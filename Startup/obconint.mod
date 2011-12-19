(*********************************************************)
(*                                                       *)
(* *)                  DEFINITION ObConInt;           (* *)
(*                                                       *)
(*********************************************************)
(* 11-08-1997: lei                                       *)
(*********************************************************)
(*                                                       *)
(* external symbols for console application startup code *)
(*                                                       *)
(* The Win32 API is duplicated for the startup code to   *)
(* avoid recompilation of the startup code when there    *)
(* are changes in the full API definition files.         *)
(*********************************************************)

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
PROCEDURE [_APICALL] AllocConsole (): BOOL;
PROCEDURE [_APICALL] FreeConsole (): BOOL;

PROCEDURE [_APICALL] WinMain (commandLine:LPSTR);

END ObConInt.
