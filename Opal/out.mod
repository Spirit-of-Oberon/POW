(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module offers a simple sequential output to the screen. A particular
  advantage is that the whole output is always accessible, even if it is far
  longer than one screen page.
  
  The interface of this module is call-compatible with the standard output 
  module in the Oakwood Guidelines.
  
  All output is sequential and the output area is only limited by the available 
  size of the main memory. The visible section can be selected with the help of 
  scroll bars. All new output automatically shifts the visible area to the 
  end of the output.
  ----------------------------------------------------------------------------*)

MODULE Out;

IMPORT Strings, I:=IOManage, Float, InOut, AppGrp;

VAR
  app:I.InOutAppP;
  ioPane:InOut.InOut;

PROCEDURE ^String*(VAR str-:ARRAY OF CHAR);
PROCEDURE ^Int*(i,n:LONGINT);
PROCEDURE ^Real*(x:LONGREAL; n:INTEGER);

PROCEDURE Char*(ch:CHAR);
(** The character <ch> is printed on the screen. *)
VAR
  t:ARRAY 2 OF CHAR;
BEGIN
  t[0]:=ch;
  t[1]:=0X;
  ioPane.lp.WriteStr(t);
END Char;

PROCEDURE Close*;
(** This procedure has no effect and exists only for reasons of compatibility.  *)
BEGIN
END Close;

PROCEDURE FScan(VAR t:ARRAY OF CHAR; VAR p,pOld:INTEGER);
VAR
  h:ARRAY 500 OF CHAR;
