;Lawn Mower NES game
;by Shiru (shiru@mail.ru) 05'11
;Compile with NESASM3
;The game and its source code are released into Public Domain

    .inesprg    1
    .ineschr    1
    .inesmir    1
    .inesmap    0

    .bank 0
    .org $c000

PPU_CTRL		equ $2000
PPU_MASK		equ $2001
PPU_STATUS		equ $2002
PPU_OAM_ADDR	equ $2003
PPU_OAM_DATA	equ $2004
PPU_SCROLL		equ $2005
PPU_ADDR		equ $2006
PPU_DATA		equ $2007
PPU_OAM_DMA		equ $4014
PPU_FRAMECNT	equ $4017
DMC_FREQ		equ $4010
CTRL_PORT1		equ $4016


TEMP			equ $00
PAD_BUF			equ $00	;3 bytes

FRAME_CNT		equ $ff
FRAME_CNT2		equ $fe
RAND_SEED		equ $fd

PAD_STATE		equ $f9
PAD_STATEP		equ $f8
PAD_STATET		equ $f7
;f0..f6 for FamiTone vars

PAL_BRIGHT		equ $ef
PAL_MODE		equ $ee
PAL_DATA		equ $40	;32 bytes

GAME_NTSC		equ $eb
GAME_PLR_X		equ $e9	;word, fixed point 12:4
GAME_PLR_Y		equ $e7	;word, fixed point 12:4
GAME_DIR		equ $e6
GAME_DIR_NEW	equ $e5
GAME_TILE_ADR	equ $e3	;word
GAME_SPEEDP		equ $e1	;word, fixed point 12:4
GAME_SPEEDM		equ $df	;word, fixed point 12:4
GAME_PLR_DX		equ $dd	;word, fixed point 12:4
GAME_PLR_DY		equ $db	;word, fixed point 12:4
GAME_PLR_OFF	equ $d9	;word, fixed point 12:4
GAME_PLR_TX		equ $d8
GAME_PLR_TY		equ $d7
GAME_CAM_X		equ $d5	;word
GAME_SPEED		equ $d4
GAME_UPDATE_X	equ $d3
GAME_UPDATE_Y	equ $d2
GAME_DONE		equ $d0	;word, fixed point 8:8
GAME_DONE_INC	equ $ce	;word, fixed point 8:8
GAME_DONE_CNT	equ $cc	;word
GAME_FUEL		equ $cb
GAME_LEVEL		equ $ca
GAME_MAP_WDT	equ $c9
GAME_CAM_MAX	equ $c7	;word
GAME_PAUSED		equ $c6
GAME_DIR_PREV	equ $c5
GAME_CHR_ANIM	equ $c4
GAME_DELAY		equ $c3
GAME_FLASH_CNT	equ $c2
GAME_FUEL_X		equ $c1
GAME_FUEL_Y		equ $c0
GAME_FUEL_PTR	equ $be	;word
GAME_FUEL_TIME	equ $bc	;word
;GAME_CAM_Y		equ $bb
GAME_CAM_SHAKE	equ $ba
GAME_BOOST		equ $b9
GAME_FUEL_NX	equ $b8
GAME_FUEL_NY	equ $b7
GAME_FUEL_NPTR	equ $b5	;word
GAME_LSKIP		equ $b4
GAME_GRASS_TYPE	equ $b3
GAME_DONE_SCR	equ $b2
GAME_CHECK_EXIT	equ $b1

OAM_PAGE		equ $200
GAME_MAP		equ $300	;512 bytes

FT_BASE_ADR		equ $0700	;page in RAM, should be $xx00
FT_TEMP			equ $f0		;7 bytes in zeropage
FT_SFX_STREAMS	equ 3		;number of sound effects played at once, could be 4 or less

FT_SFX_ENABLE				;undefine to exclude all the sound effects code
;FT_DPCM_ENABLE				;there is hack in FamiTone, dpcm channel is still parsed

DIR_NONE		equ 0
DIR_LEFT		equ 1
DIR_RIGHT		equ 2
DIR_UP			equ 3
DIR_DOWN		equ 4

SFX_ENGINE_START	equ 0
SFX_ENGINE_STOP		equ 1
SFX_ENGINE_STALL	equ 2
SFX_START			equ 3
SFX_FUEL_ON_FIELD	equ 4
SFX_FUEL_GET		equ 5
SFX_GRASS_CUT		equ 6
SFX_PAUSE			equ 7
SFX_FUEL_LOW		equ 8
SFX_SKIP			equ 9
SFX_MUTE			equ 10
SFX_STONE			equ 11
SFX_FLOWERS			equ 12
SFX_ENGINE_TURBO	equ 13

OAM_PLAYER			equ 1*4
OAM_FUEL_BAR		equ 56*4

GAME_FUEL_MAX		equ 58*4
GAME_LEVELS_ALL		equ 10
GAME_GTYPE_NONE		equ $00
GAME_GTYPE_GRASS	equ $da
GAME_GTYPE_FLOWERS	equ $ea



reset

;init hardware

    sei

    ldx #$40
    stx PPU_FRAMECNT
    ldx #$ff
    txs
    inx
    stx PPU_MASK
    stx DMC_FREQ
    stx PPU_CTRL		;no NMI

	jsr waitVBlank

    txa
clearRAM
    sta $000,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne clearRAM

	lda #%10000000
	sta PPU_CTRL		;enable NMI

	jsr waitVBlank
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL

clearVRAM
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #8
.1
	tay
.2
	sta PPU_DATA
	iny
	bne .2
	dex
	bne .1

	sta <FRAME_CNT
	sta <FRAME_CNT2

	jsr clearOAM
	jsr updateOAM
	jsr palReset
	jsr padInit


detectNTSC
	jsr waitNMI		;blargg's code
	ldx #52
	ldy #24
.1
	dex
	bne .1
	dey
	bne .1

	lda PPU_STATUS
	and #$80
	sta <GAME_NTSC


;init sound

	lda <GAME_NTSC
	jsr FamiToneInit

	ldx # LOW(sounds)
	ldy #HIGH(sounds)
	jsr FamiToneSfxInit

	lda #0
	sta $4017


;init game

	lda #1
	sta <RAND_SEED
	lda #0
	sta <GAME_LSKIP

initGame
	jsr showTitle

	lda #0
	sta <GAME_LEVEL

initLevel
	lda #0
	sta PPU_MASK

	sta <GAME_FUEL
	sta <GAME_DELAY
	sta <GAME_PLR_OFF
	sta <GAME_PLR_OFF+1
	sta <GAME_PAUSED
	sta <GAME_FUEL_X
	sta <GAME_FUEL_NX
	;sta <GAME_CAM_Y
	sta <GAME_CAM_SHAKE
	sta <GAME_BOOST
	sta <GAME_GRASS_TYPE
	sta <GAME_CHECK_EXIT
	jsr fuelSetTimer

	lda #20
	sta <GAME_SPEED
	jsr setSpeed

	lda #$80
	sta <GAME_CHR_ANIM

	lda #DIR_RIGHT
	sta <GAME_DIR
	sta <GAME_DIR_NEW
	sta <GAME_DIR_PREV

setField
	lda <GAME_LEVEL			;get level data address
	asl a
	tax
	lda levList+1,x
	sta PPU_ADDR
	lda levList,x
	sta PPU_ADDR
	lda PPU_DATA

	lda # LOW(GAME_MAP+96)	;unpack level data
	sta <TEMP+2
	lda #HIGH(GAME_MAP+96)
	sta <TEMP+3
	lda #88
	sta <TEMP+4
.1
	ldy #0
	lda PPU_DATA
	tax
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta [TEMP+2],y
	iny
	txa
	lsr a
	lsr a
	lsr a
	lsr a
	and #3
	sta [TEMP+2],y
	iny
	txa
	lsr a
	lsr a
	and #3
	sta [TEMP+2],y
	iny
	txa
	and #3
	sta [TEMP+2],y

	lda <TEMP+2
	clc
	adc #4
	sta <TEMP+2
	lda <TEMP+3
	adc #0
	sta <TEMP+3
	dec <TEMP+4
	bne .1

	lda PPU_DATA
	sta <GAME_MAP_WDT
	clc
	adc #-14
	sta <GAME_CAM_MAX
	lda #0
	sta <GAME_CAM_MAX+1
	ldx #4
