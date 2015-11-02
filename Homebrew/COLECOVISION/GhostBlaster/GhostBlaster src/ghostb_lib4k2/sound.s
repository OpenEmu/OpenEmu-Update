; sound.s

	.module play_sound

	; global from this code

    .globl  _play_sound
    ; play_sound (byte sound_number);
	
	.area _CODE
    
_play_sound:
    pop     bc
    pop     de
    push    de
    push    bc
    push    ix
    push    iy

    ld      b,e
    call	0x1ff1

    pop     iy
    pop     ix
    ret
