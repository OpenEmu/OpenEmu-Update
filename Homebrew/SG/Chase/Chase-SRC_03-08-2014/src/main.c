/*
 *                      - Feel free to do anything you want* with this code, consider it as PUBLIC DOMAIN -
 *                                  ... but be careful, this code is dark and full of terrors.
 *
 *                                    (*) NOT ALLOW TO USE THIS CODE FOR COMMERCIAL PURPOSES
 *
 *    @@@@@@@@@@_____@@@@@@@@@@@@@@@@@@@@_____@@@@@@@@@@@@@@@@@@@@_____@@@@@@@@@@@@@@@@@@@@_____@@@@@@@@@@@@@@@@@@@@_____@@@@@@@@@@
 *    @@@@@@@@@/\    \@@@@@@@@@@@@@@@@@@/\    \@@@@@@@@@@@@@@@@@@/\    \@@@@@@@@@@@@@@@@@@/\    \@@@@@@@@@@@@@@@@@@/\    \@@@@@@@@@
 *    @@@@@@@@/::\    \@@@@@@@@@@@@@@@@/::\____\@@@@@@@@@@@@@@@@/::\    \@@@@@@@@@@@@@@@@/::\    \@@@@@@@@@@@@@@@@/::\    \@@@@@@@@
 *    @@@@@@@/::::\    \@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/::::\    \@@@@@@@@@@@@@@/::::\    \@@@@@@@@@@@@@@/::::\    \@@@@@@@
 *    @@@@@@/::::::\    \@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/::::::\    \@@@@@@@@@@@@/::::::\    \@@@@@@@@@@@@/::::::\    \@@@@@@
 *    @@@@@/:::/\:::\    \@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/:::/\:::\    \@@@@@@@@@@/:::/\:::\    \@@@@@@@@@@/:::/\:::\    \@@@@@
 *    @@@@/:::/  \:::\    \@@@@@@@@/:::/____/@@@@@@@@@@@@@@@/:::/__\:::\    \@@@@@@@@/:::/__\:::\    \@@@@@@@@/:::/__\:::\    \@@@@
 *    @@@/:::/    \:::\    \@@@@@@/::::\    \@@@@@@@@@@@@@@/::::\   \:::\    \@@@@@@@\:::\   \:::\    \@@@@@@/::::\   \:::\    \@@@
 *    @@/:::/    /@\:::\    \@@@@/::::::\    \@@@_____@@@@/::::::\   \:::\    \@@@@___\:::\   \:::\    \@@@@/::::::\   \:::\    \@@
 *    @/:::/    /@@@\:::\    \@@/:::/\:::\    \@/\    \@@/:::/\:::\   \:::\    \@@/\   \:::\   \:::\    \@@/:::/\:::\   \:::\    \@
 *    /:::/____/@@@@@\:::\____\/:::/  \:::\    /::\____\/:::/  \:::\   \:::\____\/::\   \:::\   \:::\____\/:::/__\:::\   \:::\____\
 *    \:::\    \@@@@@@\::/    /\::/    \:::\  /:::/    /\::/    \:::\  /:::/    /\:::\   \:::\   \::/    /\:::\   \:::\   \::/    /
 *    @\:::\    \@@@@@@\/____/@@\/____/@\:::\/:::/    /@@\/____/@\:::\/:::/    /@@\:::\   \:::\   \/____/@@\:::\   \:::\   \/____/@
 *    @@\:::\    \@@@@@@@@@@@@@@@@@@@@@@@\::::::/    /@@@@@@@@@@@@\::::::/    /@@@@\:::\   \:::\    \@@@@@@@\:::\   \:::\    \@@@@@
 *    @@@\:::\    \@@@@@@@@@@@@@@@@@@@@@@@\::::/    /@@@@@@@@@@@@@@\::::/    /@@@@@@\:::\   \:::\____\@@@@@@@\:::\   \:::\____\@@@@
 *    @@@@\:::\    \@@@@@@@@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/:::/    /@@@@@@@@\:::\  /:::/    /@@@@@@@@\:::\   \::/    /@@@@
 *    @@@@@\:::\    \@@@@@@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@\:::\/:::/    /@@@@@@@@@@\:::\   \/____/@@@@@
 *    @@@@@@\:::\    \@@@@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@\::::::/    /@@@@@@@@@@@@\:::\    \@@@@@@@@@
 *    @@@@@@@\:::\____\@@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@@/:::/    /@@@@@@@@@@@@@@\::::/    /@@@@@@@@@@@@@@\:::\____\@@@@@@@@
 *    @@@@@@@@\::/    /@@@@@@@@@@@@@@@@\::/    /@@@@@@@@@@@@@@@@\::/    /@@@@@@@@@@@@@@@@\::/    /@@@@@@@@@@@@@@@@\::/    /@@@@@@@@
 *    @@@@@@@@@\/____/@@@@@@@@@@@@@@@@@@\/____/@@@@@@@@@@@@@@@@@@\/____/@@@@@@@@@@@@@@@@@@\/____/@@@@@@@@@@@@@@@@@@\/____/@@@@@@@@@
 *    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *
 * Original game by Shiru (shiru@mail.ru), released for NES, CHECK OUT THIS! [http://shiru.untergrund.net/software.shtml#nes]
 *
 * @CODE: 		    =>  JACK NOLDDOR    | Mail to: nolddor@hotmail.com
 * @GRAPHIC / GFX: 	=>  JACK NOLDDOR    | Mail to: nolddor@hotmail.com
 * @MUSIC / SFX: 	=>  DAVIDIAN        | Twitter: @DavidBonus
 * @PROJECT: 		=>  #Chase
 * @START DATE: 	=>  20-06-2014
 * @LAST UPDATE: 	=>  01-08-2014
 * @LIB:            =>  SGDK (v0.96d) by Stephane Dallongeville
 *
 * Special thanks to @MoonWatcherMD for always being there when I needed and encourage me to finish this game :)
 *
 * --------------------------------------------------------------------------------------------------------------------------------
 *  CHANGELOG
 * --------------------------------------------------------------------------------------------------------------------------------
 * 03-08-2014 » First release
 * --------------------------------------------------------------------------------------------------------------------------------
 *
 */


