@echo off

set cert_path=.\..\..\Cert
call %cert_path%\vars.cmd
call %cert_path%\cert.cmd
set prg_name=.\..\..\Release\%ver%\SkypeHistoryToDB-Setup-%ver%.exe

del /Q /F %prg_name%
"C:\Program Files (x86)\NSIS\makensis.exe" /DINNER setup_x86.nsi
signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% %prg_name%
