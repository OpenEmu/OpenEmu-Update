@echo off
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem ::             WLA DX compiling batch file v3              ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Do not edit anything unless you know what you're doing! ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set WLAPATH=C:\Documents\2013kuroneko\projects\2013z80\devtools\wladx\

rem Cleanup to avoid confusion
if exist object.o del object.o

rem Compile
rem "%WLAPATH%wla-z80.exe" -xo %1 object.o I don't want the parameterised version -matt
"%WLAPATH%wla-z80.exe" -xo game.z80asm object.o

rem Make linkfile
echo [objects]>linkfile
echo object.o>>linkfile

rem Link
"%WLAPATH%wlalink.exe" -drvs linkfile output.sms

rem Fixup for eSMS
if exist output.sms.sym del output.sms.sym
ren output.sym output.sms.sym

rem Cleanup to avoid mess
if exist linkfile del linkfile
if exist object.o del object.o
