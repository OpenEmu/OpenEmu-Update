;******************************************************************************
;* ingame codes
;*
;******************************************************************************

__INGAME_NATIVE = 1

.include "snes.inc"
.include "objects.inc"
.include "level.inc"
.include "graphics.inc"
.include "snes_joypad.inc"
.include "snes_decompress.inc"
.include "players.inc"
.include "snes_zvars.inc"
.include "ingame.inc"
.include "sprites.inc"
.include "explosion.inc"

.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"

.import oam_table, oam_hitable

.import Player1_DimPal
.import Player2_DimPal
.import Player3_DimPal

.import Arnold_Activate
.import Arnold_Disable
.import Arnold_Update
.import Arnold_Draw

.export BG3_Data
.export Timer
.export ExplodeSpace
.export UpdatePlayerPalettes
.export NextSobj
.export CameraX_Limit, CameraY_Limit

.export SpriteTransferQueue, SpriteTransferIndex

.exportzp ActivePlayer

.global RunGame

.importzp frame_ready


;====================================================================
; DEFS
;====================================================================

LASERTILES = 0000h
BG3MAP = 800H
IBGTILES = 1180H
IBGMAP = 1000H
IBG2TILES = 2000H
IBG2MAP = 3800H
CVTILES = 6000H+20480
EXPTILES = 0d000H


BOSS_LEVEL = 8

.macro DEBUG_CPU_START
;	stz	REG_CGADD
;	lda	#1Fh
;	sta	REG_CGDATA
;	stz	REG_CGDATA
.endmacro

.macro DEBUG_CPU_END
;	stz	REG_CGADD
;	lda	#07Ch
;	stz	REG_CGDATA
;	sta	REG_CGDATA
.endmacro

;====================================================================
	.zeropage
;====================================================================

ActivePlayer:
	.res 1
	
PlayerPalettesDirty:
	.res 1
CameraScroll:
	.res 1

	.exportzp CameraScroll
	.exportzp Flipper
Flipper:
	.res 1
Timer:
	.res 2
	
.exportzp CameraPX, CameraPY, CameraTileX, CameraTileY
CameraX:
	.res	1
CameraTileX:
	.res	1

CameraY:
	.res	1
CameraTileY:
	.res	1

CameraTX:
	.res	2
CameraTY:
	.res	2

	
CameraPX:
	.res	2
CameraPY:
	.res	2

P1_StatusPal:
	.res	1
P2_StatusPal:
	.res	1
P3_StatusPal:
	.res	1
	
Conveyor_Tile:
	.res	1
	
ENDTIMER:
	.res 1
RESULT:
	.res 1
RESTARTLEVEL:
	.res 1
	
FADEIN:
	.res 1
GAMEPAUSE:
	.res 1

;====================================================================
	.bss
;====================================================================

;********************************************************************
;* camera positions
;*
;* 12.4 fixed point (0.0 -> mapwidth/height*16-screenwidth/height)
;* x = current position, Tx = target position, Px = pixel conversions
;********************************************************************
	
;CAMERAX_MAX = (1024-256)*16
;CAMERAY_MAX = (512-SCREENHEIGHT)*16
CameraX_Limit:	.res 2
CameraY_Limit:	.res 2
CAMSCROLL_RATE = 100
	
HOFS_Shadow:	.res 2
VOFS_Shadow:	.res 2

;
; 32x2 statusbar info
;
Status_Shadow:
	.res 2*32*2
StatusDirty:
	.res	1
;
; 32x12 BG3 shadow
;
BG3_Data:
	.res 2*32*12

;***************************************************
;* 32x32 sprite transfers
;
; format:
;   1 byte: SRCBANK
;   2 bytes: SRCADDR
;   2 bytes: DESTADDR
;***************************************************
SpriteTransferQueue:		;
	.res 5*8		;
SpriteTransferIndex:		;
	.res 2			;
;---------------------------------------------------

NSOBJ = 16
SOBJ_BASE = 64

.export SobjXL, SobjXH, SobjA1, SobjA2, SobjA3, SobjSize
.exportzp SobjY

SobjXL:
	.res NSOBJ ; 0..255
SobjXH:
	.res NSOBJ ; 0/1
SobjA1:
	.res NSOBJ ; oam:attr1
SobjA2:
	.res NSOBJ ; oam:attr2
SobjA3:
	.res NSOBJ ; oam:attr3
SobjSize:
	.res NSOBJ ; 0/1
	
NextSobj:
	.res 1
	
	.zeropage
	
SobjY:
	.res NSOBJ+1 ; 1..224 (0 = disabled)
	
	.segment "XCODE"
	.a8
	.i16
	
;============================================================================
.macro AdjustCameraPos source, targ, pixelcpy
;============================================================================
	lda	targ		; source += (targ-source) / 16
	sec			;
	sbc	source		;
	cmp	#8000h		;
	ror			;
	cmp	#8000h		;
	ror			;
	cmp	#8000h		;
	ror			;
	cmp	#8000h		;
	ror			;
	clc			;
	adc	source		;
;----------------------------------------------------------------------------
	sta	source		; copy = round(source / 16)
	lsr			;
	lsr			;
	lsr			;
	lsr			;
;	adc	#0		;
	sta	pixelcpy	;
;----------------------------------------------------------------------------
.endmacro

CAMSPEED = 150

	.i8

;========================================================================================
RunSort:
;========================================================================================
	ldx	#128
	lda	#1
.repeat NSOBJ, i
	cmp	SobjY+i
	bcs	:+
	lda	SobjY+i
	ldx	#i
:
.endrep
	rts
	
	.i16

	.export SortSprites
;========================================================================================
SortSprites:
;========================================================================================
	
	lda	#^oam_table		; setup WMDATA address
	sta	REG_WMADDH		;
	ldx	#.LOWORD(oam_table+SOBJ_BASE*4)	;
	stx	REG_WMADDL		;
	sep	#10h			; 8bit index
	stz	m2+1			;
