VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Tileset converter"
   ClientHeight    =   5355
   ClientLeft      =   45
   ClientTop       =   360
   ClientWidth     =   7905
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   357
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   527
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox chkEditor 
      Caption         =   "editor version"
      Height          =   375
      Left            =   2160
      TabIndex        =   10
      Top             =   2760
      Width           =   1455
   End
   Begin VB.PictureBox picdbg 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   4875
      Left            =   4680
      ScaleHeight     =   325
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   128
      TabIndex        =   9
      Top             =   120
      Visible         =   0   'False
      Width           =   1920
   End
   Begin VB.TextBox txtOutput 
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
      Height          =   4455
      Left            =   4200
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   8
      Top             =   120
      Width           =   3615
   End
   Begin VB.CommandButton Command4 
      Caption         =   "save"
      Height          =   375
      Left            =   2160
      TabIndex        =   7
      Top             =   2280
      Width           =   1935
   End
   Begin VB.CommandButton Command3 
      Caption         =   "load palette"
      Height          =   375
      Left            =   2160
      TabIndex        =   6
      Top             =   1320
      Width           =   1935
   End
   Begin MSComctlLib.ProgressBar pb 
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   5040
      Width           =   7695
      _ExtentX        =   13573
      _ExtentY        =   450
      _Version        =   393216
      BorderStyle     =   1
      Appearance      =   0
   End
   Begin VB.PictureBox picPalette 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      ForeColor       =   &H80000008&
      Height          =   600
      Left            =   2160
      ScaleHeight     =   40
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   128
      TabIndex        =   3
      Top             =   120
      Width           =   1920
   End
   Begin VB.CommandButton Command2 
      Caption         =   "generate"
      Height          =   375
      Left            =   2160
      TabIndex        =   2
      Top             =   1800
      Width           =   1935
   End
   Begin VB.CommandButton Command1 
      Caption         =   "load bitmap"
      Height          =   375
      Left            =   2160
      TabIndex        =   1
      Top             =   840
      Width           =   1935
   End
   Begin MSComDlg.CommonDialog cd 
      Left            =   2880
      Top             =   3240
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      CancelError     =   -1  'True
   End
   Begin VB.PictureBox picTiles 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Terminal"
         Size            =   4.5
         Charset         =   255
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4800
      Left            =   120
      ScaleHeight     =   320
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   128
      TabIndex        =   0
      Top             =   120
      Width           =   1920
   End
   Begin VB.Label lblStatus 
      Height          =   255
      Left            =   2160
      TabIndex        =   5
      Top             =   4680
      Width           =   5655
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Const tw As Long = 128
Const th As Long = 320

Const npalettes As Long = 5
Const ntiles As Long = 160


Dim tilePalette(16 * 5 - 1) As Long
Dim paletteUsage(16 * 5 - 1) As Boolean

Dim fullData(tw * th - 1) As Long
Dim tileData(tw * th - 1) As Byte
Dim snesData(tw * th / 2 - 1) As Byte
Dim tilePalettes(ntiles - 1) As Integer

Dim finalData As New DataBuffer

Private Function SHL(ByVal v As Long, ByVal amt As Long) As Long
    SHL = v * 2 ^ amt
End Function

Private Function SHR(ByVal v As Long, ByVal amt As Long) As Long
    SHR = v \ 2 ^ amt
End Function

Private Sub Command1_Click()
    On Error GoTo errhand
    cd.filename = ""
    cd.Filter = "BITMAP FILES|*.bmp"
    cd.Flags = 0
    cd.ShowOpen
    picTiles.Picture = LoadPicture(cd.filename)
    
errhand:
End Sub

Private Function FindPalette(list As ColorList) As Integer
    Dim p As Long, c As Long, failure As Boolean
    Dim c2 As Long
    Dim col As Long
    Dim cfound As Boolean
    For p = 0 To npalettes - 1
        failure = False
        For c = 0 To list.nColors - 1
            col = list.GetColor(c)
            For c2 = 0 To 15
                cfound = False
                If col = tilePalette(p * 16 + c2) Then
                    cfound = True
                    Exit For
                End If
            Next
            If Not cfound Then
                failure = True
                Exit For
            End If
        Next
        If Not failure Then
            FindPalette = p
            Exit Function
        End If
    Next
    FindPalette = -1
End Function

Private Function FindColor(ByVal p As Integer, ByVal test As Long) As Byte
    Dim i As Integer
    For i = 0 To 15
        If tilePalette(p * 16 + i) = test Then
            FindColor = i
            Exit Function
        End If
    Next
    Debug.Print "failure during color find"
End Function

