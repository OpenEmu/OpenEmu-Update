; gppause.s

	.module pause
	
	; global from external code	
    .globl  _joypad_1, _joypad_2 ; coleco library
    
	; global from this code	
    .globl  _pause
    ; pause ()

	.area _CODE

_pause:
		ld	a,(0x73c4)
		push	af		; keep vdp_reg #1 in stack
		or	#0x20
		ld	c,a
		ld	b,#1
		call	0x1fd9		; enable nmi to update joypad_1 and joypad_2
		push	hl
$1:		ld	a,(_joypad_1)
		ld	h,a
		ld	a,(_joypad_2)
		or	h
		and	#0xf0
		jr	nz,$1
$2:		ld	a,(_joypad_1)
		ld	h,a
		ld	a,(_joypad_2)
		or	h
		and	#0xf0
		jr	z,$2
		pop	hl
		pop	af
		ld	c,a
		ld	b,#1
		jp	0x1fd9		; set back the vdp_reg #1 value
		