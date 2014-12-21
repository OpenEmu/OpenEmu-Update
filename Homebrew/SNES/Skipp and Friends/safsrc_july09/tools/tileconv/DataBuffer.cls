VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DataBuffer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Const alloc_size = 256

Dim data() As Byte
Dim datasize As Long
Dim datawrite As Long

Public Sub Clear()
    datasize = 0
    datawrite = 0
    Erase data
End Sub

Public Sub Push(ByVal b As Byte)
    If datawrite = datasize Then
        If datasize = 0 Then
            ReDim data(alloc_size)
        Else
            ReDim Preserve data(datasize + alloc_size)
        End If
        datasize = datasize + 256
    End If
    data(datawrite) = b
    datawrite = datawrite + 1
End Sub

Public Function Tell() As Long
    Tell = datawrite
End Function

Public Function ReadData(ByVal index As Long) As Byte
    If index > datawrite Then
        Debug.Print "error: reading outside of databuffer"
    End If
    ReadData = data(index)
End Function

Public Sub WriteData(ByVal index As Long, b As Byte)
    If index > datawrite Then
        Debug.Print "error: reading outside of databuffer"
    End If
    data(index) = b
End Sub

Public Sub WriteToFile(file As Integer)
    Dim i As Long
    Dim outp As Byte
    For i = 0 To datawrite - 1
        outp = data(i)
        Put #file, , outp
    Next
End Sub
