initVDP:
		;Set all the VDP regs. Normally I'd set them all up with an OTIR and a table, but instead
		;I'll do them one by one here so I can comment...
	ld c,$bf
	
	ld a, $6
	out (c),a
	ld a, $80
	out (c),a	; $6 in VDP 0... not totally sure what that bit (bit 2) does, but I usually see it set.
				; Also set bit 1, as zoop discovered, failing to do so will cause the demo not to work
				; on a Game Gear
	
	ld a, $0
	out (c),a
	ld a,$81
	out (c),a 	;Just set to zero to keep the screen off until we're ready
	
	ld a, $ff
	out (c),a 
	ld a, $82
	out (c),a  ;Sets the VDP name table to $3800 (/$7800), its default location
	
	ld a, $ff
	out (c),a
	ld a,$83
	out (c),a	;legacy register, I think it can be used to set the VDP into old SG1000 modes...	
				;otherwise set to $ff (the VDP specific doc explains this better than Richard's)
				
	ld a, $ff
	out (c),a
	ld a, $84
	out (c),a 	;same as above
	
	ld a, $ff
	out (c),a
	ld a,$85
	out (c),a	;sets sprite table to its default location, $3f00 (/$7f00)
	
	ld a, $3 ; 3 to work on SMS1
	out (c),a
        ld a,$86
	out (c),a   ;instructs the VDP to use the first 256 tiles in VRAM (i.e. the first 8k of VRAM, generally what
				;you want to do.)
				
	ld a, $0
	out (c),a
	ld a,$87
	out (c),a	;the low 4 bits determine which color in the sprite palette will be used for the screen border
			
	ld a, $0
	out (c),a
	ld a,$88
	out (c),a	;vertical scroll register, 0 of course
	
	ld a, $0
	out (c),a
	ld a,$89
	out (c),a 	;horizontal scroll register
	
	ld a,$ff
	out (c),a
	ld a,$8a
	out (c),a	;# of scanlines between scanline interrupts. they're not turned on anyway, but $ff is a good value to
				;use by default since there is no line $ff
	ret

