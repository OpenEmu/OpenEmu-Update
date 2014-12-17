; ***  C R A S H   ' N   D I V E  ***
;             WIP title ;-)

; Copyright 2004, Thomas Jentzsch
; Version 1.00

; free: 1 byte(s)

;*** some ideas: ***
;+ minus points
;  + each new platform
;  x each time unit
;+ bonus points for blue platform
;+ minus points for magenta platform
;+ high score
;+ game over when points < 0
;+ gravity depends on level
;x platform distances depending on level (smaller/larger?)


;*** technical stuff: ***
;x two random numbers for scrolling up
;+ largw platform which allows scrolling back up
;+ gravity and dynamic friction, resulting into maximum speed
;x animations for crashed platforms ? (thinner, different width, expanding hole, flash colors...)
;+ collisions detected by software


;*** additional space savers: ***
;+ thinner platforms (2 rows, 5 pixel)
;+ all platforms same width
;+ no lives
;x fixed platform distances


;*** TODOs: ***
;x correct pfHeightLst when UP
;+ kernel simplyfied (-~40 bytes!)
;+ speeds (gravity, friction)
;+ controls:
;  x joystick
;  + paddle
;+ collisions
;+ sounds
;+ platform generation
;+ platform disabling (platform height = 0)
;+ scoring
;  + always positive scores possible (requires sequences scoring)
;  + points depending on level (positive AND negative!)
;+ gameplay
;  x end of level (continuous)
;  + death (<0 points, malus color?)
;  + new level
;  o wall gradients (not perfect, but ok)
;  + wall color (depending on level)
;x moving platforms
;+ heightLst + 3
;+ start game
;+ game over:
;  + disable Toto (black color)
;  + show scores
;  + game over sound
;+ restart (don't reset highscore)
;+ high score
;+ optimize kernel for space (BIT_W, WSYNC)
;  + exit Kernel
;+ optimize pfHeightList
;+ fixed NextRandom
;+ limit level (0..8)
;+ temporary high scores
;x start/restart via button
;+ different scoring sound
;+ score values (incl. bonus + malus)
;+ game over with malus color
;+ more initial gravity?
;+ timing problems in later levels (fixed by "emergency exit")
;+ game over at $9900 (not $8000)
;x random mode switchable (no space)


    processor 6502
    include vcs.h


;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

MULTI_GAME      = 1

VERSION         = $0100         ; unused

  IF MULTI_GAME
BASE_ADR        = $f400
  ELSE
BASE_ADR        = $f800
  ENDIF

DEBUG           = 1

NTSC_TIM        = 0             ; (+-0) 0 = PAL-50
NTSC_COL        = 0             ; (+-0) 0 = PAL colors

; *** feature switches (may not work anymore): ***
LIVES           = 0             ; ( +8)
PADDLE          = 1             ; ( -3) use paddle
DEJITTER        = 1             ; ( +6) correct paddle jitter
PATTERN         = 0             ; (+29)
SLIM_SCORE      = 0             ; (  0)
RANDOM          = 1             ; ( +2) random platform generation
BRAKE           = 0             ; (+11)


;===============================================================================
; C O N S T A N T S
;===============================================================================

SCW             = 160                   ; screen width

DIGIT_HEIGHT    = 9-4

KERNEL_H        = 184+3+1
TOTO_H          = 12

PF_H            = 6                     ; platform row height
NUM_ROWS        = 2                     ; maximum number of rows/platform

MIN_DY          = 40                    ; minimal vertical platform distance

NUM_BLOCKS      = 10

MIN_Y           = TOTO_H  +5 +12        ; minimum top position of Toto
MAX_Y           = KERNEL_H-4 -12        ; maximum bottom position of Toto

MAX_LEVEL       = 8

WHITE           = $00
  IF NTSC_COL
YELLOW          = $10
ORANGE          = $30
RED             = $40
MAGENTA         = $50
BLUE            = $80
GREEN           = $c0
  ELSE
YELLOW          = $20
ORANGE          = $40
RED             = $60
MAGENTA         = $80
BLUE            = $b0
GREEN           = $50
  ENDIF

TOTO_COL        = YELLOW |$c

SCORE_COLOR     = WHITE  |$a
TMPSCORE_COLOR  = ORANGE |$a
HISCORE_COLOR   = RED    |$6

NEUTRAL_COL     = WHITE  |$e
SCORE1_COL      = GREEN  |$e
SCORE2_COL      = YELLOW |$e
SCORE3_COL      = ORANGE |$e
MALUS_COL       = MAGENTA|$e
BONUS_COL       = BLUE   |$e

RAND_EOR_8      = $b4                   ; $b2; $e7; $c3
;RAND_SEED       = $-1                   ; (unused?)

  IF NTSC_TIM
GRAVITY         = 5                     ; 2
  ELSE
GRAVITY         = 5+1
  ENDIF


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

    SEG.U   variables
    ORG     $80

; *** variables cleared at start/reset of game: ***
level           .byte                   ; 0..8
level4          .byte                   ; level * 4
levelPF         .byte                   ; %00000000..%11111111
cntPlatforms    .byte

; platform data:
pfLst           = .                     ; platform data list
xPosLst         ds NUM_BLOCKS           ; platform x-position
  IF PATTERN ;{
pfPatLst        ds NUM_BLOCKS           ; platform pattern
  ENDIF ;}
colorLst        ds NUM_BLOCKS           ; platform color
heightLst       ds NUM_BLOCKS           ; total height of platform block
pfHeightLst     ds NUM_BLOCKS           ; platform height
;pfTypeLst       ds NUM_BLOCKS
;nusizLst        ds NUM_BLOCKS

SIZE_PFLST      = . - pfLst

topRow          .byte                   ; index of top displayed platform

yTop            ds 2
yTopHi          = yTop
yTopLo          = yTop+1

ySpeed          ds 2
ySpeedHi        = ySpeed
ySpeedLo        = ySpeed+1

; wall animation:
wallSwitch      .byte
wallInc         .byte

sound           .byte
soundFreq       .byte

; scoring:
prevColorIdx    .byte

curRow          .byte                   ; index of current/bottom displayed platform
cxRow           .byte                   ; previous collision row

gameMode        .byte                   ; 00xxxxxx = stopped; 10xxxxxx = running; 01xxxxxx = running

; *** variables initialized at start/reset of game: ***
initVars        = .
random          .byte                   ; uses code byte for initialisation
levelLo         .byte

wallColTop      .byte
wallColBtm      .byte
colToto         .byte                   ; used for hiding Toto at end of game

yToto           ds 2
yTotoHi         = yToto
yTotoLo         = yToto+1

  IF LIVES ;{
lives           .byte
  ENDIF ;}

NUM_INIT        = . - initVars + 2

scoreLst        ds 6
score           = scoreLst
scoreHi         = score
scoreLo         = score+1

; *** variables cleared only at start of game: ***
scoreTmp        = scoreLst+2
scoreTmpHi      = scoreTmp
scoreTmpLo      = scoreTmp+1

scoreMax        = scoreLst+4
scoreMaxHi      = scoreMax
scoreMaxLo      = scoreMax+1

end_of_reset    = . - 2
end_of_start    = .

;*** uninitialized variables: ***
tmpVars         ds 9+4

scoreCnt        = tmpVars

frameCnt        .byte

saveHeight      .byte                   ; saved height of top platform block
saveHeight2     .byte                   ; saveHeight + 2

pointIdx        .byte

  IF PADDLE = 0
xToto           ds 2
xTotoHi         = xToto
xTotoLo         = xToto+1

xSpeed          ds 2
xSpeedHi        = xSpeed
xSpeedLo        = xSpeed+1
  ELSE
xToto           ds 1
xTotoHi         = xToto
  ENDIF

  IF PADDLE
paddle          .byte
   IF DEJITTER
paddleIdx       .byte
   ENDIF
  ENDIF

  ECHO "*** RAM: ", ., " ***"


;===============================================================================
; M A C R O S
;===============================================================================

DEBUG_BYTES SET 0

  MAC DEBUG_BRK
    IF DEBUG
DEBUG_BYTES SET DEBUG_BYTES + 1
      brk                         ;
    ENDIF
  ENDM

  MAC BIT_B
    .byte   $24
  ENDM

  MAC BIT_W
    .byte   $2c
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


;===============================================================================
; R O M - C O D E
;===============================================================================

    SEG     Bank0
    ORG     BASE_ADR+12+1

;---------------------------------------------------------------
Start SUBROUTINE
;---------------------------------------------------------------
; cart inserted:
    ldx     #end_of_start-1

;---------------------------------------------------------------
Reset:
;---------------------------------------------------------------
; RESET pressed:
    lda     #0
    txs
.clearLoop:
    tsx
    pha
    bne     .clearLoop

  IF MULTI_GAME
    ldx     #$ff-7
    txs
  ENDIF

    ldx     #NUM_INIT
.loopInit:
    lda     InitTbl-2,x
    sta     initVars-1,x
    dex
    bne     .loopInit

;---------------------------------------------------------------
;GameInit SUBROUTINE
;---------------------------------------------------------------

;    dec     levelPF
;    lda     #8
;    sta     level
;  IF LIVES
;    lda     #$55
;    sta     lives
;  ENDIF

  IF PADDLE = 0 ;{
    lda     #SCW/2-2
    sta     xTotoHi
  ENDIF ;}

; create first (invisible) platform:
    lda     #KERNEL_H-4+30  ; + PF_H*(NUM_ROWS-1)
    jsr     BackupOnly      ;       x=0!
    sta     yTopHi

;---------------------------------------------------------------
MainLoop:
;---------------------------------------------------------------
    cld
.waitTim:
    ldx     INTIM
    bpl     .waitTim

;---------------------------------------------------------------
;VerticalBlank SUBROUTINE
;---------------------------------------------------------------

  IF PADDLE
    lda     #%10000111
    sta     VBLANK
    asl                     ;       a = %00001110
  ELSE ;{
    lda     #%00001110
  ENDIF ;}
.loopVSync:
    sta     WSYNC
    sta     VSYNC
    sta     CTRLPF          ;       a = %00000001
    lsr
    bne     .loopVSync
  IF PADDLE
    sta     VBLANK          ;       a = %00000000
  ENDIF
  IF NTSC_TIM
    ldx     #44-6-5
  ELSE
    ldx     #44-6+32
  ENDIF
    stx     TIM64T
    inc     frameCnt
; VerticalBlank

;---------------------------------------------------------------
;GameCalc SUBROUTINE
;---------------------------------------------------------------

; game over?
    ldx     scoreHi             ;
    cpx     #$99
    bcc     .skipGameOver
    lsr     gameMode            ;       10 -> 01
    sta     scoreHi             ;       a=0!
    sta     colToto             ;       hide Toto
    lda     #$5f                ;       start game over sound
    sta     sound
.skipGameOver:

; *** sounds ***
    lax     sound
    beq     .skipSound
    asl
    beq     .skipSound
; make bouncing sound:
    ldy     #$0c
    txa
    adc     #$12                ;       C=0! (a=$1f..$13)
    bpl     .playBounce
; make platform scoring sound:
    lda     #11+1
    sbc     soundFreq           ;       C=0! ; a=1..11
.playBounce:
    dec     sound
    sty     AUDC0
    sta     AUDF0
.skipSound:
    stx     AUDV0

;; *** sounds ***
;    lax     sound
;    beq     .skipSound
;    dex
;    ldy     #$07
;    asl
;    beq     .skipSound
;    bmi     .playOver
;    ldy     #$0c
;    txa
;    bcc     .playBounce
;; make platform scoring sound:
;    lda     soundFreq
;    BIT_W
;.playOver:
;    ldx     #$0f
;    eor     #$0f                ;       a=5..15
;    BIT_W
;; make bouncing sound:
;.playBounce:
;    adc     #$13                ;       C=1!
;.setAudF0:
;    stx     AUDV0
;    sty     AUDC0
;    sta     AUDF0
;    dec     sound
;.skipSound:

; *** position score sprites: ***
  IF MULTI_GAME
XPosObject   = $f38d+1
XPosObject0  = XPosObject-2

    lda     #53+3*6-5+8-12        ;               dirty tweak to avoid additional HMCLR
    jsr     XPosObject0
  ELSE
   IF LIVES ;{
    lda     #53-16+3*6-2        ;               dirty tweak to avoid additional HMCLR
   ELSE ;}
    lda     #53+3*6-5-2         ;               dirty tweak to avoid additional HMCLR
   ENDIF
    inx
    stx     NUSIZ1              ;       %001
   IF LIVES ;{
    lda     #%011
    sta     NUSIZ0              ;       %011
    lda     #53+8+3*6
   ELSE ;}
    stx     NUSIZ0              ;       %001
    lda     #53+3*6-5+8-4
   ENDIF
    jsr     XPosObject
  ENDIF

; *** setup score colors and pointers: ***
; update high-scores:
    ldx     #$7c
.loopScore:
    lda     scoreLo-$7c,x
    sec                         ;           muss!
    sbc     scoreLo-$7a,x
    lda     scoreHi-$7c,x
    tay
    sbc     scoreHi-$7a,x
    bcc     .skipHigh
    lda     scoreLo-$7c,x
    sta     scoreLo-$7a,x
    sty     scoreHi-$7a,x
.skipHigh:
    inx
    inx
    bpl     .loopScore

  IF MULTI_GAME
    sta     HMCLR
    ldx     #1
    stx     NUSIZ1              ;       %001
    stx     NUSIZ0              ;       %001
    lda     #53+3*6-5+8-4
    jsr     XPosObject
  ENDIF

.waitTimBlank:
    ldy     INTIM
    bne     .waitTimBlank

; set colors and scores:
    ldx     #HISCORE_COLOR
    bit     gameMode            ;           game over?
    bmi     .gameRunning        ;            no
    ldy     #(scoreMax-score)
    bit     frameCnt            ;           game over, score switches...
    bvs     .setColor           ;           ...between current and high score
    ldy     #(scoreTmp-score)
    clc
.gameRunning:
    bcs     .setColor
    ldx     #SCORE_COLOR
.setColor:
    stx     COLUP0
    stx     COLUP1
; GameCalc

;---------------------------------------------------------------
DrawScreen SUBROUTINE
;---------------------------------------------------------------
.ptrScore       = tmpVars       ;..+7
.tmpY           = tmpVars+8+4
.blockHeight    = tmpVars+8+4
;---------------------------------------
.ptrToto        = tmpVars       ;..+1
.yToto          = tmpVars+4
.tmpColor       = tmpVars+5
.objDelay       = tmpVars+6


; *** setup score pointers: ***
    ldx     #4-1                ; 2         y=0,-2,-4!
  IF MULTI_GAME
    jsr     SetupScore
  ELSE
.loopScore:
    lda     #>Zero              ; 2
    sta     .ptrScore,x         ; 4
    sta     .ptrScore+6,x       ; 4
    dex                         ; 2
    sty     .tmpY               ; 3
    lda     score,y             ; 4
    pha                         ; 3
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     .ptrScore,x         ; 4
    pla                         ; 4
    and     #$0f                ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     .ptrScore+6,x       ; 4
    ldy     .tmpY               ; 3
    iny                         ; 2
    dex                         ; 2
    bpl     .loopScore          ; 2³
;total: 131
  ENDIF

;===============================================
; some very tricky coding here :-)
    lda     #%10011001
    sta     .blockHeight
    ldy     #DIGIT_HEIGHT
