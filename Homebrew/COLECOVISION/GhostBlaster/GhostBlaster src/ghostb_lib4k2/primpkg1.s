; primpkg1.s

	.module reflect_horizontal

	; global from this code
    ; Note : This function works only if the WORK_BUFFER index
    ;        is set in the rom header at address 8006-8007.
    ;        WORK_BUFFER[0..7] to get source data
    ;        WORK_BUFFER[8..15] to set destination data

    .globl  _reflect_horizontal
    ; reflect_horizontal ( table_code : 0 = sprite_name
    ;                                   1 = sprite_generator
    ;                                   2 = name (chars on screen)
    ;                                   3 = pattern (chars pattern)
    ;                                   4 = color (chars color)
    ;                      source : index to source in vram 
    ;                      destination : index to dest. in vram
    ;                      count : number of "graphic items" to do
    ;                    )
    ;
    ; Desc. : To reflect graphic data around horizontal axis 

	.area _CODE
    
_reflect_horizontal:

    push    ix
    ld      ix,#4
    add     ix,sp
    ld      a,0(ix)
    ld      e,1(ix)
    ld      d,2(ix)
    ld      l,3(ix)
    ld      h,4(ix)
    ld      c,5(ix)
    ld      b,6(ix)
    call    0x1f6d  ; Coleco's bios reflect_horizontal function
    pop     ix
    ret
