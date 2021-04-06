****************************************************************
*
* Software:	Jeff Johnson
* Initiated:	4-26-95
*
* Modified:	
* 		
*
* COPYRIGHT (C) 1992 WILLIAMS ELECTRONICS GAMES, INC.
*
*.Last mod - 4/26/95
****************************************************************
	.file	"newselct.asm"
	.title	"select screen"
	.width	132
	.option	b,d,l,t
	.mnolist

	.include	"mproc.equ"
	.include	"disp.equ"
	.include	"sys.equ"
	.include	"gsp.equ"
	.include	"mac2.asm"
	.include	"imgtbl.glo"
	.include	"bgndtbl.glo"
	.include	"game.equ"
	.include	"audit.equ"
	.include	"shawn.hdr"
	.include	"link.equ"
	.include	"imgtbl2.glo"
	.include	"plyrseq.tbl"
	.include	"imgtblm.glo"
	.include	"mugshot.tbl"


	.def	team1ptr,team2ptr
	.def	cityY,cityY2
	.def	curjoypos1,curjoypos2
	.def	lastjoypos1,lastjoypos2

	.ref	IRQSKYE,DISPLAYON,WIPEOUT
	.ref	display_blank,obj_del1c
	.ref	dpageflip
	.ref	BEGINOBJ2
	.ref	GAMSTATE
	.ref	PCNT,HALT
	.ref	CRED_P
	.ref	TWOPLAYERS			;0 = NO, 1 = YES 2 players
	.ref	get_stick_val_cur
	.ref	challenger2,our_names
	.ref	challenger
	.ref	team1,team2
	.ref	team1_control,team2_control
	.ref	defeated,in_team_select
	.ref	force_selection,exit_status
	.ref	del_offscreen_bobjs
	.ref	create_player_names,update_player_names
	.ref	plaque_xs
	.ref	fullgame_purchased
	.ref	timeout,timeout2,timeout3
	.ref	update_player_heads
	.ref	delete_text
	.ref	suckup_credits
	.ref	check_suckup

	.bss	team1ptr,32		;ptrs. to 'select_screen_info_table'
	.bss	team2ptr,32
	.bss	cityY,32
	.bss	cityY2,32
	.bss	tm1cityObjPtrs,32*7	;team 1 (left side) city img. ptrs
	.bss	tm2cityObjPtrs,32*7	;team 2 (right side) city img. ptrs
	.bss	curjoypos1,16
	.bss	lastjoypos1,16
	.bss	curjoypos2,16
	.bss	lastjoypos2,16
	.bss	joyholdcnt1,32
	.bss	joyholdcnt2,32

	.text
	.even

#****************************************************************
JOY_NONE	equ	0
JOY_UP		equ	1
JOY_DOWN	equ	2
JOY_LEFT	equ	4
JOY_RIGHT	equ	8
JOY_UP_LEFT	equ	5
JOY_UP_RIGHT	equ	9
JOY_DOWN_RIGHT	equ	0Ah
JOY_DOWN_LEFT	equ	6
#****************************************************************

#****************************************************************
* New team selection
*
 SUBR	new_team_select_screen

;	clr	a0
;	move	a0,@IRQSKYE		;background color
;	calla	display_blank
;	calla	WIPEOUT
;	movk	1,a0
;	move	a0,@dpageflip
;	movk	1,a0
;	move	a0,@DISPLAYON
;	calla	display_unblank

	movk	1,a0
	move	a0,@in_team_select
	clr	a0
	move	a0,@exit_status
	move	a0,@force_selection
	move	a0,@HALT

	calla	del_offscreen_bobjs
	calla	create_player_names
	calla	update_player_names

	clr	a10
	CREATE0	challenger2
	movk	1,a10
	CREATE0	challenger2
	CREATE	TEAM1_SEL_PID,display_team_1_city_names
	CREATE	TEAM2_SEL_PID,display_team_2_city_names

;;;;	CREATE0	fullgame_purchased

	SLEEPK	1


;;;;	move	@team1_control,a0	;player selecting team 1
;;;;	move	@team2_control,a0	;player selecting team 1

	movk	15,a0
	move	a0,@team1
	movk	24,a0
	move	a0,@team2


