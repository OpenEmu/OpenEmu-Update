; gpcls.s

		.module cls

		.globl  _cls
		; cls ()

    .AREA   _CODE

_cls:		
		ld	hl,(0x73F6)
		ld	de,#0x0300	; de = 300h
		ld      a,#32		;a = chr(32)
		call	0x1F82
		ret
