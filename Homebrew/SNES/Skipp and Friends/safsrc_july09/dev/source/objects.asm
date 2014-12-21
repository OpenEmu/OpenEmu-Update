;*********************
;* object management
;*********************

__OBJECTS_NATIVE__ = 1

.include "snes.inc"
.include "objects.inc"
.include "sprites.inc"
.include "ingame.inc"
.include "snes_zvars.inc"

	.export Objects_Reset
	.export Objects_Allocate
	.export Objects_DoInit
	.export Objects_Update
	.export Objects_Draw
	
	.export Objects_AddSpriteB16
	.export Objects_TestForEntity
	
	.export Objects_PushUp
	.export Objects_PushLeft
	.export Objects_PushDown
	.export Objects_PushRight
	
	.export Objects_Step
	.export Objects_Button
	.export Objects_Action
	.export Objects_Explosion
	.export Objects_Laser
	.export Objects_StunArea
	
	.export ObjAniStart, ObjAniLength, ObjAniSpeed, ObjAniSpeedF
	.export ObjAniFrame, ObjAniFrameF, ObjX, ObjY, ObjXF, ObjYF
	.export ObjDir, ObjA1, ObjA2, ObjA3, ObjA4
	.export ObjC1, ObjC2, ObjC3, ObjC4, ObjC5, ObjC6, ObjC7, ObjC8
	.export ObjType
	
	.zeropage
	.exportzp OTX, OTY, OTP, OTSTEP, OTKEY
	
OTX:	.res 1
OTY:	.res 1
OTP:	.res 1
OTSTEP:	.res 1 ; 1 = press, 0=release
OTKEY:	.res 1 ; KEYS

;==============================================================================
	.bss
;==============================================================================

ObjAniStart:	.res MAX_OBJECTS
ObjAniLength:	.res MAX_OBJECTS
ObjAniSpeed:	.res MAX_OBJECTS
ObjAniSpeedF:	.res MAX_OBJECTS
ObjAniFrame:	.res MAX_OBJECTS
ObjAniFrameF:	.res MAX_OBJECTS
ObjX:		.res MAX_OBJECTS ; IN TILES (PIXELS = X*16 + F)
ObjY:		.res MAX_OBJECTS ; IN TILES
ObjXF:		.res MAX_OBJECTS ; X/Y FRACTION OF TILE (256 = +16.0)
ObjYF:		.res MAX_OBJECTS ;
ObjDir:		.res MAX_OBJECTS ;
ObjA1:		.res MAX_OBJECTS
ObjA2:		.res MAX_OBJECTS
ObjA3:		.res MAX_OBJECTS
ObjA4:		.res MAX_OBJECTS
ObjC1:		.res MAX_OBJECTS
ObjC2:		.res MAX_OBJECTS
ObjC3:		.res MAX_OBJECTS
ObjC4:		.res MAX_OBJECTS

;==============================================================================
	.bss ;.segment "HRAM": NEAR
;==============================================================================

ObjC5:		.res MAX_OBJECTS
ObjC6:		.res MAX_OBJECTS
ObjC7:		.res MAX_OBJECTS
ObjC8:		.res MAX_OBJECTS

;==============================================================================
	.bss
;==============================================================================

ObjType:
	.res	MAX_OBJECTS

;******************************************************************************
	.code
	.a8
	.i16
;******************************************************************************

;==============================================================================
Objects_Reset:
;==============================================================================
	ldx	#MAX_OBJECTS-1			; reset all types to 0
	lda	#0				;
:	sta	ObjType, x			;
	dex					;
	bpl	:-				;
	rts					;

;------------------------------------------------------------------------------
;
; allocate an object
;
; undefined behavior if the object
; table is full
;
; returns:
;   x = free index
;
;==============================================================================
Objects_Allocate:
;==============================================================================
	ldx	#-1			;
;------------------------------------------------------------------------------
@search:
;------------------------------------------------------------------------------
.repeat 7				; search object types
	inx				; until a zero is found
	lda	ObjType, x		;
	beq	@found			;
.endrepeat				;
	inx				;
	lda	ObjType, x		;
	bne	@search			;
