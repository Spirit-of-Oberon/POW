MODULE PowDDE;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * This Module provides a small set of functions which enable DDE-communication *
 * with POW. If you use this module, you should be shure that only one POW      *
 * instance is up at a time.                                                    *
 ********************************************************************************)


IMPORT WD:=WinDef, WU:=WinUser, Strings, DDEML, SYSTEM, Float;

VAR
  instance        : LONGINT;
  serviceStr      : ARRAY 20 OF CHAR;
  topicStr        : ARRAY 20 OF CHAR;
  serviceStrHandle: DDEML.HSZ;
  topicStrHandle  : DDEML.HSZ;
  convContext     : DDEML.HCONV;
  str             : ARRAY 200 OF CHAR;
  buffer          : ARRAY 512 OF CHAR; (* buffer to speed up the text-transfer *)
  bufferLen       : LONGINT;

PROCEDURE FlushBuffer();
VAR 
  data : DDEML.HDDEDATA;
  res:WD.DWORD;
BEGIN
  data := DDEML.DdeClientTransaction(SYSTEM.ADR(buffer), bufferLen+1, convContext, 0, WU.CF_TEXT, DDEML.XTYP_EXECUTE, 0, res);
  buffer := 'AppendText ';
  bufferLen := Strings.Length(buffer);
END FlushBuffer;

PROCEDURE SendStringToPow*(s: ARRAY OF CHAR);
VAR 
  data : DDEML.HDDEDATA;
  res:WD.DWORD;
BEGIN
  data := DDEML.DdeClientTransaction(SYSTEM.ADR(s), Strings.Length(s)+1, convContext, 0, WU.CF_TEXT, DDEML.XTYP_EXECUTE, 0, res);
END SendStringToPow;

PROCEDURE SendTextToPow(s: ARRAY OF CHAR);
VAR data: DDEML.HDDEDATA;
    len : LONGINT;
    i   : LONGINT;
    str : ARRAY 200 OF CHAR;
BEGIN
  len := Strings.Length(s);
  IF bufferLen + len + 1 >= 512 THEN
    FlushBuffer();
  END;
  Strings.Append(buffer, s);
  bufferLen := bufferLen + len;
END SendTextToPow;
  
PROCEDURE WriteInt*(x: LONGINT; i:INTEGER);
BEGIN
  Strings.Str(x, str);
  Strings.RightAlign(str, i);
  SendTextToPow(str);
END WriteInt;

PROCEDURE WriteHex*(x: LONGINT);
CONST HEX= '0123456789ABCDEF';
VAR
  hex : ARRAY 20 OF CHAR;
  buf : ARRAY 5 OF CHAR;
BEGIN
  IF (x>=1000H) OR (x<0) THEN
     COPY('####',buf);
  ELSE
     COPY(HEX,hex);
     buf[4] := 0X;
     buf[3] := hex[x MOD 16]; x := x DIV 16;
     buf[2] := hex[x MOD 16]; x := x DIV 16;
     buf[1] := hex[x MOD 16]; x := x DIV 16;
     buf[0] := hex[x MOD 16];
  END;
  SendTextToPow(buf);
END WriteHex;

PROCEDURE CopyString(VAR d:ARRAY OF CHAR; s:ARRAY OF CHAR);
VAR i:INTEGER;
BEGIN
  i:= 0;
  d[i]:= s[i];
  WHILE d[i] # CHR(0) DO
    i := i + 1;
    d[i] := s[i];
  END;
END CopyString;

PROCEDURE WriteStr*(s: ARRAY OF CHAR);
BEGIN
  SendTextToPow(s);
END WriteStr;

PROCEDURE WriteChar*(c: CHAR);
BEGIN
  str[0] := c;
  str[1] := CHR(0);
  SendTextToPow(str);
END WriteChar;

PROCEDURE WriteLn*();
BEGIN
  str[0] := CHR(13);
  str[1] := CHR(10);
  str[2] := CHR(0);
  SendTextToPow(str); 
END WriteLn;

PROCEDURE WriteReal*(x: LONGREAL; i:INTEGER);
VAR
  j : INTEGER;
BEGIN
  Float.Str(x, str);
  j := 0;
  WHILE (str[j] # CHR(0)) & (j < i) DO
    j := j + 1;
  END;
  str[j] := CHR(0);
  Strings.RightAlign(str, i);    
  SendTextToPow(str);
END WriteReal;

PROCEDURE [_APICALL] CallBack*(type,fmt:WD.UINT; 
                              hconv:DDEML.HCONV; 
                              hsz1, hsz2:DDEML.HSZ;
                              hData:DDEML.HDDEDATA; 
                              dwData1, dwData2:WD.DWORD): DDEML.HDDEDATA;
BEGIN

END CallBack;

PROCEDURE CreatePowConnection*():BOOLEAN;
VAR 
  uRes : LONGINT;
BEGIN
  uRes:=0;
  uRes:=DDEML.DdeInitializeA (instance, CallBack , DDEML.APPCMD_CLIENTONLY, uRes);
  IF uRes # DDEML.DMLERR_NO_ERROR THEN
    RETURN FALSE;
  END;
  serviceStr := 'Pow';
  topicStr   := 'Pow';
  serviceStrHandle:=DDEML.DdeCreateStringHandleA(instance, SYSTEM.ADR(serviceStr), 0);
  topicStrHandle  :=DDEML.DdeCreateStringHandleA(instance, SYSTEM.ADR(topicStr), 0);
  convContext := DDEML.DdeConnect(instance, serviceStrHandle, topicStrHandle, NIL);  
  RETURN convContext # 0;
END CreatePowConnection;

PROCEDURE DestroyPowConnection*();
VAR
  res : WD.BOOL;
BEGIN
  IF bufferLen > 0 THEN
    FlushBuffer();
  END;
  res := DDEML.DdeDisconnect(convContext);
  res := DDEML.DdeUninitialize(instance);
END DestroyPowConnection;

BEGIN
  buffer    := 'AppendText ';
  bufferLen := Strings.Length(buffer);
END PowDDE.
