;
; execute Fadeout volume adjustment
;
subProcessFade

	lda		psgSubFadeOutSpeed
	beq		.noFade
	
	clc
	adc		psgSubFadeOutCount
	bpl		.addHi

	inc		psgSubFadeOutCount+1
	and		#$7f

.addHi
	sta		psgSubFadeOutCount
	
	lda		psgSubFadeOutCount+1
	cmp		#$1e
	bcc		.noFade
	
	ldx		#5
.voxLoop
	lda		psgSubVoiceStatus,x
	beq		.nextVoice

	lda		#2							; mark voice as ending
	sta		psgSubVoiceStatus,x
	
.nextVoice
	dex
	bpl		.voxLoop
	
.noFade
	rts
