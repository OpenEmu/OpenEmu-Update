VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmMain 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "LEVEL EDITOR - untitled"
   ClientHeight    =   10440
   ClientLeft      =   360
   ClientTop       =   810
   ClientWidth     =   13845
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   696
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   923
   Begin VB.CommandButton cmdGtweakDown 
      Caption         =   "'"
      Height          =   195
      Left            =   6360
      TabIndex        =   77
      Top             =   9960
      Width           =   135
   End
   Begin VB.CommandButton cmdGtweakRight 
      Caption         =   "'"
      Height          =   195
      Left            =   6480
      TabIndex        =   76
      Top             =   9720
      Width           =   135
   End
   Begin VB.CommandButton cmdGtweakLeft 
      Caption         =   "'"
      Height          =   195
      Left            =   6240
      TabIndex        =   75
      Top             =   9720
      Width           =   135
   End
   Begin VB.CommandButton cmdGtweakUp 
      Caption         =   "'"
      Height          =   195
      Left            =   6360
      TabIndex        =   74
      Top             =   9480
      Width           =   135
   End
   Begin VB.Frame Frame6 
      Caption         =   "paint object:"
      Height          =   975
      Left            =   4440
      TabIndex        =   62
      Top             =   8520
      Width           =   1815
      Begin VB.TextBox txtOBJattr 
         Height          =   285
         Index           =   3
         Left            =   1200
         TabIndex        =   71
         Text            =   "255"
         Top             =   600
         Width           =   375
      End
      Begin VB.TextBox txtOBJattr 
         Height          =   285
         Index           =   2
         Left            =   840
         TabIndex        =   70
         Text            =   "0"
         Top             =   600
         Width           =   375
      End
      Begin VB.TextBox txtOBJattr 
         Height          =   285
         Index           =   1
         Left            =   480
         TabIndex        =   69
         Text            =   "0"
         Top             =   600
         Width           =   375
      End
      Begin VB.TextBox txtOBJattr 
         Height          =   285
         Index           =   0
         Left            =   120
         TabIndex        =   68
         Text            =   "0"
         Top             =   600
         Width           =   375
      End
      Begin VB.OptionButton optOBJdir 
         Height          =   195
         Index           =   2
         Left            =   1080
         Style           =   1  'Graphical
         TabIndex        =   67
         Top             =   240
         Width           =   135
      End
      Begin VB.OptionButton optOBJdir 
         Height          =   195
         Index           =   3
         Left            =   960
         Style           =   1  'Graphical
         TabIndex        =   66
         Top             =   360
         Width           =   135
      End
      Begin VB.OptionButton optOBJdir 
         Height          =   195
         Index           =   0
         Left            =   840
         Style           =   1  'Graphical
         TabIndex        =   65
         Top             =   240
         Value           =   -1  'True
         Width           =   135
      End
      Begin VB.OptionButton optOBJdir 
         Height          =   195
         Index           =   1
         Left            =   960
         Style           =   1  'Graphical
         TabIndex        =   64
         Top             =   120
         Width           =   135
      End
      Begin VB.Label Label7 
         Caption         =   "direction:"
         Height          =   255
         Left            =   120
         TabIndex        =   63
         Top             =   240
         Width           =   615
      End
   End
   Begin VB.ListBox lstObjects 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   6.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2010
      Left            =   4320
      TabIndex        =   56
      ToolTipText     =   "select an object and click on the screen to paint"
      Top             =   6360
      Width           =   1695
   End
   Begin MSComDlg.CommonDialog cd 
      Left            =   5280
      Top             =   9600
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      CancelError     =   -1  'True
   End
   Begin VB.Frame Frame3 
      BorderStyle     =   0  'None
      Caption         =   "object attributes"
      Height          =   855
      Left            =   4440
      TabIndex        =   57
      Top             =   9480
      Width           =   1815
      Begin VB.Label lblATTR 
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   72
         Top             =   480
         Width           =   1575
      End
      Begin VB.Label lblOBJdir 
         Caption         =   "DIRECTION: RIGHT"
         Height          =   255
         Left            =   120
         TabIndex        =   59
         Top             =   240
         Width           =   1575
      End
      Begin VB.Label lblOBJtype 
         Caption         =   "TYPE:"
         Height          =   255
         Left            =   120
         TabIndex        =   58
         Top             =   0
         Width           =   1455
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "edit layer"
      Height          =   2655
      Left            =   6240
      TabIndex        =   23
      Top             =   6600
      Width           =   3495
      Begin VB.PictureBox picTilePrev 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         ForeColor       =   &H80000008&
         Height          =   510
         Left            =   2640
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   55
         Top             =   2040
         Width           =   510
      End
      Begin VB.CheckBox chkMaskDestruct 
         Caption         =   "DESTR"
         Height          =   255
         Left            =   2520
         TabIndex        =   49
         ToolTipText     =   "if set, the destructable attribute will be affected during painting"
         Top             =   1680
         Width           =   855
      End
      Begin VB.CheckBox chkPaintDestruct 
         Caption         =   "DESTR"
         Height          =   255
         Left            =   1560
         TabIndex        =   48
         ToolTipText     =   "toggle 'destructable' attribute"
         Top             =   1920
         Width           =   975
      End
      Begin MSComctlLib.ListView lstLayers 
         Height          =   2295
         Left            =   120
         TabIndex        =   45
         Top             =   240
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   4048
         View            =   2
         LabelWrap       =   0   'False
         HideSelection   =   0   'False
         Checkboxes      =   -1  'True
         FlatScrollBar   =   -1  'True
         GridLines       =   -1  'True
         TextBackground  =   -1  'True
         _Version        =   393217
         ForeColor       =   0
         BackColor       =   -2147483633
         Appearance      =   0
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "Terminal"
            Size            =   6
            Charset         =   255
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         NumItems        =   0
      End
      Begin VB.CheckBox chkTileMask 
         Caption         =   "TILE"
         Height          =   255
         Left            =   2520
         TabIndex        =   44
         ToolTipText     =   "if set, the tile (including hflip/vflip) will be affected during painting"
         Top             =   1200
         Value           =   1  'Checked
         Width           =   855
      End
      Begin VB.CheckBox chkSolidMask 
         Caption         =   "SOLID"
         Height          =   255
         Left            =   2520
         TabIndex        =   43
         ToolTipText     =   "if set, the solid attribute will be affected during painting"
         Top             =   1440
         Width           =   855
      End
      Begin VB.CommandButton Command4 
         Caption         =   "down"
         Height          =   255
         Left            =   2640
         TabIndex        =   41
         Top             =   720
         Width           =   735
      End
      Begin VB.CommandButton Command3 
         Caption         =   "up"
         Height          =   255
         Left            =   2040
         TabIndex        =   40
         Top             =   720
         Width           =   615
      End
      Begin VB.CommandButton cmdAddLayer 
         Caption         =   "Add Layer"
         Height          =   255
         Left            =   1560
         TabIndex        =   34
         Top             =   480
         Width           =   1815
      End
      Begin VB.CommandButton Command1 
         Caption         =   "del"
         Height          =   255
         Left            =   2760
         TabIndex        =   39
         Top             =   240
         Width           =   615
      End
      Begin VB.CheckBox chkSolid 
         Caption         =   "SOLID"
         Height          =   255
         Left            =   1560
         TabIndex        =   38
         ToolTipText     =   "toggle 'solid' attribute"
         Top             =   1680
         Width           =   855
      End
      Begin VB.CheckBox chkVFlip 
         Caption         =   "VFLIP"
         Height          =   255
         Left            =   1560
         TabIndex        =   37
         ToolTipText     =   "toggle vertical flipping"
         Top             =   1440
         Width           =   855
      End
      Begin VB.CheckBox chkHFlip 
         Caption         =   "HFLIP"
         Height          =   255
         Left            =   1560
         TabIndex        =   36
         ToolTipText     =   "toggle horizontal flip"
         Top             =   1200
         Width           =   855
      End
      Begin VB.OptionButton optLayer 
         Caption         =   "L2"
         Height          =   255
         Index           =   1
         Left            =   2040
         TabIndex        =   33
         Top             =   240
         Width           =   495
      End
      Begin VB.OptionButton optLayer 
         Caption         =   "L1"
         Height          =   255
         Index           =   0
         Left            =   1560
         TabIndex        =   32
         Top             =   240
         Value           =   -1  'True
         Width           =   495
      End
      Begin VB.Label Label10 
         Caption         =   "mask:"
         Height          =   255
         Left            =   2520
         TabIndex        =   42
         Top             =   960
         Width           =   855
      End
      Begin VB.Label Label8 
         Caption         =   "brush:"
         Height          =   255
         Left            =   1560
         TabIndex        =   35
         Top             =   960
         Width           =   855
      End
   End
   Begin VB.CommandButton Command6 
      Caption         =   "background colour"
      Height          =   375
      Left            =   8400
      TabIndex        =   53
      Top             =   6240
      Width           =   1455
   End
   Begin VB.CommandButton Command5 
      Caption         =   "tileset bg"
      Height          =   255
      Left            =   9000
      TabIndex        =   52
      Top             =   9360
      Width           =   855
   End
   Begin VB.PictureBox picDongles 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      Height          =   1020
      Left            =   10200
      Picture         =   "frmMain.frx":0CCA
      ScaleHeight     =   64
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   108
      TabIndex        =   47
      Top             =   6960
      Visible         =   0   'False
      Width           =   1680
   End
   Begin VB.PictureBox picSubViewport 
      Appearance      =   0  'Flat
      BackColor       =   &H00400000&
      ForeColor       =   &H80000008&
      Height          =   3015
      Left            =   0
      ScaleHeight     =   199
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   279
      TabIndex        =   1
      Top             =   5880
      Width           =   4215
      Begin VB.PictureBox picThumb 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C000&
         BorderStyle     =   0  'None
         ForeColor       =   &H80000008&
         Height          =   3135
         Left            =   480
         ScaleHeight     =   209
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   377
         TabIndex        =   22
         Top             =   600
         Width           =   5655
      End
      Begin VB.Label Label1 
         BackColor       =   &H00FFFFFF&
         Caption         =   "THUMBNAIL"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   6
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   135
         Left            =   0
         TabIndex        =   7
         Top             =   0
         Width           =   735
      End
   End
   Begin VB.PictureBox deprecate1 
      Appearance      =   0  'Flat
      BackColor       =   &H008080FF&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5760
      Left            =   6720
      ScaleHeight     =   384
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   128
      TabIndex        =   46
      Top             =   11280
      Visible         =   0   'False
      Width           =   1920
   End
   Begin VB.PictureBox picTilesMask 
      Appearance      =   0  'Flat
      BackColor       =   &H000000FF&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   92160
      Left            =   11280
      ScaleHeight     =   6144
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   32
      TabIndex        =   18
      Top             =   1800
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.PictureBox picTilesData 
      Appearance      =   0  'Flat
      BackColor       =   &H008080FF&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   92160
      Left            =   10200
      ScaleHeight     =   6144
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   32
      TabIndex        =   20
      Top             =   600
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.CommandButton Command2 
      Caption         =   "LOAD CUSTOM TILES"
      Enabled         =   0   'False
      Height          =   375
      Left            =   7800
      TabIndex        =   19
      Top             =   9840
      Width           =   2175
   End
   Begin VB.ComboBox Combo2 
      Height          =   315
      Left            =   6960
      TabIndex        =   16
      Text            =   "Combo2"
      Top             =   6240
      Width           =   1455
   End
   Begin VB.Frame Frame2 
      Caption         =   "size specification"
      Height          =   1095
      Left            =   0
      TabIndex        =   10
      Top             =   9240
      Width           =   2295
      Begin VB.TextBox txtMapBoundY 
         Height          =   285
         Left            =   960
         MaxLength       =   2
         TabIndex        =   14
         Text            =   "32"
         ToolTipText     =   "the height (in tiles) of the map"
         Top             =   600
         Width           =   1095
      End
      Begin VB.TextBox txtMapBoundX 
         Height          =   285
         Left            =   960
         MaxLength       =   2
         TabIndex        =   12
         Text            =   "64"
         ToolTipText     =   "the width (in tiles) of the map"
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label Label4 
         Caption         =   "height"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   600
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "width"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   240
         Width           =   735
      End
   End
   Begin VB.ComboBox cbThemes 
      Height          =   315
      ItemData        =   "frmMain.frx":5E0C
      Left            =   6960
      List            =   "frmMain.frx":5E0E
      Style           =   2  'Dropdown List
      TabIndex        =   8
      Top             =   5880
      Width           =   2175
   End
   Begin VB.PictureBox picMainViewport 
      Appearance      =   0  'Flat
      BackColor       =   &H00400000&
      ForeColor       =   &H80000008&
      Height          =   5895
      Left            =   0
      ScaleHeight     =   391
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   647
      TabIndex        =   0
      Top             =   0
      Width           =   9735
      Begin VB.PictureBox picEdit 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Lucida Console"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   7680
         Left            =   120
         ScaleHeight     =   512
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   1024
         TabIndex        =   21
         Top             =   120
         Width           =   15360
      End
   End
   Begin VB.Frame Frame1 
      BackColor       =   &H00E0E0E0&
      BorderStyle     =   0  'None
      Caption         =   "Frame1"
      Height          =   375
      Left            =   0
      TabIndex        =   3
      Top             =   8880
      Width           =   1215
      Begin VB.OptionButton Option3 
         Caption         =   "1/2"
         Height          =   255
         Left            =   720
         Style           =   1  'Graphical
         TabIndex        =   6
         Top             =   0
         Value           =   -1  'True
         Width           =   375
      End
      Begin VB.OptionButton Option2 
         Caption         =   "1/4"
         Height          =   255
         Left            =   360
         Style           =   1  'Graphical
         TabIndex        =   5
         Top             =   0
         Width           =   375
      End
      Begin VB.OptionButton Option1 
         Caption         =   "1/8"
         Height          =   255
         Left            =   0
         Style           =   1  'Graphical
         TabIndex        =   4
         Top             =   0
         Width           =   375
      End
   End
   Begin VB.CheckBox chkSelMIsaligned 
      Caption         =   "Select Misaligned"
      Height          =   255
      Left            =   6600
      TabIndex        =   30
      ToolTipText     =   "allow misaligned tile selection (warning!)"
      Top             =   9360
      Width           =   1680
   End
   Begin VB.CheckBox chkTilesetGrid 
      Caption         =   "Grid"
      Height          =   255
      Left            =   8280
      TabIndex        =   31
      Top             =   9360
      Width           =   615
   End
   Begin VB.CheckBox chkThumbActive 
      Caption         =   "ACTIVE"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   6
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   1200
      TabIndex        =   51
      Top             =   8880
      Width           =   855
   End
   Begin VB.CommandButton cmdLoadTiles 
      Caption         =   "LOAD"
      Height          =   330
      Left            =   9120
      TabIndex        =   17
      Top             =   5880
      Width           =   615
   End
   Begin VB.Frame Frame5 
      Caption         =   "SHOW"
      Height          =   1455
      Left            =   2280
      TabIndex        =   24
      Top             =   8880
      Width           =   2175
      Begin VB.CheckBox chkShowObjects 
         Caption         =   "objects"
         Height          =   255
         Left            =   120
         TabIndex        =   60
         Top             =   960
         Value           =   1  'Checked
         Width           =   975
      End
      Begin VB.CheckBox chkShowGrid 
         Caption         =   "grid"
         Height          =   255
         Left            =   120
         TabIndex        =   50
         ToolTipText     =   "toggle grid"
         Top             =   720
         Width           =   615
      End
      Begin VB.CheckBox chkShowSolid 
         Caption         =   "solid"
         Height          =   255
         Left            =   840
         TabIndex        =   28
         ToolTipText     =   "toggle markings on 'solid' tiles"
         Top             =   480
         Value           =   1  'Checked
         Width           =   1215
      End
      Begin VB.CheckBox chkShowL3 
         Caption         =   "layer3 (?)"
         Enabled         =   0   'False
         Height          =   255
         Left            =   840
         TabIndex        =   27
         Top             =   240
         Width           =   1215
      End
      Begin VB.CheckBox chkShowLayer 
         Caption         =   "layer2"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   26
         ToolTipText     =   "toggle display of layer2 (BG2)"
         Top             =   480
         Value           =   1  'Checked
         Width           =   1215
      End
      Begin VB.CheckBox chkShowLayer 
         Caption         =   "layer1"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   25
         ToolTipText     =   "toggle display of layer1 (BG1)"
         Top             =   240
         Value           =   1  'Checked
         Width           =   1095
      End
      Begin VB.CheckBox chkShowDestruct 
         Caption         =   "destructable"
         Height          =   255
         Left            =   840
         TabIndex        =   29
         ToolTipText     =   "toggle markings on 'destructable' tiles"
         Top             =   720
         Value           =   1  'Checked
         Width           =   1215
      End
   End
   Begin VB.PictureBox picTiles 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H0080FFFF&
      ForeColor       =   &H80000008&
      Height          =   10455
      Left            =   9960
      ScaleHeight     =   695
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   256
      TabIndex        =   2
      Top             =   0
      Width           =   3870
      Begin VB.PictureBox picSpTiles 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         Height          =   1020
         Left            =   1320
         Picture         =   "frmMain.frx":5E10
         ScaleHeight     =   64
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   128
         TabIndex        =   73
         Top             =   960
         Visible         =   0   'False
         Width           =   1980
      End
   End
   Begin VB.Label Label9 
      Caption         =   "global TWEAK"
      Height          =   255
      Left            =   6525
      TabIndex        =   78
      Top             =   9960
      Width           =   1095
   End
   Begin VB.Label lblXY 
      Caption         =   "Label12"
      Height          =   375
      Left            =   5040
      TabIndex        =   61
      Top             =   5880
      Width           =   1335
   End
   Begin VB.Label Label6 
      Caption         =   "objects:"
      Height          =   255
      Left            =   4320
      TabIndex        =   54
      Top             =   6000
      Width           =   615
   End
   Begin VB.Shape shpEdit 
      BorderColor     =   &H000000FF&
      BorderWidth     =   8
      Height          =   5895
      Left            =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   9735
   End
   Begin VB.Label Label5 
      BackStyle       =   0  'Transparent
      Caption         =   "MUSIC"
      Height          =   255
      Left            =   6360
      TabIndex        =   15
      Top             =   6240
      Width           =   615
   End
   Begin VB.Label Label2 
      BackStyle       =   0  'Transparent
      Caption         =   "tileset"
      Height          =   255
      Left            =   6360
      TabIndex        =   9
      Top             =   5925
      Width           =   615
   End
   Begin VB.Shape Shape1 
      BorderStyle     =   0  'Transparent
      FillStyle       =   0  'Solid
      Height          =   2025
      Left            =   4380
      Top             =   6435
      Width           =   1710
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileNew 
         Caption         =   "&New"
         Shortcut        =   ^N
      End
      Begin VB.Menu mnuFileLoad 
         Caption         =   "&Load"
         Shortcut        =   ^L
      End
      Begin VB.Menu mnuFileSave 
         Caption         =   "&Save"
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuFileSaveAs 
         Caption         =   "Save &As"
      End
      Begin VB.Menu mnudiv1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileExport 
         Caption         =   "&EXPORT"
      End
      Begin VB.Menu mnudiv2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuQUIT 
         Caption         =   "&QUIT"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpHALP 
         Caption         =   "&HALP"
         Shortcut        =   ^H
      End
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private tilesetBGcolor As Long

