; gpm3pset.s

	.module set_m3_pixel
	
	; global from external code	
	.globl  calc_offset3

	; global from this code	
	.globl  _pset
	; pset ((byte) x,(byte) y,(byte) c);
	
	.area _CODE

_pset:
		pop     hl
		pop     de
		pop     bc
		push    bc
		push    de
		push    hl
        push    de
		ld      hl, #0x0000
		push    hl
		add     hl, sp
		call    calc_offset3
        push    de
        push    bc
		ld      bc, #0x0001
		ld      a,#1
		call    0x1fe2
        pop     bc
        pop     de
		pop     hl
        ld      a,l
        ex      de,hl
        pop     de
        push    af
        ld      a,e
        and     #1
        or      a
        jr      z, $1
        ld      a,c
        and     #0x0f
        ld      c,a
        pop     af
        and     #0xf0
        jp      $2
$1:
        ld      a,c
        rl      a
        rl      a
        rl      a
        rl      a
        and     #0xf0
        ld      c,a
        pop     af
        and     #0x0f
$2:
        or      c
        ld      d,#0
        ld      e,a
        push    de
        ex      de,hl
		ld      hl, #0
		add     hl, sp
		ld      bc, #0x0001
		ld      a,#1
		call    0x1fdf
        pop     de
		ret
