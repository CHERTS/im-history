{$IFNDEF M_MUSIC}
{$DEFINE M_MUSIC}

// defined in interfaces.inc
//const MIID_WATRACK:MUUID='{FC6C81F4-837E-4430-9601-A0AA43177AE3}';

type
  pSongInfoA = ^tSongInfoA;
  tSongInfoA = record
    artist  :PAnsiChar;
    title   :PAnsiChar;
    album   :PAnsiChar;
    genre   :PAnsiChar;
    comment :PAnsiChar;
    year    :PAnsiChar;
    mfile   :PAnsiChar;     // media file
    kbps    :dword;
    khz     :dword;
    channels:dword;
    track   :dword;
    total   :dword;     // music length
    time    :dword;     // elapsed time
    wndtext :PAnsiChar;     // window title
    player  :PAnsiChar;     // player name
    plyver  :dword;     // player version
    icon    :THANDLE;   // player icon
    fsize   :dword;     // media file size
    vbr     :dword;
    status  :integer;   // WAT_MES_* const
    plwnd   :HWND;      // player window
    // video part
    codec   :dword;
    width   :dword;
    height  :dword;
    fps     :dword;
    date    :int64;
    txtver  :PAnsiChar;
    lyric   :PAnsiChar;
    cover   :PAnsiChar;
    volume  :dword;
    url     :PAnsiChar;     // player homepage
  end;
type
  pSongInfo=^tSongInfo;
  tSongInfo = record
    artist  :pWideChar;
    title   :pWideChar;
    album   :pWideChar;
    genre   :pWideChar;
    comment :pWideChar;
    year    :pWideChar;
    mfile   :pWideChar; // media file
    kbps    :dword;
    khz     :dword;
    channels:dword;
    track   :dword;
    total   :dword;     // music length
    time    :dword;     // elapsed time
    wndtext :pWideChar; // window title
    player  :pWideChar; // player name
    plyver  :dword;     // player version
    icon    :THANDLE;   // player icon
    fsize   :dword;     // media file size
    vbr     :dword;
    status  :integer;   // WAT_MES_* const
    plwnd   :HWND;      // player window
    // video part
    codec   :dword;
    width   :dword;
    height  :dword;
    fps     :dword;
    date    :int64;
    txtver  :pWideChar;
    lyric   :pWideChar;
    cover   :pWideChar; // cover path
    volume  :dword;
    url     :PWideChar; // player homepage
  end;

const
  // result codes
  WAT_RES_UNKNOWN  = -2;
  WAT_RES_NOTFOUND = -1;
  WAT_RES_ERROR    = WAT_RES_NOTFOUND;
  WAT_RES_OK       = 0;
  WAT_RES_ENABLED  = WAT_RES_OK;
  WAT_RES_DISABLED = 1;
  // internal
  WAT_RES_NEWFILE  = 3;

// result for MS_WAT_GETMUSICINFO service
const
  WAT_PLS_NORMAL   = WAT_RES_OK;
  WAT_PLS_NOMUSIC  = WAT_RES_DISABLED;
  WAT_PLS_NOTFOUND = WAT_RES_NOTFOUND;

const
  WAT_INF_UNICODE = 0;
  WAT_INF_ANSI    = 1;
  WAT_INF_UTF8    = 2;
  WAT_INF_CHANGES = $100;

const
{
  wParam : WAT_INF_* constant
  lParam : pointer to pSongInfo (Unicode) or pSongInfoA (ANSI/UTF8)
  Affects: Fill structure by currently played music info
  returns: WAT_PLS_* constant
  note: pointer will be point to global SongInfo structure of plugin
  warning: Non-Unicode data filled only by request
  if lParam=0 only internal SongInfo structure will be filled
  Example:
    var p:pSongInfo;
    PluginLink^.CallService(MS_WAT_GETMUSICINFO,0,dword(@p));
}
  MS_WAT_GETMUSICINFO:PAnsiChar = 'WATrack/GetMusicInfo';
{
  wParam:0
  lParam : pointer to pSongInfo (Unicode)
  Affects: Fill structure by info from file named in SongInfo.mfile
  returns: 0, if success
  note: fields, which values can't be obtained, leaves old values.
    you must free given strings by miranda mmi.free
}
  MS_WAT_GETFILEINFO:PAnsiChar = 'WATrack/GetFileInfo';

