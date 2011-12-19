MODULE MiscSym;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * This module provides specific classes derived from SymElement for individual *
 * handling of the different sym-types.                                         *
 ********************************************************************************)

IMPORT SYSTEM,Utils,SymElem, BasicIn, SymFile, Display:=PowDDE, Symbol, Constant, Strings, SymLists;

TYPE  PBasicType=    POINTER TO BasicType;              (* Abstract basicClass for TYPES *)
      BasicType =    RECORD (SymElem.SymElement)
               name- : ARRAY 80 OF CHAR;
                       size  : LONGINT;
                       modNo : INTEGER;
                       ownRef: INTEGER;
                     END;            

      PBasicProc=    POINTER TO BasicProc;
      BasicProc =    RECORD (SymElem.SymElement)
                        name    : ARRAY 40 OF CHAR;     (* name of procedure *)
                        parList : SymElem.PSymElement;  (* List of formal-parameters *)
                        ref1    : INTEGER;              (* Resulttype *)
                     END;

      PModAnchor=    POINTER TO ModAnchor;
      ModAnchor=     RECORD (SymElem.SymElement)  
                        key4      : LONGINT;
                        modulName : ARRAY 40 OF CHAR;
                        moduleNo  : INTEGER;
                      END;       
                               
      PVariable =     POINTER TO Variable;
      Variable =      RECORD (SymElem.SymElement)
                        varKind : INTEGER;         (* varSy, rVarSy, fldSy, rFldSy *)
                        varType : INTEGER;         (* typeTable index              *)
                        offset  : LONGINT;
                        name    : ARRAY 40 OF CHAR;
                      END;     
             
      PParameter=     POINTER TO Parameter;
      Parameter =     RECORD (SymElem.SymElement) 
                        kind : INTEGER;            (* valParSy, varParSy, rovarParSy *)
                        ref1 : INTEGER;            (* typeTable index    *)
                        name : ARRAY 40 OF CHAR;
                      END;  
   
      PParameterList= POINTER TO ParameterList;
      ParameterList = RECORD (SymElem.SymElement)
                        parameter : POINTER TO SymElem.SymElement;
                        procedure : POINTER TO SymElem.SymElement;
                      END;

      PProcedure=     POINTER TO Procedure;
      Procedure =     RECORD (BasicProc)
                        procNo : LONGINT;
                      END;
  
      PTProcedure=    POINTER TO TProcedure;
      TProcedure =    RECORD (BasicProc)
                        recRef1  : INTEGER;          (* typeTable Index of the bounding type *)
                        methno1  : INTEGER;          (* methTable Index *)
                        procNo1  : INTEGER;   
                      END;

      PWProcedure=    POINTER TO WProcedure;
      WProcedure =    RECORD (BasicProc)
                        procNo1 : LONGINT;
                      END;
 
      PCDECLProcedure=POINTER TO CDECLProcedure;
      CDECLProcedure =RECORD (BasicProc)
                        procNo1 : LONGINT;
                      END;
 
      PCProcedure=    POINTER TO CProcedure;
      CProcedure =    RECORD (BasicProc)
                        len1 : INTEGER;               (* obj. code length              *)
                        code : ARRAY 255 OF CHAR;     (* obj.code  buffer              *)
                      END;       
            
      PProcType*=     POINTER TO ProcType;
      ProcType* =     RECORD (BasicType)
                        resultRef1 : INTEGER;         (* typeTable index of resultType *)
            parList    : SymElem.PSymElement;
            typeRef-   : INTEGER;
                      END;

      PArray*=        POINTER TO Array;
      Array* =        RECORD (BasicType)
                        elemRef1 : INTEGER;            (* typeTable index of elements *)
                        count    : LONGINT;
                      END;

      PDynArray=      POINTER TO DynArray;
      DynArray =      RECORD (BasicType)
                        elemRef1 : INTEGER;            (* typeTable index of elements *)
                        lenOff   : LONGINT;            
                      END;

      PPointer=       POINTER TO Pointer;
      Pointer =       RECORD (BasicType)
                        baseRef1 : INTEGER;            (* typeTable index (PointerType) *)
                      END;

      PRecord* =      POINTER TO Record;
      Record* =       RECORD (BasicType)
                        baseRef1 : INTEGER;            (* indicates the base type of a class *)
                        descAdr  : LONGINT;
                        count    : LONGINT;
                        fieldList: SymElem.PSymElement;
                      END;

      PFieldList=     POINTER TO FieldList;
      FieldList =     RECORD (SymElem.SymElement)
                        field : POINTER TO SymElem.SymElement;
                        record: POINTER TO SymElem.SymElement;
                      END;

      PHdPtrOffset=   POINTER TO HdPtrOffset;           (*  ??? *)
      HdPtrOffset =   RECORD (SymElem.SymElement)
                        kind  : INTEGER;
                        offset: LONGINT;
                      END;

      PHdtProc=       POINTER TO HdtProc;               (*  ??? *)
      HdtProc =       RECORD (SymElem.SymElement)
                        recRef1 : INTEGER;
                        methNo1 : INTEGER;
                        procNo1 : INTEGER;
                      END;

      PNmeth=         POINTER TO Nmeth;
      Nmeth =         RECORD (SymElem.SymElement)
                        recRef1  : INTEGER;
                        nofmeth1 : INTEGER;
                      END;

      PFix=           POINTER TO Fix;
      Fix =           RECORD (SymElem.SymElement)
                        ptrRef1 : INTEGER;
                        baseRef1: INTEGER;
                      END;

      PSys=           POINTER TO Sys;
      Sys =           RECORD (SymElem.SymElement)
                        ref1 : INTEGER;
                        sysflag: INTEGER;
                      END;

      PType* =        POINTER TO Type;
      Type*  =        RECORD (BasicType)
                      END;      

