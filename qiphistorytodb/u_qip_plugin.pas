{ ############################################################################ }
{ #                                                                          # }
{ #  QIP HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit u_qip_plugin;

interface

uses Windows, SysUtils, StrUtils, ExtCtrls, Graphics, Menus,
    u_plugin_info, u_plugin_msg, u_common, JclStringConversions, WideStrUtils,
    XMLIntf, XMLDoc, ShellApi, Messages, Global, FSMonitor, About, MapStream;

var
  PluginStatus: Boolean = False;
  SpecContactAdding: Boolean = False;
  KeyID: Integer;

type
  TSpecContactHistoryToDB = record
    PicIcon         : TIcon;
    SpecContactName : WideString;
    UniqID          : Cardinal;
  end;
  pSpecContactHistoryToDB = ^TSpecContactHistoryToDB;

type
  TQipPlugin = class(TInterfacedObject, IQIPPlugin, ICLSnapshot)
  private
    FPluginSvc      : IQIPPluginService;
    FPluginInfo     : TPluginInfo;
    FDllPath        : WideString;
    FPopupMenu      : TPopupMenu;
    MPopupMenu      : TPopupMenu;
    metaPopupMenu   : TPopupMenu;
    FLanguage       : WideString;
    MessageCount    : Integer;
    FSnapshotIntf   : ICLSnapshot;
    AddProtoInFile  : Boolean;
    MenuItem:       Array[0..50] of TPluginMenuItem;
    procedure LoadSuccess;
    procedure CreateControls;
    procedure LoadPluginOptions;
    procedure FreeControls;
    procedure AddNeededBtns;
    procedure AddNeededChatBtns;
    procedure MsgBtnClicked(PlugMsg: TPluginMessage);
    procedure ChatMsgBtnClicked(PlugMsg: TPluginMessage);
    procedure AddMsgToLog(const PMSG: TPluginMessage; MsgStatus: Integer);
    procedure AddChatMsgToLog(const PMSG: TPluginMessage);
    procedure WantCLPopupMenu(var PlugMsg: TPluginMessage);
    procedure CLPopupMenuItemClick(var PlugMsg: TPluginMessage);
    procedure ShowFadeWindow(Msg: String; MsgIconType, MsgFadeType: Integer);
    procedure AddSpecContacts;
    procedure DelSpecContacts;
    procedure DrawSpecContact(PlugMsg: TPluginMessage);
    procedure SpecContactRightClick(PlugMsg: TPluginMessage);
    procedure SpecContactDblClick(PlugMsg: TPluginMessage);
    procedure OnClick_About(Sender: TObject);
    procedure OnClick_Settings(Sender: TObject);
    procedure OnClick_HistorySync(Sender: TObject);
    procedure OnClick_GetContactList(Sender: TObject);
    procedure OnClick_CheckMD5Hash(Sender: TObject);
    procedure OnClick_CheckAndDeleteMD5Hash(Sender: TObject);
    procedure OnClick_UpdateContactList(Sender: TObject);
    procedure OnClick_CheckUpdateButton(Sender: TObject);
    procedure OnClick_metaContact(Sender: TObject);
    procedure AntiBoss(HideAllForms: Boolean);
    procedure OnCurrentLang(var PlugMsg: TPluginMessage);
    procedure SetSnapshotIntf(const Value: ICLSnapshot);
    procedure ShowButtonPopupMenu;
    function GetPluginsDataDirectory: String;
    function GetNames: String;
    function VarSendPluginMessage(const AMsg: DWord; var AWParam, ALParam, ANParam): Integer;
    function SendPluginMessage(const AMsg: DWord; AWParam, ALParam, ANParam: Integer): Integer; overload;
    function SendPluginMessage(const AMsg: DWord; AWParam, ALParam, ANParam, AResult: Integer): Integer; overload;
    function PlugChecker(PlugMsg: TPluginMessage): Boolean;
  public
    constructor Create(const PluginService: IQIPPluginService);
    destructor Destroy; override;
    function GetPluginInfo: pPluginInfo; stdcall;
    { ���������� ���������� ICLSnapshot }
    function AddElement(const Contact: pSnapshotElement): HRESULT; stdcall;
    function AddProto(const Proto: pProtoSnapshotElement): HRESULT; stdcall;
    { End }
    procedure OnQipMessage(var PlugMsg: TPluginMessage); stdcall;
    procedure CoreLanguageChanged; stdcall;
    procedure GetPluginInformation(var VersionMajor: Word; var VersionMinor: Word; var PluginName: PWideChar; var Creator: PWideChar; var Description: PWideChar; var Hint: PWideChar); stdcall;
    property CoreLanguage: WideString read FLanguage;
    property SnapshotIntf: ICLSnapshot read FSnapshotIntf write SetSnapshotIntf;
  end;

var
  aSpecContactHistoryToDB  : pSpecContactHistoryToDB;

implementation

{ ������ ������ }
constructor TQipPlugin.Create(const PluginService: IQIPPluginService);
begin
  FPluginSvc := PluginService;
end;

{ ���������� ������ }
destructor TQipPlugin.Destroy;
begin
  FreeControls;
  inherited;
end;

{ ������� ���� � ����� }
function TQipPlugin.GetPluginInfo: pPluginInfo;
begin
  Result := @FPluginInfo;
end;

{ ��������� �� ����� ��������� }
procedure TQipPlugin.OnQipMessage(var PlugMsg: TPluginMessage);
begin
  case PlugMsg.Msg of
    PM_PLUGIN_LOAD_SUCCESS      : LoadSuccess;
    PM_PLUGIN_RUN               :
    begin
      LoadPluginOptions;
      CreateControls;
    end;
    PM_PLUGIN_QUIT              : FreeControls;
    PM_PLUGIN_DISABLE           : FreeControls;
    PM_PLUGIN_ENABLE            :
    begin
      LoadPluginOptions;
      CreateControls;
    end;
    PM_PLUGIN_OPTIONS           : OnClick_Settings(Self); // ������ ������ ���������
    PM_PLUGIN_WRONG_SDK_VER     :
    begin
      if CoreLanguage = 'Russian' then
        MsgInf('������ QIPHistoryToDB', '�������� ������ SDK. ��� ������ ��������� QIP 2012 ������ 6537 ��� ����.')
      else
        MsgInf('Plugin QIPHistoryToDB', 'Wrong SDK version. To work needed QIP 2012 build 6537 or higher.');
    end;
    PM_PLUGIN_ANTIBOSS          : AntiBoss(Boolean(PlugMsg.WParam));  // ��������� ��������� � ���������/���������� ������ "����-����"
    PM_PLUGIN_CAN_ADD_BTNS      : AddNeededBtns;                      // ��������� ������ � ���� ���������
    PM_PLUGIN_CHAT_CAN_BTNS     : AddNeededChatBtns;                  // ��������� ������ � ���� ���-���������
    PM_PLUGIN_MSG_BTN_CLICK     : MsgBtnClicked(PlugMsg);             // ������ ������ ������� �� ������ ���������
    PM_PLUGIN_CHAT_BTN_CLICK    : ChatMsgBtnClicked(PlugMsg);         // ������ ������ ������� �� ������ ���-���������
    PM_PLUGIN_SPEC_RIGHT_CLK    : SpecContactRightClick(PlugMsg);     // ��������� ���� ������ ������� �� ����. ��������
    PM_PLUGIN_SPEC_DBL_CLICK    : SpecContactDblClick(PlugMsg);       // ������� ���� ����� ������� �� ����. ��������
    PM_PLUGIN_SPEC_DRAW_CNT     : DrawSpecContact(PlugMsg);           // ��������� ����. ��������
    PM_PLUGIN_CURRENT_LANG      : OnCurrentLang(PlugMsg);             // ����� �����
    PM_PLUGIN_MSG_SEND          : AddMsgToLog(PlugMsg, 0);            // ���������� IM-���������
    PM_PLUGIN_MSG_RCVD          : AddMsgToLog(PlugMsg, 1);            // ������� IM-���������
    PM_PLUGIN_CHAT_MSG_RCVDNEW  : AddChatMsgToLog(PlugMsg);           // ���������� � ��������� ��������� (� �.�. ����������� ���������)
    PM_PLUGIN_MESSAGE           :                                     // ��������� QIP Manager
    begin
      if PlugChecker(PlugMsg) then
        Exit;
    end;
    PM_PLUGIN_ADD_CL_MENU_ITEMS  : WantCLPopupMenu(PlugMsg);
    PM_PLUGIN_CL_MENU_ITEM_CLICK : CLPopupMenuItemClick(PlugMsg);
  end;
end;

{ �������� �������� ������� }
procedure TQipPlugin.LoadSuccess;
var
  buf : array[0..MAX_PATH] of WideChar;
begin
  GetModuleFileNameW(FPluginInfo.DllHandle, buf, SizeOf(buf));
  FDllPath := buf;
  FPluginInfo.DllPath           := PWideChar(FDllPath);
  DllPath                       := WideCharToString(FPluginInfo.DllPath);
  FPluginInfo.QipSdkVerMajor    := QIP_SDK_VER_MAJOR;
  FPluginInfo.QipSdkVerMinor    := QIP_SDK_VER_MINOR;
  FPluginInfo.PlugVerMajor      := PLUGIN_VER_MAJOR;
  FPluginInfo.PlugVerMinor      := PLUGIN_VER_MINOR;
  FPluginInfo.PluginName        := PWideChar(PLUGIN_NAME);
  FPluginInfo.PluginAuthor      := PWideChar(PLUGIN_AUTHOR);
  FPluginInfo.PluginDescription := PWideChar(PLUGIN_DESCRUPTION);
  FPluginInfo.PluginIcon        := LoadImage(HInstance, 'ICON_4', IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);
end;

{ ������� ����� � ��������� ��������� }
procedure TQipPlugin.CreateControls;
var
  UpdTmpPath, WinName: String;
begin
  try
    // ���-����� �������
    MsgLogOpened := False;
    ErrLogOpened := False;
    DebugLogOpened := False;
    ContactListLogOpened := False;
    ProtoListLogOpened := False;
    GetContactList := False;
    // ������������� ����������
    EncryptInit;
    // ��� �������
    MyAccount := GetNames;
    // ������ �� �������� ���� ����������� ������� ���� ��� ���� ��������
    OnSendMessageToAllComponent('003');
    // ���� �� �������
    ProfilePath := GetPluginsDataDirectory + 'QIPHistoryToDB\';
    // ������� ���������� �������
    if not DirectoryExists(ProfilePath) then
      CreateDir(ProfilePath);
    // �������� ��������� ���� ������������ ����� � �������
    if FileExists(PluginPath + DefININame) then
    begin
      if FileExists(ProfilePath + ININame) then
        RenameFile(ProfilePath + ININame, ProfilePath + ININame + '.' + FormatDateTime('ddmmyyhhmmss', Now));
      CopyFileEx(PChar(PluginPath + DefININame), PChar(ProfilePath + ININame), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS);
      if FileExists(ProfilePath + ININame) then
      begin
        DeleteFile(PluginPath + DefININame);
        if MatchStrings(GetWindowsLanguage, '�������*') then
          MsgInf(PluginName, '�� ������� ������������ ������ ' + PluginName + '.' + #13 + '��� ���������� ������ ������� ��������� ��������� ���������� � ����� ������.' + #13 + '������� �� ������������� ������� ' + PluginName + '.')
        else
          MsgInf(PluginName, 'The first time you activate the plugin ' + PluginName + '.' + #13 + 'To work correctly, check your plug-in connection to the database.' + #13 + 'Thank you for using the plugin ' + PluginName + '.');
      end;
    end;
    // ��������� ���������
    LoadINI(ProfilePath);
    // ��������� ��������� �����������
    FLanguage := DefaultLanguage;
    LangDoc := NewXMLDocument();
    CoreLanguageChanged;
    // ���������� ���� IM �������
    WriteCustomINI(ProfilePath, 'IMClientType', 'QIP');
    // ���������� ���������� ������� �� ������ ��������
    WriteCustomINI(ProfilePath, 'SettingsFormRequestSend', '0');
    // ���������� ���� ���, ����� ��� ������������ ��� ��������� ��������
    WriteCustomINI(ProfilePath, 'MyAccount', MyAccount);
    // ������� ���� About
    if not Assigned(AboutForm) then
      AboutForm := TAboutForm.Create(nil);
    // ������� ����. �������.
    if AddSpecialContact then
      AddSpecContacts;
    // ��������� ��������� ������������� HistoryToDBSync
    if FileExists(PluginPath + 'HistoryToDBSync.exe') then
    begin
      WinName := 'HistoryToDBSync for QIP ('+MyAccount+')';
      if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBSync for QIP �� �������, �� ���������
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBSync.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
    end
    else
    begin
      if CoreLanguage = 'Russian' then
        ShowFadeWindow(Format('��������� ������������� ������� %s �� ������.', [PluginPath + 'HistoryToDBSync.exe']), 0, 2)
      else
        ShowFadeWindow(Format('The history synchronization program %s not found.', [PluginPath + 'HistoryToDBSync.exe']), 0, 2);
    end;
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
    // ���������� ���������� ICLSnapshot ��� ���������� �������-�����
    SnapshotIntf := Self;
    // ���������� ������� HistoryToDBUpdater.exe �� ��������� �����
    UpdTmpPath := GetUserTempPath + 'IMHistory\';
    if FileExists(UpdTmpPath + 'HistoryToDBUpdater.exe') then
    begin
      // ���� ���� HistoryToDBUpdater
      WinName := 'HistoryToDBUpdater';
      if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
      begin
        WinName := 'HistoryToDBUpdater for QIP ('+MyAccount+')';
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
            ShowFadeWindow(Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']), 0, 1)
          else
            ShowFadeWindow(Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']), 0, 1);
        end;
      end
      else
      begin
        DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
        if CoreLanguage = 'Russian' then
          ShowFadeWindow(Format('������ ���������� ������� %s', [PluginPath + 'HistoryToDBUpdater.exe']), 0, 2)
        else
          ShowFadeWindow(Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']), 0, 2);
      end;
    end;
    // ���������� ������� HistoryToDBUpdater.exe �� ����� �������
    if FileExists(PluginPath + 'HistoryToDBUpdater.upd') then
    begin
      // ���� ���� HistoryToDBUpdater
      WinName := 'HistoryToDBUpdater';
      if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
      begin
        WinName := 'HistoryToDBUpdater for QIP ('+MyAccount+')';
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
            ShowFadeWindow(Format('������� ���������� %s ������� ���������.', ['HistoryToDBUpdater.exe']), 0, 1)
          else
            ShowFadeWindow(Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']), 0, 1);
        end;
      end
      else
      begin
        DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
        if CoreLanguage = 'Russian' then
          ShowFadeWindow(Format('������ ���������� ������� %s', [PluginPath + 'HistoryToDBUpdater.exe']), 0, 2)
        else
          ShowFadeWindow(Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']), 0, 2);
      end;
    end;
    // MMF
    if SyncMethod = 0 then
      FMap := TMapStream.CreateEx('HistoryToDB for QIP ('+MyAccount+')',MAXDWORD,2000);
    // ������ ��������
    PluginStatus := True;
    // ���. ���������
    MessageCount := 0;
  except
    on E: Exception do
    begin
      PluginStatus := False;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CreateControls: ' + E.Message, 2);
      MsgDie(PLUGIN_NAME, 'Error on CreateControls: ' + E.Message);
    end;
  end;
end;

{ ���������� ����� }
procedure TQipPlugin.FreeControls;
begin
  if PluginStatus then
  begin
    try
      // ������������� �������� ����� ������������
      StopWatch;
      // ������� ����. �������
      if SpecContactAdding then
        DelSpecContacts;
      // ������� ������� � �����
      if Assigned(FPopupMenu) then FreeAndNil(FPopupMenu);
      if Assigned(MPopupMenu) then FreeAndNil(MPopupMenu);
      if Assigned(metaPopupMenu) then FreeAndNil(metaPopupMenu);
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
      //if SyncMethod = 0 then
      if Assigned(FMap) then
        FMap.Free;
      // ����. �������� ���������
      LangDoc.Active := False;
    except
      on E: Exception do
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� FreeControls: ' + E.Message, 2);
        MsgDie(PLUGIN_NAME, 'Error on FreeControls: ' + E.Message);
      end;
    end;
  end;
end;

procedure TQipPlugin.LoadPluginOptions;
begin
  try
    PluginPath := ExtractFilePath(WideCharToString(FPluginInfo.DllPath));
    if not DirectoryExists(PluginPath + dirLangs) then
      CreateDir(PluginPath + dirLangs);
  except
    on E: Exception do
      MsgDie(PLUGIN_NAME, 'Error on LoadPluginOptions: ' + E.Message);
  end;
end;

{ ���������� ������ ������� � ���� ��������� }
procedure TQipPlugin.AddNeededBtns;
var
  PlugMsg : TPluginMessage;
  BtnInfo : TAddBtnInfo;
  ICO     : TIcon;
begin
  if ShowPluginButton then
  begin
    // ������ ������� ������ �� ����� ��������
    ICO := TIcon.Create;
    try
      ICO.LoadFromResourceName(HInstance, 'ICON_4');
      BtnInfo.BtnIcon := ICO.Handle;
      BtnInfo.BtnPNG := 0;
      BtnInfo.BtnHint := Format(GetLangStr('IMButtonCaption'), [PluginName]);
      PlugMsg.Msg := PM_PLUGIN_ADD_BTN;
      PlugMsg.WParam := LongInt(@BtnInfo);
      PlugMsg.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsg);
    finally
      ICO.Free;
    end;
  end;
end;

{ ���������� ������ ������� � ���� ���� }
procedure TQipPlugin.AddNeededChatBtns;
var
  PlugMsg : TPluginMessage;
  BtnInfo : TAddBtnInfo;
  ICO     : TIcon;
begin
  if ShowPluginButton then
  begin
    // ������ ������� ������ �� ����� ��������
    ICO := TIcon.Create;
    try
      ICO.LoadFromResourceName(HInstance, 'ICON_1');
      BtnInfo.BtnIcon := ICO.Handle;
      BtnInfo.BtnPNG := 0;
      BtnInfo.BtnHint := Format(GetLangStr('CHATButtonCaption'), [PluginName]);
      PlugMsg.Msg := PM_PLUGIN_CHAT_ADD_BTN;
      PlugMsg.WParam := LongInt(@BtnInfo);
      PlugMsg.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsg);
    finally
      ICO.Free;
    end;
  end;
end;

{ ���������� ����������� ���� � ����������
  MsgFadeType - ����� ������������ ����: 0 - ����� ���������, 1 - ����������, 2 - ������ }
procedure TQipPlugin.ShowFadeWindow;
var
  PlugMsg   : TPluginMessage;
  FadeInfo  : TFadeWndInfo;
  ICO       : TIcon;
begin
  ICO := TIcon.Create;
  if MsgIconType = 0 then
    ICO.LoadFromResourceName(HInstance, 'ICON_4') // �����
  else if MsgIconType = 1 then
    ICO.LoadFromResourceName(HInstance, 'ICON_1') // �������
  else if MsgIconType = 2 then
    ICO.LoadFromResourceName(HInstance, 'ICON_2')
  else
    ICO.LoadFromResourceName(HInstance, 'ICON_3');
  FadeInfo.FadeType := MsgFadeType;
  FadeInfo.FadeIcon := ICO.Handle;
  FadeInfo.TextCentered := False;
  FadeInfo.FadeTitle := PLUGIN_NAME;
  FadeInfo.FadeText := Msg;
  FadeInfo.NoAutoClose := False;
  PlugMsg.Msg := PM_PLUGIN_FADE_MSG;
  PlugMsg.WParam := LongInt(@FadeInfo);
  PlugMsg.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg);
  ICO.Free;
end;

{ ��������� ����. �������. }
procedure TQipPlugin.AddSpecContacts;
var
  PlugMsg : TPluginMessage;
begin
  New(aSpecContactHistoryToDB);
  aSpecContactHistoryToDB^.PicIcon := TIcon.Create;
  aSpecContactHistoryToDB^.SpecContactName := PluginSpecContactName;
  aSpecContactHistoryToDB^.UniqID  := 0;
  aSpecContactHistoryToDB^.PicIcon.LoadFromResourceName(HInstance, 'ICON_4');
  PlugMsg.Msg    := PM_PLUGIN_SPEC_ADD_CNT;
  PlugMsg.WParam := 20;
  PlugMsg.LParam := Integer(aSpecContactHistoryToDB);
  PlugMsg.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg);
  if Boolean(PlugMsg.Result) then
  begin
    aSpecContactHistoryToDB^.UniqID := PlugMsg.Result;
    SpecContactAdding := True;
  end;
end;

{ ������� ����. ������� }
procedure TQipPlugin.DelSpecContacts;
var
  PlugMsg : TPluginMessage;
begin
  PlugMsg.Msg       := PM_PLUGIN_SPEC_DEL_CNT;
  PlugMsg.WParam    := aSpecContactHistoryToDB^.UniqID;
  PlugMsg.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg);
  if Boolean(PlugMsg.Result) then
  begin
    aSpecContactHistoryToDB^.UniqID := 0;
    aSpecContactHistoryToDB^.PicIcon.Free;
    aSpecContactHistoryToDB^.PicIcon := nil;
    Dispose(aSpecContactHistoryToDB);
    SpecContactAdding := False;
  end;
end;

{ ��������� ���� ������ ������� �� ����. �������� }
procedure TQipPlugin.SpecContactRightClick(PlugMsg: TPluginMessage);
var
  aSpecContactHistoryToDB : pSpecContactHistoryToDB;
  Pt       : PPoint;
  MenuItem : TMenuItem;
begin
  aSpecContactHistoryToDB := Pointer(PlugMsg.LParam);

  // �������� ���������� ��� ����
  Pt := PPoint(PlugMsg.NParam);

  if Assigned(FPopupMenu) then FreeAndNil(FPopupMenu);

  FPopupMenu             := TPopupMenu.Create(nil);
  FPopupMenu.AutoHotkeys := maManual;

  if (aSpecContactHistoryToDB = nil) then Exit;
  if aSpecContactHistoryToDB^.SpecContactName = PluginSpecContactName then
  begin
    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('SyncButton');
    MenuItem.OnClick := OnClick_HistorySync;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := '-';
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('GetContactListButton');
    MenuItem.OnClick := OnClick_GetContactList;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('CheckMD5Hash');
    MenuItem.OnClick := OnClick_CheckMD5Hash;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('CheckAndDeleteMD5Hash');
    MenuItem.OnClick := OnClick_CheckAndDeleteMD5Hash;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('UpdateContactListButton');
    MenuItem.OnClick := OnClick_UpdateContactList;
    if FileExists(ProfilePath+ContactListName) then
      MenuItem.Enabled := True
    else
      MenuItem.Enabled := False;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('CheckUpdateButton');
    MenuItem.OnClick := OnClick_CheckUpdateButton;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := '-';
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('SettingsButton');
    MenuItem.OnClick := OnClick_Settings;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := '-';
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);

    MenuItem         := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := GetLangStr('AboutButton');
    MenuItem.OnClick := OnClick_About;
    FPopupMenu.Items.Insert(FPopupMenu.Items.Count, MenuItem);
  end;
  FPopupMenu.Popup(Pt^.X, Pt^.Y);
end;

{ ������� ���� ����� ������� �� ����. �������� }
procedure TQipPlugin.SpecContactDblClick(PlugMsg: TPluginMessage);
var
  WinName: String;
begin
  WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
  if SearchMainWindow(pWideChar(WinName)) then
    OnSendMessageToOneComponent(WinName, '0040') // ���������� ���� �������
  else
  begin
    if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
      ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL)
    else
      ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
  end;
end;

procedure TQipPlugin.DrawSpecContact(PlugMsg: TPluginMessage);
var
  Cnv                     : TCanvas;
  wStr                    : WideString;
  Y                       : Integer;
  QipColors               : pQipColors;
  wFontName               : WideString;
  iFontSize               : Integer;
  PlugMsg_Color           : TPluginMessage;
begin
  aSpecContactHistoryToDB := Pointer(PlugMsg.LParam);
  if (aSpecContactHistoryToDB = nil) or (aSpecContactHistoryToDB^.UniqID = 0) then
    Exit;

  // ������ �� ��������� �������� ������ � �������
  PlugMsg_Color.Msg       := PM_PLUGIN_GET_COLORS_FONT;
  PlugMsg_Color.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg_Color);

  // �������� ��������� �������
  wFontName := PWideChar(PlugMsg_Color.WParam);
  iFontSize := PlugMsg_Color.LParam;
  QipColors := pQipColors(PlugMsg_Color.NParam);

  // ������� ����� ��� ��������� ������ ����. ��������
  Cnv := TCanvas.Create;
  try
    Cnv.Handle := PlugMsg.NParam;
    // ����� �������� ������ �������-�����
    SetBkMode(Cnv.Handle, TRANSPARENT);
    // ������ ����� � ��� ����
    Cnv.Font.Name  := wFontName;
    Cnv.Font.Color := QipColors^.Online;
    if aSpecContactHistoryToDB^.SpecContactName = PluginSpecContactName then
    begin
      // ������ ������ ������ ����. ��������
      DrawIconEx(Cnv.Handle, 6, 2, aSpecContactHistoryToDB^.PicIcon.Handle, 16, 16, 0, 0, DI_NORMAL);
      // ������ ����� ������ ����. ��������
      wStr := aSpecContactHistoryToDB^.SpecContactName;
      // ������ ����� � ��� ����
      Cnv.Font.Size  := iFontSize;
      Cnv.Font.Style := [];
      Cnv.Font.Color := QipColors^.Online;
      // ����� �����
      Y := (20 div 2) - (Cnv.TextHeight(wStr) div 2) - 1;
      Cnv.TextOut(26, Y, wStr);
    end;
  finally
    Cnv.Free;
  end;
end;

{ ������� �� ������ ������� � ���� ��������� }
procedure TQipPlugin.MsgBtnClicked(PlugMsg: TPluginMessage);
var
  AccountUIN: PWideChar;
  AccountName: WideString;
  CD: TContactDetails;
  myWParam, myLParam, myNParam, ProtoType, ProtoID: Integer;
  aBtnClick : pBtnClick;
  MC: IMetaContact;
  metaCnt: Integer;
  metaMenuItem: TMenuItem;
  Pt: TPoint;
  WinName: String;
begin
  // ���������� ����� ������� ���� ��� ���� (����� ��� ������)
  aBtnClick := pBtnClick(PlugMsg.DllHandle);
  if aBtnClick^.RightClick then // ������ ����
    ShowButtonPopupMenu
  else
  begin
    // ���������� ���� QIP ������ �� ��������� ���������� � ����� ������� ������
    myWParam := 0;
    myLParam := 0;
    myNParam := 0;
    if Boolean(VarSendPluginMessage(PM_PLUGIN_GET_NAMES, myWParam, myLParam, myNParam)) then
    begin
      if myWParam <> 0 then
        Global_CurrentAccountUIN := PWideChar(myWParam)
      else
        Global_CurrentAccountUIN := DBUserName;
    end
    else
      Global_CurrentAccountUIN := DBUserName;
    // ���������� ���� QIP ������ �� ��������� ���������� �� �������� �������� �������
    PlugMsg.Msg       := PM_PLUGIN_ACTIVE_MSG_TAB;
    PlugMsg.WParam    := Byte(False);
    PlugMsg.LParam    := 0;
    PlugMsg.NParam    := 0;
    PlugMsg.DllHandle := FPluginInfo.DllHandle;
    FPluginSvc.OnPluginMessage(PlugMsg);
    if (PlugMsg.WParam <> 0) and (PlugMsg.LParam <> 0) then
    begin
      AccountUIN := PWideChar(PlugMsg.WParam);
      ProtoID := PlugMsg.LParam;
      // ��������� ���������� ������������ � ����-��������
      if PlugMsg.NParam > 1 then
      begin
        // �������� ������ ������������ �� ������ �����������.
        PlugMsg.Msg       := PM_PLUGIN_GET_META_CONT;
        PlugMsg.WParam    := ProtoID;
        PlugMsg.LParam    := Integer(AccountUIN);
        PlugMsg.NParam    := 0;
        PlugMsg.DllHandle := FPluginInfo.DllHandle;
        FPluginSvc.OnPluginMessage(PlugMsg);
        if PlugMsg.Result <> 0 then
        begin
          MC := IMetaContact(PlugMsg.Result);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� MsgBtnClicked: ���������� ���-��������� ����-�������� ' + MC.MetaContactName + ' = ' + IntToStr(MC.Count), 2);
          // �������� ���������� ��� ����
          GetCursorPos(Pt);
          if Assigned(metaPopupMenu) then FreeAndNil(metaPopupMenu);
          metaPopupMenu             := TPopupMenu.Create(nil);
          metaPopupMenu.AutoHotkeys := maManual;
          for metaCnt := 1 to MC.Count do
          begin
           metaMenuItem           := TMenuItem.Create(metaPopupMenu);
           metaMenuItem.MenuIndex := metaCnt-1;
           metaMenuItem.Caption   := Format(GetLangStr('ShowContactHistory'), [MC.ContactDetails(metaCnt).ContactName, MC.ContactDetails(metaCnt).AccountName]);
           metaMenuItem.OnClick   := OnClick_metaContact;
           metaPopupMenu.Items.Insert(metaPopupMenu.Items.Count, metaMenuItem);
          end;
          metaPopupMenu.Popup(Pt.X, Pt.Y);
        end;
      end
      else // ���� � ����-�������� ���� ���-�������
      begin
        // �������� ���������� � �����������
        PlugMsg.Msg       := PM_PLUGIN_DETAILS_GET;
        PlugMsg.WParam    := ProtoID;
        PlugMsg.LParam    := Integer(AccountUIN);
        PlugMsg.NParam    := 0;
        PlugMsg.DllHandle := FPluginInfo.DllHandle;
        FPluginSvc.OnPluginMessage(PlugMsg);
        if Boolean(PlugMsg.Result) then
        begin
          CD := pContactDetails(PlugMsg.NParam)^;
          // �������� ��� ����������� �� �������-�����
          AccountName := CD.ContactName;
          // ����� ��������� �����������
          Global_CurrentAccountProtoID := PlugMsg.WParam;
        end
        else
        begin
          AccountName := 'NoName';
          Global_CurrentAccountProtoID := 0;
        end;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� MsgBtnClicked: ������ �����������: AccountUIN  = ' + AccountUIN + ' | AccountName = ' + AccountName + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� MsgBtnClicked: ����������� ������ �����������: AccountName = ' + CD.AccountName + ' | ContactName = ' + CD.ContactName + ' | NickName = ' + CD.NickName + ' | Email = ' + CD.Email, 2);
        // �������� ���������� � ���:
        // 1. �� ������ ��� ��������� ����������� (Global_CurrentAccountProtoID) �������� ��� ProtoName � ProtoAccount
        GetContactList := True;  // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
        AddProtoInFile := False; // �� ��������� ������ ���������� � ���� ProtoListName
        Global_CurrentAccountProtoName := '';
        Global_CurrentAccountProtoAccount := '';
        PlugMsg.Msg       := PM_PLUGIN_PROTOS_SNAPSHOT;
        PlugMsg.WParam    := LongInt(SnapshotIntf);
        PlugMsg.LParam    := 0;
        PlugMsg.DllHandle := FPluginInfo.DllHandle;
        FPluginSvc.OnPluginMessage(PlugMsg);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� MsgBtnClicked: ��� ������: ProtoName = ' + Global_CurrentAccountProtoName + ' | ProtoAccount = ' + Global_CurrentAccountProtoAccount + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
        // End
        if (Global_CurrentAccountProtoName = 'ICQ') then
          ProtoType := 0
        else if (Global_CurrentAccountProtoName = 'Google Talk') then
          ProtoType := 1
        else if (Global_CurrentAccountProtoName = 'MRA') then
          ProtoType := 2
        else if (Global_CurrentAccountProtoName = 'Jabber') then
          ProtoType := 3
        else if (Global_CurrentAccountProtoName = 'QIP.Ru') then
          ProtoType := 4
        else if (Global_CurrentAccountProtoName = 'Facebook') then
          ProtoType := 5
        else if (Global_CurrentAccountProtoName = '���������') then
          ProtoType := 6
        else
          ProtoType := 9;
        // ������ ���������� �������� ����� �������� � ��� UIN
        Global_AccountName := AccountName;
        Global_AccountUIN := AccountUIN;
        // ������ ������� ���� ������� (������� IM-���������)
        Glogal_History_Type := 0;
        if Global_CurrentAccountName = '' then
          Global_CurrentAccountName := Global_CurrentAccountUIN;
        // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
        GetContactList := False;
        // ���������� ��������� N ��������� ���������
        WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
        if SearchMainWindow(pWideChar(WinName)) then
        begin
          // ������ �������:
          //   ��� ������� ��������:
          //     008|0|UserID|UserName|ProtocolType
          //   ��� ������� ����:
          //     008|2|ChatName
          OnSendMessageToOneComponent(WinName, '008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType));
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� ������ - 008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType), 2);
        end
        else
        begin
          if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� MsgBtnClicked: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType), 2);
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType)), nil, SW_SHOWNORMAL);
          end
          else
            ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
        end;
      end;
    end
    else
      MsgInf(GetLangStr('InfoCaption'), GetLangStr('IMNoTab'));
  end;
