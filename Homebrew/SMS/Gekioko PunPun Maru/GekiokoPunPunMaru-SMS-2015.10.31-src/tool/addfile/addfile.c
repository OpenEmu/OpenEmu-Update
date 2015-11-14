#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

char *rom_name;

#define REGION_CODE		0x40	/* fixed to 'SMS Export' because only the export SMS BIOS actually checks this */
#define ROM_SIZE			(512 * 1024)
uint8_t	rom[ROM_SIZE];
uint8_t	temp[ROM_SIZE];

#define FAT_BASE			0x7C00	/* base address for FAT */
#define FILE_BASE			2		/* fast 32 kBytes (2 pages) = program + FAT + header */
#define FILE_NAME_LENGTH	17		/* 16 + NULL */
#define FA_LENGTH			(FILE_NAME_LENGTH + 1 + 2)	/* file attribute length = FILE_NAME_LENGTH + page number + offset */
#define FA_COUNT			48		/* 24 files * 20 bytes = 480 bytes for FAT */
#define ADDRESS_OFFSET	(32 * 1024)
#define PAGE_SIZE			(16 * 1024)
#define PROGRAM_SIZE		(FAT_BASE)

/* 	FAT image: 
	0123456789ABCDEF0123
	bmp/title.ptn   || |
	bmp/title.pal   || Offset
	bgm/title.sn7   |Page
	bgm/game0.sn7   Null
	bgm/gameover.sn7   |
	|              |   |
    +-- File Name -+   |
    |                  |
    +--File Attribute -+
 */

int current_page;
int current_offset;
int files_count;

void pickup(int argc, char *argv[]);
void add_file(char *file_name, int size_limit);
void add_fat(char *file_name, int file_size);
void add_header(int rom_size);
void save(char *file_name);

int main(int argc, char *argv[]){
	rom_name = argv[1];
	files_count = 0;

	/* program file */
	current_page = 0;
	current_offset = 0;
	add_file(argv[1], PROGRAM_SIZE);

	/* resource file */
	current_page = FILE_BASE;
	current_offset = 0;
	pickup(argc, argv);

	return 0;
}
void pickup(int argc, char *argv[]){
	char *arg;
	int ac;

	for(ac = 2; ac < argc; ac++){
		arg = argv[ac];
		/* option switches */
		if(*arg == '-'){
			arg++;
			switch(*arg++){
			case 'a':	/* -a1 = alignment */
			
				break;
			case 's':	/* -s = split page */
				
				break;
			default:
				break;
			}
		}else{
		/* file path */
			add_file(arg, PAGE_SIZE);
		}
	}
	save(rom_name);
}
void add_file(char *file_name, int size_limit){
	FILE *fp;
	uint8_t data;
	int c;
	int file_size;

	if((fp = fopen(file_name, "rb")) == NULL){
		printf("Cannot open :%s\n", file_name);
		exit(EXIT_FAILURE);
	}

	/* read the file */
	file_size = 0;
	while(fread(&data, 1, 1, fp) == 1){
		temp[file_size++] = data;
		if(file_size >= size_limit) break;
	}
	fclose(fp);

	/* check page over */
	if((current_offset + file_size) > size_limit){
		current_page++;
		current_offset = 0;
	}

	/* add to the rom image */
	for(c = 0; c < file_size; c++){
		rom[(current_page * PAGE_SIZE) + (current_offset + c)] = temp[c];
	}

	/* add FAT */
	add_fat(file_name, file_size);

	current_offset += file_size;
	files_count++;
}
void add_fat(char *file_name, int file_size){
	int c;
	char s;

	/* file name */
	for(c = 0; c < FILE_NAME_LENGTH; c++){
		s = *file_name++;
		if(s == '\0') break;
		rom[FAT_BASE + (files_count * FA_LENGTH) + c] = s;
	}

	/* page number */
	rom[FAT_BASE + (files_count * FA_LENGTH) + FILE_NAME_LENGTH + 0] = current_page;

	/* offset address */
	rom[FAT_BASE + (files_count * FA_LENGTH) + FILE_NAME_LENGTH + 1] = (ADDRESS_OFFSET + current_offset) & 0x00FF;
	rom[FAT_BASE + (files_count * FA_LENGTH) + FILE_NAME_LENGTH + 2] = (ADDRESS_OFFSET + current_offset) >> 8;
}
void add_header(int rom_size){
	uint16_t checksum;
	int c;

	/* trade mark */
	rom[0x7FF0] = 'T';
	rom[0x7FF1] = 'M';
	rom[0x7FF2] = 'R';
	rom[0x7FF3] = ' ';
	rom[0x7FF4] = 'S';
	rom[0x7FF5] = 'E';
	rom[0x7FF6] = 'G';
	rom[0x7FF7] = 'A';
	rom[0x7FF8] = ' ';
	rom[0x7FF9] = ' ';

	/* checksum */
	for(c = 0; c < 0x7FF0; c++){
		checksum += rom[c];
	}
	for(c = 0x8000; c < rom_size; c++){
		checksum += rom[c];
	}
	rom[0x7FFA] = checksum & 0x00FF;
	rom[0x7FFB] = checksum >> 8;

	/* product code */
	rom[0x7FFC] = 0x00;
	rom[0x7FFD] = 0x00;
	rom[0x7FFE] = 0x00;

	/* region code + rom size code */
	if(rom_size == ( 64 * 1024)) c = 0x0E;
	if(rom_size == (128 * 1024)) c = 0x0F;
	if(rom_size == (256 * 1024)) c = 0x00;
	if(rom_size == (512 * 1024)) c = 0x01;
	rom[0x7FFF] = REGION_CODE + c;
}
void save(char *file_name){
	FILE *fp;
	int rom_size;

	rom_size = (current_page + 1) * PAGE_SIZE;
	if((rom_size > (  0 * 1024)) && (rom_size < ( 64 * 1024))) rom_size =  64 * 1024;
	if((rom_size > ( 64 * 1024)) && (rom_size < (128 * 1024))) rom_size = 128 * 1024;
	if((rom_size > (128 * 1024)) && (rom_size < (256 * 1024))) rom_size = 256 * 1024;
	if((rom_size > (256 * 1024)) && (rom_size < (512 * 1024))) rom_size = 512 * 1024;
	if(rom_size > (512 * 1024)){
		printf("ROM image over 512kBytes.\n");
		exit(EXIT_FAILURE);
	}
	add_header(rom_size);
	printf("ROM used: %d bytes, %d pages\n", rom_size, current_page + 1);

	if((fp = fopen(file_name, "wb")) == NULL){
		printf("Cannot open :%s\n", file_name);
		exit(EXIT_FAILURE);
	}

	/* write to the file */
	if(fwrite(rom, 1, rom_size, fp) < rom_size){
		printf("Cannot write :%s\n", file_name);
		exit(EXIT_FAILURE);
	}
	fclose(fp);
}


