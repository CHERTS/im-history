unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XMLIntf, XMLDoc, Global, IniFiles, uIMDownloader;

type
  TMainForm = class(TForm)
    GBUpdater: TGroupBox;
    ProgressBarDownloads: TProgressBar;
    LAmountDesc: TLabel;
    LAmount: TLabel;
    LSpeedDesc: TLabel;
    LSpeed: TLabel;
    ButtonSettings: TButton;
    ButtonUpdate: TButton;
    SettingsPageControl: TPageControl;
    TabSheetConnectSettings: TTabSheet;
    TabSheetLog: TTabSheet;
    GBConnectSettings: TGroupBox;
    LProxyAddress: TLabel;
    LProxyPort: TLabel;
    LProxyUser: TLabel;
    LProxyUserPasswd: TLabel;
    CBUseProxy: TCheckBox;
    EProxyAddress: TEdit;
    EProxyPort: TEdit;
    EProxyUser: TEdit;
    CBProxyAuth: TCheckBox;
    EProxyUserPasswd: TEdit;
    LogMemo: TMemo;
    LFileDesc: TLabel;
    LFileDescription: TLabel;
    LFileMD5Desc: TLabel;
    LFileMD5: TLabel;
    LFileNameDesc: TLabel;
    LFileName: TLabel;
    IMDownloader1: TIMDownloader;
    LStatus: TLabel;
    TabSheetSettings: TTabSheet;
    GBSettings: TGroupBox;
    LLanguage: TLabel;
    CBLang: TComboBox;
    LIMClientType: TLabel;
    CBIMClientType: TComboBox;
    LDBType: TLabel;
    CBDBType: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure ButtonUpdateStartClick(Sender: TObject);
    procedure ButtonUpdateStopClick(Sender: TObject);
    procedure CBUseProxyClick(Sender: TObject);
    procedure CBProxyAuthClick(Sender: TObject);
    procedure IMDownloader1StartDownload(Sender: TObject);
    procedure IMDownloader1Break(Sender: TObject);
    procedure IMDownloader1Downloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
    procedure IMDownloader1Error(Sender: TObject; E: TIMDownloadError);
    procedure IMDownloader1Accepted(Sender: TObject);
    procedure IMDownloader1Headers(Sender: TObject; Headers: String);
    function  StartStepByStepUpdate(CurrStep: Integer; INIFileName: String): Integer;
    procedure ButtonUpdateEnableStart;
    procedure ButtonUpdateEnableStop;
    procedure FindLangFile;
    procedure CoreLanguageChanged;
    procedure CBLangChange(Sender: TObject);
    procedure CBIMClientTypeChange(Sender: TObject);
    procedure CBDBTypeChange(Sender: TObject);
    procedure IMDownloader1MD5Checked(Sender: TObject; MD5Correct,
      SizeCorrect: Boolean; MD5Str: string);
  private
    { Private declarations }
    FLanguage : WideString;
    // Для мультиязыковой поддержки
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
    RunAppDone: Boolean;
    C1, C2: TLargeInteger;
    iCounterPerSec: TLargeInteger;
    TrueHeader: Boolean;
    CurrentUpdateStep: Integer;
    HeaderMD5: String;
    HeaderFileSize: Integer;
    HeaderFileName: String;
    MD5InMemory: String;
    IMMD5Correct: Boolean;
    IMSizeCorrect: Boolean;
    INISavePath: String;
    procedure SetProxySettings;
    property CoreLanguage: WideString read FLanguage;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  CmdHelpStr: WideString;