//== DEFINES
#define MAX_LEVELS 10

#define TILE_FLOOR  0x0007
#define TILE_COIN   0x0005
#define TILE_EMPTY  0x0000

#define APLAN_ADDR(x,y)     (stages[lvl]->fg[(x)+(y)*stages[lvl]->w])
#define BPLAN_ADDR(x,y)     (stages[lvl]->bg[(x)+(y)*stages[lvl]->w])
#define COIN_MAP_ADDR(x,y)  (coin_map[(x)+(y)*40])
#define IS_FLOOR(x,y)       (BPLAN_ADDR(x,y) == TILE_FLOOR)
#define IS_COIN(x,y)        (COIN_MAP_ADDR(x,y) == TILE_COIN)

#define MAX_PLAYER 4

#define MAX_MOVES 16 // in pixel

#define MAX_DIR     4
#define DIR_NONE    0
#define DIR_UP      1
#define DIR_RIGHT   2
#define DIR_DOWN    3
#define DIR_LEFT    4

#define SPR_OFFSET_MASK 0x80 //DEV NOTE: In Sega Mega Drive visible sprites start at x,y = 128px

#define _Fixed_Start_VGM(x);        SND_isPlaying_MVS();    SND_startPlay_VGM(x);
#define _Fixed_Stop_VGM();          _Fixed_Start_VGM(music_mute);


//== INCLUDES
#include <genesis.h>
#include <kdebug.h>
#include "../res/rescomp.h"
#include "../inc/psgplayer.h"
#include "../mappy/mappy.h"


//== GLOBAL DATA
typedef struct
{
    const u16	w;  // in tiles
    const u16	h;  // in tiles
    const u16*	pal;
    const u16*	pal_fade;
    const u16	numTiles;
    const u32*	tiledata;
    const u16*	bg;
    const u16*	fg;
    const u16   numCoins;

} MappyResource;

