/* ゲーム */
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
#include "game.h"

void game_init(){
	int8u no;
	int8u count;
	
	display_off();
	pattern_fill(0x3800, 0, (BG_HIGH + BG_PAL1 + BG_TOP), 32 * 28 * 2);

	actors_clear();

	scene_wait = 0;
	player_create(0);
	alive_players = 1;
	smoke_wait = 0;
	scene_type = SCENE_GAME_PLAYING;

	vram_store(0x3000, fopen("bmp/font.ptn"), 0x0800);

	/*  load pattern */
	switch(stage){
	case 0:
		vram_store(0x2000, fopen("bmp/castle.ptn"), 0x1000);
		vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
		break;
	case 1:
		vram_store(0x2000, fopen("bmp/summer.ptn"), 0x1000);
		vram_store(0x0000, fopen("bmp/sp_summer.ptn"), 0x2000);
		break;
	case 2:
		vram_store(0x2000, fopen("bmp/jungle.ptn"), 0x1000);
		vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
		break;
	default:
		vram_store(0x2000, fopen("bmp/winter.ptn"), 0x1000);
		vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
		break;
	}
	
	/* load palette */
	load_palette(stage, 0);

	/* set enemy */
	enemies_rotation_count = level << 3;
	for(count = stage; count != 0; count--){
		/* 8 charactors * 3 levels * stage 2 */
		enemies_rotation_count += 8 * 3;
	}
	enemies_rotation_limit = enemies_rotation_count + 8;

	enemies_count = ACTORS_INITINAL_COUNT;
	enemies_alive = 0;
	enemies_left = 6 + stage;
	for(count = 0; count < enemies_count; count++){
		no = actors_get_null();
		actor_create_random(no);
	}

	display_on();
}
void game_set_bgm(){
	switch(stage){
	case 0:
		psg_set_bgm(fopen("sound/stage1.sn7\0"), TRUE);
		break;
	case 1:
		psg_set_bgm(fopen("sound/summer.sn7\0"), TRUE);
		break;
	case 2:
		psg_set_bgm(fopen("sound/jungle.sn7\0"), TRUE);
		break;
	default:
		psg_set_bgm(fopen("sound/stagex.sn7\0"), TRUE);
		break;
	}
}
void game_swap_players(){
	if(players_count == 1) return;
	if(current_player == 0){
		if(players_continue[1] != 0){
			current_player = 1;
		}
	}else{
		if(players_continue[0] != 0){
			current_player = 0;
		}
	}
}
void game_main(){
	frame_count = 0;
	while(373){
		/* basic updates */
		sprites_clear();
		port_read();
		actors_update();
		status_update();
		if(smoke_wait > 0) smoke_wait--;
		/* vblank */
		vsync_wait();
		sprites_store();
		if(frame_count & 0x01){
			store_pattern_name_buffer(1);	/* status bar */
		}
		scroll_store();
		psg_play();
		frame_count++;
		/* scene status */
		switch(scene_type){
		case SCENE_GAME_PLAYING:
			/* game over ? */
			if(alive_players == 0){
				score_undo();
				if(time_left == 0){
					scene_type = SCENE_TIME_OVER;
					gameover_main("- TIME OVER -");
					psg_stop();
					return;
				}else{
					scene_type = SCENE_GAME_OVER;
					psg_stop();
					return;
				}
			}
			break;
		case SCENE_GAME_PAUSED:
			break;
		case SCENE_DEAD_ALL_ENEMIES:
			nasu_create_all();
			scene_type = SCENE_BONUS;
			break;
		case SCENE_BONUS:
			if(time_left > 0){
				score_add_time_bonus();
				scene_wait = SCENE_WAIT_INITIAL_VALUE;
			}
			if(scene_wait-- == 0){
				scene_type = SCENE_GOTO_NEXT_LEVEL;
			  	level++;
				if(level >= LEVEL_COUNT){
					level = 0;
					stage++;
					if(stage >= STAGE_COUNT){
						scene_type = SCENE_ALL_CLEAR;
					}
				}
				score_store();
				psg_stop();
				return;
			}
			break;
		}
	}
}

