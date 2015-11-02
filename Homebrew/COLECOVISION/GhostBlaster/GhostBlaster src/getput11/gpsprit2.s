; gpsprit2.s

	.module sprites_double
	
	; global from external code	
	.globl  set_reg_1

	; global from this code	
	.globl  _sprites_8x8
	; sprites_8x8 (void)
	
	.area _CODE
	
_sprites_8x8:
	ld   a,(0x73c4)	; _get_reg_1
	and  #0xfd
	jp   set_reg_1
