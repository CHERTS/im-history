{ ############################################################################ }
{ #                                                                          # }
{ #  HistoryToDBSync v2.5                                                    # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit KeyPasswd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, Global, StdCtrls, IniFiles;

type
  TKeyPasswdForm = class(TForm)
    GBPasswd: TGroupBox;
    LKeyNumTitle: TLabel;
    LKeyNum: TLabel;
    LKeyPasswdTitle: TLabel;
    EKeyPasswd: TEdit;
    CBSaveOnly: TCheckBox;
    CBSave: TCheckBox;
    ButtonGo: TButton;
    ButtonExit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonGoClick(Sender: TObject);
    procedure EKeyPasswdKeyPress(Sender: TObject; var Key: Char);
    procedure CBSaveClick(Sender: TObject);
  private
    { Private declarations }
    SessionEnding: Boolean;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
    DBKeyID: Integer;
  end;

var
  KeyPasswdForm: TKeyPasswdForm;

implementation

{$R *.dfm}

procedure TKeyPasswdForm.WMQueryEndSession(var Message: TMessage);
begin
  SessionEnding := True;
  Message.Result := 1;
end;

procedure TKeyPasswdForm.FormCreate(Sender: TObject);
begin
  // Для мультиязыковой поддержки
  KeyPasswdFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Загружаем язык интерфейса
  LoadLanguageStrings;
end;

procedure TKeyPasswdForm.FormShow(Sender: TObject);
var
  KeyCnt: Integer;
begin
  // Переменная для режима анти-босс
  Global_KeyPasswdForm_Showing := True;
  CBSaveOnly.Checked := KeyPasswdSaveOnlySession;
  CBSave.Checked := KeyPasswdSave;
  // Прозрачность окна
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
  // Отключаем ненужное
  EKeyPasswd.Text := '';
  ButtonGo.Enabled := False;
  CBSaveOnly.Enabled := False;
  CBSave.Enabled := False;
  EKeyPasswd.Enabled := False;
  // Получаем номер активного ключа из БД
  // Подключаемся к базе
  MainSyncForm.ConnectDB;
  if MainSyncForm.ZConnection1.Connected then
  begin
    if not MainSyncForm.CheckServiceMode then
    begin
      MainSyncForm.SQL_Zeos_Key('select count(*) as cnt from key_'+ DBUserName + ' where status_key = 1');
      KeyCnt := MainSyncForm.KeyQuery.FieldByName('cnt').AsInteger;
      if KeyCnt = 1 then
      begin
        ButtonGo.Enabled := True;
        CBSave.Enabled := True;
        EKeyPasswd.Enabled := True;
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
        MainSyncForm.SQL_Zeos_Key('select id from key_'+ DBUserName + ' where status_key = 1');
        DBKeyID := MainSyncForm.KeyQuery.FieldByName('id').AsInteger;
        LKeyNum.Caption := IntToStr(DBKeyID);
        EKeyPasswd.SetFocus;
      end
      else if KeyCnt > 1 then
        LKeyNum.Caption := GetLangStr('HistoryToDBSyncMultiActiveKey')
      else
        LKeyNum.Caption := GetLangStr('HistoryToDBSyncErrActiveKey');
    end;
  end;
  if (not CheckMD5HashStartedEnabled) and (not SyncHistoryStartedEnabled) and (not UpdateContactListStartedEnabled) then
    MainSyncForm.ZConnection1.Disconnect;
  SessionEnding := False;
end;

procedure TKeyPasswdForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Переменная для режима анти-босс
  Global_KeyPasswdForm_Showing := False;
  // Если закрываем окно крестиком
  if SessionEnding then
    EncryptionKey := '';
end;

procedure TKeyPasswdForm.ButtonGoClick(Sender: TObject);
var
  INI: TIniFile;
  Path: String;
  Status: Integer;
  TempEncryptionKey, TempEncryptionKeyID: String;
begin
  Status := MainSyncForm.GetEncryptionKey(EKeyPasswd.Text, TempEncryptionKey, TempEncryptionKeyID);
  if Status = 1 then // Ошибка - Неверный пароль ключа
    MsgInf(ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncErrKeyPassword'))
  else if Status = 2 then // Пароль верный, ключ получен
  begin
    EncryptionKeyID := TempEncryptionKeyID;
    EncryptionKey := TempEncryptionKey;
  end
  else if Status = 3 then // Ошибка расшифровки
    MsgInf(ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncErrDecryptKey'))
  else if Status = 4 then // Ошибка - Найдено более 1 акт. ключа
    MsgInf(ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncMultiActiveKey'))
  else if Status = 5 then // Ошибка - Не найдено акт. ключей
    MsgInf(ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncErrActiveKey'))
  else // Ошибка - Нет доступа к БД
    MsgInf(ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('ErrDBConnect'));
  if Status = 2 then
  begin
    KeyPasswdSaveOnlySession := CBSaveOnly.Checked;
    KeyPasswdSave := CBSave.Checked;
    // Сохраняем настройки
    Path := ProfilePath + ININame;
    if FileExists(Path) then
    begin
      INI := TIniFile.Create(Path);
      try
        INI.WriteString('Main', 'KeyPasswdSaveOnlySession', BoolToIntStr(KeyPasswdSaveOnlySession));
        INI.WriteString('Main', 'KeyPasswdSave', BoolToIntStr(KeyPasswdSave));
        if KeyPasswdSave then
          INI.WriteString('Main', 'KeyPasswd'+EncryptionKeyID, EncryptStr(EKeyPasswd.Text))
        else
          INI.WriteString('Main', 'KeyPasswd'+EncryptionKeyID, 'NoSave');
      finally
        INI.Free;
      end;
    end
    else
      MsgDie(ProgramsName, GetLangStr('SettingsErrSave'));
    SessionEnding := False;
    Close;
  end;
end;

procedure TKeyPasswdForm.CBSaveClick(Sender: TObject);
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
  KeyPasswdSaveOnlySession := CBSaveOnly.Checked;
  KeyPasswdSave := CBSave.Checked;
end;

procedure TKeyPasswdForm.EKeyPasswdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ButtonGoClick(Self);
end;

procedure TKeyPasswdForm.ButtonExitClick(Sender: TObject);
begin
  EncryptionKey := '';
  SessionEnding := False;
  Close;
end;

{ Отлавливаем событие WM_MSGBOX для изменения прозрачности окна }
procedure TKeyPasswdForm.msgBoxShow(var Msg: TMessage);
var
  msgbHandle: HWND;
begin
  msgbHandle := GetActiveWindow;
  if msgbHandle <> 0 then
    MakeTransp(msgbHandle);
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TKeyPasswdForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Для мультиязыковой поддержки }
procedure TKeyPasswdForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswdCaption')
  else
    Caption := ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswdCaption');
  GBPasswd.Caption := GetLangStr('HistoryToDBSyncGBPasswd');
  LKeyNumTitle.Caption := GetLangStr('HistoryToDBSyncLKeyNumTitle');
  LKeyPasswdTitle.Caption := GetLangStr('HistoryToDBSyncLKeyPasswdTitle');
  ButtonGo.Caption := GetLangStr('HistoryToDBSyncButtonGo');
  ButtonExit.Caption := GetLangStr('HistoryToDBSyncButtonExit');
  CBSaveOnly.Caption := GetLangStr('HistoryToDBSyncCBSaveOnly');
  CBSave.Caption := GetLangStr('HistoryToDBSyncCBSave');
end;

end.
