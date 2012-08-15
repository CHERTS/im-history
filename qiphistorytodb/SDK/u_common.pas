{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://www.qip.im             }
{                                     }
{*************************************}
{ This module is common for core, protos
  and plugins, thats why some records can
  be here and some in u_plugin_info }

unit u_common;

interface

uses Windows;

type
  {Plugin specific options which will be saved in profile}
  {see http://wiki.qip.ru/SDK_Types#TPluginSpecific }
  TPluginSpecific = record
    Bool1       : Boolean;
    Bool2       : Boolean;
    Bool3       : Boolean;
    Bool4       : Boolean;
    Bool5       : Boolean;
    Bool6       : Boolean;
    Bool7       : Boolean;
    Bool8       : Boolean;
    Bool9       : Boolean;
    Bool10      : Boolean;
    Param1      : DWord;
    Param2      : DWord;
    Param3      : DWord;
    Param4      : DWord;
    Param5      : DWord;
    Param6      : DWord;
    Param7      : DWord;
    Param8      : DWord;
    Param9      : DWord;
    Param10     : DWord;
    Wstr1       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr2       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr3       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr4       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr5       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr6       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr7       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr8       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr9       : WideString; //Max length = 65535 after encoding to UTF8
    Wstr10      : WideString; //Max length = 65535 after encoding to UTF8
  end;
  pPluginSpecific = ^TPluginSpecific;

  {Adding button below avatar in msg and chat windows}
  {see http://wiki.qip.ru/SDK_Types#TAddBtnInfo }
  TAddBtnInfo = record
    BtnIcon : HICON;      //size must be 16x16, if you creating new HICON then after adding button dont forget to destroy it in your plugin.
    BtnPNG  : LongInt;    //size must be 16x16, LongInt(TPngObject) from PngImage library, delphi only. Else have to be 0. After adding button dont forget to destroy it in your plugin.
    BtnHint : WideString; //hint of the button.
    BtnData : LongInt;    //pointer of plugin specified data, will be returned on click. Since sdk 1.6.
  end;
  pAddBtnInfo = ^TAddBtnInfo;

  {plugins only}
  {see http://wiki.qip.ru/SDK_Types#TBtnClick }
  TBtnClick = record
    BtnData    : LongInt; //pointer of plugin specified data. Since sdk 1.6.
    RightClick : Boolean; //in case if user right clicked on btn
  end;
  pBtnClick = ^TBtnClick;

  //QIP Colors, delphi bgr
  {see http://wiki.qip.ru/SDK_Types#TQipColors }
  TQipColors = record
    AccBtnText     : integer;
    AccBtn         : integer;
    AccBtnGrad     : integer;
    AccBtnFrameL   : integer;
    AccBtnFrameD   : integer;
    Divider        : integer;
    Group          : integer;
    Counter        : integer;
    Online         : integer;
    Offline        : integer;
    NotInList      : integer;
    OffMsg         : integer;
    Focus          : integer;
    FocusGrad      : integer;
    FocusFrame     : integer;
    Hint           : integer;
    HintGrad       : integer;
    HintFrame      : integer;
    IncEvents      : integer;
    OutEvents      : integer;
    FadeTitle      : integer;
    FadeText       : integer;
    TabBorder      : integer;
    TabBorderDrk   : integer;
    TabInactive    : integer;
    TabInactGrad   : integer;
    TabActive      : integer;
    TabActGrad     : integer;
    TabActLiTop    : integer;
    TabActLight    : integer;
    TabFontInact   : integer;
    TabFontAct     : integer;
    ChatTopic      : integer;
    ChatTime       : integer;
    ChatOwnNick    : integer;
    ChatContNick   : integer;
    ChatOwnText    : integer;
    ChatContText   : integer;
    ChatJoined     : integer;
    ChatLeft       : integer;
    ChatDiscon     : integer;
    ChatNotice     : integer;
    ChatHighLi     : integer;
    ChatInfoText   : integer;
    ChatActText    : integer;
    ChatKickText   : integer;
    ChatModeText   : integer;
    BgPicClOff     : Boolean;
    BgPicMsgOff    : Boolean;
    BgPicChatOff   : Boolean;
    BgClColor      : integer;
    BgMsgColor     : integer;
    BgChatColor    : integer;
    HistContacts   : integer;
    XStTextColor   : integer;
    RootSlctdColor : integer;
    ContactSlctdClr: integer;
    ChatTabBorder   : integer;
    ChatTabBorderDrk: integer;
    ChatTabInactive : integer;
    ChatTabInactGrad: integer;
    ChatTabActive   : integer;
    ChatTabActGrad  : integer;
    ChatTabActLiTop : integer;
    ChatTabActLight : integer;
    ChatTabFontInact: integer;
    ChatTabFontAct  : integer;
    BgPicClStatic  : Boolean;
    BgPicMsgStatic : Boolean;
    BgPicChatStatic: Boolean;
    SpellingColor  : Integer;
    ItemBorderColor        : Integer;
    SelectedItemStartColor : Integer;
    SelectedItemEndColor   : Integer;
    SelectedItemBorderColor: Integer;
    SubItemBgColor         : Integer;
    FixedStartColor        : Integer;
    FixedEndColor          : Integer;
    ItemTextColor          : Integer;
    FxdItemTextColor       : Integer;
    SelItemTextColor       : Integer;
    SelFxdTextColor        : Integer;
    LabelItemTextColor     : Integer;
    MarkEventColor         : Integer;
    MarkEventGradientColor : Integer;
    MarkFontColor          : Integer;
  end;
  pQipColors = ^TQipColors;

  {see http://wiki.qip.ru/SDK_Types#TOverlayIcon }
  TOverlayIcon = record
    Memory    : Pointer;    //Pointer to existing memory. supports BMP, JPG and PNG here
    MemoryLen : Integer;    //memory length
  end;
  pOverlayIcon = ^TOverlayIcon;

  TQipSkinFont = record
    Name: WideString;
    Size: Integer;
    GroupFontSize: Integer;
  end;
  
  {see http://wiki.qip.ru/SDK_Types#TNotifInfo }
  TNotifInfo = record
    IconID       : Integer; //add to imagelist with PM_PLUGIN_NOTIF_ADD_ICON to get. -1 means no icon
    Text         : WideString;
    FromText     : WideString;//by default message will be equal to plugin name. set this field to override it
    Buttons      : Cardinal;  //see NIB_XXX consts
    UserBtnText1 : WideString;
    UserBtnText2 : WideString;
    NotifData    : LongInt;
    Incoming     : Boolean;
  end;
  pNotifInfo = ^TNotifInfo;

  {see http://wiki.qip.ru/SDK_Types#TDropFilesInfo }
  TDropFilesInfo = record
    FileCount   : Integer;
    FileList    : WideString; //list of files separated by CRLF
    ToChat      : Boolean;    //true if files are sent into chat
    AccountName : WideString; //accountname or chatname
    ProtoHandle : Integer;
    DropBtnInfo : TBtnClick;  //optional BtnData if files are dropped to plugin button
  end;
  PDropFilesInfo = ^TDropFilesInfo;

implementation

end.
