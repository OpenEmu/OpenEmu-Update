
; arnold PETER

.include "graphics.inc"
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_zvars.inc"
.include "sprites.inc"
.include "ingame.inc"
.include "players.inc"
.include "objects.inc"

.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"

.import DamagePlayer

	.export Arnold_Disable
	.export Arnold_Activate
	.export Arnold_Update
	.export Arnold_Draw
	
SPRITE_ENTRY = 128
	
	.zeropage

ZX:	.res 2
ZY:	.res 2
ACTIVE:	.res 1
MOUTHOFF: .res 2
TARGETX: .res 2
TARGETY: .res 2
MSPEED: .res 2
TIMER: .res 2
PATROL: .res 1

STATE: .res 1

LIFE: .res 1
INV: .res 1

MOUTH_T: .res 1
MOUTH_D: .res 1

	.bss
	
	 NBALLS = 20
	 BALL_LIMIT = 8000
	
	
ball_x:	.res 2*NBALLS
ball_y:	.res 2*NBALLS
ball_vx: .res 2*NBALLS
ball_vy: .RES 2*NBALLS

ball_next:	.res 1

RINDEX:	.res 1

DAMAGE_RANGE = 32

STATE_WAIT	 = 0
STATE_TURBOTIME	= 1
STATE_DULL	=2
STATE_PATROL	=3
STATE_CRAZY=4
STATE_ATTACK=5
STATE_DYING=6


.importzp CameraScroll


FIELDW = (18*16)
FIELDH = (18*16)
	
	.code
	.a8
	.i16
	
PATROL_TARGETS:
	.word (FIELDW/3-32)*16, (FIELDH/4-40)*16
	.word (FIELDW*2/3-32)*16, (FIELDH/4-40)*16
	.word (FIELDW/2-32)*16, (FIELDH/2-40)*16	
MOUTH_DATA:
	.byte 4,3,2,4,5,2,1,0
	.byte 5,3,5,3,4,5,1,3
	.byte 2,5,2,0,3,5,2,2
	.byte 1,5,3,3,0,4,1,3,4
	
SHAKE_DATA:
	.byte 0, 6, 12, 6, 0, -6, -12, -6
	
RDATA:
	.byte 80, 136, 148, 74, 77, 198, 4, 194, 208, 181, 12, 106, 220
	.byte 202, 95, 245, 222, 14, 242, 93, 134, 196, 14, 151, 120, 76 
	.byte 159, 165, 67, 71, 212, 210, 150, 251, 232, 58, 177, 250, 62 
	.byte 136, 27, 255, 172, 4, 147, 26, 26, 204, 73, 12, 75, 97, 77, 242 
	.byte 250, 102, 71, 41, 42, 165, 105, 105, 182, 83, 161, 53, 47, 149 
	.byte 21, 117, 231, 67, 200, 97, 74, 234, 161, 160, 109, 25, 143, 177 
	.byte 233, 213, 6, 139, 234, 110, 173, 128, 131, 118, 90, 103, 69, 14, 62 
	.byte 250, 16, 100, 93, 125, 40, 121, 66, 160, 138, 40, 239, 167, 129, 100
	.byte 27, 200, 117, 192, 152, 212, 5, 54, 19, 27, 85, 33, 0, 137, 168, 139 
	.byte 211, 21, 49, 173, 116, 91, 38, 180, 237, 135, 23, 193, 102, 118, 126 
	.byte 53, 84, 24, 150, 43, 237, 25, 113, 70, 222, 191, 70, 172, 65, 23, 8, 82
	.byte 201, 76, 60, 123, 65, 87, 11, 123, 53, 220, 150, 193, 237, 84, 138, 21 
	.byte 162, 105, 245, 29, 235, 158, 89, 38, 122, 56, 253, 33, 7, 88, 140, 235 
	.byte 137, 104, 216, 211, 171, 184, 254, 87, 126, 105, 177, 46, 108, 139, 208
	.byte 138, 109, 130, 58, 158, 125, 174, 226, 94, 77, 75, 38, 135, 57, 149, 93
	.byte 223, 122, 49, 174, 191, 157, 199, 41, 206, 52, 244, 17, 16, 202, 97, 118 
	.byte 30, 29, 44, 12, 182, 136, 143, 55, 119, 190, 192, 102, 230, 190, 23, 162 
	.byte 182
	
