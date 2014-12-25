;-----------------------------------------------------------------------------
; SUB-TRACK DATA BYTE CODE OPERATIONS

;-----------------------------------------------------------------------------
; bcSetTimeBase : $d0 - set time base. [0-15]
;.............................................................................
; set packed mode duration multiplier

bcSubSetTimeBase

	lda		[psgPtr1]					; get next byte from track data
	and		#$0F							; force into range
	sta		psgSubDurationMultiplier,y		; save it
	jmp		bcSubUpdateTrackPtr				; move track pointer to next byte
											; [ skip parameter ]
											
;-----------------------------------------------------------------------------
; bcSetOctave : $d1-$d7 - set octave. (0-7)
;.............................................................................
; set default octave for track. A has function code, with octave number in it.

bcSubSetOctave
	and		#$07							; force into range
	sta		psgSubOctave,y					; set default octave
	jmp		mmlSubFetchNext					; process next byte
	
;-----------------------------------------------------------------------------
; bcOctaveUp :  $d8 - octave up.
;.............................................................................
; raise default octave 1 step

bcSubOctaveUp

	ldx		psgCurrentVoice				; get voice to apply to
	inc		psgSubOctave,x				; raise octave
	jmp		mmlSubFetchNext				; process next byte

;-----------------------------------------------------------------------------
; bcOctaveDown : $d9 - octave down.
;.............................................................................
; lower default octave 1 step

bcSubOctaveDown

	ldx		psgCurrentVoice				; get voice to apply to
	dec		psgSubOctave,x				; lower octave
	jmp		mmlSubFetchNext				; process next byte
	
;-----------------------------------------------------------------------------
; bcTie : $da - tie note.
;.............................................................................
; mark note as tied. 
; Note that tie isn't processed when seen. we look for it after a note....
; so I'm not sure why this code exists....

bcSubTie

	lda		#3							; start new tie ?
	sta		psgSubTieState,y			; mark state
	jmp		mmlSubFetchNext				; process next byte

;-----------------------------------------------------------------------------
; bcSetVoiceVolume : $dc - set voice volume [0-31]
;.............................................................................
; set voice volume to given level. Also stops volume changes.
; [weird; it sets volume to (value - $1f)]

bcSubSetVoiceVolume
	lda		[psgPtr1]						; fetch parameter
	
	and		#$1F							; mask off low 5 bits
	sec	
	sbc		#$1F							; volume =  31 - given
	
	sta		psgSubVoiceVolume,y				; save channel volume
	cla										; stop any changes
	sta		psgSubVolumeChangeAmount,y		; changes = 0

	jmp		bcSubUpdateTrackPtr				; c834
	
;-----------------------------------------------------------------------------
; bcSetPanPot : $dd - set pan pot [ $LR ]
;.............................................................................
; set channel pan left/ pan right pots. stops any pan changes.

bcSubSetPanPots

	lda		[psgPtr1]					; get parameter
	sta		psgSubPanPot,y				; save as combined value
	
	cla
	sta		psgSubPanRightDelta,y		; stop any panning
	sta		psgSubPanLeftDelta,y		
	
	jmp		bcSubUpdateTrackPtr			; c834
	
;-----------------------------------------------------------------------------
; bcSetKeyOnOffRatio : $de - set key on/key off ratio [ 1-8 ]
;.............................................................................
; sets ratio to (8-value) (ie, periods off)

bcSubSetKeyOnOffRatio

	lda		[psgPtr1]
	dec		a					; must be at least 1 ?
	and		#$07				; mask off low bits, force into range

	sec
	sbc		#8					; subtract 8. Converts on periods to off periods
	eor		#$ff				; complement. Converts negative to positive
	sta		psgSubKeyOffPeriods,y		; save it
	
	jmp		bcSubUpdateTrackPtr	; c834
	
;-----------------------------------------------------------------------------
; bcSetRelVol : $df - relative volume  [-31 - +31]
;.............................................................................
; raise/lower track volume (ie, set relative to current)

bcSubSetRelVol

	lda		psgSubVoiceVolume,y				; get voice overall volume
	
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
	sta		psgSubVoiceVolume,y
	jmp		bcSubUpdateTrackPtr					; c834
	
