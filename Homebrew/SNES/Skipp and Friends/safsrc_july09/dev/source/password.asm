
.include "snes.inc"
.include "snes_decompress.inc"
.include "snes_joypad.inc"
.include "snes_zvars.inc"
.include "graphics.inc"
.include "snesmod.inc"
.include "soundbank.inc"
.include "sounds.inc"
.include "level.inc"
.include "players.inc"
.include "sprites.inc"
.include "objects.inc"

	.import oam_table
	.import oam_hitable

	.import	ProcessSpriteTransfers
	
	.importzp CameraPX, CameraPY, frame_ready
	.import SortSprites
	.import SpriteTransferIndex
	.import SpriteTransferQueue
	.importzp Flipper
	

	.export DoPassword, DoPregame

	.bss	
	
level_number:
	.res 1
fade:	.res 1


PASSWORD:
	.res 4

	.code
	.a8
	.i16
	
PASSLEN=m4
CURSORPOS=m5
CURSORFLASH=m5+1
EXIT=m6

SPSTART = 35

CURSORSP = (oam_table+6*16+SPSTART*4)
	
oam_setup:
	.byte	96, 224, 0, (6<<1)+1
	.byte	112,224, 0, (6<<1)+1
	.byte	128, 224, 0, (6<<1)+1
	.byte	144, 224, 0, (6<<1)+1
	
	.byte	32, 144, 0, (6<<1)+1
	.byte	56, 144, 2, (6<<1)+1
	.byte	80, 144, 4,(6<<1)+1
	.byte	104, 144, 6, (6<<1)+1
	
	.byte	136, 144, 8, (6<<1)+1
	.byte	160, 144, 10, (6<<1)+1
	.byte	184, 144, 12, (6<<1)+1
	.byte	208, 144, 14, (6<<1)+1
	
	.byte	32, 176, 32, (6<<1)+1
	.byte	56, 176, 34, (6<<1)+1
	.byte	80, 176, 36, (6<<1)+1
	.byte	104, 176, 38, (6<<1)+1
	
	.byte	136, 176, 40,(6<<1)+1
	.byte	160, 176, 42,(6<<1)+1
	.byte	184, 176, 44,(6<<1)+1
	.byte	208, 176, 46,(6<<1)+1
	
	.byte	88, 56, 64, %00001111
	.byte	152,56, 64, %01001111
	.byte	88, 72, 64, %10001111
	.byte	152,72, 64, %11001111
	
	.byte	24, 136, 64, %00001111
	.byte	40, 136, 64, %01001111
	.byte	24, 152, 64, %10001111
	.byte	40, 152, 64, %11001111
	
password_letter_map:
	.byte  0, 2, 4, 6, 8,10,12,14
	.byte 32,34,36,38,40,42,44,46
	
ascii_map:
	.byte 'A', 'C', 'D', 'E', 'F', 'I', 'L', 'M'
	.byte 'N', 'O', 'S', 'T', 'P', 'R', 'U', 'V'
	
ascii_reverse_map:

	;starting with 65
	.byte	0, -1, 1, 2, 3, 4, -1, -1, 5, -1, -1, 6
	.byte	7,  8, 9,12,-1,13, 10, 11, 14, 15
	
BG2MAP = (5000H/2)
	
.macro RenderString px, py, text, pal
	ldx	#BG2MAP + px + py * 32
	stx	REG_VMADD
	ldy	#0
	bra	:++
:	iny
	sta	REG_VMDATAL
	lda	#pal<<2
	sta	REG_VMDATAH
:	lda	text, y
	bne	:--
.endmacro	

DrawPassword:
	sep	#10h
	ldy	PASSLEN
	
.repeat 4, i
	ldx	PASSWORD+i
	lda	password_letter_map, x
	sta	oam_table+(SPSTART+i)*4+2
	cpy	#i+1
	bcs	:+
	lda	#224
	bra	:++
:	lda	#64
:	sta	oam_table+(SPSTART+i)*4+1
.endrep

	rep	#10h
	rts

