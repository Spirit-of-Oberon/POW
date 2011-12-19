(******************************************************************************
 *  Module WinHnd
 *  
 *  This module implements the Windows window class which is used
 *  for editor windows. This includes registration and deletion of
 *  the window class and the call-back procedure to receive Windows
 *  messages. 
 ******************************************************************************)

MODULE WinHnd;


IMPORT SYSTEM,
       WB:=WinBase, WU:=WinUser, WD:=WinDef, WG:=WinGDI,
       Strings, 
       ListSt, EditWin, TWin:=TextWin, GlobWin, Options, Syntax;


CONST 
  IDM_EDIT=0CACH;
  CLASSNAME = "BoostEdEditor";
  SELECTTIMER=1;
  MAXWIN=100;

VAR
  hFont* : WD.HFONT; 
  hcrIBeam,hcrArrow,hcrWait : WD.HCURSOR;  (* verschieden Cursortypen *)
  langHelpFile* : ARRAY 150 OF CHAR;
  wCounter-                  : INTEGER; (* Anzahl der offenen Fenster *)
  wList-                     : ARRAY MAXWIN OF EditWin.EditWin;

  
PROCEDURE CtrlPressed*():BOOLEAN;
BEGIN
  RETURN WU.GetKeyState(WU.VK_CONTROL)<0;
END CtrlPressed;

PROCEDURE ShiftPressed*():BOOLEAN;
BEGIN
  RETURN WU.GetKeyState(WU.VK_SHIFT)<0;
END ShiftPressed;

(**********************************************************************************************)

PROCEDURE SetWindowOldFont*(wndInx:LONGINT; font:WD.HFONT);
BEGIN
  wList[wndInx].oldFont:=font;
END SetWindowOldFont;

PROCEDURE NewEditWindow*(parent : WD.HWND; 
                         readOnly : BOOLEAN);
(* legt ein neues Fenster zur Texteingabe an *)

VAR
  rect     : WD.RECT;
  hEdit    : WD.HWND;
  win      : EditWin.EditWin;
  done     : WD.BOOL;

BEGIN
  done := WU.GetClientRect(parent,rect);
  hEdit:=WU.CreateWindowExA(WD.NULL,
                            SYSTEM.ADR(CLASSNAME),
                            WD.NULL,
                            WU.WS_CHILD+WU.WS_VISIBLE+WU.WS_VSCROLL+WU.WS_HSCROLL+WU.WS_CLIPCHILDREN,
                            0,0,
                            rect.right,rect.bottom,
                            parent,
                            IDM_EDIT,
                            GlobWin.hInstance,WD.NULL);
  IF (hEdit=0) THEN 
    GlobWin.Beep;
    RETURN 
  ELSE
    win:=EditWin.AssocWinObj(hEdit);
    win.readOnly:=readOnly;
  END;
END NewEditWindow;

(**********************************************************************************************)

PROCEDURE AddText*(win:TWin.WinDesc; text:WD.LPSTR):INTEGER;
(* hängt einen Text an den bestehenden Text an *)
(* Rückgabewert : 1 (erfolgreich), 0 (Fehler)  *)

VAR 
  saverow, savecol, len : LONGINT;
  done                  : BOOLEAN;

BEGIN
  saverow:=win.row;
  savecol:=win.col;
  done:=win.text.GetLineLength(win.text.lines,len);
  win.row:=win.text.lines;
  win.col:=len+1;
  done:=win.InsertText(text);
  win.row:=saverow;
  win.col:=savecol;
  win.SetCaret;
  IF done THEN RETURN 1 ELSE RETURN 0 END;
END AddText;

(**********************************************************************************************)

