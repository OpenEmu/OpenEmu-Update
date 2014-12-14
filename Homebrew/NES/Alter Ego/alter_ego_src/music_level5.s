music_level5_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $05

@chn0:
@chn0_loop:
@chn0_0:
	.byte $44,$1a,$1d,$24,$21,$45,$1a,$1d,$24,$21,$46,$1a,$1d,$24,$21,$47
	.byte $1a,$1d,$24,$21
@chn0_1:
	.byte $44,$1a,$1d,$45,$24,$21,$44,$1a,$45,$1d,$44,$26,$23,$1c,$1f,$45
	.byte $26,$23,$1c,$1f,$46,$26,$23
@chn0_2:
	.byte $ff,$10
	.word @chn0_0
@chn0_3:
	.byte $ff,$10
	.word @chn0_1
@chn0_4:
	.byte $50,$21,$80,$4c,$21,$80,$45,$21,$82,$46,$21,$80,$50,$1f,$80,$21
	.byte $80,$23,$80
@chn0_5:
	.byte $4c,$23,$80,$45,$23,$80,$50,$24,$80,$4c,$24,$80,$50,$23,$80,$4c
	.byte $23,$80,$50,$1f,$80,$4c,$1f,$80
@chn0_6:
	.byte $ff,$10
	.word @chn0_4
@chn0_7:
	.byte $4c,$23,$80,$45,$23,$80,$50,$26,$80,$4c,$26,$80,$50,$1f,$80,$4c
	.byte $1f,$80,$50,$1c,$80,$4c,$1c,$80
@chn0_8:
	.byte $ff,$10
	.word @chn0_0
@chn0_9:
	.byte $ff,$10
	.word @chn0_1
@chn0_10:
	.byte $44,$1d,$21,$28,$24,$45,$1d,$21,$28,$24,$46,$1d,$21,$28,$24,$47
	.byte $1d,$21,$28,$24
@chn0_11:
	.byte $44,$1d,$21,$45,$28,$24,$44,$1d,$45,$21,$44,$26,$23,$1c,$1f,$45
	.byte $26,$23,$1c,$1f,$46,$26,$23
@chn0_12:
	.byte $ff,$10
	.word @chn0_4
@chn0_13:
	.byte $ff,$10
	.word @chn0_5
@chn0_14:
	.byte $ff,$10
	.word @chn0_4
@chn0_15:
	.byte $4c,$23,$80,$45,$23,$80,$50,$28,$80,$4c,$28,$80,$50,$26,$80,$4c
	.byte $26,$80,$50,$24,$80,$4c,$24,$80
@chn0_16:
	.byte $83,$5b,$27,$82,$26,$82,$24,$82
@chn0_17:
	.byte $54,$2d,$80,$2b,$47,$2d,$54,$29,$47,$2b,$54,$24,$47,$29,$54,$21
	.byte $47,$24,$54,$1f,$47,$21,$54,$1d,$47,$1f,$54,$18,$47,$1d
@chn0_18:
	.byte $54,$15,$47,$18,$54,$13,$47,$15,$54,$11,$47,$13,$54,$0c,$47,$11
	.byte $80,$0c,$85
@chn0_19:
	.byte $54,$2f,$80,$2d,$47,$2f,$54,$2b,$47,$2d,$54,$26,$47,$2b,$54,$23
	.byte $47,$26,$54,$21,$47,$23,$54,$1f,$47,$21,$54,$1a,$47,$1f
@chn0_20:
	.byte $54,$17,$47,$1a,$54,$15,$47,$17,$54,$13,$47,$15,$54,$0e,$47,$13
	.byte $80,$0e,$85
@chn0_21:
	.byte $ff,$10
	.word @chn0_17
@chn0_22:
	.byte $ff,$10
	.word @chn0_18
@chn0_23:
	.byte $ff,$10
	.word @chn0_19
@chn0_24:
	.byte $ff,$10
	.word @chn0_20
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_loop:
@chn1_0:
	.byte $55,$15,$8e
@chn1_1:
	.byte $15,$82,$15,$80,$17,$88
@chn1_2:
	.byte $15,$8e
@chn1_3:
	.byte $ff,$10
	.word @chn1_1
@chn1_4:
	.byte $54,$16,$1a,$21,$1d,$16,$1a,$21,$1d,$16,$1a,$21,$1d,$16,$1a,$21
	.byte $1d
