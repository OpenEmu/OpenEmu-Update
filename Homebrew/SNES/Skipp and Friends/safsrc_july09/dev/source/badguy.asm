
.include "snes_zvars.inc"
.include "objects.inc"
.include "collision.inc"
.include "graphics.inc"
.include "ingame.inc"
.include "sprites.inc"
.include "players.inc"

	.import NextSobj
	.import ScheduleSpriteXfer
	.import DamagePlayer

	.export OBJR_Baddie_Init
	.export OBJR_Baddie_Update
	.export OBJR_Baddie_Draw
	.export OBJR_Baddie_Explode
	.export OBJR_Baddie_Stun

; BADGUY

SpriteOffsetX	= 16
SpriteOffsetY	= 32-4;18+4+7

PATROL_SPEED	= 16
TARGET_SPEED	= 26

BADGUY_RANGE	= ObjA1

STATE		= ObjC1
OriginX		= ObjC2
OriginY		= ObjC3
SPRITE		= ObjC4

ANIMFRAME	= ObjC5
ANIMFRAC	= ObjC6
ANIMINDEX	= ObjC7
TARGET		= ObjC8

DEATHTIMER 	= ObjA4

STATE_PATROL	= 0
STATE_TARGET	= 1
STATE_DEAD	= 2
STATE_STUNNED	= 3

ANIM_IDLE	= 0
ANIM_MOVE	= 1
ANIM_HARASS	= 2
ANIM_DEAD	= 3

TOUCH_RANGE	= 128
APPROACH_RANGE  = 60

	.code

Baddie_AnimTable_Start:
	.byte	   0,   0,      0
Baddie_AnimTable_End:
	.byte	   1,   2,      2
Baddie_AnimTable_Rate:
	.byte	   0,  24,      70
Baddie_AnimTable_Loop:
	.byte	   0,   0,    0
	
NFRAMES		= 2

SpriteDirMap:
	.word	.LOWORD(gfx_baddieTiles)+(NFRAMES*512)*2
	.word	.LOWORD(gfx_baddieTiles)+(NFRAMES*512)*1
	.word	.LOWORD(gfx_baddieTiles)+(NFRAMES*512)*2
	.word	.LOWORD(gfx_baddieTiles)+(NFRAMES*512)*0
	
VRAM_BASE = 0E000H
	
SpriteLoadAddresses:

.repeat 4, i
	.word	(VRAM_BASE + i * 80H)/2
.endrep

.repeat 4, i
	.word	(VRAM_BASE + i * 80H + 800H)/2
.endrep

SpriteCharacterIndexes:
	.byte	0, 4, 8, 12, 64, 68, 72, 76

	.code
	.a8
	.i8

;=====================================================================================
OBJR_Baddie_Init:
;=====================================================================================
	tyx
	stz	STATE, x
	
	lda	ObjX, x
	sta	OriginX, x
	lda	ObjY, x
	sta	OriginY, x
	
	lda	#128
	sta	ObjXF, x
	sta	ObjYF, x
	
	lda	NextSobj
	sta	SPRITE, x
	inc	NextSobj

	stz	ANIMINDEX, x
	stz	ANIMFRAME, x
	stz	DEATHTIMER, x
	rts

;=====================================================================================
OBJR_Baddie_Update:
;=====================================================================================
	lda	STATE, y
	beq	@state_patrol
	cmp	#STATE_TARGET
	beq	@state_target
	cmp	#STATE_DEAD
	beq	@state_death
	cmp	#STATE_STUNNED
	beq	@state_stunned
	rts
@state_stunned:
	lda	#0
	jsr	SetAnimation
	jsr	UpdateAnimation
	tyx
	inc	DEATHTIMER,x
	lda	DEATHTIMER,y
	cmp	#120
	bne	:+
	
	stz	STATE, x
	stz	DEATHTIMER, x
:	rts

@state_patrol:
	
	jsr	DoMoving
	
	jsr	DoDetect
	jsr	UpdateAnimation
	rts
