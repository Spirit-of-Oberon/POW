(******************************************************************************)
(*                                                                            *)
(**)                        MODULE DebugCV5;                                (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1995-98, Robinson Associates                                 *)
(*                        Red Lion House                                      *)
(*                        St Mary's Street                                    *)
(*                        PAINSWICK                                           *)
(*                        Glos                                                *)
(*                        GL6  6QR                                            *)
(*                        Tel:    (+44) (0)452 813 699                        *)
(*                        Fax:    (+44) (0)452 812 912                        *)
(*                        e-Mail: oberon@robinsons.co.uk                      *)
(******************************************************************************)
(* AUTHORS: Bernhard Leisch                                                   *)
(******************************************************************************)
(* PURPOSE:  Create CodeView 5 compatible debug information                   *)
(*                                                                            *)
(******************************************************************************)

IMPORT OPM,Coff,S:=String,E:=Error,OPT,OPL,Debug;

CONST
  FORMAT_SIGNATURE=2;    (* debug information format code *)
  COMPILER_VERSION="Pow! Oberon-2 32 Copyright (C) by Robinson Associates";
  LANGUAGE_CODE=1;       (* 1=C++, 4=PASCAL *)
  ALIGNMENT=4;           (* alignment of records in type definition section (.debug$T) *)
  MAXTYPEINX=07FFFFFFFH; (* largest possible debug type index value *)
  MAXINDTYPES=1000;      (* maximum number of type ids which can be allocated at the same time *)
  
  (* module visibility of objects *)
  internal=OPT.internal;
  internalR=OPT.internalR;
  external=OPT.external;
  externalR=OPT.externalR;

  ARRAY_INX_TYPE=0012H; (* type value used for the type of array indices *)
  
  T_NOTYPE =0000H;
  T_VOID   =0003H;
  
  S_COMPILE=00001H;
  S_UDT    =01003H;
  S_END    =00006H;
  S_OBJNAME=00009H;
  S_BPREL32=01006H;
  S_LDATA32=01007H;
  S_GDATA32=01008H;
  S_LPROC32=0100AH;
  S_GPROC32=0100BH;
  
  LF_POINTER    =01002H;
  LF_ARRAY      =01003H;
  LF_CLASS      =01004H;
  LF_STRUCTURE  =01005H;
  LF_UNION      =01006H;
  LF_ENUMERATION=01007H;
  LF_PROCEDURE  =01008H;
  LF_BARRAY     =0100BH; (* ???!!! this might be 0100DH if the documentation is wrong *)
  LF_DIMARRAY   =0100CH; (* ???!!! this might be 01011H if the documentation is wrong *)
  LF_OEM        =0100FH;
  LF_ARGLIST    =01201H;
  LF_FIELDLIST  =01203H;
  LF_DIMCONLU   =00209H;
  LF_DIMVARU    =0020AH;
  LF_REFSYM     =0020CH;
  LF_INDEX      =01404H;
  LF_MEMBER     =01405H;

  maxUndPtr = OPT.maxUndPtr;

  (* item base modes (=object modes)                                        *)
  MODE_VAR = OPT.MODE_VAR; 
  VarPar = OPT.VarPar; 
  MODE_CON = OPT.MODE_CON; 
  Fld = OPT.Fld; 
  MODE_TYPE = OPT.MODE_TYPE;
  MODE_DLLTYPE = OPT.MODE_DLLTYPE;
  LProc = OPT.LProc; 
  XProc = OPT.XProc;
  SProc = OPT.SProc; (* built in function *)
  CProc = OPT.CProc; 
  IProc = OPT.IProc; 
  Mod = OPT.Mod; 
  Head = OPT.Head; 
  TProc = OPT.TProc;
  WProc = OPT.WProc; (*!*)
  MODE_CDECLPROC=OPT.MODE_CDECLPROC;
  MODE_VARSTPAR=OPT.MODE_VARSTPAR; (* statically typed VAR parameter; may be declared 
                                      only in definition modules *)
  MODE_DLLVAR=OPT.MODE_DLLVAR;
  
  (* structure forms *)
  Undef =   OPT.Undef; 
  Byte =    OPT.Byte; 
  Bool =    OPT.Bool; 
  Char =    OPT.Char; 
  SInt =    OPT.SInt; 
  Int =     OPT.Int; 
  LInt =    OPT.LInt;      
  Real =    OPT.Real; 
  LReal =   OPT.LReal; 
  Set =     OPT.Set; 
  String =  OPT.String; 
  NilTyp =  OPT.NilTyp; 
  NoTyp =   OPT.NoTyp;
  Pointer = OPT.Pointer; 
  ProcTyp = OPT.ProcTyp; 
  Comp =    OPT.Comp;
  realSet = {Real, LReal};

  (* composite structure forms *)
  Basic =OPT.Basic; 
  Array =OPT.Array; 
  DynArr=OPT.DynArr; 
  Record=OPT.Record;

  DFIXUP_SECTION=OPL.DFIXUP_SECTION; (* fixup in debug area to section nr, inx is index to section symbol in symbol table *)
  DFIXUP_SECREL=OPL.DFIXUP_SECREL; (* fixup in debug area to section relative offset, inx is index to symbol table *)
  
TYPE
  TypeInxT=LONGINT; (* type index references in debug type section *)  
  
  RefListElem=POINTER TO RefListElemT;
  RefListElemT=RECORD
    next:RefListElem;
    offset:LONGINT;
  END;
  
  RefList=POINTER TO RefListT;
  RefListT=RECORD (* list of references to a type which has not been defined yet *)
    head:RefListElem;
    next:RefList;
    id:TypeInxT;
  END;
  
  TypeListT=RECORD
    head:RefList;
    ids:ARRAY MAXINDTYPES OF BOOLEAN;
  END;

CONST
  TYPEINXSIZE=4; (* size of TypeInxT in bytes *)

VAR
  sectionStart:LONGINT;
  moduleBodyInfo*:OPT.DebugInfo;
  typeInxCtr:TypeInxT;
  alignBytes:LONGINT;
  typeRefList:TypeListT;
  objFileName:ARRAY 260 OF CHAR;

PROCEDURE (list:RefList) Init(id:TypeInxT);
BEGIN
  list.head:=NIL;
  list.id:=id;
END Init;

PROCEDURE (list:RefList) Append(offset:LONGINT);
VAR
  elem:RefListElem;
BEGIN
  NEW(elem);
  elem.offset:=offset;
  elem.next:=list.head;
  list.head:=elem;
END Append;

PROCEDURE (list:RefList) Resolve(typeInx:TypeInxT);
VAR
  elem:RefListElem;
BEGIN
  elem:=list.head;
  WHILE elem#NIL DO
    Coff.WriteFixup(elem.offset,typeInx);
    elem:=elem.next;
  END;
END Resolve;

PROCEDURE (VAR list:TypeListT) Init;
VAR
  i:TypeInxT;
BEGIN
  list.head:=NIL;
  FOR i:=0 TO MAXINDTYPES-1 DO list.ids[i]:=FALSE END;
END Init;

PROCEDURE (VAR list:TypeListT) Resolve(id:TypeInxT; typeInx:TypeInxT);
(* Fixup all occurrances of the temporary type id with the actual
   type id and remove the temporary id from the list. *)
VAR
  rList,old:RefList;
BEGIN
  old:=NIL;
  rList:=list.head;
  WHILE (rList#NIL) & (rList.id#id) DO 
    old:=rList;
    rList:=rList.next;
  END;
  IF rList#NIL THEN
    rList.Resolve(typeInx);
    list.ids[-id-2]:=FALSE;
    IF old=NIL THEN list.head:=list.head.next ELSE old.next:=old.next.next END;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugCV5.TypeListT.Resolve");
  END;
END Resolve;

PROCEDURE (VAR list:TypeListT) GetNewId():TypeInxT;
(* Get a new temporary type id and make an entry for it in the
   type list *)
VAR
  i:TypeInxT;
  rList:RefList;
BEGIN
  i:=0;
  WHILE (i<MAXINDTYPES) & list.ids[i] DO INC(i) END;
  IF i>=MAXINDTYPES THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugCV5.TypeListT.GetNewId");
    RETURN -1;
  ELSE
    list.ids[i]:=TRUE;
    NEW(rList);
    rList.Init(-i-2); (* only values < -1 are allowed for temporary ids *)
    rList.next:=list.head;
    list.head:=rList;
    RETURN -i-2;
  END;
END GetNewId;

PROCEDURE (VAR list:TypeListT) Append(id:TypeInxT; offset:LONGINT);
(* Add a new offset to the list of occurrances of a specific type id *)
VAR
  rList:RefList;
BEGIN
  rList:=list.head;
  WHILE (rList#NIL) & (rList.id#id) DO rList:=rList.next END;
  IF rList=NIL THEN
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"DebugCV5.TypeListT.Append");
  ELSE
    rList.Append(offset);
  END;
END Append;


(*======================================================================*)

    
PROCEDURE SWriteStr(VAR txt-:ARRAY OF CHAR);
VAR
  i,len:LONGINT;
BEGIN
  len:=S.Length(txt);
  IF len>255 THEN 
    OPM.CommentedErr(E.INTERNAL_MURKS,"DebugCV5.WriteStr");
  ELSE
    Coff.WriteObjByte(SHORT(len));
    FOR i:=0 TO len-1 DO
      Coff.WriteObjByte(ORD(txt[i]));
    END;
  END;
END SWriteStr;

PROCEDURE SWriteSymData(obj:OPT.Object);
VAR
  name:ARRAY 2*OPM.MaxIdLen OF CHAR;
BEGIN
  COPY(OPM.moduleName,name);
  S.AppendChar(name,"_");
  S.Append(name,obj^.name);
  Coff.WriteObjWord(9+TYPEINXSIZE+S.Length(name));
  IF (obj^.vis = external) OR (obj^.vis = externalR) THEN
    Coff.WriteObjWord(S_GDATA32);
  ELSE
    Coff.WriteObjWord(S_LDATA32);
  END;
  IF (obj^.debugInfo#NIL) & (obj^.debugInfo^.type#-1) THEN
    Coff.WriteObjLongint(obj^.debugInfo^.type);
  ELSIF obj^.typ^.debugType#-1 THEN
    Coff.WriteObjLongint(obj^.typ^.debugType);
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"corrupt debug info (SWriteSymData)");
    Coff.WriteObjLongint(T_NOTYPE);
  END;
  Coff.WriteObjLongint(obj^.adr);
  OPL.DefineFixup(DFIXUP_SECREL, Coff.symInxData,Coff.globObjLen-sectionStart-4);
  Coff.WriteObjWord(0); (* section nr. *)  
  OPL.DefineFixup(DFIXUP_SECTION,Coff.symInxData,Coff.globObjLen-sectionStart-2);
  SWriteStr(name);
END SWriteSymData;

PROCEDURE SWriteBPRelative(obj:OPT.Object);
BEGIN
  Coff.WriteObjWord(6+TYPEINXSIZE+1+S.Length(obj^.name));
  Coff.WriteObjWord(S_BPREL32);
  Coff.WriteObjLongint(obj^.adr);
  IF (obj^.debugInfo#NIL) & (obj^.debugInfo^.type#-1) THEN
    Coff.WriteObjLongint(obj^.debugInfo^.type);
  ELSIF obj^.typ^.debugType#-1 THEN
    Coff.WriteObjLongint(obj^.typ^.debugType);
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"no debug type info for local variable");
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,obj^.name);
    Coff.WriteObjLongint(T_NOTYPE);
  END;
  SWriteStr(obj^.name);
END SWriteBPRelative;

PROCEDURE SWriteObjFileName;
VAR
  i,l:LONGINT;
  h:ARRAY 260 OF CHAR;
BEGIN
  l:=S.Length(objFileName);
  i:=l-1;
  WHILE (i>=0) & (objFileName[i]#"\") & (objFileName[i]#":") DO DEC(i) END;
  S.Copy(objFileName,h,i+2,l);
  Coff.WriteObjWord(7+S.Length(h));
  Coff.WriteObjWord(S_OBJNAME);
  Coff.WriteObjLongint(0); (* signature for precompiled types *)
  SWriteStr(h);
END SWriteObjFileName;

PROCEDURE SWriteProcedure(obj:OPT.Object);
VAR
  name:ARRAY 3*OPM.MaxIdLen OF CHAR;
BEGIN
  IF obj^.symTableInx=-1 THEN
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"debug info corrupt");
  END;
  IF obj^.mode=TProc THEN
    COPY(OPM.moduleName,name);
    S.AppendChar(name,OPM.SYMBOLSEPARATOR);
    S.Append(name,obj^.link^.typ^.strobj^.name);
    S.AppendChar(name,OPM.SYMBOLSEPARATOR);
    S.Append(name,obj^.name);
  ELSE
    OPM.MakeGlobalName(OPM.moduleName, obj^.name, name);
  END;
  Coff.WriteObjWord(34+TYPEINXSIZE+S.Length(name));
  IF obj^.mode=LProc THEN
    Coff.WriteObjWord(S_LPROC32);
  ELSE  
    Coff.WriteObjWord(S_GPROC32);
  END;
  Coff.WriteObjLongint(0); (* filled in by CVPACK, set to zero *)
  Coff.WriteObjLongint(0); (* filled in by CVPACK, set to zero *)
  Coff.WriteObjLongint(0); (* filled in by CVPACK, set to zero *)
  IF obj^.debugInfo#NIL THEN
    Coff.WriteObjLongint(obj^.debugInfo.procLen);  (* proc length *)
    Coff.WriteObjLongint(obj^.debugInfo.codeDebugStart);  (* debug start = first offset after stack frame is set up *)
    Coff.WriteObjLongint(obj^.debugInfo.codeDebugEnd);  (* debug end = last offset before stack frame is destroyed *)
  ELSE
    Coff.WriteObjLongint(0); Coff.WriteObjLongint(0); Coff.WriteObjLongint(0);  
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"procedure debug info corrupt");
  END;
  Coff.WriteObjLongint(obj^.debugInfo.type);    (* procedure type *)
  Coff.WriteObjLongint(0); (* offset portion of procedure address *)
  OPL.DefineFixup(DFIXUP_SECREL, obj^.symTableInx, Coff.globObjLen-sectionStart-4);
  Coff.WriteObjWord(0);    (* section portion of procedure address *)
  OPL.DefineFixup(DFIXUP_SECTION, obj^.symTableInx, Coff.globObjLen-sectionStart-2);
  Coff.WriteObjByte(1);     (* procedure flags *)
  SWriteStr(name);
