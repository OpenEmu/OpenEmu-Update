; gpdsound.s

; play_dsound
; by Daniel Bienvenu
;
; hl = pointer to sound table
; c = delay in "donothing" loop
; b and d are used like variables

	.module dsound
	
	; global from this code
	.globl  _play_dsound
	; play_dsound (void *sound, byte delay);

	.area _CODE

_play_dsound:
		pop	de	; return address 
		pop	hl	; hl = pointer to sound table
		pop	bc	; c = delay in "donothing" loop
		push	bc
		push	hl
		push	de
		di		; DISABLE INTTERUPT
		inc	bc
		push	bc
		push	de
		call	quiet	; sound_off
		pop	de
		pop	bc
loop1:
		ld	a,(hl)
		or	a
		jr	z,special
		rrca
		rrca
		rrca
		rrca
		call	volumeall
		ld	a,(hl)
		inc	hl
		ld	b,#1	; to slowdown the code
		ld	b,#1	; to slowdown the code
		ld	b,#1	; to slowdown the code
		nop		; to slowdown the code
		nop		; to slowdown the code
		nop		; to slowdown the code
		call	volumeall
		jp	loop1
special:
		inc	hl
		ld	d,(hl)
		ld	a,d
		cp	#0
		jp	nz,smallloop2
		ei		; ENABLE INTERUPT AND QUIT
		ret
loop2:
		ld	b,#5	; to slowdown the code
		nop		; to slowdown the code
donothing1:
		djnz	donothing1
smallloop2:
		ld	b,#2	; to slowdown the code
donothing2:
		djnz	donothing2
		ld	b,#2	; to slowdown the code
		nop		; to slowdown the code
		nop		; to slowdown the code
		nop		; to slowdown the code
		ld	b,c
donothing3:
		djnz	donothing3
		dec	d
		jr	nz,loop2
		inc	hl
		jp	loop1
volumeall:	
		and	#0x0F
		or	#0x90
		out	(0xFF),a
		or	#0xB0
		out	(0xFF),a
		xor	#0x60
		out	(0xFF),a
		ld	b,c
donothing4:
		djnz	donothing4
		ret
quiet:	
		ld	bc,#0x0381
loop3:	
		ld	a,c
		out	(0xFF),a
		add	a,#0x20
		ld	c,a
		ld	a,#0
		out	(0xFF),a
		djnz	loop3
		ld	a,#0xFF
		out	(0xFF),a
		ret
