{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBViewer v2.4                                 # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  Windows, Messages, Forms, Classes, SysUtils, IniFiles,
  DCPcrypt2, DCPblockciphers, DCPsha1, DCPdes, DCPmd5,
  TypInfo, XMLIntf, XMLDoc, ShlObj, ActiveX, Graphics,
  Types, Registry, ZClasses, ZDbcIntfs;

type
  TWinVersion = (wvUnknown,wv95,wv98,wvME,wvNT3,wvNT4,wvW2K,wvXP,wv2003,wvVista,wv7,wv2008);
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);

const
  ProgramsName = 'HistoryToDBViewer';
  ProgramsVer : WideString = '2.4.0.0';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  ININame = 'HistoryToDB.ini';
  ErrLogName = 'HistoryToDBViewerErr.log';
  MesLogName = 'HistoryToDBMes.sql';
  ImportLogName = 'HistoryToDBImport.sql';
  ContactListName = 'ContactList.csv';
  ProtoListName = 'ProtoList.csv';
  DebugLogName = 'HistoryToDBViewerDebug.log';
  MSG_TITLE = '%s (%s) (%s)';
  CHAT_MSG_TITLE = '%s (%s)';
  MSG_LOG = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, ''%s'', ''%s'', ''%s'', null);';
  MSG_LOG_ORACLE = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, ''%s'', ''%s'', null)';
  // Начальная дата (01/01/1970) Unix Timestamp для функций конвертации
  UnixStartDate: TDateTime = 25569.0;
  // Ключь для расшифровки параметра DBPasswd из конфига и для шифрования/расшифровки посылок программам HistoryToDBSync и HistoryToDBViewer
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // Для мультиязыковой поддержки
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  // End
  WM_MSGBOX = WM_USER + 2;
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

var
  ERR_SAVE_TO_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение сообщений в БД невозможно.';
  ERR_TEMP_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] Ошибка: БД на сервисном обслуживании. Сохранение отложенных сообщений в БД невозможно.';
  ERR_READ_DB_CONNECT_ERR : WideString = '[%s] Ошибка: Не удаётся подключиться к БД. Ошибка: %s';
  ERR_READ_DB_SERVICE_MODE : WideString = '[%s] Ошибка: Невозможно выполнить операцию. БД на сервисном обслуживании.';
  ERR_LOAD_MSG_TO_DB : WideString = '[%s] Ошибка записи сообщений из лог-файла в БД: %s';
  ERR_SEND_UPDATE : WideString = '[%s] Ошибка при запросе обновления: %s';
  ERR_NO_DB_CONNECTED : WideString = '[%s] Соединение с БД не установлено.';
  LOAD_TEMP_MSG : WideString = '[%s] В файле %s найдено %s сообщений; Загружено в БД: %s; Отбраковано: %s';
  LOAD_TEMP_MSG_NOLOGFILE : WideString = '[%s] Файл отложенных сообщений %s не найден.';
  WriteErrLog, AniEvents, EnableHistoryEncryption, HideSyncIcon, ShowPluginButton, ShowSettingsFormOnStart: Boolean;
  AddSpecialContact, BlockSpamMsg, EnableDebug, AlphaBlendEnable, ExPrivateChatName, SyncWhenExit, GlobalSkypeSupport, HistoryAutoScroll: Boolean;
  SyncMethod, SyncInterval, NumLastHistoryMsg, SyncTimeCount, SyncMessageCount, MaxErrLogSize, AlphaBlendEnableValue: Integer;
  DBType, DBAddress, DBSchema, DBPort, DBName, DBUserName, DBPasswd, DefaultLanguage, IMClientType: String;
  Global_AccountUIN, Global_AccountName, Global_CurrentAccountUIN, Global_CurrentAccountName: WideString;
  Glogal_History_Type, Global_Protocol_Type: Integer;
  Global_ChatName: WideString;
  HistoryImportType: Integer;
  ReconnectInterval, ReconnectCount: Integer;
  PluginPath, ProfilePath: WideString;
  Global_MainForm_Showing, Global_SettingsForm_Showing, Global_KeyPasswdForm_Showing, GlobalHotKeyEnable: Boolean;
  Global_AutoRunHistoryToDBSync, Global_RunningSkypeOnStartup, Global_ExitSkypeOnEnd: Boolean;
  IMEditorParagraphTitleSpaceBefore, IMEditorParagraphTitleSpaceAfter, IMEditorParagraphMessagesSpaceBefore, IMEditorParagraphMessagesSpaceAfter: Integer;
  SyncHotKey, SyncHotKeyDBSync, ExSearchHotKey, ExSearchNextHotKey: String;
  EncryptionKeyID, EncryptionKey: String;
  EncryptKeyID, MyAccount: String;
  KeyPasswdSaveOnlySession, KeyPasswdSave: Boolean;
  // Шифрование
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // Для мультиязыковой поддержки
  MainFormHandle: HWND;
  SettingsFormHandle: HWND;
  KeyPasswdFormHandle: HWND;
  LangDoc: IXMLDocument;

