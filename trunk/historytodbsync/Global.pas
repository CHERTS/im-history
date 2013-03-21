{ ############################################################################ }
{ #                                                                          # }
{ #  Импорт истории HistoryToDBSync v2.4                                     # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  Windows, Forms, Classes, SysUtils, IniFiles, DCPcrypt2, DCPblockciphers, DCPsha1,
  DCPdes, DCPmd5, TypInfo, Messages, XMLIntf, XMLDoc;

type
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);

const
  ProgramsName = 'HistoryToDBSync';
  ProgramsVer : WideString = '2.5.0.0';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  IniName = 'HistoryToDB.ini';
  ErrLogName = 'HistoryToDBSyncErr.log';
  MesLogName = 'HistoryToDBMes.sql';
  ImportLogName = 'HistoryToDBImport.sql';
  DublicateLogName = 'HistoryToDBDublicate.log';
  ContactListName = 'ContactList.csv';
  ProtoListName = 'ProtoList.csv';
  DebugLogName = 'HistoryToDBSyncDebug.log';
  SkypeDebugLogName = 'HistoryToDBSyncSkypeDebug.log';
  MSG_LOG : WideString = 'insert into uin_%s values (null, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'');';
  MSG_LOG_ORACLE : WideString = 'insert into uin_%s values (null, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')';
  CHAT_MSG_LOG : WideString = 'insert into uin_chat_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', ''%s'');';
  CHAT_MSG_LOG_ORACLE : WideString = 'insert into uin_chat_%s values (null, %s, %s, ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', ''%s'')';
  SKYPE_CHAT_MSG_LOG : WideString = 'insert into uin_chat_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', null);';
  SKYPE_CHAT_MSG_LOG_ORACLE : WideString = 'insert into uin_chat_%s values (null, %s, %s, ''%s'', ''%s'', ''%s'', %s, %s, %s, ''%s'', ''%s'', null)';
  // Начальная дата (01/01/1970) Unix Timestamp для функций конвертации
  UnixStartDate: TDateTime = 25569.0;
  // Ключь для расшифровки параметра DBPasswd из конфига
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // Для мультиязыковой поддержки
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  // End
  WM_MSGBOX = WM_USER + 2;
  ThankYouText_Rus ='Анна Никифорова за активное тестирование плагина.' + #13#10 +
                    'Кирилл Уксусов (UksusoFF) за активное тестирование плагина и новые идеи.' + #13#10 +
                    'Игорь Гурьянов за активное тестирование плагина.' + #13#10 +
                    'Вячеслав С. (HDHMETRO) за активное тестирование плагина.' + #13#10 +
                    'Providence за активное тестирование плагина и новые идеи.' + #13#10 +
                    'Cy6 за помощь в реализации импорта истории RnQ.';
  ThankYouText_Eng ='Anna Nikiforova for active testing of plug-in.' + #13#10 +
                    'Kirill Uksusov (UksusoFF) for active testing of plug-in and new ideas.' + #13#10 +
                    'Igor Guryanov for active testing of plug-in.' + #13#10 +
                    'Vyacheslav S. (HDHMETRO) for active testing of plug-in.' + #13#10 +
                    'Providence for active testing of plug-in and new ideas.' + #13#10 +
                    'Cy6 for help in implementing the import history RnQ.';
  SkypeProtocol = 8;
  {$IFDEF WIN32}
  PlatformType = 'x86';
  {$ELSE}
  PlatformType = 'x64';
  {$ENDIF}

