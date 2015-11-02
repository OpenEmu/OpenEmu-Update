; gpchar.s

	.module upload_default_ascii
	
	; global from external code	
	.globl  _upload_ascii	; from coleco library

	; global from this code
	.globl  _upload_default_ascii
	; void upload_default_ascii (byte flags)

	.area _CODE
	
_upload_default_ascii:
		pop	bc
		pop	hl
		push	hl
		push	bc

		push	hl		; flags

		ld	hl,(0x73F8) 	; offset in VRAM for charset pattern
		ld	bc,#0x00E8	; offset for chr# 29 (00e8h = 29*8)
		add	hl,bc
		push	hl

		ld	h,#128-29	; characters 29 to 128
		ld	l,#29		; start at chr# 29
		push	hl

		call	_upload_ascii

		pop bc
		pop bc
		pop bc

		ret
