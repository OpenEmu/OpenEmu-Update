BMPTN= /home/mtchocolate/z80/sms/tool/bmptn/bmptn
BMP= $(wildcard *.bmp)
FILE= $(BMP:.bmp=.ptn)
FILE+= $(BMP:.bmp=.pal)

all: $(FILE)

sp_castle.ptn: sp_castle.bmp
	$(BMPTN) $< $@ 24 16 16 16 24 16 16 24 16 16 16 24 16 16

sp_summer.ptn: sp_summer.bmp
	$(BMPTN) $< $@ 24 16 16 16 24 16 16 24 16 16 16 24 16 16

title.ptn: title.bmp
	$(BMPTN) $< $@ 8

castle.ptn: castle.bmp
	$(BMPTN) $< $@ 8

summer.ptn: summer.bmp
	$(BMPTN) $< $@ 8

jungle.ptn: jungle.bmp
	$(BMPTN) $< $@ 8

winter.ptn: winter.bmp
	$(BMPTN) $< $@ 8

font.ptn: font.bmp
	$(BMPTN) $< $@ 8

%.pal: %.bmp
	$(BMPTN) $< $@

clean:
	rm -f $(FILE)