Private mapBGcolor As Long

Private drawSel As Long
Private prevSel As Long
Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long

' drag main window
Dim bDragMain As Boolean
Dim dragMainX As Long
Dim dragMainY As Long

Dim bDragThumb As Boolean
Dim dragThumbX As Long
Dim dragThumbY As Long

Private Enum PaintModes
    PM_BG
    PM_OBJ
End Enum

Dim bPaint As Boolean
Dim paintMode As PaintModes
Dim paintX As Long, paintY As Long
Dim paintOBJdir As Long

Dim LAYERS(1) As New mapLayer
Dim OBJECTS As New ObjectsLayer
Dim AL As Long

Dim thumbScale As Double

Dim current_filename As String

Dim mapBoundX As Long
Dim mapBoundY As Long

Private Declare Function StretchBlt Lib "gdi32" (ByVal hdc As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal nSrcWidth As Long, ByVal nSrcHeight As Long, ByVal dwRop As Long) As Long

Private themesList() As String
Private CurTheme As Long

Dim cTileset As New TilesetLoader

Dim ObjectNames() As String

Dim STR_DIRECTIONS(3) As String

'Private Sub AddObjectEntry(ByVal nm As String)
'    lstObjects.AddItem nm
'End Sub

Private Function Color24_to_16(col As Long) As Long
    Dim r As Long, g As Long, b As Long
    r = col And 255
    g = (col \ 256) And 255
    b = (col \ 65536) And 255
    Color24_to_16 = (r \ 8) + (g \ 8) * 32 + (b \ 8) * 1024
