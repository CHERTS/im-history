Unit pluginutil;
interface
{$I jedi.inc}
{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}
uses
 types, windows, plugin, SysUtils;

function _int(i:integer):AnsiString; overload;
function _int(ints:array of integer):AnsiString; overload;
function _byte_at(p:pointer; ofs:integer=0):byte; overload;
function _byte_at(const s:AnsiString; idx:integer=1):byte; overload;
function _int_at(p:pointer; ofs:integer=0):integer; overload;
function _int_at(const s:AnsiString; idx:integer=1):integer; overload;
function _ptr_at(p:pointer; ofs:integer=0):pointer;
function _istring(const s:AnsiString):AnsiString;
function _istring_at(p:pointer; ofs:integer=0):AnsiString; overload;
function _istring_at(const s:AnsiString; idx:integer=1):AnsiString; overload;
function _intlist(a:array of integer):AnsiString;
function _intlist_at(p:pointer; ofs:integer=0):TintegerDynArray; overload;
function _intlist_at(const s:AnsiString; idx:integer=1):TintegerDynArray; overload;
function _double(p:pointer; ofs:integer=0):double;
// By Rapid D
function _dt(dt:Tdatetime):AnsiString;
function _dt_at(p:pointer; ofs:integer=0): Tdatetime; overload;
function _dt_at(const s: AnsiString; idx:integer=1): Tdatetime; overload;
// By ObServeR
function IntToEvent(ev: integer): AnsiString;
function KeywordToInt(keyword: AnsiString): integer;
function MessageToHex(data:pointer): AnsiString;
function ParseMessageFromRnQ(data:pointer; request:byte = 0): AnsiString;
function ParseEvent(data:pointer): AnsiString;
function ParseError(data:pointer): AnsiString;
function ParseAcknowledge(data:pointer): AnsiString;

implementation

function IntlistToStr(list:TintegerDynArray): AnsiString;
var
	i: integer;
	delim: AnsiString;
begin
	Result := '';
	delim := '';
	for i := 0 to length(list) - 1 do
		begin
		Result := Result + delim + IntToStr(list[i]);
		delim := ', ';
		end;
end;

function ParseAcknowledge(data:pointer): AnsiString;
begin
	case _byte_at(data,5) of
    PA_OK:
      Result := 'PA_OK ';

    else
      Result := '0x' + IntToHex(_byte_at(data,5), 2); //не идентифицирован
  end;

end;

function ParseError(data:pointer): AnsiString;
begin
  case _byte_at(data,5) of
		PERR_ERROR:
      Result := 'PERR_ERROR ';

    PERR_BAD_REQ:
      Result := 'PERR_BAD_REQ ';

    PERR_NOUSER:
      Result := 'PERR_NOUSER ';

    PERR_UNEXISTENT:
			Result := 'PERR_UNEXISTENT ';

    PERR_FAILED_FOR:
      Result := 'PERR_FAILED_FOR ';

    PERR_UNK_REQ:
      Result := 'PERR_UNK_REQ ';

    else
      Result := '0x' + IntToHex(_byte_at(data,5), 2); //не идентифицирована
	end;

end;

