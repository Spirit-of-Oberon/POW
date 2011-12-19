(** This definition module contains a subset of Win32-API functions
    used by the Oberon-2 Run-Time-System                                 *)
DEFINITION RTSWin;

CONST

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

  (* -- MessageBox() Flags -- *)
  MB_OK               = 0H;
  MB_OKCANCEL         = 1H;
  MB_ABORTRETRYIGNORE = 2H;
  MB_YESNOCANCEL      = 3H;
  MB_YESNO            = 4H;
  MB_RETRYCANCEL      = 5H;
  MB_ICONHAND         = 10H;
  MB_ICONSTOP         = MB_ICONHAND;
  MB_ICONERROR        = MB_ICONHAND;
  MB_ICONQUESTION     = 20H;
  MB_ICONEXCLAMATION  = 30H;
  MB_ICONWARNING      = MB_ICONEXCLAMATION;
  MB_ICONASTERISK     = 40H;
  MB_ICONINFORMATION  = MB_ICONASTERISK;
  MB_DEFBUTTON1       = 0H;
  MB_DEFBUTTON2       = 100H;
  MB_DEFBUTTON3       = 200H;
  MB_DEFBUTTON4       = 300H;
  MB_APPLMODAL        = 0H;
  MB_SYSTEMMODAL      = 1000H;
  MB_TASKMODAL        = 2000H;
  MB_HELP             = 4000H;                     (*  Help Button *)
  MB_RIGHT            = 80000H;
  MB_RTLREADING       = 100000H;
  MB_NOFOCUS          = 8000H;
  MB_SETFOREGROUND    = 10000H;
  MB_DEFAULT_DESKTOP_ONLY = 20000H;
  (* MB_SERVICE_NOTIFICATION = 40000H;*)
  MB_TYPEMASK         = 0FH;
  MB_USERICON         = 80H;
  MB_ICONMASK         = 0F0H;
  MB_DEFMASK          = 0F00H;
  MB_MODEMASK         = 3000H;
  MB_MISCMASK         = 0C000H;

  (* -- Dialog Box Command IDs -- *)
  IDOK     = 1;
  IDCANCEL = 2;
  IDABORT  = 3;
  IDRETRY  = 4;
  IDIGNORE = 5;
  IDYES    = 6;
  IDNO     = 7;
  IDCLOSE  = 8;
  IDHELP   = 9;

  (* -- OpenFile Flags -- *)
  OF_READ             =    0H;
  OF_WRITE            =    1H;
  OF_READWRITE        =    2H;
  OF_SHARE_COMPAT     =    0H;
  OF_SHARE_EXCLUSIVE  =   10H;
  OF_SHARE_DENY_WRITE =   20H;
  OF_SHARE_DENY_READ  =   30H;
  OF_SHARE_DENY_NONE  =   40H;
  OF_PARSE            =  100H;
  OF_DELETE           =  200H;
  OF_VERIFY           =  400H;
  OF_CANCEL           =  800H;
  OF_CREATE           = 1000H;
  OF_PROMPT           = 2000H;
  OF_EXIST            = 4000H;
  OF_REOPEN           = 8000H;

  PROCESS_HEAP_REGION            =  1H;
  PROCESS_HEAP_UNCOMMITTED_RANGE =  2H;
  PROCESS_HEAP_ENTRY_BUSY        =  4H;
  PROCESS_HEAP_ENTRY_MOVEABLE    = 10H;
  PROCESS_HEAP_ENTRY_DDESHARE    = 20H;

  (* -- Define the size of the 80387 save area, which is in the context frame. -- *)
  SIZE_OF_80387_REGISTERS = 80;

  (* -- The following flags control the contents of the CONTEXT structure. -- *)
  CONTEXT_i386 = 00010000H;    (* this assumes that i386 and          *)
  CONTEXT_i486 = 00010000H;    (* i486 have identical context records *)
  CONTEXT_CONTROL         = (CONTEXT_i386 + 00000001H); (* SS:SP, CS:IP, FLAGS, BP *)
  CONTEXT_INTEGER         = (CONTEXT_i386 + 00000002H); (* AX, BX, CX, DX, SI, DI  *)
  CONTEXT_SEGMENTS        = (CONTEXT_i386 + 00000004H); (* DS, ES, FS, GS          *)
  CONTEXT_FLOATING_POINT  = (CONTEXT_i386 + 00000008H); (* 387 state               *)
  CONTEXT_DEBUG_REGISTERS = (CONTEXT_i386 + 00000010H); (* DB 0-3,6,7              *)
  CONTEXT_FULL            = (CONTEXT_CONTROL + CONTEXT_INTEGER + CONTEXT_SEGMENTS);


