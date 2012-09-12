{ ################################################################################ }
{ #                                                                              # }
{ #  Miranda HistoryToDB Plugin v2.4                                             # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

unit Menu;

interface

uses
  Windows, Classes, SysUtils, ShellApi, MsgExport, m_globaldefs, m_api, Database, Global;

type
  TMenuItem = record
    Name:     String;
    Icon:     String;
    Position: Integer;
    Proc:     TMIRANDASERVICEPARAM;
    Flags:    DWord;
  end;

var
  MainMenuItems: Array [1..9] of TMenuItem;
  MainMenuHandle: Array [1..9] of THandle;
  MenuHandle: Array [1..9] of THandle;
  ChildExport: TExportForm;

procedure MenuMainItemsInit; cdecl; forward;
procedure RebuildMainMenu; cdecl; forward;
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;

implementation

uses Contacts, About, FSMonitor;

{ ���������� ���� }
procedure MenuMainItemsInit;
begin
  MainMenuItems[1].Name := WideStringToString(GetLangStr('SyncButton'), CP_ACP);
  MainMenuItems[1].Icon := 'ICON_0';
  MainMenuItems[1].Position := 000000;
  MainMenuItems[1].Proc := MainMenuSync;

  MainMenuItems[2].Name := WideStringToString(GetLangStr('ExportAllHistoryButton'), CP_ACP);
  MainMenuItems[2].Icon := '';
  MainMenuItems[2].Position := 100000;
  MainMenuItems[2].Proc := MainMenuExportAllHistory;

  MainMenuItems[3].Name := WideStringToString(GetLangStr('GetContactListButton'), CP_ACP);
  MainMenuItems[3].Icon := '';
  MainMenuItems[3].Position := 100001;
  MainMenuItems[3].Proc := MainMenuGetContactList;

  MainMenuItems[4].Name := WideStringToString(GetLangStr('CheckMD5Hash'), CP_ACP);
  MainMenuItems[4].Icon := '';
  MainMenuItems[4].Position := 100002;
  MainMenuItems[4].Proc := MainMenuCheckMD5Hash;

  MainMenuItems[5].Name := WideStringToString(GetLangStr('CheckAndDeleteMD5Hash'), CP_ACP);
  MainMenuItems[5].Icon := '';
  MainMenuItems[5].Position := 100003;
  MainMenuItems[5].Proc := MainMenuCheckAndDeleteMD5Hash;

  MainMenuItems[6].Name := WideStringToString(GetLangStr('UpdateContactListButton'), CP_ACP);
  MainMenuItems[6].Icon := '';
  MainMenuItems[6].Position := 100004;
  MainMenuItems[6].Proc := MainMenuUpdateContactList;

  MainMenuItems[7].Name := WideStringToString(GetLangStr('CheckUpdateButton'), CP_ACP);
  MainMenuItems[7].Icon := '';
  MainMenuItems[7].Position := 100004;
  MainMenuItems[7].Proc := MainMenuCheckUpdate;

  MainMenuItems[8].Name := WideStringToString(GetLangStr('SettingsButton'), CP_ACP);
  MainMenuItems[8].Icon := '';
  MainMenuItems[8].Position := 200000;
  MainMenuItems[8].Proc := MainMenuSettings;

  MainMenuItems[9].Name := WideStringToString(GetLangStr('AboutButton'), CP_ACP);
  MainMenuItems[9].Icon := '';
  MainMenuItems[9].Position := 300000;
  MainMenuItems[9].Proc := MainMenuAbout;
end;

{ ����������� ������� � �������� ���� }
procedure RebuildMainMenu;
var
  I: Integer;
  Mi: TCListMenuItem;
begin
  // ������������� ��������� ����
  MenuMainItemsInit;
  // ������������ ����
  for I := Low(MenuHandle) to High(MenuHandle) do
  begin
    ZeroMemory(@Mi, SizeOf(Mi));
    Mi.cbSize := SizeOf(Mi);
    Mi.flags := CMIM_FLAGS;
    Mi.flags := Mi.flags or CMIM_NAME;
    Mi.pszName := pAnsiChar(AnsiString(MainMenuItems[I].Name));
    PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM, MenuHandle[I], Windows.LPARAM(@Mi));
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� RebuildMainMenu: ' + 'MainMenuName = ' + MainMenuItems[I].Name, 2);
  end;
end;

{ ���������������� ������� }
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '002');
end;

{ ������� ������� }
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  if ExportFormDestroy then
    ChildExport := TExportForm.Create(nil);
  if not ChildExport.Showing then
    ChildExport.Show
  else
    ChildExport.BringFormToFront(ChildExport);
end;

{ ��������� ������ ���������� � ������� ���� }
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
var
  hContact: Cardinal;
  ContactProto, ContactID, ContactName, GroupName: AnsiString;
  ProtoCount, I: Integer;
  ProtoName: ^PPROTOCOLDESCRIPTOR;
begin
  // �������� ������ ���������
  hContact := PluginLink^.CallService(MS_DB_CONTACT_FINDFIRST, 0, 0);
  while hContact <> 0 do
  begin
    ContactProto := GetContactProto(hContact);
    ContactID := GetContactID(hContact, ContactProto);
    ContactName := GetContactDisplayName(hContact, '', True);
		GroupName := GetDBStr(hContact , 'CList' , 'Group' , GetLangStr('ContactNotInTheList'));
    if ContactName = '' then
      ContactName := 'NoContactName';
    if ContactID = '' then
      ContactID := 'NoContactID';
    //GetDBStr(hContact, 'Protocol', 'p', 'NoProto')
    if not MatchStrings(LowerCase(ContactProto), 'skype*') then
      //WriteInLog(ProfilePath, Format('%s;%s;%s;%d', [ContactID, ContactName, GetLangStr('ContactNotInTheList'), StrContactProtoToInt(GetDBStr(hContact, 'Protocol', 'p', 'NoProto'))]), 3);
      WriteInLog(ProfilePath, Format('%s;%s;%s;%d', [ContactID, ContactName, GroupName, StrContactProtoToInt(ContactProto)]), 3);
    hContact := PluginLink^.CallService(MS_DB_CONTACT_FINDNEXT, hContact, 0);
  end;
  if ContactListLogOpened then
    CloseLogFile(3);
  // �������� ������ ����������
  if (PluginLink^.CallService(MS_PROTO_ENUMPROTOCOLS, Integer(@ProtoCount), Integer(@ProtoName)) = 0) and (ProtoCount <> 0) then
  begin
    while ProtoCount > 0 do
    begin
      if ProtoName^.type_ = PROTOTYPE_PROTOCOL then
        WriteInLog(ProfilePath, Format('%s;%s;%d;%s;%s;%s', [ProtoName^.szName, GetMyContactID(ProtoName^.szName), StrContactProtoToInt(ProtoName^.szName), GetMyContactDisplayName(ProtoName^.szName), '', '']), 4);
      Inc(ProtoName);
      Dec(ProtoCount);
    end;
    if ProtoListLogOpened then
      CloseLogFile(4);
  end;
  Result := 0;
  MsgInf(htdPluginShortName, GetLangStr('SaveContactListCompleted'));
end;

{ ��������� ���������� MD5-����� }
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '0050');
end;

