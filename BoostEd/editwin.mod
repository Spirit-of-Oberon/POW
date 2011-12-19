(******************************************************************************
 *  Module EditWin
 *  
 *  This module contains the implementation of the EditWinT class.
 *  The EditWinT class extends the TextWin.WinDescT class with the
 *  following functionality:
 *    undo/redo
 *    cut and copy to clipboard
 *    cursor movement with selection of text
 *    search for text
 ******************************************************************************)

MODULE EditWin;


IMPORT SYSTEM,
       WU:=WinUser, WD:=WinDef, WB:=WinBase,
       TWin:=TextWin, List:=ListSt, Strings, Syntax, Options, GlobMem, GlobWin;


TYPE
  EditWinT* = RECORD (TWin.WinDescT)             (* enthält Verweis Textfensterdaten *) 
  END;
  EditWin *= POINTER TO EditWinT; (* Zeiger auf EditWinT *)
  
PROCEDURE^ (VAR win:EditWinT) CursGoto*(row, col:LONGINT);

(*********************************************************************************************)
  
PROCEDURE AssocWinObj*(hWnd:WD.HWND):EditWin;
(* liefert einen Zeiger auf ein Fester, daß sich auf ein gegebenes *)
(* MS Windows-Fenster bezieht                                      *)
BEGIN
  RETURN SYSTEM.VAL(EditWin,WU.GetWindowLongA(hWnd,0));
END AssocWinObj;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CutSelectionFromScreen*():BOOLEAN;
(* schneidet den selektierten Text vom Bildschirm aus                       *)
(* Rückgabewert : TRUE (erfolgreich), FALSE (nichts ausgewählt oder Fehler) *)

VAR 
  rowCounter,len   : LONGINT;
  nonDelLine       : LONGINT;  
  i,dist,Y,dmyi    : LONGINT;
  reslt            : WD.LRESULT;
  emptybuf,txt,buf : ARRAY List.MAXLENGTH+1 OF CHAR;
  dmyb             : BOOLEAN;
  retval           : BOOLEAN;  (* Rückgabewert *)

BEGIN
  retval:=TRUE; (* Rückgabewert initialisieren *)
  nonDelLine:=0;    
  IF win.text.markStart.row = win.text.markEnd.row THEN (* eine Zeile ist selektiert *)
    retval:=win.text.DeleteInLine(win.text.markStart.col,
                                  win.text.markEnd.col-win.text.markStart.col,
                                  win.text.markStart.row);

  ELSE (* mehrere Zeilen sind selektiert *)

    rowCounter:=win.text.markEnd.row-win.text.markStart.row+1;
    IF ~win.text.GetLine(win.text.markStart.row, txt, len) THEN 
      retval:=FALSE;
    END;
    IF win.text.markStart.col=1 THEN (* ganze Zeile löschen *) 
      IF ~win.text.DeleteLine(win.text.markStart.row) THEN 
        retval:=FALSE;
      END;
      nonDelLine:=0;
    ELSE  (* Teil einer Zeile löschen *)         
      IF ~(win.text.DeleteInLine(win.text.markStart.col,
                                 len-win.text.markStart.col+1,
                                 win.text.markStart.row)) THEN 
        retval:=FALSE; 
      END;
      nonDelLine:=1;
    END;    
    DEC(rowCounter);
    WHILE (rowCounter#1) & retval DO
      IF ~win.text.DeleteLine(win.text.markStart.row+nonDelLine) THEN 
        retval:=FALSE;
      END;
      DEC(rowCounter);
    END;
    IF ~win.text.DeleteInLine(1,win.text.markEnd.col-1,
                              win.text.markStart.row+nonDelLine) THEN 
      retval:=FALSE;
    END;
    IF (nonDelLine=1) & ~win.text.MergeLines(win.text.markStart.row) THEN 
      retval:=FALSE;
    END;
  END;
  rowCounter:=0;
  win.text.InvalidateMarkArea;
  win.changed:=TRUE;
  reslt:=WU.SendMessageA(WU.GetParent(win.hwnd),List.PEM_SHOWCHANGED,1,0);
  win.col:=win.text.markStart.col;
  win.row:=win.text.markStart.row;
  IF win.text.markStart.row#win.text.markEnd.row THEN
    win.ShowTextRange(win.text.markStart.row,win.text.lines);
    win.UpdateVerScrollBar;
  ELSE                                  (* only within one line *)
    win.ShowTextLine(win.text.markStart.row);
  END;
  IF ~win.RowVisible(win.row) OR ~win.ColVisible(win.col) THEN 
    win.CursGoto(win.row,win.col);
  ELSE
    win.SetCaret;
  END;
  RETURN retval;
END CutSelectionFromScreen;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) SelectionToGlobMem*(VAR globMem:WD.HGLOBAL):BOOLEAN;
(* globalen Speicher allokieren und selektierten Text dorthin kopieren     *)
(* Rückgabewert : TRUE (erfolgreich), FALSE (nichts ausgewählt oder Fehler *)

VAR
  len,lpGlob,dummy,size : LONGINT;
  txt                   : ARRAY List.MAXLENGTH+1 OF CHAR;

BEGIN
  globMem:=0;
  size:=win.text.GetMarkedTextSize(); (* Größe des selektierten Textes ermitteln *)
  IF size=0 THEN RETURN FALSE END;
  size:=size+1+List.MAXLENGTH; (* +List.MAXLENGTH wegen Undo Operationen *)
  (* Speicher allozieren *)
  globMem:=WB.GlobalAlloc(WB.GMEM_FIXED,size);
  IF globMem=WD.NULL THEN (* Speicherplatzanforderung erfolgreich ? *)
    GlobWin.Beep;
    RETURN FALSE;
  END;
  lpGlob:=WB.GlobalLock(globMem); (* globales Speicherobjekt sperren *)
  ASSERT(lpGlob#WD.NULL);
  IF ~win.text.GetFirstMarkedLine(txt) THEN
    dummy:=WB.GlobalUnlock(globMem); (* Sperre aufheben *) 
    globMem:=WB.GlobalFree(globMem); (* Speicherobjekt freigeben *)
    RETURN FALSE;
  END;
  len:=Strings.Length(txt);
  SYSTEM.MOVE(SYSTEM.ADR(txt),lpGlob,len);
  INC(lpGlob,len);
  WHILE win.text.GetNextMarkedLine(txt) DO
    SYSTEM.PUT(lpGlob,0DX); INC(lpGlob);
    SYSTEM.PUT(lpGlob,0AX); INC(lpGlob);
    len:=Strings.Length(txt);
    SYSTEM.MOVE(SYSTEM.ADR(txt),lpGlob,len);
    INC(lpGlob,len);
  END;
  SYSTEM.PUT(lpGlob,0X);
  dummy:=WB.GlobalUnlock(globMem);  
  RETURN TRUE;
END SelectionToGlobMem;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) FreeUndoBuffer*();
(* Undo Buffer freigeben *)
BEGIN
  IF win.undoData#WD.NULL THEN
    win.undoData:=WB.GlobalFree(win.undoData);
  END;
END FreeUndoBuffer;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) SetUndoAction*(action:LONGINT);
(* Undo Action Code setzen, aktuelle Zeile und Spalte merken und alten Buffer freigeben *)