function ParseEvent(data:pointer): AnsiString;
begin
  Result := '';

  case _byte_at(data,5) of
    PE_INITIALIZE:
			Result := 'PE_INITIALIZE'
			+ ' callback=0x' + IntToHex(integer(_ptr_at(data,6)), 8)
			+ ' api=' + IntToStr(_int_at(data, 10))
			+ ' rnqpath=' + _istring_at(data, 14)
			+ ' userpath=' + _istring_at(data, 14 + _int_at(data, 14) + 4)
			+ ' uin=' + IntToStr(_int_at(data, 14 + _int_at(data, 14) + 4 + _int_at(data, 14 + _int_at(data, 14) + 4) + 4));

		PE_FINALIZE:
			Result := 'PE_FINALIZE '; //нет параметров

		PE_PREFERENCES:
			Result := 'PE_PREFERENCES '; //нет параметров

		PE_CONNECTED:
			Result := 'PE_CONNECTED '; //нет параметров

		PE_DISCONNECTED:
			Result := 'PE_DISCONNECTED ';  //нет параметров

		PE_MSG_GOT:
			Result := 'PE_MSG_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(TDateTime(_double(data, 14)))
			+ ' msg=' + _istring_at(data, 22);

		PE_MSG_SENT:
			Result := 'PE_MSG_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' msg=' + _istring_at(data, 14);

		PE_CONTACTS_GOT:
			Result := 'PE_CONTACTS_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(_double(data, 14))
			+ ' contacts=' + IntlistToStr(_intlist_at(data, 22));

		PE_CONTACTS_SENT:
			Result := 'PE_CONTACTS_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' contacts=' + IntlistToStr(_intlist_at(data, 14));

		PE_URL_GOT:
			Result := 'PE_URL_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(_double(data, 14))
			+ ' url=' + _istring_at(data, 22)
			+ ' text=' + _istring_at(data, 22 + _int_at(data, 22) + 4);

		PE_URL_SENT:
			Result := 'PE_URL_SENT '; //как сгенерить это событие?

		PE_ADDEDYOU_GOT:
			Result := 'PE_ADDEDYOU_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(_double(data, 14));

		PE_ADDEDYOU_SENT:
			Result := 'PE_ADDEDYOU_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_AUTHREQ_GOT:
			Result := 'PE_AUTHREQ_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(_double(data, 14))
			+ ' text=' + _istring_at(data, 22);

 		PE_AUTHREQ_SENT:
			Result := 'PE_AUTHREQ_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' text=' + _istring_at(data, 10);

    PE_AUTH_GOT:
			Result := 'PE_AUTH_GOT '; //???????????????????????????

    PE_AUTH_SENT:
			Result := 'PE_AUTH_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_AUTHDENIED_GOT:
			Result := 'PE_AUTHDENIED_GOT '; //???????????????????????????

    PE_AUTHDENIED_SENT:
      Result := 'PE_AUTHDENIED_SENT '
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' text=' + _istring_at(data, 10);

    PE_GCARD_GOT:
			Result := 'PE_GCARD_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' flags=0x' + IntToHex(_int_at(data, 10), 8)
			+ ' when=' + DateTimeToStr(_double(data, 14))
			+ ' url=' + _istring_at(data, 22);

    PE_GCARD_SENT:
			Result := 'PE_GCARD_SENT '; //???????????????????????????

    PE_AUTOMSG_GOT:
      Result := 'PE_AUTOMSG_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' text=' + _istring_at(data, 10);

    PE_AUTOMSG_SENT:
      Result := 'PE_AUTOMSG_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' text=' + _istring_at(data, 10);

    PE_AUTOMSG_REQ_GOT:
			Result := 'PE_AUTOMSG_REQ_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_AUTOMSG_REQ_SENT:
			Result := 'PE_AUTOMSG_REQ_SENT'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_EMAILEXP_GOT:
			Result := 'PE_EMAILEXP_GOT'
			+ ' when=' + DateTimeToStr(_double(data, 6))
			+ ' name=' + _istring_at(data, 14)
			+ ' addr=' + _istring_at(data, 14 + _int_at(data, 14) + 4)
			+ ' text=' + _istring_at(data, 14 + _int_at(data, 14) + 4 + _int_at(data, 14 + _int_at(data, 14) + 4) + 4);

		PE_EMAILEXP_SENT:
			Result := 'PE_EMAILEXP_SENT '; //???????????????????????????

		PE_LIST_ADD:
			Result := 'PE_LIST_ADD'
			+ ' list=' + IntToStr(_byte_at(data, 6))
			+ ' uins=' + IntlistToStr(_intlist_at(data, 7));

		PE_LIST_REMOVE:
			Result := 'PE_LIST_REMOVE'
			+ ' list=' + IntToStr(_byte_at(data, 6))
			+ ' uins=' + IntlistToStr(_intlist_at(data, 7));

    PE_STATUS_CHANGED:
      Result := 'PE_STATUS_CHANGED'
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' status=' + IntToStr(_byte_at(data, 10))
			+ ' old=' + IntToStr(_byte_at(data, 11))
			+ ' invis=' + BoolToStr(boolean(_byte_at(data, 12)), true)
			+ ' old=' + BoolToStr(boolean(_byte_at(data, 13)), true);

		PE_USERINFO_CHANGED:
			Result := 'PE_USERINFO_CHANGED'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_VISIBILITY_CHANGED:
			Result := 'PE_VISIBILITY_CHANGED'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		PE_WEBPAGER_GOT:
			Result := 'PE_WEBPAGER_GOT'
			+ ' when=' + DateTimeToStr(_double(data, 6))
			+ ' name=' + _istring_at(data, 14)
			+ ' addr=' + _istring_at(data, 14 + _int_at(data, 14) + 4)
			+ ' text=' + _istring_at(data, 14 + _int_at(data, 14) + 4 + _int_at(data, 14 + _int_at(data, 14) + 4) + 4);

		PE_WEBPAGER_SENT:
			Result := 'PE_WEBPAGER_SENT '; //???????????????????????????

    PE_FROM_MIRABILIS:
			Result := 'PE_FROM_MIRABILIS'
			+ ' when=' + DateTimeToStr(_double(data, 6))
			+ ' name=' + _istring_at(data, 14)
			+ ' addr=' + _istring_at(data, 14 + _int_at(data, 14) + 4)
			+ ' text=' + _istring_at(data, 14 + _int_at(data, 14) + 4 + _int_at(data, 14 + _int_at(data, 14) + 4) + 4);

		PE_UPDATE_INFO:
			Result := 'PE_UPDATE_INFO'
			+ ' info=' + _istring_at(data, 6)
			+ ' ver=' + _istring_at(data, 6 + _int_at(data, 6) + 4)
			+ ' url=' + _istring_at(data, 6 + _int_at(data, 6) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4) + 4)
			+ ' pre=' + BoolToStr(boolean(_byte_at(data, 6 + _int_at(data, 6) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4) + 4) + 4)), true)
			+ ' ver=' + IntToStr(_byte_at(data, 6 + _int_at(data, 6) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4 + _int_at(data, 6 + _int_at(data, 6) + 4) + 4) + 4 + 1));

		PE_SELECTTAB:
			Result := 'PE_SELECTTAB'
			+ ' handle=0x' + IntToHex(_int_at(data, 6), 8);

		PE_DESELECTTAB:
			Result := 'PE_DESELECTTAB'
			+ ' handle=0x' + IntToHex(_int_at(data, 6), 8);

		PE_CLOSETAB:
			Result := 'PE_CLOSETAB'
			+ ' handle=0x' + IntToHex(_int_at(data, 6), 8);

		PE_XSTATUSMSG_SENT:
			Result := 'PE_XSTATUSMSG_SENT '
			+ ' uin=' + IntToStr(_int_at(data, 6))
			+ ' status=' + _istring_at(data, 10)
			+ ' mess=' + _istring_at(data, 10 + _int_at(data, 10) + 4);

		PE_XSTATUS_REQ_GOT:
			Result := 'PE_XSTATUS_REQ_GOT'
			+ ' uin=' + IntToStr(_int_at(data, 6));

		else
			Result := '0x' + IntToHex(_byte_at(data,5), 2); //не идентифицирован
	end;

