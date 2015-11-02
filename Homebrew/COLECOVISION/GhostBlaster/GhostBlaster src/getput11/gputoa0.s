; gputoa0.s

	.module utoa0
	
	; global from this code	
    .globl  _utoa0
    ; utoa0 (unsigned value,char *buffer)
    ; leading zeros _are_ put in buffer

	.area _CODE

count_sub:
    xor     a
$1:  
    sbc     hl,bc
    inc     a
    jr      nc,$1
    dec     a
    add     hl,bc
    add     a,#48 ;; = ascii for number 0
    ld      (de),a
    inc     de
    ret

_utoa0:
    pop     bc
    pop     hl
    pop     de
    push    de
    push    hl
    push    bc
    ld      bc,#10000
    call    count_sub
    ld      bc,#1000
    call    count_sub
    ld      bc,#100
    call    count_sub
    ld      c,#10
    call    count_sub
    ld      a,l
    add     a,#48 ;; = ascii for number 0
    ld      (de),a
    ret

