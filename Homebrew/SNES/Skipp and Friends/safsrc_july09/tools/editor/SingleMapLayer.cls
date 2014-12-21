VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SingleMapLayer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

Private name As String * 6

Private data(MAPWIDTH * MAPHEIGHT - 1) As TileMapEntry
Private ena As Boolean

Friend Function GetTile(x As Long, y As Long) As TileMapEntry
    GetTile = data(x + y * MAPWIDTH)
End Function

Friend Sub SetTile(x As Long, y As Long, t As TileMapEntry, mask As BRUSH_MASK)
    If mask And BRUSH_TILE Then
        data(x + y * MAPWIDTH).hflip = t.hflip
        data(x + y * MAPWIDTH).vflip = t.vflip
        data(x + y * MAPWIDTH).tile = t.tile
    End If
    If mask And BRUSH_SOLID Then
        data(x + y * MAPWIDTH).solid = t.solid
    End If
    If mask And BRUSH_DESTRUCT Then
        data(x + y * MAPWIDTH).destruct = t.destruct
    End If
End Sub


Public Property Get Enabled() As Boolean
    Enabled = ena
End Property

Public Sub Disable()
    ena = False
End Sub

Public Sub Enable()
    ena = True
End Sub

Public Sub SetName(n As String)
    name = n
End Sub

Public Function GetName() As String
    GetName = name
End Function

Public Sub WriteToFile(ByVal file As Integer)
    Put #1, , ena
    Put #1, , name
    Put #1, , data
End Sub

Public Sub ReadFromFile(ByVal file As Integer)
    Get #1, , ena
    Get #1, , name
    Get #1, , data
End Sub

Private Sub Class_Initialize()
    Dim x As Long
    For x = 0 To (MAPWIDTH * MAPHEIGHT) - 1
        data(x).tile = -1
        data(x).destruct = -1
        data(x).hflip = False
        data(x).vflip = False
        data(x).solid = -1
        data(x).matter = -1
    Next
End Sub

Public Sub ShiftUp()
    Dim x As Long, y As Long
    For x = 0 To MAPWIDTH - 1
        For y = 0 To MAPHEIGHT - 2
            data(x + y * MAPWIDTH) = data(x + (y + 1) * MAPWIDTH)
        Next
    Next
    For x = 0 To MAPWIDTH - 1
        With data(x + (MAPHEIGHT - 1) * MAPWIDTH)
            .tile = -1
            .destruct = -1
            .hflip = False
            .vflip = False
            .matter = -1
            .solid = -1
        End With
    Next
End Sub

Public Sub ShiftDown()
    Dim x As Long, y As Long
    For x = 0 To MAPWIDTH - 1
        For y = MAPHEIGHT - 1 To 1 Step -1
            data(x + y * MAPWIDTH) = data(x + (y - 1) * MAPWIDTH)
        Next
    Next
    For x = 0 To MAPWIDTH - 1
        With data(x)
            .tile = -1
            .destruct = -1
            .hflip = False
            .vflip = False
            .matter = -1
            .solid = -1
        End With
    Next
End Sub

Public Sub ShiftLeft()
    Dim y As Long, x As Long
    For y = 0 To MAPHEIGHT - 1
        For x = 0 To MAPWIDTH - 2
            data(x + y * MAPWIDTH) = data(x + 1 + y * MAPWIDTH)
        Next
    Next
    For y = 0 To MAPHEIGHT - 1
        With data(MAPWIDTH - 1 + y * MAPWIDTH)
            .tile = -1
            .destruct = -1
            .hflip = False
            .vflip = False
            .matter = -1
            .solid = -1
        End With
    Next
End Sub

Public Sub ShiftRight()
    Dim y As Long, x As Long
    For y = 0 To MAPHEIGHT - 1
        For x = MAPWIDTH - 1 To 1 Step -1
            data(x + y * MAPWIDTH) = data(x - 1 + y * MAPWIDTH)
        Next
    Next
    For y = 0 To MAPHEIGHT - 1
        With data(y * MAPWIDTH)
            .tile = -1
            .destruct = -1
            .hflip = False
            .vflip = False
            .matter = -1
            .solid = -1
        End With
    Next
End Sub
