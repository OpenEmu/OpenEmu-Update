/* キャラクター (Actor) */

extern const int8u speed_table[8 * 32];
extern const int8u enemies_rotation_array[8 * 4 * 3] ;

extern int8u enemies_count;		/* 同時に出現する敵の数 */
extern int8u enemies_left;		/* 現在の出現する敵の残り数 */
extern int8u enemies_alive;		/* 現在の出現中の敵の数 */
extern int8u enemies_rotation_count;	/* 出現パターンのカウンター */
extern int8u enemies_rotation_limit;	/* 出現パターンの上限 */
extern int8u enemies_count;		/* 同時に出現する敵の数 */
extern int8u smoke_wait;		/* 次の煙が出せるまでの残り時間 */
	#define SMOKE_WAIT_LENGTH	30

#define PLATER_DEFAULT_LIVES	3
extern int8u current_player;		/* in game */
extern int8u players_count;		/* プレイヤーの数, タイトル画面で選択される */
extern int8u alive_players;		/* 生きてるプレイヤーの数 */
extern int8u players_continue[2];	/* 各プレイヤーのコンティニュー回数 */
extern int8u player_y;			/* 現在のプレイヤーのY座標、一定以下だとtime_leftが減る */
	#define TIME_LEFT_BORDER	152

extern void actor_create_random(int8u no);	/* キャラをランダム生成する */
extern void actor_create_basic_data(int8u no);	/* 生成時の基本データをセットする */
extern int8u actors_get_null();			/* 生成に必要な空きエントリーを検索する */
extern void nasu_create_all();			/* 同時に最大数のナスを全部発生させる */
	#define NASU_COUNT	3	/* 発生させるナスの数 */

/* --------------------------------------------------------------------------------- */
/* キャラ */
		#define ACTORS_COUNT	6		/* キャラ (Actors) の最大数 */
		#define ACTORS_INITINAL_COUNT	3	/* キャラ (Actors) の初期数 */
extern int8u actors_type[ACTORS_COUNT];				/* キャラの種類 */
		#define ACTOR_NULL	0
		#define ACTOR_SMOKE	1
		#define ACTOR_PLAYER	2
		#define ACTOR_NINJA	3
		#define ACTOR_NINJA_CAKE	4
		#define ACTOR_BOAR	5
		#define ACTOR_DARUMA	6
		#define ACTOR_TENGU	7
		#define ACTOR_HIME	8
		#define ACTOR_BIRD	9
		#define ACTOR_FLOG	10
		#define ACTOR_GOAST	11
		#define ACTOR_NASU	12
		#define ACTOR_SCORE	13
		#define ACTOR_UNKO	14
		#define ACTOR_LIFE	15
		#define ACTOR_BOMB	16
extern int8u actors_x[ACTORS_COUNT];		/* キャラのX座標 */
extern int8u actors_y[ACTORS_COUNT];		/* キャラのY座標 */
extern int8u actors_speed_x[ACTORS_COUNT];	/* キャラのX移動量 */
extern int8u actors_speed_y[ACTORS_COUNT];	/* キャラのY移動量 */
extern int8u actors_angle[ACTORS_COUNT];	/* キャラの方向 */
		#define ANGLE_LEFT	0
		#define ANGLE_RIGHT	1
extern int8u actors_option[ACTORS_COUNT];	/* キャラ毎の追加情報 */
		#define ACTOR_STAND	0
		#define ACTOR_JUMP	1
extern int8u actors_life[ACTORS_COUNT];		/* キャラの命, 0 = 死亡中 */
						/* 死亡中は衝突判定が無い */
extern int8u actors_touch[ACTORS_COUNT];	/* キャラの接触フラグ, 1 = 誰かに触ってる */

extern void player_create(int8u no);		/* プレイヤーを生成する, noは 0 = 1P, 1 = 2P で固定される */
extern void daruma_create(int8u no);		/* ダルマを生成する */
extern void tengu_create(int8u no);		/* 天狗を生成する */
extern void bird_create(int8u no);		/* 鳥を生成する */
extern void flog_create(int8u no);		/* 蛙を生成する */
extern void goast_create(int8u no);		/* お化けを生成する */
extern void unko_create(int8u no);		/* 糞を生成する, 座標は親を受け継ぐ */
extern void life_create(int8u no);		/* 命を生成する, 座標は親を受け継ぐ */
extern void bomb_create(int8u no);		/* 爆発を生成する, 座標は親を受け継ぐ */
extern void hime_create(int8u no);		/* 姫を生成する */
extern void ninja_create(int8u no);		/* 忍者を生成する */
extern void ninja_cake_create(int8u no);	/* ケーキ付き忍者を生成する */
extern void boar_create(int8u no);		/* 猪を生成する */
extern void smoke_create(int8u by);		/* 煙を生成する, by = 産みの親 */
extern void score_create(int8u no);		/* 得点を生成する, 座標は親を受け継ぐ */
extern void nasu_create(int8u no);		/* ナスを生成する */

