;-----------------------------------------------------------------------------
; this is the table of counts to delay main track, when on timer (I think)
;-----------------------------------------------------------------------------

defaultDelays
	.db		$00			; Main only, @ 60Hz
	.db		$00			; Sub  only, @ 60Hz
	.db		$00			; Both,      @ 60Hz
	.db		$01			; Both,      @ 120Hz  (Main = 60Hz)
	.db		$03			; Both,      @ 240Hz  (Main = 60Hz)
	.db		$04			; Both,      @ 300Hz  (Main = 60Hz)
	
