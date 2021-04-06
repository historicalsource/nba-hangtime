**************************************************************
*
* Software:		Warren Davis
* Initiated:		9/3/91
*
* Modified:		Shawn Liptak, 8/13/92	-Basketball
*
* COPYRIGHT (C) 1992 WILLIAMS ELECTRONICS GAMES, INC.
*
*.Last mod - 3/24/93 11:23
**************************************************************
	.file	"unzip.asm"
	.title	"pkzip unzipper"
	.width	132
	.option	b,d,l,t
	.mnolist

	.include	dispequ.asm		;Display proc equates
	.include	sysequ.asm
	.include	mainequ.asm
	.include	macros.hdr
	.include	stringh.asm
	
	.include	mk3zip.tbl

;	.include	mk3end.tbl
;	.include	mk3bio.tbl

	.include	ram.glo


	.ref	syscopy

BPP		.set 	3
RAMBUFSIZ	.set	(4*1024)*8		; << BPP
;SCRN_ST		.set	(170*scrn_ptch)+(150*8)
;PXLS_PR_TIK	.set	10000

;PAGE1ADR	.equ	PAGE1YO*512*8

page_1_address	.set	>100000		; = PAGE1YO*512*8

CARYTEST		.equ	0		;1 for Cary's board testing
DEBUGPORT	.equ	>1d01010
TUNITDB		.equ	0


PTEMP1		.equ	p_store1
PIXPERFRM	.set	p_store2


RamBuffer	.usect	"unzip",RAMBUFSIZ

	.bss	lengthtree	,256*32
	.bss	disttree	,256*32
	.bss	minptrtbl	,256*32

	.def	lengthtree
	.text



display_zipped_pic
	move	a0,a1
	sll	5,a0
	sll	4,a1
	add	a1,a0
	addi	zipped_pics,a0
	move	*a0+,a1,w			; bank ??
	cmpi	2,a1
	jrne	dzp3

	move	@syscopy,a1,w			; ram copy !!
	andi	1111110011111111b,a1		; clear image bank bits
	ori	0000001000000000b,a1		; set bank 2 bit
	move	a1,@sysctrl,w
	move	a1,@syscopy,w			; keep a copy in ram
	jruc	dzp9

dzp3	cmpi	1,a1
	jrne	dzp4

	move	@syscopy,a1,w			; ram copy !!
	andi	1111110011111111b,a1		; clear image bank bits
	ori	0000000100000000b,a1		; set bank 2 bit
	move	a1,@sysctrl,w
	move	a1,@syscopy,w			; keep a copy in ram
	jruc	dzp9

dzp4	cmpi	0,a1
	jrne	dzp9

	move	@syscopy,a1,w			; ram copy !!
	andi	1111110011111111b,a1		; clear image bank bits
	move	a1,@sysctrl,w
	move	a1,@syscopy,w			; keep a copy in ram

dzp9	move	*a0,a8,l
	jruc	movie_run


zipped_pics
	.word	1
;	.long	MK3TITLE		; 0 = title screen
	.long	ULT		; 0 = title screen


*******************************************************
*******************************************************
*******************************************************


*******************************
* Run movie footage (jsrp)
* A8=* compressed picture data
* A9=Mode (0=Normal, 1=x2)
* A10=Screen * for top left of picture
* Trashes scratch, A2-A11,B2-B10

movie_run
	clr	a9			; always normal !!

	addi	xpadding*8,a10		;+XPad offset

;*******************
	move	@pageaddr,a14,l		; what page did we just plot to ??
	cmpi	page0adr+xpadding,a14
	jreq	p2
;	move	@dpage,a14
;	jrnz	p2
;*******************

	addi	page_1_address,a10	;Start in page 1 if page 0 is being displayed
p2


;****************
;
; stream line coded (ejb)
;
;	callr	movie_w aitdma
mwait	move	b13,b13			;Wait for DMAQ empty
	jrgt	mwait
	move	@dmactrl,a14
	jrn	mwait
;
;****************

	callr	movie_parsehdr
	jrnz	error1

	move	b3,a14			;Height
	subk	1,a14
	movi	scrn_ptch,a1
	mpys	a14,a1
	add	a1,a10			;* to bottom left

	callr	movie_getpal
	jrz	error1
					;A4= frames
					;A6=X size
					;B3=Y size
					;B4=strtpal
	movi	blowline,b10
	move	a9,a9
	jrz	mode0
	movi	blowlinex2,b10
