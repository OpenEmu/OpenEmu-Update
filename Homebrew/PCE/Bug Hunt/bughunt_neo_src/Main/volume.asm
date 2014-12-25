;-----------------------------------------------------------------------------
; relative volume/pan pot change
; called from main track PSG driver
;

processVolume

	;..........................................................................
	; check for any changes to main voice volume
	
	ldx		psgCurrentVoice					; get voice to work on
	lda		psgMainVolumeChangeAmount,x		; amount of change to apply to voice
	beq		.noMainChange
	
	;..........................................................................
	; is it a negative change (ie, get quieter) ?
	
	bmi		.doNeg
	
	;..........................................................................
	; no, it's a positive change (ie, get louder)
	
	clc											; set up for add
	adc			psgMainVolumeChangeAccum,x		; add to fractional volume
	sta			<psgTemp1						; save in temp
	rol			a								; multiply by 4
	rol			a
	and			#$01							; and add 1
	
	clc
	adc			psgMainVoiceVolume,x	 		; add to channel volume
	
	beq			.saveVol						; if in range, don't clip it
	bmi			.saveVol
	
	cla											; went out of range, clip
	stz			psgMainVolumeChangeAmount,x		; max volume (?)
	bra			.saveVol
	
	;..........................................................................
	; handle a negative change
	
.doNeg
	eor		#$FF								; 2's complement of value
	inc		a

	clc											; set up for add
	adc		psgMainVolumeChangeAccum,x			; add in fractional changes
	sta		<psgTemp1
	
	rol		a						; times 4	
	rol		a
	and		#$01					; original sign bit
	sta		<psgTemp2
	
	lda		psgMainVoiceVolume,x
	sec
	sbc		<psgTemp2				; subtract sign (?)
	beq		.saveVol				; if 0, we're in range
	
	cmp		#$e1					; exact max is in range
	bcs		.saveVol
	
	lda		#$e1							; force to min
	stz		psgMainVolumeChangeAmount,x		; min volume
	
	;..........................................................................
	; A should now have ($1f-volume). save it, and any fraction left over
	
.saveVol

	sta		psgMainVoiceVolume,x
	lda		<psgTemp1						; get change fraction
	and		#$7f							; mask off sign
	sta		psgMainVolumeChangeAccum,x		; update fraction
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; now do pan pot adjustments.

.noMainChange

	lda		psgMainPanRightDelta,x
	beq		.noRight
    bmi		.panRightNeg	
	
	;..........................................................................
	; adjustment to right channel is positive. 
	
	clc
	adc		psgMainPanRightAccum,x			; add to accumulator
	sta		<psgTemp1
	
	rol		a							; times 4
	rol		a
	and		#1							; sign bit ?
	sta		<psgTemp2
	lda		psgMainPanPot,x				; main value
	and		#$0f						; right side
	
	clc
	adc		<psgTemp2					; add to current
	cmp		#$10						; still in range ?
	bcc		.fixRight					; still good, skip limit
	
	lda		#$0f						; limit to $0f
	stz		psgMainPanRightDelta,x		; stop further changes
	bra		.fixRight						; go put back together....
	
	;..........................................................................
	; adjustment to right channel is negative
	
.panRightNeg
	
	eor		#$FF				; 2's comlement
	inc		a
	
	clc
	adc		psgMainPanRightAccum,x		; add to accumultor
	sta		<psgTemp1
	rol		a							; times 4
	rol		a
	and		#$01						; accumulator overflowed ?
	sta		<psgTemp2

	lda		psgMainPanPot,x				; combined value
	and		#$0f						; isolate channel
	
	sec
	sbc		<psgTemp2					; minus accumulator overflow
	bne		.fixRight						; 
	
	cla									; pan right is 0
	stz		psgMainPanRightDelta,x		; and no more changes

	;..........................................................................
	; put right pan pot back into combined.
	
.fixRight
	sta		<psgTemp2
	lda		psgMainPanPot,x
	and		#$F0					; isolate left channel
	ora		<psgTemp2				; put right channel in
	sta		psgMainPanPot,x
	
	lda		<psgTemp1				; get accumulated change
	and		#$7f					; clear sign bit
	sta		psgMainPanRightAccum,x	; save accumulated count
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; now do pan pot left adjust:
	
.noRight
	lda		psgMainPanLeftDelta,x		; amount of change
	beq		.volDone					; skip adjustment if none
	bmi		.panLeftNeg
	
	;..........................................................................
	; pan left delta positive
	
	clc										; clear carry
	adc			psgMainPanLeftAccum,x		; add to accumulated count
	sta			<psgTemp1					; save
	and			#$80						; get sign
	lsr			a							; divide by 8
	lsr			a
	lsr			a
	sta			<psgTemp2					; save

	lda			psgMainPanPot,x				; get combined value
	and			#$F0						; iosolate left channel
	clc
	adc			<psgTemp2					; add in rollover from accumulator
	bcc			.fixLeft					; and update it (still in range)

	lda			#$F0						; get limit
	stz			psgMainPanLeftDelta,x		; clear changes
	bra			.fixLeft
	
	;..........................................................................
	; pan left delta negative
	
.panLeftNeg

	eor			#$ff			; 2's complement
	inc			a
	
	clc
	adc			psgMainPanLeftAccum,x		; add to accumulated count
	sta			<psgTemp1					; save accumulated value
	
	and			#$80						; isolate sign bit
	lsr			a							; divide by 8
	lsr			a
	lsr			a
	sta			<psgTemp2					; save overflow trigger

	lda			psgMainPanPot,x				; get combined value
	and			#$F0						; isolate left side
	sec
	sbc			<psgTemp2					; subtract overflow
	bne			.fixLeft					; save if (if in range)
	
	cla										; clear pot.
	stz			psgMainPanLeftDelta,x		; clear changes
	
	;..........................................................................
	; put left channel back into combined pan pot
	
.fixLeft
	sta			<psgTemp2					; save updated accumulator
	lda			psgMainPanPot,x				; get main value
	and			#$0f						; isolate right channel
	ora			<psgTemp2					; put left channel back
	sta			psgMainPanPot,x				; save it
	
	lda			<psgTemp1					; save accumulated value
	and			#$7f						; clear overflow
	sta			psgMainPanLeftAccum,x		; save accumulated value
	
	;..........................................................................
	; all set
	
.volDone
	rts
