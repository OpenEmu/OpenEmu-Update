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

//clear enemy list

void enemy_clear(void)
{
	static unsigned char i;

	memset(enemy_type,ENEMY_NONE,ENEMY_MAX);

	enemy_free=0;
	enemy_all=0;

	for(i=0;i<ENEMY_MAX;++i) oam_spr(0,240,0,OAM_ENEMY+(i<<2));

}



//add an enemy into the list
//returns FALSE when there is no room in the list

unsigned char enemy_add(unsigned char type,int x,int y,int dx)
{
	static unsigned char i,j,off,take_ladder;

	i=enemy_free;

	for(j=0;j<ENEMY_MAX;++j)
	{
		if(enemy_type[i])
		{
			++i;
			continue;
		}

		enemy_type[i]=type;

		switch(type)
		{
		case ENEMY_WILD_BARREL_CHANGE:
		case ENEMY_WILD_BARREL_SIDE:
			/*direction is inverted for side changing wild barrel, as it hits top floor at the start*/
			if(type==ENEMY_WILD_BARREL_CHANGE) dx=-1; else dx=1;
			if(game_flip) dx=-dx;
		case ENEMY_WILD_BARREL_DOWN:
		case ENEMY_ROLLING_BARREL:
			enemy_x    [i]=x;
			enemy_y    [i]=y;
			enemy_dx   [i]=dx;
			enemy_fall [i]=0;
			enemy_anim [i]=0;
			enemy_land [i]=255;
			break;

		case ENEMY_FIREBALL_1_JUMP_IN:
		case ENEMY_FIREBALL_1_SPAWN:
			enemy_x     [i]=x;
			enemy_y     [i]=y-2;
			enemy_dx    [i]=dx;
			enemy_cnt   [i]=0;
			enemy_ladder[i]=DIR_NONE;
			break;

		case ENEMY_FIREBALL_1:
		case ENEMY_FIREBALL_2:
			enemy_x     [i]=x;
			enemy_y     [i]=y;
			enemy_dx    [i]=dx;
			enemy_cnt   [i]=8+(rand()&7);
			enemy_ladder[i]=DIR_NONE;
			enemy_spawn [i]=0;
			break;

		case ENEMY_BOUNCE:
			enemy_ix   [i]=x<<BOUNCE_FP;
			enemy_iy   [i]=y<<BOUNCE_FP;
			enemy_sy   [i]=y;
			enemy_idy  [i]=-3<<BOUNCE_FP;
			enemy_land [i]=0;
			enemy_speed[i]=game_bounce_speed<<1;
			sfx_play(SFX_CHN+2,SFX_BOUNCE_JUMP,x);
			break;

		case ENEMY_CEMENT_PAN:
			enemy_ix[i]=dx?-16:256;
			enemy_y [i]=y;
			break;
		}

		break;
	}

	if(j==ENEMY_MAX) return FALSE;

	++enemy_free;
	++enemy_all;

	if(enemy_free>=ENEMY_MAX) enemy_free=0;

	return TRUE;
}



//remove an enemy from the list

unsigned char enemy_remove(unsigned char i,unsigned char destroy)
{
	static unsigned char fire;

	oam_spr(0,240,0,OAM_ENEMY+(i<<2));//hide sprite

	fire=FALSE;

	switch(enemy_type[i])
	{
	case ENEMY_ROLLING_BARREL://rolling barrel fires the burning barrel when gets there
		if(!destroy) fire=TRUE;
		break;

	case ENEMY_FIREBALL_1:
		fire=TRUE;
	case ENEMY_FIREBALL_2:
	case ENEMY_FIREBALL_1_JUMP_IN:
	case ENEMY_FIREBALL_1_SPAWN:
		if(destroy&&game_fireballs) --game_fireballs;
		break;

	case ENEMY_CEMENT_PAN://update number of cement pans on a conveyor belt
		if(enemy_y[i]<160) --conveyor_items[1]; else --conveyor_items[2];
		break;
	}

	enemy_type[i]=ENEMY_NONE;
	enemy_free=i;
	
	--enemy_all;

	return fire;
}



//check for jumping over an object, like barrel, firefox, or a cement pan

