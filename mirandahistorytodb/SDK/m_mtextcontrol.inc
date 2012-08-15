
{$IFNDEF M_TEXTCONTROL}
{$DEFINE M_TEXTCONTROL}

const
	// bidi options. currently works ONLY for simple engine. this will be fixed later.
	MTEXT_BIDI_AUTO = 0x0c;
	MTEXT_BIDI_RTL  = 0x04;
	MTEXT_BIDI_LTR  = 0x08;
	MTEXT_BIDI_MASK = 0x0c;

	// fancy stuff. this is not (and never will be) supported by simple renderer!
	MTEXT_FANCY_SMILEYS = 0x010; // SmileyAdd smileys
	MTEXT_FANCY_BBCODES = 0x020; // [b], [u], [i], [color], [img], [url]
	MTEXT_FANCY_MATHMOD = 0x040; // enable math module formula parsing
	MTEXT_FANCY_URLS    = 0x080; // underline urls
	MTEXT_FANCY_HANDLES = 0x100; // [$handle=i<HICON as dword>$] and [$handle=b<HBITMAP as dword>$]
	MTEXT_FANCY_ESCAPED = 0x200; // passed text is escaped with slashes, not implemented
	MTEXT_FANCY_MASK    = 0xff0;

	MTEXT_FANCY_ALL     = MTEXT_FANCY_SMILEYS+MTEXT_FANCY_BBCODES+MTEXT_FANCY_MATHMOD+MTEXT_FANCY_HANDLES

type

// used in MS_TEXT_CREATEEX
MTEXTCREATE = record
	cbSize: integer;
	text: PAnsiChar;
	wtext: PWideChar;
	hContact: THandle;
end;

// used in MS_TEXT_MEASURE and MS_TEXT_DISPLAY
MTEXTDISPLAY = record
	cbSize: integer;
	dc: HDC;
	pos: TPoint;
	sz: TSite;
	text: THandle;
end;

// used in MS_TEXT_SENDMESSAGE
MTEXTMESSAGE = record
	hwnd: THandle;
	text: THandle;
	msg: word;
	wParam: WPARAM;
	lParam: LPARAM;
end;

// subscribe to MText services
// wParam = (WPARAM)(DOWRD)defaultOptions
// lParam = (LPARAM)(AnsiChar *)userTitle
// result = (LRESULT)(HANDLE)userHandle
const MS_TEXT_REGISTER "MText/Register"

//////////////////// Example ///////////////
{$ifdef I_AM_A_CONSTANT_THAT_IS_NEVER_DEFINED_BUT_ALLOWS_THE_CODE_BELOW_NOT_TO_BE_COMMENTED}

#ifndef MTEXT_NOHELPERS
__inline HANDLE MTextRegister(AnsiChar *userTitle, DWORD defaultOptions)
{
	return (HANDLE)CallService(MS_TEXT_REGISTER, (WPARAM)defaultOptions, (LPARAM)userTitle);
}
#endif // MTEXT_NOHELPERS

// allocate text object
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(AnsiChar *)text
// result = (LRESULT)(HANDLE)textHandle
#define MS_TEXT_CREATE "MText/Create"

#ifndef MTEXT_NOHELPERS
__inline HANDLE MTextCreate(HANDLE userHandle, AnsiChar *text)
{
	return (HANDLE)CallService(MS_TEXT_CREATE, (WPARAM)userHandle, (LPARAM)text);
}
#endif // MTEXT_NOHELPERS

// allocate text object (unicode)
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(WCHAR *)text
// result = (LRESULT)(HANDLE)textHandle
#define MS_TEXT_CREATEW "MText/CreateW"

#ifndef MTEXT_NOHELPERS
__inline HANDLE MTextCreateW(HANDLE userHandle, WCHAR *text)
{
	return (HANDLE)CallService(MS_TEXT_CREATEW, (WPARAM)userHandle, (LPARAM)text);
}
#endif // MTEXT_NOHELPERS

// allocate text object (advanced)
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(LPMTEXTCREATE)createInfo
// result = (LRESULT)(HANDLE)textHandle
#define MS_TEXT_CREATEEX "MText/CreateEx"