;-----------------------------------------------------------------------------
; bcDalSegno : $e1 - Da Se Nyo (Dal Segno) 
;.............................................................................
; return to save point (Segno)

bcSubDalSegno

	lda		psgSubSegnoLo,y			; copy saved pointer to temp track location
	sta		<psgPtr1
	lda		psgSubSegnoHi,y
	sta		<psgPtr1+1
	
	jmp		mmlSubFetchNext				; continue processing from there (c3f8)

;-----------------------------------------------------------------------------
; bcSegNo : $e2 - Se Nyo (Segno)
;.............................................................................
; save here as return point

bcSubSegno

	lda		<psgPtr1	 		; save current track pointer as return point
	sta		psgSubSegnoLo,y
	lda     <psgPtr1+1
	sta		psgSubSegnoHi,y
	
	jmp		mmlSubFetchNext		; (c3f8)

;-----------------------------------------------------------------------------
; bcRepeatStart : $e3 - repeat begin [ 1-255 ]
;.............................................................................
; save here as repeat location, set count of repeats

bcSubRepeatStart

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
	
	jsr		bcSubGetStackInfo			; set up stack frame pointer
	
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
	lda		psgSubStackOffset,x	; get offset
	and		#$F0					; save high bits -> voice mode
	ora		<psgTemp1				; set offset (max of 16)
	sta		psgSubStackOffset,x	; update stack offset

	;....................................................................
	; restore voice number (?)
	
	sxy							; restore original voice index
	jmp		mmlSubFetchNext		; (c3f8)

;-----------------------------------------------------------------------------
; bcRepeatEnd : $e4 - repeat end
;.............................................................................
; return track pointer to stacked value

bcSubRepeatEnd

	sxy							; save voice number in Y
	jsr		bcSubGetStackInfo		; get stack frame
	
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

	sxy									; restore voice
	jmp			mmlSubFetchNext			; done : (c3f8)
	
	;....................................................................
	; repeat iterations done, pop values off stack

.unStack
	dey						; remove iterations
	dey						; remove high byte of address
	sty		<psgPtr2			; save offset
	
	lda		psgSubStackOffset,x	; get stack frame address
	and		#$F0					; get voice mode
	ora		<psgPtr2					; set new offset

	sta		psgSubStackOffset,x	; save it
	sxy								; restore voice
	jmp		mmlSubFetchNext			; done : (c3f8)
	
;-----------------------------------------------------------------------------
; bcSetWave : $e5 - set timbre/waveform [0-127]
;.............................................................................
; set voice wave to given value. Note that value has bit 7 cleared, so it
; will load when needed.

bcSubSetWave

	lda		[psgPtr1]
	sta		psgSubWaveNo,y
	jmp		bcSubUpdateTrackPtr

;-----------------------------------------------------------------------------
; bcSetEnvelope : $e6 - set (volume) envelope [0-127]
;.............................................................................
; set volume envelope to given number.

bcSubSetEnvelope

	sxy					; save voice
	lda		[psgPtr1]	; get new envelope number
	cmp		#$10
	bcs		.userEnv
	
	;....................................................................
	; convert envelope number to offset, save internal envelope address

	asl		a				; 2-byte offset
	tay						; into index register
	
	lda		psgSysEnv,y
	sta		<psgPtr2
	lda		psgSysEnv+1,y
	sta		<psgPtr2+1
	bra		.changeEnvelope

	;....................................................................
	; convert user envelope number to offset (for user location table)
	
