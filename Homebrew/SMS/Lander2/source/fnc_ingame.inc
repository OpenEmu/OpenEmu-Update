;-------------------------------------------------------------------
DrawRocket:
  ;x in h
  ;y in l
  
  push af
  push bc
  push de
    
    ;if y in [$C0:$D0], don't print
    ld a,l
    cp $C0
      jr c,DrawRockey_start
    cp $D0+1
      jr nc,DrawRockey_start
    jp DrawRockey_end

  DrawRockey_start:
    ;select rocket image
    ld a,(rocket_status)  
    cp 0
    jr nz,DrawRocket_testFire ;if 0, normal image
    ld b,normal_rocket_tile_number
    ;test if small rocket
    ld a,(big_rocket)
    cp 0
    jr nz,+
    inc b;if small rocket start 2 tiles later
    inc b
  +: 
    jr DrawRockey_top_ready
    
  DrawRocket_testFire:
    cp 1
    jr nz,DrawRocket_testExplosion ;if 1, bottom fire image
    ld b,fire_rocket_tile_number
    ;test if small rocket
    ld a,(big_rocket)
    cp 0
    jr nz,+
    inc b;if small rocket start 2 tiles later
    inc b
  +: 
    jr DrawRockey_top_ready
    
  DrawRocket_testExplosion:
    cp 2
    jr nz,DrawRockey_top_ready ;if 2, explosion image
    ld b,explosion_tile_number    
  
  
  
  DrawRockey_top_ready:
    ;top part
    ld d,b;number of the tile in VRAM in d
    
    call SpriteSet16x8
    
    ;select rocket image
    ld a,(rocket_status)  
    cp 0
    jr nz,+ ;if 0, normal image
    ld b,normal_rocket_tile_number+4
    jr DrawRockey_bottom_ready
  +:
    cp 1
    jr nz,+ ;if 1, bottom fire image
    ld b,fire_rocket_tile_number+4
    jr DrawRockey_bottom_ready
  +:
    cp 2
    jr nz,+ ;if 2, explosion image
    ld b,explosion_tile_number+2
  +:
  
  DrawRockey_bottom_ready:
    ;bottom part
    ld a,l
    add a,8
    ld l,a;y+8
    ld d,b
    inc e
    inc e
    call SpriteSet16x16
    
  DrawRockey_end:

  pop de
  pop bc
  pop af
  ret
  
;Print a text in the middle of the screen when scrolling
PrintTextMiddleScroll:
    ;col (tiles) in c
    ;line relative to screen top (tiles) in l
    ;text pointer in de
    ;text length in b
    ;the constant "diff_tile_ascii"  must represent difference between index in tiles and in ascii
    ;XScrollVDP YScrollVDP variable is used
    
    ld a,(YScrollVDP)
    srl a
    srl a
    srl a
    add a,l;add YScrollVDP/8 to line number
    
    ;if a>=28, a=a-28
    cp 27
    jr c,+
      sub 28
  +:
    ld l,a
    
    ;hz part
    ld a,(XScrollVDP)
    neg
    srl a
    srl a
    srl a
    add a,c;add XScrollVDP/8 to line number
    ld c,a
    
    call PrintText

    ret


