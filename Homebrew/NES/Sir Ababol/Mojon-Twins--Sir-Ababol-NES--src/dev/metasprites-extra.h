// extra

// Empty sprite (for flickering)
const unsigned char spr_aba_empty [] = {
	0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0,
	0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0,
	0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0,
	128
};

// Dying sequence sprite
const unsigned char spr_dead[] = {
	0, -8, 195, 0, 8, -8, 196, 0, 
	0, 0, 197, 0, 8, 0, 198, 0, 
	0, 8, 199, 0, 8, 8, 200, 0, 
	0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0, 
	128
};

// Ending sequence
const unsigned char spr_end_ababol [] = {
	-4, -8, 173, 2, 4, -8, 174, 2, 12, -8, 175, 2,
	-4, 0, 176, 2, 4, 0, 177, 2, 12, 0, 178, 2,
	-4, 8, 179, 2, 4, 8, 180, 2, 12, 8, 181, 2,
	128
};

const unsigned char spr_end_nanako [] = {
	-4, -8, 182, 1, 4, -8, 183, 1, 12, -8, 184, 1,
	-4, 0, 185, 1, 4, 0, 186, 1, 12, 0, 187, 1,
	-4, 8, 188, 1, 4, 8, 189, 1, 12, 8, 190, 1,
	128
};

// Mojontwins logo
const unsigned char spr_mt_logo [] = {
	0, 0, 161, 0, 8, 0, 162, 0, 16, 0, 163, 1, 24, 0, 164, 1, 32, 0, 165, 0, 40, 0, 166, 0,
	0, 8, 167, 0, 8, 8, 168, 0, 16, 8, 169, 1, 24, 8, 170, 1, 32, 8, 171, 0, 40, 8, 172, 0,
	128	
};
