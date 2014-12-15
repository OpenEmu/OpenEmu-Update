// NES Scroller
// Copyleft 2013 The Mojon Twins

// Code by na_th_an
// Uses Shiru's neslib

/*
 Map is divided in Chunks. Chunks are 25 bytes long.
 First 20 bytes contain 20 16x16 metatile indexes:

	00 01
	02 03
	04 05
	06 07
	08 09
	10 11
	12 13
	14 15
	16 17
	18 19

 Next 5 bytes contain 5 attributes.

 	{03 02 01 00}, {07 06 05 04}, {11 10 09 08}, {15 14 13 12}, {19 18 17 16}

 Each 16x16 metatile is composed by 2x2 tiles:

 	(t << 4)      (t << 4 + 1)
 	(t << 4 + 2)  (t << 4 + 3)

 Each frame 1/4 of the tiles and all the attributes (total, 25 VRAM writes)
 are sent thru an update list to neslib's NMI handler.

*/

void __fastcall__  paint_chunk (void) {
	// This function paints map chunk #chunk_idx
	// Starting at VRAM address #chunk_addr (attrs @ #chunk_attr_addr)

	// Each time it's called, it draws the left or rightmost end of the chunk
	// This is done because 85 tiles seem to much to be updated in every frame

	// map_plus_offset is map + stripe_offset.
	// stripe_offset is length of each stripe in bytes.

	work_addr = chunk_addr;
	work_idx = map_plus_offset + (chunk_idx << 4) + (chunk_idx << 3) + chunk_idx;

	// Write tiles

	update_work = update_list;
	blt_flag = 0;
	updflipflop = (updflipflop + 1) & 3;

	// How to display special tiles (gates, keys, objects, refills):
	// Only one of those items can exist per chunk. There's a "0" in
	// the map data where one of those items is. If a "0" is detected
	// while drawing the current chunk, a flag is raised and the address
	// is remembered.
	/*
	switch (updflipflop) {
		case 0:
			// Tile 0
			for (i = 0; i < 5; ++i) {
				gp_addr = work_addr;
				t = *work_idx << 2;
				if (t) {
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					gp_addr += 31; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
				} else {
					blt_flag = 1;
					blt_addr = gp_addr;
					blt_update = update_work;
					update_work += 12;
				}
				work_idx += 4;
				work_addr += 128;
			}
			break;
		case 1:
			// Tile 2
			work_idx+=2;//to avoid adding 2 constantly
			for (i = 0; i < 5; ++i) {
				gp_addr = work_addr + 64;
				t = *work_idx << 2;
				if (t) {
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					gp_addr += 31; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
				} else {
					blt_flag = 1;
					blt_addr = gp_addr;
					blt_update = update_work;
					update_work += 12;
				}
				work_idx += 4;
				work_addr += 128;
			}
			work_idx-=2;//revert to as it was
			break;
		case 2:
			// Tile 1
			work_idx+=1;//to avoid adding 1 contantly
			for (i = 0; i < 5; ++i) {
				gp_addr = work_addr + 2;
				t = *work_idx << 2;
				if (t) {
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					gp_addr += 31; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
				} else {
					blt_flag = 1;
					blt_addr = gp_addr;
					blt_update = update_work;
					update_work += 12;
				}
				work_idx += 4;
				work_addr += 128;
			}
			work_idx-=1;//revert to as it was
			break;
		case 3:
			// Tile 4
			work_idx+=3;//to avoid adding 3 constantly
			for (i = 0; i < 5; ++i) {
				gp_addr = work_addr + 66;
				t = *work_idx << 2;
				if (t) {
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					gp_addr += 31; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
					++gp_addr; ++t;
					*(update_work++)=MSB(gp_addr);
					*(update_work++)=LSB(gp_addr);
					*(update_work++)=t;
				} else {
					blt_flag = 1;
					blt_addr = gp_addr;
					blt_update = update_work;
					update_work += 12;
				}
				work_idx += 4;
				work_addr += 128;
			}
			work_idx-=3;//revert to as it was
			break;
	}
	*/

	switch(updflipflop)//pre-add work_idx, pre calculate gp_addr
	{
	case 0: gp_addr=work_addr;                 break;
	case 1: gp_addr=work_addr+64; work_idx+=2; break;
	case 2: gp_addr=work_addr+2;  work_idx+=1; break;
	case 3: gp_addr=work_addr+66; work_idx+=3; break;
	}

	for (i = 0; i < 5; ++i) {
		t = *work_idx << 2;
		if (t) {
			*(update_work++)=MSB(gp_addr);
			*(update_work++)=LSB(gp_addr);
			*(update_work++)=t;
			++gp_addr; ++t;
			*(update_work++)=MSB(gp_addr);
			*(update_work++)=LSB(gp_addr);
			*(update_work++)=t;
			gp_addr += 31; ++t;
			*(update_work++)=MSB(gp_addr);
			*(update_work++)=LSB(gp_addr);
			*(update_work++)=t;
			++gp_addr; ++t;
			*(update_work++)=MSB(gp_addr);
			*(update_work++)=LSB(gp_addr);
			*(update_work++)=t;
			gp_addr+=(128-33);
		} else {
			blt_flag = 1;
			blt_addr = gp_addr;
			blt_update = update_work;
			update_work += 12;
			gp_addr+=128;
		}
		work_idx += 4;
		work_addr += 128;
	}

	switch(updflipflop)//revert work_idx to normal value
	{
	case 1: work_idx-=2; break;
	case 2: work_idx-=1; break;
	case 3: work_idx-=3; break;
	}

	gp_addr = chunk_attr_addr;

	// Now we update teh attributes

	for (i = 0; i < 5; ++i) {
		t = *work_idx++;
		*(update_work++)=MSB(gp_addr);
		*(update_work++)=LSB(gp_addr);
		*(update_work++)=t;
		gp_addr += 8;
	}

	// If blt_flag was risen while drawing the chunk, that means that
	// a metatile=0 was found in the chunk. Now we have to  calculate
	// which metatile to draw. There's one object (ababol/refill/key)
	// and one gate per screen. The arrays objs_act and bolts_act are
	// flags letting us know wether they are active or not.

	if (blt_flag) {
		i = chunk_idx >> 3;
		i2 = i + objs_offset;
		precalc1 = (i2 << 1);
		precalc2 = i2 + precalc1;
		if (bolts [precalc1] >> 1 == chunk_idx) {
			if (bolts_act [i2]) {
				t = 64;
			} else {
				t = 124;
			}
		}
		if (objs [precalc2] >> 1 == chunk_idx) {
			if (objs_act [i2]) {
				t = 64;
			} else {
				t = 240 + (objs [precalc2 + 2] << 2);
			}
		}
		*(blt_update++)=MSB(blt_addr);
		*(blt_update++)=LSB(blt_addr);
		*(blt_update++)=t;
		++t;
		++blt_addr;
		*(blt_update++)=MSB(blt_addr);
		*(blt_update++)=LSB(blt_addr);
		*(blt_update++)=t;
		++t;
		blt_addr += 31;
		*(blt_update++)=MSB(blt_addr);
		*(blt_update++)=LSB(blt_addr);
		*(blt_update++)=t;
		++t;
		++blt_addr;
		*(blt_update++)=MSB(blt_addr);
		*(blt_update++)=LSB(blt_addr);
		*(blt_update++)=t;
	}
}

