; *** S P L A T F O R M   2 6 0 0 ***

; Atari 2600 version of the 2002 Minigames Competition
; 1K winning game by Robin Harbron

; Copyright 2003/2005, Thomas Jentzsch
; Version 1.07

; free: 5 byte(s)

; TODOs:
; + better collision detection
; o improved platform generation (TODO: various platform offsets?)
;   + P0 easy = non-random, hard = random
; x animated Bouncy (no space!)
; o scoring (TODO: more points at higher levels?)
; + sounds
; + variable x-speed
; + lifes
; + lifes display at left
; + wait at start (firebutton)
; + loose life at 0 points
; + high score
; - show version number at start (0 points before start)
; + limit minimum platform density (table?)
; x no flicker at RESET/next level (level generation is a problem)
; ? visual end of level
; + smooth scrolling
; + scroll in new playfield
; + lengthLst
; o new bouncing physics (TODO: different sounds?)
;   + P1 easy = height (new), hard = const (old)
; + PAL-60 assembler switch
; + more compact score display code
; + two-face Toto
; + constant scanline count at restart/reset
; + PAL-50 timings
; + repeat levels in random mode
; x Toto wraps around
; + added VBLANK

; Switches:
; - RESET           : new game
; - LEFT DIFFICULTY : B = random platforms; A = non-random platforms
; - RIGHT DIFFICULTY: B = dynamic bouncing; A = static bouncing


    processor 6502
    include vcs.h


;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

VERSION         = $0107

MULTI_GAME      = 1

  IF MULTI_GAME
BASE_ADR        = $f000
  ELSE
BASE_ADR        = $f800
  ENDIF

DEBUG           = 0
INVINCIBLE      = 0             ; invincible Bouncy
UNLIMITED       = 0

NTSC_TIM        = 0             ; (+-0) 0 = PAL-50
NTSC_COL        = 0             ; (+-0) 0 = PAL colors

; *** Feature switches: ***
MULTI_COLOR     = 1             ; (+12) multiple colors for Bouncy
RANDOM          = 1             ; (+13)
RIGHT_SCORE     = 1             ; ( +1)
NEW_BUMP        = 1             ; ( +7)
FLICKER         = 1             ; ( +4) background flicker when losing life
LENGTH_LIST     = 0             ; ( -6)




;===============================================================================
; C O N S T A N T S
;===============================================================================

SCW             = 160

DIGIT_HEIGHT    = 9-4

NUM_ROWS        = 18
ROW_H           = 8
  IF NTSC_TIM
KERNEL_TOP      = 45                            ; = 45
  ELSE
KERNEL_TOP      = 64                            ; = 45
  ENDIF
KERNEL_H        = NUM_ROWS * ROW_H + KERNEL_TOP ; = 189

;total: DIGIT_HEIGHT + 2 + KERNEL_H = 200

BOUNCY_H        = 12
BOUNCY_W        = 7
  IF NTSC_TIM
BOUNCY_Y        = KERNEL_H-BOUNCY_H
  ELSE
BOUNCY_Y        = KERNEL_H-BOUNCY_H-19
  ENDIF

  IF NTSC_COL
BOUNCY_COL      = $1c                   ; yellow
BOUNCY_COL_STOP = $3a                   ; orange
BOUNCY_COL_BACK = $46                   ; red

SCORE_COLOR     = $0a                   ; white
HISCORE_COLOR   = $46                   ; red
  ELSE
BOUNCY_COL      = $2e                   ; yellow
BOUNCY_COL_STOP = $4a                   ; orange
BOUNCY_COL_BACK = $66                   ; red

SCORE_COLOR     = $0c                   ; white
HISCORE_COLOR   = $66                   ; red
  ENDIF
RAND_EOR_8      = $b4                   ;$b2; $e7; $c3
RAND_SEED       = $-1                   ; (unused?)


; difficulty speed parameters:
  IF NTSC_TIM
GRAVITY         = 55
BUMP            = $540
;GRAVITY         = 50
;BUMP            = $510
;GRAVITY         = 45
;BUMP            = $4d0
SPEED_DX        = 24
  ELSE
GRAVITY         = 78                    ; = 55   * (312/262)^2
BUMP            = $647                  ; = $540 * (312/262)

SPEED_DX        = 34                    ; = 24   * (312/262)^2
  ENDIF

SPEED_MAX_X     = 2
BOUNCY_MIN_X    = 8
BOUNCY_MAX_X    = SCW*3/8-BOUNCY_W/2

