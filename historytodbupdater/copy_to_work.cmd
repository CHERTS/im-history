@echo off

set prg_name=HistoryToDBUpdater.exe
call %cert_path%\vars.cmd
set cert_path=.\..\..\Cert
call %cert_path%\cert.cmd

if not exist .\..\..\Release\%ver%\x86 (
  mkdir .\..\..\Release\%ver%\x86
)
if not exist .\..\..\Release\%ver%\x64 (
  mkdir .\..\..\Release\%ver%\x64
)

call clear.bat

if exist Win32\Release\%prg_name% (
  upx.exe -9 Win32\Release\%prg_name%
  signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% Win32\Release\%prg_name%
  copy /Y Win32\Release\%prg_name% .\..\..\Release\%ver%\x86
)

if exist Win64\Release\%prg_name% (
  mpress.exe -b -x -r Win64\Release\%prg_name%
  signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% Win64\Release\%prg_name%
  copy /Y Win64\Release\%prg_name% .\..\..\Release\%ver%\x64
)

call clear.bat
