{ ############################################################################ }
{ #                                                                          # }
{ #  Импорт истории HistoryToDBSync v2.4                                     # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Main;

{$I HistoryToDBSync.inc}

interface

uses
  Global, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, OleCtrls, SKYPE4COMLib_TLB, CoolTrayIcon, mmSystem, XMLIntf, XMLDoc, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection, ZAbstractTable, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, DB, ZSqlProcessor, JvComponentBase, JvThread,
  JvAppStorage, JvAppIniStorage, JvFormPlacement, ZDbcIntfs, JvAppHotKey, JclStringConversions,
  DCPcrypt2, DCPblockciphers, DCPdes, DCPsha1, DCPbase64, RegExpr, Grids,
  ZSqlMonitor, JvThreadTimer, JvDesktopAlert, ShellApi, MapStream;

type
  TMainSyncForm = class(TForm)
    HistoryToDBSyncTray: TCoolTrayIcon;
    HistoryToDbSyncPopupMenu: TPopupMenu;
    HistorySync: TMenuItem;
    HistoryExit: TMenuItem;
    About: TMenuItem;
    HistoryMainForm: TMenuItem;
    ZConnection1: TZConnection;
    SyncGroupBox: TGroupBox;
    LSyncMethod: TLabel;
    LSyncInterval: TLabel;
    LSyncStatus: TLabel;
    SyncButton: TButton;
    TrayImageList: TImageList;
    SyncProgressBar: TProgressBar;
    LSyncStatusSet: TLabel;
    LSyncMethodSet: TLabel;
    LSyncIntervalSet: TLabel;
    SyncViewTimer: TTimer;
    StartStopSyncButton: TButton;
    TrayAniImageList: TImageList;
    MainSyncQuery: TZQuery;
    DBUpdateProcessor: TZSQLProcessor;
    LEndTime: TLabel;
    SyncThread: TJvThread;
    LEndTimeDesc: TLabel;
    LTotalMesCountDesc: TLabel;
    LMesCurrentCountDesc: TLabel;
    LMesCurrentCount: TLabel;
    LBadMesCountDesc: TLabel;
    LBadMesCount: TLabel;
    MainFormStorage: TJvFormStorage;
    AppIniFileStorage: TJvAppIniFileStorage;
    LDublicateMesCountDesc: TLabel;
    LDublicateMesCount: TLabel;
    CheckMD5HashThread: TJvThread;
    LTotalChangeMD5HashСountDesc: TLabel;
    LTotalChangeMD5HashСount: TLabel;
    LTotalBrokenMD5HashСount: TLabel;
    LTotalHashMsgСount: TLabel;
    LTotalHashMsgСountDesc: TLabel;
    LTotalBrokenMD5HashСountDesc: TLabel;
    LMD5DublicateMesCountDesc: TLabel;
    LMD5DublicateMesCount: TLabel;
    LDeletedMD5DublicateMesCountDesc: TLabel;
    LDeletedMD5DublicateMesCount: TLabel;
    LEncryptMesCountDesc: TLabel;
    LEncryptMesCount: TLabel;
    KeyQuery: TZQuery;
    LStartTimeDesc: TLabel;
    LStartTime: TLabel;
    UpdateContactListThread: TJvThread;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    StartUpdateContactLists: TMenuItem;
    StartCheckMD5: TMenuItem;
    StartCheckAndDeleteMD5: TMenuItem;
    ZSQLMonitor1: TZSQLMonitor;
    JvThreadTimerSync: TJvThreadTimer;
    ViewLogFile: TMenuItem;
    LSkypeStatusDesc: TLabel;
    LSkypeStatus: TLabel;
    LTotalMesCount: TLabel;
    JvThreadTimerSkype: TJvThreadTimer;
    HistoryShow: TMenuItem;
    ShowSettings: TMenuItem;
    PopupImage: TImage;
    ImageList_Main: TImageList;
    CheckUpdate: TMenuItem;
    JvThreadTimerAutoSync: TJvThreadTimer;
    procedure IMExcept(Sender: TObject; E: Exception);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HistoryToDBSyncTrayStartup(Sender: TObject; var ShowMainForm: Boolean);
    procedure HistoryExitClick(Sender: TObject);
    procedure HistoryMainFormClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure StartStopSyncButtonClick(Sender: TObject);
    procedure SyncButtonClick(Sender: TObject);
    procedure SyncViewTimerTimer(Sender: TObject);
    procedure ZConnection1AfterConnect(Sender: TObject);
    procedure SyncThreadExecute(Sender: TObject; Params: Pointer);
    procedure SyncThreadFinish(Sender: TObject);
    procedure CheckMD5HashThreadExecute(Sender: TObject; Params: Pointer);
    procedure CheckMD5HashThreadFinish(Sender: TObject);
    procedure LogViewButtonClick(Sender: TObject);
    procedure UpdateContactListThreadExecute(Sender: TObject; Params: Pointer);
    procedure UpdateContactListThreadFinish(Sender: TObject);
    procedure StartCheckMD5Click(Sender: TObject);
    procedure StartCheckAndDeleteMD5Click(Sender: TObject);
    procedure StartUpdateContactListsClick(Sender: TObject);
    procedure HistoryToDbSyncPopupMenuPopup(Sender: TObject);
    procedure ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
    procedure JvThreadTimerSyncTimer(Sender: TObject);
    procedure ShowSettingsClick(Sender: TObject);
    procedure HistoryShowClick(Sender: TObject);
    procedure SkypeUILanguageChanged(ASender: TObject; const code: WideString);
    procedure SkypeMessageStatus(Sender: TObject; const pMessage: IChatMessage; Status: TChatMessageStatus);
    procedure SkypeAttachmentStatus(Sender: TObject; Status: TOleEnum);
    procedure SkypeApplicationDatagram(Sender: TObject; const pApp: IApplication; const pStream: IApplicationStream; const Text: WideString);
    procedure SkypeChatMembersChanged(ASender: TObject; const pChat: IChat; const pMembers: IUserCollection);
    procedure JvThreadTimerSkypeTimer(Sender: TObject);
    procedure ShowBalloonHint(BalloonTitle, BalloonMsg : WideString);
    procedure DoAlertShow(Sender: TObject);
    procedure DoAlertClose(Sender: TObject);
    procedure CheckUpdateClick(Sender: TObject);
    procedure CheckDBUpdate(PluginDllPath: String);
    procedure DBUpdate(SQLUpdateFile: String);
    procedure StartCheckMD5Hash;
    procedure AntiBoss(HideAllForms: Boolean);
    procedure LoadDBSettings;
    procedure CoreLanguageChanged;
    procedure ShowSyncSettings;
    procedure SQL_Zeos_Key(Sql: WideString);
    procedure SQL_Zeos(Sql: WideString);
    procedure SQL_Zeos_Exec(Sql: WideString);
    procedure RegisterHotKeys;
    procedure UnRegisterHotKeys;
    procedure ReadEncryptionKey;
    procedure StartUpdateContactList;
    procedure ConnectDB;
    procedure StartJvSyncTimer;
    procedure StopJvSyncTimer;
    procedure RunTimeSync;
    procedure EnableButton;
    procedure DisableButton;
    procedure EnableSkype;
    procedure DisableSkype;
    procedure ReadMappedText;
    function ReConnectDB: Boolean;
    function GetEncryptionKey(KeyPwd: String; var EncryptKey, EncryptKeyID: String): Integer;
    function ParseSQLAndEncrypt(SQLStr, EncryptKeyID, EncryptKey: String; var EncryptMsgCount: Integer): WideString;
    function CheckServiceMode: Boolean;
    function GetCurrentEncryptionKeyID(var ActiveKeyID: String): Integer;
    function CheckQueryRecNo(TotalRecNo, CurRecNo: Integer): Boolean;
    procedure JvThreadTimerAutoSyncTimer(Sender: TObject);
  private
    { Private declarations }
    Skype: TSkype;
    SkypeStrList: TStringList;
    SkypeChatList: TStringGrid;
    SessionEnding: Boolean;
    FLanguage : WideString;
    FCount: Integer;
    FMap: TMapStream;
    procedure LoadLanguageStrings;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure OnControlReq(var Msg : TWMCopyData); message WM_COPYDATA;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure DoHotKey(Sender:TObject);
  public
    { Public declarations }
    ThreadMsgNum: Integer;
    ThreadMsgStr: String;
    ProgressBarCount: Integer;
    SyncMesCurrentCount: Integer;
    SyncTotalMesCount: Integer;
    SyncBadMesCount: String;
    SyncDublicateMesCount: String;
    SyncStartTime: String;
    SyncEndTime: String;
    SyncEncryptMsgCount: Integer;
    CheckTotalHashMsgСount: Integer;
    CheckTotalBrokenMD5HashСount: String;
    CheckTotalChangeMD5HashСount: String;
    CheckTotalMD5DublicateMesCount: String;
    CheckTotalDeletedMD5DublicateMesCount: String;
    HistoryMainFormHidden: Boolean;
    CloseRequest: Boolean;
    RunAppDone: Boolean;
    HistoryImportEnable: Boolean;
    SkypeInit: Boolean;
    SkypeRunDone: Boolean;
    SkypeAttachDone: Boolean;
    CheckMD5HashDone: Boolean;
    UpdateContactListDone: Boolean;
    SyncDone: Boolean;
    procedure SyncThreadShowMessage;
    procedure CLThreadShowMessage;
    procedure MD5ThreadShowMessage;
    function RegExprMatchStrings(Source, PatternRegExpr: WideString): Boolean;
    property CoreLanguage: WideString read FLanguage;
  end;

procedure StartSyncTrayFlashingTimer;
procedure StopSyncTrayFlashingTimer;
procedure SyncTrayFlashingTimerCallBack(uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD); stdcall;

var
  MainSyncForm                  : TMainSyncForm;
  SyncTimer                     : Cardinal;  // Мультимедиа таймер взамен кривого TTimer
  SyncTrayFlashingTimer         : Cardinal;  // Мультимедиа таймер взамен кривого TTimer
  SyncTimerEnabled              : Boolean = False;
  SyncTrayFlashingTimerEnabled  : Boolean = False;
  SyncTimerStartTime            : Longint;
  SetSyncInterval               : Integer;
  SyncHistoryStartedEnabled     : Boolean = False;
  CheckMD5HashStartedEnabled    : Boolean = False;
  UpdateContactListStartedEnabled: Boolean = False;
  DeleteDublicate               : Boolean = False;
  JvSyncHotKey                  : TJvApplicationHotKey;

implementation

uses About, KeyPasswd, Log;

{$R *.dfm}

procedure TMainSyncForm.WMQueryEndSession(var Message: TMessage);
begin
  SessionEnding := True;
  Message.Result := 1;
end;

{ Свой обработчик исключений }
procedure TMainSyncForm.IMExcept(Sender: TObject; E: Exception);
begin
  // Пишем в лог ошибки
  if EnableDebug then
    WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура IMExcept: Class - ' + E.ClassName + ' | Ошибка - ' + Trim(e.Message), 2);
end;

procedure TMainSyncForm.FormCreate(Sender: TObject);
var
  CmdHelpStr, Path: WideString;
begin
  RunAppDone := False;
  CloseRequest := False;
  // Для мультиязыковой поддержки
  MainFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Подсказка по параметрам запуска
  if GetSysLang = 'Русский' then
  begin
    CmdHelpStr := 'Параметры запуска ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '----------------------------------------------------------' + #13#13 +
    'HistoryToDBSync.exe <1> <2> <3>' + #13#13 +
    '<1> - (Обязательный параметр) - Путь до файла плагина *HistoryToDB.dll, там же должен быть каталог lang с файлами локализации (Например: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<2> - (Обязательный параметр) - Путь до файла настроек HistoryToDB.ini (Например: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<3> - (Необязательный параметр) - Режим работы' + #13#13 +
    'Возможные значения режима работы:' + #13 +
    '0 - Активировать ведение истории чатов Skype';
  end
  else
  begin
    CmdHelpStr := 'Startup options ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '--------------------------------------------' + #13#13 +
    'HistoryToDBSync.exe <1> <2>' + #13#13 +
    '<1> - (Required) - The path to the plugin file *HistoryToDB.dll, there must be a directory lang files localization (Example: "C:\Program Files\QIP Infium\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<2> - (Required) - The path to the configuration file HistoryToDB.ini (Example: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")' + #13#13 +
    '<3> - (Optional) - Mode' + #13#13 +
    'Values:' + #13 +
    '0 - Activate recording Skype chat history';
  end;
  // Проверка входных параметров
  if ParamCount < 2 then
  begin
    HistoryMainFormHidden := True;
    MsgInf(ProgramsName, CmdHelpStr);
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
    AppIniFileStorage.FileName := ProfilePath + 'HistoryToDBForms.ini';
    // Инициализация криптования
    EncryptInit;
    // Читаем настройки
    LoadINI(ProfilePath, True);
    // Настройки Skype
    if (ParamStr(3) <> '') and IsNumber(ParamStr(3)) then
    begin
      if ParamStr(3) = '0' then
      begin
        if not GlobalSkypeSupport then
          WriteCustomINI(ProfilePath, 'Main', 'SkypeSupport', '1');
        GlobalSkypeSupportOnRun := True;
        GlobalSkypeSupport := True;
        if IMClientType <> 'Skype' then
          WriteCustomINI(ProfilePath, 'Main', 'IMClientType', 'Skype');
        IMClientType := 'Skype';
      end
      else
      begin
        HistoryMainFormHidden := True;
        MsgInf(ProgramsName, CmdHelpStr);
        Exit;
      end;
    end;
    GlobalSkypeSupportOnRun := GlobalSkypeSupport;
    // Устанавливаем настройки соединения с БД
    LoadDBSettings;
    // Загружаем настройки локализации
    FLanguage := DefaultLanguage;
    LangDoc := NewXMLDocument();
    if not DirectoryExists(PluginPath + dirLangs) then
      CreateDir(PluginPath + dirLangs);
    if not FileExists(PluginPath + dirLangs + defaultLangFile) then
    begin
      HistoryMainFormHidden := True;
      if GetSysLang = 'Русский' then
        CmdHelpStr := 'Файл локализации ' + PluginPath + dirLangs + defaultLangFile + ' не найден.'
      else
        CmdHelpStr := 'The localization file ' + PluginPath + dirLangs + defaultLangFile + ' is not found.';
      MsgInf(ProgramsName, CmdHelpStr);
      // Освобождаем ресурсы
      EncryptFree;
      Exit;
    end;
    CoreLanguageChanged;
    // Систрей
    HistoryToDBSyncTray.Hint := MainSyncForm.Caption;
    HistoryToDBSyncTray.IconVisible := not HideSyncIcon;
    HistoryToDBSyncTray.PopupMenu := HistoryToDbSyncPopupMenu;
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuShow';
    // Отображаем настройки синхронизации
    ShowSyncSettings;
    // Регистрируем гор. клавиши
    JvSyncHotKey := TJvApplicationHotKey.Create(self);
    with JvSyncHotKey do
    begin
      HotKey := TextToShortCut(SyncHotKey);
      Active := False;
      OnHotKey := DoHotKey;
    end;
    RegisterHotKeys;
    // Запуск синхронизации по времени
    RunTimeSync;
    // Разрешить синхронизацию из файла HistoryToDBImport.sql
    HistoryImportEnable := True;
    // Логгирование SQL запросов
    if EnableDebug then
      ZSQLMonitor1.Active := True;
    // Загружаем настройки локализации
    LoadLanguageStrings;
    // Поддержка Skype
    if GlobalSkypeSupport then
    begin
      EnableSkype;
      if (not SkypeInit) and (IMClientType = 'Skype') then
      begin
        HistoryMainFormHidden := True;
        CmdHelpStr := GetLangStr('HistoryToDBSyncSkypeInitErr') + #13 +
          GetLangStr('HistoryToDBSyncSkypeNotFound');
        if IMClientType <> 'Unknown' then
          MsgInf(ProgramsName + ' for ' + IMClientType, CmdHelpStr)
        else
          MsgInf(ProgramsName, CmdHelpStr);
        Exit;
      end;
    end
    else
    begin
      LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeOff');
      LSkypeStatus.Hint := 'HistoryToDBSyncSkypeOff';
    end;
    // Обрабатываем все исключения сами
    Forms.Application.OnException := IMExcept;
    // MMF
    if SyncMethod = 0 then
      FMap := TMapStream.CreateEx('HistoryToDB for ' + IMClientType + ' (' + MyAccount + ')',MAXDWORD,2000);
    // Программа запущена
    RunAppDone := True;
    // Запуск обновления БД
    if not MatchStrings(DBAddress, '*.im-history.ru') then
      CheckDBUpdate(PluginPath);
  end;
  // End
end;

procedure TMainSyncForm.FormShow(Sender: TObject);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := True;
  // Прозрачность окна
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
end;

procedure TMainSyncForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    HistoryToDBSyncTray.HideMainForm;
    HistoryMainFormHidden := True;
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuShow');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuShow';
  end;
end;

procedure TMainSyncForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ((HistoryMainFormHidden) or SessionEnding);
  if not CanClose then
  begin
    HistoryToDBSyncTray.HideMainForm;
    HistoryMainFormHidden := True;
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuShow');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuShow';
  end;
end;

procedure TMainSyncForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := False;
end;

procedure TMainSyncForm.FormDestroy(Sender: TObject);
begin
  if RunAppDone then
  begin
    // Выход из Skype
    if Global_ExitSkypeOnEnd then
    begin
      if Assigned(Skype) then
      begin
        if Skype.Client.IsRunning then
          Skype.Client.Shutdown;
      end;
    end;
    // Отключаем Skype
    DisableSkype;
    // Освобождаем ресурсы
    EncryptFree;
    // Разрегистрация гор. клавиш
    UnRegisterHotKeys;
    // MMF
    if Assigned(FMap) then
      FMap.Free;
    // Завершаем потоки
    if not SyncThread.Terminated then
      SyncThread.Terminate;
    if not CheckMD5HashThread.Terminated then
      CheckMD5HashThread.Terminate;
    if not UpdateContactListThread.Terminated then
      UpdateContactListThread.Terminate;
    while not (SyncThread.Terminated) do
    begin
      Sleep(10);
      Forms.Application.ProcessMessages;
    end;
    while not (CheckMD5HashThread.Terminated) do
    begin
      Sleep(10);
      Forms.Application.ProcessMessages;
    end;
    while not (UpdateContactListThread.Terminated) do
    begin
      Sleep(10);
      Forms.Application.ProcessMessages;
    end;
  end;
end;

{ Показываем окно О программе }
procedure TMainSyncForm.AboutClick(Sender: TObject);
begin
  AboutForm.Show;
end;

{ Регистрируем глобальные горячие клавиши }
procedure TMainSyncForm.RegisterHotKeys;
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
end;

{ Разрегистрируем глобальные горячие клавиши }
procedure TMainSyncForm.UnRegisterHotKeys;
begin
  if Assigned(JvSyncHotKey) then
    JvSyncHotKey.Free;
end;

{ Обработка горячих клавиш }
procedure TMainSyncForm.DoHotKey(Sender:TObject);
begin
  if ShortCutToText((Sender as TJvApplicationHotKey).HotKey) = SyncHotKey then
    SyncButtonClick(SyncButton);
end;

{ Открыть историю }
procedure TMainSyncForm.HistoryShowClick(Sender: TObject);
var
  WinName: String;
begin
  // Ищем окно HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не найден, то ищем другое окно
  begin
    WinName := 'HistoryToDBViewer for ' + IMClientType + ' (' + MyAccount + ')';
    if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не запущен, то запускаем
    begin
      if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL)
      else
        ShowBalloonHint(MainSyncForm.Caption, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else
      OnSendMessageToAllComponent('0040');
  end
  else
    OnSendMessageToAllComponent('0040');
end;

{ Отображаем настройки программы }
procedure TMainSyncForm.ShowSettingsClick(Sender: TObject);
var
  WinName: String;
begin
  // Ищем окно HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не найден, то ищем другое окно
  begin
    WinName := 'HistoryToDBViewer for ' + IMClientType + ' (' + MyAccount + ')';
    if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не запущен, то запускаем
    begin
      if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
      begin
        // Отправлен запрос на показ настроек
        WriteCustomINI(ProfilePath, 'Main', 'SettingsFormRequestSend', '1');
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" 4'), nil, SW_SHOWNORMAL);
      end
      else
        ShowBalloonHint(MainSyncForm.Caption, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else // Иначе посылаем запрос на показ настроек
      OnSendMessageToAllComponent('005');
  end
  else // Иначе посылаем запрос на показ настроек
    OnSendMessageToAllComponent('005');
end;

{ Отображаем настройки синхронизации }
procedure TMainSyncForm.ShowSyncSettings;
begin
    case SyncMethod of
      0: LSyncMethodSet.Caption := GetLangStr('CBSyncMethodAuto');
      1: LSyncMethodSet.Caption := GetLangStr('CBSyncMethodManual');
      2: LSyncMethodSet.Caption := GetLangStr('CBSyncMethodOnSchedule');
    end;
    if (SyncMethod = 0) or (SyncMethod = 1) then
      LSyncIntervalSet.Caption := GetLangStr('HistoryToDBSyncNotSpecified')
    else
    begin
      case SyncInterval of
        0: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval5Min');
        1: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval10Min');
        2: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval20Min');
        3: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval30Min');
        4: LSyncIntervalSet.Caption := GetLangStr('CBSyncIntervalExitProgram');
        5: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval10Mes');
        6: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval20Mes');
        7: LSyncIntervalSet.Caption := GetLangStr('CBSyncInterval30Mes');
        8: LSyncIntervalSet.Caption := GetLangStr('CBSyncIntervalNMin');
        9: LSyncIntervalSet.Caption := GetLangStr('CBSyncIntervalNMes');
      end;
    end;
end;

{ Клик по пункту Выход контекстного меню в трее }
procedure TMainSyncForm.HistoryExitClick(Sender: TObject);
begin
  HistoryMainFormHidden := True;
  Close;
end;

{ Клик по пункту Скрыть/Показать контекстного меню в трее }
procedure TMainSyncForm.HistoryMainFormClick(Sender: TObject);
begin
  if HistoryMainFormHidden then
  begin
    HistoryToDBSyncTray.ShowMainForm;
    HistoryMainFormHidden := False;
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuHide');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuHide';
  end
  else
  begin
    Forms.Application.Minimize;
    HistoryToDBSyncTray.HideMainForm;
    HistoryMainFormHidden := True;
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuShow');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuShow';
  end;
end;

{ Событие перед показом контектсного меню в трее }
procedure TMainSyncForm.HistoryToDbSyncPopupMenuPopup(Sender: TObject);
begin
  // Блокруем пункты меню
  if (SyncHistoryStartedEnabled) or (CheckMD5HashStartedEnabled) or (UpdateContactListStartedEnabled) then
  begin
    HistoryToDbSyncPopupMenu.Items[2].Enabled := False;
    HistoryToDbSyncPopupMenu.Items[5].Enabled := False;
    HistoryToDbSyncPopupMenu.Items[6].Enabled := False;
    HistoryToDbSyncPopupMenu.Items[7].Enabled := False;
  end
  else
  begin
    HistoryToDbSyncPopupMenu.Items[2].Enabled := True;
    HistoryToDbSyncPopupMenu.Items[5].Enabled := True;
    HistoryToDbSyncPopupMenu.Items[6].Enabled := True;
    HistoryToDbSyncPopupMenu.Items[7].Enabled := True;
  end;
  if FileExists(ProfilePath+ContactListName) and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) then
    HistoryToDbSyncPopupMenu.Items[7].Enabled := True
  else
    HistoryToDbSyncPopupMenu.Items[7].Enabled := False;
end;

procedure TMainSyncForm.HistoryToDBSyncTrayStartup(Sender: TObject; var ShowMainForm: Boolean);
begin
  ShowMainForm := False;
  HistoryMainFormHidden := True;
end;

{ Останавливаем синхронизацию по времени }
procedure TMainSyncForm.StartStopSyncButtonClick(Sender: TObject);
begin
  if SyncTimerEnabled then
  begin
    StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStart');
    StartStopSyncButton.Hint := 'HistoryToDBSyncStart';
    StopJvSyncTimer;
  end
  else
  begin
    StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStop');
    StartStopSyncButton.Hint := 'HistoryToDBSyncStop';
    StartJvSyncTimer;
  end;
  if SyncTimerEnabled then
  begin
    LSyncStatusSet.Caption := GetLangStr('HistoryToDBSyncStarted');
    LSyncStatusSet.Hint := 'HistoryToDBSyncStarted';
  end
  else
  begin
    LSyncStatusSet.Caption := GetLangStr('HistoryToDBSyncStoped');
    LSyncStatusSet.Hint := 'HistoryToDBSyncStoped';
  end;
end;

{ Пересчитать все MD5-хэши в БД }
procedure TMainSyncForm.StartCheckMD5Click(Sender: TObject);
begin
  if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
  begin
    DeleteDublicate := False;
    StartCheckMD5Hash;
  end;
end;

{ Пересчитать все MD5-хэши в БД и удалить дубликаты }
procedure TMainSyncForm.StartCheckAndDeleteMD5Click(Sender: TObject);
begin
  if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
  begin
    DeleteDublicate := True;
    StartCheckMD5Hash;
  end;
end;

{ Обновить данные контактов в БД }
procedure TMainSyncForm.StartUpdateContactListsClick(Sender: TObject);
begin
  if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    StartUpdateContactList;
end;

{ Показываем окно лог-файлов }
procedure TMainSyncForm.LogViewButtonClick(Sender: TObject);
begin
  LogForm.Show;
end;

{ Выполнить синхронизацию }
procedure TMainSyncForm.SyncButtonClick(Sender: TObject);
var
  Status: Integer;
  CurrentEncryptionKeyID: String;
  ImportMsgPath, MsgPath, Path: WideString;
begin
  if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
  begin
    // Выбор файла для чтения
    MsgPath := ProfilePath + MesLogName;
    ImportMsgPath := ProfilePath + ImportLogName;
    if FileExists(MsgPath) or FileExists(ImportMsgPath) then
    begin
      // Если включено шифрование
      if EnableHistoryEncryption then
      begin
        // Проверяем активность ключа шифрования
        CurrentEncryptionKeyID := '0';
        Status := GetCurrentEncryptionKeyID(CurrentEncryptionKeyID);
        if Status = 1 then // Все хорошо
        begin
          if CurrentEncryptionKeyID <> EncryptionKeyID then
            EncryptionKey := '';
        end
        else if Status = 2 then // Ошибка - Найдено более 1 акт. ключа
        begin
          ShowBalloonHint(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncMultiActiveKey'));
          EncryptionKey := '';
        end
        else if Status = 3 then // Ошибка - Не найдено акт. ключей
        begin
          ShowBalloonHint(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncErrActiveKey'));
          EncryptionKey := '';
        end
        else // Ошибка - Нет доступа к БД
        begin
          ShowBalloonHint(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('ErrDBConnect'));
          EncryptionKey := '';
        end
      end;
      // Если включено шифрование, то читаем ключ, спрашивем его пароль
      if EnableHistoryEncryption and (EncryptionKey = '') and (Status = 1) and (not Global_KeyPasswdForm_Showing) then
        ReadEncryptionKey;
      // Пока окно пароля не закрыто, синхронизации не будет!
      if (not SyncHistoryStartedEnabled) and (not Global_KeyPasswdForm_Showing) then
      begin
        if not SyncThread.Terminated then
          SyncThread.Terminate;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SyncButtonClick: Запуск HistoryToDBInsertThread', 2);
        SyncThread.Execute(Self);
      end;
    end
    else
    begin
      // Выход из программы по отложенному запросу
      if CloseRequest then
        HistoryExitClick(Self);
    end;
  end;
end;

{ Добавляем сообщения в БД }
procedure TMainSyncForm.SyncThreadExecute(Sender: TObject; Params: Pointer);
var
  ImportMsgPath, MsgPath, Path: WideString;
  SyncQuery: TZQuery;
  StrList: TStringList;
  ErrStrList: TStringList;
  DublicateMesCount, BadMesCount, StrListIndex: Integer;
  MesCurrentCount, EncMsgCount: Integer;
  StartTime: TDateTime;
  EncryptSQLMsg, ErrStr: String;
begin
  SyncHistoryStartedEnabled := True;
  SyncDone := False;
  // Выбор файла для чтения
  MsgPath := ProfilePath + MesLogName;
  ImportMsgPath := ProfilePath + ImportLogName;
  if HistoryImportEnable and FileExists(ImportMsgPath) then
    Path := ImportMsgPath
  else
    Path := MsgPath;
  // End
  if FileExists(Path) then
  begin
    try
      if not ZConnection1.Connected then
        ZConnection1.Connect;
    except
      on e: Exception do
      begin
        if not ReConnectDB then
          Exit;
      end;
    end;
    if ZConnection1.Connected then
    begin
      // Отключаем вспом. процедуры, выводим сообщения и т.п.
      TMainSyncForm(Params).ThreadMsgNum := 1;
      TMainSyncForm(Params).ThreadMsgStr := '';
      //TMainSyncForm(Params).ThreadMsgStr := GetLangStr('HistoryToDBSyncStartTrayMsg');
      SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
      // Время начала
      StartTime := Now();
      // Делаем великий изврат с TStringList
      // Непонятно почему, но если грузим файл из N строк через SQL.SQL.LoadFromFile(Path)
      // то при SQL.Execute в базу попадает только первая строка или идет ошибка
      StrList := TStringList.Create;
      ErrStrList := TStringList.Create;
      SyncQuery := TZQuery.Create(nil);
      SyncQuery.Connection := ZConnection1;
      SyncQuery.ParamCheck := False;
      // Переименовываем основной лог во временный
      if FileExists(Path + '.temp') then
        DeleteFile(Path + '.temp');
      RenameFile(Path, Path + '.temp');
      // Делаем великий изврат с TStringList
      // Непонятно почему, но если грузим файл из N строк через SQL.SQL.LoadFromFile(Path)
      // то при SQL.Execute в базу попадает только первая строка или идет ошибка
      StrList.Clear;
      ErrStrList.Clear;
      try
        StrList.LoadFromFile(Path + '.temp');
      except
        on e :
          Exception do
          begin
            TMainSyncForm(Params).ThreadMsgNum := 3;
            TMainSyncForm(Params).ThreadMsgStr := Format(LOAD_TEMP_MSG_NOMSGFILE, [ExtractFileNameEx(Path + '.temp', True)]);
            SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
            if WriteErrLog then
              WriteInLog(ProfilePath, '[' + FormatDateTime('dd.mm.yy hh:mm:ss', Now) + '] Ошибка вызова StrList.LoadFromFile('+Path + '.temp)', 1);
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SyncThreadExecute: Завершение потока SyncThread.', 2);
            SyncQuery.Close;
            SyncQuery.Free;
            StrList.Free;
            ErrStrList.Free;
            // Переименовываем файл *.sql.temp в *.sql
            // Или если файл *.sql уже есть, то переименовываем *.sql.temp в *.sql.DATETIME
            if (FileExists(Path + '.temp')) and (not FileExists(Path)) then
              RenameFile(Path + '.temp', Path)
            else if (FileExists(Path + '.temp')) and (FileExists(Path)) then
              RenameFile(Path + '.temp', Path + '.' + FormatDateTime('ddmmyyhhmmss', Now));
            SyncDone := False;
            Exit;
          end;
      end;
      // Настройки счетчиков
      MesCurrentCount := 0;
      BadMesCount := 0;
      DublicateMesCount := 0;
      EncMsgCount := 0;
      // Выводим значения счетчиков
      TMainSyncForm(Params).ThreadMsgNum := 2;
      TMainSyncForm(Params).SyncMesCurrentCount := 0;
      TMainSyncForm(Params).SyncTotalMesCount := StrList.Count;
      TMainSyncForm(Params).SyncBadMesCount := '0';
      TMainSyncForm(Params).SyncDublicateMesCount := '0';
      TMainSyncForm(Params).SyncEncryptMsgCount := 0;
      TMainSyncForm(Params).SyncStartTime := '00:00:00';
      TMainSyncForm(Params).SyncEndTime := '00:00:00';
      SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
      // End
      for StrListIndex := 0 to StrList.Count-1 do
      begin
        if SyncThread.Terminated then
        begin
          SyncDone := False;
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SyncThreadExecute: Экстренное завершение потока SyncThread.', 2);
          SyncQuery.Close;
          SyncQuery.Free;
          StrList.Free;
          ErrStrList.Free;
          // Переименовываем файл *.sql.temp в *.sql
          // Или если файл *.sql уже есть, то переименовываем *.sql.temp в *.sql.DATETIME
          if (FileExists(Path + '.temp')) and (not FileExists(Path)) then
            RenameFile(Path + '.temp', Path)
          else if (FileExists(Path + '.temp')) and (FileExists(Path)) then
            RenameFile(Path + '.temp', Path + '.' + FormatDateTime('ddmmyyhhmmss', Now));
          Exit;
        end;
        SyncQuery.SQL.Clear;
        // Шифрование сообщений
        if EnableHistoryEncryption and (EncryptionKey <> '') then
        begin
          EncryptSQLMsg := ParseSQLAndEncrypt(StrList[StrListIndex], EncryptionKeyID, EncryptionKey, EncMsgCount);
          SyncQuery.SQL.Add(EncryptSQLMsg);
        end
        else // Если нет щифрования
          SyncQuery.SQL.Add(StrList[StrListIndex]);
        try
          SyncQuery.ExecSQL;
        except
          on e: Exception do
          begin
            // Пишем в лог, что ошибка при добавлении записи в БД
            if WriteErrLog then
              WriteInLog(ProfilePath, Format(ERR_LOAD_MSG_TO_DB, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), 'Class - ' + E.ClassName + ' | Ошибка - ' + Trim(e.Message)]), 1);
            if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
            begin
              ZConnection1.Disconnect;
              if not ReConnectDB then
              begin
                if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SyncThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                SyncQuery.Close;
                SyncQuery.Free;
                StrList.Free;
                ErrStrList.Free;
                // Переименовываем файл *.sql.temp в *.sql
                // Или если файл *.sql уже есть, то переименовываем *.sql.temp в *.sql.DATETIME
                if (FileExists(Path + '.temp')) and (not FileExists(Path)) then
                  RenameFile(Path + '.temp', Path)
                else if (FileExists(Path + '.temp')) and (FileExists(Path)) then
                  RenameFile(Path + '.temp', Path + '.' + FormatDateTime('ddmmyyhhmmss', Now));
                Exit;
              end
              else
              begin
                try
                  SyncQuery.ExecSQL;
                except
                end;
              end;
            end;
            // Добавляем отбракованное сообщение в ErrStrList
            ErrStrList.Add(StrList[StrListIndex]);
            Inc(BadMesCount);
            ErrStr := Trim(e.Message);
            if MatchStrings(DBType, 'firebird*') then
            begin
              if RegExprMatchStrings(ErrStr, '^(.*)violation of PRIMARY or UNIQUE KEY constraint(.*)on table(.*)') then
                Inc(DublicateMesCount);
            end
            else
            begin
              if (MatchStrings(ErrStr, '*Duplicate entry*for key*')) or
                (MatchStrings(ErrStr, '*column*is not unique*')) or
                (MatchStrings(ErrStr, '*duplicate key value violates unique*')) then
              Inc(DublicateMesCount);
            end;
          end;
        end;
        Inc(MesCurrentCount);
        // Вывод статистики
        if CheckQueryRecNo(StrList.Count, MesCurrentCount) then
        begin
          TMainSyncForm(Params).ThreadMsgNum := 2;
          TMainSyncForm(Params).SyncMesCurrentCount := MesCurrentCount-BadMesCount;
          TMainSyncForm(Params).SyncTotalMesCount := StrList.Count;
          TMainSyncForm(Params).SyncBadMesCount := IntToStr(BadMesCount);
          TMainSyncForm(Params).SyncDublicateMesCount := IntToStr(DublicateMesCount);
          if EnableHistoryEncryption and (EncryptionKey <> '') then
            TMainSyncForm(Params).SyncEncryptMsgCount := EncMsgCount-BadMesCount
          else
            TMainSyncForm(Params).SyncEncryptMsgCount := 0;
          TMainSyncForm(Params).SyncStartTime := FormatDateTime('hh:mm:ss', Now() - StartTime);
          TMainSyncForm(Params).SyncEndTime := FormatDateTime('hh:mm:ss', ((Now() - StartTime)/MesCurrentCount)*(StrList.Count-MesCurrentCount));
          TMainSyncForm(Params).ThreadMsgStr := '';
          SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
        end;
      end;
      // Финальная синхронизация
      TMainSyncForm(Params).ThreadMsgNum := 2;
      SyncMesCurrentCount := MesCurrentCount-BadMesCount;
      SyncTotalMesCount := StrList.Count;
      SyncBadMesCount := IntToStr(BadMesCount);
      SyncDublicateMesCount := IntToStr(DublicateMesCount);
      SyncEndTime := '';
      if EnableHistoryEncryption and (EncryptionKey <> '') then
        TMainSyncForm(Params).SyncEncryptMsgCount := EncMsgCount-BadMesCount
      else
        TMainSyncForm(Params).SyncEncryptMsgCount := 0;
      TMainSyncForm(Params).SyncEndTime := '00:00:00';
      TMainSyncForm(Params).ThreadMsgStr := Format(LOAD_TEMP_MSG_SCREEN, [IntToStr(StrList.Count), IntToStr(MesCurrentCount), IntToStr(BadMesCount), IntToStr(DublicateMesCount), IntToStr(SyncEncryptMsgCount)]);
      SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
      // Если есть бракованные сообщения, то пишем их назад в tempmeslogname или meslogname
      if ErrStrList.Count > 0 then
      begin
        // Проверяем размер лога *.sql.bad
        if (GetMyFileSize(Path + '.bad') > MaxErrLogSize*1024) then
          DeleteFile(Path + '.bad');
        // Пишем отбракованые назад в MesLogName.bad или ImportLogName.bad
        ErrStrList.SaveToFile(Path + '.bad');
        // Выводим сообщение в лог
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(LOAD_TEMP_MSG, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Path, IntToStr(StrList.Count), IntToStr(StrList.Count-ErrStrList.Count), IntToStr(ErrStrList.Count), IntToStr(DublicateMesCount), IntToStr(SyncEncryptMsgCount)]), 1);
      end;
      SyncQuery.Free;
      StrList.Free;
      ErrStrList.Free;
      // Удаляем файл .temp
      if FileExists(Path + '.temp') then
        DeleteFile(Path + '.temp');
      SyncDone := True;
    end;
  end
  else
  begin
    TMainSyncForm(Params).ThreadMsgNum := 3;
    TMainSyncForm(Params).ThreadMsgStr := Format(LOAD_TEMP_MSG_NOMSGFILE, [ExtractFileNameEx(Path, True)]);
    SyncThread.Synchronize(TMainSyncForm(Params).SyncThreadShowMessage);
  end;
end;

procedure TMainSyncForm.SyncThreadFinish(Sender: TObject);
begin
  SyncProgressBar.Position := 0;
  SyncHistoryStartedEnabled := False;
  // Очистка ключа, если не стоит сохранение на сессию
  if not KeyPasswdSaveOnlySession then
    EncryptionKey := '';
  // Откл. от БД
  if (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    ZConnection1.Disconnect;
  // Включаем кнопки и т.п.
  EnableButton;
  // Корректируем количество зашифрованных сообщений
  LEncryptMesCount.Caption := IntToStr(SyncEncryptMsgCount);
  // Выводим статус
  HistoryToDBSyncTray.Hint := MainSyncForm.Caption;
  LSyncStatusSet.Caption := GetLangStr('HistoryToDBSyncDone');
  LSyncStatusSet.Hint := 'HistoryToDBSyncDone';
  // Заканчиваем мигать в трее
  if not SyncHistoryStartedEnabled then
    StopSyncTrayFlashingTimer;
  if SyncDone then
  begin
    // Запуск синхронизации по времени
    RunTimeSync;
    if SyncTimerEnabled then
    begin
      StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStop');
      StartStopSyncButton.Hint := 'HistoryToDBSyncStop';
    end
    else
    begin
      StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStart');
      StartStopSyncButton.Hint := 'HistoryToDBSyncStart';
    end;
  end;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SyncThreadFinish: Поток SyncThread выполнен.', 2);
  // Выход из программы по отложенному запросу
  if CloseRequest and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    HistoryExitClick(Self);
end;

{ Проверка на сервисный режим БД }
function TMainSyncForm.CheckServiceMode: Boolean;
var
  ServiceModeQuery: TZQuery;
  System_Disable: Integer;
begin
  if ZConnection1.Connected then
  begin
    ServiceModeQuery := TZQuery.Create(nil);
    ServiceModeQuery.Connection := ZConnection1;
    ServiceModeQuery.ParamCheck := False;
    try
      ServiceModeQuery.SQL.Clear;
      ServiceModeQuery.SQL.Text := 'select config_value from config where config_name = ''system_disable''';
      ServiceModeQuery.Open;
      System_Disable := ServiceModeQuery.FieldByName('config_value').AsInteger;
      ServiceModeQuery.Close;
      if System_Disable = 1 then
      begin
        ShowBalloonHint(MainSyncForm.Caption, GetLangStr('ERR_DB_SERVICE_MODE'));
        if WriteErrLog then
          WriteInLog(ProfilePath, Format(ERR_READ_DB_SERVICE_MODE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now)]), 1);
        Result := True;
      end
      else
        Result := False;
    finally
      ServiceModeQuery.Free;
    end;
  end;