;update game status
;gameStatus= 0: start, 1: play, 2: lost, 3: landed left, 4: landed right, 5: out of screen
GameStatusUpdate:
    call ResetSprites

    ld a,(gameStatus)
    cp 0 ;test on gameStatus
    jp nz,GameStatusUpdate_sup0
    
      ;if gameStatus==0 (start)
      ld hl,(OnStartFunction)
      call CallFunctionHL;act as "call (hl)"
      jp GameStatusUpdate_end
      
  GameStatusUpdate_sup0:
    ld a,(gameStatus)
    cp 1 ;test on gameStatus
    jp nz,GameStatusUpdate_sup1
    ;if gameStatus==1 (play)
      call DoGameLogicDbg
      jp GameStatusUpdate_end
    
  GameStatusUpdate_sup1:
    ld a,(gameStatus)
    cp 2 ;test on gameStatus
    jp nz,GameStatusUpdate_sup2
    ;if gameStatus==2 (lost)
      call DoLost
      jp GameStatusUpdate_end
    
  GameStatusUpdate_sup2:
    ld a,(gameStatus)
    cp 3 ;test on gameStatus
    jp nz,GameStatusUpdate_sup3
    ;if gameStatus==3 (landed left)
      ld hl,(OnLandLeftFunction)
      call CallFunctionHL;act as "call (hl)"
      jp GameStatusUpdate_end

  GameStatusUpdate_sup3:
    ld a,(gameStatus)
    cp 4 ;test on gameStatus
    jp nz,GameStatusUpdate_sup4
    ;if gameStatus==4 (landed right)
      ld hl,(OnLandRightFunction)
      call CallFunctionHL;act as "call (hl)"
      jp GameStatusUpdate_end

  GameStatusUpdate_sup4:
    ld a,(gameStatus)
    cp 5 ;test on gameStatus
    jp nz,GameStatusUpdate_end
    ;if gameStatus==5 (out of screen)
      ld hl,(OnOutFunction)
      call CallFunctionHL;act as "call (hl)"
      jp GameStatusUpdate_end
  
  GameStatusUpdate_end:
    ret
    
;-------------------------------------------------------------------------------
DoStart:
    ld hl,(gameStatusCnt)
    ld bc,$6 ;increment gameStatusCnt
    add hl,bc
    ld (gameStatusCnt),hl

    in a,($dc)
    or %11001101
    cp  %11111111
    jr z,+
      ;if bottom pressed:
      
      ;if not first second:
      ld a,h
      cp 1
      jr c,+
      
      ;print go
      ld h,$78;x in h
      ld l,$50;y in l
      ld d, 39;n in d
      call SpriteSet8x8
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 47;n in d
      call SpriteSet8x8
      ld h,$88;x in h
      ld l,$50;y in l
      ld d,  1;n in d
      call SpriteSet8x8
      ;end of start part
      ld a,1
      ld (gameStatus),a
      ld hl,0
      ld (gameStatusCnt),hl
  +:
    
    ;show 3,2,1,GO!
    ld a,h
    cp 0
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 19;n in d
      call SpriteSet8x8
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 1
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 18;n in d
      call SpriteSet8x8
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 2
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 17;n in d
      call SpriteSet8x8
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 3
    jr nz,+
      ld h,$78;x in h
      ld l,$50;y in l
      ld d, 39;n in d
      call SpriteSet8x8
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 47;n in d
      call SpriteSet8x8
      ld h,$88;x in h
      ld l,$50;y in l
      ld d,  1;n in d
      call SpriteSet8x8
  +:
    
    ld hl,(gameStatusCnt)
    ld a,h
    cp 4
    jr nz,+
    ;if gameStatusCnt too big, change to play status
    ld a,1
    ld (gameStatus),a
    ld hl,0
    ld (gameStatusCnt),hl
  +:

    call DrawGameElements
    
    ;hide other sprites
    call SetLastSprite
  ret

DrawGameElements:
    ;draw rocket sprites
    ld bc,(posX)    
    ld h,b;x in h
    ld bc,(posY)    
    ld l,b;y in l
    call DrawRocket
    
    ;draw fuel logo
    ld h,8 ;col (pix) in h
    ld l,8 ;line (pix) in l
    ld d,fuel_tile_number
    call SpriteSet8x8
    ;fuel value
    ld hl,(rocket_fuel)
    ld e,h;value (8bit) in e
    ld h,16 ;col (pix) in h
    ld l,8 ;line (pix) in l
    call PrintInt10Sprite
    
    
    ;draw lives
    ld h,8 ;col (pix) in h
    ld l,8*2 ;line (pix) in l
    ld d,guy_tile_number
    ld a,(nb_lives)
    ld c,a
  -:
    cp 0
    jr z,+
      call SpriteSet16x8
      ld a,l
      add a,8
      ld l,a
      dec c
      dec d
      ld a,c
      jr -
   +:
  ret

