; gpcolor.s

		.module load_color

                .globl  _load_color
                ; load_color (table)

    .AREA   _CODE

_load_color:
                pop     bc
                pop     de
                push    de
                push    bc

                ld      hl,(0x73FA)		    ; hl = offset = COLTAB

                di
		ld      a,(0x1D43)
		ld      c,a  ;; (1D43h) = 0bfh
                out	(c),l
                ld 	a,h
                or 	#0x40
                out	(c),a	; SET VIDEO ADDR
                ei
                
                ex      de,hl

                ld	b,#0x20
		ld      a,(0x1D47)
		ld      c,a  ;; (1D47h) = 0beh
$1:
		ld	d,(hl)
                ld      a,#0x40
$2:
		out	(c),d 	; SEND DATA TO VIDEO
                dec	a
                or	a
                jr	nz,$2
                inc	hl
                dec	b
                ld      a,b
                or	a
                jr	nz,$1

                jp	0x1FDC	; get vdp status

