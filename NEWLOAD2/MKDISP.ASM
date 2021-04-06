
;
;
;
; Mark,
;
;   Look for the string: "TURMELL"
;
;
;



**************************************************************************
*												*
*   mkdisp - mortal kombat gsp dma object handler		  			*
*												*
*   copyright (c) 1995 Midway Manufacturing						*
*												*
**************************************************************************
	.file	"mkdisp.asm"
	.title	"gsp display processor"

	.width	132
	.option	b,d,l,t
	.mnolist
*
* files required for assembly
*
	.include	"sysequ.asm"
	.include	"macros.hdr"
	.include	"dispequ.asm"
	.include	"mainequ.asm"
	.include	"imgtbl.glo"

	.include	ram.glo
	.include	mkdisp.glo

slowdma	.set	1
lm_fliph	.set	m_fliph*>10000

**************************************************************************
*											     *
*  dma queue ram										     *
*											     *
**************************************************************************

cell_size	.set	32*6			; # bits in 1 dma queue cell entry
q_size		.set	cell_size*500

      	.bss	dma_q,q_size,1

objq_1 	.set	dma_q+q_size		; object queue entry #1

	.bss	dmaqcur,32		; current dmaq
	.bss	qdmaflg,16		; special dmaq being updated=1
qsize	.set	nobj*bqcell		; size of queues
	.bss	dmaq,qsize		; misc. non-sync dma queue	
	.bss	objstr,nobj*obsiz	; object structure list start
	.bss	objlstnd,0		; object list end

**************************************************************************
*											     *
*   keep chache aligned									     *
*											     *
**************************************************************************
dclipl
	move	a0,a3
	addi	oxvel,a3		; a3 ---> vel/pos info we want
	mmfm	a3,a12,a11,a9,a8
	move	b0,b0			; add velocities ?
	jrne	skip_velocities		; sans

	add	a12,a9			; add in x velocity
	add	a11,a8			; add in y velocity
	mmtm	a3,a9,a8		; stuff in new coordinates

skip_velocities
	move	a8,a10
	srl	16,a9
	movx	a9,a10			; a10 = y:x coordinates
	move	a0,a3
	addi	oflags-16,a3			; get parameter location
	mmfm	a3,a12,a11,a9,a8,a7,a6	; a12 = oflags / a7 = oflags2

	btst	b_noscroll,a7		; do we scroll ?
	jrne	clip4			; no, then don't
	subxy	a4,a10

clip4	clr	a3			; assume "single part" image
	btst	b_multipart,a7
	jreq	no_multi

	btst	b_inviso,a7		; invisible ?
	jrne	dispnext		; yes, dont display this guy

	move	*a0(oimg),a3,l	 	; a3 = multipart ram
	move	a10,b3			; save original coordinates

clip41	move	b3,a10			; restore original coordinates
	move	*a3+,a11,l 		; ram entry #1 = sag
	jreq	dispnext
	move	*a3+,a9,l		; ram entry #2 = y:x size
			 		; if the becomes lw - see: "ejby"
	move	*a3+,a2,w		; ram entry #3 = control word
	sll	16,a2
	andi	>803fffff,a12		; clear compress/clip bits
	or	a2,a12			; set "bits per pixel"

	move	*a3+,a2,l		; ram #4 --> a2 = y:x animation points
	subxy	a2,a10			; adjust coordinates
*
* on screen check
*
no_multi
	move	a10,a2
	addxy	a9,a2  		; a2 = bottom right (y,x) coordinate
	subxy	a14,a2
	jrylt	boxc3		; y greater than zero = offscreen
	jrxlt	boxc3		; x greater than zero = offscreen

	move	a2,b1		; b1 = # of pixels on screen

	move	a10,a2		; a2 = top left (y,x) coordinate
	subxy	a13,a2
	jrygt	boxc3		; y greater than zero = offscreen
	jrxgt	boxc3		; x greater than zero = offscreen

clip5	clr	a2		; a2 = coorindate adjustment for flips
	btst	b_fliph+16,a12	; flip horizontal ?
	jreq	clip6		; no
	movx	a9,a2		; yes, add x size to coordinate
	dec	a2
clip6	btst	b_flipv+16,a12	; flip vertical ?
	jreq	clip7		; no
	movy	a9,a2		; yes, add y size to coordinate
	subi	>10000,a2 	; and nudge it back up
clip7
	addxy	a2,a10		; add flip adjustments

*
* put on dma queue
*
*  a6 = oscale
*  a7 = oflags2                a10 = destination y:x    
*  a8 = const:palette xlate    a11 = image sag
*  a9 = vsize:hsize	      a12 = control:offset
*
	addxy	a5,a10				; page offset
	mmtm	a1,a6,a8,a9,a10,a11,a12	; put entry on dma queue !
	inc	b13

;	cmpi	2,b13
;	jrhs	dispnext

	dint

	.if slowdma
 	setf	1,0,0				; field 0 is 1 bit
	movk	1,a2
	move	a2,@(intenb+b_x1e),0		; enable dma interupt
	setf	16,1,0
	.else
;
; TURMELL: Ignore this.....it is not assemlbed because SLOWDMA=1
;
	move	b9,*b12,w			; enable dma interupt
	.endif

	move	@dmactrl,a2,w
	jrn	dma_is_busy			; dma busy = queue up this object

;	move	b13,b13
;	jrne	dma_is_busy

*
* dma is not busy
*
	trap 	1				; call dma interupt
						; (1)

dma_is_busy
	eint
	btst	b_multipart,a7		; is this a multipart image ?
      	jrne	clip41			; yes


clipb	move	@pageaddr,a5,l
	jruc	dispnext

boxc3  	addxy	a5,a10	 		; undo the "unpad"
	move	a3,a3	 		; we in middle of "multiparter"
	jrne	clip41	 		; yes, grab the next piece

dispnext
	move	*a0,a0,l 		; get next link
	jrne	dclipl			; done?
	rets


dma_interupt
	move	b11,b10
	move	-*b14,-*b10,l
	move	-*b14,-*b10,l
	move	-*b14,-*b10,l
	move	-*b14,-*b10,l
;
;TURMELL: Here is where the >80000 bit is set!!!! (Note: B12 is always >80000)
;
	or	b12,b10
	move	-*b14,-*b10,l
	move	-*b14,-*b10,l
	dsjs	b13,dmaq9

	setf	1,0,0				; field 0 is 1 bit
	clr	b10
	move	b10,@(intenb+b_x1e),0	; disable dma interupt (ejbpatch?)
	setf	16,0,0

         .if bog_line
	move	@vcount,@br_yellow,w
         .endif

