; gp2chgs.s

	.module change_spattern
	
	.globl  _change_spattern
	; change_spattern(unsigned char s, void *pattern, unsigned char N);
	.area _CODE

_change_spattern:
                pop     bc
                pop     de
                pop     hl
                push    hl
                push    de
                push    bc
		
		ld	c,h
		ld	h,l
		ld	l,d
		
		push	hl

                ld	h,#0	; BC = 8*C (count)
                ld	l,c
                add	hl,hl
                add	hl,hl
                add	hl,hl
                ld	b,h
                ld	c,l

                ld	h,#7	; DE = 8*E + SPRTAB (offset)
                ld	l,e
                add	hl,hl
                add	hl,hl
                add	hl,hl
                ld	d,h
                ld	e,l

                pop     hl	; HL = ptr

                ld      a,c
                call    0x1FDF	; PUT_VRAM (COPY BC BYTES FROM HL (ROM) TO DE (VRAM))

                ret

