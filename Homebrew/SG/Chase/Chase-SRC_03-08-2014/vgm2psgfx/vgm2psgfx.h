#ifndef _VGM2PSGFX_H_
#define _VGM2PSGFX_H_

	//== INCLUDE
	#include "sfx_all_collected.h"
	#include "sfx_item.h"
	#include "sfx_kill.h"
	#include "sfx_pause.h"
	#include "sfx_respawn_1.h"
	#include "sfx_respawn_2.h"
	#include "sfx_respawn_3.h"
	#include "sfx_respawn_4.h"
	#include "sfx_start.h"


	//== GLOBAL DATA
    static const PSG _list [] =
    {
        { "All Collected",   (u8*) sfx_all_collected_data,      0 },
        { "Item",    		(u8*) sfx_item_data,   		        0 },
        { "Kill",    		(u8*) sfx_kill_data,        		0 },
        { "Pause",    		(u8*) sfx_pause_data,     		    0 },
        { "Respawn 1",    	(u8*) sfx_respawn_1_data,           0 },
        { "Respawn 2",    	(u8*) sfx_respawn_2_data,           0 },
        { "Respawn 3",    	(u8*) sfx_respawn_3_data,           0 },
        { "Respawn 4",    	(u8*) sfx_respawn_4_data,           0 },
        { "Start",          (u8*) sfx_start_data,               0 },

        { "EOF",            NULL,                               0 } /* DON'T REMOVE */
    };

#endif
