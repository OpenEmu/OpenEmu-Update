.ifndef __OBJECTS_INC__
__OBJECTS_INC__ = 1
	
MAX_OBJECTS = 40

;------------------------------------------------------------------------------
; object-base structure
;------------------------------------------------------------------------------


.ifndef __OBJECTS_NATIVE__

	.import Objects_Reset
	.import Objects_Allocate
	.import Objects_DoInit
	.import Objects_Update
	.import Objects_Draw
	.import Objects_AddSpriteB16
	.import Objects_TestForEntity
	
	.import	Objects_PushUp
	.import Objects_PushLeft
	.import Objects_PushRight
	.import Objects_PushDown
	.import Objects_Button
	.import Objects_Step
	.import Objects_Action
	.import Objects_Explosion
	.import Objects_Laser
	
	.import ObjAniStart
	.import ObjAniLength
	.import ObjAniSpeedL
	.import ObjAniSpeedH
	.import ObjAniFrameL
	.import ObjAniFrameH
	.import ObjX
	.import ObjY
	.import ObjXF
	.import ObjYF
	.import ObjDir
	.import ObjA1
	.import ObjA2
	.import ObjA3
	.import ObjA4
	
	.import ObjC1
	.import ObjC2
	.import ObjC3
	.import ObjC4
	.import ObjC5
	.import ObjC6
	.import ObjC7
	.import ObjC8
	
	.import ObjType
	
	.importzp OTX, OTY, OTP, OTSTEP, OTKEY
.endif

OBJ_P1 = 1
OBJ_P2 = 2
OBJ_P3 = 3
OBJ_LASER = 4
OBJ_BOX = 5
OBJ_LOCK = 6
OBJ_KEY = 7
OBJ_BUTTON = 8

.macro mac_Objects_AddSpriteB16 a3, tile
	lda	#a3
	pha
	lda	#tile
	pha
	jsr	Objects_AddSpriteB16
	pla
	pla
.endmacro

;---------------------------------------------------
; note: when making object routines:
; y = object index
; a/x/y = 8bit
; these states must be preserved
;---------------------------------------------------

.endif