@state_death:
	tyx
	inc	DEATHTIMER, x		; kill object after one second
	lda	DEATHTIMER, x		;
	cmp	#60			;
	bne	:+			;
					;
	stz	ObjType, x		;
					;
					
:	
	jsr	UpdateAnimation
	rts
	
@state_target:

	lda	TARGET, y
	tax
	
	lda	PL_HP, x
	beq	@target_out_of_range
	lda	OriginX, y
	sec
	sbc	ObjA2, y
	dea
	bmi	:+
	cmp	PL_XH, x
	bcs	@target_out_of_range
:	lda	OriginX, y
	clc 
	adc	ObjA2, y
	cmp	PL_XH, x
	bcc	@target_out_of_range
	lda	OriginY, y
	sec
	sbc	ObjA3, y
	dea
	bmi	:+
	cmp	PL_YH,x
	bcs	@target_out_of_range
:	lda	OriginY, y
	clc
	adc	ObjA3, y
	cmp	PL_YH, x
	bcc	@target_out_of_range
	
	; chase target
	jsr	DoChase
	jsr	FaceTarget
	jsr	TryHurting
	
	lda	#ANIM_HARASS
	jsr	SetAnimation
	
	jsr	UpdateAnimation
	rts
	
@target_out_of_range:
	lda	#0
	sta	STATE, y
	rts



;====================================================================================	
.macro test_for_player INDEX, EXIT
;====================================================================================
	.local	@next_test
	lda	PL_HP+INDEX
	beq	@next_test
	lda	OriginX, y
	sec
	sbc	ObjA2, y
	dea
	bmi	:+
	cmp	PL_XH+INDEX
	bcs	@next_test
:	lda	OriginX, y
	clc
	adc	ObjA2, y
	cmp	PL_XH+INDEX
	bcc	@next_test

	lda	OriginY, y
	sec
	sbc	ObjA3, y
	dea
	bmi	:+
	cmp	PL_YH+INDEX
	bcs	@next_test
:	lda	OriginY, y
	clc
	adc	ObjA3, y
	cmp	PL_YH+INDEX
	bcc	@next_test
	
	lda	#INDEX
	jmp	EXIT
	
@next_test:
.endmacro
	
;====================================================================================
DoDetect:
;====================================================================================
	test_for_player 0, @found_player
	test_for_player 1, @found_player
	test_for_player 2, @found_player
	
	rts
@found_player:

	sta	TARGET, y
	lda	#STATE_TARGET
	sta	STATE, y
	rts
	
;====================================================================================
TryHurting:
;====================================================================================
	lda	TARGET, y		; m0 = abs(xdiff)
	tax				;
	lda	PL_XH, x		;
	xba				;
	lda	PL_XL, x		;
	rep	#20h			;
	sta	m0			;
	sep	#20h			;
	lda	ObjX, y			;
	xba				;
	lda	ObjXF, y		;
	rep	#20h			;
	sec				;
	sbc	m0			;
	bpl	:+			;
	eor	#0FFFFh			;
	ina				;
:	sta	m0			;
;------------------------------------------------------------------------------------
	sep	#20h			;
	lda	PL_YH, x		; a = abs(ydiff)
	xba				;
	lda	PL_YL, x		;	
	rep	#20h			;
	sta	m1			;
	sep	#20h			;	
	lda	ObjY, y			;
	xba				;
	lda	ObjYF, y		;
	rep	#20h			;
	sec				;
	sbc	m1			;
	bpl	:+			;
	eor	#0FFFFh			;
	ina				;
:					;
;------------------------------------------------------------------------------------
	clc				; get manhattan distance
	adc	m0			;
;------------------------------------------------------------------------------------
	cmp	#TOUCH_RANGE		; test for in range
	bcc	@touching		;
	sep	#20h			;
	rts				;
@touching:				;
;------------------------------------------------------------------------------------
	sep	#20h
	phy
	rep	#10h
	jsr	DamagePlayer
	sep	#10h
	ply
	rts
	
	
