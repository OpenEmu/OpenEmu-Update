; gp2chg.s

	.module change_pattern
	
	.globl  _change_pattern
	; change_pattern(unsigned char c, void *pattern, unsigned char l);
	.area _CODE

_change_pattern:
                pop	bc
                pop	de
                pop	hl
                push	hl
                push	de
                push	bc
		ld	c,h
		ld	h,l
		ld	l,d
                push	hl
                ld	h,#0
                ld	l,c
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
