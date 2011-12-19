MODULE Constant;

(*****************************************************************************
 * Autor   : Gerhard Kurka                                                   *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files    *
 *****************************************************************************
 * PURPOSE:  Implements classes derived from SymElement to handle constants  *
 *****************************************************************************)

IMPORT SymElem, SymFile, Display:=PowDDE, Symbol, SymLists;

TYPE SimpleType = RECORD 
                  END;
     
     ByteType   = RECORD (SimpleType)
                    byteValue : INTEGER;
                  END;

     BoolType   = RECORD (SimpleType)
                    boolValue : BOOLEAN;
                  END;

     CharType   = RECORD (SimpleType)
                    charValue : CHAR;
                  END;

     SintType   = RECORD (SimpleType)
                    sintValue : INTEGER;
                  END;

     IntType    = RECORD (SimpleType)
                    intValue  : INTEGER;
                  END;

     LintType   = RECORD (SimpleType)
                    lintValue : LONGINT;
                  END;

     SetType    = RECORD (SimpleType)
                    setValue  : LONGINT;
                  END;

     RealType   = RECORD (SimpleType)
                    realValue : REAL;
                  END;

     LrealType  = RECORD (SimpleType)
                    lrealValue: LONGREAL;
                  END;

     StringType = RECORD (SimpleType)
                    stringValue: ARRAY 80 OF CHAR;
                  END;

     NilType    = RECORD (SimpleType)
                  END;
                                       

     PConstant* = POINTER TO Constant;
     Constant*  = RECORD (SymElem.SymElement)
                    constValue: POINTER TO SimpleType;
                    constName : ARRAY 40 OF CHAR;
                  END;
                  
PROCEDURE (VAR self:SimpleType) ReadConstValue();
BEGIN
END ReadConstValue;

PROCEDURE (VAR self:SimpleType) DisplayConstValue();
BEGIN
END DisplayConstValue;

PROCEDURE (VAR self: ByteType)  ReadConstValue();
BEGIN
  self.byteValue := SymFile.ReadByte();
END ReadConstValue;

PROCEDURE (VAR self: ByteType)  DisplayConstValue();
BEGIN
  Display.WriteInt(self.byteValue,0);
  Display.WriteStr('H;'); 
  IF SymFile.debug THEN
    Display.WriteStr(' (* byte constant *) ');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: CharType)  ReadConstValue();
BEGIN
  self.charValue := SymFile.ReadChar();
END ReadConstValue;

PROCEDURE (VAR self: CharType)  DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteInt(ORD(self.charValue),0);
  Display.WriteStr('X;'); 
  IF SymFile.debug THEN
    Display.WriteStr(' (* character constant ');
    IF (ORD(self.charValue) > 62) & (ORD(self.charValue) < 128) THEN
      Display.WriteStr('"');
      Display.WriteChar(self.charValue);
      Display.WriteStr('" ');
    END;
    Display.WriteStr('*)');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: BoolType)  ReadConstValue();
BEGIN
  self.boolValue:=SymFile.ReadByte()#0;
END ReadConstValue;

PROCEDURE (VAR self: BoolType)  DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  IF self.boolValue THEN
    Display.WriteStr("TRUE");
  ELSE
    Display.WriteStr("FALSE");
  END;
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* boolean constant *)');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: SintType)  ReadConstValue();
BEGIN
  self.sintValue := SymFile.ReadByte();
END ReadConstValue;

PROCEDURE (VAR self: SintType)  DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteInt(self.sintValue,0);
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* shortint constant *) ');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: IntType)   ReadConstValue();
BEGIN
  self.intValue := SymFile.ReadInt();
END ReadConstValue;

PROCEDURE (VAR self: IntType)   DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteInt(self.intValue, 0); 
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* int constant *) ');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: LintType)  ReadConstValue();
BEGIN
  self.lintValue := SymFile.ReadLongInt();
END ReadConstValue;

PROCEDURE (VAR self: LintType) DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteInt(self.lintValue,0); 
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* lint constant *) ');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: SetType)  ReadConstValue();
BEGIN
  self.setValue := SymFile.ReadLongInt();
END ReadConstValue;

