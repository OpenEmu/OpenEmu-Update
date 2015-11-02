; gpnamrle.s

	.module load_namerle
	
	; global from external code	
	.globl  _rle2vram

	; global from this code
	.globl  _load_namerle
	; load_namerle(ptr)

	.area _CODE

_load_namerle:
		pop	hl
		pop	de
		push	de
		push	hl
		ld	hl,(0x73F6)
		push	hl
		push	de
		call	_rle2vram
		pop	de
		pop	hl
		ret
