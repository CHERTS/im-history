unit DownLoaderTestUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uIMDownLoader, StdCtrls, ToolWin, ComCtrls, Menus;

type
  TMainForm = class(TForm)
    IMDownloader_Demo: TIMDownloader;
    Edit1: TEdit;
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    RichEdit1: TRichEdit;
    SaveDialog1: TSaveDialog;
    TBDownload: TToolButton;
    TBStopDownload: TToolButton;
    TBView: TToolButton;
    ViewAsTest: TMenuItem;
    SaveToFile: TMenuItem;
    PopupMenu1: TPopupMenu;
    ProgressBar1: TProgressBar;
    procedure FormShow(Sender: TObject);
    procedure IMDownloader_DemoError(Sender: TObject; E: TIMDownLoadError);
    procedure IMDownloader_DemoAccepted(Sender: TObject);
    procedure IMDownloader_DemoStartDownload(Sender: TObject);
    procedure IMDownloader_DemoBreak(Sender: TObject);
    procedure ViewAsTestClick(Sender: TObject);
    procedure SaveToFileClick(Sender: TObject);
    procedure TBDownloadClick(Sender: TObject);
    procedure TBStopDownloadClick(Sender: TObject);
    procedure TBViewClick(Sender: TObject);
    procedure IMDownloader_DemoDownloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
    procedure IMDownloader_DemoHeaders(Sender: TObject; Headers: string);
    procedure IMDownloader_DemoMD5Checked(Sender: TObject; MD5Correct,
      SizeCorrect: Boolean; MD5Str: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
  end;

var
  MainForm: TMainForm;

const
  uURL = 'http://im-history.ru/update/get.php?file=HistoryToDB-Update';

implementation

{$R *.dfm}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DirectoryExists(IMDownloader_Demo.SaveDirPath) then
    FullRemoveDir(IMDownloader_Demo.SaveDirPath, True, True, True);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Edit1.Text := uURL;
  IMDownloader_Demo.DirPath := ExtractFilePath(Application.ExeName);
  IMDownloader_Demo.SaveDirPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))+'temp\';
  if not DirectoryExists(IMDownloader_Demo.SaveDirPath) then
    CreateDir(IMDownloader_Demo.SaveDirPath);
end;

procedure TMainForm.IMDownloader_DemoAccepted(Sender: TObject);
begin
  ProgressBar1.Visible := False;
  TBStopDownload.Visible := false;
  TBDownload.Visible := true;
  TBView.Visible := true;
  Edit1.ReadOnly := false;
  StatusBar1.SimpleText :=
    '���������� ������� ���������. ����� �������� ������ � ������: ' + IntToStr
    (IMDownloader_Demo.AcceptedSize);
  //RichEdit1.Lines.Append('MD5 ����� � ������: '+MD5DigestToStr(MD5Stream(IMDownloader_Demo.OutStream)));
end;

procedure TMainForm.IMDownloader_DemoBreak(Sender: TObject);
begin
  ProgressBar1.Visible := False;
  TBStopDownload.Visible := False;
  TBStopDownload.Enabled := True;
  TBDownload.Visible := True;
  TBView.Visible := IMDownloader_Demo.AcceptedSize > 0;
  Edit1.ReadOnly := False;
  StatusBar1.SimpleText :=
    '���������� �����������. ����� �������� ������ � ������: ' + IntToStr
    (IMDownloader_Demo.AcceptedSize);
end;

procedure TMainForm.IMDownloader_DemoDownloading(Sender: TObject; AcceptedSize,
  MaxSize: Cardinal);
begin
  StatusBar1.SimpleText := '�������� ����: ' + IntToStr(AcceptedSize);
  ProgressBar1.Visible := MaxSize > AcceptedSize;
  ProgressBar1.Max := MaxSize;
  ProgressBar1.Position := AcceptedSize;
end;

procedure TMainForm.IMDownloader_DemoError(Sender: TObject; E: TIMDownLoadError);
var
  s: string;
begin
  ProgressBar1.Visible := False;
  TBStopDownload.Visible := false;
  TBDownload.Visible := True;
  TBView.Visible := IMDownloader_Demo.AcceptedSize > 0;
  Edit1.ReadOnly := False;
  case E of
    deInternetOpen: s := '������ ��� �������� ������. ';
    deInternetOpenUrl: s := '������ ��� ������������ �����. ';
    deDownloadingFile: s := '������ ��� ������ �����. ';
    deRequest: s := '������ ��� ������� ������ ����� ������-������. ';
  end;
  StatusBar1.SimpleText :=
    s + '����� �������� ������ � ������: ' + IntToStr
    (IMDownloader_Demo.AcceptedSize);
end;

procedure TMainForm.IMDownloader_DemoHeaders(Sender: TObject; Headers: string);
begin
  RichEdit1.Lines.Text := Headers;
end;

