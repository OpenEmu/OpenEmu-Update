; gpascii0.s

	.module put_char
	
	; global from external code	
	.globl  calc_offset

	; global from this code	
	.globl  _put_char
	; put_char (x,y,value)
	
	.area _CODE
	
_put_char:
		pop     hl
		pop     de
		push    de
		push    hl
		ld      hl, #4
		add     hl, sp
		call    calc_offset
		ld      bc, #0x0001
		ld      a,#1
		jp      0x1fdf

