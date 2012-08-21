{ ############################################################################ }
{ #                                                                          # }
{ #  ������ ������� HistoryToDBImport v2.4                                   # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Main;

{$I HistoryToDBImport.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, DateUtils, Buttons, JvAppStorage, JvAppIniStorage, JvComponentBase,
  JvFormPlacement, JvRichEdit, XPMan, XMLIntf, XMLDoc, Global, ImgList, ZSqlMonitor,
  ZAbstractConnection, ZConnection, DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, 
  Grids, DBGrids, FileCtrl, ShlObj, ActiveX, ExtCtrls, WideStrUtils, JclStringConversions,
  UnicodeFile, RegExpr, JvExStdCtrls, JvExComCtrls, JvComCtrls;

type
  THCHUNK=record              // RnQ
    Correct: Boolean;         // ������������ ������������ �����
    What: Integer;            // ��� �����
    Kind: Byte;               // ��� ���������
    UIN: Integer;             // UIN
    Time: TDateTime;          // ���� � �����
    Size: Longint;            // ������ ����� (����)
    Pos: Int64;               // ������� ����� �� ������ �����
    Msg: String;              // ���������
  end;
  PFStream = ^TFileStream;    // ��� RnQ
  pUINToNick = record         // ��� ��� ����������� ������������� UIN <-> NickName
    UIN: WideString;
    NickName: WideString;
  end;
  pUINToNickPointer = record  // ��� ��� ����������� ������������� UIN <-> NickName
    UINToNickCount: Cardinal; // ���������� �������� pUINToNick
    UINToNickPointerID: Array of pUINToNick;
  end;
  QHFHeader = record
    QHFMagic: Array[0..3] of Byte;
    QHFData:  Array[0..3] of Byte;
    QHFNull: Array[0..25] of Byte;
    QHFItems1: Array[0..3] of Byte;
    QHFItems2: Array[0..3] of Byte;
  end;
  QHFRecord = record
    RecordType: Word;
    RecordSize: DWord;
    RecordIndex:  Cardinal;
    RecordTime: DWord;
    RecordInOut:  Byte;
    RecordMessage: WideString;
  end;
  pMyTreeData = ^TMyTreeData;
    TMyTreeData = record
    Id: Integer;
    DirName: String;
    FileName: String;
  end;
  TWMCopyData = packed record
    Msg: Cardinal;
    From: HWND;
    CopyDataStruct: PCopyDataStruct;
    Result: Longint;
  end;
  TMainForm = class(TForm)
    XPManifest: TXPManifest;
    JvFormStorage1: TJvFormStorage;
    JvAppIniFileStorage1: TJvAppIniFileStorage;
    ImageList_TreeView: TImageList;
    ImageList_RichEdit: TImageList;
    MainZConnection: TZConnection;
    ZSQLMonitor1: TZSQLMonitor;
    ViewerQuery: TZQuery;
    TopPanel: TPanel;
    OpenDialog1: TOpenDialog;
    DataSource1: TDataSource;
    Splitter1: TSplitter;
    FileListView: TJvTreeView;
    GBMain: TGroupBox;
    LReciver: TLabel;
    LMessage: TLabel;
    LMessageCount: TLabel;
    LStatus: TLabel;
    LStatusTitle: TLabel;
    LReciverUIN: TLabel;
    LSelect: TLabel;
    ESelectSource: TEdit;
    ButtonSelectSource: TButton;
    EReciverNickName: TEdit;
    ButtonToSQL: TButton;
    EReciverUIN: TEdit;
    RButtonSelectDir: TRadioButton;
    RButtonSelectFile: TRadioButton;
    ImportPM: TPopupMenu;
    SelectAll: TMenuItem;
    DeSelectAll: TMenuItem;
    ImportHistoryView: TJvRichEdit;
    EMyUIN: TEdit;
    EMyNickName: TEdit;
    LMyNick: TLabel;
    LMyUIN: TLabel;
    LAddedInSQLFile: TLabel;
    LAddedInSQLFileCount: TLabel;
    PBRead: TProgressBar;
    PBWriteToDB: TProgressBar;
    NickNameQuery: TZQuery;
    ImportHistoryZConnection: TZConnection;
    ImportHistoryZQuery: TZQuery;
    StatusBar1: TStatusBar;
    CBSelectAll: TCheckBox;
    CBPreview: TCheckBox;
    CBPreviewNum: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MainZConnectionAfterConnect(Sender: TObject);
    procedure ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
    procedure CoreLanguageChanged;
    procedure AntiBoss(HideAllForms: Boolean);
    procedure LoadDBSettings;
    procedure ConnectDB;
    procedure SQL_Zeos_Exec(Sql: WideString);
    procedure ButtonSelectSourceClick(Sender: TObject);
    procedure RButtonSelectDirClick(Sender: TObject);
    procedure RButtonSelectFileClick(Sender: TObject);
    procedure ButtonToSQLClick(Sender: TObject);
    procedure CBPreviewClick(Sender: TObject);
    procedure DeSelectAllClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure FileListViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FileListViewNodeCheckedChange(Sender: TObject; Node: TJvTreeNode);
    procedure FileListViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure QHFViewChange(Sender: TObject; Node: TTreeNode);
    procedure QHFViewIconSet(Str: String; Node: TTreeNode);
    procedure AddImageToRichEdit(const AImageIndex: Integer; ImageLst: TImageList);
    procedure AddImportHistoryInList(Str: WideString; TextType: Integer);
    procedure FindHistoryFile(Dir,Ext: String; MyNode: TTreeNode);
    procedure ReadTXTData(FileName: String);
    procedure CBSelectAllClick(Sender: TObject);
    procedure AddToSQLLog;
    procedure StartReadDirectory;
    procedure QHFViewNodeCheck;
    procedure SQL_Zeos_NickName(Sql: WideString);
    procedure GetUINToNick;
    procedure ReadRnQData(FileName: String);
    procedure SQL_ImportZeos(Sql: WideString);
    procedure SelectAllFile;
    procedure DeSelectAllFile;
    function ReadTXTAndInsertDB(FileName: String): Boolean;
    function ReadQHFData(FileName: String): Boolean;
    function ReadQHFAndInsertDB(FileName: String): Boolean;
    function r32(x3: Array of Byte): DWord;
    function r16(x3: Array of Byte ): Word;
    function TakeCHUNK(Fil: TFileStream; Pos: Int64; var Res: THCHUNK): Integer;
    function FindCHUNK (Fil: TFileStream; Start: Int64): Int64;
    function RnQHistoryRead(HistFile: PFStream; RnQFileName: WideString; WriteToSQLFile: Boolean): Longint;
    function ICQ7HistoryRead(HistoryFileName: WideString): Integer;
    function CheckServiceMode: Boolean;
    function CheckZeroRecordCount(SQL: String): Boolean;
  private
    { Private declarations }
    FLanguage             : WideString;
    procedure OnControlReq(var Msg : TWMCopyData); message WM_COPYDATA;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
    FHeaderFontInTitle    : TFont;
    FHeaderFontOutTitle   : TFont;
    FHeaderFontInBody     : TFont;
    FHeaderFontOutBody    : TFont;
    FHeaderFontServiceMsg : TFont;
    IMEditorParagraph: TJvParaAttributes;
    procedure LoadQHFNicks(FileName:String);
    procedure LoadTXTNicks(FileName: String);
    procedure LoadRnQNicks(FileName: String);
    property CoreLanguage: WideString read FLanguage;
  end;

const
  SELDIRHELP = 1000;
  ImportListFile = 'HistoryToDBImport.list';

var
  MainForm: TMainForm;
  RunAppDone: Boolean;
  ProtoType: Integer;
  MainQHFList: TStringList;
  StartLoadDB, StartPreview, LoadingDone: Boolean;
  TreeNode: TTreeNode;
  UnicodeFiles: TUnicodeFile;
  UINToNickPointer: pUINToNickPointer;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  Path, CmdHelpStr: WideString;
begin
  RunAppDone := False;
  // ��� �������������� ���������
  MainFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // �������� ������� ����������
  if GetSysLang = '�������' then
  begin
    CmdHelpStr := '��������� ������� ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '------------------------------------------------------------' + #13#13 +
    'HistoryToDBImport.exe <1> <2> <3>' + #13#13 +
    '<1> - (������������ ��������) - ���� �� ����� ������� *HistoryToDB.dll, ��� �� ������ ���� ������� lang � ������� ����������� (��������: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<2> - (������������ ��������) - ���� �� ����� �������� HistoryToDB.ini (��������: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<3> - (������������ ��������) - �� ������ IM-������� ����� �������������.' + #13#13 +
    '��������� ��������:' + #13 +
    '1 - ICQ 7.x' + #13 +
    '2 - RnQ' + #13 +
    '3 - QIP 2005' + #13 +
    '4 - QIP 2010/Infium/2012' + #13#13 +
    {'5 - Miranda' + #13 +
    '6 - qutIM';}
    '<4> - (������������ ��������) - ��� UIN (��������: 123321)' + #13#13 +
    '<5> - (������������ ��������) - ���� ��� (��������: ���� ��������)';
  end
  else
  begin
    CmdHelpStr := 'Startup options ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '------------------------------------------------------' + #13#13 +
    'HistoryToDBImport.exe <1> <2> <3> <4> <5> <6> <7>' + #13#13 +
    '<1> - (Required) - The path to the plugin file *HistoryToDB.dll, there must be a directory lang files localization (Example: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<2> - (Required) - The path to the configuration file HistoryToDB.ini (Example: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<3> - (Required) - �� ������ IM-������� ����� �������������.' + #13#13 +
    '��������� ��������:' + #13 +
    '1 - ICQ 7.x' + #13 +
    '2 - RnQ' + #13 +
    '3 - QIP 2005' + #13 +
    '4 - QIP 2010/Infium/2012' + #13#13 +
    {'5 - Miranda' + #13 +
    '6 - qutIM';}
    '<4> - (Required) - Your UIN (Example: 123321)' + #13#13 +
    '<5> - (Required) - Your Name (Example: Vasua Vasilev)';
  end;
  if ParamCount < 3 then
  begin
    MsgInf(ProgramsName, CmdHelpStr);
    RunAppDone := False;
    Application.Terminate;
  end
  else
  begin
    // �������� ������� ����������
    PluginPath := ParamStr(1);
    ProfilePath := ParamStr(2);
    if IsNumber(ParamStr(3)) then
      if (StrToInt(ParamStr(3)) > 0) and (StrToInt(ParamStr(3)) < 5) then
        HistoryImportType := StrToInt(ParamStr(3))
      else
      begin
        MsgInf(ProgramsName, CmdHelpStr);
        RunAppDone := False;
        Application.Terminate;
      end
    else
    begin
      MsgInf(ProgramsName, CmdHelpStr);
      RunAppDone := False;
      Application.Terminate;
    end;
    if ParamStr(4) <> '' then
      Global_CurrentAccountUIN := ParamStr(4)
    else
    begin
      MsgInf(ProgramsName, CmdHelpStr);
      RunAppDone := False;
      Application.Terminate;
    end;
    if ParamStr(5) <> '' then
      Global_CurrentAccountName := ParamStr(5)
    else
    begin
      MsgInf(ProgramsName, CmdHelpStr);
      RunAppDone := False;
      Application.Terminate;
    end;
    // ��������� ������� �������� � ����� ���������
    if not DirectoryExists(ProfilePath) then
      CreateDir(ProfilePath);
    Path := ProfilePath + ININame;
    if not FileExists(Path) then
    begin
      MsgInf(ProgramsName, CmdHelpStr);
      RunAppDone := False;
      Application.Terminate;
    end;
    // ��������� �����
    JvAppIniFileStorage1.FileName := ProfilePath + 'HistoryToDBForms.ini';
    // ������������� �����������
    EncryptInit;
    // ������������� ����� ��� ������ � JvRichEdit
    FHeaderFontInTitle := TFont.Create;
    FHeaderFontInTitle.Name := 'Verdana';
    FHeaderFontInTitle.Size := 8;
    FHeaderFontInTitle.Color := TColor($0000b7);
    FHeaderFontInTitle.Style := [fsBold];
    FHeaderFontOutTitle := TFont.Create;
    FHeaderFontOutTitle.Name := 'Verdana';
    FHeaderFontOutTitle.Size := 8;
    FHeaderFontOutTitle.Color := TColor($804000);
    FHeaderFontOutTitle.Style := [fsBold];
    FHeaderFontInBody := TFont.Create;
    FHeaderFontInBody.Name := 'Verdana';
    FHeaderFontInBody.Size := 8;
    FHeaderFontOutBody := TFont.Create;
    FHeaderFontOutBody.Name := 'Verdana';
    FHeaderFontOutBody.Size := 8;
    FHeaderFontServiceMsg := TFont.Create;
    FHeaderFontServiceMsg.Name := 'Verdana';
    FHeaderFontServiceMsg.Size := 8;
    FHeaderFontServiceMsg.Color := clRed;
    FHeaderFontServiceMsg.Style := [fsBold];
    IMEditorParagraph := TJvParaAttributes.Create(ImportHistoryView);
    // ������ ���������
    LoadINI(ProfilePath, True);
    // ��������� ���-�����
    ErrLogOpened := OpenLogFile(ProfilePath, 1);
    if EnableDebug then
      DebugLogOpened := OpenLogFile(ProfilePath, 2)
    else
      DebugLogOpened := False;
    // ������������� ��������� ���������� � ��
    LoadDBSettings;
    // ��������� ��������� �����������
    FLanguage := DefaultLanguage;
    LangDoc := NewXMLDocument();
    if not DirectoryExists(PluginPath + dirLangs) then
      CreateDir(PluginPath + dirLangs);
    CoreLanguageChanged;
    LoadLanguageStrings;
    // ������������ SQL ��������
    if EnableDebug then
    begin
      //ZSQLMonitor1.FileName := ProfilePath + DebugLogName;
      ZSQLMonitor1.Active := True;
    end;
    UnicodeFiles := TUnicodeFile.Create(Self);
    UINToNickPointer.UINToNickCount := 0;
    // ��������� ��������
    RunAppDone := True;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ���������� ��� ������ ����-����
  Global_MainForm_Showing := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if RunAppDone then
  begin
    // ��������� ���-�����
    if ErrLogOpened then
      CloseLogFile(1);
    if DebugLogOpened then
      CloseLogFile(2);
    // ����������� �������
    FHeaderFontInTitle.Free;
    FHeaderFontOutTitle.Free;
    FHeaderFontInBody.Free;
    FHeaderFontOutBody.Free;
    FHeaderFontServiceMsg.Free;
    IMEditorParagraph.Free;
    MainQHFList.Free;
    UnicodeFiles.Free;
    DeleteFile(ProfilePath + ImportListFile);
    EncryptFree;
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AntiBoss(True);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  // ���������� ��� ������ ����-����
  Global_MainForm_Showing := True;
  // ���� ���������� ����������� � ����������� �����������
  if RunAppDone then
  begin
    // ������������ ����
    AlphaBlend := AlphaBlendEnable;
    AlphaBlendValue := AlphaBlendEnableValue;
    // ������� TStringList ��� ������ ����������� � �� ������
    MainQHFList := TStringList.Create;
    // End
    // ��������� JvTreeView
    FileListView.ReadOnly := True;
    FileListView.ShowLines := False;
    FileListView.ShowButtons := False;
    FileListView.Checkboxes := True;
    FileListView.HideSelection := False;
    FileListView.Images := ImageList_TreeView;
    // ������
    ButtonToSQL.Enabled := False;
    ButtonSelectSource.Enabled := False;
    StartLoadDB := False;
    StartPreview := False;
    LoadingDone := True;
    // ��������� ���� "��� Nickname" � "��� UserID" � ��������� �� ��������������
    EMyNickName.ReadOnly := True;
    EMyNickName.Text := Global_CurrentAccountName;
    EMyNickName.Color := clWindow;
    EMyUIN.ReadOnly := True;
    EMyUIN.Text := Global_CurrentAccountUIN;
    EMyUIN.Color := clWindow;
    // ��������� �������������� ����� "����������" � "UserID"
    EReciverNickName.ReadOnly := True;
    EReciverUIN.ReadOnly := True;
    EReciverNickName.Color := clWindow;
    EReciverUIN.Color := clWindow;
    // End
    CBSelectAll.Checked := False;
    CBSelectAll.Enabled := False;
    // ��������� ������ ������� �� 1 ����� ��� �� ����������
    if HistoryImportType = 1 then       // ICQ7
    begin
      RButtonSelectDir.Enabled := False;
      RButtonSelectFile.Checked := True;
      CBPreview.Enabled := False;
      CBPreviewNum.Enabled := False;
      CBPreviewNum.ItemIndex := 0;
      RButtonSelectFileClick(RButtonSelectFile);
    end
    else if HistoryImportType = 2 then  // RnQ
    begin
      RButtonSelectDir.Enabled := True;
      RButtonSelectFile.Checked := False;
      RButtonSelectDir.Checked := False;
      CBPreview.Enabled := True;
      CBPreviewNum.Enabled := False;
      CBPreviewNum.ItemIndex := 0;
      ESelectSource.Text := '';
      // ��������� ��������� UIN <> Nickname
      GetUINToNick;
    end                                 // QIP
    else
    begin
      RButtonSelectDir.Enabled := True;
      RButtonSelectFile.Checked := False;
      RButtonSelectDir.Checked := False;
      ESelectSource.Text := '';
      CBPreview.Enabled := True;
      CBPreviewNum.Enabled := False;
      CBPreviewNum.ItemIndex := 0;
    end;
  end;
end;

{ ������������ � �� � ���������� ������ }
procedure TMainForm.ConnectDB;
begin
  // ������������ � ����
  if not MainZConnection.Connected then
  begin
    try
      MainZConnection.Connect;
    except
      on e :
        Exception do
        begin
          AddImportHistoryInList(Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 3);
          ImportHistoryView.Refresh;
          if WriteErrLog then
            WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
          MainZConnection.Disconnect;
          Exit;
        end
    end;
  end;
end;

{ ���������� ������� � �� }
procedure TMainForm.SQL_Zeos_Exec(Sql: WideString);
begin
    try
      if MainZConnection.Connected then
        begin
          ViewerQuery.Connection := MainZConnection;
          try
            ViewerQuery.Close;
            ViewerQuery.SQL.Clear;
            ViewerQuery.SQL.Text := Sql;
            ViewerQuery.ExecSQL;
          except
            on e :
              Exception do
              begin
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
                MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrSQLExecQuery') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
              end;
          end;
        end;
    except
      on e :
        Exception do
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
    end;
end;

{ ������������� ��������� ����������� � �� }
procedure TMainForm.LoadDBSettings;
begin
  MainZConnection.Protocol := DBType;
  if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
  begin
    MainZConnection.HostName := '';
    MainZConnection.Port := 0;
    MainZConnection.User := '';
    MainZConnection.Password := '';
    MainZConnection.Properties.Clear;
  end
  else // MySQL, PostgreSQL, Oracle � �.�.
  begin
    MainZConnection.HostName := DBAddress;
    MainZConnection.Port := StrToInt(DBPort);
    MainZConnection.User := DBUserName;
    MainZConnection.Password := DBPasswd;
    MainZConnection.Properties.Clear;
    MainZConnection.Properties.Add('codepage=UTF8');
  end;
  // ������ ��������� � ������ DBName
  if MatchStrings(DBName,'<ProfilePluginPath>*') then
    DBName := StringReplace(DBName,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
  else if MatchStrings(DBName,'<PluginPath>*') then
    DBName := StringReplace(DBName,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall]);
  // End
  MainZConnection.Database := DBName;
  MainZConnection.LoginPrompt := false;
end;

{ ����������� ����� MainZConnection.Connection
  ��� ����� ����� � �� Oracle }
procedure TMainForm.MainZConnectionAfterConnect(Sender: TObject);
begin
  if (MainZConnection.Protocol = 'oracle') or (MainZConnection.Protocol = 'oracle-9i') then
    SQL_Zeos_Exec('alter session set current_schema='+DBSchema);
  // �������� �� ��������� �����
  if CheckServiceMode then
    MainZConnection.Disconnect;
end;

{ ������������ SQL �������� ��� ������� }
procedure TMainForm.ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
begin
  if EnableDebug then
  begin
    if Trim(Event.Error) > '' then
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - ��������� ZSQLMonitor1Trace: ' + Trim(Event.Message) + ' | Error: ' + Event.Error, 2)
    else
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - ��������� ZSQLMonitor1Trace: ' + Trim(Event.Message), 2);
  end;
end;

{ �������� �� ��������� ����� }
function TMainForm.CheckServiceMode: Boolean;
var
  Query: TZQuery;
  System_Disable: Integer;
begin
  Result := False;
  if MainZConnection.Connected then
  begin
    Query := TZQuery.Create(nil);
    Query.Connection := MainZConnection;
    Query.SQL.Clear;
    Query.SQL.Text := 'select config_value from config where config_name = ''system_disable''';
    try
      Query.Open;
      System_Disable := Query.FieldByName('config_value').AsInteger;
      Query.Close;
      if System_Disable = 1 then
      begin
        AddImportHistoryInList(Format(ERR_READ_DB_SERVICE_MODE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 2);
        ImportHistoryView.Refresh;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CheckServiceMode: �� �� ��������� ������������.', 2);
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_SERVICE_MODE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
        Result := True;
      end
      else
        Result := False;
    finally
      Query.Free;
    end;
  end
  else
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� CheckServiceMode: ���������� � �� �� �����������.', 2);
end;

{ �������� �� ������� ���������� ������� � ������� }
function TMainForm.CheckZeroRecordCount(SQL: String): Boolean;
var
  Query: TZQuery;
  Count: Integer;
begin
  Result := True;
  if MainZConnection.Connected then
  begin
    Query := TZQuery.Create(nil);
    Query.Connection := MainZConnection;
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

{ ��������� ������ ����-���� }
procedure TMainForm.AntiBoss(HideAllForms: Boolean);
begin
  if not Assigned(MainForm) then Exit;
  if HideAllForms then
  begin
    ShowWindow(MainForm.Handle, SW_HIDE);
    MainForm.Hide;
  end
  else
  begin
    // ���� ����� ���� ����� �������, �� ���������� �
    if Global_MainForm_Showing then
    begin
      ShowWindow(MainForm.Handle, SW_SHOW);
      MainForm.Show;
      // ���� ����� ��������, �� ������������� � ������ ���� ����
      if MainForm.WindowState = wsMinimized then
      begin
        MainForm.FormStyle := fsStayOnTop;
        MainForm.WindowState := wsNormal;
        MainForm.FormStyle := fsNormal;
      end;
      if MainForm.WindowState = wsNormal then
      begin
        MainForm.FormStyle := fsStayOnTop;
        MainForm.FormStyle := fsNormal;
      end;
    end;
  end;
end;

procedure TMainForm.ButtonSelectSourceClick(Sender: TObject);
var
  DirName: String;
begin
  if RButtonSelectDir.Checked then
  begin
    if AdvSelectDirectory(GetLangStr('ImportAdvSelectDirectory'), ESelectSource.Text, DirName, False, False, False) then
    begin
      ESelectSource.Text := DirName;
      StartReadDirectory;
    end
    else
      Exit;
  end;
  if RButtonSelectFile.Checked then
  begin
    if HistoryImportType = 1 then      // ICQ7
    begin
      // ��������� �������������� ����� "����������" � "UserID"
      EReciverNickName.ReadOnly := True;
      EReciverUIN.ReadOnly := True;
      EReciverNickName.Color := clBtnFace;
      EReciverUIN.Color := clBtnFace;
      EReciverUIN.Text := '-';
      EReciverNickName.Text := '-';
    end
    else                               // QIP � RnQ
    begin
      // ��������� �������������� ����� "����������" � "UserID"
      EReciverNickName.ReadOnly := False;
      EReciverUIN.ReadOnly := False;
      EReciverNickName.Color := clSkyBlue;
      EReciverUIN.Color := clSkyBlue;
      EReciverUIN.Text := '';
      EReciverNickName.Text := '';
    end;
    // ��������� �������������� ����� "��� Nickname" � "��� UserID"
    EMyUIN.ReadOnly := False;
    EMyNickName.ReadOnly := False;
    EMyUIN.Color := clSkyBlue;
    EMyNickName.Color := clSkyBlue;
    // End
    OpenDialog1.Title := GetLangStr('ImportOpenHistoryFile');
    if HistoryImportType = 1 then // ICQ 7
    begin
      OpenDialog1.Filter := GetLangStr('ImportICQHistoryFile') + '|Messages.qdb';
      OpenDialog1.FileName := '';
    end;
    if HistoryImportType = 2 then // RnQ
    begin
      OpenDialog1.Filter := GetLangStr('ImportRnQHistoryFile') + '|*.*';
      OpenDialog1.FileName := '';
    end
    else if HistoryImportType = 3 then // QIP 2005
    begin
      OpenDialog1.Filter := GetLangStr('ImportQIPHistoryTXTFile') + '|*.txt';
      OpenDialog1.FileName := '';
    end
    else if HistoryImportType = 4 then // 2010/Infium/2012
    begin
      OpenDialog1.Filter := GetLangStr('ImportQIPHistoryAllQHFFile') + '|*.qhf;*.ahf|' + GetLangStr('ImportQIPHistoryQHFFile') + '|*.qhf|' + GetLangStr('ImportQIPHistoryQHFArcFile') + '|*.ahf';
      OpenDialog1.FileName := '';
    end;
    if OpenDialog1.Execute then
    begin
      ESelectSource.Text := OpenDialog1.FileName;
      if HistoryImportType = 2 then           // RnQ
        LoadRnQNicks(OpenDialog1.FileName)
      else if HistoryImportType = 3 then      // QIP 2005
        LoadTXTNicks(OpenDialog1.FileName)
      else if HistoryImportType = 4 then      // QIP 2010/Infium/2012
        LoadQHFNicks(OpenDialog1.FileName);
      StartReadDirectory;
    end;
  end;
end;

{ ��������� ������ ���������� ���������� � ������� ������ ������ }
procedure TMainForm.StartReadDirectory;
var
  Node: TTreeNode;
  Data: pMyTreeData;
  FileName: String;
begin
  PBWriteToDB.Position := 0;
  FileListView.PopupMenu := ImportPM;
  DeleteFile(ProfilePath + ImportListFile);
  FileListView.Items.BeginUpdate;
  FileListView.Items.Clear;
  if RButtonSelectDir.Checked then
  begin
    if HistoryImportType = 2 then       // RnQ
      FindHistoryFile(ESelectSource.Text, '*', Node)
    else if HistoryImportType = 3 then  // QIP 2005
      FindHistoryFile(ESelectSource.Text, '*.txt', Node)
    else if HistoryImportType = 4 then  // QIP 2010/Infium/2012
    begin
      FindHistoryFile(ESelectSource.Text, '*.ahf', Node);
      FindHistoryFile(ESelectSource.Text, '*.qhf', Node);
    end;
    FileListView.ControlStyle := FileListView.ControlStyle + [csOpaque];
  end;
  if RButtonSelectFile.Checked then
  begin
    FileName := ExtractFileNameEx(ESelectSource.Text, True);
    New(Data);
    Data.Id := 0;
    Data.DirName := '';
    Data.FileName := FileName;
    TreeNode := FileListView.Items.AddChildObject(Node, FileName, Data);
    QHFViewIconSet(FileName, TreeNode); // ���������� �������� � ������ ������
    FileListView.ControlStyle := FileListView.ControlStyle + [csOpaque];
    PBRead.Position := 0;
    if CBPreview.Checked then
    begin
      ImportHistoryView.Clear;
      ImportHistoryView.Refresh;
      if HistoryImportType = 3 then       // QIP 2005
        ReadTXTData(ESelectSource.Text)
      else  if HistoryImportType = 4 then // QIP Infium
      begin
        if not ReadQHFData(ESelectSource.Text) then
          MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + ESelectSource.Text)
      end;
    end;
  end;
  FileListView.Items.EndUpdate;
  if FileListView.Items.Count > 0 then
    CBSelectAll.Enabled := True
  else
    CBSelectAll.Enabled := False;
end;

{ ��������� ������ ������ �� ����� � ������������ �� ������ }
procedure TMainForm.FindHistoryFile(Dir, Ext: String; MyNode: TTreeNode);
var
  Data: pMyTreeData;
  SR: TSearchRec;
begin
  if FindFirst(Dir + '\*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // ����� �� ���� ������ . � ..
      begin
        Continue; // ���������� ����
      end;
      if MatchStrings(SR.Name, Ext) then
      begin
        // ��������� ����
        New(Data);
        Data.Id := 0;
        Data.DirName := Dir;
        Data.FileName := SR.Name;
        TreeNode := FileListView.Items.AddChildObject(MyNode, SR.Name, Data);
        QHFViewIconSet(SR.Name, TreeNode); // ���������� �������� � ������ ������
      end;
      if (SR.Attr = faDirectory) then // ���� ����� ����������, �� ���� ����� � ���
      begin
        FindHistoryFile(Dir + '\' + SR.Name, Ext, MyNode); // P��������� �������� ���� ���������
        Continue; // ���������� ����
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

{ ��������� ������� � ������ HistoryToDBImport.list ���������� ����� }
procedure TMainForm.FileListViewNodeCheckedChange(Sender: TObject; Node: TJvTreeNode);
var
 I: Integer;
 LS: TStringList;
 HistoryFile, HistoryDir: String;
begin
  LS := TStringList.Create;
  LS.Clear;
  if Node.Checked = True then
    Node.StateIndex := 2
  else
    Node.StateIndex := 1;
  for I:=0 to FileListView.Items.Count-1 do
  begin
    if FileListView.Items[I].StateIndex = 2 then
    begin
      HistoryFile := pMyTreeData(FileListView.Items[I].Data)^.FileName;
      HistoryDir := pMyTreeData(FileListView.Items[I].Data)^.DirName;
      if RButtonSelectDir.Checked then
        LS.Add(HistoryDir + '\' + HistoryFile)
      else if RButtonSelectFile.Checked then
        LS.Add(ExtractFilePath(ESelectSource.Text) + HistoryFile);
    end;
  end;
  LS.SaveToFile(ProfilePath + ImportListFile);
  if LS.Count > 0 then
    ButtonToSQL.Enabled := True
  else
    ButtonToSQL.Enabled := False;
  LS.Free;
end;

{ ��������� ��������� ���������� � ������ ����� }
procedure TMainForm.FileListViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with FileListView.Canvas do
    if cdsSelected in State then
    begin
      Brush.Color:= TColor($f5ddc7);  //fbf1e8
      Font.Color := clBlack;
    end;
end;

procedure TMainForm.FileListViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  Dispose(Node.Data)
end;

{ ���� �� �������� �� QHFView }
procedure TMainForm.QHFViewChange(Sender: TObject; Node: TTreeNode);
var
  FileName, DirName: String;
begin
  if (FileListView.Selected <> nil) and (Node.Data <> nil) then
  begin
    FileName := pMyTreeData(Node.Data)^.FileName;
    DirName := pMyTreeData(Node.Data)^.DirName;
    if HistoryImportType = 2 then            // RnQ
      LoadRnQNicks(DirName + '\' + FileName)
    else if HistoryImportType = 3 then       // QIP 2005
      LoadTXTNicks(DirName + '\' + FileName)
    else if HistoryImportType = 4 then       // QIP 2010/Infium/2012
      LoadQHFNicks(DirName + '\' + FileName);
    LStatus.Caption := Format(GetLangStr('ImportSelectHistoryFile'), [FileName]);
    LStatus.Hint := 'ImportSelectHistoryFile';
    PBRead.Position := 0;
    if (CBPreview.Checked) and (not StartLoadDB) then
    begin
      ImportHistoryView.Clear;
      ImportHistoryView.Refresh;
      // ��������� ������� �� �����
      if HistoryImportType = 2 then            // RnQ
        ReadRnQData(DirName + '\' + FileName)
      else if HistoryImportType = 3 then       // QIP 2005
        ReadTXTData(DirName + '\' + FileName)
      else if HistoryImportType = 4 then       // QIP 2010/Infium/2012
      begin
        if not ReadQHFData(DirName + '\' + FileName) then
          MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + DirName + '\' + FileName)
      end;
    end;
  end;
end;

{ ��������� ��������� ������ ��� ������ ������ }
procedure TMainForm.QHFViewIconSet(Str: String; Node: TTreeNode);
var
  ProtocolRegExp: TRegExpr;
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
  if HistoryImportType = 1 then       // ICQ7
  begin
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
  end
  else if HistoryImportType = 2 then  // RnQ
  begin
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
  end
  else                                // QIP
  begin
    if MatchStrings(Str, '*InfICQ*') then
    begin
      Node.ImageIndex := 2;
      Node.SelectedIndex := 2;
    end
    else if IsNumber(ExtractFileNameEx(Str, False)) and (HistoryImportType = 3) then // QIP 2005
    begin
      Node.ImageIndex := 2;
      Node.SelectedIndex := 2;
    end
    else if MatchStrings(Str, '*gmail.com*') then
    begin
      Node.ImageIndex := 3;
      Node.SelectedIndex := 3;
    end
    else if MatchStrings(Str, '*MRA*') then
    begin
      Node.ImageIndex := 4;
      Node.SelectedIndex := 4;
    end
    else if MatchStrings(Str, '*jabberqip*') then
    begin
      Node.ImageIndex := 6;
      Node.SelectedIndex := 6;
    end
    else if MatchStrings(Str, '*@qip.ru*') then
    begin
      Node.ImageIndex := 6;
      Node.SelectedIndex := 6;
    end
    else if (MatchStrings(Str, '*vk.com*')) or (MatchStrings(Str, '*vkontakte.ru*')) then
    begin
      Node.ImageIndex := 8;
      Node.SelectedIndex := 8;
    end
    else if MatchStrings(Str, '*Jabber*') then
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := 5;
    end
    else if MatchStrings(Str, '*jabber*') then
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := 5;
    end
    else if MatchStrings(Str, '*facebook.com*') then
    begin
      Node.ImageIndex := 7;
      Node.SelectedIndex := 7;
    end
    else if MatchStrings(Str, '*twitter.com*') then
    begin
      Node.ImageIndex := 9;
      Node.SelectedIndex := 9;
    end
    else if (MatchStrings(Str, '*Social*')) then
    begin
      Node.ImageIndex := 10;
      Node.SelectedIndex := 10;
    end
    else
    begin
      Node.ImageIndex := 11;
      Node.SelectedIndex := 11;
    end;
  end;
end;

{ �������� ��������� ������� ������� }
procedure TMainForm.AddToSQLLog;
var
  I: Integer;
  Noddy: TTreeNode;
  Searching: Boolean;
  SrcFile: TFileStream;
  RnQAllMsgCount, RnQMsgCount: Integer;
  MsgStr: WideString;
begin
  if FileExists(ProfilePath + ImportListFile) then
  begin
    ImportHistoryView.Clear;
    ImportHistoryView.Refresh;
    if HistoryImportType = 1 then             // ICQ7
      MsgStr := GetLangStr('ImportICQStart')
    else if HistoryImportType = 2 then        // RnQ
      MsgStr := GetLangStr('ImportRnQStart')
    else if HistoryImportType = 3 then        // QIP 2005
      MsgStr := GetLangStr('ImportTXTStart')
    else if HistoryImportType = 4 then        // QIP 2010/Infium/2012
      MsgStr := GetLangStr('ImportQHFStart');
    AddImportHistoryInList(MsgStr, 4);
    MainQHFList.Clear;
    MainQHFList.LoadFromFile(ProfilePath + ImportListFile);
    if MainQHFList.Count > 0 then
    begin
      // ���������� HistoryToDBSync �������, ��� ������� ������ �������
      OnSendMessageToAllComponent('0060');
      AddImportHistoryInList(Format(GetLangStr('SendStopSync'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ImportLogName]), 4);
      // ��������� ���� ��� �������
      ImportLogOpened := OpenLogFile(ProfilePath, 4);
      if ImportLogOpened then
      begin
        // ���������������� � �������
        StartLoadDB := True;
        ButtonToSQL.Caption := GetLangStr('ImportStop');
        ButtonToSQL.Hint := 'ImportStop';
        AddImportHistoryInList(Format(GetLangStr('ImportSelectCnt'), [IntToStr(MainQHFList.Count)]), 4);
        PBWriteToDB.Position := 0;
        PBWriteToDB.Max := MainQHFList.Count-1;
        RnQAllMsgCount := 0;
        RnQMsgCount := 0;
        // ������ �� ����� ������ ������ �������
        for I:=0 to MainQHFList.Count-1 do
        begin
          if StartLoadDB then
          begin
            AddImportHistoryInList(Format(GetLangStr('ImportProcessing'), [MainQHFList.Strings[I]]), 4);
            PBRead.Position := 0;
            if HistoryImportType <> 2 then // QIP
              LMessageCount.Caption := '0';
            // �������� ����� ���� ������ ��������������
            Noddy := FileListView.Items[0];
            Searching := true;
            while (Searching) and (Noddy <> nil) do
            begin
              if Noddy.Text = ExtractFileNameEx(MainQHFList.Strings[I], True) then
              begin
                Searching := False;
                FileListView.Selected := Noddy;
                FileListView.SetFocus;
              end
              else
              begin
                Noddy := Noddy.GetNext
              end;
            end;
            // End
            if HistoryImportType = 1 then      // ICQ7
            begin
              ICQ7HistoryRead(MainQHFList.Strings[I]);
              AddImportHistoryInList(Format(GetLangStr('ImportProcessingDone'), [MainQHFList.Strings[I]]), 4)
            end
            else if HistoryImportType = 2 then // RnQ
            begin
              SrcFile := TFileStream.Create(MainQHFList.Strings[I], fmOpenRead);
              try
                if StartPreview then
                  StartPreview := False
                else
                  StartPreview := True;
                RnQMsgCount := RnQHistoryRead(@SrcFile, MainQHFList.Strings[I], True);
                StartPreview := False;
                AddImportHistoryInList(Format(GetLangStr('ImportDoneCnt'), [IntToStr(RnQMsgCount)]), 4);
                RnQAllMsgCount := RnQAllMsgCount + RnQMsgCount;
                LMessageCount.Caption := IntToStr(RnQAllMsgCount);
              finally
                SrcFile.Free;
              end;
              AddImportHistoryInList(Format(GetLangStr('ImportProcessingDone'), [MainQHFList.Strings[I]]), 4)
            end
            else if HistoryImportType = 3 then // QIP 2005
            begin
              if ReadTXTAndInsertDB(MainQHFList.Strings[I]) then
                AddImportHistoryInList(Format(GetLangStr('ImportProcessingDone'), [MainQHFList.Strings[I]]), 4)
              else
                MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + MainQHFList.Strings[I]);
            end
            else if HistoryImportType = 4 then // QIP Infium
            begin
              if ReadQHFAndInsertDB(MainQHFList.Strings[I]) then
                AddImportHistoryInList(Format(GetLangStr('ImportProcessingDone'), [MainQHFList.Strings[I]]), 4)
              else
                MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + MainQHFList.Strings[I]);
            end;
            // ������� ���-���� � ������������� �����.
            // �� ���� �� ������ ����� �� ������.
            // ��� ���������� ������ ������� �������,
            // ��� ���� ���������� ������ � ����� for.
            Noddy := FileListView.Items[0];
            Searching := true;
            while (Searching) and (Noddy <> nil) do
            begin
              if Noddy.Text = ExtractFileNameEx(MainQHFList.Strings[I], True) then
              begin
                Searching := False;
                Noddy.StateIndex := 1;
              end
              else
              begin
                Noddy := Noddy.GetNext
              end;
            end;
            // �������������� HistoryToDBImport.list � ������ ������ ���-������
            QHFViewNodeCheck;
            // �������� �������
            PBWriteToDB.Position := PBWriteToDB.Position + 1;
          end
          else
          begin
            LStatus.Caption := Format(GetLangStr('ImportStoped'), ['AddToSQLLog']);
            LStatus.Hint := 'ImportStoped';
            ButtonToSQL.Enabled := True;
            Exit;
          end;
        end;
        LStatus.Caption := GetLangStr('ImportDone');
        LStatus.Hint := 'ImportDone';
        CloseLogFile(4);
      end;
      StartLoadDB := False;
      if HistoryImportType = 2 then // RnQ
        LAddedInSQLFileCount.Caption := IntToStr(RnQAllMsgCount);
      ButtonToSQL.Caption := GetLangStr('ImportButtonToSQL');
      ButtonToSQL.Hint := 'ImportButtonToSQL';
      if HistoryImportType <> 1 then // ICQ7
        CBPreview.Enabled := True;
      RButtonSelectDir.Enabled := True;
      RButtonSelectFile.Enabled := True;
      ButtonSelectSource.Enabled := True;
      ESelectSource.Enabled := True;
      // ������� HistoryToDBImport.list
      DeleteFile(ProfilePath + ImportListFile);
      // ������� ���-�����
      DeSelectAllClick(Self);
      // ���������� HistoryToDBSync �������, ��� ������ ������� ��������
      OnSendMessageToAllComponent('0061');
      AddImportHistoryInList(Format(GetLangStr('SendStartSync'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ImportLogName]), 4);
      // ������� ��������� �� ��������� �������
      AddImportHistoryInList(GetLangStr('ImportDoneSyncWait'), 4);
      MsgInf(MainForm.Caption, GetLangStr('ImportDoneSyncWait'));
    end
    else
      MsgInf(MainForm.Caption, GetLangStr('ImportSelectFile'));
  end
  else
      MsgInf(MainForm.Caption, GetLangStr('ImportSelectFile'));
end;

procedure TMainForm.ButtonToSQLClick(Sender: TObject);
begin
  if not StartLoadDB then
  begin
    CBPreview.Checked := False;
    CBPreview.Enabled := False;
    CBPreviewNum.Enabled := False;
    CBPreviewNum.ItemIndex := 0;
    StartPreview := False;
    RButtonSelectDir.Enabled := False;
    RButtonSelectFile.Enabled := False;
    ButtonSelectSource.Enabled := False;
    ESelectSource.Enabled := False;
    // ��������� ������ �������
    AddToSQLLog;
  end
  else
  begin
    StartLoadDB := False;
    ButtonToSQL.Caption := GetLangStr('ImportProceed');
    ButtonToSQL.Hint := 'ImportProceed';
    ButtonToSQL.Enabled := False;
  end;
end;

procedure TMainForm.CBPreviewClick(Sender: TObject);
begin
  if CBPreview.Checked then
  begin
    if (HistoryImportType = 1) or (HistoryImportType = 2) or (HistoryImportType = 3) then // ICQ7 ��� Rnq ��� QIP 2005
    begin
      CBPreviewNum.Enabled := False;
      CBPreviewNum.ItemIndex := 6;
    end
    else
      CBPreviewNum.Enabled := True;
  end
  else
    CBPreviewNum.Enabled := False;
  StartPreview := False;
  ImportHistoryView.Clear;
  ImportHistoryView.Refresh;
end;

procedure TMainForm.CBSelectAllClick(Sender: TObject);
begin
  if CBSelectAll.Checked then
    SelectAllFile
  else
    DeSelectAllFile;
end;

{ ��������� �������� � QHFView � ����� ���������� � HistoryToDBImport.list }
procedure TMainForm.QHFViewNodeCheck;
var
 I: Integer;
 LS: TStringList;
 HistoryFile: String;
begin
  LS := TStringList.Create;
  LS.Clear;
  for I:=0 to FileListView.Items.Count-1 do
  begin
    if FileListView.Items[I].StateIndex = 2 then
    begin
      HistoryFile := pMyTreeData(FileListView.Items[I].Data)^.FileName;
      if RButtonSelectDir.Checked then
        LS.Add(ESelectSource.Text + '\' + HistoryFile)
      else if RButtonSelectFile.Checked then
        LS.Add(ExtractFilePath(ESelectSource.Text) + HistoryFile);
    end;
  end;
  LS.SaveToFile(ProfilePath + ImportListFile);
  if LS.Count > 0 then
    ButtonToSQL.Enabled := True
  else
    ButtonToSQL.Enabled := False;
  LS.Free;
end;

{ ������� ��� ���-����� }
procedure TMainForm.DeSelectAllClick(Sender: TObject);
begin
  DeSelectAllFile;
  CBSelectAll.Checked := False;
end;

{ ������ ��� ���-����� }
procedure TMainForm.SelectAllClick(Sender: TObject);
begin
  SelectAllFile;
  CBSelectAll.Checked := True;
end;

procedure TMainForm.DeSelectAllFile;
var
  J: Integer;
begin
  FileListView.SetFocus;
  for J:=0 to FileListView.Items.Count-1 do
    FileListView.Items[J].StateIndex := 1;
  // ������� HistoryToDBImport.list
  DeleteFile(ProfilePath + ImportListFile);
  ButtonToSQL.Enabled := False;
end;

procedure TMainForm.SelectAllFile;
var
  J: Integer;
  LS: TStringList;
  HistoryFile, HistoryDir: String;
begin
  LS := TStringList.Create;
  LS.Clear;
  FileListView.SetFocus;
  for J:=0 to FileListView.Items.Count-1 do
  begin
    HistoryFile := pMyTreeData(FileListView.Items[J].Data)^.FileName;
    HistoryDir := pMyTreeData(FileListView.Items[J].Data)^.DirName;
    if (not MatchStrings(HistoryFile, '*qip_svc*')) or (not MatchStrings(HistoryFile, '*.bak'))  then
    begin
      FileListView.Items[J].StateIndex := 2;
      if RButtonSelectDir.Checked then
        LS.Add(HistoryDir + '\' + HistoryFile)
      else if RButtonSelectFile.Checked then
        LS.Add(ExtractFilePath(ESelectSource.Text) + HistoryFile);
    end;
  end;
  LS.SaveToFile(ProfilePath + ImportListFile);
  if LS.Count > 0 then
    ButtonToSQL.Enabled := True
  else
    ButtonToSQL.Enabled := False;
  LS.Free;
end;

procedure TMainForm.RButtonSelectDirClick(Sender: TObject);
begin
  StartLoadDB := False;
  StartPreview := False;
  EReciverNickName.Text := '';
  EReciverUIN.Text := '';
  LMessageCount.Caption := '0';
  LAddedInSQLFileCount.Caption := '0';
  LStatus.Caption := GetLangStr('ImportLStatusUnknown');
  LStatus.Hint := 'ImportLStatusUnknown';
  if HistoryImportType = 2 then       // RnQ
     ESelectSource.Text := ProfilePath + 'history\'
  else if HistoryImportType = 3 then  // QIP 2005
    ESelectSource.Text := RemoveInvalidStr('Plugins\QIPHistoryToDB', ProfilePath)// + 'Plugins\sHistory\'
  else if HistoryImportType = 4 then  // QIP 2010/Infium/2012
    ESelectSource.Text := RemoveInvalidStr('Plugins\QIPHistoryToDB', ProfilePath) + 'History\';
  PBRead.Position := 0;
  PBWriteToDB.Position := 0;
  ButtonToSQL.Enabled := False;
  LSelect.Caption := GetLangStr('ImportLSelectSelectDir');
  LSelect.Hint := 'ImportLSelectSelectDir';
  ButtonSelectSource.Caption := GetLangStr('ImportButtonSelectSourceDir');
  ButtonSelectSource.Hint := 'ImportButtonSelectSourceDir';
  ButtonSelectSource.Enabled := true;
  ESelectSource.Left := LSelect.Left + LSelect.Width + 7;
  ESelectSource.Width := ButtonSelectSource.Left - 7 - (LSelect.Left + LSelect.Width + 10);
  FileListView.OnChange := QHFViewChange;
  FileListView.PopupMenu := nil;
  CBSelectAll.Checked := False;
  CBSelectAll.Enabled := False;
  FileListView.Items.Clear;
  // ��������� �������������� ����� "����������" � "UserID"
  EReciverNickName.ReadOnly := True;
  EReciverUIN.ReadOnly := True;
  EReciverNickName.Color := clWindow;
  EReciverUIN.Color := clWindow;
  // End
  // ��������� �������������� ����� "��� Nickname" � "��� UserID"
  EMyUIN.ReadOnly := False;
  EMyNickName.ReadOnly := False;
  EMyUIN.Color := clSkyBlue;
  EMyNickName.Color := clSkyBlue;
  // End
  ImportHistoryView.Clear;
  ImportHistoryView.Refresh;
  // ������� HistoryToDBImport.list
  DeleteFile(ProfilePath + ImportListFile);
  if ESelectSource.Text <> '' then
    StartReadDirectory;
end;

procedure TMainForm.RButtonSelectFileClick(Sender: TObject);
var
  WindowsUserName: String;
begin
  StartLoadDB := False;
  StartPreview := False;
  EReciverNickName.Text := '';
  EReciverUIN.Text := '';
  LMessageCount.Caption := '0';
  LAddedInSQLFileCount.Caption := '0';
  LStatus.Caption := GetLangStr('ImportLStatusUnknown');
  LStatus.Hint := 'ImportLStatusUnknown';
  if HistoryImportType = 1 then            // ICQ7
  begin
    WindowsUserName := GetUserFromWindows();
    if WindowsUserName <> 'Unknown' then
    begin
      if (DetectWinVersionStr = 'Windows 7') then
        ESelectSource.Text := 'C:\Users\'+WindowsUserName+'\Application Data\ICQ\'
      else  if (DetectWinVersionStr = 'Windows XP') or (DetectWinVersionStr = 'Windows 2000') then
        ESelectSource.Text := 'C:\Documents and Settings\'+WindowsUserName+'\Application Data\ICQ\'
      else
        ESelectSource.Text := 'C:\';
    end
    else
      ESelectSource.Text := 'C:\';
  end
  else if HistoryImportType = 2 then       // RnQ
     ESelectSource.Text := ProfilePath + 'history\'
  else if HistoryImportType = 3 then       // QIP 2005
    ESelectSource.Text := RemoveInvalidStr('Plugins\QIPHistoryToDB', ProfilePath)
  else if HistoryImportType = 4 then       // QIP 2010/Infium/2012
    ESelectSource.Text := RemoveInvalidStr('Plugins\QIPHistoryToDB', ProfilePath) + 'History\';
  OpenDialog1.InitialDir := ESelectSource.Text;
  PBRead.Position := 0;
  PBWriteToDB.Position := 0;
  ButtonToSQL.Enabled := False;
  LSelect.Caption := GetLangStr('ImportLSelectSelectFile');
  LSelect.Hint := 'ImportLSelectSelectFile';
  ButtonSelectSource.Caption := GetLangStr('ImportButtonSelectSourceFile');
  ButtonSelectSource.Hint := 'ImportButtonSelectSourceFile';
  ButtonSelectSource.Enabled := true;
  ESelectSource.Left := LSelect.Left + LSelect.Width + 7;
  ESelectSource.Width := ButtonSelectSource.Left - 7 - (LSelect.Left + LSelect.Width + 10);
  CBSelectAll.Checked := False;
  CBSelectAll.Enabled := False;
  FileListView.OnChange := nil;
  FileListView.PopupMenu := nil;
  FileListView.Items.Clear;
  ImportHistoryView.Clear;
  ImportHistoryView.Refresh;
  // ������� HistoryToDBImport.list
  DeleteFile(ProfilePath + ImportListFile);
end;

function TMainForm.ReadTXTAndInsertDB(FileName: String): Boolean;
var
  RegExpMsgCount, RegExpIN, RegExpOUT, RegExpEnd, RegExpNick: TRegExpr;
  I, J, FileStringCount, NickMsgCount, MsgCount, MsgFoundPos, TotalMsgCount: Integer;
  ReciverNick, ReciverUin: String;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Text: WideString;
  Msg_Time, MD5String: String;
  MsgDateTime: TDateTime;
  FirstNickNameFound, NickNameFound: Boolean;
  CurrentAccountName, CurrentAccountUIN: WideString;
begin
  if RButtonSelectFile.Checked then
    ReciverUin := EReciverUIN.Text
  else
  begin
    ReciverUin := ExtractFileNameEx(FileName, False);
    EReciverUIN.Text := ReciverUin;
  end;
  // ������ ������ TRegExpr
  RegExpIN := TRegExpr.Create;
  RegExpOUT := TRegExpr.Create;
  RegExpEnd := TRegExpr.Create;
  RegExpNick := TRegExpr.Create;
  RegExpMsgCount := TRegExpr.Create;
  UnicodeFiles.Clear;
  UnicodeFiles.LoadFromFile(FileName);
  // ��������� ��������� ������, �� ��� �� ������, ��� ��� ��������� ���������
  UnicodeFiles.Add('--------------------------------------!-');

  // ���� ������ ����:
  // -------------------------------------->-
  // ���
  // --------------------------------------<-
  MsgCount := 0;
  RegExpMsgCount.Expression := '^(\-){38}(>-|<-)';
  for I:=0 to UnicodeFiles.Count-1 do
  begin
    if RegExpMsgCount.Exec(UnicodeFiles[I]) then
      Inc(MsgCount);
  end;

  PBRead.Position := 0;
  TotalMsgCount := 0;
  PBRead.Max := MsgCount;
  LMessageCount.Caption := IntToStr(MsgCount);
  AddImportHistoryInList(Format(GetLangStr('ImportFoundCnt'), [IntToStr(MsgCount)]), 4);

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
  if MatchStrings(FileName, '*InfICQ*') then
    ProtoType := 0
  else if IsNumber(ExtractFileNameEx(FileName, False)) and (HistoryImportType = 3) then // QIP 2005
    ProtoType := 0
  else if MatchStrings(FileName, '*gmail.com*') then
    ProtoType := 1
  else if MatchStrings(FileName, '*MRA*') then
    ProtoType := 2
  else if MatchStrings(FileName, '*jabberqip*') then
    ProtoType := 4
  else if (MatchStrings(FileName, '*vk.com*')) or (MatchStrings(FileName, '*vkontakte.ru*')) then
    ProtoType := 6
  else if MatchStrings(FileName, '*Jabber*') then
    ProtoType := 3
  else if MatchStrings(FileName, '*jabber*') then
    ProtoType := 3
  else if MatchStrings(FileName, '*facebook.com*') then
    ProtoType := 5
  else if MatchStrings(FileName, '*twitter.com*') then
    ProtoType := 7
  else if (MatchStrings(FileName, '*Social*')) then
    ProtoType := 8
  else
    ProtoType := 9;

  try
    // ���� �������� ���������:
    // --------------------------------------<-
    RegExpIN.Expression := '^(\-){38}(<-)';
    // ���� ��������� ���������:
    // -------------------------------------->-
    RegExpOUT.Expression := '^(\-){38}(>-)';
    // ���� ������������ ������� ���������� ���������:
    // --------------------------------------!-
    RegExpEnd.Expression := '^(\-){38}(!-)';
    // ���� ������� � �����-����
    // ������ ������ � TXT �����: ��� ���� (11:25:22 28/08/2011)
    // ��� ������ ������ � TXT �����: ��� ���� (11:25:22 28.08.2011)
    // ������� ��������� �������: 0-9 �-� �-� � <������> ~ ! @ # $ % ^ & * _ + - = . , / " ' ; ( )
    RegExpNick.Expression := '^([�-��-�\�\w\d\s\~\!\@\#\$\%\^\&\*\_\+\-\=\.\,\/\"\''\;\(\)]{1,})(\()([0-9\:]{1,8})(\s)([0-9\.\/]{1,10})(\))$';
    FileStringCount := 0;
    MsgFoundPos := 0;
    NickNameFound := False;
    DateSeparator := '/';
    if UnicodeFiles.Count > 0 then
    begin
      if RButtonSelectDir.Checked then
      begin
        // ���� ������� ����������� ��� ������ ������ � SQL-�����, ����� ����
        // ��������� ���������, �� �������� ����������� ��� ���, � �� ����� ���
        // SQL-�����.
        NickMsgCount := 0;
        while (not FirstNickNameFound) and (NickMsgCount < UnicodeFiles.Count) do
        begin
          if RegExpIN.Exec(UnicodeFiles[NickMsgCount]) then
          begin
            FirstNickNameFound := True;
            MsgFoundPos := NickMsgCount;
          end;
          Inc(NickMsgCount);
        end;
        if FirstNickNameFound and (RegExpNick.Exec(UnicodeFiles[MsgFoundPos+1])) then
          ReciverNick := Trim(RegExpNick.Match[1])
        else
          ReciverNick := ReciverUin;
        EReciverNickName.Text := ReciverNick;
      end
      else
      begin
        ReciverNick := EReciverNickName.Text;
        if ReciverNick = '' then
          ReciverNick := ReciverUin;
        if ReciverNick = '' then // ���� ��� �� ���� "����������" ������, �� ������� � �������
        begin
          Result := False;
          Exit;
        end;
      end;
      // �������� ������� ���� TXT ���� � ������
      while (FileStringCount < UnicodeFiles.Count) do
      begin
        {if EnableDebug then
        begin
          WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� ReadTXTAndInsertDB: ������: ' + UnicodeFiles[FileStringCount], 2);
        end;}
        // ����./�����. ���������
        if RegExpMsgCount.Exec(UnicodeFiles[FileStringCount]) then
        begin
          // ����. ���������
          if RegExpIN.Exec(UnicodeFiles[FileStringCount]) then
          begin
            MsgFoundPos := FileStringCount;
            Msg_Direction := '1';
            NickNameFound := False;
            if RegExpNick.Exec(UnicodeFiles[MsgFoundPos+1]) then
            begin
              NickNameFound := True;
              if RButtonSelectDir.Checked then
              begin
                ReciverNick := Trim(RegExpNick.Match[1]);
                EReciverNickName.Text := ReciverNick;
              end
              else
                ReciverNick := EReciverNickName.Text;
              MsgDateTime := StrToDateTime(StringReplace(RegExpNick.Match[5], '.', '/', [RFReplaceall])+ ' ' + RegExpNick.Match[3]);
            end;
          end
          // �����. ���������
          else if RegExpOUT.Exec(UnicodeFiles[FileStringCount]) then
          begin
            MsgFoundPos := FileStringCount;
            Msg_Direction := '0';
            NickNameFound := False;
            if RegExpNick.Exec(UnicodeFiles[MsgFoundPos+1]) then
            begin
              NickNameFound := True;
              CurrentAccountName := Trim(RegExpNick.Match[1]);
              MsgDateTime := StrToDateTime(StringReplace(RegExpNick.Match[5], '.', '/', [RFReplaceall])+ ' ' + RegExpNick.Match[3]);
            end;
          end;
          // �������� �� ��, ��� ������ ������� � ��� ������� MsgFoundPos+1 ������ ���. ���. ����� TXT �����
          if (NickNameFound) and (MsgFoundPos+1 < UnicodeFiles.Count) then
          begin
            {if EnableDebug then
            begin
              if Msg_Direction = '0' then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� ReadTXTAndInsertDB: ����������� ���������: ' + Msg_Direction + ' | �������: ' + Global_CurrentAccountName + ' | UIN: ' + Global_CurrentAccountUIN + ' | �������: ' + IntToStr(MsgFoundPos+1) + ' �� ' +  IntToStr(UnicodeFiles.Count-1), 2);
              if Msg_Direction = '1' then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� ReadTXTAndInsertDB: ����������� ���������: ' + Msg_Direction + ' | �������: ' + Nick + ' | UIN: ' + Uin + ' | �������: ' + IntToStr(MsgFoundPos+1) + ' �� ' +  IntToStr(UnicodeFiles.Count-1), 2);
            end;}
            for I := MsgFoundPos+1 to UnicodeFiles.Count-1 do
            begin
              // ���� ��������� ������� ��. ��� ���. ���������
              if (RegExpMsgCount.Exec(UnicodeFiles[I])) or (RegExpEnd.Exec(UnicodeFiles[I])) then
              begin
                Msg_Text := '';
                for J := MsgFoundPos+2 to I-1 do
                begin
                  Msg_Text := Msg_Text + Trim(UnicodeFiles[J]);
                  if J <> I-1 then
                    Msg_Text := Msg_Text + #13;
                end;
                Msg_Text := Trim(Msg_Text);
                if EnableDebug then
                begin
                  if Msg_Direction = '0' then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� ReadTXTAndInsertDB: ����������� ���������: ' + Msg_Direction + ' | �������: ' + Global_CurrentAccountName + ' | UIN: ' + Global_CurrentAccountUIN + ' | �������: ' + IntToStr(MsgFoundPos+2) + ' �� ' +  IntToStr(UnicodeFiles.Count-1) + ' | ���������: ' + PrepareString(PWideChar(Msg_Text)), 2);
                  if Msg_Direction = '1' then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������� ReadTXTAndInsertDB: ����������� ���������: ' + Msg_Direction + ' | �������: ' + ReciverNick + ' | UIN: ' + ReciverUin + ' | �������: ' + IntToStr(MsgFoundPos+2) + ' �� ' +  IntToStr(UnicodeFiles.Count-1) + ' | ���������: ' + PrepareString(PWideChar(Msg_Text)), 2);
                end;
                Break;
              end;
            end;
            // ���������� ���� ������� � UIN
            if Global_CurrentAccountName  <> EMyNickName.Text then
              CurrentAccountName := PrepareString(PWideChar(EMyNickName.Text))
            else
              CurrentAccountName := Global_CurrentAccountName;
            if Global_CurrentAccountUIN  <> EMyUIN.Text then
              CurrentAccountUIN := PrepareString(PWideChar(EMyUIN.Text))
            else
              CurrentAccountUIN := Global_CurrentAccountUIN;
            // End
            Msg_RcvrNick := WideStringToUTF8(PrepareString(PWideChar(ReciverNick)));
            Msg_RcvrAcc := WideStringToUTF8(PrepareString(PWideChar(ReciverUin)));
            if (DBType = 'oracle') or (DBType = 'oracle-9i') then
              Msg_Time := 'to_date('''+FormatDateTime('DD.MM.YYYY HH:MM:SS', MsgDateTime)+''', ''dd.mm.yyyy hh24:mi:ss'')'
            else
              Msg_Time := FormatDateTime('YYYY-MM-DD HH:MM:SS', MsgDateTime);
            Msg_Text := PrepareString(PWideChar(Msg_Text));
            Msg_Text :=  WideStringToUTF8(Msg_Text);

            LStatus.Caption := GetLangStr('ImportRecordStart');
            LStatus.Hint := 'ImportRecordStart';

            MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', MsgDateTime) + Msg_Text;
            if (DBType = 'oracle') or (DBType = 'oracle-9i') then
              WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, DBUserName, IntToStr(ProtoType), WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3)
            else
              WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, IntToStr(ProtoType), WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3);
            PBRead.Position := PBRead.Position + 1;
            Inc(TotalMsgCount);
          end;
        end;
        Inc(FileStringCount);
        LAddedInSQLFileCount.Caption := IntToStr(TotalMsgCount);
        Application.ProcessMessages;
      end;
      AddImportHistoryInList(Format(GetLangStr('ImportDoneCnt'), [IntToStr(TotalMsgCount)]), 4);
    end
    else
    begin
      Result := False;
      RegExpMsgCount.Free;
      RegExpIN.Free;
      RegExpOUT.Free;
      RegExpEnd.Free;
      RegExpNick.Free;
      Exit;
    end;
  finally
    RegExpMsgCount.Free;
    RegExpIN.Free;
    RegExpOUT.Free;
    RegExpEnd.Free;
    RegExpNick.Free;
  end;
  Result := True;
end;

{ ������ QHF-���� � ������� ����� � HistoryView }
function TMainForm.ReadQHFData(FileName: String): Boolean;
var
  TMS: TMemoryStream;
  QHFHead: QHFHeader;
  QHFRec: array of QHFRecord;
  Ba2: array[0..1] of Byte;
  Ba4: array[0..3] of Byte;
  //BaUIN, BaNick: array of Byte;
  BaStr, BaMsg: array of Byte;
  UType,l,i: Word;
  Dl: DWord;
  HistCount, SetHistStartCount, SetHistStopCount: DWord;
  SkipSetHistStartCount, SkipSetHistStopCount: DWord;
  Nick, Uin: String;
  Income: Boolean;
  Time: String;
  Msg_Text: WideString;
  Year,Mon,Day: Word;
  J,K: Cardinal;
  AllowView: Boolean;
begin
  try
    TMS := TMemoryStream.Create;
    TMS.LoadFromFile(FileName);
    TMS.Read(QHFHead,sizeof(QHFHead));
    if CompareMem(@QHFHead.QHFItems1, @QHFHead.QHFItems2, 4) then
      HistCount := r32(QHFHead.QHFItems1)
    else
    begin
      TMS.Free;
      Result := False;
      Exit;
    end;
    if QHFHead.QHFMagic[3] = $01 then //$51484601
    begin
      MsgInf(MainForm.Caption, 'Sorry. Unknown history type.');
      TMS.Free;
      Result := False;
      Exit;
    end;
    TMS.Read(UType,2);    // ������ 2 �����, �� ��� �� ��� �������
    TMS.Read(Ba2,2);      // Read UIN bytecount
    l := r16(Ba2);
    SetLength(BaStr, l*2+1);
    TMS.Read(BaStr[0],l); // Read UIN
    //SetLength(Uin,l);
    Uin := UTF8Decode(pAnsiChar(BaStr));
    TMS.Read(Ba2,2);      // Read nick bytecount
    l := r16(Ba2);
    SetLength(BaStr, l*2+1);
    TMS.Read(BaStr[0],l); // Read nick
    Nick := UTF8Decode(pAnsiChar(BaStr));
    SetLength(QHFRec, HistCount);

    if RButtonSelectFile.Checked then
    begin
      Nick := EReciverNickName.Text;
      Uin := EReciverUIN.Text;
    end
    else
    begin
      LoadQHFNicks(FileName);
      Nick := EReciverNickName.Text;
      Uin := EReciverUIN.Text;
    end;

    PBRead.Position := 0;
    LStatus.Caption := GetLangStr('ImportWait');
    LStatus.Hint := 'ImportWait';
    LMessageCount.Caption := IntToStr(HistCount);
    // ������� ���������� ������� � �������������
    SetHistStartCount := 0;
    SetHistStopCount := HistCount;
    if CBPreviewNum.ItemIndex = 0 then // ������ 5 ���������
    begin
      SetHistStartCount := 0;
      if HistCount > 5 then
        SetHistStopCount := 5
      else
        SetHistStopCount := HistCount;
      PBRead.Max := SetHistStopCount - 1;
    end
    else if CBPreviewNum.ItemIndex = 1 then // ������ 10 ���������
    begin
      SetHistStartCount := 0;
      if HistCount > 10 then
        SetHistStopCount := 10
      else
        SetHistStopCount := HistCount;
      PBRead.Max := SetHistStopCount - 1;
    end
    else if CBPreviewNum.ItemIndex = 2 then // ������ 20 ���������
    begin
      SetHistStartCount := 0;
      if HistCount > 20 then
        SetHistStopCount := 20
      else
        SetHistStopCount := HistCount;
      PBRead.Max := SetHistStopCount - 1;
    end
    else if CBPreviewNum.ItemIndex = 3 then // ��������� 5 ���������
    begin
      SetHistStartCount := 0;
      SetHistStopCount := HistCount;
      if HistCount > 4 then
        PBRead.Max := 4
      else
        PBRead.Max := HistCount;
    end
    else if CBPreviewNum.ItemIndex = 4 then // ��������� 10 ���������
    begin
      SetHistStartCount := 0;
      SetHistStopCount := HistCount;
      if HistCount > 9 then
        PBRead.Max := 9
      else
        PBRead.Max := HistCount;
    end
    else if CBPreviewNum.ItemIndex = 5 then // ��������� 20 ���������
    begin
      SetHistStartCount := 0;
      SetHistStopCount := HistCount;
      if HistCount > 19 then
        PBRead.Max := 19
      else
        PBRead.Max := HistCount;
    end
    else if CBPreviewNum.ItemIndex = 6 then // ���
    begin
      SetHistStartCount := 0;
      SetHistStopCount := HistCount;
      PBRead.Max := SetHistStopCount - 1;
    end;
    AllowView := False;

    for i := SetHistStartCount to SetHistStopCount-1 do
    begin
      TMS.Read(Ba2,2);    // Magic
      l := r16(Ba2);
      QHFRec[i].RecordType := l;
      TMS.Read(Ba4,4);    // Read record SIZE
      Dl := r32(Ba4);
      QHFRec[i].RecordSize := Dl;
      TMS.Read(Ba2,2); // Read record Index type, should be 1
      TMS.Read(Ba2,2); // Read record Index bytecount, should be 4
      TMS.Read(Ba4,4); // Read record Index
      Dl := r32(Ba4);
      QHFRec[i].RecordIndex := Dl;
      TMS.Read(Ba2,2); // Read record UINblock type, should be 2
      TMS.Read(Ba2,2); // Read record UINblock type, should be 4
      TMS.Read(Ba4,4); // Read record Timestamp
      QHFRec[i].RecordTime := r32(Ba4);  // 172800
      DecodeDate(UnixToDateTime(QHFRec[i].RecordTime),Year,Mon,Day);
      Time := TimeToStr(UnixToDateTime(QHFRec[i].RecordTime))+' '+IntToStr(Day)+'/'+IntToStr(Mon)+'/'+IntToStr(Year);
      TMS.Read(Ba2,2); // Read record Flagblock type, should be 3
      TMS.Read(Ba2,2); // Read record Flagblock type, should be 3
      TMS.Read(QHFRec[i].RecordInOut,1); // Read record InOut Type
      TMS.Read(Ba2,2); // Read record Flag, should be 1
      if QHFRec[i].RecordInOut = 1 then
        Income := True
      else
        Income := False;
      TMS.Read(Ba2,2);                    // Read message block type, should be 4
      if QHFHead.QHFMagic[3] = $03 then   // ���� ������ ����� ������� = 3 (QIP Infium)
      begin
        TMS.Read(Ba4,4);                  // Read message size (4 �����)
        l := r32(Ba4);
      end
      else
      begin
        TMS.Read(Ba2,2);                  // Read message size (2 �����)
        l := r16(Ba2);
      end;
      SetLength(BaMsg,l+1);
      TMS.Read(BaMsg[0],l); // Read message
      k := 1;
      for j := 0 to l do    // Decode message
      begin
        BaMsg[j] := (Byte(BaMsg[j]) xor $ff)-k;
        Inc(k);
        if k>256 then
          k := 1;
      end;
      BaMsg[Length(BaMsg)-1] := $00;
      QHFRec[i].RecordMessage := UTF8ToWideString(pAnsiChar(BaMsg));
      Msg_Text := QHFRec[i].RecordMessage;
      if CBPreviewNum.ItemIndex = 3 then // ��������� 5 ���������
      begin
        if HistCount > 5 then
          SkipSetHistStartCount := HistCount - 5
        else
          SkipSetHistStartCount := 0;
        SkipSetHistStopCount := HistCount;
      end
      else if CBPreviewNum.ItemIndex = 4 then // ��������� 10 ���������
      begin
        if HistCount > 10 then
          SkipSetHistStartCount := HistCount - 10
        else
          SkipSetHistStartCount := 0;
        SkipSetHistStopCount := HistCount;
      end
      else if CBPreviewNum.ItemIndex = 5 then // ��������� 20 ���������
      begin
        if HistCount > 20 then
          SkipSetHistStartCount := HistCount - 20
        else
          SkipSetHistStartCount := 0;
        SkipSetHistStopCount := HistCount;
      end;
      // ��������� ����������� ��������� ������ � ������������ �������
      if (CBPreviewNum.ItemIndex >= 0) and (CBPreviewNum.ItemIndex < 3) then // ������ 5,10,20 ���������
        AllowView := True
      else if (CBPreviewNum.ItemIndex >= 3) and (CBPreviewNum.ItemIndex < 6) and (i >= SkipSetHistStartCount) and (i < SkipSetHistStopCount)  then // ��������� 5,10,20 ���������
        AllowView := True
      else if (CBPreviewNum.ItemIndex = 6) then
        AllowView := True
      else
        AllowView := False;
      // ����� ���������
      if Income and AllowView then
      begin
        AddImportHistoryInList(Format(MSG_TITLE, [Global_CurrentAccountName, Global_CurrentAccountUIN, FormatDateTime('dd.mm.yy hh:mm:ss', UnixToDateTime(QHFRec[i].RecordTime))]), 0);
        AddImportHistoryInList(Msg_Text, 5);
      end
      else if (not Income) and AllowView then
      begin
        AddImportHistoryInList(Format(MSG_TITLE, [Nick, Uin, FormatDateTime('dd.mm.yy hh:mm:ss', UnixToDateTime(QHFRec[i].RecordTime))]), 1);
        AddImportHistoryInList(Msg_Text, 6);
      end;
      Application.ProcessMessages;
      PBRead.Position := PBRead.Position + 1;
    end;
    LStatus.Caption := GetLangStr('ImportDone');
    LStatus.Hint := 'ImportDone';
  except
    MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + FileName);
end;
  TMS.Free;
  Result := True;
end;

// ������� ����� � ReadData ���������� ������ QHF-�����
// + ��������� ���������� ������� � SQL-����
function TMainForm.ReadQHFAndInsertDB(FileName: String): Boolean;
var
  TMS: TMemoryStream;
  QHFHead: QHFHeader;
  QHFRec: Array of QHFRecord;
  Ba2: Array[0..1] of Byte;
  Ba4: Array[0..3] of Byte;
  BaStr, BaMsg: Array of Byte;
  l: Word;
  I: Integer;
  Dl: DWord;
  HistCount: DWord;
  Nick, Uin: WideString;
  Income: Boolean;
  J,K: Cardinal;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Text: WideString;
  CurrentAccountName, CurrentAccountUIN: WideString;
  Msg_Time, MD5String: String;
begin
  try
    TMS := TMemoryStream.Create;
    TMS.LoadFromFile(FileName);
    TMS.Read(QHFHead,sizeof(QHFHead));
    if CompareMem(@QHFHead.QHFItems1, @QHFHead.QHFItems2, 4) then
      HistCount := r32(QHFHead.QHFItems1)
    else
    begin
      TMS.Free;
      Result := False;
      Exit;
    end;
    if QHFHead.QHFMagic[3] = $01 then //$51484601
    begin
      MsgInf(MainForm.Caption, 'Sorry. Unknown history type.');
      TMS.Free;
      Result := False;
      Exit;
    end;
    TMS.Read(Ba2, 2);
    TMS.Read(Ba2, 2);    // Read UIN bytecount
    l := r16(Ba2);
    SetLength(BaStr, l*2+1);
    TMS.Read(BaStr[0],l); // Read UIN
    //SetLength(Uin,l);
    Uin := UTF8Decode(pAnsiChar(BaStr));
    TMS.Read(Ba2,2);      // Read nick bytecount
    l := r16(Ba2);
    SetLength(BaStr, l*2+1);
    TMS.Read(BaStr[0],l); // Read nick
    Nick := UTF8Decode(pAnsiChar(BaStr));
    SetLength(QHFRec, HistCount);

    if RButtonSelectFile.Checked then
    begin
      Nick := EReciverNickName.Text;
      Uin := EReciverUIN.Text;
    end
    else
    begin
      LoadQHFNicks(FileName);
      Nick := EReciverNickName.Text;
      Uin := EReciverUIN.Text;
    end;

    PBRead.Position := 0;
    PBRead.Max := HistCount - 1;
    LMessageCount.Caption := IntToStr(HistCount);
    AddImportHistoryInList(Format(GetLangStr('ImportFoundCnt'), [IntToStr(HistCount)]), 4);

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
    if MatchStrings(FileName, '*InfICQ*') then
      ProtoType := 0
    else if IsNumber(Uin) and (MatchStrings(FileName, '*Social*')) then // VKontacte
        ProtoType := 6
    else if MatchStrings(FileName, '*gmail.com*') then
      ProtoType := 1
    else if MatchStrings(FileName, '*MRA*') then
      ProtoType := 2
    else if MatchStrings(FileName, '*jabberqip*') then
      ProtoType := 4
    else if (MatchStrings(FileName, '*vk.com*')) or (MatchStrings(FileName, '*vkontakte.ru*')) then
      ProtoType := 6
    else if MatchStrings(FileName, '*Jabber*') then
      ProtoType := 3
    else if MatchStrings(FileName, '*jabber*') then
      ProtoType := 3
    else if MatchStrings(FileName, '*facebook.com*') then
      ProtoType := 5
    else if MatchStrings(FileName, '*twitter.com*') then
      ProtoType := 7
    else if (MatchStrings(FileName, '*Social*')) then
      ProtoType := 8
    else
      ProtoType := 9;

    for I:=0 to HistCount-1 do
    begin
      TMS.Read(Ba2,2); // Magic
      l := r16(Ba2);
      QHFRec[i].RecordType := l;
      TMS.Read(Ba4,4); // Read record SIZE
      Dl := r32(Ba4);
      QHFRec[i].RecordSize := Dl;
      TMS.Read(Ba2,2); // Read record Index type, should be 1
      TMS.Read(Ba2,2); // Read record Index bytecount, should be 4
      TMS.Read(Ba4,4); // Read record Index
      Dl := r32(Ba4);
      QHFRec[i].RecordIndex := Dl;
      TMS.Read(ba2,2); // Read record UINblock type, should be 2
      TMS.Read(ba2,2); // Read record UINblock type, should be 4
      TMS.Read(ba4,4); // Read record Timestamp
      QHFRec[i].RecordTime := r32(Ba4);  // 172800
      TMS.Read(Ba2,2); // Read record Flagblock type, should be 3
      TMS.Read(Ba2,2); // Read record Flagblock type, should be 3
      TMS.Read(QHFRec[i].RecordInOut,1); // Read record InOut Type
      TMS.Read(Ba2,2); // Read record Flag, should be 1
      if QHFRec[i].RecordInOut=1 then
        Income := True
      else
        Income := False;
      TMS.Read(Ba2,2);                    // Read message block type, should be 4
      if QHFHead.QHFMagic[3] = $03 then   // ���� ������ ����� ������� = 3 (QIP Infium)
      begin
        TMS.Read(Ba4,4);                  // Read message size (4 �����)
        l := r32(Ba4);
      end
      else                                // ���� ������ ����� ������� = 2 ��� 1 (QIP 2010)
      begin
        TMS.Read(Ba2,2);                  // Read message size (2 �����)
        l := r16(Ba2);
      end;
      SetLength(BaMsg,l+1);
      TMS.Read(BaMsg[0],l);               // Read message
      k := 1;
      for j := 0 to l do                  // Decode message
      begin
        BaMsg[j] := (Byte(BaMsg[j]) xor $ff)-k;
        Inc(k);
        if k>256 then
          k := 1;
      end;
      BaMsg[Length(BaMsg)-1] := $00;
      QHFRec[i].RecordMessage := UTF8ToWideString(pAnsiChar(BaMsg));

      Msg_RcvrNick := WideStringToUTF8(PrepareString(PWideChar(Nick)));
      Msg_RcvrAcc := WideStringToUTF8(PrepareString(PWideChar(Uin)));
      if (DBType = 'oracle') or (DBType = 'oracle-9i') then
        Msg_Time := 'to_date('''+FormatDateTime('DD.MM.YYYY HH:MM:SS', UnixToDateTime(QHFRec[i].RecordTime))+''', ''dd.mm.yyyy hh24:mi:ss'')'
      else
        Msg_Time := FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(QHFRec[i].RecordTime));
      Msg_Text := PrepareString(PWideChar(QHFRec[i].RecordMessage));
      Msg_Text :=  WideStringToUTF8(Msg_Text);
      if Income then
        Msg_Direction := '0'
      else
        Msg_Direction := '1';
      LStatus.Caption := GetLangStr('ImportRecordStart');
      LStatus.Hint := 'ImportRecordStart';
      // ���������� ���� ������� � UIN
      if Global_CurrentAccountName  <> EMyNickName.Text then
        CurrentAccountName := PrepareString(PWideChar(EMyNickName.Text))
      else
        CurrentAccountName := Global_CurrentAccountName;
      if Global_CurrentAccountUIN  <> EMyUIN.Text then
        CurrentAccountUIN := PrepareString(PWideChar(EMyUIN.Text))
      else
        CurrentAccountUIN := Global_CurrentAccountUIN;
      // End
      MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', UnixToDateTime(QHFRec[i].RecordTime)) + Msg_Text;
      if (DBType = 'oracle') or (DBType = 'oracle-9i') then
        WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, DBUserName, IntToStr(ProtoType), WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3)
      else
        WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, IntToStr(ProtoType), WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3);
      PBRead.Position := I;
      LAddedInSQLFileCount.Caption := IntToStr(I);
      Application.ProcessMessages;
    end;
    LAddedInSQLFileCount.Caption := IntToStr(I);
    AddImportHistoryInList(Format(GetLangStr('ImportDoneCnt'), [IntToStr(I)]), 4);
  except
    MsgInf(MainForm.Caption, GetLangStr('ImportHistoryFileReadError') + ' ' + FileName);
  end;
  TMS.Free;
  Result := True;
end;

{ ������ TXT-���� ������� QIP 2005 � ������� ����� � QHFHistoryView }
procedure TMainForm.ReadTXTData(FileName: String);
begin
  ImportHistoryView.Clear;
  ImportHistoryView.Refresh;
  UnicodeFiles.Clear;
  UnicodeFiles.LoadFromFile(FileName);
  AddImportHistoryInList(UnicodeFiles.Text, 5);
end;

{ ������ ���� ������� � ������� RnQ � ������� ����� � QHFHistoryView }
procedure TMainForm.ReadRnQData(FileName: String);
var
  SrcFile: TFileStream;
begin
  ImportHistoryView.Clear;
  ImportHistoryView.Refresh;
  if FileExists(FileName) then
  begin
    SrcFile := TFileStream.Create(FileName, fmOpenRead);
    try
      if StartPreview then
        StartPreview := False
      else
        StartPreview := True;
      if LoadingDone then
        LMessageCount.Caption := IntToStr(RnQHistoryRead(@SrcFile, FileName, False));
      StartPreview := False;
    finally
      SrcFile.Free;
    end;
  end;
end;

{ ��������� ���-���� � UIN �� QHF-����� }
procedure TMainForm.LoadRnQNicks(FileName: String);
var
  MyUINandNickNameCnt: Integer;
  FoundUINandNickName: Boolean;
begin
  //AddImportHistoryInList('������ ������� �� ����� '+ExtractFileNameEx(FileName, True), 3);
  if UINToNickPointer.UINToNickCount > 0 then
  begin
    FoundUINandNickName := False;
    MyUINandNickNameCnt := 0;
    while (not FoundUINandNickName) and (MyUINandNickNameCnt < UINToNickPointer.UINToNickCount) do
    begin
      if ExtractFileNameEx(FileName, True) = UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt].UIN then
        FoundUINandNickName := True;
      Inc(MyUINandNickNameCnt);
    end;
    if FoundUINandNickName then
    begin
      //AddImportHistoryInList(UINToNickPointer.UINToNickPointerID[J].UIN + ' - ' + UINToNickPointer.UINToNickPointerID[J].NickName, 3);
      EReciverUIN.Text := UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt-1].UIN;
      EReciverNickName.Text := UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt-1].NickName;
    end
    else
    begin
      EReciverUIN.Text := ExtractFileNameEx(FileName, True);
      EReciverNickName.Text := EReciverUIN.Text;
    end;
  end
  else
  begin
    EReciverUIN.Text := ExtractFileNameEx(FileName, True);
    EReciverNickName.Text := EReciverUIN.Text;
  end;
end;

{ ��������� ���-���� � UIN �� TXT-����� ������� QIP 2005}
procedure TMainForm.LoadTXTNicks(FileName: String);
var
  RegExp, RegExpIN, RegExpNick: TRegExpr;
  I, MsgCount, MsgFoundPos: Integer;
  NickFound: Boolean;
begin
  EReciverUIN.Text := ExtractFileNameEx(FileName, False);
  LAddedInSQLFileCount.Caption := '0';
  // ������ ������ TRegExpr
  RegExp := TRegExpr.Create;
  RegExpIN := TRegExpr.Create;
  RegExpNick := TRegExpr.Create;
  UnicodeFiles.Clear;
  UnicodeFiles.LoadFromFile(FileName);
  try
    // ���� ������ ����:
    // --------------------------------------<-
    RegExpIN.Expression := '(\-){38}(<-)';
    // ���� ������� � �����-����
    // ������ ������ � TXT �����: ��� ���� (11:25:22 28/08/2011)
    // ������� ��������� �������: 0-9 �-� �-� � <������> ~ ! @ # $ % ^ & * _ + - = . , / " ' ; ( )
    RegExpNick.Expression := '^([�-��-�\�\w\d\s\~\!\@\#\$\%\^\&\*\_\+\-\=\.\,\/\"\''\;\(\)]{1,})(\()([0-9\:]{1,8})(\s)([0-9\.\/]{1,10})(\))$';
    MsgFoundPos := 0;
    NickFound := False;
    if UnicodeFiles.Count > 0 then
    begin
      MsgCount := 0;
      RegExp.Expression := '(\-){38}(>-|<-)';
      for I:=0 to UnicodeFiles.Count-1 do
      begin
        if RegExp.Exec(UnicodeFiles[I]) then
          Inc(MsgCount);
      end;
      LMessageCount.Caption := IntToStr(MsgCount);
      MsgCount := 0;
      while (not NickFound) and (MsgCount < UnicodeFiles.Count) do
      begin
        if RegExpIN.Exec(UnicodeFiles[MsgCount]) then
        begin
          NickFound := True;
          MsgFoundPos := MsgCount;
        end;
        Inc(MsgCount);
      end;
      if NickFound and (RegExpNick.Exec(UnicodeFiles[MsgFoundPos+1])) then
          EReciverNickName.Text := Trim(RegExpNick.Match[1])
      else
        EReciverNickName.Text := EReciverUIN.Text;
    end
    else
      EReciverNickName.Text := EReciverUIN.Text;
  finally
    RegExp.Free;
    RegExpIN.Free;
    RegExpNick.Free;
  end;
end;

{ ��������� ���-���� � UIN �� QHF-����� }
procedure TMainForm.LoadQHFNicks(FileName: String);
var
  FS: TFileStream;
  UIN_Len, Nick_Len: Word;
  Ba4: Array[0..3] of Byte;
  HistCount: DWord;
  Magic_Str, UIN_Str, W_Nick_Str: String;
  Nick_Str: AnsiString;
  Ch: Byte;
  I: Integer;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  FS.Position := 0;
  Magic_Str := '';
  for I := 1 to 3 do
  begin
    FS.Read(Ch, 1);
    Magic_Str := Magic_Str + AnsiChar(Ch);
  end;
  if Magic_Str <> 'QHF' then
  begin
    EReciverNickName.Text := '';
    EReciverUIN.Text := '';
    FS.Free;
    Exit;
  end;
  FS.Position := 34;
  FS.Read(Ba4, 4);
  HistCount := r32(Ba4);
  LMessageCount.Caption := IntToStr(HistCount);
  FS.Position := 44;
  FS.Read(UIN_Len,2);
  UIN_Len := Swap(UIN_Len);
  UIN_Str := '';
  for I := 1 to UIN_Len do
  begin
    FS.Read(Ch, 1);
    UIN_Str := UIN_Str + AnsiChar(Ch);
  end;
  FS.Read(Nick_Len, 2);
  Nick_Len := Swap(Nick_Len);
  Nick_Str := '';
  for i := 1 to Nick_Len do
  begin
    FS.Read(Ch, 1);
    Nick_Str := Nick_Str + AnsiChar(Ch);
  end;
  W_Nick_Str := UTF8Decode(pAnsiChar(Nick_Str));
  EReciverNickName.Text := W_Nick_Str;
  EReciverUIN.Text := UIN_Str;
  FS.Free;
end;

function TMainForm.r32(x3: Array of Byte): DWord;
var
   x1 : DWord;
   x2 : Array[1..4] of Byte Absolute x1;
begin
   x2[1] := x3[3];
   x2[2] := x3[2];
   x2[3] := x3[1];
   x2[4] := x3[0];
   Result := x1;
end;

function TMainForm.r16(x3: Array of Byte): Word;
var
  x1 : Word;
  x2 : Array[0..1] of Byte Absolute x1;
begin
  x2[0] := x3[1];
  x2[1] := x3[0];
  Result := x1;
end;

{ ���������� �������� � QIPRichView }
procedure TMainForm.AddImageToRichEdit(const AImageIndex: Integer; ImageLst: TImageList);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    ImageLst.GetBitmap(AImageIndex, Bitmap);
    ImportHistoryView.InsertGraphic(Bitmap, False);
    { ���������� ������ }
    with ImportHistoryView.GetSelection do
      ImportHistoryView.SetSelection(cpMin + 1, cpMin + 1, False);
  finally
    Bitmap.Free;
  end;
end;

{ ���������� ������ � RichView }
procedure TMainForm.AddImportHistoryInList(Str: WideString; TextType: Integer);
begin
  Str := Str + #13#10;
  ImportHistoryView.SetSelection(MaxInt, MaxInt, False);
  if TextType = 0 then // ��������� ���������
  begin
    AddImageToRichEdit(0, MainForm.ImageList_RichEdit);
    IMEditorParagraph.SpaceBefore := IMEditorParagraphTitleSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphTitleSpaceAfter;
    ImportHistoryView.AddFormatText(' ' + Str, MainForm.FHeaderFontOutTitle);
  end
  else if TextType = 1 then // �������� ���������
  begin
    AddImageToRichEdit(1, MainForm.ImageList_RichEdit);
    IMEditorParagraph.SpaceBefore := IMEditorParagraphTitleSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphTitleSpaceAfter;
    ImportHistoryView.AddFormatText(' ' + Str, MainForm.FHeaderFontInTitle);
  end
  else if TextType = 2 then // �� �� ��������� ������������
  begin
    AddImageToRichEdit(2, MainForm.ImageList_RichEdit);
    ImportHistoryView.AddFormatText(' ' + Str, MainForm.FHeaderFontServiceMsg);
  end
  else if TextType = 3 then // �� ����������
  begin
    AddImageToRichEdit(3, MainForm.ImageList_RichEdit);
    MainForm.FHeaderFontServiceMsg.Color := clRed;
    ImportHistoryView.AddFormatText(' ' + Str, MainForm.FHeaderFontServiceMsg);
  end
  else if TextType = 4 then // �������� ���������� ���������
  begin
    AddImageToRichEdit(4, MainForm.ImageList_RichEdit);
    ImportHistoryView.AddFormatText(' ' + Str, MainForm.FHeaderFontServiceMsg);
  end
  else if TextType = 5 then // ���� ���������� ���������
  begin
    IMEditorParagraph.SpaceBefore := IMEditorParagraphMessagesSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphMessagesSpaceAfter;
    ImportHistoryView.AddFormatText(Str, MainForm.FHeaderFontOutBody);
  end
  else if TextType = 6 then // ���� ��������� ���������
  begin
    IMEditorParagraph.SpaceBefore := IMEditorParagraphMessagesSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphMessagesSpaceAfter;
    ImportHistoryView.AddFormatText(Str, MainForm.FHeaderFontInBody);
  end;
  ImportHistoryView.SetSelection(MaxInt, MaxInt, True);
end;

{ ���������� ������� � �� }
procedure TMainForm.SQL_Zeos_NickName(Sql: WideString);
begin
    try
      if MainForm.MainZConnection.Connected then
        begin
          NickNameQuery.Connection := MainForm.MainZConnection;
          try
            NickNameQuery.Close;
            NickNameQuery.SQL.Clear;
            NickNameQuery.SQL.Text := Sql;
            NickNameQuery.Open;
          except
            on e :
              Exception do
              begin
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
                MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
              end;
          end;
        end;
    except
      on e :
        Exception do
          MsgInf(GetLangStr('ErrCaption'), GetLangStr('ErrDBConnect') + #13 + StringReplace(e.Message,#13#10,'',[RFReplaceall]));
    end;
end;

{������ ������� ICQ7}
function TMainForm.ICQ7HistoryRead(HistoryFileName: WideString): Integer;
var
  ImportQuery: TZQuery;
  MsgCount, TotalMsgCount: Integer;
  ICQ7UserID: WideString;
  Msg_Nick, Msg_UIN, Msg_Text: WideString;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction: WideString;
  CurrentAccountName, CurrentAccountUIN: WideString;
  Msg_Date, Msg_Date_Time: TDateTime;
  MD5String, Msg_Time: String;
begin
  ImportHistoryZConnection.Database := HistoryFileName;
  ImportHistoryZConnection.Protocol := 'sqlite-3';
  ImportHistoryZConnection.HostName := '';
  ImportHistoryZConnection.Port := 0;
  ImportHistoryZConnection.User := '';
  ImportHistoryZConnection.Password := '';
  ImportHistoryZConnection.Properties.Clear;
  ImportHistoryZConnection.Properties.Add('codepage=UTF8');
  ImportHistoryZConnection.LoginPrompt := false;
  try
    if not ImportHistoryZConnection.Connected then
      ImportHistoryZConnection.Connect;
  except
    on e :
      Exception do
      begin
        AddImportHistoryInList(Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 4);
        ImportHistoryView.Refresh;
      end;
  end;
  if ImportHistoryZConnection.Connected then
  begin
    AddImportHistoryInList(Format(GetLangStr('ImportICQDBConnected'), [ImportHistoryZConnection.Database]), 4);
    ImportQuery := TZQuery.Create(nil);
    ImportQuery.Connection := ImportHistoryZConnection;
    try
      ImportQuery.SQL.Clear;
      ImportQuery.SQL.Text := 'SELECT userId FROM Users';
      ImportQuery.Open;
      TotalMsgCount := 0;
      repeat
        ICQ7UserID := ImportQuery.FieldByName('userId').AsString;
        AddImportHistoryInList(Format(GetLangStr('ImportICQFoundHistory'), [ICQ7UserID]), 4);
        SQL_ImportZeos('SELECT DISTINCT Usr.name as UserNickName,'+
          ' case when (Msg.fromUser is null) then '''+ICQ7UserID+''''+
          ' else Msg.fromUser'+
          ' end as UserUIN,'+
          ' case when (Msg.fromUser is null) then ''0'''+
          ' else ''1'''+
          ' end as MsgDirection,'+
          ' Msg.subject as subject, Msg.date as date'+
          ' FROM (SELECT userId, participantsHash FROM Participants WHERE userId = '''+ICQ7UserID+''') as PHash,'+
          ' Messages as Msg, Users as Usr, Participants as Part'+
          ' WHERE Msg.participantsHash =  PHash.participantsHash and Usr.userId = PHash.userId  ORDER by Msg.messageId asc');
        MsgCount := 0;
        repeat
          Inc(MsgCount);
          Msg_Nick := ImportHistoryZQuery.FieldByName('UserNickName').AsString;
          Msg_UIN := ImportHistoryZQuery.FieldByName('UserUIN').AsString;
          Msg_Direction  := ImportHistoryZQuery.FieldByName('MsgDirection').AsString;
          Msg_Date_Time := ImportHistoryZQuery.FieldByName('date').AsFloat;
          Msg_Text := ImportHistoryZQuery.FieldByName('subject').AsString;
          if IsUTF8String(Msg_UIN) then
            Msg_UIN := UTF8ToWideString(Msg_UIN);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_Text) then
            Msg_Text := UTF8ToWideString(Msg_Text);
          // ��������� ����� �� �� � ���������
          Msg_Date := UnixToLocalTime(DateTimeToUnix(Msg_Date_Time));
          // ���������� ���� ������� � UIN
          if Global_CurrentAccountName  <> EMyNickName.Text then
            CurrentAccountName := PrepareString(PWideChar(EMyNickName.Text))
          else
            CurrentAccountName := Global_CurrentAccountName;
          if Global_CurrentAccountUIN  <> EMyUIN.Text then
            CurrentAccountUIN := PrepareString(PWideChar(EMyUIN.Text))
          else
            CurrentAccountUIN := Global_CurrentAccountUIN;
          // End
          // ���� ����������
          Msg_RcvrNick := WideStringToUTF8(PrepareString(PWideChar(Msg_Nick)));
          Msg_RcvrAcc := WideStringToUTF8(PrepareString(PWideChar(Msg_UIN)));
          // ��������� ���� ����-������� ���������
          if (DBType = 'oracle') or (DBType = 'oracle-9i') then
            Msg_Time := 'to_date('''+FormatDateTime('DD.MM.YYYY HH:MM:SS', Msg_Date)+''', ''dd.mm.yyyy hh24:mi:ss'')'
          else
            Msg_Time := FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_Date);
          // ��������� ���� ���������
          Msg_Text := PrepareString(PWideChar(Msg_Text));
          Msg_Text :=  WideStringToUTF8(Msg_Text);
          // ������������ ����������� MD5 ������
          MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_Date) + Msg_Text;
          if (DBType = 'oracle') or (DBType = 'oracle-9i') then
            WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, DBUserName, '0', WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3)
          else
            WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, '0', WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3);
          ImportHistoryZQuery.Next;
          Application.ProcessMessages;
        until ImportHistoryZQuery.Eof;
        AddImportHistoryInList(Format(GetLangStr('ImportICQDoneCnt'), [IntToStr(MsgCount)]), 4);
        TotalMsgCount := TotalMsgCount + MsgCount;
        LAddedInSQLFileCount.Caption := IntToStr(MsgCount);
        ImportQuery.Next;
      until ImportQuery.Eof;
      LMessageCount.Caption := IntToStr(TotalMsgCount);
      LAddedInSQLFileCount.Caption := IntToStr(TotalMsgCount);
    except
      on e :
        Exception do
        begin
          if WriteErrLog then
            WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
          if MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*database is locked*') then
            AddImportHistoryInList(GetLangStr('ImportICQDBLocked'), 2);
        end;
    end;
    ImportQuery.Free;
    if ImportHistoryZConnection.Connected then
      ImportHistoryZConnection.Disconnect;
  end;
end;

{ ������ ������� RnQ }
function TMainForm.RnQHistoryRead(HistFile: PFStream; RnQFileName: WideString; WriteToSQLFile: Boolean): Longint;
var
  CHUNK: THCHUNK;
  Pos: Int64;
  NNew: Boolean;
  Count: Longint;
  Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Text: WideString;
  Msg_Time, MD5String: String;
  CurrentAccountName, CurrentAccountUIN: WideString;
  Nick, Uin: WideString;
  FoundUINandNickName: Boolean;
  MyUINandNickNameCnt: Integer;
begin
  if WriteToSQLFile then // ������ ���� ����� ������� � SQL ����
  begin
    if RButtonSelectFile.Checked then
    begin
      Nick := EReciverNickName.Text;
      Uin := EReciverUIN.Text;
    end
    else
    begin
      // ������ ��������� ������������� UIN <> NickName
      // � ���� ��� ������ ������ �����������
      if UINToNickPointer.UINToNickCount > 0 then
      begin
        FoundUINandNickName := False;
        MyUINandNickNameCnt := 0;
        while (not FoundUINandNickName) and (MyUINandNickNameCnt < UINToNickPointer.UINToNickCount) do
        begin
          if ExtractFileNameEx(RnQFileName, True) = UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt].UIN then
            FoundUINandNickName := True;
          Inc(MyUINandNickNameCnt);
        end;
        if FoundUINandNickName then
        begin
          Uin := UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt-1].UIN;
          Nick := UINToNickPointer.UINToNickPointerID[MyUINandNickNameCnt-1].NickName;
          EReciverUIN.Text := Uin;
          EReciverNickName.Text := Nick;
        end
        else
        begin
          Nick := ExtractFileNameEx(RnQFileName, True);
          Uin := Nick;
        end;
      end
      else
      begin
        Nick := ExtractFileNameEx(RnQFileName, True);
        Uin := Nick;
      end;
    end;
    // ������� ������
    PBRead.Position := 0;
    //LMessageCount.Caption := GetLangStr('ImportLStatusUnknown');
    LStatus.Caption := GetLangStr('ImportRecordStart');
    LStatus.Hint := 'ImportRecordStart';
  end;
  // ���� ���������� ������ ����� ������� RnQ
  Count := 0;
  CHUNK.Correct := False;
  Pos := 0;
  NNew := True;
  LoadingDone := False;
  repeat
    if ((@HistFile<>nil) and NNew) then
    begin
      Pos := FindCHUNK(HistFile^, Pos);
      NNew := False;
      if Pos >= 0 then
        TakeCHUNK(HistFile^, Pos, CHUNK)
      else
        CHUNK.Correct := False;
    end;
    if CHUNK.Correct = True  then
    begin
      if CHUNK.What = -1 then
      begin
        // ���������� ���� ������� � UIN
        if Global_CurrentAccountName  <> EMyNickName.Text then
          CurrentAccountName := PrepareString(PWideChar(EMyNickName.Text))
        else
          CurrentAccountName := Global_CurrentAccountName;
        if Global_CurrentAccountUIN  <> EMyUIN.Text then
          CurrentAccountUIN := PrepareString(PWideChar(EMyUIN.Text))
        else
          CurrentAccountUIN := Global_CurrentAccountUIN;
        // End
        if WriteToSQLFile then // ������ ���� ����� ������� � SQL ����
        begin
          // ���� ����������
          Msg_RcvrNick := WideStringToUTF8(PrepareString(PWideChar(Nick)));
          Msg_RcvrAcc := WideStringToUTF8(PrepareString(PWideChar(Uin)));
          // ��������� ���� ����-������� ���������
          if (DBType = 'oracle') or (DBType = 'oracle-9i') then
            Msg_Time := 'to_date('''+FormatDateTime('DD.MM.YYYY HH:MM:SS', CHUNK.Time)+''', ''dd.mm.yyyy hh24:mi:ss'')'
          else
            Msg_Time := FormatDateTime('YYYY-MM-DD HH:MM:SS', CHUNK.Time);
          // ��������� ���� ���������
          Msg_Text := PrepareString(PWideChar(CHUNK.Msg));
          Msg_Text :=  WideStringToUTF8(Msg_Text);
          // ���������� ����������� ���������
          if IntToStr(CHUNK.UIN) = CurrentAccountUIN then
            Msg_Direction := '0'
          else
            Msg_Direction := '1';
          // ������������ ����������� MD5 ������
          MD5String := Msg_RcvrAcc + FormatDateTime('YYYY-MM-DD HH:MM:SS', CHUNK.Time) + Msg_Text;
          if (DBType = 'oracle') or (DBType = 'oracle-9i') then
            WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, DBUserName, '0', WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3)
          else
            WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, '0', WideStringToUTF8(CurrentAccountName), WideStringToUTF8(CurrentAccountUIN), Msg_RcvrNick, Msg_RcvrAcc, Msg_Direction, Msg_Time, Msg_Text, EncryptMD5(MD5String)]), 3);
        end
        else
        begin
          if IntToStr(CHUNK.UIN) = CurrentAccountUIN then
          begin
            AddImportHistoryInList(Format(MSG_TITLE, [Global_CurrentAccountName, Global_CurrentAccountUIN, FormatDateTime('dd.mm.yy hh:mm:ss', CHUNK.Time)]), 0);
            AddImportHistoryInList(CHUNK.Msg, 5);
          end
          else
          begin
            AddImportHistoryInList(Format(MSG_TITLE, [EReciverNickName.Text, EReciverUIN.Text, FormatDateTime('dd.mm.yy hh:mm:ss', CHUNK.Time)]), 1);
            AddImportHistoryInList(CHUNK.Msg, 6);
          end;
        end;
        LAddedInSQLFileCount.Caption := IntToStr(Count);
      end
      else if CHUNK.What = -2 then
      begin
        AddImportHistoryInList('RnQ Import: ������� ����������� ���������.', 3);
        AddImportHistoryInList('RnQ Import: ��� �����: ' + IntToStr(CHUNK.What), 3);
        AddImportHistoryInList('RnQ Import: ������������ ���������: ' + CHUNK.Msg, 3);
        AddImportHistoryInList('RnQ Import: ��� ��������� �� ���� ������������� � ��.', 3);
      end;
      Pos := Pos + CHUNK.Size;
      NNew := True;
      Application.ProcessMessages;
      Inc(Count);
    end;
  until (CHUNK.Correct = False) or (StartPreview = False);
  LoadingDone := True;
  Result := Count;
end;

{ ���� ���� �� ����� ������� RnQ � ��������� ��� ������������ }
function TMainForm.FindCHUNK (Fil: TFileStream; Start: Int64): Int64;
var
  MBWhat: Integer;
  Pos, Size: Int64;
begin
  Size := Fil.Size - 4;
  Pos := Start - 1;
  while (Pos <= Size - 1) do
  begin
    Inc(Pos);
    Fil.Seek(Pos, soFromBeginning);
    Fil.Read(MBWhat, 4);
    if ((MBWhat = -1) or (MBWhat = -2) or (MBWhat = -3)) then
      begin
        FindCHUNK := Pos; // ���� ������
        Exit;
      end;
  end;
  FindCHUNK := -1;  // ���� �� ������
end;

{ ������ ���� �� ����� ������� RnQ � ��������� THCHUNK }
function TMainForm.TakeCHUNK(Fil: TFileStream; Pos: Int64; var Res: THCHUNK): Integer;
var
  CHUNKSize: Int64;
  What, Temp, I, EncMsgBodySize, ExtraInfoSize: Integer;
  TempMsg: AnsiString;
  RnQcryptMode: Integer;
  CountUTF8, CountWin, CountUTF, CountUTFBE: Integer;

  function getByte: Byte;
  begin
    Fil.Read(Result, 1);
  end;

  function getInt: Integer;
  begin
    Fil.Read(Result, 4);
  end;

  function getString: AnsiString;
  var
    mSize: Integer;
  begin
    mSize := getInt;
    EncMsgBodySize := mSize;
    SetLength(Result, mSize);
    Fil.Read(Result[1], mSize);
  end;

  procedure parseExtraInfo;
  var
    Code, Next, extraEnd: Integer;
    Cur : Integer;
    S: AnsiString;
  begin
    Cur := 1;
    extraEnd := 4 + getInt;
    Inc(Cur, 4);
    while Cur < extraEnd do
    begin
      Code := getInt;
      Inc(Cur, 4);
      Next := Cur + getInt + 4;
      case Code of
        1:
        begin
          getInt;
        end;
        11:
        begin
          S := getString;
          //if Length(S) > 0 then
          //  ShowMessage(S);
        end;
      end;
      Cur := Next;
    end;
    ExtraInfoSize := extraEnd-4;
  end;

  {$WARN UNSAFE_CODE OFF}
  procedure Decritt(var S: AnsiString; Key: Integer);
  begin
    asm
      push  esi
      push  ebx
      push  ecx
      push  edx
      push  eax

      mov ecx, key
      mov dl, cl
      shr ecx, 20
      mov dh, cl

      mov esi, s
      mov esi, [esi]
      or  esi, esi    // nil string
      jz  @OUT
      mov ah, 10111000b

      mov ecx, [esi-4]
      or  ecx, ecx
      jz  @OUT
    @IN:
      mov al, [esi]
      xor al, ah
      rol al, 3
      xor al, dh
      sub al, dl

      mov [esi], al
      inc esi
      ror ah, 3
      dec ecx
      jnz @IN
    @OUT:
      pop   eax
      pop   edx
      pop   ecx
      pop   ebx
      pop   esi
    end;
  end;
  {$WARN UNSAFE_CODE ON}

  function dupString(S: AnsiString): AnsiString;
  begin
    Result := copy(S, 1, Length(S));
  end;

  function DeCritted(S: AnsiString; Key: Integer): AnsiString;
  begin
    Result := dupString(S);
    DeCritt(Result, Key);
  end;

  // �� ��������� FastDetectCharset �������� ������� cy6 � ������ rnq.ru
  procedure FastDetectCharset(S: AnsiString; var CountUTF8, CountWin, CountUTF, CountUTFBE: Integer);
  begin
    asm
      PUSH  ESI
      PUSH  EBX
      PUSH  ECX
      PUSH  EDX
      PUSH  EAX

      MOV   ESI, S
      OR    ESI, ESI
      JZ    @OUT
      MOV   ECX, [ESI-4]
      OR    ECX, ECX
      JZ    @OUT
      XOR   EBX, EBX
      XOR   EDX, EDX
    @IN:
      XOR   EAX, EAX
      LODSB

      CMP   AL, 0D0h
      JNZ   @J1
      INC   BL
      JMP   @LO
    @J1:
      CMP   AL, 0D1h
      JNZ   @J2
      INC   BL
      JMP   @LO
    @J2:
      CMP   AL, 0E0h
      JNZ   @J3
      INC   BH
      JMP   @LO
    @J3:
      CMP   AL, 0EEh
      JNZ   @J4
      INC   BH
      JMP   @LO
    @J4:
      CMP   AL, 0CEh
      JNZ   @J5
      INC   BH
      JMP   @LO
    @J5:
      MOV   AH, CL
      AND   AH, 01h
      JZ    @J6
      CMP   AL, 04h
      JNZ   @LO
      INC   DL
      JMP   @LO
    @J6:
      CMP   AL, 04h
      JNZ   @LO
      INC   DH
    @LO:
      LOOP  @IN
    @OUT:
      XOR   EAX, EAX
      MOV   AL, BL
      MOV   ESI, [CountUTF8]
      MOV   [ESI], EAX
      MOV   AL, BH
      MOV   ESI, [CountWin]
      MOV   [ESI], EAX
      MOV   AL, DL
      MOV   ESI, [CountUTF]
      MOV   [ESI], EAX
      MOV   AL, DH
      MOV   ESI, [CountUTFBE]
      MOV   [ESI], EAX

      POP   EAX
      POP   EDX
      POP   ECX
      POP   EBX
      POP   ESI
    end;
  end;

  // �� ������� StrUTF2Ansi �������� ������� cy6 � ������ rnq.ru
  function StrUTF2Ansi(S: AnsiString): AnsiString;
  begin
    SetLength(Result, Length(S) div 2);
    asm
      PUSH  ESI
      PUSH  EDI
      PUSH  EDX
      PUSH  ECX
      PUSH  EAX

      MOV   ESI, S
      OR    ESI, ESI
      JZ    @OUT
      MOV   EAX, [ESI-4]
      OR    EAX, EAX
      JZ    @OUT
      MOV   ECX, 2
      XOR   EDX, EDX
      DIV   ECX
      MOV   ECX, EAX
      MOV   EDI, Result
      MOV   EDI, [EDI]
    @IN:
      LODSW
      CMP   AH, 04h
      JNZ   @PUT
      CMP   AL, 10h
      JB    @PUT
      CMP   AL, 4Fh
      JA    @PUT
      ADD   AL, 0B0h
    @PUT:
      STOSB
      LOOP  @IN
      XOR   EAX, EAX
      STOSB
    @OUT:
      POP   EAX
      POP   ECX
      POP   EDX
      POP   EDI
      POP   ESI
    end;
  end;

  // �� ������� StrUTFBE2Ansi �������� ������� cy6 � ������ rnq.ru
  function StrUTFBE2Ansi(S: AnsiString): AnsiString;
  begin
    SetLength(Result, Length(S) div 2);
    asm
      PUSH  ESI
      PUSH  EDI
      PUSH  EDX
      PUSH  ECX
      PUSH  EAX

      MOV   ESI, S
      OR    ESI, ESI
      JZ    @OUT
      MOV   EAX, [ESI-4]
      OR    EAX, EAX
      JZ    @OUT
      MOV   ECX, 2
      XOR   EDX, EDX
      DIV   ECX
      MOV   ECX, EAX
      MOV   EDI, Result
      MOV   EDI, [EDI]
    @IN:
      LODSW
      CMP   AL, 04h
      JNZ   @PUT
      CMP   AH, 10h
      JB    @PUT
      CMP   AH, 4Fh
      JA    @PUT
      ADD   AH, 0B0h
    @PUT:
      MOV   AL, AH
      STOSB
      LOOP  @IN
      XOR   EAX, EAX
      STOSB
    @OUT:
      POP   EAX
      POP   ECX
      POP   EDX
      POP   EDI
      POP   ESI
    end;
  end;

begin
  RnQcryptMode := 0;
  ExtraInfoSize := 0;
  Res.Correct := False;
  Fil.Seek(Pos, soFromBeginning);
  try
    Fil.ReadBuffer(What, 4);
    if (What = -1) then // ��� ����� HI_event
    begin
      Res.What := -1;
      Fil.ReadBuffer(Res.Kind, 1);
      Fil.ReadBuffer(Res.UIN, 4);
      Fil.ReadBuffer(Res.Time, 8);
      parseExtraInfo; // ������ ������� ����. ����������
      CHUNKSize := 21 + ExtraInfoSize;
      TempMsg := getString();
      if Res.Kind = 1 then // ������ ��� ���� ��������� EK_msg
      begin
        //TempMsg := DeCritted(TempMsg, StrToIntDef(IntToStr(Res.UIN), 0));
        TempMsg := DeCritted(TempMsg, Res.UIN);
        // �� ��������� FastDetectCharset �������� ������� cy6 � ������ rnq.ru
        FastDetectCharset(TempMsg, CountUTF8, CountWin, CountUTF, CountUTFBE);
        if (CountUTF > 0) then
          Res.Msg := WideString(StrUTF2Ansi(TempMsg))
        else if (CountUTFBE > 0) then
          Res.Msg := WideString(StrUTFBE2Ansi(TempMsg))
        else
        begin
          if ((CountUTF8 > 0) and (CountUTF8 > CountWin)) then
            Res.Msg := UTF8ToWideString(RawByteString(TempMsg))
          else
            Res.Msg := WideString(TempMsg);
        end;
        {if IsUTF8String(TempMsg) then
          Res.Msg := UTF8Decode(TempMsg) // UTF8Decode - ���������, UTF8ToString - �� JEDI
        else
          Res.Msg := TempMsg;}
      end;
      CHUNKSize := CHUNKSize + EncMsgBodySize + 4;
    end;
    if (What = -2) then // ��� ����� HI_hashed
    begin
      Res.What := -2;
      Res.Msg := getString();
    end;
    if (What = -3) then // ��� ����� HI_cryptMode
    begin
      Fil.Seek(4, soFromCurrent);
      RnQcryptMode := getByte;
    end;
  Res.Size := CHUNKSize;
  Res.Pos := Pos;
  Res.Correct := True;
  TakeCHUNK := 0;
  except
    on EReadError do begin
      TakeCHUNK := -1;
    end;
  end;
end;

{ �������� �� �� ������ UIN <-> NickName � ��������� ��������� }
procedure TMainForm.GetUINToNick;
var
  I, J, pCnt: Integer;
  SQLUIN, SQLNickName: WideString;
  FoundUINToNickPointerID: Boolean;
begin
  // ������������ � ����
  if not MainZConnection.Connected then
    ConnectDB;
  if MainForm.MainZConnection.Connected then
  begin
    // ��������� �� ������� ���������� ������ ��
    if not CheckServiceMode then
    begin
      // ��������� �� ������� �������
      if CheckZeroRecordCount('select count(*) AS cnt from uin_'+ DBUserName + '') then
      begin
        MainZConnection.Disconnect;
        Exit;
      end
      else
        SQL_Zeos_NickName('select DISTINCT nick,uin from uin_'+ DBUserName + ' where nick is not null order by nick asc');
        try
          for I := 0 to NickNameQuery.RecordCount-1 do
          begin
            SQLUIN := NickNameQuery.FieldByName('uin').AsString;
            SQLNickName := NickNameQuery.FieldByName('nick').AsString;
            if IsUTF8String(SQLUIN) then
              SQLUIN := UTF8ToWideString(SQLUIN);
            if IsUTF8String(SQLNickName) then
              SQLNickName := UTF8ToWideString(SQLNickName);
            // ��������� ������� ������ UIN � ���������
            if UINToNickPointer.UINToNickCount > 0 then
            begin
              FoundUINToNickPointerID := False;
              for J := 0 to UINToNickPointer.UINToNickCount-1 do
              begin
                // ������ UIN ���, ������� ��������� � ����� ���� ������
                //if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� GetUINToNick: ������ J='+IntToStr(J)+ ' | SQLUIN: ' + SQLUIN  + ' | SQLNickName: ' + SQLNickName + ' | ������ UINToNickPointer: ' + IntToStr(UINToNickPointer.UINToNickCount)  + ' | UIN: ' + UINToNickPointer.UINToNickPointerID[J].UIN + ' | NickName: ' + UINToNickPointer.UINToNickPointerID[J].NickName + #13#10, 2);
                if UINToNickPointer.UINToNickPointerID[J].UIN = SQLUIN then
                  FoundUINToNickPointerID := True;
              end;
              if not FoundUINToNickPointerID then
              begin
                // ��������� ������ � ��������� ��� ������ UIN
                pCnt := UINToNickPointer.UINToNickCount;
                UINToNickPointer.UINToNickCount := pCnt+1;
                SetLength(UINToNickPointer.UINToNickPointerID, UINToNickPointer.UINToNickCount);
                UINToNickPointer.UINToNickPointerID[pCnt].UIN := SQLUIN;
                UINToNickPointer.UINToNickPointerID[pCnt].NickName := SQLNickName;
                //if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� GetUINToNick: ������ UINToNickPointer: ' + IntToStr(UINToNickPointer.UINToNickCount)  + ' | UIN: ' + UINToNickPointer.UINToNickPointerID[pCnt].UIN + ' | NickName: ' + UINToNickPointer.UINToNickPointerID[pCnt].NickName + #13#10, 3);
              end;
            end
            else
            begin
              // ��������� ������ � ��������� ��� ������ UIN
              UINToNickPointer.UINToNickCount := 1;
              SetLength(UINToNickPointer.UINToNickPointerID, UINToNickPointer.UINToNickCount);
              UINToNickPointer.UINToNickPointerID[0].UIN := SQLUIN;
              UINToNickPointer.UINToNickPointerID[0].NickName := SQLNickName;
              //if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� GetUINToNick: ������ UINToNickPointer: ' + IntToStr(UINToNickPointer.UINToNickCount)  + ' | UIN: ' + UINToNickPointer.UINToNickPointerID[0].UIN + ' | NickName: ' + UINToNickPointer.UINToNickPointerID[0].NickName + #13#10, 3);
            end;
            NickNameQuery.Next;
          end;
      except
      on e :
        Exception do
        begin
          AddImportHistoryInList(FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������ � ��������� GetUINToNick: ' + StringReplace(e.Message,#13#10,'',[RFReplaceall]), 3);
          ImportHistoryView.Refresh;
          if WriteErrLog then
            WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ������ � ��������� GetUINToNick: ' + StringReplace(e.Message,#13#10,'',[RFReplaceall]), 1);
        end
      end;
    end;
  end
  else
  begin
    AddImportHistoryInList(Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 3);
    ImportHistoryView.Refresh;
    if WriteErrLog then
      WriteInLog(ProfilePath, Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
  end;
  MainZConnection.Disconnect;
end;

{ ���������� ������� � �� }
procedure TMainForm.SQL_ImportZeos(Sql: WideString);
begin
    try
      if ImportHistoryZConnection.Connected then
        begin
          ImportHistoryZQuery.Connection := ImportHistoryZConnection;
          try
            ImportHistoryZQuery.Close;
            ImportHistoryZQuery.SQL.Clear;
            ImportHistoryZQuery.SQL.Text := Sql;
            ImportHistoryZQuery.Open;
          except
            on e :
              Exception do
              begin
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
                AddImportHistoryInList(GetLangStr('ErrSQLQuery') + ' ' + StringReplace(e.Message,#13#10,'',[RFReplaceall]), 3);
              end;
          end;
        end;
    except
      on e :
        Exception do
        begin
          AddImportHistoryInList(Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 3);
          ImportHistoryView.Refresh;
          if WriteErrLog then
            WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
          Exit;
      end
    end;
end;

{ ����� ����������� ������ �� ������� �� ������� WM_COPYDATA }
procedure TMainForm.OnControlReq(var Msg : TWMCopyData);
var
  ControlStr, EncryptControlStr: String;
  TmpStr, TmpUserID, TmpUserName, TmpProtocolType, TmpChatName: String;
  copyDataType : TCopyDataType;
begin
  copyDataType := TCopyDataType(Msg.CopyDataStruct.dwData);
  if copyDataType = cdtString then
  begin
    EncryptControlStr := PChar(Msg.CopyDataStruct.lpData);
    Delete(EncryptControlStr, (Integer(Msg.CopyDataStruct.cbData) div 2)+1, Length(EncryptControlStr));
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnControlReq: �������� ����������� ����������� ���������: ' + EncryptControlStr, 2);
    ControlStr := DecryptStr(EncryptControlStr);
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnControlReq: ����������� ��������� ������������: ' + ControlStr, 2);
    //SetString(ControlStr, PChar(Msg.CopyDataStruct.lpData), StrLen(PChar(Msg.CopyDataStruct.lpData)));
    //Msg.Result := 2006;
    if ControlStr = 'Russian' then
    begin
      FLanguage := 'Russian';
      CoreLanguageChanged;
    end
    else if ControlStr = 'English' then
    begin
      FLanguage := 'English';
      CoreLanguageChanged;
    end;
    // 001 - ���������� ��������� �� ����� HistoryToDB.ini
    if ControlStr = '001' then
    begin
      // ������ ���������
      LoadINI(ProfilePath, true);
      // ������������� ��������� ���������� � ��
      LoadDBSettings;
    end;
    // 003 - ����� �� ���������
    // 009 - �������������� ����� �� ���������
    if (ControlStr = '003') or (ControlStr = '009') then
      Close;
    // 004 - ����� ����-����
    if ControlStr = '0040' then // �������� �����
      AntiBoss(False);
    if ControlStr = '0041' then // ������ �����
      AntiBoss(True);
  end;
end;

{ ����� ����� ���������� �� ������� WM_LANGUAGECHANGED }
procedure TMainForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ ����������� ������� WM_MSGBOX ��� ��������� ������������ ���� }
procedure TMainForm.msgBoxShow(var Msg: TMessage);
var
  msgbHandle: HWND;
begin
  msgbHandle := GetActiveWindow;
  if msgbHandle <> 0 then
    MakeTransp(msgbHandle);
end;

{ ������� ��� �������������� ��������� }
procedure TMainForm.CoreLanguageChanged;
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
        MsgDie(ProgramsName, 'Not found any language file!');
        Exit;
      end;
    end;
    Global.CoreLanguage := CoreLanguage;
    SendMessage(MainFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(ProgramsName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

{ ��� �������������� ��������� }
procedure TMainForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType
  else
    Caption := ProgramsName;
  GBMain.Caption := GetLangStr('ImportGBMain');
  if HistoryImportType = 1 then      // ICQ7
    GBMain.Caption :=  ' ' + GetLangStr('ImportICQHistory') + ' '
  else if HistoryImportType = 2 then // RnQ
    GBMain.Caption :=  ' ' + GetLangStr('ImportRnQHistory') + ' '
  else if HistoryImportType = 3 then // QIP 2005
    GBMain.Caption :=  ' ' + GetLangStr('ImportTXTHistory') + ' '
  else if HistoryImportType = 4 then // QIP 2010/Infium/2012
    GBMain.Caption :=  ' ' + GetLangStr('ImportQHFHistory') + ' ';
  RButtonSelectDir.Caption := GetLangStr('ImportRButtonSelectDir');
  RButtonSelectFile.Caption := GetLangStr('ImportRButtonSelectFile');
  LStatus.Caption := GetLangStr(LStatus.Hint);
  LSelect.Caption := GetLangStr(LSelect.Hint);
  if ButtonSelectSource.Hint = 'ImportButtonSelectSourceDir' then
  begin
    ButtonSelectSource.Caption := GetLangStr('ImportButtonSelectSourceDir');
    ButtonSelectSource.Hint := 'ImportButtonSelectSourceDir';
  end
  else if ButtonSelectSource.Hint = 'ImportButtonSelectSourceFile' then
  begin
    ButtonSelectSource.Caption := GetLangStr('ImportButtonSelectSourceFile');
    ButtonSelectSource.Hint := 'ImportButtonSelectSourceFile';
  end;
  ESelectSource.Left := LSelect.Left + LSelect.Width + 7;
  ESelectSource.Width := ButtonSelectSource.Left - 7 - (LSelect.Left + LSelect.Width + 10);
  if ButtonToSQL.Hint = 'ImportButtonToSQL' then
  begin
    ButtonToSQL.Caption := GetLangStr('ImportButtonToSQL');
    ButtonToSQL.Hint := 'ImportButtonToSQL';
  end
  else if ButtonToSQL.Hint = 'ImportProceed' then
  begin
    ButtonToSQL.Caption := GetLangStr('ImportProceed');
    ButtonToSQL.Hint := 'ImportProceed';
  end
  else if ButtonToSQL.Hint = 'ImportStop' then
  begin
    ButtonToSQL.Caption := GetLangStr('ImportStop');
    ButtonToSQL.Hint := 'ImportStop';
  end;
  CBPreview.Caption := GetLangStr('ImportCBPreview');
  LReciver.Caption := GetLangStr('ImportLReciver');
  LMessage.Caption := GetLangStr('ImportLMessage');
  LStatusTitle.Caption := GetLangStr('ImportLStatusTitle');
  LMessageCount.Left := LMessage.Left + LMessage.Width + 3;
  LStatus.Left := LStatusTitle.Left + LStatusTitle.Width + 3;
  LMyNick.Caption := GetLangStr('ImportLMyNick');
  LMyUIN.Caption := GetLangStr('ImportLMyUIN');
  LAddedInSQLFile.Caption := GetLangStr('ImportLAddedInSQLFile');
  LAddedInSQLFileCount.Left := LAddedInSQLFile.Left + LAddedInSQLFile.Width + 3;
  ImportPM.Items[0].Caption := GetLangStr('SelectAll');
  ImportPM.Items[1].Caption := GetLangStr('DeSelectAll');
  CBSelectAll.Caption := GetLangStr('SelectAll');
end;

end.
