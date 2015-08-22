;For music you need these variables:
;music1_start_ptr         dw ;pointer
;music1_current_ptr         dw ;pointer
;music1_tone_duration         db ;when 0 got to next tone
;music1_current_tone         dw ;value (for debug)
;music2_start_ptr         dw ;pointer
;music2_current_ptr         dw ;pointer
;music2_tone_duration         db ;when 0 got to next tone
;music2_current_tone         dw ;value (for debug)
;music3_start_ptr         dw ;pointer
;music3_current_ptr         dw ;pointer
;music3_tone_duration         db ;when 0 got to next tone
;music3_current_tone         dw ;value (for debug)
;drum_start_ptr         dw ;pointer
;drum_current_ptr         dw ;pointer
;drum_tone_duration         db ;when 0 got to next tone
;drum_current_tone         db ;value (for debug)


.ramsection "Music variables" slot 1
  music1_start_ptr         dw ;pointer
  music1_current_ptr         dw ;pointer
  music1_tone_duration         db ;when 0 got to next tone
  music1_current_tone         dw ;value (for debug)
  music2_start_ptr         dw ;pointer
  music2_current_ptr         dw ;pointer
  music2_tone_duration         db ;when 0 got to next tone
  music2_current_tone         dw ;value (for debug)
  music3_start_ptr         dw ;pointer
  music3_current_ptr         dw ;pointer
  music3_tone_duration         db ;when 0 got to next tone
  music3_current_tone         dw ;value (for debug)
  drum_start_ptr         dw ;pointer
  drum_current_ptr         dw ;pointer
  drum_tone_duration         db ;when 0 got to next tone
  drum_current_tone         db ;value (for debug)
.ends

.section "music functions" free ;

;music format:
;only 2 channel, no volume change...
;when tone duration ==1, make a 1-frame pause. At 0 change note
;3 bytes/tone : tone (16b, 10 used), duration (8b, in frames), volume (8b)
; tone $00 $00 for pause
; tone $FF $FF for end !
; tone $FF $FE for end without loop
;example :
;Music1_start:
;.db $00,$FE,60,$00,$E2,60,$00,$D5,240,$00,$00,60,$FF,$FF,00  ;A 1s,B 1s,C 4s, pause 1s, end
;Music1_end:

;drum format : 2 byte/note : %ennnvvvv (MSB is end of track, then nnn is nose type, and vvvv is volume, volume 1111=pause)
; then duration
;exemple:
;Drum1_start:
;.db %01100100,$20,%01000100,$20,%01100100,$0F,%01001111,$02,%01100100,$0F,%01000100,$20,$FF
;Drum1_end:



CutAllSound:
  push af
    ld a,%10011111 ;volume 0 on channel 0
    out ($7f),a
    ld a,%10111111 ;volume 0 on channel 1
    out ($7f),a
    ld a,%11011111 ;volume 0 on channel 2
    out ($7f),a
    ld a,%11111111 ;volume 0 on channel 3
    out ($7f),a
  pop af
  ret

CutOneChannel:
  ;channel in c*%1000000(max 3*%1000000)
  push af
    ld a,%10011111 ;volume 0 on channel 0
    or c
    out ($7f),a
  pop af
  ret


EnableChannel:
  ;volume in a (max %0000, mute %1111)
  ;channel in c*%1000000(max 3*%1000000)
  push af
    or %10010000 ;set volume
    or c ; to channel c
    out ($7f),a
  pop af
  ret

PlayTone:
  ;Tone in hl (max 1024)
  ;channel in c*%100000(max 3*%100000)
  

  push af
  push bc
  push de
    ;change hl into 4 LSB in d, and 6 MSB in e
    ld a,l
    and %00001111
    ld d,a ;4 LSB in d
    
    ld a,l
    srl a ;right shift
    srl a
    srl a
    srl a
    ld e,a ; 4 bytes for e
    ld a,h ;the 2 bytes of h must be moved left 4 times
    and %00000011
    sla a ;left shift
    sla a
    sla a
    sla a
    or e
    ld e,a ;6 MSB in e
    
    ld a,%10000000 ;tune
    or c ; on channel...
    or d
    out ($7f),a
    ld a,%00000000 ;tune data
    or e
    out ($7f),a
  pop de
  pop bc
  pop af
  ret

PlaySimpleNoise:
  ;noise in a
  push af
  push bc
  push de
    and %00001111
    or %1110000
    out ($7f),a
  pop de
  pop bc
  pop af
  ret