{ ��������� ���������� MD5-����� � �������� ���������� }
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '0051');
end;

{ ������ �� ���������� ������� ����� }
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  if FileExists(ProfilePath+ContactListName) then
    OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '007')
  else
    MsgInf(htdPluginShortName, Format(GetLangStr('SendUpdateContactListErr'), [ContactListName]));
end;

{ ��������� ���������� }
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
var
  WinName: String;
begin
  // ���� ���� HistoryToDBUpdater
  WinName := 'HistoryToDBUpdater';
  if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
  begin
    WinName := 'HistoryToDBUpdater for ' + htdIMClientName + ' ('+MyAccount+')';
    if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� �������, �� ���������
    begin
      if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
      begin
        // ��������� ������
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
      end
      else
        MsgInf(htdPluginShortName, Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']));
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '0040');
  end
  else // ����� �������� ������
    OnSendMessageToOneComponent(WinName, '0040');
end;

{ ���������� ���� �������� ������� }
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
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
        // ��������� ������ �� ����� ��������
        StopWatch;
        WriteCustomINI(ProfilePath, 'SettingsFormRequestSend', '1');
        StartWatch(ProfilePath, FILE_NOTIFY_CHANGE_LAST_WRITE, False, @ProfileDirChangeCallBack);
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" 4'), nil, SW_SHOWNORMAL);
      end
      else
        MsgInf(htdPluginShortName, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '005');
  end
  else // ����� �������� ������ �� ����� ��������
    OnSendMessageToOneComponent(WinName, '005');
end;

{ ���������� ���� � ������� }
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
begin
  Result := 0;
  AboutForm.Show;
end;

end.
