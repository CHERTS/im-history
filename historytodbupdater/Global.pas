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

interface

uses
  Windows, Forms, Classes, SysUtils, IniFiles, DCPcrypt2, DCPblockciphers, DCPsha1,
  DCPdes, DCPmd5, TypInfo, Messages, XMLIntf, XMLDoc;

type
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);

const
  ProgramsName = 'HistoryToDBUpdater';
  ProgramsVer : WideString = '1.0.0.0';
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
  defaultLangFile = 'English.xml';
  // End
  WM_MSGBOX = WM_USER + 2;
  uURL = 'http://im-history.ru/update/get.php?file=HistoryToDB-Update';

var
  WriteErrLog, AniEvents, EnableHistoryEncryption, HideSyncIcon: Boolean;
  GlobalHotKeyEnable, EnableDebug, AlphaBlendEnable, SyncWhenExit, GlobalSkypeSupport: Boolean;
  SyncMethod, SyncInterval, NumLastHistoryMsg, SyncTimeCount: Integer;
  MaxErrLogSize, AlphaBlendEnableValue: Integer;
  ReconnectInterval, ReconnectCount: Integer;
  DBType, DBAddress, DBSchema, DBPort, DBName, DBUserName, DBPasswd, DefaultLanguage, IMClientType: String;
  Global_AccountUIN, Global_AccountName, Global_CurrentAccountUIN, Global_CurrentAccountName: WideString;
  Glogal_History_Type, Glogal_Selected_History_Type: Integer;
  Global_ChatName: WideString;
  PluginPath, ProfilePath: WideString;
  Global_MainForm_Showing, Global_LogForm_Showing, Global_AboutForm_Showing, Global_KeyPasswdForm_Showing: Boolean;
  EncryptionKey, EncryptionKeyID, SyncHotKey: String;
  KeyPasswdSaveOnlySession, KeyPasswdSave: Boolean;
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
procedure EncryptInit;
procedure EncryptFree;
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure WriteCustomINI(INIPath, CustomSection, CustomParams, ParamsStr: String);
procedure MakeTransp(winHWND: HWND);
procedure OnSendMessageToAllComponent(Msg: String);
procedure IMDelay(Value: Cardinal);
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
    try
      INI := TIniFile.Create(Path);

      DBType := INI.ReadString('Main', 'DBType', 'Unknown');
      DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'English');
      IMClientType := INI.ReadString('Main', 'IMClientType', 'Unknown');

      Temp := INI.ReadString('Main', 'WriteErrLog', '0');
      if Temp = '1' then WriteErrLog := true
      else WriteErrLog := false;

      MaxErrLogSize := INI.ReadInteger('Main', 'MaxErrLogSize', 20);

      Temp := INI.ReadString('Main', 'EnableDebug', '0');
      if Temp = '1' then EnableDebug := True
      else EnableDebug := False;

      Temp := INI.ReadString('Main', 'AlphaBlend', '0');
      if Temp = '1' then AlphaBlendEnable := True
      else AlphaBlendEnable := False;
      AlphaBlendEnableValue := INI.Readinteger('Main', 'AlphaBlendValue', 255);

    finally
      INI.Free;
    end;
  end
  else
  begin
    try
      INI := TIniFile.Create(path);
      // �������� ��-���������
      DBType := 'Unknown';
      DefaultLanguage := 'English';
      IMClientType := 'Unknown';
      WriteErrLog := True;
      MaxErrLogSize := 20;
      EnableDebug := False;
      AlphaBlendEnable := False;
      AlphaBlendEnableValue := 255;
      // ��������� ���������
      INI.WriteString('Main', 'DBType', DBType);
      INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
      INI.WriteString('Main', 'IMClientType', IMClientType);
      INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
      INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
      INI.WriteString('Main', 'EnableDebug', BoolToIntStr(EnableDebug));
      INI.WriteString('Main', 'AlphaBlend', BoolToIntStr(AlphaBlendEnable));
      INI.WriteInteger('Main', 'AlphaBlendValue', AlphaBlendEnableValue);
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
  //Result :=   Lo(GetSystemDefaultUILanguage);
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

begin
end.
