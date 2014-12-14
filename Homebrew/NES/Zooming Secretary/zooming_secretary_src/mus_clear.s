mus_clear_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $06

@chn0:
@chn0_0:
	.byte $44,$0c,$45,$0c,$44,$10,$45,$0c,$44,$13,$45,$10,$44,$18,$45,$13
	.byte $44,$11,$45,$18,$44,$15,$45,$11,$44,$18,$45,$15,$44,$1d,$45,$18
	.byte $44,$13,$45,$1d,$44,$17,$45,$13,$44,$1a,$45,$17,$44,$1f,$45,$1a
	.byte $44,$24,$45,$1f,$24,$84
@chn0_loop:
@chn0_1:
	.byte $9f
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_0:
	.byte $46,$0c,$47,$0c,$46,$10,$47,$0c,$46,$13,$47,$10,$46,$18,$47,$13
	.byte $46,$11,$47,$18,$46,$15,$47,$11,$46,$18,$47,$15,$46,$1d,$47,$18
	.byte $46,$13,$47,$1d,$46,$17,$47,$13,$46,$1a,$47,$17,$46,$1f,$47,$1a
	.byte $46,$24,$47,$1f,$24,$84
@chn1_loop:
@chn1_1:
	.byte $9f
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_0:
	.byte $42,$0c,$80,$41,$18,$80,$42,$0c,$80,$41,$18,$80,$42,$0c,$80,$41
	.byte $1d,$80,$42,$0c,$80,$41,$1d,$80,$42,$0c,$80,$41,$1f,$80,$42,$0c
	.byte $80,$41,$1f,$80,$24,$82,$3f,$82
@chn2_loop:
@chn2_1:
	.byte $9f
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_0:
	.byte $81,$43,$0f,$0f,$0b,$80,$0f,$0f,$81,$0f,$0f,$0b,$80,$0f,$0f,$81
	.byte $0f,$0f,$0b,$80,$0f,$0f,$0c,$86
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