end;

{ ������� �� ������ ������� � ���� ���-��������� }
procedure TQipPlugin.ChatMsgBtnClicked(PlugMsg: TPluginMessage);
var
  myWParam, myLParam, myNParam: Integer;
  aBtnClick : pBtnClick;
  WinName: String;
begin
  // ���������� ����� ������� ���� ��� ���� (����� ��� ������)
  aBtnClick := pBtnClick(PlugMsg.DllHandle);
  if aBtnClick^.RightClick then // ������ ����
    ShowButtonPopupMenu
  else
  begin
    // ���������� ���� QIP ������ �� ��������� ���������� � ����� ������� ������
    myWParam := 0;
    myLParam := 0;
    myNParam := 0;
    if Boolean(VarSendPluginMessage(PM_PLUGIN_GET_NAMES, myWParam, myLParam, myNParam)) then
    begin
      if myWParam <> 0 then
        Global_CurrentAccountUIN := PWideChar(myWParam)
      else
        Global_CurrentAccountUIN := DBUserName;
    end
    else
      Global_CurrentAccountUIN := DBUserName;
    // ���������� ���� QIP ������ �� ��������� ���������� �� �������� �������� ������� ����
    PlugMsg.Msg       := PM_PLUGIN_ACTIVE_CHAT_TAB;
    PlugMsg.WParam    := Byte(False);
    PlugMsg.LParam    := 0;
    PlugMsg.NParam    := 0;
    PlugMsg.Result    := 0;
    PlugMsg.DllHandle := FPluginInfo.DllHandle;
    FPluginSvc.OnPluginMessage(PlugMsg);
    with PlugMsg do
    if (WParam <> 0) and (LParam <> 0) then
    begin
      Global_ChatName := PWideChar(NParam);
      Global_AccountUIN := PWideChar(LParam);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� � ����: ' + Global_ChatName + ' | ' + Global_AccountUIN, 2);
      // ����� ��������� �����������
      Global_CurrentAccountProtoID := Result;
      // �������� ���������� � ���:
      // 1. �� ������ ��� ��������� ����������� (Global_CurrentAccountProtoID) �������� ��� ProtoName � ProtoAccount
      GetContactList := True;  // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
      AddProtoInFile := False; // �� ��������� ������ ���������� � ���� ProtoListName
      Global_CurrentAccountProtoName := '';
      Global_CurrentAccountProtoAccount := '';
      PlugMsg.Msg       := PM_PLUGIN_PROTOS_SNAPSHOT;
      PlugMsg.WParam    := LongInt(SnapshotIntf);
      PlugMsg.LParam    := 0;
      PlugMsg.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsg);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ��� ������: ProtoName = ' + Global_CurrentAccountProtoName + ' | ProtoAccount = ' + Global_CurrentAccountProtoAccount + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
      // ������ ������� ���� ������� (������� ���-���������)
      Glogal_History_Type := 2;
      if Global_CurrentAccountName = '' then
        Global_CurrentAccountName := Global_CurrentAccountUIN;
      // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
      GetContactList := False;
      // ���������� ��������� N ��������� ���������
      WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
      if SearchMainWindow(pWideChar(WinName)) then
      begin
        // ������ �������:
        //   ��� ������� ��������:
        //     008|0|UserID|UserName|ProtocolType
        //   ��� ������� ����:
        //     008|2|ChatName
        if (ExPrivateChatName) and (Global_ChatName <> Global_AccountUIN) then // ���� ����������� ������ ����� ������. ����
        begin
          OnSendMessageToOneComponent(WinName, '008|2|'+Global_ChatName+' / '+Global_AccountUIN);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� ������ - 008|2|'+Global_ChatName+' / '+Global_AccountUIN, 2);
        end
        else
        begin
          OnSendMessageToOneComponent(WinName, '008|2|'+Global_ChatName);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� ������ - 008|2|'+Global_ChatName, 2);
        end;
      end
      else
      begin
        if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
        begin
          if (ExPrivateChatName) and (Global_ChatName <> Global_AccountUIN) then // ���� ����������� ������ ����� ������. ����
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+' / '+Global_AccountUIN+'"', 2);
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+' / '+Global_AccountUIN+'"'), nil, SW_SHOWNORMAL);
          end
          else
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+'"', 2);
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+'"'), nil, SW_SHOWNORMAL);
          end;
        end
        else
          ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
      end;
    end
    else
      MsgInf(GetLangStr('InfoCaption'), GetLangStr('CHATNoTab'));
  end;
