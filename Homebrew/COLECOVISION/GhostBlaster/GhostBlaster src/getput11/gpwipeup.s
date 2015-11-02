; gpwipeup.s

		.module wipe_off

		.globl  _delay	; from coleco library
		.globl  _wipe_off_up
                ; wipe_off_up (void)

    .AREA   _CODE
    
_wipe_off_up:
                ld hl,(0x73FA)
                ld de,#0x17FF
                add hl,de
                ld b,#24
$1:                
                push bc
                ld b,#8
$2:                
                push bc
                ld de,#1
                push hl
                push de
                call _delay
                pop de
                pop hl
                ld b,#32
$3:
                xor a
                push de
                call 0x1F82
                ld de, #0xFFF8 ; = -8
                add hl,de
                pop de
                djnz $3
                
                ld de, #0x00FF ; = +255
                add hl,de                
                pop bc
                djnz $2

                ld de, #0xFF08 ; = -248
                add hl,de                
                pop bc
                djnz $1
                
                ret
