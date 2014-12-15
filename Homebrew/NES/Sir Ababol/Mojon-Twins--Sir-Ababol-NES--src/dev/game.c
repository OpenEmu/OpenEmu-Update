// ** Sir Ababol **
// Copyleft Mojon Twins 2013

// Uses neslib and related tools by Shiru
// Code & music by na_th_an, GFX & design by Anjuel
// Extra optimizations by Shiru

// Extremely ugly, over-optimized, low-level code ahead.
// You've been warned.

#define MSB(x)		(((x)>>8))
#define LSB(x)		(((x)&0xff))
#define FIXBITS		4

#include "neslib.h"

// Game configuration
#include "config.h"

// Game map data
#include "map.h"

// Custom RLEd screens (16x16 tile format, MT propietary)
#include "screens.h"

// Palettes
const unsigned char mypal_game_bg[16] = { 0x0f,0x2d,0x10,0x30,0x0f,0x06,0x16,0x27,0x0f,0x01,0x11,0x31,0x0f,0x07,0x19,0x29 };

// Update list for 25 tiles (20 chars + 5 attributes)
unsigned char update_list [75];	

// Enemies in RAM (current "floor")
// Room for 48 enemies (16 "screens", 3 enemies per "screen")
unsigned int enems_x1 [48];
unsigned char enems_y1 [48];
unsigned int enems_x2 [48];
unsigned char enems_y2 [48];
signed char enems_mx [48];
signed char enems_my [48];
unsigned char enems_spr [48];
unsigned char enems_type [48];

// Coordinates
unsigned int enems_x [48];
unsigned char enems_y [48];

// Music
extern const unsigned char m_ingame [];
extern const unsigned char m_menu [];
extern const unsigned char m_die [];
extern const unsigned char m_gameover [];
extern const unsigned char m_ending [];

// Enemies in ROM (full game)
#include "enems.h"

// Metasprites
// Enemies
#include "metasprites-enemies.h"

// Sir ABabol
#include "metasprites-ababol.h"

// Extra (dead, empty, ending) sprites
#include "metasprites-extra.h"

// Bolts
#include "bolts.h"
unsigned char bolts_act [48];

// Objects
#include "objs.h"
unsigned char objs_act [48];

// Sprites active on screen
unsigned char sprite_assign [8];

// Tile behaviours
const unsigned char behaviours [] = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 4, 8, 8, 0, 0, 0, 0, 0, 0, 0, 4, 8, 1, 8, 8,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 
};

// textos
#include "texts.h"

// Push to zero page:
#pragma bssseg (push,"ZEROPAGE")
#pragma dataseg(push,"ZEROPAGE")

// General VRAM pointers
unsigned int work_addr;
unsigned int gp_addr;
unsigned int blt_addr;
const unsigned char *work_idx;
unsigned char *update_work;		// Used to fill the update list.
unsigned char *blt_update;
unsigned char blt_flag;

// Chunk control
unsigned int chunk_addr;		// Where to draw chunk #chunk_idx
unsigned int chunk_attr_addr;	// Where to draw chunk #chunk_idx's attributes
unsigned int chunk_idx;			// Chunk # to draw.
unsigned char t;				// Current tile #.
unsigned int stripe_offset;
unsigned int old_stripe_offset;
unsigned int objs_offset;	
unsigned char stripe_n;
unsigned char *map_plus_offset;	// Precalc map + offset
unsigned char updflipflop = 0;	// Each frame only 1/4 of the tiles are updated.

// Camera control
signed int cam_pos;			// Current camera pos
signed int cam_old_pos;		// Previous camera pos
unsigned char map_chunk_offset;	// Map chunk offset (to redraw full screen)

// General purpose precalc vars.
unsigned char precalc1;
unsigned char precalc2;

// General purpose pointers
unsigned char *gen_pointer1;
unsigned char *gen_pointer2;

// General purpose looper
unsigned char i, j, i1, i2, top;
signed char fader;

// Frame counters
unsigned char half_life;
unsigned char frame_counter;

// Player
unsigned char pl_flicker, pl_ctr;
unsigned int pl_x;
signed int pl_y;
unsigned int pl_olx;
signed int pl_oly;
signed char pl_vx;
signed char pl_vy;
unsigned char pl_jmp, pl_ct_jmp, pl_gotten;
unsigned char pl_spr_id, pl_possee;
signed char pl_lives, pl_objects, pl_keys;
unsigned int wx;
unsigned char wy;	//
unsigned char xx;
unsigned char yy;
unsigned int ex;
unsigned char ey;
unsigned char pl_facing;
signed int lower_end;
unsigned char cur_s, old_s;
unsigned char win, make_me_die;
unsigned char pl_jmp_key_pressed;

// Optimization: those variables store the location 
// of the object and bolt in the current virtual screen.
unsigned int bex, oex;
unsigned char bey, oey, bidx, oidx, ot;

// **************
// Main functions
// **************

// fade out
void __fastcall__ fade_out (void) {
	for (fader = 4; fader > -1; fader --) {
		pal_bright (fader);
		delay (4);
	}	
}

// fade in
void __fastcall__ fade_in (void) {
	for (fader = 0; fader < 5; fader ++) {
		pal_bright (fader);
		delay (4);
	}	
}