begin
  RunAppDone := False;
  TrueHeader := False;
  IMMD5Correct := False;
  IMSizeCorrect := False;
  CurrentUpdateStep := 0;
  // Подсказка по параметрам запуска
  if GetSysLang = 'Русский' then
  begin
    CmdHelpStr := 'Параметры запуска ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '--------------------------------------------------------------' + #13#13 +
    'HistoryToDBUpdater.exe <1>' + #13#13 +
    '<1> - (Необязательный параметр) - Путь до файла настроек HistoryToDB.ini (Например: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")';
  end
  else
  begin
    CmdHelpStr := 'Startup options ' + ProgramsName + ' v' + ProgramsVer + ':' + #13 +
    '------------------------------------------------' + #13#13 +
    'HistoryToDBUpdater.exe <1>' + #13#13 +
    '<1> - (Optional) - The path to the configuration file HistoryToDB.ini (Example: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")';
  end;
  // Проверка входных параметров
  if (ParamStr(1) = '/?') or (ParamStr(1) = '-?') then
  begin
    MsgInf(ProgramsName, CmdHelpStr);
    Exit;
  end
  else
  begin
    if ParamCount >= 1 then
    begin
      ProfilePath := ParamStr(1);
    end
    else
    begin
      ProfilePath := ExtractFilePath(Application.ExeName);
    end;
    PluginPath := ExtractFilePath(Application.ExeName);
    INISavePath := ExtractFilePath(Application.ExeName)+'HistoryToDBUpdate.ini';
    // Инициализация криптования
    EncryptInit;
    // Читаем настройки
    LoadINI(ProfilePath, false);
    // Загружаем настройки локализации
    FLanguage := DefaultLanguage;
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
      EncryptFree;
      Exit;
    end;
    CoreLanguageChanged;
    // Заполняем список языков
    FindLangFile;
    // Для мультиязыковой поддержки
    MainFormHandle := Handle;
    SetWindowLong(Handle, GWL_HWNDPARENT, 0);
    SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
    // Загружаем язык интерфейса
    LoadLanguageStrings;
    // Программа запущена
    RunAppDone := True;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if RunAppDone then
  begin
    // Освобождаем ресурсы
    EncryptFree;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  // Переменная для режима анти-босс
  Global_MainForm_Showing := True;
  // Прозрачность окна
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
  // Др. настройки
  LAmount.Caption := '0 Кбайт';
  LFileName.Caption := 'Не известно';
  LFileDescription.Caption := 'Не известно';
  LFileMD5.Caption := 'Не известно';
  LSpeed.Caption := '0 Кбайт/сек';
  CBUseProxy.Checked := False;
  EProxyAddress.Enabled := False;
  EProxyPort.Enabled := False;
  CBProxyAuth.Enabled := False;
  SettingsPageControl.ActivePage := TabSheetSettings;
  SettingsPageControl.Visible := False;
  MainForm.Height := SettingsPageControl.Height + 5;
  if DBType = 'Unknown' then
  begin
    CBDBType.Enabled := True;
    CBDBType.Items.Add('Unknown');
    CBDBType.Items.Add('mysql');
    CBDBType.Items.Add('postgresql');
    CBDBType.Items.Add('oracle');
    CBDBType.Items.Add('sqlite-3');
    CBDBType.Items.Add('firebird-2.5');
    CBDBType.Items.Add('firebird-2.0');
    CBDBType.ItemIndex := 0;
    // Показываем настройки
    ButtonSettingsClick(Self);
  end
  else
  begin
    CBDBType.Enabled := False;
    CBDBType.Items.Add(DBType);
    CBDBType.ItemIndex := 0;
  end;
  if IMClientType = 'Unknown' then
  begin
    CBIMClientType.Enabled := True;
    CBIMClientType.Items.Add('Unknown');
    CBIMClientType.Items.Add('QIP');
    CBIMClientType.Items.Add('RnQ');
    CBIMClientType.Items.Add('Skype');
    CBIMClientType.Items.Add('Miranda');
    CBIMClientType.ItemIndex := 0;
    // Показываем настройки если не были показыны ранее
    if not SettingsPageControl.Visible then
      ButtonSettingsClick(Self);
  end
  else
  begin
    CBIMClientType.Enabled := False;
    CBIMClientType.Items.Add(IMClientType);
    CBIMClientType.ItemIndex := 0;
  end;
end;

procedure TMainForm.ButtonSettingsClick(Sender: TObject);
begin
  if not SettingsPageControl.Visible then
  begin
    MainForm.Height := GBUpdater.Height + SettingsPageControl.Height + 55;
    SettingsPageControl.Visible := True;
  end
  else
  begin
    SettingsPageControl.Visible := False;
    MainForm.Height := SettingsPageControl.Height + 5;
  end;
