
;uses (refuel) to record if an input occured last frame
;uses (current_level)>0 to quit demo
Demo_Inputs:
  push af
    in a,($dc)
    ld (buttons),a
    or %11001111
    cp  %11111111
    jr z,Demo_Inputs_NoButtonPressed
    
    ;one button is pressed
    ;check if last frame it was released
    ld a,(refuel)
    cp 0
    jr nz,Demo_Inputs_end
    
    ld a,1
    ld (current_level),a;ask to quit
    ld a,1
    ld (refuel),a;a button was pressed
    
  Demo_Inputs_NoButtonPressed:  
    xor a
    ld (refuel),a;no button pressed last time
  Demo_Inputs_end:
  pop af
  ret


InitializeJmimu:
    di  ; disable interrupts
    ; Turn screen off
    ld a,%10100000
    ;      |||| |`- Zoomed sprites -> 16x16 pixels
    ;      |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
    ;      |||`---- 30 row/240 line mode
    ;      ||`----- 28 row/224 line mode
    ;      |`------ VBlank interrupts
    ;      `------- Disable display
    out ($bf),a
    ld a,$81
    out ($bf),a

    ;music init
    ld hl,jmimu_music_ch1_start;data1 start in hl
    call InitMusic1
    ld hl,jmimu_music_ch2_start;data2 start in hl
    call InitMusic2
    ld hl,0;data3 start in hl
    call InitMusic3

    ;disable scrolling
    xor a
    out ($bf),a
    ld a,%10001000
    out ($bf),a

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


    ;==============================================================
    ; clear palette
    ;==============================================================
    ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ; by outputting $c000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld b,32
    -:
      xor a
      out ($be),a
      dec c
      jr nz,-
    

    ;==============================================================
    ; Load tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output tile data
    ld hl,Tiles_jmimu_Start              ; Location of tile data
    ld bc,Tiles_jmimu_End-Tiles_jmimu_Start  ; Counter for number of bytes to write
    -:
        ; Output data byte then three zeroes, because our tile data is 1 bit
        ; and must be increased to 4 bit
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-

    
    ;==============================================================
    ; Write tilemap data
    ;==============================================================
    ; 1. Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+0
    ld a,$00
    out ($bf),a
    ld a,$38|$40
    out ($bf),a
    ; 2. Output tilemap data
    ld hl,jmimu_TilemapStart
    ld bc,jmimu_TilemapEnd-jmimu_TilemapStart  ; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-  




    ; setup screen (VDP register 0)
    ld a,%11000110
;         |||||||`- External Sync.
;         ||||||`-- 1
;         |||||`--- 1
;         ||||`---- Sprite Shift
;         |||`----- Line Interrupt Enable
;         ||`------ Left Column Blank
;         |`------- Horizontal Scroll Inhibit (top 2 char rows)
;         `-------- Vertical Scroll Inhibit (right 8 char columns).

    out ($bf),a
    ld a,$80
    out ($bf),a

    ; Turn screen on  (VDP register 1)
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
    
    ;small delay in order to loose nothing of the demo!
    
    ld hl,0
  -:
    inc hl
    call WaitForVBlankSimple
    ld a,l
    cp $20
    jp nz,-
    
    ;;how the color loop works :
    ;; fill the 16 colors index with colors in jmimu_colors
    ;ld hl,jmimu_colors
    ;ld b,(hl) ;color value
    ;ld d,0 ;counter
    ;jmimu_palette_loop:
    ;  ;set palette of jmimu
    ;  ;==============================================================
    ;  ; Update palette
    ;  ;==============================================================
    ;  ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ;  ; by outputting $c000 ORed with c (number of the color to change)
    ;  ld c,$01
    ;  -:
    ;    ld a,c
    ;    out ($bf),a
    ;    ld a,$c0
    ;    out ($bf),a
    ;    ; 2. Output colour data
    ;    ld a,b
    ;    out ($be),a
    ;    inc c
    ;    call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    ;call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    call Demo_PSGMOD_Play
    ;    call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    ;call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    ;call WaitForVBlankSimple
    ;    call Demo_PSGMOD_Play
    ;    ;call Demo_PSGMOD_Play
    ;    ld a,16
    ;    cp c
    ;  jr nz,-
    ;  inc d
    ;  inc hl
    ;  ld b,(hl)
    ;  ld a,5
    ;  cp d
    ;  jr nz,jmimu_palette_loop
    
    ;initialize input variables
    ld a,1
    ld (refuel),a;if refuel>0, an input has already been pressed
    xor a
    ld (current_level),a;if current_level>0 quit demo

    ;how the color loop works :
    ; fill the 16 colors index with 16 colors in jmimu_colors,
    ; index in jmimu_colors increasing slowly
    ld de,start_jmimu_colors
    ld ixl,64;48
    -:
      ;set palette of jmimu
      ;==============================================================
      ; Update palette
      ;==============================================================
      ; 1. Set VRAM write address to CRAM (palette) address 1 (for palette index 1)
      ; by outputting $c000 ORed with $0001
      ld a,$01
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      ; 2. Output colour data
      ld h,d
      ld l,e
      ld b,15
      ld c,$be
      otir
      ; 1. Set VRAM write address to CRAM (palette) address $11 (for palette index $11)
      ; by outputting $c000 ORed with $0001
      ld a,$11
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      ; 2. Output colour data
      ld b,15
      ld c,$be
      otir
      
      call WaitForVBlankSimple
      call Demo_PSGMOD_Play
      call Demo_Inputs
      call WaitForVBlankSimple
      call Demo_PSGMOD_Play
      call Demo_Inputs
      call WaitForVBlankSimple
      call Demo_PSGMOD_Play
      call Demo_Inputs
      
      ld a,(current_level)
      cp 0
      jr nz,InitializeJmimu_end
      
      dec de
      dec ixl
      jr nz,-
      
  InitializeJmimu_end:
ret




InitializeDemo:
    di  ; disable interrupts
    ; Turn screen off
    ld a,%10100000
    ;      |||| |`- Zoomed sprites -> 16x16 pixels
    ;      |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
    ;      |||`---- 30 row/240 line mode
    ;      ||`----- 28 row/224 line mode
    ;      |`------ VBlank interrupts
    ;      `------- Disable display
    out ($bf),a
    ld a,$81
    out ($bf),a
    
    ;disable scrolling
    xor a
    out ($bf),a
    ld a,%10001000
    out ($bf),a
    
    ;music init
    ld hl,demo4_music_ch1_start;data1 start in hl
    call InitMusic1
    ld hl,demo4_music_ch2_start;data2 start in hl
    call InitMusic2
    ld hl,0;data3 start in hl
    call InitMusic3

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

    ;load palette of title
    ;==============================================================
    ; Load palette
    ;==============================================================
    ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ; by outputting $c000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld hl,Forest_Palette_Start
    ld b,(Forest_Palette_End-Forest_Palette_Start)
    ld c,$be
    otir
    
    

    ;==============================================================
    ; Load tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output tile data
    ld hl,ForestTiles_Start              ; Location of tile data
    ld bc,ForestTiles_End-ForestTiles_Start  ; Counter for number of bytes to write
    -:
        ; Output data byte then three zeroes, because our tile data is 1 bit
        ; and must be increased to 4 bit
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-

    
    ;==============================================================
    ; Write tilemap data
    ;==============================================================
    ; 1. Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+0
    ld a,$00
    out ($bf),a
    ld a,$38|$40
    out ($bf),a
    ; 2. Output tilemap data
    ld hl,Forest_Tilemap_Start
    ld bc,Forest_Tilemap_End-Forest_Tilemap_Start  ; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-  

    call Demo_CreateForest


    ; setup screen (VDP register 0)
    ld a,%11100110
