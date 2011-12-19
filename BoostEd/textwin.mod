(******************************************************************************
 *  Module TextWin
 *  
 *  This module implements the class WinDescT, which is the basic editor 
 *  window class. The funcionality supported by this class includes
 *    text output to screen
 *    adding and deleting text
 *    handling to support scroll bars
 *    block indent and unindent
 ******************************************************************************)

MODULE TextWin;


IMPORT SYSTEM,
       WD:=WinDef, WU:=WinUser, WG:=WinGdi, WB:=WinBase,
       List:=ListSt, Utils, Strings, WinUtils, Options, Syntax, GlobMem, GlobWin;


CONST
  BRAKE = 40;     (* Unterbrechungswert um horizontales Markieren zu verlangsamen *)
  HORZCOLSTEP=10; (* Anzahl der Spalten bei horizontalem Shift *)
  ACT_PASTE*=8;
  ACT_CUT*=9;
  ACT_DELCHAR*=2;
  ACT_NONE*=3;
  ACT_MERGELINE*=4;
  ACT_DELLINE*=5;
  ACT_INSERTCHAR*=6;    (* undoLen enthält Anzahl der eingefügten Zeichen *)
  ACT_OVERWRITECHAR*=7; (* undoLen enthält Anzahl der überschriebenen Zeichen *)
  ACT_OVERWRITESELECTION*=11;
  ACT_SPLITLINE*=12; (* undoLen enthält Anzahl der eingefügten Ident Leerzeichen *)


