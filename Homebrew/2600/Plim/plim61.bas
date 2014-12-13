 set kernel_options no_blank_lines pfcolors player1colors
 set romsize 32k
 rem set debug cyclescore
 rem goto level_5_cutscene_part_3_setup bank3
 const noscore = 1

 rem goto level_8_setup bank7
 rem i=60
 rem goto level_6_cutscene_setup bank4



 rem goto level_4_cutscene_part_2 bank2
 rem goto level_5_cutscene_setup bank2
 rem goto level_4_cutscene_part_2 bank2 

 rem goto level_6_cutscene_setup bank4
 rem goto level_7_intro_part_2 bank6
 goto final_level_fight_setup bank7

 rem goto theendoflevel6 bank5
 rem goto level_3_setup bank3 
 rem goto level_2_cutscene_setup bank2


 

 playfield:
  .....................XXXXXXXXX..
  .XX..........................X..
  .XXXXXX..XXX.................X..
  .XXXX........................X..
  .XX..................XXXXXXXXX..
  .XX..................XXXXXXXXXX.
  .XX..................X........X.
  .XXXXXX..............X........X.
  .X....X..............X........X.
  .X....X..............X........X.
  .XXXXXX..............XXXXXXXXXX.
end
 pfcolors:
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
end


 player1:
 %00000000
 %00001111
 %00001111
 %00001111
 %00001111
 %00001111
 %00001110
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00111100
 %01111100
 %11111100
 %11111000
 %11111000
 %11111000
 %11111000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11111100
 %11111110
 %11111110
 %11111110
 %11110110
 %11000110
 %11000110
 %11000110
 %11000110
 %11110110
 %11110110
 %11110110
 %11000110
 %10110111
 %11110011
 %11111011
 %11111011
 %11010000
 %11010000
 %11010000
 %11010000
 %11010000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %10100000
end
 player1color:
 $22
 $22
 $22
 $22
 $22
 $22
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 130
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
 236
 236
 236
end
 
 
 player0:
 %11111111
 %10000001
 %10100001
 %10100001
 %10100001
 %10100001
 %10100001
 %10100001
 %10100001
 %10100001
 %11000001
 %11000001
 %11110001
 %11000001
 %11000001
 %11100001
 %11100001
 %11100001
 %11100001
 %11100001
 %11100001
 %11100001
 %11100001
 %10000001
 %11111111
end


intro_main

 player0scorecolor=14
 player1scorecolor=14

 if !c{0} then a=a+1 else a=0
 
 if joy0fire then c{7}=1
 if !joy0fire && c{7} then c{7}=0 : goto title_screen_setup 
 
  drawscreen
 if g>8 then g=8 : goto intro_main_2_setup

 if c{2} then gosub alien_noises
 if !c{0} then b=b+1 
 if c{0} then AUDV0=2 : AUDF0=11 : AUDC0=8 : COLUP0=0
 if b>180 then b=0 : c{0}=1 

 player1x=28 : player1y=90 : NUSIZ1=$07 
 player0x=100 : player0y=32 : NUSIZ0=$07 
 COLUP0=a
 COLUBK=14 
 if c{0} then goto static

 
 goto intro_main
 
alien_noises
 if f<3 then c{3}=1 
 if c{3} then f=f+1 else f=f-1 
 if f>30 then c{3}=0 : g=g+1 
 AUDV1=g : AUDC1=6 : AUDF1=f 
 return
 
 
static




