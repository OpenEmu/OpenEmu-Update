; scrn_on.s

	.module screen

	.globl  _screen_on
	; screen_on (void)
	
	.area _CODE
    
_screen_on:     ld      a,(0x73c4)
                or      #0x40
                ld      c,a
                ld      b,#1
                jp      0x1fd9