.3
	asl <GAME_CAM_MAX
	rol <GAME_CAM_MAX+1
	dex
	bne .3

	lda PPU_DATA
	sta <GAME_PLR_X+1
	lda PPU_DATA
	sta <GAME_PLR_Y+1
	lda #0
	sta <GAME_PLR_X
	sta <GAME_PLR_Y
	sta <GAME_DONE
	sta <GAME_DONE+1
	sta <GAME_DONE_SCR

	lda PPU_DATA
	sta <GAME_DONE_CNT
	lda PPU_DATA
	sta <GAME_DONE_CNT+1
	lda PPU_DATA
	sta <GAME_DONE_INC
	lda PPU_DATA
	sta <GAME_DONE_INC+1

	ldy #0					;replace tile codes with tile numbers
.5
	lda GAME_MAP,y
	asl a
	asl a
	sta <TEMP
	jsr rand
	and #3
	clc
	adc <TEMP
	tax
	lda tilesList,x
	sta GAME_MAP,y
	lda GAME_MAP+256,y
	asl a
	asl a
	sta <TEMP
	jsr rand
	and #3
	clc
	adc <TEMP
	tax
	lda tilesList,x
	sta GAME_MAP+256,y
	iny
	bne .5

	ldx #0					;draw borders
.6
	lda #$01
	sta GAME_MAP,x
	sta GAME_MAP+32,x
	lda #$03
	sta GAME_MAP+64,x
	lda #$08
	sta GAME_MAP+448,x
	inx
	cpx #32
	bne .6

	ldx #12
	lda #96
	sta <TEMP
	lda #HIGH(GAME_MAP)
	sta <TEMP+1
.7
	ldy #0
	lda #$05
	sta [TEMP],y
	ldy <GAME_MAP_WDT
	iny
	lda #$06
	sta [TEMP],y
	lda <TEMP
	clc
	adc #32
	sta <TEMP
	lda <TEMP+1
	adc #0
	sta <TEMP+1
	dex
	bne .7

	lda #$02
	sta GAME_MAP+64
	lda #$04
	ldx <GAME_MAP_WDT
	inx
	sta GAME_MAP+64,x
	lda #$07
	sta GAME_MAP+448
	lda #$09
	sta GAME_MAP+448,x

	ldx #0
	lda #0
.8
	sta GAME_MAP+32*15,x
	inx
	cpx #32
	bne .8

	lda <GAME_MAP_WDT		;clear field outside of the level
	cmp #30
	beq drawField
	lda #30
	sec
	sbc <GAME_MAP_WDT
	sta <TEMP
	lda #14
	sta <TEMP+1
	lda # LOW(GAME_MAP)
	sta <TEMP+2
	lda #HIGH(GAME_MAP)
	sta <TEMP+3
.9
	ldx <TEMP
	lda <GAME_MAP_WDT
	clc
	adc #2
	tay
	lda #0
.10
	sta [TEMP+2],y
	iny
	dex
	bne .10
	lda <TEMP+2
	clc
	adc #32
	sta <TEMP+2
	lda <TEMP+3
	adc #0
	sta <TEMP+3
	dec <TEMP+1
	bne .9

drawField
	ldy #0
.1
	ldx #0
.2
	txa
	pha
	tya
	pha
	jsr updateTile
	pla
	tay
	pla
	tax
	inx
	cpx #32
	bne .2
	iny
	cpy #15
	bne .1

	lda #$20
	sta PPU_ADDR
	lda #$40
	sta PPU_ADDR
	ldx #0
	ldy #64
.3
	lda gameStatNameTable,x
	sta PPU_DATA
	inx
	dey
	bne .3

setSprite0
	jsr clearOAM

	lda #32
	sta OAM_PAGE
	lda #$ab
	sta OAM_PAGE+1
	lda #0
	sta OAM_PAGE+2
	lda #0
	sta OAM_PAGE+3

	lda #0
	sta <GAME_UPDATE_X
	sta <GAME_UPDATE_Y
	jsr checkTile

	ldx #$46
	ldy #$20
	jsr setNumPos
	lda <GAME_LEVEL
	clc
	adc #1
	jsr putNum2

	jsr palReset
	ldx # LOW(palGame)
	ldy #HIGH(palGame)
	jsr palSetupBackground
	lda <GAME_LEVEL
	asl a
	clc
	adc <GAME_LEVEL
	tax
	lda palList,x
	sta PAL_DATA+1
	lda palList+1,x
	sta PAL_DATA+2
	lda palList+2,x
	sta PAL_DATA+7
	ldx # LOW(palGameSprites)
	ldy #HIGH(palGameSprites)
	jsr palSetupSprites

	lda PAL_DATA+7
	sta PAL_DATA+23

	jsr playerShow
	jsr updateFuelBar
	jsr palSetFadeIn
	jsr waitNMI
	lda #%00011110	;enable display, enable sprites
	sta PPU_MASK
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

mainLoop
	jsr waitNMI
	jsr setScrollTop
	jsr updateOAM

	jsr ntscIsSkip
	bcc updateVideo
	ldx #0
	jmp statusSplit

updateVideo
	jsr palUpdate

	ldx <GAME_UPDATE_X
	beq .noTile
	ldy <GAME_UPDATE_Y
	jsr updateTile
	lda #0
	sta <GAME_UPDATE_X
.noTile

	jsr fuelUpdate

	lda <GAME_DONE+1
	cmp <GAME_DONE_SCR
	beq .noNum
	sta <GAME_DONE_SCR
	ldx #$5a
	ldy #$20
	jsr setNumPos
	jsr putNum3
.noNum

	jsr resetPPUAdr
	ldx #1

statusSplit
	jsr fuelUpdateTime
	jsr waitSprite0

setScroll
	jsr setScrollBottom

	txa
	pha
	jsr FamiToneUpdate
	pla
	cmp #0			;check for skip frame for NTSC
	beq mainLoop

	lda <GAME_DELAY
	cmp #80
	beq .next1

	jsr playerShow

	lda <GAME_LSKIP
	beq .noLSkip
	jsr padPoll
	lda <PAD_STATE
	and #PAD_SELECT
	beq .noLSkip
	lda #GAME_FUEL_MAX
	sta <GAME_FUEL
	lda #80-1
	sta <GAME_DELAY
.noLSkip
	lda <GAME_FUEL
	cmp #GAME_FUEL_MAX
	beq .noFuelInc
	inc <GAME_FUEL
	inc <GAME_FUEL
	inc <GAME_FUEL
	inc <GAME_FUEL
.noFuelInc
	inc <GAME_DELAY

	jsr updateFuelBar
	jsr chrAnimation

	lda <GAME_DELAY
	cmp #80
	bne .checkDelay1
	ldx # LOW(bgm_game_module)
	ldy #HIGH(bgm_game_module)
	jsr FamiToneMusicStart
	jmp mainLoop

.checkDelay1
	cmp #20
	bne .checkDelay2
	lda #SFX_ENGINE_START
	jsr sfxPlay
.checkDelay2
	jmp mainLoop

.next1
	lda <GAME_PAUSED
	beq checkPad

	jsr padPoll
	lda <PAD_STATET
	cmp #PAD_START
	bne .next2
	lda #SFX_PAUSE
	jsr sfxPlay
	jsr palSetFadeIn
	lda #0
	sta <GAME_PAUSED
	jsr FamiToneMusicPause
.next2
	jmp mainLoop

checkPad
	lda <GAME_DONE_CNT		;if level is clear of fuel is out, don't allow player to move
	ora <GAME_DONE_CNT+1
	beq .noCheck
	lda <GAME_FUEL
	beq .noCheck
	jmp .check
.noCheck
	jmp .skip

.check
	jsr padPoll

	lda <PAD_STATE
	and #PAD_LEFT
	beq .noLeft
	lda <GAME_DIR
	cmp #DIR_RIGHT
	beq .left
	lda <GAME_PLR_X+1
	cmp #1
	beq .noLeft
.left
	lda <GAME_DIR
	lda #DIR_LEFT
	sta <GAME_DIR_NEW
