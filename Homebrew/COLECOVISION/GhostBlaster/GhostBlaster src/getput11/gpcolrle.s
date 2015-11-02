; gpcolrle.s

	.module load_colorrle
	
	; global from external code	
	.globl  _rle2vram

	; global from this code
        .globl  _load_colorrle
        ; load_colorrle(ptr)

	.area _CODE

_load_colorrle:
		pop	hl
		pop	de
		push	de
		push	hl

		ld      hl,(0x73FA)		    ; hl = offset

		push	hl
		push	de
		call	_rle2vram
		pop	de
		pop	hl
		ret
