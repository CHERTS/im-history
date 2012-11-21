{ ############################################################################ }
{ #                                                                          # }
{ #  RnQ HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

library RnQHistoryToDB;

{$I jedi.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

uses
  Classes,
  Windows,
  Messages,
  SysUtils,
  WideStrUtils,
  JclStringConversions,
  XMLIntf,
  XMLDoc,
  ShellApi,
  Types,
  Global in 'Global.pas',
  CallExec in 'CallExec.pas',
  About in 'About.pas' {AboutForm},
  FSMonitor in 'FSMonitor.pas',
  plugin,
  pluginutil,
  MapStream in 'MapStream.pas';

var
  userPath, andrqPath: AnsiString;
  vApiVersion, CurrentUIN: Integer;
  MessageCount: Integer;
  CoreLanguage: WideString;
  Button_Handle: Integer;
  PluginStatus: Boolean = False;
  // ���������� ��� ���� ������ ���� ����
  MenuWnd    : HWND;
  PopupMenu  : HMENU;
  ActiveMenu : HMENU;

// ���������� ������� ������ ������� � ���� ���� ����� �������� ����
procedure OnPluginLeftButtonClick(Handle: Integer);
var
  WinName: String;
begin
  Global_AccountUIN := RQ_GetChatUIN();
  Global_AccountName := RQ_GetDisplayedName(Global_AccountUIN);
  WinName := 'HistoryToDBViewer for RnQ ('+MyAccount+')';
  if SearchMainWindow(pWideChar(WinName)) then
  begin
    // ������ �������:
    //   ��� ������� ��������:
    //     008|0|UserID|UserName|ProtocolType
    //   ��� ������� ����:
    //     008|2|ChatName
    OnSendMessageToOneComponent(WinName, '008|0|'+IntToStr(Global_AccountUIN)+'|'+Global_AccountName+'|0');
  end
  else
  begin
    if FileExists(PluginPath + '\HistoryToDBViewer.exe') then
      ShellExecute(0, 'open', PWideChar(PluginPath + '\HistoryToDBViewer.exe'), PWideChar('"'+PluginPath+'\" "'+ProfilePath+'" 0 "'+IntToStr(Global_CurrentAccountUIN)+'" "'+Global_CurrentAccountName+'" "'+IntToStr(Global_AccountUIN)+'" "'+Global_AccountName+'" 0'), nil, SW_SHOWNORMAL)
    else
      MsgInf(GetLangStr('InfoCaption'), Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + '\HistoryToDBViewer.exe']));
  end;
end;

{ ���������� ���� �������� ������� }
procedure OnClickSettings;
var
  WinName: String;
begin
  // ���� ���� HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBViewer �� ������, �� ���� ������ ����
  begin
    WinName := 'HistoryToDBViewer for RnQ ('+MyAccount+')';
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
        MsgInf(PluginName, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '005');
  end
  else // ����� �������� ������ �� ����� ��������
    OnSendMessageToOneComponent(WinName, '005');
end;


// ���������� ������� ������ ������� � ���� ���� ������ �������� ����
procedure OnPluginRightButtonClick(Handle: Integer; X,Y: Integer);
begin
  TrackPopupMenu(PopupMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON, X,Y,0, MenuWnd, nil);
end;

// ���������� ������� ������ ������� � ���� ����
procedure OnPluginButtonClick(AButton: Integer);
var
  curPos: TPoint;
begin
  GetCursorPos(curPos);
  case AButton of
    0: OnPluginLeftButtonClick(AButton);
    1: OnPluginRightButtonClick(AButton, curPos.X, curPos.Y);
    else OnPluginLeftButtonClick(AButton);
  end;
end;

// ���������� ������� ����
procedure OnMenuItemClick(ItemID: Integer);
var
  List: TIntegerDynArray;
  I: Integer;
  WinName: String;
begin
  case ItemID of
    1: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
    3:
    begin
      // ��������� �����
      if ContactListLogOpened then
        CloseLogFile(3);
      if ProtoListLogOpened then
        CloseLogFile(4);
      // ������� �����
      if FileExists(ProfilePath+ProtoListName) then
        DeleteFile(ProfilePath+ProtoListName);
      WriteInLog(ProfilePath, WideFormat('%s;%s;%d', ['ICQ', IntToStr(Global_CurrentAccountUIN), 0]), 4);
      if FileExists(ProfilePath+ContactListName) then
        DeleteFile(ProfilePath+ContactListName);
      // ����������� ������ ���������
      List := RQ_GetList(PL_ROASTER);
      for I:=0 to HIGH(List) do
      begin
        WriteInLog(ProfilePath, WideFormat('%s;%s;%s;%d', [IntToStr(List[I]), RQ_GetDisplayedName(List[I]), 'Default', 0]), 3);
      end;
      // ��������� �����
      if ContactListLogOpened then
        CloseLogFile(3);
      if ProtoListLogOpened then
        CloseLogFile(4);
    end;
    4: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '0050');
    5: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '0051');
    6: if FileExists(ProfilePath+ContactListName) then OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '007');
    7:
    begin
      // ���� ���� HistoryToDBUpdater
      WinName := 'HistoryToDBUpdater';
      if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
      begin
        WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
        if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� �������, �� ���������
        begin
          if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
          begin
            // ��������� ������
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
          end
          else
            MsgInf(PluginName, Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']));
        end
        else // ����� �������� ������
          OnSendMessageToOneComponent(WinName, '0040');
      end
      else // ����� �������� ������
        OnSendMessageToOneComponent(WinName, '0040');
    end;
    9: OnClickSettings;
    11: AboutForm.Show;
  end;
end;

// ������� ��������� ����
function WndProc(wnd: hWnd; msg, wParam, lParam: longint): longint; stdcall;
begin
  case msg of
    WM_COMMAND:
      begin
        if ActiveMenu = PopupMenu then
         OnMenuItemClick(Lo(wParam));
        Result := 0;
      end;
    WM_INITMENUPOPUP:
        ActiveMenu := wParam
    else
      Result := DefWindowProc(wnd, msg, WParam, LParam);
  end;
end;

// ������ ������ ��� ����
procedure CreateWindow(var Wnd: HWND);
var
  wc: WndClass;
begin
  wc.style := 0;
  wc.lpfnWndProc := @WndProc;
  wc.cbClsExtra := 0;
  wc.cbWndExtra := 0;
  wc.hInstance := hInstance;
  wc.hIcon := 0;
  wc.hCursor := 0;
  wc.hbrBackground := 0;
  wc.lpszMenuName := nil;
  wc.lpszClassName := 'TRQPlugWnd02340';
  Windows.RegisterClass(wc);
  Wnd := CreateWindowEx(WS_EX_APPWINDOW, 'TRQPlugWnd02340',
    '', WS_POPUP, 0, 0, 0, 0, 0, 0, hInstance, nil);
end;

// ���������� ������ ��� ����
procedure DestroyWindow(var Wnd: HWND);
begin
  Windows.DestroyWindow(Wnd);
  Wnd := 0;
end;

procedure AddMsgToLog(Data: Pointer; Status: Integer);
var
  Msg_RcvrAcc, Msg_Flags: Integer;
  Current_UIN_Name, Msg_RcvrNick, Msg_Text, MD5String: AnsiString;
  Msg_DateTime: TDateTime;
  Date_Str: String;
  InsertSQLData, EncInsertSQLData, WinName: String;
  ASize: {$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF};
begin
  if Status = 0 then
  begin
    RQ__ParseMsgSentString(Data, Msg_RcvrAcc, Msg_Flags, Msg_Text);
    // �������� �����������
    Msg_Text := StringReplace(Msg_Text,#34,'\'+#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#92,'\'+#92,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#96,'\'+#96,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#39,#39#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#09,'\t',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#10,'\n',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#13,'\r',[RFReplaceall]);
    if not IsUTF8String(Msg_Text) then
      Msg_Text :=  WideStringToUTF8(Msg_Text);
    // �������� � UTF8
    if not IsUTF8String(Global_CurrentAccountName) then
      Current_UIN_Name :=  WideStringToUTF8(Global_CurrentAccountName)
    else
      Current_UIN_Name :=  Global_CurrentAccountName;
    if not IsUTF8String(RQ_GetDisplayedName(Msg_RcvrAcc)) then
      Msg_RcvrNick := WideStringToUTF8(RQ_GetDisplayedName(Msg_RcvrAcc))
    else
      Msg_RcvrNick := RQ_GetDisplayedName(Msg_RcvrAcc);
    Msg_DateTime := RQ_GetTime();
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', Msg_DateTime)
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime);
    MD5String := IntToStr(Msg_RcvrAcc) + FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime) + Msg_Text;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      InsertSQLData := Format(MSG_LOG_ORACLE, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '0', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)])
    else
      InsertSQLData := Format(MSG_LOG, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '0', Date_Str, Msg_Text, EncryptMD5(MD5String)]);
  end
  else
  begin
    RQ__ParseMsgGotString(Data, Msg_RcvrAcc, Msg_Flags, Msg_DateTime, Msg_Text);
    // �������� �����������
    Msg_Text := StringReplace(Msg_Text,#34,'\'+#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#92,'\'+#92,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#96,'\'+#96,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#39,#39#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#09,'\t',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#10,'\n',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#13,'\r',[RFReplaceall]);
    if not IsUTF8String(Msg_Text) then
      Msg_Text :=  WideStringToUTF8(Msg_Text);
    if not IsUTF8String(Current_UIN_Name) then
      Current_UIN_Name :=  WideStringToUTF8(Global_CurrentAccountName)
    else
      Current_UIN_Name :=  Global_CurrentAccountName;
    if not IsUTF8String(RQ_GetDisplayedName(Msg_RcvrAcc)) then
      Msg_RcvrNick := WideStringToUTF8(RQ_GetDisplayedName(Msg_RcvrAcc))
    else
      Msg_RcvrNick := RQ_GetDisplayedName(Msg_RcvrAcc);
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', Msg_DateTime)
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime);
    MD5String := IntToStr(Msg_RcvrAcc) + FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime) + Msg_Text;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      InsertSQLData := Format(MSG_LOG_ORACLE, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '1', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)])
    else
      InsertSQLData := Format(MSG_LOG, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '1', Date_Str, Msg_Text, EncryptMD5(MD5String)]);
  end;
  // �������� ��������� ����� MMF ��� ��������������� ������ �������������
  if SyncMethod = 0 then
  begin
    WinName := 'HistoryToDBSync for RnQ ('+MyAccount+')';
    if SearchMainWindow(pWideChar(WinName)) then
    begin
      EncInsertSQLData := EncryptStr(InsertSQLData);
      ASize := Length(EncInsertSQLData) * SizeOf(Char);
      with FMap do
      begin
        Clear;
        WriteBuffer(@ASize,Sizeof({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}));
        WriteBuffer(PChar(EncInsertSQLData),ASize);
      end;
      // ���������� ������, ��� ��������� � ������
      OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '010');
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
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
      if (SyncInterval = 6) and (MessageCount = 20) then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
      if (SyncInterval = 7) and (MessageCount = 30) then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
    end;
    if SyncInterval = 9 then
    begin
      Inc(MessageCount);
      if MessageCount = SyncMessageCount then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
    end;
  end;
