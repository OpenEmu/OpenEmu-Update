
.include "snes.inc"
.include "snes_zvars.inc"
.include "objects.inc"
.include "players.inc"

;=====================================================================================
; IMPORTS
;=====================================================================================
.import BG3_Data
.import level_solid
.import level_lasers
.importzp Timer
.importzp CameraTileX
.importzp CameraTileY

;=====================================================================================
; EXPORTS
;=====================================================================================
.export OBJR_Laser_Init, OBJR_Laser_Update, OBJR_Laser_Draw, OBJR_Laser_Button

TILE_LASER_HORZ = 2 
TILE_LASER_VERT = 8


STATE	= ObjC1 ; wait/active
STRIDE	= ObjC2 ; length of laser
PHASE	= ObjC3 ; time of laser
TMASK	= ObjA1 ; timer mask
TOFS	= ObjA2 ; timer offset
ONCE	= ObjA3
TILE	= ObjC4
;DIRTY	= ObjC4

STATE_WAIT = 0
STATE_ACTIVE = 1

	.code
	.a8
	.i8

;=====================================================================================
OBJR_Laser_Init:
;=====================================================================================
	tyx
	stz	STATE, x
	rts
	
GetMapPos:
	ldx	ObjX, y
	lda	ObjY, y
	rep	#20h
	and	#255
	xba
	lsr
	lsr
	stz	m0
	stx	m0
	adc	m0
	rts
	
	.a8
	
.macro StartBeam addition
.scope
	stz	m1
	jsr	GetMapPos 

	.a16
	rep	#10h
	clc
@calcstride:
	adc	#addition
	tax
	sep	#20h
	lda	F:level_solid, x
	bmi	@end_of_stride
	lda	F:level_lasers, x
	bmi	@end_of_stride
	lda	#128
	sta	F:level_lasers, x
	inc	m1
	rep	#21h
	txa
	bra	@calcstride
	.a8
@end_of_stride:
	sep	#10h
	lda	m1
	sta	STRIDE, y
.endscope
.endmacro

.macro mStopBeam addition
	.local @skip, @stopbeam
	jsr	GetMapPos
	.a16
	ldy	m1
	beq	@skip
	rep	#10h
	clc
@stopbeam:
:	adc	#addition
	tax
	sep	#20h
	lda	#0
	sta	F:level_lasers, x
	rep	#20h
	txa
	clc
	dey
	bne	:-
@skip:
	sep	#30h
.endmacro

	.a8
	.i8

StopBeam:
	phy
	lda	STRIDE, y
	sta	m1
	lda	ObjDir, y
	cmp	#1
	beq	sb_up
	cmp	#2
	beq	sb_right
	bcs	sb_down
sb_left:
	mStopBeam -1
	bra	sb_finished
sb_up:
	mStopBeam -64
	bra	sb_finished
sb_right:
	mStopBeam 1
	bra	sb_finished
sb_down:
	mStopBeam 64
	bra	sb_finished
sb_finished:
	ply
	rts
	
	
;=====================================================================================
OBJR_Laser_Update:
;=====================================================================================

	lda	STATE, y
	beq	lu_waiting
@active:

	lda	PHASE, y
	ina
	sta	PHASE, y
	cmp	#3
	beq	@p1
	cmp	#7
	beq	@p2
	cmp	#11
	beq	@p3
	cmp	#16
	bne	:+
	jsr	StopBeam
	tyx
	stz	STATE, x
	
	lda	ONCE, x
	beq	:+
	stz	ObjType, x ;delete object if 'once' flag is set
:	jmp	exit
	
@p1:
	lda	#TILE_LASER_HORZ
	sta	TILE, y
	
	jsr	AttackPlayers
	
	rts
@p2:
	lda	#TILE_LASER_HORZ+2
	sta	TILE, y
	jsr	AttackPlayers
	rts
@p3:
	lda	#TILE_LASER_HORZ+4
	sta	TILE, y
	jsr	AttackPlayers
	rts

