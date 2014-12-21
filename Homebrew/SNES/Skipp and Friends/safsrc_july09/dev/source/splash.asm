;====================================================================
; splash screen! ! ! 
;====================================================================

.include "snes.inc"
.include "snes_decompress.inc"
.include "graphics.inc"

.global DoSplash

; vram addresses
MAP_START = 0000h
TILES_START = 0800h

	.code
	.a8
	.i16

;====================================================================
DoSplash:
;====================================================================
	lda	#0			; disable layers
	sta	REG_TM			;
;--------------------------------------------------------------------
					; copy graphics
					;
	DoDecompressDataVram gfx_splashMap, MAP_START
	DoDecompressDataVram gfx_splashTiles, TILES_START
	DoCopyPalette gfx_splashPal, 0, 256
;--------------------------------------------------------------------
	stz	REG_BG1SC		; set bg0 control 32x32 map = 0
	stz	REG_BG1HOFS		; reset offset
	stz	REG_BG1HOFS		;
	lda	#-1			;
	sta	REG_BG1VOFS		;
	stz	REG_BG1VOFS		;
;--------------------------------------------------------------------
	lda	#1			; bgmode = 1 (16,16,4)
	sta	REG_BGMODE		;
;--------------------------------------------------------------------
	wai				; enable bg1
	lda	#1			;
	sta	REG_TM			;
;--------------------------------------------------------------------
	lda	#0			; fade in screen
:	wai				;
	sta	REG_INIDISP		;
	ina				;
	cmp	#16			;
	bne	:-			;
;--------------------------------------------------------------------
	ldx	#60*4			; timeout in 4 seconds
:	wai				;
	dex				;
	bne	:-			;
;--------------------------------------------------------------------
	lda	#15			; fade out screen
:	wai				;
	dea				;
	sta	REG_INIDISP		;
	bne	:-			;
;--------------------------------------------------------------------
	lda	#80h
	sta	REG_INIDISP
	rts