TYPE

  (* -- Basisdatentypen -- *)
  BOOL    = LONGINT;
  DWORD   = LONGINT;
  UINT    = LONGINT;
  WORD    = INTEGER;

  (* -- Handle -- *)
  HANDLE       = LONGINT;
  HDC          = HANDLE;
  HFILE        = HANDLE;
  HMODULE      = HANDLE;
  HGLOBAL      = HANDLE;
  HINSTANCE    = HANDLE;
  HLOCAL       = HANDLE;
  HWND         = HANDLE;
  GLOBALHANDLE = HANDLE;
  LOCALHANDLE  = HANDLE;

  (* -- long pointer -- *)
  LP            = LONGINT;
  LPBYTE        = LP;
  LPCSTR        = LP;
  LPCTSTR       = LP;
  LPSTARTUPINFO = LP;
  LPTSTR        = LP;
  LPVOID        = LP; (* void far * *)
  LPCVOID       = LP; (* const void far * *)
  LPCWSTR       = LP;

  (* -- procedure types -- *)
  FARPROC  = PROCEDURE [_APICALL](): LONGINT;
  NEARPROC = PROCEDURE [_APICALL](): LONGINT;
  PROC     = PROCEDURE [_APICALL](): LONGINT;

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

  STARTUPINFOA = RECORD [_NOTALIGNED]
    cb:             DWORD; 
    lpReserved:     LPTSTR; 
    lpDesktop:      LPTSTR; 
    lpTitle:        LPTSTR; 
    dwX:            DWORD; 
    dwY:            DWORD; 
    dwXSize:        DWORD;
    dwYSize:        DWORD; 
    dwXCountChars:  DWORD; 
    dwYCountChars:  DWORD; 
    dwFillAttribute:DWORD; 
    dwFlags:        DWORD; 
    wShowWindow:    WORD; 
    cbReserved2:    WORD;   
    lpReserved2:    LPBYTE; 
    hStdInput:      HANDLE;   
    hStdOutput:     HANDLE;  
    hStdError:      HANDLE;   
  END;
  STARTUPINFO = STARTUPINFOA;

  winbase_Struct0 = RECORD [_NOTALIGNED]
    hMem      : HANDLE;
    dwReserved: LONGINT;  (*ARRAY [3] OF DWORD;*)
  END;

  winbase_Struct1 = RECORD [_NOTALIGNED]
    dwCommittedSize  : DWORD;
    dwUnCommittedSize: DWORD;
    lpFirstBlock     : LPVOID;
    lpLastBlock      : LPVOID;
  END;
  (* UNION*)
(*  winbase_Union1 = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: Block : winbase_Struct0;
      |1: Region: winbase_Struct1;
    END;
  END;
*)
  winbase_Union1 = RECORD [_NOTALIGNED]
    Block : ARRAY 16 OF CHAR;
  END;

  PROCESS_HEAP_ENTRY = RECORD [_NOTALIGNED]
    lpData      : LPVOID;
    cbData      : DWORD;
    cbOverhead  : CHAR;
    iRegionIndex: CHAR;
    wFlags      : WORD;
    u           : winbase_Union1;
  END;
  LPPROCESS_HEAP_ENTRY = POINTER TO PROCESS_HEAP_ENTRY;
  PPROCESS_HEAP_ENTRY = LPPROCESS_HEAP_ENTRY;

  FLOATING_SAVE_AREA = RECORD [_NOTALIGNED]
    ControlWord:   DWORD;
    StatusWord:    DWORD;
    TagWord:       DWORD;
    ErrorOffset:   DWORD;
    ErrorSelector: DWORD;
    DataOffset:    DWORD;
    DataSelector:  DWORD;
    RegisterArea:  ARRAY SIZE_OF_80387_REGISTERS OF SHORTINT;
    Cr0NpxState:   DWORD;
  END;

  (*
   // Context Frame
   //
   // This frame has a several purposes: 1) it is used as an argument to
   // NtContinue, 2) is is used to constuct a call frame for APC delivery,
   // and 3) it is used in the user level thread creation routines.
   //
   // The layout of the record conforms to a standard call frame. 
  *)
  CONTEXT = RECORD [_NOTALIGNED]
  
    (*
    // The flags values within this flag control the contents of
    // a CONTEXT record.
    //
    // If the context record is used as an input parameter, then
    // for each portion of the context record controlled by a flag
    // whose value is set, it is assumed that that portion of the
    // context record contains valid context. If the context record
    // is being used to modify a threads context, then only that
    // portion of the threads context will be modified.
    //
    // If the context record is used as an IN OUT parameter to capture
    // the context of a thread, then only those portions of the thread's
    // context corresponding to set flags will be returned.
    //
    // The context record is never used as an OUT only parameter.
    *)
    ContextFlags: DWORD;

    (*
    // This section is specified/returned if CONTEXT_DEBUG_REGISTERS is
    // set in ContextFlags.  Note that CONTEXT_DEBUG_REGISTERS is NOT
    // included in CONTEXT_FULL.
    *)
    Dr0: DWORD;
    Dr1: DWORD;
    Dr2: DWORD;
    Dr3: DWORD;
    Dr6: DWORD;
    Dr7: DWORD;

    (*
    // This section is specified/returned if the
    // ContextFlags word contians the flag CONTEXT_FLOATING_POINT.
    *)
    FloatSave: FLOATING_SAVE_AREA;

    (*
    // This section is specified/returned if the
    // ContextFlags word contians the flag CONTEXT_SEGMENTS.
    *)
    SegGs: DWORD;
    SegFs: DWORD;
    SegEs: DWORD;
    SegDs: DWORD;

    (*
    // This section is specified/returned if the
    // ContextFlags word contians the flag CONTEXT_INTEGER.
    *)
    Edi: DWORD;
    Esi: DWORD;
    Ebx: DWORD;
    Edx: DWORD;
    Ecx: DWORD;
    Eax: DWORD;

    (*
    // This section is specified/returned if the
    // ContextFlags word contians the flag CONTEXT_CONTROL.
    *)
    Ebp:    DWORD;
    Eip:    DWORD;
    SegCs:  DWORD;             (* MUST BE SANITIZED *)
    EFlags: DWORD;             (* MUST BE SANITIZED *)
    Esp:    DWORD;
    SegSs:  DWORD;

  END;

  PCONTEXT = POINTER TO CONTEXT;