BEGIN
  win.FreeUndoBuffer;
  win.undoRow:=win.row;
  win.undoCol:=win.col;
  win.undoToRow:=1;
  win.undoToCol:=1;
  win.undoAction:=action;
  win.undo:=TRUE;
  win.undoLen:=0;
END SetUndoAction;

(*********************************************************************************************)

(* CURSOR - BEWEGUNGEN *)

PROCEDURE (VAR win:EditWinT) CursMovePrepare(mark,down:BOOLEAN);
(* Vorbereitung für Cursorbewegung *)
VAR
  len,col : LONGINT;
  done    : WD.BOOL;

BEGIN
  IF win.text.lines=0 THEN RETURN END;
  IF mark THEN
    IF win.text.isSelected THEN 
    ELSE
      win.markDown:=down;
      IF ~win.text.GetLineLength(win.row,len) THEN RETURN END;
      col:=win.col;
      IF col>len THEN col:=len+1 END;
      win.text.SetMarkArea(win.row,col,win.row,col);
    END;
  ELSE
    IF win.text.isSelected THEN 
      win.text.InvalidateMarkArea;
      done := WU.InvalidateRect(win.hwnd, NIL, 0); (* Aktualisierungsbereich festlegen *)
    END;
  END;
END CursMovePrepare;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursMoveFinish;
(* Cursorbewegung abschließen *)
VAR
  col,len  : LONGINT;
  dummy    : LONGINT;
BEGIN
  IF win.text.isSelected THEN
    IF ~win.text.GetLineLength(win.row,len) THEN RETURN END;
    col:=win.col;
    IF col>len+1 THEN col:=len+1 END;
    win.MarkUpdate(win.row,col);
  END;
  IF ~win.RowVisible(win.row) THEN
    win.textPos:=win.row-win.lineNo DIV 2;
    IF win.textPos<1 THEN win.textPos:=1 END;
    win.ShowTextRange(1,win.text.lines);
  END;
  win.CheckHorzScrollPos;
  win.UpdateHorScrollBar;
  win.UpdateVerScrollBar;
  win.SetCaret;
  (* Nachricht senden *)
  dummy:=WU.SendMessageA(WU.GetParent(win.hwnd),
                       List.PEM_SHOWLINER,
                       SYSTEM.VAL(WD.WPARAM,win.col),
                       SYSTEM.VAL(WD.LPARAM,win.row));
END CursMoveFinish;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursRight*(mark:BOOLEAN);
(* Cursor nach rechts *)
BEGIN
  win.CursMovePrepare(mark,TRUE);
  IF win.col<List.MAXLENGTH-1 THEN INC(win.col) ELSE 
    GlobWin.Beep;
  END;
  win.CursMoveFinish;
END CursRight;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursLeft*(mark:BOOLEAN);
(* Cursor nach links *)
BEGIN
  win.CursMovePrepare(mark,FALSE);
  IF win.col>1 THEN DEC(win.col) ELSE 
    GlobWin.Beep;
  END;
  win.CursMoveFinish;
