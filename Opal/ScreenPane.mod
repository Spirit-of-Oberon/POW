(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE ScreenPane;

IMPORT WD:=WinDef, WU:=WinUser, WG:=WinGDI, WB:=WinBase,
       Strings, Panes, TextPane, SYSTEM, 
       Utils, WinUtils, Process, P:=Print, Float;

CONST
  MAXLINE*=25;
  MAXCOLUMN*=80;
  emptyLine="                                                                                                         ";

  CURSUP*=26X;
  CURSDOWN*=28X;
  CURSLEFT*=25X;
  CURSRIGHT*=27X;
  INSERT*=2DX;
  DELETE*=2EX;
  HOME*=24X;
  ENDKEY*=23X;
  PAGEUP*=21X;
  PAGEDOWN*=22X;
  F1*=70X; F2*=71X; F3*=72X; F4*=73X;
  F5*=74X; F6*=75X; F7*=76X; F8*=77X;
  F9*=78X; F10*=79X;F11*=7AX;F12*=7BX;
  F13*=0D4X;F14*=0D5X;F15*=0D6X;F16*=0D7X;
  F17*=0D8X;F18*=0D9X;F19*=0DAX;F20*=0DBX;
  F21*=0DCX;F22*=0DDX;F23*=0DEX;F24*=0DFX;
  ENTER*=0DX;
  ESC*=1BX;
  TAB*=9X;
  BACKSPACE*=8X;
  INPUTINVALID*=0X;

  INPT_TEXT       =0; INPT_LETTER=1;
  INPT_CARDINAL   =2; INPT_NUMBER=3;
  INPT_ddmmyy     =4; INPT_hhmm  =5;
  INPT_YESNO      =6; INPT_UPCASE=7;
  INPT_UPCASE_CARD=8; INPT_ddmm__=9;
  INPT_REAL       =10;

TYPE
  ScreenPane*=RECORD (TextPane.TextPane)
    screen*:ARRAY MAXLINE, MAXCOLUMN OF CHAR;
    foreCol*:ARRAY MAXLINE, MAXCOLUMN OF WD.COLORREF;
    backCol*:ARRAY MAXLINE, MAXCOLUMN OF WD.COLORREF;
    curForeCol:WD.COLORREF;
    curBackCol:WD.COLORREF;
    cursX-,cursY-:LONGINT;
    textTopX,textTopY:LONGINT;
    manageInProgress:BOOLEAN;
    scrollXVis,scrollYVis:BOOLEAN;
    scrollXHeight,scrollYWidth:LONGINT;
    maxClientWidth*,maxClientHeight*:LONGINT;
    oldFont:WD.HFONT;
  END;
  ScreenPaneP*=POINTER TO ScreenPane;

PROCEDURE (p:ScreenPaneP) ClearBuffers();
VAR
  i,j:INTEGER;
BEGIN
  FOR i:=0 TO MAXCOLUMN-1 DO 
    FOR j:=0 TO MAXLINE-1 DO 
      p.screen[j,i]:=" ";
      p.foreCol[j,i]:=p.curForeCol;
      p.backCol[j,i]:=p.curBackCol;
    END;
  END;
END ClearBuffers;

PROCEDURE (VAR p:ScreenPane) Init*;
BEGIN
  p.Init^;
  p.framed:=TRUE;
END Init;

PROCEDURE (p:ScreenPaneP) Open*():BOOLEAN;
VAR
  i,j:INTEGER;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;
  p.cursX:=1;
  p.cursY:=1;
  p.textTopX:=0;
  p.textTopY:=0;
  p.curForeCol:=WinUtils.COLOR_BLACK;
  p.curBackCol:=WinUtils.COLOR_WHITE;
  p.scrollXVis:=TRUE;
  p.scrollYVis:=TRUE;
  p.scrollXHeight:=WU.GetSystemMetrics(WU.SM_CYHSCROLL);
  p.scrollYWidth:=WU.GetSystemMetrics(WU.SM_CXVSCROLL);
  p.manageInProgress:=FALSE;
  p.ClearBuffers;
  flags:=SYSTEM.BITOR(WU.WS_CHILD,WU.WS_CLIPSIBLINGS);
  flags:=SYSTEM.BITOR(flags,WU.WS_VISIBLE);
  flags:=SYSTEM.BITOR(flags,WU.WS_HSCROLL);
  flags:=SYSTEM.BITOR(flags,WU.WS_VSCROLL);
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION); END;
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER);  END;
  IF p.OpenTextPane("a Screenpane",0,flags,TextPane.TextPaneClassTxt) THEN
    p.maxClientWidth:=MAXCOLUMN*p.charWidth;
    p.maxClientHeight:=MAXLINE*p.charHeight;
    p.maxWidth:=p.maxClientWidth+2;   (* framed *)
    p.maxHeight:=p.maxClientHeight+2; (* framed *)
    p.oldFont:=WG.SelectObject(p.hdc,p.font);
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Open;

