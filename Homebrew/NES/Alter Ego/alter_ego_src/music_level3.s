music_level3_module:
	.word @chn0,@chn1,@chn2,@chn3,@chn4,music_instruments
	.byte $07

@chn0:
@chn0_loop:
@chn0_0:
	.byte $52,$13,$8e
@chn0_1:
	.byte $4f,$1d,$8e
@chn0_2:
	.byte $52,$16,$84,$55,$1a,$88
@chn0_3:
	.byte $4f,$1b,$8e
@chn0_4:
	.byte $ff,$10
	.word @chn0_0
@chn0_5:
	.byte $ff,$10
	.word @chn0_1
@chn0_6:
	.byte $52,$16,$84,$1d,$88
@chn0_7:
	.byte $ff,$10
	.word @chn0_3
@chn0_8:
	.byte $5b,$1d,$82,$5d,$22,$81,$5c,$24,$5b,$22,$81,$5c,$22,$83
@chn0_9:
	.byte $83,$3f,$88,$5b,$20,$80
@chn0_10:
	.byte $1f,$81,$22,$81,$5d,$1d,$80,$5b,$1b,$81,$5c,$1b,$5b,$18,$80,$1b
	.byte $80
@chn0_11:
	.byte $80,$5c,$1b,$85,$3f,$82,$4d,$0c,$82
@chn0_12:
	.byte $ff,$10
	.word @chn0_8
@chn0_13:
	.byte $ff,$10
	.word @chn0_9
@chn0_14:
	.byte $1f,$82,$27,$82,$5d,$22,$82,$5b,$22,$80,$24,$80
@chn0_15:
	.byte $80,$5c,$24,$85,$3f,$82,$4c,$24,$82
@chn0_16:
	.byte $52,$20,$80,$3f,$20,$80,$3f,$20,$80,$53,$1f,$86
	.byte $fe
	.word @chn0_loop

@chn1:
@chn1_loop:
@chn1_0:
	.byte $5a,$19,$80,$54,$18,$24,$5a,$19,$80,$54,$18,$80,$5a,$19,$80,$54
	.byte $15,$21,$5a,$19,$80,$54,$15,$80
@chn1_1:
	.byte $5a,$19,$80,$54,$13,$1f,$5a,$19,$80,$54,$13,$80,$5a,$19,$80,$54
	.byte $10,$1c,$5a,$19,$80,$54,$10,$80
@chn1_2:
	.byte $5a,$19,$80,$54,$1a,$26,$5a,$19,$80,$54,$1a,$80,$5a,$19,$80,$54
	.byte $22,$2e,$5a,$19,$80,$54,$22,$80
@chn1_3:
	.byte $5a,$19,$80,$54,$1f,$2b,$5a,$19,$80,$54,$1f,$80,$5a,$19,$80,$54
	.byte $1b,$27,$5a,$19,$80,$54,$1b,$80
@chn1_4:
	.byte $ff,$10
	.word @chn1_0
@chn1_5:
	.byte $ff,$10
	.word @chn1_1
@chn1_6:
	.byte $ff,$10
	.word @chn1_2
@chn1_7:
	.byte $ff,$10
	.word @chn1_3
@chn1_8:
	.byte $5a,$19,$80,$52,$14,$20,$5a,$19,$80,$52,$14,$3f,$5a,$19,$80,$52
	.byte $14,$20,$5a,$19,$80,$52,$14,$3f
@chn1_9:
	.byte $ff,$10
	.word @chn1_8
@chn1_10:
	.byte $5a,$19,$80,$52,$16,$22,$5a,$19,$80,$52,$16,$3f,$5a,$19,$80,$52
	.byte $16,$22,$5a,$19,$80,$52,$16,$3f
@chn1_11:
	.byte $ff,$10
	.word @chn1_10
@chn1_12:
	.byte $ff,$10
	.word @chn1_8
@chn1_13:
	.byte $ff,$10
	.word @chn1_8
@chn1_14:
	.byte $ff,$10
	.word @chn1_10
@chn1_15:
	.byte $ff,$10
	.word @chn1_10
@chn1_16:
	.byte $5a,$19,$80,$52,$14,$80,$5a,$19,$80,$52,$14,$80,$53,$13,$82,$5a
	.byte $19,$19,$19,$19
	.byte $fe
	.word @chn1_loop

