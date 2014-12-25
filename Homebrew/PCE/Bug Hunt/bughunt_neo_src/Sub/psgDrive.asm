;******************************************************************************************************
; SUB TRACK MUSIC DRIVER : this still has a LOT of debug stuff in it.
;------------------------------------------------------------------------------------------------------

psgSubDrive

	;...........................................................................
	; make sure song is ready.

	jsr		subInitCheck				; initialize song, if it needs it.
		
	;...........................................................................
	; if subtrack is paused, skip it

	
	tst		#$40,psgTrackCtrl			; check track control bits
	bne		.subStatusUpdate			; if sub track paused, skip to status update

	;...........................................................................
	; sub track voice loop

	lda		#5						; count down voices
	sta		psgCurrentVoice			; save working voice

.voiceLoop
	;...........................................................................
	; check voice status, skip it if off
	
	ldx		psgCurrentVoice			; retrieve working voice
	lda		psgSubVoiceStatus,x		; get status
	beq		.voiceNext				; if off, skip it
	
	;...........................................................................
	; voice needs updated. Call subroutines to do it
	
	jsr		subParseMMLCodes		; cdf6
	jsr		subProcessVolume		; d257
	jsr		subProcessDrums			; d350
	jsr		subProcessEnvelope		; d422
	jsr		subProcessFrequency		; d510

	;...........................................................................
	; process next voice
	
.voiceNext

	dec		psgCurrentVoice		; count down voice
	bpl		.voiceLoop			; loop if not done

	;...........................................................................
	; all the main track voices have been handled. 
	; fade out if needed, and output sounds

	jsr		subProcessFade		; d623
	jsr		subOutputSounds		; d64d

	;...........................................................................
	; and finally, update the sub tracks status.
	; Note that the return at end of psgSStat, sends us back to whomever called us.

.subStatusUpdate
	jmp		psgSStat			; update track status.

;-----------------------------------------------------------------------------
; subInitCheck - initialize track information, if needed.

subInitCheck
	lda		psgSongNo			; check song number
	bpl		psgSubSetupSong		; if not already started (or changed), go start it

subDriveExit
    rts
	
;-----------------------------------------------------------------------------
; psgSetupSong - initialize song information
;.............................................................................
;  IN : A = song number

psgSubSetupSong

	;...........................................................................
	; convert song number to 2-byte offset, put in Y for indexing
	
	asl		a			; 2 bytes per pointer
	tay					; into index Y
	
	;...........................................................................
	; locate pointer for this song's header

	lda		psgTrackIndexTable			; location of track pointers
	sta		<psgPtr2					; set up zp pointer

	lda		psgTrackIndexTable+1
	sta		<psgPtr2+1
	
	;...........................................................................
	; psgPtr2 now points to track index table. using Y, we now
	; copy the actual track header data pointer to psgPtr1
	
	lda		[psgPtr2],Y					; y'th entry
	sta		<psgPtr1
	iny
	
	lda		[psgPtr2],Y
	sta		<psgPtr1+1

	;...........................................................................
	; now that we know where track header information is, start processing it.

	lda		[psgPtr1]			; get voice mask for track
								; bit 7: 0= main track; 1= subtrack
								; bit 6: 0= normal;     1= debug mode
								; bit 5-0: voice in use
								
	bpl		subDriveExit		; if it's not sub track, we're done

	;...........................................................................
	; save voice mask in temp area. we shift one byte, and need the other to hold
	; the original flags, so we can check for the debug flag.
	
	sta		<psgTemp1				; save in temp area -> shiftable value
	sta		<psgTemp2				; for debug flags
	
	;...........................................................................
	; set up voices
	
	cly							; index of active tracks
	clx							; start with voice 0
	
