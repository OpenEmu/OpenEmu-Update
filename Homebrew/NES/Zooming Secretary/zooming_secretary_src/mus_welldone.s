mus_welldone_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $06

@chn0:
@chn0_loop:
@chn0_0:
	.byte $44,$11,$45,$11,$44,$15,$45,$11,$44,$18,$45,$15,$44,$1d,$45,$18
	.byte $44,$21,$45,$1d,$44,$1d,$45,$21,$44,$18,$45,$1d,$44,$15,$45,$18
	.byte $44,$13,$45,$15,$44,$17,$45,$13,$44,$1a,$45,$17,$44,$1f,$45,$1a
	.byte $44,$23,$45,$1f,$44,$1f,$45,$23,$44,$1a,$45,$1f,$44,$17,$45,$1a
	.byte $44,$0c,$45,$17,$44,$10,$45,$0c,$44,$13,$45,$10,$44,$18,$45,$13
	.byte $44,$1c,$45,$18,$44,$18,$45,$1c,$44,$13,$45,$18,$44,$10,$45,$13
	.byte $44,$09,$45,$10,$44,$0c,$45,$09,$44,$10,$45,$0c,$44,$15,$45,$10
	.byte $44,$18,$45,$15,$44,$15,$45,$18,$44,$10,$45,$15,$44,$0c,$45,$10
@chn0_1:
	.byte $44,$11,$45,$11,$44,$15,$45,$11,$44,$18,$45,$15,$44,$1d,$45,$18
	.byte $44,$21,$45,$1d,$44,$1d,$45,$21,$44,$18,$45,$1d,$44,$15,$45,$18
	.byte $44,$13,$45,$15,$44,$17,$45,$13,$44,$1a,$45,$17,$44,$1f,$45,$1a
	.byte $44,$23,$45,$1f,$44,$1f,$45,$23,$44,$1a,$45,$1f,$44,$17,$45,$1a
	.byte $44,$09,$45,$10,$44,$0c,$45,$09,$44,$10,$45,$0c,$44,$15,$45,$10
	.byte $44,$18,$45,$15,$44,$15,$45,$18,$44,$10,$45,$15,$44,$0c,$45,$10
	.byte $44,$09,$45,$10,$44,$0c,$45,$09,$44,$10,$45,$0c,$44,$15,$45,$10
	.byte $44,$18,$45,$15,$44,$15,$45,$18,$44,$10,$45,$15,$44,$0c,$45,$10
@chn0_2:
	.byte $ff,$40
	.word @chn0_0
@chn0_3:
	.byte $44,$11,$45,$11,$44,$15,$45,$11,$44,$18,$45,$15,$44,$1d,$45,$18
	.byte $44,$21,$45,$1d,$44,$1d,$45,$21,$44,$18,$45,$1d,$44,$15,$45,$18
	.byte $44,$13,$45,$15,$44,$17,$45,$13,$44,$1a,$45,$17,$44,$1f,$45,$1a
	.byte $44,$23,$45,$1f,$44,$1f,$45,$23,$44,$1a,$45,$1f,$44,$17,$45,$1a
	.byte $44,$0c,$45,$17,$44,$10,$45,$0c,$44,$13,$45,$10,$44,$18,$45,$13
	.byte $44,$1c,$45,$18,$44,$18,$45,$1c,$44,$13,$45,$18,$44,$10,$45,$13
	.byte $44,$0c,$80,$45,$10,$80,$0c,$80,$3f,$88
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_loop:
@chn1_0:
	.byte $49,$21,$82,$4a,$21,$80,$49,$21,$82,$4a,$21,$80,$49,$1f,$80,$4a
	.byte $21,$80,$49,$24,$82,$4a,$24,$86,$49,$1f,$80,$23,$80,$26,$80,$4a
	.byte $24,$80,$26,$80,$49,$26,$82,$4a,$26,$80,$49,$24,$80,$4a,$26,$80
	.byte $49,$23,$82,$4a,$23,$82,$49,$21,$82,$4a,$21,$82
@chn1_1:
	.byte $49,$21,$82,$4a,$21,$80,$49,$21,$82,$4a,$21,$80,$49,$1f,$80,$4a
	.byte $21,$80,$49,$24,$82,$4a,$24,$82,$49,$23,$82,$4a,$23,$82,$49,$21
	.byte $86,$4a,$21,$86,$49,$21,$82,$4a,$21,$82,$49,$1f,$82,$4a,$1f,$82
@chn1_2:
	.byte $ff,$40
	.word @chn1_0
@chn1_3:
	.byte $49,$24,$86,$4a,$24,$82,$49,$23,$80,$21,$80,$23,$86,$4a,$23,$82
	.byte $49,$24,$23,$81,$24,$86,$4a,$24,$86,$24,$8e
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_loop:
@chn2_0:
	.byte $41,$11,$80,$3f,$82,$11,$80,$3f,$82,$11,$80,$3f,$80,$13,$82,$3f
	.byte $86,$13,$80,$3f,$80,$18,$80,$3f,$82,$18,$80,$3f,$82,$18,$80,$3f
	.byte $80,$15,$82,$3f,$86,$15,$80,$3f,$80
@chn2_1:
	.byte $11,$80,$3f,$82,$11,$80,$3f,$82,$11,$80,$3f,$80,$13,$82,$3f,$86
	.byte $13,$80,$3f,$80,$15,$82,$3f,$8a,$15,$82,$3f,$82,$13,$86
@chn2_2:
	.byte $11,$80,$3f,$82,$11,$80,$3f,$82,$11,$80,$3f,$80,$13,$82,$3f,$86
	.byte $13,$80,$3f,$80,$18,$80,$3f,$82,$18,$80,$3f,$82,$18,$80,$3f,$80
	.byte $15,$82,$3f,$86,$15,$80,$3f,$80
@chn2_3:
	.byte $11,$80,$3f,$82,$11,$80,$3f,$82,$11,$80,$3f,$80,$13,$82,$3f,$86
	.byte $13,$80,$3f,$80,$18,$82,$3f,$9a
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_loop:
@chn3_0:
	.byte $48,$0b,$9e,$0b,$9e
@chn3_1:
	.byte $0b,$be
@chn3_2:
	.byte $0b,$9e,$0b,$9e
@chn3_3:
	.byte $ff,$40
	.word @chn3_2
	.byte $fe
	.word @chn3_loop

@chn4:
@chn4_loop:
@chn4_0:
	.byte $bf
@chn4_1:
	.byte $bf
@chn4_2:
	.byte $bf
@chn4_3:
	.byte $bf
	.byte $fe
	.word @chn4_loop