;noise info in a, format %0nnnvvvv (nnn is nose type, and vvvv is volume, volume 1111=pause) 
PlayNoise:
  ;noise in a
  push af
	;volume part
	and %00001111		;keep only volume
	or %11110000 ;set channel 3
	out ($7f),a
  pop af			;tone part, move 4 bytes right
	push af
	rra
	rra
	rra
	rra
	and %00001111
	or %11100000
	out ($7f),a
  pop af
  ret


InitMusic1:
  push af
    ;data1 start in hl
    ld (music1_start_ptr),hl
    dec hl ; get back 4 bytes
    dec hl
    dec hl
    dec hl
    ld (music1_current_ptr),hl ;current pointer is to a fake previous tone because music_tone_duration is 0
    ld a,1
    ld (music1_tone_duration),a
  pop af
  ret

InitMusic2:
  push af
    ;data2 start in hl
    ld (music2_start_ptr),hl
    dec hl ; get back 4 bytes
    dec hl
    dec hl
    dec hl
    ld (music2_current_ptr),hl ;current pointer is to a fake previous tone because music_tone_duration is 0
    ld a,1
    ld (music2_tone_duration),a
  pop af
  ret
  
InitMusic3:
  push af
    ;data3 start in hl
    ld (music3_start_ptr),hl
    dec hl ; get back 4 bytes
    dec hl
    dec hl
    dec hl
    ld (music3_current_ptr),hl ;current pointer is to a fake previous tone because music_tone_duration is 0
    ld a,1
    ld (music3_tone_duration),a
  pop af
  ret

InitDrum:
  push af
    ;data start in hl
    ld (drum_start_ptr),hl
    dec hl ; get back 2 bytes
    dec hl
    ld (drum_current_ptr),hl ;current pointer is to a fake previous tone because music_tone_duration is 0
    ld a,1
    ld (drum_tone_duration),a
  pop af
  ret

PlayMusic1:
  push af
  push bc
  push hl
    ;if music1_start_ptr==0, do nothing
    ld hl,(music1_start_ptr)
    ld a,h
    or l
    jp z,PlayMusic1_end
  
    ;check is current tone is still played
    ld a,(music1_tone_duration)
    dec a
    ld (music1_tone_duration),a
    ;cp 1 ;if duration == 1 make a pause
    ;jr nz,+
    ;  ;make pause
    ;  ld c,0;channel in c*%100000(max 3*%100000)
    ;  call CutOneChannel
    ;  ret
    ;+: ; not 1, try 0
    cp 0
    jr z,+
      pop hl
      pop bc
      pop af
      ret ;if not 0 continue tone...
    +:
    ;if 0, have to change tone...
    ld hl,(music1_current_ptr)
    inc hl
    inc hl
    inc hl
    inc hl;go 4 bytes later
    ld (music1_current_ptr),hl
    
    ;check if end of partition
    ld bc,(music1_current_ptr)
    ld a,(bc)
    cp $FF
    jr nz,+ ;(music1_current_ptr) != $ff, not end of track
    
    inc bc
    ld a,(bc)
    cp $FE
    jr c,+;(music1_current_ptr+1) != $ff, not end of track
    
    ;have to loop music
    ld hl,(music1_start_ptr)
    ld (music1_current_ptr),hl ;return to begin of track
    
    cp $FE ;if $FF, $FE, end of music
    jr nz,+
      ld hl,0
      ld (music1_start_ptr),hl
      ld c,0;channel in c*%100000(max 3*%100000)
      call CutOneChannel
      jp PlayMusic1_end
    
    +:
    
    ;play tone:
    ld bc,(music1_current_ptr)
    ld a,(bc)
    ld h,a
    inc bc
    ld a,(bc)
    ld l,a;tone in hl
    
    ld (music1_current_tone),hl
    
    ;get duration
    inc bc
    ld a,(bc)
    ld (music1_tone_duration),a
    
    ;test if tone==0
    ld a,h
    cp $00
    jr nz,+

    ld a,l
    cp $00
    jr nz,+;(music1_current_ptr+1) != 0, not pause
    ;this is a pause, so cut sound
    ld c,0;channel in c*%100000(max 3*%100000)
    call CutOneChannel
    pop hl
    pop bc
    pop af
    ret
   +:
    ;get volume
    inc bc
    ld a,(bc)
    ld c,0;channel in c*%100000(max 3*%100000)
    ;ld a,%1000 ;volume
    call EnableChannel
    call PlayTone
    
    PlayMusic1_end:
  pop hl
  pop bc
  pop af
  ret
  
