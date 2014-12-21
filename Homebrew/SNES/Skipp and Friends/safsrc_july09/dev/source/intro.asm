
;-----------------------.
;  mod shrine intro !!  |
;                       |
;-----------------------'

.include "snes.inc"
.include "graphics.inc"
.include "snesmod.inc"
.include "soundbank.inc"
.include "snes_decompress.inc"

.import sin_tab

.importzp m0, m1, m2, m3, m4, m5, m6, m7
.importzp joy1_down
.import oam_table
.import oam_hitable

TM_ON = %00010111

;--------------------------------------------------------------
; bg mode: 4,4,2
; BG1 = bouncy logo
; BG2 = (HOME OF THE MODS)
; BG3 = background
; OBJ = message
;--------------------------------------------------------------

.global DoIntro

.import DecompressDataVram
.import CopyPalette

	.segment "XCODE"
	.i16
	.a8

;--------------------------------------------------------------
DoIntro:
;--------------------------------------------------------------

	lda	#80h
	sta	REG_INIDISP
	sei
	ldx	#MOD_POLLEN8
	jsr	spcLoad
	
	;------------------------------------------------------
	; setup BG1
	;------------------------------------------------------
	
	ldx	#.LOWORD(gfx_modshrineTiles)
	lda	#^gfx_modshrineTiles
	ldy	#0000h
	jsr	DecompressDataVram
	
	ldy	#.LOWORD(gfx_modshrinePal)
	lda	#16
	xba
	lda	#^gfx_modshrinePal
	ldx	#16
	jsr	CopyPalette
	
	ldy	#.LOWORD(gfx_modshrinePal)	; another copy for sprites
	lda	#128
	xba
	lda	#^gfx_modshrinePal
	ldx	#16
	jsr	CopyPalette
	
	lda	#(3<<2)+(1)		; bg0 = 64x32
	sta	REG_BG1SC		; sb=3
	
	ldx	#.LOWORD(gfx_modshrineMap)	; decompress MODSHRINE map
	lda	#^gfx_modshrineMap		;
	ldy	#1800h				;
	jsr	DecompressDataVram		;
	
	ldx	#.LOWORD(gfx_introlettersTiles)
	lda	#^gfx_introlettersTiles
	ldy	#8000h
	jsr	DecompressDataVram
	
	;------------------------------------------------------
	; setup BG2
	;------------------------------------------------------
	
	lda	#-56
	sta	REG_BG2HOFS
	stz	REG_BG2HOFS
	lda	#-104
	sta	REG_BG2VOFS
	stz	REG_BG2VOFS
	
	ldx	#.LOWORD(gfx_ifontTiles)	; decompress font 2800h
	lda	#^gfx_ifontTiles		;
	ldy	#2800h				;
	jsr	DecompressDataVram		;
	
	lda	#(7<<2)				; bg1 base = 7 (3800h)
	sta	REG_BG2SC			;
	
	lda	#80h				; copy message
	sta	REG_VMAIN			;
	ldy	#3800h/2			;
	sty	REG_VMADDL			;
	ldy	#0FFFFh

@copy_message:
	iny
	lda	MESSAGE,y
	beq	@copy_message_complete
	
	rep	#21h
	and	#0FFh
	adc	#320-32 + (1<<10)
	sta	REG_VMDATAL
	sep	#20h
	bra	@copy_message
	