const MappyResource stage01 = { 40, 28, zone01_palette, zone01_palette_fade, 14, common_tiledata, map01_background, map01_foreground, 20 };
const MappyResource stage02 = { 40, 28, zone01_palette, zone01_palette_fade, 14, common_tiledata, map02_background, map02_foreground, 20 };
const MappyResource stage03 = { 40, 28, zone02_palette, zone02_palette_fade, 14, common_tiledata, map03_background, map03_foreground, 39 };
const MappyResource stage04 = { 40, 28, zone02_palette, zone02_palette_fade, 14, common_tiledata, map04_background, map04_foreground, 39 };
const MappyResource stage05 = { 40, 28, zone03_palette, zone03_palette_fade, 14, common_tiledata, map05_background, map05_foreground, 47 };
const MappyResource stage06 = { 40, 28, zone03_palette, zone03_palette_fade, 14, common_tiledata, map06_background, map06_foreground, 53 };
const MappyResource stage07 = { 40, 28, zone04_palette, zone04_palette_fade, 14, common_tiledata, map07_background, map07_foreground, 56 };
const MappyResource stage08 = { 40, 28, zone04_palette, zone04_palette_fade, 14, common_tiledata, map08_background, map08_foreground, 59 };
const MappyResource stage09 = { 40, 28, zone05_palette, zone05_palette_fade, 14, common_tiledata, map09_background, map09_foreground, 90 };
const MappyResource stage10 = { 40, 28, zone05_palette, zone05_palette_fade, 14, common_tiledata, map10_background, map10_foreground, 118 };

const MappyResource *stages[MAX_LEVELS] =
{
    &stage01,
    &stage02,
    &stage03,
    &stage04,
    &stage05,
    &stage06,
    &stage07,
    &stage08,
    &stage09,
    &stage10
};

const Image *lvl_screens[MAX_LEVELS] =
{
    &lvl_screen01,
    &lvl_screen02,
    &lvl_screen03,
    &lvl_screen04,
    &lvl_screen05,
    &lvl_screen06,
    &lvl_screen07,
    &lvl_screen08,
    &lvl_screen09,
    &lvl_screen10
};

u16 coin_map[40 * 28];

u8 lives, lvl, coins_collected;
u8 GAME_DONE_FLAG, GAME_CLEAR_FLAG, GAME_PAUSE;

Sprite tblSpr[MAX_SPRITE];

fix16 speedSpr[MAX_SPRITE] =
{
    FIX16(1.8), // PLAYER 1
    FIX16(0.9), // ENEMY 1
    FIX16(1.0), // ENEMI 2
    FIX16(1.1)  // ENEMY 3
};

u8 nbSpr[MAX_LEVELS] = { 2, 2, 3, 3, 3, 3, 4, 4, 4, 4 };

Vect2D_u16 posSpr_lvl01_02[2] = { {112, 80},  {192,144} };
Vect2D_u16 posSpr_lvl03_04[3] = { { 96, 64},  {208, 64}, { 96,160} };
Vect2D_u16 posSpr_lvl05_06[3] = { { 96, 64},  {208, 64}, {208,160} };
Vect2D_u16 posSpr_lvl07_08[4] = { { 96, 48},  {240, 64}, { 64,160}, {208,176} };
Vect2D_u16 posSpr_lvl09[4]    = { { 80, 40},  {224, 40}, { 80,184}, {224,184} };
Vect2D_u16 posSpr_lvl10[4]    = { { 72, 40},  {216, 40}, { 72,184}, {216,184} };

Vect2D_u16 *posSpr[MAX_LEVELS] =
{
    posSpr_lvl01_02,
    posSpr_lvl01_02,
    posSpr_lvl03_04,
    posSpr_lvl03_04,
    posSpr_lvl05_06,
    posSpr_lvl05_06,
    posSpr_lvl07_08,
    posSpr_lvl07_08,
    posSpr_lvl09,
    posSpr_lvl10
};

