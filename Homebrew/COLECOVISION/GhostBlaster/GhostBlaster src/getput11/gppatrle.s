; gppatrle.s

		.module load_patternrle

                .globl  _rle2vram		; from Coleco lib

                .globl  _load_patternrle
                ; load_patternrle(ptr)

    .AREA   _CODE

_load_patternrle:
		pop	hl
		pop	de
		push	de
		push	hl
		ld      hl,(0x73F8)	; hl = offset = PATTERN
		push	hl
		push	de
		call	_rle2vram
		pop	de
		pop	hl
		ret