;         |||||||`- External Sync.
;         ||||||`-- 1
;         |||||`--- 1
;         ||||`---- Sprite Shift
;         |||`----- Line Interrupt Enable
;         ||`------ Left Column Blank
;         |`------- Horizontal Scroll Inhibit (top 2 char rows)
;         `-------- Vertical Scroll Inhibit (right 8 char columns).

    out ($bf),a
    ld a,$80
    out ($bf),a

    ; Turn screen on  (VDP register 1)
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

    ld a,1
    ld (new_frame),a

    ei;enable interruption (for vblank)

    ;initialize input variables
    ld a,1
    ld (refuel),a;if refuel>0, an input has already been pressed
    xor a
    ld (current_level),a;if current_level>0 quit demo

    ld bc,$0
    ld (forest_anim_step),bc

    xor a
    ld (Xscroll),a

    ld hl,0
    ld (pedal_anim_step),hl
    
    ld hl,$1000
    ld (posX),hl
    ld hl,$8800
    ld (posY),hl
    
    ld hl,Demo_Bike_Speed
    ld (demo_step),hl
    inc hl
    ld c,(hl)
    ld b,$ff
    ld (Xscroll_speed),bc
    inc hl
    ld a,(hl)
    ld (demo_step_counter),a
    
    ;ld hl,$10000-$8
    ;ld (Xscroll_speed),hl
