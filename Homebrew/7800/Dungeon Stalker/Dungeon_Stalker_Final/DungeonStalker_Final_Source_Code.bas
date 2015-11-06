
  rem -------------------------------------------------------------------------------------------
  rem `             __________ ____ ________ ______ ___  ______  ____  ____      __             `
  rem `             %%%%%%%%%% %%%% %%%%%%%% %%%%%% %%%  %%%%%%  %%%%  %%%%      %%             `
  rem `              %%%%%%%%%% %%% %%%% %%% %%%  %%%%%% %%%    %%%%%% %%%%%   %%%              `
  rem `               %%%%% %%%% %% %%%% %%%% %% %%%     %%%%% %%%   %% %%%%   %%               `
  rem `              %%%%   %%%% %% %%%% %% %%%% %%% %%% %%%%% %%%   %% %% %%  %%%              `
  rem `              %%%%    %%% %%  %%% %%% %%% %%%  %% %%%   %%%   %% %% %%% %%%              `
  rem `              %%%%    %%% %%%%%%% %%   %%  %%%%%% %%%%%% %%%%%%  %% %%%% %%              `
  rem `               %%%    %%%_____ ______ ____  ___  ____ ___ _____ _____%%%%%%              `
  rem `              %%%%%%%%%% %%%%% %%%%%% %%%%  %%%  %%%% %%% %%%%% %%%%%  %%%%              `
  rem `              %%%%%%%% %%%%  %% %%% %%%%%%% %%    %%% %%% %%    %% %%%   %%              `
  rem `              %%%%%%%   %%%%%   %%% %%%  %% %%     %%%%   %%%%  %% %%%    %              `
  rem `                           %%%  %%% %%%%%%% %%     %%%%   %%%%  %%%%%                    `
  rem `                      %%%%  %%  %%% %%%  %% %%%%%% %% %%% %%    %%  %%                   `
  rem `                       %%%%%%%  %%% %%%  %% %%%%%  %%  %% %%%%% %% %%%%                  `
  rem `                                                                                         `
  rem `                             Dungeon Stalker for the Atari 7800                          `
  rem `                                  Created with 7800Basic                                 `
  rem `                                     Copyright (C)2015                                   `
  rem `                       Programmed by Steve Engelhardt and Mike Saarna                    `
  rem `                          (Atarius Maximus and RevEng at AtariAge)                       `
  rem `                                    Final Release v.245                                  `
  rem `                                       October 2015                                      `
  rem `                                                                                         `
  rem `                                    Download 7800Basic:                                  `
  rem `         http://atariage.com/forums/topic/222638-7800basic-beta-the-release-thread/      `
  rem `                                                                                         `
  rem -------------------------------------------------------------------------------------------
  rem 
  rem                                           Credits
  rem                                           ~~~~~~~
  rem
  rem   Mike & I would like to give special thanks to Robert Tuccitto and Marco Sabbetta for 
  rem   their support and contributions during the development of Dungeon Stalker, to Albert 
  rem   Yarusso at AtariAge for making a cartridge release possible, to David Exton for creating
  rem   the artwork, and to everyone who made suggestions on the AtariAge forums.  
  rem
  rem   Including comments and blank lines, this code is over 4500 lines long!  It represents
  rem   many months of hard work and was a labor of love.  Thanks to everyone who helped out.
  rem
  rem                                  Getting Started/Tutorials
  rem                                  ~~~~~~~~~~~~~~~~~~~~~~~~~
  rem
  rem   I used Gimp for graphics editing and Tiled for creating the tmx map files.  Both are 
  rem   free programs and are incredibly useful, if not essential, for creating 7800basic games.
  rem   I created a few tutorials on how to use these tools when making your own games.
  rem
  rem   Gimp tutorial:
  rem   atariage.com/forums/topic/226566-creating-7800basic-compatible-graphics-images-with-gimp/
  rem
  rem   Tiled tutorial:
  rem   atariage.com/forums/topic/227696-creating-7800basic-compatible-maps-with-the-tiled-app/
  rem
  rem   More info on getting started with 7800basic (Steve's homepage):
  rem   www.bjars.com/7800.html#7800basic_Programming_Environment
  rem
  rem   The release thread for 7800basic at AtariAge:
  rem   atariage.com/forums/topic/222638-7800basic-beta-the-release-thread/
  rem
  rem   The release and development thread for Dungeon Stalker at AtariAge:
  rem   http://atariage.com/forums/topic/236861-dungeon-stalker-a-new-atari-7800-game/
  rem
  rem -------------------------------------------------------------------------------------------

  rem ** ROM Space used in final release (48k ROM)
  rem ** 130 bytes free in main area
  rem ** 256 bytes free in DMA hole 0
  rem ** 275 bytes free in DMA hole 1 
  rem ** 480 bytes free in DMA hole 2
  rem ** 144 bytes free in DMA hole 3
  rem ** 389 bytes free in DMA hole 4
  rem ** 014 bytes free in DMA hole 5
  rem ** 1,688 bytes free total out of 49,152 bytes

  rem ** Set all of the kernel options for 7800basic
  rem
  rem ** These are all detailed in Mike's documentation that's included in the distrubution, 
  rem ** and at RT's website: http://www.randomterrain.com/7800basic.html

  rem ** -Set Display Mode-
  rem ** This command sets the current graphics display mode. You may choose between 160A, 320A, 320B.
  rem ** It should be noted that these modes are also capable of displaying 160B, 320C, and 320D 
  rem ** formatted graphics, respectively.
  displaymode 320A

  rem ** -Set Zone Height-
  rem ** Graphics in 7800basic are limited to either 8 or 16 pixels tall. This is a result of 
  rem ** MARIA's zone based architecture. To use taller sprites in your game, simple define 
  rem ** more sprites and position one above the other. Other 7800 games with sprites taller 
  rem ** than a zone are doing the same, one way or another. The default zone height is 16,
  rem ** but can be defined just once in your program with the zone height setting.
  set zoneheight 8

  rem ** -Set Zone Protection-
  rem ** If too many objects are plotted to the same horizontal zone, there's a chance objects
  rem ** will overflow the storage for that zone, and corrupt display of the next zone. Using 
  rem ** this command will prevent that from happening, at the expense of available CPU time.
  set zoneprotection on

  rem ** -Set Collision Wrap-
  rem ** The Atari 7800 doesn't have hardware collision registers, so any collision detection 
  rem ** needs to happen through software. If your game needs collision detection with sprites 
  rem ** that are partially on-screen partially off-screen, you'll need to set collision-wrapping 
  rem ** on. Be advised that setting collision-wrapping on makes the collision detection take a 
  rem ** bit of extra time.
  set collisionwrap on

  rem ** -Set base path for graphics-
  rem ** This tells 7800basic to add the provided directory path to any relative paths used with 
  rem ** the incgraphic, incmapfile, and plotmapfile commands. In my development environment,
  rem ** I use a 'gfx' subdirectory in the root folder where my 7800basic files reside.
  set basepath gfx

  rem ** -Set Plot Value-
  rem ** This tells 7800basic that when the plotvalue command is used, it should update the screen 
  rem ** immediately, instead of waiting for the screen to complete drawing. This will save precious
  rem ** off-screen cycles for plotting other objects, like sprites. When using this configuration
  rem ** option, a program should issue its plotvalue commands in the same order, immediately after 
  rem ** the restorescreen or clearscreen commands. This will ensure they go into the display list 
  rem ** in the same order as previous frames, which prevents glitching.
  set plotvalueonscreen on

  rem ** -Set ROM size-
  rem ** Ths sets the ROM size and format of your game. The default is 32k, and valid values for 
  rem ** the romsize are 32k, 48k, 128k, 128kRAM, 128kBANKRAM, 256k, 256kRAM, 256kBANKRAM, 512k, 
  rem ** 512kRAM, 512BANKRAM. Formats larger than 48k are bankswitching formats, with many 16k banks. 
  rem ** While you need to bankswitch to access all banks except the last, which is always present. 
  rem ** If you use bankswitching format, you'll need to use the bankswitching goto/gosub commands 
  rem ** to move between different banks. The formats with RAM on the end of the name provide an
  rem ** extra 16k of RAM from $4000-$7fff. You can access this extra RAM by naming it with dim,
  rem ** and using the memory through regular variable access.
  set romsize 48k
  
  rem ** -Set AtariVox-
  rem ** Enables AtariVox speech
  set avoxvoice on

  rem ** -Set High Score Screen Support-
  rem ** This tells 7800basic to include support for saving to the Atari High Score Cart, AtariVox,
  rem ** and Savekey. The #### is a unique hex number that identifies your game. You can reserve 
  rem ** by announcing it in this AtariAge thread: 
  rem ** http://atariage.com/forums/topic/237642-new-self-serve-atarivox-high-score-area/
  set hssupport $1133

  rem ** -Set High Score Difficulty Text-
  rem ** This allows you to provide custom names for the difficulty levels, instead accepting the 
  rem ** default of easy, intermediate, advanced, and expert. The single quotes are only necessary 
  rem ** if your names include spaces.
  set hsdifficultytext 'novice high scores' 'standard high scores' 'advanced high scores' 'expert high scores'

  rem ** -Set High Score Difficulty Screen Title-
  rem ** Set the title of your game for the high score table
  set hsgamename 'dungeon stalker'

  rem ** -Set High Score Ranks-
  rem ** If you use this parameter, the high score tables will display a descriptive ranking of 
  rem ** player's score. The scores+descriptions should be listed in descending order, with the 
  rem ** last score listed being 0. The single quotes are only necessary if your descriptions include spaces.
  set hsgameranks 100000 'supreme warrior' 60000 'warrior' 45000 'apprentice' 30000 'junior apprentice' 15000 'pig flogger' 0 'corpse'

  rem ** -Set Screen Height-
  rem ** The default screen height is 192, but it can be defined once in your program with the 
  rem ** screen height setting. Valid height values are 192, 208, and 224.
  set screenheight 224

  rem ** -Adjust Visible Display-
  rem ** we steal some cycles back from the visible display by telling 7800basic the 
  rem ** active display is shorter than it really is.
  adjustvisible 0 21

  rem ** Set up Variables

  rem ** Available RAM we can assign and use:
  rem ** ...The range of letters A -> Z
  rem ** ...The range of 'var0' -> 'var99'
  rem ** ...RAM locations $2200 -> $27FF

  rem ** Note that monster variable names are generic. For reference:
  rem ** ...monster1=demon bat
  rem ** ...monster2=snake
  rem ** ...monster3=skeleton warrior

  rem ** We first reserve some of our extra RAM for plotting the screen, which reduces the RAM available for variables
  rem ** ...screen ram for our 40x28 screen comes out of our extra 1.5k
  dim screenram=$2200 : rem next free=$268C

  rem ** 273 Defined variables...

  dim xpos			= a
  dim ypos			= b
  dim frame			= c
  dim herodir			= d
  dim quiveranimationframe	= e
  dim p0_x 			= f
  dim p0_y 			= g
  dim temp0_x 			= h
  dim temp0_y 			= i
  dim tempchar1 		= j
  dim tempchar2 		= k
  dim runningdir		= l
  dim runningframe		= m
  dim bat1x			= n
  dim bat2x			= o
  dim bat1y			= p
  dim bat2y			= q
  dim monster1x			= r
  dim monster2x			= s
  dim monster3x			= t
  dim monster1y			= u
  dim monster2y			= v
  dim monster3y			= w
  dim batanimationframe		= x
  dim slowdown1			= y
  dim slowdown2			= z
  dim quiverx			= var0
  dim quivery			= var1
  dim spiderx			= var2
  dim spidery			= var3
  dim spideranimationframe	= var4
  dim monster1animationframe	= var5
  dim monster2animationframe	= var6
  dim monster3animationframe	= var7
  dim xpos_fire			= var8
  dim ypos_fire			= var9
  dim fire_dir			= var10
  dim fire_debounce		= var11
  dim lifecounter		= var12
  dim arrowcounter		= var13
  dim p0_dx			= var14
  dim p0_dy			= var15
  dim screen			= var16
  dim fire_dir_save		= var17
  dim slowdown3			= var18
  dim scorevalue		= var19
  dim wizdeathspeak		= var20
  dim gotarrowsspeak	 	= var21
  dim arrowsgonespeak		= var22
  dim wizstartspeak		= var23
  dim arrowspeakflag		= var24
  dim nofireflag		= var25
  dim quadframe			= var26
  rem free			= var27
  dim menubarx			= var28
  dim menubary			= var29
  dim speedvalue		= var30
  dim levelvalue		= var31
  dim livesvalue		= var32
  dim arrowsvalue		= var33
  dim godvalue			= var34
  dim quiverplacement		= var35
  dim quiverflag		= var36
  dim quiverplaced		= var37
  dim arrowrand			= var38
  dim soundcounter		= var39
  dim gameoverflag		= var40
  dim freezeflag		= var41
  dim freeze			= var42
  dim freezecount		= var43
  dim enemy1deathflag		= var44
  dim enemy2deathflag		= var45
  dim enemy3deathflag		= var46
  dim spiderdeathflag		= var47
  dim slowdown_explode		= var49
  dim playerdeathflag		= var50
  dim deathframe		= var51
  dim slowdown_death		= var52
  dim tempx			= var53
  dim tempy			= var54
  dim tempdir			= var55
  dim obstacleseen		= var56
  dim monster1type		= var57
  dim monster2type		= var58
  dim monster3type		= var59
  dim monster1dir		= var60
  dim monster2dir		= var61
  dim monster3dir		= var62
  dim temploop			= var63
  dim temptype			= var64
  dim treasureindex		= var65
  dim spiderchangecountdown	= var66
  dim templogiccountdown	= var67
  dim spider_obstacleseen	= var69
  dim spider_spider1type	= var70
  dim spider_spider2type	= var71
  dim spider_spider3type	= var72
  dim spider_spider1dir		= var73
  dim spider_spider2dir		= var74
  dim spider_spider3dir		= var75
  dim bunkerhit			= var76
  dim godmodeon			= var78
  dim slowdown_2		= var79
  dim gamemode			= var80
  dim treasurespeak		= var81
  dim bat2_tempdir		= var82
  dim bat_bat1type		= var83
  dim bat_bat2type		= var84
  dim bat_bat1dir		= var85
  dim bat_bat2dir		= var86
  dim bat_obstacleseen		= var87
  dim bat2_obstacleseen		= var88
  dim godspeak			= var89
  dim devmodecount		= var90
  dim bat1deathflag		= var91
  dim bat2deathflag		= var92
  dim High_Score01		= var93
  dim High_Score02		= var94
  dim High_Score03		= var95
  dim Save_Score01		= var96
  dim Save_Score02		= var97
  dim Save_Score03		= var98
  dim savejoy			= var99
  dim objectblink      		= $268C
  dim livesbcdhi       		= $268D
  dim livesbcdlo       		= $268E
  dim altframe         		= $268F
  dim score0bcd0       		= $2690
  dim score0bcd1       		= $2691
  dim score0bcd2       		= $2692
  dim score0bcd3       		= $2693
  dim score0bcd4       		= $2694
  dim score0bcd5       		= $2695
  dim levelvaluebcdhi  		= $2696
  dim levelvaluebcdlo  		= $2697
  dim bat1respawn      		= $2698
  dim bat2respawn      		= $2699
  dim spiderrespawn    		= $269A
  dim treasurex        		= $269B
  dim treasurey        		= $269C
  dim treasurespawn    		= $269D
  dim treasureplaced   		= $269E
  dim treasure_rplace  		= $269F
  dim treasure_rplace2 		= $26A0
  dim treasurepickup   		= $26A1
  dim monster1health     	= $26A2
  dim monster2health     	= $26A3
  dim monster3health     	= $26A4
  dim r1x_fire         		= $26A5
  dim r2x_fire         		= $26A6
  dim r3x_fire         		= $26A7
  dim r1y_fire         		= $26A8
  dim r2y_fire         		= $26A9
  dim r3y_fire         		= $26AA
  dim r1x_temp0        		= $26AB
  dim r1y_temp0        		= $26AC
  dim r1_tempchar0     		= $26AD
  dim r1_arrowspeed   		= $26AE
  dim r1_fire_dir      		= $26AF
  dim r2_fire_dir      		= $26B0
  dim r3_fire_dir      		= $26B1
  dim tempanim         		= $26B2
  dim tempexplode      		= $26B3
  dim swordx           		= $26B4
  dim swordy           		= $26B5
  dim swordspawn       		= $26B6
  dim swordplaced      		= $26B7
  dim sword_rplace     		= $26B8
  dim sword_rplace2    		= $26B9
  dim swordpickup      		= $26BA
  dim invincibleflag   		= $26BB
  dim invincible_counter1	= $26BC
  dim invincible_counter2	= $26BD
  dim invincible_on    		= $26BE
  dim bunkerbuster     		= $26BF
  dim extralife_counter		= $26C0
  dim explodeframe1    		= $26C1
  dim explodeframe2    		= $26C2
  dim explodeframe3    		= $26C3
  dim tempexplodeframe 		= $26C4
  dim newfire1         		= $26C5
  dim newfire2         		= $26C6
  dim newfire3         		= $26C7
  dim spiderdeathframe 		= $26C8
  dim slowdown_spider  		= $26C9
  dim slowdown_bat1    		= $26CA
  dim slowdown_bat2    		= $26CB
  dim bat1deathframe   		= $26CC
  dim bat2deathframe   		= $26CD
  dim playerinvisibletime	= $26CE
  dim monster1changecountdown	= $26CF
  dim monster2changecountdown	= $26D0
  dim monster3changecountdown	= $26D1
  dim olddir           		= $26D2
  dim explosioncolor   		= $26D3
  dim explosionflash   		= $26D4
  dim copyright        		= $26D5
  dim copyrightcolor   		= $26D6
  dim present          		= $26D7
  dim presentcolor     		= $26D8
  dim monster1_shieldflag	= $26D9
  dim monster2_shieldflag	= $26DA
  dim monster3_shieldflag	= $26DB
  dim monster4_shieldflag	= $26DC
  dim monster5_shieldflag	= $26DD
  dim monster6_shieldflag	= $26DE
  dim r1hp             		= $26DF
  dim r2hp             		= $26E0
  dim r3hp             		= $26E1
  dim colorvalue       		= $26E2
  dim backcolorvalue   		= $26E3
  dim colorflasher     		= $26E4
  dim bat1changecountdown	= $26E5
  dim bat2changecountdown	= $26E6
  dim seecollision     		= $26E7
  dim temppositionadjust	= $26E8
  dim deathspeak       		= $26E9
  dim monst1slow        	= $26EA
  dim monst2slow        	= $26EB
  dim monst3slow        	= $26EC
  dim bat1slow         		= $26ED
  dim bat2slow         		= $26EE
  dim spiderslow       		= $26EF
  dim reloop           		= $26F0
  dim lastflash        		= $26F1
  dim noteindex        		= $26F2
  dim demomode         		= $26F3
  dim demomodecountdown		= $26F4
  dim fireheld         		= $26F5
  dim demodir          		= $26F6
  dim demochangetimer  		= $26F7
  dim treasuretimer    		= $26F8
  dim treasuretimer2   		= $26F9
  dim bunkerspeak      		= $26FA
  dim bunkerspeakflag  		= $26FB
  dim bunkertimer      		= $26FC
  dim level1flag       		= $26FD
  dim level2flag       		= $26FE
  dim level3flag       		= $26FF
  dim level4flag		= $2700
  dim level5flag		= $2701
  dim skill			= $2702
  dim score2flag		= $2703
  dim score3flag		= $2704
  dim score4flag		= $2705
  dim score5flag		= $2706
  dim fadeluma			= $2707
  dim fadeindex			= $2708
  dim level1spawnflag		= $2709
  dim level2spawnflag		= $270A
  dim level3spawnflag		= $270B
  dim level4spawnflag		= $270C
  dim level5spawnflag		= $270D
  dim value1flag		= $270E
  dim value2flag		= $270F
  dim value3flag		= $2710
  dim value4flag		= $2711
  dim value5flag		= $2712
  dim treasurep			= $2713
  dim spiderwebcountdown	= $2714
  dim spiderwalkingsteps	= $2715
  dim wizmode			= $2716
  dim wizmodeover		= $2717
  dim foregroundcolor		= $2718
  dim wizwarpcountdown		= $2719
  dim wizanimationframe		= $271A
  dim wizlogiccountdown		= $271B
  dim wizdeathflag		= $271C
  dim wiztempx			= $271D
  dim wiztempy			= $271E
  dim temprand                  = $271F
  dim devmodeenabled		= $2720
  dim colorchange               = $2721

  dim SBACKGRND			= $20

  rem *** last memory location available is $27FF

  rem ** Match Wizard coordinates to first monster
  dim wizx=monster1x
  dim wizy=monster1y
  dim wizdir=monster1dir
  dim wizfirex=r1x_fire
  dim wizfirey=r1y_fire

  rem ** Set up score variables
  dim sc1=score0
  dim sc2=score0+1
  dim sc3=score0+2
  dim sc4=score1
  dim sc5=score1+1
  dim sc6=score1+2

  rem ** some constants we use to find character values (for the mini-web that the spider creates)
  const spw1=<miniwebtop
  const spw2=spw1+1
  const spw3=spw1+2
  const spw4=spw1+3

  rem ** Set default game options
  arrowsvalue=8		:rem ** start with 8 arrows
  speedvalue=1		:rem ** start at normal speed (speed=0 is a dev mode option)
  levelvalue=1		:rem ** start at level 1
  livesvalue=6		:rem ** start with 6 lives
  godvalue=1		:rem ** start with god mode turned off
  colorvalue=1		:rem ** start with default colors (hold pause at start to reverse colors)
  gamemode=0		:rem ** start with default game mode
  gamedifficulty=1	:rem ** start with default difficulty level (standard)
  scorevalue=1		:rem ** start with default score value
  skill=2		:rem ** start with default skill level (2)
  colorchange=0		:rem ** start with default colors (hold pause at start to reverse colors)
  pausedisable=1 	:rem ** start with pausedisable set

  rem ** Set up characters and clear screen
  characterset atascii
  alphachars ASCII
  clearscreen

  rem ** Draw wait
  rem ** The drawscreen command completes near the beginning of the visible display. This is done intentionally, 
  rem ** to allow your program to have the maximum amount of CPU time possible.
  rem ** You may occasionally have code that you don't want to execute during the visible screen. For these 
  rem ** occasions you can call the drawwait command. This command will only return after the visible screen has 
  rem ** been completely displayed.
  drawwait

  rem ** Set up variables for text intro screens (prior to titlescreen)
  copyright=80
  copyrightcolor=5
  fadeindex=0
  fadeluma=0
  P0C2=0
  P3C2=$94 
  P4C2=$36 
  SBACKGRND=$00

  rem ** Display Introduction screen with AtariAge logo and copypright information

  rem ** Display '(C) 2015' on screen, text fades in and fades out
date
  rem ** if you hold down pause when the game begins, it reverts to the original color scheme.
  rem ** (colored background with black maze, rather than black background with colored maze)
  if switchpause then colorchange=1
  clearscreen
  fadeindex=fadeindex+1
  if fadeindex<127 then fadeluma=fadeindex/8
  if fadeindex>136 then fadeluma=32-(fadeindex/8)
  P0C2=fadeluma
  if fadeindex=81 then playsfx copyrightsfx
  rem ** Display AtariAge logo on the screen
  plotchars '* 2015' 0 68 11
  plotsprite aa_left_1 3 50 32
  plotsprite aa_left_2 3 50 40
  plotsprite aa_left_3 3 50 48
  plotsprite aa_left_4 3 50 56
  plotsprite aa_right_1 4 90 32
  plotsprite aa_right_2 4 90 40
  plotsprite aa_right_3 4 90 48
  plotsprite aa_right_4 4 90 56
  drawscreen
  if joy0fire then playsfx sfx_menumove2:goto titlescreen
  if fadeindex>0 then goto date

  rem ** Display names on screen, text fades in and fades out
copyright
  clearscreen
  fadeindex=fadeindex+1
  if fadeindex<127 then fadeluma=fadeindex/8
  if fadeindex>136 then fadeluma=32-(fadeindex/8)
  P0C2=fadeluma
  if fadeindex=81 then playsfx copyrightsfx
  plotchars 'Steve Engelhardt' 0 50 9
  plotchars '&' 0 80 11
  plotchars 'Mike Saarna' 0 60 13
  rem ** Display AtariAge logo on the screen
  plotsprite aa_left_1 3 50 32
  plotsprite aa_left_2 3 50 40
  plotsprite aa_left_3 3 50 48
  plotsprite aa_left_4 3 50 56
  plotsprite aa_right_1 4 90 32
  plotsprite aa_right_2 4 90 40
  plotsprite aa_right_3 4 90 48
  plotsprite aa_right_4 4 90 56
  drawscreen
  if joy0fire then playsfx sfx_menumove2:goto titlescreen
  if fadeindex>0 then goto copyright

  rem ** Display 'Present...' on screen, text fades in and fades out
present
  clearscreen
  fadeindex=fadeindex+1
  if fadeindex<127 then fadeluma=fadeindex/8
  if fadeindex>136 then fadeluma=32-(fadeindex/8)
  P0C2=fadeluma
  if fadeindex=81 then playsfx copyrightsfx
  plotchars 'Present...' 0 60 11
  rem ** Display AtariAge logo on the screen
  plotsprite aa_left_1 3 50 32
  plotsprite aa_left_2 3 50 40
  plotsprite aa_left_3 3 50 48
  plotsprite aa_left_4 3 50 56
  plotsprite aa_right_1 4 90 32
  plotsprite aa_right_2 4 90 40
  plotsprite aa_right_3 4 90 48
  plotsprite aa_right_4 4 90 56
  drawscreen
  if joy0fire then playsfx sfx_menumove2:goto titlescreen

  if fadeindex>0 then goto present
  playsfx sfx_menumove2 
  goto titlescreen

treasurespeak
  if demomode=1 then return
  rem ** speech texts for picking up treasure are: gold, money, and jackpot
  rem ** yes, it is more likely that 'jackpot' will be spoken. I like that one.
  treasurespeak=rand&3
  on treasurespeak goto spkt0 spkt1 spkt2 spkt3
spkt0
  speak gold:return
spkt1
  speak money:return
spkt2
spkt3
  speak jackpot:return

deathspeak
  if demomode=1 then return
  rem ** speech texts for player death are: death, mylifeisover, destroyed, terminated, yougotme, beaten
  deathspeak=rand&7
  on deathspeak goto spkd0 spkd1 spkd2 spkd3 spkd4 spkd6 spkd6 spkd7
spkd0
  speak death:return
spkd1
  speak mylifeisover:return
spkd2
  speak destroyed:return
spkd3
spkd4
  speak terminated:return
spkd5
  speak yougotme:return
spkd6
  speak beaten:return
spkd7
  speak death:return

godspeak
  if demomode=1 then return
  rem ** speech texts for picking up the sword are: nofear, bringiton, cantstopme, iamgod
  godspeak=rand&3
  on godspeak goto spkg0 spkg1 spkg2 spkg3
spkg0
  speak nofear:return
spkg1
  speak bringiton:return
spkg2
  speak cantstopme:return
spkg3
  speak iamgod:return

wizstartspeak
  if demomode=1 then return
  rem ** speech texts for the Wizard are: Ha Ha Ha and Watch Out
  wizstartspeak=rand&3
  on wizstartspeak goto spkv0 spkv1 spkv2 spkv3
spkv0
spkv1
  speak hahaha:return
spkv2
spkv3
  speak watchout:return

wizdeathspeak
  if demomode=1 then return
  rem ** speech texts for killing the wizard are: Wizard Defeated, Victory, Wizard is dead, Wizard destroyed, Got him
  wizdeathspeak=rand&7
  on wizdeathspeak goto spkx0 spkx1 spkx2 spkx3 spkx4 spkx6 spkx6 spkx7
spkx0
spkx1
  speak wizdestroyed:return
spkx2
spkx3
  speak victory:return
spkx4
spkx5
  speak wizdead:return
spkx6
  speak wizdefeated:return
spkx7
  speak gothim:return

arrowsgonespeak
  if demomode=1 then return
  rem ** speech texts for running out of arrows are: Ammo Gone, Arrows Gone, Out of Arrows, Out of Ammo
  arrowsgonespeak=rand&3
  on arrowsgonespeak goto spky0 spky1 spky2 spky3
spky0
  speak ammogone:return
spky1
  speak arrowsgone:return
spky2
  speak arrowsout:return
spky3
  speak ammoout:return

gotarrowsspeak
  if demomode=1 then return
  rem ** speech texts for picking up the quiver are: More Arrows, Filled Up, Ammo Recharged
  gotarrowsspeak=rand&3
  on gotarrowsspeak goto spkw0 spkw1 spkw2 spkw3
spkw0
spkw1
  speak morearrows:return
spkw2
  speak filledup:return
spkw3
  speak ammocharge:return

bunkerspeak
  rem ** we're not going to say "bunker damaged" in demo mode
  if demomode=1 then return
  rem ** speak 'Bunker Damaged' when you reach 37,500 points
  speak bunkerdamaged
  rem ** This is so we know the phrase has already been spoken once, and to not repeat it again
  bunkerspeakflag=1
  return

level2speak
  rem ** say "Level Up" on the atarivox when you've reached level 2
  speak levelup
  rem ** Flag is set so we know we're now on level 2
  rem ** This is to make sure the speech text isn't repeated more than once
  level2flag=1
  return

level3speak
  rem ** say "I have advanced" on the atarivox when you've reached level 3
  speak ihaveadvanced
  rem ** Flag is set so we know we're now on level 3
  rem ** This is to make sure the speech text isn't repeated more than once
  level3flag=1
  return

level4speak
  rem ** say "More Power" on the atarivox when you've reached level 4
  speak morepower
  rem ** Flag is set so we know we're now on level 4
  rem ** This is to make sure the speech text isn't repeated more than once
  level4flag=1
  return

level5speak
  rem ** say "I am stronger" on the atarivox when you've reached level 5
  speak iamstronger
  rem ** Flag is set so we know we're now on level 5
  rem ** This is to make sure the speech text isn't repeated more than once
  level5flag=1
  return

  rem ** Initialize game, prepare to start

init
  rem ** Init is where the game bounces back to from the titlescreen when you start the game

  rem ** reset flags for dev mode and wizard mode
  devmodecount=0:savejoy=0:devmodeenabled=0
  wizmodeover=0

  rem ** reset score to zero
  score0=000000

  rem ** set initial number of arrows to maximum set on titlescreen option
  rem ** reduce further based on level if needed
  arrowcounter=arrowsvalue

  rem ** Import Graphics
  rem ** ...211 unique sprite graphics were created for Dungeon Stalker!
  rem ** Syntax: incgraphic filename.png [graphics mode] [color #0] [#1] ... [palette #]

  rem ** the last digit is the default palette to use with plotmap
  rem ** these are the tile sets that make up the dungeon walls
  incgraphic tileset_NS_Maze1.png 320A 1 0 0
  incgraphic tileset_NS_Maze2.png 320A 1 0 0
  incgraphic tileset_NS_Maze3.png 320A 1 0 0
  incgraphic tileset_NS_Maze4.png 320A 1 0 0
  incgraphic blanks.png 320A 1 0 0

  rem ** characters for the alphabet and numbers
  incgraphic alphabet_8_wide.png 160A 0 1 2 
  incgraphic scoredigits_8_wide.png 320A 0 1 2 

  rem ** god mode sprite for the status bar
  incgraphic godmode.png 320A 1 0 2

  rem ** the mini spider webs that the spider spins throughout the dungeon
  incgraphic miniwebtop.png 320A 0 1 
  incgraphic miniwebbottom.png 320A 0 1

  rem ** the AtariAge Logo
  rem **  AtariAge Rocks!
  incgraphic aa_left_1.png 320A 0 1 2 
  incgraphic aa_left_2.png 320A 0 1 2 
  incgraphic aa_left_3.png 320A 0 1 2 
  incgraphic aa_left_4.png 320A 0 1 2 
  incgraphic aa_right_1.png 320A 0 1 2 
  incgraphic aa_right_2.png 320A 0 1 2 
  incgraphic aa_right_3.png 320A 0 1 2 
  incgraphic aa_right_4.png 320A 0 1 2 

  rem ** start a new graphics block
  rem ** animated graphics -must- be in the same graphics bank
  rem ** newblock forces a move to the next graphics bank
  newblock

  rem ** atascii characterset
  rem ** import the characterset, used in the titlescreen
  incgraphic atascii.png 320A 

  rem ** Main player graphic for the archer
  rem ** We used a zone height of 8, so sprites taller than 8 must be split
  rem ** Also, there are separate sprites for the archer facing left or right (no sprite flipping like the 2600)
  incgraphic archer_1_top_faceright.png 320A 0 1 2
  incgraphic archer_2_top_faceright.png 320A 0 1 2
  incgraphic archer_3_top_faceright.png 320A 0 1 2
  incgraphic archer_4_top_faceright.png 320A 0 1 2
  incgraphic archer_5_top_faceright.png 320A 0 1 2
  incgraphic archer_6_top_faceright.png 320A 0 1 2
  incgraphic archer_7_top_faceright.png 320A 0 1 2
  incgraphic archer_1_top_faceleft.png 320A 0 1 2
  incgraphic archer_2_top_faceleft.png 320A 0 1 2
  incgraphic archer_3_top_faceleft.png 320A 0 1 2
  incgraphic archer_4_top_faceleft.png 320A 0 1 2
  incgraphic archer_5_top_faceleft.png 320A 0 1 2
  incgraphic archer_6_top_faceleft.png 320A 0 1 2
  incgraphic archer_7_top_faceleft.png 320A 0 1 2
  incgraphic archer_1_bottom_faceright.png 320A 0 1 2
  incgraphic archer_2_bottom_faceright.png 320A 0 1 2
  incgraphic archer_3_bottom_faceright.png 320A 0 1 2
  incgraphic archer_4_bottom_faceright.png 320A 0 1 2
  incgraphic archer_5_bottom_faceright.png 320A 0 1 2
  incgraphic archer_6_bottom_faceright.png 320A 0 1 2
  incgraphic archer_7_bottom_faceright.png 320A 0 1 2
  incgraphic archer_1_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_2_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_3_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_4_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_5_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_6_bottom_faceleft.png 320A 0 1 2
  incgraphic archer_7_bottom_faceleft.png 320A 0 1 2

  rem ** Main player graphic death animation
  incgraphic archer_death_top1.png 320A 0 1 2
  incgraphic archer_death_top2.png 320A 0 1 2
  incgraphic archer_death_top3.png 320A 0 1 2
  incgraphic archer_death_top4.png 320A 0 1 2
  incgraphic archer_death_top5.png 320A 0 1 2
  incgraphic archer_death_top6.png 320A 0 1 2
  incgraphic archer_death_top7.png 320A 0 1 2
  incgraphic archer_death_top8.png 320A 0 1 2
  incgraphic archer_death_top9.png 320A 0 1 2
  incgraphic archer_death_top10.png 320A 0 1 2
  incgraphic archer_death_top11.png 320A 0 1 2
  incgraphic archer_death_top12.png 320A 0 1 2
  incgraphic archer_death_top13.png 320A 0 1 2
  incgraphic archer_death_top14.png 320A 0 1 2
  incgraphic archer_death_top15.png 320A 0 1 2
  incgraphic archer_death_top16.png 320A 0 1 2
  incgraphic archer_death_bottom1.png 320A 0 1 2
  incgraphic archer_death_bottom2.png 320A 0 1 2
  incgraphic archer_death_bottom3.png 320A 0 1 2
  incgraphic archer_death_bottom4.png 320A 0 1 2
  incgraphic archer_death_bottom5.png 320A 0 1 2
  incgraphic archer_death_bottom6.png 320A 0 1 2
  incgraphic archer_death_bottom7.png 320A 0 1 2
  incgraphic archer_death_bottom8.png 320A 0 1 2
  incgraphic archer_death_bottom9.png 320A 0 1 2
  incgraphic archer_death_bottom10.png 320A 0 1 2
  incgraphic archer_death_bottom11.png 320A 0 1 2
  incgraphic archer_death_bottom12.png 320A 0 1 2
  incgraphic archer_death_bottom13.png 320A 0 1 2
  incgraphic archer_death_bottom14.png 320A 0 1 2
  incgraphic archer_death_bottom15.png 320A 0 1 2
  incgraphic archer_death_bottom16.png 320A 0 1 2

  rem ** Explosion animation for all enemies
  incgraphic explode1top.png 320A 0 1 2
  incgraphic explode2top.png 320A 0 1 2
  incgraphic explode3top.png 320A 0 1 2
  incgraphic explode4top.png 320A 0 1 2
  incgraphic explode5top.png 320A 0 1 2
  incgraphic explode6top.png 320A 0 1 2
  incgraphic explode7top.png 320A 0 1 2
  incgraphic explode8top.png 320A 0 1 2
  incgraphic explode1bottom.png 320A 0 1 2
  incgraphic explode2bottom.png 320A 0 1 2
  incgraphic explode3bottom.png 320A 0 1 2
  incgraphic explode4bottom.png 320A 0 1 2
  incgraphic explode5bottom.png 320A 0 1 2
  incgraphic explode6bottom.png 320A 0 1 2
  incgraphic explode7bottom.png 320A 0 1 2
  incgraphic explode8bottom.png 320A 0 1 2

  rem ** Main player graphic for freezing
  incgraphic archer_still_top.png 320A 0 1 2
  incgraphic archer_still_top_reverse.png 320A 1 0 2
  incgraphic archer_still_bottom.png 320A 0 1 2
  incgraphic archer_still_bottom_reverse.png 320A 1 0 2

  rem ** bat 1
  incgraphic bat1.png 320A 0 1 2
  incgraphic bat2.png 320A 0 1 2
  incgraphic bat3.png 320A 0 1 2

  rem ** bat 2
  incgraphic bat4.png 320A 0 1 2
  incgraphic bat5.png 320A 0 1 2
  incgraphic bat6.png 320A 0 1 2

  rem ** bat explode frames
  incgraphic bat_explode1.png 320A 0 1 2
  incgraphic bat_explode2.png 320A 0 1 2
  incgraphic bat_explode3.png 320A 0 1 2
  incgraphic bat_explode4.png 320A 0 1 2

  rem ** Quiver
  incgraphic quiver1.png 320A 0 1 2
  incgraphic quiver2.png 320A 0 1 2

  rem ** monster 1 (8x16, stitched together)
  rem ** Demon Bat
  incgraphic monster1top.png 320A 1 0 2
  incgraphic monster2top.png 320A 1 0 2
  incgraphic monster1bottom.png 320A 1 0 2
  incgraphic monster2bottom.png 320A 1 0 2

  rem ** monster 2 (8x16, stitched together)
  rem ** Snake
  incgraphic monster3top.png 320A 1 0 2
  incgraphic monster4top.png 320A 1 0 2
  incgraphic monster3bottom.png 320A 1 0 2
  incgraphic monster4bottom.png 320A 1 0 2

  rem ** monster 3 (8x16, stitched together)
  rem ** Skeleton Warrior
  incgraphic monster5top.png 320A 0 1 2
  incgraphic monster6top.png 320A 0 1 2
  incgraphic monster5bottom.png 320A 0 1 2
  incgraphic monster6bottom.png 320A 0 1 2

  rem ** spider
  incgraphic spd1top.png 320A 0 1 2
  incgraphic spd2top.png 320A 0 1 2
  incgraphic spd3top.png 320A 0 1 2
  incgraphic spd4top.png 320A 0 1 2
  incgraphic spd1bot.png 320A 0 1 2
  incgraphic spd2bot.png 320A 0 1 2
  incgraphic spd3bot.png 320A 0 1 2
  incgraphic spd4bot.png 320A 0 1 2

  rem ** status bar items
  incgraphic lives.png 320A 0 1 2
  incgraphic level.png 320A 0 1 2
  incgraphic score.png 320A 0 1 2
  incgraphic arrows.png 320A 0 1 2
  incgraphic man.png 320A 0 1 2
  incgraphic blackbox.png 320A 0 1 2
  incgraphic level1.png 320A 0 1 2
  incgraphic level2.png 320A 0 1 2
  incgraphic level3.png 320A 0 1 2
  incgraphic level4.png 320A 0 1 2
  incgraphic level5.png 320A 0 1 2
  incgraphic level6.png 320A 0 1 2
  incgraphic level7.png 320A 0 1 2
  incgraphic level8.png 320A 0 1 2
  incgraphic level9.png 320A 0 1 2

  rem ** game over text
  incgraphic gameovertext.png 320A 0 1 2

  rem ** arrow fired from archer's bow
  incgraphic arrow.png 320A 1 0 2
  incgraphic arrow2.png 320A 1 0 2
  incgraphic arrow_large.png 320A 1 0 2

  rem ** used for center bunker
  incgraphic widebar_top_broken.png 320A 0 1 2
  incgraphic widebar.png 320A 0 1 2
  incgraphic widebar_top.png 320A 0 1 2
  incgraphic widebar_bottom.png 320A 0 1 2

  rem ** titlescreen graphic (256x128)
  incbanner tsbanner.png 320A 1 0 2

  rem ** spider web at top left of screen
  incgraphic web1.png 320A 1 0 2
  incgraphic web2.png 320A 1 0 2
  incgraphic web3.png 320A 1 0 2
  incgraphic web4.png 320A 1 0 2
  incgraphic web5.png 320A 1 0 2
  incgraphic web6.png 320A 1 0 2
  incgraphic web7.png 320A 1 0 2
  incgraphic web8.png 320A 1 0 2

  rem ** spider death animation
  incgraphic spider1top_explode1.png 320A 0 1 2
  incgraphic spider1top_explode2.png 320A 0 1 2
  incgraphic spider1top_explode3.png 320A 0 1 2
  incgraphic spider1top_explode4.png 320A 0 1 2
  incgraphic spider1top_explode5.png 320A 0 1 2
  incgraphic spider1bottom_explode1.png 320A 0 1 2
  incgraphic spider1bottom_explode2.png 320A 0 1 2
  incgraphic spider1bottom_explode3.png 320A 0 1 2
  incgraphic spider1bottom_explode4.png 320A 0 1 2
  incgraphic spider1bottom_explode5.png 320A 0 1 2

  rem ** arrow indicator on status bar
  incgraphic arrowbar0.png 320A 0 1 2
  incgraphic arrowbar1.png 320A 0 1 2
  incgraphic arrowbar2.png 320A 0 1 2
  incgraphic arrowbar3.png 320A 0 1 2
  incgraphic arrowbar4.png 320A 0 1 2
  incgraphic arrowbar5.png 320A 0 1 2
  incgraphic arrowbar6.png 320A 0 1 2
  incgraphic arrowbar7.png 320A 0 1 2
  incgraphic arrowbar8.png 320A 0 1 2
  incgraphic arrowbar_nolimit.png 320A 1 0 2

  rem ** backround for titlescreen graphic
  incgraphic ts_back1.png 320A 0 1 2
  incgraphic ts_back2.png 320A 0 1 2
  incgraphic ts_back3.png 320A 0 1 2
  incgraphic ts_back4.png 320A 0 1 2
  incgraphic ts_back5.png 320A 0 1 2
  incgraphic ts_back6.png 320A 0 1 2
  incgraphic ts_back7.png 320A 0 1 2

  rem ** sprites for wizard
  incgraphic wizlefttop1.png 320A 0 1 2
  incgraphic wizlefttop2.png 320A 0 1 2
  incgraphic wizrighttop1.png 320A 0 1 2
  incgraphic wizrighttop2.png 320A 0 1 2
  incgraphic wizleftbottom1.png 320A 0 1 2
  incgraphic wizleftbottom2.png 320A 0 1 2
  incgraphic wizrightbottom1.png 320A 0 1 2
  incgraphic wizrightbottom2.png 320A 0 1 2

  rem ** sprite for high score font
  incgraphic hiscorefont.png 320A

  rem ** flashing gems in titlescreen graphic
  incgraphic ts_back_ruby.png 320A 0 1 2

  rem ** the text highlighter in the menu options list
  incgraphic menuback1.png 320A 0 1 2

  rem ** the treasure sprite
  incgraphic treasure.png 320A 0 1 2

  rem ** the sword sprite
  incgraphic swordtop.png 320A 0 1 2
  incgraphic swordbottom.png 320A 0 1 2

  rem ** 'demo mode' text sprite
  incgraphic demomodetext.png 320A 0 1 2

  rem ** 'developer mode' text sprite
  incgraphic devmode.png 320A 1 0 2

  rem ** import character set
  characterset alphabet_8_wide

  rem ** Map screen generated from 'Tiled' application
  incmapfile Dungeon.tmx
 
  rem ** we need to let the 7800 know where the character set is
  characterset blanks

  rem ** copy a screen to our screen ram
  rem ** to allow for collision detection
  screen=0
  gosub newscreen

  rem ** setup the screen memory for rendering the screen ram.
  rem ** "Dungeon.tmx" should work with any map, so long as
  rem ** all tmx files use the same palettes in the same area.
  rem ** If that's not true, the "newscreen" subroutine should
  rem ** be updated with conditional logic to plotmapfile with
  rem ** the right tmx file.

  rem ** This command erases all sprites and characters that you've previously
  rem **  drawn on the screen, so you can draw the next screen
  clearscreen
  
  rem ** plot the screen map
  rem ** ...Syntax: plotmapfile mapfile.tmx mapdata x y width height
  plotmapfile Dungeon.tmx screenram 0 0 40 26

  rem ** plot stuff that doesn't change
  rem ** this is to save cycles, they don't need to be plotted every frame in the main loop
  rem ** ...plotsprite syntax: plotsprite sprite_graphic palette_# x y [frame]
  plotsprite score 2 64 208
  plotsprite lives 2 3 208
  plotsprite level 2 33 208
  plotsprite arrows 2 112 208
  plotsprite widebar 2 76 88
  plotsprite widebar 2 76 96
  plotsprite widebar_bottom 2 76 104

  rem ** plot the spider web in the top left
  rem ** ...this also doesn't change throughout the game
  plotsprite web1 0 0 8
  plotsprite web2 0 0 16
  plotsprite web3 0 0 24
  plotsprite web4 0 0 32
  plotsprite web5 0 0 40
  plotsprite web6 0 0 48
  plotsprite web7 0 0 56
  plotsprite web8 0 0 64

  rem ** we bake a string-like version of level value into the screen
  rem ** this saves cycles we'd waste plotting it every frame
  rem ** ...plotchars syntax: plotchars textdata palette_# x y [number_of_chars | extrawide]
  plotchars levelvaluebcdhi 6 51 26 2

  rem ** we bake in the score too
  plotchars score0bcd0 6 82 26 6

  rem ** bake in the life counter too
  plotchars livesbcdhi 6 20 26 2

  rem ** You may occasionally have code that you don't want to execute during the visible screen. 
  rem ** For these occasions you can call the drawwait command. This command will only return after 
  rem ** the visible screen has been completely displayed.
  drawwait

  rem ** set our color palettes based on automatic png->7800 color conversion
  rem ** ...as we're using 320A mode, the sprites are limited to a single color
  rem ** ...you can view a table of all the colors used in a graphic file included with the source distribution
 
  rem ** Black (Bats & web & maze & wizard)
  P0C1=0
  P0C2=0
  P0C3=0

  rem ** Green (color for enemies after they've lost one hitpoint)
  P1C1=0
  P1C2=$D6
  P1C3=0

  rem ** dark grey (Center Bunker and arrows)
  P2C1=0
  P2C2=$06
  P2C3=0

  rem ** Snake Starting color (blue)
  P3C1=0
  P3C2=$A8
  P3C3=0

  rem ** Purple (Spider)
  P4C1=0
  P4C2=$66
  P4C3=0

  rem ** Skeleton Warrior starting color (light blue) and Treasure starting color
  P5C1=0
  P5C2=$78
  P5C3=0

  rem ** Brown (Status Bar Numbers & Arrow Indicator)
  P6C1=0
  P6C2=$F6
  P6C3=0

  rem ** Orange (Player)
  P7C1=0
  P7C2=$26
  P7C3=0
 
  rem **  The savescreen command saves any sprites and characters that you've 
  rem **  drawn on the screen since the last clearscreen. The restorescreen erases 
  rem **  any sprites and characters that you've drawn on the screen since
  rem **  the last savescreen.
  savescreen

  rem ** background color
  rem ** the background color is reversable.  Holding down the pause button when you start up
  rem ** the game will reverse the colors of the background and the dungeon
  if colorchange=0 then SBACKGRND=levelcolors[levelvalue]
  if colorchange=1 then SBACKGRND=0

  rem ** set life counter to the lives value from the menu
  rem ** it's changeable if developer mode is activated
  lifecounter=livesvalue

  rem ** Set starting locations of the sprites
  rem ** ...you can view all of the respawn locations in a file included with the source distribution

  rem ** Set initial location of player
  rem ** ...right in the middle of the bunker
  rem 84x 80y
  p0_x=84
  p0_y=68

  rem ** Set initial location of bat 1
  bat1x=133
  bat1y=48

  rem ** Set initial location of bat 2
  bat2x=22
  bat2y=90

  rem ** Set initial location of quiver
  quiverx=135
  quivery=140

  rem ** Set initial location of spider
  spiderx=8
  spidery=35

  rem ** Set initial HP for each enemy
  r1hp=1
  r2hp=1
  r3hp=1 

  rem ** set initial location of treasure to offscreen
  treasurex=200
  treasurey=200

  rem ** set initial location of sword to offscreen
  swordx=200
  swordy=200

  rem ** set initial values for firing quiver to offscreen
  xpos_fire=200

  rem ** set initial firing direction to up
  fire_dir_save=1
  fire_dir=1: rem set initial fire direction to up

  rem ** quiver powerup is not onscreen when game starts
  quiverflag=0

  rem ** set initial bunker fire blocking ability to on
  bunkerbuster=0

  rem ** set extra life counter to 0 
  rem ** after collecting 5 treasures you get an extra life and this counter is reset
  extralife_counter=0

  rem ** initially place enemy arrows offscreen
  r1x_fire=200
  r2x_fire=200
  r3x_fire=200

  rem ** initially, the sword is offscreen, the invicibility counter is set to 0,
  rem ** the invicibility flag is set to 0 (off), the flag for placing the treasure
  rem ** is set to 0 (off)
  sword_rplace=0
  sword_rplace2=0
  invincible_counter1=0
  invincible_counter2=0
  invincible_on=0
  treasureplaced=0
  swordplaced=0
  explosionflash=1

  rem ** resets counters for how long treasure will stay on-screen
  rem ** the treasure stays onscreen for approximately 12 seconds before it disappears 
  rem ** and the counter is reset again
  treasuretimer=0
  treasuretimer2=0

  rem ** set initial location of enemies to offscreen
  monster1x=0:monster2x=0:monster3x=0

  rem ** reset counter that controls how often the spider spins a small web
  spiderwebcountdown=0

  rem ** reset speech flags
  bunkerspeakflag=0
  arrowspeakflag=0

  rem ** Set level flags for initial enemy spawning on a level change
  rem ** this was implemented to prevent an enemy from spawning directly on top of you
  value1flag=0: value2flag=0: value3flag=0: value4flag=0: value5flag=0

  rem ** Wizard modes starts turned off
  rem ** the wizard appears in-between levels, and never appears again after you've reached level 5
  wizmode=0

  rem ** if skill=0 you've selected a specific level from developer mode. Skip the section immediately after.
  if scorevalue=1 && skill=0 then sc1=$00:sc2=$00:sc3=$00:goto main
  if scorevalue=2 && skill=0 then sc1=$00:sc2=$74:sc3=$00:goto main
  if scorevalue=3 && skill=0 then sc1=$01:sc2=$49:sc3=$00:goto main
  if scorevalue=4 && skill=0 then sc1=$02:sc2=$99:sc3=$00:goto main
  if scorevalue=5 && skill=0 then sc1=$05:sc2=$99:sc3=$00:goto main

  rem ** scorevalue is a developer mode option that lets you pick a score value just under the requirement
  rem ** to move up to the next level.  This was implemented for testing wizard mode.
  if scorevalue=1 then sc1=$00:sc2=$00:sc3=$00:levelvalue=1
  if scorevalue=2 then sc1=$00:sc2=$74:sc3=$00:levelvalue=1
  if scorevalue=3 then sc1=$01:sc2=$49:sc3=$00:levelvalue=2
  if scorevalue=4 then sc1=$02:sc2=$99:sc3=$00:levelvalue=3
  if scorevalue=5 then sc1=$05:sc2=$99:sc3=$00:levelvalue=4

  rem ** you start on level 2 in advanced, level 3 in Expert
  if skill=3 then levelvalue=2
  if skill=4 then levelvalue=3

  rem ** Begin main game loop

main 

  rem *******************************************************************************************
  rem ************ Section 1: Game Logic... don't use plot* or *screen commands here ************
  rem *******************************************************************************************

  rem ** play the wiz theme if we've just entered wizmode and the invincibility song isn't playing...
  temp1=framecounter&7
  if wizmode=200 && temp1=0 && wizwarpcountdown<200 && wizwarpcountdown>10 && invincible_on=0 then tempx=(framecounter/16)&7:tempy=wizmodenotes[tempx]:playsfx sfx_wiz tempy

  rem ** wizard mode audio data
  rem ** the heartbeat sound is silenced for a unique tune when the wizard is active on the screen
  data wizmodenotes
  16,14,12,10,12,14,12,10,8
end

  rem ** uncomment this to increase your score by holding down the select button
  rem ** this was used for debugging and testing and was commented out for released versions of the game
  rem if switchselect then score0=score0+20

  rem ** this code plays the 'beep' sound effect when you press the fire button and you're out of arrows
  if arrowcounter=0 && !joy0fire && nofireflag<>1 then nofireflag=1 
  if nofireflag=1 && joy0fire && arrowcounter=0 then nofireflag=2:playsfx sfx_nofire

  rem ** WITCHCRAFT AHEAD...
  rem ** To avoid using plotvalue every frame, we instead plot 2 bytes of memory with plotchars
  rem ** with the rest of the level graphics, prior to savescreen. The code below points those
  rem ** 2 bytes of memory at the characterset characters representing the current level value...
  const digitstart=<scoredigits_8_wide
  levelvaluebcdhi=digitstart
  levelvaluebcdlo=levelvalue+digitstart

  rem ** Wizard Mode code
  rem **     ...We're off to see the wizard! The wonderful wizard of.... oh, nevermind.
  rem **     ...the wizard appears in-between levels

  rem ** the wizmode is over. Respawn the monsters...
  if wizmodeover=199 then gosub monster1respawn:gosub monster2respawn:gosub monster3respawn:gosub spiderrespawn:gosub bat1respawn:gosub bat2respawn
  if wizmode>0 && wizmode<200 then r1x_fire=200:r2x_fire=200:r3x_fire=200
  if wizmodeover>0 then r1x_fire=200:r2x_fire=200:r3x_fire=200
  if wizmode=0 || wizmode=200 then goto skipwizmodeshift

    rem ** wizmode is starting...
    rem ** change color scheme based on whether or not pause was pressed when the game was started (colorchange variable)
    rem ** wizmode colors swap the background color with the foreground color
    if wizmode=90 && colorchange=0 then P0C2=0
    if wizmode=90 && colorchange=1 then SBACKGRND=0
    if wizmode=150 && colorchange=0 then SBACKGRND=levelcolors[levelvalue]
    if wizmode=150 && colorchange=1 then P0C2=levelcolors[levelvalue]
    wizmode=wizmode+1
skipwizmodeshift

    rem ** wizmode is ending...
    rem ** change color scheme based on whether or not pause was pressed when the game was started (colorchange variable)
    rem ** wizmode colors swap the background color with the foreground color
  if wizmodeover=0 then goto skipwizmodeovershift
    if wizmodeover=90 && colorchange=0 then SBACKGRND=0
    if wizmodeover=90 && colorchange=1 then P0C2=0
    if wizmodeover=150 && colorchange=0 then P0C2=levelcolors[levelvalue]
    if wizmodeover=150 && colorchange=1 then SBACKGRND=levelcolors[levelvalue]
    wizmodeover=wizmodeover+1
    if wizmodeover=200 then wizmode=0:wizmodeover=0
skipwizmodeovershift

    rem ** if we're in wizmode, determine which way the wizard is facing...
    if wizmode<200 then goto skipwizmodeanimation
    rem ** first check if he's facing left or right... he always faces the player
    rem ** "up left down right"
    if wizdir=1 then wizanimationframe=0
    if wizdir=3 then wizanimationframe=2
    rem ** then periodically use the alternate animation frame
    if (frame&8)=0 then wizanimationframe=wizanimationframe|1 else wizanimationframe=wizanimationframe&%11111110
skipwizmodeanimation

    rem ** if we're in wizmode, make the wizard periodically warp...
    if wizmode<200 then skipmorewizlogic 
    if wizmodeover>0 then skipmorewizlogic 
    if wizwarpcountdown>0 && wizmodeover=0 then wizwarpcountdown=wizwarpcountdown-1:if wizwarpcountdown=0 then gosub warpwizard
    if wizwarpcountdown<200 then gosub wizlogic :goto skipmorewizlogic
    temploop=0:gosub skip_r1fire
skipmorewizlogic

  rem ** have the wizard speak right after the intro tune ends
  rem **   ...it didn't sound very good when they played at the same time
  if wizmode=199 then gosub wizstartspeak
 
  rem ** skip demo mode countdown if you're playing the actual game
  rem ** if demomode=0, you're playing the game (and really enjoying yourself!)
  if demomode=0 then goto skipdemoreturn
  temp8=frame&63
  if temp8=0 then demomodecountdown=demomodecountdown-1
  if demomodecountdown=0 then demomode=1:demomodecountdown=5:goto titlescreen
skipdemoreturn

  rem ** to prevent gameover flag from being set in demo mode
  if demomode=1 then gameoverflag=0

  rem ** this makes the enemy explosion flash
  rem ** ran out of colors for the bloody red explosion that was wanted, making it flash was a compromise
  explosioncolor=explosionflash
  explosionflash=explosionflash+1
  if explosionflash=8 then explosionflash=1

  rem ** well, reboot if you hit reset...
  rem **        ...oh, and kill the audio too
  if switchreset then AUDV0=0:AUDV1=0:reboot

  rem ** explode any onscreen enemies at the start of wizmode. no extra points are awarded. you didn't earn it!
  if wizmode<>2 then skipexplodingallenemies
  if monster1type<255 && enemy1deathflag=0 then enemy1deathflag=1:explodeframe1=0
  if monster2type<255 && enemy2deathflag=0 then enemy2deathflag=1:explodeframe2=0
  if monster3type<255 && enemy3deathflag=0 then enemy3deathflag=1:explodeframe3=0
  if spiderdeathflag=0 then spiderdeathflag=1:spiderdeathframe=0
  if levelvalue<4 && bat2deathflag=0 then bat2deathflag=1:bat2deathframe=0
  if levelvalue<3 && bat1deathflag=0 then bat1deathflag=1:bat1deathframe=0
skipexplodingallenemies
  
  rem ** Set level flags for initial enemy spawning on a level change, and reset offscreen enemies to x=0
  if levelvalue=1 && value1flag=0 then level1spawnflag=1: value1flag=1: monster2x=0: monster3x=0
  if levelvalue=2 && value2flag=0 then level2spawnflag=1: value2flag=1: monster1x=0: monster3x=0
  if levelvalue=3 && value3flag=0 then level3spawnflag=1: value3flag=1: monster3x=0
  if levelvalue=4 && value4flag=0 then level4spawnflag=1: value4flag=1: monster1x=0
  if levelvalue=5 && value5flag=0 then level5spawnflag=1: value5flag=1

  rem ** below adds the snake to demo mode but disables the skeleton warrior
  rem ** demo mode has two enemies on the blue level 1 screen, which doesn't happen when you actually play
  if demomode=1 then monster1type=1:monster2type=3:monster3type=255:goto demoskip1

  rem ** Set the enemy types for each level
  rem ** 255 blanks it out.  
  rem ** Note that the 255 enemy is still on screen but simply invisible - collision routines account for that.
  rem ** Enemies:
  rem      -monster1type=demon bat
  rem      -monster2type=snake
  rem      -monster3type=skeleton warrior
  rem
  if levelvalue=1 then monster1type=1   :monster2type=255 :monster3type=255
  if levelvalue=2 then monster1type=255 :monster2type=3   :monster3type=255 :level2flag=1
  if levelvalue=3 then monster1type=1   :monster2type=3   :monster3type=255 :level3flag=1
  if levelvalue=4 then monster1type=255 :monster2type=3   :monster3type=5   :level4flag=1
  if levelvalue=5 then monster1type=1   :monster2type=3   :monster3type=5   :level5flag=1
demoskip1

  rem ** x value is set to 0 when there is a level change, so any enemy that is appearing
  rem ** on the screen for the first time will spawn on the opposite side of the screen
  rem ** That's to avoid an enemy spawning directly on top of you.
  if monster1x=0 then gosub monster1respawn
  if monster2x=0 then gosub monster2respawn
  if monster3x=0 then gosub monster3respawn

  if playerinvisibletime>0 then playerinvisibletime=playerinvisibletime-1

  rem ** Check Level
  rem 
  rem ** these are the point values needed to advance to the next level
  rem ** Level 1: 00,000 Pts
  rem ** Level 2: 07,500 Pts
  rem ** Level 3: 15,000 Pts
  rem ** Level 4: 30,000 Pts
  rem ** Level 5: 60,000 Pts
  rem 
  rem ** these are the skill variable values for each skill level
  rem ** skill 1 = Novice (start on level 1)
  rem ** skill 2 = Standard (start on level 1)
  rem ** skill 3 = Advanced (start on level 2)
  rem ** skill 4 = Expert (start on level 3)
  rem
  rem ** if you start off on level 2 or 3 (Advanced & Expert) you will start with zero points but still need to achieve
  rem ** the same score in order to level up to the next level.  You'll be on the same level much longer.
  rem
  if score5flag=1 then skipsc5
  if sc1 = $06 then levelvalue=5: score5flag=1:gosub wizmodeinit:goto skipcl: rem ** increase level if score is greater than 60,000
skipsc5
  if score4flag=1 then skipsc4
  if sc1 = $03 then levelvalue=4: score4flag=1:gosub wizmodeinit:goto skipcl: rem ** increase level if score is greater than 30,000
skipsc4
  if score3flag=1 then skipsc3
  if sc1 = $01 && sc2 > $49 && sc3 = $00 then levelvalue=3: score3flag=1:gosub wizmodeinit:goto skipcl: rem ** increase level if score is greater than 14,500
skipsc3
  if score2flag=1 then goto skipsc2
  if sc1 = $00 && sc2 > $74 && sc3 = $00 then levelvalue=2: score2flag=1:gosub wizmodeinit:goto skipcl: rem ** increase level if score is greater than 07,500
skipsc2
skipcl

  rem ** after going over 37,500 points monsters will be able to fire into the bunker
  rem **     ...Watch out!
  if bunkerspeakflag=1 then goto skipbunkerhit
  rem ** this also runs the sub that will make the AtariVox say "Bunker Destroyed!"
  if sc1 = $03 && sc2 > $74 && bunkerspeakflag=0 then gosub bunkerspeak:bunkerspeakflag=1:bunkerbuster=1
skipbunkerhit

  rem ** play the level up speech each time you level up. Unsurprisingly, the AtariVox says "Level Up!"
  if level2flag=1 then goto skiplevel2speech
  if levelvalue=2 then gosub level2speak
skiplevel2speech

  if level3flag=1 then goto skiplevel3speech
  if levelvalue=3 then gosub level3speak
skiplevel3speech

  if level4flag=1 then goto skiplevel4speech
  if levelvalue=4 then gosub level4speak
skiplevel4speech

  if level5flag=1 then goto skiplevel5speech
  if levelvalue=5 then gosub level5speak
skiplevel5speech

  rem ** AtariVox speech for when you run out of arrows
  rem    Note that the arrowspeakflag is reset to 0 when you pick up the quiver (the grab_arrows subroutine)
  if arrowspeakflag=1 then goto skiparrow5
  if arrowcounter=0 then gosub arrowsgonespeak:arrowspeakflag=1
skiparrow5

  rem ** Extra life counter
  rem ** Pick up X number of treasuress and gain a life.  The counter is incremented every time you pick up a treasure.
  if extralife_counter=5 then gosub gainalife:extralife_counter=0:speak extralife

  rem ** some handy counters, that increment every frame, every 2nd frame, every 4th frame
  frame=frame+1
  altframe=frame&1
  quadframe=frame&3

  rem ** this changes from 0 to 32, and from 32 to 0, every 32 frames.
  rem ** its used to make certain objects blink...
  objectblink=frame&%00100000

  rem ** this controls how long the player is frozen 
  rem ** Change the freezecount limit to affect how long player is frozen. This was adjusted many times!
  freezecount=freezecount+1
  if freezecount=160 then freezecount=1:freezeflag=0

  rem ** this plays the buzzing sound when you're frozen
  rem ** it's skipped if you're already frozen or are in wizard mode (there's nothing to freeze you in wizard mode)
  if freezeflag<>1 || wizmode<>0 then goto skipbuzz
  if demomode=0 then playsfx sfx_buzz else playsfx sfx_buzz_demo
skipbuzz

  rem ** play the heartbeat background sound
  rem ** volume increases as you get lower on arrows
  rem **   ...It's stressful to get low on arrows!
  soundcounter=soundcounter+1
  if soundcounter>soundcounterlimit[arrowcounter] then soundcounter=0

  rem ** skip the heartbeat sound if invicibility is on, as there's a separate sound for that
  rem ** skip the heartbeat sound if demo mode is on, as there is a separate sound for that too
  if demomode=1 then goto skipheartbeat
  if invincible_on=1 then goto skipheartbeat

  rem ** this changes the heartbeat sound - both rate and volume - as you get low on arrows
  rem ** heartbeat sound is skipped during wizard mode, it has a separate background tune
  if soundcounter<>1 then goto skipbeatsound
  if arrowcounter>7 && wizmode=0 then playsfx sfx_heartbeat
  if arrowcounter=7 && wizmode=0 then playsfx sfx_heartbeat1
  if arrowcounter>4 && arrowcounter<7 && wizmode=0 then playsfx sfx_heartbeat2
  if arrowcounter>2 && arrowcounter<5 && wizmode=0 then playsfx sfx_heartbeat3
  if arrowcounter<3 && wizmode=0 then playsfx sfx_heartbeat4
skipbeatsound

skiparrowsgonespeak

  rem ** volume for the heartbeat sound as you get lower on arrows
  data soundcounterlimit
  46, 52, 60, 65, 70, 75, 80, 85, 90, 95
end

skipheartbeat

  rem ** play a static heartbeat sound when in demo mode
  rem ** it doesn't change with the number of arrows remaining like the regular game
  if demomode<>1 then goto skipdemoheartbeat
  if soundcounter=1 then playsfx sfx_heartbeat_demo1
  if soundcounter=3 then playsfx sfx_heartbeat_demo2
  if soundcounter=5 then playsfx sfx_heartbeat_demo3
  if soundcounter=7 then playsfx sfx_heartbeat_demo4
skipdemoheartbeat

  rem ** if you choose the 'fast' speed menu option in developer mode, you move faster
  rem **   ...how do you enable developer mode?  It's a secret. It's also right here somewhere in this code. :)
  if speedvalue=2 then goto fastplay

  rem ** slow down the player & firing
  slowdown3=slowdown3+1
  if slowdown3=3 then slowdown3=0
  if slowdown3<1 then goto skipdorunframe

  rem ** slow down the player in the spider web
  rem **   ...because walking through spiderwebs is hard
  if p0_x<28 && p0_y<60 && slowdown3<2 then goto skipdorunframe
fastplay

   rem ** skip the section that moves the player in demo mode if you're in the normal game
   if demomode=0 then skipdemomovplayer

   rem ** monster directions are encoded as up(0) left(1) down(2) right(3)

   rem ** move the player with monster logic during the game demo
   rem ** if she's frozen or dying in the demo, don't move
   if freezeflag=1 then goto skipdemomovplayer
   if playerdeathflag=1 then goto skipdemomovplayer
   tempx=p0_x
   tempy=p0_y
   tempdir=demodir
   temptype=1
   templogiccountdown=demochangetimer
   if p0_x>78 && p0_x<90 && p0_y>55 && p0_y<90 then tempdir=0:templogiccountdown=0:goto skiphumanmonstmeld
   temppositionadjust=2
   gosub doeachmonsterlogic
skiphumanmonstmeld
   demochangetimer=templogiccountdown
   demodir=tempdir
   p0_dx=0:p0_dy=0
   if tempdir=0 then p0_dy=255
   if tempdir=1 then p0_dx=255:runningdir=7
   if tempdir=2 then p0_dy=1
   if tempdir=3 then p0_dx=1:runningdir=0
   goto dorunframe
skipdemomovplayer

  rem ** you can't move the player if the game's over, you're frozen, or you're dying.
  if gameoverflag=1 then goto skipmove
  if freezeflag=1 then goto skipdorunframe
  if playerdeathflag=1 then goto skipdorunframe

  rem ** player movement logic
  p0_dx=0:p0_dy=0
  if joy0right then fire_dir=4:gosub checkmoveright:runningdir=0 : goto dorunframe
  if joy0left then fire_dir=3:gosub checkmoveleft:runningdir=7 : goto dorunframe
  if joy0up then fire_dir=1:gosub checkmoveup:goto dorunframe
  if joy0down then fire_dir=2:gosub checkmovedown:goto dorunframe

  runningframe=0:       rem ** this is the frame that is used when standing still
  goto skipdorunframe : rem ** don't advance the animation if the archer isn't moving

dorunframe

  rem ** move the player
  p0_x=p0_x+p0_dx : p0_y=p0_y+p0_dy

  rem ** Animation Speed
  rem ** the "&7" bit slows down the animation. If you need slower, try "&15", or "&3" for faster.
  if (frame&3)=0 then runningframe=runningframe+1:if runningframe=7 then runningframe=0
skipdorunframe

  rem ** Quiver placement section

  rem ** If the Max Arrows option is set to 'off', we'll skip the quiver powerup placement entirely
  rem **   ...don't want the quiver to appear if you have unlimited arrows
  if arrowsvalue=9 then quiverx=200:goto skipquiverplacement

  rem ** if you have arrows, don't display the quiver powerup.  
  rem ** quiverx=200 places the quiver offscreen, quiverflag=0 indicates you have an inventory of arrows,
  rem ** and quiverplaced=0 resets the flag so the quiver can be randomly placed again in the future.
  if arrowcounter>0 then quiverx=200:quiverflag=0:quiverplaced=0

  rem ** if you run out of arrows, set the flag to indicate you have 0 arrows
  if arrowcounter=0 then quiverflag=1

  rem ** jump to random quiver x/y placement subroutine
  if quiverflag=1 then gosub quiverplacer

  rem ** skip the quiverplacer sub below
  goto skipquiverplacement

quiverplacer
  rem ** if the quiver placed flag is on, it means this sub has already been run once.
  rem ** if it ran more than once when the arrow was 0, the quiver would flicker at
  rem ** all 8 random locations simultaneously.
  if quiverplaced=1 then return

  rem ** this creates a value from 1-8, and we place the quiver in one of 8 random locations
  quiverplacement = rand&7
  quiverx=quiverx_i[quiverplacement]
  quivery=quivery_i[quiverplacement]
  rem ** set the flag that the quiver has been placed so this is only run once
  quiverplaced=1
  return
  rem ** these are the x/y values for quiver placement
  data quiverx_i
  6,    54, 150, 150, 134,  38, 100, 70
end
  data quivery_i
  180, 116, 148,  20,  50, 148, 180, 20
end

skipquiverplacement

  rem ** if the treasure placed flag is on (1), run the timer to make it eventually disappear
  if treasureplaced=1 then treasuretimer=treasuretimer+1
  if treasuretimer>250 then treasuretimer2=treasuretimer2+1

  rem ** when the timer runs out, change the flag and remove it from the screen
  if treasuretimer2>13 then treasuretimer=1:treasuretimer2=0:treasureplaced=0:treasure_rplace=0:treasure_rplace2=0:treasurex=200

  rem ** place treasure randomly
  treasure_rplace=treasure_rplace+1
  if treasure_rplace=254 then treasure_rplace=0:treasure_rplace2=treasure_rplace2+1

  if treasure_rplace2>6 then treasure_rplace2=0

  if treasure_rplace2>5 && treasureplaced=0 then gosub treasurespawn
  if treasure_rplace2<6 && treasureplaced=0 then treasurex=200:goto skiptreasureplacement
  goto skiptreasureplacement

placetreasure
  rem ** jump to random treasure x/y placement subroutine
  if treasureplaced=0 then gosub treasurespawn

  rem ** skip the treasurespawn sub below
  goto skiptreasureplacement

treasurespawn

  rem ** if the treasureplaced flag is on, it means this sub has already been run once.
  if treasureplaced=1 then return

  rem ** reset treasure timer
  treasuretimer=0

  rem ** use a random number between 0-7 to determine a random location for treasure placement... one of 8.
  treasurespawn = rand&7
  treasurex=treasurex_i[treasurespawn]
  treasurey=treasurey_i[treasurespawn]
  rem ** set the flag that the treasure has been placed so this is only run once
  treasureplaced=1
  return

  rem ** this is the x/y placement coordinates for the treasure sprite
  data treasurex_i
   6,   22,  84,  38, 120, 134, 54, 120
end
  data treasurey_i
   116, 22, 116, 180,  20, 148, 20, 180
end

  rem ** initialize wizard mode
wizmodeinit
  wizmode=1
  wizfirex=200
  playsfx sfx_wor1
  playsfx sfx_wor2
  if p0_x<84 then gosub warpwizard_right
  if p0_x>83 then gosub warpwizard_left
  return

warpwizard_right
  wizwarpcountdown=240
  rem ** choose a new location for the wizard on the right side of the screen
  temp1 = (rand&3)
  wizx=wizx_i[temp1]
  wizy=wizy_i[temp1]
  return

  rem ** x/y spawn locations for the wizard on the right side of the screen
  data wizx_i
   98, 132, 150, 118
end
  data wizy_i
   16, 144, 116, 176
end

warpwizard_left
  wizwarpcountdown=240
  rem ** choose a new location for the wizard on the left side of the screen
  temp1 = (rand&3)
  wizx=wizx_j[temp1]
  wizy=wizy_j[temp1]
  return

  rem ** x/y spawn locations for the wizard on the left side of the screen
  data wizx_j
   4,   20,  54,  36
end
  data wizy_j
   112, 16, 112, 176
end

warpwizard
  wizwarpcountdown=255
  temprand = (rand&7)
  wizx=wizx_k[temprand]
  wizy=wizy_k[temprand]
  tempx=wizx-32
  tempy=wizy-32
  if boxcollision(p0_x,p0_y, 5,16, tempx,tempy, 72,80) then temprand=(temprand+1)&7:wizx=wizx_k[temprand]: wizy=wizy_k[temprand]
  playsfx sfx_wizwarp
  
  return

   rem ** x/y coordinates for wizard spawn
   data wizx_k
   4,  132, 54, 118
   20, 20, 150,  36
end
  data wizy_k
   112, 144, 112, 176
   96,  16, 116, 176
end

skiptreasureplacement

  rem ** Invincibility [God Mode]

  rem ** to prevent an issue where getting shot at the same time as picking up the sword
  rem ** would trigger the death animation during god mode
  if playerdeathflag=1 then invincibleflag=0:invincible_on=0:rem if death animation is running, turn god mode off
  if invincible_on=1 then playerdeathflag=0:rem if you're god, nothing can trigger death or the death animation to start.

  rem ** enable player color flashing when god mode is enabled
  colorflasher=colorflasher+invincible_counter2+1
  if invincible_on=1 then P7C2=colorflasher

  rem ** if god mode is off, change player color back to the default, skip color flasher
  if invincible_on=0 then P7C2=$26:goto skipinvinciblestuff

  rem ** player color flashing code
  rem **  ...because everyone knows you always flash colors when you're invincible
  P7C2=colorflasher
  if (colorflasher/16)=lastflash then goto skipinvinciblestuff
  lastflash=colorflasher/16
  noteindex=(noteindex+1)&3
  temp8=arp_god[noteindex]
  if wizmode=0 || wizmode=200 then playsfx sfx_god temp8
skipinvinciblestuff

  rem ** timer for how long invincibility lasts
  rem **    ...it lasts about 22 seconds.
  rem **    ...it doesn't seem long enough when you're playing, it's fun to be god
  rem **    ...you can change the last invincible_counter2 variable below to adjust how long god mode lasts
  if invincibleflag=0 then invincible_counter1=0:invincible_counter2=0:goto skipinvincibletimer
  invincible_counter1=invincible_counter1+1
  if invincible_counter1=254 then invincible_counter1=0:invincible_counter2=invincible_counter2+1
  if invincible_counter2>5 then invincible_counter2=0
  if invincible_counter2>4 then invincibleflag=0:invincible_on=0: rem ** turn god mode off when timer expires
skipinvincibletimer

  rem ** turn it on/off
  rem
  rem ** if god mode is set to on from the main titlescreen (developer mode option), don't ever turn it off
  if godmodeon=1 then goto skipcheck
  if invincibleflag=1 then invincible_on=1:rem invincible mode on
  if invincibleflag=0 then invincible_on=0:rem invincible mode off
skipcheck

  rem ** Place sword randomly at a set interval
  rem ** it's currently about every 60 seconds once it's been picked up 
  rem ** it never disappears from the screen until it's picked up, it doesn't disappear like the treasure does

  sword_rplace=sword_rplace+1
  if sword_rplace=254 then sword_rplace=0:sword_rplace2=sword_rplace2+1

  if sword_rplace2>16 then sword_rplace2=0

  if sword_rplace2>15 && swordplaced=0 then gosub swordspawn
  if sword_rplace2<16 && swordplaced=0 then swordx=200:goto skipswordplacement
  goto skipswordplacement

placesword
  rem ** jump to random sword x/y placement subroutine
  if swordplaced=0 then gosub swordspawn

  rem ** skip the swordspawn sub below
  goto skipswordplacement

swordspawn

  rem ** if the swordplaced flag is on, it means this sub has already been run once.
  rem **    ...so yeah, don't run it again if the flag is on
  if swordplaced=1 then return

  rem ** randomize sword x/y location based on data below
  swordspawn = rand&7
  swordx=swordx_i[swordspawn]
  swordy=swordy_i[swordspawn]

  rem ** set the flag that the sword has been placed so this is only run once
  swordplaced=1
  return

  rem ** x/y data placement for sword
  data swordx_i
  150, 70, 38, 84, 134, 150, 38, 100
end
  data swordy_i
  54, 146, 116, 176, 116, 176, 54, 18
end

skipswordplacement

  rem ** background/maze colors depend on pause button selection on powerup
  rem **   ...yeah, again, hold down pause to reverse background/dungeon colors on powerup
  if wizmode=0 && colorchange=0 then SBACKGRND=0:P0C2=levelcolors[levelvalue]
  if wizmode=0 && colorchange=1 then SBACKGRND=levelcolors[levelvalue]:P0C2=0

  rem ** button debounce
  rem **   ...it doesn't register until the button is released, not when it's pressed
  rem **   ...some have said it shouldn't be called "debounce".  that's what I call it.
  if fireheld=1 && !joy0fire then fireheld=0

  rem ** if you hit the button in demo mode, return to the title screen
  if demomode=1 && fireheld=0 && joy0fire then fireheld=1:goto titlescreen

  rem <--- Start Arrow firing code for the player --->
  rem         ...notice the arrows on both sides of the text above
  rem         ...arrows are the main weapon in this game
  rem         ...irony or coincidence?

  rem ** conditions upon which we fire a new arrow
  if fire_debounce>0 then fire_debounce=fire_debounce-1:goto skipstartfire
  if !joy0fire then goto skipstartfire
  rem ** frozen? No fire for you!
  if freezeflag=1 then goto skipstartfire
  rem ** button held down? No fire for you!
  if fireheld=1 then goto skipstartfire
  rem ** arrow not offscreen? No fire for you!
  if xpos_fire<>200 then goto skipstartfire
  rem ** no arrows? No fire for you!
  if arrowcounter=0 then goto skipstartfire
  rem ** Dead? No fire for you! 
  if playerdeathflag=1 then goto skipstartfire

  rem ** if we're here, the following is true
  rem    ...1. the fire button is pressed
  rem    ...2. the arrow is in limbo, ready to fire
  rem    ...3. we have arrows in inventory
  rem    ...4. you rock because you're reading the code comments

  rem ** set the position and direction for arrow
  xpos_fire=p0_x:ypos_fire=p0_y+2:fire_dir_save=fire_dir

  rem ** wizard mode countdown for warping check
  rem **   ...heh. warping is cool.
  temp1=rand&1
  if wizmode=200 && temp1=1 && wizwarpcountdown<200 then wizwarpcountdown=1

  rem ** play the quiver firing sound
  if wizmode=0 || wizmode=200 then playsfx sfx_player_shoot

  rem ** and reduce the arrows in inventory
  rem **    ...arrows? we don't need no stinking arrows!
  rem **    ...it's merely a flesh wound!
  if arrowsvalue=9 then goto skipstartfire
  arrowcounter=arrowcounter-1

skipstartfire
 
  rem ** if you choose the 'fast' speed menu option, arrows fire faster
  rem ** fast speed is only a developer mode option.
  if speedvalue=2 then goto fastplay2

  rem ** this slows down the firing rate
  if slowdown3<1 then goto skip_updatefire

fastplay2

  rem ** if the arrow is offscreen, don't move it
  rem **  ...realism is important. no one can fire an arrow that fast.
  if xpos_fire=200 then goto skip_updatefire

  rem ** if arrow is in flight, move it
  if fire_dir_save=1 then ypos_fire=ypos_fire-2
  if fire_dir_save=2 then ypos_fire=ypos_fire+2
  if fire_dir_save=3 then xpos_fire=xpos_fire-2
  if fire_dir_save=4 then xpos_fire=xpos_fire+2

  rem ** stop the arrow when it hits the screen edges
  if xpos_fire>158 || xpos_fire<2 then xpos_fire=200
  if ypos_fire>192 || ypos_fire<2 then xpos_fire=200

  rem ** stop the arrow firing if it's not over a blank space
  temp0_x=(xpos_fire+1)/4
  temp0_y=ypos_fire/8
  tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)

  rem ** check if the arrow hit a mini spiderweb character. if so, clear it...
  if tempchar1>=spw1 && tempchar1<=spw4 then xpos_fire=200:fireheld=1:pokechar screenram temp0_x temp0_y 40 28 $41:goto skip_updatefire

  rem ** $41 is the character position of the maze blank character. magic values suck...
  if tempchar1<>$41 then xpos_fire=200:fireheld=1
skip_updatefire
  rem <--- End Arrow firing code for player --->

  rem ** don't allow robots to fire if they are set to be offscreen
  rem ** the wizard uses monster1type, so don't reset arrow fire to offscreen when in wizard mode
  if monster1type=255 && wizmode=0 then r1x_fire=200:r1y_fire=200
  if monster2type=255 then r2x_fire=200:r2y_fire=200
  if monster3type=255 then r3x_fire=200:r3y_fire=200

  rem ** Slow down the animation for sprites
  slowdown1=(slowdown1+1)&31
  if (framecounter&3)=0 then slowdown_spider=slowdown_spider+1:if slowdown_spider>4 then slowdown_spider=0
  slowdown_bat1=slowdown_bat1+1:if slowdown_bat1>20 then slowdown_bat1=0
  slowdown_bat2=slowdown_bat2+1:if slowdown_bat2>20 then slowdown_bat2=0

  rem ** Increment the frame displayed for any monster explosions...
  for temploop=0 to 2
     if (frame&7)=0 then explodeframe1[temploop]=explodeframe1[temploop]+1
     if explodeframe1[temploop]>7 then explodeframe1[temploop]=0
  next

  rem ** animation frames for player death
  if (frame&7)=0 then deathframe=(deathframe+1)&15

  rem ** slow down the anmiation for monster 1 / Demon Bat
  if slowdown1=15 then monster1animationframe=0:monster2animationframe=0:monster3animationframe=0:quiveranimationframe=0:freeze=0
  if slowdown1=30 then monster1animationframe=1:monster2animationframe=1:monster3animationframe=1:quiveranimationframe=1:freeze=1

  spideranimationframe=slowdown1/8

  rem ** slow down animation for bats
  if slowdown1=10 then batanimationframe=0
  if slowdown1=20 then batanimationframe=1
  if slowdown1=30 then batanimationframe=2

  spiderdeathframe=slowdown_spider

  if slowdown_bat1=8 then bat1deathframe=0
  if slowdown_bat1=12 then bat1deathframe=1
  if slowdown_bat1=16 then bat1deathframe=2
  if slowdown_bat1=20 then bat1deathframe=3

  if slowdown_bat2=8 then bat2deathframe=0
  if slowdown_bat2=12 then bat2deathframe=1
  if slowdown_bat2=16 then bat2deathframe=2
  if slowdown_bat2=20 then bat2deathframe=3
skipmove

  rem ** if the game over flag is set, calculate high score for titlescreen, goto "game over" pause screen
  if gameoverflag=1 && joy0fire && countdownseconds=0 then gosub HighScoreCalc:gameoverflag=0:SBACKGRND=0:goto gameoverrestart

  rem **********************************************************************************
  rem ************ Section 2: Display Logic... avoid non-display logic here ************
  rem **********************************************************************************

  rem **  The restorescreen erases any sprites and
  rem **  characters that you've drawn on the screen since
  rem **  the last savescreen.
  restorescreen

  rem ** put dev mode text on screen if you're in dev mode
  rem **   ...because it's cheating to take a screenshot of a high score in dev mode.
  rem **   ...and no one's going to bother to photoshop it out, right?
  rem **   ...it's also a reminder that it's active. because people forget.
  if gamemode=1 then plotsprite devmode 2 62 194

  rem ** MORE WITCHCRAFT - we used plotchars to display ram locations as the "score",  prior
  rem ** to the savescreen command. This allows us to skip an expensive drawvalue each and
  rem ** every frame. But we do need to make those memory locations point at valid character
  rem ** digits resembling the player's score...
  score0bcd0=(sc1/16)+digitstart
  score0bcd1=(sc1&$0F)+digitstart
  score0bcd2=(sc2/16)+digitstart
  score0bcd3=(sc2&$0F)+digitstart
  score0bcd4=(sc3/16)+digitstart
  score0bcd5=(sc3&$0F)+digitstart

  rem ** YET MORE WITCHCRAFT...
  rem ** same trick for lives as with the level and score, but this time we may sometimes
  rem ** substitute the god mode character in place of the lives counter
  const godchar=<godmode
  if godvalue=2 || invincible_on=1 then livesbcdhi=godchar:livesbcdlo=godchar+1:goto skiplifecounter
  livesbcdhi=digitstart
  livesbcdlo=lifecounter+digitstart
skiplifecounter

  rem ** plot the "game over" sprite in the middle of the screen if the game has ended
  if gameoverflag=1 && demomode=0 then plotsprite gameovertext 7 72 51
  if gameoverflag=0 && demomode=1 then plotsprite demomodetext 7 71 51

  rem ** go to the frozen sub if you're been frozen by a spider or bat
  if freezeflag=1 then goto frozen

  rem ** go to the player death sub if you've died
  if playerdeathflag=1 then goto playerdeath

  rem ** Animation Frames for Archer
  temp1=runningdir+runningframe
  plotsprite archer_1_top_faceright 7 p0_x p0_y temp1
  p0_y=p0_y+8
  temp1=runningdir+runningframe
  plotsprite archer_1_bottom_faceright 7 p0_x p0_y temp1
  p0_y=p0_y-8

  rem ** skip the frozen and player death subs below, they are called above if they're needed
  goto skipall

frozen

  rem ** Animation frames for frozen archer
  if invincibleflag=0 then plotsprite archer_still_top 7 p0_x p0_y freeze
  if invincibleflag=1 then plotsprite archer_still_top 4 p0_x p0_y freeze
  p0_y=p0_y+8
  if invincibleflag=0 then plotsprite archer_still_bottom 7 p0_x p0_y freeze
  if invincibleflag=1 then plotsprite archer_still_bottom 4 p0_x p0_y freeze
  p0_y=p0_y-8
  goto skipall

playerdeath

  rem ** Animation frames for archer death
  if invincibleflag=0 then plotsprite archer_death_top1 7 p0_x p0_y deathframe
  if invincibleflag=1 then plotsprite archer_death_top1 4 p0_x p0_y deathframe
  p0_y=p0_y+8
  if invincibleflag=0 then plotsprite archer_death_bottom1 7 p0_x p0_y deathframe
  if invincibleflag=1 then plotsprite archer_death_bottom1 4 p0_x p0_y deathframe
  p0_y=p0_y-8

skipall

  rem ** reset wizard animation
  if wizanimationframe>3 then wizanimationframe=0
 
  rem ** this removes both bats on level 5, and allows one bat on level 4
  if levelvalue=5 then goto bat2deathskip
  if levelvalue=4 then goto bat1deathskip

  rem ** jump to bat1death sub if the bat has been shot or touched
  if bat1deathflag=1 then goto bat1death

  rem ** skip bat death sub if wiz mode is active
  if wizmode>0 then goto bat1deathskip

  rem ** Animation Frames for Bat 1
  plotsprite bat1 2 bat1x bat1y batanimationframe
  goto bat1deathskip

bat1death
  plotsprite bat_explode1 2 bat1x bat1y batanimationframe
bat1deathskip

  rem ** jump to bat1death sub if the bat has been shot or touched
  if bat2deathflag=1 then goto bat2death

  rem ** skip bat death sub if wiz mode is active
  if wizmode>0 then goto bat2deathskip

  rem ** Animation Frames for Bat 2
  plotsprite bat4 2 bat2x bat2y batanimationframe
  goto bat2deathskip

bat2death
  plotsprite bat_explode1 2 bat2x bat2y batanimationframe
bat2deathskip

  rem ** wizard mode sprite display, including warp-in effect...
  if wizmode<200 then skipplotwiz
  if wizmodeover>0 && wizdeathflag=1 then gosub plotwizexplode
  if wizmodeover>0 then skipplotwiz
  if wizx=200 then skipplotwiz
  if wizwarpcountdown<200 then wiztempx=wizx:wiztempy=wizy:goto skipwarpeffect

  rem ** WITCHCRAFT AHEAD...
  rem ** when the wizard warps in, he's plotted in 4 locations offset from
  rem ** his real location. ie. top-left in frame 0, bottom-left in frame 1,
  rem ** top-right in frame 2, and bottom-right in frame 3. rinse and repeat.
  rem ** the following code uses bitwise calculations on the frame counter
  rem ** to simplify the logic of picking which quadrant he's displayed in.
  rem ** The wizwarpcountdown variable determines how far his image is from
  rem ** his real location. So as it approaches 0, it approaches his real
  rem ** location...
  temp2=framecounter&1
  temp3=framecounter&2
  temp4=(wizwarpcountdown-200)*2
  if temp2=1 then wiztempx=wizx-temp4 else wiztempx=wizx+temp4
  if temp3=2 then wiztempy=wizy-temp4 else wiztempy=wizy+temp4
skipwarpeffect
  plotsprite wizlefttop1 0 wiztempx wiztempy wizanimationframe
  wiztempy=wiztempy+8
  plotsprite wizleftbottom1 0 wiztempx wiztempy wizanimationframe
skipplotwiz
  
  rem ** jump to spider death sub if the spider has been shot or touched
  if spiderdeathflag=1 then goto spiderdeath

  rem ** skip spider death if wizard mode is active
  if wizmode>0 then goto skipspiderdeath

  rem ** Animation Frames for Spider
  rem ** Two 8x8 sprites stitched together top/bottom
  plotsprite spd1top 4 spiderx spidery spideranimationframe
  spidery=spidery+8
  plotsprite spd1bot 4 spiderx spidery spideranimationframe
  spidery=spidery-8

  goto skipspiderdeath

spiderdeath
  plotsprite spider1top_explode1 4 spiderx spidery spiderdeathframe
  spidery=spidery+8
  plotsprite spider1bottom_explode1 4 spiderx spidery spiderdeathframe
  spidery=spidery-8

skipspiderdeath

  rem ** display the monster sprites
  for temploop=0 to 2
  gosub displaymonstersprite
  next

  rem ** plot the bunker in the center of the screen
  rem ** if the bunkerbuster variable is 1, your score has reaced 37,500 - display the blasted bunker instead
  if skill=4 then bunkerbuster=1
  if bunkerbuster=1 then goto brokenbunker
  plotsprite widebar_top 2 76 64
  plotsprite widebar 2 76 72
  plotsprite widebar 2 76 80
  goto skipbrokenbunker
brokenbunker
  plotsprite widebar_top_broken 2 76 64
  plotsprite widebar 2 76 72
  plotsprite widebar 2 76 80
skipbrokenbunker

  rem ** Animation Frames for Quiver
  if objectblink<>0 then goto skipplotquiver
  if arrowcounter=0 then plotsprite quiver1 2 quiverx quivery
skipplotquiver

  if swordy=200 then goto skipplotsword
  if objectblink=0 then goto skipplotsword
  plotsprite swordtop 2 swordx swordy
  swordy=swordy+8
  plotsprite swordbottom 2 swordx swordy
  swordy=swordy-8
skipplotsword

  rem ** plot the arrow sprite for the player
  if xpos_fire<>200 then plotsprite arrow 2 xpos_fire ypos_fire

  rem ** plot the arrow sprite for monster 
  rem on level 5, the monster 3 type will fire a larger arrow

  rem ** If you're on Expert mode, all shots are the shot blocking type.  Skip over normal arrow firing section.
  if skill=4 then goto skill4shots

  rem ** plot the normal arrow when enemies fire
  if r1x_fire<>200 && newfire1=0 then plotsprite arrow2 2 r1x_fire r1y_fire
  if r2x_fire<>200 && newfire2=0 then plotsprite arrow2 2 r2x_fire r2y_fire
  if r3x_fire<>200 && newfire3=0 && levelvalue<5 then plotsprite arrow2 2 r3x_fire r3y_fire
  if r3x_fire<>200 && newfire3=0 && levelvalue>4 then plotsprite arrow_large 2 r3x_fire r3y_fire
  goto skipskill4shots

  rem ** plot the shot blocking arrow when enemies fire
skill4shots
  if r1x_fire<>200 && newfire1=0 then plotsprite arrow_large 2 r1x_fire r1y_fire
  if r2x_fire<>200 && newfire2=0 then plotsprite arrow_large 2 r2x_fire r2y_fire
  if r3x_fire<>200 && newfire3=0 then plotsprite arrow_large 2 r3x_fire r3y_fire
skipskill4shots

  rem ** plot the arrows remaining     
  temp1=arrowcounter
  if temp1>8 then temp1=8
  rem ** if you have unlimited arrows, skip plotting the number of arrows and display the "unlimited" sprite instead
  if arrowsvalue=9 then plotsprite arrowbar_nolimit 6 136 208:goto skipbar

  rem ** plot the number of arrows remaining on the status bar
  plotsprite arrowbar0 6 135 208 temp1
skipbar

  rem ** plot treasure sprite

  rem ** the treasure will flash for the last 3 or so seconds it's onscreen
  if treasuretimer2>9 then goto flashtreasure
  plotsprite treasure 5 treasurex treasurey
  goto skipflashtreasure
flashtreasure
  treasurep=treasurep_i[treasureindex]
  plotsprite treasure treasurep treasurex treasurey
  data treasurep_i
  3, 4, 5, 6, 7, 3
end
skipflashtreasure

  drawscreen

  rem ** if you die right when you're entering wiz mode,
  rem ** the death animation won't play over and over again.  
  rem ** The normal collision routine is otherwise skipped.
  if wizmode>0 && deathframe=15 && playerdeathflag=1 then gosub losealife:playerdeathflag=0:playerinvisibletime=180:p0_x=84:p0_y=68:fire_dir_save=1:fire_dir=1

  treasureindex=treasureindex+1
  if treasureindex>5 then treasureindex=0

  rem ** Collision with treasure
  rem 
  rem ** avoid playing the treasure pickup sound when wizmode>0 && wizmode<200 so it won't interrupt the wiz music, 
  rem ** but will be available during full blown wizard mode
  rem
  if quadframe=0 && treasurex<200 && boxcollision(p0_x,p0_y, 5,16, treasurex,treasurey, 6,8) then gosub treasurespeak:score0=score0+000500:extralife_counter=extralife_counter+1:treasureplaced=0:treasure_rplace=0:treasure_rplace2=0:treasuretimer=1:treasuretimer2=0:gosub pickupsound

  rem ** Collision with sword
  if quadframe=1 && swordx<200 && boxcollision(p0_x,p0_y, 5,16, swordx,swordy, 6,16) then gosub godspeak:score0=score0+000100:invincibleflag=1:invincible_on=1:invincible_counter1=0:invincible_counter2=0:swordplaced=0:sword_rplace=0:sword_rplace2=0:gosub pickupsound

  rem ** monsters only move when wizmode is over...
  if wizmode=0 then gosub monstlogic
  if spiderdeathflag=0 && wizmode=0 then gosub spiderlogic
  if wizmode>0 then goto skipbatlogic
  if bat1deathflag=1 || bat2deathflag=1 then goto skipbatlogic
  if levelvalue<5 then gosub batlogic
skipbatlogic

  rem ** Enemy respawn in lower left is monster1x=8:monster1y=144
   
  rem ** what do these box collision code lines do for the enemies?
  rem 
  rem    rem -- play the explosion sound
  rem    if boxcollision(xpos_fire,ypos_fire, 8,8, monster1x,monster1y, 8,8) then playsfx sfx_explode
  rem 
  rem    rem -- increase the score
  rem    score0=score0+100
  rem  
  rem    rem -- reset the counter for the explosion animation
  rem    slowdown_explode=0
  rem
  rem    rem -- set the death flag to 1, indicating monster death 
  rem    enemy1deathflag=1
  rem
  rem    rem -- if you've reached the last frame of the death animation, then reset the monster to the spawn point, and
  rem           reset the death flag to "alive", which is 0
  rem    if explodeframe=7 && enemy1deathflag=1 then monster1x=208:monster1y=208:enemy1deathflag=0

  rem ** Prior to level 5, the demon bat has only one hit point. 
  if levelvalue<5 then monster1_shieldflag=0:r1hp=0

  rem ** some monsters need to be hit twice, which is stored by their shieldflag...
  if r1hp>0 then monster1_shieldflag=1 else monster1_shieldflag=0
  if r2hp>0 then monster2_shieldflag=1 else monster2_shieldflag=0
  if r3hp>0 then monster3_shieldflag=1 else monster3_shieldflag=0

  rem ** Collision code for Player's arrows hitting an enemy monster

  rem ** detect the end of the death animation, reset death flag to off, reset to spawn point, add to score
  if explodeframe1=7 && enemy1deathflag=1 then gosub monster1respawn:enemy1deathflag=0:if wizmode=0 then score0=score0+000400
  if explodeframe2=7 && enemy2deathflag=1 then gosub monster2respawn:enemy2deathflag=0:if wizmode=0 then score0=score0+000600
  if explodeframe3=7 && enemy3deathflag=1 then gosub monster3respawn:enemy3deathflag=0:if wizmode=0 then score0=score0+000800

  if wizmode>0 then goto skipregularenemycollisions

  rem ** Detect a collision between player arrow and monster, play explosion sound, reset explosion animation, set enemy death flag to on
  rem ** Will also skip collision if monster type is 255

  rem --Enemy 1-- (Demon Bat)
  if xpos_fire=200 then goto skipr3hit
  if monster1type=255 then goto skipr1hit
  if enemy1deathflag=1 then goto skipr1hit
  if altframe=1 then goto skipr1hit
  if monster1_shieldflag=0 && boxcollision(xpos_fire,ypos_fire, 2,2, monster1x,monster1y, 8,16) then xpos_fire=200:playsfx sfx_explode:slowdown_explode=0:enemy1deathflag=1:explodeframe1=0:fireheld=1:goto skipr3hit
  if monster1_shieldflag=1 && boxcollision(xpos_fire,ypos_fire, 2,2, monster1x,monster1y, 8,16) then xpos_fire=200:gosub r1hit:goto skipr3hit
skipr1hit

  rem --Enemy 2-- (Snake)
  if monster2type=255 then goto skipr2hit
  if enemy2deathflag=1 then goto skipr2hit
  if altframe=0 then goto skipr2hit
  if monster2_shieldflag=1 && boxcollision(xpos_fire,ypos_fire, 2,2, monster2x,monster2y, 8,14) then xpos_fire=200:gosub r2hit:goto skipr3hit
monster2hit
  if monster2_shieldflag=0 && boxcollision(xpos_fire,ypos_fire, 2,2, monster2x,monster2y, 8,16) then xpos_fire=200:playsfx sfx_explode:slowdown_explode=0:enemy2deathflag=1:explodeframe2=0:fireheld=1:goto skipr3hit
skipr2hit

  rem --Enemy 3-- (Skeleton Warrior)
  if monster3type=255 then goto skipr3hit
  if enemy3deathflag=1 then goto skipr3hit
  if altframe=1 then goto skipr3hit
  if monster3_shieldflag=0 && boxcollision(xpos_fire,ypos_fire, 2,2, monster3x,monster3y, 8,16) then xpos_fire=200:playsfx sfx_explode:slowdown_explode=0:enemy3deathflag=1:explodeframe3=0:fireheld=1
  if monster3_shieldflag=1 && boxcollision(xpos_fire,ypos_fire, 2,2, monster3x,monster3y, 8,16) then xpos_fire=200:gosub r3hit
skipr3hit

  rem ** Collision code for the player running into an enemy

  rem ** Enemies can't shoot you or hurt you by running into you in god mode
  if godvalue=2 || invincible_on=1 then goto skipmonsterfire

  rem ** skip monster firing code if wizard mode is active
  if wizmode>0 then goto skipmonsterfire

  rem ** monsters can't hurt you if they're exploding
  if enemy1deathflag=1 then r1x_fire=200:goto skipmonsterfire
  if enemy2deathflag=2 then r2x_fire=200:goto skipmonsterfire
  if enemy3deathflag=3 then r3x_fire=200:goto skipmonsterfire

  rem ** detect the end of the player death animation, reset death flag to off, reset to bunker location, set firing direction to up
  if deathframe=15 && playerdeathflag=1 then gosub losealife:playerdeathflag=0:playerinvisibletime=180:p0_x=84:p0_y=68:fire_dir_save=1:fire_dir=1

  rem ** if the player death animation is running, skip collision detection
  rem ** also skip if demo mod is on, so sounds don't play
  if playerdeathflag=1 then goto skipr3coll

  rem ** Detect a collision between player and enemy, play explosion sound, reset explosion animation, set enemy death flag to on
  rem ** Will also skip collision if monster type is 255
  rem
  rem v215 - added this next line to ensure no regular enemy collisions are registered with enemies while wizmode is active
  if wizmode>0 then skipr3coll
  rem

  rem ** the "goto skiprXcoll" statements are to skip collisions if the monsters are set to be invisible (based on level, when set to 255).
  if monster1type=255 then goto skipr1coll
  if altframe=0 && boxcollision(p0_x,p0_y, 5,16, monster1x,monster1y, 8,16) then playsfx sfx_deathsound:playerdeathflag=1:gosub monster1respawn:deathframe=0
skipr1coll
  if monster2type=255  then goto skipr2coll
  if altframe=1 && boxcollision(p0_x,p0_y, 5,16, monster2x,monster2y, 8,16) then playsfx sfx_deathsound:playerdeathflag=1:gosub monster2respawn:deathframe=0
skipr2coll
  if monster3type=255 then goto skipr3coll
  if altframe=0 && boxcollision(p0_x,p0_y, 5,16, monster3x,monster3y, 8,16) then playsfx sfx_deathsound:playerdeathflag=1:gosub monster3respawn:deathframe=0
skipr3coll
  goto skipwizmodecollisions

skipregularenemycollisions
  if wizmodeover>0 || wizmode=0 then goto skipwizmodecollisions
  if invincible_on=1 || godvalue=2 then goto skipwizmodegod: rem v174

  rem ** Wizmode collisions

  rem ** collision: wizard with player
  if wizwarpcountdown>200 then goto skipmonsterfire
  if invincible_on=0 && boxcollision(p0_x,p0_y, 5,16, wizx,wizy, 8,16) then playsfx sfx_deathsound:playerdeathflag=1:deathframe=0:wizmodeover=1

  rem ** collision: player with wizard fire
  if invincible_on=0 && r1x_fire<>200 && boxcollision(p0_x,p0_y, 5,16, r1x_fire,r1y_fire, 4,2) then r1x_fire=200:playsfx sfx_deathsound:playerdeathflag=1:deathframe=0:wizmodeover=1

skipwizmodegod

  rem ** added respawns for all monsters, bats, and the spider when you kill the wizard (v178)

  rem ** collision: player fire with wizard
  rem v185 added gosub wizdeathspeak at the end of the next line
  if boxcollision(xpos_fire,ypos_fire, 2,2, wizx,wizy, 8,16) then xpos_fire=200:playsfx sfx_explode:wizdeathflag=1:fireheld=1:wizmodeover=1:score0=score0+1200:gosub wizdeathspeak

  goto skipmonsterfire 

skipwizmodecollisions

  rem ** Collision code for the player getting hit by enemy fire

  rem ** Don't let enemies shoot you after the game's over
  if gameoverflag=1 then goto skipmonsterfire

  rem ** don't let enemy arrows hit you inside the bunker
  if bunkerbuster=0 && p0_x>78 && p0_x<90 && p0_y>62 && p0_y<90 then goto skipmonsterfire

  rem ** detect the end of the player death animation, reset death flag to off, reset to bunker location, set firing direction to up
  if deathframe=15 && playerdeathflag=1 then gosub losealife:playerdeathflag=0:p0_x=84:p0_y=68:fire_dir_save=1:fire_dir=1
 
  rem ** if the player death animation is running, skip collision detection
  if playerdeathflag=1 then goto skipr3collb

  rem ** Detect a collision between player and enemy arrow, play explosion sound, reset arrow offscreen, set player death flag to on
  rem ** Will also skip collision if monster type is 255
  if monster1type=255 then goto skipr1collb
  if r1x_fire<>200 && altframe=0 && boxcollision(p0_x,p0_y, 5,16, r1x_fire,r1y_fire, 2,2) then r1x_fire=200:playsfx sfx_deathsound:playerdeathflag=1:deathframe=0
skipr1collb
  rem v215
  if monster2type=255 || wizmode>0 then goto skipr2collb
  if r2x_fire<>200 && altframe=1 && boxcollision(p0_x,p0_y, 5,16, r2x_fire,r2y_fire, 2,2) then r2x_fire=200:playsfx sfx_deathsound:playerdeathflag=1:deathframe=0
skipr2collb
  if monster3type=255 then goto skipr3collb
  if r3x_fire<>200 && altframe=0 && boxcollision(p0_x,p0_y, 5,16, r3x_fire,r3y_fire, 2,2) then r3x_fire=200:playsfx sfx_deathsound:playerdeathflag=1:deathframe=0
skipr3collb

skipmonsterfire

  rem ** monster shot blocking
  rem ** if Monster type 3's (Skeleton Warrior) arrow hits the player's arrow, it stops it and they both disappear.
  if levelvalue<5 then goto skipblockfire
  if r3x_fire<>200 && boxcollision(xpos_fire,ypos_fire, 2,2, r3x_fire,r3y_fire, 4,4) then r3x_fire=200:xpos_fire=200
skipblockfire

  rem ** if your skill<4 then you are not on the Expert skill level. Skip large arrows.
  if skill<4 then goto skiplargearrows
  if r1x_fire<>200 && boxcollision(xpos_fire,ypos_fire, 2,2, r1x_fire,r1y_fire, 4,4) then r1x_fire=200:xpos_fire=200
  if r2x_fire<>200 && boxcollision(xpos_fire,ypos_fire, 2,2, r2x_fire,r2y_fire, 4,4) then r2x_fire=200:xpos_fire=200
  if r3x_fire<>200 && boxcollision(xpos_fire,ypos_fire, 2,2, r3x_fire,r3y_fire, 4,4) then r3x_fire=200:xpos_fire=200
skiplargearrows

  rem ** Collision code for the player picking up the quiver to get more arrows
  if quadframe=2 && quiverx<>200 && boxcollision(p0_x,p0_y, 5,16, quiverx,quivery, 8,8) then arrowspeakflag=0:gosub grab_arrows:gosub pickupsound:gosub gotarrowsspeak 

  rem ** Collision code for the player's arrows hitting the bats or the spider
  if spiderdeathframe=4 && spiderdeathflag=1 then spiderdeathflag=0:xpos_fire=200:ypos_fire=208:gosub spiderrespawn
  if bat1deathframe=3 && bat1deathflag=1 then bat1deathflag=0:xpos_fire=200:ypos_fire=208:gosub bat1respawn
  if bat2deathframe=3 && bat2deathflag=1 then bat2deathflag=0:xpos_fire=200:ypos_fire=208:gosub bat2respawn

  rem ** Skip both bats on level 5, one bat on level 4
  if wizmode>0 then goto skipshootbats
  if levelvalue=5 then goto skip2bats
  if levelvalue=4 then goto skip1bat

  if boxcollision(xpos_fire,ypos_fire, 2,2, bat1x,bat1y, 5,8) then slowdown_bat1=0:bat1deathframe=0:bat1deathflag=1:score0=score0+000300:xpos_fire=208:ypos_fire=208:playsfx sfx_batdeath
skip1bat
  if boxcollision(xpos_fire,ypos_fire, 2,2, bat2x,bat2y, 5,8) then slowdown_bat2=0:bat2deathframe=0:bat2deathflag=1:score0=score0+000300:xpos_fire=208:ypos_fire=208:playsfx sfx_batdeath
skip2bats
  if spiderdeathflag=1 then goto skipshootbats :rem (v174)
  if altframe=1 && boxcollision(xpos_fire,ypos_fire, 2,2, spiderx,spidery, 8,16) then slowdown_spider=0:spiderdeathframe=0:spiderdeathflag=1:score0=score0+000200:xpos_fire=208:ypos_fire=208:spiderwebcountdown=0:playsfx sfx_spiderdeath
skipshootbats

  rem ** Collision code for the player running into the bat or spider and freezing

  rem ** you can't be frozen in god mode or while death animation is running
  if godvalue=2 ||invincible_on=1 then goto skipcoll
  if playerdeathflag=1 then goto skipcoll

  rem ** if wizard mode is active, skipp collision detection with bats & spiders.  They aren't on screen anyway.
  if wizmode>0 then goto skipcoll

  rem ** if levelvalue is 5, skip collisions with both bats.  They aren't on the screen.
  if levelvalue=5 then goto skipbatcollision2

  rem ** if the levelvalue is 4, skip collision with the first bat.  It isn't on the screen.
  if levelvalue=4 then goto skipbatcollision1

  rem ** Collision detection with bats & spider
  if altframe=0 && boxcollision(p0_x,p0_y, 5,16, bat1x,bat1y, 5,8) then gosub bat1respawn:freezecount=0:freezeflag=1
skipbatcollision1
  if altframe=1 && boxcollision(p0_x,p0_y, 5,16, bat2x,bat2y, 5,8) then gosub bat2respawn:freezecount=0:freezeflag=1
skipbatcollision2
  if altframe=1 && boxcollision(p0_x,p0_y, 5,16, spiderx,spidery, 8,16) then gosub spiderhit:spiderx=8:spidery=35:freezecount=0:freezeflag=1:spiderwebcountdown=0
skipcoll

  rem ** finally done!  Jump back to the start of the main loop.
  goto main

  rem <---- End of main game loop ---->

pickupsound
   if wizmode=0 || wizmode=200 then playsfx sfx_pickup
   return
spiderhit

  rem ** the spider will steal an arrow if it hits you
  if arrowcounter>0 then arrowcounter=arrowcounter-1
  return

  rem ** Enemies will always respawn on the opposite side of the screen from you
  rem ** this is to avoid an enemy respawning directly on top of your current location in the dungeon
monster1respawn
  if p0_x<84 then monster1x=150:monster1y=144
  if p0_x>83 then monster1x=8:monster1y=144
  r1hp=1
  return
monster2respawn
  if demomode=1 then monster2x=150:monster2y=140:return
  if p0_x<84 then monster2x=150:monster2y=140
  if p0_x>83 then monster2x=12:monster2y=144
  r2hp=1
  return
monster3respawn
  if p0_x<84 then monster3x=150:monster3y=136
  if p0_x>83 then monster3x=16:monster3y=144
  r3hp=1
  return

  rem ** Reduce Enemy hitpoints
r1hit
  if r1hp>0 then r1hp=r1hp-1
  if r1hp=0 then monster1_shieldflag=0 else monster1_shieldflag=1
  return
r2hit
  if r2hp>0 then r2hp=r2hp-1
  if r2hp=0 then monster2_shieldflag=0 else monster2_shieldflag=1
  return
r3hit
  if r3hp>0 then r3hp=r3hp-1
  if r3hp=0 then monster3_shieldflag=0 else monster3_shieldflag=1
  return

doeachmonsterfiring

  rem ** rem conditions upon which we fire a new enemy arrow
  if playerinvisibletime>0 then goto skip_r1fire
  if enemy1deathflag[temploop]=1 then goto skip_r1fire

dowizfiring

  rem ** Enemy arrow is in-use. Skip shooting.
  if r1x_fire[temploop]<>200 then goto skip_r1fire

  rem ** determine if the player is "close" to the enemy vertically
  temp2=p0_y-15 : rem ** the minimum y
  temp3=p0_y+32 : rem ** the maximum y
  if tempy<temp2 || tempy>temp3 then goto skiphorizontalmonstshot
  if tempx<p0_x then r1_fire_dir[temploop]=3 else r1_fire_dir[temploop]=1
  goto monstshotdone

skiphorizontalmonstshot
  rem ** determine if the player is "close" to the enemy horizontally
  temp2=p0_x-8  : rem ** the minimum x
  temp3=p0_x+16 : rem ** the maximum x
  if tempx<temp2 || tempx>temp3 then goto skip_r1fire
  if tempy<p0_y then r1_fire_dir[temploop]=2 else r1_fire_dir[temploop]=0
monstshotdone
  r1x_fire[temploop]=monster1x[temploop]+4: r1y_fire[temploop]=monster1y[temploop]+8
  newfire1[temploop]=1

skip_r1fire

  reloop=0
doreloop
  rem ** play the enemy arrow firing sound

  rem ** if arrow is in flight, move it
  temp1=1
  temp2=framecounter&1
  if wizmode=200 && temp2=1 && levelvalue=3 then temp1=2
  if wizmode=200 && levelvalue>3 then temp1=2
  if r1_fire_dir[temploop]=0 then r1y_fire[temploop]=r1y_fire[temploop]-temp1:goto monsterquivermovedone
  if r1_fire_dir[temploop]=1 then r1x_fire[temploop]=r1x_fire[temploop]-temp1:goto monsterquivermovedone
  if r1_fire_dir[temploop]=2 then r1y_fire[temploop]=r1y_fire[temploop]+temp1:goto monsterquivermovedone
  if r1_fire_dir[temploop]=3 then r1x_fire[temploop]=r1x_fire[temploop]+temp1
monsterquivermovedone
  rem if frame&1 && reloop<>1 then reloop=1:goto doreloop: rem speed it up

  if newfire1[temploop]>0 then newfire1[temploop]=newfire1[temploop]+1

  rem ** stop the arrow if it hits the screen edges
  if r1x_fire[temploop]>158 then r1x_fire[temploop]=200
  if r1x_fire[temploop]<2   then r1x_fire[temploop]=200
  if r1y_fire[temploop]>192 then r1x_fire[temploop]=200
  if r1y_fire[temploop]<2   then r1x_fire[temploop]=200

  rem if wizmode=200 && levelvalue>2 then goto skipwallcollision
  rem ** stop the arrow if it's not over a blank space...
  r1x_temp0=r1x_fire[temploop]/4
  r1y_temp0=r1y_fire[temploop]/8
  r1_tempchar0=peekchar(screenram,r1x_temp0,r1y_temp0,40,28)
  if r1_tempchar0>=spw1 && r1_tempchar0<=spw4 then r1_tempchar0=$41
  if r1_tempchar0>=spw1 && r1_tempchar0<=spw4 then r1_tempchar0=$41
  if r1_tempchar0<>$41 then r1x_fire[temploop]=200

skipwallcollision

  if r1x_fire[temploop]=200 then newfire1[temploop]=0

  if r1_fire_dir[temploop]=0 || r1_fire_dir[temploop]=2 then temp1=10 else temp1=6

  if newfire1[temploop]<>temp1 then skip_r1fire2
  newfire1[temploop]=0
  rem if demomode=1 then skip_r1fire2
  if wizmode=0 || wizmode=200 then playsfx sfx_enemy_shoot

skip_r1fire2

  rem <---- End arrow firing code for Enemies ---->

  return

displaymonstersprite

  rem ** Animation Frames for Enemies
  rem ** Two 8x8 sprites stitched together top/bottom

  tempx=monster1x[temploop]
  temptype=monster1type[temploop]
  if tempx=200 || temptype=255 then a=a:return : rem a=a to workaround a 7800basic bug. to-be-fixed soon.
  tempy=monster1y[temploop]

  if enemy1deathflag[temploop]=1 then goto explodemonster

  if wizmode>0 then goto skipmonsterdisplay
  tempanim=monster1animationframe[temploop]

  if temptype=1 then goto displaymonster1
  if temptype=3 then goto displaymonster3
  if temptype=5 then goto displaymonster5
skipmonsterdisplay
  return

  rem ** Plot the monster sprites on the screen
  rem ** The color of the sprite depends on the hitpoints of the enemy.

  rem ** Enemy type 1...Demon Bat
displaymonster1
  if monster1_shieldflag=0 then plotsprite monster1top 1 tempx tempy tempanim
  if monster1_shieldflag=1 then plotsprite monster1top 6 tempx tempy tempanim
  tempy=tempy+8
  if monster1_shieldflag=0 then plotsprite monster1bottom 1 tempx tempy tempanim
  if monster1_shieldflag=1 then plotsprite monster1bottom 6 tempx tempy tempanim
  return

  rem ** Enemy type 3...Snake
displaymonster3
  if monster2_shieldflag=0 then plotsprite monster3top 1 tempx tempy tempanim
  if monster2_shieldflag=1 then plotsprite monster3top 3 tempx tempy tempanim
  tempy=tempy+8
  if monster2_shieldflag=0 then plotsprite monster3bottom 1 tempx tempy tempanim
  if monster2_shieldflag=1 then plotsprite monster3bottom 3 tempx tempy tempanim
  return

  rem ** Enemy type 5...Skeleton Warrior
displaymonster5
  if monster3_shieldflag=0 then plotsprite monster5top 1 tempx tempy tempanim
  if monster3_shieldflag=1 then plotsprite monster5top 5 tempx tempy tempanim
  tempy=tempy+8
  if monster3_shieldflag=0 then plotsprite monster5bottom 1 tempx tempy tempanim
  if monster3_shieldflag=1 then plotsprite monster5bottom 5 tempx tempy tempanim
  return

explodemonster
  tempexplodeframe=explodeframe1[temploop]
  rem ** Animation Frames for Enemy Explosion
  rem ** Two 8x8 sprites stitched together top/bottom
explodesprites
  plotsprite explode1top explosioncolor tempx tempy tempexplodeframe
  tempy=tempy+8
  plotsprite explode1bottom explosioncolor tempx tempy tempexplodeframe
  return

plotwizexplode
  tempexplodeframe=wizmodeover/4
  if tempexplodeframe>7 then return
  tempx=wizx
  tempy=wizy
  goto explodesprites

  rem ** respawn bat 1 at one of 8 pre-determined locations in the dungeon.
bat1respawn
  bat1respawn = (rand&7) + 1
  if bat1respawn=1 then bat1x=84:bat1y=20
  if bat1respawn=2 then bat1x=54:bat1y=54
  if bat1respawn=3 then bat1x=84:bat1y=146
  if bat1respawn=4 then bat1x=54:bat1y=176 
  if bat1respawn=5 then bat1x=150:bat1y=116
  if bat1respawn=6 then bat1x=22:bat1y=146
  if bat1respawn=7 then bat1x=120:bat1y=54
  if bat1respawn=8 then bat1x=133:bat1y=20
  if p0_x<84 && bat1x<84 then goto bat1respawn
  if p0_x>83 && bat1x>83 then goto bat1respawn
  return

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 0

  rem ** respawn bat 2 at one of 8 pre-determined locations in the dungeon.
bat2respawn
  bat2respawn = (rand&7) + 1
  if bat2respawn=8 then bat2x=84:bat2y=20
  if bat2respawn=7 then bat2x=54:bat2y=54  
  if bat2respawn=6 then bat2x=84:bat2y=146
  if bat2respawn=5 then bat2x=54:bat2y=176 
  if bat2respawn=4 then bat2x=150:bat2y=116
  if bat2respawn=3 then bat2x=22:bat2y=146
  if bat2respawn=2 then bat2x=120:bat2y=54
  if bat2respawn=1 then bat2x=133:bat2y=20
  if p0_x<84 && bat2x<84 then goto bat2respawn
  if p0_x>83 && bat2x>83 then goto bat2respawn
  return

spiderrespawn
  rem ** duplicate entry for spider respawning in the web (2/8 chance)
  spiderrespawn = (rand&7) + 1
  if spiderrespawn=1 then spiderx=6:spidery=22    :rem Keep
  if spiderrespawn=2 then spiderx=6:spidery=148   :rem Keep
  if spiderrespawn=3 then spiderx=120:spidery=148 :rem Keep
  if spiderrespawn=4 then spiderx=134:spidery=20  :rem 150/60 removed
  if spiderrespawn=5 then spiderx=120:spidery=116 :rem Keep
  if spiderrespawn=6 then spiderx=134:spidery=176 :rem 132/82 removed
  if spiderrespawn=7 then spiderx=22:spidery=176  :rem 22/84 removed
  if spiderrespawn=8 then spiderx=38:spidery=20   :rem 6/22 removed
  if p0_x<84 && spiderx<84 then goto spiderrespawn
  if p0_x>83 && spiderx>83 then goto spiderrespawn
  return

  rem ** random amount of arrows you get when you pick up a quiver
  rem ** it will be between 5 and 8 each time
grab_arrows
  arrowrand = (rand&7) + 1
  if arrowrand<5 then goto grab_arrows
  arrowcounter=arrowrand

  rem ** for developer mode, make sure arrow count isn't higher than the maximum allowed
checkmax
  if arrowcounter>arrowsvalue then arrowcounter=arrowcounter-1:goto checkmax
  return

webflicker
  if (frame&7)>0 then return
  if tempchar1>=spw1 && tempchar1<=spw4 then tempchar1=$41
  if tempchar2>=spw1 && tempchar2<=spw4 then tempchar2=$41
  return

  rem ** Movement Check Routines
 
  rem ** Note:
  rem      -The peekchar command is used to look up what value character is at a particular character position in a character map.

checkmovedown
   if p0_y>174 then p0_dy=0:return
   temp0_x=p0_x/4
   temp0_y=(p0_y+15)/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_x=(p0_x+3)/4
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)
   gosub webflicker 
   if tempchar1=$41 && tempchar2=$41 then p0_dy=1:return
   rem ** the next two lines make the player slide around obstacles 
   if tempchar1>=spw1 || tempchar2>=spw1 then return

   if tempchar1=$41 then p0_dx=255:return
   if tempchar2=$41 then p0_dx=1:return
   return

checkmoveup
   if p0_y<8 then p0_dy=0:return
   temp0_x=p0_x/4
   temp0_y=p0_y/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_x=(p0_x+3)/4
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)
   gosub webflicker 
   if tempchar1=$41 && tempchar2=$41 then p0_dy=255:return
   if tempchar1>=spw1 || tempchar2>=spw1 then return
   rem ** the next two lines make the player slide around obstacles 
   if tempchar1=$41 then p0_dx=255:return
   if tempchar2=$41 then p0_dx=1:return
   return

