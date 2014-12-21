
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_zvars.inc"
.include "copying.inc"
.include "objects.inc"
.include "ingame.inc"

	.import CameraX_Limit, CameraY_Limit

	.export Level_Load
	.export Level_LoadTileset
	.export Level_LoadSpecial1
	
	.export level_solid, level_lasers, level_slide

;******************************************************************
; level format
;------------------------------------------------------------------

MAP_BG1		=0
MAP_BG2		=1000h
MAP_SOLID	=2000h
MAP_DESTR1	=2800h
MAP_DESTR2	=3000h
MAP_SLIDE	=3800h
MAP_WIDTH	=4000h
MAP_HEIGHT	=4001h
MAP_TILESET	=4002h
MAP_BGCOLOR	=4003h
MAP_NOBJECTS	=4005h
MAP_OBJECTS	=4006h

;****************************
;vram
BG_MAP1		=4000H
BG_MAP2		=5000H
BG_GFX		=6000H

;******************************************************************

;==================================================================
	.code
;==================================================================

;------------------------------------------------------------------
; tileset IMPORT list
;------------------------------------------------------------------
	.import space_tileset
;------------------------------------------------------------------
	
;------------------------------------------------------------------
TilesetAddressesL:
;------------------------------------------------------------------
	.byte	<space_tileset
;------------------------------------------------------------------
TilesetAddressesH:
;------------------------------------------------------------------
	.byte	>space_tileset
;------------------------------------------------------------------
TilesetBanks:
;------------------------------------------------------------------
	.byte	^space_tileset
	
;------------------------------------------------------------------
; level IMPORT list
;------------------------------------------------------------------
	.import LEVEL_BEGINNING
	.import LEVEL_PASSWORD
	.import LEVEL_2
	.import LEVEL_SLIDERS
	.import LEVEL_FIRSTENEMY
	.import LEVEL_METEORIC
	.import LEVEL_DECISION
	.import LEVEL_FRIDGE
	.import	LEVEL_ICE2
	.import LEVEL_BOSS
;------------------------------------------------------------------

;------------------------------------------------------------------
LevelAddrL:
;------------------------------------------------------------------
	.byte	<LEVEL_BEGINNING
	.byte	<LEVEL_2
	.byte	<LEVEL_SLIDERS
	.byte	<LEVEL_FIRSTENEMY
	.byte	<LEVEL_METEORIC
	.byte	<LEVEL_DECISION
	.byte	<LEVEL_FRIDGE
	.byte	<LEVEL_ICE2
	.byte	<LEVEL_BOSS
;------------------------------------------------------------------
LevelAddrH:
;------------------------------------------------------------------
	.byte	>LEVEL_BEGINNING
	.byte	>LEVEL_2
	.byte	>LEVEL_SLIDERS
	.byte	>LEVEL_FIRSTENEMY
	.byte	>LEVEL_METEORIC
	.byte	>LEVEL_DECISION
	.byte	>LEVEL_FRIDGE
	.byte	>LEVEL_ICE2
	.byte	>LEVEL_BOSS
;------------------------------------------------------------------
LevelAddrB:
;------------------------------------------------------------------
	.byte	^LEVEL_BEGINNING
	.byte	^LEVEL_2
	.byte	^LEVEL_SLIDERS
	.byte	^LEVEL_FIRSTENEMY
	.byte	^LEVEL_METEORIC
	.byte	^LEVEL_DECISION
	.byte	^LEVEL_FRIDGE
	.byte	^LEVEL_ICE2
	.byte	^LEVEL_BOSS

;==================================================================
	.bss
;==================================================================

level_width:	.res 1
level_height:	.res 1
level_index:	.res 1

erase_queueL:	.res 35
erase_queueH:	.res 35
erase_index:	.res 1

;==================================================================
	.segment "HRAM"
;==================================================================
	
level_solid:	.res 64*32
level_destruct:	.res 64*32
level_slide:	.res 64*32
level_lasers:	.res 64*32

;==================================================================
	.zeropage
;==================================================================

mapf_addr:	.res 2
mapf_bank:	.res 1

;==================================================================
	.segment "XCODE"
	.a8
	.i16
;==================================================================

Level_LoadSpecial1:
	ldx	#.LOWORD(LEVEL_PASSWORD)
	stx	mapf_addr
	lda	#^LEVEL_PASSWORD
	sta	mapf_addr+2
	bra	load_backdoor
	
