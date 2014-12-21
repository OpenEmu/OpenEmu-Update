
.include "snes.inc"
.include "level.inc"
.include "objects.inc"
.include "graphics.inc"
.include "snes_zvars.inc"
.include "collision.inc"
.include "snesmod.inc"
.include "sounds.inc"

;===============================================================================
; imports
;===============================================================================
.import level_solid, level_slide

;===============================================================================
; exports
;===============================================================================
.export OBJR_Box_Init, OBJR_Box_Update, OBJR_Box_Draw
.export OBJR_Box_PushUp, OBJR_Box_PushDown, OBJR_Box_PushLeft, OBJR_Box_PushRight

;===============================================================================
; definitions
;===============================================================================
STATE = ObjC1
PREVX = ObjC2
PREVY = ObjC3
DSOUND = ObjC4

	.code
	.a8
	.i8

;===============================================================================
OBJR_Box_Init:
;===============================================================================
	lda	ObjY, y
	sta	PREVY
	xba
	lda	ObjX, y
	sta	PREVX
	asl
	asl
	rep	#30h
	lsr
	lsr
	tax
	sep	#20h
	lda	#192
	sta	F:level_solid, x
	sep	#10h
	tyx
	stz	STATE, x
	rts
	
.macro slide_pos pw, pf, amount, dir
	
	lda	pf,y
	.if (amount < 0)
	bne	:+
	lda	pw,y
	dea
	sta	pw,y
	lda	pf,y
:
	.endif
	.if (amount < 0)
	sec
	sbc	#-amount
	.endif
	.if (amount > 0)
	clc
	adc	#amount
	.endif
	sta	pf,y
	beq	:+
	jmp	obu_quit
:
	lda	pw,y
	.if (amount > 0)
	ina
	.endif
	sta	pw,y
	
	lda	ObjY, y
	xba
	lda	ObjX, y
	asl
	asl
	rep	#30h
	lsr
	lsr
	.if (dir = 0)
		ina
	.elseif (dir = 1)
		adc	#64
	.elseif (dir = 2)
		dea
	.else
		sbc	#64-1
	.endif
	tax
	sep	#20h
	lda	#0
	sta	F:level_solid, x
	sep	#10h
	tyx
	stz	STATE, x
	
;---------------------------------------------------------------
	lda	PREVX, y		; 'release' previous position
	sta	OTX			;
	lda	PREVY, y		;
	sta	OTY			;
	stz	OTSTEP			;
	jsr	DoStep
;---------------------------------------------------------------
	lda	ObjX, y			; 'press' new position
	sta	OTX			;
	sta	PREVX, y		;
	lda	ObjY, y			;
	sta	OTY			;
	sta	PREVY, y		;
	lda	#1			;
	sta	OTSTEP			;
	jsr	DoStep
;---------------------------------------------------------------
	rts
.endmacro

DoStep:
	phy				;
	rep	#10h			;
	jsr	Objects_Step		;
	sep	#10h			;	
	ply				;
	rts

fslide_left:
	slide_pos ObjX, ObjXF, -16, 0
	
fslide_up:
	slide_pos ObjY, ObjYF, -16, 1	
	
fslide_right:
	slide_pos ObjX, ObjXF, 16, 2
	
fslide_down:

	slide_pos ObjY, ObjYF, 16, 3
	
slide_left:
	jmp	fslide_left
	
slide_up:
	jmp	fslide_up
	
slide_right:
	jmp	fslide_right
	
slide_down:
	jmp	fslide_down
	
	
;===============================================================================
OBJR_Box_Update:
;===============================================================================
	lda	STATE, y
	cmp	#1
	beq	slide_left
	cmp	#2
	beq	slide_up
	cmp	#3
	beq	slide_right
	bcs	slide_down
	
	;uhh, test for slidey ground
	lda	ObjY, y
	xba
	lda	ObjX, y
	asl
	asl
	rep	#30h
	lsr
	lsr
	tax
	sep	#20h
	lda	F:level_slide, x
	sep	#10h
	beq	obu_quit
	cmp	#5
	bcs	obu_quit
	
	cmp	#1
	beq	@cs_left
	cmp	#2
	beq	@cs_up
	cmp	#3
	beq	@cs_right
@cs_down:
	lda	#1
	sta DSOUND, y
	jsr	OBJR_Box_PushDown
	lda	#0
	sta DSOUND, y
	rts
@cs_left:
	lda	#1
	sta DSOUND, y
	jsr	OBJR_Box_PushLeft
	lda	#0
	sta DSOUND, y
	rts
@cs_up:
	lda	#1
	sta DSOUND, y
	jsr	OBJR_Box_PushUp
	lda	#0
	sta DSOUND, y
	rts
@cs_right:
	lda	#1
	sta DSOUND, y
	jsr	OBJR_Box_PushRight
	lda	#0
	sta DSOUND, y
	
obu_quit:
	rts

	
	
	
;===============================================================================
OBJR_Box_Draw:
;===============================================================================		
	mac_Objects_AddSpriteB16 (%00110000 | (DONGLESPAL<<1)), DONGLE_BOX
	rts 
	
.macro DoPushing direction
	.local @quit
	lda	STATE, y
	bne	@quit
	phy
	lda	ObjY, y
	.if (direction = 1)
		dea
	.endif
	.if (direction = 3)
		ina
	.endif
	sta	m0+1
	lda	ObjX, y
	.if (direction = 0)
		dea
	.endif
	.if (direction = 2)
		ina
	.endif
	sta	m0
	rep	#10h
	jsr	TestForEntitiesT
	sep	#10h
	ply
	bcs	@quit
	
	lda	DSOUND, y
	bne	:+
	phy
	rep	#10h
	spcPlaySoundM SND_PUSH
	sep	#10h
	ply
:
	
	lda	ObjY, y
	xba
	lda	ObjX, y
	asl
	asl
	rep	#30h
	lsr
	lsr
	.if (direction = 0)
		dea
	.elseif (direction = 1)
		sbc	#64-1
	.elseif (direction = 2)
		ina
	.elseif (direction = 3)
		adc	#64
	.endif
	tax
	sep	#20h
	lda	#192
	sta	F:level_solid, x
	sep	#10h
	
	lda	#direction+1
	sta	STATE, y
@quit:	rts
.endmacro

;===============================================================================
OBJR_Box_PushUp:
;===============================================================================
	DoPushing 1

;===============================================================================
OBJR_Box_PushDown:
;===============================================================================
	DoPushing 3

;===============================================================================
OBJR_Box_PushLeft:
;===============================================================================
	DoPushing 0

;===============================================================================
OBJR_Box_PushRight:
;===============================================================================
	DoPushing 2