checkmoveleft
   if p0_x<4 then p0_dx=0:return
   temp0_x=(p0_x-1)/4
   temp0_y=(p0_y+1)/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_y=(p0_y+14)/8
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)
   gosub webflicker 
   if tempchar1=$41 && tempchar2=$41 then p0_dx=255:return
   if tempchar1>=spw1 || tempchar2>=spw1 then return
   rem ** the next two lines make the player slide around obstacles 
   if tempchar1=$41 then p0_dy=255:return
   if tempchar2=$41 then p0_dy=1:return
   return

checkmoveright
   if p0_x>152 then p0_dx=0:return
   temp0_x=(p0_x+4)/4
   temp0_y=(p0_y+1)/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_y=(p0_y+14)/8
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)
   gosub webflicker 
   if tempchar1=$41 && tempchar2=$41 then p0_dx=1:return
   if tempchar1>=spw1 || tempchar2>=spw1 then return
   rem ** the next two lines make the player slide around obstacles 
   if tempchar1=$41 then p0_dy=255:return
   if tempchar2=$41 then p0_dy=1:return
   return

monstlogic
   rem ** where Enemies decide which way to move, if they should shoot, which direction, etc...

   temppositionadjust=0
   for temploop=0 to 2

      tempx=monster1x[temploop]
      tempy=monster1y[temploop]
      tempdir=monster1dir[temploop]
      temptype=monster1type[temploop] : rem ** for later, in case we decide to modify the behavior based on Enemy type
      templogiccountdown=monster1changecountdown[temploop]
      if temptype=255 then goto skiplogic

      rem ** MINOR WITCHCRAFT AHEAD...
      rem ** data driven monster speed routine
      rem ** we only move when adding the level speed to the monster's slow
      rem ** variable and it exceeds 255, as detected by CARRY. This allows
      rem ** the monster to move a fractional amount of frames...
      temp1=(temptype*2)+levelspeeds[levelvalue]
      monst1slow[temploop]=monst1slow[temploop]+temp1
      if !CARRY then goto skipnonfiringstuff

      gosub doeachmonsterlogic
      gosub doeachmonstermove

      rem ** stuff tempx, tempy, and tempdir back into the actual Enemy variables
      monster1x[temploop]=tempx
      monster1y[temploop]=tempy
      monster1dir[temploop]=tempdir
      monster1changecountdown[temploop]=templogiccountdown

