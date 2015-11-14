/* Mt. Chocolate 2013/12/13
 *
 * Fo Example, you will get a title.sn7 form title.vgm: 
 * $ ./vgm2sn7 title.vgm title.sn7
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define BUFFER_LENGTH	(1024 * 64)
uint8_t vgm_buffer[BUFFER_LENGTH];
int vgm_length;

uint8_t sn7_buffer[BUFFER_LENGTH];
int sn7_length;

int read_vgm(char *file_name, uint8_t *buffer);
void write_sn7(char *file_name, uint8_t *buffer, int length);
int convert_vgm(uint8_t *vgm, int vgm_length, uint8_t *sn7);

int main(int argc, char *argv[]){
	/* arg check */
	if(argc < 3){
		printf("more arguments are needed\n");
		exit(EXIT_FAILURE);
	}

	/* read vgm */
	vgm_length = read_vgm(argv[1], vgm_buffer);

	/* vgm to sn7 */
	sn7_length = convert_vgm(vgm_buffer, vgm_length, sn7_buffer);
	
	/* output sn7 as c source code */
	write_sn7(argv[2], sn7_buffer, sn7_length);

	printf("vgm = %d, sn7 = %d\n", vgm_length, sn7_length);
	return 0;
}
int read_vgm(char *file_name, uint8_t *buffer){
	FILE *fp;
	int data;
	int length;

	if((fp = fopen(file_name, "rb")) == NULL){
		printf("Cannot open :%s\n", file_name);
		exit(EXIT_FAILURE);
	}

	length = 0;
	while(fread(&data, 1, 1, fp) == 1){
		*buffer++ = data;
		length++;
		if(length > BUFFER_LENGTH){
			printf("warning, buffer overflow has occured at read the VGM file.\n");
			break;
		}
	}
	fclose(fp);

	return length;
}
void write_sn7(char *file_name, uint8_t *buffer, int length){
	FILE *fp;

	if((fp = fopen(file_name, "wb")) == NULL){
		printf("Cannot open :%s\n", file_name);
		exit(EXIT_FAILURE);
	}

	if(fwrite(buffer, 1, length, fp) < length){
		printf("Cannot write :%s\n", file_name);
		exit(EXIT_FAILURE);
	}
	fclose(fp);
}
#define VGM_GG_STEREO	0x4F
#define VGM_PSG_WRITE	0x50
#define VGM_WAIT_60		0x62
#define VGM_WAIT_50		0x63
#define VGM_WAIT_LONG	0x61
#define VGM_WAIT_SHORT	0x70	/* 0x7n, n = 0 to 15 samples (not frame) */
#define VGM_END			0x66
/* return value is length of the created sn7 */
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
