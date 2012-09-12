{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBViewer v2.4                                 # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Main;

{$I HistoryToDBViewer.inc}
{$R Images.res}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, JvExComCtrls, JvPageListTreeView, StdCtrls, JvExStdCtrls,
  JvRichEdit, ExtCtrls, ToolWin, ImgList, JvNetscapeSplitter, JvEdit, JvDBTreeView,
  DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, ZAbstractTable, JvComCtrls, WideStrUtils, JclStringConversions,
  XMLIntf, XMLDoc, Menus, Global, XPMan, JvExExtCtrls, JvDialogs, Buttons,
  JvSpeedButton, JvExControls, JvComponentBase, JvFormPlacement, JvAppStorage,
  JvAppIniStorage, JvAnimatedImage, JvGIFCtrl, JvAppHotKey,
  DCPcrypt2, DCPblockciphers, DCPdes, DCPsha1, DCPbase64, DTPEx, ZSqlMonitor,
  Registry, ShellApi;

type
  TWMCopyData = packed record
    Msg: Cardinal;
    From: HWND;
    CopyDataStruct: PCopyDataStruct;
    Result: Longint;
  end;
  pMyTreeData = ^TMyTreeData;
    TMyTreeData = record
    Id: Integer;
    ProtoID: Integer;
    UserID: WideString;
  end;
  pMyKeyPassword = record
    KeyID: Integer;
    KeyPassword: String;
    EncryptionKey: String;
  end;
  pMyKeyPasswordPointer = record
    Count: Byte; // Количество массивов
    PasswordArray: Array of pMyKeyPassword;
  end;
  TMainForm = class(TForm)
    LeftPanel: TPanel;
    RightPanel: TPanel;
    HistoryRichView: TJvRichEdit;
    ToolBar1: TToolBar;
    ImageList_ToolBar: TImageList;
    ToolBar2: TToolBar;
    Panel2: TPanel;
    LHistory1: TLabel;
    LHistory2: TLabel;
    StartHistoryDateTimePicker: TDateTimePickerEx;
    EndHistoryDateTimePicker: TDateTimePickerEx;
    ToolBar3: TToolBar;
    Panel3: TPanel;
    LSearch: TLabel;
    ESearch: TEdit;
    JvNetscapeSplitter: TJvNetscapeSplitter;
    JvEditSearchContact: TJvEdit;
    ImageList_TreeView: TImageList;
    ZConnection1: TZConnection;
    ViewerQuery: TZQuery;
    JvTreeView: TJvTreeView;
    ImageList_RichEdit: TImageList;
    ViewerPM: TPopupMenu;
    CopyStr: TMenuItem;
    SelectAll: TMenuItem;
    ToolBar4: TToolBar;
    Panel4: TPanel;
    SearchHistoryButton: TButton;
    SearchButton: TButton;
    ShowSearchButton: TToolButton;
    ClearListButton: TToolButton;
    SyncButton: TToolButton;
    SettingsButton: TToolButton;
    CBSearchCase: TCheckbox;
    XPManifest: TXPManifest;
    SaveHistoryDialog: TJvSaveDialog;
    DeleteButton: TToolButton;
    RefreshButton: TToolButton;
    SaveButton: TToolButton;
    HistoryCount: TStaticText;
    ImportButton: TToolButton;
    ImportPM: TPopupMenu;
    ImportRnQ: TMenuItem;
    ImportQIPInfium: TMenuItem;
    ImportICQ: TMenuItem;
    SearchHistoryButtonArrow: TJvSpeedButton;
    HistoryShowPM: TPopupMenu;
    ShowHistoryDay: TMenuItem;
    ShowHistoryMonth: TMenuItem;
    ShowHistoryYear: TMenuItem;
    ShowHistoryAll: TMenuItem;
    DeleteHistoryPM: TPopupMenu;
    DeleteCurrentHistory: TMenuItem;
    DeleteAllHistory: TMenuItem;
    ImportQIP2005: TMenuItem;
    JvFormStorage1: TJvFormStorage;
    JvAppIniFileStorage1: TJvAppIniFileStorage;
    GIFPanel: TPanel;
    JvGIFAnimator: TJvGIFAnimator;
    GIFStaticText: TStaticText;
    GIFPanel2: TPanel;
    JvGIFAnimator2: TJvGIFAnimator;
    GIFStaticText2: TStaticText;
    DBServiceButton: TToolButton;
    DBServicePM: TPopupMenu;
    CheckMD5Hash: TMenuItem;
    CheckAndDeleteMD5Hash: TMenuItem;
    SearchPM: TPopupMenu;
    ExSearch: TMenuItem;
    ExSearchNext: TMenuItem;
    KeyQuery: TZQuery;
    ImageList_Import: TImageList;
    ImportMiranda: TMenuItem;
    ImportQutIM: TMenuItem;
    TreeViewPM: TPopupMenu;
    RenameContact: TMenuItem;
    DeleteContact: TMenuItem;
    MergeContact: TMenuItem;
    UpdateContactListInDB: TMenuItem;
    ZSQLMonitor1: TZSQLMonitor;
    ImageList_Main: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvEditSearchContactKeyPress(Sender: TObject; var Key: Char);
    procedure JvNetscapeSplitterCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure JvNetscapeSplitterMaximize(Sender: TObject);
    procedure JvNetscapeSplitterRestore(Sender: TObject);
    procedure JvNetscapeSplitterPaint(Sender: TObject);
    procedure JvTreeViewExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure JvTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure JvTreeViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure JvTreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure JvTreeViewCollapsed(Sender: TObject; Node: TTreeNode);
    procedure JvTreeViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure JvTreeViewMake;
    procedure ShowSummaryHistory;
    procedure ShowHistory(HistoryType: Integer; Last_UIN: WideString; Last_Proto: Integer);
    procedure AddImageToRichEdit(const AImageIndex: Integer; ImageLst: TImageList);
    procedure AddHistoryInList(Str: WideString; Encrypt: Integer; TextType: Integer);
    procedure SyncButtonClick(Sender: TObject);
    procedure ClearListButtonClick(Sender: TObject);
    procedure ShowSearchButtonClick(Sender: TObject);
    procedure SettingsButtonClick(Sender: TObject);
    procedure SearchHistoryButtonClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure ESearchKeyPress(Sender: TObject; var Key: Char);
    procedure CopyStrClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure HistoryRichViewChange(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ButtonDeleteHistoryClick(Sender: TObject);
    procedure ButtonSaveHistoryClick(Sender: TObject);
    procedure ZConnection1AfterConnect(Sender: TObject);
    procedure ShowHistoryDayClick(Sender: TObject);
    procedure ShowHistoryMonthClick(Sender: TObject);
    procedure ShowHistoryYearClick(Sender: TObject);
    procedure ShowHistoryAllClick(Sender: TObject);
    procedure DeleteAllHistoryClick(Sender: TObject);
    procedure ExSearchClick(Sender: TObject);
    procedure ExSearchNextClick(Sender: TObject);
    procedure CheckMD5HashClick(Sender: TObject);
    procedure CheckAndDeleteMD5HashClick(Sender: TObject);
    procedure EditFindDialogClose(Sender: TObject; Dialog: TFindDialog);
    procedure HistoryRichViewTextNotFound(Sender: TObject; const FindText: string);
    procedure ImportICQClick(Sender: TObject);
    procedure ImportRnQClick(Sender: TObject);
    procedure ImportQIP2005Click(Sender: TObject);
    procedure ImportQIPInfiumClick(Sender: TObject);
    procedure DeleteContactClick(Sender: TObject);
    procedure UpdateContactListInDBClick(Sender: TObject);
    procedure ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
    procedure HistoryRichViewURLClick(Sender: TObject; const URLText: string; Button: TMouseButton);
    procedure ImportMirandaClick(Sender: TObject);
    procedure JvTreeViewClick(Sender: TObject);
    procedure SQL_Zeos(Sql: WideString);
    procedure SQL_Zeos_Exec(Sql: WideString);
    procedure SQL_Zeos_Key(Sql: WideString);
    procedure LoadDBSettings;
    procedure CoreLanguageChanged;
    procedure FocusHistoryRichView;
    procedure AntiBoss(HideAllForms: Boolean);
    procedure DeleteHistory(AccountUIN, MyAccountUIN: WideString; DeleteHistoryType: Integer);
    procedure RegisterHotKeys;
    procedure UnRegisterHotKeys;
    procedure ReadEncryptionKey;
    procedure AddImageFromResourceToRichEdit(const ResID: String);
    procedure ConnectDB;
    procedure IMExcept(Sender: TObject; E: Exception);
    function CheckServiceMode: Boolean;
    function CheckZeroRecordCount(SQL: String): Boolean;
    function SearchTextAndSelect(RichView: TJvRichEdit; SearchText: string): Boolean;
    function GetEncryptionKey(KeyPwd: String; var EncryptKey: String; EncryptKeyID: String): Integer;
    function DecryptMsg(MsgStr: WideString; EncryptKeyID, EncryptKey: String): WideString;
    function OpenURL(URL: String): Cardinal;
    function DefaultBrowser: String;
    function ReConnectDB: Boolean;
  private
    { Private declarations }
    FLanguage             : WideString;
    SplitterMaximize      : Boolean;
    procedure OnControlReq(var Msg : TWMCopyData); message WM_COPYDATA;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure LoadLanguageStrings;
    procedure DoHotKey(Sender:TObject);
  public
    { Public declarations }
    RunAppDone            : Boolean;
    FHeaderFontInTitle    : TFont;
    FHeaderFontOutTitle   : TFont;
    FHeaderFontInBody     : TFont;
    FHeaderFontOutBody    : TFont;
    FHeaderFontServiceMsg : TFont;
    IMEditorParagraph: TJvParaAttributes;
    property IMCoreLanguage: WideString read FLanguage write FLanguage;
  end;

var
  MainForm                    : TMainForm;
  TreeNode                    : TTreeNode;
  TreeNodes                   : TTreeNodes;
  JvSyncHotKey                : TJvApplicationHotKey;
  JvExSearchHotKey            : TJvApplicationHotKey;
  JvExSearchNextHotKey        : TJvApplicationHotKey;
  StartSearchingContact       : Boolean;
  LastSearchingContactId      : Integer;
  LastSearchingString         : String;
  JvTreeViewStartDataLoading  : Boolean;
  MyKeyPasswordPointer        : pMyKeyPasswordPointer;

implementation

uses Settings, KeyPasswd;

{$R *.dfm}

{ Свой обработчик исключений }
procedure TMainForm.IMExcept(Sender: TObject; E: Exception);
begin
  // Пишем в лог ошибки
  if EnableDebug then
    WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура IMExcept: Class - ' + E.ClassName + ' | Ошибка - ' + Trim(e.Message), 2);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Path, CmdHelpStr: WideString;
begin
  RunAppDone := False;
  ShowSettingsFormOnStart := False;
  // Для мультиязыковой поддержки
  MainFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Проверка входных параметров
  if ParamCount < 2 then
  begin
    if GetSysLang = 'Русский' then
    begin
      CmdHelpStr := 'Параметры запуска ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
      '------------------------------------------------------------' + #13#13 +
      'HistoryToDBViewer.exe <1> <2> <3> <4> <5> <6> <7>' + #13#13 +
      '<1> - (Обязательный параметр) - Путь до файла плагина *HistoryToDB.dll, там же должен быть каталог lang с файлами локализации (Например: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
      '<2> - (Обязательный параметр) - Путь до файла настроек HistoryToDB.ini (Например: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
      '<3> - (Необязательный параметр) - Режим работы' + #13#13 +
      'Возможные значения режима работы:' + #13 +
      '0 - Просмотр истории сообщений' + #13 +
      '2 - Просмотр истории чата' + #13 +
      '4 - Показать окно настроек программы' + #13#13 +
      '<4> - (Необязательный параметр) - Ваш UIN (Например: 123321)' + #13#13 +
      '<5> - (Необязательный параметр) - Ваше имя (Например: Вася Васильев)' + #13#13 +
      'Если параметр <3> = 0, то' + #13 +
      '<6> - (Необязательный параметр) - UIN контакта для просмотра истории (Например: 789987)' + #13 +
      '<7> - (Необязательный параметр) - Имя контакта для просмотра истории (Например: Мой друг)' + #13 +
      '<8> - (Необязательный параметр) - Протокол' + #13#13 +
      'Возможные значения протокола:' + #13 +
      '0 - ICQ' + #13 +
      '1 - Google Talk' + #13 +
      '2 - MRA' + #13 +
      '3 - Jabber' + #13 +
      '4 - QIP.Ru' + #13 +
      '5 - Facebook' + #13 +
      '6 - ВКонтакте' + #13 +
      '7 - Twitter' + #13 +
      '8 - Social' + #13 +
      '9 - Unknown' + #13#13 +
      'Если параметр <3> = 2, то' + #13 +
      '<6> - (Необязательный параметр) - Название чата для просмотра истории (Например: Мой чат)';
    end
    else
    begin
      CmdHelpStr := 'Startup options ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
      '------------------------------------------------------' + #13#13 +
      'HistoryToDBViewer.exe <1> <2> <3> <4> <5> <6> <7>' + #13#13 +
      '<1> - (Required) - The path to the plugin file *HistoryToDB.dll, there must be a directory lang files localization (Example: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
      '<2> - (Required) - The path to the configuration file HistoryToDB.ini (Example: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
      '<3> - (Optional) - Mode' + #13#13 +
      'Values:' + #13 +
      '0 - View the history' + #13 +
      '2 - View chat history' + #13 +
      '4 - Edit settings' + #13#13 +
      '<4> - (Optional) - Your UIN (Example: 123321)' + #13#13 +
      '<5> - (Optional) - Your Name (Example: Vasua Vasilev)' + #13#13 +
      'If parameter <3> = 0, then' + #13 +
      '<6> - (Optional) - UIN contact to view the history (Example: 789987)' + #13 +
      '<7> - (Optional) - The contact name to view the history (Example: My friend)' + #13#13 +
      '<8> - (Optional) - Protocol' + #13#13 +
      'Values:' + #13 +
      '0 - ICQ' + #13 +
      '1 - Google Talk' + #13 +
      '2 - MRA' + #13 +
      '3 - Jabber' + #13 +
      '4 - QIP.Ru' + #13 +
      '5 - Facebook' + #13 +
      '6 - VKontacte' + #13 +
      '7 - Twitter' + #13 +
      '8 - Social' + #13 +
      '9 - Unknown' + #13#13 +
      'If parameter <3> = 2, then' + #13 +
      '<6> - (Optional) - Title to view chat history (Example: My chat)';
    end;
    MsgInf(ProgramsName, CmdHelpStr);
    Application.Terminate;
    Exit;
  end
  else
  begin
    PluginPath := ParamStr(1);
    ProfilePath := ParamStr(2);
    // Проверяем наличие каталога и файла настройки
    if not DirectoryExists(ProfilePath) then
      CreateDir(ProfilePath);
    Path := ProfilePath + ININame;
    // Состояние формы
    JvAppIniFileStorage1.FileName := ProfilePath + 'HistoryToDBForms.ini';
    // Необязательные параметры запуска
    if ParamStr(3) <> '' then
    begin
      if (ParamStr(3) = '0') or (ParamStr(3) = '2') then
      begin
        if IsNumber(ParamStr(3)) then
          Glogal_History_Type := StrToInt(ParamStr(3))
        else
          Glogal_History_Type := 10;
      end
      else if ParamStr(3) = '4' then
      begin
        if IsNumber(ParamStr(3)) then
          ShowSettingsFormOnStart := True
        else
          Glogal_History_Type := 10;
      end
      else
        Glogal_History_Type := 10;
    end
    else
      Glogal_History_Type := 10;
    // Инициализация криптования
    EncryptInit;
    // Устанавливаем стили для текста в JvRichEdit
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
    IMEditorParagraph := TJvParaAttributes.Create(HistoryRichView);
    // Читаем настройки
    LoadINI(ProfilePath, True);
    // Устанавливаем настройки соединения с БД
    LoadDBSettings;
    // Тип истории
    if Glogal_History_Type = 0 then
    begin
      if ParamStr(4) <> '' then
        Global_CurrentAccountUIN := ParamStr(4)
      else
        Global_CurrentAccountUIN := 'NoMyNameUIN';
      if ParamStr(5) <> '' then
        Global_CurrentAccountName := ParamStr(5)
      else
        Global_CurrentAccountName := 'NoMyName';
      if ParamStr(6) <> '' then
        Global_AccountUIN := ParamStr(6)
      else
        Global_AccountUIN := 'NoNameUIN';
      if ParamStr(7) <> '' then
        Global_AccountName := ParamStr(7)
      else
        Global_AccountName := 'NoName';
      if (ParamStr(6) <> '') and (ParamStr(7) <> '') and (ParamStr(8) <> '') then
      begin
        if IsNumber(ParamStr(8)) then
          Global_Protocol_Type := StrToInt(ParamStr(8))
        else
          Global_Protocol_Type := -1;
      end;
    end
    else if Glogal_History_Type = 2 then
    begin
      if ParamStr(4) <> '' then
        Global_CurrentAccountUIN := ParamStr(4)
      else
        Global_CurrentAccountUIN := 'NoMyNameUIN';
      if ParamStr(5) <> '' then
        Global_CurrentAccountName := ParamStr(5)
      else
        Global_CurrentAccountName := 'NoMyName';
      if ParamStr(6) <> '' then
        Global_ChatName := ParamStr(6)
      else
        Global_ChatName := 'MyCHAT';
    end
    else
    begin
      Glogal_History_Type := 10;
      Global_CurrentAccountUIN := DBUserName;
      Global_CurrentAccountName := DBUserName;
    end;
    // End
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Параметры запуска: ' + ParamStr(1) + ' | ' + ParamStr(2) + ' | ' + ParamStr(3) + ' | ' + ParamStr(4) + ' | ' + ParamStr(5) + ' | ' + ParamStr(6), 2);
    // Настройки внешнего вида
    LeftPanel.Width := 200;
    Constraints.MinHeight := 200;
    RightPanel.Constraints.MinWidth := 678;
    SplitterMaximize := false;
    // Загружаем настройки локализации
    IMCoreLanguage := DefaultLanguage;
    LangDoc := NewXMLDocument();
    if not DirectoryExists(PluginPath + dirLangs) then
      CreateDir(PluginPath + dirLangs);
    if not FileExists(PluginPath + dirLangs + defaultLangFile) then
    begin
      if GetSysLang = 'Русский' then
        CmdHelpStr := 'Файл локализации ' + PluginPath + dirLangs + defaultLangFile + ' не найден.'
      else
        CmdHelpStr := 'The localization file ' + PluginPath + dirLangs + defaultLangFile + ' is not found.';
      MsgInf(ProgramsName, CmdHelpStr);
      // Освобождаем ресурсы
      FHeaderFontInTitle.Free;
      FHeaderFontOutTitle.Free;
      FHeaderFontInBody.Free;
      FHeaderFontOutBody.Free;
      FHeaderFontServiceMsg.Free;
      IMEditorParagraph.Free;
      EncryptFree;
      Application.Terminate;
      Exit;
    end;
    CoreLanguageChanged;
    LoadLanguageStrings;
    // Настройки JvTreeView
    JvTreeView.ReadOnly := true;
    JvTreeView.ShowLines := false;
    JvTreeView.ShowButtons := false;
    JvTreeView.Images := ImageList_TreeView;
    JvTreeView.Items.BeginUpdate;
    TreeNodes := TTreeNodes.Create(JvTreeView);
    TreeNode := TreeNodes.Add(nil,GetLangStr('IMCaption'));
    TreeNode.ImageIndex := 0;
    TreeNode.SelectedIndex := 1;
    // Добавим фиктивную (пустую) дочернюю ветвь только для того,
    // чтобы был отрисован [+] на ветке и ее можно было бы раскрыть
    JvTreeView.Items.AddChildObject(TreeNode, '' , nil);
    // End
    TreeNode := TreeNodes.Add(nil,GetLangStr('CHATCaption'));
    TreeNode.ImageIndex := 0;
    TreeNode.SelectedIndex := 1;
    // Добавим фиктивную (пустую) дочернюю ветвь только для того,
    // чтобы был отрисован [+] на ветке и ее можно было бы раскрыть
    JvTreeView.Items.AddChildObject(TreeNode, '' , nil);
    // End
    JvTreeView.Items.EndUpdate;
    // End
    // Ставим нач. дату сегодня, а время 00:00:00
    StartHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 00:00:00', Now));
    // Ставим конечную дату - сегодня и текущее время
    EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 23:59:59', Now));
    // Переменне для поиска контакта в JvTreeView
    StartSearchingContact := False;
    LastSearchingContactId := -1;
    LastSearchingString := '';
    JvTreeViewStartDataLoading := False;
    // Регистрируем гор. клавиши
    //KeyID1 := GlobalAddAtom('HotKey1');
    //RegisterHotKey(Handle, KeyID1, MOD_CONTROL, $46); // Ctrl+F
    //KeyID2 := GlobalAddAtom('HotKey2');
    //RegisterHotKey(Handle, KeyID2, 0, VK_F3); // F3
    JvSyncHotKey := TJvApplicationHotKey.Create(self);
    with JvSyncHotKey do
    begin
      HotKey := TextToShortCut(SyncHotKey);
      Active := False;
      OnHotKey := DoHotKey;
    end;
    JvExSearchHotKey := TJvApplicationHotKey.Create(self);
    with JvExSearchHotKey do
    begin
      HotKey := TextToShortCut(ExSearchHotKey);
      Active := False;
      OnHotKey := DoHotKey;
    end;
    JvExSearchNextHotKey := TJvApplicationHotKey.Create(self);
    with JvExSearchNextHotKey do
    begin
      HotKey := TextToShortCut(ExSearchNextHotKey);
      Active := False;
      OnHotKey := DoHotKey;
    end;
    RegisterHotKeys;
    // End
    // Структура для хранения массива паролей
    MyKeyPasswordPointer.Count := 0;
    // Логгирование SQL запросов
    if EnableDebug then
    begin
      //ZSQLMonitor1.FileName := ProfilePath + DebugLogName;
      ZSQLMonitor1.Active := True;
    end;
    // Обрабатываем все исключения сами
    Forms.Application.OnException := IMExcept;
    // Программа запущена
    RunAppDone := True;
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  // Ставим фокус на QIPRichView
  if RunAppDone then
    HistoryRichView.SetFocus;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if RunAppDone then
  begin
    FHeaderFontInTitle.Free;
    FHeaderFontOutTitle.Free;
    FHeaderFontInBody.Free;
    FHeaderFontOutBody.Free;
    FHeaderFontServiceMsg.Free;
    IMEditorParagraph.Free;
    TreeNodes.Free;
    // Освобождаем ресурсы
    EncryptFree;
    // Разрегистрация гор. клавиш
    UnRegisterHotKeys;
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AntiBoss(True);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := True;
  // Если приложение запустилось с корректными параметрами
  if RunAppDone then
  begin
    // Автоскроллинг
    HistoryRichView.HideSelection := not HistoryAutoScroll;
    // Если задан показ истории, то показываем
    if (Glogal_History_Type = 0) and (not ShowSettingsFormOnStart) then
    begin
      JvNetscapeSplitter.Maximized := true;
      ShowHistory(Glogal_History_Type, Global_AccountUIN, Global_Protocol_Type);
    end
    else if (Glogal_History_Type = 2) and (not ShowSettingsFormOnStart)  then
    begin
      JvNetscapeSplitter.Maximized := true;
      ShowHistory(Glogal_History_Type, Global_ChatName, -1);
    end
    else if (Glogal_History_Type = 10) and (not ShowSettingsFormOnStart)  then
    begin
      JvNetscapeSplitter.Maximized := true;
      ShowSummaryHistory;
    end;
    // Проверка на открытие настроек при запуске
    if ShowSettingsFormOnStart then
    begin
      SettingsForm.Position := poScreenCenter;
      SettingsForm.ShowModal;
      Close;
    end
    else
      SettingsForm.Position := poMainFormCenter;
    // Прозрачность окна
    AlphaBlend := AlphaBlendEnable;
    AlphaBlendValue := AlphaBlendEnableValue;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if GIFPanel.Visible then
  begin
    GIFPanel.Left := JvTreeView.Left + (JvTreeView.Width div 2) - (GIFPanel.Width div 2);
    GIFPanel.Top := (JvTreeView.Height div 2) + (GIFPanel.Height div 2);
  end;
  if GIFPanel2.Visible then
  begin
    GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
    GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
  end;
end;

{ Регистрируем глобальные горячие клавиши }
procedure TMainForm.RegisterHotKeys;
begin
  if (SyncHotKey <> '') and GlobalHotKeyEnable then
  begin
    with JvSyncHotKey do
    begin
      HotKey := TextToShortCut(SyncHotKey);
      Active := True;
    end;
  end
  else
    JvSyncHotKey.Active := False;
  if (ExSearchHotKey <> '') and GlobalHotKeyEnable then
  begin
    with JvExSearchHotKey do
    begin
      HotKey := TextToShortCut(ExSearchHotKey);
      Active := True;
    end;
  end
  else
    JvExSearchHotKey.Active := False;
  if (ExSearchNextHotKey <> '') and GlobalHotKeyEnable then
  begin
    with JvExSearchNextHotKey do
    begin
      HotKey := TextToShortCut(ExSearchNextHotKey);
      Active := True;
    end;
  end
  else
    JvExSearchNextHotKey.Active := False;
end;

{ Разрегистрируем глобальные горячие клавиши }
procedure TMainForm.UnRegisterHotKeys;
begin
  if Assigned(JvSyncHotKey) then
    JvSyncHotKey.Free;
  if Assigned(JvExSearchHotKey) then
    JvExSearchHotKey.Free;
  if Assigned(JvExSearchNextHotKey) then
    JvExSearchNextHotKey.Free;
end;

{ Обработчик запроса к БД }
procedure TMainForm.SQL_Zeos_Key(Sql: WideString);
begin
  if ZConnection1.Connected then
  begin
    KeyQuery.Connection := ZConnection1;
    try
      KeyQuery.Close;
      KeyQuery.SQL.Clear;
      KeyQuery.SQL.Text := Sql;
      KeyQuery.Open;
    except
      on e: Exception do
      begin
        if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
        begin
          ZConnection1.Disconnect;
          if not ReConnectDB then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos_Key: Неудачный ReConnectDB.', 2);
            KeyQuery.Close;
            Exit;
          end
          else
          begin
            try
              KeyQuery.Open;
            except
            end;
          end;
        end;
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
        MsgInf(Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13#10 + Trim(e.Message));
      end;
    end;
  end
  else
  begin
    ZConnection1.Disconnect;
    if not ReConnectDB then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos_Key: Неудачный ReConnectDB.', 2);
      KeyQuery.Close;
      Exit;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainForm.SQL_Zeos(Sql: WideString);
begin
  if ZConnection1.Connected then
  begin
    ViewerQuery.Connection := ZConnection1;
    try
      ViewerQuery.Close;
      ViewerQuery.SQL.Clear;
      ViewerQuery.SQL.Text := Sql;
      ViewerQuery.Open;
    except
      on e: Exception do
      begin
        if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
        begin
          ZConnection1.Disconnect;
          if not ReConnectDB then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos: Неудачный ReConnectDB.', 2);
            ViewerQuery.Close;
            Exit;
          end
          else
          begin
            try
              ViewerQuery.Open;
            except
            end;
          end;
        end;
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
        MsgInf(Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13#10 + Trim(e.Message));
      end;
    end;
  end
  else
  begin
    ZConnection1.Disconnect;
    if not ReConnectDB then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos: Неудачный ReConnectDB.', 2);
      ViewerQuery.Close;
      Exit;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainForm.SQL_Zeos_Exec(Sql: WideString);
begin
  if ZConnection1.Connected then
  begin
    ViewerQuery.Connection := ZConnection1;
    try
      ViewerQuery.Close;
      ViewerQuery.SQL.Clear;
      ViewerQuery.SQL.Text := Sql;
      ViewerQuery.ExecSQL;
    except
      on e: Exception do
      begin
        if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
        begin
          ZConnection1.Disconnect;
          if not ReConnectDB then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos_Exec: Неудачный ReConnectDB.', 2);
            ViewerQuery.Close;
            Exit;
          end
          else
          begin
            try
              ViewerQuery.ExecSQL;
            except
            end;
          end;
        end;
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
        MsgInf(Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLExecQuery') + #13#10 + Trim(e.Message));
      end;
    end;
  end
  else
  begin
    ZConnection1.Disconnect;
    if not ReConnectDB then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SQL_Zeos_Exec: Неудачный ReConnectDB.', 2);
      ViewerQuery.Close;
      Exit;
    end;
  end;
end;

{ Поиск по JvTreeView }
procedure TMainForm.JvEditSearchContactKeyPress(Sender: TObject; var Key: Char);
var
  Noddy: TTreeNode;
  Searching: Boolean;
begin
  if (JvEditSearchContact.Text = '') or (Key = #8) or (AnsiLowerCase(JvEditSearchContact.Text) <> AnsiLowerCase(LastSearchingString)) then
  begin
    StartSearchingContact := False;
    LastSearchingContactId := -1;
  end;
  if (Key = #13) and (JvEditSearchContact.Text <> '') and (JvTreeView.Items.Count > 4) then
  begin
    if not StartSearchingContact then
      Noddy := JvTreeView.Items[0]
    else
    begin
      if JvTreeView.Items.Count > 4 then
        Noddy := JvTreeView.Items[LastSearchingContactId+1]
      else
        Noddy := JvTreeView.Items[0];
    end;
    Searching := True;
    LastSearchingString := AnsiLowerCase(JvEditSearchContact.Text);
    while (Searching) and (Noddy <> nil) do
    begin
      if MatchStrings(AnsiLowerCase(Noddy.Text), '*'+AnsiLowerCase(JvEditSearchContact.Text)+'*') and (LastSearchingContactId <> Noddy.Index) then
      begin
        StartSearchingContact := True;
        Searching := False;
        JvTreeView.Selected := Noddy;
        LastSearchingContactId := Noddy.Index;
        JvTreeView.SetFocus;
      end
      else
        Noddy := Noddy.GetNext;
    end;
  end;
end;

procedure TMainForm.JvNetscapeSplitterCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  if not SplitterMaximize then
  begin
  if MainForm.WindowState <> wsMaximized then
    if (MainForm.Left + NewSize + RightPanel.Width) > Screen.Width then
      NewSize := Screen.Width - MainForm.Left - (MainForm.Width - ClientWidth) - RightPanel.Width - JvNetscapeSplitter.Width;
  if MainForm.WindowState = wsMaximized then
    if NewSize > (ClientWidth - RightPanel.Constraints.MinWidth + JvNetscapeSplitter.Width) then
      NewSize := Screen.Width - MainForm.Left - (MainForm.Width - ClientWidth) - RightPanel.Constraints.MinWidth - JvNetscapeSplitter.Width;
  end;
end;

procedure TMainForm.JvNetscapeSplitterMaximize(Sender: TObject);
begin
  SplitterMaximize := True;
  GIFPanel.Visible := False;
  Application.ProcessMessages;
end;

procedure TMainForm.JvNetscapeSplitterPaint(Sender: TObject);
begin
  if GIFPanel.Visible then
  begin
    GIFPanel.Left := JvTreeView.Left + (JvTreeView.Width div 2) - (GIFPanel.Width div 2);
    GIFPanel.Top := (JvTreeView.Height div 2) + (GIFPanel.Height div 2);
  end;
  if GIFPanel2.Visible then
  begin
    GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
    GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
  end;
end;

procedure TMainForm.JvNetscapeSplitterRestore(Sender: TObject);
begin
  SplitterMaximize := False;
  if JvTreeViewStartDataLoading then
  begin
    GIFPanel.Visible := True;
    Application.ProcessMessages;
  end;
  if GIFPanel.Visible then
  begin
    GIFPanel.Left := JvTreeView.Left + (JvTreeView.Width div 2) - (GIFPanel.Width div 2);
    GIFPanel.Top := (JvTreeView.Height div 2) + (GIFPanel.Height div 2);
  end;
  if GIFPanel2.Visible then
  begin
    GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
    GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
  end;
end;

procedure TMainForm.ShowSummaryHistory;
var
  MsgCount: Integer;
  Proto_Filter: String;
  Msg_MyNick, Msg_MyUIN, Msg_Nick, Msg_UIN, Msg_Text: WideString;
  SystemSettings : TFormatSettings;
  MsgEncryptStatus, MyKeyPasswordCnt: Integer;
  FoundEncryptKeyID: Boolean;
  TC: Cardinal;
  SummaryQuery: TZQuery;
begin
  if EnableDebug then TC := GetTickCount;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ShowSummaryHistory: Запущено показ истории', 2);
  GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
  GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
  GIFStaticText2.Caption := GetLangStr('GIFStaticText');
  GIFStaticText2.Hint := 'GIFStaticText';
  GIFPanel2.Visible := True;
  Application.ProcessMessages;
  // Читаем региональные настройки параметров формата Даты, Времени и т.п.
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, SystemSettings);
  DateSeparator := SystemSettings.DateSeparator;
  TimeSeparator := SystemSettings.TimeSeparator;
  // End
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    HistoryRichView.Clear;
    HistoryRichView.Refresh;
    //if (MatchStrings(DBType, 'oracle*')) then
      //SQL_Zeos('select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where uin = '''+ WideStringToUTF8(Last_UIN) +''''+Proto_Filter+' and msg_time >= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') and msg_time <= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') order by msg_time asc')
    //else
    SummaryQuery := TZQuery.Create(nil);
    SummaryQuery.Connection := ZConnection1;
    SummaryQuery.ParamCheck := False;
    SummaryQuery.SQL.Clear;
    SQL_Zeos('select msg_time from uin_'+ DBUserName + ' where msg_direction = 1 order by msg_time desc limit 1');
    if ViewerQuery.FieldByName('msg_time').AsString <> '' then
      EndHistoryDateTimePicker.DateTime := StrToDateTime(ViewerQuery.FieldByName('msg_time').AsString)
    else
      EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 23:59:59', Now));
    //SummaryQuery.SQL.Text := 'select IM.my_nick,IM.my_uin,IM.nick,IM.uin,IM.msg_direction,IM.msg_time,IM.msg_text,IM.key_id from (select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where nick is not null and msg_direction = 1 and msg_time >= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''' and msg_time <= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''' group by uin order by nick asc) as IM order by IM.msg_time asc';
    SummaryQuery.SQL.Text := 'select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where msg_direction = 1 and msg_time >= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''' and msg_time <= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''' order by msg_time desc';
    try
      SummaryQuery.Open;
      MsgCount := 0;
      repeat
        if not SummaryQuery.FieldByName('msg_text').IsNull then
        begin
          Inc(MsgCount);
          // Не спрашивайте почему такой изврат с двойным декодированием
          // Какой то непонятный баг в компонентах БД
          // Или у меня руки кривые
          Msg_MyNick := SummaryQuery.FieldByName('my_nick').AsString;
          Msg_MyUIN := SummaryQuery.FieldByName('my_uin').AsString;
          Msg_Nick := SummaryQuery.FieldByName('nick').AsString;
          Msg_UIN := SummaryQuery.FieldByName('uin').AsString;
          Msg_Text := SummaryQuery.FieldByName('msg_text').AsString;
          // Если указан ключь шифрования, то запросим пароль ключа и расшифруем сооббщение
          if not SummaryQuery.FieldByName('key_id').IsNull then
          begin
            EncryptionKeyID := SummaryQuery.FieldByName('key_id').AsString;
            // Читаем структуру ключей
            if MyKeyPasswordPointer.Count > 0 then
            begin
              FoundEncryptKeyID := False;
              MyKeyPasswordCnt := 0;
              //ShowMessage('Main Размер MyKeyPasswordPointer: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount));
              while (not FoundEncryptKeyID) and (MyKeyPasswordCnt < MyKeyPasswordPointer.Count) do
              begin
                {ShowMessage('Main ID: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyID) + #13#10 +
                'Main Passwd: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyPassword + #13#10 +
                'Main Key: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].EncryptionKey);}
                if EncryptionKeyID = IntToStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].KeyID) then
                begin
                  FoundEncryptKeyID := True;
                  EncryptionKey := DecryptStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].EncryptionKey);
                  //ShowMessage('Main FoundEncryptKeyID');
                end;
                Inc(MyKeyPasswordCnt);
              end;
              if not FoundEncryptKeyID then
              begin
                //ShowMessage('Main not FoundEncryptKeyID');
                ReadEncryptionKey;
              end;
            end
            else
            begin
              // Если включено шифрование, то читаем ключ, спрашивем его пароль
              if not Global_KeyPasswdForm_Showing then
                ReadEncryptionKey;
            end;
            if EncryptionKey <> '' then
            begin
              Msg_Text := DecryptMsg(Msg_Text, EncryptionKeyID, EncryptionKey);
              MsgEncryptStatus := 1; // Сообщение расшифровано
            end
            else
            begin
              Msg_Text := GetLangStr('MessageEncrypted');
              MsgEncryptStatus := 2; // Сообщение не расшифровано
            end;
          end
          else
          begin
            MsgEncryptStatus := 0; // Не шифрованое сообщение
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
          end;
          // End
          if IsUTF8String(Msg_MyNick) then
            Msg_MyNick := UTF8ToWideString(Msg_MyNick);
          if IsUTF8String(Msg_MyNick) then
            Msg_MyNick := UTF8ToWideString(Msg_MyNick);
          if IsUTF8String(Msg_MyUIN) then
            Msg_MyUIN := UTF8ToWideString(Msg_MyUIN);
          if IsUTF8String(Msg_MyUIN) then
            Msg_MyUIN := UTF8ToWideString(Msg_MyUIN);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_UIN) then
            Msg_UIN := UTF8ToWideString(Msg_UIN);
          if IsUTF8String(Msg_UIN) then
            Msg_UIN := UTF8ToWideString(Msg_UIN);
          // End
          if (Msg_MyNick <> '') then
            Global_CurrentAccountName := Msg_MyNick;
          if (Msg_MyUIN <> '') then
            Global_CurrentAccountUIN := Msg_MyUIN;
          if SummaryQuery.FieldByName('msg_direction').AsInteger = 0 then
          begin
            AddHistoryInList(Format(MSG_TITLE, [Global_CurrentAccountName, Global_CurrentAccountUIN, SummaryQuery.FieldByName('msg_time').AsString]), MsgEncryptStatus, 0);
            AddHistoryInList(Msg_Text, 0, 5);
          end
          else
          begin
            AddHistoryInList(Format(MSG_TITLE, [Msg_Nick, Msg_UIN, SummaryQuery.FieldByName('msg_time').AsString]), MsgEncryptStatus, 1);
            AddHistoryInList(Msg_Text, 0, 6);
          end;
          SummaryQuery.Next;
        end
      until SummaryQuery.Eof;
      SummaryQuery.Close;
    finally
      SummaryQuery.Free;
    end;
    HistoryCount.Caption := IntToStr(MsgCount);
  end
  else
  begin
    AddHistoryInList(Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 3);
    if WriteErrLog then
      WriteInLog(ProfilePath, Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
  end;
  ZConnection1.Disconnect;
  HistoryRichView.Refresh;
  ToolBar3.Visible := False;
  if HistoryRichView.Lines.Count = 0 then
  begin
    RefreshButton.Enabled := false;
    SaveButton.Enabled := false;
    DeleteButton.Enabled := false;
  end
  else
  begin
    RefreshButton.Enabled := true;
    SaveButton.Enabled := true;
    DeleteButton.Enabled := true;
  end;
  GIFPanel2.Visible := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ShowSummaryHistory: ' + Format('Время выполнения: %d мc', [GetTickCount - TC]), 2);
end;

procedure TMainForm.ShowHistory(HistoryType: Integer; Last_UIN: WideString; Last_Proto: Integer);
var
  MsgCount: Integer;
  Proto_Filter: String;
  Msg_MyNick, Msg_MyUIN, Msg_Nick, Msg_UIN, Msg_Text: WideString;
  SystemSettings : TFormatSettings;
  MsgEncryptStatus, MyKeyPasswordCnt: Integer;
  FoundEncryptKeyID: Boolean;
  TC: Cardinal;
begin
  if EnableDebug then TC := GetTickCount;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ShowHistory: Запущено показ истории', 2);
  GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
  GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
  GIFStaticText2.Caption := GetLangStr('GIFStaticText');
  GIFStaticText2.Hint := 'GIFStaticText';
  GIFPanel2.Visible := True;
  Application.ProcessMessages;
  // Читаем региональные настройки параметров формата Даты, Времени и т.п.
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, SystemSettings);
  DateSeparator := SystemSettings.DateSeparator;
  TimeSeparator := SystemSettings.TimeSeparator;
  // End
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    HistoryRichView.Clear;
    HistoryRichView.Refresh;
    // Если HistoryType = 0, то показываем последние NumLastHistoryMsg сообщений пользователя Last_UIN
    // Если HistoryType = 1, то делаем поиск всей истории пользователя Last_UIN по времени StartHistoryDateTimePicker и EndHistoryDateTimePicker
    if HistoryType = 0 then // История сообщений
    begin
      if Last_Proto <> -1 then
      begin
        Proto_Filter := ' and proto_name = '+IntToStr(Last_Proto);
        Global_Protocol_Type := Last_Proto;
      end
      else
        Proto_Filter := '';
      if (MatchStrings(DBType, 'oracle*')) then
      begin
        if Last_Proto <> -1 then
        begin
          Proto_Filter := ' and o.proto_name = '+IntToStr(Last_Proto);
          Global_Protocol_Type := Last_Proto;
        end
        else
          Proto_Filter := '';
        SQL_Zeos('select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from (select o.*, row_number() over (order by o.msg_time desc) rw from uin_'+ DBUserName + ' o where o.uin = '''+ WideStringToUTF8(Last_UIN) + ''''+Proto_Filter+') z where z.rw >= 0 and z.rw <= ' + IntToStr(NumLastHistoryMsg) + ' order by msg_time asc')
      end
      else if (MatchStrings(DBType, 'firebird*')) then
        SQL_Zeos('select IM.my_nick,IM.my_uin,IM.nick,IM.uin,IM.msg_direction,IM.msg_time,IM.msg_text,IM.key_id from (select FIRST ' + IntToStr(NumLastHistoryMsg) + ' SKIP 0 my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where uin = '''+ WideStringToUTF8(Last_UIN) + ''''+Proto_Filter+' order by msg_time desc) as IM order by IM.msg_time asc')
      else
        SQL_Zeos('select IM.my_nick,IM.my_uin,IM.nick,IM.uin,IM.msg_direction,IM.msg_time,IM.msg_text,IM.key_id from (select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where uin = '''+ WideStringToUTF8(Last_UIN) + ''''+Proto_Filter+' order by msg_time desc limit ' + IntToStr(NumLastHistoryMsg) + ') as IM order by IM.msg_time asc');
    end
    else if HistoryType = 1 then  // История сообщений
    begin
      if Last_Proto <> -1 then
      begin
        Proto_Filter := ' and proto_name = '+IntToStr(Last_Proto);
        Global_Protocol_Type := Last_Proto;
      end
      else
        Proto_Filter := '';
      if (MatchStrings(DBType, 'oracle*')) then
        SQL_Zeos('select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where uin = '''+ WideStringToUTF8(Last_UIN) +''''+Proto_Filter+' and msg_time >= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') and msg_time <= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') order by msg_time asc')
      else
        SQL_Zeos('select my_nick,my_uin,nick,uin,msg_direction,msg_time,msg_text,key_id from uin_'+ DBUserName + ' where uin = '''+ WideStringToUTF8(Last_UIN) +''''+Proto_Filter+' and msg_time >= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''' and msg_time <= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''' order by msg_time asc');
    end
    else if HistoryType = 2 then // История чата
    begin
      if (MatchStrings(DBType, 'oracle*')) then
        SQL_Zeos('select msg_type,msg_time,nick_name,msg_text,key_id from (select o.*, row_number() over (order by o.msg_time desc) rw from uin_chat_'+ DBUserName + ' o) o where o.chat_caption = '''+ WideStringToUTF8(Last_UIN) + ''' and o.rw >= 0 and o.rw <= ' + IntToStr(NumLastHistoryMsg) + ' order by msg_time asc')
      else if (MatchStrings(DBType, 'firebird*')) then
        SQL_Zeos('select CHAT.msg_type,CHAT.msg_time,CHAT.nick_name,CHAT.msg_text,CHAT.key_id from (select FIRST ' + IntToStr(NumLastHistoryMsg) + ' SKIP 0 msg_type,msg_time,nick_name,msg_text,key_id from uin_chat_'+ DBUserName + ' where chat_caption = '''+ WideStringToUTF8(Last_UIN) + ''' order by msg_time desc) as CHAT order by CHAT.msg_time asc')
      else
        SQL_Zeos('select CHAT.msg_type,CHAT.msg_time,CHAT.nick_name,CHAT.msg_text,CHAT.key_id from (select msg_type,msg_time,nick_name,msg_text,key_id from uin_chat_'+ DBUserName + ' where chat_caption = '''+ WideStringToUTF8(Last_UIN) + ''' order by msg_time desc limit ' + IntToStr(NumLastHistoryMsg) + ') as CHAT order by CHAT.msg_time asc');
    end
    else // HistoryType = 3 - История чата
    begin
      if (MatchStrings(DBType, 'oracle*')) then
        SQL_Zeos('select msg_type,msg_time,nick_name,msg_text,key_id from uin_chat_'+ DBUserName + ' where chat_caption = '''+ WideStringToUTF8(Last_UIN) +''' and msg_time >= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') and msg_time <= to_date(''' + FormatDateTime('dd-MM-yyyy HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''', ''dd.mm.yyyy hh24:mi:ss'') order by msg_time asc')
      else
        SQL_Zeos('select msg_type,msg_time,nick_name,msg_text,key_id from uin_chat_'+ DBUserName + ' where chat_caption = '''+ WideStringToUTF8(Last_UIN) +''' and msg_time >= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', StartHistoryDateTimePicker.DateTime) + ''' and msg_time <= ''' + FormatDateTime('yyyy-MM-dd HH:mm:ss', EndHistoryDateTimePicker.DateTime) + ''' order by msg_time asc');
    end;
    if (HistoryType = 0) or (HistoryType = 1) then
    begin
      MsgCount := 0;
      repeat
        if not ViewerQuery.FieldByName('msg_text').IsNull then
        begin
          Inc(MsgCount);
          // Не спрашивайте почему такой изврат с двойным декодированием
          // Какой то непонятный баг в компонентах БД
          // Или у меня руки кривые
          Msg_MyNick := ViewerQuery.FieldByName('my_nick').AsString;
          Msg_MyUIN := ViewerQuery.FieldByName('my_uin').AsString;
          Msg_Nick := ViewerQuery.FieldByName('nick').AsString;
          Msg_UIN := ViewerQuery.FieldByName('uin').AsString;
          Msg_Text := ViewerQuery.FieldByName('msg_text').AsString;
          // Если указан ключь шифрования, то запросим пароль ключа и расшифруем сооббщение
          if not ViewerQuery.FieldByName('key_id').IsNull then
          begin
            EncryptionKeyID := ViewerQuery.FieldByName('key_id').AsString;
            // Читаем структуру ключей
            if MyKeyPasswordPointer.Count > 0 then
            begin
              FoundEncryptKeyID := False;
              MyKeyPasswordCnt := 0;
              //ShowMessage('Main Размер MyKeyPasswordPointer: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount));
              while (not FoundEncryptKeyID) and (MyKeyPasswordCnt < MyKeyPasswordPointer.Count) do
              begin
                {ShowMessage('Main ID: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyID) + #13#10 +
                'Main Passwd: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyPassword + #13#10 +
                'Main Key: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].EncryptionKey);}
                if EncryptionKeyID = IntToStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].KeyID) then
                begin
                  FoundEncryptKeyID := True;
                  EncryptionKey := DecryptStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].EncryptionKey);
                  //ShowMessage('Main FoundEncryptKeyID');
                end;
                Inc(MyKeyPasswordCnt);
              end;
              if not FoundEncryptKeyID then
              begin
                //ShowMessage('Main not FoundEncryptKeyID');
                ReadEncryptionKey;
              end;
            end
            else
            begin
              // Если включено шифрование, то читаем ключ, спрашивем его пароль
              if not Global_KeyPasswdForm_Showing then
                ReadEncryptionKey;
            end;
            if EncryptionKey <> '' then
            begin
              Msg_Text := DecryptMsg(Msg_Text, EncryptionKeyID, EncryptionKey);
              MsgEncryptStatus := 1; // Сообщение расшифровано
            end
            else
            begin
              Msg_Text := GetLangStr('MessageEncrypted');
              MsgEncryptStatus := 2; // Сообщение не расшифровано
            end;
          end
          else
          begin
            MsgEncryptStatus := 0; // Не шифрованое сообщение
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
          end;
          // End
          if IsUTF8String(Msg_MyNick) then
            Msg_MyNick := UTF8ToWideString(Msg_MyNick);
          if IsUTF8String(Msg_MyNick) then
            Msg_MyNick := UTF8ToWideString(Msg_MyNick);
          if IsUTF8String(Msg_MyUIN) then
            Msg_MyUIN := UTF8ToWideString(Msg_MyUIN);
          if IsUTF8String(Msg_MyUIN) then
            Msg_MyUIN := UTF8ToWideString(Msg_MyUIN);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_UIN) then
            Msg_UIN := UTF8ToWideString(Msg_UIN);
          if IsUTF8String(Msg_UIN) then
            Msg_UIN := UTF8ToWideString(Msg_UIN);
          // End
          if (Msg_MyNick <> '') then
            Global_CurrentAccountName := Msg_MyNick;
          if (Msg_MyUIN <> '') then
            Global_CurrentAccountUIN := Msg_MyUIN;
          if ViewerQuery.FieldByName('msg_direction').AsInteger = 0 then
          begin
            AddHistoryInList(Format(MSG_TITLE, [Global_CurrentAccountName, Global_CurrentAccountUIN, ViewerQuery.FieldByName('msg_time').AsString]), MsgEncryptStatus, 0);
            AddHistoryInList(Msg_Text, 0, 5);
          end
          else
          begin
            AddHistoryInList(Format(MSG_TITLE, [Msg_Nick, Msg_UIN, ViewerQuery.FieldByName('msg_time').AsString]), MsgEncryptStatus, 1);
            AddHistoryInList(Msg_Text, 0, 6);
          end;
          ViewerQuery.Next;
        end
      until ViewerQuery.Eof;
      HistoryCount.Caption := IntToStr(MsgCount);
    end
    else if (HistoryType = 2) or (HistoryType = 3) then
    begin
      MsgCount := 0;
      repeat
        if not ViewerQuery.FieldByName('msg_text').IsNull then
        begin
          Inc(MsgCount);
          // Не спрашивайте почему такой изврат с двойным декодированием
          // Какой то непонятный баг в компонентах БД
          // Или у меня руки кривые
          Msg_Text := ViewerQuery.FieldByName('msg_text').AsString;
          Msg_Nick := ViewerQuery.FieldByName('nick_name').AsString;
          // Если указан ключь шифрования, то запросим пароль ключа и расшифруем сооббщение
          if not ViewerQuery.FieldByName('key_id').IsNull then
          begin
            EncryptionKeyID := ViewerQuery.FieldByName('key_id').AsString;
            // Читаем структуру ключей
            if MyKeyPasswordPointer.Count > 0 then
            begin
              FoundEncryptKeyID := False;
              MyKeyPasswordCnt := 0;
              //ShowMessage('Main Размер MyKeyPasswordPointer: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount));
              while (not FoundEncryptKeyID) and (MyKeyPasswordCnt < MyKeyPasswordPointer.Count) do
              begin
                {ShowMessage('Main ID: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyID) + #13#10 +
                'Main Passwd: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].KeyPassword + #13#10 +
                'Main Key: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[MyKeyPasswordCnt].EncryptionKey);}
                if EncryptionKeyID = IntToStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].KeyID) then
                begin
                  FoundEncryptKeyID := True;
                  EncryptionKey := DecryptStr(MyKeyPasswordPointer.PasswordArray[MyKeyPasswordCnt].EncryptionKey);
                  //ShowMessage('Main FoundEncryptKeyID');
                end;
                Inc(MyKeyPasswordCnt);
              end;
              if not FoundEncryptKeyID then
              begin
                //ShowMessage('Main not FoundEncryptKeyID');
                ReadEncryptionKey;
              end;
            end
            else
            begin
              // Если включено шифрование, то читаем ключ, спрашивем его пароль
              if not Global_KeyPasswdForm_Showing then
                ReadEncryptionKey;
            end;
            if EncryptionKey <> '' then
            begin
              Msg_Text := DecryptMsg(Msg_Text, EncryptionKeyID, EncryptionKey);
              MsgEncryptStatus := 1; // Сообщение расшифровано
            end
            else
            begin
              Msg_Text := GetLangStr('MessageEncrypted');
              MsgEncryptStatus := 2; // Сообщение не расшифровано
            end;
          end
          else
          begin
            MsgEncryptStatus := 0; // Не шифрованое сообщение
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
            if IsUTF8String(Msg_Text) then
              Msg_Text := UTF8ToWideString(Msg_Text);
          end;
          // End
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          if IsUTF8String(Msg_Nick) then
            Msg_Nick := UTF8ToWideString(Msg_Nick);
          // End
          //Msg_Text := UnPrepareString(Msg_Text);
          if ViewerQuery.FieldByName('msg_type').AsInteger = 1 then
          begin
            if EncryptionKey = '' then
              AddHistoryInList(Format(CHAT_MSG_TITLE, [Global_CurrentAccountName, ViewerQuery.FieldByName('msg_time').AsString]), 0, 0)
            else
              AddHistoryInList(Format(CHAT_MSG_TITLE, [Global_CurrentAccountName, ViewerQuery.FieldByName('msg_time').AsString]), 1, 0);
            AddHistoryInList(Msg_Text, 0, 5);
          end
          else
          begin
            AddHistoryInList(Format(CHAT_MSG_TITLE, [Msg_Nick, ViewerQuery.FieldByName('msg_time').AsString]), MsgEncryptStatus, 1);
            AddHistoryInList(Msg_Text, 0, 6);
          end;
          ViewerQuery.Next;
        end
      until ViewerQuery.Eof;
      HistoryCount.Caption := IntToStr(MsgCount);
    end;
  end
  else
  begin
    AddHistoryInList(Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 3);
    if WriteErrLog then
      WriteInLog(ProfilePath, Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
  end;
  ZConnection1.Disconnect;
  HistoryRichView.Refresh;
  ToolBar3.Visible := False;
  if HistoryRichView.Lines.Count = 0 then
  begin
    RefreshButton.Enabled := false;
    SaveButton.Enabled := false;
    DeleteButton.Enabled := false;
  end
  else
  begin
    RefreshButton.Enabled := true;
    SaveButton.Enabled := true;
    DeleteButton.Enabled := true;
  end;
  GIFPanel2.Visible := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ShowHistory: ' + Format('Время выполнения: %d мc', [GetTickCount - TC]), 2);
end;

procedure TMainForm.ClearListButtonClick(Sender: TObject);
begin
  HistoryRichView.Clear;
  HistoryRichView.Refresh;
  ToolBar3.Visible := false
end;

procedure TMainForm.ESearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    SearchButtonClick(Sender);
end;

{ Запрос на раскрытие узела }
procedure TMainForm.JvTreeViewExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
var
  ID, I, ProtoID: Integer;
  Data: pMyTreeData;
  UIN, NickName, Chat_Caption, ProtoAcc: WideString;
  Searching, FoundDublicate: Boolean;
  Noddy: TTreeNode;
  TC: Cardinal;
begin
  Node.DeleteChildren;
  if EnableDebug then TC := GetTickCount;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура JvTreeViewExpanding: Запущено обновление дерева TreeView', 2);
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    // Для самого верхнего уровня выбрать только тех,
    // кто не имеет родителей.
    if Node = nil then
      ID := 0
    else
      ID := Node.Index;
    // Включаем панель загрузки...
    JvTreeViewStartDataLoading := True;
    if not SplitterMaximize then
      GIFPanel.Visible := True
    else
      GIFPanel.Visible := False;
    Application.ProcessMessages;
    if ID = 0 then
    begin
      // Проверяем на наличие записей
      if CheckZeroRecordCount('select count(*) AS cnt from uin_'+ DBUserName + '') then
      begin
        // Выключаем панель загрузки...
        GIFPanel.Visible := False;
        Application.ProcessMessages;
        JvTreeViewStartDataLoading := False;
        ZConnection1.Disconnect;
        Exit;
      end
      else
        SQL_Zeos('select nick,uin,proto_name from uin_'+ DBUserName + ' where nick is not null group by uin order by nick asc');
    end
    else
    begin
      // Проверяем на наличие записей
      if CheckZeroRecordCount('select count(*) AS cnt from uin_chat_'+ DBUserName +'') then
      begin
        // Выключаем панель загрузки...
        GIFPanel.Visible := False;
        Application.ProcessMessages;
        JvTreeViewStartDataLoading := False;
        ZConnection1.Disconnect;
        Exit;
      end
      else
        SQL_Zeos('select distinct chat_caption,proto_acc from uin_chat_'+ DBUserName + ' where chat_caption is not null order by chat_caption asc');
    end;
    // Для каждой строки из полученного набора данных
    // формируем ветвь в TreeView, как дочерние ветки к той,
    // которую мы только что "раскрыли"
    JvTreeView.Items.BeginUpdate;
    for I := 0 to ViewerQuery.RecordCount-1 do
    begin
      if ID = 0 then
      begin
        UIN := ViewerQuery.FieldByName('uin').AsString;
        NickName := ViewerQuery.FieldByName('nick').AsString;
        ProtoID := ViewerQuery.FieldByName('proto_name').AsInteger;
        if IsUTF8String(UIN) then
          UIN := UTF8ToWideString(UIN);
        if IsUTF8String(UIN) then
          UIN := UTF8ToWideString(UIN);
        if IsUTF8String(NickName) then
          NickName := UTF8ToWideString(NickName);
        if IsUTF8String(NickName) then
          NickName := UTF8ToWideString(NickName);
        // Ищем дубликаты в JvTreeView
        FoundDublicate := False;
        // Если нет дубликата, то добавляем данные
        if not FoundDublicate then
        begin
          // Запишем в поле Data ветки указатель на структуру pMyTreeData
          New(Data);
          Data.Id := 0;
          Data.UserID := UIN;
          Data.ProtoID := ProtoID;
          TreeNode := JvTreeView.Items.AddChildObject(Node, NickName+' ('+UIN+')', Data);
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
          if (ProtoID >= 0) and (ProtoID < 10) then
          begin
            TreeNode.ImageIndex := ProtoID + 2;
            TreeNode.SelectedIndex := ProtoID + 2;
          end
          else
          begin
            TreeNode.ImageIndex := 11;
            TreeNode.SelectedIndex := 11;
          end;
        end;
      end
      else
      begin
        Chat_Caption := ViewerQuery.FieldByName('chat_caption').AsString;
        ProtoAcc := ViewerQuery.FieldByName('proto_acc').AsString;
        if IsUTF8String(Chat_Caption) then
          Chat_Caption := UTF8ToWideString(Chat_Caption);
        if IsUTF8String(Chat_Caption) then
          Chat_Caption := UTF8ToWideString(Chat_Caption);
        // Запишем в поле Data ветки указатель на структуру pMyTreeData
        New(Data);
        Data.Id := 0;
        Data.UserID := Chat_Caption;
        Data.ProtoID := 0;
        TreeNode := JvTreeView.Items.AddChildObject(Node, Chat_Caption, Data);
        if LowerCase(ProtoAcc) = 'skype' then
        begin
          TreeNode.ImageIndex := 12;
          TreeNode.SelectedIndex := 12;
        end
        else
        begin
          TreeNode.ImageIndex := 5;
          TreeNode.SelectedIndex := 5;
        end;
      end;
      ViewerQuery.Next;
    end;
    JvTreeView.Items.EndUpdate;
    if ViewerQuery.RecordCount > 0 then
      JvTreeView.PopupMenu := TreeViewPM;
    Application.ProcessMessages;
    JvTreeViewStartDataLoading := False;
    // Выключаем панель загрузки...
    GIFPanel.Visible := False;
  end
  else
  begin
    AddHistoryInList(Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 3);
    if WriteErrLog then
      WriteInLog(ProfilePath, Format(ERR_NO_DB_CONNECTED, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
  end;
  ZConnection1.Disconnect;
  ToolBar3.Visible := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура JvTreeViewExpanding: ' + Format('Время обновления дерева TreeView: %d мc', [GetTickCount - TC]), 2);
end;

{ Обработка клика в списке JvTreeView }
procedure TMainForm.JvTreeViewChange(Sender: TObject; Node: TTreeNode);
var
  Last_UIN: WideString;
  Last_Proto: Integer;
begin
  if (JvTreeView.Selected <> nil) and (Node.Data <> nil) then
  begin
    Last_UIN := pMyTreeData(JvTreeView.Selected.Data)^.UserID;
    Last_Proto := pMyTreeData(JvTreeView.Selected.Data)^.ProtoID;
    if JvTreeView.Selected.Parent.AbsoluteIndex = 0 then
    begin
      // История IM-сообщений
      Global_AccountUIN := Last_UIN;
      Glogal_History_Type := 0;
      ShowHistory(Glogal_History_Type, Last_UIN, Last_Proto);
    end
    else if JvTreeView.Selected.Parent.AbsoluteIndex > 0 then
    begin
      // История чат-сообщений
      Global_ChatName := Last_UIN;
      Glogal_History_Type := 2;
      ShowHistory(Glogal_History_Type, Last_UIN, -1);
    end;
  end;
end;

procedure TMainForm.JvTreeViewClick(Sender: TObject);
begin
  if JvTreeView.Selected.Expanded then
    JvTreeView.Selected.Collapse(True)
  else
    JvTreeView.Selected.Expand(True);
end;

procedure TMainForm.JvTreeViewCollapsed(Sender: TObject; Node: TTreeNode);
begin
  Node.DeleteChildren;
  JvTreeView.Items.AddChildObject(Node, '' , nil);
  HistoryRichView.Clear;
end;

{ Отключаем popup меню для вершин }
procedure TMainForm.JvTreeViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  if JvTreeView.Selected.Data <> nil then
    Handled := False
  else
    Handled := True;
end;

procedure TMainForm.JvTreeViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with JvTreeView.Canvas do
    if cdsSelected in State then
    begin
      Brush.Color:= TColor($f5ddc7);  //fbf1e8
      Font.Color := clBlack;
    end;
end;

procedure TMainForm.JvTreeViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  Dispose(Node.Data)
end;

procedure TMainForm.SearchButtonClick(Sender: TObject);
begin
  if ESearch.Text <> '' then
    SearchTextAndSelect(HistoryRichView, ESearch.Text);
end;

procedure TMainForm.SearchHistoryButtonClick(Sender: TObject);
begin
  if (Glogal_History_Type = 0) or (Glogal_History_Type = 1) then
  begin
    if Global_AccountUIN <> '' then
      // История IM-сообщений
      ShowHistory(Glogal_History_Type+1, Global_AccountUIN, Global_Protocol_Type)
  end
  else if (Glogal_History_Type = 2) or (Glogal_History_Type = 3) then
    // История чат-сообщений
    ShowHistory(Glogal_History_Type+1, Global_ChatName, -1)
  else
    MsgInf(MainForm.Caption, GetLangStr('NoSelectContactHistory'));
end;

procedure TMainForm.ShowHistoryDayClick(Sender: TObject);
begin
  StartHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 00:00:00', Now));
  EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 23:59:59', Now));
  SearchHistoryButtonClick(Self);
end;

procedure TMainForm.ShowHistoryMonthClick(Sender: TObject);
var
  Y,M,D: Word;
begin
  DecodeDate(Now, Y, M, D);
  StartHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('01.mm.yy 00:00:00', Now));
  EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime(''+IntToStr(MonthDays[IsLeapYear(Y)][M])+'.mm.yy 23:59:59', Now));
  SearchHistoryButtonClick(Self);
end;

procedure TMainForm.ShowHistoryYearClick(Sender: TObject);
begin
  StartHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('01.01.yy 00:00:00', Now));
  EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('31.12.yy 23:59:59', Now));
  SearchHistoryButtonClick(Self);
end;

procedure TMainForm.ShowHistoryAllClick(Sender: TObject);
begin
  StartHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('01.01.80 00:00:00', Now));
  EndHistoryDateTimePicker.DateTime := StrToDateTime(FormatDateTime('dd.mm.yy 23:59:59', Now));
  SearchHistoryButtonClick(Self);
end;

procedure TMainForm.SettingsButtonClick(Sender: TObject);
begin
  SettingsForm.Show;
end;

procedure TMainForm.ShowSearchButtonClick(Sender: TObject);
begin
  if ToolBar3.Visible then
    ToolBar3.Visible := False
  else
  begin
    ToolBar3.Visible := Length(HistoryRichView.Lines.Text)>0;
    ESearch.Text := HistoryRichView.SelText;
  end;
end;

procedure TMainForm.ExSearchClick(Sender: TObject);
begin
  with HistoryRichView do
    if Length(Lines.Text)>0 then
    begin
      SelStart := 0;
      FindDialog(SelText);
    end;
end;

procedure TMainForm.ExSearchNextClick(Sender: TObject);
begin
  if not HistoryRichView.FindNext then
    Beep;
  FocusHistoryRichView;
end;

procedure TMainForm.HistoryRichViewTextNotFound(Sender: TObject; const FindText: string);
begin
  MsgInf(GetLangStr('SearchCaption'), Format(GetLangStr('SearchMessages'), [FindText]));
end;

{ Клик по ссылке в окне HistoryRichView }
procedure TMainForm.HistoryRichViewURLClick(Sender: TObject; const URLText: string; Button: TMouseButton);
begin
  OpenURL(URLText);
end;

{ Открываем URL }
function TMainForm.OpenURL(URL: String): Cardinal;
var
  DefBrowser: String;
begin
  DefBrowser := DefaultBrowser();
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция OpenURL: Выполняем команду: ' + DefBrowser + ' "'+URL+'"', 2);
  Result := ShellExecute(0, 'open', PChar(DefBrowser), PChar(URL), '', SW_SHOWNORMAL);
end;

{ Определяем браузера по-умолчанию }
function TMainForm.DefaultBrowser: String;
var
  Reg: TRegistry;
  KeyName: String;
  ValueStr: String;
  I: integer;
begin
  Result := 'iexplore.exe';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    KeyName := 'http\shell\open\command';
    if Reg.OpenKey(KeyName, False) then
    begin
      if Reg.ValueExists('') then
      begin
        ValueStr := Reg.ReadString('');
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция DefaultBrowser: Браузер по-умолчанию в реестре: ' + ValueStr, 2);
        I := Pos('.exe', AnsiLowerCase(ValueStr));
        if I > 0 then
        begin
          ValueStr := copy(ValueStr, 1, i - 1) + '.exe';
          if ValueStr[1] = '"' then
            ValueStr := Copy(ValueStr, 2, length(ValueStr) - 1);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция DefaultBrowser: Браузер по-умолчанию: ' + ValueStr, 2);
          Result := ValueStr;
        end;
      end
      else
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция DefaultBrowser: Браузер по-умолчанию не найден. (Не найден ключ в реестре)', 2);
      Reg.CloseKey;
    end
    else
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция DefaultBrowser: Браузер по-умолчанию не найден. (Не могу прочитать ветку реестра HKEY_CLASSES_ROOT\' + KeyName + ')', 2);
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.EditFindDialogClose(Sender: TObject; Dialog: TFindDialog);
begin
  FocusHistoryRichView;
end;

procedure TMainForm.FocusHistoryRichView;
begin
  with HistoryRichView do
    if CanFocus then
      SetFocus;
end;

procedure TMainForm.SyncButtonClick(Sender: TObject);
begin
  // Отправляем запрос HistoryToDbSync для синхронизации
  OnSendMessageToAllComponent('002');
  AddHistoryInList(Format(GetLangStr('SendSyncQuery'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 4);
end;

{ Добавление картинки из ImageList в RichView }
procedure TMainForm.AddImageToRichEdit(const AImageIndex: Integer; ImageLst: TImageList);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    ImageLst.GetBitmap(AImageIndex, Bitmap);
    HistoryRichView.InsertGraphic(Bitmap, False);
    { Перемещаем курсор }
    with HistoryRichView.GetSelection do
      HistoryRichView.SetSelection(cpMin + 1, cpMin + 1, False);
  finally
    Bitmap.Free;
  end;
end;

{ Добавление картинки из Resource в RichView }
procedure TMainForm.AddImageFromResourceToRichEdit(const ResID: String);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromResourceName(HInstance, ResID);
    HistoryRichView.InsertGraphic(Bitmap, False);
    { Перемещаем курсор }
    with HistoryRichView.GetSelection do
      HistoryRichView.SetSelection(cpMin + 1, cpMin + 1, False);
  finally
    Bitmap.Free;
  end;
end;

{ Добавление строки в QIPRichView }
procedure TMainForm.AddHistoryInList(Str: WideString; Encrypt: Integer; TextType: Integer);
begin
  Str := Str + #13#10;
  HistoryRichView.SetSelection(MaxInt, MaxInt, False);
  if TextType = 0 then // Исходящее сообщение
  begin
    if Encrypt = 0 then
      AddImageToRichEdit(0, ImageList_RichEdit)
    else if Encrypt = 1 then
      AddImageToRichEdit(5, ImageList_RichEdit)
    else
      AddImageToRichEdit(6, ImageList_RichEdit);
    IMEditorParagraph.SpaceBefore := IMEditorParagraphTitleSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphTitleSpaceAfter;
    HistoryRichView.AddFormatText(' ' + Str, FHeaderFontOutTitle);
  end
  else if TextType = 1 then // Входящее сообщение
  begin
    if Encrypt = 0 then
      AddImageToRichEdit(1, ImageList_RichEdit)
    else if Encrypt = 1 then
      AddImageToRichEdit(5, ImageList_RichEdit)
    else
      AddImageToRichEdit(6, ImageList_RichEdit);
    IMEditorParagraph.SpaceBefore := IMEditorParagraphTitleSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphTitleSpaceAfter;
    HistoryRichView.AddFormatText(' ' + Str, FHeaderFontInTitle);
  end
  else if TextType = 2 then // БД на сервисном обслуживании
  begin
    AddImageToRichEdit(2, ImageList_RichEdit);
    HistoryRichView.AddFormatText(' ' + Str, FHeaderFontServiceMsg);
  end
  else if TextType = 3 then // БД недоступна
  begin
    AddImageToRichEdit(3, ImageList_RichEdit);
    FHeaderFontServiceMsg.Color := clRed;
    HistoryRichView.AddFormatText(' ' + Str, FHeaderFontServiceMsg);
  end
  else if TextType = 4 then // Загрузка отложенных сообщений
  begin
    AddImageToRichEdit(4, ImageList_RichEdit);
    HistoryRichView.AddFormatText(' ' + Str, FHeaderFontServiceMsg);
  end
  else if TextType = 5 then // Тело исходящего сообщения
  begin
    IMEditorParagraph.SpaceBefore := IMEditorParagraphMessagesSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphMessagesSpaceAfter;
    //if MatchStrings(DBType, 'postgresql*') or MatchStrings(DBType, 'firebird*') or MatchStrings(DBType, 'sqlite*') then
    Str := UnPrepareString(Str);
    HistoryRichView.AddFormatText(Str, FHeaderFontOutBody);
  end
  else if TextType = 6 then // Тело входящего сообщения
  begin
    IMEditorParagraph.SpaceBefore := IMEditorParagraphMessagesSpaceBefore;
    IMEditorParagraph.SpaceAfter := IMEditorParagraphMessagesSpaceAfter;
    //if MatchStrings(DBType, 'postgresql*') or MatchStrings(DBType, 'firebird*') or MatchStrings(DBType, 'sqlite*') then
    Str := UnPrepareString(Str);
    HistoryRichView.AddFormatText(Str, FHeaderFontInBody);
  end;
  HistoryRichView.SetSelection(MaxInt, MaxInt, True);
end;

procedure TMainForm.HistoryRichViewChange(Sender: TObject);
begin
  if HistoryRichView.Lines.Count = 0 then
  begin
    RefreshButton.Enabled := false;
    SaveButton.Enabled := false;
    DeleteButton.Enabled := false;
  end
  else
  begin
    RefreshButton.Enabled := true;
    SaveButton.Enabled := true;
    DeleteButton.Enabled := true;
  end;
end;

procedure TMainForm.ImportICQClick(Sender: TObject);
begin
  HistoryImportType := 1;
  if FileExists(PluginPath + 'HistoryToDBImport.exe') then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ImportICQClick: Запускаем ' + PluginPath + 'HistoryToDBImport.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"', 2);
    ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBImport.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"'), nil, SW_SHOWNORMAL);
  end
  else
    AddHistoryInList(Format(GetLangStr('ERR_NO_FOUND_IMPORT'), [PluginPath + 'HistoryToDBImport.exe']), 0, 4);
end;

procedure TMainForm.ImportMirandaClick(Sender: TObject);
begin
  MsgInf(ProgramsName, GetLangStr('MirandaImportInfo'));
end;

procedure TMainForm.ImportRnQClick(Sender: TObject);
begin
  HistoryImportType := 2;
  if FileExists(PluginPath + 'HistoryToDBImport.exe') then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ImportRnQClick: Запускаем ' + PluginPath + 'HistoryToDBImport.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"', 2);
    ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBImport.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"'), nil, SW_SHOWNORMAL);
  end
  else
    AddHistoryInList(Format(GetLangStr('ERR_NO_FOUND_IMPORT'), [PluginPath + 'HistoryToDBImport.exe']), 0, 4);
end;

procedure TMainForm.ImportQIP2005Click(Sender: TObject);
begin
  HistoryImportType := 3;
  if FileExists(PluginPath + 'HistoryToDBImport.exe') then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ImportQIP2005Click: Запускаем ' + PluginPath + 'HistoryToDBImport.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"', 2);
    ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBImport.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"'), nil, SW_SHOWNORMAL);
  end
  else
    AddHistoryInList(Format(GetLangStr('ERR_NO_FOUND_IMPORT'), [PluginPath + 'HistoryToDBImport.exe']), 0, 4);
end;

procedure TMainForm.ImportQIPInfiumClick(Sender: TObject);
begin
  HistoryImportType := 4;
  if FileExists(PluginPath + 'HistoryToDBImport.exe') then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура ImportQIPInfiumClick: Запускаем ' + PluginPath + 'HistoryToDBImport.exe' + ' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"', 2);
    ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBImport.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" '+IntToStr(HistoryImportType)+' "'+Global_CurrentAccountUIN+'" "'+Global_CurrentAccountName+'"'), nil, SW_SHOWNORMAL);
  end
  else
    AddHistoryInList(Format(GetLangStr('ERR_NO_FOUND_IMPORT'), [PluginPath + 'HistoryToDBImport.exe']), 0, 4);
end;

{ Устанавливаем настройки подключения к БД }
procedure TMainForm.LoadDBSettings;
begin
  ZConnection1.Protocol := DBType;
  if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
  begin
    ZConnection1.HostName := '';
    ZConnection1.Port := 0;
    ZConnection1.User := '';
    ZConnection1.Password := '';
    ZConnection1.Properties.Clear;
  end
  else // MySQL, PostgreSQL, Oracle и т.д.
  begin
    ZConnection1.HostName := DBAddress;
    ZConnection1.Port := StrToInt(DBPort);
    ZConnection1.User := DBUserName;
    ZConnection1.Password := DBPasswd;
    ZConnection1.Properties.Clear;
    ZConnection1.Properties.Add('codepage=UTF8');
  end;
  // Замена подстроки в строке DBName
  if MatchStrings(DBName,'<ProfilePluginPath>*') then
    DBName := StringReplace(DBName,'<ProfilePluginPath>',ProfilePath,[RFReplaceall])
  else if MatchStrings(DBName,'<PluginPath>*') then
    DBName := StringReplace(DBName,'<PluginPath>',ExtractFileDir(PluginPath),[RFReplaceall]);
  // End
  ZConnection1.Database := DBName;
  ZConnection1.LoginPrompt := false;
end;

{ Выполняется после ZConnection1.Connection
  для смены схемы в БД Oracle }
procedure TMainForm.ZConnection1AfterConnect(Sender: TObject);
begin
  if (ZConnection1.Protocol = 'oracle') or (ZConnection1.Protocol = 'oracle-9i') then
    SQL_Zeos_Exec('alter session set current_schema='+DBSchema);
  // Проверка на сервисный режим
  if not SettingsForm.Showing then
  begin
    if CheckServiceMode then
      ZConnection1.Disconnect;
  end;
end;

{ Выделить весь текст в QIPRichView }
procedure TMainForm.SelectAllClick(Sender: TObject);
begin
  HistoryRichView.SelectAll;
  HistoryRichView.Invalidate;
end;

{ Скопировать в буфер весь текст в QIPRichView }
procedure TMainForm.CopyStrClick(Sender: TObject);
begin
  HistoryRichView.CopyToClipboard;
end;

procedure TMainForm.DeleteContactClick(Sender: TObject);
begin
  ButtonDeleteHistoryClick(Self);
end;

procedure TMainForm.ButtonDeleteHistoryClick(Sender: TObject);
begin
  if AlphaBlendEnable then
    PostMessage(Handle, WM_USER + 2, 0, 0);
  case MessageBox(Handle,PWideChar(GetLangStr('DeleteHistory')),PWideChar(GetLangStr('DeleteHistoryCaption')),36) of
    6:
    begin
      if (Glogal_History_Type = 0) or (Glogal_History_Type = 1) then
        DeleteHistory(Global_AccountUIN, Global_CurrentAccountUIN, 0)
      else if (Glogal_History_Type = 2) or (Glogal_History_Type = 3) then
        DeleteHistory(Global_ChatName, 'null', 1)
      else
        MsgInf(MainForm.Caption, GetLangStr('NoDeleteSelectHistory'));
    end;
    7: Exit;
  end;
end;

procedure TMainForm.DeleteAllHistoryClick(Sender: TObject);
begin
  if AlphaBlendEnable then
    PostMessage(Handle, WM_USER + 2, 0, 0);
  case MessageBox(Handle,PWideChar(GetLangStr('DeleteAllHistory')),PWideChar(GetLangStr('DeleteHistoryCaption')),36) of
    6: DeleteHistory('', '', 2);
    7: Exit;
  end;
end;

procedure TMainForm.DeleteHistory(AccountUIN, MyAccountUIN: WideString; DeleteHistoryType: Integer);
var
  TC: Cardinal;
begin
  if EnableDebug then TC := GetTickCount;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DeleteHistory: Запущено удаление истории', 2);
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    // Показываем панель для ожидания
    GIFPanel2.Left := HistoryRichView.Left + (HistoryRichView.Width div 2) - (GIFPanel2.Width div 2);
    GIFPanel2.Top := (HistoryRichView.Height div 2) + (GIFPanel2.Height div 2);
    GIFStaticText2.Caption := GetLangStr('GIFStaticTextDelete');
    GIFStaticText2.Hint := 'GIFStaticTextDelete';
    GIFPanel2.Visible := True;
    Application.ProcessMessages;
    if DeleteHistoryType = 0 then
    begin
      SQL_Zeos_Exec('delete from uin_'+ DBUserName + ' where uin = '''+ AccountUIN +''' and my_uin = '''+ MyAccountUIN + ''';');
      if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
        SQL_Zeos_Exec('commit;');
    end
    else if DeleteHistoryType = 1 then
    begin
      SQL_Zeos_Exec('delete from uin_chat_'+ DBUserName + ' where chat_caption = '''+ WideStringToUTF8(AccountUIN) + ''';');
      if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
        SQL_Zeos_Exec('commit;');
    end
    else
    begin
      SQL_Zeos_Exec('delete from uin_'+ DBUserName + ';');
      SQL_Zeos_Exec('delete from uin_chat_'+ DBUserName + ';');
      if (DBType = 'sqlite') or (DBType = 'sqlite-3') then
        SQL_Zeos_Exec('commit;');
    end;
    HistoryRichView.Clear;
    HistoryRichView.Refresh;
    // Убираем панель для ожидания
    GIFPanel2.Visible := False;
    JvTreeView.FullCollapse;
  end;
  ZConnection1.Disconnect;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DeleteHistory: ' + Format('Время выполнения: %d мc', [GetTickCount - TC]), 2);
end;

procedure TMainForm.ButtonRefreshClick(Sender: TObject);
begin
  if (Glogal_History_Type = 0) or (Glogal_History_Type = 1) then
  begin
    if Global_AccountUIN <> '' then
      ShowHistory(Glogal_History_Type, Global_AccountUIN, Global_Protocol_Type)
  end
  else if (Glogal_History_Type = 2) or (Glogal_History_Type = 3) then
  begin
    if Global_AccountUIN <> '' then
      ShowHistory(Glogal_History_Type, Global_ChatName, -1)
  end
  else if Glogal_History_Type = 10 then
    ShowSummaryHistory
  else
    MsgInf(MainForm.Caption, GetLangStr('NoSelectContactRefreshHistory'));
end;

procedure TMainForm.ButtonSaveHistoryClick(Sender: TObject);
begin
  if SaveHistoryDialog.Execute then
    HistoryRichView.Lines.SaveToFile(SaveHistoryDialog.FileName);
end;

procedure TMainForm.CheckMD5HashClick(Sender: TObject);
begin
  // Запрос на перерасчет MD5-хешей
  OnSendMessageToAllComponent('0050');
  AddHistoryInList(Format(GetLangStr('SendCheckMD5HashQuery'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 4);
end;

procedure TMainForm.CheckAndDeleteMD5HashClick(Sender: TObject);
begin
  // Запрос на перерасчет MD5-хешей и удаление дубликатов
  OnSendMessageToAllComponent('0051');
  AddHistoryInList(Format(GetLangStr('SendCheckAndDeleteMD5HashQuery'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 4);
end;

procedure TMainForm.UpdateContactListInDBClick(Sender: TObject);
begin
  // Запрос на обновление контакт листа
  if FileExists(ProfilePath+ContactListName) then
  begin
    OnSendMessageToAllComponent('007');
    AddHistoryInList(Format(GetLangStr('SendUpdateContactListInDB'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ContactListName]), 0, 4);
  end
  else
  begin
    if IMClientType = 'QIP' then
    begin
      AddHistoryInList(Format(GetLangStr('SendUpdateContactListInDBErrQIP'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ProfilePath+ContactListName]), 0, 4);
      // Выводим картинку с подсказкой
      HistoryRichView.AddFormatText(#13#10, FHeaderFontServiceMsg);
      HistoryRichView.SetSelection(MaxInt, MaxInt, True);
      if FLanguage = 'Russian' then
        AddImageFromResourceToRichEdit('SAVECONTACTQIPRU')
      else
        AddImageFromResourceToRichEdit('SAVECONTACTQIPEN');
      HistoryRichView.AddFormatText(#13#10#13#10, FHeaderFontServiceMsg);
      HistoryRichView.SetSelection(MaxInt, MaxInt, True);
    end
    else if IMClientType = 'RnQ' then
    begin
      AddHistoryInList(Format(GetLangStr('SendUpdateContactListInDBErrRnQ'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ProfilePath+ContactListName]), 0, 4);
      // Выводим картинку с подсказкой
      HistoryRichView.AddFormatText(#13#10, FHeaderFontServiceMsg);
      HistoryRichView.SetSelection(MaxInt, MaxInt, True);
      if FLanguage = 'Russian' then
        AddImageFromResourceToRichEdit('SAVECONTACTRNQRU')
      else
        AddImageFromResourceToRichEdit('SAVECONTACTRNQRU');
      HistoryRichView.AddFormatText(#13#10#13#10, FHeaderFontServiceMsg);
      HistoryRichView.SetSelection(MaxInt, MaxInt, True);
    end
    else
      AddHistoryInList(Format(GetLangStr('SendUpdateContactListInDBErrUnknown'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), ProfilePath+ContactListName]), 0, 4)
  end;
end;

{ Логгирование SQL запросов для отладки }
procedure TMainForm.ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
begin
  if EnableDebug then
  begin
    if Trim(Event.Error) > '' then
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - Процедура ZSQLMonitor1Trace: ' + Trim(Event.Message) + ' | Error: ' + Event.Error, 2)
    else
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - Процедура ZSQLMonitor1Trace: ' + Trim(Event.Message), 2);
  end;
end;

{ Проверка на сервисный режим }
function TMainForm.CheckServiceMode: Boolean;
var
  Query: TZQuery;
  System_Disable: Integer;
begin
  Result := False;
  if ZConnection1.Connected then
  begin
    Query := TZQuery.Create(nil);
    Query.Connection := ZConnection1;
    Query.ParamCheck := False;
    Query.SQL.Clear;
    Query.SQL.Text := 'select config_value from config where config_name = ''system_disable''';
    try
      Query.Open;
      System_Disable := Query.FieldByName('config_value').AsInteger;
      Query.Close;
      if System_Disable = 1 then
      begin
        AddHistoryInList(Format(ERR_READ_DB_SERVICE_MODE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 2);
        HistoryRichView.Refresh;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckServiceMode: БД на сервисном обслуживании.', 2);
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
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckServiceMode: Соединение с БД не установлено.', 2);
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

{ Мой вариант поиска текста в JvRichEdit и его выделение
  Хотя есть и стандартный диалог поиска ;) }
function TMainForm.SearchTextAndSelect(RichView: TJvRichEdit; SearchText: String): boolean;
var
  StartPos, EndPos, Pos: Integer;
  SearchType: TRichSearchTypes;
begin
  with RichView do
  begin
      if CBSearchCase.Checked then
        SearchType := [stMatchCase]
      else
        SearchType := [];
      if SelLength = 0 then
      begin
        StartPos := 0;
        EndPos := Length(Text);
      end
      else
      begin
        StartPos := SelStart + Length(SearchText);
        EndPos := Length(Text) - StartPos;
      end;
      Pos := FindText(SearchText, StartPos, EndPos, SearchType); //stBackward, stWholeWord, stMatchCase
      SetFocus;
      SelStart := Pos;
      SelLength := Length(SearchText);
      if Pos = -1 then
      begin
        SelLength := 0;
        SelStart := 0;
        SetFocus;
        Result := False;
        MsgInf(GetLangStr('SearchCaption'), GetLangStr('SearchMessage'));
      end
      else
        Result := True;
   end;
end;

{ Поддержка режима Анти-босс }
procedure TMainForm.AntiBoss(HideAllForms: Boolean);
begin
  if not Assigned(MainForm) then Exit;
  if not Assigned(SettingsForm) then Exit;
  if not Assigned(KeyPasswdForm) then Exit;
  if HideAllForms then
  begin
    ShowWindow(MainForm.Handle, SW_HIDE);
    MainForm.Hide;
    ShowWindow(SettingsForm.Handle, SW_HIDE);
    SettingsForm.Hide;
    ShowWindow(KeyPasswdForm.Handle, SW_HIDE);
    KeyPasswdForm.Hide;
  end
  else
  begin
    // Если форма была ранее открыта, то показываем её
    if Global_MainForm_Showing then
    begin
      ShowWindow(MainForm.Handle, SW_SHOW);
      MainForm.Show;
      // Если форма свернута, то разворачиваем её поверх всех окон
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
    if Global_SettingsForm_Showing then
    begin
      ShowWindow(SettingsForm.Handle, SW_SHOW);
      SettingsForm.Show;
    end;
    if Global_KeyPasswdForm_Showing then
    begin
      ShowWindow(KeyPasswdForm.Handle, SW_SHOW);
      KeyPasswdForm.Show;
    end;
  end;
end;

{ Прием управляющих команд от плагина по событию WM_COPYDATA }
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
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Получено шифрованное управляющее сообщение: ' + EncryptControlStr, 2);
    ControlStr := DecryptStr(EncryptControlStr);
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Управляющее сообщение расшифровано: ' + ControlStr, 2);
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
    // 001 - Перечитать настройки из файла HistoryToDB.ini
    if ControlStr = '001' then
    begin
      // Читаем настройки
      LoadINI(ProfilePath, true);
      // Устанавливаем настройки соединения с БД
      LoadDBSettings;
    end;
    // 003 - Выход из программы
    // 009 - Принудительный выход из программы
    if (ControlStr = '003') or (ControlStr = '009') then
      Close;
    // 004 - Режим Анти-босс
    if ControlStr = '0040' then // Показать формы
      AntiBoss(False);
    if ControlStr = '0041' then // Скрыть формы
      AntiBoss(True);
    if ControlStr = '005' then  // Показать окно настроек
    begin
      if not SettingsForm.Showing then
        SettingsForm.Show;
    end;
    if MatchStrings(ControlStr, '008|*') then  // Показать историю контакта/чата
    begin
      TmpStr := Tok('|', ControlStr);
      if TmpStr = '008' then
      begin
        TmpStr := Tok('|', ControlStr);
        if TmpStr = '0' then
        begin
          TmpUserID := Tok('|', ControlStr);
          TmpUserName := Tok('|', ControlStr);
          TmpProtocolType := Tok('|', ControlStr);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Показ истории контакта: ' + TmpUserID + ' | ' + TmpUserName + ' | ' + TmpProtocolType, 2);
          Glogal_History_Type := 0;
          Global_AccountUIN := TmpUserID;
          Global_AccountName := TmpUserName;
          Global_Protocol_Type := StrToInt(TmpProtocolType);
          ShowHistory(Glogal_History_Type, Global_AccountUIN, Global_Protocol_Type);
          AntiBoss(False); // Показать формы
        end;
        if TmpStr = '2' then
        begin
          TmpChatName := Tok('|', ControlStr);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Показ истории чата: ' + TmpChatName, 2);
          Glogal_History_Type := 2;
          Global_ChatName := TmpChatName;
          ShowHistory(Glogal_History_Type, Global_ChatName, -1);
          AntiBoss(False); // Показать формы
        end;
      end;
    end;
  end;
end;

{ Обработка горячих клавиш }
procedure TMainForm.DoHotKey(Sender:TObject);
begin
  if ShortCutToText((Sender as TJvApplicationHotKey).HotKey) = SyncHotKey then
    SyncButtonClick(SyncButton);
  if ShortCutToText((Sender as TJvApplicationHotKey).HotKey) = ExSearchHotKey then
    ExSearchClick(Self);
  if ShortCutToText((Sender as TJvApplicationHotKey).HotKey) = ExSearchNextHotKey then
    ExSearchNextClick(Self);
end;

{ Выводим окно для ввода пароля ключа шифрования }
procedure TMainForm.ReadEncryptionKey;
var
  EncryptionKeyPassword, KeyPassword: String;
  TempEncryptionKey: String;
  Status, I, pCnt: Integer;
begin
  if not KeyPasswdSave then
  begin
      KeyPasswdForm.Show;
      while Global_KeyPasswdForm_Showing do
      begin
        Sleep(1);
        Application.ProcessMessages;
      end;
  end
  else
  begin
    EncryptionKeyPassword := ReadCustomINI(ProfilePath, 'Main', 'KeyPasswd'+EncryptionKeyID, 'NoKeyPasswd');
    if (EncryptionKeyPassword = 'NoSave') or (EncryptionKeyPassword = 'NoKeyPasswd') then
    begin
      KeyPasswdForm.Show;
      while Global_KeyPasswdForm_Showing do
      begin
        Sleep(1);
        Application.ProcessMessages;
      end;
    end
    else
    begin
      KeyPassword := DecryptStr(EncryptionKeyPassword);
      Status := GetEncryptionKey(KeyPassword, TempEncryptionKey, EncryptionKeyID);
      if Status = 1 then // Ошибка - Неверный пароль ключа
        MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('ErrKeyPassword'))
      else if Status = 2 then // Пароль верный, ключ получен
      begin
        EncryptionKey := TempEncryptionKey;
        // Проверяем наличие такого пароля и ключа в структуре
        if MyKeyPasswordPointer.Count > 0 then
        begin
          for I := 0 to MyKeyPasswordPointer.Count-1 do
          begin
            // Такого ключа у нас нет, создаем структуру и пишем туда данные
            if EncryptionKeyID <> IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID) then
            begin
             // Заполняем массив в структуре для нового пароля и ключа шифрования
              pCnt := MyKeyPasswordPointer.Count;
              MyKeyPasswordPointer.Count := pCnt+1;
              SetLength(MyKeyPasswordPointer.PasswordArray, MyKeyPasswordPointer.Count);
              MyKeyPasswordPointer.PasswordArray[pCnt].KeyID := StrToInt(EncryptionKeyID);
              MyKeyPasswordPointer.PasswordArray[pCnt].KeyPassword := EncryptStr(KeyPassword);
              MyKeyPasswordPointer.PasswordArray[pCnt].EncryptionKey := EncryptStr(EncryptionKey);
            end;
          end;
        end
        else
        begin
          // Заполняем массив в структуре для нового пароля и ключа шифрования
          MyKeyPasswordPointer.Count := 1;
          SetLength(MyKeyPasswordPointer.PasswordArray, MyKeyPasswordPointer.Count);
          MyKeyPasswordPointer.PasswordArray[0].KeyID := StrToInt(EncryptionKeyID);
          MyKeyPasswordPointer.PasswordArray[0].KeyPassword := EncryptStr(KeyPassword);
          MyKeyPasswordPointer.PasswordArray[0].EncryptionKey := EncryptStr(EncryptionKey);
        end;
      end
      else if Status = 3 then // Ошибка расшифровки
        MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncErrDecryptKey'))
      else if Status = 4 then // Ошибка - Не найдено нужного ключа
        MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncNoKey'))
      else // Ошибка - Нет доступа к БД
        MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('ErrDBConnect'));
    end;
  end;
end;

{ Получаем ключь шифрования из БД }
function TMainForm.GetEncryptionKey(KeyPwd: String; var EncryptKey: String; EncryptKeyID: String): Integer;
var
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  KeyCnt, Status: Integer;
  DBKeyID, DBKeyEncryptionMethod, DBEncryptKey: String;
  FinalFullKey, FinalKeyID, FinalKeyEncryptionMethod, FinalKey: String;
begin
  if not ZConnection1.Connected then
  begin
    try
      ZConnection1.Connect;
    except
      on e :
        Exception do
        begin
          Status := 5; // Ошибка - Нет доступа к БД
          Exit;
        end
    end;
  end;
  if ZConnection1.Connected then
  begin
    SQL_Zeos_Key('select count(*) as cnt from key_'+ DBUserName + ' where id = '+EncryptKeyID+'');
    KeyCnt := KeyQuery.FieldByName('cnt').AsInteger;
    if KeyCnt <> 0 then
    begin
      MainForm.SQL_Zeos_Key('select id, encryption_method, encryption_key from key_'+ DBUserName + ' where id = '+EncryptKeyID+'');
      DBEncryptKey := KeyQuery.FieldByName('encryption_key').AsString;
      DBKeyID := KeyQuery.FieldByName('id').AsString;
      DBKeyEncryptionMethod := KeyQuery.FieldByName('encryption_method').AsString;
      // Инициализация функции хеширования SHA1
      Hash:= TDCP_sha1.Create(Self);
      Hash.Init;
      Hash.UpdateStr(KeyPwd);
      Hash.Final(Digest);
      Hash.Free;
      // Инициализация функции шифрования 3DES
      Cipher := TDCP_3des.Create(Self);
      Cipher.Init(Digest, Sizeof(Digest)*8, nil);
      // End
      // Расшифровываем ключ введенным паролем по алгоритму 3DES
      try
        Cipher.Reset;
        FinalFullKey := Cipher.DecryptString(DBEncryptKey);
        FinalKeyID :=  Tok('|', FinalFullKey);
        FinalKeyEncryptionMethod := Tok('|', FinalFullKey);
        FinalKey := Tok('|', FinalFullKey);
        if (DBKeyID <> FinalKeyID) and (DBKeyEncryptionMethod <> FinalKeyEncryptionMethod) then
        begin
          Status := 1; // Ошибка - Неверный пароль ключа
        end
        else
        begin
          EncryptKey := Base64DecodeStr(FinalKey);
          Status := 2;
        end;
      except
        on e :
          Exception do
            Status := 3; // Ошибка расшифровки
      end;
      Cipher.Burn;
      Cipher.Free;
    end
    else
      Status := 4; // Ошибка - Не найдено нужного ключа
  end;
  //ZConnection1.Disconnect;
  Result := Status;
end;

{ Расшифровываем поле сообщения }
function TMainForm.DecryptMsg(MsgStr: WideString; EncryptKeyID, EncryptKey: String): WideString;
var
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  MsgStrTmp: WideString;
begin
  // Инициализация функции хеширования SHA1
  Hash:= TDCP_sha1.Create(Self);
  Hash.Init;
  Hash.UpdateStr(EncryptKey);
  Hash.Final(Digest);
  Hash.Free;
  // Инициализация функции шифрования 3DES
  Cipher := TDCP_3des.Create(Self);
  Cipher.Init(Digest, Sizeof(Digest)*8, nil);
  // End
  try
    Cipher.Reset;
    MsgStrTmp := Cipher.DecryptString(MsgStr);
    if IsUTF8String(MsgStrTmp) then
      MsgStrTmp := UTF8ToWideString(MsgStrTmp);
    if IsUTF8String(MsgStrTmp) then
      MsgStrTmp := UTF8ToWideString(MsgStrTmp);
    Result := MsgStrTmp;
  finally
    Cipher.Burn;
    Cipher.Free;
  end;
end;

{ Подключенгие к БД с обработкой ошибок }
procedure TMainForm.ConnectDB;
begin
  // Подключаемся к базе
  if not ZConnection1.Connected then
  begin
    try
      ZConnection1.Connect;
    except
      on e: Exception do
      begin
        AddHistoryInList(Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 0, 3);
        HistoryRichView.Refresh;
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
        ZConnection1.Disconnect;
        if not ReConnectDB then
          Exit;
      end;
    end;
  end;
end;

{ Обновление дерева JvTreeView }
procedure TMainForm.JvTreeViewMake;
begin
  JvTreeView.FullCollapse;
  JvTreeView.Items.BeginUpdate;
  if Assigned(TreeNodes) then
    TreeNodes.Destroy;
  TreeNodes := TTreeNodes.Create(JvTreeView);
  TreeNode := TreeNodes.Add(nil,GetLangStr('IMCaption'));
  TreeNode.ImageIndex := 0;
  TreeNode.SelectedIndex := 1;
  // Добавим фиктивную (пустую) дочернюю ветвь только для того,
  // чтобы был отрисован [+] на ветке и ее можно было бы раскрыть
  JvTreeView.Items.AddChildObject(TreeNode, '' , nil);
  // End
  TreeNode := TreeNodes.Add(nil,GetLangStr('CHATCaption'));
  TreeNode.ImageIndex := 0;
  TreeNode.SelectedIndex := 1;
  // Добавим фиктивную (пустую) дочернюю ветвь только для того,
  // чтобы был отрисован [+] на ветке и ее можно было бы раскрыть
  JvTreeView.Items.AddChildObject(TreeNode, '' , nil);
  JvTreeView.Items.EndUpdate;
end;

function TMainForm.ReConnectDB: Boolean;
var
  I: Integer;
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Запуск.', 2);
  if not ZConnection1.Connected then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Нет подключения к БД.', 2);
    // Пробуем переподключиться
    I := 0;
    while (not ZConnection1.Connected) and (I < ReconnectCount) do
    begin
      Inc(I);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Выполняем ZConnection1.Connect #' + IntToStr(I), 2);
      AddHistoryInList(Format(GetLangStr('DBReConnectNum'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now), IntToStr(I)]), 0, 3);
      HistoryRichView.Refresh;
      try
        ZConnection1.Connect;
      except
        on e: Exception do
        begin
          AddHistoryInList(Format(GetLangStr('DBReConnectErr'), [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 0, 3);
          if WriteErrLog then
            WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в функции ReConnectDB: ' + Trim(e.Message), 2);
          ZConnection1.Disconnect;
        end;
      end;
      //IMDelay(ReconnectInterval);
      Sleep(ReconnectInterval);
    end;
    if ZConnection1.Connected then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Подключение к БД установлено.', 2);
      Result := True;
    end
    else
    begin
      AddHistoryInList('[' + FormatDateTime('dd.mm.yy hh:mm:ss', Now) + '] ' + GetLangStr('ErrDBConnect') + ' ' + GetLangStr('SeeErrLog'), 0, 3);
      HistoryRichView.Refresh;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Выполнено ' + IntToStr(ReconnectCount) + ' попыток подключения к БД с интервалом ' + IntToStr(ReconnectInterval) + ' мсек. Подключиться к БД не удалось.', 2);
      Result := False;
    end;
  end
  else
    Result := True;
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TMainForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Отлавливаем событие WM_MSGBOX для изменения прозрачности окна }
procedure TMainForm.msgBoxShow(var Msg: TMessage);
var
  msgbHandle: HWND;
begin
  msgbHandle := GetActiveWindow;
  if msgbHandle <> 0 then
    MakeTransp(msgbHandle);
end;

{ Функция для мультиязыковой поддержки }
procedure TMainForm.CoreLanguageChanged;
var
  LangFile: String;
begin
  if IMCoreLanguage = '' then
    Exit;
  try
    LangFile := PluginPath + dirLangs + IMCoreLanguage + '.xml';
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
    //Global.CoreLanguage := CoreLanguage;
    SendMessage(MainFormHandle, WM_LANGUAGECHANGED, 0, 0);
    SendMessage(SettingsFormHandle, WM_LANGUAGECHANGED, 0, 0);
    SendMessage(KeyPasswdFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(ProgramsName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + IMCoreLanguage);
  end;
end;

{ Для мультиязыковой поддержки }
procedure TMainForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType + ' (' + MyAccount + ')'
  else
    Caption := ProgramsName;
  ShowSearchButton.Hint := GetLangStr('ShowSearchButton');
  ClearListButton.Hint := GetLangStr('ClearListButton');
  RefreshButton.Hint := GetLangStr('ButtonRefreshHistory');
  SaveButton.Hint := GetLangStr('ButtonSaveHistory');
  DeleteButton.Hint := GetLangStr('ButtonDeleteHistory');
  SyncButton.Hint := GetLangStr('SyncButton');
  ImportButton.Hint := GetLangStr('ImportButton');
  ImportPM.Items[0].Caption := GetLangStr('ImportPM_ICQ');
  ImportPM.Items[1].Caption := GetLangStr('ImportPM_RnQ');
  ImportPM.Items[2].Caption := GetLangStr('ImportPM_QIP2005');
  ImportPM.Items[3].Caption := GetLangStr('ImportPM_QIPInfium');
  ImportPM.Items[4].Caption := GetLangStr('ImportPM_Miranda');
  ImportPM.Items[5].Caption := GetLangStr('ImportPM_qutIM');
  DeleteHistoryPM.Items[0].Caption := GetLangStr('ButtonDeleteCurrentHistory');
  DeleteHistoryPM.Items[1].Caption := GetLangStr('ButtonDeleteAllHistory');
  HistoryShowPM.Items[0].Caption := GetLangStr('ShowHistoryDay');
  HistoryShowPM.Items[1].Caption := GetLangStr('ShowHistoryMonth');
  HistoryShowPM.Items[2].Caption := GetLangStr('ShowHistoryYear');
  HistoryShowPM.Items[3].Caption := GetLangStr('ShowHistoryAll');
  DBServiceButton.Hint := GetLangStr('DBServiceButton');
  DBServicePM.Items[0].Caption := GetLangStr('CheckMD5Hash');
  DBServicePM.Items[1].Caption := GetLangStr('CheckAndDeleteMD5Hash');
  DBServicePM.Items[2].Caption := GetLangStr('UpdateContactListInDB');
  TreeViewPM.Items[0].Caption := GetLangStr('Rename');
  TreeViewPM.Items[1].Caption := GetLangStr('Merge');
  TreeViewPM.Items[2].Caption := GetLangStr('Delete');
  SettingsButton.Hint := GetLangStr('SettingsButton');
  JvEditSearchContact.EmptyValue := GetLangStr('SearchContact');
  LHistory1.Caption := GetLangStr('LHistory1');
  LHistory2.Caption := GetLangStr('LHistory2');
  SearchHistoryButton.Caption := GetLangStr('SearchHistoryButton');
  // Позиционируем лейблы
  StartHistoryDateTimePicker.Left := LHistory1.Left + 3 + LHistory1.Width;
  LHistory2.Left := StartHistoryDateTimePicker.Left + 3 + StartHistoryDateTimePicker.Width;
  EndHistoryDateTimePicker.Left := LHistory2.Left + 3 + LHistory2.Width;
  SearchHistoryButton.Left := EndHistoryDateTimePicker.Left + 5 + EndHistoryDateTimePicker.Width;
  SearchHistoryButtonArrow.Left := SearchHistoryButton.Left + SearchHistoryButton.Width;
  ESearch.Left := LSearch.Left + 3 + LSearch.Width;
  SearchButton.Left := ESearch.Left + 5 + ESearch.Width;
  CBSearchCase.Left := SearchButton.Left + 10 + SearchButton.Width;
  // End
  LSearch.Caption := GetLangStr('LSearch');
  SearchButton.Caption := GetLangStr('SearchButton');
  CBSearchCase.Caption := GetLangStr('CBSearchCase');
  ViewerPM.Items[0].Caption := GetLangStr('Copy');
  ViewerPM.Items[1].Caption := GetLangStr('SelectAll');
  GIFStaticText.Caption := GetLangStr('GIFStaticText');
  if GIFStaticText2.Hint = 'GIFStaticText' then
  begin
    GIFStaticText2.Caption := GetLangStr('GIFStaticText');
    GIFStaticText2.Hint := 'GIFStaticText';
  end
  else
  begin
    GIFStaticText2.Caption := GetLangStr('GIFStaticTextDelete');
    GIFStaticText2.Hint := 'GIFStaticTextDelete';
  end;
  SearchPM.Items[0].Caption := GetLangStr('ExSearch');
  SearchPM.Items[1].Caption := GetLangStr('ExSearchNext');
  ERR_READ_DB_CONNECT_ERR := GetLangStr('ERR_READ_DB_CONNECT_ERR');
  ERR_READ_DB_SERVICE_MODE := GetLangStr('ERR_READ_DB_SERVICE_MODE');
  ERR_LOAD_MSG_TO_DB := GetLangStr('ERR_LOAD_MSG_TO_DB');
  ERR_SEND_UPDATE := GetLangStr('ERR_SEND_UPDATE');
  ERR_NO_DB_CONNECTED := GetLangStr('ERR_NO_DB_CONNECTED');
  LOAD_TEMP_MSG := GetLangStr('LOAD_TEMP_MSG');
  LOAD_TEMP_MSG_NOLOGFILE := GetLangStr('LOAD_TEMP_MSG_NOLOGFILE');
end;

end.