;====================================================================================
FaceTarget:
;====================================================================================
	lda	TARGET, y		; m0 = xdiff, +1 = abs
	tax				;
	lda	PL_XH, x		;	
	sec				;
	sbc	ObjX, y			;
	sta	m0			;
	bpl	:+			;
	eor	#255			;
	ina				;
:	sta	m0+1			;
;------------------------------------------------------------------------------------
	lda	PL_YH, x		; m1 = ydiff, +1 = abs
	sec				;
	sbc	ObjY, y			;
	sta	m1			;
	bpl	:+			;
	eor	#255			;
	ina				;
:	sta	m1+1			;
;------------------------------------------------------------------------------------
	lda	m1+1			; test for dominant axis
	cmp	m0+1			;
	bcs	@y_dominant		;
;------------------------------------------------------------------------------------
	lda	m0
	bpl	:+
	lda	#0
	bra	:++
:	lda	#2
:	sta	ObjDir, y
	rts
@y_dominant:
	lda	m1
	bpl	:+
	lda	#1
	bra	:++
:	lda	#3
:	sta	ObjDir, y
	rts
	
	
;====================================================================================
.macro DoMovement XL, XH, YL, YH, direction, function, coltest
;====================================================================================
	.local @no_collision
	
	rep	#10h			; 16bit index during this routine
;------------------------------------------------------------------------------------
	lda	YH, y			; x = Y + 7
	xba				;
	lda	YL, y			;
	rep	#21h			;
.if (direction < 2)
	sbc	#7*16-1			;
.else
	adc	#6*16
.endif
	tax				;
;------------------------------------------------------------------------------------
	sep	#20h			; y = X
	lda	XH, y			;
	xba				;
	lda	XL, y			;
	phy				;
	tay				;
;------------------------------------------------------------------------------------
	lda	m0			; a = speed
	jsr	function		; clip vector
;------------------------------------------------------------------------------------
	stz	m0			; m0 = clip result
	rol	m0
	
	ply				; write new Y
	rep	#21h			;
	txa				;
.if (direction < 2)
	adc	#7*16
.else
	sbc	#6*16-1
.endif
	sep	#20h
	sta	YL, y			;
	xba				;
	sta	YH, y			;

.if coltest = 1
;------------------------------------------------------------------------------------
	lda	m0			; test for collision
	beq	@no_collision		;
;------------------------------------------------------------------------------------
	lda	#(direction+1) & 3	; rotate 90deg
	sta	ObjDir, y		;
;------------------------------------------------------------------------------------
.endif

@no_collision:				;
	sep	#10h			;
.endmacro

; a = value
DoCentering:
	cmp	#128
	beq	@centered
	bcs	@higher
	adc	#16
	cmp	#128
	bcc	@centered
	lda	#128
	bra	@centered
@higher:
	sbc	#16
	cmp	#128
	bcs	@centered
	lda	#128
@centered:
	rts
	
;====================================================================================
DoChase:
;====================================================================================
	lda	#TARGET_SPEED
	sta	m0
	
	lda	TARGET, y
	tax
	lda	PL_XH, x
	xba
	lda	PL_XL, x
	rep	#20h
	sta	m1
	sep	#20h
	lda	ObjX, y
	xba
	lda	ObjXF, y
	rep	#20h
	sec
	sbc	m1
	sta	m1
	bmi	@x_minus
	cmp	#APPROACH_RANGE
	bcc	@x_target
	bra	@approach_left
@x_minus:
	cmp	#-APPROACH_RANGE
	bcs	@x_target
	bra	@approach_right
	
@approach_left:
	sep	#20h
	DoMovement ObjYF, ObjY, ObjXF, ObjX, 0, ClipVectorLeft, 0
	jmp	@x_target
	
@approach_right:
	sep	#20h
	DoMovement ObjYF, ObjY, ObjXF, ObjX, 2, ClipVectorRight, 0
	jmp	@x_target

@x_target:
	sep	#20h
	
	lda	#TARGET_SPEED
	sta	m0
	
	lda	TARGET, y
	tax
	lda	PL_YH, x
	xba
	lda	PL_YL, x
	rep	#20h
	sta	m1
	sep	#20h
	lda	ObjY, y
	xba
	lda	ObjYF, y
	rep	#20h
	sec
	sbc	m1
	sta	m1
	bmi	@y_minus
	cmp	#APPROACH_RANGE
	bcc	@y_target
	bra	@approach_up
