;-----------------------------------------------------------------------------
; jump table for MML operations

psgSubMMLOperations	
	.dw			bcSubSetTimeBase		; d0
	.dw			bcSubSetOctave			; d1
	.dw			bcSubSetOctave			; d2
	.dw			bcSubSetOctave			; d3
	.dw			bcSubSetOctave			; d4
	.dw			bcSubSetOctave			; d5
	.dw			bcSubSetOctave			; d6
	.dw			bcSubSetOctave			; d7
	.dw			bcSubOctaveUp			; d8
	.dw			bcSubOctaveDown			; d9
	.dw			bcSubTie				; da
	.dw			mmlSubFetchNext			; db
	.dw			bcSubSetVoiceVolume		; dc
	.dw			bcSubSetPanPots			; dd
	.dw			bcSubSetKeyOnOffRatio	; de
	.dw			bcSubSetRelVol			; df
	.dw			mmlSubFetchNext	    	; e0 - unused (no operation)
	.dw			bcSubDalSegno		    ; e1 - "da se nio"
	.dw			bcSubSegno			    ; e2 - "se nio"
	.dw			bcSubRepeatStart	    ; e3 - repeat begin
	.dw			bcSubRepeatEnd	 	    ; e4 - repeat end
	.dw			bcSubSetWave		    ; e5 - set timbre/wave
	.dw			bcSubSetEnvelope	    ; e6 - set envelope
	.dw			bcSubSetMod			    ; e7 - frequency modulated (?)
	.dw			bcSubSetModDelay	    ; e8 - FM Delay
	.dw			bcSubSetModCorrection  	; e9 - FM correction
	.dw			bcSubSetPitchEnvelope	; ea - Pitch Envelope
	.dw			bcSubSetPEDelay		    ; eb - PE Delay
	.dw			bcSubDetune			    ; ec - Detune
	.dw			bcSubSweep			    ; ed - Sweep
	.dw			bcSubSweepTime		    ; ee - Sweep time
	.dw			bcSubJump			    ; ef - Jump
	.dw			bcSubCall			    ; f0 - Call
	.dw			bcSubReturn	    		; f1 - Return
	.dw			bcSubTranspose	   	 	; f2 - Transpose
	.dw			bcSubRelTranspose   	; f3 - Relative Transpose
	.dw			bcSubAllTranspose    	; f4 - Entire Transpose
	.dw			bcSubVolChange		    ; f5 - volume change
	.dw			bcSubPanRChange		    ; f6 - pan right change
	.dw			bcSubPanLChange		    ; f7 - pan left change
	.dw			bcSubChangeMode		    ; f8 - set mode
	.dw			mmlSubFetchNext		    ; f9 - unused (no operation)
	.dw			mmlSubFetchNext	   	 	; fa - unused (no operation)
	.dw			mmlSubFetchNext	   	 	; fb - unused (no operation)
	.dw			mmlSubFetchNext	    	; fc - unused (no operation)
	.dw			mmlSubFetchNext	    	; fd - unused (no operation)
	.dw			bcSubFadeOut		    ; fe - fade out (no operation ????)
	.dw			bcSubTrackDone		    ; ff - data end.
								    ;    - this returns from mml handling ???