skipnonfiringstuff
      rem ** check to see if shooting an arrow is required, do position updates
      gosub doeachmonsterfiring
skiplogic
   next
   return

   rem ** base speeds for Enemies. # out of 255 frames.
   data levelspeeds
   00,90,100,105,110,110
end

doeachmonsterlogic
   rem ** we use 255 as a flag that an Enemy isn't moving yet. pick a random direction.
   if tempdir=255 then tempdir=rand&3

   if templogiccountdown>0 then templogiccountdown=templogiccountdown-1
   olddir=tempdir

   rem ** notes on monster direction encoding
   rem ** directions are encoded as "up(0) left(1) down(2) right(3)"
   rem ** given a direction index, the opposite direction is always (d+2)&3
   rem ** given a direction index, the adjacent directions are always (d+1)&3 and (d+3)&3

   rem ** check if the current direction is free of obstacles
   on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright
   if obstacleseen>0 then goto monstercantmoveforward

   rem ** the big blank area in the spider web confuses the side-corridor logic
   if tempx<28 && tempy<60 then templogiccountdown=120:return

   rem ** the Enemy side-corridored recently. skip it.
   if templogiccountdown>0 then return

   temp9=rand

   rem ** we can still go forward, but let's check for side corridors.
   if rand<127 then tempdir=(tempdir+1)&3 else tempdir=(tempdir+3)&3

   rem ** check if that direction is free of obstacles.
   on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright
   if obstacleseen>0 then skipmonstdirchange1
       goto advancedmonstbranchlogic
       if olddir<>tempdir then return
