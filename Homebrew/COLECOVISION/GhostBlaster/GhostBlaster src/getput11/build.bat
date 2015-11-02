@echo off
echo COMPILING ALL SOURCE FILES
FOR %%c in (./*.s) DO as-z80 -o %%c.o %%c
echo COMPILE LIBRARY
FOR %%c in (./*.o) DO sdcclib getput.lib %%c
echo COPY GENERATED FILES
copy getput.lib ..
copy getput1.h ..
echo CLEAN UP
del *.o
del getput.lib
