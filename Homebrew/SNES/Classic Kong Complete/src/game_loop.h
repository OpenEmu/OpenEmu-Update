/*
Copyright 2012 Bubble Zap Games

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//divide player horizontal speed by skipping a frame every n frames

unsigned char player_horz_div(unsigned char n)
{
	++player_speed_div;

	if(player_speed_div>=n) player_speed_div=0;

	return player_speed_div;
}



//divide player vertical speed

unsigned char player_ladder_div(void)
{
	++player_speed_div;

	if(player_speed_div>=3) player_speed_div=0;

	return !player_speed_div?1:0;
}



//add an item into the item list

void game_item_add(unsigned char x,unsigned char y,unsigned char type)
{
	if(items_all>=ITEMS_MAX) return;

	item_type[items_all]=type;
	item_x   [items_all]=x;
	item_y   [items_all]=y;

	++items_all;
}



//update item sprites

void game_item_update_oam(void)
{
	static unsigned char i,j;
	static unsigned int spr;

	spr=OAM_ITEMS;

	for(i=0;i<items_all;++i)
	{
		j=item_type[i];

		if(j!=ITEM_NONE&&j!=ITEM_ELEVATOR)
		{
			oam_spr1(item_x[i],item_y[i],itemSpriteTable[j],spr);
		}
		else
		{
			oam_spr1(0,240,0,spr);
		}

		spr+=4;
	}
}



//update displayed score in the nametable

void game_update_score(void)
{
	put_num(&nametable1[POS(1,1)],game_score,5);
	put_str(&nametable1[POS(6,1)],"0");
}



//update displayed number of lives in the nametable

void game_update_lives(unsigned char lives)
{
	static unsigned char i;

	if(!game_flip)
	{
		for(i=0;i<10;++i)
		{
			if(i<lives)
			{
				nametable1[POS(30-i,2)]=TEXT_ATR|2;
				nametable1[POS(30-i,3)]=TEXT_ATR|3;
			}
			else
			{
				nametable1[POS(30-i,2)]=TEXT_ATR;
				nametable1[POS(30-i,3)]=TEXT_ATR;
			}
		}
	}
	else
	{
		for(i=0;i<10;++i)
		{
			if(i<lives)
			{
				nametable1[POS(1+i,2)]=TEXT_ATR|2;
				nametable1[POS(1+i,3)]=TEXT_ATR|3;
			}
			else
			{
				nametable1[POS(1+i,2)]=TEXT_ATR;
				nametable1[POS(1+i,3)]=TEXT_ATR;
			}
		}

	}

	game_lives_update=TRUE;
}



//add n points to the game score, check for extra live scores
//n is a real value, but the score resolution is 10 points to increase range

void game_add_score(unsigned int n)
{
	static unsigned long prev;

	prev=game_score;

	game_score+=n/10;
	game_score_change=TRUE;

	if(game_score>99999) game_score=99999;

	if((prev< 1000&&game_score>= 1000)||//extra life, scores are divided by ten
	   (prev< 2500&&game_score>= 2500)||
	   (prev< 5000&&game_score>= 5000)||
	   (prev<10000&&game_score>=10000))
	{
		++game_lives;
		game_update_lives(game_lives);
		sfx_play(SFX_CHN+3,SFX_EXTRA_LIFE,128);
	}
}



//update displayed bonus counter in the nametable

void game_update_bonus(void)
{
	static unsigned char i,x;

	x=!game_flip?22:14;

	if(game_bonus!=0xffff||game_frame_cnt&32)
	{
		put_num(&nametable1[POS(x,1)],game_bonus<0xffff?game_bonus:0,4);
	}
	else
	{
		for(i=0;i<4;++i) nametable1[POS(x+i,1)]=0x140;
	}
}



//update all stats at once, including level and labels

void game_update_stats(void)
{
	put_str(&nametable1[POS(!game_flip?16:8,1)],"BONUS:");
	put_str(&nametable1[POS(27,1)],"L=");
	put_num(&nametable1[POS(29,1)],game_loops+1,2);

	game_update_score();
	game_update_lives(game_lives);
	game_update_bonus();
}



//display kong meta sprite
//off is offset in the OAM, x is never goes off the screen,
//y can go behind the screen in both directions,
//animation frame is set in a global variable

void game_show_kong(unsigned int off,unsigned char x,int y)
{
	static int ky;
	static unsigned char kx,i,pp;

	pp=0;

	for(i=0;i<5;++i)
	{
		kx=kong_frame[pp];

		if(kx!=128)
		{
			ky=y+kong_frame[pp+1];

			if(ky>=0)
			{
				if(ky<240)
				{
					oam_spr1(x+kx,ky,kong_frame[pp+2],off);
				}
				else
				{
					oam_spr1(0,240,0,off);
				}
			}
			else
			{
				oam_spr(x+kx,ky,kong_frame[pp+2],off);
			}

			pp+=3;
		}
		else
		{
			oam_spr1(0,240,0,off);
			++pp;
		}

		off+=4;
	}
}



//update nametable when the burning barrel starts to burn,

void barrel_show_fire(unsigned char show)
{
	if(game_level<2)
	{
		nametable1[barrel_fire_off+0]=show?(0x18c|BG_PAL(2)|BG_PRI):0x140;
		nametable1[barrel_fire_off+1]=show?(0x18d|BG_PAL(2)|BG_PRI):0x140;
	}
}



//kong animation when he raises hands by one, left-right

void kong_stand_animation_level1(void)
{
	kong_frame=kongAnimationLeftRight[kong_frame_cnt];

	if(!(game_frame_cnt&3))
	{
		++kong_frame_cnt;

		if(kong_frame_cnt==6)
		{
			sfx_play(SFX_CHN+1,SFX_KONG_LEFT,kong_x+16);
		}

		if(kong_frame_cnt==12)
		{
			sfx_play(SFX_CHN+1,SFX_KONG_RIGHT,kong_x+16);
			kong_frame_cnt=0;
		}
	}
}



//kong animation for levels 2-4 with a specific beat pattern

void kong_stand_animation_level2(void)
{
	unsigned char frame;

	kong_frame=kongAnimationBoth[kong_frame_cnt];

	frame=game_frame_cnt&255;

	if(!frame||frame==35||frame==70||frame==90) kong_frame_cnt=0;

	if(!(game_frame_cnt&3))
	{
		++kong_frame_cnt;

		if(kong_frame_cnt==4) sfx_play(SFX_CHN+1,SFX_KONG_LEFT,kong_x+16);

		if(kong_frame_cnt>5) kong_frame_cnt=5;
	}
}



//update princess meta sprite
//global variables are used, the sprite can go behind the bottom edge of the screen

void game_show_princess(unsigned char frame)
{
	static unsigned char i;
	static unsigned int flip;

	flip=!game_flip?0:SPR_HFLIP;

	if(princess_y<224)
	{
		i=frame<<1;

		if(princess_y>=0)
		{
			oam_spr1(princess_x,princess_y   ,princessAnimation[i+0]|flip,OAM_PRINCESS+0);
			oam_spr1(princess_x,princess_y+16,princessAnimation[i+1]|flip,OAM_PRINCESS+4);
		}
		else
		{
			oam_spr(princess_x,princess_y   ,princessAnimation[i+0]|flip,OAM_PRINCESS+0);
			oam_spr(princess_x,princess_y+16,princessAnimation[i+1]|flip,OAM_PRINCESS+4);
		}
	}
}



//process the items list

unsigned char process_items(unsigned char clear,unsigned char elevator)
{
	static unsigned char i,anim;
	static unsigned int score,particle;

	anim=FALSE;

	for(i=game_frame_cnt&1;i<items_all;i+=2)//process half of the list per frame
	{
		switch(item_type[i])
		{
		case ITEM_ELEVATOR://check if player touches an elevator gear
			{
				if(elevator)
				{
					if(item_y[i]+8 >player_y)
					if(item_y[i]   <player_y+16)
					if(item_x[i]+16>player_x)
					if(item_x[i]   <player_x+16)
					{
						clear=LEVEL_LOSE_WINCH;
					}
				}
			}
			break;

		case ITEM_HAMMER://check if player touches a hammer
			{
				if(item_y[i]+8>player_y+2)
				if(item_y[i]  <player_y+14)
				if(item_x[i]+8>player_x)
				if(item_x[i]  <player_x+16)
				{
					sfx_play(SFX_CHN+3,SFX_ITEM,player_x+8);
					item_type[i]=ITEM_NONE;
					anim=TRUE;

					player_hammer_time=10*60;//the hammer lasts 10 seconds
					player_hammer_phase=0;
					player_hammer_cnt=0;

					music_play(MUS_HAMMER);
				}
			}
			break;

		case ITEM_UMBRELLA://other items give score
		case ITEM_BAG:
		case ITEM_HEART:
			{
				if(item_y[i]+8>=player_y+4)
				if(item_y[i]  <=player_y+12)
				if(item_x[i]+8>=player_x+4)
				if(item_x[i]  <=player_x+12)
				{
					sfx_play(SFX_CHN+3,SFX_ITEM,player_x+8);

					switch(game_loops)
					{
					case 0:  score=300; particle=PART_TYPE_300; break;
					case 1:  score=500; particle=PART_TYPE_500; break;
					default: score=800; particle=PART_TYPE_800;
					}

					game_add_score(score);
					particle_add(particle,item_x[i],item_y[i]);

					item_type[i]=ITEM_NONE;
					anim=TRUE;
				}
			}
			break;
		}
	}

	if(anim) game_item_update_oam();

	return clear;
}



//process elevators
//they change the walkmap, no special collision checks are needed

void process_elevators(void)
{
	static unsigned char i,elevator,floor1;
	static unsigned int off,spr;

	//check if the player stands on an elevator

	floor1=(TEST_MAP(player_x+8-PLR_BBOX_HWDT,player_y+16)
	       |TEST_MAP(player_x+8+PLR_BBOX_HWDT,player_y+16))&T_ELEVATOR;

	//elevator movement speed is once per four frames

	if(!(game_frame_cnt&3))
	{
		spr=OAM_ELEVATORS;

		for(i=0;i<elevators_all;++i)
		{
			//remove an elevator from the walkmap

			if(elevator_y[i]<elevator_bottom-4)
			{
				off=(elevator_y[i]<<5)+(elevator_x[i]>>3);

				walkmap[off+0 ]=0;
				walkmap[off+1 ]=0;
				walkmap[off+32]=0;
				walkmap[off+33]=0;
			}

			//move elevator

			elevator_y[i]+=elevator_dy[i];

			if(elevator_y[i]<elevator_top)    elevator_y[i]=elevator_bottom;
			if(elevator_y[i]>elevator_bottom) elevator_y[i]=elevator_top;

			//put an elevator into the walkmap

			if(elevator_y[i]<elevator_bottom-4)
			{
				off=(elevator_y[i]<<5)+(elevator_x[i]>>3);

				walkmap[off+0 ]=T_ELEVATOR;
				walkmap[off+1 ]=T_ELEVATOR;
				walkmap[off+32]=T_ELEVATOR;
				walkmap[off+33]=T_ELEVATOR;
			}

			//update elevator sprite

			oam_spr1(elevator_x[i],elevator_y[i]-1,ITEMS_TILE+0x08|SPR_PAL(1)|SPR_PRI(2),spr);

			spr+=4;
		}
	}

	//check if the player stands on an elevator again

	elevator=(TEST_MAP(player_x+8-PLR_BBOX_HWDT,player_y+16)
	         |TEST_MAP(player_x+8+PLR_BBOX_HWDT,player_y+16))&T_ELEVATOR;

	//if he was on an elevator, but no longer on it after elevators moved,
	//move player down to avoid the falling state

	if(floor1&&!elevator)
	{
		++player_y;
		elevator=T_ELEVATOR;
	}

	return elevator;
}



//play two alternating sounds while climbing on a ladder

void game_ladder_sound(void)
{
	static unsigned char off;

	off=player_step&7;

	if(off==0) sfx_play(SFX_CHN,SFX_LADDER1,player_x);
	if(off==4) sfx_play(SFX_CHN,SFX_LADDER2,player_x);
}



//wait for next frame, update nametable
//during gameplay, only game stats and rivets on the third level needs to be updated

void game_wait_and_update_nametables()
{
	static unsigned char x;

	nmi_wait();

	copy_to_vram(POS( 0,1),(unsigned char*)&nametable1[POS( 0,1)],32*2);//stats

	if(game_lives_update)
	{
		game_lives_update=FALSE;
		x=!game_flip?21:1;

		copy_to_vram(POS(x,2),(unsigned char*)&nametable1[POS(x,2)],10*2);//lives
		copy_to_vram(POS(x,3),(unsigned char*)&nametable1[POS(x,3)],10*2);
	}

	if(!game_level)//burning barrel
	{
		copy_to_vram(POS(barrel_fire_x>>3,barrel_fire_y>>3),(unsigned char*)&nametable1[POS(barrel_fire_x>>3,barrel_fire_y>>3)],2*2);
	}

	if(game_belts_update)//conveyor belts that change directions during play
	{
		game_belts_update=FALSE;
		copy_to_vram(POS(3, 7),(unsigned char*)&nametable1[POS(3, 7)],26*2);
		copy_to_vram(POS(0,13),(unsigned char*)&nametable1[POS(0,13)],32*2);
		copy_to_vram(POS(0,22),(unsigned char*)&nametable1[POS(0,22)],32*2);
	}

	if(game_rivets_update)//rivets
	{
		game_rivets_update=FALSE;
		copy_to_vram(POS(8, 7),(unsigned char*)&nametable1[POS(8, 7)],16*2);
		copy_to_vram(POS(8,12),(unsigned char*)&nametable1[POS(8,12)],16*2);
		copy_to_vram(POS(8,17),(unsigned char*)&nametable1[POS(8,17)],16*2);
		copy_to_vram(POS(8,22),(unsigned char*)&nametable1[POS(8,22)],16*2);
	}
}



void game_update_vram_animation(void)
{
	copy_to_vram(0x1800,(game_level!=1?tileset2_gfx:tileset2alt_gfx)+game_bg_anim,512);

	//background animation counter

	if(!(game_frame_cnt&3))
	{
		game_bg_anim+=512;

		if(game_bg_anim>=512*4) game_bg_anim=0;
	}
}



unsigned char player_clip_left(void)
{
	if(game_level<3&&player_y<=40&&!game_flip) return 104; else return CLIP_LEFT;
}



unsigned char player_clip_right(void)
{
	if(game_level<3&&player_y<=40&&game_flip) return 256-104-16; else return CLIP_RIGHT;
}



#include "enemy.h"
#include "game_levels.h"
#include "cutscenes.h"



//gameplay loop

unsigned char game_loop(void)
{
	static unsigned int i,j,k,ptr,off,bright,yoff,spr,start_delay;
	static unsigned char n,floor1,floor2,clear,anim,pause,elevator,player_fall_sound;
	static int x,y,dy;

	game_flip=(game_loops/5)&1;//flip every 5 loops

	set_bright(0);
	setup_hdma_gradient(-1);
	oam_clear();

	setup_ingame_graphics();
	game_update_vram_animation();
	clear_nametables();

	//unpack level into the map array

	switch(game_level)
	{
	case 0: unrle(map,map1); break;
	case 1: unrle(map,map2); break;
	case 2: unrle(map,map3); break;
	case 3: unrle(map,map4); break;
	}

	//break some ladders in the first level on later game loops

	if(!game_level)
	{
		if(game_loops>=5 ) map[POS(16,16)]=0x10;
		if(game_loops>=10) map[POS(14,20)]=0x10;
		if(game_loops>=15) map[POS(11,12)]=0x10;
	}

	if(game_flip)
	{
		ptr=0;

		for(i=0;i<32;++i)
		{
			for(j=0;j<16;++j)
			{
				n=map[ptr+j];
				map[ptr+j]=map[ptr+31-j];
				map[ptr+31-j]=n;
			}

			ptr+=32;
		}
	}

	enemy_clear();
	particles_clear();

	items_all=0;
	elevators_all=0;
	fireball_spawn_all=0;

	//convert map into the walkmap, check object markers and set up objects lists

	ptr=0;

	y=0;

	for(i=0;i<28;++i)
	{
		x=0;

		for(j=0;j<32;++j)
		{
			n=map[ptr];

			//check for object markers

			switch(n)
			{
			case 0x48://elevator dangerous parts
			case 0x4a:
				if(game_level==2) game_item_add(x-8,y,ITEM_ELEVATOR);
				break;

			case 0x4c://barrel fire
				barrel_fire_x=!game_flip?x:x-8;
				barrel_fire_y=y;
				barrel_fire_off=!game_flip?ptr:ptr-1;
			case 0x4d:
				n=0;
				break;

			case 0xf3://fireball spawn
				if(fireball_spawn_all<FIREBALL_SPAWN_MAX)
				{
					fireball_spawn_x[fireball_spawn_all]=x-4;
					fireball_spawn_y[fireball_spawn_all]=y;
					++fireball_spawn_all;
				}
				break;

			case 0xf4://fireball
				enemy_add(ENEMY_FIREBALL_1,x-4,y,0);
				break;

			case 0xf6://hammer
				game_item_add(x-4,y-4,ITEM_HAMMER);
				break;

			case 0xf7://umbrella
				game_item_add(x-4,y-4,ITEM_UMBRELLA);
				break;

			case 0xf8://bag
				game_item_add(x-4,y-4,ITEM_BAG);
				break;

			case 0xf9://heart
				game_item_add(x-4,y-4,ITEM_HEART);
				break;

			case 0xfa://elevator top bound
				elevator_top=y;
				break;

			case 0xfb://elevator bottom bound
				elevator_bottom=y;
				break;

			case 0xfc://elevator platform down
			case 0xfd://elevator platform up
				if(elevators_all<ELEVATORS_MAX)
				{
					elevator_x [elevators_all]=!game_flip?x+8:x-16;
					elevator_y [elevators_all]=y;
					elevator_dy[elevators_all]=(n==0xfc?1:-1);
					++elevators_all;
				}
				break;

			case 0xfe://kong
				kong_x=!game_flip?x:x-24;
				kong_y=y-1;
				break;

			case 0xff://player start position
				player_x=x-4;
				player_y=y;
				break;
			}

			if(n>=128) n=0;

			k=n+0x0140|(n<0x40?BG_PAL(1):BG_PAL(2));

			k|=(n<0x40||n>=(game_level==1?0x44:0x4e)?0:BG_PRI);

			if(n>=0x4e&&j<8) k|=BG_VFLIP;

			if(game_level==1)
			{
				if(n>=0x11&&n<0x17) k|=BG_PRI;
			}

			if(game_flip) k|=BG_HFLIP;

			nametable1[ptr]=k;

			if(game_level==1)
			{
				switch(n)
				{
				case 0x40://barrel top
				case 0x41:
				case 0x44://conveyor belts
				case 0x45:
				case 0x47:
				case 0x48:
				case 0x49:
				case 0x4b: n=0x08; break;
				case 0x46://conveyor ladders
				case 0x4a: n=0x20; break;
				}
			}

			off=(i<<8)+j;

			for(k=0;k<8;++k)
			{
				walkmap[off]=tileAttribute[n][k];
				off+=32;
			}

			if(n==0x30)//ladder
			{
				if(game_level==1)//remove moving parts of the ladders from nametable
				{
					if(i==8) nametable1[ptr]=0x157|BG_PAL(1);
					if(i==9) nametable1[ptr]=0x140;
				}
			}

			++ptr;
			x+=8;
		}

		y+=8;
	}

	switch(game_loops)
	{
	case 0:  game_bonus=5000; break;
	case 1:  game_bonus=6000; break;
	case 2:  game_bonus=7000; break;
	default: game_bonus=8000;
	}

	game_frame_cnt=-1;//to make it zero on the first iteration
	game_bg_anim=0;
	game_rivets=0;
	game_object_jump=0;
	game_level_difficulty=game_loops+1;
	game_level_difficulty_count=0;
	game_fireballs=0;
	game_update_palette=FALSE;
	game_score_change=FALSE;
	game_bonus_change=FALSE;
	game_bonus_cnt=0;
	game_bounce_delay=0;
	game_bounce_speed=game_loops;
	game_lives_update=FALSE;
	game_belts_update=FALSE;
	game_rivets_update=FALSE;

	if(game_bounce_speed>4) game_bounce_speed=4;

	player_anim=!game_flip?playerWalkAnimRight[0]:playerWalkAnimLeft[0];
	player_step=0;
	player_fall=FALSE;
	player_ladder=FALSE;
	player_jump=JUMP_NONE;
	player_dir=DIR_NONE;
	player_dir_prev=!game_flip?DIR_RIGHT:DIR_LEFT;
	player_speed_div=0;
	player_hammer_time=0;
	player_fall_sound=255;
	player_rivet_delay=0;

	bright=0;
	clear=0;
	pause=FALSE;
	splat_cnt=255;

	switch(game_level)
	{
	case 0:
	case 1:
	case 2:
		game_fireballs_max=2+game_loops/2;
		if(game_fireballs_max>4) game_fireballs_max=4;
		break;

	case 3:
		game_fireballs_max=4+game_loops;
		if(game_fireballs_max>8) game_fireballs_max=8;
		break;
	}

	if(game_level_difficulty>5) game_level_difficulty=5;

	start_delay=50;

	kong_frame_cnt=0;
	kong_state=KONG_STATE_STAND;
	kong_delay=20;
	kong_throw_wild_barrel=TRUE;
	kong_frame=kongAnimationLeftRight[0];
	kong_start=TRUE;
	kong_wild_barrel_type=game_loops%3;

	princess_x=!game_flip?80:256-80-16;
	princess_y=12;

	barrel_fire=FALSE;

	if(game_level==1)
	{
		barrel_show_fire(TRUE);

		conveyor_cnt_middle=10*60;

		for(i=0;i<3;++i)
		{
			conveyor_cnt[i]=0;
			conveyor_items[i]=0;
		}

		conveyor_dir[0]=1^game_flip;
		conveyor_dir[1]=0;
		conveyor_dir[2]=game_flip;

		ladders_x[0]=32;
		ladders_x[1]=216;

		for(i=0;i<2;++i)
		{
			ladders_y  [i]=64;
			ladders_dir[i]=0;
			ladders_cnt[i]=0;
		}
	}

	set_background(game_level+1);
	game_update_stats();
	update_nametables();
	setup_palettes();
	update_palette();

	for(i=0;i<512;i+=4) oam_size(i,1);//all sprites are 16x16

	if(!game_level)//barrels pile for the first level
	{
		x=!game_flip?0:208;

		oam_spr1(x+12,23,BARREL_TILE+0x0c|BARREL_ATR,OAM_BARRELS+(0<<2));
		oam_spr1(x+22,23,BARREL_TILE+0x0c|BARREL_ATR,OAM_BARRELS+(1<<2));
		oam_spr1(x+10,39,BARREL_TILE+0x0c|BARREL_ATR,OAM_BARRELS+(2<<2));
		oam_spr1(x+24,39,BARREL_TILE+0x0c|BARREL_ATR,OAM_BARRELS+(3<<2));
	}

	game_show_kong(OAM_KONG,kong_x,kong_y);
	game_show_princess(0);
	game_show_ladders();

	setup_hdma_gradient(game_level+1);

	music_play(MUS_LEVEL1);

	while(1)
	{
		game_wait_and_update_nametables();
		if(!pause) game_update_vram_animation();

		if(game_update_palette)
		{
			game_update_palette=FALSE;
			update_palette();
		}

		if(!pause)
		{
			if(bright<15)
			{
				++bright;
				set_bright(bright);
			}
		}
		else
		{
			if(bright>8)
			{
				--bright;
				set_bright(bright);
			}
		}

		pad_read_ports();

		i=pad_poll_trigger(0);

		if(!start_delay&&i&PAD_START)
		{
			pause^=TRUE;
			sfx_play(SFX_CHN,SFX_PAUSE,128);
		}

		if(start_delay)
		{
			--start_delay;

			if(!start_delay) game_item_update_oam();

			continue;
		}

		if(pause) continue;

		++game_frame_cnt;

		//process splat

		if(splat_cnt<((sizeof(splatAnimation)/sizeof(unsigned int))<<1))
		{
			oam_spr1(splat_x,splat_y,splatAnimation[splat_cnt>>1],OAM_SPLAT);

			++splat_cnt;

			continue;//splat animation pauses the gameplay
		}
		else
		{
			oam_spr1(0,240,0,OAM_SPLAT);
		}

		//process elevators and move the player vertically if he is standing on a platform

		elevator=process_elevators();

		//process player

		i=pad_poll(0);

		if(game_test_mode&&(i&PAD_SELECT))
		{
			clear=LEVEL_CLEAR;
			break;
		}

		if(player_jump!=JUMP_AIR)
		{
			if(!player_fall&&!player_ladder)
			{
				//conveyor belts

				if(game_level==1)
				{
					if(game_frame_cnt&1)
					{
						j=0;

						if(player_y==88)//middle belt, always goes to or from the center
						{
							if(!conveyor_dir[1])
							{
								if(player_x<128) j=2; else j=1;
							}
							else
							{
								if(player_x>128) j=2; else j=1;
							}
						}

						if(player_y==160)//bottom belt
						{
							if(!conveyor_dir[2]) j=1; else j=2;
						}

						switch(j)
						{
						case 1: if(player_x>CLIP_LEFT ) --player_x; break;
						case 2: if(player_x<CLIP_RIGHT) ++player_x; break;
						}
					}
				}

				//user controlled movement

				yoff=player_y&7;

				player_dir=DIR_NONE;

				if(i&PAD_LEFT)
				{
					if(player_x>=player_clip_left())
					{
						if(player_horz_div(3))
						{
							--player_x;
							++player_step;
						}

						player_dir=DIR_LEFT;
					}
				}

				if(i&PAD_RIGHT)
				{
					if(player_x<=player_clip_right())
					{
						if(player_horz_div(3))
						{
							++player_x;
							++player_step;
						}

						player_dir=DIR_RIGHT;
					}
				}

				x=player_x+8;
				y=player_y+16;

				if(TEST_MAP(x,y)&T_RIVET)//remove a rivet
				{
					off=NAM_OFF(x,y);

					nametable1[off]=0x144|BG_PAL(1);

					map[off   ]=0xf5;//mark as a wall for fireballs
					map[off-32]=0xf5;

					x=((off&31)<<3)-4;
					y=((off>>5)<<3)-4;

					particle_add(PART_TYPE_SMOKE,x,y);
					particle_add(PART_TYPE_100  ,x,y-8);

					game_add_score(100);

					x=player_x+8;
					y=player_y+16;

					off=WMAP_OFF(x,y);

					for(j=0;j<8;++j)
					{
						walkmap[off]=0;
						off+=32;
					}

					++game_rivets;

					sfx_play(SFX_CHN,SFX_RIVET,x);

					player_rivet_delay=10;//stop gravity to give the player some time to walk off a removed rivet

					game_rivets_update=TRUE;
				}

				//push the player out of solid floor when walking on the slopes
				//or riding an elevator platform

				--y;

				while((TEST_MAP(player_x+8-PLR_BBOX_HWDT,y)
				|TEST_MAP(player_x+8+PLR_BBOX_HWDT,y))&T_SOLID)
				{
					--player_y;
					--y;
				}
			}

			if(player_rivet_delay) --player_rivet_delay;

			if(!player_ladder)
			{
				//fall down if there is no floor under the character

				floor1=TEST_MAP(player_x+8-PLR_BBOX_HWDT,player_y+16)
				|TEST_MAP(player_x+8+PLR_BBOX_HWDT,player_y+16);

				if(!(floor1&T_SOLID)&&!player_rivet_delay)
				{
					++player_y;

					if(!player_fall)
					{
						player_fall=TRUE;
						player_dir=DIR_NONE;
						player_jump_y=player_y;
						player_fall_sound=0;
					}
				}
				else
				{
					if(player_fall)
					{
						player_fall=FALSE;
						player_fall_sound=255;
						player_step=0;
						player_dir=player_dir_prev;

						y=player_jump_y+MAX_FALL_HEIGHT;

						if(elevator) y+=32; //to avoid losing while jumping on a moving platform

						if(!elevator&&player_y>=y)
						{
							sfx_play(SFX_CHN,SFX_HERO_LANDS,player_x);
							clear=LEVEL_LOSE;//fell from a height
						}
					}
				}

				//check for ladder

				if(!player_fall&&!player_hammer_time)
				{
					if(i&PAD_UP)
					{
						floor1=TEST_MAP(player_x+7,player_y+15);
						floor2=TEST_MAP(player_x+9,player_y+15);

						if((floor1&T_LADDER)&&(floor2&T_LADDER))
						{
							player_ladder=TRUE;
							player_x=(player_x&~7)+4;
						}
					}

					if(i&PAD_DOWN)
					{
						floor1=TEST_MAP(player_x+7,player_y+16);
						floor2=TEST_MAP(player_x+9,player_y+16);

						if((floor1&T_LADDER)&&(floor2&T_LADDER))
						{
							player_ladder=TRUE;
							player_x=(player_x&~7)+4;
						}
					}
				}

				switch(player_dir)
				{
				case DIR_LEFT:  player_anim=playerWalkAnimLeft [(player_step>>2)%6]; break;
				case DIR_RIGHT: player_anim=playerWalkAnimRight[(player_step>>2)%6]; break;
				}
			}

			if(player_ladder)
			{
				//climbing on a ladder

				x=player_x+7;
				anim=FALSE;

				if(i&PAD_UP)
				{
					floor1=TEST_MAP(x,player_y+15);

					if(!(floor1&T_LADDER_BROKEN))
					{
						if(floor1&T_LADDER)
						{
							if(player_ladder_div())
							{
								--player_y;
								++player_step;

								game_ladder_sound();
							}

							anim=TRUE;
						}
						else
						{
							player_ladder=FALSE;
						}
					}
				}

				if(i&PAD_DOWN)
				{
					floor1=TEST_MAP(x,player_y+16);

					if(!(floor1&T_LADDER_BROKEN))
					{
						if(floor1&T_LADDER)
						{
							if(player_ladder_div())
							{
								++player_y;
								++player_step;

								game_ladder_sound();
							}

							anim=TRUE;
						}
						else player_ladder=FALSE;
					}
				}

				//update player sprite if climbing
				//depending from distance from the top of the ladder

				if(anim)
				{
					off=0;

					if(!(TEST_MAP(x,player_y+15)&(T_LADDER|T_LADDER_BROKEN))) off=6; else
					if(!(TEST_MAP(x,player_y+12)&(T_LADDER|T_LADDER_BROKEN))) off=0; else
					if(!(TEST_MAP(x,player_y+8 )&(T_LADDER|T_LADDER_BROKEN))) off=4; else
					if(!(TEST_MAP(x,player_y+4 )&(T_LADDER|T_LADDER_BROKEN))) off=2;

					player_anim=playerClimbAnim[((player_step>>2)&1)+off];
				}
			}
		}

		switch(player_jump)
		{
		case JUMP_NONE:
			{
				if(i&(PAD_A|PAD_B))
				{
					if(!player_ladder&&!player_fall&&!player_hammer_time)
					{
						player_jump=JUMP_AIR;
						player_jump_cnt=0;
						player_jump_y=player_y;
						sfx_play(SFX_CHN,SFX_HERO_JUMP,player_x+8);
					}
					else
					{
						player_jump=JUMP_DUMMY;
					}
				}
			}
			break;

		case JUMP_LAND:
		case JUMP_DUMMY:
			{
				if(!(i&PAD_A)&&!(i&PAD_B)) player_jump=JUMP_NONE;
			}
			break;

		case JUMP_AIR:
			{
				dy=playerJumpTable[player_jump_cnt++];

				player_y+=dy;

				if(player_jump_cnt>=sizeof(playerJumpTable)/sizeof(int))
				{
					player_jump=JUMP_LAND;
					player_fall=TRUE;
					sfx_play(SFX_CHN,SFX_HERO_FALL,player_x);
				}

				//check for floor while midair
				//if floor is found near the bottom edge of the player,
				//push him out of the floor

				if(player_jump_cnt>2)//to avoid a rare problem when a jump is cancelled right after pressing a button (so there is sound of the jump, but no actual jump)
				{
					for(i=0;i<2;++i)
					{
						if((TEST_MAP(player_x+8-PLR_BBOX_HWDT,player_y+16-i)
									|TEST_MAP(player_x+8+PLR_BBOX_HWDT,player_y+16-i))&T_SOLID)
						{
							player_jump=JUMP_LAND;
							player_fall=TRUE;
							player_y-=i;
							sfx_play(SFX_CHN,SFX_HERO_LANDS,player_x);
							break;
						}
					}
				}
			}
			break;
		}

		if(player_fall||player_jump==JUMP_AIR)
		{
			if(player_jump!=JUMP_AIR&&player_fall_sound<2)
			{
				++player_fall_sound;

				if(player_fall_sound==2) sfx_play(SFX_CHN,SFX_HERO_FALL,player_x);
			}

			switch(player_dir)
			{
			case DIR_LEFT:
				{
					player_anim=PLAYER_TILE+0x28|PLAYER_ATR;

					if(player_horz_div(2))
					{
						--player_x;

						if(player_x<=player_clip_left()) player_dir=DIR_RIGHT;
					}
				}
				break;

			case DIR_RIGHT:
				{
					player_anim=PLAYER_TILE+0x28|PLAYER_ATR|SPR_HFLIP;

					if(player_horz_div(2))
					{
						++player_x;

						if(player_x>=player_clip_right()) player_dir=DIR_LEFT;
					}
				}
				break;
			}
		}

		if(player_dir!=DIR_NONE) player_dir_prev=player_dir;

		clear=process_items(clear,elevator);

		particle_process();

		//level-specific code

		switch(game_level)
		{
		case 0: clear=game_level1(clear); break;
		case 1: clear=game_level2(clear); break;
		case 2: clear=game_level3(clear); break;
		case 3: clear=game_level4(clear); break;
		}

		//process enemy

		clear=enemy_process(clear);

		//set other sprites

		if(player_hammer_time&&player_jump!=JUMP_AIR&&!player_fall&&!clear)
		{
			off=(player_hammer_phase+(player_dir_prev==DIR_LEFT?0:2))<<1;

			oam_spr(player_x+hammerOffsets[off+0],player_y+hammerOffsets[off+1],hammerSprites[off+0],OAM_HAMMER+(0<<2));
			oam_spr(player_x,player_y,hammerSprites[off+1],OAM_HAMMER+(1<<2));

			spr=player_anim+0x08;
		}
		else
		{
			oam_spr(0,240,0,OAM_HAMMER+(0<<2));
			oam_spr(0,240,0,OAM_HAMMER+(1<<2));

			spr=player_anim;
		}

		oam_spr1(player_x,player_y-1,spr,OAM_PLAYER);

		game_show_princess(game_frame_cnt&32?2:0);

		if(!(game_frame_cnt&255))
		{
			particle_add(PART_TYPE_HELP,!game_flip?96:176,12);
		}

		//update stats

		++game_bonus_cnt;//separate counter to prevent early decrement

		if(!(game_bonus_cnt&63))
		{
			if(game_bonus)
			{
				if(game_bonus==1000) music_play(MUS_TIME_OUT);

				game_bonus-=100;
				game_bonus_change=TRUE;
			}
			else
			{
				clear=LEVEL_LOSE_TIME_OUT;
			}
		}

		if(game_score_change)
		{
			game_update_score();
			game_score_change=FALSE;
		}

		if(game_bonus_change)
		{
			game_update_bonus();
			game_bonus_change=FALSE;
		}

		if(game_object_jump) --game_object_jump;

		if(player_hammer_time)
		{
			if(!(player_hammer_time&7))
			{
				set_palette(192,16,player_hammer_time&8?sprites5alt_pal:sprites5_pal);
				game_update_palette=TRUE;
			}

			--player_hammer_time;

			if(!player_hammer_time)
			{
				music_play(game_bonus>=1000?MUS_LEVEL1:MUS_TIME_OUT);
				set_palette(192,16,sprites5_pal);//set normal colors for firefoxes
				game_update_palette=TRUE;
			}
			else
			{
				++player_hammer_cnt;

				if((player_hammer_phase&&player_hammer_cnt==4)//hammer at the top for 4 frames
						||(!player_hammer_phase&&player_hammer_cnt==6))//hammer at the side for 6 frames
				{
					player_hammer_phase^=1;
					player_hammer_cnt=0;
				}
			}
		}

		if(clear) break;
	}

	//run the smoke animation in the third level

	if(game_level==3&&clear==LEVEL_CLEAR)
	{
		for(i=0;i<32;++i)
		{
			particle_process();
			game_wait_and_update_nametables();
		}
	}

	//delay to allow player to see what happened

	if(clear!=LEVEL_CLEAR)
	{
		music_stop();
		sfx_play(SFX_CHN+3,SFX_HERO_HIT,player_x);

		delay(30);
	}

	//hide all particles, hammer, enemy, and items
	//that's like in the arcade original

	particles_clear();

	oam_spr(0,240,0,OAM_HAMMER+(0<<2));//hide hammer
	oam_spr(0,240,0,OAM_HAMMER+(1<<2));

	enemy_clear();
	enemy_process(0);

	for(i=0;i<items_all;++i) item_type[i]=ITEM_NONE;

	barrel_show_fire(FALSE);

	nmi_wait();
	game_item_update_oam();
	update_nametables();

	//show cutscene

	if(clear!=LEVEL_CLEAR)
	{
		if(clear==LEVEL_LOSE_TIME_OUT) game_bonus=0xffff;

		music_play(MUS_LOSE);

		//lose animation

		for(i=0;i<28*4;++i)
		{
			oam_spr1(player_x,player_y-1,playerLoseAnim[(i>>2)&3],OAM_PLAYER);
			game_update_bonus();
			game_wait_and_update_nametables();

			++game_frame_cnt;
		}

		for(i=0;i<150;++i)
		{
			if(i&8)
			{
				spr=PLAYER_TILE+0x2e|PLAYER_ATR|(player_dir_prev==DIR_LEFT?0:SPR_HFLIP);
			}
			else
			{
				spr=PLAYER_TILE+0x4a|PLAYER_ATR|(player_dir_prev==DIR_LEFT?0:SPR_HFLIP);
			}

			oam_spr1(player_x,player_y-1,spr,OAM_PLAYER);

			game_update_bonus();
			game_wait_and_update_nametables();

			++game_frame_cnt;
		}

		if(game_lives==1)
		{
			game_update_lives(0);
			game_wait_and_update_nametables();

			game_over();
		}
	}
	else
	{
		//clear animation

		music_play(MUS_STAGE_CLEAR);

		oam_spr1(player_x,player_y-1,princess_x<player_x?playerWalkAnimLeft[0]:playerWalkAnimRight[0],OAM_PLAYER);

		i=50;

		while(i||game_bonus)
		{
			if(i) --i;

			if(game_bonus)
			{
				game_add_score(100);
				game_bonus-=100;
			}

			game_update_bonus();
			game_update_score();
			game_wait_and_update_nametables();
		}

		if(game_level<3) cutscene_next_level(); else delay(150);
	}

	fade_screen(FALSE,TRUE);

	return clear;
}
