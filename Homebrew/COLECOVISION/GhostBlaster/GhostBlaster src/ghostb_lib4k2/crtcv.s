; crt0.s for Colecovision cart

	.module crt0
	
    ;; global from game
    .globl _update_music
    .globl _state
    ;.globl _counter_byte
    .globl _flag_prout
    .globl _toscreen
    
	;; global from this code
	.globl  _buffer32
	.globl _no_nmi
	.globl _vdp_status
	.globl _nmi_flag
	.globl _joypad_1
	.globl _keypad_1
	.globl _joypad_2
	.globl _keypad_2
	.globl snd_areas
	
	;; global from C code
	.globl _main
	.globl _nmi
	.globl _snd_table


	;; Ordering of segments for the linker - copied from sdcc crt0.s
	.area _HOME
	.area _CODE
	.area _GSINIT
	.area _GSFINAL
        
	.area _DATA
	.area _BSS
	.area _HEAP

	;; TABLE OF VARIABLES (IN RAM)
	.area	_DATA
_buffer32::
	.ds	32 ; buffer space 32    [7000-701F]
snd_addr::
	.ds	11 ; sound addresses    [7020-702A]
snd_areas::
	.ds	51 ; 5 sound slots + NULL (00h) [702B-...]
_no_nmi::
	.ds    1
_vdp_status::
	.ds    1
_nmi_flag::
	.ds    1
_joypad_1::
	.ds    1
_keypad_1::
	.ds    1
_joypad_2::
	.ds    1
_keypad_2::
	.ds    1	

	;; CARTRIDGE HEADER (IN ROM)
	.area _HEADER(ABS)
	.org 0x8000
	
	.db	0x55, 0xaa		; no default colecovision title screen => 55 AA
	.dw	0			; no copy of sprite table, etc.
	.dw	0			; all unused
	.dw	_buffer32		; work buffer
	.dw	0			; ??
	.dw	start_program	; start address for game coding
	.db	0xc9,0,0		; no RST 08 support
	.db	0xc9,0,0		; no RST 10 support
	.db	0xc9,0,0		; no RST 18 support
	.db	0xc9,0,0		; no RST 20 support
	.db	0xc9,0,0		; no RST 28 support
	.db	0xc9,0,0		; no RST 30 support
	.db	0xc9,0,0		; no RST 38 support  (spinner)

	;; CODE STARTS HERE WITH NMI
        .area _CODE
_nmi_asm:
	push	af
        ld	a,#1
        ld      (_nmi_flag),a           ; set NMI flag
        ld      a,(_no_nmi)             ; check if nmi() should be
        or      a                       ;  called
        jp      nz,nmi_exit
        inc     a
        ld      (_no_nmi),a
        call    0x1fdc                   ; get VDP status
        ld      (_vdp_status),a
        push    bc
        push    de
        push    hl
        push    ix
        push    iy
        ex      af,af'
        push    af
        exx
        push    bc
        push    de
        push    hl
        
        ;;;; JUNE 23 --- VIDEO OUT FIX + START +
        
        ld  a,(_flag_prout)
        sub #1 ;; && (flag_prout == 1)
        jr  nz,nmi_normal
        ;; ld  a,(_state)
        ;; sub #4 ;; if (state == STATE_GAME)
        ;; jr  nz,nmi_normal        
        call   _toscreen
        ld  hl,#_flag_prout
        inc(hl)
        ;ld  hl,#_counter_byte
        ;inc(hl)
        ;ld  a,#2
        ;ld  (hl),a
        jp  nmi_bypass
        
        ;;;; JUNE 23 --- VIDEO OUT FIX + END +

nmi_normal:
        call    cont_scan
        ; call    0x1f76                   ; update controllers
        ; ld      a,(0x73ee)
        ; and	#0x4f
        ; ld      (_joypad_1),a
        ; ld      a,(0x73ef)
        ; and	#0x4f
        ; ld      (_joypad_2),a
        ; ld      a,(0x73f0)
        ; and	#0x4f
        ; ld      (_keypad_1),a
        ; ld      a,(0x73f1)
        ; and	#0x4f
        ; ld      (_keypad_2),a
        ; call    decode_controllers
        call    _nmi                    ; call C function
