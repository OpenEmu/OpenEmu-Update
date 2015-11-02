; gpcaloff.s

;*********** CALC_OFFSET ************
; INPUT : d = y, e = x;
; OUTPUT : de = NAME + y * 32 + x;

	.module calc_offset
	
	; global from this code	
    .globl  calc_offset

	.area _CODE

calc_offset:
        call    0x08C0       ; calc offset by Coleco bios
        push    hl
        ld      hl,(0x73f6)  ; hl = Name Table Offset
        add     hl,de
        ex      de,hl        ; de = NAME + y * 32 + x
        pop     hl
        ret



