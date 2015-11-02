; scrn_off.s

	.module screen

	.globl  _screen_off
	; screen_off (void)

	.area _CODE
    
_screen_off:    ld      a,(0x73c4)
                and     #0xbf
                ld      c,a
                ld      b,#1
                jp      0x1fd9