skipmonstdirchange1

   rem ** the previous sideways turn failed. turn the other way.
   tempdir=(tempdir+2)&3
   rem ** check if that direction is free of obstacles.
   on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright
   if obstacleseen>0 then skipmonstdirchange2

       goto advancedmonstbranchlogic
skipmonstdirchange2
   rem ** carry on forward
   tempdir=olddir
   return

advancedmonstbranchlogic
   rem ** directions are encoded as "up(0) left(1) down(2) right(3)"
   templogiccountdown=60
   temp9=rand
   if temptype=1 && rand<127 then tempdir=olddir : rem ** %50 chance to go down this fork
   if temptype=1 then return

   rem ** if the direction change would take us further from the player, cancel it
   if tempdir=0 && tempy<p0_y then tempdir=olddir
   if tempdir=1 && tempx<p0_x then tempdir=olddir
   if tempdir=2 && tempy>p0_y then tempdir=olddir
   if tempdir=3 && tempy>p0_x then tempdir=olddir
   return

monstercantmoveforward

   rem ** if not, try turning left or right.
   temp9=rand:rem grab a new rand.
   if rand<127 then tempdir=(tempdir+1)&3 else tempdir=(tempdir+3)&3

   rem ** check if that direction is free of obstacles.
   on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright
   if obstacleseen=0 then return

   rem ** the previous sideways turn failed. turn the other way.
   tempdir=(tempdir+2)&3
   rem ** check if that direction is free of obstacles.
   on tempdir gosub checkmonstmoveup checkmonstmoveleft checkmonstmovedown checkmonstmoveright
   if obstacleseen=0 then return

   rem ** we must be stuck in a dead-end. turn around based on the original direction.
   tempdir=(olddir+2)&3
   return