nmi_bypass:
        call    0x1ff4                   ; update snd_addr with snd_areas
        call    _update_music
        call    0x1f61                   ; play sounds
        pop     hl
        pop     de
        pop     bc
        exx
        pop     af
        ex      af,af'
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        xor     a
        ld      (_no_nmi),a
        pop     af
        ret
nmi_exit:
        call    0x1fdc
        ld      (_vdp_status),a
        pop     af
        ret

; CTRL_0_PORT  	EQU	0FCH
; CTRL_1_PORT  	EQU	0FFH

cont_scan:
        in	a,(#0xfc)	; Read segment 0, both players
        cpl
        and #0x4f
        ld  b,a
        in	a,(#0xff)
        cpl
        and #0x4f
        ld  c,a
        out	(#0x80),a	; Strobe segment 1
        
        xor a
        ld  d,a
        
        ld  a,b
        bit 6,a
        jp  z,cont_scan_joy1a
        xor #0xc0
cont_scan_joy1a:
        ld  b,a
        in	a,(#0xfc)
        cpl
        push    af
        and #0x0f
        ld  e,a
        pop af
        and #0x40
        or  b
        ld  (_joypad_1),a
        ld  a,e        
        ld      hl,#keypad_table
        add     hl,de
        ld      a,(hl)
        ld  (_keypad_1),a

        ld  a,c
        bit 6,a
        jp  z,cont_scan_joy2a
        xor #0xc0
cont_scan_joy2a:
        ld  b,a
        in	a,(#0xff)
        cpl
        push    af
        and #0x0f
        ld  e,a
        pop af
        and #0x40
        or  b
        ld  (_joypad_2),a
        ld  a,e        
        ld      hl,#keypad_table
        add     hl,de
        ld      a,(hl)
        ld  (_keypad_2),a

        out	(#0xc0),a	; Reset to segment 0
        ret


keypad_table::
	; .db    0xff,8,4,5,0xff,7,11,2,0xff,10,0,9,3,1,6,0xff
	.db    0xff,6,1,3,9,0,10,0xff,2,11,7,0xff,5,4,8,0xff

; joypads will be decoded as follows:
; bit
; 0     left
; 1     down
; 2     right
; 3     up
; 4     --------
; 5     --------
; 6     button 2
; 7     button 1
; keypads will hold key pressed (0-11), or 0xff
; decode_controllers:
	; ld      ix, #_joypad_1
	; call    decode_controller
	; inc     ix
	; inc     ix
; decode_controller:
	; ld      a,0(ix)
	; ld      b,a
	; and     #0x40
	; rlca
	; ld      c,a
	; ld      a,b
	; and     #0x0f
	; or      c
	; ld      b,a
	; ld      a,1(ix)
	; ld      c,a
	; and     #0x40
	; or      b
	; ld      0(ix),a
	; ld      a,c
	; cpl
	; and    #0x0f
	; ld      e,a
	; ld      d,#0
	; ld      hl,#keypad_table
	; add     hl,de
	; ld      a,(hl)
	; ld      1(ix),a
	; ret


start_program:
	im       1                      ; interrupt mode -> rst 38h
	di

	xor     a                       ; clear carry
	ld      bc,#0x3b8		; ram size left
	ld      hl,#0x7000		; starting from 7000
	ld      de,#0x7001
	ld      (hl),a
	ldir                            ; zero-fill bss

	call gsinit					; Initialize global variables.

	ld	b,#5
	ld	hl,#_snd_table
	call    0x1fee                   ; init snd_areas and snd_addr + all sound off

	ld      hl,#0x0033                ; initialise random generator
	ld      (0x73c8),hl
                                                ; set screen mode 2 text
	call    0x1f85                   ; set default VDP regs 16K
	;ld      a,#0x82                  ; 16K, blank screen, no NMI, reset M1 & M3, sprites 16x16
	;ld      c,a
	;ld      b,#1
	;call    #0x1fd9
	;ld      bc,#0x039f                ; vdp_out(3,9fh)
	;call    0x1fd9
	;ld      bc,#0x0400                ; vdp_out(4,0)
	;call    0x1fd9
	;ld      bc,#0x0002                ; vdp_out(0,2) ; set mode 2
	;call    0x1fd9
	ld      de,#0x4000                ; clear VRAM
	xor     a
	ld      l,a
	ld      h,a
	call    0x1f82
	
	; call main rountine
	jp      _main
	
	.area _GSINIT
gsinit::
	.area _GSFINAL
	ret
	;
