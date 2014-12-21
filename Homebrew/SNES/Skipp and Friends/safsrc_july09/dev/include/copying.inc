.ifndef COPYING_INC
COPYING_INC=1

;******************************************************************************
; copy data to vram with DMA
;	
; a,y = ROM address
; x = VRAM address (words!)
; m0 = size (bytes)
;******************************************************************************
	.import DMAtoVRAM

;******************************************************************************
; copy data to RAM with DMA
;	
; a,y = ROM address
; x = size (bytes)
; WMADD = target
;******************************************************************************
	.import DMAtoRAM
.endif
