{ ################################################################################ }
{ #                                                                              # }
{ #  Обновление и установка набора программ IM-History - HistoryToDBUpdater v1.0 # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

unit Global;

interface

uses
  Windows, Forms, Classes, SysUtils, IniFiles, DCPcrypt2, DCPblockciphers, DCPsha1,
  DCPdes, DCPmd5, TypInfo, Messages, XMLIntf, XMLDoc, StrUtils, Types, TLHELP32, PsAPI, NTNative;

type
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);
  TDelim = set of Char;
  TArrayOfString = Array of String;
  TArrayOfCardinal = Array of Cardinal;
  TProcessInfo = packed record
    ProcessName: String;
    PID: DWord;
    ProcessFullCmd: String;
    ProcessPath: String;
    ProcessParamCmd: String;
  end;
  TProcessInfoArray = Array of TProcessInfo;

const
  ProgramsName = 'HistoryToDBUpdater';
  ProgramsVer : WideString = '2.4.0.0';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  ININame = 'HistoryToDB.ini';
  ErrLogName = 'HistoryToDBUpdaterErr.log';
  DebugLogName = 'HistoryToDBUpdaterDebug.log';
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
  uURL = 'http://im-history.ru/update/get.php?file=HistoryToDB-Update';

var
  WriteErrLog: Boolean;
  EnableDebug, AlphaBlendEnable: Boolean;
  MaxErrLogSize, AlphaBlendEnableValue: Integer;
  DBType, DefaultLanguage, IMClientType: String;
  PluginPath, ProfilePath: WideString;
  Global_MainForm_Showing, Global_AboutForm_Showing: Boolean;
  Global_IMProcessPID: DWORD;
  // Прокси
  IMUseProxy, IMProxyAuth: Boolean;
  IMProxyAddress, IMProxyPort, IMProxyUser, IMProxyUserPagsswd: String;
  DBUserName, MyAccount: String;
  // Шифрование
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // Для мультиязыковой поддержки
  CoreLanguage: String;
  MainFormHandle: HWND;
  AboutFormHandle: HWND;
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
function IsProcessRun(ProcessName: String): Boolean; overload;
function IsProcessRun(ProcessName, WinCaption: String): Boolean; overload;
function GetProcessID(ExeFileName: String): Cardinal;
//function GetProcessIDMulti(ExeFileName: String): TArrayOfString;
function GetProcessIDMulti2(ExeFileName: String): TArrayOfCardinal;
function GetThreadsOfProcess(APID: Cardinal): TIntegerDynArray;
function KillTask(ExeFileName: String): Integer; overload;
function KillTask(ExeFileName, WinCaption: String): Integer; overload;
function ProcessTerminate(dwPID: Cardinal): Boolean;
function ProcCloseEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
function ProcQuitEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
function GetProcessFileName(PID: DWord; FullPath: Boolean=True): String;
function GetProcessCmdLine(PID:DWord): String;
function SetProcessDebugPrivelege: Boolean;
function EndProcess(IMClientExeName: String; EndType: Integer; EndProcess: Boolean): TProcessInfoArray;
function GetUserTempPath: WideString;
//function ProcGetCaptionForHandleEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
function EnumThreadWndProc(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
function StringToParts(sString:String; tdDelim:TDelim): TArrayOfString;
function ExtractWord(const AString: string; const ADelimiter: Char; const ANumber: integer): string;
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
procedure MakeTransp(winHWND: HWND);
procedure OnSendMessageToAllComponent(Msg: String);
procedure IMDelay(Value: Cardinal);
procedure OnSendMessageToOneComponent(WinName, Msg: String);
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
    Result := 'MD5';
end;

// LogType = 0 - ошибки добавляются в файл ErrLogName
// LogType = 1 - сообщения добавляются в файл DebugLogName
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
var
  Path: WideString;
  TF: TextFile;
begin
  if LogType = 0 then
  begin
    Path := LogPath + ErrLogName;
    if (GetMyFileSize(Path) > MaxErrLogSize*1024) then
      DeleteFile(Path);
  end
  else
    Path := LogPath + DebugLogName;
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
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
    try
      INI := TIniFile.Create(Path);

      DBType := INI.ReadString('Main', 'DBType', 'Unknown');
      DBUserName := INI.ReadString('Main', 'DBUserName', 'username');
      DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'English');
      IMClientType := INI.ReadString('Main', 'IMClientType', 'Unknown');
      MyAccount := INI.ReadString('Main', 'MyAccount', DBUserName);

      Temp := INI.ReadString('Main', 'WriteErrLog', '0');
      if Temp = '1' then WriteErrLog := True
      else WriteErrLog := False;

      MaxErrLogSize := INI.ReadInteger('Main', 'MaxErrLogSize', 20);

      Temp := INI.ReadString('Main', 'EnableDebug', '0');
      if Temp = '1' then EnableDebug := True
      else EnableDebug := False;

      Temp := INI.ReadString('Main', 'AlphaBlend', '0');
      if Temp = '1' then AlphaBlendEnable := True
      else AlphaBlendEnable := False;
      AlphaBlendEnableValue := INI.ReadInteger('Main', 'AlphaBlendValue', 255);

      Temp := INI.ReadString('Proxy', 'UseProxy', '0');
      if Temp = '1' then IMUseProxy := True
      else IMUseProxy := False;

      IMProxyAddress := INI.ReadString('Proxy', 'ProxyAddress', '127.0.0.1');
      IMProxyPort := INI.ReadString('Proxy', 'ProxyPort', '3128');

      Temp := INI.ReadString('Proxy', 'ProxyAuth', '0');
      if Temp = '1' then IMProxyAuth := True
      else IMProxyAuth := False;

      IMProxyUser := INI.ReadString('Proxy', 'ProxyUser', '');
      IMProxyUserPagsswd := INI.ReadString('Proxy', 'ProxyUserPasswd', '');
      if IMProxyUserPagsswd <> '' then
        IMProxyUserPagsswd := DecryptStr(IMProxyUserPagsswd);
    finally
      INI.Free;
    end;
  end
  else
  begin
    try
      INI := TIniFile.Create(path);
      // Значения по-умолчанию
      DBType := 'Unknown';
      DefaultLanguage := 'English';
      IMClientType := 'Unknown';
      WriteErrLog := True;
      MaxErrLogSize := 20;
      EnableDebug := False;
      AlphaBlendEnable := False;
      AlphaBlendEnableValue := 255;
      IMUseProxy := False;
      IMProxyAddress := '127.0.0.1';
      IMProxyPort := '3128';
      IMProxyAuth := False;
      IMProxyUser := '';
      IMProxyUserPagsswd := '';
      // Сохраняем настройки
      INI.WriteString('Main', 'DBType', DBType);
      INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
      INI.WriteString('Main', 'IMClientType', IMClientType);
      INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
      INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
      INI.WriteString('Main', 'EnableDebug', BoolToIntStr(EnableDebug));
      INI.WriteString('Main', 'AlphaBlend', BoolToIntStr(AlphaBlendEnable));
      INI.WriteInteger('Main', 'AlphaBlendValue', AlphaBlendEnableValue);
      INI.WriteString('Proxy', 'UseProxy', BoolToIntStr(IMUseProxy));
      INI.WriteString('Proxy', 'ProxyAddress', IMProxyAddress);
      INI.WriteString('Proxy', 'ProxyPort', IMProxyPort);
      INI.WriteString('Proxy', 'ProxyAuth', BoolToIntStr(IMProxyAuth));
      INI.WriteString('Proxy', 'ProxyUser', IMProxyUser);
      INI.WriteString('Proxy', 'ProxyUserPasswd', IMProxyUserPagsswd);
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
  //Result := Lo(GetSystemDefaultUILanguage);
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
  WinName := 'HistoryToDBViewer for ' + IMClientType;
  // Ищем окно HistoryToDBViewer и посылаем ему команду
  HToDB := FindWindow(nil, pChar(WinName));
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  WinName := 'HistoryToDBSync for ' + IMClientType;
  // Ищем окно HistoryToDBSync и посылаем ему команду
  HToDB := FindWindow(nil, pChar(WinName));
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  WinName := 'HistoryToDBImport for ' + IMClientType;
  // Ищем окно HistoryToDBImport и посылаем ему команду
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

{ Закрытие программы через WM_CLOSE по её PID }
function ProcCloseEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
var
  Pid: DWORD;
begin
  Result := True;
  GetWindowThreadProcessId(hwnd, pid);
  if Pid = DWORD(data) then
  begin
    PostMessage(hwnd, WM_CLOSE, 0, 0);
  end;
end;

{ Закрытие программы через WM_QUIT по её PID }
function ProcQuitEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
var
  Pid: DWORD;
begin
  Result := True;
  GetWindowThreadProcessId(hwnd, pid);
  if Pid = DWORD(data) then
  begin
    PostMessage(hwnd, WM_QUIT, 0, 0);
  end;
end;

{function ProcGetCaptionForHandleEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
var
  Pid: DWORD;
  WinCaption: Array [0 .. 255] of Char;
begin
  Result := True;
  GetWindowThreadProcessId(hwnd, pid);
  if Pid = DWORD(data) then
  begin
    //PostMessage(hwnd, WM_QUIT, 0, 0);
    GetWindowText(hwnd, WinCaption, SizeOf(WinCaption));
    if WinCaption <> '' then
      MsgInf('ProcGetCaptionForHandleEnum', WinCaption);
  end;
end;}

{ Функция отправляет WM_QUIT процессу
  и возвращает TArrayOfString со списком полных путей + параметры запуска
  этих процессов
  EndType = 0 - WM_CLOSE
  EndType = 1 - WM_QUIT
   }
function EndProcess(IMClientExeName: String; EndType: Integer; EndProcess: Boolean): TProcessInfoArray;
var
  I: Integer;
  ProcessPIDListArray: TArrayOfCardinal;
  MyFullCMD, MyCMD, MyCMDParam: String;
begin
  SetLength(Result, 0);
  SetLength(ProcessPIDListArray, 0);
  ProcessPIDListArray := GetProcessIDMulti2(IMClientExeName);
  for I := 0 to High(ProcessPIDListArray) do
  begin
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1].ProcessName := IMClientExeName;
    Result[Length(Result)-1].PID := ProcessPIDListArray[I];
    Result[Length(Result)-1].ProcessFullCmd := GetProcessCmdLine(ProcessPIDListArray[I]);
    //Result[Length(Result)-1] := GetProcessFileName(StrToInt(ProcessListArray[I]), True);
    // Если в полном CMD вида
    // "C:/Program Files/PostgreSQL/9.1/bin/postgres.exe" "--forklog" "244" "248"
    // или
    // "C:\Program Files\Microsoft Firewall Client 2004\FwcAgent.exe"
    if Result[Length(Result)-1].ProcessFullCmd[1] = '"' then
    begin
      MyFullCMD := Result[Length(Result)-1].ProcessFullCmd;
      Delete(MyFullCMD, 1, 1);
      MyCMD := Copy(MyFullCMD, 1, Pos('"', MyFullCMD)-1);
      Delete(MyFullCMD, 1, Pos('"', MyFullCMD)+1);
      Result[Length(Result)-1].ProcessPath := MyCMD;
      Result[Length(Result)-1].ProcessParamCmd := MyFullCMD;
    end
    else
    begin
      MyFullCMD := Result[Length(Result)-1].ProcessFullCmd;
      // Если в полном CMD вида
      // C:\WINDOWS\system32\svchost -k DcomLaunch
      if Pos(' ', MyFullCMD) > 0 then
      begin
        MyCMD := Copy(MyFullCMD, 1, Pos(' ', MyFullCMD)-1);
        Delete(MyFullCMD, 1, Pos(' ', MyFullCMD));
        Result[Length(Result)-1].ProcessPath := MyCMD;
        Result[Length(Result)-1].ProcessParamCmd := MyFullCMD;
      end
      // Если в полном CMD вида
      // C:\WINDOWS\system32\lsass.exe
      else
      begin
        Result[Length(Result)-1].ProcessPath := MyFullCMD;
        Result[Length(Result)-1].ProcessParamCmd := '';
      end;
    end;
    // Завершение процесса
    if EndProcess then
    begin
      if EndType = 0 then //WM_CLOSE
        EnumWindows(@ProcCloseEnum, ProcessPIDListArray[I])
      else //WM_QUIT
        EnumWindows(@ProcQuitEnum, ProcessPIDListArray[I]);
    end;
  end;
end;

function EnumThreadWndProc(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  WindowClassName: String;
  WindowClassNameLength: Integer;
  WinCaption: Array [0 .. 255] of Char;
  ThreadProcessWinCaption: String;
  PID: DWORD;
begin
  Result := True;
  ThreadProcessWinCaption := String(LPARAM);
  GetWindowThreadProcessId(hwnd, pid);
  SetLength(WindowClassName, MAX_PATH);
  WindowClassNameLength := GetClassName(hwnd, PChar(WindowClassName), MAX_PATH);
  GetWindowText(hwnd, WinCaption, SizeOf(WinCaption));
  if MatchStrings(LeftStr(WindowClassName, WindowClassNameLength), 'TMain*') and (WinCaption = ThreadProcessWinCaption) then
  begin
    Global_IMProcessPID := PID;
    //MsgInf('EnumThreadWndProc', 'PID процесса родителя: ' + IntToStr(PID) + #10#13 + 'Класс: ' + LeftStr(WindowClassName, WindowClassNameLength) + #10#13 + 'Заголовок окна: ' + WinCaption);
  end;
  // Получим дочерние окна.
  //EnumChildWindows(hwnd, @EnumThreadWndProc, lParam);
end;

{ Получение ID всех потоков указанного процесса }
function GetThreadsOfProcess(APID: Cardinal): TIntegerDynArray;
var
 lSnap: DWord;
 lThread: TThreadEntry32;
begin
  Result := nil;
  if APID <> INVALID_HANDLE_VALUE then
  begin
    lSnap := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if (lSnap <> INVALID_HANDLE_VALUE) then
    begin
      lThread.dwSize := SizeOf(TThreadEntry32);
      if Thread32First(lSnap, lThread) then
      repeat
        if lThread.th32OwnerProcessID = APID then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)] := lThread.th32ThreadID;
        end;
      until not Thread32Next(lSnap, lThread);
      CloseHandle(lSnap);
    end;
  end;
