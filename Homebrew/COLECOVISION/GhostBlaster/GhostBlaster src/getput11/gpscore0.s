; gpscore0.s

	.module score
	
        .globl  _score_reset
        ; score_reset (score_t *score)

	.area _CODE
    
_score_reset:
                pop bc
                pop hl
                push hl
                push bc
                xor a
                ld (hl),a
                inc hl
                ld (hl),a
                inc hl
                ld (hl),a
                inc hl
                ld (hl),a
                ret