end;

function MessageToHex(data:pointer): AnsiString;
var
	i: integer;
begin
	Result := '';
	for i := 0 to _int_at(data) + 3 do //добавим к размеру сообщения первый integer
		Result := Result + IntToHex(_byte_at(data, i), 2) + ' ';
end;

function ParseGetData(data:pointer; request:byte): AnsiString;
begin
	Result := '';

	case request of
		PG_TIME:
			Result := ' time=' + DateTimeToStr(_double(data, 5));

		PG_LIST:
			Result := ' uins=' + IntlistToStr(_intlist_at(data, 5));

		PG_CONTACTINFO:
			Result := ' uin=' + IntToStr(_int_at(data, 9))
			+ ' status=' + IntToStr(_byte_at(data, 13))
			+ ' invis=' + BoolToStr(boolean(_byte_at(data, 14)), true)
			+ ' name=' + _istring_at(data, 15)
			+ ' nick=' + _istring_at(data, 15 + _int_at(data, 15) + 4)
			+ ' first=' + _istring_at(data, 15 + _int_at(data, 15) + 4 + _int_at(data, 15 + _int_at(data, 15) + 4) + 4)
			+ ' last=' + _istring_at(data, 15 + _int_at(data, 15) + 4 + _int_at(data, 15 + _int_at(data, 15) + 4) + 4 + _int_at(data, 15 + _int_at(data, 15) + 4 + _int_at(data, 15 + _int_at(data, 15) + 4) + 4) + 4);
			
		PG_DISPLAYED_NAME:
			Result := ' name=' + _istring_at(data, 5);

		PG_NOF_UINLISTS:
			Result := ' number=' + IntToStr(_int_at(data, 5));

		PG_UINLIST:
			Result := ' uins=' + IntlistToStr(_intlist_at(data, 5));

		PG_AWAYTIME:
			Result := ' time=' + TimeToStr(_double(data, 5));

		PG_ANDRQ_PATH:
			Result := ' path=' + _istring_at(data, 5);

		PG_USER_PATH:
			Result := ' path=' + _istring_at(data, 5);

		PG_ANDRQ_VER:
			Result := ' ver=' + IntToStr(_int_at(data, 5));

		PG_ANDRQ_VER_STR:
			Result := ' ver=' + _istring_at(data, 5);

		PG_USER:
			Result := ' uin=' + IntToStr(_int_at(data, 5));

		PG_USERTIME:
			Result := ' time=' + TimeToStr(_double(data, 5));

		PG_CONNECTIONSTATE:
			Result := ' state=' + IntToStr(_int_at(data, 5));

		PG_WINDOW:
			Result := ' handle=0x' + IntToHex(_int_at(data, 5), 8)
			+ ' x=' + IntToStr(_int_at(data, 9))
			+ ' y=' + IntToStr(_int_at(data, 13))
			+ ' width=' + IntToStr(_int_at(data, 17))
			+ ' height=' + IntToStr(_int_at(data, 21));

		PG_AUTOMSG:
			Result := ' msg=' + _istring_at(data, 5);

		PG_TRANSLATE:
			Result := ' text=' + _istring_at(data, 5);

		PG_THEME_PIC:
			Result := ' handle=0x' + IntToHex(_int_at(data, 5), 8);

		PG_CHAT_UIN:
			Result := ' uin=' + IntToStr(_int_at(data, 5));

	end;