dmaq9  	cmp	b14,b8				; are we at the shadows ?
	jreq	dmaq10				; ya !
	reti

dmaq10	move	@f_shadows,b10,w
	jreq	dmaq12

	setf	1,0,0
	clr	b10				; this section needed ?
	move	b10,@(intenb+b_x1e),0	; disable dma interupt (ejbpatch?)
	setf	16,1,0

	mmtm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14
	mmtm	sp,b0,b1,b2,b3,b4,b5

	move	@pageaddr,a5,l		; a5 = page
	move	@worldtly,a4,l

dmaqw	move	@dmactrl,a0,w
	jrn	dmaqw			; dma busy = wait

         .if bog_line
	move	@vcount,@br_blue,w
         .endif

	callr	shadow_p1p2

	move	b13,b13			; remaining queue entries ?
	jreq	dmaq11			; na !

	.if slowdma
 	setf	1,0,0			; field 0 is 1 bit
	movk	1,a2
	move	a2,@(intenb+b_x1e),0	; enable dma interupt
	setf	16,1,0
	.else
;
; TURMELL: Ignore this.....it is not assemlbed because SLOWDMA=1
;
	move	b9,*b12,w	    	; enable dma interupt (1)
	.endif

	move	@dmactrl,b3,w
	jrn	dmaq11			; dma running ?
	trap 	1			; na, start it up

dmaq11	mmfm	sp,b0,b1,b2,b3,b4,b5
	mmfm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14
dmaq12	reti

**************************************************************************
*												*
*		      end of cache alligned code					*
*		      end of cache alligned code					*
*		      end of cache alligned code					*
*												*
**************************************************************************

**************************************************************************
*												*
*		    display object lists							*
*												*
**************************************************************************
display
	move	@call_every_tick,a0,l	; routine to run every tick ?
	jreq	disp0				; no
	call	a0				; yes, call it
*
* gravity & keep in bounds
*
disp0	move	@left_edge,a0,w
	addi	left_padding,a0
	move	@right_edge,a1,w
	addi	scrrgt-right_padding,a1
	clr	a4

	move	@p1_obj,a2,l	   	; player 1 defined ?
	jreq	grav1		   	; no
	callr	gravity_n_bounds
grav1	move	@p2_obj,a2,l	   	; player 2 defined ?
	jreq	grav2		   	; no
	callr	gravity_n_bounds
*
* update scrolling
*
grav2	movi	scrollx8,a10
	movi	worldtlx8,a11
	mmfm	a10,a0,a2,a3,a4		; grab 1st 4 scroll values
	mmfm	a11,a5,a6,a7,a8		; grab 1st 4 world x values
	add	a0,a5
	add	a2,a6
	add	a3,a7
	add	a4,a8			; add 'em up
	mmtm	a11,a5,a6,a7,a8

	movi	scrollx4,a10
	movi	worldtlx4,a11
	mmfm	a10,a0,a2,a3,a4,a5	; scroll values
	mmfm	a11,a6,a7,a8,a9,a10	; world x values
	add	a0,a6
	add	a2,a7
	add	a3,a8
	add	a4,a9
	add	a5,a10			; add 'em up
	mmtm	a11,a6,a7,a8,a9,a10

	move	@scrollx,a0,l
	move	@worldtlx,a1,l
	add	a0,a1
	move	a0,@scrollx,l		; player objlst scroll

	move	@scrolly,a7,l
	move	@worldtly,a4,l
	add	a7,a4
	move	a4,@worldtly,l		; do y scrolling for all planes

**************************************************************************
*											     *
*  display object lists									     *
* 											     *
*  a0 = object pointer	       a14 = scrntl						*
*  a1 = queue pointer	        b0 = velocity flag					*
*  a4 = world top left y:x	b4 = dlist table pointer				*
*  a5 = pageaddr										     *
*											     *
**************************************************************************

	callr	init_dma_regs
	move	@pageaddr,a5,l

	move	@dlists,b4,l		; any lists to display ?
	jreq	disp5			; no

	move	@scrntl,a14,l		; a14 = top left
	move	@f_novel,b0,w		; b0 = velocity flag !!

disp1	move	b4,a3
disp2	move	*a3+,a0,l		; a0 = object list
	jreq	disp5			; zero = we are done
	jrn	disp4			; negative = next longword is a routine

disp3	move	*a3+,a13,l		; a13 = world
	move	*a13,a13,w
	movx	a13,a4			; a4 = combine to form top left y:x
	move	@scrnlr,a13,l		; a13 = lower right
	move	a3,b4
	callr	dispnext
	jruc	disp1

disp4	move	*a3+,a2,l		; a2 = routine to call
	call	a2
	jruc	disp2

*
* do manual dma queue entries
*
disp5	push	a1
	move	@qdmaflg,a0,w			; q being modified blow it off
	jrne	dma_score_area
	move	@dmaqcur,a2,l			; a2 = current queue position
	movi	dmaq+qsize,a1
	move	a1,@dmaqcur,l			; reset misc dma queue
	addi	bqcell,a1
	jruc	dqlp

dql0	mmfm	a1,a8,a9,a10,a11,a12		; get q stuff
	addxy	a5,a10				; page offset
	movi	dmaregs,a7
	rl	16,a12	       			; shift flags to upper word
q_wait	move	@dmactrl,a6,w
	jrn	q_wait	     			; wait for dma while it is busy

	movi	>01000100,a6 			; a6 = scale

;**********
;	mmtm	a7,a6,a8,a9,a10,a11,a12	; stuff the dma regs

	move	a6,-*a7,l
	move	a8,-*a7,l
	move	a9,-*a7,l
	move	a10,-*a7,l
;
; TURMELL: Here I do the same thing for the manual DMA queue !
;
	move	b12,a6
	or	a6,a7
	move	a11,-*a7,l
	move	a12,-*a7,l
;**********

dqlp	subi	2*bqcell,a1
	cmp	a2,a1
	jrhs	dql0

dma_score_area
	pull	a1

	move	@f_doscore,a0,w
	jreq	dsa9				; flag sez no !

	clr	a9				; used for zero x compare
	move	@score_1st,a0,l			; a0 = entry #1
dsa1	mmfm	a0,a2,a3,a4,a6,a7,a8		; grab dma inputs
	cmpxy	a4,a9
	jrxeq	dsa3				; x size = zero ---> skip dma
	add	a5,a6
	mmtm	a1,a2,a3,a4,a6,a7,a8 	; put entry on dma queue !
	inc	b13				; increment queue counter

	dint

	.if slowdma
 	setf	1,0,0				; field 0 is 1 bit
	movk	1,a2
	move	a2,@(intenb+b_x1e),0		; enable dma interupt
	setf	16,1,0
	.else
