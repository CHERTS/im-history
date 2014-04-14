{ ################################################################################ }
{ #                                                                              # }
{ #  MirandaNG HistoryToDB Plugin v2.6                                           # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

{ ################################################################################ }
{ #                                                                              # }
{ # History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*  # }
{ #                                                                              # }
{ # Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.                     # }
{ # History+ parts (C) 2001 Christian Kastner                                    # }
{ #                                                                              # }
{ # This program is free software; you can redistribute it and/or modify         # }
{ # it under the terms of the GNU General Public License as published by         # }
{ # the Free Software Foundation; either version 2 of the License, or            # }
{ # (at your option) any later version.                                          # }
{ #                                                                              # }
{ # This program is distributed in the hope that it will be useful,              # }
{ # but WITHOUT ANY WARRANTY; without even the implied warranty of               # }
{ # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                # }
{ # GNU General Public License for more details.                                 # }
{ #                                                                              # }
{ # You should have received a copy of the GNU General Public License            # }
{ # along with this program; if not, write to the Free Software                  # }
{ # Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA    # }
{ #                                                                              # }
{ ################################################################################ }

unit Srmm;

interface

uses m_api, windows, global;

var
  HookButtonsBarLoaded: THandle;
  HookButtonsBarPressed: THandle;

procedure InitSRMM;
procedure DeinitSRMM;
procedure AddTabBBButton;
procedure DeleteTabBBButton;
function OnButtonsBarLoaded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
function OnButtonsBarPressed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;

implementation

procedure InitSRMM;
begin
  HookButtonsBarLoaded := HookEvent(ME_MSG_TOOLBARLOADED, OnButtonsBarLoaded);
	HookButtonsBarPressed := HookEvent(ME_MSG_BUTTONPRESSED, OnButtonsBarPressed);
end;

procedure DeinitSRMM;
begin
  //if ShowPluginButton then
  //  DeleteTabBBButton;
  UnhookEvent(HookButtonsBarLoaded);
  UnhookEvent(HookButtonsBarPressed);
end;

procedure AddTabBBButton;
var
  HisButton: tBBButton;
begin
  if ShowPluginButton then
  begin
    FillChar(HisButton, SizeOf(HisButton), 0);
		HisButton.cbSize := SizeOf(HisButton);
		HisButton.dwButtonID := 0;
		HisButton.pszModuleName := htdPluginShortName;
		HisButton.dwDefPos := 200;
    HisButton.iButtonWidth := 0;
		//HisButton.bbbFlags := BBBF_ISRSIDEBUTTON or BBBF_CANBEHIDDEN or BBBF_ISIMBUTTON;
    HisButton.bbbFlags := BBBF_ISIMBUTTON or BBBF_ISLSIDEBUTTON or BBBF_ISCHATBUTTON or BBBF_ISPUSHBUTTON;
		HisButton.szTooltip.a := pAnsiChar(WideStringToString(GetLangStr('ShowOneContactHistory'), CP_ACP));
		HisButton.hIcon := LoadImage(hInstance,'ICON_0',IMAGE_ICON,16,16,0);
    CallService(MS_BB_ADDBUTTON, 0, LPARAM(@HisButton));
  end;
end;

procedure DeleteTabBBButton;
var
  HisButton: tBBButton;
begin
  FillChar(HisButton, SizeOf(HisButton), 0);
  HisButton.cbSize := SizeOf(HisButton);
  HisButton.dwButtonID := 0;
  HisButton.pszModuleName := htdPluginShortName;
  CallService(MS_BB_REMOVEBUTTON, 0, LPARAM(@HisButton));
end;

function OnButtonsBarLoaded(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  AddTabBBButton;
  Result := 0;
end;

function OnButtonsBarPressed(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  Result := 0;
end;

end.
