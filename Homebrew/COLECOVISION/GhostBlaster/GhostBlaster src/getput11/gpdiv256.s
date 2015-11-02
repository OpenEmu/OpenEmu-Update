; gplascii.s

	.module load_ascii

	.globl  _intdiv256

	;  int or char intdiv256(int value)
	
	.AREA   _CODE
	
_intdiv256:
                pop	bc
                pop	hl
		push	hl
		push	bc
		ld	l,h
		bit	7,l
		jr	z,$1
		ld	h,#0xff
		ret
$1:
		ld	h,#0x00
		ret
