;-----------------------------------------------------------------------------------------
;
; Percussion Sequencer
; called from main track PSG driver
;
subProcessDrums

	ldy		psgCurrentVoice					; get voice
	lda		psgSubStackOffset,y			; stack offset for voice
	and		#$F0							; get track mode
	cmp		#$10							; is it percussion mode ?
	beq		.isDrums						; yep... keep going

.drumOut
	rts										; nope, skip drum handling
	
	;...........................................................................
	;  check tie state, to determine what phase we are in
	
.isDrums
	lda		psgSubTieState,y				; get voice state
	beq		.drumOut						; if rest, skip it
	
	;...........................................................................
	; have note (?) handle drums ??

	lda		psgSubDrumPtrLo,y			; set up percussion table pointer
	sta		<psgPtr1
	lda		psgSubDrumPtrHi,y
	sta		<psgPtr1+1

.parseDrums
	lda		[psgPtr1]					; get code from drum track
	inc		<psgPtr1						; and bump to next
	bne		.skipHi9
	inc		<psgPtr1+1
.skipHi9

	;...........................................................................
	; check drum track codes
	
	tax									; save code ?
	cmp			#$B0					; < $B0 ?
	bcc			.isNoise				; handle noise number

	and			#$F0					; high nibble only
	cmp			#$B0					; $Bx codes - frequency, high
	beq			.isFreq
	
	cmp			#$C0					; $Cx codes - envelope number
	beq			.isEnv

	cmp			#$D0					; $Dx codes - pan pot setting
	beq			.isPan

	cmp			#$E0					; $Ex codes - wave for number
	beq			.isWave
	
	jmp			.isEnd					; $Fx codes - end-of-data
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; isNoise - handle percussion noise number

.isNoise

	cpy			#$04					; is voice noise-capable ?
	bcc			.noiseDone				; nope, save pointer and return

	;...........................................................................
	; voice is percussion capable. Value goes in NoiseFlag, with bit 7 OFF

	and			#$1f					; mask off high bits of noise (0-$1f)
	sta			psgSubNoiseFlag-4,y	; save high byte of noise value.
	bra			.noiseDone				; save pointer and return
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	isFreq - handle direct frequency value
	
.isFreq
	
	txa									; restore original value

	;...........................................................................
	; save hi byte of frequency
	
	sec
	sbc			#$b0					; get high bits of frequency
	sta			psgSubFreqHi,y			; save frequency
	
	;...........................................................................
	; get low byte of frequency, and save it.
	
	lda			[psgPtr1]				; get low byte
	inc			<psgPtr1					; and bump pointer
	bne			.skipHi10
	inc			<psgPtr1+1
.skipHi10

	sta			psgSubFreqLo,y			; save frequency lo byte
	
	;...........................................................................
	; check for noise capable channel. NoiseFlag gets set to 0, with bit 7 ON.
	
	cpy			#4
	bcc			.noiseDone				; not noise capable. we're done
	
	lda			#$80					; mark voice as noise value set (presumably)
	sta			psgSubNoiseFlag-4,Y	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; quick exit for noise stuff. Probably easier to reach in middle
	
.noiseDone
	lda			<psgPtr1					; save updated percussion pointer
	sta			psgSubDrumPtrLo,Y
	lda			<psgPtr1+1
	sta			psgSubDrumPtrHi,Y

	rts									; and return to driver

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; isEnv - handle drum envelope switches. Envelope # is parameter
	
.isEnv

	lda			[psgPtr1]				; get parameter
	cmp			#$10					; internal envelope ?
	bcs			.usrDrumEnv				; nope, handle use envelope
	
	;...........................................................................
	; handle internal envelope for drums.
	
	asl			a						; make 2-byte offset
	tax									; use as index
	lda			psgSysEnv,x				; low byte of internal address
	sta			psgSubEnvelopePtrLo,Y	; save it
	lda			psgSysEnv+1,x			; hi byte of internal address
	sta			psgSubEnvelopePtrHi,y	; save it
	bra			.nextDrumByte
	
	;...........................................................................
	; handle user envelope for drums
	
.usrDrumEnv
	sec
	sbc			#$10					; subtract internal envelope numbers
	asl			a						; convert to 2-byte offset
	
	clc
	adc			psgUserVolEnvelope		; add to low address of user envelopes
	sta			<psgPtr2					; save in alternate pointer
	cla									; high byte is 0
	adc			psgUserVolEnvelope+1	; add to hi address of user envelopes
	sta			<psgPtr2+1				; save in alternate pointer

	lda			[psgPtr2]				; get low byte of entry
	sta			psgSubEnvelopePtrLo,Y	; save it
	
	inc			<psgPtr2					; bump pointer
	bne			.skip11
	inc			<psgPtr2+1
.skip11

	lda			[psgPtr2]				; get hi byte of entry
	sta			psgSubEnvelopePtrHi,y	; save it
	bra			.nextDrumByte
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; isPan - handle pan pot changes. New value is parameter
	
.isPan
	lda			[psgPtr1]				; get parameter
	sta			psgSubPanPot,Y			; set pan pot value
	bra			.nextDrumByte
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; isWave - handle waveform changes. Wave number is parameter

.isWave
	lda			[psgPtr1]				; get parameter
	sta			psgSubWaveNo,Y			; save it - it loads as needed, since bit 7 off
	bra			.nextDrumByte
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; isEnd - handle end of drum data
	
.isEnd

	cla
	sta			psgSubTieState,Y		; voice state = 0 (silence)
	
	lda			<psgPtr1					; back pointer up
	sec
	sbc			#1
	sta			psgSubDrumPtrLo,y
	lda			<psgPtr1+1
	sbc			#0
	sta			psgSubDrumPtrHi,y
	rts									; we're done.

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; nextDrumByte - increment drum pointer to next byte, and loop
	
.nextDrumByte

	inc		<psgPtr1			; bump pointer
	bne		.skip12
	inc		<psgPtr1+1
.skip12

	jmp		.parseDrums		; and back to handle more
