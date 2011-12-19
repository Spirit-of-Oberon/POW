(******************************************************************************
 *  Module ListSt
 *  
 *  This module implements the class TextT. This class implements the data
 *  structure which is used to store the text in RAM while it is being edited.
 *  Each edit window uses one instance of this class to store the text. Files
 *  are always loaded into RAM completely before they can be edited.
 ******************************************************************************)

MODULE ListSt;


IMPORT SYSTEM,
       WD:=WinDef, WU:=WinUser, 
       Strings, Utils, WinUtils, Options;


CONST 
  
  MAXLENGTH*=2048;             (* maximum line length *)
    
    PEM_SHOWLINER*      = WU.WM_USER+1000;
    (* Update der Zeilen/Spalteninformationen *)
    (* wParam: column, lParam: row            *)
    
    PEM_SHOWINSERTMODE* = WU.WM_USER+1001;
    (* Update der Einfügemodusinformationen   *)
    (* wParam: 1(insert), 0(overwrite)        *)
  
    PEM_SHOWCHANGED*    = WU.WM_USER+1002;
    (* Update der Änderungsinformationen      *)
    (* wParam: 1(geändert), 0(nicht geändert) *)
 
   PEM_DOUBLECLICK*    = WU.WM_USER+1003;
    (* Doppelklick mit der linken Maustaste ist aufgetreten *)

   STEP* = 10;       (* Sprungrate für horizontales Scrolling *) 
   hs* = TRUE;       (* ermöglichen/sperren von horizontalem Scrolling *) 
   
   Font1* = "Fixedsys";
   Font2* = "Courier"; 
   Font3* = "Courier New";
   Font1len* =8;       
   Font2len* =7;       
  

TYPE 
  String=POINTER TO ARRAY OF CHAR;
  
  Line=POINTER TO LineT;       (* Struktur einer Textzeile *)
  LineT=RECORD
    txt             : String;  (* Text einer Zeile *)
    len             : LONGINT; (* Länge einer Zeile *)
    next            : Line;    (* nächste Zeile *)
    prev            : Line;    (* vorhergehende Zeile *)
    isCommented     : BOOLEAN; (* ist ein Kommentar in der Zeile vorhanden ? *)
    commentNesting  : INTEGER; 
  END;

  MarkT=RECORD                 (* Markierung *)
          row*, col*:LONGINT;  (* Zeile und Spalte *)
        END; 
        
  TextT*=RECORD                        
          head,tail,current    : Line;    (* Beginn, Ende, Aktuell *)
          lines-               : LONGINT; (* Gesamtzahl Zeilen *)
          markStart*,markEnd*  : MarkT;   (* für Markierung, Start und Stop der Markierung *)
          isSelected-          : BOOLEAN; (* ist eine Markierung vorhanden ? *)
          copyMark             : LONGINT;
          commentsChecked      : LONGINT; (* Nummer der Zeile, bis zu der Kommentare gecheckt sind *)
        END;
  Text*=POINTER TO TextT;   (* Zeiger auf TextT *)
      

(* FUNKTIONEN FÜR TEXTDATENSTRUKTUR *)

PROCEDURE (VAR line:LineT) Init*;
(* Initialisierung *)
BEGIN
  line.txt:=NIL;
  line.len:=0;
  line.prev:=NIL;
  line.next:=NIL;
  line.isCommented:=FALSE;
  line.commentNesting:=0;
END Init;

(*************************************************************************************************)

PROCEDURE (VAR line:LineT) UpdateCommentInfo;
(* Kommentare werden aktualisiert *)
VAR
  i   : LONGINT;
  txt : String;
  sInx: LONGINT;
  sCh : CHAR;