.noLeft
	lda <PAD_STATE
	and #PAD_RIGHT
	beq .noRight
	lda <GAME_PLR_X+1
	cmp <GAME_MAP_WDT
	beq .noRight
	lda #DIR_RIGHT
	sta <GAME_DIR_NEW
.noRight
	lda <PAD_STATE
	and #PAD_UP
	beq .noUp
	lda <GAME_DIR
	cmp #DIR_DOWN
	beq .up
	lda <GAME_PLR_Y+1
	cmp #3
	beq .noUp
.up
	lda #DIR_UP
	sta <GAME_DIR_NEW
.noUp
	lda <PAD_STATE
	and #PAD_DOWN
	beq .noDown
	lda <GAME_PLR_Y+1
	cmp #13
	beq .noDown
	lda #DIR_DOWN
	sta <GAME_DIR_NEW
.noDown
	lda <PAD_STATE
	and #(PAD_A|PAD_B)
	beq .noFire
	lda <GAME_BOOST
	bne .noBoost
	lda #SFX_ENGINE_TURBO
	jsr sfxPlay
	lda #1
	sta <GAME_BOOST
.noBoost
	lda <GAME_SPEED
	cmp #48
	bcs .skip
	inc <GAME_SPEED
	inc <GAME_SPEED
	jmp .skip
.noFire
	lda <PAD_STATET
	and #PAD_START
	beq .noStart
	lda #1
	sta <GAME_PAUSED
	jsr FamiToneMusicPause
	lda #SFX_PAUSE
	jsr sfxPlay
	jsr palSetFadeHalf
.noStart
	lda <PAD_STATET
	and #PAD_SELECT
	beq .noSelect
	lda <GAME_LSKIP
	beq .noSelect
	lda #0
	sta <GAME_DONE_CNT
	sta <GAME_DONE_CNT+1
.noSelect

	lda <GAME_SPEED
	cmp #16
	bcc .skip
	lda #0
	sta <GAME_BOOST
	dec <GAME_SPEED
	lda <FRAME_CNT
	and #1
	bne .skip
	lda <GAME_SPEED
	cmp #16
	bcc .skip
	dec <GAME_SPEED
.skip
	jsr setSpeed

	lda <GAME_DIR
	cmp #DIR_NONE
	bne .noDir
	lda <GAME_DIR_NEW
	sta <GAME_DIR
	sta <GAME_DIR_PREV
.noDir

playerMove
	lda <GAME_DIR		;set delta x,y according to speed and direction
	cmp #DIR_LEFT
	beq .left
	cmp #DIR_RIGHT
	beq .right
	cmp #DIR_UP
	beq .up
	cmp #DIR_DOWN
	beq .down
	lda #0
	sta <GAME_PLR_DX
	sta <GAME_PLR_DX+1
	sta <GAME_PLR_DY
	sta <GAME_PLR_DY+1
	sta <GAME_PLR_OFF
	sta <GAME_PLR_OFF+1
	jmp .done
.left
	lda <GAME_SPEEDM
	sta <GAME_PLR_DX
	lda <GAME_SPEEDM+1
	sta <GAME_PLR_DX+1
	lda #0
	sta <GAME_PLR_DY
	sta <GAME_PLR_DY+1
	jmp .done
.right
	lda <GAME_SPEEDP
	sta <GAME_PLR_DX
	lda <GAME_SPEEDP+1
	sta <GAME_PLR_DX+1
	lda #0
	sta <GAME_PLR_DY
	sta <GAME_PLR_DY+1
	jmp .done
.up
	lda <GAME_SPEEDM
	sta <GAME_PLR_DY
	lda <GAME_SPEEDM+1
	sta <GAME_PLR_DY+1
	lda #0
	sta <GAME_PLR_DX
	sta <GAME_PLR_DX+1
	jmp .done
.down
	lda <GAME_SPEEDP
	sta <GAME_PLR_DY
	lda <GAME_SPEEDP+1
	sta <GAME_PLR_DY+1
	lda #0
	sta <GAME_PLR_DX
	sta <GAME_PLR_DX+1
	jmp .done
.done

	lda <GAME_PLR_X		;add delta x,y to player x,y
	clc
	adc <GAME_PLR_DX
	sta <GAME_PLR_X
	lda <GAME_PLR_X+1
	adc <GAME_PLR_DX+1
	sta <GAME_PLR_X+1
	lda <GAME_PLR_Y
	clc
	adc <GAME_PLR_DY
	sta <GAME_PLR_Y
	lda <GAME_PLR_Y+1
	adc <GAME_PLR_DY+1
	sta <GAME_PLR_Y+1

	lda <GAME_PLR_OFF	;add speed to offset
	clc
	adc <GAME_SPEEDP
	sta <GAME_PLR_OFF
	lda <GAME_PLR_OFF+1
	adc <GAME_SPEEDP+1
	sta <GAME_PLR_OFF+1

	lda <GAME_DIR
	cmp #DIR_LEFT
	bne .noClipLeft
	lda <GAME_PLR_X+1
	bne .noClipLeft
	lda #1
	sta <GAME_PLR_X+1
	jsr checkTileClip
.noClipLeft
	lda <GAME_DIR
	cmp #DIR_RIGHT
	bne .noClipRight
	lda <GAME_PLR_X+1
	cmp <GAME_MAP_WDT
	bne .noClipRight
	lda <GAME_MAP_WDT
	sta <GAME_PLR_X+1
	jsr checkTileClip
.noClipRight
	lda <GAME_DIR
	cmp #DIR_UP
	bne .noClipUp
	lda <GAME_PLR_Y+1
	cmp #2
	bne .noClipUp
	lda #3
	sta <GAME_PLR_Y+1
	jsr checkTileClip
.noClipUp
	lda <GAME_DIR
	cmp #DIR_DOWN
	bne .noClipDown
	lda <GAME_PLR_Y+1
	cmp #13
	bne .noClipDown
	lda #13
	sta <GAME_PLR_Y+1
	jsr checkTileClip
.noClipDown

	lda <GAME_PLR_OFF+1
	beq .noNewTile

	jsr checkTile

	lda #0
	sta <GAME_PLR_OFF+1

	lda <GAME_DIR_NEW	;if there is direction change, coords should be aligned to tile grid
	cmp <GAME_DIR
	beq .noChange

	jsr playerTileCoordsAlign

.change
	lda <GAME_DIR_NEW
	sta <GAME_DIR
	sta <GAME_DIR_PREV
	lda #0
	sta <GAME_PLR_X
	sta <GAME_PLR_Y
	sta <GAME_PLR_OFF
.noChange

	lda #1
	sta <GAME_CHECK_EXIT

.noNewTile

	jsr playerShow

	lda <FRAME_CNT
	and #1
	beq .noFuelDec
	lda <GAME_FUEL
	beq .noFuelDec
	lda #1
	jsr fuelSubtract
.noFuelDec
	jsr updateFuelBar

	jsr chrAnimation

	lda <GAME_CHECK_EXIT
	bne .checkExit
	lda <GAME_DIR
	cmp #DIR_NONE
	beq .checkExit
	jmp mainLoop

.checkExit
	lda #0
	sta <GAME_CHECK_EXIT

	lda <GAME_DONE_CNT
	ora <GAME_DONE_CNT+1
	beq levelClear

	lda <GAME_FUEL
	bne .noExitFuel
	jmp outOfFuel
.noExitFuel

	jmp mainLoop


levelClear
	jsr FamiToneMusicStop

	lda #0
	;sta <GAME_CAM_Y
	sta <GAME_CAM_SHAKE
	sta <GAME_GRASS_TYPE
	sta <GAME_PAUSED
	jsr playerShow

	lda #80
	sta <GAME_DELAY
.loop
	jsr waitNMI
	jsr setScrollTop
	jsr updateOAM
	jsr palUpdate
	jsr fuelUpdate

	ldx <GAME_UPDATE_X
	ldy <GAME_UPDATE_Y
	jsr updateTile

	ldx #$5a
	ldy #$20
	jsr setNumPos
	lda #100
	jsr putNum3

	jsr resetPPUAdr

	jsr waitSprite0
	jsr setScrollBottom
	jsr FamiToneUpdate

	jsr ntscIsSkip
	bcs .loop

	jsr playerShow
	jsr chrAnimation

	lda <GAME_DELAY
	cmp #70
	bne .noSfx1
	lda #SFX_MUTE
	jsr sfxPlayGrass
	lda #SFX_MUTE
	jsr sfxPlayFuel