end;

{ Запуск проверки обновлений }
procedure TMainSyncForm.CheckUpdateClick(Sender: TObject);
var
  WinName: String;
begin
  // Ищем окно HistoryToDBUpdater
  WinName := 'HistoryToDBUpdater';
  if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не найден, то ищем другое окно
  begin
    WinName := 'HistoryToDBUpdater for ' + IMClientType + ' (' + MyAccount + ')';
    if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не запущен, то запускаем
    begin
      if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
      begin
        // Отправлен запрос
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
      end
      else
        ShowBalloonHint(MainSyncForm.Caption, Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']));
    end
    else // Иначе посылаем запрос
      OnSendMessageToOneComponent(WinName, '0040');
  end
  else // Иначе посылаем запрос
    OnSendMessageToOneComponent(WinName, '0040');
end;

{ Парсинг SQL Insert запросов и шифрование поля сообщения }
function TMainSyncForm.ParseSQLAndEncrypt(SQLStr, EncryptKeyID, EncryptKey: String; var EncryptMsgCount: Integer): WideString;
var
  RegExpMsgType, RegExpChatMsgType, RegExpMsg, RegExpChatMsg: TRegExpr;
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  StrReplace, SQLStrTmp: WideString;
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
  RegExpMsgType := TRegExpr.Create;
  RegExpChatMsgType := TRegExpr.Create;
  RegExpMsg := TRegExpr.Create;
  RegExpChatMsg := TRegExpr.Create;
  try
    // Определяем тип сообщения
    RegExpMsgType.Expression := '^insert into uin_([\w\d\_\-]{1,})';
    RegExpChatMsgType.Expression := '^insert into uin_chat_([\w\d\_\-]{1,})';
    // RegExpr для сообщений
    RegExpMsg.Expression := '^insert into uin_([\w\d\_\-]{1,}) values \(null\, ([\d]{1,2})\, ''(.*)''\, ''(.*)''\, '+'''(.*)''\, ' + '''(.*)''\, ([\d]{1})\, ''([\d\-\:\s]{1,})''\, ''(.*)''\, ' + '''([\w\d]{1,})''\, (.*)\)';
    // RegExpr для чатов
    RegExpChatMsg.Expression := '^insert into uin_chat_([\w\d\_\-]{1,}) values \(null\, ([\d]{1})\, ''([\d\-\:\s]{1,})''\, ' + '''(.*)''\, ''(.*)''\, ''(.*)''\, ' + '([\d]{1})\, ([\d]{1})\, ([\d]{1})\, ''(.*)''\, ''([\w\d]{1,})''\, (.*)\)';
    SQLStrTmp := UTF8ToWideString(SQLStr);
    if RegExpMsgType.Exec(SQLStr) then
    begin
      if RegExpMsg.Exec(SQLStrTmp) then
      begin
        Cipher.Reset;
        if (MatchStrings(DBType, 'oracle*')) then
          Result := Format(MSG_LOG_ORACLE, [RegExpMsg.Match[1], RegExpMsg.Match[2], WideStringToUTF8(RegExpMsg.Match[3]), WideStringToUTF8(RegExpMsg.Match[4]), WideStringToUTF8(RegExpMsg.Match[5]), WideStringToUTF8(RegExpMsg.Match[6]), RegExpMsg.Match[7], RegExpMsg.Match[8], Cipher.EncryptString(RegExpMsg.Match[9]), RegExpMsg.Match[10], EncryptKeyID])
        else
          Result := Format(MSG_LOG, [RegExpMsg.Match[1], RegExpMsg.Match[2], WideStringToUTF8(RegExpMsg.Match[3]), WideStringToUTF8(RegExpMsg.Match[4]), WideStringToUTF8(RegExpMsg.Match[5]), WideStringToUTF8(RegExpMsg.Match[6]), RegExpMsg.Match[7], RegExpMsg.Match[8], Cipher.EncryptString(RegExpMsg.Match[9]), RegExpMsg.Match[10], EncryptKeyID]);
        Inc(EncryptMsgCount);
      end
      else // Если не смогли распарсить insert-строку, то ничего не шифруем
        Result := SQLStr;
    end;
    {else
      Result := SQLStr;}
    if RegExpChatMsgType.Exec(SQLStr) then
    begin
      if RegExpChatMsg.Exec(SQLStrTmp) then
      begin
        Cipher.Reset;
        if (MatchStrings(DBType, 'oracle*')) then
          Result := Format(CHAT_MSG_LOG_ORACLE, [RegExpChatMsg.Match[1], RegExpChatMsg.Match[2], RegExpChatMsg.Match[3], WideStringToUTF8(RegExpChatMsg.Match[4]), WideStringToUTF8(RegExpChatMsg.Match[5]), WideStringToUTF8(RegExpChatMsg.Match[6]), RegExpChatMsg.Match[7], RegExpChatMsg.Match[8], RegExpChatMsg.Match[9], Cipher.EncryptString(RegExpChatMsg.Match[10]), RegExpChatMsg.Match[11], EncryptKeyID])
        else
          Result := Format(CHAT_MSG_LOG, [RegExpChatMsg.Match[1], RegExpChatMsg.Match[2], RegExpChatMsg.Match[3], WideStringToUTF8(RegExpChatMsg.Match[4]), WideStringToUTF8(RegExpChatMsg.Match[5]), WideStringToUTF8(RegExpChatMsg.Match[6]), RegExpChatMsg.Match[7], RegExpChatMsg.Match[8], RegExpChatMsg.Match[9], Cipher.EncryptString(RegExpChatMsg.Match[10]), RegExpChatMsg.Match[11], EncryptKeyID]);
        Inc(EncryptMsgCount);
      end
      else // Если не смогли распарсить insert-строку, то ничего не шифруем
        Result := SQLStr;
    end;
    {else
      Result := SQLStr;}
  finally
    RegExpMsgType.Free;
    RegExpChatMsgType.Free;
    RegExpMsg.Free;
    RegExpChatMsg.Free;
  end;
  Cipher.Burn;
  Cipher.Free;
end;

{ Устанавливаем настройки подключения к БД }
procedure TMainSyncForm.LoadDBSettings;
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
  else // MySQL, PostgreSQL, Oracle и т.п.
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

{ Обработчик запроса к БД }
procedure TMainSyncForm.SQL_Zeos_Key(Sql: WideString);
begin
  try
    if ZConnection1.Connected then
    begin
      KeyQuery.Connection := ZConnection1;
      try
        KeyQuery.Close;
        KeyQuery.SQL.Clear;
        KeyQuery.SQL.Text := Sql;
        KeyQuery.Open;
      except
        on e :
          Exception do
          begin
            if WriteErrLog then
              WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
            if not HideSyncIcon then
              MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13 + Trim(e.Message));
          end;
      end;
    end;
  except
    on e: Exception do
    begin
      if not ZConnection1.Connected then
        ReConnectDB;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainSyncForm.SQL_Zeos(Sql: WideString);
begin
  try
    if ZConnection1.Connected then
    begin
      MainSyncQuery.Connection := ZConnection1;
      try
        MainSyncQuery.Close;
        MainSyncQuery.SQL.Clear;
        MainSyncQuery.SQL.Text := Sql;
        MainSyncQuery.Open;
      except
        on e :
          Exception do
          begin
            if WriteErrLog then
              WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
            if not HideSyncIcon then
              MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLQuery') + #13 + Trim(e.Message));
          end;
        end;
    end;
  except
    on e: Exception do
    begin
      if not ZConnection1.Connected then
      begin
        ReConnectDB;
      end;
    end;
  end;
end;

{ Обработчик запроса к БД }
procedure TMainSyncForm.SQL_Zeos_Exec(Sql: WideString);
begin
  try
    if ZConnection1.Connected then
    begin
      MainSyncQuery.Connection := ZConnection1;
      if MatchStrings(DBType, 'firebird*') then
        ZConnection1.StartTransaction;
      try
        MainSyncQuery.Close;
        MainSyncQuery.SQL.Clear;
        MainSyncQuery.SQL.Text := Sql;
        MainSyncQuery.ExecSQL;
      except
        on e :
          Exception do
          begin
            if MatchStrings(DBType, 'firebird*') then
              ZConnection1.Rollback;
            if WriteErrLog then
              WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
            if not HideSyncIcon then
              MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('ErrCaption'), GetLangStr('ErrSQLExecQuery') + #13 + Trim(e.Message));
          end;
        end;
      if MatchStrings(DBType, 'firebird*') then
        ZConnection1.Commit;
    end;
  except
    on e: Exception do
    begin
      if not ZConnection1.Connected then
      begin
        ReConnectDB;
      end;
    end;
  end;
end;

{ Выполняется после ZConnection1.Connection для смены схемы в БД Oracle }
procedure TMainSyncForm.ZConnection1AfterConnect(Sender: TObject);
begin
  if MatchStrings(DBType, 'oracle*') then
    SQL_Zeos_Exec('alter session set current_schema='+DBSchema);
  // Проверка на сервисный режим
  if CheckServiceMode then
  begin
    HistoryToDBSyncTray.IconIndex := 1;
    ZConnection1.Disconnect;
  end
  else
    HistoryToDBSyncTray.IconIndex := 0;
end;

{ Логгирование SQL запросов для отладки }
procedure TMainSyncForm.ZSQLMonitor1Trace(Sender: TObject; Event: TZLoggingEvent; var LogTrace: Boolean);
begin
  if Trim(Event.Error) > '' then
    WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - Процедура ZSQLMonitor1Trace: ' + UTF8ToString(Trim(Event.Message)) + ' | Error: ' + Event.Error, 2)
  else
    WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Event.Timestamp) + ' - Процедура ZSQLMonitor1Trace: ' + UTF8ToString(Trim(Event.Message)), 2);
end;

{ Показываем всплывающе сообщение в трее }
procedure TMainSyncForm.ShowBalloonHint(BalloonTitle, BalloonMsg: WideString);
var
  DA: TJvDesktopAlert;
begin
  if AniEvents then
  begin
    DA := TJvDesktopAlert.Create(Self);
    DA.AutoFree := True;
    DA.Image := PopupImage.Picture;
    DA.HeaderText := Format('%s (%d)', [BalloonTitle, FCount]);
    DA.MessageText := BalloonMsg;
    DA.OnShow := DoAlertShow;
    DA.OnClose := DoAlertClose;
    DA.Location.AlwaysResetPosition := False;
    DA.Location.Position := dapBottomRight;
    DA.Location.Width := 350;
    DA.Location.Height := 80;
    DA.AlertStyle := asFade;
    DA.StyleHandler.StartInterval := 25;
    DA.StyleHandler.StartSteps := 10;
    DA.StyleHandler.DisplayDuration  := 1400;
    DA.StyleHandler.EndInterval := 50;
    DA.StyleHandler.EndSteps := 10;
    DA.Execute;
  end;
end;

procedure TMainSyncForm.DoAlertShow(Sender: TObject);
begin
  Inc(FCount);
end;

procedure TMainSyncForm.DoAlertClose(Sender: TObject);
begin
  Dec(FCount);
end;

{ Прием управляющих команд от плагина по событию WM_COPYDATA }
procedure TMainSyncForm.OnControlReq(var Msg : TWMCopyData);
var
  ControlStr, EncryptControlStr: String;
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
    Msg.Result := 2006;
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
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Управляющее сообщение ' + ControlStr + ' - перечитываем настройки.', 2);
      // Читаем настройки
      LoadINI(ProfilePath, True);
      HistoryToDBSyncTray.IconVisible := not HideSyncIcon;
      // Устанавливаем настройки соединения с БД
      LoadDBSettings;
      // Загружаем настройки локализации
      FLanguage := DefaultLanguage;
      CoreLanguageChanged;
      // Отображаем настройки синхронизации
      ShowSyncSettings;
      // Запуск синхронизации по времени только если нет др. задач
      if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
        RunTimeSync;
      // MMF
      if SyncMethod = 0 then
      begin
        if not Assigned(FMap) then
        begin
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Создаем TMapStream', 2);
          FMap := TMapStream.CreateEx('HistoryToDB for ' + IMClientType + ' (' + MyAccount + ')',MAXDWORD,2000);
        end;
      end
      else
      begin
        if Assigned(FMap) then
        begin
          FMap.Free;
          FMap := nil;
        end;
      end;
      // Поддержка Skype
      if GlobalSkypeSupportOnRun <> GlobalSkypeSupport then
      begin
        GlobalSkypeSupportOnRun := GlobalSkypeSupport;
        if GlobalSkypeSupport then
        begin
          if Assigned(Skype) then
            DisableSkype;
          EnableSkype;
        end
        else
        begin
          if Assigned(Skype) then
          begin
            DisableSkype;
            LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeOff');
            LSkypeStatus.Hint := 'HistoryToDBSyncSkypeOff';
          end;
        end;
      end;
    end;
    // 002 - Синхронизация истории
    if (ControlStr = '002') and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Управляющее сообщение ' + ControlStr + ' - выполняем синхронизацию истории.', 2);
      SyncButtonClick(Self);
    end;
    // 003 - Выход из программы
    // Выход если не запущена синхронизация или перерасчет MD5
    if (ControlStr = '003') and (not Global_AutoRunHistoryToDBSync) then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Управляющее сообщение ' + ControlStr + ' - выполняем выход из программы.', 2);
      if SyncHistoryStartedEnabled or CheckMD5HashStartedEnabled or UpdateContactListStartedEnabled then
        CloseRequest := True
      else if (SyncMethod = 2) and (SyncInterval = 4) then // Если синхронизация при выходе
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Запуск синхронизации перед выходом из программы.', 2);
        CloseRequest := True;
        SyncButtonClick(Self);
      end
      else if SyncWhenExit then // Если доп. синх-я при выходе
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Запуск доп. синхронизации перед выходом из программы.', 2);
        CloseRequest := True;
        SyncButtonClick(Self);
      end
      else
        HistoryExitClick(Self);
    end;
    // 0040 - Показать все окна плагина (Режим AntiBoss)
    if ControlStr = '0040' then
      AntiBoss(False);
    // 0041 - Скрыть все окна плагина (Режим AntiBoss)
    if ControlStr = '0041' then
      AntiBoss(True);
    // 0050  - Запустить перерасчет MD5-хешей
    if (ControlStr = '0050') and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    begin
      DeleteDublicate := False;
      StartCheckMD5Hash;
    end;
    // 0051  - Запустить перерасчет MD5-хешей и удаление дубликатов
    if (ControlStr = '0051') and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
    begin
      DeleteDublicate := True;
      StartCheckMD5Hash;
    end;
    // 0060 - Запретить синхронизацию из файла HistoryToDBImport.sql
    if ControlStr = '0060' then
      HistoryImportEnable := False;
    // 0061 - Разрешить синхронизацию из файла HistoryToDBImport.sql
    if ControlStr = '0061' then
      HistoryImportEnable := True;
    // 007  - Запустить обновление списка контактов
    if (ControlStr = '007') and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) and (not UpdateContactListStartedEnabled) then
      StartUpdateContactList;
    // 009 - Экстренное завершение работы
    if ControlStr = '009' then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура OnControlReq: Управляющее сообщение ' + ControlStr + ' - выполняем принудительный выход из программы.', 2);
      HistoryExitClick(Self);
    end;
    // 010 - Сигнал о наличии в памяти сообщения от плагина
    if ControlStr = '010' then
    begin
      JvThreadTimerAutoSync.Enabled := False;
      ReadMappedText;
      JvThreadTimerAutoSync.Enabled := True;
    end;
  end;
end;

{ Сработка таймера SyncViewTimer для отображения процесса отсчета основного SyncTimer }
procedure TMainSyncForm.SyncViewTimerTimer(Sender: TObject);
var
  CurrentSyncTimer: Longint;
begin
  if MainSyncForm.Showing then
  begin
    CurrentSyncTimer := (timeGetTime() - SyncTimerStartTime);
    LSyncStatusSet.Caption := Format(GetLangStr('HistoryToDBSyncStartCount'), [IntToStr(Round((SetSyncInterval-CurrentSyncTimer)/1000))]);
  end;
end;

{ Запуск JvThreadTimer синхронизации сообщений }
procedure TMainSyncForm.StartJvSyncTimer;
begin
  if SyncInterval = 0 then
    SetSyncInterval := 5*60*1000
  else if SyncInterval = 1 then
    SetSyncInterval := 10*60*1000
  else if SyncInterval = 2 then
    SetSyncInterval := 20*60*1000
  else if SyncInterval = 3 then
    SetSyncInterval := 30*60*1000
  else if SyncInterval = 8 then
    SetSyncInterval := SyncTimeCount*60*1000
  else
    Exit;
  JvThreadTimerSync.Interval := SetSyncInterval;
  JvThreadTimerSync.Enabled := True;
  SyncTimerEnabled := True;
  MainSyncForm.LSyncStatusSet.Caption := Format(GetLangStr('HistoryToDBSyncStartCount'), ['0']);
  // Запускаем таймер SyncViewTimer для отображения процесса отсчета SyncTimer
  SyncTimerStartTime := timeGetTime();
  SyncViewTimer.Enabled := True;
end;

procedure TMainSyncForm.StopJvSyncTimer;
begin
  // Останавливаем таймер
  SyncTimerEnabled := False;
  JvThreadTimerSync.Enabled := False;
  // Останавливаем таймер SyncViewTimer для отображения процесса отсчета SyncTimer
  SyncViewTimer.Enabled := False;
  LSyncStatusSet.Caption := GetLangStr('HistoryToDBSyncWaitReq');
  LSyncStatusSet.Hint := 'HistoryToDBSyncWaitReq';
end;

{ Сработка JvThreadTimerSync таймера синхронизации }
procedure TMainSyncForm.JvThreadTimerSyncTimer(Sender: TObject);
begin
  // Установим новое время начала синхронизации
  SyncTimerStartTime := timeGetTime();
  // Останавлваем таймер
  StopJvSyncTimer;
  // Запуск добавления данных из sql-файла в БД
  SyncButtonClick(Self);
  // Запуск таймера
  StartJvSyncTimer;
end;

{ Запуск таймера мигания иконок в трее }
procedure StartSyncTrayFlashingTimer;
begin
  SyncTrayFlashingTimer := TimeSetEvent(600000,1000,@SyncTrayFlashingTimerCallBack,100,TIME_PERIODIC);
  SyncTrayFlashingTimerEnabled := True;
  MainSyncForm.HistoryToDBSyncTray.IconList := MainSyncForm.TrayAniImageList;
  MainSyncForm.HistoryToDBSyncTray.CycleInterval := 400;
  MainSyncForm.HistoryToDBSyncTray.CycleIcons := True;
end;

{ Остановка таймера мигания иконок в трее }
procedure StopSyncTrayFlashingTimer;
begin
  if SyncTrayFlashingTimerEnabled then
  begin
    SyncTrayFlashingTimerEnabled := False;
    timeKillEvent(SyncTrayFlashingTimer);
    MainSyncForm.HistoryToDBSyncTray.CycleIcons := False;
    MainSyncForm.HistoryToDBSyncTray.IconList := MainSyncForm.TrayImageList;
  end;
end;

{ Сработка таймера мигания иконок в трее }
procedure SyncTrayFlashingTimerCallBack(uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD); stdcall;
begin
  StopSyncTrayFlashingTimer;
end;

{ Процедура проверки версии БД и её обновления }
procedure TMainSyncForm.CheckDBUpdate(PluginDllPath: String);
var
  Query: TZQuery;
  SQLVersion, SQLClientType, TempProgramsVer: String;
begin
  if DBUserName <> 'username' then
    ConnectDB; // Подключаемся к базе
  if ZConnection1.Connected then
  begin
    HistoryToDBSyncTray.IconIndex := 3;
    if IMClientType = 'ICQ' then
      SQLClientType := 'icq_version'
    else if IMClientType = 'QIP' then
      SQLClientType := 'qip_version'
    else if IMClientType = 'RnQ' then
      SQLClientType := 'rnq_version'
    else if IMClientType = 'Miranda' then
      SQLClientType := 'miranda_version'
    else if IMClientType = 'Skype' then
      SQLClientType := 'skype_version'
    else
    begin
      ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncUnknownIMClient'));
      Exit;
    end;
    Query := TZQuery.Create(nil);
    Query.Connection := ZConnection1;
    Query.ParamCheck := False;
    try
      Query.SQL.Clear;
      Query.SQL.Text := 'select config_value from config where config_name = '''+SQLClientType+'''';
      Query.Open;
      SQLVersion := Query.FieldByName('config_value').AsString;
      Query.Close;
      // Обновление структуры БД для Skype с версии ниже 2.3.0.0
      TempProgramsVer := StringReplace(ProgramsVer, '.', '', [RFReplaceall]);
      if IsNumber(TempProgramsVer) then
      begin
        if (StrToInt(TempProgramsVer) = 2300) and (SQLVersion = '') and (IMClientType = 'Skype') then
          SQLVersion := '2.2'
      end;
      // End
      if MatchStrings(DBType, 'mysql*') then
      begin
        {if (SQLVersion = '1.0') and (ProgramsVer = '1.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-10-to-11.sql');
        if (SQLVersion = '1.0') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-10-to-12.sql');}
        if (SQLVersion = '1.0') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-10-to-20.sql');
        {if (SQLVersion = '1.1') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-11-to-12.sql');}
        if (SQLVersion = '1.1') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-11-to-20.sql');
        if (SQLVersion = '1.2') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-12-to-20.sql');
        if (SQLVersion = '1.3') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-13-to-20.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-20-to-21.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.2.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-21-to-22.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.3.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.3') and (ProgramsVer = '2.4.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'mysql-update-23-to-24.sql');
      end
      else if MatchStrings(DBType, 'postgresql*') then
      begin
        {if (SQLVersion = '1.0') and (ProgramsVer = '1.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-10-to-11.sql');
        if (SQLVersion = '1.0') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-10-to-12.sql');}
        if (SQLVersion = '1.0') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-10-to-20.sql');
        {if (SQLVersion = '1.1') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-11-to-12.sql');}
        if (SQLVersion = '1.1') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-11-to-20.sql');
        if (SQLVersion = '1.2') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-12-to-20.sql');
        if (SQLVersion = '1.3') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-13-to-20.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-20-to-21.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.2.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-21-to-22.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.3.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.3') and (ProgramsVer = '2.4.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'postgresql-update-23-to-24.sql');
      end
      else if MatchStrings(DBType, 'oracle*') then
      begin
        {if (SQLVersion = '1.0') and (ProgramsVer = '1.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-10-to-11.sql');
        if (SQLVersion = '1.0') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-10-to-12.sql');}
        if (SQLVersion = '1.0') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-10-to-20.sql');
        {if (SQLVersion = '1.1') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-11-to-12.sql');}
        if (SQLVersion = '1.1') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-11-to-20.sql');
        if (SQLVersion = '1.2') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-12-to-20.sql');
        if (SQLVersion = '1.3') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-13-to-20.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-20-to-21.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.2.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-21-to-22.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.3.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.3') and (ProgramsVer = '2.4.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'oracle-update-23-to-24.sql');
      end
      else if MatchStrings(DBType, 'sqlite*') then
      begin
        {if (SQLVersion = '1.0') and (ProgramsVer = '1.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-10-to-11.sql');
        if (SQLVersion = '1.0') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-10-to-12.sql');}
        if (SQLVersion = '1.0') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-10-to-20.sql');
        {if (SQLVersion = '1.1') and (ProgramsVer = '1.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-11-to-12.sql');}
        if (SQLVersion = '1.1') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-11-to-20.sql');
        if (SQLVersion = '1.2') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-12-to-20.sql');
        if (SQLVersion = '1.3') and (ProgramsVer = '2.0.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-13-to-20.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-20-to-21.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.2.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-21-to-22.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.3.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.3') and (ProgramsVer = '2.4.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'sqlite-update-23-to-24.sql');
      end
      else if MatchStrings(DBType, 'firebird*') then
      begin
        if (SQLVersion = '2.0') and (ProgramsVer = '2.1.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-20-to-21.sql');
        if (SQLVersion = '2.0') and (ProgramsVer = '2.2.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.0') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-20-to-21.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.3.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.1') and (ProgramsVer = '2.2.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-21-to-22.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.3.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
        if (SQLVersion = '2.2') and (ProgramsVer = '2.4.0.0') then
        begin
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-22-to-23.sql');
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-23-to-24.sql');
        end;
        if (SQLVersion = '2.3') and (ProgramsVer = '2.4.0.0') then
          DBUpdate(PluginDllPath + 'update\' + 'firebird-update-23-to-24.sql');
      end;
    finally
      Query.Free;
    end;
    HistoryToDBSyncTray.IconIndex := 0;
  end;
  ZConnection1.Disconnect;
end;

{ Обновление базы из файла }
procedure TMainSyncForm.DBUpdate(SQLUpdateFile: String);
var
  StrList: TStringList;
  StrListIndex: Integer;
  ErrCount: Integer;
  StrReplace: String;
begin
  if ZConnection1.Connected then
  begin
    if FileExists(SQLUpdateFile) then
    begin
      ErrCount := 0;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DBUpdate: Запущено обновление БД из файла ' + SQLUpdateFile, 2);
      StrList := TStringList.Create;
      StrList.Clear;
      StrList.LoadFromFile(SQLUpdateFile);
      DBUpdateProcessor.Script.Clear;
      if MatchStrings(DBType, 'firebird*') then
        ZConnection1.StartTransaction;
      for StrListIndex := 0 to StrList.Count-1 do
      begin
        StrReplace := StrList[StrListIndex];
        StrReplace := StringReplace(StrReplace, 'username', DBUserName, [RFReplaceall]);
        DBUpdateProcessor.Script.Add(StrReplace);
      end;
      try
        DBUpdateProcessor.Execute;
      except
        on e :
          Exception do
          begin
            Inc(ErrCount);
            if WriteErrLog then
              WriteInLog(ProfilePath, Format(ERR_READ_DB_CONNECT_ERR, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
          end;
      end;
      if MatchStrings(DBType, 'firebird*') then
        ZConnection1.Commit;
      StrList.Free;
      if ErrCount = 0 then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DBUpdate: Обновление БД успешно завершено.', 2);
        ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncUpdateDone'))
      end
      else
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DBUpdate: Обновление БД завершено с ошибками.', 2);
        ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncUpdateErr'));
      end;
    end;
  end;
end;

{ Поддержка режима Анти-босс }
procedure TMainSyncForm.AntiBoss(HideAllForms: Boolean);
begin
  if not Assigned(MainSyncForm) then Exit;
  if not Assigned(LogForm) then Exit;
  if not Assigned(KeyPasswdForm) then Exit;
  if not Assigned(AboutForm) then Exit;
  if HideAllForms then
  begin
    ShowWindow(MainSyncForm.Handle, SW_HIDE);
    MainSyncForm.Hide;
    ShowWindow(LogForm.Handle, SW_HIDE);
    LogForm.Hide;
    ShowWindow(KeyPasswdForm.Handle, SW_HIDE);
    KeyPasswdForm.Hide;
    ShowWindow(AboutForm.Handle, SW_HIDE);
    AboutForm.Hide;
    if HistoryToDBSyncTray.IconVisible = True then
      HistoryToDBSyncTray.IconVisible := False;
  end
  else
  begin
    // Если форма была ранее открыта, то показываем её
    if Global_MainForm_Showing then
    begin
      if HistoryMainFormHidden then
        HistoryToDBSyncTray.HideMainForm
      else
      begin
        ShowWindow(MainSyncForm.Handle, SW_SHOW);
        MainSyncForm.Show;
      end;
    end;
    if Global_LogForm_Showing then
    begin
      ShowWindow(LogForm.Handle, SW_SHOW);
      LogForm.Show;
    end;
    if Global_KeyPasswdForm_Showing then
    begin
      ShowWindow(KeyPasswdForm.Handle, SW_SHOW);
      KeyPasswdForm.Show;
    end;
    if Global_AboutForm_Showing then
    begin
      ShowWindow(AboutForm.Handle, SW_SHOW);
      AboutForm.Show;
    end;
    HistoryToDBSyncTray.IconVisible := not HideSyncIcon;
  end;
end;

{ Процедура запуска обновления списка контактов }
procedure TMainSyncForm.StartUpdateContactList;
begin
  if not UpdateContactListStartedEnabled then
  begin
    if not UpdateContactListThread.Terminated then
      UpdateContactListThread.Terminate;
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура StartUpdateContactList: Запуск UpdateContactListThread', 2);
    UpdateContactListThread.Execute(Self);
  end;
end;

{ Поток обновления списка контактов }
procedure TMainSyncForm.UpdateContactListThreadExecute(Sender: TObject; Params: Pointer);
var
  Query: TZQuery;
  TSG_Proto, TSG_Contact: TStringGrid;
  Str1, Str2, FoundProto, FoundMyUserID: String;
  TF: TextFile;
  I, J, K, ProtoType: Integer;
begin
  UpdateContactListStartedEnabled := True;
  UpdateContactListDone := False;
  try
    if not ZConnection1.Connected then
      ZConnection1.Connect;
  except
    on e: Exception do
    begin
      if not ReConnectDB then
        Exit;
    end;
  end;
  if ZConnection1.Connected then
  begin
    if (FileExists(ProfilePath+ContactListName)) and (FileExists(ProfilePath+ProtoListName)) then
    begin
      // Начало обновления КЛ - Отключение вспомогательных процедур и т.д.
      TMainSyncForm(Params).ThreadMsgNum := 1;
      TMainSyncForm(Params).ThreadMsgStr := GetLangStr('HistoryToDBSyncStartUpdateCL');
      UpdateContactListThread.Synchronize(TMainSyncForm(Params).CLThreadShowMessage);
      // Создаем TZQuery
      Query := TZQuery.Create(nil);
      Query.Connection := ZConnection1;
      Query.ParamCheck := False;
      // Грузим список протоколов в StringGrid
      // Делаем такой изврат лишь с одной целью - легко реализуемый поиск по колонкам
      I := 0;
      TSG_Proto := TStringGrid.Create(nil);
      AssignFile(TF, ProfilePath+ProtoListName);
      Reset(TF);
      while not eof(TF) do
      begin
        Readln(TF, Str1);
        Inc(I);
        J := 0;
        while Pos(';', Str1)<>0 do
        begin
          Str2 := Copy(Str1,1,Pos(';', Str1)-1);
          Inc(J);
          Delete(Str1, 1, Pos(';', Str1));
          TSG_Proto.Cells[J-1, I-1] := Str2;
        end;
        if Pos(';', Str1) = 0 then
        begin
          Inc(J);
          TSG_Proto.Cells[J-1, I-1] := Str1;
        end;
        TSG_Proto.ColCount := J;
        TSG_Proto.RowCount := I+1;
      end;
      CloseFile(TF);
      // Грузим список контактов в StringGrid
      I := 0;
      TSG_Contact := TStringGrid.Create(nil);
      AssignFile(TF, ProfilePath+ContactListName);
      Reset(TF);
      while not eof(TF) do
      begin
        Readln(TF, Str1);
        Inc(I);
        J := 0;
        while Pos(';', Str1)<>0 do
        begin
          Str2 := Copy(Str1,1,Pos(';', Str1)-1);
          Inc(J);
          Delete(Str1, 1, Pos(';', Str1));
          TSG_Contact.Cells[J-1, I-1] := Str2;
        end;
        if Pos(';', Str1) = 0 then
        begin
          Inc(J);
          TSG_Contact.Cells[J-1, I-1] := Str1;
        end;
        TSG_Contact.ColCount := J;
        TSG_Contact.RowCount := I+1;
      end;
      CloseFile(TF);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Список TSG_Proto: ColCount - ' + IntToStr(TSG_Proto.ColCount)+', RowCount - '+IntToStr(TSG_Proto.RowCount), 2);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Список TSG_Contact: ColCount - ' + IntToStr(TSG_Contact.ColCount)+', RowCount - '+IntToStr(TSG_Contact.RowCount), 2);
      for I := 0 to TSG_Contact.RowCount-2 do
      begin
        // Синхронизация
        TMainSyncForm(Params).ThreadMsgNum := 2;
        TMainSyncForm(Params).CheckTotalHashMsgСount := TSG_Contact.RowCount-2;
        TMainSyncForm(Params).ProgressBarCount := I;
        UpdateContactListThread.Synchronize(TMainSyncForm(Params).CLThreadShowMessage);
        // Ищем имя протокола (1 поле) в списке протоколов в 3 колонке (Протокол) по 4 полю (Протокол) из списка контактов
        K := TSG_Proto.Cols[2].IndexOf(TSG_Contact.Cells[3, I]);
        if K <> -1 then // Нашли! K - строка
        begin
          // Экстр. завершение потока
          if UpdateContactListThread.Terminated then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Экстренное завершение потока UpdateContactListThread.', 2);
            UpdateContactListDone := False;
            TSG_Contact.Free;
            TSG_Proto.Free;
            Query.Free;
            Exit;
          end;
          // Протоколы и т.п.
          FoundProto := TSG_Proto.Cells[0,K];
          FoundMyUserID := TSG_Proto.Cells[1,K];
          ProtoType := StrContactProtoToInt(FoundProto);
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Для UserID = ' + TSG_Contact.Cells[0, I] + ' найден: Протокол = ' + FoundProto + ' (' + IntToStr(ProtoType) + ') | UserID собеседника = ' + FoundMyUserID, 2);
          Query.SQL.Clear;
          Query.SQL.Text := 'update uin_'+ DBUserName + ' set nick = '''+ AnsiStringToUTF8(PrepareString(PWideChar(TSG_Contact.Cells[1, I]))) + ''' where uin = ''' + AnsiStringToUTF8(TSG_Contact.Cells[0, I]) + ''';';
          try
            Query.ExecSQL;
          except
            on e :
              Exception do
              begin // Реконект в случае потери связи
                if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре UpdateContactListThreadExecute: ' + Trim(e.Message), 2);
                if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                begin
                  ZConnection1.Disconnect;
                  if not ReConnectDB then
                  begin
                    UpdateContactListDone := False;
                    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                    TSG_Contact.Free;
                    TSG_Proto.Free;
                    Query.Free;
                    Exit;
                  end;
                end;
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
              end;
          end;
          Query.SQL.Clear;
          Query.SQL.Text := 'update uin_'+ DBUserName + ' set proto_name = ' + IntToStr(ProtoType) + ' where uin = ''' + AnsiStringToUTF8(TSG_Contact.Cells[0, I]) + ''';';
          try
            Query.ExecSQL;
          except
            on e :
              Exception do
              begin // Реконект в случае потери связи
                if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре UpdateContactListThreadExecute: ' + Trim(e.Message), 2);
                if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                begin
                  ZConnection1.Disconnect;
                  if not ReConnectDB then
                  begin
                    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                    UpdateContactListDone := False;
                    TSG_Contact.Free;
                    TSG_Proto.Free;
                    Query.Free;
                    Exit;
                  end;
                end;
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
              end;
          end;
        end;
      end;
      TSG_Contact.Free;
      TSG_Proto.Free;
      Query.Free;
      UpdateContactListDone := True;
    end
    else
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadExecute: Не найдены файл со списком протоколов и контактов. ('+ProfilePath+')', 2);
      // Выводим сообщение
      TMainSyncForm(Params).ThreadMsgNum := 3;
      TMainSyncForm(Params).ThreadMsgStr := GetLangStr('HistoryToDBSyncCLFileNotFound');
      UpdateContactListThread.Synchronize(TMainSyncForm(Params).CLThreadShowMessage);
    end;
  end;
end;

{ Поток обновления списка контактов завершен }
procedure TMainSyncForm.UpdateContactListThreadFinish(Sender: TObject);
begin
  SyncProgressBar.Position := 0;
  UpdateContactListStartedEnabled := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура UpdateContactListThreadFinish: Поток UpdateContactListThread выполнен.', 2);
  // Отключаемся от БД
  if (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) then
    ZConnection1.Disconnect;
  // Заканчиваем мигать в трее
  if not SyncHistoryStartedEnabled then
    StopSyncTrayFlashingTimer;
  // Включаем кнопки и т.п.
  EnableButton;
  // Запуск таймера синхронизации по времени
  if (StartStopSyncButton.Visible) and (not SyncTimerEnabled) and (not SyncHistoryStartedEnabled) then
    StartStopSyncButtonClick(StartStopSyncButton);
  // Подсказка в трее
  if SyncHistoryStartedEnabled then
    HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStarted')
  else
    HistoryToDBSyncTray.Hint := Caption;
  // Если обновление КЛ прошло без ошибок
  if UpdateContactListDone then
  begin
    // Удаляем списки контактов и протоколов
    if FileExists(ProfilePath+ProtoListName) then
      DeleteFile(ProfilePath+ProtoListName);
    if FileExists(ProfilePath+ContactListName) then
      DeleteFile(ProfilePath+ContactListName);
    ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncCLUpdateDone'));
  end
  else
    ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncCLUpdateErr') + #13#10 + GetLangStr('SeeErrLog'));
  // Выход из программы по отложенному запросу
  if CloseRequest and (not SyncHistoryStartedEnabled) and (not CheckMD5HashStartedEnabled) then
    HistoryExitClick(Self);
end;

{ Процедура запуска перерасчета MD5-хешей }
procedure TMainSyncForm.StartCheckMD5Hash;
begin
  if not CheckMD5HashStartedEnabled then
  begin
    if not CheckMD5HashThread.Terminated then
      CheckMD5HashThread.Terminate;
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура StartCheckMD5Hash: Запуск CheckMD5HashThread', 2);
    CheckMD5HashThread.Execute(Self);
  end;
end;

{ Поток перерасчета MD5-хешей }
procedure TMainSyncForm.CheckMD5HashThreadExecute(Sender: TObject; Params: Pointer);
var
  Query: TZQuery;
  ChangeQuery: TZQuery;
  DublicateQuery: TZQuery;
  TotalMD5Hash, MsgMD5Cnt, ErrMsgMD5Cnt, ErrMD5DublicateMesCount, DeletedMD5DublicateMesCount: Integer;
  MD5String: WideString;
  DublicateMD5Hash: String;
  NextTable: Boolean;
  QueryRecNo, DublicateRecNo: Integer;
begin
  CheckMD5HashStartedEnabled := True;
  CheckMD5HashDone := False;
  TotalMD5Hash := 0;
  QueryRecNo := 0;
  try
    if not ZConnection1.Connected then
      ZConnection1.Connect;
  except
    on e: Exception do
    begin
      if not ReConnectDB then
        Exit;
    end;
  end;
  if ZConnection1.Connected then
  begin
    // Начало перерасчета MD5-хешей - Отключение вспомогательных процедур и т.д.
    TMainSyncForm(Params).ThreadMsgNum := 1;
    TMainSyncForm(Params).ThreadMsgStr := GetLangStr('HistoryToDBSyncStartMD5');
    CheckMD5HashThread.Synchronize(TMainSyncForm(Params).MD5ThreadShowMessage);
    // Создаем объекты TZQuery
    Query := TZQuery.Create(nil);
    ChangeQuery := TZQuery.Create(nil);
    DublicateQuery := TZQuery.Create(nil);
    Query.Connection := ZConnection1;
    ChangeQuery.Connection := ZConnection1;
    DublicateQuery.Connection := ZConnection1;
    Query.ParamCheck := False;
    ChangeQuery.ParamCheck := False;
    DublicateQuery.ParamCheck := False;
    // Удаляем лог HistoryToDBDublicate.log
    if DeleteDublicate then
    begin
      if FileExists(ProfilePath + DublicateLogName) then
        DeleteFile(ProfilePath + DublicateLogName);
    end;
    try
      // Ищем дубликаты в таблице uin_username
      NextTable := False;
      Query.SQL.Clear;
      Query.SQL.Text := 'select count(*) as cnt from uin_'+ DBUserName + ';';
      try
        Query.Open;
      except
        on e: Exception do
        begin // Реконект в случае потери связи
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре CheckMD5HashThreadExecute (Query): ' + Trim(e.Message), 2);
          if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
          begin
            ZConnection1.Disconnect;
            if not ReConnectDB then
            begin
              CheckMD5HashDone := False;
              if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
              Query.Close;
              Exit;
              end;
            end
            else
              try
                Query.Open;
              except
              end;
          end;
        end;
      TotalMD5Hash := Query.FieldByName('cnt').AsInteger;
      Query.Close;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Список TSG_Proto: Всего записей в таблице uin_' + DBUserName + ' = ' + IntToStr(TotalMD5Hash), 2);
      // Вывод начальной статистики по MD5 хэшам
      TMainSyncForm(Params).ThreadMsgNum := 2;
      TMainSyncForm(Params).CheckTotalBrokenMD5HashСount := '0';
      TMainSyncForm(Params).CheckTotalChangeMD5HashСount := '0';
      TMainSyncForm(Params).CheckTotalMD5DublicateMesCount := '0';
      TMainSyncForm(Params).CheckTotalDeletedMD5DublicateMesCount := '0';
      TMainSyncForm(Params).CheckTotalHashMsgСount := TotalMD5Hash;
      TMainSyncForm(Params).ProgressBarCount := 0;
      CheckMD5HashThread.Synchronize(TMainSyncForm(Params).MD5ThreadShowMessage);
      // End
      if TotalMD5Hash = 0 then
        NextTable := True;
      if not NextTable then
      begin
        Query.SQL.Clear;
        Query.SQL.Text := 'select id,uin,msg_time,msg_text,md5hash from uin_'+ DBUserName + ';';
        try
          Query.Open;
        except
          on e: Exception do
          begin // Реконект в случае потери связи
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре CheckMD5HashThreadExecute (Query): ' + Trim(e.Message), 2);
            if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
            begin
              ZConnection1.Disconnect;
              if not ReConnectDB then
              begin
                CheckMD5HashDone := False;
                if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                Query.Close;
                Exit;
              end
              else
                try
                  Query.Open;
                except
                end;
            end;
          end;
        end;
        MsgMD5Cnt := 0;
        ErrMsgMD5Cnt := 0;
        ErrMD5DublicateMesCount := 0;
        DeletedMD5DublicateMesCount := 0;
        repeat
          QueryRecNo := Query.RecNo;
          MD5String := EncryptMD5(Query.FieldByName('uin').AsString + FormatDateTime('YYYY-MM-DD HH:MM:SS', StrToDateTime(StringReplace(Query.FieldByName('msg_time').AsString, '-', '/', [RFReplaceall]))) + Query.FieldByName('msg_text').AsString);
          // Прерывание потока
          if CheckMD5HashThread.Terminated then
          begin
            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Экстренное завершение потока CheckMD5HashThread.', 2);
            CheckMD5HashDone := False;
            Query.Close;
            ChangeQuery.Close;
            DublicateQuery.Close;
            Exit;
          end;
          //if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Список TSG_Proto: MD5String = ' + MD5String + ' | Query.FieldByName(''md5hash'') = ' + Query.FieldByName('md5hash').AsString, 2);
          if MD5String <> Query.FieldByName('md5hash').AsString then
          begin
            //WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ': ' + Query.FieldByName('uin').AsString + ' | ' + IntToStr(DateTimeToUnix(StrToDateTime(StringReplace(Query.FieldByName('msg_time').AsString, '-', '/', [RFReplaceall])))) + ' | ' + PrepareString(PWideChar(Query.FieldByName('msg_text').AsString)) + ' | ' + Query.FieldByName('md5hash').AsString + ' | '+ MD5String + #13#10 + '---------------------', 2);
            ChangeQuery.SQL.Clear;
            ChangeQuery.SQL.Text := 'update uin_'+ DBUserName + ' set md5hash = '''+ MD5String + ''' where id = ' + Query.FieldByName('id').AsString + ';';
            try
              ChangeQuery.ExecSQL;
            except
              on e: Exception do
              begin
                // Если нет коннекта или он разорвался, то реконектимся
                if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                begin
                  ZConnection1.Disconnect;
                  if not ReConnectDB then
                  begin
                    CheckMD5HashDone := False;
                    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                    Query.Close;
                    ChangeQuery.Close;
                    DublicateQuery.Close;
                    Exit;
                  end
                  else
                  begin
                    Query.Open;
                    Query.RecNo := QueryRecNo;
                    ChangeQuery.ExecSQL;
                  end;
                end;
                Inc(ErrMsgMD5Cnt);
                if MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*Duplicate entry*for key*') or
                  MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*column*is not unique*') or
                  MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*duplicate key value violates unique*') then
                begin
                  Inc(ErrMD5DublicateMesCount);
                  DublicateQuery.SQL.Clear;
                  DublicateQuery.SQL.Text := 'select id,uin,msg_time,msg_text,md5hash from uin_'+ DBUserName + ' where md5hash = '''+ MD5String + ''';';
                  try
                    DublicateQuery.Open;
                  except
                    on e: Exception do
                    begin
                      // Если нет коннекта или он разорвался, то реконектимся
                      if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                      begin
                        ZConnection1.Disconnect;
                        if not ReConnectDB then
                        begin
                          CheckMD5HashDone := False;
                          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                          Query.Close;
                          ChangeQuery.Close;
                          DublicateQuery.Close;
                          Exit;
                        end
                        else
                        begin
                          Query.Open;
                          Query.RecNo := QueryRecNo;
                          DublicateQuery.Open;
                        end;
                      end;
                    end;
                  end;
                  if DublicateQuery.FieldByName('md5hash').IsNull  then
                    DublicateMD5Hash := 'NULL_MD5_HASH'
                  else
                    DublicateMD5Hash := DublicateQuery.FieldByName('md5hash').AsString;
                  WriteInLog(ProfilePath, 'Original (table uin_'+ DBUserName +'): ' + DublicateQuery.FieldByName('id').AsString + ' | ' + DublicateQuery.FieldByName('uin').AsString + ' | ' + DublicateQuery.FieldByName('msg_time').AsString + ' | ' + StringReplace(UTF8ToWideString(DublicateQuery.FieldByName('msg_text').AsString),#13#10,'\n\r',[RFReplaceall]) + ' | ' + DublicateMD5Hash, 3);
                  DublicateQuery.Close;
                  DublicateQuery.SQL.Clear;
                  DublicateQuery.SQL.Text := 'select id,uin,msg_time,msg_text,md5hash from uin_'+ DBUserName + ' where id = '+ Query.FieldByName('id').AsString + ';';
                  try
                    DublicateQuery.Open;
                  except
                    on e: Exception do
                    begin
                      // Если нет коннекта или он разорвался, то реконектимся
                      if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                      begin
                        ZConnection1.Disconnect;
                        if not ReConnectDB then
                        begin
                          CheckMD5HashDone := False;
                          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                          Query.Close;
                          ChangeQuery.Close;
                          DublicateQuery.Close;
                          Exit;
                        end
                        else
                        begin
                          Query.Open;
                          Query.RecNo := QueryRecNo;
                          DublicateQuery.Open;
                        end;
                      end;
                    end;
                  end;
                  if DublicateQuery.FieldByName('md5hash').IsNull  then
                    DublicateMD5Hash := 'NULL_MD5_HASH'
                  else
                    DublicateMD5Hash := DublicateQuery.FieldByName('md5hash').AsString;
                  WriteInLog(ProfilePath, 'Duplicate (table uin_'+ DBUserName +'): ' + DublicateQuery.FieldByName('id').AsString + ' | ' + DublicateQuery.FieldByName('uin').AsString + ' | ' + DublicateQuery.FieldByName('msg_time').AsString + ' | ' + StringReplace(UTF8ToWideString(DublicateQuery.FieldByName('msg_text').AsString),#13#10,'\n\r',[RFReplaceall]) + ' | ' + DublicateMD5Hash, 3);
                  DublicateQuery.Close;
                  // Удаляем дубликаты
                  if DeleteDublicate then
                  begin
                    DublicateQuery.SQL.Clear;
                    DublicateQuery.SQL.Text := 'delete from uin_'+ DBUserName + ' where id = '+ Query.FieldByName('id').AsString + ';';
                    try
                      DublicateQuery.ExecSQL;
                      Inc(DeletedMD5DublicateMesCount);
                    except
                      on e: Exception do
                      begin
                        // Если нет коннекта или он разорвался, то реконектимся
                        if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                        begin
                          ZConnection1.Disconnect;
                          if not ReConnectDB then
                          begin
                            CheckMD5HashDone := False;
                            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                            Query.Close;
                            ChangeQuery.Close;
                            DublicateQuery.Close;
                            Exit;
                          end
                          else
                          begin
                            Query.Open;
                            Query.RecNo := QueryRecNo;
                            DublicateQuery.ExecSQL;
                          end;
                        end;
                        if WriteErrLog then
                          WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
                      end;
                    end;
                  end;
                  // End
                end;
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), StringReplace(e.Message,#13#10,'',[RFReplaceall])]), 1);
              end;
            end;
            ChangeQuery.Close;
            Inc(MsgMD5Cnt);
          end;
          // Вывод статистики
          if CheckQueryRecNo(TotalMD5Hash, QueryRecNo) then
          begin
            TMainSyncForm(Params).ThreadMsgNum := 2;
            TMainSyncForm(Params).ProgressBarCount := QueryRecNo;
            TMainSyncForm(Params).CheckTotalBrokenMD5HashСount := IntToStr(MsgMD5Cnt);
            TMainSyncForm(Params).CheckTotalChangeMD5HashСount := IntToStr(MsgMD5Cnt-ErrMsgMD5Cnt);
            TMainSyncForm(Params).CheckTotalMD5DublicateMesCount := IntToStr(ErrMD5DublicateMesCount);
            TMainSyncForm(Params).CheckTotalDeletedMD5DublicateMesCount := IntToStr(DeletedMD5DublicateMesCount);
            CheckMD5HashThread.Synchronize(TMainSyncForm(Params).MD5ThreadShowMessage);
          end;
          Query.Next;
        until Query.Eof;
        Query.Close;
      end;
      // End
      // Ищем дубликаты в таблице uin_chat_username
      Query.SQL.Clear;
      Query.SQL.Text := 'select count(*) as cnt from uin_chat_'+ DBUserName + ';';
      try
        Query.Open;
      except
        on e: Exception do
        begin // Реконект в случае потери связи
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре CheckMD5HashThreadExecute (Query): ' + Trim(e.Message), 2);
          if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
          begin
            ZConnection1.Disconnect;
            if not ReConnectDB then
            begin
              CheckMD5HashDone := False;
              if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
              Query.Close;
              ChangeQuery.Close;
              DublicateQuery.Close;
              Exit;
              end;
            end
            else
              try
                Query.Open;
              except
              end;
          end;
        end;
      TotalMD5Hash := Query.FieldByName('cnt').AsInteger;
      Query.Close;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Список TSG_Proto: Всего записей в таблице uin_chat_' + DBUserName + ' = ' + IntToStr(TotalMD5Hash), 2);
      // Вывод начальной статистики по MD5 хэшам
      TMainSyncForm(Params).ThreadMsgNum := 2;
      TMainSyncForm(Params).CheckTotalBrokenMD5HashСount := '0';
      TMainSyncForm(Params).CheckTotalChangeMD5HashСount := '0';
      TMainSyncForm(Params).CheckTotalMD5DublicateMesCount := '0';
      TMainSyncForm(Params).CheckTotalDeletedMD5DublicateMesCount := '0';
      TMainSyncForm(Params).CheckTotalHashMsgСount := TotalMD5Hash;
      TMainSyncForm(Params).ProgressBarCount := 0;
      CheckMD5HashThread.Synchronize(TMainSyncForm(Params).MD5ThreadShowMessage);
      // End
      if TotalMD5Hash = 0 then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: TotalMD5Hash = 0 - Завершение потока CheckMD5HashThread.', 2);
        CheckMD5HashDone := True;
        ChangeQuery.Close;
        DublicateQuery.Close;
        Exit;
      end;
      Query.SQL.Clear;
      Query.SQL.Text := 'select id,nick_name,msg_time,msg_text,md5hash from uin_chat_'+ DBUserName + ';';
      try
        Query.Open;
      except
        on e: Exception do
        begin // Реконект в случае потери связи
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Exception в процедуре CheckMD5HashThreadExecute (Query): ' + Trim(e.Message), 2);
          if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
          begin
            ZConnection1.Disconnect;
            if not ReConnectDB then
            begin
              CheckMD5HashDone := False;
              if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
              Query.Close;
              ChangeQuery.Close;
              DublicateQuery.Close;
              Exit;
              end;
            end
            else
              try
                Query.Open;
              except
              end;
          end;
        end;
      MsgMD5Cnt := 0;
      ErrMsgMD5Cnt := 0;
      ErrMD5DublicateMesCount := 0;
      DeletedMD5DublicateMesCount := 0;
      repeat
        QueryRecNo := Query.RecNo;
        MD5String := EncryptMD5(Query.FieldByName('nick_name').AsString + FormatDateTime('YYYY-MM-DD HH:MM:SS', StrToDateTime(StringReplace(Query.FieldByName('msg_time').AsString, '-', '/', [RFReplaceall]))) + Query.FieldByName('msg_text').AsString);
        if CheckMD5HashThread.Terminated then
        begin
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Экстренное завершение потока CheckMD5HashThread.', 2);
          CheckMD5HashDone := False;
          Query.Close;
          ChangeQuery.Close;
          DublicateQuery.Close;
          Exit;
        end;
        if MD5String <> Query.FieldByName('md5hash').AsString then
        begin
          ChangeQuery.SQL.Clear;
          ChangeQuery.SQL.Text := 'update uin_chat_'+ DBUserName + ' set md5hash = '''+ MD5String + ''' where id = ' + Query.FieldByName('id').AsString + ';';
          try
            ChangeQuery.ExecSQL;
          except
            on e :
              Exception do
              begin
                // Если нет коннекта или он разорвался, то реконектимся
                if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                begin
                  ZConnection1.Disconnect;
                  if not ReConnectDB then
                  begin
                    CheckMD5HashDone := False;
                    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                    Query.Close;
                    ChangeQuery.Close;
                    DublicateQuery.Close;
                    Exit;
                  end
                  else
                  begin
                    Query.Open;
                    Query.RecNo := QueryRecNo;
                    ChangeQuery.ExecSQL;
                  end;
                end;
                Inc(ErrMsgMD5Cnt);
                if MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*Duplicate entry*for key*') or
                    MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*column*is not unique*') or
                    MatchStrings(StringReplace(e.Message,#13#10,'',[RFReplaceall]), '*duplicate key value violates unique*') then
                begin
                  Inc(ErrMD5DublicateMesCount);
                  DublicateQuery.SQL.Clear;
                  DublicateQuery.SQL.Text := 'select id,nick_name,msg_time,msg_text,md5hash from uin_chat_'+ DBUserName + ' where md5hash = '''+ MD5String + ''';';
                  try
                    DublicateQuery.Open;
                  except
                    on e: Exception do
                    begin
                      // Если нет коннекта или он разорвался, то реконектимся
                      if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                      begin
                        ZConnection1.Disconnect;
                        if not ReConnectDB then
                        begin
                          CheckMD5HashDone := False;
                          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                          Query.Close;
                          ChangeQuery.Close;
                          DublicateQuery.Close;
                          Exit;
                        end
                        else
                        begin
                          Query.Open;
                          Query.RecNo := QueryRecNo;
                          DublicateQuery.Open;
                        end;
                      end;
                    end;
                  end;
                  if DublicateQuery.FieldByName('md5hash').IsNull  then
                    DublicateMD5Hash := 'NULL_MD5_HASH'
                  else
                    DublicateMD5Hash := DublicateQuery.FieldByName('md5hash').AsString;
                  WriteInLog(ProfilePath, 'Original (table uin_chat_'+ DBUserName +'): ' + DublicateQuery.FieldByName('id').AsString + ' | ' + DublicateQuery.FieldByName('nick_name').AsString + ' | ' + DublicateQuery.FieldByName('msg_time').AsString + ' | ' + StringReplace(UTF8ToWideString(DublicateQuery.FieldByName('msg_text').AsString),#13#10,'\n\r',[RFReplaceall]) + ' | ' + DublicateMD5Hash, 3);
                  DublicateQuery.Close;
                  DublicateQuery.SQL.Clear;
                  DublicateQuery.SQL.Text := 'select id,nick_name,msg_time,msg_text,md5hash from uin_chat_'+ DBUserName + ' where id = '+ Query.FieldByName('id').AsString + ';';
                  try
                    DublicateQuery.Open;
                  except
                    on e: Exception do
                    begin
                      // Если нет коннекта или он разорвался, то реконектимся
                      if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                      begin
                        ZConnection1.Disconnect;
                        if not ReConnectDB then
                        begin
                          CheckMD5HashDone := False;
                          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                          Query.Close;
                          ChangeQuery.Close;
                          DublicateQuery.Close;
                          Exit;
                        end
                        else
                        begin
                          Query.Open;
                          Query.RecNo := QueryRecNo;
                          DublicateQuery.Open;
                        end;
                      end;
                    end;
                  end;
                  if DublicateQuery.FieldByName('md5hash').IsNull  then
                    DublicateMD5Hash := 'NULL_MD5_HASH'
                  else
                    DublicateMD5Hash := DublicateQuery.FieldByName('md5hash').AsString;
                  WriteInLog(ProfilePath, 'Duplicate (table uin_chat_'+ DBUserName +'): ' + DublicateQuery.FieldByName('id').AsString + ' | ' + DublicateQuery.FieldByName('nick_name').AsString + ' | ' + DublicateQuery.FieldByName('msg_time').AsString + ' | ' + StringReplace(UTF8ToWideString(DublicateQuery.FieldByName('msg_text').AsString),#13#10,'\n\r',[RFReplaceall]) + ' | ' + DublicateMD5Hash, 3);
                  DublicateQuery.Close;
                  // Удаляем дубликаты
                  if DeleteDublicate then
                  begin
                    DublicateQuery.SQL.Clear;
                    DublicateQuery.SQL.Text := 'delete from uin_chat_'+ DBUserName + ' where id = '+ Query.FieldByName('id').AsString + ';';
                    try
                      DublicateQuery.ExecSQL;
                      Inc(DeletedMD5DublicateMesCount);
                    except
                      on e: Exception do
                      begin
                        // Если нет коннекта или он разорвался, то реконектимся
                        if (not ZConnection1.Connected) or (MatchStrings(e.Message, '*MySQL server has gone away*')) then
                        begin
                          ZConnection1.Disconnect;
                          if not ReConnectDB then
                          begin
                            CheckMD5HashDone := False;
                            if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadExecute: Неудачный ReConnectDB. Завершаем поток.', 2);
                            Query.Close;
                            ChangeQuery.Close;
                            DublicateQuery.Close;
                            Exit;
                          end
                          else
                          begin
                            Query.Open;
                            Query.RecNo := QueryRecNo;
                            DublicateQuery.ExecSQL;
                          end;
                        end;
                        if WriteErrLog then
                          WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
                      end;
                    end;
                    DublicateQuery.Close;
                  end;
                  // End
                end;
                if WriteErrLog then
                  WriteInLog(ProfilePath, Format(ERR_SEND_UPDATE, [FormatDateTime('dd.mm.yy hh:mm:ss', Now), Trim(e.Message)]), 1);
              end;
          end;
          ChangeQuery.Close;
          Inc(MsgMD5Cnt);
          //WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ': ' + ChangeQuery.SQL.Text, 2);
        end;
        // Вывод статистики
        if CheckQueryRecNo(TotalMD5Hash, QueryRecNo) then
        begin
          TMainSyncForm(Params).ThreadMsgNum := 2;
          TMainSyncForm(Params).ProgressBarCount := QueryRecNo;
          TMainSyncForm(Params).CheckTotalBrokenMD5HashСount := IntToStr(MsgMD5Cnt);
          TMainSyncForm(Params).CheckTotalChangeMD5HashСount := IntToStr(MsgMD5Cnt-ErrMsgMD5Cnt);
          TMainSyncForm(Params).CheckTotalMD5DublicateMesCount := IntToStr(ErrMD5DublicateMesCount);
          TMainSyncForm(Params).CheckTotalDeletedMD5DublicateMesCount := IntToStr(DeletedMD5DublicateMesCount);
          CheckMD5HashThread.Synchronize(TMainSyncForm(Params).MD5ThreadShowMessage);
        end;
        Query.Next;
      until Query.Eof;
      Query.Close;
      // End
    finally
      Query.Free;
      ChangeQuery.Free;
      DublicateQuery.Free;
    end;
    CheckMD5HashDone := True;
  end;
end;

{ Поток перерасчета MD5-хешей завершен }
procedure TMainSyncForm.CheckMD5HashThreadFinish(Sender: TObject);
begin
  SyncProgressBar.Position := 0;
  CheckMD5HashStartedEnabled := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CheckMD5HashThreadFinish: Поток CheckMD5HashThread выполнен.', 2);
  // Отключаемся от БД
  if (not SyncHistoryStartedEnabled) and (not UpdateContactListStartedEnabled) then
    ZConnection1.Disconnect;
  // Заканчиваем мигать в трее
  if not SyncHistoryStartedEnabled then
    StopSyncTrayFlashingTimer;
  // Включаем кнопки и т.п.
  EnableButton;
  // Запуск таймера синхронизации по времени
  if (StartStopSyncButton.Visible) and (not SyncTimerEnabled) and (not SyncHistoryStartedEnabled) then
    StartStopSyncButtonClick(StartStopSyncButton);
  // Подсказка в трее
  if SyncHistoryStartedEnabled then
    HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStarted')
  else
    HistoryToDBSyncTray.Hint := Caption;
  // Если обновление прошло без ошибок
  if CheckMD5HashDone then
    ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncMD5Done'))
  else
    ShowBalloonHint(MainSyncForm.Caption, GetLangStr('HistoryToDBSyncMD5Err') + #13#10 + GetLangStr('SeeErrLog'));
  // Выход из программы по отложенному запросу
  if CloseRequest and (not SyncHistoryStartedEnabled) and (not UpdateContactListStartedEnabled) then
    HistoryExitClick(Self);
end;

{ Синхронизация потока SyncThread с основной программой - Вывод сообщений }
procedure TMainSyncForm.SyncThreadShowMessage;
begin
  case ThreadMsgNum of
  1: // Начало синхронизации, остановка таймеров, отключение кнопок
    begin
      // Останавливаем таймер синхронизации
      if (StartStopSyncButton.Visible) and (SyncTimerEnabled) then
        StartStopSyncButtonClick(StartStopSyncButton);
      // Меняем сообщение в трее и т.п.
      HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStarted');
      HistoryToDBSyncTray.IconIndex := 0;
      LSyncStatusSet.Caption := GetLangStr('HistoryToDBSyncStarted');
      LSyncStatusSet.Hint := 'HistoryToDBSyncStarted';
      // Отключаем кнопки
      DisableButton;
      // Запускаем мигание в трее
      if not SyncTrayFlashingTimerEnabled then
        StartSyncTrayFlashingTimer;
      // Вывод сообщения в трей
      if ThreadMsgStr <> '' then
        ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  2:
    begin
      if not SyncTrayFlashingTimerEnabled then // Мигаем в трее
        StartSyncTrayFlashingTimer;
      // Меняем сообщение в трее и т.п.
      HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStarted');
      // Прогресбар
      try
        SyncProgressBar.Max := SyncTotalMesCount - 1;
        SyncProgressBar.Position := SyncMesCurrentCount;
      except
      end;
      LMesCurrentCount.Caption := IntToStr(SyncMesCurrentCount);
      LEncryptMesCount.Caption := IntToStr(SyncEncryptMsgCount);
      LTotalMesCount.Caption := IntToStr(SyncTotalMesCount);
      if SyncBadMesCount <> '' then
        LBadMesCount.Caption := SyncBadMesCount;
      if SyncDublicateMesCount <> '' then
        LDublicateMesCount.Caption := SyncDublicateMesCount;
      if SyncStartTime <> '' then
        LStartTime.Caption := SyncStartTime;
      if SyncEndTime <> '' then
        LEndTime.Caption := SyncEndTime;
      // Вывод сообщения в трей
      if ThreadMsgStr <> '' then
        ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  3:
    begin
      ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  end;
end;

{ Синхронизация потока CheckMD5HashThread с основной программой - Вывод сообщений }
procedure TMainSyncForm.MD5ThreadShowMessage;
begin
  case ThreadMsgNum of
  1: // Начало проверки, остановка всяких ненужных вещей
    begin
      // Останавливаем таймер синхронизации
      if (StartStopSyncButton.Visible) and (SyncTimerEnabled) then
        StartStopSyncButtonClick(StartStopSyncButton);
      // Меняем сообщение в трее
      if (not SyncHistoryStartedEnabled) then
      begin
        HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStartMD5');
        HistoryToDBSyncTray.IconIndex := 0;
      end;
      // Отключаем кнопки
      DisableButton;
      // Запускаем мигание в трее
      if not SyncTrayFlashingTimerEnabled then
        StartSyncTrayFlashingTimer;
      if ThreadMsgStr <> '' then
        ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  2: // Вывод статистики по MD5 хэшам
    begin
      LTotalHashMsgСount.Caption := IntToStr(CheckTotalHashMsgСount);
      // Запуск мигания в трее
      if not SyncTrayFlashingTimerEnabled then
        StartSyncTrayFlashingTimer;
      if CheckTotalBrokenMD5HashСount <> '' then
        LTotalBrokenMD5HashСount.Caption := CheckTotalBrokenMD5HashСount;
      if CheckTotalChangeMD5HashСount <> '' then
        LTotalChangeMD5HashСount.Caption := CheckTotalChangeMD5HashСount;
      if CheckTotalMD5DublicateMesCount <> '' then
        LMD5DublicateMesCount.Caption := CheckTotalMD5DublicateMesCount;
      if CheckTotalDeletedMD5DublicateMesCount <> '' then
        LDeletedMD5DublicateMesCount.Caption := CheckTotalDeletedMD5DublicateMesCount;
      // Прогресбар
      try
        SyncProgressBar.Max := CheckTotalHashMsgСount - 1;
        SyncProgressBar.Position := ProgressBarCount;
      except
      end;
    end;
  3: // Вывод всплывающих сообщений в трей
    begin
      ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  end;
end;

{ Синхронизация потока UpdateContactListThread с основной программой - Вывод сообщений }
procedure TMainSyncForm.CLThreadShowMessage;
begin
  case ThreadMsgNum of
  1: // Начало проверки, остановка всяких ненужных вещей
    begin
      // Останавливаем таймер синхронизации
      if (StartStopSyncButton.Visible) and (SyncTimerEnabled) then
        StartStopSyncButtonClick(StartStopSyncButton);
      // Меняем сообщение в трее
      if (not SyncHistoryStartedEnabled) then
      begin
        HistoryToDBSyncTray.Hint := Caption + ' - ' + GetLangStr('HistoryToDBSyncStartUpdateCL');
        HistoryToDBSyncTray.IconIndex := 0;
      end;
      // Отключаем кнопки
      DisableButton;
      // Запускаем мигание в трее
      if not SyncTrayFlashingTimerEnabled then
        StartSyncTrayFlashingTimer;
      if ThreadMsgStr <> '' then
        ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  2: // Вывод статистики
    begin
      // Прогресбар
      try
        SyncProgressBar.Max := CheckTotalHashMsgСount - 1;
        SyncProgressBar.Position := ProgressBarCount;
      except
      end;
    end;
  3: // Вывод всплывающих сообщений в трей
    begin
      ShowBalloonHint(MainSyncForm.Caption, ThreadMsgStr);
    end;
  end;
end;

{ Выводим окно для ввода пароля ключа шифрования }
procedure TMainSyncForm.ReadEncryptionKey;
var
  EncryptionKeyPassword, KeyPassword: String;
  TempEncryptionKey, TempEncryptionKeyID: String;
  Status: Integer;
begin
  if not KeyPasswdSave then
  begin
    if EncryptionKey = '' then
    begin
      KeyPasswdForm.Show;
      while Global_KeyPasswdForm_Showing do
      begin
        Sleep(1);
        Forms.Application.ProcessMessages;
      end;
    end;
  end
  else
  begin
    Status := GetEncryptionKey('', TempEncryptionKey, TempEncryptionKeyID);
    if Status = 1 then // Ошибка - В БД неверный пароль ключа
      MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncErrKeyPassword'))
    else if Status = 2 then // Пароль верный, ключ получен
    begin
      EncryptionKeyID := TempEncryptionKeyID;
      EncryptionKey := TempEncryptionKey;
    end
    else if Status = 3 then // Ошибка расшифровки
      MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncErrDecryptKey'))
    else if Status = 4 then // Ошибка - Найдено более 1 акт. ключа
      MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncMultiActiveKey'))
    else if Status = 5 then // Ошибка - Не найдено акт. ключей
      MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('HistoryToDBSyncErrActiveKey'))
    else if Status = 6 then // Ошибка - Нет доступа к БД
      MsgInf(MainSyncForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncCheckEncKey'), GetLangStr('ErrDBConnect'))
    else  // Ошибка - В файле неверный пароль ключа
    begin
      KeyPasswdForm.Show;
      while Global_KeyPasswdForm_Showing do
      begin
        Sleep(1);
        Forms.Application.ProcessMessages;
      end;
    end;
  end;
end;

{ Проверяем активность ключа и его получаем его номер }
function TMainSyncForm.GetCurrentEncryptionKeyID(var ActiveKeyID: String): Integer;
var
  KeyCnt, Status: Integer;
begin
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    SQL_Zeos_Key('select count(*) as cnt from key_'+ DBUserName + ' where status_key = ''1''');
    KeyCnt := KeyQuery.FieldByName('cnt').AsInteger;
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция GetCurrentEncryptionKeyID: Найдено ' + IntToStr(KeyCnt) + ' активных ключей.', 2);
    if KeyCnt = 1 then // Найден 1 активный ключ
    begin
      SQL_Zeos_Key('select id from key_'+ DBUserName + ' where status_key = ''1''');
      Status := 1; // Все хорошо
      ActiveKeyID := KeyQuery.FieldByName('id').AsString;
    end
    else if KeyCnt > 1 then
      Status := 2  // Ошибка - Найдено более 1 акт. ключа
    else
      Status := 3; // Ошибка - Не найдено акт. ключей
    if (not CheckMD5HashStartedEnabled) and (not SyncHistoryStartedEnabled) and (not UpdateContactListStartedEnabled) then
      ZConnection1.Disconnect;
  end
  else
    Status := 4; // Ошибка - Нет подключения к БД
  Result := Status;