BEGIN
  txt:=line.txt;
  line.commentNesting:=0;
  i:=0;
  WHILE txt[i]#0X DO
    sCh:=0X;
    IF line.commentNesting<=0 THEN
      sInx:=0;
      WHILE (Options.stringDelims[sInx]#0X) &
            (Options.stringDelims[sInx]#txt[i]) DO
        INC(sInx);
      END;
      IF Options.stringDelims[sInx]#0X THEN
        sCh:=Options.stringDelims[sInx];
        INC(i);
        WHILE (txt[i]#0X) & (txt[i]#sCh) DO INC(i) END;
        IF txt[i]=sCh THEN INC(i) END;
      END;
    END;
    IF sCh#0X THEN
    ELSIF txt[i]=Options.commentStart[0] THEN
      sInx:=1;
      WHILE (Options.commentStart[sInx]#0X) &
            (txt[i+sInx]=Options.commentStart[sInx]) DO
        INC(sInx);
      END;
      IF Options.commentStart[sInx]=0X THEN
        INC(i,sInx);
        IF (line.commentNesting<=0) OR Options.commentsNested THEN 
          INC(line.commentNesting);
        END;
        line.isCommented:=TRUE;
      ELSE
        INC(i);
      END;
    ELSIF txt[i]=Options.commentEnd[0] THEN
      sInx:=1;
      WHILE (Options.commentEnd[sInx]#0X) &
            (txt[i+sInx]=Options.commentEnd[sInx]) DO
        INC(sInx);
      END;
      IF Options.commentEnd[sInx]=0X THEN
        INC(i,sInx);
        IF (line.commentNesting>=0) OR Options.commentsNested THEN 
          DEC(line.commentNesting);
        END;
        line.isCommented:=TRUE;
      ELSE
        INC(i);
      END;
    ELSE
      INC(i);
    END;
  END;
END UpdateCommentInfo;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) InvalidateMarkArea*;
(* Markierung aufheben *)
VAR
  done : WD.BOOL;

BEGIN
  IF text.isSelected THEN 
    text.isSelected:=FALSE;
    done := WU.ShowCaret(WD.NULL); (* Caret anzeigen *)
  END;
END InvalidateMarkArea;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) ResetMarkArea*;
(* Markierung zurücksetzen *)
BEGIN
  text.InvalidateMarkArea;
  text.markStart.row:=0;
  text.markStart.col:=0;
  text.markEnd.row:=0;
  text.markEnd.col:=0;
END ResetMarkArea;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SetMarkArea*(row1,col1,row2,col2:LONGINT);
(* Markierung setzen : Start (row1,col1), Stop(row2, col2) *)
VAR
  done : WD.BOOL;
BEGIN
  IF ~text.isSelected THEN 
    text.isSelected:=TRUE;
    done := WU.HideCaret(WD.NULL); (* Caret verbergen *)
  END;
  text.markStart.row:=row1;
  text.markStart.col:=col1;
  text.markEnd.row:=row2;
  text.markEnd.col:=col2;
END SetMarkArea;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) CheckMarkRange*(VAR swap:BOOLEAN);
(* Markierungsbereich überprüfen und Markierungsvariablen setzen, Anfang vor Ende *)
(* liefert TRUE, wenn Positionen vertauscht wurden                                *)
  PROCEDURE Swap(VAR a,b:LONGINT);
  (* Vertauschen *)
  VAR
    h:LONGINT;
  BEGIN
    h:=a; a:=b; b:=h;
  END Swap;
  
BEGIN
  swap:=FALSE;
  IF text.markStart.row>text.markEnd.row THEN 
    Swap(text.markStart.row,text.markEnd.row); 
    Swap(text.markStart.col,text.markEnd.col);
    swap:=TRUE;
  ELSIF text.markStart.row=text.markEnd.row THEN
    IF text.markStart.col>text.markEnd.col-1 THEN
      Swap(text.markStart.col,text.markEnd.col);
      swap:=TRUE;
    END;
  END;
END CheckMarkRange;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) Init*;
(* Initialisierung der Textdatenstruktur *)
BEGIN
  text.head:=NIL;
  text.tail:=NIL;
  text.current:=NIL;
  text.lines:=0;
  text.ResetMarkArea;
  text.commentsChecked:=0;
END Init;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SetCurrent(row:LONGINT):BOOLEAN;
(* aktuelle Zeile auf row setzen     *)
(* Rückgabewert : TRUE (erfolgreich) *)
VAR
  cur    : Line;
  count  : LONGINT;

BEGIN
  cur:=text.head;
  count:=1;
  WHILE (cur#NIL) & (count<row) DO
    cur:=cur^.next;
    INC(count);
  END;
  text.current:=cur;
  RETURN cur#NIL;
END SetCurrent;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) CheckForComments(row:LONGINT);
(* sicherstellen, daß Kommentare richtig gesetzt sind bis zur Zeile row *)
VAR
  cur    : Line;
  count  : LONGINT;

BEGIN
  IF row>text.commentsChecked THEN
    cur:=text.head;
    count:=0;
    WHILE (cur#NIL) & (count<row) DO
      cur.UpdateCommentInfo;
      cur:=cur^.next;
      INC(count);
    END;
    text.commentsChecked:=count;
  END;
END CheckForComments;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SetCurrentEx(row:LONGINT; VAR nesting:INTEGER):BOOLEAN;
(* liefert die Summe der geöffneten und geschlossen Kommentare in vorherigen Zeilen in nesting *)

VAR
  cur        : Line;
  count,min  : LONGINT;

BEGIN
  cur:=text.head;
  count:=1;
  nesting:=0;
  min:=text.commentsChecked;
  IF min>row THEN min:=row END;
  WHILE (cur#NIL) & (count<min) DO
    nesting:=nesting+cur.commentNesting;
    cur:=cur^.next;
    INC(count);
  END;
  WHILE (cur#NIL) & (count<row) DO
    cur.UpdateCommentInfo;
    nesting:=nesting+cur.commentNesting;
    cur:=cur^.next;
    INC(count);
  END;
  IF count>text.commentsChecked THEN 
    IF cur=NIL THEN DEC(count) ELSE cur.UpdateCommentInfo END;
    text.commentsChecked:=count;
  END;
  text.current:=cur;
  RETURN cur#NIL;
END SetCurrentEx;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) AddLine*(VAR txt:ARRAY OF CHAR):BOOLEAN;
(* fügt eine Zeile zum Text hinzu, die aktuelle Zeile wird auf die neue gesetzt *)
(* Rückgabewert : TRUE (erfolgreich)                                            *)

VAR 
  line : Line;

BEGIN
  NEW(line);
  IF line=NIL THEN RETURN FALSE END;
  line.Init;
  line.len:=Strings.Length(txt);
  NEW(line.txt,line.len+1);
  IF line.txt=NIL THEN
    DISPOSE(line);
    RETURN FALSE;
  END;
  line.next:=NIL;
  line.prev:=text.tail;
  COPY(txt,line.txt^);
  IF text.head=NIL THEN text.head:=line ELSE text.tail.next:=line END;
  text.tail:=line;
  text.current:=line;
  line.UpdateCommentInfo; 
  INC(text.lines);
  RETURN TRUE;
END AddLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) BulkAddLine*(VAR txt-:ARRAY OF CHAR; len:LONGINT):BOOLEAN;
(* fügt eine Zeile mit einer gegebenen Länge an den Text an, aktuelle Zeile wird nicht verändert *)
(* Rückgabewert : TRUE (erfolgreich)                                                             *)

VAR 
  line : Line;

BEGIN
  NEW(line);
  IF line=NIL THEN RETURN FALSE END;
  line.Init;
  line.len:=len;
  NEW(line.txt,line.len+1);
  IF line.txt=NIL THEN
    DISPOSE(line);
    RETURN FALSE;
  END;
  line.next:=NIL;
  line.prev:=text.tail;
  COPY(txt,line.txt^);
  IF text.head=NIL THEN text.head:=line ELSE text.tail.next:=line END;
  text.tail:=line;
(*  line.UpdateCommentInfo; *)
  INC(text.lines);
  RETURN TRUE;
END BulkAddLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) InsertLine*(VAR txt:ARRAY OF CHAR; row:LONGINT):BOOLEAN;
(* fügt eine Zeile vor einer Zeile ein                                 *)
(* ist row größer als die Gesamtzahl der Zeilen, so wird die Zeile wie *)
(* bei AddLine eingefügt                                               *)
(* aktuelle Zeile wird auf die neue Zeile gesetzt                      *)

VAR                     
  line,cur : Line;
  done     : BOOLEAN;

BEGIN
  IF (text.head=NIL) OR (row>text.lines) THEN RETURN text.AddLine(txt) END;
  NEW(line);
  IF line=NIL THEN RETURN FALSE END;
  line.Init;
  line.len:=Strings.Length(txt);
  NEW(line.txt,line.len+1);
  IF line.txt=NIL THEN
    DISPOSE(line);
    RETURN FALSE;
  END;
  done:=text.SetCurrent(row);
  ASSERT(done);
  cur:=text.current;
  line.next:=cur;
  line.prev:=cur.prev;
  IF cur=text.head THEN text.head:=line ELSE cur.prev.next:=line END;
  cur.prev:=line;
  COPY(txt,line.txt^);
  text.current:=line;
  INC(text.lines);
  line.UpdateCommentInfo;
  RETURN TRUE;
END InsertLine;
  
(*************************************************************************************************)

PROCEDURE (VAR text:TextT) InsertNextLine*(VAR txt:ARRAY OF CHAR):BOOLEAN;
(* fügt eine Zeile nach einer Zeile in den Text ein, existiert keine aktuelle Zeile  *)
(* so wird die Zeile wie bei AddLine eingefügt, die aktuelle Zeile wird auf die neue *)
(* Zeile gesetzt                                                                     *)

VAR 
  res  : BOOLEAN;
  line : Line;

BEGIN
  IF text.current=NIL THEN RETURN text.AddLine(txt) END;
  NEW(line);
  IF line=NIL THEN RETURN FALSE END;
  line.Init;
  line.len:=Strings.Length(txt);
  NEW(line.txt,line.len+1);
  IF line.txt=NIL THEN
    DISPOSE(line);
    RETURN FALSE;
  END;
  line.prev:=text.current;
  line.next:=text.current.next;
  IF text.current=text.tail THEN text.tail:=line ELSE text.current.next.prev:=line END;
  text.current.next:=line;
  COPY(txt,line.txt^);
  text.current:=line;
  INC(text.lines);
  line.UpdateCommentInfo;
  RETURN TRUE;
END InsertNextLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) DeleteCurrentLine*():BOOLEAN;
(* löscht die aktuelle Zeile aus dem Text *)

