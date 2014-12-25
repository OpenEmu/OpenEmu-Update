;-----------------------------------------------------------------------------
; process sub-track MML byte codes
;..............................................................................
; X should hold voice number to process.

subParseMMLCodes

	;..........................................................................
	; update time left on note.
	
	dec		psgSubNoteDuration,x
	beq		.newNote				; duration = 0, note done. handle new one
	rts								; note isn't done playing. skip this voice
	
	;..........................................................................
	; need data, so set up track pointer. Y now holds voice to process
	
.newNote

	sxy								; voice number into y
	lda		psgSubTrackPtrLo,y		; low byte of current track pointer
	sta		<psgPtr1					; into indirect pointer
	lda		psgSubTrackPtrHi,y
	sta		<psgPtr1+1

	;..........................................................................
	; and fetch next byte

mmlSubFetchNext
	lda		[psgPtr1]			; fetch value
	inc		<psgPtr1				; 
	bne		.noHigh1			; if low not rolled, we're okay. otherwise...
	inc		<psgPtr1+1			; we need to bump high byte
.noHigh1

	;..........................................................................
	; save value on stack. we may need it unchanged later.
	; decide if we are handling actual note, or an operation code
	
	pha								; save value
	cmp		#$d0					; is it operation code ?
	bcc		doNote2					; nope, handle tone (c46e)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; it's an operation, dispatch it. Note that Y holds the channel number
	;..........................................................................
	
	sec								
	sbc		#$d0					; convert to index. 
	asl		a						; 2 bytes per address
	tax								; put into index register
	pla								; restore original value (ie, which to do)
	
	jmp		[psgSubMMLOperations,X]	; and 'call' the routine.

	.include "sub\mmlJump.inc"
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; process note data. Y holds voice #

doNote2
	
	ldx		psgSubDurationMultiplier,y	; get duration multiplier for packed notes
	beq		.getDuration				; if it's a 0, we're not using packed notes
	
	;..........................................................................
	; it's a packed note, strip out duration
	
	and		#$0F				; duration -1 in low nibble 
	inc		a
	cmp		psgSubDurationMultiplier,y			; check against saved duration
	bcs		.isOkay								; larger (?)
	
	sax											; yes, use duration multiplier
.isOkay
	sta		<psgTemp1							; save packed duration in temp area
	
	;..........................................................................
    ; at this point, X holds   min( given duration, duration multiplier )
	; and the temp value holds max( given duration, duration multiplier )
    ; so, this multiply-by-adding loop will run the minimum number of times needed
    ; A  should hold (given duration) * (duration multiplier) when done
	;..........................................................................
	; because of small values that are useable, this works okay. it might be
	; slightly faster to do shift-and-add, though. It's only 4 bits for note
	; duration.
	;............................................................................

	clc							; no carry
.mulLoop
	dex							; one more done
	beq		.mulDone			; are we finished yet?
	
	adc		<psgTemp1			; not yet...
	bra		.mulLoop			; keep going.
	
	;..........................................................................
	; it's not a packed note; next byte is duration to use.

.getDuration	
	lda		[psgPtr1]		; get next byte (duration)
	inc		<psgPtr1			; bump pointer to next
	bne		.noHigh2
	inc		<psgPtr1+1
.noHigh2

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; either way we got here, A holds the total duration for the note.
	; next step is to calculate On/Off period and adjust the duration of the note
	
.mulDone

	sta		psgSubNoteDuration,y		; save new total duration

	;..........................................................................
	; peek at next byte, decide if it's a tied note.
	
	tax							; stash it. we need to look at next byte for ties
    lda		[psgPtr1]			; fetch at next byte
	sax							; restore duration to A
	
	cpx		#$DA				; tie operation ?
	beq		.setDuration		; yep. use entire duration for note
	
	;..........................................................................
	; it's not a tied note. calculate KeyOn/KeyOff period (1/8 note duration)
	
	lsr		a					; key on/off period = (duration / 8)
	lsr		a
	lsr		a
	sta		<psgTemp1				; save period in temp
	
	;..........................................................................
	; subtract KeyOff periods from total duration 

	sec
	lda		psgSubNoteDuration,y		; total note duration
	ldx		psgSubKeyOffPeriods,y		; # periods note is 'off'
	
.calcKeyOnLoop
	beq		.setDuration				; if all periods done, continue
	sbc		<psgTemp1					; subtract one period
	dex									; one less to do
	bra		.calcKeyOnLoop				; do it again
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; save sounding duration of this note, now that we know it. 
	; note that if we got here via tie, A holds actual duration of note.
	;..........................................................................
	
.setDuration

	sta		psgSubKeyOnDuration,y		; save how long note is on
	pla									; restore original note
	and		#$F0						; get note
	bne		.isTone						; handle tone if it's not a rest

	;..........................................................................
	; if note is 0, it should be a rest

	cla									; it's a rest -> make tie state 0
	jmp		doRest2						; go handle it
	
	;..........................................................................
	; note isn't rest. convert to offset
	
