.ifndef __SPRITES_INC
__SPRITES_INC = 1

	.import Sprites_Reset
	.import Sprites_Process
	
	.import SPRITEa_XL, SPRITEa_XH, SPRITEa_Y, SPRITEa_A2, SPRITEa_A3, SPRITEa_SIZE
	.import SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE
	
	.importzp sprite_index_front, sprite_index_back
	
.macro i_AS16 xl, xh, a1, a2, a3, size, index
	phx
	ldx	index
	sta	a1, x
	tya
	sta	a2, x
	xba
	sta	a3, x
	pla
	sta	xl, x
	pla
	sta	xh, x
	lda	#0
	sta	size, x
	inc	index
.endmacro

.macro i_AS16c xl, xh, a1, a2, a3, size, index, va2, va3
	ldx	index
	sta	a1, x
	lda	#va2
	sta	a2, x
	lda	#va3
	sta	a3, x
	rep	#20h
	tya
	sep	#20h
	sta	xl, x
	xba
	sta	xh, x
	lda	#0
	sta	size, x
	inc	index
.endmacro

.macro i_AS32c xl, xh, a1, a2, a3, size, index, va2, va3
	ldx	index
	sta	a1, x
	lda	#va2
	sta	a2, x
	lda	#va3
	sta	a3, x
	rep	#20h
	tya
	sep	#20h
	sta	xl, x
	xba
	sta	xh, x
	lda	#1
	sta	size, x
	inc	index
.endmacro
	
; x = X
; a = Y
; b = A3
; y = character
.macro AddSprite16f
	i_AS16 SPRITEa_XL, SPRITEa_XH, SPRITEa_Y, SPRITEa_A2, SPRITEa_A3, SPRITEa_SIZE, sprite_index_front
.endmacro

; x = X
; a = Y
; b = A3
; y = character
.macro AddSprite16b
	i_AS16 SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE, sprite_index_back
.endmacro

; y = X
; a = Y
.macro AddSprite16fc a2, a3
	i_AS16c SPRITEa_XL, SPRITEa_XH, SPRITEa_Y, SPRITEa_A2, SPRITEa_A3, SPRITEa_SIZE, sprite_index_front, a2, a3
.endmacro

; y = X
; a = Y
.macro AddSprite16bc a2, a3
	i_AS16c SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE, sprite_index_back, a2, a3
.endmacro

; y = X
; a = Y
.macro AddSprite32bc a2, a3
	i_AS32c SPRITEb_XL, SPRITEb_XH, SPRITEb_Y, SPRITEb_A2, SPRITEb_A3, SPRITEb_SIZE, sprite_index_back, a2, a3
.endmacro

.endif
