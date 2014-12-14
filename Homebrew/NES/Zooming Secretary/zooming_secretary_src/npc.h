void npc_add(unsigned int type)
{
	//if(npc_all==NPC_MAX) return;

	npc_type/*[npc_all]*/=type;
	npc_x  /*[npc_all]*/=px;
	npc_y  /*[npc_all]*/=py-16;
	npc_dir/*[npc_all]*/=rand8()<128?DIR_LEFT:DIR_RIGHT;
	npc_cnt/*[npc_all]*/=0;

	switch(type)
	{
	case TILE_NUM_CHIEF:
		npc_dir /*[npc_all]*/=DIR_NONE;
		npc_cnt /*[npc_all]*/=20;
		npc_spr /*[npc_all]*/=animChiefWalkLeft[0];
		npc_ty  /*[npc_all]*/=240;
		break;

	case TILE_NUM_BOUNCER:
		npc_spr /*[npc_all]*/=animBouncerWalkLeft[0];
		break;

	case TILE_NUM_CHATTER:
		npc_dir /*[npc_all]*/=DIR_NONE;
		npc_cnt /*[npc_all]*/=20;
		npc_wait/*[npc_all]*/=0;
		npc_spr /*[npc_all]*/=animChatterWalkLeft[0];
		break;

	case TILE_NUM_GEEK:
		npc_spr /*[npc_all]*/=animGeekWalkLeft[0];
		break;

	case TILE_NUM_MANBOX:
		npc_spr /*[npc_all]*/=animManBoxWalkLeft[0];
		break;

	case TILE_NUM_DIBROV:
		npc_spr  /*[npc_all]*/=animDibrovWalkLeft[0];
		npc_speed/*[npc_all]*/=1;
		break;

	case TILE_NUM_GHOST:
		npc_x   /*[npc_all]*/=16<<FP_BITS;
		npc_y   /*[npc_all]*/=240<<FP_BITS;
		npc_dx  /*[npc_all]*/=0;
		npc_dy  /*[npc_all]*/=0;
		npc_spr /*[npc_all]*/=sprChiefGhostR;
		npc_cnt /*[npc_all]*/=50;
		npc_wait/*[npc_all]*/=150;
		break;
	}

	++npc_all;
}



void npc_display(void)
{
	if(!npc_all) return;
	//for(i=0;i<npc_all;++i)
	//{
		switch(npc_type/*[i]*/)
		{
		case NPC_GHOST:
			spr=oam_meta_spr(npc_x/*[i]*/>>FP_BITS,(npc_y/*[i]*/>>FP_BITS)-1,spr,npc_spr/*[i]*/);
			break;

		case NPC_CHIEF:
			spr=oam_spr(npc_tx/*[i]*/  ,npc_ty/*[i]*/,0xfc,1,spr);//bla
			spr=oam_spr(npc_tx/*[i]*/+8,npc_ty/*[i]*/,0xfd,1,spr);

		default:
			spr=oam_meta_spr(npc_x/*[i]*/,npc_y/*[i]*/-1,spr,npc_spr/*[i]*/);//npc
		}
	//}
}



void npc_check_collision(void)
{
	if(!player_ladder)
	{
		if(player_py==py)
		{
			if(player_px+8<px+8)
			{
				if(player_px+16>=px+8)
				{
					player_x=(px+8-16)<<FP_BITS;
					player_coord_wrap();
				}
			}
			else
			{
				if(player_px<px+8)
				{
					player_x=(px+8)<<FP_BITS;
					player_coord_wrap();
				}
			}
		}
	}
}



void npc_chief_set_delay(void)
{
	npc_cnt/*[i]*/=64+(rand8()&31);
}



