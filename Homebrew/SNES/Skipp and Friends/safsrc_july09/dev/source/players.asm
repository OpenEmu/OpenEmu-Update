
;***********************************************************
; player CODES
;***********************************************************

.include "snes.inc"
.include "objects.inc"
.include "ingame.inc"
.include "snes_zvars.inc"
.include "collision.inc"
.include "sprites.inc"
.include "graphics.inc"
.include "explosion.inc"
.include "snesmod.inc"
.include "sounds.inc"

;=================================================================================
; DEFINITIONS
;=================================================================================
INV_TIME	= 15
BARRIER_TIME	= 250

SpriteOffsetX	= 16
SpriteOffsetY	= 32-4;18+4+7

PUSHING_DELAY	= 15
VRAM_TARGET	= 06000H

SLIDE_SPEED	= 25
SLIDE_CENTERING_SPEED = 15

SCREAM_RANGE	= 5

; animations:
ANIM_IDLE	=0
ANIM_MOVE	=1
ANIM_EXPLODE	=2
ANIM_ROCKET	=3
ANIM_ROCKETSTART=4
ANIM_LASER	=5
ANIM_HIT	=6
ANIM_DIE	=7
ANIM_SCREAM	=8

;=================================================================================
; IMPORTS
;=================================================================================
	.import oam_table, oam_hitable
	.import level_slide
	.importzp ActivePlayer
	
	.import OBJR_Laser_Init
	.import Objects_StunArea
	.importzp Timer

;=================================================================================
; EXPORTS
;=================================================================================
	.export OBJR_Player1_Init, OBJR_Player2_Init, OBJR_Player3_Init
	.export Players_Update
	.export Players_Draw
	.export DamagePlayer
	
	.export PL_Exited

	.exportzp PL_Moves1, PL_Moves2 ;, PL_Moves3, PL_Moves4
	.exportzp PL_KeyH, PL_KeyV, PL_KeyM
	.exportzp PL_XL, PL_XH, PL_YL, PL_YH
	.exportzp PL_HP
	.exportzp PL_HasKey
	.exportzp PL_State
	
;=================================================================================
; POOPIES
;=================================================================================
.define poopies 46




;=================================================================
	.code
;=================================================================


;              |IDLE|MOVE|EXPLODE|ROCKET|ROCKETST|LASER|HIT|DIE|SCREAM|
P1_AnimTable_Start:
	.byte	   0,   1,      9,     7,       5,   99, 99, 99,    99
P1_AnimTable_End:
	.byte	   1,   5,     10,     9,       7,   99, 99, 99,    99
P1_AnimTable_Rate:
	.byte	   0,  40,      2,    50,      20,   99, 99, 99,    99
P1_AnimTable_Loop:
	.byte	   0,   1,    128,     7,      -1,   99, 99, 99,    99
	
P2_AnimTable_Start:
	.byte	   0,   1,     99,    99,      99,    5, 99, 99,    99
P2_AnimTable_End:
	.byte	   1,   5,     99,    99,      99,    7, 99, 99,    99
P2_AnimTable_Rate:
	.byte	   0,  30,     99,    99,      99,   50, 99, 99,    99
P2_AnimTable_Loop:
	.byte	   0,   1,     99,    99,      99,  128, 99, 99,    99
	
P3_AnimTable_Start:
	.byte	   0,   1,      9,     7,       5,   99, 99, 99,    5
P3_AnimTable_End:
	.byte	   1,   5,     10,     9,       7,   99, 99, 99,    7
P3_AnimTable_Rate:
	.byte	   0,  30,      2,    50,      20,   99, 99, 99,    40
P3_AnimTable_Loop:
	.byte	   0,   1,    128,     7,      -1,   99, 99, 99,    5
	
	
P1_NFRAMES = 10
P2_NFRAMES = 7
P3_NFRAMES = 7
	
P1_SpriteDirMap:
	.word	.LOWORD(gfx_player1Tiles)+(P1_NFRAMES*512)*2
	.word	.LOWORD(gfx_player1Tiles)+(P1_NFRAMES*512)*1
	.word	.LOWORD(gfx_player1Tiles)+(P1_NFRAMES*512)*2
	.word	.LOWORD(gfx_player1Tiles)+(P1_NFRAMES*512)*0
	
P2_SpriteDirMap:
	.word	.LOWORD(gfx_player2Tiles)+(P2_NFRAMES*512)*2
	.word	.LOWORD(gfx_player2Tiles)+(P2_NFRAMES*512)*1
	.word	.LOWORD(gfx_player2Tiles)+(P2_NFRAMES*512)*2
	.word	.LOWORD(gfx_player2Tiles)+(P2_NFRAMES*512)*0
	
P3_SpriteDirMap:
	.word	.LOWORD(gfx_player3Tiles)+(P3_NFRAMES*512)*2
	.word	.LOWORD(gfx_player3Tiles)+(P3_NFRAMES*512)*1
	.word	.LOWORD(gfx_player3Tiles)+(P3_NFRAMES*512)*2
	.word	.LOWORD(gfx_player3Tiles)+(P3_NFRAMES*512)*0

PL_AT_START:
	.word	P1_AnimTable_Start
	.word	P2_AnimTable_Start
	.word	P3_AnimTable_Start

PL_AT_END:
	.word	P1_AnimTable_End
	.word	P2_AnimTable_End
	.word	P3_AnimTable_End

PL_AT_RATE:
	.word	P1_AnimTable_Rate
	.word	P2_AnimTable_Rate
	.word	P3_AnimTable_Rate

PL_AT_LOOP:
	.word	P1_AnimTable_Loop
	.word	P2_AnimTable_Loop
	.word	P3_AnimTable_Loop

PL_MoveSpeed:
	.byte	30	;p1
	.byte	20	;p2
	.byte	35	;p3

;=================================================================
	.zeropage
;=================================================================

;
; bit0 = up
; bit1 = down
; bit2 = left
; bit3 = right
;
PL_Input:	.res 3
INPUT_UP	=1
INPUT_DOWN	=2
INPUT_LEFT	=4
INPUT_RIGHT	=8

PL_HP:		.res 3

; move counters
PL_Moves1:	.res 3
PL_Moves2:	.res 3

PL_NControl:	.res 3

PL_HasKey:	.res 3

;-----------------------------------------------------------------
; 12.4 fixed point coordinates
;-----------------------------------------------------------------
PL_XL:		.res 3
PL_XH:		.res 3
PL_YL:		.res 3
PL_YH:		.res 3

