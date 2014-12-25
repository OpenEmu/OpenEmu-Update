;-----------------------------------------------------------------------------
; sound.asm - the squirrel MML player, which can be used to control the psg
;-----------------------------------------------------------------------------
; modified mar 2010 by Micheal E. Ward. 
; Copyright 2010 by M.E. Ward. All rights reserved
;.............................................................................
; this file should contain the PSG_BIOS dispatch routine and the player 
; routine. The actual PSG_BIOS functions are in a different file and page, to
; minimize the code space used in the irq handler (startup) page
;*****************************************************************************
; this is the actual psg-bios interface. All PSG_BIOS functions are called from
; here. 
; Note that the actual functions may be in a different page of memory; hence, 
; we have to map them in before we call them. All PSG_BIOS functions MUST
; reside in the same page of memory.
;-----------------------------------------------------------------------------------
;  IN:  _DH = function number
; OUT:  _AX = function return value (if any)
; USE:  _X and _Y are preserved
;       _A is trashed
;............................................................................
; I'm not sure if this is the correct name or not, but it should work

psg_bios:

	;------------------------------------------------------------------------
	; save contents of X and Y registers, so they are not lost
	
	phx							; save contents of X register
	phy							; save contents of Y register
	
	;------------------------------------------------------------------------
	; this maps the bios functions into the cpu address space.
	
	tma	#PAGE(psgOn)			; get page number for code in 'our' area
	pha							; save it
	
	lda	#BANK(psgOn)			; load page number for our code.
	tam	#PAGE(psgOn)			; map the code in

	;------------------------------------------------------------------------
	; validate function number
		
	lda		<_dh					; get function number
    cmp		#psgBiosEntries			; in valid range ?
    bcs		.psgBadParam			; skip call if out of range

	;------------------------------------------------------------------------
	; this calls the actual function code, via indirection. 
	
	asl		A						; 2 bytes per address
	tax								; place offset into index register
	lda		<_al					; get parameter
	
	jsr		psgBiosCall				; call the function from the table, as a sub-routine

	;------------------------------------------------------------------------
	; restore the original code that we mapped out

.psgBadParam:
	
	tax								; save any return value in X. 

	pla								; get page number for original code
	tam		#PAGE(psgOn)			; map original code back in
		
	txa								; restore the original return value
	
	;------------------------------------------------------------------------
	; restore original register values
	
	ply
	plx
	rts

;----------------------------------------------------------------------------------------
; this is used to call the actual bios functions.
;----------------------------------------------------------------------------------------

psgBiosCall:	
	jmp		[psgBiosTable,X]

;----------------------------------------------------------------------------------------
; the PSG-BIOS functions. The table needs to be in this page, so we can call them
; after we map them in. (NOTE: the actual functions MAY be in a different page)
;----------------------------------------------------------------------------------------

psgBiosTable:	
		.dw	psgOn			; psg_on       (00)
		.dw	psgOff			; psg_off      (01)
		.dw	psgInit			; psg_init     (02)
		.dw	psgBank			; psg_bank     (03)
		.dw	psgTrack		; psg_track    (04)
		.dw	psgWave			; psg_wave     (05)
		.dw	psgEnv	 		; psg_env      (06)
		.dw	psgFM			; psg_fm       (07)
		.dw	psgPE			; psg_pe       (08)
		.dw	psgPC			; psg_pc       (09)
		.dw	psgSetTempo		; psg_settempo (0a)
		.dw	psgPlay			; psg_play     (0b)
		.dw	psgMStat		; psg_mstat    (0c)
		.dw	psgSStat		; psg_sstat    (0d)
		.dw	psgMStop		; psg_mstop    (0e)
		.dw	psgSStop		; psg_sstop    (0f)
		.dw	psgAStop		; psg_astop    (10)
		.dw	psgMvOff		; psg_mvoff    (11)
		.dw	psgCont			; psg_cont     (12)
		.dw	psgFadeOut		; psg_fdout    (13)
		.dw	psgDCnt			; psg_dcnt     (14)

psgBiosTableEnd = *			; table end is here
psgBiosEntries  = (psgBiosTableEnd - psgBiosTable) / 2

;-----------------------------------------------------------------------------------------------
; this brings in the psg_bios functions. As promised, they are in a seperate bank.
;-----------------------------------------------------------------------------------------------


	.bank		PSG_BANK,"PSG Driver"
	.include	"main\PsgBiosFuncs.asm"

;...............................................................................................
; These are the driver rountines. Note that it's pretty big, which is why
; we go through all the hoops to run it from the non-fixed page :-)
;...............................................................................................
; this brings in the actual main track driver routine pieces. 
;...............................................................................................	
	
	.include 	"main\psgDrive.asm"				; the main track driver routine
	.include    "main\mmlParse.asm"				; mml data parser
	.include	"main\bytecodes.asm"			; mml operations
	.include	"main\volume.asm"			; volume control
	.include    "main\drums.asm"				; percussion / noise control
	.include	"main\adsr.asm"				; volume envelope handler
	.include    "main\freqEnv.asm"			; frequency processing
	.include    "main\fade.asm"				; fade-out processing.
	.include	"main\output.asm"			; output to hardware

;...............................................................................................
; this brings in the actual sub track driver routine pieces. 
;...............................................................................................	
	
	.include	"sub\psgDrive.asm"
	.include	"sub\mmlParse.asm"
	.include	"sub\bytecodes.asm"
	.include	"sub\volume.asm"
	.include	"sub\drums.asm"
	.include	"sub\adsr.asm"
	.include	"sub\freqEnv.asm"
	.include	"sub\fade.asm"
	.include	"sub\output.asm"
	
;...............................................................................................	
; the data tables we use.

	.include	"data\freqTable.inc"
	.include	"data\tempoTable.inc"
	.include	"data\envelopes.inc"
	.include    "data\waveTable.inc"
;
; now, return context to bank established in
; file which included this
;
	.bank		START_BANK

