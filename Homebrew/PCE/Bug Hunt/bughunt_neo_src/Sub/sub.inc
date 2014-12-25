;--------------------------------------------------------------------------
; sub.inc - mml player include file.                                     
;---------------------------------------------------------------------------------------
; This block defines data used by (original) psg MML player routine.
;*****************************************************************************
; this is where the subtrack data starts (248b)

							.org	$248b
							
psgSubTrackPtrLo			.ds		6	; 248b-2490  =  Voice data pointer, low
psgSubTrackPtrHi			.ds		6	; 2491-2496  =  Voice data pointer, high
psgSubOctave				.ds		6	; 2497-249c  =  default octave for voice
psgSubFrequencyLo			.ds		6	; 249d-24a2  -> frequency for tone, lo
psgSubFrequencyHi			.ds		6	; 24a3-24a8  -> frequency for tone, hi
psgSubNoteDuration			.ds		6	; 24a9-24ae = subtrack note duration
psgSubVoiceVolume			.ds		6	; 24af-24b4 =  per voice volume
psgSubKeyOffPeriods			.ds		6	; 24b5-24ba ->  referenced in tone handler. value here is
psgSubKeyOnDuration			.ds		6	; 24bb-25c0 ->  referenced in tone handler. value here is
psgSubSegnoLo				.ds		6	; 24c1-24c6  = repeat point (SegNo) pointer, lo
psgSubSegnoHi				.ds		6	; 24c7-24cc  = repeat point (Segno) pointer, hi
										;          		total duration - (keyOn Duration * 1/8 total), I think
psgSubTransposeAmount		.ds		6	; 24cd-24d2 -> voice transpose amount
psgSubDurationMultiplier	.ds		6	; 24d3-24d8 = Duration multiplier (aka TimeBase)

;..............................................................................................
; (adsr) Envelope information

psgSubEnvelopePtrLo			.ds		6	; 24d9-24de = Envelope data pointer, lo
psgSubEnvelopePtrHi			.ds		6	; 24df-24e4 = Envelope data pointer, hi
psgSubEnvelopeIndex			.ds		6	; 24e5-24ea
psgSubEnvLevelLo			.ds		6	; 24eb-24f0 -> envelope level, lo byte
psgSubEnvLevelHi			.ds		6	; 24f1-24f6 -> envelope level, hi byte
psgSubEnvDurationLo			.ds		6	; 24f7-24fc -> envelope duration, lo
psgSubEnvDurationHi			.ds		6	; 24fd-2502 -> envelope duration, hi
psgSubEnvReleaseLo			.ds		6	; 2503-2508 -> envelope release rate lo
psgSubEnvReleaseHi			.ds		6	; 2509-250e -> envelope release rate hi
psgSubEnvDecayTime			.ds		6	; 250f-2514 -> envelope decay time

;..............................................................................................
; (frequency modulation) Envelope information

psgSubModBasePtrLo				.ds		6	; 2515-251a -> location of modulation data, lo byte
psgSubModBasePtrHi				.ds		6	; 251b-2520 -> location of modulation data, hi byte
psgSubModCount					.ds		6	; 2521-2526 -> possibly count for modulation
psgSubModDelay					.ds		6	; 2527-252c =  Modulation Delay amount
psgSubModDelayCount				.ds		6	; 252d-2532 -> modulation delay counter (?)
psgSubModCorrection				.ds		6	; 2533-2538 =  Modulation Correction octave

;..............................................................................................
; (pitch) Envelope information

psgSubPEPtrLo					.ds		6	; 2539-253e -> Pitch Envelope Data Pointer, lo byte
psgSubPEPtrHi					.ds		6	; 253f-2544 -> Pitch Envelope Data Pointer, hi byte
psgSubPECount					.ds		6	; 2545-254a -> possibly PE Delay count
psgSubPEDelay					.ds		6	; 254b-2550 =  Pitch Envelope Delay Amount
psgSubPEDelayCount				.ds		6	; 2551-2556 -> Pitch Envelope Delay counter ?

;..............................................................................................

psgSubDetuneAmount				.ds	6	; 2557-255c -> channel detune amount
psgSubVolumeChangeAmount		.ds	6	; 255d-2562  = channel volume deltas
										; 			   for volume +/-
psgSubVolumeChangeAccum			.ds	6	; 2563-2568 -> low byte of work volume?

;..............................................................................................
; pan operations information

psgSubPanRightDelta				.ds		6	; 2569-256e  = Pan Right change amount
psgSubPanRightAccum 			.ds		6	; 256f-2574  = Pan Right fration accumulator
psgSubPanLeftDelta				.ds		6	; 2575-257a  = Pan Left  change amount
psgSubPanLeftAccum				.ds		6	; 257b-2580  = Pan Left  fraction accumulator

;..............................................................................................
; sweep operations information

psgSubSweepDelta				.ds		6	; 2581-2585  = channel sweep amount
psgSubSweepAccumLo				.ds		6	; 2587-258c  = channel accumulated sweep amount, lo
psgSubSweepAccumHi				.ds		6	; 258d-2592  -> channel accumulated sweep amount, hi
psgSubSweepTime					.ds		6	; 2593-2598  = channel sweep time 
psgSubSweepTimeCount			.ds		6	; 2599-259e  -> sweep time down-count

;..............................................................................................
; percussion envelope operations (?)

psgSubDrumPtrLo					.ds		6	; 259f-25a4 -> percussion data pointer, lo
psgSubDrumPtrHi					.ds		6	; 25a5-25aa -> percussion data pointer, hi (?)

;..............................................................................................

sStack0							.ds		9		; 25ab-25b2 ? = voice stack area, channel 0. 12 bytes
sStack1							.ds		9		; 25b3-24bb ? = channel 1, 12 bytes
sStack2							.ds		9		; 2426-2431 = channel 2, 12 bytes
sStack3							.ds		9		; 2432-243d = channel 3, 12 bytes
sStack4							.ds		9		; 243e-2449 = channel 4, 12 bytes
sStack5							.ds		9		; 244a-2455 = channel 5, 12 bytes

psgSubStackOffset				.ds		6	; 25e1-25e6 -> offset from stack base

;..............................................................................................
; these are the outputs, pretty much

psgSubFreqLo					.ds		6	; 25e7-25ec -> note frequency, low byte
psgSubFreqHi					.ds		6	; 25ed-25f2 -> note frequency, high byte
psgSubTrackVolume				.ds		6	; 25f3-25f8 -> track master volume
psgSubPanPot					.ds		6	; 25f9-25fe = combined pan pot value [ LR ]

; this is in common area
;psgSubWaveNo					.ds		6	; 25ff-2604 -> last waveform on sub track ?
								.ds		6	; dummy reservation to keep addresses right
						
psgSubNoiseFlag					.ds		2	; 2605-2606 -> noise on flag
psgSubVoiceStatus				.ds		6	; 2607-260c = status of voice in sub track
psgSubTieState					.ds		6	; 260d-2612 = play/tiestate flag

;..............................................................................................

psgSubFadeOutSpeed				.ds		1	; 2613      = fade out speed (sub track) ?
psgSubFadeOutCount				.ds		2	; 2614-2615 = fade out count (sub track )

