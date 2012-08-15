{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBViewer v2.4                                 # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

program HistoryToDBViewer;

uses
  Forms,
  Global in 'Global.pas',
  Main in 'Main.pas' {MainForm},
  Settings in 'Settings.pas' {SettingsForm},
  KeyPasswd in 'KeyPasswd.pas' {KeyPasswdForm};

{$R *.res}
{$I HistoryToDBViewer.inc}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HistoryToDBViewer';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TKeyPasswdForm, KeyPasswdForm);
  Application.Run;
end.
