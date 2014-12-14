#include "neslib.h"

#include "map1_nam.h"
#include "map2_nam.h"
#include "map3_nam.h"
#include "map4_nam.h"
#include "map5_nam.h"
#include "map6_nam.h"
#include "map7_nam.h"
#include "bonus_nam.h"
#include "title_nam.h"
#include "gameover_nam.h"
#include "welldone_nam.h"
#include "metaspr.h"
#include "animations.h"
#include "palettes.h"

extern const unsigned char mus_level[];
extern const unsigned char mus_gameover[];
extern const unsigned char mus_clear[];
extern const unsigned char mus_game[];
extern const unsigned char mus_welldone[];
extern const unsigned char mus_dream[];
extern const unsigned char mus_nobonus[];


const unsigned char verStr[]="v1.02 30.12.11";


const unsigned char bonusMessages[2*30]={
"       SORRY, NO BONUS!       "
"   WELL DONE, YOU GET BONUS!  "
};


#define MESSAGES_SPACE		20

const unsigned char spaceMessages[MESSAGES_SPACE*30]={
"  PLUTO IS SMALLER THAN MOON  "
"VENUS BRIGHTEST PLANET OF SKY "
"JOVIAN ARE JUPITER SATELLITES "
"VIKINGS 1 AND 2 LANDED ON MARS"
" THE HOTTEST PLANET IS VENUS  "
"  CERES IS LARGEST ASTEROID   "
" AL-SUFI SAW ANDROMEDA GALAXY "
"   TITAN HAS METHANE LAKES    "
"EUROPA HAS OXYGENE ATMOSPHERE "
"KUPIER BELT IS BEYOND NEPTUNE "
"  PIONEER 10 FLEW BY JUPITER  "
"VENERA 4 LANDED ON VENUS IN 67"
"HALLEY HAS 75-76 YEARS PERIOD "
"  ALBEDO IS REFLECTION COEFF. "
"ECCENTRICITY IS PAR. OF ORBIT "
"KEPLER - LAWS OF PLANET MOTION"
" PROMETHEUS IS VOLCANO ON IO  "
"ARISTARCHUS WAS HELIOCENTRIST "
"TYCHO BRAHE MADE MEASUREMENTS "
" URANUS ROTATES ON IT'S SIDE  "
};

#define MESSAGES_HISTORY	9

const unsigned char historyMessages[MESSAGES_HISTORY*30]={
"MACBETH WAS A KING OF SCOTLAND"
//"WARS OF ROSES 4 ENGLISH THRONE"
"3 KINGDOMS - OF EGYPT'S GLORY "
"JERICHO - EARLIEST KNOWN CITY "
" LOUIS XIV RULED FOR 72 YEARS "
//"100 YEARS WAR 4 FRENCH THRONE "
"ANNO DOMINI = YEAR OF OUR LORD"
"   CE MEANS COMMON ERA = AD   "
"STONEHENGE IS OLDER THAN 4200 "
" VICTORIA RULED 1837 TO 1901  "
"SNOW IN SAHARA ON 18 FEB 1979 "
};

#define MESSAGES_EARTH		9

const unsigned char earthMessages[MESSAGES_EARTH*30]={
" MARCO POLO TRAVELLED TO ASIA "
"MAGELLAN CROSSED PACIFIC OCEAN"
"  MT. EVEREST IS 8850 M HIGH  "
" AMUNDSEN REACHED SOUTH POLE  "
//"NANSEN ALMOST GOT 2 NORTH POLE"
"DR LIVINGSTONE EXPLORED AFRICA"
"VASCO DA GAMA SAILED TO INDIA "
"EARTH RADIUS IS ABOUT 6370 KM "
" MARIANA TRENCH IS 11 KM DEEP "
"  WATER COVERS 71% OF EARTH   "
};

#define MESSAGES_BOOKS		10

const unsigned char booksMessages[MESSAGES_BOOKS*30]={
"RHYMES ARE EASIER TO REMEMBER "
"VIRGIL IS THE AUTHOR OF AENEID"
"   OVID WROTE METAMORPHOSES   "
"EURIPIDES WON PRIZE FOR MEDEA "
"AESCHYLUS INTRODUCED DIALOGUE "
"   TAO TE CHING IS BY LAOZI   "
"DIVINE COMEDY WRITTEN BY DANTE"
" PUSHKIN WROTE EUGENE ONEGIN  "
" ONEGIN IS ABOUT TRENDY DANDY "
"  COLERIDGE WROTE KUBLA KHAN  "
};



#define MAP_WDT		32
#define MAP_WDT_BIT	5
#define MAP_HGT		22

#define TILE_SIZE	8
#define TILE_BIT	3

#define FP_BITS		4
#define FP_MASK		15

#define TILE_WALL	1
#define TILE_LADDER	2

#define TILE_NUM_PHONE		0x01
#define TILE_NUM_PLAYER		0x10
#define TILE_NUM_CHIEF		0x11
#define TILE_NUM_BOUNCER	0x12
#define TILE_NUM_CHATTER	0x13
#define TILE_NUM_GEEK		0x14
#define TILE_NUM_MANBOX		0x15
#define TILE_NUM_DIBROV		0x16
#define TILE_NUM_GHOST		0x17
#define TILE_NUM_TABLE		0x0a
#define TILE_NUM_TOPIC		0x76
#define TILE_NUM_TOPIC1		0x66
#define TILE_NUM_TOPIC2		0x68
#define TILE_NUM_TOPIC3		0x55
#define TILE_NUM_TOPIC4		0x57
#define TILE_NUM_COFFEE		0x87



const unsigned char tileAttr[256]={
0,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
0,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,
TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,TILE_WALL,0,0,0,

0,TILE_LADDER,TILE_LADDER,TILE_WALL,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,TILE_WALL,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0
};

const char levelNumberStr[7*3]={
	0x00,0x24,0x21,0x39,0x1a,0x11,0x00,//day:0
	0x00,0x24,0x32,0x25,0x21,0x2d,0x00,//dream
	0x37,0x25,0x25,0x2b,0x25,0x2e,0x24 //ending
};

