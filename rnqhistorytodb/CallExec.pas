unit CallExec;

interface
{$I Compilers.inc}
{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}
uses
 plugin,
 pluginutil,
 Types,
 Graphics,
 Windows;

 type
 {$IFNDEF UNICODE}
  RawByteString = AnsiString;
 {$ENDIF UNICODE}

 ContactInfo=record
   UIN:integer;
   Status:byte;
   Invisible:boolean;
   DisplayedName, First, Last:AnsiString
 end;

var
  callback:TpluginFun;      // &RQ callback function
  outBuffer:RawByteString;
  plugsendflag: boolean = false;

function str2comm(s:RawByteString):pointer;
function callStr(s:RawByteString):pointer;

{####################################}
//           --===  Commands  ===--
procedure RQ_SendMsg(uin, Flag:integer; msg:AnsiString);

function  RQ_GetRoasterList:TIntegerDynArray;
function  RQ_GetIgnoreList:TIntegerDynArray;
function  RQ_GetChatWindow(var wnd:HWND; var left, top, width, height:integer):integer;
function  RQ_GetRoasterWindow(var wnd:HWND; var left, top, width, height:integer):integer;
function  RQ_GetPrefWindow(var wnd:HWND; var left, top, width, height:integer):integer;

procedure RQ_SendContacts(uin, Flag:integer; contacts:TIntegerDynArray);
procedure RQ_SendAddedYou(uin:integer);
function  RQ_AddToList(List:integer; uins:TIntegerDynArray):integer;
function  RQ_RemoveFromList(List:integer; uins:TIntegerDynArray):integer;
procedure RQ_SetStatus(Status:byte);
procedure RQ_SetVisibility(Visibility:byte);
procedure RQ_Quit;
procedure RQ_Connect;
procedure RQ_Disconnect;
procedure RQ_SetAutoMessage(AutoMessage:AnsiString);
procedure RQ_SendAutoMessageRequest(uin:integer);
// -
function  RQ_CreateChatButton(buttonProc:pointer; buttonIcon: hIcon;
              buttonHint:AnsiString; PicName : AnsiString = ''):integer;
procedure RQ_ChangeChatButton(buttonAddr:Integer; buttonIcon: hIcon;
              buttonHint:AnsiString; PicName : AnsiString = '');
procedure RQ_DeleteChatButton(var buttonAddr:Integer);
{####################################}
//           --===  Get  ===--
function  RQ_GetTime:Double;
function  RQ_GetList(List:integer):TIntegerDynArray;
function  RQ_GetContactInfo(uin:integer):ContactInfo;
function  RQ_GetName(uin:integer): AnsiString;
function  RQ_GetDisplayedName(uin:integer):AnsiString;
function  RQ_GetAwayTime:double;
function  RQ_GetAndrqPath:AnsiString;
function  RQ_GetUserPath:AnsiString;
function  RQ_GetAndrqVersion:integer;
function  RQ_GetRnQVersion: Integer;
function  RQ_GetAndrqVersionAsString:AnsiString;
function  RQ_GetCurrentUser:integer;
function  RQ_GetUserTime:double;
function  RQ_GetConnectionState:integer;
function  RQ_GetWindow(window:integer; var wnd:HWND; var left, top, width, height:integer):integer;
function  RQ_GetAutoMessage:AnsiString;
function  RQ_GetChatUIN:integer;
{####################################}
procedure RQ__ParseInitString(data:Pointer; var callback:TpluginFun; var apiVersion:integer;
                              var andrqPath, userPath:AnsiString; var currentUIN:integer);
procedure RQ__ParseMsgGotString(data:pointer; var uin, flags:integer; var when:TDateTime;
                                var msg:AnsiString);
procedure RQ__ParseMsgSentString(data:pointer; var uin, flags:integer; var msg:AnsiString);
procedure RQ__ParseURLGotString(data:Pointer; var uin, flags:integer; var when:TDateTime; var URL, text:AnsiString);
procedure RQ__ParseAddedYouSentString(data:Pointer; var uin:integer);
procedure RQ__ParseAddedYouGotString(data:Pointer; var uin, flags:integer; var when:TDateTime);
procedure RQ__ParseContactsSentString(data:Pointer; var uin, flags:integer; var contacts:TIntegerDynArray);
procedure RQ__ParseContactsGotString(data:Pointer; var uin, flags:integer; var when:TDateTime;
                                     var contacts:TIntegerDynArray);
procedure RQ__ParseAuthSentString(data:Pointer; var uin:integer);
procedure RQ__ParseAuthRequestGotString(data:Pointer; var uin, flags:integer; var when:TDateTime; var text:AnsiString);
procedure RQ__ParseAuthDeniedSentString(data:Pointer; var uin:integer; var text:AnsiString);
procedure RQ__ParseAutoMessageSentString(data:Pointer; var uin:integer; var text:AnsiString);
procedure RQ__ParseAutoMessageGotString(data:Pointer; var uin:integer; var text:AnsiString);
procedure RQ__ParseAutoMessageRequestSentString(data:Pointer; var uin:integer);
procedure RQ__ParseAutoMessageRequestGotString(data:Pointer; var uin:integer);
procedure RQ__ParseVisibilityChanged(data:Pointer; var contact:integer);
procedure RQ__ParseUserinfoChanged(data:Pointer; var uin:integer);
procedure RQ__ParseStatusChanged(data:Pointer; var uin:integer; var newStatus, oldStatus:byte;
                                 var newInvisibleState, oldInvisibleState:Boolean);
procedure RQ__ParseListAddString(data:Pointer; var list:byte; var uins:TIntegerDynArray);
procedure RQ__ParseListRemoveString(data:Pointer; var list:byte; var uins:TIntegerDynArray);
{####################################}

implementation

uses
 SysUtils;

// convert a string to a "plugin communication"
function str2comm(s:RawByteString):pointer;
begin
outBuffer:=_int(length(s))+s;
result:=@outBuffer[1];
end; // str2comm

// execute callback on a string instead of pointer
function callStr(s:RawByteString):pointer;
begin
 result:=callback(str2comm( s ))
end;

{##############################################################################}

procedure RQ_SendMsg(uin, Flag:integer; msg:AnsiString);
{     Flag:
  Single  =0
  Multi   =1   }
begin
 PlugSendFlag := false;
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SEND_MSG)+_int(uin)+_int(Flag)+_istring(msg));
end;

procedure RQ_SendContacts(uin, Flag:integer; contacts:TIntegerDynArray);
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SEND_CONTACTS)+_int(uin)+_int(Flag)+_intlist(contacts));
end;

procedure RQ_SendAddedYou(uin:integer);
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SEND_ADDEDYOU)+_int(uin));
end;

