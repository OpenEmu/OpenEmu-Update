; gpscore1.s

	.module score
	
	.globl  _score_add
	; score_add (score_t *score, unsigned value)

	.area _CODE

_score_add:
                pop de
                pop hl
                pop bc
                push bc
                push hl
                push de
                
                push hl
                
                ld e,(hl)
                inc hl
                ld d,(hl)
                inc hl
                ex de,hl
                add hl,bc
                ex de,hl
                ld c,(hl)
                inc hl
                ld b,(hl)
                ex de,hl
                or a
                ld de,#0x2710
$0:
		sbc hl,de
                inc bc
                jr nc,$0
                dec bc
                add hl,de
                ex de,hl
                pop hl
                ld (hl),e
                inc hl
                ld (hl),d
                inc hl
                ld (hl),c
                inc hl
                ld (hl),b
                ret

