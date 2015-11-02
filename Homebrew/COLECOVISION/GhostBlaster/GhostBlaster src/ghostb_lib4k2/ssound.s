; ssound.s

	.module play_sound

	; global from external code
    
    .globl  _snd_table

	; global from this code

    .globl  _stop_sound
    .globl  stop_sound
    ; stop_sound (byte sound_number);
	
	.area _CODE

_stop_sound:
    pop     bc
    pop     de
    push    de
    push    bc

stop_sound:

    ld      a,e   ; a = song#

    ld      b,a   ; b = song#
    ld      hl,#_snd_table-2   ; calcul the right sound slot
    ld      de,#0x0004
$1:
    add	hl,de
    djnz	$1

    ld      b,a   ; b = song#

    ld      e,(hl)           ; get the sound slot addr.
    inc	hl
    ld      d,(hl)
    ex      de,hl

    ld      a,(hl)           ; get the song# currently in the sound slot
    and     #0x3f

    cp	b                ; compare with the song# we are looking for
    jr	nz,$2            ; if not the same song# -> do nothing

    ld      (hl),#0xff
$2:
    ret

