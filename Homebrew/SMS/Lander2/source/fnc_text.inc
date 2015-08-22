Multby32:
    ;mult l by 32, result in hl
    push af
        ld h,$00
        ld a,5 ; 32=2^5
     -: sla h ;//left shift for MSB
        sla l ;//left shift for LSB
        jr nc,+ ;if carry on sla l
        inc h
     +:
        dec a
        jr nz,-
    pop af
    ret

;print digit as sprite
PrintDigitSprite:
  ;x in h
  ;y in l
  ;value in d
  ld a,d
  add a,digits_tile_number
  ld d,a
  jp SpriteSet8x8
  

;divide by 100
DivideBy100:
  ;input x value in b
  ;output : a = x/100
  ;         b = x%100
  ld a,b
  cp 200
  jr c,+ ;if carry, a<200
  sub 200
  ld b,a
  ld a,2 ;else result is 2
  ret
 +:
  cp 100
  jr c,+ ;if carry, a<100
  sub 100
  ld b,a
  ld a,1;else result is 1
  ret
 +:
  ld b,a
  xor a ;result is 0
  ret


;divide by 10
;for x between 0 and 63: x*26/256
;for x between 64 and 99: (x-1)*26/256
DivideBy10:
  ;input x value in b (between 0 and 99)
  ;output : a = x/10
  ;         b = x%10
  ld a,b
  push hl
  push bc
    cp 64
    jr c,+
    dec a ;if a>=64, use a-1
   +:
    ld hl,0
    ld c,a
    ld b,0
    ;multiply bc by 26=16*8*2
    
    sla b ;//left shift for MSB
    sla c ;//left shift for LSB
    jr nc,+ ;if carry on sla c
    inc b
   +:
    add hl,bc;move 2*x to hl
   
   
    sla b ;//left shift for MSB
    sla c ;//left shift for LSB
    jr nc,+ ;if carry on sla c
    inc b
   +:
    sla b ;//left shift for MSB
    sla c ;//left shift for LSB
    jr nc,+ ;if carry on sla c
    inc b
   +:
    add hl,bc;add 8*x to hl (now (8+2)*x)
    
    sla b ;//left shift for MSB
    sla c ;//left shift for LSB
    jr nc,+ ;if carry on sla c
    inc b
   +:
    add hl,bc;add 16*x to hl (now (16+8+2)*x)
   
    ld d,h ;d=x/10
    
    ;get modulo
    ld hl,0
    ld b,0
    ld c,d
    sla c ;//left shift
    add hl, bc ;l=d*2
    sla c ;//left shift
    sla c ;//left shift
    add hl,bc ;l=10*d
    
  pop bc
    ;remove d*10 to b
    ld a,b
    sub l
    ld c,a
    ld a,d; a is x%10 
    ld b,c;b is x/10
  pop hl
  ret


PrintInt10Sprite: ;print an uint8 in decimal with sprites
  ;x in h
  ;y in l
  ;value in e
  ld b,e
  call DivideBy100
  ld d,a
  ;value in d
  call PrintDigitSprite
  ld a,h
  add a,8
  ld h,a
  call DivideBy10
  ld d,a
  ;value in d
  call PrintDigitSprite
  ld a,h
  add a,8
  ld h,a
  ld d,b
  ;value in d
  jp PrintDigitSprite
  

PrintInt8: ;print an int in octal...
    ;col (tiles) in c
    ;line (tiles) in l
    ;value (8bit) in e
    ; the constant "digits_tile_number" must represent the number of the "0" tile in VRAM
    
    push af
    push bc
    push de
    push hl
    
    
    ;compute the tile index in tilemap
    ;sms screen is 32*28 tiles large
    call Multby32 ;multipy l by 32, result in hl
    ld b,0
    add hl,bc
    ;ld bc,2
    ;add hl,bc ;begin to write the least siginificant digit
    add hl,hl ;2 bytes by tile
    ;hl is the number of the byte in tilemap
    
    di
    
    ;write digits
    ld d,3
  -:
        ;==============================================================
        ; Write text to name table
        ;==============================================================
        ; 1. Set VRAM write address to name table index 0
        ; by outputting $4000 ORed with $3800+hl*2
        xor a
        add a,l ;number of byte: hl
        out ($bf),a
        .db 0,0 ;double nop
        .db 0,0 ;double nop
        .db 0,0 ;double nop
        ld a,$38|$40
        add a,h ;number of byte: hl
        out ($bf),a
        .db 0,0 ;double nop
        
        ; 2. Output tilemap data   
        ld a,e
        and %00000111 ;get only the last significant digit
        ld b,a
        ld a,digits_tile_number ;tile to write : digits_tile_number+value
        add a,b
        out ($be),a
        .db 0,0 ;double nop
        .db 0,0 ;double nop
        .db 0,0 ;double nop
        .db 0,0 ;double nop
        xor a ;one zero
        out ($be),a
        
        ;ld a,e
        srl e ;divide by 8
        srl e
        srl e
        ;ld e,a
        
        dec hl ; wel'll draw next tile (go left)
        dec hl ; wel'll draw next tile (go left)
       
        ;chek if out of VDP line (usefull when H scroll)
        dec c
        ld a,c
        cp 255
        jr nz,+
          ;has to go back to screen line start
          push bc
          push hl
          ld hl,+64
          ld b,h
          ld c,l
          pop hl
          add hl,bc
          pop bc
       +:

        dec d
        jr nz,-
    
    ei
    
    pop hl
    pop de
    pop bc
    pop af
        
    ret

