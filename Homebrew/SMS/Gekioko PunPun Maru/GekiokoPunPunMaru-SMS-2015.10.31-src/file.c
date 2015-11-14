#include "sms.h"
/* ----------------------------------------------------------------------------------- */
/*
struct FILE_TABLE {
	char file_name[FILE_NAME_LENGTH];
	int8u page_number;
	int16u file_address;
};
*/
#define FAT_BASE	0x7C00	/* base address for FAT */
#define FILE_NAME_LENGTH	17	/* 16 + NULL */
#define FA_LENGTH	(FILE_NAME_LENGTH + 1 + 2)	/* file attribute length = FILE_NAME_LENGTH + page number + offset */
#define FILE_COUNT	48

/* ----------------------------------------------------------------------------------- */
int8u *fopen(char *file_name){
	char *table;
	char *name;
	int8u fc;
	int8u c;

	table = (char *)FAT_BASE;
	for(fc = FILE_COUNT; fc != 0; fc--){
		name = file_name;
		for(c = 0; c < FILE_NAME_LENGTH; c++){
			if(*name != *table++){
				table += FILE_NAME_LENGTH - 1 - c;
				break;
			}
			if(*name == '\0'){
				table += FILE_NAME_LENGTH - 1 - c;
				c = FILE_NAME_LENGTH;
				break;
			}
			name++;
		}
		if(c == FILE_NAME_LENGTH){
			/* page number */
			c = *table++;

			/* mapper control for ROM/RAM select */
			*(int8u *)0xFFFC = 0x00;

			/* page select */
			*(int8u *)0xFFFF = c;

			/* file address */
			return (int8u *)(*(int16u *)table);
		}else{
			table += 3;
		}
	}
	while(373);
}
/* ----------------------------------------------------------------------------------- */

