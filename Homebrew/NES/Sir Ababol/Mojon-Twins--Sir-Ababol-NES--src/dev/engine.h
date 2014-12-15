// Engine
// Copyleft 2013 the Mojon Twins
// Uses neslib and MT Chunk Scroller

#define SPROFFSET 31

// Remove this
/*
void debug_n (unsigned char y) {
	oam_spr (16, 16, 40 + (y / 100), 1, 180);
	oam_spr (24, 16, 40 + ((y % 100) / 10), 0, 184);
	oam_spr (32, 16, 40 + (y % 10), 0, 188);
}
*/

// creates hud (no numbers)
void __fastcall__ hud_create (void) {
	oam_spr (16, 16, 50, 1, 180);
	oam_spr (24, 16, 201, 0, 184);
	
	oam_spr (16, 199, 51, 1, 192);
	oam_spr (24, 199, 201, 0, 196);
	
	oam_spr (56, 199, 52, 0, 208);
	oam_spr (64, 199, 201, 0, 212);	
}

// lives
void __fastcall__ hud_lives (void) {
	oam_spr (32, 16, 40 + pl_lives, 0, 188);
}

// ababoles
void __fastcall__ hud_objects (void) {
	oam_spr	(32, 199, 40 + (pl_objects / 10), 0, 200);
	oam_spr (40, 199, 40 + (pl_objects % 10), 0, 204);
}

// keys
void __fastcall__ hud_keys (void) {
	oam_spr (72, 199, 40 + pl_keys, 0, 216);
}

// Copy enemies from ROM to RAM.
// level number (0..2) is on stripe_n
void __fastcall__ load_enemies (void) {
	gen_pointer1 = (void *) (432 * stripe_n + enemies_ROM);
	for (t = 0; t < 48; t ++) {
		enems_x1 [t] = ((unsigned int)(gen_pointer1 [0] << 8) + (unsigned char)(gen_pointer1 [1]));
		enems_x [t] = enems_x1 [t];
		enems_y1 [t] = (unsigned char)(gen_pointer1 [2]);
		enems_y [t] = enems_y1 [t];
		enems_x2 [t] = ((unsigned int)(gen_pointer1 [3] << 8) + (unsigned char)(gen_pointer1 [4]));
		enems_y2 [t] = (unsigned char)(gen_pointer1 [5]);
		enems_mx [t] = ((signed char)(gen_pointer1 [6])) - 8;
		enems_my [t] = ((signed char)(gen_pointer1 [7])) - 8;
		enems_spr [t] = 0xff;
		enems_type [t] = (unsigned char)(gen_pointer1 [8]);
		gen_pointer1 += 9;
	}
}

// Init enemy sprite assignations
void __fastcall__ init_sprite_assign (void) {
	for (i = 0; i < 8; i ++) {
		sprite_assign [i] = 0xff;
	}	
}

// Puts a new enemy number t to screen.
void __fastcall__ activate_enemy (void) {
	if (enems_spr [t] == 0xff && enems_type [t]) {
		for (i1 = 0; i1 < 6; i1 ++) {
			if (sprite_assign [i1] == 0xff) {
				sprite_assign [i1] = t;
				enems_spr [t] = i1;
				break;
			}
		}
	}
}

// Takes enemy number t from screen
void __fastcall__ deactivate_enemy (void) {
	i2 = enems_spr [t];
	sprite_assign [i2] = 0xff;
	enems_spr [t] = 0xff;
}

// Checks which enemies should be on screen
void __fastcall__ assign_enemies (void) {
	// First, take out those who are not visible:
	for (i = 0; i < 6; i ++) {
		t = sprite_assign [i];
		if (t != 0xff) {
			if (enems_x [t] < cam_pos || enems_x [t] > cam_pos + 240) {
				deactivate_enemy ();
			}
		}
	}
	
	// Second, activate those who may be visible:
	// screen = cam_pos / 256.
	// Enemies which could appear on screen would be those 6 from
	// enemy # i * 3
	i = MSB(cam_pos);
	precalc1 = i + i + i;
	precalc2 = precalc1 + 6;
	for (t = precalc1; t < precalc2; t ++) {
		if (enems_x [t] >= cam_pos && enems_x [t] <= cam_pos + 240) {
			activate_enemy ();
		}
	}
	
	// Move visible sprites
	for (i = 0; i < 6; i ++)  {
		t = sprite_assign [i];
		if (t != 0xff) {
			// Write OAM for sprite 24*i.
			// Move sprite to screen
			if (enems_type [t] == 5) {
				j = 9;
			} else {
				j = ((enems_type [t] - 1) << 1) + ((frame_counter >> 3) & 1);					
			}
			oam_meta_spr (enems_x [t] - cam_pos, SPROFFSET + enems_y [t], 36 + (i << 4) + (i << 3), spr_enems [j]);
		} else {
			oam_meta_spr (0, 0xef, 36 + (i << 4) + (i << 3), spr_enems [8]);
		}
	}
}