;----------------------------------------------------------------------------------------
.macro Sort4 mm
;----------------------------------------------------------------------------------------
.scope
	lda	#4			; m2 = reverse iterator
	sta	m2			;
;----------------------------------------------------------------------------------------
sort_loop:
;----------------------------------------------------------------------------------------
	jsr	RunSort			; do sorting
	cpx	#0			; if x >= 128 then terminate
	bmi	@end_of_sorting		;
;----------------------------------------------------------------------------------------
	stz	SobjY, x		; reset Y entry
	lda	SobjXL, x		; copy data
	sta	REG_WMDATA		;
	lda	SobjA1, x		;
	sta	REG_WMDATA		;
	lda	SobjA2, x		;
	sta	REG_WMDATA		;
	lda	SobjA3, x		;
	sta	REG_WMDATA		;
;---------------------------------------------------------------------------------------
	lda	SobjXH, x		; shift x msb into mm
	lsr				;
	ror	mm			;
;---------------------------------------------------------------------------------------
	lda	SobjSize, x		; shift size into mm
	lsr				;
	ror	mm			;
;---------------------------------------------------------------------------------------
	dec	m2			; loop upto 4 times
	bne	sort_loop		;
;---------------------------------------------------------------------------------------
	bra	:+++			; jump to next function
;---------------------------------------------------------------------------------------
@end_of_sorting:			; jump to end of sorting
	ldx	m2
	beq	:++
:	lsr	mm
	lsr	mm
	dex
	bne	:-
:
	jmp	end_of_sorting		;
;---------------------------------------------------------------------------------------
:	inc	m2+1			; increment x4 counter
.endscope
.endmacro
	Sort4	m0			; do sorting for 16 entries
	Sort4	m0+1			;
	Sort4	m1			;
	Sort4	m1+1			;
;---------------------------------------------------------------------------------------
end_of_sorting:
;---------------------------------------------------------------------------------------
	asl	m2+1			; x = (m2.H*4) + (4-m2.L)
	asl	m2+1			;
	lda	#4			;
	sec				;
	sbc	m2			;
	clc				;
	adc	m2+1			;
	sbc	#16-1			;
	eor	#0FFh			;
	ina				;
	tax				;
;---------------------------------------------------------------------------------------
	lda	#224			; clear the remaining sprite entries
	cpx	#0			; 
	beq	:++			;
:	stz	REG_WMDATA		;
	sta	REG_WMDATA		;
	stz	REG_WMDATA		;
	stz	REG_WMDATA		;
	dex				;
	bne	:-			;
:					;
;---------------------------------------------------------------------------------------
	rep	#10h			;
	ldx	m0			; copy hitable entries
	stx	oam_hitable+SOBJ_BASE/4
	ldx	m1			;
	stx	oam_hitable+SOBJ_BASE/4+2
;---------------------------------------------------------------------------------------
	rts
;---------------------------------------------------------------------------------------	

;---------------------------------------------------------------------------------------	
.macro UpdateBG3
;---------------------------------------------------------------------------------------
	lda	#80h
	sta	REG_VMAIN
	ldx	#BG3MAP/2
	stx	REG_VMADD
	
	lda	#1
	sta	REG_DMAP7
	lda	#<REG_VMDATA
	sta	REG_BBAD7
	ldx	#2*32*12
	stx	REG_DAS7
	lda	#^BG3_Data
	sta	REG_A1B7
	ldx	#.LOWORD(BG3_Data)
	stx	REG_A1T7
	lda	#1<<7
	sta	REG_MDMAEN
.endmacro

; y =base
; x=cbase
;--------------------------------------------------------------------------------------
InitStatus:
;--------------------------------------------------------------------------------------
	stx	m0
	lda	#(2<<2)+(1<<5)
	sta	Status_Shadow+(32+2)*2+1,y
	sta	Status_Shadow+(32+3)*2+1,y
	rep	#21h
	lda	#(1<<13)+(2<<10)
	adc	m0
	sta	Status_Shadow+(5)*2,y
	ina
	sta	Status_Shadow+(6)*2,y
	ina
	sta	Status_Shadow+(7)*2,y
	ina
	sta	Status_Shadow+(8)*2,y
	lda	#4+(1<<13)+(2<<10)
	adc	m0
	sta	Status_Shadow+(5+32)*2,y
	ina
	sta	Status_Shadow+(6+32)*2,y
	ina
	sta	Status_Shadow+(7+32)*2,y
	ina
	sta	Status_Shadow+(8+32)*2,y
	sep	#20h
	lda	#(2<<2)|(1<<5)
	sta	Status_Shadow+(9)*2+1,y
	sta	Status_Shadow+(9+32)*2+1,y
;	sta	Status_Shadow+(8)*2+1,y
;	sta	Status_Shadow+(9)*2+1,y
;	sta	Status_Shadow+(5+32)*2+1,y
;	sta	Status_Shadow+(6+32)*2+1,y
;	sta	Status_Shadow+(8+32)*2+1,y
;	sta	Status_Shadow+(9+32)*2+1,y
;	lda	#'X'
;	sta	Status_Shadow+(5)*2,y
;	lda	#'A'
;	sta	Status_Shadow+(8)*2,y
;	lda	#'Y'
;	sta	Status_Shadow+(5+32)*2,y
;	lda	#'B'
;	sta	Status_Shadow+(8+32)*2,y
	rts
	
.macro SetupAvatar base, pic
	ldx	#IBG2MAP/2+2+base*10+1*32
	stx	REG_VMADD
	ldx	#pic|(2<<10)
	stx	REG_VMDATA
	ldx	#(pic+1)|(2<<10)
	stx	REG_VMDATA
	ldx	#IBG2MAP/2+2+base*10+2*32
	stx	REG_VMADD
	ldx	#(pic+16)|(2<<10)
	stx	REG_VMDATA
	ldx	#(pic+17)|(2<<10)
	stx	REG_VMDATA
	
	; setup key too :)
	ldx	#(IBG2MAP/2+36+base*10)
	stx	REG_VMADD
	ldx	#0|(1<<13)|(2<<10)
	stx	REG_VMDATA
	