#define DIR_NONE	0
#define DIR_LEFT	1
#define DIR_RIGHT	2
#define DIR_UP		4
#define DIR_DOWN	8

static int           player_x;
static unsigned int  player_y;
static unsigned char player_px;
static unsigned char player_py;
static const unsigned char *player_spr;
static const unsigned char *player_spr_prev;
static unsigned char player_ladder;
static unsigned char player_dir;
static unsigned char player_dir_prev;
static unsigned int  player_dir_cnt;
static unsigned char player_floor;
static unsigned char player_topic;
static unsigned int  player_speed;
static unsigned int  player_speed_to;
static unsigned char player_coffee;
static unsigned int  player_step_cnt;
static unsigned char player_step_type;
static unsigned char player_slowdown;
static unsigned char player_step_anim;
static unsigned char player_knocked;
static unsigned char player_knocked_anim;
static unsigned int  player_wisdom;
static unsigned char player_catch;
static unsigned char player_answer;

static unsigned char topics_active;



static unsigned char map[MAP_WDT*MAP_HGT];

#define SFX_RINGTONE	0
#define SFX_STEP1		1
#define SFX_STEP2		2
#define SFX_STEP3		3
#define SFX_STEP4		4
#define SFX_FALL		5
#define SFX_DROP		6
#define SFX_TOPIC		7
#define SFX_ANSWER		8
#define SFX_BLA1		9
#define SFX_MISS		10
#define SFX_COFFEE		11
#define SFX_START		12
#define SFX_PAUSE		13
#define SFX_LOSE		14
#define SFX_BLA2		15
#define SFX_COFFEE_READY	16
#define SFX_KNOCK		17
#define SFX_WISDOM		18
#define SFX_EXPLODE		19
#define SFX_TELEPORT	20

#define SFX_ALL			21

#define MUS_LEVEL		0
#define MUS_CLEAR		1
#define MUS_GAMEOVER	2
#define MUS_GAME		3
#define MUS_WELLDONE	4
#define MUS_DREAM		5
#define MUS_NOBONUS		6

#define MUS_ALL			7

const unsigned char* const musicData[MUS_ALL]={
mus_level,
mus_clear,
mus_gameover,
mus_game,
mus_welldone,
mus_dream,
mus_nobonus
};

//#define NPC_MAX			2

#define NPC_NONE		0
#define NPC_CHIEF		TILE_NUM_CHIEF
#define NPC_BOUNCER		TILE_NUM_BOUNCER
#define NPC_CHATTER		TILE_NUM_CHATTER
#define NPC_GEEK		TILE_NUM_GEEK
#define NPC_MANBOX		TILE_NUM_MANBOX
#define NPC_DIBROV		TILE_NUM_DIBROV
#define NPC_GHOST		TILE_NUM_GHOST


static unsigned char npc_all;
static unsigned char npc_type;//[NPC_MAX];
static int           npc_x;//   [NPC_MAX];
static int 			 npc_y;//   [NPC_MAX];
static unsigned char npc_dir;// [NPC_MAX];
static unsigned int  npc_cnt;// [NPC_MAX];
static const unsigned char *npc_spr;//[NPC_MAX];
static unsigned char npc_tx;//  [NPC_MAX];
static unsigned char npc_ty;//  [NPC_MAX];
static unsigned char npc_wait;//[NPC_MAX];
static unsigned char npc_speed;//[NPC_MAX];
static int			 npc_dx ;// [NPC_MAX];
static int			 npc_dy;//  [NPC_MAX];

#define PHONE_MAX 4

static unsigned char phone_all;
static unsigned char phone_x    [PHONE_MAX];
static unsigned char phone_y    [PHONE_MAX];
static unsigned int  phone_cnt  [PHONE_MAX];
static unsigned char phone_level[PHONE_MAX];
static unsigned char phone_topic[PHONE_MAX];

static unsigned char phone_runaway;
static unsigned char phone_runaway_max;

#define TABLE_MAX 6

static unsigned char table_all;
static unsigned int  table_off[TABLE_MAX];
static unsigned char table_cur;

#define TOPIC_MAX 4

static unsigned char topic_all;
static unsigned char topic_x [TOPIC_MAX];
static unsigned char topic_y [TOPIC_MAX];
static unsigned char topic_id[TOPIC_MAX];

static unsigned char topic_flash_x;
static unsigned char topic_flash_y;
static unsigned char topic_flash_spr;
static unsigned char topic_flash_cnt;

static unsigned char topic_msg[TOPIC_MAX];

#define HEARTS_MAX	8

static unsigned char heart_ptr;

static unsigned char heart_x [HEARTS_MAX];
static unsigned char heart_y [HEARTS_MAX];
static unsigned char heart_cnt[HEARTS_MAX];

//nametable update list for stats and items

#define UPDATE_LIST_MAX	32
#define UPDL_MESSAGE	0*3
#define UPDL_COFFEE		1*3
#define UPDL_TOPIC		2*3
#define UPDL_STATS		4*3
#define UPDL_PHONES		8*3

static unsigned char update_list_len;

static unsigned char update_list[UPDATE_LIST_MAX*3];

const unsigned char updateListData[]={
0x20,0x00,0x00,//UPDL_MESSAGE
0x20,0x00,0x00,//UPDL_COFFEE
0x20,0x42,0x00,//UPDL_TOPIC
0x20,0x43,0x00,
0x20,0x51,0x00,//calls count tens
0x20,0x52,0x00,//calls count
0x20,0x5c,0x00//miss
};

//general vars, global to work faster

static unsigned char i,j;
static unsigned char px,py;
static unsigned char spr,spr1;
static unsigned int  i16,j16;
static unsigned char state;

static unsigned char frame_cnt;

static unsigned char calls_count;
static unsigned char calls_missed;
static unsigned char calls_missed_max;
static unsigned char calls_missed_level;
static unsigned char calls_level;
static unsigned int  call_delay;

