; gp9fila0.s

	.module fill_at0
	
	.globl   calc_offset
	
	; global from this code	
	.globl  _fill_at0
	; void fill_at0 (char x, char y, unsigned size, char c);
	
	.area _CODE

_fill_at0:
		exx
                pop     hl
                exx
                pop     de ; d = y , e = x
                call	calc_offset	; de = offset
                pop     hl
                pop     bc
                push    bc
                push    hl
                push    de
                exx
                push    hl
                exx

                ex	de,hl	; hl = offset, de = counter
                ld      a,c	; character to copy
                jp      0x1f82

