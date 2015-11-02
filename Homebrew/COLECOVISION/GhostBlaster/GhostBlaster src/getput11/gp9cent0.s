; gp9cent0.s

	.module center_string

	.globl  calc_offset, _strlen0

	.globl  _center_string0 
	; center_string (char[],(byte) y)

	.AREA   _CODE

_center_string0:
                pop     hl
                exx
                pop     hl
                pop     de
                push    de
                push    hl
                exx
                push    hl
                exx

                push    de	;	y coord.
		
                push    hl	;	hl = pointer
                call	_strlen0
                push    hl	;	bc = count

                ld	b,#0
                ld	c,l
                srl	c
                ld	a,#0x10
                sub	c	;     a = x coord.
                pop     bc	;	bc
                pop     hl	;	hl
                pop     de	;	y coord.
                ld	d,e
                ld	e,a
                call	calc_offset	;	de = offset (y*32 + x)
                ld      a,c
                jp      0x1FDF