;-------------------------------------------------------------------------------
DoLost:
    ;play music if first time in DoLost
    ld a,(first_frame_on_end_status)
    cp 1
    jr nz,+
      ld hl,lost_music_ch1_start
      call InitMusic1
      ld hl,nosound_start
      call InitMusic2
      ld hl,nosound_start
      call InitMusic3
      xor a
      ld (first_frame_on_end_status),a
      
      ;one life less
      ld a,(nb_lives)
      dec a
      ld (nb_lives),a
    +:

    ;stop lava
    xor a
    ld (YLava_speed),a
    
    ld a,(nb_lives)
    cp 0
    jr nz,+
      ;no life
      jp DoLostNoLife
  +:
    jp DoLostLives
  

DoLostNoLife:
    ;read buttons
    in a,($dc)
    or %11001111
    cp  %11111111
    jr z,+
        ld sp, $dff0 ;clear stack
        jp ShowMenu
  +:
    call DrawGameElements
    
    ;draw lost text
    ld c,11;col (tiles) in c
    ld l,10;line (tiles) in l
    ld de,TextLost3Start;text pointer in de
    ld a,1;have to write slowly ?????????
    call PrintTextMiddleScroll
    
    ld c,2;col (tiles) in c
    ld l,11;line (tiles) in l
    ld de,TextLost4Start;text pointer in de
    ld a,1;have to write slowly ?????????
    call PrintTextMiddleScroll
    
    call drawWarning;to see what went wrong

    ld l,13;line (tiles) in l
    ld a,(YScrollVDP)
    srl a
    srl a
    srl a
    add a,l;add YScrollVDP/8 to line number
    ;if a>=28, a=a-28
    cp 27
    jr c,+
      sub 28
  +:
    ld l,a
    
    ld c,7;col (tiles) in c
    ;hz part
    ld a,(XScrollVDP)
    neg
    srl a
    srl a
    srl a
    add a,c;add XScrollVDP/8 to line number
    ld c,a
    
    ;draw score text
    ;ld c,7;col (tiles) in c
    ld de,TextScoreStart;text pointer in de
    ld a,1;have to write slowly
    ;ld l,13;line (tiles) in l
    call PrintText
    ;draw score number text
    ld de,(score)
    ld e,d;value (8bit) in e
    ld a,c
    add a,15
    cp 32
    jr c,+
      sub 32
   +:
    ld c,a
    ;ld c,22;col (tiles) in c
    ;ld l,13;line (tiles) in l
    call PrintInt8
    ;draw score number text
    ld de,(score);value (8bit) in e
    ld a,c
    add a,3
    cp 32
    jr c,+
      sub 32
   +:
    ld c,a
    ;ld c,25;col (tiles) in c
    ;ld l,13;line (tiles) in l
    call PrintInt8
    
    ld a,l
    inc a
    inc a
    ;if a>=28, a=a-28
    cp 27
    jr c,+
      sub 28
  +:
    ld l,a
    
    ld c,7;col (tiles) in c
    ;hz part
    ld a,(XScrollVDP)
    neg
    srl a
    srl a
    srl a
    add a,c;add XScrollVDP/8 to line number
    ld c,a
    
    ;draw hiscore text
    ;ld c,7;col (tiles) in c
    ld de,TextHIScoreStart;text pointer in de
    ld a,1;have to write slowly
    ;ld l,15;line (tiles) in l
    call PrintText
    ;draw score number text
    ld de,(hiscore)
    ld e,d;value (8bit) in e
    ld a,c
    add a,15
    cp 32
    jr c,+
      sub 32
   +:
    ld c,a
    ;ld c,22;col (tiles) in c
    ;ld l,15;line (tiles) in l
    call PrintInt8
    ;draw score number text
    ld de,(hiscore);value (8bit) in e
    ld a,c
    add a,3
    cp 32
    jr c,+
      sub 32
   +:
    ld c,a
    ;ld c,25;col (tiles) in c
    ;ld l,15;line (tiles) in l
    call PrintInt8

    ;hide other sprites
    call SetLastSprite
    
    ret

