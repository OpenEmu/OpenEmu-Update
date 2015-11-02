; gpfram0.s

	.module put_frame
	
	; global from this code	
	.globl  _put_frame
        ; put_frame (void *table, byte x, byte y, byte width, byte height)

	.area _CODE
	
_put_frame:
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
		push ix
		push iy
		call	0x080b
		pop	iy
		pop	ix
		ret
		
