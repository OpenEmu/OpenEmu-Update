;*****************************************************************************
; PSG_BIOS.ASM - functions available from the PSG_BIOS interface
;.............................................................................

;-----------------------------------------------------------------------------
; Origin is at $C000.     (mmu slot 6?)
;
; This is normally occupied by "START_BANK" when the program
; is destined for CDROM, but should be OK for HuCard-only
; development (note: PSG player exists in system card when
; developing for CDROM)
;
	.bank	PSG_BANK,"PSG Driver"
	.org	$C000

;*****************************************************************************
; PSG_ON : Enable the psg driver.
;-----------------------------------------------------------------------------
; IN:  _al -> 0 = USE TIMER IRQ, 1 = USE VSYNC IRQ
;-----------------------------------------------------------------------------
; the original version was screwed. Majorly screwed up. This one still doesn't turn things off
;-----------------------------------------------------------------------------

psg_on:

    ;-----------------------------------------------------------------------
    ; if psg is already running, turn it off.

	bbr7			<psg_inhibit,.noturnoff		; if bit 7 is OFF, psg is stopped. 
												; if bit 7 is ON,  we need to stop psg
	bsr	psg_off									;	 psg is on, stop it
	
    ;-----------------------------------------------------------------------
	; decide which irq to use. set up timer if we are using it.
	
.noturnoff:

	lda		_al						; which interrupt does user want?
	beq		.use_timer				; 0 = VSYNC, skip timer init.

    ;-----------------------------------------------------------------------
	; on VSYNC interrupt. turn on vsync flag.

	smb0	<psg_inhibit			; mark as on vsync
    stz		 timer_ctrl				; turn off timer
	stz 	 timer_cnt				
	bra		.turn_on				; continue on

    ;-----------------------------------------------------------------------
	; on timer interrupt. set up count, turn timer on

.use_timer

	rmb0	<psg_inhibit			; mark as on timer
	stz		timer_cnt				; send initial count to hardware

    ;-----------------------------------------------------------------------
	; we don't turn irq on until play....

.turn_on

	lda		#112				; #115 = roughly 60.800Hz
	sta		psgTimerCount		; set count

	stz		psgMainDelay		; clear delay
	stz		psgMainDelayCount   ;
	rts


; ----------------------------------------------------------------------------------------
; PSG_OFF : disable the psg driver
; ----------------------------------------------------------------------------------------
;
; turn off PSG
; - all sound
; - interrupt service (if TIMER)
;
psg_off:
	bbs7	<psg_inhibit,.nostop		; if bit 7 is on, psg is running
;	jsr		psg_astop					; otherwise, stop the channels
	
.nostop:
	stz		timer_ctrl						; turn off timer irq
	rmb7	<psg_inhibit					; and turn psg off
	rts

; -----------------------------------------------------------------------------------------
; PSG_INIT : initialize psg, phase 1
; -----------------------------------------------------------------------------------------
;
; Initialize PSG.  CDROM version has a parameter:
; 0=main track only; 60Hz
; 1=sub track only; 60Hz
; 2=both tracks; 60Hz
; 3=both tracks; 120Hz
; 4=both tracks; 240Hz
; 5=both tracks; 300Hz
;
; This version only supports "main track/60Hz" for now. though it does hook the timer
; to do tempos...
; -------------------------------------------------------------------------------------------
; this is the initialization for the psg. it -should- clear all the variables, and set
; everything up the way we want it. We take it one step at a time, and don't try to get
; fancy, until we know it works.
; --------------------------------------------------------------------------------------------

psg_init:

    ;-----------------------------------------------------------------------
	; set up tin instruction in ram. It has to be ram, so we can modify it.
	
	lda		#$d3				; tin
	sta		lw
	stz		lw+1				; source
	stz		lw+2
	lda		#low( psg_wavebuf )    ; dest
	sta		lw+3
	lda		#high( psg_wavebuf )
	sta		lw+4
	lda		#32					; length
	sta		lw+5
	stz		lw+6
	lda		#$60				; rts
	sta		lw+7

	;----------------------------------------------------------------------
	; set default tempo. (lowest tempo) and mute the sound

	stz		psgTempo				; clear tempo info
	stz		psg_mainvol				; mute sound

	;----------------------------------------------------------------------
	; clear user pointer information, just in case
	
	stz		psgUserWaveTable	
	stz		psgUserWaveTable+1
	stz		psgUserVolEnvelope
	stz		psgUserVolEnvelope+1
	
	;----------------------------------------------------------------------
	; clear current channel, for loop
	
	stz		psgCurChannel
	
