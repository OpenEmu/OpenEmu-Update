
CC = ../wla_dx_9.5/binaries/wla-z80
CFLAGS = -o
LD = ../wla_dx_9.5/binaries/wlalink
LDFLAGS = -vds

SFILES = main.asm
IFILES = fnc_init.inc fnc_sound.inc fnc_sprites.inc fnc_demo.inc data_demo.inc fnc_game.inc fnc_loop.inc data_game.inc data_jmimu.inc fnc_text.inc level10.inc level1.inc level2.inc level5.inc fnc_ingame.inc menu.inc end.inc
OFILES = main.o

all: $(OFILES) $(OFILES) makefile
	$(LD) $(LDFLAGS) linkfile rom.sms

main.o: main.asm $(IFILES)
	$(CC) $(CFLAGS) main.asm main.o


$(OFILES): $(HFILES)


clean:
	rm -f $(OFILES) core *~ rom.sms linked.sym
