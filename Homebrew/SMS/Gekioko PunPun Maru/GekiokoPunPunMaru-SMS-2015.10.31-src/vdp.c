#include "sms.h"
#include "vdp.h"
/* ----------------------------------------------------------------------------------- */
int8u scroll_x;
int8u scroll_y;
int8u sprite_buffer[256];
int8u sprite_index;
volatile int8u vsync_flag;

/* ----------------------------------------------------------------------------------- */
void vdp_init(){
	/* VDP Register #0 */
	VDP_CTRL = (0 << V_SCR_LOCK) + (0 << H_SCR_LOCK) + (0 << HIDE_COLUMN) + (0 << H_INT) + (0 << SHIFT_SPRITES) + (1 << MODE_4) + (0 << MODE_2) + (0 << SYNCH);
	VDP_CTRL = VREG_WRITE + 0;

	/* VDP Register #1 */
	VDP_CTRL = (0 << DISPLAY) + (0 << V_INT) + (0 << MODE_1) + (0 << MODE_3) + (0 << SPR_8X16) + (0 << SPR_ZOOM);
	VDP_CTRL = VREG_WRITE + 1;
	
	/* VDP Register #2 - BG Name Table Base Address, def = 0xFF (VRAM address $3800) */
	VDP_CTRL = 0xFF;
	VDP_CTRL = VREG_WRITE + 2;

	/* VDP Register #3 - Color Table Base Address, def = 0xFF */
	VDP_CTRL = 0xFF;
	VDP_CTRL = VREG_WRITE + 3;

	/* VDP Register #4 - BG Pattern Generator Table Base Address, def = 0x07 */
	VDP_CTRL = 0x07;
	VDP_CTRL = VREG_WRITE + 4;

	/* VDP Register #5 - Sprite Attribute Table Base Address, def = ((0x3F << 1) + 1), (VRAM address $3F00) */
	VDP_CTRL = (0x3F << 1) + 1;
	VDP_CTRL = VREG_WRITE + 5;

	/* VDP Register #6 - Sprite Pattern Generator Table Base Address, def = 0x03 (Sprites pattern $0000 - $1f00) */
	VDP_CTRL = 0x03;
	VDP_CTRL = VREG_WRITE + 6;

	/* VDP Register #7 - Overscan/Backdrop Color */
	VDP_CTRL = 0;
	VDP_CTRL = VREG_WRITE + 7;
	
	vram_fill(0x0000, 0x00, 16 * 1024);

	/* clear sprites */
	sprites_clear();
	vram_store(0x3F00 +  0, sprite_buffer, 32);
	vram_store(0x3F00 + 32, sprite_buffer, 32);
}
/* ----------------------------------------------------------------------------------- */
void vsync_wait(){
	int8u d;
	
	/* clear flags */
	d = VDP_CTRL;
	
	/* wait VBLANK INTERRUPT PENDING */
	while(373){
		if(VDP_CTRL & 0x80) break;
	}
}
/* ----------------------------------------------------------------------------------- */
void display_off(){
	_asm
		di
	_endasm;

	scroll_x = 0;
	scroll_y = 0;

	sprites_clear();
	sprites_store();
	scroll_store();

	/* VDP Register #1 */
	VDP_CTRL = (0 << DISPLAY) + (0 << V_INT) + (0 << MODE_1) + (0 << MODE_3) + (0 << SPR_8X16) + (0 << SPR_ZOOM);
	VDP_CTRL = VREG_WRITE + 1;
}
void display_on(){
	_asm
		ei
	_endasm;
	vsync_wait();

	/* VDP Register #1 */
	VDP_CTRL = (1 << DISPLAY) + (0 << V_INT) + (0 << MODE_1) + (0 << MODE_3) + (0 << SPR_8X16) + (0 << SPR_ZOOM);
	VDP_CTRL = VREG_WRITE + 1;
}
/* ----------------------------------------------------------------------------------- */
void vram_store(int16u address, int8u *source, int16u length){
	int8u c8;
	int16u c16;

	VDP_CTRL = address & 0x00FF;
	VDP_CTRL = VRAM_WRITE + (address >> 8);

	if(length == 64){
		for(c8 = 64 / 8; c8 > 0; c8--){
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
			VDP_DATA = *source++;
		}
	}else{
		for(c16 = length; c16 > 0; c16--){
			VDP_DATA = *source++;
		}
	}
}
/* ----------------------------------------------------------------------------------- */
void vram_store_with_decompress(int16u address, int8u *source, int16u length){
	int16u block;
	int8u c;
	int8u c2;
	int8u fill;
	int8u mask;

	VDP_CTRL = address & 0x00FF;
	VDP_CTRL = VRAM_WRITE + (address >> 8);

	for(block = length >> 5; block > 0; block--){
		fill = *source++;
		for(c = 4; c > 0; c--){
			mask = *source++;
			for(c2 = 8; c2 > 0; c2--){
				if((mask & 0x0001) == 0){
					VDP_DATA = fill;
				}else{
					VDP_DATA = *source++;
				}
				mask >>= 1;
			}
		}
	}
}
/* ----------------------------------------------------------------------------------- */
/* length = as decoded data, alignment to 8bytes */
void decompress(int8u *distination, int8u *source, int16u length){
	int16u block;
	int8u c;
	int8u c2;
	int8u fill;
	int8u mask;

	for(block = length >> 5; block > 0; block--){
		fill = *source++;
		for(c = 4; c > 0; c--){
			mask = *source++;
			for(c2 = 8; c2 > 0; c2--){
				if((mask & 0x0001) == 0){
					*distination++ = fill;
				}else{
					*distination++ = *source++;
				}
				mask >>= 1;
			}
		}
	}
}
/* ----------------------------------------------------------------------------------- */
/* length = byte */
void vram_fill(int16u address, int8u data, int16u length){
	int16u c16;
	int8u d;

	d = data;
	
	VDP_CTRL = address & 0x00FF;
	VDP_CTRL = VRAM_WRITE + (address >> 8);

	for(c16 = length; c16 > 0; c16--){
		VDP_DATA = d;
	}
}
/* ----------------------------------------------------------------------------------- */
/* length = byte */
void pattern_fill(int16u address, int8u pattern_low, int8u pattern_high, int16u length){
	int16u c16;
	int8u low;
	int8u high;

	low = pattern_low;
	high = pattern_high;
	
	VDP_CTRL = address & 0x00FF;
	VDP_CTRL = VRAM_WRITE + (address >> 8);

	for(c16 = length >> 1; c16 > 0; c16--){
		VDP_DATA = low;
		VDP_DATA = high;
	}
}
/* ----------------------------------------------------------------------------------- */
void palette_store(int8u color_no, int8u *source, int8u color_count){
	int8u c;

	VDP_CTRL = color_no;
	VDP_CTRL = CRAM_WRITE;

	for(c = color_count; c > 0; c--){
		VDP_DATA = *source++;
	}
}
/* ----------------------------------------------------------------------------------- */
void sprites_clear(){
	int8u inx;
	int8u *p;

	p = sprite_buffer;
	for(inx = 32 / 8; inx > 0; inx--){
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
		*p++ = 192;
	}
	sprite_index = 0;
}
/* ----------------------------------------------------------------------------------- */
void sprite_set(int8u x, int8u y, int8u pattern){
	int8u *p;
	
	p = sprite_buffer;
	p += sprite_index;
	*p = y;

	p = sprite_buffer;
	p += sprite_index << 1;
	p += 0x80;
	*p++ = x;

	*p = pattern;
	sprite_index++;
}
/* ----------------------------------------------------------------------------------- */
void sprites_store(){
	int8u *p;
	int8u c;

	p = sprite_buffer;
	VDP_CTRL = 0x00;				/* bit  7 - 0 */
	VDP_CTRL = VRAM_WRITE + 0x3F;	/* bit 13 - 8 */
	for(c = 32 / 8; c > 0; c--){
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
	}

	p += 0x80 - 32;
	VDP_CTRL = 0x80;				/* bit  7 - 0 */
	VDP_CTRL = VRAM_WRITE + 0x3F;	/* bit 13 - 8 */
	for(c = 32 / 8; c > 0; c--){
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;

		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
		VDP_DATA = *p++;
	}
}
/* ----------------------------------------------------------------------------------- */
void scroll_store(){
	VDP_CTRL = scroll_x;
	VDP_CTRL = VREG_WRITE + 8;

	VDP_CTRL = scroll_y;
	VDP_CTRL = VREG_WRITE + 9;
}
/* ----------------------------------------------------------------------------------- */

