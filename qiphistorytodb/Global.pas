{ ############################################################################ }
{ #                                                                          # }
{ #  QIP HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  Windows, SysUtils, IniFiles, Messages, XMLIntf, XMLDoc,
  FSMonitor, DCPcrypt2, DCPblockciphers, DCPsha1, DCPdes, DCPmd5;

type
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);

const
  PLUGIN_VER_MAJOR = 2;
  PLUGIN_VER_MINOR = 4;
  PLUGIN_NAME        : WideString = 'QIPHistoryToDB';
  PLUGIN_AUTHOR      : WideString = 'Michael Grigorev';
  PLUGIN_DESCRUPTION : WideString = 'Хранение истории сообщений в базе дынных.';
  PLUGIN_DESCRUPTION_EN : WideString = 'Storing the history in the database.';
  // Для поддержки автоматического обновления плагином QIP Manager
  PlugCheck_Dlink    : WideString = 'http://www.im-history.ru/get.php?file=QIPHistoryToDB-Update';
  PlugCheck_Ver      : WideString = '2.4.0.0';
  // End
  PluginName: WideString = 'QIPHistoryToDB';
  PluginSpecContactName: WideString = 'QIP HistoryToDB';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  ININame = 'HistoryToDB.ini';
  DefININame = 'DefaultUser.ini';
  MesLogName = 'HistoryToDBMes.sql';
  ErrLogName = 'HistoryToDBErr.log';
  ContactListName = 'ContactList.csv';
  ProtoListName = 'ProtoList.csv';
  DebugLogName = 'HistoryToDBDebug.log';
  MSG_LOG : WideString = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, ''%s'', ''%s'', ''%s'', null);';
  MSG_LOG_ORACLE : WideString = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, ''%s'', ''%s'', null)';
  CHAT_MSG_LOG : WideString = 'insert into uin_chat_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', null);';
  CHAT_MSG_LOG_ORACLE : WideString = 'insert into uin_chat_%s values (null, %s, %s, ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', null)';
  // Начальная дата (01/01/1970) Unix Timestamp для функций конвертации
  UnixStartDate: TDateTime = 25569.0;
  // Ключ для шифрования посылок программам HistoryToDBSync и HistoryToDBViewer
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // Для мультиязыковой поддержки
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  ThankYouText_Rus = 'Анна Никифорова за активное тестирование плагина.' + #13#10 +
                    'Кирилл Уксусов (UksusoFF) за активное тестирование плагина и новые идеи.' + #13#10 +
                    'Игорь Гурьянов за активное тестирование плагина.' + #13#10 +
                    'Вячеслав С. (HDHMETRO) за активное тестирование плагина.' + #13#10 +
                    'Providence за активное тестирование плагина и новые идеи.' + #13#10 +
                    'Cy6 за помощь в реализации импорта истории RnQ.';
  ThankYouText_Eng = 'Anna Nikiforova for active testing of plug-in.' + #13#10 +
                    'Kirill Uksusov (UksusoFF) for active testing of plug-in and new ideas.' + #13#10 +
                    'Igor Guryanov for active testing of plug-in.' + #13#10 +
                    'Vyacheslav S. (HDHMETRO) for active testing of plug-in.' + #13#10 +
                    'Providence for active testing of plug-in and new ideas.' + #13#10 +
                    'Cy6 for help in implementing the import history RnQ.';

type
  TCopyDataStruct = packed record
    dwData: DWORD;
    cbData: DWORD;
    lpData: Pointer;
  end;