;*************************************************************************
;* a = level number
;*************************************************************************
Level_Load:
;-------------------------------------------------------------------------
	stz	erase_index
	sta	level_index		; store level index and give to Y
	tay				;
	sep	#10h			;
	rep	#10h			;
;-------------------------------------------------------------------------
	lda	LevelAddrL, y		; copy file address from table	
	sta	mapf_addr		;
	lda	LevelAddrH, y		;
	sta	mapf_addr+1		;
	lda	LevelAddrB, y		;
	sta	mapf_addr+2		;

load_backdoor:
;-------------------------------------------------------------------------
	ldy	#MAP_WIDTH		; copy width&height
	lda	[mapf_addr], y		;
	sta	level_width		;
	rep	#20h
	and	#255
	xba
	sbc	#256*16
	sta	CameraX_Limit
	sep	#20h
	iny				;
	lda	[mapf_addr], y		;
	sta	level_height		;
	rep	#20h
	and	#255
	xba
	sbc	#SCREENHEIGHT*16
	sta	CameraY_Limit
	sep	#20h
;-------------------------------------------------------------------------
	ldy	#MAP_BGCOLOR		; copy BG color
	lda	[mapf_addr], y		;
	stz	REG_CGADD		;
	sta	REG_CGDATA		;
	iny				;
	lda	[mapf_addr], y		;
	sta	REG_CGDATA		;
;-------------------------------------------------------------------------
	ldx	#4096			; copy maps to vram	
	stx	m0			;
	ldy	mapf_addr		;
	lda	mapf_bank		;
	ldx	#BG_MAP1/2		;
	jsr	DMAtoVRAM		;
	rep	#21h			;
	lda	mapf_addr		;
	adc	#4096			;
	tay				;
	sep	#20h			;
	lda	mapf_bank		;
	ldx	#BG_MAP2/2		;
	jsr	DMAtoVRAM		;
;-------------------------------------------------------------------------
	lda	#^level_solid		; copy SOLID map
	sta	REG_WMADDH		;
	ldy	#.LOWORD(level_solid)	;	
	sty	REG_WMADDL		;
	rep	#21h			;
	lda	mapf_addr		;
	adc	#MAP_SOLID		;
	tay				;
	sep	#20h			;
	lda	mapf_addr+2		;
	ldx	#2048			;
	jsr	DMAtoRAM		;
;-------------------------------------------------------------------------
	lda	#^level_slide		; copy SLIDE map
	sta	REG_WMADDH		;
	ldy	#.LOWORD(level_slide)	;
	sty	REG_WMADDL		;
	rep	#21h			;
	lda	mapf_addr		;
	adc	#MAP_SLIDE		;
	tay				;
	sep	#20h			;
	lda	mapf_addr+2		;
	ldx	#2048			;
	jsr	DMAtoRAM		;
;-------------------------------------------------------------------------
	ldy	#MAP_TILESET		; y = tileset index
	lda	[mapf_addr], y		;
	tay				; 
	sep	#10h			; <clear top byte>
	rep	#10h			;
	jsr	Level_LoadTileset	;
;-------------------------------------------------------------------------
	lda	#(BG_GFX>>13)|((BG_GFX>>13)<<4)	; setup bg controls
	sta	REG_BG12NBA			;
	lda	#((BG_MAP1/800H)<<2)|1		;
	sta	REG_BG1SC			;	
	lda	#((BG_MAP2/800H)<<2)|1		;
	sta	REG_BG2SC			;
;	stz	REG_BG1HOFS			;
;	stz	REG_BG1HOFS			;
;	stz	REG_BG1VOFS			;
;	stz	REG_BG1VOFS			;
;	stz	REG_BG2HOFS			;
;;;	stz	REG_BG2HOFS			;
;	stz	REG_BG2VOFS			;
;	stz	REG_BG2VOFS			;
;-------------------------------------------------------------------------
	ldy	#MAP_NOBJECTS		; x = nobjects(8bit)
	lda	[mapf_addr], y		;
	beq	_mapload_no_objects	;
	tax				;
	sep	#10h			;
	rep	#10h			;
	ldy	#MAP_OBJECTS
;-------------------------------------------------------------------------

setup_object:
	phx
	phy
	jsr	Objects_Allocate
	ply
	
.macro CopyObjData target
	lda	[mapf_addr], y
	sta	target, x
	iny
.endmacro
	CopyObjData ObjType
	CopyObjData ObjDir
	CopyObjData ObjX
	CopyObjData ObjY
	CopyObjData ObjA1
	CopyObjData ObjA2
	CopyObjData ObjA3
	CopyObjData ObjA4
	lda	#0
	sta	ObjXF, x
	sta	ObjYF, x

	plx
	dex
	bne	setup_object
	
