;
; process frequency effects
; called from main track PSG driver
;
subProcessFrequency

	;........................................................................
	; skip effects if not playing tones.
	
	ldx		psgCurrentVoice					; voice number in X
	lda		psgSubStackOffset,x				; top byte from stack 
	and		#$F0							; isolate voice mode
	beq		.isTone
	rts
	
	;........................................................................
	; copy note frequency to output work area
	
.isTone
	lda		psgSubFrequencyLo,x			; get lo byte of frequency
	sta		psgSubFreqLo,x					; save
	lda		psgSubFrequencyHi,x			; get hi byte of frequency
	sta		psgSubFreqHi,x					; save
	
	;........................................................................
	; check for sweeps
	
	lda		psgSubSweepDelta,x				; get sweep change
	tay										; save ?
	beq		.sweepDone						; skip if no sweep
	
	;........................................................................
	; if sweep time is 0, or time isn't up, apply sweep effect (?)
	
	lda		psgSubSweepTime,x			; do we have a time for sweep ?
	beq		.sweepTime					; no, go do it.

	dec		psgSubSweepTimeCount,x			; count down time
	bne		.sweepTime						; have time left, keep going
	
	;........................................................................
	; if time is up (Count==0), adjust frequency ??
	
	inc		psgSubSweepTimeCount,x			; reset time
	lda		psgSubSweepAccumLo,x			; save accumulated sweep value
	sta		<psgTemp1						
	lda		psgSubSweepAccumHi,x
	sta		<psgTemp2
	
	jsr		subAddToOut						; add it to output frequency
	bra		.sweepDone						; finished ?
	
	;........................................................................
	; sweep time 0, or still counting down. adjust note frequency by accumulated
	; sweep amount. 

.sweepTime

	sty		<psgTemp1					; sweep delta is in Y. 
	jsr		subFixFreq					; apply modulation adjustment to delta
	
	lda		psgSubSweepAccumLo,x		; add adjusted delta to sweep amount
	clc
	adc		<psgTemp1
	sta		psgSubSweepAccumLo,x
	sta		<psgTemp1
	
	lda		psgSubSweepAccumHi,x
	adc		<psgTemp2
	sta		psgSubSweepAccumHi,x
	
	sta		<psgTemp2
	jsr		subAddToOut					
	
	;........................................................................
	; sweep done. apply detune frequency adjustment, if any
	
.sweepDone

	lda		psgSubDetuneAmount,x
	beq		.noDetune
	
	sta		<psgTemp1				; save detune amount
	jsr		subFixFreq				; apply modulation correction
	jsr		subAddToOut				; add to output frequency

	;........................................................................
	; do we need to apply pitch envelope ?

.noDetune

	lda		psgSubPEDelay,x			; check delay
	beq		.noPitch					; skip if none

	dec		psgSubPEDelayCount,x		; count down delay
	bne		.noPitch					; not time yet.

	inc		psgSubPEDelayCount,x		; count up. Why?
	
	;........................................................................
	; yes, set up pointer for data
	
	lda		psgSubPEPtrLo,x
	sta		<psgPtr1
	lda		psgSubPEPtrHi,x
	sta		<psgPtr1+1

	;........................................................................
	; fetch data byte
	
	ldy		psgSubPECount,x			; get offset
	lda		[psgPtr1],y					; and value
	
	;........................................................................
	; end of data ?
	
	cmp		#$80
	bne		.useIt
	
	cpy		#0					; first byte is end....skip adjustment
	beq		.noPitch
	
	dey							; otherwise, use previous
	lda		[psgPtr1],y

	;........................................................................
	; calculate pitch adjustments
	
.useIt
	
	sta		<psgTemp1			; save for modulation adjustment
	phy							; save offset
	
	jsr		subFixFreq			; apply frequency modulation correction
	jsr		subAddToOut			; add to output frequency
	
	ply							; restore offset
	iny							; bump to next
	bne		.saveOffset			; save updated offset
	dey							; went to 0, back it up (locks range)

.saveOffset
	tya							; save offset 
	sta		psgSubPECount,x
	
	;........................................................................
	; apply modulation, if any
	
.noPitch

	lda		psgSubModDelay,x			; check delay
	beq		.noMod

	dec		psgSubModDelayCount,x		; count it down....
	bne		.noMod						; not time to apply it.
	
	inc		psgSubModDelayCount,x		; count up. (?)
	
	;........................................................................
	; time to apply effect. get byte from data.
	
	lda		psgSubModBasePtrLo,x		; set up pointer to effect data
	sta		<psgPtr1
	lda		psgSubModBasePtrHi,x
	sta		<psgPtr1+1

	ldy		psgSubModCount,x			; get offset
.modNext
	lda		[psgPtr1],y					; get byte
	
	;........................................................................
	; handle end of data
	
	cmp		#$80						; is it end-of-data ?
	bne		.doMod						; no, keep going
	
	cpy		#0							; if first byte...
	beq		.noMod						; exit

	stz		psgSubModCount,x			; not first byte, re-set data ptr
	cly
	bra		.modNext					; and get next byte
	
.doMod
	;........................................................................
	;	apply modulation effect
	
	sta		<psgTemp1					; save byte as delta amount
	jsr		subFixFreq					; apply modulation correction
	jsr		subAddToOut					; add to output frequency

	inc		psgSubModCount,x			; bump offset
	
.noMod
	rts

;-----------------------------------------------------------------------------
; fixFreq : convert octave difference to frequency adjustment.
; (ie, figure out how much to change the 'frequency change amount' by)
; 
; in:   sweep delta in psgTemp1
; out: change amount in psgTemp1 (lo) and psgTemp2 (hi)
;

subFixFreq

	stz		<psgTemp2		; clear high byte
	lda		<psgTemp1		; get delta amount
	bpl		.one			; if change is positive, skip sign extension
	dec		<psgTemp2		; otherwise, sign extend value
.one

    ;...........................................................................
	; check octave correction.
	
	lda		psgSubModCorrection,x			; frequency modulation correction (octave #)
	beq		.Exit							; no need to correct

	sec
	sbc		psgSubOctave,x					; subtract base octave
	tay										; stash
	bmi		.octaveDown						; if lower than base octave, adjust 
	
	
	;..............................................................................
	; modulation correction octave higher than base octave. go up octaves

.octaveUp
	beq		.Exit				; if same as base octave, we're done
	asl		<psgTemp1			; shift amount up
	rol		<psgTemp2
	dey							; one less to adjust
	bra		.octaveUp			; check for done
	
	;..............................................................................
	; modulation corection octave lower than base octave. go down octaves
	
.octaveDown
	beq		.fixSign			; if we've reached octave 0, we're done
	lsr		<psgTemp2			; divide sweep delta by 2
	ror		<psgTemp1			
	iny							; count up
	bra		.octaveDown
	
	;..............................................................................
	; repair sign due to correction shifts
	
.fixSign

	lda		<psgTemp2					; high byte 0 ?
	beq		.Exit
	lda		#$ff						; nope, make it negative
	sta		<psgTemp2
.Exit
	rts
	
;-----------------------------------------------------------------------------------
; add value in psgPtr2 to tone output frequency
;

subAddToOut
	lda		psgSubFreqLo,x			; get ouput frequency lo
	clc
	adc		<psgTemp1				; add in change lo
	sta		psgSubFreqLo,x			; and save it

	lda		psgSubFreqHi,x
	adc		<psgTemp2
	sta		psgSubFreqHi,x
	rts
	
