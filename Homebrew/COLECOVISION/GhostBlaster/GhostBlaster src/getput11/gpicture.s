; gpicture.s

		.module show_picture

		.globl  _screen_off, _screen_on
		.globl  _rle2vram

                .globl  _show_picture
                ; show_picture(void *picture)

    .AREA   _CODE
    
_show_picture:
                pop     de
                pop     hl
                push    hl
                push    de

                call    _screen_off

                ld	bc, #0x2000

                push    bc
                push    hl

                call    _rle2vram

                ld	bc, #0x0000
                push    bc
                push    hl

                call    _rle2vram

                pop     bc
                pop     bc
                pop     bc
                pop     bc

                call    _screen_on

                ret
