; SWOOPS!
; Copyright 2005, Thomas Jentzsch
; Version 0.96

; free: 4/(-2) bytes (NTSC/PAL)

;TODOs;
; + rotate colors for selected option
; + PAL
; o 3-Athlon:
;   + Menu
;   + draw score
;   + cummulate scores
;   + adjust options
; + Toto looking up and down in Crash'N'Dive too
; + SELECT returns to menu:
;   + Splatform
;   + Crash'n'Dive
;   + Cave1K
; + reset score at start of game
; + prevent restart of games in 3-Athlon mode (returns with select):
;   + Splatform
;   + Crash'n'Dive
;   + Cave1K
; + select disables 3-Athlon mode
; + use last *maximum* score


TIA_BASE_READ_ADDRESS = $30

    processor 6502
    include vcs.h


;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

VERSION         = $0096
BASE_ADR        = $f000

ILLEGAL         = 1
DEBUG           = 0

NTSC_TIM        = 0     ; [1] (+-0) 0 = PAL-50
NTSC_COL        = 0     ; [1] (- 2) 0 = PAL colors

; features:
CENTER_SCORE    = 1     ; [0] (-10)


;===============================================================================
; C O N S T A N T S
;===============================================================================

TITLE_H         = 7
FONT_H          = 11

NUM_OPTIONS     = 4
MODE_3ATHLON    = NUM_OPTIONS-1

  IF NTSC_COL
NUM_GRADIENTS   = 8
  ELSE
NUM_GRADIENTS   = 7
  ENDIF
MAX_SCROLL      = NUM_GRADIENTS*2

  IF NTSC_TIM
DELAY           = 30    ; 0.5 sec
  ELSE
DELAY           = 25    ; 0.5 sec
  ENDIF

RESERVED        = 7
STACK_TOP       = $100 - (RESERVED+2)


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

    SEG.U   variables
    ORG     $80

frameCnt    ds 1
color       ds 1
dir         ds 1
count       ds 1

colScroll   ds 1

delay       ds 1
switch      ds 1
optionLo    ds 1

    ORG     $c3

tmpVar      ds 16+1

    ORG     STACK_TOP

startVec    ds 2        ; can be overwritten
resetVec    ds 2        ; reset vector
scoreOfs    ds 1
option      ds 1
score       ds 3        ; cummulated score
scoreHi     = score
scoreMid    = score+1
scoreLo     = score+2


;===============================================================================
; M A C R O S
;===============================================================================

  MAC DEBUG_BRK
    IF DEBUG
      brk                         ;
    ENDIF
  ENDM

  MAC NOP_IMM
    .byte   $82
  ENDM

  MAC BIT_B
    .byte   $24
  ENDM

  MAC BIT_W
    .byte   $2c     ; 4 cylces
  ENDM

  MAC SLEEP
    IF {1} = 1
      ECHO "ERROR: SLEEP 1 not allowed !"
      END
    ENDIF
    IF {1} & 1
      nop $00
      REPEAT ({1}-3)/2
        nop
      REPEND
    ELSE
      REPEAT ({1})/2
        nop
      REPEND
    ENDIF
  ENDM

  MAC CHECKPAGE
    IF >. != >{1}
      ECHO ""
      ECHO "ERROR: different pages! (", {1}, ",", ., ")"
      ECHO ""
      ERR
    ENDIF
  ENDM

  MAC DEC2BCD
    IF {1} > 99
      ECHO "ERROR: Value too large for BCD! (", {1}, ")"
      ERR
    ENDIF
    .byte ({1}) / 10 << 4 | ({1}) % 10
  ENDM


;===============================================================================
; R O M - C O D E
;===============================================================================
    SEG     Bank0

    ORG     BASE_ADR

  IF NTSC_TIM
    incbin "splatform.bin"
    incbin "down.bin"
    incbin "cave1k.bin"
  ELSE
    incbin "splatPAL.bin"
    incbin "downPAL.bin"
    incbin "cavePAL.bin"
  ENDIF