end;

function ParseMessageFromRnQ(data:pointer; request:byte = 0): AnsiString;
begin
	Result := '';

	case _byte_at(data,4) of
		PM_GET:
			Result := 'PM_GET'; //такого не должно быть

		PM_DATA:
			Result := 'PM_DATA ' + ParseGetData(data, request);

		PM_EVENT:
			Result := 'PM_EVENT ' + ParseEvent(data);

		PM_ABORT:
			Result := 'PM_ABORT '; //такого не должно быть

		PM_CMD:
			Result := 'PM_CMD'; //такого не должно быть

		PM_ACK:
			Result := 'PM_ACK ' + ParseAcknowledge(data);

		PM_ERROR:
			Result := 'PM_ERROR ' + ParseError(data);

		else
			Result := Result + '0x' + IntToHex(_byte_at(data,4), 2); //не идентифицирован

  end;
end;

function IntToEvent(ev: integer): AnsiString;
begin
	case ev of
	PE_INITIALIZE: Result := 'PE_INITIALIZE';
	PE_FINALIZE: Result := 'PE_FINALIZE';
	PE_PREFERENCES: Result := 'PE_PREFERENCES';
	PE_CONNECTED: Result := 'PE_CONNECTED';
	PE_DISCONNECTED: Result := 'PE_DISCONNECTED';
	PE_MSG_GOT: Result := 'PE_MSG_GOT';
	PE_MSG_SENT: Result := 'PE_MSG_SENT';
	PE_CONTACTS_GOT: Result := 'PE_CONTACTS_GOT';
	PE_CONTACTS_SENT: Result := 'PE_CONTACTS_SENT';
	PE_URL_GOT: Result := 'PE_URL_GOT';
	PE_URL_SENT: Result := 'PE_URL_SENT';
	PE_ADDEDYOU_GOT: Result := 'PE_ADDEDYOU_GOT';
	PE_ADDEDYOU_SENT: Result := 'PE_ADDEDYOU_SENT';
	PE_AUTHREQ_GOT: Result := 'PE_AUTHREQ_GOT';
	PE_AUTHREQ_SENT: Result := 'PE_AUTHREQ_SENT';
	PE_AUTH_GOT: Result := 'PE_AUTH_GOT';
	PE_AUTH_SENT: Result := 'PE_AUTH_SENT';
	PE_AUTHDENIED_GOT: Result := 'PE_AUTHDENIED_GOT';
	PE_AUTHDENIED_SENT: Result := 'PE_AUTHDENIED_SENT';
	PE_GCARD_GOT: Result := 'PE_GCARD_GOT';
	PE_GCARD_SENT: Result := 'PE_GCARD_SENT';
	PE_AUTOMSG_GOT: Result := 'PE_AUTOMSG_GOT';
	PE_AUTOMSG_SENT: Result := 'PE_AUTOMSG_SENT';
	PE_AUTOMSG_REQ_GOT: Result := 'PE_AUTOMSG_REQ_GOT';
	PE_AUTOMSG_REQ_SENT: Result := 'PE_AUTOMSG_REQ_SENT';
	PE_EMAILEXP_GOT: Result := 'PE_EMAILEXP_GOT';
	PE_EMAILEXP_SENT: Result := 'PE_EMAILEXP_SENT';
	PE_LIST_ADD: Result := 'PE_LIST_ADD';
	PE_LIST_REMOVE: Result := 'PE_LIST_REMOVE';
	PE_STATUS_CHANGED: Result := 'PE_STATUS_CHANGED';
	PE_USERINFO_CHANGED: Result := 'PE_USERINFO_CHANGED';
	PE_VISIBILITY_CHANGED: Result := 'PE_VISIBILITY_CHANGED';
	PE_WEBPAGER_GOT: Result := 'PE_WEBPAGER_GOT';
	PE_WEBPAGER_SENT: Result := 'PE_WEBPAGER_SENT';
	PE_FROM_MIRABILIS: Result := 'PE_FROM_MIRABILIS';
	PE_UPDATE_INFO: Result := 'PE_UPDATE_INFO';
	PE_SELECTTAB: Result := 'PE_SELECTTAB';
	PE_DESELECTTAB: Result := 'PE_DESELECTTAB';
	PE_CLOSETAB: Result := 'PE_CLOSETAB';
	PE_XSTATUSMSG_SENT: Result := 'PE_XSTATUSMSG_SENT';
	PE_XSTATUS_REQ_GOT: Result := 'PE_CLOSETAB';
	else Result := '';
	end;
