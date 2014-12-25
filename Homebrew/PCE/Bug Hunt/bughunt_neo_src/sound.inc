;--------------------------------------------------------------------------
; sound.inc - mml player include file.                                     
;..........................................................................
; this file is #included at line 107 in the modified startup.asm
;..........................................................................
; HuC expect some things to be set up in this file. I'm working on fixing  
; the file layout, but for right now leave this alone.                     
;..........................................................................

;
; PSG.INC  -  MagicKit PSG Player Equates
;
;
; --------
; defines
;

;---------------------------------------------------------------------------
; fields for psgFlags / psg_inhibt

PSG_INHIBIT =	$80
PSG_IRQ		=   $01

;---------------------------------------------------------------------------
; song initialized bit

PSG_SNG_NEED_INIT		= $80

;---------------------------------------------------------------------------
; Track control fields

PSG_TRK_MAINPAUSE =	$80
PSG_TRK_SUBPAUSE =	$40

;...................................

PSG_DDA =	$40

;---------------------------------------------------------------------------
; system numbers

PSGSYS_MAIN_ONLY		= 0
PSGSYS_SUB_ONLY			= 1
PSGSYS_BOTH_60			= 2
PSGSYS_BOTH_120			= 3
PSGSYS_BOTH_240			= 4
PSGSYS_BOTH_300			= 5

; --------
; useful macros:
;

ENV_RLS	.macro
	 .db $fb
	 .dw \1
	.endm

ENV_LEV	.macro
	 .db $fc
	 .dw \1
	.endm

ENV_DLY	.macro
	 .db \1
	 .dw \2
	.endm

ENV_END	.macro
	 .db $ff
	.endm

;---------------------------------------------------------------------------------------
; This block defines standard system variables in the zero-page.
;---------------------------------------------------------------------------------------
; do NOT change these variable names. They are used by HuC startup code.
;........................................................................................

				.org	$20e6
				
psg_irqflag	 	.ds		1		; $e6 = flag to indicate psg interrupt already being serviced.

;........................................................................................
; library.asm, line 1380 is the psg_init routine (which gets called during hardware setup).
; it sets psg_inhibit to 1! so, IF we are going to use inhibit to turn the psg on/off,
; then bit 7 = 0 means the psg is OFF, and bit 7 = 1 means the psg is ON.
;

psgFlags
psg_inhibit		.ds		1		; $e7 = flag bits that control indicate the psg state.
								;       bit 0 : 0 = use timer irq,   1 = use vsync irq
                                ;       bit 7 : 0 = psg not ready,   1 = psg ready.
								
psgPtr1			.ds		2		; $e8-$e9 = temp pointer1 for psg  (was _tmpptr)
psgPtr2 	    				; $ea-$eb = temp pointer2 for psg  (was _tmpptr1 )
psgTemp1		.ds     1
psgTemp2		.ds		1

;---------------------------------------------------------------------------------------
; This block defines data used by (original) psg MML player routine.
; this is the "shared" data, common to both main and sub tracks.
;.......................................................................................
;
;		.org			$22d0

		.include 		"main\common.inc"

;---------------------------------------------------------------------------------------
; this is the data used by ONLY the main track.
;.......................................................................................
;
;		.org			$22ee

		.include 		"main\main.inc"

;---------------------------------------------------------------------------------------
; this is the data used by ONLY the sub-track.
;
;		.org			$248b
		.include		"sub\sub.inc"
		