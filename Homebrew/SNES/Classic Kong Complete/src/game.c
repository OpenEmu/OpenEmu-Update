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

//#define SOUND_DISABLE	//sound loading is rather slow, it could be disabled to make tests faster

const char versionStr[]="V2.01";

#include "sneslib.h"

#define FP	4
#define POS(x,y) (((y)<<5)+(x))

#include "data.h"

static unsigned int global_stereo;
static unsigned int global_volume;

static unsigned int game_frame_cnt;
static unsigned int game_bg_anim;

static unsigned char game_level;
static unsigned char game_lives;
static unsigned char game_rivets;
static unsigned long game_score;
static unsigned long game_best_score;
static unsigned char game_loops;
static unsigned int  game_bonus;
static unsigned char game_score_change;
static unsigned char game_bonus_change;
static unsigned char game_bonus_cnt;
static unsigned char game_level_difficulty;
static unsigned int  game_level_difficulty_count;
static unsigned char game_object_jump;
static unsigned char game_bounce_delay;
static unsigned char game_bounce_speed;
static unsigned char game_fireballs;
static unsigned char game_fireballs_max;
static unsigned char game_test_mode;
static unsigned char game_hard_mode;
static unsigned char game_update_palette;
static unsigned char game_flip;
static unsigned char game_lives_update;
static unsigned char game_belts_update;
static unsigned char game_rivets_update;

static unsigned char barrel_fire;
static unsigned char barrel_fire_x;
static unsigned char barrel_fire_y;
static unsigned int  barrel_fire_off;

static unsigned char conveyor_dir[3];
static unsigned char conveyor_cnt[3];
static unsigned char conveyor_items[3];
static unsigned int  conveyor_cnt_middle;

static unsigned int nametable1[32*32];
static unsigned int nametable2[32*32];
static unsigned int nametable3[32*32];//offset data

static unsigned char map[32*32];
static unsigned char walkmap[32*224];

static unsigned int back_buffer[24576/2];
static unsigned int back_graphics[384*8];

static unsigned int snes_palette_to[256];

#define LEVEL_CLEAR			1
#define LEVEL_LOSE			2
#define LEVEL_LOSE_WINCH	3
#define LEVEL_LOSE_TIME_OUT	4

#define T_FLOOR			1
#define T_LADDER		2
#define T_LADDER_BROKEN 4
#define T_RIVET			8
#define T_ELEVATOR		16

#define T_LDRTOP		(T_LADDER|T_FLOOR)
#define T_SOLID			(T_FLOOR|T_RIVET|T_ELEVATOR)


const unsigned char tileAttribute[128][8]={
{ 0,0,0,0,0,0,0,0 },//empty
{ T_FLOOR,0,0,0,0,0,0,0 },//other kind of floor
{ T_RIVET,0,0,0,0,0,0,0 },//tile rivet
{ T_LDRTOP,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ T_FLOOR,0,0,0,0,0,0,0 },//floor
{ T_FLOOR,0,0,0,0,0,0,0 },//floor
{ T_FLOOR,0      ,0      ,0      ,0      ,0      ,0      ,0       },
{ 0      ,T_FLOOR,0      ,0      ,0      ,0      ,0      ,0       },
{ 0      ,0      ,T_FLOOR,0      ,0      ,0      ,0      ,0       },
{ 0      ,0      ,0      ,T_FLOOR,0      ,0      ,0      ,0       },
{ 0      ,0      ,0      ,0      ,T_FLOOR,0      ,0      ,0       },
{ 0      ,0      ,0      ,0      ,0      ,T_FLOOR,0      ,0       },
{ 0      ,0      ,0      ,0      ,0      ,0      ,T_FLOOR,0       },
{ 0      ,0      ,0      ,0      ,0      ,0      ,0      ,T_FLOOR },

{ T_LADDER_BROKEN,T_LADDER_BROKEN,T_LADDER_BROKEN,T_LADDER_BROKEN,
  T_LADDER_BROKEN,T_LADDER_BROKEN,T_LADDER_BROKEN,T_LADDER_BROKEN },
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//floor bottom
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },

{ T_LDRTOP,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0       ,T_LDRTOP,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0       ,0       ,T_LDRTOP,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0       ,0       ,0       ,T_LDRTOP,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0       ,0       ,0       ,0       ,T_LDRTOP,T_LADDER,T_LADDER,T_LADDER },
{ 0       ,0       ,0       ,0       ,0       ,T_LDRTOP,T_LADDER,T_LADDER },
{ 0       ,0       ,0       ,0       ,0       ,0       ,T_LDRTOP,T_LADDER },
{ 0       ,0       ,0       ,0       ,0       ,0       ,0       ,T_LDRTOP },
{ T_FLOOR ,0       ,0       ,0       ,0       ,0       ,0       ,0       },
{ T_LADDER,T_FLOOR ,0       ,0       ,0       ,0       ,0       ,0       },
{ T_LADDER,T_LADDER,T_FLOOR ,0       ,0       ,0       ,0       ,0       },
{ T_LADDER,T_LADDER,T_LADDER,T_FLOOR ,0       ,0       ,0       ,0       },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_FLOOR ,0       ,0       ,0       },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_FLOOR ,0       ,0       },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_FLOOR ,0       },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_FLOOR },

{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER,T_LADDER },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,0,0,0,0,0 },

{ 0,0,0,0,0,0,0,0 },//barrel
{ 0,0,0,0,0,0,0,0 },//barrel
{ 0,0,0,0,0,0,0,0 },//barrel
{ 0,0,0,0,0,0,0,0 },//barrel
{ T_FLOOR,0,0,0,0,0,0,0 },//elevator thing
{ T_FLOOR,0,0,0,0,0,0,0 },//elevator thing
{ T_FLOOR,0,0,0,0,0,0,0 },//elevator thing
{ T_FLOOR,0,0,0,0,0,0,0 },//elevator thing
{ 0,0,0,0,0,0,0,0 },//dangerous elevator thing
{ 0,0,0,0,0,0,0,0 },//dangerous elevator thing
{ 0,0,0,0,0,0,0,0 },//dangerous elevator thing
{ 0,0,0,0,0,0,0,0 },//dangerous elevator thing
{ 0,0,0,0,0,0,0,0 },//fire
{ 0,0,0,0,0,0,0,0 },//fire
{ 0,0,0,0,0,0,0,0 },//elevator rope
{ 0,0,0,0,0,0,0,0 },//elevator rope
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty
{ 0,0,0,0,0,0,0,0 },//empty

};

