; gpscore2.s

	.module score

	.globl  _score_cmp_lt

	.globl  _score_cmp_gt
        ; score_cmp_gt (score_t *score, score_t *score)


	.area _CODE
	
_score_cmp_gt:
                pop bc
                pop de
                pop hl
                push hl
                push de
                push bc
                
                push de
                push hl
                
                call _score_cmp_lt
                
                pop bc
                pop bc
                
                ret

