; gpscrmo0.s

		.module	screen_mode_2
		
                .globl  	default_set_mode_2
                .globl  	_screen_mode_2_bitmap
                ; screen_mode_2_bitmap (void)

    .AREA   _CODE
    
    ;; WARNING : IT DOES USE DIRECT IO PORT VALUE
 
_screen_mode_2_bitmap:
                push    af
                push    bc
                push    de
                push    hl
                push    ix
                push    iy
                ld	a,(0x73C4)
                and	#0xA7                ; blank screen, reset M1 & M3
                or	#0x82                ; 16K, sprites 16x16
                ld      c,a
                ld      b,#1
                call    0x1FD9
                ld      bc,#0x03FF         ; vdp_out(3,ffh)
                call    0x1FD9
                ld      bc,#0x0403         ; vdp_out(4,3)
                call    0x1FD9
                di
                xor     a
                out	(0xBF),a
                ld      a,#0x18
                set     6,a
                out	(0xBF),a
                ei
                ld      d,#3
$1:
		xor     a
$2:
		out     (0XBE),a
                nop
                inc     a
                jp      nz,$2
                dec     d
                jp      nz,$1
                jp      default_set_mode_2
