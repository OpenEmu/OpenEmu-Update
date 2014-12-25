;
; TRACK DATA BYTE CODE OPERATIONS
;

;-----------------------------------------------------------------------------
; bcSetTimeBase : $d0 - set time base. [0-15]
;.............................................................................
; set packed mode duration multiplier

bcSetTimeBase

	lda		[psgPtr1]						; get next byte from track data
	and		#$0F							; force into range
	sta		psgMainDurationMultiplier,y		; save it
	jmp		bcUpdateTrackPtr				; move track pointer to next byte
											; [ skip parameter ]
											
;-----------------------------------------------------------------------------
; bcSetOctave : $d1-$d7 - set octave. (0-7)
;.............................................................................
; set default octave for track. A has function code, with octave number in it.

bcSetOctave
	and		#$07							; force into range
	sta		psgMainOctave,y					; set default octave
	jmp		mmlFetchNext					; process next byte
	
;-----------------------------------------------------------------------------
; bcOctaveUp :  $d8 - octave up.
;.............................................................................
; raise default octave 1 step

bcOctaveUp

	ldx		psgCurrentVoice				; get voice to apply to
	inc		psgMainOctave,x				; raise octave
	jmp		mmlFetchNext				; process next byte

;-----------------------------------------------------------------------------
; bcOctaveDown : $d9 - octave down.
;.............................................................................
; lower default octave 1 step

bcOctaveDown

	ldx		psgCurrentVoice				; get voice to apply to
	dec		psgMainOctave,x				; lower octave
	jmp		mmlFetchNext				; process next byte
	
;-----------------------------------------------------------------------------
; bcTie : $da - tie note.
;.............................................................................
; mark note as tied. 
; Note that tie isn't processed when seen. we look for it after a note....
; so I'm not sure why this code exists....

bcTie

	lda		#3							; start new tie ?
	sta		psgMainTieState,y			; mark state
	jmp		mmlFetchNext				; process next byte

;-----------------------------------------------------------------------------
; bcSetTempo : $db - set tempo [35-255]
;.............................................................................
; change MAIN track tempo. Tempo has NO per-voice value

bcSetTempo

	lda		[psgPtr1]				; get tempo value
	cmp		#35						; force to min of 35
	bcs		.tempo1
	lda		#35
.tempo1

	tax								; use as offset
	lda		psgTempoTable-35,x		; get timer value from table
	sta		psgTimerCount			; save as new timer value
	
	jmp		bcUpdateTrackPtr		; c834

;-----------------------------------------------------------------------------
; bcSetVoiceVolume : $dc - set voice volume [0-31]
;.............................................................................
; set voice volume to given level. Also stops volume changes.
; [weird; it sets volume to (value - $1f)]

bcSetVoiceVolume
	lda		[psgPtr1]						; fetch parameter
	
	and		#$1F							; mask off low 5 bits
	sec	
	sbc		#$1F							; volume =  31 - given
	
	sta		psgMainVoiceVolume,y			; save channel volume
	cla										; stop any changes
	sta		psgMainVolumeChangeAmount,y		; changes = 0

	jmp		bcUpdateTrackPtr				; c834
	
;-----------------------------------------------------------------------------
; bcSetPanPot : $dd - set pan pot [ $LR ]
;.............................................................................
; set channel pan left/ pan right pots. stops any pan changes.

bcSetPanPots

	lda		[psgPtr1]					; get parameter
	sta		psgMainPanPot,y				; save as combined value
	
	cla
	sta		psgMainPanRightDelta,y		; stop any panning
	sta		psgMainPanLeftDelta,y		
	
	jmp		bcUpdateTrackPtr			; c834
	
;-----------------------------------------------------------------------------
; bcSetKeyOnOffRatio : $de - set key on/key off ratio [ 1-8 ]
;.............................................................................
; sets ratio to (8-value) (ie, periods off)

bcSetKeyOnOffRatio

	lda		[psgPtr1]
	dec		a					; must be at least 1 ?
	and		#$07				; mask off low bits, force into range

	sec
	sbc		#8							; subtract 8. Converts on periods to off periods
	eor		#$ff						; complement. Converts negative to positive
	sta		psgMainKeyOffPeriods,y		; save it
	
	jmp		bcUpdateTrackPtr	; c834
	
;-----------------------------------------------------------------------------
; bcSetRelVol : $df - relative volume  [-31 - +31]
;.............................................................................
; raise/lower track volume (ie, set relative to current)

