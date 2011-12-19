MODULE OOBase;
(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  06-25-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
   This module defines a base class from which all other classes
   in a class hierarchy should be directly or indirectly derived.
   
   In addition to that several functions are provided which work
   on all objects of a class derived from ObjectT. They extend the
   object oriented programming power of the language and could not
   easily be written by an application programmer.
   Those functions make it possible to get the symbolic type name
   of a record in a string, to create an object of a certain type
   from the type name, to access record fields of a basic type using
   the symbolic name of the field, and to clone objects.
  ----------------------------------------------------------------------------*)

IMPORT SYSTEM,RTSOberon,String:=Strings,WD:=WinDef,WU:=WinUser,WB:=WinBase;

CONST
  TYP_ARRAY*    =100H; (** \HIDE *)
  TYP_DYNARRAY* =200H; (** \HIDE *)
  TYP_RECORD*   =400H; (** \HIDE *)
  TYP_ENDRECORD*=800H; (** \HIDE *)
  TYP_UNDEF*    =  0;  (** \HIDE *)
  TYP_BYTE*     =  1;  (** \HIDE *)
  TYP_BOOL*     =  2;  (** \HIDE *)
  TYP_CHAR*     =  3;  (** \HIDE *)
  TYP_SHORTINT* =  4;  (** \HIDE *)
  TYP_INT*      =  5;  (** \HIDE *)
  TYP_LONGINT*  =  6;  (** \HIDE *)
  TYP_REAL*     =  7;  (** \HIDE *)
  TYP_LONGREAL* =  8;  (** \HIDE *)
  TYP_SET*      =  9;  (** \HIDE *)
  TYP_STRING*   = 10;  (** \HIDE *)
  TYP_NIL*      = 11;  (** \HIDE *)
  TYP_NOTYP*    = 12;  (** \HIDE *)
  TYP_POINTER*  = 13;  (** \HIDE *)
  TYP_HDPOINTER*=0F0H; (** \HIDE *)
  TYP_PROCTYP*  = 14;  (** \HIDE *)
  MAXINHERITANCE= 10;  (* maximum depth of class hierarchies; compiler limitation *)
  MAXDLL=100;          (* maximum number of DLLs which can be loaded dynamically *)

TYPE
  (**
    This class should be the base of any class hierarchy.
    This class only contains the empty method Init.
  *)
  ObjectT*=RECORD
  END;
  Object*=POINTER TO ObjectT;
  FPROC=PROCEDURE [_APICALL] (key:LONGINT);

  (** \HIDE *)
  ObjMetaToolT*=RECORD
    origTag:LONGINT; (* original type tag *)
    codeTable:LONGINT; (* address of RTTI code table *)
    curAddr:LONGINT;   (* current address in RTTI string table *)
    lastCode:INTEGER; (* stored value of look ahead symbol code *)
    tagInx:INTEGER; (* current index in type tag list of super classes *)
  END;

  (** \HIDE *)
  ObjMetaToolMarkerT*=RECORD
    codeTable:LONGINT;
    curAddr:LONGINT;
    lastCode:INTEGER;
    tagInx:INTEGER;
  END;

VAR
  dllListN:LONGINT;
  dllList:ARRAY MAXDLL OF WD.HINSTANCE;

PROCEDURE (VAR obj:ObjectT) Init*;
(** This is an abstract method. The initialization methods of all
    classes should be called Init. This makes it possible to have a general convention for object 
    creation: after allocating an object with NEW the method Init
    can be called regardless of the objects class. *)  
BEGIN
END Init;

PROCEDURE Clone*(obj:Object):Object;
(** The object passed in obj is cloned. This means that a new object of
    the same class is created, which has the same state as the original
    object.
    
    The same state has to be taken literal: if the original object contains
    any pointers to other objects, which should by design be private,
    the new object will contain pointers to the same objects and not
    possess new private copies of those.
    
    The return value is either a pointer to the cloned object or NIL if the
    function failed. *)