function  RQ_AddToList(List:integer; uins:TIntegerDynArray):integer;
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_LIST_ADD)+AnsiChar(List)+_intlist(uins));
end;

function  RQ_RemoveFromList(List:integer; uins:TIntegerDynArray):integer;
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_LIST_REMOVE)+AnsiChar(List)+_intlist(uins));
end;

procedure RQ_SetStatus(Status:byte);
{   PS_ONLINE, PS_OCCUPIED, PS_DND
    PS_NA, PS_AWAY, PS_F4C, PS_OFFLINE, PS_UNKNOWN   }
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SET_STATUS)+AnsiChar(Status));
end;

procedure RQ_SetVisibility(Visibility:byte);
{   PV_ALL, PV_NORMAL, PV_PRIVACY, PV_INVISIBLE   }
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SET_VISIBILITY)+AnsiChar(Visibility));
end;

procedure RQ_Quit;
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_QUIT));
end;

procedure RQ_Connect;
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_CONNECT));
end;

procedure RQ_Disconnect;
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_DISCONNECT));
end;

procedure RQ_SetAutoMessage(AutoMessage:AnsiString);
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SET_AUTOMSG)+_istring(AutoMessage));
end;

procedure RQ_SendAutoMessageRequest(uin:integer);
begin
 callStr(AnsiChar(PM_CMD)+AnsiChar(PC_SEND_AUTOMSG_REQ)+_int(uin));