procedure TMainForm.IMDownloader_DemoMD5Checked(Sender: TObject; MD5Correct,
  SizeCorrect: Boolean; MD5Str: string);
begin
  if MD5Correct then
    RichEdit1.Lines.Append('����������� ����� MD5 = '+MD5Str+' - �����!')
  else
    RichEdit1.Lines.Append('����������� ����� MD5 = '+MD5Str+' - �� �����!');
  if SizeCorrect then
    RichEdit1.Lines.Append('������ ����� = '+IntToStr(IMDownloader_Demo.AcceptedSize)+' - ������!')
  else
    RichEdit1.Lines.Append('������ ����� = '+IntToStr(IMDownloader_Demo.AcceptedSize)+' - �� ������!');
end;

procedure TMainForm.IMDownloader_DemoStartDownload(Sender: TObject);
begin
  TBDownload.Visible := False;
  TBStopDownload.Visible := True;
  TBView.Visible := False;
  Edit1.ReadOnly := True;
  StatusBar1.SimpleText := '������������� ����������...';
end;

procedure TMainForm.ViewAsTestClick(Sender: TObject);
begin
  RichEdit1.Lines.LoadFromStream(IMDownloader_Demo.OutStream);
end;

procedure TMainForm.SaveToFileClick(Sender: TObject);
begin
  if Edit1.Text = uURL then
    SaveDialog1.FileName := 'HistoryToDBCreateDB.rar';
  if SaveDialog1.Execute then
    IMDownloader_Demo.OutStream.SaveToFile(SaveDialog1.FileName);
end;

procedure TMainForm.TBDownloadClick(Sender: TObject);
begin
  IMDownloader_Demo.URL := Edit1.Text;
  //IMDownloader_Demo.Proxy := '192.168.42.240:1522';
  //IMDownloader_Demo.Proxy := '172.29.72.168:8080';
  IMDownloader_Demo.Download;
end;

procedure TMainForm.TBStopDownloadClick(Sender: TObject);
begin
  StatusBar1.SimpleText := '������������� ������';
  TBStopDownload.Enabled := False;
  IMDownloader_Demo.BreakDownload;
end;

procedure TMainForm.TBViewClick(Sender: TObject);
begin
  TBView.DropdownMenu.Popup(TBView.ClientOrigin.X,
    TBView.ClientOrigin.Y + TBView.Height);
end;

{ �������� ��������� �������� ������ � �������������

�������� ������������ ����������� - ������� �������� ���� ����.
�������� ���������� ����������:

-DeleteAllFilesAndFolder - ���� TRUE �� �������� ����� �����������
������� ��� ��������� �������� faArchive ������ ����� ��� �����
����� ���(�) ���������;

-StopIfNotAllDeleted - ���� TRUE �� ������ ������� �����������
������������ ���� �������� ������ �������� ���� �� ������ ����� ��� �����;

-RemoveRoot - ���� TRUE, ��������� �� ������������� �������� �����.

�����������: FileCtrl, SysUtils
�����:       lipskiy, lipskiy@mail.ru, ICQ:51219290, �����-���������
Copyright:   ����������� ��������� (lipskiy)
����:        26 ������ 2002 �.

������ �������������:
FullRemoveDir('C:\a', true, true, true);
}
function TMainForm.FullRemoveDir(Dir: String; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: Boolean): Boolean;
var
  i: Integer;
  SRec: TSearchRec;
  FN: string;
begin
  Result := False;
  if not DirectoryExists(Dir) then
    exit;
  Result := True;
  // ��������� ���� � ����� � ������ ����� - "��� ����� � ����������"
  Dir := IncludeTrailingBackslash(Dir);
  i := FindFirst(Dir + '*', faAnyFile, SRec);
  try
    while i = 0 do
    begin
      // �������� ������ ���� � ����� ��� ����������
      FN := Dir + SRec.Name;
      // ���� ��� ����������
      if SRec.Attr = faDirectory then
      begin
        // ����������� ����� ���� �� ������� � ������ �������� �����
        if (SRec.Name <> '') and (SRec.Name <> '.') and (SRec.Name <> '..') then
        begin
          if DeleteAllFilesAndFolders then
            FileSetAttr(FN, faArchive);
          Result := FullRemoveDir(FN, DeleteAllFilesAndFolders,
            StopIfNotAllDeleted, True);
          if not Result and StopIfNotAllDeleted then
            exit;
        end;
      end
      else // ����� ������� ����
      begin
        if DeleteAllFilesAndFolders then
          FileSetAttr(FN, faArchive);
        Result := SysUtils.DeleteFile(FN);
        if not Result and StopIfNotAllDeleted then
          exit;
      end;
      // ����� ��������� ���� ��� ����������
      i := FindNext(SRec);
    end;
  finally
    SysUtils.FindClose(SRec);
  end;
  if not Result then
    exit;
  if RemoveRoot then // ���� ���������� ������� ������ - �������
    if not RemoveDir(Dir) then
      Result := false;
end;

end.