;------------------------------------------------------------------------------
@found:
;------------------------------------------------------------------------------
	rts				;
	
;==============================================================================
.macro RunObjectFunction table
;==============================================================================
	sep	#10h			; 8-bit index during this routine
	ldy	#MAX_OBJECTS-1		;
;------------------------------------------------------------------------------
@next_object:
;------------------------------------------------------------------------------
	lda	ObjType, y		; update object if type != 0
	bne	@update_obj		;--------------------------------------
	dey				; loop until y is invalid
	bpl	@next_object		;
	bra	@update_exit		;
;------------------------------------------------------------------------------
@update_obj:
;------------------------------------------------------------------------------
					; jump to routines[type-1]
	asl				;
	tax				;
	jsr	(table-2, x)		;
	dey				; loop until y is invalid
	bpl	@next_object		;
@update_exit:				;
	rep	#10h			;
	rts				;
;------------------------------------------------------------------------------
.endmacro
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;
; initialize
;
;==============================================================================
Objects_DoInit:
;==============================================================================
	RunObjectFunction ObjectInitRoutines

;------------------------------------------------------------------------------
;
; update all objects
;
;==============================================================================
Objects_Update:
;==============================================================================
	RunObjectFunction ObjectUpdateRoutines

;------------------------------------------------------------------------------
;
; draw all objects
;
;==============================================================================
Objects_Draw:
;==============================================================================
	RunObjectFunction ObjectDrawRoutines
	
	
	
;==============================================================================
.macro RunPointFunction table
;==============================================================================
	sep	#10h			; 8-bit index during this routine
	ldy	#MAX_OBJECTS-1		;
;------------------------------------------------------------------------------
@next_object:
;------------------------------------------------------------------------------
	lda	ObjType, y		; update object if type != 0
	bne	@update_obj		;--------------------------------------
	dey				; loop until y is invalid
	bpl	@next_object		;
	bra	@update_exit		;
;------------------------------------------------------------------------------
@update_obj:
;------------------------------------------------------------------------------
					; jump to routines[type-1]
	asl				;
	tax				;
	lda	ObjX, y			;
	cmp	OTX			;
	bne	:+			;
	lda	ObjY, y			;
	cmp	OTY			;
	bne	:+			;
	jsr	(table-2, x)		;
:	dey				; loop until y is invalid
	bpl	@next_object		;
@update_exit:				;
	rep	#10h			;
	rts				;
;------------------------------------------------------------------------------
.endmacro
;------------------------------------------------------------------------------


	
; push object UP
;==============================================================================
Objects_PushUp:
;==============================================================================
	RunPointFunction ObjectPushUpRoutines
	
; push object DOWN
;==============================================================================
Objects_PushDown:
;==============================================================================
	RunPointFunction ObjectPushDownRoutines
	
; push object LEFT
;==============================================================================
Objects_PushLeft:
;==============================================================================
	RunPointFunction ObjectPushLeftRoutines

; push object RIGHT
;==============================================================================
Objects_PushRight:
;==============================================================================
	RunPointFunction ObjectPushRightRoutines
	
;==============================================================================
Objects_Step:
;==============================================================================
	RunPointFunction ObjectStepRoutines
	
;==============================================================================
Objects_Button:
;==============================================================================
	RunPointFunction ObjectButtonRoutines
	
;==============================================================================
Objects_Action:
;==============================================================================
	RunPointFunction ObjectActionRoutines
	
;==============================================================================
Objects_Explosion:
;==============================================================================
	RunPointFunction ObjectExplosionRoutines
	
;==============================================================================
Objects_Laser:
;==============================================================================
	sep	#10h			; 8-bit index during this routine
	ldy	#MAX_OBJECTS-1		;
;------------------------------------------------------------------------------
@next_object:
;------------------------------------------------------------------------------
	lda	ObjType, y		; update object if type != 0
	bne	@update_obj		;--------------------------------------
	dey				; loop until y is invalid
	bpl	@next_object		;
	bra	@update_exit		;
