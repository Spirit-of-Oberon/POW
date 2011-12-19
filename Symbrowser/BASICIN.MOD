MODULE BasicIn;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * Provides simple LOW I/O input functions                                      *
 ********************************************************************************)

IMPORT File;

VAR result* : INTEGER; (* consider the FILE-MODULE *)
    size*: LONGINT;

PROCEDURE ReadByte*(VAR val:CHAR; fileHandle:File.Handle):BOOLEAN;
VAR
  readN  : LONGINT;
BEGIN
  INC(size);
  File.ReadBlock(fileHandle, val, 1, readN, result);
  RETURN (readN = 1) & (result = File.NOERROR); 
END ReadByte;

PROCEDURE ReadShort*(VAR val:INTEGER; fileHandle:File.Handle):BOOLEAN;
VAR
  readN  : LONGINT;
BEGIN
  File.ReadBlock(fileHandle, val, 2, readN, result);
  RETURN (readN = 2) & (result = File.NOERROR);
END ReadShort;

PROCEDURE ReadLong*(VAR val:LONGINT; fileHandle:File.Handle):BOOLEAN;
VAR
  readN  : LONGINT;
BEGIN
  File.ReadBlock(fileHandle, val, 4, readN, result);
  RETURN (readN = 4) & (result = File.NOERROR);
END ReadLong;  

PROCEDURE ReadReal*(VAR val: REAL; fileHandle:File.Handle):BOOLEAN;
VAR
  readN : LONGINT;
BEGIN
  File.ReadBlock(fileHandle, val, 4, readN, result);
  RETURN (readN = 4) & (result = File.NOERROR);
END ReadReal;

PROCEDURE ReadLongReal*(VAR val: LONGREAL; fileHandle: File.Handle):BOOLEAN;
VAR
  readN : LONGINT;
BEGIN
  File.ReadBlock(fileHandle, val, 8, readN, result);
  RETURN (readN = 8) & (result = File.NOERROR);
END ReadLongReal;

PROCEDURE OpenFile*(fileName: ARRAY OF CHAR; VAR fileHandle:File.Handle):BOOLEAN;
VAR
  result : INTEGER;
BEGIN
  File.Open(fileName, FALSE, File.DENYWRITE, File.READONLY, fileHandle, result);
  RETURN result = File.NOERROR;
END OpenFile;

PROCEDURE CloseFile*(fileHandle: File.Handle):BOOLEAN;
BEGIN
  File.Close(fileHandle);
  result := File.NOERROR;
  RETURN result = File.NOERROR;
END CloseFile;

PROCEDURE EOF*():BOOLEAN;
BEGIN
  RETURN result = File.EOFREACHED;
END EOF;

BEGIN
  size:=0;
END BasicIn.
