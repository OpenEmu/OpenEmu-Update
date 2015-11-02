; gplascii.s

	.module load_ascii

	.globl  _rle2vram

	.globl  _load_spatternrle
	; load_spatternrle(ptr)

	.AREA   _CODE

_load_spatternrle:
		pop	hl
		pop	de
		push	de
		push	hl

		ld      hl,(0x73F4)		    ; hl = offset = SPRTAB

		push	hl
		push	de
		call	_rle2vram
		pop	de
		pop	hl
		ret
