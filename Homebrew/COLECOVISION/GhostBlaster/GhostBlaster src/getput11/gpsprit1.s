; gpsprit1.s

	.module sprites_double
	
	; global from external code	
	.globl  set_reg_1

	; global from this code	
	.globl  _sprites_double
	; sprites_double (void)
	
	.area _CODE
	
_sprites_double:
	ld   a,(0x73c4)	; _get_reg_1
	or  #1
	jp   set_reg_1
