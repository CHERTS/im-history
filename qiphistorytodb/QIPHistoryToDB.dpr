{ ############################################################################ }
{ #                                                                          # }
{ #  QIP HistoryToDB Plugin v2.4                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

library QIPHistoryToDB;

uses
  u_qip_plugin in 'u_qip_plugin.pas',
  u_common in 'SDK\u_common.pas',
  u_plugin_info in 'SDK\u_plugin_info.pas',
  u_plugin_msg in 'SDK\u_plugin_msg.pas',
  Global in 'Global.pas',
  About in 'About.pas' {AboutForm},
  FSMonitor in 'FSMonitor.pas',
  MapStream in 'MapStream.pas';

//Создаём экспортируемую функцию в DLL
function CreateInfiumPLUGIN(PluginService: IQIPPluginService): IQIPPlugin; stdcall;
begin
  Result := TQipPlugin.Create(PluginService);
end;

exports
  CreateInfiumPLUGIN name 'CreateInfiumPLUGIN';
end.

