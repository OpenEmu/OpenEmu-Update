VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "TilesetLoader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' does not supporte compressed tilesets

Private tilePalette(16 * 5 - 1)     As Long
Private paletteMap(160 - 1)         As Byte
Private data(127, 319)              As Byte 'converted 80col data

Public Sub LoadTileset(filename As String)
    Dim ff As Integer
    ff = FreeFile
    Open filename For Binary As #ff
    
    LoadColors ff
    LoadTileMapping ff
    LoadBitmap ff
    
    Close #ff
End Sub

Public Function GetPalette(ByVal tile As Long) As Long
    If tile < 160 * 4 Then
        GetPalette = paletteMap((tile Mod 16) \ 2 + (tile \ 32) * 8)
    Else
        GetPalette = 4
    End If
End Function

Public Function GetPixel(x As Long, y As Long) As Long
    If data(x, y) = 0 Then
        GetPixel = -1
    Else
        GetPixel = tilePalette(data(x, y))
    End If
End Function

Private Sub LoadColors(file As Integer)
    Dim b As Byte
    Dim color As Long
    Dim i As Integer
    For i = 0 To UBound(tilePalette)
        Get #file, , b
        color = b
        Get #file, , b
        color = color + CLng(b) * 256
        tilePalette(i) = ConvertColour(color)
    Next
End Sub

Private Sub LoadTileMapping(file As Integer)
    Dim i As Integer
    Dim b As Byte
    For i = 0 To UBound(paletteMap)
        Get #file, , b
        paletteMap(i) = b
    Next
End Sub

Private Sub LoadBitmap(file As Integer)
    Dim m As Long
    Dim b As Byte
    Dim bitmapdata(CLng(128) * 320 - 1) As Byte '4bpp 8x8 tiles
    For m = 0 To CLng(128) * 320 / 2 - 1
        Get #file, , b
        bitmapdata(m * 2) = b And 15
        bitmapdata(m * 2 + 1) = b \ 16
    Next m
    
    Dim x As Long, y As Long, pal As Long
    Dim ci As Long '(color index)
    Dim bd As Long
    For x = 0 To 127
        For y = 0 To 319
            pal = paletteMap((y \ 16) * 8 + (x \ 16))
            ci = pal * 16
            bd = bitmapdata( _
                (x \ 8) * 64 + (x Mod 8) + (y \ 8) * 1024 + (y Mod 8) * 8)
            ci = ci + bd
            If bd = 0 Then
                ci = 0
            End If
            data(x, y) = ci
        Next
    Next
End Sub

Private Function ConvertColour(ByVal inp As Long) As Long
    Dim r As Long, g As Long, b As Long
    r = inp And 31
    g = (inp \ 32) And 31
    b = (inp \ 1024) And 31
    r = r * 8 + r \ 4
    g = g * 8 + g \ 4
    b = b * 8 + b \ 4
    ConvertColour = RGB(r, g, b)
End Function

