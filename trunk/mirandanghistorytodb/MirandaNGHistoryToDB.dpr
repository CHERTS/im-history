{ ############################################################################ }
{ #                                                                          # }
{ #  MirandaNG HistoryToDB Plugin v2.5                                       # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

library MirandaNGHistoryToDB;

{$I Global.inc}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  m_api,
  Windows,
  SysUtils,
  XMLIntf,
  XMLDoc,
  ShellApi,
  WideStrUtils,
  JclStringConversions,
  Contacts in 'Contacts.pas',
  Database in 'Database.pas',
  Menu in 'Menu.pas',
  About in 'About.pas',
  MsgExport in 'MsgExport.pas' {ExportForm},
  Global in 'Global.pas',
  FSMonitor in 'FSMonitor.pas',
  MapStream in 'MapStream.pas';

// use it to make plugin unicode-aware
{$DEFINE UNICODE}

// tell Miranda about this plugin ExVersion
function MirandaPluginInfoEx(mirandaVersion:DWORD): PPLUGININFOEX; cdecl;
begin
  PluginInfo.cbSize:= SizeOf(TPLUGININFOEX);
  PluginInfo.shortName:= htdPluginShortName;
  PluginInfo.version:= htdVersion;
  PluginInfo.description:= htdDescription_EN;
  PluginInfo.author:= htdAuthor_EN;
  PluginInfo.authorEmail:= htdAuthorEmail;
  PluginInfo.copyright:= htdCopyright_EN;
  PluginInfo.homepage:= htdHomePageURL;
  PluginInfo.flags:= UNICODE_AWARE;
  PluginInfo.uuid:= MIID_HISTORYTODBDLL;
  Result := @PluginInfo;
end;

var
  {$ifdef REPLDEFHISTMOD}
  PluginInterfaces: array[0..1] of TGUID;
  {$else}
  PluginInterfaces: array[0] of TGUID;
  {$endif REPLDEFHISTMOD}

  PluginStatus: Boolean = False;
  StartExport: Boolean = False;
  StartUpdate: Boolean = False;
  DefaultINICopy: Boolean = False;

  HookModulesLoad,
  HookBuildMenu,
  HookContactMenu,
  HookSystemHistoryMenu,
  {$ifdef REPLDEFHISTMOD}
  HookShowMainHistory,
  {$endif REPLDEFHISTMOD}
  HookEventAdded,
  //HookTTBLoaded,
  HookShowHistoryAPI,
  HookShowContactHistoryAPI,
  HookShowVersionAPI: THandle;
  //hTTBButton: THandle = 0;
  DialogMainWindow: HWND = 0;

const
  hLangpack: THANDLE = 0;

function OnModulesLoad(awParam:WPARAM; alParam:LPARAM): Integer; cdecl; forward;
function OnBuildContactMenu(awParam: WPARAM; alParam: LPARAM): Integer; cdecl; forward;
function OnEventAdded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl; forward;
//function OnTTBLoaded(awParam: WPARAM; alParam: LPARAM): Integer; cdecl; forward;
function OpenHistoryWindow(wParam:WPARAM;lParam:LPARAM): Integer; cdecl; forward;

// tell Miranda about supported interfaces
function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  {$ifdef REPLDEFHISTMOD}
  PluginInterfaces[0]:=MIID_UIHISTORY;
  PluginInterfaces[1]:=MIID_LAST;
  {$else}
  PluginInterfaces[0]:=MIID_LAST;
  {$endif REPLDEFHISTMOD}
  Result := @PluginInterfaces;
end;

{ ���������� ������� �������� }
function OpenHistoryWindow(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  ContactProto, ContactID, ContactName: AnsiString;
  MyContactName, MyContactID: AnsiString;
  ProtoType: Integer;
  WinName: String;
begin
  Result := 0;
  ContactProto := GetContactProto(wParam);
  ContactID := GetContactID(wParam, ContactProto);
  ContactName := GetContactDisplayName(wParam, '', True);
  MyContactName := GetMyContactDisplayName(ContactProto);
  MyContactID := GetMyContactID(ContactProto);
  if ContactID = '' then
    ContactID := TranslateW('Unknown Contact');
  if ContactName = '' then
    ContactName := TranslateW('Unknown Contact');
  if MyContactID = '' then
    MyContactID := TranslateW('Unknown Contact');
  if MyContactName = '' then
    MyContactName := TranslateW('Unknown Contact');
  // ���. �������� ���������
  if ContactProto = MyAccount then
    ContactProto := 'ICQ';
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� PluginContactMenuCommand: ' + 'Contact ID: ' + ContactID + ' | Contact Name: ' + ContactName + ' | Proto: ' + ContactProto + ' | My Contact ID: ' + MyContactID + ' | My Contact Name: ' + MyContactName, 2);
  // ��� �������
  ProtoType := StrContactProtoToInt(ContactProto);
  // ���������� ��������� N ��������� ���������
  WinName := 'HistoryToDBViewer for ' + htdIMClientName + ' ('+MyAccount+')';
  if SearchMainWindow(pWideChar(WinName)) then
  begin
    // ������ �������:
    //   ��� ������� ��������:
    //     008|0|UserID|UserName|ProtocolType
    //   ��� ������� ����:
    //     008|2|ChatName
    OnSendMessageToOneComponent(WinName, '008|0|'+ContactID+'|'+ContactName+'|'+IntToStr(ProtoType));
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� PluginContactMenuCommand: ���������� ������ - 008|0|'+ContactID+'|'+ContactName+'|'+IntToStr(ProtoType), 2);
  end
  else
  begin
    if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
    begin
      if MatchStrings(LowerCase(ContactProto), 'skype*') then // Skype
      begin
        // ������ ������� ���� ������� (������� ���-���������)
        Glogal_History_Type := 2;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� PluginContactMenuCommand: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+MyContactID+'" "'+MyContactName+'" "'+ContactName+'"', 2);
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+MyContactID+'" "'+MyContactName+'" "'+ContactName+'"'), nil, SW_SHOWNORMAL);
      end
      else
      begin
        // ������ ������� ���� ������� (������� IM-���������)
        Glogal_History_Type := 0;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� PluginContactMenuCommand: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+MyContactID+'" "'+MyContactName+'" "'+ContactID+'" "'+ContactName+'" '+IntToStr(ProtoType), 2);
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+MyContactID+'" "'+MyContactName+'" "'+ContactID+'" "'+ContactName+'" '+IntToStr(ProtoType)), nil, SW_SHOWNORMAL);
      end;
    end
    else
      MsgInf(htdPluginShortName, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
  end;
end;

{ ���������� ���� �������� ������ ��� ������������ ���������� }
function OnBuildContactMenu(awParam: WPARAM; alParam: LPARAM): Integer; cdecl;
var
  MenuItem: TCLISTMENUITEM;
  ContactProto, ContactID, ContactName: AnsiString;
begin
  Result := 0;
  ContactProto := GetContactProto(awParam);
  // ����
  ZeroMemory(@MenuItem, SizeOf(MenuItem));
  MenuItem.cbSize := SizeOf(MenuItem);
  MenuItem.flags := CMIM_FLAGS;
  if (ContactProto = MyAccount) or
    MatchStrings(LowerCase(ContactProto), 'icq*') or
    MatchStrings(LowerCase(ContactProto), 'jabber*') or
    MatchStrings(LowerCase(ContactProto), 'aim*') or
    MatchStrings(LowerCase(ContactProto), 'irc*') or
    MatchStrings(LowerCase(ContactProto), 'msn*') or
    MatchStrings(LowerCase(ContactProto), 'yahoo*') or
    MatchStrings(LowerCase(ContactProto), 'gadu*') or
    MatchStrings(LowerCase(ContactProto), 'skype*') or
    MatchStrings(LowerCase(ContactProto), 'vkonta*') then
  begin // ���������� ���� � ���� ��������
    ContactID := GetContactID(awParam, ContactProto);
    ContactName := GetContactDisplayName(awParam, '', True);
    if ContactName = '' then
      ContactName := TranslateW('Unknown Contact');
    if ContactID = '' then
      ContactID := TranslateW('Unknown Contact');
    // ���. �������� ���������
    if ContactProto = MyAccount then
      ContactProto := 'ICQ';
    MenuItem.flags := MenuItem.flags or CMIM_NAME;
    MenuItem.szName.a := pAnsiChar(AnsiString(Format(WideStringToString(GetLangStr('ShowContactHistory'), CP_ACP), [ContactName, ContactID])));
    CallService(MS_CLIST_MODIFYMENUITEM, HookContactMenu, lParam(@MenuItem));
    if EnableDebug then // ���� �������
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnBuildContactMenu: ' + 'Contact ID: ' + ContactID + ' | Contact Name: ' + ContactName + ' | Proto: ' + ContactProto, 2);
  end
  else // ��� ��������
  begin
    MenuItem.flags := MenuItem.flags or CMIF_HIDDEN;
    CallService(MS_CLIST_MODIFYMENUITEM, HookContactMenu, lParam(@MenuItem));
    if EnableDebug then // ���� �������
    begin
      ContactID := GetContactID(awParam, ContactProto);
      ContactName := GetContactDisplayName(awParam, '', True);
      if ContactName = '' then
        ContactName := TranslateW('Unknown Contact');
      if ContactID = '' then
        ContactID := TranslateW('Unknown Contact');
      // ���. �������� ���������
      if ContactProto = MyAccount then
        ContactProto := 'ICQ';
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnBuildContactMenu: ' + 'Contact ID: ' + ContactID + ' | Contact Name: ' + ContactName + ' | Proto: ' + ContactProto, 2);
    end;
  end;
end;

{ �������� ������� � ���� ������� }
function OnEventAdded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
var
  ContactProto, ContactID, ContactName: AnsiString;
  MyContactName, MyContactID: AnsiString;
  BlobSize, ProtoType: Integer;
  DBEventInfo: TDBEventInfo;
  msgA: PAnsiChar;
  msgW: PChar;
  msgLen, LenW: Cardinal;
  I: Integer;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_SenderNick, Msg_SenderAcc, Msg_Text, MD5String: WideString;
  Date_Str, MsgStatus: String;
  InsertSQLData, EncInsertSQLData, WinName: String;
  ASize: Integer;
  hContact: THandle;
begin
  Result := 0;
  ZeroMemory(@DBEventInfo, SizeOf(DBEventInfo));
  DBEventInfo.cbSize := SizeOf(DBEventInfo);
  DBEventInfo.pBlob := nil;
  BlobSize := CallService(MS_DB_EVENT_GETBLOBSIZE, lParam, 0);
  GetMem(DBEventInfo.pBlob, BlobSize);
  DBEventInfo.cbBlob := BlobSize;
  if (CallService(MS_DB_EVENT_GET, lParam, Integer(@DBEventInfo)) = 0) and (DBEventInfo.eventType = EVENTTYPE_MESSAGE and EVENTTYPE_URL) then
  begin
    // �������� ����� ���������
    msgA := PAnsiChar(DBEventInfo.pBlob);
    msgW := nil;
    msgLen := lstrlenA(PAnsiChar(DBEventInfo.pBlob)) + 1;
    if msgLen > DBEventInfo.cbBlob then
      msgLen := DBEventInfo.cbBlob;
    if Boolean(DBEventInfo.flags and DBEF_UTF) then
    begin
      SetLength(Msg_Text, msgLen);
      LenW := Utf8ToWideChar(PChar(Msg_Text), msgLen, msgA, msgLen - 1, CP_ACP);
      if Integer(LenW) > 0 then
        SetLength(Msg_Text, LenW - 1)
      else
        Msg_Text := AnsiToWideString(msgA, CP_ACP, msgLen - 1);
    end
    else
    begin
      LenW := 0;
      if DBEventInfo.cbBlob >= msgLen * SizeOf(Char) then
      begin
        msgW := PChar(msgA + msgLen);
        for i := 0 to ((DBEventInfo.cbBlob - msgLen) div SizeOf(Char)) - 1 do
          if msgW[i] = #0 then
          begin
            LenW := i;
            Break;
          end;
      end;
      if (LenW > 0) and (LenW < msgLen) then
        SetString(Msg_Text, msgW, LenW)
      else
        Msg_Text := AnsiToWideString(msgA, CP_ACP, msgLen - 1);
    end;
    // ��� �������
    hContact := wParam;
    ContactProto := GetContactProto(hContact);
    ProtoType := StrContactProtoToInt(ContactProto);
    // ���� ��������� �� ������������, �� �� ����� ��� � ��
    // �.�. ��� ������������ ���� � �� ����� ������ ��������
    if ProtoType = 15 then
      Exit;
    // ������ �����������
    ContactID := GetContactID(hContact, ContactProto);
    ContactName := GetContactDisplayName(hContact, '', True);
    // ��� ������
    MyContactName := GetMyContactDisplayName(ContactProto);
    MyContactID := GetMyContactID(ContactProto);
    // ���. �������� ���������
    if ContactProto = MyAccount then
      ContactProto := 'ICQ';
    ProtoType := StrContactProtoToInt(ContactProto);
    // End
    if ContactID = '' then
      ContactID := TranslateW('Unknown Contact');
    if ContactName = '' then
      ContactName := TranslateW('Unknown Contact');
    if MyContactID = '' then
      MyContactID := TranslateW('Unknown Contact');
    if MyContactName = '' then
      MyContactName := TranslateW('Unknown Contact');
    // ������������ MyContactID � ContactName ���� �������� �
    // ������������ ��������� ��� ������������
    {if (ProtoType = 15) and (MyContactID = TranslateW('Unknown Contact')) and (MyContactName <> TranslateW('Unknown Contact')) then
      MyContactID := MyContactName;
    if (ProtoType = 15) and (ContactName = TranslateW('Unknown Contact')) and (ContactID <> TranslateW('Unknown Contact')) then
      ContactName := ContactID;}
    // �������������, ��������������� � �.�.
    Msg_SenderNick := PrepareString(pWideChar(AnsiToWideString(MyContactName, CP_ACP)));
    Msg_SenderAcc := PrepareString(pWideChar(AnsiToWideString(MyContactID, CP_ACP)));
    Msg_SenderNick := WideStringToUTF8(Msg_SenderNick);
    Msg_SenderAcc := WideStringToUTF8(Msg_SenderAcc);
    Msg_RcvrNick := PrepareString(pWideChar(AnsiToWideString(ContactName, CP_ACP)));
    Msg_RcvrAcc := PrepareString(pWideChar(AnsiToWideString(ContactID, CP_ACP)));
    Msg_RcvrNick := WideStringToUTF8(Msg_RcvrNick);
    Msg_RcvrAcc := WideStringToUTF8(Msg_RcvrAcc);
    Msg_Text := WideStringToUTF8(PrepareString(pWideChar(Msg_Text)));
    MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToLocalTime(DBEventInfo.timestamp)) + Msg_Text;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToLocalTime(DBEventInfo.timestamp))
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToLocalTime(DBEventInfo.timestamp));
    if MatchStrings(LowerCase(ContactProto), 'skype*') then
    begin
      // ���������� ����������� �������� (�� ��������� ��� ��� ��������)
      if (DBEventInfo.flags and DBEF_SENT) = 0 then
        MsgStatus := '0'  // ��������
      else
        MsgStatus := '1'; // ���������
      // ��� �������
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnEventAdded: ' + 'Contact ID: ' + ContactID + ' | Contact Name: ' + ContactName + ' | Proto: ' + ContactProto + ' | My Contact ID: ' + MyContactID + ' | My Contact Name: ' + MyContactName + ' | Contact Proto = ' + ContactProto + ' | MsgStatus = ' + MsgStatus + ' | DateTime = ' + FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToLocalTime(DBEventInfo.timestamp)) + ' | Message = ' + Msg_Text, 2);
      if (MatchStrings(DBType, 'oracle*')) then // ���� Oracle, �� ����� SQL-��� � ������� CHAT_MSG_LOG_ORACLE
        InsertSQLData := Format(CHAT_MSG_LOG_ORACLE, [DBUserName, MsgStatus, 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_RcvrNick, 'Skype', Msg_RcvrNick+' ('+Msg_RcvrAcc+')', BoolToIntStr(True), BoolToIntStr(False), BoolToIntStr(False), Msg_Text, EncryptMD5(MD5String)])
      else
        InsertSQLData := Format(CHAT_MSG_LOG, [DBUserName, MsgStatus, Date_Str, Msg_RcvrNick, 'Skype', Msg_RcvrNick+' ('+Msg_RcvrAcc+')', BoolToIntStr(True), BoolToIntStr(False), BoolToIntStr(False), Msg_Text, EncryptMD5(MD5String)]);
    end
    else
    begin
      // ���������� ����������� �������� (�� ��������� ��� ��� ��������)
      if (DBEventInfo.flags and DBEF_SENT) = 0 then
        MsgStatus := '1'  // ��������
      else
        MsgStatus := '0'; // ���������
      // ��� �������
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnEventAdded: ' + 'Contact ID: ' + ContactID + ' | Contact Name: ' + ContactName + ' | Proto: ' + ContactProto + ' | My Contact ID: ' + MyContactID + ' | My Contact Name: ' + MyContactName + ' | Contact Proto = ' + ContactProto + ' | MsgStatus = ' + MsgStatus + ' | DateTime = ' + FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToLocalTime(DBEventInfo.timestamp)) + ' | Message = ' + Msg_Text, 2);
      if (MatchStrings(DBType, 'oracle*')) then // ���� Oracle, �� ����� SQL-��� � ������� MSG_LOG_ORACLE
        InsertSQLData := Format(MSG_LOG_ORACLE, [DBUserName, IntToStr(ProtoType), Msg_SenderNick, Msg_SenderAcc, Msg_RcvrNick, Msg_RcvrAcc, MsgStatus, 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)])
      else
        InsertSQLData := Format(MSG_LOG, [DBUserName, IntToStr(ProtoType), Msg_SenderNick, Msg_SenderAcc, Msg_RcvrNick, Msg_RcvrAcc, MsgStatus, Date_Str, Msg_Text, EncryptMD5(MD5String)]);
    end;
    // �������� ��������� ����� MMF ��� ��������������� ������ �������������
    if SyncMethod = 0 then
    begin
      WinName := 'HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')';
      if SearchMainWindow(pWideChar(WinName)) then
      begin
        EncInsertSQLData := EncryptStr(InsertSQLData);
        ASize := 2*Length(EncInsertSQLData);
        with FMap do
        begin
          Clear;
          WriteBuffer(@ASize,Sizeof(Integer));
          WriteBuffer(PChar(EncInsertSQLData),ASize);
        end;
        // ���������� ������, ��� ��������� � ������
        OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '010');
      end
      else
        WriteInLog(ProfilePath, InsertSQLData, 0);
    end
    else // ��� ������ ������������� �� ���������� � ������� ����� ��������� � SQL-����
      WriteInLog(ProfilePath, InsertSQLData, 0);
    // ���� ����� �� ����������
    if SyncMethod = 2 then
    begin
      if (SyncInterval > 4) and (SyncInterval < 8) then
      begin
        Inc(MessageCount);
        if (SyncInterval = 5) and (MessageCount = 10) then
        begin
          OnSendMessageToAllComponent('002');
          MessageCount := 0;
        end;
        if (SyncInterval = 6) and (MessageCount = 20) then
        begin
          OnSendMessageToAllComponent('002');
          MessageCount := 0;
        end;
        if (SyncInterval = 7) and (MessageCount = 30) then
        begin
          OnSendMessageToAllComponent('002');
          MessageCount := 0;
        end;
      end;
      if SyncInterval = 9 then
      begin
        Inc(MessageCount);
        if MessageCount = SyncMessageCount then
        begin
          OnSendMessageToAllComponent('002');
          MessageCount := 0;
        end;
      end;
    end;
  end;
