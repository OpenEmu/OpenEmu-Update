; gpscore6.s

	.module score

	.globl  _score_copy
	; score_copy (score_t *score_source, score_t *score_destination)

	.area _CODE

_score_copy:
                pop bc
                pop hl
                pop de
                push de
                push hl
                push bc
                ld bc,#4
                ldir
                ret

