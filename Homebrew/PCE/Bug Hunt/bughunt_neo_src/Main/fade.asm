;
; execute Fadeout volume adjustment
;
processFade

	lda		psgMainFadeOutSpeed
	beq		.noFade
	
	clc
	adc		psgMainFadeOutCount
	bpl		.addHi

	inc		psgMainFadeOutCount+1
	and		#$7f

.addHi
	sta		psgMainFadeOutCount
	lda		psgMainFadeOutCount+1
	cmp		#$1e
	bcc		.noFade
	
	ldx		#5
.voxLoop
	lda		psgMainVoiceStatus,x
	beq		.nextVoice

	lda		#2							;fading out?
	sta		psgMainVoiceStatus,x
	
.nextVoice
	dex
	bpl		.voxLoop
	
.noFade
	rts