bcSetRelVol

	lda		psgMainVoiceVolume,y				; get voice overall volume
	
	clc
	adc		[psgPtr1]							; add parameter to it
	bmi		.wentLow							; go fix if it went negative

	;.........................................................................
	; value is positive (too large). force into range.
	
	cla											; it's positive. make it 0
												; (remember, we store 31-value, which makes this 31)
	bra		.isOkay								; and it should be good now

	;.........................................................................
	; value went negative. force into range
	
.wentLow
	cmp		#$E1								; twos complement -31
	bcs		.isOkay								; not out of range, save it

    lda		#$e1								; make it -31.
												; (remember, we store 31-value, which makes this 0).
												
	;.........................................................................
	; save new value, as 31-volume
	
.isOkay
	sta		psgMainVoiceVolume,y
	jmp		bcUpdateTrackPtr					; c834
	
;-----------------------------------------------------------------------------
; bcDalSegno : $e1 - Da Se Nyo (Dal Segno) 
;.............................................................................
; return to save point (Segno)

bcDalSegno

	lda		psgMainSegnoLo,y			; copy saved pointer to temp track location
	sta		<psgPtr1
	lda		psgMainSegnoHi,y
	sta		<psgPtr1+1
	
	jmp		mmlFetchNext				; continue processing from there (c3f8)

;-----------------------------------------------------------------------------
; bcSegNo : $e2 - Se Nyo (Segno)
;.............................................................................
; save here as return point

bcSegno

	lda		<psgPtr1	 		; save current track pointer as return point
	sta		psgMainSegnoLo,y
	lda     <psgPtr1+1
	sta		psgMainSegnoHi,y
	
	jmp		mmlFetchNext		; (c3f8)

;-----------------------------------------------------------------------------
; bcRepeatStart : $e3 - repeat begin [ 1-255 ]
;.............................................................................
; save here as repeat location, set count of repeats

bcRepeatStart

	sxy						; save channel #
	lda		[psgPtr1]		; get count
	bne		.isOkay			; if not 0, don't fix it

    lda		#2				; repeat of 0 fixed to 2

.isOkay

	;....................................................................
	; save count, skip voice pointer past it.

	pha							; save count. it gets stacked last
	inc		<psgPtr1			; skip pointer past count
	bne		.noHigh4
	inc		<psgPtr1+1
.noHigh4

	;....................................................................
	; get stack frame information.
	
	jsr		getMainStackFrame
	
	;....................................................................
	; copy voice data location to stack
	
	lda		<psgPtr1				; get data location low byte
	sta		[psgPtr2],y			; save on voices stack
	iny
	
	lda		<psgPtr1+1			; get data locatin high byte
	sta		[psgPtr2],y			; save on stack
	iny
	
	;....................................................................
	; restore count, put it on stack
	
	pla							; restore count
	sta		[psgPtr2],y			; save it
	iny
	
	;....................................................................
	; update stack offset
	
	sty		<psgTemp1				; save offset (overwrites ptr2)
	lda		psgMainStackOffset,x	; get offset
	and		#$F0					; save high bits -> voice mode
	ora		<psgTemp1				; set offset (max of 16)
	sta		psgMainStackOffset,x	; update stack offset

	;....................................................................
	; restore voice number (?)
	
	sxy							; restore original voice index
	jmp		mmlFetchNext		; (c3f8)

;-----------------------------------------------------------------------------
; bcRepeatEnd : $e4 - repeat end
;.............................................................................
; return track pointer to stacked value

bcRepeatEnd

	sxy									; save voice number in Y
	jsr			getMainStackFrame		; get stack frame
	
	;....................................................................
	; get iteration from stack, count it down
	
	dey								; iteration below top of stack
	lda			[psgPtr2],y			; fetch value from stack

	dec			a					; iteration done
	beq			.unStack			; if all done, pop stack
	
	;....................................................................
	; update iterations remaining

	sta			[psgPtr2],y			; save remaining iterations
	
	dey								; back up in stack for address bytes
	lda			[psgPtr2],y			; get high byte of address
	sta			<psgPtr1+1			; restore it
	
	dey
	lda			[psgPtr2],y			; get low byte of address
	sta			<psgPtr1

	sxy								; restore voice
	jmp			mmlFetchNext		; done : (c3f8)
	
	;....................................................................
	; repeat iterations done, pop values off stack

