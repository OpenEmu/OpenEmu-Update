; vdppat1.s

    .globl  _buffer32

    .module duplicate_pattern
    
    .globl  _duplicate_pattern
    ; duplicate_pattern();
    
    .area _CODE
    
_duplicate_pattern:

    ld      bc,(0x73C4)
    ld      b,#1
    push    bc
    
    ld      c,#0x80      ; vdp_out(1,c0h)
    call    0x1FD9         ; BLACK OUT NO INTERUPT 

    ld      hl,(0x73F8)
    ld      b,#128

loop_nbr:
    push    bc
    
    ld      a,l
    out     (0xBF),a
    ld      a,h
    out     (0xBF),a
    push    hl
    
    ld      bc,#0x20BE
    ld      hl,#_buffer32
    inir
    
    pop     hl
    ld      de,#0x4800
    add     hl,de
    ld      a,l
    out     (0xBF),a
    ld      a,h
    out     (0xBF),a
    ld      de,#0xB820
    add     hl,de
    push    hl
    
    ld      bc,#0x20BE
    ld      hl,#_buffer32
    otir
    
    pop     hl
    pop     bc
    djnz    loop_nbr
    
    pop     bc
    call    0x1FD9
    
    ret
