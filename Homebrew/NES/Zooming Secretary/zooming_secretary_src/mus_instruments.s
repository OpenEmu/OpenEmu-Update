music_instruments:
@ins:
	.word @env_default,@env_default,@env_default
	.byte $30,$00
	.word @env_vol0,@env_default,@env_default
	.byte $30,$00
	.word @env_vol1,@env_arp0,@env_default
	.byte $30,$00
	.word @env_vol2,@env_default,@env_default
	.byte $30,$00
	.word @env_vol3,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol4,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol3,@env_default,@env_pitch0
	.byte $30,$00
	.word @env_vol4,@env_default,@env_pitch0
	.byte $30,$00
	.word @env_vol5,@env_default,@env_default
	.byte $30,$00
	.word @env_vol6,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol7,@env_default,@env_default
	.byte $b0,$00
@env_default:
	.byte $c0,$7f,$00
@env_vol0:
	.byte $cf,$7f,$00
@env_vol1:
	.byte $cf,$02,$c0,$7f,$02
@env_vol2:
	.byte $c9,$c5,$c3,$c2,$02,$c1,$02,$c0,$7f,$07
@env_vol3:
	.byte $c9,$c9,$c8,$c8,$c7,$c7,$c6,$c6,$c5,$c5,$c4,$7f,$0a
@env_vol4:
	.byte $c3,$01,$c2,$01,$c1,$01,$c0,$7f,$06
@env_vol5:
	.byte $c1,$0a,$c2,$0d,$c3,$0e,$c4,$10,$c5,$2b,$c4,$12,$c3,$14,$c2,$15
	.byte $c1,$10,$c0,$7f,$12
@env_vol6:
	.byte $c6,$c8,$c9,$c9,$ca,$05,$c9,$03,$c8,$03,$c7,$04,$c6,$03,$c5,$05
	.byte $c4,$04,$c3,$05,$c2,$04,$c1,$06,$c0,$7f,$18
@env_vol7:
	.byte $c2,$c3,$01,$c4,$0c,$c3,$08,$c2,$0e,$c1,$10,$c0,$c0,$7f,$0c
@env_arp0:
	.byte $cc,$c6,$c0,$b4,$7f,$03
@env_pitch0:
	.byte $c2,$7f,$00
