/* キャラクター (Actor) */
#include "sms.h"
#include "vdp.h"
#include "psg.h"
#include "port.h"
#include "file.h"
#include "main.h"

#include "actor.h"
#include "map.h"
#include "status.h"
#include "game.h"

/* 移動量加算の為のテーブル, フレーム毎にテーブルの値を加算する */
/* 8*0 = 静止, 8*31 = 最大速度 */
/* row = frame, column = speed */
const int8u speed_table[8 * 32] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 1, 0, 0, 0, 
	1, 0, 1, 0, 1, 0, 0, 0, 
	1, 0, 1, 0, 1, 0, 1, 0, 
	1, 1, 1, 0, 1, 0, 1, 0, 
	1, 1, 1, 0, 1, 1, 1, 0, 
	1, 1, 1, 1, 1, 1, 1, 0, 

	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 2, 1, 1, 1, 
	2, 1, 2, 1, 2, 1, 1, 1, 
	2, 1, 2, 1, 2, 1, 2, 1, 
	2, 2, 2, 1, 2, 1, 2, 1, 
	2, 2, 2, 1, 2, 2, 2, 1, 
	2, 2, 2, 2, 2, 2, 2, 1, 

	3, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 3, 2, 2, 2, 
	3, 2, 3, 2, 3, 2, 2, 2, 
	3, 2, 3, 2, 3, 2, 3, 2, 
	3, 3, 3, 2, 3, 2, 3, 2, 
	3, 3, 3, 2, 3, 3, 3, 2, 
	3, 3, 3, 3, 3, 3, 3, 2, 
	3, 3, 3, 3, 3, 3, 3, 3, 

	4, 3, 3, 3, 3, 3, 3, 3, 
	4, 3, 3, 3, 4, 3, 3, 3, 
	4, 3, 4, 3, 4, 3, 3, 3, 
	4, 3, 4, 3, 4, 3, 4, 3, 
	4, 3, 4, 3, 4, 3, 4, 3, 
	4, 4, 4, 3, 4, 3, 4, 3, 
	4, 4, 4, 3, 4, 4, 4, 3, 
	4, 4, 4, 4, 4, 4, 4, 3
};

const int8u enemies_rotation_array[8 * 4 * 3] = {
	/* stage 1 */
	ACTOR_NINJA,
	ACTOR_NINJA_CAKE,
	ACTOR_BIRD,
	ACTOR_NINJA,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_BIRD,
	ACTOR_DARUMA,
	
	ACTOR_NINJA,
	ACTOR_TENGU,
	ACTOR_DARUMA,
	ACTOR_FLOG,
	ACTOR_NINJA_CAKE,
	ACTOR_DARUMA,
	ACTOR_BOAR,
	ACTOR_BIRD,

	ACTOR_NINJA,
	ACTOR_DARUMA,
	ACTOR_HIME,
	ACTOR_BOAR,
	ACTOR_DARUMA,
	ACTOR_NINJA_CAKE,
	ACTOR_BIRD,
	ACTOR_TENGU,

	/* stage 2 */
	ACTOR_NINJA,
	ACTOR_TENGU,
	ACTOR_DARUMA,
	ACTOR_NINJA,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_DARUMA,
	ACTOR_BOAR,
	
	ACTOR_NINJA,
	ACTOR_TENGU,
	ACTOR_DARUMA,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_DARUMA,
	ACTOR_FLOG,
	ACTOR_BOAR,

	ACTOR_NINJA,
	ACTOR_DARUMA,
	ACTOR_HIME,
	ACTOR_BOAR,
	ACTOR_TENGU,
	ACTOR_NINJA_CAKE,
	ACTOR_BIRD,
	ACTOR_TENGU,

	/* stage 3 */
	ACTOR_BOAR,
	ACTOR_TENGU,
	ACTOR_NINJA_CAKE,
	ACTOR_DARUMA,
	ACTOR_TENGU,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_NINJA,
	
	ACTOR_HIME,
	ACTOR_TENGU,
	ACTOR_DARUMA,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_GOAST,
	ACTOR_NINJA_CAKE,
	ACTOR_TENGU,

	ACTOR_GOAST,
	ACTOR_DARUMA,
	ACTOR_HIME,
	ACTOR_GOAST,
	ACTOR_DARUMA,
	ACTOR_NINJA_CAKE,
	ACTOR_GOAST,
	ACTOR_TENGU,

	/* stage 4 */
	ACTOR_BOAR,
	ACTOR_TENGU,
	ACTOR_NINJA_CAKE,
	ACTOR_DARUMA,
	ACTOR_TENGU,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_NINJA,
	
	ACTOR_HIME,
	ACTOR_TENGU,
	ACTOR_DARUMA,
	ACTOR_BOAR,
	ACTOR_NINJA_CAKE,
	ACTOR_GOAST,
	ACTOR_NINJA_CAKE,
	ACTOR_TENGU,

	ACTOR_GOAST,
	ACTOR_DARUMA,
	ACTOR_HIME,
	ACTOR_GOAST,
	ACTOR_DARUMA,
	ACTOR_NINJA_CAKE,
	ACTOR_GOAST,
	ACTOR_TENGU,
};

