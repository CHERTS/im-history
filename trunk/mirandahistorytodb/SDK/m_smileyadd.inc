(*
Miranda SmileyAdd Plugin
Plugin support header file
Copyright (C) 2004-2006 borkra, portions by Rein-Peter de Boer

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

{$IFNDEF M_SMILEYADD}
{$DEFINE M_SMILEYADD}

const
SAFLRE_INSERTEMF    = 2;        // insert smiley as EMF into RichEdit, otherwise bitmap inserted
                                // this flag allows "true" transparency
SAFLRE_OUTGOING     = 4;        // Parsing outgoing message
SAFLRE_NOCUSTOM     = 8;        // Do not use custom smileys

type
  PSMADD_RICHEDIT = ^SMADD_RICHEDIT;
  SMADD_RICHEDIT = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PAnsiChar;
  end;

  PSMADD_RICHEDIT2 = ^SMADD_RICHEDIT2;
  SMADD_RICHEDIT2 = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PAnsiChar;
    useSounds: Boolean;
    disableRedraw: Boolean;
  end;

  PSMADD_RICHEDIT3 = ^SMADD_RICHEDIT3;
  SMADD_RICHEDIT3 = record
    cbSize: Integer;
    hwndRichEditControl: HWND;
    rangeToReplace: ^CharRange;
    ProtocolName: PAnsiChar;
    flags: integer;
    disableRedraw: Boolean;
    hContact: THandle;
  end;

const

//Replace smileys in a rich edit control...
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_RICHEDIT3*) &smre;  //pointer to SMADD_RICHEDIT3
//return: TRUE if API succeeded (all parameters were valid) , FALSE if not.
MS_SMILEYADD_REPLACESMILEYS     = 'SmileyAdd/ReplaceSmileys';

type
  PSMADD_SHOWSEL3 = ^SMADD_SHOWSEL3;
  SMADD_SHOWSEL3 = record
    cbSize: Integer;            //size of the structure
    Protocolname: PAnsiChar;        //protocol to use... if you have defined a protocol, you can
                                //use your own protocol name. Smiley add will automatically
                                //select the smileypack that is defined for your protocol.
                                //Or, use "Standard" for standard smiley set. Or "ICQ", "MSN"
                                //if you prefer those icons.
                                //If not found or NULL: "Standard" will be used
    xPosition: Integer;         //Postition to place the selectwindow
    yPosition: Integer;         // "
    Direction: Integer;         //Direction (i.e. size upwards/downwards/etc) of the window 0, 1, 2, 3

    hwndTarget: HWND;           //Window, where to send the message when smiley is selected.
    targetMessage: Cardinal;    //Target message, to be sent.
    targetWParam: WPARAM;       //Target WParam to be sent (LParam will be AnsiChar* to select smiley)
                                //see the example file.
    hwndParent: HWND;           //Parent window for smiley dialog
    hContact: THandle;          //Contact handle
  end;

const

//Show smiley selection window
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_SHOWSEL3*) &smre;  //pointer to SMADD_SHOWSEL3
//return: TRUE if API succeeded (all parameters were valid) , FALSE if not.
MS_SMILEYADD_SHOWSELECTION      = 'SmileyAdd/ShowSmileySelection';

type
  PSMADD_INFO2 = ^SMADD_INFO2;
  SMADD_INFO2 = record
    cbSize: Integer;            //size of the structure
    Protocolname: PAnsiChar;        //   "             "
    ButtonIcon: HICON;          //RETURN VALUE: this is filled with the icon handle
                                //of the smiley that can be used on the button
                                //if used with GETINFO2 handle must be destroyed by user!
                                //NULL if the buttonicon is not defined...
    NumberOfVisibleSmileys: Integer; //Number of visible smileys defined.
    NumberOfSmileys: Integer;        //Number of total smileys defined
    hContact: THandle;          //Contact handle
  end;

const

//get button smiley icon
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_INFO2*) &smgi;  //pointer to SMADD_INFO2
//return: TRUE if API succeeded (all parameters were valid) , FALSE if not.
MS_SMILEYADD_GETINFO2           = 'SmileyAdd/GetInfo2';

