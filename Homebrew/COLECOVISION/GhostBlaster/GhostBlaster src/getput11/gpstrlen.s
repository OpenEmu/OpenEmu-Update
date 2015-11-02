; gpstrlen.s

	.module strlen0

	.globl  _strlen0
	; strlen0 (char [])

	.AREA   _CODE

_strlen0:
		pop	hl
		pop	de
		push	de
		push	hl
		ld	hl,#0x0000
$1:		ld	a,(de)
		or	a
		ret	z
		inc	hl
		inc	de
		jr	$1
