; gpmlt00.s

	.module change_multicolor
	
	; global from external code	
        .globl  _change_multicolor_pattern0

	; global from this code
        .globl  _change_multicolor0
	;void change_multicolor0(void *color,unsigned char c);
	
	.area _CODE

_change_multicolor0:
                pop	bc
                pop	hl
                pop	de
                push	de
                push	hl
                push	bc
		ld	d,#1
		push	de
		push	hl
		jp	_change_multicolor_pattern0