@chn1_5:
	.byte $18,$1c,$23,$1f,$18,$1c,$23,$1f,$18,$1c,$23,$1f,$18,$1c,$23,$1f
@chn1_6:
	.byte $16,$1a,$21,$1d,$16,$1a,$21,$1d,$16,$1a,$21,$1d,$16,$1a,$21,$1d
@chn1_7:
	.byte $ff,$10
	.word @chn1_5
@chn1_8:
	.byte $ff,$10
	.word @chn1_0
@chn1_9:
	.byte $ff,$10
	.word @chn1_1
@chn1_10:
	.byte $ff,$10
	.word @chn1_2
@chn1_11:
	.byte $ff,$10
	.word @chn1_1
@chn1_12:
	.byte $ff,$10
	.word @chn1_4
@chn1_13:
	.byte $ff,$10
	.word @chn1_5
@chn1_14:
	.byte $ff,$10
	.word @chn1_6
@chn1_15:
	.byte $ff,$10
	.word @chn1_5
@chn1_16:
	.byte $83,$58,$19,$82,$18,$82,$16,$82
@chn1_17:
	.byte $4f,$1d,$8e
@chn1_18:
	.byte $5d,$1d,$86,$5b,$1a,$82,$5c,$1a,$82
@chn1_19:
	.byte $4f,$18,$8e
@chn1_20:
	.byte $58,$1c,$82,$1d,$82,$1f,$82,$21,$82
@chn1_21:
	.byte $ff,$10
	.word @chn1_17
@chn1_22:
	.byte $5b,$1c,$80,$42,$1d,$80,$5d,$1a,$82,$5c,$1c,$82,$5b,$1a,$80,$18
	.byte $80
@chn1_23:
	.byte $ff,$10
	.word @chn1_19
@chn1_24:
	.byte $47,$10,$0c,$13,$10,$46,$17,$13,$1a,$17,$45,$1c,$1a,$1f,$1c,$44
	.byte $23,$1f,$26,$23
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_loop:
@chn2_0:
	.byte $4e,$0e,$81,$41,$0e,$81,$4e,$0e,$82,$41,$0e,$80,$4e,$0e,$80,$41
	.byte $0e,$80
@chn2_1:
	.byte $4e,$0e,$81,$41,$0e,$81,$4e,$0e,$82,$41,$0e,$80,$4e,$15,$80,$41
	.byte $15,$80
@chn2_2:
	.byte $ff,$10
	.word @chn2_0
@chn2_3:
	.byte $ff,$10
	.word @chn2_1
@chn2_4:
	.byte $4e,$13,$81,$41,$13,$81,$4e,$13,$82,$41,$13,$80,$4e,$13,$80,$41
	.byte $13,$80
@chn2_5:
	.byte $4e,$15,$81,$41,$15,$81,$4e,$15,$82,$41,$15,$80,$4e,$0e,$80,$41
	.byte $0e,$80
@chn2_6:
	.byte $ff,$10
	.word @chn2_4
@chn2_7:
	.byte $4e,$15,$81,$41,$15,$81,$4e,$15,$82,$41,$15,$80,$4e,$15,$80,$41
	.byte $15,$80
@chn2_8:
	.byte $ff,$10
	.word @chn2_0
@chn2_9:
	.byte $ff,$10
	.word @chn2_1
@chn2_10:
	.byte $ff,$10
	.word @chn2_0
@chn2_11:
	.byte $ff,$10
	.word @chn2_1
@chn2_12:
	.byte $ff,$10
	.word @chn2_4
@chn2_13:
	.byte $ff,$10
	.word @chn2_5
@chn2_14:
	.byte $ff,$10
	.word @chn2_4
@chn2_15:
	.byte $ff,$10
	.word @chn2_7
@chn2_16:
	.byte $5a,$1f,$80,$3f,$80,$42,$14,$82,$13,$82,$11,$82
@chn2_17:
	.byte $4e,$0e,$82,$3f,$80,$41,$0e,$80,$54,$1a,$80,$0e,$80,$0e,$80,$4e
	.byte $0e,$80
@chn2_18:
	.byte $80,$3f,$54,$0e,$80,$41,$0e,$82,$54,$1a,$80,$26,$80,$4e,$0e,$82
@chn2_19:
	.byte $15,$82,$3f,$80,$41,$15,$80,$54,$21,$80,$15,$80,$15,$80,$4e,$15
	.byte $80
