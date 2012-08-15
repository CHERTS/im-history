{ ############################################################################ }
{ #                                                                          # }
{ #  Miranda HistoryToDB Plugin v2.4                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

{$IFNDEF M_HISTORYTODB}
{$DEFINE M_HISTORYTODB}

const

  // MS_MHTD_SHOWHISTORY
  // (supported from 2.4.0)
  // Open history
  // wParam - zero
  // lParam - zero
  // Return - 0
  MS_MHTD_SHOWHISTORY = 'MirandaHistoryToDB/ShowHistory';

  // MS_MHTD_SHOWCONTACTHISTORY
  // (supported from 2.4.0)
  // Open contact history
  // wParam - hContact
  // lParam - zero
  // Return - 0
  MS_MHTD_SHOWCONTACTHISTORY = 'MirandaHistoryToDB/ShowContactHistory';

  // MS_MHTD_GETVERSION
  // (supported from 2.4.0)
  // Get current MirandaHistoryToDB version
  // wParam - zero
  // lParam - zero
  // Return - current version, via PLUGIN_MAKE_VERSION macro
  MS_MHTD_GETVERSION = 'MirandaHistoryToDB/GetVersion';

{$ENDIF}