const
  WAT_CTRL_PREV  = 1;
  WAT_CTRL_PLAY  = 2;
  WAT_CTRL_PAUSE = 3;
  WAT_CTRL_STOP  = 4;
  WAT_CTRL_NEXT  = 5;
  WAT_CTRL_VOLDN = 6;
  WAT_CTRL_VOLUP = 7;
  WAT_CTRL_SEEK  = 8; // lParam is new position (sec)

{
  wParam: button code (WAT_CTRL_* const)
  lParam: 0, or value (see WAT_CTRL_* const comments)
  Affects: emulate player button pressing
  returns: 0 if unsuccesful
}
  MS_WAT_PRESSBUTTON:PAnsiChar = 'WATrack/PressButton';

{
  Get user's Music Info
}
  MS_WAT_GETCONTACTINFO:PAnsiChar = 'WATrack/GetContactInfo';

// ------------ Plugin/player status ------------

{
  wParam: 1  - switch off plugin
          0  - switch on plugin
          -1 - switch plugin status
          2  - get plugin version
          other - get plugin status
  lParam: 0
  Affects: Switch plugin status to enabled or disabled
  returns: version, old plugin status, 0, if was enabled
}
  MS_WAT_PLUGINSTATUS:PAnsiChar = 'WATrack/PluginStatus';

  ME_WAT_MODULELOADED:PAnsiChar = 'WATrack/ModuleLoaded';

const
  WAT_EVENT_PLAYERSTATUS = 1; // WAT_PLS_* const
  WAT_EVENT_NEWTRACK     = 2; // SongInfo ptr
  WAT_EVENT_PLUGINSTATUS = 3; // 0-enabled; 1-dis.temporary; 2-dis.permanent
  WAT_EVENT_NEWPLAYER    = 4; //
  WAT_EVENT_NEWTEMPLATE  = 5; // TM_* constant

{
  Plugin or player status changed:
  wParam: type of event (see above)
  lParam: value
}
  ME_WAT_NEWSTATUS:PAnsiChar = 'WATrack/NewStatus';

// ---------- Popup module ------------

{
  wParam: not used
  lParam: not used
  Affects: Show popup or Info window with current music information
  note: Only Info window will be showed if Popup plugin disabled
}
  MS_WAT_SHOWMUSICINFO:PAnsiChar = 'WATrack/ShowMusicInfo';

// --------- Statistic (report) module -------------

{
  wParam: pointer to log file name or NIL
  lParam: pointer to report file name or NIL
  Affects: Create report from log and run it (if option is set)
  returns: 0 if unsuccesful
  note: if wParam or lParam is a NIL then file names from options are used
}
  MS_WAT_MAKEREPORT :PAnsiChar = 'WATrack/MakeReport';
//  MS_WAT_MAKEREPORTW:PAnsiChar = 'WATrack/MakeReportW';

{
  wParam, lParam - not used
  Affects: pack statistic file
}
  MS_WAT_PACKLOG:PAnsiChar = 'WATrack/PackLog';

{
  wParam: not used
  lParam: pointer to SongInfo
}
  MS_WAT_ADDTOLOG:PAnsiChar = 'WATrack/AddToLog';

// ----------- Formats and players -----------

// media file status

const
  WAT_MES_STOPPED = 0;
  WAT_MES_PLAYING = 1;
  WAT_MES_PAUSED  = 2;
  WAT_MES_UNKNOWN = -1;

const
  WAT_ACT_REGISTER   = 1;
  WAT_ACT_UNREGISTER = 2;
  WAT_ACT_DISABLE    = 3;
  WAT_ACT_ENABLE     = 4;
  WAT_ACT_GETSTATUS  = 5; // not found/enabled/disabled
  WAT_ACT_SETACTIVE  = 6;
  WAT_ACT_REPLACE    = $10000; // can be combined with WAT_REGISTERFORMAT