typedef struct
{
    u8      dir;
    u8      lastdir;
    fix16   offset;   // in pixel
    u16     base_x;   // in pixel
    u16     base_y;   // in pixel
    Sprite  *spr;

} tPlayer;

tPlayer tblPlayer[MAX_PLAYER];

const u8 *playlist_ingame_music[MAX_LEVELS] =
{
    music_level_1,
    music_level_2,
    music_level_3,
    music_level_1,
    music_level_2,
    music_level_3,
    music_level_1,
    music_level_2,
    music_level_3,
    music_level_final
};

//== PROTOTYPES
void _init( );
_voidCallback *VIntCallback( );
static void joyEvent( u16 joy, u16 changed, u16 state );
void VDP_drawNumberBG( u16 plan, s32 num, u16 flags, u16 x, u16 y, s16 minsize );
void _showScreen( const Image *img, u32 delay );
void _title_screen( );
void _showStage( );
void _showEnd( );


//== FUNCTIONS

void _initSprites()
{
    u8 i, delay;
    u8 *spr_cnt = &nbSpr[lvl];

    //DEV NOTE: In Sega Mega Drive, sprites with lower ID are more visible than sprites with higher ID
    //We need to set the player sprite in the last position to keep enemies over the player when a collision appears
    SPR_initSprite(&tblSpr[0], &pause, 144, VDP_getScreenHeight(), TILE_ATTR(PAL1, FALSE, FALSE, FALSE));
    SPR_update(&tblSpr[0], 1);
    for (i=0; i<*spr_cnt; i++)
    {
        s16 *pos_x = &posSpr[lvl][i].x;
        s16 *pos_y = &posSpr[lvl][i].y;
        Sprite *spr = &tblSpr[*spr_cnt-i];
        tblPlayer[i] = (tPlayer) {DIR_NONE, DIR_NONE, FIX16(0.0), *pos_x + SPR_OFFSET_MASK, *pos_y + SPR_OFFSET_MASK, spr};

        SPR_initSprite(spr, &characters, *pos_x, *pos_y, TILE_ATTR(PAL1, FALSE, FALSE, FALSE));
        SPR_setAnim(spr, i);
        psgfx_play(SFX_RESPAWN_1+i);
        for (delay=0; delay<32; delay++)
        {
            VDP_waitVSync();
            SPR_setPosition(spr, *pos_x, (delay&2) ? *pos_y : VDP_getScreenHeight()); // Sprite blinking effect
            SPR_update(&tblSpr[*spr_cnt-i], i+1);
        }
    }
}


