arch snes.smp


define musicData $e000	;fixed location for music data

;I/O registers

define TEST $f0
define CTRL $f1
define ADDR $f2
define DATA $f3
define CPU0 $f4
define CPU1 $f5
define CPU2 $f6
define CPU3 $f7
define TMP0 $f8
define TMP1 $f9
define T0TG $fa
define T1TG $fb
define T2TG $fc
define T0OT $fd
define T1OT $fe
define T2OT $ff

;DSP channel registers, x0..x9, x is channel number

define DSP_VOLL  $00
define DSP_VOLR  $01
define DSP_PL    $02
define DSP_PH    $03
define DSP_SRCN  $04
define DSP_ADSR1 $05
define DSP_ADSR2 $06
define DSP_GAIN	 $07
define DSP_ENVX	 $08
define DSP_OUTX	 $09

;DSP registers for global settings

define DSP_MVOLL $0c
define DSP_MVOLR $1c
define DSP_EVOLL $2c
define DSP_EVOLR $3c
define DSP_KON	 $4c
define DSP_KOF	 $5c
define DSP_FLG	 $6c
define DSP_ENDX	 $7c
define DSP_EFB	 $0d
define DSP_PMON	 $2d
define DSP_NON	 $3d
define DSP_EON	 $4d
define DSP_DIR	 $5d
define DSP_ESA	 $6d
define DSP_EDL	 $7d
define DSP_C0	 $0f
define DSP_C1	 $1f
define DSP_C2	 $2f
define DSP_C3	 $3f
define DSP_C4	 $4f
define DSP_C5	 $5f
define DSP_C6	 $6f
define DSP_C7	 $7f

;vars

define D_TEMP	 $00

define D_SYNC	 $08
define D_BUFPTR	 $09
define D_KON	 $0a
define D_KOF	 $0b
define D_STEREO	 $0c

define M_ENABLE	 $10	;byte
define M_ROW	 $11	;byte
define M_ORDPTR_L $12	;word
define M_ORDPTR_H $13
define M_ORDINC	 $14	;byte
define M_CHCUR0x $15	;byte
define M_CHCURx0 $16	;byte
define M_CHOFF	 $17	;byte
define M_UPDROW	 $18	;byte
define M_SPEED	 $19	;byte

define M_ORDBEGIN_L	{musicData}
define M_ORDBEGIN_H	{musicData}+1
define M_ORDLOOP_L	{musicData}+2
define M_ORDLOOP_H	{musicData}+3
define M_CHANNELS	{musicData}+4
define M_INITSPEED	{musicData}+5
define M_PATTERNS_L	{musicData}+6
define M_PATTERNS_H	{musicData}+7

define M_CHSIZE	$0b	;11 bytes per channel

define M_CH0	$20
define M_CH1	{M_CH0}+{M_CHSIZE}
define M_CH2	{M_CH1}+{M_CHSIZE}
define M_CH3	{M_CH2}+{M_CHSIZE}
define M_CH4	{M_CH3}+{M_CHSIZE}
define M_CH5	{M_CH4}+{M_CHSIZE}
define M_CH6	{M_CH5}+{M_CHSIZE}
define M_CH7	{M_CH6}+{M_CHSIZE}

define D_BUFFER	$80

;offsets for music channel vars

define CH_FRAME	 $00
define CH_SPEED	 $01
define CH_PTR_L	 $02	;word
define CH_PTR_H	 $03
define CH_WAIT	 $04	;byte
define CH_VOL	 $05	;byte
define CH_PAN	 $06	;byte
define CH_NOTE	 $07	;byte
define CH_VIBOFF $08	;byte
define CH_VIBINC $09	;byte
define CH_VIBMUL $0a	;byte



	org 0
	base $0200



start:
	clp

	ldx #0
	stx {D_KON}
	stx {D_KOF}
	stx {D_STEREO}
	stx {M_ENABLE}

	dex
	txs

	lda {CPU0}			;read current value of cpu0, it is used as strobe
	sta {D_SYNC}

	jsr bufClear

setState:
	ldx #0				;initialize registers
.1:
	lda initDataSeq,x
	beq .2
	sta {ADDR}
	inx
	lda initDataSeq,x
	sta {DATA}
	inx
	bra .1
.2:

	lda #(8000/100)		;8000/80=100hz
	sta {T0TG}
	lda #$81			;enable timer 0 and IPL
	sta {CTRL}

mainLoop:

waitForTimer:
	jsr checkCommand
	lda {T0OT}
	beq waitForTimer

	jsr updatePlayer

	bra mainLoop



checkCommand:
	lda {CPU0}			;wait until cpu0 is changed
	cmp {D_SYNC}
	bne .read
	rts
.read:
	sta {D_SYNC}		;remember for next time
	sta {CPU0}			;confirm strobe

	lda {CPU1}			;read command code
	pha
	and #$0f
	tay					;channel for sound effect commands
	pla
	lsr
	lsr
	lsr
	and #$0e
	tax
	jmp (cmdList,x)



cmdStereo:
	lda {CPU2}
	sta {D_STEREO}
	rts


cmdVolume:
	lda {CPU2}
	ldx #{DSP_MVOLL}
	stx {ADDR}
	sta {DATA}
	ldx #{DSP_MVOLR}
	stx {ADDR}
	sta {DATA}
	rts


cmdMusStop:
	jsr bufClear
	
	ldx #0
	stx {M_ENABLE}

.mute:
	jsr keyOffBuf
	inx
	cpx {M_CHANNELS}
	bne .mute

	lda {D_KOF}
	eor #$ff
	and {D_KON}
	sta {D_KON}

	jmp keyOffApply


cmdMusPlay:
	lda #1
	sta {M_ENABLE}
	jmp musicInit


cmdSfxPlay:
	cpy {M_CHANNELS}	;don't play effects on music channels
	bcs .play
	rts
.play:
	lda #{M_CHSIZE}		;get channel offset
	mul
	clc
	adc #{M_CH0}
	tax

	lda {CPU2}
	asl
	tay

	lda soundData,y
	clc
	adc #soundData&255
	sta {CH_PTR_L},x
	lda soundData+1,y
	adc #soundData/256
	sta {CH_PTR_H},x
	lda #0
	sta {CH_WAIT},x
	sta {CH_NOTE},x
	sta {CH_VIBMUL},x
	sta {CH_VIBINC},x
	sta {CH_FRAME},x
	lda #6
	sta {CH_SPEED},x
	lda {CPU3}
	sta {CH_PAN},x
	lda #$3f
	sta {CH_VOL},x

	rts


cmdReload:
	jmp $ffc0



;reads variables from music data (it is at fixed location)
;reset channels variables

musicInit:
	ldy {M_CHANNELS}	;get order pos width from music data, it is channels+1
	sty {M_ORDINC}
	inc {M_ORDINC}

	lda {M_ORDBEGIN_L}	;get initial order list pointer
	clc
	adc #{musicData}&255
	sta {M_ORDPTR_L}
	lda {M_ORDBEGIN_H}
	adc #{musicData}/256
	sta {M_ORDPTR_H}

	ldx #{M_CH0}		;initialize channels vars
.set:
	lda #0
	sta {CH_WAIT},x
	sta {CH_NOTE},x
	sta {CH_VIBMUL},x
	sta {CH_VIBINC},x
	sta {CH_FRAME},x	;reset frame counter
	sta {CH_SPEED},x	;disable channel
	lda #$80
	sta {CH_PAN},x
	lda #$3f
	sta {CH_VOL},x

	txa
	clc
	adc #{M_CHSIZE}
	tax

	dey
	bne .set

	lda #$ff			;keyoff for all the channels
	sta {D_KOF}
	lda #0				;reset frame counter
	sta {D_KON}
	lda {M_INITSPEED}	;set initial speed
	sta {M_SPEED}

	;rts				;no rts because jsr musicUpdateOrder is needed for init



