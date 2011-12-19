(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE BitPane;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, WG:=WinGDI,
       Panes, WinUtils, GH:=GlobHandles,
       P:=Print, Utils, StdWins;

CONST
  BitPaneClassTxt*="BitPane";
  WIDTH-=800;
  HEIGHT-=650;

TYPE
  BitmapPane=RECORD (Panes.Pane)
    hBitmap-:WD.HBITMAP;
    maxX:LONGINT;
    maxY:LONGINT;
    posX:LONGINT;
    posY:LONGINT;
    updateSpeed:LONGINT;
    updateCount:LONGINT;
    hmemdc-:WD.HDC;
    hdc-:WD.HDC;
    holdmap:WD.HBITMAP;
    manageInProgress:BOOLEAN;
  END;
  BitmapPaneP*=POINTER TO BitmapPane;


PROCEDURE (p:BitmapPaneP) PaintBack*(hdc:WD.HDC);
BEGIN
END PaintBack;

PROCEDURE (p:BitmapPaneP) CopyAllToClipboard*();
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
    ASSERT(hBitmap#WD.NULL);
    holdmap:=WG.SelectObject(hmemdc,hBitmap);
    dummy:=WG.StretchBlt(hmemdc,
                        0,0,p.maxX+1,p.maxY+1,
                        p.hmemdc,
                        0,0,p.maxX+1,p.maxY+1,
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

PROCEDURE (p:BitmapPaneP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
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


PROCEDURE (p:BitmapPaneP) Clear*();
VAR
  dummy1:INTEGER; 
  dummy4:WD.BOOL;
BEGIN
  IF p.holdmap#0 THEN
    dummy4:=WG.PatBlt(p.hmemdc,0,0,p.maxX+1,p.maxY+1,WG.WHITENESS);
  END;
  p.PostContentsChanged();
END Clear;
 
PROCEDURE (p:BitmapPaneP) GetDot*(x,y:LONGINT):INTEGER;
VAR
  h:LONGINT;
BEGIN
  IF WG.GetPixel(p.hmemdc,x,y)=0 THEN RETURN 1 ELSE RETURN 0 END;
END GetDot;
 
PROCEDURE (p:BitmapPaneP) SetDot*(x,y,color:LONGINT);
VAR
  rect:Panes.Rect;
  dummy1:INTEGER; 
  dummy2:LONGINT;
  dummy4:WD.BOOL;
BEGIN
  IF (x<0) OR (y<0) OR (x>p.maxX) OR (y>p.maxY) THEN RETURN; END;
  y:=p.maxY-y;
  IF p.holdmap#0 THEN
    IF color=1 THEN 
      dummy2:=WG.SetPixel(p.hmemdc,x,y,00000000H);
      dummy2:=WG.SetPixel(p.hdc,x-p.posX,y-p.posY,00000000H);
    ELSE
      dummy2:=WG.SetPixel(p.hmemdc,x,y,00FFFFFFH);
      dummy2:=WG.SetPixel(p.hdc,x-p.posX,y-p.posY,00FFFFFFH);
    END;
  END;
      (*                     0,0,p.maxX+1,p.maxY+1,
                           p.hmemdc,
                           p.posX,p.posY,*)
(*  INC(p.updateCount);
  IF p.updateCount>=p.updateSpeed THEN*)
 (*   rect.upperLeft.Init(x-p.posX,y-p.posY);
    rect.lowerRight.Init(rect.upperLeft.x+1,rect.upperLeft.y+1);
    p.PostRectChanged(rect); *)
(*    p.PostContentsChanged();
    p.updateCount:=0;
  END;*)
END SetDot;

PROCEDURE (p:BitmapPaneP) ManageVerticalScroll*(code:LONGINT; value:LONGINT):LONGINT;
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
  END;
  RETURN 0; 
END ManageVerticalScroll;

PROCEDURE (p:BitmapPaneP) ManageHorizontalScroll*(code:LONGINT; value:LONGINT):LONGINT;
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
  END;
  RETURN 0; 
END ManageHorizontalScroll;

PROCEDURE (p:BitmapPaneP) ManageScrollBars*;
VAR
  rect:WD.RECT;
  max:LONGINT;
  dummyl:LONGINT;
  dummy:WD.BOOL;
BEGIN
  IF ~p^.manageInProgress THEN
    p^.manageInProgress:=TRUE; 
    dummy:=WU.GetClientRect(p.hwnd,rect);
    max:=p.maxY-rect.bottom+1;
    IF max<0 THEN max:=0; END;
    dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,0,max,0);
    dummyl:=p.ManageVerticalScroll(1000,0);
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

PROCEDURE (p:BitmapPaneP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),BitPaneClassTxt) THEN
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
  wc.lpszClassName := SYSTEM.ADR(BitPaneClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:BitmapPaneP) Open*():BOOLEAN;
VAR
  dummy1:INTEGER; 
  dummy2:LONGINT;
  dummy3:WD.HANDLE;
  dummy4:WD.BOOL;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  flags:=SYSTEM.BITOR(WU.WS_CHILD,WU.WS_CLIPSIBLINGS); 
  flags:=SYSTEM.BITOR(flags,WU.WS_VISIBLE);
  flags:=SYSTEM.BITOR(flags,WU.WS_HSCROLL);
  flags:=SYSTEM.BITOR(flags,WU.WS_VSCROLL);
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER) END;
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION) END;
  p.CreateWindow("an XYplane",0,flags,BitPaneClassTxt);
  IF p.hwnd#WD.NULL THEN
    dummy2:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
    p.hdc:=WU.GetDC(p.hwnd);
    p.maxX:=WIDTH-1;
    p.maxY:=HEIGHT-1;
    p.posX:=0;
    p.posY:=0;
    p.keyBuffer.Init();
    p.updateSpeed:=10000;
    p.updateCount:=0;
    p.hmemdc:=WG.CreateCompatibleDC(p.hdc);
 (*   p.hBitmap:=W.CreateCompatibleBitmap(p.hmemdc,p.maxX+1,p.maxY+1);    *)
    p.hBitmap:=WG.CreateBitmap(p.maxX+1,p.maxY+1,1,1,WD.NULL);
    p.holdmap:=WG.SelectObject(p.hmemdc,p.hBitmap);
    dummy4:=WG.PatBlt(p.hmemdc,0,0,p.maxX+1,p.maxY+1,WG.WHITENESS);
    (*dummy1:=W.GetObject(p.hBitmap,10,SYSTEM.ADR(p.bitmap));*)
    p.manageInProgress:=FALSE;
    p.ManageScrollBars();
  END;
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE (p:BitmapPaneP) Shutdown*():LONGINT;
VAR
  dummy4:WD.BOOL;
