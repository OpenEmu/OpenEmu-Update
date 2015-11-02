; gplascii.s

	.module fill_color

	.globl  _fill_color
	; fill_color ((byte)char,(byte)value,(byte)count)
	
	.AREA   _CODE
	
_fill_color:
                pop     de
                pop     bc
                pop     hl
                push    hl
                push    bc
                push    de
                push    bc
		ld	h,#0	; hl = 0 to 255
                add	hl,hl
                add	hl,hl
                add	hl,hl
                ld	d,h
                ld	e,l
                pop	hl
		ld	a,h
                ld	h,#4
                add	hl,hl
                add	hl,hl
                add	hl,hl
                call    0x1F82
                ret

