PAD_A			equ $01
PAD_B			equ $02
PAD_SELECT		equ $04
PAD_START		equ $08
PAD_UP			equ $10
PAD_DOWN		equ $20
PAD_LEFT		equ $40
PAD_RIGHT		equ $80



padInit
	lda #0
	sta <PAD_STATE
	sta <PAD_STATEP
	sta <PAD_STATET
	rts

padPoll
	ldx #0
	jsr padPollPort
	jsr padPollPort
	jsr padPollPort

	lda <PAD_BUF
	cmp <PAD_BUF+1
	beq .done
	cmp <PAD_BUF+2
	beq .done
	lda <PAD_BUF+1
.done
	sta <PAD_STATE

	lda <PAD_STATE
	eor <PAD_STATEP
	and <PAD_STATE
	sta <PAD_STATET
	lda <PAD_STATE
	sta <PAD_STATEP

	rts

padPollPort
	ldy #$01
	sty CTRL_PORT1
	dey
	sty CTRL_PORT1
	ldy #8
.1
	lda CTRL_PORT1
	and #$01
	clc
	beq .2
	sec
.2
	ror <PAD_BUF,x
	dey
	bne .1

	inx
	rts
