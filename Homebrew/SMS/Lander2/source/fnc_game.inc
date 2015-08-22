
.ramsection "Game variables" slot 1
  XScrollTotal             dw    ; total X scroll in level (in pixels)
  XScrollTotalMax          dw    ; maximum of XScrollTotal value (in pixels)
  XScrollVDP               db    ; VDP XScroll (in pixels)
  YScrollTotal             dw    ; total Y scroll in level (in pixels)
  YScrollTotalMax          dw    ; maximum of YScrollTotal value (in pixels)
  YScrollVDP               db    ; VDP YScroll (in pixels)
  LevelMapStart            dw    ; pointer to tilemap start (in bytes)
  NextMapDataStart         dw    ; pointer to tilemap new part to load due to scrolling (in bytes)
  LevelMapWidth            dw    ; tilemap width start (in tiles)
  YLava                    dw    ; total Y lava in level (in pixels)
  YLava_decimal            db    ; Y lava decimal part (1/256 pixels)
  YLava_speed              db    ; Y lava increase counter
  YLava_add_speed          db    ; YLava_speed increase counter
  
  OnStartFunction          dw    ; pointer to function called when starting level
  OnLandRightFunction      dw    ; pointer to function called when touching the ground
  OnLandLeftFunction       dw    ; pointer to function called when touching the ground
  OnOutFunction            dw    ; pointer to function called when out of screen
  WaitForVBlankFunction    dw    ; pointer to function WaitForVBlank
  
  gameStatus               db    ; 0: start, 1: play, 2: lost, 3: landed left, 4: landed right, 5: out of screen
  gameStatusCnt            dw    ; counter of game status
  first_frame_on_end_status db   ; 0: false, 1: true
.ends


.section "game functions" free

.include "fnc_ingame.inc"

;used to fake a call to a variable function
;function address is in (hl)
CallFunctionHL:
  ;PC was already pushed by "call CallFunctionHL" !
  jp (hl)

;update h scroll (only for 24-tile height tilemaps)
;input : c=add to h scroll (values can be -1,0,+1)
HScrollManager:
  push af
  push bc
  push de
  push hl
    ld a,c
    cp 0
    jp z,HScrollManager_end
    ld a,c
    cp 1
    jp z,HScrollManager_right
    ld a,c
    cp -1
    jp z,HScrollManager_left
    
  HScrollManager_right:
    ld hl,(XScrollTotal)

    ;check that XScrollTotal is not at XScrollTotalMax
    ld bc,(XScrollTotalMax)
    ld a,h
    cp b
    jr nz,+
    ld a,l
    cp c
    jr nz,+
    ;we are at max, stop scrolling
    jp z,HScrollManager_end
  +:
    ;update XScrollTotal
    inc hl
    ld (XScrollTotal),hl
    ;update posX
    ld hl,(posX)
    dec h
    ld (posX),hl
    
    ;update XScrollVDP
    ld a,(XScrollVDP)
    dec a
    ld (XScrollVDP),a
    ;VDP hz scrolling
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,%10001000
    out ($bf),a
    
    ;test if new tilemap row to load
    ld a,(XScrollVDP)
    and %00000111
    cp %00000111
    jp nz,HScrollManager_end
    
    ;new row to load
    
    ;compute where the new data is in rom
    ;(LevelMapStart)+(XScrollTotal)/4+64
    ld hl,(XScrollTotal)
    srl h
    rr l
    srl h
    rr l ;hl=(XScrollTotal)/4
    ld bc,64
    add hl,bc
    ld bc, (LevelMapStart)
    add hl,bc    
    ld (NextMapDataStart),hl;(NextMapDataStart)=(LevelMapStart)+(XScrollTotal)/4+64
    
    ;compute where to add it in vram : ((-XScrollVDP/8)%32)*2)
    ld a,(XScrollVDP)
    ld b,a
    xor a
    sub b
    dec a
    srl a
    srl a
    srl a
    and %00011111
    ld h,0
    ld l,a
    add hl,hl
    ld b,h
    ld c,l ;bc is where to add in vram
    
    ld hl,(LevelMapWidth);compute how much to add to get next line
    add hl,hl
    ld de,-1
    add hl,de
    
    ld d,h
    ld e,l ;de is how much bytes to complete a line

  -:
    ; Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+bc
    ld a,c
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$38|$40
    add a,b
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output tilemap data
    
    ld hl,(NextMapDataStart)
    ld a,(hl)    ; Get data byte
    out ($be),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    inc hl
    ld a,(hl)    ; Get data byte
    out ($be),a
    add hl,de ;update NextMapDataStart
    ld (NextMapDataStart),hl
    ;update bc (where to add in vram)
    ld h,b
    ld l,c
    ld bc,64
    add hl,bc
    ld b,h
    ld c,l
    
    ;test if end of screen: bc>$600
    ld a,b
    cp 6
    jr c,-
    jp HScrollManager_end
