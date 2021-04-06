****************************************************************
*
* Owner:	JOHNSON
*
* Software:	Jeff Johnson/Jamie Rivett
* Initiated:	?
*
* Modified:	?
*
* COPYRIGHT (C) 1992 WILLIAMS ELECTRONICS GAMES, INC.
*
*.Last mod - 1/15/93 15:29
****************************************************************
	.file	"select2.asm"
	.title	"name & team selection"
	.width	132
	.option	b,d,l,t
	.mnolist

	.include	"mproc.equ"
	.include	"disp.equ"
	.include	"sys.equ"
	.include	"gsp.equ"
	.include	"game.equ"
	.include	"audit.equ"
	.include	"macros.hdr"
	.include	"world.equ"

	.include	"logos.tbl"
	.include	"names2.tbl"		;New names from pnames2.img
	.include	"names2.glo"		;New names from pnames2.img

	.include	"mugshot.glo"
	.include	"imgtbl.glo"
	.include	"imgtblp.glo"
	.include	"imgtbl2.glo"
	.include	"imgtbl7.glo"
	.include	"bgndtbl.glo"
	.include	"imgtblm.glo"
	.include	"bgndtbl7.glo"
	.include	"plyrnub.tbl"

	.include	"bbvda.tbl"


	.def	CUST6,CUST7,CUST8,CUST9,CUST10

	.def	T_HAWKS,GAINED_TXT

	.def	attrib_off
	.def	attrib_on
	.def	update_attribs
	.def	team_sqaud_cnts
	.def	city_names_str_tbl
;DJT plyr_names_img_tbl removed to ATTRACT


************************************************************************

	.ref	kp_qscrs2,PCNT
	.ref	HALT

	.ref	OUR_MUG,TOB_MUG,JAS_MUG,QUI_MUG,BOO_MUG,MARTY_MUG,CARL_MUG
;DJT Start
	.ref	HEI_MUG,MAT_MUG
;DJT End

	.def	logos
	.def	BALLBAK1
	.def	city_table_start
	.def	city_table_end
	.def	our_names			;table addr.
	.def	our_heads			;table addrs.
	.def	player_attribs			;table addr.
	.def	name_sort
	.def	init_x,kit_x
	.def	nub_img_tbl

	.ref	kp_ram
	.ref	snd_play1
	.ref	tm2set,tm1set

	.ref	credit1_obj
	.ref	credit2_obj
	.ref	credit3_obj
	.ref	name1_obj
	.ref	name2_obj
	.ref	name3_obj
	.ref	name4_obj

	.ref	attrib1_obj
	.ref	attrib2_obj
	.ref	attrib3_obj
	.ref	attrib4_obj
	.ref	CRED_P
	.ref	teamset1_obj
	.ref	teamset2_obj
 	.ref	create_credits
	.ref	TWOPLAYERS			;0 = NO, 1 = YES 2 players
	.ref	concat_string
	.ref	copy_rom_string,concat_rom_string
	.ref	message_ascii,mess_space_width,mess_spacing
	.ref	mess_cursy,mess_objid
	.ref	mess_line_spacing
	.ref	CYCLE_TABLE,COLTAB2
	.ref	pal_getf
;	.ref	get_initials_string
	.ref	dropout_stats
	.ref	conttimers
	.ref	PSTATUS2
	.ref	GET_ADJ
	.ref	game_purchased
	.ref	GAMSTATE
	.ref	monitor_fullgame
	.ref	message_buffer
	.ref	pleasewt
	.ref	game_over
	.ref	credits
	.ref	KILBGND,KILALL
	.ref	print_string_C2
	.ref	cntrs_delay
	.ref	can_enter_inits
	.ref	winningteam
	.ref	newptr,newplyrs
	.ref	CR_CONTP
	.ref	team_control
	.ref	plyrsdropped
	.ref	P1DATA
	.ref	pal_clean
	.ref	qtr_purchased
	.ref	credit_messages
	.ref	monitor_buyins
	.ref	COLRTEMP
	.ref	gmqrtr
	.ref	_4plyrsingame,_2plyr_competitive

	.ref	do_scrn_transition
	.ref	un_wipe_horizontal,wipe_horizontal
	.ref	wipe_stack_vertical
	.ref	NO_CREATE_DEL_OBJS,CREATE_NO_DEL_OBJS

	.ref	fade_up,fade_down
	.ref	calc_num_defeated
	.ref	RNDRNG0,BAKMODS
	.ref	team2,team1
	.ref	switches_cur
	.ref	inmatchup
	.ref	player1_data
	.ref	dec_to_asc
	.ref	cntdown_snd
	.ref	pal_set
	.ref	player2_data
	.ref	create_logos
	.ref	call_matchup
	.ref	pal_find
	.ref	special_heads
	.ref	player3_data
	.ref	create_player_heads
	.ref	update_player_heads
	.ref	create_names
	.ref	dpageflip
	.ref	IRQSKYE
	.ref	PSTATUS
	.ref	player4_data
	.ref	switches_down
	.ref	print_string_C
	.ref	BGND_UD1
	.ref	obj_on
	.ref	force_selection
	.ref	obj_off
	.ref	scores
	.ref	WIPEOUT
	.ref	mess_cursx
	.ref	update_logos
	.ref	setup_message
	.ref	copy_string
;DJT Start
	.if	ANIM_VS
	.ref	animate_vs_logo
	.endif	;ANIM_VS
;DJT End
	.ref	get_name_string
	.ref	bast8_ascii
	.ref	plyr_get_combination
	.ref	set_plyrs_powerup_ram
	.ref	bast18_ascii,brush20_ascii
	.ref	bast10_ascii
	.ref	bounce_snd,tunegc_snd
	.ref	SOUNDSUP
	.ref	OVRTME,OVERW_P
	.ref	hide_ball_under_logo
	.ref	bast8t_ascii
	.ref	get_teams_pop,teams_pop
	.ref	kp_p1_crtplr,kp_p2_crtplr,kp_p3_crtplr,kp_p4_crtplr
	.ref	kp_p1_name1,kp_p1_name2,kp_p1_name3,kp_p1_name4
	.ref	kp_p1_name5,kp_p1_name6,kp_p1_hdnbr
	.ref	kp_p2_name1,kp_p2_name2,kp_p2_name3,kp_p2_name4
	.ref	kp_p2_name5,kp_p2_name6,kp_p2_hdnbr
	.ref	kp_p3_name1,kp_p3_name2,kp_p3_name3,kp_p3_name4
	.ref	kp_p3_name5,kp_p3_name6,kp_p3_hdnbr
	.ref	kp_p4_name1,kp_p4_name2,kp_p4_name3,kp_p4_name4
	.ref	kp_p4_name5,kp_p4_name6,kp_p4_hdnbr
	.ref	kp_team1,kp_scores,kp_team2
	.ref	mess_cursx2,kern_chars
	.ref	print_string2b,hangfnt38_ascii
	.ref	brush50_ascii,mess_justify
	.ref	message_palette
;DJT Start

	.ref	t1ispro
	.ref	t2ispro

;DJT Not .refs
;DJT End
************************************************************************


	.text




PNAME_W_P:
	.word	  4
	.word	02C0BH,07FFFH,05294H,00H

GAINED_P:
	.word	  4
	.word	00H,00H,07FFFH,07FE0H

IDIOTS_P:
	.word	  6
	.word	0318CH,00H,07FFFH,07FE0H,02B1FH,07C00H


********************************
#*

MAX_CRTIME	equ	>7fff		;30*60
;TEAMSEL_PAGE	equ	0*256
;NAMENT_PAGE	equ	1*256

	.asg	>5e+5,x1
	.asg	>a1+5,x1a
	.asg	>e4+5,x2a
	.asg	>ad+5,x1b
	.asg	>12f5+2,y1
	.asg	>131f,y1a


	.def	ladder_imgs0
	.def	ladder_imgs1,ladder_imgs2,ladder_imgs3,ladder_imgs4
	.def	ladder_imgs5,ladder_imgs6


ladder_imgs0
ladder_imgs1
ladder_imgs2
ladder_imgs3
ladder_imgs4
ladder_imgs5
ladder_imgs6
;2
;
;
;	.long	HPR_DAL,x1+400,y1
;	.long	JAC_DAL,x1,y1
;	.long	MAS_DAL,x2a,y1
;	.long	T_MAVS,x1b,y1a
;
;	.long	THM_DET,x1,y1->b3
;	.long	DUM_DET,x1a,y1->b3
;
;	.long	ELL_DET,x2a,y1->b3
;;	.long	HOR_HOU,x2a,y1->b3
;	.long	T_PISS,x1b,y1a->b3
;
;	.long	0
;
;ladder_imgs1
;;4
;	.long	BAK_MLW,x1,y1->b3*2-2
;	.long	EDW_MLW,x1a,y1->b3*2-2
;	.long	DAY_MLW,x2a,y1->b3*2-2
;	.long	T_BUCKS,x1b,y1a->b3*2-2
;
;	.long	GUG_WAS,x1,y1->b3*3-2
;	.long	ELL_WAS,x1a,y1->b3*3-2
;	.long	CHE_WAS,x2a,y1->b3*3-2
;	.long	T_BULTS,x1b,y1a->b3*3-2
;
;	.long	SIM_SAC,x1,y1->b3*4-4
;	.long	HUR_SAC,x1a,y1->b3*4-4
;	.long	RIC_SAC,x2a,y1->b3*4-4
;	.long	T_KINGS,x1b,y1a->b3*4-4
;
;	.long	LTN_MIN,x1,y1->b3*5-4
;	.long	PRS_MIN,x1a,y1->b3*5-4
;	.long	RID_MIN,x2a,y1->b3*5-4
;	.long	T_TWOLV,x1b,y1a->b3*5-4
;
;	.long	0
;
;ladder_imgs2
;;4
;	.long	PEE_LAK,x1,y1->b3*6-6
;	.long	DIV_LAK,x1a,y1->b3*6-6
;	.long	CAM_LAK,x2a,y1->b3*6-6
;	.long	T_LAKS,x1b,y1a->b3*6-6
;
;	.long	WLK_ATL,x1,y1->b3*7-6
;;	.long	MAN_CLP,x1,y1->b3*7-6
;	.long	HRP_CLP,x1a,y1->b3*7-6
;	.long	ROB_CLP,x2a,y1->b3*7-6
;	.long	T_CLIPS,x1b,y1a->b3*7-6
;
;	.long	MCD_BOS,x1,y1->b3*8-8
;	.long	BRO_BOS,x1a,y1->b3*8-8
;	.long	GAM_BOS,x2a,y1->b3*8-8
;	.long	T_CELTS,x1b,y1a->b3*8-8
;
;	.long	WEA_PHL,x1,y1->b3*9-8
;;	.long	BRA_PHL,x1a,y1->b3*9-8
;	.long	BRA_PHL,x2a,y1->b3*9-8
;	.long	HRN_PHL,x2a+400,y1->b3*9-8
;	.long	T_76RS,x1b,y1a->b3*9-8
;
;	.long	0
;
;ladder_imgs3
;;4
;	.long	MIL_IND,x1,y1->b3*10-10
;	.long	SMI_IND,x1a,y1->b3*10-10
;	.long	SEL_IND,x2a,y1->b3*10-10
;	.long	T_PACER,x1b,y1a->b3*10-10
;
;	.long	COL_NEJ,x1,y1->b3*11-10
;	.long	AND_NEJ,x1a,y1->b3*11-10
;	.long	MOR_NEJ,x2a,y1->b3*11-10
;	.long	T_NETS,x1b,y1a->b3*11-10
;
;	.long	PRC_CLE,x1,y1->b3*12-12
;	.long	DAU_CLE,x1a,y1->b3*12-12
;	.long	NAN_CLE,x2a,y1->b3*12-12
;	.long	T_CAVS,x1b,y1a->b3*12-12
;
;	.long	MUT_DEN,x1,y1->b3*13-12
;	.long	ELL_DEN,x1a,y1->b3*13-12
;	.long	ROG_DEN,x2a,y1->b3*13-12
;	.long	T_NUGS,x1b,y1a->b3*13-12
;
;	.long	0
;
;ladder_imgs4
;;4
;	.long	HRD_GLD,x1,y1->b3*14-14
;	.long	MUL_GLD,x1a,y1->b3*14-14
;	.long	WEB_GLD,x2a,y1->b3*14-14
;	.long	T_WARS,x1b,y1a->b3*14-14
;
;	.long	DRX_PRT,x1,y1->b3*15-14
;	.long	POR_PRT,x1a,y1->b3*15-14
;	.long	ROB_PRT,x2a,y1->b3*15-14
;	.long	T_BLAZ,x1b,y1a->b3*15-14
;
;	.long	RCE_MIA,x1,y1->b3*16-16
;	.long	SKL_MIA,x1a,y1->b3*16-16
;	.long	MIN_MIA,x2a,y1->b3*16-16
;	.long	T_HEAT,x1b,y1a->b3*16-16
;
;	.long	JON_CHA,x1,y1->b3*17-16
;	.long	HWK_CHA,x1a,y1->b3*17-16
;	.long	MOU_CHA,x2a,y1->b3*17-16
;	.long	T_HORS,x1b,y1a->b3*17-16
;
;	.long	0
;
;ladder_imgs5
;;4
;	.long	SKL_ORL,x1,y1->b3*18-18
;	.long	HAR_ORL,x1a,y1->b3*18-18
;	.long	AND_ORL,x2a,y1->b3*18-18
;	.long	T_MAGIC,x1b,y1a->b3*18-18
;
;	.long	ROB_SAN,x1,y1->b3*19-18
;	.long	ROD_SAN,x1a,y1->b3*19-18
;	.long	ELS_SAN,x2a,y1->b3*19-18
;	.long	T_SPURS,x1b,y1a->b3*19-18
;
;	.long	MLN_UTA,x1,y1->b3*20-20
;	.long	STK_UTA,x1a,y1->b3*20-20
;	.long	BEN_UTA,x2a,y1->b3*20-20
;	.long	T_JAZZ,x1b,y1a->b3*20-20
;
;	.long	EWG_NEY,x1,y1->b3*21-20
;	.long	MAS_NEY,x1a,y1->b3*21-20
;	.long	STA_NEY,x2a,y1->b3*21-20
;	.long	T_KNIKS,x1b,y1a->b3*21-20
;
;	.long	0
;
;ladder_imgs6
;;4
;	.long	MAN_CLP,x1,y1->b3*22-22
;;	.long	WLK_ATL,x1,y1->b3*22-22
;	.long	AUG_ATL,x1a,y1->b3*22-22
;	.long	WLS_ATL,x2a,y1->b3*22-22
;	.long	T_HAWKS,x1b,y1a->b3*22-22
;
;;	.long	BRK_PHX,x1,y1->b3*23-22
;;	.long	MAJ_PHX,x1,y1->b3*23-22
;	.long	MAJ_PHX,x1a,y1->b3*23-22
;	.long	JOH_PHX,x2a,y1->b3*23-22
;	.long	T_SUNS,x1b,y1a->b3*23-22
;
;	.long	OLA_HOU,x1,y1->b3*24-24
;	.long	MAX_HOU,x1a,y1->b3*24-24
;;	.long	ELL_DET,x2a,y1->b3
;;	.long	ELL_DET,x2a,y1->b3*24-24
;	.long	HOR_HOU,x2a,y1->b3*24-24
;	.long	T_ROCKS,x1b,y1a->b3*24-24
;
;	.long	KMP_SEA,x1,y1->b3*25-24
;	.long	PAY_SEA,x1a,y1->b3*25-24
;	.long	GIL_SEA,x2a,y1->b3*25-24
;	.long	T_SONICS,x1b,y1a->b3*25-24
;
;
;	.long	0


#*****************************************************************************
* a8  = sleep time
* a9  = palette to change
* a10 = * palette list
* a11 = * morf pal ram


START_PAL	equ	PDATA
CUR_PAL		equ	PDATA+20h
PAL_ADDR	equ	PDATA+40h
MORF_PAL	equ	PDATA+60h
SLEEP_TIME	equ	PDATA+80h

 SUBR	morf_pal


	move	a8,*a13(SLEEP_TIME)
	move	a10,*a13(START_PAL),L
	move	a10,*a13(CUR_PAL),L
	move	a11,*a13(MORF_PAL),L

#wait
	SLEEPK	1

	move	a9,a0
	calla	pal_find
	jrz	#wait
	srl	8,a0
	sll	8,a0
	move	a0,*a13(PAL_ADDR),L

	move	*a13(MORF_PAL),a1,L
	move	*a10,a2,L
	move	*a2+,a3		;num colours
#loop
	move	*a2+,*a1+
	dsj	a3,#loop

;	SLEEP	4
	move	*a13(SLEEP_TIME),a10
#dly1
	SLEEPK	1
	dsj	a10,#dly1
#next_pal

	move	*a13(CUR_PAL),a10,L
	addi	20h,a10
	move	*a10,a0,L
	jrn	#ok
	jrz	#not_sleep

	move	a10,*a13(CUR_PAL),L
	move	a0,a10
	jruc	#dly1

#not_sleep
	move	*a13(START_PAL),a10,L
#ok
	move	a10,*a13(CUR_PAL),L

#again
;	SLEEP	2
	move	*a13(SLEEP_TIME),a10
	srl	1,a10
	jrnz	#dly2
	movk	1,a10
#dly2
	SLEEPK	1
	dsj	a10,#dly2


	move	*a13(MORF_PAL),a1,L
	move	*a13(CUR_PAL),a10,L
	move	*a10,a2,L
	move	*a2+,a0			;num colours
	clr	a11
#morfit
	move	*a1,a3			;CURRENT PALETTE
	movi	0111110000000000b,a4	;5 bits of red
	and	a3,a4
	movi	0000001111100000b,a5	;5 bits of green
	and	a3,a5
	movi	0000000000011111b,a6	;5 bits of blue
	and	a3,a6

	move	*a2+,a7			;DEST PALETTE
	movi	0111110000000000b,a8	;5 bits of red
	and	a7,a8
	movi	0000001111100000b,a9	;5 bits of green
	and	a7,a9
	movi	0000000000011111b,a10	;5 bits of blue
	and	a7,a10

	srl	10,a4
	srl	10,a8
	cmp	a4,a8			;a8-a4
	jreq	#redok
	jrlt	#decr
	inc	a11
	inc	a4
	jruc	#redok
#decr
	inc	a11
	dec	a4
#redok
	sll	10,a4

	srl	5,a5
	srl	5,a9
	cmp	a5,a9
	jreq	#greenok
	jrlt	#decg
	inc	a11
	inc	a5
	jruc	#greenok
#decg
	inc	a11
	dec	a5
#greenok
	sll	5,a5

	cmp	a6,a10
	jreq	#blueok
	jrlt	#decb
	inc	a11
	inc	a6
	jruc	#blueok
#decb
	inc	a11
	dec	a6
#blueok

	or	a5,a4
	or	a6,a4
	move	a4,*a1+

	dsj	a0,#morfit

	move	*a13(CUR_PAL),a0,L	;* palette list
	move	*a0,a0,L		;* palette
	move	*a0,a2			;num colours
	move	*a13(MORF_PAL),a0,L	;* palette
	move	*a13(PAL_ADDR),a1,L	;dest palette
	calla	pal_set

	move	a11,a11
	jrnz	#again

	jruc	#next_pal

	DIE


;	movi	GREENPAL,a0	;* palette
;	move	*a0+,a2		;num colours
;	move	a10,a1		;dest palette
;	calla	pal_set

#*****************************************************************************
*
* RETURN:	a0 = start button bits
*-----------------------------------------------------------------------------

 SUBR	get_all_starts_down

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_start_down
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_start_down
	or	a0,a1
#no_player2

	btst	2,a2
	jrz	#no_player3
	movk	2,a0			;player 3
	calla	get_start_down
	or	a0,a1
#no_player3

	btst	3,a2
	jrz	#no_player4
	movk	3,a0			;player 4
	calla	get_start_down
	or	a0,a1
#no_player4

	move	a1,a0
	rets

#*****************************************************************************
*
* RETURN:	a0 = start bit
*-----------------------------------------------------------------------------

 SUBR	get_start_down

	sll	4,a0			;x 16 bits
	addi	start_offs,a0
	move	*a0,a0
	addi	switches_down,a0
	move	*a0,a0
	andi	1,a0
	rets


	.if	TUNIT
start_offs	.word	12h,15h,19h,1ah
	.else
start_offs	.word	12h,15h,17h,27h
	.endif

#*****************************************************************************
* RETURN:	a0 = start bit
*-----------------------------------------------------------------------------
 SUBR	get_start_cur

	sll	4,a0			;x 16 bits
	addi	start_offs,a0
	move	*a0,a0
	addi	switches_cur,a0
	move	*a0,a0
	andi	1,a0
	rets

#*****************************************************************************

 SUBR	get_team1_turbo

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_turbo_down
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_turbo_down
	or	a0,a1
#no_player2
	move	a1,a0

	rets

