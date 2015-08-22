.section "level5" force

Level4Message:
 .db "LAND SLOWLY ON BLINKING ZONE",0

Level5Message:
 .db "GO RIGHT TO NEXT LANDING ZONE",0

Level6Message:
 .db "CONTINUE TO THE RIGHT...",0

Level9Message:
 .db "GO WAY UP TO NEXT LEVEL",0

SetupLevel4:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel4_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel4_line_loop
    
    
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
    ld hl,$4000
    ld (posX),hl
    ld hl,$0A00
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ;ld hl,((Tilemap5End-Tilemap5Start)/48)*8
    ld (XScrollTotalMax),hl
    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoWon
    ld (OnLandLeftFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ;show level message
    ld de,Level4Message;text pointer in de
    ld c,3;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
    
    ld a,1
    ld (first_frame_on_end_status),a
ret



SetupLevel5:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel5_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel5_line_loop
    
    
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
    ld hl,$4800-$1400
    ld (posX),hl
    ld hl,$6800-1
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ld hl,160
    ld (XScrollTotalMax),hl
    
    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWait
    ld (OnLandLeftFunction),hl
    ld hl,DoWon
    ld (OnLandRightFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ;show level message
    ld de,Level5Message;text pointer in de
    ld c,3;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
    
    ld a,1
    ld (first_frame_on_end_status),a
ret

SetupLevel6:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel6_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel6_line_loop
    
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
    ld hl,$2800
    ld (posX),hl
    ld hl,$7800-1
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ld hl,160+256
    ld (XScrollTotalMax),hl
    
    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWon
    ld (OnLandLeftFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ld de,160
    call SetHScrollTo
    
    ld a,1
    ld (first_frame_on_end_status),a
    
    ;show level message
    ld de,Level6Message;text pointer in de
    ld c,24;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
ret


SetupLevel7:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel7_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel7_line_loop
    
    ;init music
    ld hl,00;end_music_ch1_start
    call InitMusic1
    ld hl,end_music_ch2_start
    call InitMusic2
    ld hl,00;end_music_ch3_start
    call InitMusic3
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ;ld hl,((Tilemap5End-Tilemap5Start)/48)*8
    ld hl,600+256
    ld (XScrollTotalMax),hl
    
    ld de,180+256
    call SetHScrollTo
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$9000
    ld (posX),hl
    ld hl,$8000 -1
    ld (posY),hl
    xor a
    ld (rocket_status),a
    

    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWon
    ld (OnLandRightFunction),hl
    ld hl,DoWait
    ld (OnLandLeftFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    
    ld a,1
    ld (first_frame_on_end_status),a
    
    ;show level message
    ;ld de,Level6Message;text pointer in de
    ;ld c,1;col (tiles) in c
    ;ld l,3;line (tiles) in l
    ;ld a,1;have to write slowly
    ;call PrintText
ret


SetupLevel8:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel8_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel8_line_loop
    
    ;init music
    ld hl,00;end_music_ch1_start
    call InitMusic1
    ld hl,end_music_ch2_start
    call InitMusic2
    ld hl,00;end_music_ch3_start
    call InitMusic3
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ld hl,768+256
    ld (XScrollTotalMax),hl
    
    ld de,600+256
    call SetHScrollTo
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$8800
    ld (posX),hl
    ld hl,$6000 -1
    ld (posY),hl
    xor a
    ld (rocket_status),a
    

    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWon
    ld (OnLandLeftFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoLost
    ld (OnOutFunction),hl
    
    ld a,1
    ld (first_frame_on_end_status),a
    
    ;show level message
    ;ld de,Level6Message;text pointer in de
    ;ld c,1;col (tiles) in c
    ;ld l,3;line (tiles) in l
    ;ld a,1;have to write slowly
    ;call PrintText
ret


SetupLevel9:
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
    ld hl,Palette5Start
    ld b,(Palette5End-Palette5Start)
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

    ;big horizontal tilemap
    ld hl,160
    ld (LevelMapWidth),hl
    ld hl,Tilemap5Start
    ld (LevelMapStart),hl
    
    ;load tilemap of current level
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
    ld hl,(LevelMapWidth);compute how much to add to get next line
    ld de,-32
    add hl,de
    add hl,hl
    ld d,h
    ld e,l ;de is how much bytes to complete a line
    ld hl,(LevelMapStart)
    ld c,24;line counter
    SetupLevel9_line_loop:
      ld b,32*2; Counter for number of bytes to write
      -:
          ld a,(hl)    ; Get data byte
          out ($be),a
          inc hl       ; Point to next tile
          dec b
          ld a,b
          cp 0
          jr nz,-
      add hl,de
      dec c
      ld a,c
      cp 0
      jr nz,SetupLevel9_line_loop
    
    ;init music
    ld hl,00;end_music_ch1_start
    call InitMusic1
    ld hl,end_music_ch2_start
    call InitMusic2
    ld hl,00;end_music_ch3_start
    call InitMusic3
    
    ;initialize scroll variables
    xor a
    ld (XScrollVDP),a
    ld (YScrollVDP),a
    ld hl,0
    ld (XScrollTotal),hl
    ld (YScrollTotal),hl
    
    
    ;compute max scroll value
    ld hl,0
    ld (YScrollTotalMax),hl
    ld hl,768+256
    ld (XScrollTotalMax),hl
    
    ld de,768+256
    call SetHScrollTo
    
    ;variables initialization
    ld hl,$0
    ld (speedX),hl
    ld hl,$0
    ld (speedY),hl
    ld hl,$EB00
    ld (posX),hl
    ld hl,$7800 -1
    ld (posY),hl
    xor a
    ld (rocket_status),a
    
    
    ;functers
    ld hl,DoStart
    ld (OnStartFunction),hl
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl
    ld hl,DoWait
    ld (OnLandRightFunction),hl
    ld hl,DoWait
    ld (OnLandLeftFunction),hl
    ld hl,DoWon
    ld (OnOutFunction),hl
    
    
    ld a,1
    ld (first_frame_on_end_status),a
    
    ;show level message
    ld de,Level9Message;text pointer in de
    ld c,3;col (tiles) in c
    ld l,3;line (tiles) in l
    ld a,1;have to write slowly
    call PrintText
ret



;==============================================================
; Data
;==============================================================

Level5Start:

Palette5Start:
.db %00010100,$07,$00,$04,$06,$08,$0b,$10,$14,$15,$16,$1a,$29,$3f,$15,$0f
.db $00,$3f,$00,$20,$38,$01,$02,$03,$15,$2a,$1f,$2f,$3a,$36,$01,$0a
Palette5End:

Tilemap5Start:
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010010011 %0100000010010100 %0000001010001010 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000011 %0000000010110110 %0000000010110110 %0000000011000011
.dw %0000000010110110 %0000000010110110 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000001010101001 %1000000010000111 %0010001011100000 %0010001011011111 %0010000011001111 %1000001010000111 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011
.dw %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011
.dw %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000001010100111 %0000001010101011 %0010000010111011 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0000001010001110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000011 %0000000011000011 %0000000011000001 %0000000011000011 %0000000011000011
.dw %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011
.dw %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000011000011 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000010 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111
.dw %0000001010101011 %0000001010101011 %1010000010111100 %0010001011011000 %0010001011010111 %0010000011000111 %0010000011001000 %1000001010001101
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000010 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011
.dw %0000001010101011 %0000001010101011 %0000001010101011 %0000000010111101 %0110000010111110 %0010001011000000 %0110001010111110 %0000001010111101
.dw %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011 %0000001010101011
.dw %0000001010101011 %0000001010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010001010 %0100000010001011 %0010000010001100 %0010001010001100

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010001110 %0010001010001001 %1000001010001000
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011
.dw %0000001010101011 %0000001010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010001010 %0100000010001011 %0010000010001100 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000010 %0000000011000001 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %1000000010001101 %0010000011100011 %0010000011100100
.dw %0000001010010010 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011 %0000001010101011
.dw %0000001010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000001010011100 %0000001010011011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010001010 %0100000010001011
.dw %0010000010001100 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010001010 %1000000010001011 %0010000010001100 %0010000011001010 %0010000011010111 %0010000011011000
.dw %1100001010010001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011010 %0000000010011011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000011000010 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %1010000010111001 %0010000010111010
.dw %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %1000000010000111 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010001010010000 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110001 %0100000010110010 %1000000010110011 %0000001010110101
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %1010000010111001 %0010000010111010 %0010000011001101 %0010000011001110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010010010 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010001010001111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000001010100111 %0000000010011011 %0000000010011100 %0000001010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010110101 %0100001010110000 %0000001010101111 %1000000010101110 %0010001011010001 %0010001011010000 %0010001011001111 %1000001010110100
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %1010000010111001 %0010000010111010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %1100000010010001 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0000001010001110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111
.dw %0000001010101011 %0000001010101011 %0000001010101011 %0000000010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %1000000010110100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010000010011000
.dw %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010100111
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %1010000010111001 %0010000010111010 %0010000011011101 %0010000011011110

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101000 %0000000010101001 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %1000000010010000 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %1000001010001101 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000001010101011
.dw %0000001010101011 %0000001010101011 %0000000010101011 %0000000010101011 %0000000010011010 %0000000010101011 %0000000010101011 %1000000010101110
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010
.dw %1000001010110100 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %1010000010111001 %0010000010111010

.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001
.dw %0000000010101101 %0000000010101100 %0000000010101101 %0000001010101011 %0000001010101011 %0000001010101011 %0000001010101011 %0000000010100111
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010010010
.dw %0100001010001011 %0000001010001010 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010010010
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0000001010001110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010110110 %0000001010100111 %0000001010101011 %0000001010101011
.dw %0000001010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0000000010011010 %0000000010110101 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110
.dw %0010000010011000 %0000001010110101 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0100001010110011 %0100001010110010
.dw %0000001010110001 %0000000010101011 %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010101001 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011010 %0000001010101011 %0000001010101011 %0000001010101011 %0000001010101011
.dw %0000000010100111 %0000000010110110 %0000000010110110 %0000001010100111 %0000000010100111 %0000000010110110 %0000000010110110 %1100000010010001
.dw %0010000011100101 %0010000011011010 %1000001010000111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101000 %0000000010101001 %0000000010110110 %0000000010110110 %1100000010010001
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %1000001010001101 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000001010110110 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011
.dw %0000000010101011 %0000001010011100 %0000001010011011 %0000000010011010 %0000000010101011 %0000000010101011 %1000000010110100 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %0010000010011110 %1000001010110011 %0100001010110010 %0100000010101111 %0100001010101111 %1000000010110100 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0100001010110011 %0000001010110010 %0000001010110001 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101000 %0000000010101001
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000001
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110

.dw %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0000001010101011 %0000001010101011 %0000001010101011
.dw %0000001010101011 %0000000010100111 %0000001010100111 %0000000010011011 %0000000010011100 %0000000010101000 %0000000010101001 %1000000010010000
.dw %0010000011011101 %0010000011011110 %0010000011001011 %1000001010001001 %0000001010001000 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000001010100111 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101000 %0000000010101001 %0010000010010000
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0000001010001110 %0000000010001110 %0010001010001001 %0000001010001000 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010001110 %1000001010000111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000011000010
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000001010100111 %0000000010100111 %0000001010100111 %0000001010101011 %0000001010101011 %0000001010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %1110000010100101 %1110000010100101 %1000001010000111 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010100111 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101000 %0000000010101001 %0000001010100111 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010010010

.dw %0000000010101011 %0000000010101011 %0000000010101100 %0000000010101101 %0000000010110001 %0100000010110010 %1000000010110011 %1110001010100101
.dw %1110001010100101 %1110001010100101 %1110001010100101 %1110001010100101 %1000001010110000 %0000001010101111 %0000001010101011 %0000001010101011
.dw %0000001010011100 %0000001010011010 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011010 %0000000010110101 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %1000001010001100 %0100001010001011 %0000001010001010
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001
.dw %0000001010101000 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011010111 %0010000011011000 %0010000011011001 %0010000011011010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %1000001010001101 %0010000010001101 %0010000011010010 %0010000011011111 %1000001010000111
.dw %0000000010110110 %0000000010110110 %1000000010001101 %0010000011010000 %0000001010001110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000001010100111 %0000001010011011 %0000001010011011 %0000000010011011 %0000000010011100 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010110100 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010
.dw %0010001011011001 %0010001011011000 %0010001011010111 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011100010 %0000001010001110
.dw %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000001010011100 %0000001010011011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %1000000010000111 %0010001010001100 %1000001010010101 %0000001010010100 %0000001010010011 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %1100000010010001

.dw %0000000010101011 %0000000010101011 %0000000010101111 %0100000010110000 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0100001010110000 %0000001010101111
.dw %0000001010011010 %0000001010101011 %0000001010101011 %0000001010101011 %0000001010101011 %0000000010101011 %1000000010110100 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %1000001010000111 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000001010101001 %0000001010101000 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011100 %0000001010011011 %0010000010111011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011011110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011011011 %0010000011011100 %0010000011011101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %1000000010100110 %1000000010001001 %0010000011010011 %0010000011010100 %1000001010001101 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010101001 %0000000010101001 %0000001010101001 %0000000010101001 %0000001010101001 %0000001010101000
.dw %0000001010011011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011011 %0000000010011100 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %1000000010101110 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110
.dw %0010001011011101 %0010001011011100 %0010001011011011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %1000001010001101
.dw %0000001010101001 %0000001010101000 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011010
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110 %0000000010110110
.dw %0000000010110110 %0000000010001110 %0010001011011011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %1000001010001100
.dw %0100001010010101 %0100000010010101 %0100000010010110 %1000001010001001 %0000001010001000 %0000000010110110 %0000000010110110 %1100000010010000

.dw %0000000010101111 %0100000010110000 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011000111
.dw %1000001010110011 %0100001010110010 %0000001010110001 %0000000010110001 %0100000010110010 %1000000010110011 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010001010001100 %1110000010100101 %1110000010100101 %1110000010100101 %1110000010100101 %1110000010100101 %1110000010100101
.dw %1110000010100101 %1110000010100101 %0010001010110011 %0100001010110010 %0000001010110001 %1000000010101110 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010001010001001 %1000001010001000 %0000000010110110
.dw %0000000010110110 %0000000010110110 %0000001010101001 %0000000010101001 %0000001010101001 %0000001010101000 %0000000010100111 %0000000010110110
.dw %0000000010110110 %0000001010100111 %1000000010101110 %0010001010110000 %0000001010101111 %0000000010101111 %0100001010110011 %0100000010110000
.dw %0100001010110000 %0000001010101111 %0000001010011011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010011010
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010110101 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %0010001011100001 %0010001011100000 %0010001011011111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %1000001010110011 %0100001010110010 %0000001010110001 %0000000010101011 %0000000010101011 %0000000010101011 %0000001010011010 %0000000010101011
.dw %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010100111 %0000000010110110
.dw %0000000010110110 %1000000010001101 %0010001011011111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010000011001110 %0010001011010001 %1110001010100101 %1110001010100101 %0010001011100010

.dw %0010000011001101 %0010000011001110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %1110001010100101
.dw %1110001010100101 %1110001010100101 %1110001010100101 %0000001010101110 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101000
.dw %0000001010101000 %1000000010101110 %0010000011001011 %0010000011001001 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %1000001010101110 %0000001010011011 %0000000010101011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010011010 %0000000010101011 %0000000010101011 %1000000010110100 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0100001010110000 %0000001010101111 %0000000010110001 %0100000010110010 %0010000010110011
.dw %0100001010110000 %0000001010101111 %0000000010101111 %0100000010110000 %0010001010110011 %0000001010110010 %0000001010110001 %0000000010101010
.dw %1000000010001001 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110

.dw %0010000011010001 %0010000011010010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011001111 %0010000011010000 %1000001010110000 %0000001010101111 %0000000010110001 %0100000010110010
.dw %1000000010110011 %0010000011100010 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111 %0010000011100000
.dw %0010000011100001 %0010000011100010 %0010000011010110 %1000001010101110 %0000001010011011 %0000000010101011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010011010 %0000000010110101 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010
.dw %0010001011011001 %0010001011011000 %0010001011010111 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010
.dw %0010001011011001 %0010001011011000 %0010001011010111 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010
.dw %0010001011011001 %0010001011011000 %0010001011010111 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111
.dw %0010000011011000 %0010000011011001 %0010000011011010 %0010001011001010 %0010001011001001 %0010001011001000 %0010001011000111 %0010001011011010

.dw %0010000011010101 %0010000011010110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011 %0010000011100100
.dw %0010000011100101 %0010000011100110 %0010000011010011 %0010000011010100 %1000001010101110 %0000001010011011 %0000000010101011 %0000000010101011
.dw %0000000010101011 %0000000010101011 %1000000010110100 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110
.dw %0010001011011101 %0010001011011100 %0010001011011011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110
.dw %0010001011011101 %0010001011011100 %0010001011011011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110
.dw %0010001011011101 %0010001011011100 %0010001011011011 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011
.dw %0010000011011100 %0010000011011101 %0010000011011110 %0010001011001110 %0010001011001101 %0010001011001100 %0010001011001011 %0010001011011110

.dw %0010000011001001 %0010000011001010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011001001 %0010000011001010 %0010000011010111 %0010000011011000
.dw %0010000011011001 %0010000011011010 %0010000011000111 %0010000011001000 %0010000011011110 %1000001010110000 %0000001010101111 %0000000010101011
.dw %0000000010101011 %1000000010101110 %0010001011001111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %0010001011100001 %0010001011100000 %0010001011011111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %0010001011100001 %0010001011100000 %0010001011011111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010
.dw %0010001011100001 %0010001011100000 %0010001011011111 %0010000011001111 %0010000011010000 %0010000011010001 %0010000011010010 %0010000011011111
.dw %0010000011100000 %0010000011100001 %0010000011100010 %0010001011010010 %0010001011010001 %0010001011010000 %0010001011001111 %0010001011100010

.dw %0010000011001101 %0010000011001110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001110 %0010000011011011 %0010000011011100
.dw %0010000011011101 %0010000011011110 %0010000011001011 %0010000011001100 %0010000011001101 %0010000011001100 %0010000011010000 %0010001010110000
.dw %0010000010110011 %0010000011100011 %0010000011100100 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110
.dw %0010001011100101 %0010001011100100 %0010001011100011 %0010000011010011 %0010000011010100 %0010000011010101 %0010000011010110 %0010000011100011
.dw %0010000011100100 %0010000011100101 %0010000011100110 %0010001011010110 %0010001011010101 %0010001011010100 %0010001011010011 %0010001011100110


Tilemap5End:
Level5End:

end_music_ch1_start:
  .db $01,$40,$02,$0e, $01,$40,$02,$0c, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$07, $01,$40,$02,$05, $01,$40,$02,$06, $01,$40,$32,$07, $01,$40,$02,$0e, $01,$40,$02,$0c, $01,$40,$02,$0a, $01,$40,$02,$09, $01,$40,$02,$07, $01,$40,$02,$05, $01,$40,$02,$06, $01,$40,$08,$07, $00,$fe,$02,$0e, $00,$fe,$02,$0d, $00,$fe,$02,$0b, $00,$fe,$02,$09, $00,$fe,$02,$07, $00,$fe,$02,$05, $00,$fe,$02,$06, $00,$fe,$20,$07, $01,$40,$02,$0d, $01,$40,$02,$0c, $01,$40,$02,$0a, $01,$40,$02,$08, $01,$40,$02,$06, $01,$40,$02,$05, $01,$40,$02,$06, $01,$40,$1e,$07, $01,$53,$02,$0e, $01,$53,$02,$0d, $01,$53,$02,$0b, $01,$53,$02,$09, $01,$53,$02,$07, $01,$53,$02,$05, $01,$53,$02,$06, $01,$53,$48,$07, $00,$fe,$02,$0f, $00,$fe,$02,$0d, $00,$fe,$02,$0b, $00,$fe,$02,$09, $00,$fe,$02,$07, $00,$fe,$06,$06, $00,$fe,$08,$07, $00,$fe,$02,$08, $00,$fe,$02,$0a, $00,$fe,$02,$0b, $00,$fe,$02,$0d, $00,$fe,$02,$0e, $01,$00,$36,$0f, $01,$7d,$02,$0d, $01,$7d,$02,$0b, $01,$7d,$02,$09, $01,$7d,$02,$08, $01,$7d,$02,$06, $01,$7d,$02,$05, $01,$7d,$02,$06, $01,$7d,$30,$07, $01,$7d,$02,$0f, $01,$7d,$02,$0d, $01,$7d,$02,$0b, $01,$7d,$02,$09, $01,$7d,$02,$07, $01,$7d,$06,$06, $01,$7d,$08,$07, $01,$40,$02,$0d, $01,$40,$02,$0b, $01,$40,$02,$0a, $01,$40,$02,$08, $01,$40,$02,$06, $01,$40,$02,$05, $01,$40,$02,$06, $01,$40,$1e,$07, $01,$7d,$02,$0e, $01,$7d,$02,$0c, $01,$7d,$02,$0b, $01,$7d,$02,$09, $01,$7d,$02,$07, $01,$7d,$02,$05, $01,$7d,$02,$06, $01,$7d,$20,$07, $01,$ac,$02,$0d, $01,$ac,$02,$0b, $01,$ac,$02,$0a, $01,$ac,$02,$08, $01,$ac,$02,$06, $01,$ac,$02,$05, $01,$ac,$02,$06, $01,$ac,$48,$07, $01,$ac,$02,$08, $01,$ac,$02,$0a, $01,$ac,$02,$0b, $01,$ac,$02,$0d, $01,$ac,$02,$0e, $01,$ac,$4c,$0f, $01,$e0,$02,$0e, $01,$e0,$02,$0c, $01,$e0,$02,$0a, $01,$e0,$02,$08, $01,$e0,$02,$07, $01,$e0,$02,$05, $01,$e0,$02,$06, $01,$e0,$32,$07, $01,$e0,$02,$0d, $01,$e0,$02,$0c, $01,$e0,$02,$0a, $01,$e0,$02,$08, $01,$e0,$02,$06, $01,$e0,$02,$05, $01,$e0,$02,$06, $01,$e0,$08,$07, $01,$ac,$02,$0e, $01,$ac,$02,$0c, $01,$ac,$02,$0a, $01,$ac,$02,$09, $01,$ac,$02,$07, $01,$ac,$02,$05, $01,$ac,$02,$06, $01,$ac,$1e,$07, $01,$e0,$02,$0f, $01,$e0,$02,$0d, $01,$e0,$02,$0b, $01,$e0,$02,$09, $01,$e0,$02,$08, $01,$e0,$02,$06, $01,$e0,$02,$05, $01,$e0,$02,$06, $01,$e0,$1e,$07, $01,$fc,$02,$0e, $01,$fc,$02,$0c, $01,$fc,$02,$0a, $01,$fc,$02,$09, $01,$fc,$02,$07, $01,$fc,$02,$05, $01,$fc,$02,$06, $01,$fc,$48,$07, $01,$40,$02,$0e, $01,$40,$02,$0c, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$07, $01,$40,$02,$05, $01,$40,$02,$06, $01,$40,$48,$07, $01,$53,$02,$0e, $01,$53,$02,$0d, $01,$53,$02,$0b, $01,$53,$02,$09, $01,$53,$02,$07, $01,$53,$02,$05, $01,$53,$02,$06, $01,$53,$32,$07, $01,$53,$02,$0e, $01,$53,$02,$0c, $01,$53,$02,$0b, $01,$53,$02,$09, $01,$53,$02,$07, $01,$53,$02,$05, $01,$53,$02,$06, $01,$53,$08,$07, $01,$40,$02,$0f, $01,$40,$02,$0d, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$07, $01,$40,$06,$06, $01,$40,$1e,$07, $01,$1d,$02,$0e, $01,$1d,$02,$0c, $01,$1d,$02,$0a, $01,$1d,$02,$08, $01,$1d,$02,$07, $01,$1d,$02,$05, $01,$1d,$02,$06, $01,$1d,$1e,$07, $01,$40,$02,$0f, $01,$40,$02,$0d, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$07, $01,$40,$06,$06, $01,$40,$48,$07, $01,$40,$02,$09, $01,$40,$02,$0a, $01,$40,$02,$0b, $01,$40,$02,$0d, $01,$40,$02,$0e, $01,$40,$b4,$0f, $ff,$ff
  ;total 1500 frames
end_music_ch1_end:

end_music_ch2_start:
  .db $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0f, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$04,$08, $00,$7f,$0a,$09, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$6b,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0f, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$04,$08, $00,$7f,$0a,$09, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$6b,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$aa,$02,$0e, $00,$aa,$02,$0d, $00,$aa,$02,$0c, $00,$aa,$02,$0b, $00,$aa,$02,$09, $00,$aa,$02,$08, $00,$aa,$0a,$09, $00,$7f,$02,$0f, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$04,$08, $00,$7f,$0a,$09, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$6b,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$aa,$02,$0e, $00,$aa,$02,$0d, $00,$aa,$02,$0c, $00,$aa,$02,$0b, $00,$aa,$02,$09, $00,$aa,$02,$08, $00,$aa,$0a,$09, $00,$7f,$02,$0f, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$04,$08, $00,$7f,$0a,$09, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$6b,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$be,$02,$0e, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0b, $00,$be,$02,$09, $00,$be,$02,$08, $00,$be,$0a,$09, $00,$a0,$02,$0f, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$04,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$be,$02,$0e, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0b, $00,$be,$02,$09, $00,$be,$02,$08, $00,$be,$0a,$09, $00,$a0,$02,$0f, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$04,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0f, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$04,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0f, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$04,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$f0,$02,$0e, $00,$f0,$02,$0d, $00,$f0,$02,$0c, $00,$f0,$02,$0b, $00,$f0,$02,$09, $00,$f0,$02,$08, $00,$f0,$0a,$09, $00,$be,$02,$0f, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0b, $00,$be,$02,$0a, $00,$be,$04,$08, $00,$be,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$be,$02,$0e, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0a, $00,$be,$02,$09, $00,$be,$02,$08, $00,$be,$0a,$09, $00,$f0,$02,$0e, $00,$f0,$02,$0d, $00,$f0,$02,$0c, $00,$f0,$02,$0b, $00,$f0,$02,$09, $00,$f0,$02,$08, $00,$f0,$0a,$09, $00,$be,$02,$0f, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0b, $00,$be,$02,$0a, $00,$be,$04,$08, $00,$be,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$be,$02,$0e, $00,$be,$02,$0d, $00,$be,$02,$0c, $00,$be,$02,$0a, $00,$be,$02,$09, $00,$be,$02,$08, $00,$be,$0a,$09, $00,$fe,$02,$0e, $00,$fe,$02,$0d, $00,$fe,$02,$0c, $00,$fe,$02,$0b, $00,$fe,$02,$09, $00,$fe,$02,$08, $00,$fe,$0a,$09, $00,$d6,$02,$0f, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$0a, $00,$d6,$04,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0a, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $00,$fe,$02,$0e, $00,$fe,$02,$0d, $00,$fe,$02,$0c, $00,$fe,$02,$0b, $00,$fe,$02,$09, $00,$fe,$02,$08, $00,$fe,$0a,$09, $00,$d6,$02,$0f, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$0a, $00,$d6,$04,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0a, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $01,$1d,$02,$0e, $01,$1d,$02,$0d, $01,$1d,$02,$0c, $01,$1d,$02,$0b, $01,$1d,$02,$09, $01,$1d,$02,$08, $01,$1d,$0a,$09, $00,$d6,$02,$0f, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$0a, $00,$d6,$04,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0a, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $01,$1d,$02,$0e, $01,$1d,$02,$0d, $01,$1d,$02,$0c, $01,$1d,$02,$0b, $01,$1d,$02,$09, $01,$1d,$02,$08, $01,$1d,$0a,$09, $00,$d6,$02,$0f, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0b, $00,$d6,$02,$0a, $00,$d6,$04,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0c, $00,$d6,$02,$0a, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $01,$40,$02,$0e, $01,$40,$02,$0d, $01,$40,$02,$0c, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$08, $01,$40,$0a,$09, $00,$fe,$02,$0f, $00,$fe,$02,$0d, $00,$fe,$02,$0c, $00,$fe,$02,$0b, $00,$fe,$02,$0a, $00,$fe,$04,$08, $00,$fe,$0a,$09, $00,$d6,$02,$0e, $00,$d6,$02,$0d, $00,$d6,$02,$0b, $00,$d6,$02,$0a, $00,$d6,$02,$09, $00,$d6,$02,$08, $00,$d6,$0a,$09, $00,$a0,$02,$0e, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0a, $00,$a0,$02,$09, $00,$a0,$02,$08, $00,$a0,$0a,$09, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$0a,$09, $00,$6b,$02,$0f, $00,$6b,$02,$0d, $00,$6b,$02,$0c, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$04,$08, $00,$6b,$0a,$09, $00,$50,$02,$0e, $00,$50,$02,$0d, $00,$50,$02,$0b, $00,$50,$02,$0a, $00,$50,$02,$09, $00,$50,$02,$08, $00,$50,$1c,$09, $00,$50,$02,$0a, $00,$50,$02,$0b, $00,$50,$02,$0c, $00,$50,$02,$0d, $00,$50,$02,$0e, $00,$50,$36,$0f, $ff,$ff
  ;total 1500 frames
end_music_ch2_end:

end_music_ch3_start:
  .db $01,$40,$02,$0e, $01,$40,$02,$0d, $01,$40,$02,$0c, $01,$40,$02,$0b, $01,$40,$02,$09, $01,$40,$02,$08, $01,$40,$34,$09, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0c, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$5f,$02,$0e, $00,$5f,$02,$0d, $00,$5f,$02,$0b, $00,$5f,$02,$0a, $00,$5f,$02,$09, $00,$6b,$02,$0f, $00,$6b,$02,$0d, $00,$6b,$02,$0c, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$08, $00,$6b,$02,$09, $00,$6b,$02,$0a, $00,$6b,$02,$0b, $00,$6b,$02,$0d, $00,$6b,$02,$0e, $00,$6b,$82,$0f, $00,$6b,$02,$0d, $00,$6b,$02,$0c, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$08, $00,$5f,$02,$0e, $00,$5f,$02,$0d, $00,$5f,$02,$0c, $00,$5f,$02,$0a, $00,$5f,$02,$09, $00,$6b,$02,$0f, $00,$6b,$02,$0e, $00,$6b,$02,$0c, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$04,$09, $00,$6b,$02,$0a, $00,$6b,$02,$0b, $00,$6b,$02,$0c, $00,$6b,$02,$0e, $00,$6b,$82,$0f, $00,$7f,$02,$0e, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$78,$02,$0e, $00,$78,$02,$0d, $00,$78,$02,$0c, $00,$78,$02,$0b, $00,$78,$02,$09, $00,$78,$02,$08, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$02,$0a, $00,$7f,$02,$0b, $00,$7f,$02,$0c, $00,$7f,$02,$0d, $00,$7f,$82,$0f, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$78,$02,$0f, $00,$78,$02,$0d, $00,$78,$02,$0c, $00,$78,$02,$0b, $00,$78,$02,$0a, $00,$78,$02,$08, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$7f,$02,$09, $00,$7f,$02,$0a, $00,$7f,$02,$0c, $00,$7f,$02,$0d, $00,$7f,$02,$0e, $00,$7f,$80,$0f, $00,$7f,$02,$0e, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0a, $00,$7f,$02,$09, $00,$7f,$02,$08, $00,$78,$02,$0e, $00,$78,$02,$0d, $00,$78,$02,$0b, $00,$78,$02,$0a, $00,$78,$02,$09, $00,$7f,$02,$0f, $00,$7f,$02,$0d, $00,$7f,$02,$0c, $00,$7f,$02,$0b, $00,$7f,$02,$0a, $00,$7f,$02,$08, $00,$7f,$02,$09, $00,$7f,$02,$0a, $00,$7f,$02,$0b, $00,$7f,$02,$0d, $00,$7f,$02,$0e, $00,$7f,$82,$0f, $00,$a0,$02,$0d, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$02,$08, $00,$8f,$02,$0e, $00,$8f,$02,$0d, $00,$8f,$02,$0c, $00,$8f,$02,$0a, $00,$8f,$02,$09, $00,$a0,$02,$0f, $00,$a0,$02,$0e, $00,$a0,$02,$0c, $00,$a0,$02,$0b, $00,$a0,$02,$0a, $00,$a0,$04,$09, $00,$a0,$02,$0a, $00,$a0,$02,$0b, $00,$a0,$02,$0c, $00,$a0,$02,$0e, $00,$a0,$82,$0f, $00,$6b,$02,$0e, $00,$6b,$02,$0c, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$5f,$02,$0e, $00,$5f,$02,$0d, $00,$5f,$02,$0c, $00,$5f,$02,$0b, $00,$5f,$02,$09, $00,$5f,$02,$08, $00,$6b,$02,$0e, $00,$6b,$02,$0d, $00,$6b,$02,$0b, $00,$6b,$02,$0a, $00,$6b,$02,$09, $00,$6b,$02,$08, $00,$6b,$02,$0a, $00,$6b,$02,$0b, $00,$6b,$02,$0c, $00,$6b,$02,$0d, $00,$6b,$ff,$0f, $00,$6b,$67,$0f, $ff,$ff
  ;total 1500 frames
end_music_ch3_end:



.ends ;--------------- end level5 section

