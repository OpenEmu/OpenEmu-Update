VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ColorList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Colors(15) As Long
Public nColors As Long

Public Sub Clear()
    nColors = 0
End Sub

Public Function AddColor(color As Long) As Boolean
    Dim i As Long
    For i = 0 To nColors - 1
        If Colors(i) = color Then
            AddColor = True
            Exit Function
        End If
    Next
    
    If nColors = 16 Then
        AddColor = False
        Exit Function
    End If
    
    Colors(nColors) = color
    nColors = nColors + 1
    AddColor = True
End Function

Public Function GetColor(index As Long) As Long
    GetColor = Colors(index)
End Function