PL_KeyH:	.res 3
PL_KeyV:	.res 3
PL_KeyM:	.res 3

PL_State:	.res 3
STATE_MOVE	=0
STATE_ROCKETW	=1
STATE_ROCKET	=2
STATE_EXPLODE	=3
STATE_LASER	=4
STATE_SCREAM	=5
STATE_DEAD	=6
STATE_REALLYDEAD=7
PL_Timer:	.res 3

AT_START:	.res 2
AT_END:		.res 2
AT_RATE:	.res 2
AT_LOOP:	.res 2

;=================================================================
	.bss
;=================================================================

PL_AnimIndex:	.res 3
PL_AnimFrame:	.res 3
PL_AnimFrac:	.res 3

PL_PushTime:	.res 3
PL_Pushing:	.res 3

PL_PrevX:	.res 3
PL_PrevY:	.res 3

PL_Inv:		.res 3

PL_RocketVel:	.res 3

PL_Exited:	.res 3

;-----------------------------------------------------------------
; 0 = left
; 1 = up
; 2 = right
; 3 = down
;-----------------------------------------------------------------
PL_Direction:	.res 3
DIR_LEFT =0|128
DIR_UP   =1
DIR_RIGHT=2
DIR_DOWN =3
	
;================================================================================
	.code
	.a8
	.i8
;================================================================================

;=================================================================
OBJR_Player1_Init:
;=================================================================
	ldx	#0
	bra	InitCode
	
;=================================================================
OBJR_Player2_Init:
;=================================================================
	ldx	#1
	bra	InitCode
	
;=================================================================
OBJR_Player3_Init:
;=================================================================
	ldx	#2
;	bra	InitCode
	
;================================================================================
InitCode:
;================================================================================
	lda	ObjX, y			; copy coordinates
	sta	PL_XH, x		;
	lda	#128			;
	sta	PL_XL, x		;
	sta	PL_YL, x		;
	lda	ObjY, y			;
	sta	PL_YH, x		;
	lda	ObjDir, y		;
	cmp	#0
	bne	:+
	ora	#128
:	sta	PL_Direction, x		;
	stz	PL_HasKey, x
;-----------------------------------------------------------------
	lda	#2			; reset HP
	sta	PL_HP, x		;
;-----------------------------------------------------------------
	lda	ObjA1, y		; setup move counters
	sta	PL_Moves1, x		;
	lda	ObjA2, y		;
	sta	PL_Moves2, x		;
;-----------------------------------------------------------------
	stz	PL_KeyH, x		; reset input
	stz	PL_KeyV, x		;
	stz	PL_KeyM, x
;-----------------------------------------------------------------
	stZ	PL_Inv, x		; reset INV
	stz	PL_PrevX, x		; reset prevcoords
	stz	PL_PrevY, x		;
	stz	PL_Exited, x
;-----------------------------------------------------------------
	lda	#0			; delete object
	sta	ObjType, y		;
;-----------------------------------------------------------------
	stz	PL_State, x
	stz	PL_Timer, x
	
	lda	ObjA3, y
	beq	:+
	txa
	sta	ActivePlayer
:
	
;	lda	#9
;	sta	PL_Moves1,X
;	lda	#9
;	sta	PL_Moves2,X
	rts
	
	.i16

;=================================================================
PI_KEYS = m0
PI_D1 = m1
PI_D2 = m1+1
PI_OPP = m2+1
PI_V1 = m3
PI_V2 = m3+1
;============================================================================================
ProcessInput:
;============================================================================================
	lda	PI_KEYS			; determine direction
	cmp	#1			; 
	bcc	INPUT_0			;
	beq	INPUT_1			;
;--------------------------------------------------------------------------------------------
INPUT_2:				;2: DOWN/RIGHT
;--------------------------------------------------------------------------------------------
	lda	PL_Direction, x		;
	cmp	PI_D1			;
	beq	:+			;
	lda	PL_Input, x		; 
	bit	PI_OPP			; test if opposite directions are pressed
	bne	:++			;
:	lda	#ANIM_MOVE		;  if not, set animation and change direction
	jsr	SetAnimation		;
	lda	PI_D2			;
	sta	PL_Direction, x		;
	lda	PL_Input, x		;
:	ora	PI_V2			; set input bit (v1)
	eor	#-1			; clear V2
	ora	PI_V1			;
	eor	#-1			;
	bra	INPUT_FINISHED		;
;--------------------------------------------------------------------------------------------
INPUT_1:				;1: UP/LEFT
;--------------------------------------------------------------------------------------------

	lda	PL_Direction, x		;
	cmp	PI_D2			;
	beq	:+			;
	lda	PL_Input, x		;
	bit	PI_OPP			; test if opposite directions are pressed
	bne	:++			;
:	lda	#ANIM_MOVE		;  it not, set animation and change direction
	jsr	SetAnimation		;
	lda	PI_D1			;
	sta	PL_Direction, x		;
	lda	PL_Input, x		;
:	ora	PI_V1			; set input bit
	eor	#-1			;
	ora	PI_V2			;
	eor	#-1			;
	bra	INPUT_FINISHED		;
;--------------------------------------------------------------------------------------------
INPUT_0:				;0: IDLE
;--------------------------------------------------------------------------------------------
	lda	PL_Input, x		; set animation to IDLE if
	bit	PI_OPP			; other directions arent
	bne	:+			; pressed
	lda	#ANIM_IDLE		;
	jsr	SetAnimation		;
:	lda	PI_V1			; clear input bits		
	ora	PI_V2			;
	eor	#-1			;
	and	PL_Input, x		;
					;
;--------------------------------------------------------------------------------------------
INPUT_FINISHED:
;--------------------------------------------------------------------------------------------
	sta	PL_Input, x
	rts


.macro PA_RunTestUp function, special

	phx					; x = top
	lda	PL_MoveSpeed, x			;
	ldx	m6				;
	jsr	function			;
	rol	m4				;
	cpx	m5				;
	bcc	:+				;
	stx	m5				;
:	plx					;
	bit	#(1<<6)				;
	;bne	special				;
	beq	:+
	lda	#1
	sta	m4+1
:
	
.endmacro

.macro PA_RunTestDown function, special
	phx
	lda	PL_MoveSpeed, x
	ldx	m6
	jsr	function
	rol	m4
	cpx	m5
	bcs	:+
	stx	m5
