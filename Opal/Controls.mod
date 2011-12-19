(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE Controls;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, Utils, Strings, Panes;


CONST
  ButtonClassTxt="Button";

TYPE

  PushButtonP*=POINTER TO PushButton;
  PushButton*=RECORD (Panes.Pane)
  END;


PROCEDURE (p:PushButtonP) Open*():BOOLEAN;
BEGIN
  p.CreateWindow("test",
                 0,
                 SYSTEM.BITOR(SYSTEM.BITOR(WU.WS_CHILD,WU.WS_VISIBLE),WU.BS_PUSHBUTTON),
                 ButtonClassTxt);
  RETURN(p.hwnd#WD.NULL);
END Open;

PROCEDURE (p:PushButtonP) AdaptSize*();
VAR
  rect:Panes.Rect;
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  p.CalcCurrentPosition(rect);
  dummy:=WU.MoveWindow(p.hwnd,
                     rect.upperLeft.x,
                     rect.upperLeft.y,
                     rect.Width(),
                     rect.Height(),
                     0);
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  dummy:=WU.InvalidateRect(p.hwnd,wRect,1); 
  dummy:=WU.UpdateWindow(p.hwnd); 
END AdaptSize;

END Controls.