DrawName SUBROUTINE
.tmpOption  = tmpVar
.tmpCount   = tmpVar+1
.tmpVal     = tmpVar+2
.grPtr      = tmpVar+3  ; ..tmpVar+14
.tmpCol     = .grPtr-2

    txa
    asl
    asl
    asl
    tay
    lda     PtrTbl,y
    sta     .tmpVal

    ldx     #12
.loopPtr:
    lda     .tmpVal
    sta     .grPtr-1,x
    iny
    lda     PtrTbl,y
    sta     .grPtr-2,x
    dex
    dex
    bpl     .loopPtr

  IF NTSC_TIM
    ldy     #7-1-1
  ELSE
    ldy     #8
  ENDIF
.wait:
    sta     WSYNC
    dey
    bpl     .wait

Draw48:
; *** wait some cycles: ***
    ldy     #9
.loopSleep:
    dey
    bne     .loopSleep      ; 2³= 46

; *** setup colors: ***
; .tmpCol contains color
    lda     .tmpOption
    cmp     optionLo
    beq     .skipDark
    BIT_W
.skipDark:
    ldy     colScroll
    ldx     #FONT_H+1
.loopCol:
    lda     .tmpCol
    and     ColTbl-1,y
    pha
    iny
    dex
    bne     .loopCol

    lda     .tmpOption      ; 3         @44
    bmi     .drawScore

; *** setup marker: ***
    cmp     optionLo        ; 3
    beq     .skipPF         ; 2³
    BIT_B                   ; 1
.skipPF:
    dex                     ; 2
.contPF                     ;   = 11
    ldy     #FONT_H-1       ; 2
    sty     .tmpCount       ; 3
    lda     #$fc            ; 2
    sta     PF2             ; 3
    pla                     ; 4
    stx     PF1             ; 3 = 17

; *** kernel loop: ***
.loop                       ;           @69
    sta     COLUPF          ; 3
    lda     (.grPtr+4),y    ; 5 =  8
    sta     GRP0            ; 3
    lda     (.grPtr+10),y   ; 5
    sta     GRP1            ; 3
    lda     (.grPtr+2),y    ; 5
    sta     GRP0            ; 3
    lda     (.grPtr+8),y    ; 5
    sta     .tmpVal         ; 3 = 27
    lax     (.grPtr),y      ; 5
    lda     (.grPtr+6),y    ; 5
    ldy     .tmpVal         ; 3
    sty     GRP1            ; 3         @44
    stx     GRP0            ; 3         @47
    sta     GRP1            ; 3         @50
    sta     GRP0            ; 3 = 25    @53 -1
    pla                     ; 4
    dec     .tmpCount       ; 5
    ldy.w   .tmpCount       ; 4
    bpl     .loop           ; 2³= 15/16

    iny
    sty     PF1
    sty     PF2
    rts

DIGIT_HEIGHT    = 9-4
.blockHeight    = .tmpVal

.drawScore:
    sta     ENABL               ; 3             a = 255!
    stx     COLUPF              ; 3             x = 0!
    lda     #%110100            ; 2             8 pixel ball, priority over graphivs, non-reflected PF
    sta     CTRLPF
  IF NTSC_COL = 0
    pla
  ENDIF
    pla
    lda     #%10011001
    sta     .blockHeight
    ldy     #DIGIT_HEIGHT
.nextBlock:
    dey                         ; 2 =  2
.contBlock:
    lda     (.grPtr+10),y       ; 5
    sta     GRP1                ; 3
    sta     WSYNC               ; 3 = 11
