(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE CBitPane;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, WG:=WinGDI, 
       Panes, WinUtils, TextPane, GH:=GlobHandles,
       Strings, Utils, P:=Print, StdWins, Process;

CONST
  CBitPaneClassTxt*="CBitPane";
  MOUSEBUFFERSIZE=100;
  WIDTH=800;
  HEIGHT=650;

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

TYPE
  CBitmapPane*=RECORD (TextPane.TextPane)
    hBitmap-:WD.HBITMAP;
    maxX:LONGINT;
    maxY:LONGINT;
    posX:LONGINT;
    posY:LONGINT;
    cursX,cursY:LONGINT;
    hmemdc-:WD.HDC;
    backCol:WD.COLORREF;
    foreCol:WD.COLORREF;
    hForePen:WD.HPEN;
    hBackPen:WD.HPEN;
    hForeBrush,hBackBrush:WD.HBRUSH;
    hOldBrush,hOldBrushMem:WD.HBRUSH;
    hOldPen:WD.HPEN;
    hOldPenMem:WD.HPEN;
    holdmap:WD.HBITMAP;
    manageInProgress:BOOLEAN;
    firstScroll:BOOLEAN;
    update-:BOOLEAN;
  END;
  CBitmapPaneP*=POINTER TO CBitmapPane;

PROCEDURE (p:CBitmapPaneP) CopyAllToClipboard*();
VAR
  dummy:WD.BOOL;
  dummy2:WD.HANDLE;
  dummy3:INTEGER;
  hmemdc:WD.HDC;
  hBitmap:WD.HBITMAP;
  holdmap:WD.HBITMAP;
  info:WG.BITMAPINFO2;
BEGIN
  IF WU.OpenClipboard(p.hwnd)#0 THEN 
    hmemdc:=WG.CreateCompatibleDC(p.hdc);
    ASSERT(hmemdc#WD.NULL);
    info.bmiHeader.biSize:=SIZE(WG.BITMAPINFOHEADER);
    info.bmiHeader.biWidth:=p.maxX+1;
    info.bmiHeader.biHeight:=p.maxY+1;
    info.bmiHeader.biPlanes:=1;
    info.bmiHeader.biBitCount:=SHORT(WG.GetDeviceCaps(p.hdc,WG.BITSPIXEL)*WG.GetDeviceCaps(p.hdc,WG.PLANES));
    info.bmiHeader.biCompression:=WG.BI_RGB;
    info.bmiHeader.biSizeImage:=0;
    info.bmiHeader.biXPelsPerMeter:=25*75;
    info.bmiHeader.biYPelsPerMeter:=25*75;
    info.bmiHeader.biClrUsed:=0;
    info.bmiHeader.biClrImportant:=0;
    info.bmiColors[0].rgbRed:=0FFX;
    info.bmiColors[0].rgbGreen:=0FFX;
    info.bmiColors[0].rgbBlue:=0FFX;
    info.bmiColors[0].rgbReserved:=0X;
    info.bmiColors[1].rgbRed:=0X;
    info.bmiColors[1].rgbGreen:=0X;
    info.bmiColors[1].rgbBlue:=0X;
    info.bmiColors[1].rgbReserved:=0X;
    hBitmap:=WG.CreateDIBitmap(p.hdc,
                              info.bmiHeader,
                              0,WD.NULL,
                              info,
                              WG.DIB_PAL_COLORS);
    ASSERT(hBitmap#WD.NULL);
    holdmap:=WG.SelectObject(hmemdc,hBitmap);
    dummy:=WG.BitBlt(hmemdc,
                    0,0,p.maxX+1,p.maxY+1,
                    p.hmemdc,
                    0,0,
                    WG.SRCCOPY);
    ASSERT(dummy#0);
    holdmap:=WG.SelectObject(hmemdc,holdmap);
    dummy:=WU.EmptyClipboard();
    dummy2:=WU.SetClipboardData(WU.CF_BITMAP,hBitmap);
    dummy:=WU.CloseClipboard();
    dummy:=WG.DeleteDC(hmemdc);
  ELSE
    dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
  END;
END CopyAllToClipboard;

PROCEDURE (p:CBitmapPaneP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  dummy:WD.BOOL;
  rect:WD.RECT;
BEGIN
  IF p.holdmap#0 THEN
    dummy:=WG.BitBlt(hdc,
                    0,0,p.maxX+1,p.maxY+1,
                    p.hmemdc,
                    p.posX,p.posY,
                    WG.SRCCOPY);
    IF p.maxY-p.posY+1<paint.rcPaint.bottom THEN
      rect.left:=0;
      rect.top:=p.maxY-p.posY+1;
      rect.right:=paint.rcPaint.right;
      rect.bottom:=paint.rcPaint.bottom;
      dummy:=WU.FillRect(hdc,rect,WinUtils.GRAY_BRUSH);
    END;
    IF p.maxX-p.posX+1<paint.rcPaint.right THEN
      rect.left:=p.maxX-p.posX+1;
      rect.top:=0;
      rect.right:=paint.rcPaint.right;
      rect.bottom:=paint.rcPaint.bottom;
      dummy:=WU.FillRect(hdc,rect,WinUtils.GRAY_BRUSH);
    END;
  END;
END Paint;

PROCEDURE (p:CBitmapPaneP) Clear*();
VAR
  dummy:LONGINT;
  rect:WD.RECT;
BEGIN
  IF p.holdmap#0 THEN
    rect.left:=0; rect.right:=p.maxX+1;
    rect.top:=0;  rect.bottom:=p.maxY+1;
    dummy:=WU.FillRect(p.hmemdc,rect,p.hBackBrush);
    IF p.update THEN p.PostContentsChanged() END;
    p.cursX:=0;
    p.cursY:=0;
    IF p.IsCursorOn() THEN p.PositionCursor END;
  END;
END Clear;

PROCEDURE (p:CBitmapPaneP) SetScreenUpdate*(x:BOOLEAN);
BEGIN
  IF x=p.update THEN RETURN END;
  p.update:=x;
  IF p.update THEN p.PostContentsChanged() END;
END SetScreenUpdate;

PROCEDURE (p:CBitmapPaneP) AdjustPens*();
VAR
  dummy2:WD.BOOL;
  dummy1:WD.HPEN;
  dummy3:WD.COLORREF;
BEGIN
  dummy1:=WG.SelectObject(p.hdc,p.hOldPen);
  dummy1:=WG.SelectObject(p.hmemdc,p.hOldPenMem);
  dummy2:=WG.DeleteObject(p.hForePen);
  dummy2:=WG.DeleteObject(p.hBackPen);
  p.hForePen:=WG.CreatePen(WG.PS_SOLID,0,p.foreCol);
  p.hBackPen:=WG.CreatePen(WG.PS_SOLID,0,p.backCol);
  dummy1:=WG.SelectObject(p.hdc,p.hForePen);
  dummy1:=WG.SelectObject(p.hmemdc,p.hForePen);
  dummy3:=WG.SetTextColor(p.hdc,p.foreCol);
  dummy3:=WG.SetTextColor(p.hmemdc,p.foreCol);
  dummy3:=WG.SetBkColor(p.hdc,p.backCol);
  dummy3:=WG.SetBkColor(p.hmemdc,p.backCol);
  dummy1:=WG.SelectObject(p.hdc,p.hOldBrush);
  dummy1:=WG.SelectObject(p.hmemdc,p.hOldBrushMem);
  dummy2:=WG.DeleteObject(p.hForeBrush);
  dummy2:=WG.DeleteObject(p.hBackBrush);
  p.hForeBrush:=WG.CreateSolidBrush(p.foreCol);
  p.hBackBrush:=WG.CreateSolidBrush(p.backCol);
  dummy1:=WG.SelectObject(p.hdc,p.hForeBrush);
  dummy1:=WG.SelectObject(p.hmemdc,p.hForeBrush);
END AdjustPens;
 
PROCEDURE (p:CBitmapPaneP) GetDotColor*(x,y:LONGINT; VAR r,g,b:INTEGER);
VAR
  h:LONGINT;
BEGIN
  h:=WG.GetPixel(p.hmemdc,x,p.maxY-y);
  IF h=-1 THEN
    r:=0;
    g:=0;
    b:=0;
    RETURN;
  END;
  WinUtils.GetRGB(h,r,g,b);
END GetDotColor;

PROCEDURE (p:CBitmapPaneP) SetForeColor*(r,g,b:INTEGER);
BEGIN
  p.foreCol:=WinUtils.RGB(r,g,b);
  p.AdjustPens();
END SetForeColor;

PROCEDURE (p:CBitmapPaneP) SetBackColor*(r,g,b:INTEGER);
BEGIN
  p.backCol:=WinUtils.RGB(r,g,b);
  p.AdjustPens();
END SetBackColor;

PROCEDURE (p:CBitmapPaneP) GetForeColor*(VAR r,g,b:INTEGER);
BEGIN
  WinUtils.GetRGB(p.foreCol,r,g,b);
END GetForeColor;

PROCEDURE (p:CBitmapPaneP) GetBackColor*(VAR r,g,b:INTEGER);
BEGIN
  WinUtils.GetRGB(p.backCol,r,g,b);
END GetBackColor;

PROCEDURE (p:CBitmapPaneP) SetDot*(x,y:LONGINT; color:INTEGER);
VAR
  dummy:LONGINT;
BEGIN
  IF (x<0) OR (y<0) OR (x>p.maxX) OR (y>p.maxY) THEN RETURN; END;
  y:=p.maxY-y;
  IF p.holdmap#0 THEN
    IF color=1 THEN 
      dummy:=WG.SetPixel(p.hmemdc,x,y,p.foreCol);
      IF p.update THEN dummy:=WG.SetPixel(p.hdc,x-p.posX,y-p.posY,p.foreCol) END;
    ELSE
      dummy:=WG.SetPixel(p.hmemdc,x,y,p.backCol);
      IF p.update THEN dummy:=WG.SetPixel(p.hdc,x-p.posX,y-p.posY,p.backCol) END;
    END;
  END;
END SetDot;

PROCEDURE (p:CBitmapPaneP) Line*(x1,y1,x2,y2:LONGINT; color:INTEGER);
VAR
  dummy:LONGINT;
  dummy1:WD.HPEN;
BEGIN
  IF p.holdmap#0 THEN
    p.SetDot(x2,y2,color);
    y1:=p.maxY-y1;
    y2:=p.maxY-y2;
    IF color#1 THEN 
      dummy1:=WG.SelectObject(p.hdc,p.hBackPen);
      dummy1:=WG.SelectObject(p.hmemdc,p.hBackPen);
    END;
    dummy:=WG.MoveToEx(p.hmemdc,x1,y1,NIL);
    dummy:=WG.LineTo(p.hmemdc,x2,y2);
    IF p.update THEN
      dummy:=WG.MoveToEx(p.hdc,x1-p.posX,y1-p.posY,NIL);
      dummy:=WG.LineTo(p.hdc,x2-p.posX,y2-p.posY);
    END;
    IF color#1 THEN 
      dummy1:=WG.SelectObject(p.hdc,p.hForePen);
      dummy1:=WG.SelectObject(p.hmemdc,p.hForePen);
    END;
  END;
END Line;

PROCEDURE (p:CBitmapPaneP) Bar*(x1,y1,x2,y2:LONGINT; color:INTEGER);
VAR
  dummy:LONGINT;
  dummy1:WD.HPEN;
  rect:WD.RECT;
BEGIN
  IF p.holdmap#0 THEN
    y1:=p.maxY-y1;
    y2:=p.maxY-y2;
    IF x1<x2 THEN 
      rect.left:=x1;
      rect.right:=x2+1;
    ELSE 
      rect.left:=x2;
      rect.right:=x1+1;
    END;
    IF y1<y2 THEN 
      rect.top:=y1;
      rect.bottom:=y2+1;
    ELSE 
      rect.top:=y2;
      rect.bottom:=y1+1;
    END;
    IF color#1 THEN
      dummy:=WU.FillRect(p.hmemdc,rect,p.hBackBrush);
    ELSE
      dummy:=WU.FillRect(p.hmemdc,rect,p.hForeBrush);
    END;
    IF p.update THEN
      IF x1<x2 THEN 
        rect.left:=x1-p.posX;
        rect.right:=x2+1-p.posX;
      ELSE 
        rect.left:=x2-p.posX;
        rect.right:=x1+1-p.posX;
      END;
      IF y1<y2 THEN 
        rect.top:=y1-p.posY;
        rect.bottom:=y2+1-p.posY;
      ELSE 
        rect.top:=y2-p.posY;
        rect.bottom:=y1+1-p.posY;
      END;
      IF color#1 THEN
        dummy:=WU.FillRect(p.hdc,rect,p.hBackBrush);
      ELSE
        dummy:=WU.FillRect(p.hdc,rect,p.hForeBrush);
      END;
    END;
  END;
END Bar;

PROCEDURE (p:CBitmapPaneP) Box*(x1,y1,x2,y2:LONGINT; color:INTEGER);
BEGIN
  p.Line(x1,y1,x2,y1,color);
  p.Line(x1,y1,x1,y2,color);
  p.Line(x2,y2,x2,y1,color);
  p.Line(x2,y2,x1,y2,color);
END Box;

PROCEDURE (p:CBitmapPaneP) ManageVerticalScroll*(code:LONGINT; value:LONGINT):LONGINT;
VAR
  oldPos:LONGINT;
  oldTop:LONGINT;
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  CASE code OF
    WU.SB_THUMBTRACK:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,value,1);
  | WU.SB_LINEDOWN,WU.SB_PAGEDOWN:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos+10,1);
  | WU.SB_LINEUP,WU.SB_PAGEUP:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos-10,1);
  ELSE
  END;
  oldTop:=p.posY;
  p.posY:=WU.GetScrollPos(p.hwnd,WU.SB_VERT);
  IF oldTop#p.posY THEN
    dummy:=WU.GetClientRect(p.hwnd,rect);
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
    dummy:=WU.UpdateWindow(p.hwnd);
    IF p.IsCursorOn() THEN p.PositionCursor END;
  END;
  RETURN 0; 
END ManageVerticalScroll;

PROCEDURE (p:CBitmapPaneP) ManageHorizontalScroll*(code:LONGINT; value:LONGINT):LONGINT;
VAR
  oldPos:LONGINT;
  oldTop:LONGINT;
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  CASE code OF
    WU.SB_THUMBTRACK:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,value,1);
  | WU.SB_LINEDOWN,WU.SB_PAGEDOWN:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,oldPos+10,1);
  | WU.SB_LINEUP,WU.SB_PAGEUP:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_HORZ,oldPos-10,1);
  ELSE
  END;
  oldTop:=p.posX;
  p.posX:=WU.GetScrollPos(p.hwnd,WU.SB_HORZ);
  IF oldTop#p.posX THEN
    dummy:=WU.GetClientRect(p.hwnd,rect);
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
    dummy:=WU.UpdateWindow(p.hwnd);
    IF p.IsCursorOn() THEN p.PositionCursor END;
  END;
  RETURN 0; 