// Event notifies that SmileyAdd options have changed
// Message dialogs usually need to redraw it's content on reception of this event
//wParam = Contact handle which options have changed, NULL if global options changed
//lParam = (LPARAM) 0; not used
ME_SMILEYADD_OPTIONSCHANGED      = 'SmileyAdd/OptionsChanged';

SAFL_PATH     = 1;              // provide smiley file path, icon otherwise
SAFL_UNICODE  = 2;              // string fields in OPTIONSDIALOGPAGE are WCHAR*
SAFL_OUTGOING = 4;              // Parsing outgoing message
SAFL_NOCUSTOM = 8;              // Do not use custom smileys

type
  PSMADD_BATCHPARSE2 = ^SMADD_BATCHPARSE2;
  SMADD_BATCHPARSE2 = record
    cbSize: Integer;            //size of the structure
    Protocolname: PAnsiChar;        //protocol to use... if you have defined a protocol, u can
                                //use your own protocol name. Smiley add wil automatically
                                //select the smileypack that is defined for your protocol.
                                //Or, use "Standard" for standard smiley set. Or "ICQ", "MSN"
                                //if you prefer those icons.
                                //If not found or NULL: "Standard" will be used
    str: TCHAR;
    flag: Cardinal;             //One of the SAFL_ flags specifies parsing requirements
                                //This parameter should be filled by the user

    numSmileys: Integer;        //Number of Smileys found, this parameter filled by SmileyAdd
    oflag: Cardinal;            //One of the SAFL_ flags specifies content of the parse results
                                //this parameter filled by SmileyAdd
    hContact: THandle;          //Contact handle
  end;

  PSMADD_BATCHPARSERES = ^SMADD_BATCHPARSERES;
  SMADD_BATCHPARSERES = record
    startChar: Cardinal;        //Starting smiley character
                                //Because of iterative nature of the API caller should set this
                                //parameter to correct value
    size: Cardinal;             //Number of characters in smiley (0 if not found)
                                //Because of iterative nature of the API caller should set this
                                //parameter to correct value
    case Integer of
      0: (filepath: TCHAR);
      1: (afilepath: PAnsiChar);
      2: (wfilepath: PWideChar);
      3: (hIcon: HICON);
  end;

const

//find all smileys in text, API parses the provided text and returns all smileys found
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_BATCHPARSE2*) &smgp;  //pointer to SMADD_BATCHPARSE2
//function returns pointer to array SMADD_BATCHPARSERES records for each smiley found
//if no smileys found NULL is returned
//if non NULL value returned pointer must be freed with MS_SMILEYADD_BATCHFREE API
MS_SMILEYADD_BATCHPARSE         = 'SmileyAdd/BatchParse';

//Free memory allocated by MS_SMILEYADD_BATCHPARSE
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_BATCHPARSERES*) &smgp;  //pointer to SMADD_BATCHPARSERES
MS_SMILEYADD_BATCHFREE          = 'SmileyAdd/BatchFree';

type
  PSMADD_REGCAT = ^SMADD_REGCAT;
  SMADD_REGCAT = record
    cbSize: Integer;            //size of the structure
    name: PAnsiChar;                //smiley category name for reference
    dispname: PAnsiChar;            //smiley category name for display
  end;

const
//Register smiley category
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_REGCAT*) &smgp;  //pointer to SMADD_REGCAT
MS_SMILEYADD_REGISTERCATEGORY   = 'SmileyAdd/RegisterCategory';

type
  PSMADD_CONT = ^SMADD_CONT;
  SMADD_CONT = record
    cbSize: Integer;            //size of the structure
    hContact: THandle;
    type_: Integer;             // 0 - directory, 1 - file
    case Integer of             // smiley category name for reference
      0: (path: TCHAR);
      1: (apath: PAnsiChar);
      2: (wpath: PWideChar);
  end;

const
//Loads all smileys for the contact
//wParam = (WPARAM) 0; not used
//lParam = (LPARAM) (SMADD_CONT*) &dir;  // pointer to directory to load smiley from
MS_SMILEYADD_LOADCONTACTSMILEYS = 'SmileyAdd/LoadContactSmileys';

{$ENDIF}