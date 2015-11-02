; sprites0.s

    .module update_sprites
    
    .globl  sprite_count
    .globl  _sprites

    .globl  _update_sprites
    ; update_sprites (byte numsprites,unsigned sprtab);

    .AREA   _CODE
_update_sprites:
    pop     hl
    pop     bc
    pop     de
    push    de
    push    bc
    push    hl
    ld      d,e
    ld      e,b
    ld      b,c
    ld      a,(0x1d43)
    ld      c,a
    di
    out     (c),e
    set     6,d
    out     (c),d
    ei
    ld      a,(0x1d47)
    ld      c,a
    ld      a,b
    ex      af,af'
    ld      b,#32
    ld      a,(sprite_count)
    ld      e,a
    ld      d,#0
sprites_loop:
    ld      hl,#_sprites
    add     hl,de
    ld      a,(hl)
    cp      #-16
    jr      nc,$1
    cp      #192
    jp      nc,$3
$1:  
    ld      a,(hl)
    inc     hl
    out     (c),a
    ld      a,(hl)
    inc     hl
    out     (c),a
    ld      a,(hl)
    inc     hl
    out     (c),a
    ld      a,(hl)
    and     #0x8f                   ; mask off unused bits so
    inc     hl                      ;  they can be used by the
    out     (c),a                   ;  program itself
    ex      af,af'
    dec     a
    jp      m,$9
    cp      #23
    jr      nz,$2
    ex      af,af'
    ld      a,e
    ld      (sprite_count),a
    ex      af,af'
$2:
    ex      af,af'
$3: 
    ld      a,e
    add     a,#4
    ld      e,a
    dec     b
    jp      nz,sprites_loop
    ld      a,#208
    out     (c),a
$9:  
    ret

