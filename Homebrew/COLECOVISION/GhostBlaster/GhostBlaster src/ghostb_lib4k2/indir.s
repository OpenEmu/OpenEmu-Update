; indir.s

	.module indir
	
	.globl  indir
	
	.area _CODE
indir:
    jp  (hl)