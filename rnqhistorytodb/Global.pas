{ ############################################################################ }
{ #                                                                          # }
{ #  RnQ HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  Windows, SysUtils, IniFiles,  DCPcrypt2, DCPblockciphers, DCPsha1, DCPdes, DCPmd5,
  Messages, XMLIntf, XMLDoc, FSMonitor;

type
  TCopyDataType = (cdtString = 0, cdtImage = 1, cdtRecord = 2);

const
  PluginVersion = '2.4';
  PluginName = 'RnQHistoryToDB';
  DefaultDBAddres = 'db01.im-history.ru';
  DefaultDBName = 'imhistory';
  ININame = '\HistoryToDB.ini';
  DefININame = 'DefaultUser.ini';
  MesLogName = '\HistoryToDBMes.sql';
  ErrLogName = '\HistoryToDBErr.log';
  ContactListName = 'ContactList.csv';
  ProtoListName = 'ProtoList.csv';
  MSG : WideString = '%s, %s (%s) '+#13#10+'%s';
  MSG_LOG : WideString = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, ''%s'', ''%s'', ''%s'', null);';
  MSG_LOG_ORACLE : WideString = 'insert into uin_%s values (null, %s, ''%s'', ''%s'', ''%s'', ''%s'', %s, %s, ''%s'', ''%s'', null)';
  // ��������� ���� (01/01/1970) Unix Timestamp ��� ������� �����������
  UnixStartDate: TDateTime = 25569.0;
  // ���� ��� ���������� ������� ���������� HistoryToDBSync � HistoryToDBViewer
  EncryptKey = 'jsU6s2msoxghsKsn7';
  // ��� �������������� ���������
  WM_LANGUAGECHANGED = WM_USER + 1;
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  // �������
  EnableDebug = False;
  DebugLogPath = 'C:\';
  DebugLogName = 'HistoryToDBDebug.log';
  // �������������
  ThankYouText_Rus = '���� ���������� �� �������� ������������ �������.' + #13#10 +
                    '������ ������� (UksusoFF) �� �������� ������������ ������� � ����� ����.' + #13#10 +
                    '����� �������� �� �������� ������������ �������.' + #13#10 +
                    '�������� �. (HDHMETRO) �� �������� ������������ �������.' + #13#10 +
                    'Providence �� �������� ������������ ������� � ����� ����.' + #13#10 +
                    'Cy6 �� ������ � ���������� ������� ������� RnQ.';
  ThankYouText_Eng = 'Anna Nikiforova for active testing of plug-in.' + #13#10 +
                    'Kirill Uksusov (UksusoFF) for active testing of plug-in and new ideas.' + #13#10 +
                    'Igor Guryanov for active testing of plug-in.' + #13#10 +
                    'Vyacheslav S. (HDHMETRO) for active testing of plug-in.' + #13#10 +
                    'Providence for active testing of plug-in and new ideas.' + #13#10 +
                    'Cy6 for help in implementing the import history RnQ.';

var
  ERR_SAVE_TO_DB_CONNECT_ERR : WideString = '[%s] ������: �� ������ ������������ � ��. ������: %s';
  ERR_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] ������: �� �� ��������� ������������. ���������� ��������� � �� ����������.';
  ERR_TEMP_SAVE_TO_DB_SERVICE_MODE : WideString = '[%s] ������: �� �� ��������� ������������. ���������� ���������� ��������� � �� ����������.';
  ERR_READ_DB_CONNECT_ERR : WideString = '[%s] ������: �� ������ ������������ � ��. ������: %s';
  ERR_READ_DB_SERVICE_MODE : WideString = '[%s] ������: �� �� ��������� ������������. ������ ������� ��������� ����������.';
  ERR_LOAD_MSG_TO_DB : WideString = '[%s] ������ ������ ��������� �� ���-����� � ��: %s';
  ERR_SEND_UPDATE : WideString = '[%s] ������ ��� ������� ����������: %s';
  ERR_NO_FOUND_VIEWER : WideString = '����������� ������� %s �� ������.';
  LOAD_TEMP_MSG : WideString = '[%s] � ����� %s ������� %s ���������; ��������� � ��: %s; �����������: %s';
  LOAD_TEMP_MSG_NOLOGFILE : WideString = '[%s] ���� ���������� ��������� %s �� ������.';
  WriteErrLog, AniEvents, EnableHistoryEncryption, HideSyncIcon, ShowPluginButton: Boolean;
  SyncMethod, SyncInterval, NumLastHistoryMsg, SyncTimeCount, SyncMessageCount: Integer;
  DBType, DBAddress, DBSchema, DBPort, DBName, DBUserName, DBPasswd, DefaultLanguage: String;
  Global_AccountUIN, Global_CurrentAccountUIN: Integer;
  Global_AccountName, Global_CurrentAccountName: WideString;
  ProfilePath: String;
  Global_AboutForm_Showing: Boolean;
  Global_SettingsForm_Showing: Boolean;
  // ��� �������������� ���������
  CoreLanguage: String;
  SettingsFormHandle: HWND;
  AboutFormHandle: HWND;
  LangDoc: IXMLDocument;
  PluginPath: String = '';
  // ����������
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;

function BoolToIntStr(b: Boolean): String;
function IsNumber(const S: String): Boolean;
function StringToWChar(const value: AnsiString): PWideChar;
function DateTimeToUnix(ConvDate: TDateTime): Longint;
function UnixToDateTime(USec: Longint): TDateTime;
function MatchStrings(Source, Pattern: String): Boolean;
function ReadCustomINI(INIPath, CustomParams, DefaultParamsStr: String): String;
function EncryptMD5(Str: String): String;
function EncryptStr(const Str: String): String;
function SearchMainWindow(MainWindowName: pWideChar): Boolean;
procedure EncryptInit;
procedure EncryptFree;
procedure OnSendMessageToAllComponent(Msg: String);
procedure OnSendMessageToOneComponent(WinName, Msg: String);
procedure WriteInLog(DllPath: String; TextString: WideString; LogType: Integer);
procedure LoadINI(INIPath: String; NotSettingsForm: Boolean);
procedure WriteCustomINI(INIPath, CustomParams, ParamsStr: String);
procedure ProfileDirChangeCallBack(pInfo: TInfoCallBack);
procedure IMDelay(Value: Cardinal);
// ��� �������������� ���������
procedure MsgDie(Caption, Msg: WideString);
procedure MsgInf(Caption, Msg: WideString);
function GetLangStr(StrID: String): WideString;

implementation

function BoolToIntStr(b: boolean): string;
begin
  if b then
    result := '1'
  else
    result := '0'
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

function StringToWChar(const value: AnsiString): PWideChar;
begin
  result := PWideChar(WideString(value));
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

// LogType = 0 - ��������� ����������� � ���� MesLogName
// LogType = 1 - ������ ����������� � ���� ErrLogName
// LogType = 2 - ��������� ����������� � ���� DebugLogName
// LogType = 3 - ��������� ����������� � ���� ContactListName
// LogType = 4 - ��������� ����������� � ���� ProtoListName
procedure WriteInLog(DllPath: String; TextString: WideString; LogType: Integer);
var
  Path: WideString;
  TF: TextFile;
begin
  if LogType = 0 then
    Path := DllPath + MesLogName
  else if LogType = 1 then
    Path := DllPath + ErrLogName
  else if LogType = 2 then
    Path := DllPath + DebugLogName
  else if LogType = 3 then
    Path := DllPath + ContactListName
  else
    Path := DllPath + ProtoListName;
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
   Ini := TIniFile.Create(Path);
   DBType := INI.ReadString('Main', 'DBType', 'mysql');  // mysql ��� postgresql
   DBAddress := INI.ReadString('Main', 'DBAddress', DefaultDBAddres);
   DBSchema := INI.ReadString('Main', 'DBSchema', 'username');
   DBPort := INI.ReadString('Main', 'DBPort', '3306');  // 3306 ��� mysql, 5432 ��� postgresql
   DBName := INI.ReadString('Main', 'DBName', DefaultDBName);
   // ���� �������� LoadINI �� � ����� SettingsForm, �� DBName ������ ��� ������ <ProfilePluginPath> � <PluginPath>
   if NotSettingsForm then
   begin
      // ������ ��������� � ������ DBName
      if MatchStrings(DBName,'<ProfilePluginPath>*') then
        DBName := StringReplace(DBName,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
      else if MatchStrings(DBName,'<PluginPath>*') then
        DBName := StringReplace(DBName,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall]);
      // End
   end;
   DBUserName := INI.ReadString('Main', 'DBUserName', 'username');
   //DBPasswd := INI.ReadString('Main', 'DBPasswd', 'password');
   SyncMethod := INI.ReadInteger('Main', 'SyncMethod', 1);
   SyncInterval := INI.ReadInteger('Main', 'SyncInterval', 0);
   NumLastHistoryMsg := INI.ReadInteger('Main', 'NumLastHistoryMsg', 6);

   Temp := INI.ReadString('Main', 'WriteErrLog', '1');
   if Temp = '1' then WriteErrLog := true
   else WriteErrLog := false;

   Temp := INI.ReadString('Main', 'ShowAnimation', '1');
   if Temp = '1' then AniEvents := true
   else AniEvents := false;

   Temp := INI.ReadString('Main', 'EnableHistoryEncryption', '0');
   if Temp = '1' then EnableHistoryEncryption := true
   else EnableHistoryEncryption := false;

   DefaultLanguage := INI.ReadString('Main', 'DefaultLanguage', 'Russian');

   Temp := INI.ReadString('Main', 'HideHistorySyncIcon', '0');
   if Temp = '1' then HideSyncIcon := true
   else HideSyncIcon := false;

   SyncTimeCount := INI.ReadInteger('Main', 'SyncTimeCount', 40);
   SyncMessageCount := INI.ReadInteger('Main', 'SyncMessageCount', 50);

   Temp := INI.ReadString('Main', 'ShowPluginButton', '1');
   if Temp = '1' then ShowPluginButton := true
   else ShowPluginButton := false;

  end
 else
  begin
   INI := TIniFile.Create(path);
    // �������� ��-���������
    DBType := 'mysql';
    DBName := DefaultDBName;
    DBUserName := 'username';
    SyncMethod := 1;
    SyncInterval := 0;
    SyncMessageCount := 50;
    WriteErrLog := True;
    AniEvents := True;
    EnableHistoryEncryption := False;
    ShowPluginButton := True;
    // ��������� ���������
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
    INI.WriteString('Main', 'AddSpecialContact', '1');
    INI.WriteString('Main', 'MaxErrLogSize', '20');
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

{ ��������� ������ �������� ��������� � ���� �������� }
procedure WriteCustomINI(INIPath, CustomParams, ParamsStr: String);
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ininame;
  INI := TIniFile.Create(Path);
  try
    INI.WriteString('Main', CustomParams, ParamsStr);
  finally
    INI.Free;
  end;
end;

{ ������� ������ �������� ��������� �� ����� �������� }
function ReadCustomINI(INIPath, CustomParams, DefaultParamsStr: String): String;
var
  Path: String;
  INI: TIniFile;
begin
  Result := DefaultParamsStr;
  Path := INIPath + ININame;
  INI := TIniFile.Create(Path);
  try
    Result := INI.ReadString('Main', CustomParams, DefaultParamsStr);
  finally
    INI.Free;
  end;
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
  EncryptMsg: String;
begin
  EncryptMsg := EncryptStr(Msg);
  // ���� ���� HistoryToDBViewer � �������� ��� �������
  HToDB := FindWindow(nil,'HistoryToDBViewer for RnQ');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  // ���� ���� HistoryToDBSync � �������� ��� �������
  HToDB := FindWindow(nil,'HistoryToDBSync for RnQ');
  if HToDB <> 0 then
  begin
    copyDataStruct.dwData := Integer(cdtString);
    copyDataStruct.cbData := 2*Length(EncryptMsg);
    copyDataStruct.lpData := PChar(EncryptMsg);
    SendMessage(HToDB, WM_COPYDATA, 0, Integer(@copyDataStruct));
  end;
  // ���� ���� HistoryToDBImport � �������� ��� �������
  HToDB := FindWindow(nil,'HistoryToDBImport for RnQ');
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

{������� ������������ ��������� ���� �����. ������ ������
����� ���� �����, �� ��� �� ������ ��������� �������� ������������ (* � ?).
������ ������ (������� �����) ����� ��������� ��������� ����� �������.
��� �������: MatchStrings('David Stidolph','*St*') ��������� True.
����� ������������� C-���� Sean Stanley
����� �������� �� Delphi David Stidolph}
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
    Result := 'String not found.';
end;

{ ���������� ��������� ������ � �������� ������� }
procedure ProfileDirChangeCallBack(pInfo: TInfoCallBack);
var
  SettingsFormRequest: String;
begin
  SettingsFormRequest := ReadCustomINI(ProfilePath, 'SettingsFormRequestSend', '0');
  if EnableDebug then WriteInLog(DebugLogPath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ProfileDirChangeCallBack: �������� SettingsFormRequestSend = ' + SettingsFormRequest, 2);
  if EnableDebug then WriteInLog(DebugLogPath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ProfileDirChangeCallBack: FAction = ' + IntToStr(pInfo.FAction) + ' | FOldFileName = ' + pInfo.FOldFileName + ' | FNewFileName = ' + pInfo.FNewFileName, 2);
  if (pInfo.FAction = 3) and (pInfo.FNewFileName = 'HistoryToDB.ini') and (SettingsFormRequest = '0') then
  begin
    if EnableDebug then WriteInLog(DebugLogPath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ProfileDirChangeCallBack: ��������� HistoryToDB.ini ����������', 2);
    IMDelay(500);
    LoadINI(ProfilePath, true);
  end;
end;

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

{ �������� �� �������� ��������� }
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

begin
end.