var
  ERR_SAVE_TO_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение сообщений в БД невозможно.';
  ERR_TEMP_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение отложенных сообщений в БД невозможно.';
  ERR_READ_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_READ_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Чтение истории переписки невозможно.';
  ERR_LOAD_MSG_TO_DB : WideString = '[%s] Ошибка записи сообщений из лог-файла в БД: %s';
  ERR_SEND_UPDATE : WideString = '[%s] Ошибка при запросе обновления: %s';
  ERR_NO_FOUND_VIEWER : WideString = 'Просмотрщик истории %s не найден.';
  LOAD_TEMP_MSG : WideString = '[%s] В файле %s найдено %s сообщений; Загружено в БД: %s; Отбраковано: %s';
  LOAD_TEMP_MSG_NOLOGFILE : WideString = '[%s] Файл отложенных сообщений %s не найден.';
  WriteErrLog, AniEvents, EnableHistoryEncryption, ShowPluginButton, AddSpecialContact, BlockSpamMsg: Boolean;
  EnableDebug, EnableCallBackDebug, ExPrivateChatName, GetContactList: Boolean;
  SyncMethod, SyncInterval, SyncMessageCount, MaxErrLogSize: Integer;
  DBType, DBName, DBUserName, DefaultLanguage: String;
  Global_AccountUIN: WideString;
  Global_AccountName: WideString;
  Global_CurrentAccountUIN: WideString;
  Global_CurrentAccountName: WideString;
  Global_CurrentAccountProtoID: Integer;
  Global_CurrentAccountProtoName, Global_CurrentAccountProtoAccount: WideString;
  Glogal_History_Type: Integer;
  Global_ChatName: WideString;
  Global_AboutForm_Showing: Boolean;
  DllPath, ProfilePath: String;
  // Для мультиязыковой поддержки
  CoreLanguage: String;
  AboutFormHandle: HWND;
  LangDoc: IXMLDocument;
  PluginPath: String = '';
  // Шифрование
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // Лог-файлы
  TFMsgLog: TextFile;
  MsgLogOpened: Boolean;
  TFErrLog: TextFile;
  ErrLogOpened: Boolean;
  TFDebugLog: TextFile;
  DebugLogOpened: Boolean;
  TFContactListLog: TextFile;
  ContactListLogOpened: Boolean;
  TFProtoListLog: TextFile;
  ProtoListLogOpened: Boolean;

function BoolToIntStr(Bool: Boolean): String;
function UnixToDateTime(USec: Longint): TDateTime;
function PrepareString(const Source : PWideChar) : WideString;
function MatchStrings(Source, Pattern: String): Boolean;
function ReadCustomINI(INIPath, CustomParams, DefaultParamsStr: String): String;
function EncryptMD5(Str: String): String;
function EncryptStr(const Str: String): String;
function SearchMainWindow(MainWindowName: pWideChar): Boolean;
function OpenLogFile(LogPath: String; LogType: Integer): Boolean;
function GetMyFileSize(const Path: String): Integer;
function GetWindowsLanguage: String;
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure CloseLogFile(LogType: Integer);
procedure LoadINI(INIPath: String);
procedure OnSendMessageToAllComponent(Msg: String);
procedure OnSendMessageToOneComponent(WinName, Msg: String);
procedure WriteCustomINI(INIPath, CustomParams, ParamsStr: String);
procedure ProfileDirChangeCallBack(pInfo: TInfoCallBack);
procedure IMDelay(Value: Cardinal);
// Для мультиязыковой поддержки
procedure MsgDie(Caption, Msg: WideString);
procedure MsgInf(Caption, Msg: WideString);
function GetLangStr(StrID: String): WideString;

implementation

function BoolToIntStr(Bool: Boolean): String;
begin
  if Bool then
    Result := '1'
  else
    Result := '0'
end;

// Функция конвертации Unix Timestamp в DateTime
function UnixToDateTime(USec: Longint): TDateTime;
begin
  Result := (Usec / 86400) + UnixStartDate;
end;

// Функция для экранирования спецсимволов в строке
function PrepareString(const Source : PWideChar) : WideString;
var
  SLen,i : Cardinal;
  WSTmp : WideString;
  WChar : WideChar;
begin
 Result := '';
 SLen := Length(WideString(Source));
 if (SLen>0) then
  begin
   for i:=1 to SLen do
    begin
     WChar:=WideString(Source)[i];
     case WChar of
      #$09 :{tab}  WSTmp:=WSTmp+'\t';
      #$0A :{line feed}  WSTmp:=WSTmp+'\n';
      #$0D :{carriage return}  WSTmp:=WSTmp+'\r';
      #$27 :{single quote mark aka apostrophe?} WSTmp:=WSTmp+WChar+WChar;
      #$22, {double quote mark aka inch sign?}
      #$5C, {backslash itself}
      #$60 :{another single quote mark} WSTmp:=WSTmp+'\'+WChar;
      else WSTmp := WSTmp + WChar;
     end;
    end;
   Result := WSTmp;
  end;
