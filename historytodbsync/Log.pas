{ ############################################################################ }
{ #                                                                          # }
{ #  Импорт истории HistoryToDBSync v2.4                                     # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global, JvAppStorage, JvAppIniStorage, JvComponentBase,
  JvFormPlacement, JvThread, JvExControls, JvAnimatedImage, JvGIFCtrl, ExtCtrls,
  ComCtrls, CommCtrl, JvExStdCtrls, JclFileUtils, Menus, ClipBrd;

type
  TLogForm = class(TForm)
    LFileNameDesc: TLabel;
    CBFileName: TComboBox;
    DeleteLogButton: TButton;
    LogFormStorage: TJvFormStorage;
    ReloadLogButton: TButton;
    FileReadThread: TJvThread;
    GIFPanel: TPanel;
    JvGIFAnimator: TJvGIFAnimator;
    GIFStaticText: TStaticText;
    StatusBar: TStatusBar;
    TextListView: TListView;
    LogPopupMenu: TPopupMenu;
    LogCopy: TMenuItem;
    SelectAllRow: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure CBFileNameChange(Sender: TObject);
    procedure DeleteLogButtonClick(Sender: TObject);
    procedure ReloadLogButtonClick(Sender: TObject);
    procedure FileReadThreadExecute(Sender: TObject; Params: Pointer);
    procedure FileReadThreadFinish(Sender: TObject);
    procedure CBFileNameDropDown(Sender: TObject);
    procedure CheckLogFile;
    procedure FileReadThreadStop;
    procedure FindLogFile(Dir, Ext: String);
    procedure TextListViewData(Sender: TObject; Item: TListItem);
    procedure TextListViewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TextListViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure LogCopyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectAllRowClick(Sender: TObject);
  private
    { Private declarations }
    FTextReader: TJclAnsiMappedTextReader;
    IsUnicodeFile: Boolean;
    // Для мультиязыковой поддержки
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
  end;

var
  LogForm: TLogForm;

implementation

{$R *.dfm}

uses
  Main;

procedure TLogForm.FormCreate(Sender: TObject);
begin
  // Для мультиязыковой поддержки
  LogFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Загружаем язык интерфейса
  LoadLanguageStrings;
  // Настройки TextListView
  // Инфо тут http://zarezky.spb.ru/lectures/mfc/list-control.html
  ListView_SetExtendedListViewStyle(TextListView.Handle, LVS_EX_DOUBLEBUFFER or LVS_EX_FULLROWSELECT); // or LVS_EX_INFOTIP
end;

procedure TLogForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTextReader);
end;

procedure TLogForm.FormResize(Sender: TObject);
begin
  if GIFPanel.Visible then
  begin
    GIFPanel.Left := (TextListView.Width div 2) - (GIFPanel.Width div 2);
    GIFPanel.Top := (TextListView.Height div 2) + (GIFPanel.Height div 2);
  end;
end;

procedure TLogForm.FormShow(Sender: TObject);
begin
  // Переменная для режима анти-босс
  Global_LogForm_Showing := True;
  // Прозрачность окна
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
  TextListView.Clear;
  CBFileName.ItemIndex := -1;
  ReloadLogButton.Enabled := False;
  DeleteLogButton.Enabled := False;
  // Позиционируем панельку
  GIFPanel.BringToFront;
  GIFPanel.Left := (TextListView.Width div 2) - (GIFPanel.Width div 2);
  GIFPanel.Top := (TextListView.Height div 2) + (GIFPanel.Height div 2);
  IsUnicodeFile := False;
end;

procedure TLogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Завершаем поток
  FileReadThreadStop;
  // Переменная для режима анти-босс
  Global_LogForm_Showing := False;
end;

{ Раскрытие списка CBFileName }
procedure TLogForm.CBFileNameDropDown(Sender: TObject);
begin
  // Завершаем поток
  FileReadThreadStop;
  // Построение списка файлов
  CheckLogFile;
end;

{ Изменение текста в CBFileName }
procedure TLogForm.CBFileNameChange(Sender: TObject);
begin
  // Завершаем поток
  FileReadThreadStop;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура CBFileNameChange: Запуск потока FileReadThread.', 2);
  // Запуск потока
  GIFPanel.Left := (TextListView.Width div 2) - (GIFPanel.Width div 2);
  GIFPanel.Top := (TextListView.Height div 2) + (GIFPanel.Height div 2);
  GIFPanel.Visible := True;
  FileReadThread.Execute(Self);
end;

{ Поток чтения лог-файла }
procedure TLogForm.FileReadThreadExecute(Sender: TObject; Params: Pointer);
var
  FileName: String;
  TC: Cardinal;
  LineCount, TempLineCount: Integer;
  LineCountTime: Extended;
begin
  FileName := CBFileName.Items[CBFileName.ItemIndex];
  if FileExists(FileName) then
  begin
    // *.bad файлы всегда в unicode
    if (ExtractFileNameEx(FileName, True) = MesLogName + '.bad') or (ExtractFileNameEx(FileName, True) = ImportLogName + '.bad') then
      IsUnicodeFile := True
    else
      IsUnicodeFile := False;
    // End
    TextListView.Clear;
    if GetMyFileSize(FileName) > 0 then
    begin
      DeleteLogButton.Enabled := False;
      ReloadLogButton.Enabled := False;
      FreeAndNil(FTextReader);
      try
        TC := GetTickCount;
        FTextReader := TJclAnsiMappedTextReader.Create(FileName);
        LineCount := FTextReader.LineCount;
        LineCountTime := GetTickCount - TC;
        TextListView.Items.Count := LineCount;
        TextListView.Invalidate;
        StatusBar.Panels[0].Text := ExtractFileName(FileName);
        StatusBar.Panels[1].Text := Format(GetLangStr('TotalString')+' %d', [LineCount]);
        StatusBar.Panels[2].Text := Format(GetLangStr('LoadingTime')+' %.2f '+GetLangStr('MSec'), [LineCountTime]);
      except
        on E: Exception do
          MsgDie(ProgramsName + ' - ' + GetLangStr('OpenLogFileCaption'), PWideChar(Format(GetLangStr('OpenLogFile'), [FileName]) + #13 +
            GetLangStr('OpenLogFileLock') + #13 + Trim(E.Message)));
      end;
    end
    else
    begin
      StatusBar.Panels[0].Text := ExtractFileName(FileName);
      StatusBar.Panels[1].Text := Format(GetLangStr('TotalString')+' %d', [0]);
      StatusBar.Panels[2].Text := Format(GetLangStr('LoadingTime')+' %.2f '+GetLangStr('MSec'), [0.00]);
    end;
    ReloadLogButton.Enabled := True;
    DeleteLogButton.Enabled := True;
  end;
end;

{ Завершаем поток }
procedure TLogForm.FileReadThreadStop;
begin
  if not FileReadThread.Terminated then
    FileReadThread.Terminate;
  while not (FileReadThread.Terminated) do
  begin
    Sleep(1);
    Application.ProcessMessages;
  end;
  TextListView.Clear;
  FreeAndNil(FTextReader);
end;

{ Поток завершен }
procedure TLogForm.FileReadThreadFinish(Sender: TObject);
begin
  GIFPanel.Visible := False;
  if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура FileReadThreadFinish: Поток FileReadThread завершен.', 2);
end;

procedure TLogForm.LogCopyClick(Sender: TObject);
var
  LVStr: String;
  I: Integer;
begin
  LVStr := '';
  if TextListView.SelCount = 1 then
    LVStr := TextListView.Items.Item[TextListView.ItemIndex].Caption
  else
  begin
    for I := TextListView.ItemIndex to TextListView.ItemIndex+TextListView.SelCount-1 do
      LVStr := LVStr + TextListView.Items.Item[I].Caption + #13#10;
  end;
  Clipboard.SetTextBuf(PChar(LVStr));
end;

procedure TLogForm.SelectAllRowClick(Sender: TObject);
begin
  TextListView.SelectAll;
end;

procedure TLogForm.TextListViewContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if TextListView.Items.Count > 0 then
    TextListView.PopupMenu := LogPopupMenu
  else
    TextListView.PopupMenu := nil;
end;

procedure TLogForm.TextListViewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  BColor: TColor;
begin
  if (Item.Index and 1) = 0 then
    BColor := $ffecda // четное
  else
    BColor := $d8d8fa; // не четноеffffff
  Sender.Canvas.Brush.Color := BColor;
end;

procedure TLogForm.TextListViewData(Sender: TObject; Item: TListItem);
begin
  if IsUnicodeFile then
    Item.Caption := UTF8ToWideString(FTextReader.Lines[Item.Index])
  else
    Item.Caption := String(FTextReader.Lines[Item.Index]);
end;

procedure TLogForm.DeleteLogButtonClick(Sender: TObject);
var
  Deleted: Boolean;
  UserAnswer: Integer;
begin
  if FileExists(CBFileName.Items[CBFileName.ItemIndex]) then
  begin
    // Завершаем поток
    FileReadThreadStop;
    // Пытаемся удалить файл
    Deleted := False;
    UserAnswer := 1;
    repeat
      Deleted := SysUtils.DeleteFile(CBFileName.Items[CBFileName.ItemIndex]);
      if not Deleted then
      begin
        case MessageBox(Handle,PWideChar(Format(GetLangStr('DeleteLogFile'), [CBFileName.Items[CBFileName.ItemIndex]]) + #13 +
            GetLangStr('DeleteLogFileRepeat')),PWideChar(MainSyncForm.Caption + ' - ' + GetLangStr('DeleteLogFileCaption')),36) of
          6: UserAnswer := 1; // Да
          7: UserAnswer := 0; // Нет
        end;
      end;
    until (Deleted) or (UserAnswer = 0);
    if Deleted then
      if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - Процедура DeleteLogButtonClick: Файл ' + CBFileName.Items[CBFileName.ItemIndex] + ' удален.', 2);
    CheckLogFile;
  end;
end;

procedure TLogForm.CheckLogFile;
begin
  CBFileName.Clear;
  ReloadLogButton.Enabled := False;
  DeleteLogButton.Enabled := False;
  FindLogFile(ProfilePath, '*.log');
  FindLogFile(ProfilePath, '*.bad');
end;

{ Процедура поиска файлов по маске и формирования их списка }
procedure TLogForm.FindLogFile(Dir, Ext: String);
var
  SR: TSearchRec;
begin
  if FindFirst(Dir + '*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // Чтобы не было файлов . и ..
      begin
        Continue; // Продолжаем цикл
      end;
      if MatchStrings(SR.Name, Ext) then
      begin
        // Заполняем лист
        CBFileName.Items.Add(Dir+SR.Name);
      end;
      if (SR.Attr = faDirectory) then // Если нашли директорию, то ищем файлы в ней
      begin
        FindLogFile(Dir + '\' + SR.Name, Ext); // Pекурсивно вызываем нашу процедуру
        Continue; // Продолжаем цикл
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

procedure TLogForm.ReloadLogButtonClick(Sender: TObject);
begin
  CBFileNameChange(ReloadLogButton);
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TLogForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Для мультиязыковой поддержки }
procedure TLogForm.LoadLanguageStrings;
begin
  if IMClientType <> 'Unknown' then
    Caption := ProgramsName + ' for ' + IMClientType + ' - ' + GetLangStr('HistoryToDBSyncLogFormCaption')
  else
    Caption := ProgramsName + ' - ' + GetLangStr('HistoryToDBSyncLogFormCaption');
  GIFStaticText.Caption := GetLangStr('GIFStaticText');
  GIFPanel.Left := (TextListView.Width div 2) - (GIFPanel.Width div 2);
  GIFPanel.Top := (TextListView.Height div 2) + (GIFPanel.Height div 2);
  LogPopupMenu.Items[0].Caption := GetLangStr('Copy');
  LogPopupMenu.Items[1].Caption := GetLangStr('SelectAll');
  LFileNameDesc.Caption := GetLangStr('HistoryToDBSyncLogFormFileName');
  DeleteLogButton.Caption := GetLangStr('HistoryToDBSyncLogFormDeleteLogButton');
  ReloadLogButton.Caption := GetLangStr('HistoryToDBSyncLogFormReloadLogButton');
  // Позиционируем лейблы
  CBFileName.Left := LFileNameDesc.Left + LFileNameDesc.Width + 5;
  CBFileName.Width := ReloadLogButton.Left - CBFileName.Left - 5;
end;

end.
