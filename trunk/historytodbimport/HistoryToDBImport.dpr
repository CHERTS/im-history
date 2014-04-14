{ ############################################################################ }
{ #                                                                          # }
{ #  Импорт истории HistoryToDBImport v2.4                                   # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

program HistoryToDBImport;

uses
  {$IFDEF DEBUG}
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$ENDIF}
  Forms,
  Global in 'Global.pas',
  Main in 'Main.pas' {MainForm};

{$R *.res}
{$I HistoryToDBImport.inc}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HistoryToDBImport';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
