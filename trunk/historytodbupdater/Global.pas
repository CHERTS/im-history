{ ################################################################################ }
{ #                                                                              # }
{ #  ���������� � ��������� ������ �������� IM-History - HistoryToDBUpdater v1.0 # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

unit Global;

{$I jedi.inc}

interface

uses
  Windows, Forms, Classes, SysUtils, IniFiles, DCPcrypt2, DCPblockciphers, DCPsha1,
  DCPdes, DCPmd5, TypInfo, Messages, XMLIntf, XMLDoc, StrUtils, Types, TLHELP32, PsAPI, NTNative;

type
  TWinVersion = (wvUnknown,wv95,wv98,wvME,wvNT3,wvNT4,wvW2K,wvXP,wv2003,wvVista,wv7,wv2008,wv8);
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
  ProgramsVer : WideString = '2.5.0.0';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  ININame = 'HistoryToDB.ini';
  ErrLogName = 'HistoryToDBUpdaterErr.log';
  DebugLogName = 'HistoryToDBUpdaterDebug.log';
  // ��������� ���� (01/01/1970) Unix Timestamp ��� ������� �����������
  UnixStartDate: TDateTime = 25569.0;
  // ����� ��� ����������� ��������� DBPasswd �� �������
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // ��� �������������� ���������
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  dirSQLUpdate = 'update\';
  defaultLangFile = 'English.xml';
  // End
  WM_MSGBOX = WM_USER + 2;
  uURL = 'http://im-history.ru/update/get.php?file=HistoryToDB-Update';
  {$IFDEF WIN32}
  PlatformType = 'x86';
  {$ELSE}
  PlatformType = 'x64';
  {$ENDIF}
var
  WriteErrLog: Boolean;
  EnableDebug, AlphaBlendEnable: Boolean;
  MaxErrLogSize, AlphaBlendEnableValue: Integer;
  DBType, DefaultLanguage, IMClientType: String;
  PluginPath, ProfilePath: WideString;
  Global_MainForm_Showing, Global_AboutForm_Showing: Boolean;
  Global_IMProcessPID: DWORD;
  // ������
  IMUseProxy, IMProxyAuth: Boolean;
  IMProxyAddress, IMProxyPort, IMProxyUser, IMProxyUserPasswd: String;
  DBUserName, MyAccount: String;
  IMClientPlatformType: String;
  UpdateServer: String;
  // ����������
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // ��� �������������� ���������
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
function GetProcessCmdLine(dwProcessId : DWORD): String;
function SetProcessDebugPrivelege: Boolean;
function EndProcess(IMClientExeName: String; EndType: Integer; EndProcess: Boolean): TProcessInfoArray;
function GetUserTempPath: WideString;
//function ProcGetCaptionForHandleEnum(hwnd: THandle; data: Pointer):BOOL;stdcall;
function EnumThreadWndProc(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
function StringToParts(sString:String; tdDelim:TDelim): TArrayOfString;
function ExtractWord(const AString: string; const ADelimiter: Char; const ANumber: integer): string;
function DetectWinVersion: TWinVersion;
function DetectWinVersionStr: String;
function GetMyExeVersion: String;
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
procedure MakeTransp(winHWND: HWND);
procedure OnSendMessageToAllComponent(Msg: String);
procedure IMDelay(Value: Cardinal);
procedure OnSendMessageToOneComponent(WinName, Msg: String);
// ��� �������������� ���������
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

// ������� ����������� DateTime � Unix Timestamp
function DateTimeToUnix(ConvDate: TDateTime): Longint;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
end;

// ������� ����������� Unix Timestamp � DateTime
function UnixToDateTime(USec: Longint): TDateTime;
begin
  Result := (Usec / 86400) + UnixStartDate;
end;

// ������� ��� ������������� ������������ � ������
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

// ���������� �����������
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

// ����������� �������
procedure EncryptFree;
begin
  if Assigned(Cipher) then
  begin
    Cipher.Burn;
    Cipher.Free;
  end;
end;

// ������������� ������
function EncryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.EncryptString(Str);
  end;
end;

// �������������� ������
function DecryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.DecryptString(Str);;
  end;
end;

// ������� MD5 ������
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

// LogType = 0 - ������ ����������� � ���� ErrLogName
// LogType = 1 - ��������� ����������� � ���� DebugLogName
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

// ��������� ���������
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
var
  Path: WideString;
  Temp: String;
  INI: TIniFile;
begin
  // ��������� ������� ��������
  if not DirectoryExists(INIPath) then
    CreateDir(INIPath);
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
    INI := TIniFile.Create(Path);
    try
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
      IMProxyUserPasswd := INI.ReadString('Proxy', 'ProxyUserPasswd', '');
      if IMProxyUserPasswd <> '' then
        IMProxyUserPasswd := DecryptStr(IMProxyUserPasswd);

      IMClientPlatformType := INI.ReadString('Main', 'IMClientPlatformType', PlatformType);
      UpdateServer := INI.ReadString('Updater', 'UpdateServer', uURL);
    finally
      INI.Free;
    end;
  end
  else
  begin
    INI := TIniFile.Create(path);
    try
      // �������� ��-���������
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
      IMProxyUserPasswd := '';
      // ��������� ���������
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
      INI.WriteString('Proxy', 'ProxyUserPasswd', IMProxyUserPasswd);
      INI.WriteString('Updater', 'UpdateServer', uURL);
    finally
      INI.Free;
    end;
  end;
end;

{������� ������������ ��������� ���� �����. ������ ������
����� ���� �����, �� ��� �� ������ ��������� �������� ������������ (* � ?).
������ ������ (������� �����) ����� ��������� ��������� ����� �������.
��� �������: MatchStrings('David Stidolph','*St*') ��������� True.
����� ������������� C-���� Sean Stanley
����� �������� �� Delphi David Stidolph}
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

{ ������� ��� ��������� ����� ����� �� ���� ��� ��� � ��� �����������.
  ���������� ��� �����, ��� ��� � ��� �����������.
  ������� ���������:
  FileName - ��� �����, ������� ���� ����������
  ShowExtension - ���� TRUE, �� ������� ��������� �������� ��� �����
  (��� ������� ���� ������� � ����), � ����������� ����� �����, �����, ���������
  �������� ��� �����, ��� ���������� ����� �����. }
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

{ ������������ ���� MessageBox }
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

// ��� �������������� ���������
procedure MsgDie(Caption, Msg: WideString);
begin
  if AlphaBlendEnable then
    PostMessage(GetForegroundWindow, WM_USER + 2, 0, 0);
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONERROR);
end;

// ��� �������������� ���������
procedure MsgInf(Caption, Msg: WideString);
begin
  if AlphaBlendEnable then
    PostMessage(GetForegroundWindow, WM_USER + 2, 0, 0);
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONINFORMATION);
end;

// ��� �������������� ���������
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

{ ������� ��������� ������ S �� �����, ����������� ���������-�������������,
���������� � ������ Sep. ������� ���������� ������ ��������� �����, ���
���� �� ������ S ��������� ��������� ����� �� ���������� ����� }
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

{ ��������� ������ �������� ��������� � ���� �������� }
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
    // ���� ���� ���� ��������� �������� ��� ��� �����-������ �������
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

{ ������� ������ �������� ��������� �� ����� �������� }
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

// ���� ���� �� ����������, �� ������ ������� ����� ������� ����� -1
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

{ ����� ���� ��������� }
function SearchMainWindow(MainWindowName: pWideChar): Boolean;
var
  HToDB: HWND;
begin
  // ���� ����
  HToDB := FindWindow(nil, MainWindowName);
  if HToDB <> 0 then
    Result := True
  else
    Result := False
end;

{ ��������� ��� �������� ��������� ��������� }
{ ����������� �������:
  001  - ���������� ��������� �� ����� HistoryToDB.ini
  002  - ������������� �������
  003  - ������� ��� ���������� �������
  0040 - �������� ��� ���� ������� (����� AntiBoss)
  0041 - ������ ��� ���� ������� (����� AntiBoss)
  0050 - ��������� ���������� MD5-�����
  0051 - ��������� ���������� MD5-����� � �������� ����������
  0060 - ������� ������ �������
  0061 - ������ ������� ��������
  007  - �������� �������-���� � ��
  008  - �������� ������� ��������/����
         ������ �������:
           ��� ������� ��������:
             008|0|UserID|UserName|ProtocolType
           ��� ������� ����:
             008|2|ChatName
  009 - ��������� ������� ��� ���������� �������.
}
procedure OnSendMessageToAllComponent(Msg: String);
var
  HToDB: HWND;
  copyDataStruct : TCopyDataStruct;
  EncryptMsg, WinName: String;
begin
  EncryptMsg := EncryptStr(Msg);
  WinName := 'HistoryToDBViewer for ' + IMClientType;
  // ���� ���� HistoryToDBViewer � �������� ��� �������
  HToDB := FindWindow(nil, pChar(WinName));
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  WinName := 'HistoryToDBSync for ' + IMClientType;
  // ���� ���� HistoryToDBSync � �������� ��� �������
  HToDB := FindWindow(nil, pChar(WinName));
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  WinName := 'HistoryToDBImport for ' + IMClientType;
  // ���� ���� HistoryToDBImport � �������� ��� �������
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
  // ���� ���� HistoryToDBViewer � �������� ��� �������
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
  { ���������
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
  else if MatchStrings(Proto, '���������*') then
    ProtoType := 6
  else if MatchStrings(Proto, '���������*') then
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

{ �������� �� �������� ��������� }
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

{ �������� ��������� ����� WM_CLOSE �� � PID }
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

{ �������� ��������� ����� WM_QUIT �� � PID }
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

{ ������� ���������� WM_QUIT ��������
  � ���������� TArrayOfString �� ������� ������ ����� + ��������� �������
  ���� ���������
  EndType = 0 - WM_CLOSE
  EndType = 1 - WM_QUIT
   }
function EndProcess(IMClientExeName: String; EndType: Integer; EndProcess: Boolean): TProcessInfoArray;
var
  I: Integer;
  ProcessPIDListArray: TArrayOfCardinal;
  MyFullCMD, MyCMD, ProcessCmdLine: String;
begin
  SetLength(Result, 0);
  SetLength(ProcessPIDListArray, 0);
  ProcessPIDListArray := GetProcessIDMulti2(IMClientExeName);
  for I := 0 to High(ProcessPIDListArray) do
  begin
    SetLength(Result, Length(Result)+1);
    Result[Length(Result)-1].ProcessName := IMClientExeName;
    Result[Length(Result)-1].PID := ProcessPIDListArray[I];
    ProcessCmdLine := GetProcessCmdLine(ProcessPIDListArray[I]);
    if ProcessCmdLine = '' then
    begin

      if (IMClientExeName = 'qip.exe') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\QIP 2012\qip.exe"'
      else if (IMClientExeName = 'qip.exe') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files (x86)\QIP 2012\qip.exe"'

      else if (IMClientExeName = 'miranda32.exe') and (IMClientType = 'Miranda') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda IM\miranda32.exe"'
      else if (IMClientExeName = 'miranda32.exe') and (IMClientType = 'Miranda') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files (x86)\Miranda IM\miranda32.exe"'
      else if (IMClientExeName = 'miranda64.exe') and (IMClientType = 'Miranda') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda IM\miranda32.exe"'
      else if (IMClientExeName = 'miranda64.exe') and (IMClientType = 'Miranda') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda IM\miranda32.exe"'

      else if (IMClientExeName = 'miranda32.exe') and (IMClientType = 'MirandaNG') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda NG\miranda32.exe"'
      else if (IMClientExeName = 'miranda32.exe') and (IMClientType = 'MirandaNG') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files (x86)\Miranda NG\miranda32.exe"'
      else if (IMClientExeName = 'miranda64.exe') and (IMClientType = 'MirandaNG') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda NG\miranda32.exe"'
      else if (IMClientExeName = 'miranda64.exe') and (IMClientType = 'MirandaNG') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Miranda NG\miranda32.exe"'

      else if (IMClientExeName = 'skype.exe') and (DetectWinVersionStr = 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files (x86)\Skype\Phone\skype.exe"'
      else if (IMClientExeName = 'skype.exe') and (DetectWinVersionStr <> 'Windows 7') then
        ProcessCmdLine := '"C:\Program Files\Skype\Phone\skype.exe"'
      else
        ProcessCmdLine := IMClientExeName;
    end;
    Result[Length(Result)-1].ProcessFullCmd := ProcessCmdLine;
    //MsgInf('EndProcess', 'ProcessName: ' + Result[Length(Result)-1].ProcessName + #13 + 'PID: ' + IntToStr(Result[Length(Result)-1].PID) + #13 + 'ProcessFullCmd: ' + Result[Length(Result)-1].ProcessFullCmd);
    //Result[Length(Result)-1] := GetProcessFileName(StrToInt(ProcessListArray[I]), True);
    // ���� � ������ CMD ����
    // "C:/Program Files/PostgreSQL/9.1/bin/postgres.exe" "--forklog" "244" "248"
    // ���
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
      // ���� � ������ CMD ����
      // C:\WINDOWS\system32\svchost -k DcomLaunch
      if Pos(' ', MyFullCMD) > 0 then
      begin
        MyCMD := Copy(MyFullCMD, 1, Pos(' ', MyFullCMD)-1);
        Delete(MyFullCMD, 1, Pos(' ', MyFullCMD));
        Result[Length(Result)-1].ProcessPath := MyCMD;
        Result[Length(Result)-1].ProcessParamCmd := MyFullCMD;
      end
      // ���� � ������ CMD ����
      // C:\WINDOWS\system32\lsass.exe
      else
      begin
        Result[Length(Result)-1].ProcessPath := MyFullCMD;
        Result[Length(Result)-1].ProcessParamCmd := '';
      end;
    end;
    // ���������� ��������
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
    //MsgInf('EnumThreadWndProc', 'PID �������� ��������: ' + IntToStr(PID) + #10#13 + '�����: ' + LeftStr(WindowClassName, WindowClassNameLength) + #10#13 + '��������� ����: ' + WinCaption);
  end;
  // ������� �������� ����.
  //EnumChildWindows(hwnd, @EnumThreadWndProc, lParam);
end;

{ ��������� ID ���� ������� ���������� �������� }
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

{ �������� �������� �� ������� � ������ �� ��� ����� }
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
      // ��������� ���������� ���� ��������
      //EnumWindows(@ProcGetCaptionForHandleEnum, FProcessEntry32.th32ProcessID);
      // ��������� ClassName � ���������� ���� ���� ������� ��������
      Global_IMProcessPID := 0;
      lThreads := GetThreadsOfProcess(Proc.th32ProcessID);
      for J := Low(lThreads) to High(lThreads) do
        EnumThreadWindows(lThreads[J], @EnumThreadWndProc, LPARAM(WinCaption));
      if Global_IMProcessPID = Proc.th32ProcessID then
        //MsgInf('IsProcessRun', '������ ������ �������');
        Result := True;
      // Ends
     end;
  until not Process32Next(Snapshot, Proc);
  CloseHandle(Snapshot);
end;

{ ���������� �������� �� ����� }
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

{ ���������� �������� �� ����� � ��������� ���� }
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
      // ��������� ���������� ���� ��������
      //EnumWindows(@ProcGetCaptionForHandleEnum, FProcessEntry32.th32ProcessID);
      // ��������� ClassName � ���������� ���� ���� ������� ��������
      Global_IMProcessPID := 0;
      lThreads := GetThreadsOfProcess(FProcessEntry32.th32ProcessID);
      for J := Low(lThreads) to High(lThreads) do
        EnumThreadWindows(lThreads[J], @EnumThreadWndProc, LPARAM(WinCaption));
      if Global_IMProcessPID = FProcessEntry32.th32ProcessID then
        //MsgInf('KillTask', '������ ������ �������');
        Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
      // Ends
     end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

{ ��������� PID ��������� � ������ }
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

{ ��������� PID ��� ���������� ��������� � ���������� ������ }
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

{ ��������� PID ��� ���������� ��������� � ���������� ������ }
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

{ �������� ������ ���� �� ���������� �� ��� PID }
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

{ �������� ������� ������� ��������� � ������ ����� �� � PID }
function GetProcessCmdLine(dwProcessId : DWORD): String;
const
  STATUS_SUCCESS             = $00000000;
  SE_DEBUG_NAME              = 'SeDebugPrivilege';
  ProcessWow64Information    = 26;
var
  ProcessHandle        : THandle;
  ProcessBasicInfo     : PROCESS_BASIC_INFORMATION;
  ReturnLength         : DWORD;
  lpNumberOfBytesRead  : ULONG_PTR;
  TokenHandle          : THandle;
  lpLuid               : TOKEN_PRIVILEGES;
  OldlpLuid            : TOKEN_PRIVILEGES;
  Rtl : RTL_USER_PROCESS_PARAMETERS;
  Peb : _PEB;
  IsProcessx64 : Boolean;
  {$IFDEF CPUX64}
  PEBBaseAddress32 : Pointer;
  Peb32 : _PEB32;
  Rtl32 : RTL_USER_PROCESS_PARAMETERS32;
  {$ENDIF}
  Ws: WideString;
begin
  Result:='';
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TokenHandle) then
  begin
    try
      if not LookupPrivilegeValue(nil, SE_DEBUG_NAME, lpLuid.Privileges[0].Luid) then
        RaiseLastOSError
      else
      begin
        lpLuid.PrivilegeCount := 1;
        lpLuid.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
        ReturnLength := 0;
        OldlpLuid    := lpLuid;
        // �������� ���� SeDebugPrivilege
        if not AdjustTokenPrivileges(TokenHandle, False, lpLuid, SizeOf(OldlpLuid), OldlpLuid, ReturnLength) then RaiseLastOSError;
      end;

      ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, dwProcessId);
      if ProcessHandle = 0 then RaiseLastOSError
      else
      try
        IsProcessx64 := ProcessIsX64(ProcessHandle);

        {$IFNDEF CPUX64}
        if IsProcessx64 then
          raise Exception.Create('Only 32 bits processes are supported');
        {$ENDIF}

        {$IFDEF CPUX64}
        if IsProcessx64 then
        begin
        {$ENDIF}
          // �������� ������ � PROCESS_BASIC_INFORMATION �� ������ PEB
          if (NtQueryInformationProcess(ProcessHandle,0{=>ProcessBasicInformation},@ProcessBasicInfo, SizeOf(ProcessBasicInfo), @ReturnLength)=STATUS_SUCCESS) and (ReturnLength=SizeOf(ProcessBasicInfo)) then
          begin
            // ������ PEB ���������
            if not ReadProcessMemory(ProcessHandle, ProcessBasicInfo.PEBBaseAddress, @Peb, sizeof(Peb), lpNumberOfBytesRead) then
              RaiseLastOSError
            else
            begin
              // ������ RTL_USER_PROCESS_PARAMETERS ���������
              if not ReadProcessMemory(ProcessHandle, Peb.ProcessParameters, @Rtl, SizeOf(Rtl), lpNumberOfBytesRead) then
               RaiseLastOSError
              else
              begin
                SetLength(ws,(Rtl.CommandLine.Length div 2));
                if not ReadProcessMemory(ProcessHandle,Rtl.CommandLine.Buffer,PWideChar(ws),Rtl.CommandLine.Length,lpNumberOfBytesRead) then
                  RaiseLastOSError
                else
                  Result := String(ws);
              end;
            end;
          end
          else
          RaiseLastOSError;
        {$IFDEF CPUX64}
        end
        else
        begin
          // �������� PEB �����
          if  NtQueryInformationProcess(ProcessHandle, ProcessWow64Information, @PEBBaseAddress32, SizeOf(PEBBaseAddress32), nil)=STATUS_SUCCESS then
          begin
            // ������ PEB ���������
            if not ReadProcessMemory(ProcessHandle, PEBBaseAddress32, @Peb32, sizeof(Peb32), lpNumberOfBytesRead) then
              RaiseLastOSError
            else
            begin
              // ������ RTL_USER_PROCESS_PARAMETERS ���������
              if not ReadProcessMemory(ProcessHandle, Pointer(Peb32.ProcessParameters), @Rtl32, SizeOf(Rtl32), lpNumberOfBytesRead) then
               RaiseLastOSError
              else
              begin
                SetLength(ws,(Rtl32.CommandLine.Length div 2));
                if not ReadProcessMemory(ProcessHandle, Pointer(Rtl32.CommandLine.Buffer), PWideChar(ws), Rtl32.CommandLine.Length, lpNumberOfBytesRead) then
                  RaiseLastOSError
                else
                  Result := String(Ws);
              end;
            end;
          end
          else
          RaiseLastOSError;
        end;
       {$ENDIF}
      finally
        CloseHandle(ProcessHandle);
      end;
    finally
      CloseHandle(TokenHandle);
    end;
  end
  else
  RaiseLastOSError;
end;

{ �������� ���� SeDebugPrivilege }
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

// ���������� ����� ��������� � ��� ����� ���������.
// ���������, ���������� � ���������� ����������.
// ��� ������� ������� ���������� ������� ���������� 'SeDebugPrivilege'
// ����������� ��� ���������� ����� ��������� � ������� (���������� ��������
// ��������� ������� ������������� ���������� �� �����.
// �������� ����������/�������� ��������� ������� ������������.  ���������� ���
// ���� � ������ �������� ��� �� ���. ���� ���������� ����, �� ��� ����� ���� �
// ���� ���������� - ��� ��������� ��� ����������. � � ���� ������� �� ������
// �������� ��� ��������� ����������� ����������, � �� ��������� ��.
function ProcessTerminate(dwPID: Cardinal): Boolean;
var
 hToken:THandle;
 SeDebugNameValue:Int64;
 tkp:TOKEN_PRIVILEGES;
 ReturnLength:Cardinal;
 hProcess:THandle;
begin
  Result := False;
  // �������� ���������� SeDebugPrivilege
  // ��� ������ �������� ����� ������ ��������
  if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken ) then
    Exit;
  // �������� LUID ����������
  if not LookupPrivilegeValue(nil, 'SeDebugPrivilege', SeDebugNameValue) then
  begin
    CloseHandle(hToken);
    Exit;
  end;
  tkp.PrivilegeCount := 1;
  tkp.Privileges[0].Luid := SeDebugNameValue;
  tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  // ��������� ���������� � ������ ��������
  AdjustTokenPrivileges(hToken, False, tkp, SizeOf(tkp), tkp, ReturnLength);
  if GetLastError() <> ERROR_SUCCESS then
    Exit;
  // ��������� �������. ���� � ��� ���� SeDebugPrivilege, �� �� �����
  // ��������� � ��������� �������
  // �������� ���������� �������� ��� ��� ����������
  hProcess := OpenProcess(PROCESS_TERMINATE, FALSE, dwPID);
  if hProcess = 0 then
    Exit;
  // ��������� �������
  if not TerminateProcess(hProcess, DWORD(-1)) then
    Exit;
  CloseHandle( hProcess );
  // ��������� ����������
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

{ ������� ���������� ���� �� ���������������� ��������� ����� }
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

{
DwMajorVersion:DWORD - ������� ����� ������ Windows

  Windows 95      - 4
   Windows 98      - 4
   Windows Me      - 4
   Windows NT 3.51 - 3
   Windows NT 4.0  - 4
   Windows 2000    - 5
   Windows XP      - 5

DwMinorVersion: DWORD - ������� ����� ������

  Windows 95      - 0
   Windows 98      - 10
   Windows Me      - 90
   Windows NT 3.51 - 51
   Windows NT 4.0  - 0
   Windows 2000    - 0
   Windows XP      - 1


DwBuildNumber: DWORD
 Win NT 4 - ����� �����
 Win 9x   - ������� ���� - ������� � ������� ����� ������ / ������� - �����
�����

dwPlatformId: DWORD

 VER_PLATFORM_WIN32s            Win32s on Windows 3.1.
 VER_PLATFORM_WIN32_WINDOWS     Win32 on Windows 9x
 VER_PLATFORM_WIN32_NT          Win32 on Windows NT, 2000


SzCSDVersion:DWORD
  NT - �������� P�har � ���� � ������������� ServicePack
  9x - ���. ����, ����� � �� ����
}
function DetectWinVersion: TWinVersion;
var
  OSVersionInfo : TOSVersionInfo;
begin
  Result := wvUnknown;                      // ����������� ������ ��
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
          7:  case OSVersionInfo.DwMinorVersion of
                1: Result := wv8;           // Windows 8
              end;
        end;
      end;
end;

function DetectWinVersionStr: String;
const
  VersStr : Array[TWinVersion] of String = (
    'Unknown OS',
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
    'Windows Server 2008',
    'Windows 8');
begin
  Result := VersStr[DetectWinVersion];
end;

function GetMyExeVersion: String;
type
  TVerInfo = packed record
    Info: Array[0..47] of Byte;       // ��� 48 ���� ��� �� �����
    Minor,Major,Build,Release: Word;  // ������ ���������
  end;
var
  RS: TResourceStream;
  VI: TVerInfo;
begin
  Result := ProgramsVer;
  try
    RS := TResourceStream.Create(HInstance, '#1', RT_VERSION); // ������ ������
    if RS.Size > 0 then
    begin
      RS.Read(VI, SizeOf(VI)); // ������ ������ ��� �����
      Result := IntToStr(VI.Major)+'.'+IntToStr(VI.Minor)+'.'+IntToStr(VI.Release)+'.'+IntToStr(VI.Build);
    end;
    RS.Free;
  except;
  end;
end;

begin
end.
