env_default
	.db $c0,$7f,$00
env_vol0
	.db $cf,$7f,$00
env_vol1
	.db $c7,$c6,$c6,$c5,$c5,$c4,$c4,$c3,$06,$c2,$10,$c1,$0c,$c0,$7f,$0d
env_vol2
	.db $ca,$c3,$c2,$c1,$04,$c0,$7f,$05
env_vol3
	.db $c9,$c7,$c6,$c5,$c4,$c4,$c3,$c3,$c2,$08,$c1,$07,$c0,$7f,$0c
env_vol4
	.db $c4,$c3,$c2,$05,$c1,$08,$c0,$7f,$06
env_vol5
	.db $c0,$05,$7f,$01
env_vol6
	.db $c9,$c9,$c8,$03,$c7,$05,$c6,$07,$c5,$08,$c4,$0a,$c3,$0e,$c2,$0f
	.db $c1,$0e,$c0,$7f,$12
env_vol7
	.db $cf,$cf,$c0,$7f,$02
env_vol8
	.db $c3,$03,$c4,$03,$c2,$07,$c1,$0a,$c0,$7f,$08
env_vol9
	.db $cf,$03,$c0,$7f,$02
env_vol10
	.db $c5,$c5,$c4,$c4,$c3,$c3,$c2,$04,$c1,$05,$c0,$7f,$0a
env_vol11
	.db $c2,$07,$c1,$08,$c0,$7f,$04
env_vol12
	.db $c4,$03,$c0,$7f,$02
env_vol13
	.db $cf,$7f,$00
env_vol14
	.db $c1,$08,$c2,$08,$c3,$08,$c2,$08,$c1,$08,$c0,$7f,$0a
env_vol15
	.db $c4,$c5,$c6,$c6,$c5,$c4,$c3,$c2,$04,$c1,$04,$c0,$7f,$0b
env_arp0
	.db $c6,$c0,$7f,$01
env_arp1
	.db $cc,$ce,$c0,$7f,$02
env_arp2
	.db $d2,$cc,$c0,$7f,$02
env_pitch0
	.db $c1,$0b,$c2,$c2,$c3,$c3,$c4,$c4,$c3,$c3,$c2,$c2,$c1,$c1,$7f,$02
env_pitch1
	.db $c0,$10,$c1,$c2,$c3,$c4,$c5,$c6,$c5,$c4,$c3,$c2,$c1,$c0,$7f,$02
env_pitch2
	.db $c4,$7f,$00
env_pitch3
	.db $c1,$c1,$c2,$c2,$c1,$c1,$c0,$c0,$7f,$00
bgm_instruments
	.dw env_default,env_default,env_default
	.db $30,$00
	.dw env_vol0,env_default,env_pitch1
	.db $30,$00
	.dw env_vol1,env_default,env_default
	.db $70,$00
	.dw env_vol6,env_default,env_pitch0
	.db $b0,$00
	.dw env_vol2,env_default,env_default
	.db $30,$00
	.dw env_vol3,env_default,env_default
	.db $30,$00
	.dw env_vol4,env_default,env_pitch1
	.db $b0,$00
	.dw env_vol6,env_default,env_pitch0
	.db $30,$00
	.dw env_vol7,env_arp0,env_default
	.db $30,$00
	.dw env_vol8,env_arp1,env_default
	.db $30,$00
	.dw env_vol4,env_default,env_default
	.db $30,$00
	.dw env_vol9,env_default,env_default
	.db $30,$00
	.dw env_vol10,env_default,env_default
	.db $70,$00
	.dw env_vol11,env_default,env_default
	.db $70,$00
	.dw env_vol12,env_arp1,env_default
	.db $30,$00
	.dw env_vol6,env_default,env_default
	.db $b0,$00
	.dw env_vol4,env_default,env_default
	.db $70,$00
	.dw env_vol1,env_default,env_pitch2
	.db $70,$00
	.dw env_vol13,env_arp2,env_default
	.db $30,$00
	.dw env_vol15,env_default,env_default
	.db $30,$00