;!!!!!!!!!!!!!!!!
  HScrollManager_left:
  HScrollManager_end:
  pop hl
  pop de
  pop bc
  pop af
ret

;-------------------------------------------------------------------------------

;update v scroll (only for 32-tile wide tilemaps)
;input : c=add to v scroll (values can be -1,0,+1)
VScrollManager:
  push af
  push bc
  push hl
    ld a,c
    cp 0
    jp z,VScrollManager_end
    ld a,c
    cp 1
    jp z,VScrollManager_down
    ld a,c
    cp -1
    jp z,VScrollManager_up
    
    
  VScrollManager_down:
    ld hl,(YScrollTotal)

    ;check that YScrollTotal is not at YScrollTotalMax
    ld bc,(YScrollTotalMax)
    ld a,h
    cp b
    jr nz,+
    ld a,l
    cp c
    jr nz,+
    ;we are at max, stop scrolling
    jp z,VScrollManager_end
  +:
    ;update YScrollTotal
    inc hl
    ld (YScrollTotal),hl
    ;update posY
    ld hl,(posY)
    dec h
    ld (posY),hl
    
    ;update YScrollVDP
    ld a,(YScrollVDP)
    inc a
    ;check if YScrollVDP >223
    cp 224
    jr c,+
    ;if YScrollVDP >223
    xor a

  +:
    ld (YScrollVDP),a
    ;VDP vertical scrolling
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,%10001001
    out ($bf),a
    
    ;test if new tilemap line to load
    ld a,(YScrollVDP)
    and %00000111
    jp nz,VScrollManager_end
    ;new line to load
    
    ;compute where the new data is in rom
    ;(LevelMapStart)+((YScrollTotal)/8+24)*64
    ld hl,(YScrollTotal)
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l ;hl=(YScrollTotal)/8
    ld bc,24
    add hl,bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl;hl=((YScrollTotal)/8+24)*64
    ld bc, (LevelMapStart)
    add hl,bc    
    ld (NextMapDataStart),hl;(NextMapDataStart)=(LevelMapStart)+((YScrollTotal)/8+24)*32
    
    ;compute where to add it in vram : ((YScrollVDP+192)/8)*64
    ld a,(YScrollVDP)
    add a,192
    ;test if carry, then a<=a-224, because of v screen loop
    jr c,+
    ;test if a>224, then a<=a-224, because of v screen loop
    cp 224
    jr nc,+
    jr VScrollManager_down_no_carry
  +:
    sub 224
  VScrollManager_down_no_carry:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    
    ; Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+hl
    ld a,l
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$38|$40
    add a,h
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output tilemap data
    ld hl,(NextMapDataStart)
    ld bc,64  ; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-
    ;end of VScrollManager_down
    jp VScrollManager_end

    

  VScrollManager_up:
    ld hl,(YScrollTotal)

    ;check that YScrollTotal is not at 0
    ld a,h
    cp 0
    jr nz,+
    ld a,l
    cp 0
    jr nz,+
    ;we are at 0, stop scrolling
    
      ;only on level 11 enable out of memory 
      ld a,(current_level)
      cp number_of_levels
      jr z,+
      jp VScrollManager_end ;remove this line to enable out of memory 
  +:
    ;update YScrollTotal
    dec hl
    ld (YScrollTotal),hl
    ;update posY
    ld hl,(posY)
    inc h
    ld (posY),hl
    
    ;update YScrollVDP
    ld a,(YScrollVDP)
    cp 0
    jr nz,+
    ;check if YScrollVDP <0
    ld a,224
  +:
    dec a
    ld (YScrollVDP),a
    ;VDP vertical scrolling
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,%10001001
    out ($bf),a
    
    ;test if new tilemap line to load
    ld a,(YScrollVDP)
    and %00000111
    jp nz,VScrollManager_end
    ;new line to load

    ;compute where the new data is in rom
    ;(LevelMapStart)+((YScrollTotal-8)/8)*64
    ld hl,(YScrollTotal)
    ld bc,-$8
    add hl,bc
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l ;hl=(YScrollTotal)/8
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl;hl=((YScrollTotal-8)/8+24)*64
    ld bc, (LevelMapStart)
    add hl,bc    
    ld (NextMapDataStart),hl;(NextMapDataStart)=(LevelMapStart)+((YScrollTotal-8)/8)*32
    
    ;compute where to add it in vram : ((YScrollVDP-8)/8)*64
    ld a,(YScrollVDP)
    ld b,-$8
    add a,b
    ;test if a>223
    cp 224
    jr nc,+
    jr VScrollManager_up_no_carry
  +:
    sub 32 ;make a 32 line jump to compensate vram_h=224 instead of 256
  VScrollManager_up_no_carry:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    
    ; Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+hl
    ld a,l
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$38|$40
    add a,h
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output tilemap data
    ld hl,(NextMapDataStart)
    ld bc,64  ; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-
    ;end of VScrollManager_down
    jp VScrollManager_end
  VScrollManager_end:
  pop hl
  pop bc
  pop af