.noSfx1
	lda <GAME_DELAY
	cmp #50
	bne .noSfx2
	lda #SFX_ENGINE_STOP
	jsr sfxPlay
.noSfx2

	lda <GAME_LSKIP
	beq .noSkip
	jsr padPoll
	lda <PAD_STATE
	and #PAD_SELECT
	beq .noSkip
	lda #1
	sta <GAME_DELAY
.noSkip

	dec <GAME_DELAY
	bne .loop

	ldx # LOW(bgm_levelclear_module)
	ldy #HIGH(bgm_levelclear_module)
	jsr FamiToneMusicStart

	ldx # LOW(msgLevelClear)
	ldy #HIGH(msgLevelClear)
	jsr showMessage

	inc <GAME_LEVEL
	lda <GAME_LEVEL
	cmp #GAME_LEVELS_ALL
	bcs gameClear
	jmp initLevel


gameClear
	lda #0
	sta PPU_MASK
	lda #200
	sta <GAME_DELAY

	ldx # LOW(doneNameTable)
	ldy #HIGH(doneNameTable)
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	jsr unrle

	ldx # LOW(bgm_welldone_module)
	ldy #HIGH(bgm_welldone_module)
	jsr FamiToneMusicStart

	jsr palReset
	ldx # LOW(palDone)
	ldy #HIGH(palDone)
	jsr palSetupBackground
	jsr palSetFadeIn

	lda #%00001110	;enable display, disable sprites
	sta PPU_MASK
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

.loop
	jsr waitNMI
	jsr palUpdate
	jsr resetPPUAdr

	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL
	lda <GAME_CHR_ANIM
	sta PPU_CTRL

	jsr FamiToneUpdate

	jsr chrAnimation

	jsr ntscIsSkip
	bcs .loop

	lda <GAME_DELAY
	cmp #16
	bcs .checkPad
	inc <GAME_DELAY
	lda <GAME_DELAY
	cmp #16
	beq .done
	jmp .loop

.checkPad
	jsr padPoll
	lda <PAD_STATET
	cmp #PAD_START
	bne .loop

	jsr FamiToneMusicStop
	jsr palSetFadeOut
	lda #0
	sta <GAME_DELAY
	lda #SFX_SKIP
	jsr sfxPlay
	jmp .loop

.done
	lda #0
	sta PPU_MASK
	jmp initGame


outOfFuel
	jsr FamiToneMusicStop
	lda #SFX_MUTE
	jsr sfxPlayGrass
	lda #SFX_MUTE
	jsr sfxPlayFuel
	jsr updateFuelBar

	lda #0
	;sta <GAME_CAM_Y
	sta <GAME_CAM_SHAKE
	sta <GAME_GRASS_TYPE
	sta <GAME_PAUSED
	jsr playerPixelCoordsAlign
	jsr playerShow

	lda #100
	sta <GAME_DELAY
.loop
	jsr waitNMI
	jsr setScrollTop
	jsr updateOAM
	jsr palUpdate
	jsr fuelUpdate

	ldx <GAME_UPDATE_X
	ldy <GAME_UPDATE_Y
	jsr updateTile
	jsr resetPPUAdr

	jsr waitSprite0
	jsr setScrollBottom
	jsr FamiToneUpdate

	jsr ntscIsSkip
	bcs .loop

	jsr playerShow
	jsr chrAnimation

	lda <GAME_DELAY
	cmp #95
	bne .noSfx1
	lda #SFX_ENGINE_STALL
	jsr sfxPlay
.noSfx1
	lda <GAME_DELAY
	cmp #50
	bne .noSfx2
	lda #SFX_ENGINE_STOP
	jsr sfxPlay
.noSfx2

	dec <GAME_DELAY
	bne .loop

	ldx # LOW(bgm_outoffuel_module)
	ldy #HIGH(bgm_outoffuel_module)
	jsr FamiToneMusicStart

	ldx # LOW(msgOutOfFuel)
	ldy #HIGH(msgOutOfFuel)
	jsr showMessage

	jmp initLevel


;show a middle screen message
;in: X,Y address of message tile map (large tiles)

showMessage
	stx <TEMP
	sty <TEMP+1
	lda <GAME_CAM_X+1
	asl a
	asl a
	asl a
	asl a
	sta <TEMP+2
	lda <GAME_CAM_X
	lsr a
	lsr a
	lsr a
	lsr a
	ora <TEMP+2
	sta <GAME_UPDATE_X
	clc
	adc #-1
	eor #31
	and #15
	tay
	ldx #0
.fill
	lda [TEMP],y
	sta GAME_MAP+32*7,x
	tya
	clc
	adc #16
	tay
	lda [TEMP],y
	sta GAME_MAP+32*8,x
	tya
	clc
	adc #16
	tay
	lda [TEMP],y
	sta GAME_MAP+32*9,x
	tya
	sec
	sbc #31
	and #15
	tay
	inx
	cpx #32
	bne .fill

	lda #0
	sta <GAME_UPDATE_Y
	lda #$80
	sta <GAME_CHR_ANIM
.loop
	jsr waitNMI
	jsr setScrollTop
	jsr updateOAM

	lda <GAME_UPDATE_Y
	cmp #16
	bcc .loop0
	ldx <GAME_UPDATE_X
	lda #$16
	sta GAME_MAP+7*32,x
	lda #$17
	sta GAME_MAP+8*32,x
	lda #$18
	sta GAME_MAP+9*32,x
.loop0

	ldx <GAME_UPDATE_X
	ldy #7
	jsr updateTile
	ldx <GAME_UPDATE_X
	ldy #8
	jsr updateTile
	ldx <GAME_UPDATE_X
	ldy #9
	jsr updateTile
	jsr resetPPUAdr

	jsr waitSprite0
	jsr setScrollBottom
	jsr FamiToneUpdate
	jsr ntscIsSkip
	bcs .loop

	lda <GAME_UPDATE_X
	asl a
	asl a
	asl a
	asl a
	sec
	sbc <GAME_CAM_X
	clc
	adc #24
	sta <TEMP

	lda <GAME_CAM_X+1
	beq .hide
	lda <GAME_UPDATE_X
	cmp #16
	bcc .skipHide
.hide
	ldx #OAM_PLAYER
.hideSpr
	lda OAM_PAGE,x
	cmp #7*16-8
	bcc .noHide
	cmp #10*16-1
	bcs .noHide
	lda <TEMP
	cmp OAM_PAGE+3,x
	bcc .noHide
	lda #$ef
	sta OAM_PAGE,x
.noHide
	inx
	inx
	inx
	inx
	cpx #OAM_FUEL_BAR
	bne .hideSpr

.skipHide
	lda <GAME_UPDATE_X
	clc
	adc #1
	and #31
	sta <GAME_UPDATE_X
	inc <GAME_UPDATE_Y
	lda <GAME_UPDATE_Y
	cmp #32
	beq .next
	jmp .loop
.next

	lda #0
	sta <GAME_FLASH_CNT
	sta <GAME_DELAY

.delay
	jsr waitNMI
	jsr setScrollTop
	jsr palUpdate

	ldx <GAME_UPDATE_X
	ldy #5
	jsr updateTile
	ldx <GAME_UPDATE_X
	ldy #6
	jsr updateTile
	ldx <GAME_UPDATE_X
	ldy #7
	jsr updateTile
	jsr resetPPUAdr

	jsr waitSprite0
	jsr setScrollBottom

	ldx #110
	lda <GAME_NTSC
	bne .wait0
	ldx #100
.wait0
	ldy #16
.wait1
	dey
	bne .wait1
	dex
	bne .wait0

	lda <GAME_FLASH_CNT
	lsr a
	lsr a
	lsr a
	lsr a
	and #$01
	ora #$80
	sta PPU_CTRL

	ldx #50
.wait2
	ldy #16