BEGIN
  p.holdmap:=WG.SelectObject(p.hmemdc,p.holdmap); 
  p.holdmap:=WD.NULL;
  dummy4:=WG.DeleteDC(p.hmemdc);   
  dummy4:=WG.DeleteObject(p.hBitmap);
  RETURN p.Shutdown^();
END Shutdown;

PROCEDURE (p:BitmapPaneP) ReleaseHandles*();
VAR
  dummy:LONGINT;
BEGIN
  p.ReleaseHandles^();
  dummy:=WU.ReleaseDC(p.hwnd,p.hdc);
  ASSERT(dummy=1);
END ReleaseHandles;

PROCEDURE (p:BitmapPaneP) Print*();
VAR
  x,y:LONGINT;
  xf,yf,xw,yw:LONGINT;
  hdc:WD.HDC;
  dummy:WD.BOOL;
  hmemdc:WD.HDC;
  hBitmap:WD.HBITMAP;
  holdmap:WD.HBITMAP;
  info:WG.BITMAPINFO2;
  win:StdWins.WaitWin;
  res:BOOLEAN;
BEGIN
  IF P.StartWithDialog() THEN
    NEW(win);
    win.Init;
    res:=win.Open();
    win.SetRange(3);
    P.GetInfo(x,y,hdc);
    P.SetLeftMargin(WinUtils.LeftPrintMargin());
    P.SetTopMargin(WinUtils.TopPrintMargin());
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
      dummy:=WG.StretchBlt(hmemdc,
                          0,0,p.maxX+1,p.maxY+1,
                          p.hmemdc,
                          0,0,p.maxX+1,p.maxY+1,
                          WG.SRCCOPY);
      ASSERT(dummy#0); 
      win.Current(2);
      xw:=WG.GetDeviceCaps(hdc,WG.HORZRES);
      xf:=xw DIV (p.maxX+1);
      yw:=WG.GetDeviceCaps(hdc,WG.VERTRES);
      yf:=yw DIV (p.maxY+1);
      IF xf>yf THEN xf:=yf END;
      dummy:=WG.StretchBlt(hdc,
                          (xw-(p.maxX+1)*xf) DIV 2,
                          (yw-(p.maxY+1)*xf) DIV 2,
                          (p.maxX+1)*xf,
                          (p.maxY+1)*xf,
                          hmemdc,
                          0,0,p.maxX+1,p.maxY+1,
                          WG.SRCCOPY);
      ASSERT(dummy#0);
      win.Current(3);
      holdmap:=WG.SelectObject(hmemdc,holdmap);
      dummy:=WG.DeleteObject(hBitmap);
      
    END;  
    dummy:=WG.DeleteDC(hmemdc);
    P.Finished;
    win.Destroy;
    DISPOSE(win);
  END;
END Print;



END BitPane.
