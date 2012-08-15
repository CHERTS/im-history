{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBCreateDB v2.0                               # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Main;

interface

uses
  Global, About, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Types, Menus, XMLIntf, XMLDoc, DB, ZAbstractConnection, ZConnection,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZClasses, ZDbcIntfs, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, ZSqlProcessor, RegExpr, ToolWin, IniFiles,
  ZSqlMonitor, ZScriptParser;

type
  TMainForm = class(TForm)
    ZConnection1: TZConnection;
    UpdateQuery: TZQuery;
    DBUpdateProcessor: TZSQLProcessor;
    ToolBar1: TToolBar;
    ImageList_ToolBar: TImageList;
    AboutButton: TToolButton;
    LangButton: TToolButton;
    Lang_PM: TPopupMenu;
    LangRussian: TMenuItem;
    LangEnglish: TMenuItem;
    CreateINIButton: TButton;
    StepsPageControl: TPageControl;
    Step0TabSheet: TTabSheet;
    StepsTabSheet: TTabSheet;
    DBGroupBox: TGroupBox;
    LIMDBName: TLabel;
    CreateDBButton: TButton;
    EIMDBName: TEdit;
    UserGroupBox: TGroupBox;
    LUserName: TLabel;
    LUserPaswd: TLabel;
    EUserName: TEdit;
    EUserPaswd: TEdit;
    CreateUserButton: TButton;
    DeleteUserButton: TButton;
    TableGroupBox: TGroupBox;
    CreateTableDBButton: TButton;
    DeleteTableDBButton: TButton;
    TableGrantGroupBox: TGroupBox;
    GrantUserButton: TButton;
    RevokeUserButton: TButton;
    RootGroupBox: TGroupBox;
    LDBType: TLabel;
    LDBAddress: TLabel;
    LDBPort: TLabel;
    LDBLogin: TLabel;
    LDBPasswd: TLabel;
    LYesConnect: TLabel;
    LDBName: TLabel;
    ConnectButton: TButton;
    CBDBType: TComboBox;
    EDBAddress: TEdit;
    EDBPort: TEdit;
    EDBUserName: TEdit;
    EDBPasswd: TEdit;
    EDBName: TEdit;
    HelpGroupBox: TGroupBox;
    LHelp: TLabel;
    SQLLogTabSheet: TTabSheet;
    ZSQLMonitor1: TZSQLMonitor;
    ZLogList: TMemo;
    ClearLogButton: TButton;
    CBAllowUpdateDB: TCheckBox;
    CBDropConfigTable: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure AboutClick(Sender: TObject);
    procedure ZConnection1AfterDisconnect(Sender: TObject);
    procedure ZConnection1AfterConnect(Sender: TObject);
    procedure CBDBTypeChange(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure CreateDBButtonClick(Sender: TObject);
    procedure CreateUserButtonClick(Sender: TObject);
    procedure DeleteUserButtonClick(Sender: TObject);
    procedure CreateTableDBButtonClick(Sender: TObject);
    procedure DeleteTableDBButtonClick(Sender: TObject);
    procedure GrantUserButtonClick(Sender: TObject);
    procedure RevokeUserButtonClick(Sender: TObject);
    procedure LangRussianClick(Sender: TObject);
    procedure LangEnglishClick(Sender: TObject);
    procedure CreateINIButtonClick(Sender: TObject);
    procedure ButtonActivate;
    procedure ButtonDeactivate;
    procedure CoreLanguageChanged;
    procedure DeleteTableDB;
    function DBUpdate(SQLUpdateFile: String): Boolean;
    function DBParamCheck: Boolean;
    function CheckRegExprStr(RegExprStr, CheckStr: WideString): Boolean;
    function SQL_Zeos(SQL: WideString): Boolean;
    function SQL_Zeos_Exec(SQL: WideString): Boolean;
    function CheckZeroRecordCount(SQL: String): Boolean;
    procedure ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent;
      var LogTrace: Boolean);
    procedure ClearLogButtonClick(Sender: TObject);
    procedure CBAllowUpdateDBClick(Sender: TObject);
  private
    { Private declarations }
    FLanguage : WideString;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
    HistoryMainFormHidden: Boolean;
    property CoreLanguage: WideString read FLanguage;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{$I HistoryToDBCreateDB.inc}

procedure TMainForm.AboutClick(Sender: TObject);
begin
  AboutForm.Show;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Для мультиязыковой поддержки
  MainFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Загружаем настройки локализации
  FLanguage := 'Russian';
  LangDoc := NewXMLDocument();
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + dirLangs) then
    CreateDir(ExtractFilePath(Application.ExeName) + dirLangs);
  CoreLanguageChanged;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ZConnection1.Connected then
    ZConnection1.Disconnect;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  I, J: Integer;
  Drivers: IZCollection;
  Protocols: TStringDynArray;
begin
  Caption := ProgramsName;
  // Ставим галки на нужный язык по умолчанию
  Lang_PM.Items[0].Checked := True;
  Lang_PM.Items[1].Checked := False;
  StepsPageControl.ActivePage := Step0TabSheet;
  StepsPageControl.Pages[1].TabVisible := False;
  StepsPageControl.Pages[2].TabVisible := False;
  // End
  WriteErrLog := True;
  // Выводим список поддерживаемых протоколов
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
  EIMDBName.Text := DefaultDBName;
end;