TYPE
  WinDesc* =POINTER TO WinDescT;

  WinDescT* = RECORD
               text*                   : List.Text;   (* Text                                       *)
               hwnd*                   : WD.HWND;     (* Fensterhandle                              *)
               changed*                : BOOLEAN;     (* Änderungen am Text ?                       *)
               row*,col*               : LONGINT;     (* aktuelle Cursorposition                    *)
               delrow*,delcol*         : LONGINT;     (* Cursorpos. des zuletzt gelöschten Elements *)
               lineNo*,                               (* Anzahl Zeilen im Fenster                   *)
               lineheight*,                           (* Höhe (abhängig von Schrift                 *)
               charwidth*,                            (* Breite eines Zeichens                      *)
               initrowpos*,                           (* Y - Offset Fenster - 1.Zeile               *)
               initcolpos*,                           (* X - Offset Fenster - 1.Zeile               *)
               colPos*                 : LONGINT;     (* erste sichtbare Spalte am Bildschirm       *)
               colNo*                  : LONGINT;     (* Anzahl sichtbarer Spalten am Bildschirm    *)
               textPos*                : LONGINT;     (* Reihennummer der 1.Zeile des Fensters      *)
               sumLen*,                               (* Handling GetFirst/NextBuffer               *) 
               position*,                             (* ----------- " --------------               *)
               lineNbr*                : LONGINT;     (* Zeilenzähler in filehnd                    *)
               hdc*                    : WD.HDC;      (* Privater device context                    *)
               wndheight*,wndwidth*    : LONGINT;     (* Geometrie des Fensters                     *)
               textHeight*             : LONGINT;     (* Höhe einer Textzeile                       *)
               MouseCapture*           : BOOLEAN;     (* für Textmarkierung                         *)
               MarkProcess*            : BOOLEAN;     (* Markierung in Arbeit ?                     *)
               backBrush*              : WD.HBRUSH;   (* Pinsel für Hintergrundlöschen              *)
               undoData*               : WD.HGLOBAL;  (* Handle für globale Daten, für UnDo         *)
               undoRow*,undoCol*       : LONGINT;
               undoToRow*,undoToCol*   : LONGINT;     (* Undo - Bereich                             *)
               undoAction*             : LONGINT;
               undoLen*                : LONGINT;
               undo*                   : BOOLEAN;     (* TRUE: undo; FALSE: redo                    *)
               oldFont*                : WD.HFONT;    (* Originalschrift von Windows                *)
               markDown*               : BOOLEAN;
               mouseX*,mouseY*         : LONGINT;     (* Mausposition während Markierung            *)
               readOnly*               : BOOLEAN;     (* Fenster kann nur gelesen werden            *)
             END;

VAR
  colWnd,colWndText              : WD.COLORREF;
  colHighlight,colHighlightText  : WD.COLORREF;
  localTxt                       : ARRAY List.MAXLENGTH+1 OF CHAR; (* This variable is global to reduce 
             stack usage; it should be local to each procedure that uses it. 
             It is used in : ShowTextLine, ShowTextRange, UnIndentMarkedBlock, DeleteLine, InsertText *)
  localStrLine                 : ARRAY List.MAXLENGTH OF CHAR;  (* this variable is global to reduce 
             stack usage; it should be local to each procedure that uses it
             It is used in : InsertText *)


PROCEDURE (VAR win:WinDescT) SetUndoAction*(action:LONGINT);
(* abstract method *)
BEGIN
  HALT(0);
END SetUndoAction;


PROCEDURE (VAR win:WinDescT) SetCaret*;
VAR
  done : WD.BOOL;
BEGIN
  done := WU.HideCaret(win.hwnd); (* Caret vom Bildschirm entfernen *)
  (* Caret an angegebene Koordinaten verschieben *)  
  done := WU.SetCaretPos(win.initcolpos+(win.col-win.colPos)*win.charwidth,
                         (win.row-win.textPos)*win.lineheight+win.initrowpos);
  done := WU.ShowCaret(win.hwnd); (* Caret anzeigen *)
END SetCaret;


PROCEDURE (VAR win:WinDescT) RowVisible*(VAR row:LONGINT):BOOLEAN;
(* liefert TRUE, wenn sich die übergebene Zeile im Fensterbereich befindet, *)
(* ansonsten FALSE zurück.                                                  *)

BEGIN
  RETURN (row>=win.textPos) & (row<win.textPos+win.lineNo);
END RowVisible;


PROCEDURE (VAR win:WinDescT) ColVisible*(VAR col:LONGINT):BOOLEAN;
(* liefert TRUE, wenn sich die übergebene Spalte im Fensterbereich befindet, *)
(* ansonsten FALSE zurück.                                                   *)
BEGIN
  RETURN (col>=win.colPos) & (col<win.colPos+win.colNo);
END ColVisible;


PROCEDURE (VAR win:WinDescT) UpdateHorScrollBar*;
(* aktualisiert die Position der horizontalen Scrollbar *)
VAR
  dummy : LONGINT;
  done  : WD.BOOL;
BEGIN
  (* minimale und maximale Position für horizontale Bildlaufleiste setzen *)
  done := WU.SetScrollRange(win.hwnd,WU.SB_HORZ,0,List.MAXLENGTH-win.colNo-1,WD.False);
  (* Position des Schiebefeldes setzen *)
  dummy:=WU.SetScrollPos(win.hwnd,
                        WU.SB_HORZ,
                        win.colPos-1,
                        WD.True);
END UpdateHorScrollBar;


PROCEDURE (VAR win:WinDescT) UpdateVerScrollBar*;
(* aktualisiert die Position der vertikalen Scrollbar *)
VAR
  dummy : LONGINT;
  range : LONGINT;
  done  : WD.BOOL;
BEGIN
  range:=win.text.lines-win.lineNo;
  IF range<0 THEN range:=0 END;
  (* minimale und maximale Position für vertikale Bildlaufleiste setzen *)
  done := WU.SetScrollRange(win.hwnd, WU.SB_VERT, 0, range, WD.False);
  (* Position des Schiebefeldes setzen *)
  dummy:=WU.SetScrollPos(win.hwnd,
                         WU.SB_VERT,
                         win.textPos-1,
                         WD.True);
END UpdateVerScrollBar;


PROCEDURE (VAR win:WinDescT) Init*;
(* Initialisierung *)
BEGIN
  win.text.Init;
  win.changed:=FALSE;
  win.row:=1;
  win.col:=1;
  win.lineNo:=0;             
  win.lineheight:=0;
  win.initrowpos:=0;
  win.initcolpos:=0;        
  win.textPos:=1;
  win.colPos:=1;
  win.colNo:=0;
  win.sumLen:=0;
  win.position:=0;
  win.lineNbr:=0;
  win.wndheight:=0;
  win.wndwidth:=0;
  win.textHeight:=0;
  win.MouseCapture:=FALSE;
  win.MarkProcess:=FALSE;               
  win.backBrush:=WU.GetSysColorBrush(WU.COLOR_WINDOW);
  win.mouseX:=1;
  win.mouseY:=1;
  win.readOnly:=FALSE;
  win.undoData:=WD.NULL;
  win.undoAction:=ACT_NONE;
  win.undoRow:=1;
  win.undoCol:=1;
  win.undo:=TRUE;
  win.undoLen:=0;
END Init;


PROCEDURE (VAR win:WinDescT) InitTextMetrics;
(* Text/Schrift Parameter konfigurieren für Bildschirm-Management *)
VAR 
  rect   : WD.RECT;
  res    : WD.BOOL;
  tm     : WG.TEXTMETRIC;
  done   : WD.BOOL;
BEGIN
  done := WU.GetClientRect(win.hwnd,rect); (* Größe des Clientbereichs ermitteln *)
  win.wndwidth:=rect.right;
  win.wndheight:=rect.bottom;
  res := WG.GetTextMetricsA(win.hdc,tm); (* Daten über aktuelle Schrift auslesen *)
  win.lineheight:=tm.tmHeight;
  win.charwidth :=tm.tmAveCharWidth;
  win.textHeight:=tm.tmHeight;
  win.lineNo:=win.wndheight DIV win.lineheight;
  win.colNo:=win.wndwidth DIV win.charwidth;
  win.initrowpos:=0; (* win.lineheight; *)
  win.initcolpos:=0; (* win.lineheight DIV 2; *)
END InitTextMetrics;


PROCEDURE (VAR win:WinDescT) ScreenConfig*;
(* Parameter für Bildschirm - Management konfigurieren *)
VAR 
  done : WD.BOOL;
BEGIN
  done := WU.ShowScrollBar(win.hwnd,WU.SB_VERT,WD.True); (* vertikale Scrollbar anzeigen *)
  win.UpdateVerScrollBar;
  IF List.hs THEN 
    done := WU.ShowScrollBar(win.hwnd,WU.SB_HORZ,WD.True);
    done := WU.SetScrollRange(win.hwnd,WU.SB_HORZ,0,List.MAXLENGTH-win.colNo-1,WD.True);  
    win.UpdateHorScrollBar;
  END;  
  win.InitTextMetrics;
END ScreenConfig;


PROCEDURE (VAR win:WinDescT) SelectMarkColor;
(* Farbe für Markierung setzen *)
VAR
  dummy : WD.COLORREF;
BEGIN
  dummy := WG.SetTextColor(win.hdc, colHighlightText); (* Textfarbe setzen *)
  dummy := WG.SetBkColor(win.hdc, colHighlight);       (* Hintergrundfarbe setzen *)
END SelectMarkColor;


PROCEDURE (VAR win:WinDescT) SelectTextColor*;
(* Textfarbe wählen *)
VAR  
  dummy : WD.COLORREF;
BEGIN
  dummy := WG.SetTextColor(win.hdc,colWndText);
  dummy := WG.SetBkColor(win.hdc,colWnd); 
END SelectTextColor;


PROCEDURE (VAR win:WinDescT) SelectCommentColor*;
(* Farbe für Kommentartext setzen *)
VAR  
  dummy : WD.COLORREF;
BEGIN
  dummy := WG.SetTextColor(win.hdc,Options.commentColor);
  dummy := WG.SetBkColor(win.hdc,colWnd); 
END SelectCommentColor;


PROCEDURE (VAR win:WinDescT) BackRect*(x1,y1,x2,y2:LONGINT);
VAR
  rect  : WD.RECT;
  dummy : LONGINT;
BEGIN
  IF y2-y1<=0 THEN RETURN END;
  rect.left:=x1;
  rect.top:=y1;
  rect.right:=x2+1;
  rect.bottom:=y2+1;
  dummy := WU.FillRect(win.hdc,rect,win.backBrush); (* Rechteck füllen *)
END BackRect;


PROCEDURE IsStrChar(x:CHAR):BOOLEAN;
VAR
  i:INTEGER;
BEGIN
  i:=0;
  WHILE (Options.stringDelims[i]#0X) &
        (Options.stringDelims[i]#x) DO
    INC(i);
  END;
  RETURN Options.stringDelims[i]=x;
END IsStrChar;


PROCEDURE IsCommentStartAt(VAR txt-:ARRAY OF CHAR;
                           inx:LONGINT):BOOLEAN;
VAR
  sInx:LONGINT;
BEGIN
  sInx:=0;
  WHILE (Options.commentStart[sInx]#0X) &
        (Options.commentStart[sInx]=txt[sInx+inx]) DO
    INC(sInx);
  END;
  RETURN Options.commentStart[sInx]=0X;
END IsCommentStartAt;


PROCEDURE (VAR win:WinDescT) WriteTextLine(VAR txt-:ARRAY OF CHAR;
                                           len:LONGINT;
                                           isCommented:BOOLEAN;
                                           nesting:INTEGER;
                                           row:LONGINT);
(* Textzeile ausgeben *)
VAR
  dummy              : WD.BOOL;
  len1,len2,len3     : LONGINT;
  x,y                : LONGINT;
  l,startInx,i       : LONGINT;
  colFlag,oldColFlag : INTEGER;
  strChar            : CHAR;
  comEndInx          : LONGINT;
  earliestComEnd     : LONGINT;
BEGIN
  x:=win.initcolpos+win.charwidth*(1-win.colPos);
  y:=win.initrowpos+win.lineheight*(row-win.textPos);
  IF txt="" THEN
    win.BackRect(0,y,win.wndwidth-1,y+win.lineheight-1);
    RETURN;
  END;
  win.BackRect(x+win.charwidth*len,y,win.wndwidth-1,y+win.lineheight-1);
  IF Options.colorComments & isCommented THEN
    colFlag:=-1;
    startInx:=0;
    i:=0;
    strChar:=0X;
    comEndInx:=0;
    earliestComEnd:=0;
    WHILE txt[i]#0X DO
      IF strChar#0X THEN
        IF txt[i]=strChar THEN
          strChar:=0X;
        END;
        comEndInx:=0;
      ELSIF (nesting<=0) & IsStrChar(txt[i]) THEN
        strChar:=txt[i];
        comEndInx:=0;
      ELSIF (txt[i]=Options.commentStart[0]) &
            IsCommentStartAt(txt,i) THEN
        IF Options.commentsNested OR (nesting<=0) THEN
          INC(nesting);
        END;
        comEndInx:=0;
        earliestComEnd:=i+Strings.Length(Options.commentStart);
      ELSIF Options.commentEnd[comEndInx]=0X THEN
        IF Options.commentsNested OR (nesting>0) THEN
          DEC(nesting);
        END;
        comEndInx:=0;
      ELSIF (txt[i]=Options.commentEnd[comEndInx]) & 
            (i>=earliestComEnd) THEN
        INC(comEndInx);
      ELSIF (txt[i]=Options.commentEnd[0]) & 
            (i>=earliestComEnd) THEN
        comEndInx:=1;
      ELSE
        comEndInx:=0;
      END;
      oldColFlag:=colFlag;
      IF win.text.isSelected & (
         ((row>win.text.markStart.row) & (row<win.text.markEnd.row)) OR
         ((row=win.text.markStart.row) & (row<win.text.markEnd.row) & (i+1>=win.text.markStart.col)) OR
         ((row>win.text.markStart.row) & (row=win.text.markEnd.row) & (i+1<win.text.markEnd.col)) OR
         ((row=win.text.markStart.row) & (row=win.text.markEnd.row) & 
                                        (i+1>=win.text.markStart.col) & (i+1<win.text.markEnd.col))
          ) THEN
        colFlag:=1;
      ELSE    
        IF nesting>0 THEN colFlag:=2 ELSE colFlag:=3 END;
      END;
      IF ((oldColFlag#colFlag) & (oldColFlag#-1)) OR (txt[i+1]=0X) THEN
        CASE oldColFlag OF
          1:win.SelectMarkColor;
        | 2:win.SelectCommentColor;
        | 3:win.SelectTextColor;
        ELSE
          GlobWin.Beep;
        END;
        (* Text ausgeben *)
        dummy:=WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt[startInx]),i-startInx);
        x:=x+win.charwidth*(i-startInx);
        startInx:=i;
      END;
      INC(i);
    END;
    CASE colFlag OF
      1:win.SelectMarkColor;
    | 2:win.SelectCommentColor;
    | 3:win.SelectTextColor;
    ELSE
      GlobWin.Beep;
    END;
    (* Text ausgeben *)
    dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt[i-1]),1);
  ELSIF win.text.isSelected & 
        (row>=win.text.markStart.row) & (row<=win.text.markEnd.row) THEN
    IF win.text.markStart.row=win.text.markEnd.row THEN
      len1:=win.text.markStart.col-1;
      len2:=win.text.markEnd.col-1-len1;
      len3:=len-len1-len2;
      IF len1>0 THEN
        IF Options.colorComments & (nesting>0) THEN win.SelectCommentColor ELSE win.SelectTextColor END;
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt),len1);
      END;
      IF len2>0 THEN
        win.SelectMarkColor;
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,
                             x+len1*win.charwidth,
                             y,
                             SYSTEM.ADR(txt)+len1,len2);
      END;
      IF len3>0 THEN
        IF Options.colorComments & (nesting>0) THEN win.SelectCommentColor ELSE win.SelectTextColor END;
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,
                             x+(len1+len2)*win.charwidth,
                             y,
                             SYSTEM.ADR(txt)+len1+len2,len3);
      END;
    ELSIF row=win.text.markStart.row THEN
      len1:=win.text.markStart.col-1;
      IF len1>0 THEN
        IF Options.colorComments & (nesting>0) THEN win.SelectCommentColor ELSE win.SelectTextColor END; 
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt),len1);
      END;
      win.SelectMarkColor;
      IF len=0 THEN
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x-win.charwidth DIV 2,y,SYSTEM.ADR("  "),1);
      ELSE
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,
                             x+len1*win.charwidth,
                             y,
                             SYSTEM.ADR(txt)+len1,len-len1);
      END;
    ELSIF row=win.text.markEnd.row THEN
      len1:=win.text.markEnd.col-1;
      IF len=0 THEN
