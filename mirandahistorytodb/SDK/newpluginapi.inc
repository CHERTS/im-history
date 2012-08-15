(*

Miranda IM: the free IM client for Microsoft* Windows*

Copyright 2000-2007 Miranda ICQ/IM project, 
all portions of this codebase are copyrighted to the people 
listed in contributors.txt.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*)

{$IFNDEF M_NEWPLUGINAPI}
{$DEFINE M_NEWPLUGINAPI}

const
  MAXMODULELABELLENGTH  = 64;
  UNICODE_AWARE         = 1;

type
  PPLUGININFO = ^TPLUGININFO;
  TPLUGININFO = record
    cbSize: Integer;
    shortName: PAnsiChar;
    version: DWORD;
    description: PAnsiChar;
    author: PAnsiChar;
    authorEmail: PAnsiChar;
    copyright: PAnsiChar;
    homepage: PAnsiChar;
    flags: Byte;      // right now the only flag, UNICODE_AWARE, is recognized here
    replacesDefaultModule: Integer; //one of the DEFMOD_ constants in m_plugins.inc or zero
                      //if non-zero, this will supress the loading of the specified built-in module
                      //with the implication that this plugin provides back-end-compatible features
  end;

{ 0.7+
    New plugin loader implementation
}

{ The UUID structure below is used to for plugin UUID's and module type definitions }
type
  PMUUID = PGUID;
  TMUUID = TGUID;

const
  { Used to define the end of the MirandaPluginInterface list }
  MIID_LAST         = '{00000000-0000-0000-0000-000000000000}';

  { Replaceable internal modules interface ids }
  MIID_HISTORY      = '{5CA0CBC1-999A-4EA2-8B44-F8F67D7F8EBE}';
  MIID_UIFINDADD    = '{B22C528D-6852-48EB-A294-0E26A9161213}';
  MIID_UIUSERINFO   = '{570B931C-9AF8-48F1-AD9F-C4498C618A77}';
  MIID_SRURL        = '{5192445C-F5E8-46C0-8F9E-2B6D43E5C753}';
  MIID_SRAUTH       = '{377780B9-2B3B-405B-9F36-B3C4878E6F33}';
  MIID_SRAWAY       = '{5AB54C76-1B4C-4A00-B404-48CBEA5FEFE7}';
  MIID_SREMAIL      = '{D005B5A6-1B66-445A-B603-74D4D4552DE2}';
  MIID_SRFILE       = '{989D104D-ACB7-4EE0-B96D-67CE4653B695}';
  MIID_UIHELP       = '{F2D35C3C-861A-4CC3-A78F-D1F7850441CB}';
  MIID_UIHISTORY    = '{7F7E3D98-CE1F-4962-8284-968550F1D3D9}';
  MIID_AUTOAWAY     = '{9C87F7DC-3BD7-4983-B7FB-B848FDBC91F0}';
  MIID_USERONLINE   = '{130829E0-2463-4FF8-BBC8-CE73C0188442}';
  MIID_IDLE         = '{296F9F3B-5B6F-40E5-8FB0-A6496C18BF0A}';
  MIID_FONTSERVICE  = '{56F39112-E37F-4234-A9E6-7A811745C175}';
  MIID_UPDATENOTIFY = '{4E68B12A-6B54-44DE-8637-F1120DB68140}';

{ Common plugin interfaces (core plugins) }
  MIID_DATABASE     = '{AE77FD33-E484-4DC7-8CBC-099FEDCCCFDD}';
  MIID_CLIST        = '{9D8DA8BF-665B-4908-9E61-9F7598AE330E}';
  MIID_CHAT         = '{23576A43-3A26-4357-9B1B-4A719E425D48}';
  MIID_SRMM         = '{58C7EEA6-F9DB-4DD9-8036-AE802BC0414C}';
  MIID_IMPORT       = '{5F3BCAD4-75F8-476E-B36B-2B307032490C}';
  MIID_IMGSERVICES  = '{F3974915-C9D5-4C87-8564-A0EBF9D25AA0}';
  MIID_TESTPLUGIN   = '{53B974F4-3C74-4DBA-8FC2-6F92FE013B8C}';

{ Common plugin interfaces (non-core plugins) }
  MIID_VERSIONINFO    = '{CFEB6325-334E-4052-A645-562193DFCC77}';
  MIID_FOLDERS        = '{CFEBEC29-39EF-4B62-AD38-9A652CA324ED}';
  MIID_BIRTHDAYNOTIFY = '{CFBA5784-3701-4D83-816A-199C00D4A67A}';
  MIID_BONSAI         = '{CFAAE811-30E1-4A4F-8784-153CCCB0037A}';
  MIID_EXCHANGE       = '{CFD79A89-9959-4E65-B076-413F98FE0D15}';
  MIID_MIRPY          = '{CFF91A5C-1786-41C1-8886-094B14281F15}';
  MIID_SERVICESLIST   = '{CF4BDF02-5D27-4241-99E5-1951AAB0C454}';
  MIID_TRANSLATOR     = '{CFB637B0-7217-4C1E-B22A-D922323A5D0B}';
  MIID_TOOLTIPS       = '{BCBDA043-2716-4404-B0FA-3D2D93819E03}';
  MIID_POPUPS         = '{33299069-1919-4FF8-B131-1D072178A766}';
  MIID_LOGWINDOW      = '{C53AFB90-FA44-4304-BC9D-6A841C3905F5}';
  MIID_EVENTNOTIFY    = '{F3D7EC5A-F7EF-45DD-8CA5-B0F6BA18647B}';
  MIID_SRCONTACTS     = '{7CA6050E-BAF7-42D2-B936-0DB9DF572B95}';
  MIID_HISTORYEXPORT  = '{18FA2ADE-E31B-4B5D-953D-0AB25781C604}';

{ Special exception interface for protocols.
  This interface allows more than one plugin to implement it at the same time }
  MIID_PROTOCOL     = '{2A3C815E-A7D9-424B-BA30-02D083229085}';

type
  PPLUGININFOEX = ^TPLUGININFOEX;
  TPLUGININFOEX = record
    cbSize: Integer;
    shortName: PAnsiChar;
    version: DWORD;
    description: PAnsiChar;
    author: PAnsiChar;
    authorEmail: PAnsiChar;
    copyright: PAnsiChar;
    homepage: PAnsiChar;
    flags: Byte;      // right now the only flag, UNICODE_AWARE, is recognized here
    replacesDefaultModule: Integer; //one of the DEFMOD_ constants in m_plugins.inc or zero
                      //if non-zero, this will supress the loading of the specified built-in module
                      //with the implication that this plugin provides back-end-compatible features
                      //***********  WILL BE DEPRECATED in 0.8 * *************//
    uuid: TMUUID;     // Not required until 0.8.
  end;

  { modules.h is never defined -- no check needed }

  TMIRANDAHOOK = function(wParam: WPARAM; lParam: LPARAM): int; cdecl;
  TMIRANDASERVICE = function(wParam: WPARAM; lParam: LPARAM): int_ptr; cdecl;
  TMIRANDASERVICEPARAM = function(wParam: WPARAM; lParam, sParam: LPARAM): int_ptr; cdecl;

const
  CALLSERVICE_NOTFOUND = $80000000;

//see modules.h for what all this stuff is

type
  Pm_FunctionAsync = ^Tm_FunctionAsync;
  Tm_FunctionAsync = function (p: Pointer): Pointer;

  PPLUGINLINK = ^TPLUGINLINK;
  TPLUGINLINK = record
    CreateHookableEvent: function(const AnsiChar: PAnsiChar): THandle; cdecl;
    DestroyHookableEvent: function(Handle: THandle): Integer; cdecl;
    NotifyEventHooks: function(Handle: THandle; wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
    HookEvent: function(const AnsiChar: PAnsiChar; MIRANDAHOOK: TMIRANDAHOOK): THandle; cdecl;
    HookEventMessage: function(const AnsiChar: PAnsiChar; Wnd: THandle; wMsg: Integer): THandle; cdecl;
    UnhookEvent: function(Handle: THandle): Integer; cdecl;
    CreateServiceFunction: function(const AnsiChar: PAnsiChar; MIRANDASERVICE: TMIRANDASERVICE): THandle; cdecl;
    CreateTransientServiceFunction: function(const AnsiChar: PAnsiChar; MIRANDASERVICE: TMIRANDASERVICE): THandle; cdecl;
    DestroyServiceFunction: function(Handle: THandle): Integer; cdecl;
    CallService: function(const AnsiChar: PAnsiChar; wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
    ServiceExists: function(const AnsiChar: PAnsiChar): Integer; cdecl; // v0.1.0.1+
    CallServiceSync: function(const AnsiChar: PAnsiChar; wParam: WPARAM; lParam: LPARAM): Integer; cdecl; //v0.3.3+
    CallFunctionAsync: function(func: Pm_FunctionAsync; p: Pointer): Integer; cdecl; //v0.3.4+
    SetHookDefaultForHookableEvent: function(Handle: THandle; MIRANDAHOOK: TMIRANDAHOOK): Integer; cdecl; // v0.3.4 (2004/09/15)
    CreateServiceFunctionParam: function(const AnsiChar:PAnsiChar; MIRANDASERVICEPARAM: TMIRANDASERVICEPARAM; lParam: LPARAM): THandle; cdecl; // v0.7+ (2007/04/24)
    NotifyEventHooksDirect: function(Handle: THandle; wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
  end;

{
 Database plugin stuff
}

const
  // grokHeader() error codes
  EGROKPRF_NOERROR   = 0;
  EGROKPRF_CANTREAD  = 1;   // can't open the profile for reading
  EGROKPRF_UNKHEADER = 2;   // header not supported, not a supported profile
  EGROKPRF_VERNEWER  = 3;   // header correct, version in profile newer than reader/writer
  EGROKPRF_DAMAGED   = 4;   // header/version fine, other internal data missing, damaged.

  // makeDatabase() error codes
  EMKPRF_CREATEFAILED = 1;  // for some reason CreateFile() didnt like something

type
  PDATABASELINK = ^TDATABASELINK;
  TDATABASELINK = record
    cbSize: Integer;
    {
      returns what the driver can do given the flag
    }
    getCapability: function(flag: Integer): Integer; cdecl;

    {
      buf: pointer to a string buffer
      cch: length of buffer
      shortName: if true, the driver should return a short but descriptive name, e.g. "3.xx profile"
      Affect: The database plugin must return a "friendly name" into buf and not exceed cch bytes,
        e.g. "Database driver for 3.xx profiles"
      Returns: 0 on success, non zero on failure
    }
    getFriendlyName: function(const buff: PAnsiChar; cch: Integer; shortName: Integer): Integer; cdecl;

    {
      profile: pointer to a string which contains full path + name
      Affect: The database plugin should create the profile, the filepath will not exist at
        the time of this call, profile will be C:\..\<name>.dat
      Note: Do not prompt the user in anyway about this operation.
      Note: Do not initialise internal data structures at this point!
      Returns: 0 on success, non zero on failure - error contains extended error information, see EMKPRF_*
    }
    makeDatabase: function(const profile: PAnsiChar; error: PInteger): Integer; cdecl;

    {
      profile: [in] a null terminated string to file path of selected profile
      error: [in/out] pointer to an int to set with error if any
      Affect: Ask the database plugin if it supports the given profile, if it does it will
          return 0, if it doesnt return 1, with the error set in error -- EGROKPRF_* can be valid error
          condition, most common error would be [EGROKPRF_UNKHEADER]
      Note: Just because 1 is returned, doesnt mean the profile is not supported, the profile might be damaged
          etc.
      Returns: 0 on success, non zero on failure
    }
    grokHeader: function(const profile: PAnsiChar; error: PInteger): Integer; cdecl;

    {
      Affect: Tell the database to create all services/hooks that a 3.xx legecy database might support into link,
        which is a PLUGINLINK structure
      Returns: 0 on success, nonzero on failure
    }
    Load: function(const profile: PAnsiChar; link: PPLUGINLINK): Integer; cdecl;

    {
      Affect: The database plugin should shutdown, unloading things from the core and freeing internal structures
      Returns: 0 on success, nonzero on failure
      Note: Unload() might be called even if Load() was never called, wasLoaded is set to 1 if Load() was ever called.
    }
    Unload: function(wasLoaded: Integer): Integer; cdecl;
  end;

{$ENDIF}