end;

{ ���������� IM-��������� � ��� }
procedure TQipPlugin.AddMsgToLog;
var
  AQIPMsg : pQipMsgPlugin;
  ProtoType: Integer;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_SenderNick, Msg_SenderAcc, Msg_Text, MD5String: WideString;
  Msg_Text_WriteFile: PWideChar;
  Date_Str: String;
  BlockWriteMsg: Boolean;
  InsertSQLData, EncInsertSQLData, WinName: String;
  I: Integer;
  ASize: {$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF};
begin
  AQIPMsg := pQipMsgPlugin(PMSG.WParam);
  // Debug
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� AddMsgToLog: ' +
  'MsgType: ' + IntToStr(AQIPMsg^.MsgType) + ' | ' +
  'MsgTime: ' + IntToStr(AQIPMsg^.MsgTime) + ' (' + DateTimeToStr(UnixToDateTime(AQIPMsg^.MsgTime)) + ')' + ' | ' +
  'ProtoName: ' + AQIPMsg^.ProtoName + ' | ' +
  'ProtoDll: ' + IntToStr(AQIPMsg^.ProtoDll) + ' | ' +
  'SenderAcc: ' + PrepareString(AQIPMsg^.SenderAcc) + ' | ' +
  'SenderNick: ' + PrepareString(AQIPMsg^.SenderNick) + ' | ' +
  'RcvrAcc: ' + PrepareString(AQIPMsg^.RcvrAcc) + ' | ' +
  'RcvrNick: ' + PrepareString(AQIPMsg^.RcvrNick) + ' | ' +
  'MsgText: ' + PrepareString(AQIPMsg^.MsgText) + ' | ' +
  'OfflineMsgText: ' + PrepareString(AQIPMsg^.OfflineMsg) + ' | ' +
  'Blocked: ' + BoolToStr(AQIPMsg^.Blocked, True), 2);
  // End debug
  if BlockSpamMsg and AQIPMsg^.Blocked then
    BlockWriteMsg := True
  else
    BlockWriteMsg := False;
  if not BlockWriteMsg then
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
      8 - Social
      9 - Unknown
    }
    if (PrepareString(AQIPMsg^.ProtoName) = 'ICQ') then
      ProtoType := 0
    else if (PrepareString(AQIPMsg^.ProtoName) = 'Google Talk') then
      ProtoType := 1
    else if (PrepareString(AQIPMsg^.ProtoName) = 'MRA') then
      ProtoType := 2
    else if (PrepareString(AQIPMsg^.ProtoName) = 'Jabber') then
      ProtoType := 3
    else if (PrepareString(AQIPMsg^.ProtoName) = 'QIP.Ru') then
      ProtoType := 4
    else if (PrepareString(AQIPMsg^.ProtoName) = 'Facebook') then
      ProtoType := 5
    else if (PrepareString(AQIPMsg^.ProtoName) = '���������') then
      ProtoType := 6
    else
      ProtoType := 9;
    // ���� OFFMSG � �������-���������, ��
    // ����� � ���� ��������� ��� ������ "������� ��������� (����)"
    if (AnsiString(IntToStr(AQIPMsg^.MsgType)) = '13') then
      Msg_Text_WriteFile :=  AQIPMsg^.OfflineMsg
    else
      Msg_Text_WriteFile :=  AQIPMsg^.MsgText;
    if IsUTF8String(Msg_Text_WriteFile) then
      Msg_Text :=  Msg_Text_WriteFile
    else
      Msg_Text := WideStringToUTF8(PrepareString(Msg_Text_WriteFile));
    Msg_RcvrNick := PrepareString(AQIPMsg^.RcvrNick);
    Msg_RcvrAcc := PrepareString(AQIPMsg^.RcvrAcc);
    Msg_RcvrNick := WideStringToUTF8(Msg_RcvrNick);
    Msg_RcvrAcc := WideStringToUTF8(Msg_RcvrAcc);
    Msg_SenderNick := PrepareString(AQIPMsg^.SenderNick);
    Msg_SenderAcc := PrepareString(AQIPMsg^.SenderAcc);
    Msg_SenderNick := WideStringToUTF8(Msg_SenderNick);
    Msg_SenderAcc := WideStringToUTF8(Msg_SenderAcc);
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToDateTime(AQIPMsg^.MsgTime))
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPMsg^.MsgTime));
    if MsgStatus = 0 then
    begin
      MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPMsg^.MsgTime)) + Msg_Text;
      if (MatchStrings(DBType, 'oracle*')) then // ���� Oracle, �� ����� SQL-��� � ������� MSG_LOG_ORACLE
        InsertSQLData := Format(MSG_LOG_ORACLE, [DBUserName, IntToStr(ProtoType), Msg_SenderNick, Msg_SenderAcc, Msg_RcvrNick, Msg_RcvrAcc, '0', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)])
      else
        InsertSQLData := Format(MSG_LOG, [DBUserName, IntToStr(ProtoType), Msg_SenderNick, Msg_SenderAcc, Msg_RcvrNick, Msg_RcvrAcc, '0', Date_Str, Msg_Text, EncryptMD5(MD5String)]);
    end
    else
    begin
      MD5String := Msg_SenderAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPMsg^.MsgTime)) + Msg_Text;
      if (MatchStrings(DBType, 'oracle*')) then // ���� Oracle, �� ����� SQL-��� � ������� MSG_LOG_ORACLE
        InsertSQLData := Format(MSG_LOG_ORACLE, [DBUserName, IntToStr(ProtoType), Msg_RcvrNick, Msg_RcvrAcc, Msg_SenderNick, Msg_SenderAcc, '1', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)])
      else
        InsertSQLData := Format(MSG_LOG, [DBUserName, IntToStr(ProtoType), Msg_RcvrNick, Msg_RcvrAcc, Msg_SenderNick, Msg_SenderAcc, '1', FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPMsg^.MsgTime)), Msg_Text, EncryptMD5(MD5String)]);
    end;
    // �������� ��������� ����� MMF ��� ��������������� ������ �������������
    if SyncMethod = 0 then
    begin
      WinName := 'HistoryToDBSync for QIP ('+MyAccount+')';
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
        OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '010');
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
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
        if (SyncInterval = 6) and (MessageCount = 20) then
        begin
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
        if (SyncInterval = 7) and (MessageCount = 30) then
        begin
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
      end;
      if SyncInterval = 9 then
      begin
        Inc(MessageCount);
        if MessageCount = SyncMessageCount then
        begin
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
      end;
    end;
  end;
