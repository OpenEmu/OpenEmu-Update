
.ifndef __EXPLOSION_INC__
__EXPLOSION_INC__ = 1

	.import	Explosion_Start ;a=x,b=y
	.import Explosion_MiniStart
	.import Explosion_Update
	.import Explosion_Draw
	.import ResetExpGX
	
	.importzp expActive
	
.macro ResetExplosion
	stz	expActive
	jsr	ResetExpGX
.endmacro

.endif
