
.segment "LEVELS1"

.export LEVEL_BEGINNING
.export LEVEL_PASSWORD
.export	LEVEL_2
.export LEVEL_SLIDERS
.export LEVEL_FIRSTENEMY
.export LEVEL_METEORIC
.export LEVEL_DECISION
.export LEVEL_FRIDGE
.export LEVEL_ICE2
.export LEVEL_BOSS
	
LEVEL_BEGINNING:
	.incbin "../levels/beginning.level"

LEVEL_PASSWORD:
	.incbin "../levels/password.level"

LEVEL_2:
	.incbin	"../levels/level2.level"
	
.segment "LEVELS2"

LEVEL_SLIDERS:
	.incbin "../levels/sliders.level"

LEVEL_FIRSTENEMY:
	.incbin "../levels/firstenemy.level"
	
LEVEL_FRIDGE:
	.incbin "../levels/fridge.level"
	

	
.segment "LEVELS3"
	
LEVEL_DECISION:
	.incbin "../levels/decision.level"
	

LEVEL_METEORIC:
	.incbin "../levels/meteoric.level"
	
	
LEVEL_ICE2:
	.incbin "../levels/ice2.level"
	
.segment "GRAPHICS3"

LEVEL_BOSS:
	.incbin "../levels/boss.level"