;
; TURMELL: Ignore this.....it is not assemlbed because SLOWDMA=1
;
	move	b9,*b12,w			; enable dma interupt (1)
	.endif

	move	@dmactrl,a2,w
	jrn	dsa2				; dma busy = skip trap
	trap 	1				; call dma interupt
dsa2	eint
dsa3	cmpi	score_ram_end,a0		; are we done ?
	jrlo	dsa1				; no

dsa9 
	.if bog_line
	move	a1,@last_dma,l			; mark the last dma queue entry
	.endif

	rets


;tttt	move	b13,b13
;	jrne	tttt
;	move	b13,b13


drop_1	.word	3,>3000-8
	.word	3,>1000-8
	.word	6,8,6,>1000-8
	.word	6,>1000
	.word	3,>1000-8
	.word	6,8,6,>1000-8
	.word	6,>1000
	.word	3,>1000-8
	.word	4,8,4,>1000-8
	.word	3,>1000
	.word	3,>1000-8
	.word	3,8,3,>1000-8
	.word	3,>1000
	.word	3,>1000
	.long	-1


gravity_n_bounds
	move	*a2(oxpos),a3,w
	cmp	a0,a3			; within left edge ?
	jrgt	kib4			; yes

	move	*a2(oflags2),a5,w
	btst	b_noedge,a5		; no edge limits ?
	jrne	kib4			; ok, let em go free

	move	a0,a3			; x coordinate = exactly on edge
	move	*a2(oxvel),a5,l
	jrp	kib6			; moving right velocity = ok
	move	a4,*a2(oxvel),l		; moving left velocity = stop it
	jruc	kib6

kib4	cmp	a1,a3			; within right edge ?
	jrlt	kib7			; yes

	move	*a2(oflags2),a5,w
	btst	b_noedge,a5		; no edge limits ?
	jrne	kib7			; ok, let em go free

	move	a1,a3			; x coordinate = exactly on edge
	move	*a2(oxvel),a5,l
	jrn	kib6			; moving left velocity = ok
	move	a4,*a2(oxvel),l		; moving right velocity = stop it
kib6	move	a3,*a2(oxpos),w

kib7	move	*a2(ograv),a5,l	   	; player 2 have gravity ?
	jreq	kib9			; no
	move	*a2(oyvel),a3,l
	add	a5,a3
	move	a3,*a2(oyvel),l		; yes add gravity to yvel
kib9	rets

**************************************************************************
*											     *
*  edge_limits - keep both players within limits of our defined universe *
* 											     *
*  input: a8 = player object in question						     *
*											     *
**************************************************************************
;edge_limits
;	jreq	elim3			; no object there ---> skip
;
;	move	*a8(oflags2),a3,w
;	btst	b_noedge,a3		; no edge limits ?
;	jrne	elim3			; ok, let em go free
;
;	move	*a8(oxpos),a3,w
;	sra	16,a3	     		; a3 = ani x
;
;	move	*a8(oxvel),a9,l
;	jreq	elim9			; zero velocity ----> skip
;	jrp	elim6
;*
;* negative velocity / moving left
;*
;	cmp	a10,a3			; compare with left edge
;	jrhi	elim3			; higher = cool
;	jreq	elim4			; equal  = no moving left allowed
;
;elim0	move	a10,a5
;	sub	a3,a5			; a5 = how far off we iz
;elim1	move	a8,a7
;elim2	move	*a7(oxpos),a0,w
;	add	a5,a0
;	move	a0,*a7(oxpos),w		; too far left = adjust back to edge
;	move	*a7(oslink),a7,l
;	jrne	elim2
;elim4	clr	a0
;	move	a0,*a8(oxvel),l		; too far left = zero x vel
;elim3	rets
;
;*
;* positive velocity / moving right
;*
;elim6	cmp	a11,a3			; compare with right edge
;	jrlo	elim3			; lower = cool
;	jreq	elim4			; equal  = no moving left allowed
;elim7	sub	a11,a3
;	move	a3,a5			; a5 = amount to adjust x left
;	neg	a5
;	jruc	elim1
;*
;* zero velocity
;*
;elim9	cmp	a10,a3			; compare with left edge
;	jrlt	elim0			; too far left ---> adjust (neg=left)
;	cmp	a11,a3			; compare with right edge
;	jrhi	elim7			; too far right ---> adjust
;	rets

**************************************************************************
*												*
*  yzsort - sort object list in z:y priority						*
*												*
*  sorts both object lists independently now (ejb)					*
*												*
**************************************************************************
yzsort:
	mmtm	sp,a0,a1,a2,a4,a5,a7,a8
	movi	objlst,a0
	callr	sort_list		; sort object list #1
	movi	objlst2,a0
	callr	sort_list		; sort object list #2
	movi	objlst3,a0
	callr	sort_list		; sort object list #3
	mmfm	sp,a0,a1,a2,a4,a5,a7,a8
	rets
*
* sort subroutine:
* input: a0 = object list to sort
*
sort_list
	movi	080000000h,a1		; lowest possible z
	movi	080000000h,a5		; lowest possible y
	move	*a0,a2,l
	jrne	yzlp0			; list not empty = sort away
	rets				; list is empty = return

yzlp0	move	*a2(ozval),a8,l		;test z
	move	*a2(oyval),a7,l		;test y
	cmp	a1,a8
	jrgt	priok
	jrlt	priswap

	cmp	a5,a7
	jrge	priok

priswap	pushst
	dint
	move	a2,*a4,l
	move	*a2,*a0,l
	move	a0,*a2,l
	popst
	move	a2,a4
	jruc	yzlp

priok	move	a0,a4
	move	a2,a0
	move	a8,a1
	move	a7,a5

yzlp	move	*a0,a2,l	; current link in a2, prev in a4
	jrne	yzlp0
	rets

**************************************************************************
*												*
*  scrtst - test if an object is on screen 						*
*												*
*  input: a8 = object to test	  returns: eq if on screen			*
*												*
**************************************************************************
*
* enter here and provide your own screen boundries
*
scrtstg	mmtm	sp,a0,a1,a2,a3
	jruc	scrtst1
*
* normal screen boundaries
*
scrtst	mmtm	sp,a0,a1,a2,a3	
	move	@scrntl,a2,l		;get screen top left
	move	@scrnlr,a3,l		;get screen lower rt.