@copy_message_complete:

	;---------------------------------------------------------
	; Setup BG3
	;---------------------------------------------------------
	
	ldx	#.LOWORD(gfx_introbgTiles)
	lda	#^gfx_introbgTiles
	ldy	#4000h
	jsr	DecompressDataVram
	
	ldx	#.LOWORD(gfx_introbgMap)
	lda	#^gfx_introbgMap
	ldy	#4800h
	jsr	DecompressDataVram
	
	ldy	#.LOWORD(gfx_introbgPal)	; another copy for sprites
	lda	#0
	xba
	lda	#^gfx_introbgPal
	ldx	#4
	jsr	CopyPalette
	
	lda	#2
	sta	REG_BG34NBA
	lda	#(4800h/800h)<<2
	sta	REG_BG3SC
	
	;---------------------------------------------------------
	; setup window
	;---------------------------------------------------------
	
	lda	#%00000001
	sta	REG_BGMODE
	
	lda	#TM_ON
	sta	REG_TM
	
	lda	#0		; hdma terminator
	pha			;
	
	rep	#21h		; allocate space for many variables
	tsc			;
	sbc	#56*2+1+3-1	; 56*2+1+3 bytes for hdma table
	sta	REG_A1T0L	; first entry is line skipper
	stz	REG_A1B0	;
	
	sbc	#16		; allocate space for 16 'characters'
	sta	m7		; bytes are : 1:Character, 1: X/2
	stz	m4		; m4 = next sprite
	stz	m4+1		;
	
	sec
	sbc	#9		; alloc 9 bytes for tm hdma
	sta	REG_A1T2L	;	
	stz	REG_A1B2	;
	
	sbc	#32+1		; 32 bytes for vars, +1 for stack pointer (empty-descending)
	tcs			;
	sep	#20h		;
	
	lda	#80h+56		; hdma 56 lines
	sta	1+57+3, S	;
	lda	#01h		; init to 'skip 1 line'
	sta	1+57, S		;
	
	lda	#%00000010	; cpu->ppu
	sta	REG_DMAP0	; direct
				; 1 register write twice
	stz	REG_DMAP2
	lda	#<REG_BG1HOFS
	sta	REG_BBAD0	; set dest pointer
	
	;------------------------
	; setup letterbox hdma
	;------------------------
	
	lda	#0		; HDMA TABLE:	fadein, 00h, 127, TM_ON, 95-fadein, TM_ON, 01h, 00h, 00h
	sta	1+32, S		;
	sta	1+33, S		;
	sta	1+39, S		;
	sta	1+40, S		;
	lda	#127		;
	sta	1+34, S		;
	lda	#TM_ON		;
	sta	1+35, S		;
	sta	1+37, S		;
	lda	#1
	sta	1+38, S
	
	lda	#REG_TM&255
	sta	REG_BBAD2
	
	lda	#%00000101	;
	sta	REG_HDMAEN	; enable hdma0,2
	
logox = 01h			; 16bit .4 fixed point logo x pos
logosine = 03h			; 16bit .8 fixed point sine pos
logoy = 07h			; 16bit .8 fixed point 
logovy = 09h			; 16bit .8 fixed point
fadein = 0Bh			; 8bit .4 fixed
readpos = 0Ch			; readposition of the characters
readtimer = 0Eh			; 8bit read timer
sprite_voff = 0Fh		; sine offset for sprites
bgscroll = 11h
fadeout = 12h
	
	lda	#0
	sta	fadein, S
	sta	fadeout, S
	rep	#20h
	and	#0FFh
	sta	logox, S
	sta	logoy, S
	
	
	lda	#-900			; vy = -900 /256
	sta	logovy, S		;
	lda	#56<<8			; ly = 56
	sta	logoy, S
	
	
	sep	#20h
	
	lda	#%00100010		; base = 4
	sta	REG_OBSEL		; sizes = 8x8, 32x32
	
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
	
	lda	#-16			; clear letter table
	ldy	#16-1			;
:	sta	(m7), y			;
	dey				;
	bpl	:-			;
	
	
	ldx	#0
	jsr	spcPlay
	jsr	spcFlush
	
	jsr	spcGetCues
	
:	jsr	spcReadStatus		; wait until song begins
	and	#SPC_P			;
	beq	:-			;
	
:	jsr	spcGetCues
	cmp	#0
	beq	:-

	cli
	wai
	wai
	
