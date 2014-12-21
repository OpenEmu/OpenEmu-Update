
.include "snes.inc"
.include "snes_zvars.inc"

	.export DMAtoVRAM, DMAtoRAM

	.segment "XCODE"
	.a8
	.i16

;******************************************************************************
; copy data to vram with DMA
;	
; a,y = ROM address
; x = VRAM address (words!)
; m0 = size (bytes)
;******************************************************************************
DMAtoVRAM:
;------------------------------------------------------------------------------
	sta	REG_A1B7		; set transfer source
	sty	REG_A1T7L		;--------------------------------------
	stx	REG_VMADDL		; set vram address
;------------------------------------------------------------------------------
	lda	#80h			; increment when writing higher byte
	sta	REG_VMAIN		;--------------------------------------
	ldx	m0			; set transfer size
	stx	REG_DAS7L		;--------------------------------------
	lda	#<REG_VMDATAL		; destination = vram
	sta	REG_BBAD7		;--------------------------------------
	lda	#%001			; setup control (2 regs write once)	
	sta	REG_DMAP7		;
	lda	#1<<7			;
	sta	REG_MDMAEN		; start transfer
;------------------------------------------------------------------------------
	rts

;******************************************************************************
; copy data to RAM with DMA
;	
; a,y = ROM address
; x = size (bytes)
; WMADD = target
;******************************************************************************
DMAtoRAM:
;------------------------------------------------------------------------------
	sta	REG_A1B7
	sty	REG_A1T7
	
	stx	REG_DAS7L		; set transfer size
	lda	#<REG_WMDATA		; target = WRAM
	sta	REG_BBAD7		;
	lda	#%000			; control (1 reg write once)	
	sta	REG_DMAP7		;
	lda	#1<<7			;
	sta	REG_MDMAEN		; start transfer
;------------------------------------------------------------------------------
	rts
