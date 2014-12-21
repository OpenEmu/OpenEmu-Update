
;
;
;

.include "snes.inc"

.import oam_table
.import oam_hitable

.export Sprites_Reset, Sprites_Process
	
NOBJ = 35

	.zeropage
	
sprite_index_back:
	.res 2
sprite_index_front:
	.res 2
	
	.bss
	
.export SPRITEa_XL, SPRITEa_XH, SPRITEa_Y, SPRITEa_A2, SPRITEa_A3, SPRITEa_SIZE
.export SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE
.exportzp sprite_index_front, sprite_index_back

SPRITEa_XL:
	.res NOBJ
SPRITEa_XH:
	.res NOBJ
SPRITEa_Y:
	.res NOBJ
SPRITEa_A2:
	.res NOBJ
SPRITEa_A3:
	.res NOBJ
SPRITEa_SIZE:
	.res NOBJ
	
SPRITEb_XL:
	.res NOBJ
SPRITEb_XH:
	.res NOBJ
SPRITEb_Y:
	.res NOBJ
SPRITEb_A2:
	.res NOBJ
SPRITEb_A3:
	.res NOBJ
SPRITEb_SIZE:
	.res NOBJ
	
	.code
	.a8
	.i16
	
;--------------------------------------------------------------------------
Sprites_Reset:
;--------------------------------------------------------------------------
	stz	sprite_index_back
	stz	sprite_index_front
	stz	sprite_index_back+1
	stz	sprite_index_front+1
	rts

;===================================================================================
.macro ProcessBuffer xl, xh, a1, a2, a3, size, count, dest
;===================================================================================
	.local	@no_sprites
	.local	@loop, @loop2
;-----------------------------------------------------------------------------------
	ldx	count				; skip operation if count = 0
	beq	@no_sprites			;
;-----------------------------------------------------------------------------------
	lda	#^oam_table			; load target address (oam+base)
	sta	REG_WMADDH			;
	ldy	#.LOWORD(oam_table+dest*4)	;
	sty	REG_WMADDL			;
;-----------------------------------------------------------------------------------
	dex					; copy data from buffer
@loop:						;
	lda	xl, x				;
	sta	REG_WMDATA			;
	lda	a1, x				;
	sta	REG_WMDATA			;
	lda	a2, x				;
	sta	REG_WMDATA			;
	lda	a3, x				;
	sta	REG_WMDATA			;
	dex					;
	bpl	@loop				;
;-----------------------------------------------------------------------------------
	lda	#^oam_hitable			; load target HI address
	sta	REG_WMADDH			;
	ldx	#.LOWORD(oam_hitable+dest/4)	;
	stx	REG_WMADDL			;
;-----------------------------------------------------------------------------------
	ldx	count				; copy hi-data
	dex					;
	
;-----------------------------------------------------------------------------------
@loop2:						;
.repeat 4					;
	lsr	xh, x				; rotate 4*2 bits into a

	ror					;	
	lsr	size, x				;
	ror					;
	dex					;
.endrep						;
;-----------------------------------------------------------------------------------
	sta	REG_WMDATA			; write to table
	bpl	@loop2				;
;-----------------------------------------------------------------------------------
@no_sprites:
.endmacro
;-----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
.macro EraseSprites index, base
;-----------------------------------------------------------------------------------
	.local @quit
;-----------------------------------------------------------------------------------
	rep	#20h				; WMADDL = oam+base+index*4
	lda	index				;
	asl					;
	asl					;
	tay					;
;-----------------------------------------------------------------------------------
	lda	#NOBJ				; x = remaining sprite entries
	sec					;
	sbc	index				;
	beq	@quit				; quit if zero
	tax					;
;-----------------------------------------------------------------------------------
	sep	#20h
:	lda	#224				; set y = 224
	sta	oam_table+base*4+1, y		;
	iny					;
	iny					;
	iny					;
	iny					;
	dex					;
	bne	:-				;
;-----------------------------------------------------------------------------------
@quit:
.endmacro

;-----------------------------------------------------------------------------------
Sprites_Process:
;-----------------------------------------------------------------------------------

	ProcessBuffer SPRITEa_XL, SPRITEa_XH, SPRITEa_Y, SPRITEa_A2, SPRITEa_A3, SPRITEa_SIZE, sprite_index_front, 0
	ProcessBuffer SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE, sprite_index_back, (64+16)
	
	EraseSprites sprite_index_front, 0
	EraseSprites sprite_index_back, (64+16)
	
	jmp	Sprites_Reset