end;

function KeywordToInt(keyword: AnsiString): integer;
begin
  // whatlist
	if keyword = 'PL_ROASTER' then
		result := PL_ROASTER
	else if keyword = 'PL_VISIBLELIST' then
		result := PL_VISIBLELIST
	else if keyword = 'PL_INVISIBLELIST' then
		result := PL_INVISIBLELIST
	else if keyword = 'PL_TEMPVISIBLELIST' then
		result := PL_TEMPVISIBLELIST
	else if keyword = 'PL_IGNORELIST' then
		result := PL_IGNORELIST
	else if keyword = 'PL_DB' then
		result := PL_DB
	else if keyword = 'PL_NIL' then
		result := PL_NIL

  // connection state
	else if keyword = 'PCS_DISCONNECTED' then
		result := PCS_DISCONNECTED
	else if keyword = 'PCS_CONNECTED' then
		result := PCS_CONNECTED
	else if keyword = 'PCS_CONNECTING' then
		result := PCS_CONNECTING

  // whatwindow
	else if keyword = 'PW_ROASTER' then
		result := PW_ROASTER
	else if keyword = 'PW_CHAT' then
		result := PW_CHAT
	else if keyword = 'PW_PREFERENCES' then
		result := PW_PREFERENCES

  // status
	else if keyword = 'PS_ONLINE' then
		result := PS_ONLINE
	else if keyword = 'PS_OCCUPIED' then
		result := PS_OCCUPIED
	else if keyword = 'PS_DND' then
		result := PS_DND
	else if keyword = 'PS_NA' then
		result := PS_NA
	else if keyword = 'PS_AWAY' then
		result := PS_AWAY
	else if keyword = 'PS_F4C' then
		result := PS_F4C
	else if keyword = 'PS_OFFLINE' then
		result := PS_OFFLINE
	else if keyword = 'PS_UNKNOWN' then
		result := PS_UNKNOWN

  // visibility
	else if keyword = 'PV_INVISIBLE' then
		result := PV_INVISIBLE
	else if keyword = 'PV_PRIVACY' then
		result := PV_PRIVACY
	else if keyword = 'PV_NORMAL' then
		result := PV_NORMAL
	else if keyword = 'PV_ALL' then
		result := PV_ALL

  // messages
	else if keyword = 'PM_GET' then
		result := PM_GET
	else if keyword = 'PM_DATA' then
		result := PM_DATA
	else if keyword = 'PM_EVENT' then
		result := PM_EVENT
	else if keyword = 'PM_ABORT' then
		result := PM_ABORT
	else if keyword = 'PM_CMD' then
		result := PM_CMD
	else if keyword = 'PM_ACK' then
		result := PM_ACK

  // events
	else if keyword = 'PM_ERROR' then
		result := PM_ERROR
	else if keyword = 'PE_INITIALIZE' then
		result := PE_INITIALIZE
	else if keyword = 'PE_FINALIZE' then
		result := PE_FINALIZE
	else if keyword = 'PE_PREFERENCES' then
		result := PE_PREFERENCES
	else if keyword = 'PE_CONNECTED' then
		result := PE_CONNECTED
	else if keyword = 'PE_DISCONNECTED' then
		result := PE_DISCONNECTED
	else if keyword = 'PE_MSG_GOT' then
		result := PE_MSG_GOT
	else if keyword = 'PE_MSG_SENT' then
		result := PE_MSG_SENT
	else if keyword = 'PE_CONTACTS_GOT' then
		result := PE_CONTACTS_GOT
	else if keyword = 'PE_CONTACTS_SENT' then
		result := PE_CONTACTS_SENT
	else if keyword = 'PE_URL_GOT' then
		result := PE_URL_GOT
	else if keyword = 'PE_URL_SENT' then
		result := PE_URL_SENT
	else if keyword = 'PE_ADDEDYOU_GOT' then
		result := PE_ADDEDYOU_GOT
	else if keyword = 'PE_ADDEDYOU_SENT' then
		result := PE_ADDEDYOU_SENT
	else if keyword = 'PE_AUTHREQ_GOT' then
		result := PE_AUTHREQ_GOT
	else if keyword = 'PE_AUTHREQ_SENT' then
		result := PE_AUTHREQ_SENT
	else if keyword = 'PE_AUTH_GOT' then
		result := PE_AUTH_GOT
	else if keyword = 'PE_AUTH_SENT' then
		result := PE_AUTH_SENT
	else if keyword = 'PE_AUTHDENIED_GOT' then
		result := PE_AUTHDENIED_GOT
	else if keyword = 'PE_AUTHDENIED_SENT' then
		result := PE_AUTHDENIED_SENT
	else if keyword = 'PE_GCARD_GOT' then
		result := PE_GCARD_GOT
	else if keyword = 'PE_GCARD_SENT' then
		result := PE_GCARD_SENT
	else if keyword = 'PE_AUTOMSG_GOT' then
		result := PE_AUTOMSG_GOT
	else if keyword = 'PE_AUTOMSG_SENT' then
		result := PE_AUTOMSG_SENT
	else if keyword = 'PE_AUTOMSG_REQ_GOT' then
		result := PE_AUTOMSG_REQ_GOT
	else if keyword = 'PE_AUTOMSG_REQ_SENT' then
		result := PE_AUTOMSG_REQ_SENT
	else if keyword = 'PE_EMAILEXP_GOT' then
		result := PE_EMAILEXP_GOT
	else if keyword = 'PE_EMAILEXP_SENT' then
		result := PE_EMAILEXP_SENT
	else if keyword = 'PE_LIST_ADD' then
		result := PE_LIST_ADD
	else if keyword = 'PE_LIST_REMOVE' then
		result := PE_LIST_REMOVE
	else if keyword = 'PE_STATUS_CHANGED' then
		result := PE_STATUS_CHANGED
	else if keyword = 'PE_USERINFO_CHANGED' then
		result := PE_USERINFO_CHANGED
	else if keyword = 'PE_VISIBILITY_CHANGED' then
		result := PE_VISIBILITY_CHANGED
	else if keyword = 'PE_WEBPAGER_GOT' then
		result := PE_WEBPAGER_GOT
	else if keyword = 'PE_WEBPAGER_SENT' then
		result := PE_WEBPAGER_SENT
	else if keyword = 'PE_FROM_MIRABILIS' then
		result := PE_FROM_MIRABILIS
	else if keyword = 'PE_UPDATE_INFO' then
		result := PE_UPDATE_INFO
	else if keyword = 'PE_SELECTTAB' then
		result := PE_SELECTTAB
	else if keyword = 'PE_DESELECTTAB' then
		result := PE_DESELECTTAB
	else if keyword = 'PE_CLOSETAB' then
		result := PE_CLOSETAB
	else if keyword = 'PE_XSTATUSMSG_SENT' then
		result := PE_XSTATUSMSG_SENT
	else if keyword = 'PE_XSTATUS_REQ_GOT' then
		result := PE_XSTATUS_REQ_GOT

  // get
	else if keyword = 'PG_USER' then
		result := PG_USER
	else if keyword = 'PG_CONTACTINFO' then
		result := PG_CONTACTINFO
	else if keyword = 'PG_DISPLAYED_NAME' then
		result := PG_DISPLAYED_NAME
	else if keyword = 'PG_TIME' then
		result := PG_TIME
	else if keyword = 'PG_LIST' then
		result := PG_LIST
	else if keyword = 'PG_NOF_UINLISTS' then
		result := PG_NOF_UINLISTS
	else if keyword = 'PG_UINLIST' then
		result := PG_UINLIST
	else if keyword = 'PG_AWAYTIME' then
		result := PG_AWAYTIME
	else if keyword = 'PG_ANDRQ_PATH' then
		result := PG_ANDRQ_PATH
	else if keyword = 'PG_USER_PATH' then
		result := PG_USER_PATH
	else if keyword = 'PG_ANDRQ_VER' then
		result := PG_ANDRQ_VER
	else if keyword = 'PG_ANDRQ_VER_STR' then
		result := PG_ANDRQ_VER_STR
	else if keyword = 'PG_USERTIME' then
		result := PG_USERTIME
	else if keyword = 'PG_CONNECTIONSTATE' then
		result := PG_CONNECTIONSTATE
	else if keyword = 'PG_WINDOW' then
		result := PG_WINDOW
	else if keyword = 'PG_AUTOMSG' then
		result := PG_AUTOMSG
	else if keyword = 'PG_TRANSLATE' then
		result := PG_TRANSLATE
	else if keyword = 'PG_THEME_PIC' then
		result := PG_THEME_PIC
	else if keyword = 'PG_CHAT_UIN' then
		result := PG_CHAT_UIN
	else if keyword = 'PG_CHAT_XYZ' then
		result := PG_CHAT_XYZ

	// acks
	else if keyword = 'PA_OK' then
		result := PA_OK
                    
  // errors
	else if keyword = 'PERR_ERROR' then
		result := PERR_ERROR
	else if keyword = 'PERR_BAD_REQ' then
		result := PERR_BAD_REQ
	else if keyword = 'PERR_NOUSER' then
		result := PERR_NOUSER
	else if keyword = 'PERR_UNEXISTENT' then
		result := PERR_UNEXISTENT
	else if keyword = 'PERR_FAILED_FOR' then
		result := PERR_FAILED_FOR
	else if keyword = 'PERR_UNK_REQ' then
		result := PERR_UNK_REQ

	// commands
	else if keyword = 'PC_SEND_MSG' then
		result := PC_SEND_MSG
	else if keyword = 'PC_SEND_CONTACTS' then
		result := PC_SEND_CONTACTS
	else if keyword = 'PC_SEND_ADDEDYOU' then
		result := PC_SEND_ADDEDYOU
	else if keyword = 'PC_LIST_ADD' then
		result := PC_LIST_ADD
	else if keyword = 'PC_LIST_REMOVE' then
		result := PC_LIST_REMOVE
	else if keyword = 'PC_SET_STATUS' then
		result := PC_SET_STATUS
	else if keyword = 'PC_SET_VISIBILITY' then
		result := PC_SET_VISIBILITY
	else if keyword = 'PC_QUIT' then
		result := PC_QUIT
	else if keyword = 'PC_CONNECT' then
		result := PC_CONNECT
	else if keyword = 'PC_DISCONNECT' then
		result := PC_DISCONNECT
	else if keyword = 'PC_SET_AUTOMSG' then
		result := PC_SET_AUTOMSG
	else if keyword = 'PC_SEND_AUTOMSG_REQ' then
		result := PC_SEND_AUTOMSG_REQ
	else if keyword = 'PC_TAB_ADD' then
		result := PC_TAB_ADD
	else if keyword = 'PC_TAB_MODIFY' then
		result := PC_TAB_MODIFY
	else if keyword = 'PC_TAB_DELETE' then
		result := PC_TAB_DELETE
	else if keyword = 'PC_PLAYSOUND' then
		result := PC_PLAYSOUND
	else if keyword = 'PC_PLAYSOUNDFN' then
		result := PC_PLAYSOUNDFN
	else if keyword = 'PC_RELOAD_THEME' then
		result := PC_RELOAD_THEME
	else if keyword = 'PC_RELOAD_LANG' then
		result := PC_RELOAD_LANG
	else if keyword = 'PC_ADD_MSG' then
		result := PC_ADD_MSG
	else if keyword = 'PC_ADD_TO_INPUT' then
		result := PC_ADD_TO_INPUT
	else if keyword = 'PC_ADDBUTTON' then
		result := PC_ADDBUTTON
	else if keyword = 'PC_MODIFY_BUTTON' then
		result := PC_MODIFY_BUTTON
	else if keyword = 'PC_DELBUTTON' then
		result := PC_DELBUTTON

	// unknown
	else
		result := -1;
