@echo off
path=path;c:\cc65\bin\
set CC65_HOME=c:\cc65\
echo Exporting chr
cd ..\gfx
nescnv tileset-import.png
copy tileset.chr ..\dev
echo Making map
cd ..\map
mapcnvnes mapa.map 256 3
copy map.h ..\dev
copy bolts.h ..\dev
copy objs.h ..\dev
cd ..\dev
cc65 -Oi game.c --add-source
ca65 crt0.s
ca65 game.s
ld65 -v -C nes.cfg -o ababol.nes crt0.o game.o runtime.lib
pause
del *.o
del game.s