int8u enemies_count;	/* 同時に出現する敵の数 */
int8u enemies_left;		/* 現在の出現する敵の残り数 */
int8u enemies_alive;	/* 現在の出現中の敵の数 */
int8u enemies_rotation_count;	/* 出現パターンのカウンター */
int8u enemies_rotation_limit;	/* 出現パターンの上限 */
int8u enemies_count;	/* 同時に出現する敵の数 */
int8u smoke_wait;		/* 次の煙が出せるまでの残り時間 */

int8u current_player;		/* in game */
int8u players_count;		/* プレイヤーの数, タイトル画面で選択される */
int8u alive_players;		/* 生きてるプレイヤーの数 */
int8u players_continue[2];	/* 各プレイヤーのコンティニュー回数 */
int8u player_y;			/* 現在のプレイヤーのY座標、一定以下だとtime_leftが減る */

/* キャラの固有情報 */
int8u actors_type[ACTORS_COUNT];		/* キャラの種類 */
int8u actors_x[ACTORS_COUNT];			/* キャラのX座標 */
int8u actors_y[ACTORS_COUNT];			/* キャラのY座標 */
int8u actors_speed_x[ACTORS_COUNT];		/* キャラのX移動量 */
int8u actors_speed_y[ACTORS_COUNT];		/* キャラのY移動量 */
int8u actors_angle[ACTORS_COUNT];		/* キャラの方向 */
int8u actors_option[ACTORS_COUNT];		/* キャラ毎の追加情報 */
int8u actors_life[ACTORS_COUNT];		/* キャラの命, 0 = 死亡中, 死亡中は衝突判定が無い */
int8u actors_touch[ACTORS_COUNT];		/* キャラの接触フラグ, 1 = 誰かに触ってる */

/* --------------------------------------------------------------------------------- */
void actor_create_random(int8u no);		/* キャラをランダム生成する */
void actor_create_basic_data(int8u no);	/* 生成時の基本データをセットする */
int8u actors_get_null();				/* 生成に必要な空きエントリーを検索する */
void nasu_create_all();					/* 同時に最大数のナスを全部発生させる */

void player_create(int8u no);		/* プレイヤーを生成する, noは 0 = 1P, 1 = 2P で固定される */
void daruma_create(int8u no);		/* ダルマを生成する */
void tengu_create(int8u no);		/* 天狗を生成する */
void bird_create(int8u no);			/* 鳥を生成する */
void flog_create(int8u no);			/* 蛙を生成する */
void goast_create(int8u no);		/* お化けを生成する */
void unko_create(int8u no);			/* 糞を生成する, 座標は親を受け継ぐ */
void life_create(int8u no);			/* 命を生成する, 座標は親を受け継ぐ */
void bomb_create(int8u no);			/* 爆発を生成する, 座標は親を受け継ぐ */
void hime_create(int8u no);			/* 姫を生成する */
void ninja_create(int8u no);		/* 忍者を生成する */
void ninja_cake_create(int8u no);	/* ケーキ付き忍者を生成する */
void boar_create(int8u no);			/* 猪を生成する */
void smoke_create(int8u by);		/* 煙を生成する, by = 産みの親 */
void score_create(int8u no);		/* 得点を生成する, 座標は親を受け継ぐ */
void nasu_create(int8u no);			/* ナスを生成する */

void actors_update();				/* 全てのキャラを更新する */
void player_update(int8u no);		/* プレイヤーを更新する */
void player_update_run(int8u no);	/* 	走る時 */
void player_update_jump(int8u no);	/* 	跳ぶ時 */
void player_update_dead(int8u no);	/* 	死ぬ時 */
void daruma_update(int8u no);		/* ダルマを更新する */
void tengu_update(int8u no);		/* 天狗を更新する */
void bird_update(int8u no);			/* 鳥を更新する */
void flog_update(int8u no);			/* 蛙を更新する */
void goast_update(int8u no);		/* お化けを更新する */
void unko_update(int8u no);			/* 糞を更新する */
void life_update(int8u no);			/* 命を更新する */
void bomb_update(int8u no);			/* 爆発を更新する */
void hime_update(int8u no);			/* 姫を更新する */
void ninja_update(int8u no);		/* 忍者を更新する */
void ninja_cake_update(int8u no);	/* ケーキ付き忍者を更新する */
void boar_update(int8u no);			/* 猪を更新する */
void smoke_update(int8u no);		/* 煙を更新する */
void score_update(int8u no);		/* 得点を更新する */
void nasu_update(int8u no);			/* ナスを更新する */

