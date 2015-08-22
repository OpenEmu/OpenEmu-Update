;lander2
;
;Copyright (C) 2014-2015  jmimu (jmimu@free.fr)
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;==============================================================


;==============================================================
; WLA-DX banking setup
; Note that this is a frame 2-only setup, allowing large data
; chunks in the first 32KB.
;==============================================================
.memorymap
   defaultslot 0
   ; ROM area
   slotsize        $C000
   slot            0       $0000
   ; RAM area
   slotsize        $2000
   slot            1       $C000
   slot            2       $E000
.endme

.rombankmap
   bankstotal 1
   banksize $C000
   banks 1
.endro




;==============================================================
; constants
;==============================================================
;demo
.define forest_1st_tile $2
.define forest_scroll_1st_tile_from_forest_start $58
.define forest_anim_steps $8
.define bike_tile_number $3C
.define bike_pedal_tile_number $4E
.define bike_pedal_anim_steps $4

;game
.define digits_tile_number $10 ;position of "0" in vram
.define fire_tile_number $5F
.define explosion_tile_number $63
.define fuel_tile_number $7D
.define normal_rocket_tile_number $69 ;big rocket starts at rocket_tile_number, small at rocket_tile_number+2
.define fire_rocket_tile_number $71 ;big rocket starts at rocket_tile_number, small at rocket_tile_number+2
.define guy_tile_number $79
.define bubble_bottom_tile_number $7F
.define bubble_left_tile_number $83
.define bubble_right_tile_number $85
.define bubble_down_tile_number $81

.define diff_tile_ascii 32 ;difference between index in tiles and in ascii ("A" tile number -65)
.define number_of_levels 11

;==============================================================
; RAM section
;==============================================================
.ramsection "variables" slot 1
  new_frame                     db ; 0: no; 1: yes
  PauseFlag db ;1 if pause
  ;demo variables
  forest_anim_step dw;from 0 to forest_anim_steps*$100
  pedal_anim_step dw;from 0 to forest_anim_steps*$100
  Xscroll dw
  Xscroll_speed dw
  demo_step_counter       db  ; counterof current speed
  demo_step               dw  ;pointer in Demo_Bike_Speed
  
  
  ;game
  posX                     dw ; multiplied by 2^8
  posY                     dw ; multiplied by 2^8
  speedX                     dw ; multiplied by 2^8
  speedY                     dw ; multiplied by 2^8
  rocket_fuel         dw 
  rocket_fuel_level_start  dw ;save rocket_fuel at level start
  rocket_status      db ;0: normal, 1: bottom fire, 2: destroyed
  buttons      db ; keep a copy of the buttons pressed
  current_level db
  difficulty_level db
  nb_lives db ; number of lives
  already_lost db ;0 if not, 1 if lost at least 1 time
  score   dw
  hiscore dw
;  goto_level db ;0 if no need to change level, n to enter level n
  star_color1 dw ;color used: bright and yellow
  star_color2 dw ;color used: bright and yellow
  landing_zone_color dw; loop between 4 colors (hi-byte is color index)
  ;PauseFlag db ;1 if pause
  tiles_vram_used   dw ; number of tiles in vram (where to add next tiles)
  
  
  ;difficulty settings
  fuel_use dw;$-70
  speed_pos_tolerance dw;$40
  speed_neg_tolerance dw;-$40
  Xdumping         dw;0
  refuel           db;0=no, 1=true
  big_rocket     db;0=no, 1=true
.ends


;==============================================================
; SDSC tag and SMS rom header
;==============================================================
.sdsctag 1.2,"Lander2","Lander2 v0.C","jmimu"

.bank 0 slot 0
.org $0000
;==============================================================
; Boot section
;==============================================================
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    jp main         ; jump to main program


.org $0038
;==============================================================
; Vertical Blank interrupt
;==============================================================
    push af
      in a,($bf);clears the interrupt request line from the VDP chip and provides VDP information
      ;do something only if vblank (we have only vblank interrupt, so nothing to do)     
      ld a,1
      ld (new_frame),a
    pop af
    ei ;re-enable interrupt
    reti


.org $0066
;==============================================================
; Pause button handler
;==============================================================
    push af
      ld a,(PauseFlag) ;taken from Heliophobe's SMS Tetris 
      xor $1  ;Just a quick toggle
      ld (PauseFlag),a
    pop af
  retn


.org    $0080 ;Mapper initialization
init:
        ; This maps the first 48K of ROM to $0000-$BFFF
        ld      de, $FFFC
        ld      hl, init_tab
        ld      bc, $0004
        ldir
        jp      main

init_tab: ; Table must exist within first 1K of ROM
        .db     $00, $00, $01, $02

;inclusions
.include "fnc_sound.inc"

.section "misc" free
.include "fnc_init.inc"
.include "fnc_demo.inc"
.include "fnc_text.inc"
.include "fnc_loop.inc"
.ends

.include "fnc_game.inc"
.include "fnc_sprites.inc"

.section "main" free
;==============================================================
; Main program
;==============================================================
main:
    ld sp, $dff0 ;where stack ends ;$dff0
    
    xor a
    ld (PauseFlag),a
    
    ld hl,WaitForVBlankSimple
    ld (WaitForVBlankFunction),hl

    ;==============================================================
    ; Set up VDP registers
    ;==============================================================
    call initVDP
    
    ld hl,0
    ld (hiscore),hl

demo:
    call CutAllSound
    ld hl,0
    ld (score),hl
    
    call InitializeJmimu
    
    ;run demo
    call InitializeDemo
    call RunDemo

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
    
    jp ShowMenu
    
end:
  jr end


;button to test in b
;ex for pad 1:
; Button 1 = %00100000 
; Button 2 = %00010000 
; up    = %00000001 
; down  = %00000010 
; left  = %00000100 
; right = %00001000 
;output: zero flag (jp nz,???)
IsButtonPressed:
    in a,($dc)
    and b
    cp  %00100000
    ret

.ends

;==============================================================
; Data
;==============================================================
;.bank 1 slot 0
.section "assets_demo" free
.include "data_jmimu.inc"
.include "data_demo.inc"
.include "menu.inc"
.ends




.org $7ff0
;we have to skip the $7ff0-$7fff area for the ROM header
ROM_header:
.org $8000

.include "level1.inc"

.include "level2.inc"

.include "level5.inc"

.include "level10.inc"

.include "end.inc"


;.bank 2 slot 0
.section "assets_game" free
.include "data_game.inc"
.ends