static unsigned char coffee_x;
static unsigned char coffee_y;
static unsigned int  coffee_wait;

static unsigned char level;
static unsigned char pause;
static unsigned char bonus;

static unsigned int ring_cnt;

static unsigned char msg_cnt;
static const unsigned char *msg_ptr;
static unsigned char msg_wait;
static unsigned char msg_off;

static unsigned char test_mode;

const unsigned char topicList[4*2]={
0x66,0x67,
0x68,0x69,
0x55,0x56,
0x57,0x58
};

const unsigned char* const topicMessages[4]={
earthMessages,
historyMessages,
booksMessages,
spaceMessages
};

const unsigned char topicMessagesCount[4]={
MESSAGES_EARTH,
MESSAGES_HISTORY,
MESSAGES_BOOKS,
MESSAGES_SPACE
};


const unsigned char testCode[]={ PAD_B,PAD_A,PAD_B,PAD_A,PAD_LEFT,PAD_UP,PAD_B,PAD_A,0 };

#define FLOORS_MAX	4

static unsigned char floor_left_cnt;
static unsigned char floor_right_cnt;
static unsigned char floor_left [FLOORS_MAX];
static unsigned char floor_right[FLOORS_MAX];

#define LEVELS_ALL	8
#define LEVEL_BONUS 4

const unsigned char* const levelMaps[LEVELS_ALL*3]={
map1_nam, palGameBG1,palGameBG1,
map2_nam, palGameBG2,palChief,
map3_nam, palGameBG3,palBouncer,
map4_nam, palGameBG4,palChatter,
bonus_nam,palBonus,  palGhost,
map5_nam, palGameBG5,palGeek,
map6_nam, palGameBG6,palManBox,
map7_nam, palGameBG7,palDibrov
};

const unsigned int levelSettings[LEVELS_ALL*3]={//calls, delay between calls, number of topics
10,250,2,
15,250,2,
20,250,3,
25,250,3,
1,0,0,//bonus
30,275,4,
35,400,4,
40,450,4
};

const unsigned char nameStats[30]={
	0x7b,0x00,0x00,0x7c,0x40,0x24,0x21,0x39,0x1a,0x00,0x00,0x23,0x21,0x2c,0x2c,
	0x1a,0x00,0x00,0x0f,0x00,0x00,0x00,0x2d,0x29,0x33,0x33,0x1a,0x00,0x0f,0x00
};




unsigned int abs(int num)
{
	if(num<0) return 0-num; else return num;
}



unsigned char check_map(unsigned char x,unsigned char y)
{
	i16=x>>TILE_BIT;
	j16=y>>TILE_BIT;

	j16-=6;
	if(j16>128) j16=0;

	return map[(j16<<MAP_WDT_BIT)+i16];
}



void player_coord_wrap(void)
{
	if(player_x<0) player_x=((256-16)<<FP_BITS);
	if(player_x>((256-16)<<FP_BITS)) player_x=0;
}



void player_align_to_ladder(void)
{
	while(!(check_map((player_x>>FP_BITS)+3 ,py)&TILE_LADDER)) player_x+=(1<<FP_BITS);
	while(!(check_map((player_x>>FP_BITS)+12,py)&TILE_LADDER)) player_x-=(1<<FP_BITS);

	player_ladder=1;
	player_dir_cnt=16<<FP_BITS;
}



void phone_reset(unsigned char id,unsigned int delay,unsigned char answer)
{
	if(answer)
	{
		phone_level[id]=255;
		phone_cnt  [id]=25;
	}
	else
	{
		phone_level[id]=0;
		phone_cnt  [id]=call_delay+delay+(unsigned int)(rand8()&63);
	}

	phone_topic[id]=rand8()%topics_active;
		
	id=id*12+2+UPDL_PHONES;

	update_list[id]  =animPhone[0];
	update_list[id+3]=0;
	update_list[id+6]=0;
	update_list[id+9]=0;

	if(answer) return;

	if(call_delay>125) call_delay-=10;
}



void sound_steps(unsigned char dir)
{
	player_step_cnt+=player_speed;

	if(player_step_cnt>=(8<<FP_BITS))
	{
		sfx_play(SFX_STEP1+player_step_type+(dir<<1),0);
		player_step_cnt-=(8<<FP_BITS);
		player_step_type^=1;
	}
}



void update_stats(void)
{
	if(calls_count!=calls_level||(frame_cnt&16))
	{
		update_list[UPDL_STATS+2]=16+calls_count/10;
		update_list[UPDL_STATS+5]=16+calls_count%10;
	}
	else
	{
		update_list[UPDL_STATS+2]=0;
		update_list[UPDL_STATS+5]=0;
	}

	if(calls_missed!=calls_missed_level||(frame_cnt&16))
	{
		update_list[UPDL_STATS+8]=16+calls_missed;
	}
	else
	{
		update_list[UPDL_STATS+8]=0;
	}
}



void update_list_add(unsigned int tile)
{
	update_list[update_list_len++]=j16>>8;
	update_list[update_list_len++]=j16&255;
	update_list[update_list_len++]=tile;
}



void hearts_add(unsigned char x,unsigned char y)
{
	for(j=0;j<HEARTS_MAX;++j)
	{
		++heart_ptr;

		if(heart_ptr>=HEARTS_MAX) heart_ptr=0;

		if(heart_y[heart_ptr]>=240)
		{
			heart_x  [heart_ptr]=x-4+(rand8()&7);
			heart_y  [heart_ptr]=y;
			heart_cnt[heart_ptr]=24+(rand8()&7);
			break;
		}
	}
}



void set_message(const unsigned char *msg)
{
	msg_ptr=msg;
	msg_cnt=30;
	msg_wait=2*50;
	msg_off=0;
}



