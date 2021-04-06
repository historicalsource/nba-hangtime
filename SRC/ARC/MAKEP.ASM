;-----------------------------------------------------------------------------
;
; COPYRIGHT (C) 1992 WILLIAMS ELECTRONICS GAMES, INC.
;
;.Last mod - 5/9/95 
;-----------------------------------------------------------------------------
	.file	"makeplyr.asm"
	.title	"create player logic"
	.width	132
	.option	b,d,l,t
	.mnolist

	.include	"mproc.equ"
	.include	"disp.equ"
	.include	"sys.equ"
	.include	"gsp.equ"
	.include	"mac2.asm"

	.include	"imgtbl.glo"
	.include	"imgtbl2.glo"
	.include	"bgndtbl.glo"
	.include	"game.equ"
	.include	"audit.equ"
	.include	"shawn.hdr"
	.include	"plyrseq.tbl"


NUM_ICONS	equ	8
NUM_ATTRIBS	equ	8


	.global	player1_data,player2_data,player3_data,player4_data

	.def	create_modify_player
	.def	in_create_plyr

	.ref	create_plyr	    ;-1=can't create plyr, 0=could, 1=creating
	.ref	player_heads			;table addr.
	.ref	player_names			;table addr.
	.ref	our_names			;table addr.
	.ref	guyhds				;table addr.
	.ref	our_heads			;table addr.
	.ref	player_attribs			;table addr.
	.ref	logos
	.ref	city_tbl
	.ref	KILBGND,WIPEOUT
	.ref	pal_clean
	.ref	BAKMODS,BGND_UD1
	.ref	scrnrel_off,print_string_C2
	.ref	mess_line_spacing,mess_objid
	.ref	setup_message
	.ref	osgemd_ascii,delete_text
	.ref	sgmd8_ascii
	.ref	dpageflip
	.ref	get_but_val_cur
	.ref	get_but_val_down
	.ref	get_stick_val_cur
	.ref	get_stick_val_down
	.ref	pal_getf
	.ref	button_actions
	.ref	get_player_record
	.ref	move_cursor,update_cursor
	.ref	save_selection
	.ref	pin_nbr_table,name_table
	.ref	force_selection
	.ref	create_menu,create_name_objs
 
	.bss	plyr_drib_cnt,16
	.bss	plyr_dribble_obj,32
	.bss	in_create_plyr,16
	.bss	timer,16
	.bss	timer_img_ptr,32*2
	.bss	icon_cursor_pos,16
	.bss	joy_pos,16
	.bss	icon_objs,32*NUM_ICONS		;8 icons on screen

	.bss	speed_points,16			;0-100 attribute amount
	.bss	power_points,16			;0-100 attribute amount
	.bss	shoot_points,16			;0-100 attribute amount
	.bss	dunks_points,16			;0-100 attribute amount
	.bss	steal_points,16			;0-100 attribute amount
	.bss	block_points,16			;0-100 attribute amount
	.bss	height_points,16		;0-10
	.bss	weight_points,16		;0-10
	.bss	total_points,16			;60 points max (perfect plyr)

	.bss	attribute_bar_objs,32*NUM_ATTRIBS
	.bss	attrib_cur_pos,16
	.bss	processing_icon,16		;1=performing icon action
	.bss	button_pos,16
	.bss	attribute_name_objs,32*NUM_ATTRIBS

	.text


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBR	create_modify_player
 
	movk	1,a0
	move	a0,@in_create_plyr
	movk	1,a0				;set cause must wait for plyr
	move	a0,@processing_icon		;to enter inits. & pin nbr

;set defaults
	movi	50,a0
	move	a0,@speed_points
	move	a0,@power_points
	move	a0,@shoot_points
	move	a0,@dunks_points
	move	a0,@steal_points
	move	a0,@block_points
	move	a0,@height_points
	move	a0,@weight_points
	movi	50,a0
	move	a0,@total_points

;setup new background
	clr	a0
	movi	-1,a1
	calla	obj_delc
	calla	pal_clean
	clr	a1				;kill all processes
	calla	KILALL

	movi	create_player_mod,a0
	move	a0,@BAKMODS,L
	calla	BGND_UD1

	calla	create_icons

	CREATE0	player_dribbing_ball

	CREATE0	timedown_create_player_timer
	CREATE0	icon_cursor_control

	movk	3,a10
	CREATE0	enter_create_plyr_initials

;	movi	create_strs_setup,a2
;	calla	setup_message
;	movi	CLSDEAD|123,a0
;	move	a0,@mess_objid
;	movk	22,a0
;	move	a0,@mess_line_spacing
;	movi	create_strs,a4
;	calla	print_string_C2

rept_1
	sleep	4
	jruc	rept_1
	rets

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBR	create_icons

;
; Create information box
;
	movi	SCRB_TX,a2,L
	movi	[128,0],a0		;X coor.
	movi	[10,0],a1		;Y coor.
	movi	7,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	movi	SCRB_P,b0			;pal. to use for city imgs.
	calla	BEGINOBJP2
