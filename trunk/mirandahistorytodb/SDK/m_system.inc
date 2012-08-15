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

{$IFNDEF M_SYSTEM}
{$DEFINE M_SYSTEM}

const
  MIRANDANAME  = 'Miranda IM';
  MIRANDACLASS = 'Miranda';

  // set the default compatibility lever for Miranda 0.4.x
  MIRANDA_VER  = $0600;

  {
    wParam : 0
    lParam : 0
    affect : called after all modules have been successfully initialised
             used to resolve double-dependencies in the module load order, see notes
    return : 0
    notes  : Can be used to call services, etc that have not yet loaded
             when your module has.
  }
  ME_SYSTEM_MODULESLOADED = 'Miranda/System/ModulesLoaded';

  {
    wParam : 0
    lParam : 0
    affect : called just before Miranda terminates,
             the database is still running during this hook
    return : 0
  }
  ME_SYSTEM_SHUTDOWN = 'Miranda/System/Shutdown';

  {
    wParam : 0
    lParam : 0
    affect : called before the app goes into shutdown routine
             to make sure everyone is happy to exit
    return : nonzero to stop the exit cycle
  }
  ME_SYSTEM_OKTOEXIT = 'Miranda/System/OkToExitEvent';

  {
    wParam : 0
    lParam : 0
    affect : check if everyone is happy to exit
    return : if everyone acknowleges OK to exit then returns true, otherwise false
  }
  MS_SYSTEM_OKTOEXIT = 'Miranda/System/OkToExit';

  {
    wParam : 0
    lParam : 0
    affect : gets the version number of Miranda encoded as a DWORD
    version: v0.1.0.1+
    return : the version number, encoded as one version per byte,
             therefore version 1.2.3.10 is 0x0102030a
  }
  MS_SYSTEM_GETVERSION = 'Miranda/System/GetVersion';

  {
    wParam : size in bytes of the buffer to be filled
    lParam : pointer to the buffer to be filled
    affect : gets the version of Miranda encoded as text
    return : 0 on success, nonzero on failure
    version: v0.1.0.1+
    notes  : may return a build qualifier, such as "0.1.0.1 alpha"
  }
  MS_SYSTEM_GETVERSIONTEXT = 'Miranda/System/GetVersionText';

  {
    wParam : hWaitObject, handle of a wait object to be used
    lParam : pszService, pointer to service name
    affect : causes the service name to be called from the main thread
             whenever the wait object is signalled with
             CallService(Service, wParam=hWaitObjeect, lParam=0)
             the Miranda message loop has a MsgWaitForMultipleObjects()
             call in it to implement this feature. See the documentation for
             that function for information on what objects are supported.
    return : 0 on success, non zero on failure.
             there is a limit of MAXIMUM_WAIT_OBJECTS minus one (MWO is defined
             in winnt.h to be 64) on the number of handles MSFMO() can process.
             this service will return nonzero if that many handles are already
             being waited on.
    version: implemented after v0.1.2.0+
    update during 0.1.2.0 development, 16/10/01:
      NotifyEventHooks() now translates all calls into the context of the main
      thread, which means that all of m_database.h is now completely safe.
    update during 0.1.2.2 development, 17/4/02:
      the main thread's message loop now also deals with asynchronous procedure
      calls. Loop up QueueUserAPC() for a neater way to accomplish a lot of the
      things that used to require ms_system_waitonhandle.
  }
  MS_SYSTEM_WAITONHANDLE = 'Miranda/System/WaitOnHandle';

  {
    wParam : hWaitObject to be removed
    lParam : 0
    affect : removes the wait object from the list, see above.
    returns: 0 on success, nonzero on failure
    version: v0.1.2.0+
  }
  MS_SYSTEM_REMOVEWAIT = 'Miranda/System/RemoveWait';