VAR
  new,size,tag:LONGINT;
  clone:Object;
BEGIN
  RTSOberon.GetObjSize(SYSTEM.VAL(LONGINT,obj),size);
  RTSOberon.GetObjType(SYSTEM.VAL(LONGINT,obj),tag); 
  RTSOberon.New(tag,size,new);
  IF new#0 THEN
    clone:=SYSTEM.VAL(Object,new);
    SYSTEM.MOVE(SYSTEM.VAL(LONGINT,obj),SYSTEM.VAL(LONGINT,clone),size);
  ELSE
    clone:=NIL;
  END;
  RETURN clone;
END Clone;

PROCEDURE ObjToName*(p:Object;          (** pointer to the object whose symbolic name should be determined *)
                     VAR codeName,      (** returns the full pathname of the .EXE or .DLL file containing the code of the class implementation *)
                     name:ARRAY OF CHAR (** returns the qualified class name of the object in the form moduleName.typeName *)
                    );
(** The symbolic name of an objects qualified class name and the name of its 
    code module are returned. *)
VAR
  x,typetag:LONGINT;
  modName,recName:RTSOberon.Name;
  i,j,l:LONGINT;
BEGIN
  x:=SYSTEM.VAL(LONGINT,p);
  SYSTEM.MOVE(x-4,SYSTEM.ADR(typetag),4);
  RTSOberon.TypetagToModRecName(typetag,modName,recName,codeName); 
  COPY(modName,name);
  String.AppendChar(name,".");
  String.Append(name,recName);
END ObjToName;


PROCEDURE NameToObj*(VAR codeName-,       (** the full pathname of the .EXE or .DLL file containig the implementation of the desired class *)
                     name-:ARRAY OF CHAR; (** the qualified class name in the form moduleName.className *)
                     VAR p:Object         (** returns a pointer to the object created or NIL if the call failed *)
                    );
(** A new object is created according to a given class and code module name.
    
    The code module name has to be given because the class might be 
    implemented in a DLL which has not yet been loaded and whose name
    can not be derived from the Oberon class name.
    
    In this case the top level module in the module hierarchy of the DLL
    must contain the DllEntryPoint procedure.
    
    It is possible to implement different modules with the same name
    in different DLLs. In this case it is not adviseable to use both
    DLLs in the same program. *)
VAR
  modName,recName:RTSOberon.Name;
  hCodeName:ARRAY 200 OF CHAR;
  pi,size,i,j,l,typetag:LONGINT;
  res:INTEGER;
  libInst:WD.HINSTANCE;
  t,h:ARRAY 200 OF CHAR;
  farProc:FPROC;

