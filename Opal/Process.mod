(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(*  22-10-1998 rel. 32/1.1 LEI some cleanups                                  *)
(**---------------------------------------------------------------------------  
  This module helps to control the execution of a program.
  ----------------------------------------------------------------------------*)

MODULE Process;

IMPORT SYSTEM, WD:=WinDef, WB:=WinBase, WU:=WinUser, WinUtils, GH:=GlobHandles;

TYPE
  ExitProc*=PROCEDURE ();

VAR
  theExitProc-:ExitProc;                     (**\HIDE*)
  importantExitProc*:PROCEDURE ():LONGINT;   (**\HIDE*)
  terminateMsgLoops-:BOOLEAN;                (**\HIDE*)
  breakEnabled-:BOOLEAN;                     (**\HIDE*)

PROCEDURE Yield*();
(** In the 16 bit Pow! version based on co-operative multi-tasking systems 
    like Windows 3.x this procedure can be used for processor sharing. During 
    time-consuming calculations other programs may be granted processor time 
    to ensure that the remaining system can still operate promptly.
    
    In the 32 bit Pow! version based on an operating system with pre-emptive 
    multi-tasking this procedure has no effect on other applications. 
    It can be used during time-consuming calculations to ensure that Windows 
    messages in the applications own message queue are being processed at 
    regular intervals to avoid that the application becomes temporarily 
    unresponsive and can not draw its screen area any more. *)
VAR
  dummy1:WD.BOOL;
  dummy2:LONGINT;
  m:WU.MSG;
  dummy:INTEGER;
BEGIN
  WHILE WU.PeekMessageA(m,0,0,0,WU.PM_REMOVE)#0 DO
    dummy1:=WU.TranslateMessage(m);
    dummy2:=WU.DispatchMessageA(m);
  END;
  IF terminateMsgLoops THEN 
    IF importantExitProc#NIL THEN dummy2:=importantExitProc() END;
    WB.ExitProcess(0);
  END;
END Yield;

PROCEDURE SetBreak*(x:BOOLEAN); 
(** The user can terminate the program execution by pressing ALT-F4 or by using 
    the menu command. If <x> is TRUE the user can exit the program at any time. 
    If FALSE the key combination ALT-F4 has no effect and the menu item "Exit" 
    is inactive and therefore appears gray. *)
VAR
  menu:WD.HMENU;
  dummy:WD.BOOL;
  buf:ARRAY 50 OF CHAR;
  i:LONGINT;
BEGIN
  breakEnabled:=x;
  menu:=WU.GetSystemMenu(GH.GetAppWindowHandle(),0);
  ASSERT(menu#WD.NULL);
  i:=WU.GetMenuStringA(menu,WU.SC_CLOSE,SYSTEM.ADR(buf),49,WU.MF_BYCOMMAND);
  IF x THEN
    dummy:=WU.ModifyMenuA(menu,WU.SC_CLOSE,WU.MF_BYCOMMAND,WU.SC_CLOSE,SYSTEM.ADR(buf));
  ELSE
    dummy:=WU.ModifyMenuA(menu,WU.SC_CLOSE,WU.MF_BYCOMMAND+WU.MF_GRAYED,WU.SC_CLOSE,SYSTEM.ADR(buf));
  END;
  ASSERT(dummy#0);
END SetBreak;

PROCEDURE SetExitProc*(proc:ExitProc); 
(** The procedure specified by proc is called before the program is terminated. 
    The procedure is not called if the program is terminated due to a system 
    error, a HALT, or an ASSERT which is not valid.
    
    If SetExitProc is called the exit procedure previously selected is overwritten. 
    When used with the function GetExitProc the previous setting can be saved 
    and a concatenation of procedures can be implemented. *)
BEGIN
  theExitProc:=proc;
END SetExitProc;

PROCEDURE GetExitProc*(VAR proc:ExitProc); 
(** The currently set exit procedure is returned in <proc>.
    A combined use of GetExitProc and SetExitProc supports a concatenation of 
    several exit procedures. Each exit procedure should call the exit procedure
    it replaced.
    If GetExitProc is called before SetExitProc the system returns an internal 
    empty exit procedure, which does not need to be called explicitly. *)
BEGIN
  proc:=theExitProc;
END GetExitProc;

PROCEDURE TerminateMsgLoops*;
(**\HIDE This is an internal function and should not be called. *)
BEGIN
  terminateMsgLoops:=TRUE;
END TerminateMsgLoops;

BEGIN
  terminateMsgLoops:=FALSE;
  theExitProc:=NIL;
  importantExitProc:=NIL;
  breakEnabled:=TRUE;
END Process.