.nextBlock:
    dey
.contBlock:
    sta     WSYNC
;---------------------------------------
    lda     topRow              ; 3         +1 !!!
    sta     curRow              ; 3
    lda     wallColTop          ; 3
    sta     COLUPF              ; 3 = 12
  IF LIVES ;{
    lda     lives               ; 3
    sta     GRP0                ; 3         @22
    SLEEP   4                   ; 2
  ELSE ;}
;    dcp     (.ptrScore),y       ; 8                 = SLEEP 8
;    SLEEP   2                   ; 2
  ENDIF
    lda     (.ptrScore+8),y     ; 5
    sta     GRP1                ; 3         @20
    lax     (.ptrScore+6),y     ; 5
    lda     (.ptrScore+2),y     ; 5
    sta     GRP0                ; 3         @33
    lda     (.ptrScore+0),y     ; 5
    lsr     .blockHeight        ; 5
    sta     GRP0                ; 3         @46
    stx     GRP1                ; 3 = 37    @49
    bcs     .nextBlock          ; 2³
    bne     .contBlock          ; 2³=  4        (9 -> 4 possible)

    sty     COLUP1              ; 3
    sty     GRP0                ; 3 =  6    @59

    lda     xTotoHi             ; 3
    jsr     XPosObject0         ; 6 =  9    @68/@09

    lda     #$c0                ; 2             $c0
    sta     PF0                 ; 3
    lda     levelPF             ; 3
    sta     PF1                 ; 3 = 11

  IF MULTI_GAME