.isTone
	
	sec									; for subtract
	sbc		#$10						; subtract 1 from high nibble
	lsr		a
	lsr		a
	lsr		a							; shift into low nibble, as 2-byte offset
	tax									; save as index

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; get voice mode. it seems to be stored at tos, in high nibble
	; apparently, mode 0 is regular wave....
	
	lda		psgSubStackOffset,y		; mode. stored in stack
	and		#$f0						; strip off high nibble
	sax									; restore index
	beq		getOctave2					; mode 0 => find octave for (wave) sound
	
	;..........................................................................
	; is channel set to percussion mode (1) ?. A should hold note offset
	
	cpx		#$10				; is channel in percussion mode ?
	bne		.doNoise			; nope. skip to handling noise

	clc
	adc		psgUserPercTable		; add note offset to percussion table base low
	sta		<psgPtr2					; save low byte
	cla								; a = 0, for carry
	adc		psgUserPercTable+1		; add to percussion table base high
	sta		<psgPtr2+1				; save high byte
	
	;..........................................................................
	; psgPtr2 now points to pointer to data for this note on drums...
    ; get drum data pointer, save it
	
	lda		[psgPtr2]				; get low byte of pointer
	sta		psgSubDrumPtrLo,y		; save drum data pointer, low byte
	inc		<psgPtr2					; bump pointer
    bne		.noHigh3
	inc		<psgPtr2+1
.noHigh3

	lda		[psgPtr2]				; get hi byte of pointer
	sta		psgSubDrumPtrHi,y		; save drum data pointer, low byte
    bra		handleTies2
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; channel set to noise mode (2) A holds note offset
	
.doNoise
	cpy		#4				; noise-capable channel ?
	bcc		getOctave2		; no, treat as regular wave
	
	;..........................................................................
	; add in noise transpsition.
	
	clc
	adc		psgSubTransposeAmount,y		; add transpose amount
	lsr		a								; divide by 2 => cleans up shift
	
	sta		psgSubNoiseFlag-4,y			; save noise index
	bra		handleTies2
	
	.include	"sub\octaves.inc"
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; find frequency for note. A should hold note * 2
	; --- we appear to be saving the correct frequency....
	
getOctave2

	ldx		psgSubOctave,y				; base octave for voice
	clc
	adc		octaveOffsets2-1,x				; add in start of octave base value (from table)
	adc		psgSubTransposeAmount,y		; add in amount to transpose note
	tax									; use note number as index
	
	lda		freqTable,x					; get note frequency
	sta		psgSubFrequencyLo,y			; save in voice
	
	lda		freqTable+1,x
	sta		psgSubFrequencyHi,y
	
	;..........................................................................
	; check channel, see if it's noise capable
	
	cpy		#4					; is it channel 5 or 6 ?
	bcc		handleTies2			; nope. process as normal

	;..........................................................................
	; channel is noise capable. Turn Noise on ??
	
	lda		#$80					; noise enabled
	sta		psgSubNoiseFlag-4, y	; mark as using noise (?)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; sort out ties. 
	
handleTies2

    lda		psgSubTieState,y			; get tie state
	cmp		#3							; are we at the tie?
	bne		.noTie1						; nope....reset effects, and update channel ptr
	
	;..........................................................................
	; State 3 is when we see the tie during parsing(and NOT when we look ahead)
	; At that point, we should have set it up, and played the note before the tie. 
	; So, we basically need to ignore it, and skip to the next note. But, do it 
	; properly, by setting the correct post-tie state for the note....
	
	lda		#1							; change tie state to 1
	bra		doRest2						; don't re-set effects, just update channel pointer

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	since new note is starting, clear effects stuff
	
.noTie1
	cla									; a = 0
	sta		psgSubModCount,y			; clear modulation count
	sta		psgSubPECount,y			; clear pitch envelope count ?
	sta		psgSubSweepAccumLo,y		; clear accumulated sweep amount, lo
	sta		psgSubSweepAccumHi,y		; clear accumulated sweep amount, hi
	
	lda		psgSubModDelay,y			; get modulation envelope delay
	sta		psgSubModDelayCount,y		; set countdown for modulation effects
	
	lda		psgSubPEDelay,y			; get pitch envelope delay
	sta		psgSubPEDelayCount,y		; set countdown for pitch effects

	lda		psgSubSweepTime,y			; get sweep time delay (?)
	sta		psgSubSweepTimeCount,y		; save sweep time countdown
	
	;..........................................................................
	; tie state not 3. make it 2. (note active ?)

	lda		#2

	;..........................................................................
	; save tie state and channel data pointer
	
doRest2
	sta		psgSubTieState, y			; update tie state
	
	lda		<psgPtr1						; save location in track data
	sta		psgSubTrackPtrLo,y
	lda		<psgPtr1+1
	sta		psgSubTrackPtrHi,y
	
	;..........................................................................
	; done with parsing this voice.
	
	rts

