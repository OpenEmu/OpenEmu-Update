; ascii.s

	.module ascii
	
	; global from external code	
	.globl  indir
	
	; global from this code
	.globl _upload_ascii
	
	; upload_ascii (byte first,byte count,
	;               unsigned offset,byte flags);
	; flags are as follows:
	; bit
	; 0 - italic
	; 1 - bold
	
	.area _CODE
_upload_ascii: 
    pop     de
    pop     hl
    exx
    pop     de
    ld      a,(0x1d43)
    ld      c,a
    di
    out     (c),e
    set     6,d
    out     (c),d
    ei
    pop     bc
    ld      a,c
    push    bc
    exx
    push    hl
    push    hl
    push    de
    ld      c,h
    ld      h,#0
    add     hl,hl
    add     hl,hl
    add     hl,hl
    ld      de,(0x006a)
    add     hl,de
    ld      de,#-65*8
    add     hl,de
    exx
    ld      hl,#upload_procs
    and     #3
    add     a,a
    add     a,l
    ld      l,a
    ld      a,#0
    adc     a,h
    ld      h,a
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    exx
    ld      a,c
    exx
    ld      b,a
    exx
    ld      a,(0x1d47)
    ld      c,a
    exx
$1: 
    call    indir
    djnz    $1
    ret

    normal:
    exx
    ld      b,#8
$2:      
    outi
    nop
    nop
    jp      nz,$2
    exx
    ret

    italic:
    exx
    ld      b,#4
$3:
    ld      a,(hl)
    inc     hl
    rrca
    and     #0x7f
    out     (c),a
    djnz    $3
    ld      b,#4
$4:
    outi
    nop
    nop
    jp      nz,$4
    exx
    ret

    bold:
    exx
    ld      b,#8
$5:
    ld      a,(hl)
    inc     hl
    ld      d,a
    rrca
    and     #0x7f
    or      d
    out     (c),a
    djnz    $5
    exx
    ret

    bold_italic:
    exx
    ld      b,#4
$6:
    ld      a,(hl)
    inc     hl
    ld      d,a
    rrca
    and     #0x7f
    or      d
    rrca
    and     #0x7f
    out     (c),a
    djnz    $6
    ld      b,#4
$7:
    ld      a,(hl)
    inc     hl
    ld      d,a
    rrca
    and     #0x7f
    or      d
    out     (c),a
    djnz    $7
    exx
    ret

upload_procs::
    .dw    normal
    .dw    italic
    .dw    bold
    .dw    bold_italic