ret

;use difficulty_level (1 to 5)
SetDifficulty:
  push af
  push hl
    ld a,(difficulty_level)
    ld b,a
    
    ;use difficulty 0 for debugging
    ld a,b
    cp 0
    jr nz,+
    ;difficulty 0
    ld hl,-$1;0
    ld (fuel_use),hl;$-7
    ld hl,$60
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$60
    ld (speed_neg_tolerance),hl;$40
    ld hl,$-10
    ld (Xdumping),hl;$0
    ld a,1
    ld (refuel),a;$0
    ld a,0
    ld (big_rocket),a;$1
    
    ld a,2
    ld (YLava_add_speed),a
    
    jp SetDifficulty_end
  +:
    ld a,b
    cp 1
    jr nz,+
    ;difficulty 1
    ld hl,$-30
    ld (fuel_use),hl;$-7
    ld hl,$60
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$60
    ld (speed_neg_tolerance),hl;$40
    ld hl,$-10
    ld (Xdumping),hl;$0
    ld a,1
    ld (refuel),a;$0
    ld a,0
    ld (big_rocket),a;$1
    
    ld a,4
    ld (YLava_add_speed),a
    
    jp SetDifficulty_end
  +:
    ld a,b
    cp 2
    jr nz,+
    ;difficulty 2
    ld hl,$-40
    ld (fuel_use),hl;$-7
    ld hl,$55
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$55
    ld (speed_neg_tolerance),hl;$40
    ld hl,$-5
    ld (Xdumping),hl;$0
    ld a,1
    ld (refuel),a;$0
    ld a,0
    ld (big_rocket),a;$1
    
    ld a,8
    ld (YLava_add_speed),a

    ;skip tutorial
    ld a,3
    ld (current_level),a
    
    jp SetDifficulty_end
  +:
    ld a,b
    cp 3
    jr nz,+
    ;difficulty 3
    ld hl,$-50
    ld (fuel_use),hl;$-7
    ld hl,$50
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$50
    ld (speed_neg_tolerance),hl;$40
    ld hl,$0
    ld (Xdumping),hl;$0
    ld a,1
    ld (refuel),a;$0
    ld a,1
    ld (big_rocket),a;$1
    
    ld a,12
    ld (YLava_add_speed),a

    ;skip tutorial
    ld a,3
    ld (current_level),a
    
    jp SetDifficulty_end
  +:
    ld a,b
    cp 4
    jr nz,+
    ;difficulty 4
    ld hl,-$0B
    ld (fuel_use),hl;$-7
    ld hl,$50
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$50
    ld (speed_neg_tolerance),hl;$40
    ld hl,$0
    ld (Xdumping),hl;$0
    ld a,0
    ld (refuel),a;$0
    ld a,1
    ld (big_rocket),a;$1
    
    ld a,15
    ld (YLava_add_speed),a
    
    ;skip tutorial
    ld a,3
    ld (current_level),a
    
    jp SetDifficulty_end
  +:
    ld a,b
    cp 5
    jr nz,SetDifficulty_end
    ;difficulty 5
    ld hl,-$10
    ld (fuel_use),hl;$-7
    ld hl,$40
    ld (speed_pos_tolerance),hl;$40
    ld hl,-$40
    ld (speed_neg_tolerance),hl;$40
    ld hl,$0
    ld (Xdumping),hl;$0
    ld a,0
    ld (refuel),a;$0  
    ld a,1
    ld (big_rocket),a;$1
    
    ld a,20
    ld (YLava_add_speed),a
    
    ;skip tutorial
    ld a,3
    ld (current_level),a
    
  SetDifficulty_end:
  pop hl
  pop af
  ret



