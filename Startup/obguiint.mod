(*********************************************************)
(*                                                       *)
(* *)                  DEFINITION ObGuiInt;           (* *)
(*                                                       *)
(*********************************************************)
(* 11-08-1997: lei                                       *)
(*********************************************************)
(*                                                       *)
(* external symbols for GUI startup code                 *)
(*                                                       *)
(* The Win32 API is duplicated for the startup code to   *)
(* avoid recompilation of the startup code when there    *)
(* are changes in the full API definition files.         *)
(*********************************************************)

CONST

  SW_HIDE = 0;
  SW_SHOWNORMAL = 1;
  SW_NORMAL = 1;
  SW_SHOWMINIMIZED = 2;
  SW_SHOWMAXIMIZED = 3;
  SW_MAXIMIZE = 3;
  SW_SHOWNOACTIVATE = 4;
  SW_SHOW = 5;
  SW_MINIMIZE = 6;
  SW_SHOWMINNOACTIVE = 7;
  SW_SHOWNA = 8;
  SW_RESTORE = 9;
  SW_SHOWDEFAULT = 10;
  SW_MAX = 10;

  STARTF_USESHOWWINDOW    =  1H;
  STARTF_USESIZE          =  2H;
  STARTF_USEPOSITION      =  4H;
  STARTF_USECOUNTCHARS    =  8H;
  STARTF_USEFILLATTRIBUTE = 10H;
  STARTF_RUNFULLSCREEN    = 20H;          (*  ignored for non-x86 platforms *)
  STARTF_FORCEONFEEDBACK  = 40H;
  STARTF_FORCEOFFFEEDBACK = 80H;
  STARTF_USESTDHANDLES    =100H;
  STARTF_USEHOTKEY        =200H;

TYPE
  HMODULE= LONGINT;   (*  HMODULEs can be used in place of HINSTANCEs  *)
  LPSTR  = LONGINT;
  LPCSTR = LONGINT;
  DWORD  = LONGINT;
  BOOL   = LONGINT;
  UINT   = LONGINT;
  WORD   = INTEGER;
  LPBYTE = LONGINT;
  HANDLE = LONGINT;

  STARTUPINFOA = RECORD [_NOTALIGNED]
    cb             : DWORD;
    lpReserved     : LPSTR;
    lpDesktop      : LPSTR;
    lpTitle        : LPSTR;
    dwX            : DWORD;
    dwY            : DWORD;
    dwXSize        : DWORD;
    dwYSize        : DWORD;
    dwXCountChars  : DWORD;
    dwYCountChars  : DWORD;
    dwFillAttribute: DWORD;
    dwFlags        : LONGINT;
    wShowWindow    : WORD;
    cbReserved2    : WORD;
    lpReserved2    : LPBYTE;
    hStdInput      : HANDLE;
    hStdOutput     : HANDLE;
    hStdError      : HANDLE;
  END;

PROCEDURE [_APICALL] GetStartupInfoA(VAR STATICTYPED StartupInfo: STARTUPINFOA);
PROCEDURE [_APICALL] GetModuleHandleA(lpModuleName: LPCSTR):HMODULE;
PROCEDURE [_APICALL] GetCommandLineA():LPSTR;
PROCEDURE [_APICALL] ExitProcess(uExitCode: UINT);

PROCEDURE [_APICALL] WinMain(hModule:HMODULE; commandLine:LPSTR; showWindow:LONGINT):LONGINT;

END ObGuiInt.