.endmacro
	

;------------------------------------------------------------------------------
; a = LEVEL
;==============================================================================
RunGame:
;==============================================================================
	
	pha
	
	sei
	jsr	Objects_Reset
	lda	#3
	sta	NextSobj
	
	jsr	spcStop
	jsr	spcFlush
	
	pla
	sep	#10h
	tax
	pha
	
	cpx	#BOSS_LEVEL
	bne	:+
	rep	#10h
	bra	@skip_start_music
:
	
	lda	LEVEL_MUSICS, x
	tax
	rep	#10h
	
	
	jsr	spcLoad
	
	ldx	#140
	jsr	spcSetModuleVolume
	
	ldx	#0
	jsr	spcPlay
	
@skip_start_music:
	
	jsr	spcFlush
	

	
	lda	#30
	sta	ENDTIMER
	
	DoCopyPalette gfx_player1Pal, 128, 16
	DoCopyPalette Player2_DimPal, 144, 16
	DoCopyPalette Player3_DimPal, 160, 16
	
	DoCopyPalette gfx_dongles1Pal, 176, 16
	DoDecompressDataVram gfx_dongles1Tiles, 0C800H
	
	DoCopyPalette gfx_infobar_bgPal, 16, 16
	DoDecompressDataVram gfx_infobar_bgTiles, IBGTILES
	DoDecompressDataVram gfx_infobar_bgMap, IBGMAP
	
	DoCopyPalette gfx_laserPal, 0, 16
	DoDecompressDataVram gfx_laserTiles, LASERTILES
	
	DoDecompressDataVram gfx_sfontTiles, IBG2TILES
	DoCopyPalette gfx_sfontPal, 32, 16
	
	DoDecompressDataVram gfx_explosionTiles, EXPTILES
	DoCopyPalette gfx_explosionPal, 192, 16
	
	DoCopyPalette gfx_baddiePal, 208, 16
	DoCopyPalette gfx_baddiePal, 224, 16
	
	
	stz	REG_BG12NBA
	stz	REG_BG34NBA
	
	lda	#(BG3MAP/800h)<<2
	sta	REG_BG3SC
	stz	REG_BG3HOFS
	stz	REG_BG3HOFS
	stz	REG_BG3VOFS
	stz	REG_BG3VOFS
	
	pla
	jsr	Level_Load
	
	DoCopyPalette SpTilePalette, (48+4*16), 16
	
	; <setup phase>
	
	lda	#OBSEL_16_32 | OBSEL_BASE(0C000h) | OBSEL_NN_16K
	sta	REG_OBSEL
	
	stz	SpriteTransferIndex
	stz	SpriteTransferIndex+1
	stz	SpriteTransferQueue
	
	lda	#^oam_table
	sta	REG_WMADDH
	ldy	#.LOWORD(oam_table)
	sty	REG_WMADDL
	
	ldy	#128
	lda	#224
:	stz	REG_WMDATA
	sta	REG_WMDATA
	stz	REG_WMDATA
	stz	REG_WMDATA
	dey
	bne	:-
	
.repeat NSOBJ+1, i
	stz	SobjY+i
.endrep
	
	stz	ActivePlayer
	
	jsr	Objects_DoInit
	
;--------------------------------------------------------
	.importzp CURRENT_LEVEL
	lda	CURRENT_LEVEL
	cmp	#BOSS_LEVEL
	bne	:+
	jsr	Arnold_Activate
	bra	:++
:	jsr	Arnold_Disable
:
;--------------------------------------------------------
	
	jsr	Sprites_Reset
	
	jsr	UpdatePlayerPalettes
	
	stz	FADEIN
	
	ResetExplosion
	
	
	lda	ActivePlayer
	rep	#20h
	and	#255
	tay
	
	sep	#20h
	lda	PL_XH, y
	xba
	lda	PL_XL, y
	rep	#21h
	sbc	#(128)*16
	bpl	:+
	lda	#0
	bra	:++
:	cmp	CameraX_Limit
	bcc	:+
	lda	CameraX_Limit
:	sta	CameraX

	sep	#20h
	lda	PL_YH, y
	xba
	lda	PL_YL, y
	rep	#21h
	sbc	#((SCREENHEIGHT/2)+16)*16
	bpl	:+
	lda	#0
	bra	:++
:	cmp	CameraY_Limit
	bcc	:+
	lda	CameraY_Limit
:	sta	CameraY
	sep	#20h

	stz	GAMEPAUSE
	
	
	
;----------------------------------------------------------------------------
; full clear on bg3
;----------------------------------------------------------------------------
	lda	#80h
	sta	REG_VMAIN
	ldx	#BG3MAP/2
	stx	REG_VMADD
	ldy	#0
	
	ldx	#32*32
	
:	sty	REG_VMDATA
	dex
	bne	:-

;----------------------------------------------------------------------------
; fill up status bg
;----------------------------------------------------------------------------
	lda	#80h				; clear to black
	sta	REG_VMAIN			;
	ldx	#IBG2MAP/2			;
	stx	REG_VMADD			;
	ldx	#16|(2<<10)|(1<<14)|(1<<15)	;
	ldy	#32*6				;
:	stx	REG_VMDATA			;
	dey					;
	bne	:-				;
;----------------------------------------------------------------------------
	ldy	#0
	
.macro copycname
	.local	@next_name
:	lda	character_names, y
	beq	@next_name
	iny
	sta	REG_VMDATAL
	lda	#(2<<2)|(1<<5)
	sta	REG_VMDATAH
	bra	:-
@next_name:
	iny
