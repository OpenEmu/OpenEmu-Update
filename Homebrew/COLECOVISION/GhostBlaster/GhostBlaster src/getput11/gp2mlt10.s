; gpmlt10.s

	.module change_multicolor

	; global from external code
        .globl  _put_vram_pattern

	; global from this code
        .globl  _change_multicolor_pattern0

	;void change_multicolor_pattern0(void *color, unsigned char c, unsigned char n);
	
	.area _CODE

_change_multicolor_pattern0:
                pop     bc
                pop     hl
                pop     de
                push    de
                push    hl
                push    bc
		
		ld	c,d
		
                push    hl

                ld      hl,(0x73FA)		    ; hl = offset = COLTAB

                xor	a
                ld	b,a	; BC = C (count)
                ld	d,a	; DE = char
                
                ex	de,hl

                add	hl,hl
                add	hl,hl
                add	hl,hl
                add	hl,de
                
                ld	a,h
                or 	#0x40
                ld 	h,a

                ex	de,hl

                pop	hl	; HL = ptr

                push	bc	; counter
                ld	bc,#0x0008
                push    bc	; pattern size = 8
                push    hl	; pattern ptr
                push    de	; offset

                call    _put_vram_pattern

                pop	bc
                pop	bc
                pop	bc
                pop	bc

                ret