end;

{ Получаем ключь шифрования из БД }
function TMainSyncForm.GetEncryptionKey(KeyPwd: String; var EncryptKey, EncryptKeyID: String): Integer;
var
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  KeyCnt, Status: Integer;
  INIKeyPasswd: String;
  INIKeyPasswdRead: Boolean;
  DBKeyID, DBKeyEncryptionMethod, DBEncryptKey: String;
  FinalFullKey, FinalKeyID, FinalKeyEncryptionMethod, FinalKey, KeyPassword: String;
begin
  // Подключаемся к базе
  ConnectDB;
  if ZConnection1.Connected then
  begin
    SQL_Zeos_Key('select count(*) as cnt from key_'+ DBUserName + ' where status_key = ''1''');
    KeyCnt := KeyQuery.FieldByName('cnt').AsInteger;
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция GetEncryptionKey: Найдено ' + IntToStr(KeyCnt) + ' активных ключей.', 2);
    if KeyCnt = 1 then
    begin
      SQL_Zeos_Key('select id, encryption_method, encryption_key from key_'+ DBUserName + ' where status_key = ''1''');
      DBEncryptKey := KeyQuery.FieldByName('encryption_key').AsString;
      DBKeyID := KeyQuery.FieldByName('id').AsString;
      DBKeyEncryptionMethod := KeyQuery.FieldByName('encryption_method').AsString;
      // Читаем пароль только прип вызове из MainForm
      INIKeyPasswdRead := False;
      if (KeyPasswdSave) and (not Global_KeyPasswdForm_Showing) then
      begin
        INIKeyPasswd := ReadCustomINI(ProfilePath, 'Main', 'KeyPasswd'+DBKeyID, 'NoSave');
        KeyPwd := DecryptStr(INIKeyPasswd);
        INIKeyPasswdRead := True;
      end;
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
          if INIKeyPasswdRead then
            Status := 7  // Ошибка - В файле неверный пароль ключа
          else
            Status := 1; // Ошибка - В БД неверный пароль ключа
        end
        else
        begin
          EncryptKey := Base64DecodeStr(FinalKey);
          EncryptKeyID := DBKeyID;
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
    else if KeyCnt > 1 then
      Status := 4 // Ошибка - Найдено более 1 акт. ключа
    else
      Status := 5; // Ошибка - Не найдено акт. ключей
    if (not CheckMD5HashStartedEnabled) and (not SyncHistoryStartedEnabled) and (not UpdateContactListStartedEnabled) then
      ZConnection1.Disconnect;
  end
  else
    Status := 6; // Ошибка - Нет подключения к БД
  Result := Status;
