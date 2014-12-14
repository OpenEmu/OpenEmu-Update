//---------------------------------------------------------------------------

#include <vcl.h>
#include <stdio.h>
#include <math.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TFormMain *FormMain;


const int width=30;
const int height=11;
const int levels=10;

int level;
int tile;

unsigned char map[width*height*levels];
unsigned int params[levels];



void __fastcall TFormMain::UpdateMap(void)
{
	int i,j,x,y;

	y=0;

	PaintBoxMap->Canvas->Brush->Style=bsSolid;

	for(i=0;i<height;i++)
	{
		x=0;

		for(j=0;j<width;j++)
		{
			if(j<(int)(params[level]&255))
			{
				ImageListTiles->Draw(PaintBoxMap->Canvas,x,y,map[level*width*height+i*width+j]);
			}
			else
			{
				PaintBoxMap->Canvas->Brush->Color=clGray;
				PaintBoxMap->Canvas->FillRect(Rect(x,y,x+32,y+32));
			}
			if((int)((params[level]>>8)&255)==j&&(int)((params[level]>>16)&255)==i)
			{
				PaintBoxMap->Canvas->Brush->Color=clWhite;
				PaintBoxMap->Canvas->FillRect(Rect(x+4,y+4,x+16,y+16));
			}
			x+=32;
		}
		y+=32;
	}

	LabelLevel->Caption="Level "+IntToStr(level+1)+" Width "+IntToStr(params[level]&255);
}



//---------------------------------------------------------------------------
__fastcall TFormMain::TFormMain(TComponent* Owner)
: TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::FormCreate(TObject *Sender)
{
	int i;
	FILE *file;

	for(i=0;i<width*height*levels;i++) map[i]=1;

	file=fopen("levels.bin","rb");

	if(file)
	{
		fread(map,width*height*levels,1,file);
		fread(params,levels*4,1,file);
		//for(i=0;i<levels;i++) params[i]=30;
		fclose(file);
	}

	level=0;
	tile=0;

	UpdateMap();
}
//---------------------------------------------------------------------------