Toto = $f3e1+1

    lda     #>Toto
    sta     .ptrToto+1
  ENDIF
    lda     #TOTO_H+KERNEL_H-1  ; 2
;    sec
    sbc     yTotoHi             ; 3             C=1!
    sta     .yToto              ; 3
;    sec
    adc     #<Toto-KERNEL_H-2   ; 2             C=1!
  IF MULTI_GAME
    bit     ySpeedHi            ; 3
    bpl     .moveUp             ; 2²
    adc     #<TOTO_H+1          ; 2
.moveUp:
    sec
  ENDIF
    sta     .ptrToto            ; 3 = 13

    sty     NUSIZ0              ; 3
    dey                         ; 2
    sty     NUSIZ1              ; 3             quad width players
  IF PATTERN = 0
    sty     GRP1                ; 3
  ENDIF
    sta     HMCLR               ; 3 = 14

    lda     colToto             ; 3
    sta     COLUP0              ; 3

    ldy     #KERNEL_H           ; 2
    bne     .enterKernel        ; 3 = 11        x=0!

;=====================================================
Kernel:
.loopKernel:                     ;          @16/18
; *** draw platform: ***
    lda     pfHeightLst,x       ; 4
    sta     .objDelay           ; 3
    lda     colorLst,x          ; 4
    sta     .tmpColor           ; 3
  IF PATTERN ;{
    lda     pfPatLst,x          ; 4                     PF-pattern
    sta     GRP1                ; 3 = (7)
  ENDIF ;}
    lda     heightLst,x         ; 4
    tax                         ; 2 = 20
    jmp     .enterLoop          ; 3 = 23    @39/41

