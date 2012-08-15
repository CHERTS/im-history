{$IFNDEF M_UPDATER_H}
{$DEFINE M_UPDATER_H}

const
 // if you set Update.szUpdateURL to the following value when registering, as well as setting your beta site and version data,
 // Updater will ignore szVersionURL and pbVersionPrefix, and attempt to find the file listing URL's from the backend XML data.
 // for this to work, the plugin name in pluginInfo.shortName must match the file listing exactly (except for case)
	UPDATER_AUTOREGISTER = 'UpdaterAUTOREGISTER';
  // Updater will also use the backend xml data if you provide URL's that reference the miranda file listing for updates (so you can use that method
// if e.g. your plugin shortName does not match the file listing) - it will grab the file listing id from the end of these URLs

type

    PUpdate = ^TUpdate;
    TUpdate = record
        cbSize: int;
        szComponentName: PAnsiChar;		  // component name as it will appear in the UI (will be translated before displaying)
        szVersionURL: PAnsiChar;	  	  // URL where the current version can be found (NULL to disable)
        pbVersionPrefix: PAnsiChar;		  // bytes occuring in VersionURL before the version, used to locate the version information within the URL data
                                    // (not that this URL could point at a binary file - dunno why, but it could :)
        cpbVersionPrefix: int;		  // number of bytes pionted to by pbVersionPrefix
        szUpdateURL: PAnsiChar;		      // URL where dll/zip is located
        szBetaVersionURL: PAnsiChar;	  // URL where the beta version can be found (NULL to disable betas)
      	pbBetaVersionPrefix: PAnsiChar;	// bytes occuring in VersionURL before the version, used to locate the version information within the URL data
      	cpbBetaVersionPrefix: int;	// number of bytes pionted to by pbVersionPrefix
        szBetaUpdateURL: PAnsiChar;		  // URL where dll/zip is located
      	pbVersion: PByte;		        // bytes of current version, used for comparison with those in VersionURL
        cpbVersion: int;		        // number of bytes pionted to by pbVersion
      	szBetaChangelogURL: PAnsiChar;	// URL for displaying changelog for beta versions
    end;

const

// register a comonent with the updater
//
// wparam = 0
// lparam = (LPARAM)&Update
    MS_UPDATE_REGISTER = 'Update/Register';

// utility functions to create a version string from a DWORD or from pluginInfo
// point buf at a buffer at least 16 chars wide - but note the version string returned may be shorter
//
//static AnsiChar *CreateVersionString(DWORD version, AnsiChar *buf) {
//	mir_snprintf(buf, 16, "%d.%d.%d.%d", (version >> 24) & 0xFF, (version >> 16) & 0xFF, (version >> 8) & 0xFF, version & 0xFF);
//	return buf;
//}

//static AnsiChar *CreateVersionStringPlugin(PLUGININFO *pluginInfo, AnsiChar *buf) {
//	return CreateVersionString(pluginInfo->version, buf);
//}


// register the 'easy' way - use this method if you have no beta URL and the plugin is on the miranda file listing
// NOTE: the plugin 'short name' in pluginInfo must match the name of the plugin on the file listing, exactly (including case)
// AND the plugin version string on the file listing must be the string version of the version in pluginInfo (i.e. 0.0.0.1,
// so no letters, brackets, etc.)
//
// wParam = (int)fileID				- this is the file ID from the file listing (i.e. the number at the end of the download link)
// lParam = (PLUGININFO*)&pluginInfo
    MS_UPDATE_REGISTERFL = 'Update/RegisterFL';

{$ENDIF}


/////////////// Usage Example ///////////////

{$IFDEF EXAMPLE_CODE}

// you need to #include "m_updater.h" and HookEvent(ME_SYSTEM_MODULESLOADED, OnModulesLoaded) in your Load function...

int OnModulesLoaded(WPARAM wParam, LPARAM lParam) {

	Update update = {0}; // for c you'd use memset or ZeroMemory...
	AnsiChar szVersion[16];

	update.cbSize = sizeof(Update);

	update.szComponentName = pluginInfo.shortName;
	update.pbVersion = (BYTE *)CreateVersionString(&pluginInfo, szVersion);
	update.cpbVersion = strlen((AnsiChar *)update.pbVersion);

	// these are the three lines that matter - the archive, the page containing the version string, and the text (or data) 
	// before the version that we use to locate it on the page
	// (note that if the update URL and the version URL point to standard file listing entries, the backend xml
	// data will be used to check for updates rather than the actual web page - this is not true for beta urls)
	update.szUpdateURL = "http://scottellis.com.au:81/test/updater.zip";
	update.szVersionURL = "http://scottellis.com.au:81/test/updater_test.html";
	update.pbVersionPrefix = (BYTE *)"Updater version ";
	
	update.cpbVersionPrefix = strlen((AnsiChar *)update.pbVersionPrefix);

	CallService(MS_UPDATE_REGISTER, 0, (WPARAM)&update);

	// Alternatively, to register a plugin with e.g. file ID 2254 on the file listing...
	// CallService(MS_UPDATE_REGISTERFL, (WPARAM)2254, (LPARAM)&pluginInfo);

	return 0;
}

{$ENDIF}