VAR 
  h : Line;

BEGIN
  IF text.current=NIL THEN RETURN FALSE END;
  IF text.current=text.head THEN
    h:=text.head.next;
    DISPOSE(text.head.txt);
    DISPOSE(text.head);
    text.head:=h;
    IF h=NIL THEN text.tail:=NIL ELSE h.prev:=NIL END;
    text.current:=h;
  ELSIF text.current=text.tail THEN
    h:=text.tail.prev;
    DISPOSE(text.tail.txt);
    DISPOSE(text.tail);
    text.tail:=h;
    h.next:=NIL;
    text.current:=h;
  ELSE 
    h:=text.current;
    h.prev.next:=h.next;
    h.next.prev:=h.prev;
    text.current:=h.next;
    DISPOSE(h.txt);
    DISPOSE(h);
  END;
  DEC(text.lines);
  RETURN TRUE;
END DeleteCurrentLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) DeleteLine*(row:LONGINT):BOOLEAN;
(* löscht eine Zeile mit der Zeilennummer row aus dem Text, aktuelle Zeile wird auf *)
(* die nächste Zeile gesetzt                                                        *)

VAR 
  done : BOOLEAN;

BEGIN
  done:=text.SetCurrent(row);
  IF ~done THEN RETURN FALSE END;
  RETURN text.DeleteCurrentLine();
END DeleteLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetLine*(row:LONGINT;
                                   VAR txt:ARRAY OF CHAR;
                                   VAR len:LONGINT):BOOLEAN;
(* setzt einen Text txt in eine Zeile row, die Länge wird in len zurückgegeben *)

VAR 
  done : BOOLEAN;

BEGIN
  txt[0]:=0X;
  len:=0;
  done:=text.SetCurrent(row);
  IF ~done THEN RETURN FALSE END;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  RETURN TRUE;
END GetLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetLineEx*(row:LONGINT;
                                   VAR txt:ARRAY OF CHAR;
                                   VAR len:LONGINT;
                                   VAR isCommented:BOOLEAN;
                                   VAR prevNesting:INTEGER;
                                   VAR commentNesting:INTEGER):BOOLEAN;
(* setzt einen Text txt in eine Zeile row, die Länge wird in len zurückgegeben *)

VAR 
  done : BOOLEAN;
BEGIN
  txt[0]:=0X;
  len:=0;
  isCommented:=FALSE;
  done:=text.SetCurrentEx(row,prevNesting);
  IF ~done THEN RETURN FALSE END;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  isCommented:=text.current.isCommented;
  commentNesting:=text.current.commentNesting; 
  RETURN TRUE;
END GetLineEx;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetLineLength*(row:LONGINT;
                                   VAR len:LONGINT):BOOLEAN;
