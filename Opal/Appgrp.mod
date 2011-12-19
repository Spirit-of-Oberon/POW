(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE AppGrp;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, WG:=WinGDI, WB:=WinBase,
       Utils, Strings, Panes, WinUtils, GH:=GlobHandles,
       Process;

CONST
  AppClassTxt*="ApplicationClass"; 
  DefWindowWidth=640;
  DefWindowHeight=450;

TYPE

  AppP*=POINTER TO App;

  App*=RECORD (Panes.Group)
    appInstance*:WD.HANDLE;
    borderWidthX*:LONGINT;
    borderWidthY*:LONGINT;
    captionHeight*:LONGINT;
    font*:WD.HFONT;
    nCmd:LONGINT;
    menu*:WD.HMENU;
    paintIconic:BOOLEAN;
    break:BOOLEAN;
    popup-:WD.HMENU;
  END;


VAR
  app:AppP;

PROCEDURE (p:AppP) GetSize*(VAR x,y:LONGINT);
VAR
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  x:=wRect.right-wRect.left+1;
  y:=wRect.bottom-wRect.top+1;
END GetSize;

PROCEDURE (p:AppP) CalcCurrentPosition*(VAR r:Panes.Rect);
VAR
  dummy:WD.BOOL;
  wRect:WD.RECT; 
BEGIN
  dummy:=WU.GetWindowRect(p.hwnd,wRect);
  r.Init(wRect.left,wRect.top,wRect.left+DefWindowWidth-1,wRect.top+DefWindowHeight-1);
END CalcCurrentPosition;

PROCEDURE (p:AppP) AdaptSize*;
VAR
  h:WD.HWND;
  pane:Panes.PaneP;
BEGIN
  IF Panes.ApplicationFocused() THEN h:=WU.GetFocus() ELSE h:=WD.NULL END; 
  CASE p.tileMode OF
    0:p.groupPaneList.FirstPane(pane);
      WHILE pane#NIL DO 
        pane.AdaptSize;
        p.groupPaneList.NextPane(pane);
      END;
  | 1:p.TileHor;
  | 2:p.TileVer;
  END;
  IF h#WD.NULL THEN h:=WU.SetFocus(h) END;
END AdaptSize;

PROCEDURE [_APICALL] AppHandleEvent*(hWnd: WD.HWND;
                                    message: WD.UINT;
                                    wParam: WD.WPARAM;
                                    lParam: WD.LPARAM): LONGINT;
TYPE
  MinMaxInfoP=POINTER TO WU.MINMAXINFO;
VAR
  minMaxInfoP:MinMaxInfoP;
  h:LONGINT;
  p:Panes.PaneP;
  windowId:INTEGER;
  paneP:Panes.PaneP;
  dummy1:WD.HWND;
  dummy2:LONGINT;
  dummy:WD.BOOL;
BEGIN
  h:=WU.GetWindowLongA(hWnd,0);
  IF h=0 THEN RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam) END;
  p:=SYSTEM.VAL(Panes.PaneP,h);

  IF message=WU.WM_CLOSE THEN
    IF Process.breakEnabled THEN
      Process.TerminateMsgLoops;
      dummy:=WU.IsWindow(p.hwnd);
      dummy:=WU.DestroyWindow(p.hwnd);
    END;

  ELSIF message=WU.WM_COMMAND THEN
    windowId:=SYSTEM.LOWORD(wParam);
    IF windowId=Panes.AM_PANE2CLIPBOARD THEN
      IF Panes.focusedPane#NIL THEN Panes.focusedPane.CopyAllToClipboard END;
    ELSIF windowId=Panes.AM_PANE2PRINTER THEN
      IF Panes.focusedPane#NIL THEN Panes.focusedPane.Print END;
    ELSIF windowId=Panes.AM_INPUTFROM THEN
      IF Panes.focusedPane#NIL THEN Panes.focusedPane.ChangeInputToFile END;
    ELSIF windowId=Panes.AM_SAVEINPUT THEN
      IF Panes.focusedPane#NIL THEN Panes.focusedPane.SaveInputToFile END;
    END;

  ELSIF message=WU.WM_DESTROY THEN
    IF Process.theExitProc#NIL THEN Process.theExitProc() END;
    p.ReleaseHandles();
    WU.PostQuitMessage(0);

  ELSIF message=WU.WM_GETMINMAXINFO THEN
    WITH p:AppP DO
      h:=WU.DefWindowProcA(hWnd, message, wParam, lParam);
      minMaxInfoP:=SYSTEM.VAL(MinMaxInfoP,lParam);
      minMaxInfoP.ptMaxSize.x:=p.maxWidth+p.borderWidthX*2;
      minMaxInfoP.ptMaxSize.y:=p.maxHeight+p.borderWidthY*2+p.captionHeight;
      minMaxInfoP.ptMaxTrackSize.x:=p.maxWidth+p.borderWidthX*2;
      minMaxInfoP.ptMaxTrackSize.y:=p.maxHeight+p.borderWidthY*2+p.captionHeight;
      minMaxInfoP.ptMinTrackSize.x:=100;
      minMaxInfoP.ptMinTrackSize.y:=80;
      RETURN(h); 
    ELSE
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)  
    END;
    
  ELSIF message=WU.WM_SETFOCUS THEN
    IF Panes.focusedPane#NIL THEN 
      dummy1:=WU.SetFocus(Panes.focusedPane.hwnd);
    END;
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam); 
  
  ELSIF message=WU.WM_ERASEBKGND THEN
    IF (p IS AppP) & p(AppP).paintIconic THEN
      RETURN 0;
    ELSE
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)
    END;

  ELSIF message=WU.WM_SIZE THEN
      IF (wParam=WU.SIZEFULLSCREEN) OR 
         (wParam=WU.SIZENORMAL) THEN
        IF p IS AppP THEN p(AppP).paintIconic:=FALSE END;
        p.AdaptSize;
      ELSIF wParam=WU.SIZE_MINIMIZED THEN
        IF p IS AppP THEN p(AppP).paintIconic:=TRUE END;
      END; 
      RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam);

  ELSE                                  
    RETURN WU.DefWindowProcA(hWnd, message, wParam, lParam)
  END;

  RETURN(WD.NULL); 