.endmacro
	
	ldx	#IBG2MAP/2+5+1*32
	stx	REG_VMADD
	copycname
	
	ldx	#IBG2MAP/2+15+1*32
	stx	REG_VMADD
	copycname
	
	ldx	#IBG2MAP/2+25+1*32
	stx	REG_VMADD
	copycname
	
	lda	#80h
	sta	REG_VMAIN
	
	SetupAvatar 0, 1
	SetupAvatar 1, 3
	SetupAvatar 2, 5
	
	rep	#20h
	lda	#16+(2<<10)
	ldy	#2*32*2-2
:	sta	Status_Shadow, y
	dey
	dey
	bpl	:-
	sep	#20h
	
	ldy	#0
	ldx	#128
	jsr	InitStatus
	ldy	#20
	ldx	#136
	jsr	InitStatus
	ldy	#40
	ldx	#144
	jsr	InitStatus
	
	jsr	UpdateHearts
	jsr	UpdatePlayerMoves
	
;----------------------------------------------------------------------------
; setup hdma
;----------------------------------------------------------------------------
	lda	#%011			; 0,1 = 2 regs write twice each
	sta	REG_DMAP0		; (HOFS/VOFS)
	sta	REG_DMAP1		;
;----------------------------------------------------------------------------
	lda	#%001
	sta	REG_DMAP4		; SC
;----------------------------------------------------------------------------
	lda	#%000			; 2,3 = 1 reg write once
	sta	REG_DMAP2		; (TM, BGMODE)
	sta	REG_DMAP3		;
	sta	REG_DMAP5		; NBA
;----------------------------------------------------------------------------
	lda	#<REG_BG1HOFS		; set targets
	sta	REG_BBAD0		;
	lda	#<REG_BG2HOFS		;
	sta	REG_BBAD1		;
	lda	#<REG_TM		;
	sta	REG_BBAD2		;
	lda	#<REG_BGMODE		;
	sta	REG_BBAD3		;
	lda	#<REG_BG1SC
	sta	REG_BBAD4
	lda	#<REG_BG12NBA
	sta	REG_BBAD5
;----------------------------------------------------------------------------
	ldx	#.LOWORD(dmatab_bg1s)	; setup source tables
	stx	REG_A1T0		;
	lda	#^dmatab_bg1s		;
	sta	REG_A1B0		;
	ldx	#.LOWORD(dmatab_bg2s)	;
	stx	REG_A1T1		;
	lda	#^dmatab_bg2s		;
	sta	REG_A1B1		;
	ldx	#.LOWORD(dmatab_tm)	;
	stx	REG_A1T2		;
	lda	#^dmatab_tm		;
	sta	REG_A1B2		;
	ldx	#.LOWORD(dmatab_bgmode)	;
	stx	REG_A1T3		;
	lda	#^dmatab_bgmode		;
	sta	REG_A1B3		;
	ldx	#.LOWORD(dmatab_bgsc)
	stx	REG_A1T4
	lda	#^dmatab_bgsc
	sta	REG_A1B4
	ldx	#.LOWORD(dmatab_bgnba)
	stx	REG_A1T5
	lda	#^dmatab_bgnba
	sta	REG_A1B5
;----------------------------------------------------------------------------
	
	cli
	wai
	
;----------------------------------------------------------------------------
	
	lda	#%111111
	sta	REG_HDMAEN
	
	lda	#%100
	sta	REG_TS
	lda	#%10
	sta	REG_CGSWSEL
	lda	#%00011
	sta	REG_CGADSUB
	
	
	stz	RESTARTLEVEL
;----------------------------------------------------------------------------
GameLoop:
;----------------------------------------------------------------------------

	DEBUG_CPU_START
	
	lda	GAMEPAUSE
	beq	:+
	jmp	_PAUSE_SKIP_UPDATE
:

	lda	Flipper
	eor	#128
	sta	Flipper
	
;----------------------------------------------------------------------------
	lda	#^BG3_Data			; Clear BG3 shadow
	sta	REG_WMADDH			;
	ldx	#.LOWORD(BG3_Data)		;
	stx	REG_WMADDL			;
						;
	lda	#%00001000			;
	sta	REG_DMAP7			;
	lda	#<REG_WMDATA			;
	sta	REG_BBAD7			;
	lda	#^bg3_clearbytes		;
	sta	REG_A1B7			;
	ldx	#.LOWORD(bg3_clearbytes)	;
	stx	REG_A1T7			;
	ldx	#2*32*12			;
	stx	REG_DAS7			;
	lda	#1<<7				;
	sta	REG_MDMAEN			;
;----------------------------------------------------------------------------
	
.repeat 3, i
	stz	PL_KeyV+i
	stz	PL_KeyH+i
	stz	PL_KeyM+i
.endrep

	sep	#10h
	ldy	ActivePlayer
	rep	#10h

	lda	PL_HP, y
	bne	:+
	lda	PL_State, y
	cmp	#PLSTATE_REALLYDEAD
	BEQ	@death_scroll
:
	stz	CameraScroll
	lda	joy1_held
	and	#JOYPAD_R
	beq	:+
@death_scroll:
	lda	#128
	sta	CameraScroll
:	
	
	
;----------------------------------------------------------------------------
	lda	joy1_held+1		; process directional input
	bit	#JOYPADH_UP		; up/down
	beq	:+			;
	jsr	JoyUpHeld		;
	bra	@joy_skipv		;
:	bit	#JOYPADH_DOWN		;
	beq	:+			;
	jsr	JoyDownHeld		;
	bra	@joy_skipv		;
:	jsr	JoyNeutralV		;
@joy_skipv:				;
;----------------------------------------------------------------------------
	lda	joy1_held+1		; process left/right
	bit	#JOYPADH_LEFT		;
	beq	:+			;
	jsr	JoyLeftHeld		;
	bra	@joy_skiph		;
:	bit	#JOYPADH_RIGHT		;
	beq	:+			;
	jsr	JoyRightHeld		;
	bra	@joy_skiph		;