void _JoyDir(tPlayer *pj)
{
    u16 state = JOY_readJoypad(JOY_1);
    s16 x = (pj->spr->x>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at x = 128px
    s16 y = (pj->spr->y>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at y = 128px

    pj->dir = DIR_NONE;

         if(state&BUTTON_UP     && IS_FLOOR(x, y-1))    { pj->dir=DIR_UP; }
    else if(state&BUTTON_RIGHT  && IS_FLOOR(x+2, y))    { pj->dir=DIR_RIGHT; }
    else if(state&BUTTON_DOWN   && IS_FLOOR(x, y+2))    { pj->dir=DIR_DOWN; }
    else if(state&BUTTON_LEFT   && IS_FLOOR(x-1, y))    { pj->dir=DIR_LEFT; }
}


void _RandomDir(tPlayer *player, tPlayer *enemy)
{
    s8 enemy_x  =   (enemy->spr->x>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at x = 128px
    s8 enemy_y  =   (enemy->spr->y>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at y = 128px
    s8 player_x =  (player->spr->x>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at x = 128px
    s8 player_y =  (player->spr->y>>3) - (SPR_OFFSET_MASK>>3);  // DEV NOTE: In Sega Mega Drive visible sprites start at x = 128px

    //==> Checking available directions
    u8 dir[MAX_DIR], i = 0;

    if(enemy->lastdir != DIR_DOWN   && IS_FLOOR(enemy_x, enemy_y-1))    { dir[i++]=DIR_UP; }
    if(enemy->lastdir != DIR_LEFT   && IS_FLOOR(enemy_x+2, enemy_y))    { dir[i++]=DIR_RIGHT; }
    if(enemy->lastdir != DIR_UP     && IS_FLOOR(enemy_x, enemy_y+2))    { dir[i++]=DIR_DOWN; }
    if(enemy->lastdir != DIR_RIGHT  && IS_FLOOR(enemy_x-1, enemy_y))    { dir[i++]=DIR_LEFT; }

    enemy->dir = i ? dir[random ()%i] : DIR_NONE;

    //==> Finding a clever path
    u8 clever_path[2], j, k=0;
    for(j=0; j<i; j++)
    {
             if(dir[j] == DIR_UP    && enemy_y > player_y )     { clever_path[k++]=DIR_UP; }
        else if(dir[j] == DIR_RIGHT && enemy_x < player_x )     { clever_path[k++]=DIR_RIGHT; }
        else if(dir[j] == DIR_DOWN  && enemy_y < player_y )     { clever_path[k++]=DIR_DOWN; }
        else if(dir[j] == DIR_LEFT  && enemy_x > player_x )     { clever_path[k++]=DIR_LEFT; }
    }
    if (k) { enemy->dir = clever_path[random ()%k]; }
}


void _SPR_checkCollision(tPlayer *pj1, tPlayer *pj2) // Borrowed from @KanedaFr [http://gendev.spritesmind.net/page-collide.html]
{
    u8 pj1_x = (pj1->spr->x>>3);
    u8 pj1_y = (pj1->spr->y>>3);
    u8 pj2_x = (pj2->spr->x>>3);
    u8 pj2_y = (pj2->spr->y>>3);

    if(!((pj1_x < pj2_x) || (pj1_x > pj2_x+1) || (pj1_y < pj2_y) ||(pj1_y > pj2_y+1)))
    {
        VDP_drawNumberBG(BPLAN, --lives, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 34, 1, 1);
        GAME_DONE_FLAG = TRUE;
    }
}


void _Coin_checkCollision(tPlayer *pj)
{
    s16 x = (pj->spr->x>>3) - (SPR_OFFSET_MASK>>3);
    s16 y = (pj->spr->y>>3) - (SPR_OFFSET_MASK>>3);
    const u16 *max_coin = &stages[lvl]->numCoins;

    if(IS_COIN(x,y))
    {
        psgfx_play(SFX_ITEM);
        VDP_clearTileMapRect(APLAN,	x, 	y, 2, 2);
        COIN_MAP_ADDR(x,y) = TILE_EMPTY;
        VDP_drawNumberBG(BPLAN, ++coins_collected, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 19, 1, 3);

        if(coins_collected >= *max_coin)
        {
            GAME_DONE_FLAG = GAME_CLEAR_FLAG = TRUE;
        }
    }
}


void _AI()
{
    tPlayer *player = &tblPlayer[0];

    u8 i;
    for(i=0; i<nbSpr[lvl] && !GAME_DONE_FLAG; i++)
    {
        tPlayer *pj = &tblPlayer[i];
        fix16 *pj_speed = &speedSpr[i];
        u32 pj_offset = fix16ToInt(pj->offset);

        if(!pj->dir) { i ? _RandomDir(player, pj) : _JoyDir(pj); }

        if(pj->dir)
        {
            pj->offset = fix16Add(pj->offset, *pj_speed);
            if(pj_offset > MAX_MOVES) { pj_offset = MAX_MOVES; }

            switch(pj->dir)
            {
                case DIR_UP:        pj->spr->y = pj->base_y - pj_offset; break;
                case DIR_RIGHT:     pj->spr->x = pj->base_x + pj_offset; break;
                case DIR_DOWN:      pj->spr->y = pj->base_y + pj_offset; break;
                case DIR_LEFT:      pj->spr->x = pj->base_x - pj_offset; break;
            }
        }

        if(pj_offset == MAX_MOVES || !pj->dir)
        {
            pj->offset = FIX16(0.0);
            pj->base_y = pj->spr->y;
            pj->base_x = pj->spr->x;
            pj->lastdir = pj->dir;
            pj->dir = DIR_NONE;
        }

        i ? _SPR_checkCollision(player, pj) : _Coin_checkCollision(pj);
    }

    SPR_update(tblSpr, nbSpr[lvl]+1);
}


void _gameloop()
{
    u8 frame = 0;
    coins_collected = 0;
    GAME_DONE_FLAG = GAME_CLEAR_FLAG = GAME_PAUSE = FALSE;

    _showStage();
    VDP_setPalette(PAL0, stages[lvl]->pal);
    VDP_setPalette(PAL1, spr_palette.data);

    _initSprites();

    _Fixed_Start_VGM(playlist_ingame_music[lvl]);
    JOY_setEventHandler(joyEvent);

    while(!GAME_DONE_FLAG)
    {
        if(!GAME_PAUSE)
        {
            _AI();
            VDP_setVerticalScroll(PLAN_A, (frame++&16) ? 1 : 0); // Coins Animation
        }
        VDP_waitVSync();
    }

    JOY_setEventHandler(NULL);
    _Fixed_Stop_VGM();
    psgfx_play(GAME_CLEAR_FLAG ? SFX_ALL_COLLECTED : SFX_KILL);
    waitMs(1000);
    SPR_clear();
}


void _game()
{
    lives = 3;

    for (lvl=0; lvl<MAX_LEVELS && lives; lvl++)
    {
        _Fixed_Start_VGM(music_ready);
        _showScreen(lvl_screens[lvl], 3500);
        _gameloop();
        if (!GAME_CLEAR_FLAG) {lvl--;}
    }

    _showEnd();
}


void _showEnd()
{
    const Image *img = lives ?  &well_done : &game_over;
    _Fixed_Start_VGM(lives ? music_well_done : music_game_over);

    VDP_resetScreen();
    VDP_setPalette(PAL0, palette_black);
    VDP_drawImageEx(APLAN, img, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, TILE_USERINDEX), 0, 0, FALSE, FALSE);
    VDP_fadePalIn(PAL0, img->palette->data, 15, FALSE);


    u8 frame = 0, FLAG = TRUE;
    u16 color1 = img->palette->data[1];
    u16 color2 = img->palette->data[2];

    startTimer(0);
    while(!(JOY_readJoypad(JOY_1) & BUTTON_START))
    {
        if(FLAG && getTimer(0, FALSE) >= (SUBTICKPERSECOND*3.5) && !lives) // If you aren't alive, PLAY A DIGITAL VOICE AFTER 3,5 sec. only once
        {
            SND_playSfx_VGM(sfx_game_over_voice, sizeof(sfx_game_over_voice));
            FLAG = !FLAG;
        }

        // ==>  Color Blinking effect
        VDP_waitVSync();
		VDP_setPaletteColor(1, (frame++&2) ? color1 : color2);
    }

    VDP_fadePalOut(PAL0, 20, FALSE);
}


void _showStage()
{
    const u16 *h = &stages[lvl]->h;
    const u16 *w = &stages[lvl]->w;
    const u16 *bg = stages[lvl]->bg;
    const u16 *fg = stages[lvl]->fg;

    VDP_loadTileData(stages[lvl]->tiledata, TILE_USERINDEX, stages[lvl]->numTiles, FALSE);
    VDP_setTileMapDataRectEx(BPLAN, bg, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, TILE_USERINDEX), 0, 0, *w, *h, *w);
    VDP_setTileMapDataRectEx(APLAN, fg, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, TILE_USERINDEX), 0, 0, *w, *h, *w);
    memcpy(&coin_map, fg, *w * *h * 2); //u16 type is 2 bytes size.

    // ==> HUD
    VDP_drawTextBG(BPLAN, "LEVEL:   GEMS:   /     LIVES: ", TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 5, 1);
    VDP_drawNumberBG(BPLAN, lvl+1, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 11, 1, 1);
    VDP_drawNumberBG(BPLAN, coins_collected, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 19, 1, 3);
    VDP_drawNumberBG(BPLAN, stages[lvl]->numCoins, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 23, 1, 3);
    VDP_drawNumberBG(BPLAN, lives, TILE_ATTR(PAL0, FALSE, FALSE, FALSE), 34, 1, 1);
}


void _showScreen(const Image *img, u32 delay)
{
    VDP_resetScreen();
    VDP_setPalette(PAL0, palette_black);
    VDP_drawImageEx(APLAN, img, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, TILE_USERINDEX), 0, 0, FALSE, FALSE);
    VDP_fadePalIn(PAL0, img->palette->data, 15, FALSE);

    waitMs(delay);

    VDP_fadePalOut(PAL0, 30, FALSE);
}

void _title_screen()
{
    // ==> Printing hide Title Screen
    VDP_resetScreen();
    VDP_setVerticalScroll(PLAN_A,224);
    VDP_drawImageEx(APLAN, &title_screen, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, TILE_USERINDEX), 0, 0, TRUE, FALSE);
    _Fixed_Start_VGM(music_title);

    // ==> Jumping effect
    s16 vscroll = 224<<4;
	s8 speed = -8<<4;
	u8 frame = 0, delay = 160;
    while(!(JOY_readJoypad(JOY_1) & BUTTON_START)) // Shiru's Original Algorithm -- AWESOME!!
    {
        VDP_waitVSync();
        VDP_setVerticalScroll(PLAN_A,vscroll>>4);

		vscroll+=speed;
		if(vscroll<0)
		{
			vscroll=0;
			speed=-speed>>1;
		}
		if(speed>(-8<<4)) speed-=2;

		// ==> 'Press Start' Blinking effect
		delay ? delay-- : VDP_setPaletteColor(1, (frame++&32) ? 0x0000 : 0x0EEE);
    }
    _Fixed_Stop_VGM();
    psgfx_play(SFX_START);

    // ==> Start Pressed - Faster blinking effect
    VDP_setVerticalScroll(PLAN_A,0);
    for (frame=0; frame < 64; frame++)
    {
        VDP_waitVSync();
        VDP_setPaletteColor(1, (frame&4) ? 0x0000 : 0x0EEE);
    }

    VDP_fadePalOut(PAL0, 30, FALSE);
}