void __fastcall__ init_player (void) {
	pl_x = (PLAYER_INI_X << 4) << FIXBITS;
	pl_y = (PLAYER_INI_Y << 4) << FIXBITS;
	pl_olx = pl_x;
	pl_oly = pl_y;
	pl_vx = pl_vy = 0;
	pl_jmp = pl_ct_jmp = pl_gotten = 0;
	pl_lives = PLAYER_LIFE;
	pl_objects = pl_keys = 0;
	pl_spr_id = 0;
	pl_facing = 0;
	pl_jmp_key_pressed = 0;
	wx = pl_x >> FIXBITS;
	wy = pl_y >> FIXBITS;
	oam_meta_spr (wx - cam_pos, SPROFFSET + wy, 0, spr_ababol [pl_spr_id]);
}

// Functions to change current strip
void __fastcall__ change_strip (void) {
	map_plus_offset = (unsigned char *)(map) + stripe_offset;
	load_enemies ();
	init_sprite_assign ();
	assign_enemies ();
}

void change_to (int offset) {
	ppu_mask (stripe_n != 0 ? 0x8e : 0x0e);
	
	stripe_offset = offset;
	objs_offset = offset / 200;
	stripe_n = objs_offset / 16;
	change_strip ();

	map_chunk_offset = cam_pos >> 5;
	ppu_mask (stripe_n != 0 ? 0x8e : 0x0e);
	draw_map ();
	oam_meta_spr (wx - cam_pos, 240, 0, spr_ababol [pl_spr_id]);
	
	ppu_mask (stripe_n != 0 ? 0x9e : 0x1e);	
	
	// Forces the engine to update bolts/objects coordinates
	old_s = 99;		
}

// Kills player in several ways
void __fastcall__ collided_enemy (void) {
	music_stop ();
	sfx_play (4, 0);
	delay (25);
}

void __fastcall__ sink (void) {
	music_stop ();	
	while (wy < ((yy + 1) << 4)) {
		++ wy;
		oam_meta_spr (wx - cam_pos, SPROFFSET + wy, 0, spr_ababol [pl_facing + 5]);
		ppu_waitnmi ();
		if (wy & 1) sfx_play (5, 0);
	}
	sfx_play (4, 0);
	delay (25);
}

void __fastcall__ die (void) {
	pl_lives --;
	pl_flicker = 1;
	pl_ctr = 128;
	
	music_play (m_die);
	
	// Death sequence
	i1 = wy + SPROFFSET;
	for (i2 = i1; i2 > 0; i2 --) {
		oam_meta_spr (wx - cam_pos, i2, 0, spr_dead);
		ppu_waitnmi ();
	}
	
	// Show lives again
	if (pl_lives >= 0) hud_lives ();

	// Reposition
	if (pl_lives >= 0) {
		ppu_off ();
		set_vram_update (0, 0);
		cls ();
		oam_meta_spr (wx - cam_pos, 240, 0, spr_ababol [pl_spr_id]);
		pl_x = pl_olx;
		pl_y = pl_oly;
		pl_vx = 0; pl_vy = 0; pl_jmp = 0;
		wx = pl_x >> FIXBITS;
		cam_pos = wx - 120;
		if (cam_pos < 0) cam_pos = 0;
		if (cam_pos > 3840) cam_pos = 3840;
		scroll (cam_pos & 0x01ff, 0);
		set_vram_update (25, update_list);
		clear_update_list ();
		ppu_on_all ();
		change_to (old_stripe_offset);
	}	
	
	music_stop ();
	music_play (m_ingame);
}