END AppHandleEvent; 

(*********************************************************************)

PROCEDURE (p:AppP) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
BEGIN
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),AppClassTxt) THEN 
    RETURN TRUE;
  END;
  wc.style := 0; (* W.CS_NOCLOSE; *)
  wc.lpfnWndProc := AppHandleEvent;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 12;                   
  wc.hInstance := p.appInstance; 
  wc.hIcon := WD.NULL; (* W.LoadIcon(NULL, IDI_APPLICATION); *)
  wc.hCursor := WU.LoadCursorA(WD.NULL, WU.IDC_ARROW);
  wc.hbrBackground := WG.GetStockObject(WG.WHITE_BRUSH);
  wc.lpszMenuName := WD.NULL;  
  wc.lpszClassName := SYSTEM.ADR(AppClassTxt); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:AppP) CreateWindow*(titel:ARRAY OF CHAR;     (* window name           *)
                                 exStyleFlags:LONGINT;    (* extended window style *)
                                 styleFlags:LONGINT;      (* window style          *)
                                 classTxt:ARRAY OF CHAR); (* window class name     *)
VAR 
  dummy1: LONGINT; 
  dummy3: WD.HANDLE;
  dummy4: WD.BOOL;
  rect:Panes.Rect;
  hdc: WD.HDC;
  tmetric:WG.TEXTMETRIC;
BEGIN
  p.owner:=NIL;
  p.hwnd:=WU.CreateWindowExA(exStyleFlags,
                             SYSTEM.ADR(classTxt),
                             SYSTEM.ADR(titel),
                             styleFlags,
                             WU.CW_USEDEFAULT,         
                             WU.CW_USEDEFAULT,         
                             10,10,
                             WD.NULL,                  
                             WD.NULL,                  
                             p.appInstance,             
                             WD.NULL);
  IF p.hwnd#WD.NULL THEN 
    GH.SetAppWindowHandle(p.hwnd);
    hdc:=WU.GetDC(p.hwnd);
    dummy3:=WG.SelectObject(hdc,p.font);
    dummy4:=WG.GetTextMetricsA(hdc,tmetric);
    dummy1:=WU.ReleaseDC(p.hwnd,hdc);   
    p.minWidth:=80;
    p.minHeight:=100;
    p.maxWidth:=WU.GetSystemMetrics(WU.SM_CXFULLSCREEN);
    p.maxHeight:=WU.GetSystemMetrics(WU.SM_CYFULLSCREEN);
    p.CalcCurrentPosition(rect);
    dummy4:=WU.MoveWindow(p.hwnd,
                          rect.upperLeft.x,rect.upperLeft.y,
                          rect.Width(),rect.Height(),1);  
    dummy1:=WU.ShowWindow(p.hwnd,p.nCmd);
    dummy4:=WU.UpdateWindow(p.hwnd); 
  END;
END CreateWindow;

PROCEDURE (p:AppP) InitMenu*();
VAR
  dummy:WD.BOOL;
BEGIN
  p.menu:=WU.CreateMenu();
  IF p.menu#WD.NULL THEN
    p.popup:=WU.CreatePopupMenu();
    dummy:=WU.AppendMenuA(p.popup,WU.MF_STRING,Panes.AM_PANE2CLIPBOARD,SYSTEM.ADR("&Copy"));
    dummy:=WU.AppendMenuA(p.popup,WU.MF_STRING,Panes.AM_PANE2PRINTER,SYSTEM.ADR("&Print"));
    dummy:=WU.AppendMenuA(p.menu,WU.MF_POPUP,p.popup,SYSTEM.ADR("&Pane"));
    dummy:=WU.SetMenu(p.hwnd,p.menu);
  END;
END InitMenu;

PROCEDURE (p:AppP) SetBreak*(x:BOOLEAN);
VAR
  menu:WD.HMENU;
  dummy:WD.BOOL;
  buf:ARRAY 50 OF CHAR;
  i:LONGINT;