END ManageHorizontalScroll;

PROCEDURE (p:CBitmapPaneP) ManageScrollBars*;
VAR
  rect:WD.RECT;
  max:LONGINT;
  dummyl:LONGINT;
  dummy2:INTEGER;
  dummy:WD.BOOL;
BEGIN
  IF ~p^.manageInProgress THEN
    p^.manageInProgress:=TRUE; 
    dummy:=WU.GetClientRect(p.hwnd,rect);
    max:=p.maxY-rect.bottom+1;
    IF max<0 THEN max:=0; END;
    dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,0,max,0);
    IF p.firstScroll THEN
      dummyl:=p.ManageVerticalScroll(WU.SB_THUMBTRACK,max);
      p.firstScroll:=FALSE;
    ELSE
      dummyl:=p.ManageVerticalScroll(1000,0);
    END;  
    dummyl:=WU.SetScrollPos(p.hwnd,
                           WU.SB_VERT,
                           WU.GetScrollPos(p.hwnd,WU.SB_VERT), 
                           1);
    max:=p.maxX-rect.right+1;
    IF max<0 THEN max:=0; END;
    dummy:=WU.SetScrollRange(p.hwnd,WU.SB_HORZ,0,max,0);
    dummyl:=p.ManageHorizontalScroll(1000,0);
    dummyl:=WU.SetScrollPos(p.hwnd,
                           WU.SB_HORZ,
                           WU.GetScrollPos(p.hwnd,WU.SB_HORZ), 
                           1);
    p^.manageInProgress:=FALSE; 
  END;