BEGIN
  WHILE (t[p]#0X) & (t[p]#'#') DO 
    IF t[p]="$" THEN t[p]:=0AX END;
    INC(p);
  END;
  Strings.Copy(t,h,pOld+1,p-pOld);
  String(h);
  pOld:=p+1;
END FScan;

PROCEDURE F*(t:ARRAY OF CHAR; x1:LONGINT);
(** This allows to easily generate formatted output of one integer value.

    A string is passed in <t> for the output of which two replacement 
    rules are valid:
    
    1. Each occurrence of the character "#" is replaced from left to right by the numbers passed in x1. 
    
    2. Each occurrence of the character "$" is replaced by CR and LF.

    Example:
    
    F2("The co-ordinates for the$center: (#,#)",45,-6);
    
    causes the output
    
    <
    
    The co-ordinates for the
    
    center: (45,-6)
    
    >
*)
VAR
  p,pOld,i:INTEGER;
BEGIN
  p:=0;
  pOld:=0;
  i:=0;
  WHILE t[p]#0X DO
    FScan(t,p,pOld);
    IF t[p]='#' THEN
      CASE i OF
        0:Int(x1,1);
      ELSE
        Char('#');
      END;  
      INC(i);
    END;
    IF t[p]#0X THEN INC(p) END;
  END;
END F;

PROCEDURE F2*(t:ARRAY OF CHAR; x1,x2:LONGINT);
(** This allows to easily generate formatted output of two integer values.

    A string is passed in <t> for the output of which two replacement 
    rules are valid:
    
    1. Each occurrence of the character "#" is replaced from left to right by the numbers passed in x1 and x2. 
    
    2. Each occurrence of the character "$" is replaced by CR and LF.

    Example:
    
    F2("The co-ordinates for the$center: (#,#)",45,-6);
    
    causes the output
    
    <
    
    The co-ordinates for the
    
    center: (45,-6)
    
    >
*)
VAR
  p,pOld,i:INTEGER;
  h:ARRAY 500 OF CHAR;
BEGIN
  p:=0;
  pOld:=0;
  i:=0;
  WHILE t[p]#0X DO
    FScan(t,p,pOld);
    IF t[p]='#' THEN
      CASE i OF
        0:Int(x1,1);
      | 1:Int(x2,1);
      ELSE
        Char('#');
      END;  
      INC(i);
    END;
    IF t[p]#0X THEN INC(p) END;
  END;
END F2;

PROCEDURE F3*(t:ARRAY OF CHAR; x1,x2,x3:LONGINT);
(** This allows to easily generate formatted output of three integer values.

    A string is passed in <t> for the output of which two replacement 
    rules are valid:
    
    1. Each occurrence of the character "#" is replaced from left to right by the numbers passed in x1, x2 and x3. 
    
    2. Each occurrence of the character "$" is replaced by CR and LF.

    Example:
    
    F2("The co-ordinates for the$center: (#,#)",45,-6);
    
    causes the output
    
    <
    
    The co-ordinates for the
    
    center: (45,-6)
    
    >
*)
VAR
  p,pOld,i:INTEGER;
  h:ARRAY 500 OF CHAR;
BEGIN
  p:=0;
  pOld:=0;
  i:=0;
  WHILE t[p]#0X DO
    FScan(t,p,pOld);
    IF t[p]='#' THEN
      CASE i OF
        0:Int(x1,1);
      | 1:Int(x2,1);
      | 2:Int(x3,1);
      ELSE
        Char('#');
      END;  
      INC(i);
    END;
    IF t[p]#0X THEN INC(p) END;
  END;
END F3;

PROCEDURE F4*(t:ARRAY OF CHAR; x1,x2,x3,x4:LONGINT);
(** This allows to easily generate formatted output of four integer values.

    A string is passed in <t> for the output of which two replacement 
    rules are valid:
    
    1. Each occurrence of the character "#" is replaced from left to right by the numbers passed in x1, x2, x3 and x4. 
    
    2. Each occurrence of the character "$" is replaced by CR and LF.

    Example:
    
    F2("The co-ordinates for the$center: (#,#)",45,-6);
    
    causes the output
    
    <
    
    The co-ordinates for the
    
    center: (45,-6)
    
    >
*)
VAR
  p,pOld,i:INTEGER;
  h:ARRAY 500 OF CHAR;
BEGIN
  p:=0;
  pOld:=0;
  i:=0;
  WHILE t[p]#0X DO
    FScan(t,p,pOld);
    IF t[p]='#' THEN
      CASE i OF
        0:Int(x1,1);
      | 1:Int(x2,1);
      | 2:Int(x3,1);
      | 3:Int(x4,1);
      ELSE
        Char('#');
      END;  
      INC(i);
    END;
    IF t[p]#0X THEN INC(p) END;
  END;
END F4;

PROCEDURE Int*(i,n:LONGINT);
(** The number contained in <i> is displayed right aligned at least <n> characters 
    wide. *)
VAR
  t:ARRAY 255 OF CHAR;
BEGIN
  Strings.Str(i,t);
  Strings.RightAlign(t,SHORT(n));
  ioPane.lp.WriteStr(t);
END Int;

PROCEDURE Ln*;
(** The output is continued at the beginning of the next line. *)
BEGIN
  ioPane.lp.WriteLn();
END Ln;

PROCEDURE LongReal*(x:LONGREAL; n:INTEGER);
(** The number contained in <x> is displayed right aligned at least <n> characters 
    wide. *)
BEGIN
  Real(x,n);
END LongReal;

PROCEDURE Open*;
(** This procedure has no effect and exists only for reasons of compatibility. 
    The output area is automatically initialized when importing the module Out. *)
BEGIN
  IF ioPane.lp.CurrentLineLength()#0 THEN Ln(); END;
END Open;

PROCEDURE Real*(x:LONGREAL; n:INTEGER);
(** The number contained in <x> is displayed right aligned at least <n> characters 
    wide. To increase consistency with respect to the modules Display and Print, 
    numbers of the type LONGREAL may also be passed. *)
VAR
  t:ARRAY 255 OF CHAR;
BEGIN
  IF n<5 THEN n:=5 END;
  IF (ABS(x)>10000) OR
     ((ABS(x)>0.001) & (ABS(x*100-ENTIER(x*100+0.5))<0.00001)) THEN
    Float.StrF(x,n-4,2,t);
  ELSE
    t[0]:="$";
  END;
  IF t[0]="$" THEN Float.StrL(x,n,t) END;
  ioPane.lp.WriteStr(t);
END Real;

PROCEDURE SetScreenUpdate*(x:BOOLEAN);
(** This procedure enables or disables screen updates. When screen updates
    are disabled, all output from procedures like Char or String is accumulated
    in the background. All pending output is written to the screen at once when
    screen update is enabled again. This allows to speed up program execution when 
    many individual calls to output functions are being used.
    
    This procedure is not included in the Oakwood Guidelines. *)
BEGIN
  ioPane.lp.SetScreenUpdate(x);
END SetScreenUpdate;

PROCEDURE String*(VAR str-:ARRAY OF CHAR);
(** The string <str> is displayed. *)
BEGIN
  ioPane.lp.WriteStr(str);
END String;

PROCEDURE Init;
VAR
  h:AppGrp.AppP;
BEGIN
  h:=AppGrp.GetApp();
  app:=h(I.InOutAppP);
  IF app.ioPane=NIL THEN app.OpenInOut() END;
  ASSERT(app.ioPane#NIL);
  ioPane:=app.ioPane;
END Init;

BEGIN
  Init;
END Out.