void show_message(void)
{
	if(msg_ptr)
	{
		if(msg_cnt)
		{
			update_list[UPDL_MESSAGE+1]=0x81+msg_off;
			update_list[UPDL_MESSAGE+2]=msg_ptr[msg_off]-0x20;
			++msg_off;
			--msg_cnt;
		}
		else
		{
			if(msg_wait)
			{
				--msg_wait;
			}
			else
			{
				msg_ptr=NULL;
				msg_off=0;
			}
		}
	}
	else
	{
		update_list[UPDL_MESSAGE+1]=0x81+msg_off;
		update_list[UPDL_MESSAGE+2]=0x00;
		++msg_off;
		if(msg_off>=30) msg_off=0;
	}
}



void change_screen(void)
{
	music_stop();
	pal_clear();
	set_vram_update(0,0);
	ppu_waitnmi();
	ppu_off();
	oam_clear();
}



void set_level_palettes(void)
{
	i=level*3;

	pal_bg(levelMaps[i+1]);
	pal_spr(palSecretary);

	pal_col(25,levelMaps[i+2][1]);//npc palette
	pal_col(26,levelMaps[i+2][2]);
	pal_col(27,levelMaps[i+2][3]);
}



void move_phone(unsigned char table)
{
	table_cur=table;

	i16=table_off[table];

	px= (i16&31)<<3;
	py=((i16>>5)&31)<<3;

	phone_x[0]=px;
	phone_y[0]=py;

	memcpy(&update_list[UPDL_PHONES+9],&update_list[UPDL_PHONES],9);
	update_list[UPDL_PHONES+9+2]=0;
	update_list[UPDL_PHONES+9+5]=0;
	update_list[UPDL_PHONES+9+8]=0;

	update_list[UPDL_PHONES+0]=i16>>8;
	update_list[UPDL_PHONES+1]=i16&255;
	update_list[UPDL_PHONES+2]=animPhone[0];
	--i16;
	update_list[UPDL_PHONES+3]=i16>>8;
	update_list[UPDL_PHONES+4]=i16&255;
	update_list[UPDL_PHONES+5]=0;
	i16+=2;
	update_list[UPDL_PHONES+6]=i16>>8;
	update_list[UPDL_PHONES+7]=i16&255;
	update_list[UPDL_PHONES+8]=0;
}



void set_vram_update1(void)
{
	set_vram_update(update_list_len/3,update_list);
}



#include "npc.h"