PlayMusic2:
  push af
  push bc
  push hl
    ;if music2_start_ptr==0, do nothing
    ld hl,(music2_start_ptr)
    ld a,h
    or l
    jp z,PlayMusic2_end
  
    ;check is current tone is still played
    ld a,(music2_tone_duration)
    dec a
    ld (music2_tone_duration),a
    cp 0 ;if duration == 0, next tone
    jr z,+
      pop hl
      pop bc
      pop af
      ret ;if not 0 continue tone...
    +:
    ;if 0, have to change tone...
    ld hl,(music2_current_ptr)
    inc hl
    inc hl
    inc hl
    inc hl;go 4 bytes later
    ld (music2_current_ptr),hl
    
    ;check if end of partition
    ld bc,(music2_current_ptr)
    ld a,(bc)
    cp $FF
    jr nz,+ ;(music2_current_ptr) != $ff, not end of track
    
    inc bc
    ld a,(bc)
    cp $FE
    jr c,+;(music2_current_ptr+1) != $ff, not end of track
    
    ;have to loop music
    ld hl,(music2_start_ptr)
    ld (music2_current_ptr),hl ;return to begin of track
    
    cp $FE ;if $FF, $FE, end of music
    jr nz,+
      ld hl,0
      ld (music2_start_ptr),hl
      ;stop sound
      ld c,1*%100000;channel in c*%100000(max 2*%100000)
      call CutOneChannel
      jp PlayMusic2_end
    
    +:
    
    ;play tone:
    ld bc,(music2_current_ptr)
    ld a,(bc)
    ld h,a
    inc bc
    ld a,(bc)
    ld l,a;tone in hl
    
    ld (music2_current_tone),hl
    
    ;get duration
    inc bc
    ld a,(bc)
    ld (music2_tone_duration),a
    
    ;test if tone==0
    ld a,h
    cp $00
    jr nz,+

    ld a,l
    cp $00
    jr nz,+;(music2_current_ptr+1) != 0, not pause
    ;this is a pause, so cut sound
    ld c,1*%100000;channel in c*%100000(max 3*%100000)
    call CutOneChannel
    pop hl
    pop bc
    pop af
    ret
   +:
    ;get volume
    inc bc
    ld a,(bc)
    ld c,1*%100000;channel in c*%100000(max 3*%100000)
    call EnableChannel
    call PlayTone
    
    PlayMusic2_end:
  pop hl
  pop bc
  pop af
  ret

PlayMusic3:
  push af
  push bc
  push hl
    ;if music3_start_ptr==0, do nothing
    ld hl,(music3_start_ptr)
    ld a,h
    or l
    jp z,PlayMusic3_end
    
    ;check is current tone is still played
    ld a,(music3_tone_duration)
    dec a
    ld (music3_tone_duration),a
    cp 0 ;if duration == 0, next tone
    jr z,+
      pop hl
      pop bc
      pop af
      ret ;if not 0 continue tone...
    +:
    ;if 0, have to change tone...
    ld hl,(music3_current_ptr)
    inc hl
    inc hl
    inc hl
    inc hl;go 4 bytes later
    ld (music3_current_ptr),hl
    
    ;check if end of partition
    ld bc,(music3_current_ptr)
    ld a,(bc)
    cp $FF
    jr nz,+ ;(music3_current_ptr) != $ff, not end of track
    
    inc bc
    ld a,(bc)
    cp $FE
    jr c,+;(music3_current_ptr+1) != $ff, not end of track
    
    ;have to loop music
    ld hl,(music3_start_ptr)
    ld (music3_current_ptr),hl ;return to begin of track
    
    cp $FE ;if $FF, $FE, end of music
    jr nz,+
      ld hl,0
      ld (music3_start_ptr),hl
      ld c,2*%100000;channel in c*%100000(max 3*%100000)
      call CutOneChannel
      jp PlayMusic3_end
    
    +:
    
    ;play tone:
    ld bc,(music3_current_ptr)
    ld a,(bc)
    ld h,a
    inc bc
    ld a,(bc)
    ld l,a;tone in hl
    
    ld (music3_current_tone),hl
    
    ;get duration
    inc bc
    ld a,(bc)
    ld (music3_tone_duration),a
    
    ;test if tone==0
    ld a,h
    cp $00
    jr nz,+

    ld a,l
    cp $00
    jr nz,+;(music3_current_ptr+1) != 0, not pause
    ;this is a pause, so cut sound
    ld c,2*%100000;channel in c*%100000(max 3*%100000)
    call CutOneChannel
    pop hl
    pop bc
    pop af
    ret
   +:
    ;get volume
    inc bc
    ld a,(bc)
    ld c,2*%100000;channel in c*%100000(max 3*%100000)
    call EnableChannel
    call PlayTone
    
    PlayMusic3_end:
  pop hl
  pop bc
  pop af
  ret