Function Posterize32(c As Long) As Long
    Dim r As Long, g As Long, b As Long
    r = c And 255
    g = (c And &HFF00&) \ &H100&
    b = (c And &HFF0000) \ &H10000
    r = r \ 8
    r = r * 8
    g = g \ 8
    g = g * 8
    b = b \ 8
    b = b * 8
    Posterize32 = RGB(r, g, b)
End Function

Function UnPosterize32(c As Long) As Long
    Dim r As Long, g As Long, b As Long
    r = c And 255
    g = (c And &HFF00&) \ &H100&
    b = (c And &HFF0000) \ &H10000
    r = Round(CDbl(r \ 8) * 8.22581)
    g = Round(CDbl(g \ 8) * 8.22581)
    b = Round(CDbl(b \ 8) * 8.22581)
    UnPosterize32 = RGB(r, g, b)
End Function

Private Sub Log(txt As String)
    If txtOutput <> "" Then
        txtOutput = txtOutput & vbCrLf & txt
    Else
        txtOutput = txt
    End If
    txtOutput.SelStart = Len(txtOutput.Text)
End Sub

Private Sub xtile(ByVal tile As Integer)
    Dim px As Long, py As Long
    px = (tile Mod 8) * 16
    py = (tile \ 8) * 16
    picTiles.Line (px, py)-(px + 16, py + 16), vbRed
    picTiles.Line (px, py + 16)-(px + 16, py), vbRed
End Sub

Private Sub CreatePalette()

    Dim x As Long, y As Long, i As Long
    
    Status "Creating palette"
    
    i = 0
    For y = 0 To 4
        For x = 0 To 15
            tilePalette(i) = Posterize32(picPalette.Point(x * 8, y * 8))
            picPalette.Line (x * 8, y * 8)-(x * 8 + 8, y * 8), UnPosterize32(tilePalette(i))
            picPalette.Line (x * 8, y * 8 + 1)-(x * 8 + 8, y * 8 + 1), UnPosterize32(tilePalette(i))
            picPalette.Line (x * 8, y * 8 + 2)-(x * 8 + 8, y * 8 + 2), UnPosterize32(tilePalette(i))
            picPalette.Line (x * 8, y * 8 + 3)-(x * 8 + 8, y * 8 + 3), UnPosterize32(tilePalette(i))
            
            i = i + 1
            DoEvents
            DoEvents
            progress CDbl(y) / 4# + (CDbl(x) / 4# / 16#)
        Next
    Next
    
End Sub

Private Sub ParseBitmap()

    Dim x As Long, y As Long, tx As Long, ty As Long
    
    Status "Cutting up bitmap (16x16 tiles)"
    
    For y = 0 To (th \ 16) - 1
        For x = 0 To (tw \ 16) - 1
            For ty = 0 To 15
                For tx = 0 To 15
                    fullData((x + y * 8) * 256 + ty * 16 + tx) = Posterize32(picTiles.Point(x * 16 + tx, y * 16 + ty))
                Next
            Next
            picTiles.PSet (x * 16 + 1, y * 16)
        Next
        progress y / (th \ 16)
        DoEvents
    Next
    
End Sub

Private Sub MapTiles()

    Status "Mapping tiles"
    
    Dim tile As Long, cl As New ColorList, x As Long
    For tile = 0 To ntiles - 1
        cl.Clear
        For x = 0 To 255
            If Not cl.AddColor(fullData(tile * 256 + x)) Then
                Log "Error: tile " & tile & " has too many colors."
                xtile tile
                Exit For
            End If
        Next
        tilePalettes(tile) = FindPalette(cl)
        If tilePalettes(tile) = -1 Then
            Log "Error: tile " & tile & " does not have a palette."
            xtile tile
        Else
            picTiles.FillColor = vbWhite
            picTiles.FillStyle = 0
            picTiles.CurrentX = (tile Mod 8) * 16
            picTiles.CurrentY = (tile \ 8) * 16
            
            ' prime
            picTiles.Line (picTiles.CurrentX, picTiles.CurrentY + 1)-(picTiles.CurrentX + 5, picTiles.CurrentY + 5), vbWhite, B
            
            picTiles.CurrentX = picTiles.CurrentX - 9
            picTiles.CurrentY = picTiles.CurrentY - 4
            
            ' paint
            picTiles.Print tilePalettes(tile)
        End If
        
        progress tile / 160
        DoEvents
    Next
    
End Sub

