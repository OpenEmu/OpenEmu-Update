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

//title screen code


//display or hide press start message

void title_screen_press_start_str(unsigned char show)
{
	put_str(&nametable1[POS(10,22)],show?"PRESS START":"           ");
}



//update nametable

void title_screen_update(void)
{
	copy_to_vram(0x0000,(unsigned char*)nametable1,32*32*2);
}



//fill a rectangle in the nametable

void title_set_rect(unsigned int off,unsigned char wdt,unsigned char hgt,unsigned int tile,unsigned char swdt)
{
	static unsigned char i,j;
	
	for(i=0;i<hgt;++i)
	{
		for(j=0;j<wdt;++j) nametable1[off+j]=tile+j;
		
		off+=32;
		tile+=swdt;
	}
}



//title screen loop

unsigned char title_screen(void)
{
	static unsigned int i,j,cnt,off,bright,codet,codeh;
	const char* const soundMode[3]={"           "," MONO MODE ","STEREO MODE"};
	const unsigned int testCode[]={PAD_B,PAD_A,PAD_R,PAD_R,PAD_A,PAD_L};
	const unsigned int hardCode[]={PAD_B,PAD_A,PAD_DOWN,PAD_B,PAD_UP,PAD_DOWN,PAD_DOWN,PAD_Y};

	set_bright(0);
	setup_hdma_gradient(-1);
	oam_clear();

	copy_to_vram(0x1800,title_top_gfx   ,2400);
	copy_to_vram(0x1cb0,title_bottom_gfx,7030);

	clear_nametables();
	
	title_set_rect(POS( 4, 5),13,3,0x180|BG_PAL(5),25);
	title_set_rect(POS( 4, 8),24,9,0x1cb|BG_PAL(6),24);
	title_set_rect(POS(16,17),12,3,0x18d|BG_PAL(5),25);

	set_background(0);

	put_str(&nametable1[POS( 4, 2)],"SCORE:000000");
	put_str(&nametable1[POS(17, 2)],"BEST:000000");
	put_str(&nametable1[POS( 8,26)],"@2012 BUBBLEZAP");

	put_num(&nametable1[POS(10,2)],game_score,5);
	put_num(&nametable1[POS(22,2)],game_best_score,5);

	update_nametables();
	setup_palettes();
	update_palette();

	setup_hdma_gradient(5);

	bright=0;
	game_frame_cnt=0;
	cnt=0;
	codet=0;
	codeh=0;

	music_play(MUS_TITLE);

	while(1)
	{
		title_screen_press_start_str(game_frame_cnt&32);

		put_str(&nametable1[POS(10,24)],soundMode[cnt?global_stereo+1:0]);

		nmi_wait();

		title_screen_update();

		++game_frame_cnt;

		if(bright<15)
		{
			++bright;
			set_bright(bright);
		}

		pad_read_ports();

		i=pad_poll_trigger(0);

		if(bright==15&&i&PAD_START) break;

		//select changes stereo sound mode
		
		if(i&PAD_SELECT)
		{
			global_stereo^=1;
			spc_stereo(global_stereo);
			sfx_play(SFX_CHN+2,SFX_ITEM,128);
			cnt=60;
		}

		if(i)
		{
			//check the test code
			
			if(testCode[codet]==i)
			{
				++codet;

				if(codet==6)
				{
					sfx_play(SFX_CHN+2,SFX_LOVE,128);
					game_test_mode^=TRUE;
					codet=0;
				}
			}
			else
			{
				codet=0;
			}
			
			if(hardCode[codeh]==i)
			{
				++codeh;

				if(codeh==8)
				{
					sfx_play(SFX_CHN+2,SFX_KONG_LAUGH,128);
					game_hard_mode^=TRUE;
					codeh=0;
				}
			}
			else
			{
				codeh=0;
			}
		}

		if(cnt) --cnt;
	}

	music_stop();
	sfx_play(SFX_CHN+3,SFX_START,128);

	for(i=0;i<15;++i)
	{
		title_screen_press_start_str(i&1);
		delay(4);
		title_screen_update();
	}

	i=pad_poll(0);

	i=(i&PAD_A)&&(i&PAD_B)?1:0;

	fade_screen(0,1);

	return i;
}
