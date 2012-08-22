unit NTNative;
 
interface
 
uses
  Windows;
 
const
   STATUS_SUCCESS = 0;
 
type
  NTSTATUS = Longint;
  PVOID = Pointer;
  KSPIN_LOCK = ULONG;
  KAFFINITY = ULONG;
  KPRIORITY = Integer;
 
  _UNICODE_STRING = record
    Length: WORD;
    MaximumLength: WORD;
    Buffer:PWideChar;
  end;
  UNICODE_STRING = _UNICODE_STRING;
  PUNICODE_STRING = ^_UNICODE_STRING;
 
  _CURDIR = record
    DosPath: UNICODE_STRING;
    Handle: THandle;
  end;
  CURDIR = _CURDIR;
  PCURDIR = ^_CURDIR;
 
  PLIST_ENTRY = ^_LIST_ENTRY;
  _LIST_ENTRY = record
    Flink: PLIST_ENTRY;
    Blink: PLIST_ENTRY;
  end;
  LIST_ENTRY = _LIST_ENTRY;
  RESTRICTED_POINTER = ^_LIST_ENTRY;
  PRLIST_ENTRY = ^_LIST_ENTRY;
 
  _PEB_LDR_DATA = record
    Length: ULONG;
    Initialized: BOOLEAN;
    SsHandle: PVOID;
    InLoadOrderModuleList: LIST_ENTRY;
    InMemoryOrderModuleList: LIST_ENTRY;
    InInitializationOrderModuleList: LIST_ENTRY;
  end;
  PEB_LDR_DATA = _PEB_LDR_DATA;
  PPEB_LDR_DATA = ^_PEB_LDR_DATA;
 
  _RTL_DRIVE_LETTER_CURDIR = record
    Flags: WORD;
    Length: WORD;
    TimeStamp: DWORD;
    DosPath: UNICODE_STRING;
  end;
  RTL_DRIVE_LETTER_CURDIR = _RTL_DRIVE_LETTER_CURDIR;
  PRTL_DRIVE_LETTER_CURDIR = ^_RTL_DRIVE_LETTER_CURDIR;
 
  _PROCESS_PARAMETERS = record
    MaximumLength: ULONG;
    Length: ULONG;
    Flags: ULONG;
    DebugFlags: ULONG;
    ConsoleHandle: THANDLE;
    ConsoleFlags: ULONG;
    StandardInput: THANDLE;
    StandardOutput: THANDLE;
    StandardError: THANDLE;
    CurrentDirectory: CURDIR;
    DllPath: UNICODE_STRING;
    ImagePathName: UNICODE_STRING;
    CommandLine: UNICODE_STRING;
    Environment: PWideChar;
    StartingX: ULONG;
    StartingY: ULONG;
    CountX: ULONG;
    CountY: ULONG;
    CountCharsX: ULONG;
    CountCharsY: ULONG;
    FillAttribute: ULONG;
    WindowFlags: ULONG;
    ShowWindowFlags: ULONG;
    WindowTitle: UNICODE_STRING;
    Desktop: UNICODE_STRING;
    ShellInfo: UNICODE_STRING;
    RuntimeInfo: UNICODE_STRING;
    CurrentDirectores: array[0..31] of RTL_DRIVE_LETTER_CURDIR;
  end;
  PROCESS_PARAMETERS = _PROCESS_PARAMETERS;
  PPROCESS_PARAMETERS = ^_PROCESS_PARAMETERS;
  PPPROCESS_PARAMETERS = ^PPROCESS_PARAMETERS;
 
  PPEBLOCKROUTINE = procedure; stdcall;
 
  PPEB_FREE_BLOCK = ^_PEB_FREE_BLOCK;
  _PEB_FREE_BLOCK = record
    Next: PPEB_FREE_BLOCK;
    Size: ULONG;
  end;
  PEB_FREE_BLOCK = _PEB_FREE_BLOCK;
 
  _RTL_BITMAP = record
    SizeOfBitMap: DWORD;
    Buffer: PDWORD;
  end;
  RTL_BITMAP = _RTL_BITMAP;
  PRTL_BITMAP = ^_RTL_BITMAP;
  PPRTL_BITMAP = ^PRTL_BITMAP;
 
  _SYSTEM_STRINGS = record
    SystemRoot: UNICODE_STRING;
    System32Root: UNICODE_STRING;
    BaseNamedObjects: UNICODE_STRING;
  end;
  SYSTEM_STRINGS = _SYSTEM_STRINGS;
  PSYSTEM_STRINGS = ^_SYSTEM_STRINGS;
 
  _TEXT_INFO = record
    Reserved: PVOID;
    SystemStrings: PSYSTEM_STRINGS;
  end;
  TEXT_INFO = _TEXT_INFO;
  PTEXT_INFO = ^_TEXT_INFO;
 
  _PEB = record
    InheritedAddressSpace: UCHAR;
    ReadImageFileExecOptions: UCHAR;
    BeingDebugged: UCHAR;
    SpareBool: BYTE;
    Mutant: PVOID;
    ImageBaseAddress: PVOID;
    Ldr: PPEB_LDR_DATA;
    ProcessParameters: PPROCESS_PARAMETERS;
    SubSystemData: PVOID;
    ProcessHeap: PVOID;
    FastPebLock: KSPIN_LOCK;
    FastPebLockRoutine: PPEBLOCKROUTINE;
    FastPebUnlockRoutine: PPEBLOCKROUTINE;
    EnvironmentUpdateCount: ULONG;
    KernelCallbackTable: PPOINTER;
    EventLogSection: PVOID;
    EventLog: PVOID;
    FreeList: PPEB_FREE_BLOCK;
    TlsExpansionCounter: ULONG;
    TlsBitmap: PRTL_BITMAP;
    TlsBitmapData: array[0..1] of ULONG;
    ReadOnlySharedMemoryBase: PVOID;
    ReadOnlySharedMemoryHeap: PVOID;
    ReadOnlyStaticServerData: PTEXT_INFO;
    InitAnsiCodePageData: PVOID;
    InitOemCodePageData: PVOID;
    InitUnicodeCaseTableData: PVOID;
    KeNumberProcessors: ULONG;
    NtGlobalFlag: ULONG;
    d6C: DWORD;
    MmCriticalSectionTimeout: Int64;
    MmHeapSegmentReserve: ULONG;
    MmHeapSegmentCommit: ULONG;
    MmHeapDeCommitTotalFreeThreshold: ULONG;
    MmHeapDeCommitFreeBlockThreshold: ULONG;
    NumberOfHeaps: ULONG;
    AvailableHeaps: ULONG;
    ProcessHeapsListBuffer: PHANDLE;
    GdiSharedHandleTable: PVOID;
    ProcessStarterHelper: PVOID;
    GdiDCAttributeList: PVOID;
    LoaderLock: KSPIN_LOCK;
    NtMajorVersion: ULONG;
    NtMinorVersion: ULONG;
    NtBuildNumber: USHORT;
    NtCSDVersion: USHORT;
    PlatformId: ULONG;
    Subsystem: ULONG;
    MajorSubsystemVersion: ULONG;
    MinorSubsystemVersion: ULONG;
    AffinityMask: KAFFINITY;
    GdiHandleBuffer: array[0..33] of ULONG;
    PostProcessInitRoutine: ULONG;
    TlsExpansionBitmap: ULONG;
    TlsExpansionBitmapBits: array[0..127] of UCHAR;
    SessionId: ULONG;
    AppCompatFlags: Int64;
    CSDVersion: PWORD;
  end;
  PEB = _PEB;
  PPEB = ^_PEB;
 
  _PROCESS_BASIC_INFORMATION = record
    ExitStatus: NTSTATUS;
    PebBaseAddress: PPEB;
    AffinityMask: KAFFINITY;
    BasePriority: KPRIORITY;
    UniqueProcessId: ULONG;
    InheritedFromUniqueProcessId: ULONG;
  end;
  PROCESS_BASIC_INFORMATION = _PROCESS_BASIC_INFORMATION;
  PPROCESS_BASIC_INFORMATION = ^_PROCESS_BASIC_INFORMATION;
  TProcessBasicInformation = PROCESS_BASIC_INFORMATION;
  PProcessBasicInformation = ^PROCESS_BASIC_INFORMATION;
 
  PROCESSINFOCLASS = (
    ProcessBasicInformation,
    ProcessQuotaLimits,
    ProcessIoCounters,
    ProcessVmCounters,
    ProcessTimes,
    ProcessBasePriority,
    ProcessRaisePriority,
    ProcessDebugPort,
    ProcessExceptionPort,
    ProcessAccessToken,
    ProcessLdtInformation,
    ProcessLdtSize,
    ProcessDefaultHardErrorMode,
    ProcessIoPortHandlers,
    ProcessPooledUsageAndLimits,
    ProcessWorkingSetWatch,
    ProcessUserModeIOPL,
    ProcessEnableAlignmentFaultFixup,
    ProcessPriorityClass,
    ProcessWx86Information,
    ProcessHandleCount,
    ProcessAffinityMask,
    ProcessPriorityBoost,
    ProcessDeviceMap,
    ProcessSessionInformation,
    ProcessForegroundInformation,
    ProcessWow64Information,
    ProcessImageFileName,
    ProcessLUIDDeviceMapsEnabled,
    ProcessBreakOnTermination,
    ProcessDebugObjectHandle,
    ProcessDebugFlags,
    ProcessHandleTracing,
    ProcessIoPriority,
    ProcessExecuteFlags,
    ProcessResourceManagement,
    ProcessCookie,
    ProcessImageInformation,
    MaxProcessInfoClass
);
 
{$EXTERNALSYM NtQueryInformationProcess}
  function NtQueryInformationProcess(ProcessHandle: THANDLE; ProcessInformationClass: PROCESSINFOCLASS; ProcessInformation: pointer; ProcessInformationLength: ULONG; ReturnLength: PDWORD): DWORD; stdcall;
 
implementation
  function NtQueryInformationProcess; external 'NTDLL.DLL';
end.