DoLostLives:
    ;read button 1
    in a,($dc)
    and %00010000
    cp  %00000000
    jr nz,+
        ld hl,(rocket_fuel_level_start)
        ld (rocket_fuel),hl
        
        ld sp, $dff0 ;clear stack
        jp NewLevel
  +:  
    
    ;read button 2
    in a,($dc)
    and %00100000
    cp  %00000000
    jr nz,+
        ld hl,(rocket_fuel_level_start)
        ld (rocket_fuel),hl
        
        ld sp, $dff0 ;clear stack
        jp ShowMenu
  +:
    
    call DrawGameElements
    
    ;draw lost text
    ld c,2;col (tiles) in c
    ld l,10;line (tiles) in l
    ld de,TextLost1Start;text pointer in de
    ld a,1;have to write slowly ?????????
    call PrintTextMiddleScroll
    
    ld c,2;col (tiles) in c
    ld l,11;line (tiles) in l
    ld de,TextLost2Start;text pointer in de
    ld a,1;have to write slowly ?????????
    call PrintTextMiddleScroll
    
    call drawWarning;to see what went wrong

    ;hide other sprites
    call SetLastSprite

    ret

;-------------------------------------------------------------------------------
DoWait:
    push af
  
    push bc
    push de
    push hl
    
    ld a,1 ;start
    ld (gameStatus),a
    
    ;if no more fuel, lost
    ld hl,(rocket_fuel)
    ld a,h
    cp 0
    jr nz,+
      call DoLost
  +:
    
    
    ;update rocket status
    ;if 1, set to 0
    ld a,(rocket_status)
    cp 1
    jr nz,+
    xor a
    ld (rocket_status),a
  +:
    
    ;mechanics
    ;forbid speedY to be positive
    ld hl,(speedY)
    ld a,h
    cp 0
    jr nz,+;if speed positive, set it to zero
    ld hl,0
    ld (speedY),hl
   +:
    ld hl,0
    ld (speedX),hl
    
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
    
    
    call ReadButtonsPlay
    
    call DrawGameElements
    
    ;call drawWarning
    ;call TestAllCollisions

    ;hide other sprites
    call SetLastSprite
    
    pop hl
    pop de
    pop bc
    pop af

    ret

