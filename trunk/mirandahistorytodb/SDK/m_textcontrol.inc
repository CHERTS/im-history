const
	// bidi options. currently works ONLY for simple engine. this will be fixed later.
	MTEXT_BIDI_AUTO = $000c;
	MTEXT_BIDI_RTL  = $0004;
	MTEXT_BIDI_LTR  = $0008;
	MTEXT_BIDI_MASK = $000c;

	// fancy stuff. this is not (and never will be) supported by simple renderer!
	MTEXT_FANCY_SMILEYS = $0010; // SmileyAdd smileys
	MTEXT_FANCY_BBCODES = $0020; // [b], [u], [i], [color], [img], [url]
	MTEXT_FANCY_MATHMOD = $0040; // enable math module formula parsing
	MTEXT_FANCY_URLS    = $0080; // underline urls
	MTEXT_FANCY_HANDLES = $0100; // [$handle=i<HICON as dword>$] and [$handle=b<HBITMAP as dword>$]
	MTEXT_FANCY_ESCAPED = $0200; // passed text is escaped with slashes, not implemented
	MTEXT_FANCY_MASK    = $0ff0;

	MTEXT_FANCY_ALL     = MTEXT_FANCY_SMILEYS+MTEXT_FANCY_BBCODES+MTEXT_FANCY_MATHMOD+MTEXT_FANCY_HANDLES;

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
	sz: TSize;
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
const MS_TEXT_REGISTER = 'MText/Register';

// allocate text object
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(AnsiChar *)text
// result = (LRESULT)(HANDLE)textHandle
const MS_TEXT_CREATE = 'MText/Create';

// allocate text object (unicode)
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(WCHAR *)text
// result = (LRESULT)(HANDLE)textHandle
const MS_TEXT_CREATEW = 'MText/CreateW';

// allocate text object (advanced)
// wParam = (WPARAM)(HANDLE)userHandle
// lParam = (LPARAM)(LPMTEXTCREATE)createInfo
// result = (LRESULT)(HANDLE)textHandle
const MS_TEXT_CREATEEX = 'MText/CreateEx';

// measure text object
// wParam = (LPARAM)(LPMTEXTDISPLAY)displayInfo
// result = 1 (success), 0 (failure)
// displayInfo->size.cx is interpreted as maximum width allowed.
// wrapped text size is stored in displayInfo->size, text
const MS_TEXT_MEASURE = 'MText/Measure';

// display text object
// wParam = (LPARAM)(LPMTEXTDISPLAY)displayInfo
// result = 1 (success), 0 (failure)
const MS_TEXT_DISPLAY = 'MText/Display';

// send message to an object
// wParam = (WPARAM)(LPMTEXTMESSAGE)message
// result = message result
const MS_TEXT_SENDMESSAGE = 'MText/SendMessage';

// destroy text object
// wParam = (LPARAM)(HANDLE)textHandle
const MS_TEXT_DESTROY = 'MText/Destroy';

