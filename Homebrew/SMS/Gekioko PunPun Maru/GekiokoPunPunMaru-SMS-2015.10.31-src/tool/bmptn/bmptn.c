/* TAB = 4 spaces */
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dib.h"
#include "bmptn.h"

int	makeType;		/* .ptn or .pal */
	#define MAKE_TYPE_PTN	0
	#define MAKE_TYPE_PAL	1
char *bmpPath;		/* path for bmp file */
char *ptnPath;		/* path for pattern file */
int bmpWidth;		/* pixel width */
int bmpHeight;		/* pixel height */
int ptnHeight[256];	/* pixel height per line */
struct BGRX color[BITMAPCOLORTABLE256_SIZE];	/* color table */
uint8_t	palette[256];	/* VDP Palette */
uint8_t *bmp;		/* pixel array from .bmp */
uint8_t	*ptn;		/* pixel pattern for VDP */
int heightLimit;	/* pixel height limit */
int heightArgCount;	/* number of height arguments */
int argRead;		/* current reading of arguments */

int main(int argc, char *argv[]){
	
	if(argc < 3){
		fprintf(stderr, "Need more arguments.\n");
		exit(EXIT_FAILURE);
	}
	argRead = 1;
	bmpPath = argv[argRead++];
	ptnPath = argv[argRead++];
	heightArgCount = (argc - argRead);
	
	if(checkSuffix()) exit(EXIT_FAILURE);
	if(readBmp()) exit(EXIT_FAILURE);
	if(makeType == MAKE_TYPE_PAL){
		if(writePal()) exit(EXIT_FAILURE);
	}else{
		if(makePtnHeight(argc, argv)) exit(EXIT_FAILURE);
		if(transform()) exit(EXIT_FAILURE);
		if(writePtn()) exit(EXIT_FAILURE);
	}
}
/* check .pal suffix */
int checkSuffix(){
	int c;
	char *p;
	int f;

	makeType = MAKE_TYPE_PTN;
	c = strlen(ptnPath);
	p = ptnPath;
	p += c - 1;
	for(; c > 0; c--){
		if(*p == '.'){
			if(strcmp(p, ".pal") == 0) makeType = MAKE_TYPE_PAL;
			break;
		}
		p--;
	}
	return 0;
}
/* make ptnHeight[] from argv */
int makePtnHeight(int argc, char *argv[]){
	int count;
	int height;
	int h;

	h = 8;
	count = 0;
	for(height = 0; height < bmpHeight; height += h){
		if(count < heightArgCount){
			if(sscanf(argv[argRead++], "%d", &h) != 1){
				fprintf(stderr, "A height argument is not integer.\n");
				return 1;
			}
		}
		if(h < 0){
			fprintf(stderr, "A height argument is minus.\n");
			return 1;
		}
		ptnHeight[count] = h;
		count++;
	}
	return 0;
}
/* read bmp file to "bmp" buffer */
int readBmp(){
	FILE *fp;
	struct BITMAPFILEHEADER bmpFileHeader;
	struct BITMAPINFOHEADER bmpInfoHeader;
	int l;
	int f;

	/* open */
	fp = fopen(bmpPath, "rb");
	if(fp == NULL){
		fprintf(stderr, "Cannot open BMP file: %s\n", bmpPath);
		return 1;
	}

	/* read file header */
	l = fread(&bmpFileHeader, 1, BITMAPFILEHEADER_SIZE, fp);
	if(l != BITMAPFILEHEADER_SIZE){
		fprintf(stderr, "Cannot read file header from BMP file: %s\n", bmpPath);
		fclose(fp);
		return 1;
	}
	/* check info header */
	f = true;
	while(true){
		if(bmpFileHeader.type != BITMAPFILEHEADER_TYPE_BM) break;
		if(bmpFileHeader.offBits < (BITMAPFILEHEADER_SIZE + BITMAPINFOHEADER_SIZE + BITMAPCOLORTABLE256_SIZE)) break;
		if(bmpFileHeader.reserved1 != 0) break;
		if(bmpFileHeader.reserved2 != 0) break;
		f = false;
		break;
	}
	if(f){
		fprintf(stderr, "Incorrect or non-supported format: %s\n", bmpPath);
		fclose(fp);
		return 1;
	}

	/* read info header */
	l = fread(&bmpInfoHeader, 1, BITMAPINFOHEADER_SIZE, fp);
	if(l != BITMAPINFOHEADER_SIZE){
		fprintf(stderr, "Cannot read info header from BMP file: %s\n", bmpPath);
		fclose(fp);
		return 1;
	}
	/* check info header */
	f = true;
	while(true){
		if(bmpInfoHeader.size != BITMAPINFOHEADER_SIZE) break;
		if(bmpInfoHeader.width < 0) break;
		if(bmpInfoHeader.height < 0) break;
		if(bmpInfoHeader.planes != 1) break;
		if(bmpInfoHeader.bitCount != 8) break;
		if(bmpInfoHeader.compression != BITMAPFILEHEADER_BI_RGB) break;
		if(bmpInfoHeader.clrUsed != 256) break;
		f = false;
		break;
	}
	if(f){
		fprintf(stderr, "Incorrect or non-supported format: %s\n", bmpPath);
		fclose(fp);
		return 1;
	}

	bmpWidth = bmpInfoHeader.width & 0xFFFFFFF8;
	bmpHeight = bmpInfoHeader.height & 0xFFFFFFF8;
	if((bmpWidth != bmpInfoHeader.width) || (bmpHeight != bmpInfoHeader.height)){
		fprintf(stderr, "Width or height is not n * 8 pixels: %s\n", bmpPath);
		fclose(fp);
		return 1;
	}

	if(makeType == MAKE_TYPE_PAL){
		/* read color table */
		l = fread(color, 1, BITMAPCOLORTABLE256_SIZE, fp);
		if(l != BITMAPCOLORTABLE256_SIZE){
			fprintf(stderr, "Cannot read color table from BMP file: %s\n", bmpPath);
			fclose(fp);
			return 1;
		}
	}else{
		/* read pixel data */
		bmp = (char *)calloc(bmpWidth * bmpHeight, 1);
		if(bmp == NULL){
			exit(EXIT_FAILURE);
		}
		fseek(fp, bmpFileHeader.offBits, SEEK_SET);
		l = fread(bmp, 1, bmpWidth * bmpHeight, fp);
		if(l != (bmpWidth * bmpHeight)){
			fprintf(stderr, "Cannot read from BMP file: %s\n", bmpPath);
			fclose(fp);
			return 1;
		}
		fclose(fp);

		/* get pattern buffer */
		ptn = (char *)calloc(bmpWidth * bmpHeight, 1);
		if(ptn == NULL){
			exit(EXIT_FAILURE);
		}
	}
	return 0;
}
/* transform bmp to pattern */
int transform(){
	int x;	/* x position for bmp */
	int y;	/* y position for bmp */
	int px;	/* x position for pattern */
	int py;	/* y position for pattern */
	int i;	/* line position for bmp */
	unsigned int d1;	/* pixel data 1st (odd nibble) */
	unsigned int d2;	/* pixel data 2nd (even nibble) */
	unsigned char *p;

	p = ptn;
	y = 0;
	for(i = 0; ptnHeight[i] != 0; i++){
		for(x = 0; x < bmpWidth; x += 8){
			for(py = 0; py < ptnHeight[i]; py++){
				/* bit plane 0 */
				d2 = 0x00;
				for(px = 0; px < 8; px++){
					d2 <<= 1;
					d1 = getPixel(x + px, y + py);
					if(d1 > 255) return 0;
					d2 |= (d1 >> 0) & 0x01;
				}
				*p++ = d2;
				/* bit plane 1 */
				d2 = 0x00;
				for(px = 0; px < 8; px++){
					d2 <<= 1;
					d1 = getPixel(x + px, y + py);
					if(d1 > 255) return 0;
					d2 |= (d1 >> 1) & 0x01;
				}
				*p++ = d2;
				/* bit plane 2 */
				d2 = 0x00;
				for(px = 0; px < 8; px++){
					d2 <<= 1;
					d1 = getPixel(x + px, y + py);
					if(d1 > 255) return 0;
					d2 |= (d1 >> 2) & 0x01;
				}
				*p++ = d2;
				/* bit plane 3 */
				d2 = 0x00;
				for(px = 0; px < 8; px++){
					d2 <<= 1;
					d1 = getPixel(x + px, y + py);
					if(d1 > 255) return 0;
					d2 |= (d1 >> 3) & 0x01;
				}
				*p++ = d2;
			}
		}
		y += ptnHeight[i];
	}
	return 0;
}
/* get a pixel form "bmp" buffer with range out check */
unsigned int getPixel(int x, int y){
	int xy;
	unsigned char *b;

	if((x > bmpWidth) || (y > bmpHeight)){
		fprintf(stderr, "Read error, getPixel function got bad args: x = %d, y = %d", x, y);
		return 256;
	}
	xy = x + ((bmpHeight - 1 - y) * bmpWidth);
	b = bmp;
	b += xy;
	return (unsigned int)(*b & 0x0F);
}
/* create pattern file */
int writePtn(){
	FILE *fp;
	int l;

	fp = fopen(ptnPath, "wb");
	if(fp == NULL){
		fprintf(stderr, "Cannot create pattern file: %s\n", ptnPath);
		return 1;
	}
	l = fwrite(ptn, 1, (bmpWidth * bmpHeight / 2), fp);
	if(l != (bmpWidth * bmpHeight / 2)){
		fprintf(stderr, "Cannot write to pattern file: %s\n", ptnPath);
		fclose(fp);
		return 1;
	}
	fclose(fp);
	return 0;
}

/* create palette file */
int writePal(){
	FILE *fp;
	int l;
	int c;
	int total;
	
	int r;
	int g;
	int b;
	uint8_t v;
	
	/* BMP BGRX (8, 8, 8, 8 = 32bit) to PAL XBGR (2, 2, 2, 2 = 8bit) */
	for(c = 0; c < 256; c++){
		r = color[c].r;
		g = color[c].g;
		b = color[c].b;
		v = ((b & 0xC0) >> 2) | ((g & 0xC0) >> 4) | ((r & 0xC0) >> 6);
		palette[c] = v;
		total += v;
		if((c & 0x0F) == 0x0F){
			if(total == 0){
				c &= 0xF0;
				break;
			}
			total = 0;
		}
	}

	/* create and write */
	fp = fopen(ptnPath, "wb");
	if(fp == NULL){
		fprintf(stderr, "Cannot create palette file: %s\n", ptnPath);
		return 1;
	}
	l = fwrite(palette, 1, c, fp);
	if(l != c){
		fprintf(stderr, "Cannot write to palette file: %s\n", ptnPath);
		fclose(fp);
		return 1;
	}
	fclose(fp);
	return 0;
}
