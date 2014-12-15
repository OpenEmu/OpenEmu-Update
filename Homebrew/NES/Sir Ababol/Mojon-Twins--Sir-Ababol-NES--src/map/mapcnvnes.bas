' MAPCNV NES
' Converts a Mappy layer to a suitable-scrollable, Churrera-NES map.
'
' Format is:
' Map is divided in "MapChunks". 
' Each MapChunk is 25 bytes:
' 20 bytes for 20 tiles:
' 01
' 23
' 45
' 67
' 89
' ...
' 5 bytes for 5 attributes.
' Each attribute contains palettes for 4 tiles.
'
' Each tile palete is stored in pallist.txt

' mapcnvnes w_t h_s

Type BOLT
	x as Integer
	y as Integer
End Type

Type OBJ
	x as integer
	y as integer
	t as integer
end type

Dim As Integer x, y, xx, yy, f1, f2, i
Dim As Integer wt, hs, rhs, rws
Dim As String mapFileName, palString, o
Dim As uByte orgMap(512, 512), d
Dim As uByte pal(47)
Dim As BOLT bolts(10,512)
Dim As OBJ objs(10,512)

If Command(1) = "" Or _
	Val(Command(2)) = 0 Or Val(Command(3))=0 Then
	Print "mapcnvnes mapfile w_t h_s"
	Print "   w_t: Width in tiles."
	Print "   h_s: Height in stripes."
	Print "Produces map.bin and map.h"
	Print "Also produces bolts.h with bolts array"
	Print "Also produces objs.h with objects array"
	Print "Replaces tile 15 (bolts) and tiles 45, 46, 47 (objects) with "
	Print "tile 0 on map output."
	System
End If

for y = 0 to 10: for x = 0 To 512
	objs(y,x).x=255
	bolts(y,x).x=255
	objs(y,x).y=255
	bolts(y,x).y=255
next x: next y

' Read pal
f1 = FreeFile
Open "pallist.txt" For Input as #f1
	Line Input #f1, palString
	For i = 1 To Len(palString)
		pal (i-1) = val (Mid (palString, i, 1))
	Next i
Close #f1

mapFileName = Command(1)
wt = Val (Command(2)) - 1
hs = Val (Command(3)) - 1
rhs = (10 * Val (Command(3))) - 1

f1 = FreeFile
Open mapFileName For Binary as #f1

' First read map
For y = 0 to rhs
	For x = 0 To wt
		Get #f1, , d
		orgMap (y, x) = d
	
	Next x
Next y

Close #f1

f2 = FreeFile
Open "map.bin" For Binary as #f2

For y = 0 to hs

	For x = 0 To wt Step 2
		' Chunk. First, 20 tiles:	
		For yy = 0 To 9
			d = orgMap (10 * y + yy, x) + 16
			' Bolt?
			If d = 31 Then
				' New bolt:
				bolts(y, x\16).x = x
				bolts(y, x\16).y = yy
				d = 0
			End If
			If d >= 61 And d <= 63 Then
			
				' New bolt:
				objs(y, x\16).x = x
				objs(y, x\16).y = yy
				objs(y, x\16).t = d-60
				d = 0
			End If
			Put #f2, , d
			d = orgMap (10 * y + yy, x + 1) + 16
			' Bolt?
			If d = 31 Then
				' New bolt:
				bolts(y, x\16).x = x + 1
				bolts(y, x\16).y = yy
				d = 0
			End If
			If d >= 61 And d <= 63 Then
				' New bolt:
				objs(y, x\16).x = x + 1
				objs(y, x\16).y = yy
				objs(y, x\16).t = d-60
				d = 0
			End If
			Put #f2, , d
		Next yy
		
		' Next, 5 attributes
		For yy = 0 To 9 Step 2
			' ab
			' cd
			' attr = dcba
			d = 0
			d = d + pal (orgMap (10 * y + yy, x))
			d = d + (pal (orgMap (10 * y + yy, x + 1)) Shl 2)
			d = d + (pal (orgMap (10 * y + yy + 1, x)) Shl 4)
			d = d + (pal (orgMap (10 * y + yy + 1, x + 1)) Shl 6)
			Put #f2, , d
		Next yy
	Next x

Next y

Close #f2

Print "map.bin generated."

' Generate map.h
f1 = FreeFile
Open "map.bin" For Binary as #f1
f2 = FreeFile
Open "map.h" For Output as #f2

i = 0
o = ""
Print #f2, "const unsigned char map[] = {"
While Not Eof (f1)
	i = i + 1
	Get #f1, , d
	o = o + Str (d)
	o = o + ", "
	If i = 25 Then 
		If Eof (f1) Then o = left(o, len(o)-2)
		Print #2, "    " + o
		o = ""
		i = 0
	End If
Wend
If o <> "" Then o = left(o, len(o)-2):Print #2, "    " + o
Print #f2, "};"
Print "map.h generated."

Close #f1, #f2

' Bolts

f2 = FreeFile
Open "bolts.h" For Output as #f2
print #f2, "const unsigned char bolts[] = {"
rws = wt\16
For y = 0 to hs
	print #f2,"    ";
	For x = 0 to rws
		print #f2, Trim(Str(bolts (y, x).x)); ", ";
		print #f2, Trim(Str(bolts (y, x).y));
		If x<>rws or y<>hs Then print #f2, ", ";
	Next x
	print #f2, ""
next y
Print #f2, "};"



Close #f2
Print "bolts.h generated."

' Objects

f2 = FreeFile
Open "objs.h" For Output as #f2
print #f2, "const unsigned char objs[] = {"
rws = wt\16
For y = 0 to hs
	print #f2,"    ";
	For x = 0 to rws
		print #f2, Trim(Str(objs (y, x).x)); ", ";
		print #f2, Trim(Str(objs (y, x).y)); ", ";
		print #f2, Trim(Str(objs (y, x).t));
		If x<>rws or y<>hs Then print #f2, ", ";
	Next x
	print #f2, ""
next y
Print #f2, "};"

Close #f2
Print "objs.h generated."
