(*

Miranda IM: the free IM client for Microsoft* Windows*

Copyright 2000-2007 Miranda ICQ/IM project, 
all portions of this codebase are copyrighted to the people 
listed in contributors.txt.

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

{$IFNDEF M_DBEDITOR}
{$DEFINE M_DBEDITOR}

const
{
  wParam: Module name
  lParam: 0
  Affect: register single module as 'known'
  Note:   must be used after or in ME_SYSTEM_MODULESLOADED
}
  MS_DBEDIT_REGISTERSINGLEMODULE = 'DBEditorpp/RegisterSingleModule';

{
  wParam: array with module names
  lParam: count of module names
  Affect: register modules as 'known'
  Note:   must be used after or in ME_SYSTEM_MODULESLOADED
  Example:
   var mods:array [0..2] = ('Module1','Module2','Module3');
   ...
   CallService(MS_DBEDIT_REGISTERMODULE,WPARAM(@mods),3);

}
  MS_DBEDIT_REGISTERMODULE = 'DBEditorpp/RegisterModule';

{
  wParam: hContact
  lParam: 0
  Affect: Open user tree in DBE++
}
  MS_DBEDIT_MENUCOMMAND = 'DBEditorpp/MenuCommand';

{$ENDIF}