:	plx
	bit	#(1<<6)
	;bne	special
	beq	:+
	lda	#1
	sta	m4+1
:
.endmacro

;===========================================================================================
.macro macProcessAxis INP_UP, INP_DOWN, INP_OPP, XL, XH, YL, YH, CV_Up, CV_Down, CV_Left, CV_Right
;===========================================================================================
	.local	@Ninput_down, @input_up, @inp_p2, @right_hit, @left_hit, @no_slide
	.local	@slide_left, @slide_right, @input_down
	.local	@skip_process

	stz	m4				; reset flag
	stz	m4+1
	lda	PL_Input, x			; examine input
	bit	#INP_UP				;
	bne	@input_up			;
	bit	#INP_DOWN			;
	beq	@Ninput_down			;
	jmp	@input_down			;
@Ninput_down:					;
	jmp	@skip_process			;
;-------------------------------------------------------------------------------------------
@input_up:
;-------------------------------------------------------------------------------------------

	lda	YH, x				; m6 = top
	xba					; m5 = top - speed
	lda	YL, x				;
	rep	#21h				;
	sbc	#(7*16)-1			;
	sta	m6				;
	sep	#20h
	sbc	PL_MoveSpeed, x			;
	xba
	sbc	#0
	xba
	rep	#20h
	sta	m5				;
;-------------------------------------------------------------------------------------------
	sep	#20h				; test left point
	lda	XH, x				;
	xba					;
	lda	XL, x				;
	rep	#21h				;
	pha					;
	sbc	#7*16-1				;
	tay					;
	sep	#20h				;
						;
	PA_RunTestUp CV_Up			;
;-------------------------------------------------------------------------------------------
	rep	#21h				; test right point
	pla					;
	adc	#6*16				;
	tay					;
	sep	#20h				;
						;
	PA_RunTestUp CV_Up			;
;-------------------------------------------------------------------------------------------
	rep	#21h				; set new Y
	lda	m5				;
	adc	#7*16				;
	sep	#20h				;
	sta	YL, x				;
	xba					;
	sta	YH, x				;
;-------------------------------------------------------------------------------------------
@inp_p2:
	lda	m4+1				; check if 'special' flag is set
	beq	:+				;'
	lda	#1				; set pushing flag
	sta	PL_Pushing, x			;
	stz	m4
:
;------------------------------------------------------------------------------------------
	lda	PL_Input, x			; skip sliding on perp input
	bit	#INP_OPP			;
	bne	@no_slide			;
	lda	m4				; skip sliding on no collision
	beq	@no_slide			;
;-------------------------------------------------------------------------------------------
	bit	#%10				; left collision only: slide right
	bne	@left_hit			; right collision only: slide left
@right_hit:					;	
	bra	@slide_left			;
@left_hit:					;
	bit	#%01				;
	beq	@slide_right			;
@no_slide:					;
	jmp	@skip_process			;

;-------------------------------------------------------------------------------------------
@slide_left:
;-------------------------------------------------------------------------------------------
	lda	YH, x				; slide X left with clipping
	xba					; (center test)
	lda	YL, x				;
	tay					;
	lda	XH, x				;
	xba					;
	lda	XL, x				;
	rep	#21h				;
	sbc	#7*16-1				;
	phx					;
	tax					;
	sep	#20h				;
	lda	#16*2				;
	jsr	CV_Left				;
	rep	#21h				;
	txa					;
	plx					;
	adc	#7*16				;
	sep	#20h				;
	sta	XL, x				;
	xba					;
	sta	XH, x				;
	jmp	@skip_process			;
;-------------------------------------------------------------------------------------------
@slide_right:
;-------------------------------------------------------------------------------------------
	lda	YH, x				; slide X right with clipping
	xba					; center test
	lda	YL, x				;
	tay					;
	lda	XH, x				;
	xba					;
	lda	XL, x				;
	rep	#21h				;
	adc	#6*16				;
	phx					;
	tax					;
	sep	#20h				;
	lda	#16*2				;
	jsr	CV_Right			;
	rep	#21h				;
	txa					;
	plx					;
	sbc	#6*16-1				;
	sep	#20h				;
	sta	XL, x				;
	xba					;
	sta	XH, x				;
	
	jmp	@skip_process			;

;-------------------------------------------------------------------------------------------
@input_down:
;-------------------------------------------------------------------------------------------

	lda	YH, x				; m6 = PY  + 6#
	xba					;
	lda	YL, x				;
	rep	#21h				;
	adc	#6*16				;
	sta	m6				;
	sep	#20h
	adc	PL_MoveSpeed, x			; m5 = m6 + SPEED
	xba
	adc	#0
	xba
	rep	#20h
	sta	m5				;
;-------------------------------------------------------------------------------------------
	sep	#20h				; test left point
	lda	XH, x				;
	xba					;
	lda	XL, x				;
	rep	#21h				;
	pha					;
	sbc	#7*16-1				;
	tay					;
	sep	#20h				;
	PA_RunTestDown CV_Down			;
;-------------------------------------------------------------------------------------------
	rep	#21h				; test right point
	pla					;
	adc	#6*16				;
	tay					;
	sep	#20h				;
	PA_RunTestDown CV_Down			;
;-------------------------------------------------------------------------------------------
	rep	#21h				; set new Y
	lda	m5				;		
	sbc	#6*16-1				;
	sep	#20h				;
	sta	YL, x				;
	xba					;
	sta	YH, x				;
	jmp	@inp_p2				;

@skip_process:
	rts
.endmacro

;===========================================================================================
ProcessAxisV:
;===========================================================================================
	macProcessAxis INPUT_UP, INPUT_DOWN, INPUT_LEFT|INPUT_RIGHT, PL_XL, PL_XH, PL_YL, PL_YH, ClipVectorUp, ClipVectorDown, ClipVectorLeft, ClipVectorRight

;===========================================================================================
ProcessAxisH:
;===========================================================================================
	macProcessAxis INPUT_LEFT, INPUT_RIGHT, INPUT_UP|INPUT_DOWN, PL_YL, PL_YH, PL_XL, PL_XH, ClipVectorLeft, ClipVectorRight, ClipVectorUp, ClipVectorDown

;=================================================================
.macro Push456
;=================================================================
	ldx	m4			; push m4,m5,m6
	phx				;
	ldx	m5			;
	phx				;
	ldx	m6			;
	phx				;