;
; HUH ?
;
	move	@team1_control,a0	;player selecting team 1
	jrn	#not_bigrost
	sll	5,a0
	addi	defeated,a0
	move	*a0,a0,L
	move	*a0,a0,L	
	cmpi	07ffffffh,a0
	jrnz	#not_bigrost
	
	move	@team1_control,a4	;player selecting team 1
	movi	rosterblu,a9
	sll	4,a4			;x 16 bits
	addi	plaque_xs,a4
	move	@TWOPLAYERS,a0		;0 = NO, 1 = YES 2 players
	jrz	#not_2p
	addi	4*16,a4
#not_2p
	move	*a4,a10
	sll	16,a10	
	clr	a0
	move	a0,@HALT
	CREATE0	fullgame_purchased
#not_bigrost
	move	@team2_control,a0	;player selecting team 1
	jrn	#not_bigrost2
	sll	5,a0
	addi	defeated,a0
	move	*a0,a0,L
	move	*a0,a0,L	
	cmpi	07ffffffh,a0
	jrnz	#not_bigrost2
	
	move	@team2_control,a4	;player selecting team 1
	movi	rosterred,a9
	sll	4,a4			;x 16 bits
	addi	plaque_xs,a4
	move	@TWOPLAYERS,a0		;0 = NO, 1 = YES 2 players
	jrz	#not_2p2
	addi	4*16,a4
#not_2p2
	move	*a4,a10
	sll	16,a10	
	clr	a0
	move	a0,@HALT
	CREATE0	fullgame_purchased
#not_bigrost2

#wait_loop0
	movi	30*TSEC,a10
	CREATE	CNTDWN_PID,timeout


#wait_loop
	SLEEPK	1
	calla	update_player_names
;;;;	calla	update_team_set
	calla	update_player_heads

	move	@exit_status,a0
	jrnz	#wait_loop

	movi	CNTDWN_PID,a0
	calla	KIL1C
	calla	delete_text

	CREATE0	suckup_credits

#wait_loop2
	SLEEPK	1
	calla	update_player_names
	calla	update_player_heads
	move	@exit_status,a0
	jrnz	#wait_loop0

	calla	check_suckup		;wait for all credits
	jrz	#wait_loop2		;to be sucked up

	movi	TSEC+30,a10
#wait_loop3
	SLEEPK	1
	PUSH	a10
	calla	update_player_names
	calla	update_player_heads
	PULL	a10
	dsj	a10,#wait_loop3

	RETP

;-----------------------------------------------------------------
;  This (PROCESS) watches joystick (UP and DOWN) and plots 
;     the city names based on joystick movement
;-----------------------------------------------------------------
display_team_1_city_names
	movi	city_img_table_start,a0,L
	move	a0,@team1ptr,L			;init ptr.
	clr	a0
	move	a0,@curjoypos1			;no joystick data..yet
	move	a0,@joyholdcnt1
;
; First delete previous city names...
;
#dsp_t_1
	movi	TEAM1CITY,a0			;object class to delete
	calla	obj_del1c
;
; Reset (init) ptr to city name img ptr array
;
	movi	tm1cityObjPtrs,a9,L		;a9 = start of array
;
; Plot city names
;
	movk	7,a12				;nbr. team names to plot
	movi	[8,0],a1			;starting Y val
	move	a1,@cityY,L			;save Y value
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM1CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	move	@team1ptr,a11,L			;a11=ptr. to city img table
#dt1cn
	move	*a11,a2,L			;ptr. to city name image
	addi	TABLE_LINE_SIZE,a11	      ;ptr. next city img. (skip logo)
	move	@cityY,a1,L			;get Y value
	addi	>c0000,a1			;add 12 decimal (spacing)
	move	a1,@cityY,L			;save Y value
	movi	[15,0],a0			;x val
	movi	CITIESP,b0			;pal. to use for city imgs.
	calla	BEGINOBJP2
	move	a8,*a9+,L			;save obj. ptr in array
	dec	a12				;more name img. to plot ?
	jrne	#dt1cn				;br=yes