end;

// LogType = 0 - сообщения добавляются в файл MesLogName
// LogType = 1 - ошибки добавляются в файл ErrLogName
// LogType = 2 - сообщения добавляются в файл DebugLogName
// LogType = 3 - сообщения добавляются в файл ContactListName
// LogType = 4 - сообщения добавляются в файл ProtoListName
function OpenLogFile(LogPath: String; LogType: Integer): Boolean;
var
  Path: WideString;
begin
  if LogType = 0 then
    Path := LogPath + MesLogName
  else if LogType = 1 then
  begin
    Path := LogPath + ErrLogName;
    if (LogType > 0) and (GetMyFileSize(Path) > MaxErrLogSize*1024) then
      DeleteFile(Path);
  end
  else if LogType = 2 then
    Path := LogPath + DebugLogName
  else if LogType = 3 then
    Path := LogPath + ContactListName
  else
    Path := LogPath + ProtoListName;
  {$I-}
  try
    if LogType = 0 then
      Assign(TFMsgLog, Path)
    else if LogType = 1 then
      Assign(TFErrLog, Path)
    else if LogType = 2 then
      Assign(TFDebugLog, Path)
    else if LogType = 3 then
      Assign(TFContactListLog, Path)
    else
      Assign(TFProtoListLog, Path);
    if FileExists(Path) then
    begin
      if LogType = 0 then
        Append(TFMsgLog)
      else if LogType = 1 then
        Append(TFErrLog)
      else if LogType = 2 then
        Append(TFDebugLog)
      else if LogType = 3 then
        Append(TFContactListLog)
      else
        Append(TFProtoListLog);
    end
    else
    begin
      if LogType = 0 then
        Rewrite(TFMsgLog)
      else if LogType = 1 then
        Rewrite(TFErrLog)
      else if LogType = 2 then
        Rewrite(TFDebugLog)
      else if LogType = 3 then
        Rewrite(TFContactListLog)
      else
        Rewrite(TFProtoListLog);
    end;
    Result := True;
  except
    on e :
      Exception do
      begin
        CloseLogFile(LogType);
        Result := False;
        Exit;
      end;
  end;
  {$I+}
end;

// LogType = 0 - сообщения добавляются в файл MesLogName
// LogType = 1 - ошибки добавляются в файл ErrLogName
// LogType = 2 - сообщения добавляются в файл DebugLogName
// LogType = 3 - сообщения добавляются в файл ContactListName
// LogType = 4 - сообщения добавляются в файл ProtoListName
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
var
  Path: WideString;
begin
  if LogType = 0 then
  begin
    if not MsgLogOpened then
      MsgLogOpened := OpenLogFile(LogPath, 0);
    Path := LogPath + MesLogName
  end
  else if LogType = 1 then
  begin
    if not ErrLogOpened then
      ErrLogOpened := OpenLogFile(LogPath, 1);
    Path := LogPath + ErrLogName;
    if (LogType > 0) and (GetMyFileSize(Path) > MaxErrLogSize*1024) then
    begin
      CloseLogFile(LogType);
      DeleteFile(Path);
      if not OpenLogFile(LogPath, LogType) then
        Exit;
    end;
  end
  else if LogType = 2 then
  begin
    if not DebugLogOpened then
      DebugLogOpened := OpenLogFile(LogPath, 2);
    Path := LogPath + DebugLogName;
  end
  else if LogType = 3 then
  begin
    if not ContactListLogOpened then
      ContactListLogOpened := OpenLogFile(LogPath, 3);
    Path := LogPath + ContactListName;
  end
  else
  begin
    if not ProtoListLogOpened then
      ProtoListLogOpened := OpenLogFile(LogPath, 4);
    Path := LogPath + ProtoListName;
  end;
  {$I-}
  try
    if LogType = 0 then
      WriteLn(TFMsgLog, TextString)
    else if LogType = 1 then
      WriteLn(TFErrLog, TextString)
    else if LogType = 2 then
      WriteLn(TFDebugLog, TextString)
    else if LogType = 3 then
      WriteLn(TFContactListLog, TextString)
    else
      WriteLn(TFProtoListLog, TextString);
  except
    on e :
      Exception do
      begin
        CloseLogFile(LogType);
        Exit;
      end;
  end;
  if MsgLogOpened then
    CloseLogFile(0);
  {$I+}
