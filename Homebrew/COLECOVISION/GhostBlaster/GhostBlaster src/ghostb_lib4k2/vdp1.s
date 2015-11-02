; vdp1.s

	.module fill_vram

    .globl  _fill_vram
    ; fill_vram (offset,(byte)value,count)
    
    .area _CODE

_fill_vram: 
    exx
    pop     hl
    exx
    pop     hl
    pop     bc
    pop     de
    push    de
    push    bc
    push    hl
    exx
    push    hl
    exx
    ld      d,e
    ld      e,b
    ld      a,c
    jp      0x1f82