.loopY:                         ;           @47..58 (1st: 51/53)
    dex                         ; 2
    lda     (.ptrToto),y        ; 5
    sta     WSYNC               ; 3 = 13/14 @60..72 (1st: 64/67)
;---------------------------------------
    bcc     .skipDraw1          ; 2³
    sta     GRP0                ; 3
.skipDraw1:                     ;   =  3/5  @03/05

    cpy     wallSwitch          ; 3
    lda     wallColBtm          ; 3
    bcs     .skipChange         ; 2³
    sta     COLUPF              ; 3
.skipChange:                    ;   =  9/11 @12..16

    lda     .tmpColor           ; 3
    and     ColAndTbl,x         ; 4
    cpx     .objDelay           ; 3
    bcs     .skipPlatform       ; 2³
    sta     COLUP1              ; 3         @27..31
.skipPlatform:                  ;   = 13/15 @25..31

  IF PADDLE
   IF MULTI_GAME
    bit     INPT2               ; 3
   ELSE
    bit     INPT0               ; 3
   ENDIF
    bmi     .skipPaddle         ; 2³
    sty     paddle              ; 3
   IF DEJITTER
    stx     paddleIdx           ; 3                 used for paddle dejittering
   ENDIF
.skipPaddle:                    ;   =  6/11 @31..42
  ENDIF

    dey                         ; 2
    beq     .exitKernel         ; 2³=  4    @35..46

.enterLoop:                     ;                    (1st: 39/41)
    lda     #TOTO_H             ; 2
    dcp     .yToto              ; 5
    txa                         ; 2
    bne     .loopY              ; 2³= 11    @46..57  (1st: 50/52)

;;*** bottom platform row: ***
    bcc     .skipDraw2          ; 2³
    lax     (.ptrToto),y        ; 5
.skipDraw2:                     ;   =  3/7  @49..64

; update row counter:
    dec     curRow              ; 5
    sec                         ; 2
    dey                         ; 2
.enterKernel:
    sta     WSYNC               ; 3 = 12    @61..76
;---------------------------------------
; *** no object row, reposition next object: ***
    beq     .exitKernel         ; 2³
    stx     GRP0                ; 3         @05
    ldx     curRow              ; 3
    lda     xPosLst,x           ; 4 = 12    @12
.waitPos:
    sbc     #$0f                ; 2
    bcs     .waitPos            ; 2³
    eor     #$07                ; 2
    asl                         ; 2
    asl                         ; 2
    asl                         ; 2
    asl                         ; 2
    sta     RESP1               ; 3 = 17    @29..54
    sta     HMP1                ; 3
    lda     #TOTO_H             ; 2
    dcp     .yToto              ; 5
    sta     WSYNC               ; 3 = 13    @42..67
;---------------------------------------
    sta     HMOVE               ; 3 =  3

    lda     (.ptrToto),y        ; 5
    bcc     .skipDraw0          ; 2³
    sta     GRP0                ; 3 =  8/10 @11/13
.skipDraw0:

    dey                         ; 2
    bne     .loopKernel         ; 2³=  4    @15/17