;move to the next order list position

define T_CHCNT $00

updateOrder:
	lda {M_CHANNELS}	;read pattern pointers into channels vars
	sta {T_CHCNT}
	ldy #0
	lda #{M_CH0}
	sta {M_CHOFF}
.read:
	lda ({M_ORDPTR_L}),y
	iny

	asl
	tax
	lda {M_PATTERNS_L},x
	clc
	adc #{musicData}&255
	pha
	lda {M_PATTERNS_H},x
	adc #{musicData}/256
	ldx {M_CHOFF}
	sta {CH_PTR_H},x
	pla
	sta {CH_PTR_L},x

	txa
	clc
	adc #{M_CHSIZE}
	sta {M_CHOFF}

	dec {T_CHCNT}
	bne .read

	lda ({M_ORDPTR_L}),y;read order position length
	sta {M_ROW}
	iny

	lda ({M_ORDPTR_L}),y;check if next position is end of the order list
	cmp #$ff
	bne .next

	lda {M_ORDLOOP_L}		;load loop position
	clc
	adc #{musicData}&255
	sta {M_ORDPTR_L}
	lda {M_ORDLOOP_H}
	adc #{musicData}/256
	sta {M_ORDPTR_H}
	rts

.next:
	clc					;move to the next position
	lda {M_ORDPTR_L}
	adc {M_ORDINC}
	sta {M_ORDPTR_L}
	lda {M_ORDPTR_H}
	adc #0
	sta {M_ORDPTR_H}

	rts



;run one frame of music player

updatePlayer:
	jsr bufApply			;apply register writes from previous frame
	jsr keyOnApply			;apply keyon from previous frame

	lda #0					;process all the channels, some of them for music, some for sound
	sta {M_CHCUR0x}
	sta {M_CHCURx0}
	sta {M_UPDROW}
	lda #{M_CH0}
	sta {M_CHOFF}

.loop:
	jsr updateChannel

	lda {M_CHOFF}
	clc
	adc #{M_CHSIZE}
	sta {M_CHOFF}

	lda {M_CHCURx0}
	clc
	adc #$10
	sta {M_CHCURx0}

	inc {M_CHCUR0x}
	lda {M_CHCUR0x}
	cmp #8
	bne .loop

	jsr keyOffApply			;apply keyoff, it always one frame earlier

	lda {M_UPDROW}
	beq .noRow
	dec {M_ROW}
	bne .noRow
	jsr updateOrder
.noRow:
	rts



;update one channel

define T_PTNPTR_L	 $00	;word
define T_PTNPTR_H	 $01
define T_CHVOLL		 $02
define T_CHVOLR		 $03
define T_PITCH_OFF_L $04
define T_PITCH_OFF_H $05

updateChannel:
	ldx {M_CHOFF}
	lda {M_CHCUR0x}
	cmp {M_CHANNELS}
	bcc .checkMus
	lda {CH_SPEED},x	;if speed is 0, channel is inactive
	bne .active
	rts
.checkMus:
	lda {M_ENABLE}
	bne .active
	rts
.active:
	lda {CH_FRAME},x
	beq .row
	jmp .processVolume

.row:
	lda {CH_WAIT},x
	beq .noWait
	dec {CH_WAIT},x
	jmp .processVolume

.noWait:
	lda {CH_PTR_H},x
	sta {T_PTNPTR_H}
	lda {CH_PTR_L},x
	sta {T_PTNPTR_L}

.read:
	jsr readPtnByte
	tay
	and #$c0

	beq .empty
	cmp #$40
	beq .volume
	cmp #$80
	beq .ins
