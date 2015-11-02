#define NO_SPRITES

#include <coleco.h>
#include <getput1.h>

/* CRTCV.S */
//extern byte *buffer32;

/* umusic.s */
extern void update_music(void);

/* asm.s */
extern void asm_engine(void);
extern void wait_displayed(void);
/*
extern void laserbeam(void);
extern void ghostanim(void);
extern void player_joystick(void);
extern void update_playerstate(void);
*/

/* pages.c */
extern const byte PAGE1[];
extern const byte PAGE2[];

/* endings.c */
extern const byte ENDING1[];
extern const byte ENDING2[];

/* blocks.s */
extern void blocks(void);
extern void toscreen(void);
extern void wipeout_asm(void);
extern void getlevelvram(void);

/* graphx.c */
extern const byte PATTERNRLE[];
extern const byte FONTRLE[];
extern const byte COLORRLE[];
extern const byte SCR_TITLE[];
extern const byte SCR_OPTIONS[];
extern const byte SCR_OPTIONS2[];

/* ghosts.c */
extern const byte sprLegsRLE[];

/* explosion.c */
extern const byte sprExplosionRLE[];

/* moons.c */
extern const byte MOON_PATTERNRLE[];
extern const byte MOON_COLORRLE[];

/* fairy.c */
extern const byte sprFairyRLE[];
extern const byte sprFairyATTR[];

/* levels.c */
extern void setup_level(void);

volatile int anim_position;

struct coord {
    byte y;
    byte x;
} camera;

#define STATE_IDLE 0
#define STATE_TITLE 1
#define STATE_OPTIONS 2
#define STATE_LEVELID 3
#define STATE_GAME 4
#define STATE_WIPEOUT 5
#define STATE_FONT 6
#define STATE_FONT2 7
#define STATE_BONUS 8
#define STATE_BONUS_GET1 9
#define STATE_BONUS_GET2 10
#define STATE_BONUS_GET3 11
#define STATE_BONUS_GET4 12
#define STATE_BONUS_GET5 13
#define STATE_BONUS_GET6 14
#define STATE_BONUS_GET7 15
#define STATE_BONUS_GET8 16
#define STATE_ENDING 8
#define STATE_OPTIONS2 17

volatile byte state;

#define PLAYER_DEFAULT  0
#define PLAYER_JUMP     1
#define PLAYER_FALL     2

volatile byte player_state;

volatile byte flag_prout;
volatile unsigned int counter;
volatile byte counter_byte;

byte buffer_scr[673];

volatile byte getcollectable;

volatile byte JUMP_MASK;

volatile char dx;
volatile byte pl_animframe;

volatile byte sprites[12];

static const byte BlueColors[] = {
    0x41,0x41,0x51,0x41,0x51,0x51,0x71,0x51,
    0x71,0x71,0x51,0x71,0x51,0x51,0x41,0x51,
    0x41,0x41,0x51,0x41,0x51,0x51,0x71};

static const byte GreenColors[] = {
    0xc1,0xc1,0x21,0xc1,0x21,0x21,0x31,0x21,
    0x31,0x31,0x21,0x31,0x21,0x21,0xc1,0x21,
    0xc1,0xc1,0x21,0xc1,0x21,0x21,0x31};

static const byte YellowColors[] = {
    0xa1,0xa1,0xb1,0xa1,0xb1,0xb1,0xf1,0xb1,
    0xf1,0xf1,0xb1,0xf1,0xb1,0xb1,0xa1,0xb1,
    0xa1,0xa1,0xb1,0xa1,0xb1,0xb1,0xf1};

static const byte SprOption1[] = {
    0x48,0x1c,0x00,0x0f,0xd0
};

static const byte SprOption2[] = {
    0x60,0x1c,0x00,0x0f,0xd0
};