; platform generation parameters:
MAX_PLATFORM    = 8-1                               ; maximum platform length
FACTOR          = (255+NUM_ROWS)/(NUM_ROWS*2)       ; 7.58 = 7 (~1/18/2)
INIT_SPEED      = 2                                 ; initial scrolling speed
;DENSITY         = $2c0                              ; initial plattfrom density ($2d0)
DENSITY         = ($3c)*(FACTOR+(MAX_PLATFORM+1)/2)   ; initial plattfrom density
DENSITY_MASK    = >DENSITY|>DENSITY/2
ADVANCE         = 16                                ; advance of difficulty (1/ADVANCE)
NUM_LEVEL       = 10


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

    SEG.U   variables
    ORG     $80

xPosLst     ds NUM_ROWS
hmPosLst    ds NUM_ROWS
pfLst       ds NUM_ROWS
  IF LENGTH_LIST
lengthLst   ds NUM_ROWS         ; originally saved just *1* single byte of ROM! :-)
  ENDIF

yBouncy     ds 4
yBouncyHi   = yBouncy
yBouncyLo   = yBouncy+1

ySpeed      = yBouncy+2
ySpeedHi    = ySpeed
ySpeedLo    = ySpeed+1

xBouncy     ds 4
xBouncyHi   = xBouncy
xBouncyLo   = xBouncy+1

xSpeed      = xBouncy+2
xSpeedHi    = xSpeed
xSpeedLo    = xSpeed+1

sound       .byte
levelCnt    .byte

scrollIn    .byte
scrollSum   .byte

pfSum       ds 2
pfSumHi     = pfSum
pfSumLo     = pfSum+1

end_of_next  = .

; variables not resetted for next level:
level       .byte

score       ds 2
scoreHi     = score
scoreLo     = score+1

end_of_reset = .

; variables initialized at start of game:
initVars    = .

random      .byte
colorP1     .byte               ; cccc111. bits
lifes       .byte
cxRowY      .byte               ; 0..NUM_ROWS-1
scoreMax     ds 2
scoreMaxHi  = scoreMax
scoreMaxLo  = scoreMax+1

NUM_INIT    = . - initVars

; uninitialized variables:
tmpVars     ds 10
tmpVar      = tmpVars
tmpVar2     = tmpVars+1
tmpVar3     = tmpVars+2

saveRandom  .byte
compMode    .byte               ; random/bouncing mode?

frameCnt    .byte

  ECHO "*** RAM: ", ., " ***"


;===============================================================================
; M A C R O S
;===============================================================================

  MAC DEBUG_BRK
    IF DEBUG
      brk                         ;
    ENDIF
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

;---------------------------------------------------------------
Start SUBROUTINE
;---------------------------------------------------------------
; cart inserted

;    cld                             ;           cleared below!
    ldx     #NUM_INIT-1

;---------------------------------------------------------------
Reset:
;---------------------------------------------------------------
; RESET pressed

.loopInit:
    lda     InitTbl,x
    sta     initVars,x
    dex
    bpl     .loopInit

  IF RANDOM || NEW_BUMP
    ldx     SWCHB
    stx     compMode
  ENDIF

;    tax                             ;           using last value from InitTbl
    ldx     #end_of_reset -1
    sec

;---------------------------------------------------------------
StartLevel:
;---------------------------------------------------------------
; (re)start level
; x contains number of resetted variables - 1

    bcc     .skipNewRandom

    lda     random              ;
  IF RANDOM
    bit     compMode            ; 3
    bvc     .skipRandom         ; 2³
    eor     frameCnt            ; 3
    bne     .skipRandom         ; 2³
    eor     INTIM               ; 4
.skipRandom:
  ENDIF
    sta     saveRandom          ;        ...save new initial random value...
.skipNewRandom:
    sta     random

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

  IF DEBUG ;{
    lda     #$80
    sta     COLUBK
    lda     #$04
    sta     COLUPF
  ENDIF ;}

;---------------------------------------------------------------
;GameInit SUBROUTINE
;---------------------------------------------------------------
;    lda     saveRandom
;    sta     random

    lda     #(SCW-8)/INIT_SPEED
    sta     scrollIn

    .byte   $a9
    DEC2BCD 100-(SCW-8)/4       ; add missing ~60 points (total: 100 points)
    jsr     Add16_ScorePos      ; clears BCD flag

;---------------------------------------------------------------
MainLoop SUBROUTINE
;---------------------------------------------------------------

.waitTim:
    ldx     INTIM
    bpl     .waitTim
    sta     HMCLR               ;               stop ball

