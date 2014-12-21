@echo off

rem convert all graphics

path=path;tools\
del gfx\*.chr >nul
del gfx\*.pal >nul
snesbmp gfx\font.bmp -b
snesbmp gfx\tileset1.bmp -b
snesbmp gfx\tileset1alt1.bmp -b
snesbmp gfx\tileset1alt2.bmp -b
snesbmp gfx\tileset2.bmp -b
snesbmp gfx\tileset2alt.bmp -b
snesbmp gfx\sprites1.bmp -b
snesbmp gfx\sprites2.bmp -b
snesbmp gfx\sprites3.bmp -b
snesbmp gfx\sprites4.bmp -b
snesbmp gfx\sprites5.bmp -b
snesbmp gfx\sprites5alt.bmp -b
snesbmp gfx\sprites6.bmp -b
snesbmp gfx\title_top.bmp -b
snesbmp gfx\title_bottom.bmp -b
snesbmp gfx\back1.bmp -b
snesbmp gfx\bubblezaplogo.bmp -b -256
del gfx\tileset1alt*.chr >nul
del gfx\sprites5alt.chr >nul

rem convert music and sfx

xm2data sound\music_title.xm
xm2data sound\music_game_start.xm
xm2data sound\music_stage_start.xm
xm2data sound\music_stage_clear.xm
xm2data sound\music_hammer.xm
xm2data sound\music_level1.xm
xm2data sound\music_lose.xm
xm2data sound\music_time_out.xm
xm2data sound\music_victory.xm
xm2data sound\sounds.xm -s