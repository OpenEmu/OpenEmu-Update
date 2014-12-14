	.include "memmap.inc"

	.export _pal_all,_pal_bg,_pal_spr,_pal_col,_pal_clear,_pal_fade
	.export _pal_fade_to_all,_pal_fade_to_bg,_pal_fade_to_spr
	.export _ppu_off,_ppu_on_all,_ppu_on_bg,_ppu_on_spr
	.export _oam_clear,_oam_spr,_oam_meta_spr
	.export _ppu_waitnmi
	.export _unrle_vram
	.export _scroll
	.export _bank_spr,_bank_bg
	.export _vram_read
	.export _music_play,_music_stop,_music_pause
	.export _sfx_play
	.export _pad_poll,_pad_trigger
	.export _rand,_setrand
	.export _set_vram_update,_vram_adr,_vram_put,_vram_fill,_vram_inc
	.export _memcpy
	.export FamiToneUpdate,FamiToneSfxInit,FamiToneInit;,FamiToneSampleInit
	.import popa,popax



;void __fastcall__ pal_all(const char *data);

_pal_all:
	sta <PTR
	stx <PTR+1
	ldy #$00
	ldx #$00
	lda #$20

pal_copy:
	sta <LEN
@0:
	lda (PTR),y
	sta PAL_BUF,x
	inx
	iny
	dec <LEN
	bne @0
	rts



;void __fastcall__ pal_bg(const char *data);

_pal_bg:
	sta <PTR
	stx <PTR+1
	ldy #$00
	ldx #$00
	lda #$10
	jmp pal_copy



;void __fastcall__ pal_spr(const char *data);

_pal_spr:
	sta <PTR
	stx <PTR+1
	ldy #$00
	ldx #$10
	txa
	jmp pal_copy



;void __fastcall__ pal_col(unsigned char index,unsigned char color);

_pal_col:
	sta <PTR
	jsr popa
	and #$1f
	tax
	lda <PTR
	sta PAL_BUF,x
	rts



;void __fastcall__ pal_clear(void);

_pal_clear:
	lda #$0f
	ldx #0
@1:
	sta PAL_BUF,x
	inx
	cpx #$20
	bne @1
	rts



;void __fastcall__ pal_fade(void);

_pal_fade:
	ldx #0
@1:
	lda PAL_BUF,x
	cmp #$10
	bcs @2
	lda #$0f
	bne @3
@2:
	sec
	sbc #$10
@3:
	sta PAL_BUF,x
	inx
	cpx #$20
	bne @1
	rts



;void __fastcall__ pal_fade_to_all(const unsigned char *pal);

_pal_fade_to_all:
	sta <PTR
	stx <PTR+1
	ldx #0
	ldy #0
	lda #32

pal_fade_to:
	sta <LEN
@1:
	lda PAL_BUF,x
	cmp (PTR),y
	beq @4
	cmp #$0f
	bne @2
	lda (PTR),y
	and #$0f
	jmp @3
@2:
	clc
	adc #$10
@3:
	sta PAL_BUF,x
@4:
	iny
	inx
	dec <LEN
	bne @1

	rts



;void __fastcall__ pal_fade_to_bg(const unsigned char *pal);

_pal_fade_to_bg:
	sta <PTR
	stx <PTR+1
	ldx #0
	ldy #0
	lda #16
	jmp pal_fade_to



;void __fastcall__ pal_fade_to_spr(const unsigned char *pal);

_pal_fade_to_spr:
	sta <PTR
	stx <PTR+1
	ldx #16
	ldy #0
	lda #16
	jmp pal_fade_to



;void __fastcall__ ppu_off(void);

_ppu_off:
	lda #0
	sta PPU_MASK
	sta PPU_CTRL
	rts



;void __fastcall__ ppu_on_all(void);

_ppu_on_all:
	lda #%00011110
	sta PPU_MASK
	lda <PPU_CTRL_VAR
	sta PPU_CTRL
	rts



;void __fastcall__ ppu_on_bg(void);

_ppu_on_bg:
	lda #%00001110
	sta PPU_MASK
	lda <PPU_CTRL_VAR
	sta PPU_CTRL
	rts



;void __fastcall__ ppu_on_spr(void);

_ppu_on_spr:
	lda #%00011110
	sta PPU_MASK
	lda <PPU_CTRL_VAR
	sta PPU_CTRL
	rts



