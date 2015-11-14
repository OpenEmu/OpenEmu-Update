#define BITMAPFILEHEADER_SIZE	14
struct BITMAPFILEHEADER {
	uint16_t	type;
		#define BITMAPFILEHEADER_TYPE_BM	0x4D42
	uint32_t	size;
	uint16_t	reserved1;
	uint16_t	reserved2;
	uint32_t	offBits;
} __attribute__ ((packed)) /* for gcc */;

#define BITMAPINFOHEADER_SIZE	40
struct BITMAPINFOHEADER {
	uint32_t	size;
	int32_t		width;
	int32_t		height;
	uint16_t	planes;
	uint16_t	bitCount;
	uint32_t	compression;
		#define BITMAPFILEHEADER_BI_RGB		0
		#define BITMAPFILEHEADER_BI_RLE8	1
		#define BITMAPFILEHEADER_BI_RLE4	2
	uint32_t	sizeImage;
	int32_t		xPixPerMeter;
	int32_t		yPixPerMeter;
	uint32_t	clrUsed;
	uint32_t	clrImporant;
} __attribute__ ((packed)) /* for gcc */;

#define BITMAPCOLORTABLE256_SIZE	(256 * 4)
struct BGRX {
	uint8_t	b;
	uint8_t	g;
	uint8_t	r;
	uint8_t	x;
} __attribute__ ((packed)) /* for gcc */;




