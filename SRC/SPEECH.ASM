;DJT Start whole file changed!!
****************************************************************
*
* Owner:	JOHNSON
*
* Software:	Jeff johnson/Dan Thompson
*
* COPYRIGHT (C) 1992 WILLIAMS ELECTRONICS GAMES, INC.
*
****************************************************************
	.file	"speech.asm"
	.title	"announcer speech"
	.width	132
	.option	b,d,l,t
	.mnolist


	.include	"mproc.equ"
	.include	"disp.equ"
	.include	"sys.equ"
	.include	"gsp.equ"
	.include	"imgtbl.glo"
	.include	"imgtbl2.glo"
	.include	"bgndtbl.glo"
	.include	"game.equ"
	.include	"audit.equ"
	.include	"macros.hdr"
	.include	"world.equ"

	.asg		0,SEQT
	.include	"plyr.equ"

******************************************************************************

;	.def	name_speech
	.def	pass_speech
	.def	welcome_sc

	.ref	ballobj_p
	.ref	special_heads			;-1 = normal player head

	.ref	brick_count
	.ref	plyrproc_t
	.ref	ballpnum,ballpnumshot
	.ref	inbound
	.ref	ballrimhitcnt,ballbbhitcnt
	.ref	snd_play1
	.ref	rndrng0,RNDPER
	.ref	game_time
	.ref	gmqrtr,scores
	.ref	ballptsforshot		;Point value for current shot (1-3)
	.ref	team1,team2
	.ref	ballpnumscored		;Last plyr who scored (0-3) or neg
	.ref	ballnumscored		;# times last plyr scored
	.ref	plyr_onfire		;plyr who is on fire
	.ref	ballscorezhit
	.ref	seekdirdist_obxz128
	.ref	ballobj_p
	.ref	get_player_stat
	.ref	error_found

	.ref	SNDSND
	.ref	script_play1
	.ref	organ_fx1_sc,organ_fx2_sc
	.ref	player_names,tm1set,tm2set,name_sort
	.ref	crwd_blchrs_sc,crwd_goteam_sc,crwd_defnse_sc
	.ref	player1_data,player2_data,player3_data,player4_data
	.ref	player_stats
	.ref	NUM_NICK_NAMES
	.ref	jet1_snd,jet2_snd,jet3_snd
	.ref	siren_snd,car_pass_snd
	.ref	prop_ple_snd,chrch_bel_sp,car_pas2_snd
	.ref	ambulne_snd,ambulne2_snd,fire_trk_snd
	.ref	tarzan,jet4_snd
	.ref	pup_court
	.ref	swat_snd
	.ref	must_rebound
	.ref	ballshotinair


#*****************************************************************************
;ram

	BSSX	last_name,	16	;last name called (0-3)
	BSSX	last_name_time,	16	;# ticks since name called
	BSSX	shot_type,	16	;dunk, 3ptr etc
	BSSX	plyr_shot,	16	;player who shot last
	BSSX	shot_percentage,16	;0-999
	BSSX	shot_distance,	16	;distance from hoop
	.bss	ugly_stat,	16	;0=not ugly, 1=ugly called
	BSSX	score_diff,	16	;+winning by, -losing by
	.bss	blowout_called,	16	;0=not called, 1=called
	.bss	needshot_called,16	;0=not called, 1=called
	.bss	freakout,	16	;0=no freakout
	BSSX	jam_speech,	16	;speech type to call when jammed
;	BSSX	next_call,	16	;# shots before next score call
	.bss	sound_ram,	16*4*4	;queued speech ram
	.bss	skycalled,	16	;skyhook called (0=no)
	BSSX	spch_name_ram,	32*8	;last and full names (4 players)
	BSSX	spch_pass_ram,	32*4	;last and full names (4 players)
	BSSX	bkbrd_proc_flg,	16	;'to' last name speech (4 players)

	.text

	.asg	16*3,TM_SPCH_TBL_SZ
	.asg	16*3,NME_SPCH_TBL_SZ


;
;***************
;    SPEECH
;***************
;
 SX	cheer_snd,   >1004,110,>1cd
 SX	cheer1_snd,  >1004,110,>1d1
 SX	cheer2_snd,  >1004,110,>1d5
 SX	cheer3_snd,  >1004,110,>1d9
 SX	cheer4_snd,  >1004,110,>1d5

 SX	crwdbed_kill,>7102,25, >dc
 SX	crwdbed_tune,>7002,799,>dd
 SX	crwdbd2_tune,>7002,799,>db
 SX	crwd_arbl_sp,>2404,135,>1ed	;f0

 SX	midway_sp,   >200D,67, >b00
;DJT Start
 SX	max_hngtm_sp,>200D,93, >b8f
; SX	nba_hngtm_sp,>200D,99, >b02
;DJT End
 SX	at_hlftme_sp,>150D,61, >adc
 SX	gm_undrwy_sp,>150D,70, >adb
 SX	heres_tip_sp,>150D,61, >b20
 SX	overtime_sp, >200D,60, >add
 SX	showtm,      >250D,75, >a9b
 SX	tst_triva_sp,>100D,76, >afd


 SX	has_sp,      >100D,20, >af1
;DJT Start
 SX	with_sp,     >100D,16, >aef
 SX	leadng_by_sp,>100D,56, >84e
 SX	leads_by_sp, >100D,51, >84b
 SX	lead_by_sp,  >100D,41, >849
 SX	out_front_sp,>100D,48, >850
 SX	by_sp,       >100D,18, >851
;DJT End
 SX	have_lead_sp,>100D,57, >84f
 SX	take_lead_sp,>100D,49, >84c
 SX	taks_lead_sp,>100D,56, >84d

;DJT Start
 SX	longway_sp,  >100D,73, >86e
 SX	downby_sp,   >100D,36, >845
 SX	behind_by_sp,>100D,49, >853
 SX	catchg_up_sp,>100D,41, >873

 SX	tiegm_sp,    >100D,44, >864
 SX	tiethegm_sp, >100D,51, >869
 SX	tied_at_sp,  >100D,69, >866
;DJT End
 SX	minute_sp,   >100D,59, >ab4

 SX     vs_sp,       >100D,47, >509
 SX	wingame_sp,  >200D,45, >863
 SX	baddec_sp,   >100D,56, >9eb
 SX	ohmy,  	     >100D,62, >96f
 SX	fancy,	     >100D,51, >ae6
 SX	matchup_sp,  >100D,65, >ab1
 SX	wideopen_sp, >100D,41, >939
 SX	no_prsure_sp,>100D,48, >a3d
 SX	opn_for_3_sp,>100D,69, >b0a
 SX	all_alone_sp,>100D,42, >91c
 SX	its_good_sp, >130D,61, >819
 SX	it_is_sp,    >100D,65, >816
 SX	off_in_time, >100D,93, >814
 SX	shrt_rng_sp, >100D,56, >7eb
 SX	finese_it_sp,>100D,47, >80f
 SX	frm_post_sp, >100D,41, >7e4
 SX	baby_hook_sp,>100D,47, >802
 SX	half_hook_sp,>100D,46, >804
 SX	hook_shot_sp,>100D,41, >805
 SX	sky_hook_sp, >100D,74, >83f
 SX	sky_hook2_sp,>100D,72, >b09
 SX	rgt_hndr_sp, >100D,69, >830
 SX	lft_hndr_sp, >100D,67, >831
 SX	for_two_sp,  >100D,40, >b08
 SX	from_15_sp,  >100D,45, >b0d
 SX	from_18_sp,  >100D,45, >b0e
 SX	from_20_sp,  >100D,35, >b0f
 SX	shoots1_sp,  >100D,37, >83c	;**
 SX	shoots2_sp,  >100D,42, >83c
 SX	shoots3_sp,  >100D,33, >83d
 SX	from_arc_sp, >100D,40, >7e1
;DJT Start
 SX	tp_circle_sp,>100D,63, >b1c
 SX	fm_3pline_sp,>100D,80, >7e5
;DJT End
 SX	for_thre1_sp,>100D,47, >7e6
 SX	frm_dwntn_sp,>100D,67, >7e9
 SX	bhd_3_arc_sp,>100D,69, >825
 SX	frm_3_arc_sp,>100D,65, >826
 SX	for_thre2_sp,>100D,45, >82a
 SX	for_thre3_sp,>100D,51, >839
 SX	frm_outsd_sp,>100D,63, >83b
 SX	unlod_one_sp,>100D,68, >7ff
 SX	frm_l_rng_sp,>100D,63, >801
 SX	hail_mary_sp,>100D,59, >a22
 SX	agn_shoot_sp,>100D,55, >80d
 SX	it_culdbe_sp,>100D,60, >80c
 SX	could_tie_sp,>100D,77, >b04
 SX	outof_rng_sp,>100D,84, >9b9
 SX	outof_rg2_sp,>100D,84, >9b9
 SX	out_cntrl_sp,>100D,58, >9bd
 SX	rainbow_sp,  >110D,70, >9f2
 SX	difficult_sp,>100D,56, >9af

 SX	swith_hnd_sp,>110D,53, >823
 SX	spn_shtup_sp,>110D,56, >7fd
 SX	a_fngr_rl_sp,>110D,55, >902

 SX	hnd_face_sp, >100D,67, >b24
 SX	ill_shot_sp, >100D,60, >b25
 SX	frcd_shot_sp,>100D,56, >b2d
 SX	wild_shot_sp,>100D,56, >b2e	;9bb
;DJT Start
 SX	lfts_wild_sp,>100D,87, >9bb
;DJT End

 SX	alley_oop_sp,>100D,63, >a18
 SX	alyoop_ps_sp,>100D,63, >a1a
 SX	thr_tmwrk_sp,>100D,61, >a9d
 SX	thr_smkn_sp, >100D,57, >af5
 SX	thr_zone_sp, >100D,65, >b05
 SX	whta_show_sp,>100D,57, >958

 SX	dble_dnk_sp, >120D,55, >b3a
 SX	dble_dnk2_sp,>120D,78, >b38
 SX	lob_pass_sp, >120D,55, >a1c
 SX	scp_tmate_sp,>120D,85, >b3b
;DJT Start
 SX	the_scoop_sp,>120D,51, >b3c
;DJT End
 SX	lev_tmate_sp,>120D,83, >b3d
;DJT Start
 SX	is_legal_sp ,>0F0D,65, >b21
;DJT End

 SX	tm_onfire_sp,>140D,76, >b3e
;DJT Start
 SX	got_hspot_sp,>140D,76, >b40
;DJT End

 SX	cantbuy_sp,  >100D,68, >9ec
 SX	rtle_arnd_sp,>100D,77, >9d2
 SX	ugly_shot_sp,>100D,71, >9e6
 SX	putup_brk_sp,>100D,66, >9b2
;DJT Start
 SX	look_out_sp, >100D,41, >a6f
;DJT End
 SX	nogood_sp,   >130D,31, >9d4
 SX	mis_fires_sp,>100D,56, >9d8
;DJT Start
 SX	what_was_sp, >100D,66, >b2b
;DJT End
 SX	there_brk_sp,>100D,66, >9b5
 SX	dwn_luck_sp, >100D,54, >ac9
 SX	missed_sp,   >100D,30, >9d6
 SX	mised_agn_sp,>100D,59, >9d7
 SX	hita_barn_sp,>100D,124,>a98
 SX	wht_thnk2_sp,>100D,88, >9ed
 SX	wht_distr_sp,>100D,73, >aa8
 SX	at_buzzer_sp,>100D,57, >7e8
 SX	sht_ball_sp, >100D,53, >aad

 SX	off_rim_sp,  >100D,46, >9bf
 SX	off_frnt_sp, >100D,54, >9c9
 SX	holes_out_sp,>100D,58, >9ad
 SX	bnce_out_sp, >100D,42, >9d0
 SX	bnce_away_sp,>100D,54, >9d1
 SX	away_side_sp,>100D,56, >9c7
 SX	spins_out_sp,>100D,45, >9cb
 SX	side_rim_sp, >100D,61, >9c5
 SX	off_heel_sp, >100D,54, >9c3
 SX	no_sp,       >100D,30, >9cc
 SX	nicly_dne_sp,>100D,69, >a49
 SX	got_skilz_sp,>100D,67, >a97

 SX	misd_evry_sp,>100D,66, >9e2
 SX	way_shrt_sp, >100D,57, >9df
 SX	misd_mile_sp,>100D,72, >9e3
 SX	teribl_sh_sp,>100D,57, >9ba
 SX	airball_sp,  >100D,56, >9da

 SX	cannonbal_sp,>110D,58, >95b
 SX	sumrslts_sp, >110D,90, >96a
 SX	goes_flyg_sp,>110D,68, >acd
 SX	hiabv_rim_sp,>110D,49, >ad4
 SX	flies_air_sp,>110D,100,>96c
 SX	gldes_air_sp,>110D,99, >96d
 SX	raises_up_sp,>110D,45, >82d
 SX	serious_h_sp,>110D,79, >b03
 SX	learn_tht_sp,>110D,54, >97a
 SX	goes_up_sp,  >0905,37, >951
 SX	goes_hoop_sp,>110D,59, >95f
 SX	tks2_hoop_sp,>110D,51, >a36
 SX	fly_1hdnr_sp,>110D,76, >96e
 SX	didnt_knw_sp,>110D,77, >97f
 SX	haning_sp,   >110D,34, >a0f
 SX	ooooooh_sp,  >110D,65, >af7
 SX	ooooooh2_sp, >110D,40, >af7
 SX	thrgh_air_sp,>110D,50, >96b
 SX	way_upair_sp,>110D,75, >974
;DJT Start
 SX	lch_atbkt_sp,>110D,100,>b03
;DJT End
 SX	catapults_sp,>110D,49, >9ab
 SX	tomahk_dk_sp,>110D,66, >965
 SX	tomahk_hm_sp,>110D,79, >966

 SX	shuld_pas_sp,>100D,75, >a6e
 SX	he_lst_bl_sp,>100D,75, >a74
 SX	he_lostit_sp,>100D,75, >a77
 SX	bal_loose_sp,>100D,75, >a7d

 SX	fades_sp,    >100D,21, >b10
 SX	fadeaway_sp, >100D,80, >b11
 SX	leans_bck_sp,>100D,80, >b17
 SX	leans_sp,    >100D,21, >b14
 SX	leans_in_sp, >100D,80, >b16
 SX	pull_jmpr_sp,>100D,80, >838
 SX	bslne_lnr_sp,>100D,45, >b30
 SX	luky_bnce_sp,>100D,58, >92f
 SX	per_luck_sp, >100D,64, >946
;DJT Start
 SX	luky_bskt_sp,>100D,82, >948
;DJT End
	
;DJT Start
 SX	kakaboom_sp, >100D,69, >91b
 SX	kaboom1_sp,  >100D,38, >b2a	;91a
 SX	kaboom2_sp,  >100D,34, >91a
;DJT End
 SX	isit_shoe_sp,>100D,62, >91e

 SX	facial_sp,   >100D,80, >b42

 SX	unbelieve_sp,>100D,53, >931
 SX	u_c_that_sp, >100D,65, >932
 SX	oh_man_sp,   >100D,52, >934
 SX	no_stopng_sp,>100D,75, >942
 SX	postr_jam_sp,>100D,67, >956
 SX	jam_it_in_sp,>100D,83, >95a
 SX	thndr_dnk_sp,>100D,60, >960
;DJT Start
 SX	throws_it_sp,>100D,66, >963
 SX	pounds_it_sp,>100D,62, >964
 SX	incredble_sp,>100D,49, >970
 SX	incrd_sht_sp,>100D,75, >90e
; SX	supr_dnk_sp, >100D,61, >971	;**
; SX	mnstr_jam_sp,>100D,70, >971
 SX	outstndng_sp,>100D,67, >aaa
;DJT End
 SX	amazing_sp,  >100D,57, >912
 SX	he_dnk_it_sp,>100D,33, >961
 SX	dunks_it_sp, >100D,24, >962
 SX	jams_it_sp,  >100D,35, >97c
 SX	spect_dnk_sp,>100D,81, >988
 SX	slam_dunk_sp,>100D,51, >989
 SX	he_slams_sp, >100D,42, >98b
 SX	with_ajam_sp,>100D,49, >998
 SX	powr_jams_sp,>100D,73, >9a6

 SX	head_fake_sp,>050D,24, >a8e
 SX	the_fake_sp, >050D,26, >a8f
 SX	pump_fake_sp,>050D,30, >a91

 SX	hits_jmpr_sp,>100D,25, >906
 SX	good_4two_sp,>100D,50, >90a
 SX	a_trey_sp,   >100D,42, >82b
 SX	he_scores_sp,>100D,56, >93b
 SX	scores_sp,   >100D,37, >7de
;DJT Start
 SX	scores2_sp,  >100D,52, >7df
;DJT End
 SX	score_agn_sp,>100D,70, >7f3
 SX	good_agn_sp, >100D,47, >7f4
 SX	yes_sp,      >100D,33, >b33
 SX	goooood_sp,  >100D,42, >818
 SX	goooood2_sp, >100D,42, >903
 SX	money_bnk_sp,>100D,33, >b33
 SX	chk_it_up_sp,>100D,56, >93b
 SX	good_4_3_sp, >100D,69, >929
 SX	thats_3_sp,  >100D,58, >92b
 SX	fantastic_sp,>100D,73, >a99
 SX	drains_it_sp,>100D,38, >93f
 SX	it_falls_sp, >100D,42, >90d
 SX	falls_in_sp, >100D,48, >91f
 SX	kncks_dwn_sp,>100D,54, >92c
;DJT Start
 SX	and_drops_sp,>100D,56, >943
;DJT End
 SX	dwn_well_sp, >100D,90, >94b
 SX	bomshakalaka,>100D,56, >afc
 SX	rama_dong_sp,>100D,80, >b47

 SX	hlftm_ldr_sp,>160D,73, >ae9
 SX	gmevr_ldr_sp,>160D,73, >aea

 SX	spin_mv1_sp, >100D,60, >7f7
 SX	spin_mv2_sp, >100D,60, >991
 SX	spin_mv3_sp, >100D,60, >993

;DJT Start
 SX	chalk_it_sp, >100D,38, >b48
