; memcpyb.s

	.module memorycopyb

	; global from this code
	.globl  _memcpyb
	; void memcpyb (void *dest,void *src,int n);
	
	.area _CODE

_memcpyb:
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
	ldir
	ret	