void npc_chief(void)
{
	if(!(py>=(player_py+24-8)||(py+24)<(player_py+8)))
	{
		if(!((px-32)>=(player_px+16)||(px+16+32)<player_px))
		{
			player_slowdown=1;
			npc_dir/*[i]*/=DIR_NONE;

			if(!npc_cnt/*[i]*/||npc_cnt/*[i]*/>25)
			{
				npc_cnt/*[i]*/=25;
				npc_tx/*[i]*/=npc_x/*[i]*/-8+(rand8()&15);
				npc_ty/*[i]*/=npc_y/*[i]*/-12+(rand8()&3);
				sfx_play(SFX_BLA1,3);
			}
			else
			{
				--npc_cnt/*[i]*/;
				if(npc_cnt/*[i]*/<10) npc_ty/*[i]*/=240;
			}

			j=(frame_cnt>>3)&3;

			npc_spr/*[i]*/=(player_px<px)?animChiefTalkLeft[j]:npc_spr/*[i]*/=animChiefTalkRight[j];

			return;
		}
	}

	npc_ty/*[i]*/=240;

	if(npc_cnt/*[i]*/)
	{
		j=(npc_x/*[i]*/>>2)&3;

		switch(npc_dir/*[i]*/)
		{
		case DIR_LEFT:
			{
				--npc_x/*[i]*/;

				if(npc_x/*[i]*/<9)//||!check_map(npc_x/*[i]*/-1,npc_y/*[i]*/+24))//no platform edges
				{
					npc_dir/*[i]*/=DIR_RIGHT;
					npc_chief_set_delay();
				}

				npc_spr/*[i]*/=animChiefWalkLeft[j];
			}
			break;

		case DIR_RIGHT:
			{
				++npc_x/*[i]*/;

				if(npc_x/*[i]*/>(256-16-9))//||!check_map(npc_x/*[i]*/+16,npc_y/*[i]*/+24))//no platform edges
				{
					npc_dir/*[i]*/=DIR_LEFT;
					npc_chief_set_delay();
				}

				npc_spr/*[i]*/=animChiefWalkRight[j];
			}
			break;

		default:
			if(!(npc_cnt/*[i]*/&15))
			{
				npc_spr/*[i]*/=(rand8()&128)?animChiefWalkLeft[j]:npc_spr/*[i]*/=animChiefWalkRight[j];
			}
		}

		--npc_cnt/*[i]*/;
	}
	else
	{
		if(npc_dir/*[i]*/)
		{
			npc_dir/*[i]*/=DIR_NONE;
		}
		else
		{
			if(npc_x/*[i]*/<64)
			{
				npc_dir/*[i]*/=DIR_RIGHT;
			}

			if(npc_x/*[i]*/>256-64)
			{
				npc_dir/*[i]*/=DIR_LEFT;
			}

			if(!npc_dir/*[i]*/) npc_dir/*[i]*/=1+(rand8()&1);
		}

		npc_chief_set_delay();
	}
}



void npc_bouncer(void)
{
	npc_check_collision();

	if(frame_cnt&3) return;

	j=(npc_x/*[i]*/>>2)&3;

	switch(npc_dir/*[i]*/)
	{
	case DIR_LEFT:
		{
			--npc_x/*[i]*/;

			if(npc_x/*[i]*/<9)//||!check_map(npc_x/*[i]*/+4-1,npc_y/*[i]*/+24))//no platform edges
			{
				npc_dir/*[i]*/=DIR_RIGHT;
			}

			npc_spr/*[i]*/=animBouncerWalkLeft[j];
		}
		break;

	case DIR_RIGHT:
		{
			++npc_x/*[i]*/;

			if(npc_x/*[i]*/>(256-16-9))//||!check_map(npc_x/*[i]*/+16-4,npc_y/*[i]*/+24))//no platform edges
			{
				npc_dir/*[i]*/=DIR_LEFT;
			}

			npc_spr/*[i]*/=animBouncerWalkRight[j];
		}
		break;
	}
}



void npc_chatter_set_delay(void)
{
	npc_cnt/*[i]*/=25+(rand8()&31);
}



