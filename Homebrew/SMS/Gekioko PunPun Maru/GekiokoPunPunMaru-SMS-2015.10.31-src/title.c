/* タイトル画面 */
#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "port.h"
#include "file.h"
#include "main.h"

#include "actor.h"
#include "map.h"
#include "title.h"
#include "game.h"
#include "print.h"

void press_start_button_update(int8u select);	/* blinking */

const char text_press_start_blank[] =  "                         \0";
const char text_press_start_button[] = "PRESS ANY BUTTON TO START\0";
const char text_select_1player[]     = "   - 1 PLAYER GAME -     \0";
const char text_select_2players[]    = "   - 2 PLAYERS GAME -    \0";
const char text_select_sound_test[]  = "     - SOUND TEST -      \0";
const char text_copy_light[] = "JAIREM ALL RIGHTS RESERVED\0";

/* ----------------------------------------------------------------------------------- */
void title_init(){
	display_off();
	actors_clear();

	palette_store( 0, fopen("bmp/title.pal"), 16);
	palette_store(16, fopen("bmp/sp_castle.pal"), 16);

	vram_store(0x0000, fopen("bmp/sp_castle.ptn"), 0x2000);
	vram_store(0x2000, fopen("bmp/title.ptn"), 0x1000);
	vram_store(0x3000, fopen("bmp/font.ptn"), 0x0800);
	vram_store(0x3800, fopen("map/title.map"), (32 * 24 * 2));

	ninja_cake_create(0);
	actors_x[0] = 8;
	actors_y[0] = 144;
	actors_angle[0] = ANGLE_RIGHT;

	map_make_pointer(STAGE_COUNT, 0);

	print_init();
	print(text_copy_light, 3);
	store_pattern_name_buffer(22);
	
	print_init();
	display_on();
	psg_set_bgm(fopen("sound/title.sn7"), FALSE);
}
void title_main(){
	int8u scene;
	int8u scene_counter;
	int8u count;
	int8u select;
	int8u past_button;

	scene = 0;
	scene_counter = 9;
	frame_count = 0;
	select = 111;	/* iniial value == "PRESS START BUTTON" */

	while(373){
		past_button = ports[0].button;
		sprites_clear();
		port_read();

		if((past_button & (BUTTON_UP | BUTTON_DOWN | BUTTON_AB)) == 0){
			/* "PRESS START BUTTON" */
			if(select == 111){
				if(ports[0].button & BUTTON_AB){
					select = 0;
				}
			}else{
			/* "1 PLAYER GAME" */
				if(ports[0].button & BUTTON_AB){
					switch(select){
					case 0:	/* single player game */
						scene_type = SCENE_LOAD;
						players_count = 1;
						players_continue[0] = PLATER_DEFAULT_LIVES;
						players_continue[1] = 0;
						break;
					case 1: /* two players game */
						scene_type = SCENE_LOAD;
						players_count = 2;
						players_continue[0] = PLATER_DEFAULT_LIVES;
						players_continue[1] = PLATER_DEFAULT_LIVES;
						break;
					case 2: /* sound test */
						scene_type = SCENE_SOUND_TEST;
						break;
					}
					break;
				}
				if(ports[0].button & BUTTON_DOWN){
					select++;
					if(select > 2) select = 0;
				}
				if(ports[0].button & BUTTON_UP){
					select--;
					if(select > 2) select = 2;
				}
			}		
		}		
		if(actors_x[0] > 248){
			if(actors_type[0] == ACTOR_NINJA_CAKE){
				player_create(0);
				actors_x[0] = 8;
				actors_y[0] = 144;
			}else{
				actors_type[0] = ACTOR_NULL;
			}
		}

		/* player go to right */
		ports[0].button |= BUTTON_RIGHT;

		actors_update();
		for(count = ACTORS_COUNT; count > 0; count--){
			if(actors_x[count] >= 250){
				actors_type[count] = ACTOR_NULL;
			}
		}

		press_start_button_update(select);
		vsync_wait();
		sprites_store();
		/* "PRESS ANY BUTTON TO START" */
		store_pattern_name_buffer(19);
		scroll_store();
		psg_play();
		frame_count++;
		if((frame_count & 0x3F) == 0){
			scene_counter--;
			if(scene_counter == 0) break;
		}
	}
	psg_stop();
}
void press_start_button_update(int8u select){
	/* text */
	switch(select){
	case 0:
		print(text_select_1player, 4);
		break;
	case 1:
		print(text_select_2players, 4);
		break;
	case 2:
		print(text_select_sound_test, 4);
		break;
	default:
		print(text_press_start_button, 4);
		break;
	}
	if((select == 111) && (frame_count & 0x10)){
		print(text_press_start_blank, 4);
	}
}

