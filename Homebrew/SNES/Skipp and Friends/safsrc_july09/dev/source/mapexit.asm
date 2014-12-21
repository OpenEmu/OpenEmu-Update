
.include "players.inc"
.include "objects.inc"
.include "graphics.inc"
.include "ingame.inc"
.include "snesmod.inc"
.include "sounds.inc"

	.export OBJR_MapExit_Init
	.export OBJR_MapExit_Update
	.export OBJR_MapExit_Draw


OBJR_MapExit_Init:
	rts
	
OBJR_MapExit_Update:

	ldx	#2
	
@test_for_players:
	lda	PL_Exited, x
	bne	@next_test
	lda	PL_HP, x
	beq	@next_test
	lda	PL_XH, x
	cmp	ObjX, y
	bne	@next_test
	lda	PL_YH, x
	cmp	ObjY, y
	bne	@next_test
	lda	#1
	sta	PL_Exited, X
	
	jsr	UpdatePlayerPalettes
	
	phy
	rep	#10h
	spcPlaySoundM SND_MENU2
	sep	#10h
	ply
	;---------------- DO SOMETHING SPECIAL FOR THE RESCUED PLAYER
	
@next_test:
	dex
	bpl	@test_for_players
	rts
	
OBJR_MapExit_Draw:
	mac_Objects_AddSpriteB16 (%00110000 | (DONGLESPAL<<1)), DONGLE_EXIT
	rts