unsigned char game_loop(void)
{
	bonus=(level==LEVEL_BONUS)?1:0;

	i=level*3;

	calls_level=levelSettings[i];
	calls_count=0;
	calls_missed=0;
	call_delay=levelSettings[i+1];

	topics_active=levelSettings[i+2];

	unrle_vram(levelMaps[i],0x2000);

	vram_read(map,0x20c0,MAP_WDT*MAP_HGT);

	if(!bonus)
	{
		vram_write((unsigned char*)nameStats,0x2041,30);

		i=level;
		if(i>LEVEL_BONUS) --i;
		vram_adr(0x204a);
		vram_put(i+17);
	}

	vram_adr(0x2054);
	vram_put(16+calls_level/10);
	vram_put(16+calls_level%10);
	vram_adr(0x205e);
	vram_put(16+calls_missed_level);

	frame_cnt=0;
	ring_cnt=0;
	pause=0;

	player_spr=animWalkRight[0];
	player_spr_prev=player_spr;
	player_ladder=0;
	player_dir=DIR_NONE;
	player_dir_prev=DIR_RIGHT;
	player_dir_cnt=0;
	player_floor=1;
	player_topic=255;
	player_speed=1<<FP_BITS;
	player_speed_to=player_speed;
	player_step_cnt=0;
	player_step_type=0;
	player_slowdown=0;
	player_coffee=0;
	player_step_anim=0;
	player_knocked=0;
	player_knocked_anim=0;
	player_wisdom=0;
	player_catch=0;
	player_answer=0;

	coffee_y=0;
	coffee_wait=150;
	topic_flash_cnt=0;

	npc_all=0;
	phone_all=0;
	topic_all=0;
	table_all=0;
	phone_runaway_max=5;
	phone_runaway=phone_runaway_max;

	msg_ptr=NULL;
	msg_cnt=0;
	msg_wait=0;
	msg_off=0;

	for(i=0;i<sizeof(update_list);++i) update_list[i]=0;
	memcpy(update_list,updateListData,sizeof(updateListData));

	update_list_len=UPDL_PHONES;

	update_stats();

	i16=0;
	py=6*8;

	for(i=0;i<MAP_HGT;++i)
	{
		px=0;

		for(j=0;j<MAP_WDT;++j)
		{
			spr=map[i16];

			switch(spr)
			{
			case TILE_NUM_PHONE:
				phone_x[phone_all]=px;
				phone_y[phone_all]=py;
				phone_reset(phone_all,((unsigned int)phone_all)<<8,0);
				++phone_all;

				j16=0x20c0+i16;
				update_list_add(animPhone[0]);//phone
				--j16;
				update_list_add(0);//ring left
				j16+=2;
				update_list_add(0);//ring right
				j16=0x20c0+i16-64;
				update_list_add(0);//topic

				map[i16]=0;
				break;

			case TILE_NUM_PLAYER:
				player_x=px<<FP_BITS;
				player_y=(py-16)<<FP_BITS;
				map[i16]=0;
				break;

			case TILE_NUM_CHIEF:
			case TILE_NUM_BOUNCER:
			case TILE_NUM_CHATTER:
			case TILE_NUM_GEEK:
			case TILE_NUM_MANBOX:
			case TILE_NUM_DIBROV:
			case TILE_NUM_GHOST:
				npc_add(spr);
				map[i16]=0;
				break;

			case TILE_NUM_TOPIC1:
			case TILE_NUM_TOPIC2:
			case TILE_NUM_TOPIC3:
			case TILE_NUM_TOPIC4:
				topic_x[topic_all]=px-2;
				topic_y[topic_all]=py+24;

				switch(spr)
				{
				case TILE_NUM_TOPIC1: spr=0; break;
				case TILE_NUM_TOPIC2: spr=1; break;
				case TILE_NUM_TOPIC3: spr=2; break;
				case TILE_NUM_TOPIC4: spr=3; break;
				default:              spr=255;
				}

				topic_id[topic_all]=spr;
				topic_msg[spr]=rand8()%topicMessagesCount[spr];

				++topic_all;

				break;

			case TILE_NUM_COFFEE:
				coffee_x=px;
				coffee_y=py+1;

				j16=0x20c0+i16;
				update_list[UPDL_COFFEE+0]=j16>>8;
				update_list[UPDL_COFFEE+1]=j16&255;
				update_list[UPDL_COFFEE+2]=0x87;
				break;

			case TILE_NUM_TABLE:
				table_off[table_all++]=0x20c0+i16;
				map[i16]=0;
				break;
			}

			++i16;
			px+=8;
		}

		py+=8;
	}

	vram_write(map,0x20c0,MAP_WDT*MAP_HGT);

	floor_left_cnt=0;
	floor_right_cnt=0;
	i16=0;
	j16=0;
	py=6*8-24;

	for(i=0;i<MAP_HGT;++i)
	{
		map[i16]   =map[i16+1];
		map[i16+31]=map[i16+30];

		for(j=0;j<32;++j)
		{
			map[i16]=tileAttr[map[i16]];
			++i16;
		}

		if(i)
		{
			if(map[j16]&&!map[j16-32])
			{
				if(floor_left_cnt<FLOORS_MAX) floor_left[floor_left_cnt++]=py;
			}

			if(map[j16+31]&&!map[j16-1])
			{
				if(floor_right_cnt<FLOORS_MAX) floor_right[floor_right_cnt++]=py;
			}
		}

		j16+=32;
		py+=8;
	}

	if(bonus)
	{
		update_list_len+=6*3;
		phone_all=1;
		move_phone(5);
		phone_reset(0,25,0);
	}

	set_vram_update1();

	heart_ptr=0;

	for(i=0;i<HEARTS_MAX;++i) heart_y[i]=240;

	ppu_on_all();

	music_play(!bonus?mus_game:mus_dream);

	ppu_waitnmi();
	set_level_palettes();

	while(1)
	{
		if(pause==25)
		{
			state=pad_trigger();

			if(state&PAD_START)
			{
				set_level_palettes();
				sfx_play(SFX_PAUSE,3);
				music_pause(0);
				pause=24;
			}
		}
		else
		{
			if(pause) --pause;
		}

		if(pause>=25)
		{
			ppu_waitnmi();
			continue;
		}

		++frame_cnt;
		++ring_cnt;

		//display mask on the right side of the screen

		py=15;

		for(spr=0;spr<24*4;spr+=4)
		{
			oam_spr(248,py,0xff,0,spr);
			py+=8;
		}

		//display player

		//spr=meta_spr_wrap(player_x>>FP_BITS,(player_y>>FP_BITS)-1,spr,player_spr);

		px= player_x>>FP_BITS;
		py=(player_y>>FP_BITS)-1;

		spr=oam_meta_spr(px,py,spr,player_spr);

		i=255;

		if(px<8)
		{
			px+=(256-16);
			i=0;
		}
		else
		{
			if(px>=(256-16-8))
			{
				px+=16;
				i=4;
			}
		}

		if(i<255)
		{
			for(;i<24;i+=8)
			{
				spr=oam_spr(px+player_spr[i+0],py+player_spr[i+1],player_spr[i+2],player_spr[i+3],spr);
			}
		}

		//display npcs

		npc_display();

		//display hearts

		for(i=0;i<HEARTS_MAX;++i)
		{
			if(heart_cnt[i]>=12) j=0x38; else j=0x3d-(heart_cnt[i]>>1);

			spr=oam_spr(heart_x[i],heart_y[i],j,0,spr);
		}

		//display flashing topic icon when needed

		if(topic_flash_cnt&2)
		{
			spr=oam_spr(topic_flash_x  ,topic_flash_y,topic_flash_spr  ,1,spr);
			spr=oam_spr(topic_flash_x+8,topic_flash_y,topic_flash_spr+1,1,spr);
		}

		//hide unused sprites, needed for oam cycling

		oam_hide_rest(spr);

		ppu_waitnmi();

		//poll controller

		state=pad_trigger();

		if(!pause&&(state&PAD_START))
		{
			sfx_play(SFX_PAUSE,3);
			music_pause(1);
			pal_fade();
			pause=50;
			continue;
		}

		state=pad_state();

		//process player movements

		px=player_x>>FP_BITS;
		py=player_y>>FP_BITS;

		if(!player_knocked)
		{
			if(!check_map(px+4,py+24)&&!check_map(px+12,py+24))
			{
				player_y+=4<<FP_BITS;
				player_ladder=0;

				if(player_floor)
				{
					player_floor=0;
					sfx_play(SFX_FALL,1);
				}
			}
			else
			{
				if(!player_floor)
				{
					player_floor=1;
					sfx_play(SFX_DROP,1);
				}

				if(player_dir_cnt)
				{
					switch(player_dir)
					{
					case DIR_UP:
						player_y-=player_speed;

						if(player_y<(32<<FP_BITS)) player_y+=(240-48-32)<<FP_BITS;

						player_spr=animWalkUp[(player_y>>FP_BITS>>2)&1];
						py=player_y>>FP_BITS;

						if(!(check_map(px+8,py+23)&TILE_LADDER))
						{
							player_dir_cnt=0;
							player_ladder=0;
							player_y&=~(7<<FP_BITS);

							if(!(check_map(px+8,py+24)&TILE_LADDER)) player_y+=(8<<FP_BITS);
						}
						break;

					case DIR_DOWN:
						player_y+=player_speed;

						if(player_y>((240-48)<<FP_BITS)) player_y-=(240-48-32)<<FP_BITS;

						player_spr=animWalkDown[(player_y>>FP_BITS>>2)&1];
						py=player_y>>FP_BITS;

						if(!(check_map(px+8,py+24)&TILE_LADDER))
						{
							player_dir_cnt=0;
							player_ladder=0;
							player_y&=~(7<<FP_BITS);
						}
						break;
					}

					if(player_dir_cnt)
					{
						player_dir_cnt-=player_speed;
						if(player_dir_cnt>=32767) player_dir_cnt=0;
					}

					sound_steps(1);
				}

				if(!player_dir_cnt)
				{
					px=player_x>>FP_BITS;
					py=(player_y>>FP_BITS)+23;

					if(state&PAD_UP&&!(state&PAD_DOWN))
					{
						if((check_map(px+6,py)&TILE_LADDER)&&
						   (check_map(px+9,py)&TILE_LADDER))
						{
							player_align_to_ladder();
							player_dir=DIR_UP;
						}
						else
						{
							player_ladder=0;
						}
					}

					++py;

					if(state&PAD_DOWN&&!(state&PAD_UP))
					{
						if((check_map(px+6,py)&TILE_LADDER)&&
						   (check_map(px+9,py)&TILE_LADDER))
						{
							player_align_to_ladder();
							player_dir=DIR_DOWN;
						}
						else
						{
							player_ladder=0;
						}
					}
				}

				if(!player_ladder)//not on a ladder
				{
					if(state&PAD_LEFT)
					{
						player_dir=DIR_LEFT;
						player_dir_prev=player_dir;
						player_x-=player_speed;
						player_coord_wrap();

						++player_step_anim;

						sound_steps(0);
					}

					if(state&PAD_RIGHT)
					{
						player_dir=DIR_RIGHT;
						player_dir_prev=player_dir;
						player_x+=player_speed;
						player_coord_wrap();

						++player_step_anim;

						sound_steps(0);
					}
				}
			}

			i=((player_step_anim>>2)&3)+(player_answer?4:0);

			switch(player_dir)
			{
			case DIR_LEFT:
				player_spr=animWalkLeft[i];
				player_spr_prev=player_spr;
				break;

			case DIR_RIGHT:
				player_spr=animWalkRight[i];
				player_spr_prev=player_spr;
				break;
			}
		}
		else
		{
			switch(player_dir_prev)
			{
			case DIR_LEFT:  player_spr=animKnockedLeft [player_knocked_anim?0:1]; break;
			case DIR_RIGHT: player_spr=animKnockedRight[player_knocked_anim?0:1]; break;
			}

			--player_knocked;

			if(player_knocked_anim) --player_knocked_anim;

			if(!player_knocked) player_spr=player_spr_prev;
		}

		if(player_answer) --player_answer;

		player_px=player_x>>FP_BITS;
		player_py=player_y>>FP_BITS;

		if(coffee_y)
		{
			if(coffee_wait)
			{
				--coffee_wait;

				if(coffee_wait==16) sfx_play(SFX_COFFEE_READY,1);

				if(coffee_wait<16)
				{
					update_list[UPDL_COFFEE+2]=coffee_wait&2?0x87:0x8f;
				}
			}
			else
			{
				if(!(coffee_y>=(player_py+24)||(coffee_y+8)<player_py))
				{
					if(!(coffee_x>=(player_px+16)||(coffee_x+8)<player_px))
					{
						update_list[UPDL_COFFEE+2]=0x87;
						player_coffee=20;
						coffee_wait=20*50;
						sfx_play(SFX_COFFEE,1);
					}
				}
			}
		}

		i=(1<<FP_BITS)+(1<<FP_BITS>>1)+(player_coffee>>1);

		if(player_slowdown)
		{
			player_speed_to=i*4/6;
		}
		else
		{
			player_speed_to=i;
		}

		if(!(frame_cnt&63)&&player_coffee) --player_coffee;

		if(player_speed<player_speed_to) ++player_speed;
		if(player_speed>player_speed_to) --player_speed;

		if(bonus) player_wisdom=100;
		if(player_wisdom) --player_wisdom;

		//process topics areas

		if(!player_wisdom)
		{
			for(i=0;i<topic_all;++i)
			{
				px=topic_x[i];
				py=topic_y[i];

				if(player_topic!=topic_id[i])
				{
					if(!(py>=(player_py+24)||(py+8)<player_py))
					{
						if(!(px>=(player_px+16)||(px+12)<player_px))
						{
							sfx_play(SFX_TOPIC,1);
							player_topic=topic_id[i];

							topic_flash_x=px+2;
							topic_flash_y=py-25;
							topic_flash_cnt=16;
							topic_flash_spr=0x30+(topic_id[i]<<1);

							break;
						}
					}
				}
			}
		}

		if(topic_flash_cnt) --topic_flash_cnt;

		//process phone counters

		if(bonus)
		{
			pal_col(31,frame_cnt&2?0x2a:0x1a);

			if(!phone_runaway)
			{
				if(player_py==(phone_y[0]-8))
				{
					if(!((player_px+32)<(phone_x[0]-16)||player_px>(phone_x[0]+8+32)))
					{
						i=table_cur;
						while(i==table_cur) i=rand8()%TABLE_MAX;

						move_phone(i);
						if(phone_runaway_max<250) phone_runaway_max+=10;
						phone_runaway=phone_runaway_max;
						sfx_play(SFX_TELEPORT,1);
					}
				}
			}
			else
			{
				--phone_runaway;
			}
		}

		spr=0;//if any phone is ringing
		spr1=(ring_cnt>>2)%3;//ring animation

		j=2+UPDL_PHONES;

		for(i=0;i<phone_all;++i)
		{
			if(phone_level[i]==255)
			{
				--phone_cnt[i];

				if(!phone_cnt[i]) phone_reset(i,0,0); else update_list[j]=0xe6;
				j+=12;

				continue;
			}

			if(phone_level[i])
			{
				px=phone_level[i]<<2;
				if(!(ring_cnt&32)) px+=((phone_cnt[i]>>2)&3);
				update_list[j]=animPhone[px];

				if(ring_cnt&32)
				{
					update_list[j+3]=0;
					update_list[j+6]=0;
				}
				else
				{
					update_list[j+3]=0xf0+spr1;
					update_list[j+6]=0xf3+spr1;
				}

				if(player_topic==phone_topic[i]||player_wisdom)
				{
					px=phone_x[i];
					py=phone_y[i];

					if(!(py>=(player_py+24)||(py+8)<player_py))
					{
						if(!(px>=(player_px+16)||(px+8)<player_px))
						{
							if(!bonus)
							{
								phone_reset(i,0,1);
								player_answer=25;

								set_message(&topicMessages[player_topic][topic_msg[player_topic]*30]);

								topic_msg[player_topic]=(topic_msg[player_topic]+1+(rand8()&3))%topicMessagesCount[player_topic];
							}

							sfx_play(bonus?SFX_EXPLODE:SFX_ANSWER,2);
							++calls_count;
						}
					}
				}

				if(!(ring_cnt&63)) spr=1;
			}

			if(phone_cnt[i])
			{
				--phone_cnt[i];
			}
			else
			{
				if(!phone_level[i])
				{
					update_list[j+9]=TILE_NUM_TOPIC+phone_topic[i];
					spr=1;
					ring_cnt=0;
				}

				if(!bonus)
				{
					++phone_level[i];

					if(phone_level[i]<4)
					{
						phone_cnt[i]=200;
					}
					else
					{
						phone_reset(i,0,0);
						++calls_missed;

						sfx_play(calls_missed<calls_missed_level?SFX_MISS:SFX_LOSE,3);
					}
				}
				else
				{
					phone_level[i]=2;
				}
			}

			j+=12;
		}

		if(spr) sfx_play(SFX_RINGTONE,2);

		//process npc movements

		player_slowdown=0;

		//for(i=0;i<npc_all;++i)
		//{
		if(npc_all)
		{
			px=npc_x;//[i];
			py=npc_y;//[i];

			switch(npc_type)//[i])
			{
			case NPC_CHIEF:   npc_chief();   break;
			case NPC_BOUNCER: npc_bouncer(); break;
			case NPC_CHATTER: npc_chatter(); break;
			case NPC_GEEK:	  npc_geek();    break;
			case NPC_MANBOX:  npc_manbox();  break;
			case NPC_DIBROV:  npc_dibrov();  break;
			case NPC_GHOST:   npc_ghost();   break;
			}
		}
		//}

		//show message

		show_message();

		//show topic

		update_list[UPDL_TOPIC+2]=0;
		update_list[UPDL_TOPIC+5]=0;

		if(!player_wisdom)
		{
			if(frame_cnt&16&&player_topic!=255)
			{
				i=player_topic<<1;
				update_list[UPDL_TOPIC+2]=topicList[i];
				update_list[UPDL_TOPIC+5]=topicList[i+1];
			}
		}
		else
		{
			if(frame_cnt&4)
			{
				update_list[UPDL_TOPIC+2]=0x53;
				update_list[UPDL_TOPIC+5]=0x54;
			}
		}

		//process hearts

		if(player_wisdom&&!bonus)
		{
			if(!(frame_cnt&7)) hearts_add(player_px+8,player_py+4-(spr<<2));
		}

		if(frame_cnt&1) spr=0; else spr=HEARTS_MAX/2;

		for(i=0;i<(HEARTS_MAX/2);++i)
		{
			if(heart_y[spr]!=240)
			{
				j=heart_cnt[spr]&7;

				if(!(frame_cnt&2))
				{
					if(j<4) --heart_x[spr]; else ++heart_x[spr];
				}

				--heart_y[spr];
				--heart_cnt[spr];

				if(!heart_cnt[spr]) heart_y[spr]=240;
			}

			++spr;
		}

		//check gameover or level clear

		if(calls_count>calls_level) calls_count=calls_level;
		if(calls_missed>calls_missed_level) calls_missed=calls_missed_level;

		update_stats();

		if(calls_count==calls_level) break;//level clear
		if(calls_missed==calls_missed_level) break;//level lose
		if(player_catch) break;//bonus lose
	}

	music_stop();

	if(bonus&&calls_count==calls_level)
	{
		update_list[UPDL_PHONES+2]=0;
		update_list[UPDL_PHONES+5]=0;
		update_list[UPDL_PHONES+8]=0;

		spr=0xf0;

		for(i=0;i<32;++i)
		{
			ppu_waitnmi();
			update_stats();
			oam_spr(phone_x[0],phone_y[0],spr,1,252);
			if((i&1)==1&&spr<0xf8) ++spr;
			++frame_cnt;
		}

		update_list[UPDL_STATS+7]+=2;

		for(j=0;j<2;j++)
		{
			++calls_missed_max;
			calls_missed=calls_missed_max;
			sfx_play(SFX_ANSWER,2);

			for(i=0;i<25;++i)
			{
				ppu_waitnmi();
				update_stats();
				++frame_cnt;
			}
		}
	}

	j=4*50;

	if(calls_count==calls_level)
	{
		if(bonus) set_message(&bonusMessages[1*30]);
		music_play(mus_clear);
	}
	else
	{
		if(player_catch)
		{
			set_message(&bonusMessages[0*30]);
			music_play(mus_nobonus);
		}
		else
		{
			j=3*50;
		}
	}

	for(i=0;i<j;++i)
	{
		ppu_waitnmi();
		update_stats();
		show_message();
		++frame_cnt;
	}

	change_screen();

	return (calls_count==calls_level||bonus)?1:0;
}