PROCEDURE (p:ScreenPaneP) ReleaseHandles*();
BEGIN
  p.oldFont:=WG.SelectObject(p.hdc,p.oldFont);
  p.ReleaseHandles^();
END ReleaseHandles;

PROCEDURE (p:ScreenPaneP) PositionCursor*();
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.cursOn THEN 
    dummy:=WU.SetCaretPos((p.cursX-p.textTopX-1)*p.charWidth,
                          (p.cursY-p.textTopY)*p.charHeight-2);
  END;
END PositionCursor;

PROCEDURE (p:ScreenPaneP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  sLeft,sRight:LONGINT;
  zBottom,zTop:LONGINT;
  i,s,sOld:LONGINT;
  dummy:WD.BOOL;
  dummyl:LONGINT;
  left,x,y:LONGINT;
  oldCol:WD.COLORREF;
  rect:WD.RECT;
  back,fore:WD.COLORREF;
BEGIN
  sLeft:=paint.rcPaint.left DIV p.charWidth+p.textTopX;
  IF sLeft<0 THEN sLeft:=0 END;
  zTop:=paint.rcPaint.top DIV p.charHeight+p.textTopY;
  IF zTop<0 THEN zTop:=0 END;
  sRight:=paint.rcPaint.right DIV p.charWidth + p.textTopX + 1;
  IF sRight>MAXCOLUMN-1 THEN 
    sRight:=MAXCOLUMN-1; 
    rect.left:=(MAXCOLUMN-p.textTopX)*p.charWidth;
    rect.top:=0;
    rect.right:=paint.rcPaint.right;
    rect.bottom:=paint.rcPaint.bottom;
    dummyl:=WU.FillRect(p.hdc,rect,WinUtils.GRAY_BRUSH);
  END;
  zBottom:=paint.rcPaint.bottom DIV p.charHeight + p.textTopY + 1;
  IF zBottom>MAXLINE-1 THEN
    zBottom:=MAXLINE-1;
    rect.left:=0;
    rect.top:=(MAXLINE-p.textTopY)*p.charHeight;
    rect.right:=paint.rcPaint.right;
    rect.bottom:=paint.rcPaint.bottom;
    dummyl:=WU.FillRect(p.hdc,rect,WinUtils.GRAY_BRUSH);
  END;
  IF zTop>MAXLINE-1 THEN RETURN END;
  IF sLeft>MAXCOLUMN-1 THEN RETURN END;
  ASSERT(sLeft>=0);
  ASSERT(sLeft<MAXCOLUMN);
  ASSERT(zTop>=0);
  ASSERT(zTop<MAXLINE);
  left:=(sLeft-p.textTopX)*p.charWidth;
  y:=(zTop-p.textTopY)*p.charHeight;
  back:=-1; 
  fore:=-1;
  FOR i:=zTop TO zBottom DO
    x:=left;
    s:=sLeft;
    sOld:=s;
    WHILE s<=sRight DO
      WHILE (s<=sRight) & (p.foreCol[i,s]=fore) & (p.backCol[i,s]=back) DO INC(s) END;
      IF s-sOld>0 THEN 
        dummy:=WG.TextOutA(p.hdc,x,y,SYSTEM.ADR(p.screen[i,sOld]),s-sOld);
        x:=x+(s-sOld)*p.charWidth;
      END;
      IF s<=sRight THEN
        back:=p.backCol[i,s];
        fore:=p.foreCol[i,s];
        ASSERT(p.hdc#WD.NULL);
        oldCol:=WG.SetTextColor(p.hdc,fore);
        oldCol:=WG.SetBkColor(p.hdc,back);
      END;
      sOld:=s;
    END;
    y:=y+p.charHeight;
  END;  
END Paint;

PROCEDURE (p:ScreenPaneP) ManageScrollBars*();
VAR
  hx,hy:LONGINT;
  rect:WD.RECT;
  dummyl:LONGINT;
  dummy:WD.BOOL;
BEGIN
  IF ~p.manageInProgress THEN
    p.manageInProgress:=TRUE;
    dummy:=WU.GetClientRect(p.hwnd,rect);
    hx:=rect.right;
    hy:=rect.bottom;
    IF p.scrollXVis THEN hy:=hy+p.scrollXHeight END;
    IF p.scrollYVis THEN hx:=hx+p.scrollYWidth END;
    IF (hx>=p.maxClientWidth) & (hy>=p.maxClientHeight) THEN
      p.scrollXVis:=FALSE;
      p.scrollYVis:=FALSE;
    ELSIF (hx<p.maxClientWidth) & (hy-p.scrollXHeight>=p.maxClientHeight) THEN
      p.scrollXVis:=TRUE;
      p.scrollYVis:=FALSE;
    ELSIF (hy<p.maxClientHeight) & (hx-p.scrollYWidth>=p.maxClientWidth) THEN
      p.scrollXVis:=FALSE;
      p.scrollYVis:=TRUE;
    ELSE
      p.scrollXVis:=TRUE;
      p.scrollYVis:=TRUE;
    END;
    IF p.scrollXVis THEN hy:=hy-p.scrollXHeight; END;
    IF p.scrollYVis THEN hx:=hx-p.scrollYWidth END;
    IF p.scrollXVis THEN
      dummy:=WU.SetScrollRange(p.hwnd,WU.SB_HORZ,1,MAXCOLUMN-hx DIV p.charWidth+1,1); 
    ELSE
      dummy:=WU.SetScrollRange(p.hwnd,WU.SB_HORZ,0,0,0); 
    END;  
    IF p.scrollYVis THEN
      dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,1,MAXLINE-hy DIV p.charHeight+1,1); 
    ELSE
      dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,0,0,0); 
    END; 
    dummyl:=p.ManageVerticalScroll(1000,0);
    dummyl:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,WU.GetScrollPos(p.hwnd,WU.SB_VERT),1);
    dummyl:=p.ManageHorizontalScroll(1000,0);
    dummyl:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,WU.GetScrollPos(p.hwnd,WU.SB_HORZ),1);
    p.manageInProgress:=FALSE;
  END;