;---------------------------------------------------------------
.exitKernel:
    sta     WSYNC               ; 3
;---------------------------------------
    sty     PF0                 ;                   y = 0!
    sty     PF1
    sty     GRP1

---------------------------------------------------------------
OverScan SUBROUTINE
;---------------------------------------------------------------
.dY         = tmpVars+8+4       ;       .blockHeight = 0!

  IF NTSC_TIM
    lda     #36-4-2-1+4
  ELSE
    lda     #36-4+27-2-1
  ENDIF
    sta     TIM64T

; *** handle switches: ***
  IF MULTI_GAME
; multi-game
; + RESET & SELECT are disabled
; + game over jumps to menu

Select  = $fcb6+1
option  = $fc

    lda     SWCHB
    lsr
    bcc     .doReset
    lsr
    bcs     .skipSelect
    jmp     Select

.doReset:
    bit     option
    bmi     .skipSelect
    ldx     #end_of_reset-1
    jmp     Reset               ;       TODO: try to remove jmp

.skipSelect:
  ELSE
    lsr     SWCHB
    bcs     .skipReset
    ldx     #end_of_reset-1
    jmp     Reset               ;       TODO: try to remove jmp

.skipReset:
  ENDIF
    bit     gameMode            ;       game running?
    bmi     .runGame            ;        yes, continue
    bvs     .skipGame           ;        game over, skip button
 IF MULTI_GAME
    lda     #$08                ;       right paddle
    bit     SWCHA
    bne     .skipGame
 ELSE
  IF PADDLE
    bit     SWCHA
  ELSE ;{
    bit     INPT4
  ENDIF ;}
    bmi     .skipGame
 ENDIF
    ror     gameMode            ;       start game
.runGame:


; *** accellerate Toto vertically: ***
; 1. gravity (always down):
    ldy     #-1
    lda     #-GRAVITY           ;       y = -1!
;    sec
    sbc     level
    ldx     #ySpeed
    jsr     Add16

; 2: friction (opposite to direction; the faster, the more):
  IF BRAKE ;{
; check fire button
    bit     SWCHA
    bmi     .skipButton
    sty     prevColorIdx
    ldy     #-30
.skipButton:
    sty     tmpVars

.loopFriction:
    ldy     #-1
  ENDIF ;}
    eor     #$ff                ;       a = ySpeedHi
    bmi     .posSpeed
    clc
    iny
.posSpeed:                      ;       1/256
    jsr     Add16_C             ;32     x = #ySpeed
  IF BRAKE ;{
    inc     tmpVars
    bne     .loopFriction
  ENDIF ;}

; *** move Toto and platforms ***
; a = ySpeedHi
MoveThem:
; Toto moving up or down?
    ldy     yTotoHi
    cpy     #MAX_Y
    tay
    bmi     .contMove
    ldy     #MIN_Y-1
    cpy     yTotoHi
.contMove:

    ldx     ySpeedLo
    bcs     .skipDouble
; 1a. move Toto in opposite direction:
    eor     #$ff                ;       a = ySpeedHi!
    tay
    txa
    eor     #$ff
    ldx     #yToto
    jsr     Add16

; 1b. double platform scroll speed:
    lda     ySpeedLo
    asl
    tax
    lda     ySpeedHi
    rol
.skipDouble:
; 2. scroll platforms:
    tay
    txa
    ldx     #yTop
    jsr     Add16

    ldx     topRow
    tay

    sec
    sbc     heightLst,x             ;           calculate difference
    sta     .dY

    tya
    sec
    sbc     saveHeight2
    bcc     .setHeight

    bit     ySpeedHi
    bmi     .moveUp
;---------------------------------------
; platforms moving down:
    tay
; scroll one platform block down:
    inc     topRow
    jsr     RestoreAndBackup
    bcc     .setYTop                ;           height = overflow
;    DEBUG_BRK
;---------------------------------------
; platforms moving up:
.moveUp:
; scroll one platform block up:
    dec     topRow
    jsr     RestoreAndBackup
; correct top row value:
    tya
;    clc
    adc     saveHeight2
    tay                             ;           height += 3 - underflow
;---------------------------------------
; set top row value:
.setYTop:
    sty     yTopHi
.setHeight:
    sty     heightLst,x             ;           store new height

.skipGame:

; *** move walls: ***
    lda     wallSwitch
    sec
    sbc     .dY
    tax
    sbc     #KERNEL_H
    bcc     .skipSwap
    bit     .dY
    bmi     .posSpeedW
    adc     #<(KERNEL_H*2-1)
.posSpeedW:
    tax
    lda     wallColTop
    cmp     wallColBtm
    bcs     .contColor
    lsr     wallInc
    bcc     .contColor
    adc     #4-1
; update level:
    dec     levelLo
    bpl     .contColor
    ldy     #7                      ;           == MAX_LEVEL-1
    sty     levelLo
    cpy     level                   ;           limit level (0..8)
    bcc     .contColor
    inc     level
    ror     levelPF                 ;
.contColor:
    ldy     wallColBtm
    sty     wallColTop
    sta     wallColBtm
.skipSwap:
    stx     wallSwitch

; *** move Toto horizontally: ***
  IF PADDLE
; check paddle value:
   IF DEJITTER
    lda     paddleIdx
    beq     .skipPaddle
   ENDIF
    lda     level
    asl
    asl
    sta     level4
  IF MULTI_GAME
    adc     #17-4+3
  ELSE
    adc     #17-4
  ENDIF
    cmp     paddle
    bcs     .outOfBounds
    eor     #$ff
  IF MULTI_GAME
    adc     #SCW-12+6
  ELSE
    adc     #SCW-12
  ENDIF
    cmp     paddle
    bcc     .outOfBounds
    lda     paddle