end;

{ ���������� ���-��������� � ��� }
procedure TQipPlugin.AddChatMsgToLog;
var
  AQIPChatMsg : pChatTextInfo;
  Date_Str: String;
  aChatName, aNickName, aProtoAcc, aMsgText, MD5String: WideString;
  aMsgType: Integer;
  aIsPrivate: Boolean;
  InsertSQLData, EncInsertSQLData, WinName: String;
  I: Integer;
  ASize: {$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF};
begin
  AQIPChatMsg := pChatTextInfo(PMSG.NParam);
  { ��������� ������ ������������ ���� ���-���������
  0 - TOPIC � ����� ���� ����������� / �������� ������� ����
  1 - OWN_MESSAGE � ����������� ��������� ����������� � ���
  2 - MESSAGE � ��������� ���������
  3 - JOINED � ���������� � �����
  4 - QUIT � ���������� � ������
  5 - DISCONNECTED � ���������
  6 - NOTIFICATION � �����������
  7 - HIGHLIGHTED � ��������� � ����� ����� � ������
  8 - INFORMATION � �������������� ���������
  9 - ACTION � ��������
  10 - KICKED � ���������� � ����
  11 - MODE � ����� ������}
  if (AnsiString(IntToStr(AQIPChatMsg^.MsgType)) = '1')
    or (AnsiString(IntToStr(AQIPChatMsg^.MsgType)) = '2') then
  begin
    // Debug
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� AddChatMsgToLog: ' +
    'MsgType: ' + IntToStr(AQIPChatMsg^.MsgType) + ' | ' +
    'MsgTime: ' + IntToStr(AQIPChatMsg^.MsgTime) + ' (' + DateTimeToStr(UnixToDateTime(AQIPChatMsg^.MsgTime)) + ')' + ' | ' +
    'ChatName: ' + AQIPChatMsg^.ChatName + ' | ' +
    'ChatCaption: ' + AQIPChatMsg^.ChatCaption + ' | ' +
    'ProtoAcc: ' + AQIPChatMsg^.ProtoAcc + ' | ' +
    'ProtoDll: ' + IntToStr(AQIPChatMsg^.ProtoDll) + ' | ' +
    'NickName: ' + AQIPChatMsg^.NickName + ' | ' +
    //'MyNick: ' + AQIPChatMsg^.MyNick + ' | ' +
    'IsPrivate: ' + BoolToStr(AQIPChatMsg^.IsPrivate, True) + ' | ' +
    'IsSimple: ' + BoolToStr(AQIPChatMsg^.IsSimple, True) + ' | ' +
    'IsIRC: ' + BoolToStr(AQIPChatMsg^.IsIRC, True) + ' | ' +
    'MsgText: ' + PrepareString(AQIPChatMsg^.MsgText), 2);
    // End debug
    // ������ ��������� � �� �� �����!
    if AQIPChatMsg^.MsgText = '' then
      Exit;
    // ��������� ��������� ���� Twitter, ��������� � Facebook
    if ((AQIPChatMsg^.ChatName = '@timeline') and (AQIPChatMsg^.MsgType = 1)) or
      (AQIPChatMsg^.ChatName = '@@wall') or
      (AQIPChatMsg^.ChatName = '@@myfeed') then
      Exit
    else
    begin // ��� ������ ���� ��� �����
      aIsPrivate := AQIPChatMsg^.IsPrivate;
      aMsgType := AQIPChatMsg^.MsgType;
      aNickName := WideStringToUTF8(PrepareString(AQIPChatMsg^.NickName));
    end;
    // ���� ��������� ���, �� ������ ��� ��� ��: <��� ����> / <��� �����������>
    if aIsPrivate and ExPrivateChatName then
      aChatName := WideStringToUTF8(PrepareString(AQIPChatMsg^.ChatCaption)+' / '+PrepareString(AQIPChatMsg^.NickName))
    else
      aChatName := WideStringToUTF8(PrepareString(AQIPChatMsg^.ChatCaption));
    aProtoAcc := WideStringToUTF8(PrepareString(AQIPChatMsg^.ProtoAcc));
    if IsUTF8String(AQIPChatMsg^.MsgText) then
      aMsgText :=  AQIPChatMsg^.MsgText
    else
      aMsgText :=  WideStringToUTF8(PrepareString(AQIPChatMsg^.MsgText));
    MD5String := aNickName + FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPChatMsg^.MsgTime)) + aMsgText;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToDateTime(AQIPChatMsg^.MsgTime))
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(AQIPChatMsg^.MsgTime));
    if (MatchStrings(DBType, 'oracle*')) then // ���� Oracle, �� ����� SQL-��� � ������� CHAT_MSG_LOG_ORACLE
      InsertSQLData := Format(CHAT_MSG_LOG_ORACLE, [DBUserName, IntToStr(aMsgType), 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), BoolToIntStr(AQIPChatMsg^.IsSimple), BoolToIntStr(AQIPChatMsg^.IsIRC), aMsgText, EncryptMD5(MD5String)])
    else
      InsertSQLData := Format(CHAT_MSG_LOG, [DBUserName, IntToStr(aMsgType), Date_Str, aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), BoolToIntStr(AQIPChatMsg^.IsSimple), BoolToIntStr(AQIPChatMsg^.IsIRC), aMsgText, EncryptMD5(MD5String)]);
    // �������� ��������� ����� MMF ��� ��������������� ������ �������������
    if SyncMethod = 0 then
    begin
      WinName := 'HistoryToDBSync for QIP ('+MyAccount+')';
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
        OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '010');
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
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
        if (SyncInterval = 6) and (MessageCount = 20) then
        begin
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
        if (SyncInterval = 7) and (MessageCount = 30) then
        begin
          OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
          MessageCount := 0;
        end;
      end;
    end;
    // End
  end;
