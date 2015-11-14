/* ----------------------------------------------------------------------------------- */
#define int8		char
#define int8u		unsigned char
#define int16		int
#define int16u	unsigned int
#define TRUE		1
#define FALSE		0
#define ERROR		(-1)

/* ----------------------------------------------------------------------------------- */
sfr at 0x3E MAPPER_CTRL;
	#define EXP_SLOT_ENABLE	7
	#define CART_SLOT_ENABLE	6
	#define CARD_SLOT_DISABLE	5
	#define WRAM_DISABLE	4
	#define BIOS_DISABLE	3
	#define IO_DISABLE	2
	/* standard value for game cart is 0xAB */

/* ----------------------------------------------------------------------------------- */
extern void sms_init();
extern int8u rnd();

/* ----------------------------------------------------------------------------------- */

