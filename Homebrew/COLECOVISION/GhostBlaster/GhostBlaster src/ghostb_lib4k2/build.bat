@echo off
echo COMPILING ALL SOURCE FILES
FOR %%c in (./*.s) DO as-z80 -o %%c.o %%c
copy crtcv.s.o ..\crtcv.o
del crtcv.s.o
echo COMPILE LIBRARY
FOR %%c in (./*.o) DO sdcclib cvlib.lib %%c
echo COPY GENERATED FILES
copy cvlib.lib ..
copy coleco.h ..
echo CLEAN UP
del *.o
del cvlib.lib
pause