music_instruments:
@ins:
	.word @env_default,@env_default,@env_default
	.byte $30,$00
	.word @env_vol0,@env_arp1,@env_default
	.byte $30,$00
	.word @env_vol1,@env_default,@env_default
	.byte $70,$00
	.word @env_vol2,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol2,@env_default,@env_default
	.byte $30,$00
	.word @env_vol3,@env_default,@env_default
	.byte $30,$00
	.word @env_vol4,@env_default,@env_default
	.byte $30,$00
	.word @env_vol5,@env_default,@env_default
	.byte $30,$00
	.word @env_vol2,@env_arp0,@env_default
	.byte $30,$00
	.word @env_vol1,@env_arp2,@env_default
	.byte $70,$00
	.word @env_vol4,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol6,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol7,@env_arp3,@env_default
	.byte $b0,$00
	.word @env_vol7,@env_arp4,@env_default
	.byte $b0,$00
	.word @env_vol8,@env_arp1,@env_default
	.byte $30,$00
	.word @env_vol9,@env_arp5,@env_default
	.byte $30,$00
	.word @env_vol1,@env_arp1,@env_default
	.byte $70,$00
	.word @env_vol6,@env_default,@env_default
	.byte $30,$00
	.word @env_vol9,@env_arp10,@env_default
	.byte $b0,$00
	.word @env_vol9,@env_arp7,@env_default
	.byte $b0,$00
	.word @env_vol11,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol9,@env_arp8,@env_default
	.byte $b0,$00
	.word @env_vol9,@env_arp9,@env_default
	.byte $b0,$00
	.word @env_default,@env_default,@env_pitch1
	.byte $70,$00
	.word @env_vol10,@env_default,@env_default
	.byte $b0,$00
	.word @env_vol1,@env_arp11,@env_default
	.byte $b0,$00
	.word @env_vol12,@env_arp12,@env_default
	.byte $b0,$00
	.word @env_vol10,@env_default,@env_default
	.byte $70,$00
	.word @env_vol6,@env_default,@env_pitch1
	.byte $70,$00
	.word @env_vol9,@env_arp2,@env_default
	.byte $70,$00
	.word @env_vol9,@env_arp6,@env_default
	.byte $b0,$00
	.word @env_vol9,@env_arp13,@env_default
	.byte $b0,$00
@env_default:
	.byte $c0,$7f,$00
@env_vol0:
	.byte $cf,$06,$c0,$7f,$02
@env_vol1:
	.byte $cf,$ce,$cd,$cc,$cb,$ca,$c9,$c1,$7f,$07
@env_vol2:
	.byte $cf,$cd,$cb,$c9,$c7,$c5,$c3,$c1,$c0,$7f,$08
@env_vol3:
	.byte $cb,$ca,$c8,$c7,$c5,$c4,$c3,$c1,$c0,$7f,$08
@env_vol4:
	.byte $c8,$c7,$c6,$c5,$c4,$c3,$c2,$c1,$c0,$7f,$08
@env_vol5:
	.byte $c4,$c4,$c3,$c3,$c2,$c2,$c1,$c1,$c0,$7f,$08
@env_vol6:
	.byte $c4,$7f,$00
@env_vol7:
	.byte $c2,$7f,$00
@env_vol8:
	.byte $cf,$7f,$00
@env_vol9:
	.byte $cc,$01,$cb,$04,$ca,$03,$c9,$04,$c8,$03,$c7,$03,$c6,$04,$c5,$03
	.byte $c4,$04,$c3,$03,$c2,$04,$c1,$03,$c0,$7f,$18
@env_vol10:
	.byte $cf,$ce,$ce,$cd,$cd,$cc,$01,$cb,$cb,$ca,$ca,$c9,$c9,$c8,$c8,$c7
	.byte $c7,$c6,$01,$c5,$c5,$c4,$c4,$c3,$c3,$c2,$c2,$c1,$c1,$c0,$7f,$1d
@env_vol11:
	.byte $cf,$cf,$c0,$7f,$02
@env_vol12:
	.byte $cf,$03,$c0,$7f,$02
@env_arp0:
	.byte $c7,$c3,$c0,$bd,$7f,$02
@env_arp1:
	.byte $cc,$c0,$7f,$01
@env_arp2:
	.byte $c0,$01,$c1,$c2,$7f,$03
@env_arp3:
	.byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5,$b4,$b3,$b2,$b1
	.byte $b0,$af,$ae,$ad,$ac,$ab,$aa,$a9,$a8,$a7,$a6,$a5,$a4,$a3,$a2,$a1
	.byte $7f,$1f
@env_arp4:
	.byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
	.byte $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd,$de,$df
	.byte $7f,$1f
@env_arp5:
	.byte $ce,$c0,$01,$c7,$01,$c4,$01,$cb,$01,$7f,$00
@env_arp6:
	.byte $c0,$01,$c6,$01,$cb,$01,$c6,$01,$7f,$00
@env_arp7:
	.byte $c0,$01,$c6,$01,$ca,$01,$c6,$01,$7f,$00
@env_arp8:
	.byte $c0,$01,$c5,$01,$c8,$01,$c5,$01,$7f,$00
@env_arp9:
	.byte $c0,$01,$c6,$01,$c9,$01,$c6,$01,$7f,$00
@env_arp10:
	.byte $c0,$01,$c5,$01,$c9,$01,$c5,$01,$7f,$00
@env_arp11:
	.byte $c0,$c7,$c7,$c0,$7f,$03
@env_arp12:
	.byte $c0,$bc,$b8,$b4,$b0,$7f,$04
@env_arp13:
	.byte $c0,$01,$c4,$01,$c9,$01,$c4,$01,$7f,$00
@env_pitch0:
	.byte $c0,$7f,$00
@env_pitch1:
	.byte $c2,$c4,$c6,$c4,$c2,$c0,$be,$bc,$ba,$bc,$be,$c0,$7f,$00
