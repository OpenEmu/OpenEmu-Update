/* サウンドテスト画面 */
#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "port.h"
#include "file.h"
#include "main.h"

#include "actor.h"
#include "map.h"
#include "status.h"
#include "sound_test.h"
#include "game.h"
#include "print.h"

#define SOUND_TEST_COUNT	9
const char text_sound_test[] = "SOUND TEST\0";
const char text_sound_help[] = "PRESS A TO PLAY\0";
const char text_sound_number[] = "SOUND NUMBER \0";
/* ----------------------------------------------------------------------------------- */
void sound_test_init(){
	display_off();
	actors_clear();

	pattern_fill(0x3800, VRAM_FONT + ' ', (BG_HIGH + BG_PAL1 + BG_TOP), 32 * 24 * 2);

	print_init();
	print(text_sound_test, 10);
	store_pattern_name_buffer(4);
	print(text_sound_help, 8);
	store_pattern_name_buffer(21);

	print_init();
	print(text_sound_number, 8);

	display_on();
}
/* ----------------------------------------------------------------------------------- */
void sound_test_main(){
	int8u past_button;
	int8u sound_number;
	
	sound_number = 0;
	while(373){
		past_button = ports[0].button;
		sprites_clear();
		port_read();

		if((past_button & (BUTTON_LEFT | BUTTON_RIGHT | BUTTON_AB)) == 0){
			if(ports[0].button & BUTTON_LEFT){
				sound_number--;
				if(sound_number >= SOUND_TEST_COUNT){
					sound_number = SOUND_TEST_COUNT - 1;
				}
			}
			if(ports[0].button & BUTTON_RIGHT){
				sound_number++;
				if(sound_number >= SOUND_TEST_COUNT){
					sound_number = 0;
				}
			}
			if(ports[0].button & BUTTON_A){
				switch(sound_number){
				case 0:
					psg_set_bgm(fopen("sound/demo.sn7"), FALSE);
					break;
				case 1:
					psg_set_bgm(fopen("sound/stage1.sn7"), TRUE);
					break;
				case 2:
					psg_set_bgm(fopen("sound/jungle.sn7"), TRUE);
					break;
				case 3:
					psg_set_bgm(fopen("sound/nangok.sn7"), TRUE);
					break;
				case 4:
					psg_set_bgm(fopen("sound/over.sn7"), FALSE);
					break;
				case 5:
					psg_set_bgm(fopen("sound/toyam2.sn7"), TRUE);
					break;
				case 6:
					psg_set_bgm(fopen("sound/stagex.sn7"), TRUE);
					break;
				case 7:
					psg_set_bgm(fopen("sound/summer.sn7"), TRUE);
					break;
				case 8:
					psg_set_bgm(fopen("sound/title.sn7"), FALSE);
					break;
				}
			}
			if(ports[0].button & BUTTON_B){
				break;
			}
		}
		pattern_name_buffer[22 << 1] = VRAM_NUMBER + sound_number;
		
		vsync_wait();
		sprites_store();
		/* "SOUND NUMBER" */
		store_pattern_name_buffer(12);
		scroll_store();
		psg_play();
		frame_count++;
	}
	psg_stop();
}