VAR sym*          : POINTER TO SymElem.SymElement;
    version32Bit* : BOOLEAN;               (* TRUE for 32 bit format *)
    version*      : LONGINT;

    moduleNo      : INTEGER;
    typeTable-    : ARRAY 4096 OF PBasicType;
    pointerTable  : ARRAY 4096 OF PPointer;
    sysTypeTable  : ARRAY 4096 OF INTEGER;  (* TRUE-WindowsType = 1 (no alignment) *)
    typeCount     : INTEGER;

    modulName-    : ARRAY 80 OF CHAR;
    lastRecRef    : INTEGER;               (* enables the insertion of a line between two   *)
                                           (* functions bounded to different types          *)
    lastRef1      : INTEGER;               (* indicates the spix of the last type from file *)
                                           (* consider the Display-methode of Type          *)
    moduleCount   : INTEGER;
    
                      
PROCEDURE Element*();
VAR
  modanchor : PModAnchor;
  type      : PType;
  variable  : PVariable;
  parameter : PParameter;
  procedure : PProcedure;
  tprocedure: PTProcedure;
  cprocedure: PCProcedure;
  wprocedure: PWProcedure;
  cdeclprocedure: PCDECLProcedure;
  procType  : PProcType;
  paramList : PParameterList;
  array     : PArray;
  dynArray  : PDynArray;
  pointer   : PPointer;
  record    : PRecord;
  fieldlist : PFieldList;
  hdPtrOffs : PHdPtrOffset;
  hdtProc   : PHdtProc;
  nmeth     : PNmeth;
  fix       : PFix;
  sys       : PSys;
  const     : Constant.PConstant;

  symHelp   : SymElem.PSymElement;
BEGIN
  CASE SymFile.sy OF
    Symbol.modSy: NEW(modanchor); symHelp := modanchor;
   |Symbol.conSy: NEW(const)    ; symHelp := const;
   |Symbol.typeSy, Symbol.hdTypeSy:NEW(type); symHelp := type;
   |Symbol.varSy,
    Symbol.fldSy,
    Symbol.rvarSy,
    Symbol.rfldSy: NEW(variable); symHelp := variable;
   |Symbol.plistSy: NEW(paramList); symHelp := paramList;
   |Symbol.ptrSy: NEW(pointer); symHelp := pointer;
   |Symbol.arrSy: NEW(array); symHelp := array;
   |Symbol.darrSy:NEW(dynArray); symHelp := dynArray;
   |Symbol.flistSy:NEW(fieldlist); symHelp := fieldlist;
   |Symbol.hdptrSy,Symbol.hdprocSy: NEW(hdPtrOffs); symHelp := hdPtrOffs;
   |Symbol.hdtprocSy: NEW(hdtProc); symHelp := hdtProc;
   |Symbol.nmethSy: NEW(nmeth); symHelp := nmeth;
   |Symbol.fixSy: NEW(fix); symHelp := fix;
   |Symbol.sysSy: NEW(sys); symHelp := sys;
   |Symbol.varParSy, Symbol.valParSy, Symbol.rovarParSy, Symbol.stvarParSy: NEW(parameter); symHelp := parameter;
  ELSE
    Display.WriteStr('Symbol ');
    Display.WriteInt(SymFile.sy, 3);
    Display.WriteStr(' does not match - internal Browser Error');

    Display.WriteStr(', offset ');
    Display.WriteInt(BasicIn.size,0);
    Display.WriteLn;
    sym := NIL;
    RETURN;
  END;
  symHelp.symID:= SymFile.sy;
  symHelp.next := NIL;
  symHelp.ReadSymInformation();
  sym := symHelp;
END Element;

PROCEDURE GetNameOfModule(VAR name: ARRAY OF CHAR; modNo: INTEGER);
VAR
  mod : SymElem.PSymElement;
  i   : INTEGER;
