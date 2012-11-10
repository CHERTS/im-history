{ ############################################################################ }
{ #                                                                          # }
{ #  �������� ������� HistoryToDBCreateDB v2.0                               # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  Windows, Forms, SysUtils, IniFiles, DCPcrypt2, DCPblockciphers, DCPsha1, DCPdes,
  TypInfo, Messages, XMLIntf, XMLDoc;

const
  ProgramsName = 'IM-History CreateDB';
  ProgramsVer : WideString = '1.8.0.0';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  DefaultSQLiteDBName = 'imhistory.sqlite';
  DefaultFireBirdDBName = 'c:\imhistory.fdb';
  DefaultININame = 'DefaultUser.ini';
  ININame = 'HistoryToDBCreateDB.ini';
  ErrorLogName = 'HistoryToDBCreateDBErr.log';
  // ��������� ���� (01/01/1970) Unix Timestamp ��� ������� �����������
  UnixStartDate: TDateTime = 25569.0;
  // ����� ��� ����������� ��������� DBPasswd �� �������
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // ��� �������������� ���������
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  // �������
  EnableDebug = False;
  DebugLogPath = 'C:\';
  DebugLogName = 'HistoryToDBCreateDBDebug.log';
  {$IFDEF WIN32}
  PlatformType = 'x86';
  {$ELSE}
  PlatformType = 'x64';
  {$ENDIF}
var
  ERR_DB_CONNECT : WideString = '[%s] ������: �� ������ ������������ � ��. ������: %s';
  ERR_NO_DB_CONNECTED : WideString = '[%s] ���������� � �� �� �����������.';
  ERR_SQL_QUERY : WideString = '[%s] ������ SQL �������: %s';
  DBType, DBAddress, DBSchema, DBPort, DBName, DBUserName, DBPasswd, DefaultLanguage: String;
  WriteErrLog, INIFileLoaded: Boolean;
  // ����������
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // ��� �������������� ���������
  CoreLanguage: String;
  MainFormHandle: HWND;
  AboutFormHandle: HWND;
  LangDoc: IXMLDocument;

procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
procedure LoadINI(INIPath: String);
procedure EncryptInit;
procedure EncryptFree;
function MatchStrings(source, pattern: String): Boolean;
function EncryptStr(const Str: String): String;
function DecryptStr(const Str: String): String;
function GetSystemDefaultUILanguage: UINT; stdcall; external kernel32 name 'GetSystemDefaultUILanguage';
function GetSysLang: AnsiString;

// ��� �������������� ���������
procedure MsgDie(Caption, Msg: WideString);
procedure MsgInf(Caption, Msg: WideString);
function GetLangStr(StrID: String): WideString;

implementation

// ���������� �����������
procedure EncryptInit;
begin
  Hash:= TDCP_sha1.Create(nil);
  Hash.Init;
  Hash.UpdateStr(EncryptKey);
  Hash.Final(Digest);
  Hash.Free;
  Cipher := TDCP_3des.Create(nil);
  Cipher.Init(Digest,Sizeof(Digest)*8,nil);
end;

// ����������� �������
procedure EncryptFree;
begin
  Cipher.Burn;
  Cipher.Free;
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

// LogType = 0 - ��������� ����������� � ���� DebugLogName
// LogType = 1 - ��������� ����������� � ���� ErrorLogName
procedure WriteInLog(LogPath: String; TextString: String; LogType: Integer);
var
  Path: WideString;
  f: TextFile;
begin
  if LogType = 0 then
    Path := LogPath + DebugLogName
  else
    Path := LogPath + ErrorLogName;
  Assign(f,Path);
  if FileExists(Path) then
    begin
      Append(f);
      Writeln(f,TextString);
    end
  else
    begin
      Rewrite(f);
      Writeln(f,TextString);
    end;
  CloseFile(f);
end;

// ��������� ���������
procedure LoadINI(INIPath: String);
var
  Path: WideString;
  INI: TIniFile;
begin
  // ��������� ������� ��������
  if not DirectoryExists(INIPath) then
    CreateDir(INIPath);
  Path := INIPath + ININame;
  if FileExists(Path) then
  begin
   Ini := TIniFile.Create(Path);
   try
     DBType := INI.ReadString('Main', 'DBType', 'mysql');  // mysql ��� postgresql
     DBAddress := INI.ReadString('Main', 'DBAddress', DefaultDBAddres);
     DBSchema := INI.ReadString('Main', 'DBSchema', 'username');
     DBPort := INI.ReadString('Main', 'DBPort', '3306');  // 3306 ��� mysql, 5432 ��� postgresql
     DBName := INI.ReadString('Main', 'DBName', DefaultDBName);
     DBUserName := INI.ReadString('Main', 'DBUserName', 'username');
     DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'Russian');
     INIFileLoaded := True;
   finally
    INI.Free;
   end;
  end
  else
    INIFileLoaded := False;
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

// ��� �������������� ���������
procedure MsgDie(Caption, Msg: WideString);
begin
  MessageBoxW(GetForegroundWindow, PWideChar(Msg), PWideChar(Caption), MB_ICONERROR);
end;

// ��� �������������� ���������
procedure MsgInf(Caption, Msg: WideString);
begin
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
    Result := 'String not found';
end;

function GetSysLang: AnsiString;
var
  WinLanguage: Array [0..50] of Char;
begin
  //Result :=   Lo(GetSystemDefaultUILanguage);
  VerLanguageName(GetSystemDefaultLangID, WinLanguage, 50);
  Result := StrPas(WinLanguage);
end;

begin
end.