:	jsr	JoyNeutralH		;
@joy_skiph:				;
;----------------------------------------------------------------------------
	rep	#20h
	lda	joy1_down		; process X
	bit	#JOYPAD_X|JOYPAD_A	;
	sep	#20h
	beq	:+			;
	jsr	JoyMove1		;
:					;
;----------------------------------------------------------------------------
	rep	#20h
	lda	joy1_down		; process Y
	bit	#JOYPAD_Y|JOYPAD_B	;
	sep	#20h
	beq	:+			;
	jsr	JoyMove2		;
:					;
;----------------------------------------------------------------------------
	lda	joy1_down		; process L
	bit	#JOYPAD_L		;
	beq	:+			;
	jsr	JoyLclicked		;
:					;
;----------------------------------------------------------------------------
;	bit	joy1_down		; process A
;	bpl	:+
;	jsr	JoyAclicked		;
;:					;
;----------------------------------------------------------------------------
	lda	joy1_down+1
	bit	#JOYPADH_START
	beq	:+
	lda	FADEIN
	cmp	#15<<1
	bcc	:+
	lda	#1
	sta	GAMEPAUSE
	
	ldx	#63
	jsr	spcSetModuleVolume
:
;----------------------------------------------------------------------------
;	bit	joy1_down		; debug 'A'
;	bpl	:+			;
;	lda	PL_YH+0
;	xba
;	lda	PL_XH+0
;	jsr	Explosion_MiniStart
;:
;----------------------------------------------------------------------------
	
	jsr	Objects_Update
	jsr	Players_Update
	jsr	Explosion_Update
	jsr	Arnold_Update
	
	bit	CameraScroll
	bmi	@skip_cam_centering
	
	lda	ActivePlayer
	rep	#20h
	and	#255
	tay
	
	sep	#20h
	lda	PL_XH, y
	xba
	lda	PL_XL, y
	rep	#21h
	sbc	#(128)*16
	bpl	:+
	lda	#0
	bra	:++
:	cmp	CameraX_Limit
	bcc	:+
	lda	CameraX_Limit
:	sta	CameraTX

	sep	#20h
	lda	PL_YH, y
	xba
	lda	PL_YL, y
	rep	#21h
	sbc	#((SCREENHEIGHT/2)+16)*16
	bpl	:+
	lda	#0
	bra	:++
:	cmp	CameraY_Limit
	bcc	:+
	lda	CameraY_Limit
:	sta	CameraTY
@skip_cam_centering:
	rep	#20h
	AdjustCameraPos CameraX, CameraTX, CameraPX
	AdjustCameraPos CameraY, CameraTY, CameraPY
	sep	#20h
	
	
	rep	#20h
	inc	Timer
	sep	#20h
	bra	_NOT_PAUSED
_PAUSE_SKIP_UPDATE:

	lda	joy1_down+1
	bit	#JOYPADH_START
	beq	:+
	ldx	#127
	jsr	spcSetModuleVolume
	stz	GAMEPAUSE
	bra	_NOT_PAUSED
:

	lda	joy1_down+1
	bit	#JOYPADH_SELECT
	beq	:+
	lda	#1
	sta	RESTARTLEVEL
:

_NOT_PAUSED:
	
	
	
	jsr	Objects_Draw
	jsr	Players_Draw
	jsr	Explosion_Draw
	jsr	Arnold_Draw
	
	
	jsr	SortSprites
	
	jsr	Sprites_Process
	
	lda	Conveyor_Tile
	ina
	and	#15
	sta	Conveyor_Tile

	ldx	SpriteTransferIndex		; terminate sprite transfer queue
	stz	SpriteTransferQueue, x		;
	
	lda	#1
	sta	frame_ready
	
	DEBUG_CPU_END
	
	jsr	spcProcess
	
;----------------------------------------------------------------------------
	wai
;----------------------------------------------------------------------------
	nop
	stz	frame_ready
	
	lda	FADEIN
	cmp	#15<<1
	beq	:+
	ina
	sta	FADEIN
	lsr
	sta	REG_INIDISP
	eor	#0Fh
	asl
	asl
	asl
	asl
	ora	#0Fh
	sta	REG_MOSAIC
	bra	@faded
:
	lda	GAMEPAUSE
	beq	:+
	lda	#0Ah
	sta	REG_INIDISP
	bra	@faded
:	lda	#0Fh
	sta	REG_INIDISP
@faded:
	
	UpdateBG3
	
	jsr	Level_ProcessErase
	
	lda	#80h
	sta	REG_VMAIN
;----------------------------------------------------------------------------
.repeat 3, i					; draw keys
;-----------------------------------------------;
	ldx	#(IBG2MAP/2+36+i*10)		;
	stx	REG_VMADD			;
	lda	PL_HasKey+i			;
	beq	:+				;
	lda	#8				;
	sta	REG_VMDATAL			;
	bra	:++				;
:	stz	REG_VMDATAL			;
:						;
.endrepeat					;
;----------------------------------------------------------------------------
	bit	PlayerPalettesDirty		; check if palette update needed
	bmi	:+
	jmp	@pal_not_dirty
:
;----------------------------------------------------------------------------
	stz	PlayerPalettesDirty		;
	lda	#<REG_CGDATA			; setup dma:
	sta	REG_BBAD7			; target = CGDATA
	lda	#%000				; control = 1 reg write once
	sta	REG_DMAP7			; 
	stz	REG_DAS7H			; transfer size H = 0
	lda	#80h				; CGADD = 128
	sta	REG_CGADD			;
	
;----------------------------------------------------------------------------
.macro cpypal source1, source2, index
;----------------------------------------------------------------------------
	lda	#^source1			;
	sta	REG_A1B7
	ldx	#.LOWORD(source1)		; source = AP == x ?
	lda	ActivePlayer			;    normalpal : dimpal
	cmp	#index				;
	beq	:+				;
	ldx	#.LOWORD(source2)		;
	lda	#^source2			;
	sta	REG_A1B7			;