beam_right:
	StartBeam 1
	jmp	beam_started
	
lu_waiting:
	lda	ObjA4, y
	beq	@inactive
	rep	#20h
	lda	Timer
	lsr
	lsr
	lsr
	sep	#20h
	and	TMASK, y
	cmp	TOFS, y
	beq	@start_beam
@inactive:
	rts
@start_beam:
	lda	ObjDir, y
	cmp	#1
	beq	beam_up
	cmp	#2
	beq	beam_right
	bcs	beam_down
beam_left:
	StartBeam -1
	bra	beam_started
beam_up:
	StartBeam -64
	bra	beam_started

beam_down:
	StartBeam 64
	
beam_started:
	lda	#1
	tyx
	sta	STATE, x
	stz	PHASE, x
	lda	#TILE_LASER_HORZ+4
	sta	TILE, x
exit:
	rts
	
;=====================================================================================
OBJR_Laser_Draw:
;=====================================================================================

	lda	STATE, y
	beq	@quit

	lda	ObjDir, y
	cmp	#1
	beq	@up
	cmp	#2
	beq	@right
	bcs	@down
	jsr	DrawLaserLeft
	rts
@up:
	jsr	DrawLaserUp
	rts
@right:
	jsr	DrawLaserRight
	rts
@down:
	jsr	DrawLaserDown
	
@quit:
	rts
	
;=====================================================================================
.macro m0_y64 qu
;=====================================================================================
	lda	ObjY, y				; get Y value
	sec					;
	sbc	CameraTileY			;
	bmi	qu				; catch off-screen
	cmp	#12				; 
	bcs	qu				;
;-------------------------------------------------------------------------------------
	rep	#20h				; m0 = y << 6
	and	#255				;
	xba					;
	lsr					;
	lsr					;
	sta	m0				;
	sep	#20h				;
;-------------------------------------------------------------------------------------
.endmacro

;-------------------------------------------------------------------------------------
.macro test_stride_load_m1 qu
	lda	STRIDE, y			; m1 = stride
	beq	qu				; catch zero-stride
	sta	m1				;
.endmacro

;=====================================================================================
.macro ClipRenderLeftTop
;=====================================================================================
	pha					; clip against boundary
	sec					;
	sbc	m1				;
	bpl	:+				;
	pla					;
	ina					;
	sta	m1				;
	dea					;
	bra	:++				;
:	pla					;
:						;
.endmacro					;
;-------------------------------------------------------------------------------------

;=====================================================================================
.macro ClipRenderRightBottom bound
;=====================================================================================
	pha					; clip against boundary
	clc					;
	adc	m1				;
	cmp	#bound				;
	bcc	:+				;
	;beq	:+
	pla					;
	pha
	sbc	#bound
	eor	#0FFFFh
	ina
	sta	m1				;
:	pla					;
						;
.endmacro					;
;-------------------------------------------------------------------------------------


;=====================================================================================
DrawLaserLeft:
;=====================================================================================
	phy					;
	test_stride_load_m1 @quit		; m1 = stride
;-------------------------------------------------------------------------------------
	m0_y64	@quit				; m0 = y * 64
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; a=x-1
	sec					;
	sbc	CameraTileX			;
	dea					;
	bmi	@quit				; catch off-screen
;-------------------------------------------------------------------------------------
	cmp	#17
	bcc	:+
	sbc	#17
	sta	m1+1
	lda	m1
	sec
	sbc	m1+1
	dea
	bmi	@quit
	beq	@quit
	sta	m1
	lda	#16
:	stz	m1+1
	rep	#31h
	and	#255
	
	ClipRenderLeftTop
	
	asl
	adc	m0
	tax
	sep	#20h
	lda	TILE, y
	
	
	ldy	m1
	beq	@quit
;-------------------------------------------------------------------------------------	
:	sta	BG3_Data, x			; draw to map
	dex					;	
	dex					;
	dey					;
	bne	:-				;
;-------------------------------------------------------------------------------------
	sep	#30h
