(******************************************************************************
 *  Module FileHnd
 *  
 *  This module contains the procedures which read from and write to
 *  text files.
 ******************************************************************************)

MODULE FileHnd;


IMPORT SYSTEM, 
       WU:=WinUser, WD:=WinDef, WB:=WinBase, WN:=WinNT,
       Str:=Strings,
       List:=ListSt, TWin:=TextWin, Options, GlobWin;


CONST 
  FILEPARTLEN=32000;
  CR=0DX;
  LF=0AX;
  EOF=1AX;


VAR
  filepart : ARRAY FILEPARTLEN OF CHAR; 
    (* This variable should be local to LoadFile. It has been declared 
       as a global variable to reduce stack usage. *)
    
(**********************************************************************************************)

PROCEDURE DisplayError(title: ARRAY OF CHAR; msg: ARRAY OF CHAR);
(* zeigt eine Messagebox an mit einer Fehlermeldung *)

VAR r: LONGINT;

BEGIN
  (* Messagebox anzeigen *)
  r := WU.MessageBoxA(WD.NULL, SYSTEM.ADR(msg), SYSTEM.ADR(title), WU.MB_OK);
END DisplayError;

(**********************************************************************************************)

PROCEDURE LoadFile*(hEdit:WD.HWND;name:WD.LPSTR):INTEGER;
(* öffnet bestimmte Datei und lädt sie in den Speicher unter Verwendung des Moduls ListStruct *)
(* Rückgabewert : 1 (erfolgreich), 0 (Fehler)                                                 *)

VAR
  i            : INTEGER; 
  char         : CHAR;
  filepos      : LONGINT;
  pos          : INTEGER;   
  lcnt         : LONGINT;
  hf           : WD.HANDLE;
  buffer       : ARRAY List.MAXLENGTH OF CHAR;
  filename     : ARRAY 100 OF CHAR;
  fplen        : WD.UINT;
  win          : TWin.WinDesc;
  valstr       : ARRAY 10 OF CHAR;
  infostr      : ARRAY 60 OF CHAR;
  infostr2     : ARRAY 30 OF CHAR;
  done         : WD.BOOL;
  dwRead       : WD.DWORD; (* Anzahl der gelesenen Bytes *)
  
  PROCEDURE NextChar(VAR ch:CHAR):BOOLEAN;
  (* liest Datei von Festplatte in Teilen und liefert ein Zeichen *)
  BEGIN
    IF filepos>=FILEPARTLEN THEN (* nächsten Teil lesen *)
        done := WB.ReadFile(hf, SYSTEM.ADR(filepart), FILEPARTLEN, dwRead, WD.NULL);
        IF (dwRead = 0) THEN RETURN FALSE END;
        filepos:=0; (* Position auf 1.Zeichen in filepart setzen *)
    END;
    IF filepos >= dwRead THEN RETURN FALSE END;
    ch:= filepart[filepos]; 
    INC(filepos);
    RETURN TRUE;
  END NextChar;
    
  PROCEDURE PrepExit();
  (* Vorbereitung für plötzliches Exit der Prozedur *)
  BEGIN
    IF (WB.CloseHandle(hf) = 0) THEN
      DisplayError("error in filehandling","could not close file");
    END;
  END PrepExit;
  
