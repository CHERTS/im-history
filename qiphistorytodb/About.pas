{ ############################################################################ }
{ #                                                                          # }
{ #  QIP HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit About;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellAPI, Global;

type
  TAboutForm = class(TForm)
    AboutImage: TImage;
    BAbout: TBevel;
    CloseButton: TButton;
    LProgramName: TLabel;
    LCopyright: TLabel;
    LabelAuthor: TLabel;
    LVersion: TLabel;
    LLicense: TLabel;
    LWeb: TLabel;
    LabelWebSite: TLabel;
    LVersionNum: TLabel;
    LLicenseType: TLabel;
    Bevel1: TBevel;
    LThankYou: TLabel;
    MemoThankYou: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CloseButtonClick(Sender: TObject);
    procedure LabelAuthorClick(Sender: TObject);
    procedure LabelWebSiteClick(Sender: TObject);
    procedure MemoThankYouEnter(Sender: TObject);
  private
    { Private declarations }
    // ��� �������������� ���������
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}
{$R icons.res}

procedure TAboutForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ���������� ��� ������ ����-����
  Global_AboutForm_Showing := false;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  AboutBitmap: TBitmap;
begin
  // ��� �������������� ���������
  AboutFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // ������ ������� ������ �� ����� ��������
  AboutBitmap := TBitmap.Create;
  try
    AboutBitmap.LoadFromResourceName(HInstance, 'About');
    AboutImage.Picture.Assign(AboutBitmap);
  finally
    AboutBitmap.Free;
  end;
  LabelAuthor.Cursor := crHandPoint;
  LabelWebSite.Cursor := crHandPoint;
  // ��������� ���� ����������
  LoadLanguageStrings;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  // ���������� ��� ������ ����-����
  Global_AboutForm_Showing := True;
  // ��������� ������ � ���� "� �������"
  LVersionNum.Caption := PlugCheck_Ver;
end;

procedure TAboutForm.LabelAuthorClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'mailto:sleuthhound@gmail.com', nil, nil, SW_RESTORE);
end;

procedure TAboutForm.LabelWebSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.im-history.ru', nil, nil, SW_RESTORE);
end;

// ����-��� ��� ������� ��������� � Memo :-D
procedure TAboutForm.MemoThankYouEnter(Sender: TObject);
begin
  CloseButton.SetFocus;
end;

// ��� �������������� ���������
procedure TAboutForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

// ��� �������������� ���������
procedure TAboutForm.LoadLanguageStrings;
begin
  Caption := GetLangStr('AboutFormCaption');
  CloseButton.Caption := GetLangStr('CloseButton');
  LVersion.Caption := GetLangStr('Version');
  LLicense.Caption := GetLangStr('License');
  LProgramName.Caption := PluginName;
  // ������������� ������
  LVersionNum.Left := LVersion.Left + 1 + LVersion.Width;
  LLicenseType.Left := LLicense.Left + 1 + LLicense.Width;
  // �������������
  LThankYou.Caption := GetLangStr('LThankYou');
  MemoThankYou.Clear;
  if CoreLanguage = 'Russian' then
    MemoThankYou.Text := ThankYouText_Rus
  else
    MemoThankYou.Text := ThankYouText_Eng;
  // End
end;

end.
 