;==================================================================================
DrawCursor:
;==================================================================================
	lda	CURSORFLASH		; if flash >= 30 then hide cursor
	cmp	#30			;
	bcc	@showcursor		;
	lda	#224			;
	sta	CURSORSP+1		;
	sta	CURSORSP+5		;
	sta	CURSORSP+9		;
	sta	CURSORSP+13		;
	rts				;
;----------------------------------------------------------------------------------
@showcursor:				;
	lda	CURSORPOS		; a = cpos * 24
	and	#7			;
	asl				;
	asl				;
	asl				;
	sta	m0			;
	asl				;
	adc	m0			;
;----------------------------------------------------------------------------------
	cmp	#96			; adjust by 8 after center point
	bcc	:+			;
	adc	#8-1			;
:					;
	adc	#24			; add offset
;----------------------------------------------------------------------------------
	sta	CURSORSP		; set X values
	sta	CURSORSP+8		;
	adc	#16			;
	sta	CURSORSP+4		;
	sta	CURSORSP+12		;
;----------------------------------------------------------------------------------
	lda	CURSORPOS		; a = (CPOS & 8) ? 32 : 0
	and	#8			;
	asl				;
	asl				;
;----------------------------------------------------------------------------------
	adc	#136			; set Y values
	sta	CURSORSP+1		;
	sta	CURSORSP+5		;
	adc	#16			;
	sta	CURSORSP+9		;
	sta	CURSORSP+13		;
;----------------------------------------------------------------------------------
	rts
	
	
InputChar:
	sep	#10h
	ldy	PASSLEN
	
	lda	CURSORPOS
	sta	PASSWORD, y
	iny
	sty	PASSLEN
	cpy	#4
	beq	_end_of_password
	rep	#10h
	
	lda	#60-5
	sta	CURSORFLASH
	rts
_end_of_password:
	rep	#10h
	lda	#1
	sta	EXIT
	rts
	
DeleteChar:
	lda	PASSLEN
	beq	_end_of_password
	dec	PASSLEN
	rts
	
;=========================================================================================
SetupScreen:
;=========================================================================================
	
	lda	#80h
	sta	REG_INIDISP

	DoDecompressDataVram gfx_sfontTiles, 0000h
	DoCopyPalette gfx_sfontPal, 0, 16
	DoDecompressDataVram gfx_pwcharsTiles, 0E000h
	DoDecompressDataVram gfx_pwbracketTiles, 0E800h
	DoCopyPalette gfx_pwcharsPal, 224, 16
	DoCopyPalette gfx_pwbracketPal, 240, 4
	
	stz	REG_CGADD
	stz	REG_CGDATA
	stz	REG_CGDATA
	
	lda	#(BG2MAP/1024)<<2
	sta	REG_BG2SC
	
	lda	#80h
	sta	REG_VMAIN
	
	ldx	#BG2MAP
	stx	REG_VMADD
	ldx	#1024
:	ldy	#0
	sty	REG_VMDATA
	dex
	bne	:-
	
	stz	REG_BG2HOFS
	stz	REG_BG2HOFS
	lda	#-1
	sta	REG_BG2VOFS
	sta	REG_BG2VOFS
	
	lda	#1
	sta	REG_BGMODE
	lda	#%10010
	sta	REG_TM

	lda	#OBSEL_16_32 | OBSEL_BASE(0C000h) | OBSEL_NN_16K
	sta	REG_OBSEL		; 16x16,32x32

	
	ldy	#oam_table&65535
	sty	REG_WMADDL
	lda	#^oam_table
	sta	REG_WMADDH
	ldy	#128
	
	
	lda	#224			; clear oam table
:	sta	REG_WMDATA		;
	sta	REG_WMDATA		;
	stz	REG_WMDATA		;
	stz	REG_WMDATA		;
	dey				;
	bne	:-			;
	
	ldy	#oam_hitable&65535
	sty	REG_WMADDL
	lda	#^oam_hitable
	sta	REG_WMADDH
	
	ldy	#128/4			; set 16x16 size
:	stz	REG_WMDATA
	dey
	bne	:-
	
	ldy	#(oam_table+SPSTART*4)&65535
	sty	REG_WMADDL
	lda	#^oam_table
	sta	REG_WMADDH
	
	ldy	#0