.wait3
	dey
	bne .wait3
	dex
	bne .wait2

	jsr setScrollBottomSplit

	jsr FamiToneUpdate
	jsr ntscIsSkip
	bcs .delay

	lda <GAME_DELAY
	beq .checkPad
	dec <GAME_DELAY
	beq .done
	jmp .delay

.checkPad
	inc <GAME_FLASH_CNT

	jsr padPoll
	lda <PAD_STATET
	and #PAD_START
	beq .delay
	lda #16
	sta <GAME_DELAY
	lda #$80
	sta <GAME_FLASH_CNT
	jsr FamiToneMusicStop
	lda #SFX_SKIP
	jsr sfxPlay
	jsr palSetFadeOut
	jmp .delay

.done
	lda #0
	sta PPU_MASK
	rts


playerShow
	ldx <GAME_PLR_X
	ldy <GAME_PLR_X+1
	jsr fpInt
	txa
	sec
	sbc #128			;not in the middle to make map tile aligned when no movement
	sta <GAME_CAM_X
	tya
	sbc #0
	sta <GAME_CAM_X+1
	bcs .noClipLeft		;clip to 0 if negative
	lda #0
	sta <GAME_CAM_X
	sta <GAME_CAM_X+1
	jmp .camSet
.noClipLeft
	lda <GAME_CAM_X+1	;clip to max if greater than max
	cmp <GAME_CAM_MAX+1
	bcc .camSet
	bne .clipRight
	lda <GAME_CAM_X
	cmp <GAME_CAM_MAX
	bcs .clipRight
	jmp .camSet
.clipRight
	lda <GAME_CAM_MAX
	sta <GAME_CAM_X
	lda <GAME_CAM_MAX+1
	sta <GAME_CAM_X+1
.camSet

	lda <GAME_DIR_PREV
	cmp #DIR_LEFT
	beq .sprLeft
	cmp #DIR_RIGHT
	beq .sprRight
	cmp #DIR_UP
	beq .sprUp
	cmp #DIR_DOWN
	beq .sprDown
	jmp .noPlrSpr
.sprLeft
	ldx # LOW(metaSpritePlrLeft)
	ldy #HIGH(metaSpritePlrLeft)
	jmp .showPlrSpr
.sprRight
	ldx # LOW(metaSpritePlrRight)
	ldy #HIGH(metaSpritePlrRight)
	jmp .showPlrSpr
.sprUp
	ldx # LOW(metaSpritePlrUp)
	ldy #HIGH(metaSpritePlrUp)
	jmp .showPlrSpr
.sprDown
	ldx # LOW(metaSpritePlrDown)
	ldy #HIGH(metaSpritePlrDown)
.showPlrSpr
	jsr setMetaSprite
	ldx <GAME_PLR_X
	ldy <GAME_PLR_X+1
	jsr fpInt
	txa
	sec
	sbc <GAME_CAM_X
	sta <TEMP+4
	ldx <GAME_PLR_Y
	ldy <GAME_PLR_Y+1
	jsr fpInt
	txa
	tay
	ldx <TEMP+4
	lda #OAM_PLAYER
	jsr putMetaSprite
.noPlrSpr
	lda <GAME_CAM_SHAKE
	beq .noShake
	jsr rand
	and #1
	;sta <GAME_CAM_Y
	eor <GAME_CAM_X
	sta <GAME_CAM_X
.noShake

	ldx #$ac
	lda <GAME_GRASS_TYPE
	beq .noCut
	jsr rand
	and #3
	clc
	adc <GAME_GRASS_TYPE
	tax
.noCut
	stx OAM_PAGE+OAM_PLAYER+10*4+1
	rts


setScrollTop
	lda #$80
	sta PPU_CTRL
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL
	rts


setScrollBottom
	lda <GAME_CAM_X+1
	and #1
	ora <GAME_CHR_ANIM
	sta PPU_CTRL
	lda <GAME_CAM_X
	sta PPU_SCROLL
	lda #0
	sta PPU_SCROLL
	rts


;	lda <GAME_CAM_X+1	;this does not work on HW properly, this is for vertical shake effect
;	and #1
;	asl a
;	asl a
;	sta PPU_ADDR	;---- NN--
;	lda <GAME_CAM_Y
;	sta PPU_SCROLL	;VV-- -vvv
;	lda <GAME_CAM_X
;	and #7
;	sta PPU_SCROLL	;---- -hhh
;	lda <GAME_CAM_X
;	lsr a
;	lsr a
;	lsr a
;	ora #$80
;	sta PPU_ADDR	;VVVH HHHH
;
;	lda <GAME_CAM_X+1
;	and #1
;	ora <GAME_CHR_ANIM
;	sta PPU_CTRL
;
;	rts


setScrollBottomSplit
	lda <GAME_CAM_X+1
	and #1
	ora #$80
	sta PPU_CTRL
	lda <GAME_CAM_X
	sta PPU_SCROLL
	lda #0
	sta PPU_SCROLL
	rts


chrAnimation
	lda <GAME_DELAY
	cmp #30
	bcc .noPlr
	ldx #3
	lda <GAME_DELAY
	cmp #60
	bcs .fast
	ldx #16
.fast
	txa
	and <FRAME_CNT
	bne .noPlr
	lda <GAME_CHR_ANIM
	eor #$08
	sta <GAME_CHR_ANIM
.noPlr
	lda <FRAME_CNT
	and #15
	bne .noBg
	lda <GAME_CHR_ANIM
	eor #$10
	sta <GAME_CHR_ANIM
.noBg
	rts


fuelUpdate
	lda <GAME_PAUSED
	bne .noAnim
	ldx <GAME_FUEL_X
	beq .noAnim
	ldy #0
	lda <FRAME_CNT
	lsr a
	lsr a
	lsr a
	and #1
	clc
	adc #$2e
	sta [GAME_FUEL_PTR],y
	ldy <GAME_FUEL_Y
	jsr updateTile
.noAnim
	rts


fuelUpdateTime
	lda <GAME_PAUSED
	bne .noDec
	lda <GAME_DELAY
	cmp #80
	bne .noDec
	lda <GAME_FUEL_X
	bne .noDec
	lda <GAME_FUEL_TIME
	ora <GAME_FUEL_TIME+1
	bne .noAdd
	jsr fuelAdd
	jsr fuelSetTimer
	jmp .noDec
.noAdd
	lda <GAME_FUEL_TIME
	bne .noDecH
	dec <GAME_FUEL_TIME+1
.noDecH
	dec <GAME_FUEL_TIME
.noDec

	lda <GAME_FUEL_NX		;generate new position if it is not generated yet
	bne .done
	jsr rand
	and #31
	ldx <GAME_MAP_WDT
	jsr max
	sta <TEMP
	inc <TEMP
	jsr rand
	and #15
	ldx #11
	jsr max
	clc
	adc #3
	sta <TEMP+1
	sta <GAME_FUEL_NPTR+1
	ror <GAME_FUEL_NPTR+1
	ror <GAME_FUEL_NPTR
	ror <GAME_FUEL_NPTR+1
	ror <GAME_FUEL_NPTR
	ror <GAME_FUEL_NPTR+1
	ror <GAME_FUEL_NPTR
	lda <GAME_FUEL_NPTR
	and #$e0
	ora <TEMP
	sta <GAME_FUEL_NPTR
	lda <GAME_FUEL_NPTR+1
	and #1
	clc
	adc #HIGH(GAME_MAP)
	sta <GAME_FUEL_NPTR+1
	ldy #0
	lda [GAME_FUEL_NPTR],y
	cmp #$0a
	bcc .done
	cmp #$0e
	bcs .done
	lda <TEMP
	sta <GAME_FUEL_NX
	lda <TEMP+1
	sta <GAME_FUEL_NY
.done
	rts


fuelAdd
	lda <GAME_FUEL_NX
	beq .done
	sta <GAME_FUEL_X
	lda <GAME_FUEL_NY
	sta <GAME_FUEL_Y
	lda <GAME_FUEL_NPTR
	sta <GAME_FUEL_PTR
	lda <GAME_FUEL_NPTR+1
	sta <GAME_FUEL_PTR+1
	lda #0
	sta <GAME_FUEL_NX
	lda #SFX_FUEL_ON_FIELD
	jsr sfxPlayFuel
.done
	rts


