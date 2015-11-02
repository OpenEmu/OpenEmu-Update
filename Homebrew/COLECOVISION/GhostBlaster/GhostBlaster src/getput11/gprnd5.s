; gprnd5.s

	.module absdiff_max_min
	
	; global from this code	
    .globl  absdiff_max_min

	.area _CODE

		; HL = B, DE = A
absdiff_max_min:
		push	hl
		pop	bc
		sbc	hl,de
		jr	nc,$1		; if B<A then swap HL=A-B, else HL=B-A
		push	bc
		pop	hl
		ex	de,hl
		sbc	hl,de
$1:		ret