byte    level_number;
byte    *GHOSTRLE;
byte    *GHOSTMOVEMENT;
byte    GHOSTCOLOR1;
byte    GHOSTCOLOR2;
byte    GHOSTENERGY1;
byte    GHOSTENERGY2;    
byte    *LEVELNAME;
byte    *LEVELDATA;

byte    player_health;
byte    player_energy;
    
byte    haunted_flag;
byte    ghost_counter;

byte    ghost_e1;
byte    ghost_e2;

//byte    length;
byte    laser_x0;
byte    laser_x1;

byte    fullgame_flag;

char deplacement_y;
char deplacement_x;

volatile byte flag_letters;
volatile byte flag_end;
volatile byte flag_saut;
byte letters;
byte saut;

const char bar[] = {
    32, 32, 32, 32, 32, 32, 32, 32,
    22, 32, 32, 32, 32, 32, 32, 32,
    21, 32, 32, 32, 32, 32, 32, 32,
    21, 22, 32, 32, 32, 32, 32, 32,
    21, 21, 32, 32, 32, 32, 32, 32,
    21, 21, 22, 32, 32, 32, 32, 32,
    21, 21, 21, 32, 32, 32, 32, 32,
    21, 21, 21, 22, 32, 32, 32, 32,
    21, 21, 21, 21, 32, 32, 32, 32,
    21, 21, 21, 21, 22, 32, 32, 32,
    21, 21, 21, 21, 21, 32, 32, 32,
    21, 21, 21, 21, 21, 22, 32, 32,
    21, 21, 21, 21, 21, 21, 32, 32,
    21, 21, 21, 21, 21, 21, 22, 32,
    21, 21, 21, 21, 21, 21, 21, 32,
    21, 21, 21, 21, 21, 21, 21, 22,
    //21, 21, 21, 21, 21, 21, 21, 21,
    };

void black_out()
{
    vdp_out0(0x82,1); /* 16K, SCREEN OFF, DISABLE NMI, 16x16 SPRITES */     
}

void display()
{
    vdp_out0(0xe2,1); /* 16K, SCREEN ON, ENABLE NMI, 16x16 SPRITES */     
}

/*
void update_music(void) {
    counter++;
    if (counter<2701)
    {
        if (counter<1213)
        {
            switch (counter)
            {
                case    1:      //  00 01
                    mute_all();
                    play_sound(1);
                    play_sound(2);
                    break;
                case    97:     //  00 61
                    play_sound(3);
                    play_sound(4);
                    play_sound(5);
                    play_sound(6);
                    break;
                case    717:    //  02 CD
                    play_sound(7);
                    play_sound(8);
                    play_sound(9);
                    stop_sound(6);
                    break;
            }
        }
        else
        {
            switch (counter)
            {
                case    1213:   //   04 BD
                    play_sound(10);
                    //play_sound(9);
                    play_sound(11);
                    break;
                case    1709:   //   06 AD
                    play_sound(12);
                    play_sound(9);
                    stop_sound(11);
                    break;
                case    2205:   //  08 9D
                    play_sound(8); //play_sound(13);
                    play_sound(13);
                    break;
            }
        }
    }
    else
    {
        if (counter<4685)
        {
            switch (counter)
            {
                case    2701:   //  0A 8D
                    play_sound(14);
                    play_sound(15);
                    play_sound(16);
                    break;
                case    3197:   //  0C 7D
                    play_sound(17);
                    play_sound(18);
                    play_sound(19);
                    break;
                case    3693:   //  0E 6D
                    play_sound(7);
                    play_sound(8); //play_sound(20);
                    play_sound(9);
                    play_sound(20);
                    break;
                case    4188:   //  10 5C
                    counter = 1708;
                    break;
                case    4189:   //  10 5D
                    mute_all();
                    play_sound(9);
                    play_sound(14);
                    play_sound(15);
                    break;
            }
        }
        else
        {
            switch (counter)
            {
                case    4685:   //  12 4D
                    play_sound(13);
                    break;
                case    5180:   //  14 3C
                    counter = 4188;
                    break;
                case    5181:   //  14 3D
                    mute_all();
                    play_sound(29);
                    break;
                case    5292:   //  14 AC
                    counter = 4188;
                    break;
                case    5293:   //  14 AD
                    mute_all();
                    play_sound(30);
                    play_sound(31);
                    break;
                case    6204:   //  18 3C
                    counter = 0;
                    break;
            }
        }
    }
}
*/