end;

{ Поиск в строке по регулярному выражению }
function TMainSyncForm.RegExprMatchStrings(Source, PatternRegExpr: WideString): Boolean;
var
  RegStr: TRegExpr;
begin
  RegStr := TRegExpr.Create;
  try
    RegStr.Expression := PatternRegExpr;
    if RegStr.Exec(Source) then
      Result := True
    else
      Result := False;
  finally
    RegStr.Free;
  end;
end;

{ Подключенгие к БД с обработкой ошибок }
procedure TMainSyncForm.ConnectDB;
begin
  // Подключаемся к базе
  if not ZConnection1.Connected then
  begin
    try
      ZConnection1.Connect;
    except
      on e: Exception do
      begin
        if not ReConnectDB then
          Exit;
      end
    end;
  end;
end;

function TMainSyncForm.ReConnectDB: Boolean;
var
  I: Integer;
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Запуск.', 2);
  if not ZConnection1.Connected then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Нет подключения к БД.', 2);
    // Откл. мигание в трее
    if SyncTrayFlashingTimerEnabled then
      StopSyncTrayFlashingTimer;
    // Пробуем переподключиться
    HistoryToDBSyncTray.IconIndex := 2;
    I := 0;
    while (not ZConnection1.Connected) and (I < ReconnectCount) do
    begin
      Inc(I);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Выполняем ZConnection1.Connect #' + IntToStr(I), 2);
      try
        ZConnection1.Connect;
      except
        on e: Exception do
        begin
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
      HistoryToDBSyncTray.IconIndex := 0;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Подключение к БД установлено.', 2);
      Result := True;
    end
    else
    begin
      HistoryToDBSyncTray.IconIndex := 2;
      ShowBalloonHint(MainSyncForm.Caption, GetLangStr('ErrDBConnect') + #13#10 + GetLAngStr('SeeErrLog'));
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Функция ReConnectDB: Выполнено ' + IntToStr(ReconnectCount) + ' попыток подключения к БД с интервалом ' + IntToStr(ReconnectInterval) + ' мсек. Подключиться к БД не удалось.', 2);
      Result := False;
    end;
  end
  else
    Result := True;
end;

procedure TMainSyncForm.RunTimeSync;
begin
  if SyncMethod = 2 then
  begin
    if ((SyncInterval >= 0) and (SyncInterval < 4)) or (SyncInterval = 8) then
    begin
      StopJvSyncTimer;
      StartJvSyncTimer;
      StartStopSyncButton.Visible := True;
    end
    else
    begin
      StopJvSyncTimer;
      StartStopSyncButton.Visible := False;
    end;
  end
  else
  begin
    StopJvSyncTimer;
    StartStopSyncButton.Visible := False;
  end;
end;

{ Включаем некоторые пункты меню в трее }
procedure TMainSyncForm.EnableButton;
begin
  SyncButton.Enabled := True;
  StartStopSyncButton.Enabled := True;
end;

{ Отключаем некоторые пункты меню в трее }
procedure TMainSyncForm.DisableButton;
begin
  SyncButton.Enabled := False;
  StartStopSyncButton.Enabled := False;
end;

{ Вкл. поддержки Skype }
procedure TMainSyncForm.EnableSkype;
begin
  SkypeInit := False;
  SkypeRunDone := False;
  SkypeAttachDone := False;
  try
    Skype := TSkype.Create(Self);
    SkypeInit := True;
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Выполнено TSkype.Create', 4);
    if Global_RunningSkypeOnStartup then
    begin
      if not Skype.Client.IsRunning then
      begin
        LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeRun');
        LSkypeStatus.Hint := 'HistoryToDBSyncSkypeRun';
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Пытаемся запустить Skype...', 4);
        Skype.Client.Start(True, True);
      end;
    end;
  except
    on e :
      Exception do
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Ошибка создания интерфейса Skype: ' + e.Message, 4);
        LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeInitErr');
        LSkypeStatus.Hint := 'HistoryToDBSyncSkypeInitErr';
        SkypeInit := False;
        SkypeRunDone := False;
        Exit;
      end;
  end;
  SkypeStrList := TStringList.Create;
  SkypeChatList := TStringGrid.Create(nil);
  SkypeChatList.FixedCols := 0;
  SkypeChatList.FixedRows := 0;
  SkypeChatList.ColCount := 3;
  SkypeChatList.RowCount := 0;
  SkypeStrList.Clear;
  JvThreadTimerSkype.Enabled := True;
end;

{ Сработка таймера для автоматического режима синхронизации }
procedure TMainSyncForm.JvThreadTimerAutoSyncTimer(Sender: TObject);
begin
  JvThreadTimerAutoSync.Enabled := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура JvThreadTimerAutoSyncTimer: Выполняем синхронизацию истории в режиме авто.', 2);
  SyncButtonClick(Self);
end;

procedure TMainSyncForm.JvThreadTimerSkypeTimer(Sender: TObject);
begin
  // Запускаем Skype только если запуск HistoryToDBSync идет с 3 параметром = 0
  if (not Skype.Client.IsRunning) and (not SkypeRunDone) and (IMClientType = 'Skype') then
  begin
    try
      LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeRun');
      LSkypeStatus.Hint := 'HistoryToDBSyncSkypeRun';
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Пытаемся запустить Skype...', 4);
      Skype.Client.Start(True, False);
      SkypeRunDone := True;
    except
      on e :
        Exception do
        begin
          SkypeRunDone := False;
          LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeRunErr');
          LSkypeStatus.Hint := 'HistoryToDBSyncSkypeRunErr';
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Ошибка запуска Skype: ' + e.Message, 4);
        end;
    end;
  end;
  if (Skype.Client.IsRunning) and (not SkypeAttachDone) then
  begin
    try
      Skype.OnUILanguageChanged := SkypeUILanguageChanged;
      Skype.OnChatMembersChanged := SkypeChatMembersChanged;
      Skype.OnAttachmentStatus := SkypeAttachmentStatus;
      Skype.OnMessageStatus := SkypeMessageStatus;
      Skype.OnApplicationDatagram   := SkypeApplicationDatagram;
      Skype.Attach(SkypeProtocol, False);
      SkypeAttachDone := True;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Выполнено Skype.Attach', 4);
    except
      on e :
        Exception do
        begin
          LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeErrCreate');
          LSkypeStatus.Hint := 'HistoryToDBSyncSkypeErrCreate';
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Ошибка создания экземпляра Skype: ' + e.Message, 4);
        end;
    end;
  end;
end;

{ Откл. поддержки Skype }
procedure TMainSyncForm.DisableSkype;
begin
  if Assigned(Skype) then
  begin
    try
      JvThreadTimerSkype.Enabled := False;
      SkypeStrList.Free;
      SkypeChatList.Free;
      Skype.Application[ProgramsName].Delete;
      Skype.Destroy;
      Skype := nil;
      SkypeAttachDone := False;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Экземпляр Skype удален.', 4);
    except
      on e :
        Exception do
        begin
          LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeErrDelete');
          LSkypeStatus.Hint := 'HistoryToDBSyncSkypeErrDelete';
          if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Ошибка удаления экземпляра Skype: ' + e.Message, 4);
        end;
    end;
  end;
end;

procedure TMainSyncForm.SkypeUILanguageChanged(ASender: TObject; const code: WideString);
begin
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeUILanguageChanged: Смена языка интерфейса - ' + UpperCase(code), 4);
  if (Skype.Client.IsRunning) and (SkypeAttachDone) and (code = 'ru') then
  begin
    FLanguage := 'Russian';
    CoreLanguageChanged;
  end
  else if (Skype.Client.IsRunning) and (SkypeAttachDone) and (code <> 'ru') then
  begin
    FLanguage := 'English';
    CoreLanguageChanged;
  end;
end;

// Значения параметра Status:
//  cmsUnknown  = $FFFFFFFF;
//  cmsSending  = $00000000;
//  cmsSent     = $00000001;
//  cmsReceived = $00000002;
//  cmsRead     = $00000003;
// pMessage.FromDisplayName - Имя от кого принято сообщение
// pMessage.FromHandle - UserID от кого принято сообщение
// pMessage.Chat.FriendlyName - Имя кому отправлено сообщение
// pMessage.Chat.DialogPartner - UserID кому отправлено сообщение
procedure TMainSyncForm.SkypeMessageStatus(Sender: TObject; const pMessage: IChatMessage; Status: TChatMessageStatus);
var
  Cnt: Integer;
  ChatName, SkypeMsgStr: WideString;
  Date_Str: String;
  aChatName, aNickName, aProtoAcc, aMsgText, MD5String, DialogPartnerFullName: WideString;
  aMsgType, SkypeSearchID, SkypeChatListRowCount: Integer;
  aIsPrivate, ChatNameChange: Boolean;
begin
  if (pMessage.Chat.type_ = cmeCreatedChatWith) or (pMessage.Chat.type_ = cmeSetTopic) then
  begin
    ChatNameChange := False;
    if pMessage.Chat.Topic = '' then
    begin
      {if pMessage.Chat.Members.Count <= 2 then}
        ChatName := Skype.User[pMessage.Chat.DialogPartner].FullName;
        if ChatName = '' then
          ChatName := pMessage.Chat.DialogPartner;
      {else
        ChatName :=  'Групповой чат';}
    end
    else
    begin
      ChatName :=  pMessage.Chat.Topic;
      if ChatName = '' then
        ChatName := pMessage.Chat.DialogPartner;
    end;

    SkypeSearchID := SkypeChatList.Cols[0].IndexOf(pMessage.Chat.Name);
    if SkypeSearchID <> -1 then // Нашли! SkypeSearchID - строка
    begin
      if SkypeChatList.Cells[1,SkypeSearchID] <> ChatName then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: Изменение имени чата: ID чата = ' + pMessage.Chat.Name + ' | Имя чата до = ' + SkypeChatList.Cells[1,SkypeSearchID] + ' | Имя чата после = ' + ChatName + ' | Количество участников = ' + IntToStr(pMessage.Chat.Members.Count), 4);
        SkypeChatList.Cells[1,SkypeSearchID] := ChatName;
        ChatNameChange := True;
      end;
      if SkypeChatList.Cells[2,SkypeSearchID] <> IntToStr(pMessage.Chat.Members.Count) then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: Изменение кол. участников чата: ID чата = ' + pMessage.Chat.Name + ' | Имя чата = ' + ChatName + ' | Кол. участников до = ' + SkypeChatList.Cells[2,SkypeSearchID] + ' | Кол. участников после = ' + IntToStr(pMessage.Chat.Members.Count), 4);
        SkypeChatList.Cells[2,SkypeSearchID] := IntToStr(pMessage.Chat.Members.Count);
      end;
    end
    else
    begin
      SkypeChatListRowCount := SkypeChatList.RowCount-1;
      SkypeChatList.Cells[0, SkypeChatListRowCount] := pMessage.Chat.Name;
      SkypeChatList.Cells[1, SkypeChatListRowCount] := ChatName;
      SkypeChatList.Cells[2, SkypeChatListRowCount] := IntToStr(pMessage.Chat.Members.Count);
      SkypeChatList.RowCount := SkypeChatListRowCount+2;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: Создан чат: ID чата = ' + pMessage.Chat.Name + ' | Имя чата = ' + ChatName + ' | Кол. учасников = ' + IntToStr(pMessage.Chat.Members.Count), 4);
    end;
    if EnableDebug then
    begin
      for Cnt := 0 to SkypeChatList.RowCount-2 do
        WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: SkypeChatList: ID чата = ' + SkypeChatList.Cells[0, Cnt] + ' | Имя чата = ' + SkypeChatList.Cells[1, Cnt] + ' | Кол. учасников = ' + SkypeChatList.Cells[2, Cnt], 4);
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: SkypeChatList: RowCount = ' + IntToStr(SkypeChatList.RowCount-1), 4);
    end;
  end
  else
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeMessageStatus: ID чата = ' + pMessage.Chat.Name + ' | Имя чат = ' + pMessage.Chat.Topic  + ' | ChatMessageType = ' + Skype.Convert.ChatMessageTypeToText(pMessage.Chat.type_) + ' | Кол. учасников = ' + IntToStr(pMessage.Chat.Members.Count), 4);
  end;

  {if ((Status = cmsReceived) and (pMessage.Chat.Members.Count > 2) and (pMessage.Body <> '')) or ((Status = cmsSent)  and (pMessage.Chat.Members.Count > 2) and (pMessage.Body <> '')) then
  begin
    Log('Всего в чате: '+ IntToStr(pMessage.Chat.Members.Count));
    for i:=1 to pMessage.Chat.Members.Count do
    begin
      Log('Участник №' + IntToStr(i) +': ' + pMessage.Chat.Members.Item[i].FullName + ' (' + pMessage.Chat.Members.Item[i].Handle + ')');
    end;
    Log('===');
  end;}
  if pMessage.Body <> '' then
  begin
   case Status of
    cmsReceived :
    begin
      if pMessage.Chat.Members.Count <= 2 then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Принято от ' + pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + ')', 4);
        aNickName := WideStringToUTF8(PrepareString(pWideChar(pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ')')));
        aIsPrivate := True;
      end
      else
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Принято от ' + pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + ')', 4);
        aNickName := WideStringToUTF8(PrepareString(pWideChar(pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ')')));
        aIsPrivate := False;
      end;
      aMsgType := 0;
      aMsgText :=  WideStringToUTF8(PrepareString(pWideChar(pMessage.Body)));
      MD5String := aNickName + FormatDateTime('YYYY-MM-DD HH:MM:SS', pMessage.Timestamp) + aMsgText;
      aChatName := WideStringToUTF8(PrepareString(pWideChar(ChatName)));
      aProtoAcc := 'Skype';
      if (DBType = 'oracle') or (DBType = 'oracle-9i') then
        Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', pMessage.Timestamp)
      else
        Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', pMessage.Timestamp);
      if not ChatNameChange then
      begin
        if (MatchStrings(DBType, 'oracle*')) then // Если Oracle, то пишем SQL-лог в формате CHAT_MSG_LOG_ORACLE
          WriteInLog(ProfilePath, Format(SKYPE_CHAT_MSG_LOG_ORACLE, [DBUserName, IntToStr(aMsgType), 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), '0', '0', aMsgText, EncryptMD5(MD5String)]), 0)
        else
          WriteInLog(ProfilePath, Format(SKYPE_CHAT_MSG_LOG, [DBUserName, IntToStr(aMsgType), Date_Str, aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), '0', '0', aMsgText, EncryptMD5(MD5String)]), 0);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Принято для ' + Skype.User[Skype.CurrentUserHandle].FullName + ' (' + Skype.CurrentUserHandle + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + '): ' + pMessage.Body, 4);
      end;
      ChatNameChange := False;
      //SkypeStrList.Add(SkypeMsgStr);
    end;
    cmsSent :
    begin
      if pMessage.Chat.Members.Count <= 2 then
      begin
        DialogPartnerFullName := Skype.User[pMessage.Chat.DialogPartner].FullName;
        if DialogPartnerFullName = '' then
          DialogPartnerFullName := Skype.User[pMessage.Chat.DialogPartner].DisplayName;
        if DialogPartnerFullName = '' then
          DialogPartnerFullName := pMessage.Chat.DialogPartner;
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Отправлено для ' + DialogPartnerFullName + ' (' + pMessage.Chat.DialogPartner + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + ')', 4);
        aNickName := WideStringToUTF8(PrepareString(pWideChar(DialogPartnerFullName + ' (' + pMessage.Chat.DialogPartner + ')')));
        aIsPrivate := True;
      end
      else
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Отправлено для чата ' + ChatName + ' (' + pMessage.FromHandle + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + ')', 4);
        aNickName := WideStringToUTF8(PrepareString(pWideChar(pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ')')));
        aIsPrivate := False;
      end;
      aMsgType := 1;
      aMsgText :=  WideStringToUTF8(PrepareString(pWideChar(pMessage.Body)));
      MD5String := aNickName + FormatDateTime('YYYY-MM-DD HH:MM:SS', pMessage.Timestamp) + aMsgText;
      aChatName := WideStringToUTF8(PrepareString(pWideChar(ChatName)));
      aProtoAcc := 'Skype';
      if (DBType = 'oracle') or (DBType = 'oracle-9i') then
        Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', pMessage.Timestamp)
      else
        Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', pMessage.Timestamp);
      if not ChatNameChange then
      begin
        if (MatchStrings(DBType, 'oracle*')) then // Если Oracle, то пишем SQL-лог в формате CHAT_MSG_LOG_ORACLE
          WriteInLog(ProfilePath, Format(SKYPE_CHAT_MSG_LOG_ORACLE, [DBUserName, IntToStr(aMsgType), 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), '0', '0', aMsgText, EncryptMD5(MD5String)]), 0)
        else
          WriteInLog(ProfilePath, Format(SKYPE_CHAT_MSG_LOG, [DBUserName, IntToStr(aMsgType), Date_Str, aChatName, aProtoAcc, aNickName, BoolToIntStr(aIsPrivate), '0', '0', aMsgText, EncryptMD5(MD5String)]), 0);
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Отправлено от ' + pMessage.FromDisplayName + ' (' + pMessage.FromHandle + ') (' + FormatDateTime('dd.mm.yy hh:mm:ss', pMessage.Timestamp) + '): ' + pMessage.Body, 4);
      end;
      ChatNameChange := False;
    end;
   end;
  end;
