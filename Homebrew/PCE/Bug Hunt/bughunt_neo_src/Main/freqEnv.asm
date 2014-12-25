;
; process frequency effects
; called from main track PSG driver
;
processFrequency

	;........................................................................
	; skip effects if not playing tones.
	
	ldx		psgCurrentVoice					; voice number in X
	lda		psgMainStackOffset,x			; top byte from stack 
	and		#$F0							; isolate voice mode
	beq		.isTone
	rts
	
	;........................................................................
	; copy note frequency to output work area
	
.isTone
	lda		psgMainFrequencyLo,x			; get lo byte of frequency
	sta		psgMainFreqLo,x					; save
	lda		psgMainFrequencyHi,x			; get hi byte of frequency
	sta		psgMainFreqHi,x					; save
	
	;........................................................................
	; check for sweeps
	
	lda		psgMainSweepDelta,x				; get sweep change
	tay										; save ?
	beq		.sweepDone						; skip if no sweep
	
	;........................................................................
	; if sweep time is 0, or time isn't up, apply sweep effect (?)
	
	lda		psgMainSweepTime,x				; check time
	beq		.sweepTime						; time = 0.

	dec		psgMainSweepTimeCount,x			; count down time
	bne		.sweepTime
	
	;........................................................................
	; if time is up (Count==0), adjust frequency ??
	
	inc		psgMainSweepTimeCount,x			; count up ??
	lda		psgMainSweepAccumLo,x			; save accumulated sweep value
	sta		<psgTemp1						
	lda		psgMainSweepAccumHi,x
	sta		<psgTemp2
	
	jsr		addSweep						; add it to output frequency
	bra		.sweepDone						; finished ?
	
	;........................................................................
	; sweep time 0, or still counting down. adjust note frequency by accumulated
	; sweep amount. 

.sweepTime

	sty		<psgTemp1					; sweep delta is in Y. 
	jsr		fixOctaves					; apply modulation adjustment to delta
	
	lda		psgMainSweepAccumLo,x		; add adjusted delta to sweep amount
	clc
	adc		<psgTemp1
	sta		psgMainSweepAccumLo,x
	sta		<psgTemp1
	
	lda		psgMainSweepAccumHi,x
	adc		<psgTemp2
	sta		psgMainSweepAccumHi,x
	sta		<psgTemp2

	jsr		addSweep					
	
	;........................................................................
	; sweep done. apply detune frequency adjustment, if any
	
.sweepDone

	lda		psgMainDetuneAmount,x
	beq		.noDetune
	
	sta		<psgTemp1				; save detune amount
	jsr		fixOctaves				; apply modulation correction
	jsr		addSweep				; add to output frequency

	;........................................................................
	; do we need to apply pitch envelope ?

.noDetune

	lda		psgMainPEDelay,x			; check delay
	beq		.noPitch					; skip if none

	dec		psgMainPEDelayCount,x		; count down delay
	bne		.noPitch					; not time yet.

	inc		psgMainPEDelayCount,x		; count up. Why?
	
	;........................................................................
	; yes, set up pointer for data
	
	lda		psgMainPEPtrLo,x
	sta		<psgPtr1
	lda		psgMainPEPtrHi,x
	sta		<psgPtr1+1

	;........................................................................
	; fetch data byte
	
	ldy		psgMainPECount,x			; get offset
	lda		[psgPtr1],y					; and value
	
	;........................................................................
	; end of data ?
	
	cmp		#$80
	bne		.useIt
	
	cpy		#0
	beq		.noPitch
	
	dey							; first byte is end....
	lda		[psgPtr1],y			; so we use previous byte. (!)
	
	;........................................................................
	; calculate pitch adjustments
	
.useIt
	
	sta		<psgTemp1			; save for modulation adjustment
	phy							; save offset
	
	jsr		fixOctaves			; apply frequency modulation correction
	jsr		addSweep			; add to output frequency
	
	ply							; restore offset
	iny							; bump to next
	bne		.saveOffset			; save updated offset
	dey							; went to 0, back it up (locks range)

.saveOffset
	tya							; save offset 
	sta		psgMainPECount,x
	
	;........................................................................
	; apply modulation, if any
	
.noPitch

	lda		psgMainModDelay,x			; check delay
	beq		.noMod

	dec		psgMainModDelayCount,x		; count it down....
	bne		.noMod						; not time to apply it.
	
	inc		psgMainModDelayCount,x		; count up. (?)
	
	;........................................................................
	; time to apply effect. get byte from data.
	
	lda		psgMainModBasePtrLo,x		; set up pointer to effect data
	sta		<psgPtr1
	lda		psgMainModBasePtrHi,x
	sta		<psgPtr1+1

	ldy		psgMainModCount,x			; get offset

.modNext
	lda		[psgPtr1],y					; get byte
	
	;........................................................................
	; handle end of data
	
	cmp		#$80						; is it end-of-data ?
	bne		.doMod						; no, keep going
	
	cpy		#0							; if first byte...
	beq		.noMod						; exit

	stz		psgMainModCount,x			; not first byte, re-set data ptr
	cly
	bra		.modNext					; and get next byte
	
.doMod
	;........................................................................
	;	apply modulation effect
	
	sta		<psgTemp1					; save byte as delta amount
	jsr		fixOctaves					; apply modulation correction
	jsr		addSweep					; add to output frequency

	inc		psgMainModCount,x			; bump offset
	
.noMod
	rts

;-----------------------------------------------------------------------------
; figure out how much to change the 'frequency change amount' by
; 
; in:   sweep delta in psgTemp1
; out: change amount in psgTemp1 (lo) and psgTemp2 (hi)
;

fixOctaves

	stz		<psgTemp2		; clear high byte
	lda		<psgTemp1		; get delta amount
	bpl		.one			; if change is positive, skip sign extension
	dec		<psgTemp2		; otherwise, sign extend value
.one

    ;...........................................................................
	; check octave correction.
	
	lda		psgMainModCorrection,x			; frequency modulation correction (octave #)
	beq		.Exit							; no need to correct

	sec
	sbc		psgMainOctave,x					; subtract base octave
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
; add value in $ea/$eb to tone frequency
; and put it back in tone frequency
;

addSweep
	lda		psgMainFreqLo,x			; get ouput frequency lo
	clc
	adc		<psgTemp1				; add in change lo
	sta		psgMainFreqLo,x			; and save it

	lda		psgMainFreqHi,x
	adc		<psgTemp2
	sta		psgMainFreqHi,x
	rts
	