;-----------------------------------------------------------------------
IntroLoop:
;-----------------------------------------------------------------------

	lda	readtimer, S		; increment readtimer
	ina				;
	sta	readtimer, S		;
	cmp	#11			; if readtimer == 10 then:
	bne	@skip_add_char		; 

	lda	#0			; reset readtimer
	sta	readtimer, S		;
	rep	#20h			;
	lda	readpos, S		; a,y = get readpos
	tay				;   
	ina				; readpos++
	sta	readpos, S		;  
	sep	#20h			;
	lda	SCROLLER, y		; read character
	beq	@restart_scroller	; if 0 then restart scroller
	
	cmp	#32			; skip spaces
	beq	@skip_add_char		; this also sets carry (all chars are >= 32)
	
	rep	#20h			; a = translated letter
	and	#0FFh			;
	asl				;
	sbc	#'A'*2-1		;
	tay				;
	lda	LETTER_MAP, y		;
	
	pha				; set oam_table[2+next*4] (character and stuff!)
	lda	m4			;
	asl				;
	asl				;
	tay				;
	pla				;
	sta	oam_table+2, y		;
	
	sep	#20h
	
	ldy	m4			;
	lda	#144			; .x = 144 (x=288) ((256+32)/2)
	sta	(m7), y			;
	
	iny				; next_sprite++
	cpy	#16			; wrap to 16 pieces
	bne	:+			;
	ldy	#0			;
:	sty	m4			;

	bra	@skip_add_char
	
@restart_scroller:
	rep	#20h			; reset readpos
	lda	#0			;
	sta	readpos, S		;
	sep	#20h			;
@skip_add_char:

;-----------------------------------------------------------------------
	ldy	#oam_table		; setup the sprite table...
	sty	REG_WMADDL		;
	lda	#^oam_table		;
	sta	REG_WMADDH		;
	
	rep	#21h
	lda	sprite_voff, S
	sbc	#44
	sta	sprite_voff, S
	and	#0
	sep	#20h
	
	lda	#%01010101
	sta	m5			; m5,m6 = top table bits for 16 sprites
	sta	m5+1			;
	sta	m5+2
	sta	m5+3
	ldx	#0			;
	txy		
	
;--------------------------------------------------------------------
@update_chars1:				; for each character:
;--------------------------------------------------------------------
	
	lda	(m7), y			; if character X is != -16 then 
	cmp	#-16			;
	beq	@offscreen		;
	dea				;    decrement X
	sta	(m7), y			;    
	asl				;    a = x << 1
	ror	m5,x			;    give top bit to m5
	ror	m5,x			;    rotate again to align
	sta	REG_WMDATA		;    set X (low)
	
	lda	(m7), y			;    a = H + sine_off & 07Fh
	clc				;
	adc	sprite_voff+1, S	;  
	asl
	
	and	#07Fh			;
	
	phx				;    read sine value    
	tax				;
	lda	SINUS20, x		;
	plx				;
	sta	REG_WMDATA		;
	
	lda	REG_WMDATA		;    skip char number + palette + etc
	lda	REG_WMDATA		;
	bra	@next_letter
@offscreen:
	lda	#224
	ror	m5, x
	ror	m5, x
	sta	REG_WMDATA		; offscreen sprite
	sta	REG_WMDATA		;
	lda	REG_WMDATA		;
	lda	REG_WMDATA		;
	
@next_letter:
	iny				; y++
	tya				; increment x on intervals of 4
	and	#03h			;
	bne	:+			;
	inx				;
:	cpy	#16			;
	bne	@update_chars1		;
	
	ldy	m5
	sty	oam_hitable
	ldy	m6
	sty	oam_hitable+2
	
	rep	#20h			; start fadeout if A or START is pressed
	lda	joy1_down		 ;
	bit	#(JOYPAD_A|JOYPAD_START) ;
	sep	#20h			 ;
	beq	:+			;
	lda	#1			;
	sta	fadeout, S		;
	ldx	#0
	ldy	#8
	jsr	spcFadeModuleVolume
