; vdp0.s

	.module vdp_out

    .globl  _vdp_out
    ; void vdp_out (byte reg,byte val);
    
    .area _CODE
    
_vdp_out:
    pop     hl
    pop     de
    push    de
    push    hl
    ld b,e
    ld c,d
    jp      0x1fd9