(*        win.SelectMarkColor;
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,SHORT(x-win.charwidth DIV 2),SHORT(y),SYSTEM.ADR("  "),1);
        win.SelectTextColor; *)
      ELSIF len1>0 THEN
        win.SelectMarkColor;
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt),len1);
      END;
      IF Options.colorComments & (nesting>0) THEN win.SelectCommentColor ELSE win.SelectTextColor END; 
      (* Text ausgeben *)
      dummy := WG.TextOutA(win.hdc,
                           x+len1*win.charwidth,
                           y,
                           SYSTEM.ADR(txt)+len1,len-len1);
    ELSE
      win.SelectMarkColor;
      IF len>0 THEN
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt),len);
      ELSE
        (* Text ausgeben *)
        dummy := WG.TextOutA(win.hdc,x-win.charwidth DIV 2,y,SYSTEM.ADR("  "),1);
      END;
    END;
  ELSE
    IF Options.colorComments & (nesting>0) THEN win.SelectCommentColor ELSE win.SelectTextColor END; 
    (* Text ausgeben *)
    dummy := WG.TextOutA(win.hdc,x,y,SYSTEM.ADR(txt),len);
  END;
END WriteTextLine;


PROCEDURE (VAR win:WinDescT) ShowTextLine*(row:LONGINT);
(* Ausgabe einer bestimmten Textzeile, wobei row eine absolute Zeilennummer ist und die *)
(* die 1. Zeile des Textes 1 ist                                                        *)
VAR 
  len         : LONGINT;
  isCommented : BOOLEAN;
  h,nesting   : INTEGER;
  done        : WD.BOOL;

