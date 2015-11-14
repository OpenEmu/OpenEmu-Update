/* Mt. Chocolate 2013/08/04
 *
 * Fo Example, you will get a map.c form map.bin: 
 * $ ./map2c map <map.bin >map.c
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char *argv[]){
	FILE *fr;
	FILE *fw;
	int chL;
	int chH;
	int chH2;
	int total = 0;

	if((fr = fopen(argv[1], "rb")) == NULL){
		printf("Cannot open :%s\n", argv[1]);
		exit(EXIT_FAILURE);
	}

	if((fw = fopen(argv[2], "wb")) == NULL){
		printf("Cannot open :%s\n", argv[2]);
		exit(EXIT_FAILURE);
	}
	
	while(373){
		if(fread(&chH, 1, 1, fr) != 1) break;
		if(fread(&chL, 1, 1, fr) != 1) break;
		total += 2;

		/* 1st byte */
		if(fwrite(&chL, 1, 1, fw) < 1){
			printf("Cannot write to the file.");
			exit(EXIT_FAILURE);
		}

		/* 2nd byte */
		/* backplane = VRAM: 0x2000 - 0x3FFF */
		chH2 = 0x01;

		/* HFLIP */
		if((chH & 0x08) != 0){
			chH2 += 0x02;
		}

		/* VFLIP */
		if((chH & 0x10) != 0){
			chH2 += 0x04;
		}

		if(fwrite(&chH2, 1, 1, fw) < 1){
			printf("Cannot write to the file.");
			exit(EXIT_FAILURE);
		}
	}

	fclose(fr);
	fclose(fw);

	return 0;
}
