mus_level_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $05

@chn0:
@chn0_0:
	.byte $44,$1f,$45,$1f,$44,$23,$45,$1f,$44,$26,$45,$23,$44,$23,$45,$26
	.byte $44,$1d,$45,$23,$44,$21,$45,$1d,$44,$24,$45,$21,$44,$21,$45,$24
	.byte $44,$18,$45,$21,$44,$1c,$45,$18,$44,$1f,$45,$1c,$44,$1c,$45,$1f
	.byte $44,$18,$80,$45,$1c,$80,$18,$82
@chn0_loop:
@chn0_1:
	.byte $9f
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_0:
	.byte $46,$1f,$47,$1f,$46,$23,$47,$1f,$46,$26,$47,$23,$46,$23,$47,$26
	.byte $46,$1d,$47,$23,$46,$21,$47,$1d,$46,$24,$47,$21,$46,$21,$47,$24
	.byte $46,$18,$47,$21,$46,$1c,$47,$18,$46,$1f,$47,$1c,$46,$1c,$47,$1f
	.byte $46,$18,$80,$47,$1c,$80,$18,$82
@chn1_loop:
@chn1_1:
	.byte $9f
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_0:
	.byte $42,$0c,$80,$41,$0c,$80,$42,$0c,$80,$41,$0c,$80,$42,$0c,$80,$41
	.byte $0c,$80,$42,$0c,$80,$41,$0c,$80,$42,$0c,$80,$41,$0c,$80,$42,$0c
	.byte $80,$41,$0c,$80,$42,$0c,$41,$0c,$81,$3f,$82
@chn2_loop:
@chn2_1:
	.byte $9f
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_0:
	.byte $43,$0f,$0f,$0f,$80,$0b,$0f,$0f,$80,$0f,$0f,$0f,$80,$0b,$0f,$0f
	.byte $80,$0f,$0f,$0f,$80,$0b,$0f,$0f,$80,$0f,$86
@chn3_loop:
@chn3_1:
	.byte $9f
	.byte $fe
	.word @chn3_loop

@chn4:
@chn4_0:
	.byte $9f
@chn4_loop:
@chn4_1:
	.byte $9f
	.byte $fe
	.word @chn4_loop