void actors_clear();	/* 全て消す */
void actor_update_go_right_left(int8u no, int8u limit);	/* 方向に応じて左か右に移動する */
void actor_update_go_left(int8u no, int8u limit);		/* 左に進もうとする */
void actor_update_go_right(int8u no, int8u limit);		/* 右に進もうとする */
void actor_update_go_up(int8u no, int8u limit);			/* 上に進もうとする, 空中移動用 */
void actor_update_go_down(int8u no, int8u limit);		/* 下に進もうとする, 空中移動用 */
void actor_update_friction(int8u no);			/* 摩擦による減速, 地に足の着いたキャラ用 */
void actor_update_x_movement(int8u no);			/* X方向の移動量を適用する */
void actor_update_y_movement(int8u no);			/* Y方向の移動量を適用する */
void actor_update_gravity(int8u no);			/* 重力による加速, 地に足の着いたキャラと死んで落ちる時用 */
void actor_update_y_adjust(int8u no);			/* Y方向の画面食み出しを制限する */
void actor_update_x_adjust(int8u no);			/* X方向ry, actor_update_turn() を呼び出してる時は要らない */
void actor_update_turn(int8u no);				/* 左右の隅に着たら折り返そうとする */
void actor_update_random_position(int8u no);	/* Y方向の位置をランダムで変更する */
void actor_update_floor(int8u no);				/* 床にめり込んでいたら床の上に整置させる */
int8u actor_collision_vs_actor(int8u no);		/* 自分にぶつかってる相手を調べる */
int8u actor_check_life(int8u no);				/* 死亡判定, TRUE = dead, FALSE = alive */
void actor_add_enemy(int8u no);					/* スコア加算して次のキャラを生成する */
int8u add_speed(int8u xy, int8u speed);			/* 移動量を加算する, 0 = 左最大, 32 = 0, 63 = 右最大 */
void actor_set_sprite(int8u no, int8u height, int8u pattern, int8u animation);	/* スプライトをセットする */
	/* height = 8, 16, 24 */
	/* pattern = パターン番号 */
	/* animation = 1 = 2パターンアニメーションする, 0 = 静止 */
	/* 		1行目 (頭) はアニメーションしない。 */
	/* palette = パレット番号 */
	/* ※widthは常に16pixel */
	/* ※actors_arignによって左右フリップする */
	/* ※actors_life = 0の時は上下フリップする (死んでるので) */

