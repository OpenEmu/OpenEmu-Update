; gp2color0.s

	.module change_color
	
	.globl  change_color0
	;void change_color0(void *color, unsigned char c, unsigned char l);

	.area _CODE
	
_change_color0:
                pop     bc
                pop     hl
                pop     de
                push    de
                push    hl
                push    bc
		
                push    hl

                ld	b,d	; B = counter

                ld	h,#4	; DE = 8*E + COLTAB (offset)
                ld	l,e
                add	hl,hl
                add	hl,hl
                add	hl,hl

                di
                ld	a,l
                out	(0xBF),a
                ld	a,h
                or	#0x40
                out	(0xBF),a	; SET VIDEO ADDR
                ei

                pop     hl	; HL = ptr

                ld	c,#0xBE
$1:
		ld	d,(hl)
                ld      a,#8
$2:
		out	(c),d 	; SEND DATA TO VIDEO
                dec	a
                or	a
                jr	nz,$2
                inc	hl
                dec	b
                ld      a,b
                or      a
                jr	nz,$1

                call	0x1FDC	; get vdp status

                ret