;
; Now plot the team logo (based on hi-lighted team city)
;
	move	@team1ptr,a1,L			;pt. curren pos in img tbl
	addi	HILITED_CITY_LOGO_OFFST,a1 	;pt. to hilighted city logo
	move	*a1,a2,L			;4th obj. is hi-lighted
	movi	[130,0],a0			;x val
	movi	[100,0],a1			;starting Y val
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM1CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ
;
; Now read joystick (up,down,left or right)
;
#rj_1
	move	@curjoypos1,a0			;save current joystick pos.
	move	a0,@lastjoypos1

	sleep	2
	movk	1,a0			;input:player number (0-3)
	calla	get_stick_val_cur	;ret. a0=joy switch value

	move	a0,@curjoypos1			;save current joystick pos.

	cmpi	JOY_UP,a0		;joystick up ?
	jreq	#joy_up1		;br=yes
	cmpi	JOY_DOWN,a0		;joystick down ?
	jreq	#joy_dwn1		;br=yes
	cmpi	JOY_LEFT,a0		;joystick left ?
	jreq	#joy_left1		;br=yes
	cmpi	JOY_RIGHT,a0		;joystick right ?
	jreq	#joy_right1		;br=yes
	jruc	#rj_1			;br=wait...
;
; Joystick up (team 1)
;
#joy_up1
	move	@lastjoypos1,a0			;get last joystick pos.
	move	@curjoypos1,a1			;get current joystick pos.
	cmp	a0,a1				;same ?
	jreq	#msu_1				;br=yes, maybe start scrolling
	clr	a0
	move	a0,@joyholdcnt1			;reset hold count
	jruc	#msu_1a				;update city imgs.
;
; start scrolling ?
;
#msu_1
	move	@joyholdcnt1,a0			;get hold count
	inc	a0				;inc count to start repeat
	move	a0,@joyholdcnt1			;save it
	cmpi	DELAY_B4_SCROLL,a0		;held for 40 ticks ?
	jrlo	#dsp_t_1			;br=nope...dont't move
	btst	0,a0				;every 2 wake up...move
	jrnz	#dsp_t_1			;dont move...yet
#msu_1a
	move	@team1ptr,a11,L
	subi	TABLE_LINE_SIZE,a11	;pt. to prev. team name (skip logo)
	cmpi	city_img_table_start,a11	;about to wrap around ?
	jrhs	#adrok1			;br=ptr still valid (in range) upwards
	movi	city_img_tbl_wrap,a11,L
#adrok1	move	a11,@team1ptr,L
	jruc	#dsp_t_1		;redraw city names


;
; Joystick down
;
#joy_dwn1
	move	@lastjoypos1,a0			;get last joystick pos.
	move	@curjoypos1,a1			;get current joystick pos.
	cmp	a0,a1				;same ?
	jreq	#msd_1				;br=yes, maybe start scrolling
	clr	a0
	move	a0,@joyholdcnt1			;reset hold count
	jruc	#msd_1a				;update city imgs.
;
; start scrolling ?
;
#msd_1
	move	@joyholdcnt1,a0			;get hold count
	inc	a0				;inc count to start repeat
	move	a0,@joyholdcnt1			;save it
	cmpi	DELAY_B4_SCROLL,a0		;held for 20 ticks ?
	jrlo	#dsp_t_1			;br=nope...dont't move
	btst	0,a0				;every 2 wake up...move
	jrnz	#dsp_t_1			;dont move...yet
#msd_1a
	move	@team1ptr,a11,L
	addi	TABLE_LINE_SIZE,a11	;pt. to next team name (skip logo)
	cmpi	city_img_tbl_wrap,a11	;about to wrap around ?
	jrls	#adrok2			;br=ptr still valid (in range) dwnward
	movi	city_img_table_start,a11,L
#adrok2	move	a11,@team1ptr,L
	jruc	#dsp_t_1		;redraw city names

#joy_left1
#joy_right1
	jruc	#dsp_t_1		;redraw city names
	
;-----------------------------------------------------------------------------
;  This (PROCESS) watches joystick (UP,DOWN, LEFT or RIGHT) and plots 
;     the city names, logos and heads based on joystick movement and table
;-----------------------------------------------------------------------------
display_team_2_city_names
	movi	city_img_table_start,a0,L
	move	a0,@team2ptr,L			;init ptr.
	clr	a0
	move	a0,@curjoypos2			;no joystick data..yet
	move	a0,@joyholdcnt2
