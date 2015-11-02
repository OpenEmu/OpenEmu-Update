; gpsprit3.s

	.module sprites_double
	
	; global from external code	
	.globl  set_reg_1

	; global from this code	
	.globl  _sprites_16x16
	; sprites_16x16 (void)
	
	.area _CODE
	
_sprites_16x16:
	ld   a,(0x73c4)	; _get_reg_1
	or  #2
	jp   set_reg_1