PROCEDURE (VAR self: SetType)  DisplayConstValue();
VAR 
  i: INTEGER;
  v: LONGINT;
  a: BOOLEAN;
BEGIN
  a:=FALSE;
  Display.WriteStr(' {');
  v := self.setValue;
  FOR i:=0 TO 31 DO
    IF (v MOD 2) = 1 THEN
      IF a THEN
        Display.WriteStr(',');
      END;
      Display.WriteInt(i,0);
      a:=TRUE;
    END;
    v := v DIV 2;
  END;
  Display.WriteStr('};');
  IF SymFile.debug THEN
    Display.WriteStr(' (* set constant *) ');
  END;  
END DisplayConstValue;

PROCEDURE (VAR self: RealType) ReadConstValue();
BEGIN
  self.realValue := SymFile.ReadReal();
END ReadConstValue;

PROCEDURE (VAR self: RealType) DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteReal(self.realValue,13);
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* real constant *)');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: LrealType) ReadConstValue();
BEGIN
  self.lrealValue := SymFile.ReadLongReal();
END ReadConstValue;

PROCEDURE (VAR self: LrealType) DisplayConstValue();
BEGIN
  Display.WriteStr(' ');
  Display.WriteReal(self.lrealValue,18);
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* longReal constant *)');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: StringType) ReadConstValue();
BEGIN
  SymFile.ReadString(self.stringValue);
END ReadConstValue;

PROCEDURE (VAR self: StringType) DisplayConstValue();
BEGIN
  Display.WriteStr(' "');
  Display.WriteStr(self.stringValue); 
  Display.WriteStr('";');
  IF SymFile.debug THEN
    Display.WriteStr(' (* string constant *) ');
  END;
END DisplayConstValue;

PROCEDURE (VAR self: NilType) ReadConstValue();
BEGIN
END ReadConstValue;

PROCEDURE (VAR self: NilType) DisplayConstValue();
BEGIN
  Display.WriteStr(' NIL;');
END DisplayConstValue;

PROCEDURE (self: PConstant) ReadSymInformation*();
VAR
  byteVal:  POINTER TO ByteType;
  charVal:  POINTER TO CharType;
  sintVal:  POINTER TO SintType;
  intVal :  POINTER TO IntType;
  lintVal:  POINTER TO LintType;
  setVal :  POINTER TO SetType;
  realVal:  POINTER TO RealType;
  lrealVal: POINTER TO LrealType;
  stringVal:POINTER TO StringType;
  boolVal:  POINTER TO BoolType;
  nilVal:   POINTER TO NilType;
  dmy: INTEGER;
BEGIN
  SymFile.NewSym();
  IF ~SymFile.success THEN RETURN; END;
  dmy:=SymFile.ReadByte();   (* inconsistency in compiler 1.19 *)
  IF ~SymFile.success THEN RETURN; END;
  CASE SymFile.sy OF
    Symbol.byteSy:  NEW(byteVal);  self.constValue := byteVal;
   |Symbol.charSy:  NEW(charVal);  self.constValue := charVal;
   |Symbol.sintSy:  NEW(sintVal);  self.constValue := sintVal;
   |Symbol.intSy :  NEW(intVal);   self.constValue := intVal;
   |Symbol.lintSy:  NEW(lintVal);  self.constValue := lintVal;
   |Symbol.setSy :  NEW(setVal);   self.constValue := setVal;
   |Symbol.realSy:  NEW(realVal);  self.constValue := realVal;
   |Symbol.lrealSy: NEW(lrealVal); self.constValue := lrealVal;
   |Symbol.stringSy:NEW(stringVal);self.constValue := stringVal;   
   |Symbol.boolSy:  NEW(boolVal);  self.constValue := boolVal;
   |Symbol.nilSy:   NEW(nilVal);   self.constValue := nilVal;
  ELSE
    SymFile.success := FALSE;
    RETURN;
  END;
  self.constValue.ReadConstValue();
  SymFile.ReadString(self.constName);
  SymLists.constList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PConstant) DisplaySymInformation*();
BEGIN
  Display.WriteStr('  ');Display.WriteStr(self.constName); Display.WriteStr(' *='); 
  self.constValue.DisplayConstValue;
  Display.WriteLn;
END DisplaySymInformation;

BEGIN
END Constant.
  
 
