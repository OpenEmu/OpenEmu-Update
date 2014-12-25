;***************************************************************************************
; envelopes.inc - data for system volume envelopes
;---------------------------------------------------------------------------------------
; 
; Envelope Table (pointers to data)
;
psgSysEnv
	.dw psg_env0
	.dw psg_env1
	.dw psg_env2
	.dw psg_env3
	.dw psg_env4
	.dw psg_env5
	.dw psg_env6
	.dw psg_env7
	.dw psg_env8
	.dw psg_env9
	.dw psg_enva
	.dw psg_envb
	.dw psg_envc
	.dw psg_envd
	.dw psg_enve
	.dw psg_envf

psgSysEnvEnd 	=	*								; end location of table
psgSysEnvCnt	= (psgSysEnvEnd - psgSysEnv ) / 2	; # entries in table

;---------------------------------------------------------------------------------
; Envelope Data
;---------------------------------------------------------------------------------
;
; envelope #0
;
psg_env0:
	ENV_RLS	$8410
	ENV_LEV	$7c40
	ENV_DLY $00,$0000
	ENV_END

;
; envelope #1
;
psg_env1:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $0c,$fe01
	ENV_END

;
; envelope #2
;
psg_env2:
	ENV_RLS	$fd05
	ENV_LEV $7c40
	ENV_DLY $0c,$fe01
	ENV_END

;
; envelope #3
;
psg_env3:
	ENV_RLS	$ff01
	ENV_LEV $7c40
	ENV_DLY $0c,$fe01
	ENV_END

;
; envelope #4
;
psg_env4:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $00,$ff81
	ENV_END

;
; envelope #5
;
psg_env5:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $00,$ff01
	ENV_END

;
; envelope #6
;
psg_env6:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $00,$fe01
	ENV_END

;
; envelope #7
;
psg_env7:
	ENV_RLS	$fb05
	ENV_LEV $2c40
	ENV_DLY $02,$2801
	ENV_DLY $00,$ff81
	ENV_END

;
; envelope #8
;
psg_env8:
	ENV_RLS	$fb05
	ENV_LEV $3440
	ENV_DLY $03,$1801
	ENV_DLY $00,$ff81
	ENV_END

;
; envelope #9
;
psg_env9:
	ENV_RLS	$fb05
	ENV_LEV $1c40
	ENV_DLY $01,$6001
	ENV_DLY $02,$fe01
	ENV_DLY $08,$fc01
	ENV_DLY $32,$0081
	ENV_END

;
; envelope #$0a
;
psg_enva:
	ENV_RLS	$fd01
	ENV_LEV $0440
	ENV_DLY $03,$2801
	ENV_DLY $04,$fe01
	ENV_END

;
; envelope #$0b
;
psg_envb:
	ENV_RLS	$fd01
	ENV_LEV $0000
	ENV_LEV $0000
	ENV_LEV $7c40
	ENV_DLY $00,$ffc1
	ENV_END

;
; envelope #$0c
;
psg_envc:
	ENV_RLS	$fa05
	ENV_LEV $0000
	ENV_LEV $0000
	ENV_LEV $6840
	ENV_DLY $00,$0061
	ENV_END

;
; envelope #$0d
;
psg_envd:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $04,$f801
	ENV_DLY $00,$ff41
	ENV_END

;
; envelope #$0e
;
psg_enve:
	ENV_RLS	$fa05
	ENV_LEV $7c40
	ENV_DLY $08,$f801
	ENV_DLY $00,$ff41
	ENV_END

;
; envelope #$0f
;
psg_envf:
	ENV_RLS	$ff00
	ENV_LEV $7c40
	ENV_DLY $05,$fc01
	ENV_LEV $7040
	ENV_DLY $05,$fc01
	ENV_LEV $6440
	ENV_DLY $05,$fc01
	ENV_LEV $5840
	ENV_DLY $05,$fc01
	ENV_LEV $4c40
	ENV_DLY $05,$fc01
	ENV_LEV $4040
	ENV_DLY $05,$fc01
	ENV_DLY $00,$ff01
	ENV_END