fuelSetTimer
	lda <GAME_LEVEL
	asl a
	tax
	jsr rand
	and #31
	clc
	adc fuelTimeList,x
	sta <GAME_FUEL_TIME
	lda #0
	adc fuelTimeList+1,x
	sta <GAME_FUEL_TIME+1
	rts


setSpeed
	lda <GAME_SPEED
	sta <GAME_SPEEDP
	clc
	adc #-1
	eor #255
	sta <GAME_SPEEDM
	lda #0
	sta <GAME_SPEEDP+1
	adc #255
	eor #255
	sta <GAME_SPEEDM+1
	rts


checkTileClip
	lda #0
	sta <GAME_PLR_X
	sta <GAME_PLR_Y
	sta <GAME_PLR_OFF
	sta <GAME_PLR_OFF+1
	lda #DIR_NONE
	sta <GAME_DIR

checkTile
	lda <GAME_PLR_X+1
	sta <GAME_PLR_TX
	lda <GAME_PLR_Y+1
	sta <GAME_PLR_TY
	lda <GAME_DIR
	cmp #DIR_LEFT
	bne .1
	lda <GAME_PLR_X
	beq .2
	inc <GAME_PLR_TX
	jmp .2
.1
	cmp #DIR_UP
	bne .2
	lda <GAME_PLR_Y
	beq .2
	inc <GAME_PLR_TY
.2

	lda <GAME_PLR_TY
	sta <GAME_TILE_ADR+1
	lda #0
	sta <GAME_TILE_ADR
	ror <GAME_TILE_ADR+1
	ror <GAME_TILE_ADR
	ror <GAME_TILE_ADR+1
	ror <GAME_TILE_ADR
	ror <GAME_TILE_ADR+1
	ror <GAME_TILE_ADR
	lda <GAME_TILE_ADR+1
	and #$1f
	clc
	adc #HIGH(GAME_MAP)
	sta <GAME_TILE_ADR+1
	ldy <GAME_PLR_TX
	sty <GAME_UPDATE_X
	ldx <GAME_PLR_TY
	stx <GAME_UPDATE_Y
	lda #0
	sta <GAME_CAM_SHAKE
	;sta <GAME_CAM_Y
	lda #GAME_GTYPE_NONE
	sta <GAME_GRASS_TYPE
	lda [GAME_TILE_ADR],y
	cmp #$0e
	bcc .noGrass
	cmp #$12
	bcs .noGrass
	jmp cutGrass
.noGrass
	cmp #$12
	bne .noFlowers
	jmp cutFlowers
.noFlowers
	cmp #$13
	bne .noFlowersCut
	jmp cutFlowersCut
.noFlowersCut
	cmp #$14
	bne .noStone
	jmp cutStone
.noStone
	cmp #$2e
	bcc .noFuel
	cmp #$30
	bcs .noFuel
	jmp cutFuel
.noFuel
	lda #SFX_MUTE
	jmp sfxPlayGrass


cutGrass
	sec
	sbc #4
	sta [GAME_TILE_ADR],y
	lda <GAME_DONE
	clc
	adc <GAME_DONE_INC
	sta <GAME_DONE
	lda <GAME_DONE+1
	adc <GAME_DONE_INC+1
	sta <GAME_DONE+1
	lda <GAME_DONE_CNT
	ora <GAME_DONE_CNT+1
	beq .1
	dec <GAME_DONE_CNT
	lda <GAME_DONE_CNT
	cmp #$ff
	bne .1
	dec <GAME_DONE_CNT+1
.1
	lda #GAME_GTYPE_GRASS
	sta <GAME_GRASS_TYPE
	lda #SFX_GRASS_CUT
	jmp sfxPlayGrass


cutFlowers
	lda #$13
	sta [GAME_TILE_ADR],y
	lda #GAME_FUEL_MAX/6
	jsr fuelSubtract
	lda #GAME_GTYPE_FLOWERS
	sta <GAME_GRASS_TYPE
	lda #SFX_FLOWERS
	jmp sfxPlayGrass


cutFlowersCut
	jsr rand
	and #3
	clc
	adc #$0a
	sta [GAME_TILE_ADR],y
	lda #GAME_GTYPE_GRASS
	sta <GAME_GRASS_TYPE
	lda #SFX_GRASS_CUT
	jmp sfxPlayGrass


cutStone
	lda #1
	sta <GAME_CAM_SHAKE
	lda #GAME_FUEL_MAX/3
	jsr fuelSubtract
	lda #SFX_STONE
	jmp sfxPlay


cutFuel
	lda #0
	sta <GAME_FUEL_X
	sta <GAME_FUEL_Y
	tay
	jsr rand
	and #3
	clc
	adc #$0a
	sta [GAME_FUEL_PTR],y
	lda #GAME_FUEL_MAX
	sta <GAME_FUEL
	lda #SFX_FUEL_GET
	jmp sfxPlayFuel


fuelSubtract
	sta <TEMP
	lda <GAME_FUEL
	sta <TEMP+1
	sec
	sbc <TEMP
	bcs .1
	lda #0
.1
	sta <GAME_FUEL
	lda <TEMP+1
	cmp #GAME_FUEL_MAX/4
	bcc .2
	lda <GAME_FUEL
	cmp #GAME_FUEL_MAX/4
	bcs .2
	lda #SFX_FUEL_LOW
	jsr sfxPlayFuel
.2
	rts


;align player coords to the tile and pixel grid

playerPixelCoordsAlign
	;jsr playerTileCoordsAlign
	;lda #0
	;sta <GAME_PLR_X
	;sta <GAME_PLR_Y
	lda <GAME_PLR_X
	cmp #128
	bcc .left
	lda <GAME_PLR_X+1
	cmp <GAME_MAP_WDT
	beq .left
	inc <GAME_PLR_X+1
.left
	lda <GAME_PLR_Y
	cmp #128
	bcc .up
	lda <GAME_PLR_Y+1
	cmp #13
	beq .up
	inc <GAME_PLR_Y+1
.up
	lda #0
	sta <GAME_PLR_X
	sta <GAME_PLR_Y
	jmp playerShow


;align player coords to the tile grid according to current direction

playerTileCoordsAlign
	lda <GAME_DIR
	cmp #DIR_LEFT
	bne .checkUp
	lda <GAME_PLR_X
	beq .done
	lda <GAME_PLR_X+1
	cmp <GAME_MAP_WDT
	beq .done
	inc <GAME_PLR_X+1
	rts
.checkUp
	cmp #DIR_UP
	bne .done
	lda <GAME_PLR_Y
	beq .done
	lda <GAME_PLR_Y+1
	cmp #13
	beq .done
	inc <GAME_PLR_Y+1
.done
	rts


;update fuel bar

updateFuelBar
	lda <GAME_FUEL
	lsr a
	lsr a
	sta <TEMP+1
	lda #0
	sta <TEMP
	ldx #OAM_FUEL_BAR
	lda #8
	sta <TEMP+2
.1
	lda <TEMP+1
	ldy #$ef
	cmp <TEMP
	bcc .2
	ldy #21
.2
	tya
	sta OAM_PAGE,x	;y
	inx
	ldy #$f8
	lda <TEMP+1
	sec
	sbc <TEMP
	cmp #8
	bcs .3
	clc
	adc #$f0
	tay
.3
	tya
	sta OAM_PAGE,x	;tile
	inx
	lda #0
	sta OAM_PAGE,x	;palette
	inx
	lda <TEMP
	clc
	adc #107
	sta OAM_PAGE,x	;x
	inx
	lda <TEMP
	clc
	adc #8
	sta <TEMP
	dec <TEMP+2
	bne .1

	ldx #$27
	lda <TEMP+1
	cmp #GAME_FUEL_MAX/4/4
	bcs .4
	lda <FRAME_CNT
	and #$10
	beq .4
	ldx #$16
.4
	stx PAL_DATA+18
	rts


;returns integer part of a fixed point number
;in:  X,Y fixed point number
;out: X,Y integer part

fpInt
	stx <TEMP+2
	sty <TEMP+3
	ror <TEMP+3
	ror <TEMP+2
	ror <TEMP+3
	ror <TEMP+2
	ror <TEMP+3
	ror <TEMP+2
	ror <TEMP+3
	ror <TEMP+2
	ldx <TEMP+2
	lda <TEMP+3
	and #$0f
	tay
	rts


