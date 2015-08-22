#!/usr/bin/python3
import os
import sys
import json
import math

#http://python.net/~goodger/projects/pycon/2007/idiomatic/handout.html

if (len(sys.argv)<2):
  print("Synthax: python3 tiled2asm.py json_file")
  exit()

filename=sys.argv[1]
data = json.load(open(filename))

tilesets=data["tilesets"]
back_tileset=None
coll_tileset=None

for tileset in tilesets:
  print("Looking at",tileset["name"],"tileset")
  if tileset["name"]=="bg":
    back_tileset=tileset
  if tileset["name"]=="collisions":
    coll_tileset=tileset

if back_tileset:
  back_tileset_w=int(back_tileset["imagewidth"]/back_tileset["tilewidth"])
  #height is divided by 2 because lower half is first half flipped
  back_tileset_h=int(back_tileset["imageheight"]/back_tileset["tileheight"]/2)
  back_tileset_firstgid=back_tileset["firstgid"]
  back_tileset_nbr_tiles=back_tileset_w*back_tileset_h
  print("back_tileset_w: ",back_tileset_w)
  print("back_tileset_h: ",back_tileset_h)
else:
  print("Error, no tileset \"back\"!")
  exit()


if coll_tileset:
  coll_tileset_w=int(coll_tileset["imagewidth"]/coll_tileset["tilewidth"])
  #height is divided by 2 because lower half is first half flipped
  coll_tileset_h=int(coll_tileset["imageheight"]/coll_tileset["tileheight"]/2)
  coll_tileset_firstgid=coll_tileset["firstgid"]
  coll_tileset_nbr_tiles=coll_tileset_w*coll_tileset_h
  print("coll_tileset_w: ",coll_tileset_w)
  print("coll_tileset_h: ",coll_tileset_h)
else:
  print("Error, no tileset \"collisions\"!")
  exit()


layers=data["layers"]
uncompressed_map_bg=None
uncompressed_map_coll=None
i=0
for layer in layers:
  print("Looking at",layer["name"],"layer")
  if layer["name"]=="bg":
    uncompressed_map_bg=layer["data"]
    bg_index=i
  if layer["name"]=="collisions":
    uncompressed_map_coll=layer["data"]
    coll_index=i
  i+=1

fixed_uncompressed_map_bg=[]
for (i, tile) in enumerate(uncompressed_map_bg):
  if (tile>0):
    tile-=back_tileset_firstgid
  #fixing law
  if (tile>=64):
    tile+=32
  fixed_uncompressed_map_bg.append(tile+back_tileset_firstgid)

fixed_uncompressed_map_coll=[]
for (i, tile) in enumerate(uncompressed_map_coll):
  if (tile>0):
    tile-=coll_tileset_firstgid
  #fixing law
  tile+=64
  fixed_uncompressed_map_coll.append(tile+coll_tileset_firstgid)



data["layers"][bg_index]=fixed_uncompressed_map_bg
data["layers"][coll_index]=fixed_uncompressed_map_coll


with open('tmp_fixed.json', 'w') as outfile:
    json.dump(data, outfile)


