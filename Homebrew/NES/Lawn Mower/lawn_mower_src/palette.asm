PAL_FADE_NONE	equ 0
PAL_FADE_IN		equ 1
PAL_FADE_OUT	equ 2


palReset
	lda #$3f
	sta PPU_ADDR
	ldx #$00
	stx PPU_ADDR
	lda #$0f
.1
	sta PPU_DATA
	sta PAL_DATA,x
	inx
	cpx #32
	bne .1

	lda #PAL_FADE_NONE
	sta <PAL_MODE
	lda #192
	sta <PAL_BRIGHT
	rts


palSetupBackground
	lda #0
	beq palSetup
palSetupSprites
	lda #16
palSetup
	stx <TEMP
	sty <TEMP+1
	tax
	ldy #0
.1
	lda [TEMP],y
	sta PAL_DATA,x
	iny
	inx
	cpy #16
	bne .1
	rts


palSetFadeIn
	lda #PAL_FADE_IN
	sta <PAL_MODE
	rts


palSetFadeOut
	lda #PAL_FADE_OUT
	sta <PAL_MODE
	rts


palSetFadeHalf
	lda #PAL_FADE_NONE
	sta <PAL_MODE
	lda #64
	sta <PAL_BRIGHT
	rts


palUpdate
	ldx #$00
	ldy #$00
	lda <FRAME_CNT
	and #1
	beq .1
	ldx #$10
	ldy #$12
.1
	lda #$3f
	sta PPU_ADDR
	sty PPU_ADDR

	lda <PAL_BRIGHT
	clc
	adc # LOW(palBrightTable)
	sta <TEMP
	lda #0
	adc #HIGH(palBrightTable)
	sta <TEMP+1
	
	cpx #$10
	beq .skip2spr
	
	lda PAL_DATA,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;0
	lda PAL_DATA+1,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;1
.skip2spr
	lda PAL_DATA+2,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;2
	lda PAL_DATA+3,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;3
	lda PPU_DATA			;skip 4
	lda PAL_DATA+5,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;5
	lda PAL_DATA+6,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;6
	lda PAL_DATA+7,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;7
	lda PPU_DATA			;skip 8
	lda PAL_DATA+9,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;9
	lda PAL_DATA+10,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;10
	lda PAL_DATA+11,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;11
	lda PPU_DATA			;skip 12
	lda PAL_DATA+13,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;13
	lda PAL_DATA+14,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;14
	lda PAL_DATA+15,x
	tay
	lda [TEMP],y
	sta PPU_DATA			;15

	cpx #0
	bne .noSpr
	lda #$3f				;always update sprite 0 color with background
	sta PPU_ADDR
	lda #$11
	sta PPU_ADDR
	lda PAL_DATA+1
	tay
	lda [TEMP],y
	sta PPU_DATA
.noSpr

	lda <FRAME_CNT
	and #3
	beq .fade
	rts
.fade

	lda <PAL_MODE
	cmp #PAL_FADE_IN
	beq .fadeIn
	cmp #PAL_FADE_OUT
	beq .fadeOut
	rts
.fadeOut
	lda <PAL_BRIGHT
	cmp #192
	beq .done
	clc
	adc #64
	jmp .done
.fadeIn
	lda <PAL_BRIGHT
	beq .done
	clc
	adc #-64
.done
	sta <PAL_BRIGHT
	rts



palBrightTable
	.db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0f,$0e,$0f
	.db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1f,$1e,$1f
	.db $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	.db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0f,$0e,$0f
	.db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1f,$1e,$1f
	.db $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0f,$0e,$0f
	.db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1f,$1e,$1f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	.db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0f,$0e,$0f

palTitle
	.db $0f,$0b,$28,$39,$0f,$0b,$16,$38,$0f,$0b,$1a,$29,$0f,$0b,$29,$30

palGameSprites
	.db $0f,$11,$27,$20,$0f,$2a,$39,$16,$0f,$06,$27,$37,$0f,$0f,$00,$30

palGame
	.db $0f,$11,$21,$30,$0f,$0a,$38,$25,$0f,$0a,$1a,$29,$0f,$0a,$10,$20

palDone
	.db $0f,$0a,$34,$17,$0f,$0a,$37,$27,$0f,$0a,$1a,$29,$0f,$0a,$37,$22