;------------------------------------------------------------------------------
@update_obj:
;------------------------------------------------------------------------------
					; jump to routines[type-1]
	asl				;
	tax				;
	lda	ObjX, y			;
	cmp	m0			;
	bcc	@miss			;
	cmp	m0+1
	bcs	@miss
	lda	ObjY, y			;
	cmp	m1			;
	bcc	@miss
	cmp	m1+1
	bcs	@miss
	jsr	(ObjectLaserRoutines-2, x)		;
@miss:	dey				; loop until y is invalid
	bpl	@next_object		;
@update_exit:				;
	rep	#10h			;
	rts				;
	
.import OBJR_Player1_Init
.import OBJR_Player2_Init
.import OBJR_Player3_Init
.import OBJR_Laser_Init , OBJR_Laser_Update , OBJR_Laser_Draw , OBJR_Laser_Button
.import OBJR_Box_Init   , OBJR_Box_Update   , OBJR_Box_Draw   , OBJR_Box_PushUp, OBJR_Box_PushDown, OBJR_Box_PushLeft, OBJR_Box_PushRight
.import OBJR_Lock_Init  , OBJR_Lock_Update  , OBJR_Lock_Draw  , OBJR_Lock_Action
.import OBJR_Key_Init   , OBJR_Key_Update   , OBJR_Key_Draw
.import OBJR_Button_Init, OBJR_Button_Update, OBJR_Button_Draw, OBJR_Button_Step
.import OBJR_Baddie_Init, OBJR_Baddie_Update, OBJR_Baddie_Draw, OBJR_Baddie_Explode, OBJR_Baddie_Stun
.import OBJR_MapExit_Init, OBJR_MapExit_Update, OBJR_MapExit_Draw

;==============================================================================
ObjectInitRoutines:
;==============================================================================
	.word	OBJR_Player1_Init	; Player1
	.word	OBJR_Player2_Init	; Player2
	.word	OBJR_Player3_Init	; Player3
	.word	OBJR_Laser_Init
	.word	OBJR_Box_Init
	.word	OBJR_Lock_Init
	.word	OBJR_Key_Init
	.word	OBJR_Button_Init
	.word	OBJR_Baddie_Init
	.word	OBJR_MapExit_Init
	; <insert init routines here>
	
;==============================================================================
ObjectUpdateRoutines:
;==============================================================================
	
	.word	DebugRoutine		; Player1
	.word	DebugRoutine		; Player2
	.word	DebugRoutine		; Player3
	.word	OBJR_Laser_Update
	.word	OBJR_Box_Update
	.word	OBJR_Lock_Update
	.word	OBJR_Key_Update
	.word	OBJR_Button_Update
	.word	OBJR_Baddie_Update
	.word	OBJR_MapExit_Update
	; <insert update routines here>
	
;==============================================================================
ObjectDrawRoutines:
;==============================================================================
	
	.word	DebugRoutine		; Player1
	.word	DebugRoutine		; Player2
	.word	DebugRoutine		; Player3
	.word	OBJR_Laser_Draw
	.word	OBJR_Box_Draw
	.word	OBJR_Lock_Draw
	.word	OBJR_Key_Draw
	.word	OBJR_Button_Draw
	.word	OBJR_Baddie_Draw
	.word	OBJR_MapExit_Draw
	; <insert drawing routines here>
	
;==============================================================================
ObjectPushUpRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	OBJR_Box_PushUp		; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit

;==============================================================================
ObjectPushDownRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser 
	.word	OBJR_Box_PushDown	; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectPushLeftRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	OBJR_Box_PushLeft	; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectPushRightRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	OBJR_Box_PushRight	; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectStepRoutines:
;==============================================================================
	.word	DebugRoutine
	.word	DebugRoutine
	.word	DebugRoutine
	.word	EmptyRoutine
	.word	EmptyRoutine
	.word	EmptyRoutine
	.word	EmptyRoutine
	.word	OBJR_Button_Step
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectButtonRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	OBJR_Laser_Button	; laser
	.word	EmptyRoutine		; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key	
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectActionRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	EmptyRoutine		; box
	.word	OBJR_Lock_Action	; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	EmptyRoutine		; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectExplosionRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	EmptyRoutine		; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	OBJR_Baddie_Explode	; baddie
	.word	EmptyRoutine		; exit
	