;
; Now create icons
;
	movi	icon_setup_table,a14,L
	movi	icon_objs,a9,L
	clr	a0			;counter of icons blitted
icons_1
	PUSH	a0,a14
	move	*a14+,a0,L		;X coor.
	move	*a14+,a1,L		;Y coor.
	move	*a14,a2,L		;ptr. to img

	movi	7,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	ICONS,a5		;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	movi	SCRB_P,b0			;pal. to use for city imgs.
	calla	BEGINOBJP2
	move	a8,*a9+,L		;save obj. ptrs to icons

	PULL	a0,a14
	addi	32*3,a14		;point to next line in table
	inc	a0
	cmpi	NUM_ICONS-1,a0
	jrls	icons_1			;br=more icons to blit
	rets

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
icon_cursor_control
	clr	a0
	move	a0,@icon_cursor_pos
	move	a0,@joy_pos
;	move	a0,@button_pos
;
; Read joystick
;
redj_1
	SLEEPK	5

	move	@processing_icon,a0		;are in ICON action routine ?
	jrnz	redj_1				;br=yep...wait

	movk	3,a0
	calla	get_stick_val_cur	;ret. a0=joy switch value

	move	@joy_pos,a14
	cmp	a14,a0
	jreq	jnon_1			;br=no auto repeat...
	move	a0,@joy_pos

	cmpi	JOY_UP,a0		;joystick up ?
	jrne	jnup_1			;br=nope
	move	@icon_cursor_pos,a0
	dec	a0
	jruc	jl_1			;fake 2 LEFT movements

jnup_1	cmpi	JOY_DOWN,a0		;joystick down ?
	jrne	jndn_1			;br=nope
	move	@icon_cursor_pos,a0
	inc	a0
	jruc	jr_1			;fake 2 RIGHT movements

jndn_1	cmpi	JOY_LEFT,a0		;joystick left ?
	jrne	jnl_1
	move	@icon_cursor_pos,a0
jl_1	dec	a0
	jrnn	jl_2
	movk	NUM_ICONS-1,a0			;reset cursor position
jl_2	move	a0,@icon_cursor_pos


jnl_1	cmpi	JOY_RIGHT,a0		;joystick right ?
	jrne	jnon_1
	move	@icon_cursor_pos,a0
jr_1	inc	a0
	cmpi	NUM_ICONS,a0		;number of icons
	jrlo	jr_2
	clr	a0			;reset cursor position
jr_2	move	a0,@icon_cursor_pos
	jruc	jnon_1
;
; Read buttons
;
jnon_1
	movk	3,a0
	calla	get_but_val_cur

	move	@button_pos,a14
	cmp	a14,a0
	jreq	adicon_0			;br=no auto repeat...
	move	a0,@button_pos

	cmpi	TURBO_BUTTON,a0
	jreq	but_1
	cmpi	PASS_BUTTON,a0
	jreq	but_1
	cmpi	SHOOT_BUTTON,a0
	jrne	adicon_0			;br=no joystick or buttons
;
; Maybe call action routine for ICON (based on table)
;
but_1
	move	@icon_cursor_pos,a0,L		;get hi-lited icon nbr.
	sll	5,a0				;mult. by 32 (index into tbl)
	addi	icon_routine_table,a0		;point at routine
	move	*a0,a0,L			;get routine addr.
	call	a0
	jruc	redj_1
;
; re-adjust palettes for icons
;
adicon_0
	clr	a14				;count of icons re-adjusted
	movi	icon_objs,a9,L			;pt. at 1st icon in array
adicon_1
	move	*a9+,a8,L				;ptr. to icon

	movi	SCRB_P,a0,L
	move	@icon_cursor_pos,a2
	cmp	a14,a2				;is this icon to-be hi-lited ?
	jrne	npal_1				;br=no, normal palette
	movi	CREDBAL_P,a0,L
npal_1
	calla	pal_getf
	move	a0,*a8(OPAL)

	inc	a14
	cmpi	NUM_ICONS,a14
	jrls	adicon_1
	jruc	redj_1

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
player_dribbing_ball

	movi	STVDRB01,a2,L
	movi	[327,0],a0		;X coor.
	movi	[170,0],a1		;Y coor.
	movi	9,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	clr	a5
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
	move	a8,@plyr_dribble_obj,L

	clr	a0
	move	a0,@plyr_drib_cnt
pdb_1
	move	@plyr_drib_cnt,a0
	sll	5,a0				;compute offset into table
	addi	player_dribble_table,a0		;add addr. of table start
	move	*a0,a0,L			;get img. pointer
;
; Change frame of player dribbling ball
;
	move	@plyr_dribble_obj,a8,L