;DJT End
 SX	book_it_sp,  >100D,28, >8ff
 SX	count_it_sp, >100D,39, >90b
 SX	bingo_sp,    >100D,41, >ae2

 SX	ever_miss_sp,>100D,77, >a95
 SX	hot_hand_sp, >100D,70, >93d
 SX	on_fire_sp,  >150D,83, >972
 SX	heatup_sp,   >130D,54, >b1e
 SX	lightn_up_sp,>120D,68, >aa4
 SX	smokin_sp,   >100D,40, >af6

 SX	swish_sp,    >100D,37, >917
;DJT Start
 SX	swish2_sp,   >100D,43, >b29
;DJT End
 SX	rgt_thrgh_sp,>100D,53, >b4a
 SX	botm_net_sp, >100D,67, >b4c
 SX	ngbut_net_sp,>100D,85, >b4b
 SX	whata_sht_sp,>100D,47, >937
 SX	great_sht_sp,>100D,54, >935
;DJT Start
 SX	greatshot_sp,>100D,47, >90f
;DJT End
 SX	good_sht_sp, >100D,36, >938
 SX	he_uncon_sp, >100D,61, >914

 SX	banked_it_sp,>100D,27, >829
 SX	a_banker_sp, >100D,33, >811
 SX	soft_glas_sp,>100D,95, >810

 SX	off_bkbrd_sp,>100D,80, >827
 SX	off_glass_sp,>100D,80, >83a
 SX	kild_smne_sp,>100D,110,>9ee
 SX	off_trgt_sp, >100D,80, >9e1
 SX	sht_stunk_sp,>100D,97, >9e8
 SX	wht_thnkg_sp,>100D,88, >9ed

 SX	fr_thw_ln_sp,>100D,65, >837
 SX	top_key_sp,  >100D,70, >807
 SX	frm_paint_sp,>100D,40, >7ed
 SX	frm_wing_sp, >100D,38, >7e7
 SX	lnch_jmpr_sp,>100D,59, >83e
 SX	stp_n_pop_sp,>100D,75, >832
 SX	fires_jumpr, >100D,55, >82e
 SX	ltle_jmpr_sp,>100D,48, >7f2

 SX	fingr_rol_sp,>100D,46, >80e
 SX	figr_itin_sp,>100D,90, >901
 SX	fingr_rl2_sp,>100D,46, >80e
 SX	lay_it_up_sp,>100D,45, >81b
 SX	layup_sp,    >100D,41, >81c
 SX	he_layup_sp, >100D,58, >81e
 SX	drv_layup_sp,>100D,61, >b19

 SX	whyyyy_sp,   >100D,41, >ae3
 SX	blowout_sp,  >100D,85, >859		;it's a blowout
 SX	whoomp_sp,   >100D,72, >85a		;Whoomp, there it is
;DJT Start
 SX	debacle_sp,  >100D,66, >a92
 SX	its_hstry_sp,>100D,47, >85f
 SX	strike_up_sp,>100D,122,>b4d
;DJT End
 SX	fnl_strw_sp, >100D,90, >b4e
 SX	fat_sing_sp, >100D,115,>858
 SX	needshot_sp, >100D,72, >ab2
 SX	run_out_sp,  >100D,55, >876
;DJT Start
 SX	just_secs_sp,>100D,84, >ab3
;DJT End

 SX	passes_sp,   >070D,33, >9f4
 SX	he_passes_sp,>070D,43, >9f6
 SX	a_pass_sp,   >070D,33, >9fb
 SX	tosses_it_sp,>070D,39, >9fc
 SX	guns_it_sp,  >070D,43, >a13

 SX	cros_crt_sp, >070D,37, >a16
 SX	downcourt_sp,>070D,37, >a0a
;DJT Start
 SX	downcrt2_sp, >070D,39, >a1e
 SX	lngpss_dc_sp,>070D,84, >a0b
;DJT End
 SX	hev_dncrt_sp,>070D,69, >a1d
 SX	bnce_pass_sp,>070D,41, >a20
 SX	dumps_it_sp, >070D,27, >9fe
 SX	long_pass_sp,>070D,85, >a0b
 SX	pas_outsd_sp,>070D,58, >9f8

 SX	goal_tend_sp,>120D,47, >a4b	;SUX

 SX	rebounds_sp, >100D,60, >af3
 SX	tks_rbnd2_sp,>100D,73, >a4f
;DJT Start
 SX	tks_rbnd3_sp,>100D,96, >a5b
;DJT End
 SX	grab_rock_sp,>100D,61, >a52
 SX	has_rebnd_sp,>100D,64, >a55
 SX	grab_ball_sp,>100D,64, >a56
 SX	tks_rebnd_sp,>100D,81, >a57
 SX	posession_sp,>100D,57, >a58
 SX	off_rebnd_sp,>100D,89, >a5a
 SX	pulls_off_sp,>100D,87, >a5b
 SX	with_bord_sp,>100D,77, >a5c
 SX	grbs_rbnd_sp,>100D,80, >a5d
 SX	ynk_rim_sp,  >100D,80, >a5f
 SX	da_rebnd_sp, >100D,45, >a60
 SX	rip_rebnd_sp,>100D,87, >a50
 SX	rbnd_miss_sp,>100D,97, >a64

 SX	its_blckd_sp,>130D,47, >a66
 SX	outa_here_sp,>130D,63, >a67
 SX	blckd_it_sp, >130D,29, >a68
 SX	no_way_sp,   >130D,47, >a69
 SX	rejected_sp, >130D,46, >a6a
 SX	deflected_sp,>130D,38, >a6c
;DJT look_out_sp line moved

 SX	stolen_sp,   >130D,35, >a72
 SX	the_steal_sp,>130D,39, >a73
 SX	turnover_sp, >130D,48, >a75
 SX	trnd_over_sp,>130D,61, >a76
 SX	quck_hnds_sp,>130D,46, >a79
 SX	intrceptd_sp,>130D,48, >a7f
 SX	stripped_sp, >130D,29, >a84
 SX	clean_pck_sp,>130D,48, >a83
 SX	bad_pass_sp, >130D,56, >a82

 SX	flagrant_sp, >090D,37, >abb
 SX	to_floor_sp, >090D,43, >ac6
 SX	to_deck_sp,  >090D,37, >ac7
;DJT Start
; SX	shvd_asde_sp,>090D,67, >aca
;DJT End
 SX	tookm_out_sp,>090D,48, >abe
 SX	hamerd_hm_sp,>090D,35, >ad1
 SX	into_stnd_sp,>050D,96, >ac4


 SX	nick_nme1,   >100D,23, >760
 SX	nick_nme2,   >100D,23, >8c6
 SX	nick_nme3,   >100D,35, >758
 SX	nick_nme4,   >100D,25, >774
 SX	nick_nme5,   >100D,36, >784
 SX	nick_nme6,   >100D,20, >75c
 SX	nick_nme7,   >100D,24, >75e
 SX	nick_nme8,   >100D,37, >8cc
 SX	nick_nme9,   >100D,25, >8d8
 SX	nick_nme10,  >100D,24, >78e
 SX	nick_nme11,  >100D,32, >8b8
 SX	nick_nme12,  >100D,37, >766
 SX	nick_nme13,  >100D,25, >8d4
 SX	nick_nme14,  >100D,46, >8bc
 SX	nick_nme15,  >100D,20, >768
 SX	nick_nme16,  >100D,37, >796
 SX	nick_nme17,  >100D,25, >76a
 SX	nick_nme18,  >100D,31, >76c
 SX	nick_nme19,  >100D,27, >76e
 SX	nick_nme20,  >100D,20, >798
 SX	nick_nme21,  >100D,36, >79a
 SX	nick_nme22,  >100D,40, >776
 SX	nick_nme23,  >100D,46, >8be
 SX	nick_nme24,  >100D,31, >8ca
; SX	nick_nme25,  >100D,28, >8c0
 SX	nick_nme26,  >100D,28, >8ce
 SX	nick_nme27,  >100D,32, >77c
 SX	nick_nme28,  >100D,28, >77e
 SX	nick_nme29,  >100D,21, >780
 SX	nick_nme30,  >100D,31, >782
 SX	nick_nme31,  >100D,27, >786
 SX	nick_nme32,  >100D,24, >788
 SX	nick_nme33,  >100D,29, >78a
 SX	nick_nme34,  >100D,36, >78c
 SX	nick_nme35,  >100D,21, >790
 SX	nick_nme36,  >100D,23, >792

 SX	to_nck_nme1, >100D,60, >761
 SX	to_nck_nme2, >100D,60, >8c7
 SX	to_nck_nme3, >100D,60, >759
 SX	to_nck_nme4, >100D,60, >775
 SX	to_nck_nme5, >100D,60, >785
 SX	to_nck_nme6, >100D,60, >75d
 SX	to_nck_nme7, >100D,60, >75f
 SX	to_nck_nme8, >100D,60, >8cd
 SX	to_nck_nme9, >100D,60, >8d9
 SX	to_nck_nme10,>100D,60, >78f
 SX	to_nck_nme11,>100D,60, >8b9
 SX	to_nck_nme12,>100D,60, >767
 SX	to_nck_nme13,>100D,60, >8d5
 SX	to_nck_nme14,>100D,60, >8bd
 SX	to_nck_nme15,>100D,60, >769
 SX	to_nck_nme16,>100D,60, >797
 SX	to_nck_nme17,>100D,60, >76b
 SX	to_nck_nme18,>100D,60, >76d
 SX	to_nck_nme19,>100D,60, >76f
 SX	to_nck_nme20,>100D,60, >799
 SX	to_nck_nme21,>100D,60, >79b
 SX	to_nck_nme22,>100D,60, >777
 SX	to_nck_nme23,>100D,60, >8bf
 SX	to_nck_nme24,>100D,60, >8cb
; SX	to_nck_nme25,>100D,60, >8c1
 SX	to_nck_nme26,>100D,60, >8cf
 SX	to_nck_nme27,>100D,60, >77d
 SX	to_nck_nme28,>100D,60, >77f
 SX	to_nck_nme29,>100D,60, >781
 SX	to_nck_nme30,>100D,60, >783
 SX	to_nck_nme31,>100D,60, >787
 SX	to_nck_nme32,>100D,60, >789
 SX	to_nck_nme33,>100D,60, >78b
 SX	to_nck_nme34,>100D,60, >78d
 SX	to_nck_nme35,>100D,60, >791
 SX	to_nck_nme36,>100D,60, >793

;
; Speech scripts
;
;DJT Start
welcome_sc   LWLW	 midway_sp,67,max_hngtm_sp,-1
;welcome_sc   LWLW	 midway_sp,67,nba_hngtm_sp,-1
;DJT End
;swat_cheer_sc  LWLW	 swat_snd,30,cheer_snd,-1


#*****************************************************************************
;speech tables

STAB_START

nickname_spch_tbl
	.long	nick_nme1, to_nck_nme1
	.long	nick_nme2, to_nck_nme2
	.long	nick_nme3, to_nck_nme3
	.long	nick_nme4, to_nck_nme4
	.long	nick_nme5, to_nck_nme5
	.long	nick_nme6, to_nck_nme6
	.long	nick_nme7, to_nck_nme7
	.long	nick_nme8, to_nck_nme8
	.long	nick_nme9, to_nck_nme9
	.long	nick_nme10,to_nck_nme10
	.long	nick_nme11,to_nck_nme11
	.long	nick_nme12,to_nck_nme12
	.long	nick_nme13,to_nck_nme13
	.long	nick_nme14,to_nck_nme14
	.long	nick_nme15,to_nck_nme15
	.long	nick_nme16,to_nck_nme16
	.long	nick_nme17,to_nck_nme17
	.long	nick_nme18,to_nck_nme18
	.long	nick_nme19,to_nck_nme19
	.long	nick_nme20,to_nck_nme20
	.long	nick_nme21,to_nck_nme21
	.long	nick_nme22,to_nck_nme22
	.long	nick_nme23,to_nck_nme23
	.long	nick_nme24,to_nck_nme24
;	.long	nick_nme25,to_nck_nme25
	.long	nick_nme26,to_nck_nme26
	.long	nick_nme27,to_nck_nme27
	.long	nick_nme28,to_nck_nme28
	.long	nick_nme29,to_nck_nme29
	.long	nick_nme30,to_nck_nme30
	.long	nick_nme31,to_nck_nme31
	.long	nick_nme32,to_nck_nme32
	.long	nick_nme33,to_nck_nme33
	.long	nick_nme34,to_nck_nme34
	.long	nick_nme35,to_nck_nme35
	.long	nick_nme36,to_nck_nme36
	.long	nick_nme36,to_nck_nme36
	.long	nick_nme36,to_nck_nme36


;FIX!!!
;Check for all incorrect AUGMON speech calls!
****************
****************
full_name_speech

 .word	>100D,83,1304	;BLAYLOCK,    mookie		( ALTANTA HAWKS )
 .word	>100D,103,1424	;MUTUMBO,     dekembe
 .word	>100D,64,1308	;SMITH,       steve
 .word	>100D,71,1604	;LAETNER,     christian
 .word	>100D,63,1316	;NORMAN,      ken

 .word	>100D,61,1320	;BROWN,       dee		( BOSTON )
 .word	>100D,57,2912	;HAMER,       steve
 .word	>100D,66,1324	;BARROS,      dana
 .word	>100D,66,1332	;RADJA,       dino
 .word	>100D,59,1336	;FOX,         rick

 .word	>100D,65,1348	;RICE,        glen		( CHARLOTTE )
 .word	>100D,80,1644	;MASON,       anthony
 .word	>100D,78,1544	;DIVAC,       vlade
 .word	>100D,70,1352	;ZIDEK,       george
 .word	>100D,58,1356	;CURRY,       del

 .word	>100D,72,1360	;PIPPEN,      scottie		( CHICAGO )
 .word	>100D,60,1364	;RODMAN,      dennis
 .word	>100D,70,1368	;KUKOC,       toni
 .word	>100D,78,1372	;LONGLEY,     luke
 .word	>100D,68,1376	;KERR,        steve

 .word	>100D,75,1380	;HILL,        tyrone		( CLEVELAND )
 .word	>100D,76,1384	;MILLS,       chris
 .word	>100D,70,1388	;PHILLS,      bobby
 .word	>100D,69,1392	;BRANDON,     terrell
 .word	>100D,65,1396	;FERRY,       danny

 .word	>100D,68,1404	;KIDD,        jason		( DALLAS )
 .word	>100D,71,1648	;HARPER,      derek
 .word	>100D,84,1400	;JACKSON,     jim
 .word	>100D,79,1328	;MONTROSS,    eric
 .word	>100D,88,1408	;MASHBURN,    jamal

 .word	>100D,96,1428	;McDYESS,     antonio		( DENVER )
 .word	>100D,100,1752	;MARCIULIONIS,sarunas
 .word	>100D,78,1516	;JACKSON,     mark
 .word	>100D,64,1436	;ELLIS,       dale
;REMOVE!!!
 .word	0,0,0

 .word	>100D,63,1444	;HILL,        grant		( DETROIT )
;; .word	>100D,54,2954	;RILEY,       ron
 .word	>100D,74,1440	;DUMARS,      joe
 .word	>100D,56,1452	;THORPE,      otis
 .word	>100D,77,1300	;AUGMON,      stacey
;REMOVE!!!
 .word	0,0,0

 .word	>100D,76,1464	;SPREWELL,    latrell		( GOLDEN STATE )
 .word	>100D,72,1676	;KONCAK,      jon
 .word	>100D,65,1472	;SMITH,       joe
 .word	>100D,77,1476	;MULLIN,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,118,1480	;OLAJUWAN,    hakeem		( HOUSTON )
 .word	>100D,66,2909	;HARRINGTON,  othella
 .word	>100D,80,1484	;DREXLER,     clyde
 .word	>100D,61,1568	;WILLIS,      kevin
;REMOVE!!!
 .word	0,0,0

 .word	>100D,85,1500	;MILLER,      reggie		( INDIANA )
 .word	>100D,66,2936	;DAMPIER,     erick
 .word	>100D,70,1432	;ROSE,        jalen
 .word	>100D,71,1508	;SMITS,       rik
 .word	>100D,71,1504	;DAVIS,       dale

 .word	>100D,45,1520	;VAUGHT,      loy		( CLIPPERS )
 .word	>100D,64,1524	;ROGERS,      rodney
 .word	>100D,80,1528	;MURRAY,      lamond
 .word	>100D,75,1532	;RICHARDSON,  pooh
 .word	>100D,72,1536	;BARRY,       brent

 .word	>100D,76,1540	;VAN EXEL,    nick		( LAKERS )
 .word	>100D,83,1548	;CEBALLOS,    cedric
 .word	>100D,56,1958	;SCOTT,       byron
 .word	>100D,62,1552	;CAMPBELL,    elden
 .word	>100D,68,1556	;JONES,       eddie

 .word	>100D,97,1560	;MOURNING,    alonzo		( MIAMI )
 .word	>100D,80,1460	;HARDAWAY,    tim		
 .word	>100D,84,1572	;DANILOVIC,   sasha
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,70,1580	;BAKER,       vin		( MILWAUKEE )
 .word	>100D,60,2930	;ALLEN,       ray
 .word	>100D,72,1955	;LANG,        andrew
 .word	>100D,93,1584	;ROBINSON,    glen
 .word	>100D,77,1588	;RESPERT,     shawn

 .word	>100D,73,1612	;GUGLIOTTA,   tom		( MINNESOTTA )
 .word	>100D,75,2951	;MARBURY,     stephon
 .word	>100D,72,1616	;GARNETT,     kevin
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,68,1340	;GILL,        kendall		( NEW JERSEY )
 .word	>100D,52,2903	;KITTLES,     kerry
 .word	>100D,70,1872	;PACK,        robert
 .word	>100D,81,1624	;BRADLEY,     shawn
 .word	>100D,61,1632	;O'BANNON,    ed

 .word	>100D,82,1640	;EWING,       patrick		( NEW YORK )
 .word	>100D,65,2906	;WALLACE,     john
 .word	>100D,74,1344	;JOHNSON,     larry
 .word	>100D,70,1656	;STARKS,      john
 .word	>100D,76,1456	;HOUSTON,     allan

 .word	>100D,95,1660	;HARDAWAY,    anfernee		( ORLANDO )
 .word	>100D,84,1468	;SEIKALY,     rony
 .word	>100D,76,1664	;GRANT,       horace
 .word	>100D,65,1668	;ANDERSON,    nick
 .word	>100D,67,1672	;SCOTT,       dennis

 .word	>100D,72,2942	;IVERSON,     allen		( PHILADELPHIA )
