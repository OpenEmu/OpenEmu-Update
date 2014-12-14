path=path;..\bin\
set CC65_HOME=g:\cc65
cc65 -Oi game.c
ca65 crt0.s
ca65 game.s
ca65 neslib.s
ld65 -C nes.cfg -o game.nes crt0.o neslib.o game.o nes.lib
pause
del *.o
del game.s
game.nes