;	move	a0,*a8(OIMG),L
;	move	*a0(0),*a8(OSIZE),L
;	move	*a0(ISAG),*a8(OSAG),L
;;;;	move	*a0(IANIOFF),*a8(OXANI),L		;update animation point

	movi	DMAWNZ|M_SCRNREL,a1	;DMA flags
	calla	obj_aniq

	SLEEPK	4

	move	@plyr_drib_cnt,a0
	inc	a0
	cmpi	(player_dribble_table_end-player_dribble_table)/32,a0
	jrlo	pdb_2
	clr	a0
pdb_2	move	a0,@plyr_drib_cnt
	jruc	pdb_1

;-----------------------------------------------------------------------------
; 	This PROCESS handles the timing of the CREATE player section
;-----------------------------------------------------------------------------
timedown_create_player_timer

	movi	BigLED_9,a2,L
	movi	[345,0],a0		;X coor.
	movi	[4,0],a1		;Y coor.
	movi	1600,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	CREATE_PLYR_TIMER,a5	;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
	move	a8,@timer_img_ptr,L

	movi	BigLED_0,a2,L
	movi	[370,0],a0		;X coor.
	movi	[4,0],a1		;Y coor.
	movi	1600,a3			;z pos (sorting)
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	CREATE_PLYR_TIMER,a5	;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
	move	a8,@timer_img_ptr+20h,L

  	movi	90,a14
	move	a14,@timer

cpt_1 	SLEEP	60
	move	@timer,a14
	dec	a14
	move	a14,@timer
;
; Seperate the TIMER into two digits
;
	clr	a0			;1st digit init. value
	move	@timer,a14
	cmpi	10,a14
	jrlt	div_dne			;timer < 10 sec. (0 1st digit)
div_10
	inc	a0			;a0 will become the 1st digit
	subk	10,a14			;a14 will become the 2nd digit
	cmpi	10,a14
	jrhs	div_10			;timer > 10 sec. still
div_dne
	sll	5,a0			;compute offset into table (1st digit)
	sll	5,a14			;compute offset into table (2nd digit)

	movi	timer_table,a1,L
	add	a1,a0			;a0 = table addr. of digit
	add	a1,a14			;a14 = table addr. of digit
	move	*a0,a0,L		;a0 = img. pointer of 1st digit
	move	*a14,a14,L		;a14 = img. pointer of 2nd digit
;
; Change first digit of timer
;
	move	@timer_img_ptr,a8,L
	move	a0,*a8(OIMG),L
	move	*a0(0),*a8(OSIZE),L
	move	*a0(ISAG),*a8(OSAG),L
;
; Change second digit of timer
;
	move	@timer_img_ptr+20h,a8,L
	move	a14,*a8(OIMG),L
	move	*a14(0),*a8(OSIZE),L
	move	*a14(ISAG),*a8(OSAG),L

	move	@timer,a14
	jrnz	cpt_1
	DIE


#*****************************************************************************
* This is the first action player must complete...in CREATE PLAYER
******************************************************************************
 SUBRP	enter_create_plyr_initials

	move	a10,*a13(PC_PLAYNUM)
#resart_cursor
;	movk	1,a0
;	move	*a13(PC_PLAYNUM),a1
;	sll	a1,a0

;	move	*a13(PC_PLAYNUM),a10
;	move	a10,a0
;	sll	5,a0				;x 32 bits
;	addi	#player_data,a0
;	move	*a0,a1,L			;start address of player data

	movi	player1_data,a1,L

	movi	PR_INIT1,a2
	add	a1,a2
	move	a2,*a13(PC_DATADDR),L		;start of player data

	movi	-1,a0				;init player data to -1
	move	a0,*a1(PR_COUNT)
	move	a0,*a1(PR_INIT1)
	move	a0,*a1(PR_INIT2)
	move	a0,*a1(PR_INIT3)

	movi	160,a1
	move	a1,*a13(PC_CENTERX)		;name center X
	move	a1,*a13(PC_CENTERX2)		;stats box center X
	move	a1,*a13(PC_CENTERXkit)		;name center X (kit)

	clr	a0
	move	a0,*a13(PC_FLASHCOUNT)

	movi	TYPTEXT|SUBPL1,a0
	move	a0,*a13(PC_OBJID)		;OBJ ID's created by this PROC
	movk	10h,a1				;mask (bits to remove)
	calla	obj_delc

;	SLEEPK	1
;	move	@force_selection,a0
;	jrnz	#youre_out

;	movk	1,a0
;	move	*a13(PC_PLAYNUM),a1
;	sll	a1,a0
;	move	@exit_status,a1
;	or	a0,a1
;	move	a1,@exit_status		;no exit

	movi	[250,0],a0		;x val
	movi	[80,0],a1		;y val
	movi	SGMD8_A,a2		;* image
	movk	7,a3			;z pos