@quit:
	ply
	rts

;=====================================================================================
DrawLaserRight:
;=====================================================================================
	phy
	test_stride_load_m1 @quit		; m1 = stride
;-------------------------------------------------------------------------------------
	m0_y64	@quit
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; a = x + 1
	sec					;
	sbc	CameraTileX			;
	ina					;
	bmi	@negative_x
	cmp	#17				; quit if >= 17 (out of right side)
	bcs	@quit				;
;-------------------------------------------------------------------------------------
	bra	@positive_x
@negative_x:					; if x is negative
	clc					; stride += x
	adc	m1				;
	bmi	@quit				; exit if stride <= 0
	beq	@quit				;
	sta	m1				;
	lda	#0				; x = 0
;-------------------------------------------------------------------------------------
@positive_x:
	stz	m1+1				;
	rep	#31h				; x = x*2 + y*64
	and	#255				;
;-------------------------------------------------------------------------------------	
	ClipRenderRightBottom 17
;-------------------------------------------------------------------------------------	
	asl					;
	clc					;
	adc	m0				;
	tax					;
;-------------------------------------------------------------------------------------	
	sep	#20h
	lda	TILE, y				; a = tile, y = stride
	ldy	m1				;
	beq	@quit
;-------------------------------------------------------------------------------------
:	sta	BG3_Data, x			; draw to map
	inx					;
	inx					;
	dey					;	
	bne	:-				;
;-------------------------------------------------------------------------------------
	sep	#30h
;-------------------------------------------------------------------------------------
@quit:
;-------------------------------------------------------------------------------------
	ply
	rts
	
;=====================================================================================
.macro test_load_x_m0 qu
;=====================================================================================
	lda	ObjX, y				; m0 = x*2
	sec					;
	sbc	CameraTileX			; quit if out of range
	bmi	qu				;
	cmp	#17				;
	bcs	qu				;
	asl					;	
	sta	m0				;
	stz	m0+1				;
.endmacro					;
;-------------------------------------------------------------------------------------

;=====================================================================================
DrawLaserUp:
;=====================================================================================
	phy
	test_stride_load_m1 @quit		; m1 = stride
;-------------------------------------------------------------------------------------
	test_load_x_m0 @quit
;-------------------------------------------------------------------------------------
	lda	ObjY, y				; a = Y - 1
	sec					;
	sbc	CameraTileY			;
	dea					;
	bmi	@quit				; quit if negative
;-------------------------------------------------------------------------------------
	cmp	#12				; clip to bottom edge
	bcc	@onscreen			;
	sbc	#12				;
	sta	m1+1				;
	lda	m1				;
	sbc	m1+1				;
	dea
	bmi	@quit				;
	beq	@quit				;
	sta	m1				;
	lda	#11				;
;-------------------------------------------------------------------------------------
@onscreen:					; x = y*64 + x*2
	stz	m1+1				;
	rep	#31h				;
	and	#255				;
	
;-------------------------------------------------------------------------------------
	ClipRenderLeftTop
;-------------------------------------------------------------------------------------
	
	xba					;
	lsr					;
	lsr					;
	adc	m0				;
	tax					;
;-------------------------------------------------------------------------------------
	lda	TILE, y				; a = TILE +6 (vertical)
	and	#255				;
	adc	#6				;
	sta	m0
	ldy	m1				; y = stride
	beq	@quit
	sec
;-------------------------------------------------------------------------------------
:	sta	BG3_Data, x			; draw to map
	txa
	sbc	#64
	tax
	lda	m0
	dey					;	
	bne	:-				;
	
@quit:
	sep	#30h
	ply
	rts
;=====================================================================================
DrawLaserDown:
;=====================================================================================
	phy
	test_stride_load_m1 @quit
;-------------------------------------------------------------------------------------
	test_load_x_m0 @quit