end;

{ Проверка процесса на наличие в памяти по его имени }
function IsProcessRun(ProcessName: String): Boolean; overload;
var
  Snapshot: THandle;
  Proc: TProcessEntry32;
begin
  Result := False;
  Snapshot := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;
  Proc.dwSize := SizeOf(TProcessEntry32);
  if Process32First(Snapshot, Proc) then
  repeat
    if Proc.szExeFile = ProcessName then
    begin
      Result := True;
      Break;
    end;
  until not Process32Next(Snapshot, Proc);
  CloseHandle(Snapshot);
end;

function IsProcessRun(ProcessName, WinCaption: String): Boolean; overload;
var
  Snapshot: THandle;
  Proc: TProcessEntry32;
  lThreads: TIntegerDynArray;
  J: Integer;
begin
  Result := False;
  Snapshot := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;
  Proc.dwSize := SizeOf(TProcessEntry32);
  if Process32First(Snapshot, Proc) then
  repeat
    if ((UpperCase(ExtractFileName(Proc.szExeFile)) = UpperCase(ProcessName))
     or (UpperCase(Proc.szExeFile) = UpperCase(ProcessName))) then
     begin
      // Получение Заголовков окон процесса
      //EnumWindows(@ProcGetCaptionForHandleEnum, FProcessEntry32.th32ProcessID);
      // Получение ClassName и Заголовков окон всех потоков процесса
      Global_IMProcessPID := 0;
      lThreads := GetThreadsOfProcess(Proc.th32ProcessID);
      for J := Low(lThreads) to High(lThreads) do
        EnumThreadWindows(lThreads[J], @EnumThreadWndProc, LPARAM(WinCaption));
      if Global_IMProcessPID = Proc.th32ProcessID then
        //MsgInf('IsProcessRun', 'Найден нужный процесс');
        Result := True;
      // Ends
     end;
  until not Process32Next(Snapshot, Proc);
  CloseHandle(Snapshot);