showLevel:
    
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

    ;load default palette
    ld hl,Title_Palette_Start
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
    ;ld hl,Title_Palette_Start
    ld b,(Title_Palette_End-Title_Palette_Start)
    ld c,$be
    otir

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
    
    ;draw texts before turning on screen to avoid problems
    ;draw hello text
    ld c,2;col (tiles) in c
    ld l,6;line (tiles) in l
    ld de,TextHelloStart;text pointer in de
    call PrintText
    
    ;draw level text
    ld c,7;col (tiles) in c
    ld l,10;line (tiles) in l
    ld de,TextLevelStart;text pointer in de
    ld a,1;have to write slowly
    call PrintText
    
    call ResetSprites
    ;draw level number text
    ld h,22*8;col (tiles) in h
    ld l,10*8-1;line (tiles) in l
    ld a,(current_level)
    ld e,a;value (8bit) in e
    ;call PrintInt8
    call PrintInt10Sprite ;print an uint8 in decimal with sprites
    
        
    ;draw lives text
    ld c,12;col (tiles) in c
    ld l,12;line (tiles) in l
    ld de,TextLevelLivesStart;text pointer in de
    ld a,1;have to write slowly
    call PrintText
    ;draw lives number
    ld h,13*8;col (tiles) in h
    ld l,12*8-1;line (tiles) in l
    ld a,(nb_lives)
    ld e,a;value (8bit) in e
    call PrintInt10Sprite ;print an uint8 in decimal with sprites
    
    ld h,10*8;x in h
    ld l,12*8-1;y in l
    ld d,guy_tile_number;n in d
    call SpriteSet16x8
    
    ;draw score text
    ld c,7;col (tiles) in c
    ld l,14;line (tiles) in l
    ld de,TextScoreStart;text pointer in de
    ld a,1;have to write slowly
    call PrintText
    ;draw score number text
    ld l,14;line (tiles) in l
    ld bc,(score)
    ld e,b;value (8bit) in e
    ld c,21;col (tiles) in c
    call PrintInt8
    ;draw score number text
    ld l,14;line (tiles) in l
    ld bc,(score)
    ld e,c;value (8bit) in e
    ld c,24;col (tiles) in c
    call PrintInt8
    
    
    ;draw hiscore text
    ld c,7;col (tiles) in c
    ld l,16;line (tiles) in l
    ld de,TextHIScoreStart;text pointer in de
    ld a,1;have to write slowly
    call PrintText
    ;draw score number text
    ld l,16;line (tiles) in l
    ld bc,(hiscore)
    ld e,b;value (8bit) in e
    ld c,21;col (tiles) in c
    call PrintInt8
    ;draw score number text
    ld l,16;line (tiles) in l
    ld bc,(hiscore)
    ld e,c;value (8bit) in e
    ld c,24;col (tiles) in c
    call PrintInt8
  
    
    call SetLastSprite

    
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

    ei  ; enable interrupts
    
    call WaitForButton
    ret


WaitForButton:
    ;out: b for button (1 or 2)
    call CutAllSound
    push af
      -:in a,($dc)
        and %00110000 ;is button 1?
        ld b,1
        cp  %00100000
        jr z,+
        in a,($dc)
        ld b,2
        and %00110000 ;is button 2?
        cp  %00010000
        jr z,+
        jr -
      +:
        ; Button down, wait for it to go up
      -:in a,($dc)
        and %00110000
        cp  %00110000
        jr nz,-
    pop af
    ret