;void __fastcall__ oam_clear(void);

_oam_clear:
	ldx #0
	lda #$ff
@1:
	sta OAM_BUF,x
	inx
	inx
	inx
	inx
	bne @1
	rts



;unsigned char __fastcall__ oam_spr(unsigned char x,unsigned char y,unsigned char chrnum,unsigned char attr,unsigned char sprid);

_oam_spr:
	sta <NEXTSPR
	asl a
	asl a
	tax

	jsr popa
	sta OAM_BUF+2,x
	jsr popa
	sta OAM_BUF+1,x
	jsr popa
	sta OAM_BUF+0,x
	jsr popa
	sta OAM_BUF+3,x

	inc <NEXTSPR
	lda <NEXTSPR
	and #$3f
	rts



;unsigned char __fastcall__ oam_meta_spr(unsigned char x,unsigned char y,unsigned char sprid,const unsigned char *data);

_oam_meta_spr:
	sta <PTR
	stx <PTR+1

	jsr popa
	asl a
	asl a
	tax

	jsr popa
	sta <SCRY
	jsr popa
	sta <SCRX

	ldy #0
@1:
	lda (PTR),y		;x offset
	cmp #$80
	beq @2
	iny
	clc
	adc <SCRX
	sta OAM_BUF+3,x
	lda (PTR),y		;y offset
	iny
	clc
	adc <SCRY
	sta OAM_BUF+0,x
	lda (PTR),y		;tile
	iny
	sta OAM_BUF+1,x
	lda (PTR),y		;attribute
	iny
	sta OAM_BUF+2,x
	inx
	inx
	inx
	inx
	jmp @1

@2:
	txa
	lsr a
	lsr a
	rts



;void __fastcall__ ppu_waitnmi(void);

_ppu_waitnmi:
	lda #1
	sta <VRAMUPDATE
	lda <FRAMECNT1
@1:
	cmp <FRAMECNT1
	beq @1
	lda <NTSCMODE
	beq @3
@2:
	lda <FRAMECNT2
	cmp #5
	beq @2
@3:
	lda #0
	sta <VRAMUPDATE
	rts



;void __fastcall__ unrle_vram(const unsigned char *data,unsigned int vram);

_unrle_vram:
	stx PPU_ADDR
	sta PPU_ADDR

	jsr popax
	sta <RLE_LOW
	stx <RLE_HIGH

	ldy #0
	jsr rle_byte
	sta <RLE_TAG
@1:
	jsr rle_byte
	cmp <RLE_TAG
	beq @2
	sta PPU_DATA
	sta <RLE_BYTE
	bne @1
@2:
	jsr rle_byte
	cmp #0
	beq @4
	tax
	lda <RLE_BYTE
@3:
	sta PPU_DATA
	dex
	bne @3
	beq @1
@4:
	rts

rle_byte:
	lda (RLE_LOW),y
	inc <RLE_LOW
	bne @1
	inc <RLE_HIGH
@1:
	rts



;void __fastcall__ scroll(unsigned int x,unsigned int y);

_scroll:
	sta <SCROLL_Y
	txa
	asl a
	and #$02
	sta <TEMP

	jsr popax
	sta <SCROLL_X
	txa
	and #$01
	ora <TEMP
	sta <TEMP
	lda <PPU_CTRL_VAR
	and #$fc
	ora <TEMP
	sta <PPU_CTRL_VAR
	rts



;void __fastcall__ bank_spr(unsigned char n);

_bank_spr:
	and #$01
	asl a
	asl a
	asl a
	sta <TEMP
	lda <PPU_CTRL_VAR
	and #%11110111
	ora <TEMP
	sta <PPU_CTRL_VAR
	rts



;void __fastcall__ bank_bg(unsigned char n);

_bank_bg:
	and #$01
	asl a
	asl a
	asl a
	asl a
	sta <TEMP
	lda <PPU_CTRL_VAR
	and #%11101111
	ora <TEMP
	sta <PPU_CTRL_VAR
	rts



;void __fastcall__ vram_read(unsigned char *dst,unsigned int adr,unsigned int size);

_vram_read:
	sta <TEMP
	stx <TEMP+1

	jsr popax
	stx PPU_ADDR
	sta PPU_ADDR
	lda PPU_DATA

	jsr popax
	sta <TEMP+2
	stx <TEMP+3

	ldy #0