void title_screen(void)
{
	pal_bg(palTitle);
	pal_spr(palTitle);
	unrle_vram(title_nam,0x2000);
	ppu_on_all();

	frame_cnt=0;
	i=0;

	while(1)
	{
		pal_col(14,frame_cnt&32?0x30:0x0f);
		ppu_waitnmi();

		state=pad_trigger();

		if(state&&i<255)
		{
			if(state==testCode[i])
			{
				++i;

				if(!testCode[i])
				{
					i=255;
					sfx_play(SFX_BLA1,1);
					test_mode=1;
				}
			}
			else
			{
				i=0;
			}
		}

		if(state&PAD_START) break;

		rand16();
		++frame_cnt;
	}

	sfx_play(SFX_START,0);

	frame_cnt=4;

	for(i=0;i<72;++i)
	{
		pal_col(14,frame_cnt&4?0x30:0x0f);
		ppu_waitnmi();

		++frame_cnt;
	}

	state=pad_state();

	if(state==(PAD_A|PAD_B|PAD_SELECT|PAD_START))//sound test
	{
		oam_meta_spr(88,168,12,sprSoundTest);

		j=0;
		px=0;
		py=0;

		while(1)
		{
			ppu_waitnmi();
			oam_spr(108,168,0x10+(px/10),j?0:2,0);
			oam_spr(116,168,0x10+(px%10),j?0:2,4);
			oam_spr(164,168,0x10+py,!j?0:2,8);

			state=pad_trigger();

			if(state&PAD_START) break;

			if(state&PAD_LEFT)  j=0;
			if(state&PAD_RIGHT) j=1;

			if(state&PAD_UP)
			{
				if(!j) { if(px<SFX_ALL-1) ++px; } else { if(py<MUS_ALL-1) ++py; }
			}

			if(state&PAD_DOWN)
			{
				if(!j) { if(px) --px; } else { if(py) --py; }
			}

			if(state&PAD_A) music_stop();

			if(state&PAD_B)
			{
				if(!j) sfx_play(px,0); else music_play(musicData[py]);
			}
		}
	}

	change_screen();
}