PROCEDURE Copy*(hEdit:WD.HWND):INTEGER;
(* Kopiert den ausgewählten Text in die Zwischenablage              *)
(* Rückgabewert : 1 (erfolgreich), 0 (nichts ausgewählt oder Fehler *)

VAR
  r            : LONGINT;
  hCopyData    : WD.HANDLE;
  win          : EditWin.EditWin;

BEGIN
  win:=EditWin.AssocWinObj(hEdit);
  IF win=NIL THEN 
    GlobWin.Beep;
    RETURN 0; 
  END;
  win.SetUndoAction(TWin.ACT_NONE);
  IF WU.OpenClipboard(win.hwnd) = 0 THEN RETURN 0 END;
  IF win.SelectionToGlobMem(hCopyData) THEN
    r:=WU.EmptyClipboard();
    r:=WU.SetClipboardData(WU.CF_TEXT, hCopyData);
    r:=WU.CloseClipboard();
    RETURN 1;
  ELSE
    GlobWin.Beep;
    r:=WU.CloseClipboard();
    RETURN 0;
  END;
END Copy;

(**********************************************************************************************)

PROCEDURE Paste*(hEdit:WD.HWND):INTEGER;
(* Fügt den Inhalt der Zwischenablage an der aktuellen Cursorposition ein *)
(* Rückgabewert : 1 (erfolgreich), 0 (kein Text in der Zwischenablage)    *)

VAR
  r                : LONGINT;
  hCopyData        : WD.HANDLE;
  lpCopy           : LONGINT;
  len,n            : LONGINT;
  win              : EditWin.EditWin;
  done             : BOOLEAN;
  reslt            : WD.LRESULT;
  dmyi             : LONGINT;

BEGIN
  win:=EditWin.AssocWinObj(hEdit);
  IF win=NIL THEN 
    GlobWin.Beep;
    RETURN 0;
  END;
  IF WU.OpenClipboard(hEdit) = 0 THEN RETURN 0 END;
  hCopyData := WU.GetClipboardData(WU.CF_TEXT);    
  IF hCopyData = WD.NULL THEN r := WU.CloseClipboard();
    GlobWin.Beep;
    RETURN 0;
  END;
  win.SetUndoAction(TWin.ACT_PASTE);
  IF win.text.isSelected THEN
    win.undoRow:=win.text.markStart.row;
    win.undoCol:=win.text.markStart.col;
    done:=win.SelectionToGlobMem(win.undoData);
    IF ~done THEN GlobWin.Beep END;
    done:=win.CutSelectionFromScreen();
  END;
  done:=win.InsertGlobMem(hCopyData);
  win.undoToRow:=win.row;
  win.undoToCol:=win.col;
  r := WU.CloseClipboard();
  IF ~done THEN 
    GlobWin.Beep;
    RETURN 0;
  END;
  win.changed:= TRUE;
  (* Nachricht senden *)
  reslt:=WU.SendMessageA(WU.GetParent(hEdit),ListSt.PEM_SHOWCHANGED,1,0); 
  win.UpdateVerScrollBar;
  win.ShowTextRange(win.undoRow,win.text.lines);
  RETURN 1; 
END Paste;

(**********************************************************************************************)

PROCEDURE Cut*(hEdit:WD.HWND):INTEGER;
(* schneidet den ausgewählten Text aus und überträgt ihn in die Zwischenablage *)
(* Rückgabewert : 1 (erfolgreich), 0 (nichts ausgewählt oder Fehler            *)

VAR
  r         : LONGINT;
  win       : EditWin.EditWin;
  hCopyData : WD.HANDLE;
  done      : BOOLEAN;

BEGIN
  win:=EditWin.AssocWinObj(hEdit);
  IF win=NIL THEN 
    GlobWin.Beep;
    RETURN 0;
  END;
  win.SetUndoAction(TWin.ACT_CUT);
  win.undoRow:=win.text.markStart.row;
  win.undoCol:=win.text.markStart.col;
  done:=win.SelectionToGlobMem(win.undoData);
  IF ~done THEN 
    GlobWin.Beep;
    RETURN 0;
  END;
  IF WU.OpenClipboard(win.hwnd) = 0 THEN RETURN 0 END;
  IF win.SelectionToGlobMem(hCopyData) THEN
    r:=WU.EmptyClipboard();
    r:=WU.SetClipboardData(WU.CF_TEXT,hCopyData);
  ELSE
    r:=WU.CloseClipboard();
    GlobWin.Beep;
    RETURN 0;
  END;
  r:=WU.CloseClipboard();
  IF win.CutSelectionFromScreen() THEN RETURN 1 ELSE RETURN 0 END;
END Cut;


PROCEDURE MousePos2RowCol(win:TWin.WinDesc; mx,my:LONGINT; VAR row,col,col2:LONGINT);
(* col ist eine gültige Zeilenposition im bestehenden Text und col2 ist die *)
(* Zeilenposition für die Mausposition                                      *)

VAR
  done   : BOOLEAN;
  len    : LONGINT;

BEGIN
  IF win.text.lines=0 THEN row:=-1; col:=1; col2:=1; RETURN END;
  col2:=(mx+win.charwidth DIV 2) DIV win.charwidth + win.colPos;
  row:=my DIV win.lineheight + win.textPos;
  IF row<1 THEN row:=1
  ELSIF row>win.text.lines THEN row:=win.text.lines
  END;
  done:=win.text.GetLineLength(row,len);
  ASSERT(done);
  IF col2<1 THEN col2:=1
  ELSIF col2>ListSt.MAXLENGTH THEN col2:=ListSt.MAXLENGTH END;
  col:=col2;
  IF col>len THEN col:=len+1 END;
END MousePos2RowCol;

(***********************************************************************************************)   

PROCEDURE CreateCaret(win:TWin.WinDesc);
(* Caret erzeugen *)
VAR
  hi  : LONGINT;
  done: WD.BOOL;

BEGIN
(*  IF win.readOnly THEN RETURN END; *)
  IF Options.insert THEN hi:=2 ELSE hi:=win.charwidth END;
  done := WU.CreateCaret(win.hwnd,WD.NULL,hi,win.textHeight); (* Caret erzeugen *)
  IF ~win.text.isSelected THEN 
  done := WU.ShowCaret(win.hwnd); (* Caret anzeigen *)
  END;
  win.SetCaret;
END CreateCaret;

(***********************************************************************************************)   

PROCEDURE DestroyCaret(win:TWin.WinDesc);
(* Caret löschen *)
VAR 
  done : WD.BOOL;

BEGIN
(*  IF win.readOnly THEN RETURN END; *)
  IF ~win.text.isSelected THEN 
  done := WU.HideCaret(win.hwnd);
  END;
  done := WU.DestroyCaret(); 
END DestroyCaret;

(***********************************************************************************************)   

PROCEDURE SelectWord(win:TWin.WinDesc);
(* Wort selektieren *)
VAR
  len,pos  : LONGINT;
  txt      : ARRAY ListSt.MAXLENGTH+1 OF CHAR;

BEGIN
  IF ~win.text.GetLine(win.row,txt,len) THEN 
    GlobWin.Beep;
    RETURN;
  END;
  IF win.text.isSelected THEN
    win.text.InvalidateMarkArea;
    win.ShowTextRange(win.text.markStart.row,win.text.markEnd.row);
  END;
  pos:=win.col-2;
  IF pos>len THEN pos:=len-1 END;
  WHILE (pos>=0) & ~Syntax.IsIdentChar(txt[pos]) DO DEC(pos) END;
  WHILE (pos>=0) & Syntax.IsIdentChar(txt[pos]) DO DEC(pos) END;
  INC(pos);
  win.text.markStart.row:=win.row;
  win.text.markStart.col:=pos+1;
  win.markDown:=TRUE;
  WHILE (pos<len) & Syntax.IsIdentChar(txt[pos]) DO INC(pos) END;
  win.MarkUpdate(win.row,pos+1);
  win.col:=pos+1;
END SelectWord;

(***********************************************************************************************)   

PROCEDURE SelectByMouse(win:TWin.WinDesc);
(* Selektieren mit Maus *)

VAR
  len,row,col,col2 : LONGINT;
  done             : BOOLEAN;

BEGIN
  MousePos2RowCol(win,win.mouseX,win.mouseY,row,col,col2);
  IF row<win.textPos THEN win.VerScroll(row-win.textPos)
  ELSIF row>win.textPos+win.lineNo-1 THEN win.VerScroll(row-(win.textPos+win.lineNo-1)) END;
  done:=win.text.GetLineLength(row,len);
  IF ~done THEN RETURN END;
  IF col>len+1 THEN col:=len+1 END;
  win.MarkUpdate(row,col);
  IF win.markDown THEN
    win.row:=win.text.markEnd.row;
    win.col:=win.text.markEnd.col;
  ELSE
    win.row:=win.text.markStart.row;
    win.col:=win.text.markStart.col;
  END;
  win.CheckHorzScrollPos;
END SelectByMouse;

(***********************************************************************************************)   

PROCEDURE MsgRightButtonDown(win:TWin.WinDesc; x,y:LONGINT);
(* Nachrichtenbehandlung für rechte Maustaste gedrückt *)

VAR
  i1,i2,row,col,col2,len  : LONGINT;
  txt                     : ARRAY ListSt.MAXLENGTH OF CHAR;
  ident                   : ARRAY 40 OF CHAR;
  res                     : WD.BOOL;
  beepOk                  : WD.BOOL;

BEGIN
  IF ~Options.mouse THEN RETURN END;
  MousePos2RowCol(win,x,y,row,col,col2);
  IF ~win.text.GetLine(row,txt,len) THEN GlobWin.Beep() END;
  i1:=col-1;
  WHILE (i1>0) & Syntax.IsIdentChar(txt[i1-1]) DO DEC(i1) END;
  i2:=col-1;
  WHILE (i2<len-1) & Syntax.IsIdentChar(txt[i2+1]) DO INC(i2) END;
  Strings.Copy(txt,ident,i1+1,i2-i1+1);
  res:=WU.WinHelpA(win.hwnd,
                   SYSTEM.ADR(langHelpFile),
                   WU.HELP_PARTIALKEY,
                   SYSTEM.ADR(ident));
END MsgRightButtonDown;

(***********************************************************************************************)   

PROCEDURE MsgLeftButtonDown(win:TWin.WinDesc; x,y:LONGINT);
(* Nachrichtenbehandlung für linke Maustaste gedrückt *)

VAR
  len,row,col,col2  : LONGINT;
  done              : BOOLEAN;
  oldhwnd           : WD.HWND;
  res               : LONGINT;
  ok                : WD.BOOL;

BEGIN
  oldhwnd:=WU.SetFocus(win.hwnd); 
  IF win.text.isSelected THEN 
    win.text.ResetMarkArea;
    ok := WU.InvalidateRect(win.hwnd, NIL, 0);
  END;
  win.mouseX:=x;
  win.mouseY:=y;
  MousePos2RowCol(win,x,y,row,col,col2);
  IF row=-1 THEN RETURN END;
  done:=win.text.GetLineLength(row,len);
  IF ~done THEN RETURN END;
  IF col>len+1 THEN col:=len+1 END;
  win.text.SetMarkArea(row,col,row,col);
  win.markDown:=TRUE;
  win.row:=row;
  win.col:=col;
  win.SetCaret;
  oldhwnd:=WU.SetCapture(win.hwnd);   (* alle Mausnachrichten erhalten *)
  win.MouseCapture:=TRUE;
  win.MarkProcess:=TRUE;
  (*res:=WU.SetTimer(win.hwnd,SELECTTIMER,125,WD.NULL);*)
END MsgLeftButtonDown;

(***********************************************************************************************)   

PROCEDURE MsgMouseMove(win:TWin.WinDesc; x,y:LONGINT);
(* Nachrichtenbehandlung für Mausbewegung *)

VAR
  len,row,col : LONGINT;
  done        : BOOLEAN;

BEGIN
  win.mouseX:=x;
  win.mouseY:=y;
  IF ~win.MouseCapture THEN RETURN END;
  IF win.MarkProcess & (x>=0) & (y>=0) & (x<win.wndwidth) & (y<win.wndheight) THEN
    SelectByMouse(win);
  END;
END MsgMouseMove;

(***********************************************************************************************)   

PROCEDURE MsgLeftDoubleClick(win:TWin.WinDesc; x,y:LONGINT);
(* Nachrichtenbehandlung für linken Maustastendoppelklick *)

VAR
  row,col,col2 : LONGINT;

BEGIN
  SelectWord(win);
END MsgLeftDoubleClick;

(***********************************************************************************************)   

PROCEDURE MsgLeftButtonUp(win:TWin.WinDesc; x,y:LONGINT);
(* Nachrichtenbehandlung für linke Maustaste losgelassen *)

VAR
  res,row,col,col2 : LONGINT;
  swap             : BOOLEAN;
  done             : WD.BOOL;

BEGIN
  IF ~win.MouseCapture THEN RETURN END;
  res:=WU.KillTimer(win.hwnd,SELECTTIMER);
  done := WU.ReleaseCapture();
  win.MouseCapture:=FALSE;
  IF win.MarkProcess THEN   (* end of markprocess *)
    IF (win.text.markStart.row=win.text.markEnd.row) & 
       (win.text.markStart.col=win.text.markEnd.col) THEN 
      win.text.ResetMarkArea; 
      MousePos2RowCol(win,win.mouseX,win.mouseY,row,col,col2);
      win.row:=row;
      win.col:=col2;
      win.SetCaret;
    ELSE
      win.text.CheckMarkRange(swap); 
      win.MarkProcess:=FALSE;                        
    END;
  END;
  (* Nachricht senden *)
  res:=WU.SendMessageA(WU.GetParent(win.hwnd),
                     ListSt.PEM_SHOWLINER,
                     SYSTEM.VAL(WD.WPARAM,win.col),
                     SYSTEM.VAL(WD.LPARAM,win.row)); 
END MsgLeftButtonUp;

(***********************************************************************************************)   

PROCEDURE MsgSelectTimer(win:TWin.WinDesc);
(* Nachrichtenbehandlung für Timer *)

BEGIN
  IF (win.mouseX<0) OR (win.mouseY<0) OR
     (win.mouseX>=win.wndwidth) OR
     (win.mouseY>=win.wndheight) THEN SelectByMouse(win) END;
END MsgSelectTimer;

(***********************************************************************************************)   

PROCEDURE MsgCreate(hwnd:WD.HWND):INTEGER;
(* Nachrichtenbehandlung für WM_CREATE Nachricht *)

VAR
  res      : LONGINT;
  quality  : SHORTINT;
  win      : EditWin.EditWin;
  lfHeight : LONGINT;
  hdc      : WD.HDC;
BEGIN
  IF wCounter<MAXWIN THEN
    INC(wCounter);
  ELSE
    GlobWin.Beep;
    RETURN -1;
  END;
  hcrIBeam:=WU.LoadCursorA(WD.NULL,WU.IDC_IBEAM);
  hcrArrow:=WU.LoadCursorA(WD.NULL,WU.IDC_ARROW);
  hcrWait :=WU.LoadCursorA(WD.NULL,WU.IDC_WAIT);
  NEW(win);                             
  IF win=NIL THEN
    GlobWin.Beep;
    RETURN -1;
  END;   
  NEW(win.text);
  IF win.text=NIL THEN
    GlobWin.Beep;
    DISPOSE(win);
    RETURN -1;
  END;   
  win.Init;
  win.text.Init;  
  wList[wCounter-1]:=win;
  res:=WU.SetWindowLongA(hwnd,0,SYSTEM.VAL(LONGINT,win));
  IF wCounter=1 THEN
    hdc:=WU.GetDC(hwnd);
    lfHeight:=-WB.MulDiv(Options.fontSize,
                         WG.GetDeviceCaps(hdc,WG.LOGPIXELSY),
                         72);
    res:=WU.ReleaseDC(hwnd,hdc);
    hFont:=WG.CreateFontA(lfHeight,
                        0,0,0,0,0,0,0,0,0,0,
                        WG.DEFAULT_QUALITY,
                        WG.FIXED_PITCH,
                        SYSTEM.ADR(Options.fontName));
    IF hFont=0 THEN
      GlobWin.Beep;
      GlobWin.DisplayError("Error","could not create font");
      RETURN -1;
    END;
  END;
  win.hwnd:=hwnd;
  win.hdc:=WU.GetDC(hwnd);    (* Device Kontext für Fensterlebensdauer ermitteln *)
  win.oldFont:=WG.SelectObject(win.hdc,hFont);   (* Schriftwahl *)
  win.text.Init;             (* Listenstruktur initialisieren *)
  win.ScreenConfig;          (* Text/Schriftparameter initialisieren *)
  win.SelectTextColor;
  (* Nachricht senden *)
  res:=WU.SendMessageA(WU.GetParent(hwnd),
                       ListSt.PEM_SHOWLINER,
                       SYSTEM.VAL(WD.WPARAM,win.col),
                       SYSTEM.VAL(WD.LPARAM,win.row)); 
  res:=WU.SendMessageA(WU.GetParent(hwnd),ListSt.PEM_SHOWINSERTMODE,1,0);
  win.ShowTextRange(1,1);
  RETURN 0;
END MsgCreate;

(***********************************************************************************************)   

PROCEDURE MsgDestroy(win:TWin.WinDesc);
(* Nachrichtenbehandlung von WM_DESTROY Nachricht *)

VAR
  dummy    : LONGINT;
  res      : WD.BOOL;
  i        : LONGINT;

BEGIN
  win.oldFont:=WG.SelectObject(win.hdc,win.oldFont); 
  dummy:=WU.ReleaseDC(win.hwnd,win.hdc);
  win.text.ResetContents;
  dummy:=WU.SetWindowLongA(win.hwnd,0,0);
  DISPOSE(win.text);
  i:=0;
  WHILE (i<wCounter) & (wList[i]#win) DO INC(i) END;
  WHILE i<wCounter-1 DO
    wList[i]:=wList[i+1];
    INC(i);               
  END;
  DEC(wCounter);
  IF wCounter=0 THEN
    res:=WG.DeleteObject(hFont);
    hFont:=WD.NULL;
  END;
  DISPOSE(win);     (* delete global record *)
END MsgDestroy;

(***********************************************************************************************)   

(****************************************************************)
(*       CallBack-Funktion zur Nachrichtenbehandlung            *)
(****************************************************************)

PROCEDURE [_APICALL] BoostedWndProc*(hWnd:WD.HWND;
                                   message: WD.UINT;
                                   wParam:WD.WPARAM;
                                   lParam:WD.LPARAM): WD.LRESULT;

VAR
  win         : EditWin.EditWin;
  hdc         : WD.HDC;   (* Handle für Device Kontext für Begin/Endpaint *)
  ps          : WU.PAINTSTRUCT;
  tmpcur      : WD.HCURSOR;
  reslt       : WD.LRESULT;
  dmyb,done   : BOOLEAN;
  dmyhwnd     : WD.HWND;
  code        : WD.WORD; (* Code aus wParam *)
  ok          : WD.BOOL;
  rect        : WD.RECT;
  exp         : LONGINT;

BEGIN
  win:=EditWin.AssocWinObj(hWnd);

  IF win=NIL THEN (* Fenster noch nicht vorhanden *)

    IF message=WU.WM_CREATE THEN (* Neues Fenster anlegen *)
      RETURN MsgCreate(hWnd);
    ELSE
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)
    END;

  ELSE (* Fenster bereits vorhanden *)

    ASSERT(win IS EditWin.EditWin);

  
    (****** WM_PAINT *******)
    IF message=WU.WM_PAINT THEN (* WM_PAINT *)

      hdc:=WU.BeginPaint(hWnd, ps);
      win.ShowTextRange(1,win.text.lines);
      ok := WU.EndPaint(hWnd, ps);
      
    (****** WM_ERASEBKGND *******)
    ELSIF message=WU.WM_ERASEBKGND THEN 

      RETURN 1;

    (****** WM_DESTROY *******)
    ELSIF message=WU.WM_DESTROY THEN

      MsgDestroy(win);
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)

    (****** WM_VSCROLL *******)
    ELSIF message=WU.WM_VSCROLL THEN 

  
      CASE SYSTEM.LOWORD(wParam) OF
        WU.SB_PAGEDOWN:
          win.VerScroll(win.lineNo);
      | WU.SB_PAGEUP:
          win.VerScroll(-win.lineNo);
      | WU.SB_LINEDOWN:
          win.VerScroll(1);
      | WU.SB_LINEUP:
          win.VerScroll(-1);
      | WU.SB_THUMBPOSITION,WU.SB_THUMBTRACK: 
          win.VerScrollThumb(SYSTEM.HIWORD(wParam)+1);
      ELSE
      END;
   
    (****** WM_HSCROLL *******)
    ELSIF message=WU.WM_HSCROLL THEN

      CASE SYSTEM.LOWORD(wParam) OF
        WU.SB_PAGEDOWN:
          win.HorScroll(win.colNo);
      | WU.SB_PAGEUP:
          win.HorScroll(-win.colNo);
      | WU.SB_LINEDOWN:
          win.HorScroll(1);
      | WU.SB_LINEUP:
          win.HorScroll(-1);
      | WU.SB_THUMBPOSITION,WU.SB_THUMBTRACK: 
          win.HorScrollThumb(SYSTEM.HIWORD(wParam)+1);
      ELSE
      END;

    (****** WM_SETCURSOR *******)
    ELSIF message=WU.WM_SETCURSOR THEN

      IF wParam = WU.HTCLIENT THEN (* Cursor in Clientbereich ändern *)
        exp := WU.MessageBoxA(hWnd, SYSTEM.ADR("Cursor"), SYSTEM.ADR("!!!"), WU.MB_OK); 
        tmpcur:=WU.SetCursor(hcrIBeam)
      ELSE 
        tmpcur:=WU.SetCursor(hcrArrow)
      END;
   
    (****** WM_KEYDOWN *******)
    ELSIF message=WU.WM_KEYDOWN THEN

      CASE wParam OF (* virtuellen Tastencode auslesen *)
        WU.VK_LEFT: 
          IF CtrlPressed() THEN 
            win.CursIdentLeft(ShiftPressed());
          ELSE 
            win.CursLeft(ShiftPressed());
          END;
      | WU.VK_RIGHT:
          IF CtrlPressed() THEN 
            win.CursIdentRight(ShiftPressed());
          ELSE 
            win.CursRight(ShiftPressed());
          END;
      | WU.VK_UP:
          win.CursUp(ShiftPressed());
      | WU.VK_DOWN:
          win.CursDown(ShiftPressed());
      | WU.VK_HOME:
          IF CtrlPressed() THEN 
            win.CursTextStart(ShiftPressed());
          ELSE
            win.CursPos1(ShiftPressed());
          END;
      | WU.VK_END:
          IF CtrlPressed() THEN 
            win.CursTextEnd(ShiftPressed());
          ELSE
            win.CursEnd(ShiftPressed());
          END;
      | WU.VK_DELETE: 
          IF win.readOnly THEN RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam) END;
          reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWCHANGED,1,0);
          dmyb:=win.DeleteChar();
          IF ~dmyb THEN RETURN 0 END;
      | WU.VK_INSERT:                
          IF win.readOnly THEN RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam) END;
          Options.insert:=~Options.insert;
          DestroyCaret(win);         
          CreateCaret(win);
          IF Options.insert THEN 
            reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWINSERTMODE,1,0); 
          ELSE 
            reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWINSERTMODE,0,0);
          END;      
      | WU.VK_PRIOR : 
          IF CtrlPressed() THEN
          ELSE
            win.CursPgUp(ShiftPressed());
          END;
      | WU.VK_NEXT:
          IF CtrlPressed() THEN
          ELSE
            win.CursPgDn(ShiftPressed());
          END;
      | ORD("I"):
          IF win.readOnly THEN RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam) END;
          IF CtrlPressed() THEN win.IndentMarkedBlock END;
      | ORD("U"):
          IF win.readOnly THEN RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam) END;
          IF CtrlPressed() THEN win.UnIndentMarkedBlock END;
      | ORD("Y"):
          IF win.readOnly THEN RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam) END;
          IF CtrlPressed() THEN win.DeleteLine END; (* ctrl-y *)
      ELSE
        RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam);
      END;
                     
    (****** WM_ACTIVATE *******)
    ELSIF message=WU.WM_ACTIVATE THEN

      code := SYSTEM.LOWORD(wParam);
      IF (code = WU.WA_ACTIVE) OR (code = WU.WA_CLICKACTIVE) THEN
        dmyhwnd:=WU.SetFocus(win.hwnd);  
        GlobWin.Beep;
      END;
      RETURN WU.DefWindowProcA(hWnd,message,wParam,lParam);
    
    (****** WM_SETFOCUS *******)
    ELSIF message=WU.WM_SETFOCUS THEN
      CreateCaret(win);
      reslt:=WU.SendMessageA(WU.GetParent(win.hwnd),ListSt.PEM_SHOWLINER,SYSTEM.VAL(WD.WPARAM,win.col),
                          SYSTEM.VAL(WD.LPARAM,win.row));
      IF Options.insert THEN 
        reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWINSERTMODE,1,0); 
      ELSE 
        reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWINSERTMODE,0,0);
      END;      
    
    (****** WM_TIMER *******)
    ELSIF message=WU.WM_TIMER THEN
      IF wParam = SELECTTIMER THEN MsgSelectTimer(win) END;
                   
    (****** WM_KILLFOCUS *******)
    ELSIF message=WU.WM_KILLFOCUS THEN
      DestroyCaret(win);
   
    (****** WM_LBUTTONDOWN *******)
    ELSIF message=WU.WM_LBUTTONDOWN THEN
    (*  IF win.readOnly THEN RETURN 0 END; *)
      MsgLeftButtonDown(win,SYSTEM.LOWORD(lParam),SYSTEM.HIWORD(lParam));
   
    (****** WM_RBUTTONDOWN *******)
    ELSIF message=WU.WM_RBUTTONDOWN THEN
      MsgRightButtonDown(win,SYSTEM.LOWORD(lParam),SYSTEM.HIWORD(lParam));
   
    (****** WM_LBUTTONUP *******)
    ELSIF message=WU.WM_LBUTTONUP THEN
   (*   IF win.readOnly THEN RETURN 0 END; *)
      MsgLeftButtonUp(win,SYSTEM.LOWORD(lParam),SYSTEM.HIWORD(lParam));
   
    (****** WM_MOUSEMOVE *******)
    ELSIF message=WU.WM_MOUSEMOVE THEN
  (*  IF win.readOnly THEN RETURN 0 END; *)
      MsgMouseMove(win,SYSTEM.LOWORD(lParam),SYSTEM.HIWORD(lParam));
                        
    (****** WM_LBUTTONDBLCLK oder WM_MBUTONDOWN *******)
    ELSIF (message=WU.WM_LBUTTONDBLCLK) OR (message=WU.WM_MBUTTONDOWN) THEN
      IF win.readOnly THEN 
        reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_DOUBLECLICK,0,0); 
      ELSE
        MsgLeftDoubleClick(win,SYSTEM.LOWORD(lParam),SYSTEM.HIWORD(lParam));
      END;
                   
    (****** WM_CHAR *******)
    ELSIF message=WU.WM_CHAR THEN
      IF (wParam=32) & CtrlPressed() THEN 
        SelectWord(win);
        RETURN 0;
      END;
      IF win.readOnly THEN RETURN 0 END;
      win.changed:=TRUE;
      reslt:=WU.SendMessageA(WU.GetParent(hWnd),ListSt.PEM_SHOWCHANGED,1,0);
      IF win.text.isSelected & 
         ~((wParam=WU.VK_ESCAPE) OR (wParam=WU.VK_BACK) OR CtrlPressed()) THEN   
        win.SetUndoAction(TWin.ACT_OVERWRITESELECTION);
        win.undoRow:=win.text.markStart.row;
        win.undoCol:=win.text.markStart.col;
        done:=win.SelectionToGlobMem(win.undoData);
        done:=win.CutSelectionFromScreen();
        win.text.ResetMarkArea;
      END;
      CASE wParam OF
        WU.VK_BACK:   (* Backspace *)
          dmyb:=win.Key_Back(); IF ~dmyb THEN RETURN 0 END;
          IF ListSt.hs THEN win.CheckHorzScrollPos END;
      | WU.VK_TAB:  (* Tabulator *)
          IF CtrlPressed() THEN RETURN 0 END;
          dmyb:=win.Key_Tab(); IF ~dmyb THEN RETURN 0 END;
          IF ListSt.hs THEN win.CheckHorzScrollPos END;
      | WU.VK_RETURN: (* SplitLines(); oder NewLine(); *)
          win.Key_Return;
          IF ListSt.hs THEN win.CheckHorzScrollPos END;
      | WU.VK_ESCAPE:
          IF win.text.isSelected THEN (* win.IsSelected:=FALSE;*)
            win.text.ResetMarkArea;
            ok := WU.InvalidateRect(hWnd, NIL,0);
            RETURN 0;
          END;
      ELSE 
        IF (wParam<32) & CtrlPressed() THEN RETURN 0 END;
        IF win.col+1>ListSt.MAXLENGTH THEN 
          GlobWin.Beep;
          RETURN 0;
        END;
        win.Key_Char(SYSTEM.VAL(CHAR,wParam));  
        IF ListSt.hs THEN win.CheckHorzScrollPos END;
      END  

    ELSE (* Default Window Procedure *)
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)
    END;
  END;
  RETURN 0;

END BoostedWndProc;

PROCEDURE RegisterClass*():BOOLEAN;
VAR
  wc : WU.WNDCLASS;
BEGIN
  wc.style:=0; 
  wc.style:=SYSTEM.BITOR(wc.style,WU.CS_OWNDC);
  wc.style:=SYSTEM.BITOR(wc.style,WU.CS_DBLCLKS); 
  wc.lpfnWndProc   := BoostedWndProc; 
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 4;  
  wc.hInstance     := GlobWin.hInstance;
  wc.hIcon         := WD.NULL;
  wc.hCursor       := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WD.NULL; 
  wc.lpszMenuName  := WD.NULL; 
  wc.lpszClassName := SYSTEM.ADR(CLASSNAME);
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE UnregisterClass*();
VAR
  res: WD.BOOL;
BEGIN
  res:=WU.UnregisterClassA(SYSTEM.ADR(CLASSNAME),GlobWin.hInstance);
END UnregisterClass;

PROCEDURE CloseAllWindows*();
VAR
  res: WD.BOOL;
BEGIN
  WHILE wCounter>0 DO
    res:=WU.DestroyWindow(wList[0].hwnd);
  END;
END CloseAllWindows;
 
BEGIN
  langHelpFile:='';
END WinHnd.