BEGIN
  COPY(codeName,hCodeName);
  String.UpCase(hCodeName);
  p:=NIL;
  i:=0;
  l:=LEN(modName)-1;
  IF LEN(name)<l THEN l:=LEN(name) END;
  WHILE (i<l) & (name[i]#0X) & (name[i]#".") DO modName[i]:=name[i]; INC(i) END;
  IF (i=l) OR (name[i]=0X) THEN RETURN END;
  modName[i]:=0X;
  j:=i+1;
  i:=0;
  WHILE (i<l) & (name[i+j]#0X) DO recName[i]:=name[i+j]; INC(i) END;
  recName[i]:=0X;
  RTSOberon.ModRecNameToTypetag(modName,recName,hCodeName,typetag,res); 
  IF res=0 THEN RETURN END;
  IF res=-1 THEN (* codeName not found ? -> try without path *)
    i:=String.Length(hCodeName)-1;
    WHILE (i>=0) & (hCodeName[i]#"\") DO DEC(i) END;
    IF i>=0 THEN String.Delete(hCodeName,1,i+1) END;
    RTSOberon.ModRecNameToTypetag(modName,recName,hCodeName,typetag,res);
    IF res=0 THEN RETURN END;
  END;
  IF res=-1 THEN (* codeName still not found ? -> try to load DLL *)
    libInst:=WB.LoadLibraryA(SYSTEM.ADR(hCodeName));
    String.HexStr(libInst,t);
    IF libInst<WB.HINSTANCE_ERROR THEN 
      COPY(hCodeName,t);
      String.AppendChar(t,0AX);
      String.Append(t,"could not be loaded because");
      String.AppendChar(t,0AX);
      CASE libInst OF
         0: String.Append(t,"out of memory, file corrupt or relocations invalid");
      |  2: String.Append(t,"the file could not be found");
      |  3: String.Append(t,"the path could not be found");
      |  5: String.Append(t,"of a sharing or network protection error");
      |  8: String.Append(t,"of insufficient memory");
      | 20: String.Append(t,"the DLL is corrupt");
      | 21: String.Append(t,"the module requires 32-bit extensions");
      ELSE  String.Append(t,"of an unexpected error");
      END;
      IF WU.MessageBoxA(0, SYSTEM.ADR(t), SYSTEM.ADR("Error"),
                        WU.MB_ICONEXCLAMATION + WU.MB_APPLMODAL)=0 THEN END;
      RETURN;
    ELSE
      dllList[dllListN]:=libInst;
      INC(dllListN);
    END;
    RTSOberon.ModRecNameToTypetag(modName,recName,hCodeName,typetag,res); 
    IF res#1 THEN RETURN END;
  END;
  SYSTEM.MOVE(typetag-4,SYSTEM.ADR(size),4);
  RTSOberon.New(typetag,size,pi);
  p:=SYSTEM.VAL(Object,pi);
  ASSERT(p IS Object);
END NameToObj; 

PROCEDURE TypeHasOffset*(typeCode:INTEGER):BOOLEAN;
(** \HIDE *)
(** return TRUE if the given type is accompanied by an offset in the RTTI *)
BEGIN
  RETURN (typeCode=TYP_ARRAY) OR (typeCode=TYP_DYNARRAY) OR
         (typeCode=TYP_RECORD) OR (typeCode=TYP_CHAR) OR
         (typeCode=TYP_INT) OR (typeCode=TYP_SHORTINT) OR
         (typeCode=TYP_BYTE) OR (typeCode=TYP_BOOL) OR
         (typeCode=TYP_LONGINT) OR (typeCode=TYP_REAL) OR
         (typeCode=TYP_LONGREAL) OR (typeCode=TYP_SET) OR         
         (typeCode=TYP_STRING) OR (typeCode=TYP_POINTER) OR
         (typeCode=TYP_PROCTYP) OR (typeCode=TYP_HDPOINTER);
END TypeHasOffset;

PROCEDURE TypeToName*(typeCode:INTEGER; VAR txt:ARRAY OF CHAR);
(** \HIDE *)
(** returns the symbolic name of the type given in typeCode *)
BEGIN
  IF typeCode=TYP_ARRAY THEN COPY("ARRAY",txt)
  ELSIF typeCode=TYP_DYNARRAY THEN COPY("open ARRAY",txt)
  ELSIF typeCode=TYP_RECORD THEN COPY("record",txt)
  ELSIF typeCode=TYP_ENDRECORD THEN COPY("end of record",txt)
  ELSIF typeCode=TYP_CHAR THEN COPY("CHAR",txt)
  ELSIF typeCode=TYP_INT THEN COPY("INTEGER",txt)
  ELSIF typeCode=TYP_SHORTINT THEN COPY("SHORTINT",txt)
  ELSIF typeCode=TYP_UNDEF THEN COPY("undefined",txt)
  ELSIF typeCode=TYP_BYTE THEN COPY("SYSTEM.BYTE",txt)
  ELSIF typeCode=TYP_BOOL THEN COPY("BOOLEAN",txt)
  ELSIF typeCode=TYP_LONGINT THEN COPY("LONGINT",txt)
  ELSIF typeCode=TYP_REAL THEN COPY("REAL",txt)
  ELSIF typeCode=TYP_LONGREAL THEN COPY("LONGREAL",txt)
  ELSIF typeCode=TYP_SET THEN COPY("SET",txt)
  ELSIF typeCode=TYP_STRING THEN COPY("STRING",txt)
  ELSIF typeCode=TYP_NIL THEN COPY("NIL",txt)
  ELSIF typeCode=TYP_NOTYP THEN COPY("no type",txt)
  ELSIF typeCode=TYP_POINTER THEN COPY("POINTER",txt)
  ELSIF typeCode=TYP_HDPOINTER THEN COPY("POINTER(opaque)",txt)
  ELSIF typeCode=TYP_PROCTYP THEN COPY("procedure type",txt)
  ELSE COPY("error",txt)
  END;
END TypeToName;

PROCEDURE (VAR p:ObjMetaToolT) SetToTag(VAR inx:INTEGER);
VAR
  typeTag:LONGINT;
  nCodes:INTEGER;
  ch:CHAR;
BEGIN
  IF inx<MAXINHERITANCE THEN
    SYSTEM.MOVE(p.origTag+inx*4,SYSTEM.ADR(typeTag),4);
    IF typeTag=0 THEN (* beyond last type tag in list *)
      p.codeTable:=-1;
      p.curAddr:=-1;
    ELSE
      SYSTEM.MOVE(typeTag-14,SYSTEM.ADR(nCodes),2);
      IF nCodes<0 THEN
        INC(inx); (* RTTI code table overrun! the RTTI for this type is skipped *)
        p.SetToTag(inx);
      ELSE
        p.codeTable:=typeTag-16;
        p.curAddr:=typeTag-15-nCodes*2;
        SYSTEM.GET(p.curAddr,ch);
        IF ch=0FFX THEN
          INC(inx); (* RTTI string table overrun! the RTTI for this type is skipped *)
          p.SetToTag(inx);
        END;
      END;
    END;
  ELSE
    p.codeTable:=-1;
    p.curAddr:=-1;
  END;
END SetToTag;

PROCEDURE (VAR p:ObjMetaToolT) InitToObj*(obj:Object);
(** The object meta information tool has to be initialized to
    work on a specific object prior to a call to any other
    method of this class. *)
VAR
  typeTag:LONGINT;
BEGIN
  IF obj=NIL THEN
    p.codeTable:=-1;
    p.curAddr:=-1;
    p.tagInx:=-1;
    p.origTag:=-1;
  ELSE
    SYSTEM.MOVE(SYSTEM.VAL(LONGINT,obj)-4,SYSTEM.ADR(typeTag),4);
    p.origTag:=typeTag;
    p.tagInx:=0;
    p.SetToTag(p.tagInx);
    p.lastCode:=-1;
  END;
END InitToObj;

PROCEDURE (VAR p:ObjMetaToolT) GetNextName*(VAR name:ARRAY OF CHAR; VAR table:LONGINT; VAR codeInx:INTEGER);
(** retrieve next name from RTTI string table. codeInx is set to -1 if there
    is no directly associated entry in the code table. The name contains the
    empty string if the last name has already been read. *)
VAR
  i:INTEGER;
  ch:CHAR;
  addr:LONGINT;
BEGIN
  IF p.codeTable=-1 THEN codeInx:=-1; RETURN END;
  i:=0;
  addr:=p.curAddr;
  REPEAT
    SYSTEM.GET(addr,ch);
    IF i<LEN(name)-1 THEN 
      name[i]:=ch;
      INC(i);
    END;
    DEC(addr);
  UNTIL ch=0X;
  name[i]:=0X;
  IF name="" THEN        (* end of RTTI string table ? *)
    INC(p.tagInx);
    p.SetToTag(p.tagInx); (* p.curAddr set by this call *)
    IF p.codeTable#-1 THEN 
      p.GetNextName(name,table,codeInx);
    ELSE 
      table:=-1;
      codeInx:=-1;
    END;
  ELSIF name#";" THEN
    SYSTEM.MOVE(addr-1,SYSTEM.ADR(codeInx),2); (* read inx to code table from string table *)
    DEC(addr,2);
    table:=p.codeTable;
    ASSERT(table#-1);
    p.curAddr:=addr;
  ELSE
    table:=p.codeTable;
    codeInx:=-1;
    p.curAddr:=addr;
  END;
END GetNextName;

PROCEDURE (VAR p:ObjMetaToolT) SetMarker*(VAR marker:ObjMetaToolMarkerT);
(** store the internal reader position in the marker *)
BEGIN
  marker.codeTable:=p.codeTable;
  marker.curAddr:=p.curAddr;
  marker.lastCode:=p.lastCode;
  marker.tagInx:=p.tagInx;
END SetMarker;

PROCEDURE (VAR p:ObjMetaToolT) ToMarker*(VAR marker:ObjMetaToolMarkerT);
(** Set the internal reader position to the state recorded in the given marker *)
BEGIN
  p.codeTable:=marker.codeTable;
  p.curAddr:=marker.curAddr;
  p.lastCode:=marker.lastCode;
  p.tagInx:=marker.tagInx;
END ToMarker;


PROCEDURE (VAR p:ObjMetaToolT) GetTypeEntry*(table:LONGINT; inx:INTEGER; 
                                               VAR code:INTEGER;
                                               VAR offset:LONGINT;
                                               VAR elemSize:LONGINT;
                                               VAR nofElems:LONGINT);
(** Retrieves a specific entry in the RTTI code table. Properties
    which do not apply are set to -1. *)
BEGIN
  ASSERT(table#-1);
  inx:=inx*2;
  SYSTEM.MOVE(table-inx,SYSTEM.ADR(code),2);
  IF TypeHasOffset(code) THEN
    SYSTEM.MOVE(table-inx-4,SYSTEM.ADR(offset),4);
    IF (code=TYP_ARRAY) OR (code=TYP_DYNARRAY) THEN
      SYSTEM.MOVE(table-inx-8,SYSTEM.ADR(elemSize),4);
      IF code=TYP_ARRAY THEN
        SYSTEM.MOVE(table-inx-12,SYSTEM.ADR(nofElems),4);
      ELSE
        nofElems:=-1;
      END;
    ELSE
      elemSize:=-1;
    END;
  ELSE
    offset:=-1;
    elemSize:=-1;
    nofElems:=-1;
  END;
END GetTypeEntry;

PROCEDURE (VAR p:ObjMetaToolT) GetTypePointedTo*(table:LONGINT; inx:INTEGER):INTEGER;
(** If inx is the index of a pointer entry in the code table
    the return value of the function is the type code for
    the type of the variable referenced by the pointer. *)
VAR
  h:INTEGER;
BEGIN
  SYSTEM.MOVE(table-inx*2-6,SYSTEM.ADR(h),2);
  RETURN h;
END GetTypePointedTo;
  

PROCEDURE (VAR p:ObjMetaToolT) GetNextSymbol*(VAR symName:ARRAY OF CHAR; VAR done:BOOLEAN);
(** retrieve only symbols at top level; returns an empty string if the last
    symbol has already been read. *)
VAR
  addr:LONGINT;
  code:INTEGER;
  nameSav:ARRAY 200 OF CHAR;

  PROCEDURE GetName;
  VAR
    i:INTEGER;
    ch:CHAR;
    tableInx:INTEGER;
  BEGIN
    i:=0;
    REPEAT
      SYSTEM.GET(addr,ch);
      IF i<LEN(symName)-1 THEN 
        symName[i]:=ch;
        INC(i);
      END;
      DEC(addr);
    UNTIL ch=0X;
    symName[i]:=0X;
    IF (symName#"") & (symName#";") THEN
      SYSTEM.MOVE(addr-1,SYSTEM.ADR(tableInx),2); 
      DEC(addr,2);
      SYSTEM.MOVE(p.codeTable-tableInx*2,SYSTEM.ADR(code),2);
    ELSE
      code:=TYP_UNDEF;
    END;
  END GetName;

  PROCEDURE TypePointedTo():INTEGER;
  VAR
    h:INTEGER;
    tableInx:INTEGER;
  BEGIN
    SYSTEM.MOVE(addr+1,SYSTEM.ADR(tableInx),2); 
    SYSTEM.MOVE(p.codeTable-(tableInx+3)*2,SYSTEM.ADR(h),2);
    RETURN h;
  END TypePointedTo;
  
  PROCEDURE^ ReadRec(level:INTEGER);
  
  PROCEDURE ReadSym(level:INTEGER);
  VAR
    type:INTEGER;
  BEGIN
    IF code=TYP_RECORD THEN 
      GetName;
      ReadRec(level+1);
    ELSIF code=TYP_ARRAY THEN
      GetName;
      ReadSym(level+1);
    ELSIF code=TYP_DYNARRAY THEN
      GetName;
      ReadSym(level+1);
    ELSIF code=TYP_POINTER THEN
      IF TypePointedTo()#TYP_RECORD THEN 
        GetName;
        ReadSym(level+1);
      ELSE
        GetName;
      END;
    ELSE
      GetName;
    END;
  END ReadSym;

  PROCEDURE ReadRec(level:INTEGER);
  BEGIN
    WHILE symName#";" DO
      ReadSym(level);
    END;
    GetName;
  END ReadRec;
  
BEGIN
  done:=LEN(symName)>=40; (* insert max. compiler symbol length here *)
  symName[0]:=0X;
  IF ~done THEN RETURN END;
  addr:=p.curAddr;
  IF addr#-1 THEN
    code:=p.lastCode;
    IF p.lastCode=TYP_STRING THEN p.lastCode:=TYP_ARRAY END;
    IF code=-1 THEN (* first call *)
      GetName;
    ELSE
      ReadSym(0);
    END;
    IF (symName="") OR (symName[0]=0FFX) THEN (* end of current RTTI table *)
      INC(p.tagInx);
      p.SetToTag(p.tagInx);
      IF p.codeTable=-1 THEN (* end of last RTTI table *)
        p.curAddr:=-1; 
        p.lastCode:=-1;
        symName[0]:=0X;
      ELSE
        p.GetNextSymbol(symName,done);
      END;
    ELSE
      p.lastCode:=code;
      p.curAddr:=addr;
      IF code=TYP_ARRAY THEN
        COPY(symName,nameSav);
        GetName;
        IF code=TYP_CHAR THEN  (* addr is not remembered here to read the correct offset of the array in GetSymbolInfo; this causes the rescan of the array type *)
          p.lastCode:=TYP_STRING;
        END;
        COPY(nameSav,symName); 
      END;
    END;
  ELSE
    symName[0]:=0X;
  END;
END GetNextSymbol;


PROCEDURE (VAR p:ObjMetaToolT) GetSymbolInfo*(VAR typeCode:INTEGER; VAR offs:LONGINT);
(** retrieve information about the last symbol read by GetNextSymbol;
    typeCode is -1 if call failed *)
VAR
  tableInx:INTEGER;
BEGIN
  SYSTEM.MOVE(p.curAddr+1,SYSTEM.ADR(tableInx),2); 
  SYSTEM.MOVE(p.codeTable-(tableInx+2)*2,SYSTEM.ADR(offs),4);
  typeCode:=p.lastCode;
END GetSymbolInfo;


PROCEDURE (obj:Object) GetFieldType*(VAR fieldName-:ARRAY OF CHAR; VAR typeCode:INTEGER; VAR done:BOOLEAN);
(** \HIDE *)
(** Returns the type code of a specific record field; the specified field must
    be of a basic type or an array of char in which case typeCode is set to TYP_STRING. *)
VAR
  typeC:INTEGER;
  offs:LONGINT;
  objTool:ObjMetaToolT;
  txt:ARRAY 100 OF CHAR;
BEGIN
  typeCode:=TYP_UNDEF;
  objTool.InitToObj(obj);
  REPEAT
    objTool.GetNextSymbol(txt,done);
  UNTIL (txt=fieldName) OR (txt="") OR (~done);
  IF ~done OR (txt="") THEN
    done:=FALSE;
  ELSE
    objTool.GetSymbolInfo(typeCode,offs);
    done:=TRUE;
  END;
END GetFieldType;

PROCEDURE (obj:Object) PrepFieldAccess(VAR fieldName:ARRAY OF CHAR; typeCode:INTEGER; VAR addr:LONGINT; VAR done:BOOLEAN);
(** \HIDE *)
(* get the address of a particular object member variable of a basic type;
   if a variable with the name given in fieldName is found, check whether
   it has the same type as given in typeCode. If yes, return TRUE in done
   and the address of the variable in addr. *)
VAR
  typeC:INTEGER;
  offs:LONGINT;
  objTool:ObjMetaToolT;
  txt:ARRAY 100 OF CHAR;
BEGIN
  addr:=0;
  objTool.InitToObj(obj);
  REPEAT
    objTool.GetNextSymbol(txt,done);
  UNTIL (txt=fieldName) OR (txt="") OR (~done);
  IF ~done OR (txt="") THEN
    ASSERT(done);
    HALT(0);
    done:=FALSE;
  ELSE
    objTool.GetSymbolInfo(typeC,offs);
    IF typeC=typeCode THEN
      addr:=SYSTEM.ADR(obj^)+offs;
      done:=TRUE;
    ELSE
      HALT(0);
      done:=FALSE;
    END;
  END;
END PrepFieldAccess;

PROCEDURE (obj:Object) PutIntField*(fieldName:ARRAY OF CHAR; x:INTEGER; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_INT,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutIntField;

PROCEDURE (obj:Object) GetIntField*(fieldName:ARRAY OF CHAR; VAR x:INTEGER; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_INT,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0 END;
END GetIntField;

PROCEDURE (obj:Object) PutLongIntField*(fieldName:ARRAY OF CHAR; x:LONGINT; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_LONGINT,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutLongIntField;

PROCEDURE (obj:Object) GetLongIntField*(fieldName:ARRAY OF CHAR; VAR x:LONGINT; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_LONGINT,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0 END;
END GetLongIntField;

PROCEDURE (obj:Object) PutShortIntField*(fieldName:ARRAY OF CHAR; x:SHORTINT; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_SHORTINT,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutShortIntField;

PROCEDURE (obj:Object) GetShortIntField*(fieldName:ARRAY OF CHAR; VAR x:SHORTINT; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_SHORTINT,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0 END;
END GetShortIntField;

PROCEDURE (obj:Object) PutCharField*(fieldName:ARRAY OF CHAR; x:CHAR; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_CHAR,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutCharField;

PROCEDURE (obj:Object) GetCharField*(fieldName:ARRAY OF CHAR; VAR x:CHAR; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_CHAR,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0X END;
END GetCharField;

PROCEDURE (obj:Object) PutBoolField*(fieldName:ARRAY OF CHAR; x:BOOLEAN; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_BOOL,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutBoolField;

PROCEDURE (obj:Object) GetBoolField*(fieldName:ARRAY OF CHAR; VAR x:BOOLEAN; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_BOOL,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=FALSE END;
END GetBoolField;

PROCEDURE (obj:Object) PutSetField*(fieldName:ARRAY OF CHAR; x:SET; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_SET,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutSetField;

PROCEDURE (obj:Object) GetSetField*(fieldName:ARRAY OF CHAR; VAR x:SET; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_SET,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:={} END;
END GetSetField;

PROCEDURE (obj:Object) PutRealField*(fieldName:ARRAY OF CHAR; x:REAL; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_REAL,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutRealField;

PROCEDURE (obj:Object) GetRealField*(fieldName:ARRAY OF CHAR; VAR x:REAL; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_REAL,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0 END;
END GetRealField;

PROCEDURE (obj:Object) PutLongRealField*(fieldName:ARRAY OF CHAR; x:LONGREAL; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_LONGREAL,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutLongRealField;

PROCEDURE (obj:Object) GetLongRealField*(fieldName:ARRAY OF CHAR; VAR x:LONGREAL; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_LONGREAL,addr,done);
  IF done THEN SYSTEM.GET(addr,x) ELSE x:=0 END;
END GetLongRealField;

PROCEDURE (obj:Object) PutStrField*(fieldName:ARRAY OF CHAR; x:ARRAY OF CHAR; VAR done:BOOLEAN);
(** \HIDE *)
(* Length check in destination missing !!! *)
VAR
  i,addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_STRING,addr,done);
  IF done THEN 
    i:=0;
    REPEAT
      SYSTEM.PUT(addr,x[i]);
      INC(i);
      INC(addr);
    UNTIL x[i-1]=0X;
  END; 
END PutStrField;

PROCEDURE (obj:Object) GetStrField*(fieldName:ARRAY OF CHAR; VAR x:ARRAY OF CHAR; VAR done:BOOLEAN);
(** \HIDE *)
(** <done> is set to FALSE if either the desired field can not be found, the field has
    the wrong type or <x> is not large enough to store the contents of the field.
    If <x> is not large enough to hold the result it is truncated. In all other cases
    of error <x> is set to the empty string. *)
VAR
  i,l,addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_STRING,addr,done);
  IF done THEN 
    i:=0;
    l:=LEN(x)-1;
    ASSERT(l>=0);
    REPEAT
      SYSTEM.GET(addr,x[i]);
      INC(i);
      INC(addr);
    UNTIL (i>l) OR (x[i-1]=0X);
    done:=x[i-1]=0X;
    x[i-1]:=0X;
  ELSE
    x[0]:=0X;
  END;
END GetStrField;

PROCEDURE (obj:Object) GetStrFieldLen*(fieldName:ARRAY OF CHAR; VAR x:LONGINT; VAR done:BOOLEAN);
(** \HIDE *)
(** returns the length of the string stored in the record field with 
    the name fieldName *)
VAR
  addr:LONGINT;
  ch:CHAR;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_STRING,addr,done);
  IF done THEN 
    x:=-1;
    REPEAT
      SYSTEM.GET(addr,ch);
      INC(x);
      INC(addr);
    UNTIL ch=0X;
  ELSE
    x:=0;
  END;
END GetStrFieldLen;

PROCEDURE (obj:Object) PutPointerField*(fieldName:ARRAY OF CHAR; x:Object; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_POINTER,addr,done);
  IF done THEN SYSTEM.PUT(addr,x) END;
END PutPointerField;

PROCEDURE (obj:Object) GetPointerField*(fieldName:ARRAY OF CHAR; VAR x:Object; VAR done:BOOLEAN);
(** \HIDE *)
VAR
  addr:LONGINT;
BEGIN
  obj.PrepFieldAccess(fieldName,TYP_POINTER,addr,done);
  IF done THEN 
    SYSTEM.GET(addr,x);
    done:=x IS Object;
  ELSE 
    x:=NIL;
  END;
END GetPointerField;

BEGIN
  dllListN:=0;
END OOBase.
