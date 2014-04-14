program HistoryToDBCreateDB;

uses
  {$IFDEF DEBUG}
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$ENDIF}
  Forms,
  Main in 'Main.pas' {MainForm},
  Global in 'Global.pas',
  About in 'About.pas' {AboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HistoryToDBCreateDB';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
