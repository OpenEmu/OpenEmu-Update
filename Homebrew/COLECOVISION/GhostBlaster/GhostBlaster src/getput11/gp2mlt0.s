; gpmlt0.s

	.module change_multicolor
	
	; global from external code	
        .globl  _change_multicolor_pattern

	; global from this code
        .globl  _change_multicolor
	;void change_multicolor(unsigned char c, void *color);
	
	.area _CODE

_change_multicolor:
                pop     bc
                pop     de
                pop     hl
                push    hl
                push    de
                push    bc
		
		ld	h,l
		ld	l,d

                ld	bc,#0x0001
                push    bc
                push    hl
                push    de
                call	_change_multicolor_pattern
                pop	bc
                pop	bc
                pop	bc

                ret
