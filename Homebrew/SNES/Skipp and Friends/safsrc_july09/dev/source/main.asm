;***************************************************
; sneskit template
;***************************************************

.include "snes.inc"
.include "snes_joypad.inc"
.include "snes_decompress.inc"
.include "snes_zvars.inc"
.include "copying.inc"

.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"

.include "level.inc"
.include "graphics.inc"

.import DoIntro, DoSplash, DoTitle, RunGame, DoStory, DoPassword, DoPregame

.global _nmi, main
.global oam_table, oam_hitable
.exportzp frame_ready


;===============================================================
.zeropage
;===============================================================

;...insert some zeropage variables
frame_ready:
	.res	1
CURRENT_LEVEL:
	.res	1
	
.exportzp CURRENT_LEVEL

;===============================================================
.bss
;===============================================================

oam_table:
	.res	(128*4)
oam_hitable:
	.res	(128/4)
	
;===============================================================
	.segment "HRAM"
;===============================================================

.export Player_DimPalettes, Player1_DimPal, Player2_DimPal, Player3_DimPal
Player_DimPalettes:
Player1_DimPal:
	.res 2*16
Player2_DimPal:
	.res 2*16
Player3_DimPal:
	.res 2*16

;===============================================================
.code
;===============================================================

	.a8
	.i16

.import test_tileset
.import Level_LoadTileset

.import LEVEL_test
;------------------------------------------------------------------------------
; program entry point
;==============================================================================
main:
;==============================================================================
	lda	#80h			; disable screen
	sta	REG_INIDISP		;
;------------------------------------------------------------------------------
	jsr	GenerateDimPalettes	; initialize stuff
					;
;------------------------------------------------------------------------------

	jsr	spcBoot			; boot SPC
	lda	#^__SOUNDBANK__		; setup soundbank
	jsr	spcSetBank		;
	lda	#^SoundTable|80h	; setup soundtable
	ldy	#.LOWORD(SoundTable)	;
	jsr	spcSetSoundTable	;
	
	lda	#38
	jsr	spcAllocateSoundRegion
;------------------------------------------------------------------------------
	lda	#81h			; enable NMI & auto-joypad
	sta	REG_NMITIMEN		;
;------------------------------------------------------------------------------
	cli				; enable IRQ
;------------------------------------------------------------------------------
	lda	#1
	sta	frame_ready
	
;	jmp	@pood
;------------------------------------------------------------------------------
	jsr	DoIntro			; run intro
;------------------------------------------------------------------------------
@redostory:
	lda	#80h			; turn off screen again
	sta	REG_INIDISP		; 
	ldy	#20
:	wai
	dey
	bne	:-
;------------------------------------------------------------------------------
	jsr	DoSplash		; run splash/credits
;------------------------------------------------------------------------------
	lda	#0
	jsr	DoStory
;-------------------------------------------------------------------------------
	stz	CURRENT_LEVEL
	jsr	DoTitle
	cmp	#2
	beq	@redostory
	cmp	#0
	beq	@LEVEL_LOOP
@dopassword:
	jsr	DoPassword
	cmp	#-1
	beq	@redostory
	sta	CURRENT_LEVEL
;-------------------------------------------------------------------------------
@LEVEL_LOOP:
@pood:
	lda	CURRENT_LEVEL
	cmp	#0
	beq	:+
	jsr	DoPregame
:

	
@redo_level:
	lda	CURRENT_LEVEL
	jsr	RunGame			;
	cmp	#0
	beq	@redo_level
	inc	CURRENT_LEVEL
	lda	CURRENT_LEVEL
	cmp	#9
	beq	@end_of_game
	bra	@LEVEL_LOOP
	
@end_of_game:
	lda	#1
	jsr	DoStory
	
:	wai
	bra	:-

;==============================================================================
GenerateDimPalettes:
;==============================================================================
						;
	lda	#^Player_DimPalettes		; setup writing to dim palettes
	sta	REG_WMADDH			;
	ldy	#.LOWORD(Player_DimPalettes)	;	
	sty	REG_WMADDL			;
;------------------------------------------------------------------------------
.macro DimPalette source
;------------------------------------------------------------------------------
	.local @loop
	ldx	#0			; iterate through colors
;------------------------------------------------------------------------------
@loop:					;
	rep	#20h			;
	lda	f:source, x		; multiply color by 7/8
	and	#~%001110011100111	;
	lsr				;
	lsr				;
	lsr				;
	sta	m0			;
	lda	f:source, x		;
	sec				;
	sbc	m0			;
;------------------------------------------------------------------------------
	sep	#20h			; write to mem
	sta	REG_WMDATA		;
	xba				;
	sta	REG_WMDATA		;
;------------------------------------------------------------------------------
	inx				; loop for 16 colors
	inx				;
	cpx	#32			;
	bne	@loop			;
.endmacro				;
;------------------------------------------------------------------------------
	DimPalette gfx_player1Pal	; process player palettes
	DimPalette gfx_player2Pal	;
	DimPalette gfx_player3Pal	;
;------------------------------------------------------------------------------
	rts
	
;---------------------------------------------------------------
; NMI irq handler
;===============================================================
_nmi:
;===============================================================
	rep	#30h			; push a,x,y
	pha				;
	phx				;
	phy				;-----------------------
	sep	#20h			; 8bit akku
;---------------------------------------------------------------
					
	lda	frame_ready		; skip frame update if not ready!
	cmp	#1			;
	bne	_frame_not_ready	;-----------------------
	stz	REG_OAMADDL		; reset oam access
	stz	REG_OAMADDH		;
					;-----------------------
	lda	#%00000010		; copy oam buffers
	sta	REG_DMAP6		;
	lda	#REG_OAMDATA&255	;
	sta	REG_BBAD6		;
	ldy	#oam_table&65535	;
	lda	#^oam_table		;
	sty	REG_A1T6L		;
	sta	REG_A1B6		;
	ldy	#544			;	
	sty	REG_DAS6L		;
	lda	#%01000000		;
	sta	REG_MDMAEN		;--------------------------
_frame_not_ready:			;
	jsr	joyRead			; read joypads
					;--------------------------
	lda	REG_TIMEUP		; read from REG_TIMEUP (?)
					;
	rep	#30h			; pop a,x,y
	ply				;
	plx				;
	pla				;
	rti				; return


.segment "HDATA"
.segment "HRAM2"