end;

procedure CloseLogFile(LogType: Integer);
begin
  {$I-}
  if LogType = 0 then
  begin
    CloseFile(TFMsgLog);
    MsgLogOpened := False;
  end
  else if LogType = 1 then
  begin
    CloseFile(TFErrLog);
    ErrLogOpened := False;
  end
  else if LogType = 2 then
  begin
    CloseFile(TFDebugLog);
    DebugLogOpened := False;
  end
  else if LogType = 3 then
  begin
    CloseFile(TFContactListLog);
    ContactListLogOpened := False;
  end
  else
  begin
    CloseFile(TFProtoListLog);
    ProtoListLogOpened := False;
  end;
  {$I+}
end;

// Если файл не существует, то вместо размера файла функция вернёт -1
function GetMyFileSize(const Path: String): Integer;
var
  FD: TWin32FindData;
  FH: THandle;
begin
  FH := FindFirstFile(PChar(Path), FD);
  Result := 0;
  if FH = INVALID_HANDLE_VALUE then
    Exit;
  Result := FD.nFileSizeLow;
  if ((FD.nFileSizeLow and $80000000) <> 0) or
     (FD.nFileSizeHigh <> 0) then
    Result := -1;
  //FindClose(FH);
end;

// Загружаем настройки
procedure LoadINI(INIPath: String);
var
  Path: WideString;
  Temp: String;
  INI: TIniFile;
