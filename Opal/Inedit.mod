(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE InEdit;

IMPORT SYSTEM,Panes,ListPane,
       WD:=WinDef,WU:=WinUser,WG:=WinGDI,WC:=CommDlg,
       Utils,Strings, GH:=GlobHandles,
       WinUtils,Process,AppGrp,Volume,InBuffer;

CONST
  INPUTLINECLASSTXT="ObEditSubclass";
  INPUTLINEEXTRAWINWORD=12;
  INPUTX=140;
  INPUTW=200;
  EXITBUTTONX=30;
  EXITBUTTONW=80;
  ENDBUTTONX=360;
  ENDBUTTONW=80;
  TEXTX=130;
  INPUTCOR=4;
  MAXBUFFER=1000;

TYPE
  EditT*=RECORD (Panes.Pane)
    ctrlWnd:WD.HWND;
    txt:ARRAY 100 OF CHAR;
    acceptInput-:BOOLEAN;
    exitButton:WD.HWND;
    buttonId:LONGINT;
    endButton:WD.HWND;
    endButtonId:LONGINT;
    fontHeight:LONGINT;
    exitClicked-:BOOLEAN;
    endClicked-:BOOLEAN;
    eleTop:LONGINT;
    eleHeight:LONGINT;
    font:WD.HFONT;
    newInput*:BOOLEAN;
    buffer*:ARRAY MAXBUFFER OF CHAR;
  END;
  Edit*=POINTER TO EditT;


VAR
  oldWndProc:WU.WNDPROC;
  
(* ********************************************************** *)

PROCEDURE (VAR p:EditT) Init*;
BEGIN
  p.Init^;
  p.ctrlWnd:=WD.NULL;
  p.txt:="";
  p.acceptInput:=FALSE;
  p.exitButton:=WD.NULL;
  p.exitClicked:=FALSE;
  p.buttonId:=0;
  p.font:=WD.NULL;
  p.buffer:="";
END Init;

PROCEDURE (p:Edit) GetEditFont():WD.HFONT;
VAR
  dummyFont,font:WD.HFONT;
  hdc:WD.HDC;
  dummyl:LONGINT;
BEGIN
  hdc:=WU.GetDC(p.ctrlWnd);
  IF hdc=WD.NULL THEN RETURN WD.NULL END;
  dummyFont:=WG.GetStockObject(WG.ANSI_FIXED_FONT);
  font:=WG.SelectObject(hdc,dummyFont);
  dummyFont:=WG.SelectObject(hdc,font);
  dummyl:=WU.ReleaseDC(p.ctrlWnd,hdc);
  RETURN font;
END GetEditFont;

PROCEDURE (p:Edit) AcceptInput*(x:BOOLEAN);
VAR
  oldWnd:WD.HWND;
  dummy:WD.BOOL;
  app:AppGrp.AppP;
BEGIN
  IF p.acceptInput=x THEN RETURN END;
  p.acceptInput:=x;
  app:=AppGrp.GetApp();
  IF x THEN
    p.endClicked:=FALSE; 
    dummy:=WU.EnableWindow(p.endButton,1);
    dummy:=WU.EnableWindow(p.ctrlWnd,1);
    IF p.owner.focusMark THEN
      dummy:=WU.EnableMenuItem(app.popup,
                            Panes.AM_INPUTFROM,
                            SYSTEM.BITOR(WU.MF_BYCOMMAND,WU.MF_ENABLED));
    END;
    IF Panes.ApplicationFocused() & 
       (Panes.focusedPane=p) THEN oldWnd:=WU.SetFocus(p.ctrlWnd) END;
  ELSE
    dummy:=WU.EnableWindow(p.endButton,0);
    IF Panes.ApplicationFocused() & 
       (Panes.focusedPane=p) THEN oldWnd:=WU.SetFocus(p.hwnd) END;
    dummy:=WU.EnableWindow(p.ctrlWnd,0);
    IF p.owner.focusMark THEN
      dummy:=WU.EnableMenuItem(app.popup,
                            Panes.AM_INPUTFROM,
                            SYSTEM.BITOR(WU.MF_BYCOMMAND,WU.MF_GRAYED));
    END;
  END;
END AcceptInput;

PROCEDURE (p:Edit) InsertionInit*(top:BOOLEAN):BOOLEAN;
VAR
  res:BOOLEAN;
  style:LONGINT;
  font:WD.HFONT;
  dummy:WD.BOOL;
  dummyl:LONGINT;
  hdc:WD.HDC;
  fm:WG.TEXTMETRIC;
BEGIN
  res:=p.InsertionInit^(top);
  IF ~res THEN RETURN FALSE END;
  ASSERT(p.hwnd#WD.NULL);
  style:=SYSTEM.BITOR(WU.WS_VISIBLE,WU.WS_CHILD);
  style:=SYSTEM.BITOR(style,WU.WS_CLIPSIBLINGS);
  style:=SYSTEM.BITOR(style,WU.ES_AUTOHSCROLL);
  style:=SYSTEM.BITOR(style,WU.WS_TABSTOP);
  style:=SYSTEM.BITOR(style,WU.WS_BORDER);
  p.ctrlWnd:=WU.CreateWindowExA(0,
                               SYSTEM.ADR(INPUTLINECLASSTXT),
                               SYSTEM.ADR(""),
                               style,
                               INPUTX,p.eleTop,
                               INPUTW,p.eleHeight,
                               p.hwnd,
                               Panes.ctrlId,
                               GH.GetAppInstanceHandle(),
                               WD.NULL);
  IF p.ctrlWnd#WD.NULL THEN
    dummyl:=WU.SetWindowLongA(p.ctrlWnd,INPUTLINEEXTRAWINWORD,SYSTEM.VAL(LONGINT,p));
    dummyl:=WU.SetWindowLongA(p.ctrlWnd,INPUTLINEEXTRAWINWORD,SYSTEM.VAL(LONGINT,p));
    ASSERT(dummyl=SYSTEM.VAL(LONGINT,p));
    INC(Panes.ctrlId);
    hdc:=WU.GetDC(p.ctrlWnd);
    IF hdc#WD.NULL THEN 
      dummy:=WG.GetTextMetricsA(hdc,fm);
      p.fontHeight:=fm.tmHeight;
      dummyl:=WU.ReleaseDC(p.ctrlWnd,hdc);
      p.eleTop:=p.fontHeight DIV 2;
      p.eleHeight:=p.fontHeight+10;
      dummy:=WU.MoveWindow(p.ctrlWnd,
                           INPUTX,p.eleTop,
                           INPUTW,p.eleHeight,
                           1);
      p.corner2.y:=p.eleHeight+p.fontHeight;
      IF p.owner#NIL THEN p.owner.AdaptSize END;
    END;
    p.font:=p.GetEditFont();
  END;
  p.endButton:=WU.CreateWindowExA(0,
                                  SYSTEM.ADR("Button"),
                                  SYSTEM.ADR("End"),
                                  SYSTEM.BITOR(SYSTEM.BITOR(SYSTEM.BITOR(
                                  WU.BS_PUSHBUTTON,
                                  WU.WS_CHILD),
                                  WU.WS_VISIBLE),
                                  WU.WS_TABSTOP),
                                  ENDBUTTONX,p.eleTop,
                                  ENDBUTTONW,p.eleHeight,
                                  p.hwnd,
                                  Panes.ctrlId,
                                  GH.GetAppInstanceHandle(),
                                  WD.NULL);
  IF p.endButton#WD.NULL THEN
    p.endButtonId:=Panes.ctrlId;
    INC(Panes.ctrlId);
  END;
  p.acceptInput:=TRUE; 
  p.AcceptInput(FALSE);
  RETURN p.ctrlWnd#WD.NULL;
END InsertionInit;

PROCEDURE (p:Edit) ChangeText*(t:ARRAY OF CHAR);
VAR
  dummy:WD.BOOL;
BEGIN
  COPY(t,p.txt);
  dummy:=WU.InvalidateRect(p.hwnd,NIL,1);
END ChangeText;

PROCEDURE (p:Edit) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  dummy:WD.BOOL;
  dummyl:LONGINT;
  rect:WD.RECT;
  oldPen:WD.HPEN;
  old:WD.HFONT;
  size:WD.SIZE;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,rect);
  oldPen:=WG.SelectObject(hdc,WinUtils.BLACK_PEN);
  ASSERT(oldPen#WD.NULL);
  dummy:=WG.MoveToEx(hdc,0,rect.bottom-1,NIL);
  dummy:=WG.LineTo(hdc,rect.right+1,rect.bottom-1);
  oldPen:=WG.SelectObject(hdc,oldPen);
  ASSERT(oldPen#WD.NULL);
  IF p.txt#"" THEN
    IF p.font#WD.NULL THEN old:=WG.SelectObject(hdc,p.font) END;
    dummy:=WG.SetBkMode(hdc,WG.TRANSPARENT);
    dummy:=WG.GetTextExtentPointA(hdc,SYSTEM.ADR(p.txt),Strings.Length(p.txt),size);
    dummy:=WG.TextOutA(hdc,TEXTX-size.cx,p.eleTop+INPUTCOR,SYSTEM.ADR(p.txt),Strings.Length(p.txt));
    IF p.font#WD.NULL THEN old:=WG.SelectObject(hdc,old) END;
  END;
END Paint;

PROCEDURE (p:Edit) ClearInput*;
VAR
  dummy:WD.BOOL;
BEGIN
  p.buffer:="";
  dummy:=WU.SetWindowTextA(p.ctrlWnd,SYSTEM.ADR(""));
END ClearInput;

PROCEDURE (p:Edit) SetInput*(VAR t:ARRAY OF CHAR);
VAR
  dummy:WD.BOOL;
BEGIN
  COPY(t,p.buffer);
  dummy:=WU.SetWindowTextA(p.ctrlWnd,SYSTEM.ADR(t));
END SetInput;

PROCEDURE [_APICALL] InputHandleEvent*(hWnd: WD.HWND;
                                      message: WD.UINT;
                                      wParam: WD.WPARAM;
                                      lParam: WD.LPARAM): LONGINT;
VAR
  ph:Panes.PaneP;
  p:Edit;
  oldWnd:WD.HWND;
  copied:LONGINT;
BEGIN
  ph:=SYSTEM.VAL(Panes.PaneP,WU.GetWindowLongA(hWnd,INPUTLINEEXTRAWINWORD));
  IF ph=NIL THEN RETURN WU.CallWindowProcA(oldWndProc,hWnd,message,wParam,lParam) END;
  ASSERT(ph IS Edit);
  p:=ph(Edit);
  IF message=WU.WM_CHAR THEN
    IF wParam=0DH THEN
      copied:=WU.GetWindowTextA(p.ctrlWnd,SYSTEM.ADR(p.buffer),LEN(p.buffer)-1);
      p.newInput:=TRUE;
      RETURN 0;
    ELSE
      RETURN WU.CallWindowProcA(oldWndProc,hWnd,message,wParam,lParam);
    END;
  
  ELSIF message=WU.WM_SETFOCUS THEN
    p.ShowFocusMark(TRUE);
    IF (p.exitButton#WD.NULL) OR ~p.acceptInput THEN
      oldWnd:=WU.SetFocus(p.hwnd);
      RETURN WD.NULL;
    ELSE
      Panes.focusedPane:=p;
      p.focused:=TRUE;
      RETURN WU.CallWindowProcA(oldWndProc,hWnd,message,wParam,lParam);
    END;
    
  ELSIF message=WU.WM_KILLFOCUS THEN
    p.ShowFocusMark(FALSE);
    RETURN WU.CallWindowProcA(oldWndProc,hWnd,message,wParam,lParam);
    
  ELSE
    RETURN WU.CallWindowProcA(oldWndProc,hWnd,message,wParam,lParam);
  END;
END InputHandleEvent; 

PROCEDURE (p:Edit) RegisterClass*():BOOLEAN;
VAR
  wc: WU.WNDCLASS;
  dummy:WD.BOOL;
BEGIN
  IF ~p.RegisterClass^() THEN RETURN FALSE END;
  IF WinUtils.IsClassRegistered(GH.GetAppInstanceHandle(),INPUTLINECLASSTXT) THEN 
    RETURN TRUE;
  END;
  dummy:=WU.GetClassInfoA(WD.NULL,SYSTEM.ADR("Edit"),wc);
  oldWndProc:=wc.lpfnWndProc;
  wc.lpfnWndProc := InputHandleEvent;
  ASSERT(wc.cbWndExtra<INPUTLINEEXTRAWINWORD);
  wc.cbWndExtra:=INPUTLINEEXTRAWINWORD+4;
  wc.hInstance:=GH.GetAppInstanceHandle();
  wc.lpszClassName:= SYSTEM.ADR(INPUTLINECLASSTXT); 
  RETURN WU.RegisterClassA(wc)#0;
END RegisterClass;

PROCEDURE (p:Edit) DefWindowProc*(hwnd:WD.HWND; 
                                  message:WD.UINT;
                                  wParam:WD.WPARAM;
                                  lParam:WD.LPARAM):LONGINT;
VAR
  oldWnd:WD.HWND;
BEGIN
  IF (message=WU.WM_COMMAND) & (SYSTEM.HIWORD(wParam)=WU.BN_CLICKED) THEN
    IF SYSTEM.LOWORD(wParam)=p.buttonId THEN
      p.exitClicked:=TRUE;
      RETURN WD.NULL;
    ELSIF SYSTEM.LOWORD(wParam)=p.endButtonId THEN
      p.endClicked:=TRUE;
      RETURN WD.NULL;
    ELSE
      RETURN p.DefWindowProc^(hwnd,message,wParam,lParam);
    END;
    
  ELSIF (message=WU.WM_CHAR) & (wParam=0DH) THEN
    p.exitClicked:=TRUE;
    RETURN WD.NULL;  
  
  ELSIF message=WU.WM_SETFOCUS THEN 
    Panes.focusedPane:=p;
    IF p.exitButton#WD.NULL THEN
      p.focused:=TRUE;
      p.ShowFocusMark(TRUE);
      RETURN WD.NULL;
    ELSIF p.acceptInput THEN
      oldWnd:=WU.SetFocus(p.ctrlWnd);
      RETURN WD.NULL;
    ELSE
      RETURN p.DefWindowProc^(hwnd,message,wParam,lParam);
    END; 
  ELSE
    RETURN p.DefWindowProc^(hwnd,message,wParam,lParam);
  END;
END DefWindowProc;

PROCEDURE (p:Edit) ShowExitButton*;
VAR
  oldWnd:WD.HWND;
BEGIN
  p.ChangeText("");
  p.exitButton:=WU.CreateWindowExA(0,
                                   SYSTEM.ADR("Button"),
                                   SYSTEM.ADR("Exit"),
                                   SYSTEM.BITOR(SYSTEM.BITOR(SYSTEM.BITOR(SYSTEM.BITOR(
                                     WU.BS_PUSHBUTTON,
                                     WU.WS_CHILD),
                                     WU.WS_VISIBLE),
                                     WU.WS_TABSTOP),
                                     WU.BS_DEFPUSHBUTTON),
                                   EXITBUTTONX,p.eleTop,
                                   EXITBUTTONW,p.eleHeight,
                                   p.hwnd,
                                   Panes.ctrlId,
                                   GH.GetAppInstanceHandle(),
                                   WD.NULL);
  IF p.exitButton#WD.NULL THEN 
    oldWnd:=WU.SetFocus(p.hwnd);
    p.buttonId:=Panes.ctrlId;
    INC(Panes.ctrlId);
  END;
END ShowExitButton;

PROCEDURE (p:Edit) ChangeInputToFile*();
BEGIN
  p.owner.ChangeInputToFile;
END ChangeInputToFile;

PROCEDURE (p:Edit) SaveInputToFile*();
BEGIN
  p.owner.SaveInputToFile;
END SaveInputToFile;

PROCEDURE (p:Edit) CopyAllToClipboard*();
BEGIN
  p.owner.CopyAllToClipboard;
END CopyAllToClipboard;

PROCEDURE (p:Edit) Print*;
BEGIN
  IF p.owner#NIL THEN p.owner.Print END;
END Print;

END InEdit.