end;

{##############################################################################}

function  RQ_GetTime:Double;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_TIME));
 Result:=_double(data,5);
end;

function RQ_GetList(List:integer):TIntegerDynArray;
{
  PL_ROASTER, PL_VISIBLELIST, PL_INVISIBLELIST, PL_TEMPVISIBLELIST,
  PL_IGNORELIST, PL_DB, PL_NIL.
}
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_LIST)+AnsiChar(List));
 Result:=_intlist_at(data,5);
end;

function RQ_GetContactInfo(uin:integer):ContactInfo;
var
 data:Pointer;
 tempCI:ContactInfo;
 a:array[0..50]of AnsiChar;
 i:integer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_CONTACTINFO)+_int(uin));
 for i:=0 to 50 do begin
  a[i]:=AnsiChar(_byte_at(data,i));
 end;
 with tempCI do begin
  UIN:=_int_at(data,9);
  Status:=_byte_at(data,13);
  Invisible:=boolean(_byte_at(data,14));
  DisplayedName:=_istring_at(data,15);
  i:=15+4+Length(DisplayedName);
  First:=_istring_at(data,i);
  i:=i+4+Length(First);
  Last:=_istring_at(data,i);
 end;
 Result.UIN:=length(a);
 Result:=tempCI;
end;

function  RQ_GetDisplayedName(uin:integer):AnsiString;
var
 data:Pointer;
 i:AnsiString;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_DISPLAYED_NAME)+_int(uin));
 i:=_istring_at(data,5);
 Result:=i;
end;

function  RQ_GetAwayTime:double;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_AWAYTIME));
 result:=_double(data, 5);
end;

function  RQ_GetAndrqPath:AnsiString;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_ANDRQ_PATH));
 result:=_istring_at(data, 5);
end;

function  RQ_GetUserPath:AnsiString;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_USER_PATH));
 result:=_istring_at(data, 5);
end;

function  RQ_GetAndrqVersion:integer;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_ANDRQ_VER));
 result:=_int_at(data, 5);
end;


function  RQ_GetRnQVersion: Integer;
var
 data: Pointer;
begin
 data := CallStr(AnsiChar(PM_GET)+AnsiChar(PG_RNQ_BUILD));
 Result := _int_at(data,5)
end;



function  RQ_GetAndrqVersionAsString:AnsiString;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_ANDRQ_VER_STR));
 result:=_istring_at(data, 5);
end;

{ Name }
function RQ_GetName(uin:integer): AnsiString;
var
 data:Pointer;
 i: AnsiString;
begin
 data:=CallStr(AnsiChar(PM_GET)+ AnsiChar(PG_DISPLAYED_NAME)+_int(uin));
 i:=_istring_at(data,5);
 Result:=i;
end;

function RQ_GetCurrentUser:integer;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_USER));
 Result:=_int_at(data,5)
end;

function  RQ_GetUserTime:double;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_USERTIME));
 Result:=_int_at(data,5)
end;

function RQ_GetConnectionState:integer;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_CONNECTIONSTATE ));
 Result:=_int_at(data, 5);
end;

function  RQ_GetWindow(window:integer; var wnd:HWND; var left, top, width, height:integer):integer;
{   PW_ROASTER, PW_CHAT, PW_PREFERENCES   }
var
 data:Pointer;
begin
 data:=callStr( AnsiChar(PM_GET)+AnsiChar(PG_WINDOW)+AnsiChar(PW_CHAT));
 if _byte_at(data,4) = PM_DATA then begin
  wnd:=_int_at(data, 5);
  left:=_int_at(data, 9);
  top:=_int_at(data, 13);
  width:=_int_at(data, 17);
  height:=_int_at(data, 21);
  result:=1;
 end
 else
  result:=0;
end;

function  RQ_GetAutoMessage:AnsiString;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_AUTOMSG));
 Result:=_istring_at(data,5)
end;

function  RQ_GetChatUIN:integer;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+AnsiChar(PG_CHAT_UIN));
 Result:=_int_at(data, 5);
end;