.userEnv
	sec
	sbc		#$10			; remove internal envelopes
	asl		a				; convert to 2-byte offset

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

	stz		psgSubEnvReleaseLo,x		; clear envelope Release Rate (lo) ?
	stz		psgSubEnvReleaseHi,x		; clear envelope Release Rate (hi) ?

	lda		[psgPtr2]					; parse initial envelope setup. get first value
	cmp		#$FB						; is it release rate ?
	bne		.noRelease					; nope, skip to pointer save and reset

	;....................................................................
	; first byte of data is release rate info. get release rate and save it

	ldy		#1							; start past release rate code
	lda		[psgPtr2],y					; get release rate low byte
	sta		psgSubEnvReleaseLo,x		; save release rate low
	iny
	lda		[psgPtr2],y					; get release rate high
	sta		psgSubEnvReleaseHi,x		; save release rate high.
	
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
	sta		psgSubEnvelopePtrLo,x
	lda		<psgPtr2+1
	sta		psgSubEnvelopePtrHi,x
	
	;....................................................................
	; and clear any other envelope information

	stz		psgSubEnvDecayTime,x			; envelope decay time
	stz		psgSubEnvLevelHi,x				; envelope level, hi byte
	stz		psgSubEnvDurationLo,x			; envelope duration, lo byte
	stz		psgSubEnvDurationHi,x			; envelope duration, hi byte
	
	;....................................................................
	; restore voice and continue
	
	sxy									; restore voice number
	jmp		bcSubUpdateTrackPtr			; c834

;-----------------------------------------------------------------------------
; bcSetMod : $e7 - set modulation information [0-127]
;.............................................................................
; set modulation index to given value. locate modulation data for the index,
; and save pointer to it.
;-----------------------------------------------------------------------------

bcSubSetMod

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
	sta			psgSubModBasePtrLo,x		; save lo byte
	iny
	
	lda			[psgPtr2],Y
	sta			psgSubModBasePtrHi,x		; save hi byte
	
	;....................................................................
	; zero either modulation count or modulation index
	
	stz			psgSubModCount,x		; X is voice #
	sxy									; restore voice
	jmp			bcSubUpdateTrackPtr		; and return
	
;-----------------------------------------------------------------------------
; bcSetModDelay : $e8 - set modulation information [0-255]
;.............................................................................
; set modulation delay time to given value.
;-----------------------------------------------------------------------------

bcSubSetModDelay

	lda			[psgPtr1]			; get parameter
	sta			psgSubModDelay,Y	; save as modulation delay
	jmp			bcSubUpdateTrackPtr	; done
	
;-----------------------------------------------------------------------------
; bcSetModCorrection : $e9 - set modulation correction amount [0-7]
;.............................................................................
; set modulation corection to given value. Note that the correction moves the
; 'standard' octave for the voice up/down.
;-----------------------------------------------------------------------------

bcSubSetModCorrection

	lda			[psgPtr1]				; get parameter
	and			#$07					; force into range
	sta			psgSubModCorrection,Y	; save octave
	jmp			bcSubUpdateTrackPtr		; done
	
;-----------------------------------------------------------------------------
; bcSetPitchEnvelope : $ea - set Pitch envelope number [0-127]
;.............................................................................
; set pitch envelope to given value.
;-----------------------------------------------------------------------------

bcSubSetPitchEnvelope

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
	sta			psgSubPEPtrLo,x		; voice in X
	iny
	
	lda			[psgPtr2],y
	sta			psgSubPEPtrHi,x
	
	stz			psgSubPECount,x		; clear PE Delay Count ??
	sxy									; restore voice
	jmp			bcSubUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcSetPEDelay : $eb - set Pitch envelope delay [0-255]
;.............................................................................
; set pitch envelope delay to given value. Delay is equivalent to sound length
; (play time?)
;-----------------------------------------------------------------------------

bcSubSetPEDelay

	lda			[psgPtr1]				; fetch parameter
	sta			psgSubPEDelay,y			; save it
	jmp			bcSubUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcDetune : $ec - Detune : fine-tune sound interval [-128 - +127]
;.............................................................................
; set 'fine tune sound interval' amount.
;-----------------------------------------------------------------------------

bcSubDetune

	lda			[psgPtr1]				; fetch parameter
	sta			psgSubDetuneAmount,y	; save it
	jmp			bcSubUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcSweepAmount : $ed - set sweep change amount [-128 - +127 ]
;-----------------------------------------------------------------------------

bcSubSweep

	lda			[psgPtr1]				; fetch parameter
	sta			psgSubSweepDelta,y		; save it
	jmp			bcSubUpdateTrackPtr		; return
	
;-----------------------------------------------------------------------------
; bcSweepTime : $ee - set sweep time [0-255 ]
;-----------------------------------------------------------------------------