/* --------------------------------------------------------------------------------- */
void actor_create_random(int8u no){
	int8u a;
	
	enemies_left--;
	enemies_alive++;

	a = enemies_rotation_array[enemies_rotation_count++];
	if(enemies_rotation_count == enemies_rotation_limit){
		enemies_rotation_count = enemies_rotation_limit - 8;
	}
	switch(a){
	case ACTOR_NINJA:
		ninja_create(no);
		break;
	case ACTOR_NINJA_CAKE:	
		ninja_cake_create(no);
		break;
	case ACTOR_BOAR:
		boar_create(no);
		break;
	case ACTOR_DARUMA:
		daruma_create(no);
		break;
	case ACTOR_TENGU:
		tengu_create(no);
		break;
	case ACTOR_HIME:
		hime_create(no);
		break;
	case ACTOR_BIRD:
		bird_create(no);
		break;
	case ACTOR_FLOG:
		flog_create(no);
		break;
	case ACTOR_GOAST:
		goast_create(no);
		break;
	}
}
void actor_create_basic_data(int8u no){
	int8u a;

	a = rnd() & 0x01;
	if(a == 0){
		actors_angle[no] = ANGLE_RIGHT;
		actors_x[no] = 4;
	}else{
		actors_angle[no] = ANGLE_LEFT;
		actors_x[no] = 252;
	}
	actors_speed_x[no] = 32;
	actors_speed_y[no] = 32;
	actors_life[no] = 1;
	actors_touch[no] = 0;
	actors_option[no] = 0;
	actor_update_random_position(no);	/* set y position */
}
int8u actors_get_null(){
	int8u count;
	int8u a;
	
	for(count = 0; count < ACTORS_COUNT; count++){
		a = actors_type[count];
		if(a == ACTOR_NULL) return count;
	}
	return 0xFF;
}
void nasu_create_all(){
	int8u count;
	
	for(count = 0; count < NASU_COUNT; count++){
		nasu_create(actors_get_null());
	}
}
void player_create(int8u no){
	actors_type[no] = ACTOR_PLAYER;
	actor_create_basic_data(no);
	actors_x[no] = (no << 6) + 96;
	actors_y[no] = 208 - 24;
}
void ninja_create(int8u no){
	actors_type[no] = ACTOR_NINJA;
	actor_create_basic_data(no);
}
void ninja_cake_create(int8u no){
	actors_type[no] = ACTOR_NINJA_CAKE;
	actor_create_basic_data(no);
}
void boar_create(int8u no){
	actors_type[no] = ACTOR_BOAR;
	actor_create_basic_data(no);
}
void daruma_create(int8u no){
	actors_type[no] = ACTOR_DARUMA;
	actor_create_basic_data(no);
}
void tengu_create(int8u no){
	actors_type[no] = ACTOR_TENGU;
	actor_create_basic_data(no);
}
void hime_create(int8u no){
	actors_type[no] = ACTOR_HIME;
	actor_create_basic_data(no);
	actors_life[no] = 2;
}
void goast_create(int8u no){
	actors_type[no] = ACTOR_GOAST;
	actor_create_basic_data(no);
}
void bird_create(int8u no){
	actors_type[no] = ACTOR_BIRD;
	actor_create_basic_data(no);
}
void flog_create(int8u no){
	actors_type[no] = ACTOR_FLOG;
	actor_create_basic_data(no);
}
void unko_create(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	actors_type[no] = ACTOR_UNKO;
	actor_create_basic_data(no);
	actors_x[no] = x;
	actors_y[no] = y;
	actors_speed_y[no] = 32 - 8;
}
void life_create(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	actors_type[no] = ACTOR_LIFE;
	actor_create_basic_data(no);
	actors_x[no] = x;
	actors_y[no] = y;
	actors_speed_y[no] = 32 - 32;
}
void bomb_create(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	actors_type[no] = ACTOR_BOMB;
	actor_create_basic_data(no);
	actors_x[no] = x;
	actors_y[no] = y;
	actors_option[no] = 3 << (0 + 2);
}
void score_create(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	actors_type[no] = ACTOR_SCORE;
	actor_create_basic_data(no);
	actors_angle[no] = ANGLE_RIGHT;
	actors_x[no] = x;
	actors_y[no] = y;
	actors_speed_y[no] = 32 - 24;
}
void nasu_create(int8u no){
	actors_type[no] = ACTOR_NASU;
	actor_create_basic_data(no);
	actors_x[no] = ((no & 0x03) << 5) + 64;
	actors_y[no] = 1;
}
void smoke_create(int8u by){
	int8u no;
	
	if(smoke_wait != 0) return;
	smoke_wait = SMOKE_WAIT_LENGTH;

	no = actors_get_null();

	if(no >= ACTORS_COUNT) return;

	actors_type[no] = ACTOR_SMOKE;
	actor_create_basic_data(no);
	actors_x[no] = actors_x[by] + 4;
	actors_y[no] = actors_y[by] - 24;
	actors_speed_y[no] = 32 - 24;
	psg_set_se(psg_punch);
}

