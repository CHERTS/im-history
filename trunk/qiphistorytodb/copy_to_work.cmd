@echo off

set prg_name=QIPHistoryToDB.dll
set cert_path=.\..\..\Cert
call %cert_path%\vars.cmd
call %cert_path%\cert.cmd

if not exist .\..\..\Release\%ver%\x86 (
  mkdir .\..\..\Release\%ver%\x86
)

call clear.bat

if exist %prg_name% (
  upx.exe -9 %prg_name%
  signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% %prg_name%
  copy /Y %prg_name% .\..\..\Release\%ver%\x86
)

call clear.bat