var
  ERR_SAVE_TO_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение сообщений в БД невозможно.';
  ERR_TEMP_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение отложенных сообщений в БД невозможно.';
  ERR_READ_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_READ_DB_SERVICE_MODE : WideString = '[%s] Ошибка: Невозможно выполнить операцию. БД на сервисном обслуживании.';
  ERR_LOAD_MSG_TO_DB : WideString = '[%s] Ошибка записи сообщений из лог-файла в БД: %s';
  ERR_SEND_UPDATE : WideString = '[%s] Ошибка при запросе обновления: %s';
  ERR_NO_DB_CONNECTED : WideString = '[%s] Соединение с БД не установлено.';
  LOAD_TEMP_MSG : WideString = '[%s] В файле %s найдено %s сообщений; Загружено в БД: %s; Отбраковано: %s; Из них дубликатов: %s';
  LOAD_TEMP_MSG_SCREEN : WideString = 'Найдено %s сообщений; Загружено в БД: %s; Отбраковано: %s; Из них дубликатов: %s';
  LOAD_TEMP_MSG_NOLOGFILE : WideString = '[%s] Файл отложенных сообщений %s не найден.';
  LOAD_TEMP_MSG_NOMSGFILE : WideString = 'Файл сообщений %s не найден.';
  WriteErrLog, AniEvents, EnableHistoryEncryption, HideSyncIcon: Boolean;
  GlobalHotKeyEnable, EnableDebug, AlphaBlendEnable, SyncWhenExit, GlobalSkypeSupport, GlobalSkypeSupportOnRun: Boolean;
  SyncMethod, SyncInterval, NumLastHistoryMsg, SyncTimeCount: Integer;
  MaxErrLogSize, AlphaBlendEnableValue: Integer;
  ReconnectInterval, ReconnectCount: Integer;
  DBType, DBAddress, DBSchema, DBPort, DBName, DBUserName, DBPasswd, DefaultLanguage, IMClientType: String;
  Global_AccountUIN, Global_AccountName, Global_CurrentAccountUIN, Global_CurrentAccountName: WideString;
  Glogal_History_Type, Glogal_Selected_History_Type: Integer;
  Global_ChatName: WideString;
  PluginPath, ProfilePath: WideString;
  Global_MainForm_Showing, Global_LogForm_Showing, Global_AboutForm_Showing, Global_KeyPasswdForm_Showing: Boolean;
  Global_AutoRunHistoryToDBSync, Global_RunningSkypeOnStartup, Global_ExitSkypeOnEnd: Boolean;
  EncryptionKey, EncryptionKeyID, SyncHotKey, MyAccount: String;
  KeyPasswdSaveOnlySession, KeyPasswdSave: Boolean;
  // Шифрование
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // Для мультиязыковой поддержки
  CoreLanguage: String;
  MainFormHandle: HWND;
  SettingsFormHandle: HWND;
  AboutFormHandle: HWND;
  LogFormHandle: HWND;
  KeyPasswdFormHandle: HWND;
  LangDoc: IXMLDocument;

function BoolToIntStr(Bool: Boolean): String;
function IsNumber(const S: String): Boolean;
function DateTimeToUnix(ConvDate: TDateTime): Longint;
function UnixToDateTime(USec: Longint): TDateTime;
function PrepareString(const Source : PWideChar) : AnsiString;
function EncryptStr(const Str: String): String;
function DecryptStr(const Str: String): String;
function EncryptMD5(Str: String): String;
function MatchStrings(source, pattern: String): Boolean;
function ExtractFileNameEx(FileName: String; ShowExtension: Boolean): String;
function ReadCustomINI(INIPath, CustomSection, CustomParams, DefaultParamsStr: String): String;
function GetSystemDefaultUILanguage: UINT; stdcall; external kernel32 name 'GetSystemDefaultUILanguage';
function GetSysLang: AnsiString;
function Tok(Sep: String; var S: String): String;
function GetMyFileSize(const Path: String): Integer;
function SearchMainWindow(MainWindowName: pWideChar): Boolean;
function StrContactProtoToInt(Proto: AnsiString): Integer;
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
procedure MakeTransp(winHWND: HWND);
procedure OnSendMessageToAllComponent(Msg: String);
procedure OnSendMessageToOneComponent(WinName, Msg: String);
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

function IsNumber(const S: string): Boolean;
begin
  Result := True;
  try
    StrToInt(S);
  except
    Result := False;
  end;