function RQ_CreateChatButton(buttonProc:Pointer; buttonIcon: hIcon;
           buttonHint:AnsiString; PicName : AnsiString = ''):integer;
var
 data:Pointer;
 res:integer;
begin//
 data:=callStr(AnsiChar(PM_CMD)+ AnsiChar(PC_ADDBUTTON)+
              _int(integer(buttonProc))+_int(integer(buttonIcon))+
              _istring(buttonHint)+_istring(PicName));
 res:=_int_at(data, 4);
 Result:=res;
end;

procedure RQ_ChangeChatButton(buttonAddr:Integer; buttonIcon: hIcon;
                  buttonHint:AnsiString; PicName : AnsiString = '');
begin//
 callStr(AnsiChar(PM_CMD)+ AnsiChar(PC_MODIFY_BUTTON)
                       +_int(integer(buttonAddr))+_int(integer(buttonIcon))
                       +_istring(buttonHint)+_istring(PicName));
end;

procedure RQ_DeleteChatButton(var buttonAddr:Integer);
begin//
 callStr(AnsiChar(PM_CMD)+ AnsiChar(PC_DELBUTTON)+_int(integer(buttonAddr)));
 buttonAddr:=0;
end;

{++++++++++++++++++++++++++++++++++++}

procedure RQ__ParseInitString(data:Pointer; var callback:TpluginFun; var apiVersion:integer;
                              var andrqPath, userPath:AnsiString; var currentUIN:integer);

var
 i:integer;
begin
 callback:=_ptr_at(data,6);
 apiVersion:=_int_at(data, 10);
 andrqPath:=_istring_at(data, 14);
 i:=14+4+length(andrqPath);
 userPath:=_istring_at(data, i);
 i:=i+4+length(userPath);
 currentUIN:=_int_at(data, i);
end;

procedure RQ__ParseMsgGotString(data:pointer; var uin, flags:integer; var when:TDateTime;
                                var msg:AnsiString);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 when:=_double(data, 14);
 msg:=_istring_at(data, 22);
end;

procedure RQ__ParseMsgSentString(data:pointer; var uin, flags:integer; var msg:AnsiString);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 msg:=_istring_at(data, 14);
end;

procedure RQ__ParseURLGotString(data:Pointer; var uin, flags:integer; var when:TDateTime; var URL, text:AnsiString);
var
 i:integer;
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 when:=_double(data, 14);
 URL:=_istring_at(data, 22);
 i:=22+4+length(URL);
 text:=_istring_at(data, i);
end;

procedure RQ__ParseAddedYouSentString(data:Pointer; var uin:integer);
begin
 uin:=_int_at(data, 6);
end;

procedure RQ__ParseAddedYouGotString(data:Pointer; var uin, flags:integer; var when:TDateTime);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 when:=_double(data, 14);
end;

procedure RQ__ParseContactsSentString(data:pointer; var uin, flags:integer; var contacts:TIntegerDynArray);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 contacts:=_intlist_at(data, 14);
end;

procedure RQ__ParseContactsGotString(data:Pointer; var uin, flags:integer; var when:TDateTime; var contacts:TIntegerDynArray);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 when:=_double(data, 14);
 contacts:=_intlist_at(data, 22);
end;

procedure RQ__ParseAuthSentString(data:Pointer; var uin:integer);
begin
 uin:=_int_at(data, 6);
end;

procedure RQ__ParseAuthRequestGotString(data:Pointer; var uin, flags:integer; var when:TDateTime; var text:AnsiString);
begin
 uin:=_int_at(data, 6);
 flags:=_int_at(data, 10);
 when:=_double(data, 14);
 text:=_istring_at(data, 22);
end;

procedure RQ__ParseAuthDeniedSentString(data:Pointer; var uin:integer; var text:AnsiString);
begin
 uin:=_int_at(data, 6);
 text:=_istring_at(data, 10);
end;

procedure RQ__ParseAutoMessageSentString(data:Pointer; var uin:integer; var text:AnsiString);
begin
 uin:=_int_at(data, 6);
 text:=_istring_at(data, 10);
