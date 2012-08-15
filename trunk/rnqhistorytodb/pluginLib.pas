{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit pluginLib;

interface

uses
  windows, Graphics, classes, sysutils, contacts, icqv9, events, types, dialogs,
  strutils;

{$I plugin.inc }
{ $I pluginutil.inc }

type
  Tplugin=class
    hnd:Thandle;
    screenName,
    filename:string;
    fun:TpluginFun;
    funC:TpluginFunC;
    active:boolean;

    function activate:boolean;
    procedure disactivate;
    function cast(data:string):string;
    procedure cast_preferences;
    end;

  Tplugins=class
   private
    enumIdx:integer;
    list:Tlist;
   public
    constructor create;
    destructor destroy; override;

    procedure resetEnumeration;
    function  hasMore:boolean;
    function  getNext:Tplugin;

    procedure load;
    procedure unload;
    function cast(data:string):string;                                                       overload;
    function castEv(ev_id:byte; uin, flags:integer; when:Tdatetime; cl:Tcontactlist):string;  overload;
    function castEv(ev_id:byte; uin, flags:integer; when:Tdatetime):string;                   overload;
    function castEv(ev_id:byte; uin, flags:integer; when:Tdatetime; s1:string):string;        overload;
    function castEv(ev_id:byte; uin, flags:integer; when:Tdatetime; s1,s2:string):string;     overload;
    function castEv(ev_id:byte; when:Tdatetime; name,addr,text:string):string;                overload;
    function castEv(ev_id:byte; uin, flags:integer; s1:string):string;                        overload;
    function castEv(ev_id:byte; uin:integer; s1:string):string;                               overload;
    function castEv(ev_id:byte; uin:integer; status,oldstatus:Tstatus; inv,oldInv:boolean ):string; overload;
    function castEv(ev_id:byte; uin:integer ):string;                                         overload;
    function castEv(ev_id:byte; uin, flags:integer; cl:Tcontactlist):string;                  overload;
    function castEv(ev_id:byte ):string;                                                      overload;
    function castEv(ev_id:byte; s1,s2,s3:string; b:boolean; i:integer):string;                overload; 
    function castEvList(ev_id:byte; list:byte; c:Tcontact ):string;
    end;

implementation

uses
  globalLib, forms, mainDlg, chatDlg, prefDlg, outboxLib, utilLib, outboxDlg,
  iniLib, RQUtil, RQGlobal, RQLog, langLib, RnQDialogs, Controls,
  pluginutil;


var
  outBuffer:string;   // callback result buffer

function whatwindow(id:byte):Tform;
begin
case id of
  PW_ROASTER: result:=mainfrm;
  PW_CHAT: result:=chatFrm;
  PW_PREFERENCES: result:=prefFrm;
  else result:=NIL;
  end;
end; // whatwindow

function whatlist(id:byte):TcontactList;
begin
case id of
  PL_ROASTER: result:=ICQ.readroaster;
  PL_VISIBLELIST: result:=visibleList;
  PL_INVISIBLELIST: result:=invisibleList;
  PL_IGNORELIST: result:=ignoreList;
  PL_TEMPVISIBLELIST: result:=ICQ.readTemporaryVisible;
  else result:=NIL;
  end;
end; // whatlist

function _contactinfo(c:Tcontact):string;
begin
if c=NIL then
  begin
  result:='';
  exit;
  end;
result:=_int(c.uin)
      +char(c.status)
      +char(c.invisible)
      +_istring(c.displayed)
      +_istring(c.first)
      +_istring(c.last);
end; // _contactinfo

function _icontactinfo(c:Tcontact):string;
begin result:=_istring(_contactinfo(c)) end;

function _get(what:byte):string;
begin result:=char(PM_GET)+char(what) end;

function _event(what:byte):string;
begin result:=char(PM_EVENT)+char(what) end;

function callbackStr(data:string):string; stdcall;
const
  tenthsPerDay=10*60*60*24;
var
  b:boolean;
  i:integer;
  w:Tform;
  bmp : TBitmap;
  cl:Tcontactlist;
  ints:TintegerDynArray;
  rct: TRect;

  function minimum(min:integer):boolean;
  begin
  result:=length(data) >= min;
  if not result then
    outBuffer:=char(PM_ERROR)+CHAR(PERR_BAD_REQ);
  end; // minimum

begin
ints:=NIL;
if data='' then exit;
outBuffer:=char(PM_ACK)+char(PA_OK);
case _byte_at(data,1) of
  PM_CMD: if minimum(2) then
    case _byte_at(data,2) of
      PC_SET_AUTOMSG: if minimum(2+4) then
        setAutoMsg(_istring_at(data,3));
      PC_SEND_MSG: if minimum(2+3*4) then
        begin
        outbox.add(OE_msg, _int_at(data,3), _int_at(data,7), _istring_at(data,11));
        outboxFrm.updateList;
        end;
      PC_ADD_MSG: if minimum(2+4) then        // By Rapid D
        begin
          ICQ.eventContact := contactsDB.get(_int_at(data,3));
          ICQ.eventTime := _dt_at(data,7);
          ICQ.notificationForMsg(MTYPE_PLAIN,0,TRUE, _istring_at(data, 15),FALSE);
//          ICQ.notifyListeners();
        end;
      PC_SEND_CONTACTS: if minimum(2+3*4) then
        begin
        outbox.add(OE_contacts, _int_at(data,3), _int_at(data,7), ints2cl(_intlist_at(data,11)));
        outboxFrm.updateList;
        end;
      PC_SEND_ADDEDYOU: if minimum(2+4) then
        begin
        outbox.add(OE_addedyou, _int_at(data,3));
        outboxFrm.updateList;
        end;
      PC_SEND_AUTOMSG_REQ: if minimum(2+4) then
        sendICQautomsgreq(_int_at(data,3));
      PC_LIST_REMOVE,
      PC_LIST_ADD: if minimum(2+1+4) then
        begin
        cl:=whatlist(_byte_at(data,3));
        if cl=NIL then
          outBuffer:=char(PM_ERROR)+char(PERR_UNEXISTENT)
        else
          begin
          b:= _byte_at(data,2)=PC_LIST_ADD;
          ints:=_intlist_at(data,4);
          for i:=0 to length(ints)-1 do
            if b then
              begin
              if not cl.add(contactsDB.get(ints[i])) then
                ints[i]:=0;
              end
            else
              if not cl.remove(contactsDB.get(ints[i])) then
                ints[i]:=0;
          packArray(ints, 0);
          if length(ints)>0 then
            outBuffer:=char(PM_ERROR)+char(PERR_FAILED_FOR)+_intlist(ints);
          ints:=NIL;
          end;
        end;
      PC_QUIT: quit;
      PC_SET_STATUS: if minimum(2+1) then
        userSetStatus(Tstatus(_byte_at(data,3)));
      PC_SET_VISIBILITY: if minimum(2+1) then
        userSetVisibility(Tvisibility(_byte_at(data,3)));
      PC_CONNECT: doConnect;
      PC_DISCONNECT: userSetStatus(SC_OFFLINE);
      PC_PLAYSOUND  : SoundPlay(theme.GetSound(_istring_at(data, 3)));
      PC_PLAYSOUNDFN: SoundPlay(_istring_at(data, 3));
      PC_ADDBUTTON : if minimum(2+4+4+2) then
          outBuffer := //#00#00#00 + //outBuffer+char(PM_DATA) +
                        _int(chatFrm.plugBtns.Add(Pointer(_int_at(data, 3)),
                              _int_at(data, 7), _istring_at(data, 11)));
      //by S@x
      PC_ADDTAB:
      begin
        //msgDlg(_istring_at(data, 3), mtInformation);
        outBuffer := _int(ADD_CHAT_TAB((_int_at(data, 3)), _istring_at(data, 7)));
      end;
      
      PC_DELBUTTON: if minimum(4) then chatFrm.plugBtns.Del(_int_at(data, 3));
      PC_MODIFY_BUTTON : begin if minimum(2+4+4+2) then
          chatFrm.plugBtns.Modify(_int_at(data, 3),
             _int_at(data, 7), _istring_at(data, 11)); end
      else outBuffer:=char(PM_ERROR)+char(PERR_UNK_REQ);
      end;//case
  PM_GET: if minimum(2) then
    case _byte_at(data,2) of
      PG_USER:
        if icq.myinfo=NIL then
          outBuffer:=char(PM_ERROR)+CHAR(PERR_NOUSER)
        else
          outBuffer:=char(PM_DATA)+_int(icq.myinfo.uin);
      PG_DISPLAYED_NAME: outBuffer:=char(PM_DATA)+_istring( contactsDB.get(_int_at(data,3)).displayed );
      PG_ANDRQ_VER: outBuffer:=char(PM_DATA)+_int( RnQversion );
      PG_ANDRQ_VER_STR: outBuffer:=char(PM_DATA)+_istring( ip2str(RnQversion) );
      PG_TIME: outBuffer:=char(PM_DATA)+_dt( now );
      PG_CONTACTINFO: outBuffer:=char(PM_DATA)+_icontactinfo( contactsDB.get(_int_at(data,3)) );
      PG_LIST: if minimum(3) then
        begin
        cl:=whatlist(_byte_at(data,3));
        if cl=NIL then
          outBuffer:=char(PM_ERROR)+char(PERR_UNEXISTENT)
        else
          outBuffer:=char(PM_DATA)+_intlist(cl.toIntArray);
        end;

      PG_CHAT_XYZ:
        begin
          //ShowMessage('chat coord request');
          if chatFrm.pagectrl.pagecount = 0 then
           outBuffer:=char(PM_DATA)+_intlist([0,0,0,0])
          else
          begin
            rct:= chatFrm.pagectrl.activepage.boundsrect;
            //rct.topleft:=  chatFrm.pagectrl.activepage.ClientToScreen(rct.topleft);
            //rct.bottomright:=  chatFrm.pagectrl.activepage.ClientToScreen(rct.bottomright);
            outBuffer:=char(PM_DATA)+_intlist([rct.top,rct.left,rct.right,rct.bottom]);
          end;
        end;
                         
      PG_NOF_UINLISTS: outBuffer:=char(PM_DATA)+_int( uinlists.count );
      PG_UINLIST: if minimum(2+4) then
        begin
        i:=_int_at(data,3);
        if (i >= 0) and (i < uinlists.count) then
          outBuffer:=char(PM_DATA)+_intlist( uinlists.getAt(i).cl.toIntArray )
        else
          outBuffer:=char(PM_ERROR)+char(PERR_UNEXISTENT);
        end;
      PG_AWAYTIME:
        if icq.myinfo=NIL then
          outBuffer:=char(PM_ERROR)+CHAR(PERR_NOUSER)
        else
          outBuffer:=char(PM_DATA)+_dt( autoaway.time/tenthsPerDay );
      PG_ANDRQ_PATH: outBuffer:=char(PM_DATA)+_istring( mypath );
      PG_USERTIME:
        if icq.myinfo=NIL then
          outBuffer:=char(PM_ERROR)+char(PERR_NOUSER)
        else
          outBuffer:=char(PM_DATA)+_dt( usertime/tenthsPerDay );
      PG_USER_PATH:
        if icq.myinfo=NIL then
          outBuffer:=char(PM_ERROR)+char(PERR_NOUSER)
        else
          outBuffer:=char(PM_DATA)+_istring( userpath );
      PG_CONNECTIONSTATE:
        if ICQ.isOnline then
          outBuffer:=char(PM_DATA)+char( PCS_CONNECTED )
        else
          if ICQ.isOffline then
            outBuffer:=char(PM_DATA)+char( PCS_DISCONNECTED )
          else
            outBuffer:=char(PM_DATA)+char( PCS_CONNECTING );
      PG_WINDOW:
        begin
        w:=whatwindow(_byte_at(data,3));
        if w=NIL then
          outBuffer:=char(PM_ERROR)+char(PERR_UNEXISTENT)
        else
          outBuffer:=char(PM_DATA)+_int([ w.handle, w.left, w.top, w.width, w.height ]);
        end;
      PG_AUTOMSG: outBuffer:=char(PM_DATA)+_istring(automessages[0]);
      PG_CHAT_UIN:
        if chatFrm.thisChat <> NIL then
          outBuffer := char(PM_DATA)+_int(chatFrm.thisChat.who.uin)
        else outBuffer := char(PM_ERROR)+_int(0);
      PG_TRANSLATE:
        outBuffer := char(PM_DATA) + _istring(getTranslation(_istring_at(data, 3)));
      PG_THEME_PIC:
          begin
            bmp := TBitmap.Create;
            theme.GetPic(_istring_at(data, 3), bmp);
            outBuffer := char(PM_DATA) + _int(bmp.Handle);
          end;
      else outBuffer:=char(PM_ERROR)+char(PERR_UNK_REQ);
      end;//case
  else outBuffer:=char(PM_ERROR)+char(PERR_UNK_REQ);
  end;//case
result:=outBuffer;
end; // callbackStr

function callback(data:Pinteger):pointer; stdcall;
var
  s:string;
begin
result:=NIL;
if data=NIL then exit;
setlength(s, data^);
inc(data);
move(data^, s[1], length(s));
callbackStr(s);
outBuffer:=_int(length(outBuffer))+outBuffer;
result:=@outBuffer[1];
end; // callback

////////////////////////////////////////////////////////////////////////

function Tplugin.activate:boolean;
var
  s:string;
begin
result:=FALSE;
if active then exit;
loggaEvt(filename+': loading');
hnd:=LoadLibrary(PChar(myPath+pluginsPath+filename));
if hnd=0 then exit;
fun:=GetProcAddress(hnd,'pluginFun');
if not assigned(fun) then fun:=GetProcAddress(hnd,'_pluginFun');
if assigned(fun) then loggaEvt(filename+': found pluginFun');
funC:=GetProcAddress(hnd,'pluginFunC');
if not assigned(funC) then funC:=GetProcAddress(hnd,'_pluginFunC');
if assigned(funC) then loggaEvt(filename+': found pluginFunC');
if not assigned(fun) and not assigned(funC) then
  begin
  loggaEvt(filename+': neither pluginFun and pluginFunC found');
  freeLibrary(hnd);
  exit;
  end;
active:=TRUE;
screenName:='';
//fun(NIL);
loggaEvt(filename+': initializing');
s:=cast(_event(PE_INITIALIZE)
  +_int(integer(@callback))+_int(APIversion)
  +_istring(myPath)+_istring(userPath)+_int(lastUser)
);
if (s>'') and (ord(s[1])=PM_DATA) then
  begin
  screenName:=_istring_at(s,2);
  loggaEvt(filename+': name: '+screenname);
  end;
result:=TRUE;
end; // activate

procedure Tplugin.disactivate;
begin
if not active then exit;
loggaEvt(filename+': disactivating');
cast(_event(PE_FINALIZE));
freeLibrary(hnd);
hnd := 0;fun := NIL;funC := NIL;
active:=FALSE;
end; // disactivate

function Tplugin.cast(data:string):string;
var
  p:Pinteger;
begin
result:='';
if not active or not (assigned(fun) or assigned(funC)) then exit;
data:=_int(length(data))+data;
//loggaEvt(format('%s: sending %d bytes',[filename,length(data)]));
if assigned(fun) then
  p:=fun(@data[1])
else
  p:=funC(@data[1]);
if assigned(p) then
  begin
  //loggaEvt(format('%s: received %d bytes',[filename,p^]));
  setlength(result, p^);
  inc(p);
  move(p^, result[1], length(result));
  end;
end; // cast

procedure Tplugin.cast_preferences;
begin cast(_event(PE_PREFERENCES)) end;

///////////////////////////////////////////////////////////////////////

constructor Tplugins.create;
begin
list:=Tlist.create;
end; // create

destructor Tplugins.destroy;
begin
unload;
list.free;
end; // destroy

procedure Tplugins.resetEnumeration;
begin enumIdx:=0 end;

function Tplugins.hasMore:boolean;
begin result:=enumIdx<list.count end;

function Tplugins.getNext:Tplugin;
begin
result:=Tplugin(list[enumIdx]);
inc(enumIdx);
end; // getNext

procedure Tplugins.load;
var
  sr:TsearchRec;
  plugin:Tplugin;
begin
loggaEvt('scanning for plugins: '+myPath+pluginsPath+'*.dll');
if findFirst(myPath+pluginsPath+'*.dll', faAnyFile, sr) = 0 then
  repeat
  plugin:=Tplugin.create;
  list.add(plugin);
  with plugin do
    begin
    filename:=sr.name;
    screenName:='';
    if ansiContainsText(disabledPlugins, filename) then
      loggaEvt(filename+': skipped (disabled)')
    else
      if activate then
        loggaEvt(filename+': activated')
      else
        begin
        loggaEvt(filename+': activation failed');
        list.Remove(plugin);
        plugin.free;
        end;
    end;
  until findNext(sr) <> 0;
findClose(sr);
loggaEvt('scanning end'); 
end; // load

procedure Tplugins.unload;
begin
while list.count > 0 do
  begin
  Tplugin(list.last).disactivate;
  Tplugin(list.last).free;
  list.delete(list.count-1);
  end;
end; // unload

function Tplugins.cast(data:string):string;
begin
result:='';
resetEnumeration;
while hasMore do
  result:=result+getNext.cast(data);
end; // cast

function Tplugins.castEv(ev_id:byte; s1,s2,s3:string; b:boolean; i:integer):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_istring(s1)+_istring(s2)+_istring(s3)+char(b)+_int(i)) end;

