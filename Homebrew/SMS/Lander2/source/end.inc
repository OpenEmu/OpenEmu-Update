.section "end" force


Level12Ending:
    call WaitForVBlankLava
    
    call ResetSprites

    ld bc,-$4 ;//remove 4pix/256frame to y speed
    ld hl,(speedY)
    add hl,bc
    ld (speedY),hl
    ;draw fire sprite
    ld bc,(posX)
    ld a,b
    add a,$4;x+4
    ld h,a;x in h
    ld bc,(posY)
    ld a,b
    add a,$12;y+$12
    ld l,a;y in l
    ld d,fire_tile_number+1;number of the tile in VRAM in d
    call SpriteSet8x16
    
    ;change rocket status to bottom fire (1)
    ld a,1
    ld (rocket_status),a
    
    ;noise!
    ld c,%01100000;channel in c*%100000(max 3*%100000)
    call EnableChannel
    ld a,%00001000
    call PlayNoise

    ;mechanics
    ;increment Y-speed (gravity)
    ld hl,(speedY)
    inc hl
    inc hl
    ld (speedY),hl
    call UpdateVScroll

    ;update y pos
    ld bc,(posY)
    ld hl, (speedY)
    add hl,bc
    ld (posY),hl

    call DrawGameElements
    
    
    ;hide other sprites
    call SetLastSprite


    call UpdatePalette
    call UpdateScreen
    call PSGMOD_Play
    
    ;quit level when (posY)<5
    ld bc,(posY)
    ld a,b
    cp 5
    jp c,EndGame
    
  jp Level12Ending


EndGame:
  di  ; disable interrupts
  ; Turn screen off
  ld a,%10100000
;          |||| |`- Zoomed sprites -> 16x16 pixels
;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;          |||`---- 30 row/240 line mode
;          ||`----- 28 row/224 line mode
;          |`------ VBlank interrupts
;          `------- Disable display
  out ($bf),a
  ld a,$81
  out ($bf),a

  ;disable scrolling
  xor a
  out ($bf),a
  ld a,%10001000 ;x scroll
  out ($bf),a
  
  xor a
  out ($bf),a
  ld a,%10001001 ;y scroll
  out ($bf),a
  
  ;cut noise channel sound
  ld c,%01100000;channel in c*%100000(max 3*%100000)
  call CutOneChannel

    ;========================== TITLE ==============================
    ;==============================================================
    ; Clear VRAM
    ;==============================================================
    ; 1. Set VRAM write address to 0 by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output 16KB of zeroes
    ld bc, $4000    ; Counter for 16KB of VRAM
    -:
        ld a,$00    ; Value to write
        out ($be),a ; Output to VRAM address, which is auto-incremented after each write
        dec bc
        ld a,b
        or c
        jp nz,-
    

    ld hl,0
    ld (tiles_vram_used),hl
    ;==============================================================
    ; Load font tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output tile data
    ld bc,FontData_End-FontData_Start  ; Counter for number of bytes to write
    ld hl,FontData_Start              ; Location of tile data
    
    -:
        ; Output data byte then three zeroes, because our tile data is 1 bit
        ; and must be increased to 4 bit
        ld a,(hl)        ; Get data byte
        out ($be),a
        xor a
        out ($be),a
        out ($be),a
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-
    ld hl,(tiles_vram_used)
    ld bc,(FontData_End-FontData_Start)*4 ; *4 because 1bpp
    add hl,bc
    ld (tiles_vram_used),hl
    
    
    ;==============================================================
    ; Load sprites tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with (tiles_vram_used)
    ld a,l
    out ($bf),a
    ld a,h
    add a,$40
    out ($bf),a
    ; 2. Output tile data
    ld bc,Tiles_sprites_End-Tiles_sprites_Start  ; Counter for number of bytes to write
    ld hl,Tiles_sprites_Start              ; Location of tile data
    
    -:
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-
    ld hl,(tiles_vram_used)
    ld bc,Tiles_sprites_End-Tiles_sprites_Start
    add hl,bc
    ld (tiles_vram_used),hl
  
  ;call InitializeDemo
  call SetupLevel1
  
  ;setup end music
  ld hl,end_music_ch1_start
  call InitMusic1
  ld hl,end_music_ch2_start
  call InitMusic2
  ld hl,end_music_ch3_start
  call InitMusic3
  
  xor a
  ld (current_level),a ;just to stop color loop
  
    
  call ResetSprites
  call DrawGameElements
  
  ;draw score text
  ld c,1;col (tiles) in c
  ld l,8;line (tiles) in l
  ld de,TextCongratStart;text pointer in de
  ld a,1;have to write slowly
  call PrintText
  
  ;draw score text
  ld c,7;col (tiles) in c
  ld l,10;line (tiles) in l
  ld de,TextFinalScoreStart;text pointer in de
  ld a,1;have to write slowly
  call PrintText
  ;draw score number text
  ld l,10;line (tiles) in l
  ld bc,(score)
  ld e,b;value (8bit) in e
  ld c,22;col (tiles) in c
  call PrintInt8
  ;draw score number text
  ld l,10;line (tiles) in l
  ld bc,(score)
  ld e,c;value (8bit) in e
  ld c,25;col (tiles) in c
  call PrintInt8
  
  
  ;draw hiscore text
  ld c,7;col (tiles) in c
  ld l,12;line (tiles) in l
  ld de,TextHIScoreStart;text pointer in de
  ld a,1;have to write slowly
  call PrintText
  ;draw score number text
  ld l,12;line (tiles) in l
  ld bc,(hiscore)
  ld e,b;value (8bit) in e
  ld c,22;col (tiles) in c
  call PrintInt8
  ;draw score number text
  ld l,12;line (tiles) in l
  ld bc,(hiscore)
  ld e,c;value (8bit) in e
  ld c,25;col (tiles) in c
  call PrintInt8
  
  ;hide other sprites
  call SetLastSprite

  call UpdatePalette
  ; Turn screen on
  ld a,%11100000
;          |||| |`- Zoomed sprites -> 16x16 pixels
;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;          |||`---- 30 row/240 line mode
;          ||`----- 28 row/224 line mode
;          |`------ VBlank interrupts
;          `------- Enable display
  out ($bf),a
  ld a,$81
  out ($bf),a 
  ei 
  -:
    call WaitForVBlankWind

    call UpdateScreen
    call PSGMOD_Play
    
    call Menu_inputs
    ld a,(current_level)
    cp 0
    jp z,-
      
  jp EndGame2