//palette and prioirty for sprites

#define PLAYER_ATR		(SPR_PAL(0)|SPR_PRI(2))
#define ITEM_ATR		(SPR_PAL(1)|SPR_PRI(2))
#define KONG_ATR		(SPR_PAL(2)|SPR_PRI(2))
#define PRINCESS_ATR	(SPR_PAL(5)|SPR_PRI(2))
#define BARREL_ATR		(SPR_PAL(3)|SPR_PRI(2))
#define ENEMY_ATR		(SPR_PAL(4)|SPR_PRI(2))
#define GAMEOVER_ATR	(SPR_PAL(7)|SPR_PRI(3))

#define TEXT_ATR		(0x0100|BG_PAL(0)|BG_PRI)

//OAM offsets for objects

#define OAM_GAMEOVER	(0<<2)						//8 sprites
#define OAM_SPLAT		(8<<2)						//1 sprite
#define OAM_HAMMER		(9<<2)						//2 sprites
#define OAM_PLAYER		(11<<2)						//1 sprite
#define OAM_ENEMY		(12<<2)						//ENEMY_MAX sprites
#define OAM_PARTICLES	(OAM_ENEMY+(ENEMY_MAX<<2))	//PARTICLES_MAX sprites
#define OAM_ITEMS		(OAM_PARTICLES+(PARTICLES_MAX<<2))		//ITEMS_MAX sprites
#define OAM_ELEVATORS 	(OAM_ITEMS+(ITEMS_MAX<<2))	//ELEVATORS_MAX sprites
#define OAM_BARRELS		(OAM_ELEVATORS+(ELEVATORS_MAX<<2))	//5 sprites
#define OAM_KONG		(OAM_BARRELS+(5<<2))		//5 sprites
#define OAM_PRINCESS	(OAM_KONG+(5<<2)) 			//3 sprites
#define OAM_LADDERS		(OAM_PRINCESS+(3<<2))		//2 sprites

#define NAM_OFF(x,y)	((((y)>>3)<<5)+((x)>>3))
#define WMAP_OFF(x,y)	(((y)<<5)+((x)>>3))
#define TEST_MAP(x,y)	(walkmap[WMAP_OFF(x,y)])

//VRAM offsets for sprite graphics

#define PLAYER_TILE		0
#define ITEMS_TILE		(PLAYER_TILE+(3072>>5))
#define KONG_TILE		(ITEMS_TILE +(2048>>5))
#define BARREL_TILE		(KONG_TILE  +(5120>>5))
#define ENEMY_TILE		(BARREL_TILE+(1024>>5))
#define PRINCESS_TILE	(ENEMY_TILE +(4096>>5))

//player variables

#define MAX_FALL_HEIGHT		15	//in pixels from initial height
#define PLR_BBOX_HWDT		(4/2)

static int  		 player_x;
static int  		 player_y;
static unsigned char player_step;
static unsigned char player_ladder;
static unsigned char player_jump;
static unsigned char player_jump_cnt;
static int			 player_jump_y;
static unsigned int  player_anim;
static unsigned char player_dir;
static unsigned char player_dir_prev;
static unsigned char player_fall;
static unsigned char player_speed_div;
static unsigned char player_rivet_delay;
static unsigned int	 player_hammer_time;
static unsigned char player_hammer_phase;
static unsigned char player_hammer_cnt;

//items variables

#define ITEM_NONE		0
#define ITEM_HAMMER		1
#define ITEM_UMBRELLA	2
#define ITEM_BAG		3
#define ITEM_HEART		4
#define ITEM_ELEVATOR	5

#define ITEMS_MAX		6

static unsigned char items_all;

static unsigned char item_type[ITEMS_MAX];
static unsigned char item_x   [ITEMS_MAX];
static unsigned char item_y   [ITEMS_MAX];

const unsigned int itemSpriteTable[5]={
0,
ITEMS_TILE+0x00|ITEM_ATR,
ITEMS_TILE+0x02|ITEM_ATR,
ITEMS_TILE+0x04|ITEM_ATR,
ITEMS_TILE+0x06|ITEM_ATR
};

//elevator variables

#define ELEVATORS_MAX	6

static unsigned char elevators_all;

static int elevator_x [ELEVATORS_MAX];
static int elevator_y [ELEVATORS_MAX];
static int elevator_dy[ELEVATORS_MAX];

static unsigned char elevator_top;
static unsigned char elevator_bottom;

//enemy variables

#define ENEMY_MAX					16

#define ENEMY_NONE					0
#define ENEMY_ROLLING_BARREL		1
#define ENEMY_LADDER_BARREL			2
#define ENEMY_WILD_BARREL			3	//to refer to all three kinds
#define ENEMY_WILD_BARREL_DOWN		3
#define ENEMY_WILD_BARREL_CHANGE	4
#define ENEMY_WILD_BARREL_SIDE		5
#define ENEMY_FIREBALL_1_JUMP_IN	6
#define ENEMY_FIREBALL_1_SPAWN		7
#define ENEMY_FIREBALL_1			8
#define ENEMY_FIREBALL_2			9
#define ENEMY_BOUNCE				10
#define ENEMY_CEMENT_PAN			11

#define BOUNCE_FP 7

static unsigned char enemy_free;
static unsigned char enemy_all;

static unsigned char enemy_type [ENEMY_MAX];
static unsigned char enemy_x    [ENEMY_MAX];
static unsigned char enemy_y    [ENEMY_MAX];
static unsigned char enemy_sy   [ENEMY_MAX];
static unsigned char enemy_dx   [ENEMY_MAX];
static unsigned char enemy_fall [ENEMY_MAX];
static unsigned char enemy_anim [ENEMY_MAX];
static unsigned char enemy_land [ENEMY_MAX];
static int           enemy_ix   [ENEMY_MAX];
static int           enemy_iy   [ENEMY_MAX];
static int           enemy_idy  [ENEMY_MAX];
static unsigned char enemy_cnt  [ENEMY_MAX];
static unsigned char enemy_ladder[ENEMY_MAX];
static unsigned char enemy_spawn[ENEMY_MAX];
static unsigned char enemy_speed[ENEMY_MAX];

