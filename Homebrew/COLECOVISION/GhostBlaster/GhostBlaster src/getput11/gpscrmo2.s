; gpscrmo2.s

    .module	default_vdp_reg
        .globl      default_set_mode_2
        .globl      default_vdp_reg

    .AREA   _CODE

default_set_mode_2:
                ld      bc,#0x0002             ; vdp_out(0,2) ; set mode 2
                call    0x1FD9

default_vdp_reg:
                ld      a,#2
                ld      hl,#0x1800
                call    0x1FB8

                ;ld      hl,#0x0000              ; clear charset
                ;ld      de,#0x1800                
                ;xor     a
                ;call    0x1F82
                ;ld      hl,#0x2000              ; set default white chars color
                ;ld      de,#0x1800                
                ;ld      a,#0xF0
                ;call    0x1F82
                ld      a,(0x73c4)
                or     #0x40                    ; show screen
                ld      c,a
                ld      b,#1
                call    0x1FD9                 
                pop     iy
                pop     ix
                pop     hl
                pop     de
                pop     bc
                pop     af
                ret

