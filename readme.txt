Структура каталогов для сборки проекта:

IM-History
 | 
 |-Cert
 |    |-cert.cmd
 |    |-vars.cmd
 |    |-sign.pfx
 |
 |-Release
 |       |-2.4.0
 |       |     |....
 |       |
 |       |-2.5.0
 |             |-x86
 |             |   |-langs
 |             |   |     |-Russian.xml
 |             |   |     |-English.xml
 |             |   |
 |             |   |-skype
 |             |   |     |-changelog.txt
 |             |   |     |-HistoryToDB.ini
 |             |   |     |-imhistory.sqlite
 |             |   |     |-installupdater-en.cmd
 |             |   |     |-installupdater-ru.cmd
 |             |   |     |-readme.txt
 |             |   |     |-Skype4COM.dll
 |             |   |     |-start_sync.cmd
 |             |   |     |-start_viewer.cmd
 |             |   |     |-update.txt
 |             |   |
 |             |   |-sql
 |             |   |   |-Link to SVN\sql
 |             |   |
 |             |   |-update
 |             |   |      |-Link to SVN\update
 |             |   |
 |             |   |-faq.txt
 |             |   |-fbclient.dll
 |             |   |-firebird.msg
 |             |   |-sqlite3.dll
 |             |   |-ssleay32.dll
 |             |   |-libeay32.dll
 |             |   |-libintl.dll
 |             |   |-libmysql.dll
 |             |   |-libpq.dll
 |             |   |-msvcr100.dll
 |             |   |-MirandaHistoryToDB.dll
 |             |   |-MirandaNGHistoryToDB.dll
 |             |   |-QIPHistoryToDB.dll
 |             |   |-RnQHistoryToDB.dll
 |             |   |-HistoryToDBImport.exe
 |             |   |-HistoryToDBSync.exe
 |             |   |-HistoryToDBUpdater.exe
 |             |   |-HistoryToDBViewer.exe
 |             |   |-uninstall.ico
 |             |
 |             |-x64
 |                 |-langs
 |                 |     |-Russian.xml
 |                 |     |-English.xml
 |                 |
 |                 |-skype
 |                 |     |....
 |                 |
 |                 |-sql
 |                 |   |....
 |                 |
 |                 |-update
 |                         |....
 |
 |-SVN
     |-components
     |-historytodbcreatedb
     |-historytodbimport
     |-historytodbsync
     |-historytodbupdater
     |-historytodbviewer
     |-icons
     |-langs
     |-mirandahistorytodb
     |-mirandanghistorytodb
     |-qiphistorytodb
     |-rnqhistorytodb
     |-skypehistorytodb
     |-sql
     |-update
     |-readme.txt


Файл cert.cmd - устанавливает переменные для подписи программ.
Содержимое cert.cmd:
@echo off
set cert_pw=mysecretpw
set cert_name=sign.pfx
set cert_url=http://time.certum.pl/authenticode

Файл vars.cmd - устанавливает переменные для сборки.
Содержимое vars.cmd:
@echo off
set ver=2.6.0
  
Файл sign.pfx - контейнер с приватным и публичным ключом для подписи программ.
