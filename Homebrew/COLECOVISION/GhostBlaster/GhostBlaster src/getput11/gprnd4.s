; gprnd4.s

	.module absdiff
	
	; global from external code	
    .globl  absdiff_max_min

	; global from this code
    .globl  _absdiff
    ; unsigned absdiff(unsigned A, unsigned B)
	
	.area _CODE
                
_absdiff:
		pop	bc
		pop	de
		pop	hl
		push	hl
		push	de
		push	bc

        jp  absdiff_max_min