BEGIN
  IF (row<win.textPos) OR (row>win.textPos+win.lineNo) THEN RETURN END;
  done := WU.HideCaret(win.hwnd); (* Caret vom Bildschirm verbergen *)
  IF ~win.text.GetLineEx(row,localTxt,len,isCommented,nesting,h) THEN localTxt:="" END;
  win.WriteTextLine(localTxt,len,isCommented,nesting,row);
  done := WU.ShowCaret(win.hwnd); (* Caret anzeigen *)
END ShowTextLine;    


PROCEDURE (VAR win:WinDescT) ShowTextRange*(startRow,endRow:LONGINT);
(* Textbereich anzeigen *)
VAR 
  i,dummy,x,y,len  : LONGINT;
  done             : BOOLEAN;
  isCommented      : BOOLEAN;
  h,nesting        : INTEGER;
  ok               : WD.BOOL;
BEGIN
  ok := WU.HideCaret(win.hwnd); (* Caret verbergen *)
  IF win.textPos+win.lineNo>win.text.lines THEN
    win.BackRect(0,(win.text.lines-win.textPos+1)*win.lineheight,
                 win.wndwidth-1,win.wndheight-1);
  ELSE
    win.BackRect(0,(win.lineNo+1)*win.lineheight,
                 win.wndwidth-1,win.wndheight-1);
  END;
  IF (startRow>win.textPos+win.lineNo) OR (endRow<win.textPos) THEN 
    ok := WU.ShowCaret(win.hwnd); (* Caret anzeigen *)
    RETURN;
  END;
  IF startRow<win.textPos THEN startRow:=win.textPos END;
  IF endRow>win.textPos+win.lineNo THEN endRow:=win.textPos+win.lineNo END;
  IF win.text.GetLineEx(startRow,localTxt,len,isCommented,nesting,h) THEN
    done:=TRUE;
    WHILE (startRow<=endRow) & done DO
      win.WriteTextLine(localTxt,len,isCommented,nesting,startRow);
      INC(startRow);
      IF startRow<=endRow THEN
        nesting:=nesting+h;
        done:=win.text.GetNextLineEx(localTxt,len,isCommented,h);
      END;
    END;
  ELSE
    win.BackRect(0,win.initrowpos+win.lineheight*(startRow-win.textPos),
                 win.wndwidth-1,win.wndheight-1);
  END;
  ok := WU.ShowCaret(win.hwnd); (* Caret anzeigen *)
