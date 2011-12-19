(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module provides simple, data-stream-oriented input. The source of input 
  can be from the keyboard or from a file. The input from a file is especially
  useful for the program development as input test data can be prepared and 
  saved in a file. This file is then selected as input source after each
  program start to run a complete test.
  
  The interface of this module is call-compatible with the standard stated in 
  the Oakwood Guidelines [OAK93] for a data-stream-oriented input module.
  If the input is made from a file the latter can be selected in a pop-up dialog. 
  This file is then read character by character, according to the input functions 
  that are called. As this must be a text file an input file can be created with 
  any text editor. In case of input functions like LongInt the procedure reads 
  from the file until a character is detected that does not conform to the rules 
  defined in the EBNF syntax. Leading blanks, tabulators, and CR and LF 
  characters are neglected, with the sole exception of Char.

  When the program is started the keyboard is the default input medium. With 
  the menu "Pane" it is possible to switch to a file as input source at any 
  time.
  
  The end of a keyboard input stream is indicated by pressing the "End" key. 
  When using a file as input source the end of the input stream is signalled 
  by the end of file.
  ----------------------------------------------------------------------------*)

MODULE In;

IMPORT I:=IOManage,Process,Out,InOut,AppGrp;

VAR
  Done*:BOOLEAN;
  app:I.InOutAppP;
  echo-:BOOLEAN;
  ioPane:InOut.InOut;

PROCEDURE Char*(VAR ch:CHAR);
(** The next character from the data stream is returned in <ch>. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadChar(ch,done);
  IF done & echo THEN Out.Char(ch) END;
  IF ~done THEN Done:=FALSE END;
END Char;

PROCEDURE Echo*(x:BOOLEAN);
(** With <x>=TRUE an automatic output of all input can be obtained using 
    the module Out. When the program is started this option is not active. 
    The setting can be "changed" during the program execution at any time.
    
    This procedure is not included in the Oakwood Guidelines. *)
BEGIN
  echo:=x;
END Echo;

PROCEDURE Int*(VAR i:INTEGER);
(** Reads from the input data stream according to the EBNF syntax rule
    IntConst = ["-"] (digit {digit} / digit {hexDigit} "H").
    
    The result is converted to a number and returned in <i>. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadInt(i,done);
  IF done & echo THEN Out.Int(i,1) END;
  IF ~done THEN Done:=FALSE END;
END Int;

PROCEDURE LongInt*(VAR l:LONGINT);
(** Reads from the input data stream according to the EBNF syntax rule
    IntConst = ["-"] (digit {digit} / digit {hexDigit} "H").
    
    The result is converted to a number and returned in <l>. *) 
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadLongInt(l,done);
  IF done & echo THEN Out.Int(l,1) END;
  IF ~done THEN Done:=FALSE END;
END LongInt;

PROCEDURE LongReal*(VAR x:LONGREAL);
(** Reads from the input data stream according to the EBNF syntax rule
    RealConst = ["-"] digit {digit} [ "." {digit}] ["E" ("+" / "-") digit {digit}].
    
    The result is converted to a number and returned in <x>. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadLongReal(x,done);
  IF done & echo THEN Out.Real(x,16) END;
  IF ~done THEN Done:=FALSE END;
END LongReal;

PROCEDURE Name*(VAR name:ARRAY OF CHAR);
(** Reads from the input data stream according to the EBNF syntax rule
    NameConst = nameChar {nameChar}.
    where nameChar denotes any character apart from the blank, 
    the quotation mark, CR, or LF. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadName(name,done);
  IF done & echo THEN Out.String(name) END;
  IF ~done THEN Done:=FALSE END;
END Name;

PROCEDURE Open*();
(** The input position is reset to the beginning of the data stream. The 
    variable Done is initialized with TRUE. As input from the keyboard is also 
    buffered internally, previous input can also be recalled. *)
BEGIN
  Done:=TRUE;  
  ioPane.Reset;
END Open;

PROCEDURE Prompt*(txt:ARRAY OF CHAR);
(** On executing the next input the string <txt> is displayed as a prompt instead of 
    the default text (e.g., "In.Name").
    If the input echo was switched on with Echo(TRUE), <txt> is also displayed in the 
    output via the module Out.
    
    This procedure is not included in the Oakwood Guidelines. *)
BEGIN
  IF ~Done THEN RETURN END;
  IF echo THEN Out.String(txt) END;
  ioPane.Prompt(txt);
END Prompt;

PROCEDURE Real*(VAR x:REAL);
(** Reads from the input data stream according to the EBNF syntax rule
    RealConst = ["-"] digit {digit} ["." {digit}] ["E" ("+" / "-") digit {digit}].
    
    The result is converted to a number and returned in <x>. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadReal(x,done);
  IF done & echo THEN Out.Real(x,10) END;
  IF ~done THEN Done:=FALSE END;
END Real;

PROCEDURE String*(VAR str:ARRAY OF CHAR);
(** Reads from the input data stream according to the EBNF syntax rule
    StringConst = '"' {char} '"'.
    
    If the input medium is the keyboard and no leading quotation mark is 
    detected, the procedure inserts one at the beginning and one at the 
    end automatically. *)
VAR
  done:BOOLEAN;
BEGIN
  ioPane.ReadStr(str,done);
  IF done & echo THEN Out.String(str) END;
  IF ~done THEN Done:=FALSE END;
END String;

PROCEDURE Init;
VAR
  h:AppGrp.AppP;
BEGIN
  h:=AppGrp.GetApp();
  app:=h(I.InOutAppP);
  IF app.ioPane=NIL THEN app.OpenInOut() END;
  ioPane:=app.ioPane;
  ioPane.edit.AcceptInput(FALSE);
  Done:=TRUE;
END Init;

BEGIN
  Init;
END In.
