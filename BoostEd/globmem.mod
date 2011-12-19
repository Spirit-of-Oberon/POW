(******************************************************************************
 *  Module GlobMem
 *  
 *  This module supports handling of Windows Global Memory objects.
 ******************************************************************************)

MODULE GlobMem;


IMPORT SYSTEM,
       WB:=WinBase, WD:=WinDef, WU:=WinUser,
       List:=ListSt, Strings, GlobWin;


PROCEDURE CopyChar*(globMem:WD.HGLOBAL; ch:CHAR);
(* Globaler Speicherbuffer, kopiert ein Zeichen in globalen Speicher *)
VAR
  lpGlob,inx : LONGINT;
  chx        : CHAR;
BEGIN
  IF globMem=WD.NULL THEN 
    GlobWin.Beep;
    RETURN;
  END;
  lpGlob := WB.GlobalLock(globMem); (* globalen Speicherbereich sperren *)
  ASSERT(lpGlob#WD.NULL);
  inx:=0;
  SYSTEM.GET(lpGlob+inx,chx);
  WHILE (inx<List.MAXLENGTH) & (chx#0X) DO
    INC(inx);
    SYSTEM.GET(lpGlob+inx,chx);
  END;
  IF inx<List.MAXLENGTH THEN
    SYSTEM.PUT(lpGlob+inx,ch);
    SYSTEM.PUT(lpGlob+inx+1,0X);
  ELSE
    GlobWin.Beep;
  END;
  lpGlob := WB.GlobalUnlock(globMem); (* Sperren aufheben *)
END CopyChar;


PROCEDURE NewLineBuf*(VAR globMem:WD.HGLOBAL);
(* globalen Speicherbuffer allokieren ausreichend für eine Zeile und Initialisieren *)
(* mit einem leeren String.                                                         *)
VAR
  lpGlob : LONGINT;
BEGIN
  globMem:=WB.GlobalAlloc(WB.GMEM_MOVEABLE,List.MAXLENGTH+1); (* Speicher allokieren *)
  IF globMem=WD.NULL THEN RETURN END; (* Speicherallokierung erfolglos ? *)
  lpGlob:=WB.GlobalLock(globMem); (* Speicherbereich sperren *)
  ASSERT(lpGlob#WD.NULL);
  SYSTEM.PUT(lpGlob,0X);
  lpGlob:=WB.GlobalUnlock(globMem); (* Sperren aufheben *)
END NewLineBuf;

(**********************************************************************************************)

PROCEDURE InsertChar*(globMem:WD.HGLOBAL; ch:CHAR);
(* ein Zeichen am Beginn des globalen Speicherbuffers einfügen *)
VAR
  lpGlob,i,inx : LONGINT;
  chx          : CHAR;
BEGIN
  IF globMem=WD.NULL THEN 
    GlobWin.Beep;
    RETURN;
  END;
  lpGlob:=WB.GlobalLock(globMem); (* globalen Speicherbereich sperren *)
  ASSERT(lpGlob#WD.NULL);
  inx:=0;
  SYSTEM.GET(lpGlob+inx,chx);
  WHILE (inx<List.MAXLENGTH) & (chx#0X) DO
    INC(inx);
    SYSTEM.GET(lpGlob+inx,chx);
  END;
  IF inx<List.MAXLENGTH THEN
    FOR i:=inx TO 0 BY -1 DO
      SYSTEM.GET(lpGlob+i,chx);
      SYSTEM.PUT(lpGlob+i+1,chx);
    END;
    SYSTEM.PUT(lpGlob,ch);
  ELSE
    GlobWin.Beep;
  END;
  lpGlob:=WB.GlobalUnlock(globMem); (* Sperren aufheben *)
END InsertChar;


PROCEDURE CopyString*(globMem:WD.HGLOBAL; txt:ARRAY OF CHAR);
(* einen String samt Carriage Return in einen globalen Speicherbuffer kopieren *)
VAR
  lpGlob,len : LONGINT;
BEGIN
  IF globMem=WD.NULL THEN 
    GlobWin.Beep;
    RETURN;
  END;
  lpGlob:=WB.GlobalLock(globMem); (* Speicherbereich sperren *)
  ASSERT(lpGlob#WD.NULL);
  len:=Strings.Length(txt);
  IF len>List.MAXLENGTH-2 THEN
    len:=List.MAXLENGTH-2;
    GlobWin.Beep;
  END;
  SYSTEM.MOVE(SYSTEM.ADR(txt),lpGlob,len);
  INC(lpGlob,len);
  SYSTEM.PUT(lpGlob,0DX); INC(lpGlob);
  SYSTEM.PUT(lpGlob,0AX); INC(lpGlob);
  SYSTEM.PUT(lpGlob,0X);
  lpGlob:=WB.GlobalUnlock(globMem);  (* Sperren aufheben *)
END CopyString;

END GlobMem.