end;

// By Rapid D
{Convert string from UTF-8 format into ASCII}
function UTF8ToStr(Value: AnsiString): AnsiString;
var
  buffer: Pointer;
  BufLen: LongWord;
begin
  BufLen := Length(Value) + 4;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
	MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
  Result := WideCharToString(buffer);
  FreeMem(buffer, BufLen);
end;

{Convert string from UTF-8 format mixed with standart ASCII symbols($00..$7f)}
function UTF8ToStrSmart(Value: AnsiString): AnsiString;
var
  Digit: AnsiString;
  i: Word;
  HByte: Byte;
  Len: Byte;
begin
  Result := '';
  Len := 0;
  If UTF8Decode(Value)='' Then
   Begin
    Result:=Value;
    Exit
   End;
  if Value = '' then Exit;
  for i := 1 to Length(Value) do
  begin
    if Len > 0 then
    begin
      Digit := Digit + Value[i];
      Dec(Len);
      if Len = 0 then
        Result := Result + UTF8ToStr(Digit);
    end else
    begin
      HByte := Ord(Value[i]);
      if HByte in [$00..$7f] then       //Standart ASCII chars
        Result := Result + Value[i]
      else begin
        //Get length of UTF-8 char
        if HByte and $FC = $FC then
          Len := 6
        else if HByte and $F8 = $F8 then
          Len := 5
        else if HByte and $F0 = $F0 then
          Len := 4
        else if HByte and $E0 = $E0 then
          Len := 3
        else if HByte and $C0 = $C0 then
          Len := 2
        else begin
          Result := Result + Value[i];
          Continue;
        end;
        Dec(Len);
        Digit := Value[i];
      end;
    end;
  end;
