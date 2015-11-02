; vdp3.s

	.module get_vram

    .globl  _get_vram
    ; get_vram (offset,ptr,count)
    
    .area _CODE
_get_vram:
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
    jp	z,0x1fe2
    inc	b
    ; - End Patch -
    jp	0x1fe2

