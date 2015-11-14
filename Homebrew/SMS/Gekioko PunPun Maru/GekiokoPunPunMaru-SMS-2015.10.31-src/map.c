/* マップ */
#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "file.h"
#include "main.h"

#include "map.h"
#include "status.h"
#include "print.h"

int8u block_array_offset;	/* 読み取る block_array[] の要素の始点 */
int8u pattern_name_buffer[64];
int8u map_cache[2048 + 512];

#define B7	0x80
#define B6	0x40
#define B5	0x20
#define B4	0x10
#define B3	0x08
#define B2	0x04
#define B1	0x02
#define B0	0x01
const int8u block_array[] = {
	/* stage 1-1 */
	0                                 , 
	0 +B0     +B2          +B5    +B7 ,
	0                                 , 
	0     +B1     +B3 +B4     +B6     , 
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0                                 , 
	0 +B0         +B3 +B4         +B7 , 
	0                                 , 
	0 +B0 +B1 +B2         +B5 +B6 +B7 , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 1-2 */
	0                                 , 
	0 +B0                         +B7 , 
	0                                 , 
	0 +B0 +B1     +B3 +B4     +B6 +B7 , 
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0         +B2         +B5         , 
	0                                 , 
	0     +B1                 +B6     , 
	0 +B0         +B3 +B4         +B7 , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 , 
	0                                 , 
	0                                 , 

	/* stage 1-3 */
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0                                 , 
	0 +B0 +B1 +B2         +B5 +B6 +B7 , 
	0                                 , 
	0 +B0     +B2 +B3 +B4 +B5     +B7 , 
	0                                 , 
	0     +B1                 +B6     , 
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0         +B2         +B5         , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 , 
	0                                 ,
	0                                 , 

	/* stage 2-1 */
	0                                 , 
	0 +B0                     +B6 +B7 , 
	0         +B2 +B3                 , 
	0 +B0                         +B7 ,
	0                     +B5         , 
	0     +B1 +B2     +B4 +B5 +B6     , 
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0         +B2 +B3                 , 
	0 +B0                 +B5     +B7 , 
	0                                 , 
	0                 +B4             , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 2-2 */
	0                                 , 
	0 +B0 +B1         +B4         +B7 , 
	0                         +B6     , 
	0         +B2         +B5         ,
	0 +B0                         +B7 , 
	0         +B2 +B3     +B5 +B6     , 
	0                                 , 
	0 +B0 +B1                 +B6 +B7 , 
	0             +B3 +B4             , 
	0                                 , 
	0     +B1 +B2                     , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 2-3 */
	0                                 , 
	0 +B0                 +B5     +B7 ,
	0     +B1 +B2                     , 
	0                 +B4     +B6 +B7 , 
	0 +B0                             , 
	0     +B1                 +B6 +B7 , 
	0         +B2 +B3                 , 
	0 +B0                 +B5     +B7 , 
	0                                 , 
	0 +B0     +B2             +B6 +B7 , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 3-1 */
	0                                 , 
	0 +B0 +B1         +B4 +B5 +B6     , 
	0                                 , 
	0     +B1 +B2 +B3         +B6 +B7 ,
	0                                 , 
	0 +B0 +B1         +B4 +B5 +B6     , 
	0                                 , 
	0     +B1 +B2 +B3         +B6 +B7 , 
	0                                 , 
	0 +B0 +B1         +B4 +B5 +B6     , 
	0                                 , 
	0     +B1 +B2             +B6 +B7 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 3-2 */
	0                                 , 
	0 +B0                 +B6         , 
	0     +B1 +B2 +B3             +B7 , 
	0 +B0                     +B6 +B7 , 
	0                                 , 
	0     +B1 +B2     +B4 +B5         , 
	0                         +B6     , 
	0 +B0             +B4             , 
	0         +B2                 +B7 , 
	0                     +B5     +B7 , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 3-3 */
	0                                 , 
	0 +B0                         +B7 ,
	0         +B2 +B3 +B4 +B5         , 
	0     +B1                 +B6     , 
	0                                 , 
	0     +B1                 +B6     , 
	0             +B3                 , 
	0 +B0                 +B5     +B7 , 
	0                                 , 
	0         +B2                     , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 ,


	/* stage 4-1 */
	0                                 , 
	0 +B0 +B1     +B3     +B5 +B6     , 
	0                                 , 
	0 +B0 +B1 +B2 +B3         +B6 +B7 ,
	0                                 , 
	0 +B0 +B1         +B4 +B5 +B6     , 
	0                                 , 
	0     +B1 +B2 +B3         +B6 +B7 , 
	0                                 , 
	0 +B0 +B1         +B4     +B6     , 
	0                                 , 
	0     +B1 +B2             +B6     , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 4-2 */
	0                                 , 
	0 +B0             +B4 +B6         , 
	0     +B1                     +B7 , 
	0 +B0     +B2             +B6     , 
	0                                 , 
	0     +B1 +B2     +B4 +B5     +B7 , 
	0                         +B6     , 
	0 +B0             +B4             , 
	0         +B2                 +B7 , 
	0     +B1             +B5     +B7 , 
	0             +B3                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 

	/* stage 4-3 */
	0                                 , 
	0 +B0                         +B7 ,
	0         +B2    +B4              , 
	0     +B1                 +B6     , 
	0         +B2         +B5         , 
	0     +B1                 +B6     , 
	0             +B3                 , 
	0 +B0                 +B5     +B7 , 
	0                                 , 
	0         +B2                     , 
	0                         +B6     , 
	0     +B1         +B4             , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 ,

	/* intro stage */
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0                                 , 
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0 +B0 +B1 +B2 +B3 +B4 +B5 +B6 +B7 , /* ground */
	0                                 ,
	0                                 , 
	0                                 , 
};
	/* 1ブロック = 16 * 32pixel */
	/* 1要素 = 1行 */
	/* 各要素の1bit = 1ブロック */

