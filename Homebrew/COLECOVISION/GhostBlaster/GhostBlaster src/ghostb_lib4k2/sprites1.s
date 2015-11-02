; sprites1.s

    .module clear_sprites
    
    .globl  sprite_count
    .globl  _sprites

    .globl  _clear_sprites
    ; clear_sprites (byte first,byte count)

    .AREA   _CODE
_clear_sprites: 
    pop     bc
    pop     hl
    push    hl
    push    bc
    ld      e,h
    ld      h,#0
    add     hl,hl
    add     hl,hl
    ld      bc,#_sprites
    add     hl,bc
    ld      bc,#4
$1:
    dec     e
    ret     m
    ld      (hl),#207
    add     hl,bc
    jr      $1
    ret

