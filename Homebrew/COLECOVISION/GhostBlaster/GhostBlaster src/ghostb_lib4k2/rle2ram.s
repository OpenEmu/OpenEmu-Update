; rle2ram.s

	.module rle_to_ram

	; global from this code

    .globl  _rle2ram
    ; void *rle2ram (void *rledata,void *ptr);
	
	.area _CODE

_rle2ram:
    pop     bc
    pop     hl
    pop     de
    push    de
    push    hl
    push    bc
$0: 
    ld      a,(hl)
    inc     hl
    cp      #0xff
    ret     z
    bit     7,a
    jr      z,$2
    and     #0x7f
    inc     a
    ld      b,a
    ld      a,(hl)
    inc     hl
$1:              
    ld      (de),a
    inc     de
    djnz    $1
    jr      $0
$2:              
    inc     a
    ld      b,a
    ldir
    jr      $0
