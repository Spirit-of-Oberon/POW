(******************************************************************************)
(*                                                                            *)
(**)                        MODULE DebugInfo;                               (**)
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
(* PURPOSE:  Launch creation of debug info                                    *)
(*                                                                            *)
(******************************************************************************)


IMPORT OPM,E:=Error,DebugCV4,DebugCV5;

CONST
  VERSION_CV4*=1;
  VERSION_CV5*=2;

VAR
  version:INTEGER;

PROCEDURE SetModuleBodyCodeStart*(x:LONGINT);
BEGIN
  CASE version OF
    VERSION_CV4:DebugCV4.moduleBodyInfo^.codeDebugStart:=x;
  | VERSION_CV5:DebugCV5.moduleBodyInfo^.codeDebugStart:=x;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugInfo.Write");
  END;
END SetModuleBodyCodeStart;

PROCEDURE SetModuleBodyCodeEnd*(x:LONGINT);
BEGIN
  CASE version OF
    VERSION_CV4:DebugCV4.moduleBodyInfo^.codeDebugEnd:=x;
  | VERSION_CV5:DebugCV5.moduleBodyInfo^.codeDebugEnd:=x;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugInfo.Write");
  END;
END SetModuleBodyCodeEnd;

PROCEDURE SetModuleBodyProcLen*(x:LONGINT);
BEGIN
  CASE version OF
    VERSION_CV4:DebugCV4.moduleBodyInfo^.procLen:=x;
  | VERSION_CV5:DebugCV5.moduleBodyInfo^.procLen:=x;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugInfo.Write");
  END;
END SetModuleBodyProcLen;

PROCEDURE Write*;
(* Write debug information to the object file *)
BEGIN
  CASE version OF
    VERSION_CV4:DebugCV4.Write;
  | VERSION_CV5:DebugCV5.Write;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugInfo.Write");
  END;
END Write;

PROCEDURE Init*(versn:INTEGER; VAR objectFileName-:ARRAY OF CHAR);
BEGIN
  version:=versn;
  CASE version OF
    VERSION_CV4:DebugCV4.Init(objectFileName);
  | VERSION_CV5:DebugCV5.Init(objectFileName);
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugInfo.Init");
  END;
END Init;

BEGIN
  version:=0;
END DebugInfo.