end;

{ ����������� ����� ������� ������������ ���� �������� (� �� ��� ��), ��� ���������� ����� ����� � ��� ����  }
procedure TQipPlugin.WantCLPopupMenu(var PlugMsg: TPluginMessage);
var
  metaCnt: Integer;
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� WantCLPopupMenu: �������� PopUp ���� ��������.', 2);
  if pIMetaContact(PlugMsg.WParam)^.UniqueID <> 0 then
  begin
    try
      with PlugMsg, pIMetaContact(WParam)^ do
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� WantCLPopupMenu: �������� PopUp ���� ����-��������: ���������� ���-��������� � ����-�������� = ' + IntToStr(Count), 2);
        // ���� � ��� ��������� ���-���������, �� ��� ������� ������ ����� ����
        for metaCnt := 1 to Count do
        begin
          MenuItem[metaCnt-1].ItemID      := metaCnt;
          MenuItem[metaCnt-1].ItemData    := 0;
          MenuItem[metaCnt-1].MenuIcon    := LoadImage(HInstance, 'ICON_4', IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);
          MenuItem[metaCnt-1].MenuCaption := Format(GetLangStr('ShowContactHistory'), [ContactDetails(metaCnt).ContactName, ContactDetails(metaCnt).AccountName]);
          MenuItem[metaCnt-1].Enabled     := True;
        end;
        PlugMsg.Result := Byte(True); // ������ <> 0 ����� ������ �� ����� ���������
        PlugMsg.LParam := Count;      // ���������� ����������� �����
        PlugMsg.NParam := Integer(@MenuItem);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� WantCLPopupMenu: �������� PopUp ���� ����-��������: ��� ����-�������� = ' + MetaContactName + ' | Meta-ID = ' + IntToStr(UniqueID) + ' | ���� ��������� = ' + BoolToStr(Boolean(LParam), True), 2);
      end;
    except
      on E: Exception do
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� WantCLPopupMenu: ������ = ' + e.Message, 2);
    end;
  end;
