
;
; lock 'n' key
;

.include "objects.inc"
.include "players.inc"
.include "graphics.inc"
.include "snesmod.inc"
.include "sounds.inc"

;============================================================================	
; IMPORTS
;============================================================================	
.import level_solid

;============================================================================	
; EXPORTS
;============================================================================	
.export OBJR_Lock_Init, OBJR_Lock_Update, OBJR_Lock_Draw, OBJR_Lock_Action

STATE = ObjC1
FRAME = ObjC2

STATE_LOCKED = 0
STATE_OPENING = 1

	.code
	.a8
	.i8

;============================================================================	
OBJR_Lock_Init:
;============================================================================	
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
	lda	#192
	sta	F:level_solid, x
	sep	#10h
	tyx
	stz	STATE, x 
	stz	FRAME, x
	rts
	
;============================================================================	
OBJR_Lock_Update:
;============================================================================
	lda	STATE, y
	beq	@quit
	
	lda	FRAME, y
	clc
	adc	#3
	sta	FRAME, y
	cmp	#4*16
	bcc	@quit
	jsr	DeleteThing
@quit:	rts
	
;============================================================================	
OBJR_Lock_Draw:
;============================================================================
	
	lda	#(%00110000 | (DONGLESPAL<<1))
	pha
	lda	FRAME, y
	lsr
	lsr
	lsr
	lsr
	asl
	adc	#DONGLE_LOCK	
	pha
	jsr	Objects_AddSpriteB16
	pla
	pla
	
;----------------------------------------------------------------------------
	rts
	
DeleteThing:
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
	lda	#0
	sta	F:level_solid, x
	sep	#10h
	sta	ObjType, y
	rts

;============================================================================
OBJR_Lock_Action:
;============================================================================	

	lda	OTKEY
	bne	:+
	
	; *maybe play FAILURE sound
	rts
:
	dec	OTKEY
	
	
	PHy
	rep	#10h
	spcPlaySoundM SND_CARDKEY
	sep	#10h
	PLy
	
	lda	#STATE_OPENING
	sta	STATE, y
	
	rts