.note:
	tya
	cmp #$fc
	bcs .effect

	and #$3f			;it is a note, remember it
	asl
	ldx {M_CHOFF}
	sta {CH_NOTE},x
	lda #0
	sta {CH_VIBOFF},x

	ldx {M_CHCUR0x}		;keyoff and keyon
	jsr keyOffBuf
	jsr keyOnBuf

	jmp .done

.effect:
	cmp #$fc
	bne .noPitch

	jsr readPtnByte		;it is a pitch change without restarting note
	and #$3f
	asl
	ldx {M_CHOFF}
	sta {CH_NOTE},x

	bra .done

.noPitch:
	cmp #$fd
	bne .noStop
	ldx {M_CHCUR0x}		;it is note cut
	jsr keyOffBuf
	bra .done

.noStop:
	cmp #$fe
	bne .noPan
	jsr readPtnByte		;it is pan, next byte is value
	ldx {M_CHOFF}
	sta {CH_PAN},x
	bra .read

.noPan:
	jsr readPtnByte		;it is speed, next byte is value
	ldx {M_CHCUR0x}
	cpx {M_CHANNELS}
	bcs .setSpeed
	sta {M_SPEED}
	bra .read

.setSpeed:
	ldx {M_CHOFF}
	sta {CH_SPEED},x
	cmp #0
	bne .read
	lda {M_CHCUR0x}
	jmp keyOffBuf

.empty:
	ldx {M_CHOFF}
	sty {CH_WAIT},x
	bra .done

.volume:
	tya
	and #$3f
	asl
	ldx {M_CHOFF}
	sta {CH_VOL},x
	bra .read

.ins:
	tya
	and #$3f
	pha

	lda {M_CHCURx0}
	ora #{DSP_SRCN}
	tax
	pla
	jsr bufWrite		;write instrument number

	asl					;get offset for parameter tables
	tax

	lda vibrato+1,x		;get vibrato parameters
	pha
	lda vibrato,x
	pha
	lda adsr+1,x		;get adsr parameters
	pha
	lda adsr,x
	pha

	lda {M_CHCURx0}		;write adsr parameters
	ora #{DSP_ADSR1}
	tax
	pla
	jsr bufWrite
	lda {M_CHCURx0}
	ora #{DSP_ADSR2}
	tax
	pla
	jsr bufWrite

	ldx {M_CHOFF}		;write vibrato parameters
	pla
	sta {CH_VIBINC},x
	pla
	sta {CH_VIBMUL},x

	jmp .read

.done:
	ldx {M_CHOFF}
	lda {T_PTNPTR_L}
	sta {CH_PTR_L},x
	lda {T_PTNPTR_H}
	sta {CH_PTR_H},x

.processVolume:
	lda {D_STEREO}
	beq .mono
.stereo:
	lda {CH_PAN},x			;calculate left volume
	eor #$ff
	tay
	lda {CH_VOL},x
	mul
	sty {T_CHVOLL}
	ldy {CH_PAN},x			;calculate right volume
	lda {CH_VOL},x
	mul
	sty {T_CHVOLR}
	bra .setVol

.mono:
	lda {CH_VOL},x
	sta {T_CHVOLL}
	sta {T_CHVOLR}

.setVol:
	lda {M_CHCURx0}
	ora #{DSP_VOLL}
	tax
	lda {T_CHVOLL}
	jsr bufWrite
	lda {M_CHCURx0}
	ora #{DSP_VOLR}
	tax
	lda {T_CHVOLR}
	jsr bufWrite