function Tplugins.castEv(ev_id:byte; uin, flags:integer; when:Tdatetime; cl:Tcontactlist):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_dt(when)+_intlist(cl.toIntArray) ) end;

function Tplugins.castEv(ev_id:byte; uin, flags:integer; when:Tdatetime):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_dt(when) ) end;

function Tplugins.castEV(ev_id:byte; uin, flags:integer; when:Tdatetime; s1:string):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_dt(when)+_istring(s1) ) end;

function Tplugins.castEv(ev_id:byte; uin, flags:integer; when:Tdatetime; s1,s2:string):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_dt(when)+_istring(s1)+_istring(s2) ) end;

function Tplugins.castEv(ev_id:byte; when:Tdatetime; name,addr,text:string):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_dt(when)+_istring(name)+_istring(addr)+_istring(text) ) end;

function Tplugins.castEv(ev_id:byte; uin, flags:integer; s1:string):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_istring(s1) ) end;

function Tplugins.castEv(ev_id:byte; uin:integer; s1:string):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_istring(s1) ) end;

function Tplugins.castEv( ev_id:byte; uin:integer; status,oldstatus:Tstatus; inv,oldInv:boolean ):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+char(status)+char(oldstatus)+char(inv)+char(oldInv) ) end;

function Tplugins.castEv(ev_id:byte; uin, flags:integer; cl:Tcontactlist):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin)+_int(flags)+_intlist(cl.toIntArray) ) end;

function Tplugins.castEv( ev_id:byte; uin:integer):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+_int(uin) ) end;

function Tplugins.castEv(ev_id:byte):string;
begin result:=cast( char(PM_EVENT)+char(ev_id) ) end;

function Tplugins.castEvList(ev_id:byte; list:byte; c:Tcontact ):string;
begin result:=cast( char(PM_EVENT)+char(ev_id)+char(list)+_intlist([c.uin]) ) end;

end.