type
  PMM_INTERFACE = ^TMM_INTERFACE;
  TMM_INTERFACE = record
    cbSize: Integer;
    _malloc: function(cbSize: Integer): Pointer; cdecl;
    _realloc: function (pb: Pointer; cbSize: Integer): Pointer; cdecl;
    _free: procedure(pb: Pointer); cdecl;
    {$IF MIRANDA_VER >= $0600}
    _calloc: function(cbSize: Integer): Pointer; cdecl;
    _strdup: function(const src: PAnsiChar): PAnsiChar; cdecl;
    _wstrdup: function(const src: PWideChar): PWideChar; cdecl;
    {$IFEND}
  end;

const
  {
    wParam : 0
    lParam : pointer to an initialised TMM_INTERFACE
    affect : get function pointers to, malloc(), free() and realloc() used by Miranda
    note   : this should only be used carefully, make sure .cbSize is initialised with sizeof(TMM_INTERFACE)
    version: 0.1.2.2+
  }
  MS_SYSTEM_GET_MMI = 'Miranda/System/GetMMI';

type
  TFSortedFunc = function(p1,p2: Pointer): Integer; cdecl;

  PSortedList = ^TSortedList;
  TSortedList = record
    items: PPointer;
    realCount: Integer;
    limit: Integer;
    increment: Integer;
    sortFunc: TFSortedFunc
  end;

  PLIST_INTERFACE = ^TLIST_INTERFACE;
  TLIST_INTERFACE = record
    cbSize: Integer;
    _Create: function(i1,i2: Integer): PSortedList; cdecl;
    _Destroy: procedure(list: PSortedList); cdecl;
    _Find: function(list: PSortedList; p: Pointer): Pointer; cdecl;
    _GetIndex: function(list: PSortedList; p: Pointer; i: PInteger): Integer; cdecl;
    _Insert: function(list: PSortedList; p: Pointer; i: Integer): Integer; cdecl;
    _Remove: function(list: PSortedList; i: Integer): Integer; cdecl;
    _IndexOf: function(list: PSortedList; p: Pointer): Integer; cdecl;
    {$IF MIRANDA_VER >= $0600}
    _InsertPtr: function(list: PSortedList; p: PPointer): Integer; cdecl;
    _RemovePtr: function(list: PSortedList; p: PPointer): Integer; cdecl;
    {$IFEND}
  end;

const
  LIST_INTERFACE_V1_SIZE = SizeOf(Integer)+7*SizeOf(Pointer);
  LIST_INTERFACE_V2_SIZE = SizeOf(Integer)+9*SizeOf(Pointer);

  {
    wParam : 0
    lParam : pointer to an initialised LIST_INTERFACE
    affect : if the sortFunc member of the list gets assigned, the list becomes sorted
    return : returns the pointer to the simple lists manager.
  }
  MS_SYSTEM_GET_LI = 'Miranda/System/GetLI';

(*
  UTF8 Manager interface. 0.5.2+
  Contains functions for utf8-strings encoding & decoding
*)

type
  PUTF8_INTERFACE = ^TUTF8_INTERFACE;
  TUTF8_INTERFACE = record
    cbSize: Integer;
    // decodes utf8 and places the result back into the same buffer.
    // if the second parameter is present, the additional wchar_t* string gets allocated,
    // and filled with the decoded utf8 content without any information loss.
    // this string should be freed using mir_free()
    utf8_decode: function(str: PAnsiChar; var ucs2: PWideChar): PAnsiChar; cdecl;
    utf8_decodecp: function(str: PAnsiChar; codepage: integer; var ucs2: PWideChar): PAnsiChar; cdecl;
    // encodes an ANSI string into a utf8 format using the current langpack code page,
    // or CP_ACP, if lanpack is missing
    // the resulting string should be freed using mir_free
    utf8_encode: function(const src: PAnsiChar): PAnsiChar; cdecl;
    utf8_encodecp: function(const src: PAnsiChar; codepage: integer): PAnsiChar; cdecl;
    // encodes an WCHAR string into a utf8 format
    // the resulting string should be freed using mir_free
    utf8_encodeW: function(const src: PWideChar): PAnsiChar; cdecl;
  end;

