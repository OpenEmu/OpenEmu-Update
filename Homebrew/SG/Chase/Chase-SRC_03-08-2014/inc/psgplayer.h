#ifndef _PSGPLAYER_H_
#define _PSGPLAYER_H_

    //== DEFINES
    #define PSG_DATA 0xc00011
    #define PSG_VCH_MAX	4
    #define SFX_ALL_COLLECTED 	0
    #define SFX_ITEM        	1
    #define SFX_KILL        	2
    #define SFX_PAUSE       	3
    #define SFX_RESPAWN_1   	4
    #define SFX_RESPAWN_2   	5
    #define SFX_RESPAWN_3   	6
    #define SFX_RESPAWN_4   	7
    #define SFX_START       	8

    //== TYPES
    typedef struct
    {
        u8  title[16];
        u8 *data;
        u8  num;
    } PSG;

    static struct
    {
        const u8 *data;

        struct
        {
            struct
            {
                s16 ptr;
                s16 wait;
                s16 time;
                u16 div;
                u8 vol;

            } slot[PSG_VCH_MAX];

        } chn[4];

    } PSGFX;

    //== PROTOTYPES
    void psgfx_play ( u16 psg );
    void psgfx_frame ( void );

#endif