RANDO8:
	ldy	RINDEX
	iny
	sep	#10h
	rep	#10h
	sty	RINDEX
	lda	RDATA,y
	rts
	
;============================================================================
Arnold_Disable:
;============================================================================
	stz	ACTIVE
	rts
	
ResetBalls:
	
.repeat NBALLS, i
	ldx	#32000
	stx	ball_y + i*2
.endrep	

	stz	ball_next
	rts

;============================================================================
Arnold_Activate:
;============================================================================

	ldx	#127
	jsr	spcSetModuleVolume
	ldx	#MOD_SHITBOX
	jsr	spcLoad
	jsr	spcStop
	jsr	spcFlush
	
	jsr	ResetBalls
	
	DoDecompressDataVram gfx_arnold1Tiles, 0F000h
	DoCopyPalette gfx_arnold1Pal, 224, 16
	
	
	ldx	#((FIELDW/2) - 32)*16
	stx	TARGETX
	stx	ZX
	ldx	#((FIELDH/2) - 40)*16
	stx	TARGETY
	
	ldx	#0
	stx	ZY
	
	lda	#1
	sta	ACTIVE
	
	ldx	#0
	stx	MOUTHOFF
	
	lda	#2
	sta	PL_HP+1
	sta	PL_HP+2
	sta	PL_Exited+1
	sta	PL_Exited+2
	
	stz	STATE

	lda	#7
	sta	LIFE
	
	rts
	
startpatrol:
	stz	PATROL
	rep	#20h
	lda	PATROL_TARGETS+0
	sta	TARGETX
	lda	PATROL_TARGETS+2
	sta	TARGETY
	stz	TIMER
	sep	#20h
	rts
	
nextpatrol:
	lda	PATROL
	ina
	cmp	#3
	bne	:+
	lda	#0
:	sta	PATROL
	asl
	asl
	tay
	sep	#10h
	rep	#30h
	lda	PATROL_TARGETS, y
	sta	TARGETX
	lda	PATROL_TARGETS+2, y
	sta	TARGETY
	sep	#20h
	rts
	
TestForPlayer:

	sep	#20h
	lda	PL_XH
	xba
	lda	PL_XL
	rep	#20h
	sec
	sbc	ZX
	sbc	#32*16
	bpl	:+
	eor	#0FFFFh
	ina
:	sta	m0
	sep	#20h
	lda	PL_YH
	xba
	lda	PL_YL
	rep	#20h
	sec
	sbc	ZY
	sbc	#40*16
	bpl	:+
	eor	#0FFFFh
	ina
:	clc
	adc	m0
	cmp	#DAMAGE_RANGE*16

	sep	#20h
	bcs	:+

	ldx	#0
	jsr	DamagePlayer
	
:	rts
	
	
;============================================================================
DoTargetting:
;============================================================================
	rep	#20h
	
	lda	ZX
	cmp	TARGETX
	beq	@x_target
	bcs	@x_higher
	adc	MSPEED
	cmp	TARGETX
	bcc	@x_target
	lda	TARGETX
	bra	@x_target
@x_higher:
	sbc	MSPEED
	cmp	TARGETX
	bcs	@x_target
	lda	TARGETX
@x_target:
	sta	ZX
;-----------------------------------	
	lda	ZY
	cmp	TARGETY
	beq	@y_target
	bcs	@y_higher
	adc	MSPEED
	cmp	TARGETY
	bcc	@y_target
	lda	TARGETY
	bra	@y_target
@y_higher:
	sbc	MSPEED
	cmp	TARGETY
	bcs	@y_target
	lda	TARGETY
@y_target:
	sta	ZY
	
	
	lda	TARGETX
	cmp	ZX
	bne	:+
	lda	TARGETY
	cmp	ZY
	bne	:+
	sep	#20h
	lda	#1
	rts
:	sep	#20h
	lda	#0
	rts

Arnold_Update:
	lda	ACTIVE
	bne	:+
	rts
:

	lda	INV
	beq	:+
	dec	INV
:
	jsr	Balls_Update
	lda	STATE
	asl
	tax
	sep	#10h
	rep	#10h
	jmp	(_state_funcs, x)
	rts
	
