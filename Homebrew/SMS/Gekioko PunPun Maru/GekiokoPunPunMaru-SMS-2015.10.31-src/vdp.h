/* ----------------------------------------------------------------------------------- */
sfr at 0x7E VDP_V;
sfr at 0x7F VDP_H;
sfr at 0xBE VDP_DATA;
sfr at 0xBF VDP_CTRL;
	#define VREG_WRITE	(2 << 6)	/* for bit CD0 - CD1 */
	#define VRAM_WRITE	(1 << 6)	/* for bit CD0 - CD1 */
	#define CRAM_WRITE	(3 << 6)	/* for bit CD0 - CD1 */

	/* MSB                         LSB */
	/* D07 D06 D05 D04 D03 D02 D01 D00    First byte written, Dx = Reg Value */
	/*  1   0   ?   ?  R03 R02 R01 R00    Second byte written, Rx = Reg Number */

	/* A07 A06 A05 A04 A03 A02 A01 A00    First byte written */
	/* CD1 CD0 A13 A12 A11 A10 A09 A08    Second byte written */

	/* CRAM format: XXBBGGRR */

	/* VDP Register #0 */
	#define V_SCR_LOCK	7
	#define H_SCR_LOCK	6
	#define HIDE_COLUMN	5
	#define H_INT			4
	#define SHIFT_SPRITES	3
	#define MODE_4		2
	#define MODE_2		1
	#define SYNCH			0

	/* VDP Register #1 */
	#define DISPLAY	6
	#define V_INT		5
	#define MODE_1	4
	#define MODE_3	3
	#define SPR_8X16	1
	#define SPR_ZOOM	0
	
	/* VDP Register #2 - BG Name Table Base Address, def = 0xFF (VRAM address $3800) */

	/* VDP Register #3 - Color Table Base Address, def = 0xFF */

	/* VDP Register #4 - BG Pattern Generator Table Base Address, def = 0x07 */

	/* VDP Register #5 - Sprite Attribute Table Base Address, def = ((0x37 << 1) + 1), (VRAM address $3700) */

	/* VDP Register #6 - Sprite Pattern Generator Table Base Address, def = 0x03 (Sprites pattern $0000 - $1f00) */

	/* VDP Register #7 - Overscan/Backdrop Color */

	/* VDP Register #8 - Background X Scroll */

	/* VDP Register #9 - Background Y Scroll */

	/* VDP Register #A - Line counter */

/* ----------------------------------------------------------------------------------- */
/* sprite and bg pattern option for high byte */

#define SPR_HFLIP	0x80
#define SPR_VFLIP	0x00

#define BG_HIGH	0x01	/* use high part of patterns (0x100 - 0x1FF) */
#define BG_HFLIP	0x02
#define BG_VFLIP	0x04
#define BG_PAL1	0x08
#define BG_TOP	0x10

/* ----------------------------------------------------------------------------------- */
/* get pattern number from VRAM address (byte) */
#define PTN(a)	(a >> 5)

/* patterns count by size */
#define PTN_32x8	(4 * 1)
#define PTN_32x16	(4 * 2)
#define PTN_32x24	(4 * 3)
#define PTN_32x32	(4 * 4)

#define PTN_24x8	(3 * 1)
#define PTN_24x16	(3 * 2)
#define PTN_24x24	(3 * 3)
#define PTN_24x32	(3 * 4)

#define PTN_16x8	(2 * 1)
#define PTN_16x16	(2 * 2)
#define PTN_16x24	(2 * 3)
#define PTN_16x32	(2 * 4)

#define PTN_8x8	(1 * 1)
#define PTN_8x16	(1 * 2)
#define PTN_8x24	(1 * 3)
#define PTN_8x32	(1 * 4)

/* ----------------------------------------------------------------------------------- */
#define VRAM_BLOCK			(0 * 16 + 8)
#define VRAM_BLACK			(1)
#define VRAM_FONT				(8 * 16 - 0x20)
#define VRAM_NUMBER			(8 * 16 + 16)

#define VRAM_PLAYER_WALK		0
#define VRAM_PLAYER_STAND	(VRAM_PLAYER_WALK		+ 6 * 2)
#define VRAM_SMOKE			(VRAM_PLAYER_STAND	+ 6 * 2)
#define VRAM_DARUMA			(VRAM_SMOKE			+ 4 * 1)
#define VRAM_NINJA_CAKE		(VRAM_DARUMA			+ 4 * 1)
#define VRAM_NINJA			(VRAM_NINJA_CAKE		+ 4 * 2)
#define VRAM_BOAR				(VRAM_NINJA			+ 4 * 2)
#define VRAM_POINT			(VRAM_BOAR				+ 4 * 2)
#define VRAM_LIFE				(VRAM_POINT			+ 2 * 1)
#define VRAM_UNKO				(VRAM_LIFE				+ 1 * 1)
#define VRAM_BOMB				(VRAM_UNKO				+ 1 * 1)
#define VRAM_TENGU			(VRAM_BOMB				+ 4 * 3)
#define VRAM_HIME				(VRAM_TENGU			+ 6 * 2)
#define VRAM_GOAST			(VRAM_HIME				+ 6 * 2)
#define VRAM_BIRD				(VRAM_GOAST			+ 4 * 2)
#define VRAM_FLOG				(VRAM_BIRD				+ 4 * 2)
#define VRAM_NASU				(VRAM_FLOG				+ 4 * 2)

/* ----------------------------------------------------------------------------------- */
extern void vdp_init();
extern void vsync_wait();
extern void sprites_clear();
extern void sprite_set(int8u x, int8u y, int8u pattern);
extern void sprites_store();
extern void scroll_store();
extern void palette_store(int8u color_no, int8u *source, int8u color_count);
extern void vram_store_with_decompress(int16u address, int8u *source, int16u length);
extern void vram_store(int16u address, int8u *source, int16u length);	/* address is VRAM address */
extern void vram_fill(int16u address, int8u data, int16u length);
extern void pattern_fill(int16u address, int8u pattern_low, int8u pattern_high, int16u length);	/* length = byte */
extern void pattern_store_from_md_format(int16u address, int8u *source, int16u length);
extern void decompress(int8u *distination, int8u *source, int16u length); 
extern void vsync_wait();
extern void display_on();
extern void display_off();

/* ----------------------------------------------------------------------------------- */
extern int8u scroll_x;
extern int8u scroll_y;
extern volatile int8u vsync_flag;

extern const int8u intro_map[];
extern const int8u back_map[];
extern const int8u sprite_ptn[];
extern const int8u sprite_pal[];
extern const int8u back_ptn[];
extern const int8u back_pal[];
extern const int8u title_ptn[];
extern const int8u title_pal[];

/* ----------------------------------------------------------------------------------- */