mode0	jsrp	movie_unzip

x0	setf	16,1,0
	setf	32,0,1
	retp

error1
	clr	a14
	move	a14,@DEBUGPORT

	lockup	7
	jruc	x0


*******************************
* Get a movie palette
* A7= of colors
* A8=* to color data
* >A0=Color map allocated (0000-cfcf)
* Z set if no palette free
* Trashes scratch

movie_getpal

	move	a8,a0
	subk	16,a0		;Point to  colors

;*************
;	calla	pal_getf
	calla	getfpal
;*************

	jrz	x3

	move	a7,a1
	sll	4,a1		;*16
	add	a1,a8

	move	a0,b4
	addk	1,a1		;Clr Z

x3	rets



*******************************
* Get movie info
* A8=* to compressed data
*Rets:
* >A0=!0 if error (CC)
* >A4= frames
* >A6/B9=X
* >A7= colors in palette
* >B3=Y
* Trashes scratch

movie_parsehdr
	move	a8,a14
	movk	30,a0		; retries

;rd
	move	*a8+,a6		;X size of frames
	move	*a8+,a1		;Y size of frames
;	movi	200,a1
	move	*a8+,a4		; of frames
	move	*a8+,a7		; of colors
	move	a1,b3
	move	a6,b9
	clr	a0
	rets



	.sect	"UNZIP"

********************************
* GSP Decompression routine
*
*	ASSUMPTIONS:  1) There is no literal table
*	              2) the size of the sliding window is 4K
*
*	Needs the following Data Tables:
*		CompressedDataTable will contain the following once
*		it is uncompressed:
*			 frames            (1 byte)
*			 colors in palette (1 byte)
*			X size of frame     (1 byte)
*			Y Size of frame     (1 byte)
*			variable length palette data
*			data for each frame
*
*	Needs the following RAM variables:
*		LengthTree   256 long words
*		DistanceTree 256 long words
*		MinPtrTable  256 long words (used for sort)
*		RamBuffer    circular buffer
*	        Tree layout is as follows...
*			low 16 bits = Code
*			next 8 bits = Bit length
*
*	B reg usage...
*		B0 = Ptr to Length tree
*		B1 = Ptr to Distance tree
*		B3 = start of line
*		B4 = start palette duped to fill 16 bits
*		B5 = used for outputting pal bits to DMAPAL
*		B6 = temp storage in ReadTree and UncompressTree
*		B7 = constant mask for pxl palette split
*		B8 = DMAPAL
*		B9 = Master X storage


*******************************
* Uncompress a tree
* A7=* to tree table
* A8=* to compressed data
* >A0=!0 if error (CC)

UncompressTree:

	PUSH	a4,a5

	move	a7,a5		;Save start of tree

	clr	a4
	PUSH	a8
				;>Determine how many codes of each bit length
	setf	8,0,0
	move	*a8+,a0		; compressed bytes to describe tree - 1
	addk	1,a0
	movk	>f,a3		;Constant
	clr	a6		;Total number of codes in tree
utr0
	move	*a8+,a1		;( codes - 1 << 4) | bit lngth - 1
	add	a1,a4		;Chksum
	move	a1,a2
	srl	4,a2
	addk	1,a2		;number of codes of this bit length
	add	a2,a6		;adjust total
	and	a3,a1
	addk	1,a1		;bit length
	move	a1,a11
	sll	16,a11
	movy	a11,a1		;duplicate bit length for sort
utr1
	move	a1,*a7+,l
	dsj	a2,utr1		;fill table

	dsj	a0,utr0		;a6 now contains size of tree


	PULL	a8		;>Recalc chksum
	clr	a2
	move	*a8+,a0		; compressed bytes to describe tree - 1
	addk	1,a0
chklp	move	*a8+,a1
	add	a1,a2
	dsj	a0,chklp

	setf	16,1,0

	cmp	a2,a4
	jrne	error3		;Chksums don't match?


*	Sort Tree by increasing Bit Length.
*		The translation index is placed in the upper byte
*		of the long word.

	movi	minptrtbl,a0	; for placing translation ptrs
	move	a6,a9		; outer loop count ( entries in tree table)

*	Outer loop, after each pass, we have found the next minimum

utr2
	move	a5,a7		; restore start of tree
	movi	06543h,a14	; current minimum
	move	a6,b6		; inner loop count
	movi	07654h,a1	; constant

*	Inner loop, go through all values in table and find min.
*	When we find it, we set it to a high value so we don't detect
*	it again.