:	lda	oam_setup, y
	sta	REG_WMDATA
	iny
	cpy	#16*1
	bne	:-
	
	rts

;==============================================================================
DoPassword:
;==============================================================================

	jsr	SetupScreen
	
	ldy	#(oam_table+SPSTART*4)&65535
	sty	REG_WMADDL
	lda	#^oam_table
	sta	REG_WMADDH
	
	ldy	#0
:	lda	oam_setup, y
	sta	REG_WMDATA
	iny
	cpy	#16*7
	bne	:-
	
	RenderString 16-10, 4, str_enteryourpassword, 0
	
	ldx	#MOD_VICOLTY
	jsr	spcLoad
	ldx	#0
	jsr	spcPlay
	
	ldx	#127
	jsr	spcSetModuleVolume
	
	jsr	spcFlush
	
	
	
	stz	PASSLEN
	
	jsr	DrawPassword
	lda	#3
	sta	CURSORPOS
	stz	CURSORFLASH
	stz	EXIT
	jsr	DrawCursor
	
	
	
@loop:
	
	lda	joy1_down+1
	bit	#JOYPADH_UP|JOYPADH_DOWN
	beq	@joy_vert
	lda	CURSORPOS
	eor	#8
	sta	CURSORPOS
	stz	CURSORFLASH
	
	spcPlaySoundM SND_MENU1
	
@joy_vert:

	lda	joy1_down+1
	bit	#JOYPADH_LEFT
	beq	@joy_left
	lda	CURSORPOS
	and	#8
	sta	m0
	lda	CURSORPOS
	dea
	and	#7
	ora	m0
	sta	CURSORPOS
	stz	CURSORFLASH
	
	spcPlaySoundM SND_MENU1
	
@joy_left:

	lda	joy1_down+1
	bit	#JOYPADH_RIGHT
	beq	@joy_right
	lda	CURSORPOS
	and	#8
	sta	m0
	lda	CURSORPOS
	ina
	and	#7
	ora	m0
	sta	CURSORPOS
	stz	CURSORFLASH
	
spcPlaySoundM SND_MENU1
	
@joy_right:

	lda	joy1_down
	bpl	@joy_a
	jsr	InputChar
	
	spcPlaySoundM SND_MENU2
@joy_a:
	lda	joy1_down+1
	bpl	@joy_b
	jsr	DeleteChar
	
	spcPlaySoundM SND_MENU2
@joy_b:
	

	lda	CURSORFLASH
	ina
	cmp	#60
	bne	:+
	lda	#0
:	sta	CURSORFLASH

	jsr	DrawCursor
	jsr	DrawPassword
	
	jsr	spcProcess
	
	wai
	
	
	lda	#0Fh
	sta	REG_INIDISP
	
	lda	EXIT
	bne	@nloop
	jmp	@loop
@nloop:
	
	lda	#255
	sta	CURSORFLASH
	jsr	DrawCursor
	
	ldy	#20
:	jsr	spcProcess
	wai
	dey
	bne	:-
	
	lda	PASSLEN	; exit on cancel
	cmp	#0	;
	bne	:+	;
	jsr	spcStop
	jsr	spcFlush
	lda	#-1	;
	rts		;
:
	
	jsr	PasswordSearch
	
	cmp	#-1
	bne	@password_ok
	
	lda	#4
	sta	PASSWORD
	lda	#0
	sta	PASSWORD+1	
	lda	#5
	sta	PASSWORD+2
	lda	#6
	sta	PASSWORD+3
	
	wai
	
	jsr	DrawPassword
	
	ldy	#100
:	jsr	spcProcess
	wai
	dey
	bne	:-
	
	lda	#80h
	sta	REG_INIDISP
	
	jsr	spcStop
	jsr	spcFlush
	lda	#-1
	rts
	
@password_ok:
	pha
	
	ldy	#100
:	jsr	spcProcess
	wai
	dey
	bne	:-
	
	
	
	lda	#80h
	sta	REG_INIDISP
	jsr	spcStop
	jsr	spcFlush
	pla
	rts
	
	
PasswordSearch:
	ldy	#0
@search:

