#!/usr/bin/python
import os
import sys
import json

if (len(sys.argv)<2):
  print("Synthax: python tiled2asm.py json_file")
  exit()

filename=sys.argv[1]
data = json.load(open(filename))

uncompressed_map=data["layers"][0]["data"]
height=data["layers"][0]["height"]
width=data["layers"][0]["width"]

k=0
print "_TilemapStart:"
for i in range(height):
  str=".dw"
  for j in range(width):
    str+=' $%04x'%(uncompressed_map[k]-1)
    if j==15:
      str+="\n.dw"
    k+=1
  print str
print "_TilemapEnd:"
