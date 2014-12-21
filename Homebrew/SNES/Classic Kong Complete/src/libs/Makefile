PREFIX=/usr/local/snes-sdk
BINDIR=$(PREFIX)/bin
AS=$(BINDIR)/wla-65816

OBJS = crt0_snes.obj libm.obj libtcc.obj libc.obj

%.obj: %.asm
	$(AS) -io $< $@

all: $(OBJS)

clean:
	rm -f $(OBJS)
