(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE Streams;

IMPORT OOBase,SYSTEM,File,Strings,Float;

CONST
  NOERROR*=File.NOERROR;
  STREAMNOTOPEN*=200H;
  ILLEGALPARAMETER*=201H;
  POSITIONOUTOFRANGE*=202H;
  OUTOFMEMORY*=203H;
  DATATYPEMISMATCH*=204H;
  
  INITIALBUFFERSIZE=10000;
  MINBUFFERSIZE=5;
  DELIMITER=09X; (* Trennzeichen f. Ascii-Streams *)

TYPE
  Stream*=RECORD (OOBase.ObjectT)
    handle:File.Handle;
    open:BOOLEAN;
    resCode1,resCode2:INTEGER;
    buffer:POINTER TO ARRAY OF CHAR;
    bufSize:LONGINT;     (* buffer size *)
    size:LONGINT;        (* size of file *)
    pos:LONGINT;         (* position of file pointer *)
    dirtyStart,dirtyEnd:LONGINT; (* start and end of dirty buffer area *)
    bufStart:LONGINT;    (* file position of buffer *)
    bufContents:LONGINT; (* amount of data in buffer *)
  END;
  StreamP*=POINTER TO Stream;

  OneWayStream*=RECORD (Stream)
  END;
  OneWayStreamP*=POINTER TO OneWayStream;

  TwoWayStream*=RECORD (Stream)
  END;
  TwoWayStreamP*=POINTER TO TwoWayStream;

  AsciiStreamIn*=RECORD (OneWayStream)
  END;
  AsciiStreamInP*=POINTER TO AsciiStreamIn;

  AsciiStreamOut*=RECORD (OneWayStream)
  END;
  AsciiStreamOutP*=POINTER TO AsciiStreamOut;

  BinaryStreamIn*=RECORD (OneWayStream)
  END;
  BinaryStreamInP*=POINTER TO BinaryStreamIn;

  BinaryStreamOut*=RECORD (OneWayStream)
  END;
  BinaryStreamOutP*=POINTER TO BinaryStreamOut;

  AsciiStream*=RECORD (TwoWayStream)
  END;
  AsciiStreamP*=POINTER TO AsciiStream;

  BinaryStream*=RECORD (TwoWayStream)
  END;
  BinaryStreamP*=POINTER TO BinaryStream;

(* ********************************************************************** *)

PROCEDURE (VAR stream:Stream) GetLastError*():INTEGER;
VAR
  res:INTEGER;
BEGIN
  res:=stream.resCode1;
  stream.resCode1:=NOERROR;
  RETURN res;
END GetLastError;

PROCEDURE (VAR stream:Stream) GetLastErrorStr*(VAR t:ARRAY OF CHAR);
BEGIN
  File.GetErrorMessage(stream.resCode2,t);
  stream.resCode2:=NOERROR;
END GetLastErrorStr;

PROCEDURE (VAR stream:Stream) RestOfOpen;
VAR
  res:INTEGER;
BEGIN
  stream.resCode2:=stream.resCode1;
  stream.open:=stream.resCode1=NOERROR;
  IF stream.open THEN
    stream.bufSize:=INITIALBUFFERSIZE;
    stream.buffer:=NIL;
    WHILE (stream.bufSize>MINBUFFERSIZE) & (stream.buffer=NIL) DO
      NEW(stream.buffer,stream.bufSize);
      IF stream.buffer=NIL THEN stream.bufSize:=stream.bufSize DIV 2 END;
    END;
    IF stream.buffer=NIL THEN 
      File.Close(stream.handle);
      stream.resCode1:=OUTOFMEMORY;
      stream.resCode2:=stream.resCode1;
      RETURN;
    END;  
  ELSE
    stream.buffer:=NIL;
    stream.bufSize:=0;
    RETURN;
  END;
  stream.bufStart:=0;
  stream.bufContents:=0;
  stream.dirtyStart:=stream.bufContents;
  stream.dirtyEnd:=-1;
  File.Size(stream.handle,stream.size,res);
  stream.pos:=0;
END RestOfOpen;

PROCEDURE (VAR stream:Stream) Open*(name:ARRAY OF CHAR);
BEGIN
  File.Open(name,TRUE,File.DENYALL,File.READWRITE,stream.handle,stream.resCode1);
  stream.RestOfOpen;
END Open;

PROCEDURE (VAR stream:Stream) SetPos*(bytePos:LONGINT);
BEGIN
  IF stream.open THEN
    stream.pos:=bytePos;
    IF stream.pos>stream.size THEN (* !!!!!!!!!!!!!!!!!!!! *) END;
    IF stream.pos<0 THEN
      stream.resCode1:=POSITIONOUTOFRANGE;
      stream.resCode2:=stream.resCode1;
      stream.pos:=0;
    END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
  END;
END SetPos;

PROCEDURE (VAR stream:Stream) MovePos*(relPos:LONGINT);
BEGIN
  IF stream.open THEN
    stream.pos:=stream.pos+relPos;
    IF stream.pos>stream.size THEN (* !!!!!!!!!!!!!!!!!!!! *) END;
    IF stream.pos<0 THEN
      stream.resCode1:=POSITIONOUTOFRANGE;
      stream.resCode2:=stream.resCode1;
      stream.pos:=0;
    END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
  END;
END MovePos;

PROCEDURE (VAR stream:Stream) GetPos*():LONGINT;
BEGIN
  IF stream.open THEN
    RETURN stream.pos;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
    RETURN 0;
  END;
END GetPos;

PROCEDURE (VAR stream:Stream) AtEnd*():BOOLEAN;
BEGIN
  IF stream.open THEN
    RETURN stream.pos=stream.size;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
    RETURN TRUE;
  END;
END AtEnd;

PROCEDURE (VAR stream:Stream) BufferWriteBack;
TYPE
  H=POINTER TO ARRAY [_NOTALIGNED] INITIALBUFFERSIZE OF CHAR;
VAR
  n:LONGINT;
  res:INTEGER;
  h:H;
BEGIN
  n:=stream.dirtyEnd-stream.dirtyStart+1;
  IF n>0 THEN
    ASSERT(stream.dirtyStart>=0);
    ASSERT(stream.dirtyStart<LEN(stream.buffer^));
    h:=SYSTEM.VAL(H,SYSTEM.ADR(stream.buffer[stream.dirtyStart]));
    File.Seek(stream.handle,stream.bufStart,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    File.WriteBlock(stream.handle,h^,n,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
  END;
  stream.dirtyStart:=stream.bufSize;
  stream.dirtyEnd:=-1;
END BufferWriteBack;

PROCEDURE (VAR stream:Stream) Close*;
VAR
  res:INTEGER;
BEGIN
  IF stream.open THEN
    stream.BufferWriteBack();
    stream.open:=FALSE;
    IF stream.buffer#NIL THEN DISPOSE(stream.buffer); stream.buffer:=NIL END;
    File.Close(stream.handle);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
  END;
END Close;

PROCEDURE (VAR stream:Stream) Size*():LONGINT;
VAR
  s1,s2:LONGINT;
  res:INTEGER;
BEGIN
  IF stream.open THEN
    File.Size(stream.handle,s1,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    s2:=stream.bufStart+stream.bufContents;
    IF s1>s2 THEN RETURN s1 ELSE RETURN s2 END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
    RETURN 0;
  END;
END Size;

PROCEDURE (VAR stream:Stream) PrepareBufferReadAccess(size:LONGINT; VAR bufInx,bufDataSize:LONGINT);
VAR
  bufSize,overlap,read:LONGINT;
  res:INTEGER;
BEGIN
  bufInx:=stream.pos-stream.bufStart;
  IF size>stream.bufSize THEN bufSize:=stream.bufSize ELSE bufSize:=size END;
  IF (bufInx>=0) & (stream.bufContents-bufInx>=bufSize) THEN
    bufDataSize:=bufSize;
    RETURN;
  ELSIF bufInx<0 THEN
    overlap:=stream.bufSize+bufInx;
    stream.BufferWriteBack;
    IF overlap>0 THEN 
      SYSTEM.MOVE(SYSTEM.ADR(stream.buffer[0]),SYSTEM.ADR(stream.buffer[stream.bufSize-overlap]),overlap);
      File.Seek(stream.handle,stream.pos,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize-overlap,read,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      stream.bufContents:=stream.bufContents+stream.bufSize-overlap;
      IF stream.bufContents>stream.bufSize THEN stream.bufContents:=stream.bufSize END;
    ELSE
      File.Seek(stream.handle,stream.pos,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize,stream.bufContents,res);
      IF (stream.bufContents>0) & (res=File.EOFREACHED) THEN res:=File.NOERROR END;
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    END;
  ELSE  
    stream.BufferWriteBack;
    File.Seek(stream.handle,stream.pos,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize,stream.bufContents,res);
    IF (stream.bufContents>0) & (res=File.EOFREACHED) THEN res:=File.NOERROR END;
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
  END;
  IF stream.bufContents<bufSize THEN bufDataSize:=stream.bufContents ELSE bufDataSize:=bufSize END;
  stream.bufStart:=stream.pos;
  bufInx:=0;
END PrepareBufferReadAccess;

PROCEDURE (VAR stream:Stream) PrepareBufferWriteAccess(size:LONGINT; VAR bufInx,bufSize:LONGINT);
VAR
  overlap,read:LONGINT;
  res:INTEGER;
BEGIN
  bufInx:=stream.pos-stream.bufStart;
  IF size>stream.bufSize THEN bufSize:=stream.bufSize ELSE bufSize:=size END;
  IF (bufInx>=0) & (stream.bufSize-bufInx>=bufSize) THEN
    IF stream.bufContents<bufInx+bufSize THEN stream.bufContents:=bufInx+bufSize END;
  ELSIF bufInx<0 THEN
    overlap:=stream.bufSize+bufInx;
    stream.BufferWriteBack;
    IF overlap>0 THEN 
      SYSTEM.MOVE(SYSTEM.ADR(stream.buffer[0]),SYSTEM.ADR(stream.buffer[stream.bufSize-overlap]),overlap);
      File.Seek(stream.handle,stream.pos,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize-overlap,read,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      stream.bufContents:=stream.bufContents+stream.bufSize-overlap;
      IF stream.bufContents>stream.bufSize THEN stream.bufContents:=stream.bufSize END;
    ELSE
      File.Seek(stream.handle,stream.pos,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
      File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize,stream.bufContents,res);
      IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    END;
    stream.bufStart:=stream.pos;
    IF stream.bufContents<bufInx+bufSize THEN stream.bufContents:=bufInx+bufSize END;
    bufInx:=0;
  ELSE  
    stream.BufferWriteBack;
    File.Seek(stream.handle,stream.pos,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    File.ReadBlock(stream.handle,stream.buffer^,stream.bufSize,stream.bufContents,res);
    IF res#NOERROR THEN stream.resCode1:=res; stream.resCode2:=res END;
    stream.bufStart:=stream.pos;
    IF stream.bufContents<bufInx+bufSize THEN stream.bufContents:=bufInx+bufSize END;
    bufInx:=0;
  END;
END PrepareBufferWriteAccess;

PROCEDURE (VAR stream:Stream) ReadChar(VAR x:CHAR);
VAR
  inx,size:LONGINT;
BEGIN
  IF stream.open THEN
    IF stream.AtEnd() THEN
      stream.resCode1:=File.EOFREACHED;
      stream.resCode2:=File.EOFREACHED;
    ELSE 
      stream.PrepareBufferReadAccess(1,inx,size);
      x:=stream.buffer[inx];
      INC(stream.pos);
    END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
    x:=0X;
  END;
END ReadChar;

PROCEDURE (VAR stream:Stream) WriteChar(x:CHAR);
VAR
  inx,size:LONGINT;
BEGIN
  IF stream.open THEN
    stream.PrepareBufferWriteAccess(1,inx,size);
    stream.buffer[inx]:=x;
    IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
    IF stream.dirtyEnd<inx THEN stream.dirtyEnd:=inx END;
    INC(stream.pos);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
    x:=0X;
  END;
END WriteChar;

PROCEDURE (VAR stream:Stream) WriteStrBody(VAR t:ARRAY OF CHAR);
VAR
  l,i,inx,end,size:LONGINT;
BEGIN
  l:=Strings.Length(t);
  i:=0;
  WHILE (l>0) DO
    stream.PrepareBufferWriteAccess(l,inx,size);
    INC(stream.pos,size);
    l:=l-size;
    end:=inx+size-1;
    IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
    IF stream.dirtyEnd<end THEN stream.dirtyEnd:=end END;
    WHILE inx<=end DO
      stream.buffer[inx]:=t[i];
      INC(i);
      INC(inx);
    END;  
  END;    
END WriteStrBody;

PROCEDURE (VAR stream:Stream) WriteStrBodyPart(VAR t:ARRAY OF CHAR; start,len:LONGINT);
VAR
  l,i,inx,end,size:LONGINT;
BEGIN
  l:=len;
  i:=start-1;
  WHILE (l>0) DO
    stream.PrepareBufferWriteAccess(l,inx,size);
    INC(stream.pos,size);
    l:=l-size;
    end:=inx+size-1;
    IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
    IF stream.dirtyEnd<end THEN stream.dirtyEnd:=end END;
    WHILE inx<=end DO
      stream.buffer[inx]:=t[i];
      INC(i);
      INC(inx);
    END;  
  END;    
END WriteStrBodyPart;

PROCEDURE (VAR stream:Stream) ReadStrBody(tLen:LONGINT; VAR t:ARRAY OF CHAR);
VAR
  l,i,inx,end,size:LONGINT;
BEGIN
  l:=tLen;
  IF l>LEN(t)-1 THEN l:=LEN(t)-1 END;
  t[l]:=0X;
  tLen:=tLen-l;
  i:=0;
  WHILE (l>0) DO
    stream.PrepareBufferReadAccess(l,inx,size);
    INC(stream.pos,size);
    l:=l-size;
    end:=inx+size-1;
    IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
    IF stream.dirtyEnd<end THEN stream.dirtyEnd:=end END;
    WHILE inx<=end DO
      t[i]:=stream.buffer[inx];
      INC(i);
      INC(inx);
    END;  
  END;
  INC(stream.pos,tLen);
END ReadStrBody;

PROCEDURE (VAR stream:Stream) WriteBlock(VAR a:ARRAY OF SYSTEM.BYTE);
VAR
  l,i,inx,end,size:LONGINT;
BEGIN
  IF stream.open THEN
    l:=LEN(a);
    i:=0;
    WHILE (l>0) DO
      stream.PrepareBufferWriteAccess(l,inx,size);
      INC(stream.pos,size);
      l:=l-size;
      end:=inx+size-1;
      IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
      IF stream.dirtyEnd<end THEN stream.dirtyEnd:=end END;
      WHILE inx<=end DO
        stream.buffer[inx]:=SYSTEM.VAL(CHAR,a[i]);
        INC(i);
        INC(inx);
      END;  
    END;    
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteBlock;

PROCEDURE (VAR stream:Stream) ReadBlock(VAR a:ARRAY OF SYSTEM.BYTE);
VAR
  l,i,inx,end,size:LONGINT;
BEGIN
  IF stream.open THEN
    l:=LEN(a);
    i:=0;
    WHILE (l>0) DO
      stream.PrepareBufferReadAccess(l,inx,size);
      INC(stream.pos,size);
      l:=l-size;
      end:=inx+size-1;
      IF stream.dirtyStart>inx THEN stream.dirtyStart:=inx END;
      IF stream.dirtyEnd<end THEN stream.dirtyEnd:=end END;
      WHILE inx<=end DO
        a[i]:=stream.buffer[inx];
        INC(i);
        INC(inx);
      END;  
    END;    
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END ReadBlock;

(* **************************************************************** *)

PROCEDURE (VAR stream:TwoWayStream) ReadChar*(VAR x:CHAR);
BEGIN
  stream.ReadChar^(x);
END ReadChar;

PROCEDURE (VAR stream:TwoWayStream) WriteChar*(x:CHAR);
BEGIN
  stream.WriteChar^(x);
END WriteChar;

PROCEDURE (VAR stream:TwoWayStream) WriteLongint*(x:LONGINT);
BEGIN
END WriteLongint;

PROCEDURE (VAR stream:TwoWayStream) ReadLongint*(VAR x:LONGINT);
BEGIN
END ReadLongint;

PROCEDURE (VAR stream:TwoWayStream) WriteInt*(x:INTEGER);
BEGIN
END WriteInt;

PROCEDURE (VAR stream:TwoWayStream) ReadInt*(VAR x:INTEGER);
BEGIN
END ReadInt;

PROCEDURE (VAR stream:TwoWayStream) WriteShortint*(x:SHORTINT);
BEGIN
END WriteShortint;

PROCEDURE (VAR stream:TwoWayStream) ReadShortint*(VAR x:SHORTINT);
BEGIN
END ReadShortint;

PROCEDURE (VAR stream:TwoWayStream) WriteReal*(x:REAL);
BEGIN
END WriteReal;

PROCEDURE (VAR stream:TwoWayStream) ReadReal*(VAR x:REAL);
BEGIN
END ReadReal;

PROCEDURE (VAR stream:TwoWayStream) WriteLongreal*(x:LONGREAL);
BEGIN
END WriteLongreal;

PROCEDURE (VAR stream:TwoWayStream) ReadLongreal*(VAR x:LONGREAL);
BEGIN
END ReadLongreal;

PROCEDURE (VAR stream:TwoWayStream) WriteSet*(x:SET);
BEGIN
END WriteSet;

PROCEDURE (VAR stream:TwoWayStream) ReadSet*(VAR x:SET);
BEGIN
END ReadSet;

PROCEDURE (VAR stream:TwoWayStream) WriteStr*(VAR t:ARRAY OF CHAR);
BEGIN
END WriteStr;

PROCEDURE (VAR stream:TwoWayStream) WriteStrPart*(VAR t:ARRAY OF CHAR; pos,n:LONGINT);
BEGIN
END WriteStrPart;

PROCEDURE (VAR stream:TwoWayStream) ReadStr*(VAR t:ARRAY OF CHAR);
BEGIN
END ReadStr;

(* **************************************************************** *)

PROCEDURE (VAR stream:AsciiStream) ReadStr*(VAR t:ARRAY OF CHAR);
VAR
  ch:CHAR;
  savCode:INTEGER;
BEGIN
  savCode:=stream.resCode1;
  stream.resCode1:=NOERROR;
  stream.ReadChar(ch);
  t[0]:=0X;
  WHILE (stream.resCode1=NOERROR) & (ch#DELIMITER) DO
    IF (ch#0AX) & (ch#0DX) THEN Strings.AppendChar(t,ch) END;
    stream.ReadChar(ch);
  END;
  IF stream.resCode1=NOERROR THEN
    stream.resCode1:=savCode;
    stream.resCode2:=savCode;
  END;
END ReadStr;

PROCEDURE (VAR stream:AsciiStream) WriteLongint*(x:LONGINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END WriteLongint;

PROCEDURE (VAR stream:AsciiStream) ReadLongint*(VAR x:LONGINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.ReadStr(t);
  x:=Strings.Val(t);
END ReadLongint;

PROCEDURE (VAR stream:AsciiStream) WriteInt*(x:INTEGER);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END WriteInt;

PROCEDURE (VAR stream:AsciiStream) ReadInt*(VAR x:INTEGER);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.ReadStr(t);
  x:=SHORT(Strings.Val(t));
END ReadInt;

PROCEDURE (VAR stream:AsciiStream) WriteShortint*(x:SHORTINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END WriteShortint;

PROCEDURE (VAR stream:AsciiStream) ReadShortint*(VAR x:SHORTINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.ReadStr(t);
  x:=SHORT(SHORT(Strings.Val(t)));
END ReadShortint;

PROCEDURE (VAR stream:AsciiStream) WriteReal*(x:REAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Float.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END WriteReal;

PROCEDURE (VAR stream:AsciiStream) ReadReal*(VAR x:REAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.ReadStr(t);
  x:=SHORT(Float.Val(t));
END ReadReal;

PROCEDURE (VAR stream:AsciiStream) WriteLongreal*(x:LONGREAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Float.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END WriteLongreal;

PROCEDURE (VAR stream:AsciiStream) ReadLongreal*(VAR x:LONGREAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.ReadStr(t);
  x:=Float.Val(t);
END ReadLongreal;

PROCEDURE (VAR stream:AsciiStream) WriteSet*(x:SET);
VAR
  i:INTEGER;
  t:ARRAY 100 OF CHAR;
  first:BOOLEAN;
BEGIN
  stream.WriteChar("{");
  first:=TRUE;
  FOR i:=0 TO MAX(SET) DO
    IF i IN x THEN
      IF ~first THEN stream.WriteChar(",") END;
      Strings.Str(i,t);
      stream.WriteStrBody(t);
      first:=FALSE;
    END;
  END;
  stream.WriteChar("}");
  stream.WriteChar(DELIMITER);
END WriteSet;

PROCEDURE (VAR stream:AsciiStream) ReadSet*(VAR x:SET);
VAR
  i:LONGINT;
  t:ARRAY 100 OF CHAR;
  first:BOOLEAN;
  ch:CHAR;
  codeSav:INTEGER;
BEGIN
  codeSav:=stream.resCode1;
  stream.resCode1:=NOERROR;
  stream.ReadChar(ch);
  IF ch#"{" THEN END;
  stream.ReadChar(ch);
  x:={};
  WHILE (ch#"}") & (stream.resCode1=NOERROR) DO
    t:="";
    WHILE (ch#",") & (ch#"}") & (stream.resCode1=NOERROR) DO
      Strings.AppendChar(t,ch);
      stream.ReadChar(ch);
    END;
    i:=Strings.Val(t);
    IF (i>=0) & (i<=MAX(SET)) THEN
      x:=x + {i};
    ELSE
      stream.resCode1:=DATATYPEMISMATCH;
      stream.resCode2:=DATATYPEMISMATCH;
    END;
    IF ch="," THEN stream.ReadChar(ch) END;
  END;
  WHILE (ch#"}") & (stream.resCode1=DATATYPEMISMATCH) DO
    stream.ReadChar(ch);
  END;
  stream.ReadChar(ch);
  IF stream.resCode1=NOERROR THEN 
    stream.resCode1:=codeSav;
    stream.resCode2:=codeSav;
  END;
END ReadSet;

PROCEDURE (VAR stream:AsciiStream) WriteLn*(t:ARRAY OF CHAR);
BEGIN
  IF stream.open THEN
    stream.WriteStrBody(t);
    stream.WriteChar(0DX);
    stream.WriteChar(0AX);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteLn;

PROCEDURE (VAR stream:AsciiStream) ReadLn*(VAR t:ARRAY OF CHAR);
VAR 
  x:CHAR;
  i,l:LONGINT;          (* allow the line to end with CR, LF or CR LF *)
  s1,s2:INTEGER;
BEGIN
  i:=0;
  l:=LEN(t)-1;
  stream.ReadChar(x);
  WHILE (stream.resCode1=NOERROR) & (x#0DX) & (x#0AX) & (i<l) DO
    t[i]:=x;
    INC(i);
    stream.ReadChar(x);
  END;  
  t[i]:=0X;
  IF x=0DX THEN
    s1:=stream.resCode1; s2:=stream.resCode2;
    stream.ReadChar(x);
    IF x#0AX THEN stream.MovePos(-1) END;
    stream.resCode1:=s1; stream.resCode2:=s2;
  END;
END ReadLn;

PROCEDURE (VAR stream:AsciiStream) WriteStr*(VAR t:ARRAY OF CHAR);
BEGIN
  IF stream.open THEN
    stream.WriteStrBody(t);
    stream.WriteChar(09X);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteStr;

PROCEDURE (VAR stream:AsciiStream) WriteStrPart*(VAR t:ARRAY OF CHAR; pos,n:LONGINT);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    l:=Strings.Length(t);
    IF pos+n-1>l THEN n:=l-pos+1 END;
    IF n<=0 THEN RETURN END;
    stream.WriteStrBodyPart(t,pos,n);
    stream.WriteChar(09X);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteStrPart;

(* **************************************************************** *)

PROCEDURE (VAR stream:BinaryStream) WriteLongint*(x:LONGINT);
BEGIN
  stream.WriteBlock(x);
END WriteLongint;

PROCEDURE (VAR stream:BinaryStream) ReadLongint*(VAR x:LONGINT);
BEGIN
  stream.ReadBlock(x);
END ReadLongint;

PROCEDURE (VAR stream:BinaryStream) WriteInt*(x:INTEGER);
BEGIN
  stream.WriteBlock(x);
END WriteInt;

PROCEDURE (VAR stream:BinaryStream) ReadInt*(VAR x:INTEGER);
BEGIN
  stream.ReadBlock(x);
END ReadInt;

PROCEDURE (VAR stream:BinaryStream) WriteShortint*(x:SHORTINT);
BEGIN
  stream.WriteChar(SYSTEM.VAL(CHAR,x));
END WriteShortint;

PROCEDURE (VAR stream:BinaryStream) ReadShortint*(VAR x:SHORTINT);
VAR
  h:CHAR;
BEGIN
  stream.ReadChar(h);
  x:=SYSTEM.VAL(SHORTINT,x);
END ReadShortint;

PROCEDURE (VAR stream:BinaryStream) WriteReal*(x:REAL);
BEGIN
  stream.WriteBlock(x);
END WriteReal;

PROCEDURE (VAR stream:BinaryStream) ReadReal*(VAR x:REAL);
BEGIN
  stream.ReadBlock(x);
END ReadReal;

PROCEDURE (VAR stream:BinaryStream) WriteLongreal*(x:LONGREAL);
BEGIN
  stream.WriteBlock(x);
END WriteLongreal;

PROCEDURE (VAR stream:BinaryStream) ReadLongreal*(VAR x:LONGREAL);
BEGIN
  stream.ReadBlock(x);
END ReadLongreal;

PROCEDURE (VAR stream:BinaryStream) WriteSet*(x:SET);
BEGIN
  stream.WriteBlock(x);
  stream.WriteLongint(0);
END WriteSet;

PROCEDURE (VAR stream:BinaryStream) ReadSet*(VAR x:SET);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    stream.ReadBlock(x);
    stream.ReadLongint(l);
    IF l#0 THEN
      stream.resCode1:=DATATYPEMISMATCH;
      stream.resCode2:=DATATYPEMISMATCH;
    END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END ReadSet;

PROCEDURE (VAR stream:BinaryStream) WriteStr*(VAR t:ARRAY OF CHAR);
BEGIN
  IF stream.open THEN
    stream.WriteLongint(Strings.Length(t));  
    stream.WriteStrBody(t);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteStr;

PROCEDURE (VAR stream:BinaryStream) WriteStrPart*(VAR t:ARRAY OF CHAR; pos,n:LONGINT);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    l:=Strings.Length(t);
    IF pos+n-1>l THEN n:=l-pos+1 END;
    IF n<0 THEN n:=0 END;
    stream.WriteLongint(n);
    IF n=0 THEN RETURN END;
    stream.WriteStrBodyPart(t,pos,n);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END WriteStrPart;

PROCEDURE (VAR stream:BinaryStream) ReadStr*(VAR t:ARRAY OF CHAR);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    stream.ReadLongint(l);
    stream.ReadStrBody(l,t);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END ReadStr;

(* **************************************************************** *)

PROCEDURE (VAR stream:OneWayStream) Int*(VAR x:INTEGER);
BEGIN
END Int;

PROCEDURE (VAR stream:OneWayStream) Shortint*(VAR x:SHORTINT);
BEGIN
END Shortint;

PROCEDURE (VAR stream:OneWayStream) Longint*(VAR x:LONGINT);
BEGIN
END Longint;

PROCEDURE (VAR stream:OneWayStream) Real*(VAR x:REAL);
BEGIN
END Real;

PROCEDURE (VAR stream:OneWayStream) Longreal*(VAR x:LONGREAL);
BEGIN
END Longreal;

PROCEDURE (VAR stream:OneWayStream) Set*(VAR x:SET);
BEGIN
END Set;

PROCEDURE (VAR stream:OneWayStream) Char*(VAR x:CHAR);
BEGIN
END Char;

PROCEDURE (VAR stream:OneWayStream) Str*(VAR t:ARRAY OF CHAR);
BEGIN
END Str;

(* **************************************************************** *)

PROCEDURE (VAR stream:AsciiStreamIn) Open*(name:ARRAY OF CHAR);
BEGIN
  File.Open(name,TRUE,File.DENYWRITE,File.READONLY,stream.handle,stream.resCode1);
  stream.RestOfOpen;
END Open;

PROCEDURE (VAR stream:AsciiStreamIn) Int*(VAR x:INTEGER);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.Str(t);
  x:=SHORT(Strings.Val(t));
END Int;

PROCEDURE (VAR stream:AsciiStreamIn) Shortint*(VAR x:SHORTINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.Str(t);
  x:=SHORT(SHORT(Strings.Val(t)));
END Shortint;

PROCEDURE (VAR stream:AsciiStreamIn) Longint*(VAR x:LONGINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.Str(t);
  x:=Strings.Val(t);
END Longint;

PROCEDURE (VAR stream:AsciiStreamIn) Real*(VAR x:REAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.Str(t);
  x:=SHORT(Float.Val(t));
END Real;

PROCEDURE (VAR stream:AsciiStreamIn) Longreal*(VAR x:LONGREAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  stream.Str(t);
  x:=Float.Val(t);
END Longreal;

PROCEDURE (VAR stream:AsciiStreamIn) Set*(VAR x:SET);
VAR
  i:LONGINT;
  t:ARRAY 100 OF CHAR;
  first:BOOLEAN;
  ch:CHAR;
  codeSav:INTEGER;
BEGIN
  codeSav:=stream.resCode1;
  stream.resCode1:=NOERROR;
  stream.ReadChar(ch);
  IF ch#"{" THEN END;
  stream.ReadChar(ch);
  x:={};
  WHILE (ch#"}") & (stream.resCode1=NOERROR) DO
    t:="";
    WHILE (ch#",") & (ch#"}") & (stream.resCode1=NOERROR) DO
      Strings.AppendChar(t,ch);
      stream.ReadChar(ch);
    END;
    i:=Strings.Val(t);
    IF (i>=0) & (i<=MAX(SET)) THEN
      x:=x + {i};
    ELSE
      stream.resCode1:=DATATYPEMISMATCH;
      stream.resCode2:=DATATYPEMISMATCH;
    END;
    IF ch="," THEN stream.ReadChar(ch) END;
  END;
  WHILE (ch#"}") & (stream.resCode1=DATATYPEMISMATCH) DO
    stream.ReadChar(ch);
  END;
  stream.ReadChar(ch);
  IF stream.resCode1=NOERROR THEN 
    stream.resCode1:=codeSav;
    stream.resCode2:=codeSav;
  END;
END Set;

PROCEDURE (VAR stream:AsciiStreamIn) Char*(VAR x:CHAR);
BEGIN
  stream.ReadChar(x);
END Char;

PROCEDURE (VAR stream:AsciiStreamIn) Str*(VAR t:ARRAY OF CHAR);
VAR
  ch:CHAR;
  savCode:INTEGER;
BEGIN
  savCode:=stream.resCode1;
  stream.resCode1:=NOERROR;
  stream.ReadChar(ch);
  t[0]:=0X;
  WHILE (stream.resCode1=NOERROR) & (ch#DELIMITER) DO
    IF (ch#0AX) & (ch#0DX) THEN Strings.AppendChar(t,ch) END;
    stream.ReadChar(ch);
  END;
  IF stream.resCode1=NOERROR THEN
    stream.resCode1:=savCode;
    stream.resCode2:=savCode;
  END;
END Str;

(* **************************************************************** *)

PROCEDURE (VAR stream:AsciiStreamOut) Open*(name:ARRAY OF CHAR);
BEGIN
  File.Open(name,TRUE,File.DENYALL,File.WRITEONLY,stream.handle,stream.resCode1);
  stream.RestOfOpen;
END Open;

PROCEDURE (VAR stream:AsciiStreamOut) Int*(VAR x:INTEGER);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END Int;

PROCEDURE (VAR stream:AsciiStreamOut) Shortint*(VAR x:SHORTINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END Shortint;

PROCEDURE (VAR stream:AsciiStreamOut) Longint*(VAR x:LONGINT);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Strings.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END Longint;

PROCEDURE (VAR stream:AsciiStreamOut) Real*(VAR x:REAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Float.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END Real;

PROCEDURE (VAR stream:AsciiStreamOut) Longreal*(VAR x:LONGREAL);
VAR
  t:ARRAY 100 OF CHAR;
BEGIN
  Float.Str(x,t);
  stream.WriteStrBody(t);
  stream.WriteChar(DELIMITER);
END Longreal;

PROCEDURE (VAR stream:AsciiStreamOut) Set*(VAR x:SET);
VAR
  i:INTEGER;
  t:ARRAY 100 OF CHAR;
  first:BOOLEAN;
BEGIN
  stream.WriteChar("{");
  first:=TRUE;
  FOR i:=0 TO MAX(SET) DO
    IF i IN x THEN
      IF ~first THEN stream.WriteChar(",") END;
      Strings.Str(i,t);
      stream.WriteStrBody(t);
      first:=FALSE;
    END;
  END;
  stream.WriteChar("}");
  stream.WriteChar(DELIMITER);
END Set;

PROCEDURE (VAR stream:AsciiStreamOut) Char*(VAR x:CHAR);
BEGIN
  stream.WriteChar(x);
END Char;

PROCEDURE (VAR stream:AsciiStreamOut) Str*(VAR t:ARRAY OF CHAR);
BEGIN
  IF stream.open THEN
    stream.WriteStrBody(t);
    stream.WriteChar(09X);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END Str;

PROCEDURE (VAR stream:AsciiStreamOut) Close*;
VAR
  res:INTEGER;
BEGIN
  IF stream.open THEN
    stream.BufferWriteBack();
    File.Truncate(stream.handle,res);
    stream.Close^;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
  END;
END Close;


(* **************************************************************** *)

PROCEDURE (VAR stream:BinaryStreamIn) Open*(name:ARRAY OF CHAR);
BEGIN
  File.Open(name,TRUE,File.DENYWRITE,File.READONLY,stream.handle,stream.resCode1);
  stream.RestOfOpen;
END Open;

PROCEDURE (VAR stream:BinaryStreamIn) Int*(VAR x:INTEGER);
BEGIN
  stream.ReadBlock(x);
END Int;

PROCEDURE (VAR stream:BinaryStreamIn) Shortint*(VAR x:SHORTINT);
BEGIN
  stream.ReadBlock(x);
END Shortint;

PROCEDURE (VAR stream:BinaryStreamIn) Longint*(VAR x:LONGINT);
BEGIN
  stream.ReadBlock(x);
END Longint;

PROCEDURE (VAR stream:BinaryStreamIn) Real*(VAR x:REAL);
BEGIN
  stream.ReadBlock(x);
END Real;

PROCEDURE (VAR stream:BinaryStreamIn) Longreal*(VAR x:LONGREAL);
BEGIN
  stream.ReadBlock(x);
END Longreal;

PROCEDURE (VAR stream:BinaryStreamIn) Set*(VAR x:SET);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    stream.ReadBlock(x);
    stream.Longint(l);
    IF l#0 THEN
      stream.resCode1:=DATATYPEMISMATCH;
      stream.resCode2:=DATATYPEMISMATCH;
    END;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END Set;

PROCEDURE (VAR stream:BinaryStreamIn) Char*(VAR x:CHAR);
BEGIN
  stream.ReadChar(x);
END Char;

PROCEDURE (VAR stream:BinaryStreamIn) Str*(VAR t:ARRAY OF CHAR);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    stream.Longint(l);
    stream.ReadStrBody(l,t);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END Str;

(* **************************************************************** *)

PROCEDURE (VAR stream:BinaryStreamOut) Open*(name:ARRAY OF CHAR);
BEGIN
  File.Open(name,TRUE,File.DENYALL,File.WRITEONLY,stream.handle,stream.resCode1);
  stream.RestOfOpen;
END Open;

PROCEDURE (VAR stream:BinaryStreamOut) Int*(VAR x:INTEGER);
BEGIN
  stream.WriteBlock(x);
END Int;

PROCEDURE (VAR stream:BinaryStreamOut) Shortint*(VAR x:SHORTINT);
BEGIN
  stream.WriteBlock(x);
END Shortint;

PROCEDURE (VAR stream:BinaryStreamOut) Longint*(VAR x:LONGINT);
BEGIN
  stream.WriteBlock(x);
END Longint;

PROCEDURE (VAR stream:BinaryStreamOut) Real*(VAR x:REAL);
BEGIN
  stream.WriteBlock(x);
END Real;

PROCEDURE (VAR stream:BinaryStreamOut) Longreal*(VAR x:LONGREAL);
BEGIN
  stream.WriteBlock(x);
END Longreal;

PROCEDURE (VAR stream:BinaryStreamOut) Set*(VAR x:SET);
VAR
  l:LONGINT;
BEGIN
  stream.WriteBlock(x);
  l:=0;
  stream.Longint(l);
END Set;

PROCEDURE (VAR stream:BinaryStreamOut) Char*(VAR x:CHAR);
BEGIN
  stream.WriteChar(x);
END Char;

PROCEDURE (VAR stream:BinaryStreamOut) Str*(VAR t:ARRAY OF CHAR);
VAR
  l:LONGINT;
BEGIN
  IF stream.open THEN
    l:=Strings.Length(t);
    stream.Longint(l);  
    stream.WriteStrBody(t);
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=STREAMNOTOPEN;
  END;
END Str;

PROCEDURE (VAR stream:BinaryStreamOut) Close*;
VAR
  res:INTEGER;
BEGIN
  IF stream.open THEN
    stream.BufferWriteBack();
    File.Truncate(stream.handle,res);
    stream.Close^;
  ELSE
    stream.resCode1:=STREAMNOTOPEN;
    stream.resCode2:=stream.resCode1;
  END;
END Close;

END Streams.