.endmacro				;
;-----------------------------------------------------------------

;=================================================================
.macro Pop456
;=================================================================
	plx				; pop m6,m5,m4
	stx	m6			;
	plx				;
	stx	m5			;
	plx				;
	stx	m4			;
.endmacro				;
;-----------------------------------------------------------------

;=====================================================================================
UpdatePushing:
;=====================================================================================
	lda	PL_Pushing, x		; reset pushtime if not pushing
	bne	:+			;
	stz	PL_PushTime, x		;
	rts				;
:					;
;-------------------------------------------------------------------------------------
	jsr	DoOpenDoors2
	stz	PL_Input, x		; reset input, stop animation
	lda	#ANIM_IDLE		;
	jsr	SetAnimation		;
	inc	PL_PushTime, x		; increment pushtime until >= PUSHING_DELAY
	lda	PL_PushTime, x		;
	cmp	#PUSHING_DELAY		;
	bcs	@do_push		;
	rts				;
;-------------------------------------------------------------------------------------
@do_push:				;
	stz	PL_PushTime, x		; reset pushtime
;-------------------------------------------------------------------------------------
	lda	PL_XH, x		; copy point & index
	sta	OTX			;
	lda	PL_YH, x		;
	sta	OTY			;
	txa				;
	sta	OTP			;
;-------------------------------------------------------------------------------------
	lda	PL_Direction, x		; determine push direction
	phx				;-preserve x
	and	#127			;
	cmp	#1			;
	beq	@up			;
	cmp	#2			;
	beq	@right			;
	bcs	@down			;
;-------------------------------------------------------------------------------------
@left:	dec	OTX			; push objects
	jsr	Objects_PushLeft	;
	plx				;
	rts				;
@up:	dec	OTY			;
	jsr	Objects_PushUp		;
	plx				;
	rts				;
@right:	inc	OTX			;
	jsr	Objects_PushRight	;
	plx				;
	rts				;
@down:	inc	OTY			;
	jsr	Objects_PushDown	;
	plx				;
	rts				;
;-------------------------------------------------------------------------------------
	
	
;===============================================================================
.macro TestSliding
;===============================================================================
.scope
	lda	PL_XH, x		; get tile address
	sta	m0			;
	lda	PL_YH, x		;
	sta	m0+1			;
	xba				;
	lda	m0			;
	asl				;
	asl				;
	rep	#20h			;
	lsr				;
	lsr				;
	phx				;
	tax				;
	sep	#20h			;
;-------------------------------------------------------------------------------
	lda	F:level_slide, x	; read sp map
	beq	@no_slide		; do slide
	cmp	#1			;
	beq	@s_left			;
	cmp	#2			;
	beq	@s_up			;
	cmp	#3			;
	beq	@s_right		;
	cmp	#4			;
	beq	@s_down			;
	bra	@no_slide		;
;-------------------------------------------------------------------------------
@s_left:
;-------------------------------------------------------------------------------
	dec	m0
	jsr	TestForEntitiesT
	bcs	@no_slide
	lda	#1
	bra	@start_slide
;-------------------------------------------------------------------------------
@s_up:
;-------------------------------------------------------------------------------
	dec	m0+1
	jsr	TestForEntitiesT
	bcs	@no_slide
	lda	#2
	bra	@start_slide
;-------------------------------------------------------------------------------
@s_right:
;-------------------------------------------------------------------------------
	inc	m0
	jsr	TestForEntitiesT
	bcs	@no_slide
	lda	#3
	bra	@start_slide
;-------------------------------------------------------------------------------
@s_down:
;-------------------------------------------------------------------------------
	inc	m0+1
	jsr	TestForEntitiesT
	bcs	@no_slide
	lda	#4
	
@start_slide:
	plx
	sta	PL_NControl, x
	bra	:+
@no_slide:
	plx
	lda	PL_NControl, x
	beq	:+
	stz	PL_NControl, x
	stz	PL_Input, x
:
.endscope
.endmacro
;-------------------------------------------------------------------------------

;========================================================================================
ProcessSlides:
;========================================================================================
	TestSliding
	
	lda	PL_NControl, x			; test for slide
	bne	:+				;
	clc
	rts
:

	cmp	#1				; slide left?
	beq	@sleft				;
	cmp	#2				; slide up?
	beq	@sup				;
	cmp	#3				; slide right??
	beq	@sright				;
	cmp	#4				; slide down?
	beq	@sdown				;
	sec
	rts
@sleft:
	lda	PL_XL, x
	sec
	sbc	#SLIDE_SPEED
	sta	PL_XL, x
	lda	PL_XH, x
	sbc	#0
	sta	PL_XH, x
	bra	@SLIDING_H
@sup:
	lda	PL_YL, x
	sec
	sbc	#SLIDE_SPEED
	sta	PL_YL, x
	lda	PL_YH, x
	sbc	#0
	sta	PL_YH, x
	bra	@SLIDING_V
@sright:
	lda	PL_XL, x
	clc
	adc	#SLIDE_SPEED
	sta	PL_XL, x
	lda	PL_XH, x
	adc	#0
	sta	PL_XH, x
	bra	@SLIDING_H
@sdown:
	lda	PL_YL, x
	clc
	adc	#SLIDE_SPEED
	sta	PL_YL, x
	lda	PL_YH, x
	adc	#0
	sta	PL_YH, x
	bra	@SLIDING_V
@SLIDING_H:
	lda	PL_YL, x
	cmp	#8*16
	beq	@sh_centered
	bcs	@sh_higher
	
	adc	#SLIDE_CENTERING_SPEED
	cmp	#8*16
	bcc	@sh_notcentered
	lda	#8*16
	bra	@sh_notcentered
@sh_higher:
	sbc	#SLIDE_CENTERING_SPEED
	cmp	#8*16
	bcs	@sh_notcentered
	lda	#8*16
@sh_notcentered:
	sta	PL_YL, x
@sh_centered:

	bra	@SLIDING

@SLIDING_V:
	lda	PL_XL, x
	cmp	#8*16
	beq	@sv_centered
	bcs	@sv_higher
	adc	#SLIDE_CENTERING_SPEED
	cmp	#8*16
	bcc	@sv_notcentered
	lda	#8*16
	bra	@sv_notcentered
@sv_higher:
	sbc	#SLIDE_CENTERING_SPEED
	cmp	#8*16
	bcs	@sv_notcentered
	lda	#8*16
