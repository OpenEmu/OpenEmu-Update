; gpupdats.s

	.module updatesprites
	
	; global from external code	
	.globl  _update_sprites0 ; from Marcel's Coleco library

	; global from this code
	.globl  _updatesprites
        ; void updatesprites(byte first, byte count)
	
	.area _CODE

_updatesprites:
                pop de
                pop hl
                push hl
                push de
		xor a
                ld c,h
                ld h,a
                ld b,a
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(0x73F2)   ; Sprite Table Index in VRAM
                add hl,de
                push bc
                push hl
                call _update_sprites0
                pop hl
                pop bc
                ret

