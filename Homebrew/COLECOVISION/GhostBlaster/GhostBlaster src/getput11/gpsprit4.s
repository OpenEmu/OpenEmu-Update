; gpsprit4.s

	.module set_reg_1
	
	; global from this code	
	.globl  set_reg_1
	
	.area _CODE
	
set_reg_1:
		ld      c,a
		ld      b,#1
		jp      0x1fd9
