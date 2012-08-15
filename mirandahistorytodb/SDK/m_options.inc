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

{$IFNDEF M_OPTIONS}
{$DEFINE M_OPTIONS}

{$include m_system.inc}

const
  {
    wParam : addinfo
    lParam : 0
    Affects: The user opened the options dialog, see notes
    Notes  : Modules should do whatever initalisation they need and call
             MS_OPT_ADDPAGE with the wParam -- MS_OPT_ADDPAGE
             can be called one or more times
             if more than one page wants to be displayed.
  }
  ME_OPT_INITIALISE       = 'Opt/Initialise';

type
  POPTIONSDIALOGPAGE = ^TOPTIONSDIALOGPAGE;
  TOPTIONSDIALOGPAGE = record
    cbSize: Integer;
    position: Integer;               // position number, lower numbers are top most
    pszTitle: TChar;
    pfnDlgProc: Pointer;             // DLGPROC prototype
    pszTemplate: PAnsiChar;
    hInstance: THandle;
    hIcon: THandle;                  // v0.1.0.1+
    pszGroup: TChar;                 // v0.1.0.1+
    groupPosition: Integer;          // v0.1.0.1+
    hGroupIcon: THandle;             // v0.1.0.1+
    flags: DWORD;                    // v0.1.2.1+
    nIDBottomSimpleControl: Integer; // v0.1.2.1+  if in simple mode the dlg will be cut off after this control, 0 to disable
    nIDRightSimpleControl: Integer;  // v0.1.2.1+  if in simple mode the dlg will be cut off after this control, 0 to disable
    expertOnlyControls: PInteger;
    nExpertOnlyControls: Integer;    // //v0.1.2.1+  these controls will be hidden in simple mode. Array must remain valid for duration of dlg.
    {$IF MIRANDA_VER >= $0600}
    pszTab: TChar;
    {$IFEND}
  end;

const
  OPTIONPAGE_OLD_SIZE  = 40;
  OPTIONPAGE_OLD_SIZE2 = 60;

  ODPF_SIMPLEONLY = 1;  // page is only shown when in simple mode
  ODPF_EXPERTONLY = 2;  // page is only shown when in expert mode
  ODPF_BOLDGROUPS = 4;  // give group box titles a bold font
  ODPF_UNICODE    = 8;  // string fields in OPTIONSDIALOGPAGE are WCHAR*
  {$IFDEF _UNICODE}
  ODPF_TCHAR      = ODPF_UNICODE;
  {$ELSE}
  ODPF_TCHAR      = 0;
  {$ENDIF}

  PSN_EXPERTCHANGED = 2;            //sent to pages via WM_NOTIFY when the expert checkbox is clicked. lParam=new state
  PSM_ISEXPERT      = ($0400+101);  //returns true/false
  PSM_GETBOLDFONT   = ($0400+102);  //returns HFONT used for group box titles

  {
    wParam : wParam from ME_OPT_INITIALISE
    lParam : Pointer to an initialised TOPTIONSDIALOGPAGE
    Affects: Adds a page to the options dialog, see notes
    Notes  : Strings in the structure can be released as soon as the
             service returns -- but icons must be kept around, this iss
             not a problem if you're loading theem from a resource.
             -
             This service should only be called within the ME_OPT_INITIALISE
             event hook.
             -
             Pages in the options dialog operate just like pages in property
             sheets, See the WinAPI documentation for details on how they operate.
    Version: Prior to v0.1.2.1 the options dialog would resize
             to fit the largest page, but since then it's a fixed size
             The largest page that fits neatly is 314x240 DLU's
             -
             Some of OPTIONSDIALOGPAGE's fields are version dependant.
  }
  MS_OPT_ADDPAGE          = 'Opt/AddPage';

type
  POPENOPTIONSDIALOG = ^TOPENOPTIONSDIALOG;
  TOPENOPTIONSDIALOG = record
    cbSize: Integer;
    pszGroup: TChar;  //set to NULL if it's a root item
    pszPage: TChar;   //set to NULL to just open the options at no specific page
    pszTab: TChar;    //set to NULL to just open the options at no specific tab
  end;

const
  SETTING_SHOWEXPERT_DEFAULT = 1;

  {
    wParam : 0
    lParam : Pointer to an initialised TOPTIONSDIALOGPAGE
    Affects: Opens the options dialog, optionally at the specified page
    Notes  : The behaviour if the options dialog is already open is that it will
             just be activated, the page won't be changed. This may change in the future.
    Varsion: v0.1.2.1+
  }
  MS_OPT_OPENOPTIONS = 'Opt/OpenOptions';

{$ENDIF}