END ShowTextRange;


PROCEDURE (VAR win:WinDescT) VerScroll*(n:LONGINT);
(* n Zeilen in angegebene Richtung scrollen, positive Werte meinen abwärts scrollen *)
BEGIN
  IF (n>0) & (win.textPos+n+win.lineNo-1>win.text.lines) THEN
    win.textPos:=win.text.lines-win.lineNo+1;
  ELSE
    win.textPos:=win.textPos+n; 
  END;
  IF win.textPos<1 THEN win.textPos:=1 END;
  win.ShowTextRange(1,win.text.lines);
  win.UpdateVerScrollBar;
  win.SetCaret;
END VerScroll;


PROCEDURE (VAR win:WinDescT) VerScrollThumb*(scrpos:LONGINT);
(* auf einen bestimmten Wert scrollen *)
BEGIN
  win.textPos:=scrpos;
  win.ShowTextRange(win.textPos,win.textPos+win.lineNo);
  win.UpdateVerScrollBar;
  win.SetCaret;
END VerScrollThumb;  


PROCEDURE (VAR win:WinDescT) HorScroll*(n:LONGINT);
(* horizontal scrollen - n Einheiten *)
BEGIN
  win.colPos:=win.colPos+n;
  IF win.colPos<1 THEN win.colPos:=1
  ELSIF win.colPos>List.MAXLENGTH-win.colNo THEN win.colPos:=List.MAXLENGTH-win.colNo END;
  win.UpdateHorScrollBar;
  win.ShowTextRange(1,win.text.lines);
  win.SetCaret;
