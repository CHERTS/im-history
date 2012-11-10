{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBCreateDB v2.0                               # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit About;

interface

uses Windows, Messages, SysUtils, Classes, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellAPI, Global;

type
  TAboutForm = class(TForm)
    Bevel1: TBevel;
    LProgramName: TLabel;
    Label2: TLabel;
    LabelAuthor: TLabel;
    LVersion: TLabel;
    LLicense: TLabel;
    Label6: TLabel;
    LabelWebSite: TLabel;
    LVersionNum: TLabel;
    LLicenseType: TLabel;
    CloseButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure LabelAuthorClick(Sender: TObject);
    procedure LabelWebSiteClick(Sender: TObject);
  private
    { Private declarations }
    // Для мультиязыковой поддержки
    procedure OnLanguageChanged(var Msg: TMessage); message WM_LANGUAGECHANGED;
    procedure LoadLanguageStrings;
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  // Для мультиязыковой поддержки
  AboutFormHandle := Handle;
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  // Настройки курсора
  LabelAuthor.Cursor := crHandPoint;
  LabelWebSite.Cursor := crHandPoint;
  // Загружаем язык интерфейса
  LoadLanguageStrings;
  // Указываем версию в окне "О плагине"
  LVersionNum.Caption := ProgramsVer + ' ' + PlatformType;
  // Позиционируем лейблы
  LVersionNum.Left := LVersion.Left + 1 + LVersion.Width;
  LLicenseType.Left := LLicense.Left + 1 + LLicense.Width;
end;

procedure TAboutForm.LabelAuthorClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'mailto:sleuthhound@gmail.com', nil, nil, SW_RESTORE);
end;

procedure TAboutForm.LabelWebSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.im-history.ru', nil, nil, SW_RESTORE);
end;

{ Смена языка интерфейса по событию WM_LANGUAGECHANGED }
procedure TAboutForm.OnLanguageChanged(var Msg: TMessage);
begin
  LoadLanguageStrings;
end;

{ Для мультиязыковой поддержки }
procedure TAboutForm.LoadLanguageStrings;
begin
  Caption := GetLangStr('AboutFormCaption');
  LProgramName.Caption := ProgramsName;
  CloseButton.Caption := GetLangStr('CloseButton');
  LVersion.Caption := GetLangStr('Version');
  LLicense.Caption := GetLangStr('License');
  // Позиционируем лейблы
  LVersionNum.Left := LVersion.Left + 1 + LVersion.Width;
  LLicenseType.Left := LLicense.Left + 1 + LLicense.Width;
end;

end.
 