;-------------------------------------------------------------------------------
DoWon:
    ld a,(first_frame_on_end_status)
    cp 1
    jr nz,DoWon_not_firstframe
      ;only on first frame of DoWon
      
      ;add to score only if level>2
      ld a,(current_level)
      cp 3
      jr c,+
      ld hl,(score)
      ld bc,(rocket_fuel)
      ld c,b
      xor a
      ld b,a ;bc=rocket_fuel/256
      add hl,bc
      
      ld b,h
      ld c,l
      ;add $80 for each difficulty level
      ld a,(difficulty_level)
      ld l,a
      call Multby32 ;mult l by 32, result in hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      
      ld (score),hl ;score+=rocket_fuel/256 + $20*difficulty_level
      
      ;test if > hiscore
      ld hl,(score)
      ld bc,(hiscore)
      or a ; reset carry flag (see http://www.smspower.org/Development/Z80ProgrammingTechniques#SubHlde)
      sbc hl,bc
      ;hl=(score)-(hiscore)
      ;if h>80, hiscore>score
      ld a,h
      cp 80
      jr nc,+
        ld hl,(score)
        ld (hiscore),hl
     +:
     
      ld hl,win_music_ch1_start
      call InitMusic1
      ld hl,nosound_start
      call InitMusic2
      ld hl,nosound_start
      call InitMusic3
      xor a
      ld (first_frame_on_end_status),a
   DoWon_not_firstframe:

    
    ;read button 1
    in a,($dc)
    and %00010000
    cp  %00000000
    jr nz,+
        ld sp, $dff0 ;clear stack
        ld a,(current_level)
        inc a
        ld (current_level),a
        jp NewLevel
  +:  
    
    call DrawGameElements
    
    ;draw player
    ld bc,(posX)    
    ld h,b;x in h
    ld bc,(posY)    
    ld l,b;y in l
    ld bc,$0808
    add hl,bc ;draw the guy a little further
    ld d,guy_tile_number;number of the tile in VRAM in d
    ld e,$6;sprite index in e, 6 because we draw the rocket too
    call SpriteSet16x16
    
    
    ;draw won text
    ld c,2;col (tiles) in c
    ld l,10;line (tiles) in l
    ld de,TextWonStart;text pointer in de
    ld a,1;have to write slowly ?????????
    call PrintTextMiddleScroll

    ;hide other sprites
    call SetLastSprite
    
    ret

UpdatePalette:
   push af
   push bc
   push hl
   
   ;update lava position
   ld a,(YLava_speed)
   ld b,a
   ld a,(YLava_decimal)
   add a,b
   ld (YLava_decimal),a
   cp $60
   jr c,+
     xor a
     ld (YLava_decimal),a
     ;has to change lava pos
     ld hl,(YLava)
     dec hl
     ld (YLava),hl
  +:
    
    ;on certain y value, lava speed increases
    ld hl,(YLava)
    ld a,l
    and %00111111
    cp  %00000000
    jr nz,+
      ld a,(YLava_add_speed)
      ld b,a
      ld a,(YLava_speed)
      add a,b
      ld (YLava_speed),a
  +:
    ;if lava too high, it stops
    ld hl,(YLava)
    ld a,h
    cp 0
    jr nz,+
      ld a,l
      cp 0
      jr nz,+
        xor a
        ld (YLava_speed),a
  +:
    
  
   
    ;update star color
    ld hl,(star_color1)
    ld bc,$100 ;color change speed
    add hl,bc
    ld (star_color1),hl
    ld hl,(star_color2)
    ld bc,$100 ;color change speed
    add hl,bc
    ld (star_color2),hl
    ;==============================================================
    ; Update palette
    ;==============================================================
    ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ; by outputting $c000 ORed with number of the color to change
    ld a,$0F
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld hl,(star_color1)
    ld a,h
    and %00110000 ;use only bright colors (let only blue byte change)
    or  %00001111 ; R and G are at max
    out ($be),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    
    ;update fire color 1
    ld a,$1A
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld hl,(star_color1)
    ld a,h
    and %00110101 ;use only bright colors (let only blue byte change)
    or  %00001010 ; R and G are at max
    out ($be),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    
    ;update fire color 2
    ld a,$1B
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld hl,(star_color2)
    ld a,h
    and %00110101 ;use only bright colors (let only blue byte change)
    or  %00001010 ; R and G are at max
    out ($be),a
    
    ;if level>1, landing zone color loop
    ld a,(current_level)
    cp 3
    jp c,UpdatePalette_end
    
    ;-----------------------------landing zone part-----------------------------
    ;loop on landing_zone_color, to change colors 11-14 of palette
    ;looking at values in LandingColorLoop
    
    ;inc landing_zone_color
    ld hl,(landing_zone_color)
    ld bc,$20 ;color loop speed
    add hl,bc
    ;test if end of loop
    ld a,h
    cp 4
    jr nz,+
    ld hl,0
  +:
    ld (landing_zone_color),hl
    ; landing_zone_color is updated
    
    
    ld bc,(landing_zone_color)
    ld a,b
    ld hl,LandingColorLoop
    ;inc hl while a>0
  -:
    cp 0
    jr z,+
    inc hl
    dec a
    jr -
  +: ;hl is the correct starting address
    
    ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ; by outputting $c000 ORed with number of the color to change
    ld a,11 ;change color 11
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output colour data
    ld a,(hl)
    out ($be),a
    
    inc hl
    inc b
    ld a,b
    cp 4
    jr nz,+
    ;end of the color array, loop
    ld hl,LandingColorLoop    
  +:
    ld a,12 ;change color 12
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output colour data
    ld a,(hl)
    out ($be),a
    
    inc hl
    inc b
    ld a,b
    cp 4
    jr nz,+
    ;end of the color array
    ld hl,LandingColorLoop    
  +:
    ld a,13 ;change color 13
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output colour data
    ld a,(hl)
    out ($be),a    

    inc hl
    inc b
    ld a,b
    cp 4
    jr nz,+
    ;end of the color array
    ld hl,LandingColorLoop    
  +:
    ld a,14 ;change color 14
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,$c0
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ; 2. Output colour data
    ld a,(hl)
    out ($be),a   
    
  UpdatePalette_end:
   pop hl
   pop bc
   pop af    
   ret 


;check if speed is too big, write a warning
drawWarning:
    push af
    push bc
    push hl


    ;in x:
    ld hl,(speedX)
    ;test if speed >0
    ld a,h
    cp $80
    jr c,drawWarning_hz_pos
    
    ;here speedX<0
    cp 255
    jr z,+
    jp drawWarning_right
  +: ;has to test tolerance
    ;test if l>speed_neg_tolerance
    ld bc,(speed_neg_tolerance)
    ld a,l
    cp c
    jr c,drawWarning_right
    jp drawWarning_test_Y
  
  drawWarning_hz_pos:
    ;here speedX>0
    ld a,h
    cp 0
    jr z,+
    jp drawWarning_left
  +: ;has to test tolerance
    ;test if l<speed_pos_tolerance
    ld bc,(speed_pos_tolerance)
    ld a,l
    cp c
    jr nc,drawWarning_left
    jp drawWarning_test_Y
    
  drawWarning_left:
    ;draw bubble left
    ld bc,(posX)
    ld a,b
    add a,10
    ld h,a;col (pix) in h
    ld bc,(posY)
    ld a,b
    add a,-12
    ld l,a;line (pix) in l
    ld d,bubble_right_tile_number
    call SpriteSet16x8
    ;draw bubble bottom
    ld bc,(posX)
    ld a,b
    add a,10
    ld h,a;col (pix) in h
    ld bc,(posY)
    ld a,b
    add a,-4
    ld l,a;line (pix) in l
    ld d,bubble_bottom_tile_number
    call SpriteSet16x8
    jp drawWarning_test_Y
  drawWarning_right:
    ;draw bubble left
    ld bc,(posX)
    ld a,b
    add a,10
    ld h,a;col (pix) in h
    ld bc,(posY)
    ld a,b
    add a,-12
    ld l,a;line (pix) in l
    ld d,bubble_left_tile_number
    call SpriteSet16x8
    ;draw bubble bottom
    ld bc,(posX)
    ld a,b
    add a,10
    ld h,a;col (pix) in h
    ld bc,(posY)
    ld a,b
    add a,-4
    ld l,a;line (pix) in l
    ld d,bubble_bottom_tile_number
    call SpriteSet16x8
    
  drawWarning_test_Y:
    ;Test in y:
    ld hl,(speedY)
    ;test if speed positive (h<$80)
    ld a,h
    cp $80
    jr nc,drawWarning_end
    
    ;test if h==0
    cp 0
    jr nz,drawWarning_down
    ;then test if l<speed_pos_tolerance
    ld bc,(speed_pos_tolerance)
    ld a,l
    cp c
    jr nc,drawWarning_down
    jr drawWarning_end
    
    drawWarning_down:
      ;draw bubble top 
      ld bc,(posX)
      ld a,b
      add a,14
      ld h,a;col (pix) in h
      ld bc,(posY)
      ld a,b
      add a,-4
      ld l,a;line (pix) in l
      ld d,bubble_down_tile_number
      call SpriteSet16x8
    
    drawWarning_bubble_bottom:
      ;draw bubble bottom
      ld bc,(posX)
      ld a,b
      add a,14
      ld h,a;col (pix) in h
      ld bc,(posY)
      ld a,b
      add a,4
      ld l,a;line (pix) in l
      ld d,bubble_bottom_tile_number
      call SpriteSet16x8
    
    drawWarning_end:
    pop hl
    pop bc
    pop af
    ret