;; .word	>100D,56,2915	;MINOR,       ryan
 .word	>100D,96,1680	;STACKHOUSE,  jerry
 .word	>100D,71,1684	;COLEMAN,     derrick
 .word	>100D,113,1688	;WEATHERSPOON,clarence
;REMOVE!!!
 .word	0,0,0

 .word	>100D,69,1700	;JOHNSON,     kevin		( PHOENIX )
 .word	>100D,101,1704	;TISDALE,     wayman
 .word	>100D,66,1708	;MANNING,     danny
 .word	>100D,80,1488	;HORRY,       robert
 .word	>100D,70,1492	;CASSELL,     sam

 .word	>100D,94,1724	;ROBINSON,    cliff		( PORTLAND )
 .word	>100D,94,1600	;RIDER,       isaiah
 .word	>100D,93,1728	;SABONIS,     arvydas
 .word	>100D,64,1620	;ANDERSON,    kenny
 .word	>100D,76,1736	;CHILDRESS,   randolph

 .word	>100D,74,1564	;OWENS,       billy		( SACRAMENTO )
 .word	>100D,89,1420	;ABDUL-RAUF,  mahmoud
 .word	>100D,82,1744	;RICHMOND,    mitch
 .word	>100D,85,1748	;GRANT,       brian
 .word	>100D,50,1756	;EDNEY,       tyus

 .word	>100D,69,1760	;ELLIOTT,     sean		( SAN ANTONIO )
 .word	>100D,92,1764	;ROBINSON,    david
 .word	>100D,90,1696	;MAXWELL,     vernon
 .word	>100D,74,1768	;JOHNSON,     avery
 .word	>100D,82,1776	;DEL NEGRO,   vinny
 
 .word	>100D,64,1780	;KEMP,        shawn		( SEATTLE )
 .word	>100D,74,1784	;PAYTON,      gary
 .word	>100D,57,1788	;SCHREMPF,    detlef
 .word	>100D,59,1792	;HAWKINS,     hersey
 .word	>100D,56,1796	;FORD,        sherell

 .word	>100D,59,1800	;ROGERS,      carlos		( TORONTO )
 .word	>100D,72,2927	;CAMBY,       marcus
 .word	>100D,92,1804	;STOUDAMIRE,  damon
 .word	>100D,74,1412	;JONES,       popeye
 .word	>100D,78,1740	;WILLIAMS,    walt

 .word	>100D,79,1820	;STOCKTON,    john		( UTAH )
 .word	>100D,68,1824	;MALONE,      karl
 .word	>100D,70,1828	;HORNACEK,    jeff
 .word	>100D,64,1836	;MORRIS,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,78,1840	;ANTHONY,     greg		( VANCOUVER )
 .word	>100D,66,1844	;EDWARDS,     blue
 .word	>100D,74,1852	;REEVES,      bryant
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,77,1720	;STRICKLAND,  rod		( WASHINGTON )
 .word	>100D,53,1864	;WEBBER,      chris
 .word	>100D,74,1860	;HOWARD,      juwan
 .word	>100D,92,1876	;MURESAN,     gheorge
 .word	>100D,69,1868	;CHEANEY,     calbert


***********
***********
pass_speech		;'TO player name'

 .word	>100D,54,1307	;to BLAYLOCK,    mookie		( ALTANTA HAWKS )
 .word	>100D,67,1427	;to MUTUMBO,     dekembe
 .word	>100D,43,1311	;to SMITH,       steve
 .word	>100D,43,1607	;to LAETNER,     christian
 .word	>100D,43,1319	;to NORMAN,      ken

 .word	>100D,42,1323	;to BROWN,       dee		( BOSTON )
 .word	>100D,35,2914	;to HAMER,       steve
 .word	>100D,40,1327	;to BARROS,      dana
 .word	>100D,44,1335	;to RADJA,       dino
 .word	>100D,43,1339	;to FOX,         rick

 .word	>100D,42,1351	;to RICE,        glen		( CHARLOTTE )
 .word	>100D,60,1647	;to MASON,       anthony
 .word	>100D,49,1547	;to DIVAC,       vlade
 .word	>100D,41,1355	;to ZIDEK,       george
 .word	>100D,36,1359	;to CURRY,       del

 .word	>100D,41,1363	;to PIPPEN,      scottie	( CHICAGO )
 .word	>100D,38,1367	;to RODMAN,      dennis
 .word	>100D,47,1371	;to KUKOC,       toni
 .word	>100D,56,1375	;to LONGLEY,     luke
 .word	>100D,44,1379	;to KERR,        steve

 .word	>100D,42,1383	;to HILL,        tyrone		( CLEVELAND )
 .word	>100D,51,1387	;to MILLS,       chris
 .word	>100D,44,1391	;to PHILLS,      bobby
 .word	>100D,39,1395	;to BRANDON,     terrell
 .word	>100D,38,1399	;to FERRY,       danny

 .word	>100D,41,1407	;to KIDD,        jason		( DALLAS )
 .word	>100D,46,1651	;to HARPER,      derek
 .word	>100D,57,1403	;to JACKSON,     jim
 .word	>100D,62,1331	;to MONTROSS,    eric
 .word	>100D,59,1411	;to MASHBURN,    jamal

 .word	>100D,58,1431	;to McDYESS,     antonio	( DENVER )
 .word	>100D,58,1755	;to MARCIULIONIS,sarunas
 .word	>100D,57,1519	;to JACKSON,     mark
 .word	>100D,38,1439	;to ELLIS,       dale
;REMOVE!!!
 .word	0,0,0

 .word	>100D,42,1447	;to HILL,        grant		( DETROIT )
;; .word	>100D,41,2956	;to RILEY,       ron
 .word	>100D,61,1443	;to DUMARS,      joe
 .word	>100D,34,1455	;to THORPE,      otis
 .word	>100D,44,1303	;to AUGMON,      stacey
;REMOVE!!!
 .word	0,0,0

 .word	>100D,52,1467	;to SPREWELL,    latrell	( GOLDEN STATE )
 .word	>100D,46,1679	;to KONCAK,      jon
 .word	>100D,43,1475	;to SMITH,       joe
 .word	>100D,52,1479	;to MULLIN,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,64,1483	;to OLAJUWAN,    hakeem		( HOUSTON )
 .word	>100D,45,2911	;to HARRINGTON,  othella
 .word	>100D,51,1487	;to DREXLER,     clyde
 .word	>100D,40,1571	;to WILLIS,      kevin
;REMOVE!!!
 .word	0,0,0

 .word	>100D,48,1503	;to MILLER,      reggie		( INDIANA )
 .word	>100D,48,2938	;to DAMPIER,     erick
 .word	>100D,38,1435	;to ROSE,        jalen
 .word	>100D,55,1511	;to SMITS,       rik
 .word	>100D,43,1507	;to DAVIS,       dale

 .word	>100D,36,1523	;to VAUGHT,      loy		( CLIPPERS )
 .word	>100D,43,1527	;to ROGERS,      rodney
 .word	>100D,39,1531	;to MURRAY,      lamond
 .word	>100D,54,1535	;to RICHARDSON,  pooh
 .word	>100D,43,1539	;to BARRY,       brent

 .word	>100D,54,1543	;to VAN EXEL,    nick		( LAKERS )
 .word	>100D,54,1551	;to CEBALLOS,    cedric
 .word	>100D,40,1960	;to SCOTT,       byron
 .word	>100D,46,1555	;to CAMPBELL,    elden
 .word	>100D,49,1559	;to JONES,       eddie

 .word	>100D,44,1563	;to MOURNING,    alonzo		( MIAMI )
 .word	>100D,56,1463	;to HARDAWAY,    tim		
 .word	>100D,58,1575	;to DANILOVIC,   sasha
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,49,1583	;to BAKER,       vin		( MILWAUKEE )
 .word	>100D,44,2932	;to ALLEN,       ray
 .word	>100D,45,1957	;to LANG,        andrew
 .word	>100D,70,1587	;to ROBINSON,    glen
 .word	>100D,51,1591	;to RESPERT,     shawn

 .word	>100D,52,1615	;to GUGLIOTTA,   tom		( MINNESOTTA )
 .word	>100D,40,2953	;to MARBURY,     stephon
 .word	>100D,50,1619	;to GARNETT,     kevin
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,40,1343	;to GILL,        kendall	( NEW JERSEY )
 .word	>100D,41,2905	;to KITTLES,     kerry
 .word	>100D,41,1875	;to PACK,        robert
 .word	>100D,53,1627	;to BRADLEY,     shawn
 .word	>100D,45,1635	;to O'BANNON,    ed

 .word	>100D,43,1643	;to EWING,       patrick	( NEW YORK )
 .word	>100D,39,2908	;to WALLACE,     john
 .word	>100D,48,1347	;to JOHNSON,     larry
 .word	>100D,45,1659	;to STARKS,      john
 .word	>100D,54,1459	;to HOUSTON,     allan

 .word	>100D,56,1663	;to HARDAWAY,    anfernee	( ORLANDO )
 .word	>100D,55,1471	;to SEIKALY,     rony
 .word	>100D,43,1667	;to GRANT,       horace
 .word	>100D,43,1671	;to ANDERSON,    nick
 .word	>100D,45,1675	;to SCOTT,       dennis

 .word	>100D,53,2944	;to IVERSON,     allen		( PHILADELPHIA )
;; .word	>100D,38,2917	;to MINOR,       ryan
 .word	>100D,69,1683	;to STACKHOUSE,  jerry
 .word	>100D,46,1687	;to COLEMAN,     derrick
 .word	>100D,75,1691	;to WEATHERSPOON,clarence
;REMOVE!!!
 .word	0,0,0

 .word	>100D,48,1703	;to JOHNSON,     kevin		( PHOENIX )
 .word	>100D,61,1707	;to TISDALE,     wayman
 .word	>100D,38,1711	;to MANNING,     danny
 .word	>100D,51,1491	;to HORRY,       robert
 .word	>100D,48,1495	;to CASSELL,     sam

 .word	>100D,70,1727	;to ROBINSON,    cliff		( PORTLAND )
 .word	>100D,53,1603	;to RIDER,       isaiah
 .word	>100D,49,1731	;to SABONIS,     arvydas
 .word	>100D,43,1623	;to ANDERSON,    kenny
 .word	>100D,48,1739	;to CHILDRESS,   randolph

 .word	>100D,51,1567	;to OWENS,       billy		( SACRAMENTO )
 .word	>100D,61,1423	;to ABDUL-RAUF,  mahmoud
 .word	>100D,51,1747	;to RICHMOND,    mitch
 .word	>100D,43,1751	;to GRANT,       brian
 .word	>100D,36,1759	;to EDNEY,       tyus

 .word	>100D,41,1763	;to ELLIOTT,     sean		( SAN ANTONIO )
 .word	>100D,70,1767	;to ROBINSON,    david
 .word	>100D,65,1699	;to MAXWELL,     vernon
 .word	>100D,48,1771	;to JOHNSON,     avery
 .word	>100D,54,1779	;to DEL NEGRO,   vinny
 
 .word	>100D,37,1783	;to KEMP,        shawn		( SEATTLE )
 .word	>100D,43,1787	;to PAYTON,      gary
 .word	>100D,41,1791	;to SCHREMPF,    detlef
 .word	>100D,44,1795	;to HAWKINS,     hersey
 .word	>100D,40,1799	;to FORD,        sherell

 .word	>100D,43,1803	;to ROGERS,      carlos		( TORONTO )
 .word	>100D,45,2929	;to CAMBY,       marcus
 .word	>100D,63,1807	;to STOUDAMIRE,  damon
 .word	>100D,49,1415	;to JONES,       popeye
 .word	>100D,45,1743	;to WILLIAMS,    walt

 .word	>100D,53,1823	;to STOCKTON,    john		( UTAH )
 .word	>100D,51,1827	;to MALONE,      karl
 .word	>100D,49,1831	;to HORNACEK,    jeff
 .word	>100D,39,1839	;to MORRIS,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,40,1843	;to ANTHONY,     greg		( VANCOUVER )
 .word	>100D,38,1847	;to EDWARDS,     blue
 .word	>100D,48,1855	;to REEVES,      bryant
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,51,1723	;to STRICKLAND,  rod		( WASHINGTON )
 .word	>100D,28,1867	;to WEBBER,      chris
 .word	>100D,43,1863	;to HOWARD,      juwan
 .word	>100D,63,1879	;to MURESAN,     gheorge
 .word	>100D,43,1871	;to CHEANEY,     calbert


***********
***********
name_speech 		;(last name only, excited)

 .word	>100D,44,1305	;BLAYLOCK,    mookie		( ALTANTA HAWKS )
 .word	>100D,58,1425	;MUTUMBO,     dekembe
 .word	>100D,33,1309	;SMITH,       steve
 .word	>100D,33,1605	;LAETNER,     christian
 .word	>100D,34,1317	;NORMAN,      ken

 .word	>100D,36,1321	;BROWN,       dee		( BOSTON )
 .word	>100D,26,2913	;HAMER,       steve
 .word	>100D,31,1325	;BARROS,      dana
 .word	>100D,35,1333	;RADJA,       dino
 .word	>100D,33,1337	;FOX,         rick

 .word	>100D,33,1349	;RICE,        glen		( CHARLOTTE )
 .word	>100D,51,1645	;MASON,       anthony
 .word	>100D,39,1545	;DIVAC,       vlade
 .word	>100D,32,1353	;ZIDEK,       george
 .word	>100D,27,1357	;CURRY,       del

 .word	>100D,31,1361	;PIPPEN,      scottie		( CHICAGO )
 .word	>100D,28,1365	;RODMAN,      dennis
 .word	>100D,38,1369	;KUKOC,       toni
 .word	>100D,47,1373	;LONGLEY,     luke
 .word	>100D,35,1377	;KERR,        steve

 .word	>100D,33,1381	;HILL,        tyrone		( CLEVELAND )
 .word	>100D,42,1385	;MILLS,       chris
 .word	>100D,35,1389	;PHILLS,      bobby
 .word	>100D,30,1393	;BRANDON,     terrell
 .word	>100D,28,1397	;FERRY,       danny

 .word	>100D,32,1405	;KIDD,        jason		( DALLAS )
 .word	>100D,37,1649	;HARPER,      derek
 .word	>100D,48,1401	;JACKSON,     jim
 .word	>100D,53,1329	;MONTROSS,    eric
 .word	>100D,50,1409	;MASHBURN,    jamal

 .word	>100D,49,1429	;McDYESS,     antonio		( DENVER )
 .word	>100D,49,1753	;MARCIULIONIS,sarunas
 .word	>100D,48,1517	;JACKSON,     mark
 .word	>100D,28,1437	;ELLIS,       dale
;REMOVE!!!
 .word	0,0,0

 .word	>100D,33,1445	;HILL,        grant		( DETROIT )
;; .word	>100D,31,2955	;RILEY,       ron
 .word	>100D,46,1441	;DUMARS,      joe
 .word	>100D,25,1453	;THORPE,      otis
 .word	>100D,34,1301	;AUGMON,      stacey
;REMOVE!!!
 .word	0,0,0

 .word	>100D,43,1465	;SPREWELL,    latrell		( GOLDEN STATE )
 .word	>100D,37,1677	;KONCAK,      jon
 .word	>100D,33,1473	;SMITH,       joe
 .word	>100D,43,1477	;MULLIN,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,55,1482	;OLAJUWAN,    hakeem		( HOUSTON )
 .word	>100D,36,2910	;HARRINGTON,  othella
 .word	>100D,41,1485	;DREXLER,     clyde
 .word	>100D,31,1569	;WILLIS,      kevin
;REMOVE!!!
 .word	0,0,0

 .word	>100D,39,1501	;MILLER,      reggie		( INDIANA )
 .word	>100D,39,2937	;DAMPIER,     erick
 .word	>100D,29,1433	;ROSE,        jalen
 .word	>100D,46,1509	;SMITS,       rik
 .word	>100D,34,1505	;DAVIS,       dale

 .word	>100D,27,1521	;VAUGHT,      loy		( CLIPPERS )
 .word	>100D,34,1525	;ROGERS,      rodney
 .word	>100D,30,1529	;MURRAY,      lamond
 .word	>100D,44,1533	;RICHARDSON,  pooh
 .word	>100D,33,1537	;BARRY,       brent

 .word	>100D,44,1541	;VAN EXEL,    nick		( LAKERS )
 .word	>100D,44,1549	;CEBALLOS,    cedric
 .word	>100D,32,1959	;SCOTT,       byron
 .word	>100D,37,1553	;CAMPBELL,    elden
 .word	>100D,40,1557	;JONES,       eddie

 .word	>100D,35,1561	;MOURNING,    alonzo		( MIAMI )
 .word	>100D,47,1461	;HARDAWAY,    tim		
 .word	>100D,49,1573	;DANILOVIC,   sasha
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,39,1581	;BAKER,       vin		( MILWAUKEE )
 .word	>100D,35,2931	;ALLEN,       ray
 .word	>100D,36,1956	;LANG,        andrew
 .word	>100D,61,1585	;ROBINSON,    glen
 .word	>100D,41,1589	;RESPERT,     shawn

 .word	>100D,43,1613	;GUGLIOTTA,   tom		( MINNESOTTA )
 .word	>100D,31,2952	;MARBURY,     stephon
 .word	>100D,41,1617	;GARNETT,     kevin
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,31,1341	;GILL,        kendall		( NEW JERSEY )
 .word	>100D,32,2904	;KITTLES,     kerry
 .word	>100D,32,1873	;PACK,        robert
 .word	>100D,43,1625	;BRADLEY,     shawn
 .word	>100D,36,1633	;O'BANNON,    ed

 .word	>100D,42,1641	;EWING,       patrick		( NEW YORK )
 .word	>100D,30,2907	;WALLACE,     john
 .word	>100D,38,1345	;JOHNSON,     larry
 .word	>100D,36,1657	;STARKS,      john
 .word	>100D,44,1457	;HOUSTON,     allan

 .word	>100D,47,1661	;HARDAWAY,    anfernee		( ORLANDO )
 .word	>100D,46,1469	;SEIKALY,     rony
 .word	>100D,34,1665	;GRANT,       horace
 .word	>100D,33,1669	;ANDERSON,    nick
 .word	>100D,36,1673	;SCOTT,       dennis

 .word	>100D,44,2943	;IVERSON,     allen		( PHILADELPHIA )
