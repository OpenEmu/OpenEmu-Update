#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "port.h"
#include "file.h"
#include "main.h"

#include "actor.h"
#include "map.h"
#include "status.h"
#include "intro.h"
#include "title.h"
#include "sound_test.h"
#include "game.h"

int8u scene_type;
int8u stage;
int8u level;
int8u frame_count;		/* フレーム毎に加算されるカウンター */
int8u scene_wait;		/* シーン用のウェイト */

void main(){
	vdp_init();
	port_init();
	psg_init();
	scene_type = SCENE_DEMO;
	while(373){
		stage = 0;	/* リセットしないとデモでぷんぷん丸が滑り続ける */
		current_player = 0;
		while(373){
			scene_type = SCENE_DEMO;
			title_init();
			title_main();
			if(scene_type == SCENE_LOAD) break;
			if(scene_type == SCENE_SOUND_TEST){
				sound_test_init();
				sound_test_main();
				scene_type = SCENE_DEMO;
			}else{
				intro_main();
			}
		}
		intro_main();
		score_init();
		level = 0;
		/* cheat */
		if(ports[0].button & BUTTON_UP) stage = 1;
		if(ports[0].button & BUTTON_LEFT) stage = 2;
		if(ports[0].button & BUTTON_RIGHT) stage = 3;
		if(ports[0].button & BUTTON_DOWN){
			scene_type = SCENE_ALL_CLEAR;
		}else{
			while(373){
				game_init();
				map_show();
				game_set_bgm();
				game_main();
				game_swap_players();
				psg_init();
				/* game over when there is no players */
				if((players_continue[0] == 0) && (players_continue[1] == 0)){
					break;
				}
			}
		}
		if(scene_type == SCENE_ALL_CLEAR){
			stage = 0;		/* リセットしないとデモでぷんぷん丸が滑り続ける */
			current_player = 0;
			intro_ending_main();	/* intro loop */
			ending_main();		/* ending loop */
		}
		gameover_main("- GAME OVER -");
	}
}

