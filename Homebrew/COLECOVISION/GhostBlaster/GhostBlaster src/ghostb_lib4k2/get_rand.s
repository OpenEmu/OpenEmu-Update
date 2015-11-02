; get_rand.s

	.module getrandom

	; global from this code
	.globl  _get_random
	; _get_random (void)
	
	.area _CODE
_get_random:
	call    #0x1ffd
	ld      a,r
	xor     l
	ld      l,a
	ret