#*****************************************************************************
 SUBR	get_team2_turbo

	clr	a1

	move	@PSTATUS,a2

	btst	2,a2
	jrz	#no_player1
	movk	2,a0			;player 3
	calla	get_turbo_down
	or	a0,a1
#no_player1

	btst	3,a2
	jrz	#no_player2
	movk	3,a0			;player 4
	calla	get_turbo_down
	or	a0,a1
#no_player2
	move	a1,a0

	rets

#*****************************************************************************
* RETURN:	a0 = start bit
*-----------------------------------------------------------------------------
 SUBR	get_turbo_down

	sll	4,a0			;x 16 bits
	addi	turbo_offs,a0
	move	*a0,a0
	addi	switches_down,a0
	move	*a0,a0
	andi	1,a0
	rets


	.if	TUNIT
turbo_offs	.word	06h,0eh,26h,2eh
	.else
turbo_offs	.word	12h,15h,17h,27h
	.endif

#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_sticks_cur

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_stick_val_cur
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_stick_val_cur
	or	a0,a1
#no_player2

	btst	2,a2
	jrz	#no_player3
	movk	2,a0			;player 3
	calla	get_stick_val_cur
	or	a0,a1
#no_player3

	btst	3,a2
	jrz	#no_player4
	movk	3,a0			;player 4
	calla	get_stick_val_cur
	or	a0,a1
#no_player4

	move	a1,a0
	rets


#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_sticks_cur2

	clr	a1

	clr	a0			;player 1
	calla	get_stick_val_cur
	or	a0,a1

	movk	1,a0			;player 2
	calla	get_stick_val_cur
	or	a0,a1

	movk	2,a0			;player 3
	calla	get_stick_val_cur
	or	a0,a1

	movk	3,a0			;player 4
	calla	get_stick_val_cur
	or	a0,a1

	move	a1,a0
	rets


#*****************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
;DJT Start
  SUBR	get_stick_val_cur_mkplr

	PUSH	a0
	move	@GAMSTATE,a0
	subk	INAMODE,a0
	mmfm	sp,a0
	jrnz	get_stick_val_cur
	.ref	stick_amode_mkplr
	move	@stick_amode_mkplr,a0
	andi	01111b,a0
	rets

;DJT End
  SUBR	get_stick_val_cur


	sll	4,a0			;x 16 bits
	addi	joy_offs,a0
	move	*a0,a0
	addi	switches_cur,a0
	move	*a0,a0
	andi	01111b,a0
	rets


#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_sticks_down

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_stick_val_down
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_stick_val_down
	or	a0,a1
#no_player2

	btst	2,a2
	jrz	#no_player3
	movk	2,a0			;player 3
	calla	get_stick_val_down
	or	a0,a1
#no_player3

	btst	3,a2
	jrz	#no_player4
	movk	3,a0			;player 4
	calla	get_stick_val_down
	or	a0,a1
#no_player4

	move	a1,a0
	rets


#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_sticks_down2

	clr	a1

	clr	a0			;player 1
	calla	get_stick_val_down
	or	a0,a1

	movk	1,a0
	calla	get_stick_val_down
	or	a0,a1

	movk	2,a0
	calla	get_stick_val_down
	or	a0,a1

	movk	3,a0
	calla	get_stick_val_down
	or	a0,a1
	move	a1,a0

	rets


******************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
;DJT Start
  SUBR	get_stick_val_down_mkplr

	PUSH	a0
	move	@GAMSTATE,a0
	subk	INAMODE,a0
	mmfm	sp,a0
	jrnz	get_stick_val_down
	move	@stick_amode_mkplr,a0
	andi	01111b,a0
	rets

;DJT End
  SUBR	get_stick_val_down

	sll	4,a0			;x 16 bits
	addi	joy_offs,a0
	move	*a0,a0
	addi	switches_down,a0
	move	*a0,a0
	andi	01111b,a0
	rets

joy_offs	.word	00h,08h,20h,28h

#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_buttons_cur

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_but_val_cur
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_but_val_cur
	or	a0,a1
#no_player2

	btst	2,a2
	jrz	#no_player3
	movk	2,a0			;player 3
	calla	get_but_val_cur
	or	a0,a1
#no_player3

	btst	3,a2
	jrz	#no_player4
	movk	3,a0			;player 4
	calla	get_but_val_cur
	or	a0,a1
#no_player4

	move	a1,a0
	rets


#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
  SUBR	get_all_buttons_cur2

	clr	a1
	clr	a0			;player 1
	calla	get_but_val_cur
	or	a0,a1
	movk	1,a0			;player 2
	calla	get_but_val_cur
	or	a0,a1
	movk	2,a0			;player 3
	calla	get_but_val_cur
	or	a0,a1
	movk	3,a0			;player 4
	calla	get_but_val_cur
	or	a0,a1
	move	a1,a0
	rets


#*****************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = button bits
*-----------------------------------------------------------------------------
;DJT Start
  SUBR	get_but_val_cur_mkplr

	PUSH	a0
	move	@GAMSTATE,a0
	subk	INAMODE,a0
	mmfm	sp,a0
	jrnz	get_but_val_cur
	move	@stick_amode_mkplr,a0
	srl	4,a0
	andi	0111b,a0
	rets

;DJT End
 SUBR	get_but_val_cur

	sll	4,a0			;x 16 bits
	addi	but_offs,a0
	move	*a0,a0
	addi	switches_cur,a0
	move	*a0,a0
	andi	0111b,a0
	rets

#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
 SUBR	get_all_buttons_down

	clr	a1

	move	@PSTATUS,a2

	btst	0,a2
	jrz	#no_player1
	clr	a0			;player 1
	calla	get_but_val_down
	or	a0,a1
#no_player1

	btst	1,a2
	jrz	#no_player2
	movk	1,a0			;player 2
	calla	get_but_val_down
	or	a0,a1
#no_player2

	btst	2,a2
	jrz	#no_player3
	movk	2,a0			;player 3
	calla	get_but_val_down
	or	a0,a1
#no_player3

	btst	3,a2
	jrz	#no_player4
	movk	3,a0			;player 4
	calla	get_but_val_down
	or	a0,a1
#no_player4

	move	a1,a0
	rets


#*****************************************************************************
* RETURN:	a0 = joy switch bits
*-----------------------------------------------------------------------------
 SUBR	get_all_buttons_down2

	clr	a1
	clr	a0			;player 1
	calla	get_but_val_down
	or	a0,a1
	movk	1,a0			;player 2
	calla	get_but_val_down
	or	a0,a1
	movk	2,a0			;player 3
	calla	get_but_val_down
	or	a0,a1
	movk	3,a0			;player 4
	calla	get_but_val_down
	or	a0,a1
	move	a1,a0
	rets


******************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = button bits
*-----------------------------------------------------------------------------
;DJT Start
  SUBR	get_but_val_down_mkplr

	PUSH	a0
	move	@GAMSTATE,a0
	subk	INAMODE,a0
	mmfm	sp,a0
	jrnz	get_but_val_down
	move	@stick_amode_mkplr,a0
	srl	4,a0
	andi	0111b,a0
	rets

;DJT End
 SUBR	get_but_val_down

	sll	4,a0			;x 16 bits
	addi	but_offs,a0
	move	*a0,a0
	addi	switches_down,a0
	move	*a0,a0
	andi	0111b,a0
	rets

	.if	TUNIT
but_offs	.word	04h,0ch,24h,2ch
	.else
but_offs	.word	04h,0ch,1ch,24h
	.endif

******************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = button bits
*-----------------------------------------------------------------------------
 SUBR	get_but_val_down_nt		;masks out turbo button

	sll	4,a0			;x 16 bits
	addi	but_offs,a0
	move	*a0,a0
	addi	switches_down,a0
	move	*a0,a0
;	andi	011b,a0			;mask out turbo
	andi	01b,a0			;mask out turbo and pass
	rets

******************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = button bits
*-----------------------------------------------------------------------------
 SUBR	get_steal_but_cur

	sll	4,a0			;x 16 bits
	addi	but_offs,a0
	move	*a0,a0
	addi	switches_cur,a0
	move	*a0,a0
	andi	010b,a0			;mask out turbo & shoot
	rets

******************************************************************************
* INPUT:	a0 = player number (0-3)
*-----------------------------------------------------------------------------
* RETURN:	a0 = button bits
*-----------------------------------------------------------------------------
 SUBR	get_block_but_cur

	sll	4,a0			;x 16 bits
	addi	but_offs,a0
	move	*a0,a0
	addi	switches_cur,a0
	move	*a0,a0
	andi	01b,a0			;mask out turbo and pass
	rets

#*****************************************************************************

	.asg	330,X1		;89,X1
	.asg	330,X2		;307,X2
	.asg	207,Y
	.asg	217,Y2

 SUBR	result_screen

	move	@kp_scores,a0,L
	move	a0,@scores,L
	move	@scores,a0
	move	@scores+16,a14
	add	a0,a14
	cmpi	20,a14
	jrlt	#x

	move	@kp_team1,a0
	move	a0,@team1
	move	@kp_team2,a0
	move	a0,@team2

	move	@kp_p1_crtplr,a14
	move	a14,@player1_data+PR_CREATED_PLYR
	move	@kp_p1_name1,a14
	move	a14,@player1_data+PR_NAME1
	move	@kp_p1_name2,a14
	move	a14,@player1_data+PR_NAME2
	move	@kp_p1_name3,a14
	move	a14,@player1_data+PR_NAME3
	move	@kp_p1_name4,a14
	move	a14,@player1_data+PR_NAME4
	move	@kp_p1_name5,a14
	move	a14,@player1_data+PR_NAME5
	move	@kp_p1_name6,a14
	move	a14,@player1_data+PR_NAME6
	move	@kp_p1_hdnbr,a14
	move	a14,@player1_data+PR_HEAD_NBR

	move	@kp_p2_crtplr,a14
	move	a14,@player2_data+PR_CREATED_PLYR
	move	@kp_p2_name1,a14
	move	a14,@player2_data+PR_NAME1
	move	@kp_p2_name2,a14
	move	a14,@player2_data+PR_NAME2
	move	@kp_p2_name3,a14
	move	a14,@player2_data+PR_NAME3
	move	@kp_p2_name4,a14
	move	a14,@player2_data+PR_NAME4
	move	@kp_p2_name5,a14
	move	a14,@player2_data+PR_NAME5
	move	@kp_p2_name6,a14
	move	a14,@player2_data+PR_NAME6
	move	@kp_p2_hdnbr,a14
	move	a14,@player2_data+PR_HEAD_NBR

	move	@kp_p3_crtplr,a14
	move	a14,@player3_data+PR_CREATED_PLYR
	move	@kp_p3_name1,a14
	move	a14,@player3_data+PR_NAME1
	move	@kp_p3_name2,a14
	move	a14,@player3_data+PR_NAME2
	move	@kp_p3_name3,a14
	move	a14,@player3_data+PR_NAME3
	move	@kp_p3_name4,a14
	move	a14,@player3_data+PR_NAME4
	move	@kp_p3_name5,a14
	move	a14,@player3_data+PR_NAME5
	move	@kp_p3_name6,a14
	move	a14,@player3_data+PR_NAME6
	move	@kp_p3_hdnbr,a14
	move	a14,@player3_data+PR_HEAD_NBR

	move	@kp_p4_crtplr,a14
	move	a14,@player4_data+PR_CREATED_PLYR
	move	@kp_p4_name1,a14
	move	a14,@player4_data+PR_NAME1
	move	@kp_p4_name2,a14
	move	a14,@player4_data+PR_NAME2
	move	@kp_p4_name3,a14
	move	a14,@player4_data+PR_NAME3
	move	@kp_p4_name4,a14
	move	a14,@player4_data+PR_NAME4
	move	@kp_p4_name5,a14
	move	a14,@player4_data+PR_NAME5
	move	@kp_p4_name6,a14
	move	a14,@player4_data+PR_NAME6
	move	@kp_p4_hdnbr,a14
	move	a14,@player4_data+PR_HEAD_NBR

	calla	display_blank
	calla	WIPEOUT			;CLEAN SYSTEM OUT

	movk	1,a0			;page flipping on
	move	a0,@dpageflip

	clr	a0
	move	a0,@IRQSKYE		;background color

	movi	SCRNEND,a0		;[256,405]
	move	a0,@SCRNLR,L

	clr	a0
	move	a0,@WORLDTLX,L
	move	a0,@WORLDTLY,L

	SLEEPK	2

	movi	result_mod,a0
	move	a0,@BAKMODS,L
	calla	BGND_UD1

;	clr	a10
;	movk	16,a11
;	CREATE0	fade_up

	movi	finalres_str_setup,a2
	calla	setup_message
	movi	finalres_str,a4,L
	calla	print_string_C2

	movk	3,a0
	calla	create_player_heads
	movk	3,a0
	calla	create_logos

	movi	170,a1	
	calla	create_names

	calla	update_logos
	calla	update_player_heads

	movi	name_setup,a2
	calla	setup_message

	movi	170,a0
	move	a0,@mess_cursy

	movi	player1_data+PR_NAME1,a4
	move	@player1_data+PR_CREATED_PLYR,a14
	jrle	#nxt
	movi	message_buffer,a3		;* string dest
	calla	get_name_string
	movi	56,a0
	move	a0,@mess_cursx
	calla	print_string_C
#nxt	
	movi	player2_data+PR_NAME1,a4
	move	@player2_data+PR_CREATED_PLYR,a14
	jrle	#nxt2
	movi	message_buffer,a3		;* string dest
	calla	get_name_string
	movi	147,a0
	move	a0,@mess_cursx
	calla	print_string_C
#nxt2
	movi	player3_data+PR_NAME1,a4
	move	@player3_data+PR_CREATED_PLYR,a14
	jrle	#nxt3
	movi	message_buffer,a3		;* string dest
	calla	get_name_string
	movi	251,a0
	move	a0,@mess_cursx
	calla	print_string_C
#nxt3
	movi	player4_data+PR_NAME1,a4
	move	@player4_data+PR_CREATED_PLYR,a14
	jrle	#nxt4
	movi	message_buffer,a3		;* string dest
	calla	get_name_string
	movi	342,a0
	move	a0,@mess_cursx
	calla	print_string_C
#nxt4
;	calla	hide_ball_under_logo

	movk	1,a10
	callr	create_player_nubs

	CREATE0	final_scores

	movk	1,a0
	move	a0,@DISPLAYON

	SLEEPK	2
	calla	display_unblank

	SLEEP	1*TSEC

	movi	12*TSEC,a10
#lp	SLEEPK	1
	calla	get_all_buttons_cur2
	jrz	#nob
	SOUND1	bounce_snd
	jruc	#xb
#nob	
	dsj	a10,#lp
#xb
	clr	a10
	movk	16,a11
	CREATE0	fade_down

	SLEEPK	24

	clr	a14
	move	a14,@player1_data+PR_CREATED_PLYR	;stop plyr from being
	move	a14,@player2_data+PR_CREATED_PLYR	;seen in amode
	move	a14,@player3_data+PR_CREATED_PLYR
	move	a14,@player4_data+PR_CREATED_PLYR

#x
	RETP


name_setup
	PRINT_STR	bast8t_ascii,8,1,200,4,BAST_W_P,0


finalres_str_setup
	PRINT_STR	brush20_ascii,10,0,200,7,BRSHGYOP,0

finalres_str
	.string	"FINAL RESULTS",0
	.even


result_mod
	.long	finalresBMOD
	.word	0,0
	.long	0


#*****************************************************************************
* 	This routine creates the player number graphic (nub)
*
* INPUT: 
*        reg a10 - X pos. table nbr.
******************************************************************************
 SUBR	create_player_nubs

	PUSH	a9
	movi	3500,a3			;z pos
	movi	DMAWNZ|M_NOCOLL,a4
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel

	sll	5,a10
	addi	scr_x_tbl_ptrs,a10
	move	*a10,a10,L

	movi	nub_img_tbl,a9,L
	move	@TWOPLAYERS,a14		;0 = NO, 1 = YES 2 players
	jrz	#nkit
	movi	nub_img_kit_tbl,a9,L
#nkit
	move	*a10+,a0,W		;get X pos.
	sll	16,a0
	move	*a10+,a1,W		;get Y pos.
	sll	16,a1
	move	*a9+,a2,L
	calla	BEGINOBJ2

	move	*a10+,a0,W		;get X pos.
	sll	16,a0
	move	*a10+,a1,W		;get X pos.
	sll	16,a1
	move	*a9+,a2,L
	calla	BEGINOBJ2

	move	*a10+,a0,W		;get X pos.
	sll	16,a0
	move	*a10+,a1,W		;get X pos.
	sll	16,a1
	move	*a9+,a2,L
	calla	BEGINOBJ2

	move	*a10+,a0,W		;get X pos.
	sll	16,a0
	move	*a10,a1,W		;get X pos.
	sll	16,a1
	move	*a9,a2,L
	calla	BEGINOBJ2
	PULL	a9
	rets


nub_img_tbl
	.long	PLYRNUB1
	.long	PLYRNUB2
	.long	PLYRNUB3
	.long	PLYRNUB4

nub_img_kit_tbl
	.long	PLYRNUB1
	.long	PLYRNUB1
	.long	PLYRNUB2
	.long	PLYRNUB2


scr_x_tbl_ptrs
	.long	stat_x_tbl,result_x_tbl
	

;stat screen
stat_x_tbl
	.word	13,103		;plyr 1
	.word	179,103		;plyr 2
	.word	208,103		;plyr 3
	.word	374,103		;plyr 4

;final result screen
result_x_tbl
	.word	12,168
	.word	178,168
	.word	208,168
	.word	374,168


#*****************************************************************************

	.if	0

 SUBRP	score_shadow

