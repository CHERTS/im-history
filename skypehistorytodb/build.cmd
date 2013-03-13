@echo off

set prg_name=.\..\..\Release\2.5.0\SkypeHistoryToDB-Setup-2.5.0.exe
set cert_path=.\..\..\Cert
call %cert_path%\cert.cmd

del /Q /F %prg_name%
"C:\Program Files\NSIS\makensis.exe" /DINNER setup_x86.nsi
signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% %prg_name%