END HorScroll;
  

PROCEDURE (VAR win:WinDescT) HorScrollThumb*(scrpos:LONGINT);
(* horizontal auf einen bestimmten Wert scrollen *)
BEGIN
  win.colPos:=scrpos;
  win.UpdateHorScrollBar;
  win.ShowTextRange(1,win.text.lines);
  win.SetCaret;
END HorScrollThumb;
    

PROCEDURE (VAR win:WinDescT) CheckHorzScrollPos*;
(* horizontale Position der Scrollbar überprüfen *)
BEGIN
  WHILE (win.col>=win.colPos+win.colNo-1) & (win.colPos<List.MAXLENGTH-win.colNo) DO
    win.HorScroll(HORZCOLSTEP);
  END;
  WHILE (win.col<=win.colPos) & (win.colPos>1) DO 
    win.HorScroll(-HORZCOLSTEP);
  END;
END CheckHorzScrollPos;


PROCEDURE (VAR win:WinDescT) IndentMarkedBlock*;
VAR
  i,end         : LONGINT;
  t             : ARRAY 2 OF CHAR;
  changed,dummy : BOOLEAN;
  done          : WD.BOOL;
BEGIN
  IF ~win.text.isSelected THEN RETURN END;
  t:=" ";
  changed:=FALSE;
  end:=win.text.markEnd.row;
  IF win.text.markEnd.col<=1 THEN DEC(end) END;
  FOR i:=win.text.markStart.row TO end DO
    dummy:=win.text.InsertInLine(t,1,i);
    changed:=TRUE;
  END;
  IF changed THEN 
    done := WU.InvalidateRect(win.hwnd,NIL,0); (* Aktualisierungsbereich festlegen *)
    win.changed:=TRUE;
  END;
END IndentMarkedBlock;


PROCEDURE (VAR win:WinDescT) UnIndentMarkedBlock*;
VAR
  i,end           : LONGINT;
  len             : LONGINT;
  changed,dummy   : BOOLEAN;
  done            : WD.BOOL;
BEGIN
  localTxt:=" ";
  changed:=FALSE;
  end:=win.text.markEnd.row;
  IF win.text.markEnd.col<=1 THEN DEC(end) END;
  FOR i:=win.text.markStart.row TO end DO
    dummy:=win.text.GetLine(i,localTxt,len);
    IF (len>0) & (localTxt[0]=" ") THEN
      dummy:=win.text.DeleteInLine(1,1,i);
      changed:=TRUE;
    END;
  END;
  IF changed THEN 
    done := WU.InvalidateRect(win.hwnd,NIL,0); (* Aktualisierungsbereich festlegen *)
    win.changed:=TRUE;
  END;
