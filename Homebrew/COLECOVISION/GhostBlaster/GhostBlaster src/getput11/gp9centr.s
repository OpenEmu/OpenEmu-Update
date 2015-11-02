; gp9centr.s

	.module center_string

	.globl  calc_offset, _strlen0

	.globl  _center_string 
	; center_string ((byte) y,char[])

	.AREA   _CODE

_center_string:
                pop     hl
                exx
                pop     de
                pop     hl
                push    hl
                push    de
                exx
                push    hl
                exx

		ld	h,l
		ld	l,d
		
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
