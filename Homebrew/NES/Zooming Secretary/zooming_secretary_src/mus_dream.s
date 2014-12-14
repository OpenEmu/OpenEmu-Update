mus_dream_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $03

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
	.byte $41,$21,$3f,$81,$15,$3f,$81,$20,$3f,$81,$14,$3f,$81,$1e,$3f,$81
	.byte $12,$3f,$12,$3f,$83,$11,$3f,$81,$21,$3f,$81,$15,$3f,$81,$20,$3f
	.byte $81,$14,$3f,$81,$1f,$3f,$81,$1e,$12,$81,$20,$14,$81,$1e,$12,$81
@chn2_1:
	.byte $21,$3f,$81,$15,$3f,$81,$20,$3f,$81,$14,$3f,$81,$1e,$3f,$81,$12
	.byte $3f,$12,$3f,$83,$11,$3f,$81,$21,$3f,$81,$15,$3f,$81,$20,$3f,$81
	.byte $14,$3f,$81,$12,$82,$3f,$82,$1e,$12,$1e,$12,$1f,$13,$1f,$13
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
