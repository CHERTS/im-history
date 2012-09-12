{ ############################################################################ }
{ #                                                                          # }
{ #  RnQ HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

library RnQHistoryToDB;

{$I Compilers.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

uses
  Classes,
  Windows,
  Messages,
  SysUtils,
  WideStrUtils,
  JclStringConversions,
  XMLIntf,
  XMLDoc,
  ShellApi,
  Types,
  Global in 'Global.pas',
  CallExec in 'CallExec.pas',
  About in 'About.pas' {AboutForm},
  FSMonitor in 'FSMonitor.pas',
  plugin,
  pluginutil;

var
  userPath, andrqPath: AnsiString;
  vApiVersion, CurrentUIN: Integer;
  MessageCount: Integer;
  CoreLanguage: WideString;
  Button_Handle: Integer;
  PluginStatus: Boolean = False;
  // Переменные для меню кнопки окна чата
  MenuWnd    : HWND;
  PopupMenu  : HMENU;
  ActiveMenu : HMENU;

// Обработчик нажатия кнопки плагина в окне чата левой клавишей мыши
procedure OnPluginLeftButtonClick(Handle: Integer);
var
  WinName: String;
begin
  Global_AccountUIN := RQ_GetChatUIN();
  Global_AccountName := RQ_GetDisplayedName(Global_AccountUIN);
  WinName := 'HistoryToDBViewer for RnQ ('+MyAccount+')';
  if SearchMainWindow(pWideChar(WinName)) then
  begin
    // Формат команды:
    //   для истории контакта:
    //     008|0|UserID|UserName|ProtocolType
    //   для истории чата:
    //     008|2|ChatName
    OnSendMessageToOneComponent(WinName, '008|0|'+IntToStr(Global_AccountUIN)+'|'+Global_AccountName+'|0');
  end
  else
  begin
    if FileExists(PluginPath + '\HistoryToDBViewer.exe') then
      ShellExecute(0, 'open', PWideChar(PluginPath + '\HistoryToDBViewer.exe'), PWideChar('"'+PluginPath+'\" "'+ProfilePath+'" 0 "'+IntToStr(Global_CurrentAccountUIN)+'" "'+Global_CurrentAccountName+'" "'+IntToStr(Global_AccountUIN)+'" "'+Global_AccountName+'" 0'), nil, SW_SHOWNORMAL)
    else
      MsgInf(GetLangStr('InfoCaption'), Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + '\HistoryToDBViewer.exe']));
  end;
end;

{ Показываем окно Настроек плагина }
procedure OnClickSettings;
var
  WinName: String;
begin
  // Ищем окно HistoryToDBViewer
  WinName := 'HistoryToDBViewer';
  if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не найден, то ищем другое окно
  begin
    WinName := 'HistoryToDBViewer for RnQ ('+MyAccount+')';
    if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBViewer не запущен, то запускаем
    begin
      if FileExists(PluginPath + 'HistoryToDBViewer.exe') then
      begin
        // Отправлен запрос на показ настроек
        StopWatch;
        WriteCustomINI(ProfilePath, 'SettingsFormRequestSend', '1');
        StartWatch(ProfilePath, FILE_NOTIFY_CHANGE_LAST_WRITE, False, @ProfileDirChangeCallBack);
        ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBViewer.exe'), PWideChar(' "'+PluginPath+'" "'+ProfilePath+'" 4'), nil, SW_SHOWNORMAL);
      end
      else
        MsgInf(PluginName, Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + 'HistoryToDBViewer.exe']));
    end
    else // Иначе посылаем запрос
      OnSendMessageToOneComponent(WinName, '005');
  end
  else // Иначе посылаем запрос на показ настроек
    OnSendMessageToOneComponent(WinName, '005');
end;


// Обработчик нажатия кнопки плагина в окне чата правой клавишей мыши
procedure OnPluginRightButtonClick(Handle: Integer; X,Y: Integer);
begin
  TrackPopupMenu(PopupMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON, X,Y,0, MenuWnd, nil);
