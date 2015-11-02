; Autor : Daniel Bienvenu
; Game : GhostBlaster
; Year : 2009

        .area _DATA
        
sound_no: .ds 1

        .area _CODE

    .globl      startsnd

    .globl      _buffer_scr
    .globl      _laser_x0
    .globl      _laser_x1
;    .globl      _length
    .globl      _player_energy
    

    .globl      _joypad_1
    
    .globl      _pl_animframe
    .globl      _sprites

    .globl      _dx
    
    .globl      _ghost_counter
    .globl      _GHOSTENERGY1
    .globl      _GHOSTCOLOR1
    .globl      _ghost_e1
    .globl      _ghost_e2
    .globl      _anim_position
        
    .globl      _GHOSTMOVEMENT
    .globl      _deplacement_y
    
    .globl      _player_health
    .globl      _level_number
    .globl      _flag_end
    
    .globl      _camera
    
    .globl      _deplacement_x
    
    ;;  void asm_engine(void);
    .globl      _asm_engine
    ;  void laserbeam(void);
    ; .globl      _laserbeam
    ;  void player_joystick(void);
    ; .globl      _player_joystick
    ;  void ghostanim(void);
    ; .globl      _ghostanim
    ;  void update_playerstate(void);
    ; .globl      _update_playerstate   
    
    ;;  void wait_displayed(void);
    .globl      _wait_displayed
    
    .globl      _player_state
    .globl      _JUMP_MASK
    .globl      _flag_saut
    .globl      _saut
    
    .globl      _getcollectable
    
    .globl      _flag_letters
    .globl      _letters
    
    .globl      _blocks
    
    .globl      _keypad_1
    .globl      _keypad_2
    
    .globl      _flag_prout

_asm_engine:

    call    _blocks

    xor a
    ld  hl,#sound_no
    ld  (hl),a
    ld  hl,#_deplacement_y
    ld  (hl),a
    inc hl
    ld  (hl),a   
;    deplacement_y = 0;
;    deplacement_x = 0;

    ld  hl,#_getcollectable
    ld  a,(hl)
    or  a
    jp  z, asm_engine_ifend