end;

procedure RQ__ParseAutoMessageGotString(data:Pointer; var uin:integer; var text:AnsiString);
begin
 uin:=_int_at(data, 6);
 text:=_istring_at(data, 10);
end;

procedure RQ__ParseAutoMessageRequestSentString(data:Pointer; var uin:integer);
begin
 uin:=_int_at(data, 6);
end;

procedure RQ__ParseAutoMessageRequestGotString(data:Pointer; var uin:integer);
begin
 uin:=_int_at(data, 6);
end;

procedure RQ__ParseVisibilityChanged(data:Pointer; var contact:integer);
{   if contact = 0 - all contacts   }
begin
 contact:=_int_at(data, 6);
end;

procedure RQ__ParseUserinfoChanged(data:Pointer; var uin:integer);
begin
 uin:=_int_at(data, 6);
end;

procedure RQ__ParseStatusChanged(data:Pointer; var uin:integer; var newStatus, oldStatus:byte;
                                 var newInvisibleState, oldInvisibleState:Boolean);
begin
 uin:=_int_at(data, 6);
 newStatus:=_byte_at(data, 10);
 oldStatus:=_byte_at(data, 11);
 newInvisibleState:=boolean(_byte_at(data, 12));
 oldInvisibleState:=boolean(_byte_at(data, 13));
end;

procedure RQ__ParseListAddString(data:Pointer; var list:byte; var uins:TIntegerDynArray);
begin
 list:=_byte_at(data, 6);
 uins:=_intlist_at(data, 7);
end;

procedure RQ__ParseListRemoveString(data:Pointer; var list:byte; var uins:TIntegerDynArray);
begin
 list:=_byte_at(data, 6);
 uins:=_intlist_at(data, 7);
end;

{ RoasterList }
function RQ_GetRoasterList:TIntegerDynArray;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+ AnsiChar(PG_LIST)+ AnsiChar(PL_ROASTER));
 Result:=_intlist_at(data,5);
end;

{ IgnoreList }
function RQ_GetIgnoreList:TIntegerDynArray;
var
 data:Pointer;
begin
 data:=CallStr(AnsiChar(PM_GET)+ AnsiChar(PG_LIST)+ AnsiChar(PL_IGNORELIST));
 Result:=_intlist_at(data,5);
end;

function  RQ_GetChatWindow(var wnd:HWND; var left, top, width, height:integer):integer;
var
 data:Pointer;
begin
 data:=callStr( AnsiChar(PM_GET)+ AnsiChar(PG_WINDOW)+ AnsiChar(PW_CHAT));
 if _byte_at(data,4) = PM_DATA then begin
  wnd:=_int_at(data, 5);
  left:=_int_at(data, 9);
  top:=_int_at(data, 13);
  width:=_int_at(data, 17);
  height:=_int_at(data, 21);
  result:=1;
 end
 else
  result:=0;
end;

function  RQ_GetRoasterWindow(var wnd:HWND; var left, top, width, height:integer):integer;
var
 data:Pointer;
begin
 data:=callStr( AnsiChar(PM_GET)+ AnsiChar(PG_WINDOW)+ AnsiChar(PW_ROASTER));
 if _byte_at(data,4) = PM_DATA then begin
  wnd:=_int_at(data, 5);
  left:=_int_at(data, 9);
  top:=_int_at(data, 13);
  width:=_int_at(data, 17);
  height:=_int_at(data, 21);
  result:=1;
 end
 else
  result:=0;
end;

function  RQ_GetPrefWindow(var wnd:HWND; var left, top, width, height:integer):integer;
var
 data:Pointer;
begin
 data:=callStr( AnsiChar(PM_GET)+ AnsiChar(PG_WINDOW)+ AnsiChar(PW_PREFERENCES));
 if _byte_at(data,4) = PM_DATA then begin
  wnd:=_int_at(data, 5);
  left:=_int_at(data, 9);
  top:=_int_at(data, 13);
  width:=_int_at(data, 17);
  height:=_int_at(data, 21);
  result:=1;
 end
 else
  result:=0;
end;

end.
