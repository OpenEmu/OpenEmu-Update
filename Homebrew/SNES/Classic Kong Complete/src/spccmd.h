//sound variables

static unsigned char snes_spc_sync;
static unsigned int  snes_spc_stereo;
static unsigned int  snes_spc_volume;

//APU registers

#define APU0(x)		*((unsigned char*)0x2140)=(x);
#define APU1(x)		*((unsigned char*)0x2141)=(x);
#define APU2(x)		*((unsigned char*)0x2142)=(x);
#define APU3(x)		*((unsigned char*)0x2143)=(x);
#define APU01(x)	*((unsigned int*)0x2140)=(x);
#define APU23(x)	*((unsigned int*)0x2142)=(x);

#define APU0RD		*((unsigned char*)0x2140)
#define APU1RD		*((unsigned char*)0x2141)
#define APU2RD		*((unsigned char*)0x2142)
#define APU3RD		*((unsigned char*)0x2143)
#define APU01RD		*((unsigned int*)0x2140)
#define APU23RD		*((unsigned int*)0x2142)

//command codes

#define SCMD_STEREO			0x0000	//change stereo sound mode
#define SCMD_VOLUME			0x1000	//set global volume
#define SCMD_MUSIC_STOP 	0x2000	//stop music
#define SCMD_MUSIC_PLAY 	0x3000	//start music
#define SCMD_SFX_PLAY		0x4000	//play sound effect
#define SCMD_RELOAD			0x5000	//load new music dara

//command aliases

#define spc_music_stop()		(spc_command(SCMD_MUSIC_STOP,0))
#define spc_music_play()		(spc_command(SCMD_MUSIC_PLAY,0))
#define spc_sfx_play(chn,x,pan)	(spc_command(SCMD_SFX_PLAY|((chn)<<8),(x)|((pan)<<8)))
#define spc_reload()			(spc_command(SCMD_RELOAD,0))



#ifdef SOUND_DISABLE

void spc_command(unsigned int command,unsigned int param) {}
void spc_stereo(unsigned int stereo) {}
void spc_volume(unsigned int volume) {}
void spc_load_data(unsigned int adr,const unsigned char *src,unsigned int size) {}
void spc_setup(void) {}
void spc_load_music(const unsigned char *data,unsigned int size) {}

#else

//send a command to the SPC driver

void spc_command(unsigned int command,unsigned int param)
{
	APU01(command|snes_spc_sync);
	APU23(param);

	if(command!=SCMD_RELOAD)
	{
		while(APU0RD!=snes_spc_sync);
		++snes_spc_sync;
	}
}



//change stereo sound mode

void spc_stereo(unsigned int stereo)
{
	snes_spc_stereo=stereo;
	spc_command(SCMD_STEREO,stereo);
}



//set global sound volume

void spc_volume(unsigned int volume)
{
	if(volume>127) volume=127;
	snes_spc_volume=volume;
	spc_command(SCMD_VOLUME,volume);
}



//upload data into the sound memory using IPL loader

void spc_load_data(unsigned int adr,const unsigned char *src,unsigned int size)
{
	static unsigned char cnt;
	static unsigned int i;

	NMITIMEEN(0);
	
	while(APU01RD!=0xbbaa);//apu ready?

	APU23(adr);//set location
	APU1(1);//not last block
	APU0(0xcc);

	while(APU0RD!=0xcc);//ready?

	cnt=0;

	while(size)
	{
		APU1(*src++);
		APU0(cnt);

		while(APU0RD!=cnt);//ready?
		++cnt;
		--size;
	}

	APU23(0x0200);//startup address
	APU1(0);//run apu code
	APU0(cnt+2);

	snes_spc_sync=cnt;
	
	NMITIMEEN(0x81);
	nmi_wait();
}



//initialize sound, set variables and upload driver code

void spc_setup(void)
{
	snes_spc_stereo=0;
	snes_spc_volume=127;

	spc_load_data(0x0200,spc700_data,spc700_size);
}



//upload music data

void spc_load_music(const unsigned char *data,unsigned int size)
{
	spc_reload();
	spc_load_data(0xe000,data,size);
	spc_stereo(snes_spc_stereo);
	spc_volume(snes_spc_volume);
}

#endif