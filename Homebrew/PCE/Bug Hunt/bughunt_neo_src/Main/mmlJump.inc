;-----------------------------------------------------------------------------
; jump table for MML operations

psgMMLOperations	
	.dw			bcSetTimeBase		; d0
	.dw			bcSetOctave			; d1
	.dw			bcSetOctave			; d2
	.dw			bcSetOctave			; d3
	.dw			bcSetOctave			; d4
	.dw			bcSetOctave			; d5
	.dw			bcSetOctave			; d6
	.dw			bcSetOctave			; d7
	.dw			bcOctaveUp			; d8
	.dw			bcOctaveDown		; d9
	.dw			bcTie				; da
	.dw			bcSetTempo			; db
	.dw			bcSetVoiceVolume	; dc
	.dw			bcSetPanPots		; dd
	.dw			bcSetKeyOnOffRatio	; de
	.dw			bcSetRelVol			; df
	.dw			mmlFetchNext	    ; e0 - unused (no operation)
	.dw			bcDalSegno		    ; e1 - "da se nio"
	.dw			bcSegno			    ; e2 - "se nio"
	.dw			bcRepeatStart	    ; e3 - repeat begin
	.dw			bcRepeatEnd		    ; e4 - repeat end
	.dw			bcSetWave		    ; e5 - set timbre/wave
	.dw			bcSetEnvelope	    ; e6 - set envelope
	.dw			bcSetMod		    ; e7 - frequency modulated (?)
	.dw			bcSetModDelay	    ; e8 - FM Delay
	.dw			bcSetModCorrection  ; e9 - FM correction
	.dw			bcSetPitchEnvelope  ; ea - Pitch Envelope
	.dw			bcSetPEDelay	    ; eb - Pitch Envelope Delay
	.dw			bcDetune		    ; ec - Detune
	.dw			bcSweepAmount	    ; ed - Sweep
	.dw			bcSweepTime		    ; ee - Sweep time
	.dw			bcJump			    ; ef - Jump
	.dw			bcCall			    ; f0 - Call
	.dw			bcReturn		    ; f1 - Return
	.dw			bcTranspose		    ; f2 - Transpose
	.dw			bcRelTranspose	    ; f3 - Relative Transpose
	.dw			bcAllTranspose	    ; f4 - Entire Transpose
	.dw			bcVolChange		    ; f5 - volume change
	.dw			bcPanRChange	    ; f6 - pan right change
	.dw			bcPanLChange	    ; f7 - pan left change
	.dw			bcChangeMode	    ; f8 - set mode
	.dw			mmlFetchNext	    ; f9 - unused (no operation)
	.dw			mmlFetchNext	    ; fa - unused (no operation)
	.dw			mmlFetchNext	    ; fb - unused (no operation)
	.dw			mmlFetchNext	    ; fc - unused (no operation)
	.dw			mmlFetchNext	    ; fd - unused (no operation)
	.dw			bcFadeOut		    ; fe - fade out (no operation ????)
	.dw			bcTrackDone		    ; ff - data end.
