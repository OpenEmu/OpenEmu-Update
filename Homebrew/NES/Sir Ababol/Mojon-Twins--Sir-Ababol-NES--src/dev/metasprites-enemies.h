// Metasprites (enemies)

// Murciélago
const unsigned char sprMurA[] = {
	-4, 0, 24, 0, 		 4, 0, 25, 0,		12, 0, 26, 0,
	-4, 8, 27, 0,		 4, 8, 28, 0, 		12, 8, 29, 0,
	128
};
const unsigned char sprMurB[] = {
	-4, 0, 30, 0, 		 4, 0, 31, 0,		12, 0, 32, 0,
	-4, 8, 33, 0,		 4, 8, 34, 0, 		12, 8, 35, 0,
	128
};
// Guerrero
const unsigned char sprGueA[] = {
	 0,-8, 12, 2,		 8,-8, 13, 2,
	 0, 0, 14, 2,		 8, 0, 15, 2,
	 0, 8, 16, 2,		 8, 8, 17, 2,
	128
};
const unsigned char sprGueB[] = {
	 0,-8, 18, 2,		 8,-8, 19, 2,
	 0, 0, 20, 2,		 8, 0, 21, 2,
	 0, 8, 22, 2,		 8, 8, 23, 2,
	128
};
// Canino
const unsigned char sprCanA[] = {
	 0,-8,  0, 0,		 8,-8,  1, 0,
	 0, 0,  2, 0,		 8, 0,  3, 0,
	 0, 8,  4, 0,		 8, 8,  5, 0,
	128
};
const unsigned char sprCanB[] = {
	 0,-8,  6, 0,		 8,-8,  7, 0,
	 0, 0,  8, 0,		 8, 0,  9, 0,
	 0, 8, 10, 0,		 8, 8, 11, 0,
	128
};
// Plataforma
const unsigned char sprPlaA[] = {
	 0, 0, 36, 0, 		 8, 0, 37, 0,
	 0, 8, 0xff, 0,		 0, 8, 0xff, 0,
	 0, 8, 0xff, 0,		 0, 8, 0xff, 0,
	128
};
const unsigned char sprPlaB[] = {
	 0, 0, 38, 0, 		 8, 0, 39, 0,
	 0, 8, 0xff, 0,		 0, 8, 0xff, 0,
	 0, 8, 0xff, 0,		 0, 8, 0xff, 0,
	128
};
const unsigned char sprExpl[] = {
	 0, 0, 191, 0,		8, 0, 192, 0,
	 0, 8, 193, 0,		8, 8, 194, 0,
	 0, 8, 0xff, 0,		0, 8, 0xff, 0,
	128
};
const unsigned char sprEmpty[] = {	0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0, 0, 0, 0xff, 0, 128 };
const unsigned char* const spr_enems[]={
	sprMurA, sprMurB, 
	sprCanA, sprCanB, 
	sprGueA, sprGueB, 
	sprPlaA, sprPlaB, 
	sprEmpty, sprExpl
};
