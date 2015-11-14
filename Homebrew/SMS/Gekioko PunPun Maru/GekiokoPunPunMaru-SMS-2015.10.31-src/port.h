/* ----------------------------------------------------------------------------------- */
sfr at 0x3F PORT_CTRL;
	#define PORTB_TH_OUT	7	/* 1 = HIGH */
	#define PORTB_TR_OUT	6
	#define PORTA_TH_OUT	5
	#define PORTA_TR_OUT	4
	#define PORTB_TH_DIR	3	/* 1 = INPUT */
	#define PORTB_TR_DIR	2
	#define PORTA_TH_DIR	1
	#define PORTA_TR_DIR	0

sfr at 0xDC PORT_A;
	#define PORTB_DOWN	7	/* 0 = PRESSED */
	#define PORTB_UP		6
	#define PORTA_TR		5
	#define PORTA_TL		4
	#define PORTA_RIGHT	3
	#define PORTA_LEFT	2
	#define PORTA_DOWN	1
	#define PORTA_UP		0

sfr at 0xDD PORT_B;
	#define PORTB_TH		7
	#define PORTA_TH		6
	#define PORT_RESET	4
	#define PORTB_TR		3
	#define PORTB_TL		2
	#define PORTB_RIGHT	1
	#define PORTB_LEFT	0

/* ----------------------------------------------------------------------------------- */
/* vlues for IO port reading */
struct PORT {
	int8u	button;		/* 1 = press */
		#define BUTTON_B		(1 << 5)	/* bit mask for c source */
		#define BUTTON_A		(1 << 4)
		#define BUTTON_RIGHT	(1 << 3)
		#define BUTTON_LEFT	(1 << 2)
		#define BUTTON_DOWN	(1 << 1)
		#define BUTTON_UP		(1 << 0)
		#define BUTTON_AB		(BUTTON_A | BUTTON_B)
	int8u	oneShot;	/* 1 when only first frame */
};
extern struct PORT ports[2];

/* ----------------------------------------------------------------------------------- */
extern void port_init();
extern void port_read();

/* ----------------------------------------------------------------------------------- */