// Clear update list
void __fastcall__ clear_update_list (void) {
	for (i = 0; i < 75; i ++)
		update_list [i] = 0;	
}

// onscreen printing
#include "printer.h"

// scrolling functions
#include "scroller.h"

// engine
#include "engine.h"

// Work

void main(void) {
	pal_bright (0);
	
	bank_spr (1);
	bank_bg (0);
	
	pal_bg (mypal_game_bg);
	pal_spr (mypal_game_bg);

	credits ();

	lower_end = 152 << FIXBITS;
	
	while (1) {
		title ();
	
		for (i = 0; i < 32; i ++) {
			if (bolts [i + i] != 0)
				bolts_act [i] = 0;
			else 
				bolts_act [i] = 1;
			if (objs [i + i + i + 2] != 0) 
				objs_act [i] = 0;
			else
				objs_act [i] = 1;
		}
			
		oam_clear ();
		stripe_offset = objs_offset = 0;
		map_plus_offset = (unsigned char *)(map) + stripe_offset;
		cam_old_pos = cam_pos = 0;
		map_chunk_offset = 0;
		stripe_n = 0;
				
		// Prepare enemies
		load_enemies ();
		init_sprite_assign ();
		assign_enemies ();
				
		init_player ();
		
		// hud
		hud_create ();
		hud_lives ();
		hud_objects ();
		hud_keys ();
		
		set_vram_update (25, update_list);
		ppu_on_bg ();
		pal_bright (4);
		draw_map ();
		ppu_mask (0x1e);
		
		frame_counter = 0;
		pl_flicker = 0;
		win = 0;
		old_s = 99;
		
		music_play (m_ingame);
		while (1) {
			half_life = 1 - half_life;
			frame_counter ++;
			if (pl_flicker) { pl_ctr --; if (pl_ctr == 0) pl_flicker = 0; }
			
			// Current screen calculations
			cur_s = MSB(wx);
			if (cur_s != old_s) {
				// When virtual "screen" changes, we 
				// precalculate the location of objects and bolts
				// used for interactions with the player.
				old_s = cur_s;
				bidx = objs_offset + cur_s;
				precalc1 = bidx + bidx;
				bex = bolts [precalc1] << 4;
				bey = bolts [precalc1 + 1] << 4;
				precalc1 = precalc1 + bidx;
				oex = objs [precalc1] << 4;
				oey = objs [precalc1 + 1] << 4;
				ot = objs [precalc1 + 2];
			}
			
			// Move enemies
			move_enemies ();
			
			// Move player
			move_player ();
					
			// Collide bolt <-> sir ababol
			if (!bolts_act [bidx]) {				
				if (wx >= bex - 15 && wx <= bex + 15) {
					if (wy >= bey - 15 && wy <= bey + 15) {
						if (pl_keys == 0) {
							if (pl_vx > 0) {
								pl_x = (xx << 4) << FIXBITS;
								pl_vx = -PLAYER_MAX_VX; 
							} else {
								pl_x = ((xx + 1) << 4) << FIXBITS;
								pl_vx = PLAYER_MAX_VX;
							}
						} else {
							pl_keys --;
							bolts_act [bidx] = 1;
							chunk_idx = bex >> 5;
							sfx_play (1, 1);
							redraw_chunk ();
							hud_keys ();
						}
					}	
				}
			}
			
			// Collide object <-> sir ababol
			if (!objs_act [bidx]) {				
				if (wx >= oex - 15 && wx <= oex + 15) {
					if (wy >= oey - 15 && wy <= oey + 15) {
						switch (ot) {
							case 1: if (pl_lives < 9) { pl_lives ++; hud_lives (); } sfx_play (2, 1); break;
							case 2: pl_objects ++; hud_objects (); sfx_play (3, 1); break;
							case 3: pl_keys ++; hud_keys (); sfx_play (0, 1); break;
						}
						objs_act [bidx] = 1;
						// Redraw chunk
						chunk_idx = oex >> 5;
						redraw_chunk ();
					}	
				}
			}
			
			// Sprite management
			assign_enemies ();
				
			// Move cam:
			cam_pos = wx - 120;
			if (cam_pos < 0) cam_pos = 0;
			if (cam_pos > 3840) cam_pos = 3840;
			
			// Change strip?
			if (pl_y >= lower_end) {
				if (stripe_offset != 6400) {
					change_to (stripe_offset + 3200);
					pl_y = 0;			
				} 
			} 
			
			if (pl_y < 0) {
				if (stripe_offset > 0) {
					change_to (stripe_offset - 3200);
					pl_y = 144 << FIXBITS;
					pl_vy = -PLAYER_MAX_VY_SALTANDO;
				}
			}
			
			// Do scroll
			scroll_to ();

			// Sync
			ppu_waitnmi ();
			
			// game over
			if (pl_lives < 0) { win = 0; break; }
			
			// fin
			if (pl_objects == PLAYER_NUM_OBJETOS) { win = 1; break; }
		}	
		music_stop ();
		
		fade_out ();
		ppu_off();
		set_vram_update (0, 0);	
		
		if (!win) game_over (); else ending ();
	}
}