;-------------------------------------------------------------------------------------
	lda	ObjY, y				; a = Y + 1
	sec					;
	sbc	CameraTileY			;
	ina					;
	bmi	@negative_y			;-----------------> if negative
	cmp	#12				; quit if >= 12
	bcs	@quit				;
;-------------------------------------------------------------------------------------
	bra	@positive_y			; clip to top edge
@negative_y:					;
	clc					;
	adc	m1				;
	bmi	@quit				;
	beq	@quit				;
	sta	m1				;
	lda	#0				;
;-------------------------------------------------------------------------------------
@positive_y:					; x = y*64 + x*2
	stz	m1+1
	rep	#31h				;
	and	#255				;
	
;-------------------------------------------------------------------------------------
	ClipRenderRightBottom 12
;-------------------------------------------------------------------------------------

	xba					;
	lsr					;
	lsr					;
	adc	m0				;	
	tax					;
;-------------------------------------------------------------------------------------
	lda	TILE, y				; m0/a = bg entry
	and	#255				;
	adc	#6				;
	sta	m0				;
	ldy	m1				; y = stride
	beq	@quit
	clc					;
;-------------------------------------------------------------------------------------
:	sta	BG3_Data, x			; draw to map
	txa					;
	adc	#2*32				;
	tax					;
	lda	m0				;
	dey					;
	bne	:-				;
;-------------------------------------------------------------------------------------
@quit:						; restore psr, pop y	
	sep	#30h				;
	ply					;
;-------------------------------------------------------------------------------------
	rts
	
;*************************************************************************************

.macro CallAPfunctions
	phy					;
	rep	#10h				;
	jsr	Players_ApplyLaser		;
	jsr	Objects_Laser		;
	sep	#10h				;
	ply					;
.endmacro

;=====================================================================================
AttackPlayers:
;=====================================================================================
	lda	STRIDE, y			; exit if stride = 0
	bne	:+				;
	rts					;
;-------------------------------------------------------------------------------------
:	lda	ObjDir, y			; branch according to dir 
	cmp	#1				;		
	beq	@up				;
	cmp	#2				;
	beq	@right				;
	bcs	@down				;
;-------------------------------------------------------------------------------------
@left:
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; apply laser (x-stride,x,y,y+1)
	sta	m0+1				;
	sec					;
	sbc	STRIDE, y			;
	sta	m0				;
	lda	ObjY, y				;
	sta	m1				;
	ina					;
	sta	m1+1				;
	CallAPfunctions
	bra	@quit				;
;-------------------------------------------------------------------------------------
@up:
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; apply laser (x,x+1,y-stride,y)
	sta	m0				;
	ina					;
	sta	m0+1				;
	lda	ObjY, y				;
	sta	m1+1				;
	sec					;
	sbc	STRIDE, y			;
	sta	m1				;
	CallAPfunctions
	bra	@quit				;
;-------------------------------------------------------------------------------------
@right:
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; apply laser (x+1,x+1+stride,y,y+1)
	ina					;
	sta	m0				;
	clc					;
	adc	STRIDE, y			;
	sta	m0+1				;
	lda	ObjY, y				;
	sta	m1				;
	ina					;
	sta	m1+1				;
	CallAPfunctions				;
	bra	@quit				;
;-------------------------------------------------------------------------------------
@down:
;-------------------------------------------------------------------------------------
	lda	ObjX, y				; apply laser (x,x+1,y+1,y+1+stride)
	sta	m0				;
	ina					;
	sta	m0+1				;
	lda	ObjY, y				;
	ina					;
	sta	m1				;
	clc					;
	adc	STRIDE, y			;
	sta	m1+1				;
	CallAPfunctions				;
	bra	@quit				;
;-------------------------------------------------------------------------------------
@quit:
;-------------------------------------------------------------------------------------
	rts

;=====================================================================================
OBJR_Laser_Button:
;=====================================================================================
	lda	ObjA4, y			; toggle active state
	bne	:+				;
	lda	#255				;
	sta	ObjA4, y			;
	rts					;
:	tyx					;
	stz	ObjA4, x			;
	rts					;