initLoop:

	;-------------------------------------------------------------------------------------
	;  select the channel, and mute it.
	;-------------------------------------------------------------------------------------

	ldx		psgCurChannel
	stx		psg_ch		        ; select channel
	
	lda		psgTimerCount		; this is the default
	sta		psgTempoMax,x		; set default channel tempo.
	stz		psgTempoCur,x
	
	stz		psgNoteFlags,x		; clear flags
	
	lda		#0					; set panning to 0
	sta		psg_pan              
	sta		psgChPan,x			; update channel control variable
		
	lda		#0					; set channel volume to none
	sta		psgChVolHigh,x
    sta		psgChVolLow,x
	
	;-------------------------------------------------------------------------------------
	; set default wave for channel to 0
		
	stz		psgChWaveNo, x		; default is simple sin wave
	jsr		loadWave

	;-------------------------------------------------------------------------------------
	; set default values for channel.
	;-------------------------------------------------------------------------------------

	lda		#4
	sta 	psgChOctave,x				; default octave is 4

	lda		#8
	sta		psgChSoundRatio,x			; default on ratio is 8/8
		
	stz		psgNoteFlags,x				; clear note flags
	stz		psgChFlags,x
	
	stz	 	psgChTimeBase, x			; default time base : ie, ticks per quanta
	stz		psgChTransAmt,x				; default transposition amount

	stz		psgChSweepAmt,x				; default step for frequency sweeps
	stz		psgChSweepCur,x				; current count for sweeps
	stz		psgChSweepTime,x			; delay counter for sweeps

	stz		psgChPanLAmt,x 				; channel pan left change amount
	stz		psgChPanLCur,x				; channel pan left current count
		
	stz		psgChPanRAmt,x				; channel pan right change amount
	stz	    psgChPanRCur,x				; channel pan right current count
		
	stz   	psgChFreqLow, x				; channel frequency
	stz   	psgChFreqHigh, x
	
	stz		psgChStackTop, x			; call stack offset
    
	stz		psgVolEnvPtrLow, x          ; zero user volume envelope pointer
	stz		psgVolEnvPtrHigh, x			
	stz		psgVolEnvOffset,x			; and volume envelope offset
	
	stz		psgVolEnvCount,x			; clear count
	inc		psgVolEnvCount,x			; need at least 1
	
	stz		psgVolEnvRelLow,x			; clear release rate
	stz		psgVolEnvRelHigh,x
	stz		psgVolEnvDecayLow,x			; clear decay rate
	stz		psgVolEnvDecayHigh,x
	
	stz		psgPitchEnvPtrLow,x
	stz		psgPitchEnvPtrHigh,x
	stz		psgPitchEnvOffset,x
	stz		psgPitchEnvDelay,x
	stz		psgPitchEnvCount,x
	
	;-------------------------------------------------------------------------------------
	; channel done, proceed to next channel
	
	inc		psgCurChannel
	lda		psgCurChannel
	cmp		#6
	beq		.out
	jmp		initLoop

	;-------------------------------------------------------------------------------------
	; done with ALL channels, turn main volume back up
.out
	lda     #$FF
	sta		psg_mainvol				; update hardware
	sta		psgMainVolume			; volume  = silent

	rts

; -----------------------------------------------------------------------------------------
; PSG_BANK : register given bank numbers with psg driver
; -----------------------------------------------------------------------------------------

psg_bank:
	
	lda		<_al
	sta		psgDataBankLow
	lda		<_ah
	sta		psgDataBankHigh
	rts

; -----------------------------------------------------------------------------------------
; PSG_TRACK : register base location of track index table with psg driver
; -----------------------------------------------------------------------------------------

psg_track:

	lda		_al
	sta		psgTrackIndexTable
	lda		_ah
	sta		psgTrackIndexTable+1
	rts

; -----------------------------------------------------------------------------------------
; PSG_WAVE - register base address of user waveform table
; -----------------------------------------------------------------------------------------

psg_wave:

	lda		_al
	sta		psgUserWaveTable
	lda		_ah
	sta		psgUserWaveTable+1
	rts

; -----------------------------------------------------------------------------------------
; PSG_ENV - register base address of user volume (adsr) envelopes.
; -----------------------------------------------------------------------------------------

psg_env:
	lda		_al
	sta		psgUserVolEnvelope
	
	lda		_ah
	sta		psgUserVolEnvelope+1

	rts

; -----------------------------------------------------------------------------------------
; PSG_FM - register base address of user modulation envelopes.
; -----------------------------------------------------------------------------------------