;; .word	>100D,28,2916	;MINOR,       ryan
 .word	>100D,59,1681	;STACKHOUSE,  jerry
 .word	>100D,37,1685	;COLEMAN,     derrick
 .word	>100D,66,1689	;WEATHERSPOON,clarence
;REMOVE!!!
 .word	0,0,0

 .word	>100D,38,1701	;JOHNSON,     kevin		( PHOENIX )
 .word	>100D,51,1705	;TISDALE,     wayman
 .word	>100D,28,1709	;MANNING,     danny
 .word	>100D,42,1489	;HORRY,       robert
 .word	>100D,38,1493	;CASSELL,     sam

 .word	>100D,61,1725	;ROBINSON,    cliff		( PORTLAND )
 .word	>100D,43,1601	;RIDER,       isaiah
 .word	>100D,40,1729	;SABONIS,     arvydas
 .word	>100D,33,1621	;ANDERSON,    kenny
 .word	>100D,38,1737	;CHILDRESS,   randolph

 .word	>100D,41,1565	;OWENS,       billy		( SACRAMENTO )
 .word	>100D,51,1421	;ABDUL-RAUF,  mahmoud
 .word	>100D,41,1745	;RICHMOND,    mitch
 .word	>100D,34,1749	;GRANT,       brian
 .word	>100D,27,1757	;EDNEY,       tyus

 .word	>100D,32,1761	;ELLIOTT,     sean		( SAN ANTONIO )
 .word	>100D,61,1765	;ROBINSON,    david
 .word	>100D,56,1697	;MAXWELL,     vernon
 .word	>100D,38,1769	;JOHNSON,     avery
 .word	>100D,45,1777	;DEL NEGRO,   vinny
 
 .word	>100D,28,1781	;KEMP,        shawn		( SEATTLE )
 .word	>100D,33,1785	;PAYTON,      gary
 .word	>100D,32,1789	;SCHREMPF,    detlef
 .word	>100D,35,1793	;HAWKINS,     hersey
 .word	>100D,31,1797	;FORD,        sherell

 .word	>100D,34,1801	;ROGERS,      carlos		( TORONTO )
 .word	>100D,36,2928	;CAMBY,       marcus
 .word	>100D,54,1805	;STOUDAMIRE,  damon
 .word	>100D,40,1413	;JONES,       popeye
 .word	>100D,36,1741	;WILLIAMS,    walt

 .word	>100D,44,1821	;STOCKTON,    john		( UTAH )
 .word	>100D,42,1825	;MALONE,      karl
 .word	>100D,40,1829	;HORNACEK,    jeff
 .word	>100D,30,1837	;MORRIS,      chris
;REMOVE!!!
 .word	0,0,0

 .word	>100D,31,1841	;ANTHONY,     greg		( VANCOUVER )
 .word	>100D,29,1845	;EDWARDS,     blue
 .word	>100D,39,1853	;REEVES,      bryant
;REMOVE!!!
 .word	0,0,0
 .word	0,0,0

 .word	>100D,42,1721	;STRICKLAND,  rod		( WASHINGTON )
 .word	>100D,18,1865	;WEBBER,      chris
 .word	>100D,34,1861	;HOWARD,      juwan
 .word	>100D,54,1877	;MURESAN,     gheorge
 .word	>100D,34,1869	;CHEANEY,     calbert


;FIX!!!
;JEFF:	I guess there is no distinction between superstar guests and Special
;guests - they will all be treated as one big table throughout the game...
***********
***********
special_name_speech
	.word	>100D,32,2290		;0  JEFF JOHNSON
	.word	>100D,31,2276		;1  SAL DIVITA
	.word	>100D,32,2272		;2  TURMELL
	.word	>100D,28,2286		;3  THOMPSON
	.word	>100D,22,2278		;4  GEER 
	.word	>100D,33,2288		;5  CARLTON
	.word	>100D,28,2280		;6  HEDRICK
	.word	>100D,23,2274		;7  JOHN HEY
	.word	>100D,43,2266		;8  AIR MORRIS
	.word	>100D,30,2268		;9  STEVE BARDO
	.word	>100D,35,2270		;10 MINIFEE
	.word	>100D,41,2282		;11 MARTINEZ
	.word	>100D,36,2284		;12 PESINA
	.word	>0105,36,2250		;13 LIPTAK
	.word	>0105,46,1910		;14 EDDIE
	.word	>0105,26,1920		;15 MIKE V.
	.word	>0105,26,1888		;16 JAMIE R.
	.word	>0105,26,1888		;17 NICK E.
	.word	>0105,26,1888		;18 J. ROOT
	.word	>0105,26,1888		;19 MEDNICK
	.word	>0105,26,1888		;20 DAN R.
	.word	>0105,26,1888		;21 PAT F.
	.word	>0105,26,1888		;22 ED BOON
	.word	>0105,26,1888		;23 J. TOBIAS
	.word	>0105,26,1888		;24 OURSLER
	.word	>0105,26,1888		;25 JASON S.
	.word	>0105,26,1888		;26 QUINN
	.word	>0105,26,1888		;27 M. PERRY
	.word	>0105,26,1888		;28 N. FUNK
	.word	>0105,26,1888		;29 MDOC
	.word	>0105,26,1888		;30 BUD
	.word	>0105,54,1877		;31 MARIUS
	.word	>0105,26,1888		;32 MUNDAY
	.word	>0105,26,1888		;33 NORTH
	.word	>0105,26,1888		;34 AMRICH
	.word	>0105,26,1888		;35 JIGGETS
	.word	>0105,26,1888		;36 ZIRIN
	.word	>0105,26,1888		;37 HEITH BETTLEMAN
	.word	>0105,30,1928		;38 MATT BETTLEMAN
	.word	>0105,36,2250		;39 KEVIN DAY

;Superstar special guests
 .word	>100D,31,1361	;PIPPEN,      scottie
 .word	>100D,28,1365	;RODMAN,      dennis
 .word	>100D,38,1345	;JOHNSON,     larry
 .word	>100D,33,1349	;RICE,        glen
 .word	>100D,32,1405	;KIDD,        jason
 .word	>100D,58,1425	;MUTUMBO,     dekembe
 .word	>100D,33,1445	;HILL,        grant
 .word	>100D,55,1482	;OLAJUWAN,    hakeem
 .word	>100D,39,1501	;MILLER,      reggie
 .word	>100D,46,1509	;SMITS,       rik
 .word	>100D,35,1561	;MOURNING,    alonzo
 .word	>100D,61,1585	;ROBINSON,    glen
 .word	>100D,42,1641	;EWING,       patrick
 .word	>100D,36,1657	;STARKS,      john
 .word	>100D,47,1661	;HARDAWAY,    anfernee
 .word	>100D,34,1665	;GRANT,       horace
 .word	>100D,59,1681	;STACKHOUSE,  jerry
 .word	>100D,61,1725	;ROBINSON,    cliff
 .word	>100D,61,1765	;ROBINSON,    david
 .word	>100D,32,1761	;ELLIOTT,     sean
 .word	>100D,28,1781	;KEMP,        shawn
 .word	>100D,42,1825	;MALONE,      karl
 .word	>100D,18,1865	;WEBBER,      chris
 .word	>100D,54,1877	;MURESAN,     gheorge

;New Superstar special guests removed from teams
 .word	>100D,46,1417	;McCLOUD,     george
 .word	>100D,42,1449	;MILLS,       terry
 .word	>100D,33,1497	;SMITH,       kenny
 .word	>100D,43,1513	;McKEE,       derek
 .word	>100D,36,1962	;CHAPMAN,     rex
 .word	>100D,34,1593	;BENJAMIN,    benoit
 .word	>100D,29,1597	;DOUGLAS,     sherman
 .word	>100D,31,1965	;WEBB,        spud
 .word	>100D,30,1629	;GILLIAM,     armon
 .word	>100D,29,1637	;EDWARDS,     kevin
 .word	>100D,36,1653	;OAKLEY,      charles
 .word	>100D,31,1968	;RUFFIN,      trevor
 .word	>100D,36,1713	;PERSON,      wesley
 .word	>100D,42,1717	;FINLEY,      michael
 .word	>100D,36,1733	;WILLIAMS,    buck
 .word	>100D,36,1773	;PERSON,      chuck
 .word	>100D,36,1953	;ROBERTSON,   alvin
 .word	>100D,39,1813	;MILLER,      oliver
 .word	>100D,30,1817	;MURRAY,      tracy
 .word	>100D,38,1833	;BENOIT,      david
 .word	>100D,36,1959	;SCOTT,       byron
 .word	>100D,37,1857	;MURDOCK,     eric


***********
***********
special_pass_speech
	.word	>100D,41,2291		;0  JEFF JOHNSON
	.word	>100D,41,2277		;1  SAL DIVITA
	.word	>100D,41,2273		;2  TURMELL
	.word	>100D,38,2287		;3  THOMPSON
	.word	>100D,31,2279		;4  GEER 
	.word	>100D,42,2289		;5  CARLTON
	.word	>100D,37,2281		;6  HEDRICK
	.word	>100D,32,2275		;7  JOHN HEY
	.word	>100D,52,2267		;8  AIR MORRIS
	.word	>100D,39,2269		;9  STEVE BARDO
	.word	>100D,44,2271		;10 MINIFEE
	.word	>100D,51,2283		;11 MARTINEZ
	.word	>100D,45,2285		;12 PESINA
	.word	>0105,45,2251		;13 LIPTAK
	.word	>0105,55,1911		;14 EDDIE
	.word	>0105,35,1921		;15 MIKE V.
	.word	>0105,35,1889		;16 JAMIE R.
	.word	>0105,35,1889		;17 NICK E.
	.word	>0105,35,1889		;18 J. ROOT
	.word	>0105,35,1889		;19 MEDNICK
	.word	>0105,35,1889		;20 DAN R.
	.word	>0105,35,1889		;21 PAT F.
	.word	>0105,35,1889		;22 ED BOON
	.word	>0105,35,1889		;23 J. TOBIAS
	.word	>0105,35,1889		;24 OURSLER
	.word	>0105,35,1889		;25 JASON S.
	.word	>0105,35,1889		;26 QUINN
	.word	>0105,35,1889		;27 M. PERRY
	.word	>0105,35,1889		;28 N. FUNK
	.word	>0105,35,1889		;29 MDOC
	.word	>0105,35,1889		;30 BUD
	.word	>0105,63,1879		;31 MARIUS
	.word	>0105,35,1889		;32 MUNDAY
	.word	>0105,35,1889		;33 NORTH
	.word	>0105,35,1889		;34 AMRICH
	.word	>0105,35,1889		;35 JIGGETS
	.word	>0105,35,1889		;36 ZIRIN
	.word	>0105,35,1889		;37 HEITH BETTLEMAN
	.word	>0105,39,1929		;38 MATT BETTLEMAN
	.word	>0105,45,2251		;39 KEVIN DAY

;Superstar special guests
 .word	>100D,41,1363	;to PIPPEN,      scottie
 .word	>100D,38,1367	;to RODMAN,      dennis
 .word	>100D,48,1347	;to JOHNSON,     larry
 .word	>100D,42,1351	;to RICE,        glen
 .word	>100D,41,1407	;to KIDD,        jason
 .word	>100D,67,1427	;to MUTUMBO,     dekembe
 .word	>100D,42,1447	;to HILL,        grant
 .word	>100D,64,1483	;to OLAJUWAN,    hakeem
 .word	>100D,48,1503	;to MILLER,      reggie
 .word	>100D,55,1511	;to SMITS,       rik
 .word	>100D,44,1563	;to MOURNING,    alonzo
 .word	>100D,70,1587	;to ROBINSON,    glen
 .word	>100D,43,1643	;to EWING,       patrick
 .word	>100D,45,1659	;to STARKS,      john
 .word	>100D,56,1663	;to HARDAWAY,    anfernee
 .word	>100D,43,1667	;to GRANT,       horace
 .word	>100D,69,1683	;to STACKHOUSE,  jerry
 .word	>100D,70,1727	;to ROBINSON,    cliff
 .word	>100D,70,1767	;to ROBINSON,    david
 .word	>100D,41,1763	;to ELLIOTT,     sean
 .word	>100D,37,1783	;to KEMP,        shawn
 .word	>100D,51,1827	;to MALONE,      karl
 .word	>100D,28,1867	;to WEBBER,      chris
 .word	>100D,63,1879	;to MURESAN,     gheorge

;New Superstar special guests removed from teams
 .word	>100D,56,1419	;to McCLOUD,     george
 .word	>100D,51,1451	;to MILLS,       terry
 .word	>100D,43,1499	;to SMITH,       kenny
 .word	>100D,52,1515	;to McKEE,       derek
 .word	>100D,45,1963	;to CHAPMAN,     rex
 .word	>100D,43,1595	;to BENJAMIN,    benoit
 .word	>100D,38,1599	;to DOUGLAS,     sherman
 .word	>100D,41,1966	;to WEBB,        spud
 .word	>100D,39,1631	;to GILLIAM,     armon
 .word	>100D,38,1639	;to EDWARDS,     kevin
 .word	>100D,45,1655	;to OAKLEY,      charles
 .word	>100D,40,1969	;to RUFFIN,      trevor
 .word	>100D,45,1715	;to PERSON,      wesley
 .word	>100D,51,1719	;to FINLEY,      michael
 .word	>100D,45,1735	;to WILLIAMS,    buck
 .word	>100D,45,1775	;to PERSON,      chuck
 .word	>100D,45,1954	;to ROBERTSON,   alvin
 .word	>100D,48,1815	;to MILLER,      oliver
 .word	>100D,39,1819	;to MURRAY,      tracy
 .word	>100D,48,1835	;to BENOIT,      david
 .word	>100D,45,1960	;to SCOTT,       byron
 .word	>100D,46,1859	;to MURDOCK,     eric

******************************************************************************

tm_name_spch_tbl
 .word	>100D,25,>4b2		;00 ATLANTA		"Hawks"
 .word	>100D,33,>4b5		;01 BOSTON		"Celtics"
 .word	>100D,22,>4b8		;02 CHARLOTTE		"Hornets"
 .word	>100D,25,>4bb		;03 CHICAGO		"Bulls"
 .word	>100D,41,>4be		;04 CLEVELAND		"Cavaliers"
 .word	>100D,29,>4c1		;05 DALLAS		"Maverick"
 .word	>100D,24,>4c4		;06 DENVER		"Nuggets"
 .word	>100D,37,>4c7		;07 DETROIT		"Pistons"
 .word	>100D,39,>4ca		;08 GOLDEN STATE	"Warriors"
 .word	>100D,28,>4cd		;09 HOUSTON		"Rockets"
 .word	>100D,37,>4d0		;10 INDIANA		"Pacers"
 .word	>100D,28,>4d3		;11 L.A. CLIPPERS	"Clippers"
 .word	>100D,36,>4d6		;12 L.A. LAKERS		"Lakers"
 .word	>100D,20,>4d9		;13 MIAMI		"Heat"
 .word	>100D,24,>4dc		;14 MILWAUKEE		"Bucks"
 .word	>100D,45,>4df		;15 MINNESOTTA		"Timberwolves"
 .word	>100D,22,>4e2		;16 NEW JERSEY		"Nets"
 .word	>100D,27,>4e5		;17 NEW YORK		"Knicks"
 .word	>100D,28,>4e8		;18 ORLANDO		"Magic"
 .word	>100D,64,>4eb		;19 PHILADELPHIA	"Sixers"
 .word	>100D,31,>4ee		;20 PHOENIX		"Suns"
 .word	>100D,52,>4f1		;21 PORTLAND		"Blazers"
 .word	>100D,36,>4f4		;22 SACRAMENTO		"Kings"
 .word	>100D,40,>4f7		;23 SAN ANTONIO		"Spurs"
 .word	>100D,52,>4fa		;24 SEATTLE		"Supersonics"
 .word	>100D,39,>4fd		;26 TORONTO		"Raptors"
 .word	>100D,33,>500		;26 UTAH		"Jazz"
 .word	>100D,39,>503		;27 VANCOUVER		"Grizzlies"
 .word	>100D,22,>506		;28 WASHINGTON		"Bullets"
 .word	>100D,42,>818		;GOOD!!!
 .word	>100D,42,>818		;GOOD!!!

tm_city_spch_tbl
 .word	>100D,39,>4b1		;00 ATLANTA
 .word	>100D,30,>4b4		;01 BOSTON
 .word	>100D,31,>4b7		;02 CHARLOTTE
 .word	>100D,41,>4ba		;03 CHICAGO
 .word	>100D,28,>4bd		;04 CLEVELAND
 .word	>100D,27,>4c0		;05 DALLAS
 .word	>100D,25,>4c3		;06 DENVER
 .word	>100D,36,>4c6		;07 DETROIT
 .word	>100D,51,>4c9		;08 GOLDEN STATE
 .word	>100D,32,>4cc		;09 HOUSTON
 .word	>100D,39,>4cf		;10 INDIANA
 .word	>100D,49,>4d2		;11 L.A. CLIPPERS
 .word	>100D,49,>4d5		;12 L.A. LAKERS
 .word	>100D,37,>4d8		;13 MIAMI
 .word	>100D,39,>4db		;14 MILWAUKEE
 .word	>100D,39,>4de		;15 MINNESOTTA
 .word	>100D,38,>4e1		;16 NEW JERSEY
 .word	>100D,37,>4e4		;17 NEW YORK
 .word	>100D,41,>4e7		;18 ORLANDO
 .word	>100D,44,>4ea		;19 PHILADELPHIA
 .word	>100D,31,>4ed		;20 PHOENIX
 .word	>100D,29,>4f0		;21 PORTLAND
 .word	>100D,48,>4f3		;22 SACRAMENTO
 .word	>100D,57,>4f6		;23 SAN ANTONIO
 .word	>100D,34,>4f9		;24 SEATTLE
 .word	>100D,40,>4fc		;26 TORONTO
 .word	>100D,32,>4ff		;26 UTAH
 .word	>100D,38,>502		;27 VANCOUVER
 .word	>100D,44,>505		;28 WASHINGTON
 .word	>100D,42,>818		;GOOD!!!
 .word	>100D,42,>818		;GOOD!!!

