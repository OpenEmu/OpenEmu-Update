/* ----------------------------------------------------------------------------------- */
#include "sms.h"
#include "psg.h"

/* ----------------------------------------------------------------------------------- */
/*
Volume
bit	7  6  5  4  3  2  1  0
	1  C2 C1 1  D3 D2 D1 D0
Cx	Volume, 0〜2 = Channel A〜C, 3 = Noize
Dx	0〜15 = Volume

Tone
bit	7  6  5  4  3  2  1  0
	1  C2 C1 0  D3 D2 D1 D0
	0  0  D9 D8 D7 D6 D5 D4
Cx	0〜2 = Channel A〜C
Dx	1〜1023 = Tone(0 = 1)

bit	7  6  5  4  3  2  1  0
	1  1  1  0  0 FB NF1 NF0
FB	1 = High F(White), 0 = Low F(Periodic)
NFx	0 = Clock/2, 1 = Clock/4, 2 = Clock/8, 3 = with Channel C

Div = 3579540 / (32 * Tone)
A(440Hz) --> 254.228693 = 3579540 / (32 * 440)

AY-3-8910
A(440Hz) --> 254.228693 = 3579540 / (32 * 440)
*/
/* ----------------------------------------------------------------------------------- */
#define PSG_SET_TONE		(1 << 7)	/* set tone */
#define PSG_SET_VOLUME	((1 << 7) + (1 << 4))	/* set volume */
#define PSG_SET_NOIZE	(7 << 5)	/* set noize freq */
#define PSG_WHITE			(1 << 2)	/* noize feed back */
#define PSG_PERIODIC		(0 << 2)	/* noize feed back */
#define PSG_DIV2			0			/* noize divider is CLK/2 */
#define PSG_DIV4			1			/* noize divider is CLK/4 */
#define PSG_DIV8			2			/* noize divider is CLK/8 */
#define PSG_DIVC			3			/* noize divider uses C channel freq */
#define PSG_A				(0 << 5)	/* select A channel */
#define PSG_B				(1 << 5)	/* select B channel */
#define PSG_C				(2 << 5)	/* select C channel */
#define PSG_N				(3 << 5)	/* select Noize channel */
#define PSG_LOW(a)		(a & 0x0F)	/* set lower 4bit value */
#define PSG_HIGH(a)		(a >> 4)	/* set higher 6bit value */

/* ----------------------------------------------------------------------------------- */
/* for playing command with short name */
#define PSG_SET_TONE_16A(a)	PSG_SET_TONE + PSG_A + PSG_LOW(a), PSG_HIGH(a)
#define PSG_SET_TONE_16B(a)	PSG_SET_TONE + PSG_B + PSG_LOW(a), PSG_HIGH(a)
#define PSG_SET_TONE_16C(a)	PSG_SET_TONE + PSG_C + PSG_LOW(a), PSG_HIGH(a)

/* ----------------------------------------------------------------------------------- */
/* for playing command */
#define PSG_WAIT	0b01000000
#define PSG_STOP	0b01100000	/* for SE */
#define PSG_LOOP	0b01100000	/* for BGM */

/* ----------------------------------------------------------------------------------- */
/* Oct is LSR to high、LSL to low */
#define KEY_C		(3579540 / (32 * 262))
#define KEY_Cs	(3579540 / (32 * 277))
#define KEY_D		(3579540 / (32 * 294))
#define KEY_Ds	(3579540 / (32 * 311))
#define KEY_E		(3579540 / (32 * 330))
#define KEY_F		(3579540 / (32 * 349))
#define KEY_Fs	(3579540 / (32 * 370))
#define KEY_G		(3579540 / (32 * 392))
#define KEY_Gs	(3579540 / (32 * 415))
#define KEY_A		(3579540 / (32 * 440))
#define KEY_As	(3579540 / (32 * 466))
#define KEY_B		(3579540 / (32 * 493))

/* ----------------------------------------------------------------------------------- */
int8u se_wait;		/* wait n + 1 frames */
int8u *se_track;

int8u bgm_wait;		/* wait n + 1 frames */
int8u *bgm_start;	/* start address */
int8u *bgm_current;
int8u bgm_loop;		/* TRUE = loop */
int16u bgm_loop_start;	/* loop start address */

int8u psg_mask[4];	/* 1 = play as SE part */

