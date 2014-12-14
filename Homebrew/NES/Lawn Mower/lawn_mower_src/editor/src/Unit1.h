//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ImgList.hpp>
#include <ExtCtrls.hpp>
#include <ComCtrls.hpp>
//---------------------------------------------------------------------------
class TFormMain : public TForm
{
__published:	// IDE-managed Components
	TImageList *ImageListTiles;
	TPaintBox *PaintBoxMap;
	TPaintBox *PaintBoxPal;
	TPaintBox *PaintBoxTile;
	TLabel *LabelLevel;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall PaintBoxMapPaint(TObject *Sender);
	void __fastcall PaintBoxPalPaint(TObject *Sender);
	void __fastcall PaintBoxTilePaint(TObject *Sender);
	void __fastcall PaintBoxMapMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
	void __fastcall PaintBoxMapMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
	void __fastcall PaintBoxPalMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
	void __fastcall PaintBoxPalMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
	void __fastcall FormKeyDown(TObject *Sender, WORD &Key, TShiftState Shift);
	void __fastcall FormDestroy(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TFormMain(TComponent* Owner);
	void __fastcall UpdateMap(void);
};
//---------------------------------------------------------------------------
extern PACKAGE TFormMain *FormMain;
//---------------------------------------------------------------------------
#endif
