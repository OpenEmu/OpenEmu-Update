;--------------------------------------------------------------------------
; main.inc - mml player include file.                                     
;---------------------------------------------------------------------------------------
; This block defines data used by (original) psg MML player routine.
; It's used by both the main and the sub-tracks, so both need access to it.
;*****************************************************************************
; "global" Main data (common to all voices in main track)
; ----------------------------------------------------------------------------

		.org			$22ee
psgMainTrackPtrLo		.ds		6	; 22ee-22f3  =  Voice data pointer, low
psgMainTrackPtrHi		.ds		6	; 22f4-22f9  =  Voice data pointer, high

psgMainOctave			.ds		6	; 22fa-22ff  =  default octave for voice
psgMainFrequencyLo		.ds		6	; 2300-2305  -> frequency for tone, lo
psgMainFrequencyHi		.ds		6	; 2306-230b  -> frequency for tone, hi
psgMainNoteDuration		.ds		6	; 230c-2311  -> channel note duration
psgMainVoiceVolume		.ds		6	; 2312-2317  =  per voice volume
									; 				note: the value here is 31 - volume
psgMainKeyOffPeriods	.ds		6	; 2318-231d  => voice KeyOff duration !!
									;               this is # periods note is OFF
psgMainKeyOnDuration	.ds		6	; 231e-2323 ->  referenced in tone handler. value here is
                                    ;         total duration - (keyOn Duration * 1/8 total), I think
									
psgMainSegnoLo				.ds		6	; 2324-2329  = repeat point (SegNo) pointer, lo
psgMainSegnoHi				.ds		6	; 232a-232f  = repeat point (Segno) pointer, hi
psgMainTransposeAmount		.ds		6	; 2330-2335 -> voice transpose amount
psgMainDurationMultiplier	.ds		6	; 2336-233b = Duration multiplier (aka TimeBase)

;..............................................................................................
; (adsr) Envelope information

psgMainEnvelopePtrLo		.ds		6	; 233c-2341 = Envelope data pointer, lo
psgMainEnvelopePtrHi		.ds		6	; 2342-2347 = Envelope data pointer, hi
psgMainEnvelopeIndex		.ds		6	; 2348-234d = Envelope (offset) index

psgMainEnvLevelLo			.ds		6	; 234e-2353 -> envelope level, lo byte
psgMainEnvLevelHi			.ds		6	; 2354-2359 -> envelope level, hi byte
psgMainEnvDurationLo		.ds		6	; 235a-235f -> envelope duration, lo
psgMainEnvDurationHi		.ds		6	; 2360-2365 -> envelope duration, hi
psgMainEnvReleaseLo			.ds		6	; 2366-236b -> envelope release rate lo
psgMainEnvReleaseHi			.ds		6	; 236c-2371 -> envelope release rate hi
psgMainEnvDecayTime			.ds		6	; 2372-2377 -> envelope decay time

;..............................................................................................
; (frequency modulation) Envelope information

psgMainModBasePtrLo			.ds		6	; 2378-237d -> location of modulation data, lo byte
psgMainModBasePtrHi			.ds		6	; 237e-2383 -> location of modulation data, hi byte
psgMainModCount				.ds		6	; 2384-2389 -> possibly count for modulation
psgMainModDelay				.ds		6	; 238a-238f =  Modulation Delay amount
psgMainModDelayCount		.ds		6	; 2390-2395 -> modulation delay counter (?)
psgMainModCorrection		.ds		6	; 2396-239b =  Modulation Correction octave

;..............................................................................................
; (pitch) Envelope information

psgMainPEPtrLo				.ds		6	; 239c-23a1 -> Pitch Envelope Data Pointer, lo byte
psgMainPEPtrHi				.ds		6	; 23a2-23a7 -> Pitch Envelope Data Pointer, hi byte
psgMainPECount				.ds		6	; 23a8-23ad -> possibly PE Delay count
psgMainPEDelay				.ds		6	; 23ae-23b3 =  Pitch Envelope Delay Amount
psgMainPEDelayCount			.ds		6	; 23b4-23b9 -> Pitch Envelope Delay counter ?