BEGIN
  SymLists.moduleList.ResetRider();
  mod := SymLists.moduleList.Next();
  ASSERT ((mod = NIL) OR (mod IS PModAnchor));
  WHILE (mod # NIL) & (mod(PModAnchor).moduleNo # modNo) DO
    mod := SymLists.moduleList.Next();
    ASSERT ((mod = NIL) OR (mod IS PModAnchor));
  END;
  IF mod # NIL THEN
    i := 0;
    name[i] := mod(PModAnchor).modulName[i];
    WHILE name[i] # CHR(0) DO
      i := i + 1;
      name[i] := mod(PModAnchor).modulName[i];
    END;
  ELSE
    name[0] := CHR(0);
  END;
END GetNameOfModule;

(************************************* BASIC_TYPE ***************************************)
PROCEDURE (self: PBasicType) DisplaySymStructure*();
(* Displays the >structure< and not the name of a type *)
BEGIN
END DisplaySymStructure;

PROCEDURE (self: PBasicType) DisplaySymName*();  (* defines standard-behaviour *)
(* Displays the typename, if there is no name defined, the structure will be
   displayed instead *)
BEGIN
  IF self.name[0] # CHR(0) THEN
    Display.WriteStr(self.name);
  ELSE
    self.DisplaySymStructure();
  END;
END DisplaySymName;

PROCEDURE (self:PBasicType) ReadSymInformation*();
BEGIN
  self.name[0] := CHR(0);
  self.ReadSymInformation^();
END ReadSymInformation;

PROCEDURE (self: PBasicType) DisplaySymInformation*();
(* Displayes a typical type declaration by the use of the name and the type-structure,
   nothing is done if there is no name defined *)
BEGIN
  IF self.name[0] # CHR(0) THEN
    Display.WriteStr('  ');
    self.DisplaySymName();
    Display.WriteStr(' = ');
    self.DisplaySymStructure();
  END;
END DisplaySymInformation;

(************************************ BasicProc *****************************************)
PROCEDURE (self: PBasicProc) DisplaySymInformation*();
VAR
  help: SymElem.PSymElement;
BEGIN
  help := self.parList;
  Display.WriteStr(self.name);
  Display.WriteStr(' (');
  WHILE help # NIL DO
    help.DisplaySymInformation();
    help := help.next;
    IF help # NIL THEN Display.WriteStr(';'); END;
  END;
  Display.WriteStr(')');
  IF self.ref1 # Symbol.noTypSy THEN
    Display.WriteStr(':');
    typeTable[self.ref1].DisplaySymName;
  END;
  Display.WriteStr(';');
  Display.WriteLn();
END DisplaySymInformation;

(************************************ HdPtrOffset ***************************************)
PROCEDURE (self: PHdPtrOffset) ReadSymInformation*();
BEGIN
  self.kind   := SymFile.sy;
  self.offset := SymFile.ReadLongInt();
  SymLists.hdPtrOffsList.Add(self);
END ReadSymInformation;

(************************************* HdtProc ******************************************)
PROCEDURE (self: PHdtProc) ReadSymInformation*();
BEGIN
  self.recRef1 := SymFile.ReadInt();
  self.methNo1 := SymFile.ReadInt();
  self.procNo1 := SymFile.ReadInt();
  SymLists.hdtProcList.Add(self);
END ReadSymInformation;

(*************************************** Nmeth *******************************************)
PROCEDURE (self: PNmeth) ReadSymInformation*();
BEGIN
  self.recRef1 := SymFile.ReadInt();
  self.nofmeth1:= SymFile.ReadInt();
  SymLists.nmethList.Add(self);  
END ReadSymInformation;

(**************************************** Fix ********************************************)
PROCEDURE (self: PFix) ReadSymInformation*();
BEGIN
  self.ptrRef1 := SymFile.ReadInt();
  self.baseRef1:= SymFile.ReadInt();
  pointerTable[self.ptrRef1].baseRef1 := self.baseRef1;
  SymLists.fixList.Add(self);
END ReadSymInformation;

(**************************************** Sys ********************************************)
PROCEDURE (self: PSys) ReadSymInformation*();
BEGIN
  self.ref1 := SymFile.ReadInt();
  self.sysflag := SymFile.ReadByte();
  sysTypeTable[self.ref1] := self.sysflag;
  SymLists.sysList.Add(self);
END ReadSymInformation;

(*********************************** FieldList ****************************************)
PROCEDURE (self: PFieldList) ReadSymInformation*();
VAR
  element,help : POINTER TO SymElem.SymElement;
  rec          : POINTER TO Record;
BEGIN
  self.field := NIL;
  SymFile.NewSym();
  WHILE SymFile.success & (SymFile.sy # Symbol.recSy) & (SymFile.sy # Symbol.eofSy) DO
    Element();
    element := sym;
    IF element = NIL THEN 
      SymFile.success := FALSE;
      RETURN;
    END;
   (* IF ~(element IS PType) & ~(element IS PFieldList) &
       ~(element IS PArray) & ~(element IS PParameterList) THEN  (* do not include Typedefs into this list *)*)
    IF (element IS PVariable) THEN
      IF self.field = NIL THEN
        self.field := element;
        help       := element;
      ELSE
        help.next := element;
        help := help.next;
      END;
    END;
    SymFile.NewSym();
  END;  
  IF SymFile.sy # Symbol.recSy THEN
    SymFile.success := FALSE;
    RETURN;
  ELSE
    NEW(rec);
    rec.fieldList := self;
    self.record := rec;
    self.record.ReadSymInformation();
  END;
  IF (self.record(PRecord).modNo = 0) OR SymFile.allMod THEN
    SymLists.fieldListList.Add(self);
  END;
END ReadSymInformation;
    
PROCEDURE (self: PFieldList) DisplaySymInformation*();
VAR help : POINTER TO SymElem.SymElement;
BEGIN
  help := self.field;
  WHILE help # NIL DO
    help.DisplaySymInformation();
    help := help.next;
  END; 
END DisplaySymInformation;

(**************************************** Record ******************************************)
PROCEDURE (self: PRecord) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.baseRef1 := SymFile.ReadInt();
  self.modNo    := SymFile.ReadByte();
  self.size     := SymFile.ReadLongInt();
  IF version32Bit THEN
    self.descAdr  := SymFile.ReadLongInt();
  ELSE
    self.descAdr  := SymFile.ReadInt();
  END;
  self.ownRef   := typeCount;
  typeTable[self.ownRef] := self;  (* for ARRAY-size calculations *)
  typeCount := typeCount + 1;
END ReadSymInformation;

PROCEDURE (self: PRecord) PrepareSymElement*();
BEGIN
  IF (self.name[0] # CHR(0)) & ((self.modNo = 0) OR SymFile.allMod) THEN
    SymLists.recordList.Add(self);
  END;
END PrepareSymElement;

PROCEDURE (self: PRecord) DisplaySymStructure*();
BEGIN
  Display.WriteStr('RECORD');
  IF self.baseRef1 # Symbol.noTypSy THEN
    Display.WriteStr('(');
    Display.WriteStr(typeTable[self.baseRef1].name);
    Display.WriteStr(')');
  END;
  IF version32Bit THEN
    IF sysTypeTable[self.ownRef] = 1 THEN
      Display.WriteStr(' [_APICALL]');
    ELSIF sysTypeTable[self.ownRef] = 2 THEN
      Display.WriteStr(' [_CDECL]');
    ELSIF sysTypeTable[self.ownRef] = 3 THEN
      Display.WriteStr(' [_NOTALIGNED]');
    ELSE
      IF sysTypeTable[self.ownRef] # 0 THEN
        Display.WriteStr(' [SYSTEM]');
      END;
    END;
  ELSE
    IF sysTypeTable[self.ownRef] = 1 THEN
      Display.WriteStr(' [WINDOWS]');
    ELSE
      IF sysTypeTable[self.ownRef] # 0 THEN
        Display.WriteStr(' [SYSTEM]');
      END;
    END;
  END;
  IF SymFile.debug THEN
    Display.WriteStr('   (*'); 
    Display.WriteStr(' modNo = ');   Display.WriteInt(self.modNo ,0);
    Display.WriteStr(', size = ');    Display.WriteInt(self.size, 0);
    Display.WriteStr(', descAdr = '); Display.WriteInt(self.descAdr, 0);
    Display.WriteStr(' *)');
  END;
  Display.WriteLn();
  self.fieldList.DisplaySymInformation();
  Display.WriteStr('  END');
END DisplaySymStructure;

PROCEDURE (self: PRecord) DisplaySymInformation*();
BEGIN
  self.DisplaySymInformation^();
  Display.WriteStr(';');
  Display.WriteLn();
END DisplaySymInformation;

(************************************** PointerType ******************************************)
PROCEDURE (self: PPointer) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.baseRef1 := SymFile.ReadInt();
  self.modNo    := SymFile.ReadByte();
  self.ownRef   := typeCount;
  self.size     := 4;
  pointerTable[self.ownRef] := self;
  typeTable[self.ownRef] := self; (* for a fix-up by "Fix" *)
  typeCount     := typeCount + 1; (* New Type ! *)
END ReadSymInformation;

PROCEDURE (self: PPointer) PrepareSymElement*();
BEGIN
  IF (self.name[0] # CHR(0)) & ((self.modNo  = 0) OR SymFile.allMod) THEN
    SymLists.pointerList.Add(self);
  END;
END PrepareSymElement;

PROCEDURE (self: PPointer) DisplaySymStructure*();
BEGIN
  Display.WriteStr('POINTER TO ');
  typeTable[self.baseRef1].DisplaySymName();
END DisplaySymStructure;

PROCEDURE (self: PPointer) DisplaySymInformation*();
BEGIN
  self.DisplaySymInformation^();
  Display.WriteStr(';');
  Display.WriteLn();
END DisplaySymInformation; 

(**************************************** Array **********************************************)
PROCEDURE (self: PArray) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.elemRef1 := SymFile.ReadInt();     
  self.modNo    := SymFile.ReadByte();
  self.size     := SymFile.ReadLongInt();
  self.ownRef   := typeCount;
  IF typeTable[self.ownRef] # NIL THEN
    self.name := typeTable[self.ownRef].name;
  END;
  typeTable[self.ownRef] := self;
  typeCount := typeCount + 1;
END ReadSymInformation;

PROCEDURE (self: PArray) PrepareSymElement*();
VAR
  byte : INTEGER;
BEGIN
  byte := SHORT(typeTable[self.elemRef1].size);
  self.count := self.size DIV byte;
  IF (self.name[0]#CHR(0)) & ((self.modNo  = 0) OR SymFile.allMod) THEN
    SymLists.arrayList.Add(self);
  END;
END PrepareSymElement;

PROCEDURE (self: PArray) DisplaySymStructure*();
BEGIN
  Display.WriteStr('ARRAY ');
  IF version32Bit THEN
    IF sysTypeTable[self.ownRef] = 1 THEN
      Display.WriteStr(' [_APICALL]');
    ELSIF sysTypeTable[self.ownRef] = 2 THEN
      Display.WriteStr(' [_CDECL]');
    ELSIF sysTypeTable[self.ownRef] = 3 THEN
      Display.WriteStr(' [_NOTALIGNED]');
    ELSE
      IF sysTypeTable[self.ownRef] # 0 THEN
        Display.WriteStr(' [SYSTEM]');
      END;
    END;
  ELSE
    IF sysTypeTable[self.ownRef] = 1 THEN
      Display.WriteStr(' [WINDOWS]');
    ELSE
      IF sysTypeTable[self.ownRef] # 0 THEN
        Display.WriteStr(' [SYSTEM]');
      END;
    END;
  END;
  Display.WriteInt(self.count, 0);
  Display.WriteStr(' OF ');
  typeTable[self.elemRef1].DisplaySymName();
END DisplaySymStructure;

PROCEDURE (self: PArray) DisplaySymInformation*();
BEGIN
  self.DisplaySymInformation^();
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* ModNo = ');Display.WriteInt(self.modNo,0);
    Display.WriteStr(', Size = '); Display.WriteInt(self.size,0);Display.WriteStr(' *)');
  END;
  Display.WriteLn();
END DisplaySymInformation;

(************************************** DynArray ******************************************)
PROCEDURE (self: PDynArray) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.elemRef1 := SymFile.ReadInt();
  self.modNo    := SymFile.ReadByte();
  self.size     := SymFile.ReadLongInt();
  self.lenOff   := SymFile.ReadInt();
  self.ownRef   := typeCount;
  typeCount     := typeCount+1;
  SymLists.dynArrayList.Add(self);
  typeTable[self.ownRef] := self;
END ReadSymInformation;                

PROCEDURE (self: PDynArray) DisplaySymStructure*();
BEGIN
  Display.WriteStr('ARRAY OF ');
  typeTable[self.elemRef1].DisplaySymName();
END DisplaySymStructure;

(*********************************** ParameterList ***************************************)
PROCEDURE (self: PParameterList) ReadSymInformation*();
VAR
  element   : POINTER TO SymElem.SymElement;
  help      : POINTER TO SymElem.SymElement;
  proc      : POINTER TO Procedure;
  wproc     : POINTER TO WProcedure;
  cdeclproc : POINTER TO CDECLProcedure;
  tproc     : POINTER TO TProcedure;
  cproc     : POINTER TO CProcedure;
  procTyp   : POINTER TO ProcType;
BEGIN
  SymFile.NewSym;
  self.parameter := NIL;
  WHILE (SymFile.sy # Symbol.xproSy) &
        (SymFile.sy # Symbol.iproSy) &
        (SymFile.sy # Symbol.tproSy) &
        (SymFile.sy # Symbol.cproSy) &
        (SymFile.sy # Symbol.procSy) &
        (SymFile.sy # Symbol.wproSy) &
        (SymFile.sy # Symbol.cdeclproSy) &
        (SymFile.sy # Symbol.eofSy) DO
    Element();
    element := sym;
    IF element = NIL THEN RETURN; END;
    element.next := NIL;
    IF element IS PParameter THEN
      IF self.parameter = NIL THEN
        self.parameter := element;
        help := element;
      ELSE
        help.next := element;
        help      := help.next;
      END;
    END;
    SymFile.NewSym();
  END;
  IF ~SymFile.success THEN RETURN; END;
  CASE SymFile.sy OF
    Symbol.xproSy, Symbol.iproSy : NEW(proc);      self.procedure := proc;proc.parList := self.parameter;
   |Symbol.tproSy                : NEW(tproc);     self.procedure := tproc;tproc.parList := self.parameter;
   |Symbol.cproSy                : NEW(cproc);     self.procedure := cproc;cproc.parList := self.parameter;
   |Symbol.procSy                : NEW(procTyp);   self.procedure := procTyp;procTyp.parList := self.parameter;
   |Symbol.wproSy                : NEW(wproc);     self.procedure := wproc;wproc.parList := self.parameter;
   |Symbol.cdeclproSy            : NEW(cdeclproc); self.procedure := cdeclproc;cdeclproc.parList := self.parameter;
  ELSE
    SymFile.success := FALSE;
    RETURN;
  END;
  self.procedure.ReadSymInformation();
  SymLists.paramListList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PParameterList) DisplaySymInformation*();
BEGIN
  self.procedure.DisplaySymInformation();
END DisplaySymInformation;     

(*************************************** CProcedure ****************************************)                   
PROCEDURE (self: PCProcedure) ReadSymInformation*();
VAR
  i : INTEGER;
BEGIN
  self.ref1 := SymFile.ReadInt();
  self.len1 := SymFile.ReadByte(); 
  FOR i:=1 TO self.len1 DO
    self.code[i-1] := SymFile.ReadChar();
  END;
  SymFile.ReadString(self.name);
  SymLists.cprocedureList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PCProcedure) DisplaySymInformation*();
BEGIN
  Display.WriteStr('PROCEDURE ');
  self.DisplaySymInformation^();
  IF SymFile.debug THEN
    Display.WriteStr('   (* CProc: CodeLen = '); Display.WriteInt(self.len1,0); Display.WriteStr(' *)');
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** WProcedure **************************************)                  
PROCEDURE (self: PWProcedure) ReadSymInformation*();
BEGIN
  self.ref1    := SymFile.ReadInt();
  IF version32Bit THEN
    self.procNo1 := SymFile.ReadLongInt();
  ELSE
    self.procNo1 := SymFile.ReadInt();
  END;
  SymFile.ReadString(self.name);
  SymLists.wprocedureList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PWProcedure) DisplaySymInformation*();
BEGIN
  IF version32Bit THEN
     Display.WriteStr('PROCEDURE [_APICALL] ');
  ELSE
     Display.WriteStr('PROCEDURE [WINDOWS] ');
  END;
  self.DisplaySymInformation^();
  IF SymFile.debug THEN
    Display.WriteStr('   (* Windows-Proc: ProcNo = '); Display.WriteInt(self.procNo1,0); Display.WriteStr(' *)'); 
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** CDECLProcedure ***********************************)                  
PROCEDURE (self: PCDECLProcedure) ReadSymInformation*();
BEGIN
  self.ref1    := SymFile.ReadInt();
  IF version32Bit THEN
    self.procNo1 := SymFile.ReadLongInt();
  ELSE
    self.procNo1 := SymFile.ReadInt();
  END;
  SymFile.ReadString(self.name);
  SymLists.cdeclprocedureList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PCDECLProcedure) DisplaySymInformation*();
BEGIN
  IF version32Bit THEN
     Display.WriteStr('PROCEDURE [_CDECL] ');
  ELSE
     Display.WriteStr('PROCEDURE [CDECL] ');
  END;
  self.DisplaySymInformation^();
  IF SymFile.debug THEN
    Display.WriteStr('   (* CDECL-Proc: ProcNo = '); Display.WriteInt(self.procNo1,0); Display.WriteStr(' *)'); 
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** TProcedure ***************************************)
PROCEDURE (self: PTProcedure) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.ref1    := SymFile.ReadInt();
  self.recRef1 := SymFile.ReadInt();
  self.methno1 := SymFile.ReadInt();
  self.procNo1 := SymFile.ReadInt();
  SymFile.ReadString(self.name);
END ReadSymInformation;

PROCEDURE (self: PTProcedure) PrepareSymElement*();
BEGIN
  IF (typeTable[self.recRef1](PRecord).modNo = 0) OR SymFile.allMod THEN
    SymLists.tprocedureList.Add(self);
  END; 
END PrepareSymElement;

PROCEDURE (self: PTProcedure) DisplaySymInformation*();
VAR
  help : SymElem.PSymElement;
BEGIN
  IF lastRecRef = -1 THEN
    lastRecRef := self.recRef1;
  ELSE IF lastRecRef # self.recRef1 THEN
         lastRecRef := self.recRef1;
         Display.WriteLn();
       END;
  END;

  help := self.parList;
  Display.WriteStr('PROCEDURE ');
  Display.WriteStr('(');
  help.DisplaySymInformation();
  Display.WriteStr(') ');   
  self.parList := self.parList.next;
  self.DisplaySymInformation^();
  self.parList := help;
  IF SymFile.debug THEN
    Display.WriteStr('   (* BoundedProc: MethNo = ');Display.WriteInt(self.methno1,0);
    Display.WriteStr(', ProcNo = '); Display.WriteInt(self.procNo1,0); 
    Display.WriteStr(' *)');
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** Procedure ***************************************)
PROCEDURE (self: PProcedure) ReadSymInformation*();
BEGIN
  self.ref1   := SymFile.ReadInt();
  IF version32Bit THEN
    self.procNo := SymFile.ReadLongInt();
  ELSE
    self.procNo := SymFile.ReadInt();
  END;
  SymFile.ReadString(self.name);
  IF (self.symID # Symbol.xproSy) OR SymFile.allMod THEN
    SymLists.procedureList.Add(self);
  END;
END ReadSymInformation;

PROCEDURE (self: PProcedure) DisplaySymInformation*();
BEGIN
  Display.WriteStr('PROCEDURE ');
  self.DisplaySymInformation^();
  IF SymFile.debug THEN
    Display.WriteStr('   (* Proc: ProcNo = '); 
    Display.WriteInt(self.procNo,0); Display.WriteStr(' *)');
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** ProcType ****************************************)
PROCEDURE (self: PProcType) ReadSymInformation*();
BEGIN
  self.ReadSymInformation^();
  self.resultRef1 := SymFile.ReadInt();
  self.modNo      := SymFile.ReadByte();
  self.ownRef     := typeCount;
  IF typeTable[self.ownRef] = NIL THEN
    typeTable[self.ownRef] := self;
  ELSE
    self.name := typeTable[self.ownRef].name;
    typeTable[self.ownRef] := self;
  END;
  typeCount := typeCount + 1;
END ReadSymInformation;

PROCEDURE (self: PProcType) PrepareSymElement*();
BEGIN
  IF self.name[0] # CHR(0) THEN
    IF (self.modNo = 0) OR (SymFile.allMod) THEN
      SymLists.procTypeList.Add(self);
    END;
  END;
END PrepareSymElement;

PROCEDURE (self: PProcType) DisplaySymStructure*();
VAR
  help : SymElem.PSymElement;
  str  : ARRAY 25 OF CHAR;
BEGIN
  help := self.parList;
  IF sysTypeTable[self.ownRef] = 0 THEN
    Display.WriteStr('PROCEDURE (');
  ELSE
    Display.WriteStr('PROCEDURE [WINDOWS] (');
  END;
  WHILE help # NIL DO
    help.DisplaySymInformation();
    help := help.next;
    IF help # NIL THEN Display.WriteStr(';'); END;
  END;
  Display.WriteStr(')');
  IF self.resultRef1 # Symbol.noTypSy THEN
    Display.WriteStr(':');
    typeTable[self.resultRef1].DisplaySymName();
  END;
END DisplaySymStructure;

PROCEDURE (self: PProcType) DisplaySymInformation*();
BEGIN
  self.DisplaySymInformation^();
  Display.WriteStr(';');
  Display.WriteLn();
  IF SymFile.debug THEN
    Display.WriteStr('    (* ProcType: modulNo = '); Display.WriteInt(self.modNo,0); Display.WriteStr(' *)');
    Display.WriteLn();
  END;
END DisplaySymInformation;

(************************************** Parameter ***************************************)               
PROCEDURE (self: PParameter) ReadSymInformation*();
BEGIN
  self.kind := SymFile.sy;
  self.ref1 := SymFile.ReadInt();
  SymFile.ReadString(self.name);
  SymLists.parameterList.Add(self);
END ReadSymInformation;

PROCEDURE (self: PParameter) DisplaySymInformation*();
BEGIN
  IF (self.kind = Symbol.varParSy) OR (self.kind = Symbol.rovarParSy) THEN
    Display.WriteStr('VAR ');
  END;
  IF (self.kind = Symbol.stvarParSy) THEN
    Display.WriteStr('VAR STATICTYPED ');
  END;
  Display.WriteStr(self.name);
  IF self.kind = Symbol.rovarParSy THEN
     Display.WriteStr('-');
  END;
  Display.WriteStr(':'); typeTable[self.ref1].DisplaySymName;
END DisplaySymInformation;

(************************************** Variable ****************************************)
PROCEDURE (self:PVariable) ReadSymInformation*();
BEGIN
  self.varKind := SymFile.sy;
  self.varType := SymFile.ReadInt();
  self.offset  := SymFile.ReadLongInt();
  SymFile.ReadString(self.name);
  (* Only true module-variables are accepted *)
  IF (self.varKind = Symbol.varSy) OR (self.varKind = Symbol.rvarSy) THEN
    SymLists.variableList.Add(self);
  END;
END ReadSymInformation;

PROCEDURE (self:PVariable) DisplaySymInformation*();
BEGIN
  CASE self.varKind OF
    Symbol.varSy: Display.WriteStr('  ');
   |Symbol.fldSy: Display.WriteStr('    ');
   |Symbol.rvarSy:Display.WriteStr('  ');
  ELSE
    Display.WriteStr('    ');  (* rfldSy *)
  END; 
  Display.WriteStr(self.name);
  CASE self.varKind OF
    Symbol.varSy, Symbol.fldSy: Display.WriteStr('*');
  ELSE 
    Display.WriteStr('-');
  END;
  Display.WriteStr(' : ');typeTable[self.varType].DisplaySymName();
  Display.WriteStr(';');
  IF SymFile.debug THEN
    Display.WriteStr(' (* offset: ');
    Display.WriteInt(self.offset, 0);
    Display.WriteStr(' *)');
  END;
  Display.WriteLn();
END DisplaySymInformation;

(******************************************* TYPE ***************************************)
PROCEDURE (self:PType) ReadSymInformation*();
VAR
  str: ARRAY 80 OF CHAR;
BEGIN
  self.ReadSymInformation^();
  self.ownRef  := SymFile.ReadInt();
  self.modNo   := SymFile.ReadByte();
  SymFile.ReadString(self.name);
  IF self.modNo # 0 THEN
    GetNameOfModule(str, self.modNo);
    Strings.Append(str, '.');
    Strings.Insert(str, self.name, 0);
  END;
  IF typeTable[self.ownRef] = NIL THEN
    typeTable[self.ownRef] := self;
  ELSE 
    IF (typeTable[self.ownRef].name[0] = 0X) & (self.ownRef > 12) THEN
      typeTable[self.ownRef].name    := self.name;
    END;
  END;
END ReadSymInformation;

PROCEDURE (self:PType) PrepareSymElement*();
BEGIN
  IF self.symID # Symbol.hdTypeSy THEN
    IF (self.modNo = 0) OR SymFile.allMod THEN
      IF self.name # typeTable[self.ownRef].name THEN
        SymLists.typeList.Add(self);
      END;
    END;
  END; 
END PrepareSymElement;

PROCEDURE (self:PType) DisplaySymInformation*();
BEGIN
  Display.WriteStr('  ');
  self.DisplaySymName();
  Display.WriteStr(' = ');
  typeTable[self.ownRef].DisplaySymName();
  IF SymFile.debug THEN
    Display.WriteStr(' (* Modul No.: ');Display.WriteInt(self.modNo,0);Display.WriteStr(' *)');
  END;
  Display.WriteLn();
END DisplaySymInformation;

(*************************************** MODULE-Anchor **********************************)
PROCEDURE (self:PModAnchor) ReadSymInformation*();
VAR
  i : INTEGER;
BEGIN
  self.key4 := SymFile.ReadLongInt();
  SymFile.ReadString(self.modulName);
  self.moduleNo := moduleNo;
  moduleNo := moduleNo + 1;
  SymLists.moduleList.Add(self);
  IF self.moduleNo = 0 THEN
    i := 0;
    WHILE (i < 80) & (self.modulName[i] # CHR(0)) DO
      modulName[i] := self.modulName[i];
      i := i + 1;
    END;
    modulName[i] := CHR(0);
  END;
END ReadSymInformation;

PROCEDURE (self:PModAnchor) DisplaySymInformation*();
BEGIN
  moduleCount := moduleCount + 1;
  IF self.moduleNo = 0 THEN
    Display.WriteStr('Definitions of module ');
    Display.WriteStr(self.modulName);
    Display.WriteStr(';');
    Display.WriteLn();
    IF SymFile.debug THEN
      Display.WriteStr('(******************************************');
      Display.WriteLn();
      Display.WriteStr(' * Additional module-header information : *');
      Display.WriteLn;
      
      Display.WriteStr(' * Module-key (four bytes)   : ');
      Display.WriteInt(self.key4, 5);Display.WriteStr('      *');
      Display.WriteLn();
      
      Display.WriteStr(' * Module-No.                : ');
      Display.WriteInt(self.moduleNo, 5); Display.WriteStr('      *');
      Display.WriteLn();

      Display.WriteStr(' * Symbolfile format version : ');
      Display.WriteHex(Utils.HiWord(version));
      Display.WriteStr('-');
      Display.WriteHex(Utils.LoWord(version));
      Display.WriteStr('  *');
      Display.WriteLn();
      
      Display.WriteStr(' ******************************************)');
      Display.WriteLn();
    END;
  ELSE
    IF self.moduleNo =  1 THEN
      Display.WriteStr('IMPORT ');
    END;
    Display.WriteStr(self.modulName);
    IF SymFile.debug THEN
      Display.WriteStr('   (* Key = ');
      Display.WriteInt(self.key4, 0);
      Display.WriteStr(', ModNo = ');
      Display.WriteInt(self.moduleNo,0);
      Display.WriteStr(' *)');
      IF moduleCount # moduleNo THEN
        Display.WriteStr(',');
        Display.WriteLn();
        Display.WriteStr('       ');
      END;
    END;
    IF moduleCount = moduleNo THEN
      Display.WriteStr(';');
      Display.WriteLn();
    ELSE 
      IF ~SymFile.debug THEN
        Display.WriteStr(', ');
      END;
    END;
  END;
END DisplaySymInformation;

PROCEDURE InitMiscSym*();
VAR
  i : INTEGER;
BEGIN
  lastRef1  := 13;  (* basic types *)
  lastRecRef := -1;
  moduleNo  := 0;
  moduleCount := 0;
  typeCount := 16;

  FOR i := 0 TO 255 DO
    typeTable[i]      := NIL;
    pointerTable[i]   := NIL;
    sysTypeTable[i]   := 0;
  END;
  FOR i := 0 TO 13 DO
    NEW(typeTable[i]);
  END;

  typeTable[0].name := 'UNDEF';    
  typeTable[1].name := 'SYSTEM.BYTE';typeTable[1].size := 1;
  typeTable[2].name := 'BOOLEAN';typeTable[2].size := SIZE(BOOLEAN);
  typeTable[3].name := 'CHAR';    typeTable[3].size := SIZE(CHAR);
  typeTable[4].name := 'SHORTINT';typeTable[4].size := 1;
  typeTable[5].name := 'INTEGER'; typeTable[5].size := SIZE(INTEGER);
  typeTable[6].name := 'LONGINT'; typeTable[6].size := SIZE(LONGINT);
  typeTable[7].name := 'REAL';    typeTable[7].size := SIZE(REAL);
  typeTable[8].name := 'LONGREAL';typeTable[8].size := SIZE(LONGREAL);
  typeTable[9].name := 'SET';     typeTable[9].size := SIZE(SET);
  typeTable[10].name:= 'STRING';
  typeTable[11].name:= 'NIL';     typeTable[11].size := 4;
  typeTable[12].name:= 'NOTYP';
  typeTable[13].name:= 'SYSTEM.PTR';  typeTable[13].size := SIZE(SYSTEM.PTR);

END InitMiscSym;

BEGIN
END MiscSym. 