psg_fm:
	lda		_al
	sta		psgUserModEnvelope
	
	lda		_al
	sta		psgUserModEnvelope+1

	rts

; -----------------------------------------------------------------------------------------
; PSG_PE - register base address of user pitch envelope
; -----------------------------------------------------------------------------------------

psg_pe:
	lda		_al
	sta		psgUserPitchEnvelope
	
	lda		_ah
	sta		psgUserPitchEnvelope+1
	rts

; -----------------------------------------------------------------------------------------
; PSG_PC - register base address of user percussion table (aka, the drum table).
;          note: you can only have 1 set of drums, from what I've seen. 
; -----------------------------------------------------------------------------------------

psg_pc:
	lda		_al
	sta		psgUserPercTable
	
	lda		_ah
	sta		psgUserPercTable+1

	rts

; -----------------------------------------------------------------------------------------
; PSG_SETTEMPO - set default tempo for song (?)
; -----------------------------------------------------------------------------------------

psg_settempo:

	lda	<_al
	sub	#35
	bpl	.okvalue
	cla
.okvalue:

	tax
	lda	psg_tempotbl,X
	sta	psgTimerCount
	
	;-----------------------------------------------------------------------------
	; update default tempo for channels.

	ldx		#0
.loop
	sta		psgTempoMax,x		; save tempo to channel
	stz		psgTempoCur,x		; clear count
	inx
	cpx		#6
	bne		.loop

	;-----------------------------------------------------------------------------
	; using tempos : set main delay to 1
	
	lda	#1
	sta	psgMainDelay
	sta	psgMainDelayCount

	;-----------------------------------------------------------------------------
	; this needs to swap over to timer irq to work right.
	
	rmb0	<psg_inhibit		; mark as on timer
	lda		psgTimerCount
	sta		timer_cnt			; send initial count to hardware
	
	rts

; -----------------------------------------------------------------------------------------
; PSG_PLAY
;
; play song # in track list (_al = song #)
; -----------------------------------------------------------------------------------------
; currently, we only play song #0 (ie, the first song)
; -----------------------------------------------------------------------------------------
; we assume you are only going to call psgPlay once, when you start a song. It takes care
; of some initializations that should only be done once, but can't be done in init, because
; the values were not set then.
;------------------------------------------------------------------------------------------

psg_play:

	;-------------------------------------------------------------------------------------
	; set up global information about song.
	
	jsr		mapBanks				; map data banks into address space
	
	jsr		getSongHeader			; locate header information for selected song
	jsr		getChannelFlags			; retrieve channel active flags
	jsr		incChannelPointer		; bump past flags
	
	;--------------------------------------------------------------------------------------
	; update milli-tick counters: this should also flag channel as responding to irq
	
	jsr		updateTickCounts

	;----------------------------------------------------------------------
	; clear current channel, for loop
	
	stz		psgCurChannel

play_loop:

	ldx		psgCurChannel				; load current index
	stx		psg_ch				        ; select channel

	;-------------------------------------------------------------------------------------
	; for now, copy note flags to zero-page location
	
	stz		psgNoteFlags,x				; clear channel note flags
	sta		<psg_noteflags
	
	lda     psgChFlags,x				; get flag
	sta		<psg_chflags
	
	;-------------------------------------------------------------------------------------
	; is channel already initialized ?
	
    bbs0	<psg_chflags, done			; if init bit set, ignore initialization
	
	;-------------------------------------------------------------------------------------
    ; channel needs initialized: is this channel active ?
.ok	
	ror		psgChActive			    ; get control bit
	bcc		done					; 0 = not used, do next channel

	;-------------------------------------------------------------------------------------
	; channel is active. save current table location
	
	jsr		copyChannelPointer
	
	;-------------------------------------------------------------------------------------
	; move to next table entry, so we are ready for next channel

	jsr		incChannelPointer
	jsr		incChannelPointer		; 2 bytes per entry

	;-------------------------------------------------------------------------------------
	;  we have location to start at, save it for segno.

	lda		psgChCurByteLow,x
	sta		psgChSegnoLow,x

	lda		psgChCurByteHigh,x
	sta     psgChSegnoHigh,x

	;-------------------------------------------------------------------------------------
	; get note to play. New note should reset all envelopes

	jsr		NewNote							; get new note from input
	bcs		.init							; at end of data. mark as init

	jsr		getFrequency					; get frequency to send, including de-tune amount
	
	;-------------------------------------------------------------------------------------
	; if we are in percussion mode, we can ignore drum set-up.
	
	lda		psgChMode,x				; get channel mode
	beq		.normal_note			; not drum / noise mode, process as normal

	;-------------------------------------------------------------------------------------
	; if drum note is a rest, handle it as normal rest
	
	bbr0	<psg_noteflags, .normal_note		; if it's a rest, skip drum processing
	jsr		StartDrum						; start drum and/or noise

