(******************************************************************************)
(*                                                                            *)
(**)                      DEFINITION DDE;                                   (**)
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
(*  05-21-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(* dde.h -       Dynamic Data Exchange structures and definitions             *)
(*                                                                            *)
(******************************************************************************)
 
IMPORT WD := WinDef;                        
(*  DDE window messages  *)

CONST 
  WM_DDE_FIRST        = 3E0H;
  WM_DDE_INITIATE     = WM_DDE_FIRST;
  WM_DDE_TERMINATE    = WM_DDE_FIRST+1;
  WM_DDE_ADVISE       = WM_DDE_FIRST+2;
  WM_DDE_UNADVISE     = WM_DDE_FIRST+3;
  WM_DDE_ACK          = WM_DDE_FIRST+4;
  WM_DDE_DATA         = WM_DDE_FIRST+5;
  WM_DDE_REQUEST      = WM_DDE_FIRST+6;
  WM_DDE_POKE         = WM_DDE_FIRST+7;
  WM_DDE_EXECUTE      = WM_DDE_FIRST+8;
  WM_DDE_LAST         = WM_DDE_FIRST+8;

(*   ----------------------------------------------------------------------------  *)
(* |       DDEACK structure                                                        *)
(* |                                                                               *)
(* |  Structure of wStatus (LOWORD(lParam)) in WM_DDE_ACK message                   *)
(* |       sent in response to a WM_DDE_DATA, WM_DDE_REQUEST, WM_DDE_POKE,         *)
(* |       WM_DDE_ADVISE, or WM_DDE_UNADVISE message.                              *)
(* |                                                                               *)
(* ----------------------------------------------------------------------------    *)

TYPE
(*BITFIELD*)
  DDEACK = RECORD [_NOTALIGNED]
  Data: INTEGER;
  END;
(*
  DDEACK = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    bAppReturnCode: INTEGER;                (* H2D: bit field. bAppReturnCode:8 *)
    reserved      : INTEGER;                (* H2D: bit field. reserved:6 *)
    fBusy         : INTEGER;                (* H2D: bit field. fBusy:1 *)
    fAck          : INTEGER;                (* H2D: bit field. fAck:1 *)
<* ELSE *>
    bAppReturnCode: PACKEDSET OF [0..15];   (* H2D: bit field. bAppReturnCode:8, reserved:6, fBusy:1, fAck:1. *)
<* END *>
  END;
*)

(*   ----------------------------------------------------------------------------  *)
(* |       DDEADVISE structure                                                     *)
(* |                                                                               *)
(* |  WM_DDE_ADVISE parameter structure for hOptions (LOWORD(lParam))               *)
(* |                                                                               *)
(* ----------------------------------------------------------------------------    *)
 (*BITFIELD*)
  DDEADVISE = RECORD [_NOTALIGNED]
  data: INTEGER;
  END;
(*
  DDEADVISE = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    reserved : INTEGER;                (* H2D: bit field. reserved:14 *)
    fDeferUpd: INTEGER;                (* H2D: bit field. fDeferUpd:1 *)
    fAckReq  : INTEGER;                (* H2D: bit field. fAckReq:1 *)
<* ELSE *>
    reserved : PACKEDSET OF [0..15];   (* H2D: bit field. reserved:14, fDeferUpd:1, fAckReq:1. *)
<* END *>
    cfFormat : INTEGER;
  END;
 *)
(*   ----------------------------------------------------------------------------  *)
(* |       DDEDATA structure                                                       *)
(* |                                                                               *)
(* |       WM_DDE_DATA parameter structure for hData (LOWORD(lParam)).             *)
(* |       The actual size of this structure depends on the size of                *)
(* |       the Value array.                                                        *)
(* |                                                                               *)
(* ----------------------------------------------------------------------------    *)
 (*
  DDEDATA = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    unused   : INTEGER;                             (* H2D: bit field. unused:12 *)
    fResponse: INTEGER;                             (* H2D: bit field. fResponse:1 *)
    fRelease : INTEGER;                             (* H2D: bit field. fRelease:1 *)
    reserved : INTEGER;                             (* H2D: bit field. reserved:1 *)
    fAckReq  : INTEGER;                             (* H2D: bit field. fAckReq:1 *)
<* ELSE *>
    unused   : PACKEDSET OF [0..15];                (* H2D: bit field. unused:12, fResponse:1, fRelease:1, reserved:1, fAckReq:1. *)
<* END *>
    cfFormat : INTEGER;
    Value    : ARRAY 1 OF WD.BYTE;
  END;

(*   ----------------------------------------------------------------------------  *)
(* |  DDEPOKE structure                                                             *)
(* |                                                                               *)
(* |  WM_DDE_POKE parameter structure for hData (LOWORD(lParam)).                   *)
(* |       The actual size of this structure depends on the size of                *)
(* |       the Value array.                                                        *)
(* |                                                                               *)
(* ----------------------------------------------------------------------------    *)

  DDEPOKE = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    unused   : INTEGER;                             (* H2D: bit field. unused:13 *)
                                                    (*  Earlier versions of DDE.H incorrectly  *)
<* END *>
(*  12 unused bits.                        *)
<* IF __GEN_C__ THEN *>
    fRelease : INTEGER;                             (* H2D: bit field. fRelease:1 *)
    fReserved: INTEGER;                             (* H2D: bit field. fReserved:2 *)
<* ELSE *>
    unused   : PACKEDSET OF [0..15];                (* H2D: bit field. unused:13, fRelease:1, fReserved:2. *)
                                                    (*  Earlier versions of DDE.H incorrectly  *)
<* END *>
    cfFormat : INTEGER;
    Value    : ARRAY [0..1-1] OF WD.BYTE;   (*  This member was named rgb[1] in previous  *)
 
(*  versions of DDE.H                         *)
  END;
end Macros*)

  SECURITY_QUALITY_OF_SERVICE = RECORD [_NOTALIGNED]
    (*  sqos  *)
    Length             : WD.DWORD;
(* SECURITY_IMPERSONATION_LEVEL *)
    ImpersonationLevel : LONGINT;
(* SECURITY_CONTEXT_TRACKING_MODE *)
    ContextTrackingMode: LONGINT;
    EffectiveOnly      : WD.BOOL;
  END;
  PSECURITY_QUALITY_OF_SERVICE = POINTER TO SECURITY_QUALITY_OF_SERVICE;

(*   ----------------------------------------------------------------------------  *)
(* The following typedef's were used in previous versions of the Windows SDK.      *)
(* They are still valid.  The above typedef's define exactly the same structures   *)
(* as those below.  The above typedef names are recommended, however, as they      *)
(* are more meaningful.                                                            *)
(*                                                                                 *)
(* Note that the DDEPOKE structure typedef'ed in earlier versions of DDE.H did     *)
(* not correctly define the bit positions.                                         *)
(* ----------------------------------------------------------------------------    *)
(* Macros
  DDELN = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    unused   : INTEGER;                (* H2D: bit field. unused:13 *)
    fRelease : INTEGER;                (* H2D: bit field. fRelease:1 *)
    fDeferUpd: INTEGER;                (* H2D: bit field. fDeferUpd:1 *)
    fAckReq  : INTEGER;                (* H2D: bit field. fAckReq:1 *)
<* ELSE *>
    unused   : PACKEDSET OF [0..15];   (* H2D: bit field. unused:13, fRelease:1, fDeferUpd:1, fAckReq:1. *)
<* END *>
    cfFormat : INTEGER;
  END;
  DDEUP = DDEDATA;
end Macros*)
(*                  *)
(*  * DDE SECURITY  *)
(*                  *)

PROCEDURE [_APICALL] DdeSetQualityOfService ( hwndClient: WD.HWND;
                                   VAR STATICTYPED qosNew: SECURITY_QUALITY_OF_SERVICE;
                                   VAR STATICTYPED qosPrev: SECURITY_QUALITY_OF_SERVICE ): WD.BOOL;

PROCEDURE [_APICALL] ImpersonateDdeClientWindow ( hWndClient: WD.HWND;
                                       hWndServer: WD.HWND ): WD.BOOL;

(*                              *)
(*  * DDE message packing APIs  *)
(*                              *)

PROCEDURE [_APICALL] PackDDElParam ( msg: WD.UINT; uiLo: WD.UINT;
                          uiHi: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] UnpackDDElParam ( msg: WD.UINT; lParam: LONGINT;
                            VAR puiLo: WD.UINT;
                            VAR puiHi: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] FreeDDElParam ( msg: WD.UINT; lParam: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ReuseDDElParam ( lParam: LONGINT; msgIn: WD.UINT;
                           msgOut: WD.UINT; uiLo: WD.UINT;
                           uiHi: WD.UINT ): LONGINT;

END DDE.