END UnIndentMarkedBlock;


PROCEDURE (VAR win:WinDescT) MarkUpdate*(row,col:LONGINT);
(* Markierung aktualisieren *)
VAR
  swap                   : BOOLEAN;
  oldStartRow,oldEndRow  : LONGINT;
BEGIN
  oldStartRow:=win.text.markStart.row;
  oldEndRow:=win.text.markEnd.row;
  IF win.markDown THEN
    win.text.SetMarkArea(win.text.markStart.row,win.text.markStart.col,row,col);
  ELSE
    win.text.SetMarkArea(row,col,win.text.markEnd.row,win.text.markEnd.col);
  END;
  win.text.CheckMarkRange(swap);
  IF swap THEN win.markDown:=~win.markDown END;
  IF oldStartRow>win.text.markStart.row THEN oldStartRow:=win.text.markStart.row END;
  IF oldEndRow<win.text.markEnd.row THEN oldEndRow:=win.text.markEnd.row END;
  IF (win.text.markStart.row=win.text.markEnd.row) & 
     (win.text.markStart.col=win.text.markEnd.col) THEN win.text.InvalidateMarkArea END;
  win.ShowTextRange(oldStartRow,oldEndRow);
END MarkUpdate;


PROCEDURE (VAR win:WinDescT) DeleteLine*;
(* Zeile löschen *)
VAR
  dmyi,len  : LONGINT;
BEGIN
  win.changed:=TRUE;
  IF win.text.isSelected THEN
    win.text.InvalidateMarkArea;
    win.ShowTextRange(win.text.markStart.row,win.text.markEnd.row);
  END;
  IF win.text.GetLine(win.row, localTxt, len) THEN 
    win.SetUndoAction(ACT_DELLINE);
    GlobMem.NewLineBuf(win.undoData);
    GlobMem.CopyString(win.undoData,localTxt);  
  ELSE
    GlobWin.Beep;
    RETURN;
  END;    
  IF win.text.DeleteLine(win.row) THEN
    win.UpdateVerScrollBar;
    win.ShowTextRange(win.row,win.row+win.lineNo);
  ELSE
    GlobWin.Beep;
  END;    
END DeleteLine;


PROCEDURE (VAR win:WinDescT) InsertText*(source:WD.LPSTR):BOOLEAN;
(* Text an aktueller Caretposition einfügen  *)
(* Rückgabewert : TRUE (erfolgreich), FALSE (Fehler) *)
TYPE
  LargeString=POINTER TO ARRAY 0FFFFFFFH OF CHAR;
