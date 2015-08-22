Lander2 v0.C

Copyright (C) 2014-2015  jmimu (jmimu@free.fr)
https://github.com/jmimu/lander2

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.



////////////////////////////////////////////////////////////////////////

Sequel to Lander1.

I found useful information to start asm SMS developpement on these pages:
 - Maxim's step-by-step introduction: http://www.smspower.org/maxim/HowToProgram/
 - Dave's Tile Studio definition file for SMS: http://racethebeam.blogspot.fr/2011/01/tile-studio-definition-file-for-sms.html
 - Z80 instructions set: http://z80-heaven.wikidot.com/instructions-set
 - Heliophobe's simple sprite demo: http://www.smspower.org/Homebrew/SimpleSpriteDemo-SMS
 - 16x16 sprites in Blockhead homebrew: http://www.smspower.org/Homebrew/Blockhead-SMS
 - mk3man.pdf
 - Maxim's bmp2tile for title screen

The font tiles come from Maxim example.

////////////////////////////////////////////////////////////////////////

List of custom tools
 - Tiled tilemaps are exported in json, and converted into binary format with maps/tiled2asm.py
 - a map where new tiles are inserted can be fixed with maps/fixTilemap.py, where you have to program the modification you want
 - the music is composed with MuseScore (musescore.org) and exported in midi
 - midi files are converted into strings with music/midi2text.py
 - the music strings are converted into binary format with music/text2sms_b.py
 - the tiles are in PNG, and converted into binary format with Master Tile Converter (jmimu.free.fr/mastertileconverter)
Please ask me for any help with them!

External tools used :
 - WLA DX (www.villehelin.com/wla.html): assembler
 - pixeditor (github.com/z-uo/pixeditor): pixel art editor
 - aseprite (http://www.aseprite.org): pixel art editor
 - GIMP: pixel art editor
 - Tiled (http://www.mapeditor.org): tiles map editor
 - MuseScore (musescore.org): musical score editor
 - Master Tile Converter (jmimu.free.fr/mastertileconverter): bitmap to asm converter
 - emulicious (emulicious.net): SMS emulator with great debugger!