;
; First delete previous city names...
;
#dsp_t_2
	movi	TEAM2CITY,a0			;object class to delete
	calla	obj_del1c
;
; Reset (init) ptr to city name img ptr array
;
	movi	tm2cityObjPtrs,a9,L		;a9 = start of array
;
; Plot city names
;
	movk	7,a12				;nbr. team names to plot
	movi	[8,0],a1			;starting Y val
	move	a1,@cityY2,L			;save Y value
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM2CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	move	@team2ptr,a11,L			;a11=ptr. to city img table
#dt2cn
	move	*a11,a2,L			;ptr. to city name image
	addi	TABLE_LINE_SIZE,a11	      ;ptr. next city img. (skip logo)
	move	@cityY2,a1,L			;get Y value
	addi	>c0000,a1			;add 12 decimal (spacing)
	move	a1,@cityY2,L			;save Y value
	movi	[300,0],a0			;x val
	movi	CITIESP,b0			;pal. to use for city imgs.
	calla	BEGINOBJP2
	move	a8,*a9+,L			;save obj. ptr in array
	dec	a12				;more name img. to plot ?
	jrne	#dt2cn				;br=yes
;
; Now plot the team logo (based on hi-lighted team city)
;
	move	@team2ptr,a1,L			;pt. curren pos in img tbl
	addi	HILITED_CITY_LOGO_OFFST,a1 	;pt. to hilighted city logo
	move	*a1,a2,L			;4th obj. is hi-lighted
	movi	[250,0],a0			;x val
	movi	[100,0],a1			;starting Y val
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM2CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ
;
; Plot (3) heads   (middle head first, then left and right)
;
	movi	RAD_MK2,a2
	movi	[260,0],a0			;x val
	movi	[205,0],a1			;starting Y val
	movi	19000,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM2CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ

	movi	SCO_MK2,a2
	movi	[200,0],a0			;x val
	movi	[200,0],a1			;starting Y val
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM2CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ

	movi	REP_MK2,a2
	movi	[320,0],a0			;x val
	movi	[200,0],a1			;starting Y val
	movi	19999,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TEAM2CITY,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ

;
; Now read joystick (up,down,left or right)
;
#rj_2
	move	@curjoypos2,a0			;save current joystick pos.
	move	a0,@lastjoypos2

	sleep	2
	movk	3,a0				;input:player number (0-3)
	calla	get_stick_val_cur		;ret. a0=joy switch value

	move	a0,@curjoypos2			;save current joystick pos.

	cmpi	JOY_UP,a0			;joystick up ?
	jreq	#joy_up2			;br=yes
	cmpi	JOY_DOWN,a0			;joystick down ?
	jreq	#joy_dwn2			;br=yes
	cmpi	JOY_LEFT,a0			;joystick right ?
	jreq	#joy_left2			;br=yes
	cmpi	JOY_RIGHT,a0			;joystick left ?
	jreq	#joy_right2			;br=yes
	jruc	#rj_2				;br=wait...

;
; Joystick up (team 2)
;
#joy_up2
	move	@lastjoypos2,a0			;get last joystick pos.
	move	@curjoypos2,a1			;get current joystick pos.
	cmp	a0,a1				;same ?
	jreq	#msu_2				;br=yes, maybe start scrolling
	clr	a0
	move	a0,@joyholdcnt2			;reset hold count
	jruc	#msu_2a				;update city imgs.
;
; start scrolling ?
;
#msu_2
	move	@joyholdcnt2,a0			;get hold count
	inc	a0				;inc count to start repeat
	move	a0,@joyholdcnt2			;save it
	cmpi	DELAY_B4_SCROLL,a0		;held for 40 ticks ?
	jrlo	#dsp_t_2			;br=nope...dont't move
	btst	0,a0				;every 2 wake up...move
	jrnz	#dsp_t_2			;dont move...yet