#SHAD1	equ	PDATA
#SHAD2	equ	#SHAD1+20h

	.asg	40,X1
	.asg	257,X2
	.asg	205,Y

	movi	[X1,0],a0		;x val
	movi	[Y,0],a1		;y val
	movi	scorshad1,a2		;* image
	movi	300,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ
	move	a8,*a13(#SHAD1),L

	movi	[X2,0],a0		;x val
	movi	[Y,0],a1		;y val
	movi	scorshad1,a2		;* image
	movi	300,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ
	move	a8,*a13(#SHAD2),L

	clr	a10
#big_mac
	SLEEPK	1
	xori	1,a10

	move	a10,a0
	sll	5,a0			;x 32 bits
	addi	#shadows,a0
	move	*a0,a11,L		;* image

	move	*a13(#SHAD1),a8,L
	calla	#change_shad
	move	*a13(#SHAD2),a8,L
	calla	#change_shad

	jruc	#big_mac

#change_shad
	move	a11,a0
	move	*a8(OCTRL),a1		;DMA flags
	calla	obj_aniq		;change object image
	rets


#shadows

	.long	scorshad1,scorshad2

	.endif

#*****************************************************************************
*   Print the final scores
******************************************************************************
 SUBRP	final_scores

	.asg	21,X1
	.asg	364,XF
	.asg	206,Y1
	.asg	227,Y2
	.asg	118,QTR1_X
	.asg	153,QTR2_X
	.asg	187,QTR3_X
	.asg	221,QTR4_X
	.asg	255,OT1_X
	.asg	289,OT2_X
	.asg	323,OT3_X

;
; Print team 1 city name
;
	movi	[X1,0],a0		;x val
	movi	[Y1,0],a1		;y val
	move	@team1,a2
	move	a2,a14
	sll	4,a14				;word length
	sll	5,a2				;LONG length
	add	a14,a2
	addi	city_table_start,a2
	move	*a2,a2,L
	movi	300,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	movi	BAST_W_P,b0,L
	calla	BEGINOBJP2		;plot CITY NAME
;
; Print team 2 city name
;
	movi	[X1,0],a0		;x val
	movi	[Y2,0],a1		;y val
	move	@team2,a2
	move	a2,a14
	sll	4,a14				;word length
	sll	5,a2				;LONG length
	add	a14,a2
	addi	city_table_start,a2
	move	*a2,a2,L
	movi	BAST_W_P,b0,L
	calla	BEGINOBJP2		;plot TEAM2 CITY NAME
;
; Print team scores, quarter by quarter
;
	movi	#score_setup,a2
	calla	setup_message
	move	@scores,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	calla	print_string_C

	move	@scores+10h,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print 1st quarter

	move	@kp_qscrs2,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR1_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+16,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR1_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print 2nd quarter

	move	@kp_qscrs2+32,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR2_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+48,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR2_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print 3rd quarter

	move	@kp_qscrs2+64,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR3_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+80,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR3_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print 4th quarter

	move	@kp_qscrs2+96,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR4_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+112,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	QTR4_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print Overtime 1
;DJT Start

	move	@kp_qscrs2,a0,L
	move	@kp_qscrs2+32,a14,L
	add	a14,a0
	move	@kp_qscrs2+64,a14,L
	add	a14,a0
	move	@kp_qscrs2+96,a14,L
	add	a14,a0
	move	@scores,a14,L
	cmp	a14,a0
	jreq	ovr_dn

	PUSH	a0
;DJT End
	move	@kp_qscrs2+128,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT1_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+144,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT1_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print Overtime 2
;DJT Start

	PULL	a0
	move	@kp_qscrs2+128,a14,L
	add	a14,a0
	move	@scores,a14,L
	cmp	a14,a0
	jreq	ovr_dn

	PUSH	a0
;DJT End
	move	@kp_qscrs2+160,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT2_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+176,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT2_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

;Print Overtime 3
;DJT Start

	PULL	a0
	move	@kp_qscrs2+160,a14,L
	add	a14,a0
	move	@scores,a14,L
	cmp	a14,a0
	jreq	ovr_dn

;DJT End
	move	@kp_qscrs2+192,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT3_X,a0
	move	a0,@mess_cursx
	movi	Y1-1,a0
	move	a0,@mess_cursy
	calla	print_string_C

	move	@kp_qscrs2+208,a0
	movi	999,a1			;max value
	calla	dec_to_asc
	calla	copy_string
	movi	OT3_X,a0
	move	a0,@mess_cursx
	movi	Y2-1,a0
	move	a0,@mess_cursy
	calla	print_string_C
;DJT Start
ovr_dn
;DJT End
	DIE

#score_setup
	PRINT_STR	bast10_ascii,8,0,XF,Y1-1,BAST_W_P,0


#*****************************************************************************

 SUBR	matchup_screen

	movk	1,a0
	move	a0,@inmatchup

	clr	a0
	movi	-1,a1
	calla	obj_delc		;delete all obj. expect transition obj

	clr	a1				;kill all processes
	calla	KILALL
	calla	KILBGND			;Kill old background

	clr	a0
	move	a0,@dpageflip

	move	@dpage,a1
	not	a1			;Flip
	move	a1,@dpage

;wipe obj. over screen
	movi	wipe_horizontal,a0,L
	movi	CREATE_NO_DEL_OBJS,a14		;dont delete objs. when done
	JSRP	do_scrn_transition

	SLEEPK	1

	movk	1,a0			;page flipping on
	move	a0,@dpageflip
;	movk	1,a0			;page flipping on
;	move	a0,@dtype

;	clr	a0
;	move	a0,@IRQSKYE		;background color

	movi	matchup_mod,a0
	move	a0,@BAKMODS,L
	calla	BGND_UD1
;DJT Start

 .if ANIM_VS
	move	@BAKLST,a0,L
#vsk
	move	*a0(OSIZEX),a14
	cmpi	44,a14
	jrne	#vsk1
	move	*a0(OCTRL),a14
	srl	2,a14
	sll	2,a14
	move	a14,*a0(OCTRL)
#vsk1
	move	*a0,a0,L
	jrnz	#vsk
 .endif ;ANIM_VS
;DJT End

	movk	1,a0
	calla	create_logos
	calla	update_logos

	movi	tnght_mat_str_setup,a2
	calla	setup_message
	movi	tonght_matchup_str,a4,L
	calla	print_string_C2

	movi	tm1_cty_str_setup,a2
	calla	setup_message
	move	@team1,a14
	sll	6,a14
	addi	city_names_str_tbl,a14
	move	*a14,a4,L
	calla	print_string_C2

	movi	tm1_nme_str_setup,a2
	calla	setup_message
	move	@team1,a14
	sll	6,a14
	addi	city_names_str_tbl,a14
	move	*a14(32),a4,L
	calla	print_string_C2

	movi	tm2_cty_str_setup,a2
	calla	setup_message
	move	@team2,a14
	sll	6,a14
	addi	city_names_str_tbl,a14
	move	*a14,a4,L
	calla	print_string_C2

	movi	tm2_nme_str_setup,a2
	calla	setup_message
	move	@team2,a14
	sll	6,a14
	addi	city_names_str_tbl,a14
	move	*a14(32),a4,L
	calla	print_string_C2

	movi	tm2_nme_str_setup,a2
	calla	setup_message
	move	@team2,a14
	sll	6,a14
	addi	city_names_str_tbl,a14
	move	*a14(32),a4,L
	calla	print_string_C2

	movi	bsd_stat_str_setup,a2
	calla	setup_message
	movi	bsd_stat_str,a4,L
	calla	print_string_C2

	move	@mess_cursy,a14
	addk	11,a14
	move	a14,@mess_cursy


	calla	get_teams_pop
	move	@team1,a0
	sll	5,a0
	addi	teams_pop,a0,L
	move	*a0,a0,L			;get team 1 'picked count'

	move	@team2,a14
	sll	5,a14
	addi	teams_pop,a14,L
	move	*a14,a14,L			;get team 2 'picked count'

	move	@team2,a4
	cmp	a0,a14				;team 2 more popular ?
	jrhs	#tmpop				;br=yes
	move	@team1,a4
#tmpop
	sll	6,a4
	addi	city_names_str_tbl,a4
	move	*a4,a4,L
	calla	copy_rom_string
	movi	favored_by_str,a4
	calla	concat_rom_string
;DJT Start

	clr	a0
	.ref	pup_msgs	;Matchup screen pup message flags
	move	a0,@pup_msgs,L
;DJT End

	movk	10,a0
	calla	RNDRNG0
	inc	a0
	movk	15,a1			;max value
	calla	dec_to_asc
	calla	concat_string
	calla	print_string_C

	clr	a10
	CREATE0	plyr_get_combination
	movk	1,a10
	CREATE0	plyr_get_combination
	movk	2,a10
	CREATE0	plyr_get_combination
	movk	3,a10
	CREATE0	plyr_get_combination

;	.ref	tuneq1_snd
;	SOUND1	tuneq1_snd

	SLEEPK	1

;wipe objs off screen -- reveal new screen
	movi	un_wipe_horizontal,a0,L
	movi	NO_CREATE_DEL_OBJS,a14
	JSRP	do_scrn_transition

	.ref	start_powerups
	CREATE	SMOVE_PID,start_powerups

	SLEEPK	1

;DJT Start
	.if	ANIM_VS
	CREATE	VS_LOGO_PID,animate_vs_logo
	.endif	;ANIM_VS
	CREATE0	call_matchup

	movi	TSEC*13/2,a10		;!!! 4
;DJT End
#delay
	SLEEPK	1
	dsj	a10,#delay
#exit
	calla	set_plyrs_powerup_ram
	movi	SMOVE_PID,a0
	movi	-1,a1
	calla	KILALL
	RETP


#******************************************************************************
; a10 = sleep count

	.asg	200-2,X
	.asg	135,Y

#restart
	calla	DELOBJA8

 SUBR	timeout

	clr	a0
	move	a0,@force_selection

	move	a10,a11
#wait
	SLEEPK	1
	dsj	a11,#wait

	movi	BRSH50R_P,b0
	movi	[X,0],a0			;x val
	movi	[Y,0],a1			;y val
	movi	BRSH50_9,a2			;* image
	movi	20700,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJP2
	calla	#center_image

	move	@PSTATUS,a9

	movi	9,a11
#loop
	SOUND1	cntdown_snd

	SLEEP	TSEC+25

	move	@PSTATUS,a0		;if player buys in
	cmp	a9,a0			;then restart timer
	jrne	#restart

	calla	obj_off

	SOUND1	cntdown_snd

	SLEEP	(1*TSEC)/2

	move	@PSTATUS,a0
	cmp	a9,a0
	jrne	#restart

	calla	obj_on
	move	a11,a0
	sll	5,a0
	addi	#nums-20h,a0
	move	*a0,a0,L		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	calla	#center_image

	dsj	a11,#loop

	SOUND1	cntdown_snd

	SLEEP	(1*TSEC+25)/2

	movk	1,a0
	move	a0,@force_selection

	calla	DELOBJA8
	DIE

#nums	.long	BRSH50_0,BRSH50_1,BRSH50_2
	.long	BRSH50_3,BRSH50_4,BRSH50_5
	.long	BRSH50_6,BRSH50_7,BRSH50_8,BRSH50_9

#center_image
	move	*a8(OSIZEX),a0
	srl	1,a0
	movi	X,a1
	sub	a0,a1
	move	a1,*a8(OXPOS)
	rets


;DJT Start
	.if	TRIVCON
;DJT End
#******************************************************************************
; a10 = sleep count

	.asg	198,X
	.asg	135,Y


 SUBR	timeout4

	clr	a0
	move	a0,@force_selection

	move	a10,a11
#wait
	SLEEPK	1
	dsj	a11,#wait			;wait before count down

	movi	BRSH50R_P,b0
	movi	[X,0],a0			;x val
	movi	[Y,0],a1			;y val
	movi	BRSH50_5,a2			;* image
	movi	20700,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TRIVIA_TIMER,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJP2
	calla	#center_image

	movi	5,a11
#loop
	SOUND1	cntdown_snd

	SLEEP	TSEC+25

	calla	obj_off

	SOUND1	cntdown_snd

	SLEEP	(1*TSEC)/2

	calla	obj_on
	move	a11,a0
	sll	5,a0
	addi	#nums-20h,a0
	move	*a0,a0,L		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	calla	#center_image

	dsj	a11,#loop

	SOUND1	cntdown_snd

	SLEEP	(1*TSEC+25)/2		;Give'm a grace period

	movk	1,a0
	move	a0,@force_selection

	calla	DELOBJA8
	DIE


#center_image
	move	*a8(OSIZEX),a0
	srl	1,a0
	movi	X,a1
	sub	a0,a1
	move	a1,*a8(OXPOS)
	rets



#nums	.long	BRSH50_0,BRSH50_1,BRSH50_2
	.long	BRSH50_3,BRSH50_4,BRSH50_5
	.long	BRSH50_6,BRSH50_7,BRSH50_8,BRSH50_9
;DJT Start
	.endif	;TRIVCON
;DJT End


#******************************************************************************
; a10 = sleep count

	.asg	200-2,X
	.asg	135,Y

#restart
	PULLP	a0
	calla	DELOBJA8

 SUBR	timeout2

	clr	a0
	move	a0,@force_selection

	move	a10,a11
#wait
	SLEEPK	1
	dsj	a11,#wait

	movi	BRSH50R_P,b0
	movi	[X,0],a0			;x val
	movi	[Y,0],a1			;y val
	movi	BRSH50_9,a2			;* image
	movi	30001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJP2
	calla	#center_image

	move	@PSTATUS,a9
	movi	9,a0
#loop
	PUSHP	a0

	SOUND1	cntdown_snd

	movi	TSEC+25,a11
#loop2
	SLEEPK	1
	calla	get_all_starts_down
	jrnz	#xit1
	dsj	a11,#loop2
#xit1
	SOUND1	cntdown_snd

	move	@PSTATUS,a0		;if player buys in
	cmp	a9,a0			;then restart timer
	jrne	#restart
	calla	obj_off
	movi	(1*TSEC)/2,a11
#loop3
	SLEEPK	1
	calla	get_all_starts_down
	jrnz	#xit2
	dsj	a11,#loop3
#xit2
	move	@PSTATUS,a0
	cmp	a9,a0
	jrne	#restart

	calla	obj_on
	PULLP	a0
	PUSHP	a0
	sll	5,a0
	addi	#nums-20h,a0
	move	*a0,a0,L		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	calla	#center_image

	PULLP	a0
	dsj	a0,#loop

	SOUND1	cntdown_snd

	movi	(1*TSEC+25)/2,a11
#loop4
	SLEEPK	1
	calla	get_all_starts_down
	jrnz	#xit3
	dsj	a11,#loop4
#xit3
	SOUND1	cntdown_snd

	movk	1,a0
	move	a0,@force_selection

	calla	DELOBJA8
	DIE


#center_image
	move	*a8(OSIZEX),a0
	srl	1,a0
	movi	X,a1
	sub	a0,a1
	move	a1,*a8(OXPOS)
	rets

#nums	.long	BRSH50_0,BRSH50_1,BRSH50_2
	.long	BRSH50_3,BRSH50_4,BRSH50_5
	.long	BRSH50_6,BRSH50_7,BRSH50_8,BRSH50_9

;;#nums	.long	lgmd_0,lgmd_1,lgmd_2
;;	.long	lgmd_3,lgmd_4,lgmd_5
;;	.long	lgmd_6,lgmd_7,lgmd_8,lgmd_9

#******************************************************************************
; a10 = sleep count

	.asg	200-2,X
	.asg	135,Y

 SUBR	timeout3

	clr	a0
	move	a0,@force_selection

	.ref	BTIME
	move	a0,@BTIME

	movi	BRSH50R_P,b0
	movi	[X,0],a0			;x val
	movi	[Y,0],a1			;y val
	movi	BRSH50_9,a2			;* image
	movi	30001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJP2
	calla	#center_image

	move	@PSTATUS,a9

	movi	9,a0
#loop
	PUSHP	a0

	SOUND1	cntdown_snd

	SLEEPK	3
	movi	TSEC+25-3,a11
#loop2
	SLEEPK	1

	move	@BTIME,a0
	jrnz	#reset

;DJT Start
	calla	get_all_buttons_cur2		;get_all_buttons_down2
	jrz	#nobut1
	move	@gmqrtr,a0
	subk	4,a0
	jrn	#xit1
	move	@PSTATUS,a0
	jrnz	#xit1
#nobut1
;DJT End
	dsj	a11,#loop2
#xit1

	SOUND1	cntdown_snd

	calla	obj_off

	SLEEPK	2
	movi	(1*TSEC)/2-3,a11
#loop3
	SLEEPK	1

	move	@BTIME,a0
	jrnz	#reset

;DJT Start
	calla	get_all_buttons_cur2		;get_all_buttons_down2
	jrz	#nobut2
	move	@gmqrtr,a0
	subk	4,a0
	jrn	#xit2
	move	@PSTATUS,a0
	jrnz	#xit2
#nobut2
;DJT End
	dsj	a11,#loop3
#xit2

	calla	obj_on
	PULLP	a0
	PUSHP	a0
	sll	5,a0
	addi	#nums-20h,a0
	move	*a0,a0,L		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	calla	#center_image

	PULLP	a0
	dsj	a0,#loop

	SOUND1	cntdown_snd

	SLEEPK	3
	movi	(1*TSEC+25)/2-3,a11
#loop4
	SLEEPK	1

	move	@BTIME,a0
	jrnz	#reset

;DJT Start
	calla	get_all_buttons_cur2		;get_all_buttons_down2
	jrz	#nobut3
	move	@gmqrtr,a0
	subk	4,a0
	jrn	#xit3
	move	@PSTATUS,a0
	jrnz	#xit3
#nobut3
;DJT End
	dsj	a11,#loop4
#xit3

	SOUND1	cntdown_snd

	movk	1,a0
	move	a0,@force_selection

	calla	DELOBJA8
	DIE

#reset
	clr	a0
	move	a0,@BTIME
	movi	TSEC,a10
	CREATE0	timeout3
	calla	DELOBJA8
	SOUND1	cntdown_snd
	DIE


#center_image
	move	*a8(OSIZEX),a0
	srl	1,a0
	movi	X,a1
	sub	a0,a1
	move	a1,*a8(OXPOS)
	rets


#nums	.long	BRSH50_0,BRSH50_1,BRSH50_2
	.long	BRSH50_3,BRSH50_4,BRSH50_5
	.long	BRSH50_6,BRSH50_7,BRSH50_8,BRSH50_9


#******************************************************************************
* a3  = * player data
* a10 = player number (0-3)
* sets special_heads based on initials entered
*
* updated to account for CREATED players...
*******************************************************************************
 SUBR	check_special_initials

	sll	4,a10				;x 16
	addi	special_heads,a10
;
; We want to favor the player who CREATED his/her character, this is just in case
;   its initials and pin_number match a team members. (or if a team member
;   wants to change their record)
;
	move	*a3(PR_CREATED_PLYR),a0		;player created ?
	cmpi	1,a0				;br=yep, no special head
	jrp	#end

	clr	a5
	movi	#team_data,a2
#next
	move	*a3(PR_NAME1),a0
	jrle	#no_match
	move	*a2,a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_NAME2),a0
	move	*a2(10h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_NAME3),a0
	move	*a2(20h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_NAME4),a0
	move	*a2(30h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_NAME5),a0
	move	*a2(40h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_NAME6),a0
	move	*a2(50h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_PIN_NBR1),a0
	move	*a2(60h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_PIN_NBR2),a0
	move	*a2(70h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_PIN_NBR3),a0
	move	*a2(80h),a1
	cmp	a0,a1
	jrne	#no_match

	move	*a3(PR_PIN_NBR4),a0
	move	*a2(90h),a1
	cmp	a0,a1
	jrne	#no_match

	movk	ADJTOURNEY,a0		;Tournament mode?
	calla	GET_ADJ			;0-1
	jrz	#yes			;On? Br=yes

	move	a5,*a10			;store special head number
	move	a5,a0
	sll	4,a5
	sll	5,a0			;x 16 x 4
	add	a5,a0
	addi	#team_snds,a0
	calla	snd_play1
#yes	rets
	

#no_match
	addi	NXT_TM_MEMBR,a2		;7 words per line in below table
	inc	a5			;head number
	cmpi	#team_data1_end,a2
	jrlo	#next
#end	rets


;DJT Start
;
; This is a table of all the SPECIAL players (designers...etc) reconizied 
;
	.asg	01,A_
	.asg	02,B_
	.asg	03,C_
	.asg	04,D_
	.asg	05,E_
	.asg	06,F_
	.asg	07,G_
	.asg	08,H_
	.asg	09,I_
	.asg	10,J_
	.asg	11,K_
	.asg	12,L_
	.asg	13,M_
	.asg	14,N_
	.asg	15,O_
	.asg	16,P_
	.asg	17,Q_
	.asg	18,R_
	.asg	19,S_
	.asg	20,T_
	.asg	21,U_
	.asg	22,V_
	.asg	23,W_
	.asg	24,X_
	.asg	25,Y_
	.asg	26,Z_
	.asg	29,SP

	.asg	-1+1,NUL
	.asg	0+1,ZER
	.asg	1+1,ONE
	.asg	2+1,TWO
	.asg	3+1,THR
	.asg	4+1,FOR
	.asg	5+1,FIV
	.asg	6+1,SIX
	.asg	7+1,SEV
	.asg	8+1,EIG
	.asg	9+1,NIN
	.asg	10+1,SPC

#team_data
	.word	J_,A_,P_,P_,L_,E_
	.word	SIX,SIX,SIX,ZER 	;00  JOHNSON
#team_data1
	.word	D_,I_,V_,I_,T_,A_
	.word	ZER,TWO,ZER,ONE 	;01  DIVITA

	.word	T_,U_,R_,M_,E_,L_
	.word	ZER,THR,TWO,TWO 	;02  TURMELL

	.word	D_,A_,N_,I_,E_,L_
	.word	ZER,SIX,ZER,FOR 	;03  THOMPSON

	.word	E_,U_,G_,E_,N_,E_
	.word	SIX,SEV,SIX,SEV 	;04  GEER

	.word	J_,C_,0,0,0,0
	.word	ZER,ZER,ZER,ZER 	;05  CARLTON

	.word	J_,F_,E_,R_,0,0
	.word	ZER,FIV,ZER,THR 	;06  HEDRICK

	.word	J_,O_,N_,H_,E_,Y_
	.word	SIX,ZER,ZER,ZER 	;07  JON HEY

	.word	M_,O_,R_,R_,I_,S_
	.word	SIX,ZER,ZER,ZER 	;08  AIR MORRIS

	.word	B_,A_,R_,D_,O_,0
	.word	SIX,ZER,ZER,ZER 	;09  STEVE BARDO

	.word	M_,I_,N_,I_,F_,E_
	.word	SIX,ZER,ZER,ZER 	;10  MINIFEE

	.word	M_,A_,R_,T_,Y_,0
	.word	ONE,ZER,ONE,ZER 	;11  MARTINEZ

	.word	C_,A_,R_,L_,O_,S_
	.word	ONE,ZER,ONE,ZER 	;12  PESINA

	.word	S_,H_,A_,W_,N_,0
	.word	ZER,ONE,TWO,THR 	;13  LIPTAK

	.word	E_,D_,D_,I_,E_,0
	.word	SIX,TWO,ONE,THR 	;14  EDDIE

	.word	M_,X_,V_,0,0,0
	.word	ONE,ZER,ONE,FOR 	;15  MIKE V.

	.word	J_,A_,M_,I_,E_,0
	.word	ONE,ZER,ZER,ZER 	;16  JAMIE

	.word	N_,I_,C_,K_,0,0
	.word	SEV,ZER,ZER,ZER 	;17  NICK E.

	.word	R_,O_,O_,T_,0,0
	.word	SIX,ZER,ZER,ZER 	;18  J. ROOT

	.word	M_,E_,D_,N_,I_,K_
	.word	SIX,ZER,ZER,ZER 	;19  C. MEDNICK

	.word	D_,A_,N_,R_,0,0
	.word	ZER,ZER,ZER,ZER 	;20  DAN R.

	.word	P_,A_,T_,F_,0,0
	.word	TWO,ZER,ZER,ZER 	;21  PAT F.
		
	.word	K_,O_,M_,B_,A_,T_
	.word	ZER,ZER,ZER,FOR 	;22  ED BOON
		  
	.word	M_,O_,R_,T_,A_,L_
	.word	ZER,ZER,ZER,FOR 	;23  J. TOBIAS
	
	.word	S_,N_,O_,0,0,0
	.word	ZER,ONE,ZER,THR 	;24 OURSLER
	    
	.word	J_,A_,S_,O_,N_,0
	.word	ZER,SEV,TWO,SPC 	;25  JASON

	.word	Q_,U_,I_,N_,0,0
	.word	ZER,THR,THR,ZER 	;26 QUINN

	.word	P_,E_,R_,R_,Y_,0
	.word	THR,FIV,ZER,ZER 	;27 PERRY

	.word	N_,F_,U_,N_,K_,0
	.word	ZER,ONE,ZER,ONE 	;28 NEIL FUNK

	.word	M_,D_,O_,C_,0,0
	.word	TWO,ZER,NUL,NUL 	;29 MDOC

	.word	N_,O_,B_,U_,D_,0
	.word	ONE,ZER,ONE,ZER 	;30 BUD

	.word	M_,A_,R_,I_,U_,S_
	.word	ONE,ZER,ZER,FIV 	;31 MARIUS

	.word	M_,U_,N_,D_,A_,Y_
	.word	FIV,FOR,THR,TWO 	;32 MUNDAY

	.word	N_,O_,R_,T_,H_,0
	.word	FIV,ZER,FIV,ZER 	;33 NORTH

	.word	A_,M_,R_,I_,C_,H_
	.word	TWO,ZER,TWO,ZER 	;34 AMRICH

	.word	J_,I_,G_,G_,E_,T_
	.word	ONE,ZER,ONE,ZER 	;35 JIGGETS

	.word	Z_,I_,R_,I_,N_,0
	.word	ONE,ZER,ONE,ZER 	;36 ZIRIN

	.word	H_,E_,I_,T_,H_,0
	.word	ONE,ZER,SEV,NIN		;37 HEITH BETTLEMAN

	.word	M_,A_,T_,T_,SP,B_
	.word	ZER,ONE,EIG,FOR		;38 MATT BETTLEMAN

	.word	K_,SP,D_,A_,Y_,0
	.word	FOR,TWO,FOR,TWO		;39 KEVIN DAY

;Superstar special guests
;FIX!!!
;Use name and birthday as pin #

	.word	P_,I_,P_,P_,E_,N_
	.word	ZER,ZER,ZER,ZER 	;PIPPEN  

	.word	R_,O_,D_,M_,A_,N_
	.word	ZER,ZER,ZER,ZER 	;RODMAN

	.word	J_,O_,H_,N_,S_,N_
	.word	ZER,ZER,ZER,ZER 	;JOHNSN_L

	.word	R_,I_,C_,E_,0,0
	.word	ZER,ZER,ZER,ZER 	;RICE

	.word	K_,I_,D_,D_,0,0
	.word	ZER,ZER,ZER,ZER 	;KIDD

	.word	M_,O_,T_,U_,M_,B_
	.word	ZER,ZER,ZER,ZER 	;MOTUMBO

	.word	G_,H_,I_,L_,L_,0
	.word	ZER,ZER,ZER,ZER 	;G. HILL

	.word	D_,R_,E_,A_,M_,0
	.word	ZER,ZER,ZER,ZER 	;OLAJUAMWN

	.word	M_,I_,L_,L_,E_,R_
	.word	ZER,ZER,ZER,ZER 	;R. MILLER

	.word	S_,M_,I_,T_,S_,0
	.word	ZER,ZER,ZER,ZER 	;R. SMITS

	.word	M_,O_,U_,R_,N_,G_
	.word	ZER,ZER,ZER,ZER 	;MOURNING

	.word	G_,L_,E_,N_,N_,R_
	.word	ZER,ZER,ZER,ZER 	;G. ROBINSON

	.word	E_,W_,I_,N_,G_,0
	.word	ZER,ZER,ZER,ZER 	;EWING

	.word	S_,T_,A_,R_,K_,S_
	.word	ZER,ZER,ZER,ZER 	;STARKS

	.word	A_,H_,R_,D_,W_,Y_
	.word	ZER,ZER,ZER,ZER 	;A. HARDAWAY

	.word	H_,G_,R_,A_,N_,T_
	.word	ZER,ZER,ZER,ZER 	;H. GRANT

	.word	S_,T_,A_,C_,K_,H_
	.word	ZER,ZER,ZER,ZER 	;STACKHOUSE

	.word	C_,L_,I_,F_,F_,R_
	.word	ZER,ZER,ZER,ZER 	;CLIFF R.

	.word	D_,A_,V_,I_,D_,R_
	.word	ZER,ZER,ZER,ZER 	;DAVID R.

	.word	E_,L_,L_,I_,O_,T_
	.word	ZER,ZER,ZER,ZER 	;S. ELLIOT

	.word	K_,E_,M_,P_,0,0
	.word	ZER,ZER,ZER,ZER 	;KEMP

	.word	M_,A_,L_,O_,N_,E_
	.word	ZER,ZER,ZER,ZER 	;MALONE

	.word	W_,E_,B_,B_,E_,R_
	.word	ZER,ZER,ZER,ZER 	;WEBBER

	.word	M_,U_,R_,S_,A_,N_
	.word	ZER,ZER,ZER,ZER 	;MURESAN

;New Superstar special guests removed from teams
;FIX!!!
;Use name and birthday as pin #

	.word	M_,C_,L_,O_,U_,D_
	.word	ZER,ZER,ZER,ZER 	;McCLOUD,     george

	.word	T_,M_,I_,L_,L_,S_
	.word	ZER,ZER,ZER,ZER 	;MILLS,       terry

	.word	K_,S_,M_,I_,T_,H_
	.word	ZER,ZER,ZER,ZER 	;SMITH,       kenny

	.word	M_,C_,K_,E_,E_,0
	.word	ZER,ZER,ZER,ZER 	;McKEE,       derek

	.word	C_,H_,A_,P_,M_,N_
	.word	ZER,ZER,ZER,ZER 	;CHAPMAN,     rex

	.word	B_,E_,N_,J_,M_,N_
	.word	ZER,ZER,ZER,ZER 	;BENJAMIN,    benoit

	.word	D_,O_,U_,G_,L_,S_
	.word	ZER,ZER,ZER,ZER 	;DOUGLAS,     sherman

	.word	S_,P_,U_,D_,0,0
	.word	ZER,ZER,ZER,ZER 	;WEBB,        spud

	.word	G_,I_,L_,I_,A_,M_
	.word	ZER,ZER,ZER,ZER 	;GILLIAM,     armon

	.word	K_,E_,V_,I_,N_,E_
	.word	ZER,ZER,ZER,ZER 	;EDWARDS,     kevin

	.word	O_,A_,K_,L_,E_,Y_
	.word	ZER,ZER,ZER,ZER 	;OAKLEY,      charles

	.word	R_,U_,F_,F_,I_,N_
	.word	ZER,ZER,ZER,ZER 	;RUFFIN,      trevor

	.word	W_,E_,S_,L_,E_,Y_
	.word	ZER,ZER,ZER,ZER 	;PERSON,      wesley

	.word	F_,I_,N_,L_,E_,Y_
	.word	ZER,ZER,ZER,ZER 	;FINLEY,      michael

	.word	B_,U_,C_,K_,0,0
	.word	ZER,ZER,ZER,ZER 	;WILLIAMS,    buck

	.word	P_,E_,R_,S_,O_,N_
	.word	ZER,ZER,ZER,ZER 	;PERSON,      chuck

	.word	A_,L_,V_,I_,N_,R_
	.word	ZER,ZER,ZER,ZER 	;ROBERTSON,   alvin

	.word	O_,M_,I_,L_,L_,R_
	.word	ZER,ZER,ZER,ZER 	;MILLER,      oliver

	.word	M_,U_,R_,R_,A_,Y_
	.word	ZER,ZER,ZER,ZER 	;MURRAY,      tracy

	.word	B_,E_,N_,O_,I_,T_
	.word	ZER,ZER,ZER,ZER 	;BENOIT,      david

	.word	B_,S_,C_,O_,T_,T_
	.word	ZER,ZER,ZER,ZER 	;SCOTT,       byron

	.word	M_,U_,R_,D_,C_,K_
	.word	ZER,ZER,ZER,ZER 	;MURDOCK,     eric

#team_data1_end



NXT_TM_MEMBR	.equ	(#team_data1-#team_data)
NUM_MEMBRS	.equ	(#team_data1_end-#team_data)/NXT_TM_MEMBR


	
#team_snds
	.word	>3505,32,2290		;0  JEFF JOHNSON
	.word	>3505,31,2276		;1  SAL DIVITA
	.word	>3505,32,2272		;2  TURMELL
	.word	>3505,28,2286		;3  THOMPSON
	.word	>3505,22,2278		;4  GEER 
	.word	>3505,33,2288		;5  CARLTON
	.word	>3505,28,2280		;6  HEDRICK
	.word	>3505,23,2274		;7  JOHN HEY
	.word	>3505,43,2266		;8  AIR MORRIS
	.word	>3505,30,2268		;9  STEVE BARDO
	.word	>3505,35,2270		;10 MINIFEE
	.word	>3505,41,2282		;11 MARTINEZ
	.word	>3505,36,2284		;12 PESINA
	.word	>3505,36,2250		;13 LIPTAK
	.word	>3505,46,1910		;14 EDDIE
	.word	>3505,26,1920		;15 MIKE V
	.word	>3505,37,2867		;16 JAMIE R.
	.word	>3505,37,2867		;17 NICK E.
	.word	>3505,37,2867		;18 J. ROOT
	.word	>3505,37,2867		;19 MEDNICK
	.word	>3505,37,2867		;20 DAN R.
	.word	>3505,37,2867		;21 PAT F.
	.word	>3505,37,2867		;22 ED BOON
	.word	>3505,37,2867		;23 J. TOBIAS
	.word	>3505,37,2867		;24 OURSLER
	.word	>3505,37,2867		;25 JASON S.
	.word	>3505,37,2867		;26 QUINN
	.word	>3505,37,2867		;27 M. PERRY
	.word	>3505,37,2867		;28 N. FUNK
	.word	>3505,37,2867		;29 MDOC
	.word	>3505,37,2867		;30 BUD
	.word	>3505,54,1877		;31 MARIUS
	.word	>3505,37,2867		;32 MUNDAY
	.word	>3505,37,2867		;33 NORTH
	.word	>3505,37,2867		;34 AMRICH 
	.word	>3505,37,2867		;35 JIGGETS
	.word	>3505,37,2867		;36 ZIRIN
	.word	>3505,37,2867		;37 HEITH BETTLEMAN
	.word	>3505,37,2867		;38 MATT BETTLEMAN
	.word	>3505,43,2787		;39 KEVIN DAY

;Superstar special guests
 .word	>100D,72,1360	;PIPPEN,      scottie
 .word	>100D,60,1364	;RODMAN,      dennis
 .word	>100D,74,1344	;JOHNSON,     larry
 .word	>100D,65,1348	;RICE,        glen
 .word	>100D,68,1404	;KIDD,        jason
 .word	>100D,103,1424	;MUTUMBO,     dekembe
 .word	>100D,63,1444	;HILL,        grant
 .word	>100D,118,1480	;OLAJUWAN,    hakeem
 .word	>100D,85,1500	;MILLER,      reggie
 .word	>100D,71,1508	;SMITS,       rik
 .word	>100D,97,1560	;MOURNING,    alonzo
 .word	>100D,93,1584	;ROBINSON,    glen
 .word	>100D,82,1640	;EWING,       patrick
 .word	>100D,70,1656	;STARKS,      john
 .word	>100D,95,1660	;HARDAWAY,    anfernee
 .word	>100D,76,1664	;GRANT,       horace
 .word	>100D,96,1680	;STACKHOUSE,  jerry
 .word	>100D,94,1724	;ROBINSON,    cliff
 .word	>100D,92,1764	;ROBINSON,    david
 .word	>100D,69,1760	;ELLIOTT,     sean
 .word	>100D,64,1780	;KEMP,        shawn
 .word	>100D,68,1824	;MALONE,      karl
 .word	>100D,53,1864	;WEBBER,      chris
 .word	>100D,92,1876	;MURESAN,     gheorge

;New Superstar special guests removed from teams
 .word	>100D,84,1416	;McCLOUD,     george
 .word	>100D,76,1448	;MILLS,       terry
 .word	>100D,64,1496	;SMITH,       kenny
 .word	>100D,77,1512	;McKEE,       derek
 .word	>100D,60,1961	;CHAPMAN,     rex
 .word	>100D,69,1592	;BENJAMIN,    benoit
 .word	>100D,69,1596	;DOUGLAS,     sherman
 .word	>100D,61,1964	;WEBB,        spud
 .word	>100D,54,1628	;GILLIAM,     armon
 .word	>100D,60,1636	;EDWARDS,     kevin
 .word	>100D,81,1652	;OAKLEY,      charles
 .word	>100D,64,1967	;RUFFIN,      trevor
 .word	>100D,77,1712	;PERSON,      wesley
 .word	>100D,95,1716	;FINLEY,      michael
 .word	>100D,73,1732	;WILLIAMS,    buck
 .word	>100D,71,1772	;PERSON,      chuck
 .word	>100D,61,1952	;ROBERTSON,   alvin
 .word	>100D,67,1812	;MILLER,      oliver
 .word	>100D,53,1816	;MURRAY,      tracy
 .word	>100D,69,1832	;BENOIT,      david
 .word	>100D,60,1958	;SCOTT,       byron
 .word	>100D,63,1856	;MURDOCK,     eric


;DJT End
#******************************************************************************

 SUBR	select_teams

;DJT Start
	PUSH	a3

	clr	a3
	not	a3
	move	a3,@t1ispro		;Set for regular skill level
	move	a3,@t2ispro

;DJT End
	move	@team1,a0
	move	@team2,a1
	or	a0,a1
	move	a1,a1
	jrnn	#teams_ok		;both teams selected?

	move	@team1,a0
	jrnn	#select_team2

#select_team1
	movi	ALL_TMS_DEFEATD,a1
	move	@PSTATUS,a0
	btst	2,a0
	jrz	#nop3
	move	@player3_data+PR_NAME1,a0
	jrle	#nop3
	move	@player3_data+PR_TEAMSDEF,a0,L
	and	a0,a1
#nop3
	move	@PSTATUS,a0
	btst	3,a0
	jrz	#nop4
	move	@player4_data+PR_NAME1,a0
	jrle	#nop4
	move	@player4_data+PR_TEAMSDEF,a0,L
	and	a0,a1
#nop4
;DJT Start
	calla	calc_num_defeated	;A1/A2 are not destroyed!!!
	clr	a3
	cmpi	NUM_ISPRO,a0
	subb	a3,a3
	cmpi	NUM_ISCHAMP,a0
	addc	a3,a3
	cmpi	NUM_TEAMS,a0
	jreq	#choose_random1		; br=all teams beat/no initials entry

	calla	get_opponent_team	;Returns A2=team #
	move	a2,@team1

	move	a2,a0			;CPU team. Do RNDPER for new squad #
	sll	4,a0			; based on total possible per team
	addi	team_sqaud_cnts,a0,L
	move	*a0,a0
	subk	1,a0
	move	a3,a3			;Human team @ champ level?
	jrnz	#nc1			; br=no
	movk	1,a0			;Select from first 2 squads only
#nc1
	calla	RNDRNG0
	sll	4,a2
	addi	tm1set,a2,L
	move	a0,*a2
	jruc	#ispro1

#choose_random1
	movk	NUM_TEAMS-1,a0		;RNDPER for any team #
	calla	RNDRNG0
	move	a0,@team1

	move	@HCOUNT,a1		;RNDPER for either of first 2 squads
	movk	1,a14
	and	a14,a1
	sll	4,a0
	addi	tm1set,a0
	move	a1,*a0

	move	@player3_data+PR_NAME1,a14	;Beat all teams? Chk initials
	jrgt	#cont1
	move	@player4_data+PR_NAME1,a14
	jrle	#teams_ok			; br=no
#cont1
	movi	NUM_MEMBRS-1,a0		;Give superstar plyr a rnd special
	calla	RNDRNG0			; guest opponent
;;	addi	56,a0
;;	clr	a0
	move	a0,@special_heads+10h
#ispro1
	move	a3,@t2ispro
	jruc	#teams_ok

;; NOT!! NUM_TEAMS elements
;; Table needs to be plyr initials (currently $1-$1D) # of elements
;#setnum	.word	0
;	.word	1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,3,0,0,0,3,1,1,0
;DJT End

#select_team2
	movi	ALL_TMS_DEFEATD,a1
	move	@PSTATUS,a0
	btst	0,a0
	jrz	#nop1
	move	@player1_data+PR_NAME1,a0
	jrle	#nop1
	move	@player1_data+PR_TEAMSDEF,a0,L
	and	a0,a1
#nop1
	move	@PSTATUS,a0
	btst	1,a0
	jrz	#nop2
	move	@player2_data+PR_NAME1,a0
	jrle	#nop2
	move	@player2_data+PR_TEAMSDEF,a0,L
	and	a0,a1
#nop2
;DJT Start
	calla	calc_num_defeated	;A1/A2 are not destroyed!!!
	clr	a3
	cmpi	NUM_ISPRO,a0
	subb	a3,a3
	cmpi	NUM_ISCHAMP,a0
	addc	a3,a3
	cmpi	NUM_TEAMS,a0
	jreq	#choose_random2		; br=all teams beat/no initials entry

	calla	get_opponent_team	;Returns A2=team #
	move	a2,@team2

	move	a2,a0			;CPU team. Do RNDPER for new squad #
	sll	4,a0			; based on total possible per team
	addi	team_sqaud_cnts,a0,L
	move	*a0,a0
	subk	1,a0
	move	a3,a3			;Human team @ champ level?
	jrnz	#nc2			; br=no
	movk	1,a0			;Select from first 2 squads only
#nc2
	calla	RNDRNG0
	sll	4,a2
	addi	tm2set,a2,L
	move	a0,*a2
	jruc	#ispro2

#choose_random2
	movk	NUM_TEAMS-1,a0		;RNDPER for any team #
	calla	RNDRNG0
	move	a0,@team2

	move	@HCOUNT,a1		;RNDPER for either of first 2 squads
	movk	1,a14
	and	a14,a1
	sll	4,a0
	addi	tm2set,a0
	move	a1,*a0

	move	@player1_data+PR_NAME1,a14	;Beat all teams? Chk initials
	jrgt	#cont2
	move	@player2_data+PR_NAME1,a14
	jrle	#teams_ok			; br=no
#cont2
	movi	NUM_MEMBRS-1,a0		;Give superstar plyr a rnd special
	calla	RNDRNG0			; guest opponent
;;	addi	56,a0
;;	clr	a0
	move	a0,@special_heads+30h
#ispro2
	move	a3,@t1ispro

#teams_ok
	PULL	a3
	rets


;This table should be ranked by real NBA record
;Updated on 10/15/96
;Worst to Best:

_ATL	.equ	0
_BOS	.equ	1
_CHA	.equ	2
_CHI	.equ	3
_CLE	.equ	4
_DAL	.equ	5
_DEN	.equ	6
_DET	.equ	7
_GOL	.equ	8
_HOU	.equ	9
_IND	.equ	10
_LAC	.equ	11
_LAL	.equ	12
_MI	.equ	13
_MIL	.equ	14
_MIN	.equ	15
_NJ	.equ	16
_NY	.equ	17
_ORL	.equ	18
_PHI	.equ	19
_PHX	.equ	20
_POR	.equ	21
_SAC	.equ	22
_SAN	.equ	23
_SEA	.equ	24
_TOR	.equ	25
_UTA	.equ	26
_VAN	.equ	27
_WAS	.equ	28

team_orders
	.word	_VAN	;27	29
	.word	_PHI	;19	28
	.word	_TOR	;25	27
	.word	_MIL	;14	26
	.word	_DAL	;5	25
	.word	_MIN	;15	24
	.word	_LAC	;11	23
	.word	_NJ	;16	22
	.word	_BOS	;1	21
	.word	_DEN	;6	20
	.word	_GOL	;8	19
	.word	_SAC	;22	18
	.word	_WAS	;28	17
	.word	_CHA	;2	16
	.word	_PHX	;20	15
	.word	_MI	;13	14
	.word	_POR	;21	13
	.word	_DET	;7	12
	.word	_ATL	;0	11
	.word	_CLE	;4	10
	.word	_NY	;17	9
	.word	_HOU	;9	8
	.word	_IND	;10	7
	.word	_LAL	;12	6
	.word	_UTA	;26	5
	.word	_SAN	;23	4
	.word	_ORL	;18	3
	.word	_SEA	;24	2
	.word	_CHI	;3	1
	.word	-1
;DJT End


#******************************************************************************
*
* INPUT:	a0 = Nth undefeated team
*		a1 = teams defeated bits
* RETURN:	a2 = team number
*
*------------------------------------------------------------------------------
 SUBR	get_opponent_team

	movi	team_orders,a0
#next_team
	move	*a0+,a2			;team number (0-28)
	jrn	#err			;shouldn't happen
	btst	a2,a1			;defeated?
	jrnz	#next_team
	rets
#err
	clr	a2
	rets




 .if 0
	PUSH	a1
	clr	a2
#next_team
	srl	1,a1
	jrc	#def
;	dec	a0			;teams defeated count ++
;	jrn	#done
#def
	inc	a2
	cmpi	26,a2
	jrlo	#next_team
#done
	PULL	a1
	rets
 .endif

#*****************************************************************************


 SUBR	print_plr_name

	move	a10,a0
	sll	4,a0				;x 16 bits
	move	a0,a1
	sll	1,a0				;x 32 bits
	addi	#plyrdata,a0
	move	*a0,a4,L			;* scr initials

	movi	init_x,a2
	move	@TWOPLAYERS,a0		;0 = NO, 1 = YES 2 players
	jrz	#not2a
	movi	kit_x,a2			;kit x vals
#not2a
	add	a2,a1

	move	*a1,a1
	move	a1,@mess_cursx
	movi	message_buffer,a3		;* string dest
	calla	get_name_string
	calla	print_string_C			;centered
	rets



	.asg	70,Y1
	.asg	104,Y2

 SUBR	ingame_mess

#wait
	move	@PSTATUS,a0
	btst	a10,a0
	jrnz	#ingame
	SLEEPK	1
	jruc	#wait
#ingame

	movi	#name_setup,a2
	calla	setup_message

	callr	print_plr_name

	move	@gmqrtr,a0
	cmpi	4,a0
	jrls	#ok
	movk	4,a0
#ok
	sll	5,a0			;x 32 bits
	addi	#qtr_msgs,a0
	move	*a0,a2,L		;* image

	sll	4,a10			;x 16 bits

	movi	#qtr_x,a3
	move	@TWOPLAYERS,a0		;0 = NO, 1 = YES 2 players
	jrz	#not2b
	movi	kit_x,a3			;kit x vals
#not2b
	add	a3,a10

	move	*a10,a0
	sll	16,a0			;x val
	PUSH	a0
	movi	[Y2,0],a1		;y val
	movi	1000,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	movi	TYPTEXT,a5		;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	movi	BAST_W_P,b0		;pal
	calla	BEGINOBJP2

	PULL	a0
	movi	[Y1,0],a1		;y val
	movi	getready,a2		;* image
	movi	1000,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	movi	TYPTEXT,a5		;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	movi	BAST_W_P,b0		;pal
	calla	BEGINOBJP2
	DIE


#plyrdata
	.long	player1_data+PR_NAME1
	.long	player2_data+PR_NAME1
	.long	player3_data+PR_NAME1
	.long	player4_data+PR_NAME1

#name_setup
	PRINT_STR	bast8_ascii,5,0,200,208,BAST_R_P,0

#qtr_msgs
	.long	_1quart,_2quart
	.long	_3quart,_4quart
	.long	OVRTME,OVRTME
	.long	OVRTME,OVRTME
;	.long	overtme,overtme
;	.long	overtme,overtme

#qtr_x	.word	55,151,249,344	;x val


init_x	.word	56,149,250,342
;#init_x	.word	56,145,250,339

kit_x	.word	0,101,295,0	;kit x vals



#*****************************************************************************

 SUBR	winner_stays_on

	movi	ADJWINMODE,a0
	calla	GET_ADJ
	move	a0,a14
	jrz	#exit				;br=disabled

;	cmpi	1,a14				;'all games' ?
;	jreq	#allow				;br=yes
;
;	cmpi	2,a14				;'player vs. player' ?
;	jrne	#ckfor				;br=no
;	move	@_2plyr_competitive,a0
;	jrz	#allow				;br=A human on each team!
;#ckfor
;	cmpi	3,a14				;'4 players' ?
;	jrne	#exit				;br=no, exit
	move	@_4plyrsingame,a0
	jrnz	#exit		 		;br=not a four player game
;#allow
	movk	INFREEPRICE,a0
	move	a0,@GAMSTATE

;Zero PxDATA areas

	clr	a0
	movi	P1DATA,a1
	movi	PDSIZE*4/16,A2
#zlp	move	a0,*a1+
	dsj	a2,#zlp

	move	a0,@conttimers,L		;4 words
	move	a0,@conttimers+20h,L

	clr	a0
	move	a0,@PSTATUS
	move	a0,@PSTATUS2

	calla	display_blank
	calla	WIPEOUT			;CLEAN SYSTEM OUT

	movi	MAX_CRTIME,a0
	move	a0,@cntrs_delay

	movk	1,a0			;page flipping on
	move	a0,@dpageflip

	clr	a0
	move	a0,@IRQSKYE		;background color

	movi	SCRNEND,a0		;[256,405]
	move	a0,@SCRNLR,L

	clr	a0
	move	a0,@WORLDTLX,L
	move	a0,@WORLDTLY,L

	clr	a10
	move	@scores,a0
	move	@scores+10h,a1
	cmp	a1,a0			;score2 - score1
	jrgt	#t1_wins
	movk	1,a10			;t2_wins
#t1_wins
	move	a10,@winningteam	;0 or 1

	SLEEPK	2

	movi	#winner_mod,a0
	move	a0,@BAKMODS,L
	calla	BGND_UD1

	movk	1,a0
	move	a0,@DISPLAYON

	CREATE0	monitor_buyins
	CREATE0	team_control

	CREATE0	credits
	CREATE0	credit_messages
	CREATE0	monitor_fullgame

	.asg	102,X1
	.asg	294,X2

	.asg	21,Y1
	.asg	42,Y2
	.asg	110,Y3

	move	a10,a0
	sll	4,a0
	addi	#xpos,a0
	move	*a0,a11

	move	a11,a0				;x val
	sll	16,a0
	movi	[Y1,0],a1			;y val
	movi	congrats_l,a2			;* image
	movi	19001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2

	move	a11,a0				;x val
	sll	16,a0
	movi	[Y3,0],a1			;y val
	movi	winfree,a2			;* image
	movi	19001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2

	movi	#inits_setup,a2
	calla	setup_message
	movi	#str_pl12,a4
	move	a10,a10
	jrz	#tm1
	movi	#str_pl34,a4		;tm2
#tm1
	move	a11,@mess_cursx
	calla	print_string_C2

	move	a10,a0
	xori	1,a0
	sll	4,a0
	addi	#xpos,a0
	move	*a0,a11
	move	a11,a0				;x val
	sll	16,a0
	movi	[Y3-18,0],a1			;y val
	movi	chalneed_l,a2			;* image
	movi	19001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	TYPTEXT,a5			;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2

	movi	1*TSEC,a10
	CREATE	CNTDWN_PID,timeout2

	SLEEPK	2
	calla	display_unblank

#slp	SLEEP	20*TSEC				;15;13
	move	@PSTATUS,a0
	jrnz	#slp
#exit
	movi	-1,a0
	move	a0,@winningteam		;-1 for no valid half price
	RETP



#inits_setup
	PRINT_STR	bast18_ascii,8,0,X1,Y2,BST18Y_P,0

#str_pl12
	.string	"PLAYERS 1 - 2",0
#str_pl34
	.string	"PLAYERS 3 - 4",0
	.even

#xpos
	.word	X1+1,X2+1

#winner_mod
	.long	ENTERKITBMOD
	.word	0,0		;x,y
	.long	ATRIBUTEBMOD
	.word	0,178
	.long	0

#*****************************************************************************

 SUBR	buyin_screen


	move	@PSTATUS,a0
	move	a0,@plyrsdropped

	clr	a0
	move	a0,@pleasewt
	move	a0,@newplyrs,L

	move	@gmqrtr,a14
	cmpi	4,a14
	jrlt	#tag1
	move	@scores,a14
	move	@scores+16,a1
	cmp	a1,a14
	jrz	#tag1
#exit
	RETP
#tag1
	move	@PSTATUS,a9
	movi	qtr_purchased,a1	; - 1 quarter for each player
	clr	a2
#dec_loop
	move	*a1,a0
	jrz	#skip2
	dec	a0
	move	a0,*a1
	jrnz	#skip2
	movk	1,a0
	sla	a2,a0
	move	@PSTATUS,a3
	andn	a0,a3
	move	a3,@PSTATUS
#skip2
	addk	16,a1
	inc	a2
	cmpi	3,a2
	jrls	#dec_loop
	move	@PSTATUS,a0
	cmp	a0,a9
	jrnz	#cont
;But, if someone inserted coins, go to buyin_screen anyway!
	calla	CR_CONTP		;Credits to continue
	jrlo	#bx			;No?
   	move	@game_purchased,a0
	cmpi	>f,a0
	jrnz	#cont
#bx
	RETP

#cont
	clr	a0
	move	a0,@IRQSKYE		;background color

	clr	a0
	move	a0,@COLRTEMP,L
	move	a0,@dtype		;2D

	movk	1,a0			;page flipping on
	move	a0,@dpageflip

	movk	ININTRO,a0
	move	a0,@GAMSTATE

	movi	newplyrs,a0
	move	a0,@newptr,L

;setup new background
	movi	wipe_stack_vertical,a0,L
	movi	CREATE_NO_DEL_OBJS,a14		;dont delete objs. when done
	JSRP	do_scrn_transition

	SLEEPK	1

	calla	KILBGND			;Kill old background
	calla	pal_clean
	clr	a0
	movi	-1,a1
	calla	obj_delc		;Kill all objs (Screen mem is clr)
	clr	a0
	calla	KIL1C

	.ref	buyin_tune
	SOUND1	buyin_tune

	movi	SCRNEND,a0		;[256,405]
	move	a0,@SCRNLR,L
	clr	a0
	move	a0,@WORLDTLY,L
	move	a0,@WORLDTLX,L
	move	a0,@WORLDTL,L

	movi	#buyin_mod,a0
	move	@TWOPLAYERS,a1		;0 = NO, 1 = YES 2 players
	jrz	#not2
	movi	#buyin_kit_mod,a0
#not2
	move	a0,@BAKMODS,L
	calla	BGND_UD1
#yesh
	SLEEPK	2
;	calla	create_bits

	movi	TSEC,a10
	CREATE0	timeout3

	CREATE0	credits
	CREATE0	credit_messages

	movk	1,a0
	move	a0,@can_enter_inits	;if 0 deletes challenger messages

	movk	1,a10			;player 2
	CREATE0	ingame_mess
	CREATE0	challenger
	movk	2,a10			;player 3
	CREATE0	ingame_mess
	CREATE0	challenger

	move	@TWOPLAYERS,a0		;0 = NO, 1 = YES 2 players
	jrnz	#2_plyrs

	clr	a10			;player 1
	CREATE0	ingame_mess
	CREATE0	challenger
	movk	3,a10			;player 4
	CREATE0	ingame_mess
	CREATE0	challenger

#2_plyrs

	SLEEP	4
;	SLEEP	10

;wipe things off
	movi	un_wipe_horizontal,a0,L
	movi	NO_CREATE_DEL_OBJS,a14
	JSRP	do_scrn_transition
#wait
	SLEEPK	1
	move	@force_selection,a0
	jrz	#wait
	move	@PSTATUS,a0
	jrnz	#ok

;2/9/93
	calla	dropout_stats
	jauc	game_over

#ok	RETP


;#buyin2_mod
;	.long	ENTER4BMOD		;enter initials module
;	.word	0,0
;	.long	ATRIBUTEBMOD
;	.word	0,178		;x,y
;	.long	0
;
;#buyin2_kit_mod
;	.long	ENTERKITBMOD
;	.word	0,0		;x,y
;	.long	ATRBKITBMOD			;option screen background
;	.word	0,178		;x,y
;	.long	0

#buyin_mod
	.long	ENTER4BMOD		;enter initials module
	.word	0,0
	.long	ATRIBUTEBMOD
	.word	0,178
	.long	0

#buyin_kit_mod
	.long	ENTERKITBMOD
	.word	0,0
	.long	ATRBKITBMOD
	.word	0,178
	.long	0

#*****************************************************************************

 SUBR	blink_tmslct

	movi	[200,0],a0
	movi	[15,0],a1
	movi	PRESSBUTT,a2			;* image
	movi	19001,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	movi	0,a5				;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2

#lp
	SLEEP	90

	movi	PRESS_P,a0		;SGMD8RED,a0
	calla	pal_getf
	move	a0,*a8(OPAL)

	movi	PRESSTURB,a0		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image

	SLEEP	90

	movi	PRESS_P,a0		;SGMD8WHT,a0
	calla	pal_getf
	move	a0,*a8(OPAL)

	movi	PRESSBUTT,a0		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image


	SLEEP	90

	movi	PRESS2_P,a0		;SGMD8WHT,a0
	calla	pal_getf
	move	a0,*a8(OPAL)

	movi	PRESSPASS,a0		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	jruc	#lp


#*****************************************************************************

	.asg	50,YSPACE

 SUBR	grand_champs_screen


	clr	a10
#chk_nxt
	callr	#check_champ
;DJT Start
	jrnc	found_champ
;DJT End
	inc	a10
	cmpi	4,a10
	jrlt	#chk_nxt

	clr	a10
	RETP


;DJT Start
 SUBR	found_champ

 .if DEBUG
	movk	INPLYRINFO,a14
	move	a14,@GAMSTATE
 .endif

	move	*a13(PROCID),*a13(PDATA)
	movi	GRANDCHAMP_PID,a14
	move	a14,*a13(PROCID)

	clr	a14
	move	a14,@PSTATUS
	move	a14,@PSTATUS2
;DJT End

	calla	display_blank
	calla	WIPEOUT

	clr	a0
	move	a0,@HALT

;DJT Start
	movi	CHEERS,a8
;	movi	TROPHY,a8
;DJT End
	movi	[0,0],a9
	.ref	movie_run
	JSRP	movie_run

	movi	CLSDEAD|123,a0
	move	a0,@mess_objid
	movi	kern_chars,a0
	move	a0,@mess_justify,L	;justification method

;DJT Start
	.asg	       2,CC_BEG
	.asg	      18,CC_END
	.asg	       3,CC_RAT
	.asg	BRSHGYOP,CC_PAL

	.bss	cycram,(CC_END-CC_BEG+1)*16*2

	movi	CC_PAL,a8,L		;*pal
	movi	cycram,a9,L		;Get cycle RAM ptr
	movi	[CC_BEG,CC_END],a10,L	;1st,last color
	movk	CC_RAT,a11		;Rate
	.ref	COLCYC
	CREATE	CYCPID,COLCYC

;DJT End
	movi	#champ_mess_tbl,a9,L
	jruc	#ctnxt
#ctxt
	move	*a4+,a0,L
	move	a0,@message_ascii,L	;
	move	*a4+,a0			;space char width
	move	a0,@mess_space_width	;
	move	*a4+,a0			;spacing between chars
	move	a0,@mess_spacing	;
	move	*a4+,a0			;message cursor pos X
	move	a0,@mess_cursx2		;
	move	*a4+,a0			;message cursor pos Y
	move	a0,@mess_cursy		;
	move	*a4+,a0,L
	move	a0,@message_palette,L

	calla	print_string2b
#ctnxt
	move	*a9+,a4,L
	cmpi	4000,a4			;at end ?
	jrne	#ctxt			;br=no

	movk	1,a0
	move	a0,@DISPLAYON
	SLEEPK	1

	clr	a0
	move	a0,@DISPLAYON
	movk	1,a0			;page flipping on
	move	a0,@dpageflip
	SLEEPK	1
	clr	a0
	move	a0,@dpageflip
	calla	display_unblank

	SOUND1	tunegc_snd
	.ref	cheer_snd
	SOUND1	cheer_snd

;DJT Start
	SLEEP	10*TSEC
;DJT End

;	movi	5*TSEC,a10
;#lpzz	SLEEPK	1
;	calla	get_all_buttons_cur2
;	jrz	#nob
;	SOUND1	bounce_snd
;	jruc	#xb
;#nob	
;	dsj	a10,#lpzz
;#xb
;DJT Start
#found_champ1
;DJT End
	calla	display_blank
	calla	WIPEOUT


	movi	#vmod,a0
	move	a0,@BAKMODS,L
	calla	BGND_UD1

;print player nbr.
;
;	movi	#congrats_setup,a2	;print player X on line below
;	calla	setup_message
;	movi	CLSDEAD|123,a0
;	move	a0,@mess_objid
;	movi	YSPACE,a0
;	move	a0,@mess_line_spacing
;	movi	#player_str,a4
;	calla	copy_rom_string
;
;	move	a10,a0
;	move	@TWOPLAYERS,a1		;0 = NO, 1 = YES 2 players
;	jrnz	#iskit
;	inc	a0			;1,2,3,4
;#iskit					;1,2
;	movi	4,a1			;max value
;	calla	dec_to_asc
;	calla	concat_string
;
;	movi	100,a0
;	move	a0,@mess_cursx2
;	movi	kern_chars,a0
;	move	a0,@mess_justify,L	;justification method
;	calla	print_string2b

;start scrolling text

;DJT Start
	movi	#congrats_setup,a2
	calla	setup_message
	movi	CLSDEAD|123,a0
	move	a0,@mess_objid
	movi	kern_chars,a0
	move	a0,@mess_justify,L	;justification method

	movi	#grand_mess_tbl,a9,L
#txt
	move	@mess_cursy,a0
#txt1
	move	*a9+,a4,L
	cmpi	4001,a4			;spc case?
	jrne	#txt2
	addk	14,a0
	jruc	#txt1
#txt2
	cmpi	4000,a4			;at end ?
	jreq	#txtdn			;br=no

	addi	YSPACE,a0
	move	a0,@mess_cursy

	move	*a4+,a0,W
	move	a0,@mess_cursx2
	move	*a4+,a0,L
	move	a0,@message_palette,L

	calla	print_string2b
	jruc	#txt

#txtdn
	movi	-0c000h,a3		;scroll text up screen
	movi	OBJLST,a14
#lp
	move	*a14,a14,L
	jrz	#x
	move	*a14(OID),a2
	cmpi	CLSDEAD|123,a2
	jrne	#lp
	move	a3,*a14(OYVEL),L
	jruc	#lp
#x

;	movi	[18h,0],a0
;	movi	[2eh,0],a1
;	movi	TROPHYD1,a2		;* image
;	movi	19001,a3		;z pos
;	movi	DMAWNZ,a4		;DMA flags
;	clr	a5
;	clr	a6			;x vel
;	clr	a7			;y vel
;	calla	BEGINOBJ2

	movk	1,a0
	move	a0,@DISPLAYON
	move	a0,@dpageflip

	SLEEPK	8

;	SOUND1	tunegc_snd

	.ref	plyr_jscrowdsnd
	CREATE0	plyr_jscrowdsnd

	calla	display_unblank

	SLEEP	TSEC*18

	CREATE0	plyr_jscrowdsnd

	SLEEP	22*TSEC +7

	clr	a3			;turn off scroll
	movi	OBJLST,a14
#lp1
	move	*a14,a14,L
	jrz	#x1
	move	*a14(OID),a2
	cmpi	CLSDEAD|123,a2
	jrne	#lp1
	move	a3,*a14(OYVEL),L
	jruc	#lp1
#x1
	SLEEP	4*TSEC-8 -7

	.ref	tune_gmovr,pregame_tune,tuneend_snd
	SOUND1	pregame_tune

	.ref	show_designteam
	JSRP	show_designteam

	move	*a13(PDATA),*a13(PROCID)

	SOUND1	tune_gmovr
;DJT End

	movk	1,a10
	RETP


;a10 = player number (0-3)
#check_champ

	move	@PSTATUS,a0
	btst	a10,a0
	jrz	#fail

	move	a10,a0
	sll	5,a0
	addi	#pdata,a0
	move	*a0,a0,L			;* player data

	move	*a0(PR_NAME1),a1
	jrle	#fail
	move	*a0(PR_NUMDEF),a1
	cmpi	NUM_TEAMS,a1
	jrlt	#fail
	move	*a0(PR_NUMDEFOLD),a1
	cmpi	NUM_TEAMS,a1
	jrge	#fail

	clrc
	rets
#fail
	setc
	rets


#pdata
	.long	player1_data
	.long	player2_data
	.long	player3_data
	.long	player4_data


#vmod
	.long	BKGDBMOD
	.word	0,1
	.long	0


	.asg	200,X
	.asg	10+300,Y

#congrats_setup
;	PRINT_STR	bast18_ascii,10,0,X,Y,BSTGYG_P,0
;DJT Start
	PRINT_STR	hangfnt38_ascii,14,0,200,180,HANGF_Y_P,kern_chars
;DJT End
;	PRINT_STR	brush50_ascii,14,0,200,60,BRSH50R_P,kern_chars



;DJT Start
#champ_mess_tbl
	.long	#line1
	.long	#line2
	.long	#line3
	.long	#line3a
	.long	4000

#grand_mess_tbl
	.long	#line_blnk
	.long	#line4
	.long	#line4a
	.long	#line4b
	.long	#line5
	.long	#line5a
	.long	#line5b
	.long	#line_blnk
	.long	#line6
	.long	#line6a
	.long	#line7
	.long	#line7a
	.long	#line8
	.long	#line8a
	.long	#line9
	.long	#line9a
	.long	#line_blnk
	.long	#line12
	.long	#line12a
	.long	#line13
	.long	#line14
	.long	#line15
	.long	#line15a
	.long	#line_blnk
	.long	#line16
	.long	#line16a
	.long	#line_blnk
	.long	#line_blnk
	.long	#line10
	.long	#line11
	.long	4001
	.long	#line17
	.long	#line17a
	.long	4000


#line1
 .long	brush20_ascii	;font
 .word	10,0		;space width, spacing
 .word	24,197		;x,y
; .word	24,174		;x,y
 .long	BRSHGWKP ;_Y_P ;GYGP
 .string "Y",1,-4,"OU",1,-2,"'",1,1,"V",1,-2,"E "
 .string "GO",1,-2,"T"
 .string 0
 .even

#line2
 .long	brush20_ascii	;font
 .word	10,0		;space width, spacing
 .word	24,221		;x,y
 .long	BRSH_G_P
 .string "M",1,-1,"AX",1,-2,"I",1,-2,"M",1,-1,"U",1,-1,"M "
 .string "H",1,-4,"AN",1,-2,"G",1,-1,"T",1,-2,"I",1,-2,"M",1,-1,"E"
 .string "!",0
 .even

#line3
 .long	brush20_ascii	;font
 .word	10,0		;space width, spacing
 .word	194,14		;x,y
 .long	CC_PAL
 .string "Y",1,-4,"OU "
 .string "AR",1,-1,"E "
 .string "T",1,-3,"H",1,-2,"E"
 .string 0
 .even

#line3a
 .long	brush20_ascii	;font
 .word	10,0		;space width, spacing
 .word	128,38		;x,y
 .long	CC_PAL
 .string "GR",1,-1,"AN",1,-1,"D "
 .string "CH",1,-4,"AM",1,-1,"PI",1,-2,"ON",1,-1,"!"
 .string 0
 .even

;; .word	20,48		;x,y
;; .string "YOU ARE",0
;;; .string "Y",1,-5,"O",1,-2,"U",1,-2," ",1,-2,"AR",1,-5,"E"," ","T",1,-6,"H",1,-6,"E",0
;; .word	20,74		;x,y
;; .string "THE NBA",0
;;; .string "N",1,-6,"B",1,-5,"A",0
;; .word	20,100		;x,y
;; .string "HANGTIME",0
;;; .string "H",1,-6,"AN",1,-4,"GT",1,-5,"I",1,-5,"M",1,-5,"E",0
;; .word	20,126		;x,y
;; .string "GRAND",0
;;; .string "G",1,-4,"R",1,-4,"AN",1,-6,"D",0
;; .word	20,152		;x,y
;; .string "CHAMPION!",0
;;; .string "C",1,-5,"H",1,-7,"AM",1,-5,"P",1,-4,"I",1,-5,"O",1,-4,"N",1,-1,"!",0


#line_blnk
 .word	0
 .long	HANGF_Y_P
 .string "",0
 .even

#line4
 .word	26
 .long	HANGF_Y_P
 .string "T",1,-7,"H",1,-7,"E P",1,-5,"L",1,-1,"A",1,2,"Y",1,-7,"E",1,-6,"R",1,-3,"S"
 .string 0
 .even

#line4a
 .word	105
 .long	HANGF_Y_P
 .string "I",1,-6,"N N",1,-7,"B",1,-6,"A"
 .string 0
 .even

#line4b
 .word	58
 .long	HANGF_G_P
 .string "H",1,-7,"A",1,1,"N",1,-5,"G",1,1,"T",1,-7,"I",1,-6,"M",1,-7,"E"
 .string 0
 .even

#line5
 .word	62
 .long	HANGF_Y_P
 .string "T",1,-4,"U",1,-6,"R",1,-5,"N",1,-7,"E",1,-7,"D IT"
 .string 0
 .even

#line5a
 .word	79
 .long	HANGF_Y_P
 .string "U",1,-6,"P T",1,-5,"O G",1,-2,"O"
 .string 0
 .even

#line5b
 .word	48
 .long	HANGF_R_P
 .string "M",1,-7,"A",1,1,"X",1,-6,"I",1,-6,"M",1,-4,"U",1,-6,"M!"
 .string 0
 .even

#line6
 .word	72
 .long	HANGF_Y_P
 .string "B",1,-3,"UT N",1,-5,"O",1,-1,"W"
 .string 0
 .even

#line6a
 .word	70
 .long	HANGF_Y_P
 .string "Y",1,-8,"O",1,-2,"U H",1,-7,"A",1,1,"V",1,-8,"E"
 .string 0
 .even

#line7
 .word	69
 .long	HANGF_Y_P
 .string "D",1,-5,"E",1,-7,"F",1,-7,"E",1,-7,"A",1,1,"T",1,-7,"E",1,-7,"D"
 .string 0
 .even

#line7a
 .word	107
 .long	HANGF_Y_P
 .string "A",1,1,"L",1,-1,"L 2",1,-3,"9"
 .string 0
 .even

#line8
 .word	68
 .long	HANGF_Y_P
 .string "T",1,-7,"E",1,-7,"A",1,1,"M",1,-4,"S T",1,-1,"O"
 .string 0
 .even

#line8a
 .word	33
 .long	HANGF_Y_P
 .string "B",1,-5,"E",1,-5,"C",1,-2,"O",1,-4,"M",1,-7,"E T",1,-7,"H",1,-7,"E"
 .string 0
 .even

#line9
 .word	33
 .long	HANGF_R_P
 .string "N",1,-7,"E",1,-2,"W G",1,-4,"R",1,-4,"A",1,1,"N",1,-7,"D"
 .string 0
 .even

#line9a
 .word	43
 .long	HANGF_R_P
 .string "C",1,-5,"H",1,-7,"A",1,1,"M",1,-6,"P",1,-5,"I",1,-5,"O",1,-5,"N!"
 .string 0
 .even

#line12
 .word	65
 .long	HANGF_G_P
 .string "M",1,-6,"I",1,-7,"DW",1,-11,"A",1,2,"Y",1,2,"'",1,-2,"S"
 .string 0
 .even

#line12a
 .word	26
 .long	HANGF_Y_P
 .string "N",1,-7,"E",1,-7,"X",1,1,"T B",1,4,"'",1,-3,"B",1,-6,"A",1,1,"L",1,-1,"L"
 .string 0
 .even

#line13
 .word	45
 .long	HANGF_Y_P
 .string "C",1,-5,"H",1,-7,"A",1,1,"L",1,-1,"L",1,-1,"E",1,-7,"N",1,-5,"G",1,-5,"E"
 .string 0
 .even

#line14
 .word	62
 .long	HANGF_Y_P
 .string "W",1,-6,"I",1,-7,"L",1,-1,"L H",1,-7,"A",1,1,"V",1,-8,"E"
 .string 0
 .even

#line15
 .word	108
 .long	HANGF_Y_P
 .string "A N",1,-7,"E",1,-2,"W"
 .string 0
 .even

#line15a
 .word	48
 .long	HANGF_Y_P
 .string "D",1,-4,"I",1,-6,"M",1,-7,"E",1,-7,"N",1,-6,"S",1,-4,"I",1,-4,"O",1,-5,"N"
 .string 0
 .even

#line16
 .word	96
 .long	HANGF_R_P
 .string "A T",1,-7,"H",1,-7,"I",1,-6,"R",1,-5,"D"
 .string 0
 .even

#line16a
 .word	48
 .long	HANGF_R_P
 .string "D",1,-4,"I",1,-6,"M",1,-7,"E",1,-7,"N",1,-6,"S",1,-4,"I",1,-4,"O",1,-5,"N"
 .string 0
 .even

#line10
 .word	49
 .long	HANGF_Y_P
 .string "T",1,-7,"H",1,-7,"A",1,1,"N",1,-7,"K Y",1,-8,"O",1,-2,"U"
 .string 0
 .even

#line11
 .word	16
 .long	HANGF_Y_P
 .string "F",1,-5,"O",1,-4,"R P",1,-5,"L",1,-1,"A",1,1,"Y",1,-6,"I",1,-7,"N",1,-5,"G!"
 .string 0
 .even

#line17
 .word	26
 .long	HANGF_G_P
 .string "Y",1,-8,"O",1,-2,"U H",1,-7,"A",1,1,"V",1,-8,"E",1,-7,"N",1,1,"'",1,2,"T"
 .string 0
 .even

#line17a
 .word	24
 .long	HANGF_G_P
 .string "S",1,-5,"E",1,-7,"E",1,-7,"N IT A",1,1,"L",1,-1,"L!"
 .string 0
 .even


; .string "Y",1,-5,"O",1,-2,"U",1,1," ",1,1,"H",1,-7,"A",1,2,"V",1,-7,"E",0
; .string "D",1,-5,"E",1,-6,"F",1,-6,"E",1,-6,"A",1,1,"T",1,-6,"E",1,-5,"D",0
; .string "AL",1,-1,"L",1,2," ","2",1,-1,"9",0
; .string "N",1,-6,"B",1,-5,"A",1,1," ","T",1,-6,"E",1,-6,"A",1,1,"M",1,-4,"S",0
;
; .string "B",1,-3,"U",1,-1,"T"," ","A",0
; .string "G",1,-4,"R",1,-5,"E",1,-7,"AT",1,-6,"E",1,-5,"R",0
; .string "C",1,-4,"H",1,-6,"ALL",1,-2,"E",1,-5,"N",1,-3,"G",1,-4,"E",0
; .string "A",1,1,"W",1,-11,"A",1,1,"IT",1,-5,"S",0
;
; .string "C",1,-3,"O",1,-3,"M",1,-5,"I",1,-5,"N",1,-4,"G",0
; .string "S",1,-3,"O",1,-2,"O",1,-4,"N",0
;
; .string "N",1,-6,"B",1,-5,"A",0
; .string "M",1,-7,"A",1,-1,"X",1,-5,"I",1,-5,"M",1,-3,"U",1,-5,"M",0
; .string "H",1,-6,"AN",1,-4,"GT",1,-5,"I",1,-5,"M",1,-5,"E",0
;
; .string "A",1,2,"V",1,-14,"A",1,1,"I",1,-6,"L",1,-2,"AB",1,-4,"L",1,-1,"E",0
; .string "N",1,-4,"O",1,2,"V",1,-2,"."," ",1,2,"1",1,1,".",0
;
; .string "T",1,-6,"H",1,-7,"AN",1,-6,"K"," ","Y",1,-6,"O",1,-2,"U",0
; .string "F",1,-4,"O",1,-4,"R"," ","P",1,-4,"L",1,-2,"A",1,1,"Y",1,-5,"I",1,-5,"N",1,-4,"G",0
;DJT End


;#congrats_str
;	.string	"congratulations!",1
;	.string	"",1
;	.string	"",1
;	.string	"",1
;	.string	"you have defeated",1
;	.string	"all 29 nba teams!",1
;	.string	"",1
;	.string	"",1
;	.string	"",1
;	.string	"You are the new",1
;	.string	"NBA hangtime",1
;	.string	"grand champion!",1
;	.string	"",1
;	.string	"",1
;	.string	"you are an incredible",1
;	.string	"player and one of the",1
;	.string	"best nba hangtime",1
;	.string	"stars of all time!",1
;	.string	"",1
;	.string	"",1
;	.string	"however, this is a",1
;	.string	"midway game!  Which",1
;	.string	"means that there is yet",1
;	.string	"a greater challenge",1
;	.string	"awaiting you . . .",1
;	.string	"",1
;	.string	"Play on . . .",1
;	.string	"",1
;	.string	"",1
;	.string	"thank you for playing",1
;	.string	"nba hangtime!",1
;	.string	"",0
;	.even


#player_str
	.string	"PLAYER ",0
	.even



******************************************************************************
#*****************************************************************************
;check if all credits have been sucked up (that can be)
;
; 0  = not all credits sucked up
; !0 = all credits sucked up

 SUBR	check_suckup

	move	@gmqrtr,a0
	cmpi	2,a0
	jrz	#not_enough

	movk	ADJFREPL,a0
	calla	GET_ADJ 	;SEE IF FREEPLAY......(Z BIT CLEAR IF SO!)
	jrnz	#free_play

	calla	CRED_P			;get number credits
	move	a0,a3
	movi	ADJCSTRT,a0		;# credits to start
	calla	GET_ADJ
	divu	a0,a3			;credits / credits to continue
	move	a3,a3
	jrz	#not_enough

	clr	a4
#next
	move	@PSTATUS,a0
	btst	a4,a0
	jrz	#no_player

	move	@game_purchased,a0
	btst	a4,a0
	jrz	#not_purchased

#no_player
	inc	a4
	cmpi	4,a4
	jrlt	#next

#not_enough			;to continue
#free_play			;so no suckup required
	movk	1,a0
	move	a0,a0
	rets


#not_purchased
	clr	a0
	rets


;============================================================
;============================================================
attrib_off
	PUSH	a8
	movk	9,a0
#atlp1
	move	*a2+,a8,L
	PUSH	a0,a2
	calla	obj_off
	PULL	a0,a2
	dsj	a0,#atlp1
	PULL	a8
	rets

;============================================================
;============================================================
attrib_on
	PUSH	a8
	movk	9,a0
#atlp2
	move	*a2+,a8,L
	PUSH	a0,a2
	calla	obj_on
	PULL	a0,a2
	dsj	a0,#atlp2
	PULL	a8
	rets

;-----------------------------------------------------------------------------
; JBJ -- updated to accout for less attributes (6)
;-----------------------------------------------------------------------------
update_attribs
	move	a6,a6			;special head ?
	jrnn	#norm2			;br=yes, exit

	movk	6,a0			;# attribs. to update
#udlp
	move	*a11+,a8,L		;a11 points to attribute obj ptrs.
	move	*a10+,a1		;a1=attribute value (0-10)

	.if	DEBUG
	cmpi	10,a1
	jrle	#ok
	LOCKUP
#ok
	.endif

	PUSH	a0,a10,a11


;;;Special head?
;;	move	a6,a6
;;	jrn	#norm
;;;Yes, hide stats!
;;	movk	11,a1
#norm

	sll	5,a1			;x32 (index into below table)
	addi	attrib_imgs,a1
	move	*a1,a0,L
;;;;	movi	DMAWNZ,a1		;DMA flags
;;;;	calla	obj_aniq		;change object image
;
; Here I update the attribute 'bar' img. for this object to a new one.
;
	move	a0,*a8(OIMG),L			;update img. pointer
	move	*a0(0),*a8(OSIZE),L		;update size
	move	*a0(ISAG),*a8(OSAG),L		;update source addr.

	move	*a0(ICTRL),a1		     ;get bits per pixel...(ctrl data)
	move	*a8(OCTRL),a14			;get current ctrl data
	andi	>8fff,a14			;clear bits (12-14)
	or	a1,a14				;set bits (12-14)
	move	a14,*a8(OCTRL)			;update 'ctrl' data

	PULL	a0,a10,a11
	dsj	a0,#udlp
#norm2	rets


attrib_imgs
	.long	ATTBAR01	;0
	.long	ATTBAR01	;1
	.long	ATTBAR02	;2
	.long	ATTBAR03
	.long	ATTBAR04
	.long	ATTBAR05
	.long	ATTBAR06
	.long	ATTBAR07
	.long	ATTBAR08
	.long	ATTBAR09
	.long	ATTBAR10	;10
	.long	ATTBAR10	;10


;;============================================================
;;============================================================
; SUBR	del_box_imgs
;
;	movi	CLSDEAD|123,a0
;	calla	obj_del1c		;delete text cpu subs
;
;	move	@teamset1_obj,a0,L
;	calla	DELOBJ	
;	move	@teamset2_obj,a0,L
;	calla	DELOBJ	
;	move	@name1_obj,a0,L
;	calla	DELOBJ	
;	move	@name2_obj,a0,L
;	calla	DELOBJ	
;	move	@name3_obj,a0,L
;	calla	DELOBJ	
;	move	@name4_obj,a0,L
;	calla	DELOBJ	
;
;	movk	9,a11
;	movi	attrib1_obj,a10
;	movi	attrib2_obj,a9
;	movi	attrib3_obj,a8
;	movi	attrib4_obj,a7
;
;#lp	move	*a10+,a0,L
;	calla	DELOBJ
;	move	*a9+,a0,L
;	calla	DELOBJ
;	move	*a8+,a0,L
;	calla	DELOBJ
;	move	*a7+,a0,L
;	calla	DELOBJ
;	dsjs	a11,#lp
;
;	movi	BAKLST,a14
;
;#lp2	move	a14,a3		;A3=*Prev
;	move	*a14,a14,L	;A14=*Next
;	jrz	#x
;#cmp	move	*a14(OZPOS),a2
;	cmpi	60,a2
;	jrz	#kil
;	cmpi	61,a2
;	jrne	#lp2
;#kil
;
;	move	*a14,*a3,L	;Unlink from obj list
;
;	move	@OFREE,*a14+,L	;Add to free list
;	subk	32,a14
;	move	a14,@OFREE,L
;	move	*a3,a14,L
;	jrnz	#cmp
;#x
;	move	@credit1_obj,a0,L
;	calla	DELOBJ
;	move	@credit2_obj,a0,L
;	calla	DELOBJ
;	move	@credit3_obj,a0,L
;	calla	DELOBJ
;	
;	clr	a0
;	callr	create_credits
;
;	rets

#******************************************************************************

 SUBR	brown_shadow
 	rets

;	movi	NBAPAL,a0
;	calla	pal_find
;	andi	0ff00h,a0
;	move	a0,a10
;
;;	callr	obj_ckpal
;;	rets
;
;
;	move	a10,a1			;dest pal
;	ori	52,a1	;26*16,a1	;26
;	movi	#brown_shad,a0		;pal data
;	movk	3,a2			;3 colours
;	calla	pal_set
;	rets
;
;#brown_shad
;	.word	11<<10+5<<5+0
;	.word	9<<10+3<<5+0
;	.word	7<<10+2<<5+0
;
;obj_ckpal
;	movi	OBJLST,a14
;	movi	kp_ram,a2
;	clr	a1
;	move	a1,*a2,L
;
;#lp
;	move	*a14,a14,L	;A14=*Next
;	jrz	#x
;	move	*a14(OPAL),a1
;	cmp	a0,a1
;	jrne	#lp
;
;	move	a14,*a2+,L
;	clr	a1
;	move	a1,*a2,L
;	jruc	#lp
;
;#x
;	movi	kp_ram,a2
;#lp2
;	move	*a2+,a0,L
;	jrz	#xx
;	calla	DELOBJ
;	jruc	#lp2
;#xx
;	rets


#******************************************************************************

 SUBR	blue_shadow
	rets
;	movi	wood64b,a0		;NBAPAL,a0
;	calla	pal_find
;;	andi	0ff00h,a0
;	move	a0,a10
;
;
;	callr	obj_ckpal
;
;	movi	NBAPAL,a0		;NBAPAL,a0
;	calla	pal_find
;;	andi	0ff00h,a0
;	move	a0,a10
;
;
;	callr	obj_ckpal
;	rets
;
;
;	move	a10,a1			;dest pal
;	ori	52,a1	;26*16,a1	;26
;	movi	#blue_shad,a0		;pal data
;	movk	3,a2			;3 colours
;	calla	pal_set
;	rets
;
;#blue_shad
;	.word	0<<10+3<<5+6	;2
;	.word	0<<10+2<<5+4	;6
;	.word	0<<10+0<<5+0	;52


#*****************************************************************************
;challenger needed / teammate needed message
;on name entry screen
;a10 = player (0-3)

;;	.asg	105,CHALLY
	.asg	88,CHALLY

 SUBR	challenger

	move	a10,a0
	sll	4,a0
	addi	#chall_x,a0
	move	@TWOPLAYERS,a1		;0 = NO, 1 = YES 2 players
	jrz	#not_2p
	addi	4*16,a0
#not_2p
	move	*a0,a0
	sll	16,a0			;x val
	movi	[CHALLY,0],a1		;y val
;	move	@gmqrtr,a2
;	cmpi	2,a2
;	jrnz	#skp
;	movi	[CHALLY+256,0],a1	;y val
#skp
	movi	CHALENG,a2		;* image
	movi	1000,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2

#isoff
	calla	obj_off
	SLEEPK	1
	move	@PSTATUS,a0
	btst	a10,a0
	jrz	#ison

	move	@PSTATUS,a0
	btst	a10,a0

	jrnz	#isoff
#ison
	move	@PSTATUS2,a0
	btst	a10,a0
	jrz	#ison2

	movi	continue,a0		;* image
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	calla	obj_on

#wait
	move	@can_enter_inits,a0	;finished initials entry?
	jrz	#done
	SLEEPK	1
	move	@PSTATUS,a0
	btst	a10,a0
	jrz	#wait
#ison2
	calla	obj_on
#loop
	SLEEPK	1

	move	@can_enter_inits,a0	;finished initials entry?
	jrz	#done

	move	@PSTATUS,a0
	btst	a10,a0
	jrnz	#isoff

	move	@PCNT,a0		;frame count
	btst	6,a0
	jrnz	#nojoin

	movi	join3,a0		;* image
	jruc	#join
#nojoin
	movi	CHALENG,a0		;* image
	move	a10,a1
	xori	1,a1			;teammate bit
	move	@PSTATUS,a2
	btst	a1,a2
	jrz	#ischall
	movi	TMATE,a0		;* image
#ischall
#join
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image
	jruc	#loop
#done
	calla	DELOBJA8
	DIE


#chall_x	.word	55,150,249,344	;x val
		.word	0,101,295,0	;x val  for KIT


#*****************************************************************************
;challenger needed message
;on team selection screen
;a10 = team (0-1)

	.asg	160-14+TEAMSEL_PAGE,CHALLY
;;;;	.asg	172-14+TEAMSEL_PAGE,CHALLY

 SUBR	challenger2

	move	a10,a0
	sll	4,a0
	addi	#chall_x,a0
	move	*a0,a0
	sll	16,a0			;x val
	movi	[CHALLY,0],a1		;y val
	movi	CHALENG,a2		;* image
	movi	1000,a3			;z pos
	movi	DMAWNZ,a4		;DMA flags
	clr	a5			;object ID
	clr	a6			;x vel
	clr	a7			;y vel
	calla	BEGINOBJ2

	move	a10,a11			;(0-1)
	sll	4,a11			;x 16 bits
	addi	team1,a11		;team1 or team2
#isoff
	calla	obj_off
	SLEEPK	1
	move	*a11,a0
	jrnn	#isoff

	calla	obj_on
#loop
	SLEEPK	1
	move	*a11,a0
	jrnn	#isoff

	movi	CHALENG,a0		;* image
	move	@PCNT,a1		;frame count
	btst	6,a1
	jrnz	#nojoin
	movi	join3,a0		;* image
#nojoin
	movi	DMAWNZ,a1		;DMA flags
	calla	obj_aniq		;change object image

	jruc	#loop

#chall_x	.word	101,295		;x val


#*****************************************************************************

 SUBR	drw_chicks
 	RETP



;;;;;;;;;;TABLES;;;;;;;;;;;;;
;;;;;;;;;;TABLES;;;;;;;;;;;;;
;;;;;;;;;;TABLES;;;;;;;;;;;;;
;;;;;;;;;;TABLES;;;;;;;;;;;;;

;DJT plyr_names_img_tbl removed to ATTRACT
matchup_mod
	.long	BKGDBMOD
	.word	0,0		;x,y
	.long	VSSCRBMOD
	.word	0,10		;x,y
	.long	0

bsd_stat_str_setup
;DJT Start
	PRINT_STR	bast8_ascii,5,0,200,197,BAST_Y_P,0
;DJT End

bsd_stat_str
	.string	"BASED ON STATS:",0
	.even

favored_by_str
	.string	" FAVORED BY ",0
	.even


tnght_mat_str_setup
	PRINT_STR	brush20_ascii,13,0,200,7,BRSHGYOP,0

tonght_matchup_str
	.string	"TONIGHT'S MATCHUP",0
	.even


tm1_cty_str_setup
	PRINT_STR	bast10_ascii,8,0,80,44,BAST_W_P,0

tm1_nme_str_setup
;	PRINT_STR	bast18_ascii,8,0,80,59,BSTGWW_P,0
	PRINT_STR	brush20_ascii,8,0,80,59,BRSHGWKP,0

tm2_cty_str_setup
	PRINT_STR	bast10_ascii,8,0,310,44,BAST_W_P,0

tm2_nme_str_setup
;	PRINT_STR	bast18_ascii,8,0,310,59,BSTGWW_P,0
	PRINT_STR	brush20_ascii,8,0,310,59,BRSHGWKP,0


city_names_str_tbl
	.long	atl_str,atl2_str
	.long	bos_str,bos2_str
	.long	cha_str,cha2_str
	.long	chi_str,chi2_str
	.long	cle_str,cle2_str
	.long	dal_str,dal2_str
	.long	den_str,den2_str
	.long	det_str,det2_str
	.long	gol_str,gol2_str
	.long	hou_str,hou2_str
	.long	ind_str,ind2_str
	.long	cli_str,cli2_str
	.long	lak_str,lak2_str
	.long	mia_str,mia2_str
	.long	mil_str,mil2_str
	.long	min_str,min2_str
	.long	new_str,new2_str
	.long	ney_str,ney2_str
	.long	orl_str,orl2_str
	.long	phi_str,phi2_str
	.long	pho_str,pho2_str
	.long	por_str,por2_str
	.long	sac_str,sac2_str
	.long	san_str,san2_str
	.long	sea_str,sea2_str
	.long	tor_str,tor2_str
	.long	uta_str,uta2_str
	.long	van_str,van2_str
	.long	was_str,was2_str
			   

atl_str
	.string	"ATLANTA",0
atl2_str
	.string	"HAWKS",0
bos_str
	.string	"BOSTON",0
bos2_str
	.string	"CELTICS",0
cha_str
	.string	"CHARLOTTE",0
cha2_str
	.string	"HORNETS",0
chi_str
	.string	"CHICAGO",0
chi2_str
	.string	"BULLS",0
cle_str
	.string	"CLEVELAND",0
cle2_str
	.string	"CAVALIERS",0
dal_str
	.string	"DALLAS",0
dal2_str
	.string	"MAVERICKS",0
den_str
	.string	"DENVER",0
den2_str
	.string	"NUGGETS",0
det_str
	.string	"DETROIT",0
det2_str
	.string	"PISTONS",0
gol_str
	.string	"GOLDEN STATE",0
gol2_str
	.string	"WARRIORS",0
hou_str
	.string	"HOUSTON",0
hou2_str
	.string	"ROCKETS",0
ind_str
	.string	"INDIANA",0
ind2_str
	.string	"PACERS",0
cli_str
	.string	"LOS ANGELES",0
cli2_str
	.string	"CLIPPERS",0
lak_str
	.string	"LOS ANGELES",0
lak2_str
	.string	"LAKERS",0
mia_str
	.string	"MIAMI",0
mia2_str
	.string	"HEAT",0
mil_str
	.string	"MILWAUKEE",0
mil2_str
	.string	"BUCKS",0
min_str
	.string	"MINNESOTA",0
min2_str
	.string	"T'WOLVES",0
new_str
	.string	"NEW JERSEY",0
new2_str
	.string	"NETS",0
ney_str
	.string	"NEW YORK",0
ney2_str
	.string	"KNICKS",0
orl_str
	.string	"ORLANDO",0
orl2_str
	.string	"MAGIC",0
phi_str
	.string	"PHILADELPHIA",0
phi2_str
	.string	"76ERS",0
pho_str
	.string	"PHOENIX",0
pho2_str
	.string	"SUNS",0
por_str
	.string	"PORTLAND",0
por2_str
	.string	"TRAILBLZRS",0
sac_str
	.string	"SACRAMENTO",0
sac2_str
	.string	"KINGS",0
san_str
	.string	"SAN ANTONIO",0
san2_str
	.string	"SPURS",0
sea_str
	.string	"SEATTLE",0
sea2_str
	.string	"SONICS",0
uta_str
	.string	"UTAH",0
uta2_str
	.string	"JAZZ",0
tor_str
	.string	"TORONTO",0
tor2_str
	.string	"RAPTORS",0
van_str
	.string	"VANCOUVER",0
van2_str
	.string	"GRIZZLIES",0
was_str
	.string	"WASHINGTON",0
was2_str
	.string	"BULLETS",0
	.even



;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
logos
	.long	T_HAWKS		; 0 ATLANTA	(124)
	.long	T_CELTS		; 1 BOSTON
	.long	T_HORS		; 2 CHARLOTTE
	.long	T_BULLS		; 3 CHICAGO
	.long	T_CAVS		; 4 CLEVELAND
	.long	T_MAVS		; 5 DALLAS
	.long	T_NUGS		; 6 DENVER
;DJT Start
	.long	T_PISS_N	; 7 DETROIT
;DJT End
	.long	T_WARS		; 8 GOLDEN STATE
	.long	T_ROCKS		; 9 HOUSTON
	.long	T_PACER		;10 INDIANA
;FIXX!!!
	.long	T_LAKS		;12 LOS ANGELES (LAKERS)
	.long	T_CLIPS		;11 LOS ANGELES (CLIPPERS)
;FIXX!!!
	.long	T_HEAT		;13 MIAMI
	.long	T_BUCKS		;14 MILWAUKEE
;DJT Start
	.long	T_TWOLV_N	;15 MINNESOTA
;DJT End
	.long	T_NETS		;16 NEW JERSEY
	.long	T_KNIKS		;17 NEW YORK
	.long	T_MAGIC		;18 ORLANDO
	.long	T_76RS		;19 PHILADELPHIA
	.long	T_SUNS		;20 PHOENIX
	.long	T_BLAZ		;21 PORTLAND
	.long	T_KINGS		;22 SACRAMENTO
	.long	T_SPURS		;23 SAN ANTONIO
	.long	T_SONICS	;24 SEATTLE
	.long	T_RAPT		;25 TORONTO
;DJT Start
	.long	T_JAZZ_N	;26 UTAH
;DJT End
	.long	T_GRIZZ		;27 VANCOUVER
	.long	T_BULTS		;28 WASHINGTON	(150)
;FIX!!! Defeated all teams special logo
	.long	T_BULTS		; Special team

;-----------------------------------------------------------------------------
;    This TABLE has the following format: ptr. to city name img, team number
;
; Its used for the CURSOR control on the new team select screen
;-----------------------------------------------------------------------------
	LW	city_tor,_TOR
	LW	city_uta,_UTA
	LW	city_van,_VAN
	LW	city_was,_WAS
city_table_start
	LW	city_atl,_ATL
	LW	city_bos,_BOS
	LW	city_cha,_CHA
	LW	city_chi,_CHI
	LW	city_cle,_CLE
	LW	city_dal,_DAL
	LW	city_den,_DEN
	LW	city_det,_DET
	LW	city_gol,_GOL
	LW	city_hou,_HOU
	LW	city_ind,_IND
	LW	city_lac,_LAC
	LW	city_lal,_LAL
;;	LW	city_los,_LOS
	LW	city_mia,_MI
	LW	city_mil,_MIL
	LW	city_min,_MIN
	LW	city_nej,_NJ
	LW	city_ney,_NY
	LW	city_orl,_ORL
	LW	city_phi,_PHI
	LW	city_pho,_PHX
	LW	city_por,_POR
	LW	city_sac,_SAC
	LW	city_san,_SAN
	LW	city_sea,_SEA
	LW	city_tor,_TOR
	LW	city_uta,_UTA
	LW	city_van,_VAN
	LW	city_was,_WAS
city_table_end
	LW	city_atl,_ATL
	LW	city_bos,_BOS
	LW	city_cha,_CHA
	LW	city_chi,_CHI
	LW	city_cle,_CLE
	LW	city_dal,_DAL
	LW	city_den,_DEN
city_table_end2

	
********NOTE***************************************************************
*  IF this table is messed with, 'name_sort' table must be updated as well
*     and vice versa
********NOTE***************************************************************
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
player_attribs
;
; LAST TWO ATTRIBUTES ARE NOW IGNORED
;

;DJT Start
;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;00 ATLANTA HAWKS

	.word  09,02,07,00
	.word  09,01,07,09	;MOOKIE BLAYLOCK	6'1"	185 reg 

	.word  06,09,04,08
	.word  05,10,03,07	;DIKEMBE MUTOMBO	7'2"	245 reg

	.word  07,05,08,05
	.word  05,02,04,06	;STEVE SMITH		6'8"	208 reg

	.word  07,06,07,03
	.word  05,05,05,08	;CHRISTIAN LAETTNER	6'11"	235 reg

	.word  07,04,06,06
	.word  04,05,04,02	;KEN NORMAN		6'8"	223 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;01 BOSTON CELTICS

	.word  08,02,05,07 
	.word  07,01,05,02	;DEE BROWN		6'1"	161 reg
;new
	.word  06,07,07,05
	.word  03,07,06,01	;STEVE HAMER		_______________

	.word  09,01,09,01
	.word  07,01,06,05	;DANA BARROS		5'11"	165 reg

	.word  07,08,07,07
	.word  07,09,01,06	;DINO RADJA		6'11"	225 thin 

	.word  05,09,07,05
	.word  08,05,07,07	;RICK FOX		6'7"	231 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;02 CHARLOTTE HORNETS

	.word  07,05,10,05
	.word  06,02,02,09	;GLEN RICE		6'8"	220 reg

	.word  06,09,06,05
	.word  03,03,04,06	;ANTHONY MASON		6'7"	250 fat

	.word  05,08,04,04
	.word  05,09,06,02	;VLADE DIVAC		7'1"	260 thin

	.word  03,08,04,04
	.word  02,07,03,02	;GEORGE ZIDEK		_______________

	.word  08,02,07,01
	.word  08,01,04,07	;DELL CURRY		6'5"	200 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;03 CHICAGO BULLS

	.word  08,06,08,09
	.word  09,08,07,08	;SCOTTIE PIPPEN		6'7"	225 thin

	.word  07,09,01,04
	.word  05,07,04,03	;DENNIS RODMAN		6'8"	210 thin

	.word  07,05,07,06
	.word  07,05,08,10	;TONI KUKOC		6'11"	230 ex thin

	.word  05,08,05,03
	.word  02,07,06,02	;LUC LONGLEY		7'2"	265 fat

	.word  06,02,09,00
	.word  06,01,04,08	;STEVE KERR		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;04 CLEVELAND CAVALIERS

	.word  06,08,06,06
	.word  03,06,04,07	;TYRONE HILL		6'9"	245 reg

	.word  07,05,07,03
	.word  04,05,04,02	;CHRIS MILLS		6'6"	216 fat

	.word  08,05,07,01
	.word  08,04,07,02	;BOBBY PHILLS		6'5"	217 reg

	.word  09,02,08,01
	.word  08,01,07,09	;TERRELL BRANDON	6'0"	180 thin

	.word  04,07,07,02
	.word  05,02,05,08	;DANNY FERRY		6'10"	245 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;05 DALLAS MAVERICKS

	.word  09,04,04,05
	.word  06,06,08,08	;JASON KIDD		_______________

	.word  06,05,06,01
	.word  07,01,05,05	;DEREK HARPER		6'4"	206 reg

	.word  07,04,07,05
	.word  05,04,05,07	;JIM JACKSON		6'6"	220 reg

	.word  04,08,03,07
	.word  01,06,03,03	;ERIC MONTROSS		_______________

	.word  08,03,09,08
	.word  04,07,05,09	;JAMAL MASHBURN		6'8"	240 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;06 DENVER NUGGETS

	.word  07,01,06,07
	.word  05,07,03,07	;ANTONIO McDYESS	_______________

	.word  04,05,08,01
	.word  08,01,02,07	;SARUNAS MARCIULIONIS	6'5"	215 reg

	.word  07,04,06,01
	.word  09,04,09,04	;MARK JACKSON		6'3"	192 fat

	.word  07,06,08,02
	.word  06,01,05,08	;DALE ELLIS		6'7"	215 reg
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;07 DETROIT PISTONS

	.word  09,05,08,08
	.word  08,05,08,09	;GRANT HILL		_______________
;new
;;	.word  07,03,08,03
;;	.word  07,05,06,02	;RON RILEY		_______________

	.word  06,04,08,00
	.word  06,01,08,09	;JOE DUMARS		6'3"	195 thin

	.word  07,09,05,07
	.word  04,07,05,02	;OTIS THORPE		6'10"	246 reg

	.word  08,03,05,07
	.word  06,02,04,08	;STACEY AUGMON		6'8"	205 thin
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;08 GOLDEN STATE WARRIORS

	.word  09,04,08,08
	.word  07,02,04,08	;LATRELL SPREWELL	6'5"	190 ex thin

	.word  04,06,05,07
	.word  03,05,03,02	;JON KONCAK		7'0"	250 reg

	.word  07,07,07,09
	.word  07,08,02,03	;JOE SMITH		_______________

	.word  04,05,09,02
	.word  08,04,07,08	;CHRIS MULLIN		6'7"	215 reg
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;09 HOUSTON ROCKETS

	.word  07,10,07,08
	.word  07,10,07,07	;HAKEEM OLAJUWON	7'0"	255 reg
;new
	.word  04,09,04,06
	.word  02,08,04,02	;OTHELLA HARRINGTON	_______________

	.word  07,03,08,09
	.word  08,02,08,08	;CLYDE DREXLER		6'7"	222 thin

	.word  05,09,05,07
	.word  04,04,01,04	;KEVIN WILLIS		7'0"	240 reg
;kill (MAYBE!!!)
;Kenny Smith
	.word  06,04,06,01
	.word  07,01,07,04	;KENNY SMITH		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;10 INDIANA PACERS
;LOOK!!!
	.word  07,04,09,06
	.word  06,05,05,10	;REGGIE MILLER		6'7"	185 ex thin
;new
	.word  04,08,07,07
	.word  03,07,04,02	;ERICK DAMPIER		_______________

	.word  09,04,06,06
	.word  08,06,08,09	;JALEN ROSE		_______________

	.word  06,09,07,03
	.word  04,06,02,09	;RIK SMITS		7'4"	265 ex thin

	.word  05,06,04,06
	.word  05,08,02,02	;DALE DAVIS		6'11"	230 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;11 L.A. CLIPPERS

	.word  05,07,07,06
	.word  06,06,01,08	;LOY VAUGHT		6'9"	240 reg

	.word  06,08,05,05
	.word  02,03,02,05	;RODNEY ROGERS		_______________

	.word  08,05,06,05
	.word  08,04,06,09	;LAMOND MURRAY		_______________

	.word  08,01,04,01
	.word  08,01,08,02	;POOH RICHARDS		_______________

	.word  08,05,06,09
	.word  06,04,05,08	;BRENT BARRY		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;12 L.A. LAKERS

	.word  10,02,07,01
	.word  06,01,08,09	;NICK VAN EXEL		6'1"	170 ex thin

	.word  08,03,09,07
	.word  08,02,02,08	;CEDRIC CEBALLOS	6'7"	220 thin

	.word  07,04,08,01
	.word  04,03,04,09	;BYRON SCOTT		6'4"	235 fat

	.word  06,05,05,06
	.word  08,09,01,03	;ELDON CAMPBELL		6'11"	230 ex thin

	.word  08,04,07,05
	.word  04,07,08,02	;EDDIE JONES		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;13 MIAMI HEAT

	.word  08,10,06,09
	.word  04,09,03,07	;ALONZO MOURNING	6'10"	240 reg

	.word  09,05,07,00
	.word  08,01,08,06	;TIM HARDAWAY		6'0"	195 reg

	.word  05,05,08,02
	.word  04,05,05,04	;SASHA DANILOVIC	_______________
;kill
	.word  00,00,00,00
	.word  00,00,00,00
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;14 MILWAUKEE BUCKS

	.word  08,05,07,08
	.word  05,07,04,06	;VIN BAKER		6'11"	234 thin
;new
	.word  09,02,08,06
	.word  06,02,05,08	;RAY ALLEN		_______________

	.word  06,08,05,06
	.word  04,09,02,04	;ANDREW LANG		6'11"	235 reg

	.word  07,07,09,06
	.word  07,02,04,08	;GLENN ROBINSON		_______________

	.word  09,01,06,00
	.word  07,01,07,09	;SHAWN RESPERT		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;15 MINNESOTA TIMBERWOLVES

	.word  07,06,07,05
	.word  09,07,06,03	;TOM GUGLIOTTA		6'10"	240 reg
;new
	.word  08,04,08,05
	.word  07,03,06,03	;STEPHON MARBURY	_______________

	.word  08,02,05,08
	.word  05,08,04,03	;KEVIN GARNETT		_______________
;kill
	.word  00,00,00,00
	.word  00,00,00,00
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;16 NEW JERSEY NETS

	.word  08,02,06,05
	.word  07,05,07,03	;KENDALL GILL		6'5"	200 thin
;new
	.word  06,06,07,07
	.word  03,07,05,02	;KERRY KITTLES		_______________

	.word  09,03,06,00
	.word  09,00,09,02	;ROBERT PACK		6'2"	180 thin

	.word  05,03,05,08
	.word  04,10,03,04	;SHAWN BRADLEY		7'6"	248 ex thin

	.word  08,04,05,06
	.word  09,05,05,08	;ED O'BANNON		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;17 NEW YORK KNICKS

	.word  06,10,07,08
	.word  04,10,02,08	;PATRICK EWING		7'0"	240 reg
;new
	.word  05,07,07,06
	.word  04,07,05,02	;JOHN WALLACE		_______________

	.word  07,08,07,08
	.word  04,05,07,08	;LARRY JOHNSON		6'7"	250 fat

	.word  09,05,08,02
	.word  07,02,08,08	;JOHN STARKS		6'5"	185 thin

	.word  08,01,10,02
	.word  04,03,05,07	;ALAN HOUSTON		6'6"	200 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;18 ORLANDO MAGIC

	.word  10,04,08,08
	.word  08,07,08,10	;ANFERNEE HARDAWAY	6'7"	200 ex thin

	.word  05,08,05,03
	.word  03,07,04,04	;RONY SEIKALY		6'11"	252 reg

	.word  06,08,05,06
	.word  04,08,04,04	;HORACE GRANT		6'10"	220 reg

	.word  07,04,08,03
	.word  08,04,04,04	;NICK ANDERSON		6'6"	205 reg

	.word  07,03,09,03
	.word  04,04,05,04	;DENNIS SCOTT		6'8"	229 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;19 PHILADELPHIA  76ers
;new
	.word  09,03,09,00
	.word  09,01,07,06	;ALLEN IVERSON		_______________
;new
;;	.word  06,05,08,06
;;	.word  06,04,07,02	;RYAN MINOR		_______________

	.word  08,04,07,08
	.word  05,03,05,07	;JERRY STACKHOUSE	_______________

	.word  05,08,07,06
	.word  03,05,03,02	;DERRICK COLEMAN	6'10"	260 fat

	.word  05,06,06,06
	.word  04,06,05,07	;CLARENCE WEATHERSPOON	6'7"	240 fat
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;20 PHOENIX SUNS

	.word  09,02,08,02
	.word  08,03,08,09	;KEVIN JOHNSON		6'1"	190 ex thin

	.word  04,08,08,06
	.word  04,06,05,07	;WAYMAN TISDALE		6'9"	260 fat

	.word  05,06,05,07
	.word  04,05,03,06	;DANNY MANNING		6'10"	234 reg

	.word  08,06,06,08
	.word  07,08,05,09	;ROBERT HORRY		6'10"	220 thin

	.word  09,01,06,01
	.word  04,01,06,02	;SAM CASSELL		6'3"	195 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;21 PORTLAND TRAILBLAZERS

	.word  08,07,06,06
	.word  06,07,02,08	;CLIFF ROBINSON		6'10"	225 thin

	.word  07,04,05,09
	.word  04,01,02,06	;ISIAH RIDER		6'5"	215 thin

	.word  04,09,06,05
	.word  03,07,02,04	;ARVYDAS SABONIS	_______________

	.word  10,03,06,00
	.word  08,03,09,06	;KENNY ANDERSON		6'1"	168 ex thin 

	.word  09,02,05,00
	.word  06,01,08,08	;RANDOLPH CHILDRESS	_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;22 SACRAMENTO KINGS

	.word  07,06,07,06
	.word  04,02,07,06	;BILLY OWENS		6'9"	220 reg

	.word  08,02,08,00
	.word  08,01,08,09	;MAHMOUD ABDUL-RAUF	6'1"	168 ex thin

	.word  07,07,08,02
	.word  09,01,06,08	;MITCH RICHMOND		6'5"	215 reg

	.word  05,06,05,06
	.word  02,09,01,06	;BRIAN GRANT		_______________

	.word  10,01,06,00
	.word  08,00,08,04	;TYUS EDNEY		_______________

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;23 SAN ANTONIO SPURS

	.word  08,04,08,07
	.word  04,05,02,08	;SEAN ELLIOTT		6'8"	215 thin

	.word  08,09,08,06
	.word  05,10,04,06	;DAVID ROBINSON		7'1"	235 reg

	.word  07,04,08,03
	.word  05,03,06,04	;VERNON MAXWELL		6'4"	190 thin

	.word  10,01,05,00
	.word  08,01,09,02	;AVERY JOHNSON		5'11"	175 ex thin

	.word  07,03,06,01
	.word  07,01,03,02	;VINNY DEL NEGRO	6'4"	200 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;24 SEATTLE SUPERSONICS

	.word  08,07,08,10
	.word  06,09,03,07	;SHAWN KEMP		6'10"	245 reg

	.word  10,03,07,00
	.word  10,02,08,08	;GARY PAYTON		6'4"	190 ex thin

	.word  05,06,08,05
	.word  02,04,04,02	;DETLEF SCHREMPF	6'10"	230 thin

	.word  06,03,07,00
	.word  06,04,05,07	;HERSEY HAWKINS		6'3"	190 thin

	.word  07,03,04,04
	.word  04,04,06,04	;SHERELL FORD		6'6"	235 thin

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;25 TORONTO RAPTORS

	.word  06,08,05,05
	.word  06,04,05,01	;CARLOS ROGERS		_______________
;new
	.word  07,07,08,08
	.word  04,09,05,07	;MARCUS CAMBY		_______________

	.word  10,01,07,00
	.word  08,01,09,08	;DAMON STOUDAMIRE	_______________

	.word  05,08,04,07
	.word  04,06,03,03	;POPEYE JONES		6'8"	250 reg

	.word  08,06,07,07
	.word  05,08,06,03	;WALT WILLIAMS		6'8"	230 reg

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;26 UTAH JAZZ

	.word  07,02,08,00
	.word  10,01,10,08	;JOHN STOCKTON		6'1"	175 ex thin
        
	.word  07,10,08,08
	.word  08,05,06,07	;KARL MALONE		6'9"	256 fat

	.word  05,05,07,02
	.word  07,02,05,06	;JEFF HORNACEK		6'4"	190 reg

	.word  05,06,07,05
	.word  08,04,04,02	;CHRIS MORRIS		6'8"	220 reg
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;27 VANCOUVER GRIZZLIES

	.word  08,04,05,01
	.word  07,02,07,02	;GREG ANTHONY		6'2"	185 ex thin

	.word  07,06,07,04
	.word  08,05,03,07	;BLUE EDWARDS		6'4"	228 reg

	.word  05,10,06,04
	.word  05,08,02,02	;BRYANT REEVES		_______________
;kill
	.word  00,00,00,00
	.word  00,00,00,00
;kill
	.word  00,00,00,00
	.word  00,00,00,00

;Speed, Power, Shoot, Dunk
;Steal, Block, Pass ability, Clutch

;28 WASHINGTON BULLETS

	.word  08,03,07,00
	.word  07,01,10,06	;ROD STRICKLAND		6'3"	185 reg

	.word  08,08,08,08
	.word  06,04,06,07	;CHRIS WEBBER		6'10"	260 fat

	.word  07,07,08,06
	.word  05,03,04,06	;JUWAN HOWARD		_______________

	.word  04,09,05,02
	.word  03,09,01,04	;GHEORGHE MURESAN	7'7"	315 thin

	.word  07,05,06,06
	.word  06,02,02,08	;CALBERT CHEANEY	6'7"	209 reg
;DJT End

;FIX!!!
;Move these to where they should go (If anywhere!)
;Special super star secret guests
;
;;ATL
;	.word  06,04,05,06
;	.word  05,08,04,03	 ;ALAN HENDERSON     ____________
;
;;G.S
;	.word  06,05,05,05
;	.word  06,04,05,05	 ;BIMBO COLES        6'2"  185 reg
;
;;ATL
;	.word  05,08,05,06
;	.word  03,06,01,04	 ;SEAN ROOKS         6'10" 260  reg
;
;;N.Y.
;	.word  07,02,06,05
;	.word  04,06,05,07	 ;WILLIE ANDERSON     6'8" 200 reg
;
;;ORL
;	.word  05,06,05,06
;	.word  03,06,04,05	 ;KENNY GATTISON    6'8" 252  fat
;
;;L.A.
;	.word  08,04,07,05
;	.word  04,07,08,02	 ;EDDIE JONES          ________________
;
;
;;TOR
;	.word  05,05,04,07
;	.word  04,07,04,04	 ;SHARONE WRIGHT         ______________



********NOTE**************************************************************
*  IF this table is messed with, 'player_attribs' must be updated as well
*     and vice versa
********NOTE**************************************************************
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;DJT Start
	.ref	ALLEN,CAMBY,DAMPIER,HAMER,HRNGTON,IVERSON,KITTLES
	.ref	MARBURY,MINOR,RILEY,WALLACE

name_sort
 .long	BLAYLOCK,MUTUMBO,SSMITH,LAETTNER,KNORMAN		;00 HAWKS
 .long	BROWN, HAMER ,BARROS,RADJA,FOX			;new	;01 CELTICS
 .long	RICE,MASON,DIVAC,ZIDEK,CURRY				;02 HORNETS
 .long	PIPPEN,RODMAN,KUKOC,LONGLEY,KERR			;03 BULLS
 .long	THILL,CMILLS,PHILLS,BRANDON,FERRY			;04 CAVALIERS
 .long	KIDD,HARPER_D,JACK,MONTROSS,MASH			;05 MAVERICKS
 .long	MCDYESS,MARCIULO,MJACKSON,DELLIS, DELLIS	;kill	;06 NUGGETS
 .long	GHILL,DUMARS,THORPE,AUGMON, RILEY 		;kill:new ;07 PISTONS
 .long	SPREWELL,KONCAK,JSMITH,MULLIN, MULLIN		;kill	;08 WARRIORS
 .long	OLAJUWON, HRNGTON ,DREXLER,WILLIS, WILLIS	;new,kill ;09 ROCKETS
 .long	MILLER, DAMPIER ,ROSE,SMITS,DDAVIS		;new	;10 PACERS
 .long	VAUGHT,RROGERS,LMURRAY,PRICHARD,BBARRY			;11 CLIPPERS
 .long	VANEXEL,CEBALLOS,SCOTT,CAMPBELL,EJONES			;12 LAKERS
 .long	MOURN,THARDAWAY,DANILOVI, DANILOVI , DANILOVI	;kill,kill ;13 HEAT
 .long	BAKER, ALLEN ,LANG,GROBINSO,RESPERT		;new	;14 BUCKS
 .long	GUGLI2, MARBURY ,GARNETT, GARNETT , GARNETT	;new,kill,kill ;15 TIMBERWOLVES
 .long	GILL, KITTLES ,PACK,BRADLEY,OBANNON		;new	;16 NETS
 .long	EWING, WALLACE ,JOHNSN_L,STARKS,HOUSTON		;new	;17 KNICKS
 .long	AHARDAWAY,SEIKALY,GRANT_HC,NANDERSON,DSCOTT		;18 MAGIC
 .long	IVERSON ,STACKHOU,COLEMAN,WEATHSPN, MINOR 	;new,kill:new ;19 76ers
 .long	KJOHNSON,TISDALE,MANNING,HORRY,CASSELL			;20 SUNS
 .long	CROBINSON,RIDER,SABONIS,KANDERSON,CHILDRES		;21 TRAILBLAZERS
 .long	BOWENS,ABDULRAU,RICH,BGRANT,EDNEY			;22 KINGS
 .long	ELLIOT2,DROBINSON,VMAXWELL,AJOHNSON,DELNEGRO		;23 SPURS
 .long	KEMP,PAYTON,SCHREMPF,HAWKINS,SFORD			;24 SUPERSONICS
 .long	CROGERS, CAMBY ,STOUDAMI,PJONES,WWILLIAM	;new	;25 RAPTORS
 .long	STOCKTON,MALONE_K,HORNACEK,CMORRIS, CMORRIS	;kill	;26 JAZZ
 .long	ANTHONY,EDWARDS,BREEVES, BREEVES , BREEVES	;kill,kill ;27 GRIZZLIES
 .long	STRICKLA,WEBBER,JHOWARD,MURESAN,CHEANEY			;28 BULLETS
 .long	0

;Removed
;MCCLOUD,TMILLS,SMITH,MCKEE2,CHAPMAN,BENJAMIN,DOUGLAS,WEBB
;GILLIAM,KEDWARDS,OAKLEY,RUFFIN,WPERSON,FINLEY,BWILLIAM,PERSON
;ROBERTSON,OMILLER,TMURRAY,BENOIT,SCOTT,EMURDOCK
;DJT End

	.if	HEADCK
;This show the player name on scrn for debugging
 SUBR	show_name

	move	a10,a0
	andi	03,a0
	sll	4,a0
	addi	#xtbl,a0
	move	*a0,a0
	sll	16,a0

	movi	[200,0],a1			;y val
	move	a10,a2
	sll	5,a2
	addi	name_sort,a2
	move	*a2,a2,L
	movi	>7ff0,a3			;z pos
	movi	DMAWNZ|M_SCRNREL,a4		;DMA flags
	clr	a5				;object ID
	clr	a6				;x vel
	clr	a7				;y vel
	calla	BEGINOBJ2
	DIE

#xtbl	.word	57,148,251,342
	.endif

;-----------------------------------------------------------------------------
; THIS table contains the MAX number of squads per team
;
;		***NOTE*** if change this table...must also update 
;			'player_names' and 'player_heads'
;-----------------------------------------------------------------------------
team_sqaud_cnts
;DJT Start
	.word	20	;ATLANTA
	.word	20	;BOSTON
	.word	20	;CHARLOTTE
	.word	20	;CHICAGO
	.word	20	;CLEVELAND
	.word	20	;DALLAS
	.word	12	;DENVER
	.word	12 ;20	;DETROIT
	.word	12	;GOLDEN STATE
	.word	12	;HOUSTON
	.word	20	;INDIANA
	.word	20	;L.A. CLIPPERS
	.word	20	;L.A. LAKERS
	.word	6	;MIAMI
	.word	20	;MILWAUKEE
	.word	6	;MINNESOTTA
	.word	20	;NEW JERSEY
	.word	20	;NEW YORK
	.word	20	;ORLANDO
	.word	12 ;20	;PHILADELPHIA
	.word	20	;PHOENIX
	.word	20	;PORTLAND
	.word	20	;SACRAMENTO
	.word	20	;SAN ANTONIO
	.word	20	;SEATTLE
	.word	20	;TORONTO
	.word	12	;UTAH
	.word	6	;VANCOUVER
	.word	20	;WASHINGTON

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
our_names
	.long	JAPPLE		;00 JEFF JOHNSON
	.long	DIVITA		;01 SAL DIVITA
	.long	TURMELL		;02 TURMELL
	.long	THOMPS		;03 THOMPSON
	.long	GEER		;04 GEER 
	.long	CARLTON		;05 CARLTON
	.long	HEDRICK		;06 HEDRICK
	.long	HEY		;07 JOHN HEY
	.long	AIRMOR		;08 AIR MORRIS
	.long	BARDO		;09 STEVE BARDO
	.long	MINIFE		;10 MINIFEE
	.long	MARTIN		;11 MARTINEZ
	.long	PESINA		;12 PESINA
	.long	LIPTAK		;13 LIPTAK
	.long	FERRIER		;14 EDDIE
	.long	VINIK		;15 MIKE V.
	.long	RIVETT		;16 JAMIE R.
	.long	EHRLICH		;17 NICK ERICH
	.long	ROOT		;18 JOHN ROOT
	.long	MEDNICK		;19 C. MEDNICK
	.long	ROAN		;20 DAN R.
	.long	FITZ		;21 PAT F.
	.long	BOON		;22 ED BOOM
	.long	TOBIAS		;23 JOHN TOBIAS
	.long	OURSLER		;24 SHERIDAN OURSLER
	.long	AIRMOR		;25 JASON S.
	.long	QUINN		;26 QUINN
	.long	PERRY		;27 PERRY from "FRIENDS"
	.long	FUNK		;28 NEIL FUNK
	.long	MDOC		;29 MDOC
	.long	FUNK		;30 BUD
	.long	MURESAN		;31 MARIUS
	.long	MUNDAY		;32 MUNDAY
	.long	NORTH		;33 NORTH
	.long	AMRICH		;34 AMRICH 
	.long	JIGGETTS	;35 JIGGETS
	.long	ZIRIN		;36 ZIRIN
	.long	HBETT		;37 HEITH BETTLEMAN
	.long	MBETT		;38 MATT BETTLEMAN
;DJT Start
	.long	FUNK		;39 KEVIN DAY
;DJT End

;Superstar special guests
	.long	PIPPEN
	.long	RODMAN
	.long	JOHNSN_L
	.long	RICE
	.long	KIDD
	.long	MUTUMBO
	.long	GHILL
	.long	OLAJUWON
	.long	MILLER
	.long	SMITS
	.long	MOURN
	.long	GROBINSO
	.long	EWING
	.long	STARKS
	.long	AHARDAWAY
	.long	GRANT_HC
	.long	STACKHOU
	.long	CROBINSON
	.long	DROBINSON
	.long	ELLIOT2
	.long	KEMP
	.long	MALONE_K
	.long	WEBBER
	.long	MURESAN

;New Superstar special guests removed from teams
	.long	MCCLOUD
	.long	TMILLS
	.long	SMITH
	.long	MCKEE2
	.long	CHAPMAN
	.long	BENJAMIN
	.long	DOUGLAS
	.long	WEBB
	.long	GILLIAM
	.long	KEDWARDS
	.long	OAKLEY
	.long	RUFFIN
	.long	WPERSON
	.long	FINLEY
	.long	BWILLIAM
	.long	PERSON
	.long	ROBERTSON
	.long	OMILLER
	.long	TMURRAY
	.long	BENOIT
	.long	SCOTT
	.long	EMURDOCK
;DJT End


;-----------------------------------------------------------------------------
; This table contains:
;
; 1) Design team and company worker BIG heads
;	  'used with SPECIAL_HEADS' variable
;-----------------------------------------------------------------------------
our_heads
	.long	JEF_MUG		;0  JEFF JOHNSON
	.long	SAL_MUG		;1  SAL DIVITA
	.long	TUR_MUG		;2  TURMELL
	.long	DAN_MUG		;3  THOMPSON
	.long	EUG_MUG		;4  GEER 
	.long	JMC_MUG		;5  CARLTON
	.long	JEN_MUG		;6  HEDRICK
	.long	HEY_MUG		;7  JOHN HEY
	.long	WIL_MUG		;8  AIR MORRIS
	.long	BAR_MUG		;9  STEVE BARDO
	.long	MIN_MUG		;10 MINIFEE
	.long	MARTY_MUG	;11 MARTINEZ
	.long	CARL_MUG	;12 PESINA
	.long	SHN_MUG		;13 LIPTAK
	.long	EDD_MUG		;14 EDDIE
	.long	MXV_MUG		;15 MIKE V.
	.long	JAM_MUG		;16 JAMIE R.
	.long	NIK_MUG		;17 NICK ERICH
	.long	ROT_MUG		;18 JOHN ROOT
	.long	CAR_MUG		;19 C. MEDNICK
	.long	ROH_MUG		;20 DAN ROAN ?
	.long	PAT_MUG		;21 PAT F.
	.long	BOO_MUG		;22 BOON
	.long	TOB_MUG		;23 TOBIAS
	.long	OUR_MUG		;24 OURSLER
	.long	JAS_MUG		;25 JASON S.
	.long	QUI_MUG		;26 QUINN
	.long	PER_MUG		;27 M. PERRY
	.long	NEI_MUG		;28 NEIL FUNK
	.long	MDOC_MUG	;29 MDOC
	.long	BUD_MUG		;30 BUD
	.long	OLD		;31 MARIUS
	.long	MUN_MUG		;32 MUNDAY
	.long	NOR_MUG		;33 NORTH
	.long	AMR_MUG		;34 AMRICH 
	.long	JIG_MUG		;35 JIGGETS
;DJT Start
	.long	JON_MUG		;36 ZIRIN
	.long	HEI_MUG		;37 HEITH BETTLEMAN
	.long	MAT_MUG		;38 MATT BETTLEMAN
	.long	BAL_MUG		;39 KEVIN DAY

;Superstar special guests
	.long	PIP_CHI
	.long	ROD_CHI
	.long	JON_CHA
	.long	RCE_CHA
	.long	KID_DAL
	.long	MUT_DEN
	.long	HIL_DET
	.long	OLA_HOU
	.long	MIL_IND
	.long	SMI_IND
	.long	MOU_MIA
	.long	ROB_MLW
	.long	EWG_NEY
	.long	STA_NEY
	.long	HAR_ORL
	.long	GRT_ORL
	.long	STA_PHL
	.long	ROB_PRT
	.long	ROB_SAN
	.long	ELL_SAN
	.long	KMP_SEA
	.long	MLN_UTA
	.long	WEB_WAS
	.long	MUR_WAS

;New Superstar special guests removed from teams
	.long	MCC_DAL
	.long	MLS_DET
	.long	SMT_HOU
	.long	MCK_IND
	.long	CHP_MIA
	.long	BEN_MLW
	.long	DOU_MLW
	.long	WEB_MIN
	.long	GIL_NEJ
	.long	EDW_NEJ
	.long	OAK_NEY
	.long	RUF_PHL
	.long	PER_PHX
	.long	FIN_PHX
	.long	WIL_PRT
	.long	PRS_SAN
	.long	ROB_TOR
	.long	MIL_TOR
	.long	MUR_TOR
	.long	BEN_UTA
	.long	SCO_VAN
	.long	MUR_VAN

our_heads_end
	.long	SAL_MUG		;0		;repeat 1st 2 for wrap around
	.long	SAL_MUG		;1
our_heads_end2

	.end
;DJT End