void VDP_drawNumberBG(u16 plan, s32 num, u16 flags, u16 x, u16 y, s16 minsize) // Borrowed from @pocket_lucho, hehehe.
{
    char str[42];
    intToStr(num, str, minsize);
    VDP_drawTextBG(plan, str, flags, x, y);
}


static void joyEvent(u16 joy, u16 changed, u16 state)
{
    if (state & changed & BUTTON_START)
    {
        GAME_PAUSE = !GAME_PAUSE;

        psgfx_play(SFX_PAUSE);
        VDP_setPalette(PAL0, GAME_PAUSE ? stages[lvl]->pal_fade : stages[lvl]->pal);
        VDP_setPalette(PAL1, GAME_PAUSE ? spr_palette_fade.data : spr_palette.data);
        SPR_setPosition(&tblSpr[0], 144, GAME_PAUSE ? 108 : VDP_getScreenHeight());                 // Pause msg - Hidden OR Unhidden
    }
}

_voidCallback *VIntCallback ( )
{
	if ( IS_PALSYSTEM || ( !IS_PALSYSTEM && ( vtimer % 6 ) ) )
	{
		psgfx_frame();
	}

	return 0;
}

void _init()
{
    VDP_init();
    VDP_setPlanSize(64, 64);
    VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);
    VDP_setScreenWidth320();
    VDP_loadFont(&custom_font, FALSE);
    SPR_init(0);
	SYS_setInterruptMaskLevel (4);
	SYS_setVIntCallback ((_voidCallback*) VIntCallback);
}




/* **************************************
 *         GAME STARTS HERE!	        *
 ************************************** */
int main()
{
    _init();
    _showScreen(&disclaimer, 3500);
    _showScreen(&nolddor_logo, 3500);

    while(TRUE)
    {
        _title_screen();
        _game();
    };

    return (0);
}