@y_minus:
	cmp	#-APPROACH_RANGE
	bcs	@y_target
	bra	@approach_down
	
@approach_up:
	sep	#20h
	DoMovement ObjXF, ObjX, ObjYF, ObjY, 0, ClipVectorUp, 0
	jmp	@y_target
	
@approach_down:
	sep	#20h
	DoMovement ObjXF, ObjX, ObjYF, ObjY, 2, ClipVectorDown, 0
	jmp	@y_target

@y_target:
	sep	#20h
	
	rts
	
	
;====================================================================================
DoMoving:
;====================================================================================

	lda	#ANIM_MOVE
	jsr	SetAnimation
	
	lda	#PATROL_SPEED
	sta	m0

	lda	ObjDir, y
	beq	@left
	cmp	#2
	bcc	@up
	beq	@right
;-------------------------------------------------------------
.macro rotate_direction
	lda	ObjDir, y
	ina
	and	#3
	sta	ObjDir, y
	rts
.endmacro

@m_down:
	lda	OriginY, y
	clc
	adc	BADGUY_RANGE,y
	dea
	cmp	ObjY, y
	bcs	:+
	rotate_direction
	bra	@skip_down
:
	DoMovement ObjXF, ObjX, ObjYF, ObjY, 3, ClipVectorDown, 1
	lda	ObjXF,y
	jsr DoCentering
	sta	ObjXF,y
@skip_down:
	rts

@left:
	bra	@m_left
@up:
	jmp	@m_up
@right:
	jmp	@m_right
	

	
@m_left:
	lda	OriginX, y
	sec
	sbc	BADGUY_RANGE,y
	bmi	:+
	
	cmp	ObjX, y
	bcc	:+
	rotate_direction
	bra	@skip_left
:

	DoMovement ObjYF, ObjY, ObjXF, ObjX, 0, ClipVectorLeft, 1
	lda	ObjYF,y
	jsr DoCentering
	sta	ObjYF,y
@skip_left:
	rts
@m_up:
	lda	OriginY, y
	sec
	sbc	BADGUY_RANGE,y
	bmi	:+
	
	cmp	ObjY, y
	bcc	:+
	rotate_direction
	bra	@skip_up
:

	DoMovement ObjXF, ObjX, ObjYF, ObjY, 1, ClipVectorUp, 1
	lda	ObjXF,y
	jsr DoCentering
	sta	ObjXF,y
@skip_up:
	rts
@m_right:
	lda	OriginX, y
	clc
	adc	BADGUY_RANGE,y
	dea
	cmp	ObjX, y
	bcs	:+
	rotate_direction
	bra	@skip_right
:


	DoMovement ObjYF, ObjY, ObjXF, ObjX, 2, ClipVectorRight, 1
	lda	ObjYF,y
	jsr DoCentering
	sta	ObjYF,y
@skip_right:
	rts
	
;=====================================================================================
UpdateAnimation:
;=====================================================================================
	lda	ANIMINDEX, y			; y = anim index
	tax					;
;-------------------------------------------------------------------------------------------
	lda	Baddie_AnimTable_Rate, x	; frac += rate
	adc	ANIMFRAC, y			;
	sta	ANIMFRAC, y			;
;-------------------------------------------------------------------------------------------
	bcc	@skip_frame_inc			; increment frame on overflow
	lda	ANIMFRAME, y			;
	ina					;
	cmp	Baddie_AnimTable_End, x		; catch end of animation
	bne	@frame_incremented 		;
	lda	Baddie_AnimTable_Loop, x	; if loop&128 then stop animation
	bmi	@skip_frame_inc			; otherwise frame = loop
@frame_incremented:				;
	sta	ANIMFRAME, y			;
@skip_frame_inc:
;-------------------------------------------------------------------------------------------
	rts
	