.normal_note:
	
	;-------------------------------------------------------------------------------------
	; which mode is the channel in ? If its noise or drums, we'll handle it in a subroutine.
	; come to think of it, we -should- handle the main processing in a subroutine...

	lda		psgChMode,x				; get channel mode
	beq		.normal
	
	;-------------------------------------------------------------------------------------
	; if drum note is a rest, handle it as normal rest
	
	bbr0	<psg_noteflags, .normal	; if it's a rest, skip drum processing
	jsr		PlayDrum				; play drum tones.
	
	;-------------------------------------------------------------------------------------
	; now that all of the calculations are done, we can send it to the hardware.
	
.normal

	jsr		HandleNote				; process notes
	
	;-------------------------------------------------------------------------------------
	; mark this channel as initialized

.init:		
	smb0	<psg_chflags
	
	;-------------------------------------------------------------------------------------
	;	done with current channel. Update indexes, do next channel if any
	
done:

	;-------------------------------------------------------------------------------------
	; now that channel is done, replace note flags.
	
	lda		<psg_noteflags
	sta		psgNoteFlags,x

	lda		<psg_chflags
	sta		psgChFlags,x
	
	;-------------------------------------------------------------------------------------
	; update channel
	
	inc		psgCurChannel
	lda		psgCurChannel
	cmp		#6
	beq		.out
	jmp		play_loop
	
	;-------------------------------------------------------------------------------------
	; done with all channels; reset main volume.
	
.out	
	lda		psgMainVolume
	sta		psg_mainvol           ; update hardware

	;-------------------------------------------------------------------------------------
	; restore original memory configuration.

	jsr		mapBanks				; map data banks into address space

	;-------------------------------------------------------------------------------------
	; if we're using timer, set timer count and turn it on.
	
	bbs0	<psg_inhibit, .no_timer
	
	stz		timer_ctrl			; turn timer off, so we can re-load count
	lda		psgTimerCount		; re-load count
	sta		timer_cnt

	lda		#1					; turn the timer on
	sta		timer_ctrl
	
	;-------------------------------------------------------------------------------------
	; turn on irq, I hope

.no_timer	
	smb7	<psg_inhibit
	rts

; -----------------------------------------------------------------------------------------
; PSG_MSTAT
;
; return bitmask of voices in use for main track
; -----------------------------------------------------------------------------------------

psg_mstat:

	lda		psgChActive					;since we keep bits for who is active, use it
	rts

; ----
; PSG_SSTAT
;
; return bitmask of voices in use for sub track
; ----

psg_sstat:
;	ldy	#5
;	cla
;
;.loop:	
;	ldx	psg_voicectrl+6,Y
;	beq	.empty
;	sec
;	rol	A
;	bra	.next
;.empty:	clc
;	rol	A
;.next:	dey
;	bpl	.loop
	rts


; ----
; PSG_MSTOP
;
; Stop voices in main track, as described in bitmask (in _al)
; ----

psg_mstop:
;	lda	<_al
;	bpl	.nopause
;
;	lda	#PSG_MAINPAUSE	; set pause on MAIN track
;	tsb	psg_trkctrl
;
;	lda	<_al
;
;.nopause:
;	tay
;	clx
;
;.loop:	
;	lda	psg_voicectrl,X
;	beq	.nextvoice
;	tya
;	bmi	.pause		; is it a 'pause' for voice ?
;
;	lsr	A		; no, it is a 'stop'
;	bcc	.nextvoice	; this voice not in mask; skip it
;
;	stz	psg_voicectrl,X
;
;.pause:	
;	lda	psg_voicectrl+6,X	; check subtrack
;	cmp	#1
;	beq	.nextvoice
;
;	stx	psg_ch_value
;	stx	psg_ch
;	stz	psg_ctrl
;
;.nextvoice:
;	inx
;	cpx	#6
;	bcs	.out
;	tya
;	bmi	.pause2
;	
;	lsr	A
;	tay
;	bra	.loop
;
;.pause2:
;	lsr	A
;	ora	#$80		; retain high-bit set
;	tay
;	bra	.loop
;
;.out:	
	rts

; ----
; PSG_SSTOP
;
; Stop voices in sub track, as described in bitmask (in _al)
; ----

