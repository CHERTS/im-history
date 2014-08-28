!include "MUI2.nsh"
!include "UAC.nsh"

!define HOME ".\..\..\Release\2.6.0\x86"
!define SKYPEHOME ".\..\..\Release\2.6.0\x86\skype"
!define INSTALLERHOME ".\..\..\Release\2.6.0"

!define PRODUCT_NAME "SkypeHistoryToDB"
!define NAME "SkypeHistoryToDB"
!define VERSION 2.6.0
!define COMPANY "Michael Grigorev"
!define URL http://www.im-history.ru
!define /date DbTIMESTAMP "%Y-%m-%d-%H-%M-%S"

;--------------------------------
;Configuration

  ;General

  OutFile ${INSTALLERHOME}\SkypeHistoryToDB-Setup-${VERSION}.exe

  ;bzip2
  SetCompressor /SOLID lzma

  ShowUninstDetails show
  ShowInstDetails show

  CRCCheck on
  XPStyle on

  ;Folder selection page
  InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
  
  VIProductVersion ${VERSION}.0
  VIAddVersionKey ProductName "${NAME}"
  VIAddVersionKey ProductVersion "${VERSION}"
  VIAddVersionKey CompanyName "${COMPANY}"
  VIAddVersionKey CompanyWebsite "${URL}"
  VIAddVersionKey FileVersion "${VERSION}"
  VIAddVersionKey FileDescription "${NAME}"
  VIAddVersionKey LegalCopyright "${COMPANY}"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;----------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
;  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
;  !define MUI_LANGDLL_REGISTRY_KEY "Software\${PRODUCT_NAME}"
;  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  
;--------------------------------
;Modern UI Configuration

  Name "${PRODUCT_NAME}"

  !define MUI_COMPONENTSPAGE_SMALLDESC
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !define MUI_ABORTWARNING
  !define MUI_ICON "icon.ico"
  !define MUI_UNICON "icon.ico"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "logo.bmp"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "left_logo.bmp"
  !define MUI_UNFINISHPAGE_NOAUTOCLOSE

  ;!define MUI_FINISHPAGE_RUN_TEXT "$(FinishPageRunDesc)"
  ;!define MUI_FINISHPAGE_RUN "SkypeHistoryToDB.exe"
  ;!define MUI_FINISHPAGE_RUN_FUNCTION PageFinishRun

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES  
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "Russian"

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------

;Function PageFinishRun
;!insertmacro UAC_AsUser_ExecShell "" "$INSTDIR\SkypeHistoryToDB.exe" "" "" ""
;FunctionEnd

;--------------------------------
;Installer Functions

Function .onInit

