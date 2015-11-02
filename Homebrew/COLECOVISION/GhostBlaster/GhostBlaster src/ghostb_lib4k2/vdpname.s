; vdpname.s

	.module default_name_table

    .globl  _set_default_name_table
    ; set_default_name_table (unsigned offset)
    
    .area _CODE
    
_set_default_name_table:
    pop     hl
    pop     de
    push    de
    push    hl
    ld      a,(0x1d43)
    ld      c,a  ;; (1d43h) = 0bfh
    di
    out     (c),e
    set     6,d
    out     (c),d
    ei
    ld      a,(0x1d47)
    ld      c,a  ;; (1d47h) = 0beh
    ld      d,#3
$1:
    xor     a
$2:
    out     (c),a
    nop
    inc     a
    jp      nz,$2
    dec     d
    jp      nz,$1
    ret