end;

procedure TMainForm.ButtonUpdateStartClick(Sender: TObject);
begin
  if (DBType = 'Unknown') or (IMClientType  = 'Unknown') then
    MsgInf(Caption, GetLangStr('SelectDBTypeAndIMClient'))
  else
  begin
    LogMemo.Clear;
    TrueHeader := False;
    CurrentUpdateStep := 0;
    SetProxySettings;
    IMDownloader1.URL := uURL;
    IMDownloader1.DownLoad;
  end;
  // Имя_файла|Описани_файла|MD5Sum_файла|Размер_файла
  {FileInfo := GetFileInfo(URL);
  FileName := Tok('|', FileInfo);
  FileDesc := Tok('|', FileInfo);
  FileMD5Sum := Tok('|', FileInfo);
  LFileName.Caption := FileName;
  LFileDescription.Caption := FileDesc;
  LFileMD5.Caption := FileMD5Sum;}
end;

{ Устанавливаем настройки прокси }
procedure TMainForm.SetProxySettings;
begin
  if CBUseProxy.Checked then
  begin
    IMDownloader1.Proxy := EProxyAddress.Text + ':' + EProxyPort.Text;
    if CBProxyAuth.Checked then
    begin
      IMDownloader1.AuthUserName := EProxyUser.Text;
      IMDownloader1.AuthPassword := EProxyUserPasswd.Text;
    end
    else
    begin
      IMDownloader1.AuthUserName := '';
      IMDownloader1.AuthPassword := '';
    end;
  end
  else
  begin
    IMDownloader1.Proxy := '';
    IMDownloader1.AuthUserName := '';
    IMDownloader1.AuthPassword := '';
  end;
end;

procedure TMainForm.IMDownloader1Accepted(Sender: TObject);
var
  SavePath: String;
  MaxSteps: Integer;
begin
  LStatus.Caption := 'Скачивание успешно завершено.';
  LStatus.Repaint;
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' Кбайт';
  LAmount.Repaint;
  if not TrueHeader then
  begin
    LFileName.Caption := 'Не известно';
    LFileDescription.Caption := 'Не известно';
    LFileMD5.Caption := 'Не известно';
    LStatus.Caption := 'Неправильный заголовок ответа с сервера.';
  end
  else
  begin
    LStatus.Caption := 'Подсчет контрольной суммы файла...';
    LStatus.Repaint;
    LogMemo.Lines.Add('MD5 файла в памяти: ' + MD5InMemory);
    LogMemo.Lines.Add('Размер файла в памяти: ' + IntToStr(IMDownloader1.OutStream.Size));
    if IMMD5Correct and IMSizeCorrect then
    begin
      LStatus.Caption := 'Контрольная сумма и размер файла подтверждены.';
      LStatus.Repaint;
      LogMemo.Lines.Add('Контрольная сумма и размер файла подтверждены.');
      // Если первый шаг - скачивание INI файла
      if CurrentUpdateStep = 0 then
      begin
        SavePath := ExtractFilePath(Application.ExeName);
        INISavePath := ExtractFilePath(Application.ExeName)+HeaderFileName;
      end
      else
        SavePath := ExtractFilePath(Application.ExeName)+'temp\';
      // Проверяем каталог для сохранения
      if not DirectoryExists(SavePath) then
        CreateDir(SavePath);
      // Удаляем старый файл
      if FileExists(SavePath + HeaderFileName) then
        DeleteFile(SavePath + HeaderFileName);
      // Сохряняем новый
      try
        IMDownloader1.OutStream.SaveToFile(SavePath + HeaderFileName);
        LStatus.Caption := 'Файл сохранен под именем ' + HeaderFileName;
        LStatus.Repaint;
        LogMemo.Lines.Add('Файл сохранен под именем ' + HeaderFileName);
        Inc(CurrentUpdateStep);
        if CurrentUpdateStep > 0 then
          MaxSteps := StartStepByStepUpdate(CurrentUpdateStep, INISavePath);
      except
        on E: Exception do
        begin
          LStatus.Caption := 'Ошибка сохранения файла ' + HeaderFileName;
          LStatus.Repaint;
          LogMemo.Lines.Add('Ошибка сохранения файла ' + HeaderFileName);
        end;
      end;
    end
    else
    begin
      LStatus.Caption := 'Не сходится контр. сумма или размер принятых данных.';
      LStatus.Repaint;
      LogMemo.Lines.Add('Не сходится контр. сумма или размер принятых данных.');
      ButtonUpdateEnableStart;
    end;
  end;