uac_tryagain:
!insertmacro UAC_RunElevated
${Switch} $0
${Case} 0
	${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
	${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
	${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
		MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This installer requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
	${EndIf}
	;fall-through and die
${Case} 1223
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This installer requires admin privileges, aborting!"
	Quit
${Case} 1062
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
	Quit
${Default}
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate , error $0"
	Quit
${EndSwitch}

  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

;--------------------------------
;Macros

!macro WriteRegStringIfUndef ROOT SUBKEY KEY VALUE
Push $R0
ReadRegStr $R0 "${ROOT}" "${SUBKEY}" "${KEY}"
StrCmp $R0 "" +1 +2
WriteRegStr "${ROOT}" "${SUBKEY}" "${KEY}" '${VALUE}'
Pop $R0
!macroend

!macro DelRegStringIfUnchanged ROOT SUBKEY KEY VALUE
Push $R0
ReadRegStr $R0 "${ROOT}" "${SUBKEY}" "${KEY}"
StrCmp $R0 '${VALUE}' +1 +2
DeleteRegValue "${ROOT}" "${SUBKEY}" "${KEY}"
Pop $R0
!macroend

!macro DelRegKeyIfUnchanged ROOT SUBKEY VALUE
Push $R0
ReadRegStr $R0 "${ROOT}" "${SUBKEY}" ""
StrCmp $R0 '${VALUE}' +1 +2
DeleteRegKey "${ROOT}" "${SUBKEY}"
Pop $R0
!macroend

!macro DelRegKeyIfEmpty ROOT SUBKEY
Push $R0
EnumRegValue $R0 "${ROOT}" "${SUBKEY}" 1
StrCmp $R0 "" +1 +2
DeleteRegKey /ifempty "${ROOT}" "${SUBKEY}"
Pop $R0
!macroend

;--------------------------------
;Language Strings

LangString SecAddShortcutsDesc ${LANG_RUSSIAN} "Добавить ярлыки в меню Пуск"
LangString SecAddShortcutsDesc ${LANG_ENGLISH} "Add shortcuts to Start Menu"

LangString SecAddShortcutsInDesktopDesc ${LANG_RUSSIAN} "Добавить ярлык на Рабочий стол"
LangString SecAddShortcutsInDesktopDesc ${LANG_ENGLISH} "Add shortcut to the Desktop"

LangString RunSkypeHistoryToDBDesc ${LANG_RUSSIAN} "Запустить SkypeHistoryToDB и Skype.lnk"
LangString RunSkypeHistoryToDBDesc ${LANG_ENGLISH} "Run SkypeHistoryToDB ans Skype.lnk"

LangString RunSkypeHistoryToDBViewerDesc ${LANG_RUSSIAN} "Просмотр истории сообщений.lnk"
LangString RunSkypeHistoryToDBViewerDesc ${LANG_ENGLISH} "View the history.lnk"

LangString DeleteSkypeHistoryToDBDesc ${LANG_RUSSIAN} "Удалить программу SkypeHistoryToDB.lnk"
LangString DeleteSkypeHistoryToDBDesc ${LANG_ENGLISH} "Uninstall SkypeHistoryToDB.lnk"

LangString FinishPageRunDesc ${LANG_RUSSIAN} "Запустить SkypeHistoryToDB и Skype"
LangString FinishPageRunDesc ${LANG_ENGLISH} "Run SkypeHistoryToDB and Skype"

;--------------------------------
;Installer Sections

;!define SF_SELECTED   1
;!define SF_RO         16
!define SF_NOT_RO     0xFFFFFFEF

Section "SkypeHistoryToDB" SecMainProgramUserSpace

  SetOverwrite on
  SetOutPath "$INSTDIR"

  File "${HOME}\fbclient.dll"
  File "${HOME}\firebird.msg"
  File "${HOME}\HistoryToDBImport.exe"
  File "${HOME}\HistoryToDBSync.exe"
  File "${HOME}\HistoryToDBUpdater.exe"
  File "${HOME}\HistoryToDBViewer.exe"
  File "${HOME}\libeay32.dll"
  File "${HOME}\libintl.dll"
  File "${HOME}\libmysql.dll"
  File "${HOME}\libmariadb.dll"
  File "${HOME}\libpq.dll"
  File "${HOME}\msvcr100.dll"
  File "${HOME}\sqlite3.dll"
  File "${HOME}\ssleay32.dll"
  File "${HOME}\uninstall.ico"
  File "${HOME}\faq.txt"

  File "${SKYPEHOME}\start_sync.cmd"
  File "${SKYPEHOME}\start_viewer.cmd"
  File "${SKYPEHOME}\update.txt"
  File "${SKYPEHOME}\changelog.txt"
  File "${SKYPEHOME}\readme.txt"
  File "${SKYPEHOME}\installupdater-en.cmd"
  File "${SKYPEHOME}\installupdater-ru.cmd"
  
  SetOutPath "$INSTDIR\langs"
  File "${HOME}\langs\English.xml"
  File "${HOME}\langs\Russian.xml"

  SetOutPath "$INSTDIR\sql"
  File "${HOME}\sql\firebird.sql"
  File "${HOME}\sql\mysql.sql"
  File "${HOME}\sql\oracle.sql"
  File "${HOME}\sql\postgresql.sql"
  File "${HOME}\sql\sqlite.sql"
  File "${HOME}\sql\imhistory.sqlite"

  ;---- Start ini file check ------
  SetOutPath "$INSTDIR"
  IfFileExists "$INSTDIR\HistoryToDB.ini" 0 nextiniinst
   CreateDirectory $INSTDIR\backup
   CopyFiles "$INSTDIR\HistoryToDB.ini" "$INSTDIR\backup\HistoryToDB-${DbTIMESTAMP}.ini"
  Goto skype4com

  nextiniinst:
   File "${SKYPEHOME}\HistoryToDB.ini"
  Goto skype4com
  ;---- End ini file check ------

  ;---- Start skype4com file check ------
  skype4com:
  SetOutPath "$INSTDIR"
  IfFileExists "$COMMONFILES\Skype\Skype4COM.dll" dbfile copyskype4com

  copyskype4com:
   File "${SKYPEHOME}\Skype4COM.dll"
   CreateDirectory $COMMONFILES\Skype
   CopyFiles "$INSTDIR\Skype4COM.dll" "$COMMONFILES\Skype"
  Goto dbfile
  ;---- End skype4com file check ------

  ;---- Start db file check ------
  dbfile:
  SetOutPath "$INSTDIR"
  IfFileExists "$INSTDIR\imhistory.sqlite" 0 nextdbinst
   CreateDirectory $INSTDIR\backup
   CopyFiles "$INSTDIR\imhistory.sqlite" "$INSTDIR\backup\imhistory-${DbTIMESTAMP}.sqlite"
  Goto updatefile

  nextdbinst:
   File "${SKYPEHOME}\imhistory.sqlite"
  Goto updatefile
  ;---- End db file check ------

  updatefile:
  SetOutPath "$INSTDIR\update"
  File "${HOME}\update\firebird-update-20-to-21.sql"
  File "${HOME}\update\firebird-update-21-to-22.sql"
  File "${HOME}\update\firebird-update-22-to-23.sql"
  File "${HOME}\update\firebird-update-23-to-24.sql"
  File "${HOME}\update\firebird-update-24-to-25.sql"
  File "${HOME}\update\firebird-update-25-to-26.sql"
  File "${HOME}\update\mysql-update-10-to-11.sql"
  File "${HOME}\update\mysql-update-10-to-12.sql"
  File "${HOME}\update\mysql-update-10-to-20.sql"
  File "${HOME}\update\mysql-update-11-to-12.sql"
  File "${HOME}\update\mysql-update-11-to-20.sql"
  File "${HOME}\update\mysql-update-12-to-20.sql"
  File "${HOME}\update\mysql-update-20-to-21.sql"
  File "${HOME}\update\mysql-update-21-to-22.sql"
  File "${HOME}\update\mysql-update-22-to-23.sql"
  File "${HOME}\update\mysql-update-23-to-24.sql"
  File "${HOME}\update\mysql-update-24-to-25.sql"
  File "${HOME}\update\mysql-update-25-to-26.sql"
  File "${HOME}\update\oracle-update-20-to-21.sql"
  File "${HOME}\update\oracle-update-21-to-22.sql"
  File "${HOME}\update\oracle-update-22-to-23.sql"
  File "${HOME}\update\oracle-update-23-to-24.sql"
  File "${HOME}\update\oracle-update-24-to-25.sql"
  File "${HOME}\update\oracle-update-25-to-26.sql"
  File "${HOME}\update\postgresql-update-10-to-11.sql"
  File "${HOME}\update\postgresql-update-10-to-12.sql"
  File "${HOME}\update\postgresql-update-10-to-20.sql"
  File "${HOME}\update\postgresql-update-11-to-12.sql"
  File "${HOME}\update\postgresql-update-11-to-20.sql"
  File "${HOME}\update\postgresql-update-12-to-20.sql"
  File "${HOME}\update\postgresql-update-20-to-21.sql"
  File "${HOME}\update\postgresql-update-21-to-22.sql"
  File "${HOME}\update\postgresql-update-22-to-23.sql"
  File "${HOME}\update\postgresql-update-23-to-24.sql"
  File "${HOME}\update\postgresql-update-24-to-25.sql"
  File "${HOME}\update\postgresql-update-25-to-26.sql"
  File "${HOME}\update\sqlite-update-10-to-11.sql"
  File "${HOME}\update\sqlite-update-10-to-12.sql"
  File "${HOME}\update\sqlite-update-10-to-20.sql"
  File "${HOME}\update\sqlite-update-11-to-12.sql"
  File "${HOME}\update\sqlite-update-11-to-20.sql"
  File "${HOME}\update\sqlite-update-12-to-20.sql"
  File "${HOME}\update\sqlite-update-20-to-21.sql"
  File "${HOME}\update\sqlite-update-21-to-22.sql"
  File "${HOME}\update\sqlite-update-22-to-23.sql"
  File "${HOME}\update\sqlite-update-23-to-24.sql"
  File "${HOME}\update\sqlite-update-24-to-25.sql"
  File "${HOME}\update\sqlite-update-25-to-26.sql"

  SetOutPath "$INSTDIR"

SectionEnd

Section $(SecAddShortcutsDesc) SecAddShortcuts

  SetOverwrite on
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\$(RunSkypeHistoryToDBDesc)" "$INSTDIR\start_sync.cmd" "" "$INSTDIR\HistoryToDBSync.exe" 0
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\$(RunSkypeHistoryToDBViewerDesc)" "$INSTDIR\start_viewer.cmd" "" "$INSTDIR\HistoryToDBSync.exe" 0
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\$(DeleteSkypeHistoryToDBDesc)" "$INSTDIR\uninstall.exe" "" $INSTDIR\uninstall.ico 0

SectionEnd

Section $(SecAddShortcutsInDesktopDesc) SecAddShortcutsInDesktop

  SetOverwrite on
  SetShellVarContext all
  CreateShortCut "$DESKTOP\$(RunSkypeHistoryToDBDesc)" "$INSTDIR\start_sync.cmd" "" "$INSTDIR\HistoryToDBSync.exe" 0
  CreateShortCut "$DESKTOP\$(RunSkypeHistoryToDBViewerDesc)" "$INSTDIR\start_viewer.cmd" "" "$INSTDIR\HistoryToDBSync.exe" 0

SectionEnd

;--------------------------------
;Language Strings

  LangString DESC_SecMainProgramUserSpace ${LANG_RUSSIAN} "Установить программу."
  LangString DESC_SecAddShortcuts ${LANG_RUSSIAN} "Добавить ярлыки в меню Пуск."
  LangString DESC_SecAddShortcutsInDesktop ${LANG_RUSSIAN} "Добавить ярлык на Рабочий стол."

  LangString DESC_SecMainProgramUserSpace ${LANG_ENGLISH} "Install main programms."
  LangString DESC_SecAddShortcuts ${LANG_ENGLISH} "Add shortcuts to the current user's Start Menu."
  LangString DESC_SecAddShortcutsInDesktop ${LANG_ENGLISH} "Add shortcuts to the Desktop."

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMainProgramUserSpace} $(DESC_SecMainProgramUserSpace)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecAddShortcuts} $(DESC_SecAddShortcuts)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecAddShortcutsInDesktop} $(DESC_SecAddShortcutsInDesktop)
!insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------
;Post-install section