const
  {
    wParam : 0
    lParam : pointer to an initialised LIST_INTERFACE
    return : returns the pointer to the UTF8 manager.
    verison: 0.5.2+
  }
  MS_SYSTEM_GET_UTFI = 'Miranda/System/GetUTFI';

(*

  -- Thread Safety --

  Proper thread safe shutdown was implemented in 0.3.0.0 (2003/04/18)
  and not  before, therefore it is improper that any MT plugins be used
  with earlier versions of Miranda (as hav0c will result)

  Note: This does not apply to MT plugins which included their own
  thread-safe shutdown routines.

  Shutdown thread safety works thusly:

  All new threads must call MS_SYSTEM_THREAD_PUSH and MS_SYSTEM_THREAD_POP
  when they return.

  Due to the nature of thread creation, it is illegal to assume
  just a call pair of MS_SYSTEM_THREAD_PUSH inside the thread will
  be enough -- the source thread may only return when the new child
  thread has actually executed MS_SYSTEM_THREAD_PUSH

  This is because a thread maybe in an undefined state at the point
  when the thread creation routine returns, thus Miranda may exit
  thinking it is safe to do so, because MS_SYSTEM_THREAD_PUSH was not
  called in time.

  See miranda.c for how this can be done using an event object
  which is signalled just after the MS_SYSTEM_THREAD_PUSH call is executed
  and so the source thread knows that the created thread is known to Miranda.

  -- What happens when Miranda exits --

  Miranda will firstly set an event object to signalled, this will
  make MS_SYSTEM_TERMINATED return TRUE, it will then fire ME_SYSTEM_PRESHUTDOWN
  at this point, no plugins or modules are unloaded.

  Miranda will then enumerate all active threads and queue an APC call
  to each thread, so any thread in an alertable state will become active,
  this functionailty may not be required by your threads: but if you use
  the Winsock2 event object system or Sleep() please use the alertable
  wait functions, so that the thread will 'wake up' when Miranda queues
  a message to it, SleepEx() will return WAIT_IO_COMPLETION if this happens.

  After all threads have been signalled, Miranda will spin on the unwind thread stack waiting
  for it to become empty, in this time, it will carry on processing thread
  switches, clearing it's own APC calls (used by NotifyEventHooks(), CallServiceSync())

  So a thread should be written in this kind of form:

  void mythread(void *arg)
  {
    // assume all thread pushing/popping is done by forkthread()
    int run=1;
    for (;run;)
    {
      Beep(4391,500);
      SleepEx(1500,TRUE);
      if (Miranda_Terminated()) {
        Beep(5000,150); run=0;
      } //if
    } //for
  }

  The above will make a nice Beep every 1.5 seconds and when the UI
  quits, it will make a lower beep and then return.

  As many copies of this thread maybe running, the creator does not need
  to worry about what to do with previous threads, as long as they're on the
  unwind stack.If there are any global resources (and they're mutex) you can free() them
  at Unload(), which will only be called, after all threads have returned.

  -- Summary --

  MS_SYSTEM_TERMINATED (will start returning TRUE)
  ME_SYSTEM_PRESHUTDOWN will be fired (The CList won't be visible at this point)

  All PROTOTYPE_PROTOCOL registered plugins will be sent ID_STATUS_OFFLINE
  automatically.

  All the threads will be notified via QueueUserAPC() and then Miranda
  will poll on the unwind thread queue until it is empty.

  ME_SYSTEM_SHUTDOWN will be fired, the database will be unloaded, the core
  will be unloaded -- Miranda will return.

*)

type
  Tm_ThreadFunc = procedure(arg: Pointer); cdecl;
  Tm_ThreadFuncEx = function(arg: Pointer): DWORD; stdcall;

  PFORK_THREADEX_PARAMS = ^TFORK_THREADEX_PARAMS;
  TFORK_THREADEX_PARAMS = record
    pFunc: Tm_ThreadFuncEx;
    iStackSize: Integer;
    arg: Pointer;
    threadID: DWORD;
  end;

const
  {
    wParam : Tm_ThreadFunc function address
    lParam : function parameter
    affect : registers a thread in the core and forks it
    verison: 0.5.2+
  }
  MS_SYSTEM_FORK_THREAD = 'Miranda/Thread/Fork';

  {
    wParam : 0
    lParam : pointer to FORK_THREADEX_PARAMS
    affect : registers a thread in the core and forks it
    return : passes the extended parameters info and returns the thread id
    verison: 0.5.2+
  }
  MS_SYSTEM_FORK_THREAD_EX = 'Miranda/Thread/ForkEx';

  {
    wParam=0
    lParam=0

    Add a thread to the unwind wait stack that Miranda will poll on
    when it is tearing down modules.

    This must be called in the context of the thread that is to be pushed
    i.e. there are no args, it works out what thread is being called
    and gets itself a handle to the calling thread.
  }
  MS_SYSTEM_THREAD_PUSH  = 'Miranda/Thread/Push';

  {
    wParam=0
    lParam=0

    Remove a thread from the unwind wait stack -- it is expected
    that the call be made in the context of the thread to be removed.

    Miranda will begin to tear down modules and plugins if/when the
    last thread from the unwind stack is removed.
  }
  MS_SYSTEM_THREAD_POP = 'Miranda/Thread/Pop';

  {
    wParam=0
    lParam=0

    This hook is fired just before the thread unwind stack is used,
    it allows MT plugins to shutdown threads if they have any special
    processing to do, etc.
  }
  ME_SYSTEM_PRESHUTDOWN  = 'Miranda/System/PShutdown';

  {
    wParam=0
    lParam=0

    Returns TRUE when Miranda has got WM_QUIT and is in the process
    of shutting down
  }
  MS_SYSTEM_TERMINATED = 'Miranda/SysTerm';

  {
    wParam : 0
    lParam : (address) void (__cdecl *callback) (void)
    Affect : Setup a function pointer to be called after main loop iterations, it allows for
             idle processing, See notes
    Returns: 1 on success, 0 on failure
    Notes  : This service will only allow one function to be registered, if one is registered, 0 will be returned
             Remember that this uses __cdecl.
    Version: Added during 0.3.4+
  }
  MS_SYSTEM_SETIDLECALLBACK = 'Miranda/SetIdleCallback';

  {
    wParam : 0
    lParam : &tick
    Affect : return the last window tick where a monitored event was seen, currently WM_CHAR/WM_MOUSEMOVE
    Returns: Always returns 0
    Version: Added during 0.3.4+ (2004/09/12)
  }
  MS_SYSTEM_GETIDLE = 'Miranda/GetIdle';

  {
    wParam: cchMax (max length of buffer)
    lParam: pointer to buffer to fill
    Affect: Returns the build timestamp of the core, as a string of YYYYMMDDhhmmss, this service might
      not exist and therefore the build is before 2004-09-30
    Returns: zero on success, non zero on failure
    Version: 0.3.4a+ (2004/09/30)
    DEFUNCT: This service was removed on 0.3.4.3+ (2004/11/19) use APILEVEL
  }
  MS_SYSTEM_GETBUILDSTRING = 'Miranda/GetBuildString';

type
  PMISSING_SERVICE_PARAMS = ^TMISSING_SERVICE_PARAMS;
  TMISSING_SERVICE_PARAMS = record
    name: PAnsiChar;
    wParam: WPARAM;
    lParam: LPARAM;
  end;

const
  {
    wParam : 0
    lParam : pointer to TMissingServiceParams
    Affect : Missing service catcher. Is being called when one calls
             the non-existent service.
    Returns: Always returns 0
    Version: 0.4.3+ addition (2006/03/27)
  }

  ME_SYSTEM_MISSINGSERVICE = 'System/MissingService';

{$ENDIF}