_state_funcs:
	.word	_state_wait
	.word	_state_turbotime
	.word	_state_dull
	.word	_state_patrol
	.word	_state_crazy
	.word	_state_attack
	.word	_state_dying
	
_state_dull:
	rts
	
_state_wait:
	ldx	#16
	stx	MSPEED

	jsr	DoTargetting
	
	lda	#1
	sta	CameraScroll
	
	lda	PL_YH
	cmp	#(FIELDH*3/4)/16
	bcs	:+
	
	lda	#STATE_TURBOTIME
	sta	STATE
	stz	TIMER
	
	stz	MOUTH_T
	stz	MOUTH_D
:	

	jsr	TestForPlayer
	rts
	
_state_turbotime:

	lda	TIMER
	bne	:+
	
	spcPlaySoundM SND_WEDGE

	
:	

	lda	TIMER
	cmp	#80
	bcc	:+
	stz	MOUTHOFF
	bra	:++
:
	lda	MOUTH_T
	dea
	sta	MOUTH_T
	bpl	:+
	lda	MOUTH_D
	ina
	and	#31
	sta	MOUTH_D
	tay
	sep	#10h
	rep	#10h
	lda	MOUTH_DATA, y
	sta	MOUTHOFF
	iny
	asl
	sta	MOUTH_T
:


	inc	TIMER
	lda	TIMER
	cmp	#110
	bne	:+
	
	
	
	lda	#STATE_PATROL
	sta	STATE
	jsr	startpatrol
	
	ldx	#0
	jsr	spcPlay
	
	stz	MOUTHOFF
	
:	
	jsr	TestForPlayer
		
			rts

_state_patrol:
	
	jsr	DoTargetting
	cmp	#0
	beq	:+
	jsr	nextpatrol
	
:
	rep	#20h
	inc	TIMER
	lda	TIMER
	cmp	#300
	bcc	:+
	
	sep	#20h
	lda	#STATE_CRAZY
	sta	STATE
	stz	TIMER
	stz	TIMER+1
:	sep	#20h

	rep	#20h
	lda	MOUTHOFF
	beq	:++
	cmp	#8000h
	ror
	bpl	:+
	ina
:
	sta	MOUTHOFF
:
	
	
	sep	#20h
	
	jsr	TestForPlayer
	
	rts
	
_state_crazy:
	rep	#20h
	inc	TIMER
	lda	TIMER
	lsr
	lsr
	lsr
	eor	#0FFFFh
	ina
	sta	MOUTHOFF
	
	
	lda	TIMER
	and	#15
	bne	:+
	
	SEP	#20H
	spcPlaySoundM SND_LOCO
	REP	#20H
:
	
	lda	TIMER
	and	#7
	tay
	sep	#20h
	lda	SHAKE_DATA, y
	rep	#21h
	and	#255
	cmp	#128
	bcc	:+
	ora	#0FF00h
:
	adc	ZX
	sta	ZX
	
	
	lda	TIMER
	cmp	#200
	bcc	:+
	sep	#20h
	
	lda	#STATE_ATTACK
	sta	STATE
	stz	TIMER
	stz	TIMER+1
	
	spcPlaySoundM SND_REGURG
	
:	sep	#20h
	
	jsr	TestForPlayer
	
	rts
	
_state_attack:
	rep	#20h
	inc	TIMER
	
	lda	TIMER
	and	#7
	tay
	sep	#20h
	lda	SHAKE_DATA, y
	rep	#21h
	and	#255
	cmp	#128
	bcc	:+
	ora	#0FF00h
:
	asl
	asl
	adc	ZX
	sta	ZX
	
	rep	#20h
	lda	MOUTHOFF
	bmi	@openmouth
	cmp	#18
	bcs	@n_openmouth
@openmouth:
	adc	#4
	bmi	:+
	cmp	#18
	bcc	:+
	lda	#18
:	sta	MOUTHOFF
@n_openmouth:

	LDA	TIMER
	and	#1
	bne	:+
	
	sep	#20h
	jsr	Balls_Spawn
:
	
	rep	#20h
	lda	TIMER
	cmp	#100
	bcc	:+
	stz	TIMER
	sep	#20h
	lda	#STATE_PATROL
	sta	STATE
