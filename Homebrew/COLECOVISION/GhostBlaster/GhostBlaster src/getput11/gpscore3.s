; gpscore3.s

	.module score

	.globl  _score_cmp_lt
        ; score_cmp_lt (score_t *score, score_t *score)

	.area _CODE

_score_cmp_lt:
                pop bc
                pop de
                pop hl
                push hl
                push de
                push bc
                
                push hl
                push de
                
                inc hl
                inc hl
                ld c,(hl)
                inc hl
                ld b,(hl)

                ex de,hl

                inc hl
                inc hl
                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a
                
                or a
                sbc hl,bc
                
                jr c,$1
                jr nz,$0
                
                pop de
                pop hl
                push hl
                push de
                
                ld c,(hl)
                inc hl
                ld b,(hl)

                ex de,hl

                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a
                
                sbc hl,bc
                
                jr c,$1

$0:
                ld hl,#0x0000
                jr $2
$1:
                ld hl,#0x0001
$2:
                pop bc
                pop bc
                ret

