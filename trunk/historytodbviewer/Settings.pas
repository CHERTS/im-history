{ ############################################################################ }
{ #                                                                          # }
{ #  �������� ������� HistoryToDBViewer v2.4                                 # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Types, StdCtrls, IniFiles, ComCtrls, Grids, DBGrids, JvExDBGrids, JvDBGrid,
  JvCsvData, MemDS, VirtualTable, DB, ZAbstractConnection, ZConnection,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZClasses, ZDbcIntfs, Main, Global,
  Spin, ExtCtrls, ButtonGroup, ShellAPI, uIMButtonGroup, JvExExtCtrls,
  JvExtComponent, JvOfficeColorButton, Buttons, Menus, JvAppHotKey,
  DCPcrypt2, DCPblockciphers, DCPdes, DCPsha1, DCPbase64, TextFade, ImgList;

type
  TSettingsForm = class(TForm)
    SettingsPageControl: TPageControl;
    MainTabSheet: TTabSheet;
    EncryptionTabSheet: TTabSheet;
    DBGroupBox: TGroupBox;
    LDBType: TLabel;
    LDBAddress: TLabel;
    LDBPort: TLabel;
    LDBName: TLabel;
    LDBLogin: TLabel;
    LDBPasswd: TLabel;
    LDBConnectMethod: TLabel;
    CBDBType: TComboBox;
    EDBAddress: TEdit;
    EDBPort: TEdit;
    EDBName: TEdit;
    EDBUserName: TEdit;
    EDBPasswd: TEdit;
    CBConnectMethod: TComboBox;
    SyncGroupBox: TGroupBox;
    LSyncMethod: TLabel;
    LSyncInterval: TLabel;
    CBSyncMethod: TComboBox;
    CBSyncInterval: TComboBox;
    EventsGroupBox: TGroupBox;
    LNumLastHistoryMsg: TLabel;
    GBKeys: TGroupBox;
    DBGridKeys: TJvDBGrid;
    VirtualTable1: TVirtualTable;
    ZQuery1: TZQuery;
    DataSource1: TDataSource;
    TestConnectionButton: TButton;
    SaveButton: TButton;
    CloseButton: TButton;
    CBAni: TCheckbox;
    CBWriteErrLog: TCheckbox;
    CBEnableEncryption: TCheckBox;
    CBHideSyncIcon: TCheckBox;
    SyncTabSheet: TTabSheet;
    InformTabSheet: TTabSheet;
    GBSyncCustomInterval: TGroupBox;
    LTimeInterval: TLabel;
    LMsgCountInterval: TLabel;
    CBShowPluginButton: TCheckBox;
    ETimeInterval: TSpinEdit;
    EMsgCountInterval: TSpinEdit;
    ENumLastHistoryMsg: TSpinEdit;
    FontsTabSheet: TTabSheet;
    GBMessageFonts: TGroupBox;
    LIncommingMesTitle: TLabel;
    LOutgoingMesTitle: TLabel;
    SettingtButtonGroup: TIMButtonGroup;
    AboutTabSheet: TTabSheet;
    LProgramName: TLabel;
    LabelCopyright: TLabel;
    LabelAuthor: TLabel;
    LVersion: TLabel;
    LVersionNum: TLabel;
    LLicense: TLabel;
    LLicenseType: TLabel;
    LabelWeb: TLabel;
    LabelWebSite: TLabel;
    AboutImage: TImage;
    LOutgoingMes: TLabel;
    LIncommingMes: TLabel;
    FontDialogInTitle: TFontDialog;
    FontDialogOutTitle: TFontDialog;
    FontDialogInBody: TFontDialog;
    FontDialogOutBody: TFontDialog;
    FontInTitle: TSpeedButton;
    FontOutTitle: TSpeedButton;
    FontInBody: TSpeedButton;
    FontOutBody: TSpeedButton;
    FontColorInTitle: TJvOfficeColorButton;
    FontColorOutTitle: TJvOfficeColorButton;
    FontColorInBody: TJvOfficeColorButton;
    FontColorOutBody: TJvOfficeColorButton;
    TitleSpacingBox: TGroupBox;
    LTitleSpacingBefore: TLabel;
    LTitleSpacingAfter: TLabel;
    TitleSpaceBefore: TSpinEdit;
    TitleSpaceAfter: TSpinEdit;
    MessagesSpacingBox: TGroupBox;
    LMessagesSpacingBefore: TLabel;
    LMessagesSpacingAfter: TLabel;
    MessagesSpaceBefore: TSpinEdit;
    MessagesSpaceAfter: TSpinEdit;
    LServiceMes: TLabel;
    FontColorService: TJvOfficeColorButton;
    FontService: TSpeedButton;
    FontDialogService: TFontDialog;
    CBAddSpecialContact: TCheckBox;
    HotKeyTabSheet: TTabSheet;
    GBHotKey: TGroupBox;
    CBHotKey: TCheckBox;
    HotKetStringGrid: TStringGrid;
    IMHotKey: THotKey;
    SetHotKeyButton: TButton;
    DeleteHotKeyButton: TButton;
    ButtonCreateEncryptionKey: TButton;
    ButtonGetEncryptionKey: TButton;
    EncryptKeyPM: TPopupMenu;
    DeleteKey: TMenuItem;
    StatusChangeKey: TMenuItem;
    PasswordChangeKey: TMenuItem;
    EncryptKeyCreateTabSheet: TTabSheet;
    GBKeyProp: TGroupBox;
    LKeyStatusTitle: TLabel;
    LCBEncryptionMethod: TLabel;
    LEncryptionKey: TLabel;
    LLocation: TLabel;
    LKeyLength: TLabel;
    LEncryptionKeyDesc: TLabel;
    LKeyPassword: TLabel;
    CBKeyStatus: TComboBox;
    CBEncryptionMethod: TComboBox;
    ButtonCreateKey: TButton;
    CBLocation: TComboBox;
    EncryptionKey: TMemo;
    KeyLength: TSpinEdit;
    KeyPassword: TEdit;
    KeyPasswordChangeTabSheet: TTabSheet;
    GBKeyPasswordChange: TGroupBox;
    LCurrentPassword: TLabel;
    LNewPassword: TLabel;
    LReNewPassword: TLabel;
    ECurrentPassword: TEdit;
    ENewPassword: TEdit;
    EReNewPassword: TEdit;
    ButtonNewKeyPassword: TButton;
    CBSaveOnly: TCheckBox;
    CBSave: TCheckBox;
    LErrLogSize: TLabel;
    SEErrLogSize: TSpinEdit;
    CBBlockSpamMsg: TCheckBox;
    LThankYou: TLabel;
    CBExPrivateChatName: TCheckBox;
    ThankYou: TLabel;
    GBAddon: TGroupBox;
    CBSyncWhenExit: TCheckBox;
    CBSkypeSupportEnable: TCheckBox;
    CBWriteDebugLog: TCheckBox;
    CBAutoScroll: TCheckBox;
    InterfaceTabSheet: TTabSheet;
    GBAlphaBlend: TGroupBox;
    AlphaBlendVar: TLabel;
    CBAlphaBlend: TCheckBox;
    AlphaBlendTrackBar: TTrackBar;
    GBLang: TGroupBox;
    CBLang: TComboBox;
    LDBReconnectCount: TLabel;
    EDBReconnectCount: TEdit;
    LDBReconnectInterval: TLabel;
    EDBReconnectInterval: TEdit;
    CBAutoStartup: TCheckBox;
    CBRunSkype: TCheckBox;
    CBExitSkype: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveButtonClick(Sender: TObject);
    procedure TestConnectionButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure CBSyncMethodChange(Sender: TObject);
    procedure CBAniClick(Sender: TObject);
    procedure CBWriteErrLogClick(Sender: TObject);
    procedure CBDBTypeChange(Sender: TObject);
    procedure CBEnableEncryptionClick(Sender: TObject);
    procedure ButtonGetEncryptionKeyClick(Sender: TObject);
    procedure ButtonCreateEncryptionKeyClick(Sender: TObject);
    procedure CBHideSyncIconClick(Sender: TObject);
    procedure CBSyncIntervalChange(Sender: TObject);
    procedure SettingtButtonGroupClick(Sender: TObject);
    procedure LabelAuthorClick(Sender: TObject);
    procedure LabelWebSiteClick(Sender: TObject);
    procedure SetAttrParagraph;
    procedure GetAttrParagraph;
    procedure FontInTitleClick(Sender: TObject);
    procedure FontOutTitleClick(Sender: TObject);
    procedure FontInBodyClick(Sender: TObject);
    procedure FontOutBodyClick(Sender: TObject);
    procedure FontColorInTitleColorChange(Sender: TObject);
    procedure FontColorOutTitleColorChange(Sender: TObject);
    procedure FontColorInBodyColorChange(Sender: TObject);
    procedure FontColorOutBodyColorChange(Sender: TObject);
    procedure FontServiceClick(Sender: TObject);
    procedure FontColorServiceColorChange(Sender: TObject);
    procedure SettingtButtonGroupKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CBHotKeyClick(Sender: TObject);
    procedure SetHotKeyButtonClick(Sender: TObject);
    procedure HotKetStringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DeleteHotKeyButtonClick(Sender: TObject);
    procedure VirtualTable1AfterScroll(DataSet: TDataSet);
    procedure VirtualTable1BeforeScroll(DataSet: TDataSet);
    procedure StatusChangeKeyClick(Sender: TObject);
    procedure DBParamSet;
    procedure ButtonCreateKeyClick(Sender: TObject);
    procedure DeleteKeyClick(Sender: TObject);
    procedure PasswordChangeKeyClick(Sender: TObject);
    procedure ButtonNewKeyPasswordClick(Sender: TObject);
    procedure CBSaveClick(Sender: TObject);
    procedure CBAlphaBlendClick(Sender: TObject);
    procedure AlphaBlendTrackBarChange(Sender: TObject);
    procedure MemoThankYou2Enter(Sender: TObject);
    procedure CBLangChange(Sender: TObject);
    procedure FindLangFile;
    function DBParamCheck: Boolean;
    procedure CBSkypeSupportEnableClick(Sender: TObject);
  private
    { Private declarations }
    SHeaderFontInTitle    : TFont;
    SHeaderFontOutTitle   : TFont;
    SHeaderFontInBody     : TFont;
    SHeaderFontOutBody    : TFont;
    SHeaderFontServiceMsg : TFont;
    HotKeySelectedCell    : Integer;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.dfm}

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  AboutBitmap: TBitmap;
  I: Integer;
begin
  // ��� �������������� ���������
  SettingsFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // ��������� ����
  for I := 0 to SettingsPageControl.PageCount-1 do
    SettingsPageControl.Pages[I].TabVisible := False;
  // ������ ������� ������ �� ����� ��������
  AboutBitmap := TBitmap.Create;
  try
    AboutBitmap.LoadFromResourceName(HInstance, 'ABOUT');
    AboutImage.Width := AboutBitmap.Width;
    AboutImage.Height := AboutBitmap.Height;
    AboutImage.Picture.Assign(AboutBitmap);
  finally
    AboutBitmap.Free;
  end;
  LabelAuthor.Cursor := crHandPoint;
  LabelWebSite.Cursor := crHandPoint;
  SHeaderFontInTitle := TFont.Create;
  SHeaderFontOutTitle := TFont.Create;
  SHeaderFontInBody := TFont.Create;
  SHeaderFontOutBody := TFont.Create;
  SHeaderFontServiceMsg := TFont.Create;
end;

procedure TSettingsForm.FormDestroy(Sender: TObject);
begin
  SHeaderFontInTitle.Free;
  SHeaderFontOutTitle.Free;
  SHeaderFontInBody.Free;
  SHeaderFontOutBody.Free;
  SHeaderFontServiceMsg.Free;
end;

procedure TSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ���������� ��� ������ ����-����
  Global_SettingsForm_Showing := False;
  // �������� �� �������� �������� ��� �������
  if ShowSettingsFormOnStart then
  begin
    ShowSettingsFormOnStart := False;
    SettingsForm.Position := poMainFormCenter;
  end;
  WriteCustomINI(ProfilePath, 'Main', 'SettingsFormRequestSend', '0');
end;

procedure TSettingsForm.FormShow(Sender: TObject);
var
  I, J: Integer;
  Drivers: IZCollection;
  Protocols: TStringDynArray;
begin
  // ���������� ��� ������ ����-����
  Global_SettingsForm_Showing := True;
  // ��������� ���� ����������
  LoadLanguageStrings;
  // ������ ���������
  LoadINI(ProfilePath, false);
  SettingsPageControl.ActivePage := MainTabSheet;
  // ������� ������ �������������� ����������
  CBDBType.Clear;
  Drivers := DriverManager.GetDrivers;
  for I := 0 to Drivers.Count - 1 do
  begin
    Protocols := (Drivers.Items[I] as IZDriver).GetSupportedProtocols;
    for J := 0 to High(Protocols) do
      CBDBType.Items.Add(Protocols[J]);
  end;
  CBDBType.Sorted := True;
  // End
  for I := 0 to CBDBType.Items.Count-1 do
  begin
    if CBDBType.Items[I] = DBType then
      CBDBType.ItemIndex := I;
  end;
  EDBPort.Text := DBPort;
  EDBName.Text := DBName;
  EDBUserName.Text := DBUserName;
  EDBPasswd.Text := DBPasswd;
  CBSyncMethod.ItemIndex := SyncMethod;
  if (CBDBType.Items[CBDBType.ItemIndex] = 'sqlite') or
   (CBDBType.Items[CBDBType.ItemIndex] = 'sqlite-3') then
  begin
    EDBAddress.Text := DBAddress;
    EDBAddress.Enabled := false;
    EDBPort.Enabled := false;
    EDBPasswd.Enabled := false;
    LDBName.Caption := GetLangStr('LDBName');
  end
  else if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
   (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
  begin
    EDBAddress.Text := DBSchema;
    EDBAddress.Enabled := true;
    EDBPort.Enabled := false;
    LDBName.Caption := GetLangStr('LDBNameOracle');
    LDBAddress.Caption := GetLangStr('LDBSchema');
  end
  else
  begin
    EDBAddress.Text := DBAddress;
    EDBAddress.Enabled := true;
    EDBPort.Enabled := true;
    EDBPasswd.Enabled := true;
    LDBName.Caption := GetLangStr('LDBName');
    LDBAddress.Caption := GetLangStr('LDBAddress');
  end;
  if SyncMethod = 2 then
  begin
    CBSyncInterval.ItemIndex := SyncInterval;
    CBSyncInterval.Enabled := True;
    LSyncInterval.Enabled := True;
  end
  else
  begin
    SyncInterval := -1;
    CBSyncInterval.Enabled := False;
    LSyncInterval.Enabled := False;
  end;
  EDBReconnectCount.Text := IntToStr(ReconnectCount);
  EDBReconnectInterval.Text := IntToStr(ReconnectInterval);
  CBAni.Checked := AniEvents;
  CBWriteErrLog.Checked := WriteErrLog;
  CBWriteDebugLog.Checked := EnableDebug;
  ENumLastHistoryMsg.Text := IntToStr(NumLastHistoryMsg);
  ETimeInterval.Text := IntToStr(SyncTimeCount);
  EMsgCountInterval.Text := IntToStr(SyncMessageCount);
  CBHideSyncIcon.Checked := HideSyncIcon;
  CBShowPluginButton.Checked := ShowPluginButton;
  CBEnableEncryption.Checked := EnableHistoryEncryption;
  if CBEnableEncryption.Checked then
  begin
    GBKeys.Visible := True;
  end
  else
  begin
    GBKeys.Visible := False;
  end;
  CBSyncIntervalChange(Self);
  CBAddSpecialContact.Checked := AddSpecialContact;
  SettingtButtonGroup.ItemIndex := 0;
  CBSaveOnly.Checked := KeyPasswdSaveOnlySession;
  CBSave.Checked := KeyPasswdSave;
  CBBlockSpamMsg.Checked := BlockSpamMsg;
  CBSyncWhenExit.Checked := SyncWhenExit;
  CBAutoScroll.Checked := HistoryAutoScroll;
  // ��������� ��������
  if CBSave.Checked then
  begin
    CBSaveOnly.Enabled := False;
    CBSaveOnly.Checked := False;
  end
  else
  begin
    CBSaveOnly.Enabled := True;
    CBSaveOnly.Checked := KeyPasswdSaveOnlySession;
  end;
  // ������ � �.�.
  SHeaderFontInTitle.Assign(MainForm.FHeaderFontInTitle);
  SHeaderFontOutTitle.Assign(MainForm.FHeaderFontOutTitle);
  SHeaderFontInBody.Assign(MainForm.FHeaderFontInBody);
  SHeaderFontOutBody.Assign(MainForm.FHeaderFontOutBody);
  SHeaderFontServiceMsg.Assign(MainForm.FHeaderFontServiceMsg);
  FontInTitle.Caption := SHeaderFontInTitle.Name + ', ' + IntToStr(SHeaderFontInTitle.Size) + ' pt';
  FontColorInTitle.SelectedColor := SHeaderFontInTitle.Color;
  FontOutTitle.Caption := SHeaderFontOutTitle.Name + ', ' + IntToStr(SHeaderFontOutTitle.Size) + ' pt';
  FontColorOutTitle.SelectedColor := SHeaderFontOutTitle.Color;
  FontInBody.Caption := SHeaderFontInBody.Name + ', ' + IntToStr(SHeaderFontInBody.Size) + ' pt';
  FontColorInBody.SelectedColor := SHeaderFontInBody.Color;
  FontOutBody.Caption := SHeaderFontOutBody.Name + ', ' + IntToStr(SHeaderFontOutBody.Size) + ' pt';
  FontColorOutBody.SelectedColor := SHeaderFontOutBody.Color;
  FontService.Caption := SHeaderFontServiceMsg.Name + ', ' + IntToStr(SHeaderFontServiceMsg.Size) + ' pt';
  FontColorService.SelectedColor := SHeaderFontServiceMsg.Color;
  FontInTitle.Font.Name := SHeaderFontInTitle.Name;
  FontInTitle.Font.Style := SHeaderFontInTitle.Style;
  FontInTitle.Font.Color := SHeaderFontInTitle.Color;
  FontOutTitle.Font.Name := SHeaderFontOutTitle.Name;
  FontOutTitle.Font.Style := SHeaderFontOutTitle.Style;
  FontOutTitle.Font.Color := SHeaderFontOutTitle.Color;
  FontInBody.Font.Name := SHeaderFontInBody.Name;
  FontInBody.Font.Style := SHeaderFontInBody.Style;
  FontInBody.Font.Color := SHeaderFontInBody.Color;
  FontOutBody.Font.Name := SHeaderFontOutBody.Name;
  FontOutBody.Font.Style := SHeaderFontOutBody.Style;
  FontOutBody.Font.Color := SHeaderFontOutBody.Color;
  FontService.Font.Name := SHeaderFontServiceMsg.Name;
  FontService.Font.Style := SHeaderFontServiceMsg.Style;
  FontService.Font.Color := SHeaderFontServiceMsg.Color;
  SetAttrParagraph;
  HotKeySelectedCell := 1;
  // ����������� ������� �������
  HotKetStringGrid.RowCount := 5;
  HotKetStringGrid.ColWidths[0] := 250;
  HotKetStringGrid.Cells[0,1] := GetLangStr('SyncButton') + ' (' + ProgramsName + ')';
  HotKetStringGrid.Cells[0,2] := GetLangStr('SyncButton') + ' (HistoryToDBSync)';
  HotKetStringGrid.Cells[0,3] := GetLangStr('ExSearch');
  HotKetStringGrid.Cells[0,4] := GetLangStr('ExSearchNext');
  if GlobalHotKeyEnable then
  begin
    GBHotKey.Visible := True;
    CBHotKey.Checked := True;
  end
  else
  begin
    GBHotKey.Visible := False;
    CBHotKey.Checked := False;
  end;
  HotKetStringGrid.Cells[1,1] := SyncHotKey;
  HotKetStringGrid.Cells[1,2] := SyncHotKeyDBSync;
  HotKetStringGrid.Cells[1,3] := ExSearchHotKey;
  HotKetStringGrid.Cells[1,4] := ExSearchNextHotKey;
  IMHotKey.HotKey := TextToShortCut(HotKetStringGrid.Cells[1,1]);
  // ��������� ������� �������� ������ ����������
  CBKeyStatus.Clear;
  CBKeyStatus.Items.Add(GetLangStr('KeyStatusInactive'));
  CBKeyStatus.Items.Add(GetLangStr('KeyStatusActive'));
  CBKeyStatus.ItemIndex := 1;
  CBLocation.Clear;
  CBLocation.Items.Add(GetLangStr('KeyLocationLocal'));
  CBLocation.Items.Add(GetLangStr('KeyLocationServer'));
  CBLocation.ItemIndex := 1;
  CBEncryptionMethod.Clear;
  CBEncryptionMethod.Items.Add('DES');
  CBEncryptionMethod.Items.Add('3DES');
  CBEncryptionMethod.Items.Add('SHA1');
  CBEncryptionMethod.ItemIndex := 1;
  EncryptionKey.Text := '';
  KeyLength.Text := '15';
  SEErrLogSize.Text := IntToStr(MaxErrLogSize);
  // ������������ ����
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
  if AlphaBlendEnable then
  begin
    CBAlphaBlend.Checked := True;
    AlphaBlendTrackBar.Visible := True;
    AlphaBlendVar.Visible := True;
    AlphaBlendTrackBar.Position := AlphaBlendEnableValue;
    AlphaBlendVar.Caption := IntToStr(AlphaBlendEnableValue);
  end
  else
  begin
    CBAlphaBlend.Checked := False;
    AlphaBlendTrackBar.Visible := False;
    AlphaBlendVar.Visible := False;
  end;
  // ����
  CBExPrivateChatName.Checked := ExPrivateChatName;
  // Skype
  CBSkypeSupportEnable.Checked := GlobalSkypeSupport;
  CBAutoStartup.Checked := Global_AutoRunHistoryToDBSync;
  CBRunSkype.Checked := Global_RunningSkypeOnStartup;
  CBExitSkype.Checked := Global_ExitSkypeOnEnd;
  if GlobalSkypeSupport then
  begin
    CBAutoStartup.Enabled := True;
    CBRunSkype.Enabled := True;
    CBExitSkype.Enabled := True;
  end
  else
  begin
    CBAutoStartup.Enabled := False;
    CBRunSkype.Enabled := False;
    CBExitSkype.Enabled := False;
  end;
  // ��������� ������ ������
  FindLangFile;
end;

procedure TSettingsForm.SetAttrParagraph;
begin
  TitleSpaceBefore.Value := IMEditorParagraphTitleSpaceBefore;
  TitleSpaceAfter.Value := IMEditorParagraphTitleSpaceAfter;
  MessagesSpaceBefore.Value := IMEditorParagraphMessagesSpaceBefore;
  MessagesSpaceAfter.Value := IMEditorParagraphMessagesSpaceAfter;
end;

procedure TSettingsForm.GetAttrParagraph;
begin
  IMEditorParagraphTitleSpaceBefore := TitleSpaceBefore.Value;
  IMEditorParagraphTitleSpaceAfter := TitleSpaceAfter.Value;
  IMEditorParagraphMessagesSpaceBefore := MessagesSpaceBefore.Value;
  IMEditorParagraphMessagesSpaceAfter := MessagesSpaceAfter.Value;
end;

procedure TSettingsForm.FontInTitleClick(Sender: TObject);
begin
  FontDialogInTitle.Font.Assign(SHeaderFontInTitle);
  if FontDialogInTitle.Execute then
  begin
    SHeaderFontInTitle.Assign(FontDialogInTitle.Font);
    FontInTitle.Caption := FontDialogInTitle.Font.Name + ', ' + IntToStr(FontDialogInTitle.Font.Size) + ' pt';
    FontInTitle.Font.Name := FontDialogInTitle.Font.Name;
    FontInTitle.Font.Style := FontDialogInTitle.Font.Style;
  end;
end;

procedure TSettingsForm.FontOutTitleClick(Sender: TObject);
begin
  FontDialogOutTitle.Font.Assign(SHeaderFontOutTitle);
  if FontDialogOutTitle.Execute then
  begin
    SHeaderFontOutTitle.Assign(FontDialogOutTitle.Font);
    FontOutTitle.Caption := FontDialogOutTitle.Font.Name + ', ' + IntToStr(FontDialogOutTitle.Font.Size) + ' pt';
    FontOutTitle.Font.Name := FontDialogOutTitle.Font.Name;
    FontOutTitle.Font.Style := FontDialogOutTitle.Font.Style;
  end;
end;

procedure TSettingsForm.FontInBodyClick(Sender: TObject);
begin
  FontDialogInBody.Font.Assign(SHeaderFontInBody);
  if FontDialogInBody.Execute then
  begin
    SHeaderFontInBody.Assign(FontDialogInBody.Font);
    FontInBody.Caption := FontDialogInBody.Font.Name + ', ' + IntToStr(FontDialogInBody.Font.Size) + ' pt';
    FontInBody.Font.Name := FontDialogInBody.Font.Name;
    FontInBody.Font.Style := FontDialogInBody.Font.Style;
  end;
end;

procedure TSettingsForm.FontOutBodyClick(Sender: TObject);
begin
  FontDialogOutBody.Font.Assign(SHeaderFontOutBody);
  if FontDialogOutBody.Execute then
  begin
    SHeaderFontOutBody.Assign(FontDialogOutBody.Font);
    FontOutBody.Caption := FontDialogOutBody.Font.Name + ', ' + IntToStr(FontDialogOutBody.Font.Size) + ' pt';
    FontOutBody.Font.Name := FontDialogOutBody.Font.Name;
    FontOutBody.Font.Style := FontDialogOutBody.Font.Style;
  end;
end;

procedure TSettingsForm.FontServiceClick(Sender: TObject);
begin
  FontDialogService.Font.Assign(SHeaderFontServiceMsg);
  if FontDialogService.Execute then
  begin
    SHeaderFontServiceMsg.Assign(FontDialogService.Font);
    FontService.Caption := FontDialogService.Font.Name + ', ' + IntToStr(FontDialogService.Font.Size) + ' pt';
    FontService.Font.Name := FontDialogService.Font.Name;
    FontService.Font.Style := FontDialogService.Font.Style;
  end;
end;

procedure TSettingsForm.FontColorInTitleColorChange(Sender: TObject);
begin
  SHeaderFontInTitle.Color := FontColorInTitle.SelectedColor;
  FontInTitle.Font.Color := FontColorInTitle.SelectedColor;
  SettingsForm.Show;
end;

procedure TSettingsForm.FontColorOutTitleColorChange(Sender: TObject);
begin
  SHeaderFontOutTitle.Color := FontColorOutTitle.SelectedColor;
  FontOutTitle.Font.Color := FontColorOutTitle.SelectedColor;
  SettingsForm.Show;
end;

procedure TSettingsForm.FontColorInBodyColorChange(Sender: TObject);
begin
  SHeaderFontInBody.Color := FontColorInBody.SelectedColor;
  FontInBody.Font.Color := FontColorInBody.SelectedColor;
  SettingsForm.Show;
end;

procedure TSettingsForm.FontColorOutBodyColorChange(Sender: TObject);
begin
  SHeaderFontOutBody.Color := FontColorOutBody.SelectedColor;
  FontOutBody.Font.Color := FontColorOutBody.SelectedColor;
  SettingsForm.Show;
end;

procedure TSettingsForm.FontColorServiceColorChange(Sender: TObject);
begin
  SHeaderFontServiceMsg.Color := FontColorService.SelectedColor;
  FontService.Font.Color := FontColorService.SelectedColor;
  SettingsForm.Show;
end;

procedure TSettingsForm.SettingtButtonGroupClick(Sender: TObject);
begin
  SettingsPageControl.ActivePageIndex := SettingtButtonGroup.ItemIndex;
  if SettingsPageControl.ActivePage = EncryptionTabSheet then
  begin
    DBGridKeys.Columns[0].Title.Caption := GetLangStr('DBGridKeysColumnID');
    DBGridKeys.Columns[1].Title.Caption := GetLangStr('DBGridKeysColumnSTATUS');
    DBGridKeys.Columns[2].Title.Caption := GetLangStr('DBGridKeysColumnMETHOD');
    if CBEnableEncryption.Checked then
      ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
  end
  else
  begin
    VirtualTable1.Close;
    VirtualTable1.Clear;
    VirtualTable1.AfterScroll := nil;
    DBGridKeys.PopupMenu := nil;
  end;
end;

procedure TSettingsForm.SettingtButtonGroupKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  SettingsPageControl.ActivePageIndex := SettingtButtonGroup.ItemIndex;
  if SettingsPageControl.ActivePage = EncryptionTabSheet then //EncryptionTabSheet
  begin
    DBGridKeys.Columns[0].Title.Caption := GetLangStr('DBGridKeysColumnID');
    DBGridKeys.Columns[1].Title.Caption := GetLangStr('DBGridKeysColumnSTATUS');
    DBGridKeys.Columns[2].Title.Caption := GetLangStr('DBGridKeysColumnMETHOD');
    if CBEnableEncryption.Checked then
      ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
  end
  else
  begin
    VirtualTable1.Close;
    VirtualTable1.Clear;
    VirtualTable1.AfterScroll := nil;
    DBGridKeys.PopupMenu := nil;
  end;
end;

{ ���������� �������� }
procedure TSettingsForm.SaveButtonClick(Sender: TObject);
var
  Path: WideString;
  IsFileClosed: Boolean;
  sFile: DWORD;
  INI: TIniFile;
  I: Integer;
begin
  if DBParamCheck then
  begin
    WriteCustomINI(ProfilePath, 'Main', 'SettingsFormRequestSend', '0');
    VirtualTable1.Close;
    VirtualTable1.Clear;
    DBType := CBDBType.Items[CBDBType.ItemIndex];
    if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
      (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
      DBSchema := EDBAddress.Text
    else
      DBAddress := EDBAddress.Text;
    DBPort := EDBPort.Text;
    // ������ ��������� � ������ DBName
    if MatchStrings(EDBName.Text,'<ProfilePluginPath>*') then
      DBName := StringReplace(EDBName.Text,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
    else if MatchStrings(EDBName.Text,'<PluginPath>*') then
      DBName := StringReplace(EDBName.Text,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall])
    else
      DBName := EDBName.Text;
    // End
    ReconnectCount := StrToInt(EDBReconnectCount.Text);
    ReconnectInterval := StrToInt(EDBReconnectInterval.Text);
    DBUserName := EDBUserName.Text;
    DBPasswd := EDBPasswd.Text;
    SyncMethod := CBSyncMethod.ItemIndex;
    if SyncMethod = 2 then
      SyncInterval := CBSyncInterval.ItemIndex
    else
      SyncInterval := 0;
    SyncMessageCount := StrToInt(EMsgCountInterval.Text);
    SyncTimeCount := StrToInt(ETimeInterval.Text);
    NumLastHistoryMsg := StrToInt(ENumLastHistoryMsg.Text);
    AniEvents := CBAni.Checked;
    WriteErrLog := CBWriteErrLog.Checked;
    EnableDebug := CBWriteDebugLog.Checked;
    HistoryAutoScroll := CBAutoScroll.Checked;
    ShowPluginButton := CBShowPluginButton.Checked;
    EnableHistoryEncryption := CBEnableEncryption.Checked;
    KeyPasswdSaveOnlySession := CBSaveOnly.Checked;
    KeyPasswdSave := CBSave.Checked;
    MaxErrLogSize := StrToInt(SEErrLogSize.Text);
    BlockSpamMsg := CBBlockSpamMsg.Checked;
    ExPrivateChatName := CBExPrivateChatName.Checked;
    SyncWhenExit := CBSyncWhenExit.Checked;
    DefaultLanguage := MainForm.IMCoreLanguage;
    GlobalSkypeSupport := CBSkypeSupportEnable.Checked;
    Global_AutoRunHistoryToDBSync := CBAutoStartup.Checked;
    Global_RunningSkypeOnStartup := CBRunSkype.Checked;
    Global_ExitSkypeOnEnd := CBExitSkype.Checked;
    // ��������� �������� � �������
    MainForm.FHeaderFontInTitle.Assign(SHeaderFontInTitle);
    MainForm.FHeaderFontOutTitle.Assign(SHeaderFontOutTitle);
    MainForm.FHeaderFontInBody.Assign(SHeaderFontInBody);
    MainForm.FHeaderFontOutBody.Assign(SHeaderFontOutBody);
    MainForm.FHeaderFontServiceMsg.Assign(SHeaderFontServiceMsg);
    GetAttrParagraph;
    // ��������� ���������� ������� ������
    MainForm.RegisterHotKeys;
    // �������������
    MainForm.HistoryRichView.HideSelection := not HistoryAutoScroll;
    Path := ProfilePath + ININame;
    if FileExists(Path) then
    begin
      try
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
        INI.WriteString('Main', 'DBType', CBDBType.Items[CBDBType.ItemIndex]);
        if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
          (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
          INI.WriteString('Main', 'DBSchema', EDBAddress.Text)
        else
          INI.WriteString('Main', 'DBAddress', EDBAddress.Text);
        INI.WriteString('Main', 'DBPort', EDBPort.Text);
        INI.WriteString('Main', 'DBName', EDBName.Text);
        INI.WriteInteger('Main', 'DBReconnectCount', ReconnectCount);
        INI.WriteInteger('Main', 'DBReconnectInterval', ReconnectInterval);
        INI.WriteString('Main', 'DBUserName', EDBUserName.Text);
        INI.WriteString('Main', 'DBPasswd', EncryptStr(EDBPasswd.Text));
        INI.WriteInteger('Main', 'SyncMethod', SyncMethod);
        INI.WriteInteger('Main', 'SyncInterval', SyncInterval);
        INI.WriteInteger('Main', 'SyncTimeCount', SyncTimeCount);
        INI.WriteInteger('Main', 'SyncMessageCount', SyncMessageCount);
        INI.WriteString('Main', 'SyncWhenExit', BoolToIntStr(SyncWhenExit));
        INI.WriteInteger('Main', 'NumLastHistoryMsg', NumLastHistoryMsg);
        INI.WriteString('Main', 'WriteErrLog', BoolToIntStr(WriteErrLog));
        INI.WriteString('Main', 'EnableDebug', BoolToIntStr(EnableDebug));
        INI.WriteString('Main', 'ShowAnimation', BoolToIntStr(AniEvents));
        INI.WriteString('Main', 'BlockSpamMsg', BoolToIntStr(BlockSpamMsg));
        INI.WriteString('Main', 'EnableHistoryEncryption', BoolToIntStr(EnableHistoryEncryption));
        INI.WriteString('Main', 'HideHistorySyncIcon', BoolToIntStr(HideSyncIcon));
        INI.WriteString('Main', 'ShowPluginButton', BoolToIntStr(ShowPluginButton));
        INI.WriteString('Main', 'AddSpecialContact', BoolToIntStr(CBAddSpecialContact.Checked));
        INI.WriteString('Main', 'HistoryAutoScroll', BoolToIntStr(HistoryAutoScroll));
        INI.WriteString('Main', 'AlphaBlend', BoolToIntStr(AlphaBlendEnable));
        INI.WriteInteger('Main', 'AlphaBlendValue', AlphaBlendEnableValue);
        INI.WriteString('Main', 'EnableExPrivateChatName', BoolToIntStr(ExPrivateChatName));
        INI.WriteString('Main', 'KeyPasswdSaveOnlySession', BoolToIntStr(KeyPasswdSaveOnlySession));
        INI.WriteString('Main', 'KeyPasswdSave', BoolToIntStr(KeyPasswdSave));
        // ��������� ������ ������ ��� ���������
        if MyKeyPasswordPointer.Count > 0 then
        begin
          for I := 0 to MyKeyPasswordPointer.Count-1 do
          begin
            if KeyPasswdSave then
              INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID), MyKeyPasswordPointer.PasswordArray[I].KeyPassword)
            else
              INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID), 'NoSave');
          end;
        end;
        // End
        INI.WriteInteger('Main', 'MaxErrLogSize', MaxErrLogSize);
        INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
        INI.WriteString('Main', 'SkypeSupport', BoolToIntStr(GlobalSkypeSupport));
        INI.WriteString('Main', 'RunningSkypeOnStartup', BoolToIntStr(Global_RunningSkypeOnStartup));
        INI.WriteString('Main', 'ExitSkypeOnEnd', BoolToIntStr(Global_ExitSkypeOnEnd));
        INI.WriteString('Main', 'AutoRunHistoryToDBSync', BoolToIntStr(Global_AutoRunHistoryToDBSync));
        INI.WriteString('Fonts', 'FontInTitle', FontToStr(MainForm.FHeaderFontInTitle));
        INI.WriteString('Fonts', 'FontOutTitle', FontToStr(MainForm.FHeaderFontOutTitle));
        INI.WriteString('Fonts', 'FontInBody', FontToStr(MainForm.FHeaderFontInBody));
        INI.WriteString('Fonts', 'FontOutBody', FontToStr(MainForm.FHeaderFontOutBody));
        INI.WriteString('Fonts', 'FontService', FontToStr(MainForm.FHeaderFontServiceMsg));
        INI.WriteString('Fonts', 'TitleParagraph', IntToStr(TitleSpaceBefore.Value)+'|'+IntToStr(TitleSpaceAfter.Value)+'|');
        INI.WriteString('Fonts', 'MessagesParagraph', IntToStr(MessagesSpaceBefore.Value)+'|'+IntToStr(MessagesSpaceAfter.Value)+'|');
        INI.WriteString('HotKey', 'GlobalHotKey', BoolToIntStr(GlobalHotKeyEnable));
        INI.WriteString('HotKey', 'SyncHotKey', SyncHotKey);
        INI.WriteString('HotKey', 'SyncHotKeyDBSync', SyncHotKeyDBSync);
        INI.WriteString('HotKey', 'ExSearchHotKey', ExSearchHotKey);
        INI.WriteString('HotKey', 'ExSearchNextHotKey', ExSearchNextHotKey);
      finally
        INI.Free;
      end;
      // ������� HistoryToDBSync
      if Global_AutoRunHistoryToDBSync then
      begin
        if not CheckCurrentUserAutorun('HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')') then
        begin
          if FileExists(PluginPath+'HistoryToDBSync.exe') then
            AddCurrentUserAutorun('HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')', '"'+PluginPath+'HistoryToDBSync.exe" "'+PluginPath+'" "'+ProfilePath+'"');
        end;
      end
      else
      begin
        if CheckCurrentUserAutorun('HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')') then
          DeleteCurrentUserAutorun('HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')');
      end;
      // ���������� ����� ���������
      MainForm.LoadDBSettings;
      // ���������� ������ HistoryToDbSync ���������� ��������� �� ����� HistoryToDB.ini
      OnSendMessageToAllComponent('001');
    end
    else
      MsgDie(MainForm.Caption, GetLangStr('SettingsErrSave'));
    Close;
  end;
end;

{ ������������ ���������� � �� }
procedure TSettingsForm.TestConnectionButtonClick(Sender: TObject);
var
  DBVer: String;
  Query: TZQuery;
  ErrorCount: Integer;
  LocalTempDBVer, LocalTempProgramsVer: Integer;
  TempDBVer, TempProgramsVer: String;
  SQLClientType: String;
begin
  if DBParamCheck then
  begin
    ErrorCount := 0;
    DBParamSet;
    try
      MainForm.ZConnection1.Connect;
      if MainForm.ZConnection1.Connected then
      begin
        if MainForm.CheckServiceMode then
        begin
          MsgInf(MainForm.Caption, GetLangStr('ERR_DB_SERVICE_MODE'));
          MainForm.ZConnection1.Disconnect;
        end;
      end;
      if MainForm.ZConnection1.Connected then
      begin
        if IMClientType = 'ICQ' then
          SQLClientType := 'icq_version'
        else if IMClientType = 'QIP' then
          SQLClientType := 'qip_version'
        else if IMClientType = 'RnQ' then
          SQLClientType := 'rnq_version'
        else if IMClientType = 'Miranda' then
          SQLClientType := 'miranda_version'
        else
          SQLClientType := 'icq_version';
        Query := TZQuery.Create(nil);
        Query.Connection := MainForm.ZConnection1;
        try
          Query.SQL.Text := 'select config_value from config where config_name = '''+SQLClientType+'''';
          Query.Open;
          DBVer := Query.FieldByName('config_value').AsString;
          Query.Close;
          TempDBVer := DBVer+'.0.0';
          TempDBVer := StringReplace(TempDBVer, '.', '', [RFReplaceall]);
          if IsNumber(TempDBVer) then
            LocalTempDBVer := StrToInt(TempDBVer)
          else
            Inc(ErrorCount);
          TempProgramsVer := StringReplace(ProgramsVer, '.', '', [RFReplaceall]);
          if IsNumber(TempProgramsVer) then
            LocalTempProgramsVer := StrToInt(TempProgramsVer)
          else
            Inc(ErrorCount);
          if (LocalTempDBVer = LocalTempProgramsVer) and (ErrorCount = 0) then
          begin
            MsgInf(GetLangStr('InfoCaption'), GetLangStr('GoodDBConnect2') + #13
             + PWideChar(Format(GetLangStr('UpdateMessage5'), [ProgramsVer])) + #13
             + PWideChar(Format(GetLangStr('UpdateMessage6'), [DBVer+'.0.0'])));
          end
          else if (LocalTempDBVer < LocalTempProgramsVer) and (ErrorCount = 0) then
            MsgInf(GetLangStr('UpdateCaption'), GetLangStr('UpdateMessage1') + #13 + GetLangStr('UpdateMessage4') + #13 + GetLangStr('UpdateMessage3') + #13
             + PWideChar(Format(GetLangStr('UpdateMessage5'), [ProgramsVer])) + #13
             + PWideChar(Format(GetLangStr('UpdateMessage6'), [DBVer+'.0.0'])))
          else if (LocalTempDBVer > LocalTempProgramsVer) and (ErrorCount = 0) then
            MsgInf(GetLangStr('UpdateCaption'), GetLangStr('UpdateMessage1') + #13 + GetLangStr('UpdateMessage2') + #13 + GetLangStr('UpdateMessage3') + #13
             + PWideChar(Format(GetLangStr('UpdateMessage5'), [ProgramsVer])) + #13
             + PWideChar(Format(GetLangStr('UpdateMessage7'), [DBVer+'.0.0'])))
        except
          on e :
            Exception do
            begin
              MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrVersionCheck') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
              Query.Free;
              //ErrorCount := ErrorCount + 1;
            end
        end;
        MainForm.ZConnection1.Disconnect;
      end;
    except
      on e :
        Exception do
        begin
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          MainForm.ZConnection1.Disconnect;
          //ErrorCount := ErrorCount + 1;
        end
    end;
    MainForm.ZConnection1.Disconnect;
  end;
end;

{ �������� ����� ���������� }
procedure TSettingsForm.ButtonCreateEncryptionKeyClick(Sender: TObject);
begin
  KeyPassword.Text := '';
  EncryptionKey.Clear;
  KeyLength.Text := '15';
  SettingsPageControl.ActivePage := EncryptKeyCreateTabSheet;
end;

{ ��������� ����� ���������� � �������}
procedure TSettingsForm.ButtonCreateKeyClick(Sender: TObject);
var
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  RandomKey, FullKeyStr, FinalKey, TestFinalKey, EmptyKey: String;
  ReadActiveKeyNum, ReadCheckKey, ReadKeyNum, ReadKeyStatus: String;
  I, KeyNum, KeyCnt: Integer;
begin
  // ����� ����� ������� ��� ��������, � ����� HistoryToDB.ini, ��� � �� �������
  // �����! ����� ����� ������ ���� ��������!
  // ����� ����� ���� �������� �� ���������� ��������� �� ������ � �������.
  // ������ ���������� �������� �����:
  // ������ [EncryptKey] � ����� HistoryToDB.ini
  // �������� TotalKeyNum - ���. ������
  // �������� ActiveKeyNum - �������� ���� ��� ����������
  // ���� �����:
  // Key1=1|STATUS|3DES(1|ALGORITM|BASE64(KEY)|)
  // Key2=2|STATUS|3DES(2|ALGORITM|BASE64(KEY)|)
  // ...
  // KeyN=N|STATUS|3DES(N|ALGORITM|BASE64(KEY)|)
  //
  // �����! ��� ���������� ����� ���� ������ ���� �������� ����.
  // � ������ ���������� ��������� ����������� ���� STATUS, ���� ������ 1 �������� ����, ��
  // ������������� ��� ������, ��������� ������ �����, � ���� ��� �����, �� ��������� ���������.
  // ���� � ������ ���������� ��������� ������� ��������� �������� ������, �� ������������
  // ������� ���� �������, ��� ��������� ����� ���������� � ������ ����������.
  // ���� ����� ��������� � ������ ���������� �������, �������� � ������ �������������.
  // ��� ���� ����� ����������� ������������� ����� ���� �� �������� ��������.
  if KeyPassword.Text = '' then
  begin
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), GetLangStr('GetEncryptPassword'));
    Exit;
  end;
  // ������������� ������� ����������� SHA1
  Hash:= TDCP_sha1.Create(Self);
  Hash.Init;
  Hash.UpdateStr(KeyPassword.Text);
  Hash.Final(Digest);
  Hash.Free;
  // ������������� ������� ���������� 3DES
  Cipher := TDCP_3des.Create(Self);
  Cipher.Init(Digest, Sizeof(Digest)*8, nil);
  // End
  // ���������� ��������� ����
  RandomKey := RandomWord(False, StrToInt(KeyLength.Text));
  EncryptionKey.Lines.Text := Base64EncodeStr(RandomKey);
  // End
  if CBLocation.ItemIndex = 0 then // ��������
  begin
    // ������ ���. ������
    KeyNum := 0;
    KeyNum := StrToInt(ReadCustomINI(ProfilePath, 'EncryptKey', 'TotalKeyNum', '0'));
    if KeyNum > 0 then
    begin
      // �������� �� ����������
      ReadActiveKeyNum := ReadCustomINI(ProfilePath, 'EncryptKey', 'ActiveKeyNum', '0');
      for I := 1 to KeyNum do
      begin
        ReadCheckKey := ReadCustomINI(ProfilePath, 'EncryptKey', 'Key'+IntToStr(I), '');
        ReadKeyNum := Tok('|', ReadCheckKey);
        ReadKeyStatus := Tok('|', ReadCheckKey);
        if (ReadActiveKeyNum = ReadKeyNum) and (ReadKeyStatus = IntToStr(CBKeyStatus.ItemIndex)) then
        begin
          MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), GetLangStr('CheckActiveEncryptKey'));
          Cipher.Burn;
          Cipher.Free;
          SettingsPageControl.ActivePage := EncryptionTabSheet;
          Exit;
        end;
      end;
    end;
    KeyNum := 0;
    KeyNum := StrToInt(ReadCustomINI(ProfilePath, 'EncryptKey', 'TotalKeyNum', '0'));
    Inc(KeyNum);
    FullKeyStr := IntToStr(KeyNum) + '|' + IntToStr(CBEncryptionMethod.ItemIndex) + '|' + Base64EncodeStr(RandomKey) + '|';
    // ������� ���� ��������� ������� �� ��������� 3DES
    Cipher.Reset;
    FinalKey := Cipher.EncryptString(FullKeyStr);
    // ���������� � ���� HistoryToDB.ini
    WriteCustomINI(ProfilePath, 'EncryptKey', 'TotalKeyNum', IntToStr(KeyNum));
    if CBKeyStatus.ItemIndex = 1 then
    begin
      WriteCustomINI(ProfilePath, 'EncryptKey', 'ActiveKeyNum', IntToStr(KeyNum));
    end;
    WriteCustomINI(ProfilePath, 'EncryptKey', 'Key'+IntToStr(KeyNum), IntToStr(KeyNum) + '|' + IntToStr(CBKeyStatus.ItemIndex) + '|' + FinalKey);
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), FORMAT(GetLangStr('SaveEncryptKeyDone'), [IntToStr(KeyNum)]) + #13#10 + GetLangStr('SaveEncryptKeyDoneHelp'));
  end
  else if CBLocation.ItemIndex = 1 then // � ��
  begin
    if MainForm.ZConnection1.Connected then
      MainForm.ZConnection1.Disconnect;
    if SettingsForm.DBParamCheck then
    begin
      DBParamSet;
      try
        MainForm.ZConnection1.Connect;
        if MainForm.ZConnection1.Connected then
        begin
          if MainForm.CheckServiceMode then
          begin
            MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), GetLangStr('ERR_DB_SERVICE_MODE'));
            MainForm.ZConnection1.Disconnect;
          end;
        end;
        if MainForm.ZConnection1.Connected then
        begin
          MainForm.SQL_Zeos('select count(*) as cnt from key_'+ DBUserName + '');
          KeyCnt := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
          if KeyCnt > 0 then
          begin
            MainForm.SQL_Zeos('select status_key from key_'+ DBUserName + '');
            repeat
              if (MainForm.ViewerQuery.FieldByName('status_key').AsInteger = 1) and (CBKeyStatus.ItemIndex = 1) then
              begin
                MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), GetLangStr('CheckActiveEncryptKey'));
                MainForm.ZConnection1.Disconnect;
                Cipher.Burn;
                Cipher.Free;
                Exit;
              end;
              MainForm.ViewerQuery.Next;
            until MainForm.ViewerQuery.Eof;
          end;
          // ����� ������ ���� � �� ����� ������ ��� �����
          EmptyKey := 'NewKey' + IntToStr(Round((Now - 25569) * 86400));
          MainForm.SQL_Zeos_Exec('insert into key_'+ DBUserName + ' values (null, '''+IntToStr(CBKeyStatus.ItemIndex)+''', '''+IntToStr(CBEncryptionMethod.ItemIndex)+''', ''' + EmptyKey + ''')');
          // ������ ��� �����
          MainForm.SQL_Zeos('select id from key_'+ DBUserName + ' where encryption_key=''' + EmptyKey + '''');
          KeyNum := MainForm.ViewerQuery.FieldByName('id').AsInteger;
          // ��� ����
          FullKeyStr := IntToStr(KeyNum) + '|' + IntToStr(CBEncryptionMethod.ItemIndex) + '|' + Base64EncodeStr(RandomKey) + '|';
          // ������� ���� ��������� ������� �� ��������� 3DES
          Cipher.Reset;
          FinalKey := Cipher.EncryptString(FullKeyStr);
          // ��������� ������ �����
          MainForm.SQL_Zeos_Exec('update key_'+ DBUserName + ' set encryption_key=''' + FinalKey + ''' where id = ' + IntToStr(KeyNum) + '');
          if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
            MainForm.SQL_Zeos_Exec('commit;');
          // ��������� ������������ ������
          MainForm.SQL_Zeos('select encryption_key from key_'+ DBUserName + ' where id=' + IntToStr(KeyNum) +'');
          TestFinalKey := MainForm.ViewerQuery.FieldByName('encryption_key').AsString;
          if TestFinalKey = FinalKey then
            MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), FORMAT(GetLangStr('SaveDBEncryptKeyDone'), [IntToStr(KeyNum)]) + #13#10 + GetLangStr('SaveEncryptKeyDoneHelp'))
          else
          begin
            // ������ �����������, ������� ������
            MainForm.SQL_Zeos_Exec('delete from key_'+ DBUserName + ' where id=' + IntToStr(KeyNum) +'');
            if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
              MainForm.SQL_Zeos_Exec('commit;');
            MsgInf(MainForm.Caption + ' - ' + GetLangStr('EncryptKey'), GetLangStr('SaveEncryptKeyErr'))
          end;
          ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
          // End
        end;
      except
        on e :
          Exception do
          begin
            MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
            MainForm.ZConnection1.Disconnect;
            SettingsPageControl.ActivePage := EncryptionTabSheet;
            Exit;
          end
      end;
      MainForm.ZConnection1.Disconnect;
    end;
  end;
  Cipher.Burn;
  Cipher.Free;
  SettingsPageControl.ActivePage := EncryptionTabSheet;
end;

{ �������� ���� ���������� � ������� }
procedure TSettingsForm.ButtonGetEncryptionKeyClick(Sender: TObject);
begin
  VirtualTable1.Close;
  VirtualTable1.Clear;
  VirtualTable1.AfterScroll := nil;
  DBGridKeys.PopupMenu := nil;
  if MainForm.ZConnection1.Connected then
    MainForm.ZConnection1.Disconnect;
  if DBParamCheck then
  begin
    DBParamSet;
    try
      MainForm.ZConnection1.Connect;
      if MainForm.ZConnection1.Connected then
      begin
        if MainForm.CheckServiceMode then
        begin
          MsgInf(ProgramsName, GetLangStr('ERR_DB_SERVICE_MODE'));
          MainForm.ZConnection1.Disconnect;
        end;
      end;
      if MainForm.ZConnection1.Connected then
      begin
        VirtualTable1.Close;
        VirtualTable1.Clear;
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.Text := 'select id,status_key,'+
        ' case'+
        ' when (status_key = 1) then ''Active'''+
        ' else ''Inactive'''+
        ' end as status_key_text,'+
        ' encryption_method,'+
        ' case'+
        ' when (encryption_method = 0) then ''DES'''+
        ' when (encryption_method = 1) then ''3DES'''+
        ' when (encryption_method = 2) then ''SHA1'''+
        ' else ''�����������'''+
        ' end as encryption_method_text'+
        ' from key_'+ DBUserName + ' order by id';
        ZQuery1.Open;
        VirtualTable1.Assign(ZQuery1);
        ZQuery1.Close;
        VirtualTable1.Active := True;
        if not VirtualTable1.IsEmpty then
          DBGridKeys.PopupMenu := EncryptKeyPM;
        VirtualTable1.AfterScroll := VirtualTable1AfterScroll;
        VirtualTable1.BeforeScroll := VirtualTable1BeforeScroll;
      end;
    except
      on e :
        Exception do
        begin
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          MainForm.ZConnection1.Disconnect;
          Exit;
        end
    end;
    MainForm.ZConnection1.Disconnect;
  end;
end;

procedure TSettingsForm.VirtualTable1AfterScroll(DataSet: TDataSet);
begin
  EncryptKeyID := DataSet.FieldByName('id').AsString;
end;

procedure TSettingsForm.VirtualTable1BeforeScroll(DataSet: TDataSet);
begin
  EncryptKeyID := DataSet.FieldByName('id').AsString;
end;

{ ����� ������ ����� }
procedure TSettingsForm.PasswordChangeKeyClick(Sender: TObject);
begin
  ECurrentPassword.Text := '';
  ENewPassword.Text := '';
  EReNewPassword.Text := '';
  SettingsPageControl.ActivePage := KeyPasswordChangeTabSheet;
end;

{ ��������� c���� ������ ����� }
procedure TSettingsForm.ButtonNewKeyPasswordClick(Sender: TObject);
var
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  KeyCnt: Integer;
  DBKeyID, DBKeyEncryptionMethod, DBEncryptKey: String;
  FinalFullKey, FinalFullKeyTmp, FinalKeyID, FinalKeyEncryptionMethod, FinalKey, NewFinalFullKey: String;
begin
  if MainForm.ZConnection1.Connected then
    MainForm.ZConnection1.Disconnect;
  if SettingsForm.DBParamCheck then
  begin
    DBParamSet;
    try
      MainForm.ZConnection1.Connect;
      if MainForm.ZConnection1.Connected then
      begin
        if MainForm.CheckServiceMode then
        begin
          MsgInf(MainForm.Caption + ' - ' + GetLangStr('KeyPasswordChangeCaption'), GetLangStr('ERR_DB_SERVICE_MODE'));
          MainForm.ZConnection1.Disconnect;
        end;
      end;
      if MainForm.ZConnection1.Connected then
      begin
        MainForm.SQL_Zeos('select count(*) as cnt from key_'+ DBUserName + '');
        KeyCnt := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
        if KeyCnt > 0 then
        begin
          MainForm.SQL_Zeos('select id, encryption_method, encryption_key from key_'+ DBUserName + ' where id = ' + EncryptKeyID + '');
          DBEncryptKey := MainForm.ViewerQuery.FieldByName('encryption_key').AsString;
          DBKeyID := MainForm.ViewerQuery.FieldByName('id').AsString;
          DBKeyEncryptionMethod := MainForm.ViewerQuery.FieldByName('encryption_method').AsString;
          // ������������� ������� ����������� SHA1
          Hash:= TDCP_sha1.Create(Self);
          Hash.Init;
          Hash.UpdateStr(ECurrentPassword.Text);
          Hash.Final(Digest);
          Hash.Free;
          // ������������� ������� ���������� 3DES
          Cipher := TDCP_3des.Create(Self);
          Cipher.Init(Digest, Sizeof(Digest)*8, nil);
          // End
          // �������������� ���� ��������� ������� �� ��������� 3DES
          try
            Cipher.Reset;
            FinalFullKey := Cipher.DecryptString(DBEncryptKey);
            FinalFullKeyTmp := FinalFullKey;
            FinalKeyID :=  Tok('|', FinalFullKey);
            FinalKeyEncryptionMethod := Tok('|', FinalFullKey);
            FinalKey := Tok('|', FinalFullKey);
            if (DBKeyID <> FinalKeyID) and (DBKeyEncryptionMethod <> FinalKeyEncryptionMethod) then
            begin
              MsgInf(MainForm.Caption + ' - ' + GetLangStr('KeyPasswordChangeCaption'), GetLangStr('ErrKeyPasswordChange'));
              MainForm.ZConnection1.Disconnect;
              Cipher.Burn;
              Cipher.Free;
              Exit;
            end
            else
            begin
              // ������ ������
              if (ENewPassword.Text = EReNewPassword.Text) and (ENewPassword.Text <> '') and (EReNewPassword.Text <> '') then
              begin
                // �������
                Cipher.Burn;
                Cipher.Free;
                // ������������� ������� ����������� SHA1
                Hash:= TDCP_sha1.Create(Self);
                Hash.Init;
                Hash.UpdateStr(ENewPassword.Text);
                Hash.Final(Digest);
                Hash.Free;
                // ������������� ������� ���������� 3DES
                Cipher := TDCP_3des.Create(Self);
                Cipher.Init(Digest, Sizeof(Digest)*8, nil);
                // End
                // ������� ���� ��������� ����� ������� �� ��������� 3DES
                Cipher.Reset;
                NewFinalFullKey := Cipher.EncryptString(FinalFullKeyTmp);
                // ��������� ������ �����
                MainForm.SQL_Zeos_Exec('update key_'+ DBUserName + ' set encryption_key=''' + NewFinalFullKey + ''' where id = ' + EncryptKeyID + '');
                if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
                  MainForm.SQL_Zeos_Exec('commit;');
                MsgInf(MainForm.Caption + ' - ' + GetLangStr('KeyPasswordChangeCaption'), GetLangStr('KeyPasswordChanged'));
                Cipher.Burn;
                Cipher.Free;
                SettingsPageControl.ActivePage := EncryptionTabSheet;
              end
              else
              begin
                MsgInf(MainForm.Caption + ' - ' + GetLangStr('KeyPasswordChangeCaption'), GetLangStr('ErrKeyPasswordChangeNotRenew'));
                MainForm.ZConnection1.Disconnect;
                Cipher.Burn;
                Cipher.Free;
                Exit;
              end;
            end;
          except
            on e :
              Exception do
              begin
                ShowMessage('������ ����������� �����.');
              end;
          end;
        end;
      end;
    except
      on e :
        Exception do
        begin
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          MainForm.ZConnection1.Disconnect;
          Exit;
        end
    end;
    MainForm.ZConnection1.Disconnect;
  end;
end;

{ ����� ������� ����� }
procedure TSettingsForm.StatusChangeKeyClick(Sender: TObject);
var
  KeyCnt, StatusKey: Integer;
begin
  MainForm.ZConnection1.Disconnect;
  if SettingsForm.DBParamCheck then
  begin
    DBParamSet;
    try
      MainForm.ZConnection1.Connect;
      if (MainForm.ZConnection1.Connected) and (not MainForm.CheckServiceMode) then
      begin
        MainForm.SQL_Zeos('select count(*) as cnt from key_'+ DBUserName + '');
        KeyCnt := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
        if KeyCnt > 0 then
        begin
          MainForm.SQL_Zeos('select status_key from key_'+ DBUserName + ' where id = ' + EncryptKeyID + '');
          StatusKey := MainForm.ViewerQuery.FieldByName('status_key').AsInteger;
          if StatusKey = 0 then
          begin
            MainForm.SQL_Zeos('select count(*) as cnt from key_'+ DBUserName + ' where status_key = ''1''');
            if MainForm.ViewerQuery.FieldByName('cnt').AsInteger >= 1 then
            begin
                MsgInf(MainForm.Caption, GetLangStr('CheckNumActiveEncryptKey'));
                MainForm.ZConnection1.Disconnect;
                Exit;
            end
            else
            begin
              // ��������� ������ �����
              MainForm.SQL_Zeos_Exec('update key_'+ DBUserName + ' set status_key=''1'' where id = ' + EncryptKeyID + '');
              if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
                MainForm.SQL_Zeos_Exec('commit;');
              MsgInf(MainForm.Caption, GetLangStr('EncryptKeyStatusChanged'))
            end;
          end
          else
          begin
            // ��������� ������ �����
            MainForm.SQL_Zeos_Exec('update key_'+ DBUserName + ' set status_key=''0'' where id = ' + EncryptKeyID + '');
            if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
              MainForm.SQL_Zeos_Exec('commit;');
            MsgInf(MainForm.Caption, GetLangStr('EncryptKeyStatusChanged'))
          end;
        end;
      end;
    except
      on e :
        Exception do
        begin
          MsgInf(MainForm.Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          MainForm.ZConnection1.Disconnect;
          Exit;
        end
    end;
    MainForm.ZConnection1.Disconnect;
    ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
  end;
end;

{ �������� ����� }
procedure TSettingsForm.DeleteKeyClick(Sender: TObject);
var
  KeyCnt, StatusKey, MsgKeyFound, ChatMsgKeyFound: Integer;
begin
  MainForm.ZConnection1.Disconnect;
  if SettingsForm.DBParamCheck then
  begin
    DBParamSet;
    try
      MainForm.ZConnection1.Connect;
      if (MainForm.ZConnection1.Connected) and (not MainForm.CheckServiceMode) then
      begin
        MainForm.SQL_Zeos('select count(*) as cnt from key_'+ DBUserName + '');
        KeyCnt := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
        if KeyCnt > 0 then
        begin
          MainForm.SQL_Zeos('select status_key from key_'+ DBUserName + ' where id = ' + EncryptKeyID + '');
          StatusKey := MainForm.ViewerQuery.FieldByName('status_key').AsInteger;
          if StatusKey = 1 then
            MsgInf(MainForm.Caption + ' - ' + GetLangStr('DeleteEncryptKeyCaption'), GetLangStr('DeleteActiveEncryptKey'));
          // ��������� ���� �� ���-�� ����������� ���� ������
          MainForm.SQL_Zeos('select count(*) as cnt from uin_'+ DBUserName + ' where key_id = ' + EncryptKeyID + '');
          MsgKeyFound := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
          MainForm.SQL_Zeos('select count(*) as cnt from uin_chat_'+ DBUserName + ' where key_id = ' + EncryptKeyID + '');
          ChatMsgKeyFound := MainForm.ViewerQuery.FieldByName('cnt').AsInteger;
          if (MsgKeyFound > 0) or (ChatMsgKeyFound > 0) then
          begin
            // ������� ��������������
            case MessageBox(Handle,PWideChar(GetLangStr('DeleteEncryptKey')),PWideChar(MainForm.Caption + ' - ' + GetLangStr('DeleteEncryptKeyCaption')),36) of
            6:
            begin
              // ������� ����
              MainForm.SQL_Zeos_Exec('delete from key_'+ DBUserName + ' where id = ' + EncryptKeyID + '');
              if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
                MainForm.SQL_Zeos_Exec('commit;');
              MsgInf(MainForm.Caption + ' - ' + GetLangStr('DeleteEncryptKeyCaption'), GetLangStr('EncryptKeyDeleted'))
            end;
            7:
            begin
              MainForm.ZConnection1.Disconnect;
              Exit;
            end;
          end;
          end
          else
          begin
            // ������� ����
            MainForm.SQL_Zeos_Exec('delete from key_'+ DBUserName + ' where id = ' + EncryptKeyID + '');
            if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
              MainForm.SQL_Zeos_Exec('commit;');
            MsgInf(MainForm.Caption, GetLangStr('EncryptKeyDeleted'))
          end;
        end;
      end;
    except
      on e :
        Exception do
        begin
          MsgInf(MainForm.Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          MainForm.ZConnection1.Disconnect;
          Exit;
        end
    end;
    MainForm.ZConnection1.Disconnect;
    ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
  end;
end;

procedure TSettingsForm.CBEnableEncryptionClick(Sender: TObject);
begin
  if CBEnableEncryption.Checked then
  begin
    GBKeys.Visible := True;
    ButtonGetEncryptionKeyClick(ButtonGetEncryptionKey);
  end
  else
  begin
    GBKeys.Visible := False;
    VirtualTable1.Close;
    VirtualTable1.Clear;
    VirtualTable1.AfterScroll := nil;
    DBGridKeys.PopupMenu := nil;
  end;
end;

procedure TSettingsForm.CBHideSyncIconClick(Sender: TObject);
begin
  if CBHideSyncIcon.Checked then
    HideSyncIcon := true
  else
    HideSyncIcon := false;
end;

procedure TSettingsForm.CBHotKeyClick(Sender: TObject);
begin
  if CBHotKey.Checked then
  begin
    GBHotKey.Visible := True;
    GlobalHotKeyEnable := True;
  end
  else
  begin
    GBHotKey.Visible := False;
    GlobalHotKeyEnable := False;
  end;
end;

procedure TSettingsForm.CBLangChange(Sender: TObject);
begin
  MainForm.IMCoreLanguage := CBLang.Items[CBLang.ItemIndex];
  DefaultLanguage := CBLang.Items[CBLang.ItemIndex];
  MainForm.CoreLanguageChanged;
  MainForm.JvTreeViewMake;
end;

procedure TSettingsForm.SetHotKeyButtonClick(Sender: TObject);
var
  S: String;
  I: Integer;
begin
  S := ShortCutToText(IMHotKey.HotKey);
  for I := 1 to HotKetStringGrid.RowCount - 1 do
  begin
    if HotKetStringGrid.Cells[1,I] = S then
    begin
      MsgInf(MainForm.Caption, 'Hot key already assigned!');
      Exit;
    end;
  end;
  HotKetStringGrid.Cells[1,HotKeySelectedCell] := S;
  SyncHotKey := HotKetStringGrid.Cells[1,1];
  SyncHotKeyDBSync := HotKetStringGrid.Cells[1,2];
  ExSearchHotKey := HotKetStringGrid.Cells[1,3];
  ExSearchNextHotKey := HotKetStringGrid.Cells[1,4];
end;

procedure TSettingsForm.DeleteHotKeyButtonClick(Sender: TObject);
begin
  HotKetStringGrid.Cells[1,HotKeySelectedCell] := '';
  IMHotKey.HotKey := TextToShortCut('');
  SyncHotKeyDBSync := HotKetStringGrid.Cells[1,2];
  ExSearchHotKey := HotKetStringGrid.Cells[1,3];
  ExSearchNextHotKey := HotKetStringGrid.Cells[1,4];
end;

procedure TSettingsForm.HotKetStringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  HotKeySelectedCell := ARow;
  IMHotKey.HotKey := TextToShortCut(HotKetStringGrid.Cells[1,ARow]);
end;

procedure TSettingsForm.CBAlphaBlendClick(Sender: TObject);
begin
  AlphaBlendEnable := CBAlphaBlend.Checked;
  // ���. ������������ ���� ��������
  AlphaBlend := AlphaBlendEnable;
  if not ShowSettingsFormOnStart then
    MainForm.AlphaBlend := AlphaBlendEnable;
  if AlphaBlendEnable then
  begin
    AlphaBlendTrackBar.Visible := True;
    AlphaBlendVar.Visible := True;
    AlphaBlendTrackBar.Position := AlphaBlendEnableValue;
    AlphaBlendVar.Caption := IntToStr(AlphaBlendEnableValue);
  end
  else
  begin
    AlphaBlendTrackBar.Visible := False;
    AlphaBlendVar.Visible := False;
  end;
end;

procedure TSettingsForm.AlphaBlendTrackBarChange(Sender: TObject);
begin
  AlphaBlendEnableValue := AlphaBlendTrackBar.Position;
  // ������������ ���� ��������
  AlphaBlendValue := AlphaBlendEnableValue;
  if not ShowSettingsFormOnStart then
    MainForm.AlphaBlendValue := AlphaBlendEnableValue;
  AlphaBlendVar.Caption := IntToStr(AlphaBlendEnableValue);
end;

procedure TSettingsForm.CBAniClick(Sender: TObject);
begin
  if CBAni.Checked then
    AniEvents := True
  else
    AniEvents := False;
end;

procedure TSettingsForm.CBWriteErrLogClick(Sender: TObject);
begin
  if CBWriteErrLog.Checked then
    WriteErrLog := True
  else
    WriteErrLog := False;
end;

procedure TSettingsForm.CBDBTypeChange(Sender: TObject);
begin
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := true;
    EDBAddress.Text := DBAddress;
    EDBPort.Text := '3306';
    EDBName.Text := DBName;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := true;
    EDBAddress.Text := DBAddress;
    EDBPort.Text := '5432';
    EDBName.Text := DBName;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := False;
    LDBAddress.Caption := GetLangStr('LDBSchema');
    LDBName.Caption := GetLangStr('LDBNameOracle');
    EDBAddress.Text := DBSchema;
    EDBPort.Text := '0000';
    EDBPasswd.Enabled := True;
    EDBName.Text := DBName;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
  begin
    EDBAddress.Enabled := False;
    EDBPort.Enabled := False;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := False;
    EDBName.Text := '<ProfilePluginPath>\imhistory.sqlite';
    EDBAddress.Text := '0.0.0.0';
    EDBPort.Text := '0000';
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := True;
    EDBAddress.Text := DBAddress;
    EDBPort.Text := '3050';
    EDBName.Text := DBName;
  end
  else
    begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := True;
    EDBAddress.Text := DBAddress;
    EDBPort.Text := '0000';
    EDBName.Text := DBName;
  end
end;

procedure TSettingsForm.CBSyncMethodChange(Sender: TObject);
begin
  if CBSyncMethod.ItemIndex = 1 then // �������
  begin
    CBSyncInterval.Enabled := false;
    CBSyncInterval.ItemIndex := -1;
    LSyncInterval.Enabled := False;
    ETimeInterval.Enabled := False;
    EMsgCountInterval.Enabled := False;
    CBSyncWhenExit.Enabled := False;
    CBSyncWhenExit.Checked := False;
  end
  else if CBSyncMethod.ItemIndex = 2 then // �� ����������
  begin
    CBSyncInterval.Enabled := True;
    CBSyncInterval.ItemIndex := 0;
    LSyncInterval.Enabled := True;
    CBSyncWhenExit.Enabled := True;
    CBSyncWhenExit.Checked := SyncWhenExit;
  end
  else
  begin // ����
    CBSyncInterval.Enabled := False;
    CBSyncInterval.ItemIndex := -1;
    LSyncInterval.Enabled := False;
    ETimeInterval.Enabled := False;
    EMsgCountInterval.Enabled := False;
    CBSyncWhenExit.Enabled := False;
    CBSyncWhenExit.Checked := False;
  end;
end;

procedure TSettingsForm.CBSaveClick(Sender: TObject);
begin
  if CBSave.Checked then
  begin
    CBSaveOnly.Enabled := False;
    CBSaveOnly.Checked := False;
  end
  else
  begin
    CBSaveOnly.Enabled := True;
    CBSaveOnly.Checked := KeyPasswdSaveOnlySession;
  end;
end;

procedure TSettingsForm.CBSkypeSupportEnableClick(Sender: TObject);
begin
  if CBSkypeSupportEnable.Checked then
  begin
    CBAutoStartup.Enabled := True;
    CBAutoStartup.Checked := Global_AutoRunHistoryToDBSync;
    CBRunSkype.Enabled := True;
    CBRunSkype.Checked := Global_RunningSkypeOnStartup;
    CBExitSkype.Enabled := True;
    CBExitSkype.Checked := Global_ExitSkypeOnEnd;
  end
  else
  begin
    CBAutoStartup.Checked := False;
    CBAutoStartup.Enabled := False;
    CBRunSkype.Checked := False;
    CBRunSkype.Enabled := False;
    CBExitSkype.Checked := False;
    CBExitSkype.Enabled := False;
  end;
end;

procedure TSettingsForm.CBSyncIntervalChange(Sender: TObject);
begin
  if (CBSyncInterval.ItemIndex = 4) or (CBSyncInterval.ItemIndex = -1) then
  begin
    CBSyncWhenExit.Enabled := False;
    CBSyncWhenExit.Checked := False;
  end
  else if CBSyncInterval.ItemIndex = 8 then
  begin
    GBSyncCustomInterval.Enabled := True;
    LTimeInterval.Enabled := True;
    ETimeInterval.Enabled := True;
    LMsgCountInterval.Enabled := False;
    EMsgCountInterval.Enabled := False;
    CBSyncWhenExit.Enabled := True;
    CBSyncWhenExit.Checked := SyncWhenExit;
  end
  else if CBSyncInterval.ItemIndex = 9 then
  begin
    GBSyncCustomInterval.Enabled := True;
    LTimeInterval.Enabled := False;
    ETimeInterval.Enabled := False;
    LMsgCountInterval.Enabled := True;
    EMsgCountInterval.Enabled := True;
    CBSyncWhenExit.Enabled := True;
    CBSyncWhenExit.Checked := SyncWhenExit;
  end
  else
  begin
    GBSyncCustomInterval.Enabled := False;
    LTimeInterval.Enabled := False;
    ETimeInterval.Enabled := False;
    LMsgCountInterval.Enabled := False;
    EMsgCountInterval.Enabled := False;
    CBSyncWhenExit.Enabled := True;
    CBSyncWhenExit.Checked := SyncWhenExit;
  end;
end;

procedure TSettingsForm.CloseButtonClick(Sender: TObject);
begin
  VirtualTable1.Close;
  VirtualTable1.Clear;
  Close;
end;

function TSettingsForm.DBParamCheck: Boolean;
var
  ErrorsCount: Integer;
  ErrorsMsg: WideString;
begin
  ErrorsCount := 0;
  ErrorsMsg := '';
  if not MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*') then
  begin
    if EDBAddress.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      if MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*') then
        ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck6') + #10#13
      else
        ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck1') + #10#13;
    end;
    if EDBPort.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck2') + #10#13;
    end;
    if EDBPasswd.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck3') + #10#13;
    end;
  end;
  if EDBUserName.Text = ''  then
  begin
    ErrorsCount := ErrorsCount + 1;
    ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck4') + #10#13;
  end;
  if EDBName.Text = '' then
  begin
    ErrorsCount := ErrorsCount + 1;
    if MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*') then
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck7') + #10#13
    else
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck5') + #10#13;
  end;
  if ErrorsCount = 0 then
    Result := true
  else
    begin
      MsgDie(GetLangStr('ErrCaption'), ErrorsMsg);
      Result := false;
    end;
end;

procedure TSettingsForm.LabelAuthorClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'mailto:sleuthhound@gmail.com', nil, nil, SW_RESTORE);
end;

procedure TSettingsForm.LabelWebSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.im-history.ru', nil, nil, SW_RESTORE);
end;

procedure TSettingsForm.DBParamSet;
begin
  MainForm.ZConnection1.Protocol := CBDBType.Items[CBDBType.ItemIndex];
  if (CBDBType.Items[CBDBType.ItemIndex] = 'sqlite') or
    (CBDBType.Items[CBDBType.ItemIndex] = 'sqlite-3') then
  begin
    MainForm.ZConnection1.HostName := '';
    MainForm.ZConnection1.Port := 0;
    MainForm.ZConnection1.User := '';
    MainForm.ZConnection1.Password := '';
  end
  else if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
    (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
  begin
    DBSchema := EDBAddress.Text;
  end
  else // MySQL and PostgreSQL
  begin
    MainForm.ZConnection1.HostName := EDBAddress.Text;
    MainForm.ZConnection1.Port := StrToInt(EDBPort.Text);
    MainForm.ZConnection1.User := EDBUserName.Text;
    MainForm.ZConnection1.Password := EDBPasswd.Text;
  end;
  DBUserName := EDBUserName.Text;
  // ������ ��������� � ������ DBName
  if MatchStrings(EDBName.Text,'<ProfilePluginPath>*') then
    DBName := StringReplace(EDBName.Text,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
  else if MatchStrings(EDBName.Text,'<PluginPath>*') then
    DBName := StringReplace(EDBName.Text,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall])
  else
    DBName := EDBName.Text;
  // End
  MainForm.ZConnection1.Database := DBName;
  MainForm.ZConnection1.LoginPrompt := false;
end;

{ ����������� ������� WM_MSGBOX ��� ��������� ������������ ���� }
procedure TSettingsForm.msgBoxShow(var Msg: TMessage);
var
  msgbHandle: HWND;
begin
  msgbHandle := GetActiveWindow;
  if msgbHandle <> 0 then
    MakeTransp(msgbHandle);
end;

// ����-��� ��� ������� ��������� � Memo :-D
procedure TSettingsForm.MemoThankYou2Enter(Sender: TObject);
begin
  CloseButton.SetFocus;
end;

{ ��������� ������ �������� ������ � ���������� ������ }
procedure TSettingsForm.FindLangFile;
var
  SR: TSearchRec;
  I: Integer;
begin
  CBLang.Items.Clear;
  if FindFirst(PluginPath + dirLangs + '\*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // ����� �� ���� ������ . � ..
      begin
        Continue; // ���������� ����
      end;
      if MatchStrings(SR.Name, '*.xml') then
      begin
        // ��������� ����
        CBLang.Items.Add(ExtractFileNameEx(SR.Name, False));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  for I := 0 to CBLang.Items.Count-1 do
  begin
    if CBLang.Items[I] = MainForm.IMCoreLanguage then
      CBLang.ItemIndex := I;
  end;
end;

{ ����� ����� ���������� �� ������� WM_LANGUAGECHANGED }
procedure TSettingsForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ ��� �������������� ��������� }
procedure TSettingsForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType + ' - ' + GetLangStr('Settings')
  else
    Caption := ProgramsName + ' - ' + GetLangStr('Settings');
  // �������������
  LThankYou.Caption := GetLangStr('LThankYou');
  if MainForm.IMCoreLanguage = 'Russian' then
    ThankYou.Caption := ThankYouText_Rus
  else
    ThankYou.Caption := ThankYouText_Eng;
  // End
  SettingtButtonGroup.Items[0].Caption := GetLangStr('SettingsPageControlMainTab');
  SettingtButtonGroup.Items[1].Caption := GetLangStr('SettingsPageControlSyncTab');
  SettingtButtonGroup.Items[2].Caption := GetLangStr('SettingsPageControlInterfaceTab');
  SettingtButtonGroup.Items[3].Caption := GetLangStr('SettingsPageControlEventsTab');
  SettingtButtonGroup.Items[4].Caption := GetLangStr('SettingsPageControlFontsTab');
  SettingtButtonGroup.Items[5].Caption := GetLangStr('SettingsPageControlHotKeyTab');
  SettingtButtonGroup.Items[6].Caption := GetLangStr('SettingsPageControlEncryptionTab');
  SettingtButtonGroup.Items[7].Caption := GetLangStr('SettingsPageControlAboutTab');
  CBConnectMethod.Clear;
  CBConnectMethod.Items.Add(GetLangStr('CBDBConnectMethodDirect'));
  CBConnectMethod.ItemIndex := 0;
  CBSyncMethod.Clear;
  CBSyncMethod.Items.Add(GetLangStr('CBSyncMethodAuto'));
  CBSyncMethod.Items.Add(GetLangStr('CBSyncMethodManual'));
  CBSyncMethod.Items.Add(GetLangStr('CBSyncMethodOnSchedule'));
  CBSyncMethod.ItemIndex := SyncMethod;
  CBSyncInterval.Clear;
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval5Min'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval10Min'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval20Min'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval30Min'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncIntervalExitProgram'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval10Mes'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval20Mes'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncInterval30Mes'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncIntervalNMin'));
  CBSyncInterval.Items.Add(GetLangStr('CBSyncIntervalNMes'));
  if SyncMethod = 2 then
  begin
    CBSyncInterval.ItemIndex := SyncInterval;
    CBSyncInterval.Enabled := true;
    LSyncInterval.Enabled := true;
  end
  else
  begin
    SyncInterval := -1;
    CBSyncInterval.Enabled := false;
    LSyncInterval.Enabled := false;
  end;
  CBSyncWhenExit.Caption := GetLangStr('SyncWhenExit');
  GBAddon.Caption := GetLangStr('Additionally');
  DBGroupBox.Caption := GetLangStr('DBGroupBox');
  SyncGroupBox.Caption := GetLangStr('SyncGroupBox');
  EventsGroupBox.Caption := GetLangStr('EventsGroupBox');
  LDBConnectMethod.Caption := GetLangStr('LDBConnectMethod');
  LDBType.Caption := GetLangStr('LDBType');
  LDBPort.Caption := GetLangStr('LDBPort');
  if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
      (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
  begin
    LDBAddress.Caption := GetLangStr('LDBSchema');
    LDBName.Caption := GetLangStr('LDBNameOracle');
  end
  else
  begin
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
  end;
  LDBLogin.Caption := GetLangStr('LDBLogin');
  LDBPasswd.Caption := GetLangStr('LDBPasswd');
  TestConnectionButton.Caption := GetLangStr('TestConnectionButton');
  LSyncMethod.Caption := GetLangStr('LSyncMethod');
  LSyncInterval.Caption := GetLangStr('LSyncInterval');
  CBEnableEncryption.Caption := GetLangStr('CBEnableEncryption');
  CBAni.Caption := GetLangStr('CBAni');
  CBWriteErrLog.Caption := GetLangStr('CBWriteErrLog');
  CBWriteDebugLog.Caption := GetLangStr('CBWriteDebugLog');
  CBHideSyncIcon.Caption := GetLangStr('CBHideSyncIcon');
  LNumLastHistoryMsg.Caption := GetLangStr('LNumLastHistoryMsg');
  GBSyncCustomInterval.Caption := GetLangStr('GBSyncCustomInterval');
  LTimeInterval.Caption := GetLangStr('LTimeInterval');
  LMsgCountInterval.Caption := GetLangStr('LMsgCountInterval');
  CBShowPluginButton.Caption := GetLangStr('CBShowPluginButton');
  SaveButton.Caption := GetLangStr('SaveButton');
  CloseButton.Caption := GetLangStr('CloseButton');
  GBKeys.Caption := GetLangStr('GBKeys');
  ButtonGetEncryptionKey.Caption := GetLangStr('ButtonGetEncryptionKey');
  ButtonCreateEncryptionKey.Caption := GetLangStr('ButtonCreateEncryptionKey');
  DBGridKeys.Columns[0].Title.Caption := GetLangStr('DBGridKeysColumnID');
  DBGridKeys.Columns[1].Title.Caption := GetLangStr('DBGridKeysColumnSTATUS');
  DBGridKeys.Columns[2].Title.Caption := GetLangStr('DBGridKeysColumnMETHOD');
  // ��������� ������ � ���� "� �������"
  LVersion.Caption := GetLangStr('Version');
  LLicense.Caption := GetLangStr('License');
  LProgramName.Caption := ProgramsName;
  LVersionNum.Caption := ProgramsVer;
  // ������������� ������
  LProgramName.Left := AboutImage.Left + AboutImage.Width + 20;
  LabelCopyright.Left := AboutImage.Left + AboutImage.Width + 20;
  LVersion.Left := AboutImage.Left + AboutImage.Width + 20;
  LLicense.Left := AboutImage.Left + AboutImage.Width + 20;
  LabelWeb.Left := AboutImage.Left + AboutImage.Width + 20;
  LabelAuthor.Left := LabelCopyright.Left + LabelCopyright.Width + 2;
  LVersionNum.Left := LVersion.Left + 1 + LVersion.Width;
  LLicenseType.Left := LLicense.Left + 1 + LLicense.Width;
  LabelWebSite.Left := LabelWeb.Left + LabelWeb.Width + 1;
  LThankYou.Left := AboutImage.Left + AboutImage.Width + 20;
  ThankYou.Left := AboutImage.Left + AboutImage.Width + 20;
  // End
  CBAddSpecialContact.Caption := GetLangStr('CBAddSpecialContact');
  GBMessageFonts.Caption := GetLangStr('GBMessageFonts');
  TitleSpacingBox.Caption := GetLangStr('TitleSpacingBox');
  MessagesSpacingBox.Caption := GetLangStr('MessagesSpacingBox');
  LIncommingMesTitle.Caption := GetLangStr('LIncommingMesTitle');
  LOutgoingMesTitle.Caption := GetLangStr('LOutgoingMesTitle');
  LIncommingMes.Caption := GetLangStr('LIncommingMes');
  LOutgoingMes.Caption := GetLangStr('LOutgoingMes');
  LServiceMes.Caption := GetLangStr('LServiceMes');
  LTitleSpacingBefore.Caption := GetLangStr('LSpacingBefore');
  LTitleSpacingAfter.Caption := GetLangStr('LSpacingAfter');
  LMessagesSpacingBefore.Caption := GetLangStr('LSpacingBefore');
  LMessagesSpacingAfter.Caption := GetLangStr('LSpacingAfter');
  GBHotKey.Caption := GetLangStr('GBHotKey');
  CBHotKey.Caption := GetLangStr('CBHotKey');
  SetHotKeyButton.Caption := GetLangStr('SetHotKeyButton');
  DeleteHotKeyButton.Caption := GetLangStr('DeleteHotKeyButton');
  HotKetStringGrid.Cells[0,1] := GetLangStr('SyncButton') + ' (' + ProgramsName + ')';
  HotKetStringGrid.Cells[0,2] := GetLangStr('SyncButton') + ' (HistoryToDBSync)';
  HotKetStringGrid.Cells[0,3] := GetLangStr('ExSearch');
  HotKetStringGrid.Cells[0,4] := GetLangStr('ExSearchNext');
  FontColorInTitle.Properties.CustomColorCaption := GetLangStr('FontCustomColorCaption');
  FontColorInTitle.Properties.CustomColorHint := GetLangStr('FontCustomColorCaption');
  FontColorInTitle.Properties.DefaultColorCaption := GetLangStr('FontDefaultColorCaption');
  FontColorInTitle.Properties.DefaultColorHint := GetLangStr('FontDefaultColorCaption');
  FontColorOutTitle.Properties.CustomColorCaption := GetLangStr('FontCustomColorCaption');
  FontColorOutTitle.Properties.CustomColorHint := GetLangStr('FontCustomColorCaption');
  FontColorOutTitle.Properties.DefaultColorCaption := GetLangStr('FontDefaultColorCaption');
  FontColorOutTitle.Properties.DefaultColorHint := GetLangStr('FontDefaultColorCaption');
  FontColorInBody.Properties.CustomColorCaption := GetLangStr('FontCustomColorCaption');
  FontColorInBody.Properties.CustomColorHint := GetLangStr('FontCustomColorCaption');
  FontColorInBody.Properties.DefaultColorCaption := GetLangStr('FontDefaultColorCaption');
  FontColorInBody.Properties.DefaultColorHint := GetLangStr('FontDefaultColorCaption');
  FontColorOutBody.Properties.CustomColorCaption := GetLangStr('FontCustomColorCaption');
  FontColorOutBody.Properties.CustomColorHint := GetLangStr('FontCustomColorCaption');
  FontColorOutBody.Properties.DefaultColorCaption := GetLangStr('FontDefaultColorCaption');
  FontColorOutBody.Properties.DefaultColorHint := GetLangStr('FontDefaultColorCaption');
  FontColorService.Properties.CustomColorCaption := GetLangStr('FontCustomColorCaption');
  FontColorService.Properties.CustomColorHint := GetLangStr('FontCustomColorCaption');
  FontColorService.Properties.DefaultColorCaption := GetLangStr('FontDefaultColorCaption');
  FontColorService.Properties.DefaultColorHint := GetLangStr('FontDefaultColorCaption');
  GBKeyProp.Caption := GetLangStr('GBKeyProp');
  CBKeyStatus.Clear;
  CBLocation.Clear;
  CBKeyStatus.Items.Add(GetLangStr('KeyStatusInactive'));
  CBKeyStatus.Items.Add(GetLangStr('KeyStatusActive'));
  CBLocation.Items.Add(GetLangStr('KeyLocationLocal'));
  CBLocation.Items.Add(GetLangStr('KeyLocationServer'));
  CBKeyStatus.ItemIndex := 1;
  CBLocation.ItemIndex := 1;
  CBEncryptionMethod.ItemIndex := 1;
  LKeyStatusTitle.Caption := GetLangStr('LKeyStatusTitle');
  LCBEncryptionMethod.Caption := GetLangStr('LCBEncryptionMethod');
  LKeyLength.Caption := GetLangStr('LKeyLength');
  LKeyPassword.Caption := GetLangStr('LKeyPassword');
  LEncryptionKey.Caption := GetLangStr('LEncryptionKey');
  LEncryptionKeyDesc.Caption := GetLangStr('LEncryptionKeyDesc');
  LLocation.Caption := GetLangStr('LLocation');
  ButtonCreateKey.Caption := GetLangStr('ButtonCreateKey');
  EncryptKeyPM.Items[0].Caption := GetLangStr('StatusChangeKey');
  EncryptKeyPM.Items[1].Caption := GetLangStr('PasswordChangeKey');
  EncryptKeyPM.Items[2].Caption := GetLangStr('DeleteKey');
  GBKeyPasswordChange.Caption := GetLangStr('GBKeyPasswordChange');
  LCurrentPassword.Caption := GetLangStr('LCurrentPassword');
  LNewPassword.Caption := GetLangStr('LNewPassword');
  LReNewPassword.Caption := GetLangStr('LReNewPassword');
  ButtonNewKeyPassword.Caption := GetLangStr('ButtonNewKeyPassword');
  CBSaveOnly.Caption := GetLangStr('HistoryToDBSyncCBSaveOnly');
  CBSave.Caption := GetLangStr('HistoryToDBSyncCBSave');
  LErrLogSize.Caption := GetLangStr('LErrLogSize');
  CBBlockSpamMsg.Caption := GetLangStr('CBBlockSpamMsg');
  CBSkypeSupportEnable.Caption := GetLangStr('EnableSkypeSupport');
  GBAlphaBlend.Caption := GetLangStr('Transparency');
  CBAlphaBlend.Caption := GetLangStr('TransparencyEnable');
  CBExPrivateChatName.Caption := GetLangStr('CBExPrivateChatName');
  GBLang.Caption := ' ' + GetLangStr('LangButton') + ' ';
  CBAutoScroll.Caption := GetLangStr('AutoScrollText');
  LDBReconnectCount.Caption := GetLangStr('DBReconnectCount');
  LDBReconnectInterval.Caption := GetLangStr('DBReconnectInterval');
  CBAutoStartup.Caption := GetLangStr('AutoRunHistoryToDBSync');
  CBRunSkype.Caption := GetLangStr('RunningSkypeOnStartup');
  CBExitSkype.Caption := GetLangStr('ExitSkypeOnEnd');
  ERR_SAVE_TO_DB_CONNECT_ERR := GetLangStr('ERR_SAVE_TO_DB_CONNECT_ERR');
  ERR_SAVE_TO_DB_SERVICE_MODE := GetLangStr('ERR_SAVE_TO_DB_SERVICE_MODE');
  ERR_TEMP_SAVE_TO_DB_SERVICE_MODE := GetLangStr('ERR_TEMP_SAVE_TO_DB_SERVICE_MODE');
  ERR_READ_DB_CONNECT_ERR := GetLangStr('ERR_READ_DB_CONNECT_ERR');
  ERR_READ_DB_SERVICE_MODE := GetLangStr('ERR_READ_DB_SERVICE_MODE');
  ERR_LOAD_MSG_TO_DB := GetLangStr('ERR_LOAD_MSG_TO_DB');
  ERR_SEND_UPDATE := GetLangStr('ERR_SEND_UPDATE');
  LOAD_TEMP_MSG := GetLangStr('LOAD_TEMP_MSG');
  LOAD_TEMP_MSG_NOLOGFILE := GetLangStr('LOAD_TEMP_MSG_NOLOGFILE');
end;

end.