@chn2_20:
	.byte $80,$3f,$54,$15,$80,$41,$15,$82,$54,$21,$80,$2d,$80,$4e,$15,$82
@chn2_21:
	.byte $0e,$82,$3f,$80,$41,$0e,$80,$54,$1a,$80,$0e,$80,$0e,$80,$4e,$0e
	.byte $80
@chn2_22:
	.byte $ff,$10
	.word @chn2_18
@chn2_23:
	.byte $ff,$10
	.word @chn2_19
@chn2_24:
	.byte $ff,$10
	.word @chn2_20
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_loop:
@chn3_0:
	.byte $41,$00,$80,$46,$0d,$80,$48,$0a,$80,$46,$0d,$80,$0f,$80,$41,$00
	.byte $80,$48,$0a,$80,$46,$0d,$80
@chn3_1:
	.byte $41,$00,$80,$46,$0d,$80,$48,$0a,$80,$46,$0d,$80,$0f,$80,$41,$00
	.byte $80,$48,$0a,$80,$41,$00,$80
@chn3_2:
	.byte $00,$80,$46,$0d,$80,$48,$0a,$80,$46,$0d,$80,$0f,$80,$41,$00,$80
	.byte $48,$0a,$80,$46,$0d,$80
@chn3_3:
	.byte $ff,$10
	.word @chn3_1
@chn3_4:
	.byte $ff,$10
	.word @chn3_2
@chn3_5:
	.byte $ff,$10
	.word @chn3_1
@chn3_6:
	.byte $ff,$10
	.word @chn3_2
@chn3_7:
	.byte $ff,$10
	.word @chn3_1
@chn3_8:
	.byte $ff,$10
	.word @chn3_2
@chn3_9:
	.byte $ff,$10
	.word @chn3_1
@chn3_10:
	.byte $ff,$10
	.word @chn3_2
@chn3_11:
	.byte $ff,$10
	.word @chn3_1
@chn3_12:
	.byte $ff,$10
	.word @chn3_2
@chn3_13:
	.byte $ff,$10
	.word @chn3_1
@chn3_14:
	.byte $ff,$10
	.word @chn3_2
@chn3_15:
	.byte $ff,$10
	.word @chn3_1
@chn3_16:
	.byte $4f,$01,$8e
@chn3_17:
	.byte $41,$00,$80,$46,$0f,$80,$0d,$80,$41,$00,$80,$54,$08,$80,$46,$0f
	.byte $80,$0d,$80,$41,$00,$80
@chn3_18:
	.byte $46,$0d,$80,$0f,$80,$41,$00,$80,$46,$0f,$80,$54,$08,$80,$46,$0f
	.byte $80,$0d,$80,$0f,$80
@chn3_19:
	.byte $ff,$10
	.word @chn3_17
@chn3_20:
	.byte $ff,$10
	.word @chn3_18
@chn3_21:
	.byte $ff,$10
	.word @chn3_0
@chn3_22:
	.byte $ff,$10
	.word @chn3_1
@chn3_23:
	.byte $ff,$10
	.word @chn3_2
@chn3_24:
	.byte $ff,$10
	.word @chn3_1
	.byte $fe
	.word @chn3_loop

@chn4:
@chn4_loop:
@chn4_0:
	.byte $8f
@chn4_1:
	.byte $8f
@chn4_2:
	.byte $8f
@chn4_3:
	.byte $8f
@chn4_4:
	.byte $8f
@chn4_5:
	.byte $8f
@chn4_6:
	.byte $8f
@chn4_7:
	.byte $8f
@chn4_8:
	.byte $8f
@chn4_9:
	.byte $8f
@chn4_10:
	.byte $8f
@chn4_11:
	.byte $8f
@chn4_12:
	.byte $8f
@chn4_13:
	.byte $8f
@chn4_14:
	.byte $8f
@chn4_15:
	.byte $8f
@chn4_16:
	.byte $8f
@chn4_17:
	.byte $8f
@chn4_18:
	.byte $8f
@chn4_19:
	.byte $8f
@chn4_20:
	.byte $8f
@chn4_21:
	.byte $8f
@chn4_22:
	.byte $8f
@chn4_23:
	.byte $8f
@chn4_24:
	.byte $8f
	.byte $fe
	.word @chn4_loop