ReadButtonsPlay:
    push af
        in a,($dc)
        ld (buttons),a
        and %00010000
        cp  %00000000
        jr nz,+
        call OnButton1
    +:  
        ld a,(buttons)
        and %00100000
        cp  %00000000
        jr nz,+
        call OnButton2
    +:  
        ld a,(buttons)
        and %00000001
        cp  %00000000
        jr nz,+
        call OnButtonUp
    +:  
        ld a,(buttons)
        and %00000010
        cp  %00000000
        jr nz,+
        call OnButtonDown
    +:  
        ld a,(buttons)
        and %00000100
        cp  %00000000
        jr nz,+
        call OnButtonLeft
    +:  
        ld a,(buttons)
        and %00001000
        cp  %00000000
        jr nz,+
        call OnButtonRight
    +:
    pop af
ret
 
OnButton1:
    ret
OnButton2:
    ret
OnButtonUp:
    ret
OnButtonDown:
    push af
    push bc
    push de
    push hl
        ld hl,(rocket_fuel) ;compare rocket_fuel to 0...
        ld a,h
        cp 0
        jp z,+
        ;if not, decrease rocket_fuel
        ld bc,(fuel_use)
        add hl,bc
        ld (rocket_fuel),hl
        

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
        
    +:
    pop hl
    pop de
    pop bc
    pop af
ret
OnButtonLeft:
    push af
    push bc
    push de
    push hl 
        ld hl,(rocket_fuel) ;compare rocket_fuel to 0...
        ld a,h
        cp 0
        jp z,+
        ;if not, decrease rocket_fuel
        ld bc,(fuel_use)
        add hl,bc
        ld (rocket_fuel),hl
        

        ld bc,$0004 ;//add 4pix/256frame to x speed
        ld hl,(speedX)
        add hl,bc
        ld (speedX),hl
        ;draw fire sprite
        ld bc,(posX)
        ld a,b
        sub $04;x-4
        ld h,a;x in h
        ld bc,(posY)
        ld a,b
        add a,$08;y+8
        ld l,a;y in l
        ld d,fire_tile_number;number of the tile in VRAM in d
        call SpriteSet8x8
        
        ;noise!
        ld c,%01100000;channel in c*%100000(max 3*%100000)
        call EnableChannel
        ld a,%00001000
        call PlayNoise
        
    +:
    pop hl
    pop de
    pop bc
    pop af
ret
OnButtonRight:
    push af
    push bc
    push de
    push hl
        ld hl,(rocket_fuel) ;compare rocket_fuel to 0...
        ld a,h
        cp 0
        jp z,+
        ;if not, decrease rocket_fuel
        ld bc,(fuel_use)
        add hl,bc
        ld (rocket_fuel),hl
        

        ld bc,$-4 ;//remove 4pix/256frame to x speed
        ld hl,(speedX)
        add hl,bc
        ld (speedX),hl
        ;draw fire sprite
        ld bc,(posX)
        ld a,b
        add a,$0C;x+12
        ld h,a;x in h
        ld bc,(posY)
        ld a,b
        add a,$08;y+8
        ld l,a;y in l
        ld d,fire_tile_number+3;number of the tile in VRAM in d
        call SpriteSet8x8
        
        ;noise!
        ld c,%01100000;channel in c*%100000(max 3*%100000)
        call EnableChannel
        ld a,%00001000
        call PlayNoise
        
    +:
    pop hl
    pop de
    pop bc
    pop af
ret


WaitForVBlankSimple:
    push af
    -:
      ;check if end of frame
      ld a,(new_frame)
      cp 0
      jr z,-

      xor a
      ld (new_frame),a
      
    pop af
  ret


PSGMOD_Play:
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
    call PlayMusic3

    ret
    


UpdateScreen:
    ret


UpdateHScroll:
    ;x scroll depending on posX
    ;if posX<108, scroll left
    ;if posX>148, scroll right
    ld hl, (posX)
    ld a,h ;a is the entire part of posX
    cp 108
    jr nc,+
    ld c,-1
    call HScrollManager
    ;once again to have a 2-speed scrolling
    ld hl, (posX)
    ld a,h ;a is the entire part of posX
    cp 108
    jr nc,+
    ld c,-1
    call HScrollManager
  +:
    cp 148
    jr c,+
    ld c,1
    call HScrollManager
    ld hl, (posX)
    ld a,h ;a is the entire part of posX
    cp 148
    jr c,+
    ld c,1
    call HScrollManager
  +:
    ret


