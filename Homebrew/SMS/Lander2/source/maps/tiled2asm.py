#!/usr/bin/python3
import os
import sys
import json
import math

if (len(sys.argv)<3):
  print("Synthax: python3 tiled2asm.py json_file first_map_tile_index")
  exit()

filename=sys.argv[1]
data = json.load(open(filename))

first_map_tile_index=int(sys.argv[2])
print("first_map_tile_index=",first_map_tile_index)

height=data["layers"][0]["height"]
width=data["layers"][0]["width"]


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

#if in to half return the tile number, else hz flip
#returns number without flip, and a hz flip flag
def numTile2filp_back(num):
  if (num>0):
     num-=back_tileset_firstgid
  if (num<=back_tileset_nbr_tiles):
    return (num,0)
  y=math.floor(num/back_tileset_w)
  x=num-y*back_tileset_w
  return ( (back_tileset_w-x-1)+(y-back_tileset_h)*back_tileset_w, 1)

if coll_tileset:
  coll_tileset_w=int(coll_tileset["imagewidth"]/coll_tileset["tilewidth"])
  #height is divided by 2 because lower half is first half flipped
  coll_tileset_h=int(coll_tileset["imageheight"]/coll_tileset["tileheight"]/2)
  coll_tileset_firstgid=coll_tileset["firstgid"]
  coll_tileset_nbr_tiles=coll_tileset_w*coll_tileset_h
  print("coll_tileset_w: ",coll_tileset_w)
  print("coll_tileset_h: ",coll_tileset_h)
else:
  print("No tileset \"collisions\"!")

#if in to half return the tile number, else remove half
#returns number without flip, and a hz flip flag
def numTile2filp_coll(num):
  if (num>0):
     num-=coll_tileset_firstgid
  if (num<=coll_tileset_nbr_tiles):
    return (num,0)
  return ( num-coll_tileset_nbr_tiles, 1)


layers=data["layers"]
uncompressed_map_bg=None
uncompressed_map_coll=None
for layer in layers:
  print("Looking at",layer["name"],"layer")
  if layer["name"]=="bg":
    uncompressed_map_bg=layer["data"]
  if layer["name"]=="collisions":
    uncompressed_map_coll=layer["data"]





#todo: support >256 rows

k=0
all_values=[]
for i in range(height):
  all_values.append([])
  for j in range(width):
    flip_tile=uncompressed_map_bg[k]
    (non_flip_tile,flip)=numTile2filp_back(flip_tile)
    non_flip_coll=0
    if (coll_tileset):
      flip_coll=uncompressed_map_coll[k]
      (non_flip_coll,flip2)=numTile2filp_coll(flip_coll)
    print("tile",first_map_tile_index+non_flip_tile,"  flip",flip,"  coll",non_flip_coll)

    #final value is composed with the tile number, hz flip bit and collision bits
    final_val=first_map_tile_index+non_flip_tile+flip*512+non_flip_coll*8192
    all_values[-1].append(final_val)
    k+=1


print("_TilemapStart:")
for row in all_values:
  str=".dw"
  j=0
  for val in row:
    j+=1
    #str+=' $%04x'%(val-1)
    str+=" %{0:016b}".format(val)
    #if (j==8)or(j==16)or(j==24):
    #  str+="\n.dw"
    #if (j==32):
    #  str+="\n"
    if (j==width):
      str+="\n"
    elif (j%8==0):
      str+="\n.dw"
  print(str)
print("_TilemapEnd:")




