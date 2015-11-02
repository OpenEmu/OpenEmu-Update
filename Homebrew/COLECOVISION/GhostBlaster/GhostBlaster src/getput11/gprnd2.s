; gprnd2.s

	.module rnd1
	
	; global from external code	
	.globl  _get_random ; From Coleco library

	; global from this code
	.globl  rnd1
	
	.area _CODE

rnd1:
		ld	bc,#0xffff	; to build AND_MASK in BC
		ld	a,h
		or  a
		jr	nz,rnd3
		ld	b,a
		ld	a,l
		jp	rnd3
rnd2:
		srl	b
		rr	c
rnd3:
		or	a
		rla
		jr	nc,rnd2
					; HL = MAX-MIN, DE = MIN, BC = AND_MASK

		push	de
		ex	de,hl
					; DE = MAX-MIN, BC = AND_MASK, MIN saved in stack

rnd4:
		push	de		; save MAX-MIN in stack
		push	bc		; save AND_MASK in stack
		
		call	_get_random    ; Coleco Random Function
		
		pop	bc		; get back AND_MASK from stack
		pop	de		; get back MAX-MIN from stack

		ld	a,h		; apply AND_MASK
		and	b
		ld	h,a
		ld	a,l
		and	c
		ld	l,a

		or	a
		push	de
		ex	de,hl
		sbc	hl,de
		ex	de,hl
		pop	de
		jr	c,rnd4		; if random number > MAX-MIN then retry

		pop	de
		add	hl,de		; HL = random_number between [MIN,MAX]
		ret