(* liefert die Länge einer Zeile row *)

VAR 
  done : BOOLEAN;

BEGIN
  len:=0;
  done:=text.SetCurrent(row);
  IF ~done THEN RETURN FALSE END;
  len:=text.current.len;
  RETURN TRUE;
END GetLineLength;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetNextLine*(VAR txt:ARRAY OF CHAR; 
                                        VAR len:LONGINT):BOOLEAN;
(* liefert die Zeile nach der aktuellen Zeile zurück und die aktuelle Zeile wird auf diese *)
(* gesetzt                                                                                 *)

BEGIN
  IF (text.current=NIL) OR (text.current.next=NIL) THEN RETURN FALSE END;
  text.current:=text.current.next;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  RETURN TRUE;
END GetNextLine;  

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetNextLineEx*(VAR txt:ARRAY OF CHAR; 
                                          VAR len:LONGINT;
                                          VAR isCommented:BOOLEAN;
                                          VAR commentNesting:INTEGER):BOOLEAN;
BEGIN
  IF (text.current=NIL) OR (text.current.next=NIL) THEN RETURN FALSE END;
  text.current:=text.current.next;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  text.current.UpdateCommentInfo;
  isCommented:=text.current.isCommented;
  commentNesting:=text.current.commentNesting;
  RETURN TRUE;
END GetNextLineEx;  

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetPrevLine*(VAR txt:ARRAY OF CHAR;
                                        VAR len:LONGINT):BOOLEAN;
(* liefert die vorhergehende Zeile zurück und die aktuelle Zeile wird auf diese gesetzt *)

BEGIN
  IF (text.current=NIL) OR (text.current.prev=NIL) THEN RETURN FALSE END;
  text.current:=text.current.prev;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  RETURN TRUE;
END GetPrevLine; 

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetCurrentLine*(VAR txt:ARRAY OF CHAR;
                                           VAR len:LONGINT):BOOLEAN;
(* liefert die aktuelle Zeile zurück *)

BEGIN
  IF text.current=NIL THEN RETURN FALSE END;
  IF LEN(txt)<text.current.len+1 THEN RETURN FALSE END;
  COPY(text.current.txt^,txt);
  len:=text.current.len;
  RETURN TRUE;
END GetCurrentLine; 

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SetLine*(row:LONGINT;
                                    VAR txt:ARRAY OF CHAR):BOOLEAN;
(* der Inhalt einer Zeile wird durch txt ersetzt *)

VAR
  done   : BOOLEAN;
  len    : LONGINT;
  newTxt : String;

BEGIN
  done:=text.SetCurrent(row);
  IF ~done THEN RETURN FALSE END;
  len:=Strings.Length(txt);
  IF LEN(text.current.txt^)<len+1 THEN
    NEW(newTxt,len+10);
    IF newTxt=NIL THEN RETURN FALSE END;
    DISPOSE(text.current.txt);
    text.current.txt:=newTxt;
  END;
  COPY(txt,text.current.txt^);
  text.current.len:=len;
  text.current.UpdateCommentInfo;
  RETURN TRUE;
END SetLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SetLineEx*(row:LONGINT;
                                    VAR txt:ARRAY OF CHAR;
                                    VAR nestingChanged:BOOLEAN):BOOLEAN;
(* der Inhalt einer Zeile wird durch txt ersetzt                                *)
(* nestingChanged wird gesetzt wenn sich bei den Kommentaren etwas geändert hat *)

VAR
  done     : BOOLEAN;
  len      : LONGINT;
  newTxt   : String;
  nesting  : INTEGER;

BEGIN
  done:=text.SetCurrent(row);
  nestingChanged:=TRUE;
  IF ~done THEN RETURN FALSE END;
  nesting:=text.current.commentNesting;
  len:=Strings.Length(txt);
  IF LEN(text.current.txt^)<len+1 THEN
    NEW(newTxt,len+10);
    IF newTxt=NIL THEN RETURN FALSE END;
    DISPOSE(text.current.txt);
    text.current.txt:=newTxt;
  END;
  COPY(txt,text.current.txt^);
  text.current.len:=len;
  text.current.UpdateCommentInfo;
  nestingChanged:=text.current.commentNesting#nesting;
  RETURN TRUE;