:					;

	jsr	spcProcess		; PROCESS SPC stuff
	
	;-------------------------------
	wai				; wait for new frame
	;-------------------------------
	
	lda	#0Fh
	sta	REG_INIDISP
	
	lda	fadeout, S		; test fadeout flag
	beq	@do_fadein		;
@do_fadeout:				; do fadeout:
	lda	fadein, S		;   decrement fadein until zero
	beq	@set_fade		;	
	dea				;
	sta	fadein, S		;
	bra	@set_fade		; set hdma stuff
	
@do_fadein:				; do fadein:
	lda	fadein, S		;   increment fadein until 28
	cpa	#28			;
	beq	@set_fade		;
	ina				;
	sta	fadein, S		;
	
@set_fade:				; setup hdma table
	sta	1+32, S			;
	asl				;
	sbc	#95			;
	eor	#255			;
	sta	1+36, S			;

	lda	fadein, S		; copy palette according to fadein
	lsr				;
	xba				;
	lda	#0			;
	rep	#20h			;
	lsr				;
	lsr				;
	lsr				;
	pha				;
	adc	#PALETTE_FADE&65535	;
	pha
	sta	REG_A1T1L		;
	sep	#20h			;
	lda	#^PALETTE_FADE		;
	sta	REG_A1B1		;
	lda	#REG_CGDATA&255		;
	sta	REG_BBAD1		;
	lda	#%00000010		;
	sta	REG_DMAP1		;
	ldy	#2*16			;	
	sty	REG_DAS1L		;
	lda	#16
	sta	REG_CGADD
	
	lda	#%00000010		;
	sta	REG_MDMAEN		;
	
	
	rep	#20h			; copy for sprites
	pla				;
	sta	REG_A1T1L		;
	sep	#20h			;
	lda	#128			;
	sta	REG_CGADD		;
	
	ldy	#2*16			;	
	sty	REG_DAS1L		;
	
	lda	#%00000010		;
	sta	REG_MDMAEN		;

	rep	#20h
	pla
	lsr
	lsr
	adc	#PALETTE_FADE2&65535
	sta	REG_A1T1L
	sep	#20h
	stz	REG_CGADD
	
	ldy	#2*4			;	
	sty	REG_DAS1L		;
	lda	#%00000010		;
	sta	REG_MDMAEN		;
	
	;---------------------------------------------------------------------------
	
	lda	fadein, S
	bne	:+
	jmp	ExitIntro
:

	lda	bgscroll, S
	ina
	sta	bgscroll, S
	sta	REG_BG3VOFS
	stz	REG_BG3VOFS
	asl
	sta	REG_BG3HOFS
	stz	REG_BG3HOFS
	
	rep	#21h			; logox += ~4.7 (+ is - screenpos)
	lda	logox, S		;
	adc	#75			;
	sta	logox, S		;
	lsr				;
	lsr				;
	lsr				;
	lsr				;
	sta	m1			; m1 = lx integer
	
	lda	logovy, S		; vy += 55
	adc	#55			;
	sta	logovy, S		;
	adc	logoy, S		; ly += vy
	sta	logoy, S
	
	sep	#20h
	jsr	spcGetCues
	cmp	#0
;	cmp	#56<<8			;if ly > 56
	beq	@missed_touch		;
	
	rep	#20h
	
	lda	#-900			; vy = -900 /256
	sta	logovy, S		;
	lda	#56<<8			; ly = 56
	sta	logoy, S
@missed_touch:

	rep	#20h

	lda	logoy, S
	
	xba				; a = 8bit whole part of ly
	sep	#20h			;
	cmp	#1			;
	bcs	:+			; hdma start = a < 1 ? 1 : a
	lda	#01h			;