end;

// Обработчик нажатия кнопки плагина в окне чата
procedure OnPluginButtonClick(AButton: Integer);
var
  curPos: TPoint;
begin
  GetCursorPos(curPos);
  case AButton of
    0: OnPluginLeftButtonClick(AButton);
    1: OnPluginRightButtonClick(AButton, curPos.X, curPos.Y);
    else OnPluginLeftButtonClick(AButton);
  end;
end;

// Обработчик пунктов меню
procedure OnMenuItemClick(ItemID: Integer);
var
  List: TIntegerDynArray;
  I: Integer;
  WinName: String;
begin
  case ItemID of
    1: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
    3:
    begin
      if FileExists(ProfilePath+ProtoListName) then
        DeleteFile(ProfilePath+ProtoListName);
      WriteInLog(ProfilePath, WideFormat('%s;%s;%d', ['ICQ', IntToStr(Global_CurrentAccountUIN), 0]), 4);
      if FileExists(ProfilePath+ContactListName) then
        DeleteFile(ProfilePath+ContactListName);
      // Запрашиваем список контактов
      List := RQ_GetList(PL_ROASTER);
      for I:=0 to HIGH(List) do
      begin
       WriteInLog(ProfilePath, WideFormat('%s;%s;%s;%d', [IntToStr(List[I]), RQ_GetDisplayedName(List[I]), 'Default', 0]), 3);
      end;
    end;
    4: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '0050');
    5: OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '0051');
    6: if FileExists(ProfilePath+ContactListName) then OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '007');
    7:
    begin
      // Ищем окно HistoryToDBUpdater
      WinName := 'HistoryToDBUpdater';
      if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не найден, то ищем другое окно
      begin
        WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
        if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не запущен, то запускаем
        begin
          if FileExists(PluginPath + 'HistoryToDBUpdater.exe') then
          begin
            // Отправлен запрос
            ShellExecute(0, 'open', PWideChar(PluginPath + 'HistoryToDBUpdater.exe'), PWideChar(' "'+ProfilePath+'"'), nil, SW_SHOWNORMAL);
          end
          else
            MsgInf(PluginName, Format(GetLangStr('ERR_NO_FOUND_UPDATER'), [PluginPath + 'HistoryToDBUpdater.exe']));
        end
        else // Иначе посылаем запрос
          OnSendMessageToOneComponent(WinName, '0040');
      end
      else // Иначе посылаем запрос
        OnSendMessageToOneComponent(WinName, '0040');
    end;
    9: OnClickSettings;
    11: AboutForm.Show;
  end;
end;

// Оконная процедура меню
function WndProc(wnd: hWnd; msg, wParam, lParam: longint): longint; stdcall;
begin
  case msg of
    WM_COMMAND:
      begin
        if ActiveMenu = PopupMenu then
         OnMenuItemClick(Lo(wParam));
        Result := 0;
      end;
    WM_INITMENUPOPUP:
        ActiveMenu := wParam
    else
      Result := DefWindowProc(wnd, msg, WParam, LParam);
  end;
end;

// Создаём окошко для меню
procedure CreateWindow(var Wnd: HWND);
var
  wc: WndClass;
begin
  wc.style := 0;
  wc.lpfnWndProc := @WndProc;
  wc.cbClsExtra := 0;
  wc.cbWndExtra := 0;
  wc.hInstance := hInstance;
  wc.hIcon := 0;
  wc.hCursor := 0;
  wc.hbrBackground := 0;
  wc.lpszMenuName := nil;
  wc.lpszClassName := 'TRQPlugWnd02340';
  Windows.RegisterClass(wc);
  Wnd := CreateWindowEx(WS_EX_APPWINDOW, 'TRQPlugWnd02340',
    '', WS_POPUP, 0, 0, 0, 0, 0, 0, hInstance, nil);
end;

