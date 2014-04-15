{ ################################################################################ }
{ #                                                                              # }
{ #  MirandaNG HistoryToDB Plugin v2.6                                           # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

unit Menu;

{$I jedi.inc}

interface

uses
  Windows, Classes, SysUtils, ShellApi, MsgExport, m_api, Database, Global;

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
{$ifdef DELPHIXE_UP}
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl; forward;
{$ELSE}
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl; forward;
{$endif DELPHIXE_UP}

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
    Mi.szName.a := pAnsiChar(AnsiString(MainMenuItems[I].Name));
    CallService(MS_CLIST_MODIFYMENUITEM, MenuHandle[I], Windows.LPARAM(@Mi));
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� RebuildMainMenu: ' + 'MainMenuName = ' + MainMenuItems[I].Name, 2);
  end;
end;

{ ���������������� ������� }
{$ifdef DELPHIXE_UP}
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuSync(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '002');
end;

{ ������� ������� }
{$ifdef DELPHIXE_UP}
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuExportAllHistory(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
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
{$ifdef DELPHIXE_UP}
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuGetContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
var
  hContact: THandle;
  ContactProto, ContactID, ContactName, GroupName: AnsiString;
  AccountCount: Integer;
  AccountName: ^PPROTOACCOUNT;
  ICQAccount: TArrayOfString;
  ICQAccountCount: Integer;
begin
  AccountCount := 0;
  // ��������� ������ ���������� � ���� ProtoList.csv
  if (CallService(MS_PROTO_ENUMACCOUNTS, Integer(@AccountCount), Integer(@AccountName)) = 0) and (AccountCount <> 0) then
  begin
    SetLength(ICQAccount, 0);
    while AccountCount > 0 do
    begin
      // ��������� ������ � ��������� ICQ
      // ������ ��� ����� ������, ��� ����� � ����� while ����� GetContactProto(hContact)
      // ��� �������� � ���������� ICQ ������ �� ��������, � AccountName^.szModuleName
      if MatchStrings(LowerCase(AccountName^.szProtoName), 'icq*') then
      begin
        SetLength(ICQAccount, Length(ICQAccount)+1);
        ICQAccount[Length(ICQAccount)-1] := AccountName^.szModuleName;
      end;
      if not((AccountName^.szModuleName = 'MetaContacts') or (MatchStrings(LowerCase(AccountName^.szModuleName), 'skype*'))) then
      //if not MatchStrings(LowerCase(AccountName^.szModuleName), 'skype*') then
        WriteInLog(ProfilePath, Format('%s;%s;%d;%s;%s;%s', [AccountName^.szModuleName, GetMyContactID(AccountName^.szModuleName), StrContactProtoToInt(AccountName^.szProtoName), GetMyContactDisplayName(AccountName^.szModuleName), '', '']), 4);
      Inc(AccountName);
      Dec(AccountCount);
    end;
  end;
  // �������� ������ ���������
  hContact := db_find_first();
  while hContact <> 0 do
  begin
    ContactProto := GetContactProto(hContact);
    ContactID := GetContactID(hContact, ContactProto);
    ContactName := GetContactDisplayName(hContact, '', True);
		GroupName := GetDBStr(hContact , 'CList' , 'Group' , GetLangStr('ContactNotInTheList'));
    if ContactName = '' then
      ContactName := TranslateW('Unknown Contact');
    if ContactID = '' then
      ContactID := TranslateW('Unknown Contact');
    // ��� � ������� ���������
    for ICQAccountCount := 0 to High(ICQAccount) do
    begin
      if ICQAccount[ICQAccountCount] = ContactProto then
        ContactProto := 'icq';
    end;
    // End
    if not ((MatchStrings(LowerCase(ContactProto), 'skype*')) or (ContactID = TranslateW('Unknown Contact')) or MatchStrings(LowerCase(ContactProto), 'metacontacts*')) then
      WriteInLog(ProfilePath, Format('%s;%s;%s;%d', [ContactID, ContactName, GroupName, StrContactProtoToInt(ContactProto)]), 3);
    hContact := db_find_next(hContact);
  end;
  // ��������� �����
  if DebugLogOpened then
    CloseLogFile(2);
  if ContactListLogOpened then
    CloseLogFile(3);
  if ProtoListLogOpened then
    CloseLogFile(4);
  Result := 0;
  if (FileExists(ProfilePath + ContactListName)) and (FileExists(ProfilePath + ProtoListName)) then
    MsgInf(htdPluginShortName, GetLangStr('SaveContactListCompleted'))
  else
    MsgInf(htdPluginShortName, GetLangStr('SaveContactListErr'));
end;

{ ��������� ���������� MD5-����� }
{$ifdef DELPHIXE_UP}
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuCheckMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '0050');
end;

{ ��������� ���������� MD5-����� � �������� ���������� }
{$ifdef DELPHIXE_UP}
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuCheckAndDeleteMD5Hash(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
begin
  Result := 0;
  OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '0051');
end;

{ ������ �� ���������� ������� ����� }
{$ifdef DELPHIXE_UP}
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuUpdateContactList(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
begin
  Result := 0;
  if FileExists(ProfilePath+ContactListName) then
    OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '007')
  else
    MsgInf(htdPluginShortName, Format(GetLangStr('SendUpdateContactListErr'), [ContactListName]));
end;

{ ��������� ���������� }
{$ifdef DELPHIXE_UP}
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuCheckUpdate(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
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
{$ifdef DELPHIXE_UP}
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuSettings(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
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
{$ifdef DELPHIXE_UP}
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: LPARAM): int_ptr; cdecl;
{$ELSE}
function MainMenuAbout(wParam: wParam; lParam: lParam; lParam1: integer): integer; cdecl;
{$endif DELPHIXE_UP}
begin
  Result := 0;
  AboutForm.Show;
end;

end.