scrtst1	move	*a8(oypos),a0,w
	move	*a8(oxpos),a1,w
	sll	16,a0
	movx	a1,a0			; a0 = top left [y,x] of object

	move	@worldtly,a1,l
	move	@worldtlx+16,a4
	movx	a4,a1			; a1 = packed worldtl [y,x]

	subxy	a1,a0			; subtract out world base
	move	*a8(osize),a1,l
	addxy	a0,a1			;get lower rt of object

	cmpxy	a3,a0			;is it lower than lower rt?
	jryge	scrtf			;lower
	jrxge	scrtf			;to the right

	cmpxy	a2,a1
	jryle	scrtf			;above...
	jrxle	scrtf			;to the left..

	clr	a0
	jruc	scrtx			;return eq (on screen)
scrtf:
	movk	1,a0
	move	a0,a0			;return ne (not on screen)
scrtx:
	mmfm	sp,a0,a1,a2,a3
	rets

**************************************************************************
*											     *
*  oinit - Initialize object system							     *
*											     *
**************************************************************************
oinit	mmtm	sp,a0,a1,a2,a3,a4,a5

	pushst
	dint
	move	@intenb,a0,w
	andni	x1e,a0			;no more dma interrupts
	move	a0,@intenb,w
	popst

	movi	zero_words_oinit,a1
	calla	zero_table_o_words

	movi	zero_longs_oinit,a1
	calla	zero_table_o_longs

	calla	dmawait			;wait on dma
	move	a0,@dmacmap,w

	movi	-1,a0
	move	a0,@swtemp1,l
	move	a0,@swtemp2,l
;MJL 03/31/95
	move	@switch2,a0,l
;MJL END
	move	a0,@swtemp3,l
	move	a0,@swtemp4,l		; all previous switch states = open

**************************************************************************
*											     *
*  setup last 2 lines of bitmap for autoerase color				     *
*											     *
**************************************************************************

	movi	510*512*8,a1		;store to last 2 lines of bitmap
	movi	erasecol,a14		;color pair
	movi	512*8*2/16,b0
lp	move	a14,*a1+
	dsj	b0,lp

	calla	clrpal			; clear palette ram

	movk	1,a0
	move	a0,@f_auto_erase,w

	movi	boonpal,a0
	calla	getfpal 		; palette #1
	mmfm	sp,a0,a1,a2,a3,a4,a5

	calla	bakclr			; clear background !!

	mmtm	sp,a0,a1,a2,a3	; save reg		
	movi	nobj,a3		; # of object blocks to init

	movi	scrnst,a0,l	; init screen top left [y,x]
	move	a0,@scrntl,l
	move	a0,@scrntl2,l

	movi	scrnend,a0,l	; init screen lower right [y,x]
	move	a0,@scrnlr,l
	move	a0,@scrnlr2,l

	movi	dmaq+qsize,a1
	move	a1,@dmaqcur,l		; init misc dma queue

; removed 7/6/93
;	pushst
;	dint
;	move	@intenb,a0,w
;	andni	x1e,a0		; no more dma interrupts
;	move	a0,@intenb,w
;	popst

	movi	objstr,a1,l
	move	a1,@ofree,l		;setup free list

oinitl	move	a1,a2
	addi	obsiz,a1,w
	move	a1,*a2,l		; link em up
	dsjs	a3,oinitl		; continue for nproc
	move	a0,*a2,l		; zero last link
	mmfm	sp,a0,a1,a2,a3		; restore regs

**************************************************************************
*											     *
*  init_dma_regs - Initialize dma registers where:				     *
* 											     *
*   a1 = dirq queue pointer								     *
* 											     *
*  b11 = dmaregs	(dedicated)									*
*  b12 = intenb	(dedicated)									*
*  b13 = counter										     *
*  b14 = dma int queue pointer								     *
*											     *
**************************************************************************
init_dma_regs
	clr	b8			; 1st shadow queue spot pointer
	movi	x1e,b9			; dedicated for speed	
	movi	dmaregs,b11		; dedicated for speed
;	movi	intenb,b12		; dedicated for speed

;
; TURMELL: Here is where I set the B12 reg to always be >80000
;

	movi	>80000,b12
	movi	objq_1,a1		; a1 = object queue entry #1 (dirq)
	move	a1,b14
	clr	b13			; b13 = queue count
	rets


zero_words_oinit
	.long	f_novel
	.long	f_auto_erase
	.long	f_shadows
	.long	noflip
	.long	f_skew
	.long	skew_y
	.long	skew_height
	.long	skew_stack
	.long	f_only_t
	.long	0

zero_longs_oinit
	.long	call_every_tick
	.long	dlists
	.long	skew_oc
	.long	skew_sag
	.long	skew_constpal
	.long	skew_dx

	.long	p1_shape
	.long	p2_shape
	.long	p1_obj
	.long	p2_obj
	.long	worldtly
	.long	worldtlx

	.long	objlst
	.long	objlst2
	.long	objlst3
	.long	baklst1
	.long	baklst2
	.long	baklst3
	.long	baklst4
	.long	baklst5
	.long	baklst6
	.long	baklst7
	.long	baklst8
	.long	baklst9
	.long	scrolly
	.long	scrollx
	.long	scrollx1
	.long	scrollx2
	.long	scrollx3
	.long	scrollx4
	.long	scrollx5
	.long	scrollx6
	.long	scrollx7
	.long	scrollx8

	.long	p1_xvel
	.long	p2_xvel
	.long	0

**************************************************************************
*												*
* getobj - get a free object block for use							*
*												*
* returns: a0 = ptr to object block								*
* if no blocks were available then the z flag is set					*
*												*
**************************************************************************
getobj	mmtm	sp,a1,a2
	move	@ofree,a0,l	; pointer to next available obj block
	jreq	getox
	move	*a0,a2,l
	move	a2,@ofree,l	; adjust pointer to free list

	clr	a2		; used for zero-ing object data
	movi	(obsiz/16)-2,a1
	addk	32,a0
	srl	1,a1
	jrnc	getobj1
	move	a2,*a0+,w
getobj1	move	a2,*a0+,l
	dsjs	a1,getobj1
	subi	obsiz,a0 	; restore a0, set non zero flag

	movi	>01000100,a2
	move	a2,*a0(oscale),l	; default scale = 100 / 100

getox	mmfm	sp,a1,a2 	; dont screw up z-flag
	rets

**************************************************************************
*												*
*  insert an object block into an object list						*
*												*
*  list is sorted by increasing z and increasing y within constant z	*
*												*
*  input: a0 = object block to be inserted 						*
*												*
**************************************************************************

*
* insert an object onto object list #3 (sorted)
*
insobj3	mmtm	sp,a1,a2,a3,a4,a5
	movi	objlst3,a4
	jruc	insobj0
*
* insert an object onto object list #2 (sorted)
*
insobj2	mmtm	sp,a1,a2,a3,a4,a5
	movi	objlst2,a4
	jruc	insobj0