end;

function TMainForm.StartStepByStepUpdate(CurrStep: Integer; INIFileName: String): Integer;
var
  UpdateINI: TIniFile;
  MaxStep: Integer;
  UpdateURL: String;
begin
  if FileExists(INIFileName) then
  begin
    UpdateINI := TIniFile.Create(INIFileName);
    MaxStep := UpdateINI.ReadInteger('HistoryToDBUpdate', 'FileCount', 0);
    if CurrentUpdateStep > MaxStep then
    begin
      LStatus.Caption := 'Все обновления успешно загружены.';
      LStatus.Repaint;
      LogMemo.Lines.Add('=========================================');
      LogMemo.Lines.Add('Все обновления успешно загружены.');
      ButtonUpdateEnableStart;
      Exit;
    end;
    LogMemo.Lines.Add('================= Шаг '+IntToStr(CurrStep)+' =================');
    LogMemo.Lines.Add('Число файлов для обновления = ' + IntToStr(MaxStep));
    if MaxStep > 0 then
    begin
      UpdateURL := UpdateINI.ReadString('HistoryToDBUpdate', 'File'+IntToStr(CurrStep), '');
      if (UpdateURL <> '') and (CurrStep <= MaxStep) then
      begin
        LogMemo.Lines.Add('Очередной файл для обновления = ' + UpdateURL);
        IMDownloader1.URL := UpdateURL;
        IMDownloader1.DownLoad;
      end
      else
        CurrentUpdateStep := 0;
    end;
  end
  else
    LogMemo.Lines.Add('Не найден файл настроек обновления ' + INIFileName);
end;

procedure TMainForm.IMDownloader1Break(Sender: TObject);
begin
  LStatus.Caption := 'Скачивание остановлено.';
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' Кбайт';
  LAmount.Repaint;
  ButtonUpdateEnableStart;
end;

procedure TMainForm.IMDownloader1Downloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
begin
  QueryPerformanceCounter(C2);
  ProgressBarDownloads.Max := MaxSize;
  ProgressBarDownloads.Position := AcceptedSize;
  LStatus.Caption := 'Идет загрузка...';
  LAmount.Caption := CurrToStr(AcceptedSize/1024)+' Кбайт';
  LAmount.Repaint;
  LSpeed.Caption := CurrToStr((AcceptedSize/1024)/((C2 - C1) / iCounterPerSec))+' Кбайт/сек';
  LSpeed.Repaint;
end;

procedure TMainForm.IMDownloader1Error(Sender: TObject; E: TIMDownloadError);
var
  S: String;
begin
  case E of
    deInternetOpen: S := 'Ошибка при открытии сессии.';
    deInternetOpenUrl: S := 'Ошибка при запрашивании файла.';
    deDownloadingFile: S := 'Ошибка при чтении файла.';
    deRequest: S := 'Ошибка при запросе данных через прокси-сервер.';
  end;
  LStatus.Caption := S;
  LogMemo.Lines.Add(S);
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' Кбайт';
  LAmount.Repaint;
  if not TrueHeader then
  begin
    LFileName.Caption := 'Не известно';
    LFileDescription.Caption := 'Не известно';
    LFileMD5.Caption := 'Не известно';
  end;
  ButtonUpdateEnableStart;
end;

{ Получение информации о файле
  Формат инормации:
  Имя_файла|Описани_файла|MD5Sum_файла|Размер_файла
}
procedure TMainForm.IMDownloader1Headers(Sender: TObject; Headers: string);
var
  HeadersStrList: TStringList;
  I: Integer;
  Size: String;
  Ch: Char;
  ResultFilename, ResultFileDesc, ResultMD5Sum, ResultHeaders: String;
  ResultFileSize: Integer;