;;;;	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	DMACAL|M_SCRNREL,a4	;DMA flags
;	movi	DMACAL,a4		;DMA flags
	move	*a13(PC_OBJID),a5
	ori	10h,a5			;object	ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2

	movi	0101h,a0
	move	a0,*a8(OCONST)
	move	a8,*a13(PC_CURSOBJ),L

	move	*a13(PC_OBJID),a5
	ori	10h,a5			;ID
;	calla	create_name_objs

	movi	create_player_menus,a0,L
	move	a0,*a13(PC_MENUBASE),L
	clr	a0			;menu number
	move	a0,*a13(PC_MENULEVEL)
	calla	create_menu
;	calla	create_heading
	calla	update_cursor

	SLEEPK	1
#loop
	movi	22,a10				;initial repeat delay
#repeat_delay
	SLEEPK	1
	move	*a13(PC_PLAYNUM),a1
;	move	@PSTATUS,a0
;	btst	a1,a0
;	jrz	#resart_cursor

;	move	@force_selection,a0
;	jrnz	#resart_cursor
	move	*a13(PC_FLASHCOUNT),a0	;cursor flash count
	inc	a0
	move	a0,*a13(PC_FLASHCOUNT)

	calla	save_selection
;	calla	update_statbox_images

	move	*a13(PC_PLAYNUM),a0
	calla	get_but_val_down
	jrz	#no_action

	JSRP	button_actions
	move	*a13(PC_MENULEVEL),a0
	cmpi	2,a0				;nbr. of menu levels
	jreq	#done
#no_action
	move	*a13(PC_PLAYNUM),a0
	calla	get_stick_val_down
	jrnz	#movit
	calla	update_cursor
	dsj	a10,#repeat_delay
	move	*a13(PC_PLAYNUM),a0
	calla	get_stick_val_cur
	calla	move_cursor
	calla	update_cursor
	movi	15,a10				;repeat delay
	jruc	#repeat_delay
#movit
	calla	move_cursor
	calla	update_cursor
	jruc	#loop
#done
	move	*a13(PC_CURSOBJ),a0,L	;delete cursor
	calla	DELOBJ
;	SLEEPK	1
;
;	move	*a13(PC_PLAYNUM),a0
;	sll	5,a0			;x 32 bits
;	addi	#player_data,a0
;	move	*a0,a0,L		;start address of player data

	movi	player1_data,a0,L
	move	a0,*a13(PC_DATADDR),L	;start of player data
	calla	get_player_record

;	move	*a13(PC_DATADDR),a0,L	;start of player data
;	move	*a0(PR_RANK),a0
;	cmpi	10,a0
;	jrgt	#not_topten
;
;	move	*a13(PC_PLAYNUM),a10
;	move	a10,a0
;	sll	5,a0			;x 32 bits
;	addi	topten_imgs,a0
;
;	move	@TWOPLAYERS,a1			;0 = NO, 1 = YES 2 players
;	jrz	#not_2pxz
;	addi	4*32,a0
;#not_2pxz
;	move	*a0,a9,L
;	CREATE0	topten_player
;
;#not_topten
;

;	move	*a13(PC_DATADDR),a3,L	;start of player data
;	move	*a13(PC_PLAYNUM),a10
;	calla	check_special_initials		;look for designer heads...etc

;	calla	print_player_stats

;	movk	30,a10
;#dly1
;	SLEEPK	1
;	move	*a13(PC_PLAYNUM),a1
;	move	@PSTATUS,a0
;	btst	a1,a0
;	jrz	#resart_cursor
;	move	@force_selection,a0
;	jrnz	#youre_out
;	dsj	a10,#dly1
;
;	movi	7*60,a10
;#wait	SLEEPK	1
;	move	*a13(PC_PLAYNUM),a1
;	move	@PSTATUS,a0
;	btst	a1,a0
;	jrz	#resart_cursor
;	move	@force_selection,a0
;	jrnz	#youre_out
;	move	*a13(PC_PLAYNUM),a0
;	calla	get_but_val_cur
;	jrnz	#exit1
;	dec	a10
;	jrnz	#wait
;	jruc	#ex2
;
;#exit1
;;Do a snd when whacking through
;;	SOUND1	bounce_snd
;#ex2
	move	*a13(PC_OBJID),a0	;OBJ ID's created by this PROC
	calla	obj_del1c		;delete all objs with this ID
