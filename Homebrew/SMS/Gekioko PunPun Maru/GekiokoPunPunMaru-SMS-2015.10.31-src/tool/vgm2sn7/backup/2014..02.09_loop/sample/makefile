VGM2SN7= /home/mtchocolate/z80/sms/tool/vgm2sn7/vgm2sn7
VGM= $(wildcard *.vgm)
SRC= $(VGM:.vgm=_vgm.c)

all: $(SRC)

%_vgm.c: %.vgm
	$(VGM2SN7) $*_vgm <$< >$*_vgm.c

