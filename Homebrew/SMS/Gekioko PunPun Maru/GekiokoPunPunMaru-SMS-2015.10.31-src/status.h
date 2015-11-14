/* ゲーム中のステータス表示 */
extern void status_init();
extern void status_update();

/* 得点 */
extern int8u score_ints[4 * 2];		/* 現在のステータス表示用BCD */
extern int8u score_ints_latest[4 * 2];	/* ステージクリア時のステータス表示用BCD */

extern void score_init();
extern void score_add(int8u score);
extern void score_add_time_bonus();
extern void score_store();
extern void score_undo();

/* 時間 */
extern int8u time_ints[3];	/* ステータス表示用BCD */
extern int8u time_left;		/* 残り時間 */

extern void time_init();
extern void time_update();
extern void time_decliment();