END CursLeft;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursUp*(mark:BOOLEAN);
(* Cursor nach oben *)
BEGIN
  win.CursMovePrepare(mark,FALSE);
  IF win.row>1 THEN DEC(win.row) ELSE 
    GlobWin.Beep;
  END;
  IF win.textPos>win.row THEN win.VerScroll(-1) END;
  win.CursMoveFinish;
END CursUp;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursDown*(mark:BOOLEAN);
(* Cursor nach unten *)
BEGIN
  win.CursMovePrepare(mark,TRUE);
  IF win.row<win.text.lines THEN INC(win.row) ELSE 
    GlobWin.Beep;
  END;
  IF win.textPos+win.lineNo-2<win.row THEN win.VerScroll(1) END;
  win.CursMoveFinish;
END CursDown;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursPgUp*(mark:BOOLEAN);
(* Cursor Seite nach oben *)
BEGIN
  win.CursMovePrepare(mark,FALSE);
  DEC(win.textPos,win.lineNo-1);
  IF win.textPos<1 THEN win.textPos:=1 END;
  DEC(win.row,win.lineNo-1);
  IF win.row<1 THEN win.row:=1 END;
  win.ShowTextRange(1,win.text.lines);
  win.CursMoveFinish;
END CursPgUp;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursPgDn*(mark:BOOLEAN);
(* Cursor Seite nach unten *)
BEGIN
  win.CursMovePrepare(mark,TRUE);
  INC(win.textPos,win.lineNo-1);
  IF win.textPos>win.text.lines-win.lineNo+3 THEN 
    win.textPos:=win.text.lines-win.lineNo+3;
    IF win.textPos<1 THEN win.textPos:=1 END;
  END;
  INC(win.row,win.lineNo-1);
  IF win.row>win.text.lines THEN win.row:=win.text.lines END;
  win.ShowTextRange(1,win.text.lines);
  win.CursMoveFinish;
END CursPgDn;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursPos1*(mark:BOOLEAN);
(* Cursor an Beginn einer Zeile *)
BEGIN
  win.CursMovePrepare(mark,FALSE);
  win.col:=1;
  win.CursMoveFinish;
END CursPos1;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursEnd*(mark:BOOLEAN);
(* Cursor an Ende einer Zeile *)
VAR
  len : LONGINT;
BEGIN
  IF ~win.text.GetLineLength(win.row,len) THEN RETURN END;
  win.CursMovePrepare(mark,TRUE);
  win.col:=len+1;
  win.CursMoveFinish;
END CursEnd;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursTextStart*(mark:BOOLEAN);
(* Cursor an Beginn des Textes *)
BEGIN
  win.CursMovePrepare(mark,FALSE);
  win.textPos:=1;
  win.row:=1;
  win.col:=1;
  win.ShowTextRange(1,win.text.lines);
  win.CursMoveFinish;
END CursTextStart;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursTextEnd*(mark:BOOLEAN);
(* Cursor an Ende des Textes *)
VAR
  len : LONGINT;
BEGIN
  IF ~win.text.GetLineLength(win.text.lines,len) THEN RETURN END;
  win.CursMovePrepare(mark,TRUE);
  win.textPos:=win.text.lines-win.lineNo+3;
  IF win.textPos<1 THEN win.textPos:=1 END;
  win.row:=win.text.lines;
  win.col:=len+1;
  win.ShowTextRange(1,win.text.lines);
  win.CursMoveFinish;
END CursTextEnd;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursIdentRight*(mark:BOOLEAN);
(* Cursor an Ende eines Wortes *)
VAR
  len,pos : LONGINT;
  txt     : ARRAY List.MAXLENGTH OF CHAR;
BEGIN
  IF ~win.text.GetLine(win.row,txt,len) THEN RETURN END;
  win.CursMovePrepare(mark,TRUE);
  pos:=win.col-1;
  WHILE (pos<len) & Syntax.IsIdentChar(txt[pos]) DO INC(pos) END;
  WHILE (pos<len) & ~Syntax.IsIdentChar(txt[pos]) DO INC(pos) END;
  win.col:=pos+1;
  win.CursMoveFinish;
END CursIdentRight;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursIdentLeft*(mark:BOOLEAN);
(* Cursor an Beginn eines Wortes *)
VAR
  len,pos : LONGINT;
  txt     : ARRAY List.MAXLENGTH OF CHAR;
BEGIN
  IF ~win.text.GetLine(win.row,txt,len) THEN RETURN END;
  win.CursMovePrepare(mark,FALSE);
  pos:=win.col-2;
  IF pos>len THEN pos:=len-1 END;
  WHILE (pos>=0) & ~Syntax.IsIdentChar(txt[pos]) DO DEC(pos) END;
  WHILE (pos>=0) & Syntax.IsIdentChar(txt[pos]) DO DEC(pos) END;
  win.col:=pos+2;
  win.CursMoveFinish;
END CursIdentLeft;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) CursGoto*(row, col:LONGINT);
(* Cursor an eine bestimmte Stelle im Fenster setzen (Zeile / Spalte)        *)
(* Zahlen beginnen mit 1, bei Zeile = -1 oder Spalte = -1 an Ende des Textes *)
BEGIN
  IF ((row=-1) & (col=-1)) THEN
    win.CursTextEnd(FALSE);
  ELSE
    IF row>win.text.lines THEN row:=win.text.lines
    ELSIF row<1 THEN row:=1 END;
    IF col>List.MAXLENGTH-1 THEN col:=List.MAXLENGTH-1
    ELSIF col<1 THEN col:=1 END;
    win.CursMovePrepare(FALSE,FALSE);
    win.row:=row;
    win.col:=col;
    win.CursMoveFinish;
  END;
