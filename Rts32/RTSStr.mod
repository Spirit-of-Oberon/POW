(** Subset of string functions used by Run-Time-System *)
MODULE RTSStr;

TYPE
  StringT*=ARRAY OF CHAR;
  String*=POINTER TO StringT;

PROCEDURE Length*(VAR t-:StringT):LONGINT;
(** The return value of the function is the number of characters of the string <t>. *)
VAR
  i,maxlen:LONGINT;
BEGIN
  maxlen:=LEN(t);
  i:=0;
  WHILE (i<maxlen) & (t[i]#0X) DO INC(i) END;
  RETURN i;
END Length;


PROCEDURE Append*(VAR dest:StringT; VAR src-:StringT);
(** The string <src> is appended to the string <dest>. *)
VAR
  i,j,lSrc,lDest:LONGINT;
BEGIN
  i:=Length(dest);
  j:=0;
  lDest:=LEN(dest)-1;
  lSrc:=LEN(src);
  WHILE (i<lDest) & (j<lSrc) & (src[j]#0X) DO  
    dest[i]:=src[j];
    INC(i);
    INC(j);
  END;
  dest[i]:=0X;
END Append;

PROCEDURE AppendChar*(VAR dest:StringT; ch:CHAR);
(** The character <ch> is appended to the string <dest>. *)
VAR
  l:LONGINT;
BEGIN
  l:=Length(dest);
  IF LEN(dest)>=l+2 THEN 
    dest[l]:=ch; 
    dest[l+1]:=0X; 
  END;
END AppendChar;

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

PROCEDURE Str*(x:LONGINT; VAR t:StringT);
(** The number <x> is converted to a string and the result is stored in <t>.
    If <t> is not large enough to hold all characters of the number, 
    <t> is filled with "$" characters. *)
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
(** The number <x> is converted to a string of hexadecimal format and the result is stored 
    in <t>. At the end of the string an "h" is appended to indicate the hexadecimal 
    representation of the number.
    
    If <t> is not large enough to hold all characters of the number, <t> is filled with "$" 
    characters. Example: 0 becomes "0h", 15 becomes "Fh", 16 becomes "10h". *)
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

END RTSStr.