.repeat 4, i
	lda	PASSWORD+i
	tax
	lda	ascii_map, x
	cmp	PASSWORD_LIST+i, y
	bne	@next
.endrepeat
	rep	#20h
	tya
	lsr
	lsr
	sep	#20h
	rts
@next:
	iny
	iny
	iny
	iny
	cpy	#PASSWORD_LIST_END-PASSWORD_LIST
	bne	@search
	
	lda	#-1
	rts

str_enteryourpassword:
	.asciiz "Insert the password."


;	 'A', 'C', 'D', 'E', 'F', 'I', 'L', 'M'
;	 'N', 'O', 'S', 'T', 'P', 'R', 'U', 'V'
	
PASSWORD_LIST:
	.byte "DEAF"
	.byte "LEVL"
	.byte "STOP"
	.byte "ENEM"
	.byte "METE"
	.byte "DECI"
	.byte "FRID"
	.byte "ICEE"
	.byte "RARE"
PASSWORD_LIST_END:

; a = level number
DoPregame:
	sta	level_number
	
	lda	#80h
	sta	REG_INIDISP

	jsr	spcStop
	jsr	spcFlush
	
	jsr	Objects_Reset
	
	jsr	Level_LoadSpecial1
	jsr	SetupScreen
	
	lda	#BGMODE_1|BGMODE_16x16_1
	sta	REG_BGMODE
	lda	#%10011
	sta	REG_TM
	lda	#8*4+1
	sta	REG_BG1SC
	
	DoCopyPalette gfx_player1Pal, 128, 16
	DoCopyPalette gfx_player2Pal, 144, 16
	DoCopyPalette gfx_player3Pal, 160, 16
	
	DoCopyPalette gfx_dongles1Pal, 176, 16
	DoDecompressDataVram gfx_dongles1Tiles, 0C800H
	
	lda	#03h
	sta	REG_BG12NBA
	
	
	lda	#4
	sta	PASSLEN
	
	lda	level_number
	rep	#20h
	and	#255
	asl
	asl
	tay
	lda	#0
	sep	#20h
.repeat 4, i
	lda	PASSWORD_LIST, y
	tax
	lda	ascii_reverse_map-65,x
	sta	PASSWORD+i
	
	.if i <> 3
	iny
	.endif
.endrep
	
	jsr	DrawPassword
	
	RenderString 16-7, 4, str_yourpassword, 0
	
	ldx	#190
	stx	CameraPX
	ldx	#40
	stx	CameraPY
	
	
	jsr	Objects_DoInit
	
	jsr	Sprites_Reset
	stz	fade
	
	wai
	
	
	
	stz	PL_KeyV
	stz	PL_KeyV+1
	stz	PL_KeyV+2
	
@loop:

	lda	Flipper
	eor	#128
	sta	Flipper
	
	lda	#2
	sta	PL_KeyH
	sta	PL_KeyH+1
	sta	PL_KeyH+2
	

	jsr	Players_Update
	jsr	Players_Draw
	
	jsr	SortSprites
	jsr	Sprites_Process
	jsr	spcProcess
	
	ldx	SpriteTransferIndex		; terminate sprite transfer queue
	stz	SpriteTransferQueue, x		;
	
	lda	#1
	sta	frame_ready
	wai
	nop
	stz	frame_ready
	
	lda	fade
	cmp	#15<<1
	beq	:+
	ina
	sta	fade
	lsr
	sta	REG_INIDISP
	
	
:
	
	jsr	ProcessSpriteTransfers
	
	
	rep	#20h				; Update scroll registers
	lda	CameraPX			;
	sep	#20h
	sta	REG_BG1HOFS
	xba
	sta	REG_BG1HOFS
	
	rep	#20h
	lda	CameraPY			;
	dea					;-compensate for first unrendered line
	sep	#20h
	sta	REG_BG1VOFS
	xba
	sta	REG_BG1VOFS
	
	lda	PL_XH+1
	cmp	#32
	bcs	:+
	bra	@loop
:	wai
	dec	fade
	lda	fade
	lsr
	sta	REG_INIDISP
	bne	:-
	lda	#80h
	sta	REG_INIDISP
	
	rts



str_yourpassword:
	.asciiz "Your Password:"
