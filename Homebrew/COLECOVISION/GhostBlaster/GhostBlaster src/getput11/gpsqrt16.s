; gpsqrt16.s

; Modified by Daniel Bienvenu Oct. 2004
; Original code by Ricardo Bittencourt Feb. 2004

	.module sqrt16
	
	; global from this code
	.globl  _sqrt16
	; byte sqrt16(unsigned)
	
	.area _CODE

_sqrt16:
		pop	de
		pop	hl
		push	hl
		push	de
		ld	de,#0x0040
		ld	a,l
		ld	l,h
		ld	h,d
		or	a
		ld	b,#8
sqrt_loop:
		sbc	hl,de
		jr	nc,sqrt_skip
		add	hl,de
sqrt_skip:
		ccf
		rl	d
		add	a,a
		adc	hl,hl
		add	a,a
		adc	hl,hl
		djnz	sqrt_loop
		ld	h,#0
		ld	l,d
		ret
