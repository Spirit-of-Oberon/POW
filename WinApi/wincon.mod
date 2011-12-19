(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION WinCon;                              (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1993, Robinson Associates                                    *)
(*                     Red Lion House                                         *)
(*                     St Mary's Street                                       *)
(*                     PAINSWICK                                              *)
(*                     Glos                                                   *)
(*                     GL6  6QR                                               *)
(*                     Tel:    (+44) (0)1452 813 699                          *)
(*                     Fax:    (+44) (0)1452 812 912                          *)
(*                     e-Mail: Oberon@robinsons.co.uk                         *)
(******************************************************************************)
(*  06-01-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(* Module Name:                                                               *)
(*                                                                            *)
(*     wincon.h                                                               *)
(*                                                                            *)
(* Abstract:                                                                  *)
(*                                                                            *)
(*     This module contains the public data structures, data types,           *)
(*     and procedures exported by the NT console subsystem.                   *)
(******************************************************************************)

IMPORT WB := WinBase, WN := WinNt, WD := WinDef;

(*  *)
(*  ControlKeyState flags *)
(*  *)

CONST 
  RIGHT_ALT_PRESSED = 1H;              (*  the right alt key is pressed. *)
  LEFT_ALT_PRESSED = 2H;               (*  the left alt key is pressed. *)
  RIGHT_CTRL_PRESSED = 4H;             (*  the right ctrl key is pressed. *)
  LEFT_CTRL_PRESSED = 8H;              (*  the left ctrl key is pressed. *)
  SHIFT_PRESSED = 10H;                 (*  the shift key is pressed. *)
  NUMLOCK_ON = 20H;                    (*  the numlock light is on. *)
  SCROLLLOCK_ON = 40H;                 (*  the scrolllock light is on. *)
  CAPSLOCK_ON = 80H;                   (*  the capslock light is on. *)
  ENHANCED_KEY = 100H;                 (*  the key is enhanced. *)

(*  *)
(*  ButtonState flags *)
(*  *)
  FROM_LEFT_1ST_BUTTON_PRESSED = 1H;
  RIGHTMOST_BUTTON_PRESSED = 2H;
  FROM_LEFT_2ND_BUTTON_PRESSED = 4H;
  FROM_LEFT_3RD_BUTTON_PRESSED = 8H;
  FROM_LEFT_4TH_BUTTON_PRESSED = 10H;

(*  *)
(*  EventFlags *)
(*  *)
  MOUSE_MOVED = 1H;
  DOUBLE_CLICK = 2H;

(*  *)
(*   EventType flags: *)
(*  *)
  KEY_EVENT = 1H;                      (*  Event contains key event record *)
  MOUSE_EVENT = 2H;                    (*  Event contains mouse event record *)
  WINDOW_BUFFER_SIZE_EVENT = 4H;       (*  Event contains window change event record *)
  MENU_EVENT = 8H;                     (*  Event contains menu event record *)
  FOCUS_EVENT = 10H;                   (*  event contains focus change *)

(*  *)
(*  Attributes flags: *)
(*  *)
  FOREGROUND_BLUE = 1H;                (*  text color contains blue. *)
  FOREGROUND_GREEN = 2H;               (*  text color contains green. *)
  FOREGROUND_RED = 4H;                 (*  text color contains red. *)
  FOREGROUND_INTENSITY = 8H;           (*  text color is intensified. *)
  BACKGROUND_BLUE = 10H;               (*  background color contains blue. *)
  BACKGROUND_GREEN = 20H;              (*  background color contains green. *)
  BACKGROUND_RED = 40H;                (*  background color contains red. *)
  BACKGROUND_INTENSITY = 80H;          (*  background color is intensified. *)
 
  CTRL_C_EVENT = 0;
  CTRL_BREAK_EVENT = 1;
  CTRL_CLOSE_EVENT = 2;

(*  3 is reserved! *)
(*  4 is reserved! *)
  CTRL_LOGOFF_EVENT = 5;
  CTRL_SHUTDOWN_EVENT = 6;

(*  *)
(*   Input Mode flags: *)
(*  *)
  ENABLE_PROCESSED_INPUT = 1H;
  ENABLE_LINE_INPUT = 2H;
  ENABLE_ECHO_INPUT = 4H;
  ENABLE_WINDOW_INPUT = 8H;
  ENABLE_MOUSE_INPUT = 10H;

(*  *)
(*  Output Mode flags: *)
(*  *)
  ENABLE_PROCESSED_OUTPUT = 1H;
  ENABLE_WRAP_AT_EOL_OUTPUT = 2H;
 
  CONSOLE_TEXTMODE_BUFFER = 1;

TYPE 
  COORD = RECORD [_NOTALIGNED]
    X: INTEGER;
    Y: INTEGER;
  END;
  PCOORD = POINTER TO COORD;

  SMALL_RECT = RECORD [_NOTALIGNED]
    Left  : INTEGER;
    Top   : INTEGER;
    Right : INTEGER;
    Bottom: INTEGER;
  END;
  PSMALL_RECT = POINTER TO SMALL_RECT;
(* UNION*)
(*
  wincon_Union = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: UnicodeChar: WD.WCHAR;
      |1: AsciiChar  : CHAR;
    END;
  END;
*)
  wincon_Union = RECORD [_NOTALIGNED]
    AsciiChar  : ARRAY 2 OF WD.BYTE;
  END;

  KEY_EVENT_RECORD = RECORD [_NOTALIGNED]
    bKeyDown         : WD.BOOL;
    wRepeatCount     : WD.WORD;
    wVirtualKeyCode  : WD.WORD;
    wVirtualScanCode : WD.WORD;
    uChar            : wincon_Union;
    dwControlKeyState: WD.DWORD;
  END;
  PKEY_EVENT_RECORD = POINTER TO KEY_EVENT_RECORD;

  MOUSE_EVENT_RECORD = RECORD [_NOTALIGNED]
    dwMousePosition  : COORD;
    dwButtonState    : WD.DWORD;
    dwControlKeyState: WD.DWORD;
    dwEventFlags     : WD.DWORD;
  END;

  PMOUSE_EVENT_RECORD = POINTER TO MOUSE_EVENT_RECORD;
 
  WINDOW_BUFFER_SIZE_RECORD = RECORD [_NOTALIGNED]
    dwSize: COORD;
  END;
  PWINDOW_BUFFER_SIZE_RECORD = POINTER TO WINDOW_BUFFER_SIZE_RECORD;

  MENU_EVENT_RECORD = RECORD [_NOTALIGNED]
    dwCommandId: WD.UINT;
  END;
  PMENU_EVENT_RECORD = POINTER TO MENU_EVENT_RECORD;

  FOCUS_EVENT_RECORD = RECORD [_NOTALIGNED]
    bSetFocus: WD.BOOL;
  END;
  PFOCUS_EVENT_RECORD = POINTER TO FOCUS_EVENT_RECORD;
(* UNION
  wincon_Union0 = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: KeyEvent             : KEY_EVENT_RECORD;
      |1: MouseEvent           : MOUSE_EVENT_RECORD;
      |2: WindowBufferSizeEvent: WINDOW_BUFFER_SIZE_RECORD;
      |3: MenuEvent            : MENU_EVENT_RECORD;
      |4: FocusEvent           : FOCUS_EVENT_RECORD;
    END;
  END;
*)
  wincon_Union0 = RECORD [_NOTALIGNED]
    FocusEvent: ARRAY 16 OF WD.BYTE;
  END;

  INPUT_RECORD = RECORD [_NOTALIGNED]
    EventType: WD.WORD;
    Event    : wincon_Union0;
  END;
  PINPUT_RECORD = POINTER TO INPUT_RECORD;
 
  CHAR_INFO = RECORD [_NOTALIGNED]
    Char      : wincon_Union;
    Attributes: WD.WORD;
  END;
  PCHAR_INFO = POINTER TO CHAR_INFO;
 
  CONSOLE_SCREEN_BUFFER_INFO = RECORD [_NOTALIGNED]
    dwSize             : COORD;
    dwCursorPosition   : COORD;
    wAttributes        : WD.WORD;
    srWindow           : SMALL_RECT;
    dwMaximumWindowSize: COORD;
  END;
  PCONSOLE_SCREEN_BUFFER_INFO = POINTER TO CONSOLE_SCREEN_BUFFER_INFO;

  CONSOLE_CURSOR_INFO = RECORD [_NOTALIGNED]
    dwSize  : WD.DWORD;
    bVisible: WD.BOOL;
  END;
  PCONSOLE_CURSOR_INFO = POINTER TO CONSOLE_CURSOR_INFO;

(*  *)
(*  typedef for ctrl-c handler routines *)
(*  *)
  PHANDLER_ROUTINE = PROCEDURE [_APICALL] ( CtrlType: WD.DWORD ): WD.BOOL;

(*  *)
(*  direct API definitions. *)
(*  *)

PROCEDURE [_APICALL] PeekConsoleInputA ( hConsoleInput: WD.HANDLE;
                              VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                              VAR NumberOfEventsRead: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] PeekConsoleInputW ( hConsoleInput: WD.HANDLE;
                              VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                              VAR NumberOfEventsRead: WD.DWORD ): WD.BOOL;
(*  ! PeekConsoleInput *)

PROCEDURE [_APICALL] ReadConsoleInputA ( hConsoleInput: WD.HANDLE;
                              VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                              NumberOfEventsRead: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] ReadConsoleInputW ( hConsoleInput: WD.HANDLE;
                              VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                              VAR NumberOfEventsRead: WD.DWORD ): WD.BOOL;
(*  !   ReadConsoleInput *)

PROCEDURE [_APICALL] WriteConsoleInputA ( hConsoleInput: WD.HANDLE;
                               VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                               VAR NumberOfEventsWritten: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] WriteConsoleInputW ( hConsoleInput: WD.HANDLE;
                               VAR STATICTYPED Buffer: INPUT_RECORD; nLength: WD.DWORD;
                               VAR NumberOfEventsWritten: WD.DWORD ): WD.BOOL;
(*  !  WriteConsoleInput *)

PROCEDURE [_APICALL] ReadConsoleOutputA ( hConsoleOutput: WD.HANDLE;
                               VAR STATICTYPED Buffer: CHAR_INFO; dwBufferSize: COORD;
                               dwBufferCoord: COORD;
                               VAR STATICTYPED ReadRegion: SMALL_RECT ): WD.BOOL;
PROCEDURE [_APICALL] ReadConsoleOutputW ( hConsoleOutput: WD.HANDLE;
                               VAR STATICTYPED Buffer: CHAR_INFO; dwBufferSize: COORD;
                               dwBufferCoord: COORD;
                               VAR STATICTYPED ReadRegion: SMALL_RECT ): WD.BOOL;
(*  ! ReadConsoleOutput *)

PROCEDURE [_APICALL] WriteConsoleOutputA ( hConsoleOutput: WD.HANDLE;
                                VAR STATICTYPED Buffer: CHAR_INFO; dwBufferSize: COORD;
                                dwBufferCoord: COORD;
                                VAR STATICTYPED WriteRegion: SMALL_RECT ): WD.BOOL;
PROCEDURE [_APICALL] WriteConsoleOutputW ( hConsoleOutput: WD.HANDLE;
                                VAR STATICTYPED Buffer: CHAR_INFO; dwBufferSize: COORD;
                                dwBufferCoord: COORD;
                                VAR STATICTYPED WriteRegion: SMALL_RECT ): WD.BOOL;
(*  !   WriteConsoleOutput *)

PROCEDURE [_APICALL] ReadConsoleOutputCharacterA ( hConsoleOutput: WD.HANDLE;
                                        lpCharacter: WD.LPSTR;
                                        nLength: WD.DWORD; dwReadCoord: COORD;
                                        VAR NumberOfCharsRead: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] ReadConsoleOutputCharacterW ( hConsoleOutput: WD.HANDLE;
                                        lpCharacter: WD.LPWSTR;
                                        nLength: WD.DWORD; dwReadCoord: COORD;
                                        VAR NumberOfCharsRead: WD.DWORD ): WD.BOOL;
(*  ! ReadConsoleOutputCharacter *)
PROCEDURE [_APICALL] ReadConsoleOutputAttribute ( hConsoleOutput: WD.HANDLE;
                                       VAR Attribute: WD.WORD;
                                       nLength: WD.DWORD; dwReadCoord: COORD;
                                       VAR NumberOfAttrsRead: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] WriteConsoleOutputCharacterA ( hConsoleOutput: WD.HANDLE;
                                         lpCharacter: WD.LPCSTR;
                                         nLength: WD.DWORD;
                                         dwWriteCoord: COORD;
                                         VAR NumberOfCharsWritten: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] WriteConsoleOutputCharacterW ( hConsoleOutput: WD.HANDLE;
                                         lpCharacter: WD.LPCWSTR;
                                         nLength: WD.DWORD;
                                         dwWriteCoord: COORD;
                                         VAR NumberOfCharsWritten: WD.DWORD ): WD.BOOL;
(*  !  WriteConsoleOutputCharacter*)

PROCEDURE [_APICALL] WriteConsoleOutputAttribute ( hConsoleOutput: WD.HANDLE;
                                        VAR Attribute: WN.SECURITY_DESCRIPTOR_CONTROL;
                                        nLength: WD.DWORD;
                                        dwWriteCoord: COORD;
                                        lpNumberOfAttrsWritten: WD.LPDWORD ): WD.BOOL;

PROCEDURE [_APICALL] FillConsoleOutputCharacterA ( hConsoleOutput: WD.HANDLE;
                                        cCharacter: CHAR; nLength: WD.DWORD;
                                        dwWriteCoord: COORD;
                                        VAR NumberOfCharsWritten: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] FillConsoleOutputCharacterW ( hConsoleOutput: WD.HANDLE;
                                        cCharacter: WD.WCHAR;
                                        nLength: WD.DWORD;
                                        dwWriteCoord: COORD;
                                        VAR NumberOfCharsWritten: WD.DWORD ): WD.BOOL;
(*  ! FillConsoleOutputCharacter *)

PROCEDURE [_APICALL] FillConsoleOutputAttribute ( hConsoleOutput: WD.HANDLE;
                                       wAttribute: WD.WORD;
                                       nLength: WD.DWORD; dwWriteCoord: COORD;
                                       VAR NumberOfAttrsWritten: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetConsoleMode ( hConsoleHandle: WD.HANDLE;
                           VAR Mode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetNumberOfConsoleInputEvents ( hConsoleInput: WD.HANDLE;
                                          VAR NumberOfEvents: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetConsoleScreenBufferInfo ( hConsoleOutput: WD.HANDLE;
                    VAR STATICTYPED ConsoleScreenBufferInfo: CONSOLE_SCREEN_BUFFER_INFO ): WD.BOOL;

PROCEDURE [_APICALL] GetLargestConsoleWindowSize ( hConsoleOutput: WD.HANDLE ): LONGINT(* Resulttype = COORD HiByte = X, LoByte = Y*);

PROCEDURE [_APICALL] GetConsoleCursorInfo ( hConsoleOutput: WD.HANDLE;
                                 VAR STATICTYPED ConsoleCursorInfo: CONSOLE_CURSOR_INFO ): WD.BOOL;

PROCEDURE [_APICALL] GetNumberOfConsoleMouseButtons ( VAR NumberOfMouseButtons: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleMode ( hConsoleHandle: WD.HANDLE;
                           dwMode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleActiveScreenBuffer ( hConsoleOutput: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] FlushConsoleInputBuffer ( hConsoleInput: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleScreenBufferSize ( hConsoleOutput: WD.HANDLE;
                                       dwSize: COORD ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleCursorPosition ( hConsoleOutput: WD.HANDLE;
                                     dwCursorPosition: COORD ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleCursorInfo ( hConsoleOutput: WD.HANDLE;
                                 VAR STATICTYPED ConsoleCursorInfo: CONSOLE_CURSOR_INFO ): WD.BOOL;

PROCEDURE [_APICALL] ScrollConsoleScreenBufferA ( hConsoleOutput: WD.HANDLE;
                                       VAR STATICTYPED ScrollRectangle: SMALL_RECT;
                                       VAR STATICTYPED ClipRectangle: SMALL_RECT;
                                       dwDestinationOrigin: COORD;
                                       VAR STATICTYPED Fill: CHAR_INFO ): WD.BOOL;
PROCEDURE [_APICALL] ScrollConsoleScreenBufferW ( hConsoleOutput: WD.HANDLE;
                                       VAR STATICTYPED ScrollRectangle: SMALL_RECT;
                                       VAR STATICTYPED ClipRectangle: SMALL_RECT;
                                       dwDestinationOrigin: COORD;
                                       VAR STATICTYPED Fill: CHAR_INFO ): WD.BOOL;
(*  !  ScrollConsoleScreenBuffer *)

PROCEDURE [_APICALL] SetConsoleWindowInfo ( hConsoleOutput: WD.HANDLE;
                                 bAbsolute: WD.BOOL;
                                 VAR STATICTYPED ConsoleWindow: SMALL_RECT ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleTextAttribute ( hConsoleOutput: WD.HANDLE;
                                    wAttributes: WD.WORD ): WD.BOOL;

PROCEDURE [_APICALL] SetConsoleCtrlHandler ( HandlerRoutine: PHANDLER_ROUTINE;
                                  Add: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GenerateConsoleCtrlEvent ( dwCtrlEvent: WD.DWORD;
                                     dwProcessGroupId: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] AllocConsole (): WD.BOOL;

PROCEDURE [_APICALL] FreeConsole (): WD.BOOL;

PROCEDURE [_APICALL] GetConsoleTitleA ( lpConsoleTitle: WD.LPSTR;
                             nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetConsoleTitleW ( lpConsoleTitle: WD.LPWSTR;
                             nSize: WD.DWORD ): WD.DWORD;
(*  !   GetConsoleTitle *)

PROCEDURE [_APICALL] SetConsoleTitleA ( lpConsoleTitle: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetConsoleTitleW ( lpConsoleTitle: WD.LPCWSTR ): WD.BOOL;
(*  !   SetConsoleTitle *)

PROCEDURE [_APICALL] ReadConsoleA ( hConsoleInput: WD.HANDLE;
                         lpBuffer: WD.LPVOID;
                         nNumberOfCharsToRead: WD.DWORD;
                         VAR NumberOfCharsRead: WD.DWORD;
                         lpReserved: WD.LPVOID ): WD.BOOL;
PROCEDURE [_APICALL] ReadConsoleW ( hConsoleInput: WD.HANDLE;
                         lpBuffer: WD.LPVOID;
                         nNumberOfCharsToRead: WD.DWORD;
                         VAR NumberOfCharsRead: WD.DWORD;
                         lpReserved: WD.LPVOID ): WD.BOOL;
(*  ! ReadConsole *)

PROCEDURE [_APICALL] WriteConsoleA ( hConsoleOutput: WD.HANDLE; lpBuffer: WD.LPVOID;
                          nNumberOfCharsToWrite: WD.DWORD;
                          VAR NumberOfCharsWritten: WD.DWORD;
                          lpReserved: WD.LPVOID ): WD.BOOL;
PROCEDURE [_APICALL] WriteConsoleW ( hConsoleOutput: WD.HANDLE; lpBuffer: WD.LPVOID;
                          nNumberOfCharsToWrite: WD.DWORD;
                          VAR NumberOfCharsWritten: WD.DWORD;
                          lpReserved: WD.LPVOID ): WD.BOOL;
(*  !   WriteConsole *)

PROCEDURE [_APICALL] CreateConsoleScreenBuffer ( dwDesiredAccess: WD.DWORD;
                                      dwShareMode: WD.DWORD;
                                      VAR STATICTYPED SecurityAttributes: WB.SECURITY_ATTRIBUTES;
                                      dwFlags: WD.DWORD;
                                      lpScreenBufferData: WD.LPVOID ): WD.HANDLE;

PROCEDURE [_APICALL] GetConsoleCP (  ): WD.UINT;

PROCEDURE [_APICALL] SetConsoleCP ( wCodePageID: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetConsoleOutputCP (  ): WD.UINT;

PROCEDURE [_APICALL] SetConsoleOutputCP ( wCodePageID: WD.UINT ): WD.BOOL;

END WinCon.