.processPitch:
	ldx {M_CHOFF}

	lda {CH_VIBOFF},x
	ldy {CH_VIBMUL},x
	tax
	lda vibratoTable,x
	mul
	sty {T_PITCH_OFF_L}
	lda #0
	sta {T_PITCH_OFF_H}
	asl {T_PITCH_OFF_L}
	rol {T_PITCH_OFF_H}
	asl {T_PITCH_OFF_L}
	rol {T_PITCH_OFF_H}

	ldx {M_CHOFF}
	lda {CH_NOTE},x
	tax
	lda divTable,x
	clc
	adc {T_PITCH_OFF_L}
	pha
	lda divTable+1,x
	adc {T_PITCH_OFF_H}
	pha
	lda {M_CHCURx0}
	ora #{DSP_PH}
	tax
	pla
	jsr bufWrite
	lda {M_CHCURx0}
	ora #{DSP_PL}
	tax
	pla
	jsr bufWrite

	ldx {M_CHOFF}
	lda {CH_VIBOFF},x		;advance vibrato table pointer
	clc
	adc {CH_VIBINC},x
	sta {CH_VIBOFF},x

.processFrameRow:
	lda {CH_FRAME},x
	bne .noRow
	lda {M_CHCUR0x}
	cmp {M_CHANNELS}
	bcc .processMus
	lda {CH_SPEED},x
	sta {CH_FRAME},x
	bra .noRow

.processMus:
	lda {M_SPEED}
	sta {CH_FRAME},x
	lda #1
	sta {M_UPDROW}

.noRow:
	dec {CH_FRAME},x
	rts



;read one byte from pattern data
;out: A=data, Y=0

readPtnByte:
	ldy #0
	lda ({T_PTNPTR_L}),y
	inc {T_PTNPTR_L}
	bne .1
	inc {T_PTNPTR_H}
.1:
	rts



;clear register writes buffer, just set ptr to 0

bufClear:
	str {D_BUFPTR}=#0
	rts



;add register write in buffer
;in X=reg, A=value

bufWrite:
	pha
	txa
	ldx {D_BUFPTR}
	sta {D_BUFFER},x
	inx
	pla
	sta {D_BUFFER},x
	inx
	stx {D_BUFPTR}
	rts



;send writes from buffer and clear it

bufApply:
	lda {D_BUFPTR}
	beq .done
	ldx #0
.loop:
	lda {D_BUFFER},x
	sta {ADDR}
	inx
	lda {D_BUFFER},x
	sta {DATA}
	inx
	cpx {D_BUFPTR}
	bne .loop
	str {D_BUFPTR}=#0
.done:
	rts



;set keyon for needed channel in temp variable
;in: X=channel

keyOnBuf:
	lda channelMask,x
	ora {D_KON}
	sta {D_KON}
	rts



;send keyon from temp variable

keyOnApply:
	lda {D_KON}
	eor #$ff
	and {D_KOF}
	ldx #{DSP_KOF}
	stx {ADDR}
	sta {DATA}
	sta {D_KOF}

	lda #{DSP_KON}
	sta {ADDR}
	lda {D_KON}
	str {D_KON}=#0
	sta {DATA}

	rts



;set keyoff for needed channel in temp variable
;in: X=channel

keyOffBuf:
	lda channelMask,x
	ora {D_KOF}
	sta {D_KOF}
	rts



;send keyoff from temp variable

keyOffApply:
	lda #{DSP_KOF}
	sta {ADDR}
	lda {D_KOF}
	sta {DATA}
	rts



cmdList:
	dw cmdStereo	;0 set stereo mode, 0 or 1
	dw cmdVolume	;1 set global volume, 0..127
	dw cmdMusStop	;2 stops music
	dw cmdMusPlay	;3 restarts music
	dw cmdSfxPlay	;4 play sound effect, number 0..127 and pan 0..255
	dw cmdReload	;5 call IPL


