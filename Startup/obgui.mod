(*********************************************************)
(*                                                       *)
(* *)                  MODULE ObGUI;                  (* *)
(*                                                       *)
(*********************************************************)
(* 23-07-1997: kre                                       *)
(*********************************************************)
(*                                                       *)
(* startup code for WIN32 GUI programs                   *)
(*********************************************************)

IMPORT SYSTEM,Ext:=ObGuiInt;

(* program entry point for console programs *)
PROCEDURE [_APICALL] ExeEntryPoint*;
VAR
  res: Ext.BOOL;
  cmd: Ext.LPSTR;
  mod: Ext.HMODULE;
  exitcode: LONGINT;
  startupinfo: Ext.STARTUPINFOA;
  showwindow: LONGINT;
BEGIN
  (* get module handle *)
  mod:=Ext.GetModuleHandleA(0);

  (* retrieve commands *)
  cmd:=Ext.GetCommandLineA();

  (* get requested window state *)
  Ext.GetStartupInfoA(startupinfo);
  IF SYSTEM.BITAND(startupinfo.dwFlags,LONG(LONG(Ext.STARTF_USESHOWWINDOW)))#0 THEN
     showwindow:=startupinfo.wShowWindow;
  ELSE
     showwindow:=Ext.SW_SHOWNORMAL;
  END; 
  
  (* start main program *)
  exitcode:=Ext.WinMain(mod,cmd,showwindow);

  (* terminate program *)
  Ext.ExitProcess(exitcode);
END ExeEntryPoint;

END ObGUI.
