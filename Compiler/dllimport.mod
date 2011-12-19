(*
  Maintain a list of module names, which have to be accessed across
  a DLL boundary if imported.
*)
MODULE DLLImportList;

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