*
* insert background object (sorted)
*
insbobj	mmtm	sp,a1,a2,a3,a4,a5
	movi	baklst1,a4
	jruc	insobj0

**************************************************************************
*											     *
*  insobj_v - insert background object on a variable list		     	*
* 											     *
*  input: b4 = object list to add to !						     *
*											     *
**************************************************************************
insobj_v
	mmtm	sp,a1,a2,a3,a4,a5
	move	b4,a4			; he wants it in a4
	jruc	insobj0

*
* insert object into object list #1
*
insobj:
	mmtm	sp,a1,a2,a3,a4,a5
	movi	objlst,a4

insobj0	move	*a0(ozval),a1,l		; get z position
	move	*a0(oyval),a5,l		; get y position

ins_loop move	a4,a2			; ptr to prev in a2
	move	*a2,a4,l		; ptr to next in a4
	jreq	ins_at_end		; bra if at end of list
	move	*a4(ozval),a3,l		; zpos in a3
	cmp	a3,a1
	jrgt	ins_loop
	jrlt	ins_at_end

	move	*a4(oyval),a3,l		;test y position
	cmp	a3,a5
	jrgt	ins_loop
ins_at_end:
	move	a4,*a0,l		; put next link in new block
	move	a0,*a2,l		; put link to new in prev block
	mmfm	sp,a1,a2,a3,a4,a5
	rets


delobj3
	mmtm	sp,a0,a2,a3,a4,a8
	movi	objlst3,a4
	jruc	del_loop

delobj2
	mmtm	sp,a0,a2,a3,a4,a8
	movi	objlst2,a4
	jruc	del_loop

*
* a0 = object
* a4 = object list to delete from
*
delobj_lista4
	mmtm	sp,a0,a2,a3,a4,a8
	jruc	del_loop

*
* delete foreground object
*
delobj:
	mmtm	sp,a0,a2,a3,a4,a8
	movi	objlst,a4
del_loop
	move	a4,a2		; ptr to prev in a2
	move	*a2,a4,l	; ptr to next in a4
	jrnz	del_chk
	lockup	10
	jruc	delobjx

del_chk
	cmp	a4,a0
	jrne	del_loop
	
	move	*a0,*a2,l	; put next link in prev block
	move	@ofree,a2,l				
	move	a2,*a0,l
	move	a0,@ofree,l	; return deleted block to free stack

delobjx
	mmfm	sp,a0,a2,a3,a4,a8
	rets
**************************************************************************
*												*
* kill a class of objects						 			*
* a0=oid (16 bits) ,a1=mask (16 bits)					 			*
* mask bits of zero are dont cares					 			*
*												*
**************************************************************************

**************************************************************************
*											     *
*  Kill an object from list #2								     *
*											     *
**************************************************************************
kilobj2
	mmtm	sp,a0,a2,a3,a4,a5
	movi	objlst2,a2,l
	jruc	kilgen

**************************************************************************
*											     *
*  Kill an object from list #1								     *
*											     *
**************************************************************************
kilobj
	mmtm	sp,a0,a2,a3,a4,a5
	movi	objlst,a2,l

kilgen
	and	a1,a0		;form match

kilobp:	
	move	a2,a3		;save previous
	move	*a2,a2,l	;get next
	jreq	kilobx		;all done
	move	*a2(oid),a4
	and	a1,a4		;can dont care bits
	cmp	a0,a4		;match?
	jrne	kilobp		;no

	move	*a2,*a3,l	;link around in active list	
	move	@ofree,a5,l	;link into free list at start
	move	a5,*a2,l
	move	a2,@ofree,l	;point free to cell
	move	a3,a2
	jruc	kilobp		;kill the rest
kilobx:	
	mmfm	sp,a0,a2,a3,a4,a5
	rets

**************************************************************************
*												*
* existobj - does an object from a certain class exist?				*
* a0 = oid											*
* a1 = mask (0's don't care)									*
* returns:											*
*	z bit set = no object, a0 = 0							*
*	z bit clr = no object, a0 = ptr to object					*
*												*
**************************************************************************
existobj
	mmtm	sp,a2,a3
	sext	a0
	and	a1,a0		; form match
	movi	objlst,a2,l
	callr	existobp	; try object list #1
	movi	objlst2,a2,l
	callr	existobp	; try object list #2
	jruc	existo3 	; object ain't out there....

existobp	move	*a2,a2,l	; get next
	jreq	existo4 	; end of list ---> return
	move	*a2(oid),a3,w
	and	a1,a3		; can dont care bits
	cmp	a0,a3		; match?
	jrne	existobp	; no
	pull	a0		; pull return address off stack
	move	a2,a0		; return a0 = found object (non-zero)
existo3	mmfm	sp,a2,a3
existo4	rets

**************************************************************************
*											     *
*  bkgsagof - special version of gsagof for backgrounds with no animatio *
*											     *
**************************************************************************
bkgsagof:
	move	*a1(isag->20),a3,l	; get top left sag (-20 -> no ani off)
	zext	a4,w			; zero offset in a4
	move	*a1(>40),a2,w		; grab backgrounds control offset info
	or	a2,a4			; stuff into flags
	jruc	gsag3

**************************************************************************
*											     *
* gsagof - get sag for object - adjusts sag for flip				     *
* 											     *
* input: a1 = ptr to image header (oimg)						     *
* 	a4 = object flags								     *
* 											     *
* returns: a2 = returned with new osize						     *
* 	  a3 = returned with new sag							     *
* 	  a4 = returned with new offset:oflags					     *
*											     *
**************************************************************************
gsagof
	move	*a1(isag),a3,l		; get top left sag
	zext	a4,w			; zero offset in a4
	move	*a1(icontrol),a2,w	; grab control info
	or	a2,a4			; stuff into flags
gsag3	move	*a1(isize),a2,l
	rets


;****************************************
badani
	.if debug
	dint
	jruc	$
	.endif
	jruc	anigx			; ignore bad ani calls
;****************************************



ani_flag
	move	*a8(oflags),a4,w

**************************************************************************
*												*
* ani - animation subroutine									*
* a1=new image pointer										*
* a4=new oflags											*
* a8=object structure pointer to be updated						*
*												*
**************************************************************************
ani	mmtm	sp,a0,a2,a3,a4,a5,a6,a7,a9

;*************************************
	cmpi	rom,a1
	jrlo	badani
;*************************************

	andi	dmago|dmaclp|m_fliph|m_flipv|>0f,a4	; keep flip info and dma info
	move	*a1(icontrol),a2,w
	or	a2,a4

	move	*a8(oflags),a5,w
	move	*a8(oimg),a3,l
	cmp	a1,a3
	jrne	anig1			; br = not the same image as last time

	zext	a4
	zext	a5
	cmp	a4,a5
	jreq	anigx		;br = every thing is the same