end;

{ Завершение процесса по имени }
function KillTask(ExeFileName: String): Integer;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
     or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),
                        FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

{ Завершение процесса по имени и заголовку окна }
function KillTask(ExeFileName, WinCaption: String): Integer; overload;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  lThreads: TIntegerDynArray;
  J: Integer;
begin
  Result := 0;
  FSnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
     or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
     begin
      // Получение Заголовков окон процесса
      //EnumWindows(@ProcGetCaptionForHandleEnum, FProcessEntry32.th32ProcessID);
      // Получение ClassName и Заголовков окон всех потоков процесса
      Global_IMProcessPID := 0;
      lThreads := GetThreadsOfProcess(FProcessEntry32.th32ProcessID);
      for J := Low(lThreads) to High(lThreads) do
        EnumThreadWindows(lThreads[J], @EnumThreadWndProc, LPARAM(WinCaption));
      if Global_IMProcessPID = FProcessEntry32.th32ProcessID then
        //MsgInf('KillTask', 'Найден нужный процесс');
        Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
      // Ends
     end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

{ Получение PID программы в памяти }
function GetProcessID(ExeFileName: String): Cardinal;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  repeat
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
       or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
    begin
       Result := FProcessEntry32.th32ProcessID;
       Break;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  until not ContinueLoop;
  CloseHandle(FSnapshotHandle);