#msu_2a	
	move	@team2ptr,a11,L
	subi	TABLE_LINE_SIZE,a11		;pt. to prev. team name (skip logo)
	cmpi	city_img_table_start,a11	;about to wrap around ?
	jrhs	#adrok3			;br=ptr still valid (in range) upwards
	movi	city_img_tbl_wrap,a11,L
#adrok3	move	a11,@team2ptr,L
	jruc	#dsp_t_2



;
; Joystick down
;
#joy_dwn2
	move	@lastjoypos2,a0			;get last joystick pos.
	move	@curjoypos2,a1			;get current joystick pos.
	cmp	a0,a1				;same ?
	jreq	#msd_2				;br=yes, maybe start scrolling
	clr	a0
	move	a0,@joyholdcnt2			;reset hold count
	jruc	#msd_2a				;update city imgs.
;
; start scrolling ?
;
#msd_2
	move	@joyholdcnt2,a0			;get hold count
	inc	a0				;inc count to start repeat
	move	a0,@joyholdcnt2			;save it
	cmpi	DELAY_B4_SCROLL,a0		;held for 20 ticks ?
	jrlo	#dsp_t_2			;br=nope...dont't move
	btst	0,a0				;every 2 wake up...move
	jrnz	#dsp_t_2			;dont move...yet
#msd_2a
	move	@team2ptr,a11,L
	addi	TABLE_LINE_SIZE,a11	;pt. to next team name (skip logo)
	cmpi	city_img_tbl_wrap,a11	;about to wrap around ?
	jrls	#adrok4			;br=ptr still valid (in range) dwnward
	movi	city_img_table_start,a11,L
#adrok4	move	a11,@team2ptr,L
	jruc	#dsp_t_2		;redraw city names

#joy_left2
#joy_right2
	jruc	#dsp_t_2		;redraw city names


DELAY_B4_SCROLL		equ	15
TABLE_LINE_SIZE		equ	32+32			;2 longs
HILITED_CITY_NAME_OFFST	equ	TABLE_LINE_SIZE*3	;7 cites shown
HILITED_CITY_LOGO_OFFST	equ	(TABLE_LINE_SIZE*3)+32	;  4th is hi-lighted

;-----------------------------------------------------------------------------
;    This TABLE has the following format:
;  ptr. to city name img, ptr. team logo,X,Y of logo, ptr. to team heads 
;  pointer to head names, and attributes.
;-----------------------------------------------------------------------------
city_img_table_start
	.long	CIT_UTA,T_JAZZ			;for wrap around case
	.long	CIT_VAN,T_JAZZ
	.long	CIT_WAS,T_BULTS
	.long	CIT_ATL,T_HAWKS
	.long	CIT_BOS,T_CELTS
	.long	CIT_CHA,T_HORS
	.long	CIT_CHI,T_BULLS
	.long	CIT_CLE,T_CAVS
	.long	CIT_DAL,T_MAVS
	.long	CIT_DEN,T_NUGS
	.long	CIT_DET,T_PISS
	.long	CIT_GLD,T_WARS
	.long	CIT_HOU,T_ROCKS
	.long	CIT_IND,T_PACER
	.long	CIT_LAC,T_CLIPS
	.long	CIT_LAL,T_LAKS
	.long	CIT_LOS,T_ROCKS
	.long	CIT_MIA,T_HEAT
	.long	CIT_MIL,T_BUCKS
	.long	CIT_MIN,T_TWOLV
	.long	CIT_NJR,T_NETS
	.long	CIT_NYK,T_KNIKS
	.long	CIT_ORL,T_MAGIC
	.long	CIT_PHI,T_76RS
	.long	CIT_PHO,T_SUNS
	.long	CIT_POR,T_BLAZ
	.long	CIT_SAC,T_KINGS
	.long	CIT_SAN,T_SPURS
	.long	CIT_SEA,T_SONICS
city_img_tbl_wrap
	.long	CIT_TOR,T_CAVS
	.long	CIT_UTA,T_JAZZ
	.long	CIT_VAN,T_LAKS
	.long	CIT_WAS,T_BULTS
	.long	CIT_ATL,T_HAWKS				;for wrap-around
	.long	CIT_BOS,T_CELTS
	.long	CIT_CHA,T_HORS
city_img_table_end



	.even

	.end
