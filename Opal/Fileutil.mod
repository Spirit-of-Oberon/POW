MODULE FileUtil;
(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  06-20-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module implements some basic routines used by the modules File and
  Volume.
  ----------------------------------------------------------------------------*)

IMPORT SYSTEM,Utils,Strings,WinB:=WinBase,WinNT;

CONST
  SHORTBUFFER                    *= MIN(INTEGER);
  
  ERROR_FILE_NOT_FOUND           *=   2;
  ERROR_PATH_NOT_FOUND           *=   3;
  ERROR_TOO_MANY_OPEN_FILES      *=   4;
  ERROR_ACCESS_DENIED            *=   5;
  ERROR_INVALID_HANDLE           *=   6;
  ERROR_INVALID_DRIVE            *=  15;
  ERROR_NO_MORE_FILES            *=  18;
  ERROR_WRITE_PROTECT            *=  19;
  ERROR_NOT_READY                *=  21;
  ERROR_CRC                      *=  23;
  ERROR_BAD_LENGTH               *=  24;
  ERROR_SEEK                     *=  25;
  ERROR_NOT_DOS_DISK             *=  26;
  ERROR_SECTOR_NOT_FOUND         *=  27;
  ERROR_WRITE_FAULT              *=  29;
  ERROR_READ_FAULT               *=  30;
  ERROR_SHARING_VIOLATION        *=  32;
  ERROR_LOCK_VIOLATION           *=  33;
  ERROR_WRONG_DISK               *=  34;
  ERROR_SHARING_BUFFER_EXCEEDED  *=  36;
  ERROR_HANDLE_EOF               *=  38;
  ERROR_HANDLE_DISK_FULL         *=  39;
  ERROR_BAD_NETPATH              *=  53;
  ERROR_NETWORK_BUSY             *=  54;
  ERROR_FILE_EXISTS              *=  80;
  ERROR_CANNOT_MAKE              *=  82;
  ERROR_DISK_CHANGE              *= 107;
  ERROR_DRIVE_LOCKED             *= 108;
  ERROR_OPEN_FAILED              *= 110;
  ERROR_BUFFER_OVERFLOW          *= 111;
  ERROR_DISK_FULL                *= 112;
  ERROR_INVALID_NAME             *= 123;
  ERROR_NO_VOLUME_LABEL          *= 125;
  ERROR_DIRECT_ACCESS_HANDLE     *= 130;
  ERROR_NEGATIVE_SEEK            *= 131;
  ERROR_SEEK_ON_DEVICE           *= 132;
  ERROR_DIR_NOT_EMPTY            *= 145;
  ERROR_LABEL_TOO_LONG           *= 154;
  ERROR_BAD_PATHNAME             *= 161;
  ERROR_BUSY                     *= 170;
  ERROR_ALREADY_EXISTS           *= 183;

  NOERROR*=0;

PROCEDURE CorrectDelimiters*(VAR t:ARRAY OF CHAR);
VAR
  i,l:LONGINT;
BEGIN
  i:=0;
  l:=LEN(t);
  WHILE (i<l) & (t[i]#0X) DO
    IF t[i]="/" THEN t[i]:="\" END;
    INC(i);
  END;
END CorrectDelimiters;
  
PROCEDURE GetErrorMessage*(error:LONGINT; VAR message:ARRAY OF CHAR);
VAR
  res:LONGINT;
BEGIN
  IF error=0 THEN
    COPY("no error",message);
  ELSE
    res:=WinB.FormatMessageA(WinB.FORMAT_MESSAGE_FROM_SYSTEM,
                             0,
                             error,
                             SYSTEM.MAKELONG(WinNT.SUBLANG_SYS_DEFAULT,WinNT.LANG_NEUTRAL),
                             SYSTEM.ADR(message),
                             LEN(message),
                             0);
    IF res=0 THEN COPY("no msg for error available",message) END;
  END;
END GetErrorMessage;

PROCEDURE String2Date*(VAR dateStr-:ARRAY OF CHAR; VAR time:WinB.FILETIME);
VAR
  sysTime:WinB.SYSTEMTIME;
  th:ARRAY 5 OF CHAR;

  PROCEDURE ShortVal(str:ARRAY OF CHAR):INTEGER;
  VAR
    h:LONGINT;
  BEGIN
    h:=Strings.Val(str);
    IF h<0 THEN RETURN -1 ELSE RETURN SHORT(h) END;
  END ShortVal;

BEGIN
  IF Strings.Length(dateStr)<20 THEN 
    time.dwLowDateTime:=0;
    time.dwHighDateTime:=0;
    RETURN;
  END;
  Strings.Copy(dateStr,th,7,4);  sysTime.wYear  :=ShortVal(th);  
  Strings.Copy(dateStr,th,4,2);  sysTime.wMonth :=ShortVal(th); 
  Strings.Copy(dateStr,th,1,2);  sysTime.wDay   :=ShortVal(th);   
  Strings.Copy(dateStr,th,13,2); sysTime.wHour  :=ShortVal(th);
  Strings.Copy(dateStr,th,16,2); sysTime.wMinute:=ShortVal(th);
  Strings.Copy(dateStr,th,19,2); sysTime.wSecond:=ShortVal(th);
  sysTime.wMilliseconds:=0;
  IF WinB.SystemTimeToFileTime(sysTime,time)=0 THEN
    time.dwLowDateTime:=0; time.dwHighDateTime:=0;
  END;
END String2Date;

PROCEDURE Date2String*(time:WinB.FILETIME; VAR dateStr:ARRAY OF CHAR);
VAR
  sysTime:WinB.SYSTEMTIME;
  h:ARRAY 20 OF CHAR;
BEGIN
  IF WinB.FileTimeToSystemTime(time,sysTime)=0 THEN
    COPY("error",dateStr);
  ELSE
    Strings.Str(sysTime.wDay,dateStr);
    Strings.RightAlign(dateStr,2);
    Strings.AppendChar(dateStr,".");
    Strings.Str(sysTime.wMonth,h);
    Strings.RightAlign(h,2);
    Strings.Append(dateStr,h);
    Strings.AppendChar(dateStr,".");
    Strings.Str(sysTime.wYear,h);
    Strings.RightAlign(h,4);
    Strings.Append(dateStr,h);
    Strings.Append(dateStr,"  ");
    Strings.Str(sysTime.wHour,h);
    IF Strings.Length(h)=1 THEN Strings.InsertChar("0",h,1) END;
    Strings.Append(dateStr,h);
    Strings.AppendChar(dateStr,":");
    Strings.Str(sysTime.wMinute,h);
    IF Strings.Length(h)=1 THEN Strings.InsertChar("0",h,1) END;
    Strings.Append(dateStr,h);
    Strings.AppendChar(dateStr,":");
    Strings.Str(sysTime.wSecond,h);
    IF Strings.Length(h)=1 THEN Strings.InsertChar("0",h,1) END;
    Strings.Append(dateStr,h);
  END;
END Date2String;


END FileUtil.