Private Sub Produce4bppData()

    ' remap 16x16 tiles to 8x8
    ' convert to 16 color
    
    Dim tile As Long, pal As Long
    Dim y As Long, x As Long, y2 As Long, x2 As Long
    Dim org As Long 'origins
    
    Status "Producing 4-bit data"
    
    For tile = 0 To ntiles - 1
        pal = tilePalettes(tile)
        
        If pal <> -1 Then
            org = (CLng(tile Mod 8) * 128) + (CLng(tile \ 8) * 2048)
            
            For y2 = 0 To 1: For x2 = 0 To 1
                For y = 0 To 7: For x = 0 To 7
                    tileData(org + x2 * 64 + y2 * 1024 + x + y * 8) = FindColor(pal, fullData(tile * 256 + x2 * 8 + y2 * 128 + x + y * 16))
                Next: Next
            Next: Next
        End If
        
        progress tile / ntiles
        DoEvents

    Next
    
End Sub

Private Function CBit(ByVal v As Long) As Long
    If v <> 0 Then
        CBit = 1
    Else
        CBit = 0
    End If
End Function

Private Sub ConvertData()
    
    
    
    Dim tile As Long
    Dim index As Long
    Dim plane As Long
    Dim bit As Long
    Dim bits As Byte
    
    If chkEditor.Value = 0 Then
    
        Status "Converting to SNES format"
        
        For tile = 0 To ntiles * 4 - 1
            For plane = 0 To 1
                For index = 0 To 7
                    
                    bits = 0
                    For bit = 0 To 7
                        bits = bits Or SHL(CBit(tileData(tile * 64 + index * 8 + (7 - bit)) And (SHL(1, plane * 2))), bit)
                    Next
                    
                    snesData(tile * 32 + plane * 16 + index * 2) = bits
                    
                    bits = 0
                    For bit = 0 To 7
                        bits = bits Or SHL(CBit(tileData(tile * 64 + index * 8 + (7 - bit)) And (SHL(1, 1 + plane * 2))), bit)
                    Next
                    
                    snesData(tile * 32 + plane * 16 + index * 2 + 1) = bits
                Next
            Next
            progress tile / (ntiles * 4)
            DoEvents
        Next
        
    Else
    
        Status "Packing data"
        
        For index = 0 To tw * th / 2 - 1
            snesData(index) = tileData(index * 2) Or (tileData(index * 2 + 1)) * 16
            If (index Mod 8) = 0 Then
                progress index / (tw * th / 2)
                DoEvents
            End If
            
        Next
    End If
'    Open App.Path & "\test.out" For Binary As #1
 '       Put #1, , snesData
  '  Close #1
End Sub

Private Sub CompressData()
    
    Status "Compressing data"
    
    Dim rp As Long
    Dim srcsize As Long
    
    Dim updatetick As Long
    srcsize = tw * th / 2
    
    ' write: compression type = lz77
    finalData.Push &H10&
    
    ' write: decompressed size
    finalData.Push srcsize And 255
    finalData.Push srcsize \ 256
    finalData.Push 0
    
    Dim blockbits As Byte
    Dim blockcounter As Long
    Dim blockstart As Long
    blockstart = finalData.Tell
    finalData.Push 0
    
    Do Until rp = srcsize
        
        Dim searchStart As Long
        Dim searchIndex As Long
        Dim searchDisp As Long
        
        Dim bestSize As Long
        Dim bestDisp As Long
        bestSize = 0
        
        For searchStart = rp - 1 To 0 Step -1
            searchDisp = rp - 1 - searchStart
            If searchDisp > 4095 Then
                Exit For
            End If
            For searchIndex = 0 To 17
                If (rp + searchIndex) >= srcsize Then
                    Exit For
                End If
                If snesData(searchStart + searchIndex) <> snesData(rp + searchIndex) Then
                    Exit For
                End If
            Next
            If searchIndex > bestSize Then
                bestSize = searchIndex
                bestDisp = searchDisp
                If bestSize = 18 Then
                    Exit For
                End If
            End If
        Next
        
        If bestSize > 2 Then
            ' lz77 block
            finalData.Push (bestDisp \ 256) + (bestSize - 3) * 16
            finalData.Push bestDisp And 255
            rp = rp + bestSize
            blockbits = blockbits Or (1 * (2 ^ (7 - blockcounter)))
        Else
            ' raw block
            finalData.Push snesData(rp)
            rp = rp + 1
        End If
        
        blockcounter = blockcounter + 1
        If blockcounter = 8 Then
            blockcounter = 0
            finalData.WriteData blockstart, blockbits
            blockbits = 0
            blockstart = finalData.Tell
            If rp <> srcsize Then
                finalData.Push 0
            End If
        End If
        
        
        updatetick = updatetick + 1
        If updatetick = 16 Then
            updatetick = 0
            progress rp / srcsize
            DoEvents
        End If
    Loop
    
    If finalData.Tell() <> blockstart Then
        finalData.WriteData blockstart, blockbits
    End If