.unStack
	dey						; remove iterations
	dey						; remove high byte of address
	sty		<psgPtr2			; save offset
	
	lda		psgMainStackOffset,x	; get stack frame address
	and		#$F0					; get voice mode
	ora		<psgPtr2					; set new offset

	sta		psgMainStackOffset,x	; save it
	sxy								; restore voice
	jmp		mmlFetchNext			; done : (c3f8)
	
;-----------------------------------------------------------------------------
; bcSetWave : $e5 - set timbre/waveform [0-127]
;.............................................................................
; set voice wave to given value. Note that value has bit 7 cleared, so it
; will load when needed.

bcSetWave

	lda		[psgPtr1]
	sta		psgMainWaveNo,y
	jmp		bcUpdateTrackPtr	; c834

;-----------------------------------------------------------------------------
; bcSetEnvelope : $e6 - set (volume) envelope [0-127]
;.............................................................................
; set volume envelope to given number.

bcSetEnvelope

	sxy					; save voice
	lda		[psgPtr1]	; get new envelope number
	cmp		#psgSysEnvCnt
	bcs		.userEnv
	
	;....................................................................
	; convert envelope number to offset, save internal envelope address

	asl		a				; 2-byte offset
	tay						; into index register
	
	lda		psgSysEnv,Y		; get pointer to internal envelope data
	sta		<psgPtr2
	lda		psgSysEnv+1,Y
	sta		<psgPtr2+1
	bra		.changeEnvelope

	;....................................................................
	; convert user envelope number to offset (for user location table)
	
.userEnv
	sec
	sbc		#psgSysEnvCnt		; remove internal envelopes
	asl		a					; convert to 2-byte offset

	clc
	adc		psgUserVolEnvelope		; add to volume envelope base address
	sta		<psgPtr2					; save low
	cla								; high byte is 0
	adc		psgUserVolEnvelope+1	; add to volume envelope base address
	sta		<psgPtr2+1				; save high
	
	;....................................................................
	; get user envelope data pointer
	
	lda		[psgPtr2]				; get low byte of envelope data address
	tay								; save it
	inc		<psgPtr2					; bump pointer
	bne		.noHigh5
	inc		<psgPtr2+1
.noHigh5

	lda		[psgPtr2]				; get high byte of envelope data address
	sta		<psgPtr2+1				; save high byte
	sty		<psgPtr2					; and low byte

	;....................................................................
	; psg_Ptr2 now should hold address of envelope data.
	
.changeEnvelope

	stz		psgMainEnvReleaseLo,x		; clear envelope Release Rate (lo) ?
	stz		psgMainEnvReleaseHi,x		; clear envelope Release Rate (hi) ?

	lda		[psgPtr2]					; parse initial envelope setup. get first value
	cmp		#$FB						; is it release rate ?
	bne		.noRelease					; nope, skip to pointer save and reset

	;....................................................................
	; first byte of data is release rate info. get release rate and save it

	ldy		#1							; start past release rate code
	lda		[psgPtr2],y					; get release rate low byte
	sta		psgMainEnvReleaseLo,x		; save release rate low
    iny
    lda		[psgPtr2],y					; get release rate high
	sta		psgMainEnvReleaseHi,x		; save release rate high.
	
	;....................................................................
	; skip data pointer past initial release rate

	lda		#3						    ; we skip 3 bytes (code+rate)
	clc
	adc		<psgPtr2						; update low byte of pointer
	sta		<psgPtr2
	cla									; high byte is 0
	adc		<psgPtr2+1
	sta		<psgPtr2+1					; update high byte
	
	;....................................................................
	; first byte of data wasn't release, or we already handled the release
	; in either case, save the envelope data pointer
	
.noRelease

	lda		<psgPtr2						; save voice envelope pointer
	sta		psgMainEnvelopePtrLo,x
	lda		<psgPtr2+1
	sta		psgMainEnvelopePtrHi,x
	
	;....................................................................
	; and clear any other envelope information

	stz		psgMainEnvDecayTime,x			; envelope decay time
	stz		psgMainEnvLevelHi,x				; envelope level, hi byte
	stz		psgMainEnvDurationLo,x			; envelope duration, lo byte
	stz		psgMainEnvDurationHi,x			; envelope duration, hi byte
	
	;....................................................................
	; restore voice and continue
	
	sxy									; restore voice number
	jmp		bcUpdateTrackPtr			; c834