;---------------------------------------------------------------
;VerticalBlank SUBROUTINE
;---------------------------------------------------------------

  IF NTSC_TIM
    ldy     #44-6-1-1
  ELSE
    ldy     #57-1
  ENDIF
    lda     #%00110100              ;
    sta     CTRLPF                  ;           8 pixel ball
    lda     #%1110
  IF DEBUG = 0
    sta     ENABL
  ENDIF
.waitSync:
    sta     WSYNC
    sta     VSYNC
    lsr
    bne     .waitSync
    sty     TIM64T

;    lda     #%11111010              ;           higher bits used as loop counter
;    sta     VSYNC
;  IF DEBUG = 0
;    sta     ENABL
;  ENDIF
;    asl                             ;           a = %xx110100
;    sta     CTRLPF                  ;           8 pixel ball
;.waitSync:
;  IF NTSC_TIM
;    ldy     #44-6
;  ELSE
;    ldy     #57
;  ENDIF
;    asl
;    sta     WSYNC
;    bmi     .waitSync
;    sta     VSYNC
;    sty     TIM64T

; VerticalBlank

;---------------------------------------------------------------
GameCalc SUBROUTINE
;---------------------------------------------------------------

; check, if current level is over:
    lda     xBouncy
    bit     sound
    bmi     .skipXScroll
    bit     levelCnt                ;           128 platforms?
    bpl     .contLevel              ;            no, continue with current level
    cmp     #SCW                    ; 2          yes, Bouncy at the very right? (160)
    bcc     .skipXScroll            ;             no, continue, but stop scrolling
    ldx     #$d0                    ;             yes, start sound for finishing the level
    stx     sound                   ;
    bcs     .skipXScroll            ; 3

.contLevel:
    ldy     scrollIn                ;           used in ScrollRight!
    lda     #BOUNCY_MAX_X
;    sec
    sbc     xBouncy                 ;           C = 1!
    bcc     .doScroll

; *** scroll in new platforms: ***
    dey
    bmi     .skipXScroll

    lda     #-INIT_SPEED
    dec     scrollIn
    bne     .doScroll2

; initial platform scrolling finished, now show Bouncy:
;    ldx     #124
;    stx     levelCnt
    ldx     #BOUNCY_Y
    stx     yBouncy
.doScroll:
    ldx     #BOUNCY_MAX_X
    stx     xBouncy
.doScroll2:
    jsr     ScrollRight
.skipXScroll:

    jsr     CheckHigh

.waitTim:
    ldy     INTIM
    bne     .waitTim

; *** setup score colors: ***
    ldx     #SCORE_COLOR
    lda     lifes               ;           game over?
    beq     .gameOverScore      ;            yes!
    bcs     .currentScoreHi
  IF MULTI_GAME
    bcc     .currentScore       ;           ...between current and high score (c=0!)
  ELSE
    BIT_W
  ENDIF
.gameOverScore:
    lda     frameCnt            ;           stopped, score switches...
    bpl     .currentScore       ;           ...between current and high score (c=0!)
    ldy     #(scoreMax-score)
.currentScoreHi:
    ldx     #HISCORE_COLOR
.currentScore:
    stx     COLUP0
    stx     COLUP1
; GameCalc


;---------------------------------------------------------------
Kernel SUBROUTINE
;---------------------------------------------------------------
.ptrScore       = tmpVars       ;..+7
.tmpY           = tmpVars+8
.blockHeight    = tmpVars+9
;---------------------------------------
.ptrBouncy  = tmpVars       ;..+1
.yBouncy    = tmpVars+7
.rows       = tmpVars+8     ; == .tmpY !

DrawScreen:
; setup score pointers:
    ldx     #4-1                ; 2
.loopScore:
    lda     #>Zero              ; 2
    sta     .ptrScore,x         ; 4
    sta     .ptrScore+4,x       ; 4
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
    sta     .ptrScore+4,x       ; 4
    ldy     .tmpY               ; 3
    iny                         ; 2
    dex                         ; 2
    bpl     .loopScore          ; 2³
;total: 133

;===============================================
; some very tricky coding here :-)
    lda     #%10011001
    sta     .blockHeight
    ldy     #DIGIT_HEIGHT
.nextBlock:
    dey
.contBlock:
    lda     lifes               ; 3
    sta     WSYNC
