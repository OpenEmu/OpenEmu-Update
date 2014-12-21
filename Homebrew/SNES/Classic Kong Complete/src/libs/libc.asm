.include "hdr.asm"

.section ".libc_mem" superfree

.accu 16
.index 16
.16bit

__builtin_memcpy:
memcpy:
      lda.b 4,s	; destination
      sta.b tcc__r0
      tay
      lda.b 8,s ; source
      tax
      lda.b 10,s ; source bank
      xba
      ora.b 6,s ; dest bank
      sta.b move_insn + 1
      lda.b 12,s ; length
      beq +
      dec a
      phb
      jsr move_insn
      plb
      lda.b 6,s
      sta.b tcc__r0h
+     rtl

__builtin_mempcpy:
mempcpy:
      lda.b 4,s	; destination
      sta.b tcc__r0
      tay
      lda.b 8,s ; source
      tax
      lda.b 10,s ; source bank
      xba
      ora.b 6,s ; dest bank
      sta.b move_insn + 1
      lda.b 12,s ; length
      beq +
      dec a
      phb
      jsr move_insn
      plb
+     lda.b 6,s
      sta.b tcc__r0h
      lda.b 4,s
      clc
      adc.b 12,s
      sta.b tcc__r0
      rtl

__builtin_memmove:
memmove:
      lda.b 6,s ; dest bank
      cmp.b 10,s
      beq memcpy	; different banks -> no overlap
      sta.b tcc__r0h
      lda.b 4,s ; dest 
      cmp.b 8,s ; src
      beq __local_finished ; nop
      bcc memcpy        ; dest before src -> forward
      
      sta.b tcc__r0	; dest
      clc
      adc.b 12,s	; +size -> end of dest
      tay
      lda.b 8,s ; source
      clc
      adc.b 12,s	; + size -> end of source
      tax
      lda.b 10,s ; source bank
      xba
      ora.b 6,s ; dest bank
      sta.b move_backwards_insn + 1
      lda.b 12,s ; length
      beq __local_finished
      dec a
      phb
      jsr move_backwards_insn
      plb
__local_finished: rtl


__builtin_memset:
memset:
      lda.b 4,s		; ptr
      sta.b tcc__r0
      lda.b 6,s
      sta.b tcc__r0h
      lda.b 10,s	; count
      beq +
      tay
      lda.b 8,s		; character
      sep #$20
-     dey
      sta.b [tcc__r0],y
      bne -
      rep #$20
+     rtl

__builtin_bzero:
bzero:
      lda.b 4,s
      sta.b tcc__r9
      lda.b 6,s
      sta.b tcc__r9h
      lda.b 8,s
      beq +
      tay
      lda.w #0
      sep #$20
-     dey
      sta.b [tcc__r9],y
      bne -
      rep #$20
+     rtl

.accu 16
.index 16
      
__builtin_strcmp:
strcmp:
      lda.b 4,s		; dest
      sta.b tcc__r9
      lda.b 6,s
      sta.b tcc__r9h
      lda.b 8,s		; src
      sta.b tcc__r10
      lda.b 10,s
      sta.b tcc__r10h
      ldy.w #0
      sep #$20
-     lda.b [tcc__r9],y
      sec
      sbc.b [tcc__r10],y
      beq + ; schaumermol
      bcs __local_gresser
      bcc __local_kloaner
+     lda.b [tcc__r9],y
      beq __local_gleich
      iny
      bra -
__local_gleich: rep #$20
      stz.b tcc__r0
      rtl
__local_gresser: rep #$20
      lda.w #1
      sta.b tcc__r0
      rtl
__local_kloaner: rep #$20
      lda.w #-1
      sta.b tcc__r0
      rtl

.accu 16
.index 16

__builtin_memcmp:
memcmp:
      lda.b 4,s
      sta.b tcc__r9
      lda.b 6,s
      sta.b tcc__r9h
      lda.b 8,s
      sta.b tcc__r10
      lda.b 10,s
      sta.b tcc__r10h
      lda.b 12,s
      beq __local_gleich
      tax
      ldy.w #0
      sep #$20
-     lda.b [tcc__r9],y
      sec
      sbc.b [tcc__r10],y
      beq + ; schaumermol
      bcs __local_gresser ; from strcmp
      bcc __local_kloaner
+     dex
      beq __local_gleich
      iny
      bra -

.ends