:	sta	1+57, S			;
	
	eor	#0FFh			; vofs = -ly
	ina				;
	sta	REG_BG1VOFS		;
	stz	REG_BG1VOFS		;
	rep	#20h			;
	
	tsc				; m0 = hdma table (sp+x)
	clc				;
	adc	#1+57+3+1		;
	sta	m0			;
	
	lda	logosine, S		; logosine += 5.625
	adc	#720			;
	sta	logosine, S		;
	xba				;
	and	#0FFh			;
	sta	m2			; m2 = logosine.whole
	
	ldy	#0			;
	
;--------------------------------
@SetupHDMA:
;--------------------------------
	
@sh_setline:
	
	lda	m2		; a = logosine + hy * 3
	clc			;
	adc	#03h		;
	and	#07Fh		;
	sta	m2		;
	
	tax			; a = sine
	sep	#21h		; set carry for subtraction!
	lda	SINUS, x	;
	rep	#20h		;
	sbc	#128		; sign value
	
	clc			; += logox
	adc	m1		;
	
	sta	(m0), y		; set hdma table
	iny			;
	iny			;
	
@sh_skipline:
	
	cpy	#56*2		; iterate for 56 entries
	bne	@SetupHDMA	;
	
	sep	#20h
;--------------------------------
	
	jmp	IntroLoop
ExitIntro:
	
	
	rep	#21h		; delete space
	tsc			;
	adc	#175		;
	tcs			;
	sep	#20h		;
	
	stz	REG_HDMAEN
	
	lda	#30
:	wai
	dea
	bne	:-
	
	lda	#0Fh
:	wai
	sta	REG_INIDISP
	dea
	bne	:-
	
	lda	#80h
	sta	REG_INIDISP
	
	jsr	spcStop
	
	rts
	
;**********************************************************************
	
	.code

MESSAGE:
	.byte	"(HOME OF THE MODS)", 0

SCROLLER:
	.byte "HELLO WORLD   GREETS TO MOD SHRINE  THIS "
	.byte "INTRO WAS CODED BY MUKUNDA WITH MUSIC BY "
	.byte "CODA SORRY I FORGOT TO PUT PUNCTUATION "
	.byte "MARKS AND NUMBERS IN THIS FONT    ANYWAY HERE IS AN "
	.byte "AWESOME SNES VIDEO GAME FOR THE PDROMS FOUR "
	.byte "POINT ZERO ONE GAME COMPETITION       "
	.byte "SNES IS SUCH AN AWFUL SYSTEM LOL      "
	.byte "PRESS START TO PLAY     ", 0

SINUS:
	.byte 128,128,128,129,129,129,129,129,130,130,130,130,130,130,131,131,131,131,131,131,131,131,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,132,131,131,131,131,131,131,131,131,130,130,130,130,130,130,129,129,129,129,129,128,128,128,128,128,127,127,127,127,127,126,126,126,126,126,126,125,125,125,125,125,125,125,125,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,124,125,125,125,125,125,125,125,125,126,126,126,126,126,126,127,127,127,127,127,128,128

SINUS20:
	.byte 136,137,138,139,140,141,142,143,144,145,145,146,147,148,149,149,150,151,151,152,153,153,154,154,154,155,155,155,156,156,156,156,156,156,156,156,156,155,155,155,154,154,154,153,153,152,151,151,150,149,149,148,147,146,145,145,144,143,142,141,140,139,138,137,136,135,134,133,132,131,130,129,128,127,127,126,125,124,123,123,122,121,121,120,119,119,118,118,118,117,117,117,116,116,116,116,116,116,116,116,116,117,117,117,118,118,118,119,119,120,121,121,122,123,123,124,125,126,127,127,128,129,130,131,132,133,134,135
	
LETTER_MAP: ; 26 letters!
	.word   0,   0+4,   0+8,   0+12
	.word  64,  64+4,  64+8,  64+12
	.word 128, 128+4, 128+8, 128+12
	.word 192, 192+4, 192+8, 192+12
	.word 256, 256+4, 256+8, 256+12
	.word 320, 320+4, 320+8, 320+12
	.word 384, 384+4
	