End Function

Private Sub PopulateObjects()
    Open App.Path & "\objects.txt" For Input As #1
    Dim content As String
    Dim inp As String
    Do Until EOF(1)
        Line Input #1, inp
        If content <> "" Then
            content = content & vbCrLf & inp
        Else
            content = inp
        End If
    Loop
    
    Close #1
    
    ObjectNames = Split(content, vbCrLf)
    
    Dim i As Integer
    For i = 0 To UBound(ObjectNames)
        lstObjects.AddItem ObjectNames(i)
    Next
End Sub

Private Function Clamp(ByVal v As Long, ByVal l As Long, ByVal h As Long) As Long
    If v < l Then v = l
    If v > h Then v = h
Clamp = v
End Function

Private Sub LoadTileset(ByVal Index As Long)
    CurTheme = Index
    cbThemes.ListIndex = CurTheme
    Me.Enabled = False
    frmLoader.ShowWindow "Loading Tileset..."
    frmLoader.Show
    DoEvents
    
   ' picTilesOrig.AutoRedraw = True
    'picTilesOrig.Picture = LoadPicture(filename)
    
    
    cTileset.LoadTileset App.Path & "\" & themesList(Index)
    
    Dim tx As Long, ty As Long, x As Long, y As Long
    
    'For ty = 0 To 319
     '   For tx = 0 To 127
 '           picTilesOrig.PSet (tx, ty), loader.GetPixel(tx, ty)
      '  Next
    'Next
    
    picTilesData.AutoRedraw = True
    picTilesMask.AutoRedraw = True
    
    Dim fx As Long, fy As Long
    
    For ty = 0 To 39
        For tx = 0 To 15
            For y = 0 To 7
                For x = 0 To 7
                    Dim px As Long, py As Long, pixel As Long
                    px = tx * 8 + x
                    py = ty * 8 + y
                    fx = x
                    fy = tx * 8 + ty * 16 * 8
                    pixel = cTileset.GetPixel(px, py)
                    If pixel = -1 Then
                        picTilesData.PSet (x, fy + y), vbBlack
                        picTilesMask.PSet (x, fy + y), vbWhite
                        picTilesData.PSet (8 + 7 - x, fy + y), vbBlack
                        picTilesMask.PSet (8 + 7 - x, fy + y), vbWhite
                        picTilesData.PSet (16 + x, fy + 7 - y), vbBlack
                        picTilesMask.PSet (16 + x, fy + 7 - y), vbWhite
                        picTilesData.PSet (24 + 7 - x, fy + 7 - y), vbBlack
                        picTilesMask.PSet (24 + 7 - x, fy + 7 - y), vbWhite
                    Else
                        picTilesData.PSet (x, fy + y), pixel
                        picTilesMask.PSet (x, fy + y), vbBlack
                        picTilesData.PSet (8 + 7 - x, fy + y), pixel
                        picTilesMask.PSet (8 + 7 - x, fy + y), vbBlack
                        picTilesData.PSet (16 + x, fy + 7 - y), pixel
                        picTilesMask.PSet (16 + x, fy + 7 - y), vbBlack
                        picTilesData.PSet (24 + 7 - x, fy + 7 - y), pixel
                        picTilesMask.PSet (24 + 7 - x, fy + 7 - y), vbBlack
                        
                    End If
                Next
            Next
        Next
        frmLoader.SetProgress ty * 100 / 40
        DoEvents
    Next
    
    
    For ty = 0 To 7
        For tx = 0 To 15
            For y = 0 To 7
                For x = 0 To 7
                    
                    px = tx * 8 + x
                    py = ty * 8 + y
                    fx = x
                    fy = tx * 8 + ty * 16 * 8 + (40 * 16 * 8)
                    pixel = picSpTiles.Point(px, py)
                    If pixel = -1 Then
                        picTilesData.PSet (x, fy + y), vbBlack
                        picTilesMask.PSet (x, fy + y), vbWhite
                        picTilesData.PSet (8 + 7 - x, fy + y), vbBlack
                        picTilesMask.PSet (8 + 7 - x, fy + y), vbWhite
                        picTilesData.PSet (16 + x, fy + 7 - y), vbBlack
                        picTilesMask.PSet (16 + x, fy + 7 - y), vbWhite
                        picTilesData.PSet (24 + 7 - x, fy + 7 - y), vbBlack
                        picTilesMask.PSet (24 + 7 - x, fy + 7 - y), vbWhite
                    Else
                        picTilesData.PSet (x, fy + y), pixel
                        picTilesMask.PSet (x, fy + y), vbBlack
                        picTilesData.PSet (8 + 7 - x, fy + y), pixel
                        picTilesMask.PSet (8 + 7 - x, fy + y), vbBlack
                        picTilesData.PSet (16 + x, fy + 7 - y), pixel
                        picTilesMask.PSet (16 + x, fy + 7 - y), vbBlack
                        picTilesData.PSet (24 + 7 - x, fy + 7 - y), pixel
                        picTilesMask.PSet (24 + 7 - x, fy + 7 - y), vbBlack
                        
                    End If
                Next
            Next
        Next
       
    Next
    