utr3
	move	*a7,a2		; look at next bit length
	cmp	a14,a2		; is it less than the last minimum
	jrge	nonewmin
	move	a2,a14		; if yes, save new minimum
	move	a7,a11		;         save pointer to minimum
nonewmin
	addk	32,a7		; point to next entry
	dsj	b6,utr3

;	end of inner loop: min is in a14, ptr to min is in a7

	move	a1,*a11		; set this minimum high.
	move	a11,*a0+,l	; place translation ptr in MinPtrTbl.

	dsjs	a9,utr2
				;>Compute the codes
	clr	a11		;Code
	clr	a1		;CodeInc
	clr	a2		;LastBitLength
	move	a6,a14		;loop counter
utr4
	move	*-a0,a7,l	;translated pointer
	add	a1,a11
	movb	*a7(16),a3	;bit length
	cmp	a3,a2
	jreq	samebitlng
	move	a3,a2		;set new LastBitLength
	movk	16,a3
	sub	a2,a3		;16-LastBitLength
	movk	1,a1
	sll	a3,a1		;CodeInc = 1 << (16-LastBitLength)
samebitlng
	move	a11,a5		;copy of Code in a5
	movk	16,a9		;reverse bit loop count
rvrsbts
	sll	1,a5		;Reverse bits of word
	movy	a5,a3
	srl	1,a3
	zext	a5
	dsjs	a9,rvrsbts

	move	a3,*a7		;store code with bits reversed
	dsjs	a14,utr4

	clr	a0

x4	PULL	a4,a5
	move	a0,a0
	rets


error3
	movk	1001b,a14
	move	a14,@DEBUGPORT

	lockup	8
	movk	1,a0		;Error!
	jruc	x4

********************************

SetConstants:
	movi	lengthtree,b0
	movi	disttree,b1
SetConstX
	movi	RamBuffer+RAMBUFSIZ-1,a0	;mask for rambuf ptr
	movi	RamBuffer,a6			;used for negative wraparound
	movi	0c0c0h,b7			;for blowing words of
	movi	dmacmap,b8
;	movi	blowline,b10
	rets

*******************************
* Initialize and run unzip loop (jsrp)
* A4= of frames
* A8=* compressed data table
* A10=Screen * for top left of picture
* B3=Y size
* B4=strt pal
* B9=X size

movie_unzip
	movi	lengthtree,b0
	movi	disttree,b1

	movk	10,a5
ltlp	move	b0,a7			;Length Tree
	move	a8,b2
	callr	UncompressTree
	jrz	ltok			;OK?
	move	b2,a8
	dsj	a5,ltlp
	jruc	error
ltok

	movk	10,a5
dtlp	move	b1,a7			;Distance Tree
	move	a8,b2
	callr	UncompressTree
	jrz	dtok			;OK?
	move	b2,a8
	dsj	a5,dtlp
	jruc	error
dtok


debugstrt

	;Clear top 4K of buffer to take care of initial wraparound

	movi	RamBuffer+RAMBUFSIZ,a1	;End of buffer
	movi	1024,a2			;4K
	clr	a3
clrbuf
	move	a3,*-a1,l
	dsj	a2,clrbuf

					;Do some initializing
	mpyu	b9,b3
	move	b3,a11			;total  bytes in frame in a11
	move	a11,*a13(PIXPERFRM),l
	callr	SetConstX
	move	a6,a9			;Where to uncompress to
	move	a9,b3			;first frame start
	clr	b5			;pixel count for Stills only


lp5	mmtm	a12,a4,a10

	callr	movie_waitdma

;	clr	b2
;	move	b2,@tick,w		; start tick = 0

;	cmpi	>c000,a11
;	jrlo	pic_not_too_big
;	move	a11,b2
;	movi	>4000,a11
;	subi	>4000,b2
;	jsrp	UncompressFrame
;	move	b2,a11
;	movk	1,a0				; 1 tick sleep
;	movi	toobig3,a14
;	jruc	GoToSleep
;toobig3
;
;	move	a11,b2
;	movi	>4000,a11
;	subi	>4000,b2
;	jsrp	UncompressFrame
;	move	b2,a11
;	movk	1,a0				; 1 tick sleep
;	movi	toobig4,a14
;	jruc	GoToSleep
;toobig4	move	b2,a11
;
;
;pic_not_too_big

	jsrp	UncompressFrame

