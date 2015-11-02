; nmi.s

	.module nmi

	; global from this code
	.globl  _disable_nmi
	; disable_nmi (void)
	.globl  _enable_nmi
	; enable_nmi (void)
	
	.area _CODE

_disable_nmi:
	ld      a,(#0x73c4)
	and     #0xdf
$1:
	ld      c,a
	ld      b,#1
	jp      0x1fd9

_enable_nmi:
	ld      a,(#0x73c4)
	or      #0x20
	call    $1
	jp      0x1fdc
	