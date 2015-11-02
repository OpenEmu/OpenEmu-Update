; sprites2.s

    .module sprite_tables
    
    .globl  sprite_count
    .globl  _sprites
    
    .AREA   _DATA
sprite_count:
    .ds    1
_sprites:
    .ds    128

