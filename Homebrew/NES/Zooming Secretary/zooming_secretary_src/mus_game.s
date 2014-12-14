mus_game_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $06

@chn0:
@chn0_loop:
@chn0_0:
	.byte $bf
@chn0_1:
	.byte $bf
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_loop:
@chn1_0:
	.byte $bf
@chn1_1:
	.byte $bf
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_loop:
@chn2_0:
	.byte $41,$13,$80,$3f,$80,$13,$80,$3f,$80,$42,$0c,$80,$41,$13,$3f,$11
	.byte $3f,$13,$3f,$0e,$80,$3f,$82,$0e,$80,$42,$0c,$80,$41,$0e,$3f,$10
	.byte $3f,$0e,$3f,$13,$80,$3f,$80,$13,$80,$3f,$80,$42,$0c,$80,$41,$13
	.byte $3f,$11,$3f,$13,$3f,$0e,$80,$3f,$8c
@chn2_1:
	.byte $13,$80,$3f,$80,$13,$80,$3f,$80,$42,$0c,$80,$41,$13,$3f,$11,$3f
	.byte $13,$3f,$0e,$80,$3f,$82,$0e,$80,$42,$0c,$80,$41,$0e,$3f,$0c,$3f
	.byte $0b,$3f,$0c,$80,$3f,$80,$0c,$80,$3f,$80,$42,$0c,$80,$41,$0c,$3f
	.byte $0b,$3f,$0c,$3f,$0e,$80,$3f,$84,$0e,$80,$3f,$80,$12,$80,$3f,$80
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_loop:
@chn3_0:
	.byte $bf
@chn3_1:
	.byte $bf
	.byte $fe
	.word @chn3_loop

@chn4:
@chn4_loop:
@chn4_0:
	.byte $bf
@chn4_1:
	.byte $bf
	.byte $fe
	.word @chn4_loop