UpdateVScroll:
    ;y scroll depending on posY
    ;if posY<60, scroll up
    ;if posY>100, scroll down
    ld hl, (posY)
    ld a,h ;a is the entire part of posY
    cp 60
    jr nc,+
    ld c,-1
    call VScrollManager
    ;once again to have a 2-speed scrolling
    ld hl, (posY)
    ld a,h ;a is the entire part of posY
    cp 60
    jr nc,+
    ld c,-1
    call VScrollManager
  +:
    cp 100
    jr c,+
    ld c,1
    call VScrollManager
    ld hl, (posY)
    ld a,h ;a is the entire part of posY
    cp 100
    jr c,+
    ld c,1
    call VScrollManager
  +:
    ret

DoGameLogicDbg:
    push af
  
    push bc
    push de
    push hl
    
    ;TODO: make it better
    ;update rocket status
    ;if 1, set to 0
    ld a,(rocket_status)
    cp 1
    jr nz,+
    xor a
    ld (rocket_status),a
  +:
    
    call drawWarning
    call TestAllCollisions
    ;if game status changed, quit this function
    ld a,(gameStatus)
    cp 1
    jp nz,DoGameLogicDbg_end
    
    ;mechanics
    ;increment Y-speed (gravity)
    ld hl,(speedY)
    inc hl
    inc hl
    ld (speedY),hl
    
    ;update x pos
    ld bc,(posX)
    ld hl, (speedX)
    add hl,bc
    ld (posX),hl
    ;update y pos
    ld bc,(posY)
    ld hl, (speedY)
    add hl,bc
    ld (posY),hl
            
    call UpdateHScroll
    call UpdateVScroll
    call ReadButtonsPlay
    
  DoGameLogicDbg_end:

    call DrawGameElements
    
    ;hide other sprites
    call SetLastSprite
    
    pop hl
    pop de
    pop bc
    pop af

    ret


;convert posX,posY (in pixel) and deltaX deltaY (in pixels)
;to number of tiles in VRAM (with scrolling)
;posX MSB in b
;posY MSB in c
;deltaX in d
;deltaY in e
;output:
;  x in h (in tiles)
;  y in l (in tiles)
;  x%8 in d (in pixels)
;  y%8 in e (in pixels)
RocketPos2vramTiles:
  push af
  push bc
    push bc;save (posX,posY)
    
    ;X part
    ld h,0
    ld l,b ;get posX
    ld c,d
    ld b,0 ;deltaX in bc
    add hl,bc
    
    ld a,(XScrollVDP)
    neg
    add a,l
    ld c,a
    ;sub scrolling value
    
    ld a,c
    and %00000111 ;keep x%8
    ld l,a
    
    ld h,c
    srl h;divide by 8
    srl h
    srl h
    ;x in h (in tiles)
    ;x%8 in l (in pixels)
    
    ;Y part
    pop bc ;get (posX,posY)
    push hl ;record x for later
    
    ld l,c
    ld h,0;Y in hl
    ld c,e
    ld b,0 ;deltaY in bc
    add hl,bc
    ;add scrolling value
    ld a,(YScrollVDP)
    ld c,a
    ld b,0
    add hl,bc
    
    ;only if vscroll has to check carry
    ld a,(YScrollVDP)
    cp 0
    jp z,RocketPos2vramTiles_VcarryOK
    
    ;have to check if hl>=224
    ;first test if >255
    ld a,h
    cp 0
    jr nz,RocketPos2vramTiles_Vcarry ;if>255, have a carry
    ld a,l
    cp 224
    jr c,RocketPos2vramTiles_VcarryOK;if<224, no carry
  RocketPos2vramTiles_Vcarry:
    ld bc,-224
    add hl,bc
    
    ;carry is handled
  RocketPos2vramTiles_VcarryOK:
    ld a,l
    and %00000111 ;keep y%8
    ld h,a
    
    srl l ;divide by 8
    srl l
    srl l
    ;y in l (in tiles)
    ;y%8 in h (in pixels)
    
    ;get x back
    pop bc
    ;x in b (in tiles)
    ;x%8 in c (in pixels)
    
    ld e,h
    ld h,b
    ld d,c
    ;x in h (in tiles)
    ;y in l (in tiles)
    ;x%8 in d (in pixels)
    ;y%8 in e (in pixels)
    
  pop bc
  pop af
  ret


