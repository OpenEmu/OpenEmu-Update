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


//sound test code

void sound_test(void)
{
	static unsigned int i,j,num,screen_bright,off,bright;
	static unsigned int sound,pan,music,done;
	static int cur;

	set_bright(0);
	setup_hdma_gradient(-1);
	oam_clear();

	clear_nametables();
	
	unrle(map,mape);

	for(i=0;i<32*32;++i) nametable1[i]=map[i]+0x0140|BG_PAL(1)|BG_PRI;

	set_background(1);

	put_str(&nametable1[POS(11,8)],"SOUND TEST");

	put_str(&nametable1[POS(11,10)],"SOUND");
	put_str(&nametable1[POS(11,11)],"PAN");
	put_str(&nametable1[POS(11,12)],"MUSIC");
	put_str(&nametable1[POS(11,13)],"VOLUME");
	put_str(&nametable1[POS(11,14)],"EXIT");

	put_str(&nametable1[POS(11,17)],versionStr);
	put_str(&nametable1[POS(17,17)],snes_ntsc?"NTSC":" PAL");

	update_nametables();
	setup_palettes();
	update_palette();

	setup_hdma_gradient(5);

	global_volume=120;
	
	spc_volume(global_volume);

	sound=0;
	pan=0x80;
	music=0;

	bright=0;
	cur=0;
	done=0;

	while(!done)
	{
		put_num(&nametable1[POS(19,10)],sound,2);
		put_num(&nametable1[POS(18,11)],pan  ,3);
		put_num(&nametable1[POS(19,12)],music,2);
		put_num(&nametable1[POS(18,13)],global_volume,3);

		off=POS(9,10);

		for(i=0;i<5;++i)
		{
			nametable1[off]=(i==cur?TEXT_ATR|'@'-32:TEXT_ATR);
			off+=0x20;
		}

		nmi_wait();

		copy_to_vram(POS(0,10),(const unsigned char*)&nametable1[POS(0,10)],512);

		if(bright<15)
		{
			++bright;
			set_bright(bright);
		}

		pad_read_ports();

		i=pad_poll_trigger(0);

		if(i&PAD_UP)
		{
			--cur;
			if(cur<0) cur=4;
		}

		if(i&PAD_DOWN)
		{
			++cur;
			if(cur>4) cur=0;
		}

		if(i&PAD_LEFT)
		{
			switch(cur)
			{
			case 0:
				{
					--sound;
					if(sound>=SOUNDS_ALL) sound=SOUNDS_ALL-1;
				}
				break;

			case 1:
				{
					pan-=0x10;
					if(pan>0xff) pan=0;
				}
				break;

			case 2:
				{
					--music;
					if(music>=MUSIC_ALL) music=MUSIC_ALL-1;
				}
				break;

			case 3:
				{
					global_volume-=0x08;
					if(global_volume>0x7f) global_volume=0;
					spc_volume(global_volume);
				}
				break;
			}
		}

		if(i&PAD_RIGHT)
		{
			switch(cur)
			{
			case 0:
				{
					++sound;
					if(sound>=SOUNDS_ALL) sound=0;
				}
				break;

			case 1:
				{
					pan+=0x10;
					if(pan>0xf0) pan=0xf0;
				}
				break;

			case 2:
				{
					++music;
					if(music>=MUSIC_ALL) music=0;
				}
				break;

			case 3:
				{
					global_volume+=0x08;
					if(global_volume>0x78) global_volume=0x78;
					spc_volume(global_volume);
				}
				break;
			}
		}

		if(i&PAD_A)
		{
			switch(cur)
			{
			case 0:
			case 1:
				sfx_play(7,sound,pan);
				break;

			case 2:
				music_play(music);
				break;

			case 4:
				done=1;
				break;
			}
		}

		if(i&PAD_B)
		{
			music_stop();

			if(cur==4) done=1;
		}

		++game_frame_cnt;
	}

	fade_screen(0,1);
}