@1:
	lda PPU_DATA
	sta (TEMP+2),y
	inc <TEMP+2
	bne @2
	inc <TEMP+3
@2:
	lda <TEMP
	bne @3
	dec <TEMP+1
@3:
	dec <TEMP
	lda <TEMP
	ora <TEMP+1
	bne @1

	rts



;void __fastcall__ music_play(const unsigned char *data);

_music_play:
	stx <PTR
	tax
	ldy <PTR
	jmp FamiToneMusicStart



;void __fastcall__ music_stop(void);

_music_stop:
	jmp FamiToneMusicStop



;void __fastcall__ music_pause(unsigned char pause);

_music_pause:
	jmp FamiToneMusicPause



;void __fastcall__ sfx_play(unsigned char sound,unsigned char channel);

_sfx_play:
	and #$03
	tax
	lda @sfxPriority,x
	tax
	jsr popa
	jmp FamiToneSfxStart

@sfxPriority:
	.byte FT_SFX_CH0,FT_SFX_CH1,FT_SFX_CH2,FT_SFX_CH3



;unsigned char __fastcall__ pad_poll(void);

_pad_poll:
	ldx #0
	jsr @padPollPort
	jsr @padPollPort
	jsr @padPollPort

	lda <PAD_BUF
	cmp <PAD_BUF+1
	beq @done
	cmp <PAD_BUF+2
	beq @done
	lda <PAD_BUF+1
@done:
	sta <PAD_STATE

	lda <PAD_STATE
	eor <PAD_STATEP
	and <PAD_STATE
	sta <PAD_STATET
	lda <PAD_STATE
	sta <PAD_STATEP

	lda <PAD_STATE

	rts

@padPollPort:
	ldy #$01
	sty CTRL_PORT1
	dey
	sty CTRL_PORT1
	ldy #8
@1:
	lda CTRL_PORT1
	and #$01
	clc
	beq @2
	sec
@2:
	ror <PAD_BUF,x
	dey
	bne @1

	inx
	rts



;unsigned char __fastcall__ pad_trigger(void);

_pad_trigger:
	jsr _pad_poll
	lda <PAD_STATET
	rts



;unsigned char __fastcall__ rand(void);
;Galois random generator, found somewhere
;out: A random number 0..255

_rand:
	lda <RAND_SEED
	asl a
	bcc @1
	eor #$cf
@1:
	sta <RAND_SEED
	rts



;void __fastcall__ setrand(unsigned char seed);

_setrand:
	sta <RAND_SEED
	rts



;void __fastcall__ set_vram_update(unsigned char len,unsigned char *buf);

_set_vram_update:
	sta <NAME_UPD_ADR
	stx <NAME_UPD_ADR+1
	jsr popa
	sta <NAME_UPD_LEN
	rts



;void __fastcall__ vram_adr(unsigned int adr);

_vram_adr:
	stx PPU_ADDR
	sta PPU_ADDR
	rts



;void __fastcall__ vram_put(unsigned char n);

_vram_put:
	sta PPU_DATA
	rts



;void __fastcall__ vram_fill(unsigned char n,unsigned char len);

_vram_fill:
	tax
	jsr popa
@1:
	sta PPU_DATA
	dex
	bne @1
	rts



;void __fastcall__ vram_inc(unsigned char n);

_vram_inc:
	beq @1
	lda #$04
@1:
	sta <TEMP
	lda <PPU_CTRL_VAR
	and #$fb
	ora <TEMP
	sta <PPU_CTRL_VAR
	sta PPU_CTRL
	rts



;void __fastcall__ memcpy(void *dst,void *src,unsigned int len);

_memcpy:
	sta <LEN
	stx <LEN+1
	jsr popax
	sta <SRC
	stx <SRC+1
	jsr popax
	sta <DST
	stx <DST+1

	ldx #0
@1:
	lda <LEN+1
	beq @2
	jsr @3
	dec <LEN+1
	inc <SRC+1
	inc <DST+1
	jmp @1
@2:
	ldx <LEN
	beq @5

@3:
	ldy #0
@4:
	lda (SRC),y
	sta (DST),y
	iny
	dex
	bne @4
@5:
	rts


	.include "famitone.s"