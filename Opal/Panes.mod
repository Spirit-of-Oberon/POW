(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE Panes;

IMPORT SYSTEM, WU:=WinUser, WD:=WinDef, WG:=WinGDI,
       Utils, Process, Strings, WinUtils, OOBase, GH:=GlobHandles;

CONST
  PaneClassTxt*="PaneClass"; 
  GroupClassTxt*="GroupClass"; 
  AM_ADAPTSIZE*=0F00H;
  AM_PANE2CLIPBOARD*=0F01H;
  AM_CLIPBOARD2PANE*=0F02H;
  AM_PANE2PRINTER*=0F03H;
  AM_INPUTFROM*=0F10H;
  AM_SAVEINPUT*=0F11H;
  KeyBufSize*=16;

TYPE

  Point*=RECORD
    x*:LONGINT;
    y*:LONGINT;
  END;

  Rect*=RECORD
    upperLeft*:Point;
    lowerRight*:Point;
  END; 

  MouseInfo*=RECORD
    x*,y*:INTEGER;
    buttons*:SET;
  END;

  MouseBuffer*=RECORD
    list*:POINTER TO ARRAY OF MouseInfo;
    last:MouseInfo;
    in:INTEGER;
    out:INTEGER;
  END;

  KeyBuffer*=RECORD
    keys-:ARRAY KeyBufSize OF CHAR;
    in-:INTEGER;
    out-:INTEGER;
  END;

  PaneP*=POINTER TO Pane;
  GroupP*=POINTER TO Group;
  PaneListP*=POINTER TO PaneList;
  PaneListEleP*=POINTER TO PaneListEle;

  PaneList*=RECORD
    first:PaneListEleP;
(*    current:PaneListEleP;*)
  END;

  PaneListEle*=RECORD
    p*:PaneP;
    next*:PaneListEleP;
  END;

  Pane*=RECORD (OOBase.ObjectT)
    growRelativex1*:BOOLEAN;
    growRelativex2*:BOOLEAN;
    growRelativey1*:BOOLEAN;
    growRelativey2*:BOOLEAN;
    corner1*:Point;
    corner2*:Point;
    hwnd*:WD.HANDLE;
    keyBuffer*:KeyBuffer;
    mouseBuffer*:MouseBuffer;
    cursSav*:BOOLEAN;
    owner*:GroupP;
    tilePriority*:INTEGER;
    focused*:BOOLEAN;
    handlesReleased-:BOOLEAN;
    minWidth*:LONGINT;
    maxWidth*:LONGINT;
    minHeight*:LONGINT;
    maxHeight*:LONGINT;
    inTree*:BOOLEAN;
    caption*:BOOLEAN;
    focusRedirection*:PaneP;
    focusMark-:BOOLEAN;
    framed*:BOOLEAN;
  END;

  Group*=RECORD (Pane)
    groupPaneList*:PaneListP;
    tileMode*:INTEGER; (* 0=none, 1=hor., 2=vert *)
  END;

VAR
  ctrlId*:INTEGER;
  focusedPane*:PaneP;

PROCEDURE ^ApplicationFocused*():BOOLEAN;

PROCEDURE WritePane*(p:PaneP; txt:ARRAY OF CHAR);
VAR
  t1,t2:ARRAY 100 OF CHAR;
BEGIN
  OOBase.ObjToName(p,t2,t1);
  Strings.AppendChar(t1,0AX);
  Strings.Append(t1,txt);
  WinUtils.WriteStr(t1);
END WritePane;

PROCEDURE (p:PaneListP) Init*();
VAR
  ele:PaneListEleP;
BEGIN
  NEW(ele);
  ASSERT(ele#NIL);
  p^.first:=ele;
  ele^.p:=NIL;
  ele^.next:=ele;
END Init;

PROCEDURE (p:PaneListP) Zap*();
VAR
  ele,old,last:PaneListEleP;
BEGIN
  ele:=p.first;
  last:=ele;
  REPEAT
    old:=ele;
    ele:=ele.next;
    DISPOSE(old);
  UNTIL ele=last;
END Zap;

PROCEDURE (p:PaneListP) InsertPane*(paneP:PaneP);
VAR
  ele:PaneListEleP;
BEGIN
  NEW(ele);
  ASSERT(ele#NIL);
  ele.p:=paneP;
  ele.next:=p^.first^.next;
  p^.first^.next:=ele;
END InsertPane;

PROCEDURE (p:PaneListP) DeletePane*(paneP:PaneP);
VAR
  ele,old:PaneListEleP;
BEGIN
  ele:=p^.first;
  WHILE (ele^.next#p^.first) & (ele^.next^.p#paneP) DO
    ele:=ele.next; 
  END;
  IF ele^.next^.p=paneP THEN
    old:=ele^.next;
    ele^.next:=ele^.next^.next;
    DISPOSE(old);
  END;
END DeletePane;

PROCEDURE (p:PaneListP) FindPane*(hWnd:WD.HANDLE; VAR paneP:PaneP);
VAR
  ele:PaneListEleP;
BEGIN
  ele:=p.first^.next;
  WHILE (ele#p^.first) & (ele.p.hwnd#hWnd) DO ele:=ele.next; END;
  IF ele#p.first THEN paneP:=ele.p ELSE paneP:=NIL END;
END FindPane;

PROCEDURE (p:PaneListP) FirstPane*(VAR paneP:PaneP);
BEGIN
  paneP:=p.first.next.p;
END FirstPane;

PROCEDURE (p:PaneListP) NextPane*(VAR paneP:PaneP);
VAR
  ele:PaneListEleP;
BEGIN
  ele:=p.first^.next;
  WHILE (ele#p^.first) & (ele.p#paneP) DO ele:=ele.next; END;
  ele:=ele.next;
  IF ele#p.first THEN paneP:=ele.p ELSE paneP:=NIL END;
END NextPane;

PROCEDURE (VAR p:Point) Init*(x,y:LONGINT);
BEGIN
  p.x:=x;
  p.y:=y;
END Init;

PROCEDURE (VAR r:Rect) Init*(x1,y1,x2,y2:LONGINT);
VAR
  h:LONGINT;
BEGIN
  IF x2<x1 THEN h:=x1; x1:=x2; x2:=h END;
  IF y2<y1 THEN h:=y1; y1:=y2; y2:=h END;
  r.upperLeft.x:=x1;
  r.upperLeft.y:=y1;
  r.lowerRight.x:=x2;
  r.lowerRight.y:=y2;
END Init;

PROCEDURE (VAR r:Rect) Width*():LONGINT;
BEGIN
  RETURN ABS(r.lowerRight.x-r.upperLeft.x)+1;
END Width;

PROCEDURE (VAR r:Rect) Height*():LONGINT;
BEGIN
  RETURN ABS(r.lowerRight.y-r.upperLeft.y)+1;
END Height;

PROCEDURE (VAR r:Rect) Write*;
VAR
  t1,t2:ARRAY 100 OF CHAR;
BEGIN
  t2:="Rect=(";
  Strings.Str(r.upperLeft.x,t1); Strings.Append(t2,t1); Strings.Append(t2,",");
  Strings.Str(r.upperLeft.y,t1); Strings.Append(t2,t1); Strings.Append(t2,")-(");
  Strings.Str(r.lowerRight.x,t1);Strings.Append(t2,t1); Strings.Append(t2,",");
  Strings.Str(r.lowerRight.y,t1);Strings.Append(t2,t1); Strings.Append(t2,")");
  Strings.AppendChar(t2,0AX);
  Strings.Str(r.Width(),t1);Strings.Append(t2,t1); Strings.Append(t2," * ");
  Strings.Str(r.Height(),t1);Strings.Append(t2,t1); 
  WinUtils.WriteStr(t2);
END Write;

PROCEDURE (VAR k:KeyBuffer) Init*();
BEGIN
  k.in:=0;
  k.out:=0;
END Init;

PROCEDURE (VAR k:KeyBuffer) KeyPressed*():BOOLEAN;
BEGIN
  RETURN k.in#k.out;
END KeyPressed;

PROCEDURE (VAR k:KeyBuffer) ReadKey*():CHAR;
VAR
  x:CHAR;
BEGIN
  IF k.in#k.out THEN
    x:=k.keys[k.out];
    k.out:=(k.out+1) MOD KeyBufSize;
    RETURN x;
  ELSE
    RETURN 0X;
  END;
END ReadKey;

PROCEDURE (VAR k:KeyBuffer) PutKey(x:CHAR);
VAR
  dummy:WD.BOOL;
BEGIN
  IF (k.in+1) MOD KeyBufSize # k.out THEN
    k.keys[k.in]:=x;
    k.in:=(k.in+1) MOD KeyBufSize;
  ELSE
    dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
  END;
END PutKey;

PROCEDURE (VAR k:KeyBuffer) Flush*();
BEGIN
  k.in:=0;
  k.out:=0;
END Flush;

PROCEDURE (VAR k:MouseBuffer) Init*();
BEGIN
  k.in:=0;
  k.out:=0;
  k.list:=NIL;
  k.last.x:=0;
  k.last.y:=0;
  k.last.buttons:={};
END Init;

PROCEDURE (VAR k:MouseBuffer) Peek*(VAR m:MouseInfo):BOOLEAN;
VAR
  x:CHAR;
BEGIN
  IF k.list=NIL THEN
    m:=k.last;
    RETURN FALSE;
  END;
  IF k.in#k.out THEN
    m:=k.list[k.out];
    k.out:=(k.out+1) MOD SHORT(LEN(k.list^));
    RETURN TRUE;
  ELSE
    m:=k.last;
    RETURN FALSE;
  END;
END Peek;

PROCEDURE (VAR k:MouseBuffer) Put*(x:MouseInfo);
BEGIN
  k.last:=x;
  IF (k.in+1) MOD LEN(k.list^) # k.out THEN
    k.list[k.in]:=x;
    k.in:=(k.in+1) MOD SHORT(LEN(k.list^));
  END;
END Put;

PROCEDURE (VAR k:MouseBuffer) Flush*();
BEGIN
  k.in:=0;
  k.out:=0;
END Flush;

(* ******************************************************* *)

PROCEDURE (VAR p:Pane) Init*();
BEGIN
  p.growRelativex1:=FALSE;
  p.growRelativex2:=FALSE;
  p.growRelativey1:=FALSE;
  p.growRelativey2:=FALSE;
  p.corner1.x:=0;
  p.corner1.y:=0;
  p.corner2.x:=1;
  p.corner2.y:=1;
  p.tilePriority:=10;
  p.keyBuffer.Init();
  p.mouseBuffer.Init();
  p.handlesReleased:=FALSE;
  p.minWidth:=0;
  p.minHeight:=0;
  p.maxWidth:=32000;
  p.maxHeight:=32000;
  p.inTree:=FALSE;
  p.caption:=FALSE;
  p.focusRedirection:=NIL;
  p.focusMark:=FALSE;
  p.framed:=FALSE;
END Init;

PROCEDURE (p:PaneP) SetFrame*(upperLeftCorner,lowerRightCorner:Point);
BEGIN
  p.growRelativex1:=FALSE;
  p.growRelativex2:=FALSE;
  p.growRelativey1:=FALSE;
  p.growRelativey2:=FALSE;
  p.corner1:=upperLeftCorner;
  p.corner2:=lowerRightCorner;
END SetFrame;

PROCEDURE (p:PaneP) SetFrameRatio*(upperLeftRatio,lowerRightRatio:Point);
BEGIN
  p.growRelativex1:=TRUE;
  p.growRelativex2:=TRUE;
  p.growRelativey1:=TRUE;
  p.growRelativey2:=TRUE;
  p.corner1:=upperLeftRatio;
  p.corner2:=lowerRightRatio;
END SetFrameRatio;

PROCEDURE (p:PaneP) GetSize*(VAR x,y:LONGINT);
BEGIN
  x:=p.corner2.x-p.corner1.x+1;
  y:=p.corner2.y-p.corner1.y+1;
END GetSize;

PROCEDURE (p:PaneP) GetClientSize*(VAR x,y:LONGINT);
VAR
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  IF p.inTree THEN
    dummy:=WU.GetClientRect(p.hwnd,rect);
    x:=rect.right;
    y:=rect.bottom;
  ELSE 
    x:=p.corner2.x-p.corner1.x+1;
    y:=p.corner2.y-p.corner1.y+1;
  END;
END GetClientSize;

PROCEDURE (p:PaneP) CalcCurrentPosition*(VAR r:Rect);
VAR
  x,y:LONGINT;

  PROCEDURE Ratio2Pos(size,ratio:LONGINT):LONGINT;
  BEGIN
    RETURN size*ratio DIV 1000;
  END Ratio2Pos;

BEGIN
  IF p.owner#NIL THEN p.owner.GetClientSize(x,y) ELSE x:=10; y:=10; END;
  IF p.growRelativex1 THEN r.upperLeft.x :=Ratio2Pos(x,p.corner1.x) ELSE r.upperLeft.x:=p.corner1.x END;
  IF p.growRelativey1 THEN r.upperLeft.y :=Ratio2Pos(y,p.corner1.y) ELSE r.upperLeft.y:=p.corner1.y END;
  IF p.growRelativex2 THEN r.lowerRight.x:=Ratio2Pos(x,p.corner2.x) ELSE r.lowerRight.x:=p.corner2.x END;
  IF p.growRelativey2 THEN r.lowerRight.y:=Ratio2Pos(y,p.corner2.y) ELSE r.lowerRight.y:=p.corner2.y END;
END CalcCurrentPosition;

PROCEDURE (p:PaneP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  dummy:WD.BOOL;
  rect:WD.RECT;
  grayBrush,oldBrush:WD.HBRUSH;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,rect);
  grayBrush:=WG.GetStockObject(WG.GRAY_BRUSH);
  oldBrush:=WG.SelectObject(hdc,grayBrush);
  ASSERT(oldBrush#WD.NULL);
  dummy:=WU.FillRect(hdc,rect,grayBrush);
  oldBrush:=WG.SelectObject(hdc,oldBrush);
  ASSERT(oldBrush#WD.NULL);
END Paint;

PROCEDURE (p:PaneP) PaintBack*(hdc:WD.HDC);
VAR
  dummy:WD.BOOL;
  rect:WD.RECT;
  grayBrush,oldBrush:WD.HBRUSH;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,rect);
  grayBrush:=WG.GetStockObject(WG.LTGRAY_BRUSH);
  oldBrush:=WG.SelectObject(hdc,grayBrush);
  ASSERT(oldBrush#WD.NULL);
  dummy:=WU.FillRect(hdc,rect,grayBrush);
  oldBrush:=WG.SelectObject(hdc,oldBrush);
  ASSERT(oldBrush#WD.NULL);
END PaintBack;

PROCEDURE (p:GroupP) PaintBack*(hdc:WD.HDC);
BEGIN
END PaintBack;


PROCEDURE (p:PaneP) SetTitle*(t:ARRAY OF CHAR);
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.SetWindowTextA(p.hwnd,SYSTEM.ADR(t));
END SetTitle;

PROCEDURE (p:PaneP) AdaptSize*();
VAR
  rect:Rect;
  wRect:WD.RECT;
  dummy:LONGINT;
  d2:WD.BOOL;
BEGIN
  IF (~p.inTree) OR (p.owner=NIL) THEN RETURN END;
  p.CalcCurrentPosition(rect);
  d2:=WU.MoveWindow(p.hwnd,
                   rect.upperLeft.x,
                   rect.upperLeft.y,
                   rect.Width(),
                   rect.Height(),1);
END AdaptSize;

PROCEDURE (p:PaneP) ManageVerticalScroll*(code:LONGINT; value:LONGINT):LONGINT;
BEGIN
  RETURN 0;
END ManageVerticalScroll;

PROCEDURE (p:PaneP) ManageHorizontalScroll*(code:LONGINT; value:LONGINT):LONGINT;
BEGIN
  RETURN 0;
END ManageHorizontalScroll;

PROCEDURE (p:PaneP) ManageScrollBars*();
BEGIN
END ManageScrollBars;

PROCEDURE (p:PaneP) Resize*(sizeKind:LONGINT);
VAR
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  IF sizeKind#WU.SIZEICONIC THEN 
    p.ManageScrollBars();
  END;
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  dummy:=WU.InvalidateRect(p.hwnd,wRect,1); 
  dummy:=WU.UpdateWindow(p.hwnd); 
END Resize;

PROCEDURE (p:PaneP) KeyPressed*():BOOLEAN;
BEGIN
  Process.Yield();
  RETURN(p.keyBuffer.KeyPressed());
END KeyPressed;

PROCEDURE (p:PaneP) CursorOn*();
BEGIN
END CursorOn;

PROCEDURE (p:PaneP) CursorOff*();
BEGIN
END CursorOff;

PROCEDURE (p:PaneP) IsCursorOn*():BOOLEAN;
BEGIN
  RETURN FALSE;
END IsCursorOn;

PROCEDURE (p:PaneP) PositionCursor*();
BEGIN
END PositionCursor;

PROCEDURE (p:PaneP) CopyAllToClipboard*();
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
END CopyAllToClipboard;

PROCEDURE (p:PaneP) Print*();
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
END Print;

PROCEDURE (p:PaneP) ReadKey*():CHAR;
VAR
  h:CHAR;
BEGIN
  WHILE ~p.KeyPressed() DO END;
  RETURN p.keyBuffer.ReadKey();
END ReadKey;

PROCEDURE (p:PaneP) ReadMouse*(VAR m:MouseInfo; VAR newMove:BOOLEAN);
BEGIN
  Process.Yield();
  newMove:=p.mouseBuffer.Peek(m);
END ReadMouse;

PROCEDURE (p:PaneP) KillFocus*();
BEGIN
END KillFocus;

PROCEDURE (p:PaneP) SetFocus*();
BEGIN
END SetFocus;

PROCEDURE (p:PaneP) PostSizeChange*();
VAR
  dummy1:LONGINT;
BEGIN
  dummy1:=WU.SendMessageA(p.hwnd,AM_ADAPTSIZE,0,0);
END PostSizeChange;

PROCEDURE (p:PaneP) PostContentsChanged*();
VAR
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  dummy:=WU.InvalidateRect(p.hwnd,wRect,0);
  dummy:=WU.UpdateWindow(p.hwnd);
END PostContentsChanged;

PROCEDURE (p:PaneP) PostRectChanged*(rect:Rect);
VAR
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  wRect.left:=rect.upperLeft.x;
  wRect.right:=rect.lowerRight.x;
  wRect.top:=rect.upperLeft.y;
  wRect.bottom:=rect.lowerRight.y;
  dummy:=WU.InvalidateRect(p.hwnd,wRect,0);
  dummy:=WU.UpdateWindow(p.hwnd);
END PostRectChanged;

PROCEDURE (p:PaneP) SetInputFocus*;
VAR
  dummy1:WD.HWND;
BEGIN
  focusedPane:=p;
  IF ApplicationFocused() THEN dummy1:=WU.SetFocus(p.hwnd); END;
END SetInputFocus;

PROCEDURE (p:PaneP) GetOwnerSize*(VAR x,y:LONGINT);
VAR
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.GetClientRect(p^.owner^.hwnd,rect);
  x:=rect.right;
  y:=rect.bottom;
END GetOwnerSize;

PROCEDURE (p:PaneP) ReleaseHandles*();
BEGIN
  p.handlesReleased:=TRUE;
END ReleaseHandles;

PROCEDURE (p:PaneP) Shutdown*():LONGINT;
BEGIN
  IF p.mouseBuffer.list#NIL THEN DISPOSE(p.mouseBuffer.list) END;
  IF ~p.handlesReleased THEN p.ReleaseHandles() END;
  RETURN 0;
END Shutdown;

PROCEDURE (p:PaneP) ShowFocusMark*(x:BOOLEAN);
VAR
  res:LONGINT;
  par:INTEGER;
BEGIN
  IF ~p.inTree THEN RETURN END;
  IF x THEN par:=1 ELSE par:=0 END;
  IF p.owner#NIL THEN 
    res:=WU.SendMessageA(p.hwnd,WU.WM_NCACTIVATE,par,0);
    p.owner.ShowFocusMark(x);
  END;
  p.focusMark:=x;
END ShowFocusMark;

PROCEDURE (p:PaneP) DefWindowProc*(hWnd: WD.HWND;     
                                   message: WD.UINT;
                                   wParam: WD.WPARAM;
                                   lParam: WD.LPARAM): LONGINT;
VAR
  hdc:WD.HDC;
  paint:WU.PAINTSTRUCT;
  dummy1:WD.HANDLE;
  dummy2:WD.HWND;
  dummy3:INTEGER;
  dummyb:WD.BOOL;
  h:LONGINT;
  mInfo:MouseInfo;
BEGIN
  IF message=WU.WM_CHAR THEN
    p.keyBuffer.PutKey(CHR(wParam));

  ELSIF message=WU.WM_KEYDOWN THEN
    IF 29 IN SYSTEM.VAL(SET,lParam) THEN (* ALT key pressed ? *)
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);
    ELSE
      IF (wParam=12) OR (wParam=16) OR (wParam=17) OR
         (wParam=19) OR (wParam=20) OR (wParam=45) OR
         ((wParam>=33) & (wParam<=40)) OR
         (wParam=46) OR 
         ((wParam>=112) & (wParam<=123)) THEN
        p.keyBuffer.PutKey(0X);
        p.keyBuffer.PutKey(CHR(wParam MOD 256));
      ELSE
        RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);
      END;
    END;

  ELSIF (message=WU.WM_MOUSEMOVE) OR (message=WU.WM_LBUTTONDOWN) OR 
        (message=WU.WM_RBUTTONDOWN) OR (message=WU.WM_LBUTTONUP) OR
        (message=WU.WM_RBUTTONUP) OR (message=WU.WM_MBUTTONDOWN) OR
        (message=WU.WM_MBUTTONUP) THEN
    IF p.mouseBuffer.list#NIL THEN
      mInfo.x:=SYSTEM.LOWORD(lParam);
      mInfo.y:=SYSTEM.HIWORD(lParam);
      mInfo.buttons:={};
      IF SYSTEM.BITAND(wParam,WU.MK_LBUTTON)#0 THEN mInfo.buttons:={0} END;
      IF SYSTEM.BITAND(wParam,WU.MK_MBUTTON)#0 THEN mInfo.buttons:=mInfo.buttons+{1} END;
      IF SYSTEM.BITAND(wParam,WU.MK_RBUTTON)#0 THEN mInfo.buttons:=mInfo.buttons+{2} END;
      p.mouseBuffer.Put(mInfo);
    END;
    IF message=WU.WM_LBUTTONDOWN THEN dummy1:=WU.SetFocus(hWnd) END;
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  ELSIF message=WU.WM_NCHITTEST THEN
    h:=WU.DefWindowProcA(hWnd, message, wParam, lParam);
    IF h=WU.HTCAPTION THEN
      RETURN WU.HTNOWHERE;
    ELSE 
      RETURN h;
    END;

  ELSIF message=WU.WM_SETCURSOR THEN
    IF (SYSTEM.LOWORD(lParam)=WU.HTNOWHERE) & (SYSTEM.HIWORD(lParam)=WU.WM_LBUTTONDOWN) & (p.hwnd#WU.GetFocus()) THEN
      dummy1:=WU.SetFocus(p.hwnd);
      RETURN 0;
    ELSE
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);
    END;

  ELSIF message=WU.WM_SIZE THEN
    p.Resize(wParam);

  ELSIF message=AM_ADAPTSIZE THEN
    p.AdaptSize;

  ELSIF message=WU.WM_VSCROLL THEN
    RETURN p.ManageVerticalScroll(SYSTEM.LOWORD(wParam),SYSTEM.HIWORD(wParam));

  ELSIF message=WU.WM_HSCROLL THEN
    RETURN p.ManageHorizontalScroll(SYSTEM.LOWORD(wParam),SYSTEM.HIWORD(wParam));

  ELSIF message=WU.WM_SETFOCUS THEN
    IF (p.focusRedirection#NIL) & (p.focusRedirection.inTree) THEN
      p.focusRedirection.SetInputFocus;
      RETURN WD.NULL;
    ELSE
      p.ShowFocusMark(TRUE);
      focusedPane:=p;
      p.focused:=TRUE;
      IF p.cursSav THEN 
        p.CursorOn(); 
        p.PositionCursor();
      END;
      p.SetFocus();
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);
    END;

  ELSIF message=WU.WM_KILLFOCUS THEN
    p.focused:=FALSE;
    p.KillFocus;
    IF p.IsCursorOn() THEN
      p.CursorOff();
      p.cursSav:=TRUE;
    ELSE
      p.cursSav:=FALSE;
    END;
    (*h:=W.SendMessage(p.hwnd,W.WM_NCACTIVATE,0,0);        *)
    p.ShowFocusMark(FALSE);
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  ELSIF message=WU.WM_PAINT THEN
    hdc:=WU.BeginPaint(hWnd,paint);
    p.Paint(hdc,paint);
    dummyb:=WU.EndPaint(hWnd,paint);  
    RETURN 1;

  ELSIF message=WU.WM_ERASEBKGND THEN
    p.PaintBack(wParam);
    RETURN 1;

  ELSIF message=WU.WM_DESTROY THEN
    p.ReleaseHandles();
    IF focusedPane=p THEN focusedPane:=NIL END;

  ELSE
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  END;  
  RETURN(WD.NULL); 
END DefWindowProc;

PROCEDURE [_APICALL] PaneHandleEvent*(hWnd: WD.HWND;
                                      message: WD.UINT;
                                      wParam: WD.WPARAM;
                                      lParam: WD.LPARAM): LONGINT;
VAR
  h:LONGINT;
  p:PaneP;
BEGIN
  h:=WU.GetWindowLongA(hWnd,0);
  (*gloPaneList.FindPane(hWnd,p);*)
  IF h=0 THEN RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam) END;
  p:=SYSTEM.VAL(PaneP,h);
  ASSERT(p IS PaneP);
  RETURN p.DefWindowProc(hWnd, message, wParam, lParam)
END PaneHandleEvent;

PROCEDURE (p:PaneP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),PaneClassTxt) THEN
    RETURN TRUE;
  END;
  wc.style := WU.CS_PARENTDC;    
  wc.lpfnWndProc := PaneHandleEvent;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 4;                   
  wc.hInstance := GH.GetAppInstanceHandle();
  wc.hIcon := WD.NULL; 
  wc.hCursor := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WD.NULL; (*W.GetStockObject(W.GRAY_BRUSH); *)
  wc.lpszMenuName := WD.NULL; 
  wc.lpszClassName := SYSTEM.ADR(PaneClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:PaneP) CreateWindow*(titel:ARRAY OF CHAR;     (* window name           *)
                                  exStyleFlags:LONGINT;    (* extended window style *)
                                  styleFlags:LONGINT;      (* window style          *)
                                  classTxt:ARRAY OF CHAR); (* window class name     *)
VAR
  rect:Rect;
  parentWnd:WD.HWND;
  couldHaveMenu:BOOLEAN;
  idOrMenu:LONGINT;
BEGIN
  IF ~p.RegisterClass() THEN 
    p.hwnd:=WD.NULL; 
    RETURN;
  END;
  p.CalcCurrentPosition(rect);
  IF (p.owner#NIL) & (p.owner.hwnd#WD.NULL) THEN 
    parentWnd:=p.owner.hwnd;
  ELSE 
    parentWnd:=WU.HWND_DESKTOP;
  END;
  couldHaveMenu:=(SYSTEM.BITAND(styleFlags,WU.WS_POPUP)#0) OR 
                 (SYSTEM.BITAND(styleFlags,WU.WS_OVERLAPPED)#0);
  IF couldHaveMenu THEN 
    idOrMenu:=0; (* no menu *)
  ELSE 
    idOrMenu:=ctrlId; (* child window identifier *)
  END;
  p.hwnd:=WU.CreateWindowExA(exStyleFlags,
                             SYSTEM.ADR(classTxt),
                             SYSTEM.ADR(titel),
                             styleFlags,
                             rect.upperLeft.x,
                             rect.upperLeft.y,
                             rect.Width(),
                             rect.Height(),
                             parentWnd,
                             idOrMenu,
                             GH.GetAppInstanceHandle(),             
                             WD.NULL);
  IF (p.hwnd#WD.NULL) & ~couldHaveMenu THEN
    INC(ctrlId);
  END;
END CreateWindow;

PROCEDURE (p:PaneP) SetCaptionVisible*(x:BOOLEAN);
VAR
  oFlags,flags:LONGINT;
  dummy:WD.BOOL;
BEGIN
  IF x=p.caption THEN RETURN END;
  p.caption:=x;
  IF p.inTree THEN
    flags:=WU.GetWindowLongA(p.hwnd,WU.GWL_STYLE);
    oFlags:=flags;
    IF x THEN
      flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION);
    ELSE
      flags:=SYSTEM.BITAND(flags,SYSTEM.BITNOT(WU.WS_CAPTION));
    END;
    IF flags#oFlags THEN 
      oFlags:=WU.SetWindowLongA(p.hwnd,WU.GWL_STYLE,flags); 
      dummy:=WU.MoveWindow(p.hwnd,0,0,10,10,0);
      p.AdaptSize;
    END;
  END;
END SetCaptionVisible;

PROCEDURE (p:PaneP) Open*():BOOLEAN;
VAR
  dummy:LONGINT;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  flags:=SYSTEM.BITOR(WU.WS_CHILD,WU.WS_VISIBLE);
  flags:=SYSTEM.BITOR(flags,WU.WS_CLIPSIBLINGS);
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER) END;
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION) END;
  p.CreateWindow("a Pane",0,flags,PaneClassTxt);
  IF p.hwnd#WD.NULL THEN
    dummy:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
  END;
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE (p:PaneP) ChangeInputToFile*();
BEGIN
END ChangeInputToFile;

PROCEDURE (p:PaneP) SaveInputToFile*();
BEGIN
END SaveInputToFile;

PROCEDURE (p:GroupP) ChildPanesNotify*(msg:WD.UINT;
                                       wpar:WD.WPARAM;
                                       lpar:WD.LPARAM);
VAR
  paneP:PaneP;
  dummy1:LONGINT;
BEGIN
  p.groupPaneList.FirstPane(paneP);
  WHILE paneP#NIL DO
    dummy1:=WU.SendMessageA(paneP.hwnd,msg,wpar,lpar); 
    p.groupPaneList.NextPane(paneP);
  END; 
END ChildPanesNotify;

PROCEDURE (p:GroupP) AllInTree():BOOLEAN;
VAR
  pane:PaneP;
  all:BOOLEAN;
BEGIN
  all:=p.inTree;
  p.groupPaneList.FirstPane(pane);
  WHILE (pane#NIL) & all DO
    all:=all & pane.inTree;
    IF pane IS GroupP THEN all:=all & pane(GroupP).AllInTree() END;
    p.groupPaneList.NextPane(pane);
  END; 
  RETURN all;
END AllInTree;

PROCEDURE (p:GroupP) ShowAllWindows(cmdShow:INTEGER);
VAR
  paneP:PaneP;
  dummy:WD.BOOL;
BEGIN
  IF ~p.inTree THEN RETURN END;
  p.groupPaneList.FirstPane(paneP);
  WHILE paneP#NIL DO
    ASSERT(paneP.hwnd#WD.NULL); 
    dummy:=WU.ShowWindow(paneP.hwnd,cmdShow);
    IF paneP IS GroupP THEN 
      paneP(GroupP).ShowAllWindows(cmdShow);
    END;
    p.groupPaneList.NextPane(paneP);
  END; 
END ShowAllWindows;

PROCEDURE (p:GroupP) TileHor*();
VAR
  sum:LONGINT;
  sumX:LONGINT;
  width:LONGINT;
  oldp:LONGINT;
  h,paneP:PaneP;
  rect:WD.RECT;
  p1,p2:Point;
  dummy:WD.BOOL;
BEGIN
  p.ShowAllWindows(WU.SW_HIDE);
  sum:=0;
  p.groupPaneList.FirstPane(paneP);
  WHILE paneP#NIL DO
    sum:=sum+paneP.tilePriority;
    p.groupPaneList.NextPane(paneP);
  END; 
  IF sum>0 THEN
    sumX:=0;
    dummy:=WU.GetClientRect(p.hwnd,rect);
    p1.y:=0;
    p2.y:=rect.bottom-1;
    oldp:=0;
    width:=rect.right;
    p.groupPaneList.FirstPane(paneP);
    WHILE paneP#NIL DO
      p1.x:=oldp;
      p2.x:=p1.x+width*paneP.tilePriority DIV sum - 1;
      sumX:=sumX+p2.x-p1.x+1;
      h:=paneP;
      p.groupPaneList.NextPane(paneP);
      IF (paneP=NIL) & (sumX#width) THEN
        p2.x:=p2.x+width-sumX;
      END;
      h.SetFrame(p1,p2);
      h.AdaptSize;
      oldp:=p2.x+1;
    END; 
  END;
  p.ShowAllWindows(WU.SW_SHOWNA);
END TileHor;

PROCEDURE (p:GroupP) TileVer*();
VAR
  sum:LONGINT;
  sumY:LONGINT;
  height:LONGINT;
  oldp:LONGINT;
  h,paneP:PaneP;
  rect:WD.RECT;
  p1,p2:Point;
  dummy:WD.BOOL;
BEGIN
  p.ShowAllWindows(WU.SW_HIDE);
  sum:=0;
  p.groupPaneList.FirstPane(paneP);
  WHILE paneP#NIL DO
    sum:=sum+paneP.tilePriority;
    p.groupPaneList.NextPane(paneP);
  END; 
  IF sum>0 THEN
    sumY:=0;
    dummy:=WU.GetClientRect(p.hwnd,rect);
    p1.x:=0;
    p2.x:=rect.right-1;
    oldp:=0;
    height:=rect.bottom;
    p.groupPaneList.FirstPane(paneP);
    WHILE paneP#NIL DO
      p1.y:=oldp;
      p2.y:=p1.y+height*paneP.tilePriority DIV sum - 1;
      sumY:=sumY+p2.y-p1.y+1;
      h:=paneP;
      p.groupPaneList.NextPane(paneP);
      IF (paneP=NIL) & (sumY#height) THEN
        p2.y:=p2.y+height-sumY;
      END;
      h.SetFrame(p1,p2);
      h.AdaptSize;
      oldp:=p2.y+1;
    END; 
  END;
  p.ShowAllWindows(WU.SW_SHOWNA);
END TileVer;

PROCEDURE (p:GroupP) AdaptSize*();
VAR
  h:WD.HWND;
  paneP:PaneP;
BEGIN
  IF ~p.inTree THEN RETURN END;
  IF ApplicationFocused() THEN h:=WU.GetFocus() ELSE h:=WD.NULL END;
  p.AdaptSize^;  
  CASE p.tileMode OF
    0:p.groupPaneList.FirstPane(paneP);
      WHILE paneP#NIL DO
        paneP.AdaptSize();
        p.groupPaneList.NextPane(paneP);
      END; 
  | 1:p.TileHor;
  | 2:p.TileVer;
  END;
  IF h#WD.NULL THEN h:=WU.SetFocus(h) END;
END AdaptSize;
                     
PROCEDURE (p:GroupP) SetHorTileMode*();
BEGIN
  p.tileMode:=1;
  IF p.inTree THEN p.TileHor() END;
END SetHorTileMode;

PROCEDURE (p:GroupP) SetVerTileMode*();
BEGIN
  p.tileMode:=2;
  IF p.inTree THEN p.TileVer() END;
END SetVerTileMode;

PROCEDURE (VAR p:Group) Init*;
BEGIN
  p.Init^();
  NEW(p.groupPaneList);
  ASSERT(p.groupPaneList#NIL);
  p.groupPaneList.Init();
  p.tileMode:=0;
END Init;

PROCEDURE (p:PaneP) InsertionInit*(top:BOOLEAN):BOOLEAN;
BEGIN
  IF ~p.Open() THEN
    p.owner.groupPaneList.DeletePane(p);
    RETURN FALSE;
  ELSE
    p.inTree:=TRUE;
    IF top THEN p.owner.AdaptSize END;
    RETURN TRUE;
  END;
END InsertionInit;

PROCEDURE (p:GroupP) InsertionInit*(top:BOOLEAN):BOOLEAN;
VAR
  paneP:PaneP;
  res:BOOLEAN;
BEGIN
  res:=p.InsertionInit^(FALSE);
  p.groupPaneList.FirstPane(paneP);
  WHILE (paneP#NIL) & res DO
    res:=paneP.InsertionInit(FALSE);
    p.groupPaneList.NextPane(paneP);
  END;
  IF res & top THEN p.owner.AdaptSize END;
  RETURN res;
END InsertionInit;

PROCEDURE (p:GroupP) Insert*(pane:PaneP):BOOLEAN;
BEGIN
  p.groupPaneList.InsertPane(pane);
  pane.owner:=p;
  IF p.inTree THEN 
    RETURN pane.InsertionInit(TRUE); 
  ELSE
    RETURN TRUE;
  END;
END Insert;

PROCEDURE (p:GroupP) Remove*(pane:PaneP);
BEGIN
  p.groupPaneList.DeletePane(pane);
  pane.owner:=NIL;
  p.AdaptSize;
END Remove;

PROCEDURE (p:GroupP) Shutdown*():LONGINT;
VAR
  paneP,oldP:PaneP;
  res:INTEGER;
BEGIN
  ASSERT(p.groupPaneList#NIL);
  ASSERT(p.groupPaneList IS PaneListP);
  p.groupPaneList.FirstPane(paneP);
  res:=0;
  WHILE paneP#NIL DO
    IF paneP.Shutdown()#0 THEN res:=1 END;
    oldP:=paneP;
    p.groupPaneList.NextPane(paneP);
    DISPOSE(oldP);
  END;
  IF p.Shutdown^()#0 THEN res:=1 END;
  p.groupPaneList.Zap();
  DISPOSE(p.groupPaneList);
  p.groupPaneList:=NIL;
  RETURN res; 
END Shutdown;

PROCEDURE [_APICALL] GroupHandleEvent*(hWnd: WD.HWND;
                                       message: WD.UINT;
                                       wParam: WD.WPARAM;
                                       lParam: WD.LPARAM): LONGINT;
TYPE
  mminfotype=POINTER TO ARRAY (10) OF LONGINT;
VAR
  paint:WU.PAINTSTRUCT;
  dummy1:WD.HANDLE;
  dummy2:INTEGER;
  hdc:WD.HDC;
  mminfo:mminfotype;
  h:LONGINT;
  p:PaneP;
BEGIN
  p:=SYSTEM.VAL(PaneP,WU.GetWindowLongA(hWnd,0));
  IF p=NIL THEN RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam) END;

  IF message=WU.WM_GETMINMAXINFO THEN
    WITH p:GroupP DO
      h:=WU.DefWindowProcA(hWnd, message, wParam, lParam);
      mminfo:=SYSTEM.VAL(mminfotype,lParam);
      mminfo[2]:=p.maxWidth;
      mminfo[3]:=p.maxHeight;
      mminfo[6]:=p.minWidth;
      mminfo[7]:=p.minHeight;
      mminfo[8]:=p.maxWidth;
      mminfo[9]:=p.maxHeight;
      RETURN(h); 
    ELSE
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)  
    END;
    
  ELSIF message=WU.WM_SIZE THEN
    IF (wParam=WU.SIZEFULLSCREEN) OR 
       (wParam=WU.SIZENORMAL) THEN
      p(GroupP).AdaptSize;
    END; 
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  ELSIF message=WU.WM_DESTROY THEN
    p.ReleaseHandles();
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  ELSE                                  
    RETURN p.DefWindowProc(hWnd, message, wParam, lParam)
  END;

  RETURN(WD.NULL); 

END GroupHandleEvent; 

PROCEDURE (p:GroupP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
BEGIN
END Paint;

PROCEDURE (p:GroupP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),GroupClassTxt) THEN
    RETURN TRUE;
  END; 
  ASSERT(GH.GetAppInstanceHandle()#0);
  wc.style := 0;
  wc.lpfnWndProc := GroupHandleEvent;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 4;
  wc.hInstance := GH.GetAppInstanceHandle(); 
  wc.hIcon := WD.NULL; (* WU.LoadIcon(NULL, IDI_APPLICATION); *)
  wc.hCursor := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WG.GetStockObject(WG.WHITE_BRUSH);
  wc.lpszMenuName := WD.NULL;
  wc.lpszClassName := SYSTEM.ADR(GroupClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:GroupP) Open*():BOOLEAN;
VAR
  dummy:LONGINT;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  flags:=Utils.BitOrL(WU.WS_CHILD,WU.WS_VISIBLE);
  flags:=Utils.BitOrL(flags,WU.WS_CLIPSIBLINGS);
  flags:=Utils.BitOrL(flags,WU.WS_CLIPCHILDREN);
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION) END;
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER) END;
  p.CreateWindow("a Group",0,flags,GroupClassTxt);
  IF p.hwnd#WD.NULL THEN
    dummy:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
  END;
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE ApplicationFocused*():BOOLEAN;
BEGIN
  RETURN TRUE;
END ApplicationFocused;

BEGIN
  ctrlId:=100;
  focusedPane:=NIL;
END Panes.
