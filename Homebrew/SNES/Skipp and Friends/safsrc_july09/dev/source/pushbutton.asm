;
; BUTTON
;

.include "objects.inc"
.include "graphics.inc"
.include "snesmod.inc"
.include "sounds.inc"

;====================================================================================
; IMPORTS
;====================================================================================

;====================================================================================
; EXPORTS
;====================================================================================
	.export OBJR_Button_Init
	.export	OBJR_Button_Update
	.export OBJR_Button_Draw
	.export OBJR_Button_Step

;====================================================================================
; DEFINITIONS
;====================================================================================
	
PRESSED = ObjC1

	.code
	.a8
	.i8

;====================================================================================
OBJR_Button_Init:
;====================================================================================
	tyx
	stz	PRESSED,x
	rts
	
;====================================================================================
OBJR_Button_Update:
;====================================================================================
	rts
	
;====================================================================================
OBJR_Button_Draw:
;====================================================================================
	lda	#%00110000 | (DONGLESPAL<<1)
	pha
	lda	PRESSED,y
	bne	:+
	lda	#DONGLE_BUTTON
	bra	:++
:	lda	#DONGLE_BUTTONDOWN
:	pha
	jsr	Objects_AddSpriteB16
	pla
	pla
	rts
	
OBJR_Button_Step:
	lda	OTSTEP
	beq	Button_Up

;====================================================================================
Button_Down:
;====================================================================================
	lda	PRESSED, y
	beq	:+
	ina
	sta	PRESSED, y
	rts
:	ina
	sta	PRESSED, y
	
	PHy
	rep	#10h
	spcPlaySoundM SND_BUTTON
	sep	#10h
	PLy
	
	; [press]
	lda	ObjA1, y
	sta	OTX
	lda	ObjA2, y
	sta	OTY
	lda	#1
	sta	OTSTEP
	phy
	rep	#10h
	jsr	Objects_Button
	sep	#10h
	ply
	
	
	rts

;====================================================================================
Button_Up:
;====================================================================================
	lda	PRESSED, y
	beq	@quit
	dea
	sta	PRESSED, y
	bne	@quit
	
	PHy
	rep	#10h
	spcPlaySoundM SND_BUTTON
	sep	#10h
	PLy
	
	; [release]
	lda	ObjA1, y
	sta	OTX
	lda	ObjA2, y
	sta	OTY
	stz	OTSTEP
	phy
	rep	#10h
	jsr	Objects_Button
	sep	#10h
	ply
@quit:	
	rts