Section -post

  ; Store install folder in registry
  WriteRegStr HKLM "SOFTWARE\${PRODUCT_NAME}" "" $INSTDIR

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Show up in Add/Remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME} v${VERSION}"
  WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon" "$INSTDIR\uninstall.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayVersion" "${VERSION}"

SectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE
  
FunctionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.txt"
  Delete "$INSTDIR\*.ini"
  Delete "$INSTDIR\*.log"
  Delete "$INSTDIR\*.msg"
  Delete "$INSTDIR\*.cmd"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\*.sqlite"
  Delete "$INSTDIR\*.ico"
  Delete "$INSTDIR\langs\*.*"
  Delete "$INSTDIR\sql\*.*"
  Delete "$INSTDIR\update\*.*"
  Delete "$INSTDIR\backup\*.*"
  Delete /REBOOTOK $INSTDIR\uninstall.exe

  RMDir /r "$INSTDIR\langs"
  RMDir /r "$INSTDIR\sql"
  RMDir /r "$INSTDIR\update"
  RMDir /r "$INSTDIR\backup"
  RMDir "$INSTDIR"

  SetShellVarContext all
  Delete "$DESKTOP\$(RunSkypeHistoryToDBDesc)"
  Delete "$DESKTOP\$(RunSkypeHistoryToDBViewerDesc)"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\$(RunSkypeHistoryToDBDesc)"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\$(RunSkypeHistoryToDBViewerDesc)"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\$(DeleteSkypeHistoryToDBDesc)"
  RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"

  DeleteRegKey HKLM "SOFTWARE\${PRODUCT_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

SectionEnd
