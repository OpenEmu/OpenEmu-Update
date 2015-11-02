; gpchoices.s

	.module choice_keypad
	
	.globl  _keypad_1, _keypad_2 ; coleco library
	
	; global from this code	
	.globl  _choice_keypad
	; byte choice_keypad (byte min,byte max)

	.area _CODE
	
_choice_keypad:
		pop	bc
		pop	hl
		push	hl
		push	bc

		ld	a,(0x73c4)
		push	af		; keep vdp_reg #1 in stack
		or	#0x20
		ld	c,a
		ld	b,#1
		call	0x1fd9		; enable nmi to update joypad_1 and joypad_2
$1:
		call	0x1fdc		; get vdp_status
		ld	a,(_keypad_1)
		ld	b,a
		ld	a,(_keypad_2)
		ld	c,a
		ld	a,h
		or	a
		sbc	a,b
		jr	c,$2
		ld	a,b
		or	a
		sbc	a,l
		jr	c,$2
		ld	a,b
		jp	$3
$2:	
		ld	a,h
		or	a
		sbc	a,c
		jr	c,$1
		ld	a,c
		or	a
		sbc	a,l
		jr	c,$1
		ld	a,c
$3:		
		ld	h,#0
		ld	l,a
		pop	af
		ld	c,a
		ld	b,#1
		jp	0x1fd9		; set back the vdp_reg #1 value
