; gplascii.s

	.module load_ascii

	.globl  _load_ascii
	; update_sprites (byte numsprites,unsigned sprtab);
	; void load_ascii()

	.AREA   _CODE

_load_ascii:
                push  ix
                call  0x1F7F
                pop   ix
                ret
		