;	move	*a13(PC_DATADDR),a1,L	;start of player data
;	move	*a1(PR_NUMDEF),a0	;number teams defeated
;	jrz	#no_wins
;	cmpi	NUM_TEAMS,a0
;	jreq	#defeated_all
;;	calla	print_teams_defeated
;
;	movk	30,a10
;#dly2
;	SLEEPK	1
;	move	*a13(PC_PLAYNUM),a1
;;	move	@PSTATUS,a0
;;	btst	a1,a0
;;	jrz	#resart_cursor
;	move	@force_selection,a0
;	jrnz	#youre_out
;	dsj	a10,#dly2
;
;	movi	7*60,a10
;#wait2	SLEEPK	1
;	move	*a13(PC_PLAYNUM),a1
;;	move	@PSTATUS,a0
;;	btst	a1,a0
;;	jrz	#resart_cursor
;	move	@force_selection,a0
;	jrnz	#youre_out
;	move	*a13(PC_PLAYNUM),a0
;	calla	get_but_val_cur
;	jrnz	#exit2a
;	dec	a10
;	jrnz	#wait2
;	jruc	#exit2
;#exit2a
;
;;	SOUND1	bounce_snd
;
;#exit2
;	move	*a13(PC_OBJID),a0	;OBJ ID's created by this PROC
;	calla	obj_del1c		;delete all objs with this ID
;
;#defeated_all
;#no_wins
;	movk	10,a10
;#dly3
;	SLEEPK	1
;	move	*a13(PC_PLAYNUM),a1
;;	move	@PSTATUS,a0
;;	btst	a1,a0
;;	jrz	#resart_cursor
;	move	@force_selection,a0
;	jrnz	#youre_out
;	dsj	a10,#dly3
;#youre_out
;	move	*a13(PC_OBJID),a0	;OBJ ID's created by this PROC
;	calla	obj_del1c		;delete all objs with this ID
;
;;	movk	1,a0
;	move	*a13(PC_PLAYNUM),a1
;	sll	a1,a0
;	move	@exit_status,a1
;	andn	a0,a1
;	move	a1,@exit_status		;exit

	clr	a0
	move	a0,@processing_icon		;not in ICON action routine
	DIE

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	change_initials_and_pin_number
	rets

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	pick_player_head

	movk	1,a0
	move	a0,@processing_icon		;in ICON action routine
	calla	create_icon_instructions
	calla	create_dribbling_player_head
	calla	create_pick_plyr_heads		;create 5 visable heads
	calla	create_pick_plyr_heads_palettes	;create 5 visable palette objs
	CREATE0	pick_plyr_head_cursor_control
	rets



	.bss	plyr_head_objs,32*5		;5 visable heads
	.bss	plyr_head_pal_objs,32*5		;5 visable flestone objs.
	.bss	plyr_dribble_head_obj,32
	.bss	plyr_dribble_head_pal,32

plyr_head_table
	.long	Hrdaway5
	.long	HarpMav5
;last two first for wrap around
	.long	ewing5
	.long	stock5
	.long	shiek5
	.long	rharp5
	.long	kmalone5
	.long	Person5
	.long	Augmon5
	.long	Benja5
	.long	Barkley5
	.long	Cole5
	.long	Drex5
	.long	Ellis5
	.long	Elliot5
	.long	Hrdaway5
	.long	HarpMav5
;repeat first two for wrap around
	.long	ewing5
	.long	stock5


plyr_fleshtone_table
	.long	pal9
	.long	pal10
;last two first for wrap around
	.long	pal1
	.long	pal2
	.long	pal3
	.long	pal4
	.long	pal5
	.long	pal6
	.long	pal7
	.long	pal8
	.long	pal9
	.long	pal10
;repeat first two for wrap around
	.long	pal1
	.long	pal2


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBR	create_dribbling_player_head

	movi	[150,0],a0			;x val
	movi	[100,0],a1			;y val
	move	ewing5,a2,L			;* head image
	movk	15,a3				;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	clr	a5				;object class
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2
	move	a8,@plyr_dribble_head_obj,L
	rets

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBR create_pick_plyr_heads

	movi	plyr_head_objs,a9,L
	movi	plyr_head_table,a10,L		;addr. of begining of table
	movk	5,a3				;nbr. of heads to create
	movi	[165,0],a0			;x val of first head
cpph_1
	PUSH	a0,a3

	movi	[75,0],a1			;y val
	move	*a10+,a2,L			;* head image
	movk	15,a3				;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	ICON_BOX_STUFF,a5		;object class
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2
	move	a8,*a9+,L

	PULL	a0,a3
	addxyi	000A0000h,a0			;add to X position (spacing)
	dec	a3				;more heads ?
	jrne	cpph_1				;br=yes
	rets

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBR create_pick_plyr_heads_palettes
	movi	plyr_head_pal_objs,a9,L
	movi	plyr_fleshtone_table,a10,L		;addr. of begining of table
	movk	5,a3				;nbr. of heads to create
	movi	[165,0],a0			;x val of first head
cpphp_1
	PUSH	a0,a3

	movi	[130,0],a1			;y val
	movi	,a2,L			;* head image
	movk	15,a3				;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	ICON_BOX_STUFF,a5		;object class
	clr	a6				;x vel
	clr	a7				;y vel
	move	*a10+,b0,L			;get palette from table
	calla	BEGINOBJP2
	move	a8,*a9+,L

	PULL	a0,a3
	addxyi	000A0000h,a0			;add to X position (spacing)
	dec	a3				;more fleshtone objs. ?
	jrne	cpphp_1				;br=yes
	rets