{ Обработчик запроса к БД }
function TMainForm.SQL_Zeos(Sql: WideString): Boolean;
var
  ErrorCount: Integer;
begin
   ErrorCount := 0;
  try
    if ZConnection1.Connected then
    begin
      UpdateQuery.Connection := ZConnection1;
      try
        UpdateQuery.Close;
        UpdateQuery.SQL.Clear;
        UpdateQuery.SQL.Text := Sql;
        UpdateQuery.Open;
      except
        on e :
          Exception do
          begin
            Inc(ErrorCount);
            if WriteErrLog then
              WriteInLog(ExtractFilePath(Application.ExeName), Format(ERR_SQL_QUERY, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
            MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          end;
      end;
    end;
  except
    on e :
      Exception do
      begin
        Inc(ErrorCount);
        MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
      end;
  end;
  if ErrorCount > 0 then
    Result := False
  else
    Result := True;
end;

{ Обработчик запроса к БД }
function TMainForm.SQL_Zeos_Exec(SQL: WideString): Boolean;
var
  ErrorCount: Integer;
begin
  ErrorCount := 0;
  try
    if ZConnection1.Connected then
    begin
      UpdateQuery.Connection := ZConnection1;
      if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
        ZConnection1.StartTransaction;
      try
        UpdateQuery.Close;
        UpdateQuery.SQL.Clear;
        UpdateQuery.SQL.Text := SQL;
        UpdateQuery.ExecSQL;
      except
        on e :
          Exception do
          begin
            if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
              ZConnection1.Rollback;
            Inc(ErrorCount);
            if WriteErrLog then
              WriteInLog(ExtractFilePath(Application.ExeName), Format(ERR_SQL_QUERY, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
            MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrSQLExecQuery') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          end;
      end;
      if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
        ZConnection1.Commit;
    end;
  except
    on e :
      Exception do
      begin
        Inc(ErrorCount);
        MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
      end;
  end;
  if ErrorCount > 0 then
    Result := False
  else
    Result := True;
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    ZConnection1.Reconnect;
end;

{ Выполняется после подключения к БД }
procedure TMainForm.ZConnection1AfterConnect(Sender: TObject);
begin
  ConnectButton.Caption := GetLangStr('DisconnectButton');
  ConnectButton.Hint := 'DisconnectButton';
  LYesConnect.Caption := GetLangStr('LYesConnect');
  LYesConnect.Hint := 'LYesConnect';
  LYesConnect.Font.Color := clBlue;
  ButtonActivate;
  StepsPageControl.Pages[1].TabVisible := True;
  StepsPageControl.Pages[2].TabVisible := True;
  StepsPageControl.ActivePage := StepsTabSheet;
  if (ZConnection1.Protocol = 'oracle') or
   (ZConnection1.Protocol = 'oracle-9i') then
    SQL_Zeos_Exec('alter session set current_schema='+EDBAddress.Text);
end;

{ После отключения от БД }
procedure TMainForm.ZConnection1AfterDisconnect(Sender: TObject);
begin
  ConnectButton.Caption := GetLangStr('ConnectButton');
  ConnectButton.Hint := 'ConnectButton';
  LYesConnect.Caption := GetLangStr('LNoConnect');
  LYesConnect.Hint := 'LNoConnect';
  LYesConnect.Font.Color := clRed;
  ButtonDeactivate;
  StepsPageControl.ActivePage := Step0TabSheet;
  StepsPageControl.Pages[1].TabVisible := False;
  StepsPageControl.Pages[2].TabVisible := False;
  HelpGroupBox.Visible := False;
  LHelp.Caption := 'Empty';
  LHelp.Hint := 'LHelpEmpty';
  ZLogList.Clear;
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TMainForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

procedure TMainForm.ConnectButtonClick(Sender: TObject);
begin
  if ZConnection1.Connected then
  begin
    ZConnection1.Disconnect;
    Exit;
  end;
  if DBParamCheck then
  begin
    ZConnection1.Protocol := CBDBType.Items[CBDBType.ItemIndex];
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
    begin
      ZConnection1.HostName := '';
      ZConnection1.Port := 0;
      ZConnection1.User := '';
      ZConnection1.Password := '';
      ZConnection1.TransactIsolationLevel := tiNone;
      ZConnection1.AutoCommit := True;
      EIMDBName.Text := EDBName.Text;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      ZConnection1.HostName := EDBAddress.Text;
      ZConnection1.Port := StrToInt(EDBPort.Text);
      ZConnection1.User := EDBUserName.Text;
      ZConnection1.Password := EDBPasswd.Text;
      ZConnection1.TransactIsolationLevel := tiReadCommitted;
      ZConnection1.AutoCommit := True;
      EIMDBName.Text := EDBName.Text
    end
    else // Другие
    begin
      ZConnection1.HostName := EDBAddress.Text;
      ZConnection1.Port := StrToInt(EDBPort.Text);
      ZConnection1.User := EDBUserName.Text;
      ZConnection1.Password := EDBPasswd.Text;
      ZConnection1.TransactIsolationLevel := tiNone;
      ZConnection1.AutoCommit := True;
    end;
    ZConnection1.Database := EDBName.Text;
    ZConnection1.LoginPrompt := False;
    ZConnection1.Properties.Clear;
    ZConnection1.Properties.Add('codepage=UTF8');
    try
      ZConnection1.Connect;
    except
      on e :
        Exception do
        begin
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
          ZConnection1.Disconnect;
        end
    end;
  end;
end;

procedure TMainForm.ButtonActivate;
begin
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
  begin
    EIMDBName.Enabled := False;
    CreateDBButton.Enabled := False;
    CreateUserButton.Enabled := False;
    DeleteUserButton.Enabled := False;
    EUserName.Enabled := True;
    EUserPaswd.Enabled := False;
    GrantUserButton.Enabled := False;
    RevokeUserButton.Enabled := False;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
  begin
    EIMDBName.Enabled := False;
    CreateDBButton.Enabled := False;
    CreateUserButton.Enabled := True;
    DeleteUserButton.Enabled := True;
    EUserName.Enabled := True;
    EUserPaswd.Enabled := True;
    GrantUserButton.Enabled := True;
    RevokeUserButton.Enabled := True;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
  begin
    EIMDBName.Enabled := False;
    CreateDBButton.Enabled := False;
    CreateUserButton.Enabled := True;
    DeleteUserButton.Enabled := True;
    EUserName.Enabled := True;
    EUserPaswd.Enabled := True;
    GrantUserButton.Enabled := True;
    RevokeUserButton.Enabled := True;
  end
  else
  begin
    EIMDBName.Enabled := True;
    CreateDBButton.Enabled := True;
    CreateUserButton.Enabled := True;
    DeleteUserButton.Enabled := True;
    EUserName.Enabled := True;
    EUserPaswd.Enabled := True;
    GrantUserButton.Enabled := True;
    RevokeUserButton.Enabled := True;
  end;
  CreateTableDBButton.Enabled := True;
  DeleteTableDBButton.Enabled := True;
  GrantUserButton.Enabled := True;
  RevokeUserButton.Enabled := True;
  CreateINIButton.Enabled := True;
end;

procedure TMainForm.ButtonDeactivate;
begin
  EIMDBName.Enabled := False;
  CreateDBButton.Enabled := False;
  EUserName.Enabled := False;
  EUserPaswd.Enabled := False;
  CreateUserButton.Enabled := False;
  DeleteUserButton.Enabled := False;
  CreateTableDBButton.Enabled := False;
  DeleteTableDBButton.Enabled := False;
  GrantUserButton.Enabled := False;
  RevokeUserButton.Enabled := False;
  CreateINIButton.Enabled := False;
end;

{ Смена типа БД }
procedure TMainForm.CBDBTypeChange(Sender: TObject);
begin
  if ZConnection1.Connected then
    ZConnection1.Disconnect;
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    EDBAddress.Text := 'localhost';
    LDBName.Caption := GetLangStr('LDBName');
    EDBName.Text := 'mysql';
    EDBPasswd.Enabled := True;
    EDBPort.Text := '3306';
    EDBUserName.Text := 'root';
    EIMDBName.Text := DefaultDBName;
    HelpGroupBox.Visible := False;
    LHelp.Caption := 'Empty';
    LHelp.Hint := 'LHelpEmpty';
    StepsPageControl.Pages[1].TabVisible := False;
    CBAllowUpdateDB.Enabled := True;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    EDBAddress.Text := 'localhost';
    LDBName.Caption := GetLangStr('LDBName');
    EDBName.Text := 'template1';
    EDBPasswd.Enabled := True;
    EDBPort.Text := '5432';
    EIMDBName.Text := DefaultDBName;
    HelpGroupBox.Visible := False;
    LHelp.Caption := 'Empty';
    LHelp.Hint := 'LHelpEmpty';
    StepsPageControl.Pages[1].TabVisible := False;
    CBAllowUpdateDB.Enabled := True;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := False;
    LDBAddress.Caption := GetLangStr('LDBSchema');
    LDBName.Caption := GetLangStr('LDBNameOracle');
    EDBAddress.Text := '';
    EDBPort.Text := '0000';
    EDBPasswd.Enabled := True;
    EDBName.Text := '';
    EDBUserName.Text := '';
    EDBPasswd.Text := '';
    LHelp.Caption := GetLangStr('LHelpOracle');
    LHelp.Hint := 'LHelpOracle';
    HelpGroupBox.Visible := True;
    StepsPageControl.Pages[1].TabVisible := False;
    CBAllowUpdateDB.Enabled := True;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
  begin
    EDBAddress.Enabled := False;
    EDBPort.Enabled := False;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := false;
    EDBName.Text := DefaultSQLiteDBName;
    EDBUserName.Text := 'root';
    EDBAddress.Text := '0.0.0.0';
    EDBPort.Text := '0000';
    EIMDBName.Text := DefaultSQLiteDBName;
    EDBPasswd.Text := '';
    LHelp.Caption := GetLangStr('LHelpSQLite');
    LHelp.Hint := 'LHelpSQLite';
    HelpGroupBox.Visible := True;
    StepsPageControl.Pages[1].TabVisible := False;
    CBAllowUpdateDB.Enabled := False;
  end
  else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
  begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBAddress.Caption := GetLangStr('LDBAddress');
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := True;
    EDBName.Text := DefaultFireBirdDBName;
    EDBUserName.Text := 'SYSDBA';
    EDBAddress.Text := 'localhost';
    EDBPort.Text := '3050';
    EIMDBName.Text := DefaultFireBirdDBName;
    EDBPasswd.Text := 'masterkey';
    LHelp.Caption := GetLangStr('LHelpFirebird');
    LHelp.Hint := 'LHelpFirebird';
    HelpGroupBox.Visible := True;
    StepsPageControl.Pages[1].TabVisible := True;
    EIMDBName.Enabled := True;
    CreateDBButton.Enabled := True;
    CBAllowUpdateDB.Enabled := False;
  end
  else
    begin
    EDBAddress.Enabled := True;
    EDBPort.Enabled := True;
    LDBName.Caption := GetLangStr('LDBName');
    EDBPasswd.Enabled := true;
    EDBAddress.Text := 'localhost';
    EDBPort.Text := '0000';
    EDBName.Text := DefaultDBName;
    EDBUserName.Text := '';
    EDBPasswd.Text := '';
    EIMDBName.Text := DefaultDBName;
    HelpGroupBox.Visible := False;
    LHelp.Caption := 'Empty';
    LHelp.Hint := 'LHelpEmpty';
    StepsPageControl.Pages[1].TabVisible := False;
    CBAllowUpdateDB.Enabled := True;
  end
end;

{ Проверка введенных параметров БД }
function TMainForm.DBParamCheck: Boolean;
var
  ErrorsCount: Integer;
  ErrorsMsg: WideString;
begin
  ErrorsCount := 0;
  ErrorsMsg := '';
  if CBDBType.Items[CBDBType.ItemIndex] = '' then
  begin
    ErrorsCount := ErrorsCount + 1;
    ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck8') + #10#13;
  end;
  if (not MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
  begin
    if EDBAddress.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
        ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck6') + #10#13
      else
        ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck1') + #10#13;
    end;
    if EDBPort.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck2') + #10#13;
    end;
    {if EDBPasswd.Text = '' then
    begin
      ErrorsCount := ErrorsCount + 1;
      ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck3') + #10#13;
    end;}
  end;
  if EDBUserName.Text = ''  then
  begin
    ErrorsCount := ErrorsCount + 1;
    ErrorsMsg := ErrorsMsg + GetLangStr('ErrDBParamCheck4') + #10#13;
  end;
  if EDBName.Text = '' then
  begin
    ErrorsCount := ErrorsCount + 1;
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
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

{ Предупреждение о выдаче глобальных привилегий }
procedure TMainForm.CBAllowUpdateDBClick(Sender: TObject);
begin
  if CBAllowUpdateDB.Checked then
    MsgInf(ProgramsName, Format(GetLangStr('AllowGlobalGrant'),[EUserName.Text]));
end;

{ Создание БД }
procedure TMainForm.CreateDBButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
  begin
    ZConnection1.HostName := EDBAddress.Text;
    ZConnection1.Port := StrToInt(EDBPort.Text);
    ZConnection1.User := EDBUserName.Text;
    ZConnection1.Password := EDBPasswd.Text;
    ZConnection1.Database := EIMDBName.Text;
    ZConnection1.Protocol := CBDBType.Items[CBDBType.ItemIndex];
    ZConnection1.Properties.Clear;
    ZConnection1.Properties.Add ('CreateNewDatabase=CREATE DATABASE ' +
        QuotedStr ('' + EIMDBName.Text + '') + ' USER ' +
        QuotedStr ('' + EDBUserName.Text + '') + ' PASSWORD ' + QuotedStr ('' + EDBPasswd.Text + '') +
        ' PAGE_SIZE 4096 DEFAULT CHARACTER SET UTF8');
    ZConnection1.Connect;
    MsgInf(ProgramsName, GetLangStr('DBCreated'));
    ZConnection1.Disconnect;
    Exit;
  end;
  ErrorsCount := 0;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      if (not SQL_Zeos_Exec('CREATE DATABASE IF NOT EXISTS ' + EIMDBName.Text + ' CHARACTER SET utf8;')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      if (not SQL_Zeos_Exec('CREATE DATABASE ' + EIMDBName.Text + ' ENCODING ''utf8'';')) then
        Inc(ErrorsCount);
    end
    else
    begin
      if (not SQL_Zeos_Exec('CREATE DATABASE ' + EIMDBName.Text + ' CHARACTER SET utf8;')) then
        Inc(ErrorsCount);
    end;
  end
  else
    MsgDie(ProgramsName, GetLangStr('ErrRegexprDBName'));
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('DBCreated'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrCreateDB') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
end;

procedure TMainForm.CreateINIButtonClick(Sender: TObject);
var
  Path: WideString;
  INI: TIniFile;
begin
  if DBParamCheck then
  begin
    // Инициализация криптования
    EncryptInit;
    Path := ExtractFilePath(Application.ExeName) + ININame;
    INI := TIniFile.Create(Path);
    INI.WriteString('Main', 'DBType', CBDBType.Items[CBDBType.ItemIndex]);
    if (CBDBType.Items[CBDBType.ItemIndex] = 'oracle') or
      (CBDBType.Items[CBDBType.ItemIndex] = 'oracle-9i') then
      INI.WriteString('Main', 'DBSchema', EDBAddress.Text)
    else
      INI.WriteString('Main', 'DBAddress', EDBAddress.Text);
    INI.WriteString('Main', 'DBPort', EDBPort.Text);
    INI.WriteString('Main', 'DBName', EIMDBName.Text);
    INI.WriteString('Main', 'DBUserName', EUserName.Text);
    INI.WriteString('Main', 'DBPasswd', EncryptStr(EUserPaswd.Text));
    INI.WriteInteger('Main', 'SyncMethod', 1);
    INI.WriteInteger('Main', 'SyncInterval', 0);
    INI.WriteInteger('Main', 'SyncTimeCount', 40);
    INI.WriteInteger('Main', 'SyncMessageCount', 50);
    INI.WriteInteger('Main', 'NumLastHistoryMsg', 6);
    INI.WriteString('Main', 'WriteErrLog', '1');
    INI.WriteString('Main', 'ShowAnimation', '1');
    INI.WriteString('Main', 'EnableHistoryEncryption', '0');
    INI.WriteString('Main', 'DefaultLanguage', CoreLanguage);
    INI.WriteString('Main', 'HideHistorySyncIcon', '0');
    INI.WriteString('Main', 'ShowPluginButton', '1');
    INI.WriteString('Main', 'AddSpecialContact', '1');
    INI.WriteString('Main', 'BlockSpamMsg', '0');
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
    INI.WriteString('HotKey', 'SyncHotKey', 'Ctrl+Alt+F11');
    INI.WriteString('HotKey', 'SyncHotKeyDBSync', 'Ctrl+Alt+F12');
    INI.WriteString('HotKey', 'ExSearchHotKey', 'Ctrl+F3');
    INI.WriteString('HotKey', 'ExSearchNextHotKey', 'F3');
    INI.Free;
    // Освобождаем ресурсы
    EncryptFree;
    MsgInf(ProgramsName, GetLangStr('CreateINIDone') + #13 + GetLangStr('CopyDefaultINIFile'));
  end;
end;

{ Создание таблиц }
procedure TMainForm.CreateTableDBButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      // Проверка на соответствие имени БД
      if not CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
      begin
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + GetLangStr('ErrRegexprDBName'));
        Exit;
      end;
      // Создание таблиц
      SQL_Zeos_Exec('use ' + EIMDBName.Text + ';');
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_config.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTableConfig') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_config.sql']));
      end;
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      // Меняем БД
      ZConnection1.Disconnect;
      ZConnection1.Database := EIMDBName.Text;
      ZConnection1.Connect;
      if not ZConnection1.Connected then
        Exit;
      // Создание таблицы config
      if DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_config.sql') then
        SQL_Zeos('select create_config_tbl(0)')
      else
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_config.sql']));
      end;
      // Создание таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      // Создание таблицы config
      SQL_Zeos('SELECT TABLE_NAME FROM ALL_TABLES WHERE TABLE_NAME = ''CONFIG''');
      if UpdateQuery.FieldByName('TABLE_NAME').AsString <> 'CONFIG' then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_config.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_config.sql']));
        end;
      end;
      // Создание таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle.sql']));
      end;
      // Создание триггеров
      DBUpdateProcessor.DelimiterType := dtSetTerm;
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_trigger.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_trigger.sql']));
      end
      else
        MsgDie(ProgramsName, 'К сожалению, из-за ошибки в компоненте ZeosLib создание триггеров проходит с ошибкой, и они создаются в БД как Инвалидные. Откройте тело триггера, сотрите последний знак <;> и напишите его заново, после этого триггеры перейдут в рабочий статус.');
      DBUpdateProcessor.DelimiterType := dtDefault;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
    begin
      // Создание таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\sqlite.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\sqlite.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      DBUpdateProcessor.DelimiterType := dtSetTerm;
      // Создание таблицы config
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_config.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_config.sql']));
      end;
      DBUpdateProcessor.DelimiterType := dtDefault;
      // Создание таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird.sql']));
      end;
      DBUpdateProcessor.DelimiterType := dtSetTerm;
      // Создание триггеров
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_trigger.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_trigger.sql']));
      end;
      DBUpdateProcessor.DelimiterType := dtDefault;
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrCreateTableUnknownDBType'));
      Exit;
    end
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('CreateTableDone'))
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrCreateTable') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
    Exit;
  end;
  // Заполняем таблицу config только если в ней нет записей
  if CheckZeroRecordCount('select count(*) AS cnt from config') then
  begin
    if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\config_insert.sql')) then
      MsgDie(ProgramsName, GetLangStr('ErrInsertTableConfig'));
  end;
end;

{ Удаление таблиц }
procedure TMainForm.DeleteTableDBButtonClick(Sender: TObject);
var
  DelMsg: String;
begin
  if CBDropConfigTable.Checked then
    DelMsg := GetLangStr('DeleteAllTable1')
  else
    DelMsg := GetLangStr('DeleteAllTable2');
  case MessageBox(Handle,PWideChar(Format(DelMsg, [EUserName.Text])),PWideChar(GetLangStr('DeleteAllTableCaption')),36) of
    6: DeleteTableDB;
    7: Exit;
  end;
end;

{ Удаление таблиц }
procedure TMainForm.DeleteTableDB;
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      // Проверка на соответствие имени БД
      if not CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
      begin
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + GetLangStr('ErrRegexprDBName'));
        Exit;
      end;
      // Удаление таблиц
      SQL_Zeos_Exec('use ' + EIMDBName.Text + ';');
      // Удаление таблицы config
      if CBDropConfigTable.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_delete_config.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_delete_config.sql']));
        end;
      end;
      // Удаление остальных таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\delete_table.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\delete_table.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      // Меняем БД
      ZConnection1.Disconnect;
      ZConnection1.Database := EIMDBName.Text;
      ZConnection1.Connect;
      if not ZConnection1.Connected then
        Exit;
      // Удаление таблицы config
      if CBDropConfigTable.Checked then
      begin
        SQL_Zeos('select delete_config_tbl(0)');
        // Удаление функций создания таблицы config
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_delete_global_function.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrDeleteSequence') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_delete_global_function.sql']));
        end;
      end;
      // Удаление остальных таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\delete_table.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\delete_table.sql']));
      end;
      // Удаление последовательностей
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\delete_sequence.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteSequence') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\delete_sequence.sql']));
      end;
      // Удаление функций
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_delete_function.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteSequence') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_delete_function.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      // Удаление таблицы config
      if CBDropConfigTable.Checked then
      begin
        SQL_Zeos('SELECT TABLE_NAME FROM ALL_TABLES WHERE TABLE_NAME = ''CONFIG''');
        if UpdateQuery.FieldByName('TABLE_NAME').AsString = 'CONFIG' then
        begin
          if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_delete_config.sql')) then
          begin
            Inc(ErrorsCount);
            MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_delete_config.sql']));
          end;
        end;
      end;
      // Удаление остальных таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_delete_table.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_delete_table.sql']));
      end;
      // Удаление последовательностей
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\delete_sequence.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteSequence') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\delete_sequence.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'sqlite*')) then
    begin
      // Удаление таблицы config
      if CBDropConfigTable.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\sqlite_delete_config.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\sqlite_delete_config.sql']));
        end;
      end;
      // Удаление остальных таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\delete_table.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\delete_table.sql']));
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      DBUpdateProcessor.DelimiterType := dtSetTerm;
      // Удаление таблицы config
      if CBDropConfigTable.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_delete_config.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_delete_config.sql']));
        end;
      end;
      // Удаление таблиц
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_delete_table.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_delete_table.sql']));
      end;
      // Удаление последовательностей
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_delete_sequence.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrDeleteSequence') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_delete_sequence.sql']));
      end;
      DBUpdateProcessor.DelimiterType := dtDefault;
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrDeleteTableUnknownDBType'));
      Exit;
    end;
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('DeleteTableDone'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrDeleteTable') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
end;

{ Создание поьзователя }
procedure TMainForm.CreateUserButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if EUserPaswd.Text = '' then
    begin
      MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + GetLangStr('NoEmptyPassword'));
      Exit;
    end;
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      // Проверка на соответствие имени БД
      if not CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
      begin
        MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + GetLangStr('ErrRegexprDBName'));
        Exit;
      end;
      // Создание таблицы config
      SQL_Zeos_Exec('use ' + EIMDBName.Text + ';');
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_config.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_config.sql']));
        Exit;
      end;
      // Создаем юзера
      if (not SQL_Zeos_Exec('grant select on ' + EIMDBName.Text + '.config to ''' + EUserName.Text + '''@''%'' identified by ''' + EUserPaswd.Text + '''')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      if (not SQL_Zeos_Exec('create user ' + EUserName.Text + ' with password ''' + EUserPaswd.Text + '''')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      if (not SQL_Zeos_Exec('create user ' + EUserName.Text + ' identified by "' + EUserPaswd.Text + '"')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      if (not SQL_Zeos_Exec('create user ' + EUserName.Text + ' password ''' + EUserPaswd.Text + '''')) then
        Inc(ErrorsCount);
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrCreateUserUnknownDBType'));
      Exit;
    end
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('CreateUserDone'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrCreateUser') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
end;

{ Удаление пользователя }
procedure TMainForm.DeleteUserButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrDeleteUser') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      if (not SQL_Zeos_Exec('drop user ''' + EUserName.Text + '''')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      if (not SQL_Zeos_Exec('drop user ' + EUserName.Text + '')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      if (not SQL_Zeos_Exec('drop user ' + EUserName.Text + '')) then
        Inc(ErrorsCount);
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      if (not SQL_Zeos_Exec('drop user ' + EUserName.Text + '')) then
        Inc(ErrorsCount);
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrDeleteUserUnknownDBType'));
      Exit;
    end
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrDeleteUser') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('DeleteUserDone'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrDeleteUser'));
end;

{ Назначение прав }
procedure TMainForm.GrantUserButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      // Проверка на соответствие имени БД
      if not CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
      begin
        MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + GetLangStr('ErrRegexprDBName'));
        Exit;
      end;
      // Назначение прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_grant.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_grant.sql']));
      end;
      // Назначение доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_grant_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_grant_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      // Назначение прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_grant.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_grant.sql']));
      end;
      // Назначение доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_grant_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_grant_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      // Назначение прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_grant.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_grant.sql']));
      end;
      // Назначение доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_grant_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_grant_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      // Назначение прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_grant.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_grant.sql']));
      end;
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrGrantUnknownDBType'));
      Exit;
    end
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('GrantDone'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
end;

{ Отнимаем права у пользователя }
procedure TMainForm.RevokeUserButtonClick(Sender: TObject);
var
  ErrorsCount: Integer;
begin
  ErrorsCount := 0;
  if EUserName.Text = '' then
  begin
    MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + GetLangStr('NoEmptyLogin'));
    Exit;
  end;
  if CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EUserName.Text) then
  begin
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'mysql*')) then
    begin
      // Проверка на соответствие имени БД
      if not CheckRegExprStr('^([a-zA-Z0-9\-\_]{1,})$', EIMDBName.Text) then
      begin
        MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + GetLangStr('ErrRegexprDBName'));
        Exit;
      end;
      // Удаление прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_revoke.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_revoke.sql']));
      end;
      // Удаление доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\mysql_revoke_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\mysql_revoke_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'postgresql*')) then
    begin
      // Удаление прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_revoke.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_revoke.sql']));
      end;
      // Удаление доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\postgresql_revoke_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\postgresql_revoke_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
    begin
      // Удаление прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_revoke.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_revoke.sql']));
      end;
      // Удаление доп. прав
      if CBAllowUpdateDB.Checked then
      begin
        if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\oracle_revoke_global.sql')) then
        begin
          Inc(ErrorsCount);
          MsgDie(ProgramsName, GetLangStr('ErrGrant') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\oracle_revoke_global.sql']));
        end;
      end;
    end
    else if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
    begin
      // Удаление прав
      if (not DBUpdate(ExtractFilePath(Application.ExeName) + 'sql\firebird_revoke.sql')) then
      begin
        Inc(ErrorsCount);
        MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + Format(GetLangStr('ErrSQLQueryInFile'), ['sql\firebird_revoke.sql']));
      end;
    end
    else
    begin
      MsgInf(ProgramsName, GetLangStr('ErrRevokeUnknownDBType'));
      Exit;
    end
  end
  else
  begin
    MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + GetLangStr('ErrRegexprUserName'));
    Exit;
  end;
  if ErrorsCount = 0 then
    MsgInf(ProgramsName, GetLangStr('RevokeDone'))
  else
    MsgDie(ProgramsName, GetLangStr('ErrRevoke') + ' ' + Format(GetLangStr('ErrFile'), [ErrorLogName]));
end;

{ Выполнение SQL-команд из файла }
function TMainForm.DBUpdate(SQLUpdateFile: String): Boolean;
var
  StrList: TStringList;
  StrListIndex: Integer;
  ErrCount: Integer;
  StrReplace: String;
begin
  if ZConnection1.Connected then
  begin
    ErrCount := 0;
    if FileExists(SQLUpdateFile) then
    begin
      StrList := TStringList.Create;
      StrList.Clear;
      StrList.LoadFromFile(SQLUpdateFile);
      DBUpdateProcessor.Script.Clear;
      if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
        ZConnection1.StartTransaction;
      for StrListIndex := 0 to StrList.Count-1 do
      begin
        StrReplace := StrList[StrListIndex];
        StrReplace := StringReplace(StrReplace, 'USERNAME', AnsiUpperCase(EUserName.Text), [RFReplaceall]);
        StrReplace := StringReplace(StrReplace, 'username', EUserName.Text, [RFReplaceall]);
        StrReplace := StringReplace(StrReplace, 'dbname', EIMDBName.Text, [RFReplaceall]);
        DBUpdateProcessor.Script.Add(StrReplace);
      end;
      try
        DBUpdateProcessor.Execute;
      except
        on e :
          Exception do
          begin
            {if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
              ZConnection1.Rollback;}
            Inc(ErrCount);
            if WriteErrLog then
              WriteInLog(ExtractFilePath(Application.ExeName), Format(ERR_SQL_QUERY, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
          end;
      end;
      if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
        ZConnection1.Commit;
      StrList.Free;
    end;
    if ErrCount = 0 then
      Result := True
    else
      Result := False;
    if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'firebird*')) then
      ZConnection1.Reconnect;
  end;
end;

{ Регулярка }
function TMainForm.CheckRegExprStr(RegExprStr, CheckStr: WideString): Boolean;
var
  RegExpCheck: TRegExpr;
begin
  RegExpCheck := TRegExpr.Create;
  try
    RegExpCheck.Expression := RegExprStr;
    if RegExpCheck.Exec(CheckStr) then
      Result := True
    else
      Result := False;
  finally
    RegExpCheck.Free;
  end;
end;

{ Проверка на нулевое количество записей в запросе }
function TMainForm.CheckZeroRecordCount(SQL: String): Boolean;
var
  Query: TZQuery;
  Count: Integer;
begin
  Result := True;
  if ZConnection1.Connected then
  begin
    Query := TZQuery.Create(nil);
    Query.Connection := ZConnection1;
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

{ Пишем лог SQL операций }
procedure TMainForm.ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
begin
  //ZLogList.Lines.Add(Trim(Event.AsString));
  if Trim (Event.Error) > '' then
    ZLogList.Lines.Add (DateTimeToStr(Event.Timestamp) + ': ' +
        Trim(Event.Message) + #13#10 + ' Error: ' + Event.Error)
  else
      ZLogList.Lines.Add (DateTimeToStr(Event.Timestamp) + ': ' +
        Trim(Event.Message));
  ZLogList.Lines.Add('-------------------------------');
end;

{ Очистка лога SQL операций }
procedure TMainForm.ClearLogButtonClick(Sender: TObject);
begin
  ZLogList.Clear;
end;

procedure TMainForm.LangRussianClick(Sender: TObject);
begin
  FLanguage := 'Russian';
  Lang_PM.Items[0].Checked := True;
  Lang_PM.Items[1].Checked := False;
  CoreLanguageChanged;
end;

procedure TMainForm.LangEnglishClick(Sender: TObject);
begin
  FLanguage := 'English';
  Lang_PM.Items[0].Checked := False;
  Lang_PM.Items[1].Checked := True;
  CoreLanguageChanged;
end;

{ Функция для мультиязыковой поддержки }
procedure TMainForm.CoreLanguageChanged;
var
  LangFile: String;
begin
  if CoreLanguage = '' then
    Exit;
  try
    LangFile := ExtractFilePath(Application.ExeName) + dirLangs + CoreLanguage + '.xml';
    if FileExists(LangFile) then
      LangDoc.LoadFromFile(LangFile)
    else
    begin
      if FileExists(ExtractFilePath(Application.ExeName) + dirLangs + defaultLangFile) then
        LangDoc.LoadFromFile(ExtractFilePath(Application.ExeName) + dirLangs + defaultLangFile)
      else
      begin
        MsgDie(ProgramsName, 'Not found any language file!');
        Exit;
      end;
    end;
    Global.CoreLanguage := CoreLanguage;
    SendMessage(MainFormHandle, WM_LANGUAGECHANGED, 0, 0);
    SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(ProgramsName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

{ Для мультиязыковой поддержки }
procedure TMainForm.LoadLanguageStrings;
begin
  Caption := ProgramsName;
  StepsPageControl.Pages[0].Caption := GetLangStr('Step0');
  StepsPageControl.Pages[1].Caption := GetLangStr('Step14');
  StepsPageControl.Pages[2].Caption := GetLangStr('SQLMonitor');
  RootGroupBox.Caption := GetLangStr('RootGroupBox');
  LDBType.Caption := GetLangStr('LDBType');
  LDBPort.Caption := GetLangStr('LDBPort');
  if (MatchStrings(CBDBType.Items[CBDBType.ItemIndex], 'oracle*')) then
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
  if ConnectButton.Hint = 'DisconnectButton' then
  begin
    ConnectButton.Caption := GetLangStr('DisconnectButton');
    ConnectButton.Hint := 'DisconnectButton';
  end
  else if ConnectButton.Hint = 'ConnectButton' then
  begin
    ConnectButton.Caption := GetLangStr('ConnectButton');
    ConnectButton.Hint := 'ConnectButton';
  end;
  if LYesConnect.Hint = 'LNoConnect' then
  begin
    LYesConnect.Caption := GetLangStr('LNoConnect');
    LYesConnect.Hint := 'LNoConnect';
  end
  else if LYesConnect.Hint = 'LYesConnect' then
  begin
    LYesConnect.Caption := GetLangStr('LYesConnect');
    LYesConnect.Hint := 'LYesConnect';
  end;
  DBGroupBox.Caption := GetLangStr('DBGroupBox');
  LIMDBName.Caption := GetLangStr('LIMDBName');
  CreateDBButton.Caption := GetLangStr('CreateDBButton');
  UserGroupBox.Caption := GetLangStr('UserGroupBox');
  LUserName.Caption := GetLangStr('LUserName');
  LUserPaswd.Caption := GetLangStr('LUserPaswd');
  CreateUserButton.Caption := GetLangStr('CreateUserButton');
  DeleteUserButton.Caption := GetLangStr('DeleteUserButton');
  TableGroupBox.Caption := GetLangStr('TableGroupBox');
  CreateTableDBButton.Caption := GetLangStr('CreateTableDBButton');
  DeleteTableDBButton.Caption := GetLangStr('DeleteTableDBButton');
  TableGrantGroupBox.Caption := GetLangStr('TableGrantGroupBox');
  GrantUserButton.Caption := GetLangStr('GrantUserButton');
  RevokeUserButton.Caption := GetLangStr('RevokeUserButton');
  LangButton.Caption := GetLangStr('LangButton');
  LangButton.Hint := GetLangStr('LangButton');
  AboutButton.Caption := GetLangStr('AboutButton');
  AboutButton.Hint := GetLangStr('AboutButton');
  Lang_PM.Items[0].Caption := GetLangStr('LangRussian');
  Lang_PM.Items[1].Caption := GetLangStr('LangEnglish');
  CreateINIButton.Caption := GetLangStr('CreateINIButton');
  ClearLogButton.Caption := GetLangStr('ClearLogButton');
  HelpGroupBox.Caption := GetLangStr('HelpGroupBox');
  CBAllowUpdateDB.Caption := GetLangStr('GlobalGrantOption');
  CBDropConfigTable.Caption := GetLangStr('CBDropConfigTable');
  if LHelp.Hint = 'LHelpOracle' then
  begin
    LHelp.Caption := GetLangStr('LHelpOracle');
    LHelp.Hint := 'LHelpOracle';
  end
  else if LHelp.Hint = 'LHelpSQLite' then
  begin
    LHelp.Caption := GetLangStr('LHelpSQLite');
    LHelp.Hint := 'LHelpSQLite';
  end
  else if LHelp.Hint = 'LHelpFirebird' then
  begin
    LHelp.Caption := GetLangStr('LHelpFirebird');
    LHelp.Hint := 'LHelpFirebird';
  end
  else
  begin
    LHelp.Caption := GetLangStr('LHelpEmpty');
    LHelp.Hint := 'LHelpEmpty';
  end;
  ERR_DB_CONNECT := GetLangStr('ERR_DB_CONNECT');
  ERR_NO_DB_CONNECTED := GetLangStr('ERR_NO_DB_CONNECTED');
  ERR_SQL_QUERY := GetLangStr('ERR_SQL_QUERY');
end;

end.
