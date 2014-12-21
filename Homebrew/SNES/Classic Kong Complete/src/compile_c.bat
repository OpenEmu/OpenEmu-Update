@echo off

set relname="Classic Kong Complete (U).smc"

rem convert C code only, without recompiling resources

REM C -> ASM / S
..\bin\816-tcc.exe -Wall -I../include -o game.ps1 -c game.c
rem pause

REM Optimize ASM files
..\bin\816-opt.py game.ps1 > game.s
rem ..\pypy-1.9\pypy.exe ..\bin\816-opt.py game.ps1 > game.s

rem tools\optimore-816.exe game.ps2 game.s

REM ASM -> OBJ
..\bin\wla-65816.exe -io game.s game.obj

REM OBJ -> SMC
..\bin\wlalink.exe -dvSo game.obj %relname%

pause

REM delete files
del *.ps1
del *.s
del *.obj
del *.sym
del stderr.txt
del stdout.txt

..\zsnesw151\zsnesw.exe %relname%
rem %relname%