; gp9filat.s

	.module fill_at
	
	.globl   calc_offset
	
	; global from this code	
	.globl  _fill_at
	; void fill_at (char x, char y, char c, unsigned size);
	
	.area _CODE

_fill_at:
		exx
                pop     hl
                exx
                pop     de ; d = y , e = x
                call	calc_offset	; de = offset
                pop     bc
                pop     hl
                push    hl
                push    bc
                push    de
                exx
                push    hl
                exx

		ld	h,l
		ld	l,b
		
                ex	de,hl	; hl = offset, de = counter
                ld      a,c	; character to copy
                jp      0x1f82

