
.include "snes.inc"
.include "snes_zvars.inc"

	.code
	.a8
	.i16
	
BG1MAP = (4000H/2)
	
.macro RenderString px, py, text, pal
	ldx	#BG1MAP + px + py * 32
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