ret

;--------------------------------------------------------------------
RunDemo:
  Demo_MainLoop:
    ;cut noise channel sound
    ld c,%01100000;channel in c*%100000(max 3*%100000)
    call CutOneChannel
    
    ld hl,(demo_step)
    ld c,(hl)
    ld b,0 ;x-speed in bc
    ;if c>128, speed=0 (special value)
    ld a,c
    cp $80
    jr c,+
      ld c,0
      ld b,0
  +:
    
    ld hl,(posX)
    add hl,bc
    ld (posX),hl
    
    ;update scrolling speed
    ld hl,(demo_step)
    inc hl
    ld a,(hl)
    cp 0
    jr nz,+
      ld bc,0
      ld (Xscroll_speed),bc
      jr RunDemo_noscroll
  +:
    ld c,a
    ld b,$ff
    ld (Xscroll_speed),bc
    
  RunDemo_noscroll:
    ;decrease step counter
    ld a,(demo_step_counter)
    dec a
    ld (demo_step_counter),a
    cp 0
    jr nz,RunDemo_counter_end
    ;go to next step
    ld hl,(demo_step)
    inc hl    
    inc hl
    inc hl    
    ld (demo_step),hl
    inc hl
    inc hl    
    ld a,(hl)
    ld (demo_step_counter),a
    
    
    ;if new step speed is $ff, quit demo
    ld hl,(demo_step)
    ld a,(hl)
    cp $ff 
    jr nz,RunDemo_counter_end
      ;quit demo
      ld a,1
      ld (current_level),a
  RunDemo_counter_end:
    
    ;scroll is implemented in WaitForVBlank
    call Demo_WaitForVBlank
    
    call Demo_UpdateTiles
    ;call UpdatePalette
    ;call UpdateScreen

    ld hl,(forest_anim_step)
    ;forest anim speed is -2*Xscroll_speed
    ld bc,(Xscroll_speed)
    ld a,c
    neg
    add a,a
    add a,a
    ld c,a
    ld b,0
    add hl,bc
    ld a,forest_anim_steps
    cp h
    jr nz,+
      ld h,0
    +:
    ld (forest_anim_step),hl
    ;make scroll forward
    ld hl,(Xscroll)
    ld bc,(Xscroll_speed)
    add hl,bc
    ld (Xscroll),hl


    ld a,$06 ; at least 6 sprites to show (rocket)
    ld (number_of_sprites),a
    
    ld a,(number_of_sprites)
    ld c,$01 ; hide only next sprite, the following will be hidden too
    call HideSprites
    
    ;pedal anim
    ld hl,(pedal_anim_step)
    ld bc,$20
    add hl,bc
    ld a,h
    cp bike_pedal_anim_steps
    jr nz,+
    ld hl,0
    +:
    ld (pedal_anim_step),hl
    
    ;if demo speed is >$fd, got to anim step bike_pedal_anim_steps
    ld hl,(demo_step)
    ld a,(hl)
    cp $fd
    jr c,+
      ld hl,bike_pedal_anim_steps*$100
      ld (pedal_anim_step),hl
    +:
    
    ;draw bike sprite
    ld bc,(posX)    
    ld h,b;x in h
    ld bc,(posY)    
    ld l,b;y in l
    ld e,$0;sprite index in e, here these are the first sprites used
    call Demo_SpriteSetBike


    call Demo_PSGMOD_Play
    
    
    call Demo_Inputs
    
    ld a,(current_level)
    cp 0
    jr nz,demo_end
    
    jp Demo_MainLoop
    
  demo_end:
    call CutAllSound