;---------------------------------------
    pla                         ; 4
    sta     COLUP0              ; 3 =  7
    sta     COLUP1              ; 3
    lda     (.grPtr+2),y        ; 5
    sta     GRP0                ; 3         @18
    lda     (.grPtr+8),y        ; 5
    sta     GRP1                ; 3 = 24    @31
    lax     (.grPtr+6),y        ; 5
    lda     (.grPtr+0),y        ; 5
  IF CENTER_SCORE
    sta     RESBL               ; 3         @44
  ELSE
    sta.w   RESBL               ; 3         @44
  ENDIF
    lsr     .blockHeight        ; 5
    sta     GRP0                ; 3         @52
    stx     GRP1                ; 3         @54
    sta     GRP0                ; 3 = 27    @57
    bcs     .nextBlock          ; 2³
    bne     .contBlock          ; 2³= 10

  IF NTSC_COL
    pla
  ENDIF
    pla                         ; 4
    sty     COLUP0
    sty     COLUP1
    sty     ENABL

  IF CENTER_SCORE
    lda     #$d0
    sta     HMP0
    sta     HMP1
    sta     WSYNC
    sta     HMOVE
  ENDIF
    rts

;**************************************************************

Select SUBROUTINE

Add16BCD = $f376+1

    ldx     scoreOfs
    lda     $01,x
    ldy     $00,x
    ldx     #<scoreMid
    jsr     Add16BCD
    bcc     .skipHi
    inc     scoreHi
.skipHi:

    ldx     option
    bpl     .skip3Athlon
    inx
    cpx     #$80+MODE_3ATHLON   ;           end if 3-ATHLON mode?
    bne     .cont3Athlon
    ldx     #MODE_3ATHLON       ;           back to normal mode
.cont3Athlon:
    stx     option
.skip3Athlon:
    ldx     #-7
    BIT_W
Start:
    ldx     #0
    cld                         ;           Clear BCD math bit.
    lda     #0
    txs
.clearLoop:
    pha
    tsx
    bne     .clearLoop

;    lda     #VERSION
;    sta     scoreLo

MainLoop:
  IF NTSC_TIM
    ldy     #43
  ELSE
    ldy     #57
  ENDIF
    ldx     #$f0|%11

; *** Vertical Blank ***
    lda     #%00001110
.loopVSync:
    sta     WSYNC
    sta     VSYNC
    lsr
    bne     .loopVSync

    sty     TIM64T

; *** Game Calc ***
    txa
    txs
    sta     NUSIZ0
    sta     NUSIZ1
    sta     VDELP0
    sta     VDELP1

    sta     HMP1            ;               a=$fx
  IF CENTER_SCORE
    asl
    sta     HMP0            ;               a=$ex
    sta     RESP0           ; @39-3
    sta     RESP1           ; @42-3
  ELSE
    asl
    sta     RESP0           ; @39
    sta     RESP1           ; @42
  ENDIF


; *** Draw Screen ***
DrawScreen SUBROUTINE
.tmpOption  = tmpVar
.tmpCol     = tmpVar+1
SetupScore  = $f792+1

    ldx     #6-1                ; 2         number of digits-1
    ldy     #$3d                ; 2         score offset
    jsr     SetupScore

.waitTim:
    ldy     INTIM
    bne     .waitTim
    sty     WSYNC
    sta     HMOVE
    sty     VBLANK              ; 3         disable
    stx     TIM64T              ; 4         x = 255!

    stx     .tmpOption          ; 3         anything unlike 0..3 goes
    lda     #$0f                ; 2         WHITE
    sta     .tmpCol             ; 3
    jsr     Draw48              ; 6 = 21

; *** TitleScreen ***
.addVal     = tmpVar
.sum        = tmpVar+1
.addBlock   = tmpVar+2
.endY       = tmpVar+3

; scroll colors of selected option:
    lda     frameCnt
    and     #$03
    bne     .skipScroll
    dec     colScroll
    bpl     .skipScroll
    ldy     #MAX_SCROLL-1
    sty     colScroll
.skipScroll:

    lsr
    ldy     count
    bcs     .skipCount
    lda     color
  IF NTSC_COL
    adc     #$10                ; $30???
  ELSE
    adc     #$20
    bcc     .contCol
    adc     #$0f
.contCol:
  ENDIF
    tax
    lda     dir
    bmi     .posDir
    iny
    cpy     #15
    bcc     .setCount
    ora     #$80
    bmi     .setDir