END SWriteProcedure;

PROCEDURE SWriteScopeEnd;
BEGIN
  Coff.WriteObjWord(2);
  Coff.WriteObjWord(S_END);
END SWriteScopeEnd;

PROCEDURE SWriteCompileFlag;
BEGIN
  Coff.WriteObjWord(7+S.Length(COMPILER_VERSION));
  Coff.WriteObjWord(S_COMPILE);
  Coff.WriteObjByte(03H); (* machine i386 *)
  Coff.WriteObjByte(LANGUAGE_CODE); 
  Coff.WriteObjByte(20H); (* !!! *)
  Coff.WriteObjByte(10H); (* !!! *)
  SWriteStr(COMPILER_VERSION);
END SWriteCompileFlag;

PROCEDURE SWriteType(obj:OPT.Object);
VAR
  type:TypeInxT;
BEGIN
  IF obj^.debugInfo#NIL THEN
    type:=obj^.debugInfo^.type;
    IF type>=1000H THEN
      Coff.WriteObjWord(3+TYPEINXSIZE+S.Length(obj^.name));
      Coff.WriteObjWord(S_UDT);
      Coff.WriteObjLongint(type);
      SWriteStr(obj^.name);
    END;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"DebugCV5.SWriteType");
  END;
END SWriteType;