end;

procedure TMainSyncForm.SkypeAttachmentStatus(Sender: TObject; Status: TOleEnum);
begin
  if Status = apiAttachPendingAuthorization then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachPendingAuthorization');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachPendingAuthorization';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: Запрос авторизации.', 4);
  end
  else if Status = apiAttachSuccess then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachSuccess');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachSuccess';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: Подключение разрешено.', 4);
  end
  else if Status = apiAttachRefused then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachRefused');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachRefused';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: Подключение отклонено.', 4);
  end
  else if Status = apiAttachNotAvailable then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachNotAvailable');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachNotAvailable';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: Подключение отключено.', 4);
    SkypeAttachDone := False;
  end
  else if Status = apiAttachAvailable then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachAvailable');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachAvailable';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: Skype API доступно.', 4);
  end
  else
  begin
    LSkypeStatus.Caption := Skype.Convert.AttachmentStatusToText(Status);
    LSkypeStatus.Hint := '';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Статус подключения к экземпляру Skype: ' + Skype.Convert.AttachmentStatusToText(Status), 4);
  end;
  if Status = apiAttachAvailable then
    Skype.Attach(SkypeProtocol, False);
  if Status = apiAttachSuccess Then
  begin
    Skype.Application[ProgramsName].Create;
    LSkypeStatus.Caption := Skype.CurrentUser.FullName + ' (' + Skype.CurrentUser.Handle + ')';
    LSkypeStatus.Hint := '';
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Подключено: ' + Skype.CurrentUser.FullName + ' (' + Skype.CurrentUser.Handle + ')', 4);
  end;