.posDir:
    eor     #$c0                ; reverse directions
    dey
    bne     .setCount
    stx     color               ; set new color
.setDir:
    sta     dir
.setCount:
    sty     count
.skipCount:
    beq     .endDraw

    lda     AddTbl-1,y
    sta     .addVal
    lsr
    sta     .sum

    ldx     DelayTbl-1,y
.waitCenter:
    sta     WSYNC
    dex
    bne     .waitCenter

    ldy     #TITLE_H
;    ldx     #0
    bit     dir
    bvc     .posDir1
    ldy     #-1
    ldx     #TITLE_H-1
.posDir1:
    stx     .endY

.loopBlock:                     ;           @59
    cpy     .endY               ; 3
    beq     .endDraw            ; 2³
    bmi     .negDirK            ; 2³
    dey                         ; 2
    NOP_IMM                     ; 0
.negDirK:
    iny                         ; 2
    ldx     color               ; 3 = 14
.loopLine:
    sta     WSYNC               ; 3 =  3    @68/76
;---------------------------------------
    stx     COLUPF              ; 3 =  3    @03

    lda     TitlePat0L,y        ; 4
    sta     PF0                 ; 3
    lda     TitlePat1L,y        ; 4
    sta     PF1                 ; 3         @17
    lda     TitlePat2L,y        ; 4
    sta     PF2                 ; 3 = 21    @24

    nop                         ; 2
    lda     TitlePat0R,y        ; 4
    sta     PF0                 ; 3 =  9    @33

    lda     .sum                ; 3
    adc     .addVal             ; 3
    sta     .sum                ; 3 =  9    @42

    lda     TitlePat1R,y        ; 4
    sta     PF1                 ; 3         @49
    lda     TitlePat2R,y        ; 4
    sta     PF2                 ; 3 = 14    @56

    bcs     .loopBlock          ; 2³
    inx                         ; 2
    inx                         ; 2
    bcc     .loopLine           ; 3³=  9    @65

.endDraw:                       ;           @65
    inc     frameCnt            ; 5
    ldy     #0                  ; 2
    sty     PF0                 ; 3         @75
    sty     COLUPF              ; 3
    iny                         ; 2
    sty     CTRLPF              ; 3

.waitMiddle:
    lda     INTIM
  IF NTSC_TIM
    eor     #143-1
  ELSE
    eor     #124-1
  ENDIF
    bne     .waitMiddle

    tax                         ;       x = 0
    lda     option
    and     #~$80
    bpl     .setOptionLo

.draw3Athlon:
    bit     option
    bpl     .loopOptions
    txa
.setOptionLo:
    sta     optionLo
.loopOptions:
    stx     .tmpOption
    jsr     DrawName
    ldx     .tmpOption
    inx
    cpx     #MODE_3ATHLON
    bcc     .loopOptions
    beq     .draw3Athlon

    ldx     #$82
    sta     WSYNC
    stx     VBLANK
;DrawScreen

; *** OverScan ***
  IF NTSC_TIM
    lda     #38
  ELSE
    lda     #50
  ENDIF
    sta     TIM64T

;*** select option ***
    lda     option
    and     #$0f
    tay
; SELECT pressed?:
    lda     SWCHB
    lsr
    ror                         ; c = 1! (RESET bit)
    bcc     .move
; joystick moved?:
    lda     SWCHA
    eor     #$ff
    beq     .setDelay
    asl
    asl
.move:
    inc     delay
    bpl     .skipMove

    asl
    bpl     .skipUp
    dey
    bpl     .skipDown
    ldy     #NUM_OPTIONS-2
    BIT_W
.skipUp:
    bcc     .skipMove
    iny
    cpy     #NUM_OPTIONS
    bcc     .skipDown
    ldy     #0
.skipDown:

; moved, restart scrolling...:
    lda     #0
    sta     colScroll
; ...and reset delay:
    sty     option
    ldx     #$80-DELAY
.setDelay:
    stx     delay               ; x = $82 or $80-DELAY