@sv_notcentered:
	sta	PL_XL, x
@sv_centered:
	bra	@SLIDING
	
@SLIDING:
	lda	#0
	jsr	SetAnimation
	sec
	rts

;-----------------------------------------------------------------------------------

;========================================================================================
ProcessSteps:
;========================================================================================
	lda	PL_XH, x			; test for change in position (H)
	cmp	PL_PrevX, x			;
	bne	@new				;
	lda	PL_YH, x			;
	cmp	PL_PrevY, x			;
	beq	@old				;
;----------------------------------------------------------------------------------------
@new:	lda	PL_PrevX, x			; release previous location
	sta	OTX				;
	lda	PL_PrevY, x			;
	sta	OTY				;
	stz	OTSTEP				;
	phx					;
	jsr	Objects_Step			;
	plx					;
;----------------------------------------------------------------------------------------
	lda	PL_XH, x			; press new position
	sta	PL_PrevX, x			;
	sta	OTX				;
	lda	PL_YH, x			;
	sta	PL_PrevY, x			;
	sta	OTY				;
	lda	#1				;
	sta	OTSTEP				;
	phx					;
	jsr	Objects_Step			;
	plx					;
;----------------------------------------------------------------------------------------
@old:	rts

.macro ProcessInv
	bit	Flipper
	bmi	:+
	lda	PL_Inv, x
	beq	:+
	dec	PL_Inv, x
:
.endmacro

;==============================================================================
Players_Update:
;==============================================================================
	Push456				; push regs, update players, pop regs, return
	ldx	#0			; 
	jsr	DoUpdate		;
	ldx	#1			;
	jsr	DoUpdate		;
	ldx	#2			;
	jsr	DoUpdate		;	
	Pop456				;
	rts				;

;==============================================================================
DoMoving:
;==============================================================================
	tyx
	jsr	ProcessSlides		; process sliding
	bcc	:+			;
	rts
;------------------------------------------------------------------------------
:	lda	PL_KeyH, x				; process horizontal input
	sta	PI_KEYS					;
	lda	#(INPUT_UP|INPUT_DOWN)			;
	sta	PI_OPP					;
	ldy	#(INPUT_LEFT)|((INPUT_RIGHT)<<8)	;
	sty	PI_V1					;
	ldy	#(DIR_LEFT)|((DIR_RIGHT)<<8)		;
	sty	PI_D1					;
	jsr	ProcessInput				;
;------------------------------------------------------------------------------
	lda	PL_KeyV, x				; process vertical input
	sta	PI_KEYS					;
	lda	#(INPUT_LEFT|INPUT_RIGHT)		;
	sta	PI_OPP					;
	ldy	#(INPUT_UP)|((INPUT_DOWN)<<8)		;
	sty	PI_V1					;
	ldy	#(DIR_UP)|((DIR_DOWN)<<8)		;
	sty	PI_D1					;
	jsr	ProcessInput				;
;------------------------------------------------------------------------------
	stz	PL_Pushing, x
	jsr	ProcessAxisV
	jsr	ProcessAxisH
;------------------------------------------------------------------------------
	jsr	UpdatePushing
;------------------------------------------------------------------------------
	rts
	
;==============================================================================
DoMove1:
;==============================================================================
	lda	PL_Moves1, x			; quit on zero moves
	bne	:+				;
	rts					;
:						;
;------------------------------------------------------------------------------
	
	cpx	#0
	beq	DoMove_Rocket
	cpx	#1
	beq	DoMove_Laser

;------------------------------------------------------------------------------
DoMove_CardKey:
;------------------------------------------------------------------------------
	lda	#1
	sta	OTKEY
	
	jsr	DoOpenDoors

	lda	OTKEY
	bne	:+
	dec	PL_Moves1, x
	jsr	UpdatePlayerMoves
	
	
:	rts
	
;------------------------------------------------------------------------------
DoMove_Rocket:
;------------------------------------------------------------------------------
	dec	PL_Moves1, x
	jsr	UpdatePlayerMoves
	
	stz	PL_Timer, x
	lda	#STATE_ROCKETW
	sta	PL_State, x
	
	lda	#ANIM_ROCKETSTART
	jsr	SetAnimation
	
	phx
	spcPlaySoundM SND_FUSE
	plx
	rts

;------------------------------------------------------------------------------
DoMove_Laser:
;------------------------------------------------------------------------------
	dec	PL_Moves1, x
	jsr	UpdatePlayerMoves
	
	stz	PL_Timer, x
	lda	#STATE_LASER
	sta	PL_State, x
	
	lda	#ANIM_LASER
	jsr	SetAnimation
	rts
	
;==============================================================================
DoMove2:
;==============================================================================
	lda	PL_Moves2, x			; quit on zero moves
	bne	:+				;
	rts					;
:						;
;------------------------------------------------------------------------------
	cpx	#0
	beq	DoMove_Explode
	cpx	#1
	beq	DoMove_Barrier
;------------------------------------------------------------------------------
DoMove_Scream:
;------------------------------------------------------------------------------
	dec	PL_Moves2, x
	jsr	UpdatePlayerMoves
	stz	PL_Timer, x
	lda	#STATE_SCREAM
	sta	PL_State, x
	
	PHX
	spcPlaySoundM SND_SCREAM
	PLX
	
	rts
	
;------------------------------------------------------------------------------
DoMove_Explode:
;------------------------------------------------------------------------------

	.importzp CURRENT_LEVEL
	lda	CURRENT_LEVEL
	cmp	#8
	beq	:+
	dec	PL_Moves2, x
:
	jsr	UpdatePlayerMoves
	stz	PL_Timer, x
	lda	#STATE_EXPLODE
	sta	PL_State, x
	rts

;------------------------------------------------------------------------------
DoMove_Barrier:
;------------------------------------------------------------------------------
	lda	PL_Inv, x
	cmp	#30
	bcs	:+
	dec	PL_Moves2, x
	jsr	UpdatePlayerMoves
	lda	#BARRIER_TIME
	sta	PL_Inv, x
:	rts

DoOpenDoors2:
	
	lda	PL_HasKey, x
	sta	OTKEY

	
	jsr	DoOpenDoors
	
@done:
	lda	OTKEY
	bne	:+
	stz	PL_HasKey, x
:	rts
	
