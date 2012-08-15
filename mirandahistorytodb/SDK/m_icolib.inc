{$IFNDEF M_ICOLIB}
{$DEFINE M_ICOLIB}

type

    PSKINICONDESC = ^TSKINICONDESC;
    TSKINICONDESC = record
        cbSize: int;
        pszSection: PAnsiChar;		    //section name used to group icons
        pszDescription: PAnsiChar;		//description for options dialog
        pszName: PAnsiChar;			      //name to refer to icon when playing and in db
        pszDefaultFile: PAnsiChar;		//default icon file to use
        iDefaultIndex: int;		    // index of icon in default file
        hDefaultIcon: HICON;		  // handle to default icon
        cx,cy: int;			          // dimensions of icon (if 0 then standard size icon (big and small options available)
        flags: int;			          // combination of SIDF_*
    end;

const

    SIDF_SORTED       = $01;		  // Icons in section are sorted by name
    SIDF_UNICODE      = $100;		  // Section and Description are in UCS-2
    SIDF_PATH_UNICODE = $200;		  // Default File is in UCS-2
    SIDF_ALL_UNICODE  = SIDF_PATH_UNICODE or SIDF_UNICODE;


const

//
//  Add a icon into options UI
//  NB! pszName should be unique, e.g.: clistmw_apply, tabsrmm_history
//
//  wParam = (WPARAM)0
//  lParam = (LPARAM)(SKINICONDESC*)sid;
//
    MS_SKIN2_ADDICON = 'Skin2/Icons/AddIcon';
//
//  Retrieve HICON with name specified in lParam
//  wParam = (WPARAM)0 - small 1 - big
//  lParam = (LPARAM)(AnsiChar*)pszName
//  Returned HICON SHOULDN'T be destroyed, it managed by IcoLib
//
    MS_SKIN2_GETICON = 'Skin2/Icons/GetIcon';
//
//  Icons change notification
//
    ME_SKIN2_ICONSCHANGED = 'Skin2/IconsChanged';

{$ENDIF}