END ManageScrollBars;

PROCEDURE (p:CBitmapPaneP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),CBitPaneClassTxt) THEN
    RETURN TRUE;
  END;
  wc.style := WU.CS_OWNDC;    
  wc.lpfnWndProc := Panes.PaneHandleEvent;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 4;
  wc.hInstance := GH.GetAppInstanceHandle();            
  wc.hIcon := WD.NULL; 
  wc.hCursor := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WD.NULL; 
  wc.lpszMenuName := WD.NULL;
  wc.lpszClassName := SYSTEM.ADR(CBitPaneClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:CBitmapPaneP) Open*():BOOLEAN;
VAR
  dummy1:INTEGER; 
  dummy3:WD.HANDLE;
  dummy4:WD.BOOL;
(*  palData:WG.LOGPALETTE256;*)
  palN:INTEGER;
  hDC:WD.HDC;
  o:WD.HBITMAP;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  flags:=SYSTEM.BITOR(WU.WS_CHILD,WU.WS_CLIPSIBLINGS);
  flags:=SYSTEM.BITOR(flags,WU.WS_VISIBLE);
  flags:=SYSTEM.BITOR(flags,WU.WS_VSCROLL);
  flags:=SYSTEM.BITOR(flags,WU.WS_HSCROLL);
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION) END;
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER) END;
  IF p.OpenTextPane("a ColorPlane",0,flags,CBitPaneClassTxt) THEN
    p.maxX:=WIDTH-1;
    p.maxY:=HEIGHT-1;
    p.posX:=0;
    p.posY:=0;
    p.cursX:=0;
    p.cursY:=0;
    p.update:=TRUE;
    p.foreCol:=00000000H;
    p.backCol:=00FFFFFFH;
    p.hForePen:=WG.CreatePen(WG.PS_SOLID,0,p.foreCol);
    p.hBackPen:=WG.CreatePen(WG.PS_SOLID,0,p.backCol);
    p.hForeBrush:=WG.CreateSolidBrush(p.foreCol);
    p.hBackBrush:=WG.CreateSolidBrush(p.backCol);
    p.keyBuffer.Init();
    p.firstScroll:=TRUE;
    p.hmemdc:=WG.CreateCompatibleDC(p.hdc);
    ASSERT(p.hmemdc#WD.NULL);
    p.hBitmap:=WG.CreateCompatibleBitmap(p.hdc,p.maxX+1,p.maxY+1);
    ASSERT(p.hBitmap#WD.NULL);
    p.holdmap:=WG.SelectObject(p.hmemdc,p.hBitmap);
    ASSERT(p.holdmap#WD.NULL);
    dummy4:=WG.PatBlt(p.hmemdc,0,0,p.maxX+1,p.maxY+1,WG.WHITENESS);
    ASSERT(dummy4#0);
    p.hOldPen:=WG.SelectObject(p.hdc,p.hForePen);
    p.hOldPenMem:=WG.SelectObject(p.hmemdc,p.hForePen);
    p.hOldBrush:=WG.SelectObject(p.hdc,p.hForeBrush);
    p.hOldBrushMem:=WG.SelectObject(p.hmemdc,p.hForeBrush);
    p.manageInProgress:=FALSE;
    p.ManageScrollBars();
    NEW(p.mouseBuffer.list,MOUSEBUFFERSIZE);
  END;
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE (p:CBitmapPaneP) Shutdown*():LONGINT;
VAR
  dummy:WD.BOOL;
BEGIN
  p.holdmap:=WG.SelectObject(p.hmemdc,p.holdmap); 
  p.holdmap:=WD.NULL;
  dummy:=WG.DeleteDC(p.hmemdc);   
  ASSERT(dummy#0);
  dummy:=WG.DeleteObject(p.hBitmap);
  ASSERT(dummy#0);
  RETURN p.Shutdown^();
END Shutdown;

PROCEDURE (p:CBitmapPaneP) ReleaseHandles*();
VAR
  dummy:INTEGER;
  res:WD.BOOL;
BEGIN
  IF p.handlesReleased THEN RETURN END;
  p.hOldPen:=WG.SelectObject(p.hdc,p.hOldPen);
  p.hOldPenMem:=WG.SelectObject(p.hmemdc,p.hOldPenMem);
  p.hOldBrush:=WG.SelectObject(p.hdc,p.hOldBrush);
  p.hOldBrushMem:=WG.SelectObject(p.hmemdc,p.hOldBrushMem);
  res:=WG.DeleteObject(p.hForePen);
  ASSERT(res#0);
  res:=WG.DeleteObject(p.hBackPen);
  ASSERT(res#0);
  res:=WG.DeleteObject(p.hForeBrush);
  ASSERT(res#0);
  res:=WG.DeleteObject(p.hBackBrush);
  ASSERT(res#0);
  p.ReleaseHandles^();
END ReleaseHandles;

PROCEDURE (p:CBitmapPaneP) PositionCursor*();
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.cursOn THEN 
    dummy:=WU.SetCaretPos(p.cursX-p.posX,p.cursY-p.posY+p.charHeight-2);
  END;
END PositionCursor;

PROCEDURE (p:CBitmapPaneP) GotoXY*(x,y:LONGINT);
BEGIN
  p.cursX:=x;
  p.cursY:=p.maxY-y;
  p.PositionCursor;
END GotoXY;

PROCEDURE (p:CBitmapPaneP) WriteStr*(txt:ARRAY OF CHAR);
VAR
  fOld:WD.HANDLE;
  dummy:WD.BOOL;
  l:INTEGER;
  cOn:BOOLEAN;
BEGIN
  l:=SHORT(Strings.Length(txt));
  IF p.update THEN
    cOn:=p.IsCursorOn();
    p.CursorOff;
    dummy:=WG.TextOutA(p.hdc,p.cursX-p.posX,p.cursY-p.posY,SYSTEM.ADR(txt),l);
    IF cOn THEN p.CursorOn() END;
  END;
  fOld:=WG.SelectObject(p.hmemdc,p.font);
  ASSERT(fOld#WD.NULL);
  dummy:=WG.TextOutA(p.hmemdc,p.cursX,p.cursY,SYSTEM.ADR(txt),l);
  p.cursX:=p.cursX+l*p.charWidth;
  p.PositionCursor;
  fOld:=WG.SelectObject(p.hmemdc,fOld);
  ASSERT(fOld#WD.NULL);
END WriteStr;

PROCEDURE (p:CBitmapPaneP) WriteLn*();
BEGIN
  p.cursY:=p.cursY+p.charHeight;
  p.cursX:=0;
  p.PositionCursor;
END WriteLn;

PROCEDURE (p:CBitmapPaneP) WhereX*():LONGINT;
BEGIN
  RETURN p.cursX;
END WhereX;

PROCEDURE (p:CBitmapPaneP) WhereY*():LONGINT;
BEGIN
  RETURN p.maxY-p.cursY;
END WhereY;

PROCEDURE (p:CBitmapPaneP) GetMouse*(VAR buttons:SET; VAR x,y:LONGINT);
VAR
  mInfo:Panes.MouseInfo;
  new:BOOLEAN;
BEGIN
  p.ReadMouse(mInfo,new);
  buttons:=mInfo.buttons;
  x:=mInfo.x+p.posX;
  y:=p.maxY-(mInfo.y+p.posY);
END GetMouse;

PROCEDURE (p:CBitmapPaneP) Input*(x,y:LONGINT; VAR kom:ARRAY OF CHAR; 
                                  VAR txt:ARRAY OF CHAR; maxlen:LONGINT; 
                                  VAR code:CHAR; art:LONGINT; edit:BOOLEAN; 
                                  VAR position:LONGINT);
VAR
  help:LONGINT;
  lng:LONGINT;
  ready,ok:BOOLEAN;
  ccode,taste:CHAR;
  h:ARRAY (3) OF CHAR;
  cOn:BOOLEAN;
  size:WD.SIZE;
  dummy:WD.BOOL;
BEGIN
  p.GotoXY(x,y); 
  cOn:=p.IsCursorOn();
  p.WriteStr(kom);
  dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(kom),Strings.Length(kom),size);
  x:=x+size.cx;
  p.Bar(x,y,x+maxlen*p.charWidth-1,y-p.charHeight+1,0);
  p.WriteStr(txt);
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
      dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(txt),position-1,size);
      p.GotoXY(x+size.cx,y);
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
          p.GotoXY(x,y);
          p.WriteStr(txt);
        END;
        dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(txt),lng,size);
        p.Bar(x+size.cx,y,
              x+maxlen*p.charWidth-1,y-p.charHeight+1,0);
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
            p.Bar(x,y,x+maxlen*p.charWidth-1,y-p.charHeight+1,0);
            txt[0]:=0X;
            edit:=TRUE;
          END;
          IF (lng>0) & (position<=lng) THEN
            DEC(lng);
            Strings.Delete(txt,position,1);
          END;
          p.GotoXY(x,y);
          p.WriteStr(txt);
          dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(txt),lng,size);
          p.Bar(x+size.cx,y,
                x+maxlen*p.charWidth-1,y-p.charHeight+1,0);
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
            p.Bar(x,y,x+maxlen*p.charWidth-1,y-p.charHeight+1,0);
            txt[0]:=0X;
            edit:=TRUE;
          END;
          Strings.InsertChar(taste,txt,position);
          IF position=lng+1 THEN
            dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(txt),position-1,size);
            p.GotoXY(x+size.cx,y);
            h[0]:=taste;
            h[1]:=0X;
            p.WriteStr(h);
          ELSE
            p.GotoXY(x,y);
            p.WriteStr(txt);
          END;
          INC(position); 
          INC(lng);
        ELSE dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION); END;
      END; 
    END;
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
  END;
  IF cOn THEN p.CursorOn() ELSE p.CursorOff(); END;
END Input;

PROCEDURE (p:CBitmapPaneP) ReadStr*(VAR t:ARRAY OF CHAR; maxl:LONGINT; VAR resCode:CHAR);
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
    p.Input(p.cursX,p.maxY-p.cursY,k,t,maxl,code,INPT_TEXT,FALSE,pos);
  END;
  resCode:=code;
END ReadStr;

PROCEDURE (p:CBitmapPaneP) EditStr*(VAR t:ARRAY OF CHAR; maxl:LONGINT; VAR resCode:CHAR);
VAR
  k:ARRAY (1) OF CHAR;
  code:CHAR;
  pos:LONGINT;
BEGIN
  IF maxl>LEN(t)-1 THEN maxl:=SHORT(LEN(t)-1) END;
  k[0]:=0X;
  pos:=0;
  REPEAT
    p.Input(p.cursX,p.maxY-p.cursY,k,t,maxl,code,INPT_TEXT,FALSE,pos);
  UNTIL (code=ENTER) OR (code=ESC) OR (code=TAB) OR 
        (code=CURSUP) OR (code=CURSDOWN) OR (code=PAGEUP) OR (code=PAGEDOWN);
  resCode:=code;
END EditStr;

PROCEDURE (p:CBitmapPaneP) TextWidth*(VAR txt:ARRAY OF CHAR):LONGINT;
VAR
  size:WD.SIZE;
  dummy:WD.BOOL;
BEGIN
  dummy:=WG.GetTextExtentPointA(p.hdc,SYSTEM.ADR(txt),Strings.Length(txt),size);
  RETURN size.cx;
END TextWidth;

PROCEDURE (p:CBitmapPaneP) TextHeight*():LONGINT;
BEGIN
  RETURN p.charHeight;
END TextHeight;

PROCEDURE (p:CBitmapPaneP) Print*();
VAR
  i,j,ii,jj,x,y:LONGINT;
  xf,yf,xw,yw,posx,posy:LONGINT;
  hdc:WD.HDC;
  dummy1:WD.BOOL;
  dummyl:LONGINT;
  col:WD.COLORREF;
  hmemdc:WD.HDC;
  hBitmap:WD.HBITMAP;
  holdmap:WD.HBITMAP;
  info:WG.BITMAPINFO2;
  bitCount:LONGINT;
  win:StdWins.WaitWin;
  res:BOOLEAN;
  rect:WD.RECT;
BEGIN
  IF P.StartWithDialog() THEN
    NEW(win);
    win.Init;
    res:=win.Open();
    P.GetInfo(x,y,hdc);
    P.SetLeftMargin(WinUtils.LeftPrintMargin());
    P.SetTopMargin(WinUtils.TopPrintMargin());
    bitCount:=WG.GetDeviceCaps(hdc,WG.BITSPIXEL)*WG.GetDeviceCaps(hdc,WG.PLANES);
    xw:=WG.GetDeviceCaps(hdc,WG.HORZRES);
    xf:=xw DIV (p.maxX+1);
    yw:=WG.GetDeviceCaps(hdc,WG.VERTRES);
    yf:=yw DIV (p.maxY+1);
    IF xf>yf THEN xf:=yf END;
    posx:=(xw-(p.maxX+1)*xf) DIV 2;
    posy:=(yw-(p.maxY+1)*xf) DIV 2;
    rect.left:=posx; rect.right:=posx+(p.maxX+1)*xf;
    rect.top:=posy;  rect.bottom:=posy+(p.maxY+1)*xf;
    dummyl:=WU.FillRect(hdc,rect,p.hBackBrush);
    IF bitCount>1 THEN
      yf:=xf;
      DEC(xf);
      win.SetRange(WIDTH);
      FOR i:=0 TO WIDTH-1 DO
        FOR j:=0 TO HEIGHT-1 DO
          col:=WG.GetPixel(p.hmemdc,i,j);
          IF col#p.backCol THEN
            FOR ii:=0 TO xf DO 
              FOR jj:=0 TO xf DO
                dummyl:=WG.SetPixel(hdc,posx+i*yf+ii,posy+j*yf+jj,col);
              END;
            END;
          END;
        END;
        win.Current(i);
      END;
    ELSE 
      win.SetRange(3);
      hmemdc:=WG.CreateCompatibleDC(hdc);
      ASSERT(hmemdc#WD.NULL);
      info.bmiHeader.biSize:=SIZE(WG.BITMAPINFOHEADER);
      info.bmiHeader.biWidth:=p.maxX+1;
      info.bmiHeader.biHeight:=p.maxY+1;
      info.bmiHeader.biPlanes:=1;
      info.bmiHeader.biBitCount:=1;
      info.bmiHeader.biCompression:=WG.BI_RGB;
      info.bmiHeader.biSizeImage:=0;
      info.bmiHeader.biXPelsPerMeter:=25*75;
      info.bmiHeader.biYPelsPerMeter:=25*75;
      info.bmiHeader.biClrUsed:=0;
      info.bmiHeader.biClrImportant:=0;
      info.bmiColors[0].rgbRed:=0FFX;
      info.bmiColors[0].rgbGreen:=0FFX;
      info.bmiColors[0].rgbBlue:=0FFX;
      info.bmiColors[0].rgbReserved:=0X;
      info.bmiColors[1].rgbRed:=0X;
      info.bmiColors[1].rgbGreen:=0X;
      info.bmiColors[1].rgbBlue:=0X;
      info.bmiColors[1].rgbReserved:=0X;
      hBitmap:=WG.CreateDIBitmap(hmemdc,
                                info.bmiHeader,
                                0,WD.NULL,
                                info,
                                WG.DIB_RGB_COLORS);
      IF hBitmap=WD.NULL THEN WinUtils.WriteError("Windows failed to create$a bitmap for printing")
      ELSE
        win.Current(1);
        holdmap:=WG.SelectObject(hmemdc,hBitmap);
        dummy1:=WG.StretchBlt(hmemdc,
                             0,0,p.maxX+1,p.maxY+1,
                             p.hmemdc,
                             0,0,p.maxX+1,p.maxY+1,
                             WG.SRCCOPY);
        ASSERT(dummy1#0); 
        win.Current(2);
        dummy1:=WG.StretchBlt(hdc,posx,posy,
                             (p.maxX+1)*xf,
                             (p.maxY+1)*xf,
                             hmemdc,
                             0,0,p.maxX+1,p.maxY+1,
                             WG.SRCCOPY);
        ASSERT(dummy1#0);
        win.Current(3);
        holdmap:=WG.SelectObject(hmemdc,holdmap);
        dummy1:=WG.DeleteObject(hBitmap);
      END;  
      dummy1:=WG.DeleteDC(hmemdc);
    END;
    P.Finished;
    win.Destroy;
    DISPOSE(win);
  END;
END Print;

END CBitPane.
