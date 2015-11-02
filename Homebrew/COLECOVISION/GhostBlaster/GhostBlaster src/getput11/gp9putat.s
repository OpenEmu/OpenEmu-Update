; gp9putat.s

	.module put_at
	
	; global from external code	
    .globl  calc_offset
    
	; global from this code	
    .globl  _put_at
    ; put_at (x,y,byte[],size)

	.area _CODE
    
_put_at:
    exx
    pop     hl
    exx
    pop     de
    call	calc_offset	; de = offset
    pop     hl
    pop     bc
    push    bc
    push    hl
    push    de
    exx
    push    hl
    exx

    ; bc = count
    ld      a,c
    jp      0x1fdf