void __fastcall__ move_enemies (void) {
	i = MSB(cam_pos);
	precalc1 = i + i + i;
	precalc2 = precalc1 <= 42 ? precalc1 + 6 : 48;
	pl_gotten = 0;
	make_me_die = 0;
	for (t = precalc1; t < precalc2; t ++) {
		if (enems_type [t]) {
			if (enems_type [t] < 5) {
				// Update position
				enems_x [t] += enems_mx [t];
				ex = enems_x [t];
				if (ex == enems_x1 [t] ||
					ex == enems_x2 [t])
					enems_mx [t] = -enems_mx [t];
				enems_y [t] += enems_my [t];
				ey = enems_y [t];
				if (ey == enems_y1 [t] ||
					ey == enems_y2 [t])
					enems_my [t] = -enems_my [t];
				
				// Manage collision
				if (enems_type [t] == 4) {
					// "enemy" is a platform:
					if (wx >= ex - 15 && wx <= ex + 15) {
						// Vertical
						if (enems_my [t] < 0) {
							if (wy >= ey - 16 && wy <= ey - 11 && pl_vy >= 0) {
								wy = ey - 16;
								pl_y = wy << FIXBITS;
								pl_gotten = 1;
								pl_vy = 0;
							}
						} else if (enems_my [t] > 0) {
							if (wy >= ey - 20 && wy <= ey - 11 && pl_vy > -PLAYER_VY_INICIAL_SALTO) {
								wy = ey - 16;
								pl_y = wy << FIXBITS;
								pl_gotten = 1;
								pl_vy = 0;
							}
						} else {
							// Horizontal	
							if (wy >= ey - 16 && wy <= ey - 11 && pl_vy >= 0) {
								wx = wx + enems_mx [t];
								pl_x = wx << FIXBITS;
								wy = ey - 16;
								pl_y = wy << FIXBITS;					
								pl_gotten = 1;
								pl_vy = 0;
							}
						}
					}
				} else {
					// "enemy" is a monster.
					// depending on the collision, we kill the monster or the player
					if (wx >= ex - 12 && wx <= ex + 12) {
						if (wy >= ey - 16 && wy <= ey - 10 && pl_vy > 0) {
							enems_type [t] = 5;
							enems_mx [t] = 16;
							pl_vy = -PLAYER_MAX_VY_SALTANDO;
							sfx_play (6, 2);
						} else if (wy >= ey - 14 && wy <= ey + 12) {
							if (!pl_flicker) {
								make_me_die = 1;
							}
						}				
					}
				}
			} else {
				// "Dying" monster. During 16 frames, show the "explosion"
				enems_mx [t] --;
				if (enems_mx [t] == 0) {
					enems_type [t] = 0;
					sprite_assign [enems_spr [t]] = 0xff;
					enems_spr [t] = 0xff;
				}
			}
		}
	}
	if (make_me_die) {
		collided_enemy ();
		die ();
	}
}

unsigned char __fastcall__ attr (unsigned char x, unsigned char y) {
	// This function gets called a lot, but I can't think on a way to 
	// make this run faster :-/
	
	if (y > 10) y = 0;		// Don't ask ... :~)
	if (y > 9) return 0;
	
	// Calculate address in map data.
	precalc1 = (x >> 1);
	work_idx = (unsigned char *) (map_plus_offset + (precalc1 << 4) + (precalc1 << 3) + precalc1);
	work_idx += (x & 1) + (y << 1);
	
	// Get metatile
	t = (*work_idx);
	
	// Return metatile behaviour
	return behaviours [t];
}

