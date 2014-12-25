;
; (adsr) Envelope processing
; called from main track PSG driver
;

processEnvelope

	ldx			psgCurrentVoice			; get voice
	lda			psgMainTieState,x		; voice state
	bne			.hasNote				; if not state 0 (rest/off), keep going
	jmp			.doRest					; otherwise, process rest

	;........................................................................
	; we have a note. what part of state do we need to handle ?
	
.hasNote

	bmi			.doKeyOff				; if bit 7 set, in key-off state
	
	cmp			#2						; state 2 ?
	beq			.keyHit
	
	;........................................................................
	;  note is on, count down on-time
	
	dec			psgMainKeyOnDuration,x		; count down on-time
	bne			.onStill					; if not counted out... 

	ora			#$80						; counted out, mark as key-off
	sta			psgMainTieState,x			; save it
	
.onStill
	lda			psgMainEnvDecayTime,x		; do we have decay amount ?
	bne			.addDecay					; add decay amount in
	bra			.parseEnv					; handle parsing ?
	
	;........................................................................
	; addDecay - add decay amount to current level
	
.addDecay
	
	lda			psgMainEnvLevelLo,x			; get level lo
	clc
	adc			psgMainEnvDurationLo,x		; add decay
	sta			psgMainEnvLevelLo,x			; save

	lda			psgMainEnvLevelHi,x			; get level hi
	adc			psgMainEnvDurationHi,x		; add decay
	bpl			.durOK						; is it still in range ?
	
	;........................................................................
	; level went out of range. force into range
	
	cla
	sta			psgMainEnvLevelLo,X			; force lo byte to 0
	ldy			psgMainEnvDurationHi,x		; get high of duration
	bmi			.durOK						; skip if it was already negative (ie, use 0)
	lda			#$7C						; set to max
.durOK
	sta			psgMainEnvLevelHi,x			; save hi byte of level

	;........................................................................
    ; now that level has been taken care of, count down decay time
	
	lda			psgMainEnvDecayTime,x		; get decay time
	cmp			#$FF						; all done ?
	beq			.envDone
	
	dec			psgMainEnvDecayTime,x		; count decay down
	bra			.envDone					; set volume and exit

	;........................................................................
	; now, key is 'released'. add in release changes

.doKeyOff

	lda			psgMainEnvLevelLo,x			; get level lo byte
	clc
	adc			psgMainEnvReleaseLo,x			; add lo of release
	sta			psgMainEnvLevelLo,x			; save
	
	lda			psgMainEnvLevelHi,x			; get level hi byte
	adc			psgMainEnvReleaseHi,x		; add hi of release
	bpl			.relOK						; still in range ?
	
	;........................................................................
	; release sent us out of range. fix level
	
	cla
	sta			psgMainEnvLevelLo,x			; clear low byte of level
	ldy			psgMainEnvReleaseHi,x		; get release hi
	bmi			.relOK						; it was negative. Use 0 for level hi
	
	lda			#$7C						; it was positive. use max for level hi

	;........................................................................
	; now that high byte of level has been fixed, save it
	
.relOK
	sta			psgMainEnvLevelHi,x
	bra			.envDone					; set volume and exit
	
	;........................................................................
	; process key on (initial strike)
	
.keyHit

	dec		psgMainTieState,x				; strike state -> normal state
	stz		psgMainEnvelopeIndex,x			; reset envelope information
	bra		.parseEnv						; parse envelope commands
	
	;........................................................................
	; state is at rest
	
.doRest
	stz		psgMainTrackVolume,x			; volume is 0
	bra		.envOut							; return

	;........................................................................
	; save envelope offset

.envExit
		tya									; save envelope offset
		sta		psgMainEnvelopeIndex,x

	;........................................................................
	; set volume level
	
.envDone
	
	lda		psgMainEnvLevelHi,x				; get envelope volume level
	lsr		a
	lsr		a								; divide by $400
	
	clc
	adc		psgMainVoiceVolume,x			; add to current volume for voice
	bpl		.setMainVol						; if okay, save as output volume
	cla										; otherwise, set output volume to 0

.setMainVol
	sta		psgMainTrackVolume,x			; set output volume
	
.envOut
	rts										; and return
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; parseEnv - handle parsing adsr envelope commands
	
.parseEnv

	;........................................................................
	; fetch next byte of control data
	
	ldy			psgMainEnvelopeIndex,x			; index into envelope data
	
	lda			psgMainEnvelopePtrLo,x			; low byte of envelope data address
	sta			<psgPtr1							; save
	lda			psgMainEnvelopePtrHi,x			; high byte
	sta			<psgPtr1+1						; save

.nextCommand
	lda			[psgPtr1],y						; get next data byte
	
	;........................................................................
	; dispatch it
	
	cmp			#$FB						; release rate
	bcc			.doDecay					; if <, it's decay rate
	beq			.doRelease					; if =, it's release rate

	cmp			#$FC						; set level
	beq			.doLevel
	bra			.doEnd						; rest -should- be end-data

	;========================================================================
	; $FB -> doDecay - process decay value for envelope
	
.doDecay

	;........................................................................
	; handle decay time
	
	cmp		#0							; check decay time
	bne		.decayOK					; if 0.....
	dec		a							; do change 'forever'
.decayOK
	sta		psgMainEnvDecayTime,x		; set decay time

	;........................................................................
	; handle decay duration
	
	iny									; next byte
	lda		[psgPtr1],Y					; duration lo byte
	sta		psgMainEnvDurationLo,x		; save it
	iny									; next byte
	lda		[psgPtr1],y					; duration hi byte
	sta		psgMainEnvDurationHi,x		; save it
	iny									; next byte
	bra		.envExit					; save offset and return

	;========================================================================
	; $FB -> doRelease - process release rate for envelope.

.doRelease

	iny
	iny
	iny									; skip release rate. it should only be first data
	bra		.nextCommand				; loop back and handle next command
	
	;========================================================================
	; $FC - doLevel - process level data for envelope

.doLevel

	iny									; next byte
	lda		[psgPtr1],y					
	sta		psgMainEnvLevelLo,x			; save level lo byte
	
	iny
	lda		[psgPtr1],y
	sta		psgMainEnvLevelHi,x			; save level hi byte

	iny
	lda		[psgPtr1],y					; next byte
	cmp		#$FB						; is it another command ?
	bcc		.doDecay					; no, it's a decay rate
	
	stz		psgMainEnvDecayTime,x			; yes, it's a command. decay rate goes to 0
	bra		.envExit

	;========================================================================
	; doEnd -> all other envelope data ($FD, $FE,$FF)

.doEnd
	
	lda		#$FF
	sta		psgMainEnvDecayTime,x			; decay time infinite
	stz		psgMainEnvDurationLo,x			; duration is 0
	stz		psgMainEnvDurationHi,x			;
	jmp		.envDone						; skip storing offset....
	
