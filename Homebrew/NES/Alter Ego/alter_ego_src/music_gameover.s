music_gameover_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $08

@chn0:
@chn0_0:
	.byte $5c,$2b,$82,$4c,$2b,$82,$3f,$82,$54,$23,$80,$25,$2c,$80,$28,$81
	.byte $23,$2c,$80,$28,$21,$80,$23,$2a,$80,$26,$81,$23,$2a,$80,$26,$82
	.byte $5c,$23,$21,$1f,$1c,$1a,$17,$15,$13,$10,$4c,$10,$80,$3f,$8c
@chn0_loop:
@chn0_1:
	.byte $bf
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_0:
	.byte $5c,$2a,$82,$4c,$2a,$82,$3f,$82,$47,$1c,$81,$1c,$81,$21,$81,$21
	.byte $81,$1e,$81,$1c,$81,$1a,$81,$17,$84,$52,$13,$97
@chn1_loop:
@chn1_1:
	.byte $bf
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_0:
	.byte $8b,$54,$19,$80,$19,$25,$80,$25,$1e,$80,$1e,$2a,$80,$2a,$1a,$80
	.byte $26,$19,$80,$25,$17,$80,$23,$10,$80,$1c,$82,$42,$0e,$88,$3f,$8d
@chn2_loop:
@chn2_1:
	.byte $bf
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_0:
	.byte $bf
@chn3_loop:
@chn3_1:
	.byte $bf
	.byte $fe
	.word @chn3_loop

@chn4:
@chn4_0:
	.byte $bf
@chn4_loop:
@chn4_1:
	.byte $bf
	.byte $fe
	.word @chn4_loop