anig1	swap	a4,a5
	swap	a1,a3
	move	*a8(osize),a2,l
	callr	ganiof		;get old animation offset
	mmtm	sp,a6,a7
	move	a5,a4		;new oflags
	move	a3,a1		;new oimg

	callr	gsagof		;get sag, offset, hw
	callr	ganiof		;get new animation offset
	mmfm	sp,a0,a5	;bring back old animation delta
	sub	a6,a0		;subtract new from old
	sub	a7,a5

	move	a2,*a8(osize),l
	move	a3,*a8(osag),l
	move	a4,*a8(oflags),w

;	move	a8,a9			;get push address of oflags,osag,osize
;	addi	oflags+>60,a9
;	mmtm	a9,a2,a3,a4		;blow this stuff out

	move	a1,*a8(oimg),l

	move	*a8(oyval),a6,l
	add	a5,a6			;adjust oyval, oxval for delta x
	move	a6,*a8(oyval),l
	move	*a8(oxval),a7,l
	add	a0,a7
	move	a7,*a8(oxval),l

anigx	mmfm	sp,a0,a2,a3,a4,a5,a6,a7,a9
	rets

**************************************************************************
*											     *
*  ani0											     *
* 											     *
*  same as ani except this does not check for repeating images		     *
*											     *
**************************************************************************
ani0	mmtm	sp,a0,a2,a3,a4,a5,a6,a7,a9
	move	*a8(oflags),a5,w

;*****************
;	move	*a8(oimg),a2,l
	move	*a8(oimg),a3,l
;*****************

	jruc	anig1

**************************************************************************
*												*
*  get animation offset										*
*  a1=oimg, a2=h:w, a4=oflags									*
*												*
*  output:											*
*  a6=x animation offset x 64k									*
*  a7=y animation offset x 64k									*
*												*
**************************************************************************
ganiof:	
	mmtm	sp,a2,a3
	move	*a1(ianioff),a6,l		
	clr	a7		;make sure a7 is 0
	movy	a6,a7
	sll	16,a6		;move to upper word		
	subi	>00010001,a2	;adjust for -1
	clr	a3
	movy	a2,a3
	sll	16,a2		;move to upper word
	btst	b_fliph,a4
	jrz	gani1
	neg	a6
	add	a2,a6		;sub ths-1 for h-flip
gani1:
	btst	b_flipv,a4
	jrz	gani2
	neg	a7
	add	a3,a7		;sub tvs-1 for v-flip
gani2:
	mmfm	sp,a2,a3
	rets

**************************************************************************
*												*
*		   dma queue support routines						*
*												*
**************************************************************************
*
* qdma puts image on dma q
* inputs:
* a1: constant color:palette
* a3: destination y:x
* a5: offset:control
* a14: address of image header
* gets: a2=h/w; a4=sag
*
qdma
	mmtm	sp,a2,a4,a13
	move	*a14,a2,l		;get vsize:hsize
	move	*a14(isag),a4,l		;get sag
qdma1	movk	1,a13
	move	a13,@qdmaflg,w		;q being modified
	move	@dmaqcur,a13,l
	cmpi	dmaq,a13
	jrls	qdmax			;q overload, can it

	mmtm	a13,a1,a2,a3,a4,a5
	move	a13,@dmaqcur,l
	clr	a13
	move	a13,@qdmaflg,w
qdmax	mmfm	sp,a2,a4,a13
	rets


*manual dma (setup your own regs)
*inputs:
*a1: constant color:palette
*a2: vsize:hsize
*a3: destination y:x
*a4: sag
*a5: offset:control
qdman:
	mmtm	sp,a2,a4,a13
	jruc	qdma1

**************************************************************************
*                                                                        *
* dman - manual dma, all regs must be setup upon calling		 		*
* a1 = [constant color,palette]						 			*
* a2 = size [h,w]							 			*
* a3 = destination [y,x]						 				*
* a4 = starting address							 			*
* a5 = [offset,control]							 			*
*                                                                        *
**************************************************************************
dman
	jruc	qdman

**************************************************************************
*											     *
*  Cache aligned code #2 - Shadow code						     *
*											     *
**************************************************************************

**************************************************************************
*											     *
*   shadow_a8 - Does multipart shadows THE HARD WAY. Using		     *
* 											     *
*   a5 = page offset to add to coordinates							*
*   a8 = y:x coordinates										*
*   a9 = multipart ram pointer								     *
*  a10 = sag pointer									     *
*  a11 =	x size of piece									     *
*  a13 = scratch											*
*  a14 = control:offset									     *
* 											     *
*   b1 = lead multiplier									     *
*   b2 = ground y										*
*   b3 = counter											*
*   b4 = ani y:x										     *
*   b5 = line counter										*
*											     *
**************************************************************************
	.sect	"SHADORG"

shadow_p1p2
	move	@syscopy,a2,w			; ram copy !!
	andi	1111110011111111b,a2		; clear image bank bits
	ori	0000000100000000b,a2		; set bank 1 bit
	move	a2,@sysctrl,w
	move	a2,@syscopy,w			; keep a copy in ram

	movi	>01000100,a2
	move	a2,@dmaxscl,l	 	; dma input #1 = scale
	movi	bpal_black*>10000,a2
	move	a2,@dmacmap,l	    	; dma input #2 = const:palette
*
* setup dedicated registers
*
*  b0 = dmactrl
*  b1 = worldtly
*  a2 = dma y:x size pointer
*  a3 = dma control:offset
*  a6 = dma y coordinate pointer
* a12 = dma sag pointer
*
	movk	1,a8
	move	a8,@dmahsize+16,w

	clr	a8
	movi	dmaoffst,a3
	move	a8,*a3+,w     		; offset is always "0"
	movi	dmavert,a6
	movi	dmahoriz,a7
	movi	dmasagl,a12

	movi	dmactrl,b0
	move	@worldtly,b1,l
	move	@ceiling_y,b6,w		; ceiling y

	move	@p2_shadadj,b7,w	; player 2 shadow adjust y
	push	b7
	move	@p1_obj,a8,l
	move	@p1_shadadj,b7,w	; player 1 shadow adjust y
	jruc	shadorg

;******* end of commented stuff

	.sect	"SHADORG"

shadorg	callr	shad0
	move	@p2_obj,a8,l
	pull	b7

