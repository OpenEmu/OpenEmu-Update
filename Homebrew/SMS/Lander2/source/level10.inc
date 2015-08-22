.section "level10" force

Level10Message:
 .db "LAND ON RIGHT-SIDE ZONE",0
Level11Message:
 .db "EXPLORE THE CRATER!",0

Level12Message:
 .db "     E A R T H Q U A K E ! ! !   ",0
Level12Message2:
 .db "     WAIT, THIS IS NOT EARTH.    ",0
Level12Message3:
 .db "             LAVA?!?!            ",0
Level12Message4:
 .db "            GET OUT!!!!          ",0

SetupLevel10:
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
    ld hl,Palette10Start
    ld b,(Palette10End-Palette10Start)
    ld c,$be
    otir
    
    
    ld hl,(tiles_vram_used)
    ;==============================================================
    ; Load level tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with (tiles_vram_used)
    ld a,l
    out ($bf),a
    ld a,h
    add a,$40
    out ($bf),a
    ; 2. Output tile data
    ld bc,Tiles_bg10_End-Tiles_bg10_Start  ; Counter for number of bytes to write
    ld hl,Tiles_bg10_Start              ; Location of tile data
    
    -:
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-
    ld hl,(tiles_vram_used)
    ld bc,Tiles_bg10_End-Tiles_bg10_Start
    add hl,bc
    ld (tiles_vram_used),hl

    ;load tilemap of current level
    ld hl,Tilemap10Start
    ;hl is where the tilemap of the level starts
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
    ld bc,$600+$40; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-
    
    ;init music
    ld hl,00;end_music_ch1_start
    call InitMusic1
    ld hl,end_music_ch2_start
    call InitMusic2
    ld hl,00;end_music_ch3_start
    call InitMusic3
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$8000
    ld (posX),hl
    ld hl,$0800
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    ;initialize scroll variables
    ld hl,Tilemap10Start
    ld (LevelMapStart),hl
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    ;compute max y scroll value (here scroll not allowed)
    ;ld hl,((Tilemap10End-Tilemap10Start)/64-24)*8
    ld hl,0
    ld (XScrollTotalMax),hl
    ld (YScrollTotalMax),hl
    
    

    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ;ld hl,WaitForVBlankLava
    ld (WaitForVBlankFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoWon
    ld (OnLandLeftFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ld hl,32
    ld (LevelMapWidth),hl
    
    
    ;show level message
    ld de,Level10Message;text pointer in de
    ld c,3;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
    
    ld a,1
    ld (first_frame_on_end_status),a
ret


SetupLevel11:
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
    ld hl,Palette10Start
    ld b,(Palette10End-Palette10Start)
    ld c,$be
    otir
    
    
    ld hl,(tiles_vram_used)
    ;==============================================================
    ; Load level tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with (tiles_vram_used)
    ld a,l
    out ($bf),a
    ld a,h
    add a,$40
    out ($bf),a
    ; 2. Output tile data
    ld bc,Tiles_bg10_End-Tiles_bg10_Start  ; Counter for number of bytes to write
    ld hl,Tiles_bg10_Start              ; Location of tile data
    
    -:
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-
    ld hl,(tiles_vram_used)
    ld bc,Tiles_bg10_End-Tiles_bg10_Start
    add hl,bc
    ld (tiles_vram_used),hl

    ;load tilemap of current level
    ld hl,Tilemap10Start
    ;hl is where the tilemap of the level starts
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
    ld bc,$600+$40; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-
    
    ;init music
    ld hl,00;end_music_ch1_start
    call InitMusic1
    ld hl,end_music_ch2_start
    call InitMusic2
    ld hl,00;end_music_ch3_start
    call InitMusic3
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$D800
    ld (posX),hl
    ld hl,$6700
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    ;initialize scroll variables
    ld hl,Tilemap10Start
    ld (LevelMapStart),hl
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    ;compute max y scroll value
    ld hl,((Tilemap10End-Tilemap10Start)/64-24)*8
    ld (YScrollTotalMax),hl
    ld hl,0
    ld (XScrollTotalMax),hl
    
    ld de,16
    call SetVScrollTo

    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ;ld hl,WaitForVBlankLava
    ld (WaitForVBlankFunction),hl
    ld hl,DoWon
    ld (OnLandRightFunction),hl
    ld hl,DoWait
    ld (OnLandLeftFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ld hl,32
    ld (LevelMapWidth),hl
    
    ;show level message
    ld de,Level11Message;text pointer in de
    ld c,5;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
    
    ld a,1
    ld (first_frame_on_end_status),a
ret

;start at bottom, has to leave the screen (TODO: disable upper scroll limit and enable any scroll init)
SetupLevel12:
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
    ld hl,Palette10Start
    ld b,(Palette10End-Palette10Start)
    ld c,$be
    otir
    
    
    ld hl,(tiles_vram_used)
    ;==============================================================
    ; Load level tiles
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with (tiles_vram_used)
    ld a,l
    out ($bf),a
    ld a,h
    add a,$40
    out ($bf),a
    ; 2. Output tile data
    ld bc,Tiles_bg10_End-Tiles_bg10_Start  ; Counter for number of bytes to write
    ld hl,Tiles_bg10_Start              ; Location of tile data
    
    -:
        ld a,(hl)        ; Get data byte
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec bc
        ld a,b
        or c
        jp nz,-
    ld hl,(tiles_vram_used)
    ld bc,Tiles_bg10_End-Tiles_bg10_Start
    add hl,bc
    ld (tiles_vram_used),hl

    ;load tilemap of current level
    ld hl,Tilemap10Start
    ;hl is where the tilemap of the level starts
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
    ld bc,$600+$40; Counter for number of bytes to write
    -:
        ld a,(hl)    ; Get data byte
        out ($be),a
        inc hl       ; Point to next tile
        dec bc
        ld a,b
        or c
        jr nz,-
    
    ;init music
    ld hl,lava_music_ch1_start
    call InitMusic1
    ld hl,lava_music_ch2_start
    call InitMusic2
    ld hl,lava_music_ch3_start
    call InitMusic3

    ;initialize scroll variables
    ld hl,Tilemap10Start
    ld (LevelMapStart),hl
    
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    ;compute max y scroll value
    ld hl,((Tilemap10End-Tilemap10Start)/64-24)*8+8
    ld (YScrollTotalMax),hl
    ld hl,0
    ld (XScrollTotalMax),hl
    
    ld de,408+8+8
    call SetVScrollTo
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$7B00
    ld (posX),hl
    ld hl,$8F00-$1000
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    
    ld hl,600
    ld (YLava),hl
    xor a
    ld (YLava_decimal),a
    ld a,08
    ld (YLava_speed),a

    ;functers
    ld hl,DoStartLava
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankLava
    ld (WaitForVBlankFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoWait
    ld (OnLandLeftFunction),hl
    ld hl,DoWon
    ld (OnOutFunction),hl
    
    ld hl,32
    ld (LevelMapWidth),hl
    
    ld a,1
    ld (first_frame_on_end_status),a
ret

WaitForVBlankLava:
    push af
    push bc
    
      ;compute lava y in screen
      ld hl,(YLava)
      ld bc,(YScrollTotal)
      ;want (YLava)-(YScrollTotal)
      or a ; reset carry flag (see http://www.smspower.org/Development/Z80ProgrammingTechniques#SubHlde)
      sbc hl,bc
      ;ld a,b
      ;neg
      ;ld b,a
      ;ld a,c
      ;neg
      ;ld c,a
      ;add hl,bc ;hl=(YLava)-(YScrollTotal)      
      
      ld a,h;test if hl in screen (<256)
      cp 0
      jr nz,WaitForVBlankLava_startlevel_out

      ;test if lava is on screen (hl<224)
      ld a,l
      cp 224
      jr c,WaitForVBlankLava_startlevel_ok
      
    WaitForVBlankLava_startlevel_out:
        ld b,$F0 ;out of screen
        ld d,$F0 ;out of screen
        ld e,$F0 ;out of screen
        call WaitForVBlankSimple
        jp WaitForVBlankLava_end
    WaitForVBlankLava_startlevel_ok:
      
      ;check if rocket is in contact with lava
      ld bc,(posY)
      ld a,b
      add a,$4 ;bottom of the rocket
      cp l
      jr c,+
        ld a,2
        ld (rocket_status),a
        ld a,2 ;lost
        ld (gameStatus),a
    +:
      
      ;put the 3 lava lines in screen in b,d,e 
      ld b,l
      ld a,b
      add a,$10
      jr nc,+
      ld d,$F0 ;out of screen
      ld e,$F0 ;out of screen
      jp WaitForVBlankLava_end_levels
    +:
      ld d,a
      add a,$2
      jr nc,+
      ld e,$F0 ;out of screen
    +:
      ld e,a
      

      
    WaitForVBlankLava_end_levels:
    -:
      ;check for lava level:
      ;read scan line counter
      in a,($7E)
      ld c,a
      cp b;if == b, change palette
      jr nz,+
      ;==============================================================
      ; Update palette
      ;==============================================================
      ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
      ; by outputting $c000 ORed with $0002 (number of the color to change)
      ld a,$02
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$20
      out ($be),a
      jr -
    +:
      ld a,c ;get line counter back
      cp d
      jr nz,+
      ;==============================================================
      ; Update palette
      ;==============================================================
      ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
      ; by outputting $c000 ORed with $0002 (number of the color to change)
      ld a,$02
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$03
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 8
      ld a,$08
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$03
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 9
      ld a,$09
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$03
      out ($be),a
      jr -
    +:    
      ld a,c ;get line counter back
      cp e
      jr nz,+
      ;==============================================================
      ; Update palette
      ;==============================================================
      ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
      ; by outputting $c000 ORed with $0002 (number of the color to change)
      ld a,$02
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$01
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 8
      ld a,$08
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$01
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 9
      ld a,$09
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$01
      out ($be),a
      jp -
    +:    
      ;check if end of frame
      ld a,(new_frame)
      cp 0
      jp z,-

      xor a
      ld (new_frame),a
      
      
      ;get back to original color...
      ;==============================================================
      ; Update palette
      ;==============================================================
      ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
      ; by outputting $c000 ORed with $0002 (number of the color to change)
      ld a,$02
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$10
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 8
      ld a,$08
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$3a
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ;change color 9
      ld a,$09
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$c0
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,%00000101
      out ($be),a
      
  WaitForVBlankLava_end:
    pop bc
    pop af
  
  ret


;-------------------------------------------------------------------------------
DoStartLava:
    ld hl,(gameStatusCnt)
    ld bc,$6 ;increment gameStatusCnt
    add hl,bc
    ld (gameStatusCnt),hl

    
    ;screen shaking
    ld a,l
    srl a
    srl a
    srl a
    and %00000011
    sub 2
    ;VDP hz scrolling
    out ($bf),a
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    .db 0,0 ;double nop
    ld a,%10001000
    out ($bf),a
    
    
    
    ;show 3,2,1,GO!
    ld hl,(gameStatusCnt)
    ld a,h
    cp 0
    jr nz,+
      ;show level message
      ld de,Level12Message;text pointer in de
      ld c,1;col (tiles) in c
      ld l,20;line (tiles) in l
      ld a,1;have to write slowly
      call PrintText
      
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 1
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 19;n in d
      call SpriteSet8x8
      ;show level message
      ld de,Level12Message2;text pointer in de
      ld c,1;col (tiles) in c
      ld l,20;line (tiles) in l
      ld a,1;have to write slowly
      call PrintText
      
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 2
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 18;n in d
      call SpriteSet8x8
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 3
    jr nz,+
      ld h,$80;x in h
      ld l,$50;y in l
      ld d, 17;n in d
      call SpriteSet8x8
      ;show level message
      ld de,Level12Message3;text pointer in de
      ld c,1;col (tiles) in c
      ld l,20;line (tiles) in l
      ld a,1;have to write slowly
      call PrintText
  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 4
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
      ;show level message
      ld de,Level12Message4;text pointer in de
      ld c,1;col (tiles) in c
      ld l,20;line (tiles) in l
      ld a,1;have to write slowly
      call PrintText

  +:
    ld hl,(gameStatusCnt)
    ld a,h
    cp 5
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

;==============================================================
; Data
;==============================================================

;lava_music_ch3_start:
;  .db $01,$94,$08,$07 $01,$ac,$0a,$07, $01,$94,$08,$07, $01,$7d,$0a,$07, $01,$68,$08,$07, $01,$53,$0a,$07, $01,$68,$08,$07, $01,$7d,$0a,$07
;  .db $ff,$ff
;lava_music_ch2_start:
;  .db $01,$7d,$0a,$07, $01,$94,$08,$07, $01,$ac,$0a,$07, $01,$94,$08,$07, $01,$7d,$0a,$07, $01,$68,$08,$07, $01,$53,$0a,$07, $01,$68,$08,$07
;  .db $ff,$ff
;lava_music_ch1_start:
;  .db $01,$ac,$0a,$07, $01,$94,$08,$07, $01,$7d,$0a,$07, $01,$68,$08,$07, $01,$53,$0a,$07, $01,$68,$08,$07, $01,$7d,$0a,$07, $01,$94,$08,$07
;  .db $ff,$ff
;  ;total 72.0 frames
;lava_music_ch1_end:

lava_music_ch3_start:
  .db $00,$00,$08,$07
lava_music_ch2_start:
  .db $00,$00,$08,$07
lava_music_ch1_start:
  .db $01,$ac,$0a,$07, $01,$94,$08,$07, $01,$7d,$0a,$07, $01,$68,$08,$07, $01,$53,$0a,$07, $01,$68,$08,$07, $01,$7d,$0a,$07, $01,$94,$08,$07
  .db $ff,$ff
  ;total 72.0 frames
lava_music_ch1_end:

Level10Start:

Tiles_bg10_Start:
.db $fe,$01,$00,$ff,$f9,$07,$01,$fe,$f7,$0f,$07,$f8,$cf,$3f,$0f,$f0,$bf,$7f,$3e,$c0,$bf,$7f,$3f,$c0,$7f,$ff,$7f,$80,$7f,$ff,$7e,$80
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$fe,$01,$00,$ff,$fd,$02,$01,$fe,$fb,$04,$03,$fc,$e6,$1a,$06,$f9,$98,$60,$18,$e7,$33,$93,$33,$8c
.db $fc,$03,$00,$ff,$e3,$1c,$03,$fc,$1f,$e0,$1f,$e0,$f9,$09,$f9,$06,$88,$80,$88,$77,$2d,$2d,$2d,$d2,$7f,$7f,$7f,$80,$ff,$ff,$ff,$00
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$f8,$07,$00,$ff,$e5,$1d,$05,$f8,$dd,$3d,$1d,$e0,$3d,$fd,$3c,$c0
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$fe,$01,$00,$ff,$fd,$02,$01,$fe,$73,$8f,$03,$fc,$89,$f9,$89,$76,$c3,$c3,$c3,$3c,$8f,$8f,$8f,$70
.db $e0,$1f,$00,$ff,$07,$e7,$07,$f8,$6f,$6f,$6f,$10,$77,$77,$77,$08,$bf,$bf,$bf,$00,$bf,$bf,$8f,$00,$cf,$df,$c7,$00,$c7,$df,$c3,$00
.db $ef,$1f,$0f,$f0,$ef,$1f,$0f,$f0,$df,$3f,$1f,$e0,$bf,$7f,$3f,$c0,$bf,$7f,$38,$c0,$bf,$7f,$3e,$c0,$7f,$ff,$7f,$80,$7f,$ff,$7f,$80
.db $fe,$01,$00,$ff,$fe,$01,$00,$ff,$fc,$03,$00,$fe,$fc,$03,$00,$fe,$fc,$02,$00,$fe,$f9,$04,$01,$fc,$f1,$0c,$01,$f8,$f1,$0c,$01,$f8
.db $bf,$bf,$3f,$40,$ff,$ff,$7f,$00,$7f,$ff,$7f,$00,$7f,$ff,$7f,$00,$7f,$7f,$7f,$00,$ff,$7f,$df,$00,$ff,$7f,$e6,$00,$fe,$ff,$f0,$00
.db $c3,$2f,$00,$e0,$d0,$37,$10,$e0,$d8,$39,$18,$e0,$bc,$7c,$38,$c0,$b8,$7c,$30,$c0,$b1,$78,$01,$c0,$42,$f0,$02,$81,$22,$e2,$02,$81
.db $fb,$07,$00,$fc,$f3,$0f,$00,$f8,$f0,$0f,$00,$f8,$e0,$17,$00,$f0,$e8,$10,$08,$f0,$eb,$18,$0b,$f0,$db,$39,$1b,$e0,$d6,$32,$06,$e1
.db $fe,$01,$00,$ff,$fe,$01,$00,$ff,$fc,$02,$00,$ff,$fc,$02,$00,$ff,$fc,$02,$00,$ff,$fb,$07,$03,$fc,$f7,$0f,$07,$f8,$f7,$0f,$03,$f8
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$e0,$1f,$00,$ff,$d0,$31,$10,$e0,$3c,$fc,$3c,$c0
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$f8,$07,$00,$ff,$f0,$08,$00,$f8,$0e,$f0,$0e,$f1,$10,$80,$10,$0f,$47,$07,$47,$38
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$f0,$0f,$00,$ff,$0b,$fb,$03,$f4,$e7,$0f,$e1,$00,$71,$77,$70,$80,$f8,$f9,$f8,$00,$fc,$fc,$fc,$00
.db $f0,$0f,$00,$ff,$88,$7b,$08,$f0,$7c,$fd,$7c,$80,$fe,$fe,$cc,$00,$fc,$fe,$e0,$00,$f1,$fc,$01,$00,$01,$f0,$01,$00,$02,$e2,$02,$01
.db $83,$83,$83,$7c,$3f,$3f,$bf,$40,$7f,$7f,$ff,$00,$ff,$ff,$67,$00,$7f,$ff,$f6,$00,$fe,$fe,$f0,$00,$f0,$f8,$c0,$00,$63,$79,$43,$80
.db $9f,$bf,$80,$00,$c0,$cf,$c0,$00,$c0,$c0,$c0,$00,$8f,$80,$8f,$00,$38,$00,$38,$07,$67,$03,$67,$18,$cf,$0f,$cf,$30,$9f,$1f,$9f,$60
.db $e0,$f8,$00,$00,$03,$e0,$03,$00,$07,$03,$07,$00,$c7,$c7,$c7,$00,$e3,$e7,$e1,$00,$e1,$e3,$e0,$00,$f0,$f1,$e0,$00,$e0,$e0,$c0,$00
.db $00,$7f,$00,$80,$00,$1f,$00,$e0,$00,$cf,$00,$30,$00,$e7,$00,$18,$00,$fb,$00,$04,$00,$fd,$00,$02,$00,$fc,$00,$03,$00,$fe,$00,$01
.db $00,$3f,$00,$c0,$00,$87,$00,$78,$00,$f3,$00,$0c,$00,$f9,$00,$06,$00,$fc,$00,$03,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00
.db $00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$7f,$00,$80,$00,$07,$00,$f8,$00,$f1,$00,$0e,$00,$fc,$00,$03
.db $c0,$e1,$80,$01,$89,$c7,$09,$06,$13,$89,$13,$0c,$07,$37,$07,$38,$2f,$4f,$2e,$50,$ae,$4f,$ac,$50,$7c,$fe,$78,$80,$78,$fc,$70,$80
.db $1f,$7f,$01,$00,$03,$1f,$00,$00,$80,$87,$00,$01,$b0,$83,$30,$02,$38,$04,$38,$04,$67,$18,$67,$18,$07,$64,$07,$78,$4f,$cd,$4f,$b0
.db $98,$9b,$98,$63,$a0,$bc,$20,$5c,$1c,$fc,$1c,$e0,$7c,$fc,$7c,$00,$79,$78,$79,$00,$fb,$78,$eb,$00,$fa,$78,$e2,$01,$f2,$f2,$c2,$01
.db $07,$e0,$07,$00,$07,$87,$01,$00,$03,$07,$00,$00,$f0,$13,$f0,$00,$98,$9f,$98,$67,$24,$3d,$24,$d8,$5c,$7c,$5c,$a0,$3e,$fe,$2e,$c0
.db $f1,$f8,$c1,$00,$e1,$f9,$81,$00,$c0,$e1,$00,$01,$00,$e2,$00,$02,$00,$cc,$00,$8c,$0e,$7a,$0e,$70,$71,$01,$71,$0e,$65,$25,$65,$1a
.db $c0,$df,$c0,$3f,$1f,$ff,$1f,$e0,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$7f,$ff,$3e,$00,$3f,$7f,$0c,$00,$0f,$3f,$01,$00,$83,$bf,$81,$00
.db $66,$72,$06,$91,$87,$f3,$87,$10,$87,$e7,$83,$20,$83,$c7,$80,$40,$80,$cf,$80,$40,$a0,$c7,$a0,$40,$70,$f1,$70,$80,$7c,$fc,$7c,$80
.db $fe,$ff,$f6,$01,$fe,$ff,$f6,$01,$fc,$ff,$e0,$02,$e8,$fe,$80,$02,$80,$fe,$00,$02,$01,$c4,$01,$04,$14,$88,$14,$0b,$63,$6b,$03,$1c
.db $55,$99,$ee,$ff,$55,$99,$ee,$ff,$7f,$7f,$3f,$00,$3f,$7f,$07,$00,$07,$3f,$01,$00,$81,$07,$80,$00,$70,$11,$70,$80,$fc,$fc,$e0,$00
.db $3f,$c0,$00,$ff,$8f,$f0,$80,$7f,$e6,$f9,$e0,$1f,$f8,$fe,$f8,$06,$f8,$fe,$f0,$04,$e1,$fc,$01,$18,$01,$f0,$01,$60,$0e,$e6,$0e,$81
.db $7f,$00,$00,$ff,$1f,$00,$00,$ff,$0f,$c0,$00,$3f,$07,$e0,$00,$1f,$03,$f8,$00,$07,$01,$fc,$00,$03,$00,$fc,$00,$03,$00,$fe,$00,$01
.db $3f,$00,$00,$ff,$07,$80,$00,$7f,$03,$f0,$00,$0f,$01,$f8,$00,$07,$00,$fc,$00,$03,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$7f,$00,$00,$ff,$07,$00,$00,$ff,$01,$f0,$00,$0f,$00,$fc,$00,$03
.db $3f,$00,$00,$ff,$0f,$80,$00,$7f,$06,$e1,$00,$1f,$01,$fb,$01,$06,$01,$fd,$01,$06,$03,$fb,$03,$18,$1b,$fb,$1b,$60,$7b,$fb,$79,$80
.db $00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00
.db $3f,$00,$00,$ff,$07,$80,$00,$7f,$03,$f0,$00,$0f,$01,$f8,$00,$07,$00,$fc,$00,$03,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00
.db $fc,$00,$00,$ff,$f0,$03,$00,$fc,$80,$0f,$00,$f0,$00,$3f,$00,$c0,$00,$7f,$00,$80,$00,$07,$00,$f8,$00,$f1,$00,$0e,$00,$fc,$00,$03
.db $00,$ff,$00,$01,$01,$ff,$00,$06,$00,$fb,$00,$08,$00,$fb,$00,$30,$30,$f8,$20,$40,$33,$f8,$03,$40,$73,$f8,$03,$80,$63,$f9,$03,$80
.db $00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$01,$01,$ff,$01,$02,$03,$ff,$03,$04,$07,$ff,$07,$18,$1f,$ff,$0c,$60,$7c,$ff,$60,$80
.db $00,$ff,$00,$03,$01,$ff,$00,$1c,$10,$f3,$10,$e0,$f8,$f8,$f0,$00,$f1,$f8,$e1,$00,$e2,$f0,$82,$01,$84,$e0,$04,$03,$45,$c5,$05,$02
.db $00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$07,$06,$f8,$06,$18,$16,$f2,$16,$21,$2c,$e4,$0c,$c3
.db $00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$01,$00,$fe,$00,$03,$01,$fd,$01,$8e,$0f,$7f,$0f,$70,$9f,$1f,$8f,$00,$cf,$df,$c7,$00
.db $00,$ff,$00,$1f,$01,$f8,$01,$e0,$06,$e0,$06,$01,$11,$81,$11,$0e,$1f,$1f,$03,$00,$c3,$0f,$c0,$00,$e0,$e3,$e0,$00,$f8,$f8,$f8,$00
.db $0b,$fb,$0a,$14,$0e,$ff,$04,$10,$04,$ef,$00,$20,$20,$ee,$00,$40,$01,$e0,$01,$40,$1c,$c0,$1c,$43,$21,$81,$21,$9e,$0f,$8f,$0f,$f0
.db $00,$ff,$00,$01,$00,$ff,$00,$01,$01,$ff,$01,$02,$01,$ff,$01,$02,$01,$ff,$01,$02,$03,$ff,$00,$04,$00,$fb,$00,$08,$00,$f9,$00,$08
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $07,$87,$07,$f8,$7f,$ff,$7f,$80,$7f,$ff,$7f,$80,$bf,$7f,$0f,$c0,$be,$7e,$2c,$c0,$bc,$7c,$20,$c0,$61,$f0,$01,$80,$47,$f2,$07,$80
.db $3f,$ff,$00,$80,$00,$9f,$00,$80,$00,$80,$00,$80,$9f,$41,$1f,$c0,$c1,$31,$01,$fe,$e7,$1f,$07,$f8,$fb,$07,$03,$fc,$fc,$03,$00,$ff
.db $40,$f0,$00,$80,$87,$40,$07,$c0,$cf,$27,$0f,$e0,$e6,$1e,$06,$f9,$f9,$07,$01,$fe,$fe,$01,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $38,$18,$38,$07,$f1,$31,$f1,$0e,$c7,$c7,$c7,$38,$1f,$1f,$1f,$e0,$bf,$bf,$bf,$40,$7f,$ff,$7f,$80,$81,$7f,$01,$fe,$fe,$01,$00,$ff
.db $0c,$e0,$0c,$83,$09,$e9,$09,$86,$0d,$cd,$0d,$82,$1f,$df,$1f,$40,$0f,$cf,$03,$40,$07,$cf,$01,$40,$21,$a7,$20,$c0,$30,$b7,$30,$c0
.db $7f,$ff,$7f,$80,$7f,$ff,$7a,$80,$7e,$ff,$78,$80,$38,$fe,$30,$40,$00,$fc,$00,$30,$01,$f8,$01,$18,$02,$fc,$02,$05,$00,$ff,$00,$03
.db $00,$c0,$00,$80,$1e,$c6,$1e,$40,$07,$e3,$06,$38,$07,$ff,$06,$18,$00,$fe,$00,$06,$00,$ff,$00,$01,$00,$ff,$00,$00,$00,$ff,$00,$00
.db $3f,$ff,$03,$00,$07,$3f,$00,$00,$01,$0f,$00,$00,$60,$07,$60,$00,$70,$00,$70,$00,$7f,$a0,$7f,$80,$01,$fe,$01,$7e,$00,$ff,$00,$01
.db $30,$33,$30,$c0,$78,$79,$78,$80,$f8,$f8,$f8,$00,$f9,$f8,$f9,$00,$f3,$f1,$f3,$00,$f6,$f0,$d6,$01,$e0,$fc,$c0,$1f,$1c,$e3,$00,$ff
.db $0f,$c1,$0f,$00,$0f,$0f,$03,$00,$07,$0f,$00,$00,$e0,$27,$e0,$00,$30,$33,$30,$c0,$78,$7a,$78,$80,$e0,$fc,$e0,$1c,$00,$ff,$00,$e3
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$10,$10,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ef,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff,$ff,$00,$00,$ff
.db $07,$07,$07,$f8,$7f,$7f,$7f,$80,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$fc,$00,$ff,$ff,$fe,$00,$ff,$ff,$fe,$00,$fe,$ff,$fc,$00
.db $3f,$7f,$00,$00,$80,$9f,$80,$00,$c0,$c0,$c0,$00,$e7,$e0,$e7,$00,$cf,$c1,$8f,$00,$9c,$84,$1c,$03,$30,$80,$30,$0f,$67,$27,$67,$18
.db $c0,$f0,$00,$00,$07,$c0,$07,$00,$3f,$01,$3f,$00,$f3,$13,$f3,$0c,$10,$00,$10,$ef,$5b,$5b,$5b,$a4,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00
.db $0c,$0c,$0c,$03,$c8,$08,$c8,$07,$e8,$c8,$e8,$07,$f5,$f5,$f5,$02,$35,$35,$35,$c2,$bb,$bb,$bb,$40,$fb,$fb,$fb,$00,$fb,$fb,$f9,$00
.db $fc,$fe,$e0,$00,$e8,$fc,$00,$00,$80,$fc,$00,$00,$06,$e0,$06,$00,$1f,$07,$1f,$00,$f3,$13,$f3,$0c,$87,$87,$87,$78,$1f,$1f,$1f,$e0
.db $6f,$2f,$6f,$10,$cf,$8f,$cf,$30,$df,$df,$df,$20,$ef,$ef,$ef,$10,$7f,$7f,$7f,$00,$7f,$7f,$1f,$00,$9f,$bf,$8f,$00,$8f,$bf,$87,$00
.db $ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$f1,$00,$ff,$ff,$fc,$00,$ff,$ff,$fe,$00,$ff,$ff,$fe,$00
.db $fb,$fb,$f0,$00,$f9,$fb,$f0,$00,$f8,$fb,$f0,$00,$f0,$fb,$e0,$00,$f0,$f8,$e0,$00,$f3,$f8,$c3,$00,$f3,$f8,$03,$00,$e3,$f9,$03,$00
.db $7f,$7f,$7f,$80,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$bf,$00,$ff,$ff,$cc,$00,$fc,$ff,$e0,$00
.db $c7,$df,$c0,$00,$e1,$ef,$e0,$00,$f0,$f3,$f0,$00,$f8,$f8,$f0,$00,$f1,$f8,$e1,$00,$e2,$f0,$82,$01,$84,$e0,$04,$03,$45,$c5,$05,$02
.db $ff,$ff,$00,$00,$26,$ff,$00,$00,$00,$ff,$00,$00,$00,$0f,$00,$00,$f0,$21,$f0,$00,$36,$30,$36,$c0,$76,$72,$76,$81,$ec,$e4,$cc,$03
.db $86,$f2,$06,$01,$46,$f6,$06,$01,$4c,$ec,$0c,$03,$0c,$ec,$0c,$03,$1d,$dd,$1d,$02,$1f,$1f,$1f,$00,$9f,$1f,$8f,$00,$cf,$df,$c7,$00
.db $f8,$fe,$00,$00,$21,$f8,$01,$00,$06,$e0,$06,$01,$11,$81,$11,$0e,$1f,$1f,$03,$00,$c3,$0f,$c0,$00,$e0,$e3,$e0,$00,$f8,$f8,$f8,$00
.db $0b,$0b,$0a,$04,$ee,$0f,$e4,$00,$64,$6f,$60,$80,$e0,$ee,$c0,$00,$c1,$e0,$01,$00,$1c,$c0,$1c,$03,$21,$01,$21,$1e,$8f,$0f,$8f,$70
.db $d1,$c1,$11,$0e,$27,$a7,$27,$18,$2f,$2f,$2f,$10,$37,$37,$07,$08,$cf,$1f,$c3,$00,$e3,$ef,$e0,$00,$f0,$f3,$f0,$00,$f8,$f9,$f8,$00
.db $e7,$ef,$e0,$00,$f0,$f7,$f0,$00,$f8,$fb,$f8,$00,$fc,$fc,$98,$00,$f9,$fc,$c1,$00,$e3,$f9,$03,$00,$02,$e0,$02,$01,$04,$c4,$04,$03
.db $07,$07,$07,$f8,$7f,$7f,$7f,$80,$ff,$ff,$ff,$00,$ff,$ff,$cf,$00,$fe,$fe,$ec,$00,$fc,$fc,$e0,$00,$e1,$f0,$81,$00,$c7,$f2,$87,$00
.db $3f,$7f,$00,$00,$80,$9f,$80,$00,$80,$80,$80,$00,$1f,$01,$1f,$00,$71,$01,$71,$0e,$cf,$07,$cf,$30,$9f,$1f,$9f,$60,$3f,$3f,$3f,$c0
.db $c0,$f0,$00,$00,$07,$c0,$07,$00,$0f,$07,$0f,$00,$8e,$8e,$8e,$01,$c7,$cf,$c3,$00,$c3,$c7,$c1,$00,$e1,$e3,$c0,$00,$c0,$c1,$80,$00
.db $38,$18,$38,$07,$f1,$31,$f1,$0e,$c7,$c7,$c7,$38,$1f,$1f,$1f,$e0,$bf,$bf,$bf,$40,$ff,$ff,$ff,$00,$ff,$ff,$73,$00,$ff,$ff,$07,$00
.db $8c,$e0,$0c,$03,$89,$e9,$09,$06,$0d,$cd,$0d,$02,$1f,$df,$1f,$00,$0f,$0f,$03,$00,$c7,$0f,$c1,$00,$a1,$a7,$a0,$40,$30,$37,$30,$c0
.db $ff,$ff,$ff,$00,$ff,$ff,$fa,$00,$fe,$ff,$f8,$00,$f8,$fe,$f0,$00,$f0,$fc,$e0,$00,$e1,$f8,$81,$00,$c2,$f0,$02,$01,$04,$e0,$04,$03
.db $80,$c0,$00,$00,$1e,$86,$1e,$00,$27,$03,$26,$18,$6f,$2f,$6e,$10,$de,$1e,$dc,$20,$5c,$1e,$58,$a0,$f8,$fc,$f0,$00,$f1,$f8,$e1,$00
.db $3f,$ff,$03,$00,$07,$3f,$00,$00,$01,$0f,$00,$00,$60,$07,$60,$00,$70,$00,$70,$00,$ff,$20,$ff,$00,$cf,$48,$cf,$30,$9f,$9b,$9f,$60
.db $30,$33,$30,$c0,$78,$79,$78,$80,$f8,$f8,$f8,$00,$f9,$f8,$f9,$00,$f3,$f1,$f3,$00,$f6,$f0,$d6,$01,$f4,$f0,$c4,$03,$e5,$e5,$85,$02
.db $0f,$c1,$0f,$00,$0f,$0f,$03,$00,$07,$0f,$00,$00,$e0,$27,$e0,$00,$30,$33,$30,$c0,$78,$7a,$78,$80,$f8,$f8,$f8,$00,$fc,$fc,$dc,$00
.db $e3,$f1,$83,$00,$c3,$f3,$03,$00,$83,$c3,$03,$00,$01,$c1,$01,$00,$18,$81,$18,$00,$3c,$14,$3c,$00,$e2,$02,$e2,$1c,$cb,$4b,$cb,$34
.db $be,$be,$be,$41,$7f,$7f,$7f,$80,$ff,$ff,$ff,$00,$ff,$ff,$ff,$00,$ff,$ff,$7d,$00,$7f,$ff,$19,$00,$1f,$7f,$03,$00,$07,$7f,$03,$00
.db $cd,$e5,$0d,$02,$0f,$e7,$0f,$00,$0f,$cf,$07,$00,$07,$8f,$01,$00,$01,$1f,$00,$00,$c0,$0f,$c0,$00,$e0,$e3,$e0,$00,$f8,$f8,$f8,$00
.db $fe,$fe,$ee,$00,$fe,$fe,$ec,$00,$fc,$fe,$c0,$00,$d0,$fc,$00,$00,$00,$f8,$00,$00,$03,$80,$03,$00,$38,$00,$38,$07,$c7,$c7,$07,$38
.db $9f,$1f,$9f,$60,$df,$df,$df,$20,$ff,$ff,$7f,$00,$7f,$ff,$0f,$00,$0f,$7f,$03,$00,$03,$0f,$00,$00,$e0,$23,$e0,$00,$f8,$f9,$c0,$00
.db $03,$1f,$00,$00,$c0,$c7,$c0,$00,$f0,$f3,$f0,$00,$f8,$f8,$f8,$00,$f9,$fc,$e1,$00,$e3,$f9,$03,$00,$02,$e0,$02,$01,$1c,$cc,$1c,$03
Tiles_bg10_End:



Palette10Start:
;.db $3f,$00,$10,$15,$25,$06,$1a,$2a,$3a,%00000101,$05,$1b,$2b,$3f,$3e,$3c
;.db $3f,$00,$10,$15,$25,$06,$1a,$2a,$3a,%00000101,$05,$1b,$2b,$3f,$3e,$0f
.db $00,$3f,$10,$15,$25,$06,$1a,$2a,$3a,%00000101,$05,$1b,$2b,$3f,$3e,$0f
.db $00,$3f,$00,$20,$38,$01,$02,$03,$15,$2a,$1f,$2f,$3a,$36,$01,$0a
Palette10End:

Tilemap10Start:
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0010001010001100 %1000001010001011 %0000001010001010 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010001010 %0100000010001011 %0100000010001001

.dw %0010000011001000 %0010000011001001 %0010000011001010 %0000001010010010 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101010 %1000000010001001 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011001100 %0010000011001101 %0010000011001110 %1100001010010001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000001010100111 %0000000010110101 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011010000 %0010000011010001 %0010000011010010 %1100001010010000 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000001010100111 %0000000010101011 %1000000010110100 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110

.dw %0010000011010100 %0010000011010101 %0010000011010110 %0010001010111011 %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111
.dw %0000000010101011 %0000000010110101 %0010001010011111 %0010001010011110 %0010000011001010 %0010000011010000 %0010000011010001 %0010000011010010

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0000001010110101 %0000001010011010 %0000000010100111 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101011
.dw %0000000010101011 %1000000010110100 %0010000011010101 %0010000011010110 %0010001010100010 %0010001010100001 %0010001010100000 %0010000011010110

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101100
.dw %0000000010101101 %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1010000010111100 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010011010 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0010000010111011 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011100011 %0010000011100100 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110
.dw %0000001010101001 %0000001010101000 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010111 %0010000011011000 %0010000011011001 %1000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010101101 %0000001010101100
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010001010011111 %0010001010011110 %0010001010111110 %1010001010111101 %0000000010011100 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011001001 %0010000011001010

.dw %0010000011001111 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011001101 %0010000011001110

.dw %0010000011001111 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010110100 %0010000011010001 %0010000011010010

.dw %0010000011010011 %0010000011010100 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011010101 %0010000011010110

.dw %0010000011010111 %0010000011011000 %1100001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010110001 %1110001010100101 %1110001010100101 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110001
.dw %0100000010110010 %0010000010110011 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %1100001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101111 %0010000010110000 %0010000011010010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010001010110000 %1000001010101111 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011000000
.dw %0010000011010100 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1010000010111101 %0010000010111110 %0010000011000000 %0010000011000000 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011010100 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011100011 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010110001 %1000000010110010 %0010000010110011 %0010001010110000 %1000001010101111 %1000000010101111 %0010000010110000 %0000001010110101
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011100110 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010001010110000 %1000001010101111 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1010000010111100 %0010000011100101 %0010000011010110 %0010000010100000 %0010000010100001 %0010000010100010 %0010001010100001 %1000001010110100
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %1010001010111100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1000000010101110 %0010001010011111 %0010001010011110 %0010001010011101 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001
.dw %1000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %1010001010111100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110
.dw %0010000011010001 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101
.dw %0010000011100110 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101
.dw %0010000010111110 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001
.dw %0010000011001010 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011100 %0000001010011011 %0000000010011011 %0000000010011100 %1000000010110100 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1010000010111101 %0010000010111110 %0010000011011101 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %1000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011
.dw %0000000010011010 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010
.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010001010110011 %1000001010110010 %0000001010110001 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010011010 %0000000010101011 %1000000010110100 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011001100 %0010000011001101 %0010000011001110
.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000010100000 %0010000010100001 %0010000010100010 %0010001010110000 %1000001010101111
.dw %0000000010101011 %0000000010101011 %0000000010110101 %0010001010011111 %0010001010011110 %0010000011100001 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011010110 %0010000011010010
.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010
.dw %0010001010110011 %1000001010110010 %1000000010110100 %0010000011010001 %0010000011010001 %0010001010011111 %0010001010011110 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011010101 %0010000010100100
.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110
.dw %0010000011100011 %0010000010011101 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011000111 %0010001010110011 %1000001010110010 %0000001010110001
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000010100011
.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000010100000 %0010000010100001
.dw %0010000010100010 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011001011 %0010000011001001 %0010001010111110 %1010001010111101
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110001 %0100000010110010 %0010000010110011 %0010000011011110
.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110
.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000010100000 %0010000010100001 %0010000010100010 %0010001010110000 %1000001010101111 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %1010000010111101 %0010000010111110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %1000001010101110 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011010 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1010000010111101 %0010000010111110 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010
.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %1010001010111100 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011010 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %1010000010111100 %0010000011011110 %0010000011001011 %0010000011010101 %0010000011001101 %0010000011001110
.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0000000010011010 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011100101 %0010000011100110 %0010000011010010
.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011
.dw %0000000010011100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011010101
.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011010 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100
.dw %0010000011011000 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1010000010111100 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011001111 %0000001010110101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0010000010111011 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011010011 %1000001010110100 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0010000010111011 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010001010110011 %1000001010110010
.dw %0000001010110001 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1000000010101110 %0010001010011111 %0010001010011110 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110
.dw %0010000011001011 %0010001010110011 %1000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0100000010110001 %1000000010110010 %0010000010110011
.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010001010011101 %0010000011010110 %0010000010100100 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %1000001010110000 %0000001010101111 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011010001 %0010000011010010
.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010001010011101 %0010000010100011 %0010000011010001 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110
.dw %0010000011010011 %0010001011000000 %0010001011000000 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101111 %0010000010110000 %0010000011010100 %0010000011010101 %0010000011010110
.dw %0010000011100011 %0010000011100100 %0010000010100000 %0010000010100001 %0010000010100010 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011000111 %0010000011001000 %0010000011000000 %0010001010111110
.dw %1010001010111101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1000000010101111 %0010000010110000 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010
.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011001011 %1010001010111100 %0000000010011011 %0000000010011100
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0010000010111011 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110
.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011001111 %0000001010110101 %0000000010101011 %0000000010101011
.dw %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1010000010111100 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011010011 %1000001010110100 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0000001010110101 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011010100 %0010000011001001 %0010000011001010
.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %1000001010110100 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011001101 %0010000011001110
.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000010100000 %0010000010100001 %0010000010100010 %0010001010110011
.dw %1000001010110010 %0000001010110001 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011010001 %0010000011010010
.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011100011 %0010000011100100 %0010001010110011 %1000001010110010 %0000001010110001 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110
.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010
.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010001010110011 %1000001010110010 %0000001010110001
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1010000010111100 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110
.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000010011110 %0010000010011111
.dw %0010001010110011 %1000001010110010 %0000001010110001 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1010000010111100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000010011101 %0010000011011010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %1000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000010011101 %0010001010011101 %0010000011011110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010000011011011 %0100001010110000 %0000001010101111 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0010000010111011 %0010000011100100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010
.dw %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011010111 %0010000011011000 %0010001010011101 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011000000 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %1010000010111100 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110
.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110
.dw %0010001011000000 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000001010011010 %0000000010011010 %0000000010101011 %0000000010101011 %1010000010111100 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010
.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011011111 %0010000011100000 %0010001010111110 %1010001010111101
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011010001 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110
.dw %0010000011100011 %0010000011100100 %0010001011000000 %0010001011000000 %0010001010111110 %1010001010111101 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010110100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010
.dw %0010001010111110 %1010001010111101 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010110001 %1000000010110010 %0010000010110011 %0010000010110011 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %1010001010111100
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %1010000010111100 %0010000011000000 %0010000011011110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010001010111110 %1010001010111101 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011 %0000000010011100 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %1010000010111101 %0010000010111110 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %1010001010111100 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011 %0000000010011100 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %1010000010111100 %0010000011100101 %0010000011100110

.dw %0010000011010111 %0010000011011000 %0010000011011001 %1010001010111100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011
.dw %0000000010011100 %0000001010011100 %0000001010011011 %0000000010101011 %1000000010101111 %0010000010110000 %0010000011001001 %0010000011001010

.dw %0010000011011011 %0010000011011100 %0010000011011101 %0010001010110011 %1000001010110010 %0000001010110001 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011010 %0100000010110001 %1000000010110010 %0010000010110011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110

.dw %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011011111 %1010001010111100 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1000000010101110 %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010

.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010001010111011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101
.dw %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010001010110011 %0000001010110010 %0000001010110001
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110
.dw %1110000010100101 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010110100
.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110
.dw %1000001010110000 %0000001010101111 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110 %0010000011011110
.dw %0010000011011011 %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110 %0010000011011110
.dw %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110

.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %1000001010101110 %0000000010110001 %1000000010110010 %0010000010110011 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %1000001010101110 %0000000010110001 %1000000010110010 %0010000010110011 %0010000011100001 %0010000011100010
.dw %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000 %0010000011100001 %0010000011100010

.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110
.dw %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100 %0010000011100101 %0010000011100110



Tilemap10End:
Level10End:



.ends ;--------------- end level10 section

