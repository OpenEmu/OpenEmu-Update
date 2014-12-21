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


/*functions that implements logic unique for particular levels*/


unsigned char game_level1(unsigned char clear)
{
	unsigned int delay;

	/*delay between barrel throws gets smaller on later game loops*/

	delay=game_loops*8;

	if(delay>32) delay=32;

	/*kong throws barrels in a complex loop consisting of few states*/

	switch(kong_state)
	{
	case KONG_STATE_STAND:/*kong stands with idle animation*/
		{
			if(kong_delay) --kong_delay;

			if(!kong_start) kong_stand_animation_level1();

			if(!kong_delay&&(!(kong_frame_cnt>>2)||(kong_frame_cnt>>2)==6))
			{
				kong_start=FALSE;

				oam_spr(!game_flip?kong_x-8:kong_x+24,kong_y+18,BARREL_TILE+0x00|BARREL_ATR,OAM_BARRELS+(4<<2));

				kong_state=KONG_STATE_TAKE;
				kong_frame=!game_flip?kongLargeSpriteSideL:kongLargeSpriteSideR;
				kong_delay=14;
			}
		}
		break;

	case KONG_STATE_TAKE:/*kong takes a barrel*/
		{
			--kong_delay;

			if(!kong_delay)
			{
				oam_spr(kong_x+8,kong_y+18,BARREL_TILE+0x08|BARREL_ATR,OAM_BARRELS+(4<<2));

				kong_state=KONG_STATE_MIDDLE;
				kong_frame=kongLargeSpriteFace1;
				kong_delay=12;
			}
		}
		break;

	case KONG_STATE_MIDDLE:/*kong turns to another side*/
		{
			--kong_delay;

			if(!kong_delay)
			{
				if(kong_throw_wild_barrel)
				{
					oam_spr(0,240,0,OAM_BARRELS+(4<<2));

					enemy_add(ENEMY_WILD_BARREL+kong_wild_barrel_type,kong_x+8,kong_y+18,0);

					++kong_wild_barrel_type;/*cycle through wild barrel types during level*/

					if(kong_wild_barrel_type>2) kong_wild_barrel_type=0;

					kong_throw_wild_barrel=FALSE;

					kong_state=KONG_STATE_WAIT;
					kong_frame=kongLargeSpriteThrow;
					kong_delay=68;

					break;
				}

				oam_spr(!game_flip?kong_x+24:kong_x-8,kong_y+18,BARREL_TILE+0x00|BARREL_ATR,OAM_BARRELS+(4<<2));

				kong_state=KONG_STATE_DROP;
				kong_frame=!game_flip?kongLargeSpriteSideR:kongLargeSpriteSideL;
				kong_delay=14;
			}
		}
		break;

	case KONG_STATE_DROP:/*delay after drop*/
		{
			if(kong_delay) --kong_delay;

			if(!kong_delay&&enemy_all<ENEMY_MAX)
			{
				oam_spr(0,240,0,OAM_BARRELS+(4<<2));

				enemy_add(ENEMY_ROLLING_BARREL,!game_flip?kong_x+24:kong_x-8,kong_y+18,!game_flip?1:-1);

				sfx_play(SFX_CHN+1,SFX_BARREL_ROLL,kong_x+32);

				kong_state=KONG_STATE_WAIT;
				kong_delay=68-delay;
			}
		}
		break;

	case KONG_STATE_WAIT:
		{
			--kong_delay;

			if(!kong_delay)
			{
				kong_state=KONG_STATE_STAND;
				kong_delay=64-delay;
				kong_frame_cnt=0;
			}
		}
		break;
	}

	game_show_kong(OAM_KONG,kong_x,kong_y);

	/*game level difficulty increases every 20 seconds*/

	if(game_level_difficulty_count<20*60)
	{
		++game_level_difficulty_count;
	}
	else
	{
		game_level_difficulty_count=0;

		if(game_level_difficulty<5) ++game_level_difficulty;

		kong_throw_wild_barrel=TRUE;
	}

	/*barrel fire collision check*/

	if(barrel_fire)
	{
		if(!(barrel_fire_x+16<player_x+4||barrel_fire_x>=player_x+12
		   ||barrel_fire_y+8 <player_y+4||barrel_fire_y>=player_y+12))
		{
			clear=LEVEL_LOSE;
		}
	}

	/*level ends when player gets to the top platform*/

	if(player_y==16) clear=TRUE;

	return clear;
}