function BoolToIntStr(Bool: Boolean): String;
function IsNumber(const S: String): Boolean;
function DateTimeToUnix(ConvDate: TDateTime): Longint;
function UnixToDateTime(USec: Longint): TDateTime;
function UnixToLocalTime(tUnix :Longint): TDateTime;
function PrepareString(const Source : PWideChar) : WideString;
function UnPrepareString(const Source: WideString) : WideString;
function EncryptStr(const Str: String): String;
function DecryptStr(const Str: String): String;
function MatchStrings(source, pattern: String): Boolean;
function ExtractFileNameEx(FileName: String; ShowExtension: Boolean): String;
function AdvSelectDirectory(Const Caption: String; Const Root: WideString; var Directory: String; EditBox: Boolean = False; ShowFiles: Boolean = False; AllowCreateDirs: Boolean = True): Boolean;
function RemoveInvalidStr(InvalidStr, Str: String): String;
function EncryptMD5(Str: String): String;
function ReadCustomINI(INIPath, CustomSection, CustomParams, DefaultParamsStr: String): String;
function GetSystemDefaultUILanguage: UINT; stdcall; external kernel32 name 'GetSystemDefaultUILanguage';
function GetSysLang: AnsiString;
function FontToStr(IMFont: TFont): String;
function Tok(Sep: String; var s: String): String;
function RandomWord(RusAlfa: Boolean; PwdLen: Integer): String;
function GetMyFileSize(const Path: String): Integer;
function GetUserFromWindows: String;
function DetectWinVersion: TWinVersion;
function DetectWinVersionStr: String;
function CheckAllUserAutorun(AppTitle: String): Boolean;
function CheckCurrentUserAutorun(AppTitle: String): Boolean;
procedure AddAllUserAutorun(AppTitle, AppExe: String);
procedure AddCurrentUserAutorun(AppTitle, AppExe: String);
procedure DeleteAllUserAutorun(AppTitle: String);
procedure DeleteCurrentUserAutorun(AppTitle: String);
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure OnSendMessageToAllComponent(Msg: String);
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
procedure StrToFont(Str: String; IMFont: TFont);
procedure MakeTransp(winHWND: HWND);

// Для мультиязыковой поддержки
procedure MsgDie(Caption, Msg: WideString);
procedure MsgInf(Caption, Msg: WideString);
function GetLangStr(StrID: String): WideString;

implementation

uses Main;

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

// Конвертация Unix Timestamp в Локальное время с учетом пояса и Перехода на летнее время
function UnixToLocalTime(tUnix :Longint): TDateTime;
var
  TimeZone :TTimeZoneInformation;
  Bias     :Integer;
begin
  if (GetTimeZoneInformation(TimeZone) = TIME_ZONE_ID_DAYLIGHT) then
    Bias := TimeZone.Bias + TimeZone.DaylightBias
  else
    Bias := TimeZone.Bias + TimeZone.StandardBias;
  Result := EncodeDate(1970,1,1) - Bias / 1440 + tUnix / 86400;
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