;-----------------------------------------------------------------------------
; This PROCESS controls the cursor and picking head and flesh tone for body
;-----------------------------------------------------------------------------
pick_plyr_head_cursor_control
	clr	a0
	move	a0,@head_cur_pos
	move	a0,@joy_pos
;
; Read joystick
;
pph_1
	SLEEPK	5

	movk	3,a0
	calla	get_stick_val_cur	;ret. a0=joy switch value

	move	@joy_pos,a14
	cmp	a14,a0
	jreq	pph_5			;br=no auto repeat...
	move	a0,@joy_pos
;
; Up ?
;
	cmpi	JOY_UP,a0		;joystick up ?
	jrne	pph_2			;br=nope
	move	@head_cur_pos,a0
	dec	a0
	jrnn	pph_2a
	movk	2,a0			;reset cursor position (save & exit)
pph_2a	move	a0,@head_cur_pos
	jruc	pph_5
;
; Down ?
;
pph_2	cmpi	JOY_DOWN,a0		;joystick down ?
	jrne	pph_3			;br=nope
	move	@head_cur_pos,a0
	inc	a0
	cmpi	2,a0			;nbr of fields
	jrlo	pph_3a
	clr	a0			;reset cursor position
pph_3a	move	a0,@head_cur_pos
	jruc	pph_5
;
; Left ?
; 
pph_3	cmpi	JOY_LEFT,a0		;joystick left ?
	jrne	pph_4
	move	@head_cur_pos,a0	;determine which field cursor is on
	jrnz	pph_3a			;br=not player head field
	
	jruc	pph_5


pph_3a	cmpi	1,a0			;fleshtone field ?
	jrne	pph_5			;br=no...save & exit field (do nothin)

	jruc	pph_5
;
; Right ?
;
pph_4	cmpi	JOY_RIGHT,a0		;joystick right ?
	jrne	ppg_5

	move	@head_cur_pos,a0	;use as index into table
	sll	6,a0			;mult. by 64 (2 longs)
	move	@head_cur_pos,a1
	sll	5,a1			;mult. by 32 (1 long)
	add	a1,a0			;offset by 3 longs
	addi	attribute_cursor_table,a0,L

;
; Read buttons (for exit)
;
pph_5
	movk	3,a0
	calla	get_but_val_cur

	move	@button_pos,a14
	cmp	a14,a0
	jreq	pph_1			;br=no auto repeat...
	move	a0,@button_pos

	cmpi	TURBO_BUTTON,a0
	jreq	pph_6
	cmpi	PASS_BUTTON,a0
	jreq	pph_6
	cmpi	SHOOT_BUTTON,a0
	jrne	pph_1			;br=no joystick or buttons
;
; Exit this icon action (return to icon control)
;
pph_6	clr	a0
	move	a0,@processing_icon		;in ICON action routine

	movi	ICON_BOX_STUFF,a0			;object ID
	clr	a1				;mask
	calla	obj_delc
	DIE

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	adjust_player_attributes

 	PUSH 	a11
	movk	1,a0
	move	a0,@processing_icon		;in ICON action routine

	calla	create_icon_instructions
;
; plot attribute name and bars from table
;
	movi	(attribute_setup_end-attribute_setup_table)/(32*6),a14	;get count
 	movi	attribute_setup_table,a9,L
	movi	attribute_bar_objs,a10,L	;array for BAR objects
	movi	attribute_name_objs,a11,L	;array for attrib. names objs.
nxatt_1
	PUSH	a14
;plot name of bar
	move	*a9+,a0,L		;x val.
	move	*a9+,a1,L		;y val.
	move	*a9+,a2,L		;* image
	movk	15,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	ICON_BOX_STUFF,a5	;object class
	clr	a6			;x vel
	clr	a7			;y vel
	movi	CHARAC02P,b0			;pal. to use for city imgs.
	calla	BEGINOBJP2
	move	a8,*a11+,L

;now plot bar
	move	*a9+,a0,L		;x val.
	move	*a9+,a1,L		;y val.
	move	*a9+,a2,L		;* image
	movk	15,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	ICON_BOX_STUFF,a5	;object class
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
	move	a8,*a10+,L		;save obj. pointers
	PULL	a14
	dec	a14
	jrne	nxatt_1			;br=more to plot

	CREATE0	attribute_cursor_control
	PULL	a11
	rets

;-----------------------------------------------------------------------------
;	 Change/Update palettes on attribute NAME images
;-----------------------------------------------------------------------------
 SUBR	update_attribute_name_pals

	movi	attribute_name_objs,a2,L	;pt. to begining of array
	clr	a4
uanp_1
	move	*a2+,a3,L			;get img. ptr.
	movi	CHARAC02P,a0,L			;default pallete
	move	@attrib_cur_pos,a1
	cmp	a1,a4				;hi-lite this image ?
	jrne	uanp_2				;br=nope...
	movi	CITIESY_P,a0,L			;new pallette for hilited name
