


#incpal(badge1pal,"gfx/badge1tiles.pcx");
#inctile_ex(neotiles,"gfx/NEO_BADGE_16.pcx",0,0,14,14,0);
#incpal(neosprpal,"gfx/text.pcx");
#incspr(neospr,"gfx/text.pcx");

#inctile_ex(title_tiles,"gfx/title1.pcx",0,0,16,4,15);
#incpal(title_pal,"gfx/title1.pcx");

squirrelsplash(){
    disp_off();
    cls();
    foo=6;

    put_string("           PC  Engine           ",0,foo);
    put_string("        MML Sound Library       ",0,2+foo);
    put_string("           'SQUIRREL'           ",0,4+foo);
    put_string("         By: Aetherbyte         ",0,6+foo);
    put_string("   http://www.aetherbyte.com/   ",0,8+foo);

    foo++;

    put_string("  Game concept and graphics by  ",0,12+foo);
    put_string("   http://lazybraingames.com/   ",0,14+foo);

    disp_on();

    bar=0;
    while(1){
        lastjoy0=joy0;
        vsync();
        bar++;
        joy0=joy(0);
        if(joy0&JOY_STRT)break;
        if(bar>90)break;
    }
    cls();
    while(joy0&JOY_STRT){
        vsync();
        joy0=joy(0);
    }



}

neosplash(){
    disp_off();
    cls();
    load_palette(16,neosprpal,1);
    load_vram(0x5000,neospr,0x400);
    load_palette(0,badge1pal,1);
    set_tile_data(neotiles);
    load_tile(0x1000);
    for(j=0;j<14;j++){
        for(i=0;i<14;i++){
            put_tile(j*14+i,i+1,j);
        }
    }

    for(i=0;i<8;i++){
        spr_set(i);
        spr_pal(0);
        spr_pri(1);
        spr_ctrl(SIZE_MAS,SZ_32x16);
        spr_pattern(0x5000+0x80*i);
        spr_y(224-24);
        spr_x(i*32);
    }
    disp_on();
    t=0;
    for(;;){
        t++;

        vsync();
        joy0=joy(0);
        satb_update();
        if(joy0&JOY_STRT){
            break;
        }
        if(t>144)break;
    }
    psgPlay(0);
    disp_off();
    for(i=0;i<8;i++){
        spr_set(i);
        spr_hide();
    }
    satb_update();
    cls();
    set_color(0,0);
    set_color(256,0);
    disp_on();

    while(joy0&JOY_STRT){
        vsync();
        joy0=joy(0);
    }


}



title(){
    psgPlay(2);
    cls();

    set_tile_data(title_tiles);
    load_tile(0x1000);
    load_palette(15,title_pal,1);
    for(i=0;i<16;i++){
        for(j=0;j<4;j++){
            put_tile(j*16+i,i,j+1);
        }
    }

    for(i=0;i<8;i++){
        set_color_rgb(241+i,0,7-i,0);
        set_color_rgb(248+i,i,7,i);
        if(248+7+i<256)set_color_rgb(248+7+i,7,i,7);
    }

    draw_win(1,21,30,6);
    put_string(" HI-SCORE       00         LV 0",0,1);
    put_number(hiscore,5,11,1);
    put_number(hilevel,1,30,1);
    put_string("PC Engine version by cabbage",2,22);
    put_string(" NEO Retro Coding Compo 2013",2,24);
    put_string("  http://www.neoflash.com/  ",2,25);
    put_string("PUSH RUN BUTTON !",8,15);

    foo=1;
    t=0;
    while(1){
        rs++;
        lastjoy0=joy0;
        vsync();
        joy0=joy(0);
        t++;
        if(t>30){
            if(foo==0){
                put_string("                 ",8,15);
                foo=1;
                t=0;
            }else{
                put_string("PUSH RUN BUTTON !",8,15);
                foo=0;
                t=0;
            }
        }

        if(joy0&JOY_STRT){
            break;
        }

        title_color_cycle();

    }

    while(joy0&JOY_STRT){
        vsync(); joy0=joy(0);
    }

    put_string("                 ",8,15);
    srand(rs);
    config();

}