const char fireBallJumpInAnimation[]={
0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,
1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,
1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1
};

const unsigned int fireBallSpawnAnim[]={
ENEMY_TILE+0x20|ENEMY_ATR,
ENEMY_TILE+0x22|ENEMY_ATR,
ENEMY_TILE+0x24|ENEMY_ATR,
ENEMY_TILE+0x26|ENEMY_ATR,
ENEMY_TILE+0x24|ENEMY_ATR,
ENEMY_TILE+0x22|ENEMY_ATR,
ENEMY_TILE+0x20|ENEMY_ATR,
ENEMY_TILE+0x22|ENEMY_ATR,
ENEMY_TILE+0x24|ENEMY_ATR,
ENEMY_TILE+0x26|ENEMY_ATR,
ENEMY_TILE+0x28|ENEMY_ATR,
ENEMY_TILE+0x26|ENEMY_ATR,
ENEMY_TILE+0x24|ENEMY_ATR,
ENEMY_TILE+0x22|ENEMY_ATR,
ENEMY_TILE+0x20|ENEMY_ATR,
ENEMY_TILE+0x22|ENEMY_ATR,
ENEMY_TILE+0x24|ENEMY_ATR,
ENEMY_TILE+0x26|ENEMY_ATR,
ENEMY_TILE+0x28|ENEMY_ATR,
ENEMY_TILE+0x2a|ENEMY_ATR,
ENEMY_TILE+0x2c|ENEMY_ATR,
ENEMY_TILE+0x2e|ENEMY_ATR
};

#define FIREBALL_SPAWN_MAX	8

static unsigned char fireball_spawn_all;

static unsigned char fireball_spawn_x[FIREBALL_SPAWN_MAX];
static unsigned char fireball_spawn_y[FIREBALL_SPAWN_MAX];

const int bounce_speed[5*2]={
(128+64)*100/100,16*100/100,//1.5 pixels
(128+64)*125/100,16*125/100,
(128+64)*150/100,16*150/100,
(128+64)*175/100,16*175/100,
(128+64)*200/100,16*200/100,
};

//particles

#define PARTICLES_MAX		4

#define PART_TYPE_NONE		0
#define PART_TYPE_100		1
#define PART_TYPE_300		2
#define PART_TYPE_500		3
#define PART_TYPE_800		4
#define PART_TYPE_HELP		5
#define PART_TYPE_SMOKE		6
#define PART_TYPE_SMOKE_UP	7
#define PART_TYPE_HEART		8

static unsigned char particle_free;

static unsigned char particle_type[PARTICLES_MAX];
static unsigned char particle_x   [PARTICLES_MAX];
static unsigned char particle_y   [PARTICLES_MAX];
static unsigned char particle_cnt1[PARTICLES_MAX];
static unsigned char particle_cnt2[PARTICLES_MAX];
static unsigned int  particle_spr [PARTICLES_MAX];

//jump states

#define JUMP_NONE	0
#define JUMP_AIR	1
#define JUMP_LAND	2
#define JUMP_DUMMY	3

//movement directions

#define DIR_NONE	0
#define DIR_LEFT	1
#define DIR_RIGHT	2
#define DIR_UP		3
#define DIR_DOWN	4

//playfield horizontal boundaries

#define CLIP_LEFT	2
#define CLIP_RIGHT	238

//player animation

const unsigned int playerWalkAnimLeft[6]={
PLAYER_TILE+0x00|PLAYER_ATR,
PLAYER_TILE+0x02|PLAYER_ATR,
PLAYER_TILE+0x00|PLAYER_ATR,
PLAYER_TILE+0x04|PLAYER_ATR,
PLAYER_TILE+0x06|PLAYER_ATR,
PLAYER_TILE+0x04|PLAYER_ATR
};

const unsigned int playerWalkAnimRight[6]={
PLAYER_TILE+0x00|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x02|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x00|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x04|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x06|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x04|PLAYER_ATR|SPR_HFLIP
};

const unsigned int playerClimbAnim[2*4]={
PLAYER_TILE+0x20|PLAYER_ATR,
PLAYER_TILE+0x20|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x22|PLAYER_ATR,
PLAYER_TILE+0x22|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x24|PLAYER_ATR,
PLAYER_TILE+0x24|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x26|PLAYER_ATR,
PLAYER_TILE+0x26|PLAYER_ATR|SPR_HFLIP
};

const unsigned int playerLoseAnim[4]={
PLAYER_TILE+0x2a|PLAYER_ATR,
PLAYER_TILE+0x2c|PLAYER_ATR,
PLAYER_TILE+0x2a|PLAYER_ATR|SPR_VFLIP,
PLAYER_TILE+0x2c|PLAYER_ATR|SPR_HFLIP
};


const int playerJumpTable[]={
-1,-1,-1,-1,-1,
-1,-1,-1,-1,-1,
0,-1,0,-1,0,-1,0,-1,
0,0,0,0,0,0,0,0,
1,0,1,0,1,0,1,0,
1,1,1,1,1,
1,1,1,1,1,
1,1,1,1,1,1,1,1//extra
};


const char hammerOffsets[8]={//x and y offsets for moving part of the hammer
-16,  0-1,//hammer at the left
  0,-16-1,//hammer at the top
 16,  0-1,//hammer at the right
  0,-16-1 //hammer at the top
};

const unsigned int hammerSprites[8]={//pair of tile numbers per phase
PLAYER_TILE+0x40|PLAYER_ATR,			//hammer at the left
PLAYER_TILE+0x42|PLAYER_ATR,
PLAYER_TILE+0x44|PLAYER_ATR,			//hammer at the top
PLAYER_TILE+0x46|PLAYER_ATR,
PLAYER_TILE+0x40|PLAYER_ATR|SPR_HFLIP,	//hammer at the right
PLAYER_TILE+0x42|PLAYER_ATR|SPR_HFLIP,
PLAYER_TILE+0x44|PLAYER_ATR|SPR_HFLIP,	//hammer at the top
PLAYER_TILE+0x46|PLAYER_ATR|SPR_HFLIP
};