END ManageScrollBars;
         
PROCEDURE (p:ScreenPaneP) ManageHorizontalScroll*(code:LONGINT; value:LONGINT):LONGINT;
VAR
  oldpos:LONGINT;
  rect:WD.RECT;
  oldtop:LONGINT;
  dummy:WD.BOOL;
BEGIN
  CASE code OF
    WU.SB_THUMBTRACK:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,value,1);
  | WU.SB_LINEDOWN,WU.SB_PAGEDOWN:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,0,0);
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,oldpos+1,1);
  | WU.SB_LINEUP,WU.SB_PAGEUP:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,0,0);
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,oldpos-1,1);
  ELSE
  END;
  oldtop:=p.textTopX;
  IF p.scrollXVis THEN 
    p.textTopX:=WU.GetScrollPos(p.hwnd,WU.SB_HORZ)-1;
  ELSE
    p.textTopX:=0;
  END;
  IF oldtop#p.textTopX THEN
    rect.left:=0;
    rect.right:=p.maxClientWidth;
    rect.top:=0;
    rect.bottom:=p.maxClientHeight;
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
    dummy:=WU.UpdateWindow(p.hwnd);   
    p.PositionCursor();
  END;
  RETURN 0;
END ManageHorizontalScroll;

PROCEDURE (p:ScreenPaneP) ManageVerticalScroll*(code:LONGINT; value:LONGINT):LONGINT;
VAR
  oldpos:LONGINT;
  rect:WD.RECT;
  oldtop:LONGINT;
  dummy:WD.BOOL;
BEGIN
  CASE code OF
    WU.SB_THUMBTRACK:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,value,1);
  | WU.SB_LINEDOWN,WU.SB_PAGEDOWN:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldpos+1,1);
  | WU.SB_LINEUP,WU.SB_PAGEUP:
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldpos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldpos-1,1);
  ELSE
  END;
  oldtop:=p.textTopY;
  IF p.scrollYVis THEN 
    p.textTopY:=WU.GetScrollPos(p.hwnd,WU.SB_VERT)-1;
  ELSE
    p.textTopY:=0;
  END;
  IF oldtop#p.textTopY THEN
    rect.left:=0;
    rect.right:=p.maxClientWidth;
    rect.top:=0;
    rect.bottom:=p.maxClientHeight;
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
    dummy:=WU.UpdateWindow(p.hwnd);   
    p.PositionCursor();
  END;
  RETURN 0;
END ManageVerticalScroll;

PROCEDURE (p:ScreenPaneP) CopyAllToClipboard*();
VAR
  dummy:WD.BOOL;
  i:INTEGER;
  mem:WD.HANDLE;
  memA:LONGINT;
BEGIN
  IF WU.OpenClipboard(p.hwnd)#0 THEN 
    dummy:=WU.EmptyClipboard();
    mem:=WB.GlobalAlloc(WB.GMEM_FIXED,(MAXCOLUMN+2)*MAXLINE+1);
    IF mem# WD.NULL THEN
      memA:=WB.GlobalLock(mem); 
      IF memA#0 THEN
  FOR i:=0 TO MAXLINE-1 DO
    SYSTEM.MOVE(SYSTEM.ADR(p.screen[i][0]),memA,MAXCOLUMN);
    memA:=memA+MAXCOLUMN;
    SYSTEM.PUT(memA,0DX);
    SYSTEM.PUT(memA+1,0AX);
    memA:=memA+2;
  END;
  SYSTEM.PUT(memA,0X);
  dummy:=WB.GlobalUnlock(mem);
  mem:=WU.SetClipboardData(WU.CF_TEXT,mem);
      END;
    END;
    dummy:=WU.CloseClipboard();
  ELSE
    dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
  END;
END CopyAllToClipboard;
    