;======================== END TITLE ============================
ret




Demo_UpdateTiles:
    ;update tiles num forest_scroll_1st_tile_from_forest_start+forest_1st_tile and forest_scroll_1st_tile_from_forest_start+forest_1st_tile+1
    
    ;==============================================================
    ; Load tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index forest_scroll_1st_tile_from_forest_start
    ; by outputting $4000 ORed with (forest_scroll_1st_tile_from_forest_start)*$20
    ld bc,$20*(forest_scroll_1st_tile_from_forest_start+forest_1st_tile);has to be written in that order
    ld a,c
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$40
    or b
    out ($bf),a
    ; 2. Output tile data
    ld hl,Tree_ScrollingTilesStart ; Location of tile data
    ;set to correct step
    ld bc,(forest_anim_step)
    ld d,b ;d: counter
    ld bc,$20*2 ; add $20*2 bytes to jump to next tile
    -:
       ld a,d
       or d
       jr z,+
       add hl,bc
       dec d
       jr -
    +:


    ld c,$20*2  ; 2 tiles to update
    -:
        ; Output data byte then three zeroes, because our tile data is 1 bit
        ; and must be increased to 4 bit
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec c
        jp nz,-


    ret


Demo_CreateForest:
    ;write series of 0 - 1 on one line, then 2 - 3 ...
    ld bc,$280 ;byte to write in vram ($40 = 1 line)


    ;send tilemap to VDP line 0
    ld a,c
    out ($bf),a
    ld a,$38|$40  ; $4000 ORed with $3800+offset
    or b
    out ($bf),a
    ld c,$10
    -:
        ld a,forest_1st_tile  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a

        ld a,forest_1st_tile+1  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a
        dec c
        jr nz,-

    ;send tilemap to VDP line 1
    ld c,$10
    -:
        ld a,forest_1st_tile+2  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a

        ld a,forest_1st_tile+3  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a
        dec c
        jr nz,-

     ;send tilemap to VDP line 2
     ld c,$10
     -:
         ld a,forest_1st_tile+4  ;tile number (little endian)
         out ($be),a
         xor a  ;metadata
         out ($be),a
 
         ld a,forest_1st_tile+5  ;tile number (little endian)
         out ($be),a
         xor a  ;metadata
         out ($be),a
         dec c
         jr nz,-

     ;send tilemap to VDP line 3
     ld c,$10
     -:
         ld a,forest_1st_tile+6  ;tile number (little endian)
         out ($be),a
         xor a  ;metadata
         out ($be),a
 
         ld a,forest_1st_tile+7  ;tile number (little endian)
         out ($be),a
         xor a  ;metadata
         out ($be),a
         dec c
         jr nz,- 

    ;send tilemap to VDP line 4
    ld c,$10
    -:
        ld a,forest_scroll_1st_tile_from_forest_start+forest_1st_tile  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a

        ld a,forest_scroll_1st_tile_from_forest_start+forest_1st_tile+1  ;tile number (little endian)
        out ($be),a
        xor a  ;metadata
        out ($be),a
        dec c
        jr nz,-

    ;;send tilemap to VDP line 5,6,7,...
    ;ld c,$70
    ;-:
    ;    ld a,$1  ;tile number (little endian)
    ;    out ($be),a
    ;    xor a  ;metadata
    ;    out ($be),a
    ;
    ;    ld a,$1  ;tile number (little endian)
    ;    out ($be),a
    ;    xor a  ;metadata
    ;    out ($be),a
    ;    dec c
    ;    jr nz,-

    ret 