@chn2:
@chn2_loop:
@chn2_0:
	.byte $4e,$11,$3f,$54,$11,$41,$11,$80,$11,$3f,$54,$11,$80,$11,$41,$1d
	.byte $18,$81,$18,$80
@chn2_1:
	.byte $4e,$11,$3f,$54,$11,$41,$11,$80,$11,$3f,$54,$11,$80,$11,$41,$1d
	.byte $18,$81,$0f,$80
@chn2_2:
	.byte $4e,$0c,$3f,$54,$0c,$41,$0c,$80,$0c,$3f,$54,$0c,$80,$0c,$41,$18
	.byte $13,$81,$13,$80
@chn2_3:
	.byte $4e,$0c,$3f,$54,$0c,$41,$0c,$80,$0c,$3f,$54,$0c,$80,$0c,$41,$18
	.byte $13,$81,$0f,$80
@chn2_4:
	.byte $ff,$10
	.word @chn2_0
@chn2_5:
	.byte $ff,$10
	.word @chn2_1
@chn2_6:
	.byte $ff,$10
	.word @chn2_2
@chn2_7:
	.byte $ff,$10
	.word @chn2_3
@chn2_8:
	.byte $4e,$0a,$3f,$54,$0a,$41,$0a,$80,$0a,$3f,$54,$0a,$80,$0a,$41,$16
	.byte $11,$81,$11,$80
@chn2_9:
	.byte $4e,$0a,$3f,$54,$0a,$41,$0a,$80,$0a,$3f,$54,$0a,$80,$0a,$41,$16
	.byte $11,$81,$4e,$0c,$80
@chn2_10:
	.byte $11,$3f,$54,$11,$41,$11,$80,$11,$3f,$54,$11,$80,$11,$41,$1d,$18
	.byte $81,$18,$80
@chn2_11:
	.byte $ff,$10
	.word @chn2_1
@chn2_12:
	.byte $ff,$10
	.word @chn2_8
@chn2_13:
	.byte $ff,$10
	.word @chn2_9
@chn2_14:
	.byte $ff,$10
	.word @chn2_10
@chn2_15:
	.byte $ff,$10
	.word @chn2_1
@chn2_16:
	.byte $4e,$0a,$3f,$54,$0a,$41,$0a,$80,$0a,$3f,$54,$0a,$4e,$0f,$3f,$54
	.byte $0f,$41,$0f,$80,$0c,$3f,$54,$0c
	.byte $fe
	.word @chn2_loop

@chn3:
@chn3_loop:
@chn3_0:
	.byte $41,$00,$80,$47,$0b,$80,$48,$0a,$80,$47,$0b,$80,$41,$00,$80,$47
	.byte $0b,$80,$48,$0a,$80,$47,$0b,$80
@chn3_1:
	.byte $41,$00,$80,$47,$0b,$80,$48,$0a,$80,$47,$0b,$80,$41,$00,$80,$47
	.byte $0b,$80,$48,$0a,$80,$47,$0b,$48,$0a
@chn3_2:
	.byte $ff,$10
	.word @chn3_0
@chn3_3:
	.byte $41,$00,$80,$47,$0b,$80,$48,$0a,$80,$47,$0b,$80,$41,$00,$48,$0a
	.byte $47,$0b,$80,$48,$0a,$80,$47,$0b,$80
@chn3_4:
	.byte $ff,$10
	.word @chn3_0
@chn3_5:
	.byte $ff,$10
	.word @chn3_1
@chn3_6:
	.byte $ff,$10
	.word @chn3_0
@chn3_7:
	.byte $ff,$10
	.word @chn3_3
@chn3_8:
	.byte $ff,$10
	.word @chn3_0
@chn3_9:
	.byte $ff,$10
	.word @chn3_1
@chn3_10:
	.byte $ff,$10
	.word @chn3_0
@chn3_11:
	.byte $ff,$10
	.word @chn3_3
@chn3_12:
	.byte $ff,$10
	.word @chn3_0
@chn3_13:
	.byte $ff,$10
	.word @chn3_1
@chn3_14:
	.byte $ff,$10
	.word @chn3_0
@chn3_15:
	.byte $ff,$10
	.word @chn3_3
@chn3_16:
	.byte $48,$0a,$81,$0a,$81,$0a,$84,$47,$0a,$46,$0a,$45,$0a,$44,$0a
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
	.byte $fe
	.word @chn4_loop
