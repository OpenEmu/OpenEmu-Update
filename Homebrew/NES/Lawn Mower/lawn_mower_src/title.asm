TITLE_X0			equ $80	;word
TITLE_X1			equ $82	;word
TITLE_START			equ $84
TITLE_OFF			equ $85
TITLE_BUF			equ $86	;8 bytes
TITLE_DELAY_TOP		equ $8e
TITLE_DELAY_MIDDLE	equ $8f
TITLE_DELAY_BOTTOM	equ $90
TITLE_PAL_ANIM		equ $91


showTitle
	lda #0
	sta PPU_MASK

	ldx # LOW(titleNameTable)
	ldy #HIGH(titleNameTable)
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	jsr unrle

	ldy #4
.clear1
	ldx #0
	txa
.clear2
	sta PPU_DATA
	dex
	bne .clear2
	dey
	bne .clear1

	ldy #8
.clear3
	sta TITLE_BUF,x
	inx
	dey
	bne .clear3

	sty <TITLE_OFF
	sty <TITLE_X0
	sty <TITLE_START
	sty <TITLE_PAL_ANIM

	lda #1
	sta <TITLE_X0+1
	lda #8
	sta <TITLE_X1
	lda #255
	sta <TITLE_X1+1

	lda <GAME_NTSC
	beq .pal
	lda #10
	sta <TITLE_DELAY_TOP
	lda #210
	sta <TITLE_DELAY_MIDDLE
	sta <TITLE_DELAY_BOTTOM
	jmp .next
.pal
	lda #10
	sta <TITLE_DELAY_TOP
	lda #200
	sta <TITLE_DELAY_MIDDLE
	sta <TITLE_DELAY_BOTTOM
.next

	jsr clearOAM

	lda #26
	sta OAM_PAGE
	lda #$49
	sta OAM_PAGE+1
	lda #0
	sta OAM_PAGE+2
	lda #0
	sta OAM_PAGE+3

	ldx # LOW(bgm_title_module)
	ldy #HIGH(bgm_title_module)
	jsr FamiToneMusicStart

	jsr palReset
	ldx # LOW(palTitle)
	ldy #HIGH(palTitle)
	jsr palSetupBackground
	jsr palSetFadeIn

	jsr waitNMI
	lda #%00011110	;enable display, enable sprites
	sta PPU_MASK
	lda #$80
	sta PPU_CTRL
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

.loop
	jsr waitNMI
	jsr updateOAM
	jsr palUpdate
	jsr resetPPUAdr

	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	jsr waitSprite0

	lda <TITLE_X0+1
	and #$01
	ora #$80
	sta PPU_CTRL
	lda <TITLE_X0
	sta PPU_SCROLL
	lda #0
	sta PPU_SCROLL

	jsr delayMiddle

	lda <TITLE_X1+1
	and #$01
	ora #$80
	sta PPU_CTRL
	lda <TITLE_X1
	sta PPU_SCROLL
	lda #0
	sta PPU_SCROLL

	jsr delayMiddle

	lda <FRAME_CNT
	lsr a
	lsr a
	ldx <TITLE_START
	bne .fast
	lsr a
	lsr a
	lsr a
.fast
	and #1
	ora #$80
	sta PPU_CTRL
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	jsr delayBottom

	lda #$80
	sta PPU_CTRL

	jsr FamiToneUpdate

	jsr ntscIsSkip
	bcc .noSkip
	jmp .loop
.noSkip

	ldx <TITLE_X0
	lda <TITLE_X0+1
	cpx #4
	bne .scroll0
	and #1
	beq .scroll1
.scroll0
	inc <TITLE_X0
	bne .scroll1
	inc <TITLE_X0+1
.scroll1
	ldx <TITLE_X1
	lda <TITLE_X1+1
	cpx #4
	bne .scroll2
	and #1
	beq .scroll3
.scroll2
	dec <TITLE_X1
	lda <TITLE_X1
	cmp #$ff
	bne .scroll3
	dec <TITLE_X1+1
.scroll3

	lda <TITLE_X0
	cmp #$04
	bne .noPalAnim
	lda <TITLE_X1
	cmp #$04
	bne .noPalAnim
	lda <TITLE_X0+1
	cmp #$02
	bne .noPalAnim
	lda <TITLE_X1+1
	cmp #$fe
	bne .noPalAnim
	lda <TITLE_PAL_ANIM
	and #$fe
	asl a
	tax
	lda titleColorAnimation,x
	sta PAL_DATA+2
	lda titleColorAnimation+1,x
	sta PAL_DATA+3
	lda titleColorAnimation+2,x
	sta PAL_DATA+6
	lda titleColorAnimation+3,x
	sta PAL_DATA+7
	lda <TITLE_PAL_ANIM
	cmp #14
	bcs .noPalAnim
	inc <TITLE_PAL_ANIM
.noPalAnim

	lda <TITLE_START
	beq .noStart
	inc <TITLE_START
	lda <TITLE_START
	cmp #50
	beq .exit
	cmp #50-16
	bne .noFade
	jsr palSetFadeOut
.noFade
	jmp .loop

.noStart
	jsr rand
	jsr padPoll
	lda <PAD_STATET
	and #PAD_START
	bne .start
	lda <PAD_STATET
	and #(PAD_LEFT|PAD_RIGHT|PAD_UP|PAD_RIGHT)
	beq .skip
	ldx <TITLE_OFF
	sta TITLE_BUF,x
	sta TITLE_BUF+4,x
	inx
	txa
	and #3
	sta <TITLE_OFF
	tax
	lda TITLE_BUF,x
	cmp #PAD_RIGHT
	bne .skip
	lda TITLE_BUF+1,x
	cmp #PAD_UP
	bne .skip
	lda TITLE_BUF+2,x
	cmp #PAD_LEFT
	bne .skip
	lda TITLE_BUF+3,x
	cmp #PAD_LEFT
	bne .skip
	lda #SFX_SKIP
	jsr sfxPlay
	lda #1
	sta <GAME_LSKIP
.skip
	jmp .loop

.start
	lda #1
	sta <TITLE_START
	lda #$04
	sta <TITLE_X0
	sta <TITLE_X1
	lda #$02
	sta <TITLE_X0+1
	lda #$fe
	sta <TITLE_X1+1
	lda #SFX_START
	jsr sfxPlay
	jsr FamiToneMusicStop
	jmp .loop

.exit
	lda #0
	sta PPU_MASK
	rts


delayTop
	ldy <TITLE_DELAY_TOP
	ldx #50
.delay0
	tay
.delay1
	dey
	bne .delay1
	dex
	bne .delay0
	rts


delayMiddle
	ldx <TITLE_DELAY_MIDDLE
.delay0
	ldy #6
.delay1
	dey
	bne .delay1
	dex
	bne .delay0
	rts


delayBottom
	ldx <TITLE_DELAY_BOTTOM
.delay0
	nop
	nop
	nop
	nop
	dex
	bne .delay0
	rts


titleNameTable
	.incbin "title.rle"

titleColorAnimation
	.db $38,$37,$26,$37
	.db $37,$20,$27,$20
	.db $20,$30,$37,$30
	.db $30,$30,$30,$30
	.db $20,$30,$37,$30
	.db $37,$20,$27,$20
	.db $38,$37,$26,$37
	.db $28,$39,$16,$38