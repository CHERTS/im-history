{ ################################################################################ }
{ #                                                                              # }
{ #  ���������� � ��������� ������ �������� IM-History - HistoryToDBUpdater v1.0 # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XMLIntf, XMLDoc, Global, IniFiles, uIMDownloader, ShellApi,
  ImgList;

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
    ImageList_Main: TImageList;
    LPlatformType: TLabel;
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
    procedure IMDownloader1MD5Checked(Sender: TObject; MD5Correct, SizeCorrect: Boolean; MD5Str: string);
    procedure CBLangChange(Sender: TObject);
    procedure CBIMClientTypeChange(Sender: TObject);
    procedure CBDBTypeChange(Sender: TObject);
    procedure ButtonUpdateEnableStart;
    procedure ButtonUpdateEnableStop;
    procedure FindLangFile;
    procedure CoreLanguageChanged;
    procedure InstallUpdate;
    procedure SetProxySettings;
    procedure AntiBoss(HideAllForms: Boolean);
    procedure RunIMClient(IMClientName: String; IMProcessArray: TProcessInfoArray);
    procedure RunAllIMClients;
    function  StartStepByStepUpdate(CurrStep: Integer; INIFileName: String): Integer;
  private
    { Private declarations }
    FLanguage : WideString;
    procedure OnControlReq(var Msg : TWMCopyData); message WM_COPYDATA;
    // ��� �������������� ���������
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
    function EndTask(TaskName, FormName: String): Boolean;
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
    SavePath: String;
    SystemLang: String;
    DropboxProcessInfo: TProcessInfoArray;
    QIPProcessInfo: TProcessInfoArray;
    RnQProcessInfo: TProcessInfoArray;
    SkypeProcessInfo: TProcessInfoArray;
    MirandaProcessInfo: TProcessInfoArray;
    property CoreLanguage: WideString read FLanguage;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  INI: TIniFile;
  Path: WideString;
  IsFileClosed: Boolean;
  sFile: DWORD;
begin
  // ���������� ��� ������ ����-����
  Global_MainForm_Showing := False;
  // ���������� ��������
  DBType := CBDBType.Items[CBDBType.ItemIndex];
  IMClientType := CBIMClientType.Items[CBIMClientType.ItemIndex];
  DefaultLanguage := CoreLanguage;
  Path := ProfilePath + ININame;
  if FileExists(Path) then
  begin
    try
      // ���� ���� ���� ��������� �������� ��� ��� �����-������ �������
      IsFileClosed := False;
      repeat
        sFile := CreateFile(PChar(Path),GENERIC_READ or GENERIC_WRITE,0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
        if (sFile <> INVALID_HANDLE_VALUE) then
        begin
          CloseHandle(sFile);
          IsFileClosed := True;
        end;
      until IsFileClosed;
      // End
      INI := TIniFile.Create(Path);
      if ParamCount = 0 then
      begin
        INI.WriteString('Main', 'DBType', DBType);
        INI.WriteString('Main', 'IMClientType', IMClientType);
        INI.WriteString('Main', 'DefaultLanguage', DefaultLanguage);
      end;
      INI.WriteString('Proxy', 'UseProxy', BoolToIntStr(CBUseProxy.Checked));
      INI.WriteString('Proxy', 'ProxyAddress', EProxyAddress.Text);
      INI.WriteString('Proxy', 'ProxyPort', EProxyPort.Text);
      INI.WriteString('Proxy', 'ProxyAuth', BoolToIntStr(CBProxyAuth.Checked));
      INI.WriteString('Proxy', 'ProxyUser', EProxyUser.Text);
      INI.WriteString('Proxy', 'ProxyUserPasswd', EncryptStr(EProxyUserPasswd.Text));
      INI.WriteString('Updater', 'UpdateServer', UpdateServer);
    finally
      INI.Free;
    end;
  end;
  if FileExists(INISavePath) then
    DeleteFile(INISavePath);
  // ����� ��� � ���
  if EnableDebug then
    LogMemo.Lines.SaveToFile(ProfilePath + DebugLogName);
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
  // ���������� ��������� ����
  if MatchStrings(GetSysLang, '�������*') or MatchStrings(GetSysLang, 'Russian*') then
    SystemLang := 'Russian'
  else
    SystemLang := 'English';
  // ��������� �� ���������� �������
  if SystemLang = 'Russian' then
  begin
    CmdHelpStr := '��������� ������� ' + ProgramsName + ' v' + ProgramsVer + ' ' + PlatformType + ':' + #13 +
    '--------------------------------------------------------------' + #13#13 +
    'HistoryToDBUpdater.exe <1>' + #13#13 +
    '<1> - (�������������� ��������) - ���� �� ����� �������� HistoryToDB.ini (��������: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")';
  end
  else
  begin
    CmdHelpStr := 'Startup options ' + ProgramsName + ' v' + ProgramsVer + ' ' + PlatformType + ':' + #13 +
    '------------------------------------------------' + #13#13 +
    'HistoryToDBUpdater.exe <1>' + #13#13 +
    '<1> - (Optional) - The path to the configuration file HistoryToDB.ini (Example: "C:\Program Files\QIP Infium\Profiles\username@qip.ru\Plugins\QIPHistoryToDB\")';
  end;
  // �������� ������� ����������
  if (ParamStr(1) = '/?') or (ParamStr(1) = '-?') then
  begin
    MsgInf(ProgramsName, CmdHelpStr);
    Exit;
  end
  else
  begin
    if ParamCount >= 1 then
    begin
      ProfilePath := IncludeTrailingPathDelimiter(ParamStr(1));
    end
    else
    begin
      ProfilePath := ExtractFilePath(Application.ExeName);
    end;
    PluginPath := ExtractFilePath(Application.ExeName);
    // ��������� �������
    SavePath := GetUserTempPath + 'IMHistory\';
    INISavePath := SavePath + 'HistoryToDBUpdate.ini';
    IMDownloader1.DirPath := PluginPath;
    // ������������� �����������
    EncryptInit;
    // ������ ���������
    LoadINI(ProfilePath, false);
    // ��������� ��������� �����������
    if ParamCount >= 1 then
      FLanguage := DefaultLanguage
    else
      FLanguage := SystemLang;
    LangDoc := NewXMLDocument();
    if not DirectoryExists(PluginPath + dirLangs) then
      CreateDir(PluginPath + dirLangs);
    if not FileExists(PluginPath + dirLangs + defaultLangFile) then
    begin
      if SystemLang = 'Russian' then
        CmdHelpStr := '���� ����������� ' + PluginPath + dirLangs + defaultLangFile + ' �� ������.'
      else
        CmdHelpStr := 'The localization file ' + PluginPath + dirLangs + defaultLangFile + ' is not found.';
      MsgInf(ProgramsName, CmdHelpStr);
      // ����������� �������
      EncryptFree;
      Exit;
    end;
    CoreLanguageChanged;
    // ��������� ������ ������
    FindLangFile;
    // ��� �������������� ���������
    MainFormHandle := Handle;
    SetWindowLong(Handle, GWL_HWNDPARENT, 0);
    SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
    // ��������� ���� ����������
    LoadLanguageStrings;
    // ��������� ��������
    RunAppDone := True;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if RunAppDone then
  begin
    // ����������� �������
    EncryptFree;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  I: Integer;
begin
  // ���������� ��� ������ ����-����
  Global_MainForm_Showing := True;
  // ������������ ����
  AlphaBlend := AlphaBlendEnable;
  AlphaBlendValue := AlphaBlendEnableValue;
  // ��. ���������
  LAmount.Caption := '0 '+GetLangStr('Kb');
  LFileName.Caption := GetLangStr('Unknown');
  LFileDescription.Caption := GetLangStr('Unknown');
  LFileMD5.Caption := GetLangStr('Unknown');
  LSpeed.Caption := '0 '+GetLangStr('KbSec');
  CBUseProxy.Checked := False;
  EProxyAddress.Enabled := False;
  EProxyPort.Enabled := False;
  CBProxyAuth.Enabled := False;
  SettingsPageControl.ActivePage := TabSheetSettings;
  SettingsPageControl.Visible := False;
  MainForm.Height := SettingsPageControl.Height + 5;
  if (DBType = 'Unknown') or (ParamCount = 0) then
  begin
    CBDBType.Enabled := True;
    CBDBType.Items.Add('Unknown');
    CBDBType.Items.Add('mysql');
    CBDBType.Items.Add('postgresql');
    CBDBType.Items.Add('oracle');
    CBDBType.Items.Add('sqlite-3');
    CBDBType.Items.Add('firebird-2.0');
    CBDBType.Items.Add('firebird-2.5');
    if ParamCount = 0 then
    begin
      for I := 0 to CBDBType.Items.Count-1 do
        if CBDBType.Items[I] = DBType then
          CBDBType.ItemIndex := I
    end
    else
      CBDBType.ItemIndex := 0;
    // ���������� ���������
    ButtonSettingsClick(Self);
  end
  else
  begin
    CBDBType.Enabled := False;
    CBDBType.Items.Add(DBType);
    CBDBType.ItemIndex := 0;
  end;
  if (IMClientType = 'Unknown') or (ParamCount = 0) then
  begin
    CBIMClientType.Enabled := True;
    CBIMClientType.Items.Add('Unknown');
    CBIMClientType.Items.Add('QIP');
    CBIMClientType.Items.Add('RnQ');
    CBIMClientType.Items.Add('Skype');
    CBIMClientType.Items.Add('Miranda');
    CBIMClientType.Items.Add('MirandaNG');
    if ParamCount = 0 then
    begin
      for I := 0 to CBIMClientType.Items.Count-1 do
        if CBIMClientType.Items[I] = IMClientType then
          CBIMClientType.ItemIndex := I
    end
    else
      CBIMClientType.ItemIndex := 0;
    // ���������� ��������� ���� �� ���� �������� �����
    if not SettingsPageControl.Visible then
      ButtonSettingsClick(Self);
  end
  else
  begin
    CBIMClientType.Enabled := False;
    CBIMClientType.Items.Add(IMClientType);
    CBIMClientType.ItemIndex := 0;
  end;
  // ���������
  LPlatformType.Caption := IMClientPlatformType;
  // ������
  CBUseProxy.Checked := IMUseProxy;
  EProxyAddress.Text := IMProxyAddress;
  EProxyPort.Text := IMProxyPort;
  CBProxyAuth.Checked := IMProxyAuth;
  EProxyUser.Text := IMProxyUser;
  EProxyUserPasswd.Text := IMProxyUserPagsswd;
  // ������ ������� ����������
  LogMemo.Lines.Add(ProgramsName + ' v' + ProgramsVer + ' ' + PlatformType);
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
var
  AllProcessEndErr: Integer;
begin
  AllProcessEndErr := 0;
  if (DBType = 'Unknown') or (IMClientType  = 'Unknown') then
    MsgInf(Caption, GetLangStr('SelectDBTypeAndIMClient'))
  else
  begin
    LogMemo.Clear;
    // ���� ��������� ������������� ���� Dropbox
    {if IsProcessRun('Dropbox.exe') then
    begin
      if SystemLang = 'Russian' then
        MsgString := '� ������ ������� ��������� Dropbox.' + #13 +
        '���� �� ����������� � ��� ������������� IM-�������, �� ��� ����������� ����������' + #13 +
        '���� ����������� ������� ���������� � �������.' + #13 +
        '������� Dropbox?'
      else
        MsgString := 'Find the program in the memory of Dropbox.' + #13 +
        'If you use it to synchronize the IM-client, to properly' + #13 +
        'update all the components necessary to close the plug.' + #13 +
        'Close Dropbox?';
      case MessageBox(MainForm.Handle, PWideChar(MsgString), PWideChar(Caption),36) of
        6: DropboxProcessInfo := EndProcess('Dropbox.exe', True);
      end;
    end;}
    // ���� ���������� ���������� ������� � ��������� ��
    if not EndTask('HistoryToDBSync.exe', 'HistoryToDBSync for ' + IMClientType + ' (' + MyAccount + ')') then
      Inc(AllProcessEndErr);
    if not EndTask('HistoryToDBViewer.exe', 'HistoryToDBViewer for ' + IMClientType + ' (' + MyAccount + ')') then
      Inc(AllProcessEndErr);
    if not EndTask('HistoryToDBImport.exe', 'HistoryToDBImport for ' + IMClientType + ' (' + MyAccount + ')') then
      Inc(AllProcessEndErr);
    // ���� ��� �������� �����, �� �����������
    if AllProcessEndErr = 0 then
    begin
      // ���� ��� ���������� IM-�������� � ��������� ��
      if IMClientType = 'QIP' then
      begin
        LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['qip.exe']));
        QIPProcessInfo := EndProcess('qip.exe', 0, True);
      end;
      if IMClientType = 'Miranda' then
      begin
        if IMClientPlatformType = 'x86' then
        begin
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['miranda32.exe']));
          MirandaProcessInfo := EndProcess('miranda32.exe', 1, True);
        end
        else
        begin
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['miranda64.exe']));
          MirandaProcessInfo := EndProcess('miranda64.exe', 1, True);
        end;
      end;
      if IMClientType = 'MirandaNG' then
      begin
        if IMClientPlatformType = 'x86' then
        begin
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['miranda32.exe']));
          MirandaProcessInfo := EndProcess('miranda32.exe', 0, True);
        end
        else
        begin
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['miranda64.exe']));
          MirandaProcessInfo := EndProcess('miranda64.exe', 0, True);
        end;
      end;
      if IMClientType = 'RnQ' then
      begin
        if IsProcessRun('rnq.exe') then
        begin
          RnQProcessInfo := EndProcess('rnq.exe', 0, True);
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['rnq.exe']));
        end;
        if IsProcessRun('R&Q.exe') then
        begin
          RnQProcessInfo := EndProcess('R&Q.exe', 0, True);
          LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['R&Q.exe']));
        end;
      end;
      if IMClientType = 'Skype' then
      begin
        SkypeProcessInfo := EndProcess('skype.exe', 0, True);
        LogMemo.Lines.Add(Format(GetLangStr('EndProcess'), ['skype.exe']));
      end;
      // �������� ����������
      TrueHeader := False;
      CurrentUpdateStep := 0;
      SetProxySettings;
      if IMClientPlatformType = 'x86' then
        IMDownloader1.URL := UpdateServer + '&platform=windows-x86'
      else
        IMDownloader1.URL := UpdateServer + '&platform=windows-x64';
      IMDownloader1.DownLoad;
    end
    else
      MsgInf(Caption, GetLangStr('ManualUpdate'));
  end;