;=====================================================================================
SetAnimation:
;=====================================================================================
	cmp	ANIMINDEX, y
	beq	@same_index
	sta	ANIMINDEX, y
	
	lda	#0
	sta	ANIMFRAC, y
	
	tax
	lda	Baddie_AnimTable_Start, x
	sta	ANIMFRAME, y
	
@same_index:
	rts
	
_no_sprite:
	sep	#30h
	lda	SPRITE, y
	tax
	stz	SobjY, x
	rts
	
;=====================================================================================
OBJR_Baddie_Draw:
;=====================================================================================
	lda	DEATHTIMER, y
	and	#1
	bne	_no_sprite
	lda	SPRITE, y
	tax

	lda	ObjX, y			; get sprite X
	xba				;
	lda	ObjXF, y		;
	rep	#20h			;
	lsr				;
	lsr				;
	lsr				;
	lsr				;	
	sec				;
	sbc	#SpriteOffsetX		;
	sbc	CameraPX		;
;--------------------------------------------------------------------------
	bpl	:+			; catch offscreen
	cmp	#-32			;
	bcs	:++			;
	bra	_no_sprite		;
:	cmp	#256			;
	bcs	_no_sprite		;
:					;
;--------------------------------------------------------------------------
	
	clc
	adc	#8
	sta	m0
	sec
	sbc	#8
	sep	#20h
	sta	SobjXL, x
	xba
	and	#1
	sta	SobjXH, x
	lda	#1
	sta	SobjSize, x
;-------------------------------------------------------------------------------------
	lda	ObjY, y			; get sprite X
	xba				;
	lda	ObjYF, y		;
	rep	#20h			;
	lsr				;
	lsr				;
	lsr				;
	lsr				;	
	sec				;
	sbc	#SpriteOffsetY		;
	sbc	CameraPY		;
;-------------------------------------------------------------------------------------
	bpl	:+			; catch offscreen
	cmp	#-32			;
	bcs	:++			;
	bra	_no_sprite		;
:	cmp	#SCREENHEIGHT		;
	bcs	_no_sprite		;
:					;
;-------------------------------------------------------------------------------------
	sep	#20h
	sta	SobjA1, x
;-------------------------------------------------------------------------------------
	txa
	lda	SpriteCharacterIndexes-3, x
	sta	SobjA2, x
;-------------------------------------------------------------------------------------

	lda	ObjDir, y
	bne	:+
	lda	#%01000000
	bra	:++
:	lda	#0
:
	ora	#%00111011
	sta	SobjA3, x
	
;-------------------------------------------------------------------------------------
	lda	SobjA1, x			; set y index
	clc					;
	adc	#1+31				;
	sta	SobjY, x			;
;-------------------------------------------------------------------------------------
	
	phy
	rep	#10h
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
	
	sep	#30h
	ply
	
;-------------------------------------------------------------------------------------
	
;-------------------------------------------------------------------------------------
	lda	ObjDir, y		; x = Direction * 2 (MAP index)
	asl				;
	tax				;
	lda	ANIMFRAME, y		; a = animframe *512
	rep	#30h			;
	and	#0FFh			;
	xba				;
	asl				;
	adc	SpriteDirMap, x		; add map
	phy
	tyx
	tay				;
	sep	#20h			;
	lda	SPRITE, x
	rep	#21h
	and	#255
	asl
	tax
	
	lda	SpriteLoadAddresses-6, x
	sep	#20h
	tax
	lda	#^gfx_baddieTiles	; schedule transfer of graphic
	jsr	ScheduleSpriteXfer	;
					;
	ply
	sep	#10h
;--------------------------------------------------------------------------------
	
	
	rts

OBJR_Baddie_Explode:
	lda	#STATE_DEAD
	sta	STATE, y
	lda	#ANIM_HARASS
	jsr	SetAnimation
	tyx
	stz	DEATHTIMER, x
	rts

OBJR_Baddie_Stun:
	lda	STATE, y
	cmp	#STATE_DEAD
	beq	:+
	lda	#STATE_STUNNED
	sta	STATE, y
	tyx
	stz	DEATHTIMER, x
:	rts

