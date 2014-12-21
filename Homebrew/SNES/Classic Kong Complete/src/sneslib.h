#include <string.h>

extern void* __nmi_handler;

//aliases for the SNES hardware registers

#define INIDISP(x)			*((unsigned char*)0x2100)=(x);
#define OBSEL(x)			*((unsigned char*)0x2101)=(x);
#define OAM_ADDR(x)			*((unsigned short*)0x2102)=(x);
#define BGMODE(x)			*((unsigned char*)0x2105)=(x);
#define MOSAIC(x)			*((unsigned char*)0x2106)=(x);
#define BG1SC(x)			*((unsigned char*)0x2107)=(x);
#define BG2SC(x)			*((unsigned char*)0x2108)=(x);
#define BG3SC(x)			*((unsigned char*)0x2109)=(x);
#define BG4SC(x)			*((unsigned char*)0x210a)=(x);
#define BG12NBA(x)			*((unsigned char*)0x210b)=(x);
#define BG34NBA(x)			*((unsigned char*)0x210c)=(x);
#define BG1HOFFS(x)			*((unsigned char*)0x210d)=(x);
#define BG1VOFFS(x)			*((unsigned char*)0x210e)=(x);
#define BG2HOFFS(x)			*((unsigned char*)0x210f)=(x);
#define BG2VOFFS(x)			*((unsigned char*)0x2110)=(x);
#define BG3HOFFS(x)			*((unsigned char*)0x2111)=(x);
#define BG3VOFFS(x)			*((unsigned char*)0x2112)=(x);
#define BG4HOFFS(x)			*((unsigned char*)0x2113)=(x);
#define BG4VOFFS(x)			*((unsigned char*)0x2114)=(x);
#define VRAM_ADDR(x)		*((unsigned short*)0x2116)=(x);
#define W12SEL(x)			*((unsigned char*)0x2123)=(x);
#define W34SEL(x)			*((unsigned char*)0x2124)=(x);
#define WOBJSEL(x)			*((unsigned char*)0x2125)=(x);
#define WH0(x)				*((unsigned char*)0x2126)=(x);
#define WH1(x)				*((unsigned char*)0x2127)=(x);
#define WH2(x)				*((unsigned char*)0x2128)=(x);
#define WH3(x)				*((unsigned char*)0x2129)=(x);
#define WBGLOG(x)			*((unsigned char*)0x212a)=(x);
#define WOBJLOG(x)			*((unsigned char*)0x212b)=(x);
#define TM(x)				*((unsigned char*)0x212c)=(x);
#define TS(x)				*((unsigned char*)0x212d)=(x);
#define CGWSEL(x)			*((unsigned char*)0x2130)=(x);
#define CGADSUB(x)			*((unsigned char*)0x2131)=(x);
#define COLDATA(x)			*((unsigned char*)0x2132)=(x);
#define STAT78()			*((unsigned char*)0x213f)

#define WRAM_ADDR(x)		*((unsigned char*)0x2181)= (x)     &0xff; \
							*((unsigned char*)0x2182)=((x)>>8 )&0xff; \
							*((unsigned char*)0x2183)=((x)>>16)&0xff;

#define NMITIMEEN(x)		*((unsigned char*)0x4200)=(x);
#define MEMSEL(x)			*((unsigned char*)0x420d)=(x);
#define HVBJOY()			*((unsigned char*)0x4212)
#define JOY_RD(x)			((unsigned short*)0x4218)[(x)]

#define DMA_TYPE(chn,x)		*((unsigned short*)(0x4300|((chn)<<4)))=(x);
#define DMA_ADDR(chn,x)		*((void**)         (0x4302|((chn)<<4)))=(x);
#define DMA_SIZE(chn,x)		*((unsigned short*)(0x4305|((chn)<<4)))=(x);

#define MDMAEN(x)			*((unsigned char*)0x420b)=(x);
#define HDMAEN(x)			*((unsigned char*)0x420c)=(x);


//variables for this basic hardware abstract layer

static unsigned int  snes_joypad_state[2];
static unsigned int  snes_joypad_state_prev[2];
static unsigned int  snes_joypad_state_trigger[2];
static unsigned int  snes_frame_cnt;
static unsigned int  snes_rand_seed1;
static unsigned int  snes_rand_seed2;
static unsigned int  snes_palette[256];
static unsigned char snes_oam[128*4+32];
static unsigned int  snes_ntsc;
static unsigned int  snes_skip_cnt;


//aliases for pad buttons

#define PAD_R		0x0010
#define PAD_L		0x0020
#define PAD_X		0x0040
#define PAD_A		0x0080
#define PAD_RIGHT	0x0100
#define PAD_LEFT	0x0200
#define PAD_DOWN	0x0400
#define PAD_UP		0x0800
#define PAD_START	0x1000
#define PAD_SELECT	0x2000
#define PAD_Y		0x4000
#define PAD_B		0x8000


//macro for sprite attributes

