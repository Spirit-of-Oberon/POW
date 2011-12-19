(*********************************************************)
(*                                                       *)
(* *)                  MODULE ObCon;                  (* *)
(*                                                       *)
(*********************************************************)
(* 23-07-1997: kre                                       *)
(*********************************************************)
(*                                                       *)
(* startup code for console programs                     *)
(*********************************************************)

IMPORT SYSTEM,Ext:=ObConInt;

(* program entry point for console programs *)
PROCEDURE [_APICALL] ExeEntryPoint*;
VAR
  res: Ext.BOOL;
  cmd: Ext.LPSTR;
BEGIN
  (* open console window *)
  res:=Ext.AllocConsole();

  (* retrieve commands *)
  cmd:=Ext.GetCommandLineA();

  (* start main program *)
  Ext.WinMain(cmd);

  (* remove console window *)
  res:=Ext.FreeConsole();

  (* terminate program *)
  Ext.ExitProcess(0);
END ExeEntryPoint;

END ObCon.