bcSubSweepTime	

	lda			[psgPtr1]				; get parameter
	sta			psgSubSweepTime,y		; save it
	jmp			bcSubUpdateTrackPtr		; return

;-----------------------------------------------------------------------------
; bcJump : $ef - jump to given address in track [address lo, address hi]
;-----------------------------------------------------------------------------

bcSubJump

	lda			[psgPtr1]				; get address lo
	tax									; save in X
	
	inc			<psgPtr1					; bump track pointer
	bne			.noHigh8
	inc			<psgPtr1+1
.noHigh8

	lda			[psgPtr1]				; get address hi
	sta			<psgPtr1+1				; save as track pointer hi
	stx			<psgPtr1					; save track pointer lo (in x)
	jmp			mmlSubFetchNext			; and go handle byte
	
;-----------------------------------------------------------------------------
; bcCall : $f0 - call subroutine [address lo, address hi]
;-----------------------------------------------------------------------------

bcSubCall

	sxy
	jsr				bcSubGetStackInfo

	lda				<psgPtr1			; get current address
	sta				[psgPtr2],Y		; stack it
	iny
	
	lda				<psgPtr1+1
	sta				[psgPtr2],Y		; stack it
	iny

	sty				<psgTemp1				; save in temp 
	lda				psgSubStackOffset,x		; get old channel mode
	and				#$F0					; save mode
	ora				<psgTemp1				; update offset
	sta				psgSubStackOffset,x		; save new offset

	lda				[psgPtr1]				; get target address
	tay
	inc				<psgPtr1
	bne				.skipHi14
	inc				<psgPtr1+1
.skipHi14

	lda				[psgPtr1]
	sta				<psgPtr1+1				; update high
	sty				<psgPtr1					; update lo

	sxy
	jmp				mmlSubFetchNext			; and keep going

;-----------------------------------------------------------------------------
; bcReturn : $f1 - return from subroutine.
;-----------------------------------------------------------------------------

bcSubReturn

	sxy
	jsr				bcSubGetStackInfo
	dey
	
	lda				[psgPtr2],y
	sta				<psgPtr1+1
	dey
	
	lda				[psgPtr2],y
	sta				<psgPtr1
	
	sty				<psgTemp1
	lda				psgSubStackOffset,x
	and				#$F0
	ora				<psgTemp1
	sta				psgSubStackOffset,x
	
	inc				<psgPtr1				; bump next byte pointer past address lo
	bne				.skipHi15
	inc				<psgPtr1+1
.skipHi15

	sxy
	jmp				bcSubUpdateTrackPtr		; and past address hi here

;-----------------------------------------------------------------------------
; bcTranspose : $f2 - transpose frequency.
;-----------------------------------------------------------------------------

bcSubTranspose

	lda			[psgPtr1]
	asl			a
	sta			psgSubTransposeAmount,y
	jmp			bcSubUpdateTrackPtr
	
;-----------------------------------------------------------------------------
; bcRelTranspose : $f3 - relative transpose frequency.
;-----------------------------------------------------------------------------

bcSubRelTranspose

	lda			[psgPtr1]
	asl			a
	sta			<psgTemp1
	
	lda			psgSubTransposeAmount,y
	clc
	adc			<psgTemp1
	sta			psgSubTransposeAmount,y

	bra			bcSubUpdateTrackPtr

;-----------------------------------------------------------------------------
; bcAllTranspose : $f4 - transpose ALL channel frequencies.
;-----------------------------------------------------------------------------

bcSubAllTranspose

	phy
	lda			[psgPtr1]
	asl			a
	tay
	
	ldx			#5
.voxLoop
	lda			psgSubVoiceStatus,x
	beq			.voxOff

	tya
	sta			psgSubTransposeAmount,x
	
.voxOff
	dex
	bpl			.voxLoop
	ply
	bra			bcSubUpdateTrackPtr
	
;-----------------------------------------------------------------------------
; bcVolChange : $f5 - gradually change (voice ?) volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcSubVolChange

	lda			[psgPtr1]						; get parameter
	sta			psgSubVolumeChangeAmount,y		; save it
	cla
	sta			psgSubVolumeChangeAccum,y		; clear fraction accumulator
	bra			bcSubUpdateTrackPtr				; return
	
