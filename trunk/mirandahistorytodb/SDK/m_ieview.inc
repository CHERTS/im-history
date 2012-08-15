(*

IEView Plugin for Miranda IM
Copyright (C) 2005  Piotr Piastucki

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

{$IFNDEF M_IEVIEW}
{$DEFINE M_IEVIEW}

const

  MS_IEVIEW_WINDOW    = 'IEVIEW/NewWindow';
  MS_IEVIEW_EVENT     = 'IEVIEW/Event';
  MS_IEVIEW_NAVIGATE  = 'IEVIEW/Navigate';

  ME_IEVIEW_OPTIONSCHANGED = 'IEVIEW/OptionsChanged';

//* IEView window commands */
  IEW_CREATE          = 1;          // create new window (control)
  IEW_DESTROY         = 2;          // destroy control
  IEW_SETPOS          = 3;          // set window position and size
  IEW_SCROLLBOTTOM    = 4;          // scroll text to bottom

//* IEView window type/mode */
  IEWM_TABSRMM        = 1;          // TabSRMM-compatible HTML builder
  IEWM_HTML           = 2;          // HTML
  IEWM_SCRIVER        = 3;          // Scriver-compatible HTML builder
  IEWM_MUCC           = 4;          // MUCC group chats GUI
  IEWM_CHAT           = 5;          // chat.dll group chats GUI
  IEWM_HISTORY        = 6;          // history viewer
  IEWM_BROWSER        = 256;        // empty browser window

type

  PIEVIEWWINDOW = ^IEVIEWWINDOW;
  IEVIEWWINDOW = record
    cbSize: Integer;                // size of the strusture
    iType: Integer;                 // one of IEW_* values
    dwMode: DWord;                  // compatibility mode - one of IEWM_* values
    dwFlags: DWord;                 // flags, one of IEWF_* values
    Parent: HWND;                   // parent window HWND
    Hwnd: HWND;                     // IEW_CREATE returns WebBrowser control's HWND here
    x: Integer;                     // IE control horizontal position
    y: Integer;                     // IE control vertical position
    cx: Integer;                    // IE control horizontal size
    cy: Integer;                    // IE control vertical size
  end;

const

  IEEDF_UNICODE       = $00000001;  // if set pszText is a pointer to wchar_t string instead of AnsiChar string
  IEEDF_UNICODE_TEXT  = $00000001;  // if set pszText is a pointer to wchar_t string instead of AnsiChar string
  IEEDF_UNICODE_NICK  = $00000002;  // if set pszNick is a pointer to wchar_t string instead of AnsiChar string
  IEEDF_UNICODE_TEXT2 = $00000004;  // if set pszText2 is a pointer to wchar_t string instead of AnsiChar string

//* The following flags are valid only for message events (IEED_EVENT_MESSAGE) */
  IEEDF_FORMAT_FONT   = $00000100;  // if set pszFont (font name) is valid and should be used
  IEEDF_FORMAT_SIZE   = $00000200;  // if set fontSize is valid and should be used
  IEEDF_FORMAT_COLOR  = $00000400;  // if set color is valid and should be used
  IEEDF_FORMAT_STYLE  = $00000800;  // if set fontSize is valid and should be used

  IEEDF_READ          = $00001000;  // if set
  IEEDF_SENT          = $00002000;  // if set
  IEEDF_RTL           = $00004000;  // if set

  IEED_EVENT_MESSAGE      = $0001;  // message
  IEED_EVENT_STATUSCHANGE = $0002;  // status change
  IEED_EVENT_FILE         = $0003;  // file
  IEED_EVENT_URL          = $0004;  // url
  IEED_EVENT_ERRMSG       = $0005;  // error message
  IEED_EVENT_SYSTEM       = $0006;  // system event

  IEED_MUCC_EVENT_MESSAGE = $0001;  // message
  IEED_MUCC_EVENT_TOPIC   = $0002;  // topic change
  IEED_MUCC_EVENT_JOINED  = $0003;  // user joined
  IEED_MUCC_EVENT_LEFT    = $0004;  // user left
  IEED_MUCC_EVENT_ERROR   = $0005;  // error

//* MUCC-related dwData bit flags */
  IEEDD_MUCC_SHOW_NICK       = $00000001;
  IEEDD_MUCC_MSG_ON_NEW_LINE = $00000002;
  IEEDD_MUCC_SHOW_DATE       = $00000010;
  IEEDD_MUCC_SHOW_TIME       = $00000020;
  IEEDD_MUCC_SECONDS         = $00000040;
  IEEDD_MUCC_LONG_DATE       = $00000080;

  IEED_GC_EVENT_HIGHLIGHT    = $8000;
  IEED_GC_EVENT_MESSAGE      = $0001;
  IEED_GC_EVENT_TOPIC        = $0002;
  IEED_GC_EVENT_JOIN         = $0003;
  IEED_GC_EVENT_PART         = $0004;
  IEED_GC_EVENT_QUIT         = $0006;
  IEED_GC_EVENT_NICK         = $0007;
  IEED_GC_EVENT_ACTION       = $0008;
  IEED_GC_EVENT_KICK         = $0009;
  IEED_GC_EVENT_NOTICE       = $000A;
  IEED_GC_EVENT_INFORMATION  = $000B;
  IEED_GC_EVENT_ADDSTATUS    = $000C;
  IEED_GC_EVENT_REMOVESTATUS = $000D;

//* GC-related dwData bit flags */
  IEEDD_GC_SHOW_NICK       = $00000001;
  IEEDD_GC_SHOW_TIME       = $00000002;
  IEEDD_GC_SHOW_ICON       = $00000004;
  IEEDD_GC_MSG_ON_NEW_LINE = $00001000;

  IE_FONT_BOLD      = $000100;      // Bold font flag
  IE_FONT_ITALIC    = $000200;      // Italic font flag
  IE_FONT_UNDERLINE = $000400;      // Underlined font flags

type

  PIEVIEWEVENTDATA = ^IEVIEWEVENTDATA;
  IEVIEWEVENTDATA = record
    cbSize: Integer;                //
    iType: Integer;                 // Event type, one of MUCC_EVENT_* values
    dwFlags: DWord;                 // Event flags - IEEDF_*
    fontName: PAnsiChar;                // Text font name
    fontSize: Integer;              // Text font size (in pixels)
    fontStyle: Integer;             // Text font style (combination of IE_FONT_* flags)
    color: COLORREF;                // Text color
    pszNick: TChar;                 // Nick, usage depends on type of event Ansi/Unicode
    pszText: TChar;                 // Text, usage depends on type of event Ansi/Unicode
    dwData: DWord;                  // DWORD data e.g. status
    bIsMe: BOOL;                    // TRUE if the event is related to the user
    time: DWord;                    // Time of the event
    next: PIEVIEWEVENTDATA;
    pszText2: TChar;                // Text, usage depends on type of event Ansi/Unicode
  end;

const

//* IEView events */
  IEE_LOG_DB_EVENTS     = 1;        // log specified number of DB events
  IEE_CLEAR_LOG         = 2;        // clear log
  IEE_GET_SELECTION     = 3;        // get selected text
  IEE_SAVE_DOCUMENT     = 4;        // save current document
  IEE_LOG_MEM_EVENTS    = 5;        // log specified number of IEView events

//* IEView event flags */
  IEEF_RTL              = 1;        // turn on RTL support
  IEEF_NO_UNICODE       = 2;        // disable Unicode support
  IEEF_NO_SCROLLING     = 4;        // do not scroll logs to bottom

  IEVIEWEVENT_SIZE_V1   = 28;
  IEVIEWEVENT_SIZE_V2   = 32;
  IEVIEWEVENT_SIZE_V3   = 36;

type

  _IEVIEWEVENTVARIANT = record
    case boolean of
      false: (hDBEventFirst: THandle);      // first event to log, when IEE_LOG_EVENTS returns it will contain
                                            // the last event actually logged or NULL if no event was logged (IEE_LOG_EVENTS)
      true:  (eventData: PIEVIEWEVENTDATA);
  end;
  PIEVIEWEVENT = ^IEVIEWEVENT;
  IEVIEWEVENT = record
    cbSize: Integer;                // size of the strusture
    iType: Integer;                 // one of IEE_* values
    dwFlags: DWord;                 // one of IEEF_* values
    Hwnd: HWND;                     // HWND returned by IEW_CREATE
    hContact: THandle;              // contact
    data: _IEVIEWEVENTVARIANT;
    Count: Integer;                 // number of events to log
    Codepage: Cardinal;             // ANSI codepage
    pszProto: PAnsiChar;                // Name of the protocol
  end;

  PIEVIEWSHOWSMILEYSEL = ^IEVIEWSHOWSMILEYSEL;
  IEVIEWSHOWSMILEYSEL = record
    cbSize: Integer;                //size of the structure
   Protocolname: PAnsiChar;            //protocol to use... if you have defined a protocol, u can
                                    //use your own protocol name. Smiley add wil automatically
                                    //select the smileypack that is defined for your protocol.
                                    //Or, use "Standard" for standard smiley set. Or "ICQ", "MSN"
                                    //if you prefer those icons.
                                    //If not found or NULL: "Standard" will be used
   xPosition: integer;             //Postition to place the selectwindow
   yPosition: integer;             // "
   Direction: integer;             //Direction (i.e. size upwards/downwards/etc) of the window 0, 1, 2, 3
   hwndTarget: HWND;               //Window, where to send the message when smiley is selected.
   targetMessage: Cardinal;        //Target message, to be sent.
   targetWParam: WPARAM;           //Target WParam to be sent (LParam will be AnsiChar* to select smiley)
                                    //see the example file.
  end;

const

  IEN_NAVIGATE = 1;        // navigate to the given destination
  IENF_UNICODE = 1;        // if set urlW is used instead of urlW

type

  PIEVIEWNAVIGATE = ^IEVIEWNAVIGATE;
  IEVIEWNAVIGATE = record
    cbSize: Integer;                //size of the structure
    iType: Integer;                 // one of IEE_* values
    dwFlags: DWord;                 // one of IEEF_* values
    Hwnd: HWND;                     // HWND returned by IEW_CREATE
    url: TChar;                     // Text, usage depends on type of event Ansi/Unicode
  end;

{$ENDIF}
