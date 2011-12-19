(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE StdWins;

IMPORT Panes,Utils,
       WD:=WinDef,WU:=WinUser,WG:=WinGDI,
       SYSTEM,Strings,Process,WinUtils;

CONST
  WAITWIDTH=300;
  WAITHEIGHT=100;

TYPE
  WaitWinT*=RECORD (Panes.Pane);
    range,current:LONGINT;
    blueBrush:WD.HBRUSH;
    shown:BOOLEAN;
    width:LONGINT;
  END;
  WaitWin*=POINTER TO WaitWinT;

PROCEDURE (VAR p:WaitWinT) Init*;
BEGIN
  p.Init^;
  p.range:=1;
  p.current:=0;
  p.shown:=FALSE;
END Init;

PROCEDURE (p:WaitWin) Open*():BOOLEAN;
VAR
  flags:LONGINT;
  dummy:LONGINT;
  p1,p2:Panes.Point;
  logBrush:WG.LOGBRUSH;
  posx,posy:INTEGER;
  rect:WD.RECT;
  dummyb:WD.BOOL;
BEGIN
  IF ~p.RegisterClass() THEN RETURN FALSE END;
  flags:=SYSTEM.BITOR(WU.WS_VISIBLE,WU.WS_POPUP);
  flags:=SYSTEM.BITOR(flags,WU.WS_DLGFRAME);
  posx:=100; posy:=100;
  p1.Init(posx,posy); p2.Init(posx+WAITWIDTH-1,posy+WAITHEIGHT-1);
  p.SetFrame(p1,p2);
  p.CreateWindow("Please Wait",0,flags,Panes.PaneClassTxt);
  IF p.hwnd#WD.NULL THEN
    dummy:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
    logBrush.lbStyle:=WG.BS_SOLID;
    logBrush.lbColor:=WinUtils.COLOR_BLUE;
    logBrush.lbHatch:=0;
    p.blueBrush:=WG.CreateBrushIndirect(logBrush);
    ASSERT(p.blueBrush#WD.NULL);
    dummyb:=WU.InvalidateRect(p.hwnd,NIL,1);
    p.SetInputFocus;
    dummyb:=WU.GetClientRect(p.hwnd,rect);
    p.width:=rect.right;
    REPEAT Process.Yield UNTIL p.shown;
  END;
  RETURN p.hwnd#WD.NULL;
END Open;

PROCEDURE (p:WaitWin) ReleaseHandles*;
VAR
  res:WD.BOOL;
BEGIN
  IF ~p.handlesReleased THEN
    res:=WG.DeleteObject(p.blueBrush);
    p.ReleaseHandles^;
  END;
END ReleaseHandles;

PROCEDURE (p:WaitWin) SetRange*(x:LONGINT);
BEGIN
  p.range:=x;
END SetRange;

PROCEDURE (p:WaitWin) Current*(x:LONGINT);
VAR
  dummy:WD.BOOL;
BEGIN
  p.current:=x;
  dummy:=WU.InvalidateRect(p.hwnd,NIL,0);
  Process.Yield;
END Current;

PROCEDURE (p:WaitWin) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  dummy:WD.BOOL;
  dummyl:LONGINT;
  x,y,w,h:LONGINT;
  disp:LONGINT;
  old1,old2:WD.HANDLE;
BEGIN
  old1:=WG.SelectObject(hdc,p.blueBrush);
  old2:=WG.SelectObject(hdc,WinUtils.BLUE_PEN);
  dummyl:=WG.SetBkMode(hdc,WG.TRANSPARENT);
  dummyl:=WG.SetTextAlign(hdc,WG.TA_CENTER);
  w:=p.width*2 DIV 3;
  x:=(p.width-w) DIV 2;
  y:=(WAITHEIGHT DIV 5)*3;
  h:=WAITHEIGHT DIV 6;
  dummyl:=WG.MoveToEx(hdc,x,y,NIL);
  dummy:=WG.LineTo(hdc,x+w-1,y);
  dummy:=WG.LineTo(hdc,x+w-1,y+h-1);
  dummy:=WG.LineTo(hdc,x,y+h-1);
  dummy:=WG.LineTo(hdc,x,y);
  disp:=SHORT(w*p.current DIV p.range);
  dummy:=WG.Rectangle(hdc,x,y,x+disp,y+h);
  dummy:=WG.TextOutA(hdc,
                   p.width DIV 2,
                   WAITHEIGHT DIV 5,
                   SYSTEM.ADR("please wait"),
                   11);
  old1:=WG.SelectObject(hdc,old1);
  old2:=WG.SelectObject(hdc,old2);
  p.shown:=TRUE;
END Paint;

PROCEDURE (p:WaitWin) Destroy*;
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.DestroyWindow(p.hwnd);
END Destroy;

END StdWins.