;---------------------------------------
    ldx     #NUM_ROWS           ; 2
    stx     .rows               ; 3
    sta     VBLANK              ; 3
    sta     GRP0                ; 3         @11
    lda     (.ptrScore+6),y     ; 5
    sta     GRP1                ; 3         @19
  IF RIGHT_SCORE
    nop                         ; 2
  ENDIF
    lax     (.ptrScore+4),y     ; 5
    lda     (.ptrScore+2),y     ; 5
    sta     GRP0                ; 3         @34
    lda     (.ptrScore+0),y     ; 5
    sta     GRP0                ; 3         @42
    stx     GRP1                ; 3         @45
    lsr     .blockHeight        ; 5
    bcs     .nextBlock          ; 2³
    bne     .contBlock          ; 2³

    sty     GRP1                ; 3
    sty     GRP0                ; 3 =  6

    lda     xBouncy             ; 3
    jsr     XPosObject0         ; 6 =  9    @69/@09

    lda     #BOUNCY_H+KERNEL_H  ; 2
    sbc     yBouncyHi           ; 3             C=1!
    sta     .yBouncy            ; 3
    adc     #<Bouncy1-KERNEL_H-3; 2             C=1!
    ldx     ySpeedHi            ; 3
    bpl     .moveUp             ; 2²
    adc     #<Bouncy2-Bouncy1   ; 2
.moveUp:
    sta     .ptrBouncy          ; 3 = 19/20

    sty     NUSIZ0              ; 3             y=0!
  IF MULTI_COLOR = 0 ;{
    dey                         ; 2
    sty     NUSIZ1              ; 3             quad width players
    sty     VDELP1              ; 3             enable vertical delay
  ENDIF ;}
    sta     HMCLR               ; 3 = 14

  IF MULTI_COLOR
    ldy     #BOUNCY_COL_BACK|1  ; 2             also used for NUSIZ1/VDELP1
    sty     NUSIZ1              ; 3             quad width players
    sty     VDELP1              ; 3             enable vertical delay
    lda     xSpeed              ; 3
    bmi     .setColor           ; 2³
    ldy     #BOUNCY_COL_STOP    ; 2
    ora     xSpeedLo            ; 3
    beq     .setColor           ; 2³
  ENDIF
    ldy     #BOUNCY_COL         ; 2
.setColor:
    sty     COLUP0              ; 3 = 10-19     @52..61

;=====================================================
; right 8 pixels are blanked by black ball!
    ldy     #KERNEL_H-1+2       ; 2
.loopKernel:                    ;           @30
    ldx     #ROW_H-2            ; 2
.loopY:                         ;
    lda     #BOUNCY_H-1         ; 2
    dcp     .yBouncy            ; 5 =  7
    sta     WSYNC               ; 3
;---------------------------------------
    bcs     .doDraw             ; 2³
    lda     #0                  ; 2
    BIT_W                       ;-1
.doDraw:
    lda     (.ptrBouncy),y      ; 5
    sta     GRP0                ; 3 = 11    @11
    lda     ColTbl-1,x          ; 4
    and     colorP1             ; 3
    sta     COLUP1              ; 3         @21
    dey                         ; 2

; check for special loop at top of kernel:
    cpy     #(KERNEL_H-KERNEL_TOP)-1+(ROW_H-1); 2
    bcs     .loopY              ; 2³

    dex                         ; 2
    bne     .loopY              ; 2³= 20³   @31

; bottom platform row:
    lda     #BOUNCY_H-1         ; 2
    dcp     .yBouncy            ; 5
    bcs     .doDraw0            ; 2³
    txa                         ; 2             x=0
    BIT_W                       ;-1
.doDraw0:
    lda     (.ptrBouncy),y      ; 5
    stx     GRP1                ; 3 = 18    @49 x=0 (delayed!)

; check collisions:
    bit     CXPPMM              ; 3         @52
    bmi     .setcxRowY          ; 2³            save *last* row *with* collision
    BIT_W                       ; 1
.setcxRowY:

    sty     cxRowY              ; 3
    dey                         ; 2
    sta     CXCLR               ; 3 = 14    @63

; update row counter:
    ldx     .rows               ; 3
    beq     .exitKernel         ; 2³
    dec     .rows               ; 5 = 10

    sta     GRP0                ; 3 =  3    @76
;---------------------------------------
; empty platform row, reposition next platform:
    lda     pfLst-1,x           ; 4
    sta     GRP1                ; 3
    lda     hmPosLst-1,x        ; 4
    sta     HMP1                ; 3
    and     #$0f                ; 2
    beq     .veryLeft           ; 2³
    sec                         ; 2
WaitObject1:
    sbc     #1                  ; 2
    bne     WaitObject1         ; 2³
.veryLeft:
    sta.w   RESP1               ; 4         @23..73!
    sta     WSYNC               ; 3
;---------------------------------------
; top platform row (black)
    sta     HMOVE               ; 3
    sta     COLUP1              ; 3 =  6

    tax                         ; 2         a = 0!
    lda     #BOUNCY_H-1         ; 2
    dcp     .yBouncy            ; 5
    bcc     .skipDraw1          ; 2³
    lax     (.ptrBouncy),y      ; 5
