@echo off

set prg_name=HistoryToDBCreateDB.exe
set cert_path=.\..\..\Cert
call %cert_path%\vars.cmd
call %cert_path%\cert.cmd

if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x86 (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x86
)
if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x64 (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x64
)
if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\langs (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\langs
)
if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x64\langs (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x64\langs
)
if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\sql (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\sql
)
if not exist .\..\..\Release\%ver%\HistoryToDBCreateDB\x64\sql (
  mkdir .\..\..\Release\%ver%\HistoryToDBCreateDB\x64\sql
)

call clear.bat

if exist Win32\Release\%prg_name% (
  upx.exe -9 Win32\Release\%prg_name%
  signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% Win32\Release\%prg_name%
  copy /Y Win32\Release\%prg_name% .\..\..\Release\%ver%\HistoryToDBCreateDB\x86
  copy /Y langs\*.xml .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\langs
  copy /Y sql\*.sql .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\sql
)

if exist Win64\Release\%prg_name% (
  mpress.exe -b -x -r Win64\Release\%prg_name%
  signtool.exe sign /f "%cert_path%\%cert_name%" /p %cert_pw% /t %cert_url% Win64\Release\%prg_name%
  copy /Y Win64\Release\%prg_name% .\..\..\Release\%ver%\HistoryToDBCreateDB\x64
  copy /Y langs\*.xml .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\langs
  copy /Y sql\*.sql .\..\..\Release\%ver%\HistoryToDBCreateDB\x86\sql
)

call clear.bat
