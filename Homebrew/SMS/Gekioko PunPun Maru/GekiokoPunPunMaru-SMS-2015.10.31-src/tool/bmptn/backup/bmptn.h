int checkSuffix();	/* check .pal suffix */
int makePtnHeight(int argc, char *argv[]);	/* make ptnHeight[] from argv */
int readBmp();		/* read bmp file to "bmp" buffer */
int transform();	/* transform bmp to pattern */
unsigned int getPixel(int x, int y);	/* get a pixel form "bmp" buffer with range out check */
int writePtn();		/* create pattern file */
int writePal();		/* create palette file */