end;

procedure TMainSyncForm.SkypeApplicationDatagram(Sender: TObject;
      const pApp: IApplication; const pStream: IApplicationStream;
      const Text: WideString);
begin
  if pApp.Name = ProgramsName then
  begin
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - SkypeApplicationDatagram: ' + pStream.Handle, 4);
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - SkypeApplicationDatagram: ' + Text, 4);
  end;
end;

procedure  TMainSyncForm.SkypeChatMembersChanged(ASender: TObject; const pChat: IChat; const pMembers: IUserCollection);
var
  ChatName: WideString;
  pMembersCnt, SkypeSearchID, SkypeChatListRowCount: Integer;
begin
  if (pChat.type_ = cmeCreatedChatWith) or (pChat.type_ = cmeSetTopic) then
  begin
    if pChat.Topic = '' then
    begin
      {if pChat.Members.Count <= 2 then}
        ChatName := Skype.User[pChat.DialogPartner].FullName;
      {else
        ChatName :=  'Групповой чат';}
    end
    else
      ChatName :=  pChat.Topic;

    SkypeSearchID := SkypeChatList.Cols[0].IndexOf(pChat.Name);
    if SkypeSearchID <> -1 then // Нашли! SkypeSearchID - строка
    begin
      if SkypeChatList.Cells[1,SkypeSearchID] <> ChatName then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Изменение имени чата: ID чата = ' + pChat.Name + ' | Имя чата до = ' + SkypeChatList.Cells[1,SkypeSearchID] + ' | Имя чата после = ' + ChatName + ' | Количество участников = ' + IntToStr(pMembers.Count), 4);
        SkypeChatList.Cells[1,SkypeSearchID] := ChatName;
      end;
      if SkypeChatList.Cells[2,SkypeSearchID] <> IntToStr(pMembers.Count) then
      begin
        if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Изменение кол. участников чата: ID чата = ' + pChat.Name + ' | Имя чата = ' + ChatName + ' | Кол. участников до = ' + SkypeChatList.Cells[2,SkypeSearchID] + ' | Кол. участников после = ' + IntToStr(pMembers.Count), 4);
        SkypeChatList.Cells[2,SkypeSearchID] := IntToStr(pMembers.Count);
        if EnableDebug then
        begin
          for pMembersCnt:=1 to pMembers.Count do
            WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Участник чата №' + IntToStr(pMembersCnt) +': ' + pMembers.Item[pMembersCnt].FullName + ' (' + pMembers.Item[pMembersCnt].Handle + ')', 4);
        end;
      end;
    end
    else
    begin
      SkypeChatListRowCount := SkypeChatList.RowCount;
      SkypeChatList.Cells[0, SkypeChatListRowCount+1] := pChat.Name;
      SkypeChatList.Cells[1, SkypeChatListRowCount+1] := ChatName;
      SkypeChatList.Cells[2, SkypeChatListRowCount+1] := IntToStr(pMembers.Count);
      SkypeChatList.RowCount := SkypeChatListRowCount+1;
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Создан чат: ID чата = ' + pChat.Name + ' | Имя чата = ' + ChatName + ' | Количество участников = ' + IntToStr(pMembers.Count), 4);
    end;
  end;

  {if EnableDebug then
  begin
    for Cnt := 0 to SkypeChatList.RowCount-2 do
      WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: SkypeChatList: ID чата = ' + SkypeChatList.Cells[0, Cnt] + ' | Имя чата = ' + SkypeChatList.Cells[1, Cnt] + ' | Кол. учасников = ' + SkypeChatList.Cells[2, Cnt], 4);
  end;}

  SkypeSearchID := SkypeChatList.Cols[0].IndexOf(pChat.Name);
  if SkypeSearchID <> -1 then // Нашли! SkypeSearchID - строка
  begin
    if SkypeChatList.Cells[2,SkypeSearchID] <> IntToStr(pMembers.Count) then
    begin
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Смена участников чата (До смены): ID чата = ' + SkypeChatList.Cells[0,SkypeSearchID] + ' | Имя чата = ' + SkypeChatList.Cells[1,SkypeSearchID] + ' | Количество участников = ' + SkypeChatList.Cells[2,SkypeSearchID], 4);
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Смена участников чата (После смены): ID чата = ' + pChat.Name + ' | Имя чата = ' + ChatName + ' | Количество участников = ' + IntToStr(pMembers.Count), 4);
      if EnableDebug then
      begin
        for pMembersCnt:=1 to pMembers.Count do
          WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура SkypeChatMembersChanged: Участник чата №' + IntToStr(pMembersCnt) +': ' + pMembers.Item[pMembersCnt].FullName + ' (' + pMembers.Item[pMembersCnt].Handle + ')', 4);
      end;
    end;
  end;
  //Log('Смена участников чата: Чат - ' + pChat.Name + ' | Количество участников: ' + IntToStr(pMembers.Count));