end;

{ ������������� ��������� ������ }
procedure TMainForm.SetProxySettings;
begin
  if CBUseProxy.Checked then
  begin
    IMDownloader1.Proxy := EProxyAddress.Text + ':' + EProxyPort.Text;
    if CBProxyAuth.Checked then
    begin
      IMDownloader1.ProxyAuthUserName := EProxyUser.Text;
      IMDownloader1.ProxyAuthPassword := EProxyUserPasswd.Text;
    end
    else
    begin
      IMDownloader1.ProxyAuthUserName := '';
      IMDownloader1.ProxyAuthPassword := '';
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
  MaxSteps: Integer;
begin
  LStatus.Caption := GetLangStr('DownloadSuccessful');
  LStatus.Hint := 'DownloadSuccessful';
  LStatus.Repaint;
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' '+GetLangStr('Kb');
  LAmount.Repaint;
  if not TrueHeader then
  begin
    LFileName.Caption := GetLangStr('Unknown');
    LFileDescription.Caption := GetLangStr('Unknown');
    LFileMD5.Caption := GetLangStr('Unknown');
    LStatus.Caption := GetLangStr('InvalidResponseHeader');
    LStatus.Hint := 'InvalidResponseHeader';
    LStatus.Repaint;
    ButtonUpdateEnableStart;
  end
  else
  begin
    LStatus.Caption := GetLangStr('IsChecksum');
    LStatus.Hint := 'IsChecksum';
    LStatus.Repaint;
    if MD5InMemory <> 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF' then
    begin
      LogMemo.Lines.Add(GetLangStr('MD5FileInMemory') + ' ' + MD5InMemory);
      LogMemo.Lines.Add(GetLangStr('FileSizeInMemory') + ' ' + IntToStr(IMDownloader1.OutStream.Size));
    end;
    if IMMD5Correct and IMSizeCorrect then
    begin
      if MD5InMemory <> 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF' then
      begin
        LStatus.Caption := GetLangStr('ChecksumConfirmed');
        LStatus.Hint := 'ChecksumConfirmed';
        LStatus.Repaint;
        LogMemo.Lines.Add(GetLangStr('ChecksumConfirmed'));
      end
      else
      begin
        LStatus.Caption := GetLangStr('ChecksumFileEqServer');
        LStatus.Hint := 'ChecksumFileEqServer';
        LStatus.Repaint;
        LogMemo.Lines.Add(GetLangStr('ChecksumFileEqServer'));
      end;
      // ���� ������ ��� - ���������� INI �����
      if CurrentUpdateStep = 0 then
        INISavePath := SavePath + HeaderFileName;
      // ��������� ������� ��� ����������
      if not DirectoryExists(SavePath) then
        CreateDir(SavePath);
      // ������� ������ ����
      if CurrentUpdateStep = 0 then
      begin
        if FileExists(INISavePath) then
          DeleteFile(INISavePath);
      end;
      if FileExists(SavePath + HeaderFileName) then
        DeleteFile(SavePath + HeaderFileName);
      // ��������� �����
      try
        if MD5InMemory <> 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF' then
        begin
          IMDownloader1.OutStream.SaveToFile(SavePath + HeaderFileName);
          LStatus.Caption := GetLangStr('FileSavedAs') + ' ' + HeaderFileName;
          LStatus.Hint := 'FileSavedAs';
          LStatus.Repaint;
          LogMemo.Lines.Add(GetLangStr('FileSavedAs') + ' ' + HeaderFileName);
        end;
        Inc(CurrentUpdateStep);
        if CurrentUpdateStep > 0 then
          MaxSteps := StartStepByStepUpdate(CurrentUpdateStep, INISavePath);
      except
        on E: Exception do
        begin
          LStatus.Caption := GetLangStr('ErrFileSavedAs') + ' ' + HeaderFileName;
          LStatus.Hint := 'ErrFileSavedAs';
          LStatus.Repaint;
          LogMemo.Lines.Add(GetLangStr('ErrFileSavedAs') + ' ' + HeaderFileName);
        end;
      end;
    end
    else
    begin
      if not IMMD5Correct then
      begin
        LStatus.Caption := GetLangStr('ChecksumNotConfirmed');
        LStatus.Hint := 'ChecksumNotConfirmed';
        LStatus.Repaint;
        LogMemo.Lines.Add(GetLangStr('ChecksumNotConfirmed'));
      end;
      if not IMSizeCorrect then
      begin
        LStatus.Caption := GetLangStr('SizeNotConfirmed');
        LStatus.Hint := 'SizeNotConfirmed';
        LStatus.Repaint;
        LogMemo.Lines.Add(GetLangStr('SizeNotConfirmed'));
      end;
      ButtonUpdateEnableStart;
    end;
  end;