PROCEDURE (p:ScreenPaneP) UpdateRect*(s,z,sn,zn:LONGINT);
VAR
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  DEC(s);
  DEC(z);
  rect.left:=(s-p.textTopX)*p.charWidth;
  rect.top:=(z-p.textTopY)*p.charHeight;
  rect.right:=rect.left+sn*p.charWidth;
  rect.bottom:=rect.top+zn*p.charHeight;
  ASSERT(p.hwnd# WD.NULL);
  dummy:=WU.InvalidateRect(p.hwnd,rect,1);
  dummy:=WU.UpdateWindow(p.hwnd);
END UpdateRect;  

PROCEDURE (p:ScreenPaneP) CheckXY(s,z:LONGINT):BOOLEAN;
BEGIN
  RETURN ~((s<1) OR (s>MAXCOLUMN) OR (z<1) OR (z>MAXLINE));
END CheckXY;

PROCEDURE (p:ScreenPaneP) ScrollUp();
VAR
  res2:WD.BOOL;
  i:LONGINT;
  rect,client:WD.RECT;
  y:LONGINT;
  cursor:BOOLEAN;
BEGIN
  cursor:=p.IsCursorOn();
  p.CursorOff;
  ASSERT((p.cursY>=1) & (p.cursY<=MAXLINE));
  FOR i:=p.cursX-1 TO MAXCOLUMN-1 DO 
    p.screen[p.cursY-1,i]:=" ";
    p.foreCol[p.cursY-1,i]:=p.curForeCol;
    p.backCol[p.cursY-1,i]:=p.curBackCol;
  END;
  IF p.cursX>MAXCOLUMN THEN p.cursX:=1 END;
  FOR i:=0 TO 23 DO 
    p.screen[i]:=p.screen[i+1];
    p.foreCol[i]:=p.foreCol[i+1];
    p.backCol[i]:=p.backCol[i+1];
  END;
  FOR i:=0 TO MAXCOLUMN-1 DO 
    p.screen[MAXLINE-1,i]:=" ";
    p.foreCol[MAXLINE-1,i]:=p.curForeCol;
    p.backCol[MAXLINE-1,i]:=p.curBackCol;
  END;
  p.UpdateRect(1,1,MAXCOLUMN,MAXLINE);
  IF p.cursY>1 THEN
    DEC(p.cursY);
    p.PositionCursor();
  END;
  IF cursor THEN p.CursorOn END;
END ScrollUp;

PROCEDURE (p:ScreenPaneP) GotoXY*(s,z:LONGINT);
BEGIN
  IF s>MAXCOLUMN THEN
    p.cursX:=1;
    p.cursY:=z+1;
  ELSE
    p.cursX:=s;
    p.cursY:=z;
  END;
  IF p.cursY>MAXLINE THEN p.cursY:=MAXLINE END;
  p.PositionCursor();
END GotoXY;

PROCEDURE (p:ScreenPaneP) WhereX*():LONGINT;
BEGIN
  RETURN p.cursX;
END WhereX;

PROCEDURE (p:ScreenPaneP) WhereY*():LONGINT;
BEGIN
  RETURN p.cursY;
END WhereY;

PROCEDURE (p:ScreenPaneP) WriteCharXY*(s,z:LONGINT; x:CHAR);
VAR
  res:WD.BOOL;
BEGIN
  IF ~p.CheckXY(s,z) THEN RETURN END;
  p.screen[z-1,s-1]:=x;
  p.foreCol[z-1,s-1]:=p.curForeCol;
  p.backCol[z-1,s-1]:=p.curBackCol;
  p.GotoXY(s+1,z);
  res:=WG.TextOutA(p.hdc,
     (s-p.textTopX-1)*p.charWidth,
     (z-p.textTopY-1)*p.charHeight,
     SYSTEM.ADR(x),
     1);
  Process.Yield();
END WriteCharXY;

PROCEDURE (p:ScreenPaneP) GetCharXY*(s,z:LONGINT):CHAR;
BEGIN
  IF ~p.CheckXY(s,z) THEN RETURN " " END;
  RETURN p.screen[z-1,s-1];
END GetCharXY;

PROCEDURE (p:ScreenPaneP) GetStrXY*(s,z,n:LONGINT; VAR t:ARRAY OF CHAR);
VAR
  i:INTEGER;
BEGIN
  IF ~p.CheckXY(s,z) THEN t[0]:=0X; RETURN; END;
  IF n>LEN(t)-1 THEN n:=SHORT(LEN(t)-1) END;
  DEC(s);
  DEC(z);
  i:=0;
  WHILE (i<n) & (s+i<MAXCOLUMN) DO
    t[i]:=p.screen[z,s+i];
    INC(i);
  END;
  t[i]:=0X;
END GetStrXY;

PROCEDURE (p:ScreenPaneP) WriteLn*();
VAR
  i:LONGINT;
BEGIN
  IF p.cursY>=MAXLINE THEN
    p.ScrollUp();
  ELSE
    FOR i:=p.cursX-1 TO MAXCOLUMN-1 DO 
      p.screen[p.cursY-1,i]:=" ";
      p.foreCol[p.cursY-1,i]:=p.curForeCol;
      p.backCol[p.cursY-1,i]:=p.curBackCol;
    END;
    p.UpdateRect(p.cursX,p.cursY,MAXCOLUMN-p.cursX+1,1);
  END;
  p.cursX:=1;
  INC(p.cursY);
  p.PositionCursor();
END WriteLn;

PROCEDURE (p:ScreenPaneP) WriteChar*(x:CHAR);
BEGIN
  p.WriteCharXY(p.cursX,p.cursY,x);
END WriteChar;

PROCEDURE (p:ScreenPaneP) WriteStrXY*(s,z:LONGINT; t:ARRAY OF CHAR);
VAR
  i,inx,s1,z1:LONGINT;
BEGIN
  Process.Yield;
  IF ~p.CheckXY(s,z) THEN RETURN END;
  DEC(s);
  DEC(z);
  s1:=s; z1:=z;
  inx:=0;
  WHILE t[inx]#0X DO 
    WHILE (t[inx]#0X) & (t[inx]#0DX) & (t[inx]#0AX) & (s<=MAXCOLUMN-1) DO
      p.screen[z,s]:=t[inx];
      p.foreCol[z,s]:=p.curForeCol;
      p.backCol[z,s]:=p.curBackCol;
      INC(s);
      INC(inx);
    END;
    IF (t[inx]=0DX) OR (t[inx]=0AX) THEN
      IF (t[inx]=0DX) & (t[inx+1]=0AX) THEN INC(inx) END;
      INC(inx);
      FOR i:=s TO MAXCOLUMN-1 DO 
  p.screen[z,i]:=" ";
  p.foreCol[z,i]:=p.curForeCol;
  p.backCol[z,i]:=p.curBackCol;
      END;
      p.cursX:=s+1;
      s:=0;
      IF p.cursY>=MAXLINE-1 THEN 
  IF z1>0 THEN DEC(z1); s1:=0 END;
  p.ScrollUp();
      ELSE INC(z) END;
      p.cursX:=1;
      INC(p.cursY);
      p.PositionCursor();
    ELSIF s>=MAXCOLUMN THEN 
      s:=0;
      p.cursX:=MAXCOLUMN+1;
      IF p.cursY>=MAXLINE-1 THEN 
  IF z1>0 THEN DEC(z1); s1:=0 END;
  p.ScrollUp();
      ELSE INC(z) END;
      p.cursX:=1;
      INC(p.cursY);
      p.PositionCursor();
    ELSE p.GotoXY(s+1,z+1) END;
  END;
  IF z1=z THEN p.UpdateRect(s1+1,z1+1,s-s1+1,1) ELSE p.UpdateRect(1,z1+1,MAXCOLUMN,z-z1+1) END;
END WriteStrXY;

PROCEDURE (p:ScreenPaneP) WriteStr*(t:ARRAY OF CHAR);
BEGIN
  p.WriteStrXY(p.cursX,p.cursY,t);
END WriteStr;

PROCEDURE (p:ScreenPaneP) WriteSpacesXY*(s,z:LONGINT; n:LONGINT);
VAR
  i:LONGINT;
BEGIN
  IF ~p.CheckXY(s,z) THEN RETURN END;
  IF s+n>=MAXCOLUMN THEN n:=MAXCOLUMN-s+1; END;
  DEC(z);
  FOR i:=s-1 TO s+n-2 DO 
    p.screen[z,i]:=" ";
    p.foreCol[z,i]:=p.curForeCol;
    p.backCol[z,i]:=p.curBackCol;
  END;
  p.GotoXY(s+n,z+1);
  p.UpdateRect(s,z+1,n,1);
END WriteSpacesXY;

PROCEDURE (p:ScreenPaneP) WriteSpaces*(n:LONGINT);
BEGIN
  p.WriteSpacesXY(p.cursX,p.cursY,n);
END WriteSpaces;

PROCEDURE (p:ScreenPaneP) WriteIntXY*(s,z:LONGINT; x:LONGINT; len:LONGINT);
VAR
  t:ARRAY (80) OF CHAR;
BEGIN
  Strings.Str(x,t);
  Strings.RightAlign(t,len);
  p.WriteStrXY(s,z,t);
END WriteIntXY;

PROCEDURE (p:ScreenPaneP) WriteInt*(x:LONGINT; len:LONGINT);
BEGIN
  p.WriteIntXY(p.cursX,p.cursY,x,len);
END WriteInt;

PROCEDURE (p:ScreenPaneP) SetForeColor*(r,g,b:INTEGER);
VAR
  oldCol:WD.COLORREF;
BEGIN
  p.curForeCol:=WinUtils.RGB(r,g,b);
  oldCol:=WG.SetTextColor(p.hdc,p.curForeCol);
END SetForeColor;

PROCEDURE (p:ScreenPaneP) SetBackColor*(r,g,b:INTEGER);
VAR
  oldCol:WD.COLORREF;
BEGIN
  p.curBackCol:=WinUtils.RGB(r,g,b);
  ASSERT(p.hdc# WD.NULL);
  oldCol:=WG.SetBkColor(p.hdc,p.curBackCol);
END SetBackColor;

PROCEDURE (p:ScreenPaneP) GetForeColor*(VAR r,g,b:INTEGER);
BEGIN
  WinUtils.GetRGB(p.curForeCol,r,g,b);
END GetForeColor;

PROCEDURE (p:ScreenPaneP) GetBackColor*(VAR r,g,b:INTEGER);
BEGIN
  WinUtils.GetRGB(p.curBackCol,r,g,b);
END GetBackColor;

PROCEDURE (p:ScreenPaneP) ReadChar*(VAR x:CHAR);
VAR
  cOn:BOOLEAN;
  dummy:CHAR;
BEGIN
  cOn:=p.IsCursorOn();
  REPEAT
    p.CursorOn();
    x:=p.ReadKey();
    IF x=0X THEN dummy:=p.ReadKey(); END;
    p.CursorOff();
  UNTIL x#0X;
  IF x<20X THEN
    IF x=TAB THEN p.WriteStr("        "); END;
    IF x=ENTER THEN p.WriteLn; END;
  ELSE
    p.WriteChar(x);
  END;
  IF cOn THEN p.CursorOn() ELSE p.CursorOff(); END;
END ReadChar;

PROCEDURE (p:ScreenPaneP) Input*(spalte,zeile:LONGINT; 
                                 VAR kom:ARRAY OF CHAR; 
                                 VAR txt:ARRAY OF CHAR;
                                 maxlen:LONGINT; 
                                 VAR code:CHAR; 
                                 art:LONGINT; 
                                 edit:BOOLEAN; 
                                 VAR position:LONGINT);
VAR
  help:LONGINT;
  lng:LONGINT;
  ready,ok:BOOLEAN;
  ccode,taste:CHAR;
  h:ARRAY (3) OF CHAR;
  cOn:BOOLEAN;
  dummy:WD.BOOL;
BEGIN
  p.GotoXY(spalte,zeile); 
  cOn:=p.IsCursorOn();
  p.WriteStr(kom);
  spalte:=spalte+SHORT(Strings.Length(kom));
  p.WriteSpaces(maxlen);
  p.WriteStrXY(spalte,zeile,txt);
  ready := FALSE;
  IF edit THEN 
    lng:=SHORT(Strings.Length(txt));
    IF (position=0) OR (position>lng) THEN position:=lng+1; END;
  ELSE 
    position:=1;
    lng:=0;
  END;
  WHILE ~ready DO
    WHILE ~ready DO
      p.GotoXY(spalte+position-1,zeile);
      ccode:=0X;
      p.CursorOn();
      taste:=p.ReadKey();
      p.CursorOff();
      code := taste;
      CASE code OF
  BACKSPACE :
  IF ~edit THEN
    lng:=SHORT(Strings.Length(txt));
    position:=lng+1;
    edit:=TRUE;
  END;
  IF position>1 THEN
    DEC(position); 
    DEC(lng);
    Strings.Delete(txt,position,1);
  ELSIF (position=1) & (lng>0) THEN
    DEC(lng);
    Strings.Delete(txt,1,1);
  END;
  IF position#lng+1 THEN 
  p.WriteStrXY(spalte,zeile,txt)
  END;
  p.WriteSpacesXY(spalte+lng,zeile,1);
      | ENTER:
  ready:=TRUE;
      | ESC:
  ready:=TRUE;
      | 0X:
  ccode:=p.ReadKey();
  CASE ccode OF
    CURSLEFT:
    IF ~edit THEN
      lng:=SHORT(Strings.Length(txt));
      position:=lng+1;
      edit:=TRUE;
    END;
    IF position>1 THEN DEC(position); END;
  | CURSRIGHT:
    IF ~edit THEN
      lng:=SHORT(Strings.Length(txt));
      position:=lng+1;
      edit:=TRUE;
    END;
    IF position<lng+1 THEN INC(position); END;
  | HOME:
    IF ~edit THEN
      lng:=SHORT(Strings.Length(txt));
      position:=lng+1;
      edit:=TRUE;
    END;
    position:=1;
  | ENDKEY:
    IF ~edit THEN
      lng:=SHORT(Strings.Length(txt));
      position:=lng+1;
      edit:=TRUE;
    END;
    IF lng<maxlen THEN position:=lng+1 ELSE position:=lng; END;
  | DELETE:
    IF ~edit THEN 
      p.WriteSpacesXY(spalte,zeile,SHORT(Strings.Length(txt)));
      txt[0]:=0X;
      edit:=TRUE;
    END;
    IF (lng>0) & (position<=lng) THEN
      DEC(lng);
      Strings.Delete(txt,position,1);
    END;
    p.WriteStrXY(spalte,zeile,txt);
    p.WriteSpaces(1);
  ELSE
  END;
      ELSE
  CASE art OF
    INPT_LETTER,INPT_UPCASE:
    ok:=(Strings.UpCaseChar(taste)>='A') & (Strings.UpCaseChar(taste)<='Z');
  | INPT_NUMBER:
    IF taste=',' THEN taste:='.'; END;
    ok:=((taste>='0') & (taste<='9')) OR
         (taste='.') OR (taste='-')  OR
         (taste='+');
        | INPT_REAL:
          taste:=CAP(taste);
    IF taste=',' THEN taste:='.'; END;
          IF taste="D" THEN taste:="E" END;
    ok:=((taste>='0') & (taste<='9')) OR
         (taste='.') OR (taste='-')  OR
               (taste='+') OR (taste="E");
  | INPT_CARDINAL,INPT_ddmmyy,INPT_hhmm,INPT_ddmm__:
    ok:=(taste>='0') & (taste<='9');
  | INPT_YESNO:
    taste:=Strings.UpCaseChar(taste);
    IF taste='Y' THEN taste:='J'; END;
    IF (maxlen=1) & (taste=' ') & ((txt[0]='J') OR (txt[0]='N')) THEN 
      IF txt[0]='J' THEN taste:='N' ELSE taste:='J'; END;
      txt[0]:=0X;
      lng:=0;
      position:=1;
    END;
    ok:=(taste='J') OR (taste='N');
  | INPT_UPCASE_CARD:
    taste:=Strings.UpCaseChar(taste);
    ok:=((taste>='A') & (taste<='Z')) & ((taste>='A') & (taste<='Z'));
  ELSE 
    ok:=TRUE;
  END;
  IF lng=maxlen THEN ok:=FALSE; END;
  IF ok THEN
    IF ~edit THEN 
      p.WriteSpacesXY(spalte,zeile,SHORT(Strings.Length(txt)));
      txt[0]:=0X;
      edit:=TRUE;
    END;
    Strings.InsertChar(taste,txt,position);
    IF position=lng+1 THEN 
      p.WriteCharXY(spalte+lng,zeile,taste)
    ELSE
      p.WriteStrXY(spalte,zeile,txt)
    END;
    INC(position); 
    INC(lng);
  ELSE dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION); END;
      END; 
    END; (* WHILE *)
    ready:=TRUE;
    IF Strings.Length(txt)#0 THEN
      CASE art OF
  INPT_ddmmyy:
  IF Strings.Length(txt)=6 THEN
    Strings.Copy(txt,h,1,2);
    help:=SHORT(Strings.Val(h));
    IF (help<1) OR (help>31) THEN ready:=FALSE; END;
    Strings.Copy(txt,h,3,2);
    help:=SHORT(Strings.Val(h));
    IF (help<1) OR (help>12) THEN ready:=FALSE; END;
    Strings.Copy(txt,h,5,2);
    help:=SHORT(Strings.Val(h));
    IF help=-1 THEN ready:=FALSE; END;
  ELSE ready:=FALSE; END;
      | INPT_hhmm:
  IF Strings.Length(txt)=4 THEN
    Strings.Copy(txt,h,1,2);
    help:=SHORT(Strings.Val(h));
    IF (help<0) OR (help>24) THEN ready:=FALSE; END;
    Strings.Copy(txt,h,3,2);
    help:=SHORT(Strings.Val(h));
    IF (help<0) OR (help>59) THEN ready:=FALSE; END;
  ELSE ready:=FALSE; END;
      | INPT_ddmm__:
  Strings.Copy(txt,h,1,2);
  help:=SHORT(Strings.Val(h));
  IF (help<1) OR (help>31) THEN ready:=FALSE; END;
  Strings.Copy(txt,h,3,2);
  help:=SHORT(Strings.Val(h));
  IF (help<1) OR (help>12) THEN ready:=FALSE; END;
  IF Strings.Length(txt)=6 THEN
    Strings.Copy(txt,h,5,2);
    help:=SHORT(Strings.Val(h));
    IF help=-1 THEN ready:=FALSE; END;
  ELSIF Strings.Length(txt)#4 THEN ready:=FALSE; END;
      ELSE;
      END;
    END;
    IF ~ready THEN dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION) END;
  END; (* WHILE *)
  IF cOn THEN p.CursorOn() ELSE p.CursorOff(); END;
END Input;

PROCEDURE (p:ScreenPaneP) ReadLongInt*(VAR x:LONGINT; maxl:LONGINT; VAR resCode:CHAR);
VAR
  k:ARRAY (1) OF CHAR;
  t:ARRAY (81) OF CHAR;
  code:CHAR;
  pos:LONGINT;
  res:BOOLEAN;
BEGIN
  k[0]:=0X;
  t[0]:=0X;
  pos:=0;
  code:=0X;
  WHILE (code#ENTER) & (code#ESC) DO
    p.Input(p.cursX,p.cursY,k,t,maxl,code,INPT_NUMBER,FALSE,pos);
  END;
  IF code=ESC THEN
    x:=0;
    resCode:=ESC;
  ELSE
    IF Strings.ValResult(t)<=Strings.ISLONGINT THEN
      x:=Strings.Val(t);
      resCode:=code;
    ELSE
      x:=0;
      resCode:=INPUTINVALID; 
    END;
  END;
END ReadLongInt;

PROCEDURE (p:ScreenPaneP) ReadLongReal*(VAR x:LONGREAL; maxl:LONGINT; VAR resCode:CHAR);
VAR
  k:ARRAY (1) OF CHAR;
  t:ARRAY (81) OF CHAR;
  code:CHAR;
  pos:LONGINT;
  res:BOOLEAN;
BEGIN
  k[0]:=0X;
  t[0]:=0X;
  pos:=0;
  code:=0X;
  WHILE (code#ENTER) & (code#ESC) DO
    p.Input(p.cursX,p.cursY,k,t,maxl,code,INPT_REAL,FALSE,pos);
  END;
  IF code=ESC THEN
    x:=0;
    resCode:=ESC;
  ELSE
    IF Float.ValResult(t)<=Float.ISLONGREAL THEN
      x:=Float.Val(t);
      resCode:=code;
    ELSE
      x:=0;
      resCode:=INPUTINVALID; 
    END;
  END;
END ReadLongReal;

PROCEDURE (p:ScreenPaneP) ReadInt*(VAR x:INTEGER; maxl:INTEGER; VAR resCode:CHAR);
VAR
  h:LONGINT;
  ch:CHAR;
BEGIN
  p.ReadLongInt(h,maxl,ch);
  IF (h>=MIN(INTEGER)) & (h<=MAX(INTEGER)) THEN 
    x:=SHORT(h); 
    resCode:=ch;
  ELSE 
    x:=0;
    resCode:=INPUTINVALID;
  END;
END ReadInt;

PROCEDURE (p:ScreenPaneP) ReadReal*(VAR x:REAL; maxl:INTEGER; VAR resCode:CHAR);
VAR
  h:LONGREAL;
  ch:CHAR;
BEGIN
  p.ReadLongReal(h,maxl,ch);
  IF (h>=MIN(REAL)) & (h<=MAX(REAL)) THEN 
    x:=SHORT(h); 
    resCode:=ch;
  ELSE 
    x:=0;
    resCode:=INPUTINVALID;
  END;
END ReadReal;

PROCEDURE (p:ScreenPaneP) ReadStr*(VAR t:ARRAY OF CHAR; maxl:LONGINT; VAR resCode:CHAR);
VAR
  k:ARRAY (1) OF CHAR;
  code:CHAR;
  pos:LONGINT;
BEGIN
  IF maxl>LEN(t)-1 THEN maxl:=SHORT(LEN(t)-1) END;
  t[0]:=0X;
  k[0]:=0X;
  pos:=0;
  code:=0X;
  WHILE (code#ENTER) & (code#ESC) DO
    p.Input(p.cursX,p.cursY,k,t,maxl,code,INPT_TEXT,FALSE,pos);
  END;
  resCode:=code;
END ReadStr;

PROCEDURE (p:ScreenPaneP) EditStr*(VAR t:ARRAY OF CHAR; maxl:LONGINT; VAR resCode:CHAR);
VAR
  k:ARRAY (1) OF CHAR;
  code:CHAR;
  pos:LONGINT;
BEGIN
  IF maxl>LEN(t)-1 THEN maxl:=SHORT(LEN(t)-1) END;
  k[0]:=0X;
  pos:=0;
  REPEAT
    p.Input(p.cursX,p.cursY,k,t,maxl,code,INPT_TEXT,FALSE,pos);
  UNTIL (code=ENTER) OR (code=ESC) OR (code=TAB) OR 
  (code=CURSUP) OR (code=CURSDOWN) OR (code=PAGEUP) OR (code=PAGEDOWN);
  resCode:=code;
END EditStr;

PROCEDURE (p:ScreenPaneP) ClrScr*();
BEGIN
  p.ClearBuffers();
  p.UpdateRect(1,1,MAXCOLUMN,MAXLINE);
  p.cursX:=1; p.cursY:=1;
  p.PositionCursor();  
END ClrScr;

PROCEDURE (p:ScreenPaneP) FlushKeyBuffer*();
BEGIN
  p.keyBuffer.Flush();
END FlushKeyBuffer;

PROCEDURE (p:ScreenPaneP) Print*();
VAR
  i,j:LONGINT;
BEGIN
  IF P.StartWithDialog() THEN
    P.SetLeftMargin(WinUtils.LeftPrintMargin());
    P.SetTopMargin(WinUtils.TopPrintMargin());
    FOR i:=0 TO MAXLINE-1 DO
      FOR j:=0 TO MAXCOLUMN-1 DO
        P.Char(p.screen[i,j]);
      END;
      P.Ln;
    END;
    P.Finished;
  END;
END Print;

END ScreenPane.
