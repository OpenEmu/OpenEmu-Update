; blocks.s

		.module blocks

		.globl  _MOON1_NAME ; from C source code
		.globl  _MOON2_NAME ; from C source code

		.globl  _buffer_scr ; from C source code
		.globl  _camera     ; from C source code

        .globl  _getcollectable ; from C source code

        .globl _flag_prout
        
        .globl _flag_letters
        
        .globl  _sprites
        .globl  _bar
        .globl  _player_energy
        .globl  _player_health

        ; void blocks();
		.globl  _blocks
        ; void toscreen();
		.globl  _toscreen
        ; void wipeout_asm();
        .globl  _wipeout_asm
        ; void getlevelvram();
        .globl  _getlevelvram
        
    .AREA   _DATA
anim_counter:
        .ds     2
        
letter_c:
        .ds     1
        
    .AREA   _CODE

_blocks:
            ;; Update animation counter
            ld   a,(#anim_counter)
            inc  a
            inc  a
            ld   (#anim_counter),a
            and  #0x0c
            ld   (#anim_counter+1),a

            exx
            push    hl
            push    de

            xor a
            ld  d,a
            ld  hl,#_camera
            ld  a,(hl)
            rla            
            rla
            rla
            rl  d
            rla
            rl  d
            and #0xe0
            inc hl
            bit 0,(hl)
            jp  nz,$01
            or  #1
$01:
            dec hl
            bit 0,(hl)
            jp  nz,$02
            ld  hl,#_MOON2_NAME
            jp  $03            
$02:
            ld  hl,#_MOON1_NAME
$03:
            ld  e,a
            
            add hl,de            
            exx
            
            ld  hl,#_camera
            xor a
            ld  d,a
            bit 0,(hl)
            jp  nz,$1
            or  #32
$1:
            inc hl
            bit 0,(hl)
            jp  nz,$2
            or  #1
$2:
            ld  e,a
            ld  hl,#_buffer_scr
            add hl,de
            ld  de,#_buffer_scr+673-160

            ld  b,#10
$3:
            push    bc
            ld  b,#16
$4:
            ld  a,(de)
            inc de
            push    de
            or  a
            jr nz,$5

            ;;; Computing a transparent (night sky) 2x2 block
            push    hl
            exx
            pop de

            ldi
            ldi

            push    hl

            ld  bc,#0x001e
            add hl,bc
            ex  de,hl
            add hl,bc
            ex  de,hl

            ldi
            ldi

            pop hl

            exx

            inc hl
            inc hl

            jp  $6

            ;;; Before computing the 2x2 block...
$5:         ;;; If it's a block to be animated (E0-FF)
            cp #0xdf
            jr c,$5b
$5a:
            ;; Apply animation to symbols E0 {E0,E4,E8,EC} and F0 {F0,F4,F8,FC}
            ld de,(#anim_counter)
            or d
            jp  $5d
$5b:
            ;;; If it's the real exit
            cp  #0x9f
            jp  nc,$5d
            cp  #0x97
            jp  c,$5d
$5c:
            ;;; then add flag_letters value to open-close the exit
            push   hl
            ld  hl,#_flag_letters
            add a,(hl)
            pop hl
$5d:
            ld  de,#0x001f
            ld  (hl),a
            inc a
            inc hl
            ld  (hl),a
            inc a
            push    hl
            add hl,de
            ld  (hl),a
            inc a
            inc hl
            ld  (hl),a
            pop hl
            inc hl
            
            exx
            inc hl
            inc hl
            exx
$6:
            pop de
            djnz    $4
            push    de
            ld  de,#0x0020
            add hl,de
            
            exx
            ld  de,#0x0020
            add hl,de
            exx
            
            pop de
            pop bc
            djnz    $3
            
            ld  a,#0x20
            ld  hl,#_buffer_scr+64
            ld  de,#0x0020
            ld  b,#18
$7:
            ld  (hl),a
            add hl,de
            djnz    $7
            
            ;exx
            pop de
            pop hl
            ;exx
            
            ret
            
;       The following code replace this => put_vram(0x1840,buffer_scr+32,640-32);
_toscreen:
            di
            ld  a,#0x41
            out (0xbf),a
            ld  a,#0x58
            out (0xbf),a
            ei
            ld  hl,#_buffer_scr+33
            ld  bc,#0x5fbe
            di
            otir
            otir
            otir
            ei
            ret

;       The following code is to sipeout the game screen when reaching the exit
_wipeout_asm:
            ld  de,#wipe_effect_table
wipeout_loop1:
            ld  hl,#_flag_prout
            inc (hl)
wipeout_wait:
            nop
            ld a,(hl)
            or  a
            jp  nz,wipeout_wait
            ex  de,hl
            ld a,(hl)
            inc hl
            or  a
            ret z
            ld  b,a
wipeout_loop2:            
            ld  e,(hl)
            inc hl
            ld  d,(hl)
            inc hl
            push    hl
            ld  hl,#_buffer_scr
            add hl,de
            ld a,#0x20
            ld  (hl),a
            pop hl
            djnz    wipeout_loop2
            ex  de,hl
            jp wipeout_loop1

wipe_effect_table:
    ; ; DIAMOND
    .db #1
    .dw #33
    .db #4
    .dw #34,#63,#65,#609
    .db #8
    .dw #35,#62,#66,#95,#97,#577,#610,#639
    .db #12
    .dw #36,#61,#67,#94,#98,#127,#129,#545,#578,#607,#611,#638
    .db #16
    .dw #37,#60,#68,#93,#99,#126,#130,#159,#161,#513,#546,#575,#579,#606,#612,#637
    .db #20
    .dw #38,#59,#69,#92,#100,#125,#131,#158,#162,#191,#193,#481,#514,#543,#547,#574,#580,#605,#613,#636
    .db #24
    .dw #39,#58,#70,#91,#101,#124,#132,#157,#163,#190,#194,#223,#225,#449,#482,#511,#515,#542,#548,#573,#581,#604,#614,#635
    .db #28
    .dw #40,#57,#71,#90,#102,#123,#133,#156,#164,#189,#195,#222,#226,#255,#257,#417,#450,#479,#483,#510,#516,#541,#549,#572,#582,#603,#615,#634
    .db #32
    .dw #41,#56,#72,#89,#103,#122,#134,#155,#165,#188,#196,#221,#227,#254,#258,#287,#289,#385,#418,#447,#451,#478,#484,#509,#517,#540,#550,#571,#583,#602,#616,#633
    .db #36
    .dw #42,#55,#73,#88,#104,#121,#135,#154,#166,#187,#197,#220,#228,#253,#259,#286,#290,#319,#321,#353,#386,#415,#419,#446,#452,#477,#485,#508,#518,#539,#551,#570,#584,#601,#617,#632
    .db #38
    .dw #43,#54,#74,#87,#105,#120,#136,#153,#167,#186,#198,#219,#229,#252,#260,#285,#291,#318,#322,#351,#354,#383,#387,#414,#420,#445,#453,#476,#486,#507,#519,#538,#552,#569,#585,#600,#618,#631
    .db #38
    .dw #44,#53,#75,#86,#106,#119,#137,#152,#168,#185,#199,#218,#230,#251,#261,#284,#292,#317,#323,#350,#355,#382,#388,#413,#421,#444,#454,#475,#487,#506,#520,#537,#553,#568,#586,#599,#619,#630
    .db #38
    .dw #45,#52,#76,#85,#107,#118,#138,#151,#169,#184,#200,#217,#231,#250,#262,#283,#293,#316,#324,#349,#356,#381,#389,#412,#422,#443,#455,#474,#488,#505,#521,#536,#554,#567,#587,#598,#620,#629
    .db #38
    .dw #46,#51,#77,#84,#108,#117,#139,#150,#170,#183,#201,#216,#232,#249,#263,#282,#294,#315,#325,#348,#357,#380,#390,#411,#423,#442,#456,#473,#489,#504,#522,#535,#555,#566,#588,#597,#621,#628
    .db #38
    .dw #47,#50,#78,#83,#109,#116,#140,#149,#171,#182,#202,#215,#233,#248,#264,#281,#295,#314,#326,#347,#358,#379,#391,#410,#424,#441,#457,#472,#490,#503,#523,#534,#556,#565,#589,#596,#622,#627
    .db #38
    .dw #48,#49,#79,#82,#110,#115,#141,#148,#172,#181,#203,#214,#234,#247,#265,#280,#296,#313,#327,#346,#359,#378,#392,#409,#425,#440,#458,#471,#491,#502,#524,#533,#557,#564,#590,#595,#623,#626
    .db #36
    .dw #80,#81,#111,#114,#142,#147,#173,#180,#204,#213,#235,#246,#266,#279,#297,#312,#328,#345,#360,#377,#393,#408,#426,#439,#459,#470,#492,#501,#525,#532,#558,#563,#591,#594,#624,#625
    .db #32
    .dw #112,#113,#143,#146,#174,#179,#205,#212,#236,#245,#267,#278,#298,#311,#329,#344,#361,#376,#394,#407,#427,#438,#460,#469,#493,#500,#526,#531,#559,#562,#592,#593
    .db #28
    .dw #144,#145,#175,#178,#206,#211,#237,#244,#268,#277,#299,#310,#330,#343,#362,#375,#395,#406,#428,#437,#461,#468,#494,#499,#527,#530,#560,#561
    .db #24
    .dw #176,#177,#207,#210,#238,#243,#269,#276,#300,#309,#331,#342,#363,#374,#396,#405,#429,#436,#462,#467,#495,#498,#528,#529
    .db #20
    .dw #208,#209,#239,#242,#270,#275,#301,#308,#332,#341,#364,#373,#397,#404,#430,#435,#463,#466,#496,#497
    .db #16
    .dw #240,#241,#271,#274,#302,#307,#333,#340,#365,#372,#398,#403,#431,#434,#464,#465
    .db #12
    .dw #272,#273,#303,#306,#334,#339,#366,#371,#399,#402,#432,#433
    .db #8
    .dw #304,#305,#335,#338,#367,#370,#400,#401
    .db #4
    .dw #336,#337,#368,#369
    .db #0
    
    ; ; CIRCLE
    ; .db #1
    ; .dw #33
    ; .db #6
    ; .dw #34,#63,#65,#97,#577,#609
    ; .db #16
    ; .dw #35,#62,#66,#95,#98,#127,#129,#161,#193,#481,#513,#545,#578,#607,#610,#639
    ; .db #34
    ; .dw #36,#61,#67,#68,#93,#94,#99,#126,#130,#159,#162,#191,#194,#223,#225,#257,#289,#321,#353,#385,#417,#449,#482,#511,#514,#543,#546,#575,#579,#606,#611,#612,#637,#638
    ; .db #44
    ; .dw #37,#38,#59,#60,#69,#92,#100,#125,#131,#132,#157,#158,#163,#190,#195,#222,#226,#255,#258,#287,#290,#319,#322,#351,#354,#383,#386,#415,#418,#447,#450,#479,#483,#510,#515,#542,#547,#548,#573,#574,#580,#605,#613,#636
    ; .db #38
    ; .dw #39,#58,#70,#91,#101,#124,#133,#156,#164,#189,#196,#221,#227,#254,#259,#286,#291,#318,#323,#350,#355,#382,#387,#414,#419,#446,#451,#478,#484,#509,#516,#541,#549,#572,#581,#604,#614,#635
    ; .db #52
    ; .dw #40,#41,#56,#57,#71,#72,#89,#90,#102,#103,#122,#123,#134,#155,#165,#188,#197,#220,#228,#229,#252,#253,#260,#285,#292,#317,#324,#349,#356,#381,#388,#413,#420,#445,#452,#453,#476,#477,#485,#508,#517,#540,#550,#571,#582,#583,#602,#603,#615,#616,#633,#634
    ; .db #38
    ; .dw #42,#55,#73,#88,#104,#121,#135,#154,#166,#187,#198,#219,#230,#251,#261,#284,#293,#316,#325,#348,#357,#380,#389,#412,#421,#444,#454,#475,#486,#507,#518,#539,#551,#570,#584,#601,#617,#632
    ; .db #50
    ; .dw #43,#44,#45,#52,#53,#54,#74,#75,#86,#87,#105,#120,#136,#153,#167,#168,#185,#186,#199,#218,#231,#250,#262,#283,#294,#315,#326,#347,#358,#379,#390,#411,#422,#443,#455,#474,#487,#506,#519,#520,#537,#538,#552,#569,#585,#600,#618,#619,#630,#631
    ; .db #54
    ; .dw #46,#47,#48,#49,#50,#51,#76,#77,#84,#85,#106,#107,#118,#119,#137,#138,#151,#152,#169,#184,#200,#217,#232,#249,#263,#282,#295,#314,#327,#346,#359,#378,#391,#410,#423,#442,#456,#473,#488,#505,#521,#536,#553,#554,#567,#568,#586,#587,#598,#599,#620,#621,#628,#629
    ; .db #48
    ; .dw #78,#79,#80,#81,#82,#83,#108,#109,#116,#117,#139,#150,#170,#183,#201,#216,#233,#248,#264,#281,#296,#313,#328,#345,#360,#377,#392,#409,#424,#441,#457,#472,#489,#504,#522,#535,#555,#566,#588,#589,#596,#597,#622,#623,#624,#625,#626,#627
    ; .db #52
    ; .dw #110,#111,#112,#113,#114,#115,#140,#141,#148,#149,#171,#172,#181,#182,#202,#203,#214,#215,#234,#247,#265,#280,#297,#312,#329,#344,#361,#376,#393,#408,#425,#440,#458,#471,#490,#491,#502,#503,#523,#524,#533,#534,#556,#557,#564,#565,#590,#591,#592,#593,#594,#595
    ; .db #44
    ; .dw #142,#143,#144,#145,#146,#147,#173,#174,#179,#180,#204,#213,#235,#246,#266,#267,#278,#279,#298,#311,#330,#343,#362,#375,#394,#407,#426,#427,#438,#439,#459,#470,#492,#501,#525,#526,#531,#532,#558,#559,#560,#561,#562,#563
    ; .db #32
    ; .dw #175,#176,#177,#178,#205,#206,#211,#212,#236,#245,#268,#277,#299,#310,#331,#342,#363,#374,#395,#406,#428,#437,#460,#469,#493,#494,#499,#500,#527,#528,#529,#530
    ; .db #28
    ; .dw #207,#208,#209,#210,#237,#238,#243,#244,#269,#276,#300,#309,#332,#341,#364,#373,#396,#405,#429,#436,#461,#462,#467,#468,#495,#496,#497,#498
    ; .db #20
    ; .dw #239,#240,#241,#242,#270,#275,#301,#308,#333,#340,#365,#372,#397,#404,#430,#435,#463,#464,#465,#466
    ; .db #20
    ; .dw #271,#272,#273,#274,#302,#303,#306,#307,#334,#339,#366,#371,#398,#399,#402,#403,#431,#432,#433,#434
    ; .db #8
    ; .dw #304,#305,#335,#338,#367,#370,#400,#401
    ; .db #4
    ; .dw #336,#337,#368,#369
    ; .db #0
    
;       Get 10 times 16 bytes from VRAM based on camera position. 
_getlevelvram:
            ; Calculate level data position in VRAM
            ; hl = 2800 + (camera.y<<6) + (camera.x>>1)
            ld  hl,#0x2800
            ld  a,(#_camera)
            bit 1,a
            jr  z,$8
            ld  l,#0x80
$8:
            rrca
            rrca
            and #0x3f
            ld  d,a
            ld  a,(#_camera+1)
            rrca
            and #0x7f
            ld  e,a
            add hl,de

            ; DE = VRAM LEVEL ADDR
            ex  de,hl
            
            ;;; JUNE 18
            push    de ;; SAVE VRAM ADDR
            ;;;
            
            ; B = NUMBER OF LINES TO READ
            ld  b,#10
            
            ; HL = RAM BUFFER ADDR
            ld  hl,#_buffer_scr+673-160 ; start addr ram buffer
            
            ; LOOP TO GET DATA FROM VRAM
$9:
            push    bc
            push    hl
            
            ; SETUP READ FROM DE VRAM ADDR
            di
            ld  a,e
            out(0xbf),a
            ld  a,d
            out(0xbf),a
            ei
            
            ; UPDATE DE ADDR FOR NEXT TIME
            ld  hl,#128
            add hl,de
            ex  de,hl

            ; SAVE VRAM INTO HL RAM ADDR
            pop hl
            ld  bc,#0x10be
            di
            inir
            ei
            
            pop bc
            djnz    $9
            
            ;;; JUNE 18
            pop hl  ;; POP VRAM ADDRESS   
            
            ld  a,(#_buffer_scr+673-160+88)
            sub a,#0xa0
            jr  c,$11   ;; if it's not a collectable, do nothing
            jp  nz,$9b
            ld  a,(#letter_c)
            or  a
            jr  z, $9a
            xor a
            ld  (#letter_c),a
            jp  $9b
$9a:
            ld  a,#0xfc
            ld  (#letter_c),a
            xor a
$9b:
            sub a,#0x20
            jr  nc,$11  ;; if it's not a collectable, do nothing
            and #0xbf
            ld  (_getcollectable),a

            push    hl

            cp  #0xa0
            jp  nz, $9c
            ld  hl,#letter_c
            add a,(hl)
$9c:
            
            add #0xc0
            rrca
            rrca
            and #0x1f
            push    af
            add #0xb7
            di
            ;ld  a,l
            out(0xbf),a
            ld  a,#0x5a
            out(0xbf),a
            pop af
            out(0xbe),a            
            ei
            pop hl
            
            ld  de,#0x4288 ;; = Write + 5*128+8
            add hl,de
            
            di
            ld  a,l
            out(0xbf),a
            ld  a,h
            out(0xbf),a
            ei
            
            ld  a,(#_buffer_scr+673-160+88-16) ;; Look above !!!
            or  a
            jp  z,$10   ;; is it an empty space ?
            cp  #0x80
            jp  z,$10   ;; or is it an inside empty space ?
            ld  a,(#_buffer_scr+673-160+88+16) ;; if not, take what's below
$10:
            di
            out(0xbe),a
            ei
            jp  $12
$11:
            xor a
            ld  (_getcollectable),a
            ;;; JUNE 18
            
            ;ret
$12:
            di
            xor a
            out (0xbf),a
            ld  a,#0x5b
            out (0xbf),a
            ei
            ld  hl,#_sprites
            ld  bc,#0x0cbe
            di
            otir
            ei
                    ; put_vram(0x1b00,sprites,12);
            di
            ld  a,#0x04
            out (0xbf),a
            ld  a,#0x58
            out (0xbf),a
            ei
            ld  d,#0
            ld  a,(#_player_health)
            and #0x78
            ld  e,a
            ld  hl,#_bar
            add hl,de
            ld  bc,#0x08be
            di
            otir
            ei
                    ; put_vram(0x1804,&bar[((player_health&0x78))],8);
            di
            ld  a,#0x17
            out (0xbf),a
            ld  a,#0x58
            out (0xbf),a
            ei
            ;ld  d,#0
            ld  a,(#_player_energy)
            and #0x78
            ld  e,a
            ld  hl,#_bar
            add hl,de
            ld  bc,#0x08be
            di
            otir
            ei
                    ; put_vram(0x1817,&bar[((player_energy&0x78))],8);
            ;;;;;
                    ; //if (counter_byte>0x1C) put_char(26,23,counter_byte);
                    ; //counter_byte   =   0x1B;
            xor a
            ld  (#_flag_prout),a
                    ; flag_prout   =   0;
            ret