void __fastcall__ redraw_chunk (void) {
	// Calculate nametable address
	precalc2 = (chunk_idx << 2) & 63;
	if (precalc2 < 32) {
		chunk_addr = 0x2080 + precalc2;
		chunk_attr_addr = 0x23c8 + (precalc2 >> 2);
	} else {
		chunk_addr = 0x2460 + precalc2;
		chunk_attr_addr = 0x27c0 + (precalc2 >> 2);
	}

	// We need 4 frames to draw all the tiles in each "chunk"
	paint_chunk ();
	ppu_waitnmi ();
	paint_chunk ();
	ppu_waitnmi ();
	paint_chunk ();
	ppu_waitnmi ();
	paint_chunk ();
	ppu_waitnmi ();
}

void __fastcall__ draw_map (void) {
	unsigned char x;
	unsigned char chunk_ini;
	unsigned char chunk_fin;

	/*scroll ((map_chunk_offset << 5) & 0x01ff, 0);
	cam_pos = map_chunk_offset << 5;*/

	// map_chunk_offset must be given in chunks.
	// This function will draw:

	//   {visible  screen}
	// |x| | | | | | | | |x|
	//   |
	//   +-> map_chunk_offset

	// Chunk initial:
	chunk_ini = (map_chunk_offset - 1) & 127;

	// Chunk final:
	chunk_fin = (map_chunk_offset + 10) & 127;

	// x coordinate (0-63) initial
	x = (chunk_ini << 2) & 63;

	// draw 10 chunks
	chunk_idx = chunk_ini;
	while (1) {

		// Calculate nametable address
		if (x < 32) {
			chunk_addr = 0x2080 + x;
			chunk_attr_addr = 0x23c8 + (x >> 2);
		} else {
			chunk_addr = 0x2460 + x;
			chunk_attr_addr = 0x27c0 + (x >> 2);
		}

		// We need 4 frames to draw all the tiles in each "chunk"
		paint_chunk ();
		ppu_waitnmi ();
		paint_chunk ();
		ppu_waitnmi ();
		paint_chunk ();
		ppu_waitnmi ();
		paint_chunk ();
		ppu_waitnmi ();

		// Next
		chunk_idx = (chunk_idx + 1) & 127;
		x = (x + 4) & 63;

		// Until we are done.
		if (chunk_idx == chunk_fin) break;
	}
}

// Draws a chunk off the visible screen border, then
// scrolls the viewport.
void __fastcall__ scroll_to (void) {
	// Depending on the direction we are scrolling,
	// update the rightmost or leftmost side.
	if (cam_pos > cam_old_pos) {
		chunk_idx = (cam_pos >> 5) + 9;
		precalc1 = (36 + ((cam_pos >> 5) << 2)) & 63;
		precalc2 = chunk_idx & 15;
	} else {
		chunk_idx = (cam_pos >> 5) - 1;
		precalc1 = (((cam_pos >> 5) << 2) - 4) & 63;
		precalc2 = chunk_idx & 15;
	}

	// Calculate nametable address
	chunk_addr = (precalc1 < 32 ? 0x2080 : 0x2460) + precalc1;
	chunk_attr_addr = (precalc1 < 32 ? 0x23C8 : 0x27C0) + precalc2;

	paint_chunk ();

	// Scroll viewport
	scroll (cam_pos & 0x01ff, 0);
	cam_old_pos = cam_pos;
}