End Sub

Private Sub UseUncompressedData()
    Dim srcsize As Long
'    finalData.Push 0 'compression type=0
 '   srcsize = tw * th / 2
  '  finalData.Push srcsize And 255
   ' finalData.Push srcsize \ 256
    'finalData.Push 0
    
    Dim i As Long
    For i = 0 To UBound(snesData)
        finalData.Push snesData(i)
    Next
    
End Sub

Private Sub Process()
    
    picTiles.DrawWidth = 1
    txtOutput.Text = ""
    picTiles.Cls
    picPalette.Cls
    picTiles.DrawWidth = 2
    
    Erase paletteUsage
    Erase tileData
    Erase tilePalette
    Erase fullData
    Erase tilePalettes
    Erase snesData
    finalData.Clear
    
    CreatePalette
    ParseBitmap
    MapTiles
    Produce4bppData
    ConvertData
    If chkEditor.Value = 1 Then
        UseUncompressedData
    Else
        CompressData
    End If
    
    progress 1
    Status "mission success"
End Sub

Private Sub Status(s As String)
    lblStatus = s & "..."
End Sub

Private Sub progress(ByVal x As Double)
    If x < 0 Then x = 0
    If x > 1 Then x = 1
    pb.Value = x * 100
End Sub

Private Sub Command2_Click()
    Process
End Sub

Private Sub Command3_Click()
    On Error GoTo errhand
    cd.filename = ""
    cd.Filter = "BITMAP FILES|*.bmp"
    cd.Flags = 0
    cd.ShowOpen
    picPalette.Picture = LoadPicture(cd.filename)
    
errhand:
End Sub

Private Sub Command4_Click()
    On Error GoTo 1
    cd.filename = ""
    cd.Filter = "TILESET files|*.tileset"
    cd.Flags = cdlOFNOverwritePrompt
    cd.ShowSave
    SaveTileset cd.filename
1
End Sub

Private Sub WriteColour16(color24 As Long, file As Integer)
    Dim r As Long, g As Long, b As Long
    r = color24 And 255
    g = (color24 \ &H100&) And 255
    b = (color24 \ &H10000) And 255
    r = r \ 8
    g = g \ 8
    b = b \ 8
    Dim c As Long
    c = r + (g * 32) + (b * 1024)
    Dim outp As Byte
    outp = c And 255
    Put #file, , outp
    outp = c \ 256
    Put #file, , outp
End Sub

Private Sub SaveTileset(filename As String)
    Open filename For Binary As #1
        Dim i As Long
        Dim outp As Byte
        For i = 0 To npalettes * 16 - 1
            WriteColour16 tilePalette(i), 1
        Next
        
        For i = 0 To ntiles - 1
            outp = tilePalettes(i)
            Put #1, , outp
        Next
        
        finalData.WriteToFile 1
    Close #1
End Sub

'Private Sub TestPlot(ByVal rm, c As Long)
'    Dim x
'    Dim y
'    Dim t
'    t = rm \ 32
'    x = ((rm Mod 32) Mod 4) * 2
'    y = (rm Mod 32) \ 4
'    x = x + (t Mod 16) * 8
'    y = y + (t \ 16) * 8
'
'    Dim pal
'    pal = (t Mod 16) \ 2
'    pal = pal + (t \ 32) * 8
'
'    picdbg.PSet (x, y), tilePalette(pal * 16 + (c And 15))
'    picdbg.PSet (x + 1, y), tilePalette(pal * 16 + (c \ 16))
'End Sub
'
'Private Sub TestDecompress()
'    picdbg.Visible = True
'
'    Dim outp
'
'    Dim rp
'
'    Dim bitcount
'    Dim bits
'
'    Dim data
'
'    Do Until outp = (tw * th) / 2
'        If bitcount = 0 Then
'            bitcount = 8
'            bits = finalData.ReadData(rp)
'            rp = rp + 1
'        End If
'
'        bitcount = bitcount - 1
'        If CBool(bits And (1 * 2 ^ bitcount)) Then
'            ' compressed
'            Dim disp
'            Dim bytecount
'            data = finalData.ReadData(rp)
'            data = (data * 256) Or finalData.ReadData(rp)
'            disp = data And 4095
'            disp = outp - disp
'
'        Else
'            ' raw
'            data = finalData.ReadData(rp)
'            TestPlot outp, data
'            outp = outp + 1
'        End If
'    Loop
'End Sub