end;

{ ���������� � ����� �� ������ ���� � �������-����� }
procedure TQipPlugin.CLPopupMenuItemClick(var PlugMsg: TPluginMessage);
var
  PlugMsgMeta: TPluginMessage;
  AccountName: WideString;
  AccountUIN: WideString;
  ProtoType: Integer;
  WinName: String;
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ���� �� PopUp ���� ��������.', 2);
  if (PlugMsg.NParam <> 0) then
  begin
    with pIMetaContact(PlugMsg.NParam)^ do
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ���� �� PopUp ���� ����-��������: ��� ����-�������� = ' + MetaContactName + ' | Meta-ID = ' + IntToStr(UniqueID) + ' | ��� ���-�������� = ' + ContactDetails(PlugMsg.WParam).ContactName, 2);
      AccountName := ContactDetails(PlugMsg.WParam).ContactName;
      AccountUIN := ContactDetails(PlugMsg.WParam).AccountName;
      Global_CurrentAccountProtoID := Contact(PlugMsg.WParam).ProtoHandle;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ������ �����������: AccountUIN = ' + AccountUIN + ' | AccountName = ' + AccountName + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ����������� ������ �����������: AccountName = ' + ContactDetails(PlugMsg.WParam).AccountName + ' | ContactName = ' + ContactDetails(PlugMsg.WParam).ContactName + ' | NickName = ' + ContactDetails(PlugMsg.WParam).NickName + ' | Email = ' + ContactDetails(PlugMsg.WParam).Email, 2);
      // �������� ���������� � ���:
      // 1. �� ������ ��� ��������� ����������� (Global_CurrentAccountProtoID) �������� ��� ProtoName � ProtoAccount
      GetContactList := True;  // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
      AddProtoInFile := False; // �� ��������� ������ ���������� � ���� ProtoListName
      Global_CurrentAccountProtoName := '';
      Global_CurrentAccountProtoAccount := '';
      PlugMsgMeta.Msg       := PM_PLUGIN_PROTOS_SNAPSHOT;
      PlugMsgMeta.WParam    := LongInt(SnapshotIntf);
      PlugMsgMeta.LParam    := 0;
      PlugMsgMeta.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsgMeta);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ��� ������: ProtoName = ' + Global_CurrentAccountProtoName + ' | ProtoAccount = ' + Global_CurrentAccountProtoAccount + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
      // ��� �������
      if (Global_CurrentAccountProtoName = 'ICQ') then
        ProtoType := 0
      else if (Global_CurrentAccountProtoName = 'Google Talk') then
        ProtoType := 1
      else if (Global_CurrentAccountProtoName = 'MRA') then
        ProtoType := 2
      else if (Global_CurrentAccountProtoName = 'Jabber') then
        ProtoType := 3
      else if (Global_CurrentAccountProtoName = 'QIP.Ru') then
        ProtoType := 4
      else if (Global_CurrentAccountProtoName = 'Facebook') then
        ProtoType := 5
      else if (Global_CurrentAccountProtoName = '���������') then
        ProtoType := 6
      else if (Global_CurrentAccountProtoName = 'Twitter') then
        ProtoType := 7
      else
        ProtoType := 9;
      // ������ ���������� �������� ����� �������� � ��� UIN
      Global_AccountName := AccountName;
      Global_AccountUIN := AccountUIN;
      if Global_CurrentAccountName = '' then
        Global_CurrentAccountName := Global_CurrentAccountUIN;
      // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
      GetContactList := False;
      // ���������� ��������� N ��������� ���������
      WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
      if SearchMainWindow(pWideChar(WinName)) then
      begin
        // ������ �������:
        //   ��� ������� ��������:
        //     008|0|UserID|UserName|ProtocolType
        //   ��� ������� ����:
        //     008|2|ChatName
        OnSendMessageToOneComponent(WinName, '008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType));
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� ������ - 008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType), 2);
      end
      else
      begin
        if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
        begin
          if ProtoType = 7 then // Twitter
          begin
            // ������ ������� ���� ������� (������� ���-���������)
            Glogal_History_Type := 2;
            Global_ChatName := Global_CurrentAccountProtoAccount;
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+'"', 2);
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_ChatName+'"'), nil, SW_SHOWNORMAL);
          end
          else
          begin
            // ������ ������� ���� ������� (������� IM-���������)
            Glogal_History_Type := 0;
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CLPopupMenuItemClick: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType), 2);
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType)), nil, SW_SHOWNORMAL);
          end;
        end
        else
          ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
      end;
    end;
  end;
end;

{ ������� ���������� ���������� � ����� ������� ������ }
function TQipPlugin.GetNames: String;
var
  myWParam, myLParam, myNParam: Integer;
begin
  Result := '';
  // ���������� ���� QIP ������ �� ��������� ���������� � ����� ������� ������
  if Boolean(VarSendPluginMessage(PM_PLUGIN_GET_NAMES, myWParam, myLParam, myNParam)) and (myWParam <> 0) then
    Result := PWideChar(myWParam)
  else
    Result := DBUserName;
end;

{ ������� ���������� ���� �� ������� ������������ }
function TQipPlugin.GetPluginsDataDirectory: String;
var
  //PlugMsg : TPluginMessage;
  iDir, wFoo: Integer;
begin
  Result := '';
  // ���������� ���� QIP ������ �� ��������� ���������� � ���� �� ������� ������������
  if Boolean(VarSendPluginMessage(PM_PLUGIN_GET_PROFILE_DIR, iDir, wFoo, wFoo)) and (iDir <> 0) then
    Result := PWideChar(iDir)
  else
    Result := DllPath;
end;

{ ������� ��� �������� �������� ���� QIP }
function TQipPlugin.VarSendPluginMessage(const AMsg: DWord; var AWParam, ALParam, ANParam): Integer;
var
  PlugMsg: TPluginMessage;
begin
  with PlugMsg do
  begin
    Msg := AMsg;
    WParam := Integer(AWParam);
    LParam := Integer(ALParam);
    NParam := Integer(ANParam);
    DllHandle := FPluginInfo.DllHandle;
    PlugMsg.Result := 0;
  end;
  FPluginSvc.OnPluginMessage(PlugMsg);
  Result := PlugMsg.Result;
  with PlugMsg do
  begin
    Integer(AWParam) := WParam;
    Integer(ALParam) := LParam;
    Integer(ANParam) := NParam;
  end;
end;

{ ������� ��� �������� �������� ���� QIP }
function TQipPlugin.SendPluginMessage(const AMsg: DWord; AWParam, ALParam, ANParam: Integer): Integer;
var
  PluginMsg: TPluginMessage;
begin
  with PluginMsg do
  begin
    Msg := AMsg;
    WParam := AWParam;
    LParam := ALParam;
    NParam := ANParam;
    DllHandle := FPluginInfo.DllHandle;
  end;
  FPluginSvc.OnPluginMessage(PluginMsg);
  Result := PluginMsg.Result;
end;

{ ������� ��� �������� �������� ���� QIP }
function TQipPlugin.SendPluginMessage(const AMsg: DWord; AWParam, ALParam, ANParam, AResult: Integer): Integer;
var
  PluginMsg: TPluginMessage;
begin
  with PluginMsg do
  begin
    Msg := AMsg;
    WParam := AWParam;
    LParam := ALParam;
    NParam := ANParam;
    DllHandle := FPluginInfo.DllHandle;
  end;
  PluginMsg.Result := AResult;
  FPluginSvc.OnPluginMessage(PluginMsg);
  Result := PluginMsg.Result;