full_tm_name_spch_tbl
 .word	>100D,71 ,>4b0		;00 ATLANTA		"Altanta Hawks"
 .word	>100D,82 ,>4b3		;01 BOSTON		"Boston Celtics"
 .word	>100D,74 ,>4b6		;02 CHARLOTTE		"Hornets"
 .word	>100D,81 ,>4b9		;03 CHICAGO		"Bulls"
 .word	>100D,93 ,>4bc		;04 CLEVELAND		"Cavaliers"
 .word	>100D,78 ,>4bf		;05 DALLAS		"Maverick"
 .word	>100D,72 ,>4c2		;06 DENVER		"Nuggets"
 .word	>100D,87 ,>4c5		;07 DETROIT		"Pistons"
 .word	>100D,101,>4c8		;08 GOLDEN STATE	"Warriors"
 .word	>100D,82 ,>4cb		;09 HOUSTON		"Rockets"
 .word	>100D,86 ,>4ce		;10 INDIANA		"Pacers"
 .word	>100D,88 ,>4d1		;11 L.A. CLIPPERS	"Clippers"
 .word	>100D,96 ,>4d4		;12 L.A. LAKERS		"Lakers"
 .word	>100D,64 ,>4d7		;13 MIAMI		"Heat"
 .word	>100D,82 ,>4da		;14 MILWAUKEE		"Bucks"
 .word	>100D,94 ,>4dd		;15 MINNESOTTA		"Timberwolves"
 .word	>100D,81 ,>4e0		;16 NEW JERSEY		"Nets"
 .word	>100D,76 ,>4e3		;17 NEW YORK		"Knicks"
 .word	>100D,81 ,>4e6		;18 ORLANDO		"Magic"
 .word	>100D,117,>4e9		;19 PHILADELPHIA	"Sixers"
 .word	>100D,72 ,>4ec		;20 PHOENIX		"Suns"
 .word	>100D,93 ,>4ef		;21 PORTLAND		"Blazers"
 .word	>100D,95 ,>4f2		;22 SACRAMENTO		"Kings"
 .word	>100D,100,>4f5		;23 SAN ANTONIO		"Spurs"
 .word	>100D,100,>4f8		;24 SEATTLE		"Supersonics"
 .word	>100D,93 ,>4fb		;26 TORONTO		"Raptors"
 .word	>100D,82 ,>4fe		;26 UTAH		"Jazz"
 .word	>100D,104,>501		;27 VANCOUVER		"Grizzlies"
 .word	>100D,82 ,>504		;28 WASHINGTON		"Bullets"
 .word	>100D,60 ,>504		;GOOD!!!
 .word	>100D,60 ,>504		;GOOD!!!


scr_nbr_tbl
 .word	>110D,23,>87c,0		;0 ;(nothing)
 .word	>110D,16,>87d,0		;1
 .word	>110D,17,>87e,0		;2
 .word	>110D,15,>87f,0		;3
 .word	>110D,20,>880,0		;4
 .word	>110D,22,>881,0		;5
 .word	>110D,21,>882,0		;6
 .word	>110D,20,>883,0		;7
 .word	>110D,20,>884,0		;8
 .word	>110D,24,>885,0		;9
 .word	>110D,22,>886,0		;10
 .word	>110D,25,>887,0		;11
 .word	>110D,25,>888,0		;12
 .word	>110D,26,>889,0		;13
 .word	>110D,29,>88a,0		;14
 .word	>110D,26,>88b,0		;15
 .word	>110D,37,>88c,0		;16
 .word	>110D,32,>88d,0		;17
 .word	>110D,28,>88e,0		;18
 .word	>110D,29,>88f,0		;19

 .word	>110D,19,>890,0		;20
 .word	>110D,25,>891,0		;21
 .word	>110D,25,>892,0		;22
 .word	>110D,25,>893,0		;23
 .word	>110D,25,>894,0		;24
 .word	>110D,25,>895,0		;25
 .word	>110D,25,>896,0		;26
 .word	>110D,25,>897,0		;27
 .word	>110D,25,>898,0		;28
 .word	>110D,25,>899,0		;29

 .word	>110D,37,>89a,0		;30
 .word	>110D,37,>89b,0		;31
 .word	>110D,37,>89c,0		;32
 .word	>110D,37,>89d,0		;33
 .word	>110D,37,>89e,0		;34
 .word	>110D,37,>89f,0		;35
 .word	>110D,37,>8a0,0		;36
 .word	>110D,37,>8a1,0		;37
 .word	>110D,37,>8a2,0		;38
 .word	>110D,37,>8a3,0		;39

 .word	>110D,38,>8a4,0		;40
 .word	>110D,38,>8a5,0		;41
 .word	>110D,38,>8a6,0		;42
 .word	>110D,38,>8a7,0		;43
 .word	>110D,38,>8a8,0		;44
 .word	>110D,38,>8a9,0		;45
 .word	>110D,38,>8aa,0		;46
 .word	>110D,38,>8ab,0		;47
 .word	>110D,38,>8ac,0		;48
 .word	>110D,38,>8ad,0		;49

 .word	>110D,34,>8ae,0		;50
 .word	>110D,34,>8af,0		;51
 .word	>110D,34,>8b0,0		;52
 .word	>110D,34,>8b1,0		;53
 .word	>110D,34,>8b2,0		;54
 .word	>110D,34,>8b3,0		;55
 .word	>110D,34,>8b4,0		;56
 .word	>110D,34,>8b5,0		;57
 .word	>110D,34,>8b6,0		;58
 .word	>110D,34,>8b7,0		;59

	       
STAB_END

#*****************************************************************************
*
*
 SUBR	lob_ball_speech

;DJT Start
	movk	9,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#lob_spch_tbl,a0
	move	*a0,a0,L
#sayo
	calla	snd_play1
	rets

#lob_spch_tbl
	.long	lev_tmate_sp
	.long	lob_pass_sp
	.long	scp_tmate_sp
;DJT Start
	.long	the_scoop_sp
;DJT End
	.long	lob_pass_sp
	.long	tosses_it_sp
	.long	lob_pass_sp
	.long	passes_sp
	.long	dble_dnk_sp
	.long	dble_dnk2_sp

#*****************************************************************************
*
*
 SUBR	start_crowd_noise
 	
	movi	crwdbed_tune,a0,L		;indoor snd
	move	@pup_court,a14
	jrz	scn_1				;br=indoor court
	movi	crwdbd2_tune,a0,L		;outdoor snd
scn_1	calla	snd_play1
	rets
		

#*****************************************************************************
* 			Halftime speech
*
* INPUT: reg a0 - player number
*
 SUBR	best_plyr_speech

	PUSH	a0
	movi	hlftm_ldr_sp,a14,L
	move	@gmqrtr,a1
	srl	2,a1
	jrz	#bsp_1				;br=halftime
	movi	gmevr_ldr_sp,a14,L

#bsp_1	movi	sound_ram,a1,L
	move	a14,*a1+,L
	move	*a14(16),a14,W
	move	a14,*a1+,W

	move	@spch_name_ram+32,a14,L		;plyr 1 is best
	subk	1,a0
	jrlt	#syp
	move	@spch_name_ram+96,a14,L		;plyr 2
	subk	1,a0
	jrlt	#syp
	move	@spch_name_ram+160,a14,L	;plyr 4
	subk	1,a0
	jrlt	#syp
	move	@spch_name_ram+224,a14,L	;plyr 3
#syp
	move	a14,*a1+,L

	movi	-1,a14
	move	a14,*a1,W

	movi	sound_ram,a0,L
	calla	script_play1
	PULL	a0
	rets



#*****************************************************************************
* 			Ball hit backboard speech process
*
* a8 = * ball obj
*
 SUBR	backbrd_hit_speech

	move	@bkbrd_proc_flg,a14
	jrnz	#die

	movk	1,a14
	move	a14,@bkbrd_proc_flg

	SLEEPK	7

	move	@ballrimhitcnt,a14
	jrnz	#done
	move	*a8(OXVEL),a0,L
	abs	a0			;Should we make a bbrd bounce sound?
	cmpi	>1fff,a0		;!!! Min XVEL to make sound
	jrlt	#soft

	SLEEPK	15

	move	@ballscorezhit,a0
	jrnz	#done			;br=ball hit score zone
	move	@ballrimhitcnt,a14
	cmpi	4,a14
	jrhs	#done

	movk	6,a0
	calla	rndrng0
	sll	5,a0
	addi	#bckbd_hit_sp_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
	SLEEP	70
	jruc	#done
#soft
	movi	250,a0
	calla	RNDPER
	jrls	#done
	SOUND1	soft_glas_sp
	SLEEP	70
#done
	clr	a14
	move	a14,@bkbrd_proc_flg
#die
 	DIE


#bckbd_hit_sp_tbl
	.long	kild_smne_sp
	.long	off_trgt_sp
	.long	wht_thnkg_sp
	.long	off_glass_sp
	.long	sht_stunk_sp
	.long	off_bkbrd_sp
	.long	wht_distr_sp

#*****************************************************************************
;a player has just launched a shot
;a0 = player number (0-3)
;a8 = * player obj
;a13 = * player process

 SUBR	shoots_speech

	PUSH	a1,a2

	move	a0,@plyr_shot
	callr	calc_score_diff

	clr	a0
	move	a0,@ugly_stat		;not ugly
	move	a0,@freakout		;no freakout on score

	callr	at_buzzer
	jrnc	#xshtspeech

	movi	350,a0
	calla	RNDPER
	jrls	#ntinfce

	move	*a13(plyr_o1dist),a14
	cmpi	40,a14				;this # is OK
	jrle	#infce
	move	*a13(plyr_o2dist),a14
	cmpi	40,a14				;this # is OK
	jrgt	#ntinfce
#infce
	move	*a13(plyr_seqflgs),a14
	btst	DUNK_B,a14
	jrnz	#ntinfce
	btst	LAYUP_B,a14
	jrnz	#ntinfce

	movk	3,a0
	calla	rndrng0
	sll	5,a0
	addi	#inface_sp_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
	jruc	#xshtspeech

#ntinfce	
	move	@shot_type,a0
	sll	5,a0			;x 32 bits
	addi	#shoots_table,a0
	move	*a0,a0,L
	call	a0

#xshtspeech
	PULL	a1,a2
	rets



#inface_sp_tbl
	.long	hnd_face_sp
	.long	frcd_shot_sp
	.long	frcd_shot_sp
	.long	difficult_sp
	

#shoots_table
	.long	#desperation
	.long	#long_range
	.long	#2_points
	.long	#3_points
	.long	#hook_shot
	.long	#lay_up
	.long	#finger_roll
	.long	#dunk_short
	.long	#dunk_med
	.long	#dunk_long
	.long	#fade_away
	.long	#fade_in

****************
#desperation

;DJT Start
	movk	11,a0
	move	@game_time,a14
	cmpi	>700,a14
	jrge	#fulltab
	movk	3,a0
#fulltab
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#desptab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#desptab
;DJT Start
	.long	hail_mary_sp
	.long	unlod_one_sp
	.long	wild_shot_sp
	.long	lfts_wild_sp

	.long	whyyyy_sp
	.long	whyyyy_sp
	.long	ill_shot_sp
	.long	ill_shot_sp
	.long	outof_rng_sp
	.long	outof_rg2_sp
	.long	out_cntrl_sp
	.long	difficult_sp

;DJT End
****************
#long_range

;DJT Start
	movk	7,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#longtab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#longtab
	.long	frm_l_rng_sp
	.long	frm_dwntn_sp
	.long	wild_shot_sp
	.long	difficult_sp
	.long	unlod_one_sp
	.long	frm_dwntn_sp
	.long	out_cntrl_sp
;DJT Start
	.long	outof_rng_sp
;DJT End

****************
#2_points

	callr	ugly_shot
	jrnc	#x2pts

;	callr	wideopen_speech
;	jrnc	#x2pts

	movi	#2ptab_near,a2

	move	@shot_distance,a0	;distance from hoop

	move	*a8(OZPOS),a14
	cmpi	1068,a14
	jrlo	#med			;br=above upper-post line
	cmpi	1226,a14
	jrhi	#med			;br=below lower-post line
	cmpi	155,a0			;beyond free-throw line ?
	jrls	#spch			;br=nope, near
	movi	#2ptab_far,a2
	jruc	#spch
#med
	movi	#2ptab_med,a2
#spch	movk	12,a0
	calla	rndrng0
	sll	5,a0
	add	a2,a0
	move	*a0,a0,L
	jrz	#cname
	calla	snd_play1
	jruc	#x2pts
#cname
	move	@plyr_shot,a0
	callr	call_player_name
#x2pts	rets



#2ptab_near
	.long	frm_paint_sp
	.long	shrt_rng_sp
	.long	for_two_sp
	.long	shoots3_sp
	.long	0
	.long	shoots1_sp
	.long	shrt_rng_sp
	.long	frm_paint_sp
	.long	for_two_sp
	.long	ltle_jmpr_sp
	.long	fires_jumpr
	.long	shoots2_sp
	.long	for_two_sp

#2ptab_med
	.long	from_15_sp
	.long	for_two_sp
	.long	fires_jumpr
	.long	frm_wing_sp
	.long	shoots1_sp
	.long	frm_post_sp
	.long	stp_n_pop_sp
	.long	from_15_sp
	.long	stp_n_pop_sp
	.long	shoots3_sp
	.long	for_two_sp
	.long	shoots2_sp
	.long	0

#2ptab_far
	.long	top_key_sp
	.long	from_18_sp
	.long	fires_jumpr
	.long	shoots1_sp
	.long	stp_n_pop_sp
	.long	fr_thw_ln_sp
	.long	lnch_jmpr_sp
	.long	tp_circle_sp
	.long	top_key_sp
	.long	for_two_sp
	.long	shoots2_sp
	.long	from_20_sp
	.long	fr_thw_ln_sp


****************
#3_points

	callr	ugly_shot
	jrnc	#x3pts

	callr	wideopen_speech
	jrnc	#x3pts

	movi	250,a0
	calla	RNDPER
	jrls	#x3p_1

	move	@game_time,a0,L		;don't call if clock run down
	cmpi	>2040906,a0
	jrge	#x3p_1

	move	@ballnumscored,a0	;# times last plyr scored
	jrz	#x3p_1
	SOUND1	agn_shoot_sp
	jruc	#x3pts

#x3p_1
;DJT Start
	movk	15,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#3ptab,a0
	move	*a0,a0,L
	calla	snd_play1
#x3pts
	rets

#3ptab
	.long	frm_dwntn_sp
	.long	frm_3_arc_sp
	.long	for_thre1_sp
	.long	frm_outsd_sp
	.long	bhd_3_arc_sp
	.long	frm_dwntn_sp
	.long	for_thre2_sp
	.long	shoots2_sp
	.long	from_arc_sp
	.long	for_thre3_sp
	.long	frm_outsd_sp
	.long	frm_dwntn_sp
	.long	frm_outsd_sp
	.long	from_arc_sp
	.long	frm_l_rng_sp
;DJT Start
	.long	fm_3pline_sp
;DJT End

****************
#hook_shot

	clr	a0
	move	a0,@skycalled

	callr	ugly_shot
	jrnc	#xhook

	movi	#hooktab_near,a2
	move	@shot_distance,a14	;distance from hoop
	cmpi	120,a14
	jrlt	#close
	movi	#hooktab_far,a2
#close
	movi	11,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	add	a2,a0
	move	*a0,a0,L
	jrz	#hname
	calla	snd_play1

	movk	1,a0
	move	a0,@skycalled
	rets
#hname
	move	@plyr_shot,a0
	callr	call_player_name
#xhook
	rets


#hooktab_near
	.long	baby_hook_sp
	.long	half_hook_sp
	.long	0
	.long	shoots1_sp
	.long	frm_post_sp
	.long	hook_shot_sp
	.long	finese_it_sp
	.long	baby_hook_sp
	.long	0
	.long	shrt_rng_sp
	.long	shoots2_sp
	.long	shoots3_sp

#hooktab_far
	.long	hook_shot_sp
	.long	sky_hook_sp
	.long	shoots1_sp
	.long	lft_hndr_sp
	.long	sky_hook2_sp
	.long	hook_shot_sp
	.long	sky_hook2_sp
	.long	rgt_hndr_sp
	.long	for_two_sp
	.long	0
	.long	sky_hook_sp
	.long	hook_shot_sp

****************
#lay_up
	
	move	@ballshotinair,a14
	move	*a13(plyr_num),a0
	cmp	a0,a14
	jrne	#nolay
#laysp
	movk	6,a0
	calla	rndrng0
	sll	5,a0
	addi	#layup_sp_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
#nolay
	rets


#layup_sp_tbl
	.long	lay_it_up_sp
	.long	layup_sp
	.long	he_layup_sp
	.long	finese_it_sp
	.long	fingr_rl2_sp
	.long	he_layup_sp
	.long	lay_it_up_sp


****************
#finger_roll

	movk	8,a0
	calla	rndrng0
	sll	5,a0
	addi	#fngr_roll_sp_tbl,a0
	move	*a0,a0,L
	jrz	#fngr
	calla	snd_play1
	rets
#fngr
	move	@plyr_shot,a0
	callr	call_player_name
	rets


#fngr_roll_sp_tbl
	.long	fires_jumpr
	.long	shoots3_sp
	.long	fingr_rl2_sp
	.long	lay_it_up_sp
	.long	figr_itin_sp
	.long	layup_sp
	.long	finese_it_sp
	.long	lay_it_up_sp
	.long	fingr_rol_sp


****************
#dunk_short

	move	@plyr_shot,a0
	callr	call_player_name
	rets


****************
#dunk_med

	move	@plyr_shot,a0
	callr	call_player_name
	rets

****************
#dunk_long

	move	@plyr_shot,a0
	callr	call_player_name
	rets


****************
#fade_away
	rets

****************
#fade_in
	rets


#*****************************************************************************
;a player has just scored a basket

 SUBR	scored_speech

	PUSH	a1,a2

	callr	blowout
	jrnc	#scrd2

	callr	onfire_speech
	jrnc	#scrd2

	callr	lucky_bounce
	jrnc	#scrd2

	movi	100,a0			;10% of time, say good again
	calla	RNDPER
	jrls	#scrd1

	move	@ballnumscored,a0
	cmpi	2,a0
	jrls	#scrd1			;br=hasnt scored a basket yet

	movi	score_agn_sp,a0,L
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#scrd
	movi	good_agn_sp,a0,L