divTable:
	dw $0217,$0237,$0259,$027d,$02a3,$02cb,$02f5,$0322
	dw $0352,$0385,$03ba,$03f3,$042f,$046f,$04b2,$04fa
	dw $0546,$0596,$05eb,$0645,$06a5,$070a,$0775,$07e6
	dw $085f,$08de,$0965,$09f4,$0a8c,$0b2c,$0bd6,$0c8b
	dw $0d4a,$0e14,$0eea,$0fcd,$10be,$11bd,$12cb,$13e9
	dw $1518,$1659,$17ad,$1916,$1a94,$1c28,$1dd5,$1f9b
	dw $217c,$237a,$2596,$27d2,$2a31,$2cb3,$2f5b,$322c
	dw $3528,$3851,$3bab,$3f37,$0000,$0000,$0000,$0000


vibratoTable:
	db $00,$01,$03,$04,$06,$07,$09,$0a,$0c,$0d,$0f,$11,$12,$14,$15,$17
	db $18,$1a,$1b,$1d,$1e,$20,$21,$23,$24,$26,$27,$29,$2a,$2c,$2d,$2f
	db $30,$32,$33,$34,$36,$37,$39,$3a,$3b,$3d,$3e,$3f,$41,$42,$43,$45
	db $46,$47,$49,$4a,$4b,$4c,$4e,$4f,$50,$51,$52,$54,$55,$56,$57,$58
	db $59,$5a,$5b,$5d,$5e,$5f,$60,$61,$62,$63,$64,$65,$66,$66,$67,$68
	db $69,$6a,$6b,$6c,$6c,$6d,$6e,$6f,$70,$70,$71,$72,$72,$73,$74,$74
	db $75,$75,$76,$77,$77,$78,$78,$79,$79,$79,$7a,$7a,$7b,$7b,$7b,$7c
	db $7c,$7c,$7d,$7d,$7d,$7d,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
	db $7f,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7d,$7d,$7d,$7d,$7c
	db $7c,$7c,$7b,$7b,$7b,$7a,$7a,$79,$79,$79,$78,$78,$77,$77,$76,$75
	db $75,$74,$74,$73,$72,$72,$71,$70,$70,$6f,$6e,$6d,$6c,$6c,$6b,$6a
	db $69,$68,$67,$66,$66,$65,$64,$63,$62,$61,$60,$5f,$5e,$5d,$5b,$5a
	db $59,$58,$57,$56,$55,$54,$52,$51,$50,$4f,$4e,$4c,$4b,$4a,$49,$47
	db $46,$45,$43,$42,$41,$3f,$3e,$3d,$3b,$3a,$39,$37,$36,$34,$33,$32
	db $30,$2f,$2d,$2c,$2a,$29,$27,$26,$24,$23,$21,$20,$1e,$1d,$1b,$1a
	db $18,$17,$15,$14,$12,$11,$0f,$0d,$0c,$0a,$09,$07,$06,$04,$03,$01


channelMask:
	db $01,$02,$04,$08,$10,$20,$40,$80


initDataSeq:
	db {DSP_FLG}  ,%01100000;mute, no echo
	db {DSP_PMON} ,0		;no pitch modulation
	db {DSP_NON}  ,0		;no noise
	db {DSP_EON}  ,0		;no echo
	db {DSP_ESA}  ,255		;echo at highest page
	db {DSP_EDL}  ,0		;minimal length
	db {DSP_DIR}  ,(dir>>8)	;address of sample dir
	db {DSP_MVOLL},127		;global volume to the max
	db {DSP_MVOLR},127
	db {DSP_EVOLL},0		;echo volume to zero
	db {DSP_EVOLR},0
	db {DSP_FLG}  ,%00100000;no mute, no echo
	db {DSP_KOF}  ,255		;all keys off
	db 0


;macro for samples

macro sample ptr,loop
	dw {ptr}
	dw {ptr}+{loop}
endmacro

macro adsr ar,dr,sl,sr
	db $80|{ar}|({dr}<<4)
	db {sr}|({sl}<<5)
endmacro

macro vib speed,depth
	db {speed}
	db {depth}
endmacro



	org $0600	;$0800 in memory
	incsrc "sound\samples.asm"

soundData:
	incbin "sound\sounds.bin"