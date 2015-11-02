; gppaper.s

	.module paper
	
	.globl  _paper
	; void paper(byte color)

	.area _CODE

_paper:
		pop	hl
		pop	bc
		push	bc
		push	hl
		ld	b,#7
		jp	0x1FD9
