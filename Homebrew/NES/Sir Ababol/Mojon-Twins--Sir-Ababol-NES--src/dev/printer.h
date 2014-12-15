// Printer

void __fastcall__ cls (void) {
	vram_adr(0x2000);
	vram_fill(0,2048);
}

void draw_tile (unsigned char x, unsigned char y, unsigned char tl) {
	tl = (16 + tl) << 2;
	gp_addr = (y<<5) + x + 0x2000;
	vram_adr (gp_addr++);
	vram_put (tl++);
	vram_adr (gp_addr);
	vram_put (tl++);
	gp_addr+=31;
	vram_adr (gp_addr++);
	vram_put (tl++);
	vram_adr (gp_addr);
	vram_put (tl);
}

void __fastcall__ un_rle_screen (unsigned char *rle) {
	wx = 0; wy = 0; i = 0;
	while (i < 240) {
		t = (*rle);
		rle ++;
		if (t & 128) {
			top = t & 127;
			t = (*rle);
			rle ++;
			while (0 < top--) {
				draw_tile (wx, wy, t);
				wx = (wx + 2) & 31; if (!wx) wy += 2;
				i ++;
			}
		} else {
			draw_tile (wx, wy, t);
			wx = (wx + 2) & 31; if (!wx) wy +=2;
			i ++;
		}
	}
	// 64 attributes
	i = 64; gp_addr = 0x23c0;
	while (0 < i--) {
		vram_adr (gp_addr++);
		vram_put (*rle++);
	}
}

void text (unsigned char x, unsigned char y, unsigned char *s) {
	gp_addr = (y<<5) + x + 0x2000;
	while (t = *(s++)) {
		vram_adr (gp_addr++);
		vram_put (t);
	}	
}

void __fastcall__ pres (void) {
	ppu_on_all ();
	fade_in ();
	while (!(pad_poll (0) & PAD_START)) {};
	fade_out ();
	
	ppu_off ();
	cls ();
}

void __fastcall__ reset_screen (void) {
	oam_clear ();	
	scroll (0, 0);
}

void showtwolines (const unsigned char *l1, const unsigned char *l2) {
	reset_screen ();
	text (10, 13, (unsigned char *) l1);
	text (15, 15, (unsigned char *) l2);
	ppu_on_all ();
	fade_in ();
	delay (120);
	fade_out ();
	ppu_off ();
	cls ();
}

void __fastcall__ title (void) {
	reset_screen ();
	
	un_rle_screen ((unsigned char *) scr_rle_0);
	text (6, 16, (unsigned char *) txt_mojon_twins);
	text (7, 19, (unsigned char *) txt_press_start);
	oam_meta_spr (120, 191, 0, spr_ababol [0]);

	music_play (m_menu);
		
	pres ();
	
	music_stop ();
}

void __fastcall__ game_over (void) {
	reset_screen ();

	un_rle_screen ((unsigned char *) scr_rle_2);
	text (11, 11, (unsigned char *) txt_game_over);
	
	music_play (m_gameover);
	
	pres ();

	music_stop ();
}

void __fastcall__ ending (void) {
	reset_screen ();

	un_rle_screen ((unsigned char *) scr_rle_1);
	text (4, 3, (unsigned char *) txt_ending_1);
	text (5, 4, (unsigned char *) txt_ending_2);
	text (5, 5, (unsigned char *) txt_ending_3);
	text (4, 7, (unsigned char *) txt_ending_4);
	
	oam_meta_spr (96, 191, 0, spr_end_ababol);
	oam_meta_spr (144, 191, 36, spr_end_nanako);
	
	music_play (m_ending);
	
	ppu_on_all ();
	fade_in ();
	delay (120);delay (120);delay (120);delay (120);delay (120);
	fade_out ();
	ppu_off ();
	cls ();
	
	showtwolines (txt_credits_1, txt_credits_2);
	showtwolines (txt_credits_3, txt_credits_4);
	showtwolines (txt_credits_5, txt_credits_2);
	showtwolines (txt_credits_7, txt_credits_8);
	showtwolines (txt_credits_6, txt_credits_4);
	showtwolines (txt_credits_9, txt_credits_8);
	showtwolines (txt_credits_10, txt_credits_11);
	showtwolines (txt_credits_10, txt_credits_12);
	showtwolines (txt_credits_10, txt_credits_13);
	
	reset_screen ();
	text (1, 16, (unsigned char *) txt_credits_14);
	oam_meta_spr (102, 104, 0, spr_mt_logo);
	pres ();
	
	music_stop ();
}

void __fastcall__ credits (void) {
	reset_screen ();
	lower_end = 0; wy = 240;

	text (4, 23, (unsigned char *) txt_intro_1);
	text (5, 24, (unsigned char *) txt_intro_2);
	text (7, 26, (unsigned char *) txt_intro_3);
	text (4, 27, (unsigned char *) txt_intro_4);
	text (3, 28, (unsigned char *) txt_intro_5);
	
	ppu_on_all ();
	fade_in ();
	while (!(pad_poll (0) & PAD_START) && lower_end < 300) {
		oam_meta_spr (102, wy, 0, spr_mt_logo);
		if (wy > 112) wy --;
		ppu_waitnmi ();
		lower_end ++;
	};
	fade_out ();
	
	ppu_off ();
	cls ();
}
