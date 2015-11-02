; mute.s

	.module play_sound

	; global from external code
    
    .globl  snd_areas

	; global from this code

    .globl  _mute_all
    ; mute_all ();
	
	.area _CODE

_mute_all:

	ld	b,#5
	ld	de,#0x000a
	ld	hl,#snd_areas
$1:
	ld	(hl),#0xff
	add	hl,de
	djnz	$1
	
	jp	0x1fd6
	