; ********************************* rev1.1 change
	move	@f_zipabort,a14,w
	jrne	uncompress_ok		   	; yes 
	mmfm	a12,a4,a10
	setf	16,1,0				; word sign extend
	setf	32,1,1				; long word
	retp
uncompress_ok
; ********************************* rev1.1 change

	clr	a0
	move	a0,@DEBUGPORT
	movk	1,a0				; 1 tick sleep
	movi	swappg,a14
	jruc	GoToSleep

swappg	mmfm	a12,a4,a10
	xori	page_1_address,a10		; Flip to other page

	setf	16,1,0
	move	*a13(PIXPERFRM),a14,l	; number of pixels in a frame
	add	a14,a11				; adjust by extra pixels done last time

	dsj	a4,lp5				; Loop once for each frame

	callr	movie_waitdma

x5	retp

error	lockup	9
	jruc	x5

******************************** rev1.1 change

coin_switch_bits	.set	>1c30000		; coin switch spots !

******************************** rev1.1 change


GoToSleep
	getst	b2
	move	a12,b6
	mmtm	b6,b2,b3,b4,b5,b9,b10
	move	b6,a12

	setf	16,1,0
	setf	32,0,1
	move	a14,*a13(PTEMP1),l
	calla	prcslp

	move	a12,b6
	mmfm	b6,b2,b3,b4,b5,b9,b10
	move	b6,a12

	callr	SetConstants
	move	*a13(PTEMP1),a14,l

	putst	b2
	exgpc	a14			;Return


********************************
* Uncompress a single frame
* A0=Address mask for circular buffer
* A8=* to compressed data
* A9=* to buffer for uncompressed bytes
* A11=How many to place before returning
* B0=*Length tree
* B1=*Distance tree
*
*Trashes:
*	a1 = Distance
*	a2 = ptr to leftover data if there is any
*	a4 = Length
*
* ReadTree uses A2-A5,A7,A14,B6
* Need to Preserve: 	B9-B10

UncompressFrame:

	movi	>4000,b2	; watch dog counter

	setf	16,0,1		;Field 1 = 16 bits no sign-ext
	move	b4,*b8,1	;Set pallette

UncFr0
	setf	1,0,0
	move	*a8+,a14	; if bit = 1, read 8 bits and copy

	jrz	decode_still
	setf	8,0,0

	move	*a8+,*a9+
	and	a0,a9

	addk	1,b5		; pixel count
	subk	1,a11
us1
	cmp	b5,b9		; have we filled a line yet?
	jrgt	us0

    	call	b10		; Blow Line Routine

us0    

;**************** rev1.1 change
	setf	32,1,0			; long word
	move	@switch+32,a14,w
	setf	8,0,0			; back 2 how it wuz
	not	a14
	andi	coin_switch_bits,a14		; any coin switches ??
	jrne	coin_switch_abort
	dec	b2
	jrne	dont_feed_dog
	movi	>4000,b2		; watch dog counter
	move	b2,@watchdog,w		; feed the watchdog
dont_feed_dog
;**************** rev1.1 change

	move	a11,a11
	jrgt	UncFr0

	setf	16,1,0
	setf	32,0,1
	retp

;**************** rev1.1 change
coin_switch_abort
	setf	16,1,0
	setf	32,0,1
	movk	1,a14
	move	a14,@f_zipabort,w	; flag: ABORTED !!!
	retp
;**************** rev1.1 change


decode_still:		 	; if bit = 0, decode from trees
	setf	6,0,0
	move	*a8+,a1		; lower 6 bits of distance

	move	b1,a5		; Distance Tree in a5
	callr	ReadTree	; Result in a7
	sll	6,a7
	or	a7,a1
	inc	a1		; DISTANCE in a1
	sll	BPP,a1		; turn it into a pointer

	move	b0,a5		; Length Tree in a5
	callr	ReadTree	; Result in a7

	setf	8,0,0

	cmpi	63,a7
	jrne	notmaxs
	move	*a8+,a3		; If length is 63, get next byte, and

	add	a3,a7		; add it to the length
notmaxs
	addk	2,a7		; add MML, LENGTH in a7

;	We now have Length and Distance,  now determine where to copy from

	move	a9,a2		; copy of current position in a2
	sub	a1,a2  		; initial attempt
	and	a0,a2		; handle wraparound
	or	a6,a2		;copy pointer is now in a2

	sub	a7,a11		;Adjust total pixel count
	move	a7,b6
	add	b6,b5	    	;Adjust pixel counter for this line

