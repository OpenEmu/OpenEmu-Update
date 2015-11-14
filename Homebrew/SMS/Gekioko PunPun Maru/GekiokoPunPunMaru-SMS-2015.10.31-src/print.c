/* print */
#include "sms.h"
#include "vdp.h"

#include "map.h"
#include "print.h"

void print_init(){
	int8u *p;
	int8u c;

	p = pattern_name_buffer;
	for(c = 32; c > 0; c--){
		*p++ = VRAM_FONT + ' ';
		*p++ = BG_HIGH + BG_TOP + BG_PAL1;
	}
}
int8u print(char *text, int8u x){
	int8u *p;
	int8u *t;
	int8u c;
	int8u length;

	t = (int8u *)text;
	p = pattern_name_buffer;
	p += x << 1;
	for(length = 0; length < 32; length++){
		c = *t++;
		if(c == '\0') break;
		*p = VRAM_FONT + c;
		p += 2;
	}
	return length + 1;
}