end;

{ Получение PID для нескольких процессов с одинаковым именем }
{function GetProcessIDMulti(ExeFileName: String): TArrayOfString;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  SetLength(Result, 0);
  //Result := 0;
  FSnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  repeat
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
       or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
    begin
       SetLength(Result, Length(Result)+1);
       Result[Length(Result)-1] := IntToStr(FProcessEntry32.th32ProcessID);
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  until not ContinueLoop;
  CloseHandle(FSnapshotHandle);
end;}

{ Получение PID для нескольких процессов с одинаковым именем }
function GetProcessIDMulti2(ExeFileName: String): TArrayOfCardinal;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  SetLength(Result, 0);
  //Result := 0;
  FSnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  repeat
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
       or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
    begin
       SetLength(Result, Length(Result)+1);
       Result[Length(Result)-1] := FProcessEntry32.th32ProcessID;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  until not ContinueLoop;
  CloseHandle(FSnapshotHandle);
end;

{ Получаем полный путь до приложения по его PID }
function GetProcessFileName(PID: DWord; FullPath: Boolean=True): String;
var
  Handle: THandle;
begin
  Result := '';
  Handle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);
  try
    if Handle <> 0 then
    begin
      SetLength(Result, MAX_PATH);
      if FullPath then
      begin
        if GetModuleFileNameEx(Handle, 0, PChar(Result), MAX_PATH) > 0 then
          SetLength(Result, StrLen(PChar(Result)))
        else
          Result := '';
      end
      else
      begin
        if GetModuleBaseNameA(Handle, 0, PAnsiChar(Result), MAX_PATH) > 0 then
          SetLength(Result, StrLen(PChar(Result)))
        else
          Result := '';
      end;
    end;
  finally
    CloseHandle(Handle);
  end;