DoOpenDoors:

	lda	PL_XH, x
	sta	OTX
	lda	PL_YH, x
	sta	OTY
	
	lda	PL_Direction, x
	and	#127
	beq	@dir_left
	cmp	#2
	bcc	@dir_up
	beq	@dir_right
@dir_down:
	INC	OTY
	phx
	jsr	Objects_Action
	plx
	rts
@dir_left:
	DEC	OTX
	phx
	jsr	Objects_Action
	plx
	rts
@dir_up:
	DEC	OTY
	phx
	jsr	Objects_Action
	plx
	rts
@dir_right:
	INC	OTX
	phx
	jsr	Objects_Action
	plx
	rts


;==============================================================================
DoMoveA:
;==============================================================================
	jsr	DoOpenDoors
	rts

ROCKETW_TIME = 30
;==============================================================================
DoRocketStart:
;==============================================================================
	tyx
	inc	PL_Timer, x
	
.macro center_coord COORD, SPEED
	.local @clip, @higher, @center
	lda	COORD, x
	cmp	#8*16
	beq	@center
	bcs	@higher
	adc	#SPEED
	cmp	#8*16
	bcc	@center
@clip:
	lda	#8*16
	bra	@center
@higher:
	sbc	#SPEED
	cmp	#8*16
	bcc	@clip
@center:
	sta	COORD, x
.endmacro

	center_coord PL_XL, 16
	center_coord PL_YL, 16
	
	lda	PL_Timer, x
	cmp	#ROCKETW_TIME
	bne	:+
	lda	#ANIM_ROCKET
	jsr	SetAnimation
	lda	#STATE_ROCKET
	sta	PL_State, x
	lda	#30
	sta	PL_RocketVel, x
	
	PHX
	spcPlaySoundM SND_LOCO
	PLX
	
:	rts

.macro mac_rocket_move XL, XH, YL, YH, DIR
	lda	YH, x
	xba
	lda	YL, x
	tay
	lda	XH, x
	xba
	lda	XL, x
	rep	#21h
	.if DIR < 2
		sbc	#7*16-1
	.else
		adc	#6*16
	.endif
	phx
	tax
	sep	#20h
	lda	m0
	stz	m4
	.if DIR = 0
		jsr	ClipVectorLeft
	.elseif DIR = 1
		jsr	ClipVectorUp
	.elseif DIR = 2
		jsr	ClipVectorRight
	.elseif DIR = 3
		jsr	ClipVectorDown
	.endif
	rol	m4
	rep	#21h
	txa
	plx
	.if DIR < 2
		adc	#7*16
	.else
		sbc	#6*16-1
	.endif
	sep	#20h
	sta	XL, x
	xba
	sta	XH, x
	
	lda	m4
	beq	:+
	stz	PL_State, x
	stz	PL_Input, x
:	
.endmacro

;==============================================================================
DoRocket:
;==============================================================================
	tyx	
	lda	PL_RocketVel, x
	cmp	#150
	bcs	:+
	adc	#10
;	sta	PL_RocketVel, x
:
	lda	PL_RocketVel, x
	sta	m0
	
;	inc	PL_Timer,x
;	lda	PL_Timer,x
;	and	#7
;	bne	:+
;	lda	PL_YH, x
;	xba
;	lda	PL_XH, x
;	phx
;	jsr	Explosion_MiniStart
;	plx
;:
	
	inc	PL_RocketVel, x
	lda	PL_Direction, x
	and	#127
	cmp	#1
	beq	@up
	cmp	#2
	beq	@right
	bcs	@down
@left:
	mac_rocket_move PL_XL, PL_XH, PL_YL, PL_YH, 0
	rts
@up:
	
	jmp	rocket_up
@right:
	
	jmp	rocket_right
@down:
	
	jmp	rocket_down
	
rocket_up:
	mac_rocket_move PL_YL, PL_YH, PL_XL, PL_XH, 1
	rts
rocket_right:
	mac_rocket_move PL_XL, PL_XH, PL_YL, PL_YH, 2
	rts
rocket_down:
	mac_rocket_move PL_YL, PL_YH, PL_XL, PL_XH, 3
	rts
	
	
;==============================================================================
DoExplode:
;==============================================================================
	tyx
	
	center_coord PL_XL, 16
	center_coord PL_YL, 16
	
	lda	PL_XL, x
	cmp	PL_YL, x
	beq	:+
	rts
:	cmp	#8*16
	beq	:+
	rts
:
	inc	PL_Timer, x
	lda	PL_Timer, x
	cmp	#1
	bne	:+
	lda	PL_YH, x
	xba
	lda	PL_XH, x
	phx
	jsr	Explosion_Start
	plx
	lda	#ANIM_EXPLODE
	jsr	SetAnimation
	
	lda	PL_Timer, x
:	cmp	#60
	bcc	:+
	stz	PL_State, x
	stz	PL_Input, x
:	rts
	
;==============================================================================
DoLaser:
;==============================================================================
	tyx
	
	center_coord PL_XL, 16
	center_coord PL_YL, 16
	
	inc	PL_Timer, x
	lda	PL_Timer, x
	cmp	#10
	beq	@fire_laser
	cmp	#30
	bne	:+
	stz	PL_State, x
	stz	PL_Input, x
:	rts
@fire_laser:

	phx
	jsr	Objects_Allocate
	stz	ObjXF, x
	stz	ObjYF, x
	lda	#OBJ_LASER
	sta	ObjType, x
	
	lda	#1
	sta	ObjA3, x	
	stz	ObjA1, x
	stz	ObjA2, x
	txy
	plx
	lda	PL_XH, x
	sta	ObjX, y
	lda	PL_YH, x
	sta	ObjY, y

	lda	PL_Direction, x
	and	#127
	sta	ObjDir, y
;	cmp	#1
;	beq	:+
;	cmp	#3
;	beq	:+
;	lda	ObjY, y
;	dea
;	sta	ObjY, y
;:
	
	sep	#10h
	phx
	jsr	OBJR_Laser_Init
	plx
	rep	#10h
	
	PHX
	spcPlaySoundM SND_LASER
	PLX
	
	
	rts
	
