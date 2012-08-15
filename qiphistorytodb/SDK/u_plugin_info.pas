{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://wiki.qip.ru/SDK        }
{                                     }
{*************************************}
unit u_plugin_info;

interface

uses Windows, u_plugin_msg, u_common;

const
  QIP_SDK_VER_MAJOR = 1;
  QIP_SDK_VER_MINOR = 10;

type
  {Plugin info}
  {see http://wiki.qip.ru/SDK_Types#TPluginInfo }
  TPluginInfo = record
    DllHandle         : DWord;      //dll instance/handle will be updated by QIP after successful loading of plugin library
    DllPath           : PWideChar;  //this should be updated by plugin library after receiving PM_PLUGIN_LOAD_SUCCESS from QIP
    QipSdkVerMajor    : Word;       //major version of sdk for core compatibility check
    QipSdkVerMinor    : Word;       //minor version of sdk for core compatibility check
    PlugVerMajor      : Word;
    PlugVerMinor      : Word;
    PluginName        : PWideChar;
    PluginAuthor      : PWideChar;
    PluginDescription : PWideChar;
    PluginHint        : PWideChar;    
    PluginIcon        : HICON;
  end;
  pPluginInfo = ^TPluginInfo;

  {QIP2Plugin instant message record}
  {see http://wiki.qip.ru/SDK_Types#TQipMsgPlugin }
  TQipMsgPlugin = record
    MsgType    : Byte;        //see below, MSG_TYPE_....
    MsgTime    : DWord;       //unix datetime, local time
    ProtoName  : PWideChar;
    SenderAcc  : PWideChar;
    SenderNick : PWideChar;
    RcvrAcc    : PWideChar;
    RcvrNick   : PWideChar;
    MsgText    : PWideChar;
    Blocked    : Boolean;     //received msg blocked by antispam
    ProtoDll   : Integer;
    OfflineMsg : PWideChar;
  end;
  pQipMsgPlugin = ^TQipMsgPlugin;

  {Fading window which popups from tray}
  {see http://wiki.qip.ru/SDK_Types#TFadeWndInfo }
  TFadeWndInfo = record
    FadeType     : Byte;        //0 - message style, 1 - information style, 2 - warning style
    FadeIcon     : HICON;       //icon in the top left corner of the window
    FadeTitle    : WideString;
    FadeText     : WideString;
    TextCentered : Boolean;     //if true then text will be centered inside window
    NoAutoClose  : Boolean;     //if NoAutoClose is True then wnd will be always shown until user close it. Not recommended to set this param to True.
  end;
  pFadeWndInfo = ^TFadeWndInfo;

  {Contact details}
  {see http://wiki.qip.ru/SDK_Types#TContactDetails }
  TContactDetails = record
    AccountName : WideString;
    ContactName : WideString;  //as showing in contact list
    NickName    : WideString;
    FirstName   : WideString;
    LastName    : WideString;
    AccRegDate  : DWord;       //unix datetime, account registration date
    ExtIPs      : WideString;  //ips divided by CRLF
    LastSeen    : DWord;       //unix datetime, last seen online
    Email       : WideString;
    HomeCountry : WideString;
    HomeCity    : WideString;
    HomeState   : WideString;
    HomeZip     : WideString;
    HomePhone   : WideString;
    HomeFax     : WideString;
    HomeCell    : WideString;
    HomeAddress : WideString;
    OrigCountry : WideString;  //Original (motherland)
    OrigCity    : WideString;
    OrigState   : WideString;
    WorkCountry : WideString;
    WorkCity    : WideString;
    WorkState   : WideString;
    WorkZip     : WideString;
    WorkPhone   : WideString;
    WorkFax     : WideString;
    WorkAddress : WideString;
    WorkCompany : WideString;
    WorkDepart  : WideString;
    WorkOccup   : WideString;
    WorkPos     : WideString;
    WorkPage    : WideString;
    PersGender  : WideString;
    PersAge     : WideString;
    PersPage    : WideString;
    PersMarital : WideString;
    BirthDate   : Double;      //TDateTime
    Lang1       : WideString;
    Lang2       : WideString;
    Lang3       : WideString;
    Inter1      : WideString;  //interests
    Inter1Keys  : WideString;
    Inter2      : WideString;
    Inter2Keys  : WideString;
    Inter3      : WideString;
    Inter3Keys  : WideString;
    Inter4      : WideString;
    Inter4Keys  : WideString;
    About       : WideString;
    Note        : WideString;  //user added note for this contact
    Additional  : WideString;
    AvatarPath  : WideString;  //don't forget to check if path is correct with WideFileExists
  end;
  pContactDetails = ^TContactDetails;

  {Connection settings}
  {see http://wiki.qip.ru/SDK_Types#TNetParams }
  TNetParams = record
    ConType     : Byte;       //Connection type, 0=direct, 1=auto, 2=manual
    PrxHost     : WideString;
    PrxPort     : Word;
    PrxUser     : WideString;
    PrxPass     : WideString;
    PrxType     : Byte;       //Proxy type, 0=none, 1=http, 2=https, 3=socks4, 4=socks4a, 5=socks5.
    PrxAuth     : Byte;       //Authentication method, 0=none, 1=socks, 2=basic, 3=ntlm.
    KeepAlive   : Boolean;    //Keep connection alive
  end;
  pNetParams = ^TNetParams;


  {QIP gives to plugin this interface}
  {see http://wiki.qip.ru/IQIPPluginService}
  IQIPPluginService = interface
    function  PluginOptions(DllHandle: LongInt): pPluginSpecific; stdcall;
    procedure OnPluginMessage(var PlugMsg: TPluginMessage); stdcall;
  end;
  pIQIPPluginService = ^IQIPPluginService;


  {Plugin gives to QIP this interface}
  {see http://wiki.qip.ru/IQIPPlugin}
  IQIPPlugin = interface
    function  GetPluginInfo: pPluginInfo; stdcall;
    procedure OnQipMessage(var PlugMsg: TPluginMessage); stdcall;
  end;
  pIQIPPlugin = ^IQIPPlugin;


  {Internal QIP Plugin item in Plugins List}
  TPluginItem = record
    DllHandle  : LongInt;
    PluginFile : WideString;
    Enabled    : Boolean;
    PluginIntf : IQIPPlugin;
  end;
  pPluginItem = ^TPluginItem;


  {Internal QIP plugin manager, INTF_PLUGINS_MAN}
  IQIPPluginMan = interface
    procedure BroadcastMsgToPlugins(var PlugMsg: TPluginMessage); stdcall;
    procedure SendMsgToPlugin(aDllHandle: DWord; var PlugMsg: TPluginMessage); stdcall;
    function  GetPlugin(aDllHandle: LongInt): pPluginItem; stdcall;
    function  EnumPlugins(var PluginIndex: integer; var Plugin: pPluginItem): Boolean; stdcall;
  end;
  pIQIPPluginMan = ^IQIPPluginMan;

  {see http://wiki.qip.ru/SDK_Types#TSnapshotElement}
  TSnapshotElement = record
    AccountName: WideString;
    ContactName: WideString;
    GroupName  : WideString;
    ProtoHandle: Integer;
    ContactStatus: Byte;
    IsChatContact: Boolean;
  end;
  pSnapshotElement = ^TSnapshotElement;

  {see http://wiki.qip.ru/SDK_Types#TProtoSnapshotElement}
  TProtoSnapshotElement = record
    ProtoName   : WideString;
    ProtoAccount: WideString;
    ProtoHandle : Integer;
    Enabled     : Boolean;
    ProtoFile   : WideString;
    NickName    : WideString;
    FirstName   : WideString;
    LastName    : WideString;
  end;
  pProtoSnapshotElement = ^TProtoSnapshotElement;

  //important note: do not call GetSnapshot in separate thread due to snapshot data is allocated in main thread
  //DO NOT use Contact in your interface implementation - use copy of data
  //DO NOT use any tricks to reduce main thread loading! this methods are for snapshot only. To collect online users use PM_PLUGIN_CONTACT_STATUS
  {see http://wiki.qip.ru/SDK Interfaces#ICLSnapshot}
  ICLSnapshot = interface
    function AddElement(const Contact: pSnapshotElement): HResult; stdcall; //return S_OK if succesfull, otherwise the core will stop enumeration
    function AddProto(const Proto: pProtoSnapshotElement): HResult; stdcall; //return S_OK if succesfull, otherwise the core will stop enumeration
  end;

  //important note: do not call in separate thread. Use copy of data in get methods.
  //Index is from 1 to 10
  //To prevent AV in core, DO NOT store interface all the time, request it at
  //any moment you need, because user can delete subcontact or total metaconact
  {see http://wiki.qip.ru/SDK Interfaces#IMetaContact}
  IMetaContact = interface
    function UniqueID: Integer; stdcall;
    function Count: Integer; stdcall;
    function Contact(Index: Integer): TSnapshotElement; stdcall;
    function ContactDetails(Index: Integer): TContactDetails; stdcall;
    function TotalStatus: Cardinal; stdcall;
    function MetaGroup: WideString; stdcall;
    function MetaContactName: WideString; stdcall;
  end;
  pIMetaContact = ^IMetaContact;

  {see http://wiki.qip.ru/SDK_Types#THistNode}
  THistNode = record
    Icon    : HICON;      //set to 0 to show standard plugin icon
    Text    : WideString; //this text will be displayed as node text
    NodeID  : WideString; //use this field to identify selected node
    HistPath: WideString; //set path to history file here if using qip to write binary history.
                          //if you keep it empty, you should respond to LoadHist method
  end;
  pHistNode = ^THistNode;

  {see http://wiki.qip.ru/SDK Interfaces#IPluginHistory}
  IPluginHistory = interface
    function  HasHistory: Boolean; stdcall;
    procedure LoadHist(NodeID: WideString; IsMeta: Boolean); stdcall;
    procedure GetHistInfo(NodeID: WideString; var TimeFmtStr: WideString;
                          var NickBeforeTime, BreakBeforeMsg, HideMsgSeparators: Boolean); stdcall;
    function  NodeIDFromMeta(AMeta: IMetaContact): WideString; stdcall;
    function  NodeIDFromAccName(AccountName: WideString; ProtoHandle: Integer;
                                AMeta: IMetaContact; MetaHasNode: Boolean): WideString; stdcall;
    function  HistFile(NodeID: WideString): WideString; stdcall;
    function  AccNodeIcon(NodeID: WideString): HICON; stdcall;
    procedure RefreshNodes(Filter: WideString); stdcall;
    procedure ExpandNode(NodeID, Filter: WideString); stdcall;
    function  DeleteHist(NodeID: WideString): Boolean; stdcall;
    function  MenuCaption(NodeID: WideString): WideString; stdcall;
  end;

  {see http://wiki.qip.ru/SDK Interfaces#IQIPHistory}
  IQIPHistory = interface
    function  ShowHistWnd: Boolean; stdcall;
    procedure CloseHistForm; stdcall;
    function  MetaFromNodeID(DllHandle: Integer; NodeID: WideString): IMetaContact; stdcall;
    procedure AccProtoNodeID(DllHandle: Integer; NodeID: WideString; var AccountName: WideString; var ProtoHandle: Integer); stdcall;
    function  SetSelectedNode(DllHandle: Integer; NodeID: WideString): Boolean; overload; stdcall;
    function  SetSelectedNode(DllHandle: Integer; AccountName: WideString; ProtoHandle: Integer): Boolean; overload; stdcall;
    function  AddToHistory(DllHandle: Integer; FilePart, Nick: WideString;
                           Outgoing: Boolean; MsgText: WideString;
                           var FileSize: Int64; var HistPath: WideString): Boolean; stdcall;
    function  HistoryPath(DllHandle: Integer): WideString; stdcall;
    procedure LoadHistory(DllHandle: Integer; HistFile: WideString); stdcall;
    function  AddHistMsg(DllHandle: Integer; DateTime: DWord; Outgoing: Boolean;
                         MsgText: WideString; MsgNick: WideString = ''): Boolean; stdcall;//DateTime is unix date time
    function  AddHistNode(DllHandle: Integer; ParentNodeID: WideString;
                          NodeInfo: pHistNode; CanExpand: Boolean): Boolean; stdcall;
  end;

  {see http://wiki.qip.ru/SDK_Types#TChatTextInfo}
  TChatTextInfo = record
    MsgType    : Byte;        //see below, CHAT_TEXT_....
    MsgTime    : Integer;     //unixtime
    ChatName   : PWideChar;
    ChatCaption: PWideChar;
    ProtoAcc   : PWideChar;
    ProtoDll   : Integer;
    NickName   : PWideChar;
    MyNick     : PWideChar;
    MsgText    : PWideChar;
    IsPrivate  : Boolean;   //private chat with some chat user
    IsSimple   : Boolean;   //fast jabber conference
    IsIRC      : Boolean;   //True if IRC chat/private
  end;
  pChatTextInfo = ^TChatTextInfo;

  {see http://wiki.qip.ru/SDK_Types#TPluginMenuItem}
  TPluginMenuItem = record
    ItemID      : Integer;
    ItemData    : Integer;
    MenuCaption : WideString;
    MenuIcon    : HICON;
    MenuPNG     : Integer;
    Enabled     : Boolean;
  end;
  PPluginMenuItem = ^TPluginMenuItem;
  PMenuItems = ^PPluginMenuItem; //array of PPluginMenuItem

const
  {Messages qip <-> plugin}
  {for better and detailed information, visit http://wiki.qip.ru/SDK_Messages}
  {All messages "plugin -> qip" have to be with actual PluginMsg.DllHandle parameter}
  {=== Plugin main messages =======}
  PM_PLUGIN_LOAD_SUCCESS    =  1; //qip -> plugin
  PM_PLUGIN_RUN             =  2; //qip -> plugin
  PM_PLUGIN_QUIT            =  3; //qip -> plugin
  PM_PLUGIN_ENABLE          =  4; //qip -> plugin
  PM_PLUGIN_DISABLE         =  5; //qip -> plugin
  PM_PLUGIN_OPTIONS         =  6; //qip -> plugin
  {=== Plugin specific messages ===}
  PM_PLUGIN_SPELL_CHECK     =  7; //qip -> plugin, WParam = PWideChar to checking word, LParam = MissSpelledColor (delphi TColor). Return LParam with own color if needed and Result = True if word misspelled.
  PM_PLUGIN_SPELL_POPUP     =  8; //qip -> plugin, WParam = PWideChar to misspelled word, LParam is PPoint where PopupMenu should be popuped (screen coordinates). Return Result = True to ignore qip default menu popup.
  PM_PLUGIN_SPELL_REPLACE   =  9; //plugin -> qip, WParam = PWideChar to right word which will replace old misspelled word. Qip will return Result = True if misspelled word was successfully replaced.
  PM_PLUGIN_XSTATUS_UPD     = 10; //plugin -> qip, WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture will be removed.
  PM_PLUGIN_XSTATUS_GET     = 11; //plugin -> qip, core will return WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture not set by user.
  PM_PLUGIN_XSTATUS_CHANGED = 12; //qip -> plugin, user manually changed custom status picture/text, WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture was removed by user.
  PM_PLUGIN_SOUND_GET       = 13; //plugin -> qip, if core returned WParam = True then qip sound enabled else sound disabled.
  PM_PLUGIN_SOUND_SET       = 14; //plugin -> qip, if WParam = True then qip will enable sound else will disable.
  PM_PLUGIN_SOUND_CHANGED   = 15; //qip -> plugin, user manually switched sound On/Off. if WParam = True the sound enabled.
  PM_PLUGIN_MSG_RCVD        = 16; //qip -> plugin, WParam = pQipMsgPlugin. Return result = True to allow core accept this msg else message will be IGNORED, CAREFUL here! If you will add to LParam pointer to own widestring then original msg text will be replaced by yours own text.
  PM_PLUGIN_MSG_SEND        = 17; //qip -> plugin, WParam = pQipMsgPlugin. Return result = True to allow send this msg else user will not be able to send this message, CAREFUL here! If you will add to LParam pointer to own widestring then original msg text will be replaced by yours own text.
  PM_PLUGIN_SPELL_RECHECK   = 18; //plugin -> qip, rechecks spelling for all message editing boxes
  PM_PLUGIN_MSG_RCVD_NEW    = 19; //qip -> plugin, notifier, qip received new message and its still not read by user. WParam = PWideChar to accountname of sender, LParam = PWideChar to nickname of sender. NParam is DllHandle of account protocol. Plugin will receive this message periodically (~400 msec) until user will open msg window and read this msg.
  PM_PLUGIN_MSG_RCVD_READ   = 20; //qip -> plugin, notifier, new received message has been read by user and qip core will stop notifing with PM_PLUGIN_MSG_RCVD_NEW message. WParam = PWideChar to accountname of sender, LParam = PWideChar to nickname of sender. NParam is DllHandle of account protocol. Plugin will receive this message only once after message or event will be read by user.
  PM_PLUGIN_WRONG_SDK_VER   = 21; //qip -> plugin, qip sends this message if plugin sdk version higher than qip's sdk version, after this msg qip will send PM_PLUGIN_QUIT message.
  PM_PLUGIN_CAN_ADD_BTNS    = 22; //qip -> plugin, broadcasted to all plugins, core creates message window and plugin can add buttons to panel below avatars, this message will be sent always on message window creation or tabs changing. WParam is PWideChar of account name of msg tab or wnd, LParam is PWideChar of protocol name of account, NParam is dll handle of protocol(for spec plugin msg sending needs);
  PM_PLUGIN_ADD_BTN         = 23; //plugin -> qip, wParam is pAddBtnInfo, core will return Result = Unique Action ID, which plugin will receive on every click on this btn, if Result will be returned  = 0 then btn was not added;
  PM_PLUGIN_MSG_BTN_CLICK   = 24; //qip -> plugin, occurs when user clicked on msg button below avatar. WParam is Unique Action ID given by core on adding this btn, LParam is PWideChar of account name of msg tab or wnd, NParam is PWideChar of protocol name of account, Result is dll handle of protocol(for spec plugin msg sending needs). Since Sdk 1.6, DllHandle is pBtnClick can be found in u_common.pas;
  PM_PLUGIN_SPEC_SEND       = 25; //plugin -> qip, WParam is protocol dll handle, LParam is PWideChar of receiver account name, NParam is special msg text/data. if Result returned = True then special message was sent else failed to send.
  PM_PLUGIN_SPEC_RCVD       = 26; //qip -> plugin, broadcasted to all plugins, WParam is protocol dll handle, LParam is PWideChar of sender account name, NParam is special msg text/data, Result is protocol name.
  PM_PLUGIN_ANTIBOSS        = 27; //qip -> plugin, user activated/deactivated antiboss, plugin have to hide/show own windows. If WParam is True then hide windows, if WParam is False then show windows.
  PM_PLUGIN_CURRENT_LANG    = 28; //qip -> plugin, means that current language changed. WParam is PWideChar of current language name.
  PM_PLUGIN_GET_LANG_STR    = 29; //plugin -> qip, plugin requesting language string. WParam have to be LI_... in file u_lang_ids. Core will return Result with PWideChar of requested language string.
  PM_PLUGIN_FADE_MSG        = 30; //plugin -> qip, showing fading popup window, WParam is pFadeWndInfo. If core will return Result = False then window was not shown cauz of any reason else Result will be unique id of fade msg.
  PM_PLUGIN_GET_NAMES       = 31; //plugin -> qip, plugin requesting display name and profile name. If core will return Result = True then names added to your message, WParam will be PWideChar od display name, LParam will be PWideChar of profile name.
  PM_PLUGIN_STATUS_GET      = 32; //plugin -> qip, plugin requesting current global status. If core will return Result = True then global status got successfuly and status will be returned in WParam and global privacy status will be returned in LParam. Status codes u can see in this file below, it's QIP_ST_....
  PM_PLUGIN_STATUS_SET      = 33; //plugin -> qip, plugin sets current global status(allowed to change status once in 1 minute). WParam have to be status code QIP_ST_... of new status (excepting QIP_STATUS_CONNECTING), if WParam will be -1 then status will not be changed and LParam have to be Privacy status (if LParam will be -1 then privacy status will not be changed). If core will return Result = True then status changed.
  PM_PLUGIN_STATUS_CHANGED  = 34; //qip -> plugin, global status changed by user or by plugins. WParam is current global status (if WParam = -1 then only privacy status was changed), LParam is current privacy status (if LParam = -1 then only global status was changed).
  PM_PLUGIN_RCVD_IM         = 35; //qip -> plugin, our user successfuly received new instant message. WParam is protocol handle, LParam is account name of sender, NParam is PWideChar of message text, Result is message type MSG_TYPE_... .
  PM_PLUGIN_SEND_IM         = 36; //plugin -> qip, plugin sends instant message to contact which is in contact list on in "not in list" group. WParam have to be protocol handle, LParam is account name of receiver, NParam is PWideChar of message text. If core returned Result = True then instant message send successfuly.
  PM_PLUGIN_CONTACT_STATUS  = 37; //qip -> plugin, core sends to plugin this message every time when contact status updated. WParam is PWideChar of protocol name, LParam is PWideChar of contact account name, NParam is contact status, Result is contact xstatus, DllHandle is protocol handle.
  PM_PLUGIN_DETAILS_GET     = 38; //plugin -> qip, plugin requesting saved LOCAL contact details. WParam have to be protocol handle, LParam have to be PWideChar of contact account name. If core will return Result = True then details found and to NParam added pContactDetails;
  PM_PLUGIN_CHAT_TAB        = 39; //qip -> plugin, occurs when started/closed new chat tab window. WParam is PWideChar of chat name, LParam is PWideChar of own nick. If NParam is True then chat opened else chat was closed, Result is PWideChar of chat tab caption, DllHandle is protocol handle.
  PM_PLUGIN_CHAT_CAN_BTNS   = 40; //qip -> plugin, broadcasted to all plugins, core creates chat tab window and plugin can add buttons to middle panel, this message will be sent always on chat tab window creation. WParam is PWideChar of chat name, LParam is PWideChar of protocol name, NParam is dll handle of protocol, Result is PWideChar of tab caption of chat;
  PM_PLUGIN_CHAT_ADD_BTN    = 41; //plugin -> qip, WParam is pAddBtnInfo, core will return Result = Unique Action ID, which plugin will receive on every click on this btn, if Result will be returned  = 0 then btn was not added;
  PM_PLUGIN_CHAT_BTN_CLICK  = 42; //qip -> plugin, occurs when user clicked on your chat button in middle panel. WParam is Unique Action ID given by core on adding this btn, LParam is PWideChar of chat name, NParam is PWideChar of chat protocol name, Result is dll handle of protocol. Since Sdk 1.6, DllHandle is pBtnClick can be found in u_common.pas;
  PM_PLUGIN_CHAT_MSG_RCVD   = 43; //obsolete since 1.8.5. qip -> plugin, occurs when chat message received (even if own message was sent). WParam is PWideChar of chat name, LParam is chat text type see below, NParam is PWideChar of sender nickname, Result is PWideChar of received message text, DllHandle is protocol handle.
  PM_PLUGIN_CHAT_SENDING    = 44; //qip -> plugin, our user going to send message to chat, occurs before message was sent to protocol. WParam is PWideChar of chat name, LParam is PWideChar of our user nickname, NParam is PWideChar of sending message text, DllHandle is protocol handle. Return Result = True if plugin edited message text and add it to NParam as PWideChar to send plugin edited text.
  PM_PLUGIN_CHAT_MSG_SEND   = 45; //plugin -> qip, plugin sends chat message to chat. WParam have to be PWideChar of chat name, LParam have to be protocol handle, NParam have to be PWideChar of sending message text. If core returned Result = True then plugin chat msg was sent.
  PM_PLUGIN_PLAY_WAV_SND    = 46; //plugin -> qip, plugin can play Wave sounds from plugin. WParam have to be QIP_SND_ID... below. If plugin have own wave files, then WParam have to be 0 and LParam have to be PWideChar of wave sound file path. if NParam will be True, then sound will be played according option "Always play unique sounds", else sound will be played according core sound enabled/disabled setting.
  PM_PLUGIN_SPEC_ADD_CNT    = 48; //plugin -> qip, plugin can add special owner draw contact. Can be sent only after PM_PLUGIN_RUN msg. WParam is contact height in contact list (default is 19, cant be lower than 8 and higher than 100). LParam can be pointer to your any record or object, else have to be 0. Core will return Result = unique dword id of contact.
  PM_PLUGIN_SPEC_DEL_CNT    = 49; //plugin -> qip, plugin can delete own special contact. WParam is unique dword id of contact. If core returned Result = True then contact deleted successfuly.
  PM_PLUGIN_SPEC_REDRAW     = 50; //plugin -> qip, plugin can redraw own special contact when needed. WParam is unique dword id of contact.
  PM_PLUGIN_SPEC_DRAW_CNT   = 51; //qip -> plugin, core drawing contact list, plugin have to draw own contact. WParam is unique contact id, LParam is your plugin data pointer (if added), NParam is Canvas HDC, Result is PRect of drawing rectangle.
  PM_PLUGIN_SPEC_DBL_CLICK  = 52; //qip -> plugin, user double clicked or pressed enter on spec contact. WParam is unique contact id, LParam is your plugin data pointer (if added).
  PM_PLUGIN_SPEC_RIGHT_CLK  = 53; //qip -> plugin, user right clicked on spec contact to see popup menu. WParam is unique contact id, LParam is your plugin data pointer (if added). NParam is PPoint where PopupMenu can be popuped (screen coordinates).
  PM_PLUGIN_FADE_CLICK      = 54; //qip -> plugin, user left clicked on plugin created fade message. WParam is unique fade msg id given in Result of PM_PLUGIN_FADE_MSG.
  PM_PLUGIN_FADE_CLOSE      = 55; //plugin -> qip, plugin can close own fade msg. WParam is unique fade msg id. If Result = True then found and closed, else was already closed or not found.
  PM_PLUGIN_GET_PROFILE_DIR = 56; //plugin -> qip, plugin can get QIP Infium "Profiles" folder to write there any needed files in case if access denied when trying to write into Plugins folder. If Core returns Result = True then it returns WParam = PWideChar of profiles folder path.
  PM_PLUGIN_GET_COLORS_FONT = 57; //plugin -> qip, plugin can get contact list font name and size and qip colors. Core will return WParam = PWideChar of contact list font name, LParam = font size, NParam = pQipColors (pQipColors definition can be found in u_common.pas).
  PM_PLUGIN_HINT_GET_WH     = 58; //qip -> plugin, user moved mouse cursor over spec contact, WParam is unique spec contact id, Result is your plugin data pointer (if added). To show hint window core have to know size of hint window. Plugin should return LParam = Width of hint window and NParam = Height of hint window.
  PM_PLUGIN_HINT_DRAW       = 59; //qip -> plugin, follows after PM_PLUGIN_HINT_GET_WH if mouse cursor still over spec contact. Here hint can be drawn by plugin. WParam is spec contact id, LParam is Canvas HDC, NParam is PRect of drawing rectangle, Result is your plugin data pointer (if added);
  PM_PLUGIN_GET_CONTACT_ST  = 60; //plugin -> qip, plugin can get current contact status. WParam have to be protocol handle, LParam = PWideChar of contact account name. If Core returned Result = False then there is NO such contact in contact list and in "not in list" group. If Core returned Result = True then contact found and status added to NParam.
  PM_PLUGIN_INFIUM_CLOSE    = 61; //plugin -> qip, plugin can close or restart QIP Infium. If Wparam = 0 then infium will be closed, if WParam = 1 then will be restarted. Becareful using this msg, it will destroy everything, including your plugin;
  PM_PLUGIN_GET_NET_SET     = 62; //plugin -> qip, plugin can get network connection parameters. If Core returns Result = True then it added to WParam pointer pNetParams (pNetParams definition can be found in u_plug_info.pas);
  PM_PLUGIN_BROADCAST       = 63; //plugin -> qip -> plugins (excepting plugin-sender and disabled plugins), plugins can exchange any data if needed, WParam, LParam, NParam, Result can be changed by any plugin. Do NOT change Msg and DllHandle values of message on broadcast. Plugin-receiver can stop broadcast by setting Msg value = 0;
  PM_PLUGIN_FIND            = 64; //plugin -> qip, plugin can check if any other plugin exists and enabled/disabled. WParam is plugin name added by its author to find (not case sensetive). Core will return Result = True if plugin with this name loaded/enabled and WParam will be pPluginInfo of requested plugin, LParam will be count of plugins with this name (can be more than 1), if NParam = True then plugin Enabled;
  PM_PLUGIN_MESSAGE         = 65; //plugin -> qip -> plugin. Plugins can exchange any data if needed, WParam is receiver plugin DllHandle found by PM_PLUGIN_FIND. You can add any data to LParam, NParam and Result for receiver plugin;
  PM_PLUGIN_ENUM_PLUGINS    = 66; //plugin -> qip. Plugin can enumerate all plugins (including disabled plugins). PM_PLUGIN_ENUM_INFO will be sent with plugin info(can be more than one message), every message for every plugin;
  PM_PLUGIN_ENUM_INFO       = 67; //qip -> plugin. Enumeration reply. WParam is pPluginInfo of one of the enumerated plugin, if LParam = True then plugin Enabled, if NParam = True then this is the last plugin info and enumeration finished;
  PM_PLUGIN_SPEC_DRAG_START = 68; //qip -> plugin. Request for drag a special contact to desktop. WParam is unique dword id of contact. If Result = True then speccontact will start dragging, otherwise cursor will be "disallowed"
  PM_PLUGIN_SPEC_DRAG_END   = 69; //qip -> plugin. Notify about dragging is done. WParam is unique dword id of contact. If LParam = True then speccontact is dropped to desktop, otherwise it is dropped back to CL or to taskbar. NParam is PPoint of drop point
  PM_PLUGIN_IS_ACC_IN_NIL   = 70; //plugin -> qip. retrieve information for contact. WParam is PWideChar of account name information about is retreived, LParam is dll handle of protocol (if NULL - NParam will be used), NParam is PWideChar of protocol name of account; Result is True if the contact is in NotInList group
  PM_PLUGIN_GET_CL_SNAPSHOT = 71; //plugin -> qip. creates contact list snapshot. WParam is ICLSnapshot interface. LParam is Protocol Handle or NULL. if NULL - all contacts of all protos will be enumerated
  PM_PLUGIN_CL_CHANGED      = 72; //qip -> plugin. Notifies plugin that contact-list changed (added or deleted contact)
  PM_PLUGIN_OPEN_FOCUS_TAB  = 73; //plugin -> qip. open message window or chat window with contact tab focused. WParam is PWideChar of account name, LParam is dll handle of protocol (if NULL - NParam will be used), NParam is PWideChar of protocol name of account; Result is True if the tab opened
  PM_PLUGIN_CLEAR_EVENT     = 74; //plugin -> qip. clears incoming event. WParam is PWideChar of account name, LParam is dll handle of protocol (if NULL - NParam will be used), NParam is PWideChar of protocol name of account;
  PM_PLUGIN_GET_SKIN_HANDLE = 75; //plugin -> qip. getting a handle of skin library. Will be placed in Msg.Result. Note that library is loaded as memory-mapped
  PM_PLUGIN_ADD_OVERLAY_ICN = 76; //plugin -> qip. add overlay icon to core imagelist. WParam is pOverlayIcon. Result is unique number (used in next 3 messages). Core will copy the memory from pIconOverlay
  PM_PLUGIN_UPD_OVERLAY_ICN = 77; //plugin -> qip. Update an overlay Icon for contact. WParam is pOverlayIcon, LParam is unique number of icon. Set NParam to non-zero if you want all the contacts to invalidate after updasting. Result = True if successful
  PM_PLUGIN_DEL_OVERLAY_ICN = 78; //plugin -> qip. Delete an overlay Icon for contact. WParam is unique number of icon. Result is True if successful
  PM_PLUGIN_SET_OVERLAY_ICN = 79; //plugin -> qip. Set an icon for a specified contact. WParam is PWideChar of account, LParam is dll handle of protocol, NParam is Unique number. Result is true if successful
  PM_PLUGIN_GET_META_CONT   = 80; //plugin -> qip. Get Metacontact that spared with specified contact. WParam is ProtoHandle, LParam is AccountName of contact. Result is IMetaContact interface
  PM_PLUGIN_PROTOS_SNAPSHOT = 81; //plugin -> qip. creates protolist snapshot. WParam is ICLSnapshot interface.
  PM_PLUGIN_SET_DETAILS     = 82; //plugin -> qip. Sets details information. WParam is ProtoHandle, LParam is PWideChar AccountName, NParam is pContactDetails. returns True if successfully updates contact details. note: only fileds that are editable in details window will be updated (ContactName, HomePhone, HomeFax, HomeCell, WorkPhone, WorkFax, Note, Additional)
  PM_PLUGIN_NOTIF_ADD_ICON  = 83; //plugin -> qip. Before adding info message, add icon to chat imagelist (to reduce gdi). WParam is HICON, LParam is TPngObject. Result is Icon offset in imagelist
  PM_PLUGIN_NOTIF_SEND_CHAT = 84; //plugin -> qip. Adds info message to chat with optional buttons. WParam is ProtoHandle, LParam is PWideChar AccountName, NParam is pNotifInfo. Result is NotifID
  PM_PLUGIN_NOTIF_BTN_CLICK = 85; //qip -> plugin. Notifies plugin that user has clicked one of defined buttons at info message. WParam is NotifID, LParam is ButtonID (See nid_XXX consts). NParam is BtnData. Set Result to True if you want all buttons to disable after user click
  PM_PLUGIN_NOTIF_BTN_DISBL = 86; //plugin -> qip. Disable specified button or all buttons in info message. WParam is ProtoHandle, LParam is PWideChar AccountName, NParam is NotifID. Set Result to -1 if the core should disable all buttons or ButtonID for disable
  PM_PLUGIN_ACTIVE_MSG_TAB  = 87; //plugin -> qip. Request for active messagetab contact. Set WParam to True if you want to search active focused tab/window (this may be separate window or tabbed window) and to False if you only want to know last active tab. Core will return AccountName in WParam (PWideChar), ProtoHandle in LParam, Subcontact count in NParam.
  PM_PLUGIN_ACTIVE_CHAT_TAB = 88; //plugin -> qip. Request for active chat tab.           Set WParam to True if you want to search active focused tab/window (this may be separate window or tabbed window) and to False if you only want to know last active tab. Core will return PWideChar of chat name in WParam, LParam is PWideChar of own nick, NParam is PWideChar of chat tab caption. Result is protocol handle
  PM_PLUGIN_IS_META_MODE    = 89; //plugin -> qip. Result is True if meta-mode is active
  PM_PLUGIN_GET_QIPHIST     = 90; //plugin -> qip. Request for IQIPHistory interface from core. returns in Result
  PM_PLUGIN_GET_PLUGHIST    = 91; //qip -> plugin. Request for IPluginHistory interface from plugin. set Result if your plugin supports that interface
  PM_PLUGIN_CORE_SVC_FADE   = 92; //qip -> plugin. Core is about to show svc fade (message fades are not included). WParam is pFadeWndInfo. set Result to False to prevent fade to be shown. do not set to true if you not sure you want it. 
  PM_PLUGIN_DETAILS_CHANGED = 93; //qip -> plugin. Core notification that contact details has been changed. WParam is AccountName, LParam is ProtoHandle
  PM_PLUGIN_GET_PROTO_ST    = 94; //plugin -> qip. Request for proto status. WParam is ProtoHandle (to retrieve it, use enumeration or any message with protohandle). Result is status number (see QIP_STATUS_ consts) or -1 if proto doesn't exist
  PM_PLUGIN_PROTO_ST_CHANGED= 95; //qip -> plugin. Notifies plugin that specified proto status has been changed. Wparam is protohandle, LParam is new status (see QIP_STATUS_ consts)
  PM_PLUGIN_GET_CONT_XST    = 96; //plugin - > qip. Request for contact x-status description text. WParam is PWideChar accountname. LParam is protohandle. [in] NParam is result memory len. [out] Result is PWideChar of x-status text (memory for result should be allocated in plugin). [out] NParam is custom status picture number.
  PM_PLUGIN_CONT_XST_CHANGE = 97; //qip -> plugin. Notifies plugin that contact x-status description text has been changed. Wparam is PWideChar accountname. LParam is protohandle. NParam is custom status picture number (may be -1 - means status message). Result is PWideChar of new x-status text
  PM_PLUGIN_CL_FILTERED     = 98; //qip -> plugin. Notifies plugin that CL filter has been changed. Use this message for fake contacts filtering. WParam is PWideChar of filter text
  PM_PLUGIN_CHAT_MSG_RCVDNEW= 99; //qip -> plugin. Since SDK 1.8.5 extends PM_PLUGIN_CHAT_MSG_RCVD. WParam is PWideChar of chat name, LParam is chat text type see below, NParam is pChatTextInfo
  PM_PLUGIN_CTAB_ACTIVATED  = 100; //qip -> plugin. Notifies plugin that specified chat tab has been activated. WParam is PWideChar of chat name, LParam is ProtoHandle
  PM_PLUGIN_WANT_SEND_FILES = 101; //qip -> plugin. Notifies plugin that file(s) has been dropped to text field or plugin button or send file button pressed. WParam is PDropFilesInfo. LParam is True if file has been dropped to plugin button. Set Result To True if you want to disable core filetransfer
  PM_PLUGIN_FILE_SEND       = 102; //plugin -> qip. Request to send specified group of files. WParam is PDropFilesInfo. LParam controls type of files upload. see SFT_ consts. Result is True if filetransfer started
  PM_PLUGIN_FILE_ACCEPT     = 103; //qip -> plugin. Notifies plugin that specified group of files came from contact. WParam is PWideChar of AccountName, LParam is ProtoHandle, NParam is PDropFilesInfo. Set Result to True if you want core to accept filetransfer
  PM_PLUGIN_GET_RIGHTS_MASK = 104; //plugin -> qip. Retrieve actions that allowed for plugin. Result is bitmask of PRM_ consts
  PM_PLUGIN_ADD_MENU_ITEMS  = 105; //qip -> plugin. Occured before showing popup menu from chat view or edit field and some text is selected. WParam is selected text. LParam is assigned url (for images or [url="uri"]text[/url]). NParam is True if popup menu is about to show on picture/video. Set Result to True if you want to add menu item, set Lparam to menu items count to be added, point NParam to MenuItems array (PMenuItems).
  PM_PLUGIN_MENU_ITEM_CLICK = 106; //qip -> plugin. Notifies plugin that popup menu item has been clicked. WParam is ItemID of menuitem. LParam is ItemData. Nparam is selected text. if menu is popping up on picture/video then Result is pic/video ItemID (see PM_PLUGIN_MEDIA_CONTROL)
  PM_PLUGIN_MEDIA_CONTROL   = 107; //plugin -> qip. Control over specified picture or video. WParam is PWideChar of AccountName, LParam is DllHandle. NParam is ItemID of pic/video. Result is control command (see PVC_ consts). Returning Result depends on command
  PM_PLUGIN_ENUM_MEDIA      = 108; //plugin -> qip. Request list of pictures/video in specified tab. WParam is PWideChar of AccountName, LParam is DllHandle. Result is True if enumeration is possible
  PM_PLUGIN_MEDIA_CALLBACK  = 109; //qip -> plugin. Enumeration reply. WParam is ItemID of picture/video. Lparam is True if media is picture. Return True if you want to stop enumeration.
  PM_PLUGIN_TAB_CREATED     = 110; //qip -> plugin. Notifies plugin that new tab has been created. WParam is PWideChar of AccountName, LParam is DllHandle, NParam is Boolean flag that tab/window is created and activated
  PM_PLUGIN_ADD_CL_MENU_ITEMS  = 111; //qip -> plugin. Occured before showing popup menu on contact (CL or message tab). WParam is pIMetaContact of contact. LParam is True if popup menu is about to show on message tab. Set Result to True if you want to add menu item, set Lparam to menu items count to be added, point NParam to MenuItems array (PMenuItems).
  PM_PLUGIN_CL_MENU_ITEM_CLICK = 112; //qip -> plugin. Notifies plugin that popup menu item has been clicked. WParam is ItemID of menuitem. LParam is ItemData. Nparam is pIMetaContact of contact.
  PM_PLUGIN_URL_CLICK          = 113; //qip -> plugin. Notifies, that user has clicked a special-forme url from bb-code ([url="plugin:MyHandle"]anytext[/url]). WParam is PWideChar of AccountName of tab where the link has been clicked, LParam is proto DllHandle, NParam is PWideChar of Text
  //to be continued ...

  {QIP msg types (http://wiki.qip.ru/SDK_Const#MSG_TYPE)}
  MSG_TYPE_UNK        = $00; //unknown msg type
  MSG_TYPE_TEXT       = $01;
  MSG_TYPE_CHAT       = $02;
  MSG_TYPE_FILE       = $03;
  MSG_TYPE_URL        = $04;
  MSG_TYPE_AUTH       = $05;
  MSG_TYPE_ADDED      = $06;
  MSG_TYPE_SERVER     = $07;
  MSG_TYPE_WEB        = $08;
  MSG_TYPE_CONTACTS   = $09;
  MSG_TYPE_AUTO       = $0A;
  MSG_TYPE_SERVICE    = $0B;
  MSG_TYPE_EMAIL      = $0C;
  MSG_TYPE_OFFMSG     = $0D;
  MSG_TYPE_AUTHREPLY  = $0E;
  MSG_TYPE_HISTDLVRD  = $0F;
  MSG_TYPE_INVITE     = $10;
  MSG_TYPE_PLUGNOTIF  = $11;

  {QIP global statuses for plugins (http://wiki.qip.ru/SDK_Const#QIP_STATUS)}
  QIP_STATUS_ONLINE 	        = $00;
	QIP_STATUS_INVISIBLE 	      = $01;
	QIP_STATUS_INVISFORALL	    = $02;
  QIP_STATUS_FFC	 	          = $03;
  QIP_STATUS_EVIL	            = $04;
  QIP_STATUS_DEPRES           = $05;
  QIP_STATUS_ATHOME		        = $06;
  QIP_STATUS_ATWORK		        = $07;
  QIP_STATUS_OCCUPIED	        = $08;
	QIP_STATUS_DND		          = $09;
  QIP_STATUS_LUNCH		        = $0A;
  QIP_STATUS_AWAY		          = $0B;
  QIP_STATUS_NA		            = $0C;
  QIP_STATUS_OFFLINE 	        = $0D;
  QIP_STATUS_CONNECTING       = $0E;
  QIP_STATUS_NOTINLIST        = $0F;

  {QIP global privacy status (http://wiki.qip.ru/SDK_Const#QIP_STATUS_PRIV)}
  QIP_STATUS_PRIV_VIS4ALL     = $01;
  QIP_STATUS_PRIV_INVIS4ALL   = $02;
  QIP_STATUS_PRIV_VIS4VIS     = $03;
  QIP_STATUS_PRIV_VISNORM     = $04;
  QIP_STATUS_PRIV_VIS4CL      = $05;

  {Chat text types (http://wiki.qip.ru/SDK_Const#CHAT_TEXT)}
  CHAT_TEXT_TOPIC        =  0;
  CHAT_TEXT_OWN_MESSAGE  =  1;
  CHAT_TEXT_MESSAGE      =  2;
  CHAT_TEXT_JOINED       =  3;
  CHAT_TEXT_QUIT         =  4;
  CHAT_TEXT_DISCONNECTED =  5;
  CHAT_TEXT_NOTIFICATION =  6;
  CHAT_TEXT_HIGHLIGHTED  =  7;
  CHAT_TEXT_INFORMATION  =  8;
  CHAT_TEXT_ACTION       =  9;
  CHAT_TEXT_KICKED       = 10;
  CHAT_TEXT_MODE         = 11;
  CHAT_TEXT_SEPARATOR    = 12;

  {QIP SOUND IDs (http://wiki.qip.ru/SDK_Const#QIP_SND_ID)}
  QIP_SND_ID_STARTUP        = 1;
  QIP_SND_ID_INC_MSG        = 2;
  QIP_SND_ID_MSG_SENT       = 3;
  QIP_SND_ID_ONLINE_ALERT   = 4;
  QIP_SND_ID_STATUS_NOTIFY  = 5;
  QIP_SND_ID_TRAY_NOTIFY    = 6;
  QIP_SND_ID_AUTH_REQUEST   = 7;
  QIP_SND_ID_AUTH_DENIED    = 8;
  QIP_SND_ID_AUTH_GRANTED   = 9;
  QIP_SND_ID_ADDED          = 10;
  QIP_SND_ID_INC_FILE       = 11;
  QIP_SND_ID_FT_COMPLETE    = 12;
  QIP_SND_ID_SERVER_MSG     = 13;
  QIP_SND_ID_EMAIL_MSG      = 14;

  //http://wiki.qip.ru/SDK_Const#NIB
  NIB_NONE             = 0;    // no buttons will show
  NIB_OK               = 1;    // ok button
  NIB_OKCANCEL         = 2;    // ok and cancel buttons
  NIB_YESNO            = 3;    // yes and no buttons
  NIB_YESNOCANCEL      = 4;    // yes, no and cancel buttons
  NIB_ABORTRETRYIGNORE = 5;
  NIB_RETRYCANCEL      = 6;
  NIB_CONFIRMDECLINE   = 7;
  NIB_CONFIRMCANCEL    = 8;
  NIB_USERBUTTON       = 254;  // one user-defined button
  NIB_USERBUTTON2      = 255;  // two user-defined buttons

  //http://wiki.qip.ru/SDK_Const#nid
  nid_Ok          = 1;
  nid_Cancel      = 2;
  nid_Yes         = 3;
  nid_No          = 4;
  nid_Abort       = 5;
  nid_Retry       = 6;
  nid_Ignore      = 7;
  nid_Confirm     = 8;
  nid_Decline     = 9;
  nid_UserButton1 = 254;
  nid_UserButton2 = 255;

  //http://wiki.qip.ru/SDK_Const#SFT
  SFT_CORE_DECIDES = 0;
  SFT_DIRECT       = 1;
  SFT_FILE_QIP     = 2;

  //http://wiki.qip.ru/SDK_Const#PRM
  PRM_NOTHING_ALLOWED      = 0;
  PRM_FILE_ACCEPT_ALLOWED  = 1;
  PRM_FILE_SENDING_ALLOWED = 2;

  //http://wiki.qip.ru/SDK_Const#PVC
  PVC_GET_URL         = 1;
  PVC_RELOAD          = 2;
  PVC_DROP_CLEAR      = 3;
  PVC_COPY_TO_CB      = 4;
  PVC_OPEN_IN_BROWSER = 5;

  PLUGIN_URL_SCHEME: WideString = 'plugin:';

implementation

end.