end;

{ Проверка на кратность номера записи в запросе }
function TMainSyncForm.CheckQueryRecNo(TotalRecNo, CurRecNo: Integer): Boolean;
begin
  if TotalRecNo < 1000 then
    Result := True
  else if (TotalRecNo >= 1000) and (TotalRecNo < 10000) then
  begin
    if Round(CurRecNo/100) = CurRecNo/100 then
      Result := True
    else
      Result := False;
  end
  else if (TotalRecNo >= 10000) and (TotalRecNo < 100000) then
  begin
    if Round(CurRecNo/1000) = CurRecNo/1000 then
      Result := True
    else
      Result := False;
  end
  else if (TotalRecNo >= 100000) and (TotalRecNo < 1000000) then
  begin
    if Round(CurRecNo/10000) = CurRecNo/10000 then
      Result := True
    else
      Result := False;
  end
  else
  begin
    if Round(CurRecNo/100000) = CurRecNo/100000 then
      Result := True
    else
      Result := False;
  end;
end;

{ Отлавливаем событие WM_MSGBOX для изменения прозрачности окна }
procedure TMainSyncForm.msgBoxShow(var Msg: TMessage);
var
  msgbHandle: HWND;
begin
  msgbHandle := GetActiveWindow;
  if msgbHandle <> 0 then
    MakeTransp(msgbHandle);
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TMainSyncForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Функция для мультиязыковой поддержки }
procedure TMainSyncForm.CoreLanguageChanged;
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
    SendMessage(LogFormHandle, WM_LANGUAGECHANGED, 0, 0);
    SendMessage(KeyPasswdFormHandle, WM_LANGUAGECHANGED, 0, 0);
    SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(ProgramsName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

{ Для мультиязыковой поддержки }
procedure TMainSyncForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType + ' (' + MyAccount + ')'
  else
    Caption := ProgramsName;
  HistoryToDBSyncTray.Hint := Caption;
  ShowSyncSettings;
  if HistoryToDbSyncPopupMenu.Items[0].Hint = 'HistoryToDBSyncPopupMenuShow' then
  begin
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuShow');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuShow';
  end
  else
  begin
    HistoryToDbSyncPopupMenu.Items[0].Caption := GetLangStr('HistoryToDBSyncPopupMenuHide');
    HistoryToDbSyncPopupMenu.Items[0].Hint := 'HistoryToDBSyncPopupMenuHide';
  end;
  HistoryToDbSyncPopupMenu.Items[2].Caption := GetLangStr('HistoryToDBSyncPopupMenuSync');
  HistoryToDbSyncPopupMenu.Items[3].Caption := GetLangStr('IMCaption');
  HistoryToDbSyncPopupMenu.Items[5].Caption := GetLangStr('CheckMD5Hash');
  HistoryToDbSyncPopupMenu.Items[6].Caption := GetLangStr('CheckAndDeleteMD5Hash');
  HistoryToDbSyncPopupMenu.Items[7].Caption := GetLangStr('UpdateContactListButton');
  HistoryToDbSyncPopupMenu.Items[8].Caption := GetLangStr('CheckUpdateButton');
  HistoryToDbSyncPopupMenu.Items[9].Caption := GetLangStr('HistoryToDBSyncShowLogFile');
  HistoryToDbSyncPopupMenu.Items[10].Caption := GetLangStr('SettingsButton');
  HistoryToDbSyncPopupMenu.Items[12].Caption := GetLangStr('HistoryToDBSyncPopupMenuShowAbout');
  HistoryToDbSyncPopupMenu.Items[13].Caption := GetLangStr('HistoryToDBSyncPopupMenuShowExit');
  SyncButton.Caption := GetLangStr('HistoryToDBSyncPopupMenuSync');
  if StartStopSyncButton.Hint = 'HistoryToDBSyncStop' then
  begin
    StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStop');
    StartStopSyncButton.Hint := 'HistoryToDBSyncStop';
  end
  else
  begin
    StartStopSyncButton.Caption := GetLangStr('HistoryToDBSyncStart');
    StartStopSyncButton.Hint := 'HistoryToDBSyncStart';
  end;
  LSkypeStatusDesc.Caption := GetLangStr('HistoryToDBSyncLSkypeStatusDesc');
  if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeOff' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeOff');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeOff';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeAttachPendingAuthorization' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachPendingAuthorization');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachPendingAuthorization';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeAttachSuccess' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachSuccess');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachSuccess';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeAttachRefused' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachRefused');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachRefused';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeAttachNotAvailable' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachNotAvailable');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachNotAvailable';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeAttachAvailable' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeAttachAvailable');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeAttachAvailable';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeErrCreate' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeErrCreate');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeErrCreate';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeErrDelete' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeErrDelete');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeErrDelete';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeRun' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeRun');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeRun';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeRunErr' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeRunErr');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeRunErr';
  end
  else if LSkypeStatus.Hint = 'HistoryToDBSyncSkypeInitErr' then
  begin
    LSkypeStatus.Caption := GetLangStr('HistoryToDBSyncSkypeInitErr');
    LSkypeStatus.Hint := 'HistoryToDBSyncSkypeInitErr';
  end;
  SyncGroupBox.Caption := GetLangStr('HistoryToDBSyncGroupBox');
  LSyncMethod.Caption := GetLangStr('LSyncMethod');
  LSyncInterval.Caption := GetLangStr('LSyncInterval');
  LSyncStatus.Caption := GetLangStr('HistoryToDBSyncStatus');
  LSyncStatusSet.Caption := GetLangStr(LSyncStatusSet.Hint);
  LTotalMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLTotalMesCountDesc');
  LMesCurrentCountDesc.Caption := GetLangStr('HistoryToDBSyncLMesCurrentCountDesc');
  LBadMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLBadMesCountDesc');
  LStartTimeDesc.Caption := GetLangStr('HistoryToDBSyncLStartTimeDesc');
  LEndTimeDesc.Caption := GetLangStr('HistoryToDBSyncLEndTimeDesc');
  LDublicateMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLDublicateMesCountDesc');
  //LogViewButton.Caption := GetLangStr('HistoryToDBSyncLogViewButton');
  LTotalHashMsgСountDesc.Caption := GetLangStr('HistoryToDBSyncLTotalHashMsgСountDesc');
  LTotalBrokenMD5HashСountDesc.Caption := GetLangStr('HistoryToDBSyncLTotalBrokenMD5HashСountDesc');
  LTotalChangeMD5HashСountDesc.Caption := GetLangStr('HistoryToDBSyncLTotalChangeMD5HashСountDesc');
  LMD5DublicateMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLMD5DublicateMesCountDesc');
  LDeletedMD5DublicateMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLDeletedMD5DublicateMesCountDesc');
  LEncryptMesCountDesc.Caption := GetLangStr('HistoryToDBSyncLEncryptMesCountDesc');
  // Позиционирование счетчиков
  LStartTime.Left := LStartTimeDesc.Left + LStartTimeDesc.Width + 5;
  LEndTime.Left := LEndTimeDesc.Left + LEndTimeDesc.Width + 5;
  // End
  ERR_READ_DB_CONNECT_ERR := GetLangStr('ERR_READ_DB_CONNECT_ERR');
  ERR_READ_DB_SERVICE_MODE := GetLangStr('ERR_READ_DB_SERVICE_MODE');
  ERR_LOAD_MSG_TO_DB := GetLangStr('ERR_LOAD_MSG_TO_DB');
  ERR_SEND_UPDATE := GetLangStr('ERR_SEND_UPDATE');
  ERR_NO_DB_CONNECTED := GetLangStr('ERR_NO_DB_CONNECTED');
  LOAD_TEMP_MSG := GetLangStr('LOAD_TEMP_MSG');
  LOAD_TEMP_MSG_SCREEN := GetLangStr('LOAD_TEMP_MSG_SCREEN');
  LOAD_TEMP_MSG_NOLOGFILE := GetLangStr('LOAD_TEMP_MSG_NOLOGFILE');
  LOAD_TEMP_MSG_NOMSGFILE := GetLangStr('LOAD_TEMP_MSG_NOMSGFILE');
end;

{ Получение сообщения из памяти }
procedure TMainSyncForm.ReadMappedText;
var
  ASize: Integer;
  Msg: PChar;
begin
  with FMap do
  begin
    Position := 0;
    ReadBuffer(@ASize,Sizeof(Integer));
    Inc(ASize);
    Msg := AllocMem(ASize);
    Msg[ASize] := #0;
    Dec(ASize);
    try
      ReadBuffer(Msg, ASize);
      WriteInLog(ProfilePath, DecryptStr(Msg), 0);
    finally
      ReAllocMem(Msg, 0);
    end;
  end;
end;

end.