titlescreen

  characterset atascii
  alphachars ASCII
  clearscreen
  AUDV0=0:AUDV1=0
  drawwait

  rem ** initial placement of grey highlight bar for menu selections
  menubarx=40
  menubary=128

  rem ** set countdown time for switching to demo mode, set initial value for demo mode to off
  demomodecountdown=5
  demomode=0
 
  rem Say "Dungeon Stalker" when you enter the titlescreen
  speak intro

hiscorereturn

  rem ** joystick debounce variable
  if joy0fire then fireheld=1

  rem ** titlescreen background is black
  SBACKGRND=$00

  rem ** dark yellow (dots at top of graphic)
  P0C1=0
  P0C2=$16
  P0C3=0

  rem ** dark blue (copyright and background) 
  P1C1=0
  P1C2=$92
  P1C3=0

  rem ** White (menu text)
  P2C1=0
  P2C2=$08
  P2C3=0

  rem ** Blue (Dungeon Stalker title) 
  P3C1=0
  P3C2=$84
  P3C3=0

  rem ** light Grey (menu selection bar)
  P4C1=0
  P4C2=$04
  P4C3=0

  rem ** blue text
  P5C1=0
  P5C2=$96
  P5C3=0

  rem ** Can you guess the color for $82? :)
  P6C1=0
  P6C2=$82
  P6C3=0

  rem ** Red (background behind the titlescreen graphic text) 
  P7C1=0
  P7C2=$40
  P7C3=0

  rem ** This command erases all sprites and characters that you've previously drawn on the screen, so you can draw the next screen.
  clearscreen

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 2

  rem ** this plots the background behind the titlescreen graphic text
  plotsprite ts_back1 7 16 52
  plotsprite ts_back2 7 16 60
  plotsprite ts_back3 7 16 68
  plotsprite ts_back4 7 16 76
  plotsprite ts_back5 7 16 84
  plotsprite ts_back6 7 16 92
  plotsprite ts_back7 7 16 100

  rem ** This creates the dots at the top of the titlescreen graphic
  plotsprite ts_back_ruby 6 16 38

  rem ** this plots the titlescreen graphic, which is 256x128, split into 8 pixel tall sprites
  rem ** (changed to a banner)
  plotbanner tsbanner 3 16 4

  rem ** The savescreen command saves any sprites and characters that you've drawn on the screen since the last clearscreen.
  savescreen