#define SPR_PAL(x)	(((x)&7)<<9)
#define SPR_PRI(x)	((x)<<12)
#define SPR_HFLIP	0x4000
#define SPR_VFLIP	0x8000

//macro for background attributes

#define BG_PAL(x)	(((x)&7)<<10)
#define BG_PRI		0x2000
#define BG_HFLIP	0x4000
#define BG_VFLIP	0x8000

//masks for R5G5B5 components

#define R_MASK		0x001f
#define G_MASK		0x03e0
#define B_MASK		0x7c00


#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	1
#endif



//16-bit random number generaton

unsigned int rand(void)
{
	snes_rand_seed1+=(snes_rand_seed2>>1);
	snes_rand_seed2-=(15^snes_rand_seed1);

	return snes_rand_seed1;
}



//nmi handler, updates sprites list through DMA every frame

void nmi_handler(void)
{
	static unsigned int i;

	OAM_ADDR(0);		//dma oam
	DMA_TYPE(7,0x0400);
	DMA_ADDR(7,snes_oam);
	DMA_SIZE(7,0x0220);
	MDMAEN(1<<7);

	++snes_frame_cnt;
}



//wait for the next TV frame

void nmi_wait(void)
{
	static unsigned int i;

	i=snes_frame_cnt;

	while(i==snes_frame_cnt);
}


/*
//wait for the next virtual 50 Hz frame, skips every sixth frame on NTSC

void nmi_wait50(void)
{
	nmi_wait();

	if(snes_ntsc)
	{
		++snes_skip_cnt;

		if(snes_skip_cnt==5)
		{
			snes_skip_cnt=0;
			nmi_wait();
		}
	}
}
*/


//poll pad ports registers and remember their state
//also polls buttons in trigger mode, bit is set only when a button is pressed, and reset the next frame

void pad_read_ports(void)
{
	static unsigned int i,j;

	while(HVBJOY()&0x01);//wait while joypad is ready

	for(i=0;i<2;++i)
	{
		j=JOY_RD(i);//read joypads

		snes_joypad_state[i]=j;
		snes_joypad_state_trigger[i]=(j^snes_joypad_state_prev[i])&j;
		snes_joypad_state_prev[i]=j;
	}
}



//get previously remembered pad state

unsigned int pad_poll(unsigned char j)
{
	return snes_joypad_state[j];
}



//get previously remembered pad trigger state

unsigned int pad_poll_trigger(unsigned char j)
{
	return snes_joypad_state_trigger[j];
}



//set few entries of the RAM copy of the palette

void set_palette(unsigned int i,unsigned int len,const unsigned int *src)
{
	memcpy(&snes_palette[i],src,len*sizeof(unsigned int));
}



//set an entry of the RAM copy of the palette

void set_color(unsigned int i,unsigned int col)
{
	snes_palette[i]=col;
}



//update the palette in the VRAM from the RAM copy

void update_palette(void)
{
	DMA_TYPE(7,0x2200);	//dma palette
	DMA_ADDR(7,snes_palette);
	DMA_SIZE(7,0x200);
	MDMAEN(1<<7);
}



//copy data from RAM or ROM to the VRAM through DMA

void copy_to_vram(unsigned int adr,const unsigned char *src,unsigned int size)
{
	VRAM_ADDR(adr);
	DMA_TYPE(7,0x1801);
	DMA_ADDR(7,(unsigned char*)src);
	DMA_SIZE(7,size);
	MDMAEN(1<<7);
}



//copy data from VRAM to RAM or ROM through DMA

void copy_from_vram(unsigned int adr,const unsigned char *src,unsigned int size)
{
	volatile unsigned short dummy;

	VRAM_ADDR(adr);

	dummy=*(unsigned short*)0x2139;

	DMA_TYPE(7,0x3981);
	DMA_ADDR(7,(unsigned char*)src);
	DMA_SIZE(7,size);
	MDMAEN(1<<7);
}



//fill VRAM with a value through DMA

void fill_vram(unsigned int adr,const unsigned char value,unsigned int size)
{
	VRAM_ADDR(adr);
	DMA_TYPE(7,0x1809);
	DMA_ADDR(7,&value);
	DMA_SIZE(7,size);
	MDMAEN(1<<7);
}



//copy data from ROM to RAM or vice versa through DMA (RAM-RAM copy is not possible)

void copy_mem(unsigned char *dst,unsigned char *src,unsigned int size)
{
	WRAM_ADDR(((unsigned long)dst));
	DMA_TYPE(7,0x8000);
	DMA_ADDR(7,(unsigned char*)src);
	DMA_SIZE(7,size);
	MDMAEN(1<<7);
}



//set brightness, also enables and disables rendering

void set_bright(unsigned int i)
{
	if(!i) i=0x80;
	INIDISP(i);
}



//set scroll registers for specified layer

