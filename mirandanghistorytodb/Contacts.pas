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

unit Contacts;

interface

uses
  Windows, SysUtils, Forms, Classes, Global, m_api, Database;

function GetContactDisplayName(hContact: TMCONTACT; Proto: AnsiString = ''; Contact: boolean = false): String;
function GetContactProto(hContact: TMCONTACT): AnsiString; overload;
function GetContactProto(hContact: TMCONTACT; var SubContact: TMCONTACT; var SubProtocol: AnsiString): AnsiString; overload;
function GetContactID(hContact: TMCONTACT; Proto: AnsiString = ''; Contact: boolean = false): AnsiString;
function TranslateAnsiW(const S: AnsiString): WideString;
function GetMyContactDisplayName(Proto: AnsiString): String;
function GetMyContactID(Proto: AnsiString): String;
function GetContactCodePage(hContact: TMCONTACT; const Proto: AnsiString = ''): Cardinal; overload;
function GetContactCodePage(hContact: TMCONTACT; const Proto: AnsiString; var UsedDefault: boolean): Cardinal; overload;

implementation

function GetContactProto(hContact: TMCONTACT): AnsiString;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
end;

function GetContactProto(hContact: TMCONTACT; var SubContact: TMCONTACT; var SubProtocol: AnsiString): AnsiString;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
  if (Result = META_PROTO) then
  begin
    SubContact := CallService(MS_MC_GETMOSTONLINECONTACT, hContact, 0);
    SubProtocol := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, SubContact, 0));
  end
  else
  begin
    SubContact := hContact;
    SubProtocol := Result;
  end;
end;

function GetContactDisplayName(hContact: TMCONTACT; Proto: AnsiString = ''; Contact: boolean = false): String;
var
  ci: TContactInfo;
  RetPWideChar, UW: PChar;
begin
  if (hContact = 0) and Contact then
    Result := TranslateW('Server')
  else
  begin
    if Proto = '' then
      Proto := GetContactProto(hContact);
    if Proto = '' then
      Result := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } )
    else
    begin
      ci.cbSize := SizeOf(ci);
      ci.hContact := hContact;
      ci.szProto := PAnsiChar(Proto);
      ci.dwFlag := CNF_DISPLAY + CNF_UNICODE;
      if CallService(MS_CONTACT_GETCONTACTINFO, 0, LPARAM(@ci)) = 0 then
      begin
        RetPWideChar := ci.retval.szVal.w;
        UW := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } );
        if WideCompareText(RetPWideChar, UW) = 0 then
          Result := AnsiToWideString(GetContactID(hContact, Proto), CP_ACP)
        else
          Result := RetPWideChar;
        mir_free(RetPWideChar);
      end
      else
        Result := String(GetContactID(hContact, Proto));
      if Result = '' then
        Result := TranslateAnsiW(Proto { TRANSLATE-IGNORE } );
    end;
  end;
end;

function GetContactID(hContact: TMCONTACT; Proto: AnsiString = ''; Contact: boolean = false): AnsiString;
var
  uid: PAnsiChar;
  dbv: TDBVARIANT;
  tmp: String;
begin
  Result := '';
  if not((hContact = 0) and Contact) then
  begin
    if Proto = '' then
      Proto := GetContactProto(hContact);
    uid := PAnsiChar(CallProtoService(PAnsiChar(Proto), PS_GETCAPS, PFLAG_UNIQUEIDSETTING, 0));
    if (uid <> pAnsiChar(CALLSERVICE_NOTFOUND)) and (uid <> nil) then
    begin
      if db_get(hContact, PAnsiChar(Proto), uid, @dbv) = 0 then
      begin
        case dbv._type of
          DBVT_BYTE:
            Result := AnsiString(intToStr(dbv.bVal));
          DBVT_WORD:
            Result := AnsiString(intToStr(dbv.wVal));
          DBVT_DWORD:
            Result := AnsiString(intToStr(dbv.dVal));
          DBVT_ASCIIZ:
            Result := AnsiString(dbv.szVal.a);
          DBVT_UTF8:
            begin
              tmp := AnsiToWideString(dbv.szVal.a, CP_UTF8);
              Result := WideToAnsiString(tmp, hppCodepage);
            end;
          DBVT_WCHAR:
            Result := WideToAnsiString(dbv.szVal.w, hppCodepage);
        end;
        // free variant
        DBFreeVariant(@dbv);
      end;
    end;
  end;
end;

function TranslateAnsiW(const S: AnsiString): WideString;
begin
  Result := AnsiToWideString(Translate(PAnsiChar(S)),hppCodepage);
end;

function GetMyContactDisplayName(Proto: AnsiString): String;
var
  ci: TContactInfo;
  RetPWideChar, UW: PChar;
begin
  ci.cbSize := SizeOf(ci);
  ci.hContact := 0;
  ci.szProto := PAnsiChar(Proto);
  ci.dwFlag := CNF_DISPLAY + CNF_UNICODE;
  if CallService(MS_CONTACT_GETCONTACTINFO, 0, LPARAM(@ci)) = 0 then
  begin
    RetPWideChar := ci.retval.szVal.w;
    UW := TranslateW('Unknown Contact');
    if WideCompareText(RetPWideChar, UW) = 0 then
      Result := TranslateW('Unknown Contact')
    else
      Result := RetPWideChar;
  end
  else
      Result := TranslateW('Unknown Contact');
end;

function GetMyContactID(Proto: AnsiString): String;
var
  ci: TContactInfo;
  RetPWideChar, UW: PChar;
  TmpContactID: AnsiString;
begin
  ci.cbSize := SizeOf(ci);
  ci.hContact := 0;
  ci.szProto := PAnsiChar(Proto);
  ci.dwFlag := CNF_DISPLAY + CNF_UNICODE;
  if CallService(MS_CONTACT_GETCONTACTINFO, 0, LPARAM(@ci)) = 0 then
  begin
    RetPWideChar := ci.retval.szVal.w;
    UW := TranslateW('Unknown Contact');
    if WideCompareText(RetPWideChar, UW) = 0 then
      Result := TranslateW('Unknown Contact')
    else
    begin
      TmpContactID := GetContactID(ci.hContact, Proto);
      if TmpContactID <> '' then
        Result := TmpContactID
      else
        Result := TranslateW('Unknown Contact');
    end;
  end
  else
      Result := TranslateW('Unknown Contact');
end;

function _GetContactCodePage(hContact: TMCONTACT; Proto: AnsiString; var UsedDefault: boolean) : Cardinal;
begin
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppCodepage
  else
  begin
    Result := GetDBWord(hContact, Proto, 'AnsiCodePage', $FFFF);
    If Result = $FFFF then
      Result := GetDBWord(0, Proto, 'AnsiCodePage', CP_ACP);
    UsedDefault := (Result = CP_ACP);
    if UsedDefault then
      Result := GetACP();
  end;
end;

function GetContactCodePage(hContact: TMCONTACT; const Proto: AnsiString = ''): Cardinal;
var
  def: boolean;
begin
  Result := _GetContactCodePage(hContact, Proto, def);
end;

function GetContactCodePage(hContact: TMCONTACT; const Proto: AnsiString; var UsedDefault: boolean): Cardinal; overload;
begin
  Result := _GetContactCodePage(hContact, Proto, UsedDefault);
end;

end.
