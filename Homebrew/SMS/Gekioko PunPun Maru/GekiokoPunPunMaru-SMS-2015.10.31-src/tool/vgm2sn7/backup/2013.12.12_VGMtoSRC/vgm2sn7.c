/* Mt. Chocolate 2013/09/08
 *
 * Fo Example, you will get a map.c form map.bin: 
 * $ ./vgm2sn7 bgm <bgm.bin >bgm.c
 *
 */
#include <stdio.h>
#include <stdint.h>

#define BUFFER_LENGTH	(1024 * 64)
uint8_t vgm_buffer[BUFFER_LENGTH];
uint8_t sn7_buffer[BUFFER_LENGTH];

void out_array(uint8_t *binary, int length);
int convert_vgm(uint8_t *vgm, int vgm_length, uint8_t *sn7);

int main(int argc, char *argv[]){
	int d;

	uint8_t *vgm;
	int vgm_length;

	uint8_t *sn7;
	int sn7_length;

	/* arg check */
	if(argc > 1){
		printf("const unsigned char %s[] %s= {\n", argv[1], argc > 2 ? argv[2] : "");
	}

	/* read vgm */
	vgm = vgm_buffer;
	vgm_length = 0;
	while(373){
		d = getchar();
		if(d == EOF) break;
		*vgm++ = d;
		vgm_length++;
	}

	/* vgm to sn7 */
	sn7_length = convert_vgm(vgm_buffer, vgm_length, sn7_buffer);
	
	/* output sn7 as c source code */
	out_array(sn7_buffer, sn7_length);

	if (argc > 1){
		printf("const int %s_size = %d;\n\n", argv[1], sn7_length);
	}
	return 0;
}
void out_array(uint8_t *binary, int length){
	int c;
	int d;
	
	while(373){
		printf("\t");
		for(c = 16; c > 0; c--){
			if(length == 0){
				printf("};\n");
				return;
			}
			d = *binary++;
			printf("0x%02X,", d);
			length--;
		}
		printf("\n");
	}
}
#define VGM_GG_STEREO	0x4F
#define VGM_PSG_WRITE	0x50
#define VGM_WAIT_60		0x62
#define VGM_WAIT_50		0x63
#define VGM_WAIT_LONG	0x61
#define VGM_WAIT_SHORT	0x70	/* 0x7n, n = 0 to 15 samples (not frame) */
#define VGM_END			0x66
/* return value is the sn7 size */
int convert_vgm(uint8_t *vgm, int vgm_length, uint8_t *sn7){
	int d;
	int c;
	int cmd;
	int length;

	vgm += 0x40;
	length = 0;
	for(c = vgm_length; c > 0; c--){
		cmd = *vgm++;
		switch(cmd){
		case VGM_GG_STEREO:
			vgm++;
			break;
		case VGM_PSG_WRITE:
			d = *vgm++;
			if((d & 0b10000000) == 0){
				d &= 0b00111111;
			}
			*sn7++ = d;
			length++;
			break;
		case VGM_WAIT_60:
		case VGM_WAIT_50:
			*sn7++ = 0b01000000 + 0;	/* wait next frame */
			length++;
			break;
		case VGM_WAIT_LONG:
			d = *vgm++;
			d += ((int)(*vgm++) << 8);
			d /= (882 / 50);
			d &= 0x001F;
			if(d > 0){
				*sn7++ = 0b01000000 + d;
				length++;
			}
			break;
		case VGM_END:
			/* end of the stream */
			*sn7++ = 0b01100000;
			length++;
			return length;
		default:
			if((cmd & 0xF0) == VGM_WAIT_SHORT){
				d = (cmd & 0x0F);
				d /= (882 / 50);
				d &= 0x001F;
				if(d > 0){
					*sn7++ = 0b01000000 + d;
					length++;
				}
				break;
			}else{
				printf("[IGNORE 0x%02X],", d);
				break;
			}
		}
	}
	/* end of the stream */
	*sn7++ = 0b01100000;
	length++;
	return length;
}

