; vdp5.s

	.module fill_vram0

    .globl  _fill_vram0
    ; fill_vram0 (offset,count, (byte)value)
    
    .area _CODE

_fill_vram0: 
    exx
    pop     hl
    exx
    pop     hl
    pop     de
    pop     bc
    push    bc
    push    de
    push    hl
    exx
    push    hl
    exx
    ld      a,c
    jp      0x1f82