VAR 
  dmy                     : WD.LPSTR;
  i,j                     : LONGINT;
  linelen                 : LONGINT;
  merge, update,dmyb      : BOOLEAN;
  offset,xoffset,strlen,r : LONGINT;
  text                    : LargeString;
  done                    : WD.BOOL;
  rect                    : WD.RECT;
  
  PROCEDURE NextLineFromSource(VAR line:ARRAY OF CHAR):BOOLEAN;
  VAR 
    pos, endpos  : LONGINT;
    moreText     : BOOLEAN;
  BEGIN
    pos:=i;
    endpos:=-1;
    WHILE (text^[i]#0DX) & (text^[i]#0AX) & (text^[i]#0X) DO
      IF i-pos<List.MAXLENGTH-1 THEN
        line[i-pos]:=text^[i];
        endpos:=i-pos;
      END;
      INC(i);
    END;
    moreText:=text^[i]#0X;
    IF text^[i]=0DX THEN INC(i) END;
    IF text^[i]=0AX THEN INC(i) END;
    line[endpos+1]:=0X;
    RETURN moreText;
  END NextLineFromSource;
  
BEGIN
  text:=SYSTEM.VAL(LargeString,source);
  i:=0;
  merge:=FALSE;
  offset:=0; xoffset:=0;
  
  IF NextLineFromSource(localTxt) THEN   (* there are more lines *)
    update:=win.text.GetLine(win.row, localStrLine, strlen);
    linelen:=Strings.Length(localTxt);
    IF update THEN
      IF win.col+linelen>=List.MAXLENGTH THEN 
        GlobWin.DisplayError("ERROR","Buffer exceeds maximal linelength");
        RETURN FALSE 
      END;
      IF win.col-1<=strlen THEN     (* at/before 0X *)
        merge:=TRUE;
        dmyb:=win.text.SplitLine(win.row, (win.col)-1, 0);
        ASSERT(dmyb);
      ELSE                                (* after 0X *)
        FOR j:=strlen TO win.col-2 DO
          localStrLine[j]:=" ";
        END;
      END;
      FOR j:=win.col-1 TO win.col-1+linelen DO
        localStrLine[j]:=localTxt[j-win.col+1];
      END;
      dmyb:=win.text.SetLine(win.row, localStrLine);
      ASSERT(dmyb);
      offset:=1;        
    ELSE
      dmyb:=win.text.AddLine(localTxt);
      offset:=win.text.lines-win.row+1;
    END;
    
    WHILE NextLineFromSource(localTxt) DO (* insert whole lines *)
      IF offset=1 THEN
        dmyb:=win.text.InsertLine(localTxt, win.row+offset);
      ELSE
        dmyb:=win.text.InsertNextLine(localTxt);
      END;
      IF ~dmyb THEN GlobWin.Beep END;
      INC(offset);
    END;
    (* insert the last line *)
    dmyb:=win.text.InsertLine(localTxt, win.row+offset);
    IF dmyb & merge THEN
      dmyb:=win.text.MergeLines(win.row+offset);
    END;
    IF ~dmyb THEN GlobWin.Beep END;
    
  ELSE  (* work within a line *)
    update:=win.text.GetLine(win.row, localStrLine, strlen);
    linelen:=Strings.Length(localTxt);
    
    IF update THEN
      IF strlen+linelen>=List.MAXLENGTH THEN 
        GlobWin.DisplayError("ERROR","Buffer exceeds maximal linelength");
        RETURN FALSE; 
      END;
      IF win.col-1<=strlen THEN     (* bei/bevor 0X *)
        FOR j:=strlen TO win.col-1 BY -1 DO (* shift back *)
          localStrLine[j+linelen]:=localStrLine[j];
        END;
        xoffset:=win.col-1;
        FOR j:=win.col-1 TO win.col-1+linelen-1 DO
          localStrLine[j]:=localTxt[j-win.col+1];
        END;
      ELSE                                (* nach 0X *)
        FOR j:=strlen TO win.col-2 DO
          localStrLine[j]:=" ";
        END;                       
        IF win.col+linelen>List.MAXLENGTH THEN 
          GlobWin.DisplayError("ERROR","Buffer exceeds maximal linelength");
          RETURN FALSE; 
        END;
        xoffset:=win.col-1;
        FOR j:=win.col-1 TO win.col-1+linelen DO
          localStrLine[j]:=localTxt[j-win.col+1];
        END;
      END;
      dmyb:=win.text.SetLine( win.row, localStrLine);
      ASSERT(dmyb);
    ELSE
      dmyb:=win.text.AddLine(localTxt);
      ASSERT(dmyb);
    END;
  END;
  win.row:=win.row+offset;
  win.col:=Strings.Length(localTxt)+1+xoffset;
  IF win.textPos+win.lineNo<=win.row THEN 
    win.textPos:=win.row-win.lineNo+1;
    done := WU.InvalidateRect(win.hwnd, rect, 0); (* Aktualisierungsbereich festlegen *)
    win.UpdateVerScrollBar;
  END;
  win.ShowTextRange(win.textPos,win.textPos+win.lineNo);
  win.SetCaret;
  RETURN TRUE;
END InsertText;


PROCEDURE (VAR win:WinDescT) InsertGlobMem*(globMem:WD.HGLOBAL):BOOLEAN;
(* Globalen Speicher Buffer an aktueller Position einfügen *)
VAR
  dummy,lpCopy : LONGINT;
  done         : BOOLEAN;
BEGIN
  lpCopy:=WB.GlobalLock(globMem); (* globalen Speicherbereich sperren *)
  IF lpCopy#WD.NULL THEN 
    done:=win.InsertText(lpCopy);
    dummy:=WB.GlobalUnlock(globMem); (* Sperren aufheben *)
  ELSE 
    done:=FALSE;
  END;
  RETURN done;
END InsertGlobMem;


BEGIN
  colWnd:=WU.GetSysColor(WU.COLOR_WINDOW);
  colWndText:=WU.GetSysColor(WU.COLOR_WINDOWTEXT);
  colHighlight:=WU.GetSysColor(WU.COLOR_HIGHLIGHT);
  colHighlightText:=WU.GetSysColor(WU.COLOR_HIGHLIGHTTEXT);
END TextWin.
