/*------------------------------------------------------------------*/
/* SongPlay.c - functions for playing songs using multiple 8k pages */
/*------------------------------------------------------------------*/

int  psgChannelStatus;
int  whichSong;

SongPlay( songno )
int       songno;
{
	/*...................................................................*/
	/* is the psg already playing a song?                                */
	/*...................................................................*/
	
    psgChannelStatus = psgMStat();
	if( psgChannelStatus != 0 )
	{
		/*........................................................*/
        /*	yes, stop the song                                    */
		/*........................................................*/
		
		psgAllStop();
	}
	/*...................................................................*/
	/* select new song data                                              */
	/*...................................................................*/

	whichSong = songno;
	SongInit( songno );
	
	/*...................................................................*/
	/* play the new song. Note we fix the index to do so.                */
	/*...................................................................*/

#asm
	ldx		_whichSong			; get song index
	lda		sngIndex,x			; lookup index in page
	sta		_whichSong			; save it
#endasm
	
	psgPlay( whichSong );
}