begin
  // Проверяем наличие каталога
  if not DirectoryExists(INIPath) then
    CreateDir(INIPath);
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
   Ini := TIniFile.Create(Path);
   DBType := INI.ReadString('Main', 'DBType', 'mysql');  // mysql или postgresql
   DBUserName := INI.ReadString('Main', 'DBUserName', 'username');
   SyncMethod := INI.ReadInteger('Main', 'SyncMethod', 1);
   SyncInterval := INI.ReadInteger('Main', 'SyncInterval', 0);

   Temp := INI.ReadString('Main', 'WriteErrLog', '1');
   if Temp = '1' then WriteErrLog := True
   else WriteErrLog := False;

   Temp := INI.ReadString('Main', 'ShowAnimation', '1');
   if Temp = '1' then AniEvents := True
   else AniEvents := False;

   Temp := INI.ReadString('Main', 'EnableHistoryEncryption', '0');
   if Temp = '1' then EnableHistoryEncryption := True
   else EnableHistoryEncryption := False;

   Temp := INI.ReadString('Main', 'AddSpecialContact', '1');
   if Temp = '1' then AddSpecialContact := True
   else AddSpecialContact := False;

   DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'Russian');
   SyncMessageCount := INI.ReadInteger('Main', 'SyncMessageCount', 50);

   Temp := INI.ReadString('Main', 'ShowPluginButton', '1');
   if Temp = '1' then ShowPluginButton := True
   else ShowPluginButton := False;

   Temp := INI.ReadString('Main', 'BlockSpamMsg', '0');
   if Temp = '1' then BlockSpamMsg := True
   else BlockSpamMsg := False;

   Temp := INI.ReadString('Main', 'EnableExPrivateChatName', '0');
   if Temp = '1' then ExPrivateChatName := True
   else ExPrivateChatName := False;

   Temp := INI.ReadString('Main', 'EnableDebug', '0');
   if Temp = '1' then EnableDebug := True
   else EnableDebug := False;

   Temp := INI.ReadString('Main', 'EnableCallBackDebug', '0');
   if Temp = '1' then EnableCallBackDebug := True
   else EnableCallBackDebug := False;

   MaxErrLogSize := INI.ReadInteger('Main', 'MaxErrLogSize', 20);
  end
 else
  begin
    INI := TIniFile.Create(path);
    // Значения по-умолчанию
    DBType := 'mysql';
    DBName := DefaultDBName;
    DBUserName := 'username';
    SyncMethod := 1;
    SyncInterval := 0;
    SyncMessageCount := 50;
    WriteErrLog := True;
    AniEvents := True;
    ShowPluginButton := True;
    EnableHistoryEncryption := False;
    AddSpecialContact := True;
    BlockSpamMsg := False;
    EnableDebug := False;
    EnableCallBackDebug := False;
    MaxErrLogSize := 20;
    // Сохраняем настройки
    INI.WriteString('Main', 'DBType', DBType);
    INI.WriteString('Main', 'DBAddress', DefaultDBAddres);
    INI.WriteString('Main', 'DBSchema', 'username');
    INI.WriteString('Main', 'DBPort', '3306');
    INI.WriteString('Main', 'DBName', DefaultDBName);
    INI.WriteString('Main', 'DBUserName', DBUserName);
    INI.WriteString('Main', 'DBPasswd', 'skGvQNyWUHcHohJS2+2r4A==');
    INI.WriteInteger('Main', 'SyncMethod', SyncMethod);
    INI.WriteInteger('Main', 'SyncInterval', SyncInterval);
    INI.WriteInteger('Main', 'SyncTimeCount', 40);
    INI.WriteInteger('Main', 'SyncMessageCount', SyncMessageCount);
    INI.WriteInteger('Main', 'NumLastHistoryMsg', 6);
    INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
    INI.WriteString('Main', 'ShowAnimation', BoolToIntStr(AniEvents));
    INI.WriteString('Main', 'EnableHistoryEncryption', BoolToIntStr(EnableHistoryEncryption));
    INI.WriteString('Main', 'DefaultLanguage', 'Russian');
    INI.WriteString('Main', 'HideHistorySyncIcon', '0');
    INI.WriteString('Main', 'ShowPluginButton', BoolToIntStr(ShowPluginButton));
    INI.WriteString('Main', 'AddSpecialContact', BoolToIntStr(AddSpecialContact));
    INI.WriteString('Main', 'BlockSpamMsg', BoolToIntStr(BlockSpamMsg));
    INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
    INI.WriteString('Main', 'AlphaBlend', '0');
    INI.WriteString('Main', 'AlphaBlendValue', '255');
    INI.WriteString('Main', 'EnableDebug', '0');
    INI.WriteString('Main', 'EnableCallBackDebug', '0');
    INI.WriteString('Fonts', 'FontInTitle', '183|-11|Verdana|0|96|8|Y|N|N|N|');
    INI.WriteString('Fonts', 'FontOutTitle', '8404992|-11|Verdana|0|96|8|Y|N|N|N|');
    INI.WriteString('Fonts', 'FontInBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
    INI.WriteString('Fonts', 'FontOutBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
    INI.WriteString('Fonts', 'FontService', '16711680|-11|Verdana|0|96|8|Y|N|N|N|');
    INI.WriteString('Fonts', 'TitleParagraph', '4|4|');
    INI.WriteString('Fonts', 'MessagesParagraph', '2|2|');
    INI.WriteString('HotKey', 'GlobalHotKey', '0');
    INI.WriteString('HotKey', 'SyncHotKey', 'Ctrl+Alt+F12');
    INI.WriteString('HotKey', 'ExSearchHotKey', 'Ctrl+F3');
    INI.WriteString('HotKey', 'ExSearchNextHotKey', 'F3');
  end;
  INI.Free;
end;

{ Процедура записи значения параметра в файл настроек }
procedure WriteCustomINI(INIPath, CustomParams, ParamsStr: String);
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
    INI := TIniFile.Create(Path);
    try
      INI.WriteString('Main', CustomParams, ParamsStr);
    finally
      INI.Free;
    end;
  end
  else
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура WriteCustomINI: ' + GetLangStr('SettingsErrSave'), 2);
    MsgDie(PluginName, GetLangStr('SettingsErrSave'));
  end;
end;

{ Функция чтения значения параметра из файла настроек }
function ReadCustomINI(INIPath, CustomParams, DefaultParamsStr: String): String;
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
    INI := TIniFile.Create(Path);
    try
      Result := INI.ReadString('Main', CustomParams, DefaultParamsStr);
    finally
      INI.Free;
    end;
  end
  else
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ReadCustomINI: ' + GetLangStr('SettingsErrRead'), 2);
    MsgDie(PluginName, GetLangStr('SettingsErrRead'));
  end;
end;

{ Процедура для отправки сообщений программе }
{ Стандартные команды:
  001  - Перечитать настройки из файла HistoryToDB.ini
  002  - Синхронизация истории
  003  - Закрыть все компоненты плагина
  0040 - Показать все окна плагина (Режим AntiBoss)
  0041 - Скрыть все окна плагина (Режим AntiBoss)
  0050 - Запустить перерасчет MD5-хешей
  0051 - Запустить перерасчет MD5-хешей и удаления дубликатов
  0060 - Запущен импорт истории
  0061 - Импорт истории завершен
  007  - Обновить контакт-лист в БД
  008  - Показать историю контакта/чата
         Формат команды:
           для истории контакта:
             008|0|UserID|UserName|ProtocolType
           для истории чата:
             008|2|ChatName
  009 - Экстренно закрыть все компоненты плагина.
}
procedure OnSendMessageToAllComponent(Msg: String);
var
  HToDB: HWND;
  copyDataStruct : TCopyDataStruct;
  EncryptMsg: String;
begin
  EncryptMsg := EncryptStr(Msg);
  // Ищем окно HistoryToDBViewer и посылаем ему команду
  HToDB := FindWindow(nil,'HistoryToDBViewer for QIP');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  // Ищем окно HistoryToDBSync и посылаем ему команду
  HToDB := FindWindow(nil,'HistoryToDBSync for QIP');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  // Ищем окно HistoryToDBImport и посылаем ему команду
  HToDB := FindWindow(nil,'HistoryToDBImport for QIP');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  // Ищем окно HistoryToDBUpdater и посылаем ему команду
  HToDB := FindWindow(nil,'HistoryToDBUpdater for QIP');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
end;

procedure OnSendMessageToOneComponent(WinName, Msg: String);
var
  HToDB: HWND;
  copyDataStruct : TCopyDataStruct;
  EncryptMsg: String;
begin
  EncryptMsg := EncryptStr(Msg);
  // Ищем окно HistoryToDBViewer и посылаем ему команду
  HToDB := FindWindow(nil, pChar(WinName));
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
end;

{ Поиск окна программы }
function SearchMainWindow(MainWindowName: pWideChar): Boolean;
var
  HToDB: HWND;
begin
  // Ищем окно
  HToDB := FindWindow(nil, MainWindowName);
  if HToDB <> 0 then
    Result := True
  else
    Result := False
end;

{Функция осуществляет сравнение двух строк. Первая строка
может быть любой, но она не должна содержать символов соответствия (* и ?).
Строка поиска (искомый образ) может содержать абсолютно любые символы.
Для примера: MatchStrings('David Stidolph','*St*') возвратит True.
Автор оригинального C-кода Sean Stanley
Автор портации на Delphi David Stidolph}
function MatchStrings(Source, Pattern: String): Boolean;
var
  pSource: array[0..255] of Char;
  pPattern: array[0..255] of Char;

  function MatchPattern(element, pattern: PChar): Boolean;

  function IsPatternWild(pattern: PChar): Boolean;
  begin
    Result := StrScan(pattern, '*') <> nil;
    if not Result then
      Result := StrScan(pattern, '?') <> nil;
  end;

  begin
    if 0 = StrComp(pattern, '*') then
      Result := True
    else if (element^ = Chr(0)) and (pattern^ <> Chr(0)) then
      Result := False
    else if element^ = Chr(0) then
      Result := True
    else
    begin
      case pattern^ of
        '*': if MatchPattern(element, @pattern[1]) then
            Result := True
          else
            Result := MatchPattern(@element[1], pattern);
        '?': Result := MatchPattern(@element[1], @pattern[1]);
      else
        if element^ = pattern^ then
          Result := MatchPattern(@element[1], @pattern[1])
        else
          Result := False;
      end;
    end;
  end;
begin
  StrPCopy(pSource, source);
  StrPCopy(pPattern, pattern);
  Result := MatchPattern(pSource, pPattern);
end;

// Для мультиязыковой поддержки
procedure MsgDie(Caption, Msg: WideString);
begin
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONERROR);
end;

// Для мультиязыковой поддержки
procedure MsgInf(Caption, Msg: WideString);
begin
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONINFORMATION);
end;