titlescreen2 

  rem ** beats me.  This code makes no sense. :)
  if skill<>4 then goto devcheckdone
  rem ** Enable dev mode.  It's a super secret entry code. It enables the holy grail of game options.
  rem ** If you've read this much of the code already I bet you can figure it out! :)
  if devmodecount=$ff then goto devcheckdone : rem ** code entry is disabled.
  temp1=SWCHA|$0f: rem ** set temp variable to read joystick position
  if temp1=savejoy then goto devcheckdone : rem ** debounce
  savejoy=temp1: rem ** set savejoy to equal temp1
  if savejoy=$ff then goto devcheckdone : rem ** neutral position
  if savejoy<>devmodecode[devmodecount] then devmodecount=$ff : goto devcheckdone : rem ** wrong code. disable code entry after 1 attempt.
  devmodecount=(devmodecount+1)&7: rem ** hmmmm, what does this do? ;)
  if devmodecount=0 then devmodeenabled=1: rem ** this must enable something?
devcheckdone

  rem ** enter developer mode
  if devmodeenabled=1 && joy0fire then playsfx sfx_wizwarp:gamemode=1

  rem ** don't allow skill value to be out of range
  rem ** if it is, set the skill level to the standard difficulty setting
  if skill<1 then skill=2
  if skill>4 then skill=2

  rem ** The restorescreen erases any sprites and characters that you've drawn on the screen since the last savescreen.
  restorescreen

  rem ** this makes the dots on the titlescreen image flash.  They are supposed to look like gems.
  colorflasher=colorflasher+$02:if colorflasher>$FE then colorflasher=$00
  P6C2=colorflasher

  rem ** plot the background sprite for highlighting the current menu option
  plotsprite menuback1 4 menubarx menubary 

  rem ** plot the menu values based on current selection

  rem ** if gamemode=1 then developer mode is activated.  Skip the normal menu.
  if gamemode=1 then goto skipnormalmenu
 
  rem ** Skill Levels
  rem      skill 1 = Novice
  rem      skill 2 = Standard
  rem      skill 3 = Advanced
  rem      skill 4 = Expert

  rem ** Note that '?' was changed to a left arrow and '@' was changed to a right arrow in a customized atascii.png
  rem **   Also, '=' was changed to a dot.
  if skill=1 then plotchars 'Skill      ?Novice>' 2 42 16:gamedifficulty=0:plotchars '=Novice High Scores' 2 42 17
  if skill=2 then plotchars 'Skill      <Standard>' 2 42 16:gamedifficulty=1:plotchars '=Standard High Scores' 2 42 17
  if skill=3 then plotchars 'Skill      <Advanced>' 2 42 16:gamedifficulty=2:plotchars '=Advanced High Scores' 2 42 17
  if skill=4 then plotchars 'Skill      <Expert@' 2 42 16:gamedifficulty=3:plotchars '=Expert High Scores' 2 42 17
  plotchars '=Start Game' 2 42 18

  rem ** plot current and best score text on title screen
  plotchars 'Current Score:' 5 44 21
  plotvalue atascii 2 score1 6 101 21
  plotchars 'Best Score:' 5 50 23
  plotvalue atascii 2 score0 6 95 23

