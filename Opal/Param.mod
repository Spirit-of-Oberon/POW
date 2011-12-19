(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  06-25-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module offers access to the command line which was used to start the
  program. It is possible to access the command line as a whole or only
  single parameters. It is assumed that the single parameters of the command
  line are separated either by blanks, commas or both.
  ----------------------------------------------------------------------------*)

MODULE Param;

IMPORT S:=Strings;

CONST
  MAXPARAMLEN*=300; (** maximum length of the entire parameter string *)
  MAXSTR*=30;       (** maximum number of different parts of the parameter string *)

VAR
  currentCmd:ARRAY MAXPARAMLEN OF CHAR;
  strList:ARRAY MAXSTR OF POINTER TO ARRAY OF CHAR;   
  strN:INTEGER;             

PROCEDURE CompleteStr*(VAR cmdLine:ARRAY OF CHAR);
(** The complete command line is copied to the parameter <cmdLine>. *)
BEGIN
  COPY(currentCmd,cmdLine);
END CompleteStr;
  
PROCEDURE Count*():INTEGER;
(** The return value of the function is the number of parameters in the command 
    line that are separated by blanks or commas. *)
BEGIN
  RETURN strN;
END Count;

PROCEDURE Parse*(VAR line-:ARRAY OF CHAR);
(** The string passed in <line> is broken up into individual arguments and replaces
    the original command line. Following calls to the function Str return the
    the individual elements found in <line>. *)
VAR
  i,start,end:LONGINT;
  t:ARRAY MAXPARAMLEN OF CHAR;
BEGIN
  COPY(line,currentCmd);
  FOR i:=0 TO strN-1 DO DISPOSE(strList[i]) END;
  FOR i:=0 TO MAXSTR-1 DO strList[i]:=NIL END;
  strN:=0;
  i:=0;
  WHILE (line[i]#0X) & (strN<MAXSTR) DO
    WHILE (line[i]=" ") & (line[i]#0X) DO INC(i) END;
    IF line[i]=0X THEN RETURN END;
    start:=i;
    WHILE (line[i]#0X) & (line[i]#",") & (line[i]#" ") & (line[i]#'"') & (line[i]#"'") DO INC(i) END;
    IF line[i]="'" THEN
      INC(i);
      WHILE (line[i]#0X) & (line[i]#"'") DO INC(i) END;
    ELSIF line[i]='"' THEN
      INC(i);
      WHILE (line[i]#0X) & (line[i]#'"') DO INC(i) END;
    END;
    end:=i-1;
    IF (line[start]="'") OR (line[start]='"') THEN
      INC(start);
      IF (line[i]="'") OR (line[i]='"') THEN INC(i) END;
    END;
    NEW(strList[strN],end-start+2); 
    S.Copy(line,strList[strN]^,start+1,end-start+1);
    WHILE line[i]=" " DO INC(i) END;
    IF line[i]="," THEN INC(i) END;
    INC(strN);
  END;
END Parse;

PROCEDURE Str*(paramNr:INTEGER; VAR paramTxt:ARRAY OF CHAR);
(** A single parameter of the command line is copied to <paramTxt>. The parameter 
    is selected by <paramNr>, starting with one. If a non-existent parameter is 
    selected an empty string is returned.
    
    Parameters containing commas, or even blanks, can be stated between 
    quotation marks. The quotation marks are removed automatically. *)
BEGIN
  IF (paramNr<1) OR (paramNr>strN) THEN
    paramTxt[0]:=0X;
  ELSE
    IF strList[paramNr-1]#NIL THEN COPY(strList[paramNr-1]^,paramTxt) ELSE paramTxt[0]:=0X END;
  END;
END Str;

BEGIN
  strN:=0;
END Param.