// Для мультиязыковой поддержки
function GetLangStr(StrID: String): WideString;
begin
  if (not Assigned(LangDoc)) or (not LangDoc.Active) then
  begin
    Result := '';
    Exit;
  end;
  if LangDoc.ChildNodes['strings'].ChildNodes.FindNode(StrID) <> nil then
    Result := LangDoc.ChildNodes['strings'].ChildNodes[StrID].Text
  else
    Result := 'String not found.';
end;

{ Обработчик изменений файлов в каталоге профиля }
procedure ProfileDirChangeCallBack(pInfo: TInfoCallBack);
var
  SettingsFormRequest: String;
begin
  SettingsFormRequest := ReadCustomINI(ProfilePath, 'SettingsFormRequestSend', '0');
  if EnableCallBackDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ProfileDirChangeCallBack: Параметр SettingsFormRequestSend = ' + SettingsFormRequest, 2);
  if EnableCallBackDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ProfileDirChangeCallBack: FAction = ' + IntToStr(pInfo.FAction) + ' | FOldFileName = ' + pInfo.FOldFileName + ' | FNewFileName = ' + pInfo.FNewFileName, 2);
  if (pInfo.FAction = 3) and (pInfo.FNewFileName = 'HistoryToDB.ini') and (SettingsFormRequest = '0') then
  begin
    if EnableCallBackDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ProfileDirChangeCallBack: Настройки HistoryToDB.ini перечитаны', 2);
    IMDelay(500);
    LoadINI(ProfilePath);
  end;
