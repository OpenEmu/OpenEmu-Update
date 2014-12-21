
.include "snes.inc"
.include "snes_zvars.inc"
.include "snes_decompress.inc"
.include "graphics.inc"
.include "snes_joypad.inc"

.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"

	.code

;========================================================================================
story_primer:
;========================================================================================
             ;01234567890123456789012345678901
	.byte "In former times,",1,1,"  friends", 13
	.byte "Skipp,",1," Apple,",1," and the Wedge", 13
	.byte "were camped.", 1,1,1,1,1,1,1,1,1,13, 13
	.byte "Opposing to expectation,",1,1,1," as", 13
	.byte "for them they were kidnapped", 13
	.byte "by the foreigners which is", 13
	.byte "supposed to because it exists.", 13, 13, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	.byte "They were placed on the under-", 13
	.byte "ground prison of the space-",13
	.byte "craft of enormous foreign", 13
	.byte "country....", 13, 13,1,1,1,1,1,1,1,1
	     ;01234567890123456789012345678901
	.byte "Before marshmellows burns,",1,1,1," it ", 13
	.byte "escapes from the body of the", 13
	.byte "captivity and it must help", 13
	.byte "those in order to return to", 13
	.byte "their planet!",1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	
;========================================================================================
story_finish:
;========================================================================================
             ;01234567890123456789012345678901
	.byte "Three friends ride in the pod",13
	.byte "of escaping,",1,1,1,1," are returned to", 13
	.byte "the planet of their houses in", 13
	.byte "their methods.", 13,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	.byte 13
	.byte "Good work, they couldn't con-",13
	.byte "tinued your excellence it does", 13
	.byte "not help.", 13,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	.byte 13
	.byte "When those return to starting", 13
	.byte "point,",1,1," truly those is cautious", 13
	.byte "in excess,",1,1," it warns to the", 13
	.byte "other people concerning the", 13
	.byte "race of immoral foreign", 13
	.byte "country."
	.byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 0
	
stories:
	.word	story_primer
	.word	story_finish
	
story_music:
	.byte	MOD_SPAEC
	.byte	MOD_GAYMARCH
	
.export DoStory

TIMER = m0
REACHEND = m0+1
WRITE = m1
FADE = m2
HOFS = m3
READ = m4
SOURCE = m5
STIME = 5
FADEOUT=m6
FADEOUTC=m6+1

	.bss
	
story_index:
	.res 1


	.code
	.a8
	.i16
	
StopStory:
	lda	FADEOUT
	bne	:+
	lda	#1
	sta	FADEOUT
	lda	#15<<2
	sta	FADEOUTC
	
	ldx	#0
	ldy	#8
	jsr	spcFadeModuleVolume
	
:	rts
	
;===========================================================
ReadChar:
;===========================================================
	lda	REACHEND
	beq	:+
	rts
:
	ldy	READ
	lda	(SOURCE), y
	beq	@end_of_story
	iny
	sty	READ
	
	cmp	#13
	beq	@newline
	cmp	#1
	beq	@delay
	
	ldy	WRITE
	sty	REG_VMADDL
	iny
	sty	WRITE
	sta	REG_VMDATAL
	lda	#1<<2
	sta	REG_VMDATAH
	
	cmp	#' '
	beq	@delay
	spcPlaySoundM SND_BEEP1
@delay:
	rts
	
@newline:
	rep	#21h
	lda	WRITE
	and	#~31
	adc	#32
	sta	WRITE
	sep	#20h

	jmp	ReadChar
	
@end_of_story:
	lda	#1
	sta	REACHEND
	jmp	StopStory

;=============================================================================
; a = index
;=============================================================================
DoStory:
;=============================================================================
	ldx	m4
	phx
	ldx	m5
	phx
	
	sta	story_index
	
	
	
	
	DoDecompressDataVram gfx_sfontTiles, 0000h
	DoCopyPalette gfx_sfontPal, 16, 16
	DoCopyPalette gfx_starsPal, 0, 16
	DoDecompressDataVram gfx_starsTiles, 8800h
	DoDecompressDataVram gfx_starsMap, 8000h
	
	lda	#(8000h>>13)<<4
	sta	REG_BG12NBA
	lda	#(8000h>>13)
	sta	REG_BG34NBA
	lda	#1
	sta	REG_BGMODE
	
	lda	#8<<2
	sta	REG_BG1SC
	lda	#(8000h/800h) << 2
	sta	REG_BG2SC
	sta	REG_BG3SC
	
	lda	#80h
	sta	REG_VMAIN
	
	ldx	#8*1024
	stx	WRITE
	stx	REG_VMADD
	ldx	#0
	ldy	#1024
:	stx	REG_VMDATA
	dey
	bne	:-
	
	lda	#-8
	sta	REG_BG1HOFS
	stz	REG_BG1HOFS
	lda	#-9
	sta	REG_BG1VOFS
	sta	REG_BG1VOFS
	lda	#-1
	sta	REG_BG2VOFS
	stz	REG_BG2VOFS
	
	lda	story_index
	asl
	tax
	sep	#10h
	rep	#30h
	lda	stories, x
	sta	SOURCE
	sep	#20h
	
	stz	FADEOUT
	stz	READ+0
	stz	READ+1
	stz	FADE
	lda	#STIME
	sta	TIMER
	stz	REACHEND
	
	lda	#%011
	sta	REG_TM
	wai

	sep	#10h
	ldx	story_index
	lda	story_music, x
	tax
	rep	#10h
	jsr	spcLoad
	
	ldx	#127
	jsr	spcSetModuleVolume
	
	ldx	#0
	jsr	spcPlay
	
	jsr	spcFlush
	
	ldx	#30
:	wai
	dex
	bne	:-
	
@loop:

	lda	FADE
	cmp	#150
	bcc	@keydelay
	
	lda	story_index	; disallow skipping of final
	cmp	#1
	beq	:+
	rep	#20h
	lda	joy1_down
	bit	#JOYPAD_A|JOYPAD_START
	beq	@no_keypres

	sep	#20h
	jsr	StopStory
	
@no_keypres:
	sep	#20h
@keydelay:
:
	
	jsr	spcProcess
	wai
	
;--------------------------------------------------------------------
	lda	FADE
	cmp	#150
	bcc	@fadescr
	
	dec	TIMER
	bne	@nochar
	lda	#STIME
	sta	TIMER
	jsr	ReadChar
	
@nochar:

	bra	@skipfade
@fadescr:
	ina
	sta	FADE
	cmp	#64
	bcs	@skipfade
	lsr
	lsr
	sta	REG_INIDISP
@skipfade:
;--------------------------------------------------------------------

	lda	FADEOUT
	beq	@no_fadeout
	
	
	lda	FADEOUTC
	dec
	sta	FADEOUTC

	lsr
	lsr
	beq	@exit_loop
	
	pha
	lda	story_index
	cmp	#1
	beq	:+
	pla
	pha
	sta	REG_INIDISP
:	pla
	
@no_fadeout:

	REP	#20H
	inc	HOFS
	lda	HOFS
	lsr
	lsr
	sep	#20H
	STA	REG_BG2HOFS
	stz	REG_BG2HOFS
	
	bra	@loop
@exit_loop:

	lda	story_index
	cmp	#1
	beq	@start_credits
	
	lda	#80h
	sta	REG_INIDISP


	plx
	stx	m5
	plx
	stx	m4

	rts

	.import DoCredits
@start_credits:
	jsr	spcFlush
	jmp	DoCredits
