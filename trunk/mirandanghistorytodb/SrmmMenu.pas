{ ################################################################################ }
{ #                                                                              # }
{ #  MirandaNG HistoryToDB Plugin v2.6                                           # }
{ #                                                                              # }
{ #  License: GPLv3                                                              # }
{ #                                                                              # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com)     # }
{ #                                                                              # }
{ ################################################################################ }

{ ################################################################################ }
{ #                                                                              # }
{ # History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*  # }
{ #                                                                              # }
{ # Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.                     # }
{ # History+ parts (C) 2001 Christian Kastner                                    # }
{ #                                                                              # }
{ # This program is free software; you can redistribute it and/or modify         # }
{ # it under the terms of the GNU General Public License as published by         # }
{ # the Free Software Foundation; either version 2 of the License, or            # }
{ # (at your option) any later version.                                          # }
{ #                                                                              # }
{ # This program is distributed in the hope that it will be useful,              # }
{ # but WITHOUT ANY WARRANTY; without even the implied warranty of               # }
{ # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                # }
{ # GNU General Public License for more details.                                 # }
{ #                                                                              # }
{ # You should have received a copy of the GNU General Public License            # }
{ # along with this program; if not, write to the Free Software                  # }
{ # Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA    # }
{ #                                                                              # }
{ ################################################################################ }

unit SrmmMenu;

interface

uses m_api, windows, messages, global;

var
  MenuWnd    : HWND;
  PopupMenu  : HMENU;
  ActiveMenu : HMENU;

procedure InitSrmmMenu;
procedure UninitSrmmMenu;
procedure CreateWindow(var Wnd: HWND);
procedure DestroyWindow(var Wnd: HWND);
procedure OnMenuItemClick(ItemID: Integer);
function PopupMenuWndProc(wnd: hWnd; msg, wParam, lParam: longint): longint; stdcall;

implementation

procedure InitSrmmMenu;
begin
  // Создяем меню
  CreateWindow(MenuWnd);
  PopupMenu := CreatePopupMenu;
  AppendMenu(PopupMenu, MF_STRING, 1, PWideChar(GetLangStr('SyncButton')));
  AppendMenu(PopupMenu, MF_SEPARATOR, 2, '-');
  AppendMenu(PopupMenu, MF_STRING, 3, PWideChar(GetLangStr('GetContactListButton')));
  AppendMenu(PopupMenu, MF_STRING, 4, PWideChar(GetLangStr('CheckMD5Hash')));
  AppendMenu(PopupMenu, MF_STRING, 5, PWideChar(GetLangStr('CheckAndDeleteMD5Hash')));
  AppendMenu(PopupMenu, MF_STRING, 6, PWideChar(GetLangStr('UpdateContactListButton')));
  AppendMenu(PopupMenu, MF_STRING, 7, PWideChar(GetLangStr('CheckUpdateButton')));
  AppendMenu(PopupMenu, MF_SEPARATOR, 8, '-');
  AppendMenu(PopupMenu, MF_STRING, 9, PWideChar(GetLangStr('SettingsButton')));
  AppendMenu(PopupMenu, MF_SEPARATOR, 10, '-');
  AppendMenu(PopupMenu, MF_STRING, 11, PWideChar(GetLangStr('AboutButton')));
end;

procedure UninitSrmmMenu;
begin
  // Удаляем меню
  DestroyMenu(PopupMenu);
  DestroyWindow(MenuWnd);
end;

// Обработчик пунктов меню
procedure OnMenuItemClick(ItemID: Integer);
begin
  case ItemID of
    1: OnSendMessageToOneComponent('HistoryToDBSync for ' + htdIMClientName + ' ('+MyAccount+')', '002');
  end;
end;

// Оконная процедура меню
function PopupMenuWndProc(wnd: hWnd; msg, wParam, lParam: longint): longint; stdcall;
begin
  case msg of
    WM_COMMAND:
      begin
        if ActiveMenu = PopupMenu then
         OnMenuItemClick(Lo(wParam));
        Result := 0;
      end;
    WM_INITMENUPOPUP:
        ActiveMenu := wParam
    else
      Result := DefWindowProc(wnd, msg, WParam, LParam);
  end;
end;

// Создаём окошко для меню
procedure CreateWindow(var Wnd: HWND);
var
  wc: WndClass;
begin
  wc.style := 0;
  wc.lpfnWndProc := @PopupMenuWndProc;
  wc.cbClsExtra := 0;
  wc.cbWndExtra := 0;
  wc.hInstance := hInstance;
  wc.hIcon := 0;
  wc.hCursor := 0;
  wc.hbrBackground := 0;
  wc.lpszMenuName := nil;
  wc.lpszClassName := 'IMHistoryPopupMenuProcessor';
  Windows.RegisterClass(wc);
  Wnd := CreateWindowEx(WS_EX_APPWINDOW, 'IMHistoryPopupMenuProcessor',
    '', WS_POPUP, 0, 0, 0, 0, 0, 0, hInstance, nil);
end;

// Уничтожаем окошко для меню
procedure DestroyWindow(var Wnd: HWND);
begin
  Windows.DestroyWindow(Wnd);
  Wnd := 0;
end;

end.
