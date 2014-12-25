;******************************************************************************************************
; MAIN TRACK MUSIC DRIVER : this still has a LOT of debug stuff in it.
;------------------------------------------------------------------------------------------------------

psgMainDrive

	;...........................................................................
	; make sure song is ready.

	jsr		initCheck				; initialize song, if it needs it.
		
	;...........................................................................
	; does main track need updated ?

	lda		psgTrackCtrl			; get track control bits
	bmi		.mainStatusUpdate		; if main track paused, skip to status update

	;...........................................................................
	; main not paused, it needs updated. count interrupt, see if time to update.

	inc		psgTrackCtrl			; count interrupt
	and		#$0F					; keep it in range
	cmp		psgTrackDelay			; did we reach delay count ?
	bcc		.mainStatusUpdate		; nope, it's not time to update
	
	;...........................................................................
	; time to update main track. reset delay count
	
	lda		#$0F					; only change low 4 bits
	trb		psgTrackCtrl			; zero delay count
	
	;...........................................................................
	; main track voice loop

	lda		#5						; count down voices
	sta		psgCurrentVoice			; save working voice

.voiceLoop
	;...........................................................................
	; check voice status, skip it if off
	
	ldx		psgCurrentVoice			; retrieve working voice
	lda		psgMainVoiceStatus,x	; get status
	beq		.voiceNext				; if off, skip it
	
	;...........................................................................
	; voice needs updated. Call subroutines to do it
	
	jsr		mainParseMMLCodes
	jsr		processVolume
	jsr		processDrums
	jsr		processEnvelope
	jsr		processFrequency

	;...........................................................................
	; process next voice
	
.voiceNext

	dec		psgCurrentVoice		; count down voice
	bpl		.voiceLoop			; loop if not done

	;...........................................................................
	; all the main track voices have been handled. 
	; fade out if needed, and output sounds

	jsr		processFade
	jsr		outputSounds

	;...........................................................................
	; and finally, update the main tracks status.
	; Note that the return at end of psgMStat, sends us back to whomever called us.

.mainStatusUpdate
	jmp		psgMStat			; update track status. I'm not sure why; we don't do anything
								; with it and it doesn't change anything...

;-----------------------------------------------------------------------------
; initCheck - initialize track information, if needed.

initCheck
	lda		psgSongNo			; check song number
	bpl		psgSetupSong		; if not already started (or changed), go start it

driveExit
    rts
	
;-----------------------------------------------------------------------------
; psgSetupSong - initialize song information
;.............................................................................
;  IN : A = song number

psgSetupSong

	;...........................................................................
	; convert song number to 2-byte offset, put in Y for indexing
	
	asl		a			; 2 bytes per pointer
	tay					; into index Y
	
	;...........................................................................
	; locate pointer for this song's header

	lda		psgTrackIndexTable			; location of track pointers
	sta		<psgPtr2						; set up zp pointer

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
								
	bmi		driveExit			; if it's a sub track, we're done

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
	; set main voice status, note duration.
	
	lda		#1
	sta		psgMainVoiceStatus,x		; mark voice as enabled
	sta		psgMainNoteDuration,x		; set duration to 1 ?
	
	;...........................................................................
	; clear main voice information
	

	stz		psgMainTieState,x			; clear tie state (ie, note not tied)
	stz		psgMainKeyOffPeriods,x		; clear # periods Key is off
	stz		psgMainVoiceVolume,x		; clear per-channel voice volume (100%?)
	
	stz		psgMainModDelay,x			; clear modulation delay
	stz		psgMainPEDelay,x			; clear pitch envelope delay
	stz		psgMainModCorrection,x		; clear modulation correction

    stz		psgMainDetuneAmount,x		; clear detune amount
	stz		psgMainSweepDelta,x			; clear sweep change amount
	stz		psgMainSweepTime,x			; clear sweep time

	stz		psgMainStackOffset,x		; clear offset from stack base
	stz		psgMainTransposeAmount,x	; clear transpose amount
	stz		psgMainVolumeChangeAmount,x	; clear volume change amount
	stz		psgMainPanRightDelta,x		; clear right pan pot change amount
	stz		psgMainPanLeftDelta,x		; clear left  pan pot change amount
	stz		psgMainDurationMultiplier,x	; clear duration multiplier
	
	lda		psgSysEnv					; point to envelope 0
	sta		psgMainEnvelopePtrLo,x
	lda		psgSysEnv+1
	sta		psgMainEnvelopePtrHi,x

	;...........................................................................
	; set defaults for non-zero items
	
	lda		#$84
	sta		psgMainEnvReleaseHi,x		; set release rate to $8400
	
	lda		#4
	sta		psgMainOctave,x				; default octave number

	;...........................................................................
	; next header entry : voice data location
	
	iny									; next byte in track header
	lda			[psgPtr1],y				; get voice data addresss
	sta			psgMainTrackPtrLo,x		; save track pointer
	sta			psgMainSegnoLo,x		; and repeat location (ie, segno)
	
	iny									; next byte in track header
	lda			[psgPtr1],y			    ; get voice data addresss
	sta			psgMainTrackPtrHi,x		; save track pointer
	sta			psgMainSegnoHi,x		; and repeat location (ie, segno)

	;...........................................................................
	; skip channel if not 5 or 6 (noise-capable channels)
	
	lda			#$80					; moise off flag
	cpx			#4						; last non-noise channel
	bcc			.notNoiseChannel		; if not a noise-capable channel, skip flagging

	;...........................................................................
	; pay attention: noise flags are right after wave flags. X must be at
	; least 4 to get here. 2476+4 = 247a, which is address we have defined.
	; ergo, to use straight X as index, we need 247a-4, which is 2476
	;...........................................................................
	; c3bc: 9d 76 24    STA $2476, X	; disable noise (if voice is noise-capable)

	sta		psgMainNoiseFlag-4, X		; mark noise as diabled.
	
.notNoiseChannel
	sta		psgMainWaveNo,x			 	; disable waveform download. last loaded is 0
	bbr6	<psgTemp2, .nextVoice		; check debug flag. That's why we saved flags twice!
	
	;...........................................................................
	; track marked for debug mode. copy debug waveform number to voice waveform
	
	lda		psg_WaveNo					; get debug wave number
	sta		psgMainWaveNo,x				; save as voice waveform. Note bit 7 should be off,
										; so it will get loaded when we reach that point
										
	;...........................................................................
	; that voice should be initialized. do the next voice
	
.nextVoice
	inx
	cpx		#6
	bcc		.voiceLoop

	;...........................................................................
	; initialize remaining track variables
	
	stz		psgMainFadeOutSpeed			; clear fade speed
	stz		psgMainFadeOutCount+1 		; clear fade count (only 1 byte?)

	;...........................................................................
	; enable track
	
	lda		#$80
	tsb		psgSongNo					; set bit 7 in song on (ie, song ready)

	lda		psgTrackCtrl				; get track control bits
	and		#$70						; turn off bit 7 (main -not- paused)
										; -and- clear delay count
	ora		psgTrackDelay				; set delay to max
	sta		psgTrackCtrl				; and update control
	rts