#scrd	calla	snd_play1
	jruc	#scrd2

#scrd1
	move	@shot_type,a0
	sll	5,a0			;x 32 bits
	addi	#scored_table,a0
	move	*a0,a0,L
	call	a0

#scrd2
	PULL	a1,a2
	rets


#scored_table
	.long	#desperation
	.long	#long_range
	.long	#2_points
	.long	#3_points
	.long	#hook_shot
	.long	#lay_up
	.long	#finger_roll
	.long	#dunk_short
	.long	#dunk_med
	.long	#dunk_long
	.long	#fade_away
	.long	#fade_in

****************
#desperation
hotscored

	callr	itsgood
	jrnc	#xdesp

;DJT Start
	movk	6,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#desptab,a0
	move	*a0,a0,L
	calla	snd_play1
#xdesp
	rets

#desptab
	.long	ohmy
	.long	per_luck_sp
	.long	its_good_sp
	.long	incredble_sp
;DJT Start
	.long	kakaboom_sp
	.long	unbelieve_sp
	.long	luky_bskt_sp
;DJT End

****************
#long_range

	callr	itsgood
	jrnc	#xlong

;DJT Start
	movk	10,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#longtab,a0
	move	*a0,a0,L
	calla	snd_play1
#xlong
	rets

#longtab
	.long	whata_sht_sp
	.long	per_luck_sp
	.long	its_good_sp
	.long	great_sht_sp
;DJT Start
	.long	greatshot_sp
	.long	incrd_sht_sp
;DJT End
	.long	scores_sp
	.long	unbelieve_sp
	.long	amazing_sp
	.long	he_scores_sp
;DJT Start
	.long	scores2_sp
;DJT End

****************
#2_points

	movi	400,a0		;call 40% swishes
	callr	swish_speech
	jrnc	#x2pts

	movi	400,a0		;call backboard hit 25% time
	calla	RNDPER
	jrls	#nobkbd
	
	move	@ballbbhitcnt,a14
	jrz	#nobkbd
	
;DJT Start
	movk	5,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#2bkbdhit_tab,a0
	jruc	#2snd

#nobkbd
;	movi	800,a0		;call scores 20% time
;	calla	RNDPER
;	jrls	#x2pts

;DJT Start
	movk	19,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#2tab,a0
#2snd
	move	*a0,a0,L
	calla	snd_play1
#x2pts
	rets


#2bkbdhit_tab
	.long	banked_it_sp
	.long	off_glass_sp
	.long	off_bkbrd_sp
	.long	a_banker_sp
	.long	scores_sp
;DJT Start
	.long	scores2_sp
;DJT End

#2tab
	.long	it_falls_sp
	.long	scores_sp
	.long	hits_jmpr_sp
	.long	great_sht_sp
;DJT Start
	.long	greatshot_sp
;DJT End
	.long	bingo_sp
	.long	good_sht_sp
	.long	count_it_sp
	.long	chk_it_up_sp
	.long	good_4two_sp
	.long	goooood2_sp
	.long	yes_sp
;DJT Start
	.long	chalk_it_sp
;DJT End
	.long	book_it_sp
	.long	bingo_sp
	.long	smokin_sp
	.long	kncks_dwn_sp
	.long	dwn_well_sp
;DJT Start
	.long	and_drops_sp
	.long	scores2_sp
;DJT End


****************
#3_points

	callr	itsgood
	jrnc	#x3p

	movi	200,a0			;call 25% swishes
	callr	swish_speech
	jrnc	#x3p

;DJT Start
	movk	20,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#3ptab,a0
	move	*a0,a0,L
	jrz	#x3p
	calla	snd_play1
#x3p
	rets

#3ptab
	.long	its_good_sp
	.long	drains_it_sp
	.long	goooood2_sp
	.long	count_it_sp
;DJT Start
	.long	chalk_it_sp
;DJT End
	.long	scores_sp
	.long	money_bnk_sp
	.long	he_scores_sp
	.long	chk_it_up_sp
	.long	goooood_sp
	.long	bingo_sp
	.long	whata_sht_sp
	.long	a_trey_sp
	.long	thats_3_sp
	.long	good_4_3_sp
	.long	amazing_sp
	.long	smokin_sp
	.long	yes_sp
	.long	dwn_well_sp
;DJT Start
	.long	outstndng_sp
	.long	scores2_sp
;DJT End


****************
#hook_shot

	callr	itsgood
	jrnc	#xhook

	move	@skycalled,a0	;sky hook called?
	jrz	#nosky

	jruc	#2_points	;call like regular 2 pointer
	calla	snd_play1
	rets

#nosky
	movi	great_sht_sp,a0
	calla	snd_play1

#xhook
	rets


****************
#lay_up

	movk	3,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#laytab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#laytab
	.long	nicly_dne_sp
	.long	fancy
	.long	got_skilz_sp
	.long	incredble_sp

****************
#finger_roll

	movk	4,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#fingtab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#fingtab
	.long	nicly_dne_sp
	.long	figr_itin_sp
	.long	nicly_dne_sp
	.long	figr_itin_sp
	.long	got_skilz_sp


****************
#dunk_short
#dunk_med
#dunk_long

	movi	300,a0			;call name 30% time
	calla	RNDPER
	jrls	#fname

	move	@ballpnumscored,a0
	callr	call_players_full_name
	jruc	#no_speech
#fname
	move	@jam_speech,a0		;speech type to call when jammed
	jrz	#no_speech
	sll	5,a0			;x 32 bits
	addi	#jam_jump,a0
	move	*a0,a0,L
	call	a0
#no_speech
	rets


#jam_jump
	.long	0
	.long	#easy_jam
	.long	#med_jam
	.long	#good_jam
	.long	#great_jam
	.long	#alleyoop_jam

****************
#easy_jam

;DJT Start
	movk	8,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#easy_tab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#easy_tab
	.long	kaboom1_sp
;DJT Start
	.long	kaboom2_sp
;DJT End
	.long	he_dnk_it_sp
	.long	jams_it_sp
	.long	jam_it_in_sp
	.long	dunks_it_sp
	.long	slam_dunk_sp
	.long	with_ajam_sp
	.long	he_slams_sp


****************
#med_jam

;DJT Start
	movk	11,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#med_tab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#med_tab
	.long	rama_dong_sp
	.long	bomshakalaka
	.long	kaboom1_sp
	.long	he_dnk_it_sp
	.long	powr_jams_sp
;DJT Start
	.long	kaboom2_sp
	.long	throws_it_sp
;DJT End
	.long	smokin_sp
	.long	incredble_sp
	.long	jam_it_in_sp
	.long	with_ajam_sp
	.long	he_slams_sp


****************
#good_jam

;DJT Start
	movk	17,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#good_tab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#good_tab
	.long	fantastic_sp
	.long	bomshakalaka
	.long	thndr_dnk_sp
	.long	kaboom1_sp
;DJT Start
	.long	kaboom2_sp
	.long	pounds_it_sp
;DJT End
	.long	spect_dnk_sp
	.long	rama_dong_sp
	.long	u_c_that_sp
	.long	jam_it_in_sp
	.long	postr_jam_sp
	.long	oh_man_sp
	.long	no_stopng_sp
	.long	incredble_sp
;DJT Start
	.long	outstndng_sp
;DJT End
	.long	amazing_sp
	.long	powr_jams_sp
	.long	with_ajam_sp


****************
#great_jam

;DJT Start
	movk	16,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#great_tab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#great_tab
	.long	rama_dong_sp
	.long	bomshakalaka
	.long	u_c_that_sp
	.long	amazing_sp
	.long	isit_shoe_sp
	.long	kaboom1_sp
;DJT Start
	.long	outstndng_sp
	.long	learn_tht_sp
	.long	didnt_knw_sp
	.long	kaboom2_sp
;DJT End
	.long	rama_dong_sp
	.long	rama_dong_sp
	.long	oh_man_sp
;DJT Start
	.long	kakaboom_sp
;DJT End
	.long	with_ajam_sp
	.long	powr_jams_sp
	.long	spect_dnk_sp


****************
#alleyoop_jam

	movk	7,a0
	calla	rndrng0
	sll	5,a0
	addi	#alleyoop_tab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets


#alleyoop_tab
	.long	alley_oop_sp
	.long	bomshakalaka
	.long	thr_tmwrk_sp
	.long	alley_oop_sp
	.long	thr_smkn_sp
	.long	alley_oop_sp
	.long	nicly_dne_sp
	.long	alley_oop_sp
;	.long	thr_zone_sp
;	.long	whta_show_sp



****************
#fade_away
#fade_in
	rets


#*****************************************************************************

 SUBR	seq_call_name

	move	*a13(plyr_num),a0	;(0-3)
	callr	call_player_name
	rets


#*****************************************************************************
;calls player name speech
;a0 = player number to call (0-3)
;
;RETURNS:
;CC = name called
;CS = name NOT called

 SUBR	call_player_name

	move	@last_name_time,a1	;# ticks since name called
	cmpi	TSEC*2,a1
	jrhs	#playit

	move	@last_name,a1		;if name called in last 3 secs
	cmp	a0,a1			;then don't call it again
	jreq	#snd_fail

#playit
	PUSH	a0

	move	a0,a1
	sll	6,a1
	addi	spch_name_ram,a1
	move	*a1,a0,L
	calla	snd_play1

	PULL	a0

	move	a0,@last_name		;last player name called
	clr	a0
	move	a0,@last_name_time	;# ticks since name called
	clrc
	rets

#snd_fail
	setc
	rets

#*****************************************************************************
*	Call FULL PLAYERS name
*	
* a0 = player number to call (0-3)
******************************************************************************
 SUBRP	call_players_full_name

	sll	6,a0
	addi	spch_name_ram,a0
	addk	32,a0				;point to full name speech
	move	*a0,a0,L
	calla	snd_play1
	rets


#*****************************************************************************
;calls "to player" speech when players pass the ball
;
;a1 = player number passing ball (0-3)
;
;RETURNS:
;CC = name called
;CS = name NOT called

 SUBR	pass_to_speech

	PUSH	a2
	move	a1,a2

	movi	300,a0			;call 'to-name' 70% of time
	calla	RNDPER
	jrls	#toname

	movi	#pass_spch_near_tbl,a2
	move	*a13(plyr_tmdist),a14
	cmpi	570,a14
	jrls	#pastos			;br=teammate is close !!
	movi	#pass_spch_far_tbl,a2
#pastos
	movk	7,a0
	calla	rndrng0
	sll	5,a0
	add	a2,a0
	move	*a0,a0,L
	jrz	#fail
	calla	snd_play1
	jruc	#fail
#toname
	move	@last_name_time,a0	;# ticks since name called
	cmpi	TSEC*3,a0
	jrls	#fail

	move	a2,a1
	sll	5,a1
	addi	spch_pass_ram,a1
	move	*a1,a0,L
	calla	snd_play1

	xori	1,a2
	move	a2,@last_name		;last player name called
	clr	a0
	move	a0,@last_name_time	;# ticks since name called
#done
	PULL	a2
	clrc
	rets
#fail
	PULL	a2
	setc
	rets


#pass_spch_near_tbl
	.long	passes_sp
	.long	he_passes_sp
	.long	0
	.long	a_pass_sp
	.long	0
	.long	he_passes_sp
	.long	tosses_it_sp
	.long	guns_it_sp

#pass_spch_far_tbl
;DJT Start
	.long	cros_crt_sp
	.long	downcourt_sp
	.long	downcrt2_sp
	.long	hev_dncrt_sp
	.long	lngpss_dc_sp
	.long	pas_outsd_sp
	.long	he_passes_sp
	.long	hev_dncrt_sp
;DJT End


#*****************************************************************************
;
;CC = at buzzer called
;CS = at buzzer NOT called

	.asg	040500h,MAX_TIME	;45 seconds
	.asg	020500h,MAX_TIME2	;25 seconds
	.asg	000200h,MIN_TIME	;2 seconds

 SUBRP	blowout

	move	@freakout,a1		;no freakout on score
	jrz	#no_freakout

	movi	its_good_sp,a0
	dec	a1
	jrnz	#ok
	move	@game_time,a0,L
	cmpi	MAX_TIME,a0
	jrhi	#snd_fail
	movi	goooood_sp,a0		;GOOOOD!!!
#ok	calla	snd_play1
	rets


#no_freakout
	move	@gmqrtr,a0
	cmpi	3,a0
	jrlt	#not_last_qtr

	move	@game_time,a0,L
	cmpi	MAX_TIME,a0
	jrhi	#snd_fail
	cmpi	MIN_TIME,a0
	jrlo	#snd_fail

	move	@blowout_called,a0
	jrnz	#snd_fail

	move	@ballpnumscored,a0	;Last plyr who scored (0-3) or neg
	callr	calc_score_diff

	move	@score_diff,a1
	cmpi	6,a1
	jrge	#isblow

	cmpi	3,a1
	jrlt	#snd_fail

	move	@needshot_called,a0
	jrnz	#snd_fail

	move	@game_time,a0,L
	cmpi	MAX_TIME2,a0
	jrhi	#snd_fail


	movk	1,a0
	calla	rndrng0
	move	a0,a0
	jrz	#do_needshot

;say " TEAM... running out of time"

	move	@ballpnumscored,a14	;Last plyr who scored (0-3) or neg
	jrn	#error

	movi	sound_ram,a4,L

	move	@team1,a0
	srl	1,a14			;0-1
	jrnz	#tm1_scored
;tm2_scored
	move	@team2,a0
#tm1_scored
	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	addi	tm_name_spch_tbl,a1
	move	a1,*a4+,L			;store ptr. to sound call data
	move	*a1(16),a14,W			;get sound call length
	addk	10,a14				;a little silence
	move	a14,*a4+,W
	movi	run_out_sp,a14,L
	move	a14,*a4+,L
	movi	-1,a14
	move	a14,*a4,W			;end script
	movi	sound_ram,a0,L
	calla	script_play1
	rets

#error
#do_needshot
;DJT Start
	movi	needshot_sp,a0
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#playit
	movi	just_secs_sp,a0
	btst	2,a14
	jrnz	#playit
	movi	run_out_sp,a0
;DJT End
#playit
	calla	snd_play1
	movk	1,a0
	move	a0,@needshot_called
	rets

#isblow
;DJT Start
	cmpi	9,a1
	jrlt	#notblow
	movi	blowout_sp,a0		;it's a blowout
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#blowout
	movi	debacle_sp,a0
	jruc	#blowout
#notblow
;DJT End
	movk	4,a0
	calla	rndrng0
	sll	5,a0
	addi	#no_chnce_win_sp_tbl,a0
	move	*a0,a0,L
#blowout
	calla	snd_play1

	movk	1,a0
	move	a0,@blowout_called
	clrc
	rets

#not_last_qtr
	clr	a0
	move	a0,@blowout_called
	move	a0,@needshot_called

#snd_fail
	setc
	rets



#no_chnce_win_sp_tbl
	.long	whoomp_sp
	.long	fnl_strw_sp
	.long	its_hstry_sp
;DJT Start
	.long	strike_up_sp
;DJT End
	.long	fat_sing_sp


#*****************************************************************************
;
;CC = at buzzer called
;CS = at buzzer NOT called

 SUBRP	at_buzzer

	move	@shot_type,a0		;don't call on dunks
	cmpi	DUNK_SHORT,a0
	jrhs	#check_buzzer

	move	@game_time,a0,L
	cmpi	400h,a0			;less than 4 seconds left
	jrgt	#snd_fail

	move	@gmqrtr,a0
	cmpi	3,a0			;last quarter?
	jrlt	#not_last_qtr

	move	@score_diff,a0
	jrp	#in_front		;already in front
	move	@ballptsforshot,a1	;Point value for current shot (1-3)
	add	a1,a0
	jrz	#ties_it
	jrn	#behind
#wins_it
	movi	it_is_sp,a0		;IT IS....
	calla	snd_play1
	movk	1,a0
	move	a0,@freakout		;freak out if it scores
	rets

#ties_it
	movi	could_tie_sp,a0
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#tsit
	movi	it_culdbe_sp,a0
#tsit
	calla	snd_play1
	movk	2,a0
	move	a0,@freakout		;freak out if it scores
	rets


#behind
#in_front
#not_last_qtr
#check_buzzer
	move	@game_time,a0,L
	cmpi	200h,a0
	jrgt	#snd_fail

	movi	off_in_time,a0
	calla	snd_play1
	rets

#snd_fail
	setc
	rets

#*****************************************************************************
;
;CC = lucky bounce called
;CS = lucky bounce NOT called

 SUBRP	lucky_bounce

	move	@shot_type,a0
	cmpi	DUNK_SHORT,a0		;no lucky bounce on dunks!
	jrge	#snd_fail

	move	@ugly_stat,a0
	jrz	#snd_fail		;ugly not called

	movk	5,a0
	calla	rndrng0
	sll	5,a0
	addi	#lucky_bnce_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
	clrc
	rets

#snd_fail
	setc
	rets


#lucky_bnce_tbl
	.long	luky_bnce_sp
	.long	it_falls_sp
	.long	luky_bnce_sp
	.long	falls_in_sp
	.long	luky_bnce_sp
	.long	per_luck_sp


#*****************************************************************************
;
;CC = ugly called
;CS = ugly NOT called

 SUBRP	ugly_shot

	move	@shot_percentage,a0	;0=ugly, 1=ok
	jrn	#doit
	jrnz	#snd_fail

	movi	100,a0			;call ugly 20% time
	calla	RNDPER
	jrls	#snd_fail

#doit
;DJT Start
	movk	3,a0
;DJT End
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#uglytab,a0
	move	*a0,a0,L
	calla	snd_play1

	movk	1,a0
	move	a0,@ugly_stat		;ugly called

	clrc
	rets

#snd_fail
	setc
	rets

#uglytab
;DJT Start
	.long	look_out_sp
;DJT End
	.long	ugly_shot_sp
	.long	putup_brk_sp
	.long	teribl_sh_sp


#*****************************************************************************
;calls team names speech
;a0 = team number to call (0-29)

 SUBR	call_team_name

 	SLEEPK	10

	move	a8,a0
	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	move	a1,a0
	addi	tm_name_spch_tbl,a0
	calla	snd_play1
	DIE


#*****************************************************************************

 SUBR	call_matchup