;..............................................................................................

psgMainDetuneAmount			.ds	6	; 23ba-23bf -> channel detune amount
psgMainVolumeChangeAmount	.ds	6	; 23c0-23c5  = channel volume deltas
									; 			   for volume +/-
psgMainVolumeChangeAccum	.ds	6	; 23c6-23cb -> low byte of work volume?

;..............................................................................................
; pan operations information

psgMainPanRightDelta	.ds		6	; 23cc-23d1  = Pan Right change amount
psgMainPanRightAccum 	.ds		6	; 23d2-23d7  = Pan Right fration accumulator
psgMainPanLeftDelta		.ds		6	; 23d8-23dd  = Pan Left  change amount
psgMainPanLeftAccum		.ds		6	; 23de-23e3  = Pan Left  fraction accumulator

;..............................................................................................
; sweep operations information

psgMainSweepDelta		.ds		6	; 23e4-23e9  = channel sweep amount
psgMainSweepAccumLo		.ds		6	; 23ea-23ef  -> channel accumulated sweep amount, lo
psgMainSweepAccumHi		.ds		6	; 23f0-23f5  -> channel accumulated sweep amount, hi
psgMainSweepTime		.ds		6	; 23f6-23fb  = channel sweep time 
psgMainSweepTimeCount	.ds		6	; 23fc-2401  -> sweep time down-count

;..............................................................................................
; percussion envelope information

psgMainDrumPtrLo		.ds		6	; 2402-2407 -> percussion data pointer, lo
psgMainDrumPtrHi		.ds		6	; 2408-240d -> percussion data pointer, hi (?)

;..............................................................................................
; main stack information

mStack0					.ds		12	; 240e-2419 = voice stack area, channel 0. 12 bytes
mStack1					.ds		12	; 241a-2425 = channel 1, 12 bytes
mStack2					.ds		12	; 2426-2431 = channel 2, 12 bytes
mStack3					.ds		12	; 2432-243d = channel 3, 12 bytes
mStack4					.ds		12	; 243e-2449 = channel 4, 12 bytes
mStack5					.ds		12	; 244a-2455 = channel 5, 12 bytes

;..............................................................................................
; this is used for two purposes: the low nibble is the offset for the stack, 
; and the high nibble is the voice mode. Mode 0 => wave output, Mode 1 => Drums, Mode 2 => Noise

psgMainStackOffset		.ds		6	; 2456-245b -> offset from stack base

;..............................................................................................

psgMainFreqLo			.ds		6	; 245c-2461 -> note frequency, low byte
psgMainFreqHi			.ds		6	; 2462-2467 -> note frequency, high byte
psgMainTrackVolume		.ds		6	; 2468-246d -> track master volume
psgMainPanPot			.ds		6	; 246e-2473 = combined pan pot value [ LR ]
psgMainWaveNo	 		.ds		6	; 2474-2479 = waveform playing on voice
									;			  bit 7 is waveform loaded flag
									; 			  bits 0-6 are waveform number. 
psgMainNoiseFlag		.ds		2	; 247a-247b ? -> noise flag
									; 			actually, bit 7 might be load flag,
									; 			rest might be noise frequency
psgMainVoiceStatus		.ds		6	; 247C-2481 = status of voice in main track
                                    ;             1 = enabled
psgMainTieState			.ds		6	; 2482-2487 = voice note tie state
									;             0 = KeyOff
									;             1 = KeyOn
									;			  2 = KeyHit
									;             3 = tie (parser is on it)
									;  bit 7 indicates key-off state (?)
									
psgMainFadeOutSpeed		.ds		1	; 2488      = fade out speed (main track) ? value ?
psgMainFadeOutCount		.ds		2	; 2489-248a = fade out count (main track ) (?)

