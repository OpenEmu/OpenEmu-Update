/* game system */
extern int8u scene_type;
	#define SCENE_SOUND_TEST			0x08
	#define SCENE_DEMO				0x10
	#define SCENE_LOAD				0x20
	#define SCENE_GAME_PLAYING		0x30
	#define SCENE_GAME_PAUSED		0x31
	#define SCENE_DEAD_ALL_ENEMIES	0x32
	#define SCENE_BONUS				0x33
	#define SCENE_TIME_OVER			0x40
	#define SCENE_GAME_OVER			0x41
	#define SCENE_GOTO_NEXT_LEVEL	0x42
	#define SCENE_ALL_CLEAR			0x43
extern int8u stage;
	#define STAGE_COUNT	4
extern int8u level;
	#define LEVEL_COUNT	3
extern int8u frame_count;		/* フレーム毎に加算されるカウンター */
extern int8u scene_wait;		/* シーン用のウェイト */
	#define SCENE_WAIT_INITIAL_VALUE 180