;-----------------------------------------------------------------------------
; bcPanRChange : $f6 - gradually change right channel volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcSubPanRChange

	lda			[psgPtr1]					; fetch parameter
	sta			psgSubPanRightDelta,y		; save it
	
	cla
	sta			psgSubPanRightAccum,y		; clear fraction accumulator
	bra			bcSubUpdateTrackPtr			; return

;-----------------------------------------------------------------------------
; bcPanLChange : $f7 - gradually change left channel volume [-128 - +127 ]
;-----------------------------------------------------------------------------

bcSubPanLChange

	lda			[psgPtr1]					; fetch parameter
	sta			psgSubPanLeftDelta,y		; save it
	
	cla
	sta			psgSubPanLeftAccum,y		; clear fraction
	bra			bcSubUpdateTrackPtr			; return

;-----------------------------------------------------------------------------
; bcChangeMode : $f8 - change track mode. [ 0-2 ]
;-----------------------------------------------------------------------------

bcSubChangeMode

	lda		[psgPtr1]
	asl		a
	asl		a
	asl		a
	asl		a					; mode into top nibble
	sta		<psgTemp1

	lda		psgSubStackOffset,y
	and		#$0F
	ora		<psgTemp1
	sta		psgSubStackOffset,y

	lda		[psgPtr1]				; exit if not drum mode
	cmp		#1
	bne		bcSubUpdateTrackPtr
	
	cla
	sta		psgSubEnvReleaseLo,y	; clear release envelope
	sta		psgSubEnvReleaseHi,y
	bra		bcSubUpdateTrackPtr

;-----------------------------------------------------------------------------
; bcFadeOut : $fe - gradually fade track out. [1-127 ]
;-----------------------------------------------------------------------------

bcSubFadeOut

		lda			[psgPtr1]				; fetch parameter
		bit			#$7f					; if 0
		beq			bcSubUpdateTrackPtr		; ... skip it (?)
		
		cmp			#0						; if positive....
		bpl			.setFade				; .. go ahead and process it
		
		eor			#$ff					; if negative, complement it
		inc			a
		
.setFade
		sta			psgSubFadeOutSpeed		; set fade speed
		stz			psgSubFadeOutCount		; set fade accumulation to 0
		stz			psgSubFadeOutCount+1
		bra			bcSubUpdateTrackPtr		; and return
		
;-----------------------------------------------------------------------------
; bcTrackDone : $ff - end-of-data
;.............................................................................
; mark track as done
;-----------------------------------------------------------------------------

bcSubTrackDone

	lda		#2						; voice state == done (?)
	sta		psgSubVoiceStatus,y	; mark voice as done
	rts								; we're done with this voice. really.

;-----------------------------------------------------------------------------
; increment track data pointer, and jump to processing next byte
; Used by operations that have a parameter to skip past the parameter
;.............................................................................

bcSubUpdateTrackPtr				; c834
	inc		<psgPtr1				; bump pointer lo
	bne		.noHi6				; if rolled,...
	inc		<psgPtr1+1			; bump pointer hi
.noHi6

    jmp		mmlSubFetchNext		; c3f8 - back to top of mml loop (aka, non-parameter jump)
	
;-----------------------------------------------------------------------------
; get stack frame & offset
;.............................................................................

bcSubGetStackInfo

	lda				sStackLo,x
	sta				<psgPtr2
	lda				sStackHi,x
	sta				<psgPtr2+1
	lda				psgSubStackOffset,x
	and				#$0f
	tay
	rts
	
;.............................................................................
; data - stack frame address (LOW) per voice
;.............................................................................

sStackLo
	.db			LOW( sStack0)
	.db			LOW( sStack1)
	.db			LOW( sStack2)
	.db			LOW( sStack3)
	.db			LOW( sStack4)
	.db			LOW( sStack5)
	
;.............................................................................
; data - stack frame address (HIGH) per voice
;.............................................................................

sStackHi
	.db			HIGH( sStack0)
	.db			HIGH( sStack1)
	.db			HIGH( sStack2)
	.db			HIGH( sStack3)
	.db			HIGH( sStack4)
	.db			HIGH( sStack5)
