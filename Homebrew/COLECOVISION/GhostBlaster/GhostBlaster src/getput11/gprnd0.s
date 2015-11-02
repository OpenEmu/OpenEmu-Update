; gprnd0.s

	.module rnd
	
	; global from external code	
	.globl  absdiff_max_min
	.globl  rnd1

	; global from this code
	.globl  _rnd
	; unsigned rnd(unsigned A, unsigned B)
	
	.area _CODE
    
_rnd:
		pop	bc
		pop	de
		pop	hl
		push	hl
		push	de
		push	bc

					; HL = B, DE = A
		call	absdiff_max_min
					; HL = MAX-MIN, DE = MIN
		jp  rnd1


