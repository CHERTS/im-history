{$IFNDEF M_MATHMODULE}
{$DEFINE M_MATHMODULE}

const
  // replace all formulas in a RichEdit with bitmaps.
  // wParam = 0
  // lParam = *TMathRichedit Info
  // return: TRUE if replacement succeeded, FALSE if not (disable by user?).
  MATH_RTF_REPLACE_FORMULAE  = 'Math/RtfReplaceFormulae';

type
  TMathRicheditInfo = record
    hwndRichEditControl: HWND;
    sel: ^CharRange; // NULL: replace all.
    disableredraw: Integer;
  end;

  // WARNING:   !!!
// Strange things happen if you use this function twice on the same CHARRANGE:
// if Math-startDelimiter == Math-endDelimiter, there is the following problem:
// it might be that someone forgot an endDelimiter, this results in a lonesome startdelimiter.
// if you try to MATH_REPLACE_FORMULAE the second time, startDelimiters and endDelimiters are mixed up.
// The same problem occours if we have empty formulae, because two succeding delimiters are
// replaced with a single delimiter.

// **********parameter functions:
const
                       
    MATH_SET_PARAMS = 'Math/SetParams';
//--------------------------------------
// sets a parameter (only integer values) specified in  wparam
// wparam=paramcode
// lparam=parametervalue
// paramcodes:
    MATH_PARAM_BKGCOLOR		= 0;	// (COLORREF) std-rgb-color or TRANSPARENT_Color
// you can make the BKGCOLOR Transparent (default) by using this color:
    TRANSPARENT_Color 		= -1;  // this is default
    MATH_PARAM_FONTCOLOR	= 1;   // (COLORREF) std-rgb-color
    MATH_PARAM_RESIZE_HWND 	= 2;            // (HWND) preview window resizes RESIZE_HWND when it is being resized.
    MATH_PARAM_ToolboxEdit_HWND = 3;       // (HWND) If this hwnd (of an edit-box) is set, MathModule can insert Formula-elements from the Math-Toolbox.

    MATH_GET_PARAMS = 'Math/GetParams';
//---------------------------------------
// get a parameter (only integer values) specified in wparam
// wparam=paramcode
// lparam=lparamOfPARAM // see below
// paramcodes and returnvalues:
    MATH_PARAM_STARTDELIMITER 	= 4; // retval: *AnsiChar delimiter // the delimiter that marks the beginning of a formula
                                      // !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER
                                      // lparam=0
    MATH_PARAM_ENDDELIMITER 	= 5; // retval: *AnsiChar delimiter // the delimiter that marks the end of a formula
                                      // !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER
                                      // lparam=0
// ************end parameter functions.


const
  MATH_GET_STARTDELIMITER = 'Math/GetStartDelimiter';
// returns the delimiter that marks the beginning of a formula
// wparam=0
// lparam=0
// result=*AnsiChar Delimiter
// !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER

  MATH_GETENDDELIMITER = 'Math/GetEndDelimiter';
// returns the delimiter that marks the end of a formula
// wparam=0
// lparam=0
// result=*AnsiChar Delimiter
// !!! the result-buffer must be deleted with MTH_FREE_MATH_BUFFER

  MTH_FREE_MATH_BUFFER = 'Math/FreeRTFBitmapText';
// deletes any buffer that MathModule has created.
// wparam=0
// lparam=(*AnsiChar) buffer
// result=0

  MATH_SETBKGCOLOR = 'Math/SetBackGroundColor';
// changes the background color of the next formula to be rendered.
// wparam=0
// lparam=(COLORREF) color
// result=0

  MTH_GETBITMAP = 'Math/GetBitmap';
//returns Bitmap that represents the formula given in lparam (string-pointer)
//this formula has NO Delimiters.
//wparam=0
//lparam=(*AnsiChar)Formula
//result=(HBITMAP) bitmap
//!!! the bitmap must be deleted with DeleteObject(hobject)

//example:
//HBITMAP Bmp=(HBITMAP)CallService(MTH_GETBITMAP,0, (LPARAM)formula);

  MTH_GET_RTF_BITMAPTEXT = 'Math/GetRTFBitmapText';
// returns rich-text stream that includes bitmaps from text given in lparam
// text included between MATH_GET_STARTDELIMITER and MATH_GETENDDELIMITER
// hereby is replaced with a rtf-bitmap-stream that represents the corresponding formula
// wparam=0
// lparam=*AnsiChar text
// result=*AnsiChar rtfstream
// !!! the result-buffer must be deleted with MTH_FREE_RTF_BITMAPTEXT

  MTH_FREE_RTF_BITMAPTEXT = 'Math/FreeRTFBitmapText';
// deletes the buffer that MTH_GET_RTF_BITMAPTEXT has created.
// wparam=0
// lparam=(*AnsiChar) buffer
// result=0

{$ENDIF}