; vdp4.s

	.module vdp_out0

    .globl  _vdp_out0
    ; void vdp_out0 (byte val,byte reg);
    
    .area _CODE
    
_vdp_out0:
    pop     hl
    pop     bc
    push    bc
    push    hl
    jp      0x1fd9