.outOfBounds:
    sta     xTotoHi
.skipPaddle:
  ELSE ;{
    lda     SWCHA
    bmi     .skipLeft
    inc     xTotoHi
.skipLeft:
    asl
    bmi     .skipRight
    dec     xTotoHi
.skipRight:
  ENDIF ;}

; prepare scoring multiplier:
    ldx     level
    stx     scoreCnt

; ***** handle collisions *****
; based on NEXT frame!
  IF PATTERN ;{
.width      = tmpVars+1
  ENDIF ;}

; *** check for collision ***
; 1. vertical collision?
; calculate collision block:
    ldx     topRow
    lda     #KERNEL_H+3
    sec
    sbc     yTotoHi
.loopSum
    sbc     #2                  ;
    bcc     .exitSum
    sbc     heightLst,x
    dex
    bcs     .loopSum
.exitSum:
    adc     pfHeightLst+1,x
    bcs     .incBlock
    adc     #TOTO_H-4           ;
    bcc     .skipInc
.incBlock:
    inx
.skipInc:

    cpx     cxRow
    inx
    stx     cxRow
    bcc     .skipCollision

; 2. horizontal collision?
  IF PATTERN ;{
; TODO?: store width in RAM
    ldy     #1
.loopWidth:
    iny
    asl
    bne     .loopWidth
    tya
    asl
    asl
    sta     .width
  ENDIF ;}
    lda     xPosLst-1,x
  IF MULTI_GAME
    adc     #10+3               ;       C=0!
  ELSE
    adc     #10                 ;       C=0!
  ENDIF
    sbc     xTotoHi             ;       C=0!
  IF PATTERN ;{
    adc     .width
  ELSE ;}
    adc     #4*9
  ENDIF
    lda     pfHeightLst-1,x
    beq     .skipCollision      ;       skip disabled platforms
    bcs     DoCollision         ;       at least two pixel must overlap!
.skipCollision:

; check for new platform:
    lda     curRow
    bne     SkipNewPF

;---------------------------------------------------------------
NewPlatform SUBROUTINE
;---------------------------------------------------------------
; generate new platform at bottom

; *** create new platform at/below bottom: ***
  IF PATTERN ;{
; 1. platform width (3..8)
    jsr     NextRandom
    and     #$07
    tax
    lda     PlatformTbl,x
    sta     pfPatLst
;---------------------------------------
; 2. platform x-position (also depending on width)
    txa
    asl
    asl
    sta     .tmpMaxX
  ENDIF ;}
.nextRandom:
    lda     #17                 ; 3
    cmp     INTIM               ; 4
    bcs     SkipNewPF           ; 2³    "emergency exit"

    brk                         ;33     jsr NextRandom
    lsr                         ; 2
    sec                         ; 2     = +1!
;    adc     #1
    adc     level4              ; 3     left offset
    tay                         ; 2
  IF PATTERN ;{
    adc     .tmpMaxX            ;       0..28
    adc     .lvlOfs
    cmp     #SCW-29             ;       131
  ELSE ;}
    adc     level4              ; 3     right offset
    cmp     #SCW-29-7*4-13      ; 2
  ENDIF
    bcs     .nextRandom         ; 2³= 58

; *** game progress (depends on number of platforms): ***
    dec     cntPlatforms
    bpl     .skipIncWall
    lda     #$05                ;       TODO: adjust
    sta     cntPlatforms
    inc     wallInc
.skipIncWall:

; *** move platform data: ***
    ldx     #SIZE_PFLST-1       ; 2     = NUM_BLOCKS*4-1 (10*4-1=39)
.loopMove:
    lda     pfLst-1,x           ; 4
    sta     pfLst,x             ; 4
    dex                         ; 2
    bne     .loopMove           ; 2³= 12/13
;total: 508

    sty     xPosLst             ;       a=1..89

    inc     topRow              ; 5
    inc     cxRow               ; 5

;---------------------------------------
; 3. platform type and color:
    brk                         ;       jsr NextRandom
    ldx     #BONUS_COL          ;       chance: 1/256
    sec
    ror
    adc     level               ;
    beq     .setColor
    ldx     #MALUS_COL          ;       chance: (level*2-1)/256
    stx     colorLst
    bcs     .setHeight1
    and     #$07
    tay
    ldx     ColorTbl+2,y        ;
.setColor:
    stx     colorLst

;---------------------------------------
; 4. platform height (5/10):
    brk                         ;       jsr NextRandom
    cmp     #256/12
.setHeight1:
    lda     #PF_H*2
    bcc     .setHeight
    lsr
.setHeight:
    sta     pfHeightLst

; 5. set platform distance:
    brk                         ;       jsr NextRandom
    lsr
    adc     #MIN_DY
    sta     heightLst           ;       PF_H * NUM_ROWS <= a <= §f7!

; decrease score:
    lda     #$96                ; 2     -4
; NewPlatform
;    rts
; ~731 since INTIM

;---------------------------------------------------------------
Add16_ScoreNeg:
;---------------------------------------------------------------
    ldy     #$99                ; 2 =  2
Add16_Score:
; add/sub points * level to score:
    sed                         ; 2
    ldx     #score              ; 2 =  4
.loopAdd:
    pha                         ; 3
