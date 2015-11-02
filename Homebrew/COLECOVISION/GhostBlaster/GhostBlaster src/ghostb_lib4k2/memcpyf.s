; memcpyf.s

	.module memorycopyf

	; global from this code
	.globl  _memcpyf
	; void memcpyf (void *dest,void *src,int n);
	
	.area _CODE

_memcpyf:
    pop     bc
    exx
    pop     de
    pop     hl
    pop     bc
    push    bc
    push    hl
    push    de
    exx
    push    bc
    exx
    add     hl,bc
    dec     hl
    ex      de,hl
    add     hl,bc
    dec     hl
    ex      de,hl
    lddr
    ret