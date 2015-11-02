; gprnd1.s

	.module rnd_byte
	
	; global from external code	
	.globl  absdiff_max_min
	.globl  rnd1

	; global from this code
	.globl  _rnd_byte
	; byte rnd_byte(byte A, byte B)
	
	.area _CODE
_rnd_byte:
		pop	hl
		pop	de
		push	de
		push	hl
		
		ld	l,d
		xor	a
		ld	h,a
		ld	d,a
					; HL = B, DE = A
		call	absdiff_max_min
		jp	rnd1		; continue in rnd function and RET