:

	sep	#20h
	
	jsr	TestForPlayer
	
	rts

_state_dying:
	
	rep	#20h
	inc	TIMER
	
	lda	TIMER
	and	#7
	tay
	sep	#20h
	lda	SHAKE_DATA, y
	rep	#21h
	and	#255
	cmp	#128
	bcc	:+
	ora	#0FF00h
:
	asl
	asl
	adc	ZX
	sta	ZX
	
	rep	#20h
	lda	MOUTHOFF
	bmi	@openmouth
	cmp	#18
	bcs	@n_openmouth
@openmouth:
	adc	#4
	bmi	:+
	cmp	#18
	bcc	:+
	lda	#18
:	sta	MOUTHOFF
@n_openmouth:

	
	
	rep	#20h
	lda	TIMER
	cmp	#100
	bcc	:+
	
	inc	INV
	inc	INV
	
	cmp	#100
	bne	:+
	sep	#20h
	spcPlaySoundM SND_WEDGE
:
	
	rep	#20h
	lda	TIMER
	cmp	#190
	bcc	:+
	stz	TIMER
	sep	#20h
	stz	ACTIVE



	jsr	Objects_Allocate
	lda	#10 ;OBJ_MAPEXIT
	sta	ObjType, x
	
	lda	ZX+1
	ina
	ina
	sta	ObjX, x
	lda	ZY+1
	ina
	ina
	ina
	sta	ObjY, x
	
	spcPlaySoundM SND_MENU2
	
:
	
	rts

	
;================================================================================
Arnold_Draw:
;================================================================================
	lda	ACTIVE
	bne	:+
	rts
:	
	
	ldx	m4
	phx
	ldx	m5
	phx
	
	lda	INV
	and	#1
	beq	:+
	jmp	@skip_drawing
:
	
	rep	#20h
	
	
	lda	ZX
	lsr
	lsr
	lsr
	lsr
	sec
	sbc	CameraPX
	sta	m4
	
	lda	ZY
	lsr
	lsr
	lsr
	lsr
	sec
	sbc	CameraPY
	sta	m5
	
	
.macro DoAddSprite32 xo, yo, index
	.local @offscreen

	lda	#xo
	clc
	adc	m4
	bpl	:+
	cmp	#-33
	bcs	:++
	jmp	@offscreen
:	cmp	#256
	bcs	@offscreen
:	tay

	lda	#yo
	clc
	adc	m5
	bpl	:+
	cmp	#-33
	bcs	:++
	jmp	@offscreen
:	cmp	#SCREENHEIGHT
	bcs	@offscreen
:	sep	#20h
		
	AddSprite32bc SPRITE_ENTRY+index, %00101101
	rep	#20h
@offscreen:

.endmacro

	DoAddSprite32 0, 0, 0
	DoAddSprite32 32, 0, 4
	DoAddSprite32 0, 32, 8
	DoAddSprite32 32, 32, 12
	DoAddSprite32 0, 64, 64
	DoAddSprite32 32, 64, 68
	
	
	
	lda	#16
	clc
	adc	m4
	bpl	:+
	cmp	#-33
	bcs	:++
	jmp	@offscreen
:	cmp	#256
	bcs	@offscreen
:	tay

	lda	#56
	clc
	adc	m5
	clc
	adc	MOUTHOFF
	bpl	:+
	cmp	#-33
	bcs	:++
	jmp	@offscreen
:	cmp	#SCREENHEIGHT
	bcs	@offscreen
:	sep	#20h
	
	AddSprite32bc SPRITE_ENTRY+72, %00101101
	rep	#20h
@offscreen:

	sep	#20h
	
	lda	STATE
	cmp	#STATE_CRAZY
	bcs	:+
	jmp	@skip_crazyness
:
	
	rep	#21h
	lda	m4
	adc	#12
	tay
	lda	m5
	adc	#30
	sep	#20h
	AddSprite16bc SPRITE_ENTRY+76, %00101101
	
	
	rep	#21h
	lda	TIMER
	cmp	#60
	bcs	:+
	lda	m4
	adc	#32
	tay
	lda	m5
	adc	#29
	sep	#20h
	AddSprite16bc SPRITE_ENTRY+76, %00101101
	bra	@skip_crazyness
	rep	#20h