TestAllCollisions:
      ;test if out of screen
      ld hl,(posY)
      ld a,h
      add a,24;bottom of the rocket
      cp 224
      jr c,+
      ld a,5 ;out of screen
      ld (gameStatus),a
      jp TestAllCollisions_end
    +:
      
      ;test point posX+8,posY
      ld bc,(posX);posX in b
      ld hl,(posY)
      ld c,h;posY in c
      ld d,8;deltaX in d
      ld e,1;deltaY in e
      ;if small rocket, add 2 pixels in deltaY
      ld a,(big_rocket)
      cp 1
      jr z,+
      inc e
      inc e
    +:
      call RocketPos2vramTiles
      call TestCollision
      
      ;test landing point posX+8,posY+25
      ld d,8;deltaX in d
      ld e,25;deltaY in e
      call RocketPos2vramTiles
      call TestLanding
      
      ;test point posX+2,posY+24
      ld d,2;deltaX in d
      ld e,24;deltaY in e
      call RocketPos2vramTiles
      call TestCollision
      
      ;test point posX+8,posY+24
      ld d,8;deltaX in d
      ld e,24;deltaY in e
      call RocketPos2vramTiles
      call TestCollision
      
      ;test point posX+13,posY+24
      ld d,13;deltaX in d
      ld e,24;deltaY in e
      call RocketPos2vramTiles
      call TestCollision
      
      ;test point posX+4,posY+12
      ld d,4;deltaX in d
      ld e,12;deltaY in e
      call RocketPos2vramTiles
      call TestCollision
      
      ;test point posX+11,posY+12
      ld d,11;deltaX in d
      ld e,12;deltaY in e
      call RocketPos2vramTiles
      call TestCollision
    
    TestAllCollisions_end:
    ret

;posX MSB in b ;unused
;posY MSB in c ;unused
;x in h (in tiles)
;y in l (in tiles)
;  x%8 in d (in pixels)
;  y%8 in e (in pixels)
TestCollision:;use tilemap collision data
    push af
    push bc
    push hl
    push de
      
      ;test if posY out of screen
      ld a,c
      cp 223
      jp c,+
        pop de
        jp TestCollision_end
    +:
      
      ;compute tile number
      ld b,0
      ld c,h;x in bc
      call Multby32 ;hl=l*32
      add hl,bc
      add hl,hl;multiply by 2
      ld b,l
      ld c,h
      ;tile number in bc
      
      ;try to read data in vram
      ; 1. Set VRAM read address to name table index 0
      ; by outputting $0000 ORed with $3800+bc
      ld a,b
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$38
      add a,c
      out ($bf),a
      ; 2. get tilemap data
      in a,($be)
      ld h,a
      in a,($be)
      ld c,a
      
      ;collision data is in c & %11100000
      pop de ;x%8 in d, y%8 in e
      ld a,c
      and %11100000
      cp  %00100000 ;test full block
      jr nz,+
      ;touches=> explode
      ld a,2
      ld (rocket_status),a
      ld hl,0
      ld (gameStatusCnt),hl
      ld a,2 ;lost
      ld (gameStatus),a
    +:
      ld a,c
      and %11100000
      cp  %01000000 ;test half bottom block
      jr nz,+
      ;touches=> check that point is below block half
      ld a,e
      cp 4
      jr c,+ ;if y%8<4, no collision
        ;explode
        ld a,2
        ld (rocket_status),a
        ld hl,0
        ld (gameStatusCnt),hl
        ld a,2 ;lost
        ld (gameStatus),a
    +:
      ld a,c
      and %11100000
      cp  %01100000 ;test half top block
      jr nz,+
      ;touches=> check that point is above block half
      ld a,e
      cp 4
      jr nc,+ ;if y%8>=4, no collision
        ;explode
        ld a,2
        ld (rocket_status),a
        ld hl,0
        ld (gameStatusCnt),hl
        ld a,2 ;lost
        ld (gameStatus),a
    +:
      
      ;now tests depends on flip bit
      ld a,c
      and %00000010
      cp  %00000010 ;test half side block
      jr z,TestCollision_HzFlip
      jp TestCollision_HzNoFlip
    TestCollision_HzFlip:
      ld a,c
      and %11100000
      cp  %10000000 ;test low ramp block
      jr nz,+
        ;touches=> check that point is in bottom left
        ld a,e
        cp d
        jr c,+ ;if y<x, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
      ld a,c
      and %11100000
      cp  %10100000 ;test high ramp block
      jr nz,+
        ;touches=> check that point is in top left
        ld a,e
        add a,d
        cp 8
        jr nc,+ ;if y+x>8, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
      ld a,c
      and %11100000
      cp  %11000000 ;test half side block
      jr nz,+
        ;touches=> check that point is left block half
        ld a,d
        cp 4
        jr nc,+ ;if x%8<4, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
        jp TestCollision_end
    TestCollision_HzNoFlip:
      ld a,c
      and %11100000
      cp  %10000000 ;test low ramp block
      jr nz,+
        ;touches=> check that point is in bottom right
        ld a,e
        add a,d
        cp 7
        jr c,+ ;if y+x<8, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
      ld a,c
      and %11100000
      cp  %10100000 ;test high ramp block
      jr nz,+
        ;touches=> check that point is in top right
        ld a,e
        cp d
        jr nc,+ ;if x<y, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
      ld a,c
      and %11100000
      cp  %11000000 ;test half side block
      jr nz,+
        ;touches=> check that point is left block half
        ld a,d
        cp 4
        jr c,+ ;if x%8>=4, no collision
          ;explode
          ld a,2
          ld (rocket_status),a
          ld hl,0
          ld (gameStatusCnt),hl
          ld a,2 ;lost
          ld (gameStatus),a
      +:
      
      
    TestCollision_end:
    pop hl
    pop bc
    pop af
    ret


