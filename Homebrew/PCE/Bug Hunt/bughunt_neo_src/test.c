#include "huc.h"

#include "defs.c"

#include "sound/psglib.c"
#include "snginit.c"
int VSyncCnt;
int TimerCnt;
int MainCnt;
int SubCnt;
	int  psgMainStatus;
	int  psgSubStatus;



#include "fps.c"
#include "levels.c"


#define XRES    256

#incpal(p0_pal_data,"gfx/spr0.pcx");
#incspr(p0_spr_data,"gfx/spr0.pcx");
#incpal(en_pal_data,"gfx/enemies.pcx");
#incspr(en_spr_data,"gfx/enemies.pcx");
#incspr(en_spr_data2,"gfx/enemies2.pcx");

#inctile_ex(tileset,"gfx/tileset.pcx",0,0,20,8,1);
#incpal(tile_pal,"gfx/tileset.pcx");
#incbin(tilemap,"gfx/background.fmp");

#incchr(neo_font,"gfx/font.pcx");
#incpal(neo_font_pal,"gfx/font.pcx");

int rs;
int t;
int foo;
int bar;
int h,i,j,k;
int joy0,lastjoy0;
int joy1,lastjoy1;


#define t0num   53
#define p0num   52
#define p0pal   17
#define ennum   0
#define enpal   18

int p0x,p0y;
char p0spd;
char p0dir;
#define DIR_LEFT    0
#define DIR_RIGHT   1
char p0state;
#define PST_WAIT    0
#define PST_OUT     1
#define PST_DIE     2
char p0tonguespd;
int p0tongue;
#define MAX_TONGUE  144

#define MAX_EN  36
char num_en,en_t;
char en_wait,en_delay;
char en_spawned; 
int en_x[MAX_EN],en_y[MAX_EN];
char en_spd[MAX_EN],en_dir[MAX_EN],en_state[MAX_EN];
#define EST_NULL    0
#define EST_FLY     1
#define EST_STUCK   2
char en_type[MAX_EN];
#define ET_FLY      0
#define ET_DRAGON   1
#define ET_WASP     2
#define ET_MAX      3

int k_moveleft,k_moveright,k_tongueup,k_tonguedown,k_pause;

char gameover;
char level,hilevel;
char music;
int score,hiscore;
int time;
int pdt;
char pf;

loopSong(){
    psgMainStatus = psgMStat();
	psgSubStatus  = psgSStat();
    if(psgMainStatus==0){
        psgPlay(music+2);
    }
}

#include "menu.c"