BEGIN   
  win:=SYSTEM.VAL(TWin.WinDesc,WU.GetWindowLongA(hEdit,0));
  win.ScreenConfig; 
  lcnt:=0;
  (* POW initialisiert die Listenstruktur bevor Öffnen der Datei durch WM_CREATE Nachricht *)
  hf := WB.CreateFileA(name, WN.GENERIC_READ, 0, NIL, WB.OPEN_EXISTING,
                       WN.FILE_ATTRIBUTE_NORMAL, WD.NULL);

  IF hf = WB.INVALID_HANDLE_VALUE THEN
    DisplayError("Error in MODULE Filehandling","Could not open file for reading");
    RETURN 0;
  END;
  filepos:=FILEPARTLEN; 
  buffer:="";

  pos:=0;
  WHILE NextChar(char) DO
    IF pos >=List.MAXLENGTH THEN   
      Str.Str(LONG(List.MAXLENGTH), valstr);
      infostr:="Line is longer than ";
      infostr2:=" chars. Loading aborted.";
      Str.Append(infostr,valstr);Str.Append(infostr,infostr2);
      GlobWin.DisplayError("Error in MODULE Filehandling",infostr);
      PrepExit;
    END;
    IF char=LF THEN  (* Zeilenende ist erreicht *)
      IF (pos>0) & (buffer[pos-1]=CR) THEN DEC(pos) END;
      buffer[pos]:=0X;
      IF ~win.text.AddLine(buffer) THEN PrepExit; RETURN 0 END;     
      pos:=0;
      INC(lcnt);
    ELSIF (char=09X) & Options.useTabs THEN 
      i:=0;
      WHILE (pos<List.MAXLENGTH-1) & (i<Options.tabsize) DO
        buffer[pos]:=" ";
        INC(pos);
        INC(i);
      END;
    ELSE
      buffer[pos]:=char;      
      INC(pos);
    END;
  END; (* WHILE *)    
  (* Ende der Datei ist erreicht *)
  IF (pos>0) & (buffer[pos-1]=EOF) THEN DEC(pos) END;
  IF pos#0 THEN
    buffer[pos]:= 0X; 
    IF ~win.text.AddLine(buffer) THEN PrepExit; RETURN 0 END;
  END;    
  PrepExit;
  win.ScreenConfig;  (* configure output-preferences *) 
  done := WU.InvalidateRect(hEdit,NIL,WD.True);  
  done := WU.UpdateWindow(hEdit); (* forciert WM_PAINT-Nachricht *)
  win.ShowTextRange(1,win.text.lines);
  RETURN 1;
END LoadFile;

(**********************************************************************************************)

PROCEDURE SaveFile*(hEdit:WD.HWND; name: WD.LPSTR):INTEGER;
(* Speichert bestimmte Datei vom Speicher auf Festplatte *)
(* Rückgabewert : 1 (erfolgreich), 0 (Fehler)            *)
     
VAR 
  hf           : WD.HANDLE;
  len          : LONGINT;
  char         : CHAR;
  buffer       : ARRAY List.MAXLENGTH OF CHAR;
  win          : TWin.WinDesc;
  crlf         : ARRAY 3 OF CHAR;     
  dwWritten    : WD.DWORD;  (* Anzahl geschriebener Bytes *)

BEGIN
  crlf[0]:=CR;
  crlf[1]:=LF;
  crlf[2]:=0X;
  win:=SYSTEM.VAL(TWin.WinDesc,WU.GetWindowLongA(hEdit,0));
 
  hf := WB.CreateFileA(name, WN.GENERIC_WRITE, 0, NIL, WB.CREATE_ALWAYS,
    WN.FILE_ATTRIBUTE_NORMAL, WD.NULL);

  IF hf = WB.INVALID_HANDLE_VALUE THEN
     GlobWin.DisplayError("Error in MODULE Filehandling.","Could not open file for saving. Save aborted.");
     RETURN 0;    
  END;
              
  IF ~(win.text.GetLine( 1, buffer, len)) THEN 
     RETURN 0 END;
      
  IF (WB.WriteFile(hf, SYSTEM.ADR(buffer), len, dwWritten, WD.NULL) = 0) THEN
         GlobWin.DisplayError("Error in MODULE Filehandling","Could not write into opened file");
         RETURN 0; END;
  IF (WB.WriteFile(hf, SYSTEM.ADR(crlf), 2, dwWritten, WD.NULL) = 0) THEN
         GlobWin.DisplayError("Error in MODULE Filehandling","Could not write into opened file");
         RETURN 0; END;     
  
  WHILE win.text.GetNextLine( buffer, len) DO
    (* zeilenweise schreiben in Datei *)
    IF (WB.WriteFile(hf, SYSTEM.ADR(buffer), len, dwWritten, WD.NULL) = 0) THEN
         GlobWin.DisplayError("Error in MODULE Filehandling","Could not write into opened file");
         RETURN 0; END;                 
    (* Zeilenumbruch schreiben *)
    IF (WB.WriteFile(hf, SYSTEM.ADR(crlf), 2, dwWritten, WD.NULL) = 0) THEN
         GlobWin.DisplayError("Error in MODULE Filehandling","Could not write into opened file");
         RETURN 0; END;     
   
  END;    

  IF WB.CloseHandle(hf) = 0 THEN 
      GlobWin.DisplayError("Error in MODULE Filehandling","Could not close specified file");
      RETURN 0;
  END;

  RETURN 1;
    