;posX MSB in b ;TODO: use bc to get mod 8 part of positions
;posY MSB in c
;x in h (in tiles)
;y in l (in tiles)
TestLanding:;use tilemap collision data
    push af
    push bc
    push de
    push hl
    
      ;compute tile number
      ld b,0
      ld c,h;x in bc
      call Multby32 ;hl=l*32
      add hl,bc
      add hl,hl;multiply by 2
      ld b,l
      ld c,h
      ;tile number in bc
      
      ;try to read data in vram
      ; 1. Set VRAM read address to name table index 0
      ; by outputting $0000 ORed with $3800+bc
      ld a,b
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$38
      add a,c
      out ($bf),a
      ; 2. get tilemap data
      in a,($be)
      ld h,a
      in a,($be)
      ld l,a
      
      ;collision data is in l & %11100000
      ld d,a;keep tile data in d
      ld a,l
      and %11100000
      cp %11100000
      jr nz,TestLanding_end
      
      TestLanding_debug:
        ;touches=> test if speed is low enough
        ;in x:
        ld hl,(speedX)
        ;test if speed >0
        ld a,h
        cp 0
        jr z,+
        cp 255
        jr z,+
        jp TestLanding_explode ;if h!=0 and h!=255, explode
      +:
        ;first, test if h==0
        cp 0
        jr nz,+
        ;positive hz speed
        ;test if l<speed_pos_tolerance
        ld bc,(speed_pos_tolerance)
        ld a,l
        cp c
        jr nc,TestLanding_explode
        jp TestLanding_y
       +:
        ;negative hz speed
        ;test if l>speed_neg_tolerance
        ld bc,(speed_neg_tolerance)
        ld a,l
        cp c
        jr c,TestLanding_explode ;TODO: speed_neg_tolerance must be -(speed_pos_tolerance)-1?
        
      TestLanding_y:  
        ;in y:
        ld hl,(speedY)
        ;if speed negative=> nothing happens
        ld a,h
        cp $80
        jp nc,TestLanding_end
        
        ;test if h==0
        ld a,h
        cp 0
        jr nz,TestLanding_explode
        ;then test if l<speed_pos_tolerance
        ld bc,(speed_pos_tolerance)
        ld a,l
        cp c
        jr nc,TestLanding_explode

      ;landed!
      ld hl,0
      ld (gameStatusCnt),hl
      ld a,3 ;landed left
      ld (gameStatus),a
      ;check hz flip
      ld a,d;keep tile data in d
      and %00000010 ;test hz flip flag
      cp  %00000010
      jr z,+
        ld a,4 ;landed right
        ld (gameStatus),a
    +:
      jr TestLanding_end
      
    TestLanding_explode:
      ld a,2
      ld (rocket_status),a
      ld hl,0
      ld (gameStatusCnt),hl
      ld a,2 ;lost
      ld (gameStatus),a
      
      ;refill!
      ld a,1
      ld (already_lost),a
      
    TestLanding_end:
    pop hl
    pop de
    pop bc
    pop af
    ret


.ends ;--------------- end game section





