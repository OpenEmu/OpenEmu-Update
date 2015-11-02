; gpm3pget.s

	.module get_m3_pixel
	
	; global from external code	
	.globl  calc_offset3

	; global from this code	
	.globl  _pget
	; (byte) = pget ((byte) x,(byte) y);
	
	.area _CODE

_pget:
		pop     hl
		pop     de
		push    de
		push    hl
        push    de
		ld      hl, #0x0000
		push    hl
		add     hl, sp
		call    calc_offset3
		ld      bc, #0x0001
		ld      a,#1
		call    0x1fe2
		pop     hl
        pop     de
        ld      a,e
        and     #1
        or      a
        jr      nz, $1
        ld      a,l
        rr      a
        rr      a
        rr      a
        rr      a
        jp      $2
$1:
        ld      a,l
$2:
        and     #0xf
        ld      l,a
		ret