; 16 bit addition:
Add16:
    clc                         ; 2
Add16_C:
    adc     $01,x               ; 4
    sta     $01,x               ; 4
    tya                         ; 2
    adc     $00,x               ; 4
    sta     $00,x               ; 4

    cpx     #score              ; 2
    bne     Exit                ; 2³
; Add16
    pla                         ; 4
    dec     scoreCnt            ; 5
    bpl     .loopAdd            ; 2³= 38 (39*9=351)
    BIT_W                       ; 1
KillGame:
    sty     scoreHi             ; 3
SkipNewPF:
    jmp     MainLoop            ; 3
; OverScan


;---------------------------------------------------------------
DoCollision SUBROUTINE
;---------------------------------------------------------------
    ldy     #-1                 ;       used below!

; *** check for crash height ***
    bit     ySpeedHi            ;       a=pfHeightLst-1,x!
    bmi     .normalCrash
    lda     #PF_H               ;       crash from below always removes whole platform
.normalCrash:
    sbc     #PF_H               ;       C=1!
    sta     pfHeightLst-1,x     ;       reduce platform height, zero?
    beq     .doCrash            ;        yes, crash

; *** bounce from platform ***
; 1. reverse direction:
    tya                         ;       y=-1!
    eor     ySpeedLo
    sta     ySpeedLo
    tya
    eor     ySpeedHi
    sta     ySpeedHi

; 2. start bouncing sound:
    ldx     #$0d
    stx     sound

; 3. move into opposite direction:
;    lda     ySpeedHi
    jmp     MoveThem            ;       TODO: remove jmp?
;---------------------------------------

; *** crash through platform ***
.doCrash:
; a=0; C=1!

; *** scoring sound: ***
    lda     #$8f
    sta     sound

    lda     colorLst-1,x        ;       used below (x gets overwritten)

; *** set new, reduced speed: ***
    ldx     ySpeedHi
    dex
    bpl     .posSpeed2
    inx
    inx
    bmi     .posSpeed2          ;       overflow?
    ldx     #0                  ;        yes, reset ySpeed
    stx     ySpeedLo
.posSpeed2:
    stx     ySpeedHi

;; *** score: ***
; find color index:
.loopColors:                    ;       y=-1!
    iny
    cmp     ColorTbl,y
    bne     .loopColors
    lda     #10                 ;       bonus score + sound index
    dey
    bmi     .setFreqA           ;       BONUS_COL!
    dey
    bmi     KillGame            ;       MALUS_COL!
    beq     .setFreqY           ;       NEUTRAL_COL!
; compare with previous color
    tya
    cmp     prevColorIdx
    sta     prevColorIdx
    bne     .skipAddIdx         ;       a=1..3 (start new sequence)
    lda     pointIdx
    cmp     #2*3 + 1
    bcs     .skipAddIdx
    adc     #3
.skipAddIdx:
    sta     pointIdx            ;       y=1..9
.setFreqA:
    tay
.setFreqY:
    sty     soundFreq           ;       y=0..10
    lda     ScoreTbl,y
.addScore:
    ldy     #$00
    beq     Add16_Score

;---------------------------------------------------------------
RestoreAndBackup SUBROUTINE
;---------------------------------------------------------------
; restore current height:
    lda     saveHeight          ;       x = current topRow
BackupOnly:
    sta     heightLst,x
; backup new height:
    ldx     topRow
    lda     heightLst,x
    sta     saveHeight
; special value for scrolling up:
    clc
    adc     #2                  ;
    sta     saveHeight2
Exit:                           ;       used by Add16
    rts
; RestoreAndBackup


;---------------------------------------------------------------
NextRandom SUBROUTINE
;---------------------------------------------------------------
;    tsx                     ; 2         adjust return address
;    dec     $02,x           ; 6
  IF MULTI_GAME
    dec     $fe-7
  ELSE
    dec     $fe             ; 5         adjust return address (fixed!)
  ENDIF

    lda     random          ; 3
    lsr                     ; 2
    bcc     .skipEor        ; 2³
    eor     #RAND_EOR_8     ; 2
.skipEor:
    sta     random          ; 3
  IF RANDOM
;    bit     compMode        ; 3
;    bvc     .skipRandom     ; 2³
;    eor     yTotoLo         ; 3
    eor     frameCnt        ; 3
;.skipRandom:
  ENDIF
    rti                     ; 6
; total: 25/26
; NextRandom


  IF MULTI_GAME
SetupScore SUBROUTINE
.ptrScore       = tmpVars       ;..+9
.tmpY           = tmpVars+12

.loopScore:
    lda     #>Zero              ; 3
    sta     .ptrScore,x         ; 4
    sta     .ptrScore+6,x       ; 4
    dex                         ; 2
    sty     .tmpY               ; 3
    lda     score,y             ; 4
    pha                         ; 3
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     .ptrScore,x         ; 4
    pla                         ; 4
    and     #$0f                ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     .ptrScore+6,x       ; 4
    ldy     .tmpY               ; 3
    iny                         ; 2
    dex                         ; 2
    bpl     .loopScore          ; 2³
;total: 131
    rts
  ENDIF

  IF MULTI_GAME = 0
;---------------------------------------------------------------
XPosObject0 SUBROUTINE
;---------------------------------------------------------------
    ldx     #0              ; 2
XPosObject:
    sta     WSYNC           ; 3
;---------------------------------------
    sec                     ; 2