datastart

 const datastarthi=(#>.datastart)
 player0x=100
 player0y=32
 player0height=24
 player0pointerhi=datastarthi

 player0pointerlo=rand/2
 COLUP0=0 : NUSIZ0=$07


 if e>40 then player1:
 %00000000
 %00001111
 %00001111
 %00001111
 %00001111
 %00001111
 %00001110
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00001100
 %00111100
 %01111100
 %11111100
 %11111000
 %11111000
 %11111000
 %11111000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %11111100
 %11111110
 %11111110
 %11111110
 %11110110
 %11000110
 %11000110
 %11000110
 %11000110
 %11110110
 %11110110
 %10110110
 %11000110
 %11110111
 %11110011
 %11111011
 %11111011
 %11010000
 %11010000
 %11010000
 %11010000
 %11010000
 %11110000
 %11110000
 %11110000
 %11110000
 %11110000
 %10100000
end

 d=d+1
 if d>3 then d=1 : e=e+1
 if e>40 then c{2}=1
 
 goto intro_main
 
intro_main_2_setup
 playfield:
  ...............................
  ...............................
  .......XXXXXXXXXXXXXXXX........
  .......XXXXXXXXXXXXXXXX........
  .......XXXXXXXXXXXXXXXX........
  .......XXXXXXXXXXXXXXXX........
  .......XXXXXXXXXXXXXXXX........
  .......XXXXXXXXXXXXXXXX........
  ...............................
  ...............................
  ...............................
end

 player1:
  %10111101
  %10111101
  %10111101
  %10111101
  %10111101
  %11111111
  %11111111
  %01111110
  %01111110
  %01111110
  %00111100
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %01111110
  %01111110
  %01111110
  %01010100
  %01010100
  %00000000
  %00000000
  %00000000
  %00000000
  %00100100
  %00100100
  %00100100
  %00100100
  %00011000
  %00011000
  %00011000
  %00011000
  %00111100
  %00111100
  %00111100
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %11111111
  %10101011
  %11111111
  %01111110
  %01111110
  %01111110
  %01111110
  %00111100
  %00111100
  %00000000
  %00000000
  %00000010
  %00000010
  %00000011
  %00000001
  %00000001
  %00000011
  %00000010
  %00000010
end
 player1color:
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
 236
 236
 236
 0
 0
 0
 0
 8
 8
 8
 8
 8
 8
 8
 8
 82
 82
 82
 82
 82
 82
 82
 82
 82
 82
 30
 30
 30
 82
 82
 82
 82
 82
 82
 0
 0
 24
 24
 24
 24
 24
 24
 24
 24
 24
end
 player1x=70
 a=0

 player0:
  %01100110
  %00100100
  %00100100
  %00111100
  %10111101
  %10111101
  %01111110
  %00011000
  %00111100
  %01111110
  %01000010
  %01011010
  %01111110
  %01100110
  %01011010
  %01111110
  %00100100
  %00100100
  %01000010
end
 player0x=60 : player0y=60
 b=0
 
intro_main_2
 a=a+1
  if joy0fire then c{7}=1
 if !joy0fire && c{7} then c{7}=0 : goto title_screen_setup
 
 COLUP0=b
 if a>60 then b=204
 if a>204 then AUDV0=0 : AUDV1=0 : goto title_screen_setup
 NUSIZ1=$07 
 drawscreen
 goto intro_main_2
 
title_screen_setup
 d=31 : c{6}=1
 player0x=49 : player0y=23
 player1y=200

 
 data theremin_note_value
 23, 11, 16, 17, 16, 19, 23, 11, 16, 17, 16, 23
 23, 11, 16, 12, 17, 16, 17, 22, 18, 19, 20, 23
end

 data theremin_note_length
 29, 29, 179
end

 c{5}=1 : c{4}=0 : c{3}=0 : c{2}=0 : c{7}=0
 e=0 : f=0 : g=0 : h=0 : i=0
 l{0}=0 : l{1}=0

 playfield:
  ...............................
  ...............................
  ...............................
  ..........XX.X..X.X...X........
  ..........XX.X..X.XX.XX........
  ..........XX.X..X.X.X.X........
  ..........X..X..X.X.X.X........
  ..........X..XX.X.X.X.X........
  ...............................
  ...............................
  ...............................
end

title_screen

 
 ballx=0 : bally=0


 COLUP0=204

 AUDV0=6 : AUDC0=12 : AUDF0=d
 if f<88 then j=6
 if f>87 then j=5
 if f>92 then j=4
 if f>97 then j=3
 if f>102 then j=2
 if f>107 then j=1
 if f>112 then j=0 
 if i>3 then f=f+1 : AUDV1=j : AUDC1=5 : AUDF1=theremin_note_value[h]
 e=e+1 
 
 if c{5} then player0x=player0x+1
 if c{4} then player0y=player0y+1
 if c{3} then player0x=player0x-1
 if c{2} then player0y=player0y-1
 
 if f>theremin_note_length[g] then f=0 : g=g+1 : h=h+1
 if h>23 then h=0 : i=255
 if g>2 then g=0
 
 if e>0 then d=31 
 if e>59 then d=26 : c{5}=0 : c{4}=1
 if e>119 && c{6} then d=22 : c{4}=0 : c{3}=1
 if e>179 && c{6} then d=18 : c{3}=0 : c{2}=1
 if e>119 && !c{6} then d=23 : c{4}=0 : c{3}=1
 if e>179 && !c{6} then d=22 : c{3}=0 : c{2}=1
 if e>239 && c{6} then e=0 : i=i+1 : c{6}=0 : c{5}=1 : c{2}=0
 if e>239 && !c{6} then e=0 : i=i+1 : c{6}=1 : c{5}=1 : c{2}=0

  COLUBK=0 :  CTRLPF=$01
 pfcolors:
  0
  0
  0
  180
  180
  184
  186
  184
  180
  180
  0
  0
end

 drawscreen
 if joy0fire && !c{7} then c{7}=1
 if !joy0fire && c{7} then l{0}=1 : l{1}=1 : c{5}=1 : goto begin
 
 k=k+1
 if k>20 then k=0
 
 if c{5} then REFP0=8 else REFP0=0
 
 if c{5} || c{3} then gosub walk_side
 if c{4} then goto walk_down
 if c{2} then goto walk_up
 

 goto title_screen


walk_down

 player0:
  %01100000
  %00100110
  %00100100
  %00111100
  %10111101
  %10111101
  %01111110
  %00011000
  %00111100
  %01111110
  %01000010
  %01011010
  %01111110
  %01100110
  %01011010
  %01111110
  %00100100
  %00100100
  %01000010
end

 if k>9 then player0:
  %00000110
  %01100100
  %00100100
  %00111100
  %10111101
  %10111101
  %01111110
  %00011000
  %00111100
  %01111110
  %01000010
  %01011010
  %01111110
  %01100110
  %01011010
  %01111110
  %00100100
  %00100100
  %01000010
end 

 goto title_screen
 
 
walk_up

 if k<10 then player0:
  %01100000
  %00100110
  %00100100
  %00111100
  %10111101
  %10111101
  %01111110
  %00011000
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %00100100
  %00100100
  %01000010
end

 if k>9 then player0:
  %00000110
  %01100100
  %00100100
  %00111100
  %10111101
  %10111101
  %01111110
  %00011000
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %00100100
  %00100100
  %01000010
end 

 goto title_screen
 
walk_side

 if k<10 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if k>9 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end
 rem if l{0} then goto begin
 return thisbank

begin
 k=k+1
 if k>20 then k=0
 AUDV0=0 : AUDV1=0 : COLUP0=204
 drawscreen
 if player0y<80 then player0y=player0y+1
 if l{1} then player0x=player0x+1 else player1x=player1x+1
 if l{1} then REFP0=8
 if player0x>150 && l{1} then l{1}=0 : player0y=200 : player1x=0 : player1y=80 : REFP0=0
 if player1x>150 && !l{1} then goto level_1_setup

 if !l{1} then gosub man
 if l{1} then gosub walk_side
 goto begin

man_anotherbank
 gosub man
 return otherbank

alien_anotherbank
 gosub walk_side
 return otherbank

man
 
 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end

 if k<10 then player1:
  %0011000
  %0010110
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end
 
 if k>9 then player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100  
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end
 return thisbank
 
 
 

   
level_1_setup

 
 b{0}=0 : b{1}=0 : b{2}=1
 
 player0score=$05
 player1score=$19

 

 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 player1x=20 : player1y=80 : player0x=115 : player0y=81
 e{1}=0 : e{2}=0 : x=9 : e{6}=0 : e{3}=0
 n=(rand/64)+1
 pfcolors:
  $90
  $92
  $94
  $96
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  180
  180
end
 drawscreen
 
begin_new_platform

 if e{6} then goto level_1_main
 z=rand/128
 e{0}=0 : e{5}=1
 a=27 : c=31
 if z=0 then goto make_hole

 e{7}=0
 i=rand/128
   COLUBK=$9a : COLUP0=204  : REFP0=8 : COLUPF=180 : ballheight=2 : CTRLPF=$31
 PF0=$ff
 



 rem drawscreen
 goto level_1_main

make_hole
 if e{6} then goto level_1_main

 e{7}=1 

 
 
level_1_main

 if e{1} then player1y=player1y-1 : f=f+1
 rem if e{1} && collision(player1,playfield) && f>3 then e{1}=0 : f=0 : e{3}=0
 if e{1} && f>20 then e{1}=0 : e{2}=1
 
  if !joy0fire && e{1} && !e{6} then e{1}=0 : e{2}=1 

 if e{6} && !e{2} && z=0 then z=1 : e{2}=1
 if e{6} && e{2} && player1y<80 then player1y=player1y+1 
 if e{6} && !e{2} && !collision(player1,playfield) then f=0 : e{1}=1

 


 t=r+2 : u=r-2
  COLUBK=$9a : COLUP0=204 : REFP0=8 : COLUPF=$90 : ballheight=2 : CTRLPF=$31 : PF0=$ff
  pfcolors:
  $90
  $92
  $94
  $96
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  180
  180
  180
end


 if e{6} && player1x>130 then gosub level_2_cutscene_setup bank2
 if e{6} && player0x>130 then player0y=200
 if e{6} then player0x=player0x+1 : player1x=player1x+1 : k=k+1 : goto ds


 if e{2} && !collision(player1,playfield) then player1y=player1y+1 : f=0
 if player1y>80 then player1y=player1y+1 

 if !e{7} && !e{0} then pfhline a 9 c on
 if e{7} then pfhline a 10 c off

 if b{2} then ballx=p : bally=q : b{2}=0  :  goto level_1_main_2
 if !b{2} then ballx=r : bally=s+z :  b{2}=1

level_1_main_2 
 if player1y=0 && !e{6} then  l{3}=1 : gosub subtract_player0score

 if l{3} && player1y<80 then player1y=player1y+1
 if player1y=80 then l{3}=0

 AUDV0=0 : AUDV1=0

 if h{0} && i<15 then i=i+1 : AUDC0=1 : AUDV0=4 : AUDF0=i
 if h{0} && i>14 then i=16 : h{0}=0 


 if h{2} && j<15 then j=j+1 : AUDC1=2 : AUDV1=4 : AUDF1=j
 if h{2} && j>14 then j=16 : h{2}=0 

 if h>8 then h=0

 if joy0right && !b{0} && player1y>79 then q=player1y-5 : p=player1x : b{0}=1

 if collision(ball,player0) && b{2} then  u=0 : w=w+1 : b{0}=0 : i=0 : h{0}=1 : h{2}=0 : gosub subtract_player1score
 rem if collision(ball,playfield) && b{2} then b{0}=0
 if collision(ball,playfield) && !b{2} then b{1}=0
 if collision(missile0,playfield) then b{1}=0 
 if p>140 then b{0}=0
 if r<20 then b{1}=0
 if collision(ball,player1) && !b{2} && !e{6} then  j=0 : b{1}=0 : h{2}=1 : b{2}=1 : gosub subtract_player0score
 if player0score=$00 then reboot
 if player1score=$00 then e{6}=1

 if !b{1} && o=1 then n=(rand/64)+1 : z=rand/32
 if !b{1} then o=o+1
 if !b{1} && o>60 then o=0 : m=m+1
 if !b{1} && m>n && player0y>79 then m=0 : s=player0y-6 : r=player0x : b{1}=1
 
 if b{0} then p=p+1 else p=0 : q=0
 if b{1} then r=r-1 else r=190 : s=190 
 
 d=d+1
 k=k+1

 if w>19 && !e{6} then pfhline 0 10 31 on : e{7}=0 : e{0}=1

 if d>4 && e{7} && !e{0} && a>0 then gosub ds_level_1
 if d>4 && e{7} && !e{0} && a>0 then d=0 : COLUP0=204 : REFP0=8 : pfhline a 10 c on : a=a-1 : c=c-1 
 if d>4 && e{7} && !e{0} && a=0 then gosub ds_level_1
 if d>4 && e{7} && !e{0} && a=0 then d=0 : COLUP0=204 : REFP0=8 : pfhline a 10 c on : c=c-1

 if collision(player1,playfield) && player1y>70 && player1y<81 then e{2}=0



 if d>4 && !e{7} && !e{0} && a>0 then gosub ds_level_1
 if d>4 && !e{7} && !e{0} && a>0 then COLUP0=204 : REFP0=8 : pfhline a 9 c off : a=a-1 

 if d>4 && !e{7} && !e{0} && a>0 then c=c-1 : d=0 
 if d>4 && !e{7} && !e{0} && a=0 then gosub ds_level_1
 if d>4 && !e{7} && !e{0} && a=0 then d=0 : COLUP0=204 : REFP0=8 : pfhline a 9 c off : c=c-1

 if e{7} then e{3}=0 : goto ds_2
 if player1y>78 && c<6 && c>0 && !e{3} && !e{6} then  e{3}=1 : gosub subtract_player0score


ds_2
 if joy0fire && !e{1} && !e{2} then e{1}=1 

 if !collision(player1,playfield) && !e{1} then e{1}=0 : e{2}=1
 


 
ds
 if c=0 then pfhline a 9 c off : pfhline a 10 c on : e{0}=1 : e{3}=0 : gosub get_new_time
 if e{0} then j=j+1
 if e{0} && j>60 then j=0 : h=h+1
 if e{0} && g>h then h=0 : g=0 : goto begin_new_platform



 if e{7} then pfhline a 10 c off 
 if !e{7} && !e{0} then pfhline a 9 c on
  COLUBK=$9a : COLUP0=204  : REFP0=8 : COLUPF=180 : ballheight=2 : CTRLPF=$31
 pfcolors:
  $90
  $92
  $94
  $96
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  180
  180
  180
end

  PF0=$ff

 
 drawscreen
 if e{5} then player0y=player0y-1 : v=v+1
 if e{5} && v>30 then e{5}=0 : l{0}=1
 if l{0} then player0y=player0y+1 
 if l{0} && collision(player0,playfield) then l{0}=0 : v=0



 e{4}=0
 
 if k>20 then k=0
 
 gosub walk_side
 gosub man
 
 goto level_1_main
 
subtract_player0score
  asm
  sed ; set decimal mode
end

 player0score=player0score-1

  asm
  cld ;clear decimal mode
end
 return

subtract_player1score
  asm
  sed ; set decimal mode
end

 player1score=player1score-$01

  asm
  cld ;clear decimal mode
end
 return

subtract_player0score_anotherbank
  asm
  sed ; set decimal mode
end

 player0score=player0score-1

  asm
  cld ;clear decimal mode
end
 return otherbank

subtract_player1score_anotherbank
  asm
  sed ; set decimal mode
end

 player1score=player1score-$01

  asm
  cld ;clear decimal mode
end
 return otherbank

get_new_time
 e{0}=1 : e{3}=0
 g=255
 return

ds_level_1
  COLUBK=$9a : COLUP0=204 : REFP0=8 : COLUPF=180 : ballheight=2 : CTRLPF=$31 : PF0=$ff
  pfcolors:
  $90
  $92
  $94
  $96
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  180
  180
  180
end
 drawscreen
 return
 
  bank 2
level_4_cutscene_part_2
 playfield:
  XXXXXXXXX...............XXXXXXX.
  XXXXXXXX....XX...........XXXXX..
  XXXXXXX.....XX............XXX...
  XXXXXX..........................
  XXXXXXXXXXXX...................X
  XXXXXXXXXXXX....................
  XXXXXX..........................
  XXXXXXX...................XXX...
  XXXXXXXX.................XXXXX..
  XXXXXXXXX...............XXXXXXX.
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 pfcolors:
  $a8
  $a8
  $a6
  $a6
  $a4
  $a4
  $a2
  $a2
  $a0
  $a0
  $a0
  $a0
end

 a=0 : b=0 : c=0
 player0x=10 : player0y=80 : bally=200
 player1x=10 : player1y=200

level_4_cutscene_part_2_main
 COLUP0=204 : REFP0=8 : PF0=$ff
 b=b+1
 f=f+1

 if f>30 then f=0 : pfscroll left
 if c>25 then AUDC0=1 : AUDF0=c/2 : AUDV0=4
 if !a{0} && player0x<151 then player0x=player0x+1 : gosub level_4_anim_alien
 if !a{0} && player0x>150 then player0y=200 : player1x=10 : player1y=46 : a{0}=1
 if b>20 then b=0
 if a{0} then player1x=player1x+1 : c=c+1 : gosub level_4_anim
 if a{0} && player1x>30 && !a{1} then player1y=200 : pfhline 1 5 6 off : pfhline 1 4 6 off : a{1}=1
 COLUBK=4
 if b>20 then b=0
 if a{1} && c>59 then goto level_4_setup
 drawscreen
 goto level_4_cutscene_part_2_main

level_4_setup
 player1x=100 : player1y=80
 a=0 : b=0 : c=0 : d=0 : f=0 : i=0 : k=0 : l=0 : m=0 : n=0 : p=0
 j=1 : w{0}=0 : z=22
 player1score=$10
 AUDV0=0


level_4_begin_pf
 playfield:
  ..X...............X.............
  ..X...............X.............  
  ..X...............X.............
  ................................
  ................................
  ................................
  ................................
  ..X...............X.............  
  ..X...............X.............
  ..X...............X.............
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 goto level_4_main

level_4_anim_alien
 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end

 if b<10 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if b>9 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end
 return

level_4_anim
 gosub man_anotherbank bank1

 return

level_4_fish
 player0:
  %10000110
  %10001011
  %11001100
  %11111111
  %11111111
  %11001111
  %10001101
  %10000110
end

 player0x=10 : player0y=rand/8
 g=rand
 f=0 
 goto level_4_main

level_4_wait
 rem gosub subtract_player1score_anotherbank bank1 



level_4_wait_2
 g=rand
 player0y=203 : player0x=139 : f=1
 AUDV0=0 

level_4_main

 if switchreset then goto level_4_setup

 player0scorecolor=0
 player1scorecolor=0


 if f>0 then f=f+1 : player0y=203 
 gosub level_4_anim
 rem if b>20 then b=0
 if player0y<80 then player0x=player0x+j : player0y=player0y+j : AUDV0=4 : AUDC0=4 : AUDF0=player0y/4
 if player0y>=80 && player0y<199 then player0y=80 : player0x=player0x+j : AUDV0=0
 if player0x>140 && f=0 then player0y=201 : f=1
 if f=1 then goto level_4_wait
 if f>g then goto level_4_fish
 
 if player0score=$00 then reboot

 if m=29 then player1y=80 : goto level_5_cutscene_setup

 pfcolors:
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
  $0E
end

 if d{0} then REFP1=8 else REFP1=0 : PF0=$ff
 COLUBK=$32
 if g<128 then g=g+128
 COLUP0=g  : scorecolor=0
 
 if m=0 && b=0 && l=0 && !n{1} then n{1}=1 : goto level_4_begin_pf 
 if m=0 && b=0 && l=0 && n{1} then goto this_is_stupid

 if joy0left  then d{0}=0 : b=b-1 : k=k+1 : p=p+1 : gosub man_anotherbank bank1

this_is_stupid
 if joy0right then d{0}=0 : b=b+1 : e=e+1 : k=k+1 : gosub man_anotherbank bank1
 if e>4 then e=0 : pfscroll left : player0x=player0x+j
 if p>4  then p=0 : pfscroll right : player0x=player0x+j

 if joy0fire && !c{0} && !c{1} then c{0}=1
 if !joy0fire && c{0} then a=21

 if c{0} then player1y=player1y-1 : a=a+1
 if a>20 then  c{0}=0 : c{1}=1
 if c{1} && player1y<80 then player1y=player1y+1
 if player1y>79 then player1y=80 : a=0 : c{1}=0

 if k>20 then k=0
 drawscreen

 AUDV1=0
 if w{0} && z<21 then AUDV1=4 : AUDC1=3 : AUDF1=12 : z=z+1 
 if w{0} && z>20 then w{0}=0


 if collision(player1,player0) then f=1 : w{0}=1 : z=0 : gosub subtract_player0score_anotherbank bank1 
 if f=1 then f=0 : goto level_4_wait_2


 if b=255 then b=31 : l=l-1
 if b>31 && b<255 then b=0 : l=l+1
 if l=255 then l=3 : m=m-1
 if l>3 then l=0 : m=m+1

 if m=12 && b=31 && l=3 && n{0} then gosub level_4_i_hate_this
 if m=13 && b=0 && l=0 && !n{0} then gosub level_4_deeper

 rem if m=2 then reboot



 goto level_4_main

level_4_i_hate_this
 playfield:
  ..X...............X.............
  ..X...............X.............  
  ..X...............X.............
  ................................
  ................................
  ................................
  ................................
  ..X...............X.............  
  ..X...............X.............
  ..X...............X.............
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 n{0}=0 
 return

level_4_deeper
 playfield:
  ...................X............
  ...................X............
  ...................X............
  ................................
  ................................
  ................................
  ................................
  ...................X............ 
  ...................X............
  ...................X............
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 n{0}=1 
 return

level_5_cutscene_setup

 ballx=102 : bally=170
 player0x=99 : player0y=90
 ballheight=80
 b=1 : c=90 : d=170

 player0:
  %00111100
  %10111101
  %01111110
  %01111110
end

level_5_cutscene
 player0y=c : bally=d : PF0=$ff
 AUDV0=4 : AUDC0=8 : AUDF0=13
 COLUBK=36 :  CTRLPF=$21 : COLUP0=14
 scorecolor=0
 drawscreen
 c=c-2 : d=d-2
 if collision(player0,player1) then player1y=player1y-2 : b=b+2
 if player1y<3 then goto level_5_cutscene_part_2_setup


 goto level_5_cutscene

level_5_cutscene_part_2_setup

 player0:
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %01111110
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
  %00111100
end
 playfield:
  ................................
  ................................
  ................................  
  ................................
  ................................
  ................................
  ................................  
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 bally=200

 b=29 
 player1y=100
 c=0 : d=0


level_5_cutscene_part_2
 c=c+1

 pfcolors:
  $ac
  $ac
  $ac
  $ac
  $ac
  $ac
  $ac
  $ac
  $94
  $94
  $94
  $94
  $94
end

 if c{1} then player1y=player1y-1 : d=d+1

 if c>7 then c=0 : b=b-1 : player1x=player1x-1 

 AUDV0=4 : AUDC0=4 : AUDF0=b

 player0x=40 : player0y=40

 if player1y<3 then goto level_5_cutscene_part_3_setup bank3

 CTRLPF=$01 : COLUBK=$AC : COLUPF=$84 : COLUP0=12 : NUSIZ0=$33 : PF0=$ff
 drawscreen
 goto level_5_cutscene_part_2





level_2_cutscene_setup
 player0x=20 : player0y=80 
 f=0

 player1:
  %10011000
  %10011000
  %10011000
  %01011000
  %01111100
  %01111100
  %00111100
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %11111111
  %11111111
  %11111111
  %11111111
  %10101011
  %10101011
  %10101011
  %10101011
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %01111110
  %01111110
  %01111110
  %00111100
  %00111100
  %00111100
  %00111100
  %00011000
  %00011000
  %00011000
  %00011000
end
 player1color:
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  30 
  30
  30
  30
  30
  30
  30
  30
  30
  30
  30
  30
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
end

level_2_cutscene

 if k<10 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if k>9 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end 
 
 player0score=$05
 player1score=$30

 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 pfcolors:
  $90
  $92
  $94
  $96
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  $9a
  180
  180
end
 if !f{1} then NUSIZ1=$07
 PF0=$ff

 k=k+1
 if k>20 then k=0


 if !f{0} && !f{1} then player1x=80 : player1y=81 : REFP0=8
  COLUBK=$9a : COLUP0=204 : REFP0=8 : COLUPF=$90 : ballheight=2 : CTRLPF=$31 : PF0=$ff
 if player0x<80 then player0x=player0x+1
 if player0x>75 then player0y=player0y-1 
 

 if !f{3} && player0x>79 then player0y=200 
 if !f{0} && !f{1} && player0y=200 then f{0}=1 
 if f{0} then player1y=player1y-1 : AUDC0=12 : AUDV0=4 : AUDF0=player1y/8

 if f{0} && player1y<1 then player1y=81 : player1x=20 : f{1}=1 : f{0}=0 : AUDV0=0
 if f{1} then player1x=player1x+1 : NUSIZ1=$00 : gosub man_2
 if f{1} && player1x>130 then player1x=20 : f{2}=1 
 if f{2} && !f{3} then player0x=80 : player0y=81 : COLUP0=6 : NUSIZ0=$05 
 if f{2} && player1x>80 then player1y=200 : f{3}=1 
 if f{3} then player0y=player0y-1 : COLUP0=6 : NUSIZ0=$05 : AUDC0=4 : AUDV0=4 : AUDF0=player0y/8
 if f{3} && player0y<2 then goto level_2_setup

 if f{2} || f{3} then player0:
  %00011001
  %00011010
  %00111100
  %00111100
  %01111110
  %01111110
  %11111111
  %11111111
  %10101011
  %10101011
  %10101011
  %10101011
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %01111110
  %00111100
  %00111100
  %00011000
  %00011000
end


 drawscreen

 goto level_2_cutscene


man_2

 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end


 if k<10 then player1:
  %0011000
  %0010110
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end
 
 if k>9 then player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end
 return




level_2_setup


 player1:
  %00011000
  %00011000
  %00011000
  %00011000
  %00111100
  %00111100
  %00111100
  %00111100
  %01111110
  %01111110
  %01111110
  %01111110
  %11111111
  %11111111
  %11111111
  %11111111
  %10101011
  %10101011
  %10101011
  %10101011
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %01111110
  %01111110
  %01111110
  %00111100
  %00111100
  %00111100
  %00111100
  %00011000
  %00011000
  %00011000
  %00011000
end
 player1color:
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  30 
  30
  30
  30
  30
  30
  30
  30
  30
  30
  30
  30
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
  82
end

 pfclear
 player1x=64 : player1y=64 : player0x=78 : player0y=10
 a=1 : c=0 : e=0 : e{0}=1 : w=9 
 m=0 : n=0 : z=0 : o=0 : p=0 : q=0 
 i=0 : j=0 : g=1 : h=0 : b=0 : f=0
 k=player0x+3 : l=player0y-7
 gosub get_new_shot_2




level_2_main


 player0:
  %00011000
  %00111100
  %01111110
  %11111111
  %10101011
  %10101011
  %11111111
  %11111111
  %01111110
  %00111100
  %00011000
end




 if player0score=$00 then goto title_screen_setup bank1

 if z=2 || z=3 then player0x=0 : player0y=0 


 COLUP0=6 : NUSIZ1=$07 
 if !e{6} then COLUBK=0 : COLUPF=82 
 CTRLPF=$21 : ballheight=3

 
 if !e{3} then k=player0x+3 : l=player0y-7

 if e{6} && o>9 then o=0 : p=p+1 : q=q+1
 if e{6} && z<4 then AUDV0=4 : AUDC0=12 : AUDF0=p : AUDV1=0
 if e{6} && z>3 then AUDV0=4 : AUDC0=4 : AUDF0=q : AUDV1=0


 if h{0} && n<15 then n=n+1 : AUDV0=4 : AUDC0=1 : AUDC0=n
 if h{0} && n>14 then n=0 : h{0}=0

  if h{1} && m<15 then m=m+1 : AUDV1=4 : AUDF1=8 : AUDC1=m
 if h{1} && m>14 then m=0 : h{1}=0

 player0scorecolor=14
 player1scorecolor=14

  if e{6} then i=1 : j=1 : o=o+1 : bally=100 : ballheight=0 : goto level_3_cutscene 


 drawscreen

 AUDV0=0
 AUDV1=0



 if a=1 then player0x=78 : player0y=10
 if a=2 then player0x=120 : player0y=48
 if a=3 then player0x=78 : player0y=88
 if a=4 then player0x=30 : player0y=46



 if player1score=$00 then x=player0x : y=player0y : e{6}=1 : z=1

 if joy0fire && !e{3} then g=a : e{3}=1 

 if joy0left then b=b+1
 if b>10 then b=0 : a=a+1
 if joy0right then f=f+1
 if f>10 then f=0 : a=a-1

 if e{2} then ballx=i : bally=j : e{2}=0 : gosub move_ball else ballx=k : bally=l : e{2}=1 
 if !e{2} then gosub move_ball_2


 if collision(player0,ball) && e{2} then  h{0}=1 : gosub get_new_shot_3

 scorecolor=14



 if a=0 then a=4
 if a=5 then a=1

 goto level_2_main




move_ball
 if c=1 then i=i+1
 if c=2 then j=j+1
 if c=3 then i=i-1
 if c=4 then j=j-1
 if i>150 then gosub get_new_shot_2
 if i<10 then gosub get_new_shot_2
 if j<1 then gosub get_new_shot_2
 if j>88 then gosub get_new_shot_2
 return


get_new_shot_3
 gosub subtract_player0score_anotherbank bank1 

get_new_shot_2

 c=(rand/64)+1
 i=80 : j=44
 return

move_ball_2
 

 if g=1 then l=l+1
 if g=2 then k=k-1 
 if g=3 then l=l-1
 if g=4 then k=k+1

 if collision(ball,player1) && !e{2} && e{3} then  e{3}=0 : h{1}=1 : gosub subtract_player1score_anotherbank bank1 
 return

level_3_cutscene


 drawscreen
 CTRLPF=$01 : missile0y=200 : player0y=200
 if z<4 then player1y=player1y+1 else player1y=0 
 if player1y>140 && z<3 then z=z+1 : player1y=1
 if player1y>70 && z=3 then player1y=0 : player1x=0 : z=z+1 : q=0
 if z>3 then y=y+1

 if y>90 && z>3 then z=z+1 : y=1
 if z=1 then COLUBK=0
 if z>3 || z<7 then player0x=x : player0y=y

 if z=2 then COLUBK=14
 if z=3 then COLUBK=152 
 if z=4 then COLUBK=0
 if z=5 then COLUBK=14
 if z=6 then COLUBK=152 
 if y=70 && z=6 then goto level_3_setup bank3

 if z>1 then PF0=$ff

 if z=2 || z=5 then playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXX....XXXXXXXXXXXXXXXXXXXXXX
  XXXXX......XXXXXXXX.......XXXXXX
  XXXXXX....XXXXXXXX.........XXXXX
  XXXXXXXXXXXXXXXXXXX.......XXXXXX
  XXXXXXXXXXX....XXXXXXXXXXXXXXXXX
  XXXXXXXXXX......XXXXXXXXXXXXXXXX
  XXXXXXXXXXX....XXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 pfcolors:
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
  $aa
end

 if z=3 || z=6 then playfield:
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 if z=3 || z=6 then pfcolors:
  152
  152
  152
  152
  152
  152
  152
  152
  152
  152
  $84
  $84
end
 if z=4 then pfcolors:
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
end


 goto level_2_main



  bank 3

level_5_cutscene_part_3_setup
 playfield:
  ................................
  ................................
  ...............XX...............
  ............XXXXXXX.............
  ............XXXXXXX.............  
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
end 
 k{2}=0 : m=0
 player1x=78 : player1y=240 : b=6 : c=0 : a=0 : f=1 : k{0}=0 
 player0y=200

 player1color:
 $22
 $22
 130
 130
 40
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end

 player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end

level_5_cutscene_part_3
 pfcolors:
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
end
 AUDV0=4 : AUDC0=4 : AUDF0=b
 if !collision(player1,playfield) then player1y=player1y+1 : c=c+1 else b=0 : AUDV0=0 : goto level_5_main
 if c>4 then c=0 : b=b+1
 drawscreen

 player0score=$05
 player1score=$00

 d=rand

 h=14 : f=1 : l=0


 goto level_5_cutscene_part_3

get_rock
  player0:
   %00111100
   %00111110
   %01111110
   %01111100
   %00111110
   %00111110
   %00011100
end

 player0y=255 
 player0x=(rand/2)+20

level_5_main

  


 i=(player1x-17)/4 : z=(player1x-9)/4 : y=(player1x-15)/4 : u=(player1x-11)/4
 g=(player1y+1)/8 : h=(player1y-1)/8 : x=player1y/8

 rem if joy0left && pfread(i, h) then player1x=player1x-1 : l=l+1 : goto level_5_main_2
 rem if joy0right && pfread(z, h) then player1x=player1x+1 : l=l+1 : goto level_5_main_2

 if joy0left && !joy0up && !joy0down && pfread(i, x) then player1x=player1x-1 : l=l+1 : goto level_5_main_2
 if joy0right && !joy0up && !joy0down && pfread(z, x) then player1x=player1x+1 : l=l+1 : goto level_5_main_2
 if joy0up && !joy0left && !joy0right && pfread(y, h) then if pfread(u, h) then player1y=player1y-1 : l=l+1 : goto level_5_main_2
 if joy0down && !joy0left && !joy0right && pfread(y, g) then if pfread(u, g) then player1y=player1y+1 : l=l+1 : goto level_5_main_2
 rem if joy0up && pfread(z, h) then player1y=player1y-1 : l=l+1 : goto level_5_main_2
 rem if joy0down && pfread(z, g) then player1y=player1y+1 : l=l+1 : goto level_5_main_2


 rem if joy0 && !pfread(i, g) then player1y=player1y+1 
 rem if j=1 && !pfread(i, g) then player1y=player1y-1


level_5_main_2

 if !k{0} then c=c+1
 if !k{0} && c>d then c=0 : d=0 : k{0}=1 : goto get_rock

 COLUBK=$AC : COLUP0=4
 pfcolors:
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
end

 
 if !k{2} && collision(player0,player1) then player0y=200 : m=0 : k{2}=1 : gosub subtract_player0score_anotherbank bank1

 drawscreen


 if k{2} && m<10 then m=m+1 : AUDC1=2 : AUDF0=20 : AUDV1=4
 if k{2} && m>9 then m=0 : k{2}=0 : AUDV1=0

 if k{0} then player0y=player0y+1 : AUDC0=12 : AUDF0=player0y/4 : AUDV0=4
 if k{0} && player0y>97 then c=1 : k{0}=0 : d=rand : AUDV0=0

 if player1y>80 then f=f+1 : player1y=6 : goto choose_level_5 bank4
 if player1y<5 then f=f-1 : player1y=80 : goto choose_level_5 bank4

 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 236
end
 if  l<10 then player1:
  %0110000
  %0010110
  %0010100
  %0010101
  %0011101
  %0011110
  %0111100
  %1001000
  %1011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
end

 if l>9 then player1:
  %0000110
  %0110100
  %0010100
  %0010100
  %1011100
  %1011100
  %0111110
  %0001001
  %0011101
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
end


 if l>20 then l=0

 goto level_5_main




level_3_setup



 player0score=$05 

level_3_setup_2
 d{0}=0 : d{3}=1
 player1x=30 : player1y=70
 dim level=s
 level=1




level_getting


 player0x=50 : player0y=30

 if level=1 then playfield:
  .........XXXX...................
  ...........XX...................
  ...........XX...................
  ...........XX...................
  ...........XX..............XXXXX
  ...........................XXXXX
  ................................
  ...........XX...................
  ...........XX.................XX
  ...........XX.................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=2 then playfield:
  ................................
  ................................
  ................................
  ..............................XX
  XXXXXXXX......................XX
  XXXXXXXX.....XXXXXXXXXXXXXXXXXXX
  ................................
  ................................
  XX............................XX
  XX............................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=3 then playfield:
  ...............XX.............XX
  ...............XX.............XX
  ...............XX.............XX
  XX.............XX.............XX
  XX.............XX......XX.....XX
  XXXXXXXXXX.....XX......XX.....XX
  ........XX.....XX......XX.......
  ........XX.....XX......XX.......
  XX......XX.............XX.....XX
  XX......XX.............XX.....XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=4 then playfield:  
  XX......................XX......
  XX......................XX......
  XX......XXXXXXXXXXXXX...XX....XX
  XX......XX.........XX...XX....XX
  XX......XX.........XX...XX....XX
  XX......XX...XX.........XX....XX
  ........XX...XX.........XX....XX
  ........XX...XXXXXXXXXXXXX....XX
  XX......XX....................XX
  XX......XX....................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=5 then playfield:
  ........XX....................XX
  ........XX....................XX
  XXXX....XX....XXXXX...........XX
  XX......XX.........XXXXXXXX...XX
  XX......XX.........XX....XX...XX
  XX....XXXXXXX............XX...XX
  XX...........X...........XX.....
  XX...........XXXXXXXX....XX.....
  XX......XX...............XXXXXXX
  XX......XX...............XXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=6 then playfield:
  XX......................XX......
  XX......................XX......
  XX....XXXXXXXXXXXXXXX...XX......
  XX....XX................XX....XX
  XX....XX................XX....XX
  XX....XX....XXXXXXXXXXXXXX....XX
  ......XX....XX..........XX....XX
  ......XX....XX..........XX....XX
  XXXXXX............XX..........XX
  X...XX............XX..........XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=7 then playfield:
  ................................
  ................................
  ................................
  XX....................XXXXXXXXXX
  XX....................XX........
  XX....XXXXXXXXXXXXXXXXXX........
  XX..............................
  XX..........................XXXX
  XX............................XX
  XX............................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=8 then playfield:
  ................................
  ................................
  ................................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ..............................XX
  ..............................XX
  ..............................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXX....XX
  XX......................XX......
  XX......................XX......
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=9 then v=0 : playfield:
  ......XX...............XX.......
  ......XX...............XX.......
  ......XX...............XX.......
  XXXXXXXX....XXXXXXX....XX...XXXX
  XX..........XX.........XX.......
  XX..........XX.........XX.......
  XX.....XXXXXXX....XXXXXXXXXXXXXX
  XX.....XX...XX..................
  .......XX...XX..................
  .......XX...XX..................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 if level=10 then  player0x=50 : player0y=20 : f{1}=0 : f{2}=0 : f{3}=0 : e=0 : v=0 : playfield:
  ..............................XX
  ..............................XX
  ..............................XX
  XXXXXXXXXX...XXXXXXXXXXXXXX...XX
  ........XX...XX..........XX...XX
  ........XX...XX..........XX...XX
  XXXXX...XX...XX..........XX...XX
  ........XX...XXXXXXXXXXXXXX...XX
  ........XX....................XX
  ........XX....................XX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end 


 ballheight=4 : player1:
  %10000010
  %01000100
  %00001000
  %00011011
  %00011111
  %00011011
  %00001000
  %01000100
  %10000010
end
 goto level_3

level_3_swim
 if c<10 then ballheight=4 : player1:
  %10000010
  %01000100
  %00001000
  %00011011
  %00011111
  %00011011
  %00001000
  %01000100
  %10000010
end
 
 if c>9 && c<20 then ballheight=3 : player1:
  %00000100
  %10001000
  %01001000
  %00011011
  %00011111
  %00011011
  %01001000
  %10001000
  %00000100
end
  

 if c>19 && c<30 then player1:
  %00010000
  %00010000
  %10001000
  %01011011
  %01011111
  %01011011
  %10001000
  %00010000
  %00010000
end

 if c>29 && c<40 then player1:
  %00100000
  %00100000
  %00011000
  %11011011
  %11011111
  %11011011
  %00011000
  %00100000
  %00100000
end

 if c>39 && c<50 then ballheight=4 : player1:
  %00010000
  %00010000
  %10001000
  %01011011
  %01011111
  %01011011
  %10001000
  %00010000
  %00010000
end




 player1color:
  $2E
  $2E
  $2E
  $2E
  $2E
  $2E
  $2E
  $2E
  $2E
end


 c=c+1
 if c>49 then c=0


 return

level_3
 if y=0 then t=4


 gosub level_3_swim


 if d{1} then REFP1=8 else REFP1=0 

 if player1y<10 then player1y=10

 if player1x<20 && level=1 then player1x=20 : ballx=30
 if player1x<20 && level<11 then player1x=130 : level=level-1 : player0x=20 : goto level_getting
 if joy0right && player1x>130 then player1x=27 : ballx=30 : level=level+1 : player0x=110 : goto level_getting

 COLUBK=128 
 COLUPF=$46

 pfcolors:
  $46
  $46
  $46
  $46
  $46
  $46
  $46
  $46
  $46
  $46
  $46
  $46
end

 if level<10 then COLUP0=6 : NUSIZ0=$05 : player0:
 %00001000
 %00110001
 %00011111
 %01111110
 %10111111
 %11111001
 %00011000
 %00001100
end



  


 

 if p>45 && level<10 then AUDV0=0 : AUDV1=0 : goto main_swim_2


 if p{3} && level<10 then AUDV0=6 
   
 if p>29 && level<10 then AUDC0=3 : AUDF0=10
 if p<46 && level<10 then AUDV1=4  
 if p>45 && level<10 then AUDV1=0

 if p=45 then gosub subtract_player0score_anotherbank bank1 
 AUDC1=6  


main_swim_2
 if p>109 then p=0
 if player0score=$00 then reboot 



 if player0y>player1y then m=player0y-player1y else m=player1y-player0y

 if player0x>player1x then r=(player0x-player1x)/2 else r=(player1x-player0x)/2


 l=m+r


 o=o+1
 if o>l && q{5} then o=0 : q{5}=0
 if o>l && !q{5} then o=0 : q{5}=1
 if q{5} then AUDF1=21 else AUDF1=19

 if switchreset then reboot



 g=(player1x-17)/4 : h=(player1y+1)/8
 k=(player1x-15)/4 : l=player1y/8
 i=(player1x-8)/4 : j=(player1y-10)/8


 y=(player1y-8)/8
 x=(player1x-18)/4
 w=(player1x-9)/4

 u=(player1y-4)/8

 if v=2 && e>0 then goto pre_boss


 if joy0left then d{0}=1
 if joy0right then d{0}=0
 if joy0up then d{1}=1
 if joy0down then d{1}=0

 rem if joy0left && !pfread(g, l) then player1x=player1x-1


 if joy0left && !pfread(x, l) then if !pfread(x, u) then if !pfread(x, y) then player1x=player1x-1

 if joy0right && !pfread(i, l)  then if !pfread(i, u) then if !pfread(i, y) then  player1x=player1x+1


 if joy0up && !pfread(k, j) then if !pfread(w, j) then if !pfread(g, j) then player1y=player1y-1

 if joy0down && !pfread(k, h) then if !pfread(w, h) then if !pfread(g, h) then player1y=player1y+1



 rem if joy0up && d{0} && !pfread(k, j) then v{0}=1
 rem if joy0up && d{0} && v{0} && !pfread(w, j) then v=0 : player1y=player1y-1


 rem if joy0down && d{0} && !pfread(k, h) then v{3}=1
 rem if joy0down && d{0} && v{3} && !pfread(w, h) then player1y=player1y+1


pre_boss

 if !d{0} then REFP1=0 : u=3 else REFP1=8 : u=6



 bally=player1y-3
 ballx=player1x+u 

 if z{0} then REFP0=0 else REFP0=8


 drawscreen

 if level>9 then  goto boss

 e=61

 if collision(player0,player1) then p=p+1 : AUDC0=12 : AUDF0=3 else p=0 : AUDV0=0




 n=n+1
 if n>2 then goto fish_movements 
 goto level_3

fish_movements

 n=0

 if player0y>player1y then player0y=player0y-1
 if player0y<player1y then player0y=player0y+1

 if player0x<player1x then player0x=player0x+1 : z{0}=0
 if player0x>player1x then player0x=player0x-1 : z{0}=1





 goto level_3

boss



 if v>2 then COLUP0=204 : player0x=150 : player0y=80 : f{0}=1 : k=0 : g=0 : goto level_4_cutscene

  if v<3 then player0:
    %01001001
    %10010010
    %01001001
    %10010010
    %11111111
    %11111111
    %11011011
    %01111110
end
 

 COLUP0=$64
 
 AUDV0=0 
 if a{6} && b<21 then AUDV0=4 : AUDC0=9 : AUDF0=b : b=b+1
 if a{6} && b>20 then a{6}=0 : b=21 : AUDV0=0

 

 if f{1} && f{2} && f{3} && e>59 then v=v+1 : f{1}=0 : f{2}=0 : f{3}=0 : e=0 : player0x=50 : goto level_3

 if f{1} && f{2} && f{3} && e<60 then e=e+1 : player0y=200 : goto level_3 

 if f{0} then player0y=player0y+1 else player0y=player0y-1
 if player0y>80 && player0y<199 then f{0}=0
 if player0y<10 then f{0}=1



 if collision(player0,player1) then gosub which_octopus_died

 if f{1} && f{2} && f{3} && e<60 then e=e+1 : player0y=200 :  goto level_3 
 if !f{1} && !f{2} && !f{3} then NUSIZ0=$06 : goto level_3


 if f{1} && !f{2} && !f{3} then player0x=82 : NUSIZ0=$02 
 if f{1} && f{2} && !f{3} then NUSIZ0=$00 : player0x=114
 if f{1} && !f{2} && f{3} then NUSIZ0=$00 : player0x=82

 if f{1} then goto level_3

 if f{2} && !f{1} && !f{3} then player0x=50 : NUSIZ0=$04
 if f{2} && !f{1} && f{3} then player0x=50 : NUSIZ0=$00
 if f{2} && f{1} && !f{3} then player0x=114 : NUSIZ0=$00

 if f{2} then goto level_3

 if f{3} && !f{1} && !f{2} then NUSIZ0=$02 : player0x=50
 if f{3} && f{1} && !f{2} then NUSIZ0=$00 : player0x=50
 if f{3} && !f{2} && f{1} then NUSIZ0=$00 : player0x=82

 goto level_3

which_octopus_died

 a{6}=1 : b=0
 if player1y>player0y && !f{7} then v=0 : f{7}=1 : gosub subtract_player0score_anotherbank bank1 
 if f{7} then f{7}=0 : a=0 : b=0 : goto level_3_setup_2

 if player1x<60 then f{1}=1 : return
 if player1x>70 && player1x<100 then f{2}=1 : return
 if player1x>100 then  f{3}=1 

 return


level_4_cutscene
 if k>20 then k=0


 if k<11 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if k>10 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end
 
 COLUP0=204
 k=k+1

 if !d{0} then REFP1=0 : u=3 else REFP1=8 : u=6


 AUDV0=0 : AUDV1=0

 bally=player1y-3
 ballx=player1x+u 


 drawscreen


 if f{0} then player0x=player0x-1 else player0x=player0x+1 : REFP0=8 : player1x=player1x+1 : ballx=ballx+1 : d{0}=0
 if player1x>150 then goto level_4_cutscene_part_2 bank2
 if player0x<120 then player0x=119 : g=g+1 : player1x=player1x-1 : ballx=ballx-1 : d{0}=1
 if g>30 then g=0 : player0x=120 : f{0}=0
 if player0x>150 then player0y=200

 gosub level_3_swim
 goto level_4_cutscene



   bank 4

choose_level_5
 player0y=200

 if f=1 then playfield:
  ................................
  ................................
  ...............XX...............
  ............XXXXXXX.............
  ............XXXXXXX.............  
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
  ..........XXXXXXXXXX............
end 

 if f=2 then playfield:
  ..........XXXXXXXXXX............
  .........XXXXXXXXXXXXX..........
  .........XXXX....XXXXX..........
  ........XXXXX...XXXXXX..........
  ......XXXX........XXXX..........
  .....XXXXXXXXXXXXXXXXXX.........
  .....XXXXX...XXXX....XXXX.......
  ....XXXXX...XXXXX.....XXXXX.....
  .....XXXXX...XXXXX...XXXXX......
  ....XXXX....XXXXX...XXXXXXXX....
  .....XXXX...XXXXX...XXXXXX......
end

 if f=3 then playfield:
  .....XXXX...XXXXX...XXXXXX......
  .....XXXX...XXXXX...XXXXXX......
  .....XXXXX...XXXXX..............
  ....XXXX......XXXXX.............
  ...XXXXXX........XXXXXX.........
  ..XXXXX.........XXXXXX..........
  ..XXXXX..........XXXX...........
  ...XXXXX..........XXXXX.........
  .....XXXXXXXXXXXXXXXX...........
  ...XXXX...XXXX....XXXX..........
  ..XXXXX...XXXXX....XXXXXXXX.....
end

 if f=4 then playfield:
  ..XXXXX...XXXXX....XXXXXXXX.....
  ..XXXXXX...XXXXX....XXXXXX......
  .XXXXXX.....XXXXX...............
  ...XXXXXXXXXXXXX................
  ......XXXXXXXXXXXXX.............
  ........XXXXXXXXXXXX............
  ..........XXXXXXXXXXX...........
  ..........XXXXXXXXXXX...........
  ..............XXXXXXXXXXXX......
  ...............XXXXXXXXXXXX.....
  ...............XXXXXXXXXXXX.....
end
 
 if f=5 then playfield:
  ...............XXXXXXXXXXXX.....
  ...............XXXXXXXX.........
  ....................XXXXX.......
  ....XXXXXX............XXXXX.....
  .XXXXXXXXXXX..........XXXXXX....
  XXXXXXXXXXXXXX.........XXXXXX...
  XXXX.......XXXX.......XXXXXXX...
  XXXX......XXXX..........XXXXX...
  XXXX.......XXXXX........XXXX....
  XXXX........XXXXX........XXXX...
  XXXX.......XXXXXXX........XXXX..
  XXXX........XXXXX........XXXXX..
end

 if f=6 then playfield:
  XXXX........XXXXX........XXXXX..
  XXXX........XXXXX......XXXXXX...
  XXXX.........XXXXX......XXXX....
  XXXX........XXXXX.......XXXXXX..
  XXXX...........XXXXXXXXXXXXX....
  .XXXXX..........................
  ..XXXXXX........................
  ...XXXXX...........XXXXXXXXXXXX.
  ..XXXXXX.........XXXXXXXXXXXXXXX
  .XXXXXX.........XXX..........XXX
  .XXXXXX........XXXX.........XXXX
  ..XXXXXX.......XXXX.........XXXX
end

 if f=7 then playfield:
  ..XXXXXX.......XXXX.........XXXX
  ...XXXXX........XXX.........XXXX
  ..XXXXXX.......XXXX........XXXXX
  ..XXXXX........XXXX........XXXX.
  ...XXXXX......XXXXX........XXXX.
  ..XXXXXX......XXXX..........XXXX
  ..XXXXX.......XXXX.......XXXXXXX
  ..XXXXX......XXXXX.....XXX...XXX
  ..XXXXX.......XXXX....XXX....XXX
  ..XXXXX.......XXXX....XXX....XXX
  ..XXXXX.......XXXX....XXX....XXX
  ..XXXXX.......XXXX....XXX....XXX
end

 if f=8 then playfield:
  ..XXXXX.......XXXX....XXX....XXX
  ..XXXXX.......XXXX....XXX....XXX
  ..XXXXX.....XXXX......XXX....XXX
  ...XXXXXXXXXXXX.......XXX....XXX
  ....................XXXX.....XXX
  ................XXXXXX.......XXX
  ......XXXXXXXXXXXXXX.........XXX
  ...XXXXXXXX..................XXX
  ....XXXXXX...................XXX
  ....XXXXXX...................XXX
  .....XXXXX...................XXX
  .....XXXXX...................XXX
end

 if f=9 then playfield:
  .....XXXXX...................XXX
  .....XXXXX...................XXX
  ......XXXX...................XXX
  ....XXXXX....................XXX
  .............................XXX
  ....................XXXXXXXXXXX.
  ...................XXXXXXXXXXXX.
  ..................XXXX..........
  ...........XXXXXXXXX............
  ...XXXXXXXXXXXX.................
  XXXXX...........................
  XXXXX...........................
end

 if f=10 then playfield:
  XXXXX...........................
  XXXXX....XXXXXXXXX...XXXXXXXXXX.
  ..XXXX...XXX...XXX...XXX....XXX.
  ..XXXX...XXX...XXX...XXX....XXX.
  ..XXXX...XXX...XXX...XXX....XXX.
  ...XXX...XXX...XXX...XXX....XXX.
  ...XXX...XXX...XXX...XXX....XXX.
  ...XXX...XXX...XXX...XXX....XXX.
  ...XXX...XXX...XXX...XXX....XXX.
  ...XXXXXXXXX...XXXXXXXXX....XXX.
  ............................XXX.
  ............................XXX.
end


 if f=11 then goto level_6_cutscene_setup

 goto level_5_main bank3



level_6_cutscene_setup
 playfield:
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  ............................XXX.
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 player1y=5 
 player1x=130 : rem remove when done testing cutscene.
 b=0
 c=0
 d=0
 player0y=200 : player0x=130
 player1score=$05
 player0score=$05

 AUDV0=0 : AUDV1=0

 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end



level_6_cutscene_main
 COLUP0=204 : COLUBK=$AA : COLUPF=$C8
 pfcolors:
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  14
  $c8
end
 drawscreen

 if b>20 then b=0

 if !c{0} && player1y<80 then player1y=player1y+1 : b=b+1
 if !c{0} && player1y=80 then c{0}=1
 if c{0} then d=d+1
 if c{0} && d>59 then c{0}=0 : c{1}=1 : d=0
 if c{1} then player1x=player1x-1 : REFP1=8 : b=b+1
 if c{1} && player1x=30 then c{1}=0 : c{2}=1
 if c{2} then player0x=player0x-1 : REFP0=0 : player0y=80 : b=b+1
 if c{2} && player0x<100 then c{2}=0 : c{3}=1
 if c{3} then REFP1=0 : REFP0=8 : player1x=player1x+1 : player0x=player0x+1 : b=b+1
 if c{3} && player0x>140 then player0y=200 : player1x=player1x+1 
 if c{3} && player1x>140 then goto level_6_cutscene_2_setup bank4

 if b<10 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if b>9 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end 

 gosub level_6_cutscene_anim 




 goto level_6_cutscene_main


level_6_cutscene_2_setup
 playfield:
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  ..........XXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end


 player1x=61 : player1y=81
 player0x=20 : player0y=81

 b=0 : c=0 : g=0

 player1:
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %00111100
end
 player1color:
  0
  0
  0 
  0
  0
  0
  0
  0 
  0
  0  
  0
  0
  0 
  0
  0  
  0
  0
  0 
  0
  0
end


level_6_cutscene_2_main

 pfcolors:
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $f6
  $c8
end

 if !g{1} && !collision(player0,player1) then COLUP0=204 : player0x=player0x+1 : REFP0=8 : b=b+1
 if !g{1} && collision(player0,player1) then player1x=20 : player1y=80 : player0x=61 : player0y=81 :  COLUPF=$F6 :  g{1}=1 : gosub level_6_cutscene_anim
 if g{1} then COLUP0=0 :  player0:
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %11111111
  %01111110
  %00111100
end
 COLUPF=$F6
  drawscreen
 player1score=$05


 gosub level_6_cutscene_anim

 if g{1} then player1x=player1x+1

 if g{1} && collision(player0,player1) then goto level_6_setup


 goto level_6_cutscene_2_main




level_6_cutscene_anim
 if !g{1} && b<10 then player0:
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

 if !g{1} && b>9 then player0:
  %110000
  %011100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000
  %001000 
  %010000
end

 if g{1} then player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 40
 40
 236
end

 if player1y<80 && b<10 then player1:
  %0110110
  %0010100
  %0010100
  %0010100
  %0011101
  %0011101
  %0011101
  %0111110
  %1011100
  %1001000
  %1011100
  %1011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
end

 if player1y<80 && b>9 then player1:
  %0110110
  %0010100
  %0010100
  %0010100
  %1011100
  %1011100
  %1011100
  %0111110
  %0011101
  %0001001
  %0011101
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
end




 if player1y>79 && player1y<81 && b<10 then player1:
  %0011000
  %0010110
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end
 
 if player1y>79 && player1y<81 && b>9 then player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
  %0001110
end 
 return



get_ledge_2
 if n=1 && p>0 then goto already_know_ledge 
 if n=2 && r>0 then goto already_know_ledge 
 if n=3 && m>0 then goto already_know_ledge 
 if n=4 && k>0 then goto already_know_ledge 
 if n=5 && s>0 then goto already_know_ledge 
 if n=6 && d>0 then goto already_know_ledge 
 if n=7 && t>0 then goto already_know_ledge 
 if n>7 then goto already_know_ledge 

 h=rand/8
 if h<10 then h=10
 if h>20 then h=10
 f=rand/8
 if f<10 then f=10
 if f>20 then f=10
 j=rand

 if n=1 then o=h : v{0}=j{0} : p=f

 if n=2 then q=h : r=f

 if n=3 then l=h : m=f 

 if n=4 then u=h : k=f 

 if n=5 then i=h : s=f

 if n=6 then c=h : d=f

 if n=7 then g=h : t=i-1

 goto already_know_ledge 


level_6_setup
 player1x=78 : player1y=80
 player0y=200
  n=1 : rem level number 

 b=0 : c=0 : d=0 : e=0 : f=0 : g=0 : t=0
 l=0 : m=0 : u=0 : k=0 : i=0 : s=0
 o=0 : p=0 : q=0 : r=0 : v=0 : w=0

get_ledge

 playfield:
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
end



 if n=1 then playfield:
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  ................................
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 AUDV0=0

 COLUPF=$F4 : COLUBK=$FA : PF0=$ff : COLUP0=$26
 
 pfcolors:
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
  $f4
end

 drawscreen


 goto get_ledge_2 

already_know_ledge
 if n=1 then goto screen_1a 
 if n=2 then goto screen_2a 
 if n=3 then goto screen_3a 
 if n=4 then goto screen_4a 
 if n=5 then goto screen_5a 
 if n=6 then goto screen_6a 
 if n=7 then goto screen_7a 
 if n=8 then goto screen_5a
 if n=9 then goto screen_6a 
 if n=10 then goto theendoflevel6 bank5



screen_1a
 

 pfhline 0 6 o on 
 gosub ds_level_6
  pfhline p 2 31 on 

 goto level_6_main bank5

screen_2a
 pfhline q 4 31 on 
 gosub ds_level_6
  pfhline 0 8 r on 

 goto level_6_main bank5

screen_3a
 pfhline 0 10 l on 
 pfhline m 5 31 on
 gosub ds_level_6
 pfhline 0 1 l on 
 goto level_6_main bank5

screen_4a
  pfhline u 8 31 on 
 gosub ds_level_6
 pfhline 0 3 k on
 goto level_6_main bank5

screen_5a
  pfhline i 10 31 on 
 gosub ds_level_6
  pfhline 0 4 s on
 goto level_6_main bank5

screen_6a
   pfhline c 10 31 on

 gosub ds_level_6
 pfhline 0 4 d on 
 goto level_6_main bank5

screen_7a
  pfhline g 10 31 on
 gosub ds_level_6
 pfhline 0 4 t 

 goto level_6_main bank5


ds_level_6
 COLUPF=$F4 : COLUBK=$FA : PF0=$ff : COLUP0=$26

 drawscreen

 return

  bank 5

get_new_acorn
 player0x=(rand/4)+20 : player0y=0 : a=0 : missile0y=0 : missile0x{0}=0
 return

level_6_main
 
 player1score=n
 
 COLUPF=$F4 : COLUBK=$FA : PF0=$ff : COLUP0=$26

 drawscreen

 if player0y=100 then missile0y=20 

 if missile0x{0} then player0y=199 : missile0y=missile0y+1 :  AUDV0=4 : AUDC0=3 : AUDF0=12

 if missile0y>19 then missile0x{0}=0 : player0y=200 : AUDV0=0
 if player0y<100 then player0y=player0y+1 : AUDV0=4 : AUDC0=4 : AUDF0=player0y/4
 if collision(player0,player1) then player0y=199 : missile0x{0}=1 : missile0y=0 : gosub subtract_player0score_anotherbank bank1 
 if player0score=$00 && player0y=200 then reboot
 if player0y>99 then a=a+1
 if player0y>99 && a>182 then gosub get_new_acorn

  AUDV1=0

 if joy0fire && e=0 then e{0}=1 : b=31
 if e{0} && b<32 then AUDC1=12 : AUDF1=b : AUDV1=4
 if !joy0fire && e{0} then e{0}=0 : e{1}=1 : b=31

 h=player1y/8

 j=(player1y-17)/8

 if e{0} && f>50 then e{0}=0 : e{1}=1 

 if w{0} then REFP1=0 else REFP1=8 

 x=(player1x-13)/4 : y=(player1x-15)/4

 

  if e{0} && j<11 && pfread(x, j) then e{0}=0 : e{1}=1 
 if e{0} && j<11 && pfread(y, j) then e{0}=0 : e{1}=1 

 if !e{0} && !pfread(x, h) then if !pfread(y, h) then e{1}=1
 rem if !e{0} && !pfread(y, h) then e{1}=1

 if joy0left && e>0 && player1x>21 && collision(player1,playfield) then player1x=player1x+1 : w{0}=0 
 if joy0right && e>0 && player1x<137 && collision(player1,playfield) then player1x=player1x-1 : w{0}=1 

 if joy0left && e>0 && player1x>21 && !collision(player1,playfield) then player1x=player1x-1 : w{0}=0 
 if joy0right && e>0 && player1x<137 && !collision(player1,playfield) then player1x=player1x+1 : w{0}=1 

 if joy0left && e=0 && player1x>21 then player1x=player1x-1 : w{0}=0 : z=z+1
 if joy0right && e=0 && player1x<137 then player1x=player1x+1 : w{0}=1 : z=z+1


 rem if f>40 then f=0 : e{0}=0 : e{0}=1

 if b>31 then AUDV1=0

 if e{0} then f=f+1 : b=b-1 : player1y=player1y-1


 if !e{0} && !pfread(x, h) then e{1}=1

level_6_part_2

 if e{1} then player1y=player1y+1

 if !e{0} && h<11 && pfread(x, h) then f=0 : e=0 




 if player1y=240 then n=n+1 : player0y=200 : f=f-20 : player1y=100 : goto get_ledge bank4

 if player1y=110 then n=n-1 : player0y=200 : player1y=2 : goto get_ledge bank4




level_6_main_part_2
 if z>20 then z=0

 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 236
end

 player0:
  %0001000
  %0111110
  %0111110
  %0111110
  %0111110
  %1111111
  %0111110
end


 if  z<10 then player1:
  %0011000
  %0010110
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
end

 if z>9 then player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
end
 goto level_6_main




theendoflevel6
 playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X......X.......................
   X....XXXXX.....................
   X....XXXXX.....................
   X....XXXXX.....................
   X.....XXX......................
   X..............................
   X..............................
   X..............................
   X..............................
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end


 AUDV0=0 : AUDV1=0 
 player0score=$05 
 player1score=$05


 player0:
 %01000000
 %00110000
 %00111010
 %00111010
 %11010110
 %10111000
 %10111000
 %01010000
end
 player1x=30 : rem temporary code 
 player1y=80 : player0x=40 : player0y=23

bee_comes_out
  if player0x<70 then player0x=player0x+1 else goto fight
  COLUPF=$2A : COLUBK=$9C : COLUP0=$1A : CTRLPF=$05 : REFP0=8

 pfcolors:
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
  $2a
end

  drawscreen
  w=0 : a=0 : c=0 : d=0 : e=0 : f=0 : g=0 : k=0 : l=0 : n=0
  m=19
  w{0}=1 
 goto bee_comes_out

fight
 b=rand
 if b>250 then b=b-5

fight_2 

 player1color:
 $22
 $22
 130
 130
 130
 196
 196
 196
 40
 40
 40
 40
 40
 40
 40
 236
end

 if k<10 then player1:
  %0011000
  %0010110
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
end

 if k>9 then player1:
  %0000110
  %0011100
  %0010100
  %0010100
  %0011100
  %0011100
  %0011100
  %0001000
  %0001100
  %0001110
  %0001000
  %0001110
  %0001111
  %0001110
  %0001010
  %0001110
end

 if k>20 then k=0

 if player0y>120 then goto level_7_intro bank6

 AUDV1=1 : AUDC1=1 : AUDF1=flightsong[o] : CTRLPF=$01
 p=p+1
 if p>4 then p=0 : o=o+1
 if o>95 then o=0



 if player1score=$00 then reboot
 COLUPF=$2A : COLUBK=$9c : COLUP0=$1A : scorecolor=14
  drawscreen


 if w{7} then REFP1=8 else REFP1=0

 if joy0left && player1x>20 then player1x=player1x-1 : k=k+1 : w{7}=1
 if joy0right && player1x<130 then player1x=player1x+1 : k=k+1 : w{7}=0
 if joy0fire && !e{0} && !e{1} then e{0}=1
 if !joy0fire && e{0} then e{0}=0 : e{1}=1
 if e{0} && player1y>60 then player1y=player1y-1
 if e{0} && player1y<61 then f=0 : e{0}=0 : e{1}=1
 if e{1} && player1y<80 then player1y=player1y+1
 if e{1} && player1y=80 then e{1}=0 

  if !w{1} && !w{3} then a=a+1
  if !w{1} && !w{3} && a>b then a=0 : w{1}=1 
  if w{1} && player0y<81 then player0y=player0y+2

  if !w{5} && e=0 && collision(player0,player1) then  w{5}=1 : w{6}=1 : gosub subtract_player0score_anotherbank bank1 
  if !w{5} && collision(player0,player1) && player1y>=player0y then  w{5}=1 : w{6}=1 : gosub subtract_player1score_anotherbank bank1 
  if !w{5} && e>0 && collision(player0,player1) && player1y<player0y then  w{2}=1 : w{5}=1 : gosub subtract_player0score_anotherbank bank1 
  if player0score=0 && player0y<120 then player0y=player0y+1 : goto fight_3


  if w{1} && player1score>$00 && player0y>80 then w{1}=0 : w{3}=1
  if player0y>23 && w{3} then player0y=player0y-1
  if w{3} && player0y<24 then w{3}=0 : goto fight

  if !collision(player0,player1) then w{5}=0

  if w{0} then player0x=player0x+1 : REFP0=0 else player0x=player0x-1 : REFP0=8
  if player0x>130 then w{0}=0
  if player0x<20 then w{0}=1


fight_3
  if w{2} && d<20 then d=d+1 : AUDV0=4 : AUDC0=1 
 if w{2} && d<10 then AUDF0=17
 if w{2} && d>9 then AUDF0=19
  if w{2} && d>19 then c=c+1 : d=0 : w{2}=0 : AUDV0=0
  
  if w{6} && d<20 then d=d+1 : AUDV0=4 : AUDC0=14 : AUDF0=20
  if w{6} && d>19 then c=c+1 : d=0 : w{6}=0 : AUDV0=0
  if player0y>90 then goto level_7_intro bank6

 l=l+1


 player0:
 %01000000
 %00110000
 %00111010
 %00111010
 %11010110
 %10111000
 %10111000
 %01010000
end

 if l{2} then player0:
 %01000000
 %00110000
 %10111000
 %10111000
 %11010110
 %00111010
 %00111010
 %01010000
end

 goto fight_2




 data flightsong
  24, 26, 28, 29, 31, 23, 24, 26 
  24, 26, 28, 29, 31, 29, 28, 26  
  24, 26, 28, 29, 31, 23, 24, 26 
  24, 26, 28, 29, 31, 29, 28, 26
  24, 26, 28, 29, 31, 23, 24, 26 
  24, 26, 28, 29, 31, 29, 28, 26
  18, 19, 20, 22, 23, 17, 18, 19
  18, 19, 20, 22, 23, 22, 20, 19
  18, 19, 20, 22, 23, 17, 18, 19
  18, 19, 20, 22, 23, 22, 20, 19
  18, 19, 20, 22, 23, 17, 18, 19
  18, 19, 20, 22, 23, 22, 20, 19
end


   bank 6

level_7_intro
 AUDV1=0
 k=k+1
 if k>20 then k=0
 player1x=player1x+1 : REFP1=0
 if player1x>136 then goto level_7_intro_part_2
 goto fight_2 bank5

level_7_intro_part_2
  playfield:
   XXXXXXX.....................XXXX
   XXXXXXX.....................XXXX
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXX............................X
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 pfcolors:
  $C8
  $C8
  $c8
  $f8
  $f8
  $f8
  $f8
  $f8
  $f8
  $f8
  $f8
  $F8
end

 player0score=$05

 player0y=88 : player0x=0
 player1x=40 : player1y=16
 a=0 : b=0
 a{0}=1

 d=0 : i=0 
 y=0

level_7_intro_2_main

 player0:
  %101
  %101
  %101
  %111
  %111
  %111
  %010
  %111
  %101
end



 player1:
  %101
  %101
  %011
  %001
  %001
  %111
  %111
  %111
end
 player1color:
  $86
  $86
  $86
  40
  40
  $2c
  $2c
  236
end



 COLUBK=$a6 : COLUP0=204 : PF0=$ff : CTRLPF=$05 : COLUPF=$C8

 if a{0} && player1y<88 then player1y=player1y+1 : AUDV0=4 : AUDC0=4 : AUDF0=player1y/4 : player0y=200 : REFP1=8
 if a{0} && player1y>87 then a{0}=0 : a{1}=1 : h{0}=1 : player0y=88 : player0x=0 
 if a{1} then b=b+1 : REFP1=0 : player1:
   %01111000
   %10000000
   %10000000
   %11100000
   %10000000
   %11100000
   %11100000
   %11100000
end
  if a{1} then player1color:
  $86
  $86
  40
  40
  $2c
  $2c
  $2c
  236
end
 if a>1 && b{0} then player0x=player0x+1
 if a{2} then player0y=88 :  player1x=player1x+1 : REFP1=8
 if a{1} && b>49 then a{1}=0 : a{2}=1 : REFP1=0

 if player0x<150 then player0x=player0x+1 else player0y=200
 if player1x>150 then  goto level_7_setup_2

 drawscreen
 if h{0} && i<10 then i=i+1 : AUDV0=4 : AUDC0=3 : AUDF0=12
 if h{0} && i>9 then h{0}=0 : AUDV0=0

 goto level_7_intro_2_main


level_7_setup_2
 a=0 : b=0 : c=0 : x=0 : d=1 : player1x=20 : player1y=48 : player0y=200 : COLUP0=$d8
  COLUP0=$D8
 if h{2} then e=d
 e=1
 f=(rand/2)+20
 g=(rand/4)+20
 player1score=$45
 player0score=$00
 

level_7_setup
 if d=1 then playfield:
   .XXXXX.......XXX..........XXX..
   .XXXXX.......XXX..........XXX..
   ...X..........X............X...
   ...X..........X............X...
   ...X..........X............X...
   ...X..........X............X...
   ...............................
   ...............................
   .XXXXX.............XXXX........
   .XXXXX.............XXXX........
   ...X.................X.........
   ...X.................X.........
   ...X.................X.........
end
 if d=1 then pfcolors:
  $c2
  $C2
  $C2
  $F4
  $F4
  $F4
  $F4
  $C2
  $c2
  $c2
  $C2
  $f4
  $f4
end

 if d=2 then playfield:
   ...............................
   .XXXXX.......XXX..........XXX..
   .XXXXX.......XXX..........XXX..
   ...X..........X............X...
   ...X..........X............X...
   ...X..........X............X...
   ...............................
   ...............................
   ..XXX..............XXXXX.......
   ..XXX..............XXXXX.......
   ...X.................X.........
   ...X.................X.........
   ...X.................X.........
end
 if d=2 then pfcolors:
  $c2
  $C2
  $C2
  $C2
  $F4
  $F4
  $F4
  $C2
  $c2
  $c2
  $C2
  $f4
  $f4
end


 if d=3 then playfield:
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
  .................XXXXXXXXX......
end
 if d=3 then pfcolors:
  6
  6
  6
  6
  6
  6
  6
  6
  6
  6
  6
  6
end

level_7_anim

 if c=0 then player1:
  %0010100
  %0010100
  %0010100
  %1011101
  %1011101
  %1011101
  %0111110
  %0011100
  %0011100
  %0011100
end

 if c>0 && c<11 then player1:
  %0000100
  %0000100
  %0010100
  %0011100
  %0011100
  %0011100
  %0111110
  %1011101
  %1011101
  %0011100
end

 if c>10 && c<19 then player1:
  %0010000
  %0010000
  %0010100
  %0011100
  %0011100
  %0011100
  %0111110
  %1011101
  %1011101
  %0011100
end

 player1color:
  $f2
  $86
  $86
  $86
  40
  40
  40
  $2c
  $2c
  236
end
 player0:
  %0110
  %1111
  %1111
  %1111
  %1111
  %1111
  %1111
  %0110
end

 

level_7_main

 bally=200
 if player1score>$00 then i=i+1
 if i>59 then i=0 : gosub subtract_player1score_anotherbank bank1
 if player1score=$00 then goto level_7b_cutscene

 k=(f-9)/4 : l=(g+1)/8
 m=k-1 : n=l-2


 CTRLPF=$05 : h{1}=0
 rem if !joy0up && !joy0down && !joy0left && !joy0right then c=0
 if player1y>47 && player1y<60 then h{1}=1 : CTRLPF=$01
 if player1y>90 then h{1}=1 : CTRLPF=$01

 COLUBK=$d8 : COLUPF=$c2 

 if d<>e then player0y=199
 drawscreen
 o{1}=0

 if pfread(k, l) then COLUP0=$d8 : h{2}=1 : gosub get_apple
 if pfread(m, l) then COLUP0=$d8 : h{2}=1 : gosub get_apple
 if pfread(k, n) then COLUP0=$d8 : h{2}=1 : gosub get_apple
 if pfread(m, n) then COLUP0=$d8 : h{2}=1 : gosub get_apple
 
 gosub control_level_7
 if player1x<19 && d=2 then d=1 : player1x=149 : goto level_7_setup
 if player1x>150 && d=1 then d=2 : player1x=20 : goto level_7_setup

 if c>20 then c=1

 

 if d=e then if !pfread(k, l) then if !pfread(m, l) then o{0}=1
 if o{0} then if !pfread(k, n) then if !pfread(m, n) then player0x=f : player0y=g : h{2}=0
 if collision(player0,player1) then h{0}=1 : player0y=200 : i=10 : y=y+1 : gosub get_apple



 o{0}=0
 if h{0} && i<20 then i=i+1 : AUDV0=4 : AUDC0=4 : AUDF0=i
 if h{0} && i>19 then h{0}=0 : AUDV0=0


 if !o{1} then COLUP0=$ce
 h{2}=0


 goto level_7_anim

control_level_7
 c=c+1
 if joy0up && player1y<>48 && player1y<>91 then player1y=player1y-1 
 if joy0down && player1y<>47 && player1y<>90 then player1y=player1y+1 
 if joy0up && player1y=48 && !collision(player1,playfield) then player1y=player1y-1 
 if joy0down && player1y=47 && !collision(player1,playfield) then player1y=player1y+1 
 if joy0up && player1y=91 && !collision(player1,playfield) then player1y=player1y-1 
 if joy0down && player1y=90 && !collision(player1,playfield) then player1y=player1y+1 
 if joy0left && player1x>18 then player1x=player1x-1 
 if joy0right then player1x=player1x+1 
 if player1y<10 then player1y=10
 if player1y>94 then player1y=94
 if player1x<19 && d=1 then player1x=19
 if player1x>150 && d=2 then player1x=150
 return

get_apple
 if player0score=$99 then player1score=$00 : goto level_7b_cutscene 
 gosub add_player0score
 e=(rand/128)+1
get_apple_2
 COLUP0=$D8
 if h{2} then e=d

 f=(rand/2)+20
 g=(rand/4)+20
 o{1}=1
 COLUBK=$d8 : COLUPF=$c2 
 player1color:
  $f2
  $86
  $86
  $2c
  40
  40
  40
  $2c
  $2c
  236
end


 drawscreen
 gosub control_level_7
 if player1x<19 && d=2 then d=1 : player1x=149 : goto level_7_setup
 if player1x>150 && d=1 then d=2 : player1x=20 : goto level_7_setup

 return


add_player0score
  asm
  sed ; set decimal mode
end

 player0score=player0score+$01

  asm
  cld ;clear decimal mode
end
 return 

level_7b_cutscene
 if player0score<$09 then goto level_7_setup

 y=89
 y=player0score

 k=k+1
 if c>19 then c=0
 if k>19 then k=0
 if d<3 then player1x=player1x+1 : player0x=70 : player0y=110 : c=c+1



 gosub alien_anotherbank bank1
 COLUP0=204
 drawscreen



 if d=3 then player0y=player0y-1 
 if player0y>111 then goto level_8_setup bank7

 rem above line temporary since I don't have level 8 worked out yet.

 if player1x>159 then player1x=5 : d=d+1 : goto level_7_setup
 goto level_7_anim

   bank 7

level_8_setup
 
 

  gosub man_anotherbank bank1

 player1score=$09

 d=100 : j=0 : k=0
 player0y=18 : e=100
 player1y=88 : player1x=110
 a=0 : b=0

level_8_main
  COLUP0=204 : CTRLPF=$51
  if !a{0} then bally=100 

 if d=11 && player0score=$00 then goto level_7_setup_2 bank6
 if joy0fire && !a{0} && player0score>$00 then d=88 : c=player1x : player0score = player0score-1 : y=y-1 
 if d<89 then a{0}=1 
 if a{0} then d=d-1
 if d<11 then y=y-1 : d=100 : a{0}=0

 if player1score>0 then f=f+1 
 if f{0} then player0x=e : player0y=18 : gosub alien_anotherbank bank1
 if !f{0} then player0x=c : player0y=d : player0:
  %0110
  %1111
  %1111
  %1111
  %1111
  %1111
  %1111
  %0110
end

 temp3=e-8 : temp4=e+4

 if !j{0} then AUDV0=0
 if j{0} then k=k+1 : AUDV0=4 : AUDC0=6 : AUDF0=k
 if j{0} && k>30 then k=0 : j{0}=0

 if d=18 && c>temp3 && c<temp4 then a{0}=0 : d=100 : player1score=player1score-1 : j{0}=1

 if player1score=0 then  goto level_9_setup

 if player0score=$8f then player0score=$89 : y=89
 if player0score=$7f then player0score=$79 : y=79
 if player0score=$6f then player0score=$69 : y=69
 if player0score=$5f then player0score=$59 : y=59
 if player0score=$4f then player0score=$49 : y=49
 if player0score=$3f then player0score=$39 : y=39
 if player0score=$2f then player0score=$29 : y=29
 if player0score=$1f then player0score=$19 : y=19
 if player0score=$0f then player0score=$09 : y=9


  drawscreen

 h=0 
 if g=0 then b=0 
 if joy0left && player1x>80 then player1x=player1x-1 : b=(rand/128)+1 : h=1
 if joy0right && player1x<130 then player1x=player1x+1 : b=(rand/128)+1 : h=1

 if h=1 then g=30 else  i=i+1
 if i>60 then  b=(rand/128)+1 : h=1


 if b=1 && e>80 then e=e-1 
 if b=1 && e=80 then b=2



 if b=2 && e<130 then e=e+1 
 if b=2 && e=130 then b=1

 if g>0 then g=g-1


 goto level_8_main

level_9_setup
 f=1
 gosub alien_anotherbank bank1
 COLUP0=204
 player0y=player0y-1 
 if player0y=180 then goto level_9_setup_2
 drawscreen
 goto level_9_setup

level_9_setup_2

 b=22
 bally=200
 player0y=88 : player0x=77
 player1y=88 : player1x=85

 player0:
  %10000000
  %01111111
  %01011100
  %01110101
  %01011100
  %01111111
  %10000000
end


 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
  ...............XXXX.............
end
 pfcolors:
  $52
  $52
  $16
  $16
  $16
  $16
  $16
  $16
  $16
  $16
  $16
  $16
  $D8
end
 a{0}=0

level_9_setup_2_main

 if player0y<254 then player0y=player0y-1
 player1y=player1y-1
 if !a{0} then player1:
  %00011000
  %00100000
  %11111001
  %11111111
  %11111000
  %11111001
  %11111111
  %00100000
  %00011000
end
 if !a{0} then player1color:
  204
  204
  204
  204
  204
  204
  204
  204
  204
end
 drawscreen

 AUDC0=12 : AUDV0=4 : AUDF0=b
 COLUP0=204
 if !a{0} && player1y=14 then a{0}=1 : player1x=78 : player1y=190 : gosub man_anotherbank bank1
 if a{0} && player1y=15 then goto final_level_fight_setup

 if b<21 then c{0}=1
 if b>30 then c{0}=0
 if c{0} then b=b+1 else b=b-1


 if a{0} then player0y=200 
 goto level_9_setup_2_main


final_level_fight_setup
 gosub man_anotherbank bank1 

 player0score=6
 player1score=6

 playfield:
  XXXXX..XXXXXXXXXXXXXXXXXX..XXXXX
  XXXXXX..XXXXXXXXXXXXXXXX..XXXXXX
  XXXXXXX..XXXXXXXXXXXXXX..XXXXXXX
  XXXXXXXX..XXXXXXXXXXXX..XXXXXXXX
  XXXXXXXX..XXXXXXXXXXXX..XXXXXXXX
  XXXXXXX..XXXXXXXXXXXXXX..XXXXXXX
  XXXXXX..XXXXXXXXXXXXXXXX..XXXXXX
  XXXXXX..XXXXXXXXXXXXXXXX..XXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 pfcolors:
  $0A
  $00
  $00
  $00
  $00
  $00
  $00
  $00
  $0A
  $06
  $06
  $06
end

 b=0 : c=0 : d=0 : e=0 : f=87 : z=player1y
 player1x=10 : player1y=87
 player0x=140 : player0y=87
 x=1 : l=0 : j=0 : k=0 : n=0 : q=0 : s=0 : r=0 : a=0
 j{0}=1



level_9_anim
 if l<10 then player0: 
  %110000
  %010110
  %010010
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end
  
 if l>9 then player0: 
  %001100
  %110100
  %010100
  %011100
  %011100
  %011100
  %011100
  %000100
  %001100
  %011100
  %000100
  %010100  
  %011100
  %001100  
  %010100  
  %011100  
  %001000 
  %001000
  %010000
end

final_fight_main



 l=l+1 :  n=n+1

 if l>19 then l=0
 COLUPF=$0a
 COLUBK=$0a : COLUP0=204 : NUSIZ0=$05
 PF0=$ff
 if !r{2} then AUDV0=0
 if d{0} then e=e+1 : AUDC0=1 : AUDV0=4 : AUDF0=g
 if e>0 then g=rand/8
 if d{0} && !e{0} then player0y=200
 if d{0} && e{0} then player0y=f
 if d{0} && e>25 then d{0}=0 : r{1}=1 : e=0 : q=1 : s=31

 
 if r{1} then q=q+1
 if r{1} && q=1 then r{1}=0 : r{2}=1 : q=0
 if r{2} then e=e+1 : AUDV0=4 : AUDC0=14 : AUDF0=s
 if r{2} && !e{0} then player0y=200 : s=s-1
 if r{2} && e{0} then player0y=f
 if r{2} && s=0 then r{2}=0 : e=0 : player0y=f : AUDV0=0 : a=0


 if r{3} then w=w+1 : AUDV0=4 : AUDC0=8 : AUDF0=v
 if r{3} && !w{0} then player1y=200 : v=v+1
 if r{3} && w{0} then player1y=z
 if r{3} && v=31 then r{3}=0 : w=0 : v=0 : player1y=z : AUDV0=0

 drawscreen

 if j{0} then REFP1=0 else REFP1=8

 if joy0fire && b=0 then b{0}=1 : b{1}=0

 rem next two lines are temporary
 if player0score=0 then reboot
 if player1score=0 then reboot

 if z>86 && b{1} then z=87 : b=0 : c=0
 if b{0} && !b{1} && c<42 then c=c+1 : player1y=player1y-1
 if b{0} && c>41 then b{0}=0 : b{1}=1 : z=player1y
 if b{0} && !joy0fire && !d{0} then b{0}=0 : b{1}=1 : z=player1y : c=42
 if b{1} && z<87 then  player1y=player1y+1 : z=z+1
 if collision(player1,player0) && player1y>74 && !r{2} && !r{3} && !d{0} then z=player1y : d{0}=1 : r{3}=0 :  b=2 : r{3}=1  : c=42 : player0score=player0score-1 
 if z>86 && b{1} then z=87 : b=0 : c=0
 if collision(player0,player1) && player1y<75 && b{1} && a=0 then c=42 : d{0}=1 : b{1}=1 : b{0}=0 : r{3}=0 : z=player1y : a=1
 
 if a=1 then player0y=201 : player1score=player1score-1 : a=2
 if a=2 && !player1score{0} && player0y=201 then x=x+1 
 if a=2 && player0y=201 then b{1}=1 : player0y=202 

 if d=0 && joy0left && player1x>1 then player1x=player1x-1 : k=k+1 : j{0}=0
 if d=0 && joy0right && player1x<153 then player1x=player1x+1 : k=k+1 : j{0}=1

 if k>19 then k=0
 if k=10 || k=0 then gosub man_anotherbank bank1 

 if j{1} && !r{3} then player0x=player0x-x : REFP0=0 
 if !j{1} && !r{3} then player0x=player0x+x : REFP0=8
 if x=3 && j{1} then player0x=player0x+1 
 if x=3 && !j{1} then player0x=player0x-1
 if player0x>147 && player0x<154 && !j{1} then j{1}=1 : player0x=147
 if player0x>152 then player0x=0 : j{1}=0 : REFP0=8 : goto level_9_anim
 if player0x>152 then player0x=156 : j{1}=1
 goto level_9_anim



   bank 8







 inline playerscores.asm
 inline bcd_math.asm


  vblank
  if switchreset then reboot
  return