end;

// ������� ��� �������������� ���������
procedure CoreLanguageChanged;
var
  LangFile: String;
begin
  if CoreLanguage = '' then
    Exit;
  try
    LangFile := PluginPath + dirLangs + CoreLanguage + '.xml';
    if FileExists(LangFile) then
      LangDoc.LoadFromFile(LangFile)
    else
    begin
      if FileExists(PluginPath + dirLangs + defaultLangFile) then
        LangDoc.LoadFromFile(PluginPath + dirLangs + defaultLangFile)
      else
      begin
        MsgDie(PluginName, 'Not found any language file!');
        Exit;
      end;
    end;
    Global.CoreLanguage := CoreLanguage;
    SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(PluginName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

function pluginFun(Data: Pointer): Pointer; stdcall;
var
  UpdTmpPath, WinName: String;
begin
  Result := nil;
  if (Data=nil) or (_int_at(Data)=0) then exit;
  case _byte_at(Data,4) of
    PM_EVENT:
      case _byte_at(Data,5) of
        PE_INITIALIZE:
        begin
          RQ__ParseInitString(Data, callback, vapiVersion, andrqPath, userPath, CurrentUIN);
          // ���������� ����
          ProfilePath := RQ_GetUserPath();
          PluginPath := RQ_GetAndrqPath + 'plugins\';
          MyAccount := IntToStr(RQ_GetCurrentUser());
          // ���-����� �������
          MsgLogOpened := False;
          ErrLogOpened := False;
          DebugLogOpened := False;
          ContactListLogOpened := False;
          ProtoListLogOpened := False;
          // �������� ��������� ���� ������������ ����� � �������
          if FileExists(PluginPath + DefININame) then
          begin
            if FileExists(ProfilePath + ININame) then
              RenameFile(ProfilePath + ININame, ProfilePath + ININame + '.' + FormatDateTime('ddmmyyhhmmss', Now));
            CopyFileEx(PChar(PluginPath + DefININame), PChar(ProfilePath + ININame), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS);
            if FileExists(ProfilePath + ININame) then
              DeleteFile(PluginPath + DefININame);
          end;
          // ��������� ��������� �������
          LoadINI(ProfilePath, true);
          if RQ_GetRnQVersion < 1106 then
          begin
            if DefaultLanguage = 'Russian' then
              MessageBox(0, PChar('��������, �� ������ RnQHistoryToDB �� ����� �������� � ������ ������� RnQ.' + #13 + '����������, �������� RnQ �� ������ 1106 � ����.' + #13 + '���������� ����� ������� �� ����������� ����� http://www.rnq.ru'), PChar(PluginName), MB_ICONHAND)
            else
              MessageBox(0, PChar('Sorry, but the plugin RnQ HistoryToDB can not work with this version RnQ.'+ #13 + 'Please upgrade RnQ to version 1106 and above.' + #13 + 'The update can be downloaded from the official site http://www.rnq.ru'), PChar(PluginName), MB_ICONHAND);
            Exit;
          end;
          try
            PluginStatus := True;
            MessageCount := 0;
            if not Assigned(AboutForm) then
              AboutForm := TAboutForm.create(nil);
            // ������������� ����������
            EncryptInit;
            // ���������� ���� ���, ����� ��� ������������ ��� ��������� ��������
            WriteCustomINI(ProfilePath, 'MyAccount', MyAccount);
            // ������ �� �������� ���� ����������� ������� ���� ��� ���� �������
            OnSendMessageToAllComponent('003');
            // ��������� ��������� �����������
            LangDoc := NewXMLDocument();
            CoreLanguage := DefaultLanguage;
            CoreLanguageChanged;
            // ���������� ���� IM �������
            WriteCustomINI(ProfilePath, 'IMClientType', 'RnQ');
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
              FMap := TMapStream.CreateEx('HistoryToDB for RnQ ('+MyAccount+')',MAXDWORD,2000);
            // ��������� ��������� ������������� HistoryToDBSync
            if FileExists(PluginPath + '\HistoryToDBSync.exe') then
              ShellExecute(0, 'open', PWideChar(PluginPath + '\HistoryToDBSync.exe'), PWideChar('"'+PluginPath+'\" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL)
            else
              MsgInf(GetLangStr('InfoCaption'), Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + '\HistoryToDBSync.exe']));
            Global_CurrentAccountUIN := RQ_GetCurrentUser();
            Global_CurrentAccountName := RQ_GetDisplayedName(Global_CurrentAccountUIN);
            if ShowPluginButton then
            begin
              Button_Handle := RQ_CreateChatButton(@OnPluginButtonClick, AboutForm.Icon.Handle, Format(GetLangStr('IMButtonCaption'), [PluginName]));
              // ������� ����
              CreateWindow(MenuWnd);
              PopupMenu := CreatePopupMenu;
              AppendMenu(PopupMenu, MF_STRING, 1, PWideChar(GetLangStr('SyncButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 2, '-');
              AppendMenu(PopupMenu, MF_STRING, 3, PWideChar(GetLangStr('GetContactListButton')));
              AppendMenu(PopupMenu, MF_STRING, 4, PWideChar(GetLangStr('CheckMD5Hash')));
              AppendMenu(PopupMenu, MF_STRING, 5, PWideChar(GetLangStr('CheckAndDeleteMD5Hash')));
              AppendMenu(PopupMenu, MF_STRING, 6, PWideChar(GetLangStr('UpdateContactListButton')));
              AppendMenu(PopupMenu, MF_STRING, 7, PWideChar(GetLangStr('CheckUpdateButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 8, '-');
              AppendMenu(PopupMenu, MF_STRING, 9, PWideChar(GetLangStr('SettingsButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 10, '-');
              AppendMenu(PopupMenu, MF_STRING, 11, PWideChar(GetLangStr('AboutButton')));
            end;
            // ���������� ������� HistoryToDBUpdater.exe �� ��������� �����
            UpdTmpPath := GetUserTempPath + 'IMHistory\';
            if FileExists(UpdTmpPath + 'HistoryToDBUpdater.exe') then
            begin
              // ���� ���� HistoryToDBUpdater
              WinName := 'HistoryToDBUpdater';
              if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
              begin
                WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
                if SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �������, �� ��������� ���
                  OnSendMessageToOneComponent(WinName, '009');
              end
              else // ����� �������� ������
                OnSendMessageToOneComponent(WinName, '009');
              // ������� ������ �������
              if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
              begin
                if CopyFileEx(PChar(UpdTmpPath + 'HistoryToDBUpdater.exe'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
                begin
                  DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
                  if CoreLanguage = 'Russian' then
                    MsgInf(PluginName, Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']))
                  else
                    MsgInf(PluginName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
                end;
              end
              else
              begin
                DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
                if CoreLanguage = 'Russian' then
                  MsgDie(PluginName, Format('������ ���������� ������� %s', [PluginPath + 'HistoryToDBUpdater.exe']))
                else
                  MsgDie(PluginName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
              end;
            end;
            // ���������� ������� HistoryToDBUpdater.exe �� ����� �������
            if FileExists(PluginPath + 'HistoryToDBUpdater.upd') then
            begin
              // ���� ���� HistoryToDBUpdater
              WinName := 'HistoryToDBUpdater';
              if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
              begin
                WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
                if SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �������, �� ��������� ���
                  OnSendMessageToOneComponent(WinName, '009');
              end
              else // ����� �������� ������
                OnSendMessageToOneComponent(WinName, '009');
              // ������� ������ �������
              if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
              begin
                if CopyFileEx(PChar(PluginPath + 'HistoryToDBUpdater.upd'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
                begin
                  DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
                  if CoreLanguage = 'Russian' then
                    MsgInf(PluginName, Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']))
                  else
                    MsgInf(PluginName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
                end;
              end
              else
              begin
                DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
                if CoreLanguage = 'Russian' then
                  MsgDie(PluginName, Format('������ ���������� ������� %s', [PluginPath + 'HistoryToDBUpdater.exe']))
                else
                  MsgDie(PluginName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
              end;
            end;
            Result := str2comm(ansichar(PM_DATA)+_istring(PluginName)+_int(APIversion));
          except
            on E: Exception do
              MsgDie(PluginName, 'Error on PE_INITIALIZE: ' + E.Message);
          end;
        end;

        PE_PREFERENCES:
        begin
          OnClickSettings;
        end;

        PE_FINALIZE:
        begin
          try
            if PluginStatus then
            begin
              // ������������� �������� ����� ������������
              StopWatch;
              // ������� ����
              DestroyMenu(PopupMenu);
              DestroyWindow(MenuWnd);
              // ������� ������ � ����
              if Button_Handle <> 0 then RQ_DeleteChatButton(Button_Handle);
              if Assigned(AboutForm) then FreeAndNil(AboutForm);
              // ������ �� �������� ���� ����������� �������
              OnSendMessageToAllComponent('003');
              // ��������� ���-�����
              if MsgLogOpened then
                CloseLogFile(0);
              if ErrLogOpened then
                CloseLogFile(1);
              if DebugLogOpened then
                CloseLogFile(2);
              // ������� ������ ����������
              EncryptFree;
              // MMF
              if Assigned(FMap) then
                FMap.Free;
              // ����. �������� ���������
              LangDoc.Active := False;
            end;
          except
            on E: Exception do
              MsgDie(PluginName, 'Error on PE_FINALIZE: ' + E.Message);
          end;
        end;

        PE_MSG_SENT:
        begin
          AddMsgToLog(Data, 0);
        end;

        PE_MSG_GOT:
        begin
          AddMsgToLog(Data, 1);
        end;
      end; //case
  end; //case
end; //pluginFun

exports
  pluginFun;

end.

