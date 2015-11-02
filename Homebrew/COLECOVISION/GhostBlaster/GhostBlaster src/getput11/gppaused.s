; gppaused.s

	.module pause_delay
	
	; global from external code	
	.globl  _joypad_1, _joypad_2 ; coleco library

	; global from this code
        .globl  _pause_delay
        ; pause_delay (unsigned i)

	.area _CODE
	
_pause_delay:
		pop	hl
		pop	de
		push	de
		push	hl

		ld	a,(0x73C4)
		push	af		; keep vdp_reg #1 in stack
		or	#0x20
		ld	c,a
		ld	b,#1
		call	0x1FD9		; enable nmi to update joypad_1 and joypad_2
		call	0x1FDC		; get vdp_status
		push	de

$1:
		ld	a,(_joypad_1)
		and	#0xF0
		ld	b,a
		ld	a,(_joypad_2)
		and	#0xF0
		or	b
		jr	nz, $2	; if fires are pressed -> goto end

		halt			; Wait one refresh

		pop	de
		dec	de		; decrease counter
		push	de
		ld	a,e
		or	d
		jr	nz, $1		; if time is up -> goto end

$2:
		pop	de
		pop	af
		ld	c,a
		ld	b,#1
		jp	0x1FD9		; set back the vdp_reg #1 value

