{ ############################################################################ }
{ #                                                                          # }
{ #  IM-History for Android v1.0                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

{$DEFINE DEMOACCESS}

unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  System.Actions, FMX.ActnList, FMX.StdCtrls, FMX.Edit, Global, FMX.Objects,
  UniProvider, Data.DB, DBAccess, Uni, FGX.ProgressDialog, MySQLUniProvider,
  FMX.Layouts, FMX.ExtCtrls, System.IOUtils, FMX.Gestures, FMX.Platform,
  FMX.ListView.Types, FMX.ListView, FMX.ListBox, FMX.Media, FMX.LinkBtn
  {$IFDEF ANDROID},FMX.Platform.Android, Android.Net{$ENDIF}
  {$IFDEF iOS},FMX.Platform.iOS{$ENDIF};

type
  TMainForm = class(TForm)
    TabControl: TTabControl;
    TabItemLogin: TTabItem;
    TabItemList: TTabItem;
    TabItemSettings: TTabItem;
    TabItemHistory: TTabItem;
    TopToolBarLogin: TToolBar;
    ToolBarLabelLogin: TLabel;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    BottomToolBar: TToolBar;
    ELogin: TEdit;
    LLogin: TLabel;
    EPassword: TEdit;
    BEnter: TButton;
    CBSavePassword: TCheckBox;
    TopToolBarList: TToolBar;
    ToolBarLabel2: TLabel;
    ChangeTabAction3: TChangeTabAction;
    UniConnection1: TUniConnection;
    fgActivityDialog: TfgActivityDialog;
    MySQLUniProvider1: TMySQLUniProvider;
    LayoutEnter1: TLayout;
    LPasswoed: TLabel;
    ButtonExit: TButton;
    TopToolBar3: TToolBar;
    ToolBarLabel3: TLabel;
    ButtonSettings: TButton;
    LogoImage: TImage;
    PBServerType: TPopupBox;
    LServerType: TLabel;
    LServerAddress: TLabel;
    EServerAddress: TEdit;
    EServerPort: TEdit;
    LServerPort: TLabel;
    CBSaveLoginPassword: TCheckBox;
    PBDBType: TPopupBox;
    UserDBLayout: TLayout;
    LDBType: TLabel;
    LayoutEnter2: TLayout;
    LayoutLogin: TLayout;
    LServerDBName: TLabel;
    EServerDBName: TEdit;
    ButtonSave: TButton;
    IMGestureManager: TGestureManager;
    ContactListBox: TListBox;
    ContactSearchBox: TSearchBox;
    ListBoxGroupHeaderMessage: TListBoxGroupHeader;
    ListBoxGroupHeaderChat: TListBoxGroupHeader;
    ListBoxItem0: TListBoxItem;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    LayoutEnter3: TLayout;
    LayoutEnter0: TLayout;
    StartupTimer: TTimer;
    LHistory: TLabel;
    TopToolBarHistory: TToolBar;
    ToolBarLabelHistory: TLabel;
    RegButton: TLinkBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BEnterClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure PBServerTypeChange(Sender: TObject);
    procedure CBSaveLoginPasswordChange(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure PBDBTypeChange(Sender: TObject);
    procedure UniConnection1AfterDisconnect(Sender: TObject);
    procedure UniConnection1BeforeConnect(Sender: TObject);
    procedure ContactListBoxItemClick(Sender: TObject);
    procedure StartupTimerTimer(Sender: TObject);
  private
    { Private declarations }
    AppEventService : IFMXApplicationEventService;
    FOnOneScreen : Boolean;
    UINInfo: pUINInfo;
    CHATInfo: pCHATInfo;
    function WA_ApplicationEventHandler(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    procedure ReAllignComponents;
    procedure PlayAudio(ResourceID: String);
    function LoadImageFromResource(ResName: String): TBitmap;
    function CheckServiceMode: Boolean;
    procedure GetList;
    procedure GetCHATList;
  public
    { Public declarations }
    StatusKeyboard: Boolean;
    function ExitProgram: Boolean;
    procedure SetDBSettings;
    procedure ExitSettings;
    procedure ExitHistory;
    procedure ConnectDB;
    procedure DisconnectDB;
    procedure LoadContactList;
    function CheckZeroRecordCount(SQL: String): Boolean;
    procedure SQL(SQLText: String); overload;
    procedure SQL(Query: TUniQuery; SQLText: String); overload;
    function ReConnectDB: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

{ Отлавливаем определенные события и делаем логаут или дисконнект }
function TMainForm.WA_ApplicationEventHandler(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  case AAppEvent of
    TApplicationEvent.aeFinishedLaunching: ;
    TApplicationEvent.aeBecameActive: ;
    TApplicationEvent.aeWillBecomeInactive: {LockScreen};
    TApplicationEvent.aeEnteredBackground: {LockScreen};
    TApplicationEvent.aeWillBecomeForeground: ;
    TApplicationEvent.aeWillTerminate: DisconnectDB;
    TApplicationEvent.aeLowMemory: ;
    TApplicationEvent.aeTimeChange: ;
    TApplicationEvent.aeOpenURL: ;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEventService)) then
    AppeventService.SetApplicationEventHandler(WA_ApplicationEventHandler);
  DocumentPath := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath);
  IMGestureManager.FileName := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath)+'imgesture.dat';
  ReAllignComponents;
  LoadINI(DocumentPath);
  ButtonExit.Visible := False;
  ButtonSettings.Visible := True;
  ButtonSave.Visible := False;
  TabControl.ActiveTab := TabItemLogin;
  LogoImage.Position.X := TabControl.Width/2 - LogoImage.Width/2;
  LogoImage.Position.Y := (LayoutLogin.Position.Y - TopToolBarLogin.Height)/2;
  StatusKeyboard := False;
  {$IFDEF ANDROID}
  EncryptInit;
  {$ENDIF}
  UINInfo.pCount := 0;
  CHATInfo.pCount := 0;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  {$IFDEF DEMOACCESS}
  Settings.DBUserName := 'demo';
  Settings.DBUserPassword := 'demo2013';
  Settings.SaveUserPassword := True;
  {$ENDIF}
  CBSavePassword.IsChecked := Settings.SaveUserPassword;
  if Settings.SaveUserPassword then
  begin
    ELogin.Text := Settings.DBUserName;
    EPassword.Text := Settings.DBUserPassword;
    StartupTimer.Enabled := True;
  end;
end;

procedure TMainForm.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  StatusKeyboard := False;
end;

procedure TMainForm.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  StatusKeyboard := True;
end;

procedure TMainForm.FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft: ButtonSettingsClick(ButtonSettings);
    sgiRight: ButtonExitClick(ButtonExit);
  end;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    if not StatusKeyboard then // Если не открыта клавиатура
    begin
      if TabControl.ActiveTab = TabItemList then
      begin
        if not ExitProgram() then
          Key := 0
      end;
      if TabControl.ActiveTab = TabItemSettings then
      begin
        ExitSettings;
        Key := 0;
      end;
      if TabControl.ActiveTab = TabItemHistory then
      begin
        ExitHistory;
        Key := 0;
      end;
    end;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  ReAllignComponents;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  {$IFDEF ANDROID}
  EncryptFree;
  {$ENDIF}
end;

procedure TMainForm.StartupTimerTimer(Sender: TObject);
begin
  StartupTimer.Enabled := False;
  BEnterClick(BEnter);
end;

procedure TMainForm.ReAllignComponents;
begin
  FOnOneScreen := Width > Height;
  if FOnOneScreen then
    LogoImage.Visible := False
  else
    LogoImage.Visible := True;
end;

procedure TMainForm.BEnterClick(Sender: TObject);
var
  ErrStr: String;
begin
  ErrStr := '';
  if ELogin.Text = '' then
    ErrStr := 'Заполните поле "Логин"';
  if EPassword.Text = '' then
  begin
    if ErrStr <> '' then
      ErrStr := ErrStr + #13#10;
    ErrStr := ErrStr + 'Заполните поле "Пароль"';
  end;
  if ErrStr <> '' then
    ShowMessage(ErrStr)
  else
    ConnectDB;
end;

procedure TMainForm.ButtonExitClick(Sender: TObject);
begin
  // Если открыт таб с контактами, то выходим
  if TabControl.ActiveTab = TabItemList then
    ExitProgram();
  // Если открыт таб с настройками, то переходим к другому табу
  if TabControl.ActiveTab = TabItemSettings then
    ExitSettings();
  // Если открыт таб с историей, то переходим к списку контактов
  if TabControl.ActiveTab = TabItemHistory then
    ExitHistory();
end;

procedure TMainForm.ButtonSettingsClick(Sender: TObject);
begin
  // Настройки
  if Settings.ServerType > PBServerType.Items.Count-1 then
    Settings.ServerType := 0;
  PBServerType.ItemIndex := Settings.ServerType;
  if PBServerType.ItemIndex = 0 then
  begin
    UserDBLayout.Visible := False;
    CBSaveLoginPassword.Position.Y := PBServerType.Position.Y + 50;
  end
  else
  begin
    PBDBType.ItemIndex := Integer(Settings.DBType);
    EServerAddress.Text := Settings.DBAddress;
    EServerPort.Text := IntToStr(Settings.DBPort);
    EServerDBName.Text := Settings.DBName;
    UserDBLayout.Visible := True;
    CBSaveLoginPassword.Position.Y := UserDBLayout.Position.Y + UserDBLayout.Height + 15;
  end;
  CBSaveLoginPassword.IsChecked := Settings.SaveUserPassword;
  if TabControl.ActiveTab = TabItemLogin then
  begin
    if not UniConnection1.Connected then
    begin
      CBSaveLoginPassword.Visible := False;
      ButtonExit.Visible := True;
      ButtonSettings.Visible := False;
      ButtonSave.Visible := True;
      ChangeTabAction1.Tab := TabItemSettings;
      ChangeTabAction1.ExecuteTarget(Self);
    end;
  end;
  if TabControl.ActiveTab = TabItemList then
  begin
    CBSaveLoginPassword.Visible := True;
    ButtonSettings.Visible := False;
    ButtonSave.Visible := True;
    ChangeTabAction1.Tab := TabItemSettings;
    ChangeTabAction1.ExecuteTarget(Self);
  end;
end;

procedure TMainForm.PBServerTypeChange(Sender: TObject);
begin
  if (Sender as TPopupBox).ItemIndex = 0 then
  begin
    UserDBLayout.Visible := False;
    CBSaveLoginPassword.Position.Y := PBServerType.Position.Y + 50;
  end
  else
  begin
    PBDBTypeChange(PBDBType);
    UserDBLayout.Visible := True;
    CBSaveLoginPassword.Position.Y := UserDBLayout.Position.Y + UserDBLayout.Height + 15;
  end;
end;

procedure TMainForm.PBDBTypeChange(Sender: TObject);
begin
  if (Sender as TPopupBox).Items[(Sender as TPopupBox).ItemIndex] = 'MySQL' then
    EServerPort.Text := '3306';
end;

procedure TMainForm.CBSaveLoginPasswordChange(Sender: TObject);
begin
  CBSavePassword.IsChecked := (Sender as TCheckBox).IsChecked;
end;

procedure TMainForm.ButtonSaveClick(Sender: TObject);
begin
  Settings.ServerType := PBServerType.ItemIndex;
  if PBServerType.ItemIndex > 0 then
  begin
    Settings.DBType := TDBType(PBDBType.ItemIndex);
    Settings.DBAddress := EServerAddress.Text;
    Settings.DBPort := StrToInt(EServerPort.Text);
    Settings.DBName := EServerDBName.Text;
  end;
  Settings.SaveUserPassword := CBSaveLoginPassword.IsChecked;
  if Settings.SaveUserPassword then
  begin
    Settings.DBUserName := ELogin.Text;
    Settings.DBUserPassword := EPassword.Text;
  end
  else
  begin
    Settings.DBUserName := '';
    Settings.DBUserPassword := '';
  end;
  SaveINI(DocumentPath);
  ButtonExitClick(ButtonExit);
end;

procedure TMainForm.ExitSettings;
begin
  ButtonSave.Visible := False;
  ButtonSettings.Visible := True;
  if not UniConnection1.Connected then
  begin
    ButtonExit.Visible := False;
    ChangeTabAction1.Tab := TabItemLogin;
    ChangeTabAction1.ExecuteTarget(Self);
  end
  else
  begin
    ButtonExit.Visible := True;
    ChangeTabAction1.Tab := TabItemList;
    ChangeTabAction1.ExecuteTarget(Self);
  end;
end;


procedure TMainForm.ExitHistory;
begin
  ButtonSettings.Visible := True;
  ButtonExit.Visible := True;
  ChangeTabAction1.Tab := TabItemList;
  ChangeTabAction1.ExecuteTarget(Self);
end;

function TMainForm.ExitProgram: Boolean;
begin
  Result := False;
  ButtonSave.Visible := False;
  case MessageDlg('Закрыть программу?', System.UITypes.TMsgDlgType.mtCustom,
    [
      System.UITypes.TMsgDlgBtn.mbYes,
      System.UITypes.TMsgDlgBtn.mbNo,
      System.UITypes.TMsgDlgBtn.mbCancel
    ], 0) of
    mrYES: // Выйход из программы
    begin
      Result := True;
      DisconnectDB;
      {$IFDEF ANDROID}
      MainActivity.Finish;
      {$ENDIF}
      {$IFDEF iOS}
      // Пока непонятно, что сделать для выхода
      {$ENDIF}
    end;
    mrNo: // Выход к окну логина-пароля
      DisconnectDB;
  end;
end;

procedure TMainForm.ConnectDB;
begin
  if IsConnected then // Проверка на подключение к сети
  begin
    UniConnection1.Username := ELogin.Text;
    UniConnection1.Password := EPassword.Text;
    fgActivityDialog.Title := 'Подключение к БД';
    fgActivityDialog.Message := 'Пожалуйста, подождите...';
    fgActivityDialog.Show;
    try
      try
        if not UniConnection1.Connected then
          UniConnection1.Connect;
        if UniConnection1.Connected then
        begin
          // Проверка на сохранение логина и пароля
          if CBSavePassword.IsChecked then
          begin
            Settings.DBUserName := ELogin.Text;
            Settings.DBUserPassword := EPassword.Text;
            if not Settings.SaveUserPassword then
            begin
              Settings.SaveUserPassword := CBSavePassword.IsChecked;
              SaveINI(DocumentPath);
            end;
          end
          else
          begin
            Settings.DBUserName := ELogin.Text;
            Settings.DBUserPassword := EPassword.Text;
            if Settings.SaveUserPassword then
            begin
              Settings.SaveUserPassword := CBSavePassword.IsChecked;
              SaveINI(DocumentPath);
            end;
          end;
          fgActivityDialog.Message := 'Подключение выполнено';
          Sleep(100);
          fgActivityDialog.Message := 'Загружаем данные...';
          // Грузим список контактов
          LoadContactList;
          Sleep(100);
        end
        else
        begin
          fgActivityDialog.Message := 'Подключение не выполнено';
          Sleep(1000);
        end;
      except
        on E: Exception do
           ShowMessage(E.Message);
      end;
    finally
      fgActivityDialog.Hide;
    end;
    if UniConnection1.Connected then
    begin
      ChangeTabAction1.Tab := TabItemList;
      ChangeTabAction1.ExecuteTarget(Self);
      ButtonExit.Visible := True;
      ButtonSettings.Visible := True;
    end;
  end
  else
    ShowMessage('Вы не подключены к сети Интернет.');
end;

procedure TMainForm.LoadContactList;
var
  Query: TUniQuery;
  LItem: TListBoxItem;
  LHeader : TListBoxGroupHeader;
  UIN, NickName: String;
  CHATCaption, ProtoAcc: String;
  I: Integer;
begin
  if UniConnection1.Connected then
  begin
    ContactListBox.Items.Clear;
    // Проверяем на наличие записей истории сообщений
    //if CheckZeroRecordCount('select count(*) AS cnt from uin_'+ Settings.DBUserName + '') then
    //if CheckZeroRecordCount('select count(*) AS cnt from uin_chat_'+ Settings.DBUserName +'') then
    GetList;
    GetCHATList;
    ContactListBox.BeginUpdate;
    // История сообщений
    LHeader := TListBoxGroupHeader.Create(ContactListBox);
    LHeader.Text := UpperCase('История сообщений');
    ContactListBox.AddObject(LHeader);
    for I := 0 to UINInfo.pCount-1 do
    begin
      fgActivityDialog.Message := 'Шаг 3: Строим список сообщений... (' + I.ToString+ ' из ' + UINInfo.pCount.ToString + ')';
      LItem := TListBoxItem.Create(ContactListBox);
      LItem.ItemData.Accessory := TListBoxItemData.TAccessory.aMore;
      LItem.ItemData.Text := UINInfo.pID[I].NickName;
      LItem.ItemData.Detail := UINInfo.pID[I].UIN;
      LItem.OnClick := ContactListBoxItemClick;
      LItem.StyleLookup := 'listboxitembottomdetail';
      { Протоколы
        0 - ICQ
        1 - Google Talk
        2 - MRA
        3 - Jabber
        4 - QIP.Ru
        5 - Facebook
        6 - ВКонтакте
        7 - Twitter
        8 - Social
        9 - Unknown
      }
      if (UINInfo.pID[I].Proto >= 0) and (UINInfo.pID[I].Proto < 10) then
        //LItem.ItemData.Bitmap := LoadImageFromResource('ICON_'+IntToStr(UINInfo.pID[I].Proto))
        LItem.ItemData.Bitmap.Assign(LoadImageFromResource('ICON_'+IntToStr(UINInfo.pID[I].Proto)))
      else
        LItem.ItemData.Bitmap.Assign(LoadImageFromResource('ICON_9'));
      ContactListBox.AddObject(LItem);
    end;
    // История чатов
    LHeader := TListBoxGroupHeader.Create(ContactListBox);
    LHeader.Text := UpperCase('История чатов');
    ContactListBox.AddObject(LHeader);
    for I := 0 to CHATInfo.pCount-1 do
    begin
      fgActivityDialog.Message := 'Шаг 4: Строим список чатов... (' + I.ToString+ ' из ' + UINInfo.pCount.ToString + ')';
      LItem := TListBoxItem.Create(ContactListBox);
      LItem.ItemData.Accessory := TListBoxItemData.TAccessory.aMore;
      LItem.ItemData.Text := CHATInfo.pID[I].CHATName;
      LItem.ItemData.Detail := CHATInfo.pID[I].Proto;
      LItem.OnClick := ContactListBoxItemClick;
      LItem.StyleLookup := 'listboxitemnodetail';
      if LowerCase(CHATInfo.pID[I].Proto) = 'skype' then
        LItem.ItemData.Bitmap.Assign(LoadImageFromResource('ICON_10'))
      else
        LItem.ItemData.Bitmap.Assign(LoadImageFromResource('ICON_3'));
      ContactListBox.AddObject(LItem);
    end;
    ContactListBox.EndUpdate;
  end;
end;

procedure TMainForm.ContactListBoxItemClick(Sender: TObject);
begin
  if Sender is TListBoxItem then
  begin
    ToolBarLabelHistory.Text := TListBoxItem(Sender).ItemData.Text + ' (' + TListBoxItem(Sender).ItemData.Detail + ')';
    ChangeTabAction1.Tab := TabItemHistory;
    ChangeTabAction1.ExecuteTarget(Self);
  end;
end;

procedure TMainForm.DisconnectDB;
begin
  try
    if UniConnection1.Connected then
      UniConnection1.Disconnect;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TMainForm.SetDBSettings;
begin
  if Settings.ServerType = 0 then
  begin
    UniConnection1.Server := DefaultDBAddress;
    UniConnection1.Port := DefaultDBPort;
    UniConnection1.Database := DefaultDBName;
    if Settings.DBType = MySQL then
      UniConnection1.ProviderName := 'MySQL';
  end
  else
  begin
    UniConnection1.Server := Settings.DBAddress;
    UniConnection1.Port := Settings.DBPort;
    UniConnection1.Database := Settings.DBName;
    if Settings.DBType = MySQL then
      UniConnection1.ProviderName := 'MySQL';
  end;
end;

{ После отключениея от БД }
procedure TMainForm.UniConnection1AfterDisconnect(Sender: TObject);
begin
  ELogin.Text := '';
  EPassword.Text := '';
  CBSavePassword.IsChecked := False;
  ButtonExit.Visible := False;
  ChangeTabAction1.Tab := TabItemLogin;
  ChangeTabAction1.ExecuteTarget(Self);
end;

{ Перед подключение к БД }
procedure TMainForm.UniConnection1BeforeConnect(Sender: TObject);
begin
  SetDBSettings;
end;

{ Проверка на нулевое количество записей в запросе }
function TMainForm.CheckZeroRecordCount(SQL: String): Boolean;
var
  Query: TUniQuery;
  Count: Integer;
begin
  Result := True;
  if UniConnection1.Connected then
  begin
    Query := TUniQuery.Create(nil);
    Query.Connection := UniConnection1;
    Query.ParamCheck := False;
    try
      Query.SQL.Clear;
      Query.SQL.Text := SQL;
      Query.Open;
      Count := Query.FieldByName('cnt').AsInteger;
      Query.Close;
      if Count = 0 then
        Result := True
      else
        Result := False;
    finally
      Query.Free;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainForm.SQL(SQLText: String);
var
  Query: TUniQuery;
begin
  if UniConnection1.Connected then
  begin
    Query := TUniQuery.Create(nil);
    Query.Connection := UniConnection1;
    Query.ParamCheck := False;
    try
      Query.Close;
      Query.SQL.Clear;
      Query.SQL.Text := SQLText;
      Query.Open;
    except
      on e: Exception do
      begin
        if (not UniConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
        begin
          UniConnection1.Disconnect;
          if not ReConnectDB then
          begin
            Query.Close;
            Exit;
          end
          else
          begin
            try
              Query.Open;
            except
            end;
          end;
        end;
        ShowMessage('Ошибка выполнения SQL запроса.' + #13#10 + Trim(e.Message));
      end;
    end;
    Query.Free;
  end
  else
  begin
    UniConnection1.Disconnect;
    if not ReConnectDB then
    begin
      Query.Close;
      Exit;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainForm.SQL(Query: TUniQuery; SQLText: String);
begin
  if UniConnection1.Connected then
  begin
    Query.Connection := UniConnection1;
    Query.ParamCheck := False;
    try
      Query.Close;
      Query.SQL.Clear;
      Query.SQL.Text := SQLText;
      Query.Open;
    except
      on e: Exception do
      begin
        if (not UniConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
        begin
          UniConnection1.Disconnect;
          if not ReConnectDB then
          begin
            Query.Close;
            Exit;
          end
          else
          begin
            try
              Query.Open;
            except
            end;
          end;
        end;
        ShowMessage('Ошибка выполнения SQL запроса.' + #13#10 + Trim(e.Message));
      end;
    end;
  end
  else
  begin
    UniConnection1.Disconnect;
    if not ReConnectDB then
    begin
      Query.Close;
      Exit;
    end;
  end;
end;

function TMainForm.ReConnectDB: Boolean;
var
  I: Integer;
begin
  if not UniConnection1.Connected then
  begin
    fgActivityDialog.Hide;
    fgActivityDialog.Title := 'Переподключение к БД';
    fgActivityDialog.Message := 'Пожалуйста, подождите...';
    fgActivityDialog.Show;
    // Пробуем переподключиться
    I := 0;
    while (not UniConnection1.Connected) and (I < ReconnectCount) do
    begin
      Inc(I);
      try
        UniConnection1.Connect;
      except
        on e: Exception do
        begin
          fgActivityDialog.Message := Trim(e.Message);
          UniConnection1.Disconnect;
        end;
      end;
      Sleep(ReconnectInterval);
    end;
    if UniConnection1.Connected then
    begin
      fgActivityDialog.Message := 'Подключение выполнено';
      Result := True;
    end
    else
      Result := False;
    fgActivityDialog.Hide;
  end
  else
    Result := True;
end;

procedure TMainForm.PlayAudio(ResourceID: String);
var
  ResStream: TResourceStream;
  TmpFile: String;
  MP: TMediaPlayer;
begin
  ResStream := TResourceStream.Create(HInstance, ResourceID, RT_RCDATA);
  MP := TMediaPlayer.Create(Owner);
  try
    TmpFile := TPath.Combine(TPath.GetTempPath, 'tmp.mp3');
    ResStream.Position := 0;
    try
      ResStream.SaveToFile(TmpFile);
    except
      on E: Exception do
        Exit;
    end;
    MP.FileName := TmpFile;
    MP.Play;
  finally
    ResStream.Free;
    MP.Free;
  end;
end;

function TMainForm.LoadImageFromResource(ResName: String): TBitmap;
var
  InStream: TResourceStream;
  Img: TBitmap;
begin
  Img := TBitmap.Create;
  InStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    Img.LoadFromStream(InStream);
    Img.Height := 64;
    Img.Width := 64;
    Result := Img;
  finally
    InStream.Free;
    Img.Free;
  end;
end;

{ Проверка на сервисный режим }
function TMainForm.CheckServiceMode: Boolean;
var
  Query: TUniQuery;
begin
  Result := False;
  if UniConnection1.Connected then
  begin
    Query := TUniQuery.Create(nil);
    Query.Connection := UniConnection1;
    Query.ParamCheck := False;
    Query.SQL.Clear;
    Query.SQL.Text := 'select config_value from config where config_name = ''system_disable''';
    try
      Query.Open;
      Result := Query.FieldByName('config_value').AsBoolean;
      Query.Close;
    finally
      Query.Free;
    end;
  end;
end;

{ Получаем из БД список контактов }
procedure TMainForm.GetList;
var
  Query: TUniQuery;
  pCnt: Integer;
  SQLUIN, SQLNickName: String;
  SQLProto: Integer;
begin
  if UniConnection1.Connected then
  begin
    // Проверяем на предмет сервисного режима БД
    if not CheckServiceMode then
    begin
      Query := TUniQuery.Create(nil);
      try
        SQL(Query, 'select nick,uin,proto_name from uin_'+ Settings.DBUserName + ' where nick is not null group by uin order by nick asc');
        while not Query.EOF do
        begin
          fgActivityDialog.Message := 'Шаг 1: Загружаем контакты... (' + Query.RecNo.ToString+ ' из ' + Query.RecordCount.ToString + ')';
          SQLUIN := Query.FieldByName('uin').AsString;
          SQLNickName := Query.FieldByName('nick').AsString;
          SQLProto := Query.FieldByName('proto_name').AsInteger;
          SQLUIN := UTF8ToString(SQLUIN);
          SQLNickName := UTF8ToString(SQLNickName);
          // Заполняем массив в структуре
          pCnt := UINInfo.pCount;
          UINInfo.pCount := pCnt+1;
          SetLength(UINInfo.pID, UINInfo.pCount);
          UINInfo.pID[pCnt].UIN := SQLUIN;
          UINInfo.pID[pCnt].NickName := SQLNickName;
          UINInfo.pID[pCnt].Proto := SQLProto;
          Query.Next;
        end;
      finally
        Query.Free;
      end;
    end;
  end;
end;

{ Получаем из БД список чатов }
procedure TMainForm.GetCHATList;
var
  Query: TUniQuery;
  pCnt: Integer;
  SQLCHATName, SQLProto: String;
begin
  if UniConnection1.Connected then
  begin
    // Проверяем на предмет сервисного режима БД
    if not CheckServiceMode then
    begin
      Query := TUniQuery.Create(nil);
      try
        SQL(Query, 'select distinct chat_caption,proto_acc from uin_chat_'+ Settings.DBUserName + ' where chat_caption is not null order by chat_caption asc');
        while not Query.EOF do
        begin
          fgActivityDialog.Message := 'Шаг 2: Загружаем чаты... (' + Query.RecNo.ToString+ ' из ' + Query.RecordCount.ToString + ')';
          SQLCHATName := Query.FieldByName('chat_caption').AsString;
          SQLProto := Query.FieldByName('proto_acc').AsString;
          SQLCHATName := UTF8ToString(SQLCHATName);
          // Заполняем массив в структуре
          pCnt := CHATInfo.pCount;
          CHATInfo.pCount := pCnt+1;
          SetLength(CHATInfo.pID, CHATInfo.pCount);
          CHATInfo.pID[pCnt].CHATName := SQLCHATName;
          CHATInfo.pID[pCnt].Proto := SQLProto;
          Query.Next;
        end;
      finally
        Query.Free;
      end;
    end;
  end;
end;

end.