begin
  //LogMemo.Lines.Add(Headers);
  HeadersStrList := TStringList.Create;
  HeadersStrList.Clear;
  HeadersStrList.Text := Headers;
  HeadersStrList.Delete(HeadersStrList.Count-1); // Последний элемент содержит всегда CRLF
  if HeadersStrList.Count > 0 then
  begin
    ResultFilename := 'Test';
    ResultFileDesc := 'Test';
    ResultMD5Sum := '00000000000000000000000000000000';
    ResultFileSize := 0;
    LogMemo.Lines.Add('Парсим заголовок...');
    for I := 0 to HeadersStrList.Count - 1 do
    begin
      //LogMemo.Lines.Add(HeadersStrList[I]);
      // Парсим строку вида
      // Content-Disposition: attachment; filename="ИМЯ-ФАЙЛА"
      // Такую строку вставляет в заголовок HTTP-запроса
      // только мой скрипт get.php
      if pos('content-disposition', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultFilename := HeadersStrList[I];
        Delete(ResultFilename, 1, Pos('"', HeadersStrList[I]));
        Delete(ResultFilename, Length(ResultFilename),1);
        //LogMemo.Lines.Add('Filename: '+ResultFilename);
      end;
      // Парсим строку вида
      // Content-Description: Desc
      if pos('content-description', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultFileDesc := HeadersStrList[I];
        Delete(ResultFileDesc, 1, Pos(':', HeadersStrList[I]));
        Delete(ResultFileDesc, 1,1);
        //LogMemo.Lines.Add('Description: '+ResultFileDesc);
      end;
      // Парсим строку вида
      // Content-MD5Sum: MD5
      if pos('content-md5sum', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultMD5Sum := HeadersStrList[I];
        Delete(ResultMD5Sum, 1, Pos(':', HeadersStrList[I]));
        Delete(ResultMD5Sum, 1,1);
        //LogMemo.Lines.Add('MD5: '+ResultMD5Sum);
      end;
      // Парсим строку вида
      // Content-Length: РАЗМЕР
      if pos('content-length', lowercase(HeadersStrList[i])) > 0 then
      begin
        Size := '';
        for Ch in HeadersStrList[I]do
          if Ch in ['0'..'9'] then
            Size := Size + Ch;
        ResultFileSize := StrToIntDef(Size,-1);// + Length(HeadersStrList.Text);
      end;
    end;
    ResultHeaders := ResultFilename + '|' + ResultFileDesc + '|' + ResultMD5Sum + '|' + IntToStr(ResultFileSize) + '|';
    if(ResultHeaders <> 'Test|Test|00000000000000000000000000000000|' + IntToStr(ResultFileSize) + '|') then
    begin
      LogMemo.Lines.Add('Данные заголовка:');
      LogMemo.Lines.Add('Скачиваем файл = ' + ResultFilename);
      LogMemo.Lines.Add('Описание файла = ' + ResultFileDesc);
      LogMemo.Lines.Add('MD5 файла = ' + ResultMD5Sum);
      LogMemo.Lines.Add('Размер файла = ' + IntToStr(ResultFileSize));
      LFileName.Caption := ResultFilename;
      LFileDescription.Caption := ResultFileDesc;
      LFileMD5.Caption := ResultMD5Sum;
      HeaderFileName := ResultFilename;
      HeaderMD5 := ResultMD5Sum;
      HeaderFileSize := ResultFileSize;
      TrueHeader := True;
    end
    else
    begin
      LogMemo.Lines.Add('Неправильный заголовок ответа с сервера.');
      HeaderFileName := 'Test';
      HeaderMD5 := '00000000000000000000000000000000';
      HeaderFileSize := 0;
      TrueHeader := False;
    end;
  end;
  HeadersStrList.Free;
end;

procedure TMainForm.IMDownloader1MD5Checked(Sender: TObject; MD5Correct,
  SizeCorrect: Boolean; MD5Str: string);
begin
  MD5InMemory := MD5Str;
  IMMD5Correct := MD5Correct;
  IMSizeCorrect := SizeCorrect;
end;

procedure TMainForm.IMDownloader1StartDownload(Sender: TObject);
begin
  QueryPerformanceFrequency(iCounterPerSec);
  QueryPerformanceCounter(C1);
  ButtonUpdateEnableStop;
  LStatus.Caption := 'Инициализация скачивания...';
  LAmount.Caption := '0 Кбайт';
  LSpeed.Caption := '0 Кбайт/сек';
  LogMemo.Lines.Add('Инициализация скачивания c URL ' + IMDownloader1.URL);
end;

procedure TMainForm.ButtonUpdateStopClick(Sender: TObject);
begin
  IMDownloader1.BreakDownload;
end;

procedure TMainForm.CBUseProxyClick(Sender: TObject);
begin
  if CBUseProxy.Checked then
  begin
    EProxyAddress.Enabled := True;
    EProxyPort.Enabled := True;
    CBProxyAuth.Enabled := True;
  end
  else
  begin
    EProxyAddress.Enabled := False;
    EProxyPort.Enabled := False;
    CBProxyAuth.Enabled := False;
  end;
end;

procedure TMainForm.CBProxyAuthClick(Sender: TObject);
begin
  if CBProxyAuth.Checked then
  begin
    EProxyUser.Enabled := True;
    EProxyUserPasswd.Enabled := True;
  end
  else
  begin
    EProxyUser.Enabled := False;
    EProxyUserPasswd.Enabled := False;
  end;
end;

procedure TMainForm.ButtonUpdateEnableStart;
begin
  ButtonUpdate.OnClick := ButtonUpdateStartClick;
  ButtonUpdate.Caption := 'Обновить';
  ButtonSettings.Enabled := True;
end;

procedure TMainForm.ButtonUpdateEnableStop;
begin
  ButtonUpdate.OnClick := ButtonUpdateStopClick;
  ButtonUpdate.Caption := 'Остановить';
  ButtonSettings.Enabled := False;
end;

procedure TMainForm.CBDBTypeChange(Sender: TObject);
begin
  DBType := CBDBType.Items[CBDBType.ItemIndex];
end;

procedure TMainForm.CBIMClientTypeChange(Sender: TObject);
begin
  IMClientType := CBIMClientType.Items[CBIMClientType.ItemIndex];
end;

{ Смена языка }
procedure TMainForm.CBLangChange(Sender: TObject);
begin
  FLanguage := CBLang.Items[CBLang.ItemIndex];
  DefaultLanguage := CBLang.Items[CBLang.ItemIndex];
  CoreLanguageChanged;
end;

{ Процедура поиска языковых файлов и заполнения списка }
procedure TMainForm.FindLangFile;
var
  SR: TSearchRec;
  I: Integer;
begin
  CBLang.Items.Clear;
  if FindFirst(PluginPath + dirLangs + '\*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // Чтобы не было файлов . и ..
      begin
        Continue; // Продолжаем цикл
      end;
      if MatchStrings(SR.Name, '*.xml') then
      begin
        // Заполняем лист
        CBLang.Items.Add(ExtractFileNameEx(SR.Name, False));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  for I := 0 to CBLang.Items.Count-1 do
  begin
    if CBLang.Items[I] = CoreLanguage then
      CBLang.ItemIndex := I;
  end;
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TMainForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Функция для мультиязыковой поддержки }
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
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType
  else
    Caption := ProgramsName;
  ButtonUpdate.Caption := GetLangStr('HistoryToDBSyncLogFormReloadLogButton');
  ButtonSettings.Caption := GetLangStr('SettingsButton');
  LDBType.Caption := GetLangStr('LDBType');
  LLanguage.Caption := GetLangStr('Language');
  TabSheetSettings.Caption := GetLangStr('GeneralSettings');
  TabSheetConnectSettings.Caption := GetLangStr('ConnectionSettings');
  TabSheetLog.Caption := GetLangStr('Logs');
  GBSettings.Caption := GetLangStr('GeneralSettings');
end;

end.
