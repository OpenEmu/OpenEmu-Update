CC= sdcc
OBJC= objcopy
ASM= as-z80
LD= link-z80
BINHEX= /home/mtchocolate/z80/sms/tool/bin2hex/bin2hex
ADDFILE= /home/mtchocolate/z80/sms/tool/addfile/addfile
VGM2SN7= /home/mtchocolate/z80/sms/tool/vgm2sn7/vgm2sn7
MAP_MD2SMS= /home/mtchocolate/z80/sms/tool/map_md2sms/map_md2sms

#temp files
DELETE= $(wildcard *.sym)
DELETE+= $(wildcard *.lst)
DELETE+= $(wildcard *.sms)
DELETE+= $(wildcard *.asm)	#.s = user created (DO NOT DELETE), .asm = temp file for compiler
DELETE+= $(wildcard *.lnk)
DELETE+= $(wildcard *.map)
DELETE+= $(wildcard *.ihx)
DELETE+= $(wildcard *.hex)
DELETE+= $(wildcard sound/*.sn7)
DELETE+= $(wildcard map/*.map)
DELETE+= $(wildcard bmp/*.ptn)
DELETE+= $(wildcard bmp/*.pal)

VGM= $(wildcard sound/*.vgm)
MAP= $(wildcard map/*.bin)
DAT= $(VGM:.vgm=.sn7)
DAT+= $(MAP:.bin=.map)
DAT+= $(wildcard bmp/*.ptn)
DAT+= $(wildcard bmp/*.pal)

BOOT_S= boot.s				# startup code (MUST SET IT TO ABSOLUTE ADDRESS 0x0000)
SRC_C= $(wildcard *.c)		# c source code
MAP_C= $(wildcard map/*.c)	# VDP pattern name table

OBJ= $(BOOT_S:.s=.o)
OBJ+= $(SRC_C:.c=.o)
OBJ+= $(BMP_C:.c=.o)
OBJ+= $(MAP_C:.c=.o)

LINKOBJ= $(OBJ)

all:	punpun.sms
	cd bmp; make

punpun.sms: punpun.ihx
	$(OBJC) --pad-to 32768 -I ihex -O binary punpun.ihx punpun.sms;
	$(ADDFILE) punpun.sms $(DAT)
	$(BINHEX) punpun.sms punpun.hex

punpun.ihx: $(OBJ) $(DAT)
	$(CC) -mz80 --out-fmt-ihx --opt-code-speed --nostdlib --no-std-crt0 --data-loc 0xC000 -o punpun.ihx $(LINKOBJ)
	$(LD) -nf punpun

%.sn7: %.vgm
	$(VGM2SN7) $< $@

%.map: %.bin
	$(MAP_MD2SMS) $< $@

%.o: %.c
	$(CC) -mz80 -o $@ -c $<

%.o: %.s
	$(ASM) -o $@ $<

clean:
	rm -f $(OBJ) $(DELETE)