PROCEDURE [_APICALL] LineTo(hdc:HDC; x,y:LONGINT):LONGINT;

PROCEDURE [_APICALL] ExitProcess(uExitCode: UINT);
   
PROCEDURE [_APICALL] GetModuleHandle (lpModuleName: LPCTSTR): HMODULE;
PROCEDURE [_APICALL] GetCommandLine  (): LPTSTR;
PROCEDURE [_APICALL] GetStartupInfo  (VAR STATICTYPED lpStartupInfo: STARTUPINFOA);
      

PROCEDURE [_APICALL] GetLastError(): DWORD;
 
PROCEDURE [_APICALL] GetStdHandle  (nStdHandle:DWORD):HANDLE; 
PROCEDURE [_APICALL] AllocConsole  (): BOOL;
PROCEDURE [_APICALL] FreeConsole   (): BOOL;
PROCEDURE [_APICALL] WriteConsoleA (hConsoleOutput:HANDLE; lpBuffer:LONGINT; nNumberOfCharsToWrite:DWORD; VAR lpNumberOfCharsWritten:DWORD; lpReserved:LONGINT): BOOL;
 
PROCEDURE [_APICALL] MessageBeep (x: UINT): BOOL;
PROCEDURE [_APICALL] MessageBoxA (hWnd: HWND; lpText: LPCSTR; lpCaption: LPCSTR; uType: UINT): LONGINT;
                                 
(* -- memory functions for memory management -- *)
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

(* -- file functions for Log-File -- *)
PROCEDURE [_APICALL] _lopen  ( lpPathName: LPCSTR; iReadWrite: LONGINT ): HFILE;
PROCEDURE [_APICALL] _lcreat ( lpPathName: LPCSTR; iAttribute: LONGINT ): HFILE;
PROCEDURE [_APICALL] _lread  ( hFile: HFILE; lpBuffer: LPVOID; uBytes: UINT ): UINT;
PROCEDURE [_APICALL] _lwrite ( hFile: HFILE; lpBuffer: LPCSTR; uBytes: UINT ): UINT;
PROCEDURE [_APICALL] _lclose ( hFile: HFILE ): HFILE;
PROCEDURE [_APICALL] _llseek ( hFile: HFILE; lOffset: LONGINT; iOrigin: LONGINT ): LONGINT;

(* -- heap functions for garbage collector -- *)
PROCEDURE [_APICALL] HeapLock   ( hHeap: HANDLE ): BOOL;
PROCEDURE [_APICALL] HeapUnlock ( hHeap: HANDLE ): BOOL;
PROCEDURE [_APICALL] HeapWalk   ( hHeap: HANDLE; VAR STATICTYPED Entry: PROCESS_HEAP_ENTRY ): BOOL;
PROCEDURE [_APICALL] GetProcessHeap (  ): HANDLE;

(* -- getting information about the stack -- *)
PROCEDURE [_APICALL] GetThreadContext(hThread: HANDLE; VAR STATICTYPED lpContext: CONTEXT): BOOL;
PROCEDURE [_APICALL] SetThreadContext(hThread: HANDLE; VAR STATICTYPED lpContext: CONTEXT): BOOL;

(* -- -- *)
PROCEDURE [_APICALL] IsBadReadPtr      (lp: LPVOID; ucb: UINT): BOOL;
PROCEDURE [_APICALL] IsBadWritePtr     (lp: LPVOID; ucb: UINT): BOOL;
PROCEDURE [_APICALL] IsBadHugeReadPtr  (lp: LPVOID; ucb: UINT): BOOL;
PROCEDURE [_APICALL] IsBadHugeWritePtr (lp: LPVOID; ucb: UINT): BOOL;
PROCEDURE [_APICALL] IsBadCodePtr      (lpfn: FARPROC): BOOL;
PROCEDURE [_APICALL] IsBadStringPtrA   (lpsz: LPCSTR;  ucchMax: UINT): BOOL;
PROCEDURE [_APICALL] IsBadStringPtrW   (lpsz: LPCWSTR; ucchMax: UINT): BOOL;


END RTSWin.
