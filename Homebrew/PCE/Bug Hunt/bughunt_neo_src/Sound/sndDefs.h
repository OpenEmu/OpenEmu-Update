/*-------------------------------------------------------------------------------------------*/
/* sndDefs.h - sound function definitions. In assembler.                                     */
/*...........................................................................................*/

#ifndef  _SND_DEFS_H_
#define  _SND_DEFS_H_

/*------------------------------------------------------------------------------------*/
/* irq identifiers for psgOn                                                          */
/*------------------------------------------------------------------------------------*/

#define  IRQ_TIMER      0
#define  IRQ_VSYNC      1

/*------------------------------------------------------------------------------------*/
/* system identifiers for psgInit()                                                   */
/*------------------------------------------------------------------------------------*/

#define  MAIN_ONLY    0
#define  SUB_ONLY     1
#define  BOTH_60HZ    2
#define  BOTH_120HZ   3
#define  BOTH_240HZ   4
#define  BOTH_300HZ   5
    

#asm



;----------------------------------------------------------------------------------------
; these are the various registers on the PSG. Definately not complete
;----------------------------------------------------------------------------------------

ChannelSelect       equ    $0800
MainVolume          equ    $0801

ChanFreqLo          equ    $0802
ChanFreqHi          equ    $0803
ChanControl         equ    $0804
ChanBalance         equ    $0805
ChanData            equ    $0806

ChanON              equ    $80
ChanDDA             equ    $40
ChanVolume          equ    $1F

;----------------------------------------------------------------------------------------
; these are useful masks for dealing with the psg.
;----------------------------------------------------------------------------------------

ChanXFer            equ    $0           ; transfer to channel
ChanReset           equ    $40          ; channel off, dda On => reset

LeftVolume          equ    $F0
RightVolume         equ    $0F

#endasm

/*.............................................................................................*/
/* these are the signatures for the PSG functions in the library.                              */
/* Yes, they are supposed to be commented out. This is just for reference.                     */
/*.............................................................................................*/
/*

void initPSG( void )                           - initialize PSG hardware. Silences All Channels.
void loadWave( char Channel,  char *WavePtr )  - load wave @ WavePtr to Channel
void setFreq(  char Channel,  int   Freq    )  - set channel wave to play at given frequency

void setMainVol( char Left,   char Right    )  - set main volume to given values (0-15!)
void setChannelBalance( char Channel, char Left, char Right )

*/

#asm
;----------------------------------------------------------------------------------------
; these are the various CD-BIOS MML Functions. Definately not complete
;----------------------------------------------------------------------------------------

PSGF_ON			.equ	$00
PSGF_OFF		.equ    $01
PSGF_INIT		.equ	$02
PSGF_BANK		.equ    $03			; already defined 
PSGF_TRACK  		.equ    $04
PSGF_WAVE		.equ    $05
PSGF_ENV		.equ    $06
PSGF_FM			.equ    $07
PSGF_PE			.equ    $08
PSGF_PC			.equ    $09
PSGF_TEMPO		.equ	$10
PSGF_PLAY		.equ	$0B
PSGF_MSTAT		.equ	$0c
PSGF_SSTAT		.equ	$0D
PSGF_MSTOP		.equ	$0E
PSGF_SSTOP		.equ    $0F

PSGF_ASTOP		.equ    $10
PSGF_MVOFF 		.equ    $11
PSGF_CONT    	.equ	$12
PSGF_FDOUT		.equ	$13
PSGF_DCNT		.equ	$14

#endasm

#endif