PlayDrum:
  push af
  push bc
  push hl
    ;check is current tone is still played
    ld a,(drum_tone_duration)
    dec a
    ld (drum_tone_duration),a
    cp 0
    jr z,+
      pop hl
      pop bc
      pop af
      ret ;if not 0 continue tone...
    +:
    ;if 0, have to change tone...
    ld hl,(drum_current_ptr)
    inc hl
    inc hl;go 2 bytes later
    ld (drum_current_ptr),hl
    
    ;check if end of partition
    ld bc,(drum_current_ptr)
    ld a,(bc)
    cp $FF
    jr nz,+ ;(drum_current_ptr) != $ff, not end of track
    
      ;have to loop music
    ld hl,(drum_start_ptr)
    ld (drum_current_ptr),hl ;return to begin of track
    ld b,h
    ld c,l
    +:
    
    ;get duration
    inc bc
    ld a,(bc)
    ld (drum_tone_duration),a

    ;play tone:
    ld bc,(drum_current_ptr)
    ld a,(bc)	;tone in a
    ld (drum_current_tone),a
    
    call PlayNoise
  pop hl
  pop bc
  pop af
  ret

	
;PlayMusicH: ;with harmonics
;  ;check is current tone is still played
;  ld a,(music_tone_duration)
;  dec a
;  ld (music_tone_duration),a
;  cp 0
;  jr z,+
;    ret
;  +:
;  ;have to change tone...
;  ld hl,(music_current_ptr)
;  inc hl
;  inc hl
;  inc hl;go 3 bytes later
;  ld (music_current_ptr),hl
;  
;  ;check if end of partition
;  ld bc,(music_current_ptr)
;  ld a,(bc)
;  cp $FF
;  jr nz,+ ;(music_current_ptr) != $ff, not end of track
;  
;  inc bc
;  ld a,(bc)
;  cp $FF
;  jr nz,+;(music_current_ptr+1) != $ff, not end of track
;  
;  ;have to loop music
;  ld hl,(music_start_ptr)
;  ld (music_current_ptr),hl ;return to begin of track
;  
;  +:
;  
;  ;play tone:
;  ld bc,(music_current_ptr)
;  ld a,(bc)
;  ld h,a
;  inc bc
;  ld a,(bc)
;  ld l,a;tone in hl
;  
;  ld (music_current_tone),hl
;  
;  ;get duration
;  inc bc
;  ld a,(bc)
;  ld (music_tone_duration),a
;  
;  
;  ;test if tone==0
;  ld a,h
;  cp $00
;  jr nz,+
;
;  ld a,l
;  cp $00
;  jr nz,+;(music_current_ptr+1) != $00, not silence
;  ;this is a pause, so cut sound
;  ld c,0;channel in c*%100000(max 3*%100000)
;  call CutOneChannel
;  ld c,%00100000;channel in c*%100000(max 3*%100000)
;  call CutOneChannel
;  ;ld c,%01000000;channel in c*%100000(max 3*%100000)
;  ;call CutOneChannel
;  ret
; +:
;  ld c,0;channel in c*%100000(max 3*%100000)
;  ld a,%1000 ;volume
;  call EnableChannel
;  call PlayTone
;  add hl,hl ;8 tones (5 would be better...)
;  ld c,%00100000;channel in c*%100000(max 3*%100000)
;  ld a,%1100
;  ;call EnableChannel
;  ;call PlayTone
;  ;add hl,hl
;  ;ld c,%01000000;channel in c*%100000(max 3*%100000)
;  ;ld a,%1110
;  ;call EnableChannel
;  ;call PlayTone
;
;  ret

.ends ;--------------- end music functions section