void __fastcall TFormMain::PaintBoxMapPaint(TObject *Sender)
{
	UpdateMap();
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::PaintBoxPalPaint(TObject *Sender)
{
	int i;

	for(i=0;i<8;i++)
	{
		ImageListTiles->Draw(PaintBoxPal->Canvas,i*32,0,i);
	}
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::PaintBoxTilePaint(TObject *Sender)
{
	ImageListTiles->Draw(PaintBoxTile->Canvas,0,0,tile);
}
//---------------------------------------------------------------------------


void __fastcall TFormMain::PaintBoxMapMouseDown(TObject *Sender,
TMouseButton Button, TShiftState Shift, int X, int Y)
{
	PaintBoxMapMouseMove(Sender,Shift,X,Y|0x1000);
}
//---------------------------------------------------------------------------


void __fastcall TFormMain::PaintBoxMapMouseMove(TObject *Sender,
TShiftState Shift, int X, int Y)
{
	int tx,ty,off,prev;
	bool down;

	down=Y&0x1000?true:false;
	Y&=~0x1000;

	if(X>=0&&X<width*32&&Y>=0&&Y<height*32)
	{
		tx=X/32;
		ty=Y/32;
		off=level*width*height+ty*width+tx;

		if(Shift.Contains(ssLeft))
		{
			if(!Shift.Contains(ssShift))
			{
				prev=map[off];
				map[off]=tile;
				if(prev!=tile) UpdateMap();
			}
			else
			{
				if(down)
				{
					params[level]=(params[level]&255)|(tx<<8)|(ty<<16);
					UpdateMap();
				}
			}
		}

		if(Shift.Contains(ssRight))
		{
			prev=tile;
			tile=map[off];
			if(prev!=tile) PaintBoxTile->Repaint();
		}
	}
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::PaintBoxPalMouseDown(TObject *Sender,
TMouseButton Button, TShiftState Shift, int X, int Y)
{
	PaintBoxPalMouseMove(Sender,Shift,X,Y);
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::PaintBoxPalMouseMove(TObject *Sender,
TShiftState Shift, int X, int Y)
{
	int prev;

	if(X>=0&&X<4*32&&Y>=0&&Y<32)
	{
		if(Shift.Contains(ssLeft))
		{
			prev=tile;
			tile=X/32;
			if(prev!=tile) PaintBoxTile->Repaint();
		}
	}
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::FormKeyDown(TObject *Sender, WORD &Key,
TShiftState Shift)
{
	bool update;
	int i,j,off,t;
	unsigned char temp[width];

	update=false;

	if(Key==VK_ADD&&level<levels-1)
	{
		level++;
		update=true;
	}

	if(Key==VK_SUBTRACT&&level>0)
	{
		level--;
		update=true;
	}

	if(Key==VK_LEFT)
	{
		off=level*width*height;
		for(i=0;i<height;i++) temp[i]=map[off+i*width];

		for(i=0;i<height;i++)
		{
			off=level*width*height+i*width;
			for(j=0;j<width-1;j++) map[off+j]=map[off+j+1];
		}

		off=level*width*height+width-1;
		for(i=0;i<height;i++) map[off+i*width]=temp[i];

		update=true;
	}

	if(Key==VK_RIGHT)
	{
		off=level*width*height+width-1;
		for(i=0;i<height;i++) temp[i]=map[off+i*width];

		for(i=0;i<height;i++)
		{
			off=level*width*height+i*width;
			for(j=width-1;j>0;j--) map[off+j]=map[off+j-1];
		}

		off=level*width*height;
		for(i=0;i<height;i++) map[off+i*width]=temp[i];

		update=true;
	}

	if(Key==VK_UP)
	{
		off=level*width*height;
		for(i=0;i<width;i++) temp[i]=map[off+i];

		for(i=0;i<width;i++)
		{
			off=level*width*height+i;
			for(j=0;j<height-1;j++) map[off+j*width]=map[off+(j+1)*width];
		}

		off=level*width*height+(height-1)*width;
		for(i=0;i<width;i++) map[off+i]=temp[i];

		update=true;
	}

	if(Key==VK_DOWN)
	{
		off=level*width*height+(height-1)*width;
		for(i=0;i<width;i++) temp[i]=map[off+i];

		for(i=0;i<width;i++)
		{
			off=level*width*height+i;
			for(j=height-1;j>0;j--) map[off+j*width]=map[off+(j-1)*width];
		}

		off=level*width*height;
		for(i=0;i<width;i++) map[off+i]=temp[i];

		update=true;
	}

	if(Key==VK_PRIOR)
	{
		if(level>0)
		{
			level--;
			off=level*width*height;
			for(i=0;i<width*height;i++)
			{
				j=map[off+i];
				map[off+i]=map[off+i+width*height];
				map[off+i+width*height]=j;
			}
			update=true;
			j=params[level];
			params[level]=params[level+1];
			params[level+1]=j;
		}
	}

	if(Key==VK_NEXT)
	{
		if(level<49)
		{
			off=level*width*height;
			for(i=0;i<width*height;i++)
			{
				j=map[off+i];
				map[off+i]=map[off+i+width*height];
				map[off+i+width*height]=j;
			}
			j=params[level];
			params[level]=params[level+1];
			params[level+1]=j;
			level++;
			update=true;
		}
	}

	if(Key==VK_HOME)
	{
		if((params[level]&255)>14)
		{
			params[level]=(params[level]&~255)|((params[level]-1)&255);
			update=true;
		}
	}

	if(Key==VK_END)
	{
		if((params[level]&255)<30)
		{
			params[level]=(params[level]&~255)|((params[level]+1)&255);
			update=true;
		}
	}

	if(update) UpdateMap();
}
//---------------------------------------------------------------------------

void __fastcall TFormMain::FormDestroy(TObject *Sender)
{
	FILE *file;
	int i,j,k,l,bits,off,rt;
	float tcnt;
	bool ok;
	unsigned char buf[32*11];

	file=fopen("levels.bin","wb");

	if(file)
	{
		fwrite(map,width*height*levels,1,file);
		fwrite(params,levels*4,1,file);
		fclose(file);
	}
	/*
	file=fopen("levels.asm","wt");

	if(file)
	{
		fprintf(file,"levList\n");

		for(i=0;i<levels;i++) fprintf(file,"\t.dw .level%i\n",i+1);

		for(i=0;i<levels;i++)
		{
			fprintf(file,".level%i\n\t.db ",i+1);

			off=i*width*height;
			memset(buf,0,32*11);
			tcnt=0;

			for(j=0;j<height;j++)
			{
				for(k=0;k<width;k++)
				{
					if(k<(int)(params[i]&255))
					{
						buf[j*32+1+k]=map[off];
						if(map[off]==1) tcnt++;
					}
					else
					{
						buf[j*32+1+k]=0;
					}
					off++;
				}
			}

			l=0;

			for(j=0;j<32*11;j++)
			{
				if(!(j&3)) k=buf[j]; else k=(k<<2)|buf[j];
				l++;
				if((j&3)==3)
				{
					fprintf(file,"$%2.2x",k);
					if(l<44) fprintf(file,",");
				}
				if(l==44)
				{
					fprintf(file,"\n\t.db ");
					l=0;
				}
			}
			fprintf(file,"$%2.2x\n",params[i]&255);
			fprintf(file,"\t.db $%2.2x\n",((params[i]>>8)&255)+1);
			fprintf(file,"\t.db $%2.2x\n",((params[i]>>16)&255)+3);
			fprintf(file,"\t.dw $%4.4x\n",(int)tcnt);
			fprintf(file,"\t.dw $%4.4x\n",(int)(100.0f*256.0f/tcnt));
		}
		fclose(file);
	}
	*/
	unsigned char data[8192];
	unsigned char chr[8192];
	int pp;

	pp=0;

		for(i=0;i<levels;i++)
		{
			off=i*width*height;
			memset(buf,0,32*11);
			tcnt=0;

			for(j=0;j<height;j++)
			{
				for(k=0;k<width;k++)
				{
					if(k<(int)(params[i]&255))
					{
						buf[j*32+1+k]=map[off];
						if(map[off]==1) tcnt++;
					}
					else
					{
						buf[j*32+1+k]=0;
					}
					off++;
				}
			}

			l=0;

			for(j=0;j<32*11;j++)
			{
				if(!(j&3)) k=buf[j]; else k=(k<<2)|buf[j];
				l++;
				if((j&3)==3)
				{
					data[pp++]=k;
				}
				if(l==44)
				{
					l=0;
				}
			}
			data[pp++]=params[i]&255;
			data[pp++]=((params[i]>>8)&255)+1;
			data[pp++]=((params[i]>>16)&255)+3;
			data[pp++]=((int)tcnt)&255;
			data[pp++]=((int)tcnt)/256;
			data[pp++]=((int)(100.0f*256.0f/tcnt))&255;
			data[pp++]=((int)(100.0f*256.0f/tcnt))/256;
		}

		file=fopen("patterns.chr","rb");

		if(file)
		{
			fread(chr,8192,1,file);
			fclose(file);
			file=fopen("patterns.chr","wb");
			memcpy(chr+4096,data,pp);
			fwrite(chr,8192,1,file);
			fclose(file);
		}
		else
		{
            Application->MessageBox("patterns.chr not found\n","Error",MB_OK);
        }
}
//---------------------------------------------------------------------------