void nmi(void) {
    
    byte c;
    
    switch (state)
    {
        case    STATE_GAME:
            //counter_byte++;
            if (flag_prout == 2)
            {
                    getlevelvram();
                    //~ put_vram(0x1b00,sprites,12);
                    //~ put_vram(0x1804,&bar[((player_health&0x78))],8);
                    //~ put_vram(0x1817,&bar[((player_energy&0x78))],8);
                    //~ //if (counter_byte>0x1C) put_char(26,23,counter_byte);
                    //~ //counter_byte   =   0x1B;
                    //~ flag_prout   =   0;
            }
            break;
            
        case    STATE_OPTIONS:
            if (JUMP_MASK == UP)
            {
                put_vram(0x1b00,SprOption1,5);
                if (keypad_1==2 || joypad_1==DOWN)
                {
                    play_sound(21);
                    JUMP_MASK = FIRE2;
                }
            } else {
                put_vram(0x1b00,SprOption2,5);
                if (keypad_1==1 || joypad_1==UP)
                {
                    play_sound(21);
                    JUMP_MASK = UP;
                }
            }
            counter_byte = (counter_byte+1)&0x1f;
            put_vram_pattern (0x2180,&BlueColors[(counter_byte>>1)],8,0x2d);
            break;

        case    STATE_OPTIONS2:
            if  (keypad_1>0 && keypad_1<7)
            {
                level_number = keypad_1 - 1;
                play_sound(21);
            } else {
                if (joypad_1!=letters) {
                    letters = joypad_1;
                    if (joypad_1==UP) {
                        if (level_number>0) {
                            level_number--;
                            play_sound(21);
                        }
                    }
                    if (joypad_1==DOWN) {
                        if (level_number<5) {
                            level_number++;
                            play_sound(21);
                        }
                    }
                }
            }
            c = (level_number << 4) + 40;
            put_vram(0x1b00,&c,1);
            
            /*
            if (JUMP_MASK == UP)
            {
                put_vram(0x1b00,SprOption1,5);
                if (keypad_1==2 || joypad_1==DOWN)
                {
                    play_sound(21);
                    JUMP_MASK = FIRE2;
                }
            } else {
                put_vram(0x1b00,SprOption2,5);
                if (keypad_1==1 || joypad_1==UP)
                {
                    play_sound(21);
                    JUMP_MASK = UP;
                }
            }
        */
            counter_byte = (counter_byte+1)&0x1f;
            put_vram_pattern (0x2180,&BlueColors[(counter_byte>>1)],8,0x2d);
            break;
            
        case    STATE_TITLE:
            counter_byte = (counter_byte+1)&0x1f;
            put_vram_pattern (0x2180,&BlueColors[(counter_byte>>1)],8,0x2d);
            break;
        
        case    STATE_LEVELID:
            counter_byte = (counter_byte+1)&0x1f;
            put_vram_pattern (0x2180,&GreenColors[(counter_byte>>1)],8,0x2d);
            break;

        case    STATE_BONUS:
            counter_byte = (counter_byte+1)&0x1f;
            put_vram_pattern (0x2180,&YellowColors[(counter_byte>>1)],8,0x2d);
            break;
                    
        case    STATE_WIPEOUT:
            //counter_byte++;
            sprites[0] = 0xd0;
            put_vram(0x1b00,sprites,1);
            if (flag_prout == 2)
            {
                    // getlevelvram();
                    //if (counter_byte>0x1C) put_char(26,23,counter_byte);
                    //counter_byte   =   0x1B;
                    flag_prout   =   0;
            }
            break;
        case    STATE_FONT:
            rle2vram(FONTRLE,0x0180);
            rle2vram(FONTRLE,0x0980);
            state = STATE_FONT2;
            break;
        case    STATE_FONT2:
            rle2vram(FONTRLE,0x1180);
            fill_vram(0x2180,0x41,0x168);
            state = STATE_IDLE;
            break;
        case    STATE_BONUS_GET1:
            get_vram(0x2800,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET2:
            get_vram(0x2a00,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET3:
            get_vram(0x2c00,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET4:
            get_vram(0x2e00,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET5:
            get_vram(0x3000,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET6:
            get_vram(0x3200,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET7:
            get_vram(0x3400,buffer_scr,512);
            state = STATE_BONUS;
            break;
        case    STATE_BONUS_GET8:
            get_vram(0x3600,buffer_scr,512);
            state = STATE_BONUS;
            break;
    }
}

void game_loop(void)
{
    
    //byte    c;
    //char letters = 0;
    //char letterc = 0;
        
    //byte    ghost_e1;
    //byte    ghost_e2;
    
    char    car;

    /*    
    volatile char *spr_y1 = &sprites[4];
    volatile char *spr_x1 = &sprites[5];
    volatile char *spr_y2 = &sprites[8];
    volatile char *spr_x2 = &sprites[9];
    */
    
    byte *ptr_buffer_lvl = buffer_scr+673-160;

    flag_letters = 0xf8;
    
    dx = 1;
    pl_animframe = 0;
    anim_position = 0;
    
    player_health = 0x7F;
    player_energy = 0x7F;

    ghost_counter = 11-level_number;
    
    letters = 0;

    flag_end = 0;
    flag_saut = 0;
    
    saut = 0;

    cls();
    
    car = 19;
    put_vram(0x1802,&car,1);

    car = 20;
    put_vram(0x1815,&car,1);

    //counter = 716;

    display();

loop:

    wait_displayed();
    //~ while (flag_prout!=0) delay(0);

    if (flag_end) return;
    
    //~ deplacement_x = 0;
    //~ deplacement_y = 0;

    //~ /* If collectable, do something appropriate */
    //~ if (getcollectable) {
        //~ if (getcollectable&0x10) {
            //~ // ITEMS
            //~ play_sound(24);
            //~ if (getcollectable==0xb0) {
                //~ // HEALTH
                //~ player_health += 64;
                //~ if (player_health > 0x7f) {
                    //~ player_health = 0x7f;
                //~ }
            //~ } else if (getcollectable==0xb4) {
                //~ // ENERGY
                //~ player_energy += 64;
                //~ if (player_energy > 0x7f) {
                    //~ player_energy = 0x7f;
                //~ }
            //~ }
        //~ } else {
            //~ // LETTERS
            //~ // CHECK : if (getcollectable==0xa0 && letterc==0) getcollectable = 0x9c;
            //~ // TODO : printletter();
            //~ letters++;
            //~ stop_sound(24);
            //~ if (letters<5) {
                //~ play_sound(22);
            //~ } else {
                //~ play_sound(23);
                //~ flag_letters = 0;
            //~ }
        //~ }
    //~ }

    /* Change level data to blocks */
    //blocks();

    
    asm_engine();

    /*
    length = 0;

    c = (buffer_scr[369]) & 0xfe;
    if (c==0x9c) {
        flag_end = 1;
    }
    */
    
    /* Add player in the center */
    //laserbeam();
    /*
    if (dx==1)
    {
        laserbeamright();
        if ((player_energy>0) && joypad_1&FIRE1) {
            byte *offset = &buffer_scr[370];
            laser_x0 = 144;
            laser_x1 = 143;
            while (length<14 && *offset<0xc0) {
                *offset = 0x10;
                offset++;
                length++;
                laser_x1 += 8;
            }
            buffer_scr[337] = 0x03;
            buffer_scr[369] = 0x05;
            player_energy--;
        } else {
            buffer_scr[337] = 0x02;
            buffer_scr[369] = 0x04;
        }
    }
    else
    {
        laserbeamleft();
        buffer_scr[338] = 0x08;
        buffer_scr[370] = 0x09;
        sprites[2] = 224 + pl_animframe;
        if ((player_energy>0) && joypad_1&FIRE1) {
            byte *offset = &buffer_scr[368];
            laser_x0 = 136;
            laser_x1 = 135;
            while (length<16 && *offset<0xc0) {
                *offset = 0x10;
                offset--;
                length++;
                laser_x0 -= 8;
            }
            buffer_scr[337] = 0x0b;
            buffer_scr[369] = 0x0d;
            player_energy--;
        } else {
            buffer_scr[337] = 0x0a;
            buffer_scr[369] = 0x0c;
        }
    }
            */

    /* Calculate Frame */
    //player_joystick();
    /*
    if (joypad_1&RIGHT) {
        if (buffer_scr[402]<0xc0)
        {
            if (camera.x!=225) {
                deplacement_x -= 8;
                camera.x++;
            }
        }
        dx = 1;
    }
    if (joypad_1&LEFT) {
        if (buffer_scr[400]<0xc0)
        {
            if (camera.x!=0) {
                deplacement_x += 8;
                camera.x--;
            }
        }
        dx = -1;
    }
    if (joypad_1&(LEFT|RIGHT)) {
        pl_animframe += 4;
        if (pl_animframe == 32) pl_animframe = 4;
    } else {
        pl_animframe = 0;
    }
    */
    //update_playerstate();
    
    /*
    switch (player_state)
    {
        case    PLAYER_DEFAULT:
            if (buffer_scr[433]<0xc0) {
                if (camera.y < 44) player_state = PLAYER_FALL;
            }
            if (joypad_1&JUMP_MASK) {
                if (flag_saut==0) {
                    player_state = PLAYER_JUMP;
                    flag_saut = 1;
                }
            } else {
                if (flag_saut) {
                    flag_saut = 0;
                }
            }
            break;
        case    PLAYER_FALL:
            // if (flag_saut) {
            //    if (joypad_1&JUMP_MASK == 0) {
            //        flag_saut = 0;
            //    }
            //}
            if (buffer_scr[433]>=0xc0) {
                player_state = PLAYER_DEFAULT;
                camera.y &= 0x7e;
            }
            break;
        case    PLAYER_JUMP:
            c = buffer_scr[305];
            if (c>=0xc0 && c<0xd0) {
                player_state = PLAYER_FALL;
            }
            break;
    }

    switch (player_state)
    {
        case    PLAYER_DEFAULT:
            c = (buffer_scr[433])&0xf0;
            if (c==0xe0) {
                deplacement_x -= 8;
                camera.x++;
            }
            if (c==0xf0) {
                deplacement_x += 8;
                camera.x--;
            }
            saut = 0;
            break;
        case    PLAYER_FALL:
            if (camera.y < 44) {
                deplacement_y -= 8;
                camera.y++;
            } else {
                player_state = PLAYER_DEFAULT;
            }
            break;
        case    PLAYER_JUMP:
            player_state = PLAYER_FALL;
            if (joypad_1&JUMP_MASK) {
                if (camera.y) {
                    if (saut<10) {
                        saut++;
                        deplacement_y += 8;
                        camera.y--;
                        player_state = PLAYER_JUMP;
                    }
                }
            } else {
                flag_saut = 0;
            }
            break;
    }
        */

    //ghostanim();
    /*
    if (sprites[4] != 0xd0)
    {    
        *spr_x1 += deplacement_x; 
        *spr_y1 += deplacement_y;
        
        *spr_x1 += GHOSTMOVEMENT[anim_position++];
        *spr_y1 += GHOSTMOVEMENT[anim_position++];
        
        if (*spr_x2 & 0x80) {
            if (*spr_x1 & 0x80) {
                if (*spr_x1 > -16) {
                    *spr_x1 = -16;   
                }
            }
            else {
                if (*spr_x1 < 8) *spr_x1 = -16;
            }
        } else {
            if (*spr_x1 & 0x80) {
                if (*spr_x1 > -16) *spr_x1 = 8;
            }
            else {
                if (*spr_x1 < 8) {
                    *spr_x1 = 8;   
                }
            }
        }  
        *spr_x2 = *spr_x1;

        if (*spr_y2 & 0x80) {
            if (*spr_y1 & 0x80) {
                if (*spr_y1 > -105) {
                    *spr_y1 = -105;   
                }
            }
            else {
                if (*spr_y1 < 15) *spr_y1 = -105;
            }
        } else {
            if (*spr_y1 & 0x80) {
                if (*spr_y1 > -105) *spr_y1 = 15;
            }
            else {
                if (*spr_y1 < 15) {
                    *spr_y1 = 15;   
                }
            }
        }  
        *spr_y2 = *spr_y1;
        
        if (*spr_x1 & 0x80) {
            sprites[6] |= 0x20;
            sprites[10] |= 0x20;
        } else {
            sprites[6] &= 0xdf;
            sprites[10] &= 0xdf;
        }
            
        sprites[6] = (sprites[6] & 0xf0) | ((char)anim_position & 0x0c);
        sprites[10] = (sprites[10] & 0xf0) | ((char)anim_position & 0x0c);
        
        if (anim_position == 512) {
            player_energy+=8;
            if (player_energy > 0x7f) {
                player_energy=0x7f;
            }
            anim_position = 0;
        }

        // IF HIT DETECTION BETWEEN LASER AND GHOST    
        if (length>0) { //joypad_1&FIRE1) {
            if (sprites[4]>=84 && sprites[4]<=108 && sprites[5]>=laser_x0 && sprites[5]<=laser_x1)
            {
                play_sound(26);
                if (ghost_e1>0) {
                    ghost_e1--;
                    if (ghost_e1==0) {
                        sprites[7] = 0;
                    }
                }
                if (ghost_e2>0) {
                    ghost_e2--;
                    if (ghost_e2==0) {
                        sprites[11] = 0;
                    }
                }
                if (sprites[7] == 0 && sprites[11] == 0) {
                    sprites[4] = 0xd0;
                    sprites[8] = 0xd0;
                    play_sound(28);
                }
            }
        }
        // IF HIT WITH PLAYER
        if (sprites[4]>=76 && sprites[4]<=116) {
            if  (dx == 1) {
                if (sprites[5]>=116 && sprites[5]<=148) {
                    if (player_health <= level_number) {
                        player_health = 0;
                    } else `{
                        player_health -= (level_number + 1);
                    }
                    play_sound(27);
                    if (player_health == 0) flag_end = 1;
                }
            } else {
                if (sprites[5]>=124 && sprites[5]<=156) {
                    if (player_health <= level_number) {
                        player_health = 0;
                    } else `{
                        player_health -= (level_number + 1);
                    }
                    play_sound(27);
                    if (player_health == 0) flag_end = 1;
                }
            }
        }
        
    } else {

        addghost();
        
        //~ if (ghost_counter > 0) {
            //~ sprites[4] = 15; // 15 - 151
            //~ sprites[5] = 124; // 8 - 240
            //~ sprites[6] = 0;
            //~ sprites[7] = GHOSTCOLOR1;
            //~ sprites[8] = 15; // 15 - 151
            //~ sprites[9] = 124; // 8 - 240
            //~ sprites[10] = 16;
            //~ sprites[11] = GHOSTCOLOR2;
            
            //~ ghost_e1 = GHOSTENERGY1;
            //~ ghost_e2 = GHOSTENERGY2;
            
            //~ anim_position = 0;
            //~ ghost_counter--;
            
            //~ play_sound(25);
        //~ }
    }
    */

    //~ if (keypad_1==10 || keypad_2==10)
    //~ {
        //~ play_sound(25);
        //~ while (keypad_1==10 || keypad_2==10) delay(0);
        //~ while (keypad_1!=10 && keypad_2!=10) delay(0);
        //~ play_sound(25);
        //~ while (keypad_1==10 || keypad_2==10) delay(0);
    //~ }

    /* Set the flag to draw this frame */
    //~ flag_prout = 1;
    
    goto loop;    
}

void playgame(void)
{    
    black_out();
    screen_off();
    state = STATE_GAME;
    rle2vram(MOON_COLORRLE,0x2108);
    rle2vram(MOON_PATTERNRLE,0x0108);
    //put_vram(0x2800,demo,0x1000);
    //put_vram(0x3000,demo,0x0800);
    sprites[0] = 95;
    sprites[1] = 132;
    sprites[2] = 240;
    sprites[3] = 5;
    sprites[4] = 0xd0;
    sprites[8] = 0xd0;
    
    dx = 1;
    rle2vram(LEVELDATA,0x2800);
    duplicate_pattern();
    flag_prout = 2;
    camera.y = 44; // 32 - 10 = 22; 22*2 = 44;
    camera.x = 1;
    //mute_all();
    //counter = 716;
    game_loop();
}

void levelid(void)
{
    black_out();
    state = STATE_LEVELID;
    //rle2vram(COLORRLE,0x2000);
    //rle2vram(PATTERNRLE,0x0000);
    setup_level();
    fill_vram(0x1b0d,0xd0,1);
    rle2vram(sprLegsRLE,0x3e00);
    rle2vram(sprExplosionRLE,0x3a00);
    rle2vram(GHOSTRLE,0x3800);
    cls(); // rle2vram(SCR_TITLE,0x1800);
    center_string(11,LEVELNAME);
    duplicate_pattern();
    counter = 96;
    display();
    delay(155);
    pause_delay(464);
}

/*
 REG 0 : - - - - - - MODE2 EXTERNVIDEO
 REG 1 : 4/16K DISPLAY NMI MODE1 MODE3 - SPR16x16 MAGNIFY
*/

void title(void)
{
    black_out();
    vdp_out0(0x02,0); /* SET GRAPHIC MODE 2 */
    vdp_out0(0x9f,3); /* COLOR AT 2000, ONLY 256 CHARS */
    vdp_out0(0x03,4); /* PATTERN AT 0000, ALL 768 CHARS */    
    state = STATE_TITLE;
    rle2vram(COLORRLE,0x2000);
    rle2vram(PATTERNRLE,0x0000);
    rle2vram(FONTRLE,0x0180);
    rle2vram(SCR_TITLE,0x1800);
    put_vram(0x1b00,SprOption1+4,1);
    //~ put_vram(0x1b04,SprOption1+4,1);
    //~ put_vram(0x1b08,SprOption1+4,1);
    put_vram(0x1b0c,SprOption1+4,1);
    duplicate_pattern();
    counter = 0;
    display();
    pause();
}

void storyline(void)
{
    black_out();
    rle2vram(PAGE1,0x1800);    
    display();
    pause();
    black_out();
    rle2vram(PAGE2,0x1800);    
    display();
    pause();
}

const byte SPR_HAND[] = {
  0x1D, 0x00, 0x0F, 0x38, 0x7F, 0xFF, 0xFF, 0xFC, 0xF9, 0xE4, 0xFB, 0xFB, 0x74, 0x77, 0x39,
  0x0E, 0x00, 0x00, 0xFF, 0x7F, 0x80, 0xC0, 0xE0, 0xE0, 0x10, 0xF0, 0x00, 0xE0, 0xC0, 0x00, 0x80,
  0x81, 0x00, 0xFF};
  
void options(void)
{
    black_out();
    state = STATE_OPTIONS;
    rle2vram(SCR_OPTIONS,0x1800);
    rle2vram(SPR_HAND,0x3800);
    counter = 4188;
    JUMP_MASK = UP;
    display();
    pause();
    delay(1);
    
    black_out();
    state = STATE_OPTIONS2;
    rle2vram(SCR_OPTIONS2,0x1800);
    fullgame_flag = 0;
    level_number = 0;
    display();
    pause();
    
    switch (level_number)
    {
        case    0:
            fullgame_flag = 0xff;
            break;
        case    1:
            level_number = 4;
            break;
        case    2:
            level_number = 5;
            break;
        case    3:
            level_number = 7;
            break;
        case    4:
            level_number = 8;
            break;
        case    5:
            level_number = 9;
            break;
    }
    
    put_vram(0x1b00,SprOption1+4,1);
}

void wipeout(void)
{
    state = STATE_WIPEOUT;
    blocks();
    counter = 4188;
    if (dx==1)
    {
        buffer_scr[336] = 0x00;
        if (player_health == 0) {
            buffer_scr[337] = 0x11;
        } else {
            buffer_scr[337] = 0x02;
        }
        buffer_scr[368] = 0x01;
        buffer_scr[369] = 0x04;
        buffer_scr[401] = 0x07;
    }
    else
    {
        buffer_scr[338] = 0x08;
        if (player_health == 0) {
            buffer_scr[337] = 0x12;
        } else {
            buffer_scr[337] = 0x0a;
        }
        buffer_scr[370] = 0x09;
        buffer_scr[369] = 0x0c;
        buffer_scr[401] = 0x0f;
    }
    wipeout_asm();
    state = STATE_FONT;
    while (state != STATE_IDLE) delay(0);
    state = STATE_BONUS;
}

void bonus(void)
{
    unsigned i;
    byte *offset;
    unsigned miss = 0;
    state = STATE_BONUS_GET1;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++;
        offset++;
    }
    state = STATE_BONUS_GET2;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET3;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET4;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET5;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET6;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET7;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    state = STATE_BONUS_GET8;
    while(state!=STATE_BONUS) delay(0);
    offset = buffer_scr;
    for (i=0;i<512;i++) {
        if (*offset == 0xb8 || *offset == 0xbc) miss++; 
        offset++;
    }
    delay(1);
    if (miss!=0) {
        center_string(8,"SORRY");        
        print_at (7,10,"YOU MISS 00000 GEMS");        
        for (i=1;i<=miss;i++) {
            play_sound(26);
            print_at (16,10,str(i));
            delay(3);
        }
        player_health = 0;
    } else {
        // WIN!
        play_sound(28);
        center_string(8,"CONGRATULATIONS");        
        center_string(10,"YOU DID COLLECT ALL GEMS");
        haunted_flag += ghost_counter;
    }
    center_string(16,"PRESS FIRE");
    pause();
}

void ending(void)
{
    state = STATE_ENDING;
    black_out();
    rle2vram(COLORRLE,0x2000);
    rle2vram(PATTERNRLE,0x0000);
    rle2vram(FONTRLE,0x0180);
    duplicate_pattern();
    if (haunted_flag) {
        counter = 5180;
        rle2vram(ENDING2,0x1800);
    } else {
        counter = 5292;
        rle2vram(ENDING1,0x1800);
        rle2vram(sprFairyRLE,0x3800);        
        put_vram(0x1b00,sprFairyATTR,49);
    }
    display();    
    pause();
}

void main(void)
{
restart:
    title();
    storyline();
    options();
    if (keypad_1==11) fullgame_flag = 0xff;
    haunted_flag = 0;
next_level:
    levelid();
    playgame();
    wipeout();
    if (player_health > 0) {
        bonus();
        if (player_health > 0) {
            level_number++;
        }
    }
    if (fullgame_flag) {   
        if (level_number<10) goto next_level;
        ending();
    }
    goto restart;
}