(*
Miranda plugin template, originally by Richard Hughes
http://miranda-icq.sourceforge.net/

This file is placed in the public domain. Anybody is free to use or
modify it as they wish with no restriction.
There is no warranty.
*)

library testdll;

uses
  m_globaldefs, m_api, Windows;

{$include m_helpers.inc}

// use it to make plugin compatible with pre 0.7 miranda builds
{.$DEFINE MIRANDA_PRE7_COMPABILITY}

// use it to make plugin unicode-aware
{$DEFINE UNICODE}

const
  piShortName   = 'Plugin Template';
  piDescription = 'The long description of your plugin, to go in the plugin options dialog';
  piAuthor      = 'J. Random Hacker';
  piAuthorEmail = 'noreply@sourceforge.net';
  piCopyright   = '(c) 2003 J. Random Hacker';
  piHomepage    = 'http://miranda-icq.sourceforge.net/';

const
  // Generate your own unique id for your plugin.
  // Do not use this UUID!
  // Use Shift+Ctrl+G or uuidgen.exe to generate the uuuid
  MIID_TESTDLL = '{08B86253-EC6E-4d09-B7A9-64ACDF0627B8}';

var
  {$IFDEF MIRANDA_PRE7_COMPABILITY}
  PluginInfo: TPLUGININFO = (
    cbSize: SizeOf(TPLUGININFO);
    shortName: piShortName;
    version: 0;
    description: piDescription;
    author: piAuthor;
    authorEmail: piAuthorEmail;
    copyright: piCopyright;
    homepage: piHomepage;
    flags: {$IFDEF UNICODE}UNICODE_AWARE{$ELSE}0{$ENDIF};
    replacesDefaultModule: 0;
  );
  {$ENDIF}

  PluginInfoEx: TPLUGININFOEX = (
    cbSize: SizeOf(TPLUGININFOEX);
    shortName: piShortName;
    version: 0;
    description: piDescription;
    author: piAuthor;
    authorEmail: piAuthorEmail;
    copyright: piCopyright;
    homepage: piHomepage;
    flags: {$IFDEF UNICODE}UNICODE_AWARE{$ELSE}0{$ENDIF};
    replacesDefaultModule: 0;
    uuid: MIID_TESTDLL;
  );

  PluginInterfaces: array[0..1] of TGUID = (
    MIID_TESTPLUGIN,
    MIID_LAST);

{$IFDEF MIRANDA_PRE7_COMPABILITY}
function MirandaPluginInfo(mirandaVersion: DWORD): PPLUGININFO; cdecl;
begin
  PluginInfo.version := PLUGIN_MAKE_VERSION(0,0,0,1);
  Result := @PluginInfo;
end;
{$ENDIF}

function MirandaPluginInfoEx(mirandaVersion:DWORD): PPLUGININFOEX; cdecl;
begin
  PluginInfoEx.version := PLUGIN_MAKE_VERSION(0,0,0,1);
  Result := @PluginInfoEx;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  Result := @PluginInterfaces;
end;

function PluginMenuCommand(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
  // this is called by Miranda, thus has to use the cdecl calling convention
  // all services and hooks need this.
  {$IFDEF UNICODE}
  MessageBoxW(0, 'Just groovy, baby!', 'Plugin-o-rama', MB_OK);
  {$ELSE}
  MessageBoxA(0, 'Just groovy, baby!', 'Plugin-o-rama', MB_OK);
  {$ENDIF}
end;

function Load(link: PPLUGINLINK): int; cdecl;
var
  mi: TCListMenuItem;
begin
  // this line is VERY VERY important, if it's not present, expect crashes.
  PluginLink := Pointer(link);
  PluginLink^.CreateServiceFunction('TestPlug/MenuCommand', @PluginMenuCommand);
  FillChar(mi, sizeof(mi), 0);
  mi.cbSize := sizeof(mi);
  mi.position := $7FFFFFFF;
  mi.flags := 0;
  mi.hIcon := LoadSkinnedIcon(SKINICON_OTHER_MIRANDA);
  mi.pszName := '&Test Plugin...';
  mi.pszService := 'TestPlug/MenuCommand';
  pluginLink^.CallService(MS_CLIST_ADDMAINMENUITEM, 0, lParam(@mi));
  Result := 0;
end;

function Unload: int; cdecl;
begin
  Result := 0;
end;

exports
  {$IFDEF MIRANDA_PRE7_COMPABILITY}
  MirandaPluginInfo,
  {$ENDIF}
  MirandaPluginInfoEx,
  MirandaPluginInterfaces,
  Load,
  Unload;

begin
end.
