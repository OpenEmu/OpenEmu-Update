; gpscore5.s

	.module score

	.globl  _utoa0
	.globl  _score_str
        ; char *score_str(score_t *s, unsigned nb_digits)

	.area _DATA

score_string:
	.ds    10

	.area _CODE

_score_str:
                pop de
                pop hl
                pop bc
                push bc
                push hl
                push de
                
                push bc

                ld e,(hl)
                inc hl
                ld d,(hl)
                inc hl
                
                push hl
                
                ld bc,#score_string+4
                
                push bc
                push de
                call _utoa0
                pop bc
                pop bc
                
                pop hl

                ld e,(hl)
                inc hl
                ld d,(hl)
                
                ld bc,#score_string
                
                push bc
                push de
                call _utoa0
                pop bc
                pop bc
                
                xor a
                ld (score_string+9),a
                
                pop bc
                ld hl,#9
                sbc hl,bc
                ld de,#score_string
                add hl,de
                
                ret