PROCEDURE^ SWriteObjs(obj: OPT.Object; topScope:BOOLEAN);
PROCEDURE^ SWriteObj(obj:OPT.Object; topScope:BOOLEAN);

PROCEDURE SWriteProcScope(obj:OPT.Object);
VAR
  hobj:OPT.Object;

  PROCEDURE WriteLocalProcs(obj:OPT.Object);
  BEGIN
    IF obj#NIL THEN
      WriteLocalProcs(obj^.left);
      IF obj^.mode=LProc THEN SWriteProcScope(obj) END;
      WriteLocalProcs(obj^.right);
    END;
  END WriteLocalProcs;
  
BEGIN
  SWriteProcedure(obj);
  hobj:=obj^.link;   (* parameters *)
  WHILE hobj#NIL DO  
    SWriteObj(hobj,FALSE);
    hobj:=hobj^.link;
  END;
  hobj:=obj^.scope^.scope; (* local variables *)
  WHILE hobj#NIL DO
    SWriteObj(hobj,FALSE);
    hobj:=hobj^.link;
  END;
  IF (obj^.mode#TProc) & (obj^.scope#NIL) THEN WriteLocalProcs(obj^.scope^.right) END;
  SWriteScopeEnd;
END SWriteProcScope;

PROCEDURE SWriteMethods(obj:OPT.Object);
BEGIN
  IF obj#NIL THEN
    SWriteMethods(obj^.left);
    IF obj^.mode=TProc THEN SWriteProcScope(obj) END;
    SWriteMethods(obj^.right);
  END;
END SWriteMethods;

PROCEDURE SWriteObj(obj:OPT.Object; topScope:BOOLEAN);
BEGIN
  IF obj^.mode=MODE_VAR THEN
    IF topScope THEN
      SWriteSymData(obj); (* variable in data section *)
    ELSE
      SWriteBPRelative(obj); (* procedure local variable *)
    END;
  ELSIF (obj^.mode=VarPar) OR
        (obj^.mode=MODE_VARSTPAR) THEN
    SWriteBPRelative(obj); (* procedure parameter *)
  ELSIF (obj^.mode=MODE_TYPE) (*& (obj^.typ^.strobj#obj) & (obj^.typ^.strobj#NIL)*) THEN
    SWriteType(obj);
    IF obj^.typ^.comp=Record THEN
      SWriteMethods(obj^.typ^.link);
    END;
  ELSIF ((obj^.mode = XProc) OR
        (obj^.mode = TProc) OR
        (obj^.mode = WProc) OR
        (obj^.mode = LProc) OR
        (obj^.mode = IProc) OR
        (obj^.mode = CProc) OR
        (obj^.mode = MODE_CDECLPROC)) & (obj^.debugInfo#NIL) & (obj^.debugInfo.type#-1) THEN
    SWriteProcScope(obj);    
  END;
END SWriteObj;
  
PROCEDURE SWriteObjs(obj: OPT.Object; topScope:BOOLEAN);
BEGIN
  IF obj # NIL THEN
    SWriteObjs(obj^.left,topScope);
    SWriteObj(obj,topScope);
    SWriteObjs(obj^.right,topScope);
  END
END SWriteObjs;


(*======================================================================*)

    
PROCEDURE TWriteRecLen(len:LONGINT; VAR typeInx:TypeInxT);
BEGIN
  typeInx:=typeInxCtr;
  INC(typeInxCtr);
  IF typeInxCtr=MAXTYPEINX THEN
    OPM.Err(E.TOO_MANY_DEBUGTYPES);
    typeInxCtr:=1000H;
  END;
  alignBytes:=(-len-2) MOD ALIGNMENT;
  Coff.WriteObjWord(alignBytes+len);
END TWriteRecLen;

PROCEDURE TWriteRecEnd;
VAR
  i:LONGINT;
  pad:INTEGER;
BEGIN
  pad:=00F0H+SHORT(alignBytes);
  FOR i:=1 TO alignBytes DO
    Coff.WriteObjByte(pad);
    DEC(pad);
  END;
END TWriteRecEnd;

PROCEDURE TWriteTypeInx(typeInx:TypeInxT);
BEGIN
  IF typeInx=-1 THEN
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"DebugCV5.TWriteTypeInx");
    (* type index not initialized to either an actual or a temporary value *)
  ELSIF typeInx<0 THEN
    typeRefList.Append(typeInx,Coff.globObjLen);
    Coff.WriteObjLongint(0);
  ELSE
    Coff.WriteObjLongint(typeInx);
  END;
END TWriteTypeInx;

PROCEDURE ^TWriteTypeS(struct:OPT.Struct);
PROCEDURE ^TWriteType(obj: OPT.Object; topScope:BOOLEAN);
PROCEDURE ^TWriteTypes(obj: OPT.Object; topScope:BOOLEAN);
PROCEDURE ^TWriteProcedureS(struct:OPT.Struct);
PROCEDURE ^TWriteArray(struct:OPT.Struct);
PROCEDURE ^TWriteProcedure(obj:OPT.Object);

PROCEDURE TWritePointer(struct:OPT.Struct);
VAR
  baseDebug:TypeInxT;
BEGIN
  IF struct^.BaseTyp^.debugType=-1 THEN TWriteTypeS(struct^.BaseTyp) END;
  baseDebug:=struct^.BaseTyp^.debugType;
  IF (baseDebug=0020H) OR 
     (baseDebug=0010H) OR 
     (baseDebug=0011H) OR 
     (baseDebug=0012H) THEN
    struct.debugType:=baseDebug+0400H;
  ELSE
    TWriteRecLen(6+TYPEINXSIZE,struct.debugType);
    Coff.WriteObjWord(LF_POINTER);
    TWriteTypeInx(baseDebug);
    Coff.WriteObjLongint(000AH); (* ptr type: near 32 bit pointer, ptr mode: pointer *)
    TWriteRecEnd;
  END;
END TWritePointer;

PROCEDURE TWriteFieldList(struct:OPT.Struct; VAR typeInx:TypeInxT);
VAR
  hobj:OPT.Object;
  size:INTEGER;

  PROCEDURE CalcRecLength(struct:OPT.Struct; VAR size:INTEGER);
  VAR
    hobj:OPT.Object;
    len,recSize,pad:INTEGER;
  BEGIN
    IF struct^.BaseTyp#NIL THEN CalcRecLength(struct^.BaseTyp,size) END;
    hobj:=struct^.link;
    WHILE hobj#NIL DO
      IF hobj^.mode=Fld THEN
        len:=SHORT(S.Length(hobj^.name))+1;
        recSize:=len+6(*numeric leaf*)+4+TYPEINXSIZE;
        pad:=(-recSize) MOD ALIGNMENT;
        size:=size+pad+recSize;
      END;
      hobj:=hobj.link;
    END;
  END CalcRecLength;
  
  PROCEDURE WriteSubRecords(struct:OPT.Struct);
  VAR
    hobj:OPT.Object;
    pad:INTEGER;
  BEGIN
    IF struct^.BaseTyp#NIL THEN WriteSubRecords(struct^.BaseTyp) END;
    hobj:=struct^.link;
    WHILE hobj#NIL DO
      IF hobj^.mode=Fld THEN
        Coff.WriteObjWord(LF_MEMBER);
        Coff.WriteObjWord(0); (* member attribute bit field *)
        TWriteTypeInx(hobj^.typ^.debugType);
        Coff.WriteObjWord(08004H); (* unsigned long numeric leaf: *)
        Coff.WriteObjLongint(hobj^.adr);
        SWriteStr(hobj^.name);
        pad:=+(-SHORT(S.Length(hobj^.name))-1-10-TYPEINXSIZE) MOD ALIGNMENT;
        WHILE pad>0 DO
          Coff.WriteObjByte(00F0H+pad);
          DEC(pad);
        END;
      END;
      hobj:=hobj.link;
    END;
  END WriteSubRecords;

BEGIN
  hobj:=struct^.link;
  size:=2;
  CalcRecLength(struct,size);
  TWriteRecLen(size,typeInx);
  Coff.WriteObjWord(LF_FIELDLIST);
  WriteSubRecords(struct);
  TWriteRecEnd;
END TWriteFieldList;

PROCEDURE TWriteRecord(struct:OPT.Struct);
VAR
  fieldListInx:TypeInxT;
  n:INTEGER;
  name:OPM.Name;
  
  PROCEDURE CreateBaseTypes(struct:OPT.Struct; VAR n:INTEGER);
  VAR
    hobj:OPT.Object;
  BEGIN
    IF struct^.BaseTyp#NIL THEN CreateBaseTypes(struct^.BaseTyp,n) END;
    hobj:=struct^.link;
    WHILE hobj#NIL DO
      IF hobj^.typ^.debugType=-1 THEN TWriteTypeS(hobj^.typ) END;
      IF hobj^.mode=Fld THEN INC(n) END;
      hobj:=hobj.link;
    END;
  END CreateBaseTypes;
  
BEGIN
  IF struct^.strobj#NIL THEN
    COPY(struct^.strobj^.name,name);
  ELSE
    name:="@in-place type"; (* unnamed type declaration, e.g. as part of a variable declaration *)
  END;
  n:=0;
  CreateBaseTypes(struct,n);
  TWriteFieldList(struct,fieldListInx);
  TWriteRecLen(6+TYPEINXSIZE*3+6(*numeric leaf*)+1+S.Length(name),struct.debugType);
  Coff.WriteObjWord(LF_CLASS);
  Coff.WriteObjWord(n); (* CV: number of elements including methods and data members *)
  Coff.WriteObjWord(0); (* property bit field including: forward defs? nested classes? *)
  TWriteTypeInx(fieldListInx);
  Coff.WriteObjLongint(0); (* CV: should be set to 0 by compiler *)
  Coff.WriteObjLongint(0); (* type index of virtual function table shape descriptor *)
  Coff.WriteObjWord(8004H);  (* numeric leaf, unsigned long: *)
  Coff.WriteObjLongint(struct^.size);  (* size of structure *)
  SWriteStr(name);
  TWriteRecEnd;
END TWriteRecord;

PROCEDURE TWriteDynArray(struct:OPT.Struct);
CONST
  TYPENAME="open_array";
  LENFIELD="max_index";
  ARRAYFIELD="first_element";
VAR
  fieldListInx:TypeInxT;

  PROCEDURE SubRecordLength(VAR name-:ARRAY OF CHAR):INTEGER;
  VAR
    size:INTEGER;
  BEGIN
    size:=SHORT(S.Length(name))+1+10+TYPEINXSIZE;
    size:=size+(-size) MOD ALIGNMENT;
    RETURN size;
  END SubRecordLength;

  PROCEDURE WriteSubRecord(offset:LONGINT; typeInx:TypeInxT; VAR name-:ARRAY OF CHAR);
  VAR
    hobj:OPT.Object;
    pad:INTEGER;
  BEGIN
    Coff.WriteObjWord(LF_MEMBER);
    Coff.WriteObjWord(0); (* member attribute bit field *)
    TWriteTypeInx(typeInx);
    Coff.WriteObjWord(08004H); (* unsigned long numeric leaf: *)
    Coff.WriteObjLongint(offset);
    SWriteStr(name);
    pad:=(-SHORT(S.Length(name))-1-10-TYPEINXSIZE) MOD ALIGNMENT;
    WHILE pad>0 DO
      Coff.WriteObjByte(00F0H+pad);
      DEC(pad);
    END;
  END WriteSubRecord;

BEGIN
  IF struct^.BaseTyp^.debugType=-1 THEN TWriteTypeS(struct^.BaseTyp) END;
  TWriteRecLen(2+SubRecordLength(LENFIELD)+SubRecordLength(ARRAYFIELD),fieldListInx);
  Coff.WriteObjWord(LF_FIELDLIST);
  WriteSubRecord(8,0075H,LENFIELD);
  WriteSubRecord(12,struct^.BaseTyp^.debugType,ARRAYFIELD);
  TWriteRecEnd;
  TWriteRecLen(6+TYPEINXSIZE*3+6(*numeric leaf*)+1+S.Length(TYPENAME),struct.debugType);
  Coff.WriteObjWord(LF_CLASS);
  Coff.WriteObjWord(2); (* CV: number of elements including methods and data members *)
  Coff.WriteObjWord(0); (* property list including: forward defs? nested classes? *)
  TWriteTypeInx(fieldListInx);
  Coff.WriteObjLongint(0); (* CV: should be set to 0 by compiler *)
  Coff.WriteObjLongint(0); (* type index of virtual function table shape descriptor *)
  Coff.WriteObjWord(8004H);  (* numeric leaf, unsigned long: *)
  Coff.WriteObjLongint(12+struct^.BaseTyp^.size);  (* size of structure *)
  SWriteStr(TYPENAME);
  TWriteRecEnd;
END TWriteDynArray;

PROCEDURE TWriteDynArrayParam(object:OPT.Object);
CONST
  TYPENAME="open_array_param";
  LENFIELD="max_index";
  ARRAYFIELD="ptr_to_array";
VAR
  fieldListInx:TypeInxT;
  ptrStruct:OPT.Struct;

  PROCEDURE SubRecordLength(VAR name-:ARRAY OF CHAR):INTEGER;
  VAR
    size:INTEGER;
  BEGIN
    size:=SHORT(S.Length(name))+1+10+TYPEINXSIZE;
    size:=size+(-size) MOD ALIGNMENT;
    RETURN size;
  END SubRecordLength;

  PROCEDURE WriteSubRecord(offset:LONGINT; typeInx:TypeInxT; VAR name-:ARRAY OF CHAR);
  VAR
    hobj:OPT.Object;
    pad:INTEGER;
  BEGIN
    Coff.WriteObjWord(LF_MEMBER);
    Coff.WriteObjWord(0); (* member attribute bit field *)
    TWriteTypeInx(typeInx);
    Coff.WriteObjWord(08004H); (* unsigned long numeric leaf: *)
    Coff.WriteObjLongint(offset);
    SWriteStr(name);
    pad:=(-SHORT(S.Length(name))-1-10-TYPEINXSIZE) MOD ALIGNMENT;
    WHILE pad>0 DO
      Coff.WriteObjByte(00F0H+pad);
      DEC(pad);
    END;
  END WriteSubRecord;

BEGIN
  IF object^.debugInfo=NIL THEN object^.debugInfo:=OPT.NewDebugInfo() END;
  IF object^.typ^.BaseTyp^.debugType=-1 THEN TWriteTypeS(object^.typ^.BaseTyp) END;
  ptrStruct:=OPT.NewStr(Pointer,Basic);
  ptrStruct.BaseTyp:=object^.typ^.BaseTyp;
  TWritePointer(ptrStruct);
  TWriteRecLen(2+SubRecordLength(LENFIELD)+SubRecordLength(ARRAYFIELD),fieldListInx);
  Coff.WriteObjWord(LF_FIELDLIST);
  WriteSubRecord(8,0075H,LENFIELD);
  WriteSubRecord(0,ptrStruct^.debugType,ARRAYFIELD);
  TWriteRecEnd;
  TWriteRecLen(6+TYPEINXSIZE*3+6(*numeric leaf*)+1+S.Length(TYPENAME),object^.debugInfo^.type);
  Coff.WriteObjWord(LF_CLASS);
  Coff.WriteObjWord(2); (* CV: number of elements including methods and data members *)
  Coff.WriteObjWord(0); (* property list including: forward defs? nested classes? *)
  TWriteTypeInx(fieldListInx);
  Coff.WriteObjLongint(0); (* CV: should be set to 0 by compiler *)
  Coff.WriteObjLongint(0); (* type index of virtual function table shape descriptor *)
  Coff.WriteObjWord(8004H);  (* numeric leaf, unsigned long: *)
  Coff.WriteObjLongint(12);  (* size of structure *)
  SWriteStr(TYPENAME);
  TWriteRecEnd;
END TWriteDynArrayParam;


PROCEDURE TWriteRecordVarParam(object:OPT.Object; staticObjMode:BOOLEAN);
CONST
  TYPENAME1="record_var_param";
  TYPENAME2="ptr_var_param";
  TAGFIELD="typetag";
  PTRFIELD1="ptr_to_record";
  PTRFIELD2="record";
VAR
  fieldListInx:TypeInxT;
  ptrStruct:OPT.Struct;
  ptrField,typeName:OPM.Name;
  ptrFieldType:TypeInxT;
  size:LONGINT;

  PROCEDURE SubRecordLength(VAR name-:ARRAY OF CHAR):INTEGER;
  VAR
    size:INTEGER;
  BEGIN
    size:=SHORT(S.Length(name))+1+10+TYPEINXSIZE;
    size:=size+(-size) MOD ALIGNMENT;
    RETURN size;
  END SubRecordLength;

  PROCEDURE WriteSubRecord(offset:LONGINT; typeInx:TypeInxT; VAR name-:ARRAY OF CHAR);
  VAR
    hobj:OPT.Object;
    pad:INTEGER;
  BEGIN
    Coff.WriteObjWord(LF_MEMBER);
    Coff.WriteObjWord(0); (* member attribute bit field *)
    TWriteTypeInx(typeInx);
    Coff.WriteObjWord(08004H); (* unsigned long numeric leaf: *)
    Coff.WriteObjLongint(offset);
    SWriteStr(name);
    pad:=(-SHORT(S.Length(name))-1-10-TYPEINXSIZE) MOD ALIGNMENT;
    WHILE pad>0 DO
      Coff.WriteObjByte(00F0H+pad);
      DEC(pad);
    END;
  END WriteSubRecord;

BEGIN
  IF object^.debugInfo=NIL THEN object^.debugInfo:=OPT.NewDebugInfo() END;
  IF object^.typ^.debugType=-1 THEN TWriteRecord(object^.typ) END;
  IF staticObjMode THEN
    ptrStruct:=OPT.NewStr(Pointer,Basic);
    ptrStruct^.BaseTyp:=object^.typ;
    TWritePointer(ptrStruct);
    ptrField:=PTRFIELD1;
    typeName:=TYPENAME1;
    ptrFieldType:=ptrStruct^.debugType;
    size:=8;
  ELSE
    ptrField:=PTRFIELD2;
    typeName:=TYPENAME2;
    ptrFieldType:=object^.typ^.debugType;
    size:=4+object^.typ^.size;
  END;
  TWriteRecLen(2+SubRecordLength(TAGFIELD)+SubRecordLength(ptrField),fieldListInx);
  Coff.WriteObjWord(LF_FIELDLIST);
  WriteSubRecord(0,0075H,TAGFIELD);
  WriteSubRecord(4,ptrFieldType,ptrField);
  TWriteRecEnd;
  TWriteRecLen(6+TYPEINXSIZE*3+6(*numeric leaf*)+1+S.Length(typeName),object^.debugInfo^.type);
  Coff.WriteObjWord(LF_CLASS);
  Coff.WriteObjWord(2); (* CV: number of elements including methods and data members *)
  Coff.WriteObjWord(0); (* property list including: forward defs? nested classes? *)
  TWriteTypeInx(fieldListInx);
  Coff.WriteObjLongint(0); (* CV: should be set to 0 by compiler *)
  Coff.WriteObjLongint(0); (* type index of virtual function table shape descriptor *)
  Coff.WriteObjWord(8004H);  (* numeric leaf, unsigned long: *)
  Coff.WriteObjLongint(size);  (* size of structure *)
  SWriteStr(typeName);
  TWriteRecEnd;
END TWriteRecordVarParam; 

PROCEDURE TWriteArray(struct:OPT.Struct);
BEGIN
  IF struct^.BaseTyp^.debugType=-1 THEN 
    TWriteTypeS(struct^.BaseTyp);
  END;
  TWriteRecLen(2+2*TYPEINXSIZE+6(*numeric leaf*)+1,struct^.debugType);
  Coff.WriteObjWord(LF_ARRAY);
  TWriteTypeInx(struct^.BaseTyp^.debugType);
  Coff.WriteObjLongint(ARRAY_INX_TYPE);
  Coff.WriteObjWord(08004H); (* unsigned long numeric leaf: *)
  Coff.WriteObjLongint(struct^.size);
  Coff.WriteObjByte(0);
  TWriteRecEnd;
END TWriteArray;

PROCEDURE TWriteTypeS(struct:OPT.Struct);
VAR
  tmpId:TypeInxT;
BEGIN
  tmpId:=typeRefList.GetNewId();
  struct.debugType:=tmpId; (* prevent endless indirect recursion *)
  IF struct^.comp=Array THEN
    TWriteArray(struct);
  ELSIF struct^.comp=DynArr THEN 
    TWriteDynArray(struct);
  ELSIF struct^.comp=Record THEN
    TWriteRecord(struct);
  ELSIF struct^.form=Pointer THEN
    TWritePointer(struct);
  ELSIF struct^.form=ProcTyp THEN
    TWriteProcedureS(struct);
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"debug info corrupt (TWriteTypeS)");
  END;
  typeRefList.Resolve(tmpId,struct.debugType);
END TWriteTypeS;

PROCEDURE TWriteTypeDecl(obj:OPT.Object);
BEGIN
  IF obj^.debugInfo=NIL THEN
    obj^.debugInfo:=OPT.NewDebugInfo();
  END;
  IF obj^.typ^.debugType=-1 THEN TWriteTypeS(obj^.typ) END;
  obj^.debugInfo^.type:=obj^.typ^.debugType;
END TWriteTypeDecl;

PROCEDURE TWriteVarParamType(obj:OPT.Object);
VAR
  ptrStruct,ptrStruct2:OPT.Struct;
BEGIN
  IF obj^.typ^.comp=DynArr THEN
    TWriteDynArrayParam(obj);
  ELSIF (obj^.typ^.comp=Record) & (obj^.mode#MODE_VARSTPAR) THEN
    TWriteRecordVarParam(obj,TRUE);
  ELSIF (obj^.typ^.form=Pointer) & (obj^.typ^.BaseTyp^.comp=Record) THEN
    IF obj^.debugInfo=NIL THEN
      obj^.debugInfo:=OPT.NewDebugInfo();
    END;
    ptrStruct:=OPT.NewStr(Pointer,Basic);
    ptrStruct^.BaseTyp:=obj^.typ;
    ptrStruct2:=OPT.NewStr(Pointer,Basic);
    ptrStruct2^.BaseTyp:=ptrStruct;
    TWritePointer(ptrStruct2);
    obj^.debugInfo^.type:=ptrStruct^.debugType;
  ELSE
    IF obj^.debugInfo=NIL THEN
      obj^.debugInfo:=OPT.NewDebugInfo();
    END;
    ptrStruct:=OPT.NewStr(Pointer,Basic);
    ptrStruct^.BaseTyp:=obj^.typ;
    TWritePointer(ptrStruct);
    obj^.debugInfo^.type:=ptrStruct^.debugType;
  END;
END TWriteVarParamType;

PROCEDURE TWriteParams(obj:OPT.Object; VAR typeInx:TypeInxT; VAR nParams:INTEGER);
VAR
  hobj:OPT.Object;
BEGIN
  hobj:=obj; nParams:=0; 
  WHILE hobj#NIL DO 
    IF (hobj^.mode=VarPar) OR
       (hobj^.mode=MODE_VARSTPAR)THEN
      IF (hobj^.debugInfo=NIL) OR (hobj^.debugInfo^.type#-1) THEN TWriteVarParamType(hobj) END;
    ELSE
      IF hobj^.typ^.debugType=-1 THEN TWriteTypeS(hobj^.typ) END;
    END;
    INC(nParams); 
    hobj:=hobj^.link;
  END;
  TWriteRecLen(2+4+nParams*TYPEINXSIZE,typeInx);
  Coff.WriteObjWord(LF_ARGLIST);
  Coff.WriteObjLongint(nParams);
  hobj:=obj; 
  WHILE hobj#NIL DO 
    IF hobj^.debugInfo#NIL THEN
      TWriteTypeInx(hobj^.debugInfo^.type);
    ELSE
      TWriteTypeInx(hobj^.typ^.debugType);
    END;
    hobj:=hobj^.link;
  END;
  TWriteRecEnd;
END TWriteParams;

PROCEDURE TWriteProcedureS(struct:OPT.Struct);
VAR 
  paramType:TypeInxT;
  paramN:INTEGER;
  callConvention:INTEGER;
  hobj:OPT.Object;
BEGIN
  TWriteParams(struct^.link,paramType,paramN);
  IF struct^.BaseTyp^.debugType=-1 THEN TWriteTypeS(struct^.BaseTyp) END;
  IF struct.strobj=NIL THEN
    callConvention:=2;
  ELSIF struct.strobj.mode=MODE_CDECLPROC THEN
    callConvention:=0;
  ELSIF struct.strobj.mode=WProc THEN
    callConvention:=7;
  ELSE
    callConvention:=2;
  END;
  TWriteRecLen(2+TYPEINXSIZE+1+1+2+TYPEINXSIZE,struct^.debugType);
  Coff.WriteObjWord(LF_PROCEDURE);
  IF struct^.BaseTyp^.debugType=0 THEN
    TWriteTypeInx(T_VOID);
  ELSE
    TWriteTypeInx(struct^.BaseTyp^.debugType);
  END;
  Coff.WriteObjByte(callConvention);
  Coff.WriteObjByte(0);
  Coff.WriteObjWord(paramN);
  TWriteTypeInx(paramType);
  TWriteRecEnd;
END TWriteProcedureS;

PROCEDURE TWriteProcedure(obj:OPT.Object);
VAR 
  paramType:TypeInxT;
  paramN:INTEGER;
  callConvention:INTEGER;
  hobj:OPT.Object;
BEGIN
  IF (obj^.debugInfo=NIL) OR (obj^.debugInfo^.type#-1) THEN RETURN END;
  TWriteParams(obj^.link,paramType,paramN); (* parameters *)
  hobj:=obj^.scope^.scope; (* local variables *)
  WHILE hobj#NIL DO
    IF hobj^.typ^.debugType=-1 THEN TWriteTypeS(hobj^.typ) END;
    hobj:=hobj^.link;
  END;
  IF (obj^.mode#TProc) & (obj^.scope#NIL) THEN TWriteTypes(obj^.scope^.right,FALSE) END; (* local procedures *)
  IF obj^.typ^.debugType=-1 THEN TWriteTypeS(obj^.typ) END;
  IF obj.mode=MODE_CDECLPROC THEN
    callConvention:=0;
  ELSIF obj.mode=WProc THEN
    callConvention:=7;
  ELSE
    callConvention:=2;
  END;
  TWriteRecLen(2+TYPEINXSIZE+1+1+2+TYPEINXSIZE,obj^.debugInfo^.type);
  Coff.WriteObjWord(LF_PROCEDURE);
  IF obj^.typ^.debugType=0 THEN
    TWriteTypeInx(T_VOID);
  ELSE
    TWriteTypeInx(obj^.typ^.debugType);
  END;
  Coff.WriteObjByte(callConvention);
  Coff.WriteObjByte(0);
  Coff.WriteObjWord(paramN);
  TWriteTypeInx(paramType);
  TWriteRecEnd;
END TWriteProcedure;

PROCEDURE TWriteMethods(obj:OPT.Object);
BEGIN
  IF obj#NIL THEN
    TWriteMethods(obj^.left);
    IF obj^.mode=TProc THEN TWriteProcedure(obj) END;
    TWriteMethods(obj^.right);
  END;
END TWriteMethods;

PROCEDURE TWriteType(obj: OPT.Object; topScope:BOOLEAN);
BEGIN
  IF obj^.mode = MODE_VAR THEN
    IF obj^.typ^.comp=DynArr THEN
      IF (obj^.debugInfo=NIL) OR (obj^.debugInfo^.type=-1) THEN TWriteDynArrayParam(obj) END;
    ELSE
      IF obj^.typ^.debugType=-1 THEN TWriteTypeS(obj^.typ) END;
    END;
  ELSIF (obj^.mode=VarPar) OR
        (obj^.mode=MODE_VARSTPAR) THEN
    TWriteVarParamType(obj);
  ELSIF (obj^.mode=MODE_TYPE) & ((obj^.debugInfo=NIL) OR (obj^.debugInfo.type=-1)) THEN
    IF (obj^.typ^.comp=Record) & (obj^.typ^.link#NIL) THEN
      TWriteTypes(obj^.typ^.link,FALSE); (* methods and fields of a record type *)
      TWriteMethods(obj^.typ^.link);
    END;
    TWriteTypeDecl(obj);
  ELSIF ((obj^.mode = XProc) OR
        (obj^.mode = TProc) OR
        (obj^.mode = WProc) OR
        (obj^.mode = LProc) OR
        (obj^.mode = IProc) OR
        (obj^.mode = CProc) OR
        (obj^.mode = MODE_CDECLPROC)) & (obj^.debugInfo#NIL) & (obj^.debugInfo.type=-1) THEN
    TWriteProcedure(obj);
  END;
END TWriteType;

PROCEDURE TWriteTypes(obj: OPT.Object; topScope:BOOLEAN);
BEGIN
  IF obj # NIL THEN
    TWriteTypes(obj^.left,topScope);
    TWriteType(obj,topScope);
    TWriteTypes(obj^.right,topScope);
  END
END TWriteTypes;


(*======================================================================*)

    
PROCEDURE Write*;
(* Write CodeView compatible debug sections to the object file *)
VAR
  padBytes:LONGINT;
BEGIN
  typeRefList.Init;
  padBytes:=(-Coff.globObjLen) MOD 4;
  WHILE padBytes>0 DO Coff.WriteObjByte(0); DEC(padBytes) END;
  Coff.WriteFixup(Coff.debugTypesFixup,Coff.globObjLen);
  sectionStart:=Coff.globObjLen;
  Coff.WriteObjLongint(FORMAT_SIGNATURE);
  typeInxCtr:=1000H;
  TWriteTypes(OPT.topScope^.right,TRUE); 
  Coff.WriteFixup(Coff.debugTypesFixup-4,Coff.globObjLen-sectionStart);
  Coff.WriteObjAlignment;
  sectionStart:=Coff.globObjLen;
  Coff.WriteFixup(Coff.debugSymbolsFixup,Coff.globObjLen);
  Coff.WriteObjLongint(FORMAT_SIGNATURE);
  SWriteObjFileName;
  SWriteCompileFlag;
  SWriteObjs(OPT.topScope^.right,TRUE); 
  Coff.WriteFixup(Coff.debugSymbolsFixup-4,Coff.globObjLen-sectionStart);
  Coff.WriteObjAlignment;
END Write;

PROCEDURE Init*(VAR objectFileName-:ARRAY OF CHAR);
BEGIN
  moduleBodyInfo:=OPT.NewDebugInfo();
  COPY(objectFileName,objFileName);
END Init;

END DebugCV5.
