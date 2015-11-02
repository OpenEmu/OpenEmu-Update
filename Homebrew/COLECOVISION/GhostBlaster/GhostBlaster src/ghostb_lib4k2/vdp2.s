; vdp2.s

	.module put_vram

    .globl  _put_vram
    ; put_vram (offset,ptr,count)
    
    .area _CODE
    
_put_vram:
    exx
    pop     hl
    exx
    pop     de
    pop     hl
    pop     bc
    push    bc
    push    hl
    push    de
    exx
    push    hl
    exx
    ; - Patch to fix a curious bug -
    ld      a,c
    or	a
    jp	z,0x1fdf
    inc	b
    ; - End Patch -
    jp	0x1fdf

