MODULE Parse;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * Parses the symbol-file by calling the proper SymElement methods. In addition *
 * it builds up a symbol list that reflects the structure of the current        *
 * symbol file. A subsequent loop displays each symbol by it's type bounded     *
 * method.                                                                      *
 ********************************************************************************)

IMPORT WD:=WinDef, WU:=WinUser, SYSTEM, Utils,
       SymFile, Symbol, Display := PowDDE, MiscSym, SymElem, SymLists, Strings;

TYPE sp = ARRAY 20 OF CHAR;

VAR
  symbolChain : POINTER TO SymElem.SymElement;
  element     : POINTER TO SymElem.SymElement;
  help        : POINTER TO SymElem.SymElement;
  c           : CHAR;

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

PROCEDURE InitParser*(name:ARRAY OF CHAR):BOOLEAN;
VAR        
  helpStr   : ARRAY 80 OF CHAR;
  ret       : LONGINT;
  signature : LONGINT;
  version   : LONGINT;
BEGIN
  SymFile.OpenSymFile(name);
  IF SymFile.success THEN
    signature:=SymFile.ReadLongInt();
    IF SymFile.success & (signature=1A4D5953H) THEN
       version:=SymFile.ReadLongInt();
       MiscSym.version:=version;
       IF SymFile.success & (Utils.HiWord(version)=0016H) THEN
          IF Utils.LoWord(version)=0119H THEN
             MiscSym.version32Bit:=FALSE;
             MiscSym.InitMiscSym();
             symbolChain:=NIL;
             RETURN TRUE;
          ELSIF Utils.LoWord(version)<0119H THEN
             ret := WU.MessageBoxA(0, SYSTEM.ADR('Symbol File format is from old compiler!'),
                                    SYSTEM.ADR('Browser File Error'), WU.MB_OK);
          ELSE
             ret := WU.MessageBoxA(0, SYSTEM.ADR('Symbol File format is newer than this browser!'),
                                    SYSTEM.ADR('Browser File Error'), WU.MB_OK);
          END;
       ELSIF SymFile.success & (Utils.HiWord(version)=0032H) THEN
          IF Utils.LoWord(version)=0200H THEN
             MiscSym.version32Bit:=TRUE;
             MiscSym.InitMiscSym();
             symbolChain:=NIL;
             RETURN TRUE;
          ELSIF Utils.LoWord(version)<0200H THEN
             ret := WU.MessageBoxA(0, SYSTEM.ADR('Symbol File format is from old compiler!'),
                                    SYSTEM.ADR('Browser File Error'), WU.MB_OK);
          ELSE
             ret := WU.MessageBoxA(0, SYSTEM.ADR('Symbol File format is newer than this browser!'),
                                    SYSTEM.ADR('Browser File Error'), WU.MB_OK);
          END;
       END;
    ELSE
       ret := WU.MessageBoxA(0, SYSTEM.ADR('Invalid Symbol File !'),
                             SYSTEM.ADR('Browser File Error'), WU.MB_OK);
    END;
    SymFile.CloseSymFile;
    SymFile.success := FALSE;
    RETURN FALSE;
  ELSE
    CopyString(helpStr,"Cannot Open File: ");
    Strings.Append(helpStr,name); 
    ret := WU.MessageBoxA(0, SYSTEM.ADR(helpStr),
                           SYSTEM.ADR('Browser File Error'), WU.MB_OK);
    RETURN FALSE;
  END;
END InitParser;

PROCEDURE PSymFile*();
VAR
  arrayTypeFlag : BOOLEAN;
BEGIN
  IF SymFile.success THEN
    SymFile.NewSym();
    IF SymFile.success & (SymFile.sy # Symbol.eofSy) THEN
      MiscSym.Element();
      element     := MiscSym.sym;
      symbolChain := element;
      help        := element; 
    END;    
    SymFile.NewSym();
    WHILE (element # NIL) & SymFile.success & (SymFile.sy # Symbol.eofSy) DO
      MiscSym.Element();
      element := MiscSym.sym;
      IF element # NIL THEN
        help.next := element;
        help := help.next; 
        SymFile.NewSym();
      END;
    END;
    SymFile.CloseSymFile();
    SymElem.IterateOverAllSyms(); (* FixUps and some other things *)

    SymLists.moduleList.Describe('invisible');
    Display.WriteLn();
    IF (~SymLists.typeList.IsEmpty() OR ~SymLists.arrayList.IsEmpty() OR ~SymLists.recordList.IsEmpty()
        OR ~SymLists.procTypeList.IsEmpty()) THEN
      Display.WriteStr('TYPE');
      Display.WriteLn();
    END;
    SymLists.typeList.Describe(' (** TYPES **)');
    SymLists.pointerList.Describe(' (** POINTER TYPES **)');
    SymLists.arrayList.Describe(' (** ARRAYS **)');
    SymLists.recordList.Describe(' (** RECORDS **)');
    SymLists.procTypeList.Describe(' (** PROCEDURE TYPES **)');
    SymLists.constList.Describe('CONST ');
    SymLists.variableList.Describe('VAR '); 

    SymLists.tprocedureList.Describe('(** TYPE BOUNDED METHODS **)');
    SymLists.cprocedureList.Describe('(** INTRINSIC PROCEDURES **)');
    SymLists.wprocedureList.Describe('(** WINDOWS PROCEDURES **)');
    SymLists.cdeclprocedureList.Describe('(** CDECL PROCEDURES **)');
    SymLists.procedureList.Describe('(** OBERON PROCEDURES **)');
     
    Display.WriteStr('END '); Display.WriteStr(MiscSym.modulName); Display.WriteStr('.');
    Display.WriteLn();
  END;
END PSymFile;

BEGIN
END Parse.