;-----------------------------------------------------------------------------
	lda	#0				; clear laser map
	ldx	#64*32-1			;
:	sta	F:level_lasers,x		;
	dex					;
	bpl	:-				;
;-----------------------------------------------------------------------------

_mapload_no_objects:
	rts

;*************************************************************************
;* y = index
;*************************************************************************
Level_LoadTileset:
;-------------------------------------------------------------------------
	lda	TilesetAddressesL, y	; setup memptr
	sta	memptr			;
	lda	TilesetAddressesH, y	;
	sta	memptr+1		;
	lda	TilesetBanks, y		;
	sta	memptr+2		;
;-------------------------------------------------------------------------
	ldy	memptr			; copy palette (80 colors)
	xba				;
	lda	#48			;
	xba				;
	ldx	#5*16			;
	jsr	CopyPalette		;
;-------------------------------------------------------------------------
	rep	#21h			; decompress tiles to vram
	lda	memptr			;
	adc	#140h			;
	tax				;
	sep	#20h			;
	lda	memptr+2		;
	ldy	#BG_GFX			;
	jsr	DecompressDataVram	;
;-------------------------------------------------------------------------
	rts
	
	.export Level_ProcessErase
;=========================================================================
Level_ProcessErase:
;=========================================================================
; VBLANK routine
;-------------------------------------------------------------------------
	lda	#80h			; setup vram access (inc on H)
	sta	REG_VMAIN		;
;-------------------------------------------------------------------------
	sep	#10h			; y is index
	ldy	erase_index		;
	dey				;
	bmi	@quit			; quit if negative already
;-------------------------------------------------------------------------
@loop:					;
	lda	erase_queueL, y		; set dest address
	sta	REG_VMADDL		;
	lda	erase_queueH, y		;
	sta	REG_VMADDH		;
;-------------------------------------------------------------------------
	stz	REG_VMDATAL		; clear entry
	stz	REG_VMDATAH		;
;-------------------------------------------------------------------------
	dey				; loop until index is negative
	bpl	@loop			;
;-------------------------------------------------------------------------
	stz	erase_index		; reset counter
@quit:					;
	rep	#10h			; 16bit index
;-------------------------------------------------------------------------
	rts

;=========================================================================
ScheduleErase:
;=========================================================================
	sep	#10h
	ldx	erase_index	
;-------------------------------------------------------------------------
	cmp	#32		; if x > 32
	bcc	:+		; y+= 32, x &= 31
	and	#31		;	
	xba			;
	ora	#32		;
	xba			;
:				;
;-------------------------------------------------------------------------
	asl			; a = (b*32+a)
	asl			;
	asl			;
	rep	#20h		;
	lsr			;
	lsr			;
	lsr
;-------------------------------------------------------------------------
	clc
	adc	#BG_MAP2/2
	sep	#20h		; write to queue
	sta	erase_queueL, x	;
	xba			;
	sta	erase_queueH, x	;
	inc	erase_index	;
;-------------------------------------------------------------------------
	rep	#10h
	rts

	.export Level_Destroy
;=========================================================================
Level_Destroy:
;=========================================================================
;a=x
;b=y
;-------------------------------------------------------------------------
	rep	#20h			; save x,y
	pha				;
	sep	#20h			;
;-------------------------------------------------------------------------
	asl				; y = x + y * 64 + DESTR2
	asl				;		
	rep	#21h			;
	lsr				;
	lsr				;
	adc	#MAP_DESTR2		;
	tay				;
;-------------------------------------------------------------------------
	sep	#20h			; a = destr2 entry
	lda	[mapf_addr], y		;
	beq	@skip_destr		; quit if 0
;-------------------------------------------------------------------------
	rep	#21h			; x = map offset
	tya				;
	sbc	#MAP_DESTR2-1		;
	tax				;
	sep	#20h			;
	lda	#0			;
	sta	f:level_solid, x	; clear destr entry
;-------------------------------------------------------------------------
	rep	#20h			; schedule bg erasing
	pla				;
	sep	#20h			; 
	jsr	ScheduleErase		;
;-------------------------------------------------------------------------
	rts
	
;-------------------------------------------------------------------------
@skip_destr:				; pop stack
	rep	#20h			;
	pla				;
	sep	#20h			;
;-------------------------------------------------------------------------
	rts