const int8u	psg_null_se[] = {
	0, 0, 0, 0, 
	PSG_SET_VOLUME + PSG_A + 15,
	PSG_SET_VOLUME + PSG_B + 15,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_SET_VOLUME + PSG_N + 15,
	PSG_WAIT,
	PSG_STOP
};
const int8u	psg_null_bgm[] = {
	9, 0, 
	PSG_SET_VOLUME + PSG_A + 15,
	PSG_SET_VOLUME + PSG_B + 15,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_SET_VOLUME + PSG_N + 15,
	PSG_WAIT,
	PSG_LOOP
};
/* ----------------------------------------------------------------------------------- */
void psg_init(){
	psg_set_se(psg_null_se);
	psg_set_bgm(psg_null_bgm, TRUE);
	psg_play();
}
void psg_play(){
	psg_play_se();
	psg_play_bgm();
}
void psg_stop(){
	psg_init();
}
void psg_set_se(int8u *stream){
	int8u *p;

	p = psg_mask;
	if(*p++ != 0) PSG_PORT = PSG_SET_VOLUME + PSG_A + 15;
	if(*p++ != 0) PSG_PORT = PSG_SET_VOLUME + PSG_B + 15;
	if(*p++ != 0) PSG_PORT = PSG_SET_VOLUME + PSG_C + 15;
	if(*p++ != 0) PSG_PORT = PSG_SET_VOLUME + PSG_N + 15;

	p = psg_mask;
	*p++ = *stream++;	/* channel A mask */
	*p++ = *stream++;	/* channel B mask */
	*p++ = *stream++;	/* channel C mask */
	*p++ = *stream++;	/* channel N mask */
	se_track = stream;
}
void psg_play_se(){
	int8u *stream;
	int8u d;

	if(se_wait != 0){
		se_wait--;
		return;
	}

	stream = se_track;
	while(373){
		d = *stream++;
		if((d & 0b10000000) != 0){
			/* write single or low byte command */
			PSG_PORT = d;
		}else{
			if((d & 0b01000000) == 0){
				/* write high byte command */
				PSG_PORT = d;
			}else{
				if((d & 0b00100000) == 0){
					/* wait command */
					se_wait = d & 0b00011111;
					se_track = stream;
					break;
				}else{
					/* stop command */
					se_track = --stream;
					psg_mask[0] = 0;
					psg_mask[1] = 0;
					psg_mask[2] = 0;
					psg_mask[3] = 0;
					break;
				}
			}
		}
	}
}
void psg_set_bgm(int8u *stream, int8u loop){
	PSG_PORT = PSG_SET_VOLUME + PSG_A + 15;
	PSG_PORT = PSG_SET_VOLUME + PSG_B + 15;
	PSG_PORT = PSG_SET_VOLUME + PSG_C + 15;
	PSG_PORT = PSG_SET_VOLUME + PSG_N + 15;

	bgm_loop = loop;
	bgm_wait = 0;

	/* as loop start */
	bgm_start = stream;
	bgm_start += *(int16u *)bgm_start;

	/* curent address */
	bgm_current = stream;
	bgm_current += 2;
}
void psg_play_bgm(){
	int8u *stream;
	int8u d;
	int8u c;

	if(bgm_wait != 0){
		bgm_wait--;
		return;
	}

	stream = bgm_current;
	while(373){
		d = *stream++;
		if((d & 0b10000000) != 0){
			/* write single or low byte command */
			c = d >> 5 & 0x03;
			if(psg_mask[c] == 0){
				PSG_PORT = d;
			}
		}else{
			if((d & 0b01000000) == 0){
				/* write high byte */
				c = *stream >> 5 & 0x03;	/* c = channel number */
				if(psg_mask[c] == 0){
					PSG_PORT = d;
				}
			}else{
				if((d & 0b00100000) == 0){
					/* wait command */
					bgm_wait = d & 0b00011111;
					bgm_current = stream;
					break;
				}else{
					if(bgm_loop == TRUE){
						/* loop command */
						bgm_current = bgm_start;
					}else{
						/* stop command */
						stream--;
					}
					break;
				}
			}
		}
	}
}
/* ----------------------------------------------------------------------------------- */
/* 1st row = Channel Mask A, B, C, N */
/* other rows = data for a SN76489 */
const int8u	psg_score[] = {
	0, 0, 1, 0, 
	PSG_SET_TONE_16C(KEY_A >> 2),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_STOP
};
const int8u	psg_punch[] = {
	0, 0, 1, 0, 
	PSG_SET_TONE_16C(KEY_Ds << 1),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_Cs << 1),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_B << 2),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_A << 2),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 2,
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 4,
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 7,
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 11,
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_STOP
};
const int8u	psg_eat[] = {
	0, 0, 1, 0, 
	PSG_SET_TONE_16C(KEY_A),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 8,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_F),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 12,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_A),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 14,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_C << 1),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_STOP
};
const int8u	psg_damage[] = {
	0, 0, 1, 0, 
	PSG_SET_TONE_16C(KEY_A << 2),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_F << 1),
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_G << 1),
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_A >> 1),
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_G >> 1),
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_Ds >> 1),
	PSG_WAIT + 1,
	PSG_SET_TONE_16C(KEY_Cs >> 1),
	PSG_WAIT + 1,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_STOP
};
const int8u	psg_jump[] = {
	0, 0, 1, 0, 
	PSG_SET_TONE_16C(KEY_A >> 0),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_As >> 0),
	PSG_SET_VOLUME + PSG_C + 0,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 2,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_B >> 0),
	PSG_SET_VOLUME + PSG_C + 4,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 6,
	PSG_WAIT,
	PSG_SET_TONE_16C(KEY_C >> 1),
	PSG_SET_VOLUME + PSG_C + 8,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 10,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 11,
	PSG_WAIT,
	PSG_SET_VOLUME + PSG_C + 15,
	PSG_WAIT,
	PSG_STOP
};
/* ----------------------------------------------------------------------------------- */