void update_level_str(unsigned char lev)
{
	unsigned char str[7];

	switch(lev)
	{
	case LEVEL_BONUS:
		memcpy(str,levelNumberStr+7,7);
		break;

	case LEVELS_ALL:
		memcpy(str,levelNumberStr+14,7);
		break;

	default:
		if(lev>LEVEL_BONUS) --lev;
		memcpy(str,levelNumberStr,7);
		str[5]=0x11+lev;
	}

	i16=0x21ac;
	update_list_len=0;

	for(i=0;i<7;++i)
	{
		update_list[update_list_len++]=i16>>8;
		update_list[update_list_len++]=i16&0xff;
		update_list[update_list_len++]=str[i];
		++i16;
	}
}



void show_level_number(void)
{
	pal_bg(palGameBG1);
	vram_adr(0x2000);
	vram_fill(0,960);
	vram_fill(255,64);
	update_level_str(level);
	set_vram_update1();
	ppu_on_bg();

	if(test_mode)
	{
		while(1)
		{
			ppu_waitnmi();

			state=pad_trigger();

			if(state&(PAD_START|PAD_A|PAD_B)) break;

			if(state&PAD_LEFT)
			{
				if(level)
				{
					--level;
					update_level_str(level);
				}
			}

			if(state&PAD_RIGHT)
			{
				if(level<LEVELS_ALL)
				{
					++level;
					update_level_str(level);
				}
			}
		}
	}

	if(level<LEVELS_ALL) music_play(mus_level);

	for(i=0;i<50*3;++i) ppu_waitnmi();

	change_screen();
}



