; br2vram.s

	.module brle_to_vram

	; global from this code

    .globl  _brle2vram
    ; void *brle2vram (void *brledata,unsigned offset);
	
	.area _CODE

_brle2vram:
    pop     bc
    pop     hl
    pop     de
    push    de
    push    hl
    push    bc
    di
    ld      a,(0x1d43)
    ld      c,a  ;; (1d43h) = 0bfh
    out     (c),e
    set     6,d
    out     (c),d
    ei
    ld      a,(0x1d47)
    ld      c,a  ;; (1d47h) = 0beh
$0:
    ld      a,(hl)
    inc     hl
    cp      #0xff
    ret     z
    bit     7,a
    jr      z,$2
    and     #0x7f
    ld      d,#1    ; assume a short run of 1 to 119
    cp      #103    ; see if it is a special long run
    jr      c,$4    ; do the short run as always
    sub     #102    ; how many times through the long run
    ld      d,a     ; load up D with 256 * (length-95)
    ld      a,#255  ; B needs to do 256 steps
$4:
    inc     a
    ld      b,a
    ld      a,(hl)
    inc     hl
$1:
    out     (c),a
    nop
    nop
    djnz    $1
    dec     d		; is this the home stretch?
    jr      nz,$1	; more to do still
    jr      $0
$2:      
    inc     a
    ld      b,a
$3:            
    outi
    jr      z,$0
    jp      $3