end;

{ Получаем команду запуска программы с полным путем по её PID }
function GetProcessCmdLine(PID: DWord): String;
var
  hProcess: THandle;
  pProcBasicInfo: PROCESS_BASIC_INFORMATION;
  ReturnLength: DWORD;
  prb: PEB;
  ProcessParameters: PROCESS_PARAMETERS;
  cb: cardinal;
  ws: WideString;
begin
  Result := '';
  if PID = 0 then
    Exit;
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, PID);
  if (hProcess <> 0) then
  try
    if (NtQueryInformationProcess(hProcess,ProcessBasicInformation,
                               @pProcBasicInfo,
                               sizeof(PROCESS_BASIC_INFORMATION),@ReturnLength) = STATUS_SUCCESS) then
  begin
   if ReadProcessMemory(hProcess,pProcBasicInfo.PebBaseAddress,@prb,sizeof(PEB),cb) then
     if ReadProcessMemory(hProcess,prb.ProcessParameters,@ProcessParameters,sizeof(PROCESS_PARAMETERS),cb) then
     begin
       SetLength(ws,(ProcessParameters.CommandLine.Length div 2));
       if ReadProcessMemory(hProcess,ProcessParameters.CommandLine.Buffer,
                            PWideChar(ws),ProcessParameters.CommandLine.Length,cb) then
       Result := String(ws)
     end
  end
 finally
  Closehandle(hProcess);
 end
end;

{ Включаем себе SeDebugPrivilege }
function SetProcessDebugPrivelege: Boolean;
var
  hToken: THandle;
  tp: TTokenPrivileges;
  rl: Cardinal;