shad0	move	*a8(oflags2),a0,w
 	btst	b_shadow,a0		; shadow ?
	jreq	shad9			; no

	move	*a8(oimg),a9,l		; a9 ---> multipart ram
	movi	>2000000,a2		; a2 = quick handy 2 mil
	clr	a13			; bank 0 = bit clear
	move	*a9(mp_sag),a0,l	; a0 = sag of this piece
	cmpi	>4000000,a0		; lower bank ?
	jrlt	bank0			; yes
	neg	a2			; no, upper ---> flip dis !!!
	movi	>100,a13		; bank 1 = bit set

bank0 	move	@syscopy,a0,w
	andni	>100,a0			; 1st clear the bit
	or	a13,a0			; set 8th bit = use band 1
	move	a0,@sysctrl,w
	move	a0,@syscopy,w		; keep a copy in ram

	move	*a8(oypos),a13,w
	move	*a8(oxpos),a0,w
	zext	a0,w
	sll	16,a13
	or	a13,a0			; a0 = ani y:x for all pieces (world)

	move	b1,a14			; a14 = worldtly
	move	@worldtlx+16,a13,w

;************ fix elevated shadows
	zext	a13,w			; clear out the Y in case x = neg
;************ fix elevated shadows

	or	a14,a13			; a13 = world y:x
	subxy	a13,a0
	move	a0,b4			; b4 = ani y:x (screen coordinates)

	move	@ground_y,a14,w
	sll	16,a14
	subxy	a13,a14			; a14 = [screen ground y,??]
	move	a14,b2
	srl	16,b2
	add	b7,b2			; personal adjust for each ochar
	sll	16,b2			; b2 = [screen ground y,0]

**************************************************************************
*											     *
*  piece by piece loop									     *
*											     *
**************************************************************************

shad2	move	*a9(mp_sag),a10,l	; a10 = sag of this piece
	jreq	shad9			; sag = 0 ---> we are done
	
;***************
	cmpi	>a17ce6a,a10
	jreq	shadsk			; sag = 0 ---> we are done

;      	move	a10,a10
;shad19
;	jrne	not_shang_patch
;	movi	0400c20aH,a10
;	movi	0400c20aH,a10
;not_shang_patch
;***************

	add	a2,a10	    		; cpu read = add 2 mil

	move	b4,a0			; get ani y:x
	move	*a9(mp_anixy),a13,l
	subxy	a13,a0			; a0 = y:x of this piece

	move	b2,a13			; a13 = [ground y,0]
	subxy	a0,a13			; a13 = [distance from ground,??]
	srl	16,a13

	sll	16-2,a13	  	; a13 = [1/4 distance,0]
	move	b2,a14			; a14 = [ground y,0]
	subxy	a13,a14			; a14 = [shadow y,0]

	movy	a14,a0			; a0 = shadow [1/4 y:x]
	move	*a9(mp_sizey),a13,w	; a13 = # of lines

	srl	2,a13			; shadows are 1/4 the normal height

	move	a13,b5

	move	*a9(mp_sizex),a11,w
	move   	a11,@dmahsize,w		; set a11 = x size for this piece

	move	*a9(mp_control),a14,w
	btst	b_fliph,a14		; flip horizontal ?
	jreq	shad1
	addxy	a11,a0			; yes, adjust coordinates for flip
	dec	a0			; and nudge..

shad1	move	a14,a1
	move	a14,a4
	sll	16+4,a1
	srl	32-2,a1			; a1 = trail multiplier
	sll	16+4+2,a4
	srl	32-2,a4			; a4 = lead multiplier

	ori	dmacnz,a14

	addxy	a5,a0
	move	a0,*a7,w		; set x coordinate here !!
	srl	16,a0

**************************************************************************
*											     *
*  line by line loop									     *
*											     *
**************************************************************************

shad4
shad3	move	*b0,b3,w
	jrn	shad3 	      	; wait for dma while busy

	sub	a2,a10
	move	a10,*a12,l	; stuff sag
	add	a2,a10

	move	a0,*a6,w      	; set y coordinate
	move	a14,*a3,w     	; set the GO! bit
	dsjs	b5,shad5

**************************************************************************
*											     *
*  do the last line again to fill in "holes"					     *
*											     *
**************************************************************************

shad6	move	*b0,b3,w
	jrn	shad6	    	; wait for dma while busy

	inc	a0
	move	a0,*a6,w	; set y 1 line down
	dec	a0

;shad6	move	*b0,b3,w
;	jrn	shad6	    	; wait for dma while busy

	move	a14,*a3,w	; set the GO
shadsk	addi	mp_length,a9   	; a9 ---> next multipart piece
	jruc	shad2
*
* skip 4 lines
*
shad5	move	*b0,b3,w
	jrn	shad5	 	; wait for dma while busy

	inc	a0

	movk	4,b3
 	setf	8,0,0	 	; field 0 is 8 bits (zero extend)

shad7  	move	*a10+,a8,w	; grab a BYTE !!

	move	a8,a13
	sll	32-4,a13
	srl	32-4,a13	; mask off upper b.s.
	sll	a4,a13		; a13 = lead zeros

	srl	4,a8		
	sll	a1,a8		; a8 = trailing zeros

	add	a8,a13		; a13 = lead + trailing = all compressed zeros
	move	a11,a8		; a8 = x size
	sub	a13,a8		; a8 = uncompressed pixels to skip

	sll	1,a8  		; 2x
	add	a8,a10
	sll	1,a8  		; + 4x = 6 bits per pixel
	add	a8,a10		; a10 ---> sag for next line
	dsjs	b3,shad7

	setf	16,1,0		; field 0 is back to 16 bits
	jruc	shad4

shad9	rets


;************** (2)
;	move	@intenb,a0,w
;	andni	x1e,a0
;	move	a0,@intenb,w 	  	; disable dma interrupts
;************** (2)

;*************** (1)
; 	setf	1,0,0				; field 0 is 1 bit
;	movk	1,a2
;	move	a2,@(intenb+b_x1e),0		; enable dma interupt
;	setf	16,1,0
;*************** (1)


**************************************************************************
*											     *
*  Cache aligned code #2 - floor code							     *
*											     *
**************************************************************************

	.sect	"FLOORORG"

**************************************************************************
*											     *
*   floor code											*
* 											     *
*   a0 = floor_x                      b0 = DON'T TOUCH !			     *
*   a1 = dma queue pointer            b1 = DON'T TOUCH !			     *
*   a2 = scale                        b2 = DON'T TOUCH !			     *
*   a3 = const:pal                    b3 = loop counter			     *
*   a4 = piece #2 y:x size            b4 = loop counter			     *
*   a5 = DONT TOUCH                   b5 = sag holder (for a8)		     *
*   a6 = piece #1 y:x size            b6 = [1,x] size holder (for a6)    *
*   a7 = piece #1 y:x coordinates     b7 = unused				     *
*   a8 = sag										     *
*   a9 = control:offset									     *
*  a10 = skew x (running x)								     *
*  a11 = skew dx										     *
*  a13 = scratch										     *
*  a14 = piece #2 y:x coordinates							     *
* 											     *
*  a12 = running y									     *
*											     *
**************************************************************************
floor_x	.set	1200