:	stx	REG_A1T7			;
	lda	#32				; transfer 32 bytes
	sta	REG_DAS7L			;
	lda	#128				;
	sta	REG_MDMAEN			;
.endmacro
;----------------------------------------------------------------------------

	cpypal gfx_player1Pal, Player1_DimPal, 0
	cpypal gfx_player2Pal, Player2_DimPal, 1
	cpypal gfx_player3Pal, Player3_DimPal, 2
	
	lda	#17
	sta	REG_CGADD

;------------------------------------------------------------
.macro cpyibpal pal
;------------------------------------------------------------
	ldy	pal
	sep	#10h
	rep	#10h
.repeat 10, i
	lda	ib_pal_normal+i, y
	sta	REG_CGDATA
.endrepeat
.endmacro
;------------------------------------------------------------

	cpyibpal P1_StatusPal
	cpyibpal P2_StatusPal
	cpyibpal P3_StatusPal

@pal_not_dirty:
;----------------------------------------------------------------------------
	
	jsr	ProcessSpriteTransfers
	
	lda	#^gfx_conveyorTiles
	sta	REG_A1B7
	lda	#<gfx_conveyorTiles
	sta	REG_A1T7L
	lda	#>gfx_conveyorTiles
	adc	Conveyor_Tile
	sta	REG_A1T7H
	ldx	#CVTILES/2
	stx	REG_VMADD
	ldx	#128
	stx	REG_DAS7
	lda	#1<<7
	sta	REG_MDMAEN
	stx	REG_DAS7
	ldx	#(CVTILES+512)/2
	stx	REG_VMADD
	sta	REG_MDMAEN
	
	
;----------------------------------------------------------------------------
	bit	StatusDirty
	bpl	:+
	stz	StatusDirty
	lda	#%001
	sta	REG_DMAP7
	ldx	#Status_Shadow
	stx	REG_A1T7
	lda	#^Status_Shadow
	sta	REG_A1B7
	ldx	#IBG2MAP/2+96
	stx	REG_VMADD
	lda	#<REG_VMDATA
	sta	REG_BBAD7
	ldx	#2*32*2
	stx	REG_DAS7
	lda	#1<<7
	sta	REG_MDMAEN
:
;----------------------------------------------------------------------------
	rep	#20h				; Update scroll registers
	lda	CameraPX			;
	sta	f:dmatab_bg1s+1
	sta	f:dmatab_bg1s+6
	sta	f:dmatab_bg2s+1
	sta	f:dmatab_bg2s+6
	sep	#20h
	and	#15
	sta	REG_BG3HOFS
	stZ	REG_BG3HOFS
	rep	#20h
	lda	CameraPY			;
	dea					;-compensate for first unrendered line
	sta	f:dmatab_bg1s+3
	sta	f:dmatab_bg1s+8
	sta	f:dmatab_bg2s+3
	sta	f:dmatab_bg2s+8
	
	lda	CameraPY			;
	and	#15
	dea
	;clc
	;adc	#8-1
	ina
	ina
	sep	#20h
	sta	REG_BG3VOFS
	XBA
	sta	REG_BG3VOFS
	
;----------------------------------------------------------------------------

	
	jsr	TestEndOfGame
	cmp	#0
	bne	:+
	lda	RESTARTLEVEL
	bne	:+
	jmp	GameLoop
:	

	lda	PL_HP+0
	beq	@bad_end
	lda	PL_HP+1
	beq	@bad_end
	lda	PL_HP+2
	beq	@bad_end
	lda	#1
	sta	RESULT
	bra	@good_end
@bad_end:
	stz	RESULT
@good_end:
	lda	RESTARTLEVEL
	beq	:+
	stz	RESULT
:
	
	ldx	#0
	ldy	#8
	jsr	spcFadeModuleVolume
	
	lda	#30
	sta	ENDTIMER
	
:	jsr	spcProcess
	wai
	dec	ENDTIMER
	bne	:-
	
	ldx	#127
	jsr	spcSetModuleVolume

	lda	RESULT
	beq	:+
	ldx	#MOD_REALFANFARE
	bra	:++
:	ldx	#MOD_POOPLOSE
:
	jsr	spcLoad
	
	jsr	spcGetCues
	ldx	#0
	jsr	spcPlay
	
	
	jsr	spcFlush
	

	
:	jsr	spcReadStatus
	bit	#SPC_P
	bne	:-
	
	
:	wai
	wai
	jsr	spcProcess
	jsr	spcGetCues
	beq	:-
	
	ldx	#0
	ldy	#8
	jsr	spcFadeModuleVolume
	lda	#15<<1
	sta	ENDTIMER
:	wai
	lda	ENDTIMER
	lsr
	sta	REG_INIDISP
	jsr	spcProcess
	dec	ENDTIMER
	bne	:-
	
	stz	REG_HDMAEN
	lda	#80h
	sta	REG_INIDISP
	stz	REG_TM
	stz	REG_TS
	
	lda	RESULT
	rts
	
TestEndOfGame:
	lda	PL_Exited+0
	bne	:+
	lda	PL_HP+0
	bne	@not
:	lda	PL_Exited+1
	bne	:+
	lda	PL_HP+1
	bne	@not
:	lda	PL_Exited+2
	bne	:+
	lda	PL_HP+2
	bne	@not
:	lda	#1
	rts
@not:	lda	#0
	rts
	
	.export ProcessSpriteTransfers
;===================================================================================
ProcessSpriteTransfers:
;===================================================================================
	lda	#<REG_VMDATA			; prepare for vram transferring
	sta	REG_BBAD7			;
	lda	#80h				;
	sta	REG_VMAIN			;
	stz	SpriteTransferIndex		;
	lda	#%001				; [2 regs write twice]
	sta	REG_DMAP7			;
	stz	REG_DAS7H			;
	sep	#10h				; 8bit index
	ldx	#128				; x = xfer size