void set_scroll(unsigned int layer,unsigned int x,unsigned int y)
{
	switch(layer)
	{
	case 0:
		BG1HOFFS(x&255);
		BG1HOFFS(x>>8);
		BG1VOFFS(y&255);
		BG1VOFFS(y>>8);
		break;

	case 1:
		BG2HOFFS(x&255);
		BG2HOFFS(x>>8);
		BG2VOFFS(y&255);
		BG2VOFFS(y>>8);
		break;

	case 2:
		BG3HOFFS(x&255);
		BG3HOFFS(x>>8);
		BG3VOFFS(y&255);
		BG3VOFFS(y>>8);
		break;

	case 3:
		BG4HOFFS(x&255);
		BG4HOFFS(x>>8);
		BG4VOFFS(y&255);
		BG4VOFFS(y>>8);
		break;
	}
}



//set pixelize effect
//0 off, 1..16 min to max

void set_pixelize(unsigned int i)
{
	if(i) i=((16-i)<<4)|0x0f;
	MOSAIC(i);
}



//set a sprite in the OAM buffer
//this function allows to set complete X value, but works slowly

void oam_spr(unsigned int x,unsigned int y,unsigned int chr,unsigned int off)
{
	static unsigned int offx;

	snes_oam[off+0]=x;
	snes_oam[off+1]=y;
	snes_oam[off+2]=chr;
	snes_oam[off+3]=chr>>8;

	offx=512+(off>>4);

	switch(off&0x0c)
	{
	case 0x00:
		snes_oam[offx]=(snes_oam[offx]&0xfe)|((x>>8)&0x01);
		break;
	case 0x04:
		snes_oam[offx]=(snes_oam[offx]&0xfb)|((x>>6)&0x04);
		break;
	case 0x08:
		snes_oam[offx]=(snes_oam[offx]&0xef)|((x>>4)&0x10);
		break;
	case 0x0c:
		snes_oam[offx]=(snes_oam[offx]&0xbf)|((x>>2)&0x40);
		break;
	}
}



//set a sprite in the OAM buffer
//this function only sets LSB of X, but works much faster
/*
void oam_spr1(unsigned int x,unsigned int y,unsigned int chr,unsigned int off)
{
	snes_oam[off+0]=x;
	snes_oam[off+1]=y;
	snes_oam[off+2]=chr;
	snes_oam[off+3]=chr>>8;
}
*/
#define oam_spr1(x,y,chr,off) snes_oam[(off)+0]=(x); \
							  snes_oam[(off)+1]=(y); \
							  snes_oam[(off)+2]=(chr); \
							  snes_oam[(off)+3]=(chr)>>8;


//set size bits of a sprite in the OAM buffer

//set size bits of a sprite in the OAM buffer

void oam_size(unsigned int off,unsigned int size)
{
	static unsigned int offx;
	static unsigned char c;

	offx=512+(off>>4);
	c=snes_oam[offx];

	switch((off>>2)&3)
	{
	case 0: c=(c&0xfd)|(size<<1); break;
	case 1: c=(c&0xf7)|(size<<3); break;
	case 2: c=(c&0xdf)|(size<<5); break;
	case 3: c=(c&0x7f)|(size<<7); break;
	}

	snes_oam[offx]=c;
}



//clear the OAM buffer

void oam_clear(void)
{
	static unsigned int i;

	for(i=0;i<512;i+=4)
	{
		oam_spr(0,240,0,i);
		oam_size(i,0);
	}
}



//wait for specified number of TV frames

void delay(unsigned int i)
{
	while(--i) nmi_wait();
}



//initialize the hardware

void init(void)
{
	static unsigned int i;

	__nmi_handler=nmi_handler;

	snes_frame_cnt=0;
	snes_rand_seed1=1;
	snes_rand_seed2=5;
	snes_ntsc=STAT78()&0x10?0:1;
	snes_skip_cnt=0;

	//VRAM offsets are in words, so 64K = $8000

	BGMODE(2+8);	//mode 2, 2 layers, 16+16 colors
	BG1SC(0<<2);	//32x32 nametable at $0000
	BG2SC(1<<2);	//32x32 nametable at $0400
	BG3SC(31<<2);	//offsets table $7c00
	BG12NBA(0x40);	//patterns for layers 1 at $0000, 2 at $4000
	BG34NBA(0x44);	//patterns for layers 3 and 4 at $4000
	TM(0x13);		//enable sprites and background
	OBSEL(1);		//sprite sizes 8x8 and 16x16, graphics at $2000
	MEMSEL(1);		//FastROM enable

	CGWSEL(0x00);
	CGADSUB(0x82);

	for(i=0;i<4;++i) set_scroll(i,0,0);

	for(i=0;i<2;++i)
	{
		snes_joypad_state[i]=0;
		snes_joypad_state_prev[i]=0;
		snes_joypad_state_trigger[i]=0;
	}

	set_bright(0);
	oam_clear();

	NMITIMEEN(0x81);//enable NMI and joypad
}
