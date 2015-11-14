	.module	crt0
	.globl	_main
	.globl	_vsync_flag

	;;int vector
	.area	_HEADER (ABS)
	.org 	0x00
	jp	boot
	.org	0x08
	reti
	.org	0x10
	reti
	.org	0x18
	reti
	.org	0x20
	reti
	.org	0x28
	reti
	.org	0x30
	reti
	.org	0x38
vblank:
	di
	push af
	ld	a, #0
	ld	(_vsync_flag), a
	pop af
	ei
	reti

pause_nmi:
	.org	0x66
	reti

	;;bootup code
boot:
	;disable int
	di

	;set int mode
	im		1
	
	;i/o enable
	;bit6 = cart enable
	;bit4 = ram enable
	;bit2 = i/o enable
	ld	a, #0xAB
	out	(0x3E), a
	
	;bank select
	ld	hl, #0xFFFC
	;ROM/RAM enable
	ld	(hl), #0x00
	inc	hl
	;bank select for slot 0
	ld	(hl), #0x00
	inc	hl
	;bank select for slot 1
	ld	(hl), #0x01
	inc	hl
	;bank select for slot 2
	ld	(hl), #0x02
	inc	hl

	;set sp
	ld		sp, #0xDFF0

	;wait for VDP init
	ld		b, #0x00
boot_wait_b:
	ld		c, #0x00
boot_wait_c:
	ld		d, #0x07
boot_wait_d:
	dec		d
	jp		nz, boot_wait_d
	dec		c
	jp		nz, boot_wait_c
	dec		b
	jp		nz, boot_wait_b

	;call the c-main function
	call	_main
	jp		boot

	;;Ordering of segments for the linker
	.area	_HOME
	.area	_CODE
	.area	_GSINIT
	.area	_GSFINAL
	.area	_CABS
	.area	_DATA
	.area	_BSS
	.area	_HEAP

	.area	_GSINIT
gsinit::

	.area	_GSFINAL
	ret


