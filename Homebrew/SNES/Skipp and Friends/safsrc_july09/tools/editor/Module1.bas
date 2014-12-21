Attribute VB_Name = "Module1"

Public Const MAPWIDTH As Long = 64
Public Const MAPHEIGHT As Long = 32

Public Enum BRUSH_MASK
    BRUSH_TILE = 1
    BRUSH_SOLID = 2
    BRUSH_DESTRUCT = 4
End Enum


Public Type TileMapEntry
    tile As Integer
    hflip As Boolean
    vflip As Boolean
    
    solid As Integer
    destruct As Integer
    matter As Integer
    
End Type



Global Const SkipFlipping = True