/* --------------------------------------------------------------------------------- */
void actors_update(){
	int8u a;
	int8u count;

	for(count = 0; count < ACTORS_COUNT; count++){
		a = actors_type[count];
		switch(a){
		case ACTOR_PLAYER:
			player_update(count);
			break;
		case ACTOR_NINJA:	/* normal ninja */
			ninja_update(count);
			break;
		case ACTOR_NINJA_CAKE:	/* ninja with cake, i am happy! run away! */
			ninja_cake_update(count);
			break;
		case ACTOR_BOAR:
			boar_update(count);
			break;
		case ACTOR_DARUMA:
			daruma_update(count);
			break;
		case ACTOR_TENGU:
			tengu_update(count);
			break;
		case ACTOR_HIME:
			hime_update(count);
			break;
		case ACTOR_GOAST:
			goast_update(count);
			break;
		case ACTOR_BIRD:
			bird_update(count);
			break;
		case ACTOR_FLOG:
			flog_update(count);
			break;
		case ACTOR_UNKO:
			unko_update(count);
			break;
		case ACTOR_LIFE:
			life_update(count);
			break;
		case ACTOR_SMOKE:
			smoke_update(count);
			break;
		case ACTOR_SCORE:
			score_update(count);
			break;
		case ACTOR_BOMB:
			bomb_update(count);
			break;
		case ACTOR_NASU:
			nasu_update(count);
			break;
		}
	}
}
void player_update(int8u no){
	int8u a;

	/* non stop at stage 3 */
	if(stage != 3){
		actor_update_friction(no);
	}
	actor_update_gravity(no);
	actor_update_floor(no);
	a = actors_touch[no];
	if(a == TRUE){
		actors_option[no] = ACTOR_STAND;
	}
	a = actors_speed_y[no];
	if(a > 33){
		actors_option[no] = ACTOR_JUMP;
	}
	actor_update_x_adjust(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);

	/* 衝突 */
	if(actors_life[no] > 0){
		a = actor_collision_vs_actor(no);
		if(a < ACTORS_COUNT){
			switch(actors_type[a]){
			case ACTOR_SMOKE:
				break;
			case ACTOR_LIFE:
				actors_life[a] = 0;
				players_continue[current_player]++;
				psg_set_se(psg_eat);
				break;
			case ACTOR_SCORE:
				break;
			case ACTOR_PLAYER:
				break;
			case ACTOR_NASU:
				actors_type[a] = ACTOR_NULL;
				score_add(1);
				psg_set_se(psg_eat);
				break;
			default:
				actors_life[no] = 0;
				actors_speed_x[no] = 32 - 0;
				actors_speed_y[no] = 32 - 8;
				psg_set_se(psg_damage);
			}
		}
		if((time_left == 0) && (enemies_alive != 0)){
			actors_life[no] = 0;
			actors_speed_x[no] = 32 - 0;
			actors_speed_y[no] = 32 - 24;
			psg_set_se(psg_damage);
		}
	}
	/* 死 */
	a = actor_check_life(no);	/* return TRUE = dead, FALSE = alive */
	if(a == TRUE){
		actors_type[no] = ACTOR_NULL;
		players_continue[current_player]--;
		alive_players--;
	}

	/* スプライト */
	a = actors_option[no];
	switch(a){
	case ACTOR_STAND:
		a = actors_speed_x[no];
		if(a == 32){
			actor_set_sprite(no, 24, VRAM_PLAYER_STAND, 1);
		}else{
			actor_set_sprite(no, 24, VRAM_PLAYER_WALK, 1);
		}
		break;
	case ACTOR_JUMP:
		actor_set_sprite(no, 24, VRAM_PLAYER_WALK, 0);
		break;
	}

	/* 死んでたら以降のアクションをしない */
	if(actors_life[no] == 0) return;
	
	/* ジャンプ */
	a = actors_option[no];
	if(a == ACTOR_STAND){
		if(ports[current_player].button & BUTTON_B){
			actors_speed_y[no] = 0;
			actors_option[no] = ACTOR_JUMP;
			psg_set_se(psg_jump);
		}
	}

	/* ぷんぷん */
	if(ports[current_player].button & BUTTON_A){
		smoke_create(no);
	}

	/* 左右移動 */
	if(ports[current_player].button & BUTTON_LEFT){
		actors_angle[no] = ANGLE_LEFT;
		actor_update_go_left(no, 32 - 16);
	}
	if(ports[current_player].button & BUTTON_RIGHT){
		actors_angle[no] = ANGLE_RIGHT;
		actor_update_go_right(no, 32 + 16);
	}
	
	player_y = actors_y[no];
}
void ninja_update(int8u no){
	actor_update_go_right_left(no, 8);
	actor_update_friction(no);
	actor_update_turn(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_NINJA, 1);
}
void ninja_cake_update(int8u no){
	/* jump */
	if(((frame_count & 0x3F) == 3) && (actors_speed_y[no] == 32) && (actors_life[no] > 0)){
		actors_speed_y[no] = 0;
	}

	actor_update_go_right_left(no, 10);
	actor_update_friction(no);
	actor_update_turn(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_NINJA_CAKE, 1);
}
void boar_update(int8u no){
	actor_update_go_right_left(no, 16);
	actor_update_friction(no);
	actor_update_turn(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_BOAR, 1);
}
void daruma_update(int8u no){
	/* jump */
	if(((frame_count & 0x1F) == 3) && (actors_speed_y[no] == 32) && (actors_life[no] > 0)){
		actors_speed_y[no] = 32 - 16;
	}

	actor_update_go_right_left(no, 6);
	actor_update_friction(no);
	actor_update_turn(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_DARUMA, 0);
}
void flog_update(int8u no){
	int8u a;

	/* jump */
	if(((frame_count & 0x3F) == 0) && (actors_speed_y[no] == 32) && (actors_life[no] > 0)){
		actors_speed_y[no] = 32 - 32;
		a = actors_x[no];
		if(a > 128){
			actors_angle[no] = ANGLE_LEFT;
			actors_speed_x[no] = 32 - 32;
		}else{
			actors_angle[no] = ANGLE_RIGHT;
			actors_speed_x[no] = 32 + 31;
		}
	}
	actor_update_friction(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_x_adjust(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	a = actors_speed_y[no];
	if(a >= 32){
		actor_set_sprite(no, 16, VRAM_FLOG, 0);
	}else{
		actor_set_sprite(no, 16, VRAM_FLOG + 4, 0);
	}
}
void tengu_update(int8u no){
	int8u a;

	/* 上下運動 */
	a = actors_option[no];
	actors_option[no] = ++a;
	if(a & 0x40){
		actor_update_go_up(no, 32 - 16);
	}else{
		actor_update_go_down(no, 32 + 16);
	}

	actor_update_go_right_left(no, 11);
	actor_update_turn(no);
	if(actors_life[no] == 0) actor_update_gravity(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 24, VRAM_TENGU, 1);
}
void goast_update(int8u no){
	int8u a;
	int8u b;

	if((frame_count & 0x3F) == 23){
		a = actors_x[0];
		b = actors_x[no];
		if(b < a){
			actors_speed_x[no] = 32 + 24;
			actors_angle[no] = ANGLE_RIGHT;
		}else{
			actors_speed_x[no] = 32 - 24;
			actors_angle[no] = ANGLE_LEFT;
		}
		a = actors_y[0];
		b = actors_y[no];
		if(b < a){
			actors_speed_y[no] = 32 + 8;
		}else{
			actors_speed_y[no] = 32 - 8;
		}
	}

	actor_update_friction(no);
	if(actors_life[no] == 0) actor_update_gravity(no);
	actor_update_x_adjust(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_GOAST, 1);
}
void hime_update(int8u no){
	int8u a;
	int8u x;

	/* 1回やられると加速する */
	a = actors_life[no];
	if(a == 1){
		x = 15;
	}else{
		x = 7;
	}

	actor_update_go_right_left(no, x);
	actor_update_friction(no);
	actor_update_turn(no);
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 24, VRAM_HIME, 1);
}
void bird_update(int8u no){
	int8u a;

	/* 上下運動 */
	a = actors_option[no];
	actors_option[no] = ++a;
	if(a & 0x10){
		actor_update_go_up(no, 32 - 8);
	}else{
		actor_update_go_down(no, 32 + 10);
	}

	actor_update_go_right_left(no, 8);
	actor_update_turn(no);
	if(actors_life[no] == 0) actor_update_gravity(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_BIRD, 1);
}
void unko_update(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	if(y >= 192){
		actors_type[no] = ACTOR_NULL;
		actor_add_enemy(no);
		return;
	}

	actor_update_gravity(no);
	actor_update_y_adjust(no);
	actor_update_y_movement(no);

	sprite_set(x - 4, y, VRAM_UNKO);
}
void life_update(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];
	if((y >= 192) || (actors_life[no] == 0)){
		actors_type[no] = ACTOR_NULL;
		actor_add_enemy(no);
		return;
	}

	actor_update_gravity(no);
	actor_update_y_adjust(no);
	actor_update_y_movement(no);

	sprite_set(x - 4, y, VRAM_LIFE);
}
void bomb_update(int8u no){
	int8u a;

	if(actors_option[no]-- == 0){
		score_add(1);
		score_create(no);
		return;
	}

	a = (actors_option[no] >> 1) & 0x0C;
	a += VRAM_BOMB;
	actor_set_sprite(no, 16, a, 0);
}
void score_update(int8u no){
	int8u a;

	actor_update_gravity(no);
	actor_update_y_adjust(no);
	actor_update_y_movement(no);

	a = actors_speed_y[no];
	if(a > 31){
		actors_type[no] = ACTOR_NULL;
		actor_add_enemy(no);
		return;
	}

	actor_set_sprite(no, 8, VRAM_POINT, 0);
}
void nasu_update(int8u no){
	actor_update_gravity(no);
	actor_update_floor(no);
	actor_update_y_adjust(no);
	actor_update_x_movement(no);
	actor_update_y_movement(no);
	actor_set_sprite(no, 16, VRAM_NASU, 1);
}
void smoke_update(int8u no){
	int8u a;

	actor_update_gravity(no);
	actor_update_y_movement(no);
	if(actors_y[no] > 192){
		actors_type[no] = ACTOR_NULL;
	}

	a = actors_speed_y[no];
	if(a > 30){
		actors_type[no] = ACTOR_NULL;
	}
	
	/* clear away when get collision */
	a = actor_collision_vs_actor(no);
	if(a < ACTORS_COUNT){
		switch(actors_type[a]){
		case ACTOR_PLAYER:
			break;
		case ACTOR_LIFE:
			break;
		case ACTOR_UNKO:
			break;
		case ACTOR_SCORE:
			break;
		case ACTOR_SMOKE:
			break;
		case ACTOR_BOMB:
			break;
		case ACTOR_NASU:
			break;
		case ACTOR_HIME:
			life_create(a);
			score_add(1);
			psg_set_se(psg_damage);
			return;
		case ACTOR_BIRD:
			unko_create(a);
			score_add(1);
			psg_set_se(psg_damage);
			return;
		default:
			actors_type[no] = ACTOR_NULL;
			bomb_create(a);
			psg_set_se(psg_damage);
			return;
		}
	}

	actor_set_sprite(no, 16, VRAM_SMOKE, 0);
}