void npc_chatter(void)
{
	if(npc_wait/*[i]*/)
	{
		if(npc_cnt/*[i]*/)
		{
			--npc_cnt/*[i]*/;

			j=(frame_cnt>>3)&3;

			npc_spr/*[i]*/=(player_px<px)?animChatterTalkLeft[j]:npc_spr/*[i]*/=animChatterTalkRight[j];

			return;
		}

		--npc_wait/*[i]*/;

		j=(frame_cnt>>3)%5;

		npc_spr/*[i]*/=(player_px<px)?animChatterGlassesLeft[j]:npc_spr/*[i]*/=animChatterGlassesRight[j];

		return;
	}

	if(player_py==py)
	{
		if(!((px-16)>=(player_px+16)||(px+16+16)<player_px))
		{
			if(!npc_wait/*[i]*/)
			{
				player_topic=rand8()%topics_active;
				npc_dir/*[i]*/=DIR_NONE;
				npc_wait/*[i]*/=100;
				npc_cnt/*[i]*/=50;
				sfx_play(SFX_BLA2,3);
			}

			return;
		}

		if(player_px<px)
		{
			npc_dir/*[i]*/=DIR_LEFT;
		}
		else
		{
			npc_dir/*[i]*/=DIR_RIGHT;
		}
	}
	else
	{
		if(frame_cnt&1) return;
	}

	if(npc_cnt/*[i]*/)
	{
		j=(npc_x/*[i]*/>>2)&3;

		switch(npc_dir/*[i]*/)
		{
		case DIR_LEFT:
			{
				--npc_x/*[i]*/;

				if(npc_x/*[i]*/<9)//||!check_map(npc_x/*[i]*/-1,npc_y/*[i]*/+24))//no platform edges
				{
					npc_dir/*[i]*/=DIR_RIGHT;
					npc_chatter_set_delay();
				}

				npc_spr/*[i]*/=animChatterWalkLeft[j];
			}
			break;

		case DIR_RIGHT:
			{
				++npc_x/*[i]*/;

				if(npc_x/*[i]*/>(256-16-9))//||!check_map(npc_x/*[i]*/+16,npc_y/*[i]*/+24))//no platform edges
				{
					npc_dir/*[i]*/=DIR_LEFT;
					npc_chatter_set_delay();
				}

				npc_spr/*[i]*/=animChatterWalkRight[j];
			}
			break;

		default:
			if(!(npc_cnt/*[i]*/&31))
			{
				npc_spr/*[i]*/=(rand8()&128)?animChatterWalkLeft[j]:npc_spr/*[i]*/=animChatterWalkRight[j];
			}
		}

		--npc_cnt/*[i]*/;
	}
	else
	{
		if(npc_dir/*[i]*/)
		{
			npc_dir/*[i]*/=DIR_NONE;
		}
		else
		{
			if(npc_x/*[i]*/<64)
			{
				npc_dir/*[i]*/=DIR_RIGHT;
			}

			if(npc_x/*[i]*/>256-64)
			{
				npc_dir/*[i]*/=DIR_LEFT;
			}

			if(!npc_dir/*[i]*/) npc_dir/*[i]*/=1+(rand8()&1);
		}

		npc_chatter_set_delay();
	}
}