BEGIN
  p.break:=x;
  menu:=WU.GetSystemMenu(p.hwnd,0);
  ASSERT(menu#WD.NULL);
  i:=WU.GetMenuStringA(menu,WU.SC_CLOSE,SYSTEM.ADR(buf),49,WU.MF_BYCOMMAND);
  IF x THEN
    dummy:=WU.ModifyMenuA(menu,WU.SC_CLOSE,WU.MF_BYCOMMAND,WU.SC_CLOSE,SYSTEM.ADR(buf));
  ELSE
    dummy:=WU.ModifyMenuA(menu,WU.SC_CLOSE,WU.MF_BYCOMMAND+WU.MF_GRAYED,WU.SC_CLOSE,SYSTEM.ADR(buf));
  END;
  ASSERT(dummy#0);
END SetBreak;

PROCEDURE (p:AppP) Open*():BOOLEAN;
VAR
  dummy:LONGINT;
  len,pos:LONGINT;
  t:ARRAY 301 OF CHAR;
  flags:LONGINT;
BEGIN
  len:=WB.GetModuleFileNameA(GH.GetAppInstanceHandle(),SYSTEM.ADR(t),300);
  IF len=0 THEN t[0]:=0X END;
  pos:=Strings.Length(t)-1;
  WHILE (pos>=0) & (t[pos]#"\") DO DEC(pos) END;
  IF pos>=0 THEN Strings.Delete(t,1,pos+1) END;
  pos:=Strings.Length(t)-1;
  WHILE (pos>=0) & (t[pos]#".") DO DEC(pos) END;
  IF pos>=0 THEN t[pos]:=0X END;
  flags:=SYSTEM.BITOR(WU.WS_OVERLAPPEDWINDOW,WU.WS_CLIPCHILDREN);
  flags:=SYSTEM.BITOR(flags,WU.WS_THICKFRAME);
  flags:=SYSTEM.BITOR(flags,WU.WS_MINIMIZEBOX);
  flags:=SYSTEM.BITOR(flags,WU.WS_MAXIMIZEBOX);
  p.CreateWindow(t,
                 WU.WS_EX_OVERLAPPEDWINDOW,
                 flags,
                 AppClassTxt);
  IF p.hwnd#WD.NULL THEN
    dummy:=WU.SetWindowLongA(p.hwnd,0,SYSTEM.VAL(LONGINT,p));
    p.InitMenu(); 
    p.SetBreak(FALSE);
  END;
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE (VAR p:App) Init*;
BEGIN
  p.Init^();
  p.menu:=WD.NULL;
  p.break:=FALSE;
  p.inTree:=TRUE;
  p.paintIconic:=FALSE;
  WinUtils.Prepare;
  p.font:=WinUtils.GetReasonableFixedFont();
  p.borderWidthX:=WU.GetSystemMetrics(WU.SM_CXFRAME);
  p.borderWidthY:=WU.GetSystemMetrics(WU.SM_CYFRAME); 
  p.captionHeight:=WU.GetSystemMetrics(WU.SM_CYCAPTION); 
END Init;

PROCEDURE (p:AppP) AppInit*(hInstance: WD.HANDLE; 
                            lpCmdLine: WD.LPSTR;  nCmdShow: LONGINT): BOOLEAN;
BEGIN
  GH.SetAppInstanceHandle(hInstance);
  p.Init();
  p.appInstance:=hInstance;
  p.nCmd:=nCmdShow;
  IF ~p.RegisterClass() THEN RETURN(FALSE) END;
  RETURN p.Open();
END AppInit;        

PROCEDURE (p:AppP) ReleaseHandles*();
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.menu#WD.NULL THEN 
    dummy:=WU.DestroyMenu(p.popup); 
  END;
  dummy:=WG.DeleteObject(p.font);
  p.ReleaseHandles^();
END ReleaseHandles;

PROCEDURE (p:AppP) EndApp*():LONGINT;
VAR
  msg: WU.MSG; 
  dummyl: LONGINT;
  dummy: WD.BOOL;
BEGIN
      dummy:=WU.IsWindow(p.hwnd);
  dummy:=WU.DestroyWindow(p.hwnd);
  WHILE WU.GetMessageA(msg,WD.NULL,WD.NULL,WD.NULL)#0 DO 
    dummyl:=WU.TranslateMessage(msg); 
    dummyl:=WU.DispatchMessageA(msg);   
  END;
  RETURN msg.wParam;
END EndApp;

PROCEDURE (p:AppP) Shutdown*():LONGINT;
VAR
  res:LONGINT;
BEGIN
  WinUtils.Down;
  res:=p.Shutdown^();
  RETURN res;
END Shutdown;

PROCEDURE GetApp*():AppP;
BEGIN
  RETURN app;
END GetApp;

PROCEDURE SetApp*(x:AppP);
BEGIN
  app:=x;
END SetApp;

PROCEDURE AppShutdown*():LONGINT;
BEGIN
  RETURN app.Shutdown();
END AppShutdown;

BEGIN
  Process.importantExitProc:=AppShutdown; 
  app:=NIL;
END AppGrp.
