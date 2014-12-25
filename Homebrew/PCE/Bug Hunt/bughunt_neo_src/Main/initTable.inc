;-----------------------------------------------------------------------------
; this gets copied to 22d0 in psg_init

initTable
	.db $d3   ; don't know what these are, but the appear to be defaults for something
	.db $00   ; in global song control. The 00 values are also used to clear memory
	.db $00   ; 
	.db $06   ; 
	.db $08   ; 
	.db $20   ; 
	.db $00   ; 
	.db $60   ; 

