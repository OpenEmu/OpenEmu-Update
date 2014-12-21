
.include "snes.inc"
.include "snes_zvars.inc"
.include "snesmod.inc"
.include "soundbank.inc"


.export DoCredits

HOFS = m3
WRITELINE = m4
READ = m1
VOFS = m2
REACHEDEND=m4+1



	.a8
	.i16
	
_clearline:

	lda	WRITELINE			; prime area
	rep	#20h
	and	#255
	asl
	asl
	asl
	asl
	asl
	adc	#2000h
	sta	REG_VMADD
	sta	m0
	
	sep	#20h
	lda	#80h
	sta	REG_VMAIN
	rep	#20h
	
.repeat 32
	stz	REG_VMDATA
.endrep
	sep	#20h

	
	rts
	
;=======================================================================
CopyLine:
;=======================================================================
	ldy	READ		; x = length of line
	lda	CREDITS,y
	cmp	#2
	bne	:+
	
	jsr	_clearline
	lda	WRITELINE
	ina
	and	#31
	sta	WRITELINE
	rts
:
	ldx	#-1		;
	dey			;
:	iny			;
	inx			;
	lda	CREDITS, y	;
	bne	:-		;
;-----------------------------------------------------------------------
	jsr	_clearline
;	lda	WRITELINE			; prime area
;	rep	#20h
;	and	#255
;	asl
;	asl
;	asl
;	asl
;	asl
;	adc	#2000h
;	sta	REG_VMADD
;	sta	m0
	
;	sep	#20h
;	lda	#80h
;	sta	REG_VMAIN
;	rep	#20h
;	
;.repeat 32
;	stz	REG_VMDATA
;.endrep
	rep	#20h
	txa
	lsr
	sec
	sbc	#16
	eor	#0FFFFh
	ina
	clc
	adc	m0
	dea
	sta	REG_VMADD
	sep	#20h
	
	
	ldy	READ		; x = length of line
:	lda	CREDITS, y	;
	beq	@quit
	iny
	sta	REG_VMDATAL
	stz	REG_VMDATAH
	bra	:-		;
@quit:
	iny
	sty	READ

	lda	WRITELINE
	ina
	and	#31
	sta	WRITELINE
	
	rts
	
;=======================================================================
DoCredits:
;=======================================================================

	; branch off from story
	
	
	jsr	spcStop
	jsr	spcFlush
	
	ldx	#127
	jsr	spcSetModuleVolume

	ldx	#MOD_THEMESNE
	jsr	spcLoad
	
	stx	VOFS
	
	jsr	spcPlay
	jsr	spcFlush
	
	lda	#29
	sta	WRITELINE
	ldx	#0
	stx	READ
	
@loop:
	wai
	REP	#20H
	inc	HOFS
	lda	HOFS
	lsr
	lsr
	sep	#20H
	sta	REG_BG2HOFS
	stz	REG_BG2HOFS
	
	rep	#20h

	inc	VOFS
	lda	VOFS
	cmp	#ENDOFSCROLL
	bne	:+
	dec	VOFS
	jmp	@loop
:
	
	bit	#%111111
	bne	:+
	sep	#20h
	jsr	CopyLine
:	rep	#20h
	lda	VOFS
	lsr
	lsr
	lsr
	ina
	sep	#21h
	sbc	#8
	sta	REG_BG1VOFS
	stz	REG_BG1VOFS
	
	
	jmp	@loop
	
CREDITS:
	.asciiz	"-- Credits --"
	.asciiz	""
	.asciiz	""
	.asciiz	"- Programming -"
	.asciiz ""
	.asciiz	"Mukunda Johnson"
	.asciiz	""
	.asciiz	""
	.asciiz "- Character Design -"
	.asciiz ""
	.asciiz	"Hubert Lamontagne"
	.asciiz	"Ken Snyder"
	.asciiz	""
	.asciiz	""
	.asciiz "- Character Animation -"
	.asciiz ""
	.asciiz	"Ken Snyder"
	.asciiz	""
	.asciiz	""
	.asciiz	"- Concept -"
	.asciiz ""
	.asciiz	"Hubert Lamontagne"
	.asciiz	""
	.asciiz	""
	.asciiz "- Music -"
	.asciiz ""
	.asciiz	"Steven Velema"
	.asciiz	"Hubert Lamontagne"
	.asciiz	"Ken Snyder"
	.asciiz	""
	.asciiz	""
	.asciiz	"- Sound Effects -"
	.asciiz ""
	.asciiz	"Steven Velema"
	.asciiz	"Mukunda Johnson"
	.asciiz	""
	.asciiz	""
	.asciiz	"- Level Design -"
	.asciiz ""
	.asciiz	"Mukunda Johnson"
	.asciiz	""
	.asciiz ""
	.asciiz "- Audio Programming -"
	.asciiz ""
	.asciiz "Mukunda Johnson"
	.asciiz	""
	.asciiz	""
	.asciiz "- Beta Testing -"
	.asciiz ""
	.asciiz	"#mod_shrine"
	.asciiz	""
	.asciiz ""
	.asciiz "- Localization -"
	.asciiz ""
	.asciiz "Yahoo!(R) Babel Fish"
	.asciiz	""
	.asciiz	""
	.asciiz "- Special Thanks -"
	.asciiz ""
	.asciiz "Arvid Staaf"
	.asciiz "Nyarla"
	.asciiz	""
	.asciiz	""
	.asciiz	"No humans were harmed"
	.asciiz	"during the production"
	.asciiz	"of this video game"
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz	""
	.asciiz "The End"
	.byte 2

ENDOFSCROLL	= ((270-189)*8+112+8)*8