void npc_geek(void)
{
	if(!player_ladder)
	{
		if(player_py==py&&abs(((int)player_px)-((int)px))<64)
		{
			j=(frame_cnt>>3)&1;

			if(player_px+8<px+8&&npc_dir/*[i]*/==DIR_LEFT)
			{
				if(player_px+16>=px+8&&player_dir==DIR_RIGHT)
				{
					player_x=(px+8-16)<<FP_BITS;
					player_coord_wrap();

					if(frame_cnt&1)
					{
						if(npc_x/*[i]*/<256-16) ++npc_x/*[i]*/;
					}
				}

				npc_spr/*[i]*/=animGeekStandLeft[j];

				if(!(frame_cnt&31)) hearts_add(px+4,py);

				return;
			}

			if(player_px+8>px+8&&npc_dir/*[i]*/==DIR_RIGHT)
			{
				if(player_px<px+8&&player_dir==DIR_LEFT)
				{
					player_x=(px+8)<<FP_BITS;
					player_coord_wrap();

					if(frame_cnt&1)
					{
						if(npc_x/*[i]*/>0) --npc_x/*[i]*/;
					}
				}

				npc_spr/*[i]*/=animGeekStandRight[j];

				if(!(frame_cnt&31)) hearts_add(px+4,py);

				return;
			}
		}
	}

	if(frame_cnt&1) return;

	j=(npc_x/*[i]*/>>2)&3;

	switch(npc_dir/*[i]*/)
	{
	case DIR_LEFT:
		{
			--npc_x/*[i]*/;

			if(npc_x/*[i]*/<9)//||!check_map(npc_x/*[i]*/+4-1,npc_y/*[i]*/+24))//no platform edges
			{
				npc_dir/*[i]*/=DIR_RIGHT;
			}

			npc_spr/*[i]*/=animGeekWalkLeft[j];
		}
		break;

	case DIR_RIGHT:
		{
			++npc_x/*[i]*/;

			if(npc_x/*[i]*/>(256-16-9))//||!check_map(npc_x/*[i]*/+16-4,npc_y/*[i]*/+24))//no platform edges
			{
				npc_dir/*[i]*/=DIR_LEFT;
			}

			npc_spr/*[i]*/=animGeekWalkRight[j];
		}
		break;
	}
}



void npc_change_floor_left(void)
{
	npc_dir/*[i]*/=DIR_RIGHT;
	npc_x/*[i]*/=-8;
	npc_y/*[i]*/=floor_left[rand8()%floor_left_cnt];
}



void npc_change_floor_right(void)
{
	npc_dir/*[i]*/=DIR_LEFT;
	npc_x/*[i]*/=248;
	npc_y/*[i]*/=floor_right[rand8()%floor_right_cnt];
}



void npc_manbox(void)
{
	if(npc_cnt/*[i]*/)
	{
		--npc_cnt/*[i]*/;
		return;
	}

	if(player_py==py)
	{
		if(!((player_px+16-4)<px||player_px>=(px+16-4)))
		{
			if(!player_knocked)
			{
				player_knocked=48;
				player_knocked_anim=8;
				npc_dir/*[i]*/=(npc_dir/*[i]*/==DIR_LEFT)?DIR_RIGHT:DIR_LEFT;
				sfx_play(SFX_KNOCK,1);
			}
			else
			{
				++player_knocked;
			}
		}
	}

	if(frame_cnt&1) return;

	j=(npc_x/*[i]*/>>2)&3;

	switch(npc_dir/*[i]*/)
	{
	case DIR_LEFT:
		{
			--npc_x/*[i]*/;

			if(npc_x/*[i]*/<-7)
			{
				npc_change_floor_left();
				npc_cnt/*[i]*/=50;
			}
			else
			{
				if(!check_map(npc_x/*[i]*/+4-1,npc_y/*[i]*/+24)) npc_dir/*[i]*/=DIR_RIGHT;
			}

			npc_spr/*[i]*/=animManBoxWalkLeft[j];
		}
		break;

	case DIR_RIGHT:
		{
			++npc_x/*[i]*/;

			if(npc_x/*[i]*/>=248)
			{
				npc_change_floor_right();
				npc_cnt/*[i]*/=50;
			}
			else
			{
				if(!check_map(npc_x/*[i]*/+16-4,npc_y/*[i]*/+24)) npc_dir/*[i]*/=DIR_LEFT;
			}

			npc_spr/*[i]*/=animManBoxWalkRight[j];
		}
		break;
	}
}



