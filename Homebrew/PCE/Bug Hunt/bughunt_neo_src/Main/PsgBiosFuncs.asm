;*****************************************************************************
; PSG_BIOS.ASM
;-----------------------------------------------------------------------------
; functions that make up the PSG_BIOS functionality of the psg driver system.
;-----------------------------------------------------------------------------
; A PSG_BIOS call passes the function number in the _DH psuedo register.
; Any parameters to the call are passed in the _AX psuedo register.
;.............................................................................
; the bios routines preserve the X and Y registers, and return any values in 
; the A register
;-----------------------------------------------------------------------------


;*****************************************************************************
; psgBios functions.
;.............................................................................
; these are the psg bios functions. They reside in a seperate code page, and 
; hence have to be mapped in and out before they are called.
;-----------------------------------------------------------------------------
; Origin is at $C000.     (mmu slot 6?)
; This is normally occupied by "START_BANK" when the program is destined for 
; CDROM, but should be OK for HuCard-only development.
; (note: PSG player exists in system card when developing for CDROM)
;.............................................................................

	.org	$C000

;-----------------------------------------------------------------------------
; PSG_ON : Enable the psg driver. Note that psgFlags (aka psg_inhibit) gets
;          set to 1 when hardware is initialized. (that's OFF, but on VSync)
;.............................................................................
; _AL is interrupt to respond to.  0=TIMER, 1=VSYNC
;.............................................................................

psgOn:

    ;-----------------------------------------------------------------------
    ; if psg is already running, turn it off.

	lda			<psgFlags
	bpl			.noTurnOff						; if it's already OFF (bit 7 = 0),
												; skip turning it off
	
;	bbr7			<psgFlags,.noTurnOff		; if bit 7 is off, psg is already off
	jsr				psgOff	 	  		        ; otherwise, stop the psg
	
.noTurnOff:

    ;-----------------------------------------------------------------------
	; mark as having valid irq information, and save irq flag

	lda		<_al			; get parameter. Calls above probably trashed A
	and		#PSG_IRQ		; clear all bits but irq
	ora		#PSG_INHIBIT	; turn on bit 7
	sta		<psgFlags		; save as valid, with irq in bit 0
	
    ;-----------------------------------------------------------------------
    ; if on timer irq, start timer

    and		#PSG_IRQ		; are we using vsync ?
	bne		.psgOnExit		; skip timer setup if we are

	lda		#1				; timer on
	sta		timer_ctrl		; start timer.
	
.psgOnExit
	rts

;-----------------------------------------------------------------------------
; PSG_OFF : stop the psg driver
;.............................................................................

psgOff:
	lda		<psgFlags				; get flags
	bpl		.noStop					; if already OFF (bit 7 = 0), skip stopping it
	
;	bbr7	<psgFlags,.noStop			; if bit 7 is off, psg is not running
	jsr		psgAStop					; otherwise, stop the channels
	
.noStop:
	lda		<psgFlags
	and		#PSG_IRQ				; which interrput ?
	bne		.psgOffExit				; VSync, skip timer setup
	
;	bbs0	<psgFlags, .psgOffExit		; if low bit is set, we're using vsync.
	stz		timer_ctrl					; turn off timer irq

.psgOffExit:
	rts

;-----------------------------------------------------------------------------
; PSG_INIT : initialize psg, phase 1
;.............................................................................
; _al = 0 	-> main track only; 60Hz
; 		1	-> sub track only; 60Hz
; 		2	-> both tracks; 60Hz
; 		3	-> both tracks; 120Hz
; 		4	-> both tracks; 240Hz
; 		5	-> both tracks; 300Hz
;.............................................................................

			.org		$c043
psgInit:

    ;-----------------------------------------------------------------------
	; check parameter. if out of range, force to system 2
	
	cmp		#(PSGSYS_BOTH_300+1)	; max mode
	bcc		.parmOK					; if it's okay
	
	lda		#PSGSYS_BOTH_60			; switch to default
	
    ;-----------------------------------------------------------------------
	; map in bank 2 ? (isn't that us? )
	; I -think- this is making sure the wave-table data is mapped in....
	; but, the wave-table is later in this segment, so we don't need to re-map
	; it.
	
.parmOK

	tay						; save parameter
;	tma		#6				;		#$40			; get bank at $c000
;	pha						; save it
;	
;	lda		#$02			; get bank number
;	tam		#6				;$40			; and map it in.

    ;-----------------------------------------------------------------------
	; for each channel.... reset wave-form data pointer

	lda		#PSG_DDA		; 64 -> 0100_0000 -> 'dda' bit
	ldx		#$05			; start at channel 5

	;.......................................................................
	; set default wave form for channel

.waveLoop

	stx		psgCurChannel	; save current psg channel selected
	stx		psg_ch			; select output channel
	
    sta		psg_ctrl		; togle dda bit, to reset waveform buffer
	stz		psg_ctrl		

    tin		psgWaves, psg_wavebuf, 32		; send wave form (32 bytes) to psg	
	
	;.......................................................................
	; next channel
	
	dex						; count down channel
	bpl		.waveLoop		; if >= 0, do next

    ;-----------------------------------------------------------------------
	; set main volume to max (hardware)
	
	lda		#$FF
	sta		psg_mainvol

    ;-----------------------------------------------------------------------
	; turn off LFO (hardware)
	
	lda		#1					; set LFO frequency to 1
	sta		psg_lfofreq			
	stz		psg_lfoctrl			; bit    7 =  0 -> LFO on
								; bits 0-1 = 00 -> don't apply LFO
								
    ;-----------------------------------------------------------------------
	; clear player global information (psgTrackIndexTable to  psgCurChannel)
	; note that part of it will get overwritten. 
	
	tai 	initTable+1, psgTrackIndexTable, 30	  ; copy 2 zero bytes, alternating, from initTable
												  ; to global control area. 30 bytes total 
	tii 	initTable, $22e3, 8					  ; copy initTable to $22e3. no idea what 22e3 is yet

	;................................................................................
	; clear main track / subtrack data areas

	sty		psgSystemNo				; save parameter (system number)
	cpy		#PSGSYS_SUB_ONLY		; playing just subtrack ?
	beq		.initSubTracks			; yep, set-up sub tracks

	;................................................................................
	; clear main track info

	tai		initTable+1, psgMainTrackPtrLo, $019d		; copy 2 zero bytes to main track data area
	bcc		.initTrackDone								; if not both systems, we're done

	;................................................................................
	; clear sub track info
	
.initSubTracks
	tai		initTable+1, psgSubTrackPtrLo, $018b			; copy 2 0 bytes to 248b, until 395 bytes done
	
	;................................................................................
	; clear zero-page pointer areas

.initTrackDone
	
	stz 	<psgPtr1				; clear psgPtr1
	stz 	<psgPtr1+1

	stz 	<psgPtr2				; clear psgPtr2
	stz		<psgPtr2+1

	stz 	<psg_irqflag				; not in middle of servicing interrupt

	;................................................................................
	; set control flag

	lda		<psgFlags				; get flag
	ora		#PSG_INHIBIT			; set bit 7 -> turn psg on
	sta		<psgFlags
	
	;................................................................................
	; init song number

	lda		#PSG_SNG_NEED_INIT							; song 0, but not ready
	sta		psgSongNo									; set song number

	lda		#(PSG_TRK_MAINPAUSE | PSG_TRK_SUBPAUSE )	; 1100_0000 -> main paused, sub paused
	sta		psgTrackCtrl								; save track control

	;................................................................................
	; set main track delay count according to system number (ie, speed)

	lda		defaultDelays,Y
	sta		psgTrackDelay

	;................................................................................
	; set default tempo according to system number (ie, speed)

	lda		defaultTempos,y				; load default tempo 
	jsr		psgSetTempo					; initialize tempo

	;................................................................................
	; restore original bank, cause we're done. Since I took out the map-in,
	; there's no reason to un-map...

;	pla
;	tam		#6			;#$40
	rts

	.include		"main\initTable.inc"
	.include		"main\defDelays.inc"
	.include		"main\defTempos.inc"
	
;-----------------------------------------------------------------------------
; PSG_BANK : register given bank numbers with psg driver
;.............................................................................

psgBank:
	
	lda		<_al
	sta		psgDataBankLow
	lda		<_ah
	sta		psgDataBankHigh
	rts

;-----------------------------------------------------------------------------
; PSG_TRACK : register base location of track index table with psg driver
;.............................................................................

psgTrack:

	lda		<_al
	sta		psgTrackIndexTable
	lda		<_ah
	sta		psgTrackIndexTable+1
	rts

;-----------------------------------------------------------------------------
; PSG_WAVE - register base address of user waveform table
;.............................................................................

psgWave:

	lda		<_al
	sta		psgUserWaveTable
	lda		<_ah
	sta		psgUserWaveTable+1
	rts

;-----------------------------------------------------------------------------
; PSG_ENV - register base address of user volume (adsr) envelopes.
;.............................................................................

psgEnv:
	lda		<_al
	sta		psgUserVolEnvelope
	lda		<_ah
	sta		psgUserVolEnvelope+1
	rts

;-----------------------------------------------------------------------------
; PSG_FM - register base address of user modulation envelopes.
;.............................................................................

psgFM:
	lda		<_al
	sta		psgUserModEnvelope
	lda		<_ah
	sta		psgUserModEnvelope+1

	rts

;-----------------------------------------------------------------------------
; PSG_PE - register base address of user pitch envelope
;.............................................................................

psgPE:
	lda		<_al
	sta		psgUserPitchEnvelope
	lda		<_ah
	sta		psgUserPitchEnvelope+1
	rts

;-----------------------------------------------------------------------------
; PSG_PC - register base address of user percussion table (aka, the drum table).
;          note: you can only have 1 set of drums, from what I've seen. 
;.............................................................................

psgPC:
	lda		<_al
	sta		psgUserPercTable
	lda		<_ah
	sta		psgUserPercTable+1
	rts

;-----------------------------------------------------------------------------
; PSG_SETTEMPO - set default tempo for song.
;.............................................................................

psgSetTempo:

	;................................................................................
	; map data bank in. (Why?)
	; -probably to make sure the table is mapped in. BUT, since it's in this segment,
	; we don't need to do this anymore (I think)
	
;	tax							; stash parameter
;	tma		#6		;$40				; get bank number
;	pha							; save it
;
;	lda		#$02				; bank 2? That's us, isn't it?
;	tam		#6		;$40				; map it in
;	txa							; restore parameter

	;...........................................................................
	; check arguement. if it's < 35, force to 35

	cmp		#35					; check parameter
	bcs		.okvalue			; it's good, keep going
	lda		#35					; out of range: force to 35
	
.okvalue:

	;...........................................................................
	; set new timer value
	
	tax
	lda		psgTempoTable-35,X	; look up value in table
	sta		psgTimerCount
	
	;...........................................................................
	; restore original data bank, we're done. Well, since I don't map it in
	; anymore, we don't have to up-map it....
;	
;	pla
;	tam		#6		;$40
	rts

;-----------------------------------------------------------------------------
; PSG_PLAY - play song # in track list (_al = song #)
;.............................................................................

psgPlay:

	;................................................................................
	; save parameters
	
	sta		psgSongNo			; save track/song number
	lda		<_ah				; get debug wave number
	sta		psg_WaveNo			; save it
	
	;................................................................................
	; mark player as not ready. 
	
;	lda		<psgFlags			; get control flag
;	and		#$7f				; turn off ready bit, save irq bit. Note that 0 value
;								; still gets serviced on timer...
;	sta		<psgFlags			; this may be how sub-tracks are handled....
	rts
	
;-----------------------------------------------------------------------------
; PSG_MSTAT - return bitmask of voices in use for main track
;.............................................................................

psgMStat:

	;...........................................................................
	; check which tracks are playing

	lda		#$80				; load return error value
	ldx		psgSystemNo			; get irq information
	cpx		#PSGSYS_SUB_ONLY	; subtrack only?
	beq		.mstatExit			; yes, exit with error
	
	;...........................................................................
	; main track in use. 6 voices to check

	ldx		#5					; start at voice 5
	cla							; clear status byte

	;...........................................................................
	; check voice status flag

.voiceLoop
	ldy		psgMainVoiceStatus,X	; get voice status
	bne		.isPlaying				; if not 0, it's playing

	;...........................................................................
	; status is not playing. shift in 0

	clc								; clear bit to shift in
	rol		a
	bra		.voiceDone				; go shift it in

	;...........................................................................
	; status is playing. shift in a 1

.isPlaying
	sec								; set bit to shift in
	rol		a
	;...........................................................................
	; shift carry into status byte
	

	;...........................................................................
	; check next voice

.voiceDone

	dex								; next voice.
	bpl		.voiceLoop
	
.mstatExit
    rts

;-----------------------------------------------------------------------------
; PSG_SSTAT - return bitmask of voices in use for sub track
;.............................................................................

psgSStat:

	;...........................................................................
	; check which tracks are playing

	lda		#$80				; load return error value
	ldx		psgSystemNo			; get irq information
	beq		.sstatExit			; main only, exit with error

	;...........................................................................
	; sub track in use. 6 voices to check

	ldx		#5					; start at voice 5
	cla							; clear status byte

	;...........................................................................
	; check voice status flag

.checkLoop
	ldy		psgSubVoiceStatus,X		; get voice status
	bne		.isPlaying				; if not 0, it's playing

	;...........................................................................
	; status is not playing. shift in 0

	clc								; clear bit to shift in
	rol		a
	bra		.voiceDone				; go shift it in

	;...........................................................................
	; status is playing. shift in a 1

.isPlaying
	sec								; set bit to shift in
	rol			a
	;...........................................................................
	; shift carry into status byte
	

	;...........................................................................
	; check next voice

.voiceDone

	dex								; next voice.
	bpl		.checkLoop
	
.sstatExit
    rts

;-----------------------------------------------------------------------------
; PSG_MSTOP - Stop voices in main track, as described in bitmask (in _al)
;.............................................................................

psgMStop:

	;...........................................................................
	; if main track isn't enabled, we don't need to stop anything.

    ldx		psgSystemNo				; get system number
	cpx		#PSGSYS_SUB_ONLY		; subtrack only ?
	beq		.mstopExit				; yep, nothing to do
	
	;..........................................................................
	; check pause all bit

	tay								; save parameter
	bpl			.mstopLoop			; bit off, skip marking all paused

	;..........................................................................
	; mark main track as all paused

	lda		psgTrackCtrl			; get track control flags
	ora		#$80					; set bit 7 (all main paused)
	sta		psgTrackCtrl			; save it
	
	;..........................................................................
	; pause individual tracks, as requested

.mstopLoop
	clx									; start with voice 0
	
.mvoiceLoop
	lda			psgMainVoiceStatus,X	; get status of voice
	beq			.nextVoice
	
	;..........................................................................
	; decide who to stop.

	tya								; restore bits for who to pause
	bmi			.stopMe				; if all-pause set, stop track.
	
	lsr			a					; bit for next track
	bcc			.nextVoice			; bit is 0 -> don't process voice

	stz			psgMainVoiceStatus,X		; mark voice as stopped

	;..........................................................................
	; check if sub-track is playing instead.
	
.stopMe

	lda		psgSystemNo				; get system number
	beq		.stopChan				; if it's main only, go ahead and stop the voice

	;..........................................................................
	; if sub-track is enabled and playing, let it play
	
	lda		psgSubVoiceStatus,x		; get sub-track status
	cmp		#1						; is it playing ?
	beq		.nextVoice				; sub-track playing, let it play

	;..........................................................................
	; main is playing and sub-track isn't. mute the channel
	
.stopChan

	stx		psgCurChannel			; save channel we're going to stop as last selected
	stx		psg_ch					; select the channel
	stz		psg_ctrl				; stop the channel
	
	;..........................................................................
	; update flags for next voice

.nextVoice

	tya								; restore flags from temp storage
	lsr		a						; update flags
	
	bit		#$40						; all-paused flag got shifted....
	beq		.noAllFix				; if it wasn't set, we don't have to fix it
	
	ora		#$80					; if all-pause was set, restore it
	
	;..........................................................................
	; do next voice
	
.noAllFix
	tay								; and update temp stash
	inx								; next voice number
	cpx			#6					; last one ?
	bcc			.mvoiceLoop			; nope, do next voice.
	
	;..........................................................................
	; we're all done.
	
.mstopExit
	rts
	

;-----------------------------------------------------------------------------
; PSG_SSTOP - Stop voices in sub track, as described in bitmask (in _al)
;.............................................................................

psgSStop:

	;...........................................................................
	; if main track isn't enabled, we don't need to stop anything.

	ldx		psgSystemNo				; get system number
	beq		.sstopExit				; main track only, nothing to do
	
	;..........................................................................
	; check pause all bit

	tay								; save parameter
	bpl			.sstopLoop			; bit off, skip marking all paused

	;..........................................................................
	; mark sub track as all paused

	lda		psgTrackCtrl			; get track control flags
	ora		#$40					; set bit 6 (all sub paused)
	sta		psgTrackCtrl			; save it
	
	;..........................................................................
	; set up to loop through voices
	
.sstopLoop
	clx									; start with voice 0
	
	;..........................................................................
	; pause individual tracks, as requested

.voiceLoop
	lda			psgSubVoiceStatus,X		; get status of voice
	beq			.nextVoice
	
	;..........................................................................
	; decide who to stop, all tracks or just individual ones.

	tya								; restore bits for who to pause
	bpl			.bitCheck			; if all-pause clear, we need to check bits.
	
	;..........................................................................
	; pause all the tracks. 
	
	lda			#$FF					; pause flag
	sta			psgSubVoiceStatus,x		; mark sub-track as paused (NOT stopped)
	bra			.flagsDone				; and go to stopping sound
	
	;..........................................................................
	; not pausing all voices; check the individual voice to see if it needs paused
	
.bitCheck
	lsr			a						; get bit
	bcc			.nextVoice				; if not pause requested, skip it
	
	stz			psgSubVoiceStatus,x		; pause requested, mark sub-track as paused (stopped?)
	
	;..........................................................................
	; at this point, our flags have been updated. Now we need to deal with
	; main/subtrack interaction, and actual sound.
	
.flagsDone

	lda		psgSystemNo					; get system
	cmp		#PSGSYS_SUB_ONLY			; subtrack only ?
	beq		.stopPsgChannel				; yeah, go ahead and stop the sound
	
	;..........................................................................
	; both systems are running. check main track to see what to do

	lda		psgMainVoiceStatus,X		; get main voice flag
	beq		.stopPsgChannel				; if main isn't running, stop the sound

	;..........................................................................
	;	no idea what's at 2474.....bit 7 is getting re-set, though
	
	lda		psgMainWaveNo,x				; re-set wave number for track
	and		#$7F						; not loaded yet....
	sta		psgMainWaveNo,x				; update waveform
	
	;..........................................................................
	; check to see if main should be playing.
	
	lda		psgTrackCtrl				; check control flags....
	bpl		.nextVoice					; if main track is running, skip to next voice
										; (and let main play on)
	;..........................................................................
	; stop sound from psg on this channel
	
.stopPsgChannel

	stx		psgCurChannel					; update selected channel
	stx		psg_ch							; select channel
	stz		psg_ctrl						; stop channel output

	;..........................................................................
	; update flags for next voice

.nextVoice
	tya								; restore flags from temp storage
	lsr		a						; update flags

	bit		#$40					; all-paused flag got shifted....
	beq		.noAllFix				; if it wasn't set, we don't have to fix it
	
	ora		#$80					; if all-pause was set, restore it
	
	;..........................................................................
	; do next voice
	
.noAllFix

    tay								; update temp stash
	inx								; next voice number
	cpx			#6					; last one ?
	bcc			.voiceLoop			; nope, do next voice.
	
	;..........................................................................
	; we're all done.
	
.sstopExit
	rts

;-----------------------------------------------------------------------------
; PSG_ASTOP - Stop all voices
;.............................................................................

psgAStop:

	;..........................................................................
	; stop psg driver
	
	lda		<psgFlags			; get control flags
	ora		#$80				; mark psg NOT ready (bit 7 = 0)
	sta		<psgFlags			; update control flags
	
	;..........................................................................
	; pause the tracks
	
	lda		#$C0				; 1100_0000 -> main and sub tracks paused
	sta		psgTrackCtrl		; pause everyone
	
	;..........................................................................
	; loop through tracks, and stop any that are playing.
	
	ldy		psgSystemNo			; get running systems
	ldx		#5					; last channel; we count down
	
	;..........................................................................
	; handle main track....

.voiceLoop	

	cpy		#PSGSYS_SUB_ONLY	; is it only subtrack active?
    beq		.doSubTrack			; yep, skip stopping this track in main

	stz		psgMainVoiceStatus,x		; mark main track as stopped
	bcc		.mainDone					; and if only main was running, do next

	;..........................................................................
	; handle sub-track
	
.doSubTrack

	stz		psgSubVoiceStatus,x			; mark sub-track as stopped
	
	;..........................................................................
	; stop the psg
	
.mainDone

	stx		psgCurChannel				; save selected channel
	stx		psg_ch						; select channel
	stz		psg_ctrl					; stop the channel
	
	;..........................................................................
	; next voice
	
	dex
	bpl		.voiceLoop
	
	rts

;-----------------------------------------------------------------------------
; PSG_MVOFF - turn Main volume off for voices specified in bitmask (in _al)
;.............................................................................

psgMvOff:

	ldx			psgSystemNo				; get system number
	cpx			#PSGSYS_SUB_ONLY		; is it subtracks only ?
	beq			.mvExit					; yes, exit
	
	;..............................................................................
	; turn off main voice as specifed by bits.

	clx								; start at voice 0

.mvLoop	
	lsr			a					; get flag bit
	bcc			.nextVoice			; if flag clear, skip this voice
	
	;..............................................................................
	; only turn off voice if it's on.

	ldy			psgMainVoiceStatus,x		; get voice state
	beq			.nextVoice					; if voice is off, skip it
	
	;..............................................................................
	; voice is on, we want it off.

	ldy			#$FF					; voice off value
	say									; save flags, put of token in A
	sta			psgMainVoiceStatus,X	; mark voice as off
	say									; restore flags
	
	;..............................................................................
	; check to see if main track is playing
	
	ldy			psgSystemNo			; get system number
	beq			.stopChannel		; if main only, stop the channel
	
	;..............................................................................
	; check to see if subtrack playing
	
	ldy			psgSubVoiceStatus,x			; get subtrack state
	cpy			#1							; is it playing ?
	beq			.nextVoice					; yes, let it play
	
	;..............................................................................
	; subtrack isn't playing, stop psg channel

.stopChannel
	stx			psgCurChannel		; save selected channel number
	stx			psg_ch				; select channel
	stz			psg_ctrl			; turn sound output off
	
	;..............................................................................
	; next voice
	
.nextVoice
	inx								; next voice
	cpx			#6					; all done ?
	bcc			.mvLoop

.mvExit
	rts
	
;-----------------------------------------------------------------------------
; PSG_CONT - continue playing stopped track
;.............................................................................
;
; parameter:
; 0 = main track
; 1 = sub track
; 2 = both
;.............................................................................

psgCont:

	tay								; save parameter
	
	lda		psgSystemNo				; get system number
	cmp		#PSGSYS_SUB_ONLY		; only subtrack playing?
	beq		.doSub					; main not playing, skip it
	
	;..............................................................................
	; check requested track

	cpy		#PSGSYS_SUB_ONLY		; want to continue sub-track
	beq		.doSub					; so skip main track

	;..............................................................................
	; restore main tracks that are stopped
	
	ldx		#5
	
.contMain

	lda		psgMainVoiceStatus,x		; get main voice state
	beq		.nextMain					; if voice off, skip it
	
    lda		#1							; mark voice as running
	sta		psgMainVoiceStatus,x
	
	;..............................................................................
	; next voice in main track
	
.nextMain

	dex								; count down
	bpl			.contMain
	
	;..............................................................................
	; update main track pause flag
	
	lda		psgTrackCtrl			; get track control bits
	and		#$7F					; turn OFF main paused
	sta		psgTrackCtrl			

	;..............................................................................
	; now we handle sub-tracks.
	
.doSub

	lda		psgSystemNo			; get system number
	beq		.reStart			; if main track only, skip sub-tracks
	
	tya							; get requested system to continue
	beq		.reStart			; if main track only, skip sub-tracks
	
	;..............................................................................
	; process the sub tracks
	
	ldx		#5					; do all voices
	
.contSub
	lda		psgSubVoiceStatus,x		; get status for voice
	beq		.nextSub				; sub track is stopped, skip it
	
	lda		#1						; mark as playing
	sta		psgSubVoiceStatus,x		
	
	;..............................................................................
	; request re-load of subtrack waveform
	
	lda		psgSubWaveNo,x			; get last waveform number for subtrack
	and		#$7f					; turn off loaded bit
	sta		psgSubWaveNo,x			; save it

	;..............................................................................
	; next voice in sub track
	
.nextSub

	dex
	bpl		.contSub
	
	;..............................................................................
	; sub-tracks done.  turn off sub-track pause flag
	
	lda		psgTrackCtrl		; get track control flags
	and		#$BF				; 1011_1111 -> sub paused off
	sta		psgTrackCtrl		; update track control
	
	;..............................................................................
	; re-start player
	
.reStart
	lda			<psgFlags		; get player flags
	and			#$7f			; clear bit 7 -> psg not ready now
	sta			<psgFlags		; update flags
	
	rts

;-----------------------------------------------------------------------------
; PSG_FDOUT - fade out main track
;.............................................................................
; _al is fade out speed.
;.............................................................................

psgFadeOut:

	;..............................................................................
	; check system. we can only fade out main track
	
	ldx		psgSystemNo					; get system number
	cpx		#PSGSYS_SUB_ONLY			; only subtrack enabled?
	beq		.fadeExit					; yep, we're done
	
	;..............................................................................
	; check parameter: 0 not allowed (we will never fade out)
	
	bit		#$7f				; and with all but sign, discard result
	beq		.fadeExit			; if all 0's, ignore fade out
								; [ because value is 0. note that 1000_0000 will
								;   will not be 0 because we kept sign bit. it will
								;	get correctly flipped to 128, I think ]
	
	;..............................................................................
	; clear fade-out counter
	
	stz		psgMainFadeOutCount				; clear fadout count (?)
	stz		psgMainFadeOutCount+1
	
	;..............................................................................
	; if negative, correct to positive

	cmp		#0					; is parameter negative ?
	bpl		.notNeg				; no (positive or 0), skip 2's complement
	
	;..............................................................................
	; 2's complement to change sign
	
	eor		#$FF				; flip bits...
	inc		a					; and add 1
	
	;..............................................................................
	; save fade out speed.
	
.notNeg
	sta		psgMainFadeOutSpeed		; save (positive) speed
	
.fadeExit
	rts


;-----------------------------------------------------------------------------
; PSG_DCNT - set (main track) delay counter.
;.............................................................................
;  sets limit on up-counter used if interrupt frequency is >60Hz. This will 
;  act as a frequency divider (by ignoring interrupts until this value is hit)
;.............................................................................
; _al = delay counter
;.............................................................................

psgDCnt:
	and		#$07			; force into range
	sta		psgTrackDelay	; save it as delay count
	rts

