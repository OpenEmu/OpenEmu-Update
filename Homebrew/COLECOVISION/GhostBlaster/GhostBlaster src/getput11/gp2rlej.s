; gp2rlej.s

	.module rlej2vram
	
	.globl  _rlej2vram
	; void *rlej2vram (void *rledata,unsigned offset);
	
	.area _CODE

_rlej2vram:
		pop     bc
                pop     hl
                pop     de
                push    de
                push    hl
                push    bc
                di
                ld      a,(0x1D43)
                ld      c,a
                out     (c),e
                set     6,d
                out     (c),d
                ei
                ld      a,(0x1D47)
                ld      c,a
$0:
		ld      a,(hl)
                inc	hl
                cp	#0xFF
                ret	z
                bit	7,a
                jr	z,$2
                and	#0x7F
                inc    a
                ld      b,a
                ld      a,(hl)
                inc     hl
                cp     #0x00
                jr      nz,$1
                push	bc
                ld      c,a
                ld      b,#0
                ex	de,hl
                add	hl,bc
                ex	de,hl
                di
                ld      a,(0x1D43)
                ld      c,a
                out	(c),e
                set	6,d
                out	(c),d
                ei
                pop	bc
                jr      $0
$1:
		out	(c),a
                inc	de
                ;nop
                nop
                djnz	$1
                jr	$0
$2:
		inc	a
                ld      b,a
$3:
		outi
                inc	de
                jr      z,$0
                jp	$3
