; gpfram1.s

	.module get_bkgrnd
	
	; global from this code
	.globl  _get_bkgrnd
	; get_bkgrnd (void *table, byte x, byte y, byte width, byte height)
	
	.area _CODE

_get_bkgrnd:
		exx
		pop	hl
		exx
		pop	hl
		pop	de
		pop	bc
		push	bc
		push	de
		push	hl
		exx
		push	hl
		exx
		push	ix
		push	iy
		call	0x0898
		pop	iy
		pop	ix
		ret