;	SLEEP	20
;
;	SOUND1	matchup
;
;	SLEEP	1*TSEC+20

	movi	sound_ram,a4,L

	move	@team1,a0
	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	addi	full_tm_name_spch_tbl,a1
	move	a1,*a4+,L			;store ptr. to sound call data
	move	*a1(16),a0,W			;get sound call length
	move	a0,*a4+,W

	movi	vs_sp,a0,L
	move	a0,*a4+,L
	move	*a0(16),a14,W		;get sound call length
	move	a14,*a4+,W		;store it

	move	@team2,a0
	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	addi	full_tm_name_spch_tbl,a1
	move	a1,*a4+,L			;store ptr. to sound call data

	movi	-1,a14
	move	a14,*a4,W			;end script

	movi	sound_ram,a0,L
	calla	script_play1
	DIE


#*****************************************************************************
* a0 = player who last scored or shot

calc_score_diff

	PUSH	a0,a1,a2

	move	@scores,a1
	move	@scores+10h,a2
	sub	a2,a1
	srl	1,a0
	jrz	#team1
	neg	a1			;team2, so negate
#team1
	move	a1,@score_diff
	PULL	a0,a1,a2
	rets

#*****************************************************************************
;called when player with ball gets pushed and loses ball

 SUBR	pushed_speech

	PUSH	a0,a1,a14
	movk	9,a0
	calla	rndrng0
	sll	5,a0
	addi	#pushtab,a0
	move	*a0,a0,L
	jrz	#nosnd
	calla	snd_play1
#nosnd
	PULL	a0,a1,a14
	setc
	rets


#pushtab
	.long	flagrant_sp
	.long	0
	.long	to_floor_sp
	.long	to_deck_sp
	.long	0
;DJT Start
	.long	hamerd_hm_sp
;DJT End
	.long	tookm_out_sp
	.long	tookm_out_sp
	.long	0
	.long	hamerd_hm_sp


#*****************************************************************************
;called when a player rejects a shot

 SUBR	rejected_speech

	PUSH	a0,a1,a14
;Check to make sure ball is high enough in air
	move	@ballobj_p,a1,L
	move	*a1(OYPOS),a0
	cmpi	-38,a0		;if below HOOP - dont call!
;	cmpi	-28,a0
	jrgt	#yes		;Br=near ground

	move	@must_rebound,a0
	jrnz	#yes

	movk	8,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#regtab,a0
	move	*a0,a0,L
	calla	snd_play1
#yes
	PULL	a0,a1,a14
	rets

#regtab
	.long	its_blckd_sp
	.long	rejected_sp
	.long	deflected_sp
	.long	outa_here_sp
	.long	rejected_sp
	.long	blckd_it_sp
	.long	outa_here_sp
	.long	rejected_sp
	.long	outa_here_sp


#*****************************************************************************
; called when a player steals the ball in the air
;
 SUBR	in_air_steal_speech

	PUSH	a0,a1,a14
	movk	4,a0
	calla	rndrng0
	sll	5,a0
	addi	#inair_spch_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
#inar	
 	PULL	a0,a1,a14
	rets


#inair_spch_tbl
	.long	outa_here_sp
	.long	stolen_sp
	.long	grab_ball_sp
	.long	outa_here_sp
	.long	quck_hnds_sp


#*****************************************************************************
;called when a player rejects a dunk

 SUBR	rejected_dnk_speech

	PUSH	a0,a1,a14
;Check to make sure ball is high enough in air
	move	@ballobj_p,a1,L
	move	*a1(OYPOS),a0
	cmpi	-75,a0
	jrgt	#yes		;Br=near ground

	movk	4,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#regdnktab,a0
	move	*a0,a0,L
	calla	snd_play1
	jruc	#dne
#yes	
	SOUND1	stolen_sp
#dne
	PULL	a0,a1,a14
	rets

#regdnktab
	.long	rejected_sp
	.long	no_way_sp
	.long	outa_here_sp
	.long	rejected_sp
	.long	outa_here_sp


#*****************************************************************************
;called when a player swats the ball in air

 SUBR	deflected_speech

	PUSH	a0,a1,a14

	move	@must_rebound,a0
	jrnz	#yes


	movk	6,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#deflt_spch_tab,a0
	move	*a0,a0,L
	calla	snd_play1
#yes	
	PULL	a0,a1,a14
	rets

#deflt_spch_tab
	.long	rejected_sp
	.long	outa_here_sp
	.long	deflected_sp
	.long	its_blckd_sp
	.long	rejected_sp
	.long	deflected_sp
	.long	outa_here_sp


#*****************************************************************************

 SUBR	rebound_speech

	PUSH	a1,a2,a4,a6,a7,a8

	move	@game_time,a0,L		;don't call if clock run down
	jrz	#done

	move	@ballpnum,a1
	jrn	#done

	movi	HOOPLX,a6
	move	*a13(PA8),a14
	move	*a14(OXPOS),a14
	subi	WRLDMID,a14
;	jruc	#je
	jrn	#rbs
	movi	HOOPRX,a6
#rbs
	movi	CZMID,a7
	move	@ballobj_p,a8,L
	calla	seekdirdist_obxz128
	cmpi	22,a1
	jrhi	#ntnear
	movk	5,a0
	calla	rndrng0
	sll	5,a0
	addi	#rebnd_near_hoop_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
	jruc	#done

#ntnear
	movi	500,a0			;call name 50% time
	calla	RNDPER
	jrls	#name
	move	@last_name_time,a14	;# ticks since name called
	cmpi	TSEC*2,a14
	jrhs	#name			;br=okay too call name
#noname
	movk	6,a0
	calla	rndrng0
	sll	5,a0
	addi	#rebnd_no_nme_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
	jruc	#done
#name
	movi	200,a0			;call name 50% time
	calla	RNDPER
	jrls	#aname

	movi	sound_ram,a4,L

	move	@team1,a0
	move	@ballpnum,a14
	srl	1,a14			;0-1
	jrz	#tm1
	move	@team2,a0
#tm1	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	addi	tm_name_spch_tbl,a1
	move	a1,*a4+,L			;store ptr. to sound call data
	move	*a1(16),a14,W			;get sound call length
	move	a14,*a4+,W
	movi	posession_sp,a14,L
	move	a14,*a4+,L
	movi	-1,a14
	move	a14,*a4,W			;end script
	movi	sound_ram,a0,L
	calla	script_play1
	jruc	#done
#aname
     	
;	movi	300,a0			;call name 50% time
;	calla	RNDPER
;	jrls	#bname
;#je
;	movi	sound_ram,a4,L
;
;	move	@ballpnum,a14
;	sll	6,a14
;	addi	spch_name_ram,a14
;	move	*a14,a14,L		;get snd call ptr.
;	move	a14,*a4+,L		;store it
;	move	*a14(16),a14,W		;get sound call length
;	move	a14,*a4+,W		;store it
;
;;	movi	has_sp,a14,L
;	movi	with_sp,a14,L
;
;	move	a14,*a4+,L
;	move	*a14(16),a14,W		;get sound call length
;	move	a14,*a4+,W		;store it
;
;	move	@ballpnum,a1
;	movi	PS_OFF_REB,a0		;Assume offensive rebound
;	calla	get_player_stat
;	move	a14,a2
;	movi	PS_DEF_REB,a0		;No. Defensive rebound
;	move	@ballpnum,a1
;	calla	get_player_stat
;	add	a2,a14
;
;	cmpi	20,a14
;	jrhi	#bname			;br=if value > 20, ignore
;
;	sll	6,a14
;	addi	scr_nbr_tbl,a14
;	move	a14,*a4+,L		;store sound ptr
;	move	*a14(16),a14,W		;get sound call length
;	move	a14,*a4+,W		;store it
;
;	movi	rebounds_sp,a14,L
;	move	a14,*a4+,L
;
;	movi	-1,a14
;	move	a14,*a4,W			;end script
;	movi	sound_ram,a0,L
;	calla	script_play1
;	jruc	#done
;
;#bname
	movi	sound_ram,a4,L

	move	@ballpnum,a14
	sll	6,a14
	addi	spch_name_ram,a14
	move	*a14,a14,L		;get snd call ptr.
	move	a14,*a4+,L		;store it
	move	*a14(16),a14,W		;get sound call length
;	subk	6,a14			;shorten space between speech
	move	a14,*a4+,W		;store it

	movk	5,a0
	calla	rndrng0
	sll	5,a0
	addi	#rebnd_nme_tbl,a0
	move	*a0,a0,L
	jrz	#done
	move	a0,*a4+,L		;store REBOUND speech

	movi	-1,a14
	move	a14,*a4,W			;end script
	movi	sound_ram,a0,L
	calla	script_play1

	move	@ballpnum,a0
	move	a0,@last_name		;last player name called
	clr	a0
	move	a0,@last_name_time	;# ticks since name called
#done
	PULL	a1,a2,a4,a6,a7,a8
	rets




#rebnd_near_hoop_tbl
	.long	pulls_off_sp
	.long	with_bord_sp
	.long	tks_rebnd_sp
	.long	tks_rbnd2_sp
	.long	ynk_rim_sp
	.long	tks_rbnd3_sp

#rebnd_nme_tbl
	.long	grab_rock_sp
	.long	has_rebnd_sp
	.long	grab_ball_sp
	.long	tks_rbnd2_sp
	.long	grab_ball_sp
	.long	tks_rbnd2_sp


#rebnd_no_nme_tbl
	.long	tks_rebnd_sp
	.long	quck_hnds_sp
	.long	with_bord_sp
	.long	grab_rock_sp
	.long	grbs_rbnd_sp
	.long	da_rebnd_sp
	.long	rip_rebnd_sp


#*****************************************************************************

 SUBR	intercepted_speech

	movk	3,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#intcptab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#intcptab
	.long	intrceptd_sp
	.long	turnover_sp
	.long	clean_pck_sp
	.long	bad_pass_sp

#*****************************************************************************

 SUBR	stolen_speech

	movk	4,a0
	calla	rndrng0
	sll	5,a0
	addi	#stealstab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#stealstab
	.long	turnover_sp
	.long	stolen_sp
	.long	stripped_sp
	.long	the_steal_sp
	.long	trnd_over_sp

#*****************************************************************************

 SUBR	call_facial_speech
	
	movk	2,a0
	calla	rndrng0
	sll	5,a0
	addi	#facial_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
#done	rets


#facial_sp_tbl
	.long	no_stopng_sp
	.long	facial_sp
	.long	no_stopng_sp

#*****************************************************************************

 SUBR	ball_loose_spch

	SLEEPK	20

	move	@ballpnum,a0
	jrnn	#done

	movk	10,a0
	calla	rndrng0
	sll	5,a0
	addi	#ball_loose_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
#done	DIE


#ball_loose_sp_tbl
	.long	0
	.long	he_lst_bl_sp
	.long	cheer2_snd
	.long	he_lostit_sp
	.long	cheer_snd
	.long	bal_loose_sp
	.long	cheer1_snd
	.long	shuld_pas_sp
	.long	0
	.long	bal_loose_sp
	.long	0


#*****************************************************************************

 SUBR	head_fake_speech

	movk	5,a0
	calla	rndrng0
	sll	5,a0
	addi	#head_fake_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
#done	rets


#head_fake_sp_tbl
	.long	0
	.long	head_fake_sp
	.long	the_fake_sp
	.long	0
	.long	pump_fake_sp
	.long	0

#*****************************************************************************
;calls "it's good" whenever a player scores from 3pt out with no time left
;CC = it's good called
;CS = it's good NOT called

 SUBRP	itsgood

	move	@game_time,a0,L
	jrnz	#done
	SOUND1	its_good_sp
	rets
#done
	setc
	rets

#*****************************************************************************
 SUBR	seq_alleyoop_speech

	movi	goes_up_sp,a0
	calla	snd_play1
	rets


#*****************************************************************************

 SUBR	seq_lay_up_start

	movi	lay_it_up_sp,a0
	calla	snd_play1
	rets

#*****************************************************************************

 SUBR	seq_high_dnk_spch

	movi	400,a0			;20% of tim
	calla	RNDPER
	jrls	#noooh

	SOUND1	ooooooh_sp
	jruc	#saidoh
#noooh
	movk	9,a0
	calla	rndrng0
	sll	5,a0
	addi	#dnk_high_sp_tbl,a0
	move	*a0,a0,L
	calla	snd_play1

;	movi	200,a0			;20% of tim
;	calla	RNDPER
;	jrls	#saidoh

	movk	4,a0
	calla	rndrng0
	sll	5,a0
	addi	#dunk_fx_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
#saidoh
	rets


#dunk_fx_tbl
	.long	jet1_snd
	.long	jet3_snd
	.long	jet4_snd
	.long	jet2_snd
	.long	tarzan

#dnk_high_sp_tbl
	.long	thrgh_air_sp
	.long	hiabv_rim_sp
	.long	goes_hoop_sp
	.long	serious_h_sp
	.long	flies_air_sp
	.long	gldes_air_sp
	.long	goes_flyg_sp
	.long	serious_h_sp
	.long	way_upair_sp
	.long	lch_atbkt_sp


#*****************************************************************************

 SUBR	seq_low_dnk_spch

	movk	7,a0
	calla	rndrng0
	sll	5,a0
	addi	#dnk_low_sp_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
	rets


#dnk_low_sp_tbl
	.long	goes_up_sp
	.long	goes_hoop_sp
	.long	tks2_hoop_sp
	.long	goes_hoop_sp
	.long	goes_up_sp
	.long	tks2_hoop_sp
	.long	raises_up_sp
	.long	catapults_sp

#*****************************************************************************
* B4=*Next data in seq list

 SUBR	seq_jam_speech

	move	*b4+,b0
	move	b0,a0		;jam speech type
	move	a0,@jam_speech	;speech type to call when jammed
 	rets

#*****************************************************************************
* a0 = % of swishes to call

 SUBRP	swish_speech

	move	@ballrimhitcnt,a1
	jrnz	#noswish

	move	@ballbbhitcnt,a1
	jrnz	#snd_fail

	calla	RNDPER
	jrls	#snd_fail

#doit
	movk	6,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#swishtab,a0
	move	*a0,a0,L
	calla	snd_play1
	rets
#snd_fail
	setc
	rets

#noswish
	cmpi	9,a1
	jrlt	#snd_fail
	callr	lucky_bounce
	rets


#swishtab
	.long	swish_sp
	.long	ngbut_net_sp
	.long	rgt_thrgh_sp
	.long	swish_sp
	.long	scores_sp
	.long	botm_net_sp
;DJT Start
	.long	swish2_sp
;DJT End


#*****************************************************************************
* A11=Team who gets ball (0=1, !0=2)

 SUBR	call_scores

	PUSH	a0,a1,a7,a14
	PUSH	b0,b1

	move	@game_time,a0,L
	jrz	#no_call0		;br=not playing...

	cmpi	010000h,a0		;10 seconds
	jrlt	#no_call0
	CREATE0	call_scores_proc

#no_call0
	PULL	b0,b1
	PULL	a0,a1,a7,a14
	rets



 SUBRP	call_scores_proc

	SLEEP	TSEC+10

	move	@game_time,a0,L
	jrz	#no_call

;	move	@gmqrtr,a0		;don't call if in last quarter and
;	cmpi	3,a0			;less than 30 seconds on clock
;	jrlt	#not_last_qtr
;
;#not_last_qtr

;DJT Start
 .if DEBUG
;	jruc	#anc_scr
 .endif ;DEBUG

	movi	99,a0
	calla	rndrng0
	cmpi	30,a0		;45
	jrls	#no_call		; br=nothing
	cmpi	60,a0
	jrls	#anc_scr		; br=annouce scores
	cmpi	80,a0
	jrls	#crwd_fx		; br=crowd/outdoor sounds

	move	@pup_court,a14		;No br=organ sounds if indoor
	jrnz	#die			; br=outdoor court
;DJT End

	movk	3,a0
	calla	rndrng0			;>0-3
	sll	5,a0
	addi	#organ_script_tbl,a0
	move	*a0,a0,L
	calla	script_play1
#die
	DIE	


**********************************
#anc_scr

;DJT Start
	move	@scores,a4
	move	@scores+10h,a0
	sub	a0,a4

	move	@team1,a2
	move	a11,a11
	jrnz	#cnt
	move	@team2,a2
	neg	a4
#cnt
	move	a4,a0
	jrz	#tied
	abs	a0
	cmpi	59,a0
	jrhi	#no_call		;br=if score diff > 59, ignore

	movi	#anc_scr_lose_tbl,a3
	neg	a4			;make positive
	jrn	#neg
	move	a4,a0
	subk	12,a0
	jrlt	#pos
	srl	5,a0			;3.2% per pt down
	addi	500,a0			; plus base %
	cmpi	900,a0			;Max %
	jrls	#valp
	movi	900,a0			;Max %
#valp
	calla	RNDPER
	jrls	#pos
	movi	#anc_scr_lngw_tbl,a3
	jruc	#pos
#neg
	neg	a4			;make positive
	movi	#anc_scr_take_tbl,a3
	cmpi	3,a4
	jrlt	#pos
	movi	#anc_scr_win_tbl,a3
#pos
;DJT End
	movk	5,a0
	calla	rndrng0
	sll	6,a0
	add	a0,a3
;DJT Start
#doscscr
;DJT End
	move	a3,a0
	move	a4,a1

	movi	sound_ram,a4,L

	move	*a0+,a14,W
	jrn	#nofrst				;br=nothing goes here
	jrz	#saytm
	movi	tm_city_spch_tbl,a14
	jruc	#saycty
#saytm
	movi	tm_name_spch_tbl,a14
#saycty
	movi	TM_SPCH_TBL_SZ,a3
	mpys	a2,a3
	add	a14,a3
	move	a3,*a4+,L		;store ptr. to sound call data
	move	*a3(16),a14,W		;get sound call length
	move	a14,*a4+,W		;store it
#nofrst
	move	*a0+,a3,L		;get sound call ptr
	move	a3,*a4+,L		;store sound ptr
	move	*a3(16),a3,W		;get sound call length

	move	*a0,a14,W
	jrn	#nolst
;DJT Start
	move	a3,*a4+,W		;store it
	jrz	#saysc
	movi	longway_sp,a1,L
	jruc	#saysc1
#saysc
	sll	6,a1			;x 32 bits
	addi	scr_nbr_tbl,a1
