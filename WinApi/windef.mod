(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION WinDef;                              (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1993; Robinson Associates                                    *)
(*                     Red Lion House                                         *)
(*                     St Mary's Street                                       *)
(*                     PAINSWICK                                              *)
(*                     Glos                                                   *)
(*                     GL6  6QR                                               *)
(*                     Tel:    (+44) (0)1452 813 699                          *)
(*                     Fax:    (+44) (0)1452 812 912                          *)
(*                     e-Mail: Oberon@robinsons.co.uk                         *)
(******************************************************************************)
(*  06-0§-1997 rel. 1.1 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(* windef.h -- Basic Windows Type Definitions                                 *)
(******************************************************************************)

CONST 
  WINVER= 400H;
  MAX_PATH= 260;
  False= 0;  (* TRUE & FALSE allready declared in Oberon 2.0 *)
  True= 1;
  NULL = 0;
(*  mode selections for the device mode function  *) 
  DM_UPDATE= 1;
  DM_OUT_DEFAULT= DM_UPDATE;
  DM_COPY= 2;
  DM_OUT_BUFFER= DM_COPY;
  DM_PROMPT= 4;
  DM_IN_PROMPT= DM_PROMPT;
  DM_MODIFY= 8;
  DM_IN_BUFFER= DM_MODIFY;

(*  device capabilities indices  *)
  DC_FIELDS= 1;
  DC_PAPERS= 2;
  DC_PAPERSIZE= 3;
  DC_MINEXTENT= 4;
  DC_MAXEXTENT= 5;
  DC_BINS= 6;
  DC_DUPLEX= 7;
  DC_SIZE= 8;
  DC_EXTRA= 9;
  DC_VERSION= 10;
  DC_DRIVER= 11;
  DC_BINNAMES= 12;
  DC_ENUMRESOLUTIONS= 13;
  DC_FILEDEPENDENCIES= 14;
  DC_TRUETYPE= 15;
  DC_PAPERNAMES= 16;
  DC_ORIENTATION= 17;
  DC_COPIES= 18;

  HFILE_ERROR= -1;

(*                                                                        *)
(*  * BASETYPES is defined in ntdef.h if these types are already defined  *)
(*                                                                        *)

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
  INT= LONGINT;
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
  LPCWSTR = LONGINT;
(* #ifndef NT_INCLUDED     *)
(* #include <winnt.h>      *)
(* #endif  NT_INCLUDED     *)
(*  Types use for passing & returning polymorphic values  *)

  WPARAM= LONGINT;
  LPARAM= LONGINT;
  LRESULT= LONGINT;


(* Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] max ( a, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / max ( a, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] min ( a, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / min ( a, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEWORD ( a, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEWORD ( a, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKELONG ( a, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKELONG ( a, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] LOWORD ( l: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / LOWORD ( l: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] HIWORD ( l: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / HIWORD ( l: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] LOBYTE ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / LOBYTE ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] HIBYTE ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / HIBYTE ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
*)
 
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

  FARPROC= PROCEDURE [_APICALL](): LONGINT;
  NEARPROC= PROCEDURE [_APICALL](): LONGINT;
  PROC= PROCEDURE [_APICALL](): LONGINT;

  HGDIOBJ= LONGINT;
  HACCEL= LONGINT;
  HBITMAP= LONGINT;
  HBRUSH= LONGINT;
  HCOLORSPACE= LONGINT;
  HDC= LONGINT;
  HGLRC= LONGINT;                     (*  OpenGL *)
  HDESK= LONGINT;
  HENHMETAFILE= LONGINT;
  HFONT= LONGINT;
  HICON= LONGINT;
  HMENU= LONGINT;
  HMETAFILE= LONGINT;
  HINSTANCE= LONGINT;
  HMODULE= LONGINT;                   (*  HMODULEs can be used in place of HINSTANCEs  *)
  HPALETTE= LONGINT;
  HPEN= LONGINT;
  HRGN= LONGINT;
  HRSRC= LONGINT;
  HSTR= LONGINT;
  HTASK= LONGINT;
  HWINSTA= LONGINT;
  HKL= LONGINT;
  HFILE= LONGINT;
  HCURSOR= LONGINT;                   (*  HICONs & HCURSORs are polymorphic  *)
  COLORREF= LONGINT;
  LPCOLORREF= PULONG;
  
  RECT= RECORD
    left : LONGINT;
    top  : LONGINT;
    right: LONGINT;
    bottom:LONGINT;
  END;
    
  PRECT= POINTER TO RECT;
  NPRECT= POINTER TO RECT;
  LPRECT= POINTER TO RECT;
  LPCRECT= LPRECT;

(*  rcl  *)

  RECTL= RECORD
    left : LONGINT;
    top  : LONGINT;
    right: LONGINT;
    bottom: LONGINT;
  END;

  PRECTL= POINTER TO RECTL;
  LPRECTL= POINTER TO RECTL;
  LPCRECTL= POINTER TO RECTL;

  POINT= RECORD
    x: LONGINT;
    y: LONGINT;
  END;
    
  PPOINT= POINTER TO POINT;
  NPPOINT= POINTER TO POINT;
  LPPOINT= POINTER TO POINT;

(*  ptl   *)

  POINTL= RECORD
    x: LONGINT;
    y: LONGINT;
  END;

  PPOINTL= POINTER TO POINTL;

  SIZE= RECORD
    cx: LONGINT;
    cy: LONGINT;
  END;

  PSIZE= POINTER TO SIZE;
  LPSIZE= POINTER TO SIZE;

  SIZEL=  RECORD
    cx: LONGINT;
    cy: LONGINT;
  END;

  PSIZEL= POINTER TO SIZEL;
  LPSIZEL= POINTER TO SIZEL;

  POINTS= RECORD
    x: INTEGER;
    y: INTEGER;
  END;

  PPOINTS= POINTER TO POINTS;
  LPPOINTS= POINTER TO POINTS;

END WinDef.