/* --------------------------------------------------------------------------------- */
void actor_set_sprite(int8u no, int8u height, int8u pattern, int8u animation){
	int8u x;
	int8u y;
	int8u c;

	/* hrizonal flip */	
	if(actors_angle[no] == ANGLE_LEFT){
		pattern += SPR_HFLIP;
	}

	/* animation */	
	if(animation == 1){
		if((frame_count & 0x08) == 0){
			pattern += height >> 2;
		}
	}

	/* x */	
	x = actors_x[no];
	x -= 8;

	/* y */	
	y = actors_y[no];
	switch(height){
	case 8:
		y -= 4;
		break;
	case 16:
		y -= 16;
		break;
	case 24:
		y -= 24;
		break;
	}

	/* vertical flip */	
	/*
	if(actors_life[no] == 0){
		y += height - 8;
		yadd = 0 - 8;
		pattern += SPR_VFLIP;
	}
	*/

	/* column 0 */
	for(c = height; c > 0; c -= 8){
		sprite_set(x, y, pattern);
		y += 8;
		pattern++;
	}
	x += 8;
	y -= height;

	/* column 1 */
	for(c = height; c > 0; c -= 8){
		sprite_set(x, y, pattern);
		y += 8;
		pattern++;
	}
}
void actors_clear(){
	int8u count;
	
	for(count = 0; count < ACTORS_COUNT; count++){
		actors_type[count] = ACTOR_NULL;
	}
}
void actor_update_go_right_left(int8u no, int8u limit){
	int8u a;

	a = actors_angle[no];
	if(a == ANGLE_LEFT){
		a = 32 - limit;
		actor_update_go_left(no, a);
	}else{
		a = 32 + limit;
		actor_update_go_right(no, a);
	}
}
void actor_update_go_left(int8u no, int8u limit){
	int8u s;

	s = actors_speed_x[no];
	if(s > limit) s--;
	actors_speed_x[no] = s;
}
void actor_update_go_right(int8u no, int8u limit){
	int8u s;

	s = actors_speed_x[no];
	if(s < limit) s++;
	actors_speed_x[no] = s;
}
void actor_update_go_up(int8u no, int8u limit){
	int8u s;

	s = actors_speed_y[no];
	if(s > limit) s--;
	actors_speed_y[no] = s;
}
void actor_update_go_down(int8u no, int8u limit){
	int8u s;

	s = actors_speed_y[no];
	if(s < limit) s++;
	actors_speed_y[no] = s;
}
void actor_update_friction(int8u no){
	int8u a;
	int8u s;

	a = frame_count & 0x01;
	if(a == 0) return;

	s = actors_speed_x[no];
	if(s < 32) s++;
	if(s > 32) s--;
	actors_speed_x[no] = s;
}
int8u add_speed(int8u xy, int8u speed){
	int8u a;

	if(speed < 32){
		a = (32 - speed) << 3;
		a += frame_count & 0x07;
		xy -= speed_table[a];
		return xy;
	}else{
		a = (speed - 32) << 3;
		a += frame_count & 0x07;
		xy += speed_table[a];
		return xy;
	}
}
void actor_update_x_movement(int8u no){
	int8u s;
	int8u x;

	/* check speed limit */
	s = actors_speed_x[no];
	if(s >127) s = 0;	/* limit over - minus */
	if(s > 63) s = 63;	/* limit over - plus  */
	actors_speed_x[no] = s;

	/* add speed value to x position */
	x = actors_x[no];
	x = add_speed(x, s);
	actors_x[no] = x;
}
void actor_update_y_movement(int8u no){
	int8u s;
	int8u y;

	/* check speed limit */
	s = actors_speed_y[no];
	if(s >127) s = 0;	/* limit over - minus */
	if(s > 63) s = 63;	/* limit over - plus  */
	actors_speed_y[no] = s;

	/* add speed value to x position */
	y = actors_y[no];
	y = add_speed(y, s);
	actors_y[no] = y;
}
void actor_update_gravity(int8u no){
	int8u s;

	s = actors_speed_y[no];
	if(s < 63) s++;
	actors_speed_y[no] = s;
}
void actor_update_y_adjust(int8u no){
	int8u y;

	y = actors_y[no];
	if(y < 4) y = 4;	/* actor's head over the top line */
	if(y > 200) y = 200;	/* actor's leg over the end line */
	actors_y[no] = y;
}
/* actor_update_turn() を呼び出してる時は要らない */
void actor_update_x_adjust(int8u no){
	int8u x;

	x = actors_x[no];
	if(x < 4) x = 4;	/* actor's leg over the left side */
	if(x > 252) x = 252;	/* actor's head over the right side */
	actors_x[no] = x;
}
/* turn left (left side) or turn right (right side) */
void actor_update_turn(int8u no){
	int8u x;
	int8u y;

	x = actors_x[no];
	y = actors_y[no];

	if(x < 4){
		actors_x[no] = 4;
		actors_speed_x[no] = 32;
		actors_angle[no] = ANGLE_RIGHT;
		if(y > 176){
			actor_update_random_position(no);
		}
		return;
	}	
	if(x > 252){
		actors_x[no] = 252;
		actors_speed_x[no] = 32;
		actors_angle[no] = ANGLE_LEFT;
		if(y > 176){
			actor_update_random_position(no);
		}
		return;
	}
}
void actor_update_random_position(int8u no){
	int8u y;
	
	y = actors_y[no];
	y = rnd() & 0x30;
	y += 16;
	actors_y[no] = y;
}
void actor_update_floor(int8u no){
	int8u x;
	int8u y;
	int8u s;
	int8u block;

	x = actors_x[no];
	y = actors_y[no];
	s = actors_speed_y[no];

	/* clear touch flag */
	actors_touch[no] = 0;

	/* check movement, the collision occured when only move to plus (fall down) */
	if(s <= 32) return;

	/* ignore when dead */
	s = actors_life[no];
	if(s == 0) return;

	/* check y position */
	y = actors_y[no] & 0x0F;
	if(y > 4) return;

	/* load block map */
	y = actors_y[no] >> 4;
	y += block_array_offset;
	block = block_array[y];

	/* check x position vs blocks */
	x = actors_x[no];
	x >>= 5;	/* 32 / 8 = 1 */
	block >>= x;
	block &= 0x01;
	if(block == 0) return;	/* not in blocks */

	/* get colision */
	y = actors_y[no];
	actors_y[no] = y & 0xF0;
	actors_speed_y[no] = 32;
	actors_touch[no] = 1;
	return;
}
int8u actor_collision_vs_actor(int8u no){
	int8u my_x;
	int8u my_y;
	int8u my_xw;
	int8u my_yw;
	int8u your_pos;
	int8u count;

	my_x = actors_x[no];
	my_y = actors_y[no];
	my_xw = my_x + 16;
	my_yw = my_y + 16;

	for(count = 1; count < ACTORS_COUNT; count++){
		if(count != no){
			if(actors_type[count] != ACTOR_NULL){
				your_pos = actors_y[count];
				if(my_yw > your_pos){
					your_pos += 16;
					if(my_y < your_pos){
						your_pos = actors_x[count];
						if(my_xw > your_pos){
							your_pos += 16;
							if(my_x < your_pos){
								if(actors_life[count] > 0){
									return count;
								}
							}
						}
					}
				}
			}
		}
	}
	return 0xFF;
}
int8u actor_check_life(int8u no){
	if(actors_life[no] == 0){
		if(actors_y[no] > 192){
			/* actors_type[no] = ACTOR_NULL; */
			return TRUE;	/* dead */
		}
	}
	return FALSE;	/* now fall down */
}
void actor_add_enemy(int8u no){
	enemies_alive--;
	if(enemies_alive == 0){
		scene_type = SCENE_DEAD_ALL_ENEMIES;
		return;
	}
	if(enemies_left > 0){
		actor_create_random(no);
		return;
	}
}
/* --------------------------------------------------------------------------------- */