extern void actors_update();			/* 全てのキャラを更新する */
extern void player_update(int8u no);		/* プレイヤーを更新する */
extern void player_update_run(int8u no);	/* 	走る時 */
extern void player_update_jump(int8u no);	/* 	跳ぶ時 */
extern void player_update_dead(int8u no);	/* 	死ぬ時 */
extern void daruma_update(int8u no);		/* ダルマを更新する */
extern void tengu_update(int8u no);		/* 天狗を更新する */
extern void bird_update(int8u no);		/* 鳥を更新する */
extern void flog_update(int8u no);		/* 蛙を更新する */
extern void goast_update(int8u no);		/* お化けを更新する */
extern void unko_update(int8u no);		/* 糞を更新する */
extern void life_update(int8u no);		/* 命を更新する */
extern void bomb_update(int8u no);		/* 爆発を更新する */
extern void hime_update(int8u no);		/* 姫を更新する */
extern void ninja_update(int8u no);		/* 忍者を更新する */
extern void ninja_cake_update(int8u no);	/* ケーキ付き忍者を更新する */
extern void boar_update(int8u no);		/* 猪を更新する */
extern void smoke_update(int8u no);		/* 煙を更新する */
extern void score_update(int8u no);		/* 得点を更新する */
extern void nasu_update(int8u no);		/* ナスを更新する */

extern void actors_clear();	/* 全て消す */
extern void actor_update_go_right_left(int8u no, int8u limit);	/* 方向に応じて左か右に移動する */
extern void actor_update_go_left(int8u no, int8u limit);	/* 左に進もうとする */
extern void actor_update_go_right(int8u no, int8u limit);	/* 右に進もうとする */
extern void actor_update_go_up(int8u no, int8u limit);		/* 上に進もうとする, 空中移動用 */
extern void actor_update_go_down(int8u no, int8u limit);	/* 下に進もうとする, 空中移動用 */
extern void actor_update_friction(int8u no);		/* 摩擦による減速, 地に足の着いたキャラ用 */
extern void actor_update_x_movement(int8u no);		/* X方向の移動量を適用する */
extern void actor_update_y_movement(int8u no);		/* Y方向の移動量を適用する */
extern void actor_update_gravity(int8u no);		/* 重力による加速, 地に足の着いたキャラと死んで落ちる時用 */
extern void actor_update_y_adjust(int8u no);		/* Y方向の画面食み出しを制限する */
extern void actor_update_x_adjust(int8u no);		/* X方向ry, actor_update_turn() を呼び出してる時は要らない */
extern void actor_update_turn(int8u no);		/* 左右の隅に着たら折り返そうとする */
extern void actor_update_random_position(int8u no);	/* Y方向の位置をランダムで変更する */
extern void actor_update_floor(int8u no);		/* 床にめり込んでいたら床の上に整置させる */
extern int8u actor_collision_vs_actor(int8u no);	/* 自分にぶつかってる相手を調べる */
extern int8u actor_check_life(int8u no);		/* 死亡判定, TRUE = dead, FALSE = alive */
extern void actor_add_enemy(int8u no);			/* スコア加算して次のキャラを生成する */
extern int8u add_speed(int8u xy, int8u speed);		/* 移動量を加算する, 0 = 左最大, 32 = 0, 63 = 右最大 */
extern void actor_set_sprite(int8u no, int8u height, int8u pattern, int8u animation);	/* スプライトをセットする */
	/* height = 8, 16, 24 */
	/* pattern = パターン番号 */
	/* animation = 1 = 2パターンアニメーションする, 0 = 静止 */
	/* 		1行目 (頭) はアニメーションしない。 */
	/* palette = パレット番号 */
	/* ※widthは常に16pixel */
	/* ※actors_arignによって左右フリップする */
	/* ※actors_life = 0の時は上下フリップする (死んでるので) */

