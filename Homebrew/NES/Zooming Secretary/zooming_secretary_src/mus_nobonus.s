mus_nobonus_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $06

@chn0:
@chn0_0:
	.byte $44,$13,$07,$81,$11,$05,$81,$10,$04,$81,$0e,$02,$81,$0c,$00,$81
	.byte $45,$00,$82,$44,$00,$82,$45,$00,$82,$3f,$9e
@chn0_loop:
@chn0_1:
	.byte $bf
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_0:
	.byte $46,$13,$07,$81,$11,$05,$81,$10,$04,$81,$0e,$02,$81,$0c,$00,$81
	.byte $47,$00,$82,$46,$00,$82,$47,$00,$82,$3f,$9e
@chn1_loop:
@chn1_1:
	.byte $bf
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_0:
	.byte $41,$1f,$13,$81,$1d,$11,$81,$1c,$10,$81,$1a,$0e,$81,$18,$0c,$81
	.byte $3f,$82,$0c,$82,$3f,$a2
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