END SetLineEx;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) MergeLines*(row:LONGINT):BOOLEAN;
(* der Inhalt einer Zeile row und der folgenden Zeile wird miteinander vereint, die *)
(* aktuelle Zeile wird gesetzt                                                      *)

VAR
  done      : BOOLEAN;
  newTxt    : String;
  h         : Line;

BEGIN
  done:=text.SetCurrent(row);
  IF ~done OR (text.current.next=NIL) THEN RETURN FALSE END;
  NEW(newTxt,text.current.len+text.current.next.len+1);
  IF newTxt=NIL THEN RETURN FALSE END;
  INC(text.current.len,text.current.next.len);
  COPY(text.current.txt^,newTxt^);
  Strings.Append(newTxt^,text.current.next.txt^);
  DISPOSE(text.current.txt);
  text.current.txt:=newTxt;
  text.current.UpdateCommentInfo;
  h:=text.current;
  text.current:=h.next;
  done:=text.DeleteCurrentLine();
  text.current:=h;
  RETURN done;
END MergeLines;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) SplitLine*(row:LONGINT;
                                      len1:LONGINT;
                                      indent:LONGINT):BOOLEAN;
(* die Zeile row wird in zwei Teile geteilt, die Länge des 1. Teils ist len1 Zeichen *)

VAR 
  done      : BOOLEAN;
  txt       : String;
  i,len2    : LONGINT;
  h         : Line;

BEGIN
  done:=text.SetCurrent(row);
  IF ~done THEN RETURN FALSE END;
  h:=text.current;
  IF len1>h.len THEN len1:=h.len END;
  len2:=h.len-len1;
  NEW(txt,len2+1+indent);
  IF txt=NIL THEN RETURN FALSE END;
  FOR i:=0 TO indent-1 DO txt[i]:=" " END;
  FOR i:=0 TO len2-1 DO txt[i+indent]:=h.txt[len1+i] END;
  h.txt[len1]:=0X;
  h.len:=len1;
  h.UpdateCommentInfo;
  txt[indent+len2]:=0X;
  IF ~text.InsertNextLine(txt^) THEN RETURN FALSE END;
  text.current:=h;
  RETURN TRUE;
END SplitLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GoToLastLine*;
(* zur letzten Zeile springen *)

BEGIN
  text.current:=text.tail;
END GoToLastLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GoToFirstLine*;
(* zur ersten Zeile springen *)

BEGIN
  text.current:=text.head;
END GoToFirstLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetCurrentLineNo*(VAR row:LONGINT);
(* liefert aktuelle Zeilennummer zurück *)

VAR
  cur:Line;
BEGIN
  row:=0;
  IF (text.current=NIL) OR (text.head=NIL) THEN RETURN END;
  row:=1;
  cur:=text.head;
  WHILE (cur#NIL) & (cur#text.current) DO
    INC(row);
    cur:=cur.next;
  END;
END GetCurrentLineNo;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetFirstMarkedLine*(VAR txt:ARRAY OF CHAR):BOOLEAN;
(* liefert den Inhalt der 1.Zeile der Markierung *)

VAR
  buf  : String;
  len  : LONGINT;
  swap : BOOLEAN;

BEGIN
  IF ~text.isSelected THEN txt[0]:=0X; RETURN FALSE END;
  NEW(buf,MAXLENGTH);
  IF buf=NIL THEN txt[0]:=0X; RETURN FALSE END;
  text.CheckMarkRange(swap);
  text.copyMark:=text.markStart.row;
  IF ~text.GetLine(text.markStart.row,buf^,len) THEN DISPOSE(buf); RETURN FALSE END;
  IF text.markStart.row#text.markEnd.row THEN
    Strings.Copy(buf^,txt,text.markStart.col,len-text.markStart.col+1);
  ELSE 
    Strings.Copy(buf^,txt,text.markStart.col,text.markEnd.col-text.markStart.col);
  END;
  DISPOSE(buf);
  RETURN TRUE;
END GetFirstMarkedLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetNextMarkedLine*(VAR txt:ARRAY OF CHAR):BOOLEAN;
(* liefert den Inhalt der nächsten Zeile einer Markierung *)

VAR
  len,row : LONGINT;
  buf     : String;

BEGIN
  txt[0]:=0X;
  IF ~text.isSelected OR (text.copyMark>=text.markEnd.row) THEN RETURN FALSE END;
  INC(text.copyMark);
  IF text.copyMark=text.markEnd.row THEN
    NEW(buf,MAXLENGTH);
    IF buf=NIL THEN RETURN FALSE END;
    IF ~text.GetNextLine(buf^,len) THEN DISPOSE(buf); RETURN FALSE END;
    Strings.Copy(buf^,txt,1,text.markEnd.col-1);
  ELSE
    IF ~text.GetNextLine(txt,len) THEN RETURN FALSE END;
  END;
  RETURN TRUE;
END GetNextMarkedLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) ResetContents*;
(* Inhalt zurücksetzen *)

