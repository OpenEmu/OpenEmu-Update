.ifndef __PLAYERS_INC__
__PLAYERS_INC__ = 1

	.import OBJR_Player1_Init, OBJR_Player2_Init, OBJR_Player3_Init
	.import Players_Update
	.import Players_Draw
	
	.import Players_ApplyExplosion
	.import Players_ApplyLaser

	.importzp PL_Moves1, PL_Moves2, PL_Moves3, PL_Moves4
	.importzp PL_KeyH, PL_KeyV, PL_KeyM
	.importzp PL_XL, PL_XH, PL_YL, PL_YH
	.importzp PL_HP
	.importzp PL_HasKey
	
	.import PL_Exited
	
	PLSTATE_REALLYDEAD=7
	.importzp PL_State
	
.endif
