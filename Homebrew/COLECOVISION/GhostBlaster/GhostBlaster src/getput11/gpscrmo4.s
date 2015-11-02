; gpscrmo4.s

		.module	screen_mode_1
		
                .globl  	default_vdp_reg
                .globl  	_screen_mode_1_text
                ; screen_mode_2_text (void)

    .AREA   _CODE
    
    ;; WARNING : IT DOES USE DIRECT IO PORT VALUE

_screen_mode_1_text:
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
                ld      a,(0x73C4)
                and     #0xA7       ; blank screen, reset M1 & M3
                or      #0x82       ; 16K, sprites 16x16
                ld      c,a
                ld      b,#1
                call    0x1FD9
                ld      bc,#0x0380  ; vdp_out(3,80h) ; COLTAB = 2000
                call    0x1FD9
                ld      bc,#0x0400  ; vdp_out(4,00h) ; CHRGEN = 0000
                call    0x1FD9
                ld      hl,#0x1800                 ; clear screen
                ld      de,#0x0300                
                ld      a,#0x20
                call    0x1F82
                jp      default_vdp_reg
