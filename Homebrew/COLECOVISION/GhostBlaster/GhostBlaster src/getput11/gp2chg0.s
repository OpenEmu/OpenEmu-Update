; gp2chg0.s

	.module change_pattern
	
	.globl  _change_pattern
	; change_pattern0(void *pattern, unsigned char c, unsigned char l);
	.area _CODE

_change_pattern0:
                pop	bc
                pop	hl
                pop	de
                push	de
                push	hl
                push	bc
                push	hl
                ld	h,#0
                ld	l,d
                add	hl,hl
                add	hl,hl
                add	hl,hl
                ld	b,h
                ld	c,l
                ld	h,#0
                ld	l,e
                add	hl,hl
                add	hl,hl
                add	hl,hl
                ld	d,h
                ld	e,l
                pop	hl
                ld      a,c
                jp      0x1FDF
