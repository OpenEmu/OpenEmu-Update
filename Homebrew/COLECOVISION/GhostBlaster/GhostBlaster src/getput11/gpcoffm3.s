; gpcoff3.s

;*********** CALC_OFFSET ************
; INPUT : d = y, e = x;
; OUTPUT : de = NAME + y * 32 + x;

	.module calc_offset3
	
	; global from this code	
    .globl  calc_offset3

	.area _CODE

calc_offset3:
        push    hl
        ld      a,d
        and     #7
        ld      l,a
        ld      a,d
        sub     a,l
        rrca
        rrca
        rrca
        ld      h,a
        ld      a,e
        and     #0x3e
        add     a,a
        add     a,a
        add     a,l
        ld      l,a
        ex      de,hl
        pop     hl
        ret


;        push    hl
;        push    de
;        ld      h,#0
;        ld      a,d
;        and     #0x38
;        ld      l,a
;        add     hl,hl
;        add     hl,hl
;        add     hl,hl
;        ld      a,e
;        and     #0x3e
;        ld      d,#0
;        ld      e,a
;        add     hl,de
;        add     hl,hl
;        add     hl,hl
;        pop     de
;        ld      a,d
;        and     #7
;        or      l
;        ld      l,a
;        ex      de,hl
;        pop     hl
;        ret
