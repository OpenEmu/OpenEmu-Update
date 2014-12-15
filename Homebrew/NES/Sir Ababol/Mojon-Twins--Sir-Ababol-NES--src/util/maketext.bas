' make text

Dim as String text, m
Dim as Integer i, j,ctr

print "Mete texto (mayúsculas y tal)"
input text

ctr = 0
For i = 1 to len (text)
	j = asc(mid(text, i, 1))-32
	if j = 0 then j = 64
	Print "0x";hex(j, 2); ", ";
	ctr = ctr + 1: if ctr = 8 then print :ctr = 0
Next i
Print "0"
?"LEN = " & len(text)
?"CENTER X = " & (16 - len(text)/2)