/* イントロ */
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
#include "print.h"

int8u *serif;
const char ending_text[] = {
	" - CAST -\0"
	"PUN PUN MARU\0"
	"HUNGRY NINJA\0"
	"I LOVE CAKE\0"
	"RED BOAR\0"
	"DARUMA\0"
	"TENGU\0"
	"HIME\0"
	"BLUE BIRD\0"
	"GREEN FLOG\0"
	"YODARE GOAST\0"
	"BOO NASU THE BONUS\0"
	"PROGRAM - MOUNT CHOCOLATE\0"
	"ORIGINAL TITLE GFX - HIROM\0"
	"GRAFIX - MOUNT CHOCOLATE\0"
	"VGM CONVERSION - ROPHON\0"
	" \0"
	"ORIGINAL MUSIC COMPOSERS\0"
	" MANABU NAMIKI\0"
	" HYDDEN\0"
	" ROPHON\0"
	" YUMI\0"
	" SAKAMOTO KYOJU\0"
	" \0"
	"- THANK YOU FOR PLAYING -\0"
	" \0"
	" \0"
	"\0"
};
#define ENDING_ACTOR_START	2
#define ENDING_ACTOR_END	12

/* ----------------------------------------------------------------------------------- */
void basic_init_for_intro(){
	display_off();
	actors_clear();

	palette_store( 0, fopen("bmp/title.pal"), 16);
	palette_store(16, fopen("bmp/sp_castle.pal"), 16);
	vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
	vram_store(0x2000, fopen("bmp/title.ptn"), 0x1800);
	vram_store(0x3800, fopen("map/intro.map"), (32 * 24 * 2));

	map_make_pointer(STAGE_COUNT, 0);
	frame_count = 0;
	print_init();
	display_on();
}
void basic_update_for_intro(){
	actors_update();
	vsync_wait();
	sprites_store();
	vram_store(0x3800 + (64 * 8), serif, 64);
	psg_play();
	frame_count++;
}
/* ----------------------------------------------------------------------------------- */
void intro_main(){
	int8u scene;
	int8u scene_counter;
	int8u c;
	int8u *sour;
	int8u *dist;

	basic_init_for_intro();
	scene = 0;
	scene_counter = 240;

	sour = fopen("map/intro.map");
	sour += 32 * (24 + 0) * 2;
	dist = map_cache;
	for(c = 32 * 3; c != 0; c--){
		*dist++ = *sour++;
		*dist++ = *sour++;
	}
	serif = map_cache;
	psg_set_bgm(fopen("sound/demo.sn7"), FALSE);

	while(373){
		sprites_clear();
		port_read();

		if(ports[0].button & BUTTON_AB){
			scene_type = SCENE_LOAD;
			break;
		}

		switch(scene){
		case 0:
			ninja_create(0);
			actors_x[0] = 40;
			actors_y[0] = 140;
			actors_angle[0] = ANGLE_RIGHT;
			scene++;
			break;
		case 1:
			if(actors_x[0] == 116){
				ninja_cake_create(0);
				actors_x[0] = 115;
				actors_y[0] = 140;
				actors_angle[0] = ANGLE_RIGHT;
				scene++;
			}
			break;
		case 2:
			if(actors_x[0] > 208){
				actors_type[0] = ACTOR_NULL;
				scene_counter = 60;
				scene++;
			}
			break;
		case 3:
			if(scene_counter == 0){
				player_create(0);
				actors_x[0] = 40;
				actors_y[0] = 144;
				scene++;
			}
			break;
		case 4:
			/* player go to right */
			ports[0].button |= BUTTON_RIGHT;
			if(actors_x[0] >= 88){
				scene_counter = 60;
				scene++;
			}
			break;
		case 5:
			if(scene_counter == 0){
				serif += 64;
				scene_counter = 120;
				scene++;
			}
		case 6:
			if(scene_counter == 0){
				serif += 64;
				scene_counter = 120;
				scene++;
			}
		case 7:
			if(scene_counter == 0){
				return;
			}
		}

		scene_counter--;
		basic_update_for_intro();
	}
	psg_stop();
}
/* ----------------------------------------------------------------------------------- */
void intro_ending_main(){
	int8u scene;
	int8u scene_counter;
	int8u c;
	int8u *sour;
	int8u *dist;

	basic_init_for_intro();
	scene = 0;
	scene_counter = 240;

	sour = fopen("map/intro.map");
	sour += 32 * (24 + 3) * 2;
	dist = map_cache;
	for(c = 32 * 5; c != 0; c--){
		*dist++ = *sour++;
		*dist++ = *sour++;
	}
	serif = map_cache;

	psg_set_bgm(fopen("sound/demo.sn7"), FALSE);

	while(373){
		sprites_clear();
		port_read();

		switch(scene){
		case 0:	/*  */
			ninja_cake_create(0);
			actors_x[0] = 40;
			actors_y[0] = 140;
			actors_angle[0] = ANGLE_RIGHT;
			scene++;
			break;
		case 1:	/* ケーキを持って冷蔵庫の前まで来る */
			if(actors_x[0] >= 114){
				actors_type[0] = ACTOR_NULL;
				actors_x[0] = 115;
				actors_y[0] = 144;
				scene_counter = 120;
				scene++;
			}
			if(actors_y[0] < 32){
				actors_speed_y[0] = 32;
			}
			break;
		case 2:	/* ケーキを持って「もうこりごりだ」 */
			actor_set_sprite(0, 16, VRAM_NINJA_CAKE + 4, 0);
			if(scene_counter == 0){
				serif += 64;
				scene_counter = 120;
				scene++;
			}
			break;
		case 3:	/* 「ここにケーキを入れる！」 */
			actor_set_sprite(0, 16, VRAM_NINJA + 4, 0);
			if(scene_counter == 0){
				ninja_create(0);
				actors_x[0] = 115;
				actors_y[0] = 144;
				actors_angle[0] = ANGLE_RIGHT;
				serif += 64;
				scene_counter = 120;
				scene++;
			}
			break;
		case 4:	/* 忍者が去る */
			if(actors_x[0] > 208){
				actors_type[0] = ACTOR_NULL;
				scene_counter = 120;
				scene++;
			}
			break;
		case 5:	/* 誰も居ない間 */
			//scene_counter--;
			if(scene_counter == 0){
				player_create(0);
				actors_x[0] = 40;
				actors_y[0] = 144;
				scene_counter = 120;
				scene++;
			}
			break;
		case 6:	/* ぷんぷん丸が来る */
			ports[0].button |= BUTTON_RIGHT;
			if(actors_x[0] >= 88){
				scene_counter = 240;
				scene++;
			}
			break;
		case 7:	/* 「なんだ俺のケーキあるじゃないか」 */
			if(scene_counter == 120){
				serif += 64;
			}
			if(scene_counter == 0){
				boar_create(1);
				actors_x[1] = 40;
				actors_y[1] = 144;
				actors_angle[1] = ANGLE_RIGHT;
				scene++;
			}
			break;
		case 8:	/* イノシシが来る */
			if(actors_x[1] > 108){
				actors_speed_x[0] = 32 + 31;
				actors_speed_y[0] = 32 - 32;
				scene++;
			}
			break;
		case 9:	/* 突き飛ばされる */
			if(actors_x[0] > 208){
				psg_stop();
				return;
			}
			break;
		}
		scene_counter--;
		basic_update_for_intro();
	}
}
/* ----------------------------------------------------------------------------------- */
void ending_main(){
	int8u actor_no;
	int8u scene_counter;
	char  *text;
	int8u text_row;
	int8u c;

	actors_clear();
	actor_no = ENDING_ACTOR_START;
	scene_counter = 1;
	text = ending_text;
	scroll_y = 0;

	/* clear bottom 4 rows */
	print_init();
	for(c = 24; c < 28; c++){
		vsync_wait();
		store_pattern_name_buffer(c);
	}
	
	psg_set_bgm(fopen("sound/summer.sn7"), TRUE);

	while(373){
		sprites_clear();
		port_read();
		
		/* generate text */
		text_row = scroll_y >> 3;
		text_row--;
		scene_counter--;
		if(scene_counter == 0){
			scene_counter = 255;
			text_row--;
			c = print(text, 4);
			if(c < 2) break;
			text += c;
		}else{
			print_init();
		}
		
		/* actors */
		if(scene_counter == 1){
			if(actor_no <= ENDING_ACTOR_END){
				switch(actor_no){
				case ACTOR_PLAYER:
					player_create(0);
					actors_speed_y[0] = 32 - 32;
					break;
				case ACTOR_NINJA:
					ninja_create(0);
					break;
				case ACTOR_NINJA_CAKE:	
					actors_type[0] = ACTOR_NINJA_CAKE;
					break;
				case ACTOR_BOAR:
					boar_create(0);
					break;
				case ACTOR_DARUMA:
					daruma_create(0);
					break;
				case ACTOR_TENGU:
					tengu_create(0);
					break;
				case ACTOR_HIME:
					hime_create(0);
					break;
				case ACTOR_BIRD:
					bird_create(0);
					break;
				case ACTOR_FLOG:
					flog_create(0);
					break;
				case ACTOR_GOAST:
					goast_create(0);
					actors_y[0] = 192;
					actors_x[0] = 250;
					break;
				case ACTOR_NASU:
					nasu_create(0);
					break;
				}
			}else{
				actors_type[0] = ACTOR_NULL;
			}
			actor_no++;
		}

		/* scroll */
		if(frame_count & 0x01){
			scroll_y++;
			if(scroll_y > 224){
				scroll_y = 0;
			}
		}

		/* updates */
		actors_update();
		vsync_wait();
		sprites_store();
		store_pattern_name_buffer(text_row);
		scroll_store();
		psg_play();
		frame_count++;
	}
	psg_stop();
}
/* ----------------------------------------------------------------------------------- */
void gameover_main(char *message){
	int8u c;

	display_off();

	palette_store( 0, fopen("bmp/title.pal"), 16);
	palette_store(16, fopen("bmp/sp_castle.pal"), 16);

	vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
	vram_store(0x2000, fopen("bmp/title.ptn"), 0x1000);
	vram_store(0x3000, fopen("bmp/font.ptn"), 0x800);
	pattern_fill(0x3800, 0, BG_HIGH, 32 * 24 * 2);

	print_init();
	store_pattern_name_buffer(10);
	print(message, 10);
	store_pattern_name_buffer(9);

	print("1P SCORE XXXX0 ", 8);
	pattern_name_buffer[17 << 1] = VRAM_NUMBER + score_ints[3];
	pattern_name_buffer[18 << 1] = VRAM_NUMBER + score_ints[2];
	pattern_name_buffer[19 << 1] = VRAM_NUMBER + score_ints[1];
	pattern_name_buffer[20 << 1] = VRAM_NUMBER + score_ints[0];
	store_pattern_name_buffer(11);

	if(players_count == 2){
		print("2P SCORE XXXX0 ", 8);
		pattern_name_buffer[17 << 1] = VRAM_NUMBER + score_ints[7];
		pattern_name_buffer[18 << 1] = VRAM_NUMBER + score_ints[6];
		pattern_name_buffer[19 << 1] = VRAM_NUMBER + score_ints[5];
		pattern_name_buffer[20 << 1] = VRAM_NUMBER + score_ints[4];
		store_pattern_name_buffer(13);
	}

	actors_clear();
	scroll_y = 0;
	print_init();
	display_on();
	psg_set_bgm(fopen("sound/over.sn7"), FALSE);
	
	for(c = 6; c != 0; c--){
		for(frame_count = 0; frame_count < 60; frame_count++){
			sprites_clear();
			vsync_wait();
			sprites_store();
			scroll_store();
			psg_play();
		}
	}
	psg_stop();
}
/* ----------------------------------------------------------------------------------- */