.skipMove:

;*** check for start of option ***
    lsr     SWCHB               ; SELECT switch
    bcc     .pressed
    lda     SWCHA               ; paddles fire buttons
    asl
    asl
    asl
    asl
    and     INPT4               ; left joystick fire button
    bpl     .pressed
    bit     switch              ; switch released?
    bpl     .skipStart
;---------------------------------------------------------------
; *** start game: ***
    lda     option
    cmp     #MODE_3ATHLON       ; 3-Athlon?
    bcc     .resetScore
    bne     .skipResetScore
    lda     #$80                ; start with Splatform
    sta     option
.resetScore
    ldy     #0
    sty     score
    sty     score+1
    sty     score+2
.skipResetScore:

    and     #$0f
    tay
    ldx     #5-1
.loopPtr:
    lda     JmpTbl,y
    sta     startVec,x
    iny
    iny
    iny
    dex
    bpl     .loopPtr
    jmp     (startVec)

Reset:
    jmp     (resetVec)    ; variable Reset vector

Splat_Start = $f000
Splat_Reset = $f002
Splat_Score = $cb;$c5
Down_Start  = $f40c+1
Down_Reset  = $f784+1
Down_Score  = $c4
Cave_Start  = $f7e1+1
Cave_Reset  = $f7e3+1
Cave_Score  = $d9;$9d

JmpTbl:
    .byte   <Splat_Score, <Down_Score, <Cave_Score
    .byte   >Splat_Reset, >Down_Reset, >Cave_Reset
    .byte   <Splat_Reset, <Down_Reset, <Cave_Reset
    .byte   >Splat_Start, >Down_Start, >Cave_Start
    .byte   <Splat_Start, <Down_Start, <Cave_Start

;    .word   $f000, $f002
;    .byte   $c5
;    .word   $f40c, $f784
;    .byte   $c4
;    .word   $f7e1, $f7e3
;    .byte   $9d
;---------------------------------------------------------------

.pressed:
    sec
    ror     switch              ; switch pressed! (bit7=1)
.skipStart:

.waitOverScan:
    lda     INTIM
    bne     .waitOverScan
; OverScan
    jmp     MainLoop

FREE SET 0

.endCode:

;===============================================================================
; R O M - T A B L E S
;===============================================================================

    ORG $fe73

FREE SET FREE + . - .endCode

Splatform0:
    .byte   %10001101
    .byte   %01110101
    .byte   %11110101
    .byte   %11110101
    .byte   %11110101
    .byte   %10001100
    .byte   %01111101
    .byte   %01111101
    .byte   %01111101
    .byte   %01110101
    .byte   %10001100
Splatform1:
    .byte   %11100001
    .byte   %11101111
    .byte   %11101111
    .byte   %11101111
    .byte   %11101111
    .byte   %01101111
    .byte   %10101111
    .byte   %10101111
    .byte   %10101111
    .byte   %10101111
    .byte   %01101111
Splatform2:
    .byte   %01101101
    .byte   %01101101
    .byte   %01101101
    .byte   %01101101
    .byte   %01101101
    .byte   %00001101
    .byte   %01101101
    .byte   %01101101
    .byte   %01101101
    .byte   %01101101
    .byte   %10011000
Splatform3:
    .byte   %10111111
    .byte   %10111110
    .byte   %10111110
    .byte   %10111101
    .byte   %10111100
    .byte   %10001100
    .byte   %10111100
    .byte   %10111100
    .byte   %10111110
    .byte   %10111110
    .byte   %10000111
Splatform4:
    .byte   %00011101
    .byte   %00001101
    .byte   %11101101
    .byte   %00010101
    .byte   %00000101
    .byte   %00000100
    .byte   %10100101
    .byte   %10100101
    .byte   %10101101
    .byte   %00001101
    .byte   %00011100
Splatform5:
    .byte   %10101110
    .byte   %10101110
    .byte   %10101110
    .byte   %10101110
    .byte   %10101110
    .byte   %01101010
    .byte   %10101010
    .byte   %10100100
    .byte   %10100100
    .byte   %10101110
    .byte   %01101110