skipnormalmenu

  rem ** skip developer mode menu options if dev mode is not activated
  if gamemode=0 then goto skipmenu

  rem ** Developer Mode Menu.  It's super secret.  No one will ever find it. :)
  rem **  ...developer mode is undocumented in the instruction manual
  rem **  ...if it's active, high scores will not be saved
                        
  plotchars '<Exit Developer Mode>' 2 42 16
  plotchars '=Start Game' 2 42 23
  plotchars ' Developer' 5 38 1
  plotchars 'Mode Active' 5 87 1

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 1

  rem ** plot the dev mode menu
  if speedvalue=1 then plotchars 'Speed      <Normal@' 2 42 17:speedvalue=1:rem 136
  if speedvalue=2 then plotchars 'Speed      ?Fast>' 2 42 17:speedvalue=2

  if levelvalue=1 then plotchars 'Level      ?1>' 2 42 18
  if levelvalue=2 then plotchars 'Level      <2>' 2 42 18
  if levelvalue=3 then plotchars 'Level      <3>' 2 42 18
  if levelvalue=4 then plotchars 'Level      <4>' 2 42 18
  if levelvalue=5 then plotchars 'Level      <5@' 2 42 18

  if godvalue=1 then plotchars 'God Mode   ?Off>' 2 42 21:godvalue=1:rem 168
  if godvalue=2 then plotchars 'God Mode   <On@' 2 42 21:godvalue=2

  if livesvalue=1 then plotchars 'Lives      ?1>' 2 42 20:rem 160
  if livesvalue=2 then plotchars 'Lives      <2>' 2 42 20
  if livesvalue=3 then plotchars 'Lives      <3>' 2 42 20
  if livesvalue=4 then plotchars 'Lives      <4>' 2 42 20
  if livesvalue=5 then plotchars 'Lives      <5>' 2 42 20
  if livesvalue=6 then plotchars 'Lives      <6>' 2 42 20
  if livesvalue=7 then plotchars 'Lives      <7>' 2 42 20
  if livesvalue=8 then plotchars 'Lives      <8>' 2 42 20
  if livesvalue=9 then plotchars 'Lives      <9@' 2 42 20

  if arrowsvalue=1 then plotchars 'Max Arrows ?1>' 2 42 19:rem 152
  if arrowsvalue=2 then plotchars 'Max Arrows <2>' 2 42 19
  if arrowsvalue=3 then plotchars 'Max Arrows <3>' 2 42 19
  if arrowsvalue=4 then plotchars 'Max Arrows <4>' 2 42 19

  if arrowsvalue=5 then plotchars 'Max Arrows <5>' 2 42 19
  if arrowsvalue=6 then plotchars 'Max Arrows <6>' 2 42 19
  if arrowsvalue=7 then plotchars 'Max Arrows <7>' 2 42 19
  if arrowsvalue=8 then plotchars 'Max Arrows <8>' 2 42 19
  if arrowsvalue=9 then plotchars 'Max Arrows <No Max@' 2 42 19

skipmenu

  if scorevalue=1 && gamemode=1 then plotchars 'Score      ?00000>' 2 42 22
  if scorevalue=2 && gamemode=1 then plotchars 'Score      ?07400>' 2 42 22
  if scorevalue=3 && gamemode=1 then plotchars 'Score      ?14900>' 2 42 22
  if scorevalue=4 && gamemode=1 then plotchars 'Score      ?29900>' 2 42 22
  if scorevalue=5 && gamemode=1 then plotchars 'Score      <59900@' 2 42 22

  rem ** enter the current score and high score data into the score0 and score1 variables
  sc1=High_Score01:sc2=High_Score02:sc3=High_Score03 
  sc4=Save_Score01:sc5=Save_Score02:sc6=Save_Score03

skipscoredisplay

  rem ** Note that 23 is the last visible line to plot characters

  rem ** debounce routine for pressing fire to exit the titlescreen
  if fireheld=1 && !joy0fire then fireheld=0

  rem ** start the game if you're on the 'start game' menu line and press the fire button
  rem ** there are two entries due to the fact that the start game line is on a different Y coordinate in dev mode
  if gamemode=0 && fireheld=0 && joy0fire && menubary=144 then goto preinit
  if gamemode=1 && fireheld=0 && joy0fire && menubary>179 then goto preinit

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 3

  rem ** return from demo mode to the titlescreen if you press the fire button
  if joy0fire && gamemode=0 && menubary=136 && fireheld=0 then drawwait:drawhiscores attract:goto hiscorereturn

  rem ** Code to move around the menu

  rem ** moving up and down on the standard menu
  if gamemode=0 && joy0down && menubary<140 then gosub menumovedown
  if gamemode=0 && joy0up && menubary>132 then gosub menumoveup

  rem ** moving up and down on the developer mode menu
  if gamemode=1 && joy0down && menubary<181 then gosub menumovedown
  if gamemode=1 && joy0up && menubary>132 then gosub menumoveup

  rem ** moving left and right on the skill select menu option
  if menubary=128 && skill<4 && joy0right then gosub skillselectright
  if menubary=128 && skill>1 && joy0left then gosub skillselectleft

  if gamemode=1 && menubary=128 && joy0left then gamemode=0:skill=2:menubary=136:devmodeenabled=0
  if gamemode=1 && menubary=128 && joy0right then gamemode=0:skill=2:menubary=136:devmodeenabled=0

  rem ** skip all the menu navigation options for dev mode if you're in standard mode
  if gamemode=0 then goto skipcustommenu

  rem <--- Start Developer mode menu selection code --->

  if menubary=136 && joy0right then gosub speedselect
  if menubary=136 && joy0left then gosub speedselect

  if menubary=144 && levelvalue<5 && joy0right then gosub levelmoveright
  if menubary=144 && levelvalue>1 && joy0left then gosub levelmoveleft

  if menubary=152 && arrowsvalue<9 && joy0right then gosub arrowsmoveright
  if menubary=152 && arrowsvalue>1 && joy0left then gosub arrowsmoveleft

  if menubary=160 && livesvalue<9 && joy0right then gosub livesmoveright
  if menubary=160 && livesvalue>1 && joy0left then gosub livesmoveleft

  if menubary=168 && joy0right then gosub godselect
  if menubary=168 && joy0left then gosub godselect

  if menubary=176 && scorevalue<5 && joy0right then gosub scoreselectright
  if menubary=176 && scorevalue>1 && joy0left then gosub scoreselectleft

  rem <--- End Developer mode menu selection code --->

skipcustommenu

  drawscreen

  frame=frame+1
  if joy0any then demomodecountdown=8
  temp8=frame&63
  if temp8=0 then demomodecountdown=demomodecountdown-1
  if gamemode=0 && demomodecountdown=0 then demomode=1:demomodecountdown=18:drawwait:goto preinit

  goto titlescreen2

doeachmonstermove

  rem ** this will stop the Enemy when one is killed by an arrow
  if enemy1deathflag[temploop]=1 then goto skipmove1

  rem ** don't allow enemy movement or shooting while player death animation is running
  if playerdeathflag=1 then goto skipmove1

   rem "0 up  1 left  2 down  3 right"
   if tempdir=0 then tempy=tempy-1
   if tempdir=1 then tempx=tempx-1
   if tempdir=2 then tempy=tempy+1
   if tempdir=3 then tempx=tempx+1
skipmove1

   return

checkmonstmoveup
   rem ** the monster looks to see if he can move up...
   if tempy<8 then obstacleseen=1:return : rem don't let him move above the top row

   rem ** 1. pick 2 points above the enemy, spaced the width of a corridor.
   rem ** 2. convert the sprite coordinates to character coordinates.
   rem ** 3. lookup the characters. If both aren't spaces, the path up is blocked.

   rem ** convert to character coordinates...
   temp0_x=(tempx-temppositionadjust)/4
   temp0_y=(tempy-1)/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_x=(tempx+7-temppositionadjust)/4
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)

   if tempchar1>=spw1 && tempchar1<=spw4 then tempchar1=$41
   if tempchar2>=spw1 && tempchar2<=spw4 then tempchar2=$41

   rem ** for now we just check for blank=$41...
   if tempchar1=$41 && tempchar2=$41 then obstacleseen=0:return

   rem ** any other situation is a barrier to the monster...
   obstacleseen=1
   return

checkmonstmovedown
   rem ** the monster looks to see if he can move down...
   if tempy>199 then obstacleseen=1:return : rem don't let him move beyond the last row

   rem ** 1. pick 2 points below the monster, spaced the width of a corridor.
   rem ** 2. convert the sprite coordinates to character coordinates.
   rem ** 3. lookup the characters. If both aren't spaces, the path down is blocked.

   temp0_x=(tempx-temppositionadjust)/4
   temp0_y=(tempy+16)/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_x=(tempx+7-temppositionadjust)/4
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)

   if tempchar1>=spw1 && tempchar1<=spw4 then tempchar1=$41
   if tempchar2>=spw1 && tempchar2<=spw4 then tempchar2=$41

   rem ** for now we just check for blank=$41...
   if tempchar1=$41 && tempchar2=$41 then obstacleseen=0:return

   rem ** any other tile is a barrier to the enemy...
   obstacleseen=1
   return

checkmonstmoveleft
   rem ** the enemy looks to see if he can move left...
   if tempx<4 then obstacleseen=1:return : rem don't let him move before the first column

   rem ** 1. pick 2 points to the left of the monster, spaced the height of a corridor.
   rem ** 2. convert the sprite coordinates to character coordinates.
   rem ** 3. lookup the characters. If both aren't spaces, the path left is blocked

   temp0_x=(tempx-1-temppositionadjust)/4
   temp0_y=tempy/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_y=(tempy+15)/8
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)

   if tempchar1>=spw1 && tempchar1<=spw4 then tempchar1=$41
   if tempchar2>=spw1 && tempchar2<=spw4 then tempchar2=$41

   rem ** for now we just check for blank=$41...
   if tempchar1=$41 && tempchar2=$41 then obstacleseen=0:return

   rem ** any other tile is a barrier to the monster...
   obstacleseen=1
   return

checkmonstmoveright
   rem ** the enemy looks to see if he can move right...
   if tempx>151 then obstacleseen=1:return : rem don't let him move beyond the last column

   rem ** pick a point in the middle of the monster, above him, and
   rem ** convert to character coordinates...
   temp0_x=(tempx+8-temppositionadjust)/4
   temp0_y=tempy/8
   tempchar1=peekchar(screenram,temp0_x,temp0_y,40,28)
   temp0_y=(tempy+15)/8
   tempchar2=peekchar(screenram,temp0_x,temp0_y,40,28)

   if tempchar1>=spw1 && tempchar1<=spw4 then tempchar1=$41
   if tempchar2>=spw1 && tempchar2<=spw4 then tempchar2=$41

   rem ** for now we just check for blank=$41...
   if tempchar1=$41 && tempchar2=$41 then obstacleseen=0:return

   rem ** any other tile is a barrier to the monster...
   obstacleseen=1
   return

spiderlogic
      temppositionadjust=0
      rem ** where spiders decide which way to move, if they should shoot, which direction, etc...

      rem ** our spider is making a web. skip moving entirely.
      rem ** the animation still runs even though the spider doesn't move
      if spiderwebcountdown>0 && skill<>1 then goto dospiderwebbing

      temploop=0
      tempx=spiderx
      tempy=spidery
      tempdir=spider_spider1dir
      temptype=1 : rem ** spider moves like a basic monster/monster
      templogiccountdown=spiderchangecountdown

      rem *** data driven monster speed routine...
      temp1=levelspeeds[levelvalue]
      spiderslow[temploop]=spiderslow[temploop]+temp1
      if !CARRY then return

      rem ** we reuse the monster logic routines for the spider
      gosub doeachmonsterlogic
skipspidermove

      gosub doeachspidermove

      rem ** stuff tempx, tempy, and tempdir back into the actual spider's variables...
      spiderx=tempx
      spidery=tempy
      spider_spider1dir=tempdir
      spiderchangecountdown=templogiccountdown
      if spiderx<28 && spidery<60 then return
      if (spiderx&3)=0 && (spidery&7)=0 then carryonspiderwalking
      return
carryonspiderwalking
      spiderwalkingsteps=spiderwalkingsteps+1
      if spiderwalkingsteps<76 then return
      tempx=tempx/4
      tempy=tempy/8
      tempchar2=peekchar(screenram,tempx,tempy,40,28)
      if tempchar2<>$41 then return
      spiderwalkingsteps=0
      if (rand&1)=0 then return
      spiderwebcountdown=255
   return

dospiderwebbing
      rem ** if the spider has walked enough, he creates a web.
      rem ** we do this by finding the characters at his x/y location
      rem ** and changing them to the spider web characters...
      spiderwebcountdown=spiderwebcountdown-1
      if spiderwebcountdown>0 then return
      tempx=spiderx/4
      tempy=spidery/8
      pokechar screenram tempx tempy 40 28 spw1
      tempx=tempx+1
      pokechar screenram tempx tempy 40 28 spw2
      tempy=tempy+1
      pokechar screenram tempx tempy 40 28 spw4
      tempx=tempx-1
      pokechar screenram tempx tempy 40 28 spw3
   return

doeachspidermove

  rem ** this will stop the eneny when one is killed by a arrow
  if playerdeathflag=1 then goto skipmove2

   rem "up left down right"
   if tempdir=0 then tempy=tempy-1:return
   if tempdir=1 then tempx=tempx-1:return
   if tempdir=2 then tempy=tempy+1:return
   if tempdir=3 then tempx=tempx+1:return
skipmove2
   return

wizlogic
      temploop=0
      temppositionadjust=0
      tempx=wizx 
      tempy=wizy 
      templogiccountdown=wizlogiccountdown
      tempdir=wizdir
      temptype=1
      gosub doeachmonsterlogic
      gosub dowizmove
      wizx=tempx
      wizy=tempy
      wizlogiccountdown=templogiccountdown
      wizdir=tempdir
      gosub dowizfiring
      return

batlogic
      if levelvalue=5 then return
      temppositionadjust=2

      rem ** where bats decide which way to move, which direction, etc...
      for temploop=0 to 1
      if levelvalue=4 then temploop=1
      tempx=bat1x[temploop]
      tempy=bat1y[temploop]
      templogiccountdown=bat1changecountdown[temploop]
      tempdir=bat_bat1dir[temploop]
      temptype=1

      rem *** data driven monster speed routine...
      temp1=levelspeeds[levelvalue]/2
      bat1slow[temploop]=bat1slow[temploop]+temp1
      if !CARRY then goto skiprestbatlogic

      gosub doeachmonsterlogic
      gosub doeachbatmove

      rem ** stuff tempx, tempy, and tempdir back into the actual bat's variables...
      bat1x[temploop]=tempx
      bat1y[temploop]=tempy
      bat1changecountdown[temploop]=templogiccountdown
      bat_bat1dir[temploop]=tempdir
skiprestbatlogic
      next : rem next bat...
  return

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 4

  rem ** include atarivox assembly code
  inline 7800vox.asm

doeachbatmove

  rem ** this will stop the monster when one is killed by a arrow
  if playerdeathflag=1 then goto skipmove3

dowizmove

   rem "up left down right"
   if tempdir=0 then tempy=tempy-1:return
   if tempdir=1 then tempx=tempx-1:return
   if tempdir=2 then tempy=tempy+1:return
   if tempdir=3 then tempx=tempx+1:return
skipmove3
   return

newscreen
   if screen=0 then memcpy screenram Dungeon 1120
   return

  rem <---- Debounce subs for moving the joystick around the menu options---->
 
menumovedown
  if !joy0down then menubary=menubary+8:playsfx sfx_menumove3:return
  drawscreen
  goto menumovedown

menumoveup
  if !joy0up then menubary=menubary-8:playsfx sfx_menumove3:return
  drawscreen
  goto menumoveup

skillselectright
  if !joy0right then skill=skill+1:playsfx sfx_menuselect:return
  goto skillselectright

skillselectleft
 if !joy0left then skill=skill-1:playsfx sfx_menuselect:return
  goto skillselectleft

scoreselectright
  if !joy0right then scorevalue=scorevalue+1:playsfx sfx_menuselect:return
  goto scoreselectright

scoreselectleft
 if !joy0left then scorevalue=scorevalue-1:playsfx sfx_menuselect:return
  goto scoreselectleft

speedselect
  if speedvalue=2 && joy0left then return
  if speedvalue=1 && joy0right then return
  if !joy0right then playsfx sfx_menuselect:speedvalue=2:return
  if !joy0left then playsfx sfx_menuselect:speedvalue=1:return
  goto speedselect

godselect
  if godvalue=1 && joy0left then return
  if godvalue=2 && joy0right then return
  if !joy0right then playsfx sfx_menuselect:godvalue=1:return
  if !joy0left then playsfx sfx_menuselect:godvalue=2:return
  goto godselect

colorselectright
 if !joy0right then colorvalue=colorvalue+1:playsfx sfx_menuselect:return
 goto colorselectright

colorselectleft
 if !joy0left then colorvalue=colorvalue-1:playsfx sfx_menuselect:return
 goto colorselectleft

levelmoveright
 if !joy0right then levelvalue=levelvalue+1:playsfx sfx_menuselect:return
 goto levelmoveright

levelmoveleft
 if !joy0left then levelvalue=levelvalue-1:playsfx sfx_menuselect:return
 goto levelmoveleft

livesmoveright
 if !joy0right then livesvalue=livesvalue+1:playsfx sfx_menuselect:return
 goto livesmoveright

livesmoveleft
 if !joy0left then livesvalue=livesvalue-1:playsfx sfx_menuselect:return
 goto livesmoveleft

arrowsmoveright
 if !joy0right then arrowsvalue=arrowsvalue+1:playsfx sfx_menuselect:return
 goto arrowsmoveright

arrowsmoveleft
 if !joy0left then arrowsvalue=arrowsvalue-1:playsfx sfx_menuselect:return
 goto arrowsmoveleft

  rem <----End debounce subs for moving the joystick around the menu options---->

preinit

  rem ** re-enable the pause feature
  pausedisable=0

  rem ** if using dev mode we don't want a skill level set
  if gamemode=1 then skill=0

  rem ** in standard game mode we always want to start the game with a score of 0
  if gamemode=0 then scorevalue=1

  score2flag=0:score3flag=0:score4flag=0:score5flag=0
  if skill=1 then arrowsvalue=9:speedvalue=1:levelvalue=1:livesvalue=6
  if skill=2 then arrowsvalue=8:speedvalue=1:levelvalue=1:livesvalue=5
  if skill=3 then arrowsvalue=7:speedvalue=1:levelvalue=2:livesvalue=4:score2flag=1
  if skill=4 then arrowsvalue=6:speedvalue=1:levelvalue=3:livesvalue=3:bunkerbuster=1:score2flag=1:score3flag=1

  rem ** this allows for switching back to the main loop when the fire button is released

  if joy0fire then fireheld=1

  if frame>0 then rand16=frame

  restorescreen
  drawscreen

  rem ** when the fire button is released, go to the init sub to start the game
  rem ** flags set to 0 so they don't transfer to the start of the game when quickly switching from demo mode to the real game.
  if !joy0fire then clearscreen:SBACKGRND=0:speak entering:freezeflag=0:playerdeathflag=0:quiverflag=0:AUDV0=0:AUDV1=0:goto init
  goto preinit