end;

// Функция конвертации DateTime в Unix Timestamp
function DateTimeToUnix(ConvDate: TDateTime): Longint;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
end;

// Функция конвертации Unix Timestamp в DateTime
function UnixToDateTime(USec: Longint): TDateTime;
begin
  Result := (Usec / 86400) + UnixStartDate;
end;

// Функция для экранирования спецсимволов в строке
function PrepareString(const Source : PWideChar) : AnsiString;
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
   Result := AnsiString(WSTmp);
  end;
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
  Cipher.Init(Digest,Sizeof(Digest)*8,nil);
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

// Расшифровываем строку
function DecryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.DecryptString(Str);;
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
    Result := '';
end;

// LogType = 0 - сообщения добавляются в файл MesLogName
// LogType = 1 - ошибки добавляются в файл ErrLogName
// LogType = 2 - сообщения добавляются в файл DebugLogName
// LogType = 3 - сообщения добавляются в файл DublicateLogName
// LogType = 4 - сообщения добавляются в файл SkypeDebugLogName
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
var
  Path: WideString;
  TF: TextFile;
begin
  if LogType = 0 then
    Path := LogPath + MesLogName
  else if LogType = 1 then
  begin
    Path := LogPath + ErrLogName;
    if (GetMyFileSize(Path) > MaxErrLogSize*1024) then
      DeleteFile(Path);
  end
  else if LogType = 2 then
    Path := LogPath + DebugLogName
  else if LogType = 3 then
  begin
    Path := LogPath + DublicateLogName;
    if (GetMyFileSize(Path) > MaxErrLogSize*1024) then
      DeleteFile(Path);
  end
  else
    Path := LogPath + SkypeDebugLogName;
  {$I-}
  try
    Assign(TF,Path);
    if FileExists(Path) then
      Append(TF)
    else
      Rewrite(TF);
    Writeln(TF,TextString);
    CloseFile(TF);
  except
    on e :
      Exception do
      begin
        CloseFile(TF);
        Exit;
      end;
  end;
  {$I+}
end;

// Загружаем настройки
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
var
  Path: WideString;
  Temp: String;
  INI: TIniFile;