title_color_cycle(){
    h=get_color(241);
    for(i=1;i<15;i++){
        k=get_color(240+i+1);
        set_color(240+i,k);
    }
    set_color(255,h);
}

config(){
    psgPlay(0);

    draw_win(5,13,9,5);
    draw_win(18,13,9,5);
    put_string("LEVEL",6,15);
    put_string("MUSIC",19,15);

    put_number(level,1,12,15);
    put_number(music,1,25,15);

    bar=0;
    foo=0;
    while(bar==0){
        psgPlay(0);
        put_string("<",12,14);
        put_string(">",12,16);
        while(foo==0){
            title_color_cycle();
            lastjoy0=joy0;
            vsync();
            joy0=joy(0);
            if( (joy0&JOY_A && !(lastjoy0&JOY_A)) || (joy0&JOY_RGHT && !(lastjoy0&JOY_RGHT)) ){
                put_string(" ",12,14);
                put_string(" ",12,16);
                foo=1;
                psgPlay(7);
            }
            if(joy0&JOY_UP&&!(lastjoy0&JOY_UP)){
                if(level<9)
                    level++;
                else
                    level=0;
                put_number(level,1,12,15);
                psgPlay(7);
            }else if(joy0&JOY_DOWN && !(lastjoy0&JOY_DOWN)){
                if(level>0)
                    level--;
                else
                    level=9;
                put_number(level,1,12,15);
                psgPlay(7);
            }

            if(joy0&JOY_STRT && !(lastjoy0&JOY_STRT)){
                foo=255;
                bar=1;
                psgPlay(7);
            }
        }

        psgPlay(music+2);
        put_string("<",25,14);
        put_string(">",25,16);
        while(foo==1){
            loopSong();
            title_color_cycle();
            lastjoy0=joy0;
            vsync();
            joy0=joy(0);

            if( (joy0&JOY_B && !(lastjoy0&JOY_B)) || (joy0&JOY_LEFT && !(lastjoy0&JOY_LEFT)) ){
                put_string(" ",25,14);
                put_string(" ",25,16);
                foo=0;
                psgPlay(7);
            }

            if(joy0&JOY_A && !(lastjoy0&JOY_A)){
                foo=255;
                bar=1;
                psgPlay(7);
            }
            if(joy0&JOY_UP&&!(lastjoy0&JOY_UP)){
                psgPlay(7);
                if(music<4)
                    music++;
                else
                    music=0;
                put_number(music,1,25,15);
                psgPlay(music+2);
            }else if(joy0&JOY_DOWN && !(lastjoy0&JOY_DOWN)){
                psgPlay(7);
                if(music>0)
                    music--;
                else
                    music=4;
                put_number(music,1,25,15);
                psgPlay(music+2);
            }

            if(joy0&JOY_STRT && !(lastjoy0&JOY_STRT)){
                foo=255;
                bar=1;
                psgPlay(7);
            }

        }
    }
    cls();


}



draw_win(wx,wy,ww,wh)char wx;char wy;char ww;char wh;{
    for(i=1;i<ww-1;i++){
        put_string("_",wx+i,wy);
        put_string("^",wx+i,wy+wh-1);
        for(j=1;j<wh-1;j++){
            put_string(" ",wx+i,wy+j);
        }
    }
    for(i=1;i<wh-1;i++){
        put_string("[",wx,wy+i);
        put_string("{",wx+ww-1,wy+i);
    }

    put_string("\\",wx,wy);
    put_string("]",wx+ww-1,wy);
    put_string("|",wx,wy+wh-1);
    put_string("}",wx+ww-1,wy+wh-1);
}