#ifndef MTEXT_NOHELPERS
__inline HANDLE MTextCreateEx(HANDLE userHandle, HANDLE hContact, AnsiChar *text, WCHAR *wtext)
{
	#ifdef __cplusplus
		MTEXTCREATE textCreate;
	#else
		MTEXTCREATE textCreate = {0};
		textCreate.cbSize = sizeof(textCreate);
	#endif
	textCreate.hContact = hContact;
	textCreate.text = text;
	textCreate.wtext = wtext;
	return (HANDLE)CallService(MS_TEXT_CREATEEX, (WPARAM)userHandle, (LPARAM)&textCreate);
}
#endif // MTEXT_NOHELPERS

// measure text object
// wParam = (LPARAM)(LPMTEXTDISPLAY)displayInfo
// result = 1 (success), 0 (failure)
// displayInfo->size.cx is interpreted as maximum width allowed.
// wrapped text size is stored in displayInfo->size, text
#define MS_TEXT_MEASURE "MText/Measure"

#ifndef MTEXT_NOHELPERS
__inline int MTextMeasure(HDC dc, SIZE *sz, HANDLE text)
{
	#ifdef __cplusplus
		MTEXTDISPLAY displayInfo;
	#else
		MTEXTDISPLAY displayInfo = {0};
		displayInfo.cbSize = sizeof(displayInfo);
	#endif
	displayInfo.dc = dc;
	displayInfo.pos.x = displayInfo.pos.y = 0;
	displayInfo.sz = *sz;
	displayInfo.text = text;
	int result = (int)CallService(MS_TEXT_MEASURE, (WPARAM)&displayInfo, (LPARAM)0);
	*sz = displayInfo.sz;
	return result;
}
#endif // MTEXT_NOHELPERS

// display text object
// wParam = (LPARAM)(LPMTEXTDISPLAY)displayInfo
// result = 1 (success), 0 (failure)
#define MS_TEXT_DISPLAY "MText/Display"

#ifndef MTEXT_NOHELPERS
__inline int MTextDisplay(HDC dc, POINT pos, SIZE sz, HANDLE text)
{
	#ifdef __cplusplus
		MTEXTDISPLAY displayInfo;
	#else
		MTEXTDISPLAY displayInfo = {0};
		displayInfo.cbSize = sizeof(displayInfo);
	#endif
	displayInfo.dc = dc;
	displayInfo.pos = pos;
	displayInfo.sz = sz;
	displayInfo.text = text;
	return (int)CallService(MS_TEXT_DISPLAY, (WPARAM)&displayInfo, (LPARAM)0);
}
#endif // MTEXT_NOHELPERS

// send message to an object
// wParam = (WPARAM)(LPMTEXTMESSAGE)message
// result = message result
#define MS_TEXT_SENDMESSAGE "MText/SendMessage"

#ifndef MTEXT_NOHELPERS
__inline int MTextSendMessage(HWND hwnd, HANDLE text, UINT msg, WPARAM wParam, LPARAM lParam)
{
	#ifdef __cplusplus
		MTEXTMESSAGE message;
	#else
		MTEXTMESSAGE message = {0};
	#endif
	message.hwnd = hwnd;
	message.text = text;
	message.msg = msg;
	message.wParam = wParam;
	message.lParam = lParam;
	return (int)CallService(MS_TEXT_SENDMESSAGE, (WPARAM)&message, (LPARAM)0);
}
#endif // MTEXT_NOHELPERS

// destroy text object
// wParam = (LPARAM)(HANDLE)textHandle
#define MS_TEXT_DESTROY "MText/Destroy"

#ifndef MTEXT_NOHELPERS
__inline int MTextDestroy(HANDLE text)
{
	return (int)CallService(MS_TEXT_DESTROY, (WPARAM)text, (LPARAM)0);
}
#endif // MTEXT_NOHELPERS

//#define MS_TEXT_QDISPLAY "MText/QDisplay"
//#define MS_TEXT_QDISPLAYW "MText/QDisplayW"

// T-definitions for unicode
#if defined(UNICODE) || defined (_UNICODE)
	#define MS_TEXT_CREATET MS_TEXT_CREATEW
	#define MTextCreateT MTextCreateW
#else
	#define MS_TEXT_CREATET MS_TEXT_CREATE
	#define MTextCreateT MTextCreate
#endif

// Text control
#define MTEXTCONTROLCLASS "MTextControl"
#define MTM_SETUSER WM_USER
#define MTM_UPDATE  WM_USER+1

#endif // __mtext_h__

{$endif}

{$ENDIF}
