rem This batch file is used to quickly convert a .csv music file into a binary music file,
rem then reassemble the game using the new file and launch it in Mednafen for testing.

C:\Documents\2013kuroneko\projects\2013smscsvread\2013smscsvread\bin\release\2013smscsvread "C:\Documents\2013kuroneko\projects\2013z80\workons\gaiden\modules\excel_sms_module.csv" "C:\Documents\2013kuroneko\projects\2013z80\workons\gaiden\modules\musicmodule_output.bin"
xcopy /Y "C:\Documents\2013kuroneko\projects\2013z80\workons\gaiden\modules\musicmodule_output.bin" ".\musicmodule_output.bin"
call make.bat
"C:\Emulators\mednafen-0.9.28-wip-win32\mednafen.exe" ".\output.sms"
