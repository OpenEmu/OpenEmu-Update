VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "mapLayer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' -1 = inherit!

Private LAYERS() As SingleMapLayer
Dim nlayers As Long

Dim ActLayer As Long

Public Sub WriteBGmap(file As Integer, ByVal prio As Boolean, tileset As TilesetLoader)
    
    Dim x As Long, y As Long
    
    Dim tile As TileMapEntry
    Dim bgtile As Long
    
    Dim outp As Byte
    Dim z As Long
    
    For z = 0 To 1
        For y = 0 To 31
            For x = 0 To 31
                
                tile = GetTile(x + z * 32, y)
                
                bgtile = tile.tile
                If tile.hflip Then
                    bgtile = bgtile + 16384
                End If
                If tile.vflip Then
                    bgtile = bgtile + 32768
                End If
                
                If prio Then
                    bgtile = bgtile + 8192
                End If
                
                bgtile = bgtile + ((3 + tileset.GetPalette(tile.tile)) * 1024)
                
                outp = bgtile And 255
                Put #file, , outp
                outp = bgtile \ 256
                Put #file, , outp
            Next
        Next
    Next
    
End Sub

Public Sub AddLayer()
    If nlayers = 0 Then
        ReDim LAYERS(0)
        ActLayer = 0
    Else
        ReDim Preserve LAYERS(nlayers)
    End If
    Set LAYERS(nlayers) = New SingleMapLayer
    LAYERS(nlayers).Enable
    LAYERS(nlayers).SetName "LAYER" & nlayers + 1
    nlayers = nlayers + 1
End Sub

Public Sub DeleteLayer(Index As Long)
    If Index < nlayers Then
        Set LAYERS(Index) = Nothing 'delete reference
        Dim i As Long
        For i = Index To nlayers - 2
            Set LAYERS(i) = LAYERS(i + 1)
        Next
        Set LAYERS(nlayers - 1) = Nothing
        If nlayers > 1 Then
            ReDim Preserve LAYERS(nlayers - 2)
        Else
            ReDim LAYERS(-1 To -1)
        End If
        nlayers = nlayers - 1
    End If
End Sub

Public Sub MoveLayerUp(Index As Long)
    If Index <> 0 Then
        Dim l As SingleMapLayer
        Set l = LAYERS(Index)
        Set LAYERS(Index) = LAYERS(Index - 1)
        Set LAYERS(Index - 1) = l
    End If
End Sub

Public Sub MoveLayerDown(Index As Long)
    If Index <> nlayers - 1 Then
        Dim l As SingleMapLayer
        Set l = LAYERS(Index + 1)
        Set LAYERS(Index + 1) = LAYERS(Index)
        Set LAYERS(Index) = l
    End If
End Sub

Public Function GetNumLayers() As Long
    GetNumLayers = nlayers
End Function

Public Sub SetActiveLayer(Index As Long)
    ActLayer = Index
End Sub

Public Sub DisableLayer(Index As Long)
    LAYERS(Index).Disable
End Sub

Public Sub EnableLayer(Index As Long)
    LAYERS(Index).Enable
End Sub

Public Function LayerIsEnabled(Index As Long) As Boolean
    LayerIsEnabled = LAYERS(Index).Enabled
End Function

Friend Function GetTile(x As Long, y As Long) As TileMapEntry
    Dim t As TileMapEntry
    t.destruct = False
    t.hflip = False
    t.vflip = False
    t.matter = 0
    t.solid = 0
    
    Dim layer As Long
    For layer = 0 To nlayers - 1
        If LAYERS(layer).Enabled Then
            Dim t2 As TileMapEntry
            t2 = LAYERS(layer).GetTile(x, y)
            If t2.tile <> -1 Then
                t.tile = t2.tile
                t.hflip = t2.hflip
                t.vflip = t2.vflip
            End If
            If t2.solid <> -1 Then
                t.solid = t2.solid
            End If
            If t2.matter <> -1 Then
                t.matter = t2.matter
            End If
            If t2.destruct <> -1 Then
                t.destruct = t2.destruct
            End If
        End If
    Next
    GetTile = t
End Function

Friend Function Paint(x As Long, y As Long, t As TileMapEntry, m As BRUSH_MASK)
    If ActLayer >= 0 Then
        LAYERS(ActLayer).SetTile x, y, t, m
    End If
End Function

Public Sub SetLayerName(ByVal Index As Long, name As String)
    LAYERS(Index).SetName name
End Sub

Public Function GetLayerName(ByVal Index As Long) As String
    GetLayerName = LAYERS(Index).GetName
End Function

Public Function WriteToFile(ByVal file As Integer)
    Put #1, , nlayers
    Dim i As Integer
    For i = 0 To nlayers - 1
        LAYERS(i).WriteToFile file
    Next
End Function

Public Function ReadFromFile(ByVal file As Integer)
    Get #1, , nlayers
    ReDim LAYERS(0 To nlayers - 1)
    Dim i As Integer
    For i = 0 To nlayers - 1
        Set LAYERS(i) = New SingleMapLayer
        LAYERS(i).ReadFromFile file
    Next
End Function

Private Sub Class_Initialize()
    ActLayer = -1
End Sub

Public Sub ShiftUp()
    Dim i As Integer
    For i = 0 To nlayers - 1
        LAYERS(i).ShiftUp
    Next
End Sub

Public Sub ShiftDown()
    Dim i As Integer
    For i = 0 To nlayers - 1
        LAYERS(i).ShiftDown
    Next
End Sub

Public Sub ShiftLeft()
    Dim i As Integer
    For i = 0 To nlayers - 1
        LAYERS(i).ShiftLeft
    Next
End Sub

Public Sub ShiftRight()
    Dim i As Integer
    For i = 0 To nlayers - 1
        LAYERS(i).ShiftRight
    Next
End Sub
