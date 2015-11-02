; delay.s

	.module delay

	; global from external code
	.globl  _nmi_flag

	; global from this code
	.globl  _delay
	; delay (unsigned icount)
	
	.area _CODE
_delay:
	pop     hl
	pop     de
	push    de
	push    hl
	ld      a,(#0x73c4)       ; check if NMI enabled
	and     #0x20
	jr      z,$3
$1:              
	ld      a,e             ; NMI enabled, check _nmi_flag
	or      d
	ret     z
	xor     a
	ld      (_nmi_flag),a
$2:      
	ld      a,(_nmi_flag)
	or      a
	jr      z,$2
	dec     de
	jr      $1
$3:      
	call    #0x1fdc           ; NMI disabled, check VDP status
$4:      
	ld      a,e
	or      d
	ret     z
$5:      
	call    #0x1fdc
	rlca
	jr      nc,$5
	dec     de
	jr      $4