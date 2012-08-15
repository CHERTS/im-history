{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBViewer v2.4                                 # }
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
  Dialogs, Main, Global, StdCtrls, IniFiles,
  DCPcrypt2, DCPblockciphers, DCPdes, DCPsha1, DCPbase64;

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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure msgBoxShow(var Msg: TMessage); message WM_MSGBOX;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
    DBKeyID: Integer;
  end;

var
  KeyPasswdForm: TKeyPasswdForm;

implementation

{$R *.dfm}

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
  // Отключаем ненужное
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
  EKeyPasswd.Text := '';
  ButtonGo.Enabled := True;
  CBSave.Enabled := True;
  EKeyPasswd.Enabled := True;
  LKeyNum.Caption := EncryptionKeyID;
  EKeyPasswd.SetFocus;
  // Прозрачность окна
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
end;

procedure TKeyPasswdForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Переменная для режима анти-босс
  Global_KeyPasswdForm_Showing := False;
end;

procedure TKeyPasswdForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ButtonExitClick(ButtonExit);
end;

procedure TKeyPasswdForm.ButtonGoClick(Sender: TObject);
var
  INI: TIniFile;
  Path: String;
  Status, pCnt, I: Integer;
  TempEncryptionKey: String;
  MyKeyPassword: pMyKeyPassword;
begin
  Status := MainForm.GetEncryptionKey(EKeyPasswd.Text, TempEncryptionKey, EncryptionKeyID);
  if Status = 1 then // Ошибка - Неверный пароль ключа
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('ErrKeyPassword'))
  else if Status = 2 then // Пароль верный, ключ получен
  begin
    EncryptionKey := TempEncryptionKey;
  end
  else if Status = 3 then // Ошибка расшифровки
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncErrDecryptKey'))
  else if Status = 4 then // Ошибка - Не найдено нужного ключа
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('HistoryToDBSyncNoKey'))
  else // Ошибка - Нет доступа к БД
    MsgInf(MainForm.Caption + ' - ' + GetLangStr('HistoryToDBSyncKeyPasswordCaption'), GetLangStr('ErrDBConnect'));
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
        // Только для сохраняемых ключей на 1 сессию
        if KeyPasswdSaveOnlySession or KeyPasswdSave then
        begin
          // Проверяем наличие такого пароля и ключа в структуре
          if MyKeyPasswordPointer.Count > 0 then
          begin
            for I := 0 to MyKeyPasswordPointer.Count-1 do
            begin
              //ShowMessage('Размер MyKeyPasswordPointer до: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount));
              // Такого ключа у нас нет, создаем структуру и пишем туда данные
              if EncryptionKeyID <> IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID) then
              begin
                // Заполняем массив в структуре для нового пароля и ключа шифрования
                pCnt := MyKeyPasswordPointer.Count;
                MyKeyPasswordPointer.Count := pCnt+1;
                SetLength(MyKeyPasswordPointer.PasswordArray, MyKeyPasswordPointer.Count);
                MyKeyPasswordPointer.PasswordArray[pCnt].KeyID := StrToInt(EncryptionKeyID);
                MyKeyPasswordPointer.PasswordArray[pCnt].KeyPassword := EncryptStr(EKeyPasswd.Text);
                MyKeyPasswordPointer.PasswordArray[pCnt].EncryptionKey := EncryptStr(EncryptionKey);
                if KeyPasswdSave then
                  INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[pCnt].KeyID), MyKeyPasswordPointer.PasswordArray[pCnt].KeyPassword)
                else
                  INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[pCnt].KeyID), 'NoSave');
              end;
              {ShowMessage('Размер MyKeyPasswordPointer: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount) + #13#10 +
              'ID: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordPointerID[I].KeyID) + #13#10 +
              'Passwd: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[I].KeyPassword + #13#10 +
              'Key: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[I].EncryptionKey);}
              if KeyPasswdSave then
                INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID), MyKeyPasswordPointer.PasswordArray[I].KeyPassword)
              else
                INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[I].KeyID), 'NoSave');
            end;
          end
          else
          begin
            //ShowMessage('Размер MyKeyPasswordPointer до: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount));
            // Заполняем массив в структуре для нового пароля и ключа шифрования
            MyKeyPasswordPointer.Count := 1;
            SetLength(MyKeyPasswordPointer.PasswordArray, MyKeyPasswordPointer.Count);
            MyKeyPasswordPointer.PasswordArray[0].KeyID := StrToInt(EncryptionKeyID);
            MyKeyPasswordPointer.PasswordArray[0].KeyPassword := EncryptStr(EKeyPasswd.Text);
            MyKeyPasswordPointer.PasswordArray[0].EncryptionKey := EncryptStr(EncryptionKey);
            if KeyPasswdSave then
              INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[0].KeyID), MyKeyPasswordPointer.PasswordArray[0].KeyPassword)
            else
              INI.WriteString('Main', 'KeyPasswd'+IntToStr(MyKeyPasswordPointer.PasswordArray[0].KeyID), 'NoSave');
            {ShowMessage('Размер MyKeyPasswordPointer после: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordCount) + #13#10 +
            'ID: ' + IntToStr(MyKeyPasswordPointer.MyKeyPasswordPointerID[0].KeyID) + #13#10 +
            'Passwd: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[0].KeyPassword + #13#10 +
            'Key: ' + MyKeyPasswordPointer.MyKeyPasswordPointerID[0].EncryptionKey);}
          end;
        end;
      finally
        INI.Free;
      end;
    end
    else
      MsgDie(MainForm.Caption, GetLangStr('SettingsErrSave'));
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
end;

procedure TKeyPasswdForm.EKeyPasswdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ButtonGoClick(Self);
end;

procedure TKeyPasswdForm.ButtonExitClick(Sender: TObject);
begin
  EncryptionKey := '';
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