end;

procedure StrSwapByteOrder(Str: PWideChar);
// exchanges in each character of the given string the low order and high order
// byte to go from LSB to MSB and vice versa.
// EAX contains address of string
{$IFDEF WIN32}
asm
       PUSH    ESI
       PUSH    EDI
       MOV     ESI, EAX
       MOV     EDI, ESI
       XOR     EAX, EAX // clear high order byte to be able to use 32bit operand below
@@1:
       LODSW
       OR      EAX, EAX
       JZ      @@2
       XCHG    AL, AH
       STOSW
       JMP     @@1
@@2:
       POP     EDI
       POP     ESI
{$ELSE}
asm
       PUSH    RSI
       PUSH    RDI
       MOV     RSI, RAX
       MOV     RDI, RSI
       XOR     RAX, RAX // clear high order byte to be able to use 32bit operand below
@@1:
       LODSW
       OR      RAX, RAX
       JZ      @@2
       XCHG    AL, AH
       STOSW
       JMP     @@1
@@2:
       POP     RDI
       POP     RSI
{$ENDIF}
end;

function UnWideStr(s : AnsiString) : AnsiString;
begin
  result := s;
  if (result > '') and (result[1] < #5)and not odd(Length(result)) then
   begin
		 StrSwapByteOrder(PWideChar(result));
		 result := WideCharToString(PWidechar(result));
	 end;
end;


function UnUTF(s : AnsiString) : AnsiString;
begin
	result := UTF8ToStrSmart(UnWideStr(s));
end;


function _int(i:integer):AnsiString; overload;
begin
  setLength(result, 4);
  move(i, result[1], 4);
end; // _int

function _int(ints:array of integer):AnsiString; overload;
var
  i:integer;
begin
result:='';
for i:=0 to length(ints)-1 do
  result:=result+_int(ints[i]);
end; // _int

function _byte_at(p:pointer; ofs:integer=0):byte;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
result:=byte(p^)
end;

function _byte_at(const s:AnsiString; idx:integer=1):byte; overload;
begin result:=_byte_at(@s[idx]) end;

function _int_at(p:pointer; ofs:integer=0):integer; overload;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
result:=integer(p^)
end;

function _int_at(const s:AnsiString; idx:integer=1):integer; overload;
begin result:=_int_at(@s[idx]) end;

function _ptr_at(p:pointer; ofs:integer=0):pointer;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
result:=pointer(_int_at(p))
end;

function _istring(const s:AnsiString):AnsiString;
begin result:=_int(length(s))+s end;

function _istring_at(p:pointer; ofs:integer=0):AnsiString; overload;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
setlength(result, integer(p^));
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), 4);
move(p^, result[1], length(result));
end; // _istring_at