begin
  // Проверяем наличие каталога
  if not DirectoryExists(INIPath) then
    CreateDir(INIPath);
  Path := INIPath + ininame;
  if FileExists(Path) then
  begin
    try
      Ini := TIniFile.Create(Path);
      DBType := INI.ReadString('Main', 'DBType', 'mysql');  // mysql или postgresql
      DBAddress := INI.ReadString('Main', 'DBAddress', DefaultDBAddres);
      DBSchema := INI.ReadString('Main', 'DBSchema', 'username');
      DBPort := INI.ReadString('Main', 'DBPort', '3306');  // 3306 для mysql, 5432 для postgresql
      DBName := INI.ReadString('Main', 'DBName', DefaultDBName);
      // Если вызываем LoadINI НЕ с формы SettingsForm, то DBName ставим без замены <ProfilePluginPath> и <PluginPath>
      if NotSettingsForm then
      begin
        // Замена подстроки в строке DBName
        if MatchStrings(DBName,'<ProfilePluginPath>*') then
          DBName := StringReplace(DBName,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
        else if MatchStrings(DBName,'<PluginPath>*') then
          DBName := StringReplace(DBName,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall]);
        // End
      end;
      ReconnectCount := INI.ReadInteger('Main', 'DBReconnectCount', 5);
      ReconnectInterval := INI.ReadInteger('Main', 'DBReconnectInterval', 1500);
      DBUserName := INI.ReadString('Main', 'DBUserName', 'username');
      DBPasswd := INI.ReadString('Main', 'DBPasswd', 'password');
      if DBPasswd <> '' then
        DBPasswd := DecryptStr(DBPasswd);
      SyncMethod := INI.ReadInteger('Main', 'SyncMethod', 0);
      SyncInterval := INI.ReadInteger('Main', 'SyncInterval', 0);

      Temp := INI.ReadString('Main', 'SyncWhenExit', '0');
      if Temp = '1' then SyncWhenExit := True
      else SyncWhenExit := False;

      NumLastHistoryMsg := INI.ReadInteger('Main', 'NumLastHistoryMsg', 6);

      Temp := INI.ReadString('Main', 'WriteErrLog', '0');
      if Temp = '1' then WriteErrLog := true
      else WriteErrLog := false;

      Temp := INI.ReadString('Main', 'ShowAnimation', '1');
      if Temp = '1' then AniEvents := True
      else AniEvents := False;

      Temp := INI.ReadString('Main', 'EnableHistoryEncryption', '0');
      if Temp = '1' then EnableHistoryEncryption := True
      else EnableHistoryEncryption := False;

      DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'English');
      IMClientType := INI.ReadString('Main', 'IMClientType', 'Unknown');
      MyAccount := INI.ReadString('Main', 'MyAccount', DBUserName);

      Temp := INI.ReadString('Main', 'HideHistorySyncIcon', '0');
      if Temp = '1' then HideSyncIcon := True
      else HideSyncIcon := False;

      SyncTimeCount := INI.ReadInteger('Main', 'SyncTimeCount', 40);

      Temp := INI.ReadString('HotKey', 'GlobalHotKey', '0');
      if Temp = '1' then GlobalHotKeyEnable := True
      else GlobalHotKeyEnable := False;

      SyncHotKey := INI.ReadString('HotKey', 'SyncHotKeyDBSync', 'Ctrl+Alt+F12');

      Temp := INI.ReadString('Main', 'KeyPasswdSaveOnlySession', '0');
      if Temp = '1' then KeyPasswdSaveOnlySession := True
      else KeyPasswdSaveOnlySession := False;

      Temp := INI.ReadString('Main', 'KeyPasswdSave', '0');
      if Temp = '1' then KeyPasswdSave := True
      else KeyPasswdSave := False;

      MaxErrLogSize := INI.ReadInteger('Main', 'MaxErrLogSize', 20);

      Temp := INI.ReadString('Main', 'EnableDebug', '0');
      if Temp = '1' then EnableDebug := True
      else EnableDebug := False;

      Temp := INI.ReadString('Main', 'AlphaBlend', '0');
      if Temp = '1' then AlphaBlendEnable := True
      else AlphaBlendEnable := False;
      AlphaBlendEnableValue := INI.Readinteger('Main', 'AlphaBlendValue', 255);

      Temp := INI.ReadString('Main', 'SkypeSupport', '0');
      if Temp = '1' then GlobalSkypeSupport := True
      else GlobalSkypeSupport := False;

      Temp := INI.ReadString('Main', 'RunningSkypeOnStartup', '0');
      if Temp = '1' then Global_RunningSkypeOnStartup := True
      else Global_RunningSkypeOnStartup := False;

      Temp := INI.ReadString('Main', 'ExitSkypeOnEnd', '0');
      if Temp = '1' then Global_ExitSkypeOnEnd := True
      else Global_ExitSkypeOnEnd := False;

      Temp := INI.ReadString('Main', 'AutoRunHistoryToDBSync', '0');
      if Temp = '1' then Global_AutoRunHistoryToDBSync := True
      else Global_AutoRunHistoryToDBSync := False;
    finally
      INI.Free;
    end;
  end
  else
  begin
    try
      INI := TIniFile.Create(path);
      // Значения по-умолчанию
      DBType := 'mysql';
      DBAddress := DefaultDBAddres;
      DBSchema := 'username';
      DBPort := '3306';
      DBName := DefaultDBName;
      ReconnectCount := 5;
      ReconnectInterval := 1500;
      DBUserName := 'username';
      DBPasswd := 'password';
      SyncMethod := 1;
      SyncInterval := 0;
      SyncTimeCount := 40;
      SyncWhenExit := False;
      NumLastHistoryMsg := 6;
      WriteErrLog := True;
      AniEvents := True;
      EnableHistoryEncryption := False;
      HideSyncIcon := False;
      KeyPasswdSaveOnlySession := False;
      KeyPasswdSave := False;
      MaxErrLogSize := 20;
      GlobalHotKeyEnable := False;
      SyncHotKey := 'Ctrl+Alt+F12';
      EnableDebug := False;
      AlphaBlendEnable := False;
      AlphaBlendEnableValue := 255;
      GlobalSkypeSupport := False;
      Global_RunningSkypeOnStartup := False;
      Global_ExitSkypeOnEnd := False;
      Global_AutoRunHistoryToDBSync := False;
      DefaultLanguage := 'English';
      // Сохраняем настройки
      INI.WriteString('Main', 'DBType', DBType);
      INI.WriteString('Main', 'DBAddress', DefaultDBAddres);
      INI.WriteString('Main', 'DBSchema', DBSchema);
      INI.WriteString('Main', 'DBPort', DBPort);
      INI.WriteInteger('Main', 'DBReconnectCount', ReconnectCount);
      INI.WriteInteger('Main', 'DBReconnectInterval', ReconnectInterval);
      INI.WriteString('Main', 'DBName', DefaultDBName);
      INI.WriteString('Main', 'DBUserName', DBUserName);
      INI.WriteString('Main', 'DBPasswd', EncryptStr(DBPasswd));
      INI.WriteInteger('Main', 'SyncMethod', SyncMethod);
      INI.WriteInteger('Main', 'SyncInterval', SyncInterval);
      INI.WriteInteger('Main', 'SyncTimeCount', SyncTimeCount);
      INI.WriteInteger('Main', 'SyncMessageCount', 50);
      INI.WriteString('Main', 'SyncWhenExit', BoolToIntStr(SyncWhenExit));
      INI.WriteInteger('Main', 'NumLastHistoryMsg', NumLastHistoryMsg);
      INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
      INI.WriteString('Main', 'ShowAnimation', BoolToIntStr(AniEvents));
      INI.WriteString('Main', 'EnableHistoryEncryption', BoolToIntStr(EnableHistoryEncryption));
      INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
      INI.WriteString('Main', 'HideHistorySyncIcon', BoolToIntStr(HideSyncIcon));
      INI.WriteString('Main', 'ShowPluginButton', '1');
      INI.WriteString('Main', 'AddSpecialContact', '1');
      INI.WriteString('Main', 'KeyPasswdSaveOnlySession', BoolToIntStr(KeyPasswdSaveOnlySession));
      INI.WriteString('Main', 'KeyPasswdSave', BoolToIntStr(KeyPasswdSave));
      INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
      INI.WriteString('Main', 'SkypeSupport', BoolToIntStr(GlobalSkypeSupport));
      INI.WriteString('Main', 'RunningSkypeOnStartup', BoolToIntStr(Global_RunningSkypeOnStartup));
      INI.WriteString('Main', 'ExitSkypeOnEnd', BoolToIntStr(Global_ExitSkypeOnEnd));
      INI.WriteString('Main', 'AutoRunHistoryToDBSync', BoolToIntStr(Global_AutoRunHistoryToDBSync));
      INI.WriteString('Fonts', 'FontInTitle', '183|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'FontOutTitle', '8404992|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'FontInBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      INI.WriteString('Fonts', 'FontOutBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      INI.WriteString('Fonts', 'FontService', '16711680|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'TitleParagraph', '4|4|');
      INI.WriteString('Fonts', 'MessagesParagraph', '2|2|');
      INI.WriteString('HotKey', 'GlobalHotKey', BoolToIntStr(GlobalHotKeyEnable));
      INI.WriteString('HotKey', 'SyncHotKey', 'Ctrl+Alt+F11');
      INI.WriteString('HotKey', 'SyncHotKeyDBSync', SyncHotKey);
      INI.WriteString('HotKey', 'ExSearchHotKey', 'Ctrl+F3');
      INI.WriteString('HotKey', 'ExSearchNextHotKey', 'F3');
    finally
      INI.Free;
    end;
  end;
end;

{Функция осуществляет сравнение двух строк. Первая строка
может быть любой, но она не должна содержать символов соответствия (* и ?).
Строка поиска (искомый образ) может содержать абсолютно любые символы.
Для примера: MatchStrings('David Stidolph','*St*') возвратит True.
Автор оригинального C-кода Sean Stanley
Автор портации на Delphi David Stidolph}
function MatchStrings(source, pattern: String): Boolean;
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

{ Функция для получения имени файла из пути без или с его расширением.
  Возвращает имя файла, без или с его расширением.
  Входные параметры:
  FileName - имя файла, которое надо обработать
  ShowExtension - если TRUE, то функция возвратит короткое имя файла
  (без полного пути доступа к нему), с расширением этого файла, иначе, возвратит
  короткое имя файла, без расширения этого файла. }
function ExtractFileNameEx(FileName: String; ShowExtension: Boolean): String;
var
  I: Integer;
  S, S1: string;
begin
  I := Length(FileName);
  if I <> 0 then
  begin
    while (FileName[i] <> '\') and (i > 0) do
      i := i - 1;
    S := Copy(FileName, i + 1, Length(FileName) - i);
    i := Length(S);
    if i = 0 then
    begin
      Result := '';
      Exit;
    end;
    while (S[i] <> '.') and (i > 0) do
      i := i - 1;
    S1 := Copy(S, 1, i - 1);
    if s1 = '' then
      s1 := s;
    if ShowExtension = True then
      Result := s
    else
      Result := s1;
  end
  else
    Result := '';
end;

{ Прозрачность окна MessageBox }
procedure MakeTransp(winHWND: HWND);
var
  exStyle: Longint;
begin
  exStyle := GetWindowLong(winHWND, GWL_EXSTYLE);
  if (exStyle and WS_EX_LAYERED = 0) then
  begin
    exStyle := exStyle or WS_EX_LAYERED;
    SetwindowLong(winHWND, GWL_EXSTYLE, exStyle);
  end;
  SetLayeredWindowAttributes(winHWND, 0, AlphaBlendEnableValue, LWA_ALPHA);
end;

// Для мультиязыковой поддержки
procedure MsgDie(Caption, Msg: WideString);
begin
  if AlphaBlendEnable then
    PostMessage(GetForegroundWindow, WM_USER + 2, 0, 0);
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONERROR);
end;

// Для мультиязыковой поддержки
procedure MsgInf(Caption, Msg: WideString);
begin
  if AlphaBlendEnable then
    PostMessage(GetForegroundWindow, WM_USER + 2, 0, 0);
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

function GetSysLang: AnsiString;
var
  WinLanguage: Array [0..50] of Char;
begin
  //Result :=   Lo(GetSystemDefaultUILanguage);
  VerLanguageName(GetSystemDefaultLangID, WinLanguage, 50);
  Result := StrPas(WinLanguage);
end;

{ Функция разбивает строку S на слова, разделенные символами-разделителями,
указанными в строке Sep. Функция возвращает первое найденное слово, при
этом из строки S удаляется начальная часть до следующего слова }
function Tok(Sep: String; var S: String): String;

  function isoneof(c, s: string): Boolean;
  var
    iTmp: integer;
  begin
    Result := False;
    for iTmp := 1 to Length(s) do
    begin
      if c = Copy(s, iTmp, 1) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

var
  c, t: String;
begin
  if s = '' then
  begin
    Result := s;
    Exit;
  end;
  c := Copy(s, 1, 1);
  while isoneof(c, sep) do
  begin
    s := Copy(s, 2, Length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  t := '';
  while (not isoneof(c, sep)) and (s <> '') do
  begin
    t := t + c;
    s := Copy(s, 2, length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  Result := t;
end;

{ Процедура записи значения параметра в файл настроек }
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
var
  Path: String;
  IsFileClosed: Boolean;
  sFile: DWORD;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
    // Ждем пока файл освободит антивирь или еще какая-нибудь гадость
    IsFileClosed := False;
    repeat
      sFile := CreateFile(PChar(Path),GENERIC_READ or GENERIC_WRITE,0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      if (sFile <> INVALID_HANDLE_VALUE) then
      begin
        CloseHandle(sFile);
        IsFileClosed := True;
      end;
    until IsFileClosed;
    // End
    INI := TIniFile.Create(Path);
    try
      INI.WriteString(CustomSection, CustomParams, ParamsStr);
    finally
      INI.Free;
    end;
  end
  else
    MsgDie(ProgramsName, GetLangStr('SettingsErrSave'));
end;

{ Функция чтения значения параметра из файла настроек }
function ReadCustomINI(INIPath, CustomSection, CustomParams, DefaultParamsStr: String): String;
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  INI := TIniFile.Create(Path);
  if FileExists(Path) then
  begin
    try
      Result := INI.ReadString(CustomSection, CustomParams, DefaultParamsStr);
    finally
      INI.Free;
    end;
  end
  else
    MsgDie(ProgramsName, GetLangStr('SettingsErrRead'));
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
  EncryptMsg, WinName: String;
begin
  EncryptMsg := EncryptStr(Msg);
  WinName := 'HistoryToDBViewer for ' + IMClientType + ' (' + MyAccount + ')';
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

function StrContactProtoToInt(Proto: AnsiString): Integer;
var
  ProtoType: Integer;
begin
  { Протоколы
    0 - ICQ
    1 - Google Talk
    2 - MRA
    3 - Jabber
    4 - QIP.Ru
    5 - Facebook
    6 - VKontacte
    7 - Twitter
    8 - Social (LiveJournal)
    9 - AIM
    10 - IRC
    11 - MSN
    12 - YAHOO
    13 - GADU
    14 - SKYPE
    15 - Unknown
  }
  if MatchStrings(LowerCase(Proto), 'icq*') then
    ProtoType := 0
  else if MatchStrings(LowerCase(Proto), 'google talk*') then
    ProtoType := 1
  else if MatchStrings(LowerCase(Proto), 'mra*') then
    ProtoType := 2
  else if MatchStrings(LowerCase(Proto), 'jabber*') then
    ProtoType := 3
  else if (LowerCase(Proto) = 'qip.ru') then
    ProtoType := 4
  else if MatchStrings(LowerCase(Proto), 'facebook*') then
    ProtoType := 5
  else if MatchStrings(LowerCase(Proto), 'vkontakte*') then
    ProtoType := 6
  else if MatchStrings(Proto, 'ВКонтакте*') then
    ProtoType := 6
  else if MatchStrings(Proto, 'вконтакте*') then
    ProtoType := 6
  else if MatchStrings(LowerCase(Proto), 'twitter*') then
    ProtoType := 7
  else if MatchStrings(LowerCase(Proto), 'livejournal*') then
    ProtoType := 8
  else if MatchStrings(LowerCase(Proto), 'aim*') then
    ProtoType := 9
  else if MatchStrings(LowerCase(Proto), 'irc*') then
    ProtoType := 10
  else if MatchStrings(LowerCase(Proto), 'msn*') then
    ProtoType := 11
  else if MatchStrings(LowerCase(Proto), 'yahoo*') then
    ProtoType := 12
  else if MatchStrings(LowerCase(Proto), 'gadu*') then
    ProtoType := 13
  else if MatchStrings(LowerCase(Proto), 'skype*') then
    ProtoType := 14
  else
    ProtoType := 15;
  Result := ProtoType;
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
    Application.ProcessMessages;
    Inc(N);
  end;
  F := GetTickCount;
  repeat
    Application.ProcessMessages;
    N := GetTickCount;
  until (N - F >= (Value mod 10)) or (N < F);
end;

begin
end.