end;

function TMainForm.StartStepByStepUpdate(CurrStep: Integer; INIFileName: String): Integer;
var
  UpdateINI: TIniFile;
  MaxStep, IMClientCount, IMClientDownloadFileCount: Integer;
  DatabaseCount, DatabaseDownloadFileCount, I, UpdateServerInServiceMode: Integer;
  IMClientName, IMClientNum, UpdateURL: String;
  DatabaseName, DatabaseNum, TmpUpdateServer: String;
  FileListArray: TArrayOfString;
  DownloadListArray: TArrayOfString;
begin
  Result := 0;
  if FileExists(INIFileName) then
  begin
    UpdateINI := TIniFile.Create(INIFileName);
    UpdateServerInServiceMode := UpdateINI.ReadInteger('HistoryToDBUpdate', 'UpdateServerInServiceMode', 0);
    LogMemo.Lines.Add('UpdateServerInServiceMode = ' + IntToStr(UpdateServerInServiceMode));
    //������ ���������� �������� �� ��������� ������������
    if UpdateServerInServiceMode = 1 then
    begin
      LogMemo.Lines.Add(Format(GetLangStr('UpdateServerInServiceMode'), [' ']));
      IMDownloader1.BreakDownload;
      MsgInf(Caption, Format(GetLangStr('UpdateServerInServiceMode'), [#13]));
      Result := -1;
      // ���. ������
      ButtonUpdateEnableStart;
      // ������ IM-�������
      RunAllIMClients;
      // �����
      Close;
      Exit;
    end;
    // ����� ������� ����������
    TmpUpdateServer := UpdateINI.ReadString('HistoryToDBUpdate', 'UpdateServer', UpdateServer);
    if TmpUpdateServer <> UpdateServer then
      UpdateServer := TmpUpdateServer;
    // End
    MaxStep := UpdateINI.ReadInteger('HistoryToDBUpdate', 'FileCount', 0);
    IMClientCount := UpdateINI.ReadInteger('HistoryToDBUpdate', 'IMClientCount', 0);
    if EnableDebug then
      LogMemo.Lines.Add('����� IM-�������� � INI-����� = ' + IntToStr(IMClientCount));
    IMClientDownloadFileCount := 0;
    SetLength(DownloadListArray, 0);
    if IMClientCount > 0 then
    begin
      IMClientName := '';
      while (IMClientCount > 0) and (IMClientName <> CBIMClientType.Items[CBIMClientType.ItemIndex]) do
      begin
        IMClientName := UpdateINI.ReadString('HistoryToDBUpdate', 'IMClient'+IntToStr(IMClientCount)+'Name', '');
        IMClientNum := UpdateINI.ReadString('HistoryToDBUpdate', 'IMClient'+IntToStr(IMClientCount)+'File', '');
        if EnableDebug then
        begin
          LogMemo.Lines.Add('IM-������ = ' + IMClientName);
          LogMemo.Lines.Add('������ ������ = ' + IMClientNum);
        end;
        Dec(IMClientCount);
      end;
      FileListArray := StringToParts(IMClientNum, [',']);
      SetLength(DownloadListArray, Length(FileListArray));
      DownloadListArray := FileListArray;
      IMClientDownloadFileCount := Length(FileListArray);
      if EnableDebug then
      begin
        for I := 0 to High(FileListArray) do
          LogMemo.Lines.Add('� ����� ��� '+IMClientName+' = ' + FileListArray[I]);
      end;
    end;
    DatabaseCount := UpdateINI.ReadInteger('HistoryToDBUpdate', 'DatabaseCount', 0);
    DatabaseDownloadFileCount := 0;
    if EnableDebug then
      LogMemo.Lines.Add('����� ����� Database � INI-����� = ' + IntToStr(DatabaseCount));
    if DatabaseCount > 0 then
    begin
      DatabaseName := '';
      while (DatabaseCount > 0) and (DatabaseName <> CBDBType.Items[CBDBType.ItemIndex]) do
      begin
        DatabaseName := UpdateINI.ReadString('HistoryToDBUpdate', 'Database'+IntToStr(DatabaseCount)+'Name', '');
        DatabaseNum := UpdateINI.ReadString('HistoryToDBUpdate', 'Database'+IntToStr(DatabaseCount)+'File', '');
        if EnableDebug then
        begin
          LogMemo.Lines.Add('Database = ' + DatabaseName);
          LogMemo.Lines.Add('������ ������ = ' + DatabaseNum);
        end;
        Dec(DatabaseCount);
      end;
      FileListArray := StringToParts(DatabaseNum, [',']);
      SetLength(DownloadListArray, Length(DownloadListArray) + Length(FileListArray));
      DatabaseDownloadFileCount := Length(FileListArray);
      for I := 0 to High(FileListArray) do
      begin
        DownloadListArray[IMClientDownloadFileCount+I] := FileListArray[I];
        if EnableDebug then
          LogMemo.Lines.Add('� ����� ��� '+DatabaseName+' = ' + FileListArray[I]);
      end;
    end;
    if EnableDebug then
    begin
      LogMemo.Lines.Add('����� ����� = ' + IntToStr(Length(DownloadListArray)));
      for I := 0 to High(DownloadListArray) do
        LogMemo.Lines.Add('DownloadListArray['+IntToStr(I)+'] = ' + DownloadListArray[I]);
    end;
    MaxStep := IMClientDownloadFileCount + DatabaseDownloadFileCount;
    Result := MaxStep;
    if EnableDebug then
      LogMemo.Lines.Add('����� ����� = ' + IntToStr(MaxStep));
    if CurrentUpdateStep > MaxStep then
    begin
      LStatus.Caption := GetLangStr('AllUpdatesDownloaded');
      LStatus.Hint := 'AllUpdatesDownloaded';
      LStatus.Repaint;
      LogMemo.Lines.Add('=========================================');
      LogMemo.Lines.Add(GetLangStr('AllUpdatesDownloaded'));
      InstallUpdate;
      LStatus.Caption := GetLangStr('AllUpdatesInstalled');
      LStatus.Hint := 'AllUpdatesInstalled';
      LStatus.Repaint;
      LogMemo.Lines.Add('=========================================');
      LogMemo.Lines.Add(GetLangStr('AllUpdatesInstalled'));
      // ���. ������
      ButtonUpdateEnableStart;
      // ������ IM-�������
      RunAllIMClients;
      Close;
      Exit;
    end;
    LogMemo.Lines.Add('================= ' + GetLangStr('Step') + ' '+IntToStr(CurrStep)+' =================');
    LogMemo.Lines.Add(GetLangStr('NumberFilesUpdate') + ' = ' + IntToStr(MaxStep));
    if MaxStep > 0 then
    begin
      UpdateURL := UpdateINI.ReadString('HistoryToDBUpdate', 'File'+DownloadListArray[CurrStep-1], '');
      if (UpdateURL <> '') and (CurrStep <= MaxStep) then
      begin
        LogMemo.Lines.Add(GetLangStr('FileToUpdate') + ' = ' + UpdateURL);
        if MatchStrings(UpdateURL, '*file=*Lang') then
          IMDownloader1.DirPath := PluginPath + dirLangs
        else if MatchStrings(UpdateURL, '*file=*-update-*-to-*') then
          IMDownloader1.DirPath := PluginPath + dirSQLUpdate
        else
          IMDownloader1.DirPath := PluginPath;
        IMDownloader1.URL := UpdateURL;
        IMDownloader1.DownLoad;
      end
      else
        CurrentUpdateStep := 0;
    end;
  end
  else
    LogMemo.Lines.Add(GetLangStr('UpdateSettingsFileNotFound') + ' ' + INIFileName);
end;

procedure TMainForm.InstallUpdate;
var
  SR: TSearchRec;
begin
  LAmount.Caption := '0 '+GetLangStr('Kb');
  LFileName.Caption := GetLangStr('Unknown');
  LFileDescription.Caption := GetLangStr('Unknown');
  LFileMD5.Caption := GetLangStr('Unknown');
  LSpeed.Caption := '0 '+GetLangStr('KbSec');
  // ����������
  if FindFirst(SavePath + '*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // ����� �� ���� ������ . � ..
      begin
        Continue; // ���������� ����
      end;
      if MatchStrings(SR.Name, 'HistoryToDBUpdater.exe') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateFile'), [SR.Name]);
        LStatus.Hint := 'UpdateFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateFile'), [SR.Name]));
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + 'HistoryToDBUpdater.upd'), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.xml') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateLangFile'), [SR.Name]);
        LStatus.Hint := 'UpdateLangFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateLangFile'), [SR.Name]));
        if FileExists(PluginPath + dirLangs + SR.Name) then
          DeleteFile(PluginPath + dirLangs + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + dirLangs + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateLangFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.sql') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateSQLFile'), [SR.Name]);
        LStatus.Hint := 'UpdateSQLFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateSQLFile'), [SR.Name]));
        if not DirectoryExists(PluginPath + dirSQLUpdate) then
          CreateDir(PluginPath + dirSQLUpdate);
        if FileExists(PluginPath + dirSQLUpdate + SR.Name) then
          DeleteFile(PluginPath + dirSQLUpdate + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + dirSQLUpdate + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateSQLFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.exe') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateFile'), [SR.Name]);
        LStatus.Hint := 'UpdateFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateFile'), [SR.Name]));
        if FileExists(PluginPath + SR.Name) then
          DeleteFile(PluginPath + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.dll') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateFile'), [SR.Name]);
        LStatus.Hint := 'UpdateFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateFile'), [SR.Name]));
        if FileExists(PluginPath + SR.Name) then
          DeleteFile(PluginPath + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.msg') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateFile'), [SR.Name]);
        LStatus.Hint := 'UpdateFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateFile'), [SR.Name]));
        if FileExists(PluginPath + SR.Name) then
          DeleteFile(PluginPath + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateFileDone'), [SR.Name]));
        end;
      end;
      if MatchStrings(SR.Name, '*.txt') then
      begin
        LStatus.Caption := Format(GetLangStr('UpdateFile'), [SR.Name]);
        LStatus.Hint := 'UpdateFile';
        LStatus.Repaint;
        LogMemo.Lines.Add(Format(GetLangStr('UpdateFile'), [SR.Name]));
        if FileExists(PluginPath + SR.Name) then
          DeleteFile(PluginPath + SR.Name);
        if CopyFileEx(PChar(SavePath + SR.Name), PChar(PluginPath + SR.Name), nil, nil, nil, COPY_FILE_FAIL_IF_EXISTS) then
        begin
          DeleteFile(SavePath + SR.Name);
          LogMemo.Lines.Add(Format(GetLangStr('UpdateFileDone'), [SR.Name]));
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

procedure TMainForm.IMDownloader1Break(Sender: TObject);
begin
  LStatus.Caption := GetLangStr('DownloadStopped');
  LStatus.Hint := 'DownloadStopped';
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' '+GetLangStr('Kb');
  LAmount.Repaint;
  ButtonUpdateEnableStart;
end;

procedure TMainForm.IMDownloader1Downloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
begin
  QueryPerformanceCounter(C2);
  ProgressBarDownloads.Max := MaxSize;
  ProgressBarDownloads.Position := AcceptedSize;
  LStatus.Caption := GetLangStr('Loading');
  LStatus.Hint := 'Loading';
  LAmount.Caption := CurrToStr(AcceptedSize/1024)+' '+GetLangStr('Kb');
  LAmount.Repaint;
  LSpeed.Caption := CurrToStr((AcceptedSize/1024)/((C2 - C1) / iCounterPerSec))+' '+GetLangStr('KbSec');
  LSpeed.Repaint;
end;

procedure TMainForm.IMDownloader1Error(Sender: TObject; E: TIMDownloadError);
var
  S, HS: String;
begin
  case E of
    deInternetOpen:
    begin
      S := GetLangStr('ErrInternetOpen');
      HS := 'ErrInternetOpen';
    end;
    deInternetOpenUrl:
    begin
      S := GetLangStr('ErrInternetOpenURL');
      HS := 'ErrInternetOpenURL';
    end;
    deDownloadingFile:
    begin
      S := GetLangStr('ErrDownloadingFile');
      HS := 'ErrDownloadingFile';
    end;
    deRequest:
    begin
      S := GetLangStr('ErrRequest');
      HS := 'ErrRequest';
    end;
  end;
  LStatus.Caption := S;
  LStatus.Hint := HS;
  LogMemo.Lines.Add(S);
  LAmount.Caption := CurrToStr(IMDownloader1.AcceptedSize/1024)+' '+GetLangStr('Kb');
  LAmount.Repaint;
  if not TrueHeader then
  begin
    LFileName.Caption := GetLangStr('Unknown');
    LFileDescription.Caption := GetLangStr('Unknown');
    LFileMD5.Caption := GetLangStr('Unknown');
  end;
  ButtonUpdateEnableStart;
end;

{ ��������� ���������� � �����
  ������ ���������:
  ���_�����|�������_�����|MD5Sum_�����|������_�����
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
  HeadersStrList.Delete(HeadersStrList.Count-1); // ��������� ������� �������� ������ CRLF
  if HeadersStrList.Count > 0 then
  begin
    ResultFilename := 'Test';
    ResultFileDesc := 'Test';
    ResultMD5Sum := '00000000000000000000000000000000';
    ResultFileSize := 0;
    LogMemo.Lines.Add(GetLangStr('ParseHeader'));
    for I := 0 to HeadersStrList.Count - 1 do
    begin
      //LogMemo.Lines.Add(HeadersStrList[I]);
      // ������ ������ ����
      // Content-Disposition: attachment; filename="���-�����"
      // ����� ������ ��������� � ��������� HTTP-�������
      // ������ ��� ������ get.php
      if pos('content-disposition', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultFilename := HeadersStrList[I];
        Delete(ResultFilename, 1, Pos('"', HeadersStrList[I]));
        Delete(ResultFilename, Length(ResultFilename),1);
        //LogMemo.Lines.Add('Filename: '+ResultFilename);
      end;
      // ������ ������ ����
      // Content-Description: Desc
      if pos('content-description', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultFileDesc := HeadersStrList[I];
        Delete(ResultFileDesc, 1, Pos(':', HeadersStrList[I]));
        Delete(ResultFileDesc, 1,1);
        //LogMemo.Lines.Add('Description: '+ResultFileDesc);
      end;
      // ������ ������ ����
      // Content-MD5Sum: MD5
      if pos('content-md5sum', lowercase(HeadersStrList[I])) > 0 then
      begin
        ResultMD5Sum := HeadersStrList[I];
        Delete(ResultMD5Sum, 1, Pos(':', HeadersStrList[I]));
        Delete(ResultMD5Sum, 1,1);
        //LogMemo.Lines.Add('MD5: '+ResultMD5Sum);
      end;
      // ������ ������ ����
      // Content-Length: ������
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
      LogMemo.Lines.Add(GetLangStr('HeaderData'));
      LogMemo.Lines.Add(GetLangStr('FileName') + ' ' + ResultFilename);
      LogMemo.Lines.Add(GetLangStr('FileDesc') + ' ' + ResultFileDesc);
      LogMemo.Lines.Add('MD5: ' + ResultMD5Sum);
      LogMemo.Lines.Add(GetLangStr('FileSize') + ' ' + IntToStr(ResultFileSize));
      LFileName.Caption := ResultFilename;
      LFileDescription.Caption := ResultFileDesc;
      LFileMD5.Caption := ResultMD5Sum;
      HeaderFileName := ResultFilename;
      HeaderMD5 := ResultMD5Sum;
      HeaderFileSize := ResultFileSize;
      if (CurrentUpdateStep = 0) and FileExists(PluginPath+HeaderFileName) then
        DeleteFile(PluginPath+HeaderFileName);
      TrueHeader := True;
    end
    else
    begin
      LogMemo.Lines.Add(GetLangStr('InvalidResponseHeader'));
      LogMemo.Lines.Add(GetLangStr('InvalidResponseHeaderDesc'));
      HeaderFileName := 'Test';
      HeaderMD5 := '00000000000000000000000000000000';
      HeaderFileSize := 0;
      TrueHeader := False;
    end;
  end;
  HeadersStrList.Free;
end;

procedure TMainForm.IMDownloader1MD5Checked(Sender: TObject; MD5Correct, SizeCorrect: Boolean; MD5Str: string);
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
  LStatus.Caption := GetLangStr('InitDownload');
  LStatus.Hint := 'InitDownload';
  LAmount.Caption := '0 '+GetLangStr('Kb');
  LSpeed.Caption := '0 '+GetLangStr('KbSec');
  LogMemo.Lines.Add(GetLangStr('InitDownloadFromURL') + ' ' + IMDownloader1.URL);
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
  ButtonUpdate.Caption := GetLangStr('UpdateButton');
  ButtonUpdate.Hint := 'UpdateButton';
  ButtonSettings.Enabled := True;
  CBIMClientType.Enabled := True;
  CBDBType.Enabled := True;
end;

procedure TMainForm.ButtonUpdateEnableStop;
begin
  ButtonUpdate.OnClick := ButtonUpdateStopClick;
  ButtonUpdate.Caption := GetLangStr('StopButton');
  ButtonUpdate.Hint := 'StopButton';
  ButtonSettings.Enabled := False;
  CBIMClientType.Enabled := False;
  CBDBType.Enabled := False;
end;

procedure TMainForm.CBDBTypeChange(Sender: TObject);
begin
  DBType := CBDBType.Items[CBDBType.ItemIndex];
end;

procedure TMainForm.CBIMClientTypeChange(Sender: TObject);
begin
  IMClientType := CBIMClientType.Items[CBIMClientType.ItemIndex];
end;

{ ����� ����� }
procedure TMainForm.CBLangChange(Sender: TObject);
begin
  FLanguage := CBLang.Items[CBLang.ItemIndex];
  DefaultLanguage := CBLang.Items[CBLang.ItemIndex];
  CoreLanguageChanged;
end;

{ ��������� ������ �������� ������ � ���������� ������ }
procedure TMainForm.FindLangFile;
var
  SR: TSearchRec;
  I: Integer;
begin
  CBLang.Items.Clear;
  if FindFirst(PluginPath + dirLangs + '\*.*', faAnyFile or faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then // ����� �� ���� ������ . � ..
      begin
        Continue; // ���������� ����
      end;
      if MatchStrings(SR.Name, '*.xml') then
      begin
        // ��������� ����
        CBLang.Items.Add(ExtractFileNameEx(SR.Name, False));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if CBLang.Items.Count > 0 then
  begin
    for I := 0 to CBLang.Items.Count-1 do
    begin
      if CBLang.Items[I] = CoreLanguage then
        CBLang.ItemIndex := I;
    end;
  end
  else
  begin
    CBLang.Items.Add(GetLangStr('NotFoundLangFile'));
    CBLang.ItemIndex := 0;
    CBLang.Enabled := False;
  end;
end;

{ ����� ����� ���������� �� ������� WM_LANGUAGECHANGED }
procedure TMainForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
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
    //SendMessage(AboutFormHandle, WM_LANGUAGECHANGED, 0, 0);
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
    Caption := ProgramsName + ' for ' + IMClientType + ' (' + MyAccount + ')'
  else
    Caption := ProgramsName;
  if ButtonUpdate.Hint = 'UpdateButton' then
  begin
    ButtonUpdate.Caption := GetLangStr('UpdateButton');
    ButtonUpdate.Hint := 'UpdateButton';
  end
  else
  begin
    ButtonUpdate.Caption := GetLangStr('StopButton');
    ButtonUpdate.Hint := 'StopButton';
  end;
  ButtonSettings.Caption := GetLangStr('SettingsButton');
  LIMClientType.Caption := GetLangStr('IMClientType');
  LDBType.Caption := GetLangStr('LDBType');
  LLanguage.Caption := GetLangStr('Language');
  TabSheetSettings.Caption := GetLangStr('GeneralSettings');
  TabSheetConnectSettings.Caption := GetLangStr('ConnectionSettings');
  TabSheetLog.Caption := GetLangStr('Logs');
  GBSettings.Caption := GetLangStr('GeneralSettings');
  GBConnectSettings.Caption := GetLangStr('ConnectionSettings');
  CBUseProxy.Caption := GetLangStr('UseProxy');
  LProxyAddress.Caption := GetLangStr('ProxyAddress');
  LProxyPort.Caption := GetLangStr('ProxyPort');
  CBProxyAuth.Caption := GetLangStr('ProxyAuth');
  LProxyUser.Caption := GetLangStr('ProxyUser');
  LProxyUserPasswd.Caption := GetLangStr('ProxyUserPasswd');
  EProxyAddress.Left := LProxyAddress.Left + LProxyAddress.Width + 5;
  LProxyPort.Left := EProxyAddress.Left + EProxyAddress.Width + 5;
  EProxyPort.Left := LProxyPort.Left + LProxyPort.Width + 5;
  GBUpdater.Caption := GetLangStr('Update');
  LStatus.Caption := GetLangStr(LStatus.Hint);
  LAmountDesc.Caption := GetLangStr('Amount');
  LSpeedDesc.Caption := GetLangStr('Speed');
  LFileNameDesc.Caption := GetLangStr('FileName');
  LFileDesc.Caption := GetLangStr('FileDesc');
  LAmount.Left := LAmountDesc.Left + LAmountDesc.Width + 5;
  LSpeed.Left := LSpeedDesc.Left + LSpeedDesc.Width + 5;
  LFileName.Left := LFileNameDesc.Left + LFileNameDesc.Width + 5;
  LFileDescription.Left := LFileDesc.Left + LFileDesc.Width + 5;
  if ButtonSettings.Enabled then
  begin
    LFileName.Caption := GetLangStr('Unknown');
    LFileDescription.Caption := GetLangStr('Unknown');
    LFileMD5.Caption := GetLangStr('Unknown');
  end;
end;

function TMainForm.EndTask(TaskName, FormName: String): Boolean;
begin
  Result := False;
  if IsProcessRun(TaskName, FormName) then
  begin
    LogMemo.Lines.Add(Format(GetLangStr('InMemoryFoundProcess'), [TaskName, IntToStr(GetProcessID(TaskName))]));
    LogMemo.Lines.Add(GetLangStr('SendExitCommand'));
    OnSendMessageToOneComponent(FormName, '009');
    Sleep(1200);
    LogMemo.Lines.Add(Format(GetLangStr('SearchProcessInMemory'), [TaskName]));
    if IsProcessRun(TaskName, FormName) then
    begin
      LogMemo.Lines.Add(Format(GetLangStr('InMemoryFoundProcess'), [TaskName, IntToStr(GetProcessID(TaskName))]));
      LogMemo.Lines.Add(Format(GetLangStr('KillProcess'), [TaskName]));
      if KillTask(TaskName, FormName) = 1 then
      begin
        LogMemo.Lines.Add(Format(GetLangStr('KillProcessDone'), [TaskName]));
        Result := True;
      end
      else
      begin
        if Global_IMProcessPID <> 0 then
        begin
          LogMemo.Lines.Add(Format(GetLangStr('NotKillProcess'), [TaskName]));
          LogMemo.Lines.Add(Format(GetLangStr('SeDebugPrivilege'), [TaskName]));
          if ProcessTerminate(Global_IMProcessPID) then
          begin
            LogMemo.Lines.Add(Format(GetLangStr('SeDebugPrivilegeDone'), [TaskName]));
            Result := True;
          end
          else
          begin
            LogMemo.Lines.Add(Format(GetLangStr('NotKillSeDebugPrivilege'), [TaskName]));
            Result := False;
          end;
        end;
      end;
    end
    else
    begin
      LogMemo.Lines.Add(Format(GetLangStr('InMemoryNotFoundProcess'), [TaskName]));
      Result := True;
    end;
  end
  else
  begin
    LogMemo.Lines.Add(Format(GetLangStr('InMemoryNotFoundProcess'), [TaskName]));
    Result := True;
  end;
end;

{ ����� ����������� ������ �� ������� �� ������� WM_COPYDATA }
procedure TMainForm.OnControlReq(var Msg : TWMCopyData);
var
  ControlStr, EncryptControlStr: String;
  copyDataType : TCopyDataType;
  GotChars: Integer;
begin
  copyDataType := TCopyDataType(Msg.CopyDataStruct.dwData);
  if copyDataType = cdtString then
  begin
    GotChars := Msg.CopyDataStruct.cbData div SizeOf(Char);
    SetLength(EncryptControlStr, GotChars);
    Move(Msg.CopyDataStruct.lpData^, PChar(EncryptControlStr)^, GotChars * sizeof(Char));
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnControlReq: �������� ����������� ����������� ���������: ' + EncryptControlStr, 1);
    ControlStr := DecryptStr(EncryptControlStr);
    if EnableDebug then WriteInLog(ProfilePath, FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ' - ��������� OnControlReq: ����������� ��������� ������������: ' + ControlStr, 1);
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
    end;
    // 004 - ����� ����-����
    if ControlStr = '0040' then // �������� �����
      AntiBoss(False);
    if ControlStr = '0041' then // ������ �����
      AntiBoss(True);
    // 003 - ����� �� ���������
    {if (ControlStr = '003') and (ButtonUpdate.Enabled) then
      Close;}
    // 009 - ���������� ����� �� ���������
    if ControlStr = '009' then
    begin
      IMDownloader1.BreakDownload;
      Close;
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
    //ShowWindow(AboutForm.Handle, SW_HIDE);
    //AboutForm.Hide;
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
    {if Global_AboutForm_Showing then
    begin
      ShowWindow(AboutForm.Handle, SW_SHOW);
      AboutForm.Show;
    end;}
  end;
end;

procedure TMainForm.RunIMClient(IMClientName: String; IMProcessArray: TProcessInfoArray);
var
  i: Integer;
begin
  for i := Low(IMProcessArray) to High(IMProcessArray) do
  begin
    if LowerCase(IMClientName) = LowerCase(IMProcessArray[i].ProcessName) then
    begin
      if FileExists(IMProcessArray[i].ProcessPath) then
      begin
        LogMemo.Lines.Add(Format(GetLangStr('StartProgram'), [IMProcessArray[i].ProcessPath + IMProcessArray[i].ProcessParamCmd]));
        ShellExecute(0, 'open', PWideChar(IMProcessArray[i].ProcessPath), PWideChar(' '+IMProcessArray[i].ProcessParamCmd), nil, SW_SHOWNORMAL);
        Sleep(500);
        if IsProcessRun(IMProcessArray[i].ProcessName) then
          LogMemo.Lines.Add(Format(GetLangStr('StartProgramDone'), [IMProcessArray[i].ProcessPath]))
        else
          LogMemo.Lines.Add(Format(GetLangStr('StartProgramFail'), [IMProcessArray[i].ProcessPath]));
      end;
    end;
  end;
end;

procedure TMainForm.RunAllIMClients;
begin
  if IMClientType = 'QIP' then
    RunIMClient('qip.exe', QIPProcessInfo);
  if (IMClientType = 'Miranda') or (IMClientType = 'MirandaNG') then
    {$IfDef WIN32}
    RunIMClient('miranda32.exe', MirandaProcessInfo);
    {$Else}
    RunIMClient('miranda64.exe', MirandaProcessInfo);
    {$EndIf}
  if IMClientType = 'RnQ' then
  begin
    RunIMClient('R&Q.exe', RnQProcessInfo);
    RunIMClient('rnq.exe', RnQProcessInfo);
  end;
  if IMClientType = 'Skype' then
  begin
    if SystemLang = 'Russian' then
    begin
      if FileExists(PluginPath + 'installupdater-ru.cmd') then
        ShellExecute(0, 'open', PWideChar(PluginPath + 'installupdater-ru.cmd'), nil, nil, SW_HIDE)
      else
        RunIMClient('skype.exe', SkypeProcessInfo);
    end
    else
    begin
      if FileExists(PluginPath + 'installupdater-en.cmd') then
        ShellExecute(0, 'open', PWideChar(PluginPath + 'installupdater-en.cmd'), nil, nil, SW_HIDE)
      else
        RunIMClient('skype.exe', SkypeProcessInfo);
    end;
  end;
  // ������ Dropbox
  {if not IsProcessRun('Dropbox.exe') then
    RunIMClient('Dropbox.exe', DropboxProcessInfo);}
end;

end.
