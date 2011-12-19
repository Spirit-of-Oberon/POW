(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(*  07-10-1997 rel. 32/1.1 LEI  bugfix read hex in GetLongInt                 *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE InBuffer;

IMPORT WD:=WinDef,WU:=WinUser,SYSTEM,
       OOBase,Strings,Streams,Utils,File,WinUtils,Float;

CONST
  TMPLEN=100;
  ERRNONE*=0;
  ERRSYNTAX*=1;
  ERRBOUNDS*=2;
  
TYPE
  BufferT*=RECORD (OOBase.ObjectT)
    pos:LONGINT;
    n:LONGINT;
    p:POINTER TO ARRAY OF CHAR;
  END;
  Buffer*=POINTER TO BufferT;

PROCEDURE (VAR p:BufferT) InitEx*(size:LONGINT):BOOLEAN;
BEGIN
  p.pos:=0;
  p.n:=0;
  NEW(p.p,size);
  RETURN p.p#NIL;
END InitEx;

PROCEDURE (VAR p:BufferT) Append*(VAR t:ARRAY OF CHAR);
VAR
  i,size:LONGINT;
BEGIN
  i:=0;
  size:=LEN(p.p^);
  WHILE (p.n<size) & (t[i]#0X) DO 
    p.p[p.n]:=t[i];
    INC(i);
    INC(p.n);
  END;
END Append;

PROCEDURE (VAR p:BufferT) AppendChar*(ch:CHAR);
BEGIN
  IF p.n<LEN(p.p^) THEN
    p.p[p.n]:=ch;
    INC(p.n);
  END;
END AppendChar;

PROCEDURE (VAR p:BufferT) SaveFile*(fName:ARRAY OF CHAR);
VAR
  stream:Streams.AsciiStreamOut; 
  err:INTEGER;
  i:LONGINT;
  msg:ARRAY 100 OF CHAR; 
BEGIN
  stream.Open(fName);
  err:=stream.GetLastError();
  i:=0;
  WHILE (i<p.n) & (err=Streams.NOERROR) DO
    stream.Char(p.p[i]);
    INC(i);
  END;
  IF err#File.NOERROR THEN
    stream.GetLastErrorStr(msg);
    IF WU.MessageBoxA(WD.NULL,
                      SYSTEM.ADR(msg),
                      SYSTEM.ADR("Error"),
                      SYSTEM.BITOR(WU.MB_ICONEXCLAMATION,WU.MB_TASKMODAL)
                      )=0 THEN END;
  END;
  stream.Close; 
END SaveFile;

PROCEDURE (VAR p:BufferT) AppendFile*(fName:ARRAY OF CHAR);
VAR
  size:LONGINT;
  stream:Streams.AsciiStreamIn;
  ch:CHAR;
  msg:ARRAY 100 OF CHAR;
  err:INTEGER; 
BEGIN
  stream.Open(fName);
  size:=LEN(p.p^);
  err:=stream.GetLastError();
  WHILE (p.n<size) & (err=Streams.NOERROR) DO
    stream.Char(ch);
    err:=stream.GetLastError();
    IF err=Streams.NOERROR THEN
      p.p[p.n]:=ch;
      INC(p.n);
    END;
  END;
  IF err#File.EOFREACHED THEN
    IF err=Streams.NOERROR THEN
      msg:="file too long";
    ELSE
      stream.GetLastErrorStr(msg);
    END;
    IF WU.MessageBoxA(WD.NULL,
                      SYSTEM.ADR(msg),
                      SYSTEM.ADR("Error"),
                      SYSTEM.BITOR(WU.MB_ICONEXCLAMATION,WU.MB_TASKMODAL)
                      )=0 THEN END;
  END;
  stream.Close; 
END AppendFile;

PROCEDURE (VAR p:BufferT) Clear*;
BEGIN
  p.pos:=0;
  p.n:=0;
END Clear;

PROCEDURE (VAR p:BufferT) AtEnd*():BOOLEAN;
BEGIN
  RETURN p.pos>=p.n;
END AtEnd;

PROCEDURE (VAR p:BufferT) SeekEnd*();
BEGIN
  p.pos:=p.n;
END SeekEnd;

PROCEDURE (VAR p:BufferT) SeekStart*();
BEGIN
  p.pos:=0;
END SeekStart;

PROCEDURE (VAR p:BufferT) GetLeftover*(VAR t:ARRAY OF CHAR);
VAR
  i,l:LONGINT;
BEGIN
  l:=LEN(t)-1;
  i:=0;
  WHILE (i<l) & (i+p.pos<p.n) DO
    t[i]:=p.p[p.pos+i];
    INC(i);
  END;
  t[i]:=0X;
END GetLeftover;

PROCEDURE (VAR p:BufferT) GetChar*(VAR ch:CHAR; VAR done:BOOLEAN; VAR code:LONGINT);
BEGIN
  IF p.pos<p.n THEN 
    ch:=p.p[p.pos];
    INC(p.pos);
    done:=TRUE;
    code:=ERRNONE;
  ELSE
    ch:=0X;
    done:=FALSE;
    code:=ERRSYNTAX;
  END;
END GetChar;

PROCEDURE (VAR p:BufferT) PutBack;
BEGIN
  IF p.pos>0 THEN DEC(p.pos) END;
END PutBack;

PROCEDURE (VAR p:BufferT) Skip;
BEGIN
  WHILE (p.pos<p.n) & (
        (p.p[p.pos]=" ") OR 
        (p.p[p.pos]=0AX) OR   (* LF *)
        (p.p[p.pos]=0DX) OR   (* CR *)
        (p.p[p.pos]=09X)) DO  (* TAB *)
    INC(p.pos);
  END;
END Skip;

PROCEDURE (VAR p:BufferT) GetLongReal*(VAR x:LONGREAL; VAR done:BOOLEAN; VAR code:LONGINT);
VAR
  t:ARRAY TMPLEN+1 OF CHAR;
  i:INTEGER;
  ch:CHAR;
BEGIN
  x:=0;
  i:=0;
  p.Skip;
  p.GetChar(ch,done,code);
  IF done THEN
    IF ch="-" THEN
      t[i]:="-";
      INC(i);
    ELSE
      p.PutBack;
    END;
  END;
  LOOP
    p.GetChar(ch,done,code);
    IF ~done OR (ch<"0") OR (ch>"9") THEN EXIT END;
    IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
  END;
  IF done & (ch=".") THEN
    IF i<TMPLEN THEN t[i]:="."; INC(i) END;
    LOOP
      p.GetChar(ch,done,code);
      IF ~done OR (ch<"0") OR (ch>"9") THEN EXIT END;
      IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
    END;
  END;
  IF done & ((CAP(ch)="D") OR (CAP(ch)="E")) THEN
    IF i<TMPLEN THEN t[i]:=CAP(ch); INC(i) END;
    p.GetChar(ch,done,code);
    IF done THEN
      IF ch="-" THEN
        t[i]:="-";
        INC(i);
      ELSE
        p.PutBack;
      END;
    END;  
    LOOP
      p.GetChar(ch,done,code);
      IF ~done OR (ch<"0") OR (ch>"9") THEN EXIT END;
      IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
    END;
  END;
  IF done THEN p.PutBack END;
  done:=i#0;
  IF done THEN 
    t[i]:=0X;
    IF Float.ValResult(t)<=Float.ISLONGREAL THEN
      x:=Float.Val(t);
      code:=ERRNONE;
    ELSE
      x:=0;
      done:=FALSE;
      code:=ERRBOUNDS;
    END;
  ELSE
    code:=ERRSYNTAX;
  END;
END GetLongReal;

PROCEDURE (VAR p:BufferT) GetReal*(VAR x:REAL; VAR done:BOOLEAN; VAR code:LONGINT);
VAR
  l:LONGREAL;
BEGIN
  p.GetLongReal(l,done,code);
  IF done THEN
    IF (l>=MIN(REAL)) & (l<=MAX(REAL)) THEN
      x:=SHORT(l);
    ELSE
      x:=0;
      done:=FALSE;
      code:=ERRBOUNDS;
    END;
  ELSE
    x:=0;
  END;
END GetReal;

PROCEDURE (VAR p:BufferT) GetLongInt*(VAR x:LONGINT; VAR done:BOOLEAN; VAR code:LONGINT);
VAR 
  t:ARRAY TMPLEN+1 OF CHAR;
  i:LONGINT;
  hex:BOOLEAN;
  ch:CHAR;
BEGIN
  code:=ERRNONE;
  x:=0;
  i:=0;
  hex:=FALSE;
  p.Skip;
  p.GetChar(ch,done,code);
  IF done THEN
    IF ch="-" THEN
      t[i]:="-";
      INC(i);
    ELSE
      p.PutBack;
    END;
  END;  
  LOOP
    p.GetChar(ch,done,code);
    IF ~done OR (ch<"0") OR (ch>"9") THEN EXIT END;
    IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
  END;
  ch:=CAP(ch);
  IF (ch>="A") & (ch<="F") THEN
    t[i]:=ch; INC(i); (* bugfix 7.10.97 *)
    hex:=TRUE;
    LOOP
      p.GetChar(ch,done,code);
      ch:=CAP(ch);
      IF ~done OR ~(((ch>="0") & (ch<="9")) OR ((ch>="A") & (ch<="F"))) THEN EXIT END;
      IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
    END;
  END;
  IF done THEN 
    IF ch="H" THEN
      IF i<TMPLEN THEN t[i]:=ch; INC(i) END;
    ELSE
      p.PutBack;
    END;
  END;
  done:=i#0;
  IF done & hex & (ch#"H") THEN done:=FALSE END;
  IF done THEN 
    t[i]:=0X;
    IF Strings.ValResult(t)<=Strings.ISLONGINT THEN
      x:=Strings.Val(t);
      code:=ERRNONE;
    ELSE
      x:=0;
      done:=FALSE;
      code:=ERRBOUNDS;
    END;
  ELSE
    code:=ERRSYNTAX;
  END;
END GetLongInt;

PROCEDURE (VAR p:BufferT) GetInt*(VAR x:INTEGER; VAR done:BOOLEAN; VAR code:LONGINT);
VAR
  l:LONGINT;
BEGIN
  p.GetLongInt(l,done,code);
  IF done THEN
    IF (l>=MIN(INTEGER)) & (l<=MAX(INTEGER)) THEN
      x:=SHORT(l);
    ELSE
      x:=0;
      done:=FALSE;
      code:=ERRBOUNDS;
    END;
  ELSE
    x:=0;
  END;
END GetInt;

PROCEDURE (VAR p:BufferT) GetName*(VAR x:ARRAY OF CHAR; VAR done:BOOLEAN; VAR code:LONGINT);
VAR 
  i:LONGINT;
  ch,term:CHAR;
  maxlen:LONGINT;
BEGIN
  code:=ERRNONE;
  maxlen:=LEN(x)-1;
  x[0]:=0X;
  i:=0;
  p.Skip;
  LOOP
    p.GetChar(ch,done,code);
    IF ~done OR (ch=" ") OR (ch=0AX) OR (ch=0DX) OR (ch=09X) OR
        (ch="'") OR (ch='"') THEN EXIT END;
    IF i<maxlen THEN x[i]:=ch; INC(i) END;
  END;
  IF done & ((ch="'") OR (ch='"')) THEN p.PutBack END;
  x[i]:=0X;
  done:=i#0;
  IF ~done THEN code:=ERRSYNTAX END;
END GetName;

PROCEDURE (VAR p:BufferT) GetStr*(VAR x:ARRAY OF CHAR; VAR done:BOOLEAN; VAR code:LONGINT);
VAR 
  i:LONGINT;
  ch,term:CHAR;
  maxlen:LONGINT;
BEGIN
  code:=ERRNONE;
  maxlen:=LEN(x)-1;
  x[0]:=0X;
  i:=0;
  p.Skip;
  p.GetChar(term,done,code);
  IF (term#"'") & (term#'"') THEN done:=FALSE END;
  IF ~done THEN 
    IF term#0X THEN p.PutBack END;
    code:=ERRSYNTAX; 
    RETURN;
  END;
  LOOP
    p.GetChar(ch,done,code);
    IF ~done OR (ch=term) THEN EXIT END;
    IF i<maxlen THEN x[i]:=ch; INC(i) END;
  END;
  IF ~done & (ch#0X) THEN p.PutBack END;
  x[i]:=0X;
  IF ~done THEN code:=ERRSYNTAX END;
END GetStr;

END InBuffer.
