(******************************************************************************)
(*                                                                            *)
(**)                        MODULE Debug;                                   (**)
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
(* PURPOSE:  procedures for writing debug messages directly to the screen     *)
(*                                                                            *)
(******************************************************************************)

IMPORT SYSTEM,W:=Win32,String;

CONST
  ACTIVE*=TRUE;

TYPE
  GetDynTypeT*=PROCEDURE (obj:SYSTEM.PTR; VAR txt:ARRAY OF CHAR);
  
VAR
  txt:ARRAY 8000 OF CHAR;  
  getDynType:GetDynTypeT;

PROCEDURE ShowOutput*;
BEGIN
  IF W.MessageBoxA(0,SYSTEM.ADR(txt[0]),SYSTEM.ADR("Debug message"),
                  W.MB_RETRYCANCEL+W.MB_ICONEXCLAMATION+
                  W.MB_APPLMODAL)#W.IDRETRY THEN END;
  txt:="";
END ShowOutput;
  
PROCEDURE WriteLn*;
BEGIN
  String.AppendChar(txt,0AX);
END WriteLn;
  
PROCEDURE WriteStr*(t:ARRAY OF CHAR);
BEGIN
  String.Append(txt,t);
END WriteStr;

PROCEDURE WriteInt*(i:LONGINT);
VAR
  t:ARRAY 30 OF CHAR;
BEGIN
  String.Str(i,t);
  WriteStr(t);
END WriteInt;

PROCEDURE WriteStrInt*(t:ARRAY OF CHAR; i:LONGINT);
BEGIN
  WriteStr(t);
  WriteStr(" ");
  WriteInt(i);
END WriteStrInt;

PROCEDURE WriteDynType*(obj:SYSTEM.PTR);
VAR
  txt:ARRAY 100 OF CHAR;
BEGIN
  getDynType(obj,txt);
  WriteStr("dynamic type:");
  WriteStr(txt);
  WriteStr(" ");
END WriteDynType;

PROCEDURE SetDynTypeProc*(proc:GetDynTypeT);
BEGIN
  txt:="";
  getDynType:=proc;
END SetDynTypeProc;

BEGIN
  getDynType:=NIL;
END Debug.
