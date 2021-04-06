**************************************************************************
*											     *
*  This loop spawns off the individual paper processes			     *
*											     *
**************************************************************************

	movk	2,a5
brc2	movi	a_big_paper,a9		    	; a9 = animation to use
	create	pid_bani,garbage_straight
	movi	a_lil_paper,a9		    	; a9 = animation to use
	create	pid_bani,garbage_straight
	movi	a_leaf,a9     		    	; a9 = animation to use
	create	pid_bani,garbage_straight
	create	pid_bani,garbage_straight
	create	pid_bani,garbage_straight	; straight does NOT loop on screen

	movi	a_big_paper,a9
	create	pid_bani,garbage_loop	; does a Loop-dee-Loop onscreen
	movi	a_lil_paper,a9
	create	pid_bani,garbage_loop
	dsj	a5,brc2








;**********************************************


garbage_straight
	callr	get_paper_object		; you can write your version of this
simp4	callr	paper_start_position		; compute where to start paper (offscreen)
	callr	paper_glide			; random velocities (to look real)
	callr	paper_glide			; random velocities (to look real)
	clr	a1				; dx
	clr	a2	 			; dy
	jsrp	paper_fly_offscreen		; wait for piece to go offscreen
	jruc	simp4


garbage_loop
	callr	get_paper_object

ploop1	callr	paper_start_position
	callr	paper_glide
*
* this code makes the piece go Loop-dee-Loop
*
	movi	->2800,a10			; dy
ploop2	movi	->4000,a1			; dx
	move	*a8(oxvel),a0,l
	abs	a0
	cmpi	>8000,a0
	jrhi	ploop3
	movi	>5000,a10			; reached peak ---> head downwards
ploop3	move	a10,a2
	callr	paper_loop_sleep
	cmpi	->20000,a1
	jrgt	ploop2

ploop4	movi	>3000,a1			; dx
	movi	>3000,a2			; dy
	callr	paper_loop_sleep

	cmpi	>30000,a2
	jrlt	ploop5
	movi	>30000,a2
ploop5
	cmpi	>30000,a1
	jrlt	ploop4

	movi	>3000,a1			; dx
	movi	->2000,a2			; dy
	jsrp	paper_fly_offscreen
	jruc	ploop1				; offscreen = start over agin !


paper_fly_offscreen
	move	a1,*a13(p_store1),w
	move	a2,*a13(p_store2),w

pfo4	move	*a13(p_store1),a1,w
	move	*a13(p_store2),a2,w
	callr	paper_loop_sleep
	calla	next_anirate
	move	@worldtlx1+16,a1,w
	addi	scrrgt,a1			; a1 = right edge
	move	*a8(oxpos),a0,w			; a0 = obj position
	cmp	a1,a0
	jrlt	pfo4		 		; on screen = loopy
	retp

*
* Input:
*         a1 = x velocity change
*         a2 = y velocity change
*
paper_loop_sleep
	move	*a8(oyvel),a0,l
	add	a2,a0
	move	a0,*a8(oyvel),l
	move	*a8(oxvel),a0,l
	add	a1,a0
	move	a0,*a8(oxvel),l

	pull	a11			; return address
	sleep	1
	calla	next_anirate

	move	*a8(oxvel),a1,l
	move	*a8(oyvel),a2,l
	jump	a11			; return


paper_glide
	pull	a11
	movi	>20000,a0
	calla	srand
	subi	>4000,a0		; nudge things up
	move	a0,*a8(oyvel),l

	movi	>20,a0
	movi	>08,a1
	calla	randu_minimum
	move	a0,a10
glid3	sleep	1
	calla	next_anirate
	dsj	a10,glid3
	jump	a11			; return

;******************

get_paper_object
	pull	a11

	movi	>30,a0
	calla	randu
	calla	prcslp

	movk	4,a0
	calla	init_anirate
	move	*a9,a5,l

					; you probably have a routine which
					; does the equivalent of this !
	calla	gso_dmawnz		; get object with write non-zero bit set

	movi	baklst4,b4
	move	a8,a0
	calla	insobj_v   		; insert on baklst 4 !!
	jump	a11

*
* Start position = just off the left side of the screen (flies to the right)
*
paper_start_position
	movi	>0000fff0,a4
	movi	>40,a0				; this range !!
	movi	>80,a1				; at least this low on the screen
	calla	randu_minimum			; a1 = randomness #
	sll	16,a0				; random starting y position
	addxy	a0,a4
	callr	a4_to_world_coor		; and rets

	movi	>40000,a0
	movi	>40000,a1
	calla	randu_minimum
	move	a0,*a8(oxvel),l			; random starting vel
	rets

*
* Convert A4 (screen coordinates) to world coordinates
*
a4_to_world_coor
	move	@worldtlx1+16,a0,w
	move	@worldtly+16,a1,w
	sll	16,a1
	or	a0,a1
	addxy	a1,a4				; a4 = coordinate for obj
	calla	set_xy_coordinates
	rets


;*****************************************************************


*
* Garbage/Paper animations
*

a_paper1	.long	PAPER1
	.long	PAPER2
	.long	PAPER3
	.long	PAPER4
	.long	PAPER5
	.long	PAPER6
	.long	PAPER7
	.long	PAPER8
	.long	PAPER9
	.long	0


a_big_paper
	.long	LGSHEET1
	.long	LGSHEET2
	.long	LGSHEET3
	.long	LGSHEET4
	.long	LGSHEET5
	.long	LGSHEET6
	.long	LGSHEET7
	.long	LGSHEET8
	.long	LGSHEET9
	.long	ani_jump,a_big_paper

a_lil_paper
	.long	SMSHEET1
	.long	SMSHEET2
	.long	SMSHEET3
	.long	SMSHEET4
	.long	SMSHEET5
	.long	SMSHEET6
	.long	SMSHEET7
	.long	SMSHEET8
	.long	SMSHEET9
	.long	ani_jump,a_lil_paper

a_leaf	.long	LEAF1
	.long	LEAF2
	.long	LEAF3
	.long	LEAF4
	.long	LEAF5
	.long	LEAF6
	.long	LEAF7
	.long	LEAF8
	.long	ani_jump,a_leaf



*
* LOD file for paper/garbage images
*
C:\VIDEO\KOMBAT3\IMG\MKBGANI2.IMG
---> PAPER1,LGSHEET1,SMSHEET1,LEAF1,SKTORCH1
POF>
---> PAPER2,PAPER3,PAPER4,PAPER5,PAPER6,PAPER7,PAPER8,PAPER9
---> LGSHEET2,LGSHEET3,LGSHEET4,LGSHEET5,LGSHEET6,LGSHEET7
---> LGSHEET8,LGSHEET9,SMSHEET2,SMSHEET3,SMSHEET4,SMSHEET5
---> SMSHEET6,SMSHEET7,SMSHEET8,SMSHEET9,LEAF2,LEAF3,LEAF4,LEAF5
---> LEAF6,LEAF7,LEAF8