void npc_dibrov(void)
{
	if(npc_cnt/*[i]*/)
	{
		--npc_cnt/*[i]*/;
		return;
	}

	if(player_py==py)
	{
		if(!((player_px+16-4)<px||player_px>=(px+16-4)))
		{
			if(!player_wisdom)
			{
				player_wisdom=10*50;
				sfx_play(SFX_WISDOM,2);

				for(spr=0;spr<2;++spr) hearts_add(player_px+4,player_py+8-(spr<<2));
			}

		}

		npc_speed/*[i]*/=2;

		npc_dir/*[i]*/=((int)player_px)<npc_x/*[i]*/?DIR_RIGHT:DIR_LEFT;
	}
	else
	{
		npc_speed/*[i]*/=1;

		if(abs(((int)player_px)-npc_x/*[i]*/)<64) npc_dir/*[i]*/=((int)player_px)<npc_x/*[i]*/?DIR_RIGHT:DIR_LEFT;
	}

	if(npc_speed/*[i]*/<2&&frame_cnt&1) return;

	j=npc_speed/*[i]*/;

	if(j==2&&frame_cnt&1) j=1;

	switch(npc_dir/*[i]*/)//no platform edges on the level
	{
	case DIR_LEFT:
		/*if(!check_map(npc_x[i]+4-1 ,npc_y[i]+24)) npc_dir[i]=DIR_RIGHT; else */npc_x/*[i]*/-=j;
		break;

	case DIR_RIGHT:
		/*if(!check_map(npc_x[i]+16-4,npc_y[i]+24)) npc_dir[i]=DIR_LEFT; else */npc_x/*[i]*/+=j;
		break;
	}

	if(npc_x/*[i]*/>=248||npc_x/*[i]*/<-7)
	{
		npc_cnt/*[i]*/=player_wisdom?player_wisdom+25:25;

		if(player_px<128) npc_change_floor_right(); else npc_change_floor_left();
	}

	j=(npc_x/*[i]*/>>2)&3;

	npc_spr/*[i]*/=(npc_dir/*[i]*/==DIR_LEFT)?animDibrovWalkLeft[j]:npc_spr/*[i]*/=animDibrovWalkRight[j];
}



void npc_ghost(void)
{
	if(npc_wait/*[i]*/)
	{
		--npc_wait/*[i]*/;
		return;
	}

	++npc_cnt/*[i]*/;

	if(npc_cnt/*[i]*/>=100)
	{
		sfx_play(SFX_BLA1,3);
		npc_cnt/*[i]*/=0;
	}

	if(!(npc_x/*[i]*/+(16<<FP_BITS)< player_x||
	     npc_x/*[i]*/+ (8<<FP_BITS)>=player_x+(16<<FP_BITS)||
		 npc_y/*[i]*/+(16<<FP_BITS)< player_y||
		 npc_y/*[i]*/+ (8<<FP_BITS)>=player_y+(24<<FP_BITS)))
	{
		player_catch=1;
		npc_wait/*[i]*/=255;
		return;
	}

	if(player_x<npc_x/*[i]*/)
	{
		if(npc_y/*[i]*/<(240<<FP_BITS)&&npc_dx/*[i]*/>-16) --npc_dx/*[i]*/;

		npc_spr/*[i]*/=npc_cnt/*[i]*/<20?sprChiefGhostBlaL:sprChiefGhostL;
	}
	else
	{
		if(npc_y/*[i]*/<(240<<FP_BITS)&&npc_dx/*[i]*/< 16) ++npc_dx/*[i]*/;

		npc_spr/*[i]*/=npc_cnt/*[i]*/<20?sprChiefGhostBlaR:sprChiefGhostR;
	}

	if(player_y<npc_y/*[i]*/)
	{
		if(npc_dy/*[i]*/>-12) --npc_dy/*[i]*/;
	}
	else
	{
		if(npc_dy/*[i]*/< 12) ++npc_dy/*[i]*/;
	}

	npc_x/*[i]*/+=npc_dx/*[i]*/;
	npc_y/*[i]*/+=npc_dy/*[i]*/;
}