.skipDraw1:
    stx     GRP0                ; 3 = 19    @25 (@25, besser 24!)

    dey                         ; 2
    bne     .loopKernel         ; 3 =  5

;=====================================================
.exitKernel:                    ;           @69

;---------------------------------------------------------------
OverScan SUBROUTINE
;---------------------------------------------------------------
  IF NTSC_TIM
    lda     #29-1|2             ; 2
  ELSE
    lda     #46|2
  ENDIF
    sta     TIM64T              ; 4

;    stx     GRP0                ; 3         @02
    stx     VDELP1              ; 3
    sta     VBLANK

; *** handle collisions: ***
;    lda     #0
;    sta     COLUBK

; calculate old row:
;    sec                         ;       almost doesn't matter
    lda     yBouncyLo           ;       C=1!
    sbc     ySpeedLo
    lda     yBouncyHi
    sbc     ySpeedHi
    sbc     #ROW_H*2            ;       C=0!
    bcc     .skipCollision      ;        no, skip
    sbc     cxRowY              ;       was previous row above?
    bcc     .skipCollision      ;        no, skip

; *** bump ***
    lda     #<BUMP
    ldx     #>BUMP
    bit     compMode            ;       constant bump mode?
    bmi     .contBump           ;        yes
    sbc     ySpeedLo            ;        no, 50% additional bump for previous height
    tay
    txa
    sbc     ySpeedHi
    lsr
    tax
    tya
    ror
.contBump:
    sta     ySpeedLo
    stx     ySpeedHi

; start bouncing sound:
;    clc
;    adc     #5
;    sta     sound
    lda     #$0c
    sta     sound

    lda     #$95                ;       -5 points
    ldy     #$99
    jsr     Add16_Score

    bcc     .resetScore         ;       score below zero, loose life!
.skipCollision:

; *** play sounds: ***
    lax     sound
    beq     .skipSound
    bpl     .bounce
    dex
    asl
    bpl     .falling
    ldy     #$04
    asl                         ;       falling sound over?
    bne     .setAudF0a

; goto next level
    lda     colorP1             ;        ...calculate new level color,...
  IF NTSC_COL
    adc     #$2f                ;       C=1! (color repeats after 16 levels)
  ELSE
    adc     #$4f                ;       C=1! (color repeats after 16 levels)
  ENDIF
    sta     colorP1

; limit level number:
    ldy     level               ;
    cpy     #NUM_LEVEL-1
    bcs     .maxLevel
    inc     level               ;       increase level
    sec                         ;       carry is important for StartLevel!
.maxLevel:
.restartLevel:
    ldx     #end_of_next -1     ;        ...and start new level
    jmp     StartLevel          ; 3

; make falling sound:
.falling:
    bne     .contFalling
    lda     saveRandom          ;       load old initial random value
; loose one life:
  IF UNLIMITED = 0
    lsr     lifes
    lsr     lifes               ;       any more lifes?
    bne     .restartLevel       ;        yes, restart current level (C=0!)
                                ;        no, game over!!!
  ELSE ;{
    lda     saveRandom
    bne     .restartLevel
  ENDIF ;}
    jsr     CheckHigh           ;       new high score?
    bcc     .skipHigh
    stx     scoreMaxLo
    sty     scoreMaxHi
.skipHigh:
    ldx     #0
    stx     scrollIn
    inc     sound

.contFalling:
    txa
  IF FLICKER
    sta     COLUBK
  ENDIF
    lsr
    lsr
    tax
    ldy     #$03
    lda     #$0c
    bne     .setAudF0

;---------------------------------------
.resetScore:                    ;       set score to zero
    lda     #0
    sta     scoreLo
    sta     scoreHi
.looseLife:
    lda     #$b8                ;       start dying sound ($0b..$00)
    sta     sound
.endMoveJmp:
    jmp     .endMove
;---------------------------------------

; make bouncing sound:
.bounce:
    dex
    txa
    ldy     #$0c
    adc     #$13                ;       C=1!
    BIT_B
.setAudF0a:
    txa
.setAudF0:
    stx     AUDV0
    sty     AUDC0
    sta     AUDF0
    dec     sound
.skipSound:

; *** reset collisions: ***
    ldy     #-1                 ;       reinitialize collision variable
    sty     cxRowY

; *** check RESET switch: ***
    ldx     #NUM_INIT-3         ;       number of initialized variables
  IF MULTI_GAME