uanp_2
	calla	pal_getf
	move	a0,*a3(OPAL)

	inc	a4
 	cmpi	NUM_ATTRIBS-1,a4		;more elements to update ?
	jrls	uanp_1				;br=yes
	rets


;-----------------------------------------------------------------------------
; This PROCESS controls the cursor and increasing/decreasing of attributes
;-----------------------------------------------------------------------------
attribute_cursor_control
	clr	a0
	move	a0,@attrib_cur_pos
	move	a0,@joy_pos
	calla	update_attribute_name_pals
;
; Read joystick
;
acc_1
	SLEEPK	5

	movk	3,a0
	calla	get_stick_val_cur	;ret. a0=joy switch value

	move	@joy_pos,a14
	cmp	a14,a0
	jreq	acc_5			;br=no auto repeat...
	move	a0,@joy_pos
;
; Up ?
;
	cmpi	JOY_UP,a0		;joystick up ?
	jrne	acc_2			;br=nope
	move	@attrib_cur_pos,a0
	dec	a0
	jrnn	acc_2a
	movi	NUM_ATTRIBS-1,a0			;reset cursor position
acc_2a	move	a0,@attrib_cur_pos
	calla	update_attribute_name_pals
	jruc	acc_5
;
; Down ?
;
acc_2	cmpi	JOY_DOWN,a0		;joystick down ?
	jrne	acc_3			;br=nope
	move	@attrib_cur_pos,a0
	inc	a0
	cmpi	NUM_ATTRIBS,a0		;number of attributes to adjust
	jrlo	acc_3a
	clr	a0			;reset cursor position
acc_3a	move	a0,@attrib_cur_pos
	calla	update_attribute_name_pals
	jruc	acc_5
;
; Left ?
; 
acc_3	cmpi	JOY_LEFT,a0		;joystick left ?
	jrne	acc_4

	move	@attrib_cur_pos,a0	;use as index into table
	sll	6,a0			;mult. by 64 (2 longs)
	move	@attrib_cur_pos,a1
	sll	5,a1			;mult. by 32 (1 long)
	add	a1,a0			;offset by 3 longs
	addi	attribute_cursor_table,a0,L

	move	*a0(40h),a1,L		;a1=addr. of VALUE to upate
	move	*a1,a2,W		;get value
	addi	2,a2
	move	a2,*a1,W

;adjust total attribute points	
	move	@total_points,a0
	subi	2,a0
	move	a0,@total_points
	jruc	acc_5
;
; Right ?
;
acc_4	cmpi	JOY_RIGHT,a0		;joystick right ?
	jrne	acc_5

	move	@attrib_cur_pos,a0	;use as index into table
	sll	6,a0			;mult. by 64 (2 longs)
	move	@attrib_cur_pos,a1
	sll	5,a1			;mult. by 32 (1 long)
	add	a1,a0			;offset by 3 longs
	addi	attribute_cursor_table,a0,L

	move	*a0(40h),a1,L		;a1=addr. of VALUE to upate
	move	*a1,a2,W		;get value
	subi	2,a2
	move	a2,*a1,W

;adjust total attribute points	
	move	@total_points,a0
	addi	2,a0
	move	a0,@total_points

;
; Read buttons (for exit)
;
acc_5
	movk	3,a0
	calla	get_but_val_cur

	move	@button_pos,a14
	cmp	a14,a0
	jreq	acc_1			;br=no auto repeat...
	move	a0,@button_pos

	cmpi	TURBO_BUTTON,a0
	jreq	acc_6
	cmpi	PASS_BUTTON,a0
	jreq	acc_6
	cmpi	SHOOT_BUTTON,a0
	jrne	acc_1			;br=no joystick or buttons
;
; Exit this icon action (return to icon control)
;
acc_6	clr	a0
	move	a0,@processing_icon		;in ICON action routine

	movi	ICON_BOX_STUFF,a0			;object ID
	clr	a1				;mask
	calla	obj_delc
	DIE


;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	pick_uniform_color
	rets

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	choose_players_nickname
	rets

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	pick_personal_sound_call
	rets

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	try_player_in_game
	rets

;-----------------------------------------------------------------------------
; action routine for ICON
;-----------------------------------------------------------------------------
 SUBR	save_and_exit
	rets


;-----------------------------------------------------------------------------
; This routine plots all the instructions for the hi-lited ICON
;-----------------------------------------------------------------------------
 SUBR	create_icon_instructions
 	
	move	@icon_cursor_pos,a9
	move	a9,a0
	sll	7,a9				;mult. by 128
	sll	6,a0				;mult by 64
	add	a0,a9				; 196 (size of table line)
	addi	icon_instructions_table,a9,L	;index to instructions