PrintText:
    ;col (tiles) in c
    ;line (tiles) in l
    ;text pointer in de (the text ends then ascii=0)
    ;the constant "diff_tile_ascii"  must represent difference between index in tiles and in ascii
    
    ;push bc
    ;  ld b,e
    ;  call PrintInt
    ;pop bc
    
    push bc
    push de
    push hl
    push af
    push bc
    
    
    ;compute the tile index in tilemap
    ;sms screen is 32*28 tiles large
    call Multby32 ;multipy l by 32, result in hl
    ld b,0
    add hl,bc
    ;hl is the number of the tile
    
    add hl,hl ;2 bytes by tile
    ;hl is the number of the byte in tilemap
    
    pop bc
    
    
    ;write chars
    -:
        ;==============================================================
      ; Write text to name table
      ;==============================================================
      ; 1. Set VRAM write address to name table index 0
      ; by outputting $4000 ORed with $3800+hl*2
      xor a
      add a,l ;number of byte: hl
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      ld a,$38|$40
      add a,h ;number of byte: hl
      out ($bf),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      
      ; 2. Output tilemap data   
      ld a,(de);the char
      cp 0
      jr z,PrintText_end ;end of loop if value=0
      
      sub diff_tile_ascii
      out ($be),a
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      .db 0,0 ;double nop
      xor a ;one zero
      out ($be),a
      inc de;move pointer in data
      inc hl;move pointer on screen
      inc hl;move pointer on screen
      
      ;chek if out of VDP line (usefull when H scroll)
      inc c
      ld a,c
      cp 32
      jr nz,+
      ;has to go back to screen line start
      push bc
      push hl
      ld hl,-64
      ld b,h
      ld c,l
      pop hl
      add hl,bc
      pop bc
      
    +:
      jr -
    
    
  PrintText_end:
    pop af
    pop hl
    pop de
    pop bc

    ret
    
    
;PrintTextStatic: ;for static screens (turn off screen to avoid missing letters)
;    ;col (tiles) in c
;    ;line (tiles) in l
;    ;text pointer in de (the text ends then ascii=0)
;    ;the constant "diff_tile_ascii"  must represent difference between index in tiles and in ascii
;    
;    ;push bc
;    ;  ld b,e
;    ;  call PrintInt
;    ;pop bc
;    
;    push bc
;    push de
;    push hl
;    push af
;    push bc
;    
;    
;    ;compute the tile index in tilemap
;    ;sms screen is 32*28 tiles large
;    call Multby32 ;multipy l by 32, result in hl
;    ld b,0
;    add hl,bc
;    ;hl is the number of the tile
;    
;    add hl,hl ;2 bytes by tile
;    ;hl is the number of the byte in tilemap
;    
;    pop bc
;    
;    di
;    ; Turn screen off
;    ld a,%10100000
;;          |||| |`- Zoomed sprites -> 16x16 pixels
;;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;;          |||`---- 30 row/240 line mode
;;          ||`----- 28 row/224 line mode
;;          |`------ VBlank interrupts
;;          `------- Enable display
;    out ($bf),a
;    ld a,$81
;    out ($bf),a
;    
;    ;write chars
;    -:
;        ;==============================================================
;      ; Write text to name table
;      ;==============================================================
;      ; 1. Set VRAM write address to name table index 0
;      ; by outputting $4000 ORed with $3800+hl*2
;      ld a,$00
;      add a,l ;number of byte: hl
;      out ($bf),a
;      ld a,$38|$40
;      add a,h ;number of byte: hl
;      out ($bf),a
;      
;      ; 2. Output tilemap data   
;      ld a,(de);the char
;      cp 0
;      jr z,PrintTextStatic_end ;end of loop if value=0
;      
;      sub diff_tile_ascii
;      out ($be),a
;      xor a ;one zero
;      out ($be),a
;      inc de;move pointer in data
;      inc hl;move pointer on screen
;      inc hl;move pointer on screen
;      
;      jr -
;    
;  PrintTextStatic_end:
;
;    ; Turn screen on
;    ld a,%11100000
;;          |||| |`- Zoomed sprites -> 16x16 pixels
;;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;;          |||`---- 30 row/240 line mode
;;          ||`----- 28 row/224 line mode
;;          |`------ VBlank interrupts
;;          `------- Enable display
;    out ($bf),a
;    ld a,$81
;    out ($bf),a
;    ei
;    
;    
;    pop af
;    pop hl
;    pop de
;    pop bc
;    
;        
;    ret
