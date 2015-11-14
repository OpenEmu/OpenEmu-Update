/* マップ */

extern int8u pattern_name_buffer[64];
extern int8u block_array_offset;	/* 読み取る block_array[] の要素の始点 */
extern const int8u block_array[];
extern int8u map_cache[2048 + 512];

extern void map_show();
extern void map_make_pointer(int8u stage, int8u level);
extern void map_make_buffer(int8u row, int8u *map);
extern void map_add_blocks(int8u row);

/* マップ用のVRAM/CRAM関数 */
extern void store_pattern_name_buffer(int8u row);
extern void load_palette(int8u back_palette, int8u char_palette);


