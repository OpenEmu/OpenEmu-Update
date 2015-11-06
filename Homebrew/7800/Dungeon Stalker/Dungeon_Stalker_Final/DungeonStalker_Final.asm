;-------------------------------------------------------------------------------------------
;`             __________ ____ ________ ______ ___  ______  ____  ____      __             `
;`             %%%%%%%%%% %%%% %%%%%%%% %%%%%% %%%  %%%%%%  %%%%  %%%%      %%             `
;`              %%%%%%%%%% %%% %%%% %%% %%%  %%%%%% %%%    %%%%%% %%%%%   %%%              `
;`               %%%%% %%%% %% %%%% %%%% %% %%%     %%%%% %%%   %% %%%%   %%               `
;`              %%%%   %%%% %% %%%% %% %%%% %%% %%% %%%%% %%%   %% %% %%  %%%              `
;`              %%%%    %%% %%  %%% %%% %%% %%%  %% %%%   %%%   %% %% %%% %%%              `
;`              %%%%    %%% %%%%%%% %%   %%  %%%%%% %%%%%% %%%%%%  %% %%%% %%              `
;`               %%%    %%%_____ ______ ____  ___  ____ ___ _____ _____%%%%%%              `
;`              %%%%%%%%%% %%%%% %%%%%% %%%%  %%%  %%%% %%% %%%%% %%%%%  %%%%              `
;`              %%%%%%%% %%%%  %% %%% %%%%%%% %%    %%% %%% %%    %% %%%   %%              `
;`              %%%%%%%   %%%%%   %%% %%%  %% %%     %%%%   %%%%  %% %%%    %              `
;`                           %%%  %%% %%%%%%% %%     %%%%   %%%%  %%%%%                    `
;`                      %%%%  %%  %%% %%%  %% %%%%%% %% %%% %%    %%  %%                   `
;`                       %%%%%%%  %%% %%%  %% %%%%%  %%  %% %%%%% %% %%%%                  `
;`                                                                                         `
;`                                      Dungeon Stalker                                    `
;`                                     Copyright (C)2015                                   `                        
;`                              Steve Engelhardt and Mike Saarna                           `                  
;`                                    Final Revision (v245)                                ` 
;`                                       October 2015                                      `
;`                                                                                         `
;-------------------------------------------------------------------------------------------

; MACRO.H
; Version 1.05, 13/NOVEMBER/2003

VERSION_MACRO         = 105

;
; THIS FILE IS EXPLICITLY SUPPORTED AS A DASM-PREFERRED COMPANION FILE
; PLEASE DO *NOT* REDISTRIBUTE MODIFIED VERSIONS OF THIS FILE!
;
; This file defines DASM macros useful for development for the Atari 2600.
; It is distributed as a companion machine-specific support package
; for the DASM compiler. Updates to this file, DASM, and associated tools are
; available at at http://www.atari2600.org/dasm
;
; Many thanks to the people who have contributed.  If you take issue with the
; contents, or would like to add something, please write to me
; (atari2600@taswegian.com) with your contribution.
;
; Latest Revisions...
;
; 1.05  14/NOV/2003      - Added VERSION_MACRO equate (which will reflect 100x version #)
;                          This will allow conditional code to verify MACRO.H being
;                          used for code assembly.
; 1.04  13/NOV/2003     - SET_POINTER macro added (16-bit address load)
;
; 1.03  23/JUN/2003     - CLEAN_START macro added - clears TIA, RAM, registers
;
; 1.02  14/JUN/2003     - VERTICAL_SYNC macro added
;                         (standardised macro for vertical synch code)
; 1.01  22/MAR/2003     - SLEEP macro added. 
;                       - NO_ILLEGAL_OPCODES switch implemented
; 1.0	22/MAR/2003		Initial release

; Note: These macros use illegal opcodes.  To disable illegal opcode usage, 
;   define the symbol NO_ILLEGAL_OPCODES (-DNO_ILLEGAL_OPCODES=1 on command-line).
;   If you do not allow illegal opcode usage, you must include this file 
;   *after* including VCS.H (as the non-illegal opcodes access hardware
;   registers and require them to be defined first).

; Available macros...
;   SLEEP n             - sleep for n cycles
;   VERTICAL_SYNC       - correct 3 scanline vertical synch code
;   CLEAN_START         - set machine to known state on startup
;   SET_POINTER         - load a 16-bit absolute to a 16-bit variable

;-------------------------------------------------------------------------------
; SLEEP duration
; Original author: Thomas Jentzsch
; Inserts code which takes the specified number of cycles to execute.  This is
; useful for code where precise timing is required.
; ILLEGAL-OPCODE VERSION DOES NOT AFFECT FLAGS OR REGISTERS.
; LEGAL OPCODE VERSION MAY AFFECT FLAGS
; Uses illegal opcode (DASM 2.20.01 onwards).

            MAC SLEEP            ;usage: SLEEP n (n>1)
.CYCLES     SET {1}

                IF .CYCLES < 2
                    ECHO "MACRO ERROR: 'SLEEP': Duration must be > 1"
                    ERR
                ENDIF

                IF .CYCLES & 1
                    IFNCONST NO_ILLEGAL_OPCODES
                        nop $80
                    ELSE
                        bit VSYNC
                    ENDIF
.CYCLES             SET .CYCLES - 3
                ENDIF
            
                REPEAT .CYCLES / 2
                    nop
                REPEND
            ENDM

;-------------------------------------------------------
; SET_POINTER
; Original author: Manuel Rotschkar
;
; Sets a 2 byte RAM pointer to an absolute address.
;
; Usage: SET_POINTER pointer, address
; Example: SET_POINTER SpritePTR, SpriteData
;
; Note: Alters the accumulator, NZ flags
; IN 1: 2 byte RAM location reserved for pointer
; IN 2: absolute address

            MAC SET_POINTER
.POINTER    SET {1}
.ADDRESS    SET {2}

                LDA #<.ADDRESS  ; Get Lowbyte of Address
                STA .POINTER    ; Store in pointer
                LDA #>.ADDRESS  ; Get Hibyte of Address
                STA .POINTER+1  ; Store in pointer+1

            ENDM

; EOF
;
; speakjet.inc
;
;
; AtariVox Speech Synth Driver
;
; By Alex Herbert, 2004
;




; Constants


SERIAL_OUTMASK  equ     $01
SERIAL_RDYMASK  equ     $02



; Macros

        mac     SPKOUT

        ; check buffer-full status
        lda     SWCHA
        and     #SERIAL_RDYMASK
        beq     .speech_done

        ; get next speech byte
        ldy     #$00
        lda     (speech_addr),y

        ; invert data and check for end of string
        eor     #$ff
        beq     .speech_done
        sta     {1}

        ; increment speech pointer
        inc     speech_addr
        bne     .incaddr_skip
        inc     speech_addr+1
.incaddr_skip

        ; output byte as serial data

        sec     ; start bit
.byteout_loop
        ; put carry flag into bit 0 of SWACNT, perserving other bits
        lda     SWACNT          ; 4
        and     #$fe            ; 2 6
        adc     #$00            ; 2 8
        sta     SWACNT          ; 4 12

        ; 10 bits sent? (1 start bit, 8 data bits, 1 stop bit)
        cpy     #$09            ; 2 14
        beq     .speech_done    ; 2 16
        iny                     ; 2 18

	; the 7800 is 1.5x faster than the 2600. Waste more cycles here
	; to match the original baud rate...
        ;ldx     #$07
        ldx     #$0D

.delay_loop
        dex			; 
        bne     .delay_loop     ; 36 54

        ; shift next data bit into carry
        lsr     {1}             ; 5 59

        ; and loop (branch always taken)
        bpl     .byteout_loop   ; 3 62 cycles for loop

.speech_done

        endm


        mac     SPEAK

        lda     #<{1}
        sta     speech_addr
        lda     #>{1}
        sta     speech_addr+1

        endm



 processor 6502
 ;include "macro.h"
 include "7800basic.h"
 include "7800basic_variable_redefs.h"

 ;start address of cart...
 ifconst ROM48k
   ORG $4000
 else
   ifconst bankswitchmode
     ORG  $8000
     RORG $8000
   else
     ORG $8000
   endif
 endif

game
.
 ; 

.L00 ;  rem -------------------------------------------------------------------------------------------

.L01 ;  rem `             __________ ____ ________ ______ ___  ______  ____  ____      __             `

.L02 ;  rem `             %%%%%%%%%% %%%% %%%%%%%% %%%%%% %%%  %%%%%%  %%%%  %%%%      %%             `

.L03 ;  rem `              %%%%%%%%%% %%% %%%% %%% %%%  %%%%%% %%%    %%%%%% %%%%%   %%%              `

.L04 ;  rem `               %%%%% %%%% %% %%%% %%%% %% %%%     %%%%% %%%   %% %%%%   %%               `

.L05 ;  rem `              %%%%   %%%% %% %%%% %% %%%% %%% %%% %%%%% %%%   %% %% %%  %%%              `

.L06 ;  rem `              %%%%    %%% %%  %%% %%% %%% %%%  %% %%%   %%%   %% %% %%% %%%              `

.L07 ;  rem `              %%%%    %%% %%%%%%% %%   %%  %%%%%% %%%%%% %%%%%%  %% %%%% %%              `

.L08 ;  rem `               %%%    %%%_____ ______ ____  ___  ____ ___ _____ _____%%%%%%              `

.L09 ;  rem `              %%%%%%%%%% %%%%% %%%%%% %%%%  %%%  %%%% %%% %%%%% %%%%%  %%%%              `

.L010 ;  rem `              %%%%%%%% %%%%  %% %%% %%%%%%% %%    %%% %%% %%    %% %%%   %%              `

.L011 ;  rem `              %%%%%%%   %%%%%   %%% %%%  %% %%     %%%%   %%%%  %% %%%    %              `

.L012 ;  rem `                           %%%  %%% %%%%%%% %%     %%%%   %%%%  %%%%%                    `

.L013 ;  rem `                      %%%%  %%  %%% %%%  %% %%%%%% %% %%% %%    %%  %%                   `

.L014 ;  rem `                       %%%%%%%  %%% %%%  %% %%%%%  %%  %% %%%%% %% %%%%                  `

.L015 ;  rem `                                                                                         `

.L016 ;  rem `                           <          Dungeon Stalker           >                        `

.L017 ;  rem `                           <         Copyright (C)2015          >                        `                        

.L018 ;  rem `                           <  Steve Engelhardt and Mike Saarna  >                        `                  

.L019 ;  rem `                           <        Final Revision (v245)       >                        ` 

.L020 ;  rem `                           <           October 2015             >                        `

.L021 ;  rem `                                                                                         `

.L022 ;  rem -------------------------------------------------------------------------------------------

.L023 ;  rem 

.L024 ;  rem                                           Credits

.L025 ;  rem 

.L026 ;  rem   Mike & I would like to give special thanks to Robert Truccitto and Marco Sabbetta for 

.L027 ;  rem   their support and contributions during the development of Dungeon Stalker, to Albert 

.L028 ;  rem   Yarusso at AtariAge for making a cartridge release possible, to David Exton for creating

.L029 ;  rem   the artwork, and to everyone who made suggestions on the AtariAge forums.  

.L030 ;  rem 

.
 ; 

.L031 ;  rem ** set all of the kernel options for 7800basic

.L032 ;  displaymode 320A

    lda #%01000011 ;Enable DMA, mode=160x2/160x4
    sta CTRL

    sta sCTRL

.L033 ;  set zoneheight 8

.L034 ;  set zoneprotection on

.L035 ;  set collisionwrap on

.L036 ;  set basepath gfx

.L037 ;  set plotvalueonscreen on

.L038 ;  set romsize 48k

.L039 ;  set avoxvoice on

.L040 ;  set hssupport $1133

.L041 ;  set hsdifficultytext 'novice^high^scores' 'standard^high^scores' 'advanced^high^scores' 'expert^high^scores'

.L042 ;  set hsgamename 'dungeon^stalker'

.L043 ;  set hsgameranks 100000 'supreme^warrior' 60000 'warrior' 45000 'apprentice' 30000 'junior^apprentice' 15000 'pig^flogger' 0 'corpse'

.L044 ;  set screenheight 224

.
 ; 

.L045 ;  rem ** Adjust visible display

.L046 ;  rem ** we steal some cycles back from the visible display by telling 7800basic the 

.L047 ;  rem ** active display is shorter than it really is.

.L048 ;  adjustvisible 0 21

 lda #(0*3)
 sta temp1
 lda #(21*3)
 sta temp2
 jsr adjustvisible
.
 ; 

.L049 ;  rem ** Set up Variables

.L050 ;  rem ** Available RAM we can assign and use:

.L051 ;  rem ** ...The range of letters A -> Z

.L052 ;  rem ** ...The range of 'var0' -> 'var99'

.L053 ;  rem ** ...RAM locations $2200 -> $27FF 

.
 ; 

.L054 ;  rem ** Note that monster variable names are generic. For reference:

.L055 ;  rem ** ...monster1=demon bat

.L056 ;  rem ** ...monster2=snake

.L057 ;  rem ** ...monster3=skeleton warrior

.
 ; 

.L058 ;  rem ** We first reserve some of our extra RAM for plotting the screen, which reduces the RAM available for variables

.L059 ;  rem ** ...screen ram for our 40x28 screen comes out of our extra 1.5k

.L060 ;  dim screenram = $2200  :  rem next free=$268C

.
 ; 

.L061 ;  rem ** 273 Defined variables...

.
 ; 

.L062 ;  dim xpos  =  a

.L063 ;  dim ypos  =  b

.L064 ;  dim frame  =  c

.L065 ;  dim herodir  =  d

.L066 ;  dim quiveranimationframe  =  e

.L067 ;  dim p0_x  =  f

.L068 ;  dim p0_y  =  g

.L069 ;  dim temp0_x  =  h

.L070 ;  dim temp0_y  =  i

.L071 ;  dim tempchar1  =  j

.L072 ;  dim tempchar2  =  k

.L073 ;  dim runningdir  =  l

.L074 ;  dim runningframe  =  m

.L075 ;  dim bat1x  =  n

.L076 ;  dim bat2x  =  o

.L077 ;  dim bat1y  =  p

.L078 ;  dim bat2y  =  q

.L079 ;  dim monster1x  =  r

.L080 ;  dim monster2x  =  s

.L081 ;  dim monster3x  =  t

.L082 ;  dim monster1y  =  u

.L083 ;  dim monster2y  =  v

.L084 ;  dim monster3y  =  w

.L085 ;  dim batanimationframe  =  x

.L086 ;  dim slowdown1  =  y

.L087 ;  dim slowdown2  =  z

.L088 ;  dim quiverx  =  var0

.L089 ;  dim quivery  =  var1

.L090 ;  dim spiderx  =  var2

.L091 ;  dim spidery  =  var3

.L092 ;  dim spideranimationframe  =  var4

.L093 ;  dim monster1animationframe  =  var5

.L094 ;  dim monster2animationframe  =  var6

.L095 ;  dim monster3animationframe  =  var7

.L096 ;  dim xpos_fire  =  var8

.L097 ;  dim ypos_fire  =  var9

.L098 ;  dim fire_dir  =  var10

.L099 ;  dim fire_debounce  =  var11

.L0100 ;  dim lifecounter  =  var12

.L0101 ;  dim arrowcounter  =  var13

.L0102 ;  dim p0_dx  =  var14

.L0103 ;  dim p0_dy  =  var15

.L0104 ;  dim screen  =  var16

.L0105 ;  dim fire_dir_save  =  var17

.L0106 ;  dim slowdown3  =  var18

.L0107 ;  dim scorevalue  =  var19

.L0108 ;  dim wizdeathspeak  =  var20

.L0109 ;  dim gotarrowsspeak  =  var21

.L0110 ;  dim arrowsgonespeak  =  var22

.L0111 ;  dim wizstartspeak  =  var23

.L0112 ;  dim arrowspeakflag  =  var24

.L0113 ;  dim nofireflag  =  var25

.L0114 ;  dim quadframe  =  var26

.L0115 ;  rem free			= var27

.L0116 ;  dim menubarx  =  var28

.L0117 ;  dim menubary  =  var29

.L0118 ;  dim speedvalue  =  var30

.L0119 ;  dim levelvalue  =  var31

.L0120 ;  dim livesvalue  =  var32

.L0121 ;  dim arrowsvalue  =  var33

.L0122 ;  dim godvalue  =  var34

.L0123 ;  dim quiverplacement  =  var35

.L0124 ;  dim quiverflag  =  var36

.L0125 ;  dim quiverplaced  =  var37

.L0126 ;  dim arrowrand  =  var38

.L0127 ;  dim soundcounter  =  var39

.L0128 ;  dim gameoverflag  =  var40

.L0129 ;  dim freezeflag  =  var41

.L0130 ;  dim freeze  =  var42

.L0131 ;  dim freezecount  =  var43

.L0132 ;  dim enemy1deathflag  =  var44

.L0133 ;  dim enemy2deathflag  =  var45

.L0134 ;  dim enemy3deathflag  =  var46

.L0135 ;  dim spiderdeathflag  =  var47

.L0136 ;  dim slowdown_explode  =  var49

.L0137 ;  dim playerdeathflag  =  var50

.L0138 ;  dim deathframe  =  var51

.L0139 ;  dim slowdown_death  =  var52

.L0140 ;  dim tempx  =  var53

.L0141 ;  dim tempy  =  var54

.L0142 ;  dim tempdir  =  var55

.L0143 ;  dim obstacleseen  =  var56

.L0144 ;  dim monster1type  =  var57

.L0145 ;  dim monster2type  =  var58

.L0146 ;  dim monster3type  =  var59

.L0147 ;  dim monster1dir  =  var60

.L0148 ;  dim monster2dir  =  var61

.L0149 ;  dim monster3dir  =  var62

.L0150 ;  dim temploop  =  var63

.L0151 ;  dim temptype  =  var64

.L0152 ;  dim treasureindex  =  var65

.L0153 ;  dim spiderchangecountdown  =  var66

.L0154 ;  dim templogiccountdown  =  var67

.L0155 ;  dim spider_obstacleseen  =  var69

.L0156 ;  dim spider_spider1type  =  var70

.L0157 ;  dim spider_spider2type  =  var71

.L0158 ;  dim spider_spider3type  =  var72

.L0159 ;  dim spider_spider1dir  =  var73

.L0160 ;  dim spider_spider2dir  =  var74

.L0161 ;  dim spider_spider3dir  =  var75

.L0162 ;  dim bunkerhit  =  var76

.L0163 ;  dim godmodeon  =  var78

.L0164 ;  dim slowdown_2  =  var79

.L0165 ;  dim gamemode  =  var80

.L0166 ;  dim treasurespeak  =  var81

.L0167 ;  dim bat2_tempdir  =  var82

.L0168 ;  dim bat_bat1type  =  var83

.L0169 ;  dim bat_bat2type  =  var84

.L0170 ;  dim bat_bat1dir  =  var85

.L0171 ;  dim bat_bat2dir  =  var86

.L0172 ;  dim bat_obstacleseen  =  var87

.L0173 ;  dim bat2_obstacleseen  =  var88

.L0174 ;  dim godspeak  =  var89

.L0175 ;  dim devmodecount  =  var90

.L0176 ;  dim bat1deathflag  =  var91

.L0177 ;  dim bat2deathflag  =  var92

.L0178 ;  dim High_Score01  =  var93

.L0179 ;  dim High_Score02  =  var94

.L0180 ;  dim High_Score03  =  var95

.L0181 ;  dim Save_Score01  =  var96

.L0182 ;  dim Save_Score02  =  var97

.L0183 ;  dim Save_Score03  =  var98

.L0184 ;  dim savejoy  =  var99

.L0185 ;  dim objectblink  =  $268C

.L0186 ;  dim livesbcdhi  =  $268D

.L0187 ;  dim livesbcdlo  =  $268E

.L0188 ;  dim altframe  =  $268F

.L0189 ;  dim score0bcd0  =  $2690

.L0190 ;  dim score0bcd1  =  $2691

.L0191 ;  dim score0bcd2  =  $2692

.L0192 ;  dim score0bcd3  =  $2693

.L0193 ;  dim score0bcd4  =  $2694

.L0194 ;  dim score0bcd5  =  $2695

.L0195 ;  dim levelvaluebcdhi  =  $2696

.L0196 ;  dim levelvaluebcdlo  =  $2697

.L0197 ;  dim bat1respawn  =  $2698

.L0198 ;  dim bat2respawn  =  $2699

.L0199 ;  dim spiderrespawn  =  $269A

.L0200 ;  dim treasurex  =  $269B

.L0201 ;  dim treasurey  =  $269C

.L0202 ;  dim treasurespawn  =  $269D

.L0203 ;  dim treasureplaced  =  $269E

.L0204 ;  dim treasure_rplace  =  $269F

.L0205 ;  dim treasure_rplace2  =  $26A0

.L0206 ;  dim treasurepickup  =  $26A1

.L0207 ;  dim monster1health  =  $26A2

.L0208 ;  dim monster2health  =  $26A3

.L0209 ;  dim monster3health  =  $26A4

.L0210 ;  dim r1x_fire  =  $26A5

.L0211 ;  dim r2x_fire  =  $26A6

.L0212 ;  dim r3x_fire  =  $26A7

.L0213 ;  dim r1y_fire  =  $26A8

.L0214 ;  dim r2y_fire  =  $26A9

.L0215 ;  dim r3y_fire  =  $26AA

.L0216 ;  dim r1x_temp0  =  $26AB

.L0217 ;  dim r1y_temp0  =  $26AC

.L0218 ;  dim r1_tempchar0  =  $26AD

.L0219 ;  dim r1_arrowspeed  =  $26AE

.L0220 ;  dim r1_fire_dir  =  $26AF

.L0221 ;  dim r2_fire_dir  =  $26B0

.L0222 ;  dim r3_fire_dir  =  $26B1

.L0223 ;  dim tempanim  =  $26B2

.L0224 ;  dim tempexplode  =  $26B3

.L0225 ;  dim swordx  =  $26B4

.L0226 ;  dim swordy  =  $26B5

.L0227 ;  dim swordspawn  =  $26B6

.L0228 ;  dim swordplaced  =  $26B7

.L0229 ;  dim sword_rplace  =  $26B8

.L0230 ;  dim sword_rplace2  =  $26B9

.L0231 ;  dim swordpickup  =  $26BA

.L0232 ;  dim invincibleflag  =  $26BB

.L0233 ;  dim invincible_counter1  =  $26BC

.L0234 ;  dim invincible_counter2  =  $26BD

.L0235 ;  dim invincible_on  =  $26BE

.L0236 ;  dim bunkerbuster  =  $26BF

.L0237 ;  dim extralife_counter  =  $26C0

.L0238 ;  dim explodeframe1  =  $26C1

.L0239 ;  dim explodeframe2  =  $26C2

.L0240 ;  dim explodeframe3  =  $26C3

.L0241 ;  dim tempexplodeframe  =  $26C4

.L0242 ;  dim newfire1  =  $26C5

.L0243 ;  dim newfire2  =  $26C6

.L0244 ;  dim newfire3  =  $26C7

.L0245 ;  dim spiderdeathframe  =  $26C8

.L0246 ;  dim slowdown_spider  =  $26C9

.L0247 ;  dim slowdown_bat1  =  $26CA

.L0248 ;  dim slowdown_bat2  =  $26CB

.L0249 ;  dim bat1deathframe  =  $26CC

.L0250 ;  dim bat2deathframe  =  $26CD

.L0251 ;  dim playerinvisibletime  =  $26CE

.L0252 ;  dim monster1changecountdown  =  $26CF

.L0253 ;  dim monster2changecountdown  =  $26D0

.L0254 ;  dim monster3changecountdown  =  $26D1

.L0255 ;  dim olddir  =  $26D2

.L0256 ;  dim explosioncolor  =  $26D3

.L0257 ;  dim explosionflash  =  $26D4

.L0258 ;  dim copyright  =  $26D5

.L0259 ;  dim copyrightcolor  =  $26D6

.L0260 ;  dim present  =  $26D7

.L0261 ;  dim presentcolor  =  $26D8

.L0262 ;  dim monster1_shieldflag  =  $26D9

.L0263 ;  dim monster2_shieldflag  =  $26DA

.L0264 ;  dim monster3_shieldflag  =  $26DB

.L0265 ;  dim monster4_shieldflag  =  $26DC

.L0266 ;  dim monster5_shieldflag  =  $26DD

.L0267 ;  dim monster6_shieldflag  =  $26DE

.L0268 ;  dim r1hp  =  $26DF

.L0269 ;  dim r2hp  =  $26E0

.L0270 ;  dim r3hp  =  $26E1

.L0271 ;  dim colorvalue  =  $26E2

.L0272 ;  dim backcolorvalue  =  $26E3

.L0273 ;  dim colorflasher  =  $26E4

.L0274 ;  dim bat1changecountdown  =  $26E5

.L0275 ;  dim bat2changecountdown  =  $26E6

.L0276 ;  dim seecollision  =  $26E7

.L0277 ;  dim temppositionadjust  =  $26E8

.L0278 ;  dim deathspeak  =  $26E9

.L0279 ;  dim monst1slow  =  $26EA

.L0280 ;  dim monst2slow  =  $26EB

.L0281 ;  dim monst3slow  =  $26EC

.L0282 ;  dim bat1slow  =  $26ED

.L0283 ;  dim bat2slow  =  $26EE

.L0284 ;  dim spiderslow  =  $26EF

.L0285 ;  dim reloop  =  $26F0

.L0286 ;  dim lastflash  =  $26F1

.L0287 ;  dim noteindex  =  $26F2

.L0288 ;  dim demomode  =  $26F3

.L0289 ;  dim demomodecountdown  =  $26F4

.L0290 ;  dim fireheld  =  $26F5

.L0291 ;  dim demodir  =  $26F6

.L0292 ;  dim demochangetimer  =  $26F7

.L0293 ;  dim treasuretimer  =  $26F8

.L0294 ;  dim treasuretimer2  =  $26F9

.L0295 ;  dim bunkerspeak  =  $26FA

.L0296 ;  dim bunkerspeakflag  =  $26FB

.L0297 ;  dim bunkertimer  =  $26FC

.L0298 ;  dim level1flag  =  $26FD

.L0299 ;  dim level2flag  =  $26FE

.L0300 ;  dim level3flag  =  $26FF

.L0301 ;  dim level4flag  =  $2700

.L0302 ;  dim level5flag  =  $2701

.L0303 ;  dim skill  =  $2702

.L0304 ;  dim score2flag  =  $2703

.L0305 ;  dim score3flag  =  $2704

.L0306 ;  dim score4flag  =  $2705

.L0307 ;  dim score5flag  =  $2706

.L0308 ;  dim fadeluma  =  $2707

.L0309 ;  dim fadeindex  =  $2708

.L0310 ;  dim level1spawnflag  =  $2709

.L0311 ;  dim level2spawnflag  =  $270A

.L0312 ;  dim level3spawnflag  =  $270B

.L0313 ;  dim level4spawnflag  =  $270C

.L0314 ;  dim level5spawnflag  =  $270D

.L0315 ;  dim value1flag  =  $270E

.L0316 ;  dim value2flag  =  $270F

.L0317 ;  dim value3flag  =  $2710

.L0318 ;  dim value4flag  =  $2711

.L0319 ;  dim value5flag  =  $2712

.L0320 ;  dim treasurep  =  $2713

.L0321 ;  dim spiderwebcountdown  =  $2714

.L0322 ;  dim spiderwalkingsteps  =  $2715

.L0323 ;  dim wizmode  =  $2716

.L0324 ;  dim wizmodeover  =  $2717

.L0325 ;  dim foregroundcolor  =  $2718

.L0326 ;  dim wizwarpcountdown  =  $2719

.L0327 ;  dim wizanimationframe  =  $271A

.L0328 ;  dim wizlogiccountdown  =  $271B

.L0329 ;  dim wizdeathflag  =  $271C

.L0330 ;  dim wiztempx  =  $271D

.L0331 ;  dim wiztempy  =  $271E

.L0332 ;  dim temprand  =  $271F

.L0333 ;  dim devmodeenabled  =  $2720

.L0334 ;  dim colorchange  =  $2721

.
 ; 

.L0335 ;  dim SBACKGRND  =  $20

.
 ; 

.L0336 ;  rem *** last memory location available is $27FF

.
 ; 

.L0337 ;  rem ** Match Wizard coordinates to first monster

.L0338 ;  dim wizx = monster1x

.L0339 ;  dim wizy = monster1y

.L0340 ;  dim wizdir = monster1dir

.L0341 ;  dim wizfirex = r1x_fire

.L0342 ;  dim wizfirey = r1y_fire

.
 ; 

.L0343 ;  rem ** Set up score variables

.L0344 ;  dim sc1 = score0

.L0345 ;  dim sc2 = score0 + 1

.L0346 ;  dim sc3 = score0 + 2

.L0347 ;  dim sc4 = score1

.L0348 ;  dim sc5 = score1 + 1

.L0349 ;  dim sc6 = score1 + 2

.
 ; 

.L0350 ;  rem ** some constants we use to find character values (for the mini-web that the spider creates)

.L0351 ;  const spw1 =  < miniwebtop

.L0352 ;  const spw2 = spw1 + 1

.L0353 ;  const spw3 = spw1 + 2

.L0354 ;  const spw4 = spw1 + 3

.
 ; 

.L0355 ;  rem ** Set default game options

.L0356 ;  arrowsvalue = 8  : rem ** start with 8 arrows

	LDA #8
	STA arrowsvalue
.L0357 ;  speedvalue = 1  : rem ** start at normal speed (speed=0 is a dev mode option)

	LDA #1
	STA speedvalue
.L0358 ;  levelvalue = 1  : rem ** start at level 1

	LDA #1
	STA levelvalue
.L0359 ;  livesvalue = 6  : rem ** start with 6 lives

	LDA #6
	STA livesvalue
.L0360 ;  godvalue = 1  : rem ** start with god mode turned off

	LDA #1
	STA godvalue
.L0361 ;  colorvalue = 1  : rem ** start with default colors (hold pause at start to reverse colors)

	LDA #1
	STA colorvalue
.L0362 ;  gamemode = 0  : rem ** start with default game mode

	LDA #0
	STA gamemode
.L0363 ;  gamedifficulty = 1  : rem ** start with default difficulty level (standard)

	LDA #1
	STA gamedifficulty
.L0364 ;  scorevalue = 1  : rem ** start with default score value

	LDA #1
	STA scorevalue
.L0365 ;  skill = 2  : rem ** start with default skill level (2)

	LDA #2
	STA skill
.L0366 ;  colorchange = 0  : rem ** start with default colors (hold pause at start to reverse colors)

	LDA #0
	STA colorchange
.L0367 ;  pausedisable = 1  : rem ** start with pausedisable set

	LDA #1
	STA pausedisable
.
 ; 

.L0368 ;  rem ** Set up characters and clear screen

.L0369 ;  characterset atascii

    lda #>atascii
    sta CHARBASE
    sta sCHARBASE

    lda #(atascii_mode | %01100000)
    sta charactermode

.L0370 ;  alphachars ASCII

.L0371 ;  clearscreen

 jsr clearscreen
.
 ; 

.L0372 ;  rem ** Draw wait

.L0373 ;  rem ** The drawscreen command completes near the beginning of the visible display. This is done intentionally, 

.L0374 ;  rem ** to allow your program to have the maximum amount of CPU time possible.

.L0375 ;  rem ** You may occasionally have code that you don't want to execute during the visible screen. For these 

.L0376 ;  rem ** occasions you can call the drawwait command. This command will only return after the visible screen has 

.L0377 ;  rem ** been completely displayed.

.L0378 ;  drawwait

 jsr drawwait
.
 ; 

.L0379 ;  rem ** Set up variables for text intro screens (prior to titlescreen)

.L0380 ;  copyright = 80

	LDA #80
	STA copyright
.L0381 ;  copyrightcolor = 5

	LDA #5
	STA copyrightcolor
.L0382 ;  fadeindex = 0

	LDA #0
	STA fadeindex
.L0383 ;  fadeluma = 0

	LDA #0
	STA fadeluma
.L0384 ;  P0C2 = 0

	LDA #0
	STA P0C2
.L0385 ;  P3C2 = $94

	LDA #$94
	STA P3C2
.L0386 ;  P4C2 = $36

	LDA #$36
	STA P4C2
.L0387 ;  SBACKGRND = $00

	LDA #$00
	STA SBACKGRND
.
 ; 

.L0388 ;  rem ** Display Introduction screen with AtariAge logo and copypright information

.
 ; 

.L0389 ;  rem ** Display '(C) 2015' on screen, text fades in and fades out

.date
 ; date

.L0390 ;  rem ** if you hold down pause when the game begins, it reverts to the original color scheme.

.L0391 ;  rem ** (colored background with black maze, rather than black background with colored maze)

.L0392 ;  if switchpause then colorchange = 1

 lda #8
 bit SWCHB
	BNE .skipL0392
.condpart0
	LDA #1
	STA colorchange
.skipL0392
.L0393 ;  clearscreen

 jsr clearscreen
.L0394 ;  fadeindex = fadeindex + 1

	LDA fadeindex
	CLC
	ADC #1
	STA fadeindex
.L0395 ;  if fadeindex < 127 then fadeluma = fadeindex / 8

	LDA fadeindex
	CMP #127
     BCS .skipL0395
.condpart1
	LDA fadeindex
	lsr
	lsr
	lsr
	STA fadeluma
.skipL0395
.L0396 ;  if fadeindex > 136 then fadeluma = 32 -  ( fadeindex / 8 ) 

	LDA #136
	CMP fadeindex
     BCS .skipL0396
.condpart2
; complex statement detected
	LDA #32
	PHA
	LDA fadeindex
	lsr
	lsr
	lsr
  TAY
  PLA
  STY tempmath
  SEC
  SBC tempmath
	STA fadeluma
.skipL0396
.L0397 ;  P0C2 = fadeluma

	LDA fadeluma
	STA P0C2
.L0398 ;  if fadeindex = 81 then playsfx copyrightsfx

	LDA fadeindex
	CMP #81
     BNE .skipL0398
.condpart3
    lda #<copyrightsfx
    sta temp1
    lda #>copyrightsfx
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL0398
.L0399 ;  rem ** Display AtariAge logo on the screen

.L0400 ;  plotchars '*^2015' 0 68 11

	JMP skipalphadata0
alphadata0
 .byte (<atascii + $2a)
 .byte (<atascii + $20)
 .byte (<atascii + $32)
 .byte (<atascii + $30)
 .byte (<atascii + $31)
 .byte (<atascii + $35)
skipalphadata0
    lda #<alphadata0
    sta temp1

    lda #>alphadata0
    sta temp2

    lda #26 ; width in two's complement
    ora #0 ; palette left shifted 5 bits
    sta temp3
    lda #68
    sta temp4

    lda #11

    sta temp5

 jsr plotcharacters
.L0401 ;  plotsprite aa_left_1 3 50 32

    lda #<aa_left_1
    sta temp1

    lda #>aa_left_1
    sta temp2

    lda #(96|aa_left_1_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #32

    sta temp5

    lda #(aa_left_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0402 ;  plotsprite aa_left_2 3 50 40

    lda #<aa_left_2
    sta temp1

    lda #>aa_left_2
    sta temp2

    lda #(96|aa_left_2_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #40

    sta temp5

    lda #(aa_left_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0403 ;  plotsprite aa_left_3 3 50 48

    lda #<aa_left_3
    sta temp1

    lda #>aa_left_3
    sta temp2

    lda #(96|aa_left_3_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #48

    sta temp5

    lda #(aa_left_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0404 ;  plotsprite aa_left_4 3 50 56

    lda #<aa_left_4
    sta temp1

    lda #>aa_left_4
    sta temp2

    lda #(96|aa_left_4_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #56

    sta temp5

    lda #(aa_left_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0405 ;  plotsprite aa_right_1 4 90 32

    lda #<aa_right_1
    sta temp1

    lda #>aa_right_1
    sta temp2

    lda #(128|aa_right_1_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #32

    sta temp5

    lda #(aa_right_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0406 ;  plotsprite aa_right_2 4 90 40

    lda #<aa_right_2
    sta temp1

    lda #>aa_right_2
    sta temp2

    lda #(128|aa_right_2_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #40

    sta temp5

    lda #(aa_right_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0407 ;  plotsprite aa_right_3 4 90 48

    lda #<aa_right_3
    sta temp1

    lda #>aa_right_3
    sta temp2

    lda #(128|aa_right_3_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #48

    sta temp5

    lda #(aa_right_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0408 ;  plotsprite aa_right_4 4 90 56

    lda #<aa_right_4
    sta temp1

    lda #>aa_right_4
    sta temp2

    lda #(128|aa_right_4_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #56

    sta temp5

    lda #(aa_right_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0409 ;  drawscreen

 jsr drawscreen
.L0410 ;  if joy0fire then playsfx sfx_menumove2 : goto titlescreen

 bit sINPT1
	BPL .skipL0410
.condpart4
    lda #<sfx_menumove2
    sta temp1
    lda #>sfx_menumove2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
 jmp .titlescreen

.skipL0410
.L0411 ;  if fadeindex > 0 then goto date

	LDA #0
	CMP fadeindex
     BCS .skipL0411
.condpart5
 jmp .date

.skipL0411
.
 ; 

.L0412 ;  rem ** Display names on screen, text fades in and fades out

.copyright
 ; copyright

.L0413 ;  clearscreen

 jsr clearscreen
.L0414 ;  fadeindex = fadeindex + 1

	LDA fadeindex
	CLC
	ADC #1
	STA fadeindex
.L0415 ;  if fadeindex < 127 then fadeluma = fadeindex / 8

	LDA fadeindex
	CMP #127
     BCS .skipL0415
.condpart6
	LDA fadeindex
	lsr
	lsr
	lsr
	STA fadeluma
.skipL0415
.L0416 ;  if fadeindex > 136 then fadeluma = 32 -  ( fadeindex / 8 ) 

	LDA #136
	CMP fadeindex
     BCS .skipL0416
.condpart7
; complex statement detected
	LDA #32
	PHA
	LDA fadeindex
	lsr
	lsr
	lsr
  TAY
  PLA
  STY tempmath
  SEC
  SBC tempmath
	STA fadeluma
.skipL0416
.L0417 ;  P0C2 = fadeluma

	LDA fadeluma
	STA P0C2
.L0418 ;  if fadeindex = 81 then playsfx copyrightsfx

	LDA fadeindex
	CMP #81
     BNE .skipL0418
.condpart8
    lda #<copyrightsfx
    sta temp1
    lda #>copyrightsfx
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL0418
.L0419 ;  plotchars 'Steve^Engelhardt' 0 50 9

	JMP skipalphadata1
alphadata1
 .byte (<atascii + $53)
 .byte (<atascii + $74)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $45)
 .byte (<atascii + $6e)
 .byte (<atascii + $67)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $68)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $64)
 .byte (<atascii + $74)
skipalphadata1
    lda #<alphadata1
    sta temp1

    lda #>alphadata1
    sta temp2

    lda #16 ; width in two's complement
    ora #0 ; palette left shifted 5 bits
    sta temp3
    lda #50
    sta temp4

    lda #9

    sta temp5

 jsr plotcharacters
.L0420 ;  plotchars '&' 0 80 11

	JMP skipalphadata2
alphadata2
 .byte (<atascii + $26)
skipalphadata2
    lda #<alphadata2
    sta temp1

    lda #>alphadata2
    sta temp2

    lda #31 ; width in two's complement
    ora #0 ; palette left shifted 5 bits
    sta temp3
    lda #80
    sta temp4

    lda #11

    sta temp5

 jsr plotcharacters
.L0421 ;  plotchars 'Mike^Saarna' 0 60 13

	JMP skipalphadata3
alphadata3
 .byte (<atascii + $4d)
 .byte (<atascii + $69)
 .byte (<atascii + $6b)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $61)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $6e)
 .byte (<atascii + $61)
skipalphadata3
    lda #<alphadata3
    sta temp1

    lda #>alphadata3
    sta temp2

    lda #21 ; width in two's complement
    ora #0 ; palette left shifted 5 bits
    sta temp3
    lda #60
    sta temp4

    lda #13

    sta temp5

 jsr plotcharacters
.L0422 ;  rem ** Display AtariAge logo on the screen

.L0423 ;  plotsprite aa_left_1 3 50 32

    lda #<aa_left_1
    sta temp1

    lda #>aa_left_1
    sta temp2

    lda #(96|aa_left_1_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #32

    sta temp5

    lda #(aa_left_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0424 ;  plotsprite aa_left_2 3 50 40

    lda #<aa_left_2
    sta temp1

    lda #>aa_left_2
    sta temp2

    lda #(96|aa_left_2_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #40

    sta temp5

    lda #(aa_left_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0425 ;  plotsprite aa_left_3 3 50 48

    lda #<aa_left_3
    sta temp1

    lda #>aa_left_3
    sta temp2

    lda #(96|aa_left_3_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #48

    sta temp5

    lda #(aa_left_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0426 ;  plotsprite aa_left_4 3 50 56

    lda #<aa_left_4
    sta temp1

    lda #>aa_left_4
    sta temp2

    lda #(96|aa_left_4_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #56

    sta temp5

    lda #(aa_left_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0427 ;  plotsprite aa_right_1 4 90 32

    lda #<aa_right_1
    sta temp1

    lda #>aa_right_1
    sta temp2

    lda #(128|aa_right_1_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #32

    sta temp5

    lda #(aa_right_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0428 ;  plotsprite aa_right_2 4 90 40

    lda #<aa_right_2
    sta temp1

    lda #>aa_right_2
    sta temp2

    lda #(128|aa_right_2_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #40

    sta temp5

    lda #(aa_right_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0429 ;  plotsprite aa_right_3 4 90 48

    lda #<aa_right_3
    sta temp1

    lda #>aa_right_3
    sta temp2

    lda #(128|aa_right_3_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #48

    sta temp5

    lda #(aa_right_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0430 ;  plotsprite aa_right_4 4 90 56

    lda #<aa_right_4
    sta temp1

    lda #>aa_right_4
    sta temp2

    lda #(128|aa_right_4_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #56

    sta temp5

    lda #(aa_right_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0431 ;  drawscreen

 jsr drawscreen
.L0432 ;  if joy0fire then playsfx sfx_menumove2 : goto titlescreen

 bit sINPT1
	BPL .skipL0432
.condpart9
    lda #<sfx_menumove2
    sta temp1
    lda #>sfx_menumove2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
 jmp .titlescreen

.skipL0432
.L0433 ;  if fadeindex > 0 then goto copyright

	LDA #0
	CMP fadeindex
     BCS .skipL0433
.condpart10
 jmp .copyright

.skipL0433
.
 ; 

.L0434 ;  rem ** Display 'Present...' on screen, text fades in and fades out

.present
 ; present

.L0435 ;  clearscreen

 jsr clearscreen
.L0436 ;  fadeindex = fadeindex + 1

	LDA fadeindex
	CLC
	ADC #1
	STA fadeindex
.L0437 ;  if fadeindex < 127 then fadeluma = fadeindex / 8

	LDA fadeindex
	CMP #127
     BCS .skipL0437
.condpart11
	LDA fadeindex
	lsr
	lsr
	lsr
	STA fadeluma
.skipL0437
.L0438 ;  if fadeindex > 136 then fadeluma = 32 -  ( fadeindex / 8 ) 

	LDA #136
	CMP fadeindex
     BCS .skipL0438
.condpart12
; complex statement detected
	LDA #32
	PHA
	LDA fadeindex
	lsr
	lsr
	lsr
  TAY
  PLA
  STY tempmath
  SEC
  SBC tempmath
	STA fadeluma
.skipL0438
.L0439 ;  P0C2 = fadeluma

	LDA fadeluma
	STA P0C2
.L0440 ;  if fadeindex = 81 then playsfx copyrightsfx

	LDA fadeindex
	CMP #81
     BNE .skipL0440
.condpart13
    lda #<copyrightsfx
    sta temp1
    lda #>copyrightsfx
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL0440
.L0441 ;  plotchars 'Present...' 0 60 11

	JMP skipalphadata4
alphadata4
 .byte (<atascii + $50)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $65)
 .byte (<atascii + $6e)
 .byte (<atascii + $74)
 .byte (<atascii + $2e)
 .byte (<atascii + $2e)
 .byte (<atascii + $2e)
skipalphadata4
    lda #<alphadata4
    sta temp1

    lda #>alphadata4
    sta temp2

    lda #22 ; width in two's complement
    ora #0 ; palette left shifted 5 bits
    sta temp3
    lda #60
    sta temp4

    lda #11

    sta temp5

 jsr plotcharacters
.L0442 ;  rem ** Display AtariAge logo on the screen

.L0443 ;  plotsprite aa_left_1 3 50 32

    lda #<aa_left_1
    sta temp1

    lda #>aa_left_1
    sta temp2

    lda #(96|aa_left_1_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #32

    sta temp5

    lda #(aa_left_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0444 ;  plotsprite aa_left_2 3 50 40

    lda #<aa_left_2
    sta temp1

    lda #>aa_left_2
    sta temp2

    lda #(96|aa_left_2_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #40

    sta temp5

    lda #(aa_left_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0445 ;  plotsprite aa_left_3 3 50 48

    lda #<aa_left_3
    sta temp1

    lda #>aa_left_3
    sta temp2

    lda #(96|aa_left_3_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #48

    sta temp5

    lda #(aa_left_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0446 ;  plotsprite aa_left_4 3 50 56

    lda #<aa_left_4
    sta temp1

    lda #>aa_left_4
    sta temp2

    lda #(96|aa_left_4_width_twoscompliment)
    sta temp3

    lda #50
    sta temp4

    lda #56

    sta temp5

    lda #(aa_left_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0447 ;  plotsprite aa_right_1 4 90 32

    lda #<aa_right_1
    sta temp1

    lda #>aa_right_1
    sta temp2

    lda #(128|aa_right_1_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #32

    sta temp5

    lda #(aa_right_1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0448 ;  plotsprite aa_right_2 4 90 40

    lda #<aa_right_2
    sta temp1

    lda #>aa_right_2
    sta temp2

    lda #(128|aa_right_2_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #40

    sta temp5

    lda #(aa_right_2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0449 ;  plotsprite aa_right_3 4 90 48

    lda #<aa_right_3
    sta temp1

    lda #>aa_right_3
    sta temp2

    lda #(128|aa_right_3_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #48

    sta temp5

    lda #(aa_right_3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0450 ;  plotsprite aa_right_4 4 90 56

    lda #<aa_right_4
    sta temp1

    lda #>aa_right_4
    sta temp2

    lda #(128|aa_right_4_width_twoscompliment)
    sta temp3

    lda #90
    sta temp4

    lda #56

    sta temp5

    lda #(aa_right_4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0451 ;  drawscreen

 jsr drawscreen
.L0452 ;  if joy0fire then playsfx sfx_menumove2 : goto titlescreen

 bit sINPT1
	BPL .skipL0452
.condpart14
    lda #<sfx_menumove2
    sta temp1
    lda #>sfx_menumove2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
 jmp .titlescreen

.skipL0452
.
 ; 

.L0453 ;  if fadeindex > 0 then goto present

	LDA #0
	CMP fadeindex
     BCS .skipL0453
.condpart15
 jmp .present

.skipL0453
.L0454 ;  playsfx sfx_menumove2

    lda #<sfx_menumove2
    sta temp1
    lda #>sfx_menumove2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.L0455 ;  goto titlescreen

 jmp .titlescreen

.
 ; 

.treasurespeak
 ; treasurespeak

.L0456 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0456
.condpart16
  RTS
.skipL0456
.L0457 ;  rem ** speech texts for picking up treasure are: gold, money, and jackpot

.L0458 ;  rem ** yes, it is more likely that 'jackpot' will be spoken. I like that one.

.L0459 ;  treasurespeak = rand & 3

 jsr randomize
	AND #3
	STA treasurespeak
.L0460 ;  on treasurespeak goto spkt0 spkt1 spkt2 spkt3

	LDX treasurespeak
	LDA .L0460jumptablehi,x
	PHA
	LDA .L0460jumptablelo,x
	PHA
	RTS
.L0460jumptablehi
	.byte >(.spkt0-1)
	.byte >(.spkt1-1)
	.byte >(.spkt2-1)
	.byte >(.spkt3-1)
.L0460jumptablelo
	.byte <(.spkt0-1)
	.byte <(.spkt1-1)
	.byte <(.spkt2-1)
	.byte <(.spkt3-1)
.spkt0
 ; spkt0

.L0461 ;  speak gold : return

    SPEAK gold
  RTS
.spkt1
 ; spkt1

.L0462 ;  speak money : return

    SPEAK money
  RTS
.spkt2
 ; spkt2

.spkt3
 ; spkt3

.L0463 ;  speak jackpot : return

    SPEAK jackpot
  RTS
.
 ; 

.deathspeak
 ; deathspeak

.L0464 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0464
.condpart17
  RTS
.skipL0464
.L0465 ;  rem ** speech texts for player death are: death, mylifeisover, destroyed, terminated, yougotme, beaten

.L0466 ;  deathspeak = rand & 7

 jsr randomize
	AND #7
	STA deathspeak
.L0467 ;  on deathspeak goto spkd0 spkd1 spkd2 spkd3 spkd4 spkd6 spkd6 spkd7

	LDX deathspeak
	LDA .L0467jumptablehi,x
	PHA
	LDA .L0467jumptablelo,x
	PHA
	RTS
.L0467jumptablehi
	.byte >(.spkd0-1)
	.byte >(.spkd1-1)
	.byte >(.spkd2-1)
	.byte >(.spkd3-1)
	.byte >(.spkd4-1)
	.byte >(.spkd6-1)
	.byte >(.spkd6-1)
	.byte >(.spkd7-1)
.L0467jumptablelo
	.byte <(.spkd0-1)
	.byte <(.spkd1-1)
	.byte <(.spkd2-1)
	.byte <(.spkd3-1)
	.byte <(.spkd4-1)
	.byte <(.spkd6-1)
	.byte <(.spkd6-1)
	.byte <(.spkd7-1)
.spkd0
 ; spkd0

.L0468 ;  speak death : return

    SPEAK death
  RTS
.spkd1
 ; spkd1

.L0469 ;  speak mylifeisover : return

    SPEAK mylifeisover
  RTS
.spkd2
 ; spkd2

.L0470 ;  speak destroyed : return

    SPEAK destroyed
  RTS
.spkd3
 ; spkd3

.spkd4
 ; spkd4

.L0471 ;  speak terminated : return

    SPEAK terminated
  RTS
.spkd5
 ; spkd5

.L0472 ;  speak yougotme : return

    SPEAK yougotme
  RTS
.spkd6
 ; spkd6

.L0473 ;  speak beaten : return

    SPEAK beaten
  RTS
.spkd7
 ; spkd7

.L0474 ;  speak death : return

    SPEAK death
  RTS
.
 ; 

.godspeak
 ; godspeak

.L0475 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0475
.condpart18
  RTS
.skipL0475
.L0476 ;  rem ** speech texts for picking up the sword are: nofear, bringiton, cantstopme, iamgod

.L0477 ;  godspeak = rand & 3

 jsr randomize
	AND #3
	STA godspeak
.L0478 ;  on godspeak goto spkg0 spkg1 spkg2 spkg3

	LDX godspeak
	LDA .L0478jumptablehi,x
	PHA
	LDA .L0478jumptablelo,x
	PHA
	RTS
.L0478jumptablehi
	.byte >(.spkg0-1)
	.byte >(.spkg1-1)
	.byte >(.spkg2-1)
	.byte >(.spkg3-1)
.L0478jumptablelo
	.byte <(.spkg0-1)
	.byte <(.spkg1-1)
	.byte <(.spkg2-1)
	.byte <(.spkg3-1)
.spkg0
 ; spkg0

.L0479 ;  speak nofear : return

    SPEAK nofear
  RTS
.spkg1
 ; spkg1

.L0480 ;  speak bringiton : return

    SPEAK bringiton
  RTS
.spkg2
 ; spkg2

.L0481 ;  speak cantstopme : return

    SPEAK cantstopme
  RTS
.spkg3
 ; spkg3

.L0482 ;  speak iamgod : return

    SPEAK iamgod
  RTS
.
 ; 

.wizstartspeak
 ; wizstartspeak

.L0483 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0483
.condpart19
  RTS
.skipL0483
.L0484 ;  rem ** speech texts for the Wizard are: Ha Ha Ha and Watch Out

.L0485 ;  wizstartspeak = rand & 3

 jsr randomize
	AND #3
	STA wizstartspeak
.L0486 ;  on wizstartspeak goto spkv0 spkv1 spkv2 spkv3

	LDX wizstartspeak
	LDA .L0486jumptablehi,x
	PHA
	LDA .L0486jumptablelo,x
	PHA
	RTS
.L0486jumptablehi
	.byte >(.spkv0-1)
	.byte >(.spkv1-1)
	.byte >(.spkv2-1)
	.byte >(.spkv3-1)
.L0486jumptablelo
	.byte <(.spkv0-1)
	.byte <(.spkv1-1)
	.byte <(.spkv2-1)
	.byte <(.spkv3-1)
.spkv0
 ; spkv0

.spkv1
 ; spkv1

.L0487 ;  speak hahaha : return

    SPEAK hahaha
  RTS
.spkv2
 ; spkv2

.spkv3
 ; spkv3

.L0488 ;  speak watchout : return

    SPEAK watchout
  RTS
.
 ; 

.wizdeathspeak
 ; wizdeathspeak

.L0489 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0489
.condpart20
  RTS
.skipL0489
.L0490 ;  rem ** speech texts for killing the wizard are: Wizard Defeated, Victory, Wizard is dead, Wizard destroyed, Got him

.L0491 ;  wizdeathspeak = rand & 7

 jsr randomize
	AND #7
	STA wizdeathspeak
.L0492 ;  on wizdeathspeak goto spkx0 spkx1 spkx2 spkx3 spkx4 spkx6 spkx6 spkx7

	LDX wizdeathspeak
	LDA .L0492jumptablehi,x
	PHA
	LDA .L0492jumptablelo,x
	PHA
	RTS
.L0492jumptablehi
	.byte >(.spkx0-1)
	.byte >(.spkx1-1)
	.byte >(.spkx2-1)
	.byte >(.spkx3-1)
	.byte >(.spkx4-1)
	.byte >(.spkx6-1)
	.byte >(.spkx6-1)
	.byte >(.spkx7-1)
.L0492jumptablelo
	.byte <(.spkx0-1)
	.byte <(.spkx1-1)
	.byte <(.spkx2-1)
	.byte <(.spkx3-1)
	.byte <(.spkx4-1)
	.byte <(.spkx6-1)
	.byte <(.spkx6-1)
	.byte <(.spkx7-1)
.spkx0
 ; spkx0

.spkx1
 ; spkx1

.L0493 ;  speak wizdestroyed : return

    SPEAK wizdestroyed
  RTS
.spkx2
 ; spkx2

.spkx3
 ; spkx3

.L0494 ;  speak victory : return

    SPEAK victory
  RTS
.spkx4
 ; spkx4

.spkx5
 ; spkx5

.L0495 ;  speak wizdead : return

    SPEAK wizdead
  RTS
.spkx6
 ; spkx6

.L0496 ;  speak wizdefeated : return

    SPEAK wizdefeated
  RTS
.spkx7
 ; spkx7

.L0497 ;  speak gothim : return

    SPEAK gothim
  RTS
.
 ; 

.arrowsgonespeak
 ; arrowsgonespeak

.L0498 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0498
.condpart21
  RTS
.skipL0498
.L0499 ;  rem ** speech texts for running out of arrows are: Ammo Gone, Arrows Gone, Out of Arrows, Out of Ammo

.L0500 ;  arrowsgonespeak = rand & 3

 jsr randomize
	AND #3
	STA arrowsgonespeak
.L0501 ;  on arrowsgonespeak goto spky0 spky1 spky2 spky3

	LDX arrowsgonespeak
	LDA .L0501jumptablehi,x
	PHA
	LDA .L0501jumptablelo,x
	PHA
	RTS
.L0501jumptablehi
	.byte >(.spky0-1)
	.byte >(.spky1-1)
	.byte >(.spky2-1)
	.byte >(.spky3-1)
.L0501jumptablelo
	.byte <(.spky0-1)
	.byte <(.spky1-1)
	.byte <(.spky2-1)
	.byte <(.spky3-1)
.spky0
 ; spky0

.L0502 ;  speak ammogone : return

    SPEAK ammogone
  RTS
.spky1
 ; spky1

.L0503 ;  speak arrowsgone : return

    SPEAK arrowsgone
  RTS
.spky2
 ; spky2

.L0504 ;  speak arrowsout : return

    SPEAK arrowsout
  RTS
.spky3
 ; spky3

.L0505 ;  speak ammoout : return

    SPEAK ammoout
  RTS
.
 ; 

.gotarrowsspeak
 ; gotarrowsspeak

.L0506 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0506
.condpart22
  RTS
.skipL0506
.L0507 ;  rem ** speech texts for picking up the quiver are: More Arrows, Filled Up, Ammo Recharged

.L0508 ;  gotarrowsspeak = rand & 3

 jsr randomize
	AND #3
	STA gotarrowsspeak
.L0509 ;  on gotarrowsspeak goto spkw0 spkw1 spkw2 spkw3

	LDX gotarrowsspeak
	LDA .L0509jumptablehi,x
	PHA
	LDA .L0509jumptablelo,x
	PHA
	RTS
.L0509jumptablehi
	.byte >(.spkw0-1)
	.byte >(.spkw1-1)
	.byte >(.spkw2-1)
	.byte >(.spkw3-1)
.L0509jumptablelo
	.byte <(.spkw0-1)
	.byte <(.spkw1-1)
	.byte <(.spkw2-1)
	.byte <(.spkw3-1)
.spkw0
 ; spkw0

.spkw1
 ; spkw1

.L0510 ;  speak morearrows : return

    SPEAK morearrows
  RTS
.spkw2
 ; spkw2

.L0511 ;  speak filledup : return

    SPEAK filledup
  RTS
.spkw3
 ; spkw3

.L0512 ;  speak ammocharge : return

    SPEAK ammocharge
  RTS
.
 ; 

.bunkerspeak
 ; bunkerspeak

.L0513 ;  rem ** we're not going to say "bunker damaged" in demo mode

.L0514 ;  if demomode = 1 then return

	LDA demomode
	CMP #1
     BNE .skipL0514
.condpart23
  RTS
.skipL0514
.L0515 ;  rem ** speak 'Bunker Damaged' when you reach 37,500 points

.L0516 ;  speak bunkerdamaged

    SPEAK bunkerdamaged
.L0517 ;  rem ** This is so we know the phrase has already been spoken once, and to not repeat it again

.L0518 ;  bunkerspeakflag = 1

	LDA #1
	STA bunkerspeakflag
.L0519 ;  return

  RTS
.
 ; 

.level2speak
 ; level2speak

.L0520 ;  rem ** say "Level Up" on the atarivox when you've reached level 2

.L0521 ;  speak levelup

    SPEAK levelup
.L0522 ;  rem ** Flag is set so we know we're now on level 2

.L0523 ;  rem ** This is to make sure the speech text isn't repeated more than once

.L0524 ;  level2flag = 1

	LDA #1
	STA level2flag
.L0525 ;  return

  RTS
.
 ; 

.level3speak
 ; level3speak

.L0526 ;  rem ** say "I have advanced" on the atarivox when you've reached level 3

.L0527 ;  speak ihaveadvanced

    SPEAK ihaveadvanced
.L0528 ;  rem ** Flag is set so we know we're now on level 3

.L0529 ;  rem ** This is to make sure the speech text isn't repeated more than once

.L0530 ;  level3flag = 1

	LDA #1
	STA level3flag
.L0531 ;  return

  RTS
.
 ; 

.level4speak
 ; level4speak

.L0532 ;  rem ** say "More Power" on the atarivox when you've reached level 4

.L0533 ;  speak morepower

    SPEAK morepower
.L0534 ;  rem ** Flag is set so we know we're now on level 4

.L0535 ;  rem ** This is to make sure the speech text isn't repeated more than once

.L0536 ;  level4flag = 1

	LDA #1
	STA level4flag
.L0537 ;  return

  RTS
.
 ; 

.level5speak
 ; level5speak

.L0538 ;  rem ** say "I am stronger" on the atarivox when you've reached level 5

.L0539 ;  speak iamstronger

    SPEAK iamstronger
.L0540 ;  rem ** Flag is set so we know we're now on level 5

.L0541 ;  rem ** This is to make sure the speech text isn't repeated more than once

.L0542 ;  level5flag = 1

	LDA #1
	STA level5flag
.L0543 ;  return

  RTS
.
 ; 

.L0544 ;  rem ** Initialize game, prepare to start

.
 ; 

.init
 ; init

.L0545 ;  rem ** Init is where the game bounces back to from the titlescreen when you start the game

.
 ; 

.L0546 ;  rem ** reset flags for dev mode and wizard mode

.L0547 ;  devmodecount = 0 : savejoy = 0 : devmodeenabled = 0

	LDA #0
	STA devmodecount
	STA savejoy
	STA devmodeenabled
.L0548 ;  wizmodeover = 0

	LDA #0
	STA wizmodeover
.
 ; 

.L0549 ;  rem ** reset score to zero

.L0550 ;  score0 = 000000

	LDA #$00
	STA score0+2
	LDA #$00
	STA score0+1
	LDA #$00
	STA score0
.
 ; 

.L0551 ;  rem ** set initial number of arrows to maximum set on titlescreen option

.L0552 ;  rem ** reduce further based on level if needed

.L0553 ;  arrowcounter = arrowsvalue

	LDA arrowsvalue
	STA arrowcounter
.
 ; 

.L0554 ;  rem ** Import Graphics

.
 ; 

.L0555 ;  rem ** the last digit is the default palette to use with plotmap

.L0556 ;  rem ** these are the tile sets that make up the dungeon walls

.L0557 ;  incgraphic tileset_NS_Maze1.png 320A 1 0 0

.L0558 ;  incgraphic tileset_NS_Maze2.png 320A 1 0 0

.L0559 ;  incgraphic tileset_NS_Maze3.png 320A 1 0 0

.L0560 ;  incgraphic tileset_NS_Maze4.png 320A 1 0 0

.L0561 ;  incgraphic blanks.png 320A 1 0 0

.
 ; 

.L0562 ;  rem ** characters for the alphabet and numbers

.L0563 ;  incgraphic alphabet_8_wide.png 160A 0 1 2 

.L0564 ;  incgraphic scoredigits_8_wide.png 320A 0 1 2 

.
 ; 

.L0565 ;  rem ** god mode sprite for the status bar

.L0566 ;  incgraphic godmode.png 320A 1 0 2

.
 ; 

.L0567 ;  rem ** the mini spider webs that the spider spins throughout the dungeon

.L0568 ;  incgraphic miniwebtop.png 320A 0 1 

.L0569 ;  incgraphic miniwebbottom.png 320A 0 1

.
 ; 

.L0570 ;  rem ** the AtariAge Logo

.L0571 ;  rem **  AtariAge Rocks!

.L0572 ;  incgraphic aa_left_1.png 320A 0 1 2 

.L0573 ;  incgraphic aa_left_2.png 320A 0 1 2 

.L0574 ;  incgraphic aa_left_3.png 320A 0 1 2 

.L0575 ;  incgraphic aa_left_4.png 320A 0 1 2 

.L0576 ;  incgraphic aa_right_1.png 320A 0 1 2 

.L0577 ;  incgraphic aa_right_2.png 320A 0 1 2 

.L0578 ;  incgraphic aa_right_3.png 320A 0 1 2 

.L0579 ;  incgraphic aa_right_4.png 320A 0 1 2 

.
 ; 

.L0580 ;  rem ** start a new graphics block

.L0581 ;  rem ** animated graphics -must- be in the same graphics bank

.L0582 ;  rem ** newblock forces a move to the next graphics bank

.L0583 ;  newblock

.
 ; 

.L0584 ;  rem ** atascii characterset

.L0585 ;  rem ** import the characterset, used in the titlescreen

.L0586 ;  incgraphic atascii.png 320A 

.
 ; 

.L0587 ;  rem ** Main player graphic for the archer

.L0588 ;  rem ** We used a zone height of 8, so sprites taller than 8 must be split

.L0589 ;  rem ** Also, there are separate sprites for the archer facing left or right (no sprite flipping like the 2600)

.L0590 ;  incgraphic archer_1_top_faceright.png 320A 0 1 2

.L0591 ;  incgraphic archer_2_top_faceright.png 320A 0 1 2

.L0592 ;  incgraphic archer_3_top_faceright.png 320A 0 1 2

.L0593 ;  incgraphic archer_4_top_faceright.png 320A 0 1 2

.L0594 ;  incgraphic archer_5_top_faceright.png 320A 0 1 2

.L0595 ;  incgraphic archer_6_top_faceright.png 320A 0 1 2

.L0596 ;  incgraphic archer_7_top_faceright.png 320A 0 1 2

.L0597 ;  incgraphic archer_1_top_faceleft.png 320A 0 1 2

.L0598 ;  incgraphic archer_2_top_faceleft.png 320A 0 1 2

.L0599 ;  incgraphic archer_3_top_faceleft.png 320A 0 1 2

.L0600 ;  incgraphic archer_4_top_faceleft.png 320A 0 1 2

.L0601 ;  incgraphic archer_5_top_faceleft.png 320A 0 1 2

.L0602 ;  incgraphic archer_6_top_faceleft.png 320A 0 1 2

.L0603 ;  incgraphic archer_7_top_faceleft.png 320A 0 1 2

.L0604 ;  incgraphic archer_1_bottom_faceright.png 320A 0 1 2

.L0605 ;  incgraphic archer_2_bottom_faceright.png 320A 0 1 2

.L0606 ;  incgraphic archer_3_bottom_faceright.png 320A 0 1 2

.L0607 ;  incgraphic archer_4_bottom_faceright.png 320A 0 1 2

.L0608 ;  incgraphic archer_5_bottom_faceright.png 320A 0 1 2

.L0609 ;  incgraphic archer_6_bottom_faceright.png 320A 0 1 2

.L0610 ;  incgraphic archer_7_bottom_faceright.png 320A 0 1 2

.L0611 ;  incgraphic archer_1_bottom_faceleft.png 320A 0 1 2

.L0612 ;  incgraphic archer_2_bottom_faceleft.png 320A 0 1 2

.L0613 ;  incgraphic archer_3_bottom_faceleft.png 320A 0 1 2

.L0614 ;  incgraphic archer_4_bottom_faceleft.png 320A 0 1 2

.L0615 ;  incgraphic archer_5_bottom_faceleft.png 320A 0 1 2

.L0616 ;  incgraphic archer_6_bottom_faceleft.png 320A 0 1 2

.L0617 ;  incgraphic archer_7_bottom_faceleft.png 320A 0 1 2

.
 ; 

.L0618 ;  rem ** Main player graphic death animation

.L0619 ;  incgraphic archer_death_top1.png 320A 0 1 2

.L0620 ;  incgraphic archer_death_top2.png 320A 0 1 2

.L0621 ;  incgraphic archer_death_top3.png 320A 0 1 2

.L0622 ;  incgraphic archer_death_top4.png 320A 0 1 2

.L0623 ;  incgraphic archer_death_top5.png 320A 0 1 2

.L0624 ;  incgraphic archer_death_top6.png 320A 0 1 2

.L0625 ;  incgraphic archer_death_top7.png 320A 0 1 2

.L0626 ;  incgraphic archer_death_top8.png 320A 0 1 2

.L0627 ;  incgraphic archer_death_top9.png 320A 0 1 2

.L0628 ;  incgraphic archer_death_top10.png 320A 0 1 2

.L0629 ;  incgraphic archer_death_top11.png 320A 0 1 2

.L0630 ;  incgraphic archer_death_top12.png 320A 0 1 2

.L0631 ;  incgraphic archer_death_top13.png 320A 0 1 2

.L0632 ;  incgraphic archer_death_top14.png 320A 0 1 2

.L0633 ;  incgraphic archer_death_top15.png 320A 0 1 2

.L0634 ;  incgraphic archer_death_top16.png 320A 0 1 2

.L0635 ;  incgraphic archer_death_bottom1.png 320A 0 1 2

.L0636 ;  incgraphic archer_death_bottom2.png 320A 0 1 2

.L0637 ;  incgraphic archer_death_bottom3.png 320A 0 1 2

.L0638 ;  incgraphic archer_death_bottom4.png 320A 0 1 2

.L0639 ;  incgraphic archer_death_bottom5.png 320A 0 1 2

.L0640 ;  incgraphic archer_death_bottom6.png 320A 0 1 2

.L0641 ;  incgraphic archer_death_bottom7.png 320A 0 1 2

.L0642 ;  incgraphic archer_death_bottom8.png 320A 0 1 2

.L0643 ;  incgraphic archer_death_bottom9.png 320A 0 1 2

.L0644 ;  incgraphic archer_death_bottom10.png 320A 0 1 2

.L0645 ;  incgraphic archer_death_bottom11.png 320A 0 1 2

.L0646 ;  incgraphic archer_death_bottom12.png 320A 0 1 2

.L0647 ;  incgraphic archer_death_bottom13.png 320A 0 1 2

.L0648 ;  incgraphic archer_death_bottom14.png 320A 0 1 2

.L0649 ;  incgraphic archer_death_bottom15.png 320A 0 1 2

.L0650 ;  incgraphic archer_death_bottom16.png 320A 0 1 2

.
 ; 

.L0651 ;  rem ** Explosion animation for all enemies

.L0652 ;  incgraphic explode1top.png 320A 0 1 2

.L0653 ;  incgraphic explode2top.png 320A 0 1 2

.L0654 ;  incgraphic explode3top.png 320A 0 1 2

.L0655 ;  incgraphic explode4top.png 320A 0 1 2

.L0656 ;  incgraphic explode5top.png 320A 0 1 2

.L0657 ;  incgraphic explode6top.png 320A 0 1 2

.L0658 ;  incgraphic explode7top.png 320A 0 1 2

.L0659 ;  incgraphic explode8top.png 320A 0 1 2

.L0660 ;  incgraphic explode1bottom.png 320A 0 1 2

.L0661 ;  incgraphic explode2bottom.png 320A 0 1 2

.L0662 ;  incgraphic explode3bottom.png 320A 0 1 2

.L0663 ;  incgraphic explode4bottom.png 320A 0 1 2

.L0664 ;  incgraphic explode5bottom.png 320A 0 1 2

.L0665 ;  incgraphic explode6bottom.png 320A 0 1 2

.L0666 ;  incgraphic explode7bottom.png 320A 0 1 2

.L0667 ;  incgraphic explode8bottom.png 320A 0 1 2

.
 ; 

.L0668 ;  rem ** Main player graphic for freezing

.L0669 ;  incgraphic archer_still_top.png 320A 0 1 2

.L0670 ;  incgraphic archer_still_top_reverse.png 320A 1 0 2

.L0671 ;  incgraphic archer_still_bottom.png 320A 0 1 2

.L0672 ;  incgraphic archer_still_bottom_reverse.png 320A 1 0 2

.
 ; 

.L0673 ;  rem ** bat 1

.L0674 ;  incgraphic bat1.png 320A 0 1 2

.L0675 ;  incgraphic bat2.png 320A 0 1 2

.L0676 ;  incgraphic bat3.png 320A 0 1 2

.
 ; 

.L0677 ;  rem ** bat 2

.L0678 ;  incgraphic bat4.png 320A 0 1 2

.L0679 ;  incgraphic bat5.png 320A 0 1 2

.L0680 ;  incgraphic bat6.png 320A 0 1 2

.
 ; 

.L0681 ;  rem ** bat explode frames

.L0682 ;  incgraphic bat_explode1.png 320A 0 1 2

.L0683 ;  incgraphic bat_explode2.png 320A 0 1 2

.L0684 ;  incgraphic bat_explode3.png 320A 0 1 2

.L0685 ;  incgraphic bat_explode4.png 320A 0 1 2

.
 ; 

.L0686 ;  rem ** Quiver

.L0687 ;  incgraphic quiver1.png 320A 0 1 2

.L0688 ;  incgraphic quiver2.png 320A 0 1 2

.
 ; 

.L0689 ;  rem ** monster 1 (8x16, stitched together)

.L0690 ;  rem ** Demon Bat

.L0691 ;  incgraphic monster1top.png 320A 1 0 2

.L0692 ;  incgraphic monster2top.png 320A 1 0 2

.L0693 ;  incgraphic monster1bottom.png 320A 1 0 2

.L0694 ;  incgraphic monster2bottom.png 320A 1 0 2

.
 ; 

.L0695 ;  rem ** monster 2 (8x16, stitched together)

.L0696 ;  rem ** Snake

.L0697 ;  incgraphic monster3top.png 320A 1 0 2

.L0698 ;  incgraphic monster4top.png 320A 1 0 2

.L0699 ;  incgraphic monster3bottom.png 320A 1 0 2

.L0700 ;  incgraphic monster4bottom.png 320A 1 0 2

.
 ; 

.L0701 ;  rem ** monster 3 (8x16, stitched together)

.L0702 ;  rem ** Skeleton Warrior

.L0703 ;  incgraphic monster5top.png 320A 0 1 2

.L0704 ;  incgraphic monster6top.png 320A 0 1 2

.L0705 ;  incgraphic monster5bottom.png 320A 0 1 2

.L0706 ;  incgraphic monster6bottom.png 320A 0 1 2

.
 ; 

.L0707 ;  rem ** spider

.L0708 ;  incgraphic spd1top.png 320A 0 1 2

.L0709 ;  incgraphic spd2top.png 320A 0 1 2

.L0710 ;  incgraphic spd3top.png 320A 0 1 2

.L0711 ;  incgraphic spd4top.png 320A 0 1 2

.L0712 ;  incgraphic spd1bot.png 320A 0 1 2

.L0713 ;  incgraphic spd2bot.png 320A 0 1 2

.L0714 ;  incgraphic spd3bot.png 320A 0 1 2

.L0715 ;  incgraphic spd4bot.png 320A 0 1 2

.
 ; 

.L0716 ;  rem ** status bar items

.L0717 ;  incgraphic lives.png 320A 0 1 2

.L0718 ;  incgraphic level.png 320A 0 1 2

.L0719 ;  incgraphic score.png 320A 0 1 2

.L0720 ;  incgraphic arrows.png 320A 0 1 2

.L0721 ;  incgraphic man.png 320A 0 1 2

.L0722 ;  incgraphic blackbox.png 320A 0 1 2

.L0723 ;  incgraphic level1.png 320A 0 1 2

.L0724 ;  incgraphic level2.png 320A 0 1 2

.L0725 ;  incgraphic level3.png 320A 0 1 2

.L0726 ;  incgraphic level4.png 320A 0 1 2

.L0727 ;  incgraphic level5.png 320A 0 1 2

.L0728 ;  incgraphic level6.png 320A 0 1 2

.L0729 ;  incgraphic level7.png 320A 0 1 2

.L0730 ;  incgraphic level8.png 320A 0 1 2

.L0731 ;  incgraphic level9.png 320A 0 1 2

.
 ; 

.L0732 ;  rem ** game over text

.L0733 ;  incgraphic gameovertext.png 320A 0 1 2

.
 ; 

.L0734 ;  rem ** arrow fired from archer's bow

.L0735 ;  incgraphic arrow.png 320A 1 0 2

.L0736 ;  incgraphic arrow2.png 320A 1 0 2

.L0737 ;  incgraphic arrow_large.png 320A 1 0 2

.
 ; 

.L0738 ;  rem ** used for center bunker

.L0739 ;  incgraphic widebar_top_broken.png 320A 0 1 2

.L0740 ;  incgraphic widebar.png 320A 0 1 2

.L0741 ;  incgraphic widebar_top.png 320A 0 1 2

.L0742 ;  incgraphic widebar_bottom.png 320A 0 1 2

.
 ; 

.L0743 ;  rem ** titlescreen graphic (256x128)

.L0744 ;  incbanner tsbanner.png 320A 1 0 2

.
 ; 

.L0745 ;  rem ** spider web at top left of screen

.L0746 ;  incgraphic web1.png 320A 1 0 2

.L0747 ;  incgraphic web2.png 320A 1 0 2

.L0748 ;  incgraphic web3.png 320A 1 0 2

.L0749 ;  incgraphic web4.png 320A 1 0 2

.L0750 ;  incgraphic web5.png 320A 1 0 2

.L0751 ;  incgraphic web6.png 320A 1 0 2

.L0752 ;  incgraphic web7.png 320A 1 0 2

.L0753 ;  incgraphic web8.png 320A 1 0 2

.
 ; 

.L0754 ;  rem ** spider death animation

.L0755 ;  incgraphic spider1top_explode1.png 320A 0 1 2

.L0756 ;  incgraphic spider1top_explode2.png 320A 0 1 2

.L0757 ;  incgraphic spider1top_explode3.png 320A 0 1 2

.L0758 ;  incgraphic spider1top_explode4.png 320A 0 1 2

.L0759 ;  incgraphic spider1top_explode5.png 320A 0 1 2

.L0760 ;  incgraphic spider1bottom_explode1.png 320A 0 1 2

.L0761 ;  incgraphic spider1bottom_explode2.png 320A 0 1 2

.L0762 ;  incgraphic spider1bottom_explode3.png 320A 0 1 2

.L0763 ;  incgraphic spider1bottom_explode4.png 320A 0 1 2

.L0764 ;  incgraphic spider1bottom_explode5.png 320A 0 1 2

.
 ; 

.L0765 ;  rem ** arrow indicator on status bar

.L0766 ;  incgraphic arrowbar0.png 320A 0 1 2

.L0767 ;  incgraphic arrowbar1.png 320A 0 1 2

.L0768 ;  incgraphic arrowbar2.png 320A 0 1 2

.L0769 ;  incgraphic arrowbar3.png 320A 0 1 2

.L0770 ;  incgraphic arrowbar4.png 320A 0 1 2

.L0771 ;  incgraphic arrowbar5.png 320A 0 1 2

.L0772 ;  incgraphic arrowbar6.png 320A 0 1 2

.L0773 ;  incgraphic arrowbar7.png 320A 0 1 2

.L0774 ;  incgraphic arrowbar8.png 320A 0 1 2

.L0775 ;  incgraphic arrowbar_nolimit.png 320A 1 0 2

.
 ; 

.L0776 ;  rem ** backround for titlescreen graphic

.L0777 ;  incgraphic ts_back1.png 320A 0 1 2

.L0778 ;  incgraphic ts_back2.png 320A 0 1 2

.L0779 ;  incgraphic ts_back3.png 320A 0 1 2

.L0780 ;  incgraphic ts_back4.png 320A 0 1 2

.L0781 ;  incgraphic ts_back5.png 320A 0 1 2

.L0782 ;  incgraphic ts_back6.png 320A 0 1 2

.L0783 ;  incgraphic ts_back7.png 320A 0 1 2

.
 ; 

.L0784 ;  rem ** sprites for wizard

.L0785 ;  incgraphic wizlefttop1.png 320A 0 1 2

.L0786 ;  incgraphic wizlefttop2.png 320A 0 1 2

.L0787 ;  incgraphic wizrighttop1.png 320A 0 1 2

.L0788 ;  incgraphic wizrighttop2.png 320A 0 1 2

.L0789 ;  incgraphic wizleftbottom1.png 320A 0 1 2

.L0790 ;  incgraphic wizleftbottom2.png 320A 0 1 2

.L0791 ;  incgraphic wizrightbottom1.png 320A 0 1 2

.L0792 ;  incgraphic wizrightbottom2.png 320A 0 1 2

.
 ; 

.L0793 ;  rem ** sprite for high score font

.L0794 ;  incgraphic hiscorefont.png 320A

.
 ; 

.L0795 ;  rem ** flashing gems in titlescreen graphic

.L0796 ;  incgraphic ts_back_ruby.png 320A 0 1 2

.
 ; 

.L0797 ;  rem ** the text highlighter in the menu options list

.L0798 ;  incgraphic menuback1.png 320A 0 1 2

.
 ; 

.L0799 ;  rem ** the treasure sprite

.L0800 ;  incgraphic treasure.png 320A 0 1 2

.
 ; 

.L0801 ;  rem ** the sword sprite

.L0802 ;  incgraphic swordtop.png 320A 0 1 2

.L0803 ;  incgraphic swordbottom.png 320A 0 1 2

.
 ; 

.L0804 ;  rem ** 'demo mode' text sprite

.L0805 ;  incgraphic demomodetext.png 320A 0 1 2

.
 ; 

.L0806 ;  rem ** 'developer mode' text sprite

.L0807 ;  incgraphic devmode.png 320A 1 0 2

.
 ; 

.L0808 ;  rem ** import character set

.L0809 ;  characterset alphabet_8_wide

    lda #>alphabet_8_wide
    sta CHARBASE
    sta sCHARBASE

    lda #(alphabet_8_wide_mode | %01100000)
    sta charactermode

.
 ; 

.L0810 ;  rem ** Map screen generated from 'Tiled' application

.L0811 ;  incmapfile Dungeon.tmx

	JMP skipmapdata5
Dungeon
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(blanks+0)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze4+6)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze4+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze4+4)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze3+1)
 .byte <(tileset_NS_Maze3+1)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze2+12)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+13)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+12)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+13)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+12)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+13)
 .byte <(tileset_NS_Maze4+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+10)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+9)
 .byte <(tileset_NS_Maze4+0)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+8)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+12)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+13)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+8)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+12)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+11)
 .byte <(tileset_NS_Maze1+8)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(tileset_NS_Maze2+4)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+11)
 .byte <(tileset_NS_Maze4+10)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+0)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+3)
 .byte <(blanks+0)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+0)
 .byte <(tileset_NS_Maze3+13)
 .byte <(tileset_NS_Maze3+13)
 .byte <(tileset_NS_Maze3+13)
 .byte <(blanks+0)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+8)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+8)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+5)
 .byte <(tileset_NS_Maze3+6)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze3+13)
 .byte <(tileset_NS_Maze3+13)
 .byte <(tileset_NS_Maze3+13)
 .byte <(tileset_NS_Maze2+6)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+2)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze4+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+0)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+10)
 .byte <(tileset_NS_Maze2+9)
 .byte <(tileset_NS_Maze2+9)
 .byte <(tileset_NS_Maze2+9)
 .byte <(tileset_NS_Maze2+11)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+11)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze2+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+11)
 .byte <(tileset_NS_Maze3+0)
 .byte <(tileset_NS_Maze3+1)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze2+11)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze4+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+11)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+8)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze4+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+11)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+9)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze3+4)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze2+2)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+0)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+5)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze2+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+8)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+8)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+8)
 .byte <(tileset_NS_Maze1+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+3)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+3)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze4+2)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+10)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze2+6)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+5)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+12)
 .byte <(tileset_NS_Maze2+0)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze2+14)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+11)
 .byte <(tileset_NS_Maze3+0)
 .byte <(tileset_NS_Maze1+4)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(tileset_NS_Maze1+6)
 .byte <(tileset_NS_Maze1+7)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze3+11)
 .byte <(tileset_NS_Maze1+5)
 .byte <(tileset_NS_Maze4+5)
 .byte <(tileset_NS_Maze4+6)
 .byte <(tileset_NS_Maze2+7)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze1+15)
 .byte <(tileset_NS_Maze1+13)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(blanks+1)
 .byte <(tileset_NS_Maze2+1)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze3+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze2+4)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze4+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+0)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+2)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze1+1)
 .byte <(tileset_NS_Maze3+15)
 .byte <(tileset_NS_Maze2+5)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
 .byte <(tileset_NS_Maze3+14)
skipmapdata5
.
 ; 

.L0812 ;  rem ** we need to let the 7800 know where the character set is

.L0813 ;  characterset blanks

    lda #>blanks
    sta CHARBASE
    sta sCHARBASE

    lda #(blanks_mode | %01100000)
    sta charactermode

.
 ; 

.L0814 ;  rem ** copy a screen to our screen ram

.L0815 ;  rem ** to allow for collision detection

.L0816 ;  screen = 0

	LDA #0
	STA screen
.L0817 ;  gosub newscreen

 jsr .newscreen

.
 ; 

.L0818 ;  rem ** setup the screen memory for rendering the screen ram.

.L0819 ;  rem ** "Dungeon.tmx" should work with any map, so long as

.L0820 ;  rem ** all tmx files use the same palettes in the same area.

.L0821 ;  rem ** If that's not true, the "newscreen" subroutine should

.L0822 ;  rem ** be updated with conditional logic to plotmapfile with

.L0823 ;  rem ** the right tmx file.

.
 ; 

.L0824 ;  rem ** This command erases all sprites and characters that you've previously

.L0825 ;  rem **  drawn on the screen, so you can draw the next screen

.L0826 ;  clearscreen

 jsr clearscreen
.
 ; 

.L0827 ;  rem **  plot the screen map

.L0828 ;  plotmapfile Dungeon.tmx screenram 0 0 40 26

 lda #(<plotmapfiledata6)
 sta temp8
 lda #(>plotmapfiledata6)
 sta temp9
 jsr plotcharloop
 jmp skipplotmapfiledata6
plotmapfiledata6
 .byte <(screenram+0), >(screenram+0), $00, 0, 0
 .byte <(screenram+32), >(screenram+32), $18, 128, 0
 .byte <(screenram+40), >(screenram+40), $00, 0, 1
 .byte <(screenram+72), >(screenram+72), $18, 128, 1
 .byte <(screenram+80), >(screenram+80), $00, 0, 2
 .byte <(screenram+112), >(screenram+112), $18, 128, 2
 .byte <(screenram+120), >(screenram+120), $00, 0, 3
 .byte <(screenram+152), >(screenram+152), $18, 128, 3
 .byte <(screenram+160), >(screenram+160), $00, 0, 4
 .byte <(screenram+192), >(screenram+192), $18, 128, 4
 .byte <(screenram+200), >(screenram+200), $00, 0, 5
 .byte <(screenram+232), >(screenram+232), $18, 128, 5
 .byte <(screenram+240), >(screenram+240), $00, 0, 6
 .byte <(screenram+272), >(screenram+272), $18, 128, 6
 .byte <(screenram+280), >(screenram+280), $00, 0, 7
 .byte <(screenram+312), >(screenram+312), $18, 128, 7
 .byte <(screenram+320), >(screenram+320), $00, 0, 8
 .byte <(screenram+352), >(screenram+352), $18, 128, 8
 .byte <(screenram+360), >(screenram+360), $00, 0, 9
 .byte <(screenram+392), >(screenram+392), $18, 128, 9
 .byte <(screenram+400), >(screenram+400), $00, 0, 10
 .byte <(screenram+432), >(screenram+432), $18, 128, 10
 .byte <(screenram+440), >(screenram+440), $00, 0, 11
 .byte <(screenram+472), >(screenram+472), $18, 128, 11
 .byte <(screenram+480), >(screenram+480), $00, 0, 12
 .byte <(screenram+512), >(screenram+512), $18, 128, 12
 .byte <(screenram+520), >(screenram+520), $00, 0, 13
 .byte <(screenram+552), >(screenram+552), $18, 128, 13
 .byte <(screenram+560), >(screenram+560), $00, 0, 14
 .byte <(screenram+592), >(screenram+592), $18, 128, 14
 .byte <(screenram+600), >(screenram+600), $00, 0, 15
 .byte <(screenram+632), >(screenram+632), $18, 128, 15
 .byte <(screenram+640), >(screenram+640), $00, 0, 16
 .byte <(screenram+672), >(screenram+672), $18, 128, 16
 .byte <(screenram+680), >(screenram+680), $00, 0, 17
 .byte <(screenram+712), >(screenram+712), $18, 128, 17
 .byte <(screenram+720), >(screenram+720), $00, 0, 18
 .byte <(screenram+752), >(screenram+752), $18, 128, 18
 .byte <(screenram+760), >(screenram+760), $00, 0, 19
 .byte <(screenram+792), >(screenram+792), $18, 128, 19
 .byte <(screenram+800), >(screenram+800), $00, 0, 20
 .byte <(screenram+832), >(screenram+832), $18, 128, 20
 .byte <(screenram+840), >(screenram+840), $00, 0, 21
 .byte <(screenram+872), >(screenram+872), $18, 128, 21
 .byte <(screenram+880), >(screenram+880), $00, 0, 22
 .byte <(screenram+912), >(screenram+912), $18, 128, 22
 .byte <(screenram+920), >(screenram+920), $00, 0, 23
 .byte <(screenram+952), >(screenram+952), $18, 128, 23
 .byte <(screenram+960), >(screenram+960), $00, 0, 24
 .byte <(screenram+992), >(screenram+992), $18, 128, 24
 .byte <(screenram+1000), >(screenram+1000), $00, 0, 25
 .byte <(screenram+1032), >(screenram+1032), $18, 128, 25
 .byte 0,0
skipplotmapfiledata6
.
 ; 

.L0829 ;  rem ** plot stuff that doesn't change

.L0830 ;  rem ** this is to save cycles, they don't need to be plotted every frame in the main loop

.L0831 ;  plotsprite score 2 64 208

    lda #<score
    sta temp1

    lda #>score
    sta temp2

    lda #(64|score_width_twoscompliment)
    sta temp3

    lda #64
    sta temp4

    lda #208

    sta temp5

    lda #(score_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0832 ;  plotsprite lives 2 3 208

    lda #<lives
    sta temp1

    lda #>lives
    sta temp2

    lda #(64|lives_width_twoscompliment)
    sta temp3

    lda #3
    sta temp4

    lda #208

    sta temp5

    lda #(lives_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0833 ;  plotsprite level 2 33 208

    lda #<level
    sta temp1

    lda #>level
    sta temp2

    lda #(64|level_width_twoscompliment)
    sta temp3

    lda #33
    sta temp4

    lda #208

    sta temp5

    lda #(level_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0834 ;  plotsprite arrows 2 112 208

    lda #<arrows
    sta temp1

    lda #>arrows
    sta temp2

    lda #(64|arrows_width_twoscompliment)
    sta temp3

    lda #112
    sta temp4

    lda #208

    sta temp5

    lda #(arrows_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0835 ;  plotsprite widebar 2 76 88

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #88

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0836 ;  plotsprite widebar 2 76 96

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #96

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0837 ;  plotsprite widebar_bottom 2 76 104

    lda #<widebar_bottom
    sta temp1

    lda #>widebar_bottom
    sta temp2

    lda #(64|widebar_bottom_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #104

    sta temp5

    lda #(widebar_bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.
 ; 

.L0838 ;  rem ** plot the spider web in the top left

.L0839 ;  rem ** this also doesn't change throughout the game

.L0840 ;  plotsprite web1 0 0 8

    lda #<web1
    sta temp1

    lda #>web1
    sta temp2

    lda #(0|web1_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #8

    sta temp5

    lda #(web1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0841 ;  plotsprite web2 0 0 16

    lda #<web2
    sta temp1

    lda #>web2
    sta temp2

    lda #(0|web2_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #16

    sta temp5

    lda #(web2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0842 ;  plotsprite web3 0 0 24

    lda #<web3
    sta temp1

    lda #>web3
    sta temp2

    lda #(0|web3_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #24

    sta temp5

    lda #(web3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0843 ;  plotsprite web4 0 0 32

    lda #<web4
    sta temp1

    lda #>web4
    sta temp2

    lda #(0|web4_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #32

    sta temp5

    lda #(web4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0844 ;  plotsprite web5 0 0 40

    lda #<web5
    sta temp1

    lda #>web5
    sta temp2

    lda #(0|web5_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #40

    sta temp5

    lda #(web5_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0845 ;  plotsprite web6 0 0 48

    lda #<web6
    sta temp1

    lda #>web6
    sta temp2

    lda #(0|web6_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #48

    sta temp5

    lda #(web6_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0846 ;  plotsprite web7 0 0 56

    lda #<web7
    sta temp1

    lda #>web7
    sta temp2

    lda #(0|web7_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #56

    sta temp5

    lda #(web7_mode|%01000000)
    sta temp6

 jsr plotsprite
.L0847 ;  plotsprite web8 0 0 64

    lda #<web8
    sta temp1

    lda #>web8
    sta temp2

    lda #(0|web8_width_twoscompliment)
    sta temp3

    lda #0
    sta temp4

    lda #64

    sta temp5

    lda #(web8_mode|%01000000)
    sta temp6

 jsr plotsprite
.
 ; 

.L0848 ;  rem ** we bake a string-like version of level value into the screen

.L0849 ;  rem ** this saves cycles we'd waste plotting it every frame

.L0850 ;  plotchars levelvaluebcdhi 6 51 26 2

    lda #<levelvaluebcdhi
    sta temp1

    lda #>levelvaluebcdhi
    sta temp2

    lda #30 ; width in two's complement
    ora #192 ; palette left shifted 5 bits
    sta temp3
    lda #51
    sta temp4

    lda #26
    sta temp5

 jsr plotcharacters
.
 ; 

.L0851 ;  rem ** we bake in the score too

.L0852 ;  plotchars score0bcd0 6 82 26 6

    lda #<score0bcd0
    sta temp1

    lda #>score0bcd0
    sta temp2

    lda #26 ; width in two's complement
    ora #192 ; palette left shifted 5 bits
    sta temp3
    lda #82
    sta temp4

    lda #26
    sta temp5

 jsr plotcharacters
.
 ; 

.L0853 ;  rem ** bake in the life counter too

.L0854 ;  plotchars livesbcdhi 6 20 26 2

    lda #<livesbcdhi
    sta temp1

    lda #>livesbcdhi
    sta temp2

    lda #30 ; width in two's complement
    ora #192 ; palette left shifted 5 bits
    sta temp3
    lda #20
    sta temp4

    lda #26
    sta temp5

 jsr plotcharacters
.
 ; 

.L0855 ;  rem ** You may occasionally have code that you don't want to execute during the visible screen. 

.L0856 ;  rem ** For these occasions you can call the drawwait command. This command will only return after 

.L0857 ;  rem ** the visible screen has been completely displayed.

.L0858 ;  drawwait

 jsr drawwait
.
 ; 

.L0859 ;  rem ** set our color palettes based on automatic png->7800 color conversion

.L0860 ;  rem ** As we're using 320A mode, the sprites are limited to a single color

.
 ; 

.L0861 ;  rem ** Black (Bats & web & maze & wizard)

.L0862 ;  P0C1 = 0

	LDA #0
	STA P0C1
.L0863 ;  P0C2 = 0

	LDA #0
	STA P0C2
.L0864 ;  P0C3 = 0

	LDA #0
	STA P0C3
.
 ; 

.L0865 ;  rem ** Green (color for enemies after they've lost one hitpoint)

.L0866 ;  P1C1 = 0

	LDA #0
	STA P1C1
.L0867 ;  P1C2 = $D6

	LDA #$D6
	STA P1C2
.L0868 ;  P1C3 = 0

	LDA #0
	STA P1C3
.
 ; 

.L0869 ;  rem ** dark grey (Center Bunker and arrows)

.L0870 ;  P2C1 = 0

	LDA #0
	STA P2C1
.L0871 ;  P2C2 = $06

	LDA #$06
	STA P2C2
.L0872 ;  P2C3 = 0

	LDA #0
	STA P2C3
.
 ; 

.L0873 ;  rem ** Snake Starting color (blue)

.L0874 ;  P3C1 = 0

	LDA #0
	STA P3C1
.L0875 ;  P3C2 = $A8

	LDA #$A8
	STA P3C2
.L0876 ;  P3C3 = 0

	LDA #0
	STA P3C3
.
 ; 

.L0877 ;  rem ** Purple (Spider)

.L0878 ;  P4C1 = 0

	LDA #0
	STA P4C1
.L0879 ;  P4C2 = $66

	LDA #$66
	STA P4C2
.L0880 ;  P4C3 = 0

	LDA #0
	STA P4C3
.
 ; 

.L0881 ;  rem ** Skeleton Warrior starting color (light blue) and Treasure starting color

.L0882 ;  P5C1 = 0

	LDA #0
	STA P5C1
.L0883 ;  P5C2 = $78

	LDA #$78
	STA P5C2
.L0884 ;  P5C3 = 0

	LDA #0
	STA P5C3
.
 ; 

.L0885 ;  rem ** Brown (Status Bar Numbers & Arrow Indicator)

.L0886 ;  P6C1 = 0

	LDA #0
	STA P6C1
.L0887 ;  P6C2 = $F6

	LDA #$F6
	STA P6C2
.L0888 ;  P6C3 = 0

	LDA #0
	STA P6C3
.
 ; 

.L0889 ;  rem ** Orange (Player)

.L0890 ;  P7C1 = 0

	LDA #0
	STA P7C1
.L0891 ;  P7C2 = $26

	LDA #$26
	STA P7C2
.L0892 ;  P7C3 = 0

	LDA #0
	STA P7C3
.
 ; 

.L0893 ;  rem **  The savescreen command saves any sprites and characters that you've 

.L0894 ;  rem **  drawn on the screen since the last clearscreen. The restorescreen erases 

.L0895 ;  rem **  any sprites and characters that you've drawn on the screen since

.L0896 ;  rem **  the last savescreen.

.L0897 ;  savescreen

 jsr savescreen
.
 ; 

.L0898 ;  rem ** background color

.L0899 ;  rem ** the background color is reversable.  Holding down the pause button when you start up

.L0900 ;  rem ** the game will reverse the colors of the background and the dungeon

.L0901 ;  if colorchange = 0 then SBACKGRND = levelcolors[levelvalue]

	LDA colorchange
	CMP #0
     BNE .skipL0901
.condpart24
	LDX levelvalue
	LDA levelcolors,x
	STA SBACKGRND
.skipL0901
.L0902 ;  if colorchange = 1 then SBACKGRND = 0

	LDA colorchange
	CMP #1
     BNE .skipL0902
.condpart25
	LDA #0
	STA SBACKGRND
.skipL0902
.
 ; 

.L0903 ;  rem ** set life counter to the lives value from the menu

.L0904 ;  rem ** it's changeable if developer mode is activated

.L0905 ;  lifecounter = livesvalue

	LDA livesvalue
	STA lifecounter
.
 ; 

.L0906 ;  rem ** Set initial location of player

.L0907 ;  rem 84x 80y

.L0908 ;  p0_x = 84

	LDA #84
	STA p0_x
.L0909 ;  p0_y = 68

	LDA #68
	STA p0_y
.
 ; 

.L0910 ;  rem ** Set initial location of bat 1

.L0911 ;  bat1x = 133

	LDA #133
	STA bat1x
.L0912 ;  bat1y = 48

	LDA #48
	STA bat1y
.
 ; 

.L0913 ;  rem ** Set initial location of bat 2

.L0914 ;  bat2x = 22

	LDA #22
	STA bat2x
.L0915 ;  bat2y = 90

	LDA #90
	STA bat2y
.
 ; 

.L0916 ;  rem ** Set initial location of quiver

.L0917 ;  quiverx = 135

	LDA #135
	STA quiverx
.L0918 ;  quivery = 140

	LDA #140
	STA quivery
.
 ; 

.L0919 ;  rem ** Set initial location of spider

.L0920 ;  spiderx = 8

	LDA #8
	STA spiderx
.L0921 ;  spidery = 35

	LDA #35
	STA spidery
.
 ; 

.L0922 ;  rem ** Set initial HP for each enemy

.L0923 ;  r1hp = 1

	LDA #1
	STA r1hp
.L0924 ;  r2hp = 1

	LDA #1
	STA r2hp
.L0925 ;  r3hp = 1

	LDA #1
	STA r3hp
.
 ; 

.L0926 ;  rem ** set initial location of treasure to offscreen

.L0927 ;  treasurex = 200

	LDA #200
	STA treasurex
.L0928 ;  treasurey = 200

	LDA #200
	STA treasurey
.
 ; 

.L0929 ;  rem ** set initial location of sword to offscreen

.L0930 ;  swordx = 200

	LDA #200
	STA swordx
.L0931 ;  swordy = 200

	LDA #200
	STA swordy
.
 ; 

.L0932 ;  rem ** set initial values for firing quiver to offscreen

.L0933 ;  xpos_fire = 200

	LDA #200
	STA xpos_fire
.
 ; 

.L0934 ;  rem ** set initial firing direction to up

.L0935 ;  fire_dir_save = 1

	LDA #1
	STA fire_dir_save
.L0936 ;  fire_dir = 1 :  rem set initial fire direction to up

	LDA #1
	STA fire_dir
.
 ; 

.L0937 ;  rem ** quiver powerup is not onscreen when game starts

.L0938 ;  quiverflag = 0

	LDA #0
	STA quiverflag
.
 ; 

.L0939 ;  rem ** set initial bunker fire blocking ability to on

.L0940 ;  bunkerbuster = 0

	LDA #0
	STA bunkerbuster
.
 ; 

.L0941 ;  rem ** set extra life counter to 0 

.L0942 ;  rem ** after collecting 5 treasures you get an extra life and this counter is reset

.L0943 ;  extralife_counter = 0

	LDA #0
	STA extralife_counter
.
 ; 

.L0944 ;  rem ** initially place enemy arrows offscreen

.L0945 ;  r1x_fire = 200

	LDA #200
	STA r1x_fire
.L0946 ;  r2x_fire = 200

	LDA #200
	STA r2x_fire
.L0947 ;  r3x_fire = 200

	LDA #200
	STA r3x_fire
.
 ; 

.L0948 ;  rem ** initially, the sword is offscreen, the invicibility counter is set to 0,

.L0949 ;  rem ** the invicibility flag is set to 0 (off), the flag for placing the treasure

.L0950 ;  rem ** is set to 0 (off)

.L0951 ;  sword_rplace = 0

	LDA #0
	STA sword_rplace
.L0952 ;  sword_rplace2 = 0

	LDA #0
	STA sword_rplace2
.L0953 ;  invincible_counter1 = 0

	LDA #0
	STA invincible_counter1
.L0954 ;  invincible_counter2 = 0

	LDA #0
	STA invincible_counter2
.L0955 ;  invincible_on = 0

	LDA #0
	STA invincible_on
.L0956 ;  treasureplaced = 0

	LDA #0
	STA treasureplaced
.L0957 ;  swordplaced = 0

	LDA #0
	STA swordplaced
.L0958 ;  explosionflash = 1

	LDA #1
	STA explosionflash
.
 ; 

.L0959 ;  rem ** resets counters for how long treasure will stay on-screen

.L0960 ;  rem ** the treasure stays onscreen for approximately 12 seconds before it disappears 

.L0961 ;  rem ** and the counter is reset again

.L0962 ;  treasuretimer = 0

	LDA #0
	STA treasuretimer
.L0963 ;  treasuretimer2 = 0

	LDA #0
	STA treasuretimer2
.
 ; 

.L0964 ;  rem ** set initial location of enemies to offscreen

.L0965 ;  monster1x = 0 : monster2x = 0 : monster3x = 0

	LDA #0
	STA monster1x
	STA monster2x
	STA monster3x
.
 ; 

.L0966 ;  rem ** reset counter that controls how often the spider spins a small web

.L0967 ;  spiderwebcountdown = 0

	LDA #0
	STA spiderwebcountdown
.
 ; 

.L0968 ;  rem ** reset speech flags

.L0969 ;  bunkerspeakflag = 0

	LDA #0
	STA bunkerspeakflag
.L0970 ;  arrowspeakflag = 0

	LDA #0
	STA arrowspeakflag
.
 ; 

.L0971 ;  rem ** Set level flags for initial enemy spawning on a level change

.L0972 ;  rem ** this was implemented to prevent an enemy from spawning directly on top of you

.L0973 ;  value1flag = 0 :  value2flag = 0 :  value3flag = 0 :  value4flag = 0 :  value5flag = 0

	LDA #0
	STA value1flag
	STA value2flag
	STA value3flag
	STA value4flag
	STA value5flag
.
 ; 

.L0974 ;  rem ** Wizard modes starts turned off

.L0975 ;  rem ** the wizard appears in-between levels, and never appears again after you've reached level 5

.L0976 ;  wizmode = 0

	LDA #0
	STA wizmode
.
 ; 

.L0977 ;  rem ** if skill=0 you've selected a specific level from developer mode. Skip the section immediately after.

.L0978 ;  if scorevalue = 1  &&  skill = 0 then sc1 = $00 : sc2 = $00 : sc3 = $00 : goto main

	LDA scorevalue
	CMP #1
     BNE .skipL0978
.condpart26
	LDA skill
	CMP #0
     BNE .skip26then
.condpart27
	LDA #$00
	STA sc1
	STA sc2
	STA sc3
 jmp .main

.skip26then
.skipL0978
.L0979 ;  if scorevalue = 2  &&  skill = 0 then sc1 = $00 : sc2 = $74 : sc3 = $00 : goto main

	LDA scorevalue
	CMP #2
     BNE .skipL0979
.condpart28
	LDA skill
	CMP #0
     BNE .skip28then
.condpart29
	LDA #$00
	STA sc1
	LDA #$74
	STA sc2
	LDA #$00
	STA sc3
 jmp .main

.skip28then
.skipL0979
.L0980 ;  if scorevalue = 3  &&  skill = 0 then sc1 = $01 : sc2 = $49 : sc3 = $00 : goto main

	LDA scorevalue
	CMP #3
     BNE .skipL0980
.condpart30
	LDA skill
	CMP #0
     BNE .skip30then
.condpart31
	LDA #$01
	STA sc1
	LDA #$49
	STA sc2
	LDA #$00
	STA sc3
 jmp .main

.skip30then
.skipL0980
.L0981 ;  if scorevalue = 4  &&  skill = 0 then sc1 = $02 : sc2 = $99 : sc3 = $00 : goto main

	LDA scorevalue
	CMP #4
     BNE .skipL0981
.condpart32
	LDA skill
	CMP #0
     BNE .skip32then
.condpart33
	LDA #$02
	STA sc1
	LDA #$99
	STA sc2
	LDA #$00
	STA sc3
 jmp .main

.skip32then
.skipL0981
.L0982 ;  if scorevalue = 5  &&  skill = 0 then sc1 = $05 : sc2 = $99 : sc3 = $00 : goto main

	LDA scorevalue
	CMP #5
     BNE .skipL0982
.condpart34
	LDA skill
	CMP #0
     BNE .skip34then
.condpart35
	LDA #$05
	STA sc1
	LDA #$99
	STA sc2
	LDA #$00
	STA sc3
 jmp .main

.skip34then
.skipL0982
.
 ; 

.L0983 ;  rem ** scorevalue is a developer mode option that lets you pick a score value just under the requirement

.L0984 ;  rem ** to move up to the next level.  This was implemented for testing wizard mode.

.L0985 ;  if scorevalue = 1 then sc1 = $00 : sc2 = $00 : sc3 = $00 : levelvalue = 1

	LDA scorevalue
	CMP #1
     BNE .skipL0985
.condpart36
	LDA #$00
	STA sc1
	STA sc2
	STA sc3
	LDA #1
	STA levelvalue
.skipL0985
.L0986 ;  if scorevalue = 2 then sc1 = $00 : sc2 = $74 : sc3 = $00 : levelvalue = 1

	LDA scorevalue
	CMP #2
     BNE .skipL0986
.condpart37
	LDA #$00
	STA sc1
	LDA #$74
	STA sc2
	LDA #$00
	STA sc3
	LDA #1
	STA levelvalue
.skipL0986
.L0987 ;  if scorevalue = 3 then sc1 = $01 : sc2 = $49 : sc3 = $00 : levelvalue = 2

	LDA scorevalue
	CMP #3
     BNE .skipL0987
.condpart38
	LDA #$01
	STA sc1
	LDA #$49
	STA sc2
	LDA #$00
	STA sc3
	LDA #2
	STA levelvalue
.skipL0987
.L0988 ;  if scorevalue = 4 then sc1 = $02 : sc2 = $99 : sc3 = $00 : levelvalue = 3

	LDA scorevalue
	CMP #4
     BNE .skipL0988
.condpart39
	LDA #$02
	STA sc1
	LDA #$99
	STA sc2
	LDA #$00
	STA sc3
	LDA #3
	STA levelvalue
.skipL0988
.L0989 ;  if scorevalue = 5 then sc1 = $05 : sc2 = $99 : sc3 = $00 : levelvalue = 4

	LDA scorevalue
	CMP #5
     BNE .skipL0989
.condpart40
	LDA #$05
	STA sc1
	LDA #$99
	STA sc2
	LDA #$00
	STA sc3
	LDA #4
	STA levelvalue
.skipL0989
.
 ; 

.L0990 ;  rem ** you start on level 2 in advanced, level 3 in Expert

.L0991 ;  if skill = 3 then levelvalue = 2

	LDA skill
	CMP #3
     BNE .skipL0991
.condpart41
	LDA #2
	STA levelvalue
.skipL0991
.L0992 ;  if skill = 4 then levelvalue = 3

	LDA skill
	CMP #4
     BNE .skipL0992
.condpart42
	LDA #3
	STA levelvalue
.skipL0992
.
 ; 

.L0993 ;  rem ** Begin main game loop

.
 ; 

.main
 ; main

.
 ; 

.L0994 ;  rem *******************************************************************************************

.L0995 ;  rem ************ Section 1: Game Logic... don't use plot* or *screen commands here ************

.L0996 ;  rem *******************************************************************************************

.
 ; 

.L0997 ;  temp1 = framecounter & 7

	LDA framecounter
	AND #7
	STA temp1
.L0998 ;  if wizmode = 200  &&  temp1 = 0  &&  wizwarpcountdown < 200  &&  wizwarpcountdown > 10  &&  invincible_on = 0 then tempx =  ( framecounter / 16 )  & 7 : tempy = wizmodenotes[tempx] : playsfx sfx_wiz tempy

	LDA wizmode
	CMP #200
     BNE .skipL0998
.condpart43
	LDA temp1
	CMP #0
     BNE .skip43then
.condpart44
	LDA wizwarpcountdown
	CMP #200
     BCS .skip44then
.condpart45
	LDA #10
	CMP wizwarpcountdown
     BCS .skip45then
.condpart46
	LDA invincible_on
	CMP #0
     BNE .skip46then
.condpart47
; complex statement detected
	LDA framecounter
	lsr
	lsr
	lsr
	lsr
	AND #7
	STA tempx
	LDX tempx
	LDA wizmodenotes,x
	STA tempy
    lda #<sfx_wiz
    sta temp1
    lda #>sfx_wiz
    sta temp2
    lda tempy
    sta temp3
    jsr schedulesfx
.skip46then
.skip45then
.skip44then
.skip43then
.skipL0998
.
 ; 

.L0999 ;  rem ** wizard mode audio data

.L01000 ;  rem ** the heartbeat sound is silenced for a unique tune when the wizard is active on the screen

.L01001 ;  data wizmodenotes

	JMP .skipL01001
wizmodenotes
	.byte   16,14,12,10,12,14,12,10,8

.skipL01001
.
 ; 

.L01002 ;  rem ** uncomment this to increase your score by holding down the select button

.L01003 ;  rem ** this was used for debugging and testing and was commented out for released versions of the game

.L01004 ;  rem if switchselect then score0=score0+20

.
 ; 

.L01005 ;  rem ** this code plays the 'beep' sound effect when you press the fire button and you're out of arrows

.L01006 ;  if arrowcounter = 0  &&  !joy0fire  &&  nofireflag <> 1 then nofireflag = 1

	LDA arrowcounter
	CMP #0
     BNE .skipL01006
.condpart48
 bit sINPT1
	BMI .skip48then
.condpart49
	LDA nofireflag
	CMP #1
     BEQ .skip49then
.condpart50
	LDA #1
	STA nofireflag
.skip49then
.skip48then
.skipL01006
.L01007 ;  if nofireflag = 1  &&  joy0fire  &&  arrowcounter = 0 then nofireflag = 2 : playsfx sfx_nofire

	LDA nofireflag
	CMP #1
     BNE .skipL01007
.condpart51
 bit sINPT1
	BPL .skip51then
.condpart52
	LDA arrowcounter
	CMP #0
     BNE .skip52then
.condpart53
	LDA #2
	STA nofireflag
    lda #<sfx_nofire
    sta temp1
    lda #>sfx_nofire
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip52then
.skip51then
.skipL01007
.
 ; 

.L01008 ;  rem ** the below three lines are...

.L01009 ;  const digitstart =  < scoredigits_8_wide

.L01010 ;  levelvaluebcdhi = digitstart

	LDA #digitstart
	STA levelvaluebcdhi
.L01011 ;  levelvaluebcdlo = levelvalue + digitstart

	LDA levelvalue
	CLC
	ADC #digitstart
	STA levelvaluebcdlo
.
 ; 

.L01012 ;  rem ** Wizard Mode code

.L01013 ;  rem **     ...We're off to see the wizard! The wonderful wizard of.... oh, nevermind.

.
 ; 

.L01014 ;  if wizmodeover = 199 then gosub monster1respawn : gosub monster2respawn : gosub monster3respawn : gosub spiderrespawn : gosub bat1respawn : gosub bat2respawn

	LDA wizmodeover
	CMP #199
     BNE .skipL01014
.condpart54
 jsr .monster1respawn
 jsr .monster2respawn
 jsr .monster3respawn
 jsr .spiderrespawn
 jsr .bat1respawn
 jsr .bat2respawn

.skipL01014
.L01015 ;  if wizmode > 0  &&  wizmode < 200 then r1x_fire = 200 : r2x_fire = 200 : r3x_fire = 200

	LDA #0
	CMP wizmode
     BCS .skipL01015
.condpart55
	LDA wizmode
	CMP #200
     BCS .skip55then
.condpart56
	LDA #200
	STA r1x_fire
	STA r2x_fire
	STA r3x_fire
.skip55then
.skipL01015
.L01016 ;  if wizmodeover > 0 then r1x_fire = 200 : r2x_fire = 200 : r3x_fire = 200

	LDA #0
	CMP wizmodeover
     BCS .skipL01016
.condpart57
	LDA #200
	STA r1x_fire
	STA r2x_fire
	STA r3x_fire
.skipL01016
.L01017 ;  if wizmode = 0  ||  wizmode = 200 then goto skipwizmodeshift

	LDA wizmode
	CMP #0
     BNE .skipL01017
.condpart58
 jmp .condpart59
.skipL01017
	LDA wizmode
	CMP #200
     BNE .skip14OR
.condpart59
 jmp .skipwizmodeshift

.skip14OR
.L01018 ;  rem ** change color scheme based on whether or not pause was pressed when the game was started (colorchange variable)

.L01019 ;  if wizmode = 90  &&  colorchange = 0 then P0C2 = 0

	LDA wizmode
	CMP #90
     BNE .skipL01019
.condpart60
	LDA colorchange
	CMP #0
     BNE .skip60then
.condpart61
	LDA #0
	STA P0C2
.skip60then
.skipL01019
.L01020 ;  if wizmode = 90  &&  colorchange = 1 then SBACKGRND = 0

	LDA wizmode
	CMP #90
     BNE .skipL01020
.condpart62
	LDA colorchange
	CMP #1
     BNE .skip62then
.condpart63
	LDA #0
	STA SBACKGRND
.skip62then
.skipL01020
.L01021 ;  if wizmode = 150  &&  colorchange = 0 then SBACKGRND = levelcolors[levelvalue]

	LDA wizmode
	CMP #150
     BNE .skipL01021
.condpart64
	LDA colorchange
	CMP #0
     BNE .skip64then
.condpart65
	LDX levelvalue
	LDA levelcolors,x
	STA SBACKGRND
.skip64then
.skipL01021
.L01022 ;  if wizmode = 150  &&  colorchange = 1 then P0C2 = levelcolors[levelvalue]

	LDA wizmode
	CMP #150
     BNE .skipL01022
.condpart66
	LDA colorchange
	CMP #1
     BNE .skip66then
.condpart67
	LDX levelvalue
	LDA levelcolors,x
	STA P0C2
.skip66then
.skipL01022
.L01023 ;  wizmode = wizmode + 1

	LDA wizmode
	CLC
	ADC #1
	STA wizmode
.skipwizmodeshift
 ; skipwizmodeshift

.L01024 ;  if wizmodeover = 0 then goto skipwizmodeovershift

	LDA wizmodeover
	CMP #0
     BNE .skipL01024
.condpart68
 jmp .skipwizmodeovershift

.skipL01024
.L01025 ;  if wizmodeover = 90  &&  colorchange = 0 then SBACKGRND = 0

	LDA wizmodeover
	CMP #90
     BNE .skipL01025
.condpart69
	LDA colorchange
	CMP #0
     BNE .skip69then
.condpart70
	LDA #0
	STA SBACKGRND
.skip69then
.skipL01025
.L01026 ;  if wizmodeover = 90  &&  colorchange = 1 then P0C2 = 0

	LDA wizmodeover
	CMP #90
     BNE .skipL01026
.condpart71
	LDA colorchange
	CMP #1
     BNE .skip71then
.condpart72
	LDA #0
	STA P0C2
.skip71then
.skipL01026
.L01027 ;  if wizmodeover = 150  &&  colorchange = 0 then P0C2 = levelcolors[levelvalue]

	LDA wizmodeover
	CMP #150
     BNE .skipL01027
.condpart73
	LDA colorchange
	CMP #0
     BNE .skip73then
.condpart74
	LDX levelvalue
	LDA levelcolors,x
	STA P0C2
.skip73then
.skipL01027
.L01028 ;  if wizmodeover = 150  &&  colorchange = 1 then SBACKGRND = levelcolors[levelvalue]

	LDA wizmodeover
	CMP #150
     BNE .skipL01028
.condpart75
	LDA colorchange
	CMP #1
     BNE .skip75then
.condpart76
	LDX levelvalue
	LDA levelcolors,x
	STA SBACKGRND
.skip75then
.skipL01028
.L01029 ;  wizmodeover = wizmodeover + 1

	LDA wizmodeover
	CLC
	ADC #1
	STA wizmodeover
.L01030 ;  if wizmodeover = 200 then wizmode = 0 : wizmodeover = 0

	LDA wizmodeover
	CMP #200
     BNE .skipL01030
.condpart77
	LDA #0
	STA wizmode
	STA wizmodeover
.skipL01030
.skipwizmodeovershift
 ; skipwizmodeovershift

.
 ; 

.L01031 ;  if wizmode < 200 then goto skipwizmodeanimation

	LDA wizmode
	CMP #200
     BCS .skipL01031
.condpart78
 jmp .skipwizmodeanimation

.skipL01031
.L01032 ;  rem ** first check if he's facing left or right... he always faces the player

.L01033 ;  rem ** "up left down right"

.L01034 ;  if wizdir = 1 then wizanimationframe = 0

	LDA wizdir
	CMP #1
     BNE .skipL01034
.condpart79
	LDA #0
	STA wizanimationframe
.skipL01034
.L01035 ;  if wizdir = 3 then wizanimationframe = 2

	LDA wizdir
	CMP #3
     BNE .skipL01035
.condpart80
	LDA #2
	STA wizanimationframe
.skipL01035
.L01036 ;  rem ** then periodically use the alternate animation frame

.L01037 ;  if  ( frame & 8 )  = 0 then wizanimationframe = wizanimationframe | 1 else wizanimationframe = wizanimationframe & %11111110

; complex condition detected
; complex statement detected
	LDA frame
	AND #8
	CMP #0
     BNE .skipL01037
.condpart81
	LDA wizanimationframe
	ORA #1
	STA wizanimationframe
 jmp .skipelse0
.skipL01037
	LDA wizanimationframe
	AND #%11111110
	STA wizanimationframe
.skipelse0
.skipwizmodeanimation
 ; skipwizmodeanimation

.
 ; 

.L01038 ;  if wizmode < 200 then skipmorewizlogic

	LDA wizmode
	CMP #200
 if ((* - .skipmorewizlogic) < 127) && ((* - .skipmorewizlogic) > -128)
	bcc .skipmorewizlogic
 else
	bcs .0skipskipmorewizlogic
	jmp .skipmorewizlogic
.0skipskipmorewizlogic
 endif
.L01039 ;  if wizmodeover > 0 then skipmorewizlogic

	LDA #0
	CMP wizmodeover
 if ((* - .skipmorewizlogic) < 127) && ((* - .skipmorewizlogic) > -128)
	bcc .skipmorewizlogic
 else
	bcs .1skipskipmorewizlogic
	jmp .skipmorewizlogic
.1skipskipmorewizlogic
 endif
.L01040 ;  if wizwarpcountdown > 0  &&  wizmodeover = 0 then wizwarpcountdown = wizwarpcountdown - 1 : if wizwarpcountdown = 0 then gosub warpwizard

	LDA #0
	CMP wizwarpcountdown
     BCS .skipL01040
.condpart82
	LDA wizmodeover
	CMP #0
     BNE .skip82then
.condpart83
	LDA wizwarpcountdown
	SEC
	SBC #1
	STA wizwarpcountdown
	LDA wizwarpcountdown
	CMP #0
     BNE .skip83then
.condpart84
 jsr .warpwizard

.skip83then
.skip82then
.skipL01040
.L01041 ;  if wizwarpcountdown < 200 then gosub wizlogic  : goto skipmorewizlogic

	LDA wizwarpcountdown
	CMP #200
     BCS .skipL01041
.condpart85
 jsr .wizlogic
 jmp .skipmorewizlogic

.skipL01041
.L01042 ;  temploop = 0 : gosub skip_r1fire

	LDA #0
	STA temploop
 jsr .skip_r1fire

.skipmorewizlogic
 ; skipmorewizlogic

.
 ; 

.L01043 ;  rem ** have the wizard speak right after the intro tune ends

.L01044 ;  if wizmode = 199 then gosub wizstartspeak

	LDA wizmode
	CMP #199
     BNE .skipL01044
.condpart86
 jsr .wizstartspeak

.skipL01044
.
 ; 

.L01045 ;  rem ** skip demo mode countdown if you're playing the actual game

.L01046 ;  rem ** if demomode=0, you're playing the game

.L01047 ;  if demomode = 0 then goto skipdemoreturn

	LDA demomode
	CMP #0
     BNE .skipL01047
.condpart87
 jmp .skipdemoreturn

.skipL01047
.L01048 ;  temp8 = frame & 63

	LDA frame
	AND #63
	STA temp8
.L01049 ;  if temp8 = 0 then demomodecountdown = demomodecountdown - 1

	LDA temp8
	CMP #0
     BNE .skipL01049
.condpart88
	LDA demomodecountdown
	SEC
	SBC #1
	STA demomodecountdown
.skipL01049
.L01050 ;  if demomodecountdown = 0 then demomode = 1 : demomodecountdown = 5 : goto titlescreen

	LDA demomodecountdown
	CMP #0
     BNE .skipL01050
.condpart89
	LDA #1
	STA demomode
	LDA #5
	STA demomodecountdown
 jmp .titlescreen

.skipL01050
.skipdemoreturn
 ; skipdemoreturn

.
 ; 

.L01051 ;  rem ** to prevent gameover flag from being set in demo mode

.L01052 ;  if demomode = 1 then gameoverflag = 0

	LDA demomode
	CMP #1
     BNE .skipL01052
.condpart90
	LDA #0
	STA gameoverflag
.skipL01052
.
 ; 

.L01053 ;  rem ** this makes the enemy explosion flash

.L01054 ;  rem ** ran out of colors for the bloody red explosion that was wanted, making it flash was a compromise

.L01055 ;  explosioncolor = explosionflash

	LDA explosionflash
	STA explosioncolor
.L01056 ;  explosionflash = explosionflash + 1

	LDA explosionflash
	CLC
	ADC #1
	STA explosionflash
.L01057 ;  if explosionflash = 8 then explosionflash = 1

	LDA explosionflash
	CMP #8
     BNE .skipL01057
.condpart91
	LDA #1
	STA explosionflash
.skipL01057
.
 ; 

.L01058 ;  rem ** well, reboot if you hit reset...

.L01059 ;  rem **        ...oh, and kill the audio too

.L01060 ;  if switchreset then AUDV0 = 0 : AUDV1 = 0 : reboot

 jsr checkresetswitch
	BNE .skipL01060
.condpart92
	LDA #0
	STA AUDV0
	STA AUDV1
	JMP START
.skipL01060
.
 ; 

.L01061 ;  rem ** explode any onscreen enemies at the start of wizmode. no extra points.

.L01062 ;  if wizmode <> 2 then skipexplodingallenemies

	LDA wizmode
	CMP #2
 if ((* - .skipexplodingallenemies) < 127) && ((* - .skipexplodingallenemies) > -128)
	BNE .skipexplodingallenemies
 else
	beq .2skipskipexplodingallenemies
	jmp .skipexplodingallenemies
.2skipskipexplodingallenemies
 endif
.L01063 ;  if monster1type < 255  &&  enemy1deathflag = 0 then enemy1deathflag = 1 : explodeframe1 = 0

	LDA monster1type
	CMP #255
     BCS .skipL01063
.condpart93
	LDA enemy1deathflag
	CMP #0
     BNE .skip93then
.condpart94
	LDA #1
	STA enemy1deathflag
	LDA #0
	STA explodeframe1
.skip93then
.skipL01063
.L01064 ;  if monster2type < 255  &&  enemy2deathflag = 0 then enemy2deathflag = 1 : explodeframe2 = 0

	LDA monster2type
	CMP #255
     BCS .skipL01064
.condpart95
	LDA enemy2deathflag
	CMP #0
     BNE .skip95then
.condpart96
	LDA #1
	STA enemy2deathflag
	LDA #0
	STA explodeframe2
.skip95then
.skipL01064
.L01065 ;  if monster3type < 255  &&  enemy3deathflag = 0 then enemy3deathflag = 1 : explodeframe3 = 0

	LDA monster3type
	CMP #255
     BCS .skipL01065
.condpart97
	LDA enemy3deathflag
	CMP #0
     BNE .skip97then
.condpart98
	LDA #1
	STA enemy3deathflag
	LDA #0
	STA explodeframe3
.skip97then
.skipL01065
.L01066 ;  if spiderdeathflag = 0 then spiderdeathflag = 1 : spiderdeathframe = 0

	LDA spiderdeathflag
	CMP #0
     BNE .skipL01066
.condpart99
	LDA #1
	STA spiderdeathflag
	LDA #0
	STA spiderdeathframe
.skipL01066
.L01067 ;  if levelvalue < 4  &&  bat2deathflag = 0 then bat2deathflag = 1 : bat2deathframe = 0

	LDA levelvalue
	CMP #4
     BCS .skipL01067
.condpart100
	LDA bat2deathflag
	CMP #0
     BNE .skip100then
.condpart101
	LDA #1
	STA bat2deathflag
	LDA #0
	STA bat2deathframe
.skip100then
.skipL01067
.L01068 ;  if levelvalue < 3  &&  bat1deathflag = 0 then bat1deathflag = 1 : bat1deathframe = 0

	LDA levelvalue
	CMP #3
     BCS .skipL01068
.condpart102
	LDA bat1deathflag
	CMP #0
     BNE .skip102then
.condpart103
	LDA #1
	STA bat1deathflag
	LDA #0
	STA bat1deathframe
.skip102then
.skipL01068
.skipexplodingallenemies
 ; skipexplodingallenemies

.
 ; 

.L01069 ;  rem ** Set level flags for initial enemy spawning on a level change, and reset offscreen enemies to x=0

.L01070 ;  if levelvalue = 1  &&  value1flag = 0 then level1spawnflag = 1 :  value1flag = 1 :  monster2x = 0 :  monster3x = 0

	LDA levelvalue
	CMP #1
     BNE .skipL01070
.condpart104
	LDA value1flag
	CMP #0
     BNE .skip104then
.condpart105
	LDA #1
	STA level1spawnflag
	STA value1flag
	LDA #0
	STA monster2x
	STA monster3x
.skip104then
.skipL01070
.L01071 ;  if levelvalue = 2  &&  value2flag = 0 then level2spawnflag = 1 :  value2flag = 1 :  monster1x = 0 :  monster3x = 0

	LDA levelvalue
	CMP #2
     BNE .skipL01071
.condpart106
	LDA value2flag
	CMP #0
     BNE .skip106then
.condpart107
	LDA #1
	STA level2spawnflag
	STA value2flag
	LDA #0
	STA monster1x
	STA monster3x
.skip106then
.skipL01071
.L01072 ;  if levelvalue = 3  &&  value3flag = 0 then level3spawnflag = 1 :  value3flag = 1 :  monster3x = 0

	LDA levelvalue
	CMP #3
     BNE .skipL01072
.condpart108
	LDA value3flag
	CMP #0
     BNE .skip108then
.condpart109
	LDA #1
	STA level3spawnflag
	STA value3flag
	LDA #0
	STA monster3x
.skip108then
.skipL01072
.L01073 ;  if levelvalue = 4  &&  value4flag = 0 then level4spawnflag = 1 :  value4flag = 1 :  monster1x = 0

	LDA levelvalue
	CMP #4
     BNE .skipL01073
.condpart110
	LDA value4flag
	CMP #0
     BNE .skip110then
.condpart111
	LDA #1
	STA level4spawnflag
	STA value4flag
	LDA #0
	STA monster1x
.skip110then
.skipL01073
.L01074 ;  if levelvalue = 5  &&  value5flag = 0 then level5spawnflag = 1 :  value5flag = 1

	LDA levelvalue
	CMP #5
     BNE .skipL01074
.condpart112
	LDA value5flag
	CMP #0
     BNE .skip112then
.condpart113
	LDA #1
	STA level5spawnflag
	STA value5flag
.skip112then
.skipL01074
.
 ; 

.L01075 ;  rem ** below adds the snake to demo mode but disables the skeleton warrior

.L01076 ;  rem ** demo mode has two enemies on the blue level 1 screen, which doesn't happen when you actually play

.L01077 ;  if demomode = 1 then monster1type = 1 : monster2type = 3 : monster3type = 255 : goto demoskip1

	LDA demomode
	CMP #1
     BNE .skipL01077
.condpart114
	LDA #1
	STA monster1type
	LDA #3
	STA monster2type
	LDA #255
	STA monster3type
 jmp .demoskip1

.skipL01077
.
 ; 

.L01078 ;  rem ** Set the enemy types for each level

.L01079 ;  rem ** 255 blanks it out.  

.L01080 ;  rem ** Note that the 255 enemy is still on screen but simply invisible - collision routines need to account for that.

.L01081 ;  rem ** Enemies:

.L01082 ;  rem      -monster1type=demon bat

.L01083 ;  rem      -monster2type=snake

.L01084 ;  rem      -monster3type=skeleton warrior

.L01085 ;  rem

.L01086 ;  if levelvalue = 1 then monster1type = 1  : monster2type = 255  : monster3type = 255

	LDA levelvalue
	CMP #1
     BNE .skipL01086
.condpart115
	LDA #1
	STA monster1type
	LDA #255
	STA monster2type
	STA monster3type
.skipL01086
.L01087 ;  if levelvalue = 2 then monster1type = 255  : monster2type = 3  : monster3type = 255  : level2flag = 1

	LDA levelvalue
	CMP #2
     BNE .skipL01087
.condpart116
	LDA #255
	STA monster1type
	LDA #3
	STA monster2type
	LDA #255
	STA monster3type
	LDA #1
	STA level2flag
.skipL01087
.L01088 ;  if levelvalue = 3 then monster1type = 1  : monster2type = 3  : monster3type = 255  : level3flag = 1

	LDA levelvalue
	CMP #3
     BNE .skipL01088
.condpart117
	LDA #1
	STA monster1type
	LDA #3
	STA monster2type
	LDA #255
	STA monster3type
	LDA #1
	STA level3flag
.skipL01088
.L01089 ;  if levelvalue = 4 then monster1type = 255  : monster2type = 3  : monster3type = 5  : level4flag = 1

	LDA levelvalue
	CMP #4
     BNE .skipL01089
.condpart118
	LDA #255
	STA monster1type
	LDA #3
	STA monster2type
	LDA #5
	STA monster3type
	LDA #1
	STA level4flag
.skipL01089
.L01090 ;  if levelvalue = 5 then monster1type = 1  : monster2type = 3  : monster3type = 5  : level5flag = 1

	LDA levelvalue
	CMP #5
     BNE .skipL01090
.condpart119
	LDA #1
	STA monster1type
	LDA #3
	STA monster2type
	LDA #5
	STA monster3type
	LDA #1
	STA level5flag
.skipL01090
.demoskip1
 ; demoskip1

.
 ; 

.L01091 ;  rem ** x value is set to 0 when there is a level change, so any enemy that is appearing

.L01092 ;  rem ** on the screen for the first time will spawn on the opposite side of the screen

.L01093 ;  rem ** That's to avoid an enemy spawning directly on top of you.

.L01094 ;  if monster1x = 0 then gosub monster1respawn

	LDA monster1x
	CMP #0
     BNE .skipL01094
.condpart120
 jsr .monster1respawn

.skipL01094
.L01095 ;  if monster2x = 0 then gosub monster2respawn

	LDA monster2x
	CMP #0
     BNE .skipL01095
.condpart121
 jsr .monster2respawn

.skipL01095
.L01096 ;  if monster3x = 0 then gosub monster3respawn

	LDA monster3x
	CMP #0
     BNE .skipL01096
.condpart122
 jsr .monster3respawn

.skipL01096
.
 ; 

.L01097 ;  if playerinvisibletime > 0 then playerinvisibletime = playerinvisibletime - 1

	LDA #0
	CMP playerinvisibletime
     BCS .skipL01097
.condpart123
	LDA playerinvisibletime
	SEC
	SBC #1
	STA playerinvisibletime
.skipL01097
.
 ; 

.L01098 ;  rem ** Check Level

.L01099 ;  rem 

.L01100 ;  rem ** these are the point values needed to advance to the next level

.L01101 ;  rem ** Level 1: 00,000 Pts

.L01102 ;  rem ** Level 2: 07,500 Pts

.L01103 ;  rem ** Level 3: 15,000 Pts

.L01104 ;  rem ** Level 4: 30,000 Pts

.L01105 ;  rem ** Level 5: 60,000 Pts

.L01106 ;  rem 

.L01107 ;  rem ** these are the skill variable values for each skill level

.L01108 ;  rem ** skill 1 = Novice (start on level 1)

.L01109 ;  rem ** skill 2 = Standard (start on level 1)

.L01110 ;  rem ** skill 3 = Advanced (start on level 2)

.L01111 ;  rem ** skill 4 = Expert (start on level 3)

.L01112 ;  rem

.L01113 ;  rem ** if you start off on level 2 or 3 (Advanced & Expert) you will start with zero points but still need to achieve

.L01114 ;  rem ** the same score in order to level up to the next level.  You'll be on the same level much longer

.L01115 ;  rem

.L01116 ;  if score5flag = 1 then skipsc5

	LDA score5flag
	CMP #1
 if ((* - .skipsc5) < 127) && ((* - .skipsc5) > -128)
	BEQ .skipsc5
 else
	bne .3skipskipsc5
	jmp .skipsc5
.3skipskipsc5
 endif
.L01117 ;  if sc1  =  $06 then levelvalue = 5 :  score5flag = 1 : gosub wizmodeinit : goto skipcl :  rem increase level if score is greater than 60,000

	LDA sc1
	CMP #$06
     BNE .skipL01117
.condpart124
	LDA #5
	STA levelvalue
	LDA #1
	STA score5flag
 jsr .wizmodeinit
 jmp .skipcl
.skipL01117
.skipsc5
 ; skipsc5

.L01118 ;  if score4flag = 1 then skipsc4

	LDA score4flag
	CMP #1
 if ((* - .skipsc4) < 127) && ((* - .skipsc4) > -128)
	BEQ .skipsc4
 else
	bne .4skipskipsc4
	jmp .skipsc4
.4skipskipsc4
 endif
.L01119 ;  if sc1  =  $03 then levelvalue = 4 :  score4flag = 1 : gosub wizmodeinit : goto skipcl :  rem increase level if score is greater than 30,000

	LDA sc1
	CMP #$03
     BNE .skipL01119
.condpart125
	LDA #4
	STA levelvalue
	LDA #1
	STA score4flag
 jsr .wizmodeinit
 jmp .skipcl
.skipL01119
.skipsc4
 ; skipsc4

.L01120 ;  if score3flag = 1 then skipsc3

	LDA score3flag
	CMP #1
 if ((* - .skipsc3) < 127) && ((* - .skipsc3) > -128)
	BEQ .skipsc3
 else
	bne .5skipskipsc3
	jmp .skipsc3
.5skipskipsc3
 endif
.L01121 ;  if sc1  =  $01  &&  sc2  >  $49  &&  sc3  =  $00 then levelvalue = 3 :  score3flag = 1 : gosub wizmodeinit : goto skipcl :  rem increase level if score is greater than 14,500

	LDA sc1
	CMP #$01
     BNE .skipL01121
.condpart126
	LDA #$49
	CMP sc2
     BCS .skip126then
.condpart127
	LDA sc3
	CMP #$00
     BNE .skip127then
.condpart128
	LDA #3
	STA levelvalue
	LDA #1
	STA score3flag
 jsr .wizmodeinit
 jmp .skipcl
.skip127then
.skip126then
.skipL01121
.skipsc3
 ; skipsc3

.L01122 ;  if score2flag = 1 then goto skipsc2

	LDA score2flag
	CMP #1
     BNE .skipL01122
.condpart129
 jmp .skipsc2

.skipL01122
.L01123 ;  if sc1  =  $00  &&  sc2  >  $74  &&  sc3  =  $00 then levelvalue = 2 :  score2flag = 1 : gosub wizmodeinit : goto skipcl :  rem increase level if score is greater than 07,500

	LDA sc1
	CMP #$00
     BNE .skipL01123
.condpart130
	LDA #$74
	CMP sc2
     BCS .skip130then
.condpart131
	LDA sc3
	CMP #$00
     BNE .skip131then
.condpart132
	LDA #2
	STA levelvalue
	LDA #1
	STA score2flag
 jsr .wizmodeinit
 jmp .skipcl
.skip131then
.skip130then
.skipL01123
.skipsc2
 ; skipsc2

.skipcl
 ; skipcl

.
 ; 

.L01124 ;  rem ** after going over 37,500 points monsters will be able to fire into the bunker

.L01125 ;  rem **     ...Watch out!

.L01126 ;  if bunkerspeakflag = 1 then goto skipbunkerhit

	LDA bunkerspeakflag
	CMP #1
     BNE .skipL01126
.condpart133
 jmp .skipbunkerhit

.skipL01126
.L01127 ;  rem ** this also runs the sub that will make the AtariVox say "Bunker Destroyed!"

.L01128 ;  if sc1  =  $03  &&  sc2  >  $74  &&  bunkerspeakflag = 0 then gosub bunkerspeak : bunkerspeakflag = 1 : bunkerbuster = 1

	LDA sc1
	CMP #$03
     BNE .skipL01128
.condpart134
	LDA #$74
	CMP sc2
     BCS .skip134then
.condpart135
	LDA bunkerspeakflag
	CMP #0
     BNE .skip135then
.condpart136
 jsr .bunkerspeak
	LDA #1
	STA bunkerspeakflag
	STA bunkerbuster
.skip135then
.skip134then
.skipL01128
.skipbunkerhit
 ; skipbunkerhit

.
 ; 

.L01129 ;  rem ** play the level up speech each time you level up. Unsurprisingly, the AtariVox says "Level Up!"

.L01130 ;  if level2flag = 1 then goto skiplevel2speech

	LDA level2flag
	CMP #1
     BNE .skipL01130
.condpart137
 jmp .skiplevel2speech

.skipL01130
.L01131 ;  if levelvalue = 2 then gosub level2speak

	LDA levelvalue
	CMP #2
     BNE .skipL01131
.condpart138
 jsr .level2speak

.skipL01131
.skiplevel2speech
 ; skiplevel2speech

.
 ; 

.L01132 ;  if level3flag = 1 then goto skiplevel3speech

	LDA level3flag
	CMP #1
     BNE .skipL01132
.condpart139
 jmp .skiplevel3speech

.skipL01132
.L01133 ;  if levelvalue = 3 then gosub level3speak

	LDA levelvalue
	CMP #3
     BNE .skipL01133
.condpart140
 jsr .level3speak

.skipL01133
.skiplevel3speech
 ; skiplevel3speech

.
 ; 

.L01134 ;  if level4flag = 1 then goto skiplevel4speech

	LDA level4flag
	CMP #1
     BNE .skipL01134
.condpart141
 jmp .skiplevel4speech

.skipL01134
.L01135 ;  if levelvalue = 4 then gosub level4speak

	LDA levelvalue
	CMP #4
     BNE .skipL01135
.condpart142
 jsr .level4speak

.skipL01135
.skiplevel4speech
 ; skiplevel4speech

.
 ; 

.L01136 ;  if level5flag = 1 then goto skiplevel5speech

	LDA level5flag
	CMP #1
     BNE .skipL01136
.condpart143
 jmp .skiplevel5speech

.skipL01136
.L01137 ;  if levelvalue = 5 then gosub level5speak

	LDA levelvalue
	CMP #5
     BNE .skipL01137
.condpart144
 jsr .level5speak

.skipL01137
.skiplevel5speech
 ; skiplevel5speech

.
 ; 

.L01138 ;  rem ** AtariVox speech for when you run out of arrows

.L01139 ;  rem    Note that the arrowspeakflag is reset to 0 when you pick up the quiver (the grab_arrows subroutine)

.L01140 ;  if arrowspeakflag = 1 then goto skiparrow5

	LDA arrowspeakflag
	CMP #1
     BNE .skipL01140
.condpart145
 jmp .skiparrow5

.skipL01140
.L01141 ;  if arrowcounter = 0 then gosub arrowsgonespeak : arrowspeakflag = 1

	LDA arrowcounter
	CMP #0
     BNE .skipL01141
.condpart146
 jsr .arrowsgonespeak
	LDA #1
	STA arrowspeakflag
.skipL01141
.skiparrow5
 ; skiparrow5

.
 ; 

.L01142 ;  rem ** Extra life counter

.L01143 ;  rem ** Pick up X number of treasuress and gain a life.  The counter is incremented every time you pick up a treasure.

.L01144 ;  if extralife_counter = 5 then gosub gainalife : extralife_counter = 0 : speak extralife

	LDA extralife_counter
	CMP #5
     BNE .skipL01144
.condpart147
 jsr .gainalife
	LDA #0
	STA extralife_counter
    SPEAK extralife
.skipL01144
.
 ; 

.L01145 ;  rem ** frame counter

.L01146 ;  frame = frame + 1

	LDA frame
	CLC
	ADC #1
	STA frame
.L01147 ;  altframe = frame & 1

	LDA frame
	AND #1
	STA altframe
.L01148 ;  quadframe = frame & 3

	LDA frame
	AND #3
	STA quadframe
.L01149 ;  objectblink = frame & %00100000

	LDA frame
	AND #%00100000
	STA objectblink
.
 ; 

.L01150 ;  rem ** this controls how long the player is frozen. 

.L01151 ;  rem ** Change the freezecount limit to affect how long player is frozen. This was adjusted many times!

.L01152 ;  freezecount = freezecount + 1

	LDA freezecount
	CLC
	ADC #1
	STA freezecount
.L01153 ;  if freezecount = 160 then freezecount = 1 : freezeflag = 0

	LDA freezecount
	CMP #160
     BNE .skipL01153
.condpart148
	LDA #1
	STA freezecount
	LDA #0
	STA freezeflag
.skipL01153
.
 ; 

.L01154 ;  rem ** this plays the buzzing sound when you're frozen

.L01155 ;  rem ** it's skipped if you're already frozen or are in wizard mode (there's nothing to freeze you in wizard mode)

.L01156 ;  if freezeflag <> 1  ||  wizmode <> 0 then goto skipbuzz

	LDA freezeflag
	CMP #1
     BEQ .skipL01156
.condpart149
 jmp .condpart150
.skipL01156
	LDA wizmode
	CMP #0
     BEQ .skip40OR
.condpart150
 jmp .skipbuzz

.skip40OR
.L01157 ;  if demomode = 0 then playsfx sfx_buzz else playsfx sfx_buzz_demo

	LDA demomode
	CMP #0
     BNE .skipL01157
.condpart151
    lda #<sfx_buzz
    sta temp1
    lda #>sfx_buzz
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
 jmp .skipelse1
.skipL01157
    lda #<sfx_buzz_demo
    sta temp1
    lda #>sfx_buzz_demo
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipelse1
.skipbuzz
 ; skipbuzz

.
 ; 

.L01158 ;  rem ** play the heartbeat background sound

.L01159 ;  rem ** volume increases as you get lower on arrows

.L01160 ;  rem **   ...It's stressful to get low on arrows!

.L01161 ;  soundcounter = soundcounter + 1

	LDA soundcounter
	CLC
	ADC #1
	STA soundcounter
.L01162 ;  if soundcounter > soundcounterlimit[arrowcounter] then soundcounter = 0

	LDX arrowcounter
	LDA soundcounterlimit,x
	CMP soundcounter
     BCS .skipL01162
.condpart152
	LDA #0
	STA soundcounter
.skipL01162
.
 ; 

.L01163 ;  rem ** skip the heartbeat sound if invicibility is on, as there's a separate sound for that

.L01164 ;  rem ** skip the heartbeat sound if demo mode is on, as there is a separate sound for that too

.L01165 ;  if demomode = 1 then goto skipheartbeat

	LDA demomode
	CMP #1
     BNE .skipL01165
.condpart153
 jmp .skipheartbeat

.skipL01165
.L01166 ;  if invincible_on = 1 then goto skipheartbeat

	LDA invincible_on
	CMP #1
     BNE .skipL01166
.condpart154
 jmp .skipheartbeat

.skipL01166
.
 ; 

.L01167 ;  rem ** this changes the heartbeat sound - both rate and volume - as you get low on arrows

.L01168 ;  rem ** heartbeat sound is skipped during wizard mode, it has a separate background tune

.L01169 ;  if soundcounter <> 1 then goto skipbeatsound

	LDA soundcounter
	CMP #1
     BEQ .skipL01169
.condpart155
 jmp .skipbeatsound

.skipL01169
.L01170 ;  if arrowcounter > 7  &&  wizmode = 0 then playsfx sfx_heartbeat

	LDA #7
	CMP arrowcounter
     BCS .skipL01170
.condpart156
	LDA wizmode
	CMP #0
     BNE .skip156then
.condpart157
    lda #<sfx_heartbeat
    sta temp1
    lda #>sfx_heartbeat
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip156then
.skipL01170
.L01171 ;  if arrowcounter = 7  &&  wizmode = 0 then playsfx sfx_heartbeat1

	LDA arrowcounter
	CMP #7
     BNE .skipL01171
.condpart158
	LDA wizmode
	CMP #0
     BNE .skip158then
.condpart159
    lda #<sfx_heartbeat1
    sta temp1
    lda #>sfx_heartbeat1
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip158then
.skipL01171
.L01172 ;  if arrowcounter > 4  &&  arrowcounter < 7  &&  wizmode = 0 then playsfx sfx_heartbeat2

	LDA #4
	CMP arrowcounter
     BCS .skipL01172
.condpart160
	LDA arrowcounter
	CMP #7
     BCS .skip160then
.condpart161
	LDA wizmode
	CMP #0
     BNE .skip161then
.condpart162
    lda #<sfx_heartbeat2
    sta temp1
    lda #>sfx_heartbeat2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip161then
.skip160then
.skipL01172
.L01173 ;  if arrowcounter > 2  &&  arrowcounter < 5  &&  wizmode = 0 then playsfx sfx_heartbeat3

	LDA #2
	CMP arrowcounter
     BCS .skipL01173
.condpart163
	LDA arrowcounter
	CMP #5
     BCS .skip163then
.condpart164
	LDA wizmode
	CMP #0
     BNE .skip164then
.condpart165
    lda #<sfx_heartbeat3
    sta temp1
    lda #>sfx_heartbeat3
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip164then
.skip163then
.skipL01173
.L01174 ;  if arrowcounter < 3  &&  wizmode = 0 then playsfx sfx_heartbeat4

	LDA arrowcounter
	CMP #3
     BCS .skipL01174
.condpart166
	LDA wizmode
	CMP #0
     BNE .skip166then
.condpart167
    lda #<sfx_heartbeat4
    sta temp1
    lda #>sfx_heartbeat4
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip166then
.skipL01174
.skipbeatsound
 ; skipbeatsound

.
 ; 

.skiparrowsgonespeak
 ; skiparrowsgonespeak

.
 ; 

.L01175 ;  rem ** volume for the heartbeat sound as you get lower on arrows

.L01176 ;  data soundcounterlimit

	JMP .skipL01176
soundcounterlimit
	.byte   46, 52, 60, 65, 70, 75, 80, 85, 90, 95

.skipL01176
.
 ; 

.skipheartbeat
 ; skipheartbeat

.
 ; 

.L01177 ;  rem ** play a static heartbeat sound when in demo mode

.L01178 ;  rem ** it doesn't change with the number of arrows remaining like the regular game

.L01179 ;  if demomode <> 1 then goto skipdemoheartbeat

	LDA demomode
	CMP #1
     BEQ .skipL01179
.condpart168
 jmp .skipdemoheartbeat

.skipL01179
.L01180 ;  if soundcounter = 1 then playsfx sfx_heartbeat_demo1

	LDA soundcounter
	CMP #1
     BNE .skipL01180
.condpart169
    lda #<sfx_heartbeat_demo1
    sta temp1
    lda #>sfx_heartbeat_demo1
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01180
.L01181 ;  if soundcounter = 3 then playsfx sfx_heartbeat_demo2

	LDA soundcounter
	CMP #3
     BNE .skipL01181
.condpart170
    lda #<sfx_heartbeat_demo2
    sta temp1
    lda #>sfx_heartbeat_demo2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01181
.L01182 ;  if soundcounter = 5 then playsfx sfx_heartbeat_demo3

	LDA soundcounter
	CMP #5
     BNE .skipL01182
.condpart171
    lda #<sfx_heartbeat_demo3
    sta temp1
    lda #>sfx_heartbeat_demo3
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01182
.L01183 ;  if soundcounter = 7 then playsfx sfx_heartbeat_demo4

	LDA soundcounter
	CMP #7
     BNE .skipL01183
.condpart172
    lda #<sfx_heartbeat_demo4
    sta temp1
    lda #>sfx_heartbeat_demo4
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01183
.skipdemoheartbeat
 ; skipdemoheartbeat

.
 ; 

.L01184 ;  rem ** if you choose the 'fast' speed menu option in developer mode, you move faster

.L01185 ;  if speedvalue = 2 then goto fastplay

	LDA speedvalue
	CMP #2
     BNE .skipL01185
.condpart173
 jmp .fastplay

.skipL01185
.
 ; 

.L01186 ;  rem ** slow down the player & firing

.L01187 ;  slowdown3 = slowdown3 + 1

	LDA slowdown3
	CLC
	ADC #1
	STA slowdown3
.L01188 ;  if slowdown3 = 3 then slowdown3 = 0

	LDA slowdown3
	CMP #3
     BNE .skipL01188
.condpart174
	LDA #0
	STA slowdown3
.skipL01188
.L01189 ;  if slowdown3 < 1 then goto skipdorunframe

	LDA slowdown3
	CMP #1
     BCS .skipL01189
.condpart175
 jmp .skipdorunframe

.skipL01189
.
 ; 

.L01190 ;  rem ** slow down the player in the spider web

.L01191 ;  if p0_x < 28  &&  p0_y < 60  &&  slowdown3 < 2 then goto skipdorunframe

	LDA p0_x
	CMP #28
     BCS .skipL01191
.condpart176
	LDA p0_y
	CMP #60
     BCS .skip176then
.condpart177
	LDA slowdown3
	CMP #2
     BCS .skip177then
.condpart178
 jmp .skipdorunframe

.skip177then
.skip176then
.skipL01191
.fastplay
 ; fastplay

.
 ; 

.L01192 ;  rem ** skip the section that moves the player in demo mode if you're in the normal game

.L01193 ;  if demomode = 0 then skipdemomovplayer

	LDA demomode
	CMP #0
 if ((* - .skipdemomovplayer) < 127) && ((* - .skipdemomovplayer) > -128)
	BEQ .skipdemomovplayer
 else
	bne .6skipskipdemomovplayer
	jmp .skipdemomovplayer
.6skipskipdemomovplayer
 endif
.
 ; 

.L01194 ;  rem ** monster directions are encoded as up(0) left(1) down(2) right(3)

.
 ; 

.L01195 ;  rem ** if you're frozen or dying, don't move

.L01196 ;  if freezeflag = 1 then goto skipdemomovplayer

	LDA freezeflag
	CMP #1
     BNE .skipL01196
.condpart179
 jmp .skipdemomovplayer

.skipL01196
.L01197 ;  if playerdeathflag = 1 then goto skipdemomovplayer

	LDA playerdeathflag
	CMP #1
     BNE .skipL01197
.condpart180
 jmp .skipdemomovplayer

.skipL01197
.L01198 ;  tempx = p0_x

	LDA p0_x
	STA tempx
.L01199 ;  tempy = p0_y

	LDA p0_y
	STA tempy
.L01200 ;  tempdir = demodir

	LDA demodir
	STA tempdir
.L01201 ;  temptype = 1

	LDA #1
	STA temptype
.L01202 ;  templogiccountdown = demochangetimer

	LDA demochangetimer
	STA templogiccountdown
.L01203 ;  if p0_x > 78  &&  p0_x < 90  &&  p0_y > 55  &&  p0_y < 90 then tempdir = 0 : templogiccountdown = 0 : goto skiphumanmonstmeld

	LDA #78
	CMP p0_x
     BCS .skipL01203
.condpart181
	LDA p0_x
	CMP #90
     BCS .skip181then
.condpart182
	LDA #55
	CMP p0_y
     BCS .skip182then
.condpart183
	LDA p0_y
	CMP #90
     BCS .skip183then
.condpart184
	LDA #0
	STA tempdir
	STA templogiccountdown
 jmp .skiphumanmonstmeld

.skip183then
.skip182then
.skip181then
.skipL01203
.L01204 ;  temppositionadjust = 2

	LDA #2
	STA temppositionadjust
.L01205 ;  gosub doeachmonsterlogic

 jsr .doeachmonsterlogic

.skiphumanmonstmeld
 ; skiphumanmonstmeld

.L01206 ;  demochangetimer = templogiccountdown

	LDA templogiccountdown
	STA demochangetimer
.L01207 ;  demodir = tempdir

	LDA tempdir
	STA demodir
.L01208 ;  p0_dx = 0 : p0_dy = 0

	LDA #0
	STA p0_dx
	STA p0_dy
.L01209 ;  if tempdir = 0 then p0_dy = 255

	LDA tempdir
	CMP #0
     BNE .skipL01209
.condpart185
	LDA #255
	STA p0_dy
.skipL01209
.L01210 ;  if tempdir = 1 then p0_dx = 255 : runningdir = 7

	LDA tempdir
	CMP #1
     BNE .skipL01210
.condpart186
	LDA #255
	STA p0_dx
	LDA #7
	STA runningdir
.skipL01210
.L01211 ;  if tempdir = 2 then p0_dy = 1

	LDA tempdir
	CMP #2
     BNE .skipL01211
.condpart187
	LDA #1
	STA p0_dy
.skipL01211
.L01212 ;  if tempdir = 3 then p0_dx = 1 : runningdir = 0

	LDA tempdir
	CMP #3
     BNE .skipL01212
.condpart188
	LDA #1
	STA p0_dx
	LDA #0
	STA runningdir
.skipL01212
.L01213 ;  goto dorunframe

 jmp .dorunframe

.skipdemomovplayer
 ; skipdemomovplayer

.
 ; 

.L01214 ;  rem ** you can't move the player if the game's over, you're frozen, or you're dying.

.L01215 ;  if gameoverflag = 1 then goto skipmove

	LDA gameoverflag
	CMP #1
     BNE .skipL01215
.condpart189
 jmp .skipmove

.skipL01215
.L01216 ;  if freezeflag = 1 then goto skipdorunframe

	LDA freezeflag
	CMP #1
     BNE .skipL01216
.condpart190
 jmp .skipdorunframe

.skipL01216
.L01217 ;  if playerdeathflag = 1 then goto skipdorunframe

	LDA playerdeathflag
	CMP #1
     BNE .skipL01217
.condpart191
 jmp .skipdorunframe

.skipL01217
.
 ; 

.L01218 ;  rem ** player movement logic

.L01219 ;  p0_dx = 0 : p0_dy = 0

	LDA #0
	STA p0_dx
	STA p0_dy
.L01220 ;  if joy0right then fire_dir = 4 : gosub checkmoveright : runningdir = 0  :  goto dorunframe

 bit SWCHA
	BMI .skipL01220
.condpart192
	LDA #4
	STA fire_dir
 jsr .checkmoveright
	LDA #0
	STA runningdir
 jmp .dorunframe

.skipL01220
.L01221 ;  if joy0left then fire_dir = 3 : gosub checkmoveleft : runningdir = 7  :  goto dorunframe

 bit SWCHA
	BVS .skipL01221
.condpart193
	LDA #3
	STA fire_dir
 jsr .checkmoveleft
	LDA #7
	STA runningdir
 jmp .dorunframe

.skipL01221
.L01222 ;  if joy0up then fire_dir = 1 : gosub checkmoveup : goto dorunframe

 lda #$10
 bit SWCHA
	BNE .skipL01222
.condpart194
	LDA #1
	STA fire_dir
 jsr .checkmoveup
 jmp .dorunframe

.skipL01222
.L01223 ;  if joy0down then fire_dir = 2 : gosub checkmovedown : goto dorunframe

 lda #$20
 bit SWCHA
	BNE .skipL01223
.condpart195
	LDA #2
	STA fire_dir
 jsr .checkmovedown
 jmp .dorunframe

.skipL01223
.
 ; 

.L01224 ;  runningframe = 0 :  rem ** this is the frame that is used when standing still

	LDA #0
	STA runningframe
.L01225 ;  goto skipdorunframe  :  rem ** don't advance the animation if the archer isn't moving

 jmp .skipdorunframe
.
 ; 

.dorunframe
 ; dorunframe

.
 ; 

.L01226 ;  rem ** move the player

.L01227 ;  p0_x = p0_x + p0_dx  :  p0_y = p0_y + p0_dy

	LDA p0_x
	CLC
	ADC p0_dx
	STA p0_x
	LDA p0_y
	CLC
	ADC p0_dy
	STA p0_y
.
 ; 

.L01228 ;  rem ** Animation Speed

.L01229 ;  rem ** the "&7" bit slows down the animation. If you need slower, try "&15", or "&3" for faster.

.L01230 ;  if  ( frame & 3 )  = 0 then runningframe = runningframe + 1 : if runningframe = 7 then runningframe = 0

; complex condition detected
; complex statement detected
	LDA frame
	AND #3
	CMP #0
     BNE .skipL01230
.condpart196
	LDA runningframe
	CLC
	ADC #1
	STA runningframe
	LDA runningframe
	CMP #7
     BNE .skip196then
.condpart197
	LDA #0
	STA runningframe
.skip196then
.skipL01230
.skipdorunframe
 ; skipdorunframe

.
 ; 

.L01231 ;  rem ** Quiver placement section

.
 ; 

.L01232 ;  rem ** If the Max Arrows option is set to 'off', we'll skip the quiver powerup placement entirely

.L01233 ;  rem **   ...don't want the quiver to appear if you have unlimited arrows

.L01234 ;  if arrowsvalue = 9 then quiverx = 200 : goto skipquiverplacement

	LDA arrowsvalue
	CMP #9
     BNE .skipL01234
.condpart198
	LDA #200
	STA quiverx
 jmp .skipquiverplacement

.skipL01234
.
 ; 

.L01235 ;  rem ** if you have arrows, don't display the quiver powerup.  

.L01236 ;  rem ** quiverx=200 places the quiver offscreen, quiverflag=0 indicates you have an inventory of arrows,

.L01237 ;  rem ** and quiverplaced=0 resets the flag so the quiver can be randomly placed again in the future.

.L01238 ;  if arrowcounter > 0 then quiverx = 200 : quiverflag = 0 : quiverplaced = 0

	LDA #0
	CMP arrowcounter
     BCS .skipL01238
.condpart199
	LDA #200
	STA quiverx
	LDA #0
	STA quiverflag
	STA quiverplaced
.skipL01238
.
 ; 

.L01239 ;  rem ** if you run out of arrows, set the flag to indicate you have 0 arrows

.L01240 ;  if arrowcounter = 0 then quiverflag = 1

	LDA arrowcounter
	CMP #0
     BNE .skipL01240
.condpart200
	LDA #1
	STA quiverflag
.skipL01240
.
 ; 

.L01241 ;  rem ** jump to random quiver x/y placement subroutine

.L01242 ;  if quiverflag = 1 then gosub quiverplacer

	LDA quiverflag
	CMP #1
     BNE .skipL01242
.condpart201
 jsr .quiverplacer

.skipL01242
.
 ; 

.L01243 ;  rem ** skip the quiverplacer sub below

.L01244 ;  goto skipquiverplacement

 jmp .skipquiverplacement

.
 ; 

.quiverplacer
 ; quiverplacer

.L01245 ;  rem ** if the quiver placed flag is on, it means this sub has already been run once.

.L01246 ;  rem ** if it ran more than once when the arrow was 0, the quiver would flicker at

.L01247 ;  rem ** all 8 locations simultaneously.

.L01248 ;  if quiverplaced = 1 then return

	LDA quiverplaced
	CMP #1
     BNE .skipL01248
.condpart202
  RTS
.skipL01248
.
 ; 

.L01249 ;  rem ** this creates a value from 1-8, and we place the quiver in one of 8 random locations

.L01250 ;  quiverplacement  =  rand & 7

 jsr randomize
	AND #7
	STA quiverplacement
.L01251 ;  quiverx = quiverx_i[quiverplacement]

	LDX quiverplacement
	LDA quiverx_i,x
	STA quiverx
.L01252 ;  quivery = quivery_i[quiverplacement]

	LDX quiverplacement
	LDA quivery_i,x
	STA quivery
.L01253 ;  rem ** set the flag that the quiver has been placed so this is only run once

.L01254 ;  quiverplaced = 1

	LDA #1
	STA quiverplaced
.L01255 ;  return

  RTS
.L01256 ;  rem ** these are the x/y values for quiver placement

.L01257 ;  data quiverx_i

	JMP .skipL01257
quiverx_i
	.byte   6,    54, 150, 150, 134,  38, 100, 70

.skipL01257
.L01258 ;  data quivery_i

	JMP .skipL01258
quivery_i
	.byte   180, 116, 148,  20,  50, 148, 180, 20

.skipL01258
.
 ; 

.skipquiverplacement
 ; skipquiverplacement

.
 ; 

.L01259 ;  rem ** if the treasure placed flag is on (1), run the timer to make it eventually disappear

.L01260 ;  if treasureplaced = 1 then treasuretimer = treasuretimer + 1

	LDA treasureplaced
	CMP #1
     BNE .skipL01260
.condpart203
	LDA treasuretimer
	CLC
	ADC #1
	STA treasuretimer
.skipL01260
.L01261 ;  if treasuretimer > 250 then treasuretimer2 = treasuretimer2 + 1

	LDA #250
	CMP treasuretimer
     BCS .skipL01261
.condpart204
	LDA treasuretimer2
	CLC
	ADC #1
	STA treasuretimer2
.skipL01261
.L01262 ;  rem ** when the timer runs out, change the flag and remove it from the screen

.L01263 ;  if treasuretimer2 > 13 then treasuretimer = 1 : treasuretimer2 = 0 : treasureplaced = 0 : treasure_rplace = 0 : treasure_rplace2 = 0 : treasurex = 200

	LDA #13
	CMP treasuretimer2
     BCS .skipL01263
.condpart205
	LDA #1
	STA treasuretimer
	LDA #0
	STA treasuretimer2
	STA treasureplaced
	STA treasure_rplace
	STA treasure_rplace2
	LDA #200
	STA treasurex
.skipL01263
.
 ; 

.L01264 ;  rem ** place treasure randomly

.L01265 ;  treasure_rplace = treasure_rplace + 1

	LDA treasure_rplace
	CLC
	ADC #1
	STA treasure_rplace
.L01266 ;  if treasure_rplace = 254 then treasure_rplace = 0 : treasure_rplace2 = treasure_rplace2 + 1

	LDA treasure_rplace
	CMP #254
     BNE .skipL01266
.condpart206
	LDA #0
	STA treasure_rplace
	LDA treasure_rplace2
	CLC
	ADC #1
	STA treasure_rplace2
.skipL01266
.
 ; 

.L01267 ;  if treasure_rplace2 > 6 then treasure_rplace2 = 0

	LDA #6
	CMP treasure_rplace2
     BCS .skipL01267
.condpart207
	LDA #0
	STA treasure_rplace2
.skipL01267
.
 ; 

.L01268 ;  if treasure_rplace2 > 5  &&  treasureplaced = 0 then gosub treasurespawn

	LDA #5
	CMP treasure_rplace2
     BCS .skipL01268
.condpart208
	LDA treasureplaced
	CMP #0
     BNE .skip208then
.condpart209
 jsr .treasurespawn

.skip208then
.skipL01268
.L01269 ;  if treasure_rplace2 < 6  &&  treasureplaced = 0 then treasurex = 200 : goto skiptreasureplacement

	LDA treasure_rplace2
	CMP #6
     BCS .skipL01269
.condpart210
	LDA treasureplaced
	CMP #0
     BNE .skip210then
.condpart211
	LDA #200
	STA treasurex
 jmp .skiptreasureplacement

.skip210then
.skipL01269
.L01270 ;  goto skiptreasureplacement

 jmp .skiptreasureplacement

.
 ; 

.placetreasure
 ; placetreasure

.L01271 ;  rem ** jump to random treasure x/y placement subroutine

.L01272 ;  if treasureplaced = 0 then gosub treasurespawn

	LDA treasureplaced
	CMP #0
     BNE .skipL01272
.condpart212
 jsr .treasurespawn

.skipL01272
.
 ; 

.L01273 ;  rem ** skip the treasurespawn sub below

.L01274 ;  goto skiptreasureplacement

 jmp .skiptreasureplacement

.
 ; 

.treasurespawn
 ; treasurespawn

.
 ; 

.L01275 ;  rem ** if the treasureplaced flag is on, it means this sub has already been run once.

.L01276 ;  if treasureplaced = 1 then return

	LDA treasureplaced
	CMP #1
     BNE .skipL01276
.condpart213
  RTS
.skipL01276
.
 ; 

.L01277 ;  rem ** reset treasure timer

.L01278 ;  treasuretimer = 0

	LDA #0
	STA treasuretimer
.
 ; 

.L01279 ;  rem ** use a random number between 0-7 to determine a random location for treasure placement... one of 8.

.L01280 ;  treasurespawn  =  rand & 7

 jsr randomize
	AND #7
	STA treasurespawn
.L01281 ;  treasurex = treasurex_i[treasurespawn]

	LDX treasurespawn
	LDA treasurex_i,x
	STA treasurex
.L01282 ;  treasurey = treasurey_i[treasurespawn]

	LDX treasurespawn
	LDA treasurey_i,x
	STA treasurey
.L01283 ;  rem ** set the flag that the treasure has been placed so this is only run once

.L01284 ;  treasureplaced = 1

	LDA #1
	STA treasureplaced
.L01285 ;  return

  RTS
.
 ; 

.L01286 ;  rem ** this is the x/y placement coordinates for the treasure sprite

.L01287 ;  data treasurex_i

	JMP .skipL01287
treasurex_i
	.byte    6,   22,  84,  38, 120, 134, 54, 120

.skipL01287
.L01288 ;  data treasurey_i

	JMP .skipL01288
treasurey_i
	.byte    116, 22, 116, 180,  20, 148, 20, 180

.skipL01288
.
 ; 

.L01289 ;  rem ** initialize wizard mode

.wizmodeinit
 ; wizmodeinit

.L01290 ;  wizmode = 1

	LDA #1
	STA wizmode
.L01291 ;  wizfirex = 200

	LDA #200
	STA wizfirex
.L01292 ;  playsfx sfx_wor1

    lda #<sfx_wor1
    sta temp1
    lda #>sfx_wor1
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.L01293 ;  playsfx sfx_wor2

    lda #<sfx_wor2
    sta temp1
    lda #>sfx_wor2
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.L01294 ;  if p0_x < 84 then gosub warpwizard_right

	LDA p0_x
	CMP #84
     BCS .skipL01294
.condpart214
 jsr .warpwizard_right

.skipL01294
.L01295 ;  if p0_x > 83 then gosub warpwizard_left

	LDA #83
	CMP p0_x
     BCS .skipL01295
.condpart215
 jsr .warpwizard_left

.skipL01295
.L01296 ;  return

  RTS
.
 ; 

.warpwizard_right
 ; warpwizard_right

.L01297 ;  wizwarpcountdown = 240

	LDA #240
	STA wizwarpcountdown
.L01298 ;  rem ** choose a new location for the wizard on the right side of the screen

.L01299 ;  temp1  =   ( rand & 3 ) 

; complex statement detected
 jsr randomize
	AND #3
	STA temp1
.L01300 ;  wizx = wizx_i[temp1]

	LDX temp1
	LDA wizx_i,x
	STA wizx
.L01301 ;  wizy = wizy_i[temp1]

	LDX temp1
	LDA wizy_i,x
	STA wizy
.L01302 ;  return

  RTS
.
 ; 

.L01303 ;  rem ** x/y spawn locations for the wizard on the right side of the screen

.L01304 ;  data wizx_i

	JMP .skipL01304
wizx_i
	.byte    98, 132, 150, 118

.skipL01304
.L01305 ;  data wizy_i

	JMP .skipL01305
wizy_i
	.byte    16, 144, 116, 176

.skipL01305
.
 ; 

.warpwizard_left
 ; warpwizard_left

.L01306 ;  wizwarpcountdown = 240

	LDA #240
	STA wizwarpcountdown
.L01307 ;  rem ** choose a new location for the wizard on the left side of the screen

.L01308 ;  temp1  =   ( rand & 3 ) 

; complex statement detected
 jsr randomize
	AND #3
	STA temp1
.L01309 ;  wizx = wizx_j[temp1]

	LDX temp1
	LDA wizx_j,x
	STA wizx
.L01310 ;  wizy = wizy_j[temp1]

	LDX temp1
	LDA wizy_j,x
	STA wizy
.L01311 ;  return

  RTS
.
 ; 

.L01312 ;  rem ** x/y spawn locations for the wizard on the left side of the screen

.L01313 ;  data wizx_j

	JMP .skipL01313
wizx_j
	.byte    4,   20,  54,  36

.skipL01313
.L01314 ;  data wizy_j

	JMP .skipL01314
wizy_j
	.byte    112, 16, 112, 176

.skipL01314
.
 ; 

.warpwizard
 ; warpwizard

.L01315 ;  wizwarpcountdown = 255

	LDA #255
	STA wizwarpcountdown
.L01316 ;  temprand  =   ( rand & 7 ) 

; complex statement detected
 jsr randomize
	AND #7
	STA temprand
.L01317 ;  wizx = wizx_k[temprand]

	LDX temprand
	LDA wizx_k,x
	STA wizx
.L01318 ;  wizy = wizy_k[temprand]

	LDX temprand
	LDA wizy_k,x
	STA wizy
.L01319 ;  tempx = wizx - 32

	LDA wizx
	SEC
	SBC #32
	STA tempx
.L01320 ;  tempy = wizy - 32

	LDA wizy
	SEC
	SBC #32
	STA tempy
.L01321 ;  if boxcollision ( p0_x , p0_y ,  5 , 16 ,  tempx , tempy ,  72 , 80 )  then temprand =  ( temprand + 1 )  & 7 : wizx = wizx_k[temprand] :  wizy = wizy_k[temprand]

    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda tempx
    sta temp5
    lda tempy
    sta temp6
    lda #72-1
    sta temp7
    lda #80-1
    sta temp8
   jsr boxcollision
   BCC .skipL01321
.condpart216
; complex statement detected
	LDA temprand
	CLC
	ADC #1
	AND #7
	STA temprand
	LDX temprand
	LDA wizx_k,x
	STA wizx
	LDX temprand
	LDA wizy_k,x
	STA wizy
.skipL01321
.L01322 ;  playsfx sfx_wizwarp

    lda #<sfx_wizwarp
    sta temp1
    lda #>sfx_wizwarp
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.
 ; 

.L01323 ;  return

  RTS
.
 ; 

.L01324 ;  rem ** x/y coordinates for wizard spawn

.L01325 ;  data wizx_k

	JMP .skipL01325
wizx_k
	.byte    4,  132, 54, 118

	.byte    20, 20, 150,  36

.skipL01325
.L01326 ;  data wizy_k

	JMP .skipL01326
wizy_k
	.byte    112, 144, 112, 176

	.byte    96,  16, 116, 176

.skipL01326
.
 ; 

.skiptreasureplacement
 ; skiptreasureplacement

.
 ; 

.L01327 ;  rem ** Invincibility [God Mode]

.
 ; 

.L01328 ;  rem ** to prevent an issue where getting shot at the same time as picking up the sword

.L01329 ;  rem ** would trigger the death animation during god mode

.L01330 ;  if playerdeathflag = 1 then invincibleflag = 0 : invincible_on = 0 : rem if death animation is running, turn god mode off

	LDA playerdeathflag
	CMP #1
     BNE .skipL01330
.condpart217
	LDA #0
	STA invincibleflag
	STA invincible_on
.skipL01330
.L01331 ;  if invincible_on = 1 then playerdeathflag = 0 : rem if you're god, nothing can trigger death or the death animation to start.

	LDA invincible_on
	CMP #1
     BNE .skipL01331
.condpart218
	LDA #0
	STA playerdeathflag
.skipL01331
.
 ; 

.L01332 ;  rem ** enable player color flashing when god mode is enabled

.L01333 ;  colorflasher = colorflasher + invincible_counter2 + 1

; complex statement detected
	LDA colorflasher
	CLC
	ADC invincible_counter2
	CLC
	ADC #1
	STA colorflasher
.L01334 ;  if invincible_on = 1 then P7C2 = colorflasher

	LDA invincible_on
	CMP #1
     BNE .skipL01334
.condpart219
	LDA colorflasher
	STA P7C2
.skipL01334
.
 ; 

.L01335 ;  rem ** if god mode is off, change player color back to the default, skip color flasher

.L01336 ;  if invincible_on = 0 then P7C2 = $26 : goto skipinvinciblestuff

	LDA invincible_on
	CMP #0
     BNE .skipL01336
.condpart220
	LDA #$26
	STA P7C2
 jmp .skipinvinciblestuff

.skipL01336
.
 ; 

.L01337 ;  rem ** player color flashing code

.L01338 ;  P7C2 = colorflasher

	LDA colorflasher
	STA P7C2
.L01339 ;  if  ( colorflasher / 16 )  = lastflash then goto skipinvinciblestuff

; complex condition detected
; complex statement detected
	LDA colorflasher
	lsr
	lsr
	lsr
	lsr
	CMP lastflash
     BNE .skipL01339
.condpart221
 jmp .skipinvinciblestuff

.skipL01339
.L01340 ;  lastflash = colorflasher / 16

	LDA colorflasher
	lsr
	lsr
	lsr
	lsr
	STA lastflash
.L01341 ;  noteindex =  ( noteindex + 1 )  & 3

; complex statement detected
	LDA noteindex
	CLC
	ADC #1
	AND #3
	STA noteindex
.L01342 ;  temp8 = arp_god[noteindex]

	LDX noteindex
	LDA arp_god,x
	STA temp8
.L01343 ;  if wizmode = 0  ||  wizmode = 200 then playsfx sfx_god temp8

	LDA wizmode
	CMP #0
     BNE .skipL01343
.condpart222
 jmp .condpart223
.skipL01343
	LDA wizmode
	CMP #200
     BNE .skip55OR
.condpart223
    lda #<sfx_god
    sta temp1
    lda #>sfx_god
    sta temp2
    lda temp8
    sta temp3
    jsr schedulesfx
.skip55OR
.skipinvinciblestuff
 ; skipinvinciblestuff

.
 ; 

.L01344 ;  rem ** timer for how long invincibility lasts

.L01345 ;  rem **    ...it lasts about 22 seconds.

.L01346 ;  if invincibleflag = 0 then invincible_counter1 = 0 : invincible_counter2 = 0 : goto skipinvincibletimer

	LDA invincibleflag
	CMP #0
     BNE .skipL01346
.condpart224
	LDA #0
	STA invincible_counter1
	STA invincible_counter2
 jmp .skipinvincibletimer

.skipL01346
.L01347 ;  invincible_counter1 = invincible_counter1 + 1

	LDA invincible_counter1
	CLC
	ADC #1
	STA invincible_counter1
.L01348 ;  if invincible_counter1 = 254 then invincible_counter1 = 0 : invincible_counter2 = invincible_counter2 + 1

	LDA invincible_counter1
	CMP #254
     BNE .skipL01348
.condpart225
	LDA #0
	STA invincible_counter1
	LDA invincible_counter2
	CLC
	ADC #1
	STA invincible_counter2
.skipL01348
.L01349 ;  if invincible_counter2 > 5 then invincible_counter2 = 0

	LDA #5
	CMP invincible_counter2
     BCS .skipL01349
.condpart226
	LDA #0
	STA invincible_counter2
.skipL01349
.L01350 ;  if invincible_counter2 > 4 then invincibleflag = 0 : invincible_on = 0

	LDA #4
	CMP invincible_counter2
     BCS .skipL01350
.condpart227
	LDA #0
	STA invincibleflag
	STA invincible_on
.skipL01350
.skipinvincibletimer
 ; skipinvincibletimer

.
 ; 

.L01351 ;  rem ** turn it on/off

.L01352 ;  rem

.L01353 ;  rem ** if god mode is set to on from the main titlescreen (developer mode option), don't ever turn it off

.L01354 ;  if godmodeon = 1 then goto skipcheck

	LDA godmodeon
	CMP #1
     BNE .skipL01354
.condpart228
 jmp .skipcheck

.skipL01354
.L01355 ;  if invincibleflag = 1 then invincible_on = 1 : rem invincible mode on

	LDA invincibleflag
	CMP #1
     BNE .skipL01355
.condpart229
	LDA #1
	STA invincible_on
.skipL01355
.L01356 ;  if invincibleflag = 0 then invincible_on = 0 : rem invincible mode off

	LDA invincibleflag
	CMP #0
     BNE .skipL01356
.condpart230
	LDA #0
	STA invincible_on
.skipL01356
.skipcheck
 ; skipcheck

.
 ; 

.L01357 ;  rem ** Place sword randomly at a set interval

.L01358 ;  rem ** it's currently about every 60 seconds once it's been picked up 

.L01359 ;  rem ** it never disappears from the screen until it's picked up, it doesn't disappear like the treasure does

.
 ; 

.L01360 ;  sword_rplace = sword_rplace + 1

	LDA sword_rplace
	CLC
	ADC #1
	STA sword_rplace
.L01361 ;  if sword_rplace = 254 then sword_rplace = 0 : sword_rplace2 = sword_rplace2 + 1

	LDA sword_rplace
	CMP #254
     BNE .skipL01361
.condpart231
	LDA #0
	STA sword_rplace
	LDA sword_rplace2
	CLC
	ADC #1
	STA sword_rplace2
.skipL01361
.
 ; 

.L01362 ;  if sword_rplace2 > 16 then sword_rplace2 = 0

	LDA #16
	CMP sword_rplace2
     BCS .skipL01362
.condpart232
	LDA #0
	STA sword_rplace2
.skipL01362
.
 ; 

.L01363 ;  if sword_rplace2 > 15  &&  swordplaced = 0 then gosub swordspawn

	LDA #15
	CMP sword_rplace2
     BCS .skipL01363
.condpart233
	LDA swordplaced
	CMP #0
     BNE .skip233then
.condpart234
 jsr .swordspawn

.skip233then
.skipL01363
.L01364 ;  if sword_rplace2 < 16  &&  swordplaced = 0 then swordx = 200 : goto skipswordplacement

	LDA sword_rplace2
	CMP #16
     BCS .skipL01364
.condpart235
	LDA swordplaced
	CMP #0
     BNE .skip235then
.condpart236
	LDA #200
	STA swordx
 jmp .skipswordplacement

.skip235then
.skipL01364
.L01365 ;  goto skipswordplacement

 jmp .skipswordplacement

.
 ; 

.placesword
 ; placesword

.L01366 ;  rem ** jump to random sword x/y placement subroutine

.L01367 ;  if swordplaced = 0 then gosub swordspawn

	LDA swordplaced
	CMP #0
     BNE .skipL01367
.condpart237
 jsr .swordspawn

.skipL01367
.
 ; 

.L01368 ;  rem ** skip the swordspawn sub below

.L01369 ;  goto skipswordplacement

 jmp .skipswordplacement

.
 ; 

.swordspawn
 ; swordspawn

.
 ; 

.L01370 ;  rem ** if the swordplaced flag is on, it means this sub has already been run once.

.L01371 ;  rem **    ...so yeah, don't run it again if the flag is on

.L01372 ;  if swordplaced = 1 then return

	LDA swordplaced
	CMP #1
     BNE .skipL01372
.condpart238
  RTS
.skipL01372
.
 ; 

.L01373 ;  rem ** randomize sword x/y location based on data below

.L01374 ;  swordspawn  =  rand & 7

 jsr randomize
	AND #7
	STA swordspawn
.L01375 ;  swordx = swordx_i[swordspawn]

	LDX swordspawn
	LDA swordx_i,x
	STA swordx
.L01376 ;  swordy = swordy_i[swordspawn]

	LDX swordspawn
	LDA swordy_i,x
	STA swordy
.
 ; 

.L01377 ;  rem ** set the flag that the sword has been placed so this is only run once

.L01378 ;  swordplaced = 1

	LDA #1
	STA swordplaced
.L01379 ;  return

  RTS
.
 ; 

.L01380 ;  rem ** x/y data placement for sword

.L01381 ;  data swordx_i

	JMP .skipL01381
swordx_i
	.byte   150, 70, 38, 84, 134, 150, 38, 100

.skipL01381
.L01382 ;  data swordy_i

	JMP .skipL01382
swordy_i
	.byte   54, 146, 116, 176, 116, 176, 54, 18

.skipL01382
.
 ; 

.skipswordplacement
 ; skipswordplacement

.
 ; 

.L01383 ;  rem ** background/maze colors depend on pause button selection on powerup

.L01384 ;  rem **   ...yeah, again, hold down pause to reverse colors on powerup

.L01385 ;  if wizmode = 0  &&  colorchange = 0 then SBACKGRND = 0 : P0C2 = levelcolors[levelvalue]

	LDA wizmode
	CMP #0
     BNE .skipL01385
.condpart239
	LDA colorchange
	CMP #0
     BNE .skip239then
.condpart240
	LDA #0
	STA SBACKGRND
	LDX levelvalue
	LDA levelcolors,x
	STA P0C2
.skip239then
.skipL01385
.L01386 ;  if wizmode = 0  &&  colorchange = 1 then SBACKGRND = levelcolors[levelvalue] : P0C2 = 0

	LDA wizmode
	CMP #0
     BNE .skipL01386
.condpart241
	LDA colorchange
	CMP #1
     BNE .skip241then
.condpart242
	LDX levelvalue
	LDA levelcolors,x
	STA SBACKGRND
	LDA #0
	STA P0C2
.skip241then
.skipL01386
.
 ; 

.L01387 ;  rem ** button debounce

.L01388 ;  rem **   ...it doesn't register until the button is released, not when it's pressed

.L01389 ;  if fireheld = 1  &&  !joy0fire then fireheld = 0

	LDA fireheld
	CMP #1
     BNE .skipL01389
.condpart243
 bit sINPT1
	BMI .skip243then
.condpart244
	LDA #0
	STA fireheld
.skip243then
.skipL01389
.
 ; 

.L01390 ;  rem ** if you hit the button in demo mode, return to the title screen

.L01391 ;  if demomode = 1  &&  fireheld = 0  &&  joy0fire then fireheld = 1 : goto titlescreen

	LDA demomode
	CMP #1
     BNE .skipL01391
.condpart245
	LDA fireheld
	CMP #0
     BNE .skip245then
.condpart246
 bit sINPT1
	BPL .skip246then
.condpart247
	LDA #1
	STA fireheld
 jmp .titlescreen

.skip246then
.skip245then
.skipL01391
.
 ; 

.L01392 ;  rem <--- Start Arrow firing code for the player --->

.L01393 ;  rem         ...notice the arrows on both sides of the text above

.
 ; 

.L01394 ;  rem ** conditions upon which we fire a new arrow

.L01395 ;  if fire_debounce > 0 then fire_debounce = fire_debounce - 1 : goto skipstartfire

	LDA #0
	CMP fire_debounce
     BCS .skipL01395
.condpart248
	LDA fire_debounce
	SEC
	SBC #1
	STA fire_debounce
 jmp .skipstartfire

.skipL01395
.L01396 ;  if !joy0fire then goto skipstartfire

 bit sINPT1
	BMI .skipL01396
.condpart249
 jmp .skipstartfire

.skipL01396
.L01397 ;  rem ** frozen? No fire for you!

.L01398 ;  if freezeflag = 1 then goto skipstartfire

	LDA freezeflag
	CMP #1
     BNE .skipL01398
.condpart250
 jmp .skipstartfire

.skipL01398
.L01399 ;  rem ** button held down? No fire for you!

.L01400 ;  if fireheld = 1 then goto skipstartfire

	LDA fireheld
	CMP #1
     BNE .skipL01400
.condpart251
 jmp .skipstartfire

.skipL01400
.L01401 ;  rem ** arrow not offscreen? No fire for you!

.L01402 ;  if xpos_fire <> 200 then goto skipstartfire

	LDA xpos_fire
	CMP #200
     BEQ .skipL01402
.condpart252
 jmp .skipstartfire

.skipL01402
.L01403 ;  rem ** no arrows? No fire for you!

.L01404 ;  if arrowcounter = 0 then goto skipstartfire

	LDA arrowcounter
	CMP #0
     BNE .skipL01404
.condpart253
 jmp .skipstartfire

.skipL01404
.L01405 ;  rem ** Dead? No fire for you! 

.L01406 ;  if playerdeathflag = 1 then goto skipstartfire

	LDA playerdeathflag
	CMP #1
     BNE .skipL01406
.condpart254
 jmp .skipstartfire

.skipL01406
.
 ; 

.L01407 ;  rem ** if we're here, the following is true

.L01408 ;  rem    1. the fire button is pressed

.L01409 ;  rem    2. the arrow is in limbo, ready to fire

.L01410 ;  rem    3. we have arrows in inventory

.L01411 ;  rem    4. you rock because you're reading the code comments

.
 ; 

.L01412 ;  rem ** set the position and direction for arrow

.L01413 ;  xpos_fire = p0_x : ypos_fire = p0_y + 2 : fire_dir_save = fire_dir

	LDA p0_x
	STA xpos_fire
	LDA p0_y
	CLC
	ADC #2
	STA ypos_fire
	LDA fire_dir
	STA fire_dir_save
.
 ; 

.L01414 ;  rem ** wizard mode countdown for warping check

.L01415 ;  rem **   ...heh. warping is cool.

.L01416 ;  temp1 = rand & 1

 jsr randomize
	AND #1
	STA temp1
.L01417 ;  if wizmode = 200  &&  temp1 = 1  &&  wizwarpcountdown < 200 then wizwarpcountdown = 1

	LDA wizmode
	CMP #200
     BNE .skipL01417
.condpart255
	LDA temp1
	CMP #1
     BNE .skip255then
.condpart256
	LDA wizwarpcountdown
	CMP #200
     BCS .skip256then
.condpart257
	LDA #1
	STA wizwarpcountdown
.skip256then
.skip255then
.skipL01417
.
 ; 

.L01418 ;  rem ** play the quiver firing sound

.L01419 ;  if wizmode = 0  ||  wizmode = 200 then playsfx sfx_player_shoot

	LDA wizmode
	CMP #0
     BNE .skipL01419
.condpart258
 jmp .condpart259
.skipL01419
	LDA wizmode
	CMP #200
     BNE .skip65OR
.condpart259
    lda #<sfx_player_shoot
    sta temp1
    lda #>sfx_player_shoot
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip65OR
.
 ; 

.L01420 ;  rem ** and reduce the arrows in inventory

.L01421 ;  rem **    ...arrows? we don't need no stinking arrows!

.L01422 ;  if arrowsvalue = 9 then goto skipstartfire

	LDA arrowsvalue
	CMP #9
     BNE .skipL01422
.condpart260
 jmp .skipstartfire

.skipL01422
.L01423 ;  arrowcounter = arrowcounter - 1

	LDA arrowcounter
	SEC
	SBC #1
	STA arrowcounter
.
 ; 

.skipstartfire
 ; skipstartfire

.
 ; 

.L01424 ;  rem ** if you choose the 'fast' speed menu option, arrows fire faster

.L01425 ;  rem ** fast speed is only a developer mode option.

.L01426 ;  if speedvalue = 2 then goto fastplay2

	LDA speedvalue
	CMP #2
     BNE .skipL01426
.condpart261
 jmp .fastplay2

.skipL01426
.
 ; 

.L01427 ;  rem ** this slows down the firing rate

.L01428 ;  if slowdown3 < 1 then goto skip_updatefire

	LDA slowdown3
	CMP #1
     BCS .skipL01428
.condpart262
 jmp .skip_updatefire

.skipL01428
.
 ; 

.fastplay2
 ; fastplay2

.
 ; 

.L01429 ;  rem ** if the arrow is offscreen, don't move it

.L01430 ;  if xpos_fire = 200 then goto skip_updatefire

	LDA xpos_fire
	CMP #200
     BNE .skipL01430
.condpart263
 jmp .skip_updatefire

.skipL01430
.
 ; 

.L01431 ;  rem ** if fire is in flight, move it

.L01432 ;  if fire_dir_save = 1 then ypos_fire = ypos_fire - 2

	LDA fire_dir_save
	CMP #1
     BNE .skipL01432
.condpart264
	LDA ypos_fire
	SEC
	SBC #2
	STA ypos_fire
.skipL01432
.L01433 ;  if fire_dir_save = 2 then ypos_fire = ypos_fire + 2

	LDA fire_dir_save
	CMP #2
     BNE .skipL01433
.condpart265
	LDA ypos_fire
	CLC
	ADC #2
	STA ypos_fire
.skipL01433
.L01434 ;  if fire_dir_save = 3 then xpos_fire = xpos_fire - 2

	LDA fire_dir_save
	CMP #3
     BNE .skipL01434
.condpart266
	LDA xpos_fire
	SEC
	SBC #2
	STA xpos_fire
.skipL01434
.L01435 ;  if fire_dir_save = 4 then xpos_fire = xpos_fire + 2

	LDA fire_dir_save
	CMP #4
     BNE .skipL01435
.condpart267
	LDA xpos_fire
	CLC
	ADC #2
	STA xpos_fire
.skipL01435
.
 ; 

.L01436 ;  rem ** stop the fire hits the screen edges

.L01437 ;  if xpos_fire > 158  ||  xpos_fire < 2 then xpos_fire = 200

	LDA #158
	CMP xpos_fire
     BCS .skipL01437
.condpart268
 jmp .condpart269
.skipL01437
	LDA xpos_fire
	CMP #2
     BCS .skip66OR
.condpart269
	LDA #200
	STA xpos_fire
.skip66OR
.L01438 ;  if ypos_fire > 192  ||  ypos_fire < 2 then xpos_fire = 200

	LDA #192
	CMP ypos_fire
     BCS .skipL01438
.condpart270
 jmp .condpart271
.skipL01438
	LDA ypos_fire
	CMP #2
     BCS .skip67OR
.condpart271
	LDA #200
	STA xpos_fire
.skip67OR
.
 ; 

.L01439 ;  rem ** stop the arrow firing if it's not over a blank space

.L01440 ;  temp0_x =  ( xpos_fire + 1 )  / 4

; complex statement detected
	LDA xpos_fire
	CLC
	ADC #1
	lsr
	lsr
	STA temp0_x
.L01441 ;  temp0_y = ypos_fire / 8

	LDA ypos_fire
	lsr
	lsr
	lsr
	STA temp0_y
.L01442 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.
 ; 

.L01443 ;  rem <--- End Arrow firing code for player --->

.
 ; 

.L01444 ;  rem ** check if we hit a spiderweb

.L01445 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then xpos_fire = 200 : fireheld = 1 : pokechar screenram temp0_x temp0_y 40 28 $41 : goto skip_updatefire

	LDA tempchar1
	CMP #spw1
     BCC .skipL01445
.condpart272
	LDA #spw4
	CMP tempchar1
     BCC .skip272then
.condpart273
	LDA #200
	STA xpos_fire
	LDA #1
	STA fireheld
    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda #$41
    sta (temp1),y
 jmp .skip_updatefire

.skip272then
.skipL01445
.L01446 ;  if tempchar1 <> $41 then xpos_fire = 200 : fireheld = 1

	LDA tempchar1
	CMP #$41
     BEQ .skipL01446
.condpart274
	LDA #200
	STA xpos_fire
	LDA #1
	STA fireheld
.skipL01446
.skip_updatefire
 ; skip_updatefire

.
 ; 

.L01447 ;  rem ** don't allow robots to fire if they are set to be offscreen

.L01448 ;  rem ** the wizard uses monster1type, so don't reset arrow fire to offscreen when in wizard mode

.L01449 ;  if monster1type = 255  &&  wizmode = 0 then r1x_fire = 200 : r1y_fire = 200

	LDA monster1type
	CMP #255
     BNE .skipL01449
.condpart275
	LDA wizmode
	CMP #0
     BNE .skip275then
.condpart276
	LDA #200
	STA r1x_fire
	STA r1y_fire
.skip275then
.skipL01449
.L01450 ;  if monster2type = 255 then r2x_fire = 200 : r2y_fire = 200

	LDA monster2type
	CMP #255
     BNE .skipL01450
.condpart277
	LDA #200
	STA r2x_fire
	STA r2y_fire
.skipL01450
.L01451 ;  if monster3type = 255 then r3x_fire = 200 : r3y_fire = 200

	LDA monster3type
	CMP #255
     BNE .skipL01451
.condpart278
	LDA #200
	STA r3x_fire
	STA r3y_fire
.skipL01451
.
 ; 

.L01452 ;  rem ** Slow down the animation for sprites

.L01453 ;  slowdown1 =  ( slowdown1 + 1 )  & 31

; complex statement detected
	LDA slowdown1
	CLC
	ADC #1
	AND #31
	STA slowdown1
.L01454 ;  if  ( framecounter & 3 )  = 0 then slowdown_spider = slowdown_spider + 1 : if slowdown_spider > 4 then slowdown_spider = 0

; complex condition detected
; complex statement detected
	LDA framecounter
	AND #3
	CMP #0
     BNE .skipL01454
.condpart279
	LDA slowdown_spider
	CLC
	ADC #1
	STA slowdown_spider
	LDA #4
	CMP slowdown_spider
     BCS .skip279then
.condpart280
	LDA #0
	STA slowdown_spider
.skip279then
.skipL01454
.L01455 ;  slowdown_bat1 = slowdown_bat1 + 1 : if slowdown_bat1 > 20 then slowdown_bat1 = 0

	LDA slowdown_bat1
	CLC
	ADC #1
	STA slowdown_bat1
	LDA #20
	CMP slowdown_bat1
     BCS .skipL01455
.condpart281
	LDA #0
	STA slowdown_bat1
.skipL01455
.L01456 ;  slowdown_bat2 = slowdown_bat2 + 1 : if slowdown_bat2 > 20 then slowdown_bat2 = 0

	LDA slowdown_bat2
	CLC
	ADC #1
	STA slowdown_bat2
	LDA #20
	CMP slowdown_bat2
     BCS .skipL01456
.condpart282
	LDA #0
	STA slowdown_bat2
.skipL01456
.
 ; 

.L01457 ;  rem ** I don't remember.  It's a loop.  Something explodes.

.L01458 ;  for temploop = 0 to 2

	LDA #0
	STA temploop
.L01458fortemploop
.L01459 ;  if  ( frame & 7 )  = 0 then explodeframe1[temploop] = explodeframe1[temploop] + 1

; complex condition detected
; complex statement detected
	LDA frame
	AND #7
	CMP #0
     BNE .skipL01459
.condpart283
	LDX temploop
	LDA explodeframe1,x
	CLC
	ADC #1
	LDX temploop
	STA explodeframe1,x
.skipL01459
.L01460 ;  if explodeframe1[temploop] > 7 then explodeframe1[temploop] = 0

	LDA #7
	LDX temploop
	CMP explodeframe1,x
     BCS .skipL01460
.condpart284
	LDA #0
	LDX temploop
	STA explodeframe1,x
.skipL01460
.L01461 ;  next

	LDA temploop
	CMP #2

	INC temploop
 if ((* - .L01458fortemploop) < 127) && ((* - .L01458fortemploop) > -128)
	bcc .L01458fortemploop
 else
	bcs .7skipL01458fortemploop
	jmp .L01458fortemploop
.7skipL01458fortemploop
 endif
.
 ; 

.L01462 ;  rem ** animation frames for player death

.L01463 ;  if  ( frame & 7 )  = 0 then deathframe =  ( deathframe + 1 )  & 15

; complex condition detected
; complex statement detected
	LDA frame
	AND #7
	CMP #0
     BNE .skipL01463
.condpart285
; complex statement detected
	LDA deathframe
	CLC
	ADC #1
	AND #15
	STA deathframe
.skipL01463
.
 ; 

.L01464 ;  rem ** slow down the anmiation for monster 1 / Demon Bat

.L01465 ;  if slowdown1 = 15 then monster1animationframe = 0 : monster2animationframe = 0 : monster3animationframe = 0 : quiveranimationframe = 0 : freeze = 0

	LDA slowdown1
	CMP #15
     BNE .skipL01465
.condpart286
	LDA #0
	STA monster1animationframe
	STA monster2animationframe
	STA monster3animationframe
	STA quiveranimationframe
	STA freeze
.skipL01465
.L01466 ;  if slowdown1 = 30 then monster1animationframe = 1 : monster2animationframe = 1 : monster3animationframe = 1 : quiveranimationframe = 1 : freeze = 1

	LDA slowdown1
	CMP #30
     BNE .skipL01466
.condpart287
	LDA #1
	STA monster1animationframe
	STA monster2animationframe
	STA monster3animationframe
	STA quiveranimationframe
	STA freeze
.skipL01466
.
 ; 

.L01467 ;  spideranimationframe = slowdown1 / 8

	LDA slowdown1
	lsr
	lsr
	lsr
	STA spideranimationframe
.
 ; 

.L01468 ;  rem ** slow down animation for bats

.L01469 ;  if slowdown1 = 10 then batanimationframe = 0

	LDA slowdown1
	CMP #10
     BNE .skipL01469
.condpart288
	LDA #0
	STA batanimationframe
.skipL01469
.L01470 ;  if slowdown1 = 20 then batanimationframe = 1

	LDA slowdown1
	CMP #20
     BNE .skipL01470
.condpart289
	LDA #1
	STA batanimationframe
.skipL01470
.L01471 ;  if slowdown1 = 30 then batanimationframe = 2

	LDA slowdown1
	CMP #30
     BNE .skipL01471
.condpart290
	LDA #2
	STA batanimationframe
.skipL01471
.
 ; 

.L01472 ;  spiderdeathframe = slowdown_spider

	LDA slowdown_spider
	STA spiderdeathframe
.
 ; 

.L01473 ;  if slowdown_bat1 = 8 then bat1deathframe = 0

	LDA slowdown_bat1
	CMP #8
     BNE .skipL01473
.condpart291
	LDA #0
	STA bat1deathframe
.skipL01473
.L01474 ;  if slowdown_bat1 = 12 then bat1deathframe = 1

	LDA slowdown_bat1
	CMP #12
     BNE .skipL01474
.condpart292
	LDA #1
	STA bat1deathframe
.skipL01474
.L01475 ;  if slowdown_bat1 = 16 then bat1deathframe = 2

	LDA slowdown_bat1
	CMP #16
     BNE .skipL01475
.condpart293
	LDA #2
	STA bat1deathframe
.skipL01475
.L01476 ;  if slowdown_bat1 = 20 then bat1deathframe = 3

	LDA slowdown_bat1
	CMP #20
     BNE .skipL01476
.condpart294
	LDA #3
	STA bat1deathframe
.skipL01476
.
 ; 

.L01477 ;  if slowdown_bat2 = 8 then bat2deathframe = 0

	LDA slowdown_bat2
	CMP #8
     BNE .skipL01477
.condpart295
	LDA #0
	STA bat2deathframe
.skipL01477
.L01478 ;  if slowdown_bat2 = 12 then bat2deathframe = 1

	LDA slowdown_bat2
	CMP #12
     BNE .skipL01478
.condpart296
	LDA #1
	STA bat2deathframe
.skipL01478
.L01479 ;  if slowdown_bat2 = 16 then bat2deathframe = 2

	LDA slowdown_bat2
	CMP #16
     BNE .skipL01479
.condpart297
	LDA #2
	STA bat2deathframe
.skipL01479
.L01480 ;  if slowdown_bat2 = 20 then bat2deathframe = 3

	LDA slowdown_bat2
	CMP #20
     BNE .skipL01480
.condpart298
	LDA #3
	STA bat2deathframe
.skipL01480
.skipmove
 ; skipmove

.
 ; 

.L01481 ;  rem ** if the game over flag is set, calculate high score for titlescreen, goto "game over" pause screen

.L01482 ;  if gameoverflag = 1  &&  joy0fire  &&  countdownseconds = 0 then gosub HighScoreCalc : gameoverflag = 0 : SBACKGRND = 0 : goto gameoverrestart

	LDA gameoverflag
	CMP #1
     BNE .skipL01482
.condpart299
 bit sINPT1
	BPL .skip299then
.condpart300
	LDA countdownseconds
	CMP #0
     BNE .skip300then
.condpart301
 jsr .HighScoreCalc
	LDA #0
	STA gameoverflag
	STA SBACKGRND
 jmp .gameoverrestart

.skip300then
.skip299then
.skipL01482
.
 ; 

.L01483 ;  rem **********************************************************************************

.L01484 ;  rem ************ Section 2: Display Logic... avoid non-display logic here ************

.L01485 ;  rem **********************************************************************************

.
 ; 

.L01486 ;  rem **  The restorescreen erases any sprites and

.L01487 ;  rem **  characters that you've drawn on the screen since

.L01488 ;  rem **  the last savescreen.

.L01489 ;  restorescreen

 jsr restorescreen
.
 ; 

.L01490 ;  rem ** put dev mode text on screen if you're in dev mode

.L01491 ;  if gamemode = 1 then plotsprite devmode 2 62 194

	LDA gamemode
	CMP #1
     BNE .skipL01491
.condpart302
    lda #<devmode
    sta temp1

    lda #>devmode
    sta temp2

    lda #(64|devmode_width_twoscompliment)
    sta temp3

    lda #62
    sta temp4

    lda #194

    sta temp5

    lda #(devmode_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01491
.
 ; 

.L01492 ;  rem ** update the variable our baked in score uses

.L01493 ;  score0bcd0 =  ( sc1 / 16 )  + digitstart

; complex statement detected
	LDA sc1
	lsr
	lsr
	lsr
	lsr
	CLC
	ADC #digitstart
	STA score0bcd0
.L01494 ;  score0bcd1 =  ( sc1 & $0F )  + digitstart

; complex statement detected
	LDA sc1
	AND #$0F
	CLC
	ADC #digitstart
	STA score0bcd1
.L01495 ;  score0bcd2 =  ( sc2 / 16 )  + digitstart

; complex statement detected
	LDA sc2
	lsr
	lsr
	lsr
	lsr
	CLC
	ADC #digitstart
	STA score0bcd2
.L01496 ;  score0bcd3 =  ( sc2 & $0F )  + digitstart

; complex statement detected
	LDA sc2
	AND #$0F
	CLC
	ADC #digitstart
	STA score0bcd3
.L01497 ;  score0bcd4 =  ( sc3 / 16 )  + digitstart

; complex statement detected
	LDA sc3
	lsr
	lsr
	lsr
	lsr
	CLC
	ADC #digitstart
	STA score0bcd4
.L01498 ;  score0bcd5 =  ( sc3 & $0F )  + digitstart

; complex statement detected
	LDA sc3
	AND #$0F
	CLC
	ADC #digitstart
	STA score0bcd5
.
 ; 

.L01499 ;  rem ** sometimes, when you add comments later, you forget what stuff does.

.L01500 ;  const godchar =  < godmode

.L01501 ;  if godvalue = 2  ||  invincible_on = 1 then livesbcdhi = godchar : livesbcdlo = godchar + 1 : goto skiplifecounter

	LDA godvalue
	CMP #2
     BNE .skipL01501
.condpart303
 jmp .condpart304
.skipL01501
	LDA invincible_on
	CMP #1
     BNE .skip72OR
.condpart304
	LDA #godchar
	STA livesbcdhi
	CLC
	ADC #1
	STA livesbcdlo
 jmp .skiplifecounter

.skip72OR
.L01502 ;  livesbcdhi = digitstart

	LDA #digitstart
	STA livesbcdhi
.L01503 ;  livesbcdlo = lifecounter + digitstart

	LDA lifecounter
	CLC
	ADC #digitstart
	STA livesbcdlo
.skiplifecounter
 ; skiplifecounter

.
 ; 

.L01504 ;  rem ** plot the "game over" sprite in the middle of the screen if the game has ended

.L01505 ;  if gameoverflag = 1  &&  demomode = 0 then plotsprite gameovertext 7 72 51

	LDA gameoverflag
	CMP #1
     BNE .skipL01505
.condpart305
	LDA demomode
	CMP #0
     BNE .skip305then
.condpart306
    lda #<gameovertext
    sta temp1

    lda #>gameovertext
    sta temp2

    lda #(224|gameovertext_width_twoscompliment)
    sta temp3

    lda #72
    sta temp4

    lda #51

    sta temp5

    lda #(gameovertext_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip305then
.skipL01505
.L01506 ;  if gameoverflag = 0  &&  demomode = 1 then plotsprite demomodetext 7 71 51

	LDA gameoverflag
	CMP #0
     BNE .skipL01506
.condpart307
	LDA demomode
	CMP #1
     BNE .skip307then
.condpart308
    lda #<demomodetext
    sta temp1

    lda #>demomodetext
    sta temp2

    lda #(224|demomodetext_width_twoscompliment)
    sta temp3

    lda #71
    sta temp4

    lda #51

    sta temp5

    lda #(demomodetext_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip307then
.skipL01506
.
 ; 

.L01507 ;  rem ** go to the frozen sub if you're been frozen by a spider or bat

.L01508 ;  if freezeflag = 1 then goto frozen

	LDA freezeflag
	CMP #1
     BNE .skipL01508
.condpart309
 jmp .frozen

.skipL01508
.
 ; 

.L01509 ;  rem ** go to the player death sub if you've died

.L01510 ;  if playerdeathflag = 1 then goto playerdeath

	LDA playerdeathflag
	CMP #1
     BNE .skipL01510
.condpart310
 jmp .playerdeath

.skipL01510
.
 ; 

.L01511 ;  rem ** Animation Frames for Archer

.L01512 ;  temp1 = runningdir + runningframe

	LDA runningdir
	CLC
	ADC runningframe
	STA temp1
.L01513 ;  plotsprite archer_1_top_faceright 7 p0_x p0_y temp1

    lda #<archer_1_top_faceright
    ldy temp1
      clc
      beq plotspritewidthskip7
plotspritewidthloop7
      adc #archer_1_top_faceright_width
      dey
      bne plotspritewidthloop7
plotspritewidthskip7
    sta temp1

    lda #>archer_1_top_faceright
    sta temp2

    lda #(224|archer_1_top_faceright_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_1_top_faceright_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01514 ;  p0_y = p0_y + 8

	LDA p0_y
	CLC
	ADC #8
	STA p0_y
.L01515 ;  temp1 = runningdir + runningframe

	LDA runningdir
	CLC
	ADC runningframe
	STA temp1
.L01516 ;  plotsprite archer_1_bottom_faceright 7 p0_x p0_y temp1

    lda #<archer_1_bottom_faceright
    ldy temp1
      clc
      beq plotspritewidthskip8
plotspritewidthloop8
      adc #archer_1_bottom_faceright_width
      dey
      bne plotspritewidthloop8
plotspritewidthskip8
    sta temp1

    lda #>archer_1_bottom_faceright
    sta temp2

    lda #(224|archer_1_bottom_faceright_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_1_bottom_faceright_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01517 ;  p0_y = p0_y - 8

	LDA p0_y
	SEC
	SBC #8
	STA p0_y
.
 ; 

.L01518 ;  rem ** skip the frozen and player death subs below, they are called above if they're needed

.L01519 ;  goto skipall

 jmp .skipall

.
 ; 

.frozen
 ; frozen

.
 ; 

.L01520 ;  rem ** Animation frames for frozen archer

.L01521 ;  if invincibleflag = 0 then plotsprite archer_still_top 7 p0_x p0_y freeze

	LDA invincibleflag
	CMP #0
     BNE .skipL01521
.condpart311
    lda #<archer_still_top
    ldy freeze
      clc
      beq plotspritewidthskip9
plotspritewidthloop9
      adc #archer_still_top_width
      dey
      bne plotspritewidthloop9
plotspritewidthskip9
    sta temp1

    lda #>archer_still_top
    sta temp2

    lda #(224|archer_still_top_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_still_top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01521
.L01522 ;  if invincibleflag = 1 then plotsprite archer_still_top 4 p0_x p0_y freeze

	LDA invincibleflag
	CMP #1
     BNE .skipL01522
.condpart312
    lda #<archer_still_top
    ldy freeze
      clc
      beq plotspritewidthskip10
plotspritewidthloop10
      adc #archer_still_top_width
      dey
      bne plotspritewidthloop10
plotspritewidthskip10
    sta temp1

    lda #>archer_still_top
    sta temp2

    lda #(128|archer_still_top_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_still_top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01522
.L01523 ;  p0_y = p0_y + 8

	LDA p0_y
	CLC
	ADC #8
	STA p0_y
.L01524 ;  if invincibleflag = 0 then plotsprite archer_still_bottom 7 p0_x p0_y freeze

	LDA invincibleflag
	CMP #0
     BNE .skipL01524
.condpart313
    lda #<archer_still_bottom
    ldy freeze
      clc
      beq plotspritewidthskip11
plotspritewidthloop11
      adc #archer_still_bottom_width
      dey
      bne plotspritewidthloop11
plotspritewidthskip11
    sta temp1

    lda #>archer_still_bottom
    sta temp2

    lda #(224|archer_still_bottom_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_still_bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01524
.L01525 ;  if invincibleflag = 1 then plotsprite archer_still_bottom 4 p0_x p0_y freeze

	LDA invincibleflag
	CMP #1
     BNE .skipL01525
.condpart314
    lda #<archer_still_bottom
    ldy freeze
      clc
      beq plotspritewidthskip12
plotspritewidthloop12
      adc #archer_still_bottom_width
      dey
      bne plotspritewidthloop12
plotspritewidthskip12
    sta temp1

    lda #>archer_still_bottom
    sta temp2

    lda #(128|archer_still_bottom_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_still_bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01525
.L01526 ;  p0_y = p0_y - 8

	LDA p0_y
	SEC
	SBC #8
	STA p0_y
.L01527 ;  goto skipall

 jmp .skipall

.
 ; 

.playerdeath
 ; playerdeath

.
 ; 

.L01528 ;  rem ** Animation frames for archer death

.L01529 ;  if invincibleflag = 0 then plotsprite archer_death_top1 7 p0_x p0_y deathframe

	LDA invincibleflag
	CMP #0
     BNE .skipL01529
.condpart315
    lda #<archer_death_top1
    ldy deathframe
      clc
      beq plotspritewidthskip13
plotspritewidthloop13
      adc #archer_death_top1_width
      dey
      bne plotspritewidthloop13
plotspritewidthskip13
    sta temp1

    lda #>archer_death_top1
    sta temp2

    lda #(224|archer_death_top1_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_death_top1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01529
.L01530 ;  if invincibleflag = 1 then plotsprite archer_death_top1 4 p0_x p0_y deathframe

	LDA invincibleflag
	CMP #1
     BNE .skipL01530
.condpart316
    lda #<archer_death_top1
    ldy deathframe
      clc
      beq plotspritewidthskip14
plotspritewidthloop14
      adc #archer_death_top1_width
      dey
      bne plotspritewidthloop14
plotspritewidthskip14
    sta temp1

    lda #>archer_death_top1
    sta temp2

    lda #(128|archer_death_top1_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_death_top1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01530
.L01531 ;  p0_y = p0_y + 8

	LDA p0_y
	CLC
	ADC #8
	STA p0_y
.L01532 ;  if invincibleflag = 0 then plotsprite archer_death_bottom1 7 p0_x p0_y deathframe

	LDA invincibleflag
	CMP #0
     BNE .skipL01532
.condpart317
    lda #<archer_death_bottom1
    ldy deathframe
      clc
      beq plotspritewidthskip15
plotspritewidthloop15
      adc #archer_death_bottom1_width
      dey
      bne plotspritewidthloop15
plotspritewidthskip15
    sta temp1

    lda #>archer_death_bottom1
    sta temp2

    lda #(224|archer_death_bottom1_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_death_bottom1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01532
.L01533 ;  if invincibleflag = 1 then plotsprite archer_death_bottom1 4 p0_x p0_y deathframe

	LDA invincibleflag
	CMP #1
     BNE .skipL01533
.condpart318
    lda #<archer_death_bottom1
    ldy deathframe
      clc
      beq plotspritewidthskip16
plotspritewidthloop16
      adc #archer_death_bottom1_width
      dey
      bne plotspritewidthloop16
plotspritewidthskip16
    sta temp1

    lda #>archer_death_bottom1
    sta temp2

    lda #(128|archer_death_bottom1_width_twoscompliment)
    sta temp3

    lda p0_x
    sta temp4

    lda p0_y
    sta temp5

    lda #(archer_death_bottom1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01533
.L01534 ;  p0_y = p0_y - 8

	LDA p0_y
	SEC
	SBC #8
	STA p0_y
.
 ; 

.skipall
 ; skipall

.
 ; 

.L01535 ;  rem ** reset wizard animation

.L01536 ;  if wizanimationframe > 3 then wizanimationframe = 0

	LDA #3
	CMP wizanimationframe
     BCS .skipL01536
.condpart319
	LDA #0
	STA wizanimationframe
.skipL01536
.
 ; 

.L01537 ;  rem ** this removes both bats on level 5, and allows one bat on level 4

.L01538 ;  if levelvalue = 5 then goto bat2deathskip

	LDA levelvalue
	CMP #5
     BNE .skipL01538
.condpart320
 jmp .bat2deathskip

.skipL01538
.L01539 ;  if levelvalue = 4 then goto bat1deathskip

	LDA levelvalue
	CMP #4
     BNE .skipL01539
.condpart321
 jmp .bat1deathskip

.skipL01539
.
 ; 

.L01540 ;  rem ** jump to bat1death sub if the bat has been shot or touched

.L01541 ;  if bat1deathflag = 1 then goto bat1death

	LDA bat1deathflag
	CMP #1
     BNE .skipL01541
.condpart322
 jmp .bat1death

.skipL01541
.
 ; 

.L01542 ;  rem ** skip bat death sub if wiz mode is active

.L01543 ;  if wizmode > 0 then goto bat1deathskip

	LDA #0
	CMP wizmode
     BCS .skipL01543
.condpart323
 jmp .bat1deathskip

.skipL01543
.
 ; 

.L01544 ;  rem ** Animation Frames for Bat 1

.L01545 ;  plotsprite bat1 2 bat1x bat1y batanimationframe

    lda #<bat1
    ldy batanimationframe
      clc
      beq plotspritewidthskip17
plotspritewidthloop17
      adc #bat1_width
      dey
      bne plotspritewidthloop17
plotspritewidthskip17
    sta temp1

    lda #>bat1
    sta temp2

    lda #(64|bat1_width_twoscompliment)
    sta temp3

    lda bat1x
    sta temp4

    lda bat1y
    sta temp5

    lda #(bat1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01546 ;  goto bat1deathskip

 jmp .bat1deathskip

.
 ; 

.bat1death
 ; bat1death

.L01547 ;  plotsprite bat_explode1 2 bat1x bat1y batanimationframe

    lda #<bat_explode1
    ldy batanimationframe
      clc
      beq plotspritewidthskip18
plotspritewidthloop18
      adc #bat_explode1_width
      dey
      bne plotspritewidthloop18
plotspritewidthskip18
    sta temp1

    lda #>bat_explode1
    sta temp2

    lda #(64|bat_explode1_width_twoscompliment)
    sta temp3

    lda bat1x
    sta temp4

    lda bat1y
    sta temp5

    lda #(bat_explode1_mode|%01000000)
    sta temp6

 jsr plotsprite
.bat1deathskip
 ; bat1deathskip

.
 ; 

.L01548 ;  rem ** jump to bat1death sub if the bat has been shot or touched

.L01549 ;  if bat2deathflag = 1 then goto bat2death

	LDA bat2deathflag
	CMP #1
     BNE .skipL01549
.condpart324
 jmp .bat2death

.skipL01549
.
 ; 

.L01550 ;  rem ** skip bat death sub if wiz mode is active

.L01551 ;  if wizmode > 0 then goto bat2deathskip

	LDA #0
	CMP wizmode
     BCS .skipL01551
.condpart325
 jmp .bat2deathskip

.skipL01551
.
 ; 

.L01552 ;  rem ** Animation Frames for Bat 2

.L01553 ;  plotsprite bat4 2 bat2x bat2y batanimationframe

    lda #<bat4
    ldy batanimationframe
      clc
      beq plotspritewidthskip19
plotspritewidthloop19
      adc #bat4_width
      dey
      bne plotspritewidthloop19
plotspritewidthskip19
    sta temp1

    lda #>bat4
    sta temp2

    lda #(64|bat4_width_twoscompliment)
    sta temp3

    lda bat2x
    sta temp4

    lda bat2y
    sta temp5

    lda #(bat4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01554 ;  goto bat2deathskip

 jmp .bat2deathskip

.
 ; 

.bat2death
 ; bat2death

.L01555 ;  plotsprite bat_explode1 2 bat2x bat2y batanimationframe

    lda #<bat_explode1
    ldy batanimationframe
      clc
      beq plotspritewidthskip20
plotspritewidthloop20
      adc #bat_explode1_width
      dey
      bne plotspritewidthloop20
plotspritewidthskip20
    sta temp1

    lda #>bat_explode1
    sta temp2

    lda #(64|bat_explode1_width_twoscompliment)
    sta temp3

    lda bat2x
    sta temp4

    lda bat2y
    sta temp5

    lda #(bat_explode1_mode|%01000000)
    sta temp6

 jsr plotsprite
.bat2deathskip
 ; bat2deathskip

.
 ; 

.L01556 ;  rem ** wizard mode stuff

.L01557 ;  if wizmode < 200 then skipplotwiz

	LDA wizmode
	CMP #200
 if ((* - .skipplotwiz) < 127) && ((* - .skipplotwiz) > -128)
	bcc .skipplotwiz
 else
	bcs .8skipskipplotwiz
	jmp .skipplotwiz
.8skipskipplotwiz
 endif
.L01558 ;  if wizmodeover > 0  &&  wizdeathflag = 1 then gosub plotwizexplode

	LDA #0
	CMP wizmodeover
     BCS .skipL01558
.condpart326
	LDA wizdeathflag
	CMP #1
     BNE .skip326then
.condpart327
 jsr .plotwizexplode

.skip326then
.skipL01558
.L01559 ;  if wizmodeover > 0 then skipplotwiz

	LDA #0
	CMP wizmodeover
 if ((* - .skipplotwiz) < 127) && ((* - .skipplotwiz) > -128)
	bcc .skipplotwiz
 else
	bcs .9skipskipplotwiz
	jmp .skipplotwiz
.9skipskipplotwiz
 endif
.L01560 ;  if wizx = 200 then skipplotwiz

	LDA wizx
	CMP #200
 if ((* - .skipplotwiz) < 127) && ((* - .skipplotwiz) > -128)
	BEQ .skipplotwiz
 else
	bne .10skipskipplotwiz
	jmp .skipplotwiz
.10skipskipplotwiz
 endif
.L01561 ;  if wizwarpcountdown < 200 then wiztempx = wizx : wiztempy = wizy : goto skipwarpeffect

	LDA wizwarpcountdown
	CMP #200
     BCS .skipL01561
.condpart328
	LDA wizx
	STA wiztempx
	LDA wizy
	STA wiztempy
 jmp .skipwarpeffect

.skipL01561
.L01562 ;  temp2 = framecounter & 1

	LDA framecounter
	AND #1
	STA temp2
.L01563 ;  temp3 = framecounter & 2

	LDA framecounter
	AND #2
	STA temp3
.L01564 ;  temp4 =  ( wizwarpcountdown - 200 )  * 2

; complex statement detected
	LDA wizwarpcountdown
	SEC
	SBC #200
	asl
	STA temp4
.L01565 ;  if temp2 = 1 then wiztempx = wizx - temp4 else wiztempx = wizx + temp4

	LDA temp2
	CMP #1
     BNE .skipL01565
.condpart329
	LDA wizx
	SEC
	SBC temp4
	STA wiztempx
 jmp .skipelse2
.skipL01565
	LDA wizx
	CLC
	ADC temp4
	STA wiztempx
.skipelse2
.L01566 ;  if temp3 = 2 then wiztempy = wizy - temp4 else wiztempy = wizy + temp4

	LDA temp3
	CMP #2
     BNE .skipL01566
.condpart330
	LDA wizy
	SEC
	SBC temp4
	STA wiztempy
 jmp .skipelse3
.skipL01566
	LDA wizy
	CLC
	ADC temp4
	STA wiztempy
.skipelse3
.skipwarpeffect
 ; skipwarpeffect

.L01567 ;  plotsprite wizlefttop1 0 wiztempx wiztempy wizanimationframe

    lda #<wizlefttop1
    ldy wizanimationframe
      clc
      beq plotspritewidthskip21
plotspritewidthloop21
      adc #wizlefttop1_width
      dey
      bne plotspritewidthloop21
plotspritewidthskip21
    sta temp1

    lda #>wizlefttop1
    sta temp2

    lda #(0|wizlefttop1_width_twoscompliment)
    sta temp3

    lda wiztempx
    sta temp4

    lda wiztempy
    sta temp5

    lda #(wizlefttop1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01568 ;  wiztempy = wiztempy + 8

	LDA wiztempy
	CLC
	ADC #8
	STA wiztempy
.L01569 ;  plotsprite wizleftbottom1 0 wiztempx wiztempy wizanimationframe

    lda #<wizleftbottom1
    ldy wizanimationframe
      clc
      beq plotspritewidthskip22
plotspritewidthloop22
      adc #wizleftbottom1_width
      dey
      bne plotspritewidthloop22
plotspritewidthskip22
    sta temp1

    lda #>wizleftbottom1
    sta temp2

    lda #(0|wizleftbottom1_width_twoscompliment)
    sta temp3

    lda wiztempx
    sta temp4

    lda wiztempy
    sta temp5

    lda #(wizleftbottom1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipplotwiz
 ; skipplotwiz

.
 ; 

.L01570 ;  rem ** jump to spider death sub if the spider has been shot or touched

.L01571 ;  if spiderdeathflag = 1 then goto spiderdeath

	LDA spiderdeathflag
	CMP #1
     BNE .skipL01571
.condpart331
 jmp .spiderdeath

.skipL01571
.
 ; 

.L01572 ;  rem ** skip spider death if wizard mode is active

.L01573 ;  if wizmode > 0 then goto skipspiderdeath

	LDA #0
	CMP wizmode
     BCS .skipL01573
.condpart332
 jmp .skipspiderdeath

.skipL01573
.
 ; 

.L01574 ;  rem ** Animation Frames for Spider

.L01575 ;  rem ** Two 8x8 sprites stitched together top/bottom

.L01576 ;  plotsprite spd1top 4 spiderx spidery spideranimationframe

    lda #<spd1top
    ldy spideranimationframe
      clc
      beq plotspritewidthskip23
plotspritewidthloop23
      adc #spd1top_width
      dey
      bne plotspritewidthloop23
plotspritewidthskip23
    sta temp1

    lda #>spd1top
    sta temp2

    lda #(128|spd1top_width_twoscompliment)
    sta temp3

    lda spiderx
    sta temp4

    lda spidery
    sta temp5

    lda #(spd1top_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01577 ;  spidery = spidery + 8

	LDA spidery
	CLC
	ADC #8
	STA spidery
.L01578 ;  plotsprite spd1bot 4 spiderx spidery spideranimationframe

    lda #<spd1bot
    ldy spideranimationframe
      clc
      beq plotspritewidthskip24
plotspritewidthloop24
      adc #spd1bot_width
      dey
      bne plotspritewidthloop24
plotspritewidthskip24
    sta temp1

    lda #>spd1bot
    sta temp2

    lda #(128|spd1bot_width_twoscompliment)
    sta temp3

    lda spiderx
    sta temp4

    lda spidery
    sta temp5

    lda #(spd1bot_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01579 ;  spidery = spidery - 8

	LDA spidery
	SEC
	SBC #8
	STA spidery
.
 ; 

.L01580 ;  goto skipspiderdeath

 jmp .skipspiderdeath

.
 ; 

.spiderdeath
 ; spiderdeath

.L01581 ;  plotsprite spider1top_explode1 4 spiderx spidery spiderdeathframe

    lda #<spider1top_explode1
    ldy spiderdeathframe
      clc
      beq plotspritewidthskip25
plotspritewidthloop25
      adc #spider1top_explode1_width
      dey
      bne plotspritewidthloop25
plotspritewidthskip25
    sta temp1

    lda #>spider1top_explode1
    sta temp2

    lda #(128|spider1top_explode1_width_twoscompliment)
    sta temp3

    lda spiderx
    sta temp4

    lda spidery
    sta temp5

    lda #(spider1top_explode1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01582 ;  spidery = spidery + 8

	LDA spidery
	CLC
	ADC #8
	STA spidery
.L01583 ;  plotsprite spider1bottom_explode1 4 spiderx spidery spiderdeathframe

    lda #<spider1bottom_explode1
    ldy spiderdeathframe
      clc
      beq plotspritewidthskip26
plotspritewidthloop26
      adc #spider1bottom_explode1_width
      dey
      bne plotspritewidthloop26
plotspritewidthskip26
    sta temp1

    lda #>spider1bottom_explode1
    sta temp2

    lda #(128|spider1bottom_explode1_width_twoscompliment)
    sta temp3

    lda spiderx
    sta temp4

    lda spidery
    sta temp5

    lda #(spider1bottom_explode1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01584 ;  spidery = spidery - 8

	LDA spidery
	SEC
	SBC #8
	STA spidery
.
 ; 

.skipspiderdeath
 ; skipspiderdeath

.
 ; 

.L01585 ;  rem ** display the monster sprites

.L01586 ;  for temploop = 0 to 2

	LDA #0
	STA temploop
.L01586fortemploop
.L01587 ;  gosub displaymonstersprite

 jsr .displaymonstersprite

.L01588 ;  next

	LDA temploop
	CMP #2

	INC temploop
 if ((* - .L01586fortemploop) < 127) && ((* - .L01586fortemploop) > -128)
	bcc .L01586fortemploop
 else
	bcs .11skipL01586fortemploop
	jmp .L01586fortemploop
.11skipL01586fortemploop
 endif
.
 ; 

.L01589 ;  rem ** plot the bunker in the center of the screen

.L01590 ;  rem ** if the bunkerbuster variable is 1, your score has reaced 37,500 - display the blasted bunker instead

.L01591 ;  if skill = 4 then bunkerbuster = 1

	LDA skill
	CMP #4
     BNE .skipL01591
.condpart333
	LDA #1
	STA bunkerbuster
.skipL01591
.L01592 ;  if bunkerbuster = 1 then goto brokenbunker

	LDA bunkerbuster
	CMP #1
     BNE .skipL01592
.condpart334
 jmp .brokenbunker

.skipL01592
.L01593 ;  plotsprite widebar_top 2 76 64

    lda #<widebar_top
    sta temp1

    lda #>widebar_top
    sta temp2

    lda #(64|widebar_top_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #64

    sta temp5

    lda #(widebar_top_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01594 ;  plotsprite widebar 2 76 72

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #72

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01595 ;  plotsprite widebar 2 76 80

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #80

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01596 ;  goto skipbrokenbunker

 jmp .skipbrokenbunker

.brokenbunker
 ; brokenbunker

.L01597 ;  plotsprite widebar_top_broken 2 76 64

    lda #<widebar_top_broken
    sta temp1

    lda #>widebar_top_broken
    sta temp2

    lda #(64|widebar_top_broken_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #64

    sta temp5

    lda #(widebar_top_broken_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01598 ;  plotsprite widebar 2 76 72

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #72

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01599 ;  plotsprite widebar 2 76 80

    lda #<widebar
    sta temp1

    lda #>widebar
    sta temp2

    lda #(64|widebar_width_twoscompliment)
    sta temp3

    lda #76
    sta temp4

    lda #80

    sta temp5

    lda #(widebar_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipbrokenbunker
 ; skipbrokenbunker

.
 ; 

.L01600 ;  rem ** Animation Frames for Quiver

.L01601 ;  if objectblink <> 0 then goto skipplotquiver

	LDA objectblink
	CMP #0
     BEQ .skipL01601
.condpart335
 jmp .skipplotquiver

.skipL01601
.L01602 ;  if arrowcounter = 0 then plotsprite quiver1 2 quiverx quivery

	LDA arrowcounter
	CMP #0
     BNE .skipL01602
.condpart336
    lda #<quiver1
    sta temp1

    lda #>quiver1
    sta temp2

    lda #(64|quiver1_width_twoscompliment)
    sta temp3

    lda quiverx
    sta temp4

    lda quivery

    sta temp5

    lda #(quiver1_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01602
.skipplotquiver
 ; skipplotquiver

.
 ; 

.L01603 ;  if swordy = 200 then goto skipplotsword

	LDA swordy
	CMP #200
     BNE .skipL01603
.condpart337
 jmp .skipplotsword

.skipL01603
.L01604 ;  if objectblink = 0 then goto skipplotsword

	LDA objectblink
	CMP #0
     BNE .skipL01604
.condpart338
 jmp .skipplotsword

.skipL01604
.L01605 ;  plotsprite swordtop 2 swordx swordy

    lda #<swordtop
    sta temp1

    lda #>swordtop
    sta temp2

    lda #(64|swordtop_width_twoscompliment)
    sta temp3

    lda swordx
    sta temp4

    lda swordy

    sta temp5

    lda #(swordtop_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01606 ;  swordy = swordy + 8

	LDA swordy
	CLC
	ADC #8
	STA swordy
.L01607 ;  plotsprite swordbottom 2 swordx swordy

    lda #<swordbottom
    sta temp1

    lda #>swordbottom
    sta temp2

    lda #(64|swordbottom_width_twoscompliment)
    sta temp3

    lda swordx
    sta temp4

    lda swordy

    sta temp5

    lda #(swordbottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01608 ;  swordy = swordy - 8

	LDA swordy
	SEC
	SBC #8
	STA swordy
.skipplotsword
 ; skipplotsword

.
 ; 

.L01609 ;  rem ** plot the arrow sprite for the player

.L01610 ;  if xpos_fire <> 200 then plotsprite arrow 2 xpos_fire ypos_fire

	LDA xpos_fire
	CMP #200
     BEQ .skipL01610
.condpart339
    lda #<arrow
    sta temp1

    lda #>arrow
    sta temp2

    lda #(64|arrow_width_twoscompliment)
    sta temp3

    lda xpos_fire
    sta temp4

    lda ypos_fire

    sta temp5

    lda #(arrow_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01610
.
 ; 

.L01611 ;  rem ** plot the arrow sprite for monster 

.L01612 ;  rem on level 5, the monster 3 type will fire a larger arrow

.
 ; 

.L01613 ;  rem ** If you're on Expert mode, all shots are the shot blocking type.  Skip over normal arrow firing section.

.L01614 ;  if skill = 4 then goto skill4shots

	LDA skill
	CMP #4
     BNE .skipL01614
.condpart340
 jmp .skill4shots

.skipL01614
.
 ; 

.L01615 ;  rem ** plot the normal arrow when enemies fire

.L01616 ;  if r1x_fire <> 200  &&  newfire1 = 0 then plotsprite arrow2 2 r1x_fire r1y_fire

	LDA r1x_fire
	CMP #200
     BEQ .skipL01616
.condpart341
	LDA newfire1
	CMP #0
     BNE .skip341then
.condpart342
    lda #<arrow2
    sta temp1

    lda #>arrow2
    sta temp2

    lda #(64|arrow2_width_twoscompliment)
    sta temp3

    lda r1x_fire
    sta temp4

    lda r1y_fire

    sta temp5

    lda #(arrow2_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip341then
.skipL01616
.L01617 ;  if r2x_fire <> 200  &&  newfire2 = 0 then plotsprite arrow2 2 r2x_fire r2y_fire

	LDA r2x_fire
	CMP #200
     BEQ .skipL01617
.condpart343
	LDA newfire2
	CMP #0
     BNE .skip343then
.condpart344
    lda #<arrow2
    sta temp1

    lda #>arrow2
    sta temp2

    lda #(64|arrow2_width_twoscompliment)
    sta temp3

    lda r2x_fire
    sta temp4

    lda r2y_fire

    sta temp5

    lda #(arrow2_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip343then
.skipL01617
.L01618 ;  if r3x_fire <> 200  &&  newfire3 = 0  &&  levelvalue < 5 then plotsprite arrow2 2 r3x_fire r3y_fire

	LDA r3x_fire
	CMP #200
     BEQ .skipL01618
.condpart345
	LDA newfire3
	CMP #0
     BNE .skip345then
.condpart346
	LDA levelvalue
	CMP #5
     BCS .skip346then
.condpart347
    lda #<arrow2
    sta temp1

    lda #>arrow2
    sta temp2

    lda #(64|arrow2_width_twoscompliment)
    sta temp3

    lda r3x_fire
    sta temp4

    lda r3y_fire

    sta temp5

    lda #(arrow2_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip346then
.skip345then
.skipL01618
.L01619 ;  if r3x_fire <> 200  &&  newfire3 = 0  &&  levelvalue > 4 then plotsprite arrow_large 2 r3x_fire r3y_fire

	LDA r3x_fire
	CMP #200
     BEQ .skipL01619
.condpart348
	LDA newfire3
	CMP #0
     BNE .skip348then
.condpart349
	LDA #4
	CMP levelvalue
     BCS .skip349then
.condpart350
    lda #<arrow_large
    sta temp1

    lda #>arrow_large
    sta temp2

    lda #(64|arrow_large_width_twoscompliment)
    sta temp3

    lda r3x_fire
    sta temp4

    lda r3y_fire

    sta temp5

    lda #(arrow_large_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip349then
.skip348then
.skipL01619
.L01620 ;  goto skipskill4shots

 jmp .skipskill4shots

.
 ; 

.L01621 ;  rem ** plot the shot blocking arrow when enemies fire

.skill4shots
 ; skill4shots

.L01622 ;  if r1x_fire <> 200  &&  newfire1 = 0 then plotsprite arrow_large 2 r1x_fire r1y_fire

	LDA r1x_fire
	CMP #200
     BEQ .skipL01622
.condpart351
	LDA newfire1
	CMP #0
     BNE .skip351then
.condpart352
    lda #<arrow_large
    sta temp1

    lda #>arrow_large
    sta temp2

    lda #(64|arrow_large_width_twoscompliment)
    sta temp3

    lda r1x_fire
    sta temp4

    lda r1y_fire

    sta temp5

    lda #(arrow_large_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip351then
.skipL01622
.L01623 ;  if r2x_fire <> 200  &&  newfire2 = 0 then plotsprite arrow_large 2 r2x_fire r2y_fire

	LDA r2x_fire
	CMP #200
     BEQ .skipL01623
.condpart353
	LDA newfire2
	CMP #0
     BNE .skip353then
.condpart354
    lda #<arrow_large
    sta temp1

    lda #>arrow_large
    sta temp2

    lda #(64|arrow_large_width_twoscompliment)
    sta temp3

    lda r2x_fire
    sta temp4

    lda r2y_fire

    sta temp5

    lda #(arrow_large_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip353then
.skipL01623
.L01624 ;  if r3x_fire <> 200  &&  newfire3 = 0 then plotsprite arrow_large 2 r3x_fire r3y_fire

	LDA r3x_fire
	CMP #200
     BEQ .skipL01624
.condpart355
	LDA newfire3
	CMP #0
     BNE .skip355then
.condpart356
    lda #<arrow_large
    sta temp1

    lda #>arrow_large
    sta temp2

    lda #(64|arrow_large_width_twoscompliment)
    sta temp3

    lda r3x_fire
    sta temp4

    lda r3y_fire

    sta temp5

    lda #(arrow_large_mode|%01000000)
    sta temp6

 jsr plotsprite
.skip355then
.skipL01624
.skipskill4shots
 ; skipskill4shots

.
 ; 

.L01625 ;  rem ** plot the arrows remaining     

.L01626 ;  temp1 = arrowcounter

	LDA arrowcounter
	STA temp1
.L01627 ;  if temp1 > 8 then temp1 = 8

	LDA #8
	CMP temp1
     BCS .skipL01627
.condpart357
	LDA #8
	STA temp1
.skipL01627
.L01628 ;  rem ** if you have unlimited arrows, skip plotting the number of arrows and display the "unlimited" sprite instead

.L01629 ;  if arrowsvalue = 9 then plotsprite arrowbar_nolimit 6 136 208 : goto skipbar

	LDA arrowsvalue
	CMP #9
     BNE .skipL01629
.condpart358
    lda #<arrowbar_nolimit
    sta temp1

    lda #>arrowbar_nolimit
    sta temp2

    lda #(192|arrowbar_nolimit_width_twoscompliment)
    sta temp3

    lda #136
    sta temp4

    lda #208
    sta temp5

    lda #(arrowbar_nolimit_mode|%01000000)
    sta temp6

 jsr plotsprite
 jmp .skipbar

.skipL01629
.
 ; 

.L01630 ;  rem ** plot the number of arrows remaining on the status bar

.L01631 ;  plotsprite arrowbar0 6 135 208 temp1

    lda #<arrowbar0
    ldy temp1
      clc
      beq plotspritewidthskip27
plotspritewidthloop27
      adc #arrowbar0_width
      dey
      bne plotspritewidthloop27
plotspritewidthskip27
    sta temp1

    lda #>arrowbar0
    sta temp2

    lda #(192|arrowbar0_width_twoscompliment)
    sta temp3

    lda #135
    sta temp4

    lda #208
    sta temp5

    lda #(arrowbar0_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipbar
 ; skipbar

.
 ; 

.L01632 ;  rem ** plot treasure sprite

.
 ; 

.L01633 ;  rem ** the treasure will flash for the last 3 or so seconds it's onscreen

.L01634 ;  if treasuretimer2 > 9 then goto flashtreasure

	LDA #9
	CMP treasuretimer2
     BCS .skipL01634
.condpart359
 jmp .flashtreasure

.skipL01634
.L01635 ;  plotsprite treasure 5 treasurex treasurey

    lda #<treasure
    sta temp1

    lda #>treasure
    sta temp2

    lda #(160|treasure_width_twoscompliment)
    sta temp3

    lda treasurex
    sta temp4

    lda treasurey

    sta temp5

    lda #(treasure_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01636 ;  goto skipflashtreasure

 jmp .skipflashtreasure

.flashtreasure
 ; flashtreasure

.L01637 ;  treasurep = treasurep_i[treasureindex]

	LDX treasureindex
	LDA treasurep_i,x
	STA treasurep
.L01638 ;  plotsprite treasure treasurep treasurex treasurey

    lda #<treasure
    sta temp1

    lda #>treasure
    sta temp2

    lda treasurep
    asl
    asl
    asl
    asl
    asl
    ora #treasure_width_twoscompliment
    sta temp3

    lda treasurex
    sta temp4

    lda treasurey

    sta temp5

    lda #(treasure_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01639 ;  data treasurep_i

	JMP .skipL01639
treasurep_i
	.byte   3, 4, 5, 6, 7, 3

.skipL01639
.skipflashtreasure
 ; skipflashtreasure

.
 ; 

.L01640 ;  drawscreen

 jsr drawscreen
.
 ; 

.L01641 ;  rem ** if you die right when you're entering wiz mode,

.L01642 ;  rem ** the death animation won't play over and over again.  

.L01643 ;  rem ** The normal collision routine is otherwise skipped.

.L01644 ;  if wizmode > 0  &&  deathframe = 15  &&  playerdeathflag = 1 then gosub losealife : playerdeathflag = 0 : playerinvisibletime = 180 : p0_x = 84 : p0_y = 68 : fire_dir_save = 1 : fire_dir = 1

	LDA #0
	CMP wizmode
     BCS .skipL01644
.condpart360
	LDA deathframe
	CMP #15
     BNE .skip360then
.condpart361
	LDA playerdeathflag
	CMP #1
     BNE .skip361then
.condpart362
 jsr .losealife
	LDA #0
	STA playerdeathflag
	LDA #180
	STA playerinvisibletime
	LDA #84
	STA p0_x
	LDA #68
	STA p0_y
	LDA #1
	STA fire_dir_save
	STA fire_dir
.skip361then
.skip360then
.skipL01644
.
 ; 

.L01645 ;  treasureindex = treasureindex + 1

	LDA treasureindex
	CLC
	ADC #1
	STA treasureindex
.L01646 ;  if treasureindex > 5 then treasureindex = 0

	LDA #5
	CMP treasureindex
     BCS .skipL01646
.condpart363
	LDA #0
	STA treasureindex
.skipL01646
.
 ; 

.L01647 ;  rem ** Collision with treasure

.L01648 ;  rem 

.L01649 ;  rem ** if you avoid playing the treasure pickup sound when wizmode>0 && wizmode<200 it won't interrupt the wiz music, 

.L01650 ;  rem ** but will be available during full blown wizard mode

.L01651 ;  rem

.L01652 ;  if quadframe = 0  &&  treasurex < 200  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  treasurex , treasurey ,  6 , 8 )  then gosub treasurespeak : score0 = score0 + 000500 : extralife_counter = extralife_counter + 1 : treasureplaced = 0 : treasure_rplace = 0 : treasure_rplace2 = 0 : treasuretimer = 1 : treasuretimer2 = 0 : gosub pickupsound

	LDA quadframe
	CMP #0
     BNE .skipL01652
.condpart364
	LDA treasurex
	CMP #200
     BCS .skip364then
.condpart365
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda treasurex
    sta temp5
    lda treasurey
    sta temp6
    lda #6-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skip365then
.condpart366
 jsr .treasurespeak
	SED
	CLC
	LDA score0+1
	ADC #$05
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
	LDA extralife_counter
	CLC
	ADC #1
	STA extralife_counter
	LDA #0
	STA treasureplaced
	STA treasure_rplace
	STA treasure_rplace2
	LDA #1
	STA treasuretimer
	LDA #0
	STA treasuretimer2
 jsr .pickupsound

.skip365then
.skip364then
.skipL01652
.
 ; 

.L01653 ;  rem ** Collision with sword

.L01654 ;  if quadframe = 1  &&  swordx < 200  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  swordx , swordy ,  6 , 16 )  then gosub godspeak : score0 = score0 + 000100 : invincibleflag = 1 : invincible_on = 1 : invincible_counter1 = 0 : invincible_counter2 = 0 : swordplaced = 0 : sword_rplace = 0 : sword_rplace2 = 0 : gosub pickupsound

	LDA quadframe
	CMP #1
     BNE .skipL01654
.condpart367
	LDA swordx
	CMP #200
     BCS .skip367then
.condpart368
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda swordx
    sta temp5
    lda swordy
    sta temp6
    lda #6-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip368then
.condpart369
 jsr .godspeak
	SED
	CLC
	LDA score0+1
	ADC #$01
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
	LDA #1
	STA invincibleflag
	STA invincible_on
	LDA #0
	STA invincible_counter1
	STA invincible_counter2
	STA swordplaced
	STA sword_rplace
	STA sword_rplace2
 jsr .pickupsound

.skip368then
.skip367then
.skipL01654
.
 ; 

.L01655 ;  if wizmode = 0 then gosub monstlogic

	LDA wizmode
	CMP #0
     BNE .skipL01655
.condpart370
 jsr .monstlogic

.skipL01655
.
 ; 

.L01656 ;  if spiderdeathflag = 0  &&  wizmode = 0 then gosub spiderlogic

	LDA spiderdeathflag
	CMP #0
     BNE .skipL01656
.condpart371
	LDA wizmode
	CMP #0
     BNE .skip371then
.condpart372
 jsr .spiderlogic

.skip371then
.skipL01656
.L01657 ;  if wizmode > 0 then goto skipbatlogic

	LDA #0
	CMP wizmode
     BCS .skipL01657
.condpart373
 jmp .skipbatlogic

.skipL01657
.L01658 ;  if bat1deathflag = 1  ||  bat2deathflag = 1 then goto skipbatlogic

	LDA bat1deathflag
	CMP #1
     BNE .skipL01658
.condpart374
 jmp .condpart375
.skipL01658
	LDA bat2deathflag
	CMP #1
     BNE .skip92OR
.condpart375
 jmp .skipbatlogic

.skip92OR
.L01659 ;  if levelvalue < 5 then gosub batlogic

	LDA levelvalue
	CMP #5
     BCS .skipL01659
.condpart376
 jsr .batlogic

.skipL01659
.skipbatlogic
 ; skipbatlogic

.
 ; 

.L01660 ;  rem ** Enemy respawn in lower left is monster1x=8:monster1y=144

.
 ; 

.L01661 ;  rem ** what do these box collision code lines do for the enemies?

.L01662 ;  rem 

.L01663 ;  rem    rem -- play the explosion sound

.L01664 ;  rem    if boxcollision(xpos_fire,ypos_fire, 8,8, monster1x,monster1y, 8,8) then playsfx sfx_explode

.L01665 ;  rem 

.L01666 ;  rem    rem -- increase the score

.L01667 ;  rem    score0=score0+100

.L01668 ;  rem  

.L01669 ;  rem    rem -- reset the counter for the explosion animation

.L01670 ;  rem    slowdown_explode=0

.L01671 ;  rem

.L01672 ;  rem    rem -- set the death flag to 1, indicating monster death 

.L01673 ;  rem    enemy1deathflag=1

.L01674 ;  rem

.L01675 ;  rem    rem -- if you've reached the last frame of the death animation, then reset the monster to the spawn point, and

.L01676 ;  rem           reset the death flag to "alive", which is 0

.L01677 ;  rem    if explodeframe=7 && enemy1deathflag=1 then monster1x=208:monster1y=208:enemy1deathflag=0

.
 ; 

.L01678 ;  if levelvalue < 5 then monster1_shieldflag = 0 : r1hp = 0

	LDA levelvalue
	CMP #5
     BCS .skipL01678
.condpart377
	LDA #0
	STA monster1_shieldflag
	STA r1hp
.skipL01678
.
 ; 

.L01679 ;  if r1hp > 0 then monster1_shieldflag = 1 else monster1_shieldflag = 0

	LDA #0
	CMP r1hp
     BCS .skipL01679
.condpart378
	LDA #1
	STA monster1_shieldflag
 jmp .skipelse4
.skipL01679
	LDA #0
	STA monster1_shieldflag
.skipelse4
.L01680 ;  if r2hp > 0 then monster2_shieldflag = 1 else monster2_shieldflag = 0

	LDA #0
	CMP r2hp
     BCS .skipL01680
.condpart379
	LDA #1
	STA monster2_shieldflag
 jmp .skipelse5
.skipL01680
	LDA #0
	STA monster2_shieldflag
.skipelse5
.L01681 ;  if r3hp > 0 then monster3_shieldflag = 1 else monster3_shieldflag = 0

	LDA #0
	CMP r3hp
     BCS .skipL01681
.condpart380
	LDA #1
	STA monster3_shieldflag
 jmp .skipelse6
.skipL01681
	LDA #0
	STA monster3_shieldflag
.skipelse6
.
 ; 

.L01682 ;  rem ** Collision code for Player's arrows hitting an enemy monster

.
 ; 

.L01683 ;  rem ** detect the end of the death animation, reset death flag to off, reset to spawn point, add to score

.L01684 ;  if explodeframe1 = 7  &&  enemy1deathflag = 1 then gosub monster1respawn : enemy1deathflag = 0 : if wizmode = 0 then score0 = score0 + 000400

	LDA explodeframe1
	CMP #7
     BNE .skipL01684
.condpart381
	LDA enemy1deathflag
	CMP #1
     BNE .skip381then
.condpart382
 jsr .monster1respawn
	LDA #0
	STA enemy1deathflag
	LDA wizmode
	CMP #0
     BNE .skip382then
.condpart383
	SED
	CLC
	LDA score0+1
	ADC #$04
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
.skip382then
.skip381then
.skipL01684
.L01685 ;  if explodeframe2 = 7  &&  enemy2deathflag = 1 then gosub monster2respawn : enemy2deathflag = 0 : if wizmode = 0 then score0 = score0 + 000600

	LDA explodeframe2
	CMP #7
     BNE .skipL01685
.condpart384
	LDA enemy2deathflag
	CMP #1
     BNE .skip384then
.condpart385
 jsr .monster2respawn
	LDA #0
	STA enemy2deathflag
	LDA wizmode
	CMP #0
     BNE .skip385then
.condpart386
	SED
	CLC
	LDA score0+1
	ADC #$06
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
.skip385then
.skip384then
.skipL01685
.L01686 ;  if explodeframe3 = 7  &&  enemy3deathflag = 1 then gosub monster3respawn : enemy3deathflag = 0 : if wizmode = 0 then score0 = score0 + 000800

	LDA explodeframe3
	CMP #7
     BNE .skipL01686
.condpart387
	LDA enemy3deathflag
	CMP #1
     BNE .skip387then
.condpart388
 jsr .monster3respawn
	LDA #0
	STA enemy3deathflag
	LDA wizmode
	CMP #0
     BNE .skip388then
.condpart389
	SED
	CLC
	LDA score0+1
	ADC #$08
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
.skip388then
.skip387then
.skipL01686
.
 ; 

.L01687 ;  if wizmode > 0 then goto skipregularenemycollisions

	LDA #0
	CMP wizmode
     BCS .skipL01687
.condpart390
 jmp .skipregularenemycollisions

.skipL01687
.
 ; 

.L01688 ;  rem ** Detect a collision between player arrow and monster, play explosion sound, reset explosion animation, set enemy death flag to on

.L01689 ;  rem ** Will also skip collision if monster type is 255

.
 ; 

.L01690 ;  rem --Enemy 1-- (Demon Bat)

.L01691 ;  if xpos_fire = 200 then goto skipr3hit

	LDA xpos_fire
	CMP #200
     BNE .skipL01691
.condpart391
 jmp .skipr3hit

.skipL01691
.L01692 ;  if monster1type = 255 then goto skipr1hit

	LDA monster1type
	CMP #255
     BNE .skipL01692
.condpart392
 jmp .skipr1hit

.skipL01692
.L01693 ;  if enemy1deathflag = 1 then goto skipr1hit

	LDA enemy1deathflag
	CMP #1
     BNE .skipL01693
.condpart393
 jmp .skipr1hit

.skipL01693
.L01694 ;  if altframe = 1 then goto skipr1hit

	LDA altframe
	CMP #1
     BNE .skipL01694
.condpart394
 jmp .skipr1hit

.skipL01694
.L01695 ;  if monster1_shieldflag = 0  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster1x , monster1y ,  8 , 16 )  then xpos_fire = 200 : playsfx sfx_explode : slowdown_explode = 0 : enemy1deathflag = 1 : explodeframe1 = 0 : fireheld = 1 : goto skipr3hit

	LDA monster1_shieldflag
	CMP #0
     BNE .skipL01695
.condpart395
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster1x
    sta temp5
    lda monster1y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip395then
.condpart396
	LDA #200
	STA xpos_fire
    lda #<sfx_explode
    sta temp1
    lda #>sfx_explode
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #0
	STA slowdown_explode
	LDA #1
	STA enemy1deathflag
	LDA #0
	STA explodeframe1
	LDA #1
	STA fireheld
 jmp .skipr3hit

.skip395then
.skipL01695
.L01696 ;  if monster1_shieldflag = 1  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster1x , monster1y ,  8 , 16 )  then xpos_fire = 200 : gosub r1hit : goto skipr3hit

	LDA monster1_shieldflag
	CMP #1
     BNE .skipL01696
.condpart397
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster1x
    sta temp5
    lda monster1y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip397then
.condpart398
	LDA #200
	STA xpos_fire
 jsr .r1hit
 jmp .skipr3hit

.skip397then
.skipL01696
.skipr1hit
 ; skipr1hit

.
 ; 

.L01697 ;  rem --Enemy 2-- (Snake)

.L01698 ;  if monster2type = 255 then goto skipr2hit

	LDA monster2type
	CMP #255
     BNE .skipL01698
.condpart399
 jmp .skipr2hit

.skipL01698
.L01699 ;  if enemy2deathflag = 1 then goto skipr2hit

	LDA enemy2deathflag
	CMP #1
     BNE .skipL01699
.condpart400
 jmp .skipr2hit

.skipL01699
.L01700 ;  if altframe = 0 then goto skipr2hit

	LDA altframe
	CMP #0
     BNE .skipL01700
.condpart401
 jmp .skipr2hit

.skipL01700
.L01701 ;  if monster2_shieldflag = 1  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster2x , monster2y ,  8 , 14 )  then xpos_fire = 200 : gosub r2hit : goto skipr3hit

	LDA monster2_shieldflag
	CMP #1
     BNE .skipL01701
.condpart402
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster2x
    sta temp5
    lda monster2y
    sta temp6
    lda #8-1
    sta temp7
    lda #14-1
    sta temp8
   jsr boxcollision
   BCC .skip402then
.condpart403
	LDA #200
	STA xpos_fire
 jsr .r2hit
 jmp .skipr3hit

.skip402then
.skipL01701
.monster2hit
 ; monster2hit

.L01702 ;  if monster2_shieldflag = 0  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster2x , monster2y ,  8 , 16 )  then xpos_fire = 200 : playsfx sfx_explode : slowdown_explode = 0 : enemy2deathflag = 1 : explodeframe2 = 0 : fireheld = 1 : goto skipr3hit

	LDA monster2_shieldflag
	CMP #0
     BNE .skipL01702
.condpart404
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster2x
    sta temp5
    lda monster2y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip404then
.condpart405
	LDA #200
	STA xpos_fire
    lda #<sfx_explode
    sta temp1
    lda #>sfx_explode
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #0
	STA slowdown_explode
	LDA #1
	STA enemy2deathflag
	LDA #0
	STA explodeframe2
	LDA #1
	STA fireheld
 jmp .skipr3hit

.skip404then
.skipL01702
.skipr2hit
 ; skipr2hit

.
 ; 

.L01703 ;  rem --Enemy 3-- (Skeleton Warrior)

.L01704 ;  if monster3type = 255 then goto skipr3hit

	LDA monster3type
	CMP #255
     BNE .skipL01704
.condpart406
 jmp .skipr3hit

.skipL01704
.L01705 ;  if enemy3deathflag = 1 then goto skipr3hit

	LDA enemy3deathflag
	CMP #1
     BNE .skipL01705
.condpart407
 jmp .skipr3hit

.skipL01705
.L01706 ;  if altframe = 1 then goto skipr3hit

	LDA altframe
	CMP #1
     BNE .skipL01706
.condpart408
 jmp .skipr3hit

.skipL01706
.L01707 ;  if monster3_shieldflag = 0  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster3x , monster3y ,  8 , 16 )  then xpos_fire = 200 : playsfx sfx_explode : slowdown_explode = 0 : enemy3deathflag = 1 : explodeframe3 = 0 : fireheld = 1

	LDA monster3_shieldflag
	CMP #0
     BNE .skipL01707
.condpart409
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster3x
    sta temp5
    lda monster3y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip409then
.condpart410
	LDA #200
	STA xpos_fire
    lda #<sfx_explode
    sta temp1
    lda #>sfx_explode
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #0
	STA slowdown_explode
	LDA #1
	STA enemy3deathflag
	LDA #0
	STA explodeframe3
	LDA #1
	STA fireheld
.skip409then
.skipL01707
.L01708 ;  if monster3_shieldflag = 1  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  monster3x , monster3y ,  8 , 16 )  then xpos_fire = 200 : gosub r3hit

	LDA monster3_shieldflag
	CMP #1
     BNE .skipL01708
.condpart411
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda monster3x
    sta temp5
    lda monster3y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip411then
.condpart412
	LDA #200
	STA xpos_fire
 jsr .r3hit

.skip411then
.skipL01708
.skipr3hit
 ; skipr3hit

.
 ; 

.L01709 ;  rem ** Collision code for the player running into an enemy

.
 ; 

.L01710 ;  rem ** Enemies can't shoot you or hurt you by running into you in god mode

.L01711 ;  if godvalue = 2  ||  invincible_on = 1 then goto skipmonsterfire

	LDA godvalue
	CMP #2
     BNE .skipL01711
.condpart413
 jmp .condpart414
.skipL01711
	LDA invincible_on
	CMP #1
     BNE .skip102OR
.condpart414
 jmp .skipmonsterfire

.skip102OR
.
 ; 

.L01712 ;  rem ** skip monster firing code if wizard mode is active

.L01713 ;  if wizmode > 0 then goto skipmonsterfire

	LDA #0
	CMP wizmode
     BCS .skipL01713
.condpart415
 jmp .skipmonsterfire

.skipL01713
.
 ; 

.L01714 ;  rem ** monsters can't hurt you if they're exploding

.L01715 ;  if enemy1deathflag = 1 then r1x_fire = 200 : goto skipmonsterfire

	LDA enemy1deathflag
	CMP #1
     BNE .skipL01715
.condpart416
	LDA #200
	STA r1x_fire
 jmp .skipmonsterfire

.skipL01715
.L01716 ;  if enemy2deathflag = 2 then r2x_fire = 200 : goto skipmonsterfire

	LDA enemy2deathflag
	CMP #2
     BNE .skipL01716
.condpart417
	LDA #200
	STA r2x_fire
 jmp .skipmonsterfire

.skipL01716
.L01717 ;  if enemy3deathflag = 3 then r3x_fire = 200 : goto skipmonsterfire

	LDA enemy3deathflag
	CMP #3
     BNE .skipL01717
.condpart418
	LDA #200
	STA r3x_fire
 jmp .skipmonsterfire

.skipL01717
.
 ; 

.L01718 ;  rem ** detect the end of the player death animation, reset death flag to off, reset to bunker location, set firing direction to up

.L01719 ;  if deathframe = 15  &&  playerdeathflag = 1 then gosub losealife : playerdeathflag = 0 : playerinvisibletime = 180 : p0_x = 84 : p0_y = 68 : fire_dir_save = 1 : fire_dir = 1

	LDA deathframe
	CMP #15
     BNE .skipL01719
.condpart419
	LDA playerdeathflag
	CMP #1
     BNE .skip419then
.condpart420
 jsr .losealife
	LDA #0
	STA playerdeathflag
	LDA #180
	STA playerinvisibletime
	LDA #84
	STA p0_x
	LDA #68
	STA p0_y
	LDA #1
	STA fire_dir_save
	STA fire_dir
.skip419then
.skipL01719
.
 ; 

.L01720 ;  rem ** if the player death animation is running, skip collision detection

.L01721 ;  rem ** also skip if demo mod is on, so sounds don't play

.L01722 ;  if playerdeathflag = 1 then goto skipr3coll

	LDA playerdeathflag
	CMP #1
     BNE .skipL01722
.condpart421
 jmp .skipr3coll

.skipL01722
.
 ; 

.L01723 ;  rem ** Detect a collision between player and enemy, play explosion sound, reset explosion animation, set enemy death flag to on

.L01724 ;  rem ** Will also skip collision if monster type is 255

.L01725 ;  rem

.L01726 ;  rem v215 - added this next line to ensure no regular enemy collisions are registered with enemies while wizmode is active

.L01727 ;  if wizmode > 0 then skipr3coll

	LDA #0
	CMP wizmode
 if ((* - .skipr3coll) < 127) && ((* - .skipr3coll) > -128)
	bcc .skipr3coll
 else
	bcs .12skipskipr3coll
	jmp .skipr3coll
.12skipskipr3coll
 endif
.L01728 ;  rem

.
 ; 

.L01729 ;  rem ** the "goto skiprXcoll" statements are to skip collisions if the monsters are set to be invisible (based on level, when set to 255).

.L01730 ;  if monster1type = 255 then goto skipr1coll

	LDA monster1type
	CMP #255
     BNE .skipL01730
.condpart422
 jmp .skipr1coll

.skipL01730
.L01731 ;  if altframe = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  monster1x , monster1y ,  8 , 16 )  then playsfx sfx_deathsound : playerdeathflag = 1 : gosub monster1respawn : deathframe = 0

	LDA altframe
	CMP #0
     BNE .skipL01731
.condpart423
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda monster1x
    sta temp5
    lda monster1y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip423then
.condpart424
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
 jsr .monster1respawn
	LDA #0
	STA deathframe
.skip423then
.skipL01731
.skipr1coll
 ; skipr1coll

.L01732 ;  if monster2type = 255 then goto skipr2coll

	LDA monster2type
	CMP #255
     BNE .skipL01732
.condpart425
 jmp .skipr2coll

.skipL01732
.L01733 ;  if altframe = 1  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  monster2x , monster2y ,  8 , 16 )  then playsfx sfx_deathsound : playerdeathflag = 1 : gosub monster2respawn : deathframe = 0

	LDA altframe
	CMP #1
     BNE .skipL01733
.condpart426
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda monster2x
    sta temp5
    lda monster2y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip426then
.condpart427
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
 jsr .monster2respawn
	LDA #0
	STA deathframe
.skip426then
.skipL01733
.skipr2coll
 ; skipr2coll

.L01734 ;  if monster3type = 255 then goto skipr3coll

	LDA monster3type
	CMP #255
     BNE .skipL01734
.condpart428
 jmp .skipr3coll

.skipL01734
.L01735 ;  if altframe = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  monster3x , monster3y ,  8 , 16 )  then playsfx sfx_deathsound : playerdeathflag = 1 : gosub monster3respawn : deathframe = 0

	LDA altframe
	CMP #0
     BNE .skipL01735
.condpart429
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda monster3x
    sta temp5
    lda monster3y
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip429then
.condpart430
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
 jsr .monster3respawn
	LDA #0
	STA deathframe
.skip429then
.skipL01735
.skipr3coll
 ; skipr3coll

.L01736 ;  goto skipwizmodecollisions

 jmp .skipwizmodecollisions

.
 ; 

.skipregularenemycollisions
 ; skipregularenemycollisions

.L01737 ;  if wizmodeover > 0  ||  wizmode = 0 then goto skipwizmodecollisions

	LDA #0
	CMP wizmodeover
     BCS .skipL01737
.condpart431
 jmp .condpart432
.skipL01737
	LDA wizmode
	CMP #0
     BNE .skip107OR
.condpart432
 jmp .skipwizmodecollisions

.skip107OR
.L01738 ;  if invincible_on = 1  ||  godvalue = 2 then goto skipwizmodegod :  rem v174

	LDA invincible_on
	CMP #1
     BNE .skipL01738
.condpart433
 jmp .condpart434
.skipL01738
	LDA godvalue
	CMP #2
     BNE .skip108OR
.condpart434
 jmp .skipwizmodegod
.skip108OR
.
 ; 

.L01739 ;  rem ** Wizmode collisions

.
 ; 

.L01740 ;  rem ** collision: wizard with player

.L01741 ;  if wizwarpcountdown > 200 then goto skipmonsterfire

	LDA #200
	CMP wizwarpcountdown
     BCS .skipL01741
.condpart435
 jmp .skipmonsterfire

.skipL01741
.L01742 ;  if invincible_on = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  wizx , wizy ,  8 , 16 )  then playsfx sfx_deathsound : playerdeathflag = 1 : deathframe = 0 : wizmodeover = 1

	LDA invincible_on
	CMP #0
     BNE .skipL01742
.condpart436
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda wizx
    sta temp5
    lda wizy
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip436then
.condpart437
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
	LDA #0
	STA deathframe
	LDA #1
	STA wizmodeover
.skip436then
.skipL01742
.
 ; 

.L01743 ;  rem ** collision: player with wizard fire

.L01744 ;  if invincible_on = 0  &&  r1x_fire <> 200  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  r1x_fire , r1y_fire ,  4 , 2 )  then r1x_fire = 200 : playsfx sfx_deathsound : playerdeathflag = 1 : deathframe = 0 : wizmodeover = 1

	LDA invincible_on
	CMP #0
     BNE .skipL01744
.condpart438
	LDA r1x_fire
	CMP #200
     BEQ .skip438then
.condpart439
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda r1x_fire
    sta temp5
    lda r1y_fire
    sta temp6
    lda #4-1
    sta temp7
    lda #2-1
    sta temp8
   jsr boxcollision
   BCC .skip439then
.condpart440
	LDA #200
	STA r1x_fire
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
	LDA #0
	STA deathframe
	LDA #1
	STA wizmodeover
.skip439then
.skip438then
.skipL01744
.
 ; 

.skipwizmodegod
 ; skipwizmodegod

.
 ; 

.L01745 ;  rem ** added respawns for all monsters, bats, and the spider when you kill the wizard (v178)

.
 ; 

.L01746 ;  rem ** collision: player fire with wizard

.L01747 ;  rem v185 added gosub wizdeathspeak at the end of the next line

.L01748 ;  if boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  wizx , wizy ,  8 , 16 )  then xpos_fire = 200 : playsfx sfx_explode : wizdeathflag = 1 : fireheld = 1 : wizmodeover = 1 : score0 = score0 + 1200 : gosub wizdeathspeak

    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda wizx
    sta temp5
    lda wizy
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skipL01748
.condpart441
	LDA #200
	STA xpos_fire
    lda #<sfx_explode
    sta temp1
    lda #>sfx_explode
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA wizdeathflag
	STA fireheld
	STA wizmodeover
	SED
	CLC
	LDA score0+1
	ADC #$12
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
 jsr .wizdeathspeak

.skipL01748
.
 ; 

.L01749 ;  goto skipmonsterfire

 jmp .skipmonsterfire

.
 ; 

.skipwizmodecollisions
 ; skipwizmodecollisions

.
 ; 

.L01750 ;  rem ** Collision code for the player getting hit by enemy fire

.
 ; 

.L01751 ;  rem ** Don't let enemies shoot you after the game's over

.L01752 ;  if gameoverflag = 1 then goto skipmonsterfire

	LDA gameoverflag
	CMP #1
     BNE .skipL01752
.condpart442
 jmp .skipmonsterfire

.skipL01752
.
 ; 

.L01753 ;  rem ** don't let enemy arrows hit you inside the bunker

.L01754 ;  if bunkerbuster = 0  &&  p0_x > 78  &&  p0_x < 90  &&  p0_y > 62  &&  p0_y < 90 then goto skipmonsterfire

	LDA bunkerbuster
	CMP #0
     BNE .skipL01754
.condpart443
	LDA #78
	CMP p0_x
     BCS .skip443then
.condpart444
	LDA p0_x
	CMP #90
     BCS .skip444then
.condpart445
	LDA #62
	CMP p0_y
     BCS .skip445then
.condpart446
	LDA p0_y
	CMP #90
     BCS .skip446then
.condpart447
 jmp .skipmonsterfire

.skip446then
.skip445then
.skip444then
.skip443then
.skipL01754
.
 ; 

.L01755 ;  rem ** detect the end of the player death animation, reset death flag to off, reset to bunker location, set firing direction to up

.L01756 ;  if deathframe = 15  &&  playerdeathflag = 1 then gosub losealife : playerdeathflag = 0 : p0_x = 84 : p0_y = 68 : fire_dir_save = 1 : fire_dir = 1

	LDA deathframe
	CMP #15
     BNE .skipL01756
.condpart448
	LDA playerdeathflag
	CMP #1
     BNE .skip448then
.condpart449
 jsr .losealife
	LDA #0
	STA playerdeathflag
	LDA #84
	STA p0_x
	LDA #68
	STA p0_y
	LDA #1
	STA fire_dir_save
	STA fire_dir
.skip448then
.skipL01756
.
 ; 

.L01757 ;  rem ** if the player death animation is running, skip collision detection

.L01758 ;  if playerdeathflag = 1 then goto skipr3collb

	LDA playerdeathflag
	CMP #1
     BNE .skipL01758
.condpart450
 jmp .skipr3collb

.skipL01758
.
 ; 

.L01759 ;  rem ** Detect a collision between player and enemy arrow, play explosion sound, reset arrow offscreen, set player death flag to on

.L01760 ;  rem ** Will also skip collision if monster type is 255

.L01761 ;  if monster1type = 255 then goto skipr1collb

	LDA monster1type
	CMP #255
     BNE .skipL01761
.condpart451
 jmp .skipr1collb

.skipL01761
.L01762 ;  if r1x_fire <> 200  &&  altframe = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  r1x_fire , r1y_fire ,  2 , 2 )  then r1x_fire = 200 : playsfx sfx_deathsound : playerdeathflag = 1 : deathframe = 0

	LDA r1x_fire
	CMP #200
     BEQ .skipL01762
.condpart452
	LDA altframe
	CMP #0
     BNE .skip452then
.condpart453
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda r1x_fire
    sta temp5
    lda r1y_fire
    sta temp6
    lda #2-1
    sta temp7
    lda #2-1
    sta temp8
   jsr boxcollision
   BCC .skip453then
.condpart454
	LDA #200
	STA r1x_fire
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
	LDA #0
	STA deathframe
.skip453then
.skip452then
.skipL01762
.skipr1collb
 ; skipr1collb

.L01763 ;  rem v215

.L01764 ;  if monster2type = 255  ||  wizmode > 0 then goto skipr2collb

	LDA monster2type
	CMP #255
     BNE .skipL01764
.condpart455
 jmp .condpart456
.skipL01764
	LDA #0
	CMP wizmode
     BCS .skip119OR
.condpart456
 jmp .skipr2collb

.skip119OR
.L01765 ;  if r2x_fire <> 200  &&  altframe = 1  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  r2x_fire , r2y_fire ,  2 , 2 )  then r2x_fire = 200 : playsfx sfx_deathsound : playerdeathflag = 1 : deathframe = 0

	LDA r2x_fire
	CMP #200
     BEQ .skipL01765
.condpart457
	LDA altframe
	CMP #1
     BNE .skip457then
.condpart458
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda r2x_fire
    sta temp5
    lda r2y_fire
    sta temp6
    lda #2-1
    sta temp7
    lda #2-1
    sta temp8
   jsr boxcollision
   BCC .skip458then
.condpart459
	LDA #200
	STA r2x_fire
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
	LDA #0
	STA deathframe
.skip458then
.skip457then
.skipL01765
.skipr2collb
 ; skipr2collb

.L01766 ;  if monster3type = 255 then goto skipr3collb

	LDA monster3type
	CMP #255
     BNE .skipL01766
.condpart460
 jmp .skipr3collb

.skipL01766
.L01767 ;  if r3x_fire <> 200  &&  altframe = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  r3x_fire , r3y_fire ,  2 , 2 )  then r3x_fire = 200 : playsfx sfx_deathsound : playerdeathflag = 1 : deathframe = 0

	LDA r3x_fire
	CMP #200
     BEQ .skipL01767
.condpart461
	LDA altframe
	CMP #0
     BNE .skip461then
.condpart462
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda r3x_fire
    sta temp5
    lda r3y_fire
    sta temp6
    lda #2-1
    sta temp7
    lda #2-1
    sta temp8
   jsr boxcollision
   BCC .skip462then
.condpart463
	LDA #200
	STA r3x_fire
    lda #<sfx_deathsound
    sta temp1
    lda #>sfx_deathsound
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA playerdeathflag
	LDA #0
	STA deathframe
.skip462then
.skip461then
.skipL01767
.skipr3collb
 ; skipr3collb

.
 ; 

.skipmonsterfire
 ; skipmonsterfire

.
 ; 

.L01768 ;  rem ** monster shot blocking

.L01769 ;  rem ** if Monster type 3's (Skeleton Warrior) arrow hits the player's arrow, it stops it and they both disappear.

.L01770 ;  if levelvalue < 5 then goto skipblockfire

	LDA levelvalue
	CMP #5
     BCS .skipL01770
.condpart464
 jmp .skipblockfire

.skipL01770
.L01771 ;  if r3x_fire <> 200  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  r3x_fire , r3y_fire ,  4 , 4 )  then r3x_fire = 200 : xpos_fire = 200

	LDA r3x_fire
	CMP #200
     BEQ .skipL01771
.condpart465
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda r3x_fire
    sta temp5
    lda r3y_fire
    sta temp6
    lda #4-1
    sta temp7
    lda #4-1
    sta temp8
   jsr boxcollision
   BCC .skip465then
.condpart466
	LDA #200
	STA r3x_fire
	STA xpos_fire
.skip465then
.skipL01771
.skipblockfire
 ; skipblockfire

.
 ; 

.L01772 ;  rem ** if your skill<4 then you are not on the Expert skill level. Skip large arrows.

.L01773 ;  if skill < 4 then goto skiplargearrows

	LDA skill
	CMP #4
     BCS .skipL01773
.condpart467
 jmp .skiplargearrows

.skipL01773
.L01774 ;  if r1x_fire <> 200  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  r1x_fire , r1y_fire ,  4 , 4 )  then r1x_fire = 200 : xpos_fire = 200

	LDA r1x_fire
	CMP #200
     BEQ .skipL01774
.condpart468
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda r1x_fire
    sta temp5
    lda r1y_fire
    sta temp6
    lda #4-1
    sta temp7
    lda #4-1
    sta temp8
   jsr boxcollision
   BCC .skip468then
.condpart469
	LDA #200
	STA r1x_fire
	STA xpos_fire
.skip468then
.skipL01774
.L01775 ;  if r2x_fire <> 200  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  r2x_fire , r2y_fire ,  4 , 4 )  then r2x_fire = 200 : xpos_fire = 200

	LDA r2x_fire
	CMP #200
     BEQ .skipL01775
.condpart470
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda r2x_fire
    sta temp5
    lda r2y_fire
    sta temp6
    lda #4-1
    sta temp7
    lda #4-1
    sta temp8
   jsr boxcollision
   BCC .skip470then
.condpart471
	LDA #200
	STA r2x_fire
	STA xpos_fire
.skip470then
.skipL01775
.L01776 ;  if r3x_fire <> 200  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  r3x_fire , r3y_fire ,  4 , 4 )  then r3x_fire = 200 : xpos_fire = 200

	LDA r3x_fire
	CMP #200
     BEQ .skipL01776
.condpart472
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda r3x_fire
    sta temp5
    lda r3y_fire
    sta temp6
    lda #4-1
    sta temp7
    lda #4-1
    sta temp8
   jsr boxcollision
   BCC .skip472then
.condpart473
	LDA #200
	STA r3x_fire
	STA xpos_fire
.skip472then
.skipL01776
.skiplargearrows
 ; skiplargearrows

.
 ; 

.L01777 ;  rem ** Collision code for the player picking up the quiver to get more arrows

.L01778 ;  if quadframe = 2  &&  quiverx <> 200  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  quiverx , quivery ,  8 , 8 )  then arrowspeakflag = 0 : gosub grab_arrows : gosub pickupsound : gosub gotarrowsspeak

	LDA quadframe
	CMP #2
     BNE .skipL01778
.condpart474
	LDA quiverx
	CMP #200
     BEQ .skip474then
.condpart475
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda quiverx
    sta temp5
    lda quivery
    sta temp6
    lda #8-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skip475then
.condpart476
	LDA #0
	STA arrowspeakflag
 jsr .grab_arrows
 jsr .pickupsound
 jsr .gotarrowsspeak

.skip475then
.skip474then
.skipL01778
.
 ; 

.L01779 ;  rem ** Collision code for the player's arrows hitting the bats or the spider

.L01780 ;  if spiderdeathframe = 4  &&  spiderdeathflag = 1 then spiderdeathflag = 0 : xpos_fire = 200 : ypos_fire = 208 : gosub spiderrespawn

	LDA spiderdeathframe
	CMP #4
     BNE .skipL01780
.condpart477
	LDA spiderdeathflag
	CMP #1
     BNE .skip477then
.condpart478
	LDA #0
	STA spiderdeathflag
	LDA #200
	STA xpos_fire
	LDA #208
	STA ypos_fire
 jsr .spiderrespawn

.skip477then
.skipL01780
.L01781 ;  if bat1deathframe = 3  &&  bat1deathflag = 1 then bat1deathflag = 0 : xpos_fire = 200 : ypos_fire = 208 : gosub bat1respawn

	LDA bat1deathframe
	CMP #3
     BNE .skipL01781
.condpart479
	LDA bat1deathflag
	CMP #1
     BNE .skip479then
.condpart480
	LDA #0
	STA bat1deathflag
	LDA #200
	STA xpos_fire
	LDA #208
	STA ypos_fire
 jsr .bat1respawn

.skip479then
.skipL01781
.L01782 ;  if bat2deathframe = 3  &&  bat2deathflag = 1 then bat2deathflag = 0 : xpos_fire = 200 : ypos_fire = 208 : gosub bat2respawn

	LDA bat2deathframe
	CMP #3
     BNE .skipL01782
.condpart481
	LDA bat2deathflag
	CMP #1
     BNE .skip481then
.condpart482
	LDA #0
	STA bat2deathflag
	LDA #200
	STA xpos_fire
	LDA #208
	STA ypos_fire
 jsr .bat2respawn

.skip481then
.skipL01782
.
 ; 

.L01783 ;  rem ** Skip both bats on level 5, one bat on level 4

.L01784 ;  if wizmode > 0 then goto skipshootbats

	LDA #0
	CMP wizmode
     BCS .skipL01784
.condpart483
 jmp .skipshootbats

.skipL01784
.L01785 ;  if levelvalue = 5 then goto skip2bats

	LDA levelvalue
	CMP #5
     BNE .skipL01785
.condpart484
 jmp .skip2bats

.skipL01785
.L01786 ;  if levelvalue = 4 then goto skip1bat

	LDA levelvalue
	CMP #4
     BNE .skipL01786
.condpart485
 jmp .skip1bat

.skipL01786
.
 ; 

.L01787 ;  if boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  bat1x , bat1y ,  5 , 8 )  then slowdown_bat1 = 0 : bat1deathframe = 0 : bat1deathflag = 1 : score0 = score0 + 000300 : xpos_fire = 208 : ypos_fire = 208 : playsfx sfx_batdeath

    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda bat1x
    sta temp5
    lda bat1y
    sta temp6
    lda #5-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skipL01787
.condpart486
	LDA #0
	STA slowdown_bat1
	STA bat1deathframe
	LDA #1
	STA bat1deathflag
	SED
	CLC
	LDA score0+1
	ADC #$03
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
	LDA #208
	STA xpos_fire
	STA ypos_fire
    lda #<sfx_batdeath
    sta temp1
    lda #>sfx_batdeath
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01787
.skip1bat
 ; skip1bat

.L01788 ;  if boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  bat2x , bat2y ,  5 , 8 )  then slowdown_bat2 = 0 : bat2deathframe = 0 : bat2deathflag = 1 : score0 = score0 + 000300 : xpos_fire = 208 : ypos_fire = 208 : playsfx sfx_batdeath

    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda bat2x
    sta temp5
    lda bat2y
    sta temp6
    lda #5-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skipL01788
.condpart487
	LDA #0
	STA slowdown_bat2
	STA bat2deathframe
	LDA #1
	STA bat2deathflag
	SED
	CLC
	LDA score0+1
	ADC #$03
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
	LDA #208
	STA xpos_fire
	STA ypos_fire
    lda #<sfx_batdeath
    sta temp1
    lda #>sfx_batdeath
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skipL01788
.skip2bats
 ; skip2bats

.L01789 ;  if spiderdeathflag = 1 then goto skipshootbats  : rem (v174)

	LDA spiderdeathflag
	CMP #1
     BNE .skipL01789
.condpart488
 jmp .skipshootbats
.skipL01789
.L01790 ;  if altframe = 1  &&  boxcollision ( xpos_fire , ypos_fire ,  2 , 2 ,  spiderx , spidery ,  8 , 16 )  then slowdown_spider = 0 : spiderdeathframe = 0 : spiderdeathflag = 1 : score0 = score0 + 000200 : xpos_fire = 208 : ypos_fire = 208 : spiderwebcountdown = 0 : playsfx sfx_spiderdeath

	LDA altframe
	CMP #1
     BNE .skipL01790
.condpart489
    lda xpos_fire
    sta temp1
    lda ypos_fire
    sta temp2
    lda #2-1
    sta temp3
    lda #2-1
    sta temp4
    lda spiderx
    sta temp5
    lda spidery
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip489then
.condpart490
	LDA #0
	STA slowdown_spider
	STA spiderdeathframe
	LDA #1
	STA spiderdeathflag
	SED
	CLC
	LDA score0+1
	ADC #$02
	STA score0+1
	LDA score0
	ADC #$00
	STA score0
	CLD
	LDA #208
	STA xpos_fire
	STA ypos_fire
	LDA #0
	STA spiderwebcountdown
    lda #<sfx_spiderdeath
    sta temp1
    lda #>sfx_spiderdeath
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip489then
.skipL01790
.skipshootbats
 ; skipshootbats

.
 ; 

.L01791 ;  rem ** Collision code for the player running into the bat or spider and freezing

.
 ; 

.L01792 ;  rem ** you can't be frozen in god mode or while death animation is running

.L01793 ;  if godvalue = 2  || invincible_on = 1 then goto skipcoll

	LDA godvalue
	CMP #2
     BNE .skipL01793
.condpart491
 jmp .condpart492
.skipL01793
	LDA invincible_on
	CMP #1
     BNE .skip134OR
.condpart492
 jmp .skipcoll

.skip134OR
.L01794 ;  if playerdeathflag = 1 then goto skipcoll

	LDA playerdeathflag
	CMP #1
     BNE .skipL01794
.condpart493
 jmp .skipcoll

.skipL01794
.
 ; 

.L01795 ;  rem ** if wizard mode is active, skipp collision detection with bats & spiders.  They aren't on screen anyway.

.L01796 ;  if wizmode > 0 then goto skipcoll

	LDA #0
	CMP wizmode
     BCS .skipL01796
.condpart494
 jmp .skipcoll

.skipL01796
.
 ; 

.L01797 ;  rem ** if levelvalue is 5, skip collisions with both bats.  They aren't on the screen.

.L01798 ;  if levelvalue = 5 then goto skipbatcollision2

	LDA levelvalue
	CMP #5
     BNE .skipL01798
.condpart495
 jmp .skipbatcollision2

.skipL01798
.
 ; 

.L01799 ;  rem ** if the levelvalue is 4, skip collision with the first bat.  It isn't on the screen.

.L01800 ;  if levelvalue = 4 then goto skipbatcollision1

	LDA levelvalue
	CMP #4
     BNE .skipL01800
.condpart496
 jmp .skipbatcollision1

.skipL01800
.
 ; 

.L01801 ;  rem ** Collision detection with bats & spider

.L01802 ;  if altframe = 0  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  bat1x , bat1y ,  5 , 8 )  then gosub bat1respawn : freezecount = 0 : freezeflag = 1

	LDA altframe
	CMP #0
     BNE .skipL01802
.condpart497
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda bat1x
    sta temp5
    lda bat1y
    sta temp6
    lda #5-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skip497then
.condpart498
 jsr .bat1respawn
	LDA #0
	STA freezecount
	LDA #1
	STA freezeflag
.skip497then
.skipL01802
.skipbatcollision1
 ; skipbatcollision1

.L01803 ;  if altframe = 1  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  bat2x , bat2y ,  5 , 8 )  then gosub bat2respawn : freezecount = 0 : freezeflag = 1

	LDA altframe
	CMP #1
     BNE .skipL01803
.condpart499
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda bat2x
    sta temp5
    lda bat2y
    sta temp6
    lda #5-1
    sta temp7
    lda #8-1
    sta temp8
   jsr boxcollision
   BCC .skip499then
.condpart500
 jsr .bat2respawn
	LDA #0
	STA freezecount
	LDA #1
	STA freezeflag
.skip499then
.skipL01803
.skipbatcollision2
 ; skipbatcollision2

.L01804 ;  if altframe = 1  &&  boxcollision ( p0_x , p0_y ,  5 , 16 ,  spiderx , spidery ,  8 , 16 )  then gosub spiderhit : spiderx = 8 : spidery = 35 : freezecount = 0 : freezeflag = 1 : spiderwebcountdown = 0

	LDA altframe
	CMP #1
     BNE .skipL01804
.condpart501
    lda p0_x
    sta temp1
    lda p0_y
    sta temp2
    lda #5-1
    sta temp3
    lda #16-1
    sta temp4
    lda spiderx
    sta temp5
    lda spidery
    sta temp6
    lda #8-1
    sta temp7
    lda #16-1
    sta temp8
   jsr boxcollision
   BCC .skip501then
.condpart502
 jsr .spiderhit
	LDA #8
	STA spiderx
	LDA #35
	STA spidery
	LDA #0
	STA freezecount
	LDA #1
	STA freezeflag
	LDA #0
	STA spiderwebcountdown
.skip501then
.skipL01804
.skipcoll
 ; skipcoll

.
 ; 

.L01805 ;  rem ** finally done!  Jump back to the start of the main loop.

.L01806 ;  goto main

 jmp .main

.
 ; 

.L01807 ;  rem <---- End of main game loop ---->

.
 ; 

.pickupsound
 ; pickupsound

.L01808 ;  if wizmode = 0  ||  wizmode = 200 then playsfx sfx_pickup

	LDA wizmode
	CMP #0
     BNE .skipL01808
.condpart503
 jmp .condpart504
.skipL01808
	LDA wizmode
	CMP #200
     BNE .skip138OR
.condpart504
    lda #<sfx_pickup
    sta temp1
    lda #>sfx_pickup
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip138OR
.L01809 ;  return

  RTS
.spiderhit
 ; spiderhit

.
 ; 

.L01810 ;  rem ** the spider will steal an arrow if it hits you

.L01811 ;  if arrowcounter > 0 then arrowcounter = arrowcounter - 1

	LDA #0
	CMP arrowcounter
     BCS .skipL01811
.condpart505
	LDA arrowcounter
	SEC
	SBC #1
	STA arrowcounter
.skipL01811
.L01812 ;  return

  RTS
.
 ; 

.L01813 ;  rem ** Enemies will always respawn on the opposite side of the screen from you

.L01814 ;  rem ** this is to avoid an enemy respawning directly on top of your current location in the dungeon

.monster1respawn
 ; monster1respawn

.L01815 ;  if p0_x < 84 then monster1x = 150 : monster1y = 144

	LDA p0_x
	CMP #84
     BCS .skipL01815
.condpart506
	LDA #150
	STA monster1x
	LDA #144
	STA monster1y
.skipL01815
.L01816 ;  if p0_x > 83 then monster1x = 8 : monster1y = 144

	LDA #83
	CMP p0_x
     BCS .skipL01816
.condpart507
	LDA #8
	STA monster1x
	LDA #144
	STA monster1y
.skipL01816
.L01817 ;  r1hp = 1

	LDA #1
	STA r1hp
.L01818 ;  return

  RTS
.monster2respawn
 ; monster2respawn

.L01819 ;  if demomode = 1 then monster2x = 150 : monster2y = 140 : return

	LDA demomode
	CMP #1
     BNE .skipL01819
.condpart508
	LDA #150
	STA monster2x
	LDA #140
	STA monster2y
  RTS
.skipL01819
.L01820 ;  if p0_x < 84 then monster2x = 150 : monster2y = 140

	LDA p0_x
	CMP #84
     BCS .skipL01820
.condpart509
	LDA #150
	STA monster2x
	LDA #140
	STA monster2y
.skipL01820
.L01821 ;  if p0_x > 83 then monster2x = 12 : monster2y = 144

	LDA #83
	CMP p0_x
     BCS .skipL01821
.condpart510
	LDA #12
	STA monster2x
	LDA #144
	STA monster2y
.skipL01821
.L01822 ;  r2hp = 1

	LDA #1
	STA r2hp
.L01823 ;  return

  RTS
.monster3respawn
 ; monster3respawn

.L01824 ;  if p0_x < 84 then monster3x = 150 : monster3y = 136

	LDA p0_x
	CMP #84
     BCS .skipL01824
.condpart511
	LDA #150
	STA monster3x
	LDA #136
	STA monster3y
.skipL01824
.L01825 ;  if p0_x > 83 then monster3x = 16 : monster3y = 144

	LDA #83
	CMP p0_x
     BCS .skipL01825
.condpart512
	LDA #16
	STA monster3x
	LDA #144
	STA monster3y
.skipL01825
.L01826 ;  r3hp = 1

	LDA #1
	STA r3hp
.L01827 ;  return

  RTS
.
 ; 

.L01828 ;  rem ** Reduce Enemy hitpoints

.r1hit
 ; r1hit

.L01829 ;  if r1hp > 0 then r1hp = r1hp - 1

	LDA #0
	CMP r1hp
     BCS .skipL01829
.condpart513
	LDA r1hp
	SEC
	SBC #1
	STA r1hp
.skipL01829
.L01830 ;  if r1hp = 0 then monster1_shieldflag = 0 else monster1_shieldflag = 1

	LDA r1hp
	CMP #0
     BNE .skipL01830
.condpart514
	LDA #0
	STA monster1_shieldflag
 jmp .skipelse7
.skipL01830
	LDA #1
	STA monster1_shieldflag
.skipelse7
.L01831 ;  return

  RTS
.r2hit
 ; r2hit

.L01832 ;  if r2hp > 0 then r2hp = r2hp - 1

	LDA #0
	CMP r2hp
     BCS .skipL01832
.condpart515
	LDA r2hp
	SEC
	SBC #1
	STA r2hp
.skipL01832
.L01833 ;  if r2hp = 0 then monster2_shieldflag = 0 else monster2_shieldflag = 1

	LDA r2hp
	CMP #0
     BNE .skipL01833
.condpart516
	LDA #0
	STA monster2_shieldflag
 jmp .skipelse8
.skipL01833
	LDA #1
	STA monster2_shieldflag
.skipelse8
.L01834 ;  return

  RTS
.r3hit
 ; r3hit

.L01835 ;  if r3hp > 0 then r3hp = r3hp - 1

	LDA #0
	CMP r3hp
     BCS .skipL01835
.condpart517
	LDA r3hp
	SEC
	SBC #1
	STA r3hp
.skipL01835
.L01836 ;  if r3hp = 0 then monster3_shieldflag = 0 else monster3_shieldflag = 1

	LDA r3hp
	CMP #0
     BNE .skipL01836
.condpart518
	LDA #0
	STA monster3_shieldflag
 jmp .skipelse9
.skipL01836
	LDA #1
	STA monster3_shieldflag
.skipelse9
.L01837 ;  return

  RTS
.
 ; 

.doeachmonsterfiring
 ; doeachmonsterfiring

.
 ; 

.L01838 ;  rem ** rem conditions upon which we fire a new enemy arrow

.L01839 ;  if playerinvisibletime > 0 then goto skip_r1fire

	LDA #0
	CMP playerinvisibletime
     BCS .skipL01839
.condpart519
 jmp .skip_r1fire

.skipL01839
.L01840 ;  if enemy1deathflag[temploop] = 1 then goto skip_r1fire

	LDX temploop
	LDA enemy1deathflag,x
	CMP #1
     BNE .skipL01840
.condpart520
 jmp .skip_r1fire

.skipL01840
.
 ; 

.dowizfiring
 ; dowizfiring

.
 ; 

.L01841 ;  rem ** Enemy arrow is in-use. Skip shooting.

.L01842 ;  if r1x_fire[temploop] <> 200 then goto skip_r1fire

	LDX temploop
	LDA r1x_fire,x
	CMP #200
     BEQ .skipL01842
.condpart521
 jmp .skip_r1fire

.skipL01842
.
 ; 

.L01843 ;  rem ** determine if the player is "close" to the enemy vertically

.L01844 ;  temp2 = p0_y - 15  :  rem ** the minimum y

	LDA p0_y
	SEC
	SBC #15
	STA temp2
.L01845 ;  temp3 = p0_y + 32  :  rem ** the maximum y

	LDA p0_y
	CLC
	ADC #32
	STA temp3
.L01846 ;  if tempy < temp2  ||  tempy > temp3 then goto skiphorizontalmonstshot

	LDA tempy
	CMP temp2
     BCS .skipL01846
.condpart522
 jmp .condpart523
.skipL01846
	LDA temp3
	CMP tempy
     BCS .skip139OR
.condpart523
 jmp .skiphorizontalmonstshot

.skip139OR
.L01847 ;  if tempx < p0_x then r1_fire_dir[temploop] = 3 else r1_fire_dir[temploop] = 1

	LDA tempx
	CMP p0_x
     BCS .skipL01847
.condpart524
	LDA #3
	LDX temploop
	STA r1_fire_dir,x
 jmp .skipelse10
.skipL01847
	LDA #1
	LDX temploop
	STA r1_fire_dir,x
.skipelse10
.L01848 ;  goto monstshotdone

 jmp .monstshotdone

.
 ; 

.skiphorizontalmonstshot
 ; skiphorizontalmonstshot

.L01849 ;  rem ** determine if the player is "close" to the enemy horizontally

.L01850 ;  temp2 = p0_x - 8  :  rem ** the minimum x

	LDA p0_x
	SEC
	SBC #8
	STA temp2
.L01851 ;  temp3 = p0_x + 16  :  rem ** the maximum x

	LDA p0_x
	CLC
	ADC #16
	STA temp3
.L01852 ;  if tempx < temp2  ||  tempx > temp3 then goto skip_r1fire

	LDA tempx
	CMP temp2
     BCS .skipL01852
.condpart525
 jmp .condpart526
.skipL01852
	LDA temp3
	CMP tempx
     BCS .skip140OR
.condpart526
 jmp .skip_r1fire

.skip140OR
.L01853 ;  if tempy < p0_y then r1_fire_dir[temploop] = 2 else r1_fire_dir[temploop] = 0

	LDA tempy
	CMP p0_y
     BCS .skipL01853
.condpart527
	LDA #2
	LDX temploop
	STA r1_fire_dir,x
 jmp .skipelse11
.skipL01853
	LDA #0
	LDX temploop
	STA r1_fire_dir,x
.skipelse11
.monstshotdone
 ; monstshotdone

.L01854 ;  r1x_fire[temploop] = monster1x[temploop] + 4 :  r1y_fire[temploop] = monster1y[temploop] + 8

	LDX temploop
	LDA monster1x,x
	CLC
	ADC #4
	LDX temploop
	STA r1x_fire,x
	LDX temploop
	LDA monster1y,x
	CLC
	ADC #8
	LDX temploop
	STA r1y_fire,x
.L01855 ;  newfire1[temploop] = 1

	LDA #1
	LDX temploop
	STA newfire1,x
.
 ; 

.skip_r1fire
 ; skip_r1fire

.
 ; 

.L01856 ;  reloop = 0

	LDA #0
	STA reloop
.doreloop
 ; doreloop

.L01857 ;  rem ** play the enemy arrow firing sound

.
 ; 

.L01858 ;  rem ** if arrow is in flight, move it

.L01859 ;  temp1 = 1

	LDA #1
	STA temp1
.L01860 ;  temp2 = framecounter & 1

	LDA framecounter
	AND #1
	STA temp2
.L01861 ;  if wizmode = 200  &&  temp2 = 1  &&  levelvalue = 3 then temp1 = 2

	LDA wizmode
	CMP #200
     BNE .skipL01861
.condpart528
	LDA temp2
	CMP #1
     BNE .skip528then
.condpart529
	LDA levelvalue
	CMP #3
     BNE .skip529then
.condpart530
	LDA #2
	STA temp1
.skip529then
.skip528then
.skipL01861
.L01862 ;  if wizmode = 200  &&  levelvalue > 3 then temp1 = 2

	LDA wizmode
	CMP #200
     BNE .skipL01862
.condpart531
	LDA #3
	CMP levelvalue
     BCS .skip531then
.condpart532
	LDA #2
	STA temp1
.skip531then
.skipL01862
.L01863 ;  if r1_fire_dir[temploop] = 0 then r1y_fire[temploop] = r1y_fire[temploop] - temp1 : goto monsterquivermovedone

	LDX temploop
	LDA r1_fire_dir,x
	CMP #0
     BNE .skipL01863
.condpart533
	LDX temploop
	LDA r1y_fire,x
	SEC
	SBC temp1
	LDX temploop
	STA r1y_fire,x
 jmp .monsterquivermovedone

.skipL01863
.L01864 ;  if r1_fire_dir[temploop] = 1 then r1x_fire[temploop] = r1x_fire[temploop] - temp1 : goto monsterquivermovedone

	LDX temploop
	LDA r1_fire_dir,x
	CMP #1
     BNE .skipL01864
.condpart534
	LDX temploop
	LDA r1x_fire,x
	SEC
	SBC temp1
	LDX temploop
	STA r1x_fire,x
 jmp .monsterquivermovedone

.skipL01864
.L01865 ;  if r1_fire_dir[temploop] = 2 then r1y_fire[temploop] = r1y_fire[temploop] + temp1 : goto monsterquivermovedone

	LDX temploop
	LDA r1_fire_dir,x
	CMP #2
     BNE .skipL01865
.condpart535
	LDX temploop
	LDA r1y_fire,x
	CLC
	ADC temp1
	LDX temploop
	STA r1y_fire,x
 jmp .monsterquivermovedone

.skipL01865
.L01866 ;  if r1_fire_dir[temploop] = 3 then r1x_fire[temploop] = r1x_fire[temploop] + temp1

	LDX temploop
	LDA r1_fire_dir,x
	CMP #3
     BNE .skipL01866
.condpart536
	LDX temploop
	LDA r1x_fire,x
	CLC
	ADC temp1
	LDX temploop
	STA r1x_fire,x
.skipL01866
.monsterquivermovedone
 ; monsterquivermovedone

.L01867 ;  rem if frame&1 && reloop<>1 then reloop=1:goto doreloop: rem speed it up

.
 ; 

.L01868 ;  if newfire1[temploop] > 0 then newfire1[temploop] = newfire1[temploop] + 1

	LDA #0
	LDX temploop
	CMP newfire1,x
     BCS .skipL01868
.condpart537
	LDX temploop
	LDA newfire1,x
	CLC
	ADC #1
	LDX temploop
	STA newfire1,x
.skipL01868
.
 ; 

.L01869 ;  rem ** stop the arrow if it hits the screen edges

.L01870 ;  if r1x_fire[temploop] > 158 then r1x_fire[temploop] = 200

	LDA #158
	LDX temploop
	CMP r1x_fire,x
     BCS .skipL01870
.condpart538
	LDA #200
	LDX temploop
	STA r1x_fire,x
.skipL01870
.L01871 ;  if r1x_fire[temploop] < 2 then r1x_fire[temploop] = 200

	LDX temploop
	LDA r1x_fire,x
	CMP #2
     BCS .skipL01871
.condpart539
	LDA #200
	LDX temploop
	STA r1x_fire,x
.skipL01871
.L01872 ;  if r1y_fire[temploop] > 192 then r1x_fire[temploop] = 200

	LDA #192
	LDX temploop
	CMP r1y_fire,x
     BCS .skipL01872
.condpart540
	LDA #200
	LDX temploop
	STA r1x_fire,x
.skipL01872
.L01873 ;  if r1y_fire[temploop] < 2 then r1x_fire[temploop] = 200

	LDX temploop
	LDA r1y_fire,x
	CMP #2
     BCS .skipL01873
.condpart541
	LDA #200
	LDX temploop
	STA r1x_fire,x
.skipL01873
.
 ; 

.L01874 ;  rem if wizmode=200 && levelvalue>2 then goto skipwallcollision

.L01875 ;  rem ** stop the arrow if it's not over a blank space...

.L01876 ;  r1x_temp0 = r1x_fire[temploop] / 4

	LDX temploop
	LDA r1x_fire,x
	lsr
	lsr
	STA r1x_temp0
.L01877 ;  r1y_temp0 = r1y_fire[temploop] / 8

	LDX temploop
	LDA r1y_fire,x
	lsr
	lsr
	lsr
	STA r1y_temp0
.L01878 ;  r1_tempchar0 = peekchar ( screenram , r1x_temp0 , r1y_temp0 , 40 , 28 ) 

    ldy r1y_temp0
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy r1x_temp0
    lda (temp1),y
	STA r1_tempchar0
.L01879 ;  if r1_tempchar0 >= spw1  &&  r1_tempchar0 <= spw4 then r1_tempchar0 = $41

	LDA r1_tempchar0
	CMP #spw1
     BCC .skipL01879
.condpart542
	LDA #spw4
	CMP r1_tempchar0
     BCC .skip542then
.condpart543
	LDA #$41
	STA r1_tempchar0
.skip542then
.skipL01879
.L01880 ;  if r1_tempchar0 >= spw1  &&  r1_tempchar0 <= spw4 then r1_tempchar0 = $41

	LDA r1_tempchar0
	CMP #spw1
     BCC .skipL01880
.condpart544
	LDA #spw4
	CMP r1_tempchar0
     BCC .skip544then
.condpart545
	LDA #$41
	STA r1_tempchar0
.skip544then
.skipL01880
.L01881 ;  if r1_tempchar0 <> $41 then r1x_fire[temploop] = 200

	LDA r1_tempchar0
	CMP #$41
     BEQ .skipL01881
.condpart546
	LDA #200
	LDX temploop
	STA r1x_fire,x
.skipL01881
.
 ; 

.skipwallcollision
 ; skipwallcollision

.
 ; 

.L01882 ;  if r1x_fire[temploop] = 200 then newfire1[temploop] = 0

	LDX temploop
	LDA r1x_fire,x
	CMP #200
     BNE .skipL01882
.condpart547
	LDA #0
	LDX temploop
	STA newfire1,x
.skipL01882
.
 ; 

.L01883 ;  if r1_fire_dir[temploop] = 0  ||  r1_fire_dir[temploop] = 2 then temp1 = 10 else temp1 = 6

	LDX temploop
	LDA r1_fire_dir,x
	CMP #0
     BNE .skipL01883
.condpart548
 jmp .condpart549
.skipL01883
	LDX temploop
	LDA r1_fire_dir,x
	CMP #2
     BNE .skip146OR
.condpart549
	LDA #10
	STA temp1
 jmp .skipelse12
.skip146OR
	LDA #6
	STA temp1
.skipelse12
.
 ; 

.L01884 ;  if newfire1[temploop] <> temp1 then skip_r1fire2

	LDX temploop
	LDA newfire1,x
	CMP temp1
 if ((* - .skip_r1fire2) < 127) && ((* - .skip_r1fire2) > -128)
	BNE .skip_r1fire2
 else
	beq .13skipskip_r1fire2
	jmp .skip_r1fire2
.13skipskip_r1fire2
 endif
.L01885 ;  newfire1[temploop] = 0

	LDA #0
	LDX temploop
	STA newfire1,x
.L01886 ;  rem if demomode=1 then skip_r1fire2

.L01887 ;  if wizmode = 0  ||  wizmode = 200 then playsfx sfx_enemy_shoot

	LDA wizmode
	CMP #0
     BNE .skipL01887
.condpart550
 jmp .condpart551
.skipL01887
	LDA wizmode
	CMP #200
     BNE .skip147OR
.condpart551
    lda #<sfx_enemy_shoot
    sta temp1
    lda #>sfx_enemy_shoot
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
.skip147OR
.
 ; 

.skip_r1fire2
 ; skip_r1fire2

.
 ; 

.L01888 ;  rem <---- End arrow firing code for Enemies ---->

.
 ; 

.L01889 ;  return

  RTS
.
 ; 

.displaymonstersprite
 ; displaymonstersprite

.
 ; 

.L01890 ;  rem ** Animation Frames for Enemies

.L01891 ;  rem ** Two 8x8 sprites stitched together top/bottom

.
 ; 

.L01892 ;  tempx = monster1x[temploop]

	LDX temploop
	LDA monster1x,x
	STA tempx
.L01893 ;  temptype = monster1type[temploop]

	LDX temploop
	LDA monster1type,x
	STA temptype
.L01894 ;  if tempx = 200  ||  temptype = 255 then a = a : return  :  rem a=a to workaround a 7800basic bug. to-be-fixed soon.

	LDA tempx
	CMP #200
     BNE .skipL01894
.condpart552
 jmp .condpart553
.skipL01894
	LDA temptype
	CMP #255
     BNE .skip148OR
.condpart553
	LDA a
	STA a
  RTS
.skip148OR
.L01895 ;  tempy = monster1y[temploop]

	LDX temploop
	LDA monster1y,x
	STA tempy
.
 ; 

.L01896 ;  if enemy1deathflag[temploop] = 1 then goto explodemonster

	LDX temploop
	LDA enemy1deathflag,x
	CMP #1
     BNE .skipL01896
.condpart554
 jmp .explodemonster

.skipL01896
.
 ; 

.L01897 ;  if wizmode > 0 then goto skipmonsterdisplay

	LDA #0
	CMP wizmode
     BCS .skipL01897
.condpart555
 jmp .skipmonsterdisplay

.skipL01897
.L01898 ;  tempanim = monster1animationframe[temploop]

	LDX temploop
	LDA monster1animationframe,x
	STA tempanim
.
 ; 

.L01899 ;  if temptype = 1 then goto displaymonster1

	LDA temptype
	CMP #1
     BNE .skipL01899
.condpart556
 jmp .displaymonster1

.skipL01899
.L01900 ;  if temptype = 3 then goto displaymonster3

	LDA temptype
	CMP #3
     BNE .skipL01900
.condpart557
 jmp .displaymonster3

.skipL01900
.L01901 ;  if temptype = 5 then goto displaymonster5

	LDA temptype
	CMP #5
     BNE .skipL01901
.condpart558
 jmp .displaymonster5

.skipL01901
.skipmonsterdisplay
 ; skipmonsterdisplay

.L01902 ;  return

  RTS
.
 ; 

.L01903 ;  rem ** Plot the monster sprites on the screen

.L01904 ;  rem ** The color of the sprite depends on the hitpoints of the enemy.

.
 ; 

.L01905 ;  rem ** Enemy type 1...Demon Bat

.displaymonster1
 ; displaymonster1

.L01906 ;  if monster1_shieldflag = 0 then plotsprite monster1top 1 tempx tempy tempanim

	LDA monster1_shieldflag
	CMP #0
     BNE .skipL01906
.condpart559
    lda #<monster1top
    ldy tempanim
      clc
      beq plotspritewidthskip28
plotspritewidthloop28
      adc #monster1top_width
      dey
      bne plotspritewidthloop28
plotspritewidthskip28
    sta temp1

    lda #>monster1top
    sta temp2

    lda #(32|monster1top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster1top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01906
.L01907 ;  if monster1_shieldflag = 1 then plotsprite monster1top 6 tempx tempy tempanim

	LDA monster1_shieldflag
	CMP #1
     BNE .skipL01907
.condpart560
    lda #<monster1top
    ldy tempanim
      clc
      beq plotspritewidthskip29
plotspritewidthloop29
      adc #monster1top_width
      dey
      bne plotspritewidthloop29
plotspritewidthskip29
    sta temp1

    lda #>monster1top
    sta temp2

    lda #(192|monster1top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster1top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01907
.L01908 ;  tempy = tempy + 8

	LDA tempy
	CLC
	ADC #8
	STA tempy
.L01909 ;  if monster1_shieldflag = 0 then plotsprite monster1bottom 1 tempx tempy tempanim

	LDA monster1_shieldflag
	CMP #0
     BNE .skipL01909
.condpart561
    lda #<monster1bottom
    ldy tempanim
      clc
      beq plotspritewidthskip30
plotspritewidthloop30
      adc #monster1bottom_width
      dey
      bne plotspritewidthloop30
plotspritewidthskip30
    sta temp1

    lda #>monster1bottom
    sta temp2

    lda #(32|monster1bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster1bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01909
.L01910 ;  if monster1_shieldflag = 1 then plotsprite monster1bottom 6 tempx tempy tempanim

	LDA monster1_shieldflag
	CMP #1
     BNE .skipL01910
.condpart562
    lda #<monster1bottom
    ldy tempanim
      clc
      beq plotspritewidthskip31
plotspritewidthloop31
      adc #monster1bottom_width
      dey
      bne plotspritewidthloop31
plotspritewidthskip31
    sta temp1

    lda #>monster1bottom
    sta temp2

    lda #(192|monster1bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster1bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01910
.L01911 ;  return

  RTS
.
 ; 

.L01912 ;  rem ** Enemy type 3...Snake

.displaymonster3
 ; displaymonster3

.L01913 ;  if monster2_shieldflag = 0 then plotsprite monster3top 1 tempx tempy tempanim

	LDA monster2_shieldflag
	CMP #0
     BNE .skipL01913
.condpart563
    lda #<monster3top
    ldy tempanim
      clc
      beq plotspritewidthskip32
plotspritewidthloop32
      adc #monster3top_width
      dey
      bne plotspritewidthloop32
plotspritewidthskip32
    sta temp1

    lda #>monster3top
    sta temp2

    lda #(32|monster3top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster3top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01913
.L01914 ;  if monster2_shieldflag = 1 then plotsprite monster3top 3 tempx tempy tempanim

	LDA monster2_shieldflag
	CMP #1
     BNE .skipL01914
.condpart564
    lda #<monster3top
    ldy tempanim
      clc
      beq plotspritewidthskip33
plotspritewidthloop33
      adc #monster3top_width
      dey
      bne plotspritewidthloop33
plotspritewidthskip33
    sta temp1

    lda #>monster3top
    sta temp2

    lda #(96|monster3top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster3top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01914
.L01915 ;  tempy = tempy + 8

	LDA tempy
	CLC
	ADC #8
	STA tempy
.L01916 ;  if monster2_shieldflag = 0 then plotsprite monster3bottom 1 tempx tempy tempanim

	LDA monster2_shieldflag
	CMP #0
     BNE .skipL01916
.condpart565
    lda #<monster3bottom
    ldy tempanim
      clc
      beq plotspritewidthskip34
plotspritewidthloop34
      adc #monster3bottom_width
      dey
      bne plotspritewidthloop34
plotspritewidthskip34
    sta temp1

    lda #>monster3bottom
    sta temp2

    lda #(32|monster3bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster3bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01916
.L01917 ;  if monster2_shieldflag = 1 then plotsprite monster3bottom 3 tempx tempy tempanim

	LDA monster2_shieldflag
	CMP #1
     BNE .skipL01917
.condpart566
    lda #<monster3bottom
    ldy tempanim
      clc
      beq plotspritewidthskip35
plotspritewidthloop35
      adc #monster3bottom_width
      dey
      bne plotspritewidthloop35
plotspritewidthskip35
    sta temp1

    lda #>monster3bottom
    sta temp2

    lda #(96|monster3bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster3bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01917
.L01918 ;  return

  RTS
.
 ; 

.L01919 ;  rem ** Enemy type 5...Skeleton Warrior

.displaymonster5
 ; displaymonster5

.L01920 ;  if monster3_shieldflag = 0 then plotsprite monster5top 1 tempx tempy tempanim

	LDA monster3_shieldflag
	CMP #0
     BNE .skipL01920
.condpart567
    lda #<monster5top
    ldy tempanim
      clc
      beq plotspritewidthskip36
plotspritewidthloop36
      adc #monster5top_width
      dey
      bne plotspritewidthloop36
plotspritewidthskip36
    sta temp1

    lda #>monster5top
    sta temp2

    lda #(32|monster5top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster5top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01920
.L01921 ;  if monster3_shieldflag = 1 then plotsprite monster5top 5 tempx tempy tempanim

	LDA monster3_shieldflag
	CMP #1
     BNE .skipL01921
.condpart568
    lda #<monster5top
    ldy tempanim
      clc
      beq plotspritewidthskip37
plotspritewidthloop37
      adc #monster5top_width
      dey
      bne plotspritewidthloop37
plotspritewidthskip37
    sta temp1

    lda #>monster5top
    sta temp2

    lda #(160|monster5top_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster5top_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01921
.L01922 ;  tempy = tempy + 8

	LDA tempy
	CLC
	ADC #8
	STA tempy
.L01923 ;  if monster3_shieldflag = 0 then plotsprite monster5bottom 1 tempx tempy tempanim

	LDA monster3_shieldflag
	CMP #0
     BNE .skipL01923
.condpart569
    lda #<monster5bottom
    ldy tempanim
      clc
      beq plotspritewidthskip38
plotspritewidthloop38
      adc #monster5bottom_width
      dey
      bne plotspritewidthloop38
plotspritewidthskip38
    sta temp1

    lda #>monster5bottom
    sta temp2

    lda #(32|monster5bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster5bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01923
.L01924 ;  if monster3_shieldflag = 1 then plotsprite monster5bottom 5 tempx tempy tempanim

	LDA monster3_shieldflag
	CMP #1
     BNE .skipL01924
.condpart570
    lda #<monster5bottom
    ldy tempanim
      clc
      beq plotspritewidthskip39
plotspritewidthloop39
      adc #monster5bottom_width
      dey
      bne plotspritewidthloop39
plotspritewidthskip39
    sta temp1

    lda #>monster5bottom
    sta temp2

    lda #(160|monster5bottom_width_twoscompliment)
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(monster5bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.skipL01924
.L01925 ;  return

  RTS
.
 ; 

.explodemonster
 ; explodemonster

.L01926 ;  tempexplodeframe = explodeframe1[temploop]

	LDX temploop
	LDA explodeframe1,x
	STA tempexplodeframe
.L01927 ;  rem ** Animation Frames for Enemy Explosion

.L01928 ;  rem ** Two 8x8 sprites stitched together top/bottom

.explodesprites
 ; explodesprites

.L01929 ;  plotsprite explode1top explosioncolor tempx tempy tempexplodeframe

    lda #<explode1top
    ldy tempexplodeframe
      clc
      beq plotspritewidthskip40
plotspritewidthloop40
      adc #explode1top_width
      dey
      bne plotspritewidthloop40
plotspritewidthskip40
    sta temp1

    lda #>explode1top
    sta temp2

    lda explosioncolor
    asl
    asl
    asl
    asl
    asl
    ora #explode1top_width_twoscompliment
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(explode1top_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01930 ;  tempy = tempy + 8

	LDA tempy
	CLC
	ADC #8
	STA tempy
.L01931 ;  plotsprite explode1bottom explosioncolor tempx tempy tempexplodeframe

    lda #<explode1bottom
    ldy tempexplodeframe
      clc
      beq plotspritewidthskip41
plotspritewidthloop41
      adc #explode1bottom_width
      dey
      bne plotspritewidthloop41
plotspritewidthskip41
    sta temp1

    lda #>explode1bottom
    sta temp2

    lda explosioncolor
    asl
    asl
    asl
    asl
    asl
    ora #explode1bottom_width_twoscompliment
    sta temp3

    lda tempx
    sta temp4

    lda tempy
    sta temp5

    lda #(explode1bottom_mode|%01000000)
    sta temp6

 jsr plotsprite
.L01932 ;  return

  RTS
.
 ; 

.plotwizexplode
 ; plotwizexplode

.L01933 ;  tempexplodeframe = wizmodeover / 4

	LDA wizmodeover
	lsr
	lsr
	STA tempexplodeframe
.L01934 ;  if tempexplodeframe > 7 then return

	LDA #7
	CMP tempexplodeframe
     BCS .skipL01934
.condpart571
  RTS
.skipL01934
.L01935 ;  tempx = wizx

	LDA wizx
	STA tempx
.L01936 ;  tempy = wizy

	LDA wizy
	STA tempy
.L01937 ;  goto explodesprites

 jmp .explodesprites

.
 ; 

.L01938 ;  rem ** respawn bat 1 at one of 8 pre-determined locations in the dungeon.

.bat1respawn
 ; bat1respawn

.L01939 ;  bat1respawn  =   ( rand & 7 )   +  1

; complex statement detected
 jsr randomize
	AND #7
	CLC
	ADC #1
	STA bat1respawn
.L01940 ;  if bat1respawn = 1 then bat1x = 84 : bat1y = 20

	LDA bat1respawn
	CMP #1
     BNE .skipL01940
.condpart572
	LDA #84
	STA bat1x
	LDA #20
	STA bat1y
.skipL01940
.L01941 ;  if bat1respawn = 2 then bat1x = 54 : bat1y = 54

	LDA bat1respawn
	CMP #2
     BNE .skipL01941
.condpart573
	LDA #54
	STA bat1x
	STA bat1y
.skipL01941
.L01942 ;  if bat1respawn = 3 then bat1x = 84 : bat1y = 146

	LDA bat1respawn
	CMP #3
     BNE .skipL01942
.condpart574
	LDA #84
	STA bat1x
	LDA #146
	STA bat1y
.skipL01942
.L01943 ;  if bat1respawn = 4 then bat1x = 54 : bat1y = 176

	LDA bat1respawn
	CMP #4
     BNE .skipL01943
.condpart575
	LDA #54
	STA bat1x
	LDA #176
	STA bat1y
.skipL01943
.L01944 ;  if bat1respawn = 5 then bat1x = 150 : bat1y = 116

	LDA bat1respawn
	CMP #5
     BNE .skipL01944
.condpart576
	LDA #150
	STA bat1x
	LDA #116
	STA bat1y
.skipL01944
.L01945 ;  if bat1respawn = 6 then bat1x = 22 : bat1y = 146

	LDA bat1respawn
	CMP #6
     BNE .skipL01945
.condpart577
	LDA #22
	STA bat1x
	LDA #146
	STA bat1y
.skipL01945
.L01946 ;  if bat1respawn = 7 then bat1x = 120 : bat1y = 54

	LDA bat1respawn
	CMP #7
     BNE .skipL01946
.condpart578
	LDA #120
	STA bat1x
	LDA #54
	STA bat1y
.skipL01946
.L01947 ;  if bat1respawn = 8 then bat1x = 133 : bat1y = 20

	LDA bat1respawn
	CMP #8
     BNE .skipL01947
.condpart579
	LDA #133
	STA bat1x
	LDA #20
	STA bat1y
.skipL01947
.L01948 ;  if p0_x < 84  &&  bat1x < 84 then goto bat1respawn

	LDA p0_x
	CMP #84
     BCS .skipL01948
.condpart580
	LDA bat1x
	CMP #84
     BCS .skip580then
.condpart581
 jmp .bat1respawn

.skip580then
.skipL01948
.L01949 ;  if p0_x > 83  &&  bat1x > 83 then goto bat1respawn

	LDA #83
	CMP p0_x
     BCS .skipL01949
.condpart582
	LDA #83
	CMP bat1x
     BCS .skip582then
.condpart583
 jmp .bat1respawn

.skip582then
.skipL01949
.L01950 ;  return

  RTS
.
 ; 

.L01951 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L01952 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L01953 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L01954 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L01955 ;  rem ** so you'll have to experiment with their location in your own code.

.L01956 ;  dmahole 0

 jmp dmahole_0
gameend
 echo " ",[($8000 - gameend)]d , "bytes of ROM space left in the main area."

 ORG $8000  ; *************

tileset_NS_Maze1
       HEX fffffffe1c000018f01cf00f0ff0f00f
tileset_NS_Maze2
       HEX 8003f00ffffff81f00000000e00700ff
       HEX 
tileset_NS_Maze3
       HEX 0181ff0ff00000ff7fffff00ffff00ff
tileset_NS_Maze4
       HEX fffffffe00000000f01cf00f03e0e007
       HEX 
blanks
       HEX ff00
alphabet_8_wide
       HEX 000014141414141414501400140014141414014014141414140014051414
       HEX 141414001450141400140140141405501515141401401400014001400140
scoredigits_8_wide
       HEX 7e7e
       HEX 7e7e067e7e307e7e000000000000
godmode
       HEX ffff
miniwebtop
       HEX 41fa
miniwebbottom
       HEX 2040
aa_left_1
       HEX 060f8f83001800000000
aa_left_2
       HEX 30f8
       HEX 88f860c30c00cc0c
aa_left_3
       HEX 0e18f8c3800000000000
aa_left_4
       HEX 0003fe00000000000000
aa_right_1
       HEX 06000000
       HEX 0000000000
aa_right_2
       HEX 30c3019ff800000000
aa_right_3
       HEX 000003800000000000
aa_right_4
       HEX 000000000000000000

 ORG $8100  ; *************

;tileset_NS_Maze1
       HEX ffffffff3e68387cf03ef01f3ff8f81f
;tileset_NS_Maze2
       HEX c007f81ffffffe7f00000000e00700ff
       HEX 
;tileset_NS_Maze3
       HEX 83c1ff07e00000fe7f7ffe0000ff00ff
;tileset_NS_Maze4
       HEX ff7f7fff00003830f03ef00f07f0f00f
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000014141414141414141400140014141414014000141414140014051414
       HEX 141414001414141400140140141415541555055001401400000000000000
;scoredigits_8_wide
       HEX 7e7e
       HEX 7e7e067e7e307e7e667c3c787e60
;godmode
       HEX 8423
;miniwebtop
       HEX 4747
;miniwebbottom
       HEX 17f0
;aa_left_1
       HEX 0703fe07000000000000
;aa_left_2
       HEX 30f8
       HEX f8f860c30c30cf0c
;aa_left_3
       HEX 0c38f8e1800000000000
;aa_left_4
       HEX 001fffc0000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 30c1838c1800000000
;aa_right_3
       HEX 000001800000000000
;aa_right_4
       HEX 000000000000000000

 ORG $8200  ; *************

;tileset_NS_Maze1
       HEX ffffffff7f7c7cfcf07ef01f1ffcfc3f
;tileset_NS_Maze2
       HEX e00ffc3ffffffe7f80000000e00780e7
       HEX 
;tileset_NS_Maze3
       HEX cff3ff07e00000fc3f3ffc0100ff00ff
;tileset_NS_Maze4
       HEX ff7f7fff18187c7ce07ee00f0ff8f81f
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000015541414140014141400140014141414014000141450140014051454
       HEX 141414001414145000140140141414141445014005500500000001400140
;scoredigits_8_wide
       HEX 6618
       HEX 60060606663066066666666c6060
;godmode
       HEX b5ad
;miniwebtop
       HEX 4942
;miniwebbottom
       HEX 1849
;aa_left_1
       HEX 0380f80e000000000000
;aa_left_2
       HEX 38fc
       HEX 71f8e0e70c39cfcc
;aa_left_3
       HEX 1c3c71e1c381c71ecc0c
;aa_left_4
       HEX 007e03f0000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 39c1c78e3800000000
;aa_right_3
       HEX e0707983e000000000
;aa_right_4
       HEX 000000000000000000

 ORG $8300  ; *************

;tileset_NS_Maze1
       HEX ffffffff7ffefdfef0fff01f3ffcf87f
;tileset_NS_Maze2
       HEX f00ffe7fffffffffe0000000e007e0c3
       HEX 
;tileset_NS_Maze3
       HEX ffffff01800000f81f0ff80700ff00ff
;tileset_NS_Maze4
       HEX fe3f3ffe3c3c7c7ee0ffe0071ffcf83f
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000014141550140014141550155014541554014000141540140014451554
       HEX 141415501414155005500140141414141405014014140140000001400150
;scoredigits_8_wide
       HEX 6618
       HEX 7c3e7e7e7e387e7e666660666060
;godmode
       HEX a5ad
;miniwebtop
       HEX 3122
;miniwebbottom
       HEX 2886
;aa_left_1
       HEX 01c0001c000000000000
;aa_left_2
       HEX 187c
       HEX 71f0c0663f1f8dcc
;aa_left_3
       HEX 187c71f0c381cf3fcc0c
;aa_left_4
       HEX 00f00078000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 1980fd87f000000000
;aa_right_3
       HEX e070fd87f000000000
;aa_right_4
       HEX 000000000000000000

 ORG $8400  ; *************

;tileset_NS_Maze1
       HEX 7fdf9ffefffffffff0fff00f3ffcfc3f
;tileset_NS_Maze2
       HEX f01ffc7ffffffffff8ff0000e007f881
       HEX 
;tileset_NS_Maze3
       HEX ffffff00000180f81f07e00f0000ff7e
;tileset_NS_Maze4
       HEX 7e1f1ffc7e7efeffc0ffc0071ffcf83f
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000014141414140014141400140014001414014000141540140015551554
       HEX 141414141414141414000140141414141405055014140050000001400054
;scoredigits_8_wide
       HEX 6618
       HEX 1e3e7e7e7e1c7e7e7e7c60667c7c
;godmode
       HEX bdad
;miniwebtop
       HEX 6114
;miniwebbottom
       HEX 248c
;aa_left_1
       HEX 00f00078000000000000
;aa_left_2
       HEX 187e
       HEX 23f0c07e3f0f0ccc
;aa_left_3
       HEX 187e23f0c381cc31cc0c
;aa_left_4
       HEX 01c0001c000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 1f807983e000000000
;aa_right_3
       HEX e071c78e3800000000
;aa_right_4
       HEX 000000000000000000

 ORG $8500  ; *************

;tileset_NS_Maze1
       HEX 77df0ffcffffffffe0ffe00f3ff8f81f
;tileset_NS_Maze2
       HEX f01ffc3ffe7ffffffc0001e0e007fc00
       HEX 
;tileset_NS_Maze3
       HEX ffffe3000007e0fc3f01803f0000ff38
;tileset_NS_Maze4
       HEX 7c1e0ff8feffffffc0ffc0031ff8f01f
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000005501414141414501400140014001414014000141450140015151514
       HEX 141414141414141414000140141414141405141414140014000001400014
;scoredigits_8_wide
       HEX 6618
       HEX 06066660600e6666666660666060
;godmode
       HEX bdad
;miniwebtop
       HEX 9218
;miniwebbottom
       HEX 4292
;aa_left_1
       HEX 007c01f0000000000000
;aa_left_2
       HEX 1c3e
       HEX 23e1c03c0c000000
;aa_left_3
       HEX 38fe23f8e1ff8c30cc0c
;aa_left_4
       HEX 0380f80e000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 0f0000000000000000
;aa_right_3
       HEX 7fe1838c1800000000
;aa_right_4
       HEX 00007c000000000000

 ORG $8600  ; *************

;tileset_NS_Maze1
       HEX 338e03f0ffffffffe0ffc0071ff8e007
;tileset_NS_Maze2
       HEX f01ff81ffe7ffffffe0003f0e007fe00
       HEX 
;tileset_NS_Maze3
       HEX ffff81000007e0fe7f00007f0000ff00
;tileset_NS_Maze4
       HEX 380c03e0ffffffff80ff80010ff0e007
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000001401550055015401554155405541414155400141414140014051414
       HEX 055015500550155005501554141414141405141414141554000001400550
;scoredigits_8_wide
       HEX 7e38
       HEX 7e7e667e7e7e7e7e3c66666c6060
;godmode
       HEX 8423
;miniwebtop
       HEX 0fe8
;miniwebbottom
       HEX e2e2
;aa_left_1
       HEX 001fffc0000000000000
;aa_left_2
       HEX 0c3f
       HEX 07e1803c0c00000c
;aa_left_3
       HEX 30ff07f861ff8c1fcc0c
;aa_left_4
       HEX 0703fe07000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 0f0000000000000000
;aa_right_3
       HEX 7fe301980000000000
;aa_right_4
       HEX 0000fe000000000000

 ORG $8700  ; *************

;tileset_NS_Maze1
       HEX 000000c0ffffffffc0ff80030ff0f00f
;tileset_NS_Maze2
       HEX f00ff00ff81fffffff0007f0e007ff00
       HEX 
;tileset_NS_Maze3
       HEX ffff8100000ff0ffff0000ff0000ff00
;tileset_NS_Maze4
       HEX 100000c0ffffffff00ff000007e0c003
       HEX 
;blanks
       HEX ff00
;alphabet_8_wide
       HEX 000000000000000000000000000000000000000000000000000000000000
       HEX 000000000000000000000000000000000000000000000000000000000000
;scoredigits_8_wide
       HEX 7e38
       HEX 7e7e667e7e7e7e7e187c3c787e7e
;godmode
       HEX ffff
;miniwebtop
       HEX 0204
;miniwebbottom
       HEX 5f82
;aa_left_1
       HEX 0003fe00000000000000
;aa_left_2
       HEX 0e1f
       HEX 07c380180000000c
;aa_left_3
       HEX 30ff07f861c38c0ecc0c
;aa_left_4
       HEX 060fff83000000000000
;aa_right_1
       HEX 00000000
       HEX 0000000000
;aa_right_2
       HEX 060000000000000000
;aa_right_3
       HEX 70e3019ff800000000
;aa_right_4
       HEX 0001c7000000000000

 ORG $8800  ; *************
dmahole_0
.
 ; 

.L01957 ;  rem ** respawn bat 2 at one of 8 pre-determined locations in the dungeon.

.bat2respawn
 ; bat2respawn

.L01958 ;  bat2respawn  =   ( rand & 7 )   +  1

; complex statement detected
 jsr randomize
	AND #7
	CLC
	ADC #1
	STA bat2respawn
.L01959 ;  if bat2respawn = 8 then bat2x = 84 : bat2y = 20

	LDA bat2respawn
	CMP #8
     BNE .skipL01959
.condpart584
	LDA #84
	STA bat2x
	LDA #20
	STA bat2y
.skipL01959
.L01960 ;  if bat2respawn = 7 then bat2x = 54 : bat2y = 54

	LDA bat2respawn
	CMP #7
     BNE .skipL01960
.condpart585
	LDA #54
	STA bat2x
	STA bat2y
.skipL01960
.L01961 ;  if bat2respawn = 6 then bat2x = 84 : bat2y = 146

	LDA bat2respawn
	CMP #6
     BNE .skipL01961
.condpart586
	LDA #84
	STA bat2x
	LDA #146
	STA bat2y
.skipL01961
.L01962 ;  if bat2respawn = 5 then bat2x = 54 : bat2y = 176

	LDA bat2respawn
	CMP #5
     BNE .skipL01962
.condpart587
	LDA #54
	STA bat2x
	LDA #176
	STA bat2y
.skipL01962
.L01963 ;  if bat2respawn = 4 then bat2x = 150 : bat2y = 116

	LDA bat2respawn
	CMP #4
     BNE .skipL01963
.condpart588
	LDA #150
	STA bat2x
	LDA #116
	STA bat2y
.skipL01963
.L01964 ;  if bat2respawn = 3 then bat2x = 22 : bat2y = 146

	LDA bat2respawn
	CMP #3
     BNE .skipL01964
.condpart589
	LDA #22
	STA bat2x
	LDA #146
	STA bat2y
.skipL01964
.L01965 ;  if bat2respawn = 2 then bat2x = 120 : bat2y = 54

	LDA bat2respawn
	CMP #2
     BNE .skipL01965
.condpart590
	LDA #120
	STA bat2x
	LDA #54
	STA bat2y
.skipL01965
.L01966 ;  if bat2respawn = 1 then bat2x = 133 : bat2y = 20

	LDA bat2respawn
	CMP #1
     BNE .skipL01966
.condpart591
	LDA #133
	STA bat2x
	LDA #20
	STA bat2y
.skipL01966
.L01967 ;  if p0_x < 84  &&  bat2x < 84 then goto bat2respawn

	LDA p0_x
	CMP #84
     BCS .skipL01967
.condpart592
	LDA bat2x
	CMP #84
     BCS .skip592then
.condpart593
 jmp .bat2respawn

.skip592then
.skipL01967
.L01968 ;  if p0_x > 83  &&  bat2x > 83 then goto bat2respawn

	LDA #83
	CMP p0_x
     BCS .skipL01968
.condpart594
	LDA #83
	CMP bat2x
     BCS .skip594then
.condpart595
 jmp .bat2respawn

.skip594then
.skipL01968
.L01969 ;  return

  RTS
.
 ; 

.spiderrespawn
 ; spiderrespawn

.L01970 ;  rem ** duplicate entry for spider respawning in the web (2/8 chance)

.L01971 ;  spiderrespawn  =   ( rand & 7 )   +  1

; complex statement detected
 jsr randomize
	AND #7
	CLC
	ADC #1
	STA spiderrespawn
.L01972 ;  if spiderrespawn = 1 then spiderx = 6 : spidery = 22  : rem Keep

	LDA spiderrespawn
	CMP #1
     BNE .skipL01972
.condpart596
	LDA #6
	STA spiderx
	LDA #22
	STA spidery
.skipL01972
.L01973 ;  if spiderrespawn = 2 then spiderx = 6 : spidery = 148  : rem Keep

	LDA spiderrespawn
	CMP #2
     BNE .skipL01973
.condpart597
	LDA #6
	STA spiderx
	LDA #148
	STA spidery
.skipL01973
.L01974 ;  if spiderrespawn = 3 then spiderx = 120 : spidery = 148  : rem Keep

	LDA spiderrespawn
	CMP #3
     BNE .skipL01974
.condpart598
	LDA #120
	STA spiderx
	LDA #148
	STA spidery
.skipL01974
.L01975 ;  if spiderrespawn = 4 then spiderx = 134 : spidery = 20  : rem 150/60 removed

	LDA spiderrespawn
	CMP #4
     BNE .skipL01975
.condpart599
	LDA #134
	STA spiderx
	LDA #20
	STA spidery
.skipL01975
.L01976 ;  if spiderrespawn = 5 then spiderx = 120 : spidery = 116  : rem Keep

	LDA spiderrespawn
	CMP #5
     BNE .skipL01976
.condpart600
	LDA #120
	STA spiderx
	LDA #116
	STA spidery
.skipL01976
.L01977 ;  if spiderrespawn = 6 then spiderx = 134 : spidery = 176  : rem 132/82 removed

	LDA spiderrespawn
	CMP #6
     BNE .skipL01977
.condpart601
	LDA #134
	STA spiderx
	LDA #176
	STA spidery
.skipL01977
.L01978 ;  if spiderrespawn = 7 then spiderx = 22 : spidery = 176  : rem 22/84 removed

	LDA spiderrespawn
	CMP #7
     BNE .skipL01978
.condpart602
	LDA #22
	STA spiderx
	LDA #176
	STA spidery
.skipL01978
.L01979 ;  if spiderrespawn = 8 then spiderx = 38 : spidery = 20  : rem 6/22 removed

	LDA spiderrespawn
	CMP #8
     BNE .skipL01979
.condpart603
	LDA #38
	STA spiderx
	LDA #20
	STA spidery
.skipL01979
.L01980 ;  if p0_x < 84  &&  spiderx < 84 then goto spiderrespawn

	LDA p0_x
	CMP #84
     BCS .skipL01980
.condpart604
	LDA spiderx
	CMP #84
     BCS .skip604then
.condpart605
 jmp .spiderrespawn

.skip604then
.skipL01980
.L01981 ;  if p0_x > 83  &&  spiderx > 83 then goto spiderrespawn

	LDA #83
	CMP p0_x
     BCS .skipL01981
.condpart606
	LDA #83
	CMP spiderx
     BCS .skip606then
.condpart607
 jmp .spiderrespawn

.skip606then
.skipL01981
.L01982 ;  return

  RTS
.
 ; 

.L01983 ;  rem ** random amount of arrows you get when you pick up a quiver

.L01984 ;  rem ** it will be between 5 and 8 each time

.grab_arrows
 ; grab_arrows

.L01985 ;  arrowrand  =   ( rand & 7 )   +  1

; complex statement detected
 jsr randomize
	AND #7
	CLC
	ADC #1
	STA arrowrand
.L01986 ;  if arrowrand < 5 then goto grab_arrows

	LDA arrowrand
	CMP #5
     BCS .skipL01986
.condpart608
 jmp .grab_arrows

.skipL01986
.L01987 ;  arrowcounter = arrowrand

	LDA arrowrand
	STA arrowcounter
.
 ; 

.L01988 ;  rem ** for developer mode, make sure arrow count isn't higher than the maximum allowed

.checkmax
 ; checkmax

.L01989 ;  if arrowcounter > arrowsvalue then arrowcounter = arrowcounter - 1 : goto checkmax

	LDA arrowsvalue
	CMP arrowcounter
     BCS .skipL01989
.condpart609
	LDA arrowcounter
	SEC
	SBC #1
	STA arrowcounter
 jmp .checkmax

.skipL01989
.L01990 ;  return

  RTS
.
 ; 

.webflicker
 ; webflicker

.L01991 ;  if  ( frame & 7 )  > 0 then return

; complex condition detected
; complex statement detected
	LDA frame
	AND #7
  PHA
  TSX
  PLA
	LDA #0
	CMP  $101,x
     BCS .skipL01991
.condpart610
  RTS
.skipL01991
.L01992 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then tempchar1 = $41

	LDA tempchar1
	CMP #spw1
     BCC .skipL01992
.condpart611
	LDA #spw4
	CMP tempchar1
     BCC .skip611then
.condpart612
	LDA #$41
	STA tempchar1
.skip611then
.skipL01992
.L01993 ;  if tempchar2 >= spw1  &&  tempchar2 <= spw4 then tempchar2 = $41

	LDA tempchar2
	CMP #spw1
     BCC .skipL01993
.condpart613
	LDA #spw4
	CMP tempchar2
     BCC .skip613then
.condpart614
	LDA #$41
	STA tempchar2
.skip613then
.skipL01993
.L01994 ;  return

  RTS
.
 ; 

.L01995 ;  rem ** Movement Check Routines

.
 ; 

.L01996 ;  rem ** Note:

.L01997 ;  rem      -The peekchar command is used to look up what value character is at a particular character position in a character map.

.
 ; 

.checkmovedown
 ; checkmovedown

.L01998 ;  if p0_y > 174 then p0_dy = 0 : return

	LDA #174
	CMP p0_y
     BCS .skipL01998
.condpart615
	LDA #0
	STA p0_dy
  RTS
.skipL01998
.L01999 ;  temp0_x = p0_x / 4

	LDA p0_x
	lsr
	lsr
	STA temp0_x
.L02000 ;  temp0_y =  ( p0_y + 15 )  / 8

; complex statement detected
	LDA p0_y
	CLC
	ADC #15
	lsr
	lsr
	lsr
	STA temp0_y
.L02001 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02002 ;  temp0_x =  ( p0_x + 3 )  / 4

; complex statement detected
	LDA p0_x
	CLC
	ADC #3
	lsr
	lsr
	STA temp0_x
.L02003 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.L02004 ;  gosub webflicker

 jsr .webflicker

.L02005 ;  if tempchar1 = $41  &&  tempchar2 = $41 then p0_dy = 1 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02005
.condpart616
	LDA tempchar2
	CMP #$41
     BNE .skip616then
.condpart617
	LDA #1
	STA p0_dy
  RTS
.skip616then
.skipL02005
.L02006 ;  rem ** the next two lines make the player slide around obstacles 

.L02007 ;  if tempchar1 >= spw1  ||  tempchar2 >= spw1 then return

	LDA tempchar1
	CMP #spw1
     BCC .skipL02007
.condpart618
 jmp .condpart619
.skipL02007
	LDA tempchar2
	CMP #spw1
     BCC .skip158OR
.condpart619
  RTS
.skip158OR
.
 ; 

.L02008 ;  if tempchar1 = $41 then p0_dx = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02008
.condpart620
	LDA #255
	STA p0_dx
  RTS
.skipL02008
.L02009 ;  if tempchar2 = $41 then p0_dx = 1 : return

	LDA tempchar2
	CMP #$41
     BNE .skipL02009
.condpart621
	LDA #1
	STA p0_dx
  RTS
.skipL02009
.L02010 ;  return

  RTS
.
 ; 

.checkmoveup
 ; checkmoveup

.L02011 ;  if p0_y < 8 then p0_dy = 0 : return

	LDA p0_y
	CMP #8
     BCS .skipL02011
.condpart622
	LDA #0
	STA p0_dy
  RTS
.skipL02011
.L02012 ;  temp0_x = p0_x / 4

	LDA p0_x
	lsr
	lsr
	STA temp0_x
.L02013 ;  temp0_y = p0_y / 8

	LDA p0_y
	lsr
	lsr
	lsr
	STA temp0_y
.L02014 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02015 ;  temp0_x =  ( p0_x + 3 )  / 4

; complex statement detected
	LDA p0_x
	CLC
	ADC #3
	lsr
	lsr
	STA temp0_x
.L02016 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.L02017 ;  gosub webflicker

 jsr .webflicker

.L02018 ;  if tempchar1 = $41  &&  tempchar2 = $41 then p0_dy = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02018
.condpart623
	LDA tempchar2
	CMP #$41
     BNE .skip623then
.condpart624
	LDA #255
	STA p0_dy
  RTS
.skip623then
.skipL02018
.L02019 ;  if tempchar1 >= spw1  ||  tempchar2 >= spw1 then return

	LDA tempchar1
	CMP #spw1
     BCC .skipL02019
.condpart625
 jmp .condpart626
.skipL02019
	LDA tempchar2
	CMP #spw1
     BCC .skip160OR
.condpart626
  RTS
.skip160OR
.L02020 ;  rem ** the next two lines make the player slide around obstacles 

.L02021 ;  if tempchar1 = $41 then p0_dx = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02021
.condpart627
	LDA #255
	STA p0_dx
  RTS
.skipL02021
.L02022 ;  if tempchar2 = $41 then p0_dx = 1 : return

	LDA tempchar2
	CMP #$41
     BNE .skipL02022
.condpart628
	LDA #1
	STA p0_dx
  RTS
.skipL02022
.L02023 ;  return

  RTS
.
 ; 

.checkmoveleft
 ; checkmoveleft

.L02024 ;  if p0_x < 4 then p0_dx = 0 : return

	LDA p0_x
	CMP #4
     BCS .skipL02024
.condpart629
	LDA #0
	STA p0_dx
  RTS
.skipL02024
.L02025 ;  temp0_x =  ( p0_x - 1 )  / 4

; complex statement detected
	LDA p0_x
	SEC
	SBC #1
	lsr
	lsr
	STA temp0_x
.L02026 ;  temp0_y =  ( p0_y + 1 )  / 8

; complex statement detected
	LDA p0_y
	CLC
	ADC #1
	lsr
	lsr
	lsr
	STA temp0_y
.L02027 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02028 ;  temp0_y =  ( p0_y + 14 )  / 8

; complex statement detected
	LDA p0_y
	CLC
	ADC #14
	lsr
	lsr
	lsr
	STA temp0_y
.L02029 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.L02030 ;  gosub webflicker

 jsr .webflicker

.L02031 ;  if tempchar1 = $41  &&  tempchar2 = $41 then p0_dx = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02031
.condpart630
	LDA tempchar2
	CMP #$41
     BNE .skip630then
.condpart631
	LDA #255
	STA p0_dx
  RTS
.skip630then
.skipL02031
.L02032 ;  if tempchar1 >= spw1  ||  tempchar2 >= spw1 then return

	LDA tempchar1
	CMP #spw1
     BCC .skipL02032
.condpart632
 jmp .condpart633
.skipL02032
	LDA tempchar2
	CMP #spw1
     BCC .skip162OR
.condpart633
  RTS
.skip162OR
.L02033 ;  rem ** the next two lines make the player slide around obstacles 

.L02034 ;  if tempchar1 = $41 then p0_dy = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02034
.condpart634
	LDA #255
	STA p0_dy
  RTS
.skipL02034
.L02035 ;  if tempchar2 = $41 then p0_dy = 1 : return

	LDA tempchar2
	CMP #$41
     BNE .skipL02035
.condpart635
	LDA #1
	STA p0_dy
  RTS
.skipL02035
.L02036 ;  return

  RTS
.
 ; 

.checkmoveright
 ; checkmoveright

.L02037 ;  if p0_x > 152 then p0_dx = 0 : return

	LDA #152
	CMP p0_x
     BCS .skipL02037
.condpart636
	LDA #0
	STA p0_dx
  RTS
.skipL02037
.L02038 ;  temp0_x =  ( p0_x + 4 )  / 4

; complex statement detected
	LDA p0_x
	CLC
	ADC #4
	lsr
	lsr
	STA temp0_x
.L02039 ;  temp0_y =  ( p0_y + 1 )  / 8

; complex statement detected
	LDA p0_y
	CLC
	ADC #1
	lsr
	lsr
	lsr
	STA temp0_y
.L02040 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02041 ;  temp0_y =  ( p0_y + 14 )  / 8

; complex statement detected
	LDA p0_y
	CLC
	ADC #14
	lsr
	lsr
	lsr
	STA temp0_y
.L02042 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.L02043 ;  gosub webflicker

 jsr .webflicker

.L02044 ;  if tempchar1 = $41  &&  tempchar2 = $41 then p0_dx = 1 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02044
.condpart637
	LDA tempchar2
	CMP #$41
     BNE .skip637then
.condpart638
	LDA #1
	STA p0_dx
  RTS
.skip637then
.skipL02044
.L02045 ;  if tempchar1 >= spw1  ||  tempchar2 >= spw1 then return

	LDA tempchar1
	CMP #spw1
     BCC .skipL02045
.condpart639
 jmp .condpart640
.skipL02045
	LDA tempchar2
	CMP #spw1
     BCC .skip164OR
.condpart640
  RTS
.skip164OR
.L02046 ;  rem ** the next two lines make the player slide around obstacles 

.L02047 ;  if tempchar1 = $41 then p0_dy = 255 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02047
.condpart641
	LDA #255
	STA p0_dy
  RTS
.skipL02047
.L02048 ;  if tempchar2 = $41 then p0_dy = 1 : return

	LDA tempchar2
	CMP #$41
     BNE .skipL02048
.condpart642
	LDA #1
	STA p0_dy
  RTS
.skipL02048
.L02049 ;  return

  RTS
.
 ; 

.monstlogic
 ; monstlogic

.L02050 ;  rem ** where Enemies decide which way to move, if they should shoot, which direction, etc...

.
 ; 

.L02051 ;  temppositionadjust = 0

	LDA #0
	STA temppositionadjust
.L02052 ;  for temploop = 0 to 2

	LDA #0
	STA temploop
.L02052fortemploop
.
 ; 

.L02053 ;  tempx = monster1x[temploop]

	LDX temploop
	LDA monster1x,x
	STA tempx
.L02054 ;  tempy = monster1y[temploop]

	LDX temploop
	LDA monster1y,x
	STA tempy
.L02055 ;  tempdir = monster1dir[temploop]

	LDX temploop
	LDA monster1dir,x
	STA tempdir
.L02056 ;  temptype = monster1type[temploop]  :  rem ** for later, in case we decide to modify the behavior based on Enemy type

	LDX temploop
	LDA monster1type,x
	STA temptype
.L02057 ;  templogiccountdown = monster1changecountdown[temploop]

	LDX temploop
	LDA monster1changecountdown,x
	STA templogiccountdown
.L02058 ;  if temptype = 255 then goto skiplogic

	LDA temptype
	CMP #255
     BNE .skipL02058
.condpart643
 jmp .skiplogic

.skipL02058
.
 ; 

.L02059 ;  rem ** data driven monster speed routine

.L02060 ;  temp1 =  ( temptype * 2 )  + levelspeeds[levelvalue]

; complex statement detected
	LDA temptype
	asl
	LDX levelvalue
	CLC
	ADC levelspeeds,x
	STA temp1
.L02061 ;  monst1slow[temploop] = monst1slow[temploop] + temp1

	LDX temploop
	LDA monst1slow,x
	CLC
	ADC temp1
	LDX temploop
	STA monst1slow,x
.L02062 ;  if !CARRY then goto skipnonfiringstuff

 BCS .skipL02062
.condpart644
 jmp .skipnonfiringstuff

.skipL02062
.
 ; 

.L02063 ;  gosub doeachmonsterlogic

 jsr .doeachmonsterlogic

.L02064 ;  gosub doeachmonstermove

 jsr .doeachmonstermove

.
 ; 

.L02065 ;  rem ** stuff tempx, tempy, and tempdir back into the actual Enemy variables

.L02066 ;  monster1x[temploop] = tempx

	LDA tempx
	LDX temploop
	STA monster1x,x
.L02067 ;  monster1y[temploop] = tempy

	LDA tempy
	LDX temploop
	STA monster1y,x
.L02068 ;  monster1dir[temploop] = tempdir

	LDA tempdir
	LDX temploop
	STA monster1dir,x
.L02069 ;  monster1changecountdown[temploop] = templogiccountdown

	LDA templogiccountdown
	LDX temploop
	STA monster1changecountdown,x
.
 ; 

.skipnonfiringstuff
 ; skipnonfiringstuff

.L02070 ;  rem ** check to see if shooting an arrow is required, do position updates

.L02071 ;  gosub doeachmonsterfiring

 jsr .doeachmonsterfiring

.skiplogic
 ; skiplogic

.L02072 ;  next

	LDA temploop
	CMP #2

	INC temploop
 if ((* - .L02052fortemploop) < 127) && ((* - .L02052fortemploop) > -128)
	bcc .L02052fortemploop
 else
	bcs .14skipL02052fortemploop
	jmp .L02052fortemploop
.14skipL02052fortemploop
 endif
.L02073 ;  return

  RTS
.
 ; 

.L02074 ;  rem ** base speeds for Enemies. # out of 255 frames.

.L02075 ;  data levelspeeds

	JMP .skipL02075
levelspeeds
	.byte    00,90,100,105,110,110

.skipL02075
.
 ; 

.doeachmonsterlogic
 ; doeachmonsterlogic

.L02076 ;  rem ** we use 255 as a flag that an Enemy isn't moving yet. pick a random direction.

.L02077 ;  if tempdir = 255 then tempdir = rand & 3

	LDA tempdir
	CMP #255
     BNE .skipL02077
.condpart645
 jsr randomize
	AND #3
	STA tempdir
.skipL02077
.
 ; 

.L02078 ;  if templogiccountdown > 0 then templogiccountdown = templogiccountdown - 1

	LDA #0
	CMP templogiccountdown
     BCS .skipL02078
.condpart646
	LDA templogiccountdown
	SEC
	SBC #1
	STA templogiccountdown
.skipL02078
.L02079 ;  olddir = tempdir

	LDA tempdir
	STA olddir
.
 ; 

.L02080 ;  rem ** notes on monster direction encoding

.L02081 ;  rem ** directions are encoded as "up(0) left(1) down(2) right(3)"

.L02082 ;  rem ** given a direction index, the opposite direction is always (d+2)&3

.L02083 ;  rem ** given a direction index, the adjacent directions are always (d+1)&3 and (d+3)&3

.
 ; 

.L02084 ;  rem ** check if the current direction is free of obstacles

.L02085 ;  on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright

	lda #>(ongosub0-1)
	PHA
	lda #<(ongosub0-1)
	PHA
	LDX tempdir
	LDA .L02085jumptablehi,x
	PHA
	LDA .L02085jumptablelo,x
	PHA
	RTS
.L02085jumptablehi
	.byte >(.checkmonstmoveup-1)
	.byte >(.checkmonstmoveleft-1)
	.byte >(.checkmonstmovedown-1)
	.byte >(.checkmonstmoveright-1)
.L02085jumptablelo
	.byte <(.checkmonstmoveup-1)
	.byte <(.checkmonstmoveleft-1)
	.byte <(.checkmonstmovedown-1)
	.byte <(.checkmonstmoveright-1)
ongosub0
.L02086 ;  if obstacleseen > 0 then goto monstercantmoveforward

	LDA #0
	CMP obstacleseen
     BCS .skipL02086
.condpart647
 jmp .monstercantmoveforward

.skipL02086
.
 ; 

.L02087 ;  rem ** the big blank area in the spider web confuses the side-corridor logic

.L02088 ;  if tempx < 28  &&  tempy < 60 then templogiccountdown = 120 : return

	LDA tempx
	CMP #28
     BCS .skipL02088
.condpart648
	LDA tempy
	CMP #60
     BCS .skip648then
.condpart649
	LDA #120
	STA templogiccountdown
  RTS
.skip648then
.skipL02088
.
 ; 

.L02089 ;  rem ** the Enemy side-corridored recently. skip it.

.L02090 ;  if templogiccountdown > 0 then return

	LDA #0
	CMP templogiccountdown
     BCS .skipL02090
.condpart650
  RTS
.skipL02090
.
 ; 

.L02091 ;  temp9 = rand

 jsr randomize
	STA temp9
.
 ; 

.L02092 ;  rem ** we can still go forward, but let's check for side corridors.

.L02093 ;  if rand < 127 then tempdir =  ( tempdir + 1 )  & 3 else tempdir =  ( tempdir + 3 )  & 3

	LDA rand
	CMP #127
     BCS .skipL02093
.condpart651
; complex statement detected
	LDA tempdir
	CLC
	ADC #1
	AND #3
	STA tempdir
 jmp .skipelse13
.skipL02093
; complex statement detected
	LDA tempdir
	CLC
	ADC #3
	AND #3
	STA tempdir
.skipelse13
.
 ; 

.L02094 ;  rem ** check if that direction is free of obstacles.

.L02095 ;  on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright

	lda #>(ongosub1-1)
	PHA
	lda #<(ongosub1-1)
	PHA
	LDX tempdir
	LDA .L02095jumptablehi,x
	PHA
	LDA .L02095jumptablelo,x
	PHA
	RTS
.L02095jumptablehi
	.byte >(.checkmonstmoveup-1)
	.byte >(.checkmonstmoveleft-1)
	.byte >(.checkmonstmovedown-1)
	.byte >(.checkmonstmoveright-1)
.L02095jumptablelo
	.byte <(.checkmonstmoveup-1)
	.byte <(.checkmonstmoveleft-1)
	.byte <(.checkmonstmovedown-1)
	.byte <(.checkmonstmoveright-1)
ongosub1
.L02096 ;  if obstacleseen > 0 then skipmonstdirchange1

	LDA #0
	CMP obstacleseen
 if ((* - .skipmonstdirchange1) < 127) && ((* - .skipmonstdirchange1) > -128)
	bcc .skipmonstdirchange1
 else
	bcs .15skipskipmonstdirchange1
	jmp .skipmonstdirchange1
.15skipskipmonstdirchange1
 endif
.L02097 ;  goto advancedmonstbranchlogic

 jmp .advancedmonstbranchlogic

.L02098 ;  if olddir <> tempdir then return

	LDA olddir
	CMP tempdir
     BEQ .skipL02098
.condpart652
  RTS
.skipL02098
.skipmonstdirchange1
 ; skipmonstdirchange1

.
 ; 

.L02099 ;  rem ** the previous sideways turn failed. turn the other way.

.L02100 ;  tempdir =  ( tempdir + 2 )  & 3

; complex statement detected
	LDA tempdir
	CLC
	ADC #2
	AND #3
	STA tempdir
.L02101 ;  rem ** check if that direction is free of obstacles.

.L02102 ;  on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright

	lda #>(ongosub2-1)
	PHA
	lda #<(ongosub2-1)
	PHA
	LDX tempdir
	LDA .L02102jumptablehi,x
	PHA
	LDA .L02102jumptablelo,x
	PHA
	RTS
.L02102jumptablehi
	.byte >(.checkmonstmoveup-1)
	.byte >(.checkmonstmoveleft-1)
	.byte >(.checkmonstmovedown-1)
	.byte >(.checkmonstmoveright-1)
.L02102jumptablelo
	.byte <(.checkmonstmoveup-1)
	.byte <(.checkmonstmoveleft-1)
	.byte <(.checkmonstmovedown-1)
	.byte <(.checkmonstmoveright-1)
ongosub2
.L02103 ;  if obstacleseen > 0 then skipmonstdirchange2

	LDA #0
	CMP obstacleseen
 if ((* - .skipmonstdirchange2) < 127) && ((* - .skipmonstdirchange2) > -128)
	bcc .skipmonstdirchange2
 else
	bcs .16skipskipmonstdirchange2
	jmp .skipmonstdirchange2
.16skipskipmonstdirchange2
 endif
.
 ; 

.L02104 ;  goto advancedmonstbranchlogic

 jmp .advancedmonstbranchlogic

.skipmonstdirchange2
 ; skipmonstdirchange2

.L02105 ;  rem ** carry on forward

.L02106 ;  tempdir = olddir

	LDA olddir
	STA tempdir
.L02107 ;  return

  RTS
.
 ; 

.advancedmonstbranchlogic
 ; advancedmonstbranchlogic

.L02108 ;  rem ** directions are encoded as "up(0) left(1) down(2) right(3)"

.L02109 ;  templogiccountdown = 60

	LDA #60
	STA templogiccountdown
.L02110 ;  temp9 = rand

 jsr randomize
	STA temp9
.L02111 ;  if temptype = 1  &&  rand < 127 then tempdir = olddir  :  rem ** %50 chance to go down this fork

	LDA temptype
	CMP #1
     BNE .skipL02111
.condpart653
	LDA rand
	CMP #127
     BCS .skip653then
.condpart654
	LDA olddir
	STA tempdir
.skip653then
.skipL02111
.L02112 ;  if temptype = 1 then return

	LDA temptype
	CMP #1
     BNE .skipL02112
.condpart655
  RTS
.skipL02112
.
 ; 

.L02113 ;  rem ** if the direction change would take us further from the player, cancel it

.L02114 ;  if tempdir = 0  &&  tempy < p0_y then tempdir = olddir

	LDA tempdir
	CMP #0
     BNE .skipL02114
.condpart656
	LDA tempy
	CMP p0_y
     BCS .skip656then
.condpart657
	LDA olddir
	STA tempdir
.skip656then
.skipL02114
.L02115 ;  if tempdir = 1  &&  tempx < p0_x then tempdir = olddir

	LDA tempdir
	CMP #1
     BNE .skipL02115
.condpart658
	LDA tempx
	CMP p0_x
     BCS .skip658then
.condpart659
	LDA olddir
	STA tempdir
.skip658then
.skipL02115
.L02116 ;  if tempdir = 2  &&  tempy > p0_y then tempdir = olddir

	LDA tempdir
	CMP #2
     BNE .skipL02116
.condpart660
	LDA p0_y
	CMP tempy
     BCS .skip660then
.condpart661
	LDA olddir
	STA tempdir
.skip660then
.skipL02116
.L02117 ;  if tempdir = 3  &&  tempy > p0_x then tempdir = olddir

	LDA tempdir
	CMP #3
     BNE .skipL02117
.condpart662
	LDA p0_x
	CMP tempy
     BCS .skip662then
.condpart663
	LDA olddir
	STA tempdir
.skip662then
.skipL02117
.L02118 ;  return

  RTS
.
 ; 

.monstercantmoveforward
 ; monstercantmoveforward

.
 ; 

.L02119 ;  rem ** if not, try turning left or right.

.L02120 ;  temp9 = rand : rem grab a new rand.

 jsr randomize
	STA temp9
.L02121 ;  if rand < 127 then tempdir =  ( tempdir + 1 )  & 3 else tempdir =  ( tempdir + 3 )  & 3

	LDA rand
	CMP #127
     BCS .skipL02121
.condpart664
; complex statement detected
	LDA tempdir
	CLC
	ADC #1
	AND #3
	STA tempdir
 jmp .skipelse14
.skipL02121
; complex statement detected
	LDA tempdir
	CLC
	ADC #3
	AND #3
	STA tempdir
.skipelse14
.
 ; 

.L02122 ;  rem ** check if that direction is free of obstacles.

.L02123 ;  on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright

	lda #>(ongosub3-1)
	PHA
	lda #<(ongosub3-1)
	PHA
	LDX tempdir
	LDA .L02123jumptablehi,x
	PHA
	LDA .L02123jumptablelo,x
	PHA
	RTS
.L02123jumptablehi
	.byte >(.checkmonstmoveup-1)
	.byte >(.checkmonstmoveleft-1)
	.byte >(.checkmonstmovedown-1)
	.byte >(.checkmonstmoveright-1)
.L02123jumptablelo
	.byte <(.checkmonstmoveup-1)
	.byte <(.checkmonstmoveleft-1)
	.byte <(.checkmonstmovedown-1)
	.byte <(.checkmonstmoveright-1)
ongosub3
.L02124 ;  if obstacleseen = 0 then return

	LDA obstacleseen
	CMP #0
     BNE .skipL02124
.condpart665
  RTS
.skipL02124
.
 ; 

.L02125 ;  rem ** the previous sideways turn failed. turn the other way.

.L02126 ;  tempdir =  ( tempdir + 2 )  & 3

; complex statement detected
	LDA tempdir
	CLC
	ADC #2
	AND #3
	STA tempdir
.L02127 ;  rem ** check if that direction is free of obstacles.

.L02128 ;  on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright

	lda #>(ongosub4-1)
	PHA
	lda #<(ongosub4-1)
	PHA
	LDX tempdir
	LDA .L02128jumptablehi,x
	PHA
	LDA .L02128jumptablelo,x
	PHA
	RTS
.L02128jumptablehi
	.byte >(.checkmonstmoveup-1)
	.byte >(.checkmonstmoveleft-1)
	.byte >(.checkmonstmovedown-1)
	.byte >(.checkmonstmoveright-1)
.L02128jumptablelo
	.byte <(.checkmonstmoveup-1)
	.byte <(.checkmonstmoveleft-1)
	.byte <(.checkmonstmovedown-1)
	.byte <(.checkmonstmoveright-1)
ongosub4
.L02129 ;  if obstacleseen = 0 then return

	LDA obstacleseen
	CMP #0
     BNE .skipL02129
.condpart666
  RTS
.skipL02129
.
 ; 

.L02130 ;  rem ** we must be stuck in a dead-end. turn around based on the original direction.

.L02131 ;  tempdir =  ( olddir + 2 )  & 3

; complex statement detected
	LDA olddir
	CLC
	ADC #2
	AND #3
	STA tempdir
.L02132 ;  return

  RTS
.
 ; 

.titlescreen
 ; titlescreen

.
 ; 

.L02133 ;  characterset atascii

    lda #>atascii
    sta CHARBASE
    sta sCHARBASE

    lda #(atascii_mode | %01100000)
    sta charactermode

.L02134 ;  alphachars ASCII

.L02135 ;  clearscreen

 jsr clearscreen
.L02136 ;  AUDV0 = 0 : AUDV1 = 0

	LDA #0
	STA AUDV0
	STA AUDV1
.L02137 ;  drawwait

 jsr drawwait
.
 ; 

.L02138 ;  rem ** initial placement of grey highlight bar for menu selections

.L02139 ;  menubarx = 40

	LDA #40
	STA menubarx
.L02140 ;  menubary = 128

	LDA #128
	STA menubary
.
 ; 

.L02141 ;  rem ** set countdown time for switching to demo mode, set initial value for demo mode to off

.L02142 ;  demomodecountdown = 5

	LDA #5
	STA demomodecountdown
.L02143 ;  demomode = 0

	LDA #0
	STA demomode
.
 ; 

.L02144 ;  rem Say "Dungeon Stalker" when you enter the titlescreen

.L02145 ;  speak intro

    SPEAK intro
.
 ; 

.hiscorereturn
 ; hiscorereturn

.
 ; 

.L02146 ;  rem ** joystick debounce variable

.L02147 ;  if joy0fire then fireheld = 1

 bit sINPT1
	BPL .skipL02147
.condpart667
	LDA #1
	STA fireheld
.skipL02147
.
 ; 

.L02148 ;  rem ** titlescreen background is black

.L02149 ;  SBACKGRND = $00

	LDA #$00
	STA SBACKGRND
.
 ; 

.L02150 ;  rem ** dark yellow (dots at top of graphic)

.L02151 ;  P0C1 = 0

	LDA #0
	STA P0C1
.L02152 ;  P0C2 = $16

	LDA #$16
	STA P0C2
.L02153 ;  P0C3 = 0

	LDA #0
	STA P0C3
.
 ; 

.L02154 ;  rem ** dark blue (copyright and background) 

.L02155 ;  P1C1 = 0

	LDA #0
	STA P1C1
.L02156 ;  P1C2 = $92

	LDA #$92
	STA P1C2
.L02157 ;  P1C3 = 0

	LDA #0
	STA P1C3
.
 ; 

.L02158 ;  rem ** White (menu text)

.L02159 ;  P2C1 = 0

	LDA #0
	STA P2C1
.L02160 ;  P2C2 = $08

	LDA #$08
	STA P2C2
.L02161 ;  P2C3 = 0

	LDA #0
	STA P2C3
.
 ; 

.L02162 ;  rem ** Blue (Dungeon Stalker title) 

.L02163 ;  P3C1 = 0

	LDA #0
	STA P3C1
.L02164 ;  P3C2 = $84

	LDA #$84
	STA P3C2
.L02165 ;  P3C3 = 0

	LDA #0
	STA P3C3
.
 ; 

.L02166 ;  rem ** light Grey (menu selection bar)

.L02167 ;  P4C1 = 0

	LDA #0
	STA P4C1
.L02168 ;  P4C2 = $04

	LDA #$04
	STA P4C2
.L02169 ;  P4C3 = 0

	LDA #0
	STA P4C3
.
 ; 

.L02170 ;  rem ** blue text

.L02171 ;  P5C1 = 0

	LDA #0
	STA P5C1
.L02172 ;  P5C2 = $96

	LDA #$96
	STA P5C2
.L02173 ;  P5C3 = 0

	LDA #0
	STA P5C3
.
 ; 

.L02174 ;  rem ** Can you guess the color for $82? :)

.L02175 ;  P6C1 = 0

	LDA #0
	STA P6C1
.L02176 ;  P6C2 = $82

	LDA #$82
	STA P6C2
.L02177 ;  P6C3 = 0

	LDA #0
	STA P6C3
.
 ; 

.L02178 ;  rem ** Red (background behind the titlescreen graphic text) 

.L02179 ;  P7C1 = 0

	LDA #0
	STA P7C1
.L02180 ;  P7C2 = $40

	LDA #$40
	STA P7C2
.L02181 ;  P7C3 = 0

	LDA #0
	STA P7C3
.
 ; 

.L02182 ;  rem ** This command erases all sprites and characters that you've previously drawn on the screen, so you can draw the next screen.

.L02183 ;  clearscreen

 jsr clearscreen
.
 ; 

.L02184 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L02185 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L02186 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L02187 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L02188 ;  rem ** so you'll have to experiment with their location in your own code.

.L02189 ;  dmahole 2

 jmp dmahole_2
 echo "  ","  ","  ","  ",[($9000 - .)]d , "bytes of ROM space left in DMA hole 0."

 ORG $9000  ; *************

atascii
       HEX 7e7e7e7e0c7e7e307e7e00000000000000000000000000000000000000000000
       HEX 000000000000000000003c01ff00000000000000000000000000003000000000
       HEX 000000000000000000000000000000000000000000000000000000007e000000
       HEX 000000000000007c00003c00000000006006000000000000007800
archer_1_top_faceright
       HEX ba
archer_2_top_faceright
       HEX b1
archer_3_top_faceright
       HEX b1
archer_4_top_faceright
       HEX b9
archer_5_top_faceright
       HEX b9
       HEX 
archer_6_top_faceright
       HEX b1
archer_7_top_faceright
       HEX b1
archer_1_top_faceleft
       HEX 5d
archer_2_top_faceleft
       HEX 8d
archer_3_top_faceleft
       HEX 8d
archer_4_top_faceleft
       HEX 9d
archer_5_top_faceleft
       HEX 9d
archer_6_top_faceleft
       HEX 8d
archer_7_top_faceleft
       HEX 8d
archer_1_bottom_faceright
       HEX cc
archer_2_bottom_faceright
       HEX 0c
archer_3_bottom_faceright
       HEX 30
archer_4_bottom_faceright
       HEX 20
archer_5_bottom_faceright
       HEX 8c
archer_6_bottom_faceright
       HEX 8c
archer_7_bottom_faceright
       HEX 30
archer_1_bottom_faceleft
       HEX 33
archer_2_bottom_faceleft
       HEX 30
archer_3_bottom_faceleft
       HEX 0c
archer_4_bottom_faceleft
       HEX 04
archer_5_bottom_faceleft
       HEX 31
archer_6_bottom_faceleft
       HEX 31
archer_7_bottom_faceleft
       HEX 0c
archer_death_top1
       HEX 39
archer_death_top2
       HEX 39
archer_death_top3
       HEX 39
archer_death_top4
       HEX 39
archer_death_top5
       HEX 39
archer_death_top6
       HEX 39
archer_death_top7
       HEX 39
archer_death_top8
       HEX 39
archer_death_top9
       HEX 00
       HEX 
archer_death_top10
       HEX 00
archer_death_top11
       HEX 00
archer_death_top12
       HEX 00
archer_death_top13
       HEX 00
archer_death_top14
       HEX 00
archer_death_top15
       HEX 00
archer_death_top16
       HEX 00
archer_death_bottom1
       HEX 6c
archer_death_bottom2
       HEX 6c
archer_death_bottom3
       HEX 6c
archer_death_bottom4
       HEX 6c
archer_death_bottom5
       HEX 6c
archer_death_bottom6
       HEX 6c
archer_death_bottom7
       HEX 6c
archer_death_bottom8
       HEX 6c
archer_death_bottom9
       HEX 6c
archer_death_bottom10
       HEX 6c
archer_death_bottom11
       HEX 6c
archer_death_bottom12
       HEX 6c
archer_death_bottom13
       HEX 6c
archer_death_bottom14
       HEX 6c
archer_death_bottom15
       HEX 6c
archer_death_bottom16
       HEX 00
explode1top
       HEX 0000
explode2top
       HEX 0fc0
explode3top
       HEX 00c0
explode4top
       HEX 0330
explode5top
       HEX 00
       HEX 03
explode6top
       HEX 3003
explode7top
       HEX c00c
explode8top
       HEX 0000
explode1bottom
       HEX 0000
explode2bottom
       HEX 0000
explode3bottom
       HEX 0000
explode4bottom
       HEX 00c0
explode5bottom
       HEX ccc0
explode6bottom
       HEX c303
explode7bottom
       HEX 30c0
explode8bottom
       HEX c003
archer_still_top
       HEX ba
archer_still_top_reverse
       HEX a5
archer_still_bottom
       HEX 6c
archer_still_bottom_reverse
       HEX 7c
bat1
       HEX 18
bat2
       HEX 00
bat3
       HEX 00
bat4
       HEX 18
bat5
       HEX 00
       HEX 
bat6
       HEX 00
bat_explode1
       HEX 00
bat_explode2
       HEX 00
bat_explode3
       HEX 00
bat_explode4
       HEX 81
quiver1
       HEX 00
quiver2
       HEX 00
monster1top
       HEX fdbf
monster2top
       HEX ffff
monster1bottom
       HEX 1810
monster2bottom
       HEX 0000
monster3top
       HEX 63e0
monster4top
       HEX 21e0
monster3bottom
       HEX 3bee
monster4bottom
       HEX 37de
monster5top
       HEX 13df
monster6top
       HEX d3fe
monster5bottom
       HEX 1800
monster6bottom
       HEX 0018

 ORG $9100  ; *************

;atascii
       HEX 7e7e7e7e0c7e7e307e7e00000000000000000000000000000000000000000000
       HEX 0018006618463b000e704200000018403c7e7e3c0c3c3c303c38181800000000
       HEX 00667c3c787e603e667e3c667e63663c6036663c187e186366187e1e3c7800ff
       HEX 003e7c3c3e3c1806663c06663c63663c6006607c0e3e1836660c7e
;archer_1_top_faceright
       HEX 7e
;archer_2_top_faceright
       HEX bf
;archer_3_top_faceright
       HEX bf
;archer_4_top_faceright
       HEX 7f
;archer_5_top_faceright
       HEX 7f
       HEX 
;archer_6_top_faceright
       HEX bf
;archer_7_top_faceright
       HEX bf
;archer_1_top_faceleft
       HEX 7e
;archer_2_top_faceleft
       HEX fd
;archer_3_top_faceleft
       HEX fd
;archer_4_top_faceleft
       HEX fe
;archer_5_top_faceleft
       HEX fe
;archer_6_top_faceleft
       HEX fd
;archer_7_top_faceleft
       HEX fd
;archer_1_bottom_faceright
       HEX 88
;archer_2_bottom_faceright
       HEX 08
;archer_3_bottom_faceright
       HEX 60
;archer_4_bottom_faceright
       HEX 48
;archer_5_bottom_faceright
       HEX 88
;archer_6_bottom_faceright
       HEX 88
;archer_7_bottom_faceright
       HEX 60
;archer_1_bottom_faceleft
       HEX 11
;archer_2_bottom_faceleft
       HEX 10
;archer_3_bottom_faceleft
       HEX 06
;archer_4_bottom_faceleft
       HEX 12
;archer_5_bottom_faceleft
       HEX 11
;archer_6_bottom_faceleft
       HEX 11
;archer_7_bottom_faceleft
       HEX 06
;archer_death_top1
       HEX b9
;archer_death_top2
       HEX b9
;archer_death_top3
       HEX b9
;archer_death_top4
       HEX b9
;archer_death_top5
       HEX b9
;archer_death_top6
       HEX b9
;archer_death_top7
       HEX b9
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 28
;archer_death_bottom2
       HEX 28
;archer_death_bottom3
       HEX 28
;archer_death_bottom4
       HEX 28
;archer_death_bottom5
       HEX 28
;archer_death_bottom6
       HEX 28
;archer_death_bottom7
       HEX 28
;archer_death_bottom8
       HEX 28
;archer_death_bottom9
       HEX 28
;archer_death_bottom10
       HEX 28
;archer_death_bottom11
       HEX 28
;archer_death_bottom12
       HEX 28
;archer_death_bottom13
       HEX 28
;archer_death_bottom14
       HEX 28
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0fc0
;explode3top
       HEX 00c0
;explode4top
       HEX 0330
;explode5top
       HEX 00
       HEX 03
;explode6top
       HEX 3003
;explode7top
       HEX c00c
;explode8top
       HEX 0000
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0000
;explode3bottom
       HEX 0000
;explode4bottom
       HEX 00c0
;explode5bottom
       HEX ccc0
;explode6bottom
       HEX c303
;explode7bottom
       HEX 30c0
;explode8bottom
       HEX c003
;archer_still_top
       HEX 7e
;archer_still_top_reverse
       HEX a1
;archer_still_bottom
       HEX 28
;archer_still_bottom_reverse
       HEX 54
;bat1
       HEX 18
;bat2
       HEX 00
;bat3
       HEX 81
;bat4
       HEX 18
;bat5
       HEX 00
       HEX 
;bat6
       HEX 81
;bat_explode1
       HEX 00
;bat_explode2
       HEX 24
;bat_explode3
       HEX 42
;bat_explode4
       HEX 00
;quiver1
       HEX e0
;quiver2
       HEX 00
;monster1top
       HEX f99f
;monster2top
       HEX f99f
;monster1bottom
       HEX 3bdc
;monster2bottom
       HEX 1810
;monster3top
       HEX 07c0
;monster4top
       HEX 43c0
;monster3bottom
       HEX 4003
;monster4bottom
       HEX 4003
;monster5top
       HEX 15bf
;monster6top
       HEX 15be
;monster5bottom
       HEX 0820
;monster6bottom
       HEX 0410

 ORG $9200  ; *************

;atascii
       HEX 661860060c066630660600000000000000000000000000000000000000000000
       HEX 000000ff7c6666001c389d1800001860661830667e666630660c18180c183010
       HEX 087e66666c6060666618666c60636e66606c6c0618663c776618601818180000
       HEX 006666606660183e6618066c186b66667c3e600618663c3e3c3e30
;archer_1_top_faceright
       HEX 72
;archer_2_top_faceright
       HEX 79
;archer_3_top_faceright
       HEX 79
;archer_4_top_faceright
       HEX 71
;archer_5_top_faceright
       HEX 71
       HEX 
;archer_6_top_faceright
       HEX 79
;archer_7_top_faceright
       HEX f9
;archer_1_top_faceleft
       HEX 4e
;archer_2_top_faceleft
       HEX 9e
;archer_3_top_faceleft
       HEX 9e
;archer_4_top_faceleft
       HEX 8e
;archer_5_top_faceleft
       HEX 8e
;archer_6_top_faceleft
       HEX 9e
;archer_7_top_faceleft
       HEX 9f
;archer_1_bottom_faceright
       HEX 88
;archer_2_bottom_faceright
       HEX 88
;archer_3_bottom_faceright
       HEX 60
;archer_4_bottom_faceright
       HEX 48
;archer_5_bottom_faceright
       HEX 88
;archer_6_bottom_faceright
       HEX 88
;archer_7_bottom_faceright
       HEX 60
;archer_1_bottom_faceleft
       HEX 11
;archer_2_bottom_faceleft
       HEX 11
;archer_3_bottom_faceleft
       HEX 06
;archer_4_bottom_faceleft
       HEX 12
;archer_5_bottom_faceleft
       HEX 11
;archer_6_bottom_faceleft
       HEX 11
;archer_7_bottom_faceleft
       HEX 06
;archer_death_top1
       HEX 7f
;archer_death_top2
       HEX 7f
;archer_death_top3
       HEX 7f
;archer_death_top4
       HEX 7f
;archer_death_top5
       HEX 7f
;archer_death_top6
       HEX 7f
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 28
;archer_death_bottom2
       HEX 28
;archer_death_bottom3
       HEX 28
;archer_death_bottom4
       HEX 28
;archer_death_bottom5
       HEX 28
;archer_death_bottom6
       HEX 28
;archer_death_bottom7
       HEX 28
;archer_death_bottom8
       HEX 28
;archer_death_bottom9
       HEX 28
;archer_death_bottom10
       HEX 28
;archer_death_bottom11
       HEX 28
;archer_death_bottom12
       HEX 28
;archer_death_bottom13
       HEX 28
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0300
;explode3top
       HEX 3030
;explode4top
       HEX 0003
;explode5top
       HEX 03
       HEX 30
;explode6top
       HEX 000c
;explode7top
       HEX 0003
;explode8top
       HEX c000
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0000
;explode3bottom
       HEX 0300
;explode4bottom
       HEX 3003
;explode5bottom
       HEX 0003
;explode6bottom
       HEX 30cc
;explode7bottom
       HEX 0003
;explode8bottom
       HEX 0000
;archer_still_top
       HEX 3a
;archer_still_top_reverse
       HEX c5
;archer_still_bottom
       HEX 28
;archer_still_bottom_reverse
       HEX 54
;bat1
       HEX 24
;bat2
       HEX 18
;bat3
       HEX 99
;bat4
       HEX 24
;bat5
       HEX 18
       HEX 
;bat6
       HEX 99
;bat_explode1
       HEX 00
;bat_explode2
       HEX 00
;bat_explode3
       HEX 18
;bat_explode4
       HEX 00
;quiver1
       HEX e0
;quiver2
       HEX 00
;monster1top
       HEX 7bdc
;monster2top
       HEX 7ffe
;monster1bottom
       HEX 3ffc
;monster2bottom
       HEX 3bdc
;monster3top
       HEX 0780
;monster4top
       HEX 23c0
;monster3bottom
       HEX 8efb
;monster4bottom
       HEX 8df3
;monster5top
       HEX 0a6e
;monster6top
       HEX 0a5c
;monster5bottom
       HEX 0830
;monster6bottom
       HEX 0c10

 ORG $9300  ; *************

;atascii
       HEX 66187c3e7e7e7e387e7e00000000000000000000000000000000000000000000
       HEX 0018006606306f001818a118000000307618180c6c06661866060000183c1818
       HEX 186666606660606e66180678606b7e667c667c061866667f3c18301818186300
       HEX 003e6660667e186666180678187f66666666603c1866667f186618
;archer_1_top_faceright
       HEX 22
;archer_2_top_faceright
       HEX 71
;archer_3_top_faceright
       HEX 71
;archer_4_top_faceright
       HEX 21
;archer_5_top_faceright
       HEX 21
       HEX 
;archer_6_top_faceright
       HEX 71
;archer_7_top_faceright
       HEX 71
;archer_1_top_faceleft
       HEX 44
;archer_2_top_faceleft
       HEX 8e
;archer_3_top_faceleft
       HEX 8e
;archer_4_top_faceleft
       HEX 84
;archer_5_top_faceleft
       HEX 84
;archer_6_top_faceleft
       HEX 8e
;archer_7_top_faceleft
       HEX 8e
;archer_1_bottom_faceright
       HEX 90
;archer_2_bottom_faceright
       HEX 88
;archer_3_bottom_faceright
       HEX 60
;archer_4_bottom_faceright
       HEX 28
;archer_5_bottom_faceright
       HEX 88
;archer_6_bottom_faceright
       HEX 88
;archer_7_bottom_faceright
       HEX 60
;archer_1_bottom_faceleft
       HEX 09
;archer_2_bottom_faceleft
       HEX 11
;archer_3_bottom_faceleft
       HEX 06
;archer_4_bottom_faceleft
       HEX 14
;archer_5_bottom_faceleft
       HEX 11
;archer_6_bottom_faceleft
       HEX 11
;archer_7_bottom_faceleft
       HEX 06
;archer_death_top1
       HEX 39
;archer_death_top2
       HEX 39
;archer_death_top3
       HEX 39
;archer_death_top4
       HEX 39
;archer_death_top5
       HEX 39
;archer_death_top6
       HEX 00
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 28
;archer_death_bottom2
       HEX 28
;archer_death_bottom3
       HEX 28
;archer_death_bottom4
       HEX 28
;archer_death_bottom5
       HEX 28
;archer_death_bottom6
       HEX 28
;archer_death_bottom7
       HEX 28
;archer_death_bottom8
       HEX 28
;archer_death_bottom9
       HEX 28
;archer_death_bottom10
       HEX 28
;archer_death_bottom11
       HEX 28
;archer_death_bottom12
       HEX 28
;archer_death_bottom13
       HEX 00
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0300
;explode3top
       HEX 3030
;explode4top
       HEX 0003
;explode5top
       HEX 03
       HEX 30
;explode6top
       HEX 000c
;explode7top
       HEX 0003
;explode8top
       HEX c000
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0000
;explode3bottom
       HEX 0300
;explode4bottom
       HEX 3003
;explode5bottom
       HEX 0003
;explode6bottom
       HEX 30cc
;explode7bottom
       HEX 0003
;explode8bottom
       HEX 0000
;archer_still_top
       HEX 92
;archer_still_top_reverse
       HEX 6d
;archer_still_bottom
       HEX 28
;archer_still_bottom_reverse
       HEX 57
;bat1
       HEX 42
;bat2
       HEX 18
;bat3
       HEX 5a
;bat4
       HEX 42
;bat5
       HEX 18
       HEX 
;bat6
       HEX 5a
;bat_explode1
       HEX 18
;bat_explode2
       HEX 18
;bat_explode3
       HEX 00
;bat_explode4
       HEX 00
;quiver1
       HEX f0
;quiver2
       HEX 00
;monster1top
       HEX 07e0
;monster2top
       HEX 33cc
;monster1bottom
       HEX 37ec
;monster2bottom
       HEX 3ffc
;monster3top
       HEX 07c0
;monster4top
       HEX 03c0
;monster3bottom
       HEX 983e
;monster4bottom
       HEX 983e
;monster5top
       HEX 0180
;monster6top
       HEX 0180
;monster5bottom
       HEX 0408
;monster6bottom
       HEX 1020

 ORG $9400  ; *************

;atascii
       HEX 66181e3e6c7e7e1c7e7e00000000000000000000000000000000000000000000
       HEX 001866663c1838181818a17e000000186e180c183c7c7c0c3c3e18183f3cfc1f
       HEX f8667c60667c7c607e180678607f7e666666663c1866666b3c3c181818183600
       HEX 18067c603e663e667c38066c187f6666666666601866666b3c660c
;archer_1_top_faceright
       HEX b2
;archer_2_top_faceright
       HEX 21
;archer_3_top_faceright
       HEX 21
;archer_4_top_faceright
       HEX b1
;archer_5_top_faceright
       HEX b1
       HEX 
;archer_6_top_faceright
       HEX 21
;archer_7_top_faceright
       HEX a1
;archer_1_top_faceleft
       HEX 4d
;archer_2_top_faceleft
       HEX 84
;archer_3_top_faceleft
       HEX 84
;archer_4_top_faceleft
       HEX 8d
;archer_5_top_faceleft
       HEX 8d
;archer_6_top_faceleft
       HEX 84
;archer_7_top_faceleft
       HEX 85
;archer_1_bottom_faceright
       HEX 54
;archer_2_bottom_faceright
       HEX 6a
;archer_3_bottom_faceright
       HEX 52
;archer_4_bottom_faceright
       HEX 2a
;archer_5_bottom_faceright
       HEX 52
;archer_6_bottom_faceright
       HEX 52
;archer_7_bottom_faceright
       HEX 52
;archer_1_bottom_faceleft
       HEX 2a
;archer_2_bottom_faceleft
       HEX 56
;archer_3_bottom_faceleft
       HEX 4a
;archer_4_bottom_faceleft
       HEX 54
;archer_5_bottom_faceleft
       HEX 4a
;archer_6_bottom_faceleft
       HEX 4a
;archer_7_bottom_faceleft
       HEX 4a
;archer_death_top1
       HEX 91
;archer_death_top2
       HEX 91
;archer_death_top3
       HEX 91
;archer_death_top4
       HEX 91
;archer_death_top5
       HEX 00
;archer_death_top6
       HEX 00
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 2a
;archer_death_bottom2
       HEX 2a
;archer_death_bottom3
       HEX 2a
;archer_death_bottom4
       HEX 2a
;archer_death_bottom5
       HEX 2a
;archer_death_bottom6
       HEX 2a
;archer_death_bottom7
       HEX 2a
;archer_death_bottom8
       HEX 2a
;archer_death_bottom9
       HEX 2a
;archer_death_bottom10
       HEX 2a
;archer_death_bottom11
       HEX 2a
;archer_death_bottom12
       HEX 00
;archer_death_bottom13
       HEX 00
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0000
;explode3top
       HEX 0300
;explode4top
       HEX 3000
;explode5top
       HEX 00
       HEX 03
;explode6top
       HEX 3330
;explode7top
       HEX 0300
;explode8top
       HEX 0003
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0300
;explode3bottom
       HEX 3030
;explode4bottom
       HEX 0030
;explode5bottom
       HEX 0330
;explode6bottom
       HEX 0c00
;explode7bottom
       HEX 3000
;explode8bottom
       HEX 0000
;archer_still_top
       HEX ba
;archer_still_top_reverse
       HEX 45
;archer_still_bottom
       HEX 3a
;archer_still_bottom_reverse
       HEX 45
;bat1
       HEX 81
;bat2
       HEX a5
;bat3
       HEX 24
;bat4
       HEX 81
;bat5
       HEX a5
       HEX 
;bat6
       HEX 24
;bat_explode1
       HEX 18
;bat_explode2
       HEX 24
;bat_explode3
       HEX 00
;bat_explode4
       HEX 00
;quiver1
       HEX e8
;quiver2
       HEX 00
;monster1top
       HEX 05a0
;monster2top
       HEX 1818
;monster1bottom
       HEX 06a0
;monster2bottom
       HEX 37ec
;monster3top
       HEX 03fc
;monster4top
       HEX 03e0
;monster3bottom
       HEX 97fc
;monster4bottom
       HEX 97fc
;monster5top
       HEX 03c0
;monster6top
       HEX 03c0
;monster5bottom
       HEX 0670
;monster6bottom
       HEX 0e60

 ORG $9500  ; *************

;atascii
       HEX 661806066c60600e666600000000000000000000000000000000000000000000
       HEX 001866ff606c1c181c389d180000000c6638660c1c6060066666181818181818
       HEX 183c66666c6060606618066c60777666666666601866666366660c1818181c00
       HEX 183c603c063c183e6000006018667c3c7c3e7c3e7e66666366667e
;archer_1_top_faceright
       HEX 76
;archer_2_top_faceright
       HEX b3
;archer_3_top_faceright
       HEX 33
;archer_4_top_faceright
       HEX 73
;archer_5_top_faceright
       HEX 73
       HEX 
;archer_6_top_faceright
       HEX b3
;archer_7_top_faceright
       HEX 73
;archer_1_top_faceleft
       HEX 6e
;archer_2_top_faceleft
       HEX cd
;archer_3_top_faceleft
       HEX cc
;archer_4_top_faceleft
       HEX ce
;archer_5_top_faceleft
       HEX ce
;archer_6_top_faceleft
       HEX cd
;archer_7_top_faceleft
       HEX ce
;archer_1_bottom_faceright
       HEX 74
;archer_2_bottom_faceright
       HEX 72
;archer_3_bottom_faceright
       HEX 72
;archer_4_bottom_faceright
       HEX 72
;archer_5_bottom_faceright
       HEX 72
;archer_6_bottom_faceright
       HEX 72
;archer_7_bottom_faceright
       HEX 72
;archer_1_bottom_faceleft
       HEX 2e
;archer_2_bottom_faceleft
       HEX 4e
;archer_3_bottom_faceleft
       HEX 4e
;archer_4_bottom_faceleft
       HEX 4e
;archer_5_bottom_faceleft
       HEX 4e
;archer_6_bottom_faceleft
       HEX 4e
;archer_7_bottom_faceleft
       HEX 4e
;archer_death_top1
       HEX bb
;archer_death_top2
       HEX bb
;archer_death_top3
       HEX bb
;archer_death_top4
       HEX 00
;archer_death_top5
       HEX 00
;archer_death_top6
       HEX 00
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 3a
;archer_death_bottom2
       HEX 3a
;archer_death_bottom3
       HEX 3a
;archer_death_bottom4
       HEX 3a
;archer_death_bottom5
       HEX 3a
;archer_death_bottom6
       HEX 3a
;archer_death_bottom7
       HEX 3a
;archer_death_bottom8
       HEX 3a
;archer_death_bottom9
       HEX 3a
;archer_death_bottom10
       HEX 3a
;archer_death_bottom11
       HEX 00
;archer_death_bottom12
       HEX 00
;archer_death_bottom13
       HEX 00
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0000
;explode3top
       HEX 0300
;explode4top
       HEX 3000
;explode5top
       HEX 00
       HEX 03
;explode6top
       HEX 3330
;explode7top
       HEX 0300
;explode8top
       HEX 0003
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0300
;explode3bottom
       HEX 3030
;explode4bottom
       HEX 0030
;explode5bottom
       HEX 0330
;explode6bottom
       HEX 0c00
;explode7bottom
       HEX 3000
;explode8bottom
       HEX 0000
;archer_still_top
       HEX 7a
;archer_still_top_reverse
       HEX 85
;archer_still_bottom
       HEX 3a
;archer_still_bottom_reverse
       HEX 45
;bat1
       HEX 81
;bat2
       HEX 42
;bat3
       HEX 00
;bat4
       HEX 81
;bat5
       HEX 42
       HEX 
;bat6
       HEX 00
;bat_explode1
       HEX 81
;bat_explode2
       HEX 00
;bat_explode3
       HEX 00
;bat_explode4
       HEX 00
;quiver1
       HEX e4
;quiver2
       HEX 00
;monster1top
       HEX 0810
;monster2top
       HEX 07e0
;monster1bottom
       HEX 0420
;monster2bottom
       HEX 0420
;monster3top
       HEX 01f6
;monster4top
       HEX 01fc
;monster3bottom
       HEX 48f8
;monster4bottom
       HEX 48f8
;monster5top
       HEX 0660
;monster6top
       HEX 0660
;monster5bottom
       HEX 6420
;monster6bottom
       HEX 0420

 ORG $9600  ; *************

;atascii
       HEX 7e387e7e6c7e7e7e7e7e00000000000000000000000000000000000000000000
       HEX 001866663e6636180e704218000000063c183c7e0c7e3c7e3c3c00000c003010
       HEX 08187c3c787e7e3e667e06666063663c7c3c7c3c7e66666366667e1e3c780800
       HEX 1800600006000e0060180660380000000000000018000000000000
;archer_1_top_faceright
       HEX 34
;archer_2_top_faceright
       HEX 72
;archer_3_top_faceright
       HEX f2
;archer_4_top_faceright
       HEX 32
;archer_5_top_faceright
       HEX 32
       HEX 
;archer_6_top_faceright
       HEX 72
;archer_7_top_faceright
       HEX 32
;archer_1_top_faceleft
       HEX 2c
;archer_2_top_faceleft
       HEX 4e
;archer_3_top_faceleft
       HEX 4f
;archer_4_top_faceleft
       HEX 4c
;archer_5_top_faceleft
       HEX 4c
;archer_6_top_faceleft
       HEX 4e
;archer_7_top_faceleft
       HEX 4c
;archer_1_bottom_faceright
       HEX 36
;archer_2_bottom_faceright
       HEX 33
;archer_3_bottom_faceright
       HEX 73
;archer_4_bottom_faceright
       HEX 73
;archer_5_bottom_faceright
       HEX 73
;archer_6_bottom_faceright
       HEX 73
;archer_7_bottom_faceright
       HEX 33
;archer_1_bottom_faceleft
       HEX 6c
;archer_2_bottom_faceleft
       HEX cc
;archer_3_bottom_faceleft
       HEX ce
;archer_4_bottom_faceleft
       HEX ce
;archer_5_bottom_faceleft
       HEX ce
;archer_6_bottom_faceleft
       HEX ce
;archer_7_bottom_faceleft
       HEX cc
;archer_death_top1
       HEX 7a
;archer_death_top2
       HEX 7a
;archer_death_top3
       HEX 00
;archer_death_top4
       HEX 00
;archer_death_top5
       HEX 00
;archer_death_top6
       HEX 00
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 3a
;archer_death_bottom2
       HEX 3a
;archer_death_bottom3
       HEX 3a
;archer_death_bottom4
       HEX 3a
;archer_death_bottom5
       HEX 3a
;archer_death_bottom6
       HEX 3a
;archer_death_bottom7
       HEX 3a
;archer_death_bottom8
       HEX 3a
;archer_death_bottom9
       HEX 3a
;archer_death_bottom10
       HEX 00
;archer_death_bottom11
       HEX 00
;archer_death_bottom12
       HEX 00
;archer_death_bottom13
       HEX 00
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 0000
;explode2top
       HEX 0000
;explode3top
       HEX 0000
;explode4top
       HEX 00c0
;explode5top
       HEX c0
       HEX c0
;explode6top
       HEX c0c3
;explode7top
       HEX cc0c
;explode8top
       HEX 300c
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0fc0
;explode3bottom
       HEX cc00
;explode4bottom
       HEX ccc0
;explode5bottom
       HEX cc00
;explode6bottom
       HEX c00c
;explode7bottom
       HEX 0000
;explode8bottom
       HEX 0000
;archer_still_top
       HEX 3a
;archer_still_top_reverse
       HEX 45
;archer_still_bottom
       HEX 12
;archer_still_bottom_reverse
       HEX 6d
;bat1
       HEX 00
;bat2
       HEX 00
;bat3
       HEX 00
;bat4
       HEX 00
;bat5
       HEX 00
       HEX 
;bat6
       HEX 00
;bat_explode1
       HEX 24
;bat_explode2
       HEX 81
;bat_explode3
       HEX 00
;bat_explode4
       HEX 00
;quiver1
       HEX e4
;quiver2
       HEX 00
;monster1top
       HEX 0000
;monster2top
       HEX 0c30
;monster1bottom
       HEX 2a54
;monster2bottom
       HEX 3a5c
;monster3top
       HEX 0078
;monster4top
       HEX 00f3
;monster3bottom
       HEX 21f0
;monster4bottom
       HEX 21f0
;monster5top
       HEX 05a0
;monster6top
       HEX 05a0
;monster5bottom
       HEX 63ce
;monster6bottom
       HEX 03dc

 ORG $9700  ; *************

;atascii
       HEX 7e387e7e6c7e7e7e7e7e00000000000000000000000000000000000000000000
       HEX 0000000018001c0000003c0000fe000000000000000000000000000000000000
       HEX 000000000000000000000000000000000000000000000000000000007e000000
       HEX 000000000000000000000000000000000000000000000000000000
;archer_1_top_faceright
       HEX 04
;archer_2_top_faceright
       HEX 32
;archer_3_top_faceright
       HEX 32
;archer_4_top_faceright
       HEX 02
;archer_5_top_faceright
       HEX 02
       HEX 
;archer_6_top_faceright
       HEX 32
;archer_7_top_faceright
       HEX 32
;archer_1_top_faceleft
       HEX 20
;archer_2_top_faceleft
       HEX 4c
;archer_3_top_faceleft
       HEX 4c
;archer_4_top_faceleft
       HEX 40
;archer_5_top_faceleft
       HEX 40
;archer_6_top_faceleft
       HEX 4c
;archer_7_top_faceleft
       HEX 4c
;archer_1_bottom_faceright
       HEX b2
;archer_2_bottom_faceright
       HEX 71
;archer_3_bottom_faceright
       HEX b1
;archer_4_bottom_faceright
       HEX b1
;archer_5_bottom_faceright
       HEX b1
;archer_6_bottom_faceright
       HEX b1
;archer_7_bottom_faceright
       HEX 71
;archer_1_bottom_faceleft
       HEX 4d
;archer_2_bottom_faceleft
       HEX 8e
;archer_3_bottom_faceleft
       HEX 8d
;archer_4_bottom_faceleft
       HEX 8d
;archer_5_bottom_faceleft
       HEX 8d
;archer_6_bottom_faceleft
       HEX 8d
;archer_7_bottom_faceleft
       HEX 8e
;archer_death_top1
       HEX 3a
;archer_death_top2
       HEX 00
;archer_death_top3
       HEX 00
;archer_death_top4
       HEX 00
;archer_death_top5
       HEX 00
;archer_death_top6
       HEX 00
;archer_death_top7
       HEX 00
;archer_death_top8
       HEX 00
;archer_death_top9
       HEX 00
       HEX 
;archer_death_top10
       HEX 00
;archer_death_top11
       HEX 00
;archer_death_top12
       HEX 00
;archer_death_top13
       HEX 00
;archer_death_top14
       HEX 00
;archer_death_top15
       HEX 00
;archer_death_top16
       HEX 00
;archer_death_bottom1
       HEX 13
;archer_death_bottom2
       HEX 13
;archer_death_bottom3
       HEX 13
;archer_death_bottom4
       HEX 13
;archer_death_bottom5
       HEX 13
;archer_death_bottom6
       HEX 13
;archer_death_bottom7
       HEX 13
;archer_death_bottom8
       HEX 13
;archer_death_bottom9
       HEX 00
;archer_death_bottom10
       HEX 00
;archer_death_bottom11
       HEX 00
;archer_death_bottom12
       HEX 00
;archer_death_bottom13
       HEX 00
;archer_death_bottom14
       HEX 00
;archer_death_bottom15
       HEX 00
;archer_death_bottom16
       HEX 00
;explode1top
       HEX 00c0
;explode2top
       HEX 0000
;explode3top
       HEX 0000
;explode4top
       HEX 00c0
;explode5top
       HEX c0
       HEX c0
;explode6top
       HEX c0c3
;explode7top
       HEX cc0c
;explode8top
       HEX 300c
;explode1bottom
       HEX 0000
;explode2bottom
       HEX 0fc0
;explode3bottom
       HEX cc00
;explode4bottom
       HEX ccc0
;explode5bottom
       HEX cc00
;explode6bottom
       HEX c00c
;explode7bottom
       HEX 0000
;explode8bottom
       HEX 0000
;archer_still_top
       HEX 00
;archer_still_top_reverse
       HEX 3a
;archer_still_bottom
       HEX 3a
;archer_still_bottom_reverse
       HEX c5
;bat1
       HEX 00
;bat2
       HEX 00
;bat3
       HEX 00
;bat4
       HEX 00
;bat5
       HEX 00
       HEX 
;bat6
       HEX 00
;bat_explode1
       HEX 00
;bat_explode2
       HEX 24
;bat_explode3
       HEX 81
;bat_explode4
       HEX 81
;quiver1
       HEX 18
;quiver2
       HEX 00
;monster1top
       HEX 0000
;monster2top
       HEX 0000
;monster1bottom
       HEX 3bdc
;monster2bottom
       HEX 3bdc
;monster3top
       HEX 0000
;monster4top
       HEX 003c
;monster3bottom
       HEX 91e0
;monster4bottom
       HEX 11e0
;monster5top
       HEX 03c0
;monster6top
       HEX 03c0
;monster5bottom
       HEX 259f
;monster6bottom
       HEX e5be

 ORG $9800  ; *************
dmahole_1
.
 ; 

.L02265 ;  rem ** plot the dev mode menu

.L02266 ;  if speedvalue = 1 then plotchars 'Speed^^^^^^<Normal@' 2 42 17 : speedvalue = 1 : rem 136

	LDA speedvalue
	CMP #1
     BNE .skipL02266
.condpart685
	JMP skipalphadata57
alphadata57
 .byte (<atascii + $53)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $65)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $4e)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $6d)
 .byte (<atascii + $61)
 .byte (<atascii + $6c)
 .byte (<atascii + $40)
skipalphadata57
    lda #<alphadata57
    sta temp1

    lda #>alphadata57
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17
    sta temp5

 jsr plotcharacters
	LDA #1
	STA speedvalue
.skipL02266
.L02267 ;  if speedvalue = 2 then plotchars 'Speed^^^^^^?Fast>' 2 42 17 : speedvalue = 2

	LDA speedvalue
	CMP #2
     BNE .skipL02267
.condpart686
	JMP skipalphadata58
alphadata58
 .byte (<atascii + $53)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $65)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $46)
 .byte (<atascii + $61)
 .byte (<atascii + $73)
 .byte (<atascii + $74)
 .byte (<atascii + $3e)
skipalphadata58
    lda #<alphadata58
    sta temp1

    lda #>alphadata58
    sta temp2

    lda #15 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17
    sta temp5

 jsr plotcharacters
	LDA #2
	STA speedvalue
.skipL02267
.
 ; 

.L02268 ;  if levelvalue = 1 then plotchars 'Level^^^^^^?1>' 2 42 18

	LDA levelvalue
	CMP #1
     BNE .skipL02268
.condpart687
	JMP skipalphadata59
alphadata59
 .byte (<atascii + $4c)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $31)
 .byte (<atascii + $3e)
skipalphadata59
    lda #<alphadata59
    sta temp1

    lda #>alphadata59
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.skipL02268
.L02269 ;  if levelvalue = 2 then plotchars 'Level^^^^^^<2>' 2 42 18

	LDA levelvalue
	CMP #2
     BNE .skipL02269
.condpart688
	JMP skipalphadata60
alphadata60
 .byte (<atascii + $4c)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $32)
 .byte (<atascii + $3e)
skipalphadata60
    lda #<alphadata60
    sta temp1

    lda #>alphadata60
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.skipL02269
.L02270 ;  if levelvalue = 3 then plotchars 'Level^^^^^^<3>' 2 42 18

	LDA levelvalue
	CMP #3
     BNE .skipL02270
.condpart689
	JMP skipalphadata61
alphadata61
 .byte (<atascii + $4c)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $33)
 .byte (<atascii + $3e)
skipalphadata61
    lda #<alphadata61
    sta temp1

    lda #>alphadata61
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.skipL02270
.L02271 ;  if levelvalue = 4 then plotchars 'Level^^^^^^<4>' 2 42 18

	LDA levelvalue
	CMP #4
     BNE .skipL02271
.condpart690
	JMP skipalphadata62
alphadata62
 .byte (<atascii + $4c)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $34)
 .byte (<atascii + $3e)
skipalphadata62
    lda #<alphadata62
    sta temp1

    lda #>alphadata62
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.skipL02271
.L02272 ;  if levelvalue = 5 then plotchars 'Level^^^^^^<5@' 2 42 18

	LDA levelvalue
	CMP #5
     BNE .skipL02272
.condpart691
	JMP skipalphadata63
alphadata63
 .byte (<atascii + $4c)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $35)
 .byte (<atascii + $40)
skipalphadata63
    lda #<alphadata63
    sta temp1

    lda #>alphadata63
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.skipL02272
.
 ; 

.L02273 ;  if godvalue = 1 then plotchars 'God^Mode^^^?Off>' 2 42 21 : godvalue = 1 : rem 168

	LDA godvalue
	CMP #1
     BNE .skipL02273
.condpart692
	JMP skipalphadata64
alphadata64
 .byte (<atascii + $47)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $4d)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $4f)
 .byte (<atascii + $66)
 .byte (<atascii + $66)
 .byte (<atascii + $3e)
skipalphadata64
    lda #<alphadata64
    sta temp1

    lda #>alphadata64
    sta temp2

    lda #16 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #21
    sta temp5

 jsr plotcharacters
	LDA #1
	STA godvalue
.skipL02273
.L02274 ;  if godvalue = 2 then plotchars 'God^Mode^^^<On@' 2 42 21 : godvalue = 2

	LDA godvalue
	CMP #2
     BNE .skipL02274
.condpart693
	JMP skipalphadata65
alphadata65
 .byte (<atascii + $47)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $4d)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $4f)
 .byte (<atascii + $6e)
 .byte (<atascii + $40)
skipalphadata65
    lda #<alphadata65
    sta temp1

    lda #>alphadata65
    sta temp2

    lda #17 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #21
    sta temp5

 jsr plotcharacters
	LDA #2
	STA godvalue
.skipL02274
.
 ; 

.L02275 ;  if livesvalue = 1 then plotchars 'Lives^^^^^^?1>' 2 42 20 : rem 160

	LDA livesvalue
	CMP #1
     BNE .skipL02275
.condpart694
	JMP skipalphadata66
alphadata66
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $31)
 .byte (<atascii + $3e)
skipalphadata66
    lda #<alphadata66
    sta temp1

    lda #>alphadata66
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20
    sta temp5

 jsr plotcharacters
.skipL02275
.L02276 ;  if livesvalue = 2 then plotchars 'Lives^^^^^^<2>' 2 42 20

	LDA livesvalue
	CMP #2
     BNE .skipL02276
.condpart695
	JMP skipalphadata67
alphadata67
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $32)
 .byte (<atascii + $3e)
skipalphadata67
    lda #<alphadata67
    sta temp1

    lda #>alphadata67
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02276
.L02277 ;  if livesvalue = 3 then plotchars 'Lives^^^^^^<3>' 2 42 20

	LDA livesvalue
	CMP #3
     BNE .skipL02277
.condpart696
	JMP skipalphadata68
alphadata68
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $33)
 .byte (<atascii + $3e)
skipalphadata68
    lda #<alphadata68
    sta temp1

    lda #>alphadata68
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02277
.L02278 ;  if livesvalue = 4 then plotchars 'Lives^^^^^^<4>' 2 42 20

	LDA livesvalue
	CMP #4
     BNE .skipL02278
.condpart697
	JMP skipalphadata69
alphadata69
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $34)
 .byte (<atascii + $3e)
skipalphadata69
    lda #<alphadata69
    sta temp1

    lda #>alphadata69
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02278
.L02279 ;  if livesvalue = 5 then plotchars 'Lives^^^^^^<5>' 2 42 20

	LDA livesvalue
	CMP #5
     BNE .skipL02279
.condpart698
	JMP skipalphadata70
alphadata70
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $35)
 .byte (<atascii + $3e)
skipalphadata70
    lda #<alphadata70
    sta temp1

    lda #>alphadata70
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02279
.L02280 ;  if livesvalue = 6 then plotchars 'Lives^^^^^^<6>' 2 42 20

	LDA livesvalue
	CMP #6
     BNE .skipL02280
.condpart699
	JMP skipalphadata71
alphadata71
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $36)
 .byte (<atascii + $3e)
skipalphadata71
    lda #<alphadata71
    sta temp1

    lda #>alphadata71
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02280
.L02281 ;  if livesvalue = 7 then plotchars 'Lives^^^^^^<7>' 2 42 20

	LDA livesvalue
	CMP #7
     BNE .skipL02281
.condpart700
	JMP skipalphadata72
alphadata72
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $37)
 .byte (<atascii + $3e)
skipalphadata72
    lda #<alphadata72
    sta temp1

    lda #>alphadata72
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02281
.L02282 ;  if livesvalue = 8 then plotchars 'Lives^^^^^^<8>' 2 42 20

	LDA livesvalue
	CMP #8
     BNE .skipL02282
.condpart701
	JMP skipalphadata73
alphadata73
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $38)
 .byte (<atascii + $3e)
skipalphadata73
    lda #<alphadata73
    sta temp1

    lda #>alphadata73
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02282
.L02283 ;  if livesvalue = 9 then plotchars 'Lives^^^^^^<9@' 2 42 20

	LDA livesvalue
	CMP #9
     BNE .skipL02283
.condpart702
	JMP skipalphadata74
alphadata74
 .byte (<atascii + $4c)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $39)
 .byte (<atascii + $40)
skipalphadata74
    lda #<alphadata74
    sta temp1

    lda #>alphadata74
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #20

    sta temp5

 jsr plotcharacters
.skipL02283
.
 ; 

.L02284 ;  if arrowsvalue = 1 then plotchars 'Max^Arrows^?1>' 2 42 19 : rem 152

	LDA arrowsvalue
	CMP #1
     BNE .skipL02284
.condpart703
	JMP skipalphadata75
alphadata75
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $31)
 .byte (<atascii + $3e)
skipalphadata75
    lda #<alphadata75
    sta temp1

    lda #>alphadata75
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19
    sta temp5

 jsr plotcharacters
.skipL02284
.L02285 ;  if arrowsvalue = 2 then plotchars 'Max^Arrows^<2>' 2 42 19

	LDA arrowsvalue
	CMP #2
     BNE .skipL02285
.condpart704
	JMP skipalphadata76
alphadata76
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $32)
 .byte (<atascii + $3e)
skipalphadata76
    lda #<alphadata76
    sta temp1

    lda #>alphadata76
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02285
.L02286 ;  if arrowsvalue = 3 then plotchars 'Max^Arrows^<3>' 2 42 19

	LDA arrowsvalue
	CMP #3
     BNE .skipL02286
.condpart705
	JMP skipalphadata77
alphadata77
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $33)
 .byte (<atascii + $3e)
skipalphadata77
    lda #<alphadata77
    sta temp1

    lda #>alphadata77
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02286
.L02287 ;  if arrowsvalue = 4 then plotchars 'Max^Arrows^<4>' 2 42 19

	LDA arrowsvalue
	CMP #4
     BNE .skipL02287
.condpart706
	JMP skipalphadata78
alphadata78
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $34)
 .byte (<atascii + $3e)
skipalphadata78
    lda #<alphadata78
    sta temp1

    lda #>alphadata78
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02287
.
 ; 

.L02288 ;  if arrowsvalue = 5 then plotchars 'Max^Arrows^<5>' 2 42 19

	LDA arrowsvalue
	CMP #5
     BNE .skipL02288
.condpart707
	JMP skipalphadata79
alphadata79
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $35)
 .byte (<atascii + $3e)
skipalphadata79
    lda #<alphadata79
    sta temp1

    lda #>alphadata79
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02288
.L02289 ;  if arrowsvalue = 6 then plotchars 'Max^Arrows^<6>' 2 42 19

	LDA arrowsvalue
	CMP #6
     BNE .skipL02289
.condpart708
	JMP skipalphadata80
alphadata80
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $36)
 .byte (<atascii + $3e)
skipalphadata80
    lda #<alphadata80
    sta temp1

    lda #>alphadata80
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02289
.L02290 ;  if arrowsvalue = 7 then plotchars 'Max^Arrows^<7>' 2 42 19

	LDA arrowsvalue
	CMP #7
     BNE .skipL02290
.condpart709
	JMP skipalphadata81
alphadata81
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $37)
 .byte (<atascii + $3e)
skipalphadata81
    lda #<alphadata81
    sta temp1

    lda #>alphadata81
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02290
.L02291 ;  if arrowsvalue = 8 then plotchars 'Max^Arrows^<8>' 2 42 19

	LDA arrowsvalue
	CMP #8
     BNE .skipL02291
.condpart710
	JMP skipalphadata82
alphadata82
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $38)
 .byte (<atascii + $3e)
skipalphadata82
    lda #<alphadata82
    sta temp1

    lda #>alphadata82
    sta temp2

    lda #18 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02291
.L02292 ;  if arrowsvalue = 9 then plotchars 'Max^Arrows^<No^Max@' 2 42 19

	LDA arrowsvalue
	CMP #9
     BNE .skipL02292
.condpart711
	JMP skipalphadata83
alphadata83
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $6f)
 .byte (<atascii + $77)
 .byte (<atascii + $73)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $4e)
 .byte (<atascii + $6f)
 .byte (<atascii + $20)
 .byte (<atascii + $4d)
 .byte (<atascii + $61)
 .byte (<atascii + $78)
 .byte (<atascii + $40)
skipalphadata83
    lda #<alphadata83
    sta temp1

    lda #>alphadata83
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #19

    sta temp5

 jsr plotcharacters
.skipL02292
.
 ; 

.skipmenu
 ; skipmenu

.
 ; 

.L02293 ;  if scorevalue = 1  &&  gamemode = 1 then plotchars 'Score^^^^^^?00000>' 2 42 22

	LDA scorevalue
	CMP #1
     BNE .skipL02293
.condpart712
	LDA gamemode
	CMP #1
     BNE .skip712then
.condpart713
	JMP skipalphadata84
alphadata84
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $3e)
skipalphadata84
    lda #<alphadata84
    sta temp1

    lda #>alphadata84
    sta temp2

    lda #14 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #22

    sta temp5

 jsr plotcharacters
.skip712then
.skipL02293
.L02294 ;  if scorevalue = 2  &&  gamemode = 1 then plotchars 'Score^^^^^^?07400>' 2 42 22

	LDA scorevalue
	CMP #2
     BNE .skipL02294
.condpart714
	LDA gamemode
	CMP #1
     BNE .skip714then
.condpart715
	JMP skipalphadata85
alphadata85
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $30)
 .byte (<atascii + $37)
 .byte (<atascii + $34)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $3e)
skipalphadata85
    lda #<alphadata85
    sta temp1

    lda #>alphadata85
    sta temp2

    lda #14 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #22

    sta temp5

 jsr plotcharacters
.skip714then
.skipL02294
.L02295 ;  if scorevalue = 3  &&  gamemode = 1 then plotchars 'Score^^^^^^?14900>' 2 42 22

	LDA scorevalue
	CMP #3
     BNE .skipL02295
.condpart716
	LDA gamemode
	CMP #1
     BNE .skip716then
.condpart717
	JMP skipalphadata86
alphadata86
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $31)
 .byte (<atascii + $34)
 .byte (<atascii + $39)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $3e)
skipalphadata86
    lda #<alphadata86
    sta temp1

    lda #>alphadata86
    sta temp2

    lda #14 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #22

    sta temp5

 jsr plotcharacters
.skip716then
.skipL02295
.L02296 ;  if scorevalue = 4  &&  gamemode = 1 then plotchars 'Score^^^^^^?29900>' 2 42 22

	LDA scorevalue
	CMP #4
     BNE .skipL02296
.condpart718
	LDA gamemode
	CMP #1
     BNE .skip718then
.condpart719
	JMP skipalphadata87
alphadata87
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $32)
 .byte (<atascii + $39)
 .byte (<atascii + $39)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $3e)
skipalphadata87
    lda #<alphadata87
    sta temp1

    lda #>alphadata87
    sta temp2

    lda #14 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #22

    sta temp5

 jsr plotcharacters
.skip718then
.skipL02296
.L02297 ;  if scorevalue = 5  &&  gamemode = 1 then plotchars 'Score^^^^^^<59900@' 2 42 22

	LDA scorevalue
	CMP #5
     BNE .skipL02297
.condpart720
	LDA gamemode
	CMP #1
     BNE .skip720then
.condpart721
	JMP skipalphadata88
alphadata88
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $35)
 .byte (<atascii + $39)
 .byte (<atascii + $39)
 .byte (<atascii + $30)
 .byte (<atascii + $30)
 .byte (<atascii + $40)
skipalphadata88
    lda #<alphadata88
    sta temp1

    lda #>alphadata88
    sta temp2

    lda #14 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #22

    sta temp5

 jsr plotcharacters
.skip720then
.skipL02297
.
 ; 

.L02298 ;  rem ** enter the current score and high score data into the score0 and score1 variables

.L02299 ;  sc1 = High_Score01 : sc2 = High_Score02 : sc3 = High_Score03

	LDA High_Score01
	STA sc1
	LDA High_Score02
	STA sc2
	LDA High_Score03
	STA sc3
.L02300 ;  sc4 = Save_Score01 : sc5 = Save_Score02 : sc6 = Save_Score03

	LDA Save_Score01
	STA sc4
	LDA Save_Score02
	STA sc5
	LDA Save_Score03
	STA sc6
.
 ; 

.skipscoredisplay
 ; skipscoredisplay

.
 ; 

.L02301 ;  rem ** Note that 23 is the last visible line to plot characters

.
 ; 

.L02302 ;  rem ** debounce routine for pressing fire to exit the titlescreen

.L02303 ;  if fireheld = 1  &&  !joy0fire then fireheld = 0

	LDA fireheld
	CMP #1
     BNE .skipL02303
.condpart722
 bit sINPT1
	BMI .skip722then
.condpart723
	LDA #0
	STA fireheld
.skip722then
.skipL02303
.
 ; 

.L02304 ;  rem ** start the game if you're on the 'start game' menu line and press the fire button

.L02305 ;  rem ** there are two entries due to the fact that the start game line is on a different Y coordinate in dev mode

.L02306 ;  if gamemode = 0  &&  fireheld = 0  &&  joy0fire  &&  menubary = 144 then goto preinit

	LDA gamemode
	CMP #0
     BNE .skipL02306
.condpart724
	LDA fireheld
	CMP #0
     BNE .skip724then
.condpart725
 bit sINPT1
	BPL .skip725then
.condpart726
	LDA menubary
	CMP #144
     BNE .skip726then
.condpart727
 jmp .preinit

.skip726then
.skip725then
.skip724then
.skipL02306
.L02307 ;  if gamemode = 1  &&  fireheld = 0  &&  joy0fire  &&  menubary > 179 then goto preinit

	LDA gamemode
	CMP #1
     BNE .skipL02307
.condpart728
	LDA fireheld
	CMP #0
     BNE .skip728then
.condpart729
 bit sINPT1
	BPL .skip729then
.condpart730
	LDA #179
	CMP menubary
     BCS .skip730then
.condpart731
 jmp .preinit

.skip730then
.skip729then
.skip728then
.skipL02307
.
 ; 

.L02308 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L02309 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L02310 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L02311 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L02312 ;  rem ** so you'll have to experiment with their location in your own code.

.L02313 ;  dmahole 3

 jmp dmahole_3
 echo "  ","  ","  ","  ",[($A000 - .)]d , "bytes of ROM space left in DMA hole 1."

 ORG $A000  ; *************

spd1top
       HEX 0eb8
spd2top
       HEX 0eb8
spd3top
       HEX 0eb8
spd4top
       HEX 0eb8
spd1bot
       HEX 0220
spd2bot
       HEX 1100
spd3bot
       HEX 0220
spd4bot
       HEX 0044
lives
       HEX fb1c7df0
level
       HEX fbe38fbe
score
       HEX fbefdbbe
arrows
       HEX cdbb77ec
       HEX 6f80
man
       HEX 63
blackbox
       HEX ff
level1
       HEX 7e
level2
       HEX 7e
level3
       HEX 7e
level4
       HEX 06
level5
       HEX 7e
level6
       HEX 7e
level7
       HEX 18
level8
       HEX 7e
level9
       HEX 7e
gameovertext
       HEX fd9b1bf1f8e3f6e0
arrow
       HEX 00
arrow2
       HEX 00
arrow_large
       HEX 00
widebar_top_broken
       HEX ff800001ff
widebar
       HEX ff8000
       HEX 01ff
widebar_top
       HEX ff800001ff
widebar_bottom
       HEX 0000000000
tsbanner00
       HEX 00000000000000000000000000000003ffe00000
       HEX 000000000000000000000000
tsbanner01
       HEX 00000000000000000000000000000000ff800000
       HEX 000000000000000000000000
tsbanner02
       HEX 0000000000000007e0000000001e00007f00003c
       HEX 0000000001f0000000000000
tsbanner03
       HEX 00000000000000001f803ff003040000ff800008
       HEX 6003fe00fc00000000000000
tsbanner04
       HEX 0000000000000033fe1ffc01ff07800ffff800f0
       HEX 7fc01ffc3fe6000000000000

 ORG $A100  ; *************

;spd1top
       HEX 03e0
;spd2top
       HEX 33e0
;spd3top
       HEX 03e0
;spd4top
       HEX 03e6
;spd1bot
       HEX 2412
;spd2bot
       HEX 2220
;spd3bot
       HEX 2412
;spd4bot
       HEX 0222
;lives
       HEX fb3e7df0
;level
       HEX fbe7cfbe
;score
       HEX fbefdb3e
;arrows
       HEX cdb367ee
       HEX ef80
;man
       HEX 1e
;blackbox
       HEX ff
;level1
       HEX 7e
;level2
       HEX 7e
;level3
       HEX 7e
;level4
       HEX 06
;level5
       HEX 7e
;level6
       HEX 7e
;level7
       HEX 18
;level8
       HEX 7e
;level9
       HEX 7e
;gameovertext
       HEX fd9b1bf1f9f3f6c0
;arrow
       HEX 00
;arrow2
       HEX 00
;arrow_large
       HEX 00
;widebar_top_broken
       HEX ffc00003ff
;widebar
       HEX ff8000
       HEX 01ff
;widebar_top
       HEX ffc00003ff
;widebar_bottom
       HEX 1ffffffff8
;tsbanner00
       HEX 00000000000000000000000000000003ffe00000
       HEX 000000000000000000000000
;tsbanner01
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner02
       HEX 0000000000000000c0000000000c00007f000018
       HEX 000000000180000000000000
;tsbanner03
       HEX 00000000000000003f0007e0000f00007f80007c
       HEX 0003f8007e00000000000000
;tsbanner04
       HEX 00000000000000007ffff8007e03800ffff800e0
       HEX 3f000fffff00000000000000

 ORG $A200  ; *************

;spd1top
       HEX 3ebe
;spd2top
       HEX 6eb8
;spd3top
       HEX 3ebe
;spd4top
       HEX 0ebb
;spd1bot
       HEX 4411
;spd2bot
       HEX 2214
;spd3bot
       HEX 4411
;spd4bot
       HEX 1422
;lives
       HEX c3776030
;level
       HEX c30eec30
;score
       HEX 1b0cde30
;arrows
       HEX fde3c66f
       HEX e180
;man
       HEX 00
;blackbox
       HEX ff
;level1
       HEX 18
;level2
       HEX 60
;level3
       HEX 06
;level4
       HEX 06
;level5
       HEX 06
;level6
       HEX 66
;level7
       HEX 18
;level8
       HEX 66
;level9
       HEX 06
;gameovertext
       HEX cdfb1b019bbb0780
;arrow
       HEX 00
;arrow2
       HEX 00
;arrow_large
       HEX 00
;widebar_top_broken
       HEX 7fffffffff
;widebar
       HEX ffffff
       HEX ffff
;widebar_top
       HEX ffffffffff
;widebar_bottom
       HEX 3ffffffffc
;tsbanner00
       HEX 0000000000000000000000000000000ffff80000
       HEX 000000000000000000000000
;tsbanner01
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner02
       HEX 00000000000000000000000000000000ff800000
       HEX 000000000000000000000000
;tsbanner03
       HEX 00000000000000007e0003c0001fe0007f8007fe
       HEX 0000e0003f00000000000000
;tsbanner04
       HEX 00000000000000000fff00001e03c00ffff801e0
       HEX 1c00007ffc00000000000000

 ORG $A300  ; *************

;spd1top
       HEX 6d5b
;spd2top
       HEX 6d54
;spd3top
       HEX 6d5b
;spd4top
       HEX 155b
;spd1bot
       HEX 4c19
;spd2bot
       HEX 2612
;spd3bot
       HEX 4c19
;spd4bot
       HEX 2432
;lives
       HEX c36379f0
;level
       HEX c3cc6f30
;score
       HEX fb0cdf3c
;arrows
       HEX fdf3e66f
       HEX ef80
;man
       HEX 5f
;blackbox
       HEX ff
;level1
       HEX 18
;level2
       HEX 7e
;level3
       HEX 7e
;level4
       HEX 7e
;level5
       HEX 7e
;level6
       HEX 7e
;level7
       HEX 18
;level8
       HEX 7e
;level9
       HEX 7e
;gameovertext
       HEX cdfb5bc19b1bc7c0
;arrow
       HEX 00
;arrow2
       HEX 00
;arrow_large
       HEX 00
;widebar_top_broken
       HEX 7fbedff9ff
;widebar
       HEX ffffff
       HEX ffff
;widebar_top
       HEX ffffffffff
;widebar_bottom
       HEX 7ffffffffe
;tsbanner00
       HEX 0000000000000000000000000000000ffff80000
       HEX 000000000000000000000000
;tsbanner01
       HEX 00000000000000000000000000000001ffc00000
       HEX 000000000000000000000000
;tsbanner02
       HEX 00000000000000000000000000000000ff800000
       HEX 000000000000000000000000
;tsbanner03
       HEX 0000000000000001fc000380003ffffffffffffe
       HEX 000060001fc0000000000000
;tsbanner04
       HEX 000000000000000003fe00000e03e00ffff80ff0
       HEX 3c00001fe000000000000000

 ORG $A400  ; *************

;spd1top
       HEX 680b
;spd2top
       HEX 2816
;spd3top
       HEX 680b
;spd4top
       HEX 340a
;spd1bot
       HEX 4c99
;spd2bot
       HEX 269a
;spd3bot
       HEX 4c99
;spd4bot
       HEX 2cb2
;lives
       HEX c36379f0
;level
       HEX c3cc6f30
;score
       HEX fb0cdbbc
;arrows
       HEX cdbb766d
       HEX 6f80
;man
       HEX 7c
;blackbox
       HEX ff
;level1
       HEX 18
;level2
       HEX 7e
;level3
       HEX 7e
;level4
       HEX 7e
;level5
       HEX 7e
;level6
       HEX 7e
;level7
       HEX 0c
;level8
       HEX 7e
;level9
       HEX 7e
;gameovertext
       HEX c19bfbc19b1bc6e0
;arrow
       HEX 00
;arrow2
       HEX 00
;arrow_large
       HEX f0
;widebar_top_broken
       HEX 7f1486c0f7
;widebar
       HEX ffffff
       HEX ffff
;widebar_top
       HEX 7ffffffffe
;widebar_bottom
       HEX 7ffffffffe
;tsbanner00
       HEX 0000000000000000000000000000000e00380000
       HEX 000000000000000000000000
;tsbanner01
       HEX 00000000000000000000000000000001ffc00000
       HEX 000000000000000000000000
;tsbanner02
       HEX 00000000000000000000000000000000ff800000
       HEX 000000000000000000000000
;tsbanner03
       HEX 0000000000000003f8000000003ffffffffffffe
       HEX 000000000fe0000000000000
;tsbanner04
       HEX 000000000000000003ff80000f07ffeffff9fff8
       HEX 7800007fe000000000000000

 ORG $A500  ; *************

;spd1top
       HEX 280a
;spd2top
       HEX 2416
;spd3top
       HEX 280a
;spd4top
       HEX 3412
;spd1bot
       HEX 4dd9
;spd2bot
       HEX 25da
;spd3bot
       HEX 4dd9
;spd4bot
       HEX 2dd2
;lives
       HEX c3636180
;level
       HEX c30c6c30
;score
       HEX c30cd9b0
;arrows
       HEX cd9b366c
       HEX 6c00
;man
       HEX 00
;blackbox
       HEX ff
;level1
       HEX 18
;level2
       HEX 06
;level3
       HEX 06
;level4
       HEX 66
;level5
       HEX 60
;level6
       HEX 60
;level7
       HEX 06
;level8
       HEX 66
;level9
       HEX 66
;gameovertext
       HEX c19bfb019b1b0660
;arrow
       HEX 00
;arrow2
       HEX 00
;arrow_large
       HEX f0
;widebar_top_broken
       HEX 37000000f6
;widebar
       HEX ffffff
       HEX ffff
;widebar_top
       HEX 7ffffffffe
;widebar_bottom
       HEX ffffffffff
;tsbanner00
       HEX 0000000000000000000000000000000e00380000
       HEX 000000000000000000000000
;tsbanner01
       HEX 00000000000000000000000000000001ffc00000
       HEX 000000000000000000000000
;tsbanner02
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner03
       HEX 0000000000000007f8000000003ffffffffffffe
       HEX 0000000007f0000000000000
;tsbanner04
       HEX 000000000000000001fff00007fffffffffbffff
       HEX f00003ffe000000000000000

 ORG $A600  ; *************

;spd1top
       HEX 2412
;spd2top
       HEX 1024
;spd3top
       HEX 2412
;spd4top
       HEX 1204
;spd1bot
       HEX 65d3
;spd2bot
       HEX 15da
;spd3bot
       HEX 65d3
;spd4bot
       HEX 2dd4
;lives
       HEX c3637df0
;level
       HEX c3ec6fb0
;score
       HEX fbefdfbe
;arrows
       HEX fdfbf7ec
       HEX 6f80
;man
       HEX 06
;blackbox
       HEX ff
;level1
       HEX 38
;level2
       HEX 7e
;level3
       HEX 7e
;level4
       HEX 66
;level5
       HEX 7e
;level6
       HEX 7e
;level7
       HEX 7e
;level8
       HEX 7e
;level9
       HEX 7e
;gameovertext
       HEX fdfbbbf1fb1bf7e0
;arrow
       HEX c0
;arrow2
       HEX c0
;arrow_large
       HEX f0
;widebar_top_broken
       HEX 1600000062
;widebar
       HEX ffffff
       HEX ffff
;widebar_top
       HEX 3fc00003fc
;widebar_bottom
       HEX ffffffffff
;tsbanner00
       HEX 0000000000000000000000000000000ffff80000
       HEX 000000000000000000000000
;tsbanner01
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner02
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner03
       HEX 000000000000001ff0000000001ffffffffffffe
       HEX 0000000007fe000000000000
;tsbanner04
       HEX 000000000000000003fffff007f007fffffbf807
       HEX f0063ffff000000000000000

 ORG $A700  ; *************

;spd1top
       HEX 1004
;spd2top
       HEX 0048
;spd3top
       HEX 1004
;spd4top
       HEX 0900
;spd1bot
       HEX 15d4
;spd2bot
       HEX 15d6
;spd3bot
       HEX 15d4
;spd4bot
       HEX 35d4
;lives
       HEX c3637df0
;level
       HEX c3ec6fb0
;score
       HEX fbefdfbe
;arrows
       HEX fdfbf7ec
       HEX 6f80
;man
       HEX 06
;blackbox
       HEX ff
;level1
       HEX 38
;level2
       HEX 7e
;level3
       HEX 7e
;level4
       HEX 66
;level5
       HEX 7e
;level6
       HEX 7e
;level7
       HEX 7e
;level8
       HEX 7e
;level9
       HEX 7e
;gameovertext
       HEX fdfb1bf1fb1bf7e0
;arrow
       HEX c0
;arrow2
       HEX c0
;arrow_large
       HEX f0
;widebar_top_broken
       HEX 0000000000
;widebar
       HEX ff8000
       HEX 01ff
;widebar_top
       HEX 1f800001f8
;widebar_bottom
       HEX ffc00003ff
;tsbanner00
       HEX 0000000000000000000000000000000ffff80000
       HEX 000000000000000000000000
;tsbanner01
       HEX 000000000000000000000000000000007f000000
       HEX 000000000000000000000000
;tsbanner02
       HEX 00000000000000000000000000000000ff800000
       HEX 000000000000000000000000
;tsbanner03
       HEX 000000000000001fe0000000001f8000ff8000fe
       HEX 0000000003fc000000000000
;tsbanner04
       HEX 00000000000000000fc0fff003c00003ffe00001
       HEX e007ff81f800000000000000

 ORG $A800  ; *************
dmahole_2
.
 ; 

.L02190 ;  rem ** this plots the background behind the titlescreen graphic text

.L02191 ;  plotsprite ts_back1 7 16 52

    lda #<ts_back1
    sta temp1

    lda #>ts_back1
    sta temp2

    lda #(224|ts_back1_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #52

    sta temp5

    lda #(ts_back1_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02192 ;  plotsprite ts_back2 7 16 60

    lda #<ts_back2
    sta temp1

    lda #>ts_back2
    sta temp2

    lda #(224|ts_back2_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #60

    sta temp5

    lda #(ts_back2_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02193 ;  plotsprite ts_back3 7 16 68

    lda #<ts_back3
    sta temp1

    lda #>ts_back3
    sta temp2

    lda #(224|ts_back3_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #68

    sta temp5

    lda #(ts_back3_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02194 ;  plotsprite ts_back4 7 16 76

    lda #<ts_back4
    sta temp1

    lda #>ts_back4
    sta temp2

    lda #(224|ts_back4_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #76

    sta temp5

    lda #(ts_back4_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02195 ;  plotsprite ts_back5 7 16 84

    lda #<ts_back5
    sta temp1

    lda #>ts_back5
    sta temp2

    lda #(224|ts_back5_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #84

    sta temp5

    lda #(ts_back5_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02196 ;  plotsprite ts_back6 7 16 92

    lda #<ts_back6
    sta temp1

    lda #>ts_back6
    sta temp2

    lda #(224|ts_back6_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #92

    sta temp5

    lda #(ts_back6_mode|%01000000)
    sta temp6

 jsr plotsprite
.L02197 ;  plotsprite ts_back7 7 16 100

    lda #<ts_back7
    sta temp1

    lda #>ts_back7
    sta temp2

    lda #(224|ts_back7_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #100

    sta temp5

    lda #(ts_back7_mode|%01000000)
    sta temp6

 jsr plotsprite
.
 ; 

.L02198 ;  rem ** This creates the dots at the top of the titlescreen graphic

.L02199 ;  plotsprite ts_back_ruby 6 16 38

    lda #<ts_back_ruby
    sta temp1

    lda #>ts_back_ruby
    sta temp2

    lda #(192|ts_back_ruby_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #38

    sta temp5

    lda #(ts_back_ruby_mode|%01000000)
    sta temp6

 jsr plotsprite
.
 ; 

.L02200 ;  rem ** this plots the titlescreen graphic, which is 256x128, split into 8 pixel tall sprites

.L02201 ;  rem ** (changed to a banner)

.L02202 ;  plotbanner tsbanner 3 16 4

    lda #(96|tsbanner00_width_twoscompliment)
    sta temp3

    lda #16
    sta temp4

    lda #4

    sta temp5

    lda #(tsbanner00_mode|%01000000)
    sta temp6

    lda #<tsbanner00
    sta temp1

    lda #>tsbanner00
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner01
    sta temp1

    lda #>tsbanner01
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner02
    sta temp1

    lda #>tsbanner02
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner03
    sta temp1

    lda #>tsbanner03
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner04
    sta temp1

    lda #>tsbanner04
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner05
    sta temp1

    lda #>tsbanner05
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner06
    sta temp1

    lda #>tsbanner06
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner07
    sta temp1

    lda #>tsbanner07
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner08
    sta temp1

    lda #>tsbanner08
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner09
    sta temp1

    lda #>tsbanner09
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner10
    sta temp1

    lda #>tsbanner10
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner11
    sta temp1

    lda #>tsbanner11
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner12
    sta temp1

    lda #>tsbanner12
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner13
    sta temp1

    lda #>tsbanner13
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner14
    sta temp1

    lda #>tsbanner14
    sta temp2

 jsr plotsprite
    clc
    lda #8
    adc temp5
    sta temp5
    lda #<tsbanner15
    sta temp1

    lda #>tsbanner15
    sta temp2

 jsr plotsprite
.
 ; 

.L02203 ;  rem ** The savescreen command saves any sprites and characters that you've drawn on the screen since the last clearscreen.

.L02204 ;  savescreen

 jsr savescreen
.
 ; 

.titlescreen2
 ; titlescreen2

.
 ; 

.L02205 ;  rem ** beats me.  This code makes no sense. :)

.L02206 ;  if skill <> 4 then goto devcheckdone

	LDA skill
	CMP #4
     BEQ .skipL02206
.condpart668
 jmp .devcheckdone

.skipL02206
.L02207 ;  rem ** Enable dev mode.  It's a super secret entry code. It enables the holy grail of game options.

.L02208 ;  rem ** If you've read this much of the code already I bet you can figure it out! :)

.L02209 ;  if devmodecount = $ff then goto devcheckdone  :  rem ** code entry is disabled.

	LDA devmodecount
	CMP #$ff
     BNE .skipL02209
.condpart669
 jmp .devcheckdone
.skipL02209
.L02210 ;  temp1 = SWCHA | $0f :  rem ** set temp variable to read joystick position

	LDA SWCHA
	ORA #$0f
	STA temp1
.L02211 ;  if temp1 = savejoy then goto devcheckdone  :  rem ** debounce

	LDA temp1
	CMP savejoy
     BNE .skipL02211
.condpart670
 jmp .devcheckdone
.skipL02211
.L02212 ;  savejoy = temp1 :  rem ** set savejoy to equal temp1

	LDA temp1
	STA savejoy
.L02213 ;  if savejoy = $ff then goto devcheckdone  :  rem ** neutral position

	LDA savejoy
	CMP #$ff
     BNE .skipL02213
.condpart671
 jmp .devcheckdone
.skipL02213
.L02214 ;  if savejoy <> devmodecode[devmodecount] then devmodecount = $ff  :  goto devcheckdone  :  rem ** wrong code. disable code entry after 1 attempt.

	LDA savejoy
	LDX devmodecount
	CMP devmodecode,x
     BEQ .skipL02214
.condpart672
	LDA #$ff
	STA devmodecount
 jmp .devcheckdone
.skipL02214
.L02215 ;  devmodecount =  ( devmodecount + 1 )  & 7 :  rem ** hmmmm, what does this do? ;)

; complex statement detected
	LDA devmodecount
	CLC
	ADC #1
	AND #7
	STA devmodecount
.L02216 ;  if devmodecount = 0 then devmodeenabled = 1 :  rem ** this must enable something?

	LDA devmodecount
	CMP #0
     BNE .skipL02216
.condpart673
	LDA #1
	STA devmodeenabled
.skipL02216
.devcheckdone
 ; devcheckdone

.
 ; 

.L02217 ;  rem ** enter developer mode

.L02218 ;  if devmodeenabled = 1  &&  joy0fire then playsfx sfx_wizwarp : gamemode = 1

	LDA devmodeenabled
	CMP #1
     BNE .skipL02218
.condpart674
 bit sINPT1
	BPL .skip674then
.condpart675
    lda #<sfx_wizwarp
    sta temp1
    lda #>sfx_wizwarp
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA gamemode
.skip674then
.skipL02218
.
 ; 

.L02219 ;  rem ** don't allow skill value to be out of range

.L02220 ;  rem ** if it is, set the skill level to the standard difficulty setting

.L02221 ;  if skill < 1 then skill = 2

	LDA skill
	CMP #1
     BCS .skipL02221
.condpart676
	LDA #2
	STA skill
.skipL02221
.L02222 ;  if skill > 4 then skill = 2

	LDA #4
	CMP skill
     BCS .skipL02222
.condpart677
	LDA #2
	STA skill
.skipL02222
.
 ; 

.L02223 ;  rem ** The restorescreen erases any sprites and characters that you've drawn on the screen since the last savescreen.

.L02224 ;  restorescreen

 jsr restorescreen
.
 ; 

.L02225 ;  rem ** this makes the dots on the titlescreen image flash.  They are supposed to look like gems.

.L02226 ;  colorflasher = colorflasher + $02 : if colorflasher > $FE then colorflasher = $00

	LDA colorflasher
	CLC
	ADC #$02
	STA colorflasher
	LDA #$FE
	CMP colorflasher
     BCS .skipL02226
.condpart678
	LDA #$00
	STA colorflasher
.skipL02226
.L02227 ;  P6C2 = colorflasher

	LDA colorflasher
	STA P6C2
.
 ; 

.L02228 ;  rem ** plot the background sprite for highlighting the current menu option

.L02229 ;  plotsprite menuback1 4 menubarx menubary

    lda #<menuback1
    sta temp1

    lda #>menuback1
    sta temp2

    lda #(128|menuback1_width_twoscompliment)
    sta temp3

    lda menubarx
    sta temp4

    lda menubary

    sta temp5

    lda #(menuback1_mode|%01000000)
    sta temp6

 jsr plotsprite
.
 ; 

.L02230 ;  rem ** plot the menu values based on current selection

.
 ; 

.L02231 ;  rem ** if gamemode=1 then developer mode is activated.  Skip the normal menu.

.L02232 ;  if gamemode = 1 then goto skipnormalmenu

	LDA gamemode
	CMP #1
     BNE .skipL02232
.condpart679
 jmp .skipnormalmenu

.skipL02232
.
 ; 

.L02233 ;  rem ** Skill Levels

.L02234 ;  rem      skill 1 = Novice

.L02235 ;  rem      skill 2 = Standard

.L02236 ;  rem      skill 3 = Advanced

.L02237 ;  rem      skill 4 = Expert

.
 ; 

.L02238 ;  rem ** Note that '?' was changed to a left arrow and '@' was changed to a right arrow in a customized atascii.png

.L02239 ;  rem **   Also, '=' was changed to a dot.

.L02240 ;  if skill = 1 then plotchars 'Skill^^^^^^?Novice>' 2 42 16 : gamedifficulty = 0 : plotchars '=Novice^High^Scores' 2 42 17

	LDA skill
	CMP #1
     BNE .skipL02240
.condpart680
	JMP skipalphadata42
alphadata42
 .byte (<atascii + $53)
 .byte (<atascii + $6b)
 .byte (<atascii + $69)
 .byte (<atascii + $6c)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3f)
 .byte (<atascii + $4e)
 .byte (<atascii + $6f)
 .byte (<atascii + $76)
 .byte (<atascii + $69)
 .byte (<atascii + $63)
 .byte (<atascii + $65)
 .byte (<atascii + $3e)
skipalphadata42
    lda #<alphadata42
    sta temp1

    lda #>alphadata42
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #16
    sta temp5

 jsr plotcharacters
	LDA #0
	STA gamedifficulty
	JMP skipalphadata43
alphadata43
 .byte (<atascii + $3d)
 .byte (<atascii + $4e)
 .byte (<atascii + $6f)
 .byte (<atascii + $76)
 .byte (<atascii + $69)
 .byte (<atascii + $63)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $48)
 .byte (<atascii + $69)
 .byte (<atascii + $67)
 .byte (<atascii + $68)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
skipalphadata43
    lda #<alphadata43
    sta temp1

    lda #>alphadata43
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17

    sta temp5

 jsr plotcharacters
.skipL02240
.L02241 ;  if skill = 2 then plotchars 'Skill^^^^^^<Standard>' 2 42 16 : gamedifficulty = 1 : plotchars '=Standard^High^Scores' 2 42 17

	LDA skill
	CMP #2
     BNE .skipL02241
.condpart681
	JMP skipalphadata44
alphadata44
 .byte (<atascii + $53)
 .byte (<atascii + $6b)
 .byte (<atascii + $69)
 .byte (<atascii + $6c)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $53)
 .byte (<atascii + $74)
 .byte (<atascii + $61)
 .byte (<atascii + $6e)
 .byte (<atascii + $64)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $64)
 .byte (<atascii + $3e)
skipalphadata44
    lda #<alphadata44
    sta temp1

    lda #>alphadata44
    sta temp2

    lda #11 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #16
    sta temp5

 jsr plotcharacters
	LDA #1
	STA gamedifficulty
	JMP skipalphadata45
alphadata45
 .byte (<atascii + $3d)
 .byte (<atascii + $53)
 .byte (<atascii + $74)
 .byte (<atascii + $61)
 .byte (<atascii + $6e)
 .byte (<atascii + $64)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $48)
 .byte (<atascii + $69)
 .byte (<atascii + $67)
 .byte (<atascii + $68)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
skipalphadata45
    lda #<alphadata45
    sta temp1

    lda #>alphadata45
    sta temp2

    lda #11 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17

    sta temp5

 jsr plotcharacters
.skipL02241
.L02242 ;  if skill = 3 then plotchars 'Skill^^^^^^<Advanced>' 2 42 16 : gamedifficulty = 2 : plotchars '=Advanced^High^Scores' 2 42 17

	LDA skill
	CMP #3
     BNE .skipL02242
.condpart682
	JMP skipalphadata46
alphadata46
 .byte (<atascii + $53)
 .byte (<atascii + $6b)
 .byte (<atascii + $69)
 .byte (<atascii + $6c)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $41)
 .byte (<atascii + $64)
 .byte (<atascii + $76)
 .byte (<atascii + $61)
 .byte (<atascii + $6e)
 .byte (<atascii + $63)
 .byte (<atascii + $65)
 .byte (<atascii + $64)
 .byte (<atascii + $3e)
skipalphadata46
    lda #<alphadata46
    sta temp1

    lda #>alphadata46
    sta temp2

    lda #11 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #16
    sta temp5

 jsr plotcharacters
	LDA #2
	STA gamedifficulty
	JMP skipalphadata47
alphadata47
 .byte (<atascii + $3d)
 .byte (<atascii + $41)
 .byte (<atascii + $64)
 .byte (<atascii + $76)
 .byte (<atascii + $61)
 .byte (<atascii + $6e)
 .byte (<atascii + $63)
 .byte (<atascii + $65)
 .byte (<atascii + $64)
 .byte (<atascii + $20)
 .byte (<atascii + $48)
 .byte (<atascii + $69)
 .byte (<atascii + $67)
 .byte (<atascii + $68)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
skipalphadata47
    lda #<alphadata47
    sta temp1

    lda #>alphadata47
    sta temp2

    lda #11 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17

    sta temp5

 jsr plotcharacters
.skipL02242
.L02243 ;  if skill = 4 then plotchars 'Skill^^^^^^<Expert@' 2 42 16 : gamedifficulty = 3 : plotchars '=Expert^High^Scores' 2 42 17

	LDA skill
	CMP #4
     BNE .skipL02243
.condpart683
	JMP skipalphadata48
alphadata48
 .byte (<atascii + $53)
 .byte (<atascii + $6b)
 .byte (<atascii + $69)
 .byte (<atascii + $6c)
 .byte (<atascii + $6c)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $20)
 .byte (<atascii + $3c)
 .byte (<atascii + $45)
 .byte (<atascii + $78)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $72)
 .byte (<atascii + $74)
 .byte (<atascii + $40)
skipalphadata48
    lda #<alphadata48
    sta temp1

    lda #>alphadata48
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #16
    sta temp5

 jsr plotcharacters
	LDA #3
	STA gamedifficulty
	JMP skipalphadata49
alphadata49
 .byte (<atascii + $3d)
 .byte (<atascii + $45)
 .byte (<atascii + $78)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $72)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $48)
 .byte (<atascii + $69)
 .byte (<atascii + $67)
 .byte (<atascii + $68)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
skipalphadata49
    lda #<alphadata49
    sta temp1

    lda #>alphadata49
    sta temp2

    lda #13 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #17

    sta temp5

 jsr plotcharacters
.skipL02243
.L02244 ;  plotchars '=Start^Game' 2 42 18

	JMP skipalphadata50
alphadata50
 .byte (<atascii + $3d)
 .byte (<atascii + $53)
 .byte (<atascii + $74)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $47)
 .byte (<atascii + $61)
 .byte (<atascii + $6d)
 .byte (<atascii + $65)
skipalphadata50
    lda #<alphadata50
    sta temp1

    lda #>alphadata50
    sta temp2

    lda #21 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #18

    sta temp5

 jsr plotcharacters
.
 ; 

.L02245 ;  rem ** plot current and best score text on title screen

.L02246 ;  plotchars 'Current^Score:' 5 44 21

	JMP skipalphadata51
alphadata51
 .byte (<atascii + $43)
 .byte (<atascii + $75)
 .byte (<atascii + $72)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $6e)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $3a)
skipalphadata51
    lda #<alphadata51
    sta temp1

    lda #>alphadata51
    sta temp2

    lda #18 ; width in two's complement
    ora #160 ; palette left shifted 5 bits
    sta temp3
    lda #44
    sta temp4

    lda #21

    sta temp5

 jsr plotcharacters
.L02247 ;  plotvalue atascii 2 score1 6 101 21

    lda #<atascii
    sta temp1

    lda #>atascii
    sta temp2

    lda charactermode
    sta temp9
    lda #(atascii_mode | %01100000)
    sta charactermode
    lda #26 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #101
    sta temp4

    lda #21
    sta temp5

    lda #6
    sta temp6

    lda #<score1
    sta temp7

    lda #>score1
    sta temp8

 jsr plotvalue
    lda temp9
    sta charactermode
.L02248 ;  plotchars 'Best^Score:' 5 50 23

	JMP skipalphadata52
alphadata52
 .byte (<atascii + $42)
 .byte (<atascii + $65)
 .byte (<atascii + $73)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $53)
 .byte (<atascii + $63)
 .byte (<atascii + $6f)
 .byte (<atascii + $72)
 .byte (<atascii + $65)
 .byte (<atascii + $3a)
skipalphadata52
    lda #<alphadata52
    sta temp1

    lda #>alphadata52
    sta temp2

    lda #21 ; width in two's complement
    ora #160 ; palette left shifted 5 bits
    sta temp3
    lda #50
    sta temp4

    lda #23

    sta temp5

 jsr plotcharacters
.L02249 ;  plotvalue atascii 2 score0 6 95 23

    lda #<atascii
    sta temp1

    lda #>atascii
    sta temp2

    lda charactermode
    sta temp9
    lda #(atascii_mode | %01100000)
    sta charactermode
    lda #26 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #95
    sta temp4

    lda #23
    sta temp5

    lda #6
    sta temp6

    lda #<score0
    sta temp7

    lda #>score0
    sta temp8

 jsr plotvalue
    lda temp9
    sta charactermode
.
 ; 

.skipnormalmenu
 ; skipnormalmenu

.
 ; 

.L02250 ;  rem ** skip developer mode menu options if dev mode is not activated

.L02251 ;  if gamemode = 0 then goto skipmenu

	LDA gamemode
	CMP #0
     BNE .skipL02251
.condpart684
 jmp .skipmenu

.skipL02251
.
 ; 

.L02252 ;  rem ** Developer Mode Menu.  It's super secret.  No one will ever find it. :)

.L02253 ;  rem **  ...developer mode is undocumented in the instruction manual

.L02254 ;  rem **  ...if it's active, high scores will not be saved

.
 ; 

.L02255 ;  plotchars '<Exit^Developer^Mode>' 2 42 16

	JMP skipalphadata53
alphadata53
 .byte (<atascii + $3c)
 .byte (<atascii + $45)
 .byte (<atascii + $78)
 .byte (<atascii + $69)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $44)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $6f)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $72)
 .byte (<atascii + $20)
 .byte (<atascii + $4d)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $65)
 .byte (<atascii + $3e)
skipalphadata53
    lda #<alphadata53
    sta temp1

    lda #>alphadata53
    sta temp2

    lda #11 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #16

    sta temp5

 jsr plotcharacters
.L02256 ;  plotchars '=Start^Game' 2 42 23

	JMP skipalphadata54
alphadata54
 .byte (<atascii + $3d)
 .byte (<atascii + $53)
 .byte (<atascii + $74)
 .byte (<atascii + $61)
 .byte (<atascii + $72)
 .byte (<atascii + $74)
 .byte (<atascii + $20)
 .byte (<atascii + $47)
 .byte (<atascii + $61)
 .byte (<atascii + $6d)
 .byte (<atascii + $65)
skipalphadata54
    lda #<alphadata54
    sta temp1

    lda #>alphadata54
    sta temp2

    lda #21 ; width in two's complement
    ora #64 ; palette left shifted 5 bits
    sta temp3
    lda #42
    sta temp4

    lda #23

    sta temp5

 jsr plotcharacters
.L02257 ;  plotchars '^Developer' 5 38 1

	JMP skipalphadata55
alphadata55
 .byte (<atascii + $20)
 .byte (<atascii + $44)
 .byte (<atascii + $65)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
 .byte (<atascii + $6c)
 .byte (<atascii + $6f)
 .byte (<atascii + $70)
 .byte (<atascii + $65)
 .byte (<atascii + $72)
skipalphadata55
    lda #<alphadata55
    sta temp1

    lda #>alphadata55
    sta temp2

    lda #22 ; width in two's complement
    ora #160 ; palette left shifted 5 bits
    sta temp3
    lda #38
    sta temp4

    lda #1

    sta temp5

 jsr plotcharacters
.L02258 ;  plotchars 'Mode^Active' 5 87 1

	JMP skipalphadata56
alphadata56
 .byte (<atascii + $4d)
 .byte (<atascii + $6f)
 .byte (<atascii + $64)
 .byte (<atascii + $65)
 .byte (<atascii + $20)
 .byte (<atascii + $41)
 .byte (<atascii + $63)
 .byte (<atascii + $74)
 .byte (<atascii + $69)
 .byte (<atascii + $76)
 .byte (<atascii + $65)
skipalphadata56
    lda #<alphadata56
    sta temp1

    lda #>alphadata56
    sta temp2

    lda #21 ; width in two's complement
    ora #160 ; palette left shifted 5 bits
    sta temp3
    lda #87
    sta temp4

    lda #1

    sta temp5

 jsr plotcharacters
.
 ; 

.L02259 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L02260 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L02261 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L02262 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L02263 ;  rem ** so you'll have to experiment with their location in your own code.

.L02264 ;  dmahole 1

 jmp dmahole_1
 echo "  ","  ","  ","  ",[($B000 - .)]d , "bytes of ROM space left in DMA hole 2."

 ORG $B000  ; *************

tsbanner05
       HEX 000000000003fffffffffffffffffffffffffffffffffffffffffff000000000
       HEX 
tsbanner06
       HEX 0000007ff0000000000000000000000000000000000000000000000007ff8000
       HEX 
tsbanner07
       HEX 0000000ff01ff7f3ffa7f17fd7ffc7ebfcff0bfc04fe08ff3ffe02fc07fc0000
       HEX 
tsbanner08
       HEX 000003fc003ff000bfebffff8fe93febff87dbfffe7fe3fc7f93feff001ff000
       HEX 
tsbanner09
       HEX 0000007f803ffffffcffffbffff8fffc9fc009fc1fe3ffe3fffc13fe00ff0000
       HEX 
tsbanner10
       HEX 00000003fc0000000007ffc2fe0bffff5fd005fff80bf84bfff800000fe00000
       HEX 
tsbanner11
       HEX 0000000001ffe00000000004000000000000000000000000000001ffe0000000
       HEX 
tsbanner12
       HEX 000000000000000000000000001fffffc1fffff8000000000000000000000000

 ORG $B100  ; *************

;tsbanner05
       HEX 0000000000000ffffffffffffffffffffffffffffffffffffffff80000000000
       HEX 
;tsbanner06
       HEX 0000007ffe00000000000000000000000000000000000000000000001fff8000
       HEX 
;tsbanner07
       HEX 00000007f01ff00fff4ff17fd7ff97ebfe006bfc02ff39fe7ffe02fc07f80000
       HEX 
;tsbanner08
       HEX 000007f8007ff000bfebf8ff9fea7febfe17cbfc00ff09fe3fa7fcff001ff000
       HEX 
;tsbanner09
       HEX 0000007f803ffffffe7fffbffff87ff93fe01bfe3ff7ffe7fff827fe00ff8000
       HEX 
;tsbanner10
       HEX 00000007f8000000003fffc2fe0bffff5fd005fff00bffcbfff000000ff00000
       HEX 
;tsbanner11
       HEX 0000000007ffe000031ff83dff27e0dfbfffdbff07f3fffbf0dfc1fff0000000
       HEX 
;tsbanner12
       HEX 00000000000003ffe00000001ffffffe003ffffffc0000001ffffc0000000000

 ORG $B200  ; *************

;tsbanner05
       HEX 0000000000000000ffffffffffffffffffffffffffffffffff80000000000000
       HEX 
;tsbanner06
       HEX 0000003fffe000000000000000000000000000000000000000000001ffff0000
       HEX 
;tsbanner07
       HEX 00000007f01ffffffe9ff17fd7ff17ebffffebfc007f87fc7ffc02fe03f80000
       HEX 
;tsbanner08
       HEX 000007f800fff000bfebf27f97ecffebfc17ebfc05fe04ff3f8ff8ff800ff000
       HEX 
;tsbanner09
       HEX 000000ff001fffffff1fff2000080000000000000000000000004ffc00ff8000
       HEX 
;tsbanner10
       HEX 00000007f0000000007fff82fe0bf03f5fd005fff00bffcbfffc000007f80000
       HEX 
;tsbanner11
       HEX 000000000fffe00002ffff19ff33f05f1fffc9fe0ff3fffbf85fc1fffc000000
       HEX 
;tsbanner12
       HEX 0000000000000fffffffffffffffffc00000ffffffffffffffffff8000000000

 ORG $B300  ; *************

;tsbanner05
       HEX 000000000000000100ffffffffffffffffffffffffffffff8060000000000000
       HEX 
;tsbanner06
       HEX 0000000ffffe0000000000000000000000000000000000000000003ffffc0000
       HEX 
;tsbanner07
       HEX 0000000fe03ffffffd3ff17fc7fe27e5ffffe3fffe3ffff8fff802fe03f80000
       HEX 
;tsbanner08
       HEX 000007fc00fff000bfebf17fd7e9ffebfc17ebfde5fe02ff3f9ff2ff001ff800
       HEX 
;tsbanner09
       HEX 000000ff001ff00fff9ffc0000000000000000000000000000009ffc007fc000
       HEX 
;tsbanner10
       HEX 0000000ff0ffffff00fffc02fe0bf13f5fd005fff80bffcbf8fe000f03fc0000
       HEX 
;tsbanner11
       HEX 000000001ff0000002ffff8cfe1bf05f5fffe5fc1fe3fffbf85f8007fe000000
       HEX 
;tsbanner12
       HEX 0000000000001fffffffffffffffe000000003ffffffffffffffffe000000000

 ORG $B400  ; *************

;tsbanner05
       HEX 00000000000000078039fffe01ffffffffffffffc01ffffc0078000000000000
       HEX 
;tsbanner06
       HEX 00000003fffffe000000000000000000000000000000000000001fffffe00000
       HEX 
;tsbanner07
       HEX 0000001fc07ffffffa7ff27fcffc4ff27ffff3ffff0fffe3fff005ff01fc0000
       HEX 
;tsbanner08
       HEX 000007ff807ff0017febf17fd7e3ffebf817ebfc05fe027f3fbfe2ff007ff800
       HEX 
;tsbanner09
       HEX 000001fe001ff002ffc0000000000000000000000000000100013ffe007fc000
       HEX 
;tsbanner10
       HEX 0000001fe0000000e1ffc002fe0bf97f5fd005fcfe0bf84bf87e007003fc0000
       HEX 
;tsbanner11
       HEX 000000007fc0000002ffffc6fe1bf09f5ffff5fc3fcbf80bf85f8001ff000000
       HEX 
;tsbanner12
       HEX 0000000000003ffffffffffffff8000000000007ffffffffffffffe000000000

 ORG $B500  ; *************

;tsbanner05
       HEX 000000000000000fc033ffbe001c3ffffffffe1e003ffffe00fc000000000000
       HEX 
;tsbanner06
       HEX 000000007ffffffffffff800000000003c000000000007ffffffffffff000000
       HEX 
;tsbanner07
       HEX 0000001fc0ffffffe4ffe4fffffc9ff91fffe7ffffc3ff8fffe00bff81fe0000
       HEX 
;tsbanner08
       HEX 00000fffc03ff0017febf17fd7e7ffebfa37ebffe5fe027f3fbfc2fe01fff800
       HEX 
;tsbanner09
       HEX 000001fe001ff0017fd9fff87ff839e187ff27ffffb1ff07ffe27ffe003fe000
       HEX 
;tsbanner10
       HEX 0000001fe1fffffe19fe0182fe03f87f5fd005fc7f0bf80bf87e018783fe0000
       HEX 
;tsbanner11
       HEX 00000000ff00000002ff3fc2fe0bf13f5ffff5fc7f8bf803f83f00007f800000
       HEX 
;tsbanner12
       HEX 000000000000fe0007fffff800000000000000000007fffffe000ff000000000

 ORG $B600  ; *************

;tsbanner05
       HEX 000000000000001fe03fff1f807f003ffffe007fc0fc71fe01fc000000000000
       HEX 
;tsbanner06
       HEX 000000000fffffffffffffc00000000ffff000000000fffffffffffff8000000
       HEX 
;tsbanner07
       HEX 0000003f81ffffffb9ffe5fffffcbffec3ff00000000000000000007c0ff0000
       HEX 
;tsbanner08
       HEX 000001fff01ff002ffcbf17fd7fff7ebfa000bffe5fe02ff3fff82fe03ffe000
       HEX 
;tsbanner09
       HEX 000001fe001ff000bfcbffff3ff047e63fff93ffff0fffe1ffc4fffe003fe000
       HEX 
;tsbanner10
       HEX 0000003fc0ffffffc5ff07a0fe0bfcff5fd005fc3f8bf80bf8fe063f01fe0000
       HEX 
;tsbanner11
       HEX 00000000fe00000002f83fe2fe0bf87f5fc015fcff0bf80bf87f00003fc00000
       HEX 
;tsbanner12
       HEX 000000000007f00000000000000000000000000000000000000003f800000000

 ORG $B700  ; *************

;tsbanner05
       HEX 000000000000003ff81ffe07ffc7800ffff80071fff0387c07fe000000000000
       HEX 
;tsbanner06
       HEX 0000000000ffffffffffffffff003ffffffff8001fffffffffffffff80000000
       HEX 
;tsbanner07
       HEX 0000007fc3fffffc000000000000000000000000000000000000000041ff0000
       HEX 
;tsbanner08
       HEX 0000007ff01ff00dffd3f17fd7ffe7ebf9000bffe5fe04ff3fff02fe07ff0000
       HEX 
;tsbanner09
       HEX 000003fc003ff000bfebffff9fe09fe8ffffcbffff3ffff87f89fffe001fe000
       HEX 
;tsbanner10
       HEX 0000003fc07ffffff1ffffbffff9fffe5fd005fc1fcbf86bfffe08fe01ff0000
       HEX 
;tsbanner11
       HEX 00000001fc00000002e07fe2fe0bffff5fd005fffc0bf80bfffe00001fe00000
       HEX 
;tsbanner12
       HEX 00000000003fe00000000000000000000000000000000000000001ff00000000

 ORG $B800  ; *************
dmahole_3
.
 ; 

.L02314 ;  rem ** return from demo mode to the titlescreen if you press the fire button

.L02315 ;  if joy0fire  &&  gamemode = 0  &&  menubary = 136  &&  fireheld = 0 then drawwait : drawhiscores attract : goto hiscorereturn

 bit sINPT1
	BPL .skipL02315
.condpart732
	LDA gamemode
	CMP #0
     BNE .skip732then
.condpart733
	LDA menubary
	CMP #136
     BNE .skip733then
.condpart734
	LDA fireheld
	CMP #0
     BNE .skip734then
.condpart735
 jsr drawwait
 jsr loaddifficultytable
 lda #0
 sta hsdisplaymode
 jsr hscdrawscreen
 jmp .hiscorereturn

.skip734then
.skip733then
.skip732then
.skipL02315
.
 ; 

.L02316 ;  rem ** Code to move around the menu

.
 ; 

.L02317 ;  rem ** moving up and down on the standard menu

.L02318 ;  if gamemode = 0  &&  joy0down  &&  menubary < 140 then gosub menumovedown

	LDA gamemode
	CMP #0
     BNE .skipL02318
.condpart736
 lda #$20
 bit SWCHA
	BNE .skip736then
.condpart737
	LDA menubary
	CMP #140
     BCS .skip737then
.condpart738
 jsr .menumovedown

.skip737then
.skip736then
.skipL02318
.L02319 ;  if gamemode = 0  &&  joy0up  &&  menubary > 132 then gosub menumoveup

	LDA gamemode
	CMP #0
     BNE .skipL02319
.condpart739
 lda #$10
 bit SWCHA
	BNE .skip739then
.condpart740
	LDA #132
	CMP menubary
     BCS .skip740then
.condpart741
 jsr .menumoveup

.skip740then
.skip739then
.skipL02319
.
 ; 

.L02320 ;  rem ** moving up and down on the developer mode menu

.L02321 ;  if gamemode = 1  &&  joy0down  &&  menubary < 181 then gosub menumovedown

	LDA gamemode
	CMP #1
     BNE .skipL02321
.condpart742
 lda #$20
 bit SWCHA
	BNE .skip742then
.condpart743
	LDA menubary
	CMP #181
     BCS .skip743then
.condpart744
 jsr .menumovedown

.skip743then
.skip742then
.skipL02321
.L02322 ;  if gamemode = 1  &&  joy0up  &&  menubary > 132 then gosub menumoveup

	LDA gamemode
	CMP #1
     BNE .skipL02322
.condpart745
 lda #$10
 bit SWCHA
	BNE .skip745then
.condpart746
	LDA #132
	CMP menubary
     BCS .skip746then
.condpart747
 jsr .menumoveup

.skip746then
.skip745then
.skipL02322
.
 ; 

.L02323 ;  rem ** moving left and right on the skill select menu option

.L02324 ;  if menubary = 128  &&  skill < 4  &&  joy0right then gosub skillselectright

	LDA menubary
	CMP #128
     BNE .skipL02324
.condpart748
	LDA skill
	CMP #4
     BCS .skip748then
.condpart749
 bit SWCHA
	BMI .skip749then
.condpart750
 jsr .skillselectright

.skip749then
.skip748then
.skipL02324
.L02325 ;  if menubary = 128  &&  skill > 1  &&  joy0left then gosub skillselectleft

	LDA menubary
	CMP #128
     BNE .skipL02325
.condpart751
	LDA #1
	CMP skill
     BCS .skip751then
.condpart752
 bit SWCHA
	BVS .skip752then
.condpart753
 jsr .skillselectleft

.skip752then
.skip751then
.skipL02325
.
 ; 

.L02326 ;  if gamemode = 1  &&  menubary = 128  &&  joy0left then gamemode = 0 : skill = 2 : menubary = 136 : devmodeenabled = 0

	LDA gamemode
	CMP #1
     BNE .skipL02326
.condpart754
	LDA menubary
	CMP #128
     BNE .skip754then
.condpart755
 bit SWCHA
	BVS .skip755then
.condpart756
	LDA #0
	STA gamemode
	LDA #2
	STA skill
	LDA #136
	STA menubary
	LDA #0
	STA devmodeenabled
.skip755then
.skip754then
.skipL02326
.L02327 ;  if gamemode = 1  &&  menubary = 128  &&  joy0right then gamemode = 0 : skill = 2 : menubary = 136 : devmodeenabled = 0

	LDA gamemode
	CMP #1
     BNE .skipL02327
.condpart757
	LDA menubary
	CMP #128
     BNE .skip757then
.condpart758
 bit SWCHA
	BMI .skip758then
.condpart759
	LDA #0
	STA gamemode
	LDA #2
	STA skill
	LDA #136
	STA menubary
	LDA #0
	STA devmodeenabled
.skip758then
.skip757then
.skipL02327
.
 ; 

.L02328 ;  rem ** skip all the menu navigation options for dev mode if you're in standard mode

.L02329 ;  if gamemode = 0 then goto skipcustommenu

	LDA gamemode
	CMP #0
     BNE .skipL02329
.condpart760
 jmp .skipcustommenu

.skipL02329
.
 ; 

.L02330 ;  rem <--- Start Developer mode menu selection code --->

.
 ; 

.L02331 ;  if menubary = 136  &&  joy0right then gosub speedselect

	LDA menubary
	CMP #136
     BNE .skipL02331
.condpart761
 bit SWCHA
	BMI .skip761then
.condpart762
 jsr .speedselect

.skip761then
.skipL02331
.L02332 ;  if menubary = 136  &&  joy0left then gosub speedselect

	LDA menubary
	CMP #136
     BNE .skipL02332
.condpart763
 bit SWCHA
	BVS .skip763then
.condpart764
 jsr .speedselect

.skip763then
.skipL02332
.
 ; 

.L02333 ;  if menubary = 144  &&  levelvalue < 5  &&  joy0right then gosub levelmoveright

	LDA menubary
	CMP #144
     BNE .skipL02333
.condpart765
	LDA levelvalue
	CMP #5
     BCS .skip765then
.condpart766
 bit SWCHA
	BMI .skip766then
.condpart767
 jsr .levelmoveright

.skip766then
.skip765then
.skipL02333
.L02334 ;  if menubary = 144  &&  levelvalue > 1  &&  joy0left then gosub levelmoveleft

	LDA menubary
	CMP #144
     BNE .skipL02334
.condpart768
	LDA #1
	CMP levelvalue
     BCS .skip768then
.condpart769
 bit SWCHA
	BVS .skip769then
.condpart770
 jsr .levelmoveleft

.skip769then
.skip768then
.skipL02334
.
 ; 

.L02335 ;  if menubary = 152  &&  arrowsvalue < 9  &&  joy0right then gosub arrowsmoveright

	LDA menubary
	CMP #152
     BNE .skipL02335
.condpart771
	LDA arrowsvalue
	CMP #9
     BCS .skip771then
.condpart772
 bit SWCHA
	BMI .skip772then
.condpart773
 jsr .arrowsmoveright

.skip772then
.skip771then
.skipL02335
.L02336 ;  if menubary = 152  &&  arrowsvalue > 1  &&  joy0left then gosub arrowsmoveleft

	LDA menubary
	CMP #152
     BNE .skipL02336
.condpart774
	LDA #1
	CMP arrowsvalue
     BCS .skip774then
.condpart775
 bit SWCHA
	BVS .skip775then
.condpart776
 jsr .arrowsmoveleft

.skip775then
.skip774then
.skipL02336
.
 ; 

.L02337 ;  if menubary = 160  &&  livesvalue < 9  &&  joy0right then gosub livesmoveright

	LDA menubary
	CMP #160
     BNE .skipL02337
.condpart777
	LDA livesvalue
	CMP #9
     BCS .skip777then
.condpart778
 bit SWCHA
	BMI .skip778then
.condpart779
 jsr .livesmoveright

.skip778then
.skip777then
.skipL02337
.L02338 ;  if menubary = 160  &&  livesvalue > 1  &&  joy0left then gosub livesmoveleft

	LDA menubary
	CMP #160
     BNE .skipL02338
.condpart780
	LDA #1
	CMP livesvalue
     BCS .skip780then
.condpart781
 bit SWCHA
	BVS .skip781then
.condpart782
 jsr .livesmoveleft

.skip781then
.skip780then
.skipL02338
.
 ; 

.L02339 ;  if menubary = 168  &&  joy0right then gosub godselect

	LDA menubary
	CMP #168
     BNE .skipL02339
.condpart783
 bit SWCHA
	BMI .skip783then
.condpart784
 jsr .godselect

.skip783then
.skipL02339
.L02340 ;  if menubary = 168  &&  joy0left then gosub godselect

	LDA menubary
	CMP #168
     BNE .skipL02340
.condpart785
 bit SWCHA
	BVS .skip785then
.condpart786
 jsr .godselect

.skip785then
.skipL02340
.
 ; 

.L02341 ;  if menubary = 176  &&  scorevalue < 5  &&  joy0right then gosub scoreselectright

	LDA menubary
	CMP #176
     BNE .skipL02341
.condpart787
	LDA scorevalue
	CMP #5
     BCS .skip787then
.condpart788
 bit SWCHA
	BMI .skip788then
.condpart789
 jsr .scoreselectright

.skip788then
.skip787then
.skipL02341
.L02342 ;  if menubary = 176  &&  scorevalue > 1  &&  joy0left then gosub scoreselectleft

	LDA menubary
	CMP #176
     BNE .skipL02342
.condpart790
	LDA #1
	CMP scorevalue
     BCS .skip790then
.condpart791
 bit SWCHA
	BVS .skip791then
.condpart792
 jsr .scoreselectleft

.skip791then
.skip790then
.skipL02342
.
 ; 

.L02343 ;  rem <--- End Developer mode menu selection code --->

.
 ; 

.skipcustommenu
 ; skipcustommenu

.
 ; 

.L02344 ;  drawscreen

 jsr drawscreen
.
 ; 

.L02345 ;  frame = frame + 1

	LDA frame
	CLC
	ADC #1
	STA frame
.L02346 ;  if joy0any then demomodecountdown = 8

 lda SWCHA
 and #$F0
 eor #$F0
	BEQ .skipL02346
.condpart793
	LDA #8
	STA demomodecountdown
.skipL02346
.L02347 ;  temp8 = frame & 63

	LDA frame
	AND #63
	STA temp8
.L02348 ;  if temp8 = 0 then demomodecountdown = demomodecountdown - 1

	LDA temp8
	CMP #0
     BNE .skipL02348
.condpart794
	LDA demomodecountdown
	SEC
	SBC #1
	STA demomodecountdown
.skipL02348
.L02349 ;  if gamemode = 0  &&  demomodecountdown = 0 then demomode = 1 : demomodecountdown = 18 : drawwait : goto preinit

	LDA gamemode
	CMP #0
     BNE .skipL02349
.condpart795
	LDA demomodecountdown
	CMP #0
     BNE .skip795then
.condpart796
	LDA #1
	STA demomode
	LDA #18
	STA demomodecountdown
 jsr drawwait
 jmp .preinit

.skip795then
.skipL02349
.
 ; 

.L02350 ;  goto titlescreen2

 jmp .titlescreen2

.
 ; 

.doeachmonstermove
 ; doeachmonstermove

.
 ; 

.L02351 ;  rem ** this will stop the Enemy when one is killed by an arrow

.L02352 ;  if enemy1deathflag[temploop] = 1 then goto skipmove1

	LDX temploop
	LDA enemy1deathflag,x
	CMP #1
     BNE .skipL02352
.condpart797
 jmp .skipmove1

.skipL02352
.
 ; 

.L02353 ;  rem ** don't allow enemy movement or shooting while player death animation is running

.L02354 ;  if playerdeathflag = 1 then goto skipmove1

	LDA playerdeathflag
	CMP #1
     BNE .skipL02354
.condpart798
 jmp .skipmove1

.skipL02354
.
 ; 

.L02355 ;  rem "0 up  1 left  2 down  3 right"

.L02356 ;  if tempdir = 0 then tempy = tempy - 1

	LDA tempdir
	CMP #0
     BNE .skipL02356
.condpart799
	LDA tempy
	SEC
	SBC #1
	STA tempy
.skipL02356
.L02357 ;  if tempdir = 1 then tempx = tempx - 1

	LDA tempdir
	CMP #1
     BNE .skipL02357
.condpart800
	LDA tempx
	SEC
	SBC #1
	STA tempx
.skipL02357
.L02358 ;  if tempdir = 2 then tempy = tempy + 1

	LDA tempdir
	CMP #2
     BNE .skipL02358
.condpart801
	LDA tempy
	CLC
	ADC #1
	STA tempy
.skipL02358
.L02359 ;  if tempdir = 3 then tempx = tempx + 1

	LDA tempdir
	CMP #3
     BNE .skipL02359
.condpart802
	LDA tempx
	CLC
	ADC #1
	STA tempx
.skipL02359
.skipmove1
 ; skipmove1

.
 ; 

.L02360 ;  return

  RTS
.
 ; 

.checkmonstmoveup
 ; checkmonstmoveup

.L02361 ;  rem ** the monster looks to see if he can move up...

.L02362 ;  if tempy < 8 then obstacleseen = 1 : return  :  rem don't let him move above the top row

	LDA tempy
	CMP #8
     BCS .skipL02362
.condpart803
	LDA #1
	STA obstacleseen
  RTS
.skipL02362
.
 ; 

.L02363 ;  rem ** 1. pick 2 points above the enemy, spaced the width of a corridor.

.L02364 ;  rem ** 2. convert the sprite coordinates to character coordinates.

.L02365 ;  rem ** 3. lookup the characters. If both aren't spaces, the path up is blocked.

.
 ; 

.L02366 ;  rem ** convert to character coordinates...

.L02367 ;  temp0_x =  ( tempx - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02368 ;  temp0_y =  ( tempy - 1 )  / 8

; complex statement detected
	LDA tempy
	SEC
	SBC #1
	lsr
	lsr
	lsr
	STA temp0_y
.L02369 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02370 ;  temp0_x =  ( tempx + 7 - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	CLC
	ADC #7
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02371 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.
 ; 

.L02372 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then tempchar1 = $41

	LDA tempchar1
	CMP #spw1
     BCC .skipL02372
.condpart804
	LDA #spw4
	CMP tempchar1
     BCC .skip804then
.condpart805
	LDA #$41
	STA tempchar1
.skip804then
.skipL02372
.L02373 ;  if tempchar2 >= spw1  &&  tempchar2 <= spw4 then tempchar2 = $41

	LDA tempchar2
	CMP #spw1
     BCC .skipL02373
.condpart806
	LDA #spw4
	CMP tempchar2
     BCC .skip806then
.condpart807
	LDA #$41
	STA tempchar2
.skip806then
.skipL02373
.
 ; 

.L02374 ;  rem ** for now we just check for blank=$41...

.L02375 ;  if tempchar1 = $41  &&  tempchar2 = $41 then obstacleseen = 0 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02375
.condpart808
	LDA tempchar2
	CMP #$41
     BNE .skip808then
.condpart809
	LDA #0
	STA obstacleseen
  RTS
.skip808then
.skipL02375
.
 ; 

.L02376 ;  rem ** any other situation is a barrier to the monster...

.L02377 ;  obstacleseen = 1

	LDA #1
	STA obstacleseen
.L02378 ;  return

  RTS
.
 ; 

.checkmonstmovedown
 ; checkmonstmovedown

.L02379 ;  rem ** the monster looks to see if he can move down...

.L02380 ;  if tempy > 199 then obstacleseen = 1 : return  :  rem don't let him move beyond the last row

	LDA #199
	CMP tempy
     BCS .skipL02380
.condpart810
	LDA #1
	STA obstacleseen
  RTS
.skipL02380
.
 ; 

.L02381 ;  rem ** 1. pick 2 points below the monster, spaced the width of a corridor.

.L02382 ;  rem ** 2. convert the sprite coordinates to character coordinates.

.L02383 ;  rem ** 3. lookup the characters. If both aren't spaces, the path down is blocked.

.
 ; 

.L02384 ;  temp0_x =  ( tempx - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02385 ;  temp0_y =  ( tempy + 16 )  / 8

; complex statement detected
	LDA tempy
	CLC
	ADC #16
	lsr
	lsr
	lsr
	STA temp0_y
.L02386 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02387 ;  temp0_x =  ( tempx + 7 - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	CLC
	ADC #7
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02388 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.
 ; 

.L02389 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then tempchar1 = $41

	LDA tempchar1
	CMP #spw1
     BCC .skipL02389
.condpart811
	LDA #spw4
	CMP tempchar1
     BCC .skip811then
.condpart812
	LDA #$41
	STA tempchar1
.skip811then
.skipL02389
.L02390 ;  if tempchar2 >= spw1  &&  tempchar2 <= spw4 then tempchar2 = $41

	LDA tempchar2
	CMP #spw1
     BCC .skipL02390
.condpart813
	LDA #spw4
	CMP tempchar2
     BCC .skip813then
.condpart814
	LDA #$41
	STA tempchar2
.skip813then
.skipL02390
.
 ; 

.L02391 ;  rem ** for now we just check for blank=$41...

.L02392 ;  if tempchar1 = $41  &&  tempchar2 = $41 then obstacleseen = 0 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02392
.condpart815
	LDA tempchar2
	CMP #$41
     BNE .skip815then
.condpart816
	LDA #0
	STA obstacleseen
  RTS
.skip815then
.skipL02392
.
 ; 

.L02393 ;  rem ** any other tile is a barrier to the enemy...

.L02394 ;  obstacleseen = 1

	LDA #1
	STA obstacleseen
.L02395 ;  return

  RTS
.
 ; 

.checkmonstmoveleft
 ; checkmonstmoveleft

.L02396 ;  rem ** the enemy looks to see if he can move left...

.L02397 ;  if tempx < 4 then obstacleseen = 1 : return  :  rem don't let him move before the first column

	LDA tempx
	CMP #4
     BCS .skipL02397
.condpart817
	LDA #1
	STA obstacleseen
  RTS
.skipL02397
.
 ; 

.L02398 ;  rem ** 1. pick 2 points to the left of the monster, spaced the height of a corridor.

.L02399 ;  rem ** 2. convert the sprite coordinates to character coordinates.

.L02400 ;  rem ** 3. lookup the characters. If both aren't spaces, the path left is blocked

.
 ; 

.L02401 ;  temp0_x =  ( tempx - 1 - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	SEC
	SBC #1
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02402 ;  temp0_y = tempy / 8

	LDA tempy
	lsr
	lsr
	lsr
	STA temp0_y
.L02403 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02404 ;  temp0_y =  ( tempy + 15 )  / 8

; complex statement detected
	LDA tempy
	CLC
	ADC #15
	lsr
	lsr
	lsr
	STA temp0_y
.L02405 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.
 ; 

.L02406 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then tempchar1 = $41

	LDA tempchar1
	CMP #spw1
     BCC .skipL02406
.condpart818
	LDA #spw4
	CMP tempchar1
     BCC .skip818then
.condpart819
	LDA #$41
	STA tempchar1
.skip818then
.skipL02406
.L02407 ;  if tempchar2 >= spw1  &&  tempchar2 <= spw4 then tempchar2 = $41

	LDA tempchar2
	CMP #spw1
     BCC .skipL02407
.condpart820
	LDA #spw4
	CMP tempchar2
     BCC .skip820then
.condpart821
	LDA #$41
	STA tempchar2
.skip820then
.skipL02407
.
 ; 

.L02408 ;  rem ** for now we just check for blank=$41...

.L02409 ;  if tempchar1 = $41  &&  tempchar2 = $41 then obstacleseen = 0 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02409
.condpart822
	LDA tempchar2
	CMP #$41
     BNE .skip822then
.condpart823
	LDA #0
	STA obstacleseen
  RTS
.skip822then
.skipL02409
.
 ; 

.L02410 ;  rem ** any other tile is a barrier to the monster...

.L02411 ;  obstacleseen = 1

	LDA #1
	STA obstacleseen
.L02412 ;  return

  RTS
.
 ; 

.checkmonstmoveright
 ; checkmonstmoveright

.L02413 ;  rem ** the enemy looks to see if he can move right...

.L02414 ;  if tempx > 151 then obstacleseen = 1 : return  :  rem don't let him move beyond the last column

	LDA #151
	CMP tempx
     BCS .skipL02414
.condpart824
	LDA #1
	STA obstacleseen
  RTS
.skipL02414
.
 ; 

.L02415 ;  rem ** pick a point in the middle of the monster, above him, and

.L02416 ;  rem ** convert to character coordinates...

.L02417 ;  temp0_x =  ( tempx + 8 - temppositionadjust )  / 4

; complex statement detected
	LDA tempx
	CLC
	ADC #8
	SEC
	SBC temppositionadjust
	lsr
	lsr
	STA temp0_x
.L02418 ;  temp0_y = tempy / 8

	LDA tempy
	lsr
	lsr
	lsr
	STA temp0_y
.L02419 ;  tempchar1 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar1
.L02420 ;  temp0_y =  ( tempy + 15 )  / 8

; complex statement detected
	LDA tempy
	CLC
	ADC #15
	lsr
	lsr
	lsr
	STA temp0_y
.L02421 ;  tempchar2 = peekchar ( screenram , temp0_x , temp0_y , 40 , 28 ) 

    ldy temp0_y
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy temp0_x
    lda (temp1),y
	STA tempchar2
.
 ; 

.L02422 ;  if tempchar1 >= spw1  &&  tempchar1 <= spw4 then tempchar1 = $41

	LDA tempchar1
	CMP #spw1
     BCC .skipL02422
.condpart825
	LDA #spw4
	CMP tempchar1
     BCC .skip825then
.condpart826
	LDA #$41
	STA tempchar1
.skip825then
.skipL02422
.L02423 ;  if tempchar2 >= spw1  &&  tempchar2 <= spw4 then tempchar2 = $41

	LDA tempchar2
	CMP #spw1
     BCC .skipL02423
.condpart827
	LDA #spw4
	CMP tempchar2
     BCC .skip827then
.condpart828
	LDA #$41
	STA tempchar2
.skip827then
.skipL02423
.
 ; 

.L02424 ;  rem ** for now we just check for blank=$41...

.L02425 ;  if tempchar1 = $41  &&  tempchar2 = $41 then obstacleseen = 0 : return

	LDA tempchar1
	CMP #$41
     BNE .skipL02425
.condpart829
	LDA tempchar2
	CMP #$41
     BNE .skip829then
.condpart830
	LDA #0
	STA obstacleseen
  RTS
.skip829then
.skipL02425
.
 ; 

.L02426 ;  rem ** any other tile is a barrier to the monster...

.L02427 ;  obstacleseen = 1

	LDA #1
	STA obstacleseen
.L02428 ;  return

  RTS
.
 ; 

.spiderlogic
 ; spiderlogic

.L02429 ;  temppositionadjust = 0

	LDA #0
	STA temppositionadjust
.L02430 ;  rem ** where spiders decide which way to move, if they should shoot, which direction, etc...

.
 ; 

.L02431 ;  rem ** our spider is making a web. skip moving entirely.

.L02432 ;  rem ** the animation still runs even though the spider doesn't move

.L02433 ;  if spiderwebcountdown > 0  &&  skill <> 1 then goto dospiderwebbing

	LDA #0
	CMP spiderwebcountdown
     BCS .skipL02433
.condpart831
	LDA skill
	CMP #1
     BEQ .skip831then
.condpart832
 jmp .dospiderwebbing

.skip831then
.skipL02433
.
 ; 

.L02434 ;  temploop = 0

	LDA #0
	STA temploop
.L02435 ;  tempx = spiderx

	LDA spiderx
	STA tempx
.L02436 ;  tempy = spidery

	LDA spidery
	STA tempy
.L02437 ;  tempdir = spider_spider1dir

	LDA spider_spider1dir
	STA tempdir
.L02438 ;  temptype = 1  :  rem ** spider moves like a basic monster/monster

	LDA #1
	STA temptype
.L02439 ;  templogiccountdown = spiderchangecountdown

	LDA spiderchangecountdown
	STA templogiccountdown
.
 ; 

.L02440 ;  rem *** data driven monster speed routine...

.L02441 ;  temp1 = levelspeeds[levelvalue]

	LDX levelvalue
	LDA levelspeeds,x
	STA temp1
.L02442 ;  spiderslow[temploop] = spiderslow[temploop] + temp1

	LDX temploop
	LDA spiderslow,x
	CLC
	ADC temp1
	LDX temploop
	STA spiderslow,x
.L02443 ;  if !CARRY then return

 BCS .skipL02443
.condpart833
  RTS
.skipL02443
.
 ; 

.L02444 ;  rem ** we reuse the monster logic routines for the spider

.L02445 ;  gosub doeachmonsterlogic

 jsr .doeachmonsterlogic

.skipspidermove
 ; skipspidermove

.
 ; 

.L02446 ;  gosub doeachspidermove

 jsr .doeachspidermove

.
 ; 

.L02447 ;  rem ** stuff tempx, tempy, and tempdir back into the actual spider's variables...

.L02448 ;  spiderx = tempx

	LDA tempx
	STA spiderx
.L02449 ;  spidery = tempy

	LDA tempy
	STA spidery
.L02450 ;  spider_spider1dir = tempdir

	LDA tempdir
	STA spider_spider1dir
.L02451 ;  spiderchangecountdown = templogiccountdown

	LDA templogiccountdown
	STA spiderchangecountdown
.L02452 ;  if spiderx < 28  &&  spidery < 60 then return

	LDA spiderx
	CMP #28
     BCS .skipL02452
.condpart834
	LDA spidery
	CMP #60
     BCS .skip834then
.condpart835
  RTS
.skip834then
.skipL02452
.L02453 ;  if  ( spiderx & 3 )  = 0  &&   ( spidery & 7 )  = 0 then carryonspiderwalking

; complex condition detected
; complex statement detected
	LDA spiderx
	AND #3
; todo: this LDA is spurious and should be prevented ->	LDA  $101,x
	CMP #0
     BNE .skipL02453
.condpart836
; complex condition detected
; complex statement detected
	LDA spidery
	AND #7
	CMP #0
 if ((* - .carryonspiderwalking) < 127) && ((* - .carryonspiderwalking) > -128)
	BEQ .carryonspiderwalking
 else
	bne .17skipcarryonspiderwalking
	jmp .carryonspiderwalking
.17skipcarryonspiderwalking
 endif
.skipL02453
.L02454 ;  return

  RTS
.carryonspiderwalking
 ; carryonspiderwalking

.L02455 ;  spiderwalkingsteps = spiderwalkingsteps + 1

	LDA spiderwalkingsteps
	CLC
	ADC #1
	STA spiderwalkingsteps
.L02456 ;  if spiderwalkingsteps < 76 then return

	LDA spiderwalkingsteps
	CMP #76
     BCS .skipL02456
.condpart837
  RTS
.skipL02456
.L02457 ;  tempx = tempx / 4

	LDA tempx
	lsr
	lsr
	STA tempx
.L02458 ;  tempy = tempy / 8

	LDA tempy
	lsr
	lsr
	lsr
	STA tempy
.L02459 ;  tempchar2 = peekchar ( screenram , tempx , tempy , 40 , 28 ) 

    ldy tempy
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy tempx
    lda (temp1),y
	STA tempchar2
.L02460 ;  if tempchar2 <> $41 then return

	LDA tempchar2
	CMP #$41
     BEQ .skipL02460
.condpart838
  RTS
.skipL02460
.L02461 ;  spiderwalkingsteps = 0

	LDA #0
	STA spiderwalkingsteps
.L02462 ;  if  ( rand & 1 )  = 0 then return

; complex condition detected
; complex statement detected
 jsr randomize
	AND #1
	CMP #0
     BNE .skipL02462
.condpart839
  RTS
.skipL02462
.L02463 ;  spiderwebcountdown = 255

	LDA #255
	STA spiderwebcountdown
.L02464 ;  return

  RTS
.
 ; 

.dospiderwebbing
 ; dospiderwebbing

.L02465 ;  spiderwebcountdown = spiderwebcountdown - 1

	LDA spiderwebcountdown
	SEC
	SBC #1
	STA spiderwebcountdown
.L02466 ;  if spiderwebcountdown > 0 then return

	LDA #0
	CMP spiderwebcountdown
     BCS .skipL02466
.condpart840
  RTS
.skipL02466
.L02467 ;  tempx = spiderx / 4

	LDA spiderx
	lsr
	lsr
	STA tempx
.L02468 ;  tempy = spidery / 8

	LDA spidery
	lsr
	lsr
	lsr
	STA tempy
.L02469 ;  pokechar screenram tempx tempy 40 28 spw1

    ldy tempy
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy tempx
    lda #spw1
    sta (temp1),y
.L02470 ;  tempx = tempx + 1

	LDA tempx
	CLC
	ADC #1
	STA tempx
.L02471 ;  pokechar screenram tempx tempy 40 28 spw2

    ldy tempy
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy tempx
    lda #spw2
    sta (temp1),y
.L02472 ;  tempy = tempy + 1

	LDA tempy
	CLC
	ADC #1
	STA tempy
.L02473 ;  pokechar screenram tempx tempy 40 28 spw4

    ldy tempy
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy tempx
    lda #spw4
    sta (temp1),y
.L02474 ;  tempx = tempx - 1

	LDA tempx
	SEC
	SBC #1
	STA tempx
.L02475 ;  pokechar screenram tempx tempy 40 28 spw3

    ldy tempy
    lda screenram_mult_lo,y
    sta temp1
    lda screenram_mult_hi,y
    sta temp2
    ldy tempx
    lda #spw3
    sta (temp1),y
.L02476 ;  return

  RTS
.
 ; 

.doeachspidermove
 ; doeachspidermove

.
 ; 

.L02477 ;  rem ** this will stop the eneny when one is killed by a arrow

.L02478 ;  if playerdeathflag = 1 then goto skipmove2

	LDA playerdeathflag
	CMP #1
     BNE .skipL02478
.condpart841
 jmp .skipmove2

.skipL02478
.
 ; 

.L02479 ;  rem "up left down right"

.L02480 ;  if tempdir = 0 then tempy = tempy - 1 : return

	LDA tempdir
	CMP #0
     BNE .skipL02480
.condpart842
	LDA tempy
	SEC
	SBC #1
	STA tempy
  RTS
.skipL02480
.L02481 ;  if tempdir = 1 then tempx = tempx - 1 : return

	LDA tempdir
	CMP #1
     BNE .skipL02481
.condpart843
	LDA tempx
	SEC
	SBC #1
	STA tempx
  RTS
.skipL02481
.L02482 ;  if tempdir = 2 then tempy = tempy + 1 : return

	LDA tempdir
	CMP #2
     BNE .skipL02482
.condpart844
	LDA tempy
	CLC
	ADC #1
	STA tempy
  RTS
.skipL02482
.L02483 ;  if tempdir = 3 then tempx = tempx + 1 : return

	LDA tempdir
	CMP #3
     BNE .skipL02483
.condpart845
	LDA tempx
	CLC
	ADC #1
	STA tempx
  RTS
.skipL02483
.skipmove2
 ; skipmove2

.L02484 ;  return

  RTS
.
 ; 

.wizlogic
 ; wizlogic

.L02485 ;  temploop = 0

	LDA #0
	STA temploop
.L02486 ;  temppositionadjust = 0

	LDA #0
	STA temppositionadjust
.L02487 ;  tempx = wizx

	LDA wizx
	STA tempx
.L02488 ;  tempy = wizy

	LDA wizy
	STA tempy
.L02489 ;  templogiccountdown = wizlogiccountdown

	LDA wizlogiccountdown
	STA templogiccountdown
.L02490 ;  tempdir = wizdir

	LDA wizdir
	STA tempdir
.L02491 ;  temptype = 1

	LDA #1
	STA temptype
.L02492 ;  gosub doeachmonsterlogic

 jsr .doeachmonsterlogic

.L02493 ;  gosub dowizmove

 jsr .dowizmove

.L02494 ;  wizx = tempx

	LDA tempx
	STA wizx
.L02495 ;  wizy = tempy

	LDA tempy
	STA wizy
.L02496 ;  wizlogiccountdown = templogiccountdown

	LDA templogiccountdown
	STA wizlogiccountdown
.L02497 ;  wizdir = tempdir

	LDA tempdir
	STA wizdir
.L02498 ;  gosub dowizfiring

 jsr .dowizfiring

.L02499 ;  return

  RTS
.
 ; 

.batlogic
 ; batlogic

.L02500 ;  if levelvalue = 5 then return

	LDA levelvalue
	CMP #5
     BNE .skipL02500
.condpart846
  RTS
.skipL02500
.L02501 ;  temppositionadjust = 2

	LDA #2
	STA temppositionadjust
.
 ; 

.L02502 ;  rem ** where bats decide which way to move, if they should shoot, which direction, etc...

.L02503 ;  for temploop = 0 to 1

	LDA #0
	STA temploop
.L02503fortemploop
.L02504 ;  if levelvalue = 4 then temploop = 1

	LDA levelvalue
	CMP #4
     BNE .skipL02504
.condpart847
	LDA #1
	STA temploop
.skipL02504
.L02505 ;  tempx = bat1x[temploop]

	LDX temploop
	LDA bat1x,x
	STA tempx
.L02506 ;  tempy = bat1y[temploop]

	LDX temploop
	LDA bat1y,x
	STA tempy
.L02507 ;  templogiccountdown = bat1changecountdown[temploop]

	LDX temploop
	LDA bat1changecountdown,x
	STA templogiccountdown
.L02508 ;  tempdir = bat_bat1dir[temploop]

	LDX temploop
	LDA bat_bat1dir,x
	STA tempdir
.L02509 ;  temptype = 1

	LDA #1
	STA temptype
.
 ; 

.L02510 ;  rem *** data driven monster speed routine...

.L02511 ;  temp1 = levelspeeds[levelvalue] / 2

	LDX levelvalue
	LDA levelspeeds,x
	lsr
	STA temp1
.L02512 ;  bat1slow[temploop] = bat1slow[temploop] + temp1

	LDX temploop
	LDA bat1slow,x
	CLC
	ADC temp1
	LDX temploop
	STA bat1slow,x
.L02513 ;  if !CARRY then goto skiprestbatlogic

 BCS .skipL02513
.condpart848
 jmp .skiprestbatlogic

.skipL02513
.
 ; 

.L02514 ;  gosub doeachmonsterlogic

 jsr .doeachmonsterlogic

.L02515 ;  gosub doeachbatmove

 jsr .doeachbatmove

.
 ; 

.L02516 ;  rem ** stuff tempx, tempy, and tempdir back into the actual bat's variables...

.L02517 ;  bat1x[temploop] = tempx

	LDA tempx
	LDX temploop
	STA bat1x,x
.L02518 ;  bat1y[temploop] = tempy

	LDA tempy
	LDX temploop
	STA bat1y,x
.L02519 ;  bat1changecountdown[temploop] = templogiccountdown

	LDA templogiccountdown
	LDX temploop
	STA bat1changecountdown,x
.L02520 ;  bat_bat1dir[temploop] = tempdir

	LDA tempdir
	LDX temploop
	STA bat_bat1dir,x
.skiprestbatlogic
 ; skiprestbatlogic

.L02521 ;  next  :  rem next bat...

	LDA temploop
	CMP #1

	INC temploop
 if ((* - .L02503fortemploop) < 127) && ((* - .L02503fortemploop) > -128)
	bcc .L02503fortemploop
 else
	bcs .18skipL02503fortemploop
	jmp .L02503fortemploop
.18skipL02503fortemploop
 endif
.L02522 ;  return

  RTS
.
 ; 

.L02523 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L02524 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L02525 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L02526 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L02527 ;  rem ** so you'll have to experiment with their location in your own code.

.L02528 ;  dmahole 4

 jmp dmahole_4
 echo "  ","  ","  ","  ",[($C000 - .)]d , "bytes of ROM space left in DMA hole 3."

 ORG $C000  ; *************

tsbanner13
       HEX 000000000000000000000000000000033ff00000000000000000000000000000
       HEX 
tsbanner14
       HEX 000000000000000000000000000000003f800000000000000000000000000000
       HEX 
tsbanner15
       HEX 0000000000000000000000000000000000000000000000000000000000000000
       HEX 
web1
       HEX f10100008000809f
web2
       HEX f101400080028087
web3
       HEX f8101103c088081f
web4
       HEX fc4081018081020f
       HEX 
web5
       HEX f820208cb104040f
web6
       HEX fa00800ff001004f
web7
       HEX f082000000004107
web8
       HEX f000000000000003
       HEX 
spider1top_explode1
       HEX 0eb8
spider1top_explode2
       HEX 0eb8
spider1top_explode3
       HEX 0eb8
spider1top_explode4
       HEX 06b0
spider1top_explode5
       HEX 0000
spider1bottom_explode1
       HEX 0000
spider1bottom_explode2
       HEX 0000
spider1bottom_explode3
       HEX 0000
spider1bottom_explode4
       HEX 0000
spider1bottom_explode5
       HEX 0000
arrowbar0
       HEX 000000000000
arrowbar1
       HEX 400000000000
       HEX 
arrowbar2
       HEX 420000000000
arrowbar3
       HEX 421000000000
arrowbar4
       HEX 421080000000
arrowbar5
       HEX 421084000000
arrowbar6
       HEX 421084200000
arrowbar7
       HEX 4210
       HEX 84210000
arrowbar8
       HEX 421084210800
arrowbar_nolimit
       HEX ffffffffffe0

 ORG $C100  ; *************

;tsbanner13
       HEX 000000000000000000000000000000023ff00000000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000007f800000000000000000000000000000
       HEX 
;tsbanner15
       HEX 0000000000000000000000000000000000000000000000000000000000000000
       HEX 
;web1
       HEX f20180008003004f
;web2
       HEX e082200080044107
;web3
       HEX f8100a008050081f
;web4
       HEX fc4081024081021f
       HEX 
;web5
       HEX fc2020508a04040f
;web6
       HEX fa0140300c028047
;web7
       HEX f844003ffc00220f
;web8
       HEX f800000000000007
       HEX 
;spider1top_explode1
       HEX 03e0
;spider1top_explode2
       HEX 03e0
;spider1top_explode3
       HEX 03e0
;spider1top_explode4
       HEX 03e0
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 0410
;spider1bottom_explode2
       HEX 0000
;spider1bottom_explode3
       HEX 0000
;spider1bottom_explode4
       HEX 0000
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX c00000000000
       HEX 
;arrowbar2
       HEX c60000000000
;arrowbar3
       HEX c63000000000
;arrowbar4
       HEX c63180000000
;arrowbar5
       HEX c6318c000000
;arrowbar6
       HEX c6318c600000
;arrowbar7
       HEX c631
       HEX 8c630000
;arrowbar8
       HEX c6318c631800
;arrowbar_nolimit
       HEX 85d0aebb8460

 ORG $C200  ; *************

;tsbanner13
       HEX 000000000000000000000000000000063ff00000000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000007f800000000000000000000000000000
       HEX 
;tsbanner15
       HEX 0000000000000000000000000000000000000000000000000000000000000000
       HEX 
;web1
       HEX fcc3c01880cc002f
;web2
       HEX f044100080082207
;web3
       HEX f80804008020101f
;web4
       HEX fc408084a101021f
       HEX 
;web5
       HEX fc4040208402020f
;web6
       HEX fc0220c003044027
;web7
       HEX fc2800c00300141f
;web8
       HEX f80000ffff00000f
       HEX 
;spider1top_explode1
       HEX 3ebe
;spider1top_explode2
       HEX 3ebe
;spider1top_explode3
       HEX 0eb8
;spider1top_explode4
       HEX 0080
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 0410
;spider1bottom_explode2
       HEX 0000
;spider1bottom_explode3
       HEX 0000
;spider1bottom_explode4
       HEX 0000
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 200000000000
       HEX 
;arrowbar2
       HEX 210000000000
;arrowbar3
       HEX 210800000000
;arrowbar4
       HEX 210840000000
;arrowbar5
       HEX 210842000000
;arrowbar6
       HEX 210842100000
;arrowbar7
       HEX 2108
       HEX 42108000
;arrowbar8
       HEX 210842108400
;arrowbar_nolimit
       HEX b5d7aebbbda0

 ORG $C300  ; *************

;tsbanner13
       HEX 00000000000000000000000000000007fff00000000000000000000000000000
       HEX 
;tsbanner14
       HEX 00000000000000000000000000000000dfc00000000000000000000000000000
       HEX 
;tsbanner15
       HEX 0000000000000000000000000000000000000000000000000000000000000000
       HEX 
;web1
       HEX fde7cf3c81f03c1f
;web2
       HEX f0280c008030140f
;web3
       HEX e8080a008050101f
;web4
       HEX fc4080889101021f
       HEX 
;web5
       HEX fc4040508a020207
;web6
       HEX fc04110000882027
;web7
       HEX fc10030000c0083f
;web8
       HEX f800030000c0000f
       HEX 
;spider1top_explode1
       HEX 6d5b
;spider1top_explode2
       HEX 2d5a
;spider1top_explode3
       HEX 0550
;spider1top_explode4
       HEX 0000
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 4c19
;spider1bottom_explode2
       HEX 0410
;spider1bottom_explode3
       HEX 0000
;spider1bottom_explode4
       HEX 0000
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 100000000000
       HEX 
;arrowbar2
       HEX 108000000000
;arrowbar3
       HEX 108400000000
;arrowbar4
       HEX 108420000000
;arrowbar5
       HEX 108421000000
;arrowbar6
       HEX 108421080000
;arrowbar7
       HEX 1084
       HEX 21084000
;arrowbar8
       HEX 108421084200
;arrowbar_nolimit
       HEX b597aebbbda0

 ORG $C400  ; *************

;tsbanner13
       HEX 0000000000000000000000000000000ffff80000000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000009fc00000000000000000000000000000
       HEX 
;tsbanner15
       HEX 0000000000000000000000000000000000000000000000000000000000000000
       HEX 
;web1
       HEX fff7efffe7fc7f3f
;web2
       HEX f010030080c0080f
;web3
       HEX f40411008088202f
;web4
       HEX f84040508a02023f
       HEX 
;web5
       HEX f840808891010207
;web6
       HEX f8080a000050101f
;web7
       HEX f8280c000030143f
;web8
       HEX f8000c000030001f
       HEX 
;spider1top_explode1
       HEX 280a
;spider1top_explode2
       HEX 0808
;spider1top_explode3
       HEX 0000
;spider1top_explode4
       HEX 0000
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 4c99
;spider1bottom_explode2
       HEX 0c98
;spider1bottom_explode3
       HEX 0080
;spider1bottom_explode4
       HEX 0000
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 080000000000
       HEX 
;arrowbar2
       HEX 084000000000
;arrowbar3
       HEX 084200000000
;arrowbar4
       HEX 084210000000
;arrowbar5
       HEX 084210800000
;arrowbar6
       HEX 084210840000
;arrowbar7
       HEX 0842
       HEX 10842000
;arrowbar8
       HEX 084210842100
;arrowbar_nolimit
       HEX b557aabb8da0

 ORG $C500  ; *************

;tsbanner13
       HEX 0000000000000000000000000000007ffffc0000000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000009fe00000000000000000000000000000
       HEX 
;tsbanner15
       HEX 000000000000000000000000000000000c000000000000000000000000000000
       HEX 
;web1
       HEX ffffffffffffffff
;web2
       HEX f82800c08300140f
;web3
       HEX fc0220c08304402f
;web4
       HEX f04040208402023f
       HEX 
;web5
       HEX e0408084a1010207
;web6
       HEX f00804000020101f
;web7
       HEX e04410000008223f
;web8
       HEX fc003000000c002f
       HEX 
;spider1top_explode1
       HEX 0808
;spider1top_explode2
       HEX 0000
;spider1top_explode3
       HEX 0000
;spider1top_explode4
       HEX 0000
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 4dd9
;spider1bottom_explode2
       HEX 4dd9
;spider1bottom_explode3
       HEX 05d0
;spider1bottom_explode4
       HEX 0000
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 050000000000
       HEX 
;arrowbar2
       HEX 052800000000
;arrowbar3
       HEX 052940000000
;arrowbar4
       HEX 05294a000000
;arrowbar5
       HEX 05294a500000
;arrowbar6
       HEX 05294a528000
;arrowbar7
       HEX 0529
       HEX 4a529400
;arrowbar8
       HEX 05294a5294a0
;arrowbar_nolimit
       HEX b4d7a4bbbda0

 ORG $C600  ; *************

;tsbanner13
       HEX 000000000000000000000000000003ffffffe000000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000019fe00000000000000000000000000000
       HEX 
;tsbanner15
       HEX 000000000000000000000000000000001e000000000000000000000000000000
       HEX 
;web1
       HEX ffffffffffffffff
;web2
       HEX f844003ffc00221f
;web3
       HEX fa0140308c028047
;web4
       HEX f82020508a04043f
       HEX 
;web5
       HEX f84081024081020f
;web6
       HEX f0100a000050081f
;web7
       HEX e08220000004411f
;web8
       HEX f200c00000030047
       HEX 
;spider1top_explode1
       HEX 0410
;spider1top_explode2
       HEX 0000
;spider1top_explode3
       HEX 0000
;spider1top_explode4
       HEX 0000
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 65d3
;spider1bottom_explode2
       HEX 65d3
;spider1bottom_explode3
       HEX 25d2
;spider1bottom_explode4
       HEX 0080
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 030000000000
       HEX 
;arrowbar2
       HEX 031800000000
;arrowbar3
       HEX 0318c0000000
;arrowbar4
       HEX 0318c6000000
;arrowbar5
       HEX 0318c6300000
;arrowbar6
       HEX 0318c6318000
;arrowbar7
       HEX 0318
       HEX c6318c00
;arrowbar8
       HEX 0318c6318c60
;arrowbar_nolimit
       HEX b5d7aea08460

 ORG $C700  ; *************

;tsbanner13
       HEX 00000000000000000000000000007ffffffffe00000000000000000000000000
       HEX 
;tsbanner14
       HEX 000000000000000000000000000000011fe00000000000000000000000000000
       HEX 
;tsbanner15
       HEX 000000000000000000000000000000003f000000000000000000000000000000
       HEX 
;web1
       HEX ffffffffffffffff
;web2
       HEX f88200008000413f
;web3
       HEX f200800ff0010047
;web4
       HEX f820208cb104043f
       HEX 
;web5
       HEX fffffffdbfffffff
;web6
       HEX f8101103c088081f
;web7
       HEX f10140000002809f
;web8
       HEX f101000000008087
       HEX 
;spider1top_explode1
       HEX 0000
;spider1top_explode2
       HEX 0000
;spider1top_explode3
       HEX 0000
;spider1top_explode4
       HEX 0000
;spider1top_explode5
       HEX 0000
;spider1bottom_explode1
       HEX 15d4
;spider1bottom_explode2
       HEX 15d4
;spider1bottom_explode3
       HEX 15d4
;spider1bottom_explode4
       HEX 05d0
;spider1bottom_explode5
       HEX 0000
;arrowbar0
       HEX 000000000000
;arrowbar1
       HEX 070000000000
       HEX 
;arrowbar2
       HEX 073800000000
;arrowbar3
       HEX 0739c0000000
;arrowbar4
       HEX 0739ce000000
;arrowbar5
       HEX 0739ce700000
;arrowbar6
       HEX 0739ce738000
;arrowbar7
       HEX 0739
       HEX ce739c00
;arrowbar8
       HEX 0739ce739ce0
;arrowbar_nolimit
       HEX ffffffffffe0

 ORG $C800  ; *************
dmahole_4
.
 ; 

.L02529 ;  rem ** include atarivox assembly code

.L02530 ;  inline 7800vox.asm

 include 7800vox.asm

included.7800vox.asm
 = 1
.
 ; 

.doeachbatmove
 ; doeachbatmove

.
 ; 

.L02531 ;  rem ** this will stop the monster when one is killed by a arrow

.L02532 ;  if playerdeathflag = 1 then goto skipmove3

	LDA playerdeathflag
	CMP #1
     BNE .skipL02532
.condpart849
 jmp .skipmove3

.skipL02532
.
 ; 

.dowizmove
 ; dowizmove

.
 ; 

.L02533 ;  rem "up left down right"

.L02534 ;  if tempdir = 0 then tempy = tempy - 1 : return

	LDA tempdir
	CMP #0
     BNE .skipL02534
.condpart850
	LDA tempy
	SEC
	SBC #1
	STA tempy
  RTS
.skipL02534
.L02535 ;  if tempdir = 1 then tempx = tempx - 1 : return

	LDA tempdir
	CMP #1
     BNE .skipL02535
.condpart851
	LDA tempx
	SEC
	SBC #1
	STA tempx
  RTS
.skipL02535
.L02536 ;  if tempdir = 2 then tempy = tempy + 1 : return

	LDA tempdir
	CMP #2
     BNE .skipL02536
.condpart852
	LDA tempy
	CLC
	ADC #1
	STA tempy
  RTS
.skipL02536
.L02537 ;  if tempdir = 3 then tempx = tempx + 1 : return

	LDA tempdir
	CMP #3
     BNE .skipL02537
.condpart853
	LDA tempx
	CLC
	ADC #1
	STA tempx
  RTS
.skipL02537
.skipmove3
 ; skipmove3

.L02538 ;  return

  RTS
.
 ; 

.newscreen
 ; newscreen

.L02539 ;  if screen = 0 then memcpy screenram Dungeon 1120

	LDA screen
	CMP #0
     BNE .skipL02539
.condpart854
 ldy #0
memcpyloop89
 lda Dungeon+0,y
 sta screenram+0,y
 dey
 bne memcpyloop89
 ldy #0
memcpyloop90
 lda Dungeon+256,y
 sta screenram+256,y
 dey
 bne memcpyloop90
 ldy #0
memcpyloop91
 lda Dungeon+512,y
 sta screenram+512,y
 dey
 bne memcpyloop91
 ldy #0
memcpyloop92
 lda Dungeon+768,y
 sta screenram+768,y
 dey
 bne memcpyloop92
 ldy #96
memcpyloop93
 lda Dungeon-1+1024,y
 sta screenram-1+1024,y
 dey
 bne memcpyloop93
 ldy #96
memcpyloop94
 lda Dungeon-1,y
 sta screenram-1,y
 dey
 bne memcpyloop94
.skipL02539
.L02540 ;  return

  RTS
.
 ; 

.L02541 ;  rem <---- Debounce subs for moving the joystick around the menu options---->

.
 ; 

.menumovedown
 ; menumovedown

.L02542 ;  if !joy0down then menubary = menubary + 8 : playsfx sfx_menumove3 : return

 lda #$20
 bit SWCHA
	BEQ .skipL02542
.condpart855
	LDA menubary
	CLC
	ADC #8
	STA menubary
    lda #<sfx_menumove3
    sta temp1
    lda #>sfx_menumove3
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02542
.L02543 ;  drawscreen

 jsr drawscreen
.L02544 ;  goto menumovedown

 jmp .menumovedown

.
 ; 

.menumoveup
 ; menumoveup

.L02545 ;  if !joy0up then menubary = menubary - 8 : playsfx sfx_menumove3 : return

 lda #$10
 bit SWCHA
	BEQ .skipL02545
.condpart856
	LDA menubary
	SEC
	SBC #8
	STA menubary
    lda #<sfx_menumove3
    sta temp1
    lda #>sfx_menumove3
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02545
.L02546 ;  drawscreen

 jsr drawscreen
.L02547 ;  goto menumoveup

 jmp .menumoveup

.
 ; 

.skillselectright
 ; skillselectright

.L02548 ;  if !joy0right then skill = skill + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02548
.condpart857
	LDA skill
	CLC
	ADC #1
	STA skill
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02548
.L02549 ;  goto skillselectright

 jmp .skillselectright

.
 ; 

.skillselectleft
 ; skillselectleft

.L02550 ;  if !joy0left then skill = skill - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02550
.condpart858
	LDA skill
	SEC
	SBC #1
	STA skill
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02550
.L02551 ;  goto skillselectleft

 jmp .skillselectleft

.
 ; 

.scoreselectright
 ; scoreselectright

.L02552 ;  if !joy0right then scorevalue = scorevalue + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02552
.condpart859
	LDA scorevalue
	CLC
	ADC #1
	STA scorevalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02552
.L02553 ;  goto scoreselectright

 jmp .scoreselectright

.
 ; 

.scoreselectleft
 ; scoreselectleft

.L02554 ;  if !joy0left then scorevalue = scorevalue - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02554
.condpart860
	LDA scorevalue
	SEC
	SBC #1
	STA scorevalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02554
.L02555 ;  goto scoreselectleft

 jmp .scoreselectleft

.
 ; 

.speedselect
 ; speedselect

.L02556 ;  if speedvalue = 2  &&  joy0left then return

	LDA speedvalue
	CMP #2
     BNE .skipL02556
.condpart861
 bit SWCHA
	BVS .skip861then
.condpart862
  RTS
.skip861then
.skipL02556
.L02557 ;  if speedvalue = 1  &&  joy0right then return

	LDA speedvalue
	CMP #1
     BNE .skipL02557
.condpart863
 bit SWCHA
	BMI .skip863then
.condpart864
  RTS
.skip863then
.skipL02557
.L02558 ;  if !joy0right then playsfx sfx_menuselect : speedvalue = 2 : return

 bit SWCHA
	BPL .skipL02558
.condpart865
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #2
	STA speedvalue
  RTS
.skipL02558
.L02559 ;  if !joy0left then playsfx sfx_menuselect : speedvalue = 1 : return

 bit SWCHA
	BVC .skipL02559
.condpart866
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA speedvalue
  RTS
.skipL02559
.L02560 ;  goto speedselect

 jmp .speedselect

.
 ; 

.godselect
 ; godselect

.L02561 ;  if godvalue = 1  &&  joy0left then return

	LDA godvalue
	CMP #1
     BNE .skipL02561
.condpart867
 bit SWCHA
	BVS .skip867then
.condpart868
  RTS
.skip867then
.skipL02561
.L02562 ;  if godvalue = 2  &&  joy0right then return

	LDA godvalue
	CMP #2
     BNE .skipL02562
.condpart869
 bit SWCHA
	BMI .skip869then
.condpart870
  RTS
.skip869then
.skipL02562
.L02563 ;  if !joy0right then playsfx sfx_menuselect : godvalue = 1 : return

 bit SWCHA
	BPL .skipL02563
.condpart871
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #1
	STA godvalue
  RTS
.skipL02563
.L02564 ;  if !joy0left then playsfx sfx_menuselect : godvalue = 2 : return

 bit SWCHA
	BVC .skipL02564
.condpart872
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
	LDA #2
	STA godvalue
  RTS
.skipL02564
.L02565 ;  goto godselect

 jmp .godselect

.
 ; 

.colorselectright
 ; colorselectright

.L02566 ;  if !joy0right then colorvalue = colorvalue + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02566
.condpart873
	LDA colorvalue
	CLC
	ADC #1
	STA colorvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02566
.L02567 ;  goto colorselectright

 jmp .colorselectright

.
 ; 

.colorselectleft
 ; colorselectleft

.L02568 ;  if !joy0left then colorvalue = colorvalue - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02568
.condpart874
	LDA colorvalue
	SEC
	SBC #1
	STA colorvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02568
.L02569 ;  goto colorselectleft

 jmp .colorselectleft

.
 ; 

.levelmoveright
 ; levelmoveright

.L02570 ;  if !joy0right then levelvalue = levelvalue + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02570
.condpart875
	LDA levelvalue
	CLC
	ADC #1
	STA levelvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02570
.L02571 ;  goto levelmoveright

 jmp .levelmoveright

.
 ; 

.levelmoveleft
 ; levelmoveleft

.L02572 ;  if !joy0left then levelvalue = levelvalue - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02572
.condpart876
	LDA levelvalue
	SEC
	SBC #1
	STA levelvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02572
.L02573 ;  goto levelmoveleft

 jmp .levelmoveleft

.
 ; 

.livesmoveright
 ; livesmoveright

.L02574 ;  if !joy0right then livesvalue = livesvalue + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02574
.condpart877
	LDA livesvalue
	CLC
	ADC #1
	STA livesvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02574
.L02575 ;  goto livesmoveright

 jmp .livesmoveright

.
 ; 

.livesmoveleft
 ; livesmoveleft

.L02576 ;  if !joy0left then livesvalue = livesvalue - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02576
.condpart878
	LDA livesvalue
	SEC
	SBC #1
	STA livesvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02576
.L02577 ;  goto livesmoveleft

 jmp .livesmoveleft

.
 ; 

.arrowsmoveright
 ; arrowsmoveright

.L02578 ;  if !joy0right then arrowsvalue = arrowsvalue + 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BPL .skipL02578
.condpart879
	LDA arrowsvalue
	CLC
	ADC #1
	STA arrowsvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02578
.L02579 ;  goto arrowsmoveright

 jmp .arrowsmoveright

.
 ; 

.arrowsmoveleft
 ; arrowsmoveleft

.L02580 ;  if !joy0left then arrowsvalue = arrowsvalue - 1 : playsfx sfx_menuselect : return

 bit SWCHA
	BVC .skipL02580
.condpart880
	LDA arrowsvalue
	SEC
	SBC #1
	STA arrowsvalue
    lda #<sfx_menuselect
    sta temp1
    lda #>sfx_menuselect
    sta temp2
    lda #0
    sta temp3
    jsr schedulesfx
  RTS
.skipL02580
.L02581 ;  goto arrowsmoveleft

 jmp .arrowsmoveleft

.
 ; 

.L02582 ;  rem <----End debounce subs for moving the joystick around the menu options---->

.
 ; 

.preinit
 ; preinit

.
 ; 

.L02583 ;  rem ** re-enable the pause feature

.L02584 ;  pausedisable = 0

	LDA #0
	STA pausedisable
.
 ; 

.L02585 ;  rem ** if using dev mode we don't want a skill level set

.L02586 ;  if gamemode = 1 then skill = 0

	LDA gamemode
	CMP #1
     BNE .skipL02586
.condpart881
	LDA #0
	STA skill
.skipL02586
.
 ; 

.L02587 ;  rem ** in standard game mode we always want to start the game with a score of 0

.L02588 ;  if gamemode = 0 then scorevalue = 1

	LDA gamemode
	CMP #0
     BNE .skipL02588
.condpart882
	LDA #1
	STA scorevalue
.skipL02588
.
 ; 

.L02589 ;  score2flag = 0 : score3flag = 0 : score4flag = 0 : score5flag = 0

	LDA #0
	STA score2flag
	STA score3flag
	STA score4flag
	STA score5flag
.L02590 ;  if skill = 1 then arrowsvalue = 9 : speedvalue = 1 : levelvalue = 1 : livesvalue = 6

	LDA skill
	CMP #1
     BNE .skipL02590
.condpart883
	LDA #9
	STA arrowsvalue
	LDA #1
	STA speedvalue
	STA levelvalue
	LDA #6
	STA livesvalue
.skipL02590
.L02591 ;  if skill = 2 then arrowsvalue = 8 : speedvalue = 1 : levelvalue = 1 : livesvalue = 5

	LDA skill
	CMP #2
     BNE .skipL02591
.condpart884
	LDA #8
	STA arrowsvalue
	LDA #1
	STA speedvalue
	STA levelvalue
	LDA #5
	STA livesvalue
.skipL02591
.L02592 ;  if skill = 3 then arrowsvalue = 7 : speedvalue = 1 : levelvalue = 2 : livesvalue = 4 : score2flag = 1

	LDA skill
	CMP #3
     BNE .skipL02592
.condpart885
	LDA #7
	STA arrowsvalue
	LDA #1
	STA speedvalue
	LDA #2
	STA levelvalue
	LDA #4
	STA livesvalue
	LDA #1
	STA score2flag
.skipL02592
.L02593 ;  if skill = 4 then arrowsvalue = 6 : speedvalue = 1 : levelvalue = 3 : livesvalue = 3 : bunkerbuster = 1 : score2flag = 1 : score3flag = 1

	LDA skill
	CMP #4
     BNE .skipL02593
.condpart886
	LDA #6
	STA arrowsvalue
	LDA #1
	STA speedvalue
	LDA #3
	STA levelvalue
	STA livesvalue
	LDA #1
	STA bunkerbuster
	STA score2flag
	STA score3flag
.skipL02593
.
 ; 

.L02594 ;  rem ** this allows for switching back to the main loop when the fire button is released

.
 ; 

.L02595 ;  if joy0fire then fireheld = 1

 bit sINPT1
	BPL .skipL02595
.condpart887
	LDA #1
	STA fireheld
.skipL02595
.
 ; 

.L02596 ;  if frame > 0 then rand16 = frame

	LDA #0
	CMP frame
     BCS .skipL02596
.condpart888
	LDA frame
	STA rand16
.skipL02596
.
 ; 

.L02597 ;  restorescreen

 jsr restorescreen
.L02598 ;  drawscreen

 jsr drawscreen
.
 ; 

.L02599 ;  rem ** when the fire button is released, go to the init sub to start the game

.L02600 ;  rem ** flags set to 0 so they don't transfer to the start of the game when quickly switching from demo mode to the real game.

.L02601 ;  if !joy0fire then clearscreen : SBACKGRND = 0 : speak entering : freezeflag = 0 : playerdeathflag = 0 : quiverflag = 0 : AUDV0 = 0 : AUDV1 = 0 : goto init

 bit sINPT1
	BMI .skipL02601
.condpart889
 jsr clearscreen
	LDA #0
	STA SBACKGRND
    SPEAK entering
	STA freezeflag
	STA playerdeathflag
	STA quiverflag
	STA AUDV0
	STA AUDV1
 jmp .init

.skipL02601
.L02602 ;  goto preinit

 jmp .preinit

.
 ; 

.gameoverrestart
 ; gameoverrestart

.L02603 ;  rem ** This command erases all sprites and characters that you've previously drawn on the screen, so you can draw the next screen.

.L02604 ;  clearscreen

 jsr clearscreen
.
 ; 

.L02605 ;  AUDV0 = 0 : AUDV1 = 0

	LDA #0
	STA AUDV0
	STA AUDV1
.L02606 ;  rem ** this allows for switching back to the main loop when the fire button is released

.L02607 ;  drawscreen

 jsr drawscreen
.L02608 ;  if !joy0fire  &&  gamemode = 0 then drawwait : drawhiscores single : drawwait : goto titlescreen

 bit sINPT1
	BMI .skipL02608
.condpart890
	LDA gamemode
	CMP #0
     BNE .skip890then
.condpart891
 jsr drawwait
 lda #1
 sta hsdisplaymode
 jsr loaddifficultytable
 jsr hscdrawscreen
 jsr savedifficultytable
 jsr drawwait
 jmp .titlescreen

.skip890then
.skipL02608
.L02609 ;  if !joy0fire  &&  gamemode = 1 then goto titlescreen

 bit sINPT1
	BMI .skipL02609
.condpart892
	LDA gamemode
	CMP #1
     BNE .skip892then
.condpart893
 jmp .titlescreen

.skip892then
.skipL02609
.L02610 ;  goto gameoverrestart

 jmp .gameoverrestart

.
 ; 

.L02611 ;  rem ** reduce life counter when the player dies

.losealife
 ; losealife

.L02612 ;  if lifecounter > 1 then gosub deathspeak

	LDA #1
	CMP lifecounter
     BCS .skipL02612
.condpart894
 jsr .deathspeak

.skipL02612
.L02613 ;  if lifecounter = 9 then lifecounter = 8 : return

	LDA lifecounter
	CMP #9
     BNE .skipL02613
.condpart895
	LDA #8
	STA lifecounter
  RTS
.skipL02613
.L02614 ;  if lifecounter = 8 then lifecounter = 7 : return

	LDA lifecounter
	CMP #8
     BNE .skipL02614
.condpart896
	LDA #7
	STA lifecounter
  RTS
.skipL02614
.L02615 ;  if lifecounter = 7 then lifecounter = 6 : return

	LDA lifecounter
	CMP #7
     BNE .skipL02615
.condpart897
	LDA #6
	STA lifecounter
  RTS
.skipL02615
.L02616 ;  if lifecounter = 6 then lifecounter = 5 : return

	LDA lifecounter
	CMP #6
     BNE .skipL02616
.condpart898
	LDA #5
	STA lifecounter
  RTS
.skipL02616
.L02617 ;  if lifecounter = 5 then lifecounter = 4 : return

	LDA lifecounter
	CMP #5
     BNE .skipL02617
.condpart899
	LDA #4
	STA lifecounter
  RTS
.skipL02617
.L02618 ;  if lifecounter = 4 then lifecounter = 3 : return

	LDA lifecounter
	CMP #4
     BNE .skipL02618
.condpart900
	LDA #3
	STA lifecounter
  RTS
.skipL02618
.L02619 ;  if lifecounter = 3 then lifecounter = 2 : return

	LDA lifecounter
	CMP #3
     BNE .skipL02619
.condpart901
	LDA #2
	STA lifecounter
  RTS
.skipL02619
.L02620 ;  if lifecounter = 2 then lifecounter = 1 : return

	LDA lifecounter
	CMP #2
     BNE .skipL02620
.condpart902
	LDA #1
	STA lifecounter
  RTS
.skipL02620
.L02621 ;  rem v185

.L02622 ;  if lifecounter = 1 then lifecounter = 0 : gameoverflag = 1 : countdownseconds = 1 : speak gameover : return

	LDA lifecounter
	CMP #1
     BNE .skipL02622
.condpart903
	LDA #0
	STA lifecounter
	LDA #1
	STA gameoverflag
	STA countdownseconds
    SPEAK gameover
  RTS
.skipL02622
.L02623 ;  return

  RTS
.
 ; 

.L02624 ;  rem ** increase life counter when you've picked up enough treasures to gain a life

.L02625 ;  rem ** the maximum number of lives you can have is 9

.gainalife
 ; gainalife

.L02626 ;  if lifecounter = 9 then lifecounter = 9 : return

	LDA lifecounter
	CMP #9
     BNE .skipL02626
.condpart904
	LDA #9
	STA lifecounter
  RTS
.skipL02626
.L02627 ;  if lifecounter = 8 then lifecounter = 9 : return

	LDA lifecounter
	CMP #8
     BNE .skipL02627
.condpart905
	LDA #9
	STA lifecounter
  RTS
.skipL02627
.L02628 ;  if lifecounter = 7 then lifecounter = 8 : return

	LDA lifecounter
	CMP #7
     BNE .skipL02628
.condpart906
	LDA #8
	STA lifecounter
  RTS
.skipL02628
.L02629 ;  if lifecounter = 6 then lifecounter = 7 : return

	LDA lifecounter
	CMP #6
     BNE .skipL02629
.condpart907
	LDA #7
	STA lifecounter
  RTS
.skipL02629
.L02630 ;  if lifecounter = 5 then lifecounter = 6 : return

	LDA lifecounter
	CMP #5
     BNE .skipL02630
.condpart908
	LDA #6
	STA lifecounter
  RTS
.skipL02630
.L02631 ;  if lifecounter = 4 then lifecounter = 5 : return

	LDA lifecounter
	CMP #4
     BNE .skipL02631
.condpart909
	LDA #5
	STA lifecounter
  RTS
.skipL02631
.L02632 ;  if lifecounter = 3 then lifecounter = 4 : return

	LDA lifecounter
	CMP #3
     BNE .skipL02632
.condpart910
	LDA #4
	STA lifecounter
  RTS
.skipL02632
.L02633 ;  if lifecounter = 2 then lifecounter = 3 : return

	LDA lifecounter
	CMP #2
     BNE .skipL02633
.condpart911
	LDA #3
	STA lifecounter
  RTS
.skipL02633
.L02634 ;  if lifecounter = 1 then lifecounter = 2 : return

	LDA lifecounter
	CMP #1
     BNE .skipL02634
.condpart912
	LDA #2
	STA lifecounter
  RTS
.skipL02634
.L02635 ;  return

  RTS
.
 ; 

.L02636 ;  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 

.L02637 ;  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 

.L02638 ;  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.

.L02639 ;  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,

.L02640 ;  rem ** so you'll have to experiment with their location in your own code.

.L02641 ;  dmahole 5

 jmp dmahole_5
 echo "  ","  ","  ","  ",[($D000 - .)]d , "bytes of ROM space left in DMA hole 4."

 ORG $D000  ; *************

ts_back1
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff8000
       HEX 
ts_back2
       HEX 0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffc0000
       HEX 
ts_back3
       HEX 000003fffffffffffffffffffffffffffffffffffffffffffffffffffffff000
       HEX 
ts_back4
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
ts_back5
       HEX 00000003ffffffffffffffffffffffffffffffffffffffffffffffffffe00000
       HEX 
ts_back6
       HEX 0000000001ffffffffffffffffffffffffffffffffffffffffffffffe0000000
       HEX 
ts_back7
       HEX 000000000000000000000000001ffffffffffff8000000000000000000000000
       HEX 
wizlefttop1
       HEX 3fe3
wizlefttop2
       HEX 1fe4
wizrighttop1
       HEX c7fc
wizrighttop2
       HEX 27f8
wizleftbottom1
       HEX 0ffc
wizleftbottom2
       HEX 07f8
wizrightbottom1
       HEX 3ff0
wizrightbottom2
       HEX 1fe0

 ORG $D100  ; *************

;ts_back1
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff8000
       HEX 
;ts_back2
       HEX 00000007fffffffffffffffffffffffffffffffffffffffffffffffffff80000
       HEX 
;ts_back3
       HEX 000007fffffffffffffffffffffffffffffffffffffffffffffffffffffff000
       HEX 
;ts_back4
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff8000
       HEX 
;ts_back5
       HEX 00000007fffffffffffffffffffffffffffffffffffffffffffffffffff00000
       HEX 
;ts_back6
       HEX 0000000007fffffffffffffffffffffffffffffffffffffffffffffff0000000
       HEX 
;ts_back7
       HEX 00000000000003ffe00000001ffffffffffffffffc0000001ffffc0000000000
       HEX 
;wizlefttop1
       HEX 1fe6
;wizlefttop2
       HEX 0fe4
;wizrighttop1
       HEX 67f8
;wizrighttop2
       HEX 27f0
;wizleftbottom1
       HEX 07fc
;wizleftbottom2
       HEX 07f8
;wizrightbottom1
       HEX 3fe0
;wizrightbottom2
       HEX 1fe0

 ORG $D200  ; *************

;ts_back1
       HEX 0000003fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
;ts_back2
       HEX 00000007fffffffffffffffffffffffffffffffffffffffffffffffffff80000
       HEX 
;ts_back3
       HEX 000007fffffffffffffffffffffffffffffffffffffffffffffffffffffff000
       HEX 
;ts_back4
       HEX 000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff8000
       HEX 
;ts_back5
       HEX 00000007fffffffffffffffffffffffffffffffffffffffffffffffffff80000
       HEX 
;ts_back6
       HEX 000000000ffffffffffffffffffffffffffffffffffffffffffffffffc000000
       HEX 
;ts_back7
       HEX 0000000000000fffffffffffffffffffffffffffffffffffffffff8000000000
       HEX 
;wizlefttop1
       HEX 02fc
;wizlefttop2
       HEX 07ec
;wizrighttop1
       HEX 3f40
;wizrighttop2
       HEX 37e0
;wizleftbottom1
       HEX 0ff8
;wizleftbottom2
       HEX 07f0
;wizrightbottom1
       HEX 1ff0
;wizrightbottom2
       HEX 0fe0

 ORG $D300  ; *************

;ts_back1
       HEX 0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffc0000
       HEX 
;ts_back2
       HEX 0000000ffffffffffffffffffffffffffffffffffffffffffffffffffff80000
       HEX 
;ts_back3
       HEX 000007fffffffffffffffffffffffffffffffffffffffffffffffffffffff800
       HEX 
;ts_back4
       HEX 000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffc000
       HEX 
;ts_back5
       HEX 0000000ffffffffffffffffffffffffffffffffffffffffffffffffffffc0000
       HEX 
;ts_back6
       HEX 000000001ffffffffffffffffffffffffffffffffffffffffffffffffe000000
       HEX 
;ts_back7
       HEX 0000000000001fffffffffffffffffffffffffffffffffffffffffe000000000
       HEX 
;wizlefttop1
       HEX 04f8
;wizlefttop2
       HEX 02f8
;wizrighttop1
       HEX 1f20
;wizrighttop2
       HEX 1f40
;wizleftbottom1
       HEX 0ff0
;wizleftbottom2
       HEX 07f0
;wizrightbottom1
       HEX 0ff0
;wizrightbottom2
       HEX 0fe0

 ORG $D400  ; *************

;ts_back1
       HEX 00000003ffffffffffffffffffffffffffffffffffffffffffffffffffe00000
       HEX 
;ts_back2
       HEX 0000001ffffffffffffffffffffffffffffffffffffffffffffffffffffc0000
       HEX 
;ts_back3
       HEX 000007fffffffffffffffffffffffffffffffffffffffffffffffffffffff800
       HEX 
;ts_back4
       HEX 000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffc000
       HEX 
;ts_back5
       HEX 0000001ffffffffffffffffffffffffffffffffffffffffffffffffffffc0000
       HEX 
;ts_back6
       HEX 000000007fffffffffffffffffffffffffffffffffffffffffffffffff000000
       HEX 
;ts_back7
       HEX 0000000000003fffffffffffffffffffffffffffffffffffffffffe000000000
       HEX 
;wizlefttop1
       HEX 04e0
;wizlefttop2
       HEX 04f0
;wizrighttop1
       HEX 0720
;wizrighttop2
       HEX 0f20
;wizleftbottom1
       HEX 07f0
;wizleftbottom2
       HEX 07f0
;wizrightbottom1
       HEX 0fe0
;wizrightbottom2
       HEX 0fe0

 ORG $D500  ; *************

;ts_back1
       HEX 000000007fffffffffffffffffffffffffffffffffffffffffffffffff000000
       HEX 
;ts_back2
       HEX 0000001ffffffffffffffffffffffffffffffffffffffffffffffffffffe0000
       HEX 
;ts_back3
       HEX 00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff800
       HEX 
;ts_back4
       HEX 000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffe000
       HEX 
;ts_back5
       HEX 0000001ffffffffffffffffffffffffffffffffffffffffffffffffffffe0000
       HEX 
;ts_back6
       HEX 00000000ffffffffffffffffffffffffffffffffffffffffffffffffff800000
       HEX 
;ts_back7
       HEX 000000000000fffffffffffffffffffffffffffffffffffffffffff000000000
       HEX 
;wizlefttop1
       HEX 07c0
;wizlefttop2
       HEX 04e0
;wizrighttop1
       HEX 03e0
;wizrighttop2
       HEX 0720
;wizleftbottom1
       HEX 07e0
;wizleftbottom2
       HEX 23e0
;wizrightbottom1
       HEX 07e0
;wizrightbottom2
       HEX 07c4

 ORG $D600  ; *************

;ts_back1
       HEX 000000000ffffffffffffffffffffffffffffffffffffffffffffffff8000000
       HEX 
;ts_back2
       HEX 0000003fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
;ts_back3
       HEX 000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffe000
       HEX 
;ts_back4
       HEX 000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffe000
       HEX 
;ts_back5
       HEX 0000003ffffffffffffffffffffffffffffffffffffffffffffffffffffe0000
       HEX 
;ts_back6
       HEX 00000000ffffffffffffffffffffffffffffffffffffffffffffffffffc00000
       HEX 
;ts_back7
       HEX 000000000007fffffffffffffffffffffffffffffffffffffffffff800000000
       HEX 
;wizlefttop1
       HEX 03e0
;wizlefttop2
       HEX 07c0
;wizrighttop1
       HEX 07c0
;wizrighttop2
       HEX 03e0
;wizleftbottom1
       HEX 03e0
;wizleftbottom2
       HEX 33e0
;wizrightbottom1
       HEX 07c0
;wizrightbottom2
       HEX 07cc

 ORG $D700  ; *************

;ts_back1
       HEX 0000000000ffffffffffffffffffffffffffffffffffffffffffffff80000000
       HEX 
;ts_back2
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
;ts_back3
       HEX 0000007fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
;ts_back4
       HEX 000003ffffffffffffffffffffffffffffffffffffffffffffffffffffffe000
       HEX 
;ts_back5
       HEX 0000003fffffffffffffffffffffffffffffffffffffffffffffffffffff0000
       HEX 
;ts_back6
       HEX 00000001ffffffffffffffffffffffffffffffffffffffffffffffffffe00000
       HEX 
;ts_back7
       HEX 00000000003fffffffffffffffffffffffffffffffffffffffffffff00000000
       HEX 
;wizlefttop1
       HEX 0000
;wizlefttop2
       HEX 03e0
;wizrighttop1
       HEX 0000
;wizrighttop2
       HEX 07c0
;wizleftbottom1
       HEX e3e1
;wizleftbottom2
       HEX 13e4
;wizrightbottom1
       HEX 87c7
;wizrightbottom2
       HEX 27c8

 ORG $D800  ; *************
dmahole_5
.
 ; 

.L02642 ;  rem <--- Start Audio Code --->

.
 ; 

.L02643 ;  rem ** the next very long section has all of the audio code for the game

.
 ; 

.L02644 ;  data sfx_enemy_shoot

	JMP .skipL02644
sfx_enemy_shoot
	.byte   $10,$01,$03 ; version, priority, frames per chunk

	.byte   $18,$08,$01 ; first chunk of freq,channel,volume data 

	.byte   $19,$08,$05

	.byte   $19,$08,$05

	.byte   $19,$08,$05

	.byte   $19,$08,$05

	.byte   $1C,$08,$02

	.byte   $1C,$08,$02

	.byte   $1C,$08,$02

	.byte   $1C,$08,$02

	.byte   $1C,$08,$02

	.byte   $1E,$08,$01

	.byte   $1E,$08,$01

	.byte   $1E,$08,$01

	.byte   $1E,$08,$01

	.byte   $1E,$08,$01

	.byte   $00,$00,$00

.skipL02644
.
 ; 

.L02645 ;  data sfx_player_shoot

	JMP .skipL02645
sfx_player_shoot
	.byte   $10,$04,$01 ; version, priority, frames per chunk

	.byte   $06,$08,$06 ; first chunk of freq,channel,volume data 

	.byte   $06,$08,$06

	.byte   $06,$08,$06

	.byte   $05,$08,$05

	.byte   $05,$08,$05

	.byte   $05,$08,$05

	.byte   $04,$08,$04

	.byte   $04,$08,$04

	.byte   $03,$08,$03

	.byte   $03,$08,$03

	.byte   $02,$08,$01

	.byte   $01,$08,$01

	.byte   $01,$08,$01

	.byte   $00,$00,$00 

.skipL02645
.
 ; 

.L02646 ;  data sfx_heartbeat

	JMP .skipL02646
sfx_heartbeat
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$02 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02646
.
 ; 

.L02647 ;  data sfx_heartbeat1

	JMP .skipL02647
sfx_heartbeat1
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$04 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02647
.
 ; 

.L02648 ;  data sfx_heartbeat2

	JMP .skipL02648
sfx_heartbeat2
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$06 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02648
.
 ; 

.L02649 ;  data sfx_heartbeat3

	JMP .skipL02649
sfx_heartbeat3
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$08 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02649
.
 ; 

.L02650 ;  data sfx_heartbeat4

	JMP .skipL02650
sfx_heartbeat4
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$0A ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02650
.
 ; 

.L02651 ;  data sfx_heartbeat_demo1

	JMP .skipL02651
sfx_heartbeat_demo1
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$02 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02651
.
 ; 

.L02652 ;  data sfx_heartbeat_demo2

	JMP .skipL02652
sfx_heartbeat_demo2
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$03 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02652
.
 ; 

.L02653 ;  data sfx_heartbeat_demo3

	JMP .skipL02653
sfx_heartbeat_demo3
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$04 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02653
.
 ; 

.L02654 ;  data sfx_heartbeat_demo4

	JMP .skipL02654
sfx_heartbeat_demo4
	.byte   $10,$04,$14 ; version, priority, frames per chunk

	.byte   $18,$06,$05 ; first chunk of freq,channel,volume data 

	.byte   $10,$06,$00

	.byte   $00,$00,$00 

.skipL02654
.
 ; 

.L02655 ;  data sfx_nofire

	JMP .skipL02655
sfx_nofire
	.byte   $10,$04,$06 ; version, priority, frames per chunk

	.byte   $04,$06,$06 ; first chunk of freq,channel,volume data 

	.byte   $00,$00,$00 

.skipL02655
.
 ; 

.L02656 ;  data sfx_buzz

	JMP .skipL02656
sfx_buzz
	.byte   $10,$10,$02 ; version, priority, frames per chunk

	.byte   $10,$03,$05 ; first chunk of freq,channel,volume data 

	.byte   $04,$08,$05 

	.byte   $10,$03,$05 

	.byte   $04,$08,$04

	.byte   $10,$03,$04 

	.byte   $04,$08,$04

	.byte   $10,$03,$03 

	.byte   $04,$08,$03 

	.byte   $10,$03,$03

	.byte   $04,$08,$02 

	.byte   $10,$03,$02 

	.byte   $04,$08,$02

	.byte   $10,$03,$01

	.byte   $04,$08,$01 

	.byte   $10,$03,$01 

	.byte   $00,$00,$00 

.skipL02656
.
 ; 

.L02657 ;  data sfx_buzz_demo

	JMP .skipL02657
sfx_buzz_demo
	.byte   $10,$10,$02 ; version, priority, frames per chunk

	.byte   $10,$03,$02 ; first chunk of freq,channel,volume data 

	.byte   $04,$08,$02 

	.byte   $04,$08,$02

	.byte   $10,$03,$02 

	.byte   $04,$08,$02

	.byte   $10,$03,$02 

	.byte   $04,$08,$01 

	.byte   $10,$03,$01 

	.byte   $04,$08,$01

	.byte   $10,$03,$01

	.byte   $00,$00,$00 

.skipL02657
.
 ; 

.L02658 ;  data sfx_deathsound

	JMP .skipL02658
sfx_deathsound
	.byte   $10,$12,$02 ; version, priority, frames per chunk

	.byte   $04,$03,$10 ; first chunk of freq,channel,volume data 

	.byte   $04,$08,$0E 

	.byte   $04,$03,$0D 

	.byte   $04,$08,$0C 

	.byte   $04,$03,$0B 

	.byte   $04,$08,$0A 

	.byte   $04,$03,$09 

	.byte   $04,$08,$08 

	.byte   $04,$03,$07 

	.byte   $04,$08,$06 

	.byte   $04,$03,$05 

	.byte   $04,$08,$04 

	.byte   $04,$03,$03 

	.byte   $04,$08,$02 

	.byte   $04,$03,$01 

	.byte   $00,$00,$00 

.skipL02658
.
 ; 

.L02659 ;  data sfx_pickup

	JMP .skipL02659
sfx_pickup
	.byte   $10,$2C,$01 ; version, priority, frames per chunk

	.byte   $18,$04,$08 ; first chunk of freq,channel,volume data 

	.byte   $1E,$04,$08

	.byte   $18,$04,$08

	.byte   $1E,$04,$08

	.byte   $14,$04,$08

	.byte   $00,$00,$00 

.skipL02659
.
 ; 

.L02660 ;  data sfx_explode

	JMP .skipL02660
sfx_explode
	.byte   $10,$2F,$02 ; version, priority, frames per chunk

	.byte   $1A,$03,$0a ; first chunk of freq,channel,volume data 

	.byte   $1A,$08,$0E 

	.byte   $1A,$03,$0D 

	.byte   $1A,$08,$0C 

	.byte   $1A,$03,$0B 

	.byte   $1A,$08,$0A 

	.byte   $1A,$03,$09 

	.byte   $1A,$03,$02 

	.byte   $1A,$03,$09 

	.byte   $1A,$03,$02 

	.byte   $1A,$03,$09 

	.byte   $1A,$03,$02 

	.byte   $1A,$03,$09 

	.byte   $1A,$03,$09 

	.byte   $1F,$08,$08 

	.byte   $1F,$03,$07 

	.byte   $1F,$08,$06 

	.byte   $1F,$03,$05 

	.byte   $1F,$08,$04 

	.byte   $1F,$03,$03 

	.byte   $1F,$08,$02 

	.byte   $1F,$03,$01 

	.byte   $00,$00,$00 

.skipL02660
.
 ; 

.L02661 ;  data copyrightsfx

	JMP .skipL02661
copyrightsfx
	.byte   $10,$08,$08 ; version, priority, frames per chunk

	.byte   $18,$06,$0a ; first chunk of freq,channel,volume data 

	.byte   $08,$06,$0a

	.byte   $01,$00,$00 

	.byte   $18,$06,$05

	.byte   $08,$06,$05

	.byte   $01,$00,$00 

	.byte   $18,$06,$04

	.byte   $08,$06,$04

	.byte   $01,$00,$00 

	.byte   $18,$06,$03

	.byte   $08,$06,$03

	.byte   $01,$00,$00 

	.byte   $18,$06,$02

	.byte   $08,$06,$02

	.byte   $01,$00,$00 

	.byte   $18,$06,$01

	.byte   $08,$06,$01

	.byte   $00,$00,$00 

.skipL02661
.
 ; 

.L02662 ;  data sfx_batdeath

	JMP .skipL02662
sfx_batdeath
	.byte   $10,$2E,$02 ; version, priority, frames per chunk

	.byte   $06,$03,$06 ; first chunk of freq,channel,volume data 

	.byte   $06,$08,$0E 

	.byte   $06,$03,$0D 

	.byte   $06,$08,$0C 

	.byte   $06,$03,$0B 

	.byte   $06,$08,$0A 

	.byte   $00,$00,$00 

.skipL02662
.
 ; 

.L02663 ;  data sfx_spiderdeath

	JMP .skipL02663
sfx_spiderdeath
	.byte   $10,$2D,$02 ; version, priority, frames per chunk

	.byte   $08,$03,$06 ; first chunk of freq,channel,volume data 

	.byte   $08,$08,$0A 

	.byte   $08,$03,$0B 

	.byte   $08,$08,$0C 

	.byte   $08,$03,$0D 

	.byte   $08,$08,$0E 

	.byte   $00,$00,$00 

.skipL02663
.
 ; 

.L02664 ;  data sfx_menumove

	JMP .skipL02664
sfx_menumove
	.byte   $10,$10,$02 ; version, priority, frames per chunk

	.byte   $08,$03,$02 ; first chunk of freq,channel,volume data 

	.byte   $14,$04,$04

	.byte   $00,$00,$00 

.skipL02664
.
 ; 

.L02665 ;  rem data sfx_menumove2

.L02666 ;  rem $10,$01,$00 ; version, priority, frames per chunk

.L02667 ;  rem $06,$0F,$04 ; first chunk of freq,channel,volume data

.L02668 ;  rem $07,$0F,$02

.L02669 ;  rem $08,$0F,$04

.L02670 ;  rem $04,$0F,$04

.L02671 ;  rem $02,$0F,$02

.L02672 ;  rem $00,$00,$00

.L02673 ;  rem end

.
 ; 

.L02674 ;  data sfx_menuselect

	JMP .skipL02674
sfx_menuselect
	.byte   $10,$04,$02 ; version, priority, frames per chunk

	.byte   $00,$06,$05 ; first chunk of freq,channel,volume data 

	.byte   $01,$06,$02 

	.byte   $02,$06,$01 

	.byte   $03,$06,$01

	.byte   $00,$00,$00 

.skipL02674
.
 ; 

.L02675 ;  data sfx_menumove2

	JMP .skipL02675
sfx_menumove2
	.byte   $10,$10,$02 ; version, priority, frames per chunk

	.byte   $1F,$03,$0F ; first chunk of freq,channel,volume data 

	.byte   $1F,$08,$0E 

	.byte   $1F,$03,$0D 

	.byte   $1F,$08,$0C 

	.byte   $1F,$03,$0B 

	.byte   $1F,$08,$0A 

	.byte   $1F,$03,$09 

	.byte   $1F,$08,$08 

	.byte   $1F,$03,$07 

	.byte   $1F,$08,$06 

	.byte   $1F,$03,$05 

	.byte   $1F,$08,$04 

	.byte   $1F,$03,$03 

	.byte   $1F,$08,$02 

	.byte   $1F,$03,$01 

	.byte   $00,$00,$00 

.skipL02675
.
 ; 

.L02676 ;  rem for moving up and down on the menu

.L02677 ;  data sfx_menumove3

	JMP .skipL02677
sfx_menumove3
	.byte   $10,$10,$02 ; version, priority, frames per chunk

	.byte   $1F,$03,$05 ; first chunk of freq,channel,volume data 

	.byte   $1F,$08,$04 

	.byte   $1F,$03,$04 

	.byte   $1F,$08,$03 

	.byte   $1F,$03,$03 

	.byte   $1F,$08,$03 

	.byte   $1F,$03,$02 

	.byte   $1F,$08,$02 

	.byte   $1F,$03,$02 

	.byte   $00,$00,$00 

.skipL02677
.
 ; 

.L02678 ;  data sfx_god

	JMP .skipL02678
sfx_god
	.byte    $10,$01,$00 ; version, priority, frames per chunk

	.byte    $00,$01,$08 ; first chunk of freq,channel,volume data

	.byte    $00,$01,$06

	.byte    $00,$01,$04

	.byte    $00,$00,$00

.skipL02678
.L02679 ;  data sfx_wiz

	JMP .skipL02679
sfx_wiz
	.byte    $10,$00,$01 ; version, priority, frames per chunk

	.byte    $00,$01,$04 ; first chunk of freq,channel,volume data

	.byte    $00,$01,$02 ; first chunk of freq,channel,volume data

	.byte    $00,$00,$00

.skipL02679
.
 ; 

.L02680 ;  data sfx_wor1

	JMP .skipL02680
sfx_wor1
	.byte    $10,$FF,$20 ; version, priority, frames per chunk

	.byte    $1D,$0C,$08 ; first chunk of freq,channel,volume data

	.byte    $1D,$0C,$08 

	.byte    $19,$0C,$08 

	.byte    $18,$0C,$08 

	.byte    $18,$0C,$08 

	.byte    $1D,$0C,$08

	.byte    $1D,$0C,$08 

	.byte    $00,$00,$00

.skipL02680
.L02681 ;  data sfx_wor2

	JMP .skipL02681
sfx_wor2
	.byte    $10,$FF,$20

	.byte    $1D,$04,$08 ; first chunk of freq,channel,volume data

	.byte    $1D,$04,$08 

	.byte    $19,$04,$08 

	.byte    $18,$04,$08 

	.byte    $18,$04,$08 

	.byte    $1D,$04,$08

	.byte    $1D,$04,$08 

	.byte    $00,$00,$00

.skipL02681
.
 ; 

.L02682 ;  data arp_god

	JMP .skipL02682
arp_god
	.byte    19,23,29,21

.skipL02682
.
 ; 

.L02683 ;  data sfx_wizwarp

	JMP .skipL02683
sfx_wizwarp
	.byte   $10,$00,$04

	.byte    $1F,$08,$08 ; first chunk of freq,channel,volume data

	.byte    $1C,$08,$08

	.byte    $18,$08,$08

	.byte    $14,$08,$08

	.byte    $10,$08,$08

	.byte    $0C,$08,$08

	.byte    $08,$08,$08

	.byte    $04,$08,$08

	.byte    $00,$08,$08

	.byte    $00,$00,$00

.skipL02683
.
 ; 

.L02684 ;  rem <--- End Audio Code --->

.
 ; 

.L02685 ;  rem ** This section calculates your current best score for the current game session

.L02686 ;  rem ** it has nothing to do with the high score tables, it shows your "best" score

.L02687 ;  rem ** on the title screen for the current session, regardless of the difficulty level played

.
 ; 

.HighScoreCalc
 ; HighScoreCalc

.
 ; 

.L02688 ;  Save_Score01 = sc1

	LDA sc1
	STA Save_Score01
.L02689 ;  Save_Score02 = sc2

	LDA sc2
	STA Save_Score02
.L02690 ;  Save_Score03 = sc3

	LDA sc3
	STA Save_Score03
.
 ; 

.L02691 ;  rem  ** Checks for a new high score.

.L02692 ;  if sc1  >  High_Score01 then goto New_High_Score

	LDA High_Score01
	CMP sc1
     BCS .skipL02692
.condpart913
 jmp .New_High_Score

.skipL02692
.L02693 ;  if sc1  <  High_Score01 then goto Skip_High_Score

	LDA sc1
	CMP High_Score01
     BCS .skipL02693
.condpart914
 jmp .Skip_High_Score

.skipL02693
.
 ; 

.L02694 ;  rem  ** First byte equal. Do the next test. 

.L02695 ;  if sc2  >  High_Score02 then goto New_High_Score

	LDA High_Score02
	CMP sc2
     BCS .skipL02695
.condpart915
 jmp .New_High_Score

.skipL02695
.L02696 ;  if sc2  <  High_Score02 then goto Skip_High_Score

	LDA sc2
	CMP High_Score02
     BCS .skipL02696
.condpart916
 jmp .Skip_High_Score

.skipL02696
.
 ; 

.L02697 ;  rem  ** Second byte equal. Do the next test. 

.L02698 ;  if sc3  >  High_Score03 then goto New_High_Score

	LDA High_Score03
	CMP sc3
     BCS .skipL02698
.condpart917
 jmp .New_High_Score

.skipL02698
.L02699 ;  if sc3  <  High_Score03 then goto Skip_High_Score

	LDA sc3
	CMP High_Score03
     BCS .skipL02699
.condpart918
 jmp .Skip_High_Score

.skipL02699
.
 ; 

.L02700 ;  rem  ** All bytes equal. Current score is the same as the high score.

.L02701 ;  goto Skip_High_Score

 jmp .Skip_High_Score

.
 ; 

.New_High_Score
 ; New_High_Score

.
 ; 

.L02702 ;  rem  ** save new high score.

.L02703 ;  High_Score01  =  sc1  :  High_Score02  =  sc2  :  High_Score03  =  sc3

	LDA sc1
	STA High_Score01
	LDA sc2
	STA High_Score02
	LDA sc3
	STA High_Score03
.
 ; 

.Skip_High_Score
 ; Skip_High_Score

.
 ; 

.L02704 ;  return

  RTS
.
 ; 

.L02705 ;  rem ** AtariVox Speech Data

.
 ; 

.L02706 ;  rem Below is all of the AtariVox Speech

.L02707 ;  rem This table shows the actual speech and the name of the sub that calls it earlier in the game code

.L02708 ;  rem 

.L02709 ;  rem Speech			Name of subroutine

.L02710 ;  rem

.L02711 ;  rem Dungeon Stalker            intro

.L02712 ;  rem Entering the Dungeon       entering

.L02713 ;  rem I Am God 			iamgod

.L02714 ;  rem Death			death

.L02715 ;  rem I Am stronger		iamstronger

.L02716 ;  rem Terminated			terminated

.L02717 ;  rem You got me			yougotme

.L02718 ;  rem Gold			gold

.L02719 ;  rem Level Up			levelup	

.L02720 ;  rem Extra Life			extralife

.L02721 ;  rem No Fear			nofear

.L02722 ;  rem Bring it On		bringiton	

.L02723 ;  rem Money			money

.L02724 ;  rem Can't Stop	Me		cantstopme

.L02725 ;  rem My Life is Over		mylifeisover

.L02726 ;  rem More Power			morepower

.L02727 ;  rem Growing Stronger		growingstronger

.L02728 ;  rem Destroyed			destroyed

.L02729 ;  rem Beaten			beaten

.L02730 ;  rem Jackpot			jackpot

.L02731 ;  rem Bunker Hit			bunkerhit

.L02732 ;  rem Bunker Destroyed		bunkerdamaged

.L02733 ;  rem Moving Up			movingup

.L02734 ;  rem I have advanced		ihaveadvanced

.L02735 ;  rem Wizard Destroyed		wizdestroyed

.L02736 ;  rem Victory			victory

.L02737 ;  rem Wizard is Dead		wizdead

.L02738 ;  rem Wizard is Defeated		wizdefeated

.L02739 ;  rem More Arrows		morearrows

.L02740 ;  rem Filled Up			filledup

.L02741 ;  rem Ammo Recharged		ammocharge

.L02742 ;  rem Watch Out			watchout

.L02743 ;  rem Ammo Gone			ammogone

.L02744 ;  rem Arrows Gone		arrowsgone

.L02745 ;  rem Out of Arrows		arrowsout

.L02746 ;  rem Out of Ammo		ammoout

.L02747 ;  rem Game Over			gameover	

.L02748 ;  rem Ha Ha Ha			hahaha

.L02749 ;  rem Got Him			gothim

.
 ; 

.L02750 ;  rem ** AtariVox speech code subs

.L02751 ;  rem ** trial. error. trial. error. trial. error......

.
 ; 

.L02752 ;  speechdata intro

	JMP .skipL02752
intro
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 74 ; pitch
 .byte 175,134,141,165,134,141 ; DUNJUN (phonetic)
   .byte $05 ; pause 60ms
 .byte 187,191,136,145,194,134,148 ; STALLCUR (phonetic)
 .byte 255 ; end of avox data
.skipL02752
.
 ; 

.L02753 ;  speechdata entering

	JMP .skipL02753
entering
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 74 ; pitch
 .byte 131,141,191,134,148,148,129,141,180 ; ENTURRING (phonetic)
   .byte $05 ; pause 60ms
 .byte 169,128 ; THE (phonetic)
   .byte $05 ; pause 60ms
 .byte 175,134,141,165,134,141 ; DUNJUN (phonetic)
 .byte 255 ; end of avox data
.skipL02753
.
 ; 

.L02754 ;  speechdata iamgod

	JMP .skipL02754
iamgod
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 80 ; pitch
 .byte 14,155 ; I (dictionary)
   .byte 22, 86 ; pitch
 .byte 132,140 ; AM (phonetic)
   .byte 21, 80 ; speed
   .byte 22, 82 ; pitch
 .byte 8,179,14,135,176 ; GOD (dictionary)
 .byte 255 ; end of avox data
.skipL02754
.
 ; 

.L02755 ;  speechdata death

	JMP .skipL02755
death
   .byte 31,31 ; reset
   .byte 21, 68 ; speed
 .byte 176,14, 22,80, 131,190, 22,88; DEATH (dictionary)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02755
.
 ; 

.L02756 ;  speechdata iamstronger

	JMP .skipL02756
iamstronger
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 88 ; pitch
 .byte 14,155 ; I (dictionary)
   .byte 22, 90 ; pitch
 .byte 132,140 ; AM (phonetic)
   .byte 22, 92 ; pitch
 .byte 187,191,148,135 ; STRAW (phonetic)
   .byte 22, 92 ; pitch
 .byte 14,135,141 ; ON (dictionary)
   .byte 22, 94 ; pitch
 .byte  22,86, 179,134,148, 22,94 ; GUR. (phonetic)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02756
.
 ; 

.L02757 ;  speechdata terminated

	JMP .skipL02757
terminated
   .byte 31,31 ; reset
   .byte 21, 108 ; speed
   .byte 22, 78 ; pitch
 .byte 191,134,148,140,129,141,154,191,131,177 ; TURMINATED (phonetic)
 .byte 255 ; end of avox data
.skipL02757
.
 ; 

.L02758 ;  speechdata yougotme

	JMP .skipL02758
yougotme
   .byte 31,31 ; reset
   .byte 21, 105 ; speed
   .byte 22, 78 ; pitch
 .byte 128,14,139 ; YOU (dictionary)
   .byte 21, 86 ; speed
   .byte 22, 82 ; pitch
 .byte 178,132,183,191 ; GAHT (phonetic)
   .byte 21, 96 ; speed
   .byte 22, 84 ; pitch
 .byte 140,14,128 ; ME (dictionary)
 .byte 255 ; end of avox data
.skipL02758
.
 ; 

.L02759 ;  speechdata gold

	JMP .skipL02759
gold
   .byte 31,31 ; reset
   .byte 21, 92 ; speed
   .byte 22, 88 ; pitch
 .byte 8,179,14,8,137,145 ; GOAL (dictionary)
   .byte 22, 90 ; pitch
 .byte  22,82, 177, 22,90 ; D. (phonetic)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02759
.
 ; 

.L02760 ;  speechdata levelup

	JMP .skipL02760
levelup
   .byte 31,31 ; reset
 .byte  3,3,3,3,3,3 ; raw
   .byte 21, 98 ; speed
   .byte 22, 78 ; pitch
 .byte 145,14,131,166,134,145 ; LEVEL (dictionary)
   .byte 22, 80 ; pitch
 .byte 14, 22,72, 134,198, 22,80; UP (dictionary)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02760
.
 ; 

.L02761 ;  speechdata extralife

	JMP .skipL02761
extralife
   .byte 31,31 ; reset
   .byte 21, 104 ; speed
   .byte 22, 78 ; pitch
 .byte 14,131,194,187,191,148,134 ; EXTRA (dictionary)
   .byte 22, 80 ; pitch
 .byte 145,14, 22,72, 155,186, 22,80; LIFE (dictionary)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02761
.
 ; 

.L02762 ;  speechdata nofear

	JMP .skipL02762
nofear
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 76 ; pitch
 .byte 141,14,8,137 ; NO (dictionary)
   .byte 21, 86 ; speed
   .byte 22, 82 ; pitch
 .byte 186, 22,74, 128,148, 22,82 ; FEAR. (phonetic)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02762
.
 ; 

.L02763 ;  speechdata bringiton

	JMP .skipL02763
bringiton
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 80 ; pitch
 .byte 171,148,14,129,143 ; BRING (dictionary)
   .byte 22, 86 ; pitch
 .byte 14,129,191 ; IT (dictionary)
   .byte 21, 80 ; speed
   .byte 22, 82 ; pitch
 .byte 14,135,141 ; ON (dictionary)
 .byte 255 ; end of avox data
.skipL02763
.
 ; 

.L02764 ;  speechdata money

	JMP .skipL02764
money
   .byte 31,31 ; reset
   .byte 21, 96 ; speed
   .byte 22, 78 ; pitch
 .byte 140,14,134,141,128 ; MONEY (dictionary)
 .byte 255 ; end of avox data
.skipL02764
.
 ; 

.L02765 ;  speechdata cantstopme

	JMP .skipL02765
cantstopme
   .byte 31,31 ; reset
   .byte 21, 104 ; speed
   .byte 22, 80 ; pitch
 .byte 194,132,141,191 ; CANT (phonetic)
   .byte 22, 82 ; pitch
 .byte 187,191,14,135,198 ; STOP (dictionary)
   .byte 21, 80 ; speed
   .byte 22, 80 ; pitch
 .byte 140,14,128 ; ME (dictionary)
 .byte 255 ; end of avox data
.skipL02765
.
 ; 

.L02766 ;  speechdata mylifeisover

	JMP .skipL02766
mylifeisover
   .byte 31,31 ; reset
   .byte 21, 106 ; speed
   .byte 22, 82 ; pitch
 .byte 140,14,155 ; MY (dictionary)
   .byte 22, 84 ; pitch
 .byte 145,14,155,186 ; LIFE (dictionary)
   .byte 22, 86 ; pitch
 .byte 14,129,167 ; IS (dictionary)
   .byte 22, 80 ; pitch
 .byte 14,8,137,166,151 ; OVER (dictionary)
 .byte 255 ; end of avox data
.skipL02766
.
 ; 

.L02767 ;  speechdata morepower

	JMP .skipL02767
morepower
   .byte 31,31 ; reset
 .byte  3,3,3,3,3,3 ; raw
   .byte 21, 100 ; speed
   .byte 22, 80 ; pitch
 .byte 140,14,137,148 ; MORE (dictionary)
   .byte 21, 94 ; speed
   .byte 22, 78 ; pitch
 .byte 199,135 ; PAW (phonetic)
   .byte 22, 76 ; pitch
 .byte 147,134,148 ; WUR (phonetic)
 .byte 255 ; end of avox data
.skipL02767
.
 ; 

.L02768 ;  speechdata growingstronger

	JMP .skipL02768
growingstronger
   .byte 31,31 ; reset
 .byte  3,3,3,3,3,3 ; raw
   .byte 21, 112 ; speed
   .byte 22, 82 ; pitch
 .byte 179,148,164,147,129,141,180 ; GROWING (phonetic)
   .byte 22, 82 ; pitch
   .byte 21, 108 ; speed
 .byte 187,191,148,135 ; STRAW (phonetic)
   .byte 22, 84 ; pitch
 .byte 14,135,141 ; ON (dictionary)
   .byte 22, 86 ; pitch
 .byte  22,78, 179,134,148, 22,86 ; GUR. (phonetic)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02768
.
 ; 

.L02769 ;  speechdata destroyed

	JMP .skipL02769
destroyed
   .byte 31,31 ; reset
   .byte 21, 104 ; speed
   .byte 22, 80 ; pitch
 .byte 174,128 ; DEE (phonetic)
   .byte 22, 78 ; pitch
 .byte 187,191,148,156,177 ; STROYD (phonetic)
 .byte 255 ; end of avox data
.skipL02769
.
 ; 

.L02770 ;  speechdata beaten

	JMP .skipL02770
beaten
   .byte 31,31 ; reset
   .byte 21, 102 ; speed
   .byte 22, 76 ; pitch
 .byte 170,128,191,131,141 ; BEETEN (phonetic)
 .byte 255 ; end of avox data
.skipL02770
.
 ; 

.L02771 ;  speechdata jackpot

	JMP .skipL02771
jackpot
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 82 ; pitch
 .byte 165,132,194,194 ; JACK (phonetic)
   .byte 21, 96 ; speed
   .byte 22, 84 ; pitch
 .byte 199,135,191 ; PAWT (phonetic)
 .byte 255 ; end of avox data
.skipL02771
.
 ; 

.L02772 ;  speechdata bunkerdamaged

	JMP .skipL02772
bunkerdamaged
   .byte 31,31 ; reset
   .byte 22, 78 ; pitch
 .byte 171,134,141,194,134,148 ; BUNCUR (phonetic)
   .byte 21, 80 ; speed
   .byte 22, 80 ; pitch
 .byte 174,132,140 ; DAM (phonetic)
   .byte 21, 90 ; speed
   .byte 22, 78 ; pitch
 .byte 131,174,165 ; EDGE (phonetic)
   .byte 21, 64 ; speed
   .byte 22, 72 ; pitch
 .byte  22,64, 177, 22,72 ; D. (phonetic)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02772
.
 ; 

.L02773 ;  speechdata movingup

	JMP .skipL02773
movingup
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 84 ; pitch
 .byte 140,14,139,166 ; MOVE (dictionary)
   .byte 21, 100 ; speed
   .byte 22, 82 ; pitch
 .byte 129,141,180 ; ING (phonetic)
   .byte 21, 74 ; speed
   .byte 22, 82 ; pitch
 .byte 14, 22,74, 134,198, 22,82; UP (dictionary)
   .byte $03 ; pause 700ms
 .byte 255 ; end of avox data
.skipL02773
.
 ; 

.L02774 ;  speechdata ihaveadvanced

	JMP .skipL02774
ihaveadvanced
   .byte 31,31 ; reset
 .byte  3,3,3,3,3,3 ; raw
   .byte 21, 100 ; speed
   .byte 22, 82 ; pitch
 .byte 14,155 ; I (dictionary)
   .byte 21, 98 ; speed
   .byte 22, 82 ; pitch
 .byte 183,14,132,166 ; HAVE (dictionary)
   .byte 21, 102 ; speed
   .byte 22, 84 ; pitch
 .byte 14,132,176 ; AD (dictionary)
   .byte 22, 80 ; pitch
 .byte 166,132,141 ; VAN (phonetic)
   .byte 22, 80 ; pitch
 .byte 187,187 ; SS (phonetic)
   .byte 22, 78 ; pitch
 .byte 187,191 ; ST (phonetic)
 .byte 255 ; end of avox data
.skipL02774
.
 ; 

.L02775 ;  speechdata wizdestroyed

	JMP .skipL02775
wizdestroyed
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 82 ; pitch
 .byte 147,129,167 ; WHIZ (phonetic)
   .byte 22, 88 ; pitch
 .byte 167,134,148,177 ; ZURD (phonetic)
   .byte 21, 105 ; speed
   .byte 22, 92 ; pitch
 .byte 174,128 ; DEE (phonetic)
   .byte 22, 105 ; pitch
   .byte 22, 80 ; pitch
 .byte 187,191,148,156,177 ; STROYD (phonetic)
 .byte 255 ; end of avox data
.skipL02775
.
 ; 

.L02776 ;  speechdata victory

	JMP .skipL02776
victory
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 80 ; pitch
 .byte 166,129,194 ; VIC (phonetic)
   .byte 22, 80 ; pitch
 .byte 191,137,148 ; TOR (phonetic)
   .byte 21, 105 ; speed
   .byte 22, 80 ; pitch
 .byte 128 ; E (phonetic)
 .byte 255 ; end of avox data
.skipL02776
.
 ; 

.L02777 ;  speechdata wizdead

	JMP .skipL02777
wizdead
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 82 ; pitch
 .byte 147,129,167 ; WHIZ (phonetic)
   .byte 22, 86 ; pitch
 .byte 167,134,148,177 ; ZURD (phonetic)
   .byte 21, 80 ; speed
   .byte 22, 92 ; pitch
 .byte 14,129,167 ; IS (dictionary)
   .byte 22, 88 ; pitch
 .byte 176,14,131,176 ; DEAD (dictionary)
 .byte 255 ; end of avox data
.skipL02777
.
 ; 

.L02778 ;  speechdata wizdefeated

	JMP .skipL02778
wizdefeated
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 82 ; pitch
 .byte 147,129,167 ; WHIZ (phonetic)
   .byte 22, 88 ; pitch
 .byte 167,134,148,177 ; ZURD (phonetic)
   .byte 22, 92 ; pitch
 .byte 14,129,167 ; IS (dictionary)
   .byte 22, 86 ; pitch
 .byte 174,128 ; DEE (phonetic)
   .byte 22, 84 ; pitch
 .byte 186,128,191 ; FEET (phonetic)
   .byte 22, 82 ; pitch
 .byte 191,131,177 ; TED (phonetic)
 .byte 255 ; end of avox data
.skipL02778
.
 ; 

.L02779 ;  speechdata morearrows

	JMP .skipL02779
morearrows
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 88 ; pitch
 .byte 140,14,137,148 ; MORE (dictionary)
   .byte 21, 110 ; speed
   .byte 22, 86 ; pitch
 .byte 14,131,148 ; AIR (dictionary)
   .byte 22, 86 ; pitch
 .byte 148,164,147,187 ; ROWS (phonetic)
 .byte 255 ; end of avox data
.skipL02779
.
 ; 

.L02780 ;  speechdata filledup

	JMP .skipL02780
filledup
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 88 ; pitch
 .byte 186,129,145,145,177 ; FILLD (phonetic)
   .byte 21, 85 ; speed
   .byte 22, 82 ; pitch
 .byte 134,199 ; UP (phonetic)
 .byte 255 ; end of avox data
.skipL02780
.
 ; 

.L02781 ;  speechdata ammocharge

	JMP .skipL02781
ammocharge
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 88 ; pitch
 .byte 132,140 ; AM (phonetic)
   .byte 22, 90 ; pitch
 .byte 140,164 ; MO (phonetic)
   .byte 22, 92 ; pitch
 .byte 148,128 ; REE (phonetic)
   .byte 22, 82 ; pitch
 .byte 182,14,135,148,165 ; CHARGE (dictionary)
   .byte 22, 82 ; pitch
 .byte 177 ; D (phonetic)
 .byte 255 ; end of avox data
.skipL02781
.
 ; 

.L02782 ;  speechdata watchout

	JMP .skipL02782
watchout
   .byte 31,31 ; reset
 .byte  3,3,3 ; raw
   .byte 21, 100 ; speed
   .byte 22, 80 ; pitch
 .byte 147,14,135,182 ; WATCH (dictionary)
   .byte 21, 100 ; speed
   .byte 22, 78 ; pitch
 .byte 14,161,191 ; OUT (dictionary)
 .byte 255 ; end of avox data
.skipL02782
.
 ; 

.L02783 ;  speechdata ammogone

	JMP .skipL02783
ammogone
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 88 ; pitch
 .byte 132,140 ; AM (phonetic)
   .byte 22, 90 ; pitch
 .byte 140,164 ; MO (phonetic)
   .byte 22, 84 ; pitch
 .byte 178,135,141 ; GAWN (phonetic)
 .byte 255 ; end of avox data
.skipL02783
.
 ; 

.L02784 ;  speechdata arrowsgone

	JMP .skipL02784
arrowsgone
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 86 ; pitch
 .byte 14,131,148 ; AIR (dictionary)
   .byte 22, 86 ; pitch
 .byte 148,164,147,187 ; ROWS (phonetic)
   .byte 21, 100 ; speed
   .byte 22, 82 ; pitch
 .byte 178,135,141 ; GAWN (phonetic)
 .byte 255 ; end of avox data
.skipL02784
.
 ; 

.L02785 ;  speechdata arrowsout

	JMP .skipL02785
arrowsout
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 86 ; pitch
 .byte 14,161,191 ; OUT (dictionary)
   .byte 22, 86 ; pitch
 .byte 14,134,166 ; OF (dictionary)
   .byte 22, 82 ; pitch
   .byte 21, 110 ; speed
 .byte 14,131,148 ; AIR (dictionary)
   .byte 22, 82 ; pitch
 .byte 148,164,147,187 ; ROWS (phonetic)
 .byte 255 ; end of avox data
.skipL02785
.
 ; 

.L02786 ;  speechdata ammoout

	JMP .skipL02786
ammoout
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 86 ; pitch
 .byte 14,161,191 ; OUT (dictionary)
   .byte 22, 86 ; pitch
 .byte 14,134,166 ; OF (dictionary)
   .byte 22, 82 ; pitch
 .byte 132,140 ; AM (phonetic)
   .byte 22, 82 ; pitch
 .byte 140,164 ; MO (phonetic)
 .byte 255 ; end of avox data
.skipL02786
.
 ; 

.L02787 ;  speechdata gameover

	JMP .skipL02787
gameover
   .byte 31,31 ; reset
   .byte 21, 100 ; speed
   .byte 22, 86 ; pitch
 .byte 178,154,140 ; GAYME (phonetic)
   .byte 22, 82 ; pitch
   .byte 21, 110 ; speed
 .byte 14,8,137 ; OWE (dictionary)
   .byte 21, 95 ; speed
   .byte 22, 80 ; pitch
 .byte 166,134,148 ; VUR (phonetic)
 .byte 255 ; end of avox data
.skipL02787
.
 ; 

.L02788 ;  speechdata hahaha

	JMP .skipL02788
hahaha
   .byte 31,31 ; reset
 .byte  3,3,3 ; raw
   .byte 21, 78 ; speed
   .byte 22, 68 ; pitch
 .byte 135 ; AW (phonetic)
   .byte $05 ; pause 60ms
 .byte 135 ; AW (phonetic)
   .byte $05 ; pause 60ms
 .byte 135 ; AW (phonetic)
 .byte 255 ; end of avox data
.skipL02788
.
 ; 

.L02789 ;  speechdata gothim

	JMP .skipL02789
gothim
   .byte 31,31 ; reset
   .byte 21, 110 ; speed
   .byte 22, 86 ; pitch
 .byte 178,132,183,191 ; GAHT (phonetic)
   .byte $05 ; pause 60ms
 .byte 183,14,129,140 ; HIM (dictionary)
 .byte 255 ; end of avox data
.skipL02789
.
 ; 

.L02790 ;  rem ** Level colors

.L02791 ;  rem             1   2   3   4   5

.L02792 ;  rem v232   $00,$92,$D0,$52,$34,$14

.L02793 ;  rem        blk blu grn prp org yel

.L02794 ;  rem 

.L02795 ;  rem v233+  $00,$92,$14,$52,$D0,$34

.L02796 ;  rem        blk blu yel prp grn org

.
 ; 

.L02797 ;  data levelcolors

	JMP .skipL02797
levelcolors
	.byte   $00,$92,$14,$52,$D0,$34

.skipL02797
.
 ; 

.L02798 ;  rem ** shhhh. it's a secret.

.L02799 ;  data devmodecode

	JMP .skipL02799
devmodecode
	.byte   $EF,$EF,$DF,$DF,$BF,$7F,$BF,$7F

.skipL02799
.
 ; 

.
 ; 

.
 ; 

 echo "  ","  ","  ","  ",[($E000 - .)]d , "bytes of ROM space left in DMA hole 5."

 ORG $E000  ; *************

hiscorefont
       HEX 667c3c787e603e667e3c667e63663c6036663c187e186366187e001800000000
       HEX ff3c7e7e3c0c3c3c303c38
ts_back_ruby
       HEX 000000000000000000000000007c00000000001f00
       HEX 0000000000000000000000
menuback1
       HEX 3fffffffffffffffffffffffffffffffffffffffff
       HEX fc
treasure
       HEX 7e
swordtop
       HEX 2c
swordbottom
       HEX 18
demomodetext
       HEX f9fb1bf18dfbe7e0
devmode
       HEX e3c43cf3903d3089ce3c0000

 ORG $E100  ; *************

;hiscorefont
       HEX 6666666c6060666618666660636666606c660618663c77661860181800000010
       HEX ff661860667e666630660c
;ts_back_ruby
       HEX 00000000000000000000000001fc00000000001fc0
       HEX 0000000000000000000000
;menuback1
       HEX 7fffffffffffffffffffffffffffffffffffffffff
       HEX fe
;treasure
       HEX 18
;swordtop
       HEX 2c
;swordbottom
       HEX 18
;demomodetext
       HEX fdfb1bf18dfbf7e0
;devmode
       HEX 940a41045041408a29400000

 ORG $E200  ; *************

;hiscorefont
       HEX 6666666660606666180666606366666066660618667e7f3c1860180000000030
       HEX ff661870066c0666306606
;ts_back_ruby
       HEX 00000000000000000000000003fe00000000003fe0
       HEX 0000000000000000000000
;menuback1
       HEX ffffffffffffffffffffffffffffffffffffffffff
       HEX ff
;treasure
       HEX 18
;swordtop
       HEX 2c
;swordbottom
       HEX 18
;demomodetext
       HEX cd831b318d9b3600
;devmode
       HEX 979179045e79e0aa29780000

 ORG $E300  ; *************

;hiscorefont
       HEX 7e6660666060666618066c60636e6660666c061866666b183c300000ff00187e
       HEX ff66183c066c0666306606
;ts_back_ruby
       HEX 00000000000000000000000003fe00000000003ff0
       HEX 0000000000000000000000
;menuback1
       HEX ffffffffffffffffffffffffffffffffffffffffff
       HEX ff
;treasure
       HEX 3c
;swordtop
       HEX 2c
;swordbottom
       HEX 18
;demomodetext
       HEX cde35b31ad9b3780
;devmode
       HEX 94114104514110aa29400000

 ORG $E400  ; *************

;hiscorefont
       HEX 667c60667c7c6e7e180678606b7e667c667c3c186666631866180000ff00187e
       HEX ff66181e0c6c7c7c183c3e
;ts_back_ruby
       HEX 00000000000000000000000003fe00000000003ff0
       HEX 0000000000000000000000
;menuback1
       HEX ffffffffffffffffffffffffffffffffffffffffff
       HEX ff
;treasure
       HEX 6e
;swordtop
       HEX 2c
;swordbottom
       HEX 7e
;demomodetext
       HEX cde3fb31fd9b3780
;devmode
       HEX e3d13d038e3ce051ce3c0000

 ORG $E500  ; *************

;hiscorefont
       HEX 6666606660606066180678607f7e6666666660186666633c660c180000000c30
       HEX ff661806183c60600c6666
;ts_back_ruby
       HEX 00000000000000000000000003fe00000000003ff0
       HEX 0000000000000000000000
;menuback1
       HEX ffffffffffffffffffffffffffffffffffffffffff
       HEX ff
;treasure
       HEX df
;swordtop
       HEX 3c
;swordbottom
       HEX ff
;demomodetext
       HEX cd83fb31fd9b3600
;devmode
       HEX 000000000000000000000000

 ORG $E600  ; *************

;hiscorefont
       HEX 3c66666c6060606618066c607776666666666018666663666606180000000c10
       HEX ff6638660c1c6060066666
;ts_back_ruby
       HEX 00000000000000000000000003fe00000000001fe0
       HEX 0000000000000000000000
;menuback1
       HEX 7fffffffffffffffffffffffffffffffffffffffff
       HEX fe
;treasure
       HEX bf
;swordtop
       HEX 3c
;swordbottom
       HEX ad
;demomodetext
       HEX fdfbbbf1ddfbf7e0
;devmode
       HEX 000000000000000000000000

 ORG $E700  ; *************

;hiscorefont
       HEX 187c3c787e7e3e667e06666063663c7c3c7c3c7e66666366667e000000000c00
       HEX ff3c183c7e0c7e3c7e3c3c
;ts_back_ruby
       HEX 00000000000000000000000001fc00000000000fc0
       HEX 0000000000000000000000
;menuback1
       HEX 3fffffffffffffffffffffffffffffffffffffffff
       HEX fc
;treasure
       HEX bf
;swordtop
       HEX 18
;swordbottom
       HEX 2c
;demomodetext
       HEX f9fb1bf18dfbe7e0
;devmode
       HEX 000000000000000000000000
screenram_mult_lo
  .byte <(screenram+0)
  .byte <(screenram+40)
  .byte <(screenram+80)
  .byte <(screenram+120)
  .byte <(screenram+160)
  .byte <(screenram+200)
  .byte <(screenram+240)
  .byte <(screenram+280)
  .byte <(screenram+320)
  .byte <(screenram+360)
  .byte <(screenram+400)
  .byte <(screenram+440)
  .byte <(screenram+480)
  .byte <(screenram+520)
  .byte <(screenram+560)
  .byte <(screenram+600)
  .byte <(screenram+640)
  .byte <(screenram+680)
  .byte <(screenram+720)
  .byte <(screenram+760)
  .byte <(screenram+800)
  .byte <(screenram+840)
  .byte <(screenram+880)
  .byte <(screenram+920)
  .byte <(screenram+960)
  .byte <(screenram+1000)
  .byte <(screenram+1040)
  .byte <(screenram+1080)
screenram_mult_hi
  .byte >(screenram+0)
  .byte >(screenram+40)
  .byte >(screenram+80)
  .byte >(screenram+120)
  .byte >(screenram+160)
  .byte >(screenram+200)
  .byte >(screenram+240)
  .byte >(screenram+280)
  .byte >(screenram+320)
  .byte >(screenram+360)
  .byte >(screenram+400)
  .byte >(screenram+440)
  .byte >(screenram+480)
  .byte >(screenram+520)
  .byte >(screenram+560)
  .byte >(screenram+600)
  .byte >(screenram+640)
  .byte >(screenram+680)
  .byte >(screenram+720)
  .byte >(screenram+760)
  .byte >(screenram+800)
  .byte >(screenram+840)
  .byte >(screenram+880)
  .byte >(screenram+920)
  .byte >(screenram+960)
  .byte >(screenram+1000)
  .byte >(screenram+1040)
  .byte >(screenram+1080)
 

 ifnconst bankswitchmode
   if ( * < $f000 )
     ORG $F000
   endif
 else
     ifconst ROM128K
       if ( * < $f000 )
         ORG $27000
         RORG $F000
       endif
     endif
    ifconst ROM256K
       if ( * < $f000 )
         ORG $47000
         RORG $F000
       endif
     endif
    ifconst ROM512K
       if ( * < $f000 )
         ORG $87000
         RORG $F000
       endif
     endif
 endif

 ifnconst included.7800vox.asm
     include 7800vox.asm
 endif
 ifnconst included.pokeysound.asm
     include pokeysound.asm
 endif
  ;standard routines needed for pretty much all games

 ; some definitions used with "set debug color"
DEBUGCALC  = $91
DEBUGWASTE = $41
DEBUGDRAW  = $C1

     ;NMI and IRQ handlers
NMI
     ;VISIBLEOVER is 255 while the screen is drawn, and 0 right after the visible screen is done.
     pha
     lda visibleover
     eor #255
     sta visibleover
 ;sta BACKGRND
     dec interruptindex 
     beq reallyoffvisible
     pla

IRQ
     RTI

reallyoffvisible
     sta WSYNC
     lda #3
     sta interruptindex
     lda #0
     sta visibleover

     txa
     pha
     tya
     pha
     cld

     jsr uninterruptableroutines
     inc frameslost

     pla
     tay
     pla
     tax
     pla
     RTI

clearscreen
     ldx #(WZONECOUNT-1)
     lda #0
clearscreenloop
     sta dlend,x
     dex
     bpl clearscreenloop
     lda #0
     sta valbufend ; clear the bcd value buffer
     sta valbufendsave 
     rts

restorescreen
     ldx #(WZONECOUNT-1)
     lda #0
restorescreenloop
     lda dlendsave,x
     sta dlend,x
     dex
     bpl restorescreenloop
     lda valbufendsave
     sta valbufend
     rts

savescreen
     ldx #(WZONECOUNT-1)
savescreenloop
     lda dlend,x
     sta dlendsave,x
     dex
     bpl savescreenloop
     lda valbufend
     sta valbufendsave
     rts

drawscreen
     jsr servicesfxchannels 
     jsr checkjoybuttons

     inc framecounter
     lda framecounter
     and #63
     bne skipcountdownseconds
     lda countdownseconds
     beq skipcountdownseconds
     dec countdownseconds

skipcountdownseconds
     lda #0
     sta temp1 ; not B&W if we're here...

drawscreenwait
     ifconst DEBUGCOLOR
         lda #DEBUGWASTE
         sta BACKGRND
     endif
     lda visibleover
     bne drawscreenwait ; make sure the visible screen isn't being drawn

     ;restore some registers in case the user changed them mid-screen...
     lda sCTRL
     ora temp1
     sta CTRL
     lda sCHARBASE
     sta CHARBASE

     ;add DL end entry on each DL
     ldx #(WZONECOUNT-1)

dlendloop
     lda DLPOINTL,x
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1
     ldy dlend,x
     lda #$00
     iny
     sta (dlpnt),y
     dex
     bpl dlendloop

     ifnconst pauseroutineoff
         ; check to see if pause was pressed and released
pauseroutine
         lda pausedisable
         bne leavepauseroutine
         lda #8
         bit SWCHB
         beq pausepressed
         ;pause isn't pressed
         lda #0
         sta pausebuttonflag ; clear pause hold state in case its set

         ;check if we're in an already paused state
         lda pausestate
         beq leavepauseroutine ; nope, leave

         cmp #1 ; last frame was the start of pausing
         beq enterpausestate2 ; move from state 1 to 2

         cmp #2
         beq carryonpausing

         ;pausestate must be >2, which means we're ending an unpause 
         lda #0
         sta pausebuttonflag 
         sta pausestate 
         lda sCTRL
         sta CTRL
         jmp leavepauseroutine

pausepressed
         ;pause is pressed
         lda pausebuttonflag
         cmp #$ff
         beq carryonpausing

         ;its a new press, increment the state
         inc pausestate

         ;silence volume at the start and end of pausing
         lda #0 
         sta AUDV0
         sta AUDV1

         ifconst pokeysupport
             ldy #7
pausesilencepokeyaudioloop
             sta (pokeybase),y
             dey
             bpl pausesilencepokeyaudioloop
         endif

         lda #$ff
         sta pausebuttonflag
         bne carryonpausing

enterpausestate2
         lda #2
         sta pausestate
         bne carryonpausing
leavepauseroutine
         jmp visiblescreenstarted

carryonpausing
         ifconst .pause
             jsr .pause
         endif
         lda #%10000000 ; turn off colorburst during pause...
         sta temp1
         jmp drawscreenwait ; going to drawscreenwait skips servicing the sfx routine, so sfx pause too

     endif

     ; Make sure the visible screen has *started* before we exit. That way we can rely on drawscreen
     ; delaying a full frame, but still allowing time for basic calculations.
visiblescreenstarted
  ifconst DEBUGFRAMES
     lda #DEBUGCALC
     ldy #0
  endif ; DEBUGFRAMES
     dec frameslost
     beq skipframeswerelost
frameswerelost
  ifconst DEBUGFRAMES
     lda #DEBUGWASTE
  endif ; DEBUGFRAMES
     sty frameslost
skipframeswerelost
 ifconst DEBUGFRAMES
     sta BACKGRND
 endif ; DEBUGFRAMES

visiblescreenstartedwait
     lda visibleover
     beq visiblescreenstartedwait

    ifconst DEBUGCOLOR
         lda #DEBUGCALC
         sta BACKGRND
     endif
     rts

uninterruptableroutines
     ; this is for routines that must happen offscreen, each frame.
     ; So far just atarivox voice uses this. If it happens mid-screen DMA 
     ; messes up the baud rate.
     lda #$7F
     sta CTRL
     sta WSYNC
     lda #0
     sta palfastframe
     lda paldetected
     beq skippalframeadjusting
         ; ** PAL console is detected. we increment palframes to accurately count 5 frames, 
         ldx palframes
         inx
         cpx #5
         bne palframeskipdone
         inc palfastframe
         ldx #0
palframeskipdone
         stx palframes
skippalframeadjusting
     ifconst AVOXVOICE
         jsr processavoxvoice
     endif
     lda sCTRL
     sta CTRL
     rts

     ifconst AVOXVOICE
processavoxvoice
         lda avoxenable
         bne avoxfixport
         SPKOUT tempavox
         rts
avoxfixport
         lda #0 ; restore the port to all bits as inputs...
         sta SWACNT
         rts
silenceavoxvoice
         SPEAK avoxsilentdata
         rts
avoxsilentdata
         .byte 31,255
     endif

     ifconst HSSUPPORT
detectatarivoxeeprom
         ; do a test to see if atarivox eeprom can be accessed, and save results
         jsr AVoxDetect
         eor #$ff ; invert for easy 7800basic if...then logic
         sta avoxdetected
         rts 

detecthsc
         ; we check the first 2 bytes of the HSC signature...
         lda $1002
         cmp #$68
         bne detecthscfail
         lda $1003
         cmp #$83
         bne detecthscfail
         lda #$ff
         rts
detecthscfail
         lda #0
         rts
     endif ; HSSUPPORT

checkjoybuttons
     ;we poll the joystick fire buttons and throw them in shadow registers now
     lda #0
     sta sINPT1
     sta sINPT3
     lda INPT4
     bmi .skipp0firecheck
     ;one button joystick is down
     lda #$f0
     sta sINPT1
     lda joybuttonmode
     and #%00000100
     beq .skipp0firecheck
     lda joybuttonmode
     ora #%00000100
     sta joybuttonmode
     sta SWCHB
.skipp0firecheck
     lda INPT5
     bmi .skipp1firecheck
     ;one button joystick is down
     lda #$f0
     sta sINPT3
     lda joybuttonmode
     and #%00010000
     beq .skipp1firecheck
     lda joybuttonmode
     ora #%00010000
     sta joybuttonmode
     sta SWCHB
.skipp1firecheck
     lda INPT1
     ora sINPT1
     sta sINPT1

     lda INPT3
     ora sINPT3
     sta sINPT3
     rts

drawwait
     lda visibleover
     bne drawwait ; make sure the visible screen isn't being drawn
     rts

servicesfxchannels
     lda sfx1pointlo
     ora sfx1pointhi
     beq skipservicesfx1 ; (sfx1pointlo) isn't pointing at a sound

     lda sfx1tick
     beq servicesfx1_cont1
     dec sfx1tick ; frame countdown is non-zero. subtract one and
     jmp skipservicesfx1 ; skip playing the sound

servicesfx1_cont1

     lda sfx1frames ; set the frame countdown for this sound chunk
     sta sfx1tick

     lda sfx1priority ; decrease the sound's priority if its non-zero
     beq servicesfx1_cont2
     dec sfx1priority
servicesfx1_cont2

     ldy #0 ; play the sound
     lda (sfx1pointlo),y
     sta temp1
     clc
     adc sfx1poffset ; take into account any pitch modification
     sta AUDF0
     iny
     lda (sfx1pointlo),y
     sta AUDC0
     sta temp2
     iny
     lda (sfx1pointlo),y
     sta AUDV0

     ora temp2
     ora temp1 ; check if F|C|V=0
     beq zerosfx1 ; if so, we're at the end of the sound.

     ; advance the pointer to the next sound chunk
     clc
     lda sfx1pointlo
     adc #3
     sta sfx1pointlo
     lda sfx1pointhi
     adc #0
     sta sfx1pointhi
     jmp skipservicesfx1
     
zerosfx1
     sta sfx1pointlo
     sta sfx1pointhi
     sta sfx1priority
skipservicesfx1
     
     ifnconst TIASFXMONO
         lda sfx2pointlo
         ora sfx2pointhi
         beq skipservicesfx2 ; (sfx2pointlo) isn't pointing at a sound

         lda sfx2tick
         beq servicesfx2_cont1
         dec sfx2tick ; frame countdown is non-zero. subtract one and
         jmp skipservicesfx2 ; skip playing the sound

servicesfx2_cont1

         lda sfx2frames ; set the frame countdown for this sound chunk
         sta sfx2tick

         lda sfx2priority ; decrease the sound's priority if its non-zero
         beq servicesfx2_cont2
         dec sfx2priority
servicesfx2_cont2

         ldy #0 ; play the sound
         lda (sfx2pointlo),y
         sta temp1
         clc
         adc sfx2poffset ; take into account any pitch modification
         sta AUDF1
         iny
         lda (sfx2pointlo),y
         sta AUDC1
         sta temp2
         iny
         lda (sfx2pointlo),y
         sta AUDV1

         ora temp2
         ora temp1 ; check if F|C|V=0
         beq zerosfx2 ; if so, we're at the end of the sound.

         ; advance the pointer to the next sound chunk
         clc
         lda sfx2pointlo
         adc #3
         sta sfx2pointlo
         lda sfx2pointhi
         adc #0
         sta sfx2pointhi
         jmp skipservicesfx2
         
zerosfx2
         sta sfx2pointlo
         sta sfx2pointhi
         sta sfx2priority
skipservicesfx2
     endif ; TIASFXMONO

     ifnconst pokeysupport
         rts
     else
         jmp checkpokeyplaying
     endif

schedulesfx
     ifnconst TIASFXMONO
         ; called with temp1=<data temp2=>data temp3=pitch offset
         ifconst pokeysupport
             ldy #0
             lda (temp1),y
             cmp #$20 ; TIA?
             bne scheduletiasfx
             jmp schedulepokeysfx
scheduletiasfx
         endif ; pokeysupport
         lda sfx1pointlo
         ora sfx1pointhi
         beq schedulesfx1 ;if channel 1 is idle, use it
         lda sfx2pointlo
         ora sfx2pointhi
         beq schedulesfx2 ;if channel 2 is idle, use it
         ; Both channels are scheduled. 
         ldy #1
         lda (temp1),y
         bne interruptsfx
         rts ; the new sound has 0 priority and both channels are busy. Skip playing it.
interruptsfx
         ;Compare which active sound has a lower priority. We'll interrupt the lower one.
         lda sfx1priority
         cmp sfx2priority
         bcs schedulesfx2
schedulesfx1
     endif ; TIASFXMONO

     ldy #1 ; get priority and sound-resolution (in frames)
     lda (temp1),y
     sta sfx1priority
     iny
     lda (temp1),y
     sta sfx1frames
     lda temp1
     clc
     adc #3
     sta sfx1pointlo
     lda temp2
     adc #0
     sta sfx1pointhi
     lda temp3
     sta sfx1poffset
     lda #0
     sta sfx1tick
     rts
     ifnconst TIASFXMONO
schedulesfx2
         ldy #1
         lda (temp1),y
         sta sfx2priority
         iny
         lda (temp1),y
         sta sfx2frames
         lda temp1
         clc
         adc #3
         sta sfx2pointlo
         lda temp2
         adc #0
         sta sfx2pointhi
         lda temp3
         sta sfx2poffset
         lda #0
         sta sfx2tick
         rts
     endif ; TIASFXMONO

plotsprite
     ifconst DEBUGCOLOR
         lda #DEBUGWASTE
         sta BACKGRND
     endif

plotspritewait
     lda visibleover
     bne plotspritewait

     ifconst DEBUGCOLOR
         lda #DEBUGDRAW
         sta BACKGRND
     endif

     ;arguments: 
     ; temp1=lo graphicdata 
     ; temp2=hi graphicdata 
     ; temp3=palette | width byte
     ; temp4=x
     ; temp5=y
     ; temp6=mode
     lda temp5 ;Y position
     lsr ; 2 - Divide by 8 or 16
     lsr ; 2
     lsr ; 2
     if WZONEHEIGHT = 16
         lsr ; 2
     endif

     tax

     ; the next block allows for vertical masking, and ensures we don't overwrite non-DL memory

     cmp #WZONECOUNT

     bcc continueplotsprite1 ; the sprite is fully on-screen, so carry on...
     ; otherwise, check to see if the bottom half is in zone 0...

     if WZONEHEIGHT = 16
         cmp #15
     else
         cmp #31
     endif

     bne exitplotsprite1
     ldx #0
     jmp continueplotsprite2
exitplotsprite1
     rts

continueplotsprite1

     lda DLPOINTL,x ;Get pointer to DL that this sprite starts in
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1

     ;Create DL entry for upper part of sprite

     ldy dlend,x ;Get the index to the end of this DL

     ifconst CHECKOVERWRITE
         cpy #DLLASTOBJ
         beq checkcontinueplotsprite2
continueplotsprite1a
     endif

     lda temp1 ; graphic data, lo byte
     sta (dlpnt),y ;Low byte of data address

     iny
     lda temp6
     sta (dlpnt),y

     iny
     lda temp5 ;Y position

     if WZONEHEIGHT = 16
         and #$0F
     else ; WZONEHEIGHT = 8
         and #$7
     endif

     ora temp2 ; graphic data, hi byte
     sta (dlpnt),y

     iny
     lda temp3 ;palette|width
     sta (dlpnt),y

     iny
     lda temp4 ;Horizontal position
     sta (dlpnt),y

     iny
     sty dlend,x

checkcontinueplotsprite2

     lda temp5
     and #(WZONEHEIGHT-1)

     beq doneSPDL ;branch if it is

     ;Create DL entry for lower part of sprite

     inx ;Next region

     cpx #WZONECOUNT

     bcc continueplotsprite2 ; the second half of the sprite is fully on-screen, so carry on...
     rts
continueplotsprite2

     lda DLPOINTL,x ;Get pointer to next DL
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1
     ldy dlend,x ;Get the index to the end of this DL

     ifconst CHECKOVERWRITE
         cpy #DLLASTOBJ
         bne continueplotsprite2a
         rts
continueplotsprite2a
     endif

     lda temp1 ; graphic data, lo byte
     sta (dlpnt),y

     iny
     lda temp6
     sta (dlpnt),y

     iny
     lda temp5 ;Y position

     if WZONEHEIGHT = 16
         and #$0F
         eor #$0F
     endif
     if WZONEHEIGHT = 8
         and #$07
         eor #$07
     endif

     sta temp9
     lda temp2 ; graphic data, hi byte
     clc
     sbc temp9
     sta (dlpnt),y

     iny
     lda temp3 ;palette|width
     sta (dlpnt),y

     iny
     lda temp4 ;Horizontal position
     sta (dlpnt),y

     iny
     sty dlend,x
doneSPDL
     rts

lockzonex
  ifconst ZONELOCKS
     ldy dlend,x
     cpy #DLLASTOBJ
     beq lockzonexreturn ; the zone is either stuffed or locked. abort!
     lda DLPOINTL,x
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1
     iny
     lda #0
     sta (dlpnt),y
     dey
     tya
     ldy #(DLLASTOBJ-1)
     sta (dlpnt),y
     iny
     sty dlend,x
lockzonexreturn
     rts
  endif ; ZONELOCKS
unlockzonex
  ifconst ZONELOCKS
     ldy dlend,x
     cpy #DLLASTOBJ
     bne unlockzonexreturn ; if the zone isn't stuffed, it's not locked. abort!
     lda DLPOINTL,x
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1
     dey
     ;ldy #(DLLASTOBJ-1)
     lda (dlpnt),y
     tay
     sty dlend,x
unlockzonexreturn
  endif ; ZONELOCKS
     rts

plotcharloop
     ; ** read from a data indirectly pointed to from temp8,temp9
     ; ** format is: lo_data, hi_data, palette|width, x, y
     ; ** format ends with lo_data | hi_data = 0
     ifconst DEBUGCOLOR
         lda #DEBUGWASTE
         sta BACKGRND
     endif
plotcharloopwait
     lda visibleover
     bne plotcharloopwait
     ifconst DEBUGCOLOR
         lda #DEBUGDRAW
         sta BACKGRND
     endif
plotcharlooploop
     ldy #0
     lda (temp8),y
     sta temp1
     iny
     lda (temp8),y
     sta temp2
     ora temp1
     bne plotcharloopcontinue
     ;the pointer=0, so return
     rts
plotcharloopcontinue
     iny
     lda (temp8),y
     sta temp3
     iny
     lda (temp8),y
     sta temp4
     iny
     lda (temp8),y
     ;sta temp5 ; not needed with our late entry.
     jsr plotcharactersskipentry
     lda temp8
     clc
     adc #5
     sta temp8
     lda temp9
     adc #0
     sta temp9
     jmp plotcharlooploop

plotcharacters
     ifconst DEBUGCOLOR
         lda #DEBUGWASTE
         sta BACKGRND
     endif
plotcharacterswait
     lda visibleover
     bne plotcharacterswait
     ifconst DEBUGCOLOR
         lda #DEBUGDRAW
         sta BACKGRND
     endif
     ;arguments: 
     ; temp1=lo charactermap
     ; temp2=hi charactermap
     ; temp3=palette | width byte
     ; temp4=x
     ; temp5=y

     lda temp5 ;Y position

plotcharactersskipentry

     ;ifconst ZONEHEIGHT
     ; if ZONEHEIGHT = 16
     ; and #$0F
     ; endif
     ; if ZONEHEIGHT = 8
     ; and #$1F
     ; endif
     ;else
     ; and #$0F
     ;endif

     tax
     lda DLPOINTL,x ;Get pointer to DL that the characters are in
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1

     ;Create DL entry for the characters

     ldy dlend,x ;Get the index to the end of this DL

     ifconst CHECKOVERWRITE
         cpy #DLLASTOBJ
         bne continueplotcharacters
         rts
continueplotcharacters
     endif

     lda temp1 ; character map data, lo byte
     sta (dlpnt),y ;(1) store low address

     iny
     lda charactermode 
     sta (dlpnt),y ;(2) store mode

     iny
     lda temp2 ; character map, hi byte
     sta (dlpnt),y ;(3) store high address

     iny
     lda temp3 ;palette|width
     sta (dlpnt),y ;(4) store palette|width

     iny
     lda temp4 ;Horizontal position
     sta (dlpnt),y ;(5) store horizontal position

     iny
     sty dlend,x ; save display list end byte
     rts

plotcharacterslive
     ; a version of plotcharacters that draws live and minimally disrupts the screen...

     ;arguments: 
     ; temp1=lo charactermap
     ; temp2=hi charactermap
     ; temp3=palette | width byte
     ; temp4=x
     ; temp5=y

     lda temp5 ;Y position

     tax
     lda DLPOINTL,x ;Get pointer to DL that the characters are in
     sta dlpnt
     lda DLPOINTH,x
     sta dlpnt+1

     ;Create DL entry for the characters

     ldy dlend,x ;Get the index to the end of this DL

     ifconst CHECKOVERWRITE
         cpy #DLLASTOBJ
         bne continueplotcharacterslive
         rts
continueplotcharacterslive
     endif

     lda temp1 ; character map data, lo byte
     sta (dlpnt),y ;(1) store low address

     iny
     ; we don't add the second byte yet, since the charmap could briefly
     ; render without a proper character map address, width, or position.
     lda charactermode 
     sta (dlpnt),y ;(2) store mode

     iny
     lda temp2 ; character map, hi byte
     sta (dlpnt),y ;(3) store high address

     iny
     lda temp3 ;palette|width
     sta (dlpnt),y ;(4) store palette|width

     iny
     lda temp4 ;Horizontal position
     sta (dlpnt),y ;(5) store horizontal position

     iny
     sty dlend,x ; save display list end byte

     rts

plotvalue
     ; calling 7800basic command:
     ; plotvalue digit_gfx palette variable/data number_of_digits screen_x screen_y
     ; ...displays the variable as BCD digits
     ;
     ; asm sub arguments: 
     ; temp1=lo charactermap
     ; temp2=hi charactermap
     ; temp3=palette | width byte
     ; temp4=x
     ; temp5=y
     ; temp6=number of digits
     ; temp7=lo variable
     ; temp8=hi variable
     ; temp9=character mode

plotdigitcount     = temp6

 ifconst ZONELOCKS
     ldx temp5
     ldy dlend,x
     cpy #DLLASTOBJ
     bne carryonplotvalue
     rts
carryonplotvalue
 endif

     lda #0
     tay
     ldx valbufend

     lda plotdigitcount
     and #1
     beq pvnibble2char
     lda #0
     sta VALBUFFER,x ; just in case we skip this digit
     beq pvnibble2char_skipnibble

pvnibble2char
     ; high nibble...
     lda (temp7),y
     and #$f0 
     lsr
     lsr
     lsr
     ifnconst DOUBLEWIDE ; multiply value by 2 for double-width
         lsr
     endif

     clc
     adc temp1 ; add the offset to character graphics to our value
     sta VALBUFFER,x
     inx
     dec plotdigitcount

pvnibble2char_skipnibble
     ; low nibble...
     lda (temp7),y
     and #$0f 
     ifconst DOUBLEWIDE ; multiply value by 2 for double-width
         asl
     endif
     clc
     adc temp1 ; add the offset to character graphics to our value
     sta VALBUFFER,x 
     inx
     iny

     dec plotdigitcount
     bne pvnibble2char

     ;point to the start of our valuebuffer
     clc
     lda #<VALBUFFER
     adc valbufend
     sta temp1
     lda #>VALBUFFER
     adc #0
     sta temp2

     ;advance valbufend to the end of our value buffer
     stx valbufend

     ifnconst plotvalueonscreen
         jmp plotcharacters
     else
         jmp plotcharacterslive
     endif


plotvalueextra
     ; calling 7800basic command:
     ; plotvalue digit_gfx palette variable/data number_of_digits screen_x screen_y
     ; ...displays the variable as BCD digits
     ;
     ; asm sub arguments: 
     ; temp1=lo charactermap
     ; temp2=hi charactermap
     ; temp3=palette | width byte
     ; temp4=x
     ; temp5=y
     ; temp6=number of digits
     ; temp7=lo variable
     ; temp8=hi variable

     lda #0
     tay
     ldx valbufend
     ifnconst plotvalueonscreen
         sta VALBUFFER,x
     endif

     lda plotdigitcount
     and #1
     
     bne pvnibble2char_skipnibbleextra

pvnibble2charextra
     ; high nibble...
     lda (temp7),y
     and #$f0 
     lsr
     lsr
     ifnconst DOUBLEWIDE ; multiply value by 2 for double-width
         lsr
     endif
     clc
     adc temp1 ; add the offset to character graphics to our value
     sta VALBUFFER,x
     inx

     ; second half of the digit
     clc
     adc #1
     sta VALBUFFER,x
     inx

pvnibble2char_skipnibbleextra
     ; low nibble...
     lda (temp7),y
     and #$0f 
     ifconst DOUBLEWIDE ; multiply value by 2 for double-width
         asl
     endif
     asl

     clc
     adc temp1 ; add the offset to character graphics to our value
     sta VALBUFFER,x 
     inx

     clc
     adc #1
     sta VALBUFFER,x
     inx
     iny

     dec plotdigitcount
     bne pvnibble2charextra

     ;point to the start of our valuebuffer
     clc
     lda #<VALBUFFER
     adc valbufend
     sta temp1
     lda #>VALBUFFER
     adc #0
     sta temp2

     ;advance valbufend to the end of our value buffer
     stx valbufend

     ifnconst plotvalueonscreen
         jmp plotcharacters
     else
         jmp plotcharacterslive
     endif

boxcollision
     ; prior to getting here...
     ; we have 4x lda #immed, 4x lda zp, 8x sta zp, and 1x jsr
     ; = 50 cycles to start. eep!

__boxx1 = temp1
__boxy1 = temp2
__boxw1 = temp3
__boxh1 = temp4

__boxx2 = temp5
__boxy2 = temp6
__boxw2 = temp7
__boxh2 = temp8

     ifconst collisionwrap
         ; if collision durring screen wrap is required, we add constants to
         ; coordinates, so we're not looking at negatives. (if reasonably
         ; sized sprites are used, anyway.)
         lda __boxx1 ;3 
         clc ;2
         adc #48 ;2
         sta __boxx1 ;3

         lda __boxx2 ;3
         clc ;2
         adc #48 ;2
         sta __boxx2 ;3

         lda __boxy1 ;3
         clc ;2
         ;adc #32 ;2
         adc #((256-WSCREENHEIGHT)/2) ;2
         sta __boxy1 ;3

         lda __boxy2 ;3
         clc ;2
         ;adc #32 ;2
         adc #((256-WSCREENHEIGHT)/2) ;2
         sta __boxy2 ;3
         ;=== +40 cycles for using collisionwrap
     endif

DoXCollisionCheck
     lda __boxx1 ;3
     cmp __boxx2 ;3
     bcs X1isbiggerthanX2 ;2/3
X2isbiggerthanX1
     adc __boxw1 ;3
     cmp __boxx2 ;3
     bcs DoYCollisionCheck ;3/2
     rts ;6 - carry clear, no collision
X1isbiggerthanX2
     clc ;2
     sbc __boxw2 ;3
     cmp __boxx2 ;3
     bcs noboxcollision ;3/2
DoYCollisionCheck
     lda __boxy1 ;3
     cmp __boxy2 ;3
     bcs Y1isbiggerthanY2 ;3/2
Y2isbiggerthanY1
     adc __boxh1 ;3
     cmp __boxy2 ;3
     rts ;6 
Y1isbiggerthanY2
     clc ;2
     sbc __boxh2 ;3
     cmp __boxy2 ;3
     bcs noboxcollision ;3/2
yesboxcollision
     sec ;2
     rts ;6
noboxcollision
     clc ;2
     rts ;6

     ;==48 cycles worst case for checks+rts
     ;TOTAL =~48+50 for call+checks+rts
     ;TOTAL =~48+50+40 for call+wrap+checks+rts

randomize
     lda rand
     lsr
     rol rand16
     bcc noeor
     eor #$B4
noeor
     sta rand
     eor rand16
     rts

     ; bcd conversion routine courtesy Omegamatrix
     ; http://atariage.com/forums/blog/563/entry-10832-hex-to-bcd-conversion-0-99/
converttobcd
     ;value to convert is in the accumulator
     sta temp1
     lsr
     adc temp1
     ror
     lsr
     lsr
     adc temp1
     ror
     adc temp1
     ror
     lsr
     and #$3C
     sta temp2
     lsr
     adc temp2
     adc temp1 
     rts ; return the result in the accumulator

     ; Y and A contain multiplicands, result in A
mul8
     sty temp1
     sta temp2
     lda #0
reptmul8
     lsr temp2
     bcc skipmul8
     clc
     adc temp1
     ;bcs donemul8 might save cycles?
skipmul8
     ;beq donemul8 might save cycles?
     asl temp1
     bne reptmul8
donemul8
     rts

div8
     ; A=numerator Y=denominator, result in A
     cpy #2
     bcc div8end+1;div by 0 = bad, div by 1=no calc needed, so bail out
     sty temp1
     ldy #$ff
div8loop
     sbc temp1
     iny
     bcs div8loop
div8end
     tya
     ; result in A
     rts

     ; Y and A contain multiplicands, result in temp2,A=low, temp1=high
mul16
     sty temp1
     sta temp2

     lda #0
     ldx #8
     lsr temp1
mul16_1
     bcc mul16_2
     clc
     adc temp2
mul16_2
     ror
     ror temp1
     dex
     bne mul16_1
     sta temp2
     rts

     ; div int/int
     ; numerator in A, denom in temp1
     ; returns with quotient in A, remainder in temp1
div16
     sty temp1
     ldx #8
loopdiv
     cmp temp1
     bcc toosmalldiv
     sbc temp1 ; Note: Carry is, and will remain, set.
     rol temp2
     rol
     dex
     bne loopdiv
     beq donediv
toosmalldiv
     rol temp2
     rol
     dex
     bne loopdiv
donediv
     sta temp1
     lda temp2
     rts

     ifconst bankswitchmode
BS_jsr
         ifconst MCPDEVCART
             ora #$18
             sta $3000
         else
             sta $8000
         endif
         pla
         tax
         pla
         rts

BS_return
         pla ; bankswitch bank
         ifconst BANKRAM
             sta currentbank
             ora currentrambank
         endif
         ifconst MCPDEVCART
             ora #$18
             sta $3000
         else
             sta $8000
         endif
         pla ; bankswitch $0 flag
         rts 
     endif


checkselectswitch
     lda SWCHB ; first check the real select switch...
     and #%00000010
     beq checkselectswitchreturn ; switch is pressed
     lda SWCHA ; then check the soft "select" joysick code...
     and #%10110000 ; R_DU
checkselectswitchreturn
     rts

checkresetswitch
     lda SWCHB ; first check the real reset switch...
     and #%00000001
     beq checkresetswitchreturn ; switch is pressed
     lda SWCHA ; then check the soft "reset" joysick code...
     and #%01110000 ; _LDU
checkresetswitchreturn
     rts

 ifconst FINESCROLLENABLED
finescrolldlls
     ldx temp1 ; first DLL index x3
     lda DLLMEM,x
     and #%11110000
     ora finescrolly
     sta DLLMEM,x

     ldx temp2 ; last DLL index x3
     lda DLLMEM,x
     and #%11110000
     ora finescrolly
     eor #(WZONEHEIGHT-1)
     sta DLLMEM,x
     rts
 endif ; FINESCROLLENABLED

adjustvisible
     ; called with temp1=first visible zone *3, temp2=last visible zone *3
     jsr waitforvblankstart ; ensure vblank just started
     ldx visibleDLLstart
findfirstinterrupt
     lda DLLMEM,x
     bmi foundfirstinterrupt
     inx
     inx
     inx
     bne findfirstinterrupt
foundfirstinterrupt
     and #%01111111 ; clear the interrupt bit
     sta DLLMEM,x
     ldx overscanDLLstart
findlastinterrupt
     lda DLLMEM,x
     bmi foundlastinterrupt
     dex
     dex
     dex
     bne findlastinterrupt
foundlastinterrupt
     and #%01111111 ; clear the interrupt bit
     sta DLLMEM,x
     ;now we need to set the new interrupts
     clc
     lda temp1
     adc visibleDLLstart
     tax
     lda DLLMEM,x
     ora #%10000000
     sta DLLMEM,x
     clc
     lda temp2
     adc visibleDLLstart
     tax
     lda DLLMEM,x
     ora #%10000000
     sta DLLMEM,x
     jsr vblankresync
     rts

vblankresync
     jsr waitforvblankstart ; ensure vblank just started
     lda #0
     sta visibleover
     lda #3
     sta interruptindex
     rts

createallgamedlls
     ldx #0
     lda #NVLINES
     ldy paldetected
     beq skipcreatePALpadding
     clc
     adc #25 
skipcreatePALpadding
     jsr createnonvisibledlls
     stx visibleDLLstart
     jsr createvisiblelines
     stx overscanDLLstart
createallgamedllscontinue
     lda #(NVLINES+50)  ; extras for PAL
     jsr createnonvisibledlls

     ldx visibleDLLstart
     lda DLLMEM,x
     ora #%10000000 ; NMI 1 - start of visible screen
     sta DLLMEM,x

     ldx overscanDLLstart
     lda DLLMEM,x
     ora #%10000011 ; NMI 2 - end of visible screen
     and #%11110011 ; change this to a 1-line DLL, so there's time enough for the "deeper overscan" DLL
     sta DLLMEM,x

     inx
     inx
     inx

     lda DLLMEM,x
     ora #%10000000 ; NMI 3 - deeper overscan
     sta DLLMEM,x

     rts

createnonvisibledlls
     sta temp1
     lsr
     lsr
     lsr
     lsr ; /16
     beq skipcreatenonvisibledlls1loop
     tay
createnonvisibledlls1loop
     lda #%01001111 ;low nibble=16 lines, high nibble=Holey DMA
     jsr createblankdllentry
     dey
     bne createnonvisibledlls1loop
skipcreatenonvisibledlls1loop
     lda temp1
     and #%00001111
     beq createnonvisibledllsreturn
     sec
     sbc #1
     ora #%01000000
     jsr createblankdllentry
createnonvisibledllsreturn
     rts


createblankdllentry
     sta DLLMEM,x
     inx
     lda #$21 ; blank
     sta DLLMEM,x
     inx
     lda #$00
     sta DLLMEM,x
     inx
     rts 


createvisiblelines
     ldy #0
createvisiblelinesloop
     lda.w DLHEIGHT,y
     ora #(WZONEHEIGHT * 4) ; set Holey DMA for 8 or 16 tall zones
     sta DLLMEM,x
     inx
     lda DLPOINTH,y
     sta DLLMEM,x
     inx
     lda DLPOINTL,y
     sta DLLMEM,x
     inx
     iny
     cpy #WZONECOUNT
     bne createvisiblelinesloop
     rts

waitforvblankstart
visibleoverwait
     BIT MSTAT
     bpl visibleoverwait
vblankstartwait
     BIT MSTAT
     bmi vblankstartwait
     rts

     ifconst HSSUPPORT 
         ifnconst hiscorefont
             echo ""
             echo "WARNING: High score support is enabled, but the hiscorefont.png was"
             echo " NOT imported with incgraphic. The high score display code"
             echo " has been omitted from this build."
             echo ""
         else
hscdrawscreen

; we use 20 lines on a 24 line display
; HSSCOREY to dynamically centers based on 
;HSSCOREY             = 0
HSSCOREY             = ((WZONECOUNT*WZONEHEIGHT/8)-22)/2
HSCURSORY            = ((HSSCOREY/(WZONEHEIGHT/8))*WZONEHEIGHT)

 ifconst HSSCORESIZE
SCORESIZE = HSSCORESIZE
 else
SCORESIZE = 6
 endif

             ;save shadow registers for later return...
             lda sCTRL
             sta ssCTRL
             lda sCHARBASE
             sta ssCHARBASE 
             jsr drawwait
             jsr blacken320colors
             jsr clearscreen

             ;set the character base to the HSC font
             lda #>hiscorefont
             sta CHARBASE
             sta sCHARBASE

             lda #%01000011 ;Enable DMA, mode=320A
             sta CTRL
             sta sCTRL

             lda #60
             sta hsjoydebounce

             lda #0
             sta hscursorx
             sta framecounter
             ifnconst HSCOLORCHASESTART
                 lda #$8D ; default is blue. why not?
             else
                 lda #HSCOLORCHASESTART
             endif
             sta hscolorchaseindex

             lda #$0F
             sta P0C2 ; base text is white

             jsr hschasecolors

             ; ** plot all of the initials
             lda #<HSRAMInitials
             sta temp1 ; charmaplo
             lda #>HSRAMInitials
             sta temp2 ; charmaphi
             lda #32+29 ; palette=0-29 | 32-(width=3)
             sta temp3 ; palette/width
             lda #104
             sta temp4 ; X
             lda #((HSSCOREY+6)/(WZONEHEIGHT/8))
             sta temp5 ; Y
plothsinitialsloop
             jsr plotcharacters
             clc
             lda temp3
             adc #32
             sta temp3
             inc temp5
             if WZONEHEIGHT = 8
                 inc temp5
             endif
             clc
             lda #3
             adc temp1
             sta temp1
             cmp #(<(HSRAMInitials+15))
             bcc plothsinitialsloop

             ifconst HSGAMENAMELEN
                 ;plot the game name...
                 lda #<HSGAMENAMEtable
                 sta temp1 ; charmaplo
                 lda #>HSGAMENAMEtable
                 sta temp2 ; charmaphi
                 lda #(32-HSGAMENAMELEN) ; palette=0*29 | 32-(width=3)
                 sta temp3 ; palette/width
                 lda #(80-(HSGAMENAMELEN*2))
                 sta temp4 ; X
                 lda #((HSSCOREY+0)/(WZONEHEIGHT/8))
                 sta temp5 ; Y
                 jsr plotcharacters
             endif

             ;plot "difficulty"...
             ldy gamedifficulty
             ifnconst HSNOLEVELNAMES
                 lda highscoredifficultytextlo,y
                 sta temp1
                 lda highscoredifficultytexthi,y
                 sta temp2
                 sec
                 lda #32
                 sbc highscoredifficultytextlen,y
                 sta temp3 ; palette/width
                 sec
                 lda #40
                 sbc highscoredifficultytextlen,y
                 asl
                 sta temp4 ; X
             else
                 lda #<HSHIGHSCOREStext
                 sta temp1 ; charmaplo
                 lda #>HSHIGHSCOREStext
                 sta temp2 ; charmaphi
                 lda #(32-11) ; palette=0*29 | 32-(width=3)
                 sta temp3 ; palette/width
                 lda #(80-(11*2))
                 sta temp4 ; X
             endif

             lda #((HSSCOREY+2)/(WZONEHEIGHT/8))
             sta temp5 ; Y
             jsr plotcharacters

             ldy hsdisplaymode ; 0=attact mode, 1=player eval, 2=player 1 eval, 3=player 2 player eval
             bne carronwithscoreevaluation
             jmp donoscoreevaluation
carronwithscoreevaluation
             dey
             lda highscorelabeltextlo,y
             sta temp1
             lda highscorelabeltexthi,y
             sta temp2
             sec
             lda #(32-15) ; palette=0*29 | 32-(width=3)
             sta temp3 ; palette/width
             lda highscorelabeladjust1,y
             sta temp4 ; X
             lda #((HSSCOREY+18)/(WZONEHEIGHT/8))
             sta temp5 ; Y
             jsr plotcharacters

             ldy hsdisplaymode ; 0=attact mode, 1=player eval, 2=player 1 eval, 3=player 2 player eval
             dey

             ;plot the current player score...
             lda #(32-SCORESIZE) ; palette=0*32 
             sta temp3 ; palette/width
             lda highscorelabeladjust2,y
             sta temp4 ; X
             lda #((HSSCOREY+18)/(WZONEHEIGHT/8))
             sta temp5 ; Y

             lda scorevarlo,y
             sta temp7 ; score variable lo
             lda scorevarhi,y
             sta temp8 ; score variable hi

             lda #(hiscorefont_mode | %01100000) ; charactermode 
             sta temp9

             lda #<(hiscorefont+33) ; +33 to get to '0' character
             sta temp1 ; charmaplo
             lda #>(hiscorefont+33)
             sta temp2 ; charmaphi
             lda #SCORESIZE
             sta temp6
             jsr plotvalue

             ifconst HSGAMERANKS
                 
                 ldx #$ff ; start at 0 after the inx...
comparescore2rankloop
                 inx
                 ldy #0
                 lda rankvalue_0,x
                 cmp (temp7),y
                 bcc score2rankloopdone
                 bne comparescore2rankloop
                 iny
                 lda rankvalue_1,x
                 cmp (temp7),y
                 bcc score2rankloopdone
                 bne comparescore2rankloop
                 iny
                 lda (temp7),y
                 cmp rankvalue_2,x
                 bcs score2rankloopdone
                 jmp comparescore2rankloop
score2rankloopdone
                 stx hsnewscorerank
                 
                 lda ranklabello,x
                 sta temp1
                 lda ranklabelhi,x
                 sta temp2
                 sec
                 lda #32 ; palette=0*29 | 32-(width=3)
                 sbc ranklabellengths,x
                 sta temp3 ; palette/width
                 sec
                 lda #(40+6)
                 sbc ranklabellengths,x
                 asl
                 sta temp4 ; X
                 lda #((HSSCOREY+20)/(WZONEHEIGHT/8))
                 sta temp5 ; Y
                 jsr plotcharacters

                 ldx hsnewscorerank

                 lda #<highscoreranklabel
                 sta temp1
                 lda #>highscoreranklabel
                 sta temp2

                 lda #(32-5) ; palette=0*29 | 32-(width=3)
                 sta temp3 ; palette/width
                 lda #(40-6)
                 sec
                 sbc ranklabellengths,x
                 asl
                 sta temp4 ; X
                 lda #((HSSCOREY+20)/(WZONEHEIGHT/8))
                 sta temp5 ; Y
                 jsr plotcharacters
             endif


             ; ** which line did this player beat?
             lda #$ff
             sta hsnewscoreline
             ldx #$fd 
comparescoreadd2x
             inx
comparescoreadd1x
             inx
comparescore2lineloop
             inc hsnewscoreline
             inx ; initialrun, x=0
             cpx #15
             beq nohighscoreforyou
             ldy #0
             lda HSRAMScores,x
             cmp (temp7),y ; first score digit
             bcc score2lineloopdonedel1x
             bne comparescoreadd2x
             iny
             inx
             lda HSRAMScores,x
             cmp (temp7),y
             bcc score2lineloopdonedel2x
             bne comparescoreadd1x
             iny
             inx
             lda (temp7),y
             cmp HSRAMScores,x
             bcs score2lineloopdonedel3x
             jmp comparescore2lineloop
nohighscoreforyou
             lda #$ff
             sta hsnewscoreline
             sta countdownseconds
             jmp donoscoreevaluation
score2lineloopdonedel3x
             dex
score2lineloopdonedel2x
             dex
score2lineloopdonedel1x
             dex

             ; 0 1 2
             ; 3 4 5
             ; 6 7 8
             ; 9 0 1
             ; 2 3 4

             stx temp9
             cpx #11
             beq postsortscoresuploop
             ldx #11
sortscoresuploop
             lda HSRAMScores,x
             sta HSRAMScores+3,x
             lda HSRAMInitials,x
             sta HSRAMInitials+3,x
             dex
             cpx temp9
             bne sortscoresuploop
postsortscoresuploop

             ;stick the score and cleared initials in the slot...
             inx
             ldy #0 
             sty hsinitialhold
             lda (temp7),y
             sta HSRAMScores,x
             iny
             lda (temp7),y
             sta HSRAMScores+1,x
             iny
             lda (temp7),y
             sta HSRAMScores+2,x
             lda #0
             sta HSRAMInitials,x
             lda #29
             sta HSRAMInitials+1,x
             sta HSRAMInitials+2,x

             stx hsinitialpos

donoscoreevaluation

             lda #(32+(32-SCORESIZE)) ; palette=0*32 | 32-(width=6)
             sta temp3 ; palette/width
             lda #(72+(4*(6-SCORESIZE)))
             sta temp4 ; X
             lda #((HSSCOREY+6)/(WZONEHEIGHT/8))
             sta temp5 ; Y
             lda #<HSRAMScores
             sta temp7 ; score variable lo
             lda #>HSRAMScores
             sta temp8 ; score variable hi
             lda #(hiscorefont_mode | %01100000) ; charactermode 
             sta temp9
plothsscoresloop
             lda #<(hiscorefont+33) ; +33 to get to '0' character
             sta temp1 ; charmaplo
             lda #>(hiscorefont+33)
             sta temp2 ; charmaphi
             lda #6
             sta temp6
             jsr plotvalue
             clc
             lda temp3
             adc #32
             sta temp3
             inc temp5
             if WZONEHEIGHT = 8
                 inc temp5
             endif
             clc
             lda #3
             adc temp7
             sta temp7
             cmp #(<(HSRAMScores+15))
             bcc plothsscoresloop
plothsindex
             lda #32+31 ; palette=0*32 | 32-(width=1)
             sta temp3 ; palette/width
             lda #44
             sta temp4 ; X
             lda #((HSSCOREY+6)/(WZONEHEIGHT/8))
             sta temp5 ; Y
             lda #<hsgameslotnumbers
             sta temp7 ; score variable lo
             lda #>hsgameslotnumbers
             sta temp8 ; score variable hi
             lda #(hiscorefont_mode | %01100000) ; charactermode 
             sta temp9
plothsindexloop
             lda #<(hiscorefont+33)
             sta temp1 ; charmaplo
             lda #>(hiscorefont+33)
             sta temp2 ; charmaphi
             lda #1
             sta temp6 ; number of characters
             jsr plotvalue
             clc
             lda temp3
             adc #32
             sta temp3
             inc temp5
             if WZONEHEIGHT = 8
                 inc temp5
             endif
             inc temp7
             lda temp7
             cmp #(<(hsgameslotnumbers+5))
             bcc plothsindexloop

             jsr savescreen

             ifnconst HSSECONDS
                 lda #6
             else
                 lda #HSSECONDS
             endif
             sta countdownseconds
             
keepdisplayinghs
             jsr restorescreen


             jsr setuphsinpt1

             lda hsnewscoreline
             bpl carryonkeepdisplayinghs
             jmp skipenterscorecontrol
carryonkeepdisplayinghs


             ifnconst HSSECONDS
                 lda #6
             else
                 lda #HSSECONDS
             endif
             sta countdownseconds

             ;plot the cursor underneath the line
             lda #<(hiscorefont+28)
             sta temp1
             lda #>(hiscorefont+28)
             sta temp2
             lda #31 ; palette=0*32 | 32-(width=1)
             sta temp3 ; palette/width
             lda hscursorx
             asl
             asl
             clc
             adc #104
             sta temp4 ; X
             lda hsnewscoreline
             asl
             asl
             asl
             asl
             adc #((3*16)+6+HSCURSORY)
             sta temp5 ; Y
             lda #%01000000
             sta temp6
             jsr plotsprite

             lda SWCHA
             cpx #3
             bne hsskipadjustjoystick1
             asl
             asl
             asl
             asl
hsskipadjustjoystick1
             sta hsswcha
             and #%00110000
             cmp #%00110000
             beq hsjoystickskipped
             lda hsjoydebounce
             beq hsdontdebounce
             jmp hspostjoystick
hsdontdebounce
             ldx #1 ; small tick sound
             jsr playhssfx
             lda hsswcha
             and #%00110000
             ldx hscursorx
             cmp #%00100000 ; check down
             bne hsjoycheckup
             ldy hsinitialhold
             cpx #0
             bne skipavoid31_1
             cpy #0
             bne skipavoid31_1
             dey
skipavoid31_1
             dey
             jmp hssetdebounce
hsjoycheckup
             cmp #%00010000 ; check up
             bne hsjoystickskipped
             ldy hsinitialhold
             cpx #0
             bne skipavoid31_2
             cpy #15
             bne skipavoid31_2
             iny
skipavoid31_2
             iny
hssetdebounce
             tya
             and #31
             sta hsinitialhold
             lda #15
             sta hsjoydebounce
             bne hspostjoystick
hsjoystickskipped
             ; check the fire button only when the stick isn't engaged
             lda hsinpt1
             bpl hsbuttonskipped
             lda hsjoydebounce
             beq hsfiredontdebounce
             bne hspostjoystick
hsfiredontdebounce
             lda hsinitialhold
             cmp #31
             beq hsmovecursorback
             inc hscursorx
             inc hsinitialpos
             lda hscursorx
             cmp #3
             bne skiphsentryisdone
             lda #0
             sta framecounter
             lda #$ff
             sta hsnewscoreline
             dec hsinitialpos
             bne skiphsentryisdone
hsmovecursorback
             lda #29
             ldx hsinitialpos
             sta HSRAMInitials,x
             dec hsinitialpos
             dec hscursorx
             dex
             lda HSRAMInitials,x
             sta hsinitialhold

skiphsentryisdone
             ldx #0
             jsr playhssfx
             lda #20
             sta hsjoydebounce
             bne hspostjoystick

hsbuttonskipped
             lda #0
             sta hsjoydebounce
hspostjoystick

             ldx hsinitialpos
             lda hsinitialhold
             sta HSRAMInitials,x

             jmp skiphschasecolors

skipenterscorecontrol
             jsr hschasecolors
             jsr setuphsinpt1
             lda hsjoydebounce
             bne skiphschasecolors
             lda hsinpt1
             bmi returnfromhs
skiphschasecolors

             jsr drawscreen

             lda countdownseconds
             beq returnfromhs
             jmp keepdisplayinghs
returnfromhs
             jsr drawwait
             jsr clearscreen
             lda #0
             ldy #7
             jsr blacken320colors
             lda ssCTRL
             sta sCTRL
             lda ssCHARBASE
             sta sCHARBASE 
             rts

setuphsinpt1
             lda #$ff
             sta hsinpt1
             lda hsjoydebounce
             beq skipdebounceadjust
             dec hsjoydebounce
             bne skipstorefirebuttonstatus
skipdebounceadjust
             ldx hsdisplaymode
             cpx #3
             bne hsskipadjustjoyfire1
             lda sINPT3
             jmp hsskipadjustjoyfire1done
hsskipadjustjoyfire1
             lda sINPT1
hsskipadjustjoyfire1done
             sta hsinpt1
skipstorefirebuttonstatus
             rts

blacken320colors
             ldy #7
blacken320colorsloop
             sta P0C2,y
             dey
             bpl blacken320colorsloop
             rts

hschasecolors
             lda framecounter
             and #3
             bne hschasecolorsreturn
             inc hscolorchaseindex
             lda hscolorchaseindex
             
             sta P5C2
             sbc #$02
             sta P4C2
             sbc #$02
             sta P3C2
             sbc #$02
             sta P2C2
             sbc #$02
             sta P1C2
hschasecolorsreturn
             rts


playhssfx
             lda hssfx_lo,x
             sta temp1
             lda hssfx_hi,x
             sta temp2
             lda #0
             sta temp3
             jmp schedulesfx

hssfx_lo
             .byte <sfx_hsletterpositionchange, <sfx_hslettertick
hssfx_hi
             .byte >sfx_hsletterpositionchange, >sfx_hslettertick

sfx_hsletterpositionchange
             .byte $10,$18,$00
             .byte $02,$06,$08
             .byte $02,$06,$04
             .byte $00,$00,$00

sfx_hslettertick
             .byte $10,$18,$00
             .byte $00,$00,$0a
             .byte $00,$00,$00

highscorelabeladjust1
             .byte (80-(14*2)-(SCORESIZE*2)),(80-(16*2)-(SCORESIZE*2)),(80-(16*2)-(SCORESIZE*2))
highscorelabeladjust2
             .byte (80+(14*2)-(SCORESIZE*2)),(80+(16*2)-(SCORESIZE*2)),(80+(16*2)-(SCORESIZE*2))

scorevarlo
             .byte <(score0+((6-SCORESIZE)/2)),<(score0+((6-SCORESIZE)/2)),<(score1+((6-SCORESIZE)/2))
scorevarhi
             .byte >(score0+((6-SCORESIZE)/2)),>(score0+((6-SCORESIZE)/2)),>(score1+((6-SCORESIZE)/2))

             ifnconst HSNOLEVELNAMES
highscoredifficultytextlo
                 .byte <easylevelname, <mediumlevelname, <hardlevelname, <expertlevelname
highscoredifficultytexthi
                 .byte >easylevelname, >mediumlevelname, >hardlevelname, >expertlevelname

             ifnconst HSCUSTOMLEVELNAMES
highscoredifficultytextlen
                 .byte 22, 30, 26, 24
                 
easylevelname
                 .byte $04,$00,$12,$18,$1d,$0b,$04,$15,$04,$0b,$1d,$07,$08,$06,$07,$1d,$12,$02,$0e,$11,$04,$12
mediumlevelname
                 .byte $08,$0d,$13,$04,$11,$0c,$04,$03,$08,$00,$13,$04,$1d,$0b,$04,$15,$04,$0b,$1d,$07,$08,$06,$07,$1d,$12,$02,$0e,$11,$04,$12
hardlevelname
                 .byte $00,$03,$15,$00,$0d,$02,$04,$03,$1d,$0b,$04,$15,$04,$0b,$1d,$07,$08,$06,$07,$1d,$12,$02,$0e,$11,$04,$12
expertlevelname
                 .byte $04,$17,$0f,$04,$11,$13,$1d,$0b,$04,$15,$04,$0b,$1d,$07,$08,$06,$07,$1d,$12,$02,$0e,$11,$04,$12
             else
                 include "7800hsgamediffnames.asm"
             endif ; HSCUSTOMLEVELNAMES
             else
HSHIGHSCOREStext
                 .byte $07,$08,$06,$07,$1d,$12,$02,$0e,$11,$04,$12

             endif ; HSNOLEVELNAMES

highscorelabeltextlo
             .byte <player0label, <player1label, <player2label
highscorelabeltexthi
             .byte >player0label, >player1label, >player2label

player0label
             .byte $0f,$0b,$00,$18,$04,$11,$1d,$12,$02,$0e,$11,$04,$1a,$1d,$1d

player1label
             .byte $0f,$0b,$00,$18,$04,$11,$1d,$22,$1d,$12,$02,$0e,$11,$04,$1a

player2label
             .byte $0f,$0b,$00,$18,$04,$11,$1d,$23,$1d,$12,$02,$0e,$11,$04,$1a


             ifconst HSGAMENAMELEN
HSGAMENAMEtable
                 include "7800hsgamename.asm"
             endif
             ifconst HSGAMERANKS
                 include "7800hsgameranks.asm"
highscoreranklabel
                 .byte $11,$00,$0d,$0a,$1a
             endif

             ;ensure our table doesn't wrap a page...
             if ((<*)>251)
                 align 256
             endif
hsgameslotnumbers
             .byte 33,34,35,36,37
         endif

loaddifficultytable
         lda gamedifficulty
         and #$03 ; ensure the user hasn't selected an invalid difficulty
         sta gamedifficulty
         cmp hsdifficulty; check game difficulty is the same as RAM table
         bne loaddifficultytablecontinue1
         rts ; this high score difficulty table is already loaded
loaddifficultytablecontinue1
         lda gamedifficulty
         sta hsdifficulty
         ;we need to check the device for the table
         lda hsdevice
         bne loaddifficultytablecontinue2
         ; there's no save device. clear out this table.
         jmp cleardifficultytablemem
loaddifficultytablecontinue2
         lda hsdevice
         and #1
         beq memdeviceisntHSC
         jmp loaddifficultytableHSC
memdeviceisntHSC
         jmp loaddifficultytableAVOX

savedifficultytable
         ;*** we need to check wich device we should use...
         lda hsdevice
         bne savedifficultytablerealdevice
         rts ; its a ram device
savedifficultytablerealdevice
         and #1
         beq savememdeviceisntHSC
         jmp savedifficultytableHSC
savememdeviceisntHSC
         jmp savedifficultytableAVOX

savedifficultytableAVOX
         ; the load call already setup the memory structure and atarivox memory location
         jsr savealoadedHSCtablecontinue
         lda #HSIDHI
         sta eeprombuffer
         lda #HSIDLO
         sta eeprombuffer+1
         lda hsdifficulty
         sta eeprombuffer+2
         lda #32
         jsr AVoxWriteBytes
         rts

savedifficultytableHSC
         ;we always load a table before reaching here, so the
         ;memory structures from the load should be intact...
         ldy hsgameslot
         bpl savealoadedHSCtable
         rts
savealoadedHSCtable
         lda HSCGameDifficulty,y 
         cmp #$7F
         bne savealoadedHSCtablecontinue
         jsr initializeHSCtableentry
savealoadedHSCtablecontinue
         ;convert our RAM table to HSC format and write it out...
         ldy #0
         ldx #0
savedifficultytableScores

         lda HSRAMInitials,x
         sta temp3
         lda HSRAMInitials+1,x
         sta temp4
         lda HSRAMInitials+2,x
         sta temp5
         jsr encodeHSCInitials ; takes 3 byte initials from temp3,4,5 and stores 2 byte initials in temp1,2

         lda temp1
         sta (HSGameTableLo),y
         iny
         lda temp2
         sta (HSGameTableLo),y
         iny
         
         lda HSRAMScores,x
         sta (HSGameTableLo),y
         iny
         lda HSRAMScores+1,x
         sta (HSGameTableLo),y
         iny
         lda HSRAMScores+2,x
         sta (HSGameTableLo),y
         iny
         inx
         inx
         inx ; +3
         cpx #15
         bne savedifficultytableScores
         rts

loaddifficultytableHSC
         ; routine responsible for loading the difficulty table from HSC
         jsr findindexHSC
         ldy hsgameslot
         lda HSCGameDifficulty,y 
         cmp #$7F
         bne loaddifficultytableHSCcontinue
         ;there was an error. use a new RAM table instead...
         jmp cleardifficultytablemem
loaddifficultytableHSCcontinue
         ; parse the data into the HS memory...
         ldy #0
         ldx #0
loaddifficultytableScores
         lda (HSGameTableLo),y
         sta temp1
         iny
         lda (HSGameTableLo),y
         sta temp2
         jsr decodeHSCInitials ; takes 2 byte initials from temp1,2 and stores 3 byte initials in temp3,4,5
         iny
         lda (HSGameTableLo),y
         sta HSRAMScores,x
         lda temp3
         sta HSRAMInitials,x
         inx
         iny
         lda (HSGameTableLo),y
         sta HSRAMScores,x
         lda temp4
         sta HSRAMInitials,x
         inx
         iny
         lda (HSGameTableLo),y
         sta HSRAMScores,x
         lda temp5
         sta HSRAMInitials,x
         inx
         iny
         cpx #15
         bne loaddifficultytableScores
         rts

decodeHSCInitials
         ; takes 2 byte initials from temp1,2 and stores 3 byte initials in temp3,4,5
         ; 2 bytes are packed in the form: 22211111 22_33333
         lda #0
         sta temp4

         lda temp1
         and #%00011111
         sta temp3

         lda temp2
         and #%00011111
         sta temp5

         lda temp1
         asl
         rol temp4
         asl
         rol temp4
         asl
         rol temp4
         lda temp2
         asl
         rol temp4
         asl
         rol temp4
         rts

encodeHSCInitials
         ; takes 3 byte initials from temp3,4,5 and stores 2 byte initials in temp1,2
         ; 2 bytes are packed in the form: 22211111 22_33333
         ; start with packing temp1...
         lda temp4
         and #%00011100
         sta temp1
         asl temp1
         asl temp1
         asl temp1
         lda temp3
         and #%00011111
         ora temp1
         sta temp1
         ; ...temp1 is now packed, on to temp2...
         lda temp5
         asl 
         asl
         ror temp4
         ror
         ror temp4
         ror
         sta temp2
         rts 

findindexHSCerror
         ;the HSC is stuffed. return the bad slot flag
         ldy #$ff
         sty hsgameslot
         rts

findindexHSC
HSCGameID1         = $1029
HSCGameID2         = $106E
HSCGameDifficulty         = $10B3
HSCGameIndex         = $10F8
         ; routine responsible for finding the game index from HSC
         ; call with x=0 to create a new table if none exist, call with x=$ff to avoid creating new tables
         ; the HS loading routine will use x=$ff, the HS saving routine will use x=0
         ldy #69 ; start +1 to account for the dey
findindexHSCloop
         dey
         bmi findindexHSCerror
         lda HSCGameDifficulty,y 
         cmp #$7F
         beq findourindexHSC
         cmp gamedifficulty
         bne findindexHSCloop
         lda HSCGameID1,y 
         cmp #HSIDHI
         bne findindexHSCloop
         lda HSCGameID2,y 
         cmp #HSIDLO
         bne findindexHSCloop
findourindexHSC
         ; if we're here we found our index in the table
         ; or we found the first empty one
         sty hsgameslot
         jsr setupHSCGamepointer ; setup the pointer to the HS Table for this game...
         rts


initializeHSCtableentry
         ldy hsgameslot 
         ; we need to make a new entry...
         lda #HSIDHI
         sta HSCGameID1,y
         lda #HSIDLO
         sta HSCGameID2,y
         lda gamedifficulty
         sta HSCGameDifficulty,y 
         ldx #0
fixHSDGameDifficultylistLoop
         inx
         txa
         sta HSCGameIndex,y
         iny
         cpy #69
         bne fixHSDGameDifficultylistLoop
         rts

setupHSCGamepointer
         ; this routines sets (HSGameTableLo) pointing to the game's HS table
         lda #$17
         sta HSGameTableHi
         lda #$FA
         sta HSGameTableLo
setupHSCGamepointerLoop
         lda HSGameTableLo
         sec
         sbc #25
         sta HSGameTableLo
         lda HSGameTableHi
         sbc #0
         sta HSGameTableHi
         iny
         cpy #69
         bne setupHSCGamepointerLoop
         rts
         
loaddifficultytableAVOX
         ; routine responsible for loading the difficulty table from Avox
         ; we reuse HSC routines to format data to/from our Avox RAM buffer...
         lda #>(eeprombuffer+3)
         sta HSGameTableHi
         lda #<(eeprombuffer+3)
         sta HSGameTableLo

         ; the start location in EEPROM, subtract 32...
         lda #$5F
         sta HSVoxHi
         lda #$E0
         sta HSVoxLo
         lda #0
         sta temp1
loaddifficultytableAVOXloop
         inc temp1
         beq loaddifficultytableAVOXfull
         clc
         lda HSVoxLo
         adc #32
         sta HSVoxLo
         lda HSVoxHi
         adc #0
         sta HSVoxHi
         lda #3
         jsr AVoxReadBytes ; read in 3 bytes, ID1,ID2,Difficulty
         lda eeprombuffer
         cmp #$FF
         beq loaddifficultytableAVOXempty
         cmp #HSIDHI
         bne loaddifficultytableAVOXloop
         lda eeprombuffer+1
         cmp #HSIDLO
         bne loaddifficultytableAVOXloop
         lda eeprombuffer+2
         cmp gamedifficulty
         bne loaddifficultytableAVOXloop
loaddifficultytableAVOXdone
         lda #32
         jsr AVoxReadBytes
         jsr loaddifficultytableHSCcontinue
         rts
loaddifficultytableAVOXfull
         lda #0
         sta hsdevice ; looks like all 255 entries are taken... disable it.
loaddifficultytableAVOXempty
         jmp cleardifficultytablemem         
         rts

cleardifficultytablemem
         ldy #29
         lda #0
cleardifficultytablememloop
         sta HSRAMTable,y
         dey
         bpl cleardifficultytablememloop
         rts
         
     endif ; HSSUPPORT

START
start

     ;******** more or less the Atari recommended startup procedure

     sei
     cld

  ifnconst NOTIALOCK
     lda #$07
  else
     lda #$06
  endif
     sta INPTCTRL ;lock 7800 into 7800 mode
     lda #$7F
     sta CTRL ;disable DMA
     lda #$00
     sta OFFSET
  ifnconst NOTIALOCK
     sta INPTCTRL
  endif
     ldx #$FF
     txs

     ;************** Clear Memory

     ldx #$40
     lda #$00
crloop1     
     sta $00,x ;Clear zero page
     sta $100,x ;Clear page 1
     inx
     bne crloop1


     ldy #$00 ;Clear Ram
     lda #$18 ;Start at $1800
     sta $81 
     lda #$00
     sta $80
crloop3
     lda #$00
     sta ($80),y ;Store data
     iny ;Next byte
     bne crloop3 ;Branch if not done page
     inc $81 ;Next page
     lda $81
     cmp #$20 ;End at $1FFF
     bne crloop3 ;Branch if not

     ldy #$00 ;Clear Ram
     lda #$22 ;Start at $2200
     sta $81 
     lda #$00
     sta $80
crloop4
     lda #$00
     sta ($80),y ;Store data
     iny ;Next byte
     bne crloop4 ;Branch if not done page
     inc $81 ;Next page
     lda $81
     cmp #$27 ;End at $27FF
     bne crloop4 ;Branch if not

     ldx #$00
     lda #$00
crloop5     ;Clear 2100-213F, 2000-203F
     sta $2000,x
     sta $2100,x
     inx
     cpx #$40
     bne crloop5

     sta $80
     sta $81
     sta $82
     sta $83

     ;seed random number with hopefully-random timer value
     lda #1
     ora INTIM
     sta rand

     ; detect the console type...
pndetectvblankstart
     lda MSTAT
     bpl pndetectvblankstart ; if we're not in VBLANK, wait for it to start 
pndetectvblankover
     lda MSTAT
     bmi pndetectvblankover ;  then wait for it to be over
     ldy #$00
     ldx #$00
pndetectvblankhappening
     lda MSTAT
     bmi pndetectinvblank   ;  if VBLANK starts, exit our counting loop 
     sta WSYNC
     sta WSYNC
     inx
     bne pndetectvblankhappening
pndetectinvblank
     cpx #125
     bcc pndetecispal
     ldy #$01
pndetecispal
     sty paldetected

     jsr createallgamedlls

     lda #>DLLMEM
     sta DPPH
     lda #<DLLMEM
     sta DPPL

     ; CTRL 76543210
     ; 7 colorburst kill
     ; 6,5 dma ctrl 2=normal DMA, 3=no DMA
     ; 4 character width 1=2 byte chars, 0=1 byte chars
     ; 3 border control 0=background color border, 1=black border
     ; 2 kangaroo mode 0=transparancy, 1=kangaroo
     ; 1,0 read mode 0=160x2/160x4 1=N/A 2=320B/320D 3=320A/320C

     ifconst DOUBLEWIDE
         lda #%01010000 ;Enable DMA, mode=160x2/160x4, 2x character width
     else
         lda #%01000000 ;Enable DMA, mode=160x2/160x4
     endif
     sta CTRL
     sta sCTRL

     jsr vblankresync

     ifconst pokeysupport
         ; pokey support is compiled in, so try to detect it...
         jsr detectpokeylocation
     endif

     ;Setup port B for two button reading, and turn on both joysticks...
     lda #$14
     sta CTLSWB
     lda #0
     sta SWCHB

     ;Setup port A to read mode
     ;lda #$00
     ;sta SWCHA
     ;sta CTLSWA

     ifconst HSSUPPORT
         ; try to detect HSC
         jsr detecthsc
         and #1
         sta hsdevice
skipHSCdetect
         ; try to detect AtariVox eeprom
         jsr detectatarivoxeeprom
         and #2
         ora hsdevice
         cmp #3
         bne storeAinhsdevice
         ; For now, we tie break by giving HSC priority over AtariVox.
         ; Later we should check each device's priority byte if set, instead, 
         lda #2 
storeAinhsdevice
         sta hsdevice
         lda #$ff
         sta hsdifficulty
         sta hsgameslot
         sta hsnewscoreline
     endif

     ifconst AVOXVOICE
         jsr silenceavoxvoice
     endif


     ifconst bankswitchmode
         ; we need to switch to the first bank before we jump there!
         ifconst MCPDEVCART
             lda #$18 ; xxx11nnn - switch to bank 0
             sta $3000
         else
             lda #0
             sta $8000
         endif
     endif

     jmp game


     ;************** Setup DLL entries

     ; setup some working definitions, to avoid ifnconst mess elsewhere...
     ifnconst SCREENHEIGHT
WSCREENHEIGHT         = 192
     else
WSCREENHEIGHT         = SCREENHEIGHT
     endif

     ifnconst ZONEHEIGHT
WZONEHEIGHT         = 16
     else
WZONEHEIGHT         = ZONEHEIGHT
     endif

     ifnconst ZONECOUNT
WZONECOUNT         = (WSCREENHEIGHT/WZONEHEIGHT)
     else
WZONECOUNT         = ZONECOUNT
     endif

     ; top of the frame, non-visible lines. this is based on NTSC,
     ; but we add in extra NV lines at the end of the display to ensure
     ; our PAL friends can play the game without it crashing.
NVLINES         = ((243-WSCREENHEIGHT)/2)

  if WZONEHEIGHT = 8
  if WSCREENHEIGHT = 192
DLPOINTH
   .byte $18,$18,$19,$19,$19,$1a,$1a,$1a,$1a,$1b,$1b,$1b
   .byte $1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1f,$1f
DLPOINTL
   .byte $80,$cd,$1a,$67,$b4,$01,$4e,$9b,$e8,$35,$82,$cf
   .byte $1c,$69,$b6,$03,$50,$9d,$ea,$37,$84,$d1,$1e,$6b
   ; last byte used in DLL: 1fb7
   ; max number of objects per DL: 15
DLLASTOBJ = 75
DLHEIGHT
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
  endif ; 192 (8)

  if WSCREENHEIGHT = 208
DLPOINTH
   .byte $18,$18,$19,$19,$19,$19,$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b
   .byte $1c,$1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1f,$1f,$1f
DLPOINTL
   .byte $80,$c3,$06,$49,$8c,$cf,$12,$55,$98,$db,$1e,$61,$a4,$e7
   .byte $2a,$6d,$b0,$f3,$36,$79,$bc,$ff,$42,$85,$c8,$0b,$4e,$91
   ; last byte used in DLL: 1fd3
   ; max number of objects per DL: 13
DLLASTOBJ = 65
DLHEIGHT
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
  endif ; 208 (8)

  if WSCREENHEIGHT = 224
DLPOINTH
   .byte $18,$18,$18,$19,$19,$19,$19,$1a,$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b
   .byte $1c,$1c,$1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1e,$1e,$1f,$1f
DLPOINTL
   .byte $80,$b9,$f2,$2b,$64,$9d,$d6,$0f,$48,$81,$ba,$f3,$2c,$65,$9e,$d7
   .byte $10,$49,$82,$bb,$f4,$2d,$66,$9f,$d8,$11,$4a,$83,$bc,$f5,$2e,$67
   ; last byte used in DLL: 1f9f
   ; max number of objects per DL: 11
DLLASTOBJ = 55
DLHEIGHT
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
  endif ; 224 (8)
  endif ; 8

  if WZONEHEIGHT = 16
  if WSCREENHEIGHT = 192
DLPOINTH
   .byte $18,$19,$19,$1a,$1a,$1b,$1c,$1c,$1d,$1e,$1e,$1f
DLPOINTL
   .byte $80,$1d,$ba,$57,$f4,$91,$2e,$cb,$68,$05,$a2,$3f
   ; last byte used in DLL: 1fdb
   ; max number of objects per DL: 31
DLLASTOBJ = 155
DLHEIGHT
   .byte $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
  endif ; 192 (16)

  if WSCREENHEIGHT = 208
DLPOINTH
   .byte $18,$19,$19,$1a,$1a,$1b,$1b,$1c,$1d,$1d,$1e,$1e,$1f
DLPOINTL
   .byte $80,$13,$a6,$39,$cc,$5f,$f2,$85,$18,$ab,$3e,$d1,$64
   ; last byte used in DLL: 1ff6
   ; max number of objects per DL: 29
DLLASTOBJ = 145
DLHEIGHT
   .byte $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
  endif ; 208 (16)

  if WSCREENHEIGHT = 224
DLPOINTH
   .byte $18,$19,$19,$1a,$1a,$1b,$1b,$1c,$1c,$1d,$1d,$1e,$1e,$1f
DLPOINTL
   .byte $80,$09,$92,$1b,$a4,$2d,$b6,$3f,$c8,$51,$da,$63,$ec,$75
   ; last byte used in DLL: 1ffd
   ; max number of objects per DL: 27
DLLASTOBJ = 135
DLHEIGHT
   .byte $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
  endif ; 224 (16)
  endif ; 16

 ifconst HSSUPPORT
HSDLPOINTH
   .byte $18,$18,$19,$19,$19,$1a,$1a,$1a,$1a,$1b,$1b,$1b
   .byte $1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1f,$1f
HSDLPOINTL
   .byte $80,$cd,$1a,$67,$b4,$01,$4e,$9b,$e8,$35,$82,$cf
   .byte $1c,$69,$b6,$03,$50,$9d,$ea,$37,$84,$d1,$1e,$6b
   ; last byte used in DLL: 1fb7
   ; max number of objects per DL: 15
HSDLLASTOBJ = 75
HSDLHEIGHT
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
   .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
 endif
  ifconst DEV
    ifnconst ZONEHEIGHT
      echo "* the 4k 7800basic area has",[($FFF8 - *)]d,"bytes free."
    else
      if ZONEHEIGHT =  8
        echo "* the 4k 7800basic area has",[($FFF8 - *)]d,"bytes free."
      else
        echo "* the 4k 7800basic area has",[($FFF8 - *)]d,"bytes free."
      endif
    endif
  endif

  ifnconst bankswitchmode 
    ORG $FFF8
  else
    ifconst ROM128K
      ORG $27FF8
      RORG $FFF8
    endif
    ifconst ROM256K
      ORG $47FF8
      RORG $FFF8
    endif
    ifconst ROM512K
      ORG $87FF8
      RORG $FFF8
    endif
  endif


  .byte   $FF	; region verification. $FF=all regions
  .byte   $F7	; high nibble:  encryption check from $N000 to $FF7F. we only hash the last 4k for faster boot.
		; low nibble :  N=7 atari rainbow start, N=3 no atari rainbow

  ;Vectors
  .word NMI
  .word START
  .word IRQ