end;

{ ������� ��� ��������� ��������������� ���������� �������� QIP Manager }
function TQipPlugin.PlugChecker(PlugMsg: TPluginMessage): Boolean;
begin
  if (PlugMsg.WParam <> 0) and (PlugMsg.LParam <> 0) then
    try
      if PWideChar(PlugMsg.LParam) = 'PluginCheckerGet' then
        if Boolean(SendPluginMessage(
             PM_PLUGIN_MESSAGE,
             PlugMsg.DllHandle,
             LongInt(PWideChar(PlugCheck_Dlink)),
             LongInt(PWideChar(PlugCheck_Ver)),
             LongInt(PWideChar('PluginCheckerGet')))) then
        begin
          Result := True;
          Exit;
        end;
    except
      on e :
        Exception do
        begin
          // ����� ������ � ���
          if WriteErrLog then
            WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
        end;
    end;
  Result := false;
end;

{ ���������� ���� � ������� }
procedure TQipPlugin.OnClick_About(Sender: TObject);
begin
  AboutForm.Show;
end;

{ ���������� ���� �������� ������� }
procedure TQipPlugin.OnClick_Settings(Sender: TObject);
var
  WinName: String;
begin
  // ���� ���� HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBViewer �� ������, �� ���� ������ ����
  begin
    WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
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
        ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '005');
  end
  else // ����� �������� ������ �� ����� ��������
    OnSendMessageToOneComponent(WinName, '005');
end;

{ �������������� ������� }
procedure TQipPlugin.OnClick_HistorySync(Sender: TObject);
begin
  OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '002');
end;

{ ��������� ������ ���������� � ������� ���� }
procedure TQipPlugin.OnClick_GetContactList(Sender: TObject);
var
  PlugMsg: TPluginMessage;
begin
  // ��������� �����
  if ContactListLogOpened then
    CloseLogFile(3);
  if ProtoListLogOpened then
    CloseLogFile(4);
  // ������ ������ ����������
  if FileExists(ProfilePath+ProtoListName) then
    DeleteFile(ProfilePath+ProtoListName);
  GetContactList := True; // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
  AddProtoInFile := True; // ��������� ������ ���������� � ����
  PlugMsg.Msg       := PM_PLUGIN_PROTOS_SNAPSHOT;
  PlugMsg.WParam    := LongInt(SnapshotIntf);
  PlugMsg.LParam    := 0;
  PlugMsg.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg);
  // ������ ������ ���������
  if FileExists(ProfilePath+ContactListName) then
    DeleteFile(ProfilePath+ContactListName);
  PlugMsg.Msg       := PM_PLUGIN_GET_CL_SNAPSHOT;
  PlugMsg.WParam    := LongInt(SnapshotIntf);
  PlugMsg.LParam    := 0;
  PlugMsg.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg);
  ShowFadeWindow(GetLangStr('SaveContactListCompleted'), 0, 1);
  // ��������� �����
  if ContactListLogOpened then
    CloseLogFile(3);
  if ProtoListLogOpened then
    CloseLogFile(4);
  GetContactList := False;
  AddProtoInFile := False;
end;

{ ��������� ���������� MD5-����� }
procedure TQipPlugin.OnClick_CheckMD5Hash(Sender: TObject);
begin
  OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '0050');
end;

{ ��������� ���������� MD5-����� � �������� ���������� }
procedure TQipPlugin.OnClick_CheckAndDeleteMD5Hash(Sender: TObject);
begin
  OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '0051');
end;

{ ������ �� ���������� ������� ����� }
procedure TQipPlugin.OnClick_UpdateContactList(Sender: TObject);
begin
  if FileExists(ProfilePath+ContactListName) then
  begin
    OnSendMessageToOneComponent('HistoryToDBSync for QIP ('+MyAccount+')', '007');
    //ShowFadeWindow(GetLangStr('SendUpdateContactListCompleted'), 0, 1);
  end
  else
    ShowFadeWindow(Format(GetLangStr('SendUpdateContactListErr'), [ContactListName]), 0, 2);
end;

{ ������ �� ������ �������� ���������� }
procedure TQipPlugin.OnClick_CheckUpdateButton(Sender: TObject);
var
  WinName: String;
begin
  // ���� ���� HistoryToDBUpdater
  WinName := 'HistoryToDBUpdater';
  if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� ������, �� ���� ������ ����
  begin
    WinName := 'HistoryToDBUpdater for QIP ('+MyAccount+')';
    if not SearchMainWindow(pWideChar(WinName)) then // ���� HistoryToDBUpdater �� �������, �� ���������
    begin
      if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
      begin
        // ��������� ������
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
      end
      else
        ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']), 0, 2);
    end
    else // ����� �������� ������
      OnSendMessageToOneComponent(WinName, '0040');
  end
  else // ����� �������� ������
    OnSendMessageToOneComponent(WinName, '0040');
end;

{ ���� �� ����������� � ���� metaPopupMenu }
procedure TQipPlugin.OnClick_metaContact(Sender: TObject);
var
  PlugMsgMeta: TPluginMessage;
  pAccountUIN: PWideChar;
  AccountName: WideString;
  AccountUIN: WideString;
  CD: TContactDetails;
  myWParam, myLParam, myNParam, ProtoType, ProtoID: Integer;
  MC: IMetaContact;
  metaID: Integer;
  WinName: String;
