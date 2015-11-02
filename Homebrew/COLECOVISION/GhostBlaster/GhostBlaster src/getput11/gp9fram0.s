; gp9fram0.s

	.module put_frame0
	
	.globl   calc_offset
	
	; global from this code	
	.globl  _put_frame0
	; put_frame0 (void *table, byte x, byte y, byte width, byte height)
	
	.area _CODE
	
_put_frame0:
		exx
		pop	hl
		exx
		pop	hl
		pop	de
		call	calc_offset
		pop	bc
		push	bc
		push	de
		push	hl
		exx
		push	hl
		exx
loop:
		push	bc
		push	de
		push	hl
		ld	b,#0
		xor	a
		call	0x1fdf
		pop	hl
		pop	de
		pop	bc
		push	bc
		ld	b,#0
		add	hl,bc
		ex	de,hl
		ld	bc,#0x0020
		add	hl,bc
		ex	de,hl
		pop	bc
		dec	b
		ld	a,b
		jr	nz,loop
		ret