begin
  Result := False;
  if not OpenProcessToken(GetCurrentProcess,TOKEN_ADJUST_PRIVILEGES,hToken) then
    Exit;
  try
    if not LookupPrivilegeValue(nil,'SeDebugPrivilege', tp.Privileges[0].Luid) then
      Exit;
    tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    tp.PrivilegeCount := 1;
    Result := AdjustTokenPrivileges(hToken,false,tp,0,nil,rl) and (GetLastError=0);
  finally
    CloseHandle(hToken);
  end
end;

// Завершение любых процессов в том числе системных.
// Включение, приминение и отключения привилегии.
// Для примера возьмем привилегию отладки приложений 'SeDebugPrivilege'
// необходимую для завершения ЛЮБЫХ процессов в системе (завершение процесов
// созданных текущим пользователем привилегия не нужна.
// Название добавление/удаление привилгии немного неправильные.  Привилегия или
// есть в токене процесса или ее нет. Если привилегия есть, то она может быть в
// двух состояниях - или включеная или отключеная. И в этом примере мы только
// включаем или выключаем необходимую привилегию, а не добавляем ее.
function ProcessTerminate(dwPID: Cardinal): Boolean;
var
 hToken:THandle;
 SeDebugNameValue:Int64;
 tkp:TOKEN_PRIVILEGES;
 ReturnLength:Cardinal;
 hProcess:THandle;
begin
  Result := False;
  // Включаем привилегию SeDebugPrivilege
  // Для начала получаем токен нашего процесса
  if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken ) then
    Exit;
  // Получаем LUID привилегии
  if not LookupPrivilegeValue(nil, 'SeDebugPrivilege', SeDebugNameValue) then
  begin
    CloseHandle(hToken);
    Exit;
  end;
  tkp.PrivilegeCount := 1;
  tkp.Privileges[0].Luid := SeDebugNameValue;
  tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  // Добавляем привилегию к нашему процессу
  AdjustTokenPrivileges(hToken, False, tkp, SizeOf(tkp), tkp, ReturnLength);
  if GetLastError() <> ERROR_SUCCESS then
    Exit;
  // Завершаем процесс. Если у нас есть SeDebugPrivilege, то мы можем
  // завершить и системный процесс
  // Получаем дескриптор процесса для его завершения
  hProcess := OpenProcess(PROCESS_TERMINATE, FALSE, dwPID);
  if hProcess = 0 then
    Exit;
  // Завершаем процесс
  if not TerminateProcess(hProcess, DWORD(-1)) then
    Exit;
  CloseHandle( hProcess );
  // Отключаем привилегию
  tkp.Privileges[0].Attributes := 0;
  AdjustTokenPrivileges(hToken, FALSE, tkp, SizeOf(tkp), tkp, ReturnLength);
  if GetLastError() <> ERROR_SUCCESS then
    Exit;
  Result := True;
end;

function StringToParts(sString: String; tdDelim: TDelim): TArrayOfString;
var
  iCounter,iBegin:Integer;
begin
  if length(sString)>0 then
  begin
    include(tdDelim, #0);
    iBegin:=1;
    SetLength(Result, 0);
    for iCounter:=1 to Length(sString)+1 do
    begin
      if(sString[iCounter] in tdDelim) then
      begin
        SetLength(Result, Length(Result)+1);
        Result[Length(Result)-1] := Copy(sString, iBegin, iCounter-iBegin);
        iBegin := iCounter+1;
      end;
    end;
  end;
end;

{ Edit1.Text := ExtractWord(ExtractWord('admin:login:password', ':', 3)); //'password' }
function ExtractWord(const AString: string; const ADelimiter: Char; const ANumber: integer): string;
var
  i, j, k: integer;
begin
  i := 1;
  k := 1;
  while k <> ANumber do
  begin
    if AString[i] = ADelimiter then
    begin
      Inc(k);
    end;
    Inc(i);
  end;
  j := i + 1;
  while (j <= Length(AString)) and (AString[j] <> ADelimiter) do
    Inc(j);
  Result := Copy(AString, i, j - i);
end;

{ Функция возвращает путь до пользовательской временной папки }
function GetUserTempPath: WideString;
var
  UserPath: WideString;
begin
  Result := '';
  SetLength(UserPath, MAX_PATH);
  GetTempPath(MAX_PATH, PChar(UserPath));
  GetLongPathName(PChar(UserPath), PChar(UserPath), MAX_PATH);
  SetLength(UserPath, StrLen(PChar(UserPath)));
  Result := UserPath;
end;

begin
end.
