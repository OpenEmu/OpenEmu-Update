; gp2chgs0.s

	.module change_spattern
	
	.globl  _change_spattern0
	; change_spattern0 (void *pattern, unsigned char s, unsigned char N);
	.area _CODE

_change_spattern0:
                pop     bc
                pop     hl
                pop     de
                push    de
                push    hl
                push    bc
		
		push	hl

                ld	h,#0	; BC = 8*C (count)
                ld	l,d
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