end;

{function OnTTBLoaded(awParam: WPARAM; alParam: LPARAM): Integer; cdecl;
var
  TTB: TTBButtonV2;
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnTTBLoaded', 2);
  if hTTBButton <> 0 then
  begin
    if ServiceExists(MS_TTB_REMOVEBUTTON)>0 then
    begin
      CallService(MS_TTB_REMOVEBUTTON, WPARAM(hTTBButton),0);
      hTTBButton := 0;
    end;
  end;
  if ShowPluginButton then
  begin
    if ServiceExists(MS_TTB_ADDBUTTON) > 0 then
    begin
      ZeroMemory(@TTB, SizeOf(TTB));
      TTB.cbSize        := SizeOf(TTB);
      TTB.pszServiceUp  := MHTD_SHOWSERVICE;
      TTB.pszServiceDown:= MHTD_SHOWSERVICE;
      TTB.hIconUp       := LoadImage(hInstance, 'ICON_0', IMAGE_ICON, 16, 16, 0);
      TTB.hIconDn       := ttb.hIconUp;
      TTB.dwFlags       := TTBBF_VISIBLE;
      TTB.name          := htdDBName;
      hTTBButton := CallService(MS_TTB_ADDBUTTON, WPARAM(@TTB), 0);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� OnTTBLoaded: ������ ���������.', 2);
    end;
  end;
  Result := 0;
end;}

