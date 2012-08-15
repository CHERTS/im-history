{$IFNDEF M_TOPTOOLBAR_H}
{$DEFINE M_TOPTOOLBAR_H}

const

//button flags
TTBBF_DISABLED		= 1;
TTBBF_VISIBLE		= 2; 
TTBBF_PUSHED		= 4;
TTBBF_SHOWTOOLTIP	= 8;
TTBBF_DRAWBORDER	= 16;	//draw border for bitmap,bitmap must be WxH 16x12
TTBBF_ISSEPARATOR	= 32;

//for internal launch buttons
TTBBF_ISLBUTTON		= 64;

type

PTBButton = ^TTBButton;
TTBButton = record
	cbSize: integer;
	hbBitmapUp: hBitmap;
	hbBitmapDown: hBitmap;
	pszServiceUp: PAnsiChar;
	pszServiceDown: PAnsiChar;
	dwFlags: DWORD;
	lParamUp: LPARAM;
	wParamUp: WPARAM;
	lParamDown: LPARAM;
	wParamDown: WPARAM ;
	name: PAnsiChar;
end;

PTBButtonV2 = ^TTBButtonV2;
TTBButtonV2 = record
	cbSize: integer;
	hbBitmapUp: hBitmap;
	hbBitmapDown: hBitmap;
	pszServiceUp: PAnsiChar;
	pszServiceDown: PAnsiChar;
	dwFlags: DWORD;
	lParamUp: LPARAM;
	wParamUp: WPARAM;
	lParamDown: LPARAM;
	wParamDown: WPARAM ;
	name: PAnsiChar;
	hIconUp,hIconDn: hIcon;
	tooltipUp: PAnsiChar;
	tooltipDn: PAnsiChar;
end;

const

//=== EVENTS ===
{
toptoolbar/moduleloaded event
wParam = lParam = 0
Called when the toolbar services are available

!!!Warning you may work with TTB services only in this event or later.
}
ME_TTB_MODULELOADED	= 'TopToolBar/ModuleLoaded';

//=== SERVICES ===
{
toptoolbar/addbutton service
wparam = (TTBButton*)lpTTBButton
lparam = 0
returns: hTTBButton - handle of added button on success, -1 on failure.
}
MS_TTB_ADDBUTTON	= 'TopToolBar/AddButton';

{
toptoolbar/removebutton service
wparam = (HANDLE)hTTButton
lparam = 0
returns: 0 on success, -1 on failure.
}
MS_TTB_REMOVEBUTTON	= 'TopToolBar/RemoveButton';

{
toptoolbar/setstate service
wparam = (HANDLE)hTTButton
lparam = (LPARAM) state
returns: 0 on success, -1 on failure.
}
TTBST_PUSHED		= 1;
TTBST_RELEASED		= 2;

MS_TTB_SETBUTTONSTATE	='TopToolBar/SetState';

{
toptoolbar/getstate service
wparam = (HANDLE)hTTButton
lparam = 0
returns: state on success, -1 on failure.
}
MS_TTB_GETBUTTONSTATE	= 'TopToolBar/GetState';

{
toptoolbar/getoptions service
(HIWORD)wparam = (HANDLE)hTTButton
(LOWORD)wparam = TTBO_FLAG
lparam = 0,or lparam=lpTTBButton if flag=TTBO_ALLDATA
returns: value on success, -1 on failure.
}
TTBO_FLAGS		= 0;     //get/set all flags
TTBO_POS		= 1;     //position
TTBO_WIDTH		= 2;     //not impemented
TTBO_HEIGHT		= 3;     //not impemented
TTBO_TIPNAME		= 4;     //tool tip name
TTBO_ALLDATA		= 5;     //change all data via lparam=lpTTBButton

MS_TTB_GETBUTTONOPTIONS	= 'TopToolBar/GetOptions';

{
toptoolbar/setoptions service
(HIWORD)wparam = (HANDLE)hTTButton
(LOWORD)wparam = TTBO_FLAG
lparam = value
returns: 1 on success, -1 on failure.
}
MS_TTB_SETBUTTONOPTIONS	= 'TopToolBar/SetOptions';

{$ENDIF}
