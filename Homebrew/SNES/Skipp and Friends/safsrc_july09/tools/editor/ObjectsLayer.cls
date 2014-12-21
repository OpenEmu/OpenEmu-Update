VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ObjectsLayer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private OBJECTS() As SingleObject
Private nObjects As Long

Public Sub WriteToFile(file As Integer)
    Put #1, , nObjects
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            Put #1, , .attr1
            Put #1, , .attr2
            Put #1, , .attr3
            Put #1, , .attr4
            Put #1, , .direction
            Put #1, , .typ
            Put #1, , .x
            Put #1, , .y
        End With
    Next
End Sub

Public Sub ReadFromFile(file As Integer)
    Get #1, , nObjects
    If nObjects <> 0 Then
        ReDim OBJECTS(nObjects - 1)
    Else
        ReDim OBJECTS(-1 To -1)
    End If
    
    Dim i As Integer
    Dim v As Integer
    For i = 0 To nObjects - 1
        Set OBJECTS(i) = New SingleObject
        With OBJECTS(i)
        
            Get #1, , v
            .attr1 = v
            Get #1, , v
            .attr2 = v
            Get #1, , v
            .attr3 = v
            Get #1, , v
            .attr4 = v
            Get #1, , v
            .direction = v
            Get #1, , v
            .typ = v
            Get #1, , v
            .x = v
            Get #1, , v
            .y = v
        End With
    Next
End Sub

Public Function AddObject(ByVal x As Long, ByVal y As Long, ByVal typ As Long, ByVal direction As Integer) As SingleObject
    If nObjects = 0 Then
        ReDim OBJECTS(0)
    Else
        ReDim Preserve OBJECTS(nObjects + 1)
    End If
    Set OBJECTS(nObjects) = New SingleObject
    With OBJECTS(nObjects)
        
        .x = x
        .y = y
        .direction = direction
        .typ = typ
    End With
    nObjects = nObjects + 1
    Set AddObject = OBJECTS(nObjects - 1)
End Function

Public Sub RemoveObject(ByVal Index As Long)
    If Index > nObjects Then
        Debug.Print "err: deleting invalid object"
    End If
    
    If nObjects = 1 Then
        nObjects = 0
        ReDim OBJECTS(-1 To -1)
    Else
    
        Dim i As Integer
        For i = Index To nObjects - 2
            Set OBJECTS(i) = OBJECTS(i + 1)
        Next
        ReDim Preserve OBJECTS(nObjects - 2)
        nObjects = nObjects - 1
    End If
End Sub

Public Function TestForObject(ByVal x As Long, ByVal y As Long) As Integer
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            If .x = x And .y = y Then
                TestForObject = i
                Exit Function
            End If
        End With
    Next
    
    TestForObject = -1
End Function

Public Function GetObject(ByVal Index As Integer) As SingleObject
    Set GetObject = OBJECTS(Index)
End Function

Public Function Count() As Integer
    Count = nObjects
End Function

Public Sub Export(file As Integer)
    Dim i As Integer
    
    Dim outp As Byte
    outp = nObjects
    Put #file, , outp
    
    For i = 0 To nObjects - 1
        With OBJECTS(i)
        
            
            outp = .typ + 1
            Put #file, , outp
            outp = .direction
            Put #file, , outp
            outp = .x
            Put #file, , outp
            outp = .y
            Put #file, , outp
            outp = .attr1
            Put #file, , outp
            outp = .attr2
            Put #file, , outp
            outp = .attr3
            Put #file, , outp
            outp = .attr4
            Put #file, , outp
        End With
    Next
End Sub

Public Sub ShiftLeft()
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            .x = .x - 1
        End With
    Next
End Sub

Public Sub ShiftUp()
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            .y = .y - 1
        End With
    Next
End Sub

Public Sub ShiftRight()
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            .x = .x + 1
        End With
    Next
End Sub

Public Sub ShiftDown()
    Dim i As Integer
    For i = 0 To nObjects - 1
        With OBJECTS(i)
            .y = .y + 1
        End With
    Next
End Sub
