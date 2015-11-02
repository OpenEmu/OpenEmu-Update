; gpascii1.s

	.module get_char
	
	; global from external code	
	.globl  calc_offset

	; global from this code	
	.globl  _get_char
	; get_char (x,y,value)
	
	.area _CODE

_get_char:
		pop     hl
		pop     de
		push    de
		push    hl
		ld      hl, #0x0000
		push    hl
		add     hl, sp
		call    calc_offset
		ld      bc, #0x0001
		ld      a,#1
		call    0x1fe2
		pop     hl
		ret
