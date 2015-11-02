; gp9print.s

	.module print_at

	.globl  calc_offset, _strlen0

	.globl  _print_at
	; print_at ((byte)x,(byte)y,*char)

	.AREA   _CODE

_print_at:
                pop     bc
                pop     de
                call	calc_offset	; de = offset
                pop     hl
                push    hl
                push    de
                push    bc

                push    de
                push    hl
		
                call	_strlen0

                ld	b,#0
                ld	c,l	; bc = count
                pop     hl	; hl = pointer
                pop     de   	; de = offset
                ld      a,c
                jp      0x1FdF

