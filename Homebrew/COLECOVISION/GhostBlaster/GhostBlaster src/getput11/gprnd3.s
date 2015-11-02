; gprnd3.s

	.module absdiff_byte
	
	; global from external code	
    .globl  absdiff_max_min

	; global from this code
    .globl  _absdiff_byte
    ; byte absdiff_byte(byte A, byte B)
	
	.area _CODE
    
_absdiff_byte:
		pop	hl
		pop	de
		push	de
		push	hl
		
		ld	l,d
		xor	a
		ld	h,a
		ld	d,a
		
		jp	absdiff_max_min


