@echo off

rem compile spc700 code, also includes sample and effects data

path=path;tools\
del spc700.bin
pre spc700.asm
bass -arch=table -o spc700.bin spc700.s
rem pause
del spc700.s