unsigned char enemy_check_object_jump(unsigned char ox,unsigned char oy)
{
	if(oy>=player_y+12&&oy<player_jump_y+8)
	{
		if(player_x>=ox-4&&player_x<ox+4)
		{
			if(!game_object_jump&&player_jump==JUMP_AIR) return TRUE;
		}
	}

	return FALSE;
}



//process all enemies and update their sprites

unsigned char enemy_process(unsigned char clear)
{
	static unsigned char i,frame,fire,type,particle,jump_over,barrels_jumped,hammer,hammer_off;
	static unsigned int spr,anim,score,val;
	static unsigned char ox,oy,sy,hx,hy,off;
	static unsigned char random,difficulty,barrel_dir,take_ladder;
	static int dx;

	difficulty=(game_level_difficulty>>1)+1;

	hammer=(player_hammer_time&&player_jump!=JUMP_AIR&&!player_fall)?TRUE:FALSE;
	hammer_off=(player_hammer_phase+(player_dir_prev==DIR_LEFT?0:2))<<1;

	spr=OAM_ENEMY;
	frame=game_frame_cnt;
	fire=FALSE;
	jump_over=FALSE;
	barrels_jumped=0;

	for(i=0;i<ENEMY_MAX;++i)
	{
		type=enemy_type[i];

		if(type==ENEMY_NONE)
		{
			spr+=4;
			continue;
		}

		switch(type)
		{
		case ENEMY_ROLLING_BARREL:
			{
				ox=enemy_x[i];
				oy=enemy_y[i];

				if(enemy_check_object_jump(ox,oy))
				{
					++barrels_jumped;
					jump_over=TRUE;
				}

				if(enemy_land[i]<sizeof(barrelLandingAnimation))
				{
					sy=oy-barrelLandingAnimation[enemy_land[i]++];
				}
				else
				{
					sy=oy;
				}

				oam_spr1(ox,sy,BARREL_TILE|((enemy_anim[i]&3)<<1)|BARREL_ATR,spr);

				if(!((TEST_MAP(ox+6,oy+14)|TEST_MAP(ox+10,oy+14))&T_LDRTOP))
				{
					++enemy_fall[i];
					++oy;

					if(frame&1) break;//half the horizontal speed while falling
				}
				else
				{
					if(enemy_fall[i]>1)
					{
						enemy_dx  [i]=0-enemy_dx[i];
						enemy_land[i]=0;

						sfx_play(SFX_CHN+2,SFX_BARREL1+(rand()&3),ox);
					}

					enemy_fall[i]=0;
				}

				ox+=enemy_dx[i];

				if((ox&7)==4)
				{
					//when a barrel is on top of a ladder, make a decision as described in
					//http://donhodges.com/Controlling_the_barrels_in_Donkey_Kong.htm

					if(TEST_MAP(ox+8,oy+14)&T_LADDER)
					{
						take_ladder=FALSE;

						if(!barrel_fire) take_ladder=TRUE;

						if(oy<player_y+8)
						{
							random=rand();

							if((random&3)<difficulty)
							{
								if(ox==player_x)
								{
									take_ladder=TRUE;
								}
								else
								{
									barrel_dir=(enemy_dx[i]==1)?DIR_RIGHT:DIR_LEFT;

									if(player_dir==barrel_dir)
									{
										take_ladder=TRUE;
									}
									else
									{
										if(!(random&0x18)) take_ladder=TRUE;
									}
								}
							}
						}

						if(take_ladder)
						{
							enemy_land[i]=255;
							enemy_fall[i]=0;
							enemy_type[i]=ENEMY_LADDER_BARREL;
							break;
						}
					}
				}

				if(!(frame&7)) ++enemy_anim[i];

				if(oy>=192)
				{
					if(!game_flip)
					{
						if(ox==32)
						{
							fire=enemy_remove(i,FALSE);
							type=ENEMY_NONE;
						}
					}
					else
					{
						if(ox==256-32-16)
						{
							fire=enemy_remove(i,FALSE);
							type=ENEMY_NONE;
						}
					}
				}
			}
			break;

		case ENEMY_LADDER_BARREL:
			{
				ox=enemy_x[i];
				oy=enemy_y[i];

				oam_spr1(ox,oy,BARREL_TILE+0x08|((enemy_anim[i]&1)<<1)|BARREL_ATR,spr);

				if(!(frame&1))
				{
					++oy;

					if(TEST_MAP(ox+8,oy+14)&T_FLOOR)
					{
						enemy_dx  [i]=0-enemy_dx[i];
						enemy_type[i]=ENEMY_ROLLING_BARREL;
					}
				}

				if(!(frame&7)) ++enemy_anim[i];
			}
			break;

		case ENEMY_WILD_BARREL_DOWN:
		case ENEMY_WILD_BARREL_CHANGE:
		case ENEMY_WILD_BARREL_SIDE:
			{
				ox=enemy_x[i];
				oy=enemy_y[i];

				oam_spr1(ox,oy,BARREL_TILE+0x08|((enemy_anim[i]&1)<<1)|BARREL_ATR,spr);

				if(enemy_fall[i])
				{
					--enemy_fall[i];
				}
				else
				{
					ox+=enemy_dx[i];
					++oy;

					if(TEST_MAP(ox+8,oy+14)==T_FLOOR)
					{
						if(type!=ENEMY_WILD_BARREL_SIDE) enemy_dx[i]=0-enemy_dx[i];
						enemy_fall[i]=4;

						sfx_play(SFX_CHN+2,SFX_BARREL1+(rand()&3),ox);
					}

					if(type!=ENEMY_WILD_BARREL_SIDE) hy=192; else hy=188;

					if(oy>=hy)//wild barrel turns into a rolling barrel at the bottom
					{
						enemy_type[i]=ENEMY_ROLLING_BARREL;
						enemy_fall[i]=0;
						enemy_dx  [i]=!game_flip?1:-1;
					}
				}

				if(!(frame&7)) ++enemy_anim[i];
			}
			break;

		case ENEMY_FIREBALL_1_JUMP_IN:
			{
				off=enemy_cnt[i];

				if(!game_flip)
				{
					ox=enemy_x[i]+fireBallJumpInAnimation[off+0];
				}
				else
				{
					ox=enemy_x[i]-fireBallJumpInAnimation[off+0];
				}

				oy=enemy_y[i]+fireBallJumpInAnimation[off+1];

				oam_spr1(ox,oy-2,ENEMY_TILE+0x04|(((frame>>1)&1)<<1)|ENEMY_ATR|(!game_flip?SPR_HFLIP:0),spr);

				enemy_cnt[i]+=2;

				if(enemy_cnt[i]>=sizeof(fireBallJumpInAnimation))
				{
					enemy_type[i]=ENEMY_FIREBALL_1;
					enemy_cnt [i]=3+(rand()&7);
				}
			}
			break;

		case ENEMY_FIREBALL_1_SPAWN:
			{
				ox=enemy_x[i];
				oy=enemy_y[i];

				oam_spr1(ox,oy-2,ENEMY_TILE+0x04|(((frame>>1)&1)<<1)|ENEMY_ATR|SPR_HFLIP,spr);

				++enemy_cnt[i];
				--oy;

				if(enemy_cnt[i]==14)
				{
					enemy_type[i]=ENEMY_FIREBALL_1;
					enemy_cnt [i]=3+(rand()&7);
				}
			}
			break;

		case ENEMY_FIREBALL_1:
		case ENEMY_FIREBALL_2:
			{
				ox=enemy_x[i];
				oy=enemy_y[i];
				dx=enemy_dx[i];

				if(enemy_check_object_jump(ox,oy))
				{
					game_add_score(100);
					particle_add(PART_TYPE_100,ox,oy);

					jump_over=TRUE;
				}

				anim=ENEMY_TILE+0x04|(frame&2)|ENEMY_ATR|(dx<=1?SPR_HFLIP:0);

				if(type==ENEMY_FIREBALL_2)
				{
					if(enemy_spawn[i]<sizeof(fireBallSpawnAnim))
					{
						anim=fireBallSpawnAnim[enemy_spawn[i]>>1];

						++enemy_spawn[i];

						oam_spr1(ox,oy-2,anim,spr);

						break;
					}
					else
					{
						anim+=4;
					}
				}

				oam_spr1(ox,oy-2,anim,spr);

				if(enemy_ladder[i]==DIR_NONE)
				{
					if(frame&1)
					{
						if(dx)
						{
							if(dx==1)
							{
								if(map[NAM_OFF(ox+12,oy+15)]==0xf5) enemy_dx[i]=-1;
							}
							else
							{
								if(map[NAM_OFF(ox+4,oy+15)]==0xf5) enemy_dx[i]=1;
							}

							ox+=dx;

							if(type==ENEMY_FIREBALL_1)
							{
								if(!(TEST_MAP(ox+8,oy+16)&T_SOLID))
								{
									if(TEST_MAP(ox+8,oy+15)&T_SOLID) --oy; else ++oy;
								}
							}
						}

						--enemy_cnt[i];

						if(!enemy_cnt[i])
						{
							enemy_cnt[i]=4+(rand()&15);

							if(!dx||(player_y==oy&&(rand()&255)>32))/*go to the player*/
							{
								if(player_x<ox) enemy_dx[i]=-1; else enemy_dx[i]=1;
							}
							else/*go random direction*/
							{
								enemy_dx[i]=((rand()&31)/12)-1;

								if(!enemy_dx[i]) enemy_cnt[i]=(enemy_cnt[i]&7)+1;
							}
						}
					}
					else
					{
						if((ox&7)==4)
						{
							if(TEST_MAP(ox+8,oy+16)&T_LADDER)
							{
								if(player_y>oy)/*firefoxes are getting smarter on latter loops*/
								{
									val=64+game_loops*16;
									if(val>255) val=255;
								}
								else
								{
									val=64;
								}

								if((rand()&255)<val)
								{
									enemy_ladder[i]=DIR_DOWN;
									break;
								}
							}

							if(TEST_MAP(ox+8,oy+15)&T_LADDER)
							{
								if(player_y<oy)/*firefoxes are getting smarter on latter loops*/
								{
									val=64+game_loops*16;
									if(val>255) val=255;
								}
								else
								{
									val=64;
								}

								if((rand()&255)<val&&oy>40)/*don't take the ladders at top of the screen*/
								{
									enemy_ladder[i]=DIR_UP;
									break;
								}
							}
						}
					}
				}
				else
				{
					if(!(frame&3))
					{
						if(enemy_ladder[i]==DIR_UP)
						{
							--oy;

							if(!(TEST_MAP(ox+8,oy+15)&(T_LADDER|T_LADDER_BROKEN)))
							{
								enemy_ladder[i]=DIR_NONE;
							}
						}
						else
						{
							++oy;

							if(!(TEST_MAP(ox+8,oy+16)&(T_LADDER|T_LADDER_BROKEN)))
							{
								enemy_ladder[i]=DIR_NONE;
							}
						}
					}
				}
			}
			break;

		case ENEMY_BOUNCE:
			{
				ox=(enemy_ix[i]>>BOUNCE_FP);
				oy=(enemy_iy[i]>>BOUNCE_FP);

				oam_spr(enemy_ix[i]>>BOUNCE_FP,oy,ENEMY_TILE+(enemy_land[i]?0x02:0x00)|ENEMY_ATR,spr);

				if(enemy_idy[i]<(3<<BOUNCE_FP))
				{
					if(oy>=enemy_sy[i])
					{
						if((!game_flip&&ox<184)||(game_flip&&ox>256-184-16))
						{
							enemy_idy [i]=-3<<BOUNCE_FP;
							enemy_land[i]=10;
							sfx_play(SFX_CHN+2,SFX_BOUNCE_JUMP,ox);
						}
					}

					if(!game_flip)
					{
						enemy_ix[i]+=bounce_speed[enemy_speed[i]+0];
					}
					else
					{
						enemy_ix[i]-=bounce_speed[enemy_speed[i]+0];
					}

					enemy_idy[i]+=bounce_speed[enemy_speed[i]+1];

					if(enemy_idy[i]>=(3<<BOUNCE_FP)) sfx_play(SFX_CHN+2,SFX_BOUNCE_FALL,ox);
				}

				enemy_iy[i]+=enemy_idy[i];

				if(enemy_land[i]) --enemy_land[i];

				if(enemy_ix[i]<0) type=ENEMY_NONE;//prevent killing with the bounce at the right edge of the screen in the second level

				if(enemy_iy[i]>=(224<<BOUNCE_FP))
				{
					fire=enemy_remove(i,FALSE);
					type=ENEMY_NONE;
				}
			}
			break;

		case ENEMY_CEMENT_PAN:
			{
				dx=enemy_ix[i];//as it can get off the screen
				ox=dx;
				oy=enemy_y [i];

				if(dx>1&&dx<254)
				{
					oam_spr1(ox,oy,PLAYER_TILE+0x48|PLAYER_ATR,spr);
					
					if(enemy_check_object_jump(ox,oy))
					{
						game_add_score(100);
						particle_add(PART_TYPE_100,ox,oy);

						jump_over=TRUE;
					}
				}
				else
				{
					oam_spr(dx,oy,PLAYER_TILE+0x48|PLAYER_ATR,spr);
					type=ENEMY_NONE;//prevent wrapping up the coords for hit box check
				}

				if(frame&1)
				{
					if(oy<160)//middle belt
					{
						if(dx!=120)//moving
						{
							if(!conveyor_dir[1])
							{
								if(dx<120) ++enemy_ix[i]; else --enemy_ix[i];
							}
							else
							{
								if(dx>120) ++enemy_ix[i]; else --enemy_ix[i];
							}
						}
						else//falling
						{
							++oy;

							if(oy>=88+8)//pan falls into the fire
							{
								sfx_play(SFX_CHN+3,SFX_BURN,ox);
								particle_add(PART_TYPE_SMOKE_UP,120,oy+4);
								fire=enemy_remove(i,FALSE);
								type=ENEMY_NONE;
								break;
							}
						}
					}
					else//bottom belt
					{
						if(conveyor_dir[2]) ++enemy_ix[i]; else --enemy_ix[i];
					}

					if(dx<-16||dx>256)//pan gets off the screen
					{
						fire=enemy_remove(i,FALSE);
						type=ENEMY_NONE;
					}
				}
			}
			break;
		}

		//check interaction between an enemy and player and hammer

		if(type)
		{
			if(game_frame_cnt&1)//alternate checks between frames
			{
				if(player_y+12>oy+4)
				if(player_y+4 <oy+12)
				if(player_x+12>ox+4)
				if(player_x+4 <ox+12)
				{
					clear=LEVEL_LOSE;
				}
			}
			else
			{
				if(hammer)//check hammer collision
				{
					hx=player_x+hammerOffsets[hammer_off+0]+3;
					hy=player_y+hammerOffsets[hammer_off+1]+3;

					if(oy+10>hy)
					if(oy+6 <hy+10)
					if(ox+10>hx)
					if(ox+6 <hx+10)
					{
						splat_x=ox;
						splat_y=oy;
						splat_cnt=0;

						sfx_play(SFX_CHN,SFX_DESTROY,ox);

						switch(type)
						{
						case ENEMY_FIREBALL_1_JUMP_IN:
						case ENEMY_FIREBALL_1_SPAWN:
						case ENEMY_FIREBALL_1:
						case ENEMY_FIREBALL_2:
							score=500;
							particle=PART_TYPE_500;
							break;

						default://barrels, cement pans
							score=300;
							particle=PART_TYPE_300;
						}

						game_add_score(score);
						particle_add(particle,ox,oy);

						fire=enemy_remove(i,TRUE);

						break;//prevent destroying more than one object at once
					}
				}
			}

			enemy_x[i]=ox;
			enemy_y[i]=oy;
		}

		spr+=4;
		++frame;//to distribute time-based events between objects
	}

	//automatically add a fireball when a wild barrel hits the burning barrel

	if(fire)
	{
		if(!game_level)
		{
			barrel_show_fire(TRUE);
			barrel_fire=TRUE;

			if(game_fireballs<game_fireballs_max)
			{
				++game_fireballs;

				enemy_add(ENEMY_FIREBALL_1_JUMP_IN,barrel_fire_x,barrel_fire_y+8,0);
				sfx_play(SFX_CHN+2,SFX_FIRE_SPAWN,barrel_fire_x+8);
			}
		}
	}

	if(jump_over)
	{
		sfx_play(SFX_CHN+3,SFX_JUMP_OVER,player_x);

		game_object_jump=8;//prevent getting few bonuses from the same object
	}

	switch(barrels_jumped)
	{
	case 0:
		break;

	case 1:
		game_add_score(100);
		particle_add(PART_TYPE_100,player_x,player_y);
		break;

	case 2:
		game_add_score(300);
		particle_add(PART_TYPE_300,player_x,player_y);
		break;

	case 2:
		game_add_score(500);
		particle_add(PART_TYPE_500,player_x,player_y);
		break;

	default://4 or more
		game_add_score(800);
		particle_add(PART_TYPE_800,player_x,player_y);
	}

	return clear;
}