;==============================================================================
DoScream:
;==============================================================================
	tyx
	
	inc	PL_Timer, x
	lda	PL_Timer, x
	cmp	#1
	bne	:+
	; play scream
	lda	#ANIM_SCREAM
	jsr	SetAnimation
	
	lda	PL_XH, x
	sec
	sbc	#SCREAM_RANGE
	sta	m0
	clc
	adc	#SCREAM_RANGE*2
	sta	m0+1
	
	lda	PL_YH, x
	sec
	sbc	#SCREAM_RANGE
	sta	m1
	clc
	adc	#SCREAM_RANGE*2
	sta	m1+1

	phx
	jsr	Objects_StunArea
	plx
	
	rts
:	cmp	#30
	bne	:+
	stz	PL_State, x
:
	rts
	
;==============================================================================
DoEternalDeathness:
;==============================================================================
	tyx
	; deathness doesn't hurt
	lda	#ANIM_MOVE
	jsr	SetAnimation
	lda	#10
	sta	PL_Inv, x
	
	inc	PL_Timer, x
	lda	PL_Timer, x
	cmp	#30
	bne	:+
	lda	#STATE_REALLYDEAD
	sta	PL_State, x
:	rts
	
DoDead:
	tyx
	rts
	
;==============================================================================
DoUpdate:
;==============================================================================

	lda	PL_Exited, x		; dont update on exited
	beq	:+			;
	rts				;
:					;
	rep	#20h
	txa
	asl
	tay
	lda	PL_AT_START, y		; set anitable directory
	sta	AT_START		;
	lda	PL_AT_END, y		;
	sta	AT_END			;
	lda	PL_AT_RATE, y		;
	sta	AT_RATE			;
	lda	PL_AT_LOOP, y		;
	sta	AT_LOOP			;
	sep	#20h
	
;------------------------------------------------------------------------------
	lda	PL_State, x		; process move input on state=0
	bne	@no_moves		;
	lda	PL_NControl, x		;
	bne	@no_moves		;
	lda	PL_KeyM, x		;
	bit	#1			;
	beq	@nmove1			;
	jsr	DoMove1			;
	bra	@no_moves		;
@nmove1:				;
	bit	#2			;	
	beq	@nmove2			;
	jsr	DoMove2			;
@nmove2:				;
;	bit	#4			;
;	beq	@no_moves		;
;	jsr	DoMoveA			;
@no_moves:				;
	stz	PL_KeyM, x		;
;------------------------------------------------------------------------------
	lda	PL_State, x		; update according to state
	asl				;
	txy				;
	tax				;
	sep	#10h
	rep	#10h
	jsr	(state_functions,x)	;
;------------------------------------------------------------------------------
	
	jsr	ProcessSteps
	ProcessInv
	jsr	UpdateAnimation
;------------------------------------------------------------------------------
	rts
	
state_functions:
	.word	DoMoving
	.word	DoRocketStart
	.word	DoRocket
	.word	DoExplode
	.word	DoLaser
	.word	DoScream
	.word	DoEternalDeathness
	.word	DoDead

;===========================================================================================
UpdateAnimation:
;===========================================================================================
	lda	PL_AnimIndex, x			; y = anim index
;	CMP	#ANIM_ROCKET

	sep	#10h				;
	tay					;
	rep	#11h				;
;-------------------------------------------------------------------------------------------
	lda	(AT_RATE), y			; frac += rate
	adc	PL_AnimFrac, x			;
	sta	PL_AnimFrac, x			;
;-------------------------------------------------------------------------------------------
	bcc	@skip_frame_inc			; increment frame on overflow
	lda	PL_AnimFrame, x			;
	ina					;
	cmp	(AT_END), y			; catch end of animation
	bne	@frame_incremented 		;
	lda	(AT_LOOP), y			; if loop&128 then stop animation
	bmi	@skip_frame_inc			; otherwise frame = loop
@frame_incremented:				;
	sta	PL_AnimFrame, x			;
@skip_frame_inc:
;-------------------------------------------------------------------------------------------
	rts

;===========================================================================================
SetAnimation:	
;===========================================================================================
; a = new animation index
;-------------------------------------------------------------------------------------------
	cmp	PL_AnimIndex, x		; skip if index is the same
	beq	@quit			;
;-------------------------------------------------------------------------------------------
	sta	PL_AnimIndex, x		; save index
;-------------------------------------------------------------------------------------------
	tay				; copy starting frame
	sep	#10h			;
	rep	#10h			;
	lda	(AT_START), y		;
	sta	PL_AnimFrame, x		;
;-------------------------------------------------------------------------------------------
	stz	PL_AnimFrac, x		; reset fraction
;-------------------------------------------------------------------------------------------
@quit:	rts				;

;=====================================================================================
SetupSprite:
;=====================================================================================
	lda	PL_Inv, x
	cmp	#50
	bcc	@short_inv
	beq	@not_inv
	lda	Timer
	and	#15
	cmp	#12
	bcc	@not_inv
	jmp	@no_sprite
@short_inv:
	lda	PL_Inv, x		; skip if flipper & invulnerable
	beq	@not_inv		; for flashign effect
	bit	Flipper			;
	bmi	@not_inv		;
	jmp	@no_sprite		;
@not_inv:				;
	lda	PL_State, x
	cmp	#STATE_REALLYDEAD
	bne	:+
	jmp	@no_sprite
:

	lda	PL_Exited, x	; dont show if player has exited
	beq	:+
	jmp	@no_sprite
:
;-------------------------------------------------------------------------------------
	lda	PL_XH, x			; a = X.pixels - tweak
	xba					;
	lda	PL_XL, x			;
	rep	#20h				;
	lsr					;
	lsr					;
	lsr					;
	lsr					;
	sec					;
	sbc	#SpriteOffsetX			;
;-------------------------------------------------------------------------------------
	sbc	CameraPX			; a -= camera
	bpl	:+				; catch offscreen sprite
	cmp	#-32				;
	bcs	:++				;
@no_sprite2:					;
	jmp	@no_sprite			;
:	cmp	#256				;
	bcs	@no_sprite2			;
:						;
;-------------------------------------------------------------------------------------
	clc
	adc	#8
	sta	m0
	sec
	sbc	#8
	sep	#20h				; SPRITE.ATTR0 = X.L
	sta	SobjXL, x			;
;-------------------------------------------------------------------------------------
	xba					; set SIZE bit, and MSB in hitable
	and	#1				;
	sta	SobjXH, x			;
	lda	#1				;
	sta	SobjSize, x			;
;-------------------------------------------------------------------------------------
	lda	PL_YH, x			; a = Y.pixels - camera
	xba					;
	lda	PL_YL, x			;
	rep	#20h				;
	lsr					;
	lsr					;
	lsr					;
	lsr					;
	sec					;
	sbc	#SpriteOffsetY			;