// Уничтожаем окошко для меню
procedure DestroyWindow(var Wnd: HWND);
begin
  Windows.DestroyWindow(Wnd);
  Wnd := 0;
end;

// logtype = 0 - сообщения добавляются в файл meslogname
// logtype = 1 - ошибки добавляются в файл errlogname
procedure AddMsgToLog(Data: Pointer; Status: Integer; LogType: Integer);
var
  Msg_RcvrAcc, Msg_Flags: Integer;
  Current_UIN_Name, Msg_RcvrNick, Msg_Text, MD5String: AnsiString;
  Msg_DateTime: TDateTime;
  Date_Str: String;
begin
  if Status = 0 then
  begin
    RQ__ParseMsgSentString(Data, Msg_RcvrAcc, Msg_Flags, Msg_Text);
    // Заменяем спецсимволы
    Msg_Text := StringReplace(Msg_Text,#34,'\'+#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#92,'\'+#92,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#96,'\'+#96,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#39,#39#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#09,'\t',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#10,'\n',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#13,'\r',[RFReplaceall]);
    if not IsUTF8String(Msg_Text) then
      Msg_Text :=  WideStringToUTF8(Msg_Text);
    // Кодируем в UTF8
    if not IsUTF8String(Global_CurrentAccountName) then
      Current_UIN_Name :=  WideStringToUTF8(Global_CurrentAccountName)
    else
      Current_UIN_Name :=  Global_CurrentAccountName;
    if not IsUTF8String(RQ_GetDisplayedName(Msg_RcvrAcc)) then
      Msg_RcvrNick := WideStringToUTF8(RQ_GetDisplayedName(Msg_RcvrAcc))
    else
      Msg_RcvrNick := RQ_GetDisplayedName(Msg_RcvrAcc);
    Msg_DateTime := RQ_GetTime();
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', Msg_DateTime)
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime);
    MD5String := IntToStr(Msg_RcvrAcc) + FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime) + Msg_Text;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '0', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)]), LogType)
    else
      WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '0', Date_Str, Msg_Text, EncryptMD5(MD5String)]), LogType);
  end
  else
  begin
    RQ__ParseMsgGotString(Data, Msg_RcvrAcc, Msg_Flags, Msg_DateTime, Msg_Text);
    // Заменяем спецсимволы
    Msg_Text := StringReplace(Msg_Text,#34,'\'+#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#92,'\'+#92,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#96,'\'+#96,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#39,#39#39,[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#09,'\t',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#10,'\n',[RFReplaceall]);
    Msg_Text := StringReplace(Msg_Text,#13,'\r',[RFReplaceall]);
    if not IsUTF8String(Msg_Text) then
      Msg_Text :=  WideStringToUTF8(Msg_Text);
    if not IsUTF8String(Current_UIN_Name) then
      Current_UIN_Name :=  WideStringToUTF8(Global_CurrentAccountName)
    else
      Current_UIN_Name :=  Global_CurrentAccountName;
    if not IsUTF8String(RQ_GetDisplayedName(Msg_RcvrAcc)) then
      Msg_RcvrNick := WideStringToUTF8(RQ_GetDisplayedName(Msg_RcvrAcc))
    else
      Msg_RcvrNick := RQ_GetDisplayedName(Msg_RcvrAcc);
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      Date_Str := FormatDateTime('DD.MM.YYYY HH:MM:SS', Msg_DateTime)
    else
      Date_Str := FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime);
    MD5String := IntToStr(Msg_RcvrAcc) + FormatDateTime('YYYY-MM-DD HH:MM:SS', Msg_DateTime) + Msg_Text;
    if (DBType = 'oracle') or (DBType = 'oracle-9i') then
      WriteInLog(ProfilePath, Format(MSG_LOG_ORACLE, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '1', 'to_date('''+Date_Str+''', ''dd.mm.yyyy hh24:mi:ss'')', Msg_Text, EncryptMD5(MD5String)]), LogType)
    else
      WriteInLog(ProfilePath, Format(MSG_LOG, [DBUserName, '0', Current_UIN_Name, IntToStr(Global_CurrentAccountUIN), Msg_RcvrNick, IntToStr(Msg_RcvrAcc), '1', Date_Str, Msg_Text, EncryptMD5(MD5String)]), LogType);
  end;
  // Посылаем запрос на синхронизацию
  if SyncMethod = 0 then
    OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
  if SyncMethod = 2 then
  begin
    if (SyncInterval > 4) and (SyncInterval < 8) then
    begin
      Inc(MessageCount);
      if (SyncInterval = 5) and (MessageCount = 10) then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
      if (SyncInterval = 6) and (MessageCount = 20) then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
      if (SyncInterval = 7) and (MessageCount = 30) then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
    end;
    if SyncInterval = 9 then
    begin
      Inc(MessageCount);
      if MessageCount = SyncMessageCount then
      begin
        OnSendMessageToOneComponent('HistoryToDBSync for RnQ ('+MyAccount+')', '002');
        MessageCount := 0;
      end;
    end;
  end;
end;

// Функция для мультиязыковой поддержки
procedure CoreLanguageChanged;
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
        MsgDie(PluginName, 'Not found any language file!');
        Exit;
      end;
    end;
    Global.CoreLanguage := CoreLanguage;
    SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
  except
    on E: Exception do
      MsgDie(PluginName, 'Error on CoreLanguageChanged: ' + E.Message + sLineBreak +
        'CoreLanguage: ' + CoreLanguage);
  end;
end;

function pluginFun(Data: Pointer): Pointer; stdcall;
var
  UpdTmpPath, WinName: String;
begin
  Result := nil;
  if (Data=nil) or (_int_at(Data)=0) then exit;
  case _byte_at(Data,4) of
    PM_EVENT:
      case _byte_at(Data,5) of
        PE_INITIALIZE:
        begin
          RQ__ParseInitString(Data, callback, vapiVersion, andrqPath, userPath, CurrentUIN);
          // Определяем пути
          ProfilePath := RQ_GetUserPath();
          PluginPath := RQ_GetAndrqPath + 'plugins\';
          MyAccount := IntToStr(RQ_GetCurrentUser());
          // Копируем дефолтный файл конфигурации юзеру в профиль
          if FileExists(PluginPath + DefININame) then
          begin
            if FileExists(ProfilePath + ININame) then
              RenameFile(ProfilePath + ININame, ProfilePath + ININame + '.' + FormatDateTime('ddmmyyhhmmss', Now));
            CopyFileEx(PChar(PluginPath + DefININame), PChar(ProfilePath + ININame), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS);
            if FileExists(ProfilePath + ININame) then
              DeleteFile(PluginPath + DefININame);
          end;
          // Загружаем настройки плагина
          LoadINI(ProfilePath, true);
          if RQ_GetRnQVersion < 1106 then
          begin
            if DefaultLanguage = 'Russian' then
              MessageBox(0, PChar('Извините, но плагин RnQHistoryToDB не может работать с данной версией RnQ.' + #13 + 'Пожалуйста, обновите RnQ до версии 1106 и выше.' + #13 + 'Обновление можно скачать на официальном сайте http://www.rnq.ru'), PChar(PluginName), MB_ICONHAND)
            else
              MessageBox(0, PChar('Sorry, but the plugin RnQ HistoryToDB can not work with this version RnQ.'+ #13 + 'Please upgrade RnQ to version 1106 and above.' + #13 + 'The update can be downloaded from the official site http://www.rnq.ru'), PChar(PluginName), MB_ICONHAND);
            Exit;
          end;
          try
            PluginStatus := True;
            MessageCount := 0;
            if not Assigned(AboutForm) then
              AboutForm := TAboutForm.create(nil);
            // Инициализация шифрования
            EncryptInit;
            // Записываем наше имя, потом оно используется для заголовка программ
            WriteCustomINI(ProfilePath, 'MyAccount', MyAccount);
            // Запрос на закрытие всех компонентов плагина если они были открыты
            OnSendMessageToAllComponent('003');
            // Загружаем настройки локализации
            LangDoc := NewXMLDocument();
            CoreLanguage := DefaultLanguage;
            CoreLanguageChanged;
            // Записываем типа IM клиента
            WriteCustomINI(ProfilePath, 'IMClientType', 'RnQ');
            { Запускаем контроль файла конфигурации
            FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;//Изменение имени файла
            FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;//Изменение имени папки
            FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;//Изменение атрибутов файла
            FILE_NOTIFY_CHANGE_SIZE             = $00000008;//Изменение размера файла
            FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;//Изменение времени последней записи
            FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;//Изменение времени последнего доступа
            FILE_NOTIFY_CHANGE_CREATION         = $00000040;//Изменение времени создания
            FILE_NOTIFY_CHANGE_SECURITY         = $00000100;//Изменение прав доступа
            }
            StartWatch(ProfilePath, FILE_NOTIFY_CHANGE_LAST_WRITE, False, @ProfileDirChangeCallBack);
            // Запускаем программу синхронизации HistoryToDBSync
            if FileExists(PluginPath + '\HistoryToDBSync.exe') then
              ShellExecute(0, 'open', PWideChar(PluginPath + '\HistoryToDBSync.exe'), PWideChar('"'+PluginPath+'\" "'+ProfilePath+'"'), nil, SW_SHOWNORMAL)
            else
              MsgInf(GetLangStr('InfoCaption'), Format(GetLangStr('ERR_NO_FOUND_VIEWER'), [PluginPath + '\HistoryToDBSync.exe']));
            Global_CurrentAccountUIN := RQ_GetCurrentUser();
            Global_CurrentAccountName := RQ_GetDisplayedName(Global_CurrentAccountUIN);
            if ShowPluginButton then
            begin
              Button_Handle := RQ_CreateChatButton(@OnPluginButtonClick, AboutForm.Icon.Handle, Format(GetLangStr('IMButtonCaption'), [PluginName]));
              // Создяем меню
              CreateWindow(MenuWnd);
              PopupMenu := CreatePopupMenu;
              AppendMenu(PopupMenu, MF_STRING, 1, PWideChar(GetLangStr('SyncButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 2, '-');
              AppendMenu(PopupMenu, MF_STRING, 3, PWideChar(GetLangStr('GetContactListButton')));
              AppendMenu(PopupMenu, MF_STRING, 4, PWideChar(GetLangStr('CheckMD5Hash')));
              AppendMenu(PopupMenu, MF_STRING, 5, PWideChar(GetLangStr('CheckAndDeleteMD5Hash')));
              AppendMenu(PopupMenu, MF_STRING, 6, PWideChar(GetLangStr('UpdateContactListButton')));
              AppendMenu(PopupMenu, MF_STRING, 7, PWideChar(GetLangStr('CheckUpdateButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 8, '-');
              AppendMenu(PopupMenu, MF_STRING, 9, PWideChar(GetLangStr('SettingsButton')));
              AppendMenu(PopupMenu, MF_SEPARATOR, 10, '-');
              AppendMenu(PopupMenu, MF_STRING, 11, PWideChar(GetLangStr('AboutButton')));
            end;
            // Обновление утилиты HistoryToDBUpdater.exe из временной папки
            UpdTmpPath := GetUserTempPath + 'IMHistory\';
            if FileExists(UpdTmpPath + 'HistoryToDBUpdater.exe') then
            begin
              // Ищем окно HistoryToDBUpdater
              WinName := 'HistoryToDBUpdater';
              if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не найден, то ищем другое окно
              begin
                WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
                if SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater запущен, то закрываем его
                  OnSendMessageToOneComponent(WinName, '009');
              end
              else // Иначе посылаем запрос
                OnSendMessageToOneComponent(WinName, '009');
              // Удаляем старую утилиту
              if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
              begin
                if CopyFileEx(PChar(UpdTmpPath + 'HistoryToDBUpdater.exe'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
                begin
                  DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
                  if CoreLanguage = 'Russian' then
                    MsgInf(PluginName, Format('Утилита обновления %s успешно обновлена.', ['HistoryToDBUpdater.exe']))
                  else
                    MsgInf(PluginName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
                end;
              end
              else
              begin
                DeleteFile(UpdTmpPath + 'HistoryToDBUpdater.exe');
                if CoreLanguage = 'Russian' then
                  MsgDie(PluginName, Format('Ошибка обновления утилиты %s', [PluginPath + 'HistoryToDBUpdater.exe']))
                else
                  MsgDie(PluginName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
              end;
            end;
            // Обновление утилиты HistoryToDBUpdater.exe из папки плагина
            if FileExists(PluginPath + 'HistoryToDBUpdater.upd') then
            begin
              // Ищем окно HistoryToDBUpdater
              WinName := 'HistoryToDBUpdater';
              if not SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater не найден, то ищем другое окно
              begin
                WinName := 'HistoryToDBUpdater for RnQ ('+MyAccount+')';
                if SearchMainWindow(pWideChar(WinName)) then // Если HistoryToDBUpdater запущен, то закрываем его
                  OnSendMessageToOneComponent(WinName, '009');
              end
              else // Иначе посылаем запрос
                OnSendMessageToOneComponent(WinName, '009');
              // Удаляем старую утилиту
              if DeleteFile(PluginPath + 'HistoryToDBUpdater.exe') then
              begin
                if CopyFileEx(PChar(PluginPath + 'HistoryToDBUpdater.upd'), PChar(PluginPath + 'HistoryToDBUpdater.exe'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
                begin
                  DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
                  if CoreLanguage = 'Russian' then
                    MsgInf(PluginName, Format('Утилита обновления %s успешно обновлена.', ['HistoryToDBUpdater.exe']))
                  else
                    MsgInf(PluginName, Format('Update utility %s successfully updated.', ['HistoryToDBUpdater.exe']));
                end;
              end
              else
              begin
                DeleteFile(PluginPath + 'HistoryToDBUpdater.upd');
                if CoreLanguage = 'Russian' then
                  MsgDie(PluginName, Format('Ошибка обновления утилиты %s', [PluginPath + 'HistoryToDBUpdater.exe']))
                else
                  MsgDie(PluginName, Format('Error update utility %s', [PluginPath + 'HistoryToDBUpdater.exe']));
              end;
            end;
            Result := str2comm(ansichar(PM_DATA)+_istring(PluginName)+_int(APIversion));
          except
            on E: Exception do
              MsgDie(PluginName, 'Error on PE_INITIALIZE: ' + E.Message);
          end;
        end;

        PE_PREFERENCES:
        begin
          OnClickSettings;
        end;

        PE_FINALIZE:
        begin
          try
            if PluginStatus then
            begin
              // Останавливаем контроль файла конфигурации
              StopWatch;
              // Удаляем меню
              DestroyMenu(PopupMenu);
              DestroyWindow(MenuWnd);
              // Удаляем кнопку и окна
              if Button_Handle <> 0 then RQ_DeleteChatButton(Button_Handle);
              if Assigned(AboutForm) then FreeAndNil(AboutForm);
              // Запрос на закрытие всех компонентов плагина
              OnSendMessageToAllComponent('003');
              // Очистка ключей шифрования
              EncryptFree;
              LangDoc.Active := False;
            end;
          except
            on E: Exception do
              MsgDie(PluginName, 'Error on PE_FINALIZE: ' + E.Message);
          end;
        end;

        PE_MSG_SENT:
        begin
          AddMsgToLog(Data, 0, 0);
        end;

        PE_MSG_GOT:
        begin
          AddMsgToLog(Data, 1, 0);
        end;
      end; //case
  end; //case
end; //pluginFun

exports
  pluginFun;

end.