;
; First instruction
;
	move	*a9+,a0,L		;x val.
	move	*a9+,a1,L		;y val.
	move	*a9+,a2,L		;* image
	movk	15,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	ICON_BOX_STUFF,a5	;object class
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
;
; Second instruction (if nesscary)
;
	move	*a9+,a0,L		;x val.
	move	*a9+,a1,L		;y val.
	move	*a9,a2,L		;* image
	jrn	cintr_1			;br=-1 means no plot
	movk	15,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4	;DMA flags
	movi	ICON_BOX_STUFF,a5	;object class
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2
cintr_1
 	rets



;-----------  TABLES ------------
;-----------  TABLES ------------
;-----------  TABLES ------------
;-----------  TABLES ------------

;
; This table contains:
;
; 1) X,Y for 1st instruction img 
; 2) X,Y for 2nd instruction img (-1 for img. ptr. if none)
;
icon_instructions_table
	.long	130<<16,20<<16,instr01, 130<<16,33<<16,instr04
	.long	130<<16,20<<16,instr12, 130<<16,33<<16,instr13
	.long	130<<16,20<<16,instr05, 130<<16,33<<16,-1
	.long	130<<16,20<<16,instr06, 130<<16,33<<16,instr07
	.long	130<<16,20<<16,instr08, 130<<16,33<<16,-1
	.long	130<<16,20<<16,instr09, 130<<16,33<<16,-1
	.long	130<<16,20<<16,instr10, 130<<16,33<<16,-1
	.long	130<<16,20<<16,instr11, 130<<16,33<<16,-1


;
; This table contains:
;
; 1) X,Y position of cursor
; 2) Value to update (when read a joystick LEFT or RIGHT)
;
attribute_cursor_table
	.long	167<<16,30<<16,height_points
	.long	167<<16,40<<16,weight_points
	.long	167<<16,50<<16,speed_points
	.long	167<<16,60<<16,power_points
	.long	167<<16,70<<16,shoot_points
	.long	167<<16,80<<16,dunks_points
	.long	167<<16,90<<16,steal_points
	.long	167<<16,100<<16,block_points
attribute_cursor_table_end


;
; This table contains the following info:
;
;   1) X pos.
;   2) Y pos.
;   3) ptr. to Attribute name img
;   4) X pos.
;   5) Y pos.
;   6) ptr. to Attribute bar img
;
attribute_setup_table
	.long	145<<16,53<<16,height, 146<<16,64<<16,bar01
	.long	145<<16,78<<16,weight, 146<<16,89<<16,bar01
	.long	145<<16,103<<16,speed, 146<<16,114<<16,bar01
	.long	145<<16,128<<16,power, 146<<16,139<<16,bar01
	.long	145<<16,153<<16,shoot, 146<<16,164<<16,bar01
	.long	145<<16,178<<16,dunks, 146<<16,189<<16,bar01
	.long	145<<16,203<<16,steal, 146<<16,214<<16,bar01
	.long	145<<16,228<<16,block, 146<<16,239<<16,bar01
attribute_setup_end



; 
; Routines to dispatch when ICON is selected
;
icon_routine_table
	.long	change_initials_and_pin_number
	.long	pick_player_head
	.long	adjust_player_attributes
	.long	pick_uniform_color
	.long	choose_players_nickname
	.long	pick_personal_sound_call
	.long	try_player_in_game
	.long	save_and_exit


;
; For player dribbing ball
;
player_dribble_table
	.long	STVDRB01
	.long	STVDRB02
	.long	STVDRB03
	.long	STVDRB04
	.long	STVDRB05
	.long	STVDRB06
	.long	STVDRB07
player_dribble_table_end


;for entering initials during CREATE PLAYER
create_player_menus
	.long	cpm1
	.long	cpm2
cpm1
	.word	0			;palette
	.word	142,15			;x,y start
	.long	name_table		;table
cpm2
	.word	0			;palette
	.word	142,54			;x,y start
	.long	pin_nbr_table


timer_table
	.long	BigLED_0
	.long	BigLED_1
	.long	BigLED_2
	.long	BigLED_3
	.long	BigLED_4
	.long	BigLED_5
	.long	BigLED_6
	.long	BigLED_7
	.long	BigLED_8
	.long	BigLED_9


;
; This table contains the following info:
;
;   1. X position
;   2. Y position
;   3. pointer to icon img
;
icon_setup_table
	.long	8<<16,13<<16,SCRB_IN
	.long	62<<16,13<<16,SCRB_HD
	.long	8<<16,73<<16,SCRB_AT
	.long	62<<16,73<<16,SCRB_JR
	.long	8<<16,132<<16,SCRB_NM
	.long	62<<16,132<<16,SCRB_SC
	.long	8<<16,193<<16,SCRB_ME
	.long	62<<16,193<<16,SCRB_EX
icon_setup_table_end


create_strs_setup
	RJR_STR	sgmd8_ascii,10,0,199,5,PURPLE,0
	
create_strs
	.string	"create player",0
	.even


create_player_mod
	.long	WOODFLBMOD		;team selection map
	.word	0,512
	.long	0






******************************************************************************

	.end
