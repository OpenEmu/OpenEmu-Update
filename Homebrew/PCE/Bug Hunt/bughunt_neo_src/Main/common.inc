;--------------------------------------------------------------------------
; common.inc - mml player include file.                                     
;---------------------------------------------------------------------------------------
; This block defines data used by (original) psg MML player routine.
; It's used by both the main and the sub-tracks, so both need access to it.
;.......................................................................................

						.org	$22d0

psgTrackIndexTable		.ds		2		;  $22d0-1 = Track table header pointer
psgUserWaveTable		.ds		2		;  $22d2-3 = user Wave Data header pointer
psgTimerCount			.ds		1		;  $22d4   = timer count, for tempo
psgUserVolEnvelope		.ds		2		;  $22d5-6 = user Volume Envelope header pointer
psgUserModEnvelope		.ds		2		;  $22d7-8 = user FM modulation envelope header pointer
psgUserPitchEnvelope	.ds		2		;  $22d9-a = user Pitch Envelope header pointer
psgUserPercTable		.ds		2		;  $22db-c = user Percussion Table data header pointer
psgTrackDelay			.ds		1		;  $22dd   = main track delay counter
										;            (# interrupts to get a 60Hz timebase, minus 1)
psgTrackCtrl			.ds		1		;  $22de   = main track/subtrack control
										;           bit 7   = main track pause (1=paused)
										;           bit 6   = subtrack pause
										;           bit 2-0 = up-counter to count to psgMainDelay value 
										;			         (IRQ counter for main track)
										; [ but we AND with $0F, implying 16 counts...]
										
psgSystemNo				.ds		1		;  $22df   = PSG_INIT system number (0-5)
psgCurrentVoice			.ds		1		;  $22e0   = current voice # (index, 0 through 5)
psgSongNo				.ds		1		;  $22e1   = song number to play (from PSG_PLAY) 
										;            (bit $80 set if already started)
psg_WaveNo				.ds		1		;  $22e2   = debug mode wave number (from PSG_PLAY)

;---------------------------------------------------------------------------------------
; there's something here, from 22e3 to 22ea (8 bytes), but I have no idea what... yet.
; 1) $22e3
; 2) $22e4
; 3) $22e5
; 4) $22e6
; 5) $22e7
; 6) $22e8
; 7) $22e9
; 8) $22ea
;..........................................................................................

						.org		$22eb
psgDataBankLow			.ds		1	;  $22eb   = low  bank for song data
psgDataBankHigh			.ds		1	;  $22ec   = high bank for song data
psgCurChannel			.ds		1  	;  $22ed   = current output channel selected in psg


;---------------------------------------------------------------------------------------
; this is used by the bios.  (PSG_CONT, specifically)

						.org		$25ff
psgSubWaveNo			.ds		6	; 25ff-2604 -> last waveform on sub track ?