;-----------------------------------------------------------------------------
; bcSetMod : $e7 - set modulation information [0-127]
;.............................................................................
; set modulation index to given value. locate modulation data for the index,
; and save pointer to it.
;-----------------------------------------------------------------------------

bcSetMod

	sxy							; save voice in X
	lda			[psgPtr1]		; get parameter
    asl			a				; convert to word offset
	tay							; offset into Y
	
	;....................................................................
	; set alternate pointer to user modulation envelope pointer table
	
	lda			psgUserModEnvelope		; lo of mod envelope pointer
	sta			<psgPtr2					; into alternate pointer
	lda			psgUserModEnvelope+1	; hi of mod envelope
	sta			<psgPtr2+1				; into alternate pointer

	;....................................................................
	; get y'th envelope location; ie, modulation[y].

	lda			[psgPtr2],y				; yth entry in table at psgPtr2
	sta			psgMainModBasePtrLo,x	; save lo byte
	iny
	
	lda			[psgPtr2],Y
	sta			psgMainModBasePtrHi,x	; save hi byte
	
	;....................................................................
	; zero either modulation count or modulation index
	
	stz			psgMainModCount,x		; X is voice #
	sxy									; restore voice
	jmp			bcUpdateTrackPtr		; and return
	
;-----------------------------------------------------------------------------
; bcSetModDelay : $e8 - set modulation information [0-255]
;.............................................................................
; set modulation delay time to given value.
;-----------------------------------------------------------------------------

bcSetModDelay

	lda			[psgPtr1]			; get parameter
	sta			psgMainModDelay,Y	; save as modulation delay
	jmp			bcUpdateTrackPtr	; done
	
;-----------------------------------------------------------------------------
; bcSetModCorrection : $e9 - set modulation correction amount [0-7]
;.............................................................................
; set modulation corection to given value. Note that the correction moves the
; 'standard' octave for the voice up/down.
;-----------------------------------------------------------------------------

bcSetModCorrection

	lda			[psgPtr1]				; get parameter
	and			#$07					; force into range
	sta			psgMainModCorrection,Y	; save octave
	jmp			bcUpdateTrackPtr		; done
	
;-----------------------------------------------------------------------------
; bcSetPitchEnvelope : $ea - set Pitch envelope number [0-127]
;.............................................................................
; set pitch envelope to given value.
;-----------------------------------------------------------------------------

bcSetPitchEnvelope

	sxy									; save voice in X
	lda			[psgPtr1]				; get parameter
	asl			a						; convert to word offset
	tay									; save as index
	
	;....................................................................
	; save Y'th pointer in PE table.
	
	lda			psgUserPitchEnvelope
	sta			<psgPtr2					; save in alternate pointer, lo byte
	lda			psgUserPitchEnvelope+1
	sta			<psgPtr2+1				; save in alternate pointer, hi byte
	
	;....................................................................
	; get address of pitch envelope data and save it
	
	lda			[psgPtr2],y				; offset in Y
	sta			psgMainPEPtrLo,x		; voice in X
	iny
	
	lda			[psgPtr2],y
	sta			psgMainPEPtrHi,x
	
	stz			psgMainPECount,x		; clear PE Delay Count ??
	sxy									; restore voice
	jmp			bcUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcSetPEDelay : $eb - set Pitch envelope delay [0-255]
;.............................................................................
; set pitch envelope delay to given value. Delay is equivalent to sound length
; (play time?)
;-----------------------------------------------------------------------------

bcSetPEDelay

	lda			[psgPtr1]				; fetch parameter
	sta			psgMainPEDelay,y		; save it
	jmp			bcUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcDetune : $ec - Detune : fine-tune sound interval [-128 - +127]
;.............................................................................
; set 'fine tune sound interval' amount.
;-----------------------------------------------------------------------------

bcDetune

	lda			[psgPtr1]				; fetch parameter
	sta			psgMainDetuneAmount,y	; save it
	jmp			bcUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcSweepAmount : $ed - set sweep change amount [-128 - +127 ]
;-----------------------------------------------------------------------------

bcSweepAmount

	lda			[psgPtr1]				; fetch parameter
	sta			psgMainSweepDelta,y		; save it
	jmp			bcUpdateTrackPtr		; return
	
;-----------------------------------------------------------------------------
; bcSweepTime : $ee - set sweep time [0-255 ]
;-----------------------------------------------------------------------------

bcSweepTime	
	lda			[psgPtr1]				; get parameter
	sta			psgMainSweepTime,y		; save it
	jmp			bcUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcJump : $ef - jump to given address in track [address lo, address hi]
