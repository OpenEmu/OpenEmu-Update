; gpscrmo3.s

		.module	screen_mode_3
		
                .globl  	default_vdp_reg
                .globl  	_screen_mode_3_bitmap
                ; screen_mode_3_bitmap (void)

    .AREA   _CODE
    
    ;; WARNING : IT DOES USE DIRECT IO PORT VALUE
 
_screen_mode_3_bitmap:
                push    af
                push    bc
                push    de
                push    hl
                push    ix
                push    iy
                
                ld      a,(0x73c3)	; _get_reg_0
                and     #0xFD       ; reset M2
                ld      c,a
                ld      b,#0
                call    0x1FD9
                ld      a,(0x73c4)  ; _get_reg_1
                and     #0xAF       ; blank screen, reset M1
                or      #0x8A       ; 16K, set M3, sprites 16x16
                ld      c,a
                ld      b,#1
                call    0x1FD9
                ld      bc,#0x0380  ; vdp_out(3,80h) ; COLTAB = 2000
                call    0x1FD9
                ld      bc,#0x0400  ; vdp_out(4,00h) ; CHRGEN = 0000
                call    0x1FD9
                di
                xor     a
                out     (0xBF),a
                ld      a,#0x18
                set     6,a
                out     (0xBF),a
                ei

                xor     a
                ld      h,#6
$1:             ld      d,#4
$2:             ld      e,#32
$3:             out     (0xBE),a
                nop
                inc     a
                dec     e
                jp      nz,$3
                ld      e,#224 ; = 256-32
                add     a,e
                dec     d
                jp      nz,$2
                ld      e,#32
                add     a,e
                dec     h
                jp      nz,$1
                jp      default_vdp_reg