psg_sstop:
;	lda	<_al
;	bpl	.nopause
;
;	lda	#PSG_SUBPAUSE	; set pause on SUB track
;	tsb	psg_trkctrl
;
;	lda	<_al
;
;.nopause:
;	tay
;	clx
;
;.loop:	lda	psg_voicectrl+6,X
;	beq	.nextvoice
;	tya
;	bmi	.pause		; is it a 'pause' ?
;
;	lsr	A		; no, it is a 'stop'
;	bcc	.nextvoice	; voice not in mask; skip it
;
;	stz	psg_voicectrl+6,X
;	bra	.pause1
;.pause:
;	lda	#$ff		; pause control
;	sta	psg_voicectrl+6,X
;
;.pause1:
;	lda	psg_voicectrl,X
;	beq	.skipwave
;
;	lda	psg_wavenum,X
;	and	#$80
;	sta	psg_wavenum,X
;
;.skipwave:
;	lda	psg_trkctrl	; is anything playing on main track ?
;	bpl	.nextvoice	; yes... so don't stop it
;
;	stx	psg_ch_value
;	stx	psg_ch
;	stz	psg_ctrl
;
;.nextvoice:
;	inx
;	cpx	#6
;	bcs	.out
;	tya
;	bmi	.pause2
;	
;	lsr	A
;	tay
;	bra	.loop
;
;.pause2:
;	lsr	A
;	ora	#$80
;	tay
;	bra	.loop
;
.out:	rts


; ----
; PSG_ASTOP
;
; Stop all voices
; ----

psg_astop:
;	smb7	<psg_inhibit
;
;	lda	#(PSG_MAINPAUSE | PSG_SUBPAUSE)
;	sta	psg_trkctrl
;
;	ldx	#5
;.loop:	
;	stz	psg_voicectrl,X		; disable main track
;	stz	psg_voicectrl+6,X	; disable sub track
;	stx	psg_ch
;	stz	psg_ctrl		; disable voice
;	dex
;	bpl	.loop
;
	rts

; ----
; PSG_MVOFF
;
; Main volume off for voices specified in bitmask (in _al)
; ----

psg_mvoff:
;	lda	<_al
;	clx
;
;.loop:	lsr	A
;	bcc	.skip
;
;	ldy	psg_voicectrl,X
;	beq	.skip
;
;	pha
;	lda	#$ff		; turn off sound on voice
;	sta	psg_voicectrl,X
;	pla
;
;	ldy	psg_voicectrl+6,X
;	cpy	#1
;	beq	.skip
;
;	stx	psg_ch_value	; turn off voice
;	stx	psg_ch
;	stz	psg_ctrl
;
;.skip:	inx
;	cpx	#6
;	bcc	.loop
;
	rts


; ----
; PSG_CONT
;
; "continue"
; ----
;
; parameter:
; 0 = main track
; 1 = sub track
; 2 = both
;
psg_cont:
;	lda	<_al
;	cmp	#1
;	beq	.sub
;
;	ldx	#5
;.loop:	
;	lda	psg_voicectrl,X
;	beq	.next			; skip if disabled
;
;	lda	#1			; restart voice
;	sta	psg_voicectrl,X
;
;.next:	dex
;	bpl	.loop
;
;	lda	#PSG_MAINPAUSE		; release pause on main tracks
;	trb	psg_trkctrl
;
;.sub:	lda	<_al
;	beq	.end
;
;	ldx	#5
;.loop1:	
;	lda	psg_voicectrl+6,X
;	beq	.next1			; skip if disabled
;
;	lda	#1			; restart voice
;	sta	psg_voicectrl+6,X
;
;	lda	psg_wavenum,X
;	and	#$80			; force re-download of waveform
;	sta	psg_wavenum,X
;
;.next1:	dex
;	bpl	.loop1
;
;	lda	#PSG_SUBPAUSE		; release pause on sub tracks
;	trb	psg_trkctrl
;
;.end:	
;	rmb7	<psg_inhibit		; remove pause on irq processing
	rts


; ----
; PSG_FDOUT
; ----

psg_fdout:
;	lda	<_al
;	bpl	.positive
;
;	eor	#$ff		; get absolute value from negative
;	inc	A
;
;.positive:
;	sta	psg_fadespeed	; store it as fade speed
;	stz	psg_fadecount	; reset fade levels
;	stz	psg_fadevolcut

	rts


; ----
; PSG_DCNT
;
;  set delay counter - sets an up-counter to use if interrupt
;  frequency is >60Hz, and this will act as a frequency divider
;  (by ignoring interrupts until up-counter value is hit)
;
;  Not used in this implementation of PSG driver
; ----

psg_dcnt:
    lda		_al
	inc		a
	sta		psgMainDelay
	rts