'    Dim ms As Single
'    ms = Timer
'    frmLoader.ShowWindow "Preparing graphics... (PRE-FLIPPING TILES)"
'    For ty = 0 To 767
'        For y = 0 To 7
'            For x = 0 To 7
'                ' HF
'
'                picTilesData.PSet (8 + x, ty * 8 + y), picTilesData.Point(7 - x, ty * 8 + y)
'                picTilesMask.PSet (8 + x, ty * 8 + y), picTilesMask.Point(7 - x, ty * 8 + y)
'                ' VF
'  '              picTilesData.PSet (16 + X, ty * 8 + Y), picTilesData.Point(X, ty * 8 + 7 - Y)
'   '             picTilesMask.PSet (16 + X, ty * 8 + Y), picTilesMask.Point(X, ty * 8 + 7 - Y)
'                ' HF+VF
'    '            picTilesData.PSet (24 + X, ty * 8 + Y), picTilesData.Point(7 - X, ty * 8 + 7 - Y)
'     '           picTilesMask.PSet (24 + X, ty * 8 + Y), picTilesMask.Point(7 - X, ty * 8 + 7 - Y)
'
'            Next
'        Next
'        frmLoader.SetProgress ty * 100 / 768
'    Next
'    MsgBox Timer - ms

 '   For ty = 0 To 767
  '      For x = 0 To 7
   '         picTilesData.PaintPicture picTiles.Image, 8 + x, y * 8, 1, 8, 7 - x, y * 8, 1, 8
    '    Next
     '   frmLoader.SetProgress ty * 100 / 768
  '  Next
    
    
  '  picTilesData.Picture = picTilesData.Image
  '  picTilesMask.Picture = picTilesMask.Image
    
    picTiles_Paint
    
    Me.Enabled = True
    frmLoader.Hide
    DoEvents
End Sub

Private Sub PopulateThemes()

    Dim content As String
    Dim gl As String
    cbThemes.Clear
    
    Open App.Path & "\tilesets.txt" For Input As #1
    
        
    
        Do While Not EOF(1)
            Line Input #1, gl
            content = content & gl & "|"
        Loop
    Close #1
    
    Dim arr() As String
    arr = Split(content, "|")
    
    ReDim themesList(-1 To -1)
    
    Dim i As Integer
    For i = 0 To UBound(arr)
        If Not Trim(arr(i)) = "" Then
            Dim ub As Long
            ub = UBound(themesList)
            If ub = -1 Then
                ReDim themesList(0)
            Else
                ReDim Preserve themesList(ub + 1)
            End If
            themesList(UBound(themesList)) = Trim(arr(i))
            cbThemes.AddItem Mid$(themesList(UBound(themesList)), 1, InStr(themesList(UBound(themesList)), ".tileset") - 1)
        End If
    Next
    
    
    'LoadTileset 0
