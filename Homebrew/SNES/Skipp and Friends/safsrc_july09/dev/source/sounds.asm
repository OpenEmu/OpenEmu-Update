
;
; sound binaries and table
;

.include "snes.inc"

	.export SoundTable
	
	.code
	
RATE_12K = 6
RATE_10K = 5
RATE_8K = 4
RATE_6K = 3
RATE_4K = 2
RATE_2K = 1

PAN_CENTER = 8
VOL_MAX = 15

.macro SDEF RATE, PAN, VOL, SRC, SRCEND
	.byte	RATE
	.byte	PAN
	.byte	VOL
	.word	(SRCEND-SRC)/9
	.word	.LOWORD(SRC)
	.byte	^SRC
.endmacro
	
;==============================================================================
SoundTable:
;==============================================================================
;0:
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_BEEP1, SND_BEEP1_END
;------------------------------------------------------------------------------
;1:
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_SCREAM, SND_SCREAM_END
;------------------------------------------------------------------------------
;2:
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_CARDKEY, SND_CARDKEY_END	
;------------------------------------------------------------------------------
;3:
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_BUTTON, SND_BUTTON_END	
;------------------------------------------------------------------------------
;4:
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_EXPLOSION, SND_EXPLOSION_END	
;------------------------------------------------------------------------------
;5
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_PUSH, SND_PUSH_END
;------------------------------------------------------------------------------
;6
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_FUSE, SND_FUSE_END
;------------------------------------------------------------------------------
;7
	SDEF RATE_10K, PAN_CENTER, VOL_MAX, SND_LASER, SND_LASER_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_LOCO, SND_LOCO_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_STARTGAEM, SND_STARTGAEM_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_MENU1, SND_MENU1_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_MENU2, SND_MENU2_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_OW1, SND_OW1_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_WAH1, SND_WAH1_END
	SDEF RATE_12K, PAN_CENTER, VOL_MAX, SND_WEDGE, SND_WEDGE_END
	SDEF RATE_8K, PAN_CENTER, VOL_MAX, SND_OW1, SND_OW1_END
	SDEF RATE_10K, PAN_CENTER, VOL_MAX, SND_WEDGE, SND_WEDGE_END
;------------------------------------------------------------------------------


	.segment "SOUNDS"
	
SND_BEEP1:
.incbin	"../sounds/beep1.brr"
SND_BEEP1_END:

SND_SCREAM:
.incbin "../sounds/scream.brr"
SND_SCREAM_END:

SND_CARDKEY:
.incbin "../sounds/cardkey.brr"
SND_CARDKEY_END:

SND_BUTTON:
.incbin "../sounds/button.brr"
SND_BUTTON_END:

SND_EXPLOSION:
.incbin "../sounds/explosion.brr"
SND_EXPLOSION_END:

SND_PUSH:
.incbin "../sounds/push.brr"
SND_PUSH_END:

SND_FUSE:
.incbin "../sounds/fuse.brr"
SND_FUSE_END:


SND_LASER:
.incbin "../sounds/laser.brr"
SND_LASER_END:
SND_LOCO:
.incbin "../sounds/loco.brr"
SND_LOCO_END:

SND_STARTGAEM:
.incbin "../sounds/startgaem.brr"
SND_STARTGAEM_END:

SND_MENU1:
.incbin "../soundS/menu1.brr"
SND_MENU1_END:

SND_MENU2:
.incbin "../soundS/menu2.brr"
SND_MENU2_END:

SND_OW1:
.incbin "../sounds/ow1.brr"
SND_OW1_END:

SND_WAH1:
.incbin "../sounds/wah1.brr"
SND_WAH1_END:

	.segment "SOUNDS2"

SND_WEDGE:
.incbin "../sounds/wedge.brr"
SND_WEDGE_END:
