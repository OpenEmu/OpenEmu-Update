; gpscrmo1.s

		.module	screen_mode_2
		
                .globl  	default_set_mode_2
                .globl  	_screen_mode_2_text
                ; screen_mode_2_text (void)

    .AREA   _CODE
    
    ;; WARNING : IT DOES USE DIRECT IO PORT VALUE

_screen_mode_2_text:
                push    af
                push    bc
                push    de
                push    hl
                push    ix
                push    iy
                ld      a,(0x73C4)
                and	#0xA7                     ; blank screen, reset M1 & M3
                or 	#0x82                     ; 16K, sprites 16x16
                ld      c,a
                ld      b,#1
                call    0x1FD9
                ld      bc,#0x039F                ; vdp_out(3,9fh)
                call    0x1FD9
                ld      bc,#0x0403                ; vdp_out(4,3)
                call    0x1FD9
                ;ld      hl,#0x1800                 ; clear screen
                ;ld      de,#0x0300                
                ;ld      a,#0x20
                ;call    0x1F82
                jp      default_set_mode_2