; multi-game
; + RESET is disabled (button too)
; +
; + game over jumps to menu

Select  = $fcb6+1
option  = $fc
    lda     SWCHB
    lsr
    bcs     .skipReset
    bit     option
    bpl     .doReset            ;       brk!
.skipReset:
    lsr
    bcs     .skipSelect
.doSelect:
    jmp     Select

.skipSelect:
  ELSE
    lsr     SWCHB
    bcc     .doReset            ;       brk!
  ENDIF

; *** wait at start of level: ***
    lda     scrollIn
    bmi     .skipWait
    bne     .endMoveJmp
    bit     INPT4
    bmi     .endMoveJmp
    lda     lifes
  IF MULTI_GAME
    bne     .skipReset0
.checkReset:
    bit     option
    bpl     .doReset            ;       brk!
.skipReset0:
  ELSE
    beq     .doReset
  ENDIF
    dec     scrollIn            ;
.skipWait:

    bit     sound
    bmi     .endMoveJmp

; *** move Bouncy vertically: ***
;    ldy     #-1
    lda     #-GRAVITY           ;       y = -1!
    ldx     #ySpeed
    jsr     Add16

;    tay                         ;       a = ySpeedHi
;    lda     ySpeedLo
;    ldx     #yBouncy
;    jsr     Add16
    jsr     Sum16               ;       yBouncy += ySpeed

; check for falling down:
  IF INVINCIBLE = 0
    cmp     #-18
    bcs     .looseLife
  ELSE
    clc
  ENDIF

;    lda     #BOUNCY_H+ROW_H-3-1      ; -> just above bottom row
;    lda     #KERNEL_H-1              ; -> directly at top
;    lda     #-1
;    sta     yBouncyHi

; *** horizontal movement: ***

; *** move Bouncy horizontally: ***
.doReset = . + 1
; check joystick:
    ldy     #0                  ;       brk!
    lda     #SPEED_DX
    bit     SWCHA
    bpl     .addSpeedX
    tya
    bvs     .addSpeedX
    dey
    lda     #-SPEED_DX          ;       brakes faster than accelerating (due to additonal friction)
.addSpeedX:
    ldx     #xSpeed
    jsr     Add16

; friction:
    asl                         ;       positive or negative speed?
    ldy     #0
    lda     #SPEED_DX/3
    bcs     .subSpeedX
    dey
    lda     #-SPEED_DX/3
.subSpeedX:
    jsr     Add16               ;       x = <xSpeed!

; check for direction switch due to friction
    bcc     .checkNeg
    dey
.checkNeg:
    iny
    beq     .stopX              ;       friction changed direction, set x-speed to 0

; limit positive horizontal speed:
    tay                         ;       a = xSpeedHi!
    eor     #SPEED_MAX_X
    bne     .skipLimit
    sta     xSpeedLo            ;       a = 0!
.skipLimit:

; move:
;    lda     xSpeedLo
;    ldx     #xBouncy
;    jsr     Add16               ;       y = xSpeedHi
    jsr     Sum16               ;       xBouncy += xSpeed

; limit xBouncy to the left:
    cmp     #BOUNCY_MIN_X       ;       a = xBouncyHi
    bcs     .xBouncyOk
    lda     #BOUNCY_MIN_X
    sta     xBouncyHi
    ldy     #0
.stopX
    sty     xSpeedHi
    sty     xSpeedLo
.xBouncyOk:

;-------------------------------------------------
.endMove:

; *** position score sprites and blanking ball: ***
  IF RIGHT_SCORE
    lda     #38-16+3*2+4          ;               +4: dirty tweak to avoid additional HMCLR
  ELSE
    lda     #38-16+4
  ENDIF
    jsr     XPosObject0
    sta     RESBL
    lda     #$70|%011
    sta     HMBL
    sta     NUSIZ0              ;       %011
    inx
    stx     NUSIZ1              ;       %001
  IF RIGHT_SCORE
    lda     #38+8+3*2
  ELSE
    lda     #38+8
  ENDIF
    jsr     XPosObject

    inc     frameCnt

    jmp     MainLoop
; OverScan


;***************************************************************
ScrollRight SUBROUTINE
;***************************************************************
; a = .dPixel (negative!)
; y = scrollIn

.dPixel     = tmpVar
.dPixel16   = tmpVar+1
.newPixel   = tmpVar+2
  IF RANDOM
