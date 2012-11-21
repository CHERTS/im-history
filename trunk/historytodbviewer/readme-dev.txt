HistoryToDBViewer
-----------------

Просмотрщик истории для серии плагинов *HistoryToDB (RnQHistoryToDB, QIPHistoryToDB, MirandaHistoryToDB)

Автор:		Михаил Григорьев
E-Mail: 	sleuthhound@gmail.com
ICQ: 		161867489
WWW:		http://www.im-history.ru
Лицензия:	GNU GPLv3

Системные требования:
---------------------
ОС:		Win2000/XP/2003/Vista/7
IM-клиент:	Любой
БД:		MySQL 4.0, 4.1, 5.0, 5.1
		PostgreSQL 7.1 - 8.3
		Oracle 8i - 11i
		SQLite 3

Необходимые компоненты для сборки плагина:
------------------------------------------

1. Embarcadero RAD Studio XE3

2. ZeosLib 7.0.0-alpha
   http://www.sourceforge.net/projects/zeoslib

3. DevART VirtualTable
   http://www.devart.com/vtable/

4. JEDI Core + JEDI VCL
   http://www.delphi-jedi.org

5. DCPcrypt Cryptographic Component Library v2
   http://www.cityinthesky.co.uk/

6. IM-History Button Group Component
   See also directory IMButtonGroupComponent 

7. DateTimePickerEx Component
   See also directory DTPEx

Описание параметров запуска:
----------------------------

HistoryToDBViewer.exe <1> <2> <3> <4> <5> <6> <7> 

<1> - (Обязательный параметр) - Путь до файла плагина *HistoryToDB.dll (Например: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")

<2> - (Обязательный параметр) - Путь до файла настроек *HistoryToDB.dll (Например: "C:\Program Files\QIP Infium\Profiles\sleuthhound@qip.ru\Plugins\QIPHistoryToDB\")

<3> - (Необязательный параметр) - Режим работы.
      Возможные значения:
      0 - Просмотр истории сообщений
      2 - Просмотр истории чата
      4 - Показать окно настроек программы

<4> - (Необязательный параметр) - Наше UIN (Например: vasua@qip.ru)

<5> - (Необязательный параметр) - Наше Имя (Например: Вася Пупкин)

Если пареметр <3> = 0, то

<6> - (Необязательный параметр) - UIN контакта для просмотра истории (Например: myfriend@qip.ru)

<7> - (Необязательный параметр) - Имя контакта для просмотра истории (Например: Мой друг)

Если пареметр <3> = 2, то

<6> - (Необязательный параметр) - Название чата для просмотра истории (Например: Мой чат)