unsigned char game_show_ladders(void)
{
	static unsigned char dx;
	static unsigned int flip;

	if(game_level==1)
	{
		if(!game_flip)
		{
			dx=0;
			flip=0;
		}
		else
		{
			dx=-8;
			flip=SPR_HFLIP;
		}

		oam_spr1(ladders_x[0]+dx,ladders_y[0]-1,BARREL_TILE+0x0e|BARREL_ATR|flip,OAM_LADDERS+0);
		oam_spr1(ladders_x[1]+dx,ladders_y[1]-1,BARREL_TILE+0x0e|BARREL_ATR|flip,OAM_LADDERS+4);
	}
}



unsigned char game_level2(unsigned char clear)
{
	static unsigned char i,x,y;
	static int val;

	kong_stand_animation_level2();

	game_show_kong(OAM_KONG,kong_x,kong_y);
	game_show_ladders();

	/*spacing between the cement pans depends on the game loop*/

	val=128-game_loops*16;

	if(val<48) val=48;

	/*move ladders*/

	for(i=0;i<2;++i)
	{
		switch(ladders_dir[i])
		{
		case 0:/*down*/
			if(!(game_frame_cnt&7))
			{
				if(ladders_cnt[i]<16)
				{
					++ladders_y[i];
					++ladders_cnt[i];
				}
				else
				{
					ladders_dir[i]=1;
					ladders_cnt[i]=64+(rand()&15)+(i<<4);
				}
			}
			break;

		case 1:/*delay*/
			if(ladders_cnt[i]) --ladders_cnt[i]; else ladders_dir[i]=2;
			break;

		case 2:/*up*/
			if(!(game_frame_cnt&3))
			{
				if(ladders_cnt[i]<16)
				{
					--ladders_y[i];
					++ladders_cnt[i];
				}
				else
				{
					ladders_dir[i]=3;
					ladders_cnt[i]=64+(rand()&15)+(i<<4);
				}
			}
			break;

		case 3:/*delay*/
			if(ladders_cnt[i]) --ladders_cnt[i]; else ladders_dir[i]=0;
			break;
		}

		if(ladders_dir[i]!=3)
		{
			x=ladders_x[i];
			y=ladders_y[i];

			if(player_x>=x-4&&player_x<x+4)
			{
				if(player_y>=60&&player_y<y) ++player_y;
			}
		}
	}

	/*barrel fire collision check*/

	if(!(barrel_fire_x+12<player_x+4||barrel_fire_x+4>=player_x+12
	   ||barrel_fire_y+6 <player_y+4||barrel_fire_y+2>=player_y+12))
	{
		clear=LEVEL_LOSE;
	}

	/*move kong, change direction of the conveyor belts*/

	if(game_frame_cnt&1)
	{
		if(conveyor_dir[0]) ++kong_x; else --kong_x;

		if(kong_x<26||kong_x>200)
		{
			conveyor_dir[0]^=1;

			for(i=0;i<26;++i) nametable1[POS(3,7)+i]^=0xc;

			if(kong_x<26)
			{
				conveyor_dir[2]^=1;

				sfx_play(SFX_CHN+3,SFX_SWITCH,128);

				for(i=0;i<32;++i) nametable1[POS(0,22)+i]^=0xc;
			}

			game_belts_update=TRUE;
		}

		if(!conveyor_cnt_middle)/*do not change middle conveyor direction for few seconds after beginning of the level*/
		{
			if(kong_x==120)
			{
				if((rand()&255)<64)/*the middle belt rarely changes the direction*/
				{
					conveyor_dir[1]^=1;

					game_belts_update=TRUE;

					sfx_play(SFX_CHN+3,SFX_SWITCH,128);

					for(i=0;i<15;++i)
					{
						nametable1[POS( 0,13)+i]^=0xc;
						nametable1[POS(17,13)+i]^=0xc;
					}
				}
			}
		}
		else
		{
			--conveyor_cnt_middle;
		}

		for(i=1;i<3;++i)
		{
			if(conveyor_dir[i])
			{
				++conveyor_cnt[i];
				if(conveyor_cnt[i]>val) conveyor_cnt[i]=0;
			}
			else
			{
				--conveyor_cnt[i];
				if(conveyor_cnt[i]>=val) conveyor_cnt[i]=val-1;
			}
		}
	}
	else
	{
		if(!conveyor_cnt[1]&&conveyor_items[1]<4)
		{
			if(!conveyor_dir[1])
			{
				if(enemy_add(ENEMY_CEMENT_PAN,0,88,(rand()&255)<128?0:1)) ++conveyor_items[1];
			}
		}

		if(!conveyor_cnt[2]&&conveyor_items[2]<4)
		{
			if(enemy_add(ENEMY_CEMENT_PAN,0,160,conveyor_dir[2])) ++conveyor_items[2];
		}
	}

	/*check when player touches kong*/
	
	if(player_y   <kong_y+28)
	if(player_x+12>kong_x)
	if(player_x   <kong_x+28)
	{
		clear=LEVEL_LOSE;
	}
		
	/*level ends when player gets to the top platform*/

	if(player_y==40) clear=TRUE;

	/*game level difficulty increases every 5 seconds, new fireballs are added every time*/

	if(game_level_difficulty_count<5*60)
	{
		++game_level_difficulty_count;
	}
	else
	{
		game_level_difficulty_count=0;

		if(game_fireballs<game_fireballs_max)
		{
			++game_fireballs;

			enemy_add(ENEMY_FIREBALL_1_SPAWN,barrel_fire_x,barrel_fire_y+8,0);
			sfx_play(SFX_CHN+2,SFX_FIRE_SPAWN,x+8);
		}
	}

	return clear;
}



