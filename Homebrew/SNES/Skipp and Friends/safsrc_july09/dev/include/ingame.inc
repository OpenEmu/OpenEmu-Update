.ifndef __INGAME_INC__
__INGAME_INC__ = 42

	.ifndef __INGAME_NATIVE

	.import ScheduleSpriteXfer
	.import ExplodeSpace
	.import UpdateHearts
	.import UpdatePlayerMoves
	.import UpdatePlayerPalettes
	.importzp CameraPX
	.importzp CameraPY
	
	
	.import SobjXL, SobjXH, SobjA1, SobjA2, SobjA3, SobjSize
	.importzp SobjY
	
	.importzp Flipper
	
	.endif
	
	SCREENHEIGHT = (224-48)

.endif