gameoverrestart
  rem ** This command erases all sprites and characters that you've previously drawn on the screen, so you can draw the next screen.
  clearscreen

  AUDV0=0:AUDV1=0
  rem ** this allows for switching back to the main loop when the fire button is released
  drawscreen
  if !joy0fire && gamemode=0 then drawwait:drawhiscores single:drawwait:goto titlescreen
  if !joy0fire && gamemode=1 then goto titlescreen
  goto gameoverrestart

  rem ** reduce life counter when the player dies
losealife
  if lifecounter>1 then gosub deathspeak
  if lifecounter=9 then lifecounter=8:return
  if lifecounter=8 then lifecounter=7:return
  if lifecounter=7 then lifecounter=6:return
  if lifecounter=6 then lifecounter=5:return
  if lifecounter=5 then lifecounter=4:return
  if lifecounter=4 then lifecounter=3:return
  if lifecounter=3 then lifecounter=2:return
  if lifecounter=2 then lifecounter=1:return
  rem v185
  if lifecounter=1 then lifecounter=0:gameoverflag=1:countdownseconds=1:speak gameover:return
 return

  rem ** increase life counter when you've picked up enough treasures to gain a life
  rem ** the maximum number of lives you can have is 9
gainalife
  if lifecounter=9 then lifecounter=9:return
  if lifecounter=8 then lifecounter=9:return
  if lifecounter=7 then lifecounter=8:return
  if lifecounter=6 then lifecounter=7:return
  if lifecounter=5 then lifecounter=6:return
  if lifecounter=4 then lifecounter=5:return
  if lifecounter=3 then lifecounter=4:return
  if lifecounter=2 then lifecounter=3:return
  if lifecounter=1 then lifecounter=2:return
 return

  rem ** The 7800 requires its graphics to be padded with zeroes. To avoid wasting ROM space with zeroes, 
  rem ** 7800basic uses a 7800 feature called holey DMA. This allows you to stick program code in 
  rem ** these areas between the graphics blocks that would otherwise be wasted with zeroes.
  rem ** Their placement has to be tweaked, only so much code can be stuffed in each hole,
  rem ** so you'll have to experiment with their location in your own code.
  dmahole 5

  rem <--- Start Audio Code --->

  rem ** the next very long section has all of the audio code for the game
  
 data sfx_enemy_shoot
  $10,$01,$03 ; version, priority, frames per chunk
  $18,$08,$01 ; first chunk of freq,channel,volume data 
  $19,$08,$05
  $19,$08,$05
  $19,$08,$05
  $19,$08,$05
  $1C,$08,$02
  $1C,$08,$02
  $1C,$08,$02
  $1C,$08,$02
  $1C,$08,$02
  $1E,$08,$01
  $1E,$08,$01
  $1E,$08,$01
  $1E,$08,$01
  $1E,$08,$01
  $00,$00,$00
end

 data sfx_player_shoot
  $10,$04,$01 ; version, priority, frames per chunk
  $06,$08,$06 ; first chunk of freq,channel,volume data 
  $06,$08,$06
  $06,$08,$06
  $05,$08,$05
  $05,$08,$05
  $05,$08,$05
  $04,$08,$04
  $04,$08,$04
  $03,$08,$03
  $03,$08,$03
  $02,$08,$01
  $01,$08,$01
  $01,$08,$01
  $00,$00,$00 
end

 data sfx_heartbeat
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$02 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat1
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$04 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat2
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$06 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat3
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$08 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat4
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$0A ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat_demo1
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$02 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat_demo2
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$03 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat_demo3
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$04 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_heartbeat_demo4
  $10,$04,$14 ; version, priority, frames per chunk
  $18,$06,$05 ; first chunk of freq,channel,volume data 
  $10,$06,$00
  $00,$00,$00 
end

 data sfx_nofire
  $10,$04,$06 ; version, priority, frames per chunk
  $04,$06,$06 ; first chunk of freq,channel,volume data 
  $00,$00,$00 
end

 data sfx_buzz
  $10,$10,$02 ; version, priority, frames per chunk
  $10,$03,$05 ; first chunk of freq,channel,volume data 
  $04,$08,$05 
  $10,$03,$05 
  $04,$08,$04
  $10,$03,$04 
  $04,$08,$04
  $10,$03,$03 
  $04,$08,$03 
  $10,$03,$03
  $04,$08,$02 
  $10,$03,$02 
  $04,$08,$02
  $10,$03,$01
  $04,$08,$01 
  $10,$03,$01 
  $00,$00,$00 
end

 data sfx_buzz_demo
  $10,$10,$02 ; version, priority, frames per chunk
  $10,$03,$02 ; first chunk of freq,channel,volume data 
  $04,$08,$02 
  $04,$08,$02
  $10,$03,$02 
  $04,$08,$02
  $10,$03,$02 
  $04,$08,$01 
  $10,$03,$01 
  $04,$08,$01
  $10,$03,$01
  $00,$00,$00 
end

 data sfx_deathsound
  $10,$12,$02 ; version, priority, frames per chunk
  $04,$03,$10 ; first chunk of freq,channel,volume data 
  $04,$08,$0E 
  $04,$03,$0D 
  $04,$08,$0C 
  $04,$03,$0B 
  $04,$08,$0A 
  $04,$03,$09 
  $04,$08,$08 
  $04,$03,$07 
  $04,$08,$06 
  $04,$03,$05 
  $04,$08,$04 
  $04,$03,$03 
  $04,$08,$02 
  $04,$03,$01 
  $00,$00,$00 
end

  data sfx_pickup
  $10,$2C,$01 ; version, priority, frames per chunk
  $18,$04,$08 ; first chunk of freq,channel,volume data 
  $1E,$04,$08
  $18,$04,$08
  $1E,$04,$08
  $14,$04,$08
  $00,$00,$00 
end

 data sfx_explode
  $10,$2F,$02 ; version, priority, frames per chunk
  $1A,$03,$0a ; first chunk of freq,channel,volume data 
  $1A,$08,$0E 
  $1A,$03,$0D 
  $1A,$08,$0C 
  $1A,$03,$0B 
  $1A,$08,$0A 
  $1A,$03,$09 
  $1A,$03,$02 
  $1A,$03,$09 
  $1A,$03,$02 
  $1A,$03,$09 
  $1A,$03,$02 
  $1A,$03,$09 
  $1A,$03,$09 
  $1F,$08,$08 
  $1F,$03,$07 
  $1F,$08,$06 
  $1F,$03,$05 
  $1F,$08,$04 
  $1F,$03,$03 
  $1F,$08,$02 
  $1F,$03,$01 
  $00,$00,$00 
end

 data copyrightsfx
  $10,$08,$08 ; version, priority, frames per chunk
  $18,$06,$0a ; first chunk of freq,channel,volume data 
  $08,$06,$0a
  $01,$00,$00 
  $18,$06,$05
  $08,$06,$05
  $01,$00,$00 
  $18,$06,$04
  $08,$06,$04
  $01,$00,$00 
  $18,$06,$03
  $08,$06,$03
  $01,$00,$00 
  $18,$06,$02
  $08,$06,$02
  $01,$00,$00 
  $18,$06,$01
  $08,$06,$01
  $00,$00,$00 
end

 data sfx_batdeath
  $10,$2E,$02 ; version, priority, frames per chunk
  $06,$03,$06 ; first chunk of freq,channel,volume data 
  $06,$08,$0E 
  $06,$03,$0D 
  $06,$08,$0C 
  $06,$03,$0B 
  $06,$08,$0A 
  $00,$00,$00 
end

 data sfx_spiderdeath
  $10,$2D,$02 ; version, priority, frames per chunk
  $08,$03,$06 ; first chunk of freq,channel,volume data 
  $08,$08,$0A 
  $08,$03,$0B 
  $08,$08,$0C 
  $08,$03,$0D 
  $08,$08,$0E 
  $00,$00,$00 
end

 data sfx_menumove
  $10,$10,$02 ; version, priority, frames per chunk
  $08,$03,$02 ; first chunk of freq,channel,volume data 
  $14,$04,$04
  $00,$00,$00 
end

  rem data sfx_menumove2
  rem $10,$01,$00 ; version, priority, frames per chunk
  rem $06,$0F,$04 ; first chunk of freq,channel,volume data
  rem $07,$0F,$02
  rem $08,$0F,$04
  rem $04,$0F,$04
  rem $02,$0F,$02
  rem $00,$00,$00
  rem end

  data sfx_menuselect
  $10,$04,$02 ; version, priority, frames per chunk
  $00,$06,$05 ; first chunk of freq,channel,volume data 
  $01,$06,$02 
  $02,$06,$01 
  $03,$06,$01
  $00,$00,$00 
end

  data sfx_menumove2
  $10,$10,$02 ; version, priority, frames per chunk
  $1F,$03,$0F ; first chunk of freq,channel,volume data 
  $1F,$08,$0E 
  $1F,$03,$0D 
  $1F,$08,$0C 
  $1F,$03,$0B 
  $1F,$08,$0A 
  $1F,$03,$09 
  $1F,$08,$08 
  $1F,$03,$07 
  $1F,$08,$06 
  $1F,$03,$05 
  $1F,$08,$04 
  $1F,$03,$03 
  $1F,$08,$02 
  $1F,$03,$01 
  $00,$00,$00 
end

  rem for moving up and down on the menu
  data sfx_menumove3
  $10,$10,$02 ; version, priority, frames per chunk
  $1F,$03,$05 ; first chunk of freq,channel,volume data 
  $1F,$08,$04 
  $1F,$03,$04 
  $1F,$08,$03 
  $1F,$03,$03 
  $1F,$08,$03 
  $1F,$03,$02 
  $1F,$08,$02 
  $1F,$03,$02 
  $00,$00,$00 
end

  data sfx_god
   $10,$01,$00 ; version, priority, frames per chunk
   $00,$01,$08 ; first chunk of freq,channel,volume data
   $00,$01,$06
   $00,$01,$04
   $00,$00,$00
end
  data sfx_wiz
   $10,$00,$01 ; version, priority, frames per chunk
   $00,$01,$04 ; first chunk of freq,channel,volume data
   $00,$01,$02 ; first chunk of freq,channel,volume data
   $00,$00,$00
end

  data sfx_wor1
   $10,$FF,$20 ; version, priority, frames per chunk
   $1D,$0C,$08 ; first chunk of freq,channel,volume data
   $1D,$0C,$08 
   $19,$0C,$08 
   $18,$0C,$08 
   $18,$0C,$08 
   $1D,$0C,$08
   $1D,$0C,$08 
   $00,$00,$00
end
   data sfx_wor2
   $10,$FF,$20
   $1D,$04,$08 ; first chunk of freq,channel,volume data
   $1D,$04,$08 
   $19,$04,$08 
   $18,$04,$08 
   $18,$04,$08 
   $1D,$04,$08
   $1D,$04,$08 
   $00,$00,$00
end
 
  data arp_god
   19,23,29,21
end

  data sfx_wizwarp
  $10,$00,$04
   $1F,$08,$08 ; first chunk of freq,channel,volume data
   $1C,$08,$08
   $18,$08,$08
   $14,$08,$08
   $10,$08,$08
   $0C,$08,$08
   $08,$08,$08
   $04,$08,$08
   $00,$08,$08
   $00,$00,$00
end

  rem <--- End Audio Code --->
 
  rem ** This section calculates your current best score for the current game session
  rem ** it has nothing to do with the high score tables, it shows your "best" score
  rem ** on the title screen for the current session, regardless of the difficulty level played

HighScoreCalc

   Save_Score01=sc1
   Save_Score02=sc2
   Save_Score03=sc3

   rem  ** Checks for a new high score.
   if sc1 > High_Score01 then goto New_High_Score
   if sc1 < High_Score01 then goto Skip_High_Score

   rem  ** First byte equal. Do the next test. 
   if sc2 > High_Score02 then goto New_High_Score
   if sc2 < High_Score02 then goto Skip_High_Score

   rem  ** Second byte equal. Do the next test. 
   if sc3 > High_Score03 then goto New_High_Score
   if sc3 < High_Score03 then goto Skip_High_Score

   rem  ** All bytes equal. Current score is the same as the high score.
   goto Skip_High_Score

New_High_Score

   rem  ** save new high score.
   High_Score01 = sc1 : High_Score02 = sc2 : High_Score03 = sc3

Skip_High_Score

   return

 rem ** AtariVox Speech Data

 rem Below is all of the AtariVox Speech
 rem This table shows the actual speech and the name of the sub that calls it earlier in the game code
 rem 
 rem Speech			Name of subroutine
 rem
 rem Dungeon Stalker            intro
 rem Entering the Dungeon       entering
 rem I Am God 			iamgod
 rem Death			death
 rem I Am stronger		iamstronger
 rem Terminated			terminated
 rem You got me			yougotme
 rem Gold			gold
 rem Level Up			levelup	
 rem Extra Life			extralife
 rem No Fear			nofear
 rem Bring it On		bringiton	
 rem Money			money
 rem Can't Stop	Me		cantstopme
 rem My Life is Over		mylifeisover
 rem More Power			morepower
 rem Growing Stronger		growingstronger
 rem Destroyed			destroyed
 rem Beaten			beaten
 rem Jackpot			jackpot
 rem Bunker Hit			bunkerhit
 rem Bunker Destroyed		bunkerdamaged
 rem Moving Up			movingup
 rem I have advanced		ihaveadvanced
 rem Wizard Destroyed		wizdestroyed
 rem Victory			victory
 rem Wizard is Dead		wizdead
 rem Wizard is Defeated		wizdefeated
 rem More Arrows		morearrows
 rem Filled Up			filledup
 rem Ammo Recharged		ammocharge
 rem Watch Out			watchout
 rem Ammo Gone			ammogone
 rem Arrows Gone		arrowsgone
 rem Out of Arrows		arrowsout
 rem Out of Ammo		ammoout
 rem Game Over			gameover	
 rem Ha Ha Ha			hahaha
 rem Got Him			gothim

 rem ** AtariVox speech code subs
 rem ** trial. error. trial. error. trial. error......

 speechdata intro
 reset
 speed 110
 pitch 74
 phonetic 'Dunjun stallcur'
end

 speechdata entering
 reset
 speed 110
 pitch 74
 phonetic 'Enturring the Dunjun'
end

 speechdata iamgod
 reset
 speed 100
 pitch 80
 dictionary 'I'
 pitch 86
 dictionary 'am'
 speed 80
 pitch 82
 dictionary 'god'
end

 speechdata death
 reset
 speed 68
 dictionary 'death.'
end

 speechdata iamstronger
 reset
 speed 100
 pitch 88
 dictionary 'I'
 pitch 90 
 dictionary 'am'
 pitch 92
 dictionary 'straw'
 pitch 92
 dictionary 'on'
 pitch 94
 phonetic 'gur.'
end

 speechdata terminated
 reset
 speed 108
 pitch 78
 phonetic 'Turminated'
end

 speechdata yougotme
 reset
 speed 105
 pitch 78
 dictionary 'you'
 speed 86
 pitch 82
 phonetic 'gaht'
 speed 96
 pitch 84
 dictionary 'me'
end

 speechdata gold
 reset
 speed 92
 pitch 88
 dictionary 'Goal'
 pitch 90
 phonetic 'd.'
end

 speechdata levelup
 reset
 raw 3,3,3,3,3,3
 speed 98
 pitch 78
 dictionary 'Level'
 pitch 80
 dictionary 'up.'
end

 speechdata extralife
 reset
 speed 104
 pitch 78
 dictionary 'Extra'
 pitch 80
 dictionary 'Life.'
end

 speechdata nofear
 reset
 speed 100
 pitch 76
 dictionary 'no'
 speed 86
 pitch 82
 phonetic 'fear.'
end

 speechdata bringiton
 reset
 speed 100
 pitch 80
 dictionary 'Bring'
 pitch 86
 dictionary 'it'
 speed 80
 pitch 82
 dictionary 'on'
end

 speechdata money
 reset
 speed 96
 pitch 78
 dictionary 'Money'
end

 speechdata cantstopme
 reset
 speed 104
 pitch 80
 dictionary 'cant'
 pitch 82
 dictionary 'stop'
 speed 80
 pitch 80
 dictionary 'me'
end

 speechdata mylifeisover
 reset
 speed 106
 pitch 82
 dictionary 'my'
 pitch 84 
 dictionary 'life'
 pitch 86
 dictionary 'is'
 pitch 80
 dictionary 'over'
end

 speechdata morepower
 reset
 raw 3,3,3,3,3,3
 speed 100
 pitch 80
 dictionary 'More'
 speed 94
 pitch 78
 phonetic 'Paw'
 pitch 76
 phonetic 'wur'
end

 speechdata growingstronger
 reset
 raw 3,3,3,3,3,3
 speed 112
 pitch 82
 dictionary 'Growing'
 pitch 82
 speed 108
 dictionary 'straw'
 pitch 84
 dictionary 'on'
 pitch 86
 phonetic 'gur.'
end

 speechdata destroyed
 reset
 speed 104
 pitch 80
 phonetic 'Dee'
 pitch 78
 phonetic 'stroyd'
end

 speechdata beaten
 reset
 speed 102
 pitch 76
 phonetic 'Beeten'
end

 speechdata jackpot
 reset
 speed 100
 pitch 82
 phonetic 'jack'
 speed 96
 pitch 84
 phonetic 'pawt'
end

 speechdata bunkerdamaged
 reset
  pitch 78
  phonetic 'Buncur'
  speed 80
  pitch 80
  phonetic 'dam'
  speed 90
  pitch 78
  phonetic 'edge'
  speed 64
  pitch 72
  phonetic 'd.'
end

 speechdata movingup
 reset
  speed 100
  pitch 84
  dictionary 'move'
  speed 100
  pitch 82
  phonetic 'ing'
  speed 74
  pitch 82
  dictionary 'up.'
end

 speechdata ihaveadvanced
 reset
 raw 3,3,3,3,3,3
  speed 100
  pitch 82
  dictionary 'i'
  speed 98
  pitch 82
  dictionary 'have'
  speed 102
  pitch 84
  dictionary 'ad'
  pitch 80
  dictionary 'van'
  pitch 80
  phonetic 'ss'
  pitch 78
  phonetic 'st'
end

  speechdata wizdestroyed
  reset
  speed 110
  pitch 82
  phonetic 'whiz'
  pitch 88
  phonetic 'zurd'
  speed 105
  pitch 92
  phonetic 'dee'
  pitch 105
  pitch 80
  phonetic 'stroyd'
end

 speechdata victory
 reset
  speed 100
  pitch 80
  phonetic 'vic'
  pitch 80
  phonetic 'tor'
  speed 105
  pitch 80
  phonetic 'e'
end

 speechdata wizdead
 reset
  speed 110
  pitch 82
  phonetic 'whiz'
  pitch 86
  phonetic 'zurd'
  speed 80
  pitch 92
  dictionary 'is'
  pitch 88
  dictionary 'dead'
end

 speechdata wizdefeated
 reset
  speed 110
  pitch 82
  phonetic 'whiz'
  pitch 88
  phonetic 'zurd'
 pitch 92
 dictionary 'is'
 pitch 86
 phonetic   'dee'
 pitch 84
 dictionary 'feet'
 pitch 82
 phonetic   'ted'
end

 speechdata morearrows
 reset
  speed 100
  pitch 88
  dictionary 'more'
  speed 110
  pitch 86
  dictionary 'air'
  pitch 86
  dictionary 'rows'
end

 speechdata filledup
 reset
  speed 100
  pitch 88
  phonetic 'filld'
  speed 85
  pitch 82
  phonetic 'up'
end

 speechdata ammocharge
 reset
 speed 110
 pitch 88
 dictionary 'am'
 pitch 90 
 phonetic 'mo'
 pitch 92
 phonetic 'ree'
 pitch 82
 dictionary  'charge'
 pitch 82
 dictionary  'd'
end

 speechdata watchout
 reset
  raw 3,3,3
  speed 100
  pitch 80
  dictionary 'watch'
  speed 100
  pitch 78
  dictionary 'out'
end

 speechdata ammogone
 reset
 speed 110
 pitch 88
 dictionary 'am'
 pitch 90 
 phonetic 'mo'
 pitch 84
 phonetic 'gawn'
end

 speechdata arrowsgone
 reset
  speed 110
  pitch 86
  dictionary 'air'
  pitch 86
  dictionary 'rows'
  speed 100
  pitch 82
 phonetic 'gawn'
end

 speechdata arrowsout
 reset
 speed 100
  pitch 86
  dictionary 'out'
  pitch 86
  dictionary 'of'
  pitch 82
  speed 110
  dictionary 'air'
  pitch 82
  dictionary 'rows'
end

 speechdata ammoout
 reset
 speed 100
  pitch 86
  dictionary 'out'
  pitch 86
  dictionary 'of'
 pitch 82
 dictionary 'am'
 pitch 82 
 phonetic 'mo'
end

 speechdata gameover
 reset
 speed 100
  pitch 86
  phonetic 'gayme'
  pitch 82
  speed 110
  dictionary 'owe'
  speed 95
  pitch 80
  phonetic 'vur'
end

 speechdata hahaha
 reset
 raw 3,3,3
 speed 78
  pitch 68
  phonetic 'aw aw aw'
end

 speechdata gothim
 reset
 speed 110
  pitch 86
  dictionary 'gaht him'
end

  rem ** Level colors
  rem             1   2   3   4   5
  rem v232   $00,$92,$D0,$52,$34,$14
  rem        blk blu grn prp org yel
  rem 
  rem v233+  $00,$92,$14,$52,$D0,$34
  rem        blk blu yel prp grn org

  data levelcolors
  $00,$92,$14,$52,$D0,$34
end

  rem ** shhhh. it's a secret.
  data devmodecode
  $EF,$EF,$DF,$DF,$BF,$7F,$BF,$7F
end

 rem ** I'm impressed! You looked at the code long enough to get to the bottom!
 
