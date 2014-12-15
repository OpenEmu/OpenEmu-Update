Dim As Integer basetile
Dim As Integer baseX, baseY
Dim As Integer i, x, y, s, nextSet, offsX, offsY, ctr, tile, pal
Dim As Integer numSets, numFrames

' Generates Sir Ababol spriteset
'
' I'm sure this may come handy for future games
' with the same spriteset.

' SirAbabol tiles begin from time 96 onwards
basetile = 53

' Sprites are 24x24 and are aligned (-4, -8) to the
' active 16x16 bounding box, so...
baseX = -4
baseY = -8

' 2 sets, 6 frames per set. Sets 64 tiles appart
nextSet = 54
numSets = 2
numFrames = 6

' Palette used
pal = 2

open "metasprites.h" for output as #1

ctr = 0
For s = 1 To numSets

	tile = baseTile
	
	For i = 1 to numFrames
		Print #1, "const unsigned char sprAba" & Trim (Str (ctr)) & "[] = {"
		Print #1, "    ";
		offsY = baseY
		For y = 0 to 2
			offsX = baseX
			For x = 0 to 2
				Print #1, Trim (Str (offsX)) & ", " & Trim (Str (offsY)) & ", " & Trim (Str (Tile)) & ", " & Trim (Str (pal)) & ", ";				
				offsX = offsX + 8
				tile = tile + 1
			Next x
			offsY = offsY + 8
		Next y
		Print #1, "128"
		Print #1, "};"
		ctr = ctr + 1
	Next i

	baseTile = baseTile + nextSet
	
Next s

Print #1, ""
Print #1, "const unsigned char* const spr_enems[]={"
ctr = 0
For s = 1 To numSets
	Print #1, "    ";
	For i = 1 To numFrames
		Print #1, "sprAba" & Trim (Str (ctr));
		If i <> numFrames Or s <> numSets Then
			Print #1, ", ";
		End If
		ctr = ctr + 1
	Next i
	Print #1, ""
Next s
Print #1, "};"
	
Close 1