void __fastcall__ move_player (void) {
	i = pad_poll (0);
		
	// Vertical axis. update "Y"
	pl_vy = pl_vy + PLAYER_G;
	if (pl_vy > PLAYER_MAX_VY_CAYENDO) pl_vy = PLAYER_MAX_VY_CAYENDO;
	pl_y = pl_y + pl_vy;
	if (pl_y < -128) pl_y = -128;
		
	// Collide with map?
	wx = pl_x >> FIXBITS;	// pixel
	xx = wx >> 4;			// tile
	wy = pl_y >> FIXBITS; 
	yy = wy >> 4;
	
	pl_possee = 0;
	if (pl_vy > 0 && (wy & 15) < 8) {
		if (attr (xx, yy + 1) > 3 ||
			((wx & 15) != 0 && attr (xx + 1, yy + 1) > 3)) {
			pl_vy = 0;
			wy = yy << 4;
			pl_y = wy << FIXBITS;
			pl_possee = 1;
		} else if (attr (xx, yy + 1) == 1 ||
			((wx & 15) != 0 && attr (xx + 1, yy + 1) == 1)) {
			if (pl_flicker) {
				pl_vy = -PLAYER_MAX_VY_SALTANDO;
				sfx_play (6, 2);
			} else {
				wy = yy << 4;
				sink ();
				die (); return;
			}
		}
	} else {
		if (attr (xx, yy) > 7 ||
			((wx & 15) != 0 && attr (xx + 1, yy) > 7)) {
			pl_vy = 0;
			wy = (yy + 1) << 4;
			pl_y = wy << FIXBITS;
		}
	}
	
	// Jump?
	if (i & PAD_A || i & PAD_B) {
		if (!pl_jmp) {
			if ((pl_possee || pl_gotten) && !pl_jmp_key_pressed) {
				pl_jmp = 1;
				pl_ct_jmp = 0;
				pl_x = wx << FIXBITS;
				pl_vy = -PLAYER_VY_INICIAL_SALTO;
				if (!pl_gotten) {
					pl_olx = pl_x;
					pl_oly = pl_y;
					old_stripe_offset = stripe_offset;
				}
				sfx_play (7, 0);
			}
		} else {
			pl_vy -= (PLAYER_INCR_SALTO - (pl_ct_jmp >> 1));
			if (pl_vy < -PLAYER_MAX_VY_SALTANDO) pl_vy = -PLAYER_MAX_VY_SALTANDO;
			pl_ct_jmp ++;
			if (pl_ct_jmp == 8) { pl_jmp = 0; pl_jmp_key_pressed = 1; }
		}
	} else {
		pl_jmp = 0;
		pl_jmp_key_pressed = 0;
	}
	
	// Horizontal axis. Update "X"
	if (! (i & PAD_LEFT || i & PAD_RIGHT)) {
		if (pl_vx > 0) {
			pl_vx -= PLAYER_RX;
			if (pl_vx < 0) pl_vx = 0;
		} else if (pl_vx < 0) {
			pl_vx += PLAYER_RX;
			if (pl_vx > 0) pl_vx = 0;
		}
	} 
	
	if (i & PAD_LEFT) {
		pl_facing = 6;
		pl_vx -= PLAYER_AX;
		if (pl_vx < -PLAYER_MAX_VX) pl_vx = -PLAYER_MAX_VX;
	}
	if (i & PAD_RIGHT) {
		pl_facing = 0;
		pl_vx += PLAYER_AX;
		if (pl_vx > PLAYER_MAX_VX) pl_vx = PLAYER_MAX_VX;
	}
	
	// Collide with map?
	pl_x = pl_x + pl_vx;
	wx = pl_x >> FIXBITS;	
	xx = wx >> 4;			
	wy = pl_y >> FIXBITS;
	yy = wy >> 4;
	
	if (pl_vx > 0) {
		if (attr (xx + 1, yy) > 7 || 
			((wy & 15) != 0 && attr (xx + 1, yy + 1) > 7)) {
			pl_vx = 0;
			wx = xx << 4;
			pl_x = wx << FIXBITS;
		}
	}
	if (pl_vx < 0) {
		if (attr (xx, yy) > 7 || 
			((wy & 15) != 0 && attr (xx, yy + 1) > 7)) {
			pl_vx = 0;
			wx = (xx + 1) << 4;
			pl_x = wx << FIXBITS;
		}
	}
	
	// Calculate sprite ID
	if (!pl_possee && !pl_gotten) {
		pl_spr_id = pl_facing + 5;
	} else {
		if (pl_vx == 0) {
			pl_spr_id = pl_facing;
		} else {
			pl_spr_id = pl_facing + 1 + ((wx >> 4) & 3);
		}
	}
	
	// Move and update player meta-sprite.
	if (half_life || !pl_flicker) {
		oam_meta_spr (wx - cam_pos, SPROFFSET + wy, 0, spr_ababol [pl_spr_id]);
	} else {
		oam_meta_spr (wx - cam_pos, SPROFFSET + wy, 0, spr_aba_empty);
	}
	
	// Pause?
	if (i & PAD_START) {
		while (pad_poll (0) & PAD_START);
		music_pause (1);
		sfx_play (0, 1);		
		pal_bright (3);
		ppu_waitnmi ();
		while (!(pad_poll (0) & PAD_START));
		pal_bright (4);
		music_pause (0);
		while (pad_poll (0) & PAD_START);
	}
}
