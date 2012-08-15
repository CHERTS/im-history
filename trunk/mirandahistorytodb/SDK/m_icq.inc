(*

Miranda IM: the free IM client for Microsoft* Windows*

Copyright 2000-2003 Miranda ICQ/IM project,
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

{$IFNDEF M_ICQ}
{$DEFINE M_ICQ}

const

    // extra flags for PSS_MESSAGE
    PIMF_ROUTE_DEFAULT          = 0;
    PIMF_ROUTE_DIRECT           = $10000;
    PIMF_ROUTE_THRUSERVER       = $20000;
    PIMF_ROUTE_BESTWAY          = $30000;
    PIMF_ROUTE_MASK             = $30000;

    // for SMS

    //SMSes received from phones come through this same ack, again to avoid having
    //an XML parser in the protocol module. Here's one I got:
    //"<sms_message><source>MTN</source><destination_UIN>[UIN of recipient, ie this account]</destination_UIN><sender>[sending phone number, without +]</sender><senders_network>[contains one space, because I sent from ICQ]</senders_network><text>[body of the message]</text><time>Fri, 16 Nov 2001 03:12:33 GMT</time></sms_message>"
    ICQACKTYPE_SMS              = 1001;
    ICQEVENTTYPE_SMS            = 2001;    //database event type

    //e-mail express
    //db event added to NULL contact
    //blob format is:
    //ASCIIZ    text, usually of the form "Subject: %s\r\n%s"
    //ASCIIZ    from name
    //ASCIIZ    from e-mail
    ICQEVENTTYPE_EMAILEXPRESS   = 2002;  //database event type

    //www pager
    //db event added to NULL contact
    //blob format is:
    //ASCIIZ    text, usually "Sender IP: xxx.xxx.xxx.xxx\r\n%s"
    //ASCIIZ    from name
    //ASCIIZ    from e-mail
    ICQEVENTTYPE_WEBPAGER       = 2003;    //database event type

    //for server-side lists, used internally only
    //hProcess=dwSequence
    //lParam=server's error code, 0 for success
    ICQACKTYPE_SERVERCLIST      = 1003;

    //for rate warning distribution (mainly upload dlg)
    //hProcess=Rate class ID
    //lParam=server's status code
    ICQACKTYPE_RATEWARNING      = 1004;

    //received Xtraz Notify response
    //hProcess=dwSequence
    //lParam=contents of RES node
    ICQACKTYPE_XTRAZNOTIFY_RESPONSE = 1005;

    //received Custom Status details response
    //hProcess=dwSequence
    //lParam=0
    ICQACKTYPE_XSTATUS_RESPONSE = 1006;

    //auth
    //db event added to NULL contact
    //blob format is:
    //ASCIIZ    text
    //DWORD     uin
    //HANDLE    hContact
    ICQEVENTTYPE_AUTH_GRANTED   = 2004;    //database event type
    ICQEVENTTYPE_AUTH_DENIED    = 2005;    //database event type
    ICQEVENTTYPE_SELF_REMOVE    = 2007;    //database event type
    ICQEVENTTYPE_FUTURE_AUTH    = 2008;    //database event type
    ICQEVENTTYPE_CLIENT_CHANGE  = 2009;    //database event type
    ICQEVENTTYPE_CHECK_STATUS   = 2010;    //database event type
    ICQEVENTTYPE_IGNORECHECK_STATUS = 2011;//database event type

    //broadcast from server
    //ASCIIZ    text
    //ASCIIZ    from name
    //ASCIIZ    from e-mail
    ICQEVENTTYPE_BROADCAST      = 2006;    //database event type


{$ifndef m_protosvc}
    {$include m_protosvc.inc}
{$endif}

type

    PICQSEARCHRESULT = ^TICQSEARCHRESULT;
    TICQSEARCHRESULT = record
        hdr: TPROTOSEARCHRESULT;
        uin: DWORD;
        auth: Byte;
    end;

    PICQDETAILSSEARCH = ^TICQDETAILSSEARCH;
    TICQDETAILSSEARCH = record
        nick: PAnsiChar;
        firstName: PAnsiChar;
        lastNamee: PAnsiChar;
    end;

const

    {
        wParam : 0
        lParam : null terminated string containing e-mail to search
        affects: Start a search for all ICQ users by e-mail -- see notes
        returns: Returnss a handle to the search on success, NULL(0) on failure
        notes  : uses the same scheme as PSS_BASICSEARCH,
                 *DEPRECATED* in favour of PS_SEARCHBYEMAIL
    }
    MS_ICQ_SEARCHBYEMAIL        = 'ICQ/SearchByEmail';

    {
        wParam : 0
        lParam : POinter to a TICQDETAILSSEARCH structure
        Affect : Start a search of all ICQ users by details, see notes
        Returns: A handle to the search on success, NULL(0) on failure
        Notes  : Results are returned in the same scheme as in PSS_BASICSEARCH,
                 Not recommended, use PS_SEARCHBYNAME
    }
    MS_ICQ_SEARCHBYDETAILS      = 'ICQ/SearchByDetails';

    {
        wParam : Pointer to a null terminated string containing phone number
        lParam : Pointer to a null terminated string containing the message
        Affect : Send an SMS via the ICQ network, See notes
        Returns: Handle to the send on success, NULL(0) on failure
        Notes  : the phone number should be the full number with internation code
                 and prefixed by + e.g. +44<numba>
    }
    MS_ICQ_SENDSMS              = 'ICQ/SendSMS';

    {
        wParam : level
        lParam : null terminated string containing logging message
        Affect : a logging message was sent from ICQLib
    }
    ME_ICQ_LOG                  = 'ICQ/Log';

{$ENDIF}

    {$ifdef __}
//Changing user info:
//See documentation of PS_CHANGEINFO
//The changing user info stuff built into the protocol is purposely extremely
//thin, to the extent that your data is passed as-is to the server without
//verification. Don't mess up.
//Everything is byte-aligned
//WORD:  2 bytes, little-endian (that's x86 order)
//DWORD: 4 bytes, little-endian
//LNTS:  a WORD containing the length of the string, followed by the string
//       itself. No zero terminator.
#define ICQCHANGEINFO_MAIN     0xEA03
/* pInfoData points to:
    WORD    datalen
    LNTS    nick
    LNTS    first
    LNTS    last
    LNTS    email
    LNTS    city
    LNTS    state
    LNTS    phone
    LNTS    fax
    LNTS    street
    LNTS    cellular (if SMS-able string contains an ending ' SMS')
    LNTS    zip
    WORD    country
    BYTE    gmt
    BYTE    unknown, usually 0
*/
#define ICQCHANGEINFO_MORE     0xFD03
/* pInfoData points to:
    WORD    datalen
    BYTE    age
    BYTE    0
    BYTE    sex
    LNTS    homepage
    WORD    birth-year
    BYTE    birth-month
    BYTE    birth-day
    BYTE    lang1
    BYTE    lang2
    BYTE    lang3
*/
#define ICQCHANGEINFO_ABOUT	   0x0604
/* pInfoData points to:
    WORD    datalen
	LNTS    about
*/
#define ICQCHANGEINFO_WORK	   0xF303
/* pInfoData points to:
    WORD    datalen
    LNTS    city
    LNTS    state
    DWORD   0
    LNTS    street
    LNTS    zip
    WORD    country
    LNTS    company-name
    LNTS    company-dept
    LNTS    company-position
    WORD    0
    LNTS    company-web
*/
#define ICQCHANGEINFO_PASSWORD 0x2E04
/* pInfoData points to:
    WORD    datalen
	LNTS    newpassword
*/
    {$endif}

