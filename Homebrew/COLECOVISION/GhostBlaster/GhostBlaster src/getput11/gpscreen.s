; gpscreen.s

	.module screen
	
	; global from this code
	.globl  _screen
	; screen (vram address to view, vram address to edit);
	.globl  _swap_screen
	; swap_screen (void);

	.area _DATA
	
screen_name_table:
	.ds    2

	.area _CODE
	
_screen:
		exx
                pop	hl
                exx
                pop	hl
                pop	de
                push	de
                push	hl
                exx
                push	hl
                exx

swap_screen_core:
                ld	(screen_name_table),hl

                push	de

                push	ix
                push	iy
                ld	a,#2
                call	0x1FB8
                pop	iy
                pop	ix

                pop	de

                ld	(0x73F6),de

                ret

_swap_screen:
                ld	de,(screen_name_table)
                ld	hl,(0x73F6)
                jp	swap_screen_core

