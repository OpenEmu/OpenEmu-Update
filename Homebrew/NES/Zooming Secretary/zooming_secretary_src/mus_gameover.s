mus_gameover_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $06

@chn0:
@chn0_0:
	.byte $44,$13,$80,$45,$13,$80,$44,$13,$80,$45,$13,$80,$44,$11,$80,$45
	.byte $13,$80,$44,$11,$80,$45,$11,$80,$44,$0e,$82,$45,$11,$80,$0e,$80
	.byte $44,$11,$82,$45,$11,$82
@chn0_loop:
@chn0_1:
	.byte $9f
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_0:
	.byte $46,$13,$80,$47,$13,$80,$46,$13,$80,$47,$13,$80,$46,$11,$80,$47
	.byte $13,$80,$46,$11,$80,$47,$11,$80,$46,$0e,$82,$47,$11,$80,$0e,$80
	.byte $46,$11,$82,$47,$11,$82
@chn1_loop:
@chn1_1:
	.byte $9f
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_0:
	.byte $42,$0c,$80,$41,$13,$80,$42,$0c,$80,$41,$13,$80,$42,$0c,$80,$41
	.byte $11,$80,$42,$0c,$80,$41,$11,$80,$42,$0c,$80,$41,$0c,$80,$42,$0c
	.byte $82,$41,$11,$82,$3f,$82
@chn2_loop:
@chn2_1:
	.byte $9f
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_0:
	.byte $9f
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