function _istring_at(const s:AnsiString; idx:integer=1):AnsiString; overload;
begin result:=_istring_at(@s[idx]) end;

function _intlist(a:array of integer):AnsiString;
begin result:=_int(length(a))+_int(a) end;

function _intlist_at(p:pointer; ofs:integer=0):TintegerDynArray; overload;
var
  n,i:integer;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
n:=integer(p^);
setlength(result, n);
for i:=0 to n-1 do
  begin
  inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p),4);
  result[i]:=_int_at(p);
  end;
end; // _intlist_at

function _intlist_at(const s:AnsiString; idx:integer=1):TintegerDynArray; overload;
begin result:=_intlist_at(@s[idx]) end;

function _dt(dt:Tdatetime):AnsiString;
begin
setLength(result, 8);
move(dt, result[1], 8);
end; // _dt

function _double(p:pointer; ofs:integer=0):double;
begin
inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
//setlength(result, integer(p^));
//inc(integer(p), 4);
move(p^, result, 8);
end; // _double

function _dt_at(p:pointer; ofs:integer=0): Tdatetime; overload;
begin
  inc({$IFDEF WIN32}Integer{$ELSE}NativeInt{$ENDIF}(p), ofs);
  result:=Tdatetime(p^)
end; // _dt_at
function _dt_at(const s: AnsiString; idx:integer=1): Tdatetime; overload;
begin
 result := _dt_at(@s[idx]);
end; // _dt_at


end.
