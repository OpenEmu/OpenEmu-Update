;-----------------------------------------------------------------------------
; octaveOffsets - offset from base of frequency table for beginning note
;                 of given octave.
;.............................................................................

octaveOffsets
	.db		 0		; octave 0 * 12 notes * 2 bytes per freq
	.db		24		; octave 1 * 12 notes * 2 bytes per freq
	.db		48		; octave 2 * 12 notes * 2 bytes per freq
	.db		72		; octave 3 * 12 notes * 2 bytes per freq
	.db		96		; octave 4 * 12 notes * 2 bytes per freq
	.db		120		; octave 5 * 12 notes * 2 bytes per freq
	.db		144		; octave 6 * 12 notes * 2 bytes per freq
	.db		168		; octave 7 * 12 notes * 2 bytes per freq