unsigned char game_level3(unsigned char clear)
{
	static int val;

	kong_stand_animation_level2();

	game_show_kong(OAM_KONG,kong_x,kong_y);

	/*the bouncing spring is added every 180 frames or less, depending from the game loop*/

	if(!game_bounce_delay)
	{
		val=180-game_loops*16;
		if(val<64) val=64;

		game_bounce_delay=val;

		val=(rand()%(game_loops+1)&7);

		enemy_add(ENEMY_BOUNCE,!game_flip?-16+val:256-val,kong_y+18,0);
	}
	else
	{
		--game_bounce_delay;
	}

	/*game level difficulty increases every 10 seconds, along with bouncing speed*/

	if(game_level_difficulty_count<10*60)
	{
		++game_level_difficulty_count;
	}
	else
	{
		game_level_difficulty_count=0;

		if(game_bounce_speed<4) ++game_bounce_speed;
	}

	/*level ends when player gets to the top platform*/

	if(player_y==16) clear=TRUE;

	return clear;
}



unsigned char game_level4(unsigned char clear)
{
	static unsigned char i,x,y;
	static int val;

	kong_stand_animation_level2();

	game_show_kong(OAM_KONG,kong_x,kong_y);

	/*game level difficulty increases every 10 seconds or less, new fireballs are added every time*/

	val=(10-game_loops/2)*60;

	if(val<5*60) val=5*60;

	if(game_level_difficulty_count<val)
	{
		++game_level_difficulty_count;
	}
	else
	{
		game_level_difficulty_count=0;

		if(game_fireballs<game_fireballs_max)
		{
			++game_fireballs;

			i=rand()%fireball_spawn_all;

			while(1)
			{
				x=fireball_spawn_x[i];
				y=fireball_spawn_y[i];

				if(!(y>player_y-32&&y<player_y+32)&&(x>>7)!=(player_x>>7)) break;

				i=(i+1)%fireball_spawn_all;
			}

			enemy_add(ENEMY_FIREBALL_2,x,y,0);
			sfx_play(SFX_CHN+2,SFX_FIRE_SPAWN,x+8);
		}
	}

	/*check when player touches kong*/
	
	if(player_y   <kong_y+28)
	if(player_x+12>kong_x)
	if(player_x   <kong_x+28)
	{
		clear=LEVEL_LOSE;
	}

	/*level ends when player removed all the rivets*/

	if(game_rivets==8) clear=LEVEL_CLEAR;

	return clear;
}