Demo_WaitForVBlank:
    push af
    
    ;no scroll at screen top
    xor a
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,%10001000
    out ($bf),a
    
    -:
      ;read scan line counter
      in a,($7E)
      ld c,a
      cp $20-1;if > $20, scroll quarter speed
      jr nz,+
      ld hl,(Xscroll)
      ld a,h
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,%10001000
      out ($bf),a
      
      +:
      ld a,c
      cp $50-1-8;if > $50, scroll half speed
      jr nz,+
      ld hl,(Xscroll)
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld a,h
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,%10001000
      out ($bf),a
      
      ;add hl,hl
      +:
      ld a,c
      cp $90-1;if > $90, scroll full speed
      jr nz,+
      ld hl,(Xscroll)
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld a,h
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,%10001000
      out ($bf),a
      +:
      
      
      ld a,(new_frame)
      cp 0
      jr z,-

      xor a
      ld (new_frame),a      
    pop af    
    ret   

Demo_PSGMOD_Play:
    ;~ ld c,0;channel in c*%100000(max 3*%100000)
    ;~ ld hl,(posY) ;Tone in hl (max 1024)
    ;~ ;ld l,h
    ;~ ;ld h,%00000011
    ;~ 
    ;~ ld a,h
    ;~ ;neg
    ;~ ld l,a
    ;~ ld h,%00000010
    ;~ 
    ;~ 
    ;~ call PlayTone
    ;~ 
    
    ;play harmonics or not depending on level number
    ;ld a,(current_level)
    ;and %00000001
    ;jr z,+
    ;call PlayMusicH
    ;ret
    ;+:
    call PlayMusic1
    call PlayMusic2
    ;call PlayMusic3

    ret




;--------------------------------------------------------------------
Demo_SpriteSetBike:
  ;x in h
  ;y in l
  ;sprite index in e
  
  ld bc,(pedal_anim_step);pedal anim step in b

  ld d,bike_tile_number

  ;vdp set addr
  ld a, e
  out ($bf), a
  ld a, $7f
  out ($bf), a

  ;fill all the y's
  ;y+0 y+0 y+0 y+0 y+0 y+0
  ;y+8 y+8 y+8 y+8 y+8 y+8 y+8
  ;y+16 y+16 y+16 y+16 y+16 y+16 y+16
  ld a, l
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  add a, $08
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  add a, $08
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  out ($be), a
  
  ld l,b
  
  ;vdp set addr
  ld a, e
  add a, a
  or $80
  out ($bf), a
  ld a, $7f
  out ($bf), a

  ;x+0 n+0   x+8 n+1   x+16 n+2   x+24 n+3   x+40 n+4   x+48 n+5
  ;x+0 n+6   x+8 n+7   x+16 n+8   x+24 n+9   x+32 n+10   x+40 n+bike_pedal_tile_number   x+48 n+11
  ;x+0 n+12   x+8 n+13   x+16 n+14   x+24 n+15   x+32 n+16   x+40 n+bike_pedal_tile_number+1   x+48 n+17
  ;x in a
  ;n in b
  
  ld c,$be
  ;line1
  ld a, h
  out (c), a
  ld b, d
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
;head part, changes with animation
 push af
 push hl
    ;if demo speed is >$fe, change head
    ld hl,(demo_step)
    ld a,(hl)
    cp $fe
    jr c,+
      ld a,b
      add a,24 ;add 24 to tile number
      ld b,a
  +:
 pop hl
 pop af
 
  add a,16
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
;go back to normal if head changed
 push af
 push hl
    ;if demo speed is >$fe, change head
    ld hl,(demo_step)
    ld a,(hl)
    cp $fe
    jr c,+
      ld a,b
      add a,-24 ;add 24 to tile number
      ld b,a

  +:
 pop hl
 pop af
  
  ;line2
  ld a,h
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  push af
  ld a,l
  add a,a
  add a,bike_pedal_tile_number
  ld e,a  ;tile number = bike_pedal_tile_number + anim_step*2
  pop af
  out (c), a
  out (c), e
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  ;line3
  ld a,h
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  inc b
  out (c), a
  out (c), b
  
  add a,8
  push af
  ld a,l
  add a,a
  add a,bike_pedal_tile_number
  inc a
  ld e,a  ;tile number = bike_pedal_tile_number + anim_step*2 +1
  pop af
  out (c), a
  out (c), e
  
  add a,8
  inc b
  out (c), a
  out (c), b
 
ret