.voiceLoop
	lsr		<psgTemp1			; get voice bit
	bcc		.nextVoice			; skip it if voice not in use

	;...........................................................................
	; set sub voice status, note duration.
	
	lda		#1
	sta		psgSubVoiceStatus,x			; mark voice as enabled
	sta		psgSubNoteDuration,x		; set duration to 1 ?
	
	;...........................................................................
	; clear main voice information
	

	stz		psgSubTieState,x			; clear tie state (ie, note not tied)
	stz		psgSubKeyOffPeriods,x		; clear # periods Key is off
	stz		psgSubVoiceVolume,x			; clear per-channel voice volume (100%?)
	
	stz		psgSubModDelay,x			; clear modulation delay
	stz		psgSubPEDelay,x				; clear pitch envelope delay
	stz		psgSubModCorrection,x		; clear modulation correction

	stz		psgSubDetuneAmount,x		; clear detune amount
	stz		psgSubSweepDelta,x			; clear sweep change amount
	stz		psgSubSweepTime,x			; clear sweep time

	stz		psgSubStackOffset,x			; clear offset from stack base
	stz		psgSubTransposeAmount,x		; clear transpose amount
	stz		psgSubVolumeChangeAmount,x	; clear volume change amount
	stz		psgSubPanRightDelta,x		; clear right pan pot change amount
	stz		psgSubPanLeftDelta,x		; clear left  pan pot change amount
	stz		psgSubDurationMultiplier,x	; clear duration multiplier
	
	lda		psgSysEnv					; point to system envelope table
	sta		psgSubEnvelopePtrLo,x
	lda		psgSysEnv+1
	sta		psgSubEnvelopePtrHi,x

	;...........................................................................
	; set defaults for non-zero items
	
	lda		#$84
	sta		psgSubEnvReleaseHi,x		; set release rate to $8400
	
	lda		#4
	sta		psgSubOctave,x				; default octave number

	;...........................................................................
	; next header entry : voice data location
	
	iny									; next byte in track header
	lda			[psgPtr1],y				; get voice data addresss
	sta			psgSubTrackPtrLo,x		; save track pointer
	sta			psgSubSegnoLo,x			; and repeat location (ie, segno)
	
	iny									; next byte in track header
	lda			[psgPtr1],y			    ; get voice data addresss
	sta			psgSubTrackPtrHi,x		; save track pointer
	sta			psgSubSegnoHi,x			; and repeat location (ie, segno)

	;...........................................................................
	; skip channel if not 5 or 6 (noise-capable channels)
	
	lda			#$80					; noise off flag
	cpx			#4						; non-noise channel
	bcc			.notNoiseChannel		; if not a noise-capable channel, skip flagging

	;...........................................................................
	; pay attention: noise flags are right after wave flags. X must be at
	; least 4 to get here. 2476+4 = 247a, which is address we have defined.
	; ergo, to use straight X as index, we need 247a-4, which is 2476
	;...........................................................................
	; c3bc: 9d 76 24    STA $2476, X	; disable noise (if voice is noise-capable)

	sta		psgSubNoiseFlag-4, X		; mark noise as diabled.
	
.notNoiseChannel
	sta		psgSubWaveNo,x			 	; disable waveform download. last loaded is 0
	bbr6	<psgTemp2, .nextVoice		; check debug flag. That's why we saved flags twice!
	
	;...........................................................................
	; track marked for debug mode. copy debug waveform number to voice waveform
	
	lda		psg_WaveNo					; get debug wave number
	sta		psgSubWaveNo,x				; save as voice waveform. Note bit 7 should be off,
										; so it will get loaded when we reach that point
										
	;...........................................................................
	; that voice should be initialized. do the next voice
	
.nextVoice
	inx
	cpx		#6
	bcc		.voiceLoop

	;...........................................................................
	; initialize remaining track variables
	
	stz		psgSubFadeOutSpeed			; clear fade speed
	stz		psgSubFadeOutCount+1 		; clear fade count (only 1 byte?)

	;...........................................................................
	; enable track
	
	lda		#$80
	tsb		psgSongNo					; set bit 7 in song on (ie, song ready)

	lda		#$40						; sub pause bit
	trb		psgTrackCtrl				; turn off sub paused bit (?)
	rts