'
'
'    Dim str As String
'    str = Dir$(App.Path & "\*.theme.bmp")
'
'    Do Until str = ""
'        cbThemes.AddItem Mid$(str, 1, InStr(str, ".theme.bmp") - 1)
'        str = Dir$()
'    Loop
'    ''''''''''''''''''''''''''''''''''#########################################################################
'    LoadTileset App.Path & "\test.tileset"
End Sub

Private Sub SetBGcolor(ByVal c As Long)
    mapBGcolor = c
    'picBGprev.BackColor = c
    picEdit.BackColor = c
    picThumb.BackColor = c
    picTilePrev.BackColor = c
    DrawAllMain
    DrawAllSub
    picTilePrev_Paint
End Sub

Private Sub chkHFlip_Click()
    picTilePrev_Paint
End Sub

Private Sub chkSelMIsaligned_Click()
    If chkSelMIsaligned.Value = 1 Then
        MsgBox "warning: if the multiple tiles that are selected do not use the same palette then the image will not be previewed correctly."
    End If
End Sub

Private Sub chkShowDestruct_Click()
    DrawAllMain
    DrawAllSub
End Sub

Private Sub chkShowPassable_Click()
    DrawAllMain
    DrawAllSub
End Sub

Private Sub chkShowGrid_Click()
    DrawAllMain
End Sub

Private Sub chkShowLayer_Click(Index As Integer)
    DrawAllMain
    DrawAllSub
End Sub

Private Sub chkShowObjects_Click()
    DrawAllMain
End Sub

Private Sub chkShowSolid_Click()
    DrawAllMain
    DrawAllSub
End Sub

Private Sub chkTilesetGrid_Click()
    picTiles_Paint
End Sub

Private Sub chkVFlip_Click()
    picTilePrev_Paint
End Sub

Private Sub cmdAddLayer_Click()
    LAYERS(AL).AddLayer
    PopulateLayers
    lstLayers.SelectedItem = lstLayers.ListItems(lstLayers.ListItems.Count)
    
    LAYERS(AL).SetActiveLayer lstLayers.ListItems.Count - 1
End Sub

Private Sub PopulateLayers()

    lstLayers.ListItems.Clear
    Dim nlayers As Long
    nlayers = LAYERS(AL).GetNumLayers
    Dim i As Long
    For i = 0 To nlayers - 1
        
        
        lstLayers.ListItems.Add , "LAYER" & i, LAYERS(AL).GetLayerName(i)
        lstLayers.ListItems(i + 1).Checked = LAYERS(AL).LayerIsEnabled(i)
    Next
    
    If LAYERS(AL).GetNumLayers <> 0 Then
        LAYERS(AL).SetActiveLayer 0
    Else
        LAYERS(AL).SetActiveLayer -1
    End If
    
    DrawAllMain
    DrawAllSub
End Sub


Private Sub cmdGtweakDown_Click()
    LAYERS(0).ShiftDown
    LAYERS(1).ShiftDown
    OBJECTS.ShiftDown
    DrawAllMain
    DrawAllSub
End Sub

Private Sub cmdGtweakLeft_Click()
    LAYERS(0).ShiftLeft
    LAYERS(1).ShiftLeft
    OBJECTS.ShiftLeft
    DrawAllMain
    DrawAllSub
End Sub

Private Sub cmdGtweakRight_Click()
    LAYERS(0).ShiftRight
    LAYERS(1).ShiftRight
    OBJECTS.ShiftRight
    DrawAllMain
    DrawAllSub
End Sub

Private Sub cmdGtweakUp_Click()
    LAYERS(0).ShiftUp
    LAYERS(1).ShiftUp
    OBJECTS.ShiftUp
    DrawAllMain
    DrawAllSub
End Sub

Private Sub cmdLoadTiles_Click()
    LoadTileset cbThemes.ListIndex
End Sub

Private Sub Command1_Click()
    If lstLayers.ListItems.Count <> 0 Then
        LAYERS(AL).DeleteLayer lstLayers.SelectedItem.Index - 1
        PopulateLayers
    End If
End Sub

Private Sub Command3_Click()
    If lstLayers.ListItems.Count <> 0 Then
        Dim i As Long
        i = lstLayers.SelectedItem.Index - 1
        If i <> 0 Then
            LAYERS(AL).MoveLayerUp lstLayers.SelectedItem.Index - 1
            PopulateLayers
            LAYERS(AL).SetActiveLayer i - 1
            
            lstLayers.SelectedItem = lstLayers.ListItems(i)
        End If
    End If
End Sub

Private Sub Command4_Click()
    If lstLayers.ListItems.Count <> 0 Then
        Dim i As Long
        i = lstLayers.SelectedItem.Index - 1
        If i <> lstLayers.ListItems.Count - 1 Then
            
            LAYERS(AL).MoveLayerDown lstLayers.SelectedItem.Index - 1
            PopulateLayers
            LAYERS(AL).SetActiveLayer i + 1
            
            lstLayers.SelectedItem = lstLayers.ListItems(i + 2)
            
        End If
    End If
End Sub

Private Sub Command5_Click()
    On Error GoTo errhand
    cd.color = tilesetBGcolor
    cd.Flags = cdlCCRGBInit
    cd.ShowColor
    tilesetBGcolor = cd.color
    picTiles_Paint
errhand:
End Sub

Private Sub Command6_Click()
    On Error GoTo 1
    cd.color = mapBGcolor
    cd.Flags = cdlCCRGBInit
    cd.ShowColor
    SetBGcolor cd.color
1
End Sub

Private Sub Command7_Click()
    frmProps.Show
End Sub

Private Sub Form_Load()
    
    STR_DIRECTIONS(0) = "LEFT"
    STR_DIRECTIONS(1) = "UP"
    STR_DIRECTIONS(2) = "RIGHT"
    STR_DIRECTIONS(3) = "DOWN"
    PopulateObjects

    tilesetBGcolor = RGB(32, 180, 240)

    mapBoundX = 64
    mapBoundY = 32

    PopulateThemes
    ResizeThumb 1 / 2
    SetBGcolor RGB(0, 192, 192)
    
    
    LAYERS(0).AddLayer
    LAYERS(1).AddLayer
    AL = 0
    PopulateLayers
End Sub

Private Sub UpdateCaption()
    If current_filename <> "" Then
        frmMain.Caption = "LEVEL EDITOR - " & Mid$(current_filename, InStrRev(current_filename, "\") + 1)
    Else
        frmMain.Caption = "LEVEL EDITOR - untitled"
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
    End
End Sub

Private Sub lstLayers_AfterLabelEdit(Cancel As Integer, NewString As String)
    LAYERS(AL).SetLayerName lstLayers.SelectedItem.Index - 1, NewString
End Sub

Private Sub lstLayers_ItemCheck(ByVal Item As MSComctlLib.ListItem)
    If Item.Checked Then
        LAYERS(AL).EnableLayer Item.Index - 1
    Else
        LAYERS(AL).DisableLayer Item.Index - 1
    End If
    DrawAllMain
    DrawAllSub
End Sub

Private Sub lstLayers_ItemClick(ByVal Item As MSComctlLib.ListItem)
    LAYERS(AL).SetActiveLayer Item.Index - 1
End Sub

Private Sub lstObjects_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    paintMode = PM_OBJ
    Shape1.FillColor = vbRed
    chkShowObjects.Value = 1
End Sub

Private Sub mnuFileExport_Click()
    'On Local Error GoTo cancelPressed
    cd.Filter = "LEVEL FILE|*.level"
    cd.Flags = cdlOFNOverwritePrompt
    cd.ShowSave
    ExportLevel cd.filename
    
cancelPressed:
End Sub

Private Sub mnuFileLoad_Click()
    On Local Error GoTo cancelPressed
    cd.Filter = "MAP files|*.map"
    cd.Flags = 0
    cd.ShowOpen
    
    
    ' open file
    LoadFromFile cd.filename
    
    current_filename = cd.filename
    UpdateCaption
    
    Exit Sub
cancelPressed:
    If Err.Number <> 32755 Then
        Debug.Print "butts"
    End If
    
End Sub

Private Sub mnuFileSave_Click()
    If current_filename <> "" Then
        ' save file
        
        SaveToFile current_filename
    Else
        mnuFileSaveAs_Click
    End If
End Sub

Private Sub mnuFileSaveAs_Click()
    On Local Error GoTo cancelPressed
    cd.Filter = "MAP files|*.map"
    cd.Flags = cdlOFNOverwritePrompt
    cd.ShowSave
    
    ' save file
    SaveToFile cd.filename
    
    current_filename = cd.filename
    UpdateCaption
    
cancelPressed:

End Sub

Private Sub mnuHelpAbout_Click()
    MsgBox "This is a level editor.", vbInformation, "About Level Editor"
End Sub

Private Sub mnuHelpHALP_Click()
    MsgBox "Call your mommy for help.", vbInformation, "Getting Help"
End Sub

Private Sub mnuQUIT_Click()
    End
End Sub

Private Sub Option1_Click()
    ResizeThumb 1 / 8
    DrawAllSub
End Sub

Private Sub Option2_Click()
    ResizeThumb 1 / 4
    DrawAllSub
End Sub

Private Sub Option3_Click()
    ResizeThumb 1 / 2
    DrawAllSub
End Sub

Private Sub Option4_Click()
    ResizeThumb 1
    DrawAllSub
End Sub

Private Sub ResizeThumb(ByVal cscale As Double)
    thumbScale = cscale
    picThumb.Width = 1024 * thumbScale
    picThumb.Height = 512 * thumbScale
    picThumb.Left = (picSubViewport.Width - picThumb.Width) / 2
    picThumb.Top = (picSubViewport.Height - picThumb.Height) / 2
End Sub

Private Sub DoErase(ByVal x As Long, ByVal y As Long)
    Dim tx As Long, ty As Long
    tx = x \ 16
    ty = y \ 16
    If tx < 0 Or ty < 0 Or tx >= MAPWIDTH Or ty >= MAPHEIGHT Then
        Exit Sub
    End If
    
 '   If Not bPaint Then
        bPaint = True
  '  Else
   '     If paintX = tx And paintY = ty Then
    '        Exit Sub
     '   End If
    'End If
    
'    paintX = tx
 '   paintY = ty
    
    Dim t As TileMapEntry
    t.tile = -1
    t.hflip = False
    t.vflip = False
    t.solid = -1
    t.destruct = -1
    Dim m As BRUSH_MASK
    m = BRUSH_TILE Or BRUSH_SOLID Or BRUSH_DESTRUCT
    
    
    LAYERS(AL).Paint tx, ty, t, m
    
    
    If chkThumbActive Then
        DrawAllSub
    End If
    
    DrawPatch tx, ty
End Sub


Private Sub DoPaint(ByVal x As Long, ByVal y As Long)
    
    
    Dim tx As Long, ty As Long
    tx = x \ 16
    ty = y \ 16
    If tx < 0 Or ty < 0 Or tx >= MAPWIDTH Or ty >= MAPHEIGHT Then
        Exit Sub
    End If
    
 '   If Not bPaint Then
        bPaint = True
  '  Else
 '       If paintX = tx And paintY = ty Then
  '          Exit Sub
   '     End If
    'End If
    
'    paintX = tx
 '   paintY = ty
    
    
    Dim t As TileMapEntry
    t.tile = drawSel
    t.hflip = chkHFlip
    t.vflip = chkVFlip
    t.solid = chkSolid
    t.matter = 0
    t.destruct = chkPaintDestruct
    Dim m As BRUSH_MASK
    If chkTileMask.Value = 1 Then
        m = BRUSH_TILE
    End If
    
    If chkSolidMask.Value = 1 Then
        m = m Or BRUSH_SOLID
    End If
    
    If chkMaskDestruct.Value = 1 Then
        m = m Or BRUSH_DESTRUCT
    End If
    
    LAYERS(AL).Paint tx, ty, t, m

    
    DrawPatch tx, ty
    picEdit.Line (tx * 16, ty * 16)-(tx * 16 + 15, ty * 16 + 15), vbRed, B
    
    If chkThumbActive Then
        DrawAllSub
    End If
End Sub

Private Sub optLayer_Click(Index As Integer)
    AL = Index
    PopulateLayers
End Sub

Private Sub optOBJdir_Click(Index As Integer)
    paintOBJdir = Index
End Sub

Private Sub picEdit_GotFocus()
    shpEdit.Visible = True
End Sub

Private Sub picEdit_KeyDown(KeyCode As Integer, Shift As Integer)
    Select Case KeyCode
        Case vbKeyH
            chkHFlip.Value = 1 - chkHFlip.Value
        Case vbKeyV
            chkVFlip.Value = 1 - chkVFlip.Value
        Case vbKeyS
            chkSolid.Value = 1 - chkSolid.Value
        Case vbKeyD
            chkPaintDestruct.Value = 1 - chkPaintDestruct.Value
        Case vbKeyF
            FlipSelection
    End Select
End Sub

Private Sub picEdit_LostFocus()
    shpEdit.Visible = False
End Sub

Private Sub DoEraseObject(ByVal x As Long, ByVal y As Long)
    Dim px As Long, py As Long
    If x < 0 Or y < 0 Or x >= MAPWIDTH * 16 Or y >= MAPHEIGHT * 16 Then Exit Sub
    px = x \ 16
    py = y \ 16
    
    Dim test As Integer
    test = OBJECTS.TestForObject(px, py)
    
    If test <> -1 Then
        OBJECTS.RemoveObject test
    Else
        'MsgBox "Erase: error, no object present.", vbInformation
    End If
    
    UpdateObjectInfo px, py
    DrawAllMain
End Sub

Private Sub DoPaintObject(ByVal x As Long, ByVal y As Long)
    Dim px As Long, py As Long
    If x < 0 Or y < 0 Or x >= MAPWIDTH * 16 Or y >= MAPHEIGHT * 16 Then Exit Sub
    px = x \ 16
    py = y \ 16
    
    Dim test As Integer
    test = OBJECTS.TestForObject(px, py)
    
    If test <> -1 Then
        OBJECTS.RemoveObject test
    End If
    
    Dim obj As SingleObject
    Set obj = OBJECTS.AddObject(px, py, lstObjects.ListIndex, paintOBJdir)
   ' On Error GoTo 1
    obj.attr1 = CInt(txtOBJattr(0).Text)
    obj.attr2 = CInt(txtOBJattr(1).Text)
    obj.attr3 = CInt(txtOBJattr(2).Text)
    obj.attr4 = CInt(txtOBJattr(3).Text)
1
    
    UpdateObjectInfo px, py
    DrawAllMain
End Sub

Private Sub picEdit_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then
        bDragMain = True
        dragMainX = x + picEdit.Left
        dragMainY = y + picEdit.Top
    ElseIf Button = 1 Then
        
        
        If paintMode = PM_BG Then
            If Shift And vbShiftMask Then
                DoErase x, y
            Else
                DoPaint x, y
            End If
        Else
            If Shift And vbShiftMask Then
                DoEraseObject x, y
            Else
                DoPaintObject x, y
            End If
        End If
    End If
End Sub

Private Sub UpdateObjectInfo(ByVal x As Long, ByVal y As Long)
    Dim obj As SingleObject
    Dim obji As Integer
    obji = OBJECTS.TestForObject(x, y)
    If obji <> -1 Then
        Set obj = OBJECTS.GetObject(obji)
        lblOBJtype.Caption = "TYPE: " & ObjectNames(obj.typ)
        lblOBJdir.Caption = "DIR: " & STR_DIRECTIONS(obj.direction)
        lblATTR.Caption = "A: " & obj.attr1 & ", " & obj.attr2 & ", " & obj.attr3 & ", " & obj.attr4
    End If
End Sub

Private Sub picEdit_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    Dim tx As Long, ty As Long
    tx = x \ 16
    ty = y \ 16
    If paintX <> tx Or paintY <> ty Then
        DrawPatch paintX, paintY
        paintX = tx
        paintY = ty
        
        If paintMode = PM_BG Then
            If Not Shift And vbShiftMask Then
                DrawTileMain tx, ty, drawSel, chkHFlip.Value = 1, chkVFlip.Value = 1, False, False
            'Else
            '    DrawTileMain tx, ty, 0, False, False
            End If
        End If
        picEdit.Line (tx * 16, ty * 16)-(tx * 16 + 15, ty * 16 + 15), vbRed, B
        lblXY.Caption = "X: " & tx & ", Y: " & ty
        
        UpdateObjectInfo tx, ty
        
        If bPaint And paintMode = PM_BG Then
            picEdit_MouseDown Button, Shift, x, y
        End If
    End If
    
    If bDragMain Then
        Dim px As Long, py As Long
        px = x + picEdit.Left
        py = y + picEdit.Top
        
        picEdit.Move picEdit.Left + px - dragMainX, picEdit.Top + py - dragMainY
        dragMainX = px
        dragMainY = py
        'picEdit.Left = picEdit.Left + (X - dragMainX)
        'picEdit.Top = picEdit.Top + (Y - dragMainY)
        If picEdit.Left < picMainViewport.ScaleWidth - picEdit.Width - 64 Then
            picEdit.Left = picMainViewport.ScaleWidth - picEdit.Width - 64
        End If
        If picEdit.Left > 64 Then
            picEdit.Left = 64
        End If
        
        If picEdit.Top < picMainViewport.ScaleHeight - picEdit.Height - 64 Then
            picEdit.Top = picMainViewport.ScaleHeight - picEdit.Height - 64
        End If
        If picEdit.Top > 64 Then
            picEdit.Top = 64
        End If
        
    ElseIf bPaint Then
        
        
    End If
'    shpCursor.Left = (x \ 32) * 32
 '   shpCursor.Top = (y \ 32) * 32
End Sub

Private Sub picEdit_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    bDragMain = False
    bPaint = False
    DrawAllSub
End Sub

Private Sub picEdit_Paint()
    DrawAllMain
End Sub

Private Sub picThumb_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    If picThumb.Width > picSubViewport.ScaleWidth - 128 Then
        bDragThumb = True
        dragThumbX = x + picThumb.Left
        dragThumbY = y + picThumb.Top
    End If
End Sub

Private Sub picThumb_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    If bDragThumb Then
        Dim px As Long, py As Long
        px = x + picThumb.Left
        py = y + picThumb.Top
        
        picThumb.Move picThumb.Left + px - dragThumbX, picThumb.Top + py - dragThumbY
        dragThumbX = px
        dragThumbY = py
        'picEdit.Left = picEdit.Left + (X - dragMainX)
        'picEdit.Top = picEdit.Top + (Y - dragMainY)
        
        If picThumb.Left > 64 Then
            picThumb.Left = 64
        ElseIf picThumb.Left < picSubViewport.ScaleWidth - picThumb.Width - 64 Then
            picThumb.Left = picSubViewport.ScaleWidth - picThumb.Width - 64
        End If
        
        If picThumb.Top > 64 Then
            picThumb.Top = 64
        ElseIf picThumb.Top < picSubViewport.ScaleHeight - picThumb.Height - 64 Then
            picThumb.Top = picSubViewport.ScaleHeight - picThumb.Height - 64
        End If
    End If
End Sub

Private Sub picThumb_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    bDragThumb = False
End Sub

Private Sub picThumb_Paint()
    DrawAllSub
End Sub

Private Sub picTilePrev_Paint()
    picTilePrev.Cls
    
    Const tw As Long = 16
    
    Dim xoff As Long
    Dim hfx As Long
    Dim vfx As Long
    If chkHFlip.Value = 1 Then
        xoff = xoff Or 1
        hfx = tw
    End If
    If chkVFlip.Value = 1 Then
        xoff = xoff Or 2
        vfx = tw
    End If
    xoff = xoff * 8
    
    StretchBlt picTilePrev.hdc, hfx, vfx, tw, tw, picTilesMask.hdc, xoff, drawSel * 8, 8, 8, vbSrcAnd
    StretchBlt picTilePrev.hdc, hfx, vfx, tw, tw, picTilesData.hdc, xoff, drawSel * 8, 8, 8, vbSrcPaint
    
    StretchBlt picTilePrev.hdc, hfx Xor tw, vfx, tw, tw, picTilesMask.hdc, xoff, (drawSel + 1) * 8, 8, 8, vbSrcAnd
    StretchBlt picTilePrev.hdc, hfx Xor tw, vfx, tw, tw, picTilesData.hdc, xoff, (drawSel + 1) * 8, 8, 8, vbSrcPaint
    
    StretchBlt picTilePrev.hdc, hfx, vfx Xor tw, tw, tw, picTilesMask.hdc, xoff, (drawSel + 16) * 8, 8, 8, vbSrcAnd
    StretchBlt picTilePrev.hdc, hfx, vfx Xor tw, tw, tw, picTilesData.hdc, xoff, (drawSel + 16) * 8, 8, 8, vbSrcPaint
    
    StretchBlt picTilePrev.hdc, hfx Xor tw, vfx Xor tw, tw, tw, picTilesMask.hdc, xoff, (drawSel + 17) * 8, 8, 8, vbSrcAnd
    StretchBlt picTilePrev.hdc, hfx Xor tw, vfx Xor tw, tw, tw, picTilesData.hdc, xoff, (drawSel + 17) * 8, 8, 8, vbSrcPaint
End Sub

Private Sub FlipSelection()
    SelectTile prevSel
End Sub

Private Sub DrawTileSelection()
    Dim gx As Long, gy As Long
    gx = (drawSel Mod 16) * 16
    gy = (drawSel \ 16) * 16
    picTiles.FillStyle = 1
    picTiles.Line (gx, gy)-(gx + 31, gy + 31), vbRed, B
End Sub

Private Sub SelectTile(ByVal Index As Long)
    If Index = drawSel Then
        ' skip if index is the same
        Exit Sub
    End If
    
    prevSel = drawSel
    drawSel = Index
    
    RenderTilesetCell prevSel
    RenderTilesetCell prevSel + 1
    RenderTilesetCell prevSel + 16
    RenderTilesetCell prevSel + 17
    
    'lblTileIndex.Caption = "INDEX: " & drawSel
    picTilePrev_Paint
    
    DrawTileSelection
End Sub

Private Sub picTiles_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    If Shift = 0 And Button = 1 Then
    
        Dim px As Long, py As Long
        Shape1.FillColor = vbBlack
        paintMode = PM_BG
        px = x
        py = y
        If px < 0 Then px = 0
        If px > 255 Then px = 255
        If py < 0 Then py = 0
        If py > 767 Then py = 767
        Dim tile As Long
        
        If chkSelMIsaligned.Value = 0 Then
            tile = (px \ 32) * 2 + (py \ 32) * 32
        Else
            If px < 8 Then px = 8
            If py < 8 Then py = 8
            tile = ((px - 8) \ 16) + ((py - 8) \ 16) * 16
        End If
        
        SelectTile tile
        
        
    End If
End Sub

Private Sub picTiles_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 1 Then
        picTiles_MouseDown Button, Shift, x, y
    End If
End Sub

Private Sub RenderTilesetCell(ByVal tile As Long)
    Dim x As Long, y As Long
    x = (tile Mod 16) * 16
    y = (tile \ 16) * 16
    picTiles.FillStyle = 0
    picTiles.FillColor = picTiles.BackColor
    picTiles.Line (x, y)-(x + 15, y + 15), picTiles.FillColor, B
    tile = tile * 8
    StretchBlt picTiles.hdc, x, y, 16, 16, picTilesMask.hdc, 0, tile, 8, 8, vbSrcAnd
    StretchBlt picTiles.hdc, x, y, 16, 16, picTilesData.hdc, 0, tile, 8, 8, vbSrcPaint
End Sub

Private Sub picTiles_Paint()
    picTiles.Cls
    picTiles.BackColor = tilesetBGcolor
    
    Dim x As Long, y As Long
    
    For x = 0 To 767
        RenderTilesetCell x
    Next
    'For x = 0 To 15
     '   For y = 0 To 47
      '      StretchBlt picTiles.hdc, x * 16, y * 16, 16, 16, picTilesMask.hdc, 0, (x + y * 16) * 8, 8, 8, vbSrcAnd
       '     StretchBlt picTiles.hdc, x * 16, y * 16, 16, 16, picTilesData.hdc, 0, (x + y * 16) * 8, 8, 8, vbSrcPaint
'        Next
 '   Next
    
    If chkTilesetGrid.Value = 1 Then
        Dim gx As Long, gy As Long
        For gx = 0 To 7
            picTiles.Line (gx * 32, 0)-(gx * 32, 768), vbWhite
        Next
        For gy = 0 To 23
            picTiles.Line (0, gy * 32)-(256, gy * 32), vbWhite
        Next
    End If
    
    DrawTileSelection
    
End Sub

Private Sub Text1_Change()

End Sub

Private Sub tilebgB_Click()
    tilebgR_Change
End Sub

Private Sub tilebgG_Click()
    tilebgR_Change
End Sub

Private Sub tilebgR_Change()
    picTiles_Paint
End Sub

Private Sub txtBGb_Change()
    txtBGr_Change
End Sub

Private Sub txtBGg_Change()
    txtBGr_Change
End Sub

Private Sub txtBGr_Change()
'    On Error GoTo 1
'    SetBGcolor txtBGr, txtBGg, txtBGb
'1
End Sub

'****************************************************************************
'
' drawing functions
'
'****************************************************************************

Public Sub DrawTileMain(ByVal x As Long, ByVal y As Long, ByVal t As Long, ByVal hf As Boolean, ByVal vf As Boolean, ByVal solid As Boolean, ByVal destruct As Boolean)

    ' main screen
    t = t * 8
    x = x * 16
    y = y * 16
    
    Dim hfx As Long
    Dim vfx As Long
    Dim xo As Long
    If hf Then
        hfx = 8
        xo = 8
    End If
    If vf Then
        vfx = 8
        xo = xo Or 16
    End If
    
    BitBlt picEdit.hdc, x Xor hfx, y Xor vfx, 8, 8, picTilesMask.hdc, xo, t, vbSrcAnd
    BitBlt picEdit.hdc, x Xor hfx, y Xor vfx, 8, 8, picTilesData.hdc, xo, t, vbSrcPaint
    
    BitBlt picEdit.hdc, (x Or 8) Xor hfx, y Xor vfx, 8, 8, picTilesMask.hdc, xo, t + 8, vbSrcAnd
    BitBlt picEdit.hdc, (x Or 8) Xor hfx, y Xor vfx, 8, 8, picTilesData.hdc, xo, t + 8, vbSrcPaint
    
    BitBlt picEdit.hdc, x Xor hfx, (y Or 8) Xor vfx, 8, 8, picTilesMask.hdc, xo, t + 128, vbSrcAnd
    BitBlt picEdit.hdc, x Xor hfx, (y Or 8) Xor vfx, 8, 8, picTilesData.hdc, xo, t + 128, vbSrcPaint
    
    BitBlt picEdit.hdc, (x Or 8) Xor hfx, (y Or 8) Xor vfx, 8, 8, picTilesMask.hdc, xo, t + 136, vbSrcAnd
    BitBlt picEdit.hdc, (x Or 8) Xor hfx, (y Or 8) Xor vfx, 8, 8, picTilesData.hdc, xo, t + 136, vbSrcPaint
    
    If solid Then
        BitBlt picEdit.hdc, x, y, 16, 16, picDongles.hdc, 0, 16, vbSrcAnd
        BitBlt picEdit.hdc, x, y, 16, 16, picDongles.hdc, 0, 0, vbSrcPaint
    End If
    
    If destruct Then
        BitBlt picEdit.hdc, x, y, 16, 16, picDongles.hdc, 16, 16, vbSrcAnd
        BitBlt picEdit.hdc, x, y, 16, 16, picDongles.hdc, 16, 0, vbSrcPaint
    End If
End Sub

Public Sub DrawTileSub(ByVal x As Long, ByVal y As Long, ByVal t As Long, ByVal hf As Boolean, ByVal vf As Boolean, ByVal solid As Boolean, ByVal destruct As Boolean, ByVal cs As Long)

    Dim offset As Long
    offset = (16 - cs) / 2 - 4
    x = x * cs
    y = y * cs
    t = t * 8
    
    BitBlt picThumb.hdc, x, y, cs, cs, picTilesMask.hdc, offset, t + offset, vbSrcAnd
    BitBlt picThumb.hdc, x, y, cs, cs, picTilesData.hdc, offset, t + offset, vbSrcPaint
    
    If solid Then
        BitBlt picThumb.hdc, x, y, cs, cs, picDongles.hdc, 0, 16, vbSrcAnd
        BitBlt picThumb.hdc, x, y, cs, cs, picDongles.hdc, 0, 0, vbSrcPaint
    End If
    
    If destruct Then
        BitBlt picThumb.hdc, x, y, cs, cs, picDongles.hdc, 32, 0, vbSrcCopy
    End If
End Sub

Public Sub DrawPatch(ByVal x As Long, ByVal y As Long)
    If x < 0 Or y < 0 Or x >= MAPWIDTH Or y >= MAPHEIGHT Then
        Exit Sub
    End If
    Dim t As TileMapEntry
    picEdit.FillStyle = 0
    picEdit.FillColor = picEdit.BackColor
    picEdit.Line (x * 16, y * 16)-(x * 16 + 15, y * 16 + 15), picEdit.BackColor, B
    
    Dim layer As Long
    For layer = 0 To 1
        If chkShowLayer(layer) Then
            t = LAYERS(layer).GetTile(x, y)
            
            If chkShowSolid.Value = 0 Then
                t.solid = 0
            End If
            If chkShowDestruct.Value = 0 Then
                t.destruct = 0
            End If
            
            If t.tile <> 0 Then
                DrawTileMain x, y, t.tile, t.hflip, t.vflip, t.solid, t.destruct
            End If
        End If
        
    Next
    
    If chkShowGrid Then
        picEdit.Line (x * 16, y * 16)-(x * 16 + 16, y * 16), vbBlack
        picEdit.Line (x * 16, y * 16)-(x * 16, y * 16 + 16), vbBlack
    End If
    
    If x = mapBoundX Then
        picEdit.Line (x * 16, y * 16)-(x * 16, y * 16 + 16), vbRed
    End If
    If y = mapBoundY Then
        picEdit.Line (x * 16, y * 16)-(x * 16 + 16, y * 16), vbRed
    End If
    
    picEdit.FillStyle = 1
    
    DrawAllObjects
End Sub

Public Sub DrawObjectDirection(ByVal x As Long, ByVal y As Long, ByVal d As Long)
    Select Case d
    Case 0 'left
        picEdit.Line (x, y)-(x - 8, y)
    Case 1 'up
        picEdit.Line (x, y)-(x, y - 8)
    Case 2 'right
        picEdit.Line (x, y)-(x + 8, y)
    Case 3 'down
        picEdit.Line (x, y)-(x, y + 8)
    End Select
End Sub

Public Sub DrawObjectData(obj As SingleObject, offset As Long)
    
    Dim lx As Long, ly As Long
    With obj
        lx = .x * 16 + 8 + offset
        ly = .y * 16 + 8 + offset
        picEdit.Circle (lx, ly), 4
        DrawObjectDirection lx, ly, .direction
        lx = lx + 3
        ly = ly + 3
        picEdit.Line (lx, ly)-(lx + 8, ly + 8)
        lx = lx + 8
        ly = ly + 8
        picEdit.Line (lx, ly)-(lx + 15, ly)
        lx = lx + 15
        picEdit.CurrentX = lx + 2
        picEdit.CurrentY = ly - 3
        
        picEdit.Print ObjectNames(.typ)
    End With
End Sub

Public Sub DrawAllObjects()
    If chkShowObjects Then
        Dim i As Integer
        Dim obj As SingleObject
        
        For i = 0 To OBJECTS.Count - 1
            Set obj = OBJECTS.GetObject(i)
            picEdit.ForeColor = vbBlack
            DrawObjectData obj, 1
            picEdit.ForeColor = vbWhite
            DrawObjectData obj, 0
        Next
    End If
End Sub

Public Sub DrawAllMain()
    Dim x As Long
    Dim y As Long
    Dim t As TileMapEntry
    Dim t2 As TileMapEntry
    picEdit.Cls
    
    Dim xf As Long
    Dim yf As Long
    Dim xt As Long
    Dim yt As Long
    xf = Clamp(-picEdit.Left \ 16, 0, MAPWIDTH - 1)
    yf = Clamp(-picEdit.Top \ 16, 0, MAPHEIGHT - 1)
    xt = Clamp(-(picEdit.Left - picMainViewport.ScaleWidth) \ 16, 0, MAPWIDTH - 1)
    yt = Clamp(-(picEdit.Top - picMainViewport.ScaleHeight) \ 16, 0, MAPHEIGHT - 1)
    
    Dim layer As Long
    For layer = 0 To 1
        If chkShowLayer(layer) Then
            For x = xf To xt
                For y = yf To yt
                    t = LAYERS(layer).GetTile(x, y)
                    If chkShowSolid.Value = 0 Then
                        t.solid = 0
                    End If
                    If chkShowDestruct.Value = 0 Then
                        t.destruct = 0
                    End If
                    If t.tile <> 0 Then
                        DrawTileMain x, y, t.tile, t.hflip, t.vflip, t.solid, t.destruct
                    End If
                Next
            Next
        End If
    Next
    
    If chkShowGrid Then
        For x = xf To xt
            picEdit.Line (x * 16, 0)-(x * 16, MAPHEIGHT * 16), vbBlack
        Next
        
        For y = yf To yt
            picEdit.Line (0, y * 16)-(MAPWIDTH * 16, y * 16), vbBlack
        Next
    End If
    
    picEdit.Line (mapBoundX * 16, 0)-(mapBoundX * 16, MAPHEIGHT * 16), vbRed
    picEdit.Line (0, mapBoundY * 16)-(MAPWIDTH * 16, mapBoundY * 16), vbRed
    
    
    If chkShowObjects Then
        DrawAllObjects
    End If
    
End Sub

Public Sub DrawAllSub()
    Dim x As Long
    Dim y As Long
    Dim t As TileMapEntry
    picThumb.Cls

    Dim xf As Long
    Dim yf As Long
    Dim xt As Long
    Dim yt As Long
    
    Dim cs As Double
    cs = thumbScale * 16
    xf = Clamp(-picThumb.Left \ cs, 0, MAPWIDTH - 1)
    yf = Clamp(-picThumb.Top \ cs, 0, MAPHEIGHT - 1)
    xt = Clamp(-(picThumb.Left - picSubViewport.ScaleWidth) \ cs, 0, MAPWIDTH - 1)
    yt = Clamp(-(picThumb.Top - picSubViewport.ScaleHeight) \ cs, 0, MAPHEIGHT - 1)
    
    Dim layer As Long
    For layer = 0 To 1
        If chkShowLayer(layer) Then
            
            For x = xf To xt
                For y = yf To yt
                    t = LAYERS(layer).GetTile(x, y)
                    
                    If chkShowSolid.Value = 0 Then
                        t.solid = False
                    End If
                    
                    If chkShowDestruct.Value = 0 Then
                        t.destruct = False
                    End If
                    
                    If t.tile <> 0 Then
                        DrawTileSub x, y, t.tile, t.hflip, t.vflip, t.solid, t.destruct, cs
                    End If
                Next
            Next
        End If
    Next
    
    picThumb.Line (mapBoundX * cs, 0)-(mapBoundX * cs, MAPHEIGHT * cs), vbRed
    picThumb.Line (0, mapBoundY * cs)-(MAPWIDTH * cs, mapBoundY * cs), vbRed
    
End Sub

Private Sub txtMapBoundX_Change()
    On Error GoTo errhand
    Dim i As Integer
    i = txtMapBoundX.Text
    If i < 1 Then i = 1
    If i > 64 Then i = 64
    txtMapBoundX.Text = i
    mapBoundX = i
    DrawAllMain
    DrawAllSub
errhand:
End Sub

Private Sub txtMapBoundY_Change()
    On Error GoTo errhand
    Dim i As Integer
    i = txtMapBoundY.Text
    If i < 1 Then i = 1
    If i > 32 Then i = 32
    txtMapBoundY.Text = i
    mapBoundY = i
    DrawAllMain
    DrawAllSub
errhand:
End Sub


'
'
' SAVING/LOADING
''
'
'

Private Sub SaveToFile(filename As String)
    Open filename For Binary As #1
    Put #1, , mapBoundX
    Put #1, , mapBoundY
    Dim lon As Long
    lon = 0
    Put #1, , CurTheme
    Put #1, , lon ' music specification
    Put #1, , lon ' theme specification
    Put #1, , mapBGcolor
    Put #1, , tilesetBGcolor
    
    LAYERS(0).WriteToFile 1
    LAYERS(1).WriteToFile 1
    OBJECTS.WriteToFile 1
    
    
    ' todo: custom tiles
    Close #1
End Sub

Private Sub LoadFromFile(filename As String)
    Open filename For Binary As #1
    
    
    Get #1, , mapBoundX
    Get #1, , mapBoundY
    Dim lon As Long
    Get #1, , CurTheme
    Get #1, , lon 'music
    Get #1, , lon 'theme
    Get #1, , mapBGcolor
    Get #1, , tilesetBGcolor
    
    SetBGcolor mapBGcolor
    picTiles_Paint
    
    LAYERS(0).ReadFromFile 1
    LAYERS(1).ReadFromFile 1
    OBJECTS.ReadFromFile 1
    
    LoadTileset CurTheme
    
    'todo custom tiles
    DrawAllMain
    DrawAllSub
    picTilePrev_Paint
    PopulateLayers
    
    Close #1
End Sub

Private Sub ExportLevel(file As String)
    Open file For Binary As #1
        LAYERS(0).WriteBGmap 1, False, cTileset
        LAYERS(1).WriteBGmap 1, True, cTileset
        Dim x As Long, y As Long, z As Long, outp As Byte, t As TileMapEntry, t2 As TileMapEntry
        For y = 0 To 31
            For x = 0 To 63
                t = LAYERS(0).GetTile(x, y)
                t2 = LAYERS(1).GetTile(x, y)
                If (t.solid = 1 And t.tile <> 0) Or (t2.solid = 1 And t2.tile <> 0) Then
                    outp = 128
                Else
                    outp = 0
                End If
                
                Put #1, , outp
            Next
        Next
        
        For z = 0 To 1
            For y = 0 To 31
                For x = 0 To 63
                    t = LAYERS(z).GetTile(x, y)
                    outp = t.destruct
                    If t.tile = 0 Then
                        outp = 0
                    End If
                    Put #1, , outp
                Next
            Next
        Next
        
        'sliding
        For y = 0 To 31
            For x = 0 To 63
                t = LAYERS(0).GetTile(x, y)
                outp = 0
                If t.tile = 640 Then
                    If t.hflip Then
                        outp = 3
                    Else
                        outp = 1
                    End If
                ElseIf t.tile = 642 Then
                    If t.vflip Then
                        outp = 4
                    Else
                        outp = 2
                    End If
                End If
                
                t = LAYERS(1).GetTile(x, y)
                
                If t.tile = 640 Then
                    If t.hflip Then
                        outp = 3
                    Else
                        outp = 1
                    End If
                ElseIf t.tile = 642 Then
                    If t.vflip Then
                        outp = 4
                    Else
                        outp = 2
                    End If
                End If
                
                
                Put #1, , outp
            Next
        Next
        
        outp = mapBoundX
        Put #1, , outp
        outp = mapBoundY
        Put #1, , outp
        outp = CurTheme
        Put #1, , outp
        
        outp = Color24_to_16(mapBGcolor) And 255
        Put #1, , outp
        outp = Color24_to_16(mapBGcolor) \ 256
        Put #1, , outp
        
        
        For x = 0 To OBJECTS.Count
            OBJECTS.Export 1
        Next
        
    Close #1
End Sub
