; vdppat.s

    .module put_vram_pattern
    
    .globl  _put_vram_pattern
    ; put_vram_pattern (unsigned offset,void *pattern,
    ;                   byte psize,unsigned count);
    
    .area _CODE
    
_put_vram_pattern:
	exx
	pop     hl
	pop     de
	ld      a,(0x1d43)
	ld      c,a  ;; (1d43h) = 0bfh                
	di
	out     (c),e
	set     6,d
	out     (c),d
	ei
	exx
	pop     hl
	pop     bc
	pop     de
	push    de
	push    bc
	push    hl
	exx
	push    de
	push    hl
	exx
	ld      d,e
	ld      e,b
	ld      b,c
	ld      a,(0x1d47)
	ld      c,a  ;; (1d47h) = 0beh
$1:
	push    bc
	push    hl
$2:
	outi
	nop
	nop
	jp      nz,$2
	pop     hl
	pop     bc
	dec     de
	ld      a,e
	or      d
	jr      nz,$1
	ret
