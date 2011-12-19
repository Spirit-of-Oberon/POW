MODULE SymFile;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * This is based on basicin and provides higher level read-access to the        *
 * symbolfile.                                                                  *
 ********************************************************************************)

IMPORT BasicIn, File, Symbol;

VAR
  symFileHandle : File.Handle;
  success*      : BOOLEAN;
  symFileOpen   : BOOLEAN; 
  sy*           : INTEGER; 
  debug*        : BOOLEAN; (* Indicates debug-mode *)
  allMod*       : BOOLEAN; (* output of foreign type defs *)

PROCEDURE OpenSymFile*(symFileName: ARRAY OF CHAR);
BEGIN
  IF ~symFileOpen THEN
    success := BasicIn.OpenFile(symFileName, symFileHandle);
    symFileOpen := success;
  ELSE
    success := FALSE;
  END;
END OpenSymFile;

PROCEDURE CloseSymFile*();
BEGIN
  IF symFileOpen THEN
    success := BasicIn.CloseFile(symFileHandle);
    symFileOpen := ~success;
  ELSE
    success := FALSE;
  END;
END CloseSymFile;

PROCEDURE ReadChar*():CHAR;
VAR
  c : CHAR;
BEGIN
  success := BasicIn.ReadByte(c, symFileHandle);
  RETURN c;
END ReadChar;

PROCEDURE ReadByte*():INTEGER;
BEGIN
  RETURN ORD(ReadChar());
END ReadByte;

PROCEDURE ReadInt*():INTEGER;
VAR
  i : INTEGER;
BEGIN
  success := BasicIn.ReadShort(i, symFileHandle);
  RETURN i;
END ReadInt;

PROCEDURE ReadLongInt*():LONGINT;
VAR
  l : LONGINT;
BEGIN
  success := BasicIn.ReadLong(l, symFileHandle);
  RETURN l;
END ReadLongInt;

PROCEDURE ReadReal*():REAL;
VAR 
  l : REAL;
BEGIN
  success := BasicIn.ReadReal(l, symFileHandle);
  RETURN l;
END ReadReal;

PROCEDURE ReadLongReal*():LONGREAL;
VAR
  l : LONGREAL;
BEGIN
  success := BasicIn.ReadLongReal(l, symFileHandle);
  RETURN l;
END ReadLongReal;

(* Reads a characterstring which terminates with zero *)
PROCEDURE ReadString*(VAR s: ARRAY OF CHAR);
VAR
  i : INTEGER;
BEGIN
  i := 0;
  s[i] := ReadChar();
  WHILE success & (ORD(s[i]) # 0) DO
    i := i + 1;
    s[i] := ReadChar();
  END;
END ReadString;   

(* Read a new symbol-indicator (1-Byte) *)
PROCEDURE NewSym*();
BEGIN
  sy := ReadByte();
  IF ~success THEN 
    sy := Symbol.eofSy;
  END;
END NewSym;

BEGIN
  success     := TRUE;
  symFileOpen := FALSE;
END SymFile.