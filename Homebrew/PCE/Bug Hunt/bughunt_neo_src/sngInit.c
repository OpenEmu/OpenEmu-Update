/*----------------------------------------------------------------*/
/* This file was generated using mml2pce by M.E. Ward /Aetherbyte.*/
/* File produced may be used for NON-COMMERCIAL purposes only     */
/* Please contact Arkhan at Aetherbyte for other uses.            */
/*----------------------------------------------------------------*/
/* mml2pce Copyright 2010 by M.E. Ward. Licensed to Aetherbyte.   */
/*----------------------------------------------------------------*/
/*You may not charge for any programs produced using this software*/
/*You may not disassemble and/or reverse engineer this software.  */
/*You may freely distribute any programs produced using this      */
/*software, provided you do not charge for them. You may freely   */
/*examine any and all output from mml2pce for educational purposes*/
/*----------------------------------------------------------------*/
/*You should have fun making music, and share any effects that you*/
/*feel especially proud of.                                       */
/*----------------------------------------------------------------*/


sngInit()
{
#asm
;-----------------
; set bank values 
;
	lda 	#$03
	sta	<_dh
	lda	#BANK(_sngBank1)
	sta	<_al
	lda	#BANK(_sngBank2)
	sta	<_ah
	jsr	psg_bios

;--------------------------------
; set track index table location 
;
	lda    #$04
	sta    <_dh
	lda	#LOW(TRACK_IX)
	sta	<_al
	lda	#HIGH(TRACK_IX)
	sta	<_ah
	jsr	psg_bios

;--------------------
; register modulation 
;
	lda	#7
	sta	<_dh

	lda	#LOW(MODU_IX)
	sta	<_al
	lda	#HIGH(MODU_IX)
	sta	<_ah
	jsr	psg_bios

;--------------------
; register percussion 
;
	lda	#9
	sta	<_dh

	lda	#LOW(DRUM_TAB)
	sta	<_al
	lda	#HIGH(DRUM_TAB)
	sta	<_ah
	jsr	psg_bios

;--------------------
; Set Tempo 
;
	lda	#10
	sta	<_dh

	lda	#75
	sta	<_al
	jsr	psg_bios

#endasm
}
/*---------------------------------*/
/* includes for song data          */
/*---------------------------------*/

#asm
    .data
    .bank   9
    .org    $8000
_sngBank1:
    .include  "mml/MyMML.asm"
    .code

    .data
    .bank   10
    .org    $A000
_sngBank2:
    .include  "mml/MyMML2.asm"
    .code

#endasm