void show_game_over(void)
{
	pal_bg(palGameBG1);
	pal_col(14,0x0f);
	unrle_vram(gameover_nam,0x2000);
	ppu_on_bg();

	i16=0;

	music_play(mus_gameover);

	while(1)
	{
		ppu_waitnmi();

		state=pad_trigger();

		++i16;

		if(i16>=50*10) break;
		if(i16>50&&(state&PAD_START)) break;
	}

	music_stop();
	sfx_play(SFX_START,0);

	frame_cnt=0;

	for(i=0;i<50*3;++i)
	{
		ppu_waitnmi();

		++frame_cnt;

		pal_col(14,frame_cnt&8?0x0f:palGameBG1[14]);
	}

	change_screen();
}



void show_congratulations(void)
{
	pal_bg(palWellDone);
	pal_spr(palWellDoneSpr);
	unrle_vram(welldone_nam,0x2000);
	ppu_on_all();

	spr=0;
	py=31;

	for(i=0;i<10;++i)
	{
		spr=oam_spr( 72,py,0x3f,3,spr);
		spr=oam_spr(176,py,0x3f,3,spr);
		py+=8;
	}

	frame_cnt=0;

	spr=0;
	i16=0;
	j16=0;
	i=255;

	music_play(mus_welldone);

	while(1)
	{
		if(i>=180)
		{
			spr=frame_cnt&64?1:0;
		}
		else
		{
			if(i<80||i>=120) spr=2; else spr=3;
			++i;
		}

		spr=oam_meta_spr(128,95,20*4,animSecretaryRest[spr]);
		spr=oam_spr(0,240,0,0,spr);
		spr=oam_spr(0,240,0,0,spr);

		ppu_waitnmi();

		if(i16<50)
		{
			++i16;
		}
		else
		{
			state=pad_trigger();

			if(state&PAD_START) break;
		}

		++j16;

		if(j16>=1280) j16=0;

		if(j16==1240) sfx_play(SFX_RINGTONE,0);
		if(j16==1270) i=0;

		++frame_cnt;
	}

	music_stop();
	pal_clear();
	for(i=0;i<25;++i) ppu_waitnmi();

	change_screen();
}




void main(void)
{
	bank_bg(0);
	ppu_mask(0);
	change_screen();

	test_mode=0;

	while(1)
	{
		bank_spr(0);
		title_screen();
		bank_spr(1);

		level=0;
		calls_missed_max=3;

		while(1)
		{
			calls_missed_level=calls_missed_max;

			show_level_number();

			if(level==LEVELS_ALL)
			{
				show_congratulations();
				break;
			}

			if(game_loop())
			{
				++level;
			}
			else
			{
				show_game_over();
			}
		}
	}
}