CrashNDive0:
    .byte   %10011011
    .byte   %01101011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111000
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111000
    .byte   %01101111
    .byte   %10011111
CrashNDive1:
    .byte   %01011011
    .byte   %01011010
    .byte   %01011011
    .byte   %01000011
    .byte   %11011011
    .byte   %01011010
    .byte   %01100110
    .byte   %01111110
    .byte   %11111111
    .byte   %11111111
    .byte   %11111111
CrashNDive2:
    .byte   %00110110
    .byte   %11010110
    .byte   %11010110
    .byte   %11010110
    .byte   %00110110
    .byte   %11110000
    .byte   %11110110
    .byte   %11010110
    .byte   %00110110
    .byte   %11110110
    .byte   %11111110
CrashNDive3:
    .byte   %11011011
    .byte   %11011011
    .byte   %11011011
    .byte   %11011011
    .byte   %11011011
    .byte   %11011011
    .byte   %11000111
    .byte   %11111111
    .byte   %10111101
    .byte   %10111101
    .byte   %10111101
CrashNDive4:
    .byte   %00011011
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101010
    .byte   %01101011
    .byte   %00011111
CrashNDive5:
    .byte   %01110000
    .byte   %10110111
    .byte   %11010111
    .byte   %11010011
    .byte   %11010111
    .byte   %11010111
    .byte   %11010001
    .byte   %11011111
    .byte   %11111111
    .byte   %11111111
    .byte   %11111111

PtrTbl:
    .byte   >Splatform0
    .byte   <Splatform1, <Splatform3, <Splatform5, <Splatform0, <Splatform2, <Splatform4
  IF NTSC_COL
    .byte   $cf
  ELSE
    .byte   $5f
  ENDIF
    .byte   >CrashNDive0
    .byte   <CrashNDive1, <CrashNDive3, <CrashNDive5, <CrashNDive0, <CrashNDive2, <CrashNDive4
  IF NTSC_COL
    .byte   $4f
  ELSE
    .byte   $6f
  ENDIF
    .byte   >Cave0
    .byte   <Cave1, <Cave3, <Cave5, <Cave0, <Cave2, <Cave4
  IF NTSC_COL
    .byte   $8f
  ELSE
    .byte   $df
  ENDIF
    .byte   >Triathlon0
    .byte   <Triathlon1, <Triathlon3, <Triathlon5, <Triathlon0, <Triathlon2, <Triathlon4
  IF NTSC_COL
    .byte   $1f
  ELSE
    .byte   $2f
  ENDIF

AddTbl:
    .byte   255,154,104, 79, 64, 54, 48
    .byte    43, 40, 37, 35, 34, 33, 32, 32

  IF NTSC_TIM
TH  = 9
  ELSE
TH  = 13
  ENDIF

DelayTbl:
    .byte   24+TH, 22+TH, 19+TH, 16+TH, 14+TH, 11+TH, 9+TH
    .byte    7+TH,  5+TH,  3+TH,  2+TH,  1+TH,  1+TH
    .byte    0+TH,  0+TH

ColTbl:
  IF NTSC_COL
    .byte   $f2, $f4, $f6, $f8, $fa, $fc, $fe, $0e
    .byte   $fe, $fc, $fa, $f8, $f6, $f4, $f2, $f0
    .byte   $f2, $f4, $f6, $f8, $fa, $fc, $fe, $0e, $fe, $fc
  ELSE
    .byte   $f4, $f6, $f8, $fa, $fc, $fe, $fc
    .byte   $fa, $f8, $f6, $f4, $f2, $f0, $f2
    .byte   $f4, $f6, $f8, $fa, $fc, $fe, $fc, $fa, $f8, $f6
  ENDIF

TitlePat0L:
    .byte   %11110000
    .byte   %10000000
    .byte   %10000000
    .byte   %11110000
    .byte   %00010000
    .byte   %00010000