;----------------------------------------------------------------------------
	ldy	#0				; iterate through 32x32 spr transfers
next_sprite_transfer:				;
	sep	#20h
	lda	SpriteTransferQueue, y		;
	beq	@end_of_sprite_transfers	;
;----------------------------------------------------------------------------
	iny					; set bank
	sta	REG_A1B7			;
	rep	#21h				; 16bit akku, clear carry
	lda	SpriteTransferQueue, y		; copy src addr
	sta	REG_A1T7L			;
	iny					;
	iny					;
	lda	SpriteTransferQueue, y		; copy dest addr
	iny					;
	iny					;
	sta	REG_VMADD			;
	stx	REG_DAS7L			; reset xfer size
	phy					;
	ldy	#1<<7				;
	sty	REG_MDMAEN			; start transfer
;----------------------------------------------------------------------------
.repeat 3					; transfer remaining data
	adc	#256				;
	sta	REG_VMADD			;
	stx	REG_DAS7L			;
	sty	REG_MDMAEN			;
.endrepeat					;
;----------------------------------------------------------------------------
	ply
	bra	next_sprite_transfer
@end_of_sprite_transfers:

	rep	#11h				; restore 16bit index, clc
	sep	#20h
	;stz	SpriteTransferQueue
	rts
	
;============================================================================
JoyUpHeld:
;============================================================================
	bit	CameraScroll
	bmi	@scrollcam
	lda	#1
	sta	PL_KeyV, y
	rts
	
@scrollcam:
	rep	#20h
	lda	CameraTY
	sbc	#CAMSCROLL_RATE
	bpl	:+
	lda	#0
:	sta	CameraTY
	sep	#20h
	rts
	
;============================================================================
JoyLeftHeld:
;============================================================================
	bit	CameraScroll
	bmi	@scrollcam
	lda	#1
	sta	PL_KeyH, y
	rts
	
@scrollcam:
	rep	#20h
	lda	CameraTX
	sbc	#CAMSCROLL_RATE
	bpl	:+
	lda	#0
:	sta	CameraTX
	sep	#20h
	rts
	
;============================================================================
JoyDownHeld:
;============================================================================
	bit	CameraScroll
	bmi	@scrollcam
	lda	#2
	sta	PL_KeyV, y
	rts

@scrollcam:
	rep	#20h
	lda	CameraTY
	adc	#CAMSCROLL_RATE
	cmp	CameraY_Limit
	bcc	:+
	lda	CameraY_Limit
:	sta	CameraTY
	sep	#20h
	rts
	
;============================================================================
JoyRightHeld:
;============================================================================
	bit	CameraScroll
	bmi	@scrollcam
	
	lda	#2
	sta	PL_KeyH, y
	rts
	
@scrollcam:

	rep	#20h
	lda	CameraTX
	adc	#CAMSCROLL_RATE
	cmp	CameraX_Limit
	bcc	:+
	lda	CameraX_Limit
:	sta	CameraTX
	sep	#20h
	rts
	
;============================================================================
JoyMove1:
;============================================================================
	lda	#1
	sta	PL_KeyM, y
	rts
;============================================================================
JoyMove2:
;============================================================================
	lda	#2
	sta	PL_KeyM, y
	rts
	
;============================================================================
;JoyXclicked:
;============================================================================
;	lda	#1
;	sta	PL_KeyM, y
;	rts
	
;============================================================================
;JoyYclicked:
;============================================================================
;	lda	#2
;	sta	PL_KeyM, y
;	rts
	
;============================================================================
;JoyAclicked:
;============================================================================
;	lda	#4
;	sta	PL_KeyM, y
;	rts
	
;============================================================================
JoyLclicked:
;============================================================================

;----------------------------------------------------------------------------
	sep	#10h				;
	ldy	ActivePlayer			; find player that is not dead/exited
	ldx	#3 				; timeout
	rep	#10h				;
@find_player:					;
	dex
	beq	@timeout
	iny					;
	cpy	#3				;
	bne	:+				;
	ldy	#0				;
:	lda	PL_HP, y			;
	beq	@find_player			;
	lda	PL_Exited, y
	bne	@find_player
	bra	@found_player
@timeout:
	rts
;----------------------------------------------------------------------------
@found_player:
	tya
	sta	ActivePlayer
	
	spcPlaySoundM SND_MENU1
;	bra	UpdatePlayerPalettes
	
;============================================================================
UpdatePlayerPalettes:
;============================================================================

.macro upp target, hp, index
	.local @quit
	lda	PL_Exited+index
	beq	:+
	lda	#30
	sta	target
	bra	@quit
:	lda	hp			; hp=0 ? red
	bne	:+			;
	lda	#20			;
	sta	target			;
	bra	@quit			;
:	lda	ActivePlayer		; activeplayer ? light : normal
	cmp	#index			;
	bne	:+			;
	lda	#10			;
	sta	target			;
	bra	@quit			;
:	stz	target			;
@quit:
.endmacro

	upp	P1_StatusPal, PL_HP, 0
	upp	P2_StatusPal, PL_HP+1, 1
	upp	P3_StatusPal, PL_HP+2, 2
	
	lda	#128
	sta	PlayerPalettesDirty
	
	rts

;============================================================================
JoyNeutralV:
;============================================================================
	;stz	Player1_KeyV
	rts

;============================================================================
JoyNeutralH:
;============================================================================
	;stz	Player1_KeyH
	rts

;----------------------------------------------------------------------------
; a = src bank
; y = source
; x = dest
;----------------------------------------------------------------------------
	.export ScheduleSpriteXfer
;============================================================================
ScheduleSpriteXfer:
;============================================================================
	phy					; add entry to transfer queue
	ldy	SpriteTransferIndex		;
	sta	SpriteTransferQueue, y		;
	iny					;
	rep	#20h				;
	pla					;
	sta	SpriteTransferQueue, y		;
	iny					;
	iny					;
	txa					;
	sta	SpriteTransferQueue, y		;
	sep	#20h				;
	iny					;
	iny					;
	sty	SpriteTransferIndex		;