:
	lda	m4
	adc	#32
	tay
	lda	m5
	adc	#29
	sep	#20h
	AddSprite16bc SPRITE_ENTRY+76, %10101101
	
	
	
@skip_crazyness:
	sep	#20h
	
@skip_drawing:	

	jsr	Balls_Draw
	
	
	
	
	plx
	stx	m5
	plx
	stx	m4
	
	rts

Balls_Spawn:
	lda	ball_next
	INA
	CMP	#NBALLS
	bcc	:+
	lda	#0
:	sta	ball_next

	rep	#20h
	and	#255
	asl
	tax
	
	sep	#20h
	jsr	RANDO8
	rep	#20h
	and	#255
	sbc	#128
	adc	ZX
	adc	#32*16
	sta	ball_x, x
	
	lda	ZY
	adc	#40*16
	sta	ball_y, x
	
	sep	#20h
	jsr	RANDO8
	lsr
	lsr
	rep	#20h
	and	#255
	sbc	#32
	bpl	:+
	adc	#5
	bra	:++
:	sbc	#5
:	
	
	sta	ball_vx, x
	
	sep	#20h
	jsr	RANDO8
	lsr
	lsr
	rep	#20h
	and	#255
	sbc	#32
;	adc	#25
	bpl	:+
	adc	#5
	bra	:++
:	sbc	#5
:	

	sta	ball_vy, x
	
	sep	#20h
	rts
	
Balls_Update:
	ldx	#0
	rep	#20h
@loop:
	lda	ball_y, x
	cmp	#BALL_LIMIT
	bcs	@next

	clc
	adc	ball_vy, x
	sta	ball_y,x
	lda	ball_x,x
	adc	ball_vx, x
	sta	ball_x,x
	bpl	:+
	cmp	#-8*16
	bcs	@onscreen
	lda	#BALL_LIMIT
	sta	ball_y, x
	bra	@next
:	cmp	#256*16
	bcc	@onscreen
	lda	#BALL_LIMIT
	sta	ball_y, x
@onscreen:

	; test for player
	sep	#20h
	lda	ball_x+1, x
	cmp	PL_XH
	bne	@miss
	lda	ball_y+1, x
	cmp	PL_YH
	bne	@miss
	
	
	phx
	ldx	#0
	jsr	DamagePlayer
	plx
@miss:
	rep	#20h
@next:
	inx
	inx
	cpx	#NBALLS*2
	bne	@loop
	sep	#20h
	rts
		
Balls_Draw:
	
	ldx	#0
	
@loop:
	rep	#20h
	lda	ball_y,x
	cmp	#BALL_LIMIT
	bcs	@next
	lda	ball_x,x
	lsr
	lsr
	lsr
	lsr
	sbc	CameraPX
	sbc	#4
	tay
	lda	ball_y,x
	lsr
	lsr
	lsr
	lsr
	sbc	CameraPY
	sbc	#8
	cmp	#SCREENHEIGHT
	bcs	@next
	sep	#20h
	phx
	AddSprite16bc SPRITE_ENTRY+76, %10101101
	plx
@next:
	inx
	inx
	cpx	#NBALLS*2
	bne	@loop
	
	sep	#20h
	rts

	.export Arnold_ApplyExplosion
Arnold_ApplyExplosion:
	pha
	lda	ACTIVE
	bne	:+
	pla
	rts
:	lda	INV
	beq	:+
	pla
	rts
:
	pla
	sta	m0
	;xba
	rep	#20h
	and	#0FF00h
	ora	#80h
	cmp	ZY
	bcc	@miss
	sbc	#80*16
	cmp	ZY
	bcs	@miss
	sep	#20h
	lda	m0
	rep	#20h
	xba
	and	#0FF00h
	ora	#80h
	cmp	ZX
	bcc	@miss
	sbc	#64*16
	cmp	ZX
	bcs	@miss

	

	sep	#20h
	
	spcPlaySoundM SND_WEDGE
	lda	#60
	sta	INV

	dec	LIFE
	lda	LIFE
	bne	@miss

	jsr	spcStop
	jsr	spcFlush
	
	lda	#STATE_DYING
	sta	STATE
	stz	TIMER
	stz	TIMER+1

@miss:
	sep	#20h
	rts

	