// Функция обратная PrepareString
function UnPrepareString(const Source: WideString) : WideString;
var
  Msg_Result: WideString;
begin
  Result := '';
  Msg_Result := Source;
  Msg_Result := StringReplace(Msg_Result, '\r', #$0D, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\n', #$0A, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\t', #$09, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\"', #$22, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '''', #$27, [RFReplaceall]);
  Result := Msg_Result;
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
    Result := 'MD5';
end;

// LogType = 0 - сообщения добавляются в файл MesLogName
// LogType = 1 - ошибки добавляются в файл ErrLogName
// LogType = 2 - сообщения добавляются в файл DebugLogName
// LogType = 3 - сообщения добавляются в файл ImportLogName
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
    if (LogType > 0) and (GetMyFileSize(Path) > MaxErrLogSize*1024) then
      DeleteFile(Path);
  end
  else if LogType = 2 then
  begin
    Path := LogPath + DebugLogName;
    //if (LogType > 0) and (GetMyFileSize(Path) > MaxErrLogSize*1024) then
    //  DeleteFile(Path);
  end
  else
    Path := LogPath + ImportLogName;
  {$I-}
  Assign(TF,Path);
  if FileExists(Path) then
  begin
    try
      Append(TF);
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
  end
  else
  begin
    try
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
  end;
  {$I+}
end;

// Загружаем настройки
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
var
  Path: WideString;
  Temp: String;
  INI: TIniFile;
  I, J: Integer;
  Drivers: IZCollection;
  Protocols: TStringDynArray;
  DBTypeTrue: Boolean;
begin
  // Проверяем наличие каталога
  if not DirectoryExists(INIPath) then
    CreateDir(INIPath);
  Path := INIPath + ininame;
  if FileExists(Path) then
  begin
    try
      INI := TIniFile.Create(Path);
      DBType := INI.ReadString('Main', 'DBType', 'mysql');  // mysql или postgresql
      // Проверяем корректность драйвера БД
      DBTypeTrue := False;
      Drivers := DriverManager.GetDrivers;
      for I := 0 to Drivers.Count - 1 do
      begin
        Protocols := (Drivers.Items[I] as IZDriver).GetSupportedProtocols;
        for J := 0 to High(Protocols) do
          if DBType = Protocols[J] then
            DBTypeTrue := True;
      end;
      if not DBTypeTrue then
        DBType := 'mysql';
      // End
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
      if Temp = '1' then WriteErrLog := True
      else WriteErrLog := False;

      Temp := INI.ReadString('Main', 'ShowAnimation', '1');
      if Temp = '1' then AniEvents := True
      else AniEvents := False;

      Temp := INI.ReadString('Main', 'BlockSpamMsg', '0');
      if Temp = '1' then BlockSpamMsg := True
      else BlockSpamMsg := False;

      Temp := INI.ReadString('Main', 'EnableHistoryEncryption', '0');
      if Temp = '1' then EnableHistoryEncryption := True
      else EnableHistoryEncryption := False;

      DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'English');
      IMClientType := INI.ReadString('Main', 'IMClientType', 'Unknown');
      MyAccount := INI.ReadString('Main', 'MyAccount', DBUserName);

      Temp := INI.ReadString('Main', 'HideHistorySyncIcon', '0');
      if Temp = '1' then HideSyncIcon := true
      else HideSyncIcon := false;

      SyncTimeCount := INI.ReadInteger('Main', 'SyncTimeCount', 40);
      SyncMessageCount := INI.ReadInteger('Main', 'SyncMessageCount', 50);

      Temp := INI.ReadString('Main', 'ShowPluginButton', '1');
      if Temp = '1' then ShowPluginButton := true
      else ShowPluginButton := false;

      Temp := INI.ReadString('Main', 'AddSpecialContact', '1');
      if Temp = '1' then AddSpecialContact := True
      else AddSpecialContact := False;

      Temp := INI.ReadString('Main', 'HistoryAutoScroll', '1');
      if Temp = '1' then HistoryAutoScroll := True
      else HistoryAutoScroll := False;

      Temp := INI.ReadString('Main', 'EnableDebug', '0');
      if Temp = '1' then EnableDebug := True
      else EnableDebug := False;

      Temp := INI.ReadString('Main', 'EnableExPrivateChatName', '0');
      if Temp = '1' then ExPrivateChatName := True
      else ExPrivateChatName := False;

      Temp := INI.ReadString('Main', 'KeyPasswdSaveOnlySession', '0');
      if Temp = '1' then KeyPasswdSaveOnlySession := True
      else KeyPasswdSaveOnlySession := False;

      Temp := INI.ReadString('Main', 'KeyPasswdSave', '0');
      if Temp = '1' then KeyPasswdSave := True
      else KeyPasswdSave := False;

      MaxErrLogSize := INI.ReadInteger('Main', 'MaxErrLogSize', 20);

      Temp := INI.ReadString('Fonts', 'FontInTitle', '183|-11|Verdana|0|96|8|Y|N|N|N|');
      StrToFont(Temp, MainForm.FHeaderFontInTitle);

      Temp := INI.ReadString('Fonts', 'FontOutTitle', '8404992|-11|Verdana|0|96|8|Y|N|N|N|');
      StrToFont(Temp, MainForm.FHeaderFontOutTitle);

      Temp := INI.ReadString('Fonts', 'FontInBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      StrToFont(Temp, MainForm.FHeaderFontInBody);

      Temp := INI.ReadString('Fonts', 'FontOutBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      StrToFont(Temp, MainForm.FHeaderFontOutBody);

      Temp := INI.ReadString('Fonts', 'FontService', '16711680|-11|Verdana|0|96|8|Y|N|N|N|');
      StrToFont(Temp, MainForm.FHeaderFontServiceMsg);

      Temp := INI.ReadString('Fonts', 'TitleParagraph', '4|4|');
      IMEditorParagraphTitleSpaceBefore := StrToInt(Tok('|', Temp));
      IMEditorParagraphTitleSpaceAfter := StrToInt(Tok('|', Temp));

      Temp := INI.ReadString('Fonts', 'MessagesParagraph', '2|2|');
      IMEditorParagraphMessagesSpaceBefore := StrToInt(Tok('|', Temp));
      IMEditorParagraphMessagesSpaceAfter := StrToInt(Tok('|', Temp));

      Temp := INI.ReadString('HotKey', 'GlobalHotKey', '0');
      if Temp = '1' then GlobalHotKeyEnable := True
      else GlobalHotKeyEnable := False;

      SyncHotKey := INI.ReadString('HotKey', 'SyncHotKey', 'Ctrl+Alt+F11');
      SyncHotKeyDBSync := INI.ReadString('HotKey', 'SyncHotKeyDBSync', 'Ctrl+Alt+F12');
      ExSearchHotKey := INI.ReadString('HotKey', 'ExSearchHotKey', 'Ctrl+F3');
      ExSearchNextHotKey := INI.ReadString('HotKey', 'ExSearchNextHotKey', 'F3');

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
      SyncMessageCount := 50;
      SyncWhenExit := False;
      NumLastHistoryMsg := 6;
      WriteErrLog := True;
      AniEvents := True;
      EnableHistoryEncryption := False;
      HideSyncIcon := False;
      ShowPluginButton := True;
      AddSpecialContact := True;
      KeyPasswdSaveOnlySession := False;
      KeyPasswdSave := False;
      MaxErrLogSize := 20;
      BlockSpamMsg := False;
      EnableDebug := False;
      GlobalSkypeSupport := False;
      Global_RunningSkypeOnStartup := False;
      Global_ExitSkypeOnEnd := False;
      Global_AutoRunHistoryToDBSync := False;
      DefaultLanguage := 'English';
      Temp := '183|-11|Verdana|0|96|8|Y|N|N|N|';
      StrToFont(Temp, MainForm.FHeaderFontInTitle);
      Temp := '8404992|-11|Verdana|0|96|8|Y|N|N|N|';
      StrToFont(Temp, MainForm.FHeaderFontOutTitle);
      Temp := '-16777208|-11|Verdana|0|96|8|N|N|N|N|';
      StrToFont(Temp, MainForm.FHeaderFontInBody);
      Temp := '-16777208|-11|Verdana|0|96|8|N|N|N|N|';
      StrToFont(Temp, MainForm.FHeaderFontOutBody);
      Temp := '16711680|-11|Verdana|0|96|8|Y|N|N|N|';
      StrToFont(Temp, MainForm.FHeaderFontServiceMsg);
      IMEditorParagraphTitleSpaceBefore := 4;
      IMEditorParagraphTitleSpaceAfter := 4;
      IMEditorParagraphMessagesSpaceBefore := 4;
      IMEditorParagraphMessagesSpaceAfter := 4;
      GlobalHotKeyEnable := False;
      SyncHotKey := 'Ctrl+Alt+F11';
      SyncHotKeyDBSync := 'Ctrl+Alt+F12';
      ExSearchHotKey := 'Ctrl+F3';
      ExSearchNextHotKey := 'F3';
      AlphaBlendEnable := False;
      AlphaBlendEnableValue := 255;
      HistoryAutoScroll := True;
      // Сохраняем настройки
      INI.WriteString('Main', 'DBType', DBType);
      INI.WriteString('Main', 'DBAddress', DefaultDBAddres);
      INI.WriteString('Main', 'DBSchema', DBSchema);
      INI.WriteString('Main', 'DBPort', DBPort);
      INI.WriteString('Main', 'DBName', DefaultDBName);
      INI.WriteInteger('Main', 'DBReconnectCount', ReconnectCount);
      INI.WriteInteger('Main', 'DBReconnectInterval', ReconnectInterval);
      INI.WriteString('Main', 'DBUserName', DBUserName);
      INI.WriteString('Main', 'DBPasswd', EncryptStr(DBPasswd));
      INI.WriteInteger('Main', 'SyncMethod', SyncMethod);
      INI.WriteInteger('Main', 'SyncInterval', SyncInterval);
      INI.WriteInteger('Main', 'SyncTimeCount', SyncTimeCount);
      INI.WriteInteger('Main', 'SyncMessageCount', SyncMessageCount);
      INI.WriteString('Main', 'SyncWhenExit', BoolToIntStr(SyncWhenExit));
      INI.WriteInteger('Main', 'NumLastHistoryMsg', NumLastHistoryMsg);
      INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
      INI.WriteString('Main', 'ShowAnimation', BoolToIntStr(AniEvents));
      INI.WriteString('Main', 'BlockSpamMsg', BoolToIntStr(BlockSpamMsg));
      INI.WriteString('Main', 'EnableHistoryEncryption', BoolToIntStr(EnableHistoryEncryption));
      INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
      INI.WriteString('Main', 'HideHistorySyncIcon', BoolToIntStr(HideSyncIcon));
      INI.WriteString('Main', 'ShowPluginButton', BoolToIntStr(ShowPluginButton));
      INI.WriteString('Main', 'AddSpecialContact', BoolToIntStr(AddSpecialContact));
      INI.WriteString('Main', 'HistoryAutoScroll', BoolToIntStr(HistoryAutoScroll));
      INI.WriteString('Main', 'KeyPasswdSaveOnlySession', BoolToIntStr(KeyPasswdSaveOnlySession));
      INI.WriteString('Main', 'KeyPasswdSave', BoolToIntStr(KeyPasswdSave));
      INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
      INI.WriteString('Main', 'SkypeSupport', BoolToIntStr(GlobalSkypeSupport));
      INI.WriteString('Main', 'RunningSkypeOnStartup', BoolToIntStr(Global_RunningSkypeOnStartup));
      INI.WriteString('Main', 'ExitSkypeOnEnd', BoolToIntStr(Global_ExitSkypeOnEnd));
      INI.WriteString('Main', 'AutoRunHistoryToDBSync', BoolToIntStr(Global_AutoRunHistoryToDBSync));
      INI.WriteString('Main', 'AlphaBlend', BoolToIntStr(AlphaBlendEnable));
      INI.WriteInteger('Main', 'AlphaBlendValue', AlphaBlendEnableValue);
      INI.WriteString('Fonts', 'FontInTitle', '183|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'FontOutTitle', '8404992|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'FontInBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      INI.WriteString('Fonts', 'FontOutBody', '-16777208|-11|Verdana|0|96|8|N|N|N|N|');
      INI.WriteString('Fonts', 'FontService', '16711680|-11|Verdana|0|96|8|Y|N|N|N|');
      INI.WriteString('Fonts', 'TitleParagraph', '4|4|');
      INI.WriteString('Fonts', 'MessagesParagraph', '2|2|');
      INI.WriteString('HotKey', 'GlobalHotKey', BoolToIntStr(GlobalHotKeyEnable));
      INI.WriteString('HotKey', 'SyncHotKey', 'Ctrl+Alt+F11');
      INI.WriteString('HotKey', 'SyncHotKeyDBSync', 'Ctrl+Alt+F12');
      INI.WriteString('HotKey', 'ExSearchHotKey', 'Ctrl+F3');
      INI.WriteString('HotKey', 'ExSearchNextHotKey', 'F3');
    finally
      INI.Free;
    end;
  end;
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
  AppNameStr, EncryptMsg: String;
begin
  // Ищем окно HistoryToDBSync и посылаем ему команду
  if IMClientType <> 'Unknown' then
  begin
    AppNameStr := 'HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')';
    HToDB := FindWindow(nil, PWideChar(AppNameStr));
  end
  else
    HToDB := FindWindow(nil, 'HistoryToDBSync');
  if HToDB <> 0 then
  begin
    EncryptMsg := EncryptStr(Msg);
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
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
    Result := 'String not found';
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

// Функция вызова диалога выбора каталога
// Зависит от ShlObj и ActiveX
function AdvSelectDirectory(Const Caption: String; Const Root: WideString; var Directory: string; EditBox: Boolean = False; ShowFiles: Boolean = False; AllowCreateDirs: Boolean = True): Boolean;
  function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer; stdcall;
  begin
    case uMsg of
      BFFM_INITIALIZED: SendMessage(Wnd, BFFM_SETSELECTION, Ord(True), Integer(lpData));
    end;
    Result := 0;
  end;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
const
  BIF_USENEWUI = $0040;
  BIF_NOCREATEDIRS = $0200;
begin
  Result := False;
  if not DirectoryExists(Directory) then
    Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if Root <> '' then
      begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(Application.Handle, nil, POleStr(Root), Eaten, RootItemIDList, Flags);
      end;
      OleInitialize(nil);
      with BrowseInfo do
      begin
        hwndOwner := Application.Handle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS or BIF_USENEWUI or
          BIF_EDITBOX * Ord(EditBox) or BIF_BROWSEINCLUDEFILES * Ord(ShowFiles) or
          BIF_NOCREATEDIRS * Ord(not AllowCreateDirs);
        lpfn := @SelectDirCB;
        if Directory <> '' then
          lParam := Integer(PChar(Directory));
      end;
      WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      Result := ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

// Функция удаляет подстроку InvalidStr из строки Str
function RemoveInvalidStr(InvalidStr, Str: String): String;
var
  MyStr: String;
begin
  MyStr := Str;
  while Pos(InvalidStr, MyStr) > 0 do
    MyStr := Copy(MyStr,1,pos(InvalidStr,MyStr)-1) +
  Copy(MyStr,Pos(InvalidStr,MyStr)+Length(MyStr),Length(MyStr));
  Result := MyStr;
end;

function GetSysLang: AnsiString;
var
  WinLanguage: Array [0..50] of Char;
begin
  //Result :=   Lo(GetSystemDefaultUILanguage);
  VerLanguageName(GetSystemDefaultLangID, WinLanguage, 50);
  Result := StrPas(WinLanguage);
end;

{ Преобрауем TFont в строку вида
  Color|Height|Name|Pitch|PixelsPerInch|Size|Style-fsBold|Style-fsItalic|Style-fsUnderline|Style-fsStrikeout| }
function FontToStr(IMFont: TFont): String;
  procedure Yes(var Str: String);
  begin
    Str := Str + 'Y|';
  end;
  procedure No(var Str: String);
  begin
    Str := Str + 'N|';
  end;
begin
  { Кодируем все атрибуты TFont в строку }
  Result := '';
  Result := Result + IntToStr(IMFont.Color) + '|';
  Result := Result + IntToStr(IMFont.Height) + '|';
  Result := Result + IMFont.Name + '|';
  Result := Result + IntToStr(Ord(IMFont.Pitch)) + '|';
  Result := Result + IntToStr(IMFont.PixelsPerInch) + '|';
  Result := Result + IntToStr(IMFont.Size) + '|';
  if fsBold in IMFont.Style then
    Yes(Result)
  else
    No(Result);
  if fsItalic in IMFont.Style then
    Yes(Result)
  else
    No(Result);
  if fsUnderline in IMFont.Style then
    Yes(Result)
  else
    No(Result);
  if fsStrikeout in IMFont.Style then
    Yes(Result)
  else
    No(Result);
end;

{ Преобрауем строку вида
  Color|Height|Name|Pitch|PixelsPerInch|Size|Style-fsBold|Style-fsItalic|Style-fsUnderline|Style-fsStrikeout|
  в TFont }
procedure StrToFont(Str: String; IMFont: TFont);
var
  YesNo: String;
begin
  if Str = '' then
    Exit;
  IMFont.Color := StrToInt(Tok('|', Str));
  IMFont.Height := StrToInt(Tok('|', Str));
  IMFont.Name := Tok('|', Str);
  IMFont.Pitch := TFontPitch(StrToInt(Tok('|', Str)));
  IMFont.PixelsPerInch := StrToInt(Tok('|', Str));
  IMFont.Size := StrToInt(Tok('|', Str));
  IMFont.Style := [];
  YesNo := Tok('|', Str);
  if YesNo = 'Y' then
    IMFont.Style := IMFont.Style + [fsBold];
  YesNo := Tok('|', Str);
  if YesNo = 'Y' then
    IMFont.Style := IMFont.Style + [fsItalic];
  YesNo := Tok('|', Str);
  if YesNo = 'Y' then
    IMFont.Style := IMFont.Style + [fsUnderline];
  YesNo := Tok('|', Str);
  if YesNo = 'Y' then
    IMFont.Style := IMFont.Style + [fsStrikeout];
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

{ Генерируем ключ указанной длины
  Если RusAlfa = True, то будут присутствовать русский набор символов
  Иначе только Английский набор, Спец. символы и Цифры }
function RandomWord(RusAlfa: Boolean; PwdLen: Integer): String;
const
  Con1='qwertyuiopasdfghjklzxcvbnm';
  Con2='QWERTYUIOPASDFGHJKLZXCVBNM';
  Con3='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  Con4='!@#$%^&*()_+|\=-<>. ,/?'';:"][}{';
  Con5='йцукенгшщзхъфывапролджэячсмитьбю';
  Con6='ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
  Con7='йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
var
  Pw: String;
  PasswordLen, Rand: Integer;
begin
  Randomize;
  Result := '';
  PasswordLen := PwdLen;
  repeat
    if RusAlfa then
      Rand := Random(8)+1
    else
      Rand := Random(5)+1;
    if PasswordLen > 0 then
        case Rand of
          1: Pw := Pw + Con1[Random(25)+1];
          2: Pw := Pw + Con2[Random(25)+1];
          3: Pw := Pw + Con3[Random(49)+1];
          4: Pw := Pw + Con4[Random(30)+1];
          5: Pw := Pw + IntToStr(Random(10));
          6: Pw := Pw + Con5[Random(31)+1];
          7: Pw := Pw + Con6[Random(31)+1];
          8: Pw := Pw + Con7[Random(63)+1];
        end
    else
      PasswordLen := Length(Pw);
  until Length(Pw) >= PasswordLen;
  while Length(Pw) > PasswordLen do
    Delete(Pw,1,1);
  Result := Pw;
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

// Узнаем имя залогиневшегося пользователя
function GetUserFromWindows: String;
var
  UserName    : string;
  UserNameLen : Dword;
begin
  UserNameLen := 255;
  SetLength(userName, UserNameLen);
  if GetUserName(PChar(UserName), UserNameLen) Then
    Result := Copy(UserName,1,UserNameLen - 1)
  else
    Result := 'Unknown';
end;

{
DwMajorVersion:DWORD - старшая цифра версии Windows

  Windows 95      - 4
   Windows 98      - 4
   Windows Me      - 4
   Windows NT 3.51 - 3
   Windows NT 4.0  - 4
   Windows 2000    - 5
   Windows XP      - 5

DwMinorVersion: DWORD - младшая цифра версии

  Windows 95      - 0
   Windows 98      - 10
   Windows Me      - 90
   Windows NT 3.51 - 51
   Windows NT 4.0  - 0
   Windows 2000    - 0
   Windows XP      - 1


DwBuildNumber: DWORD
 Win NT 4 - номер билда
 Win 9x   - старший байт - старшая и младшая цифры версии / младший - номер
билда

dwPlatformId: DWORD

 VER_PLATFORM_WIN32s            Win32s on Windows 3.1.
  VER_PLATFORM_WIN32_WINDOWS     Win32 on Windows 9x
  VER_PLATFORM_WIN32_NT          Win32 on Windows NT, 2000


SzCSDVersion:DWORD
  NT - содержит PСhar с инфо о установленном ServicePack
  9x - доп. инфо, может и не быть
}
function DetectWinVersion: TWinVersion;
var
  OSVersionInfo : TOSVersionInfo;
begin
  Result := wvUnknown;                      // Неизвестная версия ОС
  OSVersionInfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo);
  if GetVersionEx(OSVersionInfo)
    then
      begin
        case OSVersionInfo.DwMajorVersion of
          3:  Result := wvNT3;              // Windows NT 3
          4:  case OSVersionInfo.DwMinorVersion of
                0: if OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT
                   then Result := wvNT4     // Windows NT 4
                   else Result := wv95;     // Windows 95
                10: Result := wv98;         // Windows 98
                90: Result := wvME;         // Windows ME
              end;
          5:  case OSVersionInfo.DwMinorVersion of
                0: Result := wvW2K;         // Windows 2000
                1: Result := wvXP;          // Windows XP
                2: Result := wv2003;        // Windows 2003
                3: Result := wvVista;       // Windows Vista
              end;
          6:  case OSVersionInfo.DwMinorVersion of
                0: Result := wv2008;        // Windows 2008
                1: Result := wv7;           // Windows 7
              end;
        end;
      end;
end;

function DetectWinVersionStr: String;
const
  VersStr : Array[TWinVersion] of String = (
    'Unknown',
    'Windows 95',
    'Windows 98',
    'Windows ME',
    'Windows NT 3',
    'Windows NT 4',
    'Windows 2000',
    'Windows XP',
    'Windows Server 2003',
    'Windows Vista',
    'Windows 7',
    'Windows Server 2008');
begin
  Result := VersStr[DetectWinVersion];
end;

procedure AddAllUserAutorun(AppTitle, AppExe: String);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      Reg.WriteString(AppTitle, AppExe);
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

procedure AddCurrentUserAutorun(AppTitle, AppExe: String);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      Reg.WriteString(AppTitle, AppExe);
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

procedure DeleteAllUserAutorun(AppTitle: String);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      Reg.DeleteValue(AppTitle);
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

procedure DeleteCurrentUserAutorun(AppTitle: String);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      Reg.DeleteValue(AppTitle);
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

function CheckAllUserAutorun(AppTitle: String): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      if Reg.ValueExists(AppTitle) then
        Result := True;
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

function CheckCurrentUserAutorun(AppTitle: String): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      if Reg.ValueExists(AppTitle) then
        Result := True;
      Reg.CloseKey();
    end;
  finally
    Reg.Free;
  end;
end;

begin
end.