;-------------------------------------------------------------------------------------
	sbc	CameraPY			; a -= camera
	bpl	:+				; catch off-screen sprite
	cmp	#-31				;
	bcs	:++				;
	bra	@no_sprite			;
:	cmp	#SCREENHEIGHT			;
	bcs	@no_sprite			;
:						;
;-------------------------------------------------------------------------------------
	sep	#20h				; sprite.ATTR1 = y
	sta	SobjA1, x			;
;-------------------------------------------------------------------------------------
	txa					; character = base*4
	asl					;
	asl					;
	sta	SobjA2, x			;
;-------------------------------------------------------------------------------------
	txa					; ATTR3 = prio3, pal BASE
	asl					; HFLIP if d&128
	ora	#%00110000			;
	bit	PL_Direction, x			;
	bpl	:+				;
	ora	#%01000000			;
:	sta	SobjA3, x
;-------------------------------------------------------------------------------------
	lda	SobjA1, x			; set y index
	clc					;
	adc	#1+31				;
	sta	SobjY, x			;
;-------------------------------------------------------------------------------------
	lda	#%00100000+(DONGLESPAL<<1)	; draw shadow
	bit	Flipper				;
	bmi	:+				;
	ora	#%01000000			;
:	xba					;
	lda	SobjA1, x			;
	clc					;
	adc	#28				;
	ldx	m0				;
	ldy	#DONGLE_SHADOW			;
	AddSprite16b				;
	rts					;
;-------------------------------------------------------------------------------------
@no_sprite:					; disable sprite
	sep	#20h				;
	stz	SobjY, x			;
;-------------------------------------------------------------------------------------
	rts
	
;=====================================================================================
.macro SpriteXfer DIR, FRAME, MAP, TILES, TARGET
;=====================================================================================
	lda	DIR			; y = Direction * 2 (MAP index)
	asl				;
	tay				;
	sep	#10h			; clear top 8bits
	lda	FRAME			; a = animframe *512
	rep	#10h+20h		;
	and	#0FFh			;
	xba				;
	asl				;
	adc	MAP, y			; add map
	tay				;
	sep	#20h			;
	lda	#^TILES			; schedule transfer of graphic
	ldx	#VRAM_TARGET+TARGET*32*2;
	jsr	ScheduleSpriteXfer	;
.endmacro				;
;-------------------------------------------------------------------------------------

;=====================================================================================
Players_Draw:
;=====================================================================================
	
	SpriteXfer PL_Direction+0, PL_AnimFrame+0, P1_SpriteDirMap, gfx_player1Tiles, 0
	
	ldx	#0
	jsr	SetupSprite

	SpriteXfer PL_Direction+1, PL_AnimFrame+1, P2_SpriteDirMap, gfx_player2Tiles, 1
	
	ldx	#1
	jsr	SetupSprite

	SpriteXfer PL_Direction+2, PL_AnimFrame+2, P3_SpriteDirMap, gfx_player3Tiles, 2
	
	ldx	#2
	jsr	SetupSprite
	rts
	
;===============================================================================
RunLaser:
;===============================================================================
	lda	PL_Inv, x
	bne	@miss
	lda	PL_HP, x
	beq	@miss
	lda	PL_XH, x		; a = X tile
;-------------------------------------------------------------------------------
	cmp	m0			; test X
	bcc	@miss			;
	cmp	m0+1			;
	bcs	@miss			;
;-------------------------------------------------------------------------------
	lda	PL_YH, x		; a = Y tile 
;-------------------------------------------------------------------------------
	cmp	m1			; test Y
	bcc	@miss			;
	cmp	m1+1			;
	bcs	@miss			;
;-------------------------------------------------------------------------------
	; TODO: damage/kill? player
	jsr	DamagePlayer
;-------------------------------------------------------------------------------
@miss:
;-------------------------------------------------------------------------------
	rts
	
	.export DamagePlayer
; modifies: a
DamagePlayer:
	lda	PL_Exited, x
	bne	@no_hp
	LDA	PL_Inv, x
	bne	@no_hp
	lda	PL_State, x
	cmp	#STATE_EXPLODE
	beq	@no_hp
	lda	PL_HP, x
	beq	@no_hp
	dec	PL_HP, x
	pha
	phx
	jsr	UpdateHearts
	plx
	pla
	dea
	beq	@death
	lda	#INV_TIME
	sta	PL_Inv, x
	jmp	@do_sound
@death:
	
	lda	#STATE_DEAD
	sta	PL_State, x
	stz	PL_Timer,x 
	jsr	UpdatePlayerPalettes
	jmp	@do_sound
@no_hp:
	rts
	
@do_sound:
	cpx	#1
	bcc	@pl1
	beq	@pl2
@pl3:
	PHX
	spcPlaySoundM SND_SCREAM
	PLX
	rts
@pl2:
	
	
	PHX
	lda	PL_State, x
	cmp	#STATE_DEAD
	beq	:+
	spcPlaySoundM SND_WEDGEOW
	PLX
	rts
:	spcPlaySoundM SND_WEDGE
	PLX
	rts
	
	
@pl1:
	PHX
	lda	PL_State, x
	cmp	#STATE_DEAD
	beq	:+
	spcPlaySoundM SND_OW1
	PLX
	rts
:	spcPlaySoundM SND_WAH1
	PLX
	rts

	.export Players_ApplyLaser
;------------------------------------------------------------------------------
; m0 = x1,x2
; m1 = y1,y2
;==============================================================================
Players_ApplyLaser:
;==============================================================================
	stz	m2

	ldx	#0
	jsr	RunLaser
	inx
	jsr	RunLaser
	inx
	jsr	RunLaser

	rts

	.export Players_ApplyExplosion
	
; a=x
; b=y
;==============================================================================
Players_ApplyExplosion:
;==============================================================================
	; explosions dont affect p1

	ldx	#1
	jsr	RunExplosion
	ldx	#2
	jsr	RunExplosion

	rts
	
;==============================================================================
RunExplosion:
;==============================================================================
	cmp	PL_XH, x
	bne	@miss
	xba
	cmp	PL_YH, x
	bne	@miss_switch
	
	pha
	jsr	DamagePlayer
	pla
@miss_switch:
	xba
@miss:
	rts
	
	rts