;get address of a tile with given coords in GAME_MAP
;in:  X,Y coords of a tile 0..31,0..15
;out: GAME_TILE_ADR address

getTileAddr
	sty <GAME_TILE_ADR		;y*32+x
	lda #0
	sta <GAME_TILE_ADR+1
	asl <GAME_TILE_ADR
	rol <GAME_TILE_ADR+1
	asl <GAME_TILE_ADR
	rol <GAME_TILE_ADR+1
	asl <GAME_TILE_ADR
	rol <GAME_TILE_ADR+1
	asl <GAME_TILE_ADR
	rol <GAME_TILE_ADR+1
	asl <GAME_TILE_ADR
	rol <GAME_TILE_ADR+1
	txa
	clc
	adc <GAME_TILE_ADR
	sta <GAME_TILE_ADR
	lda <GAME_TILE_ADR+1
	adc #HIGH(GAME_MAP)
	sta <GAME_TILE_ADR+1
	rts


;update a tile with given coords in the nametable
;in: X,Y coords of a tile 0..31,0..15

updateTile
	stx <TEMP
	sty <TEMP+1
	sty <TEMP+4
	txa
	lsr a
	lsr a
	and #$04
	ora #$20
	sta <TEMP+3		;nametable address

	jsr getTileAddr	;get the tile from the map
	ldy #0
	lda [GAME_TILE_ADR],y
	asl a
	asl a
	clc
	adc [GAME_TILE_ADR],y
	tax

	lda #0			;get nametable address, y*64+(x&15)*2
	sta <TEMP+2
	clc
	ror <TEMP+1
	ror <TEMP+2
	clc
	ror <TEMP+1
	ror <TEMP+2		;H +1, L +2
	lda <TEMP
	and #15
	asl a
	clc
	adc <TEMP+2
	sta <TEMP+2
	tay
	lda <TEMP+1
	adc <TEMP+3
	sta <TEMP+1
	sta PPU_ADDR
	sty PPU_ADDR

	lda tilesTable,x
	sta PPU_DATA
	lda tilesTable+1,x
	sta PPU_DATA

	lda <TEMP+2
	clc
	adc #$20
	tay
	lda <TEMP+1
	adc #0
	sta PPU_ADDR
	sty PPU_ADDR

	lda tilesTable+2,x
	sta PPU_DATA
	lda tilesTable+3,x
	sta PPU_DATA
	stx <TEMP+5

	lda <TEMP		;get attributes mask
	and #1
	sta <TEMP+1
	lda <TEMP+4
	asl a
	and #2
	ora <TEMP+1
	tax
	lda attrMasks,x
	sta <TEMP+1
	eor #$ff
	sta <TEMP+2

	lda <TEMP+4		;get attributes address, y/2*8+(x&15)/2
	and #$0e
	asl a
	asl a
	sta <TEMP+4
	lsr <TEMP
	lda <TEMP
	and #$07
	clc
	adc <TEMP+4
	clc
	adc #$c0
	tax
	lda #$03
	clc
	adc <TEMP+3
	sta PPU_ADDR
	stx PPU_ADDR

	ldy PPU_DATA
	ldy PPU_DATA
	sta PPU_ADDR
	stx PPU_ADDR

	tya
	and <TEMP+2
	sta <TEMP+2
	ldx <TEMP+5
	lda tilesTable+4,x
	and <TEMP+1
	ora <TEMP+2
	sta PPU_DATA

	rts


;set address of a metasprite structure
;in: X,Y address

setMetaSprite
	stx <TEMP
	sty <TEMP+1
	rts


;put a metasprite into OAM buffer
;in: X,Y screen coords
;    A offset in OAM in bytes

putMetaSprite
	dey
	stx <TEMP+2
	sty <TEMP+3
	tax
	ldy #0
.1
	lda [TEMP],y
	beq .2
	iny
	sta <TEMP+4
	lda <TEMP+3
	clc
	adc [TEMP],y
	iny
	sta OAM_PAGE,x
	inx
	lda <TEMP+4
	sta OAM_PAGE,x
	inx
	lda [TEMP],y
	iny
	sta OAM_PAGE,x
	inx
	lda <TEMP+2
	clc
	adc	[TEMP],y
	iny
	sta OAM_PAGE,x
	inx
	jmp .1
.2
	rts


;set position to draw a number
;in: X,Y nametable offset

setNumPos
	stx <TEMP
	sty <TEMP+1
	rts


;draw a 3-digit number

putNum3
	ldx #-1
	sec
.1
	inx
	sbc #100
	bcs .1
	adc #100
	jsr putNum1

;draw a 2-digit number

putNum2
	ldx #-1
	sec
.1
	inx
	sbc #10
	bcs .1
	adc #10

	jsr putNum1
	tax

;draw a 1-digit number

putNum1
	sta <TEMP+2
	lda <TEMP+1
	sta PPU_ADDR
	lda <TEMP
	sta PPU_ADDR
	txa
	clc
	adc #$d0
	sta PPU_DATA
	adc #16
	tax
	lda <TEMP
	clc
	adc #32
	tay
	lda <TEMP+1
	adc #0
	sta PPU_ADDR
	sty PPU_ADDR
	stx PPU_DATA
	inc <TEMP
	lda <TEMP+2
	rts


;play sfx using FamiTone, always using the same channel
;in: A sound effect number

sfxPlay
	ldx #FT_SFX_CH0
	jmp FamiToneSfxStart

sfxPlayGrass
	ldx #FT_SFX_CH1
	jmp FamiToneSfxStart

sfxPlayFuel
	ldx #FT_SFX_CH2
	jmp FamiToneSfxStart


;Galois random generator, found somewhere
;out: A random number 0..255

rand
	lda <RAND_SEED
	asl a
	bcc .1
	eor #$cf
.1
	sta <RAND_SEED
	rts


;limit number with certain range
;in:  A value, X max
;out: A number 0..max-1

max
	stx <TEMP+4
	sec
.1
	sbc <TEMP+4
	bcs .1
	adc <TEMP+4
	rts


;wait for sprite 0 hit flag

waitSprite0
.1
	bit PPU_STATUS
	bvs .1
.2
	bit PPU_STATUS
	bvc .2
	rts


;reset PPU address

resetPPUAdr
	lda #0
	sta PPU_ADDR
	sta PPU_ADDR
	rts


waitVBlank
    bit PPU_STATUS
.1
    bit PPU_STATUS
    bpl .1
	rts


waitNMI
	lda <FRAME_CNT
.1
	cmp <FRAME_CNT
	beq .1
	rts


;if in NTSC mode, counts frames and returns C=1 every 6th frame

ntscIsSkip
	lda <GAME_NTSC
	beq .1
	inc <FRAME_CNT2
	lda <FRAME_CNT2
	cmp #5
	bne .1
	lda #0
	sta <FRAME_CNT2
	sec
	rts
.1
	clc
	rts


waitNMI50
	lda <FRAME_CNT
.1
	cmp <FRAME_CNT
	beq .1
	jsr ntscIsSkip
	bcc .2
	txa
	pha
	tya
	pha
	jsr FamiToneUpdate
	pla
	tay
	pla
	tax
	jmp waitNMI50
.2
	rts


clearOAM
	lda #$ff
	ldx #0
.1
	sta OAM_PAGE,x
	inx
	bne .1
	rts



updateOAM
	lda #0
	sta PPU_OAM_ADDR
	lda #HIGH(OAM_PAGE)
	sta PPU_OAM_DMA
	rts


;empty NMI handler

nmiEmpty
	inc <FRAME_CNT
	rti


	.include "controller.asm"
	.include "palette.asm"
	.include "rle.asm"
	.include "famitone.asm"
	.include "title.asm"
	.include "bgm_instruments.asm"
	.include "bgm_levelclear.asm"
	.include "bgm_outoffuel.asm"

fuelTimeList
	.dw 5*50
	.dw 5*50-15
	.dw 5*50-30
	.dw 4*50
	.dw 4*50-15
	.dw 4*50-30
	.dw 3*50
	.dw 3*50
	.dw 3*50
	.dw 3*50