//kong variables

#define KONG_STATE_STAND	0
#define KONG_STATE_TAKE		1
#define KONG_STATE_MIDDLE	2
#define KONG_STATE_DROP		3
#define KONG_STATE_WAIT		4

static unsigned char kong_x;
static int           kong_y;
static unsigned char kong_frame_cnt;
static unsigned char kong_state;
static unsigned char kong_delay;
static const unsigned int* kong_frame;
static unsigned char kong_throw_wild_barrel;
static unsigned char kong_wild_barrel_type;
static unsigned char kong_start;


//kong animation

const unsigned int kongLargeSpriteFace1[]={
 0, 0,KONG_TILE+0x00|KONG_ATR,
 0,16,KONG_TILE+0x20|KONG_ATR,
16, 0,KONG_TILE+0x00|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x20|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace2Both[]={
0 ,0 ,KONG_TILE+0x02|KONG_ATR,
0 ,16,KONG_TILE+0x22|KONG_ATR,
16,0 ,KONG_TILE+0x02|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x22|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace3Both[]={
 0, 0,KONG_TILE+0x04|KONG_ATR,
 0,16,KONG_TILE+0x24|KONG_ATR,
16, 0,KONG_TILE+0x04|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x24|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace4Both[]={
 0, 0,KONG_TILE+0x06|KONG_ATR,
 0,16,KONG_TILE+0x26|KONG_ATR,
16, 0,KONG_TILE+0x06|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x26|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace2Left[]={
 0, 0,KONG_TILE+0x02|KONG_ATR,
 0,16,KONG_TILE+0x22|KONG_ATR,
16, 0,KONG_TILE+0x42|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x62|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace3Left[]={
 0, 0,KONG_TILE+0x04|KONG_ATR,
 0,16,KONG_TILE+0x24|KONG_ATR,
16, 0,KONG_TILE+0x44|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x64|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace4Left[]={
 0, 0,KONG_TILE+0x06|KONG_ATR,
 0,16,KONG_TILE+0x26|KONG_ATR,
16, 0,KONG_TILE+0x46|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x66|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace2Right[]={
 0, 0,KONG_TILE+0x42|KONG_ATR,
 0,16,KONG_TILE+0x62|KONG_ATR,
16, 0,KONG_TILE+0x02|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x22|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace3Right[]={
 0, 0,KONG_TILE+0x44|KONG_ATR,
 0,16,KONG_TILE+0x64|KONG_ATR,
16, 0,KONG_TILE+0x04|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x24|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFace4Right[]={
 0, 0,KONG_TILE+0x46|KONG_ATR,
 0,16,KONG_TILE+0x66|KONG_ATR,
16, 0,KONG_TILE+0x06|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x26|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteSideL[]={
 0, 0,KONG_TILE+0x08|KONG_ATR,
 0,16,KONG_TILE+0x28|KONG_ATR,
16, 0,KONG_TILE+0x0a|KONG_ATR,
16,16,KONG_TILE+0x2a|KONG_ATR,
128
};

const unsigned int kongLargeSpriteSideR[]={
 0, 0,KONG_TILE+0x0a|KONG_ATR|SPR_HFLIP,
 0,16,KONG_TILE+0x2a|KONG_ATR|SPR_HFLIP,
16, 0,KONG_TILE+0x08|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x28|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteThrow[]={
 0, 0,KONG_TILE+0x0c|KONG_ATR,
 0,16,KONG_TILE+0x2c|KONG_ATR,
16, 0,KONG_TILE+0x0c|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x2c|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteLaugh[]={
 0, 0,KONG_TILE+0x0e|KONG_ATR,
 0,16,KONG_TILE+0x2e|KONG_ATR,
16, 0,KONG_TILE+0x0e|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x2e|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteFalling1[]={
-8, 8,KONG_TILE+0x80|KONG_ATR,
 8, 8,KONG_TILE+0x82|KONG_ATR,
24, 8,KONG_TILE+0x84|KONG_ATR,
 8,24,KONG_TILE+0x8a|KONG_ATR,
128
};

const unsigned int kongLargeSpriteFalling2[]={
-8, 8,KONG_TILE+0x84|KONG_ATR|SPR_HFLIP,
 8, 8,KONG_TILE+0x86|KONG_ATR,
24, 8,KONG_TILE+0x80|KONG_ATR|SPR_HFLIP,
 8,24,KONG_TILE+0x8e|KONG_ATR,
128
};

const unsigned int kongLargeSpriteFell[]={
-8, 8,KONG_TILE+0x88|KONG_ATR,
 8, 8,KONG_TILE+0x8c|KONG_ATR,
24, 8,KONG_TILE+0x88|KONG_ATR|SPR_HFLIP,
128,
128
};

const unsigned int kongLargeSpriteClimb1L[]={
 0, 0,KONG_TILE+0x4a|KONG_ATR|SPR_HFLIP,
16, 0,KONG_TILE+0x48|KONG_ATR|SPR_HFLIP,
 0,16,KONG_TILE+0x6a|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x68|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteClimb2L[]={
 0, 0,KONG_TILE+0x4e|KONG_ATR|SPR_HFLIP,
16, 0,KONG_TILE+0x4c|KONG_ATR|SPR_HFLIP,
 0,16,KONG_TILE+0x6e|KONG_ATR|SPR_HFLIP,
16,16,KONG_TILE+0x6c|KONG_ATR|SPR_HFLIP,
128
};

const unsigned int kongLargeSpriteClimb1R[]={
 0, 0,KONG_TILE+0x48|KONG_ATR,
16, 0,KONG_TILE+0x4a|KONG_ATR,
 0,16,KONG_TILE+0x68|KONG_ATR,
16,16,KONG_TILE+0x6a|KONG_ATR,
128
};

const unsigned int kongLargeSpriteClimb2R[]={
 0, 0,KONG_TILE+0x4c|KONG_ATR,
16, 0,KONG_TILE+0x4e|KONG_ATR,
 0,16,KONG_TILE+0x6c|KONG_ATR,
16,16,KONG_TILE+0x6e|KONG_ATR,
128
};

const unsigned int* const kongAnimationLeftRight[]={
kongLargeSpriteFace1,
kongLargeSpriteFace2Left,
kongLargeSpriteFace3Left,
kongLargeSpriteFace4Left,
kongLargeSpriteFace3Left,
kongLargeSpriteFace2Left,
kongLargeSpriteFace1,
kongLargeSpriteFace2Right,
kongLargeSpriteFace3Right,
kongLargeSpriteFace4Right,
kongLargeSpriteFace3Right,
kongLargeSpriteFace2Right,
kongLargeSpriteFace1,
kongLargeSpriteFace1
};

const unsigned int* const kongAnimationBoth[]={
kongLargeSpriteFace1,
kongLargeSpriteFace2Both,
kongLargeSpriteFace3Both,
kongLargeSpriteFace4Both,
kongLargeSpriteFace3Both,
kongLargeSpriteFace1
};

const unsigned int* const kongAnimationStartCutscene[]={
kongLargeSpriteFace4Both,
kongLargeSpriteFace3Both,
kongLargeSpriteFace2Both,
kongLargeSpriteFace1
};


const unsigned int princessAnimation[]={
PRINCESS_TILE+0x00|PRINCESS_ATR,
PRINCESS_TILE+0x02|PRINCESS_ATR,
PRINCESS_TILE+0x00|PRINCESS_ATR,
PRINCESS_TILE+0x0a|PRINCESS_ATR,
PRINCESS_TILE+0x04|PRINCESS_ATR,
PRINCESS_TILE+0x06|PRINCESS_ATR
};

//this animation is used for a barrel that is just landed
//it subtracted from the screen y coordinate to make it appear like jumping

const unsigned char barrelLandingAnimation[]={
1,2,2,3,3,3,3,2,2,1,0,0,0,0,1,2,2,1,0
};

//splat variables

static unsigned char splat_x;
static unsigned char splat_y;
static unsigned char splat_cnt;

const unsigned int splatAnimation[]={
ENEMY_TILE+0x60|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x66|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x60|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x66|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x60|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x66|ENEMY_ATR,
ENEMY_TILE+0x64|ENEMY_ATR,
ENEMY_TILE+0x62|ENEMY_ATR,
ENEMY_TILE+0x68|ENEMY_ATR,
ENEMY_TILE+0x68|ENEMY_ATR,
ENEMY_TILE+0x6a|ENEMY_ATR,
ENEMY_TILE+0x6a|ENEMY_ATR,
ENEMY_TILE+0x6c|ENEMY_ATR,
ENEMY_TILE+0x6c|ENEMY_ATR,
ENEMY_TILE+0x6e|ENEMY_ATR,
ENEMY_TILE+0x6e|ENEMY_ATR
};

//princess variables

static unsigned char princess_x;
static int           princess_y;

//intro cutscene animation and variables

const unsigned int platformAnim[2*8]={
0x0149|BG_PAL(1),0x0159|BG_PAL(1),
0x014a|BG_PAL(1),0x015a|BG_PAL(1),
0x014b|BG_PAL(1),0x015b|BG_PAL(1),
0x014c|BG_PAL(1),0x015c|BG_PAL(1),
0x014d|BG_PAL(1),0x015d|BG_PAL(1),
0x014e|BG_PAL(1),0x015e|BG_PAL(1),
0x014f|BG_PAL(1),0x015f|BG_PAL(1),
0x0148|BG_PAL(1),0x0158|BG_PAL(1)
};

static unsigned char platformAnimCnt[6*32];

//ladders variables

#define LADDERS_MAX	22

static unsigned char ladders_x    [LADDERS_MAX];
static unsigned char ladders_y    [LADDERS_MAX];
static unsigned char ladders_dir  [LADDERS_MAX];
static unsigned char ladders_cnt  [LADDERS_MAX];
static unsigned char ladders_delay[LADDERS_MAX];


//sound variables

#define SFX_CHN			4

#define SFX_BARREL1		0
#define SFX_BARREL2		1
#define SFX_BARREL3		2
#define SFX_BARREL4		3
#define SFX_HERO_JUMP	4
#define SFX_ITEM		5
#define SFX_PAUSE		6
#define SFX_JUMP_OVER	7
#define SFX_FIRE_SPAWN	8
#define SFX_RAFT_FALL	9
#define SFX_KONG_LEFT	10
#define SFX_KONG_RIGHT	11
#define SFX_RIVET		12
#define SFX_BOUNCE_FALL	13
#define SFX_BOUNCE_JUMP	14
#define SFX_KONG_FALLS	15
#define SFX_KONG_LANDS	16
#define SFX_LOVE		17
#define SFX_BRIDGE		18
#define SFX_DESTROY		19
#define SFX_START		20
#define SFX_LADDER1		21
#define SFX_LADDER2		22
#define SFX_BARREL_ROLL	23
#define SFX_HERO_FALL	24
#define SFX_HERO_LANDS	25
#define SFX_HERO_HIT	26
#define SFX_KONG_LAUGH	27
#define SFX_CRACK		28
#define SFX_SWITCH		29
#define SFX_BURN		30
#define SFX_EXTRA_LIFE	31
#define SFX_HEART		32

#define SOUNDS_ALL		33

#define MUS_TITLE		0
#define MUS_GAME_START	1
#define MUS_STAGE_START	2
#define MUS_LOSE		3
#define MUS_STAGE_CLEAR	4
#define MUS_HAMMER		5
#define MUS_LEVEL1		6
#define MUS_TIME_OUT	7
#define MUS_VICTORY		8

#define MUSIC_ALL		9



const unsigned char* const musicListPtr[MUSIC_ALL]={
	music_title_data,
	music_game_start_data,
	music_stage_start_data,
	music_lose_data,
	music_stage_clear_data,
	music_hammer_data,
	music_level1_data,
	music_time_out_data,
	music_victory_data
};

const unsigned int* const musicListSize[MUSIC_ALL]={
	music_title_size,
	music_game_start_size,
	music_stage_start_size,
	music_lose_size,
	music_stage_clear_size,
	music_hammer_size,
	music_level1_size,
	music_time_out_size,
	music_victory_size
};



//empty hdma list, used when the background gradient is disabled

const unsigned char hdmaTableNull[]={ 0 };

//pointers to the hdma lists

const unsigned char* const hdmaTables[8][3]={
{ hdmaTableNull,hdmaTableNull,hdmaTableNull },//no gradient
{ hdmaGradient0List0,hdmaGradient0List1,hdmaGradient0List2 },//level 1
{ hdmaGradient5List0,hdmaGradient5List1,hdmaGradient5List2 },//level 2
{ hdmaGradient2List0,hdmaGradient2List1,hdmaGradient2List2 },//level 3
{ hdmaGradient1List0,hdmaGradient1List1,hdmaGradient1List2 },//level 4
{ hdmaGradient3List0,hdmaGradient3List1,hdmaGradient3List2 },//title
{ hdmaGradient4List0,hdmaGradient4List1,hdmaGradient4List2 },//sound test, levels clear
{ hdmaGradient6List0,hdmaGradient6List1,hdmaGradient6List2 },//how high can you get
};

const unsigned char flipTable[256]={
0x00,0x80,0x40,0xc0,0x20,0xa0,0x60,0xe0,0x10,0x90,0x50,0xd0,0x30,0xb0,0x70,0xf0,
0x08,0x88,0x48,0xc8,0x28,0xa8,0x68,0xe8,0x18,0x98,0x58,0xd8,0x38,0xb8,0x78,0xf8,
0x04,0x84,0x44,0xc4,0x24,0xa4,0x64,0xe4,0x14,0x94,0x54,0xd4,0x34,0xb4,0x74,0xf4,
0x0c,0x8c,0x4c,0xcc,0x2c,0xac,0x6c,0xec,0x1c,0x9c,0x5c,0xdc,0x3c,0xbc,0x7c,0xfc,
0x02,0x82,0x42,0xc2,0x22,0xa2,0x62,0xe2,0x12,0x92,0x52,0xd2,0x32,0xb2,0x72,0xf2,
0x0a,0x8a,0x4a,0xca,0x2a,0xaa,0x6a,0xea,0x1a,0x9a,0x5a,0xda,0x3a,0xba,0x7a,0xfa,
0x06,0x86,0x46,0xc6,0x26,0xa6,0x66,0xe6,0x16,0x96,0x56,0xd6,0x36,0xb6,0x76,0xf6,
0x0e,0x8e,0x4e,0xce,0x2e,0xae,0x6e,0xee,0x1e,0x9e,0x5e,0xde,0x3e,0xbe,0x7e,0xfe,
0x01,0x81,0x41,0xc1,0x21,0xa1,0x61,0xe1,0x11,0x91,0x51,0xd1,0x31,0xb1,0x71,0xf1,
0x09,0x89,0x49,0xc9,0x29,0xa9,0x69,0xe9,0x19,0x99,0x59,0xd9,0x39,0xb9,0x79,0xf9,
0x05,0x85,0x45,0xc5,0x25,0xa5,0x65,0xe5,0x15,0x95,0x55,0xd5,0x35,0xb5,0x75,0xf5,
0x0d,0x8d,0x4d,0xcd,0x2d,0xad,0x6d,0xed,0x1d,0x9d,0x5d,0xdd,0x3d,0xbd,0x7d,0xfd,
0x03,0x83,0x43,0xc3,0x23,0xa3,0x63,0xe3,0x13,0x93,0x53,0xd3,0x33,0xb3,0x73,0xf3,
0x0b,0x8b,0x4b,0xcb,0x2b,0xab,0x6b,0xeb,0x1b,0x9b,0x5b,0xdb,0x3b,0xbb,0x7b,0xfb,
0x07,0x87,0x47,0xc7,0x27,0xa7,0x67,0xe7,0x17,0x97,0x57,0xd7,0x37,0xb7,0x77,0xf7,
0x0f,0x8f,0x4f,0xcf,0x2f,0xaf,0x6f,0xef,0x1f,0x9f,0x5f,0xdf,0x3f,0xbf,0x7f,0xff
};



#include "spccmd.h"



void sfx_play(unsigned int chn,unsigned int sfx,int pan)
{
	if(pan<0)   pan=0;
	if(pan>255) pan=255;

	spc_sfx_play(chn,sfx,pan);
}



void music_play(unsigned int mus)
{
	spc_music_stop();
	spc_reload();
	spc_load_music(musicListPtr[mus],*musicListSize[mus]);
	spc_volume(global_volume);
	spc_music_play();
}



void music_stop(void)
{
	spc_music_stop();
}



void unrle(unsigned char *dst,const unsigned char *src)
{
	static unsigned char i,tag,byte;

	tag=*src++;
	byte=0;

	while(1)
	{
		i=*src++;

		if(i==tag)
		{
			i=*src++;

			if(!i) break;

			while(i)
			{
				*dst++=byte;
				--i;
			}
		}
		else
		{
			byte=i;;
			*dst++=byte;
		}
	}
}



//fade the screen brightness in or out, together with global sound volume if needed

void fade_screen(unsigned char in,unsigned char sound)
{
	static unsigned char i;
	static char volume;

	volume=127;

	for(i=1;i<16;++i)
	{
		nmi_wait();

		if(in)
		{
			set_bright(i);
		}
		else
		{
			set_bright(15-i);

			if(sound)
			{
				volume-=8;
				if(volume<0) volume=0;
				spc_volume(volume);
			}
		}
	}

	if(!in&&sound) music_stop();
}



//clear all nametables

void clear_nametables(void)
{
	static unsigned int i;

	for(i=0;i<32*32;++i)
	{
		nametable1[i]=0x100;
		nametable2[i]=0x100;
		nametable3[i]=0;
	}
}



//upload all nametables into the VRAM

void update_nametables(void)
{
	copy_to_vram(0x0000,(unsigned char*)nametable1,32*32*2);
	copy_to_vram(0x0400,(unsigned char*)nametable2,32*32*2);
	copy_to_vram(0x7c00,(unsigned char*)nametable3,32*32*2);
}



//set up a background, it includes uploading graphics into the VRAM,
//setting up a palette and nametable
//-1    no background graphics
// 0    title screen (more processing for the mask)
// 1..4 levels and other screens
// 5	how high can you get screen

#define MAKE_MASK(x)	tile=back_buffer[off+0+(x)]|back_buffer[off+8+(x)]; \
						tile|=(tile>>8)|(tile<<8); \
						back_graphics[ptr++]=~tile;

#define MAKE_MASK_F(x)	tile=back_buffer[off+0+(x)]|back_buffer[off+8+(x)]; \
						tile=flipTable[tile&255]|(flipTable[tile>>8]<<8); \
						tile|=(tile>>8)|(tile<<8); \
						back_graphics[ptr++]=~tile;

void set_background(char n)
{
	static unsigned int off,ptr,tile,pp,tiles_all;
	static unsigned char i,j,x,x_off;
	static const unsigned int *pal;

	switch(n)
	{
	case 2:  pal=tileset1alt1_pal; break;
	case 3:  pal=tileset1alt2_pal; break;
	default: pal=tileset1_pal;
	}

	set_palette(16,16,pal);

	if(n<0)
	{
		fill_vram(0x4000,0,24576);

		return;
	}

	x_off=(n*7)&31;//background image horizontal offset depends from the level
	tiles_all=(n?80:358);

	//copy previously uploaded front layer graphics from VRAM to RAM buffer

	copy_from_vram(0x1400,(unsigned char*)back_buffer,tiles_all<<5);

	//convert it to mask

	ptr=0;

	if(!game_flip)
	{
		for(off=0;off<(tiles_all<<4);off+=16)
		{
			MAKE_MASK(0);
			MAKE_MASK(1);
			MAKE_MASK(2);
			MAKE_MASK(3);
			MAKE_MASK(4);
			MAKE_MASK(5);
			MAKE_MASK(6);
			MAKE_MASK(7);
		}
	}
	else
	{
		for(off=0;off<(tiles_all<<4);off+=16)
		{
			MAKE_MASK_F(0);
			MAKE_MASK_F(1);
			MAKE_MASK_F(2);
			MAKE_MASK_F(3);
			MAKE_MASK_F(4);
			MAKE_MASK_F(5);
			MAKE_MASK_F(6);
			MAKE_MASK_F(7);
		}
	}

	//copy background from ROM to RAM buffer

	copy_mem((unsigned char*)back_buffer,(unsigned char*)back1_gfx,24576);

	//put level graphics mask on the background graphics

	ptr=0;
	off=0;

	for(i=0;i<24;++i)
	{
		x=x_off;

		for(j=0;j<32;++j)
		{
			tile=nametable1[off+x]&0x3ff;

			if(tile>0x140)//skip empty and font tiles to save time
			{
				pp=(tile-0x140)<<3;

				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp];

				pp&=~7;

				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp++];
				back_buffer[ptr++]&=back_graphics[pp];
			}
			else
			{
				ptr+=16;
			}

			x=(x+1)&31;
		}

		off+=32;
	}

	//copy modified background graphics from RAM buffer to VRAM

	copy_to_vram(0x4000,(unsigned char*)back_buffer,24576);
	set_palette(112,16,back1_pal);

	off=0;

	for(i=0;i<24;++i)
	{
		x=x_off;

		for(j=0;j<32;++j)
		{
			nametable2[off+x]=off+j+BG_PAL(7);
			x=(x+1)&31;
		}

		off+=32;
	}

	for(off=32*24;off<32*32;++off) nametable2[off]=32*23+BG_PAL(7);
}



//set up a hdma gradient, or disable it
//-1 disable
// 0 no gradient
// 1 level 1
// 2 level 2
// 3 level 3
// 4 level 4
// 5 title, sound test
// 6 levels clear
// 7 how high can you get

void setup_hdma_gradient(char n)
{
	nmi_wait();
	HDMAEN(0);//stop hdma
	nmi_wait();

	if(n<0) return;

	DMA_TYPE(0,0x3200);
	DMA_ADDR(0,(unsigned char*)hdmaTables[n][0]);
	DMA_TYPE(1,0x3200);
	DMA_ADDR(1,(unsigned char*)hdmaTables[n][1]);
	DMA_TYPE(2,0x3200);
	DMA_ADDR(2,(unsigned char*)hdmaTables[n][2]);

	HDMAEN(0x07);//start hdma 0,1,2
}



//set up all needed palettes
//they are fixed for almost everything but background pictures
//and the first half of the tileset

void setup_palettes(void)
{
	set_palette(0  ,16,font_pal);
	set_palette(32 ,16,game_level!=1?tileset2_pal:tileset2alt_pal);
	set_palette(80 ,16,title_top_pal);
	set_palette(96 ,16,title_bottom_pal);

	set_palette(128,16,sprites1_pal);
	set_palette(144,16,sprites2_pal);
	set_palette(160,16,sprites3_pal);
	set_palette(176,16,sprites4_pal);
	set_palette(192,16,sprites5_pal);
	set_palette(208,16,sprites6_pal);
	set_palette(240,16,sprites2_pal);
}



//upload all needed in-game graphics into the VRAM

void setup_ingame_graphics(void)
{
	const unsigned int offset=0x2000;

	copy_to_vram(offset+(PLAYER_TILE  <<4),sprites1_gfx,3072);
	copy_to_vram(offset+(ITEMS_TILE   <<4),sprites2_gfx,2048);
	copy_to_vram(offset+(KONG_TILE    <<4),sprites3_gfx,5120);
	copy_to_vram(offset+(BARREL_TILE  <<4),sprites4_gfx,1024);
	copy_to_vram(offset+(ENEMY_TILE   <<4),sprites5_gfx,4096);
	copy_to_vram(offset+(PRINCESS_TILE<<4),sprites6_gfx,1024);
}



//fade RGB values of current palette array into target palette
//this used in the fade to sepia effect for the game over screen

void palette_fade_to(unsigned int from,unsigned int to)
{
	static unsigned int i,src,dst;

	for(i=from;i<to;++i)
	{
		dst=snes_palette[i];
		src=snes_palette_to[i];

		if((dst&R_MASK)<(src&R_MASK)) ++dst; else
		if((dst&R_MASK)>(src&R_MASK)) --dst;
		if((dst&G_MASK)<(src&G_MASK)) dst+=(1<<5); else
		if((dst&G_MASK)>(src&G_MASK)) dst-=(1<<5);
		if((dst&B_MASK)<(src&B_MASK)) dst+=(1<<10); else
		if((dst&B_MASK)>(src&B_MASK)) dst-=(1<<10);

		snes_palette[i]=dst;
	}
}



//put a text string into a RAM copy of a nametable
//converts ASCII encoding into tiles numbers with attributes

void put_str(unsigned short* dst,const char* str)
{
	static char i;

	while(1)
	{
		i=*str++;

		if(!i) return;

		*dst++=TEXT_ATR+i-32;
	}
}



//put a number of 1-5 digits into a RAM copy of a nametable

void put_num(unsigned short* dst,unsigned int num,unsigned char len)
{
	if(len>=5) *dst++=TEXT_ATR|'0'-32+(num/10000)%10;
	if(len>=4) *dst++=TEXT_ATR|'0'-32+(num/1000)%10;
	if(len>=3) *dst++=TEXT_ATR|'0'-32+(num/100)%10;
	if(len>=2) *dst++=TEXT_ATR|'0'-32+(num/10)%10;
	if(len>=1) *dst++=TEXT_ATR|'0'-32+ num %10;
}



#include "sound_test.h"
#include "title_screen.h"
#include "game_over.h"
#include "particles.h"
#include "game_loop.h"



//shows a 256-color company logo
//it does fade in only, no fade out, as there is sound code upload
//performed while the logo is displayed

void show_logo(void)
{
	static unsigned int i,j,n,bright;

	BGMODE(3+8);	/*mode 3, 2 layers, 256+16 colors*/
	BG1SC(0<<2);	/*32x32 nametable at $0000*/
	BG2SC(1<<2);	/*32x32 nametable at $0400*/
	BG12NBA(0x70);	/*patterns for layers 1 and 2 at $1000*/
	BG34NBA(0x00);	/*patterns for layers 3 and 4 at $1000*/

	copy_to_vram(0x0800,bzlogo_gfx,7168);
	set_palette(0,256,bzlogo_pal);

	for(i=0;i<32*32;++i)
	{
		nametable1[i]=0;
		nametable2[i]=0;
	}

	n=64;

	for(i=0;i<4;++i)
	{
		for(j=0;j<28;++j)
		{
			nametable1[POS(2+j,12+i)]=n;
			++n;
		}
	}

	update_nametables();
	update_palette();

	bright=0;

	for(i=0;i<17<<1;++i)
	{
		nmi_wait();

		if(bright<15)
		{
			++bright;
			set_bright(bright);
		}

		set_pixelize(i>>1);
	}
}



//show PAL compatibility warning screen

void show_pal_warning(void)
{
	static unsigned int i,bright;

	set_bright(0);
	oam_clear();

	clear_nametables();

	put_str(&nametable1[POS(6,7)] ,"PAL SYSTEM DETECTED!");
	put_str(&nametable1[POS(1,11)],"THIS GAME IS DESIGNED FOR NTSC");
	put_str(&nametable1[POS(1,13)],"SYSTEM ONLY.  IT WILL RUN, BUT");
	put_str(&nametable1[POS(1,15)],"SLOWER THAN INTENDED. SORRY.");
	put_str(&nametable1[POS(4,19)],"PRESS START TO CONTINUE");

	update_nametables();
	setup_palettes();
	update_palette();

	bright=0;

	while(1)
	{
		nmi_wait();

		if(bright<15)
		{
			++bright;
			set_bright(bright);
		}

		pad_read_ports();

		i=pad_poll_trigger(0);

		if(i&PAD_START) break;
	}

	fade_screen(0,1);
}



/*the main function, this is where the program starts*/

int main(void)
{
	init();

	/*clear VRAM*/

	fill_vram(0,0,65535);

	/*show logo screen*/

	show_logo();

	/*initialize sound and upload sound data, this takes few seconds*/
	spc_setup();

	global_volume=127;
	global_stereo=1;/*stereo by default, mono can be set with Select on the title screen*/
	game_frame_cnt=0;

	spc_volume(global_volume);
	spc_stereo(global_stereo);

	/*fade logo screen*/

	fade_screen(FALSE,FALSE);

	init();

	/*since there is not much graphics in the game, part of it is loaded into
	  the VRAM at once, only sprites are reloaded when needed*/

	copy_to_vram(0x1000,font_gfx,2048);
	copy_to_vram(0x1400,tileset1_gfx,2048);

	/*show PAL warning*/

	if(!snes_ntsc) show_pal_warning();

	/*reinitialize*/

	set_scroll(1,-1,-1);
	setup_hdma_gradient(-1);

	game_score=0;
	game_best_score=0;
	game_test_mode=FALSE;
	game_hard_mode=FALSE;

	/*main loop*/

	while(1)
	{
		if(title_screen())
		{
			sound_test();
			continue;
		}

		/*setup game variables*/

		game_level=0;
		game_lives=3;
		game_score=0;
		game_loops=!game_hard_mode?0:15;

		/*show intro and the 'how high you can get' cutscene*/

		cutscene_intro();
		cutscene_level();

		/*main levels loop*/

		while(1)
		{
			/*play a level, check if it is clear*/

			if(game_loop()==LEVEL_CLEAR)
			{
				/*level clear, go to the next level*/

				++game_level;

				/*when all three levels are clear, show the clear cutscene*/

				if(game_level==4)
				{
					cutscene_levels_clear();

					game_level=0;

					if(game_loops<255) ++game_loops;
				}

				/*show 'how high you can get' cutscene*/

				cutscene_level();
			}
			else
			{
				/*level is not clear, decrease attemtps counter*/

				if(!game_test_mode) --game_lives;

				/*if there are no lives left, show game over and break the levels loop*/

				if(!game_lives)
				{
					if(game_score>game_best_score) game_best_score=game_score;
					break;
				}
			}
		}
	}

	return 0;/*this never happens*/
}