copys
	move	*a2+,*a9+	;>Copy
	and	a0,a2
	and	a0,a9
	dsj	a7,copys

	jruc	us1


*******************************
* Read compression tree
* A5=*Tree table
* A8=*Compressed data
* Field 1 = 16 bits
* >A7=Data
*
* Trashes: A2-A5,A14,B6
*
* Must preserve: A0,A1,A6,A8-A11

ReadTree:
	movk	1,a2		; bits_read
	setf	1,0,0
	move	*a8+,a7		; read a bit
	rl	31,a7		; rotate right one more bit
	clr	b6		; result
	jruc	strt
lp6
	addk	1,b6
strt	move	*a5+,a3,1	; Code in a3
	move	*a5+,a4,1	; Blngth in a4
	movk	32,a14
	sub	a2,a14
	rl	a14,a3		; rotate right as many bits have been read
lp2
	cmpxy	a3,a7
	jrynz	lp6

	cmp	a2,a4
	jreq	x6
	move	*a8+,a14	; read a bit
	or	a14,a7		; accumulate with other bits
	inc	a2		; inc bits_read
	rl	31,a7		; rotate right one more bit
	rl	31,a3		; shift code for check of next bit
	jruc	lp2

x6
	move	b6,a7
	rets			;Result returned in a7



*******************************
* BlowLine is used during decompression of a Still Picture to blow out
* a single line of data.  Since only a single line needs to be stored at
* once, the RamBuffer can be as small as 4K.
* A0=Address mask for circular buffer
* Field 1 = 16 bits
* Trashes A1-A2,A5

blowline

;	setf	32,0,0

	move	a10,a2 		;* screen

	move	b3,a1		;Start of line
	move	b9,a5		;X size
	srl	2,a5		;X/4 = loop counter
	jrnc	by4
	move	*a1+,*a2+,1	;Copy 2 pixels
	and	a0,a1
by4
lp7
	move	*a1+,*a2+,1	;Copy 2 pixels
	and	a0,a1
	move	*a1+,*a2+,1	;Copy 2 pixels
	and	a0,a1
	dsj	a5,lp7


endblowline
	subi	scrn_ptch,a10
	move	a1,b3		;save for next frame
	sub	b9,b5		;readjust pixels for next line
	cmp	b9,b5		;added 6/92. if there are enough pixels
	jrge	nuther1		;left to do another line, do it.

      	rets

nuther1
	jruc	blowline

********************************
* Same as BlowLine, but blows to both screens
* Trashes A1,A3-A5

;blowlinelastfrm
;
;	move	a10,a3 		; where on screen to put
;	move	a3,a4
;	xori	PAGE1ADR,a4
;	move	b3,a1		; start of line
;	move	b9,a5		; X size
;	srl	1,a5		; X/2 = loop counter
;
;spbl1
;	move	*a1+,a14,1		; write into both screens
;	move	a14,*a3+,1
;	move	a14,*a4+,1		; write into both screens
;	and	a0,a1
;	dsjs	a5,spbl1
;
;	jruc	endblowline


*******************************
* BlowLine is used during decompression of a Still Picture to blow out
* a single line of data.  Since only a single line needs to be stored at
* once, the RamBuffer can be as small as 4K.
* A0=Address mask for circular buffer
* Field 1 = 16 bits

blowlinex2
	move	a10,a2 		;* screen
	move	a10,a3
	addi	scrn_ptch,a3

	move	b3,a1		;start of line
	move	b9,a5		;X size

	setf	8,0,0
lp8
	move	*a1+,a14	;Get 8 bits
	move	a14,a4
	sll	8,a4
	or	a4,a14
	move	a14,*a2+,1	;16 bits
	move	a14,*a3+,1
	and	a0,a1
	dsjs	a5,lp8

	subi	scrn_ptch*2,a10
	move	a1,b3		; save for next frame
	sub	b9,b5		; readjust pixels for next line
	cmp	b9,b5		; added 6/92. if there are enough pixels
	jrge	nuther2		; left to do another line, do it.

      	rets

nuther2
	jruc	blowlinex2

**************************************************************************
*											     *
*  Wait for DMA activity to stop								     *
*  Trashes A14										     *
*											     *
**************************************************************************
movie_waitdma
	move	b13,b13			;Wait for DMAQ empty
	jrgt	movie_waitdma
	move	@dmactrl,a14
	jrn	movie_waitdma
	rets

;**********************************************************************



	.end
