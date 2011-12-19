(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE TextPane;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, WG:=WinGDI, 
       GH:=GlobHandles, Utils, Panes, WinUtils;

CONST 
  TextPaneClassTxt*="TextPane";

TYPE
  TextPane*=RECORD (Panes.Pane)
    font*,fOld:WD.HFONT;
    backBrush*:WD.HBRUSH;
    charHeight*:LONGINT;
    charWidth*:LONGINT;
    cursOn*:BOOLEAN;
    hdc*:WD.HDC;
  END;
  TextPaneP*=POINTER TO TextPane;


PROCEDURE (p:TextPaneP) PaintBack*(hdc:WD.HDC);
BEGIN
END PaintBack;

PROCEDURE (p:TextPaneP) OpenTextPane*(titel:ARRAY OF CHAR; 
                                      exStyleFlags:LONGINT;
                                      styleFlags:LONGINT;
                                      classTxt:ARRAY OF CHAR):BOOLEAN;
VAR
  dummy1:INTEGER; 
  dummy4:WD.BOOL;
  dummy:LONGINT;
  tmetric:WG.TEXTMETRIC;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  p.cursOn:=FALSE;
  p.cursSav:=FALSE;
  p.backBrush:=WG.GetStockObject(WG.WHITE_BRUSH);
  p.CreateWindow(titel,exStyleFlags,styleFlags,classTxt);
  IF p.hwnd#WD.NULL THEN
    dummy:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
    p.keyBuffer.Init();
    p.font:=WinUtils.GetReasonableFixedFont();
    ASSERT(p.font#WD.NULL);
    p.hdc:=WU.GetDC(p.hwnd);
    ASSERT(p.hdc#WD.NULL);
    p.fOld:=WG.SelectObject(p.hdc,p.font);
    ASSERT(p.fOld#WD.NULL);
    dummy4:=WG.GetTextMetricsA(p.hdc,tmetric);
    p.charWidth:=tmetric.tmAveCharWidth;
    p.charHeight:=tmetric.tmHeight;               
    p.ManageScrollBars;
  END;
  RETURN(p.hwnd#WD.NULL);
END OpenTextPane;

PROCEDURE (p:TextPaneP) Shutdown*():LONGINT;
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WG.DeleteObject(p.font);
  RETURN p.Shutdown^();
END Shutdown;

PROCEDURE (p:TextPaneP) PositionCursor*();
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.cursOn THEN dummy:=WU.SetCaretPos(0,p.charHeight-2); END;
END PositionCursor;

PROCEDURE (p:TextPaneP) CursorOn*;
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.focused THEN
    dummy:=WU.CreateCaret(p.hwnd,0,p.charWidth,2);
    p.cursOn:=TRUE;
    p.PositionCursor();
    dummy:=WU.ShowCaret(p.hwnd);
  ELSE
    p.cursSav:=TRUE;
  END;
END CursorOn;

PROCEDURE (p:TextPaneP) CursorOff*;
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.cursOn THEN
    p.cursOn:=FALSE;
    dummy:=WU.DestroyCaret();
  END;
  p.cursSav:=FALSE;
END CursorOff;

PROCEDURE (p:TextPaneP) IsCursorOn*():BOOLEAN;
BEGIN
  RETURN p.cursOn;
END IsCursorOn;

PROCEDURE (p:TextPaneP) ReleaseHandles*();
VAR
  dummy:LONGINT;
BEGIN
  IF p.handlesReleased THEN RETURN END;
  p.ReleaseHandles^;
  p.fOld:=WG.SelectObject(p.hdc,p.fOld);
  ASSERT(p.fOld#WD.NULL);
  dummy:=WU.ReleaseDC(p.hwnd,p.hdc);   
  ASSERT(dummy=1);
END ReleaseHandles;

PROCEDURE (p:TextPaneP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),TextPaneClassTxt) THEN
    RETURN TRUE;
  END;
  wc.style := WU.CS_OWNDC;    
  wc.lpfnWndProc := Panes.PaneHandleEvent;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 4;
  wc.hInstance := GH.GetAppInstanceHandle();            
  wc.hIcon := WD.NULL; 
  wc.hCursor := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WD.NULL; (*W.GetStockObject(W.WHITE_BRUSH);*)
  wc.lpszMenuName := WD.NULL;
  wc.lpszClassName := SYSTEM.ADR(TextPaneClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

END TextPane.