{ C����� MS_MHTD_SHOWHISTORY
  ������ ������ � m_historytodb.inc }
function HTDBShowHistory(wParam { 0 } : WPARAM; lParam { 0 } : LPARAM): int_ptr; cdecl;
var
  WinName: String;
begin
  Result := 0;
  // ���� ���� HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBViewer �� ������, �� ���� ������ ����
  begin
    WinName := 'HistoryToDBViewer for ' + htdIMClientName + ' ('+MyAccount+')';
    if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBViewer �� �������, �� ���������
    begin
      if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
      begin
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
      end
      else
        MsgInf(htdPluginShortName, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else // ����� �������� ������ �� ����� ����
      OnSendMessageToOneComponent(WinName, '0040');
  end
  else // ����� �������� ������ �� ����� ����
    OnSendMessageToOneComponent(WinName, '0040');
end;

{ C����� MS_MHTD_SHOWCONTACTHISTORY
  ������ ������ � m_historytodb.inc }
function HTDBShowContactHistory(wParam { hContact } : WPARAM; lParam { 0 } : LPARAM): int_ptr; cdecl;
begin
  Result := OpenHistoryWindow(wParam, 0);
end;

{ C����� MS_MHTD_GETVERSION
  ������ ������ � m_historytodb.inc }
function HTDBGetVersion(wParam { 0 } : WPARAM; lParam { 0 } : LPARAM): int_ptr; cdecl;
begin
  Result := htdVersion;
end;

function OnModulesLoad(awParam{0}:WPARAM; alParam{0}:LPARAM):integer; cdecl;
var
  Mi: TCListMenuItem;
  //{$ifdef REPLDEFHISTMOD}
  Si: TCListMenuItem;
  //{$endif REPLDEFHISTMOD}
  AutoCoreLang, UpdTmpPath, WinName: String;
  I: Byte;
  MenuMainService: PAnsiChar;
  //IMUPD: TUpdate;
begin
  // ���-����� �������
  MsgLogOpened := False;
  ErrLogOpened := False;
  DebugLogOpened := False;
  ContactListLogOpened := False;
  ProtoListLogOpened := False;
  ImportLogOpened := False;
  // ������������� ����������
  EncryptInit;
  // ���������� �����������
  if FileExists(ExtractFilePath(ParamStr(0))+'Langpack_russian.txt') then
    AutoCoreLang := 'Russian'
  else
    AutoCoreLang := 'English';
  // ������ �� �������� ���� ����������� ������� ���� ��� ���� ��������
  OnSendMessageToAllComponent('003');
  // �������� ��������� ���� ������������ ����� � �������
  if FileExists(PluginPath + DefININame) then
  begin
    if FileExists(ProfilePath + ININame) then
      RenameFile(ProfilePath + ININame, ProfilePath + ININame + '.' + FormatDateTime('ddmmyyhhmmss', Now));
    if CopyFileEx(PChar(PluginPath + DefININame), PChar(ProfilePath + ININame), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
    begin
      DefaultINICopy := True;
      if FileExists(ProfilePath + ININame) then
        DeleteFile(PluginPath + DefININame);
    end;
  end;
  // ������ ������� ��� ������ �������
  if (GetDBInt(htdDBName, 'FirstRun.FirstActivate', 0) = 0) or (DefaultINICopy) then
  begin
    if AutoCoreLang = 'Russian' then
    begin
      case MessageBox(DialogMainWindow, PWideChar('�� ������� ������������ ������ ' + htdPluginShortName + '.' + #13 +
        '��� ���������� ������ ������� ��������� ��������� ���������� � ����� ������.' + #13 +
        '�� ������ ������ ������� �������?'), PWideChar(htdPluginShortName),36) of
        6: StartExport := True; // ��
        7: StartExport := False; // ���
      end;
    end
    else
    begin
      case MessageBox(DialogMainWindow, PWideChar('The first time you activate the plugin ' + htdPluginShortName + '.' + #13 +
        'To work correctly, check your plug-in connection to the database.' + #13 +
        'Do you want to start exporting the history?'), PWideChar(htdPluginShortName),36) of
        6: StartExport := True; // ��
        7: StartExport := False; // ���
      end;
    end;
  end;
  // ��������� �������� ����� ����������
  if GetDBInt(htdDBName, 'FirstRun.RunUpdateDoneV'+IntToStr(htdVersion), 0) = 0 then
  begin
    if AutoCoreLang = 'Russian' then
    begin
      //MsgInf(htdPluginShortName, '�� ������� ������������ ������ ' + htdPluginShortName + '.' + #13 + '��� ���������� ������ ������� ��������� ��������� ���������� � ����� ������.' + #13 + '������� �� ������������� ������� ' + htdPluginShortName + '.')
      case MessageBox(DialogMainWindow, PWideChar('�� ������� ������������ ������ ' + htdPluginShortName + '.' + #13 +
        '��� ���������� ������ ������� ���������� ��������� ������� ���������� ������� ����� ��������.' + #13 +
        '�� ������ ������ ������� ����������?'), PWideChar(htdPluginShortName),36) of
        6: StartUpdate := True; // ��
        7: StartUpdate := False; // ���
      end;
    end
    else
    begin
      //MsgInf(htdPluginShortName, 'The first time you activate the plugin ' + htdPluginShortName + '.' + #13 + 'To work correctly, check your plug-in connection to the database.' + #13 + 'Thank you for using the plugin ' + htdPluginShortName + '.');
      case MessageBox(DialogMainWindow, PWideChar('The first time you activate the plugin ' + htdPluginShortName + '.' + #13 +
        'To work correctly, the plugin must run the update plugin via the Internet.' + #13 +
        'Do you want to start the update process?'), PWideChar(htdPluginShortName),36) of
        6: StartUpdate := True; // ��
        7: StartUpdate := False; // ���
      end;
    end;
  end;
  // ����� ����� �� ���������
  if AutoCoreLang <> DefaultLanguage then
  begin
    CoreLanguage := AutoCoreLang;
    WriteCustomINI(ProfilePath, 'DefaultLanguage', CoreLanguage);
  end
  else
    CoreLanguage := DefaultLanguage;
  // ��������� ��������� �����������
  LangDoc := NewXMLDocument();
  CoreLanguageChanged;
  // ���������� ���� IM �������
  WriteCustomINI(ProfilePath, 'IMClientType', htdIMClientName);
  WriteCustomINI(ProfilePath, 'IMClientPlatformType', htdPlatform);
  // ���������� ���������� ������� �� ������ ��������
  WriteCustomINI(ProfilePath, 'SettingsFormRequestSend', '0');
  // ������� ���� About � Export
  if not Assigned(AboutForm) then
    AboutForm := TAboutForm.Create(nil);
  ExportFormDestroy := True;
  // API - �������� ���� �������
  HookShowHistoryAPI := CreateServiceFunction(MS_MHTD_SHOWHISTORY, @HTDBShowHistory);
  // API - �������� ���� ������� ���������� ��������
  HookShowContactHistoryAPI := CreateServiceFunction(MS_MHTD_SHOWCONTACTHISTORY, @HTDBShowContactHistory);
  // API - ������ �������
  HookShowVersionAPI := CreateServiceFunction(MS_MHTD_GETVERSION, @HTDBGetVersion);
  // ������������� ��������� ����
  MenuMainItemsInit;
  // ������� �������� ����
  FillChar(Mi, SizeOf(Mi), 0);
  Mi.cbSize := SizeOf(Mi);
  Mi.szPopupName.a := '&' + htdPluginShortName;
  Mi.popupPosition := 500000;
  Mi.hIcon := LoadImage(hInstance,'ICON_0',IMAGE_ICON,16,16,0);
  Mi.flags := 0;
  for I := Low(MainMenuItems) to High(MainMenuItems) do
  begin
    if MainMenuItems[I].Icon = '' then
      Mi.hIcon := 0
    else
      Mi.hIcon := LoadImage(hInstance, pChar(MainMenuItems[I].Icon), IMAGE_ICON, 16, 16, 0);
    Mi.szName.a := pAnsiChar(AnsiString(MainMenuItems[I].Name));
    MenuMainService := pAnsiChar(AnsiString(Format('%s/MainMenuCommand%d', [htdPluginShortName, I])));
    //if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� Load: ' + 'MenuMainName = ' + MenuMainItems[I].Name + ' | MenuMainService = ' + MenuMainService, 2);
    MainMenuHandle[I] := CreateServiceFunctionParam(MenuMainService, @MainMenuItems[I].Proc, I);
    Mi.pszService := MenuMainService;
    Mi.Position := MainMenuItems[I].Position;
    MenuHandle[I] := CallService(MS_CLIST_ADDMAINMENUITEM, 0, Windows.LPARAM(@Mi));
  end;
  // ������� ���� ����� � �������� ���� ��� ��������� �������
  //{$ifdef REPLDEFHISTMOD}
  FillChar(Si, SizeOf(Si), 0);
  Si.cbSize := SizeOf(Si);
  Si.Position := 500060000;
  Si.szName.a := pAnsiChar(AnsiString(Format(WideStringToString(GetLangStr('IMButtonCaption'), CP_ACP), [htdPluginShortName])));
  Si.pszService := MS_MHTD_SHOWHISTORY;//MS_HISTORY_SHOWCONTACTHISTORY;
  Si.hIcon := LoadImage(hInstance,'ICON_0',IMAGE_ICON,16,16,0);;
  HookSystemHistoryMenu := CallService(MS_CLIST_ADDMAINMENUITEM,0,LPARAM(@Si));
  //{$endif REPLDEFHISTMOD}
  // ������� ���� ����� � ���� ��������
  CreateServiceFunction(htdPluginShortName+'/ContactMenuCommand', @OpenHistoryWindow);
  Mi.pszContactOwner := nil; // ��� ��������
  Mi.cbSize := SizeOf(Mi);
  Mi.position := 1000090000;
  Mi.flags := 0;
  Mi.hIcon := LoadImage(hInstance,'ICON_0',IMAGE_ICON,16,16,0);
  Mi.szName.a := pAnsiChar(WideStringToString(GetLangStr('ShowOneContactHistory'), CP_ACP));
  Mi.pszService := htdPluginShortName+'/ContactMenuCommand';
  HookContactMenu := CallService(MS_CLIST_ADDCONTACTMENUITEM, 0, LPARAM(@Mi));
  // ��� �� �������� ���� ��������
  HookBuildMenu := HookEvent(ME_CLIST_PREBUILDCONTACTMENU, OnBuildContactMenu);
  // ��� �� ���������� ������ � ��������� �� �������
  HookEventAdded := HookEvent(ME_DB_EVENT_ADDED, OnEventAdded);
  // �������� ���� �������
 {$ifdef REPLDEFHISTMOD}
    HookShowMainHistory := CreateServiceFunction(MS_HISTORY_SHOWCONTACTHISTORY, @OpenHistoryWindow);
 {$endif REPLDEFHISTMOD}
  // ��������� TopToolBar
  //HookTTBLoaded := HookEvent(ME_TTB_MODULELOADED, OnTTBLoaded);
  // Register in updater
  {if Boolean(ServiceExists(MS_UPDATE_REGISTER)) then
  begin
    ZeroMemory(@IMUPD,SizeOf(IMUPD));
    IMUPD.cbSize := SizeOf(IMUPD);
    IMUPD.szComponentName := htdPluginShortName;
    IMUPD.pbVersion := @hppVersionStr[1];
    IMUPD.cpbVersion := Length(hppVersionStr);
    // File listing section
    //IMUPD.szUpdateURL = UPDATER_AUTOREGISTER;
    IMUPD.szUpdateURL := htdFLUpdateURL;
    IMUPD.szVersionURL := htdFLVersionURL;
    IMUPD.pbVersionPrefix := htdFLVersionPrefix;
    IMUPD.cpbVersionPrefix := Length(htdFLVersionPrefix);
    // Alpha-beta section
    IMUPD.szBetaUpdateURL := htdUpdateURL;
    IMUPD.szBetaVersionURL := htdVersionURL;
    IMUPD.pbBetaVersionPrefix := htdVersionPrefix;
    IMUPD.cpbBetaVersionPrefix := Length(htdVersionPrefix);
    IMUPD.szBetaChangelogURL := htdChangelogURL;
    CallService(MS_UPDATE_REGISTER, 0, LPARAM(@IMUPD));
  end;}
  // �������������� � dbeditor
  CallService(MS_DBEDIT_REGISTERSINGLEMODULE, WPARAM(PAnsiChar(htdDBName)), 0);
  { ��������� �������� ����� ������������
  FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;//��������� ����� �����
  FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;//��������� ����� �����
  FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;//��������� ��������� �����
  FILE_NOTIFY_CHANGE_SIZE             = $00000008;//��������� ������� �����
  FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;//��������� ������� ��������� ������
  FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;//��������� ������� ���������� �������
  FILE_NOTIFY_CHANGE_CREATION         = $00000040;//��������� ������� ��������
  FILE_NOTIFY_CHANGE_SECURITY         = $00000100;//��������� ���� �������
  }
  StartWatch(ProfilePath, FILE_NOTIFY_CHANGE_LAST_WRITE, False, @ProfileDirChangeCallBack);
  // MMF
  if SyncMethod = 0 then
    FMap := TMapStream.CreateEx('HistoryToDB for ' + htdIMClientName + ' ('+MyAccount+')',MAXDWORD,2000);
  // ������ ��������
  PluginStatus := True;
  // ���. ���������
  MessageCount := 0;
  // ����� ������ � ������ ������� � ����
  WriteDBInt(htdDBName, 'FirstRun.FirstActivate', 1);
  // ���������� ������� HistoryToDBUpdater.exe �� ��������� �����
  UpdTmpPath := GetUserTempPath + 'IMHistory\';
  if FileExists(UpdTmpPath + 'HistoryToDBUpdater.exe') then
  begin
    // ���� ���� HistoryToDBUpdater
    WinName := 'HistoryToDBUpdater';
    if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
    begin
      WinName := 'HistoryToDBUpdater for ' + htdIMClientName + ' ('+MyAccount+')';
      if SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �������, �� ��������� ���
        OnSendMessageToOneComponent(WinName, '009');
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '009');
    Sleep(800);
    // ������� ������ �������
    if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
    begin
      if CopyFileEx(PChar(UpdTmpPath + 'HistoryToDBUpdater.exe'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
      begin
        DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
        if CoreLanguage = 'Russian' then
          MsgInf(htdPluginShortName, Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']))
        else
          MsgInf(htdPluginShortName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
      end;
    end
    else
    begin
      DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
      if CoreLanguage = 'Russian' then
        MsgDie(htdPluginShortName, Format('������ ���������� ������� %s �� ��������� �����.', [PluginPath + 'HistoryToDBUpdater.exe']))
      else
        MsgDie(htdPluginShortName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
    end;
  end;
  // ���������� ������� HistoryToDBUpdater.exe �� ����� �������
  if FileExists(PluginPath + 'HistoryToDBUpdater.upd') then
  begin
    // ���� ���� HistoryToDBUpdater
    WinName := 'HistoryToDBUpdater';
    if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
    begin
      WinName := 'HistoryToDBUpdater for ' + htdIMClientName + ' ('+MyAccount+')';
      if SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �������, �� ��������� ���
        OnSendMessageToOneComponent(WinName, '009');
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '009');
    Sleep(800);
    // ������� ������ �������
    if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
    begin
      if CopyFileEx(PChar(PluginPath + 'HistoryToDBUpdater.upd'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
      begin
        DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
        if CoreLanguage = 'Russian' then
          MsgInf(htdPluginShortName, Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']))
        else
          MsgInf(htdPluginShortName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
      end;
    end
    else
    begin
      DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
      if CoreLanguage = 'Russian' then
        MsgDie(htdPluginShortName, Format('������ ���������� ������� %s �� ����� ��������.', [PluginPath + 'HistoryToDBUpdater.exe']))
      else
        MsgDie(htdPluginShortName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
    end;
  end;
  // ������ ����������
  if StartUpdate then
  begin
    if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
    begin
      // ����� ������ � ����
      WriteDBInt(htdDBName, 'FirstRun.RunUpdateDoneV'+IntToStr(htdVersion), 1);
      // ��������� ������
      ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
    end
    else
      MsgInf(htdPluginShortName, Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']));
  end
  else
  begin
    // ��������� �������� ����� ����������
    if GetDBInt(htdDBName, 'FirstRun.RunUpdateDoneV'+IntToStr(htdVersion), 0) = 0 then
      WriteDBInt(htdDBName, 'FirstRun.RunUpdateDoneV'+IntToStr(htdVersion), 1); // ����� ������ � ����
  end;
  // �������� ���� ��������
  if StartExport then
  begin
    if ExportFormDestroy then
      ChildExport := TExportForm.Create(nil);
    if Assigned(ChildExport) then
    begin
      if not ChildExport.Showing then
        ChildExport.Show
      else
        ChildExport.BringFormToFront(ChildExport);
    end;
  end;
  // ���� �� ��������� ����������, �� ��������� ��������� ������������� HistoryToDBSync
  if not StartUpdate then
  begin
    if FileExists(PluginPath + 'HistoryToDBSync.exe') then
    begin
      WinName := 'HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')';
      if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBSync for QIP �� �������, �� ���������
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBSync.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL)
    end
    else
    begin
      if CoreLanguage = 'Russian' then
        MsgInf(htdPluginShortName, Format('��������� ������������� ������� %s �� �������.' + #13 + '��������� ������� ���������� �������.', [PluginPath + 'HistoryToDBSync.exe']))
      else
        MsgInf(htdPluginShortName, Format('The history synchronization program %s not found.' + #13 + 'Begin the process of updating the plugin.', [PluginPath + 'HistoryToDBSync.exe']));
    end;
  end;
  Result := 0;
end;

function Load():Integer; cdecl;
var
  ProfileName, TmpProfilePath: String;
  Str: PAnsiChar;
begin
  CallService(MS_LANGPACK_REGISTER,WPARAM(@hLangpack),LPARAM(@PluginInfo));
  // ������� ��������
  hppCodepage := CallService(MS_LANGPACK_GETCODEPAGE, 0, 0);
  if (hppCodepage = CALLSERVICE_NOTFOUND) or (hppCodepage = CP_ACP) then
    hppCodepage := GetACP();
  // �������� �� ��������� ����-���������
  MetaContactsEnabled := Boolean(ServiceExists(MS_MC_GETMOSTONLINECONTACT));
  if MetaContactsEnabled then
  begin
    Str := pAnsiChar(CallService(MS_MC_GETPROTOCOLNAME, 0, 0));
    if Assigned(Str) then
      MetaContactsProto := AnsiString(Str)
    else
      MetaContactsEnabled := False;
  end;
  // ���� �� ��������
  SetLength(DllPath, MAX_PATH);
  SetLength(DllPath, GetModuleFileNameW(hInstance, @DllPath[1], MAX_PATH));
  PluginPath := ExtractFilePath(DllPath);
  // ���� �� ���������� ������� (USERNAME\USERNAME.dat)
  SetLength(TmpProfilePath, MAX_PATH);
  CallService(MS_DB_GETPROFILEPATH, MAX_PATH, lParam(@TmpProfilePath[1]));
  SetLength(TmpProfilePath, StrLen(pAnsiChar(@TmpProfilePath[1])));
  TmpProfilePath := pAnsiChar(TmpProfilePath) + PathDelim;
  // ��� ����� �������
  SetLength(ProfileName, MAX_PATH);
  CallService(MS_DB_GETPROFILENAME, MAX_PATH, lParam(@ProfileName[1]));
  SetLength(ProfileName, StrLen(pAnsiChar(@ProfileName[1])));
  // ���� �� ������� USERNAME.dat
  TmpProfilePath := TmpProfilePath + ExtractFileNameEx(TmpProfilePath+pAnsiChar(ProfileName), False) + PathDelim;
  if DirectoryExists(TmpProfilePath) then
    ProfilePath := TmpProfilePath
  else
    ProfilePath := ExtractFilePath(DllPath);
  // ��������� ���������
  LoadINI(ProfilePath);
  // ���������� ��� �������, ����� ��� ������������ ��� ��������� ��������
  MyAccount := ExtractFileNameEx(pAnsiChar(ProfileName), False);
  WriteCustomINI(ProfilePath, 'MyAccount', MyAccount);
  // ������������� �������� �������
  HookModulesLoad := HookEvent(ME_SYSTEM_MODULESLOADED, OnModulesLoad);
  Result := 0;
end;

function Unload: int; cdecl;
var
  I: Byte;
begin
  Result := 0;
  if PluginStatus then
  begin
    // ������������� �������� ����� ������������
    StopWatch;
    if Assigned(AboutForm) then FreeAndNil(AboutForm);
    if Assigned(ExportForm) then FreeAndNil(ExportForm);
    // ������� ����
    for I := Low(MainMenuHandle) to High(MainMenuHandle) do
    begin
      DestroyServiceFunction(MainMenuHandle[I]);
      DestroyServiceFunction(MenuHandle[I]);
    end;
    {$ifdef REPLDEFHISTMOD}
    DestroyServiceFunction(HookShowMainHistory);
    {$endif REPLDEFHISTMOD}
    DestroyServiceFunction(HookShowHistoryAPI);
    DestroyServiceFunction(HookShowContactHistoryAPI);
    DestroyServiceFunction(HookShowVersionAPI);
    //{$ifdef REPLDEFHISTMOD}
    UnhookEvent(HookSystemHistoryMenu);
    //{$endif REPLDEFHISTMOD}
    UnhookEvent(HookContactMenu);
    //UnhookEvent(HookTTBLoaded);
    UnhookEvent(HookEventAdded);
    UnhookEvent(HookBuildMenu);
    UnhookEvent(HookModulesLoad);
    // ������ �� �������� ���� ����������� �������
    OnSendMessageToAllComponent('003');
    // ��������� ���-�����
    if MsgLogOpened then
      CloseLogFile(0);
    if ErrLogOpened then
      CloseLogFile(1);
    if DebugLogOpened then
      CloseLogFile(2);
    if ContactListLogOpened then
      CloseLogFile(3);
    if ProtoListLogOpened then
      CloseLogFile(4);
    // ������� ������ ����������
    EncryptFree;
    // MMF
    if Assigned(FMap) then
      FMap.Free;
    // ����. �������� ���������
    LangDoc.Active := False;
  end;
end;

exports
  MirandaPluginInfoEx,
  MirandaPluginInterfaces,
  Load,
  Unload;

begin
end.