const
  // flags
  WAT_OPT_DISABLED    = $0001; // registered but disabled
  WAT_OPT_ONLYONE     = $0002; // can't be overwriten
  WAT_OPT_PLAYERINFO  = $0004; // song info from player
  WAT_OPT_WINAMPAPI   = $0008; // Winamp API support
  WAT_OPT_CHECKTIME   = $0010; // check file time for changes
  WAT_OPT_VIDEO       = $0020; // only for format registering used
  WAT_OPT_LAST        = $0040; // (internal-Winamp Clone) put to the end of queue
  WAT_OPT_FIRST       = $0080; // (internal)
  WAT_OPT_TEMPLATE    = $0100; // (internal)
  WAT_OPT_IMPLANTANT  = $0200; // use process implantation
  WAT_OPT_HASURL      = $0400; // (player registration) URL field present
  WAT_OPT_CHANGES     = $0800; // obtain only chaged values
                               // (volume, status, window text, elapsed time)
  WAT_OPT_APPCOMMAND  = $1000; // Special (multimedia) key support
  WAT_OPT_MULTITHREAD = $8000; // Use multithread scan
  WAT_OPT_KEEPOLD     = $4000; // Keep Old opened file

type
  tReadFormatProc = function(var Info:tSongInfo):boolean; cdecl;
  pMusicFormat = ^tMusicFormat;
  tMusicFormat = record
    proc :tReadFormatProc;
    ext  :array [0..7] of AnsiChar;
    flags:integer;
  end;

const
{
  wParam: action
  lParam: pointer to tMusicFormat if wParam = WAT_ACT_REGISTER,
          else - pointer to extension string (ANSI)
  returns: see result codes
}
  MS_WAT_FORMAT:PAnsiChar = 'WATrack/Format';

{
  wParam: pointer to SongInfo structure (plwind field must be initialized)
  lParam: flags
  Affects: trying to fill SongInfo using Winamp API
}
  MS_WAT_WINAMPINFO:PAnsiChar = 'WATrack/WinampInfo';

{
  wParam: window
  lParam: LoWord - command; HiWord - value
}
  MS_WAT_WINAMPCOMMAND:PAnsiChar = 'WATrack/WinampCommand';

type
  tNameProc    = function:pWideChar;cdecl;
  tCheckProc   = function(flags:integer):HWND;cdecl;
  tInfoProc    = function(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
  tCommandProc = function(command:integer;value:integer):integer;cdecl;

  pPlayerCell = ^tPlayerCell;
  tPlayerCell = record
    Desc   :PAnsiChar;
    flags  :integer;
    Icon   :HICON;        // can be 0. for registration only
    Check  :tCheckProc;   // check player
    GetName:tNameProc;    // can be NIL. get media filename
    GetInfo:tInfoProc;    // can be NIL. get info from player
    Command:tCommandProc; // can be NIL. send command to player
    URL    :PAnsiChar;        // only if WAT_OPT_HASURL flag present
  end;

const
{
  wParam: action
  lParam: pointer to tPlayerCell if wParam = WAT_ACT_REGISTER,
          else - pointer to player description string (ANSI)
  returns: player window handle or value>0 if found
  note: If you use GetName or GetInfo field, please, do not return empty
        filename even when mediafile is remote!
}
  MS_WAT_PLAYER:PAnsiChar = 'WATrack/Player';

// --------- Templates ----------

const //templates
  TM_MESSAGE    = 0; // privat message
  TM_CHANNEL    = 1; // chat
  TM_STAT_TITLE = 2; // xstatus title
  TM_STAT_TEXT  = 3; // [x]status text
  TM_POPTITLE   = 4; // popup title
  TM_POPTEXT    = 5; // popup text
  TM_EXPORT     = 6; // other app
  TM_FRAMEINFO  = 7; // frame

  TM_SETTEXT    = $100; // only for service
  TM_GETTEXT    = 0;    // only for service

const
{
  wParam: 0 (standard Info) or pSongInfo
  lParam: TM_* constant or Unicode template
  returns: New Unicode (replaced) string
}
  MS_WAT_REPLACETEXT:PAnsiChar = 'WATrack/ReplaceText';

{
  event types for History
  Blob structure for EVENTTYPE_WAT_ANSWER:
   Uniciode artist#0title#0album#0answer
}
const
  EVENTTYPE_WAT_REQUEST = 9601;
  EVENTTYPE_WAT_ANSWER  = 9602;
  EVENTTYPE_WAT_ERROR   = 9603;
  EVENTTYPE_WAT_MESSAGE = 9604;

const
{
  wParam:  Template type (TM_* constants).
  lParam:  Template string for template setup, or not used
  returns: pointer to statically allocated string (DON'T free!)
  note:    Template set if wParam with TM_SETTEXT combined. If used for
           Protocol-dependent templates, used only for default templates.
}
  MS_WAT_TEMPLATE:PAnsiChar = 'WATrack/Templates';

{$ENDIF M_MUSIC}