END CursGoto;

(*********************************************************************************************)

(* SONDERTASTEN *)

PROCEDURE (VAR win:EditWinT) DeleteChar*():BOOLEAN;
(* Zeichen löschen *)
VAR 
  i,len,dmyi     : LONGINT;
  buf,buf2       : ARRAY List.MAXLENGTH OF CHAR;
  spacebuf       : ARRAY 3 OF CHAR;
  done,dmyb      : BOOLEAN;
  reslt          : WD.LRESULT;
  nestingChanged : BOOLEAN;

BEGIN
  done:=TRUE;
  IF win.text.lines=0 THEN 
    GlobWin.Beep;
    RETURN FALSE;
  END;
  IF win.text.isSelected THEN  (* irgendetwas selektiert ? *)
    win.SetUndoAction(TWin.ACT_CUT);
    win.undoRow:=win.text.markStart.row;
    win.undoCol:=win.text.markStart.col;
    done:=win.SelectionToGlobMem(win.undoData);
    IF ~done THEN 
      win.SetUndoAction(TWin.ACT_NONE);
      GlobWin.Beep;
    END;
    done:=win.CutSelectionFromScreen();
    RETURN TRUE;
  END;
  IF ~win.text.GetLine(win.row, buf, len) THEN RETURN FALSE END;
  IF win.col>len THEN (* leere Zeile, Zeilen nachziehen *)
    win.SetUndoAction(TWin.ACT_MERGELINE);
    FOR i:=len TO win.col-2 DO buf[i]:=" " END;
    len:=win.col-1;
    buf[len]:=0X;
    IF Options.smartDel  THEN
      IF win.text.GetLine(win.row+1,buf2,len) THEN
        IF buf2[0]=" " THEN Strings.AppendChar(buf," ") END;
        Strings.RemoveLeadingSpaces(buf2);
        done:=win.text.SetLine(win.row+1, buf2);
      END;
    END;
    IF ~win.text.SetLine(win.row,buf) THEN RETURN FALSE END;
    done:=win.text.MergeLines(win.row);
    win.ShowTextRange(win.row,win.text.lines);
  ELSE                             
    IF (win.undoAction#TWin.ACT_DELCHAR) OR ~win.undo OR
       (win.undoRow#win.row) OR (win.undoCol#win.col) THEN 
      win.SetUndoAction(TWin.ACT_DELCHAR);
      GlobMem.NewLineBuf(win.undoData);
    END;
    INC(win.undoLen);
    GlobMem.CopyChar(win.undoData,buf[win.col-1]);  
    i:=win.col;
    FOR i:=win.col TO len DO buf[i-1]:=buf[i] END;
    DEC(len);
    buf[len]:=0X;
    dmyb:=win.text.SetLineEx(win.row, buf,nestingChanged);
    ASSERT(dmyb);
    IF Options.colorComments & nestingChanged THEN
      win.ShowTextRange(win.row,win.text.lines);
    ELSE
      win.ShowTextLine(win.row);
    END;
  END;
  (* Nachricht senden *)
  reslt:=WU.SendMessageA(WU.GetParent(win.hwnd),List.PEM_SHOWLINER,SYSTEM.VAL(WD.WPARAM,win.col),
         SYSTEM.VAL(WD.LPARAM,win.row));
  win.changed:=TRUE;       
  RETURN done;
END DeleteChar;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) Key_Back*():BOOLEAN;
(* Backspace *)
VAR 
  y,i,len,len2,dmyi  : LONGINT;
  buf                : ARRAY List.MAXLENGTH OF CHAR;
  spacebuf           : ARRAY 3 OF CHAR;
  done,blanks,dmyb   : BOOLEAN;
  reslt              : WD.LRESULT;
  nestingChanged     : BOOLEAN;

BEGIN
  IF win.text.isSelected THEN  (* irgendetwas selektiert ? *)
    win.SetUndoAction(TWin.ACT_CUT);
    win.undoRow:=win.text.markStart.row;
    win.undoCol:=win.text.markStart.col;
    done:=win.SelectionToGlobMem(win.undoData);
    IF ~done THEN 
      win.SetUndoAction(TWin.ACT_NONE);
      GlobWin.Beep;
    END;
    done:=win.CutSelectionFromScreen();
    RETURN TRUE;
  END;
  IF (win.col=1) & (win.row=1) THEN 
      GlobWin.Beep;
      RETURN FALSE;
  END;
  IF (win.col>1) & (win.text.lines=0) THEN  (* Leerzeichen in erster Zeile löschen *)
    DEC(win.col);
    win.SetCaret;
    RETURN FALSE;
  END;
  dmyb:=win.text.GetLine(win.row,buf,len);
  ASSERT(dmyb);
  IF win.col>len+1 THEN  (* nicht in der Zeile *)
    DEC(win.col);
    win.SetCaret;
  ELSIF (win.col>1) & (win.col<=len+1) THEN (* zwischen 1 und len+1 *)
    IF (win.undoAction#TWin.ACT_DELCHAR) OR ~win.undo OR
       (win.undoRow#win.row) OR (win.undoCol#win.col) THEN 
      win.SetUndoAction(TWin.ACT_DELCHAR);
      GlobMem.NewLineBuf(win.undoData);
    END;
    GlobMem.InsertChar(win.undoData,buf[win.col-2]);  
    INC(win.undoLen);
    i:=win.col;
    FOR i:=win.col TO len+1 DO  (* vorhergehendes Zeichen löschen *)
      buf[i-2]:=buf[i-1];
    END;
    DEC(win.col);
    DEC(win.undoCol);
    DEC(len);
    dmyb:=win.text.SetLineEx(win.row, buf,nestingChanged);
    ASSERT(dmyb);
    IF Options.colorComments & nestingChanged THEN
      win.ShowTextRange(win.row,win.text.lines);
    ELSE
      win.ShowTextLine(win.row);
    END;
    spacebuf:="  ";
    win.SetCaret;
  ELSIF (win.col=1) & (win.row>1) THEN (* Zeile nachziehen *)
    win.SetUndoAction(TWin.ACT_MERGELINE);
    IF Options.smartDel THEN
      blanks:=buf[0]=" ";
      Strings.RemoveLeadingSpaces(buf);
      done:=win.text.SetLine(win.row, buf);
      IF win.text.GetLine(win.row-1,buf,len2) THEN
        Strings.RemoveTrailingSpaces(buf);
        IF blanks THEN Strings.AppendChar(buf," ") END;
        len2:=Strings.Length(buf);
        done:=win.text.SetLine(win.row-1,buf);
      END;
    ELSE
      done:=win.text.GetLineLength(win.row-1,len2);
    END;
    done:=win.text.MergeLines(win.row-1); 
    DEC(win.row);
    win.col:=len2+1;
    win.SetCaret;
    IF win.textPos>win.row THEN  (* scroll ? *)
      DEC(win.textPos);
    END;
    win.ShowTextRange(win.row,win.text.lines);
  END;  
  (* Nachricht senden *)
  reslt:=WU.SendMessageA(WU.GetParent(win.hwnd),
                       List.PEM_SHOWLINER,
                       SYSTEM.VAL(WD.WPARAM,win.col),
                       SYSTEM.VAL(WD.LPARAM,win.row));
  RETURN TRUE;
END Key_Back;
 
(*********************************************************************************************)
 
PROCEDURE (VAR win:EditWinT) Key_Tab*():BOOLEAN;
(* Tabulator gedrückt *)
VAR 
  i,len,len2,dmyi   : LONGINT;
  buf               : ARRAY List.MAXLENGTH OF CHAR;
  dmyb,update       : BOOLEAN;
  reslt             : WD.LRESULT;    
  nestingChanged    : BOOLEAN;
BEGIN
  nestingChanged:=FALSE;
  win.SetUndoAction(TWin.ACT_NONE);
  IF Options.tabsize=0 THEN RETURN FALSE END;
  update:=win.text.GetLine( win.row, buf,len);
  IF Options.tabsize+len>List.MAXLENGTH-1 THEN RETURN FALSE END;
  IF win.col<=len THEN  (* in Textbereich *)
    FOR i:=len TO win.col BY -1 DO
      buf[i+Options.tabsize-1]:=buf[i-1];
    END;
    FOR i:=1 TO Options.tabsize DO
      buf[win.col+i-2]:=" ";
    END;
    buf[len+Options.tabsize]:=0X;
    len:=len+Options.tabsize;
    IF update THEN
      dmyb:=win.text.SetLineEx(win.row, buf,nestingChanged);
    ELSE
      dmyb:=win.text.AddLine(buf);
    END;
    ASSERT(dmyb);
  END;
  win.col:= win.col+Options.tabsize;
  IF Options.colorComments & nestingChanged THEN
    win.ShowTextRange(win.row,win.text.lines);
  ELSE
    win.ShowTextLine(win.row);
  END;
  win.SetCaret;
  (* Nachricht senden *)
  reslt:=WU.SendMessageA(WU.GetParent(win.hwnd),List.PEM_SHOWLINER,SYSTEM.VAL(WD.WPARAM,win.col),
         SYSTEM.VAL(WD.LPARAM,win.row));
  RETURN TRUE;
END Key_Tab;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) Key_Return*;
(* Return Taste gedrückt *)
VAR 
  txt                   : ARRAY List.MAXLENGTH OF CHAR;
  spaces,i,splitAt,len  : LONGINT;
  done,noNewLine        : BOOLEAN;

BEGIN
  IF win.text.lines=0 THEN
    win.SetUndoAction(TWin.ACT_NONE);
    txt:="";
    len:=0;
    done:=win.text.AddLine(txt);
  ELSE
    win.SetUndoAction(TWin.ACT_SPLITLINE);
    done:=win.text.GetLine(win.row,txt,len);
  END;
  IF ~done THEN 
    win.SetUndoAction(TWin.ACT_NONE); 
    GlobWin.Beep;
    RETURN;
  END;
  spaces:=0; 
  IF Options.autoIndent THEN
    WHILE txt[spaces]=" " DO INC(spaces) END;
  END;
  IF win.col<=len THEN
    IF Options.autoIndent & (win.col<=spaces) THEN 
      txt:="";
      done:=win.text.InsertLine(txt,win.row);
    ELSE
      win.undoLen:=spaces;
      done:=win.text.SplitLine(win.row,win.col-1,spaces);
    END;
    win.CursGoto(win.row+1,spaces+1);
  ELSE
    IF Options.syntax THEN Syntax.Analyze(win.row,win.text,noNewLine) END;
    IF ~noNewLine THEN
      FOR i:=0 TO spaces-1 DO txt[i]:=" " END;
      txt[spaces]:=0X;
      IF win.text.lines#0 THEN
        done:=win.text.InsertLine(txt,win.row+1);
      ELSE   
        done:=win.text.AddLine(txt);
      END;
    END;
    win.CursDown(FALSE);
    win.CursEnd(FALSE);
  END;
  win.ShowTextRange(win.row-1,win.text.lines);
  IF ~done THEN 
    GlobWin.Beep;
  END;
END Key_Return; 

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) Key_Char*(ch:CHAR);
(* Zeichen eingegeben *)
VAR 
  done           : BOOLEAN;
  i,len          : LONGINT;
  txt            : ARRAY List.MAXLENGTH OF CHAR;
  nestingChanged : BOOLEAN;

BEGIN
  IF win.text.lines=0 THEN
    txt:="";
    len:=0;
    done:=win.text.AddLine(txt);
  ELSE
    done:=win.text.GetLine(win.row,txt,len);
  END;
  IF ~done THEN 
    GlobWin.Beep;
    RETURN;
  END;
  IF ~win.RowVisible(win.row) THEN win.CursGoto(win.row,win.col) END;
  IF Options.insert THEN      
    IF (win.undoAction#TWin.ACT_INSERTCHAR) OR 
       (win.undoRow#win.row) OR (win.undoCol+win.undoLen#win.col) THEN
      IF (win.undoAction=TWin.ACT_OVERWRITESELECTION) & 
         (win.undoRow=win.row) & (win.undoCol=win.col) THEN
        win.undoAction:=TWin.ACT_INSERTCHAR;
        win.undoLen:=0;
      ELSE
        win.SetUndoAction(TWin.ACT_INSERTCHAR);
        GlobMem.NewLineBuf(win.undoData);
      END;
    END;
  ELSE
    IF (win.undoAction#TWin.ACT_OVERWRITECHAR) OR 
       (win.undoRow#win.row) OR (win.undoCol+win.undoLen#win.col) THEN
      win.SetUndoAction(TWin.ACT_OVERWRITECHAR);
      GlobMem.NewLineBuf(win.undoData);
    END;
  END;
  IF win.col<=len THEN
    IF Options.insert THEN      
      FOR i:=len TO win.col-1 BY -1 DO txt[i+1]:=txt[i] END;
    ELSE
      GlobMem.CopyChar(win.undoData,txt[win.col-1]);  
    END;
    INC(win.undoLen);
    txt[win.col-1]:=ch;
    txt[len+1]:=0X;
  ELSIF win.col<List.MAXLENGTH THEN
    IF ~Options.insert THEN GlobMem.CopyChar(win.undoData," ") END;
    INC(win.undoLen);
    FOR i:=len TO win.col-2 DO txt[i]:=" " END;
    txt[win.col-1]:=ch;
    txt[win.col]:=0X;
  ELSE
    GlobWin.Beep;
  END;
  IF ~win.text.SetLineEx(win.row,txt,nestingChanged) THEN 
    GlobWin.Beep;
  END;
  IF Options.colorComments & nestingChanged THEN
    win.ShowTextRange(win.row,win.text.lines);
  ELSE
    win.ShowTextLine(win.row);                     
  END;
  win.CursRight(FALSE);
END Key_Char;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) DeleteLine*;
(* Zeile löschen *)
BEGIN
  win.DeleteLine^;
  IF win.row>win.text.lines THEN win.CursUp(FALSE) END;
END DeleteLine;

(*********************************************************************************************)

(* UNDO / REDO FUNKTIONALITÄT *)

PROCEDURE (VAR win:EditWinT) Undo*;
(* letztes Kommando zurücknehmen *)
VAR
  txt,buf      : ARRAY List.MAXLENGTH+1 OF CHAR;
  len,i        : LONGINT;
  lpGlob       : LONGINT;
  ch           : CHAR;
  done         : BOOLEAN;
  tmpBuf       : WD.HANDLE;
  
  PROCEDURE CursGotoUndo;
  BEGIN
    win.row:=win.undoRow;
    win.col:=win.undoCol;
    IF ~win.RowVisible(win.row) THEN 
      win.CursGoto(win.row,win.col);
    ELSE
      win.SetCaret;
    END;
  END CursGotoUndo;

BEGIN
  IF win.undoAction=TWin.ACT_NONE THEN 
    GlobWin.Beep;
    RETURN;
  END;
  IF win.undo THEN
    win.undo:=FALSE;
    CASE win.undoAction OF
    | TWin.ACT_PASTE:
        win.text.SetMarkArea(win.undoRow,win.undoCol,win.undoToRow,win.undoToCol);
        done:=win.CutSelectionFromScreen();
        win.row:=win.undoRow;
        win.col:=win.undoCol;
        IF win.undoData#0 THEN done:=win.InsertGlobMem(win.undoData) END;
        win.ShowTextRange(1,win.text.lines);
    
    | TWin.ACT_CUT,TWin.ACT_OVERWRITESELECTION:
        win.row:=win.undoRow;
        win.col:=win.undoCol;
        IF win.undoData#0 THEN 
          done:=win.InsertGlobMem(win.undoData);
          IF ~done THEN 
            GlobWin.Beep;
          END;
        END;
        win.ShowTextRange(1,win.text.lines);
    
    | TWin.ACT_DELCHAR:
        IF win.text.GetLine(win.undoRow,txt,len) THEN
          FOR i:=len+win.undoLen TO win.undoCol+win.undoLen-1 BY -1 DO 
            txt[i]:=txt[i-win.undoLen];
          END;
          lpGlob:=WB.GlobalLock(win.undoData); (* Speicherbereich sperren *)
          ASSERT(lpGlob#WD.NULL);
          FOR i:=win.undoCol-1 TO win.undoCol+win.undoLen-2 DO
            SYSTEM.GET(lpGlob,txt[i]);
            INC(lpGlob);
          END;
          lpGlob:=WB.GlobalUnlock(win.undoData); (* Sperre aufheben *)
          IF win.text.SetLine(win.undoRow, txt) THEN 
            CursGotoUndo;
            win.ShowTextLine(win.undoRow);
          ELSE
            GlobWin.Beep;
          END;
        END;
    
    | TWin.ACT_MERGELINE:
        CursGotoUndo;
        GlobWin.Beep;

    | TWin.ACT_SPLITLINE:
        CursGotoUndo;
        IF win.text.GetLine(win.row+1,buf,len) THEN
          i:=0;
          WHILE (i<win.undoLen) & (buf[i]=" ") DO INC(i) END;
          Strings.Delete(buf,1,i);
          done:=win.text.SetLine(win.row+1, buf);
        END;
        done:=win.text.MergeLines(win.row); 
        win.ShowTextRange(win.row,win.text.lines);
        
    | TWin.ACT_DELLINE:
        win.row:=win.undoRow;
        win.col:=1;
        IF ~win.InsertGlobMem(win.undoData) THEN 
          GlobWin.Beep;
        END;
        CursGotoUndo;
        
    | TWin.ACT_INSERTCHAR:    (* undoLen contains number of inserted characters *)
        IF win.text.GetLine(win.undoRow,txt,len) THEN
          GlobMem.NewLineBuf(tmpBuf);
          FOR i:=win.undoCol-1 TO win.undoCol+win.undoLen-2 DO GlobMem.CopyChar(tmpBuf,txt[i]) END;
          FOR i:=win.undoCol+win.undoLen-1 TO len DO txt[i-win.undoLen]:=txt[i] END;
          txt[len-win.undoLen]:=0X;
          IF win.text.SetLine(win.undoRow, txt) THEN
            CursGotoUndo;
            IF win.undoData#0 THEN
              win.text.markStart.row:=win.row;
              win.text.markStart.col:=win.col;
              win.markDown:=TRUE;
              done:=win.InsertGlobMem(win.undoData);
              win.MarkUpdate(win.row,win.col);
              IF ~done THEN 
                GlobWin.Beep;
              END;
              win.FreeUndoBuffer;
            END;
            win.undoData:=tmpBuf;  
            win.ShowTextLine(win.undoRow);
          ELSE
            GlobWin.Beep;
          END;
        ELSE
          GlobWin.Beep;
        END;
        
    | TWin.ACT_OVERWRITECHAR: (* undoLen enthält Anzahl der überschriebenen Zeichen *)
        IF win.text.GetLine(win.undoRow,txt,len) THEN
          lpGlob:=WB.GlobalLock(win.undoData); (* Speicherbereich sperren *)
          ASSERT(lpGlob#WD.NULL);
          FOR i:=win.undoCol-1 TO win.undoCol+win.undoLen-2 DO 
            ch:=txt[i];
            SYSTEM.GET(lpGlob,txt[i]);
            SYSTEM.PUT(lpGlob,ch);
            INC(lpGlob);
          END;
          lpGlob:=WB.GlobalUnlock(win.undoData); (* Sperren aufheben *)
          IF win.text.SetLine(win.undoRow, txt) THEN 
            CursGotoUndo;
            win.ShowTextLine(win.undoRow);
          ELSE
            GlobWin.Beep;
          END;
        ELSE
          GlobWin.Beep;
        END;
        
    ELSE
      GlobWin.Beep;
    END;
  ELSE
    GlobWin.Beep;
  END;
  
END Undo;

(*********************************************************************************************)

PROCEDURE (VAR win:EditWinT) Redo*;
(* Kommando wiederholen *)
BEGIN
  IF ~win.undo THEN
    win.undo:=TRUE;
    CASE win.undoAction OF
    | TWin.ACT_PASTE:
        GlobWin.Beep;
        win.undo:=FALSE;
        
    | TWin.ACT_DELCHAR:
        GlobWin.Beep;
        win.undo:=FALSE;
        
    | TWin.ACT_MERGELINE:
        GlobWin.Beep;
        win.undo:=FALSE;
        
    | TWin.ACT_SPLITLINE:
        GlobWin.Beep;
        win.undo:=FALSE;
        
    | TWin.ACT_DELLINE:
        win.row:=win.undoRow;
        win.col:=win.undoCol;
        IF ~win.RowVisible(win.row) THEN 
          win.CursGoto(win.row,win.col);
        ELSE
          win.SetCaret;
        END;
        win.DeleteLine;

    | TWin.ACT_INSERTCHAR:    (* undoLen contains number of inserted characters *)
        GlobWin.Beep;
        win.undo:=FALSE;
        
    | TWin.ACT_OVERWRITECHAR:
        win.undo:=TRUE;
        win.Undo;
    ELSE
      GlobWin.Beep;
    END;
  ELSE
    GlobWin.Beep;
  END;
END Redo;

PROCEDURE (VAR win:EditWinT) SearchText*(text:WD.LPSTR; 
                                         matchcase, down, words:BOOLEAN):BOOLEAN;
(* sucht einen Text mit einer optimierten Version von BOYER - MOORE       *)
(* die nur N/M Zeichen vergleichen muß (M ... Länge des gesuchten String, *)
(* N .... Länge des gesamten Texts                                        *)
                                                
VAR 
  seektxt                   : ARRAY List.MAXLENGTH OF CHAR; 
  buf                       : ARRAY List.MAXLENGTH OF CHAR;
  m,dmyi,len,i,j,t,deltax   : LONGINT;
  skip                      : ARRAY 256 OF LONGINT;
  ok,doExit, break, dmyb    : BOOLEAN;
  dmy                       : WD.LPSTR;
  startrow                  : LONGINT;
  res                       : BOOLEAN;
    
  PROCEDURE SetSkip();  
  (* stellt ein Skip-Array zur Verfügung für Sprungweite *)
  VAR i : INTEGER;
  BEGIN
    FOR i:=0 TO 255 DO (* 32 - 127 *)
      skip[i]:=m;
    END;
    FOR i:=0 TO m-1 DO
      skip[ORD(seektxt[i])]:=m-i-1;
    END;
    
  END SetSkip;
  
  
  PROCEDURE Ch(character:CHAR):CHAR;
  BEGIN
    IF matchcase THEN
      RETURN character
    ELSE
      RETURN CAP(character)
    END;
  END Ch;
  
BEGIN
  startrow:=win.row;
  
  dmy:=WB.lstrcpyA(SYSTEM.ADR(seektxt),text); (* String in andere Adresse kopieren *)
  ASSERT(dmy#WD.NULL); 
  
  m:=Strings.Length(seektxt);
  
  IF ~matchcase THEN  (* nicht Case-Sensitive *)
    FOR i:=0 TO m-1 DO
      seektxt[i]:=CAP(seektxt[i]);
    END;
  END;
  
  SetSkip();
  break:=FALSE;
  doExit:=FALSE;
  deltax:=0;
  dmyb:=win.text.GetLine( startrow, buf, len);
  IF win.col>len THEN     (* Manipuliert ersten Buffer um bei col zu starten *)
    dmyb:=win.text.GetNextLine(buf, len);
    INC(startrow);
  ELSE
    FOR i:=win.col-1 TO len DO (* nach vorne kopieren *)
      buf[i-win.col+1]:=buf[i];
    END;
    deltax:=len;
    len:=Strings.Length(buf);
    deltax:=deltax-len;
  END;  
    
  WHILE dmyb & ~doExit DO
    i:=m-1;
    j:=m-1;
    break:=FALSE;
    WHILE (j>=0) & ~break DO
      IF i<len THEN
        WHILE (Ch(buf[i]) # seektxt[j]) & ~break DO
          t:=skip[ORD(Ch(buf[i]))];
          IF m-j>t THEN i:=i+m-j;
          ELSE i:=i+t;
          END;      
          IF (i>=len) THEN break:=TRUE;
          ELSE j:=m-1;
          END;
        
        END;
      ELSE break:=TRUE;END;
      DEC(i);
      DEC(j);
    END; (* gefunden an Position i+1 in buf wenn break = False *)
    
    IF ~break THEN
      ok:=TRUE;
      IF words THEN  (* nur ganze Wörter *)
        ok:=((i<=-1) OR ~Syntax.IsIdentChar(buf[i])) & 
            ((i+1+m>=len) OR ~Syntax.IsIdentChar(buf[i+1+m]));
      END;
      
      IF ok THEN  (* Wort gefunden *)  
        win.CursGoto(startrow, i+2+m+deltax);
        win.text.SetMarkArea(startrow,i+2+deltax,startrow,i+2+m+deltax);
        win.ShowTextLine(startrow);
        
        doExit:=TRUE;   (* doExit nicht korrekt verwendet *)
        RETURN TRUE; (* gefunden *)
      END;
    END;
    deltax:=0;
    IF down THEN
      INC(startrow);
      dmyb:=win.text.GetNextLine(buf, len);
    ELSE
      DEC(startrow);
      dmyb:=win.text.GetPrevLine( buf, len);
    END;
      
    IF ~dmyb THEN RETURN FALSE; END; (* kein Text *)
        
  END;
  RETURN FALSE;
END SearchText;

END EditWin.

                      






