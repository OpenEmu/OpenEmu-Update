/* ----------------------------------------------------------------------------------- */
sfr at 0x7F PSG_PORT;

void psg_init();
void psg_play();
void psg_stop();
void psg_set_se(int8u *stream);
void psg_play_se();
void psg_set_bgm(int8u *stream, int8u loop);
void psg_play_bgm();

extern const int8u psg_damage[];
extern const int8u psg_fix[];
extern const int8u psg_eat[];
extern const int8u psg_scramble[];
extern const int8u psg_punch[];
extern const int8u psg_jump[];
extern const int8u psg_score[];

/* ----------------------------------------------------------------------------------- */

