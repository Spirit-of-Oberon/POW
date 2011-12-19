(******************************************************************************)
(*                                                                            *)
(**)                        MODULE DLLImportList;                           (**)
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
(* PURPOSE:                                                                   *)
(*   This modules maintains a list of those Oberon module names, which have   *)
(*   to be accessed across a DLL boundary if imported.                        *)
(*                                                                            *)
(******************************************************************************)


IMPORT String,OPM,Debug;

TYPE
  ListEle=POINTER TO ListEleT;
  ListEleT=RECORD
    name:OPM.Name;
    next:ListEle;
  END;

VAR
  head:ListEle;

PROCEDURE Init*;
(* needs to be called only once before any compilation run; initializes the list *)
BEGIN
  head:=NIL;
END Init;

PROCEDURE [_APICALL] AddDLLModule*(VAR name-:ARRAY OF CHAR; VAR done:BOOLEAN);
(* add a module to the list. Returns FALSE if this is not possible *)
VAR
  ele:ListEle;
BEGIN
  NEW(ele);
  IF ele#NIL THEN
    COPY(name,ele.name);
    String.UpCase(ele.name);
    ele.next:=head;
    head:=ele;
    done:=TRUE;
  ELSE
    done:=FALSE;
  END;
END AddDLLModule;

PROCEDURE [_APICALL] ClearDLLModules*();
(* empties the list *)
BEGIN
  head:=NIL;
END ClearDLLModules;

PROCEDURE IsFromDLL*(name:ARRAY OF CHAR):BOOLEAN;
(* returns TRUE if the given module name is from across a DLL boundary *)
VAR
  ele:ListEle;
BEGIN
  String.UpCase(name);
  ele:=head;
  WHILE (ele#NIL) & (ele^.name#name) DO ele:=ele^.next END;
  RETURN ele#NIL;
END IsFromDLL;

BEGIN
  Init;
END DLLImportList.
