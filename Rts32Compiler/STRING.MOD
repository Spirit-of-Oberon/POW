(**************************************************************************
 
 MODULE Strings
 
 Copyright (C) 1992,93,94,95,96 by Bernhard Leisch
 
   Vers. 0.1   5. 3.1992
         0.2  18. 5.1993
         0.3  28. 5.1993 Val, Str, HexStr modified; ValResult added
         0.3a  3.10.1993 minor corrections, Length changed
         0.3b 28.10.1993 CopyAll removed
         0.3c 24.01.1994 better protection from invalid arguments in
                         Pos,PosChar and Copy
         0.4   9.05.1994 Changed first parameter in Pos and Insert to
                         call by value
         0.5  22.09.1994 ValResult and Val changed to avoid arithmetic
                         overflow under all circumstances
         0.5a 20.10.1994 enhanced range check in Equal
         0.6  14. 3.1995 Val and ValResult accept hex format
         0.7  23. 5.1995 Val and ValResult bug removed: input parameter
                         was modified as a side effect
         0.7b 12. 7.1995 Bug in LeftAlign removed
         
         1.0  21. 2.1996 Renamed to module String; moved to Opal++;
                         type String introduced; Params changed to String
         1.1  10. 3.1996 interface changed to make use of read only VAR parameters
                         Equal removed

 The purpose of this module is to supply elementary string manipulation
 functions.
 This module is implemented in pure Oberon-2, without importing any
 other module. This makes it portable as is to any Oberon-2 environment.
 **************************************************************************)


(**
  General information:

  All procedures should be save.
  If character arrays are being used which are to short for a result,
   the result will be truncated accordingly.
  All values concerning positions in strings start count from 1.
  (first character in a strings has position 1).
  Strings may be of arbitrary length. As not to impose a MAX(INTEGER) limit,
  LONGINT has to be used for position values.

  All procedures applying to characters instead of strings have a
  trailing "Char" in their names.
*)

MODULE String;

CONST
  ISSHORTINT*=1;
  ISINTEGER*=2;
  ISLONGINT*=3;
  ISOUTOFRANGE*=4;
  STRINGEMPTY*=5;
  STRINGILLEGAL*=6;

TYPE
  StringT*=ARRAY OF CHAR;
  String*=POINTER TO StringT;