/* --------------------------------------------------------------------------------- */
void map_make_pointer(int8u stage, int8u level){
	int8u count;

	/* ゲーム中に読み取る block_array[] の要素の始点 */
	block_array_offset = level << 4;
	for(count = stage; count > 0; count--){
		block_array_offset += 16 * 3;
	}
}
/* --------------------------------------------------------------------------------- */
void map_show(){
	int8u row;
	int8u *map;

	psg_init();
	map_make_pointer(stage, level);

	scroll_x = 0;
	scroll_y = 23 * 8;
	switch(stage){
	case 0:
		map = fopen("map/castle.map");
		break;
	case 1:
		map = fopen("map/summer.map");
		break;
	case 2:
		map = fopen("map/jungle.map");
		break;
	default:
		map = fopen("map/winter.map");
		break;
	}
	for(row = 23; row > 0; row--){
		sprites_clear();

		map_make_buffer(row, map);
		map_add_blocks(row);

		vsync_wait();
		sprites_store();
		store_pattern_name_buffer(row);
		scroll_store();
		
		scroll_y -= 8;
	}
	print_init();
	status_init();
}
void load_palette(int8u back_palette, int8u char_palette){
	int8u *pal;
	
	vsync_wait();
	switch(char_palette){
	case 0:
		pal = fopen("bmp/sp_castle.pal");
		break;
	case 1:
		pal = fopen("bmp/sp_castle.pal");
		break;
	case 2:
		pal = fopen("bmp/sp_castle.pal");
		break;
	default:
		pal = fopen("bmp/sp_castle.pal");
		break;
	}
	palette_store(16, pal, 16);

	vsync_wait();
	switch(back_palette){
	case 0:
		pal = fopen("bmp/castle.pal");
		break;
	case 1:
		pal = fopen("bmp/summer.pal");
		break;
	case 2:
		pal = fopen("bmp/jungle.pal");
		break;
	default:
		pal = fopen("bmp/winter.pal");
		break;
	}
	palette_store( 0, pal, 16);
	palette_store(16, pal, 1);
}
/* マップパターンは1VSYNCに1行だけVRAMにストアする */
void store_pattern_name_buffer(int8u row){
	int16u address;

	address = row & 0x1F;
	address <<= 6;
	address += 0x3800;
	vram_store(address, pattern_name_buffer, 64);
}
void map_make_buffer(int8u row, int8u *map){
	int8u count;
	int8u *buf;

	map += row << (5 + 1);
	buf = pattern_name_buffer;
	for(count = 0; count < 32; count++){
		*buf++ = *map++;
		*buf++ = *map++;
	}
}
void map_add_blocks(int8u row){
	int8u a;
	int8u count;
	int8u block;
	int8u *buf;
	
	a = row >> 1;
	a += block_array_offset;
	block = block_array[a];

	buf = pattern_name_buffer;
	for(count = 0; count < 8; count++){
		if((block & 0x01) != 0){
			if((row & 0x01) == 0){
				*buf++ = VRAM_BLOCK + 0;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 1;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 2;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 3;
				*buf++ = BG_HIGH;
			}else{
				*buf++ = VRAM_BLOCK + 4;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 5;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 6;
				*buf++ = BG_HIGH;
				*buf++ = VRAM_BLOCK + 7;
				*buf++ = BG_HIGH;
			}
		}else{
			buf += 4 << 1;
		}
		block >>= 1;
	}
}