;-----------------------------------------------------------------------------

bcJump

	lda			[psgPtr1]				; get address lo
	tax									; save in X
	
	inc			<psgPtr1					; bump track pointer
	bne			.noHigh8
	inc			<psgPtr1+1
.noHigh8

	lda			[psgPtr1]				; get address hi
	sta			<psgPtr1+1				; save as track pointer hi
	stx			<psgPtr1					; save track pointer lo (in x)
	jmp			mmlFetchNext			; and go handle byte
	
;-----------------------------------------------------------------------------
; bcCall : $f0 - call routine at given address [addr lo, addr hi]
;-----------------------------------------------------------------------------

bcCall

	sxy									; save voice
	jsr			getMainStackFrame		; locate stack

	lda			<psgPtr1					; return address lo
	sta			[psgPtr2],y				; stack it
	iny

	lda			<psgPtr1+1				; return address hi
	sta			[psgPtr2],y
	iny

	sty			<psgTemp1				; save offset
	lda			psgMainStackOffset,x	; original offset
	and			#$F0					; save mode
	ora			<psgTemp1				; new offset
	sta			psgMainStackOffset,x	; save updated offset

	lda			[psgPtr1]				; fetch parameter
	tay									; stash it
	inc			<psgPtr1					; bump pointer
	bne			.skipHi12
	inc			<psgPtr1+1
.skipHi12
	
	lda			[psgPtr1]				; get new address hi
	sta			<psgPtr1+1				; save it as current location
	sty			<psgPtr1

	sxy									; restore original voice
	jmp			mmlFetchNext			; and continue at new address
	
;-----------------------------------------------------------------------------
; bcReturn : $f1 - return from called routine
;-----------------------------------------------------------------------------

bcReturn

	sxy									; save current voice
	jsr			getMainStackFrame		; locate stack
	
	dey									; pop top value
	lda			[psgPtr2],y				; get hi of return address
	sta			<psgPtr1+1
	
	dey
	lda			[psgPtr2],y				; get lo of return address
	sta			<psgPtr1
	sty			<psgTemp1				; save new offset

	lda			psgMainStackOffset,x	; get old offset
	and			#$f0					; save mode
	ora			<psgTemp1				; set new offset
	sta			psgMainStackOffset,x	; save new offset

	inc			<psgPtr1					; bump return address past address part of save command
	bne			.skipHi13				; (one byte here, one byte at return)
	inc			<psgPtr1+1
.skipHi13

	sxy									; restore original voice
	jmp			bcUpdateTrackPtr

;-----------------------------------------------------------------------------
; bcTranspose : $f2 - raise notes by given amount.   [ -128 - +127 ]
;-----------------------------------------------------------------------------

bcTranspose

		lda			[psgPtr1]					; fetch parameter
		asl			a							; convert to offset
		sta			psgMainTransposeAmount,y	; save
		jmp			bcUpdateTrackPtr			; skip parameter

;-----------------------------------------------------------------------------
; bcRelTranspose : $f3 - raise/lower notes (more) by given amount, relative to
;                        current amount.  [ -128 - +127 ]
;-----------------------------------------------------------------------------

bcRelTranspose

		lda			[psgPtr1]					; fetch parameter
		asl			a							; convert to offset
		sta			<psgTemp1					; save

		lda			psgMainTransposeAmount,y	; base amount
		clc
		adc			<psgTemp1					; add new amount
		sta			psgMainTransposeAmount,y	; save
		bra			bcUpdateTrackPtr			; skip parameter and return
		
;-----------------------------------------------------------------------------
; bcAllTranspose : $f4 - raise/lower all tracks by given amount.[ -128 - +127 ]
;-----------------------------------------------------------------------------

bcAllTranspose

		phy										; save voice
		lda			[psgPtr1]					; get parameter
		asl			a							; convert to offset
		tay										; save offset
		
		ldx			#5
.voxLoop
		lda			psgMainVoiceStatus,x		; is voice active ?
		beq			.nextVoice					; nope, skip it
		
		tya										; restore amount
		sta			psgMainTransposeAmount,x	; save it
		
.nextVoice
		dex										; next voice
		bpl			.voxLoop					; loop if more
		
		ply										; restore original voice
		bra			bcUpdateTrackPtr
		