WaitObject:
    sbc     #$0f            ; 2
    bcs     WaitObject      ; 2³

  CHECKPAGE WaitObject

    eor     #$07            ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    sta     HMP0,x          ; 4
    sta     RESP0,x         ; 4     @24!
    sta     WSYNC
;---------------------------------------
    sta     HMOVE
    rts
; C=1
; XPosObject0
  ENDIF

;===============================================================================
; R O M - T A B L E S
;===============================================================================

FREE SET 0

InitTbl:
;    .byte   RAND_SEED       ; random = $60 (rts)
    .byte   7               ; levelLo
  IF LIVES ;{
    .byte   %01010101       ; lifes (4 lifes, only three are shown!)
  ENDIF ;}
    .byte   $20             ; wallColTop
    .byte   $22             ; wallColBtm
    .byte   TOTO_COL
    .byte   MAX_Y-70        ; yTotoHi  (MIN_DY = 40:-65; 60:-70: 100:-76)
    .byte   0               ; yTotoLo
    .byte   $03             ; scoreHi
;    .byte   $00             ; scoreLo (shared with ColAndTbl)

ColAndTbl: ;
    .byte   0               ; overlaps with scoreLo
    .byte   $f0, $f4, $f8, $fc, $fe
  REPEAT NUM_ROWS-1
    .byte   0
    .byte   $02, $04, $08, $0c, $0e
  REPEND

ScoreTbl:
    .byte   $00
;    .byte   $01,$02,$04     ; (1,2,9),(2,4,20),(4,8,44): +~3.56:-4
;    .byte   $02,$04,$08
;    .byte   $09,$20,$44
    .byte   $01,$02,$03     ; (1,2,9),(2,4,22),(3,6,48): +~3.49:-4
    .byte   $02,$04,$06
    .byte   $09,$22,$48
    .byte   $75

ColorTbl:
    .byte   BONUS_COL, MALUS_COL
    .byte   NEUTRAL_COL, SCORE1_COL, SCORE2_COL, SCORE3_COL
    .byte   SCORE1_COL,  SCORE1_COL, SCORE2_COL, SCORE1_COL

  IF MULTI_GAME
DigitTbl = $fb49+1
Zero     = $fb68+1
  ELSE
DigitTbl:
    .byte   #<Zero,  #<One,   #<Two,   #<Three, #<Four
    .byte   #<Five,  #<Six,   #<Seven, #<Eight, #<Nine

  IF SLIM_SCORE
One:
    .byte   %00000000
    .byte   %00000010
Seven:
    .byte   %00000000
    .byte   %00000010
Four:
    .byte   %00000000
    .byte   %00000010
Zero:
    .byte   %00111100
    .byte   %01000010
    .byte   %00000000
    .byte   %01000010
Three:
    .byte   %00111100
    .byte   %00000010
Nine:
    .byte   %00111100
    .byte   %00000010
Eight:
    .byte   %00111100
    .byte   %01000010
Six:
    .byte   %00111100
    .byte   %01000010
Two:
    .byte   %00111100
    .byte   %01000000
Five:
    .byte   %00111100
    .byte   %00000010
    .byte   %00111100
    .byte   %01000000
    .byte   %00111100
  ELSE
One:
    .byte   %00000000
    .byte   %00001100
Seven:
    .byte   %00000000
    .byte   %00001100
Four:
    .byte   %00000000
    .byte   %00001100
Zero:
    .byte   %01111000
    .byte   %11001100
    .byte   %00000000
    .byte   %11001100
Three:
    .byte   %01111000
    .byte   %00001100
Nine:
    .byte   %01111000
    .byte   %00001100
Eight:
    .byte   %01111000
    .byte   %11001100
Six:
    .byte   %01111000
    .byte   %11001100
Two:
    .byte   %01111000
    .byte   %11000000
Five:
    .byte   %01111000
    .byte   %00001100
    .byte   %01111000
    .byte   %11000000
    .byte   %01111000
  ENDIF

  CHECKPAGE One
  ENDIF

;PlatformTbl:
;    .byte   %10000000
;    .byte   %11000000
;    .byte   %11100000
;    .byte   %11110000
;    .byte   %11111000
;    .byte   %11111100
;    .byte   %11111110
;    .byte   %11111111

DataEnd:
;    ORG $fffc - TOTO_H
  IF MULTI_GAME
;    ORG BASE_ADR + $3fc - (TOTO_H+1)+9
  ELSE
    ORG BASE_ADR + $3fc - (TOTO_H+1)
  ENDIF

FREE SET FREE + . - DataEnd + DEBUG_BYTES

  IF MULTI_GAME
;    .byte 0
  ELSE
Toto:
    .byte   0
    .byte   %00111000
    .byte   %01111100
    .byte   %01111100
    .byte   %11000110
    .byte   %10111010
    .byte   %11111110
    .byte   %11111110
    .byte   %11010110
    .byte   %11010110
    .byte   %01111100
    .byte   %01111100
    .byte   %00111000
  ENDIF

    ECHO "*** Free ", FREE, " bytes (Debug:", DEBUG_BYTES, ") ***"

  IF MULTI_GAME
;    org BASE_ADR + $3fc-3-4,0;-25+4+10+8, 0
    ECHO "Start:      ", Start
    ECHO "Reset:      ", NextRandom
    ECHO "SetupScore: ", SetupScore
;    ECHO "DigitTbl =  ", DigitTbl
;    ECHO "Zero =      ", Zero
  ELSE
    ORG $fffc, 0
    .word   Start
    .word   NextRandom      ; brk instead of jsr
  ENDIF