(**
  Returns the length of a zero terminated string in characters.
*)
PROCEDURE Length*(VAR t-:StringT):LONGINT;
VAR
  i,maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  i:=0;
  WHILE (i<maxlen) & (t[i]#0X) DO INC(i) END;
  RETURN i;
END Length;


(*
  Returns position of first occurrance of character x in string t.
  If not found returns 0.
*)
PROCEDURE PosChar*(x:CHAR; VAR t-:StringT; start:LONGINT):LONGINT;
VAR
  maxl:LONGINT;
BEGIN
  IF start<1 THEN start:=0 ELSE DEC(start) END;
  maxl:=Length(t);
  WHILE (start<maxl) & (t[start]#x) DO INC(start); END;
  IF (start<maxl) & (t[start]=x) THEN RETURN start+1 ELSE RETURN 0; END;
END PosChar;

(*
  Returns position of first occurrance of string pat in string t.
  If not found returns 0.
*)
PROCEDURE Pos*(VAR pat-:StringT; VAR t-:StringT; start:LONGINT):LONGINT;
VAR
  i,j,maxl,patLen:LONGINT;
BEGIN
  IF start<1 THEN start:=0 ELSE DEC(start) END;
  maxl:=Length(t);
  patLen:=Length(pat);
  i:=start;
  j:=0;
  WHILE (j<patLen) & (i+j<maxl) DO
    IF t[i+j]=pat[j] THEN INC(j) ELSE j:=0; INC(i) END;
  END;
  IF j=patLen THEN RETURN i+1 ELSE RETURN 0 END;
END Pos;

(*PROCEDURE CopyAll*(source:StringT; VAR dest:StringT);
VAR
  i,l1,l2:LONGINT;
BEGIN
  l1:=LEN(source)-1; 
  l2:=LEN(dest)-1;
  IF l2<l1 THEN l1:=l2 END;
  i:=0;
  WHILE (i<l1) & (source[i]#0X) DO 
    dest[i]:=source[i]; 
    INC(i); 
  END;
  dest[i]:=0X;
END CopyAll;*)

PROCEDURE Copy*(VAR source-,dest:StringT; pos,n:LONGINT);
VAR
  i,j,l1,l2:LONGINT;
BEGIN
  IF pos<1 THEN
    dest[0]:=0X;
    RETURN;
  END;
  l1:=Length(source)-pos+1; 
  IF l1<1 THEN 
    dest[0]:=0X;
    RETURN;
  END;
  l2:=LEN(dest)-1;
  IF l2<l1 THEN l1:=l2 END;
  IF n<l1 THEN l1:=n END;
  i:=0;
  j:=pos-1;
  WHILE i<l1 DO 
    dest[i]:=source[j]; 
    INC(i); 
    INC(j);
  END;
  dest[i]:=0X;
END Copy;

PROCEDURE Append*(VAR dest:StringT; VAR t-:StringT);
VAR
  i,j,lSrc,lDest:LONGINT;
BEGIN
  i:=Length(dest);
  j:=0;
  lDest:=LEN(dest)-1;
  lSrc:=LEN(t);
  WHILE (i<lDest) & (j<lSrc) & (t[j]#0X) DO  
    dest[i]:=t[j];
    INC(i);
    INC(j);
  END;
  dest[i]:=0X;
END Append;

PROCEDURE AppendChar*(VAR dest:StringT; t:CHAR);
VAR
  l:LONGINT;
BEGIN
  l:=Length(dest);
  IF LEN(dest)>=l+2 THEN 
    dest[l]:=t; 
    dest[l+1]:=0X; 
  END;
END AppendChar;

(*
PROCEDURE Equal*(VAR t1,t2:StringT):BOOLEAN;
VAR
  l,i:LONGINT;
BEGIN
  i:=0;
  l:=LEN(t1);
  IF LEN(t2)<l THEN l:=LEN(t2) END;
  WHILE (i<l) & (t1[i]=t2[i]) & (t1[i]#0X) DO INC(i) END;
  RETURN (i<l) & (t1[i]=t2[i]) & (t1[i]=0X); (* line changed 20.10.94 *)
END Equal;
*)

PROCEDURE UpCaseChar*(x:CHAR):CHAR;
BEGIN
  IF (x>="a") & (x<="z") THEN x:=CHR(ORD(x)+ORD("A")-ORD("a")) 
  ELSIF x="ö" THEN x:="Ö"
  ELSIF x="ä" THEN x:="Ä"
  ELSIF x="ü" THEN x:="Ü"
  END;
  RETURN x;
END UpCaseChar;

PROCEDURE UpCase*(VAR t:StringT);
VAR
  i,l:LONGINT;
BEGIN
  i:=0;
  l:=LEN(t);
  WHILE (i<l) & (t[i]#0X) DO 
    t[i]:=UpCaseChar(t[i]);
    INC(i);
  END;
END UpCase;

PROCEDURE Delete*(VAR t:StringT; pos,n:LONGINT);
VAR
  i,l:LONGINT;
BEGIN
  l:=Length(t);
  IF (n<1) OR (pos<1) OR (pos>l) THEN RETURN END;
  IF n>l-pos+1 THEN n:=l-pos+1 END;
  FOR i:=pos-1 TO l-n DO t[i]:=t[i+n]; END;
END Delete;

PROCEDURE ReverseStringT(VAR t:StringT; n:LONGINT);
VAR
  a,b:LONGINT;
  x:CHAR;
BEGIN
  a:=0;
  b:=n-1;
  WHILE (a<b) DO
    x:=t[a];
    t[a]:=t[b];
    t[b]:=x;
    INC(a);
    DEC(b);
  END;
END ReverseStringT;

PROCEDURE RemoveTrailingSpaces*(VAR t:StringT);
VAR
  i:LONGINT;
BEGIN
  i:=Length(t)-1;
  WHILE (i>0) & (t[i]=" ") DO DEC(i) END;
  t[i+1]:=0X;
END RemoveTrailingSpaces;

PROCEDURE RemoveLeadingSpaces*(VAR t:StringT);
VAR
  i,ml:LONGINT;
BEGIN
  i:=0;
  ml:=LEN(t)-1;
  WHILE (i<ml) & (t[i]=" ") DO INC(i); END;
  IF i>0 THEN Delete(t,1,i) END;
END RemoveLeadingSpaces;

PROCEDURE Val*(t:StringT):LONGINT;
CONST
  threshDec=MAX(LONGINT) DIV 10;
  threshHex=MAX(LONGINT) DIV 16;
VAR                       
  inx,l,v,res:LONGINT;
  hex,exit,neg:BOOLEAN;
  ch:CHAR;
BEGIN
  RemoveTrailingSpaces(t);
  RemoveLeadingSpaces(t); 
  l:=Length(t);
  IF l<1 THEN RETURN MIN(LONGINT) END;
  hex:=CAP(t[l-1])="H";
  IF hex THEN
    DEC(l);
    t[l]:=0X;
    IF l<1 THEN RETURN MIN(LONGINT) END;
  END;  
  inx:=0;
  neg:=FALSE;
  res:=0;
  IF t[0]="+" THEN INC(inx) 
  ELSIF t[0]="-" THEN INC(inx); neg:=TRUE; END;
  IF t[l-1]="+" THEN DEC(l) 
  ELSIF t[l-1]="-" THEN DEC(l); neg:=TRUE; END;
  exit:=FALSE;
  IF hex THEN
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res<-threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res>threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16+v;
          INC(inx);
        END;
      END;
    END;
  ELSE
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res<-threshDec) OR ((res=-threshDec) & (v>8)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res>threshDec) OR ((res=threshDec) & (v>7)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10+v;
          INC(inx);
        END;
      END;
    END;
  END;
  IF exit THEN 
    RETURN MIN(LONGINT)
  ELSE
    RETURN res;
  END;
END Val;

PROCEDURE ValResult*(t:StringT):INTEGER;
CONST
  threshDec=MAX(LONGINT) DIV 10;
  threshHex=MAX(LONGINT) DIV 16;
  mThreshHex=MIN(LONGINT) DIV 16;
VAR                       
  inx,l,v,res:LONGINT;
  h:INTEGER;
  hex,exit,neg:BOOLEAN;
  ch:CHAR;
BEGIN
  RemoveTrailingSpaces(t);
  RemoveLeadingSpaces(t); 
  l:=Length(t);
  IF l<1 THEN RETURN STRINGEMPTY END;
  hex:=CAP(t[l-1])="H";
  IF hex THEN
    DEC(l);
    t[l]:=0X;
    IF l<1 THEN RETURN STRINGEMPTY END;
  END;  
  inx:=0;
  neg:=FALSE;
  res:=0;
  IF t[0]="+" THEN INC(inx) 
  ELSIF t[0]="-" THEN INC(inx); neg:=TRUE; END;
  IF t[l-1]="+" THEN DEC(l) 
  ELSIF t[l-1]="-" THEN DEC(l); neg:=TRUE; END;
  exit:=FALSE;
  IF hex THEN
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res<mThreshHex) OR ((res=mThreshHex) & (v>0)) THEN 
          exit:=TRUE
        ELSE
          res:=res*16-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        ch:=CAP(t[inx]);
        IF (ch>="0") & (ch<="9") THEN
          v:=ORD(ch)-48;
        ELSIF (ch>="A") & (ch<="F") THEN
          v:=ORD(ch)-65+10;
        ELSE
          v:=-1;
        END;
        IF (v<0) OR (v>15) OR (res>threshHex) THEN 
          exit:=TRUE
        ELSE
          res:=res*16+v;
          INC(inx);
        END;
      END;
    END;
  ELSE
    IF neg THEN 
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res<-threshDec) OR ((res=-threshDec) & (v>8)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10-v;
          INC(inx);
        END;
      END;
    ELSE
      WHILE (inx<l) & ~exit DO
        v:=ORD(t[inx])-48;
        IF (v<0) OR (v>9) OR (res>threshDec) OR ((res=threshDec) & (v>7)) THEN 
          exit:=TRUE
        ELSE
          res:=res*10+v;
          INC(inx);
        END;
      END;
    END;
  END;
  IF exit THEN 
    IF (v<0) OR (hex & (v>15)) OR (~hex & (v>9)) THEN RETURN STRINGILLEGAL ELSE RETURN ISOUTOFRANGE END;
  ELSE
    h:=ISLONGINT;
    IF (res>=MIN(INTEGER)) & (res<=MAX(INTEGER)) THEN DEC(h) END;
    IF (res>=MIN(SHORTINT)) & (res<=MAX(SHORTINT)) THEN DEC(h) END;
    RETURN h;
  END;
END ValResult;

PROCEDURE Str*(x:LONGINT; VAR t:StringT);
VAR
  i:LONGINT;
  maxlen:LONGINT;
  neg:BOOLEAN;
BEGIN
  maxlen:=LEN(t)-1;
  IF maxlen<1 THEN
    t[0]:=0X;
    RETURN;
  END;
  IF x=0 THEN
    t[0]:="0";
    t[1]:=0X;
  ELSE
    i:=0;
    neg:=x<0;
    IF neg THEN 
      IF x=MIN(LONGINT) THEN
        COPY("-2147483648",t);
        IF Length(t)#11 THEN
          FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
          t[maxlen]:=0X;
        END;
        RETURN;
      ELSE
        x:=-x; 
      END;
    END;
    WHILE (x#0) & (i<maxlen) DO
      t[i]:=CHR(48+x MOD 10);
      x:=x DIV 10;
      INC(i);
    END;
    IF (x#0) OR (neg & (i>=maxlen)) THEN 
      FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
      t[maxlen]:=0X;
    ELSE  
      IF neg THEN
        t[i]:="-";
        INC(i);
      END;
      t[i]:=0X;
      ReverseStringT(t,i);
    END;
  END;
END Str;   

PROCEDURE HexStr*(x:LONGINT; VAR t:StringT);
VAR
  i:LONGINT;
  digit:LONGINT;
  maxlen:LONGINT;
  neg:BOOLEAN;
BEGIN
  maxlen:=LEN(t)-1;
  IF maxlen<2 THEN
    IF maxlen=1 THEN t[0]:="$"; t[1]:=0X ELSE t[0]:=0X END;
    RETURN;
  END;
  IF x=0 THEN
    t[0]:="0";
    t[1]:="h";
    t[2]:=0X;
  ELSE
    t[0]:="h";
    i:=1;
    neg:=x<0;
    IF neg THEN 
      IF x=MIN(LONGINT) THEN
        COPY("-80000000h",t);
        IF Length(t)#10 THEN
          FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
          t[maxlen]:=0X;
        END;
        RETURN;
      ELSE
        x:=-x; 
      END;
    END;
    WHILE (x#0) & (i<maxlen) DO
      digit:=x MOD 16;
      IF digit<10 THEN t[i]:=CHR(48+digit) ELSE t[i]:=CHR(55+digit) END;
      x:=x DIV 16;
      INC(i);
    END;
    IF (x#0) OR (neg & (i>=maxlen)) THEN 
      FOR i:=0 TO maxlen-1 DO t[i]:="$" END;
      t[maxlen]:=0X;
    ELSE  
      IF neg THEN
        t[i]:="-";
        INC(i);
      END;
      t[i]:=0X;
      ReverseStringT(t,i);
    END;
  END;
END HexStr;   

PROCEDURE InsertChar*(x:CHAR; VAR t:StringT; pos:LONGINT);
VAR
  i,l:LONGINT;
BEGIN
  l:=Length(t);
  IF l+1<LEN(t) THEN
    IF pos<1 THEN pos:=1 ELSIF pos>l+1 THEN pos:=l+1 END;
    FOR i:=l TO pos-1 BY -1 DO t[i+1]:=t[i]; END;
    t[pos-1]:=x;
  END;
END InsertChar;

(*
  string source is inserted into string dest starting from position pos.
  If the dest array is not long enough to hold the result, the string
  to be inserted is truncated to a size where insertion is possible.
*)
PROCEDURE Insert*(VAR source-:StringT; VAR dest:StringT; pos:LONGINT);
VAR
  i,l,dif:LONGINT;         
BEGIN
  dif:=Length(source);
  l:=Length(dest);
  IF l+dif+1>LEN(dest) THEN dif:=LEN(dest)-l-1 END;
  IF pos<1 THEN pos:=1 ELSIF pos>l+1 THEN pos:=l+1 END;
  FOR i:=l TO pos-1 BY -1 DO dest[i+dif]:=dest[i]; END;
  FOR i:=pos-1 TO pos-2+dif DO dest[i]:=source[i+1-pos] END;
END Insert;

PROCEDURE LeftAlign*(VAR t:StringT; n:LONGINT);
VAR
  l,i:LONGINT;
  maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  IF n+1>maxlen THEN n:=maxlen-1; END;
  l:=Length(t);
  IF l<=n-1 THEN
    FOR i:=l TO n-1 DO t[i]:=" " END;
    t[n]:=0X;
  END;
END LeftAlign;

PROCEDURE RightAlign*(VAR t:StringT; n:LONGINT);
VAR
  l,i:LONGINT;
  maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  IF n+1>maxlen THEN n:=maxlen-1; END;
  l:=Length(t);
  IF l<n THEN
    t[n]:=0X;
    n:=n-l;
    FOR i:=l-1 TO 0 BY -1 DO t[i+n]:=t[i] END;
    FOR i:=0 TO n-1 DO t[i]:=" " END;
  END;
END RightAlign;


END String.