levList
	.dw $1000+95*0
	.dw $1000+95*1
	.dw $1000+95*2
	.dw $1000+95*3
	.dw $1000+95*4
	.dw $1000+95*5
	.dw $1000+95*6
	.dw $1000+95*7
	.dw $1000+95*8
	.dw $1000+95*9


version
	.db "Lawn Mower v1.12 01.07.11"

	.bank 1
	.org $e000

	.include "bgm_title.asm"
	.include "bgm_game.asm"
	.include "bgm_welldone.asm"
	.include "sounds.asm"

doneNameTable
	.incbin "done.rle"


;attribute masks for tile drawing routine

attrMasks
	.db %00000011,%00001100,%00110000,%11000000

;tile number, y offset, palette, x offset

metaSpritePlrLeft
	.db $b8,0,$03,0		;top
	.db $b9,0,$03,8
	.db $ba,0,$03,16
	.db $bb,8,$03,0
	.db $bc,8,$03,8
	.db $b4,0,$02,0		;bottom
	.db $b5,0,$02,8
	.db $b6,8,$02,0
	.db $b7,8,$02,8
	.db $ac,0,$02,0		;empty
	.db $da,4,$01,16	;grass
	.db 0

metaSpritePlrRight
	.db $c9,0,$03,-8	;top
	.db $ca,0,$03,0
	.db $cb,0,$03,8
	.db $cc,8,$03,0
	.db $cd,8,$03,8
	.db $b4,0,$02,0		;bottom
	.db $b5,0,$02,8
	.db $b6,8,$02,0
	.db $b7,8,$02,8
	.db $ac,0,$02,0		;empty
	.db $da,4,$01,-8	;grass
	.db 0

metaSpritePlrUp
	.db $bd,0,$03,0		;top
	.db $be,0,$03,8
	.db $bf,8,$03,0
	.db $c0,8,$03,8
	.db $c1,16,$03,0
	.db $c2,16,$03,8
	.db $b0,0,$02,0		;bottom
	.db $b1,0,$02,8
	.db $b2,8,$02,0
	.db $b3,8,$02,8
	.db $da,16,$01,4	;grass
	.db 0

metaSpritePlrDown
	.db $c3,-8,$03,0	;top
	.db $c4,-8,$03,8
	.db $c5,0,$03,0
	.db $c6,0,$03,8
	.db $c7,8,$03,0
	.db $c8,8,$03,8
	.db $b0,0,$02,0		;bottom
	.db $b1,0,$02,8
	.db $b2,8,$02,0
	.db $b3,8,$02,8
	.db $da,-8,$01,4	;grass
	.db 0

;four tile numbers, palette as HLHLHLHL

tilesTable
	.db $00,$00,$00,$00,$00	;00 empty
	.db $a9,$a9,$a9,$a9,$00	;01 border empty
	.db $aa,$aa,$a0,$a1,$00	;02 border top,left
	.db $aa,$aa,$a2,$a2,$00	;03 border top
	.db $aa,$aa,$a6,$a0,$00	;04 border top,right
	.db $a0,$a3,$a0,$a3,$00	;05 border left
	.db $a7,$a0,$a7,$a0,$00	;06 border right
	.db $a0,$a4,$a0,$a0,$00	;07 border bottom,left
	.db $a5,$a5,$a0,$a0,$00	;08 border bottom
	.db $a8,$a0,$a0,$a0,$00	;09 border bottom,right
	.db $80,$81,$90,$91,$aa	;0a cut 1
	.db $82,$83,$92,$93,$aa	;0b cut 2
	.db $80,$82,$92,$91,$aa	;0c cut 3
	.db $81,$80,$93,$92,$aa	;0d cut 4
	.db $84,$85,$94,$95,$aa	;0e grass 1
	.db $86,$87,$96,$97,$aa	;0f grass 2
	.db $84,$87,$96,$95,$aa	;10 grass 3
	.db $85,$86,$97,$94,$aa	;11 grass 4
	.db $88,$89,$98,$99,$55 ;12 flowers
	.db $8a,$8b,$9a,$9b,$aa ;13 flowers cut
	.db $8c,$8d,$9c,$9d,$ff ;14 stone 1
	.db $8e,$8f,$9e,$9f,$ff ;15 stone 2
	.db $ad,$ad,$af,$af,$00	;16 text top
	.db $af,$af,$af,$af,$00	;17 text middle
	.db $af,$af,$ae,$ae,$00	;18 text bottom
	.db $ad,$ad,$72,$af,$00	;19	L top
	.db $72,$af,$72,$af,$00	;1a L middle
	.db $7d,$7e,$ae,$ae,$00	;1b L bottom
	.db $ad,$ad,$79,$7a,$00	;1c E top
	.db $7b,$7c,$72,$af,$00	;1d E middle
	.db $ad,$ad,$72,$72,$00	;1e V top
	.db $72,$72,$72,$72,$00	;1f V middle
	.db $8e,$8f,$ae,$ae,$00	;20 V bottom
	.db $ad,$ad,$70,$71,$00	;21 C top
	.db $73,$74,$ae,$ae,$00	;22 C bottom
	.db $72,$72,$7b,$7f,$00	;23 A middle
	.db $72,$72,$ae,$ae,$00	;24 A bottom
	.db $ad,$ad,$79,$71,$00	;25 R top
	.db $72,$72,$7b,$9e,$00	;26 R middle
	.db $ad,$ad,$af,$5f,$00	;27 ! top
	.db $af,$72,$af,$6f,$00	;28 ! middle
	.db $af,$9f,$ae,$ae,$00	;29 ! bottom
	.db $ad,$ad,$75,$76,$00	;2a T top
	.db $77,$78,$77,$78,$00	;2b	T middle
	.db $77,$78,$ae,$ae,$00	;2c	T bottom
	.db $72,$af,$ae,$ae,$00	;2d F bottom
	.db $ce,$cf,$de,$df,$aa	;2e fuel 1
	.db $ce,$cf,$de,$df,$ff	;2f fuel 2

tilesList
	.db $0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$12,$12,$12,$14,$14,$14,$14

palList
	.db $11,$21,$25	;cyan
	.db $14,$24,$27	;magenta
	.db $17,$27,$26	;orange
	.db $19,$29,$21	;green
	.db $15,$25,$27	;cherry
	.db $18,$28,$25	;light brown
	.db $1a,$2a,$24 ;green 2
	.db $16,$26,$27	;red
	.db $1c,$2c,$2b	;cyan 2
	.db $1b,$2b,$2c	;green 3

gameStatNameTable
	.db $a9,$a9,$56,$55,$57,$58,$d0,$d0,$a9,$5d,$5e,$5b,$56,$f9,$fa,$fa
	.db $fa,$fa,$fa,$fa,$fb,$a9,$59,$5a,$58,$5b,$d0,$d0,$d0,$5c,$a9,$a9
	.db $a9,$a9,$66,$65,$67,$68,$e0,$e0,$a9,$6d,$6e,$6b,$66,$fc,$fd,$fd
	.db $fd,$fd,$fd,$fd,$fe,$a9,$69,$6a,$68,$6b,$e0,$e0,$e0,$6c,$a9,$a9

msgLevelClear
	.db $16,$16,$19,$1c,$1e,$1c,$19,$16,$21,$19,$1c,$21,$25,$27,$16,$16
	.db $17,$17,$1a,$1d,$1f,$1d,$1a,$17,$1a,$1a,$1d,$23,$26,$28,$17,$17
	.db $18,$18,$1b,$1b,$20,$1b,$1b,$18,$22,$1b,$1b,$24,$24,$29,$18,$18

msgOutOfFuel
	.db $16,$16,$21,$1e,$2a,$16,$21,$1c,$16,$1c,$1e,$1c,$19,$27,$16,$16
	.db $17,$17,$1f,$1f,$2b,$17,$1f,$1d,$17,$1d,$1f,$1d,$1a,$28,$17,$17
	.db $18,$18,$22,$22,$2c,$18,$22,$2d,$18,$2d,$22,$1b,$1b,$29,$18,$18


	.bank 1
    .org $fffa
    .dw  nmiEmpty
    .dw  reset
	.dw  0


    .bank 2
    .org $0000
    .incbin "patterns.chr"