;-----------------------------------------------------------------------------
; bcVolChange : $f5 - gradually change (voice ?) volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcVolChange

	lda			[psgPtr1]						; get parameter
	sta			psgMainVolumeChangeAmount,y		; save it
	cla
	sta			psgMainVolumeChangeAccum,y		; clear fraction accumulator
	bra			bcUpdateTrackPtr				; return
	
;-----------------------------------------------------------------------------
; bcPanRChange : $f6 - gradually change right channel volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcPanRChange

	lda			[psgPtr1]					; fetch parameter
	sta			psgMainPanRightDelta,y		; save it
	
	cla
	sta			psgMainPanRightAccum,y		; clear fraction accumulator
	bra			bcUpdateTrackPtr			; return

;-----------------------------------------------------------------------------
; bcPanLChange : $f7 - gradually change left channel volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcPanLChange

	lda			[psgPtr1]					; fetch parameter
	sta			psgMainPanLeftDelta,y		; save it
	
	cla
	sta			psgMainPanLeftAccum,y		; clear fraction
	bra			bcUpdateTrackPtr			; return

;-----------------------------------------------------------------------------
; bcChangeMode : $f8 - change track mode, if we can [ 0-2 ]
;-----------------------------------------------------------------------------

bcChangeMode

	lda			[psgPtr1]				; get parameter (mode)
	asl			a						; into upper nibble
	asl			a
	asl			a
	asl			a
	sta			<psgTemp1				; save

	lda			psgMainStackOffset,y	; get stack offset
	and			#$0F					; clear mode nibble
	ora			<psgTemp1				; save new mode
	sta			psgMainStackOffset,y

	lda			[psgPtr1]				; check mode
	cmp			#1						; percussion ?
	bne			bcUpdateTrackPtr		; nope, keep going
	
	cla
	sta			psgMainEnvReleaseLo,y	; clear release value
	sta			psgMainEnvReleaseHi,y
	
	bra			bcUpdateTrackPtr
	
;-----------------------------------------------------------------------------
; bcFadeOut : $fe - gradually fade track out. [1-127 ]
;-----------------------------------------------------------------------------

bcFadeOut

		lda			[psgPtr1]				; fetch parameter
		bit			#$7f					; if 0
		beq			bcUpdateTrackPtr		; ... skip it (?)
		
		cmp			#0						; if positive....
		bpl			.setFade				; .. go ahead and process it
		
		eor			#$ff					; if negative, complement it
		inc			a
		
.setFade
		sta			psgMainFadeOutSpeed		; set fade speed
		stz			psgMainFadeOutCount		; set fade accumulation to 0
		stz			psgMainFadeOutCount+1
		bra			bcUpdateTrackPtr		; and return
		
;-----------------------------------------------------------------------------
; bcTrackDone : $ff - end-of-data
;.............................................................................
; mark track as done
;-----------------------------------------------------------------------------

bcTrackDone

	lda		#2						; voice state == done (?)
	sta		psgMainVoiceStatus,y	; mark voice as done
	rts								; we're done with this voice. really.

;-----------------------------------------------------------------------------
; increment track data pointer, and jump to processing next byte
; Used by operations that have a parameter to skip past the parameter
;.............................................................................

bcUpdateTrackPtr				; c834
	inc		<psgPtr1				; bump pointer lo
	bne		.noHi6				; if rolled,...
	inc		<psgPtr1+1			; bump pointer hi
.noHi6

    jmp		mmlFetchNext		; c3f8 - back to top of mml loop (aka, non-parameter jump)
	
;-----------------------------------------------------------------------------
; getMainStackFrame - put voice stack address in psgPtr2, offset in y
;.............................................................................

getMainStackFrame
	lda			mStackLo,x						; get address low
	sta			<psgPtr2
	lda			mStackHi,x						; get address hi
	sta			<psgPtr2+1
	lda			psgMainStackOffset,x		; get offset
	and			#$0f
	tay
	rts
	
;.............................................................................
; data - stack frame address (LOW) per voice
;.............................................................................

mStackLo
	.db			LOW( mStack0)
	.db			LOW( mStack1)
	.db			LOW( mStack2)
	.db			LOW( mStack3)
	.db			LOW( mStack4)
	.db			LOW( mStack5)
	
;.............................................................................
; data - stack frame address (HIGH) per voice
;.............................................................................

mStackHi
	.db			HIGH( mStack0)
	.db			HIGH( mStack1)
	.db			HIGH( mStack2)
	.db			HIGH( mStack3)
	.db			HIGH( mStack4)
	.db			HIGH( mStack5)