begin
  // ���������� ���� QIP ������ �� ��������� ���������� � ����� ������� ������
  myWParam := 0;
  myLParam := 0;
  myNParam := 0;
  if Boolean(VarSendPluginMessage(PM_PLUGIN_GET_NAMES, myWParam, myLParam, myNParam)) then
  begin
    if myWParam <> 0 then
      Global_CurrentAccountUIN := PWideChar(myWParam)
    else
      Global_CurrentAccountUIN := DBUserName;
  end
  else
    Global_CurrentAccountUIN := DBUserName;
  // ���������� ���� QIP ������ �� ��������� ���������� �� �������� �������� �������
  PlugMsgMeta.Msg       := PM_PLUGIN_ACTIVE_MSG_TAB;
  PlugMsgMeta.WParam    := Byte(False);
  PlugMsgMeta.LParam    := 0;
  PlugMsgMeta.NParam    := 0;
  PlugMsgMeta.DllHandle := FPluginInfo.DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsgMeta);
  if (PlugMsgMeta.WParam <> 0) and (PlugMsgMeta.LParam <> 0) then
  begin
    pAccountUIN := PWideChar(PlugMsgMeta.WParam);
    ProtoID := PlugMsgMeta.LParam;
    // ��������� ���������� ������������ � ����-��������
    if PlugMsgMeta.NParam > 1 then
    begin
      // �������� ������ ������������ �� ������ �����������.
      PlugMsgMeta.Msg       := PM_PLUGIN_GET_META_CONT;
      PlugMsgMeta.WParam    := ProtoID;
      PlugMsgMeta.LParam    := Integer(pAccountUIN);
      PlugMsgMeta.NParam    := 0;
      PlugMsgMeta.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsgMeta);
      if PlugMsgMeta.Result <> 0 then
      begin
        MC := IMetaContact(PlugMsgMeta.Result);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ���������� ���-��������� ����-�������� ' + MC.MetaContactName + ' = ' + IntToStr(MC.Count), 2);
        metaID := (sender as TMenuItem).MenuIndex+1;
        if metaID > 0 then
        begin
          AccountName := MC.ContactDetails(metaID).ContactName;
          AccountUIN := MC.ContactDetails(metaID).AccountName;
          Global_CurrentAccountProtoID := MC.Contact(metaID).ProtoHandle;
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ������ �����������: AccountUIN  = ' + AccountUIN + ' | AccountName = ' + AccountName + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ����������� ������ �����������: AccountName = ' + MC.ContactDetails(metaID).AccountName + ' | ContactName = ' + MC.ContactDetails(metaID).ContactName + ' | NickName = ' + MC.ContactDetails(metaID).NickName + ' | Email = ' + MC.ContactDetails(metaID).Email, 2);
        end;
      end;
    end
    else // ���� � ����-�������� ���� ���-�������
    begin
      // �������� ���������� � �����������
      PlugMsgMeta.Msg       := PM_PLUGIN_DETAILS_GET;
      PlugMsgMeta.WParam    := ProtoID;
      PlugMsgMeta.LParam    := Integer(pAccountUIN);
      PlugMsgMeta.NParam    := 0;
      PlugMsgMeta.DllHandle := FPluginInfo.DllHandle;
      FPluginSvc.OnPluginMessage(PlugMsgMeta);
      if Boolean(PlugMsgMeta.Result) then
      begin
        CD := pContactDetails(PlugMsgMeta.NParam)^;
        // �������� ��� ����������� �� �������-�����
        AccountName := CD.ContactName;
        // ����� ��������� �����������
        Global_CurrentAccountProtoID := PlugMsgMeta.WParam;
      end
      else
      begin
        AccountName := 'NoName';
        Global_CurrentAccountProtoID := 0;
      end;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ������ �����������: AccountUIN  = ' + AccountUIN + ' | AccountName = ' + AccountName + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ����������� ������ �����������: AccountName = ' + CD.AccountName + ' | ContactName = ' + CD.ContactName + ' | NickName = ' + CD.NickName + ' | Email = ' + CD.Email, 2);
    end;
    // �������� ���������� � ���:
    // 1. �� ������ ��� ��������� ����������� (Global_CurrentAccountProtoID) �������� ��� ProtoName � ProtoAccount
    GetContactList := True;  // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
    AddProtoInFile := False; // �� ��������� ������ ���������� � ���� ProtoListName
    Global_CurrentAccountProtoName := '';
    Global_CurrentAccountProtoAccount := '';
    PlugMsgMeta.Msg       := PM_PLUGIN_PROTOS_SNAPSHOT;
    PlugMsgMeta.WParam    := LongInt(SnapshotIntf);
    PlugMsgMeta.LParam    := 0;
    PlugMsgMeta.DllHandle := FPluginInfo.DllHandle;
    FPluginSvc.OnPluginMessage(PlugMsgMeta);
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ��� ������: ProtoName = ' + Global_CurrentAccountProtoName + ' | ProtoAccount = ' + Global_CurrentAccountProtoAccount + ' | ProtoID = ' + IntToStr(Global_CurrentAccountProtoID), 2);
    // ��� �������
    if (Global_CurrentAccountProtoName = 'ICQ') then
      ProtoType := 0
    else if (Global_CurrentAccountProtoName = 'Google Talk') then
      ProtoType := 1
    else if (Global_CurrentAccountProtoName = 'MRA') then
      ProtoType := 2
    else if (Global_CurrentAccountProtoName = 'Jabber') then
      ProtoType := 3
    else if (Global_CurrentAccountProtoName = 'QIP.Ru') then
      ProtoType := 4
    else if (Global_CurrentAccountProtoName = 'Facebook') then
      ProtoType := 5
    else if (Global_CurrentAccountProtoName = '���������') then
      ProtoType := 6
    else
      ProtoType := 9;
    // ������ ���������� �������� ����� �������� � ��� UIN
    Global_AccountName := AccountName;
    Global_AccountUIN := AccountUIN;
    // ������ ������� ���� ������� (������� IM-���������)
    Glogal_History_Type := 0;
    // ��������� ��������� PM_PLUGIN_PROTOS_SNAPSHOT
    GetContactList := False;
    if Global_CurrentAccountName = '' then
      Global_CurrentAccountName := Global_CurrentAccountUIN;
    // ���������� ��������� N ��������� ���������
    WinName := 'HistoryToDBViewer for QIP ('+MyAccount+')';
    if SearchMainWindow(pWideChar(WinName)) then
    begin
      // ������ �������:
      //   ��� ������� ��������:
      //     008|0|UserID|UserName|ProtocolType
      //   ��� ������� ����:
      //     008|2|ChatName
      OnSendMessageToOneComponent(WinName, '008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType));
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� ChatMsgBtnClicked: ���������� ������ - 008|0|'+Global_AccountUIN+'|'+Global_AccountName+'|'+IntToStr(ProtoType), 2);
    end
    else
    begin
      if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnClick_metaContact: ��������� ' + PluginPath + 'HistoryToDBViewer.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType), 2);
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(Glogal_History_Type)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'" "'+Global_AccountUIN+'" "'+Global_AccountName+'" '+IntToStr(ProtoType)), nil, SW_SHOWNORMAL);
      end
      else
        ShowFadeWindow(Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']), 0, 1);
    end;
  end
  else
    MsgInf(GetLangStr('InfoCaption'), GetLangStr('IMNoTab'));
end;

{ �������� ������ ��������� }
function TQipPlugin.AddElement(const Contact: pSnapshotElement): HRESULT;
begin
  Result := S_OK;
  if GetContactList then
  begin
    if (Contact <> nil) and (not Contact.IsChatContact) and
      (Contact.AccountName <> 'lastmail.ya.ru') and (Contact.AccountName <> 'new-features@ya.ru') and
      (Contact.GroupName <> 'SearchAgents') and (not MatchStrings(Contact.GroupName, '*@ Twitter')) then
    begin
      with Contact^ do
      begin
        if GroupName = '' then
          WriteInLog(ProfilePath, WideFormat('%s;%s;%s;%d', [AccountName, ContactName, GetLangStr('ContactNotInTheList'), ProtoHandle]), 3)
        else
          WriteInLog(ProfilePath, WideFormat('%s;%s;%s;%d', [AccountName, ContactName, GroupName, ProtoHandle]), 3);
      end;
    end;
  end;
end;

{ �������� ������ ���������� }
function TQipPlugin.AddProto(const Proto: pProtoSnapshotElement): HRESULT;
begin
  if AddProtoInFile then
    Result := S_OK
  else
    Result := S_FALSE;
  if GetContactList then
  begin
    if Proto <> nil then
    begin
      with Proto^ do
      begin
        if AddProtoInFile then // ��������� ������ ���������� � ����
          WriteInLog(ProfilePath, WideFormat('%s;%s;%d;%s;%s;%s', [ProtoName, ProtoAccount, ProtoHandle, NickName, FirstName, LastName]), 4)
        else
        begin
          if ProtoHandle = Global_CurrentAccountProtoID then
          begin
            Global_CurrentAccountUIN := ProtoAccount;
            Global_CurrentAccountProtoID := ProtoHandle;
            Global_CurrentAccountProtoName := ProtoName;
            Global_CurrentAccountProtoAccount := ProtoAccount;
            if (FirstName <> '') and (LastName <> '') then
              Global_CurrentAccountName := FirstName + ' ' + LastName
            else if NickName <> '' then
              Global_CurrentAccountName := NickName
            else
              Global_CurrentAccountName := ProtoAccount;
            Result := S_FALSE;
          end
          else
            Result := S_OK;
          if EnableDebug then WriteInLog(ProfilePath, WideFormat('%s - ������� AddProto - ��� ��������� %s; ������� %s; ����� ��������� %d; �������: %s; ���: %s; �������: %s', [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ProtoName, ProtoAccount, ProtoHandle, NickName, FirstName, LastName]), 2);
        end;
      end;
    end;
  end;
end;

procedure TQipPlugin.SetSnapshotIntf(const Value: ICLSnapshot);
begin
  FSnapshotIntf := Value;
end;

procedure TQipPlugin.ShowButtonPopupMenu;
var
  MenuItem  : TMenuItem;
  Pt        : TPoint;
begin
  // �������� ���������� ��� ����
  GetCursorPos(Pt);

  if Assigned(MPopupMenu) then FreeAndNil(MPopupMenu);

  MPopupMenu             := TPopupMenu.Create(nil);
  MPopupMenu.AutoHotkeys := maManual;

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('SyncButton');
  MenuItem.OnClick := OnClick_HistorySync;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := '-';
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('GetContactListButton');
  MenuItem.OnClick := OnClick_GetContactList;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('CheckMD5Hash');
  MenuItem.OnClick := OnClick_CheckMD5Hash;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('CheckAndDeleteMD5Hash');
  MenuItem.OnClick := OnClick_CheckAndDeleteMD5Hash;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('UpdateContactListButton');
  MenuItem.OnClick := OnClick_UpdateContactList;
  if FileExists(ProfilePath+ContactListName) then
    MenuItem.Enabled := True
  else
    MenuItem.Enabled := False;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('CheckUpdateButton');
  MenuItem.OnClick := OnClick_CheckUpdateButton;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := '-';
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('SettingsButton');
  MenuItem.OnClick := OnClick_Settings;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := '-';
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MenuItem         := TMenuItem.Create(MPopupMenu);
  MenuItem.Caption := GetLangStr('AboutButton');
  MenuItem.OnClick := OnClick_About;
  MPopupMenu.Items.Insert(MPopupMenu.Items.Count, MenuItem);

  MPopupMenu.Popup(Pt.X, Pt.Y);
end;

{ ��������� ��������� � ���������/���������� ������ "����-����",
  ����� ��� ���� ������ ���� �������������� ������ ��� �������������. }
procedure TQipPlugin.AntiBoss(HideAllForms: Boolean);
begin
  if not Assigned(AboutForm) then Exit;
  if HideAllForms then
  begin
    ShowWindow(AboutForm.Handle, SW_HIDE);
    AboutForm.Hide;
    // ���������� ������ �� ������ ��� ���� ������� (����� AntiBoss)
    OnSendMessageToAllComponent('0041');
  end
  else
  begin
    // ���� ����� ���� ����� �������, �� ���������� �
    if Global_AboutForm_Showing then
    begin
      ShowWindow(AboutForm.Handle, SW_SHOW);
      AboutForm.Show;
    end;
    // ���������� ������ �� �������� ��� ���� ������� (����� AntiBoss)
    OnSendMessageToAllComponent('0040');
  end;
end;

{ ������� ��� �������������� ��������� }
procedure TQipPlugin.CoreLanguageChanged;
var
  LangFile: string;
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
        MsgDie(PLUGIN_NAME, 'Not found any language file!');
        Exit;
      end;
    end;
    SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(PLUGIN_NAME, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

{ ��������� ��� �������������� ��������� }
procedure TQipPlugin.OnCurrentLang(var PlugMsg: TPluginMessage);
begin
  with PlugMsg do
  if (WParam <> 0) and (Trim(PWideChar(WParam)) <> '') and not WideSameStr(PWideChar(WParam), FLanguage) then
  begin
    // ������ ���� ��� ����� dll'��
    FLanguage := PWideChar(WParam);
    CoreLanguageChanged;
    with FPluginInfo do
      GetPluginInformation(PlugVerMajor, PlugVerMinor, PluginName, PluginAuthor, PluginDescription, PluginHint);
    // �������� ������� ����� ����� ���� �����������
    OnSendMessageToAllComponent(FLanguage);
    // ���������� ���������� �������� ����� ���������
    StopWatch;
    DefaultLanguage := FLanguage;
    WriteCustomINI(ProfilePath, 'DefaultLanguage', FLanguage);
    StartWatch(ProfilePath, FILE_NOTIFY_CHANGE_LAST_WRITE, False, @ProfileDirChangeCallBack);
  end;
end;

{ ��������� ��� �������������� ��������� }
procedure TQipPlugin.GetPluginInformation(var VersionMajor, VersionMinor: Word; var PluginName, Creator, Description, Hint: PWideChar);
begin
  VersionMajor := PLUGIN_VER_MAJOR;
  VersionMinor := PLUGIN_VER_MINOR;
  Creator      := PWideChar(PLUGIN_AUTHOR);
  PluginName   := PWideChar(PLUGIN_NAME);

  if CoreLanguage = 'Russian' then
    Description  := PWideChar(PLUGIN_DESCRUPTION)
  else
    Description  := PWideChar(PLUGIN_DESCRUPTION_EN);
end;

end.
