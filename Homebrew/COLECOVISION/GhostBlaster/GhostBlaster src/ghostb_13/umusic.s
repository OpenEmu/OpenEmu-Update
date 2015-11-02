; Autor : Daniel Bienvenu
; Game : GhostBlaster
; Year : 2009

        .area _DATA
        
;sound_no: .ds 1

        .area _CODE
        
    .globl      _mute_all
    .globl      stop_sound
    
    .globl      _counter
    
    ;;  void update_music(void);
    .globl      _update_music

_update_music:
    ld  de,(#_counter)
    inc de
    ld  (#_counter),de
    ld  a,e
    sub #0x0d
    and #0x0f
    jp  nz, case_C_1_ELSE
; CASE D
    ld  a,d
    sub #0x0c
    jp  z, try_0C7D
    jp  nc, try_0E6D
    ld  a,d
    sub #0x02
    ret c
    jp  nz, try_04BD
    ld  a,e
    sub #0xcd
    ret nz
                ; case    717:    //  02 CD
    ld  b,#7
    call    startsound
                    ; play_sound(7);
    ld  b,#8
    call    startsound
                    ; play_sound(8);
    ld  b,#9
    call    startsound
                    ; play_sound(9);
    ld  e,#6
    jp  stop_sound
                    ; stop_sound(6);
                    ; break;
try_04BD:
    sub #0x02
    ret c
    jp  nz, try_06AD
    ld  a,e
    sub #0xbd
    ret nz
                ; case    1213:   //   04 BD
    ld  b,#10
    call    startsound
                    ; play_sound(10);
                    ; //play_sound(9);
    ld  b,#11
    jp      startsound
                    ; play_sound(11);
                    ; break;
try_06AD:
    sub #0x02
    ret c
    jp  nz, try_089D
    ld  a,e
    sub #0xad
    ret nz
                ; case    1709:   //   06 AD
    ld  b,#12
    call    startsound
                    ; play_sound(12);
    ld  b,#9
    call    startsound
                    ; play_sound(9);
    ld  e,#11
    jp      stop_sound
                    ; stop_sound(11);
                    ; break;
try_089D:
    sub #0x02
    ret c
    jp  nz, try_0A8D
    ld  a,e
    sub #0x9d
    ret nz
                ; case    2205:   //  08 9D
    ld  b,#8
    call    startsound
                    ; play_sound(8); //play_sound(13);
    ld  b,#13
    jp    startsound
                    ; play_sound(13);
                    ; break;
try_0A8D:
    sub #0x02
    ret c
    ret nz
    ld  a,e
    sub #0x8d
    ret nz
                ; case    2701:   //  0A 8D
    ld  b,#14
    call    startsound
                    ; play_sound(14);
    ld  b,#15
    call    startsound
                    ; play_sound(15);
    ld  b,#16
    jp      startsound
                    ; play_sound(16);
                    ; break;
try_0C7D:
    ld  a,e
    sub #0x7d
    ret nz
                ; case    3197:   //  0C 7D
    ld  b,#17
    call    startsound
                    ; play_sound(17);
    ld  b,#18
    call    startsound
                    ; play_sound(18);
    ld  b,#19
    jp    startsound
                    ; play_sound(19);
                    ; break;
try_0E6D:
    sub #2
    ret c
    jp  nz, try_105D
    ld  a,e
    sub #0x6d
    ret nz
                ; case    3693:   //  0E 6D
    ld  b,#7
    call    startsound
                    ; play_sound(7);
    ld  b,#8
    call    startsound
                    ; play_sound(8); //play_sound(20);
    ld  b,#9
    call    startsound
                    ; play_sound(9);
    ld  b,#20
    jp      startsound
                    ; play_sound(20);
                    ; break;
try_105D:
    sub #2
    ret c
    jp  nz, try_124D
    ld  a,e
    sub #0x5d
    ret nz
                ; case    4189:   //  10 5D
    call    _mute_all
                    ; mute_all();
    ld  b,#9
    call    startsound
                    ; play_sound(9);
    ld  b,#14
    call    startsound
                    ; play_sound(14);
    ld  b,#15
    jp      startsound
                    ; play_sound(15);
                    ; break;
try_124D:
    sub #2
    ret c
    jp  nz, try_143D
    ld  a,e
    sub #0x4d
    ret nz
                ; case    4685:   //  12 4D
    ld  b,#13
    jp      startsound
                    ; play_sound(13);
                    ; break;
try_143D:
    sub #2
    ret nz
    ld  a,e
    sub #0x3d
    ret c
    jp  nz, try_14AD
                ; case    5181:   //  14 3D
    call    _mute_all
                    ; mute_all();
    ld  b,#29
    jp      startsound
                    ; play_sound(29);
                    ; break;
try_14AD:
    sub #0x70
    ret nz
                ; case    5293:   //  14 AD
    call    _mute_all
                    ; mute_all();
    ld  b,#30
    call    startsound
                    ; play_sound(30);
    ld  b,#31
    jp      startsound
                    ; play_sound(31);
                    ; break;

case_C_1_ELSE:
    sub #0x0f
    jp  nz, case_1_ELSE
; CASE C
    ld  a,d
    sub #0x10
    ret c
    jp  nz, try_143C
    ld  a,e
    sub #0x5c
    ret  nz
                ; case    4188:   //  10 5C
        ld  de,#1708
        ld  (#_counter),de
                    ; counter = 1708;
        ret
                    ; break;
try_143C:
    sub #0x04
    ret  c
    jp  nz, try_183C
    ld  a,e
    sub #0x3C
    ret c
    jp  nz, try_14AC
                ; case    5180:   //  14 3C
        ld  de,#4188
        ld  (#_counter),de
                    ; counter = 4188;
        ret
                    ; break;
try_14AC:
    sub #0x70
    ret c
    ret nz
                ; case    5292:   //  14 AC
        ld  de,#4188
        ld  (#_counter),de
                    ; counter = 4188;
        ret
                    ; break;
try_183C:
    sub #0x04
    ret  c
    ret  nz
                ; case    6204:   //  18 3C
        ld  de,#0000
        ld  (#_counter),de
                    ; counter = 0;
    ret
                    ; break;
    
case_1_ELSE:
    add a,#0x0b
    ret  nz
; CASE 1
    ld  a,e
    sub #0x01
    jp  nz, try_61
    ld  a,d
    or  a
    ret  nz
                ; case    1:      //  00 01
    call    _mute_all
                    ; mute_all();
    ld  b,#1
    call    startsound
                    ; play_sound(1);
    ld  b,#2
    jp    startsound
                    ; play_sound(2);
                    ; break;
try_61:
    sub #0x60
    ret  nz
    ld  a,d
    or  a
    ret  nz
                ; case    97:     //  00 61
    ld  b,#3
    call    startsound
                    ; play_sound(3);
    ld  b,#4
    call    startsound
                    ; play_sound(4);
    ld  b,#5
    call    startsound
                    ; play_sound(5);
    ld  b,#6
    jp    startsound
                    ; play_sound(6);
                    ; break;
; CASE ELSE
;case_ELSE:
;ret
; void update_music(void) {
    ; counter++;
    ; if (counter<2701)
    ; {
        ; if (counter<1213)
        ; {
            ; switch (counter)
            ; {

                ; case    717:    //  02 CD
                    ; play_sound(7);
                    ; play_sound(8);
                    ; play_sound(9);
                    ; stop_sound(6);
                    ; break;
            ; }
        ; }
        ; else
        ; {
            ; switch (counter)
            ; {
                ; case    1213:   //   04 BD
                    ; play_sound(10);
                    ; //play_sound(9);
                    ; play_sound(11);
                    ; break;
                ; case    1709:   //   06 AD
                    ; play_sound(12);
                    ; play_sound(9);
                    ; stop_sound(11);
                    ; break;
                ; case    2205:   //  08 9D
                    ; play_sound(8); //play_sound(13);
                    ; play_sound(13);
                    ; break;
            ; }
        ; }
    ; }
    ; else
    ; {
        ; if (counter<4685)
        ; {
            ; switch (counter)
            ; {
                ; case    2701:   //  0A 8D
                    ; play_sound(14);
                    ; play_sound(15);
                    ; play_sound(16);
                    ; break;
                ; case    3197:   //  0C 7D
                    ; play_sound(17);
                    ; play_sound(18);
                    ; play_sound(19);
                    ; break;
                ; case    3693:   //  0E 6D
                    ; play_sound(7);
                    ; play_sound(8); //play_sound(20);
                    ; play_sound(9);
                    ; play_sound(20);
                    ; break;
                ; case    4189:   //  10 5D
                    ; mute_all();
                    ; play_sound(9);
                    ; play_sound(14);
                    ; play_sound(15);
                    ; break;
            ; }
        ; }
        ; else
        ; {
            ; switch (counter)
            ; {
                ; case    4685:   //  12 4D
                    ; play_sound(13);
                    ; break;
                ; case    5181:   //  14 3D
                    ; mute_all();
                    ; play_sound(29);
                    ; break;
                ; case    5293:   //  14 AD
                    ; mute_all();
                    ; play_sound(30);
                    ; play_sound(31);
                    ; break;
            ; }
        ; }
    ; }
; }
    ret
    
startsound:

    push    ix
   ; push    iy

    ;ld      b,a
    call	0x1ff1

   ; pop     iy
    pop     ix
    ret