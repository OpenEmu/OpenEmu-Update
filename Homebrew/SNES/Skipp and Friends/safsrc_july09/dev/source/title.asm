;
; title screen!
;

.include "snes.inc"
.include "snes_zvars.inc"
.include "snes_decompress.inc"
.include "graphics.inc"
.include "snes_joypad.inc"
.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"

.global DoTitle
;-------------------------------------------------------------------------
; bg0 = 256col title
; bg1 = 16col options
;-------------------------------------------------------------------------

BG2MAP = (0C000H/2)

	.code
	.a8
	.i16
	
.macro RenderString px, py, text, pal
	ldx	#BG2MAP + px + py * 32
	stx	REG_VMADD
	ldy	#0
	bra	:++
:	iny
	sta	REG_VMDATAL
	lda	#pal<<2
	sta	REG_VMDATAH
:	lda	text, y
	bne	:--
.endmacro	

SELECTION = m4
DIRTY = m5
TIMEOUT=m6
FADEOUT=m7

;*************************************************************************
;* show title screen and choose game mode
;*************************************************************************
DoTitle:
;-------------------------------------------------------------------------
	lda	#0			; disable layers
	sta	REG_TM			;
;-------------------------------------------------------------------------
					; load graphics
					;
	DoDecompressDataVram gfx_titleMap, 0000h
	DoDecompressDataVram gfx_titleTiles, 2000h
	DoCopyPalette gfx_titlePal, 32, 160
	DoCopyPalette gfx_sfontPal, 0, 16
	DoCopyPalette gfx_sfontPal, 16, 16
	DoDecompressDataVram gfx_sfontTiles, 8000h
	
	jsr	spcStop
	
	ldx	#127
	
	jsr	spcSetModuleVolume
	
	ldx	#MOD_BOTSONG
	jsr	spcLoad
	
	ldx	#0
	jsr	spcPlay
	jsr	spcGetCues
	
	jsr	spcFlush
	
	stz	REG_CGADD
	stz	REG_CGDATA
	stz	REG_CGDATA
	
	lda	#1+16
	sta	REG_CGADD
	lda	#0EFH
	sta	REG_CGDATA
	lda	#03DH
	sta	REG_CGDATA
	
	stz	REG_BG1SC
	stz	REG_BG1HOFS
	stz	REG_BG1HOFS
	stz	REG_BG2HOFS
	stz	REG_BG2HOFS
	LDA	#-1
	STA	REG_BG1VOFS
	STA	REG_BG1VOFS
	sta	REG_BG2HOFS
	sta	REG_BG2HOFS
	lda	#(0C000h/800h)<<2
	sta	REG_BG2SC	
	lda	#(08000h>>13)<<4
	sta	REG_BG12NBA
;-------------------------------------------------------------------------
	lda	#BGMODE_3		; setup display
	sta	REG_BGMODE		; mode3
	lda	#%11			;
	sta	REG_TM			; bg1
	
	lda	#80h
	sta	REG_VMAIN
	
	ldx	#BG2MAP
	stx	REG_VMADD
	ldx	#1024
:	ldy	#0
	sty	REG_VMDATA
	dex
	bne	:-
	
	RenderString 12, 22, str_newgame, 0
	RenderString 12, 24, str_password, 1

	stz	SELECTION
	stz	DIRTY
	
	lda	#%11110010
	sta	REG_MOSAIC
	stz	m0
	stz	m1
	

;-------------------------------------------------------------------------
	wai				; turn on screen
	lda	#00h			;
	sta	REG_INIDISP		;
;-------------------------------------------------------------------------
@loop:

	lda	m1
	lsr
	cmp	#16
	bne	@noinput
	lda	joy1_down+1
	bit	#JOYPADH_UP|JOYPADH_DOWN
	beq	:+
	lda	SELECTION
	eor	#1
	sta	SELECTION
	inc	DIRTY
	
	spcPlaySoundM SND_MENU1
:
	lda	joy1_down
	bpl	:+
	jmp	OptionSelected
:
@noinput:

	rep	#20h
	lda	TIMEOUT
	ina
	cmp	#60*60
	bne	:+
	sep	#20h
	lda	#2
	sta	SELECTION
	jmp	OptionSelected
:	sta	TIMEOUT
	sep	#20h
	
	jsr	spcProcess
	
	wai

	lda	m1
	lsr
	cmp	#16
	beq	:+
	sta	REG_INIDISP
	
	asl
	asl
	asl
	asl
	eor	#0F0h
	ora	#%011
	sta	REG_MOSAIC
	inc	m1
	
:
	
	lda	DIRTY
	beq	@notdirty
	stz	DIRTY
	
	lda	#1
	sta	REG_CGADD
	lda	#0FFH
	sta	REG_CGDATA
	lda	#07FH
	sta	REG_CGDATA
	
	lda	#1+16
	sta	REG_CGADD
	lda	#0FFH
	sta	REG_CGDATA
	lda	#07FH
	sta	REG_CGDATA
	
	lda	SELECTION
	beq	@topsel
	lda	#1
	bra	@bottomsel
@topsel:
	lda	#1+16
@bottomsel:
	
	
	sta	REG_CGADD
	lda	#0EFH
	sta	REG_CGDATA
	lda	#03DH
	sta	REG_CGDATA
	
@notdirty:

;	rep	#20h
;	inc	m0
;	lda	m0
;	lsr
;	sep	#20h
;	sta	REG_BG2HOFS
;	stz	REG_BG2HOFS
	jmp	@loop
;-------------------------------------------------------------------------


OptionSelected:


	stz	TIMEOUT
	stz	TIMEOUT+1
	lda	#15<<1
	sta	FADEOUT

	lda	SELECTION
	cmp	#1
	beq	@s1
	bcc	@s0
	bra	@s2
@s0:
	spcPlaySoundM SND_STARTGAEM
	bra	@s2
@s1:
	spcPlaySoundM SND_MENU2
@s2:

@loop:
	inc	m0
	lda	TIMEOUT
	cmp	#50
	bcs	:+
	ina
	sta	TIMEOUT
	
	cmp	#50
	bne	:+
	ldx	#0
	ldy	#8
	jsr	spcFadeModuleVolume
:
	jsr	spcProcess
	wai
	
	lda	TIMEOUT
	cmp	#50
	bne	:+
	lda	FADEOUT
	dea
	sta	FADEOUT
	beq	@quit
	lsr
	sta	REG_INIDISP
:
	
	lda	SELECTION
	cmp	#2
	beq	@noflash
	cmp	#0
	beq	@topsel
	lda	#1+16
	bra	@bottomsel
@topsel:
	lda	#1
@bottomsel:
	
	
	sta	REG_CGADD
	
	lda	m0
	and	#7
	cmp	#4
	rep	#20h
	bcs	:+
	lda	#07FFFh
	bra	:++
:	lda	#05294h
:
	sep	#20h
	sta	REG_CGDATA
	xba
	sta	REG_CGDATA
@noflash:
	
	bra	@loop
@quit:
	lda	#80h
	sta	REG_INIDISP

	lda	SELECTION
	rts

str_newgame:
	.asciiz "New Game"
	
str_password:
	.asciiz "Password"