;==============================================================================
ObjectLaserRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	EmptyRoutine		; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	OBJR_Baddie_Explode	; baddie
	.word	EmptyRoutine		; exit

;==============================================================================
ObjectStunRoutines:
;==============================================================================
	.word	DebugRoutine		; p1
	.word	DebugRoutine		; p2
	.word	DebugRoutine		; p3
	.word	EmptyRoutine		; laser
	.word	EmptyRoutine		; box
	.word	EmptyRoutine		; lock
	.word	EmptyRoutine		; key
	.word	EmptyRoutine		; button
	.word	OBJR_Baddie_Stun	; baddie
	.word	EmptyRoutine		; exit
	
	.a8
	.i8

;==============================================================================
EmptyRoutine:
;==============================================================================
	rts
	
;==============================================================================
DebugRoutine:
;==============================================================================
	lda	#08h				;
	sta	REG_INIDISP			;
:	bra :-					;
;------------------------------------------------------------------------------
	rts					;
	
;==============================================================================
Objects_AddSpriteB16:
;==============================================================================
	lda	ObjX, y				; a = X - CAMERA
	xba					;
	lda	ObjXF, y			;
	rep	#20h				;
	lsr					;
	lsr					;
	lsr					;
	lsr					;
	sec					;
	sbc	CameraPX			;
;------------------------------------------------------------------------------
	bpl	:+				; catch off-screen
	cmp	#-16				;
	bcs	:++				;
	bra	@offscreen			;
:	cmp	#256				;
	bcs	@offscreen			;
:	sta	m0				; save result
;------------------------------------------------------------------------------
	sep	#20h				; a = Y - CAMERA
	lda	ObjY, y				;
	xba					;
	lda	ObjYF, y			;
	rep	#20h				;
	lsr					;
	lsr					;
	lsr					;
	lsr					;
	sec					;
	sbc	CameraPY			;
;------------------------------------------------------------------------------
	bpl	:+				; catch off-screen		
	cmp	#-16				;
	bcs	:++				;
	bra	@offscreen			;
:	cmp	#SCREENHEIGHT			;
	bcs	@offscreen			;
:	
;------------------------------------------------------------------------------
	sep	#20h				; a = 8bit
	xba					; b = Y
	phy					; preserve Y
	lda	4, S				; y = TILE
	tay					; 
	lda	5, S				; a = A3
	rep	#10h				; 
	ldx	m0				; x = X
	xba					; swap A/B
	AddSprite16b				; add sprite
	sep	#10h				;
	ply					; restore Y
;------------------------------------------------------------------------------
	rts					; exit
;------------------------------------------------------------------------------
@offscreen:
;------------------------------------------------------------------------------
	sep	#30h
	rts
	
;==============================================================================
Objects_ApplyLaser:
;==============================================================================
	rts
	
	
;******************************************************************************

	.i16
	.a8

; m0=x,y
;==============================================================================
Objects_TestForEntity:
;==============================================================================
	clc
	rts

; m0 = x1,x2
; m1 = y1,y2
;==============================================================================
Objects_StunArea:
;==============================================================================
	sep	#10h			; 8-bit index during this routine
	ldy	#MAX_OBJECTS-1		;
;------------------------------------------------------------------------------
@next_object:
;------------------------------------------------------------------------------
	lda	ObjType, y		; update object if type != 0
	bne	@update_obj		;--------------------------------------
	dey				; loop until y is invalid
	bpl	@next_object		;
	bra	@update_exit		;
;------------------------------------------------------------------------------
@update_obj:
;------------------------------------------------------------------------------
					; jump to routines[type-1]
	asl				;
	tax				;
	lda	ObjX, y			;
	cmp	m0			;
	bcc	@miss			;
	cmp	m0+1
	bcs	@miss
	lda	ObjY, y			;
	cmp	m1			;
	bcc	@miss
	cmp	m1+1
	bcs	@miss
	jsr	(ObjectStunRoutines-2, x)		;
@miss:	dey				; loop until y is invalid
	bpl	@next_object		;
@update_exit:				;
	rep	#10h			;
	rts				;
	