.random     = tmpVar+3
  ENDIF

    sta     .dPixel
    asl
    asl
    asl
    asl
    sta     .dPixel16

    lda     scrollSum
    clc
    adc     .dPixel
    and     #$03
    sta     scrollSum
    ror     .newPixel           ;       N = smooth scroll only

    bmi     .skipNew            ;
  IF (NUM_ROWS & 1) = 0
   IF LENGTH_LIST
    jsr     NextRandom
   ELSE
    bit     .dPixel16
    bvs     NextRandom
   ENDIF
.extraRandom:
  ENDIF

; *** update platform counter: ***
; get level number:
    ldx     level
;    ldx     #9
; get platform density of current level:
    lda     DensityTbl,x
    tax
    and     #DENSITY_MASK
; create safety platform at start of level:
    cpy     #51                 ;       y = scrollIn
    bne     .skipSafety
    adc     #FACTOR/2-1         ;       increase new platform probability (C=1!)
.skipSafety:
; increase platform possibility:
    tay
    txa
    ldx     #pfSum
    jsr     Add16
.skipNew:
  IF LENGTH_LIST = 0
    lsr     .newPixel           ;       V = smooth scroll only
  ENDIF

; *** main scrolling loop: ***
    ldx     #NUM_ROWS-1
.loopScroll:
; *** smooth scrolling: ***
    ldy     pfLst,x
    beq     .skipSmooth

.smoothScroll:
    lda     xPosLst,x
    clc
    adc     .dPixel
    bcs     .xPosOk

; remove left platform piece:
    adc     #4
  IF LENGTH_LIST
    dec     lengthLst,x
  ENDIF
    asl     pfLst,x             ;       remove platform piece
    clc
.xPosOk:
    sta     xPosLst,x

    lda     hmPosLst,x
    bcs     .xPosOk2
    sbc     #$40-1              ;       move 4 pixel right, C=0!
    bvc     .hmOk
    adc     #$f1-1              ;       C=1!
.hmOk:
    sec
.xPosOk2:
    sbc     .dPixel16
    bvc     .hmOk2
    adc     #$10-1              ;       C=0!
.hmOk2:
    sta     hmPosLst,x
.skipSmooth:

; *** create new platform pieces ***
    bit     .newPixel
  IF LENGTH_LIST
    bmi     .nextLoop
    jsr     NextRandom

    ldy     lengthLst,x
  ELSE
    bvs     .nextLoop
    ldy     #-1
    lda     pfLst,x
    beq     .zeroBits
.loopBits:
    iny
    asl
    bne     .loopBits

.zeroBits:
;***************************************************************
NextRandom:
;***************************************************************
    lda     random              ; 3
    lsr                         ; 2
    bcc     .skipEor            ; 2³
    eor     #RAND_EOR_8         ; 2
.skipEor:                       ;
    sta     random              ; 3

    bvs     .extraRandom
; NextRandom

    iny
  ENDIF
    beq     .emptyRow

    cmp     RandomTbl-1,y
    bcs     .nextLoop

; check for enlarging existing platform:
    tya
    asl
    asl
    adc     xPosLst,x
    sbc     scrollSum           ;       C = 0!
    cmp     #(SCW-8)-1-1
    bne     .nextLoop
; enlarge existing platform:
    lda     #-2
    bcs     .setBit

; check for new platform:
.emptyRow:
    bit     pfSumHi
    bmi     .nextLoop
    and     #$7f                ;       a = random number!
    cmp     pfSumHi
    bcs     .nextLoop

; create new platform:
    inc     levelCnt            ;       increase level length counter
    ldy     scrollSum
    lda     HmStartTbl,y
    sta     hmPosLst,x
    tya
    adc     #(SCW-8)-1          ;       C = 0!
    sta     xPosLst,x
    lda     #-FACTOR
.setBit:
    adc     pfSumHi             ;       C = 0!
    sta     pfSumHi
    sec
    ror     pfLst,x
  IF LENGTH_LIST
    inc     lengthLst,x
  ENDIF

.nextLoop:
    dex
    bpl     .loopScroll

; *** add points: ***
    bit     .newPixel
  IF LENGTH_LIST
    bmi     Exit
  ELSE
    bvs     Exit
  ENDIF

    lda     #$01                ;       add 1 point
;    lda     level
;    lsr
;    adc     #1

; ScrollRight

;***************************************************************
Add16_ScorePos SUBROUTINE
;***************************************************************
    ldy     #$00
Add16_Score:
    ldx     #score
Add16BCD:
    sed
Add16:
    clc
    adc     $01,x
    sta     $01,x
    tya
    adc     $00,x
    sta     $00,x
    cld
Exit:
    rts

Sum16:
    lda     $01,x
    ldy     $00,x
    dex
    dex
    bne     Add16
; Add16_ScorePos


  IF LENGTH_LIST
