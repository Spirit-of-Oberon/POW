(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE IOManage;

IMPORT SYSTEM, 
       WD:=WinDef, WU:=WinUser, WB:=WinBase,
       Process, OOBase, Panes, 
       ListPane,
       BitPane, 
       AppGrp, 
       Param, 
       ScreenPane, 
       CBitPane, 
       WinUtils,
       InOut;

TYPE
  InOutApp*=RECORD (AppGrp.App)
    ioPane*:InOut.InOut;
    screenPane*:ScreenPane.ScreenPaneP;
    paneGroup:Panes.GroupP;
    xyPane*:BitPane.BitmapPaneP;
    colorPane*:CBitPane.CBitmapPaneP;
    xyPlane*:BOOLEAN;
    colorPlane*:BOOLEAN;
    listPanesN:INTEGER;
    postponeIoPane:BOOLEAN;
    postponeScreenPane:BOOLEAN;
  END;
  InOutAppP*=POINTER TO InOutApp;

VAR
  appRunning:BOOLEAN;

PROCEDURE (VAR p:InOutApp) Init*;
BEGIN
  p.Init^;
  p.xyPlane:=FALSE;
  p.xyPane:=NIL;
  p.colorPlane:=FALSE;
  p.colorPane:=NIL;
  p.ioPane:=NIL;
  p.screenPane:=NIL;
  p.paneGroup:=NIL;
  p.postponeIoPane:=FALSE;
  p.postponeScreenPane:=FALSE;
END Init;

PROCEDURE CreateApp*();
VAR
  app:InOutAppP;
BEGIN
  NEW(app);
  ASSERT(app#NIL);
  app.Init;
  AppGrp.SetApp(app);
  app.listPanesN:=0;
END CreateApp;

PROCEDURE (p:InOutAppP) AppInit*(hInstance: WD.HANDLE; 
                                lpCmdLine: WD.LPSTR;  nCmdShow: LONGINT): BOOLEAN;
BEGIN
  IF p.AppInit^(hInstance,lpCmdLine,nCmdShow) THEN
    p.SetVerTileMode();
    Process.SetBreak(TRUE);
    RETURN TRUE;
  END;  
  RETURN FALSE;
END AppInit;

PROCEDURE (p:InOutAppP) AssertThereIsPaneGroup();
BEGIN
  IF p.paneGroup=NIL THEN
    NEW(p.paneGroup);
    ASSERT(p.paneGroup#NIL);
    p.paneGroup.Init();
    IF p.Insert(p.paneGroup) THEN p.paneGroup.SetHorTileMode() END;  
  END;
END AssertThereIsPaneGroup;

PROCEDURE (p:InOutAppP) IsOnlyOneOpen():BOOLEAN;
VAR
  n:INTEGER;
BEGIN
  n:=0;
  IF p.screenPane#NIL THEN INC(n) END;
  IF p.ioPane#NIL THEN INC(n) END;
  IF p.xyPane#NIL THEN INC(n) END;
  IF p.colorPane#NIL THEN INC(n) END;
  RETURN n=1;
END IsOnlyOneOpen;

PROCEDURE (p:InOutAppP) SetAllCaptionsVisible(x:BOOLEAN);
VAR
  dummy:WD.BOOL;
BEGIN
  IF p.screenPane#NIL THEN p.screenPane.SetCaptionVisible(x) END;
  IF p.ioPane#NIL THEN p.ioPane.SetCaptionVisible(x) END;
  IF p.xyPane#NIL THEN p.xyPane.SetCaptionVisible(x) END;
  IF p.colorPane#NIL THEN p.colorPane.SetCaptionVisible(x) END;
  dummy:=WU.InvalidateRect(p.hwnd,NIL,1);
  dummy:=WU.UpdateWindow(p.hwnd);
END SetAllCaptionsVisible;

PROCEDURE (p:InOutAppP) OpenInOut*();
VAR
  res:BOOLEAN;
BEGIN
  IF p.ioPane=NIL THEN NEW(p.ioPane) END;
  ASSERT(p.ioPane#NIL);
  IF ~appRunning THEN
    p.postponeIoPane:=TRUE;
    RETURN;
  END;
  p.postponeIoPane:=FALSE;
  p.AssertThereIsPaneGroup;
  p.maxWidth:=WU.GetSystemMetrics(WU.SM_CXFULLSCREEN);
  p.maxHeight:=WU.GetSystemMetrics(WU.SM_CYFULLSCREEN);
  p.ioPane.Init();
  res:=p.paneGroup.Insert(p.ioPane);
  ASSERT(res);
  p.ioPane.SetTitle("In/Out");
  p.ioPane.SetInputFocus();
  IF p.IsOnlyOneOpen() THEN p.ioPane.SetCaptionVisible(FALSE) ELSE p.SetAllCaptionsVisible(TRUE) END;
END OpenInOut;

PROCEDURE (p:InOutAppP) OpenXYplane*();
VAR
  res:BOOLEAN;
BEGIN
  IF ~p.xyPlane THEN
    p.maxWidth:=WU.GetSystemMetrics(WU.SM_CXFULLSCREEN);
    p.maxHeight:=WU.GetSystemMetrics(WU.SM_CYFULLSCREEN);
    NEW(p.xyPane);
    ASSERT(p.xyPane#NIL);
    p.xyPane.Init();
    p.xyPane.tilePriority:=20;
    res:=p.Insert(p.xyPane);
    ASSERT(res);
    p.xyPane.SetTitle("XYplane");
    IF Panes.ApplicationFocused() & (Panes.focusedPane=NIL) THEN p.xyPane.SetInputFocus() END;
    IF p.IsOnlyOneOpen() THEN p.xyPane.SetCaptionVisible(FALSE) ELSE p.SetAllCaptionsVisible(TRUE) END;
  END;
END OpenXYplane;

PROCEDURE (p:InOutAppP) CloseXYplane*();
VAR
  dummy:LONGINT;
  focus:BOOLEAN;
BEGIN
  focus:=Panes.focusedPane=p.xyPane;
  p.Remove(p.xyPane);
  p.xyPane.ReleaseHandles();
  dummy:=WU.DestroyWindow(p.xyPane.hwnd);
  dummy:=p.xyPane.Shutdown();
  DISPOSE(p.xyPane);
  p.xyPane:=NIL;
  IF focus THEN
    IF p.screenPane#NIL THEN p.screenPane.SetInputFocus
    ELSIF p.ioPane#NIL THEN p.ioPane.SetInputFocus END;
  END;
  IF p.IsOnlyOneOpen() THEN p.SetAllCaptionsVisible(FALSE) END;
END CloseXYplane;

PROCEDURE (p:InOutAppP) OpenColorPlane*();
VAR
  res:BOOLEAN;
BEGIN
  IF ~p.colorPlane THEN
    p.maxWidth:=WU.GetSystemMetrics(WU.SM_CXFULLSCREEN);
    p.maxHeight:=WU.GetSystemMetrics(WU.SM_CYFULLSCREEN);
    NEW(p.colorPane);
    ASSERT(p.colorPane#NIL);
    p.colorPane.Init();
    p.colorPane.tilePriority:=20;
    res:=p.Insert(p.colorPane);
    ASSERT(res);
    p.colorPane.SetTitle("ColorPlane");
    IF Panes.ApplicationFocused() & (Panes.focusedPane=NIL) THEN p.colorPane.SetInputFocus() END;
    IF p.IsOnlyOneOpen() THEN p.colorPane.SetCaptionVisible(FALSE) ELSE p.SetAllCaptionsVisible(TRUE) END;
  END;
END OpenColorPlane;

PROCEDURE (p:InOutAppP) CloseColorPlane*();
VAR
  dummy:LONGINT;
  focus:BOOLEAN;
BEGIN
  focus:=Panes.focusedPane=p.colorPane;
  p.Remove(p.colorPane);
  p.colorPane.ReleaseHandles();
  dummy:=WU.DestroyWindow(p.colorPane.hwnd);
  dummy:=p.colorPane.Shutdown();
  DISPOSE(p.colorPane);
  p.colorPane:=NIL;
  IF focus THEN
    IF p.screenPane#NIL THEN p.screenPane.SetInputFocus
    ELSIF p.ioPane#NIL THEN p.ioPane.SetInputFocus() END;
  END;
  IF p.IsOnlyOneOpen() THEN p.SetAllCaptionsVisible(FALSE) END;
END CloseColorPlane;

PROCEDURE (p:InOutAppP) RemoveMenu*();
VAR
  dummy:WD.BOOL;
  rect:WD.RECT;
BEGIN
  IF p.menu#WD.NULL THEN
    dummy:=WU.SetMenu(p.hwnd,WD.NULL);
    dummy:=WU.DestroyMenu(p.menu);
    p.menu:=WD.NULL;
    dummy:=WU.GetWindowRect(p.hwnd,rect);
    dummy:=WU.MoveWindow(p.hwnd,
                        rect.left,rect.top,
                        rect.right-rect.left+1,
                        rect.bottom-rect.top+1,1);
  END;
END RemoveMenu;

PROCEDURE (p:InOutAppP) OpenDisplay*();
VAR
  res:WD.BOOL;
  rect:WD.RECT;
  done:BOOLEAN;
BEGIN
  IF p.screenPane#NIL THEN RETURN END;
  p.AssertThereIsPaneGroup;
  NEW(p.screenPane);
  ASSERT(p.screenPane#NIL);
  p.screenPane.Init();
  done:=p.paneGroup.Insert(p.screenPane);
  ASSERT(done);
  IF (p.ioPane=NIL) & ~p.xyPlane & ~p.colorPlane THEN
    p.maxWidth:=p.screenPane.maxWidth;
    p.maxHeight:=p.screenPane.maxHeight;
    IF p.menu#WD.NULL THEN p.maxHeight:=p.maxHeight+WU.GetSystemMetrics(WU.SM_CYMENU)+WU.GetSystemMetrics(WU.SM_CYBORDER) END;
    INC(p.maxWidth,2*WU.GetSystemMetrics(WU.SM_CXFIXEDFRAME));
    INC(p.maxHeight,WU.GetSystemMetrics(WU.SM_CYSIZEFRAME));
    res:=WU.GetWindowRect(p.hwnd,rect);
    res:=WU.MoveWindow(p.hwnd,rect.left,rect.top,
                      p.maxWidth+p.borderWidthX*2,
                      p.maxHeight+p.borderWidthY*2+p.captionHeight,1);
  END;
  p.screenPane.SetTitle("Display");
  p.screenPane.SetInputFocus();
  IF p.IsOnlyOneOpen() THEN p.screenPane.SetCaptionVisible(FALSE) ELSE p.SetAllCaptionsVisible(TRUE) END;
END OpenDisplay;

PROCEDURE AddListPane*(VAR p:ListPane.ListPaneP):BOOLEAN;
VAR
  app:AppGrp.AppP;
BEGIN
  app:=AppGrp.GetApp();
  WITH app:InOutAppP DO
    app.SetAllCaptionsVisible(TRUE);
    app.maxWidth:=WU.GetSystemMetrics(WU.SM_CXFULLSCREEN);
    app.maxHeight:=WU.GetSystemMetrics(WU.SM_CYFULLSCREEN);
    NEW(p);
    IF p#NIL THEN
      p.Init();
      INC(app.listPanesN);
      RETURN app.paneGroup.Insert(p);
    ELSE RETURN FALSE END;
  ELSE
    RETURN FALSE;
  END;
END AddListPane;

PROCEDURE (p:InOutAppP) AddPane*(newPane:Panes.PaneP; title:ARRAY OF CHAR):BOOLEAN;
BEGIN
  IF ~p.Insert(newPane) THEN RETURN FALSE END;
  newPane.SetTitle(title);
  IF Panes.ApplicationFocused() & (Panes.focusedPane=NIL) THEN newPane.SetInputFocus() END;
  IF p.IsOnlyOneOpen() THEN newPane.SetCaptionVisible(FALSE) ELSE p.SetAllCaptionsVisible(TRUE) END;
  RETURN TRUE;
END AddPane;

PROCEDURE RemovePane*(p:Panes.PaneP);
VAR
  dummy:WD.BOOL;
  focus:BOOLEAN;
  app:AppGrp.AppP;
BEGIN
  app:=AppGrp.GetApp();
  WITH app:InOutAppP DO
    focus:=Panes.focusedPane=p;
    app.paneGroup.Remove(p);
    p.ReleaseHandles();
    dummy:=WU.DestroyWindow(p.hwnd);
    dummy:=p.Shutdown();
    DISPOSE(p);
    IF focus THEN
      IF app.screenPane#NIL THEN app.screenPane.SetInputFocus
      ELSIF app.ioPane#NIL THEN app.ioPane.SetInputFocus END;
    END;
    DEC(app.listPanesN);
    IF app.IsOnlyOneOpen() THEN app.SetAllCaptionsVisible(FALSE) END;
  ELSE
  END;
END RemovePane;

PROCEDURE (p:InOutAppP) EndApp*():LONGINT;
BEGIN
  IF p.ioPane#NIL THEN
    p.ioPane.SetInputFocus();
    p.ioPane.ShowExitButton;
    p.ioPane.WaitForExitButton;
  END;  
  RETURN p.EndApp^();
END EndApp;

PROCEDURE EndApp*():LONGINT;
VAR
  app:AppGrp.AppP;
  res:LONGINT;
BEGIN
  app:=AppGrp.GetApp();
  res:=app.EndApp();
  res:=AppGrp.AppShutdown();
  DISPOSE(app);
  RETURN res;
END EndApp;

PROCEDURE EndAppAltF4*():LONGINT;
VAR
  app:AppGrp.AppP;
  res:LONGINT;
BEGIN
  app:=AppGrp.GetApp();
  res:=AppGrp.AppShutdown();
  DISPOSE(app);
  RETURN res;
END EndAppAltF4;

PROCEDURE RunApp*(hInstance: WD.HANDLE; 
                  lpCmdLine: WD.LPSTR;  nCmdShow: LONGINT): BOOLEAN;
VAR
  res:LONGINT; 
  app:AppGrp.AppP;
  done:BOOLEAN;
BEGIN
  IF WB.SetErrorMode(WB.SEM_NOOPENFILEERRORBOX)=0 THEN END;
  app:=AppGrp.GetApp();
  WITH app:InOutAppP DO
    Process.importantExitProc:=EndAppAltF4;
    appRunning:=TRUE;
    done:=app.AppInit(hInstance,lpCmdLine,nCmdShow);
    IF done THEN
      IF app.postponeIoPane THEN app.OpenInOut END;
      IF app.postponeScreenPane THEN app.OpenDisplay END;
    END;
    RETURN done;
  ELSE
    RETURN FALSE;
  END;
END RunApp;

PROCEDURE DirtyExitProcCall*();
BEGIN
  Process.theExitProc();
END DirtyExitProcCall;

PROCEDURE [_APICALL] DllEntryPoint*(hDLL:WD.HANDLE; 
                                    dwReason:WD.DWORD; 
                                    lpReserved:WD.LPVOID):WD.BOOL;
BEGIN
  RETURN 1;
END DllEntryPoint;

BEGIN
  appRunning:=FALSE;
END IOManage.