PALETTE_FADE:
	.word $7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF
	.word $7BDF,$77BD,$7FFF,$7BDE,$7FFF,$7FFF,$7FFF,$7FFF,$77BD,$77BD,$77DE,$77BD,$7BDE,$7BDE,$7BDE,$7BDE
	.word $73DF,$6F7B,$7FFF,$7BDE,$7FFF,$7FFF,$7FFF,$7BDE,$6F7B,$6F7C,$6F9D,$6F7B,$7BDE,$7BDE,$77BD,$77BD
	.word $6FBF,$6318,$7FFF,$77BD,$7FFF,$7FFF,$7FFF,$7BDE,$6339,$673A,$675C,$6739,$77BD,$77BD,$739C,$739C
	.word $679F,$5AD6,$7FFF,$739C,$7BDE,$7FFF,$7FFF,$7BDE,$5AD6,$5F18,$633A,$5AF7,$739C,$739C,$6F7C,$6F7B
	.word $637F,$5294,$7FFF,$739C,$7BDE,$7FFF,$7FFF,$77BD,$5294,$56D6,$5B19,$52B5,$6F7C,$6F7B,$6B5B,$6B5A
	.word $5B7F,$4A52,$7FFF,$6F7B,$7BDE,$7FFF,$7FFF,$77BD,$4A52,$4E95,$52D8,$4A73,$6F7B,$6F7B,$673A,$6739
	.word $575F,$4210,$7FFF,$6B5A,$7BDE,$7FDF,$7BDE,$739C,$4210,$4253,$4A97,$4211,$6B5A,$6B5A,$6319,$6318
	.word $533F,$35AD,$7FFF,$6B5A,$7BDE,$7FDF,$7BDE,$739C,$35CE,$3A11,$4276,$39CF,$673A,$6739,$6318,$5AD6
	.word $4B3F,$2D6B,$7FFF,$6739,$7BDE,$7FDF,$7BDE,$739C,$2D8C,$31D0,$3A55,$318D,$6739,$6739,$5EF7,$56B5
	.word $471F,$2529,$7FFF,$6739,$7BDE,$7FDF,$7BDE,$6F7B,$254A,$298E,$3214,$294B,$6319,$6318,$5AD6,$5294
	.word $3EFF,$1CE7,$7FFF,$6318,$77BD,$7FDF,$7BDE,$6F7B,$1CE7,$216C,$2DD2,$1D09,$5EF8,$5EF7,$56B6,$4E73
	.word $3ADF,$1084,$7FFF,$5EF7,$77BD,$7FDF,$7BDE,$6F7B,$10A5,$192A,$25B1,$14C7,$5AD7,$5AD6,$5295,$4A52
	.word $32DF,$842,$7FFF,$5EF7,$77BD,$7FDF,$7BDE,$6B5A,$863,$10E9,$1D90,$C85,$5AD7,$5AD6,$4E74,$4631
	.word $2EBF,$0,$7FFF,$5AD6,$77BD,$7FDF,$7BDE,$6B5A,$21,$8A7,$154F,$443,$56B6,$56B5,$4A53,$4210

PALETTE_FADE2:
	.word $7FFF,$7FFF,$7FFF,$7FFF
	.word $77BD,$7BDF,$7BFF,$77BD
	.word $6F7B,$73DF,$7BDF,$6F7B
	.word $6318,$6FBF,$77DF,$6318
	.word $5AD6,$679F,$73DF,$5AD6
	.word $5294,$637F,$73DF,$5294
	.word $4A52,$5B7F,$6FBF,$4A52
	.word $4210,$575F,$6BBF,$4210
	.word $35AD,$533F,$6BBF,$35AD
	.word $2D6B,$4B3F,$679F,$2D6B
	.word $2529,$471F,$679F,$2529
	.word $1CE7,$3EFF,$639F,$1CE7
	.word $1084,$3ADF,$5F9F,$1084
	.word $842,$32DF,$5F7F,$842
	.word $0,$2EBF,$5B7F,$0