;----------------------------------------------------------------------------
	rts					;
	
	.export UpdatePlayerMoves
;==================================================================================
UpdatePlayerMoves:
;==================================================================================

.macro upm base, moves1, moves2 ;, moves3, moves4
	clc
	lda	moves1
	adc	#'0'
	sta	Status_Shadow+(base+9)*2
	lda	moves2
	adc	#'0'
	sta	Status_Shadow+(base+9+32)*2
.endmacro
	
	upm	0, PL_Moves1, PL_Moves2
	upm	10, PL_Moves1+1, PL_Moves2+1
	upm	20, PL_Moves1+2, PL_Moves2+2
	
	lda	#128
	sta	StatusDirty
;---------------------------------------------------------------------------------
	rts
	
	.export UpdateHearts
;==================================================================================
UpdateHearts:
;==================================================================================

.macro SetHearts base, hp
	stz	Status_Shadow+(32+base)*2
	stz	Status_Shadow+(32+base+1)*2
	
	lda	hp
	beq	:++
	cmp	#1
	beq	:+
	lda	#7
	sta	Status_Shadow+(32+base+1)*2
:	lda	#7
	sta	Status_Shadow+(32+base)*2
:
.endmacro

	SetHearts 2, PL_HP
	SetHearts 12, PL_HP+1
	SetHearts 22, PL_HP+2
	
	lda	#128
	sta	StatusDirty
	rts

	.export ExplodeSpace
;==============================================================================
ExplodeSpace:
;==============================================================================
; a= x
; b =y
;------------------------------------------------------------------------------
	rep	#20h
	pha
	sep	#20h
	jsr	Level_Destroy
	rep	#20h
	pla
	pha
	sep	#20h
	jsr	Players_ApplyExplosion
	rep	#20h
	pla
	pha
	sep	#20h
		.import Arnold_ApplyExplosion
	jsr	Arnold_ApplyExplosion
	rep	#20h
	pla
	sep	#20h
	sta	OTX
	xba
	sta	OTY
	jsr	Objects_Explosion
	
	rts

;=========================================================================================
	.segment "HDATA"
;=========================================================================================

;DEBUG_DISABLE_HDMA = 1
	
;-----------------------------------------------------------------------------------------
dmatab_bg1s:
;-----------------------------------------------------------------------------------------
	.byte 127
	.word 0, 0 ;bgscroll values
	.byte 49
	.word 0, 0 ;bgscroll values
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.word 0,-177 ; infobar
	.byte 0
;-----------------------------------------------------------------------------------------
dmatab_bg2s:
;-----------------------------------------------------------------------------------------
	.byte 127
	.word 0, 0
	.byte 49
	.word 0, 0
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.word 0, -177
	.byte 0
	
;=========================================================================================
	.code
;=========================================================================================


	
;-----------------------------------------------------------------------------------------
dmatab_tm:
;-----------------------------------------------------------------------------------------
	.byte 127
	.byte TM_BG1 | TM_BG2 | TM_OBJ
	.byte 49
	.byte TM_BG1 | TM_BG2 | TM_OBJ
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.byte TM_BG1 | TM_BG2
	.byte 0
;-----------------------------------------------------------------------------------------
dmatab_bgmode:
;-----------------------------------------------------------------------------------------
	.byte 127
	.byte BGMODE_1 | BGMODE_16x16_1 | BGMODE_16x16_2 | BGMODE_16x16_3 | BGMODE_PRIO
	.byte 49
	.byte BGMODE_1 | BGMODE_16x16_1 | BGMODE_16x16_2 | BGMODE_16x16_3 | BGMODE_PRIO
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.byte BGMODE_1
	.byte 0

;-----------------------------------------------------------------------------------------
dmatab_bgsc:
;-----------------------------------------------------------------------------------------
	.byte 127
	.byte 8*4+1, 10*4+1
	.byte 49
	.byte 8*4+1, 10*4+1
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.byte IBG2MAP/800H*4, IBGMAP/800H*4
	.byte 0

;-----------------------------------------------------------------------------------------
dmatab_bgnba:
;-----------------------------------------------------------------------------------------
	.byte 127
	.byte 33h
	.byte 49
	.byte 33h
.ifdef DEBUG_DISABLE_HDMA
	.byte 0
.endif
	.byte 1
	.byte 01h
	.byte 0

bg3_clearbytes:
	.byte 0
	
.define rgb8(r,g,b) (((r)>>3) + (((g)>>3)<<5) + (((b)>>3)<<10))

ib_pal_normal:
	.word rgb8(220,220,220), rgb8(161,161,161), rgb8(140,140,140), rgb8(107,107,107), rgb8(85,85,85)
	
ib_pal_active:
	.word rgb8(255,255,255), rgb8(187,187,187), rgb8(163,163,163), rgb8(125,125,125), rgb8(99,99,99)
	
ib_pal_red:
	.word rgb8(255,148,155), rgb8(231,23,40), rgb8(183,0,0), rgb8(128,0,0), rgb8(101,0,0)
	
ib_pal_green:
	.word rgb8(154,248,144), rgb8(43,224,16), rgb8(3,176,0), rgb8(2,128,0), rgb8(1,96,0)

character_names:
	.asciiz "Skipp"
	.asciiz "Wedge"
	.asciiz "Apple"

SpTilePalette:
	.word 0
	.word rgb8(40,80,220)
	.word rgb8(0,0,0)

LEVEL_MUSICS:
	.byte	MOD_EXBORE
	.byte	MOD_EXBORE
	.byte	MOD_EXCITEBORE2
	.byte	MOD_EXCITEBORE2
	.byte	MOD_METEORIC
	.byte	MOD_METEORIC
	.byte	MOD_ICESHIP
	.byte	MOD_DUCKIEST
	.byte	MOD_EXCITEBORE2
	
