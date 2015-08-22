StartGame:
    ; setup screen (VDP register 0)
    ld a,%01000110
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

    ;disable scrolling
    xor a
    out ($bf),a
    ld a,%10001000 ;x scroll
    out ($bf),a
    
    xor a
    out ($bf),a
    ld a,%10001001 ;y scroll
    out ($bf),a
    
    ld a,1
    ld (current_level),a
    
    
    ld hl,$0000
    ld (star_color1),hl
    ld hl,$2000
    ld (star_color2),hl
    
    xor a
    ld (landing_zone_color),a
    
    ld b,0;debug mode
    call SetDifficulty

    ld hl,$FF0F
    ld (rocket_fuel),hl
    xor a
    ld (already_lost),a
    
    ld a,5
    ld (nb_lives),a

NewLevel:
    call CutAllSound

    ;disable interrupts and turn off screen before writing to it. Will it fix tiles issues?
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


    ;reset scrolling
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    xor a
    ld (XScrollVDP),a
    ;VDP hz scrolling
    out ($bf),a
    ld a,%10001000
    out ($bf),a
    
    xor a
    ld (YScrollVDP),a
    ;VDP vertical scrolling
    out ($bf),a
    ld a,%10001001
    out ($bf),a
    
    call showLevel
    
    ;disable interrupts and turn off screen before writing to it. Will it fix tiles issues?
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

    ;set game status to level start
    ld a,0
    ld (gameStatus),a
    ld hl,0
    ld (gameStatusCnt),hl
    
    call SelectLevel
    
    ; setup screen (VDP register 0)
    ld a,%00100110
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
    
    ld a,1
    ld (new_frame),a

    ei;enable interruption (for vblank)    

    ;check if fuel reset
    ld a,(refuel)
    cp 0
    jr z,+
      ld hl,$FF0F
      ld (rocket_fuel),hl
   +:
    ld hl,(rocket_fuel)
    ld (rocket_fuel_level_start),hl
    
    call ResetSprites
    call SetLastSprite
    
    xor a
    ld (PauseFlag),a
GameLoop:

    ld a,(PauseFlag)
    cp 1
    jr nz,GameLoop_not_pause ;if pause do nothing in main loop
      call CutAllSound
      
      ;if level!=2
      ld a,(current_level)
      cp 2
        jr z,GameLoop_pause_lvl2
      
      ld hl,(WaitForVBlankFunction)
      call CallFunctionHL;act as "call (hl)"
      jr GameLoop
      
    GameLoop_pause_lvl2:
      call WaitForVBlankSimple
      jr GameLoop
  GameLoop_not_pause:
    
    
    ld hl,(WaitForVBlankFunction)
    call CallFunctionHL;act as "call (hl)"
    call UpdatePalette

    ;cut noise channel sound
    ld c,%01100000;channel in c*%100000(max 3*%100000)
    call CutOneChannel
    

    call GameStatusUpdate
    
    
    call UpdateScreen
    
    
    call PSGMOD_Play
    
    ;on last level, if VScroll<0, go to Level12Ending
    ld a,(current_level)
    cp number_of_levels
    jr nz,GameLoop_notEndOfGame
      ld hl,(YScrollTotal)
      ld a,h
      cp $80
      jp c,GameLoop_notEndOfGame
        ;end of game
        ld hl,(score)
        ld bc,(rocket_fuel)
        ld c,b
        xor a
        ld b,a ;bc=rocket_fuel/256
        add hl,bc
        ld (score),hl ;score+=rocket_fuel/256
        ;if refuel==0, add $600 to score to compensate
        ld a,(refuel)
        cp 0
        jr nz,+
          ld a,h
          add a,6
          ld h,a
          ld (score),hl ;score+=$600
       +:
        ;add $200 for each remaining life
        ld a,(nb_lives)
        add a,a
        ld b,a
        ld a,h
        add a,b
        ld h,a
        
        ;add $100 for each difficulty level
        ld a,(difficulty_level)
        ld b,a
        ld a,h
        add a,b
        ld h,a
        ld (score),hl
        
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
        
        jp Level12Ending
    GameLoop_notEndOfGame:
    
    jp GameLoop


;-----------------------------------------------------------------------
SelectLevel:
    ;TODO: add end of game check and show level here?
    ld a,(current_level)
    cp 1
    jr nz,+
      call SetupLevel1
      jp SelectLevel_end
  +:
    cp 2
    jr nz,+
      call SetupLevel2
      jp SelectLevel_end
  +:
    cp 3
    jr nz,+
      call SetupLevel4
      jp SelectLevel_end
  +:
    cp 4
    jr nz,+
      call SetupLevel5
      jp SelectLevel_end
  +:
    cp 5
    jr nz,+
      call SetupLevel6
      jp SelectLevel_end
  +:
    cp 6
    jr nz,+
      call SetupLevel7
      jp SelectLevel_end
  +:
    cp 7
    jr nz,+
      call SetupLevel8
      jp SelectLevel_end
  +:
    cp 8
    jr nz,+
      call SetupLevel9
      jp SelectLevel_end
  +:
    cp 9
    jr nz,+
      call SetupLevel10
      jp SelectLevel_end
  +:
    cp 10
    jr nz,+
      call SetupLevel11
      jp SelectLevel_end
  +:
    cp 11
    jr nz,+
      call SetupLevel12
      jp SelectLevel_end
  +:
    
  SelectLevel_end:
    ret


;-----------------------------------------------------------------------
SetVScrollTo:
    ;input: target VScroll value in de (de must be positive)
    
    ;while YScrollTotal < de, incremente Vscroll
    ld hl,(YScrollTotal)
    ld a,h
    cp d
    jr z,SetVScrollTo_unit
    jr nc,+
      ;has to increment v scroll
      ld c,+1
      call VScrollManager
      jp SetVScrollTo ;recursive call
  +:
    ;has to decrement v scroll
    ld c,-1
    call VScrollManager
    jp SetVScrollTo ;recursive call
    
  SetVScrollTo_unit: ;less than 256 diff
    ld a,l
    cp e
    jr z,SetVScrollTo_end
    jr nc,+
      ;has to increment v scroll
      ld c,+1
      call VScrollManager
      jp SetVScrollTo ;recursive call
  +:
    ;has to decrement v scroll
    ld c,-1
    call VScrollManager
    jp SetVScrollTo ;recursive call
  
  SetVScrollTo_end:
    ret

;-----------------------------------------------------------------------
SetHScrollTo:
    ;input: target HScroll value in de (de must be positive)
    
    ;while XScrollTotal < de, incremente Hscroll
    ld hl,(XScrollTotal)
    ld a,h
    cp d
    jr z,SetHScrollTo_unit
    jr nc,+
      ;has to increment h scroll
      ld c,+1
      call HScrollManager
      jp SetHScrollTo ;recursive call
  +:
    ;has to decrement h scroll
    ld c,-1
    call HScrollManager
    jp SetHScrollTo ;recursive call
    
  SetHScrollTo_unit: ;less than 256 diff
    ld a,l
    cp e
    jr z,SetHScrollTo_end
    jr nc,+
      ;has to increment h scroll
      ld c,+1
      call HScrollManager
      jp SetHScrollTo ;recursive call
  +:
    ;has to decrement h scroll
    ld c,-1
    call HScrollManager
    jp SetHScrollTo ;recursive call
  
  SetHScrollTo_end:
    ret