EndGame2:  ;----------------- final scene
  jp demo
;  call InitializeDemo
;
;  EndGame2_MainLoop:
;    
;    ;scroll is implemented in WaitForVBlank
;    call Demo_WaitForVBlank
;    
;    call Demo_UpdateTiles
;    ;call UpdatePalette
;    ;call UpdateScreen
;
;    ld hl,(forest_anim_step)
;    ;forest anim speed is -2*Xscroll_speed
;    ld bc,(Xscroll_speed)
;    ld a,c
;    neg
;    add a,a
;    add a,a
;    ld c,a
;    ld b,0
;    add hl,bc
;    ld a,forest_anim_steps
;    cp h
;    jr nz,+
;      ld h,0
;    +:
;    ld (forest_anim_step),hl
;    ;make scroll forward
;    ld hl,(Xscroll)
;    ld bc,(Xscroll_speed)
;    add hl,bc
;    ld (Xscroll),hl
;
;
;    ld a,$06 ; at least 6 sprites to show (rocket)
;    ld (number_of_sprites),a
;    
;    ld a,(number_of_sprites)
;    ld c,$01 ; hide only next sprite, the following will be hidden too
;    call HideSprites
;    
;    ;pedal anim
;    ld hl,(pedal_anim_step)
;    ld bc,$20
;    add hl,bc
;    ld a,h
;    cp bike_pedal_anim_steps
;    jr nz,+
;    ld hl,0
;    +:
;    ld (pedal_anim_step),hl
;    
;    ;if demo speed is >$fd, got to anim step bike_pedal_anim_steps
;    ld hl,(demo_step)
;    ld a,(hl)
;    cp $fd
;    jr c,+
;      ld hl,bike_pedal_anim_steps*$100
;      ld (pedal_anim_step),hl
;    +:
;    
;    ;draw bike sprite
;    ld bc,(posX)    
;    ld h,b;x in h
;    ld bc,(posY)    
;    ld l,b;y in l
;    ld e,$0;sprite index in e, here these are the first sprites used
;    call Demo_SpriteSetBike
;
;
;    call Demo_PSGMOD_Play
;    
;    
;    call Demo_Inputs
;    
;    ld a,(current_level)
;    cp 0
;    jr nz,EndGame2_end
;    
;    jp EndGame2_MainLoop
;    
;  EndGame2_end:
;    call CutAllSound
;
;    jp demo



.ends ;--------------- end end section
