
.include "snes.inc"
.include "snes_zvars.inc"
.include "sprites.inc"
.include "ingame.inc"
.include "snesmod.inc"
.include "sounds.inc"

;========================================================================
; exports
;========================================================================
	.export Explosion_Start
	.export Explosion_Update
	.export Explosion_Draw
	.export ResetExpGX
	
	.export Explosion_MiniStart
	
	.exportzp expActive

;========================================================================
	.zeropage
;========================================================================

expX:		.res 1
expY:		.res 1
expTime:	.res 1
expActive:	.res 1
gx_index:	.res 1
gx_eindex:	.res 1

;========================================================================
	.bss
;========================================================================

N_GX		=15
E_GX		=5

gx_x:		.res N_GX+E_GX
gx_y:		.res N_GX+E_GX
gx_frame:	.res N_GX+E_GX
gx_active:	.res N_GX+E_GX

;========================================================================
	.code
	.a8 
	.i16
;========================================================================

.macro mspawn_gx PX,PY
	lda	#PY
	clc
	adc	expY
	xba
	lda	#PX
	clc
	adc	expX
	jsr	spawn_gx
.endmacro

ResetExpGX:
	ldx	#N_GX-1
:	stz	gx_active, x
	dex
	bpl	:-
	stz	gx_eindex
	rts

;========================================================================
Explosion_Start:
;========================================================================
; a = x (tile)
; b = y (tile)
;------------------------------------------------------------------------
	sta	expX
	xba
	sta	expY
	stz	expTime
	lda	#128
	sta	expActive
	
	stz	gx_index
	rts
	
;========================================================================
Explosion_MiniStart:
;========================================================================
;a=x
;b=y
;------------------------------------------------------------------------
	pha
	lda	gx_eindex
	ina
	cmp	#E_GX
	bcc	:+
	lda	#0
:	sta	gx_eindex
	clc
	adc	#N_GX
	tax
	pla
	sep	#10h
	jmp	spawn_gxi
	.i16
	
;========================================================================
Explosion_Update:
;========================================================================

	jsr	UpdateGX
	
	bit	expActive
	bmi	@active
	rts
@active:
	
	inc	expTime
	lda	expTime
	cmp	#1
	beq	@et_1
	cmp	#5
	beq	@et_2
	cmp	#9
	beq	@et_3
	cmp	#15
	beq	@et_4
	rts
	
@et_4:
	rts
	
@et_1:
	mspawn_gx 0, 0
	rts
@et_2:
	mspawn_gx -1, 0
	mspawn_gx 1, 0
	mspawn_gx 0, -1
	mspawn_gx 0, 1
	rts
@et_3:
	mspawn_gx -2, 0
	mspawn_gx 2, 0
	mspawn_gx 0, -2
	mspawn_gx 0, 2
	mspawn_gx -1, -1
	mspawn_gx 1, -1
	mspawn_gx -1, 1
	mspawn_gx 1, 1
	stz	expActive
	rts
	
;========================================================================
UpdateGX:
;========================================================================
	ldx	#0
	
@loop:
	lda	gx_active, x
	beq	@next
	
	inc	gx_frame, x
	lda	gx_frame, x
	cmp	#2<<2
	bne	:++
:	lda	gx_y, x
	xba
	lda	gx_x, x
	phx
	jsr	ExplodeSpace
	plx
	bra	@next
:	
	cmp	#3<<2
	beq	:--
	cmp	#7<<2
	bcc	@next
	stz	gx_active, x
@next:
	inx
	cpx	#N_GX+E_GX
	bne	@loop
	
	rts
	

;========================================================================
Explosion_Draw:
;========================================================================
	jsr	draw_gx
	
	lda	expActive
	beq	:+
:	rts

draw_gx:
	ldx	#0
	
	
@loop:
	lda	gx_active, x
	beq	@next
	lda	gx_x, x
	rep	#20h
	and	#255
	asl
	asl
	asl
	asl
	sbc	CameraPX
	bmi	:+
	cmp	#256
	bcs	@next
	bra	:++
:	cmp	#-17
	bcc	@next
:	
	sta	m0
	
	sep	#20h
	lda	gx_y, x
	rep	#20h
	and	#255
	asl
	asl
	asl
	asl
	sbc	CameraPY
	bmi	:+
	cmp	#SCREENHEIGHT
	bcs	@next
	bra	:++
:	cmp	#-17
	bcc	@next
:	
	sta	m1
	
	sep	#20h
	lda	gx_frame, x
	rep	#20h
	and	#255
	lsr
	lsr
	asl
	adc	#128		; gxtileS
	tay
	
	sep	#20h
	lda	#%00110000 + (4<<1)
	xba
	lda	m1
	phx
	ldx	m0
	AddSprite16f
	plx
@next:
	sep	#20h
	inx
	cpx	#N_GX+E_GX
	beq	@quit
	jmp	@loop
@quit:
	
	rts

;a = x
;b = y
;========================================================================
spawn_gx:
;========================================================================
	sep	#10h			; read index
	ldx	gx_index		;
;------------------------------------------------------------------------
	cpx	#N_GX			; catch index-maxed
	bne	:+			;
	rep	#10h			;
	rts				;
:					;
	inc	gx_index		;
;------------------------------------------------------------------------
spawn_gxi:
	
	sta	gx_x, x			; set x,y
	xba				;
	sta	gx_y, x			;
	stz	gx_frame, x		; reset time
	lda	#128			; set active flag
	sta	gx_active, x		;
;------------------------------------------------------------------------
	rep	#10h
	
	spcPlaySoundM SND_EXPLOSION

	rts
