/* ゲーム中のステータス表示 */
#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "file.h"
#include "main.h"

#include "actor.h"
#include "map.h"
#include "status.h"
#include "game.h"
#include "print.h"

const char text_status_name[]  = "   STAGE ENEMY SCORE TIME LIFE  \0";
const char text_status_value[] = "     -   #X        0 %    1P    \0";

/* 得点 */
int8u score_ints[4 * 2];	/* 現在のステータス表示用BCD */
int8u score_ints_latest[4 * 2];	/* ステージクリア時のステータス表示用BCD */

/* 時間 */
int8u time_ints[3];	/* ステータス表示用BCD */
int8u time_left;		/* 残り時間 */

/* --------------------------------------------------------------------------------- */
void status_init(){
	time_init();

	print(text_status_name ,0);
	vsync_wait();
	store_pattern_name_buffer(0);

	print(text_status_value ,0);
	pattern_name_buffer[26 << 1] = VRAM_NUMBER + 1 + current_player;
	vsync_wait();
	store_pattern_name_buffer(1);
}
void status_update(){
	time_update();

	switch(frame_count & 0x07){
	case 0: /* stage */
		pattern_name_buffer[ 4 << 1] = (VRAM_NUMBER + 1) + stage;
		pattern_name_buffer[ 6 << 1] = (VRAM_NUMBER + 1) + level;
		/* enemies left */
		pattern_name_buffer[11 << 1] = VRAM_NUMBER + enemies_left;
		break;
	case 2: /* score */
		if(current_player == 0){
			pattern_name_buffer[15 << 1] = VRAM_NUMBER + score_ints[3];
			pattern_name_buffer[16 << 1] = VRAM_NUMBER + score_ints[2];
			pattern_name_buffer[17 << 1] = VRAM_NUMBER + score_ints[1];
			pattern_name_buffer[18 << 1] = VRAM_NUMBER + score_ints[0];
		}else{
			pattern_name_buffer[15 << 1] = VRAM_NUMBER + score_ints[7];
			pattern_name_buffer[16 << 1] = VRAM_NUMBER + score_ints[6];
			pattern_name_buffer[17 << 1] = VRAM_NUMBER + score_ints[5];
			pattern_name_buffer[18 << 1] = VRAM_NUMBER + score_ints[4];
		}
		break;
	case 4: /* time */
		pattern_name_buffer[22 << 1] = VRAM_NUMBER + time_ints[2];
		pattern_name_buffer[23 << 1] = VRAM_NUMBER + time_ints[1];
		pattern_name_buffer[24 << 1] = VRAM_NUMBER + time_ints[0];
		break;
	case 6: /* player left */
		pattern_name_buffer[29 << 1] = VRAM_NUMBER + players_continue[current_player];
		/* time left */
		if((player_y >= TIME_LEFT_BORDER) && ((frame_count >> 4) & 0x01)){
			pattern_name_buffer[21 << 1] = VRAM_FONT + ' ';
		}else{
			pattern_name_buffer[21 << 1] = VRAM_FONT + '%';
		}
		break;
	default:
		break;
	}
}
/* --------------------------------------------------------------------------------- */
void time_init(){
	time_left = 101;
	time_ints[2] = 1;
	time_ints[1] = 0;
	time_ints[0] = 1;
}
void time_update(){

	if((frame_count & 0x0F) > 0) return;
	if(scene_type != SCENE_GAME_PLAYING) return;
	if(player_y < TIME_LEFT_BORDER) return;
	if(time_left == 0) return;
	time_decliment();
}
void time_decliment(){
	time_left--;

	/* BCD sub */
	time_ints[0]--;
	if(time_ints[0] == 255){
		time_ints[0] = 9;
		time_ints[1]--;
		if(time_ints[1] == 255){
			time_ints[1] = 9;
			time_ints[2]--;
		}
	}
}
/* --------------------------------------------------------------------------------- */
void score_init(){
	int8u c;
	
	for(c = 0; c < (4 * 2); c++){
		score_ints[c] = 0;
	}
	score_store();
}
void score_add(int8u score){
	/* BCD add */
	if(current_player == 0){
		score_ints[0] += score;
		if(score_ints[0] > 9){
			score_ints[0] -= 10;
			score_ints[1]++;
			if(score_ints[1] > 9){
				score_ints[1] -= 10;
				score_ints[2]++;
				if(score_ints[2] > 9){
					score_ints[2] -= 10;
					score_ints[3]++;
				}
			}
		}
	}else{
		score_ints[4] += score;
		if(score_ints[4] > 9){
			score_ints[4] -= 10;
			score_ints[5]++;
			if(score_ints[5] > 9){
				score_ints[5] -= 10;
				score_ints[6]++;
				if(score_ints[6] > 9){
					score_ints[6] -= 10;
					score_ints[7]++;
				}
			}
		}
	}
}
/* 確定させる */
void score_store(){
	int8u a;
	int8u c;
	
	a = current_player << 2;
	for(c = 0; c < 4; c++){
		score_ints_latest[a] = score_ints[a];
		a++;
	}
}
/* 戻す */
void score_undo(){
	int8u a;
	int8u c;
	
	a = current_player << 2;
	for(c = 0; c < 4; c++){
		score_ints[a] = score_ints_latest[a];
		a++;
	}
}
void score_add_time_bonus(){
	score_add(1);
	time_decliment();
	if((time_left & 0x03) == 0){
		psg_set_se(psg_score);
	}
}
/* --------------------------------------------------------------------------------- */