main(){
    rs=0;
    level=5;
    music=1;
    hiscore=20;
    hilevel=0;


    init_satb();
    set_screen_size(SCR_SIZE_64x32);

	psgInit(5);
	psgOn(0);
	psgPlay(1);

	sngInit();
	psgDelay( 0 );


    neosplash();

    load_font(neo_font,224);
    load_palette(0,neo_font_pal,1);
    set_color_rgb(1,7,7,7);
    set_color_rgb(2,0,2,0);

    squirrelsplash();

  while(1){
    title();



    load_palette(1,tile_pal,1);
    set_tile_data(tileset);
    load_tile(0x1000);
    set_map_data(tilemap,16,14);
    load_map(0,0,0,0,16,14);

    load_palette(p0pal,p0_pal_data,1);
    load_palette(enpal,en_pal_data,1);
    load_vram(0x5000,p0_spr_data,0x800);
    load_vram(0x6000,en_spr_data,0x300);

    num_en=LD_en_num[level];
    /*init enemies list*/
    for(i=0;i<num_en;i++){
        spr_set(ennum+i);
        spr_ctrl(SIZE_MAS,SZ_32x32);
        spr_pal(enpal);
        spr_pri(1);
        en_state[i]=EST_NULL;
    }

    p0x=128;
    p0y=224-48;
    spr_set(p0num);
    spr_ctrl(SIZE_MAS,SZ_32x32);
    spr_ctrl(FLIP_MAS,NO_FLIP_X);
    spr_pattern(0x5000);
    spr_pal(p0pal);
    spr_pri(1);

    spr_set(t0num);
    spr_ctrl(SIZE_MAS,SZ_16x16);
    spr_pattern(0x5600);
    spr_pal(p0pal);
    spr_pri(1);
    for(i=1;i<10;i++){
        spr_set(t0num+i);
        spr_ctrl(SIZE_MAS,SZ_16x16);
        spr_pattern(0x5640);
        spr_pal(p0pal);
        spr_pri(1);
    }
    en_t=0;

    k_moveleft=JOY_LEFT;
    k_moveright=JOY_RGHT;
    k_tongueup=JOY_UP;
    k_tonguedown=JOY_DOWN;
    k_pause=JOY_STRT;

    p0dir=DIR_LEFT;
    p0state=PST_WAIT;
    p0spd=2;
    p0tongue=0;
    p0tonguespd=4;


    score=0;
    time=0;
    gameover=0;

    en_wait=0;
    en_delay=LD_en_delay[level];

    draw_win(1,23,7,5);
    draw_win(22,23,9,5);
    put_string("LEVEL",2,24);
    put_number(level,1,4,26);
    put_string("SCORE",24,24);
    put_string("00",28,26);
    pdt=0;
    pf=0;
    while(1){
    put_number(level,1,4,26);
        if(score) put_number(score,5,23,26);
        if(p0state!=PST_DIE)
            loopSong();
        lastjoy0=joy0;
/*        fps();*/
        vsync();
        joy0=joy(0);
        satb_update();




        spr_set(p0num);

        if(p0state!=PST_DIE){
             if(joy0&k_pause && !(lastjoy0&k_pause)){
                /*pause game*/
                pause();
            }


            if(joy0&k_moveleft){
                p0x-=p0spd;
                if(p0x<0)p0x=0;
                if(p0dir!=DIR_LEFT){
                    p0dir=DIR_LEFT;
                    spr_ctrl(FLIP_MAS,NO_FLIP_X);
                }
            }else if(joy0&k_moveright){
                p0x+=p0spd;
                if(p0x>254)p0x=254;
                if(p0dir!=DIR_RIGHT){
                    p0dir=DIR_RIGHT;
                    spr_ctrl(FLIP_MAS,FLIP_X);
                }
            }
            spr_x(p0x-15);
            spr_y(p0y-23);
            if(joy0&k_tongueup){
                if(p0state!=PST_OUT){
                    p0state=PST_OUT;
                    spr_pattern(0x5100);
                }
                p0tongue+=p0tonguespd;
                if(p0tongue>MAX_TONGUE)p0tongue=MAX_TONGUE;
            }else if(joy0&k_tonguedown){
                p0tongue-=p0tonguespd;
                if(p0tongue<=0){
                    p0tongue=0;
                    if(p0state!=PST_WAIT){
                        p0state=PST_WAIT;
                        spr_pattern(0x5000);
                    }
                }
            }
        }else{
            /*player death*/
            pdt++;
            if(pdt%15==0){
                pf++;
                if(pf>=4)pf=0;
                spr_pattern(0x5200+(0x100*pf));
            }
            if(pdt>200){
                break;
            }
        }

        spr_set(t0num);
        if(p0state!=PST_OUT){
            spr_hide();
        }else{
            spr_x(p0x-7);
            spr_y(p0y-32-p0tongue);
        }
        for(i=1;i<10;i++){
            spr_set(t0num+i);
            if(p0tongue>=i*16-8){
                spr_x(p0x-7);
                spr_y(p0y-23-i*16);
            }else{
                spr_hide();
            }

        }
        
        /*upd enemies*/
        en_t++;
        if(en_t%3==0){
            load_vram(0x6000,en_spr_data2+0x000,0x80);
            load_vram(0x6200,en_spr_data +0x200,0x80);
        }else if(en_t%3==1){
            load_vram(0x6100,en_spr_data2+0x100,0x80);
            load_vram(0x6000,en_spr_data +0x000,0x80);
        }else if(en_t%3==2){
            load_vram(0x6200,en_spr_data2+0x200,0x80);
            load_vram(0x6100,en_spr_data +0x100,0x80);
        }


        if(en_wait>=en_delay)
            en_wait=0;
        else
            en_wait++;
        en_spawned=0;
        for(i=0;i<num_en;i++){
            if(en_state[i]==EST_NULL && !en_spawned){
                spawn();
                en_spawned=1;
            }
            if(en_state[i]==EST_FLY){
                if(en_wait>=en_delay){
                    if(en_dir[i]==DIR_LEFT){
                        en_x[i]-=en_spd[i];
                        if(en_x[i]<-16)en_state[i]=EST_NULL;
                    }else{
                        en_x[i]+=en_spd[i];
                        if(en_x[i]>256+16)en_state[i]=EST_NULL;
                    }
                }

                if(p0state==PST_OUT){
                    if(en_x[i]<p0x+8 && en_x[i]>p0x-8){
                        if(en_y[i]>p0y-37-p0tongue){
                            if(en_type[i]==ET_WASP){
                                p0state=PST_DIE;
                                p0tongue=0;
                                psgPlay(1);
                                spr_set(p0num);
                                spr_pattern(0x5200);
                                draw_win(9,23,12,5);
                                put_string("GAMEOVER",11,25);
                            }else{
                                en_state[i]=EST_STUCK;
                                psgPlay(SFX_GOOD);
                            }
                        }
                    }
                }

                spr_set(ennum+i);
                if(en_x[i]>-16 && en_x[i]<255+16){
                    spr_x(en_x[i]-16);
                    spr_y(en_y[i]-16);
                }else{
                    spr_hide();
                }
            }
            if(en_state[i]==EST_STUCK){
                en_x[i]=p0x;
                if(en_y[i]<p0y-34-p0tongue) en_y[i]=p0y-34-p0tongue;

                spr_set(ennum+i);
                if(p0state!=PST_OUT){
                    spr_hide();

                    if(p0state!=PST_DIE){
                        if(en_type[i]==ET_FLY) score+=1;
                        else if(en_type[i]==ET_DRAGON) score+=5;
                        psgPlay(SFX_OK);
                    }
                    en_state[i]=EST_NULL;



                }else{

                    spr_x(en_x[i]-16);
                    spr_y(en_y[i]-16);
                }
            }
        }



    }
    if(score>=hiscore){
        hiscore=score;
        hilevel=level;
    }
    disp_off();
    for(i=0;i<64;i++){
        spr_set(i);
        spr_hide();
    }
    satb_update();
    cls();
    disp_on();
  }
}

spawn(){
    foo=rand();
    en_state[i]=EST_FLY;
    en_dir[i]=foo%2;

    bar=foo%100;
    if(bar<LD_en_dragon_prob[level]){
        en_type[i]=ET_DRAGON;
    }else if(bar < (LD_en_dragon_prob[level]+LD_en_fly_prob[level]) ){

        en_type[i]=ET_FLY;
    }else{
        en_type[i]=ET_WASP;

    }
    if(en_type[i]==ET_DRAGON)en_spd[i]=2;
    else en_spd[i]=1;
    if(en_dir[i]==DIR_LEFT){
        en_x[i]=255+16+16*(foo%14);
    }else{
        en_x[i]=-256+16*(foo%14);
    }
    en_y[i]=16+16*(foo%9);

    spr_set(ennum+i);
    spr_pattern(0x6000+(en_type[i]*0x100));
    spr_ctrl(FLIP_MAS,FLIP_X*en_dir[i]);
}

pause(){
    while(joy0&k_pause){
        vsync(); joy0=joy(0);
    }
    while(!(joy0&k_pause)){
        vsync(); joy0=joy(0);
    }

    while(joy0&k_pause){
        vsync(); joy0=joy(0);
    }
}