VAR
  line,h : Line;

BEGIN
  line:=text.tail;
  WHILE line#NIL DO
    h:=line;
    line:=line.prev;
    IF h.txt#NIL THEN DISPOSE(h.txt) END;
    DISPOSE(h);
  END;
  text.Init;
END ResetContents;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) GetMarkedTextSize*():LONGINT;
(* Speicherplatz berechnen für markierten Text inklusive Zeilenvorschub *)

VAR 
  rows,size : LONGINT;
  swap,done : BOOLEAN;

BEGIN
  IF ~text.isSelected THEN RETURN 0 END;
  text.CheckMarkRange(swap);
  size:=0;
  IF text.markStart.row=text.markEnd.row THEN
    RETURN text.markEnd.col-text.markStart.col;
  ELSE
    rows:=text.markEnd.row-text.markStart.row+1;
    done:=text.SetCurrent(text.markStart.row);
    ASSERT(done);
    size:=text.current.len-text.markStart.col+3;
    DEC(rows);
    WHILE rows>1 DO
      text.current:=text.current.next;
      ASSERT(text.current#NIL);
      size:=size+text.current.len+2;
      DEC(rows);
    END;
    text.current:=text.current.next;
    ASSERT(text.current#NIL);
    size:=size+text.markEnd.col+2;
    RETURN size;
  END;
END GetMarkedTextSize;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) InsertInLine*(VAR txt:ARRAY OF CHAR;
                                         pos :LONGINT; 
                                         row:LONGINT):BOOLEAN;
(* fügt einen String txt an der Position pos in der Zeile row ein, wenn möglich,        *)
(* ansonsten wird der String an den Text angehängt, wenn die Zeile noch nicht existiert *)

VAR
  len  : LONGINT;
  buf  : String;
  done : BOOLEAN;

BEGIN
  NEW(buf,MAXLENGTH);
  IF buf=NIL THEN RETURN FALSE END;
  IF ~text.GetLine(row,buf^,len) THEN 
    DISPOSE(buf);
    RETURN text.AddLine(txt);
  END;
  IF pos>len+1 THEN pos:=len+1 END;
  Strings.Insert(txt,buf^,pos);
  done:=text.SetLine(row,buf^);
  DISPOSE(buf);
  RETURN done;
END InsertInLine;

(*************************************************************************************************)

PROCEDURE (VAR text:TextT) DeleteInLine*(pos:LONGINT;
                                         len:LONGINT; 
                                         row:LONGINT):BOOLEAN;
(* Löscht len Zeichen aus einer Zeile row beginnend an der Position pos *)

VAR 
  buf    : String;
  bufLen : LONGINT;
  done   : BOOLEAN;

BEGIN
  IF len<=0 THEN RETURN TRUE END;
  NEW(buf,MAXLENGTH);
  IF buf=NIL THEN RETURN FALSE END;
  IF ~text.GetLine(row,buf^,bufLen) THEN DISPOSE(buf); RETURN FALSE END;
  IF pos>bufLen THEN pos:=bufLen+1 END;
  IF pos+len-1>bufLen THEN len:=bufLen-pos+1 END;
  IF (pos=1) & (len=bufLen) THEN
    buf[0]:=0X;
  ELSE
    Strings.Delete(buf^,pos,len);
  END;
  done:=text.SetLine(row,buf^);
  DISPOSE(buf);
  RETURN done;
END DeleteInLine;

END ListSt.

