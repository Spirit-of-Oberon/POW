(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION Win32;                               (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1995-98, Robinson Associates                                 *)
(*                        Red Lion House                                      *)
(*                        St Mary's Street                                    *)
(*                        PAINSWICK                                           *)
(*                        Glos                                                *)
(*                        GL6  6QR                                            *)
(*                        Tel:    (+44) (0)452 813 699                        *)
(*                        Fax:    (+44) (0)452 812 912                        *)
(*                        e-Mail: oberon@robinsons.co.uk                      *)
(******************************************************************************)
(* AUTHORS: Bernhard Leisch                                                   *)
(******************************************************************************)
(* PURPOSE:  Interface of Windows API                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*   This module defines only a subset of the Windows API. It has been        *)
(*   created solely for use by the compiler implementation.                   *)
(******************************************************************************)



CONST

  NULL = 0;
  
  STD_INPUT_HANDLE  = -10; (* Standard input handle  *)
  STD_OUTPUT_HANDLE = -11; (* Standard output handle *) 
  STD_ERROR_HANDLE  = -12; (* Standard error handle  *)
  
  (* -- Global Memory Flags -- *)
  GMEM_FIXED          = 00000H;
  GMEM_MOVEABLE       = 00002H;
  GMEM_NOCOMPACT      = 00010H;
  GMEM_NODISCARD      = 00020H;
  GMEM_ZEROINIT       = 00040H;
  GMEM_MODIFY         = 00080H;
  GMEM_DISCARDABLE    = 00100H;
  GMEM_NOT_BANKED     = 01000H;
  GMEM_SHARE          = 02000H;
  GMEM_DDESHARE       = 02000H;
  GMEM_NOTIFY         = 04000H;
  GMEM_LOWER          = GMEM_NOT_BANKED;
  GMEM_VALID_FLAGS    = 07F72H;
  GMEM_INVALID_HANDLE = 08000H;
  GHND                = (GMEM_MOVEABLE + GMEM_ZEROINIT);
  GPTR                = (GMEM_FIXED + GMEM_ZEROINIT);

  MB_OK = 0H;
  MB_OKCANCEL = 1H;
  MB_ABORTRETRYIGNORE = 2H;
  MB_YESNOCANCEL = 3H;
  MB_YESNO = 4H;
  MB_RETRYCANCEL = 5H;
  MB_ICONHAND = 10H;
  MB_ICONSTOP = MB_ICONHAND;
  MB_ICONERROR = MB_ICONHAND;
  MB_ICONQUESTION = 20H;
  MB_ICONEXCLAMATION = 30H;
  MB_ICONWARNING = MB_ICONEXCLAMATION;
  MB_ICONASTERISK = 40H;
  MB_ICONINFORMATION = MB_ICONASTERISK;
  MB_DEFBUTTON1 = 0H;
  MB_DEFBUTTON2 = 100H;
  MB_DEFBUTTON3 = 200H;
  MB_DEFBUTTON4 = 300H;
  MB_APPLMODAL = 0H;
  MB_SYSTEMMODAL = 1000H;
  MB_TASKMODAL = 2000H;
  MB_HELP = 4000H;                     (*  Help Button *)
  MB_RIGHT = 80000H;
  MB_RTLREADING = 100000H;
  MB_NOFOCUS = 8000H;
  MB_SETFOREGROUND = 10000H;
  MB_DEFAULT_DESKTOP_ONLY = 20000H;
  MB_TYPEMASK = 0FH;
  MB_USERICON = 80H;
  MB_ICONMASK = 0F0H;
  MB_DEFMASK = 0F00H;
  MB_MODEMASK = 3000H;
  MB_MISCMASK = 0C000H;

  IDOK = 1;
  IDCANCEL = 2;
  IDABORT = 3;
  IDRETRY = 4;
  IDIGNORE = 5;
  IDYES = 6;
  IDNO = 7;
  IDCLOSE = 8;
  IDHELP = 9;

  DLL_PROCESS_ATTACH = 1;
  DLL_THREAD_ATTACH = 2;
  DLL_THREAD_DETACH = 3;
  DLL_PROCESS_DETACH = 0;
  
  INVALID_HANDLE_VALUE = -1;
  INVALID_FILE_SIZE = -1;
  FILE_BEGIN = 0;
  FILE_CURRENT = 1;
  FILE_END = 2;
  HFILE_ERROR=-1;
  OF_READ = 0H;
  OF_WRITE = 1H;
  OF_READWRITE = 2H;
  OF_SHARE_COMPAT = 0H;
  OF_SHARE_EXCLUSIVE = 10H;
  OF_SHARE_DENY_WRITE = 20H;
  OF_SHARE_DENY_READ = 30H;
  OF_SHARE_DENY_NONE = 40H;
  OF_PARSE = 100H;
  OF_DELETE = 200H;
  OF_VERIFY = 400H;
  OF_CANCEL = 800H;
  OF_CREATE = 1000H;
  OF_PROMPT = 2000H;
  OF_EXIST = 4000H;
  OF_REOPEN = 8000H;
  OFS_MAXPATHNAME = 128;
  
  GW_HWNDFIRST = 0;
  GW_HWNDLAST = 1;
  GW_HWNDNEXT = 2;
  GW_HWNDPREV = 3;
  GW_OWNER = 4;
  GW_CHILD = 5;
  GW_MAX = 5;

(*  *)
(*  Define access rights to files and directories *)
(*  *)
(*  *)
(*  The FILE_READ_DATA and FILE_WRITE_DATA constants are also defined in *)
(*  devioctl.h as FILE_READ_ACCESS and FILE_WRITE_ACCESS. The values for these *)
(*  constants *MUST* always be in sync. *)
(*  The values are redefined in devioctl.h because they must be available to *)
(*  both DOS and NT. *)
(*  *)
  FILE_READ_DATA = 1H;                 (*  file & pipe *)
  FILE_LIST_DIRECTORY = 1H;            (*  directory *)
  FILE_WRITE_DATA = 2H;                (*  file & pipe *)
  FILE_ADD_FILE = 2H;                  (*  directory *)
  FILE_APPEND_DATA = 4H;               (*  file *)
  FILE_ADD_SUBDIRECTORY = 4H;          (*  directory *)
  FILE_CREATE_PIPE_INSTANCE = 4H;      (*  named pipe *)
  FILE_READ_EA = 8H;                   (*  file & directory *)
  FILE_WRITE_EA = 10H;                 (*  file & directory *)
  FILE_EXECUTE = 20H;                  (*  file *)
  FILE_TRAVERSE = 20H;                 (*  directory *)
  FILE_DELETE_CHILD = 40H;             (*  directory *)
  FILE_READ_ATTRIBUTES = 80H;          (*  all *)
  FILE_WRITE_ATTRIBUTES = 100H;        (*  all *)
  FILE_SHARE_READ = 1H;
  FILE_SHARE_WRITE = 2H;
  FILE_SHARE_DELETE = 4H;
  FILE_ATTRIBUTE_READONLY = 1H;
  FILE_ATTRIBUTE_HIDDEN = 2H;
  FILE_ATTRIBUTE_SYSTEM = 4H;
  FILE_ATTRIBUTE_DIRECTORY = 10H;
  FILE_ATTRIBUTE_ARCHIVE = 20H;
  FILE_ATTRIBUTE_NORMAL = 80H;
  FILE_ATTRIBUTE_TEMPORARY = 100H;
  FILE_ATTRIBUTE_COMPRESSED = 800H;
  FILE_ATTRIBUTE_OFFLINE = 1000H;
  FILE_NOTIFY_CHANGE_FILE_NAME = 1H;
  FILE_NOTIFY_CHANGE_DIR_NAME = 2H;
  FILE_NOTIFY_CHANGE_ATTRIBUTES = 4H;
  FILE_NOTIFY_CHANGE_SIZE = 8H;
  FILE_NOTIFY_CHANGE_LAST_WRITE = 10H;
  FILE_NOTIFY_CHANGE_LAST_ACCESS = 20H;
  FILE_NOTIFY_CHANGE_CREATION = 40H;
  FILE_NOTIFY_CHANGE_SECURITY = 100H;
  FILE_ACTION_ADDED = 1H;
  FILE_ACTION_REMOVED = 2H;
  FILE_ACTION_MODIFIED = 3H;
  FILE_ACTION_RENAMED_OLD_NAME = 4H;
  FILE_ACTION_RENAMED_NEW_NAME = 5H;
  MAILSLOT_NO_MESSAGE = -1;
  MAILSLOT_WAIT_FOREVER = -1;
  FILE_CASE_SENSITIVE_SEARCH = 1H;
  FILE_CASE_PRESERVED_NAMES = 2H;
  FILE_UNICODE_ON_DISK = 4H;
  FILE_PERSISTENT_ACLS = 8H;
  FILE_FILE_COMPRESSION = 10H;
  FILE_VOLUME_IS_COMPRESSED = 8000H;
(*  *)
(*  File creation flags must start at the high end since they *)
(*  are combined with the attributes *)
(*  *)
  FILE_FLAG_WRITE_THROUGH = MIN(LONGINT);
  FILE_FLAG_OVERLAPPED = 40000000H;
  FILE_FLAG_NO_BUFFERING = 20000000H;
  FILE_FLAG_RANDOM_ACCESS = 10000000H;
  FILE_FLAG_SEQUENTIAL_SCAN = 8000000H;
  FILE_FLAG_DELETE_ON_CLOSE = 4000000H;
  FILE_FLAG_BACKUP_SEMANTICS = 2000000H;
  FILE_FLAG_POSIX_SEMANTICS = 1000000H;
  CREATE_NEW = 1;
  CREATE_ALWAYS = 2;
  OPEN_EXISTING = 3;
  OPEN_ALWAYS = 4;
  TRUNCATE_EXISTING = 5;

(*  *)
(*   These are the generic rights. *)
(*  *)
  GENERIC_READ = MIN(LONGINT);
  GENERIC_WRITE = 40000000H;
  GENERIC_EXECUTE = 20000000H;
  GENERIC_ALL = 10000000H;


TYPE 
  ULONG= LONGINT;
  PULONG= LONGINT;
  USHORT= INTEGER;
  PUSHORT= LONGINT;
  UCHAR= CHAR;
  PUCHAR= LONGINT;
  PSZ= LONGINT;   (* pointer to char *)
  DWORD= LONGINT;
  BOOL= LONGINT;
  BYTE= CHAR;
  WORD= INTEGER;
  PFLOAT= LONGINT;  (* pointer to real*)
  PBOOL= LONGINT;  (*pointer to bool*)
  LPBOOL= PBOOL;
  PBYTE= LONGINT;
  LPBYTE= LONGINT;
  PINT= LONGINT;
  LPINT= LONGINT;
  PWORD= LONGINT;
  LPWORD= LONGINT;
  LPLONG= LONGINT;
  PDWORD= LONGINT;
  LPDWORD= LONGINT;
  LPVOID= LONGINT; (*SYSTEM.ADDRESS;*)    (* ???? *)
  LPCVOID= LONGINT; (*SYSTEM.ADDRESS; *)
  UINT= LONGINT;
  PUINT= LONGINT;
  WCHAR = INTEGER;
  (*  added for oberon   *)
  LP = LONGINT;
  PSTR = LONGINT;
  LPSTR = LONGINT;
  LPWSTR = LONGINT;
  LPCSTR = LONGINT;
  LPCTSTR=LONGINT;
  LPTSTR=LONGINT;
  LPCWSTR = LONGINT;
(* #ifndef NT_INCLUDED     *)
(* #include <winnt.h>      *)
(* #endif  NT_INCLUDED     *)
(*  Types use for passing & returning polymorphic values  *)

  WPARAM= LONGINT;
  LPARAM= LONGINT;
  LRESULT= LONGINT;

  HANDLE= LONGINT;
  HWND= LONGINT;
  HHOOK= LONGINT;
  ATOM= INTEGER;
  SPHANDLE= LONGINT;                   (*near  pointer *)
  LPHANDLE= LONGINT;                   (*far  pointer *)
  HGLOBAL= LONGINT;
  HLOCAL= LONGINT;
  GLOBALHANDLE= LONGINT;
  LOCALHANDLE= LONGINT;
  HMODULE=LONGINT;

  OFSTRUCT=RECORD [_NOTALIGNED] 
    cBytes:BYTE;
    fFixedDisk:BYTE;
    nErrCode:WORD;
    Reserved1:WORD;
    Reserved2:WORD;
    szPathName:ARRAY OFS_MAXPATHNAME OF CHAR;
  END;

  OVERLAPPED = RECORD [_NOTALIGNED]
    Internal    : DWORD;
    InternalHigh: DWORD;
    Offset      : DWORD;
    OffsetHigh  : DWORD;
    hEvent      : HANDLE;
  END;
  LPOVERLAPPED=POINTER TO OVERLAPPED;

  STARTUPINFOA=RECORD [_NOTALIGNED]
    cb:DWORD; (* Specifies the size, in bytes, of the structure. *)
    lpReserved:LPTSTR; (* Reserved. Set this member to NULL before passing the structure to CreateProcess. *)
    lpDesktop:LPTSTR; (* Windows NT only: Points to a zero-terminated string that specifies either the name 
                         of the desktop only or the name of both the window station and desktop 
                         for this process. A backslash in the string pointed to by lpDesktop indicates 
                         that the string includes both desktop and window station names. Otherwise, the 
                         lpDesktop string is interpreted as a desktop name. If lpDesktop is NULL, the new 
                         process inherits the window station and desktop of its parent process. *)
    lpTitle:LPTSTR; (* For console processes, this is the title displayed in the title bar 
                       if a new console window is created. If NULL, the name of the executable file 
                       is used as the window title instead. This parameter must be NULL for GUI or 
                       console processes that do not create a new console window. *)

    dwX:DWORD; (* Ignored unless dwFlags specifies STARTF_USEPOSITION. Specifies the x and y 
                  offsets, in pixels, of the upper left corner of a window if a new window is 
                  created. The offsets are from the upper left corner of the screen. For GUI 
                  processes, the specified position is used the first time the new process 
                  calls CreateWindow to create an overlapped window if the x parameter of 
                  CreateWindow is CW_USEDEFAULT. *)
    dwY:DWORD; 
    
    dwXSize:DWORD; (* Ignored unless dwFlags specifies STARTF_USESIZE. Specifies the width 
                      (dwXSize) and height (dwYSize), in pixels, of the window if a new 
                      window is created. For GUI processes, this is used only the first time 
                      the new process calls CreateWindow to create an overlapped window if 
                      the nWidth parameter of CreateWindow is CW_USEDEFAULT. *)
    dwYSize:DWORD; 
    
    dwXCountChars:DWORD; (* Ignored unless dwFlags specifies STARTF_USECOUNTCHARS. For 
                            console processes, if a new console window is created, 
                            dwXCountChars specifies the screen buffer width in character 
                            columns, and dwYCountChars specifies the screen buffer height 
                            in character rows. These values are ignored in GUI processes. *)
    dwYCountChars:DWORD; 
    
    dwFillAttribute:DWORD; (* Ignored unless dwFlags specifies STARTF_USEFILLATTRIBUTE. 
                              Specifies the initial text and background colors if a new 
                              console window is created in a console application. These values 
                              are ignored in GUI applications. This value can be any combination 
                              of the following values: FOREGROUND_BLUE, FOREGROUND_GREEN, 
                              FOREGROUND_RED, FOREGROUND_INTENSITY, BACKGROUND_BLUE, 
                              BACKGROUND_GREEN, BACKGROUND_RED, and BACKGROUND_INTENSITY. 
                              For example, the following combination of values produces red 
                              text on a whilte background:
                              FOREGROUND_RED | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE *)

    dwFlags:DWORD; 
    (* This is a bit field that determines whether certain STARTUPINFO members are used when the 
       process creates a window. Any combination of the following values can be specified: 
       
       Value                       Meaning
       STARTF_USESHOWWINDOW    If this value is not specified, the wShowWindow member is ignored.
       STARTF_USEPOSITION      If this value is not specified, the dwX and dwY members are ignored.
       STARTF_USESIZE          If this value is not specified, the dwXSize and dwYSize members are ignored.
       STARTF_USECOUNTCHARS    If this value is not specified, the dwXCountChars and dwYCountChars members are ignored.
       STARTF_USEFILLATTRIBUTE If this value is not specified, the dwFillAttribute member is ignored.
       STARTF_FORCEONFEEDBACK  If this value is specified, the cursor is in feedback mode for two 
                               seconds after CreateProcess is called. If during those two 
                               seconds the process makes the first GUI call, the system gives 
                               five more seconds to the process. If during those five seconds 
                               the process shows a window, the system gives five more seconds 
                               to the process to finish drawing the window.
                               The system turns the feedback cursor off after the first call 
                               to GetMessage, regardless of whether the process is drawing.
                               For more information on feedback, see the following Remarks section.
       STARTF_FORCEOFFFEEDBACK If specified, the feedback cursor is forced off while the process 
                               is starting. The normal cursor is displayed. For more information 
                               on feedback, see the following Remarks section.
       STARTF_USESTDHANDLES    If this value is specified, sets the standard input of the process, 
                               standard output, and standard error handles to the handles 
                               specified in the hStdInput, hStdOutput, and hStdError members of 
                               the STARTUPINFO structure. The CreateProcess function's fInheritHandles 
                               parameter must be set to TRUE for this to work properly.
                               If this value is not specified, the hStdInput, hStdOutput, 
                               and hStdError members of the STARTUPINFO structure are ignored. *)

    wShowWindow:WORD; (* Ignored unless dwFlags specifies STARTF_USESHOWWINDOW. The wshowWindow 
                         member can be any of the SW_ constants defined in WINUSER.H. For GUI 
                         processes, wShowWindow specifies the default value the first time 
                         ShowWindow is called. The nCmdShow parameter of ShowWindow is ignored. 
                         In subsequent calls to ShowWindow, the wShowWindow member is used if the 
                         nCmdShow parameter of ShowWindow is set to SW_SHOWDEFAULT.  *)
    cbReserved2:WORD;   (* Reserved; must be zero. *)
    lpReserved2:LPBYTE; (* Reserved; must be NULL. *)
    hStdInput:HANDLE;   (* Ignored unless dwFlags specifies STARTF_USESTDHANDLES. Specifies a 
                           handle that will be used as the standard input handle of the 
                           process if STARTF_USESTDHANDLES is specified. *)
    hStdOutput:HANDLE;  (* Ignored unless dwFlags specifies STARTF_USESTDHANDLES. Specifies a 
                           handle that will be used as the standard output handle of the 
                           process if STARTF_USESTDHANDLES is specified. *)
    hStdError:HANDLE;   (* Ignored unless dwFlags specifies STARTF_USESTDHANDLES. Specifies a 
                           handle that will be used as the standard error handle of the 
                           process if STARTF_USESTDHANDLES is specified. *)
  END;
  STARTUPINFO=STARTUPINFOA;

  MEMORYSTATUS  = RECORD
    dwLength:        DWORD;
    dwMemoryLoad:    DWORD;
    dwTotalPhys:     DWORD;
    dwAvailPhys:     DWORD;
    dwTotalPageFile: DWORD;
    dwAvailPageFile: DWORD;
    dwTotalVirtual:  DWORD;
    dwAvailVirtual:  DWORD;
  END;
  LPMEMORYSTATUS = POINTER TO MEMORYSTATUS;

  SECURITY_ATTRIBUTES = RECORD [_NOTALIGNED]
    nLength             : DWORD;
    lpSecurityDescriptor: LPVOID;
    bInheritHandle      : BOOL;
  END;
  PSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;
  LPSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;


PROCEDURE [_APICALL] MessageBoxA ( hWnd: HWND; lpText: LPCSTR;
                        lpCaption: LPCSTR;
                        uType: UINT ): LONGINT;


PROCEDURE [_APICALL] SetFilePointer(hFile:HANDLE; 
                                    lDistanceToMove:LONGINT; 
                                    lpdistanceToMoveHigh:LPVOID; 
                                    dwMoveMethod:DWORD):DWORD;

PROCEDURE [_APICALL] CloseHandle(hObject:HANDLE):BOOL;

PROCEDURE [_APICALL] CreateFileA ( lpFileName: LPCSTR;
                                   dwDesiredAccess: DWORD;
                                   dwShareMode: DWORD;
                                   VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES;
                                   dwCreationDisposition: DWORD;
                                   dwFlagsAndAttributes: DWORD;
                                   hTemplateFile: HANDLE ): HANDLE;

PROCEDURE [_APICALL] CreateFileW ( lpFileName: LPCWSTR;
                                   dwDesiredAccess: DWORD;
                                   dwShareMode: DWORD;
                                   VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES;
                                   dwCreationDisposition: DWORD;
                                   dwFlagsAndAttributes: DWORD;
                                   hTemplateFile: HANDLE ): HANDLE;

PROCEDURE [_APICALL] OpenFile(lpFileName:LPCSTR; 
                              VAR STATICTYPED ReOpenBuff:OFSTRUCT; 
                              uStyle:UINT):HANDLE;

PROCEDURE [_APICALL] DeleteFileA ( lpFileName: LPCSTR ): BOOL;

PROCEDURE [_APICALL] DeleteFileW ( lpFileName: LPCWSTR ): BOOL;

PROCEDURE [_APICALL] MoveFileA ( lpExistingFileName: LPCSTR;
                                 lpNewFileName: LPCSTR ): BOOL;

PROCEDURE [_APICALL] MoveFileW ( lpExistingFileName: LPCWSTR;
                                 lpNewFileName: LPCWSTR ): BOOL;

PROCEDURE [_APICALL] GetWindow(hWnd:HWND; 
                               uCmd:UINT):HWND;

PROCEDURE [_APICALL] GetTickCount():DWORD;

PROCEDURE [_APICALL] ReadFile(hFile:HANDLE; 
                              lpBuffer:LPVOID; 
                              nNumberOfBytesToRead:DWORD; 
                              VAR NumberOfBytesRead:DWORD; 
                              lpOverlapped:LPOVERLAPPED):BOOL;

PROCEDURE [_APICALL] WriteFile(hFile:HANDLE; 
                               lpBuffer:LPCVOID; 
                               nNumberOfBytesToWrite:DWORD; 
                               VAR NumberOfBytesWritten:DWORD; 
                               lpOverlapped:LPOVERLAPPED):BOOL;

(* The ExitProcess function ends a process and all its threads. *)
PROCEDURE [_APICALL] ExitProcess(uExitCode:UINT (* exit code for all threads *)
                                );
   
(* The GetModuleHandle function returns a module handle for the specified module if the 
   file has been mapped into the address space of the calling process. 
   <lpModuleName> points to a null-terminated string that names a Win32 module 
   (either a .DLL or .EXE file). If the filename extension is omitted, the default 
   library extension .DLL is appended. The filename string can include a trailing point 
   character (.) to indicate that the module name has no extension. The string does not have 
   to specify a path. The name is compared (case independently) to the names of modules 
   currently mapped into the address space of the calling process. 
   If this parameter is NULL, GetModuleHandle returns a handle of the file used to create 
   the calling process. *)
PROCEDURE [_APICALL] GetModuleHandle(lpModuleName:LPCTSTR (* address of module name to return handle for *)
                                    ):HMODULE;
 
(* The GetCommandLine function returns a pointer to the command-line string 
   for the current process. *)
PROCEDURE [_APICALL] GetCommandLine():LPTSTR;
 
(* The GetStartupInfo function retrieves the contents of the STARTUPINFO structure that was 
   specified when the calling process was created. *)
PROCEDURE [_APICALL] GetStartupInfo(VAR STATICTYPED lpStartupInfo:STARTUPINFOA);
      
(* The AllocConsole function allocates a new console for the calling process. 
   If the function succeeds, the return value is TRUE.
   If the function fails, the return value is FALSE. To get extended error information, 
   call GetLastError. *)
PROCEDURE [_APICALL] AllocConsole():BOOL;

(* The GetLastError function returns the calling thread's last-error code value. The last-error 
   code is maintained on a per-thread basis. Multiple threads do not overwrite each other's 
   last-error code. *)
PROCEDURE [_APICALL] GetLastError():DWORD;
 
(* The FreeConsole function detaches the calling process from its console. *)
PROCEDURE [_APICALL] FreeConsole():BOOL;
 
PROCEDURE [_APICALL] MessageBeep(x:UINT):BOOL;

PROCEDURE [_APICALL] WriteConsoleA(hConsoleOutput:HANDLE; (* handle to a console screen buffer *)
                                  lpBuffer:LONGINT; (* pointer to buffer to write from  *)
                                  nNumberOfCharsToWrite:DWORD; (* number of characters to write *)
                                  VAR lpNumberOfCharsWritten:DWORD; (* pointer to number of characters written *)
                                  lpReserved:LONGINT (* reserved; must be 0 *)
                                 ):BOOL;
                                 
PROCEDURE [_APICALL] GetStdHandle(nStdHandle:DWORD (* input, output, or error device *)
                                 ):HANDLE; 

PROCEDURE [_APICALL] GlobalAlloc  (uFlags: UINT;  dwBytes: DWORD): HGLOBAL;
PROCEDURE [_APICALL] GlobalReAlloc(hMem: HGLOBAL; dwBytes: DWORD; uFlags: UINT): HGLOBAL;
PROCEDURE [_APICALL] GlobalSize   (hMem: HGLOBAL): DWORD;
PROCEDURE [_APICALL] GlobalFlags  (hMem: HGLOBAL): UINT;
PROCEDURE [_APICALL] GlobalLock   (hMem: HGLOBAL): LPVOID;
PROCEDURE [_APICALL] GlobalUnlock (hMem: HGLOBAL): BOOL;
PROCEDURE [_APICALL] GlobalFree   (hMem: HGLOBAL): HGLOBAL;
PROCEDURE [_APICALL] GlobalFix    (hMem: HGLOBAL);
PROCEDURE [_APICALL] GlobalUnfix  (hMem: HGLOBAL);
PROCEDURE [_APICALL] GlobalWire   (hMem: HGLOBAL): LPVOID;
PROCEDURE [_APICALL] GlobalUnWire (hMem: HGLOBAL): BOOL;
PROCEDURE [_APICALL] GlobalHandle (pMem: LPCVOID): HGLOBAL;
PROCEDURE [_APICALL] GlobalCompact(dwMinFree: DWORD): UINT;
PROCEDURE [_APICALL] GlobalMemoryStatus(lpBuffer: LPMEMORYSTATUS);

END Win32.
