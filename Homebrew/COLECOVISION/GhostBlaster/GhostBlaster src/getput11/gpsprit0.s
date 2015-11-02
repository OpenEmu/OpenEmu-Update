; gpsprit0.s

	.module sprites_simple
	
	; global from external code	
	.globl  set_reg_1

	; global from this code	
	.globl  _sprites_simple
	; sprites_simple (void)
	
	.area _CODE
	
_sprites_simple:
	ld   a,(0x73c4)	; _get_reg_1
	and  #0xfe
	jp   set_reg_1