end;

// Подсчет MD5 строки
function EncryptMD5(Str: String): String;
var
  Hash: TDCP_md5;
  Digest: Array[0..15] of Byte;
  I: Integer;
  P: String;
begin
  if Str <> '' then
  begin
    Hash:= TDCP_md5.Create(nil);
    try
      Hash.HashSize := 128;
      Hash.Init;
      Hash.UpdateStr(Str);
      Hash.Final(Digest);
      P := '';
      for I:= 0 to 15 do
        P:= P + IntToHex(Digest[I], 2);
    finally
      Hash.Free;
    end;
    Result := P;
  end
  else
    Result := 'MD5';
end;

// Инициируем криптование
procedure EncryptInit;
begin
  Hash:= TDCP_sha1.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(EncryptKey);
    Hash.Final(Digest);
  finally
    Hash.Free;
  end;
  Cipher := TDCP_3des.Create(nil);
  try
    Cipher.Init(Digest,Sizeof(Digest)*8,nil);
  except
    on E: Exception do
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура EncryptInit: ' + E.Message, 2);
  end;
end;

// Освобождаем ресурсы
procedure EncryptFree;
begin
  if Assigned(Cipher) then
  begin
    Cipher.Burn;
    Cipher.Free;
  end;
end;

// Зашифровываем строку
function EncryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.EncryptString(Str);
  end;
end;

{ Задержка не грузящая процессор }
procedure IMDelay(Value: Cardinal);
var
  F, N: Cardinal;
begin
  N := 0;
  while N <= (Value div 10) do
  begin
    SleepEx(1, True);
    //Application.ProcessMessages;
    Inc(N);
  end;
  F := GetTickCount;
  repeat
    //Application.ProcessMessages;
    N := GetTickCount;
  until (N - F >= (Value mod 10)) or (N < F);
end;

function GetWindowsLanguage: String;
var
  WinLanguage: Array [0..50] of Char;
begin
  VerLanguageName(GetSystemDefaultLangID, WinLanguage, 50);
  Result := StrPas(WinLanguage);
end;

end.
