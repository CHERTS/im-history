{ ############################################################################ }
{ #                                                                          # }
{ #  Импорт истории HistoryToDBSync v2.4                                     # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

program HistoryToDBSync;

uses
  Forms,
  Main in 'Main.pas' {MainSyncForm},
  Global in 'Global.pas',
  About in 'About.pas' {AboutForm},
  Log in 'Log.pas' {LogForm},
  KeyPasswd in 'KeyPasswd.pas' {KeyPasswdForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HistoryToDBSync';
  Application.CreateForm(TMainSyncForm, MainSyncForm);
  if MainSyncForm.RunAppDone then
  begin
    Application.CreateForm(TAboutForm, AboutForm);
    Application.CreateForm(TLogForm, LogForm);
    Application.CreateForm(TKeyPasswdForm, KeyPasswdForm);
    Application.Run;
  end;
end.