#saysc1
;DJT End
	move	a1,*a4+,L		;store sound ptr
#nolst
	movi	-1,a14
	move	a14,*a4,W			;end script

	movi	sound_ram,a0,L
	calla	script_play1

;	movi	2,a0
;	move	a0,@next_call

#snd_fail
#no_call
	DIE


;
; Table sytanx:
;
; first number:
;  0 - say team name
;  1 - say city name
; -1 - say nothing
;
; second thing:
;   speech call ptr.
;
; last number:
;  + - say "long way..."
;  0 - say point difference
; -1 - say nothing

#anc_scr_win_tbl
	WLW	1,leadng_by_sp,0
	WLW	0,leadng_by_sp,0
	WLW	1,leads_by_sp,0
	WLW	0,lead_by_sp,0
	WLW	0,by_sp,0
	WLW	0,have_lead_sp,-1

;DJT Start
#anc_scr_take_tbl
	WLW	1,taks_lead_sp,-1
	WLW	0,take_lead_sp,-1
	WLW	1,taks_lead_sp,-1
	WLW	0,out_front_sp,-1
	WLW	1,out_front_sp,-1
	WLW	0,have_lead_sp,-1

;DJT End
#anc_scr_lose_tbl
	WLW	1,downby_sp,0
	WLW	0,downby_sp,0
	WLW	1,behind_by_sp,0
	WLW	0,behind_by_sp,0
	WLW	1,catchg_up_sp,-1
	WLW	0,catchg_up_sp,-1
;DJT Start

#anc_scr_lngw_tbl
	WLW	1,with_sp,1
	WLW	0,with_sp,1
	WLW	1,with_sp,1
	WLW	0,with_sp,1
	WLW	1,with_sp,1
	WLW	0,with_sp,1

#anc_scr_tied_tbl
	WLW	-1,tied_at_sp,0
	WLW	-1,tiegm_sp,-1
	WLW	 0,tiethegm_sp,-1
;DJT End
	


******************************************************************************
#tied
;DJT Start
	movi	#anc_scr_tied_tbl,a3
	movi	99,a0
	calla	rndrng0

	cmpi	30,a0			;%
	jrhi	#tied1

	move	@scores,a4
	cmpi	60,a4
	jrlo	#doscscr			; br=OK, score not too high
#tied1
	addi	64,a3
	cmpi	65,a0			;%
	jrls	#doscscr
	addi	64,a3
	jruc	#doscscr
;DJT End


**********************************
#crwd_fx

	move	@pup_court,a14
	jrz	#crwd0				;br=indoor court

	movk	10,a0
	calla	rndrng0				;>0-3
	sll	5,a0
	addi	#outdr_snd_tbl,a0,L
	move	*a0,a0,L
	calla	snd_play1
	DIE

#crwd0
	move	@scores,a0			;team 1 score
	move	@scores+10h,a1			;team 2 score

	movi	#crowd_chant_tbl,a8
	cmp	a1,a0				;team 1 > team 2 ?
	jrhs	#crwdsnd			;br=yep
	movi	#crowd_chant_tbl2,a8
#crwdsnd
	movk	3,a0
	calla	rndrng0				;>0-3
	sll	5,a0
	add	a8,a0
	move	*a0,a0,L
	calla	script_play1
	DIE


#organ_script_tbl
	.long	organ_fx1_sc
	.long	organ_fx2_sc
	.long	organ_fx1_sc
	.long	organ_fx2_sc


#crowd_chant_tbl
	.long	crwd_blchrs_sc
	.long	crwd_goteam_sc
	.long	crwd_goteam_sc
	.long	crwd_blchrs_sc


#crowd_chant_tbl2
	.long	crwd_blchrs_sc
	.long	crwd_goteam_sc
	.long	crwd_defnse_sc
	.long	crwd_blchrs_sc


#outdr_snd_tbl
	.long	ambulne2_snd
	.long	ambulne_snd
	.long	prop_ple_snd
	.long	siren_snd
	.long	car_pas2_snd
	.long	fire_trk_snd
	.long	car_pas2_snd
	.long	prop_ple_snd
	.long	siren_snd
	.long	chrch_bel_sp
	.long	car_pass_snd


#*****************************************************************************
* process

 SUBR	name_call

#restart
	movi	TSEC*2,a10
#loop
	SLEEPK	1

	move	@game_time,a0,L
	jrz	#restart

	move	@inbound,a0
	jrnn	#restart

	move	@ballpnum,a0
	jrn	#restart		;ball free

	move	a0,a1
	sll	5,a1			;*32
	addi	plyrproc_t,a1
	move	*a1,a1,L
	move	*a1(plyr_seqflgs),a1
	btst	DUNK_B,a1
	jrnz	#restart

	dsj	a10,#loop

	move	@last_name,a1		;if name called in last 3 secs
	cmp	a0,a1
	jrne	#diff_name

	move	@last_name_time,a1	;# ticks since name called
	cmpi	TSEC*2,a1
	jrlt	#restart

#diff_name
	callr	call_player_name

	movi	TSEC*4,a10
	jruc	#loop


#*****************************************************************************
;CC = onfire called
;CS = onfire NOT called

 SUBRP	onfire_speech

	move	@game_time,a0,L
	jrz	#snd_fail

	move	@ballnumscored,a0	;# times last plyr scored
	cmpi	3,a0
	jrge	#onfire
	cmpi	2,a0
	jrne	#snd_fail		;is cold

	movi	heatup_sp,a0
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#heatup
	movi	lightn_up_sp,a0
	jruc	#heatup

#onfire
	move	@ballpnumscored,a1	;Last plyr who scored (0-3) or neg
	move	@plyr_onfire,a0		;plyr who is on fire
;;	cmp	a0,a1
;;	jrne	#was_teammate
	btst	a1,a0
	jrz	#was_teammate		;br=not on fire

	move	@shot_type,a0
	jrnz	#not_desp

	movi	400,a0			;call desp speech 40% time
	calla	RNDPER
	jrhi	hotscored

#not_desp
	movk	6,a0
	calla	rndrng0
	sll	5,a0		;x 32 bits
	addi	#onfiretab,a0
	move	*a0,a0,L
#heatup
	calla	snd_play1
	rets

#was_teammate
#snd_fail
	setc
	rets

#onfiretab
	.long	hot_hand_sp
	.long	he_uncon_sp
	.long	hot_hand_sp
	.long	smokin_sp
	.long	ever_miss_sp
	.long	smokin_sp
	.long	he_uncon_sp

#*****************************************************************************
* call wide open if applicable

	.asg	140,RANGE

 SUBRP	 wideopen_speech

	movi	450,a0			;call wide-open 35% time
	calla	RNDPER
	jrls	#not_open

	move	@plyr_shot,a0		;player who shot last (0-3)
	sll	5,a0			;*32
	addi	plyrproc_t,a0
	move	*a0,a0,L
	move	*a0(plyr_o1dist),a1	;opponent 1 dist
	cmpi	RANGE,a1
	jrlt	#not_open
	move	*a0(plyr_o2dist),a1	;opponent 2 dist
	cmpi	RANGE,a1
	jrlt	#not_open

	movk	3,a0
	calla	rndrng0
	sll	5,a0
	addi	#wide_opn_tbl,a0
	move	*a0,a0,L
	calla	snd_play1
	rets

#not_open
	setc
	rets


#wide_opn_tbl
	.long	opn_for_3_sp
	.long	wideopen_sp
	.long	all_alone_sp
	.long	no_prsure_sp


#*****************************************************************************

	.asg	2,BRICK_MAX

 SUBR	nogood_speech

	PUSH	a10

	move	@ballpnumshot,a10
	sll	4,a10			;x 16
	addi	brick_count,a10
	move	*a10,a1			;brick_count
	cmpi	BRICK_MAX,a1
	jrlt	#no_good

	move	@ballrimhitcnt,a0
	cmpi	3,a0
	jrlo	#ngs1
	movi	rtle_arnd_sp,a0,L
	move	@HCOUNT,a14
	btst	1,a14
	jrnz	#ngs0
	movi	spins_out_sp,a0,L
#ngs0	calla	snd_play1
	jruc	#done
#ngs1
;	cmpi	1,a0
;	jrls	#ngs2
;
;	movk	8,a0
;	calla	rndrng0
;	sll	5,a0
;	addi	#rim_bnce_sp_tbl,a0
;	move	*a0,a0,L
;	jrz	#ngs2			;br=no rim spch, try miss spch
;	calla	snd_play1
;	jruc	#done
;#ngs2
;DJT Start
	movk	6,a0
;DJT End
	calla	rndrng0
	sll	5,a0
	addi	#brick_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1

	clr	a0
	move	a0,*a10			;played, now clear it
	jruc	#done

#no_good
	move	@game_time,a0,L		;always call if clock at zero
	jrnz	#ng2
	SOUND1	nogood_sp
	jruc	#done

#ng2	movk	17,a0
	calla	rndrng0
	sll	5,a0
	addi	#nogood_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
#done
	PULL	a10
	rets



#nogood_sp_tbl
	.long	nogood_sp
	.long	mis_fires_sp
	.long	missed_sp
	.long	dwn_luck_sp
	.long	0
	.long	hita_barn_sp
	.long	off_rim_sp
	.long	off_trgt_sp
	.long	side_rim_sp
	.long	missed_sp
	.long	bnce_out_sp
	.long	holes_out_sp
	.long	bnce_away_sp
	.long	nogood_sp
	.long	away_side_sp
	.long	holes_out_sp
	.long	0
	.long	off_frnt_sp


#brick_sp_tbl
	.long	nogood_sp
	.long	cantbuy_sp
	.long	there_brk_sp
	.long	mis_fires_sp
	.long	missed_sp
	.long	side_rim_sp
;DJT Start
	.long	what_was_sp
;DJT End

;#rim_bnce_sp_tbl
;	.long	side_rim_sp
;	.long	bnce_out_sp
;	.long	holes_out_sp
;	.long	bnce_away_sp
;	.long	0
;	.long	away_side_sp
;	.long	holes_out_sp
;	.long	0
;	.long	off_frnt_sp

#*****************************************************************************

 SUBR	victory_speech

	move	@team1,a0
	move	@scores,a1
	move	@scores+10h,a2
	cmp	a1,a2
	jrlt	#t1_wins
	move	@team2,a0
#t1_wins
	movi	TM_SPCH_TBL_SZ,a1
	mpys	a0,a1
	addi	full_tm_name_spch_tbl,a1
;	addi	tm_name_spch_tbl,a1

	movi	sound_ram,a4,L
	move	a1,*a4+,L		;store sound table ptr
	move	*a1(16),*a4+,W		;store sound length

	movi	wingame_sp,a0,L
	move	a0,*a4+,L

	movi	-1,a0
	move	a0,*a4,W			;end script

	movi	sound_ram,a0,L
	calla	script_play1
	rets


#*****************************************************************************

 SUBR	tip_off_speech

	movi	450,a0
	calla	RNDPER
	jrls	#done
	SOUND1	gm_undrwy_sp
#done
	DIE


#*****************************************************************************

 SUBR	shot_clock_speech

;DJT Start
;	SOUND1	error_found
;DJT End

	movk	3,a0
	calla	rndrng0
	sll	5,a0
	addi	#sht_clck_sp_tbl,a0
	move	*a0,a0,L
	jrz	#done
	calla	snd_play1
#done	DIE


#sht_clck_sp_tbl
	.long	baddec_sp
	.long	0
	.long	wht_thnk2_sp
	.long	0

#******************************************************************************
* After teams have been selected, call this routine
* Stuff name_ram for calling player name based on who's been picked


 SUBR	setup_speech

;
; Player 1 on team 1
;
	move	@player1_data+PR_COUNT,a14
	jrn	#plr1				;br=player didn't enter inits
	move	@player1_data+PR_CREATED_PLYR,a14
	jrle	#plr1				;br=plyr not created!
	move	@player1_data+PR_NICKNAME_NBR,a14
	cmpi	NUM_NICK_NAMES-1,a14		;> than max count ?
	jrgt	#plr1
	sll	6,a14
	addi	nickname_spch_tbl,a14
	move	*a14+,a1,L			;get 'name' sound call ptr.
	move	a1,a2				;no full name
	move	*a14,a0,L			;get 'to-name' sound call ptr.
	jruc	#tag1

#plr1	movi	player_names,a10
	move	@team1,a2
;DJT Start
	jrz	#out3
#lp3
	addi	NEXT_TEAM_NAMES,a10		;compute offset into table
	dec	a2
	jrnz	#lp3
;DJT End
#out3
	move	@team1,a0
	sll	4,a0
	addi	tm1set,a0
	move	*a0,a14
	sll	6,a14
	add	a14,a10

	callr	get_plr_spch_ptrs

	move	@special_heads,a14
	jrn	#tag1
	movi	NME_SPCH_TBL_SZ,a1
	mpys	a14,a1
	move	a1,a0
	addi	special_name_speech,a1
	addi	special_pass_speech,a0
	move	a1,a2
#tag1
	move	a1,@spch_name_ram,L
	move	a2,@spch_name_ram+32,L
	move	a0,@spch_pass_ram+32,L
#*
;
; Player 2 on team 1
;
	move	@player2_data+PR_COUNT,a14
	jrn	#plr2				;br=player didn't enter inits
	move	@player2_data+PR_CREATED_PLYR,a14
	jrle	#plr2				;br=plyr not created!
	move	@player2_data+PR_NICKNAME_NBR,a14
	cmpi	NUM_NICK_NAMES-1,a14		;> than max count ?
	jrgt	#plr2
	sll	6,a14
	addi	nickname_spch_tbl,a14
	move	*a14+,a1,L			;get 'name' sound call ptr.
	move	a1,a2				;no full name
	move	*a14,a0,L			;get 'to-name' sound call ptr.
	jruc	#tag2

#plr2	movi	player_names,a10
	move	@team1,a2
;DJT Start
	jrz	#out3
#lp3
	addi	NEXT_TEAM_NAMES,a10		;compute offset into table
	dec	a2
	jrnz	#lp3
;DJT End
#out3
	move	@team1,a0
	sll	4,a0
	addi	tm1set,a0
	move	*a0,a14
	sll	6,a14
	add	a14,a10
	addk	32,a10				;2nd player on team 1

	callr	get_plr_spch_ptrs

	move	@special_heads+10h,a14
	jrn	#tag2
	movi	NME_SPCH_TBL_SZ,a1
	mpys	a14,a1
	move	a1,a0
	addi	special_name_speech,a1
	addi	special_pass_speech,a0
	move	a1,a2
#tag2
	move	a1,@spch_name_ram+64,L
	move	a2,@spch_name_ram+96,L
	move	a0,@spch_pass_ram,L

#*
;
; Player 1 on team 2
;

	move	@player3_data+PR_COUNT,a14
	jrn	#plr3				;br=player didn't enter inits
	move	@player3_data+PR_CREATED_PLYR,a14
	jrle	#plr3				;br=plyr not created!
	move	@player3_data+PR_NICKNAME_NBR,a14
	cmpi	NUM_NICK_NAMES-1,a14		;> than max count ?
	jrgt	#plr3
	sll	6,a14
	addi	nickname_spch_tbl,a14
	move	*a14+,a1,L			;get 'name' sound call ptr.
	move	a1,a2				;no full name
	move	*a14,a0,L			;get 'to-name' sound call ptr.
	jruc	#tag3

#plr3	movi	player_names,a10
	move	@team2,a2
;DJT Start
	jrz	#out3
#lp3
	addi	NEXT_TEAM_NAMES,a10		;compute offset into table
	dec	a2
	jrnz	#lp3
;DJT End
#out3
	move	@team2,a0
	sll	4,a0
	addi	tm2set,a0
	move	*a0,a14
	sll	6,a14
	add	a14,a10

	callr	get_plr_spch_ptrs

	move	@special_heads+20h,a14
	jrn	#tag3
	movi	NME_SPCH_TBL_SZ,a1
	mpys	a14,a1
	move	a1,a0
	addi	special_name_speech,a1
	addi	special_pass_speech,a0
	move	a1,a2
#tag3
	move	a1,@spch_name_ram+128,L
	move	a2,@spch_name_ram+160,L
	move	a0,@spch_pass_ram+96,L

#*
;
; Player 2 on team 2
;
	move	@player4_data+PR_COUNT,a14
	jrn	#plr4				;br=player didn't enter inits
	move	@player4_data+PR_CREATED_PLYR,a14
	jrle	#plr4				;br=plyr not created!
	move	@player4_data+PR_NICKNAME_NBR,a14
	cmpi	NUM_NICK_NAMES-1,a14		;> than max count ?
	jrgt	#plr4
	sll	6,a14
	addi	nickname_spch_tbl,a14
	move	*a14+,a1,L			;get 'name' sound call ptr.
	move	a1,a2				;no full name
	move	*a14,a0,L			;get 'to-name' sound call ptr.
	jruc	#tag4

#plr4	movi	player_names,a10
	move	@team2,a2
;DJT Start
	jrz	#out3
#lp3
	addi	NEXT_TEAM_NAMES,a10		;compute offset into table
	dec	a2
	jrnz	#lp3
;DJT End
#out3
	move	@team2,a0
	sll	4,a0
	addi	tm2set,a0
	move	*a0,a14
	sll	6,a14
	add	a14,a10
	addk	32,a10			;player 2 on team 2

	callr	get_plr_spch_ptrs

	move	@special_heads+30h,a14
	jrn	#tag4
	movi	NME_SPCH_TBL_SZ,a1
	mpys	a14,a1
	move	a1,a0
	addi	special_name_speech,a1
	addi	special_pass_speech,a0
	move	a1,a2
#tag4
	move	a1,@spch_name_ram+192,L
	move	a2,@spch_name_ram+224,L
	move	a0,@spch_pass_ram+64,L
	rets


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
 SUBRP	get_plr_spch_ptrs

	move	*a10,a0,L
	movi	name_sort,a14
	movi	-1,a10
#lp4
	inc	a10
	move	*a14+,a1,L
	cmp	a1,a0
	jrnz	#lp4

	movi	NME_SPCH_TBL_SZ,a1
	mpys	a10,a1
	move	a1,a0
	move	a1,a2

	addi	name_speech,a1
	addi	pass_speech,a0
	addi	full_name_speech,a2
	rets

;-----------------------------------------------------------------------------
	.end
