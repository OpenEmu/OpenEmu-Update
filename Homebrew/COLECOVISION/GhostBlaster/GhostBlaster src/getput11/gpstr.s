; gpstr.s

	.module str
	
	; global from external code	
    .globl  _utoa0
    
	; global from this code	
    .globl  _str
    ; char *str (unsigned value)

    .area _DATA
string_data:
    .ds    6
    
	.area _CODE

_str:
		pop	hl
		pop	bc
		push	bc
		push	hl

		ld	hl,#string_data
		push	hl
		push	bc

		call	_utoa0

		pop	bc
		pop	bc

		xor	a
		ld	(string_data+5),a
		ld	hl,#string_data

		ret