;    /* If collectable, do something appropriate */
;    if (getcollectable) {
    ld  b,a
    and #0x10
    jp  z, collect_letters
;        if (getcollectable&0x10) {
    ld  a,b
    sub #0xb0
    jp  nz, collect_energy
;            // ITEMS
;            if (getcollectable==0xb0) {
    ld  hl,#_player_health
$1:
    ld  a,(hl)
    add a,#32   
;                // HEALTH
;                player_health += 32;
    cp  #0x80
    jp  c,set_player_health
    ld  a,#0x7f
;                if (player_health > 0x7f) {
;                    player_health = 0x7f;
set_player_health:
    ld  (hl),a
    jp  playsound_item
;                }

collect_energy:
    sub #4
    jp  nz, playsound_item ;; you collect a gem == do nothing
;            } else if (getcollectable==0xb4) {

    ld  hl,#_player_energy
    jp  $1
;    ld  a,(hl)
;    add a,#32   
;                // ENERGY
;                player_energy += 32;
;    cp  #0x80
;    jp  c, ; set_player_energy
;    ld  a,#0x7f
;                if (player_health > 0x7f) {
;                    player_health = 0x7f;
;set_player_energy:
;    ld  (hl),a
;    jp  asm_engine_ifend

;                if (player_energy > 0x7f) {
;                    player_energy = 0x7f;
;                }
;            }
playsound_item:
    ld  hl,#sound_no
    ld  (hl),#24
    ;call    startsnd
;            play_sound(24);
;        } else {
    jp  asm_engine_ifend
collect_letters:
;            // LETTERS
;            // CHECK : if (getcollectable==0xa0 && letterc==0) getcollectable = 0x9c;
;            // TODO : printletter();
    ld  hl,#_letters
    inc (hl)
;            letters++;

;            stop_sound(24);
    ld  a,(hl)
    sub #5
    jp  nc, get_all5letters
;            if (letters<5) {
    ld  hl,#sound_no
    ld  (hl),#22
    jp  asm_engine_ifend
;                play_sound(22);
;            } else {
get_all5letters:
    ;xor    a
    ld  hl,#_flag_letters
    ld  (hl),a
;                flag_letters = 0;
    ld  hl,#sound_no
    ld  (hl),#23
;                play_sound(23);
;            }
;        }
;    }

asm_engine_ifend:
;    length = 0;

    ld  a,(#_buffer_scr+369)
    and #0xfe
;    c = (buffer_scr[369]) & 0xfe;
    sub #0x9c    
    jp  nz,asm_engine_next
;    if (c==0x9c) {
    ld  hl,#_flag_end
    ld  (hl),#1    
;        flag_end = 1;
;    }

asm_engine_next:
    call _laserbeam
    call _player_joystick
    ;jp _update_playerstate
    ;jp  _ghostanim

    ld  a,(_keypad_1)
    sub #10    
    jp  z,pausing
    ld  a,(_keypad_2)
    sub #10
    jp  z,pausing    
    call startsnd
asm_engine_end:
    ld  a,#1
    ld  (#_flag_prout),a
    ret

pausing:
    ld  hl,#sound_no
    ld  (hl),#25
    call startsnd    
        ; play_sound(25);
pauseloop1:
    nop
    ld  a,(_keypad_1)
    sub #10    
    jp  z,pauseloop1
    ld  a,(_keypad_2)
    sub #10
    jp  z,pauseloop1
        ; while (keypad_1==10 || keypad_2==10) delay(0);

pauseloop2:
    nop
    ld  a,(_keypad_1)
    sub #10
    jp  z,pauseloop2_end
    ld  a,(_keypad_2)
    sub #10
    jp  nz,pauseloop2
        ; while (keypad_1!=10 && keypad_2!=10) delay(0);
pauseloop2_end:
    ld  hl,#sound_no
    ld  (hl),#25
    call startsnd
        ; play_sound(25);
pauseloop3:
    nop
    ld  a,(_keypad_1)
    sub #10    
    jp  z,pauseloop3
    ld  a,(_keypad_2)
    sub #10
    jp  z,pauseloop3
        ; while (keypad_1==10 || keypad_2==10) delay(0);
    jp  asm_engine_end
    
_laserbeam:

    xor a
    ld  hl,#_laser_x0
    ld  (hl),a

    or  #1
    ld  hl,#_dx
    
    cp (hl)
    ;   if (dx == 1)
    jp  nz, _laserbeamleft

_laserbeamright:

    ld  hl,#_buffer_scr+336
    ld  (hl),#0x00
    ld  hl,#_buffer_scr+368
    ld  (hl),#0x01
    ld  a,(#_pl_animframe)
    or  #192
    ld  hl,#_sprites+2
    ld  (hl),a
    ;        buffer_scr[336] = 0x00;
    ;        buffer_scr[368] = 0x01;
    ;        sprites[2] = 192 + pl_animframe;

    ld  a,(#_player_energy)
    or  a
    jr  z,nolaserbeanright
    ld  a,(#_joypad_1)
    and #0x80  ;; FIRE1
    jr  nz,laserbeanright
    ;         if ((player_energy>0) && joypad_1&FIRE1) {

nolaserbeanright:
    ld  hl,#_buffer_scr+337
    ld  (hl),#0x02
    ld  hl,#_buffer_scr+369
    ld  (hl),#0x04
    ret
    ;       else
    ;            buffer_scr[337] = 0x02;
    ;            buffer_scr[369] = 0x04;

laserbeanright:
    ld  de,#0x8f8f ;; 908f = 144, 143
    ld  hl,#_buffer_scr+370 ;; ptr_offset
    xor a
    ld  b,a
loop1:
    ld  a,b
    sub  #14
    jp z, endloop1
    ld  a,(hl)
    sub  #0xc0
    jp nc, endloop1
    ld  a,#0x10
    ld  (hl),a
    inc hl
    inc b
    ld  a,#8
    add a,e
    ld  e,a
    jp  loop1
endloop1:
    ld  hl,#_laser_x0
    ld  (hl),d
    ld  hl,#_laser_x1
    ld  (hl),e
;    ld  hl,#_length
;    ld  (hl),b
    ld  hl,#_buffer_scr+337
    ld  (hl),#0x03
    ld  hl,#_buffer_scr+369
    ld  (hl),#0x05
    ld  hl,#_player_energy
    dec (hl)    
    ret

;            byte *offset = &buffer_scr[370];
;            laser_x0 = 144;
;            laser_x1 = 143;
;            while (length<14 && *offset<0xc0) {
;                *offset = 0x10;
;                offset++;
;                length++;
;                laser_x1 += 8;
;            }
;            buffer_scr[337] = 0x03;
;            buffer_scr[369] = 0x05;
;            player_energy--;


_laserbeamleft:

    ld  hl,#_buffer_scr+338
    ld  (hl),#0x08
    ld  hl,#_buffer_scr+370
    ld  (hl),#0x09
    ld  a,(#_pl_animframe)
    or  #224
    ld  hl,#_sprites+2
    ld  (hl),a
    ;        buffer_scr[338] = 0x08;
    ;        buffer_scr[370] = 0x09;
    ;        sprites[2] = 224 + pl_animframe;

    ld  a,(#_player_energy)
    or  a
    jr  z,nolaserbeanleft
    ld  a,(#_joypad_1)
    and #0x80  ;; FIRE1
    jr  nz,laserbeanleft
    ;        if ((player_energy>0) && joypad_1&FIRE1) {

nolaserbeanleft:
    ld  hl,#_buffer_scr+337
    ld  (hl),#0x0a
    ld  hl,#_buffer_scr+369
    ld  (hl),#0x0c
    ret

        ; } else {
            ; buffer_scr[337] = 0x0a;
            ; buffer_scr[369] = 0x0c;
        ; }

laserbeanleft:
    ld  de,#0x8787 ;; 8887 = 136, 135
    ld  hl,#_buffer_scr+368 ;; ptr_offset
    xor a
    ld  b,a
loop2:
    ld  a,b
    sub  #16
    jp z, endloop2
    ld  a,(hl)
    sub  #0xc0
    jp nc, endloop2
    ld  a,#0x10
    ld  (hl),a
    dec hl
    inc b
    ld  a,#0xf8 ;; -8
    add a,d
    ld  d,a
    jp  loop2
endloop2:
    ld  hl,#_laser_x0
    ld  (hl),d
    ld  hl,#_laser_x1
    ld  (hl),e
;    ld  hl,#_length
;    ld  (hl),b
    ld  hl,#_buffer_scr+337
    ld  (hl),#0x0b
    ld  hl,#_buffer_scr+369
    ld  (hl),#0x0d
    ld  hl,#_player_energy
    dec (hl)    
    ret

;            byte *offset = &buffer_scr[368];
;            laser_x0 = 136;
;            laser_x1 = 135;
;            while (length<16 && *offset<0xc0) {
;                *offset = 0x10;
;                offset--;
;                length++;
;                laser_x0 -= 8;
;            }
;            buffer_scr[337] = 0x0b;
;            buffer_scr[369] = 0x0d;
;            player_energy--;


_player_joystick:
    ld  a,(#_joypad_1)
    bit 1,a
    jp  nz, joystick_right
;    /* Calculate Frame */
;    if (joypad_1&RIGHT) {
    bit 3,a
    jp  nz, joystick_left
;    if (joypad_1&LEFT) {
    ld  hl,#_pl_animframe
    xor a
    jp set_pl_animframe
    
joystick_right:
    ld  hl,#_buffer_scr+402
    ld  a,(hl)
    sub #0xc0
    jp  nc,direction_right
;        if (buffer_scr[402]<0xc0)
;        {
    ld  hl,#_camera+1
    ld  a,(hl)
    sub #225
    jp  z,direction_right
;            if (camera.x!=225) {
    inc (hl)
;                camera.x++;
    ld  hl,#_deplacement_x
    ld  a,(hl)
    sub #8
    ld  (hl),a
;                deplacement_x -= 8;
;            }
;        }
direction_right:
    ld  hl,#_dx
    ld  (hl),#1
;        dx = 1;
;    }
    jp update_legsanim

joystick_left:
    ld  hl,#_buffer_scr+400
    ld  a,(hl)
    sub #0xc0
    jp  nc,direction_left
;        if (buffer_scr[400]<0xc0)
;        {
    ld  hl,#_camera+1
    ld  a,(hl)
    or  a
    jp  z,direction_left
;            if (camera.x!=0) {
    dec (hl)
;                camera.x--;
    ld  hl,#_deplacement_x
    ld  a,(hl)
    add a,#8
    ld  (hl),a
;                deplacement_x += 8;
;            }
;        }
direction_left:
    ld  hl,#_dx
    ld  (hl),#0xff ;; = -1
;        dx = -1;
;    }
    ;jp update_legsanim

update_legsanim:
;    if (joypad_1&(LEFT|RIGHT)) {
    ld  hl,#_pl_animframe
    ld  a,(hl)
    add a,#4
;        pl_animframe += 4;
    cp  #32
    jp  nz,set_pl_animframe
    ld  a,#4
;        if (pl_animframe == 32) pl_animframe = 4;
;    } else {
;        pl_animframe = 0;
;    }
set_pl_animframe:
    ld  (hl),a

    ;ret
    
_update_playerstate:

;#define PLAYER_DEFAULT  0
;#define PLAYER_JUMP     1
;#define PLAYER_FALL     2

 ;   switch (player_state)
 ;   {
    ld  hl,#_player_state
    ld  a,(hl)
    or  a
    jp  nz, case1_jumporfall
;        case    PLAYER_DEFAULT:
;case1_default:
;case1_default_ifjump:
    ld  hl,#_JUMP_MASK
    ld  a,(#_joypad_1)
    and (hl)
    jp  nz, case1_default_jump
;            if (joypad_1&JUMP_MASK) {
    ld  hl,#_flag_saut
    ld  (hl),a
;                if (flag_saut) {
;                    flag_saut = 0;
;                }
;            }
;            } else {
case1_default_iffall:
    ld  hl,#_buffer_scr+433
    ld  a,(hl)
    sub #0xc0
    jp  nc, case2_default ;case1_default_ifjump
;            if (buffer_scr[433]<0xc0) {
    ld  hl,#_camera
    ld  a,(hl)
    sub #44
    jp  c, case2_fall
;                if (camera.y < 44) player_state = PLAYER_FALL;
    jp case2_default
case1_default_jump:
    ld  hl,#_flag_saut
    ld  a,(hl)
    or  a
    jp  nz,case1_default_iffall
    ld  (hl),#1
    jp  case2_jump_yes
;                if (flag_saut==0) {
;                    player_state = PLAYER_JUMP;
;                    flag_saut = 1;
;                }
;            }
;            break;

case1_jumporfall:
    sub #1
    jp  nz, case1_fall
;case1_jump:
;        case    PLAYER_JUMP:
    ld  hl,#_buffer_scr+305
    ld  a,(hl)
;            c = buffer_scr[305];
    sub #0xc0
    jp  c,case2_jump
    sub #0x10
    jp  nc,case2_jump
;            if (c>=0xc0 && c<0xd0) {
    jp  case2_fall    
;                player_state = PLAYER_FALL;
;            }
;            break;

case1_fall:
;        case    PLAYER_FALL:
;            /* if (flag_saut) {
;                if (joypad_1&JUMP_MASK == 0) {
;                    flag_saut = 0;
;                }
;            } */
    ld  hl,#_buffer_scr+433
    ld  a,(hl)
    sub #0xc0
    jp  c,case2_fall
;            if (buffer_scr[433]>=0xc0) {
    ld  hl,#_camera
    ld  a,(hl)
    and #0x7e
    ld  (hl),a
;                camera.y &= 0x7e;
    jp  case2_default
;                player_state = PLAYER_DEFAULT;
;            }
;            break;
;    }

 ;   switch (player_state)
 ;   {
 case2_default:
    ld  hl,#_player_state
    xor a
    ld  (hl),a ;; player_state = PLAYER_DEFAULT; /* = 0 */
 ;       case    PLAYER_DEFAULT:
    
    ld  a,(#_buffer_scr+433)
    and #0xf0
 ;           c = (buffer_scr[433])&0xf0;
    sub #0xe0
    jp  nz, case2_default_f0
;case2_default_e0:
 ;           if (c==0xe0) {
    ld  hl,#_deplacement_x
    ld  a,(hl)
    sub #8
    ld  (hl),a
 ;               deplacement_x -= 8;
    ld  hl,#_camera+1 ; &camera + 1 = &camera.x
    inc (hl)
 ;               camera.x++;
 ;           }
    jp  case2_default_end
case2_default_f0:
    sub #0x10
    jp  nz, case2_default_end
 ;           if (c==0xf0) {    
    ld  hl,#_deplacement_x
    ld  a,(hl)
    add a,#8
    ld  (hl),a
 ;               deplacement_x += 8;
    ld  hl,#_camera+1 ; &camera + 1 = &camera.x
    dec (hl)
 ;               camera.x--;
 ;           }
case2_default_end:
    ld  hl,#_saut
    xor a
    ld  (hl),a
 ;           saut = 0;
 ;           break;
    jp  case2_end ;;; ret

case2_jump:
 ;       case    PLAYER_JUMP:
    ld  hl,#_player_state
    ld  (hl),#2
 ;           player_state = PLAYER_FALL;

    ld  hl,#_JUMP_MASK
    ld  a,(#_joypad_1)
    and (hl)
    jp  z, case2_jump_no

case2_jump_yes:
 ;           if (joypad_1&JUMP_MASK) {
    ld  hl,#_camera
    ld  a,(hl)
    or  a
    jp  z, case2_end
 ;               if (camera.y) {
    ld  hl,#_saut
    ld  a,(hl)
    sub #10
    jp  nc, case2_end    
 ;                   if (saut<10) {
    inc (hl)
;                        saut++;
    ld  hl,#_deplacement_y
    ld  a,(hl)
    add a,#8
    ld  (hl),a
;                        deplacement_y += 8;
    ld  hl,#_camera
    dec (hl)
;                        camera.y--;
    ld  hl,#_player_state
    ld  (hl),#1
;                        player_state = PLAYER_JUMP;
;                    }
;                }
;            } else {
    jp  case2_end
    
case2_jump_no:
    xor a
    ld  hl,#_flag_saut
    ld  (hl),a
;                flag_saut = 0;
;            }
    jp  case2_end
;            break;
    
 case2_fall:
    ld  hl,#_player_state
    ld  (hl),#2 ;; player_state = PLAYER_FALL; /* = 2 */
 ;       case    PLAYER_FALL:
    ld  hl,#_camera
    ld  a,(hl)
    sub #44
    jp  nc,case2_fall_limit
 ;           if (camera.y < 44) {
    ld  hl,#_deplacement_y
    ld  a,(hl)
    sub #8
    ld  (hl),a
;                        deplacement_y -= 8;
    ld  hl,#_camera
    inc (hl)
;                        camera.y++;
    jp  case2_end  
 ;           } else {
case2_fall_limit:
    xor a
    ld  hl,#_player_state
    ld  (hl),a ;; player_state = PLAYER_DEFAULT; /* = 0 */
 ;               player_state = PLAYER_DEFAULT;
 ;           }
case2_end:
 ;           break;
;    }
;    ret

_ghostanim:

    ;ld  hl,#_sprites+8
    ;ld  a,(hl)
    ld  a,(#_sprites+8)
    sub #0xd0
    jp  z,_addghost

    ; if (sprites[8] != 0xd0)
    ; {    

    ld  hl,(#_GHOSTMOVEMENT)
    ld  de,(#_anim_position)
    add hl,de
    ld  b,(hl)
    inc hl
    ld  c,(hl)
    ld  hl,#_anim_position
    inc (hl)
    inc (hl)
    
    ld  de,(#_deplacement_y)

    ld  hl,#_sprites+4
    
    ld  a,(hl)
    add a,e
    add a,c
    ld  (hl),a
    
    inc hl
    
    ld  a,(hl)
    add a,d
    add a,b
    ld  (hl),a

        ; *spr_y1 += deplacement_y;
        ; *spr_x1 += deplacement_x; 
        
        ; *spr_y1 += GHOSTMOVEMENT[anim_position++];
        ; *spr_x1 += GHOSTMOVEMENT[anim_position++];
    
    ld  hl,#_sprites+9 ; spr2_x
    ld  a,(hl)
    ld  hl,#_sprites+5 ; spr1_x
    ;or  a
    sub #0xc0
    jp  nc,x2_high
    ;or  a
    sub #0x80
    jp  nc,x2_end
;x2_lower_40
    ld  a,(hl)
    sub #8
    bit 7,a
    jp  z,x2_end
;x2_lower_limit:
    ld  (hl),#8
    jp  x2_end
x2_high:
    ld  a,(hl)
    add a,#16
    bit 7,a
    jp  nz,x2_end
;x2_higher_limit:
    ld  (hl),#0xf0
    ;jp  x2_end

        ; if (*spr_x2 & 0x80) {
            ; if (*spr_x1 & 0x80) {
                ; if (*spr_x1 > -16) {
                    ; *spr_x1 = -16;   
                ; }
            ; }
            ; else {
                ; if (*spr_x1 < 8) *spr_x1 = -16;
            ; }
        ; } else {
            ; if (*spr_x1 & 0x80) {
                ; if (*spr_x1 > -16) *spr_x1 = 8;
            ; }
            ; else {
                ; if (*spr_x1 < 8) {
                    ; *spr_x1 = 8;   
                ; }
            ; }
        ; }  

x2_end:
    ld  a,(hl)
    ld  hl,#_sprites+9 ; spr2_x
    ld  (hl),a

        ; *spr_x2 = *spr_x1;

    ld  hl,#_sprites+8 ; spr2_y
    ld  a,(hl)
    ld  hl,#_sprites+4 ; spr1_y
    ;or  a
    sub #0x4b
    jp  nc,y2_high
    ;or  a
    sub #0xd8
    jp  nc,y2_end
;y2_lower_40
    ld  a,(hl)
    sub #15
    bit 7,a
    jp  z,y2_end
;y2_lower_limit:
    ld  (hl),#15
    jp  y2_end
y2_high:
    ld  a,(hl)
    add a,#0x69
    bit 7,a
    jp  nz,y2_end
;y2_higher_limit:
    ld  (hl),#0x97
    ;jp  y2_end

        ; if (*spr_y2 & 0x80) {
            ; if (*spr_y1 & 0x80) {
                ; if (*spr_y1 > -105) {
                    ; *spr_y1 = -105;   
                ; }
            ; }
            ; else {
                ; if (*spr_y1 < 15) *spr_y1 = -105;
            ; }
        ; } else {
            ; if (*spr_y1 & 0x80) {
                ; if (*spr_y1 > -105) *spr_y1 = 15;
            ; }
            ; else {
                ; if (*spr_y1 < 15) {
                    ; *spr_y1 = 15;   
                ; }
            ; }
        ; }  

y2_end:
    ld  a,(hl)
    ld  hl,#_sprites+8 ; spr2_y
    ld  (hl),a

        ; *spr_y2 = *spr_y1;
        
    ld  hl,#_anim_position
    ld  a,(hl)
    and #0x0c
    ld  c,a
    
    ld  hl,#_sprites+5
    bit 7,(hl)
    jp  z,facingright
;facingleft
    ld  hl,#_sprites+6
    ld  a,(hl)
    or  #0x20
    and #0xf0
    or  c
    ld  (hl),a
    add a,#0x10
    ld  hl,#_sprites+10
    ld  (hl),a
    jp  facingend
facingright:
    ld  hl,#_sprites+6
    ld  a,(hl)
    and  #0xdf
    and #0xf0
    or  c
    ld  (hl),a
    add a,#0x10
    ld  hl,#_sprites+10
    ld  (hl),a
facingend:

        ; if (*spr_x1 & 0x80) {
            ; sprites[6] |= 0x20;
            ; sprites[10] |= 0x20;
        ; } else {
            ; sprites[6] &= 0xdf;
            ; sprites[10] &= 0xdf;
        ; }

        ; sprites[6] = (sprites[6] & 0xf0) | ((char)anim_position & 0x0c);
        ; sprites[10] = (sprites[10] & 0xf0) | ((char)anim_position & 0x0c);


    ld  hl,#_anim_position
    ld  a,(hl)
    or  a
    jp  nz,anim_adjust_end
    inc hl
    inc (hl)
    ld  a,(hl)
    sub #2
    jp  nz,anim_adjust_end
    ld  (hl),a
    ld  hl,#_player_energy
    ld  a,(hl)
    add a,#8
    bit 7,a
    jp  z,anim_adjust_end0
    ld  a,#0x7f
anim_adjust_end0:
    ld  (hl),a
anim_adjust_end:

        ; if (anim_position == 512) {
            ; player_energy+=8;
            ; if (player_energy > 0x7f) {
                ; player_energy=0x7f;
            ; }
            ; anim_position = 0;
        ; }

    ld  hl,#_laser_x0
    ld  a,(hl)
    or  a
    jp  z,laserghost_end
        ; // IF HIT DETECTION BETWEEN LASER AND GHOST    
        ; if ( laser_x0 ) { // length>0) { //joypad_1&FIRE1) {
    ld  hl,#_sprites+5
    cp  (hl)
    jp  nc,laserghost_end
    ld  a,(hl)
    ld  hl,#_laser_x1
    cp  (hl)
    jp  nc,laserghost_end    
    ld  hl,#_sprites+4
    ld  a,(hl)
    sub #80
    jp  c,laserghost_end
    sub #24 ; 104-80 = 24
    jp nc,laserghost_end
    
            ; if (sprites[4]>=84 && sprites[4]<=108 && sprites[5]>=laser_x0 && sprites[5]<=laser_x1)
            ; {
            
    ld  hl,#sound_no
    ld  (hl),#26
            ;;;
                ; play_sound(26);

    ld  hl,#_ghost_e1
    xor a
    cp  (hl)
    jp  z,notghost_e1
    dec (hl)
    cp  (hl)
    jp  nz,notghost_e1
    ld  de,#_sprites+7
    ld  (de),a
                ; if (ghost_e1>0) {
                    ; ghost_e1--;
                    ; if (ghost_e1==0) {
                        ; sprites[7] = 0;
                    ; }
                ; }
notghost_e1:
    inc hl
    cp (hl)
    jp  z,notghost_e2
    dec (hl)
    cp (hl)
    jp  nz,notghost_e2
    ;ld  de,#_sprites+11
    ;ld  (de),a
                ; if (ghost_e2>0) {
                    ; ghost_e2--;
                    ; if (ghost_e2==0) {
                        ; sprites[11] = 0;
                    ; }
                ; }
    ld  hl,#_sprites+8
    ld  (hl),#0xd0
    
    ld  hl,#_anim_position
    ld  (hl),#64
    
    ;ld  e,#28
    ;call    startsnd
                ; if (sprites[7] == 0 && sprites[11] == 0) {
                    ; //sprites[4] = 0xd0;
                    ; sprites[8] = 0xd0;
                    ; play_sound(28);
                ; }
notghost_e2:
            ; }
        ; }
        
laserghost_end:

    ld  hl,#_sprites+4
    ld  a,(hl)
    sub #76
    jp  c, avoidplayer
    sub #40
    jp  nc, avoidplayer
    ld  hl,#_dx
    bit 7,(hl)
    ld  hl,#_sprites+5
    jp  nz, playerfacingleft
;playerfacingright:
    ld  a,(hl)
    sub #116
    jp  c, avoidplayer
    jp  playerfacingleft2
playerfacingleft:
    ld  a,(hl)
    sub #124
    jp  c, avoidplayer
playerfacingleft2:
    sub #28
    jp  nc, avoidplayer
    ;;; HIT PLAYER
    ld  hl,#_player_health
    ld  de,(#_level_number)
    ld  a,(hl)
    inc e
    sub e
    jp  nc, playerlifenotbad1
    xor a
playerlifenotbad1:
    ld  (hl),a
    jp nz, playerlifenotbad2
    ld  hl,#_flag_end
    ld  (hl),#1
playerlifenotbad2:
    ld  hl,#sound_no
    ld  (hl),#27
    ret
avoidplayer:
        ; // IF HIT WITH PLAYER
        ; if (sprites[4]>=76 && sprites[4]<=116) {
            ; if  (dx == 1) {
                ; if (sprites[5]>=116 && sprites[5]<=148) {
                    ; if (player_health <= level_number) {
                        ; player_health = 0;
                    ; } else `{
                        ; player_health -= (level_number + 1);
                    ; }
                    ; play_sound(27);
                    ; if (player_health == 0) flag_end = 1;
                ; }
            ; } else {
                ; if (sprites[5]>=124 && sprites[5]<=156) {
                    ; if (player_health <= level_number) {
                        ; player_health = 0;
                    ; } else `{
                        ; player_health -= (level_number + 1);
                    ; }
                    ; play_sound(27);
                    ; if (player_health == 0) flag_end = 1;
                ; }
            ; }
        ; }
        
    ; } else {

        ; addghost();
        
    ; }
    
    ret


;;; SIZE 30578
;;; SIZE 29821

;;; SIZE 30909
;;; SIZE 30825
;;; SIZE 30738

;;; SIZE 30754

;;; SIZE 30576

;;; SIZE 30619

_addghost:
    ld  hl,#_sprites+7
    ld  (hl),#15 ;; sprite 0 color white
    
    ld  a,(#_ghost_counter)
    or  a
    jp  nz,ghostmorph

;        if (ghost_counter > 0) {

ghostexplode:

    ld  hl,#_anim_position
    ld  a,(hl)
    cp  #128+2
    ret z
    inc (hl)
    inc (hl)
    and #0xfc
    ld  hl,#_sprites+6
    ld  (hl),a ;; sprite 0 patterns = spiral and explosion
    sub #64
    ret nz
    
    ld  hl,#sound_no
    ld  (hl),#28
    ret
    
ghostmorph:

    ld  hl,#_anim_position
    ld  a,(hl)
    cp  #96
    jp z,addghost
    inc (hl)
    inc (hl)
    and #0xfc
    ld  hl,#_sprites+6
    ld  (hl),a ;; sprite 0 patterns = spiral
    ret

addghost:
    ld  de,#_sprites+8
    ld  hl,#_sprites+4
    ld  a,#15
    ld  (hl),a
    ld  (de),a
    inc hl
    inc de
    ld  a,#124
    ld  (hl),a
    ld  (de),a
    inc hl
    inc de
    xor a
    ld  (hl),a
    ld  a,#16
    ld  (de),a
    inc hl
    inc de   
    ld  bc,(#_GHOSTCOLOR1)
    ld  (hl),c
    ex  de,hl
    ld  (hl),b
    
    
;    ld  a,#15
;    ld  hl,#_sprites+4
;    ld  (hl),a
;    ld  hl,#_sprites+8
;    ld  (hl),a
;
;    ld  a,#124
;    ld  hl,#_sprites+5
;    ld  (hl),a
;    ld  hl,#_sprites+9
;    ld  (hl),a
 ;   
 ;   xor a
 ;   ld  hl,#_sprites+6
 ;   ld  (hl),a
 ;   ld  a,#16
 ;   ld  hl,#_sprites+10
 ;   ld  (hl),a

;    ld  de,(#_GHOSTCOLOR1)
;    
;    ld  hl,#_sprites+7
;    ld  (hl),e
;    ld  hl,#_sprites+11
;    ld  (hl),d

    ld  hl,(#_GHOSTENERGY1)
    ld  (#_ghost_e1),hl
        
    xor a
    ld  hl,#_anim_position
    ld  (hl),a
    inc hl
    ld  (hl),a
    ld  hl,#_ghost_counter
    dec (hl)

    ld  hl,#sound_no
    ld  (hl),#25
    ret
    
;            sprites[4] = 15; // 15 - 151
;            sprites[5] = 124; // 8 - 240
;            sprites[6] = 0;
;            sprites[7] = GHOSTCOLOR1;
;            sprites[8] = 15; // 15 - 151
;            sprites[9] = 124; // 8 - 240
;            sprites[10] = 16;
;            sprites[11] = GHOSTCOLOR2;
;            
;            ghost_e1 = GHOSTENERGY1;
;            ghost_e2 = GHOSTENERGY2;
;            
;            anim_position = 0;
;            ghost_counter--;
;            
;            play_sound(25);
;        }

; startsnd
; parameter : e = #
;
; Almost everything is scrap after the call

startsnd:

    ; ld  hl,#sound_no
    ; ld  a,(hl)
    ; or  a
    ; ret z
    
    ; push    ix
    ; push    iy

    ; ld      b,a
    ; call	0x1ff1

    ; pop     iy
    ; pop     ix
    ; ret

    ld  hl,#sound_no
    ld  a,(hl)
    or  a
    ret z
    ld      b,a

    ld  hl,#0x7026
    ld  (hl),#0x53
    inc hl
    ld  (hl),#0x70
    
    ld  hl,(#0x7020)
    ld  e,b
    dec e
    rlc e
    rlc e
    ld  d,#0
    add hl,de
    ld  e,(hl)
    inc hl
    ld  d,(hl)
    ld  hl,#0x705c
    xor a
    ld  (hl),a
    dec hl
    ld  (hl),a
    dec hl
    ld  (hl),a
    dec hl
    ld  (hl),a
    dec hl
    or  #1
    ld  (hl),a
    dec hl
    or  #0xf0
    ld  (hl),a
    dec hl
    ld  (hl),a
    dec hl
    ld  (hl),d
    dec hl
    ld  (hl),e
    dec hl
    ld  a,b
    or  #0x80
    ld  (hl),a
    
    ret
    
_wait_displayed:
    nop
    ld  a,(#_flag_prout)
    or  a
    jp  nz,_wait_displayed
    ret
    ; while (flag_prout!=0) delay(0);
    