;    .byte   %11110000
TitlePat0R:
    .byte   %11110000
    .byte   %10000000
    .byte   %10000000
    .byte   %11000000
    .byte   %11000000
    .byte   %11000000
    .byte   %11110000
TitlePat1L:
    .byte   %10111111
    .byte   %10110101
    .byte   %10110101
    .byte   %10110101
    .byte   %00100101
    .byte   %00100001
    .byte   %10100001
TitlePat2L:
    .byte   %10111110
    .byte   %10100010
    .byte   %10100010
    .byte   %10110010
    .byte   %10110010
    .byte   %10110010
    .byte   %10111110
TitlePat1R:
    .byte   %01100001
    .byte   %01100000
    .byte   %01100000
    .byte   %01111101
    .byte   %01000101
    .byte   %01000101
    .byte   %01111101
TitlePat2R:
    .byte   %01001111
    .byte   %00001100
    .byte   %01001100
    .byte   %11001111
    .byte   %11000000
    .byte   %11000000
    .byte   %11001111

Cave0:
    .byte   %11111000
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11111000
Cave1:
    .byte   %11100110
    .byte   %01100110
    .byte   %11100110
    .byte   %11100110
    .byte   %11100110
    .byte   %11100000
    .byte   %11100110
    .byte   %11100110
    .byte   %11100110
    .byte   %01100110
    .byte   %11110001
Cave2:
    .byte   %11110111
    .byte   %11101011
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
    .byte   %11001101
Cave3:
    .byte   %10000011
    .byte   %10011111
    .byte   %10011111
    .byte   %10011111
    .byte   %10011111
    .byte   %10000111
    .byte   %10011111
    .byte   %10011111
    .byte   %10011111
    .byte   %10011111
    .byte   %10000011
Cave4:
    .byte   %10000110
    .byte   %11001110
    .byte   %11001110
    .byte   %11001110
    .byte   %11001110
    .byte   %11001110
    .byte   %11001110
    .byte   %11001110
    .byte   %10001110
    .byte   %11001110
    .byte   %11101110
Cave5:
    .byte   %01101111
    .byte   %01011111
    .byte   %00111111
    .byte   %00111111
    .byte   %01011111
    .byte   %01101111
    .byte   %01111111
    .byte   %01111111
    .byte   %01111111
    .byte   %01111111
    .byte   %01111111

Triathlon0:
    .byte   %00000011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11110011
    .byte   %11000011
    .byte   %11110111
    .byte   %11110111
    .byte   %11110111
    .byte   %11110111
    .byte   %10000111
Triathlon1:
    .byte   %11111001
    .byte   %11111001
    .byte   %11111001
    .byte   %11111001
    .byte   %11111001
    .byte   %00011000
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
    .byte   %11111100
Triathlon2:
    .byte   %10111001
    .byte   %10111001
    .byte   %10111001
    .byte   %10111001
    .byte   %10111001
    .byte   %00111001
    .byte   %10111011
    .byte   %10111011
    .byte   %10111011
    .byte   %10111011
    .byte   %00100000
Triathlon3:
    .byte   %10011010
    .byte   %10011010
    .byte   %10011010
    .byte   %10011010
    .byte   %10011010
    .byte   %10000010
    .byte   %10111011
    .byte   %10111011
    .byte   %10111011
    .byte   %10111011
    .byte   %10111011
Triathlon4:
    .byte   %00001000
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111011
    .byte   %01111000
Triathlon5:
    .byte   %00100110
    .byte   %10100110
    .byte   %10100110
    .byte   %10100110
    .byte   %10100110
    .byte   %00100110
    .byte   %00101110
    .byte   %00101110
    .byte   %00101110
    .byte   %00101110
    .byte   %00100000


;    .byte   " SWOOPS! v0.16 (C) 2005, Thomas Jentzsch "

FREE SET FREE + $fffc - .

    org $fffc, 0
    .word   Start
    .word   Reset

    ECHO "*** Free ", FREE, " bytes ***"
    ECHO "Select:", Select