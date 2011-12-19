(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  06-20-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  The functions implemented here tend to be system dependent. Therefore the  
  module Utils is a relative of the module SYSTEM.                           
  The import of Utils is an indicator that the program using it is           
  non-portable                                                               
  ----------------------------------------------------------------------------*)

MODULE Utils;

IMPORT SYSTEM,Strings,WBas:=WinBase;

TYPE
  CastRecT=RECORD [_NOTALIGNED]
    lbyte:CHAR;
    hbyte:CHAR;
  END;

PROCEDURE BitAnd*(a,b:INTEGER):INTEGER;
(** A bitwise AND is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITAND  *)
BEGIN
  RETURN(SYSTEM.BITAND(a,b));
END BitAnd;

PROCEDURE BitXOr*(a,b:INTEGER):INTEGER;
(** A bitwise XOR is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITXOR  *)
BEGIN
  RETURN(SYSTEM.BITXOR(a,b));
END BitXOr;

PROCEDURE BitOr*(a,b:INTEGER):INTEGER;
(** A bitwise OR is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITOR  *)
BEGIN
  RETURN(SYSTEM.BITOR(a,b));
END BitOr;

PROCEDURE BitNot*(a:INTEGER):INTEGER;
(** The value of <a> is bitwise negated, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITNOT  *)
BEGIN
  RETURN(SYSTEM.BITNOT(a));
END BitNot;

PROCEDURE BitAndL*(a,b:LONGINT):LONGINT;
(** A bitwise AND is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITAND  *)
BEGIN
  RETURN(SYSTEM.BITAND(a,b));
END BitAndL;

PROCEDURE BitXOrL*(a,b:LONGINT):LONGINT;
(** A bitwise XOR is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITXOR  *)
BEGIN
  RETURN(SYSTEM.BITXOR(a,b));
END BitXOrL;

PROCEDURE BitOrL*(a,b:LONGINT):LONGINT;
(** A bitwise OR is applied to the values <a> and <b>, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITOR  *)
BEGIN
  RETURN(SYSTEM.BITOR(a,b));
END BitOrL;

PROCEDURE BitNotL*(a:LONGINT):LONGINT;
(** The value of <a> is bitwise negated, and the result returned.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.BITNOT  *)
BEGIN
  RETURN(SYSTEM.BITNOT(a));
END BitNotL;

PROCEDURE LoWord*(x:LONGINT):INTEGER;
(** The return value of LoWord is the least significant half of the four-byte 
    value <x>. 
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.LOWORD  *)
BEGIN
  RETURN(SYSTEM.LOWORD(x));
END LoWord;

PROCEDURE HiWord*(x:LONGINT):INTEGER;
(** The return value of HiWord is the most significant half of the four-byte 
    value <x>.
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.HIWORD  *)
BEGIN
  RETURN(SYSTEM.HIWORD(x));
END HiWord;

PROCEDURE LoByte*(x:INTEGER):CHAR;
(** The return value of LoByte is the least significant byte of the two-byte 
    value <x>. *)
VAR
  h:CastRecT;
BEGIN
  h:=SYSTEM.VAL(CastRecT,x);
  RETURN(h.lbyte);
END LoByte;

PROCEDURE HiByte*(x:INTEGER):CHAR;
(** The return value of HiByte is the most significant byte of the two-byte 
    value <x>. *)
VAR
  h:CastRecT;
BEGIN
  h:=SYSTEM.VAL(CastRecT,x);
  RETURN(h.hbyte);
END HiByte;

PROCEDURE MakeLong*(hi,lo:INTEGER):LONGINT;
(** The two-byte values <hi> and <lo> are combined to a four-byte value by 
    concatenation and returned as result of the function. <hi> becomes the most 
    significant and <lo> the least significant part of the result. 
    
    The module SYSTEM now supports an equivalent function which is resolved 
    in-line and therefore does not generate the overhead of a procedure call:
    SYSTEM.MAKELONG  *)
BEGIN
  RETURN(SYSTEM.MAKELONG(hi,lo));
END MakeLong;

PROCEDURE MakeWord*(hi,lo:CHAR):INTEGER;
(** The one-byte values <hi> and <lo> are combined to a two-byte value by 
    concatenation and returned as result of the function. <hi> becomes the 
    most significant and <lo> the least significant part of the result. *)
VAR
  h:CastRecT;
BEGIN
  h.hbyte:=hi;
  h.lbyte:=lo;
  RETURN(SYSTEM.VAL(INTEGER,h));
END MakeWord;

PROCEDURE GetDate*(VAR day,month,year,dayOfWeek:INTEGER);
(** The current date is read from the system's real-time clock and returned 
    in the parameters <day>, <month>, <year>, and <dayOfWeek>.
    
    The year is stated including the century.
    In addition, in <dayOfWeek> a value between 1 and 7 is returned, 
    where 1 denotes Monday and 7 Sunday. *)
VAR
  systemTime:WBas.SYSTEMTIME;
BEGIN
  WBas.GetLocalTime(systemTime);
  dayOfWeek:=systemTime.wDayOfWeek;
  year:=systemTime.wYear;
  month:=systemTime.wMonth;
  day:=systemTime.wDay;
END GetDate;

PROCEDURE GetTime*(VAR sec,min,hour:INTEGER);
(** The current time is read from the system's real-time clock and returned 
    in the parameters <sec>, <min>, and <hour>. *)
VAR
  systemTime:WBas.SYSTEMTIME;
BEGIN
  WBas.GetLocalTime(systemTime);
  sec:=systemTime.wSecond;
  min:=systemTime.wMinute;
  hour:=systemTime.wHour;
END GetTime;

PROCEDURE GetDateStr*(VAR t:ARRAY OF CHAR);
(** The current date is read from the system's real-time clock and returned 
    as a string in <t>. The result is 10 characters long and has the format 
    "dd.mm.yyyy". If <t> cannot hold a string of 10 characters length, a 
    completely empty string is returned.*)
VAR
  txt:ARRAY 10 OF CHAR;
  day,month,year,d:INTEGER;
BEGIN
  IF LEN(t)<11 THEN t[0]:=0X; RETURN END;
  GetDate(day,month,year,d);
  Strings.Str(day,t);
  Strings.RightAlign(t,2);
  Strings.AppendChar(t,".");
  Strings.Str(month,txt);
  Strings.RightAlign(txt,2);
  Strings.Append(t,txt);
  Strings.AppendChar(t,".");
  Strings.Str(year,txt);
  Strings.RightAlign(txt,4);
  Strings.Append(t,txt);
END GetDateStr;

PROCEDURE GetTimeStr*(VAR t:ARRAY OF CHAR);
(** The current time is read from the system's real-time clock and 
    returned as a string in <t>. The result is 8 characters long and has 
    the format "HH.MM.SS". If <t> cannot hold a string of 8 characters 
    length, a completely empty string is returned. *)
VAR
  txt:ARRAY 10 OF CHAR;
  hour,min,sec:INTEGER;
BEGIN
  IF LEN(t)<9 THEN t[0]:=0X; RETURN END;
  GetTime(sec,min,hour);
  Strings.Str(hour,t);
  Strings.RightAlign(t,2);
  Strings.AppendChar(t,":");
  Strings.Str(min,txt);
  Strings.RightAlign(txt,2);
  Strings.Append(t,txt);
  Strings.AppendChar(t,":");
  Strings.Str(sec,txt);
  Strings.RightAlign(txt,2);
  Strings.Append(t,txt);
END GetTimeStr;

END Utils.
