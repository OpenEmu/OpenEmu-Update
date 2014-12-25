;-----------------------------------------------------------------------------
; Send sound to psg for output
;
; X should hold voice to send....

subOutputSounds
	ldx		#5
	
	;..........................................................................
	; is voice on ?
	
.voxLoop
	lda		psgSubVoiceStatus,x			; get voice status
	cmp		#1								; is it on ?
	bpl		.voxOn							; yes, keep going
	jmp		.nextVoice						; no, skip it
	
	;..........................................................................
	; voice is on. check to see if it ended.

.voxOn	

	stx		psg_ch					; select hardware voice
	beq		.voxOK					; if status is 0, main is playing

	;..........................................................................
	; status is something other than 0 or 1. we assume that means the track ended.
	
	stz		psg_ctrl				; turn channel off
	stz		psgSubVoiceStatus,x		; turn voice off

	;..........................................................................
	; voice is shutting off. is main still playing ?
	
	lda		psgSystemNo				; check system number
	cmp		#1						; sub-track only. 
	beq		.skipSub				; leave voice off
	
	lda		psgMainVoiceStatus,x	; get main track state
	beq		.skipSub				; main off, leave track off

	;..........................................................................
	; sub-track ended, but main should keep playing. restore waveform 
	
	lda		psgMainWaveNo,x	
	and		#$7f
	sta		psgMainWaveNo,x
	
.skipSub
	jmp		.nextVoice				; track on, ignore it.
	
	;..........................................................................
	; check main to see if we need wave change
	
.voxOK

	lda		psgSubWaveNo,x			; get wave number for voice
	bmi		.waveOK					; if bit 7 set, wave already loaded

	;..........................................................................
	; mark wave as being loaded. We're gonna load it next
	
	ora		#$80					; mark wave as loaded
	sta		psgSubWaveNo,x			; save it
	and		#$7F					; resore original wave number
	cmp		#$2d					; is it internal wave ?
	bcs		.isUserWave				; nope, load user waveform
	
	;..........................................................................
	; wave number is internal wave. load it.

	jsr		getWaveOffset			; locate wave data
	lda		#LOW( psgWaves )		; add base address
    clc
	adc		<psgPtr1					; add low byte to offset
	sta		<psgPtr1
	lda		#HIGH( psgWaves )
	adc		<psgPtr1+1				; add high byte to offset
	sta		<psgPtr1+1
	bra		.loadWave
	
	;..........................................................................
	; wave number is user wave. locate and load it

.isUserWave

	sec								; subtract internal wave numbers
	sbc		#$2d
	jsr		getWaveOffset			; calculate offset from user wave table

	lda		psgUserWaveTable		; low byte of user table
	clc
	adc		<psgPtr1
	sta		<psgPtr1
	lda		psgUserWaveTable+1		; high byte of user table
	adc		<psgPtr1+1
	sta		<psgPtr1+1
	
	;..........................................................................
	; load wave to psg. psgPtr1 is address of wave data.
	
.loadWave

	lda		#PSG_DDA				; DDA bit in psg
	sta		psg_ctrl				; turn psg off
	stz		psg_ctrl				; reset psg to load wave
	
	; I don't see why they didn't use block instruction....
	cly								; y is byte count
.sendByte
	lda		[psgPtr1],y				; get value
	sta		psg_wavebuf				; save in psg
	iny
	cpy		#32						; 32 bytes done ?
	bcc		.sendByte				; nope, loop
	
	;..........................................................................
	; waveform all set. is voice in noise mode ?
	
.waveOK

	cpx		#4						; is it noise-capable channel ?
	bcc		.notNoise				; nope, skip noise setup
	
	lda		psgSubNoiseFlag-4,x		; check for noise
	bmi		.notNoise				; if bit 7 set, se've already set noies freq.
	
	ora		#$80					; mark as noise set
	sta		psg_noise				; save noise frequency (?)
	bra		.noiseOK				; done setting noise

	;..........................................................................
	; channel not noise capable, turn off noise
	
.notNoise

	stz		psg_noise				; no noise
	lda		psgSubFreqLo,x			; save tone frequency
	sta		psg_freqlo
	lda		psgSubFreqHi,x
	sta		psg_freqhi
	
	;..........................................................................
	;	set volume pan register
	
.noiseOK
	lda		psgSubPanPot,x			; get panning values
	sta		psg_pan					; update register
	
	lda		psgSubTrackVolume,x	; get track volume
	
	sec
	sbc		psgSubFadeOutCount+1	; minus fade-out stuff (?)
	beq		.voxMute				; if 0, mute voice
    bpl		.voxVol					; if > 0, set volume
	
	;..........................................................................
	; set track volume
	
.voxMute
	stz		psg_ctrl				; mute voice and stop channel
	bra		.nextVoice

.voxVol	
	ora		#$80					; turn on track play bit
	sta		psg_ctrl	
	
	;..........................................................................
	; do next voice
	
.nextVoice
	dex
	bmi		.volExit				; if all done, exit
	jmp		.voxLoop				; to top of loop

.volExit
	rts


