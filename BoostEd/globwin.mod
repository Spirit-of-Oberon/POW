(******************************************************************************
 *  Module GlobWin
 *  
 *  This module provides global access to some commonly used functions
 *  which are closely tied to the Windows API.
 ******************************************************************************)

MODULE GlobWin;

IMPORT SYSTEM,
       WD:=WinDef, WB:=WinBase, WU:=WinUser, WN:=WinNT,
       Strings;

CONST
  HELPFILENAME="BoostEd.hlp";
  
VAR
  hInstance* : WD.HINSTANCE;  

PROCEDURE DisplayError*(title: ARRAY OF CHAR; msg: ARRAY OF CHAR);
(* Show a pop-up window with an error message.
   The procedure returns after the user has acknowledged 
   the error message. *)
VAR 
  r: WD.BOOL;
BEGIN
  r := WU.MessageBoxA(WD.NULL, SYSTEM.ADR(msg), SYSTEM.ADR(title), WU.MB_OK);
END DisplayError;


PROCEDURE ShowHelp*(hEdit:WD.HWND);
VAR 
  ret,i     : LONGINT;
  tmp,help  : ARRAY 128 OF CHAR;
  dmyi      : LONGINT;
BEGIN
  ret:=WB.GetModuleFileNameA(hInstance,SYSTEM.ADR(help),128);
  IF ret=0 THEN DisplayError("Error","Problems getting helpfile");
  ELSE
    i:=ret-1;
    WHILE (i>=0) & (help[i]#"\") DO
      help[i]:=0X;
      DEC(i);
    END;
    Strings.Append(help,HELPFILENAME);
       
    dmyi:=WU.WinHelpA(hEdit, SYSTEM.ADR(help), WU.HELP_CONTENTS,0);
    IF dmyi=0 THEN 
      tmp:="The helpfile must reside at ";
      Strings.Append(tmp,help);
      DisplayError("HELP",tmp);
    END; 
  END;
END ShowHelp;
  
PROCEDURE Beep*;
VAR
  res:WD.BOOL;
BEGIN
  res:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
END Beep;           

PROCEDURE RGB*(r,g,b:INTEGER):LONGINT;
BEGIN
  RETURN (b*256+g)*256+r;
END RGB;

END GlobWin.