END SaveFile;

(**********************************************************************************************)
                                          
PROCEDURE GetNextBuffer*(hEdit:WD.HWND; 
                         VAR buf:ARRAY OF CHAR; 
                         size:LONGINT):LONGINT;
(* holt Edit Buffer in Teilen, Maximal size Bytes werden in buf kopiert               *)
(* liefert aktuelle Größe zurück, EOF ist erreicht, wenn zurückgeliefert Wert < Größe *)

VAR
  i,min    : LONGINT;
  len      : LONGINT;
  buffer   : ARRAY List.MAXLENGTH OF CHAR;   
  win      : TWin.WinDesc;

BEGIN
  win:=SYSTEM.VAL(TWin.WinDesc,WU.GetWindowLongA(hEdit,0));
  i:=0;
  IF win.position=-1 THEN
    buf[0]:=0DX;
    buf[1]:=0AX;
    win.position:=0;
    i:=2;
  ELSIF win.position=-2 THEN
    buf[0]:=0AX;
    win.position:=0;
    i:=1;
  ELSIF win.position=-3 THEN
    buf[0]:=0X;
    RETURN 1;
  END;
  IF ~(win.text.GetLine(win.lineNbr, buffer, len)) THEN 
    buf[0]:=0X;
    RETURN 1;
  END;
  WHILE i<size DO
    WHILE (i<size) & (win.position<len) DO
      buf[i]:=buffer[win.position];
      INC(i);
      INC(win.position);
    END;
    IF win.position>=len THEN
      win.position:=0;
      INC(win.lineNbr);
      IF i<size THEN buf[i]:=0DX; INC(i) ELSE win.position:=-1; RETURN i END;
      IF i<size THEN buf[i]:=0AX; INC(i) ELSE win.position:=-2; RETURN i END;
    END;
    IF (i<size) & ~(win.text.GetNextLine(buffer, len)) THEN 
      IF i<size THEN buf[i]:=0X; INC(i) ELSE win.position:=-3 END;
      RETURN i;
    END;  (* last Elem is reached *)
  END;
  RETURN i;
END GetNextBuffer;

(**********************************************************************************************)

PROCEDURE GetFirstBuffer*(hEdit:WD.HWND;VAR buf:ARRAY OF CHAR; size:LONGINT):LONGINT;
(* holt Edit Buffer in Teilen, Maximal size Bytes werden in buf kopiert               *)
(* liefert aktuelle Größe zurück, EOF ist erreicht, wenn zurückgeliefert Wert < Größe *)
(* win.position : 0- : inx in Line Buffer                                             *)
(*                -1 : CR LF fehlen                                                   *)
(*                -2 : LF fehlt                                                       *)
(*                -3 : OX fehlt                                                       *)

VAR 
  win : TWin.WinDesc;
BEGIN
  win:=SYSTEM.VAL(TWin.WinDesc,WU.GetWindowLongA(hEdit,0));
  win.lineNbr :=1;
  win.position:=0;
  RETURN GetNextBuffer(hEdit,buf,size);
END GetFirstBuffer;

END FileHnd.