;***************************************************************
NextRandom:
;***************************************************************
    lda     random              ; 3
    lsr                         ; 2
    bcc     .skipEor            ; 2³
    eor     #RAND_EOR_8         ; 2
.skipEor:                       ;
    sta     random              ; 3
    rts
; NextRandom
  ENDIF


;***************************************************************
XPosObject0 SUBROUTINE
;***************************************************************
    ldx     #0              ; 2
XPosObject:
    sec                     ; 2
    sta     WSYNC           ; 3
;---------------------------------------
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
    sta.wx  RESP0,x         ; 5     @23!
    sta     WSYNC
;---------------------------------------
    sta     HMOVE
    rts
; XPosObject0


;***************************************************************
CheckHigh SUBROUTINE
;***************************************************************
; carry doesn't matter!
    lax     scoreLo
    sbc     scoreMaxLo
    lda     scoreHi
    tay
    sbc     scoreMaxHi
    rts
; CheckHigh

CodeEnd:


;===============================================================================
; R O M - T A B L E S (Bank 0)
;===============================================================================

FREE SET 0

HmStartTbl:
    .byte   $1a, $0a, $fa, $ea  ;       -4, -3, -2, -1

DensityTbl:
Y2 SET DENSITY*1024
  REPEAT NUM_LEVEL
Y SET (Y2+1024/2)/1024
    .byte (<Y & ~DENSITY_MASK) | (>Y & DENSITY_MASK)
Y2 SET (Y2 * (ADVANCE-1) + ADVANCE/2)/ADVANCE
  REPEND

InitTbl:
    .byte   RAND_SEED   ; saveRandom
    .byte   $2e         ; colorP1
    .byte   %01010101   ; lifes (4 lifes, only three are shown!)
    .byte   -1          ; cxRowY
    .byte   >VERSION    ; scoreMaxHi
    .byte   <VERSION    ; scoreMaxLo

ColTbl:
;    .byte   $f0, $f4, $f6, $f8, $fa, $0e;
    .byte   $f0, $f2, $f6, $fa, $fe, $0e;   ; rounded platforms
;    .byte   $00                             ; overlapping!!!

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

  CHECKPAGE One

DataEnd1:

  IF <. < KERNEL_H-1
    ORG (. & ~$ff) + KERNEL_H-1
  ENDIF

FREE SET FREE + . - DataEnd1

  IF MULTI_GAME
    .byte   0
  ENDIF
Bouncy1:
    .byte   %00111000
    .byte   %01111100
    .byte   %01111100
    .byte   %11111110
    .byte   %11000110
    .byte   %10111010
    .byte   %11111110
    .byte   %11111110
    .byte   %11010110
    .byte   %01010100
    .byte   %01111100
  IF MULTI_GAME
    .byte   %00111000
    .byte   0
  ELSE
;    .byte   %00111000
  ENDIF
Bouncy2:
    .byte   %00111000
    .byte   %01111100
    .byte   %01000100
    .byte   %10111010
    .byte   %11111110
    .byte   %11111110
    .byte   %11010110
    .byte   %11010110
    .byte   %11111110
    .byte   %01111100
    .byte   %01111100
    .byte   %00111000

  CHECKPAGE (Bouncy1-1)

DigitTbl:
    .byte   <Zero,  <One,   <Two,   <Three, <Four
    .byte   <Five,  <Six,   <Seven, <Eight, <Nine

RandomTbl:
Y SET MAX_PLATFORM
  REPEAT MAX_PLATFORM
Y SET Y - 1
    .byte   (256*Y+(Y+1)/2)/(Y+1)
  REPEND
;    .byte   256/8*7, 256/7*6, 256/6*5, 256/5*4,.byte   256/4*3, 256/3*2, 256/2*1, 256/1*0
;    .byte   256/15*14, 256/14*12, 256/12*10, 256/10*8, 256/8*6, 256/6*4, 256/4*2, 256/2*0
;    .byte   $0

DataEnd2:
;    .byte   "Splatform v1.03 - (C) 2004 Thomas Jentzsch"

  IF MULTI_GAME
FREE SET FREE + BASE_ADR + $400 - DataEnd2
;    org BASE_ADR + $3fc+1, 0
;    ds 3, 0
  ECHO "Toto       =", Bouncy1-1
  ECHO "XPosObject =", XPosObject
  ECHO "Add16BCD   =", Add16BCD

  ELSE
FREE SET FREE + BASE_ADR + $3fc - DataEnd2
    org $fffc, 0
    .word   Start
    .word   Reset
  ENDIF

  ECHO "*** Free ", FREE, " bytes ***"

