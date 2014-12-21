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

/* show game over text over the gameplay */

void game_over(void)
{
	static unsigned int i,j,color;
	static int r,g,b;
	static unsigned char x,y;

	/* prepare sepia version of the current pallette */
	
	for(i=0;i<240;++i)
	{
		color=snes_palette[i];

		r=(color&R_MASK);
		g=(color&G_MASK)>>5;
		b=(color&B_MASK)>>10;

		if(i>=112&&i<128)
		{
			r=0;
			g=0;
			b=0;
		}
		else
		{
			if(g<4) g=4;
			g=(g*20)>>5;
			r=g;
			b=g>>1;
		}

		snes_palette_to[i]=r|(g<<5)|(b<<10);
	}

	for(i=240;i<256;++i)
	{
		snes_palette_to[i]=snes_palette[i];
		snes_palette[i]=0;
	}

	/* smoothly fade from current palette into the sepia one */
	
	for(i=0;i<32;++i)
	{
		palette_fade_to(0,48);
		palette_fade_to(96,224);

		nmi_wait();
		update_palette();
	}

	/* display text as sprites */
	
	x=62;
	y=104;

	for(i=0;i<250;++i)
	{
		palette_fade_to(240,256);

		oam_spr1(x+15*0,y,ITEMS_TILE+0x22|GAMEOVER_ATR,OAM_GAMEOVER+(0<<2));
		oam_spr1(x+15*1,y,ITEMS_TILE+0x24|GAMEOVER_ATR,OAM_GAMEOVER+(1<<2));
		oam_spr1(x+15*2,y,ITEMS_TILE+0x26|GAMEOVER_ATR,OAM_GAMEOVER+(2<<2));
		oam_spr1(x+15*3,y,ITEMS_TILE+0x28|GAMEOVER_ATR,OAM_GAMEOVER+(3<<2));
		oam_spr1(x+15*5,y,ITEMS_TILE+0x2a|GAMEOVER_ATR,OAM_GAMEOVER+(4<<2));
		oam_spr1(x+15*6,y,ITEMS_TILE+0x2c|GAMEOVER_ATR,OAM_GAMEOVER+(5<<2));
		oam_spr1(x+15*7,y,ITEMS_TILE+0x28|GAMEOVER_ATR,OAM_GAMEOVER+(6<<2));
		oam_spr1(x+15*8,y,ITEMS_TILE+0x2e|GAMEOVER_ATR,OAM_GAMEOVER+(7<<2));

		nmi_wait();
		update_palette();
	}
}

