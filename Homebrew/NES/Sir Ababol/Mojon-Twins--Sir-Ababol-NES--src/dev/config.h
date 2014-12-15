// Config.h

#define PLAYER_MAX_VY_CAYENDO	112	
#define PLAYER_G				7	

#define PLAYER_VY_INICIAL_SALTO	24	
#define PLAYER_MAX_VY_SALTANDO	80	
#define PLAYER_INCR_SALTO 		16	

#define PLAYER_MAX_VX			48		// Velocidad máxima horizontal (192/64 = 3 píxels/frame)
#define PLAYER_AX				4		// Aceleración horizontal (24/64 = 0,375 píxels/frame^2)
#define PLAYER_RX				8		// Fricción horizontal (32/64 = 0,5 píxels/frame^2)

#define PLAYER_LIFE				9		// Vida máxima (con la que empieza, además)
#define PLAYER_REFILL			1		// Recarga de vida.

#define PLAYER_INI_X			1		// NO TOCAR ESTO, que el motor sólo puede empezar desde
#define PLAYER_INI_Y			1		// Arriba del todo a la izquierda, para ahorrar código.									

#define PLAYER_NUM_OBJETOS		24		// Número de objetos para terminar el juego