floor_code
	move	@f_skew,a2,w		; skew the ground ?
	jreq	kib9			; no
	mmtm	sp,a3,a14
*
* scroll the floor
*
	move	@skew_scroll,a9,l
	move	*a9,a9,l
	move	@skew_oc,a10,l
	sub	a9,a10
	move	a10,@skew_oc,l		; scroll "OFF CENTER" indicator !!

	move	@skew_calla,a0,l
	jump	a0
skew_rets				; a11 = dx per line
	move	a11,@skew_dx,l

	move	@skew_height,b4,w	; b4 = # of lines to DMA out
	move	@skew_y,b6,w
	move	@worldtly+16,b3,w
	sub	b3,b6			; b6 = starting y screen coordinates
	cmpi	254,b6
	jrgt	floor_exit	    	; off screen ---> exit
	sll	16,b6
	move	@skew_sag,a8,l
*
* CONSTANTS !!
*
	movi	>01000100,a2		; scale
	move	@skew_constpal,a3,l	; const:pal
	movi	>00010190,a6		; y:x size
	movi	>e0020000,a9		; conrtol:offset
	movi	floor_x*6,a12	  	; beginning of next line offset
      	movi	>00010000,b2		; setup for fast "down 1 line"
*
*  a10 = how far off center we are !
*  a11 = skew value to add for EACH LINE
*
floor6	move	b6,a13
	clr	a7
	movy	a13,a7	     	 	; move current y into a7
	addxy	a5,a7			; a7 = our line's y:x coordinates

	move	a8,b1			; save sag
	move	a10,a13
	sra	16,a13	     	 	; a13 = pixels off center (integer)
	sll	1,a13
	move	a13,a0
	sll	1,a13
	add	a13,a0			; a0 = 6 bits/pixel
	sub	a0,a8			; adjust sag
	mmtm	a1,a2,a3,a6,a7,a8,a9	; floor piece ---> on the queue
	inc	b13
	move	b1,a8			; restore sag

	add	a12,a8			; sag ---> beginning of next line
	add	a11,a10			; start skew on line two

	add	b2,b6			; down 1 line

	dsjs	b4,floor6

floor_exit
	mmfm	sp,a3,a14
	rets

**************************************************************************

	.if bog_line

*
* a2 = vcount to use
* a3 = constant color to use
*
draw_boglines
	mmtm	sp,a0,a1,a2,a3

dbog2	move	@dmactrl,a0,w
	jrn	dbog2			; dma busy = wait

;	move	@br_red,a2,w
;	movi	bog_red,a3
;	callr	draw_1_line

;	move	@br_white,a2,w
;	movi	bog_white,a3
;	callr	draw_1_line

;	move	@br_blue,a2,w
;	movi	bog_blue,a3
;	callr	draw_1_line

	move	@br_yellow,a2,w
	movi	bog_yellow,a3
	callr	draw_1_line

	mmfm	sp,a0,a1,a2,a3
	rets


draw_1_line
	move	a2,a2
	jreq	draw9
	cmpi	>fe,a2
	jreq	draw9			; dont write onto erase lines
	cmpi	>ff,a2
	jreq	draw9			; dont write onto erase lines

	clr	a0
	move	a0,@dmacmap,w		; setup dma palette register

	move	@pageaddr,a1,l
	srl	8,a1
	sll	4,a1
	addi	>38*8,a1		; padding bs

	sll	12,a2
	add	a2,a1

;	movi	30,a2
	movk	10,a2
draw7	move	a3,*a1+,l
	dsjs	a2,draw7

draw9	rets

	.endif


; 	setf	3,0,0	   	 	; field 0 is 3 bits (zero extend)
; 	setf	8,0,1	   	 	; field 0 is 8 bits (zero extend)
;	move	a12,a5
;rain1	move	a11,a3
;rain2	move	*a0+,a2,w  		; grab 3 bits
;	jreq	rain3			; zero ---> don't write
;	move	a2,*a1,l		; stuff 8 bits
;rain3	addk	8,a1
;	dsjs	a3,rain2
;	addi	>1000-(6*8),a1		; down 1 line on the screen
;	dsjs	a5,rain1
;	setf	16,1,0
;	setf	32,1,1


*************************************************
*
* rain !!
*
;	move	@gstate,a0,w
;	cmpi	99,a0
;	jrne	norain
;
;;	movi	>0e0e0e0e,a3
;;	calla	draw_bogline		; white = start of rain loop
;
;	movi	>0101,a0
;	move	a0,@dmacmap,w		; setup dma palette register
;
;	movi	rain_ram,a4
;	move	@pageaddr,a11,l		; take this outside the loop
;	srl	8,a11
;	sll	4,a11
;	addi	>38*8,a11		; a11 = top of page we are on
;
;rain5	move	*a4,a6,l		; x coordinate
;	jreq	rain9
;
;	move	*a4(32*2),a9,l		; x vel
;	add	a9,a6
;	move	*a4(32*1),a7,l		; y coordinate
;	move	*a4(32*3),a9,l		; y vel
;	add	a9,a7
;
;	cmpi	0,a6
;	jrgt	rain4
;	movi	(scrrgt-17)*>10000,a6
;rain4	cmpi	234*>10000,a7		; hit ground ?
;	jrlt	rain6
;	clr	a7
;rain6	move	a6,*a4,l		; stuff new x coordinate
;	move	a7,*a4(32*1),l		; stuff new y coordinate
;
;	move	a11,a1			; grab the correct page
;	srl	16,a7
;	sll	12,a7
;	add	a7,a1			; add in y coordinate
;	srl	16,a6
;	sll	3,a6			; x coordinate * 8 bits/pix (screen)
;	add	a6,a1
;*
;* draw drop
;*
;	movi	drop_1,a0
;	movk	14,a3			; rain drop = 14 lines tall
;rain2	move	*a0+,a2,l		; grab [offset,pixel data]
;	movb	a2,*a1			; stuff 1 pixel
;	srl	16,a2
;	add	a2,a1			; add in offset
;	dsjs	a3,rain2
;
;rain3	addi	32*4,a4
;	jruc	rain5
;
;rain9
;;	movi	>04040404,a3
;;	calla	draw_bogline
;
;norain
************************************************************************

	.end
