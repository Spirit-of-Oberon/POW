(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPT;                                     (**)
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
(* AUTHORS: Régis Crelier, Richard De Moliner, Bernhard Leisch                *)
(******************************************************************************)
(* PURPOSE: Symbol table of Oberon2 compiler DLL                              *)
(*          Symbol file generation                                            *)
(*          Export file generation                                            *)
(******************************************************************************)

  IMPORT
    OPS, OPM, E:=Error, Debug, DLLImportList;

  CONST
    MaxConstLen* = OPS.MaxStrLen;
    HdPtrName* = "@ptr";
    HdProcName* = "@proc";
    HdTProcName* = "@tproc";

    (* constants for symbol file tags *)
    TAG_CONSTANT=1;
    TAG_TYPE=2;
    TAG_HID_TYPE=3;
    TAG_VAR=4;
    TAG_IPROC=5; (* interrupt procedure *)
    TAG_XPROC=6; (* exported procedure *)
    TAG_CPROC=7; (* code procedure *)
    TAG_PTR=8;
    TAG_PROC=9;
    TAG_ARRAY=10;
    TAG_OPEN_ARRAY=11;
    TAG_RECORD=12;
    TAG_PARAM_LIST=13;
    TAG_VAL_PARAM=14;
    TAG_VAR_PARAM=15;
    TAG_FIELD_LIST=16;
    TAG_FIELD=17; (* record field *)
    TAG_HID_PTR=18;
    TAG_HID_PROC=19;
    TAG_FIXUP=20;
    TAG_SYS=21;
    TAG_MODULE=22;
    TAG_RO_VAR=23; (* read only var  *)
    TAG_RO_FIELD=24;
    TAG_TB_PROC=25; (* type bound procedure *)
    TAG_NOF_METHODS=26; (* number of methods *)
    TAG_HID_TB_PROC=27; (* hidden type bound procedure *)
    TAG_WND_PROC=30; (* procedure declared [_APICALL] *)
    TAG_RO_VAR_PARAM=31; (* read only var parameter, call by reference *)
    TAG_CDECL_PROC=32; (* procedure with C calling convention, declared [_CDECL] *)
    TAG_STATICTYPEDVAR_PARAM=33; (* statically typed VAR parameter *)

  TYPE
    Const* = POINTER TO ConstDesc;
    Object* = POINTER TO ObjDesc;
    Struct* = POINTER TO StrDesc;
    Node* = POINTER TO NodeDesc;
    ConstExt* = POINTER TO OPS.String;
 
    ConstDesc* = RECORD
      ext*: ConstExt;        (* string or code for code proc *)
      intval*: LONGINT;      (* constant value or adr, proc par size, text position or least case label *)
      intval2*: LONGINT;     (* string length, proc var size or larger case label *)
      setval*: SET;          (* constant value, procedure body present or "ELSE" present in case *)
      realval*: LONGREAL     (* real or longreal constant value *)
    END ;
    
    DebugInfoDesc*=RECORD
      codeDebugStart*:LONGINT; (* first code offset after stack frame has been set up,
                                  available after code generation *)
      codeDebugEnd*:LONGINT;   (* last code offset before stack frame is destroyed,
                                  available after code generation *)
      procLen*:LONGINT; (* size of procedure ,
                           available after code generation *)
      type*:LONGINT;    (* CodeView debug type, 
                           available after debug type section has been written *)
    END;
  
    DebugInfo*=POINTER TO DebugInfoDesc;

    ObjDesc* = RECORD
      left*, right*, link*, scope*: Object;
      name*: OPS.Name;
      leaf*: BOOLEAN;
      mode*: SHORTINT;
      mnolev*: SHORTINT;  (* mnolev < 0 -> mno = -mnolev; 
                             mno = 0 if defined within module or module 
                             number if imported? *)
      vis*: SHORTINT;  (* 0: internal; 1: internalR; 2: external; 3: externalR *) (*!*)
      typ*: Struct; (* for procedures this is type of return value  *)
      conval*: Const;
      adr*, linkadr*: LONGINT;
      symTableInx*:LONGINT; (* -1 or zero based index of corresponding symbol table entry *)
      debugInfo*:DebugInfo; (* NIL or pointer to additional debug information (currently only for procedures) *)
      fromDLL*:BOOLEAN; (* TRUE if object has to be accessed across DLL boundaries *)
    END ;

(* Objects:

    mode      | adr   conval  link     scope    leaf
    ---------------------------------------------
    Undef     |                                        Not used
    Var       | adr           next              regopt Glob or loc var or proc value parameter
    VarPar    | vadr          next              regopt Procedure var parameter
    Con       |       val                              Constant
    Fld       | off           next                     Record field
    Typ       |                                        Named type
    LProc     |       sizes   firstpar scope    leaf   Local procedure
    XProc     | pno   sizes   firstpar scope    leaf   External procedure
    WProc     | pno   sizes   firstpar scope    leaf   External windows procedure (*!*)
    CDeclProc | pno   sizes   firstpar scope    leaf   External C calling convention procedure (* + 26.08.96 *)
    SProc     | fno   sizes                            Standard procedure
    CProc     |       code    firstpar scope           Code procedure
    IProc     | pno   sizes            scope    leaf   Interrupt procedure
    Mod       | key                    scope           Module
    Head      | txtpos        owner    firstvar        Scope anchor
    TProc     | index sizes   firstpar scope    leaf   Bound procedure, index = 10000H*mthno+pno
    
    for imported procedures pno is the zero based index into the coff symbol table;
    (the first symbol in the table is never a procedure, therefore pno=0 may be used
    to signal that it is not initialized yet)
    for TProc (type bound procedures) pno has a different meaning after
    OPC.InitTypDesc has been called for the associated class: ?
    
    Bit stuffing in adr field of TProc objects (index = 10000H*mthno+pno) does
    only work when the code into which pno points at some time during compilation
    is within the first 64kb of the code section; because the code is in
    the module initialization code and module initialization code starts at
    offset 0 of the code section this works as long as module initialization
    does not grow larger than 64kB.
*)

    StrDesc* = RECORD
      form*, comp*, mno*, extlev*: SHORTINT;
      ref*, sysflag*: INTEGER;
      n*, size*, tdadr*, offset*: LONGINT;
      BaseTyp*: Struct; (* definition of superclass for derived record types ? *)
      link*: Object;
      strobj*: Object; (* pointer to name of structure ? (at least for named records) *)
      txtpos*:OPM.SourcePosT;
      debugType*:LONGINT; (* used for the CodeView debug type codes *)
    END ;

(*
Structures:
                               (Struct) (Object)
    form    comp  | n          BaseTyp   link     mno  tdadr     offset txtpos   sysflag
    -----------------------------------------------------------------------------
    Undef   Basic |
    Byte    Basic |
    Bool    Basic |
    Char    Basic |
    SInt    Basic |
    Int     Basic |
    LInt    Basic |
    Real    Basic |
    LReal   Basic |
    Set     Basic |
    String  Basic |
    NilTyp  Basic |
    NoTyp   Basic |
    Pointer Basic |            PBaseTyp           mno                   txtpos   sysflag
    ProcTyp Basic |            ResTyp    params   mno                   txtpos   sysflag
    Comp    Array | nofel      ElemTyp            mno  boundsaddr       txtpos   sysflag
    Comp    DynArr| dim        ElemTyp            mno            lenoff txtpos   sysflag
    Comp    Record| nofmethods RBaseTyp  fields   mno  tdadr            txtpos   sysflag
    
*)   
    NodeDesc* = RECORD
      left*, right*, link*: Node;
      class*, subcl*: SHORTINT;
      readonly*: BOOLEAN;
      typ*: Struct;
      obj*: Object;
      conval*: Const;
      txtpos*:OPM.SourcePosT; (** position in source text *)
      endLine*:LONGINT; (*  the last line of structuring constructs like procedures or IF...END *) 
    END ;
(*
Nodes:

design   = Nvar|Nvarpar|Nfield|Nderef|Nindex|Nguard|Neguard|Ntype|Nproc.
expr     = design|Nconst|Nupto|Nmop|Ndop|Ncall.
nextexpr = NIL|expr.
ifstat   = NIL|Nif.
casestat = Ncaselse.
sglcase  = NIL|Ncasedo.
stat     = NIL|Ninittd|Nenter|Nassign|Ncall|Nifelse|Ncase|Nwhile|Nrepeat|
           Nloop|Nexit|Nreturn|Nwith|Ntrap
           |Ndispose. (*!*)


              class     subcl     obj      left      right     link      
              ---------------------------------------------------------

design        Nvar                var                          nextexpr
              Nvarpar             varpar                       nextexpr
              Nfield              field    design              nextexpr
              Nderef                       design              nextexpr
              Nindex                       design    expr      nextexpr
              Nguard                       design              nextexpr (typ = guard type)
              Neguard                      design              nextexpr (typ = guard type)
              Ntype               type                         nextexpr
              Nproc     normal    proc                         nextexpr
                        super     proc                         nextexpr


expr          design
              Nconst              const                                 (val = node^.conval)
              Nupto                        expr      expr      nextexpr 
              Nmop      not                expr                nextexpr
                        minus              expr                nextexpr
                        is        tsttype  expr                nextexpr
                        conv               expr                nextexpr
                        abs                expr                nextexpr
                        cap                expr                nextexpr
                        odd                expr                nextexpr
                        adr                expr                nextexpr SYSTEM.ADR
                        cc                 Nconst              nextexpr SYSTEM.CC
                        val                expr                nextexpr SYSTEM.VAL
              Ndop      times              expr      expr      nextexpr
                        slash              expr      expr      nextexpr
                        div                expr      expr      nextexpr
                        mod                expr      expr      nextexpr
                        and                expr      expr      nextexpr
                        plus               expr      expr      nextexpr
                        minus              expr      expr      nextexpr
                        or                 expr      expr      nextexpr
                        eql                expr      expr      nextexpr
                        neq                expr      expr      nextexpr
                        lss                expr      expr      nextexpr
                        leq                expr      expr      nextexpr
                        grt                expr      expr      nextexpr
                        geq                expr      expr      nextexpr
                        in                 expr      expr      nextexpr
                        ash                expr      expr      nextexpr
                        msk                expr      Nconst    nextexpr
                        len                design    Nconst    nextexpr
                        bit                expr      expr      nextexpr SYSTEM.BIT
                        lsh                expr      expr      nextexpr SYSTEM.LSH
                        rot                expr      expr      nextexpr SYSTEM.ROT
              Ncall               fpar     design    nextexpr  nextexpr

nextexpr      NIL
              expr

ifstat        NIL
              Nif                          expr      stat      ifstat

casestat      Ncaselse                     sglcase   stat            (minmax = node^.conval)

sglcase       NIL
              Ncasedo                      Nconst    stat      sglcase

stat          NIL
              Ninittd                                          stat     (of node^.typ)
              Nenter              proc     stat      stat      stat     (proc=NIL for mod)
              Nassign   assign             design    expr      stat
                        newfn              design              stat
                        incfn              design    expr      stat
                        decfn              design    expr      stat
                        inclfn             design    expr      stat
                        exclfn             design    expr      stat
                        copyfn             design    expr      stat
                        getfn              design    expr      stat     SYSTEM.GET
                        putfn              expr      expr      stat     SYSTEM.PUT
                        getrfn             design    Nconst    stat     SYSTEM.GETREG
                        putrfn             Nconst    expr      stat     SYSTEM.PUTREG
                        sysnewfn           design    expr      stat     SYSTEM.NEW
                        movefn             expr      expr      stat     SYSTEM.MOVE
                                                                        (right^.link = 3rd par)
              Ncall               fpar     design    nextexpr  stat
              Nifelse                      ifstat    stat      stat
              Ncase                        expr      casestat  stat
              Nwhile                       expr      stat      stat
              Nrepeat                      stat      expr      stat
              Nloop                        stat                stat 
              Nexit                                            stat 
              Nreturn             proc     nextexpr            stat     (proc = NIL for mod)
              Nwith                        ifstat    stat      stat
              Ntrap                                  expr      stat
              Ndispose                     design              stat     (*!*)
*)

  CONST
    MAXIMPS* = 61; (** maximum number of imported modules *) (*!*) (* must be < 128 *)

  VAR
    topScope*: Object; (* pointer to current top level object in parse tree ? *)
    undftyp*, bytetyp*, booltyp*, 
    chartyp*, sinttyp*, inttyp*, 
    linttyp*, realtyp*, lrltyp*, 
    settyp*, stringtyp*, niltyp*, 
    notyp*, 
    sysptrtyp*: Struct; (* SYSTEM.PTR *)
    nofGmod*: SHORTINT;  (*nof imports*)
    GlbMod*:  ARRAY MAXIMPS OF Object;  (* GlbMod[i]^.mode = exported module number *)
    SYSimported*: BOOLEAN; (* TRUE if module SYSTEM imported ? *)
    defModule*: BOOLEAN; (*! true if module is a definition module *)
    
  CONST
    (* object modes *)
    MODE_VAR* = 1; (* variable or value parameter *)
    VarPar* = 2; 
    MODE_CON* = 3; 
    Fld* = 4; 
    MODE_TYPE*=5;
    LProc* = 6; 
    XProc* = 7;
    SProc* = 8; (* built in function *)
    CProc* = 9; 
    IProc* = 10; 
    Mod* = 11; 
    Head* = 12; 
    TProc* = 13;
    WProc* = 14; (*!*)
    MODE_CDECLPROC*=15;
    MODE_VARSTPAR*=16; (* statically typed VAR parameter; may be declared 
                          only in definition modules *)
    MODE_DLLVAR*=17; (* variable imported from a DLL *)
    MODE_DLLTYPE*=18;

    (* structure forms *)
    (* constant values need to adhere to the following order:
       Byte < Char < SInt < Int < LInt *)
    Undef* = 0; Byte* = 1; Bool* = 2; Char* = 3; SInt* = 4; Int* = 5; LInt* = 6;
    Real* = 7; LReal* = 8; Set* = 9; String* = 10; NilTyp* = 11; NoTyp* = 12;
    Pointer* = 13; ProcTyp* = 14; Comp* = 15;
    
    (* composite structure forms *)
    Basic* = 1; Array* = 2; DynArr* = 3; Record* = 4;

    (*function number*)
    assign = 0;
    haltfn = 0; newfn = 1; absfn = 2; capfn = 3; ordfn = 4;
    entierfn = 5; oddfn = 6; minfn = 7; maxfn = 8; chrfn = 9;
    shortfn = 10; longfn = 11; sizefn = 12; incfn = 13; decfn = 14;
    inclfn = 15; exclfn = 16; lenfn = 17; copyfn = 18; ashfn = 19; assertfn = 32;
    disposefn = 33; (*!*)
    
    (*SYSTEM function number*)
    adrfn = 20; ccfn = 21; lshfn = 22; rotfn = 23;
    SYSTEM_GETFN* = 24;
    SYSTEM_PUTFN* = 25; 
    SYSTEM_GETRFN*= 26;
    SYSTEM_PUTRFN*= 27;
    bitfn = 28; valfn = 29; sysnewfn = 30; movefn* = 31;
    SYSTEMFN_XOR*=34;
    SYSTEMFN_OR*=35;
    SYSTEMFN_AND*=36;
    SYSTEMFN_NOT*=37;
    SYSTEMFN_HIWORD*=38;
    SYSTEMFN_LOWORD*=39;
    SYSTEMFN_MKLONG*=40;
    
    (* module visibility of objects *)
    internal* = 0; 
    internalR* = 1; (* internal read only - read only var parameter ? *)
    external* = 2; 
    externalR* = 3; (*!*)

    FIRSTSTR = 16;
    MAXSTRUCT = 1023;  (* changed from 255 to 1023, 26.08.96 *)
    maxUndPtr*= 64;
    NotYetExp = 0;
    
  VAR
    universe, syslink: Object;
    strno, udpinx: INTEGER;
    nofExp: SHORTINT;
    undPtr: ARRAY maxUndPtr OF Struct;
    first: BOOLEAN; (*!L*)

  PROCEDURE Init*;
  BEGIN 
    topScope:=universe; 
    strno:=0; 
    udpinx:=0; 
    nofGmod:=0; 
    SYSimported:=FALSE;
    defModule:=FALSE; (*!*)
    IF first THEN 
      OPM.Init1; 
      first:=FALSE 
    END; (*!L*)
  END Init;

  PROCEDURE Close*;
  VAR 
    i: INTEGER;
  BEGIN 
    i:=0;
    WHILE i < MAXIMPS DO 
      GlbMod[i]:=NIL;  (* garbage collection *)
      INC(i);
    END  
  END Close;

  PROCEDURE Err(code:INTEGER);
  BEGIN 
    OPM.Err(code);
  END Err;
  
  PROCEDURE NewConst*(): Const;
  VAR 
    const: Const;
  BEGIN 
    NEW(const); 
    (*const^.ext:=NIL;*) 
    RETURN const;
  END NewConst;
  
  PROCEDURE NewObj*(): Object;
  VAR 
    obj: Object;
  BEGIN 
    NEW(obj); 
    (*obj^.left:=NIL; obj^.right:=NIL; obj^.link:=NIL; obj^.scope:=NIL; *)
    (*obj^.typ:=NIL; obj^.conval:=NIL;*) 
    obj^.symTableInx:=-1;
    obj^.fromDLL:=FALSE;
    obj^.debugInfo:=NIL;
    RETURN obj;
  END NewObj;

  PROCEDURE NewDebugInfo*():DebugInfo;
  VAR
    dbg:DebugInfo;
  BEGIN
    NEW(dbg);
    IF dbg#NIL THEN
      dbg^.codeDebugStart:=0;
      dbg^.codeDebugEnd:=0;
      dbg^.procLen:=0;
      dbg^.type:=-1;
    END;
    RETURN dbg;
  END NewDebugInfo;

  PROCEDURE NewStr*(form, comp: SHORTINT): Struct;
  VAR 
    typ: Struct;
  BEGIN 
    NEW(typ); 
    (*typ^.link:=NIL; typ^.strobj:=NIL;*)
    typ^.form:=form; 
    typ^.comp:=comp;
    (*typ^.mno:=0; typ^.ref:=0; typ^.sysflag:=0; typ^.extlev:=0; typ^.n:=0;*)
    typ^.tdadr:=OPM.TDAdrUndef; 
    typ^.offset:=OPM.TDAdrUndef;
    typ^.txtpos:=OPM.errpos; 
    typ^.size:=-1;
    typ^.BaseTyp:=undftyp; 
    typ^.debugType:=-1;
    RETURN typ
  END NewStr;
  
  PROCEDURE NewNode*(class: SHORTINT): Node;
  VAR 
    node: Node;
  BEGIN
    NEW(node); 
    node^.class:=class; 
    node^.left:=NIL; node^.right:=NIL; node^.link:=NIL;
    node^.typ:=NIL; node^.obj:=NIL; node^.conval:=NIL;
    node^.endLine:=-1;
    RETURN node
  END NewNode;
  
  PROCEDURE NewExt*(): ConstExt;
  VAR 
    ext: ConstExt;
  BEGIN 
    NEW(ext); 
    RETURN ext
  END NewExt;

  (** 
    Search the scope of object mod for the symbol name currently in the 
    scanner (OPS.name). Return NIL or a pointer to the found object.
    An object can not be found if it is a type (obj^.mode=Typ) and
    it is not expored.
  *)
  PROCEDURE FindImport*(mod: Object; VAR res: Object);
  VAR 
    obj: Object;
  BEGIN 
    obj:=mod^.scope;
    LOOP
      IF obj = NIL THEN EXIT END ;
      IF OPS.name < obj^.name THEN 
        obj:=obj^.left
      ELSIF OPS.name > obj^.name THEN 
        obj:=obj^.right
      ELSE (*found*)
        IF ((obj^.mode=MODE_DLLTYPE) OR (obj^.mode = MODE_TYPE)) & (obj^.vis < external (*!*)) THEN obj:=NIL END;
        EXIT
      END
    END ;
    res:=obj
  END FindImport;

  PROCEDURE Find*(VAR res: Object);
  VAR 
    obj, head: Object;
  BEGIN 
    head:=topScope;
    LOOP 
      obj:=head^.right;
      LOOP
        IF obj = NIL THEN EXIT END ;
        IF OPS.name < obj^.name THEN 
          obj:=obj^.left
        ELSIF OPS.name > obj^.name THEN 
          obj:=obj^.right
        ELSE (*found*) 
          EXIT
        END
      END ;
      IF obj # NIL THEN EXIT END ;
      head:=head^.left;
      IF head = NIL THEN EXIT END
    END ;
    res:=obj
  END Find;

  PROCEDURE FindField*(name: OPS.Name; typ: Struct; VAR res: Object);
  VAR 
    obj: Object;
  BEGIN 
    WHILE typ # NIL DO 
      obj:=typ^.link;
      WHILE obj # NIL DO
        IF name < obj^.name THEN 
          obj:=obj^.left
        ELSIF name > obj^.name THEN 
          obj:=obj^.right
        ELSE (*found*) 
          res:=obj; 
          RETURN
        END
      END ;
      typ:=typ^.BaseTyp
    END ;
    res:=NIL
  END FindField;

  PROCEDURE Insert*(name: OPS.Name; VAR obj: Object);
  VAR 
    ob0, ob1: Object; 
    left: BOOLEAN;
  BEGIN 
    ob0:=topScope; 
    ob1:=ob0^.right; 
    left:=FALSE;
    LOOP
      IF ob1 # NIL THEN
        IF name < ob1^.name THEN 
          ob0:=ob1; 
          ob1:=ob0^.left; 
          left:=TRUE
        ELSIF name > ob1^.name THEN 
          ob0:=ob1; 
          ob1:=ob0^.right; 
          left:=FALSE
        ELSE (*double def*) 
          OPM.CommentedErr(E.MULTIPLY_DEFINED,name); 
          ob0:=ob1; 
          ob1:=ob0^.right
        END
      ELSE (*insert*) 
        ob1:=NewObj(); 
        ob1^.leaf:=TRUE;
        IF left THEN 
          ob0^.left:=ob1 
        ELSE 
          ob0^.right:=ob1 
        END ;
        ob1^.left:=NIL; 
        ob1^.right:=NIL; 
        COPY(name, ob1^.name);
        ob1^.mnolev:=topScope^.mnolev; 
        EXIT
      END
    END ;
    obj:=ob1
  END Insert;

  (**
     Creates a new object which serves as the root of a new scope.
     If owner is not NIL, the .scope entry of the owner is set
     to the new scope.
     The global topScope variable is set to the new scope.
  *)
  PROCEDURE OpenScope*(level: SHORTINT; owner:Object);
  VAR 
    head: Object;
  BEGIN 
    head:=NewObj();
    head^.mode:=Head; 
    head^.mnolev:=level; 
    head^.link:=owner;
    IF owner # NIL THEN owner^.scope:=head END;
    head^.left:=topScope; 
    head^.right:=NIL; 
    head^.scope:=NIL; 
    topScope:=head
  END OpenScope;

  PROCEDURE CloseScope*;
  BEGIN 
    topScope:=topScope^.left
  END CloseScope;

  (* 
     If an object with the name of the new object obj already exists,
     a pointer to that object is returned in old.
     Otherwise the object obj is inserted into the binary search tree root.
  *)
  PROCEDURE InsertImport(obj, root: Object; VAR old: Object);
  VAR 
    ob0, ob1: Object; 
    left: BOOLEAN;
  BEGIN 
    ob0:=root; 
    ob1:=ob0^.right; 
    left:=FALSE;
    LOOP
      IF ob1 # NIL THEN
        IF obj^.name < ob1^.name THEN 
          ob0:=ob1; 
          ob1:=ob1^.left; 
          left:=TRUE;
        ELSIF obj^.name > ob1^.name THEN 
          ob0:=ob1; 
          ob1:=ob1^.right; 
          left:=FALSE
        ELSE 
          old:=ob1; 
          EXIT
        END
      ELSE 
        ob1:=obj;
        IF left THEN ob0^.left:=ob1 ELSE ob0^.right:=ob1 END ;
        ob1^.left:=NIL; 
        ob1^.right:=NIL; 
        ob1^.mnolev:=root^.mnolev; 
        old:=NIL; 
        EXIT
      END
    END
  END InsertImport;

  PROCEDURE ReadId(VAR name: ARRAY OF CHAR; VAR len: LONGINT);
  VAR 
    i: INTEGER; 
    ch: CHAR;
  BEGIN i:=0;
    REPEAT
      OPM.SymRCh(ch); 
      name[i]:=ch; 
      INC(i)
    UNTIL ch = 0X;
    len:=i
  END ReadId;
  
  PROCEDURE WriteId(VAR name: ARRAY OF CHAR);
  VAR 
    i: INTEGER; 
    ch: CHAR;
  BEGIN i:=0;
    REPEAT 
      ch:=name[i]; 
      OPM.SymWCh(ch); 
      INC(i)
    UNTIL ch = 0X
  END WriteId;
  
  PROCEDURE Import*(VAR aliasName, impName, selfName: OPS.Name);
  VAR
    moduleFromDLL:BOOLEAN;
    m, si,class: INTEGER;
    i,s:LONGINT;
    k, len: LONGINT; rval: REAL;
    ch: CHAR; done: BOOLEAN;
    nofLmod, strno, parlev, fldlev: INTEGER;
    obj, head, old: Object;
    typ: Struct;
    ext: ConstExt;
    mname: OPS.Name;
    LocMod:  ARRAY MAXIMPS + 1 OF Object;
    struct:  ARRAY MAXSTRUCT OF Struct; 
    param, lastpar, fldlist, lastfld: ARRAY 6 OF Object;

    PROCEDURE reverseList(p: Object; mnolev: SHORTINT);
    VAR 
      q, r: Object;
    BEGIN 
      q:=NIL;
      WHILE p # NIL DO 
        p^.mnolev:=mnolev;
        r:=p^.link; 
        p^.link:=q; 
        q:=p; 
        p:=r;
      END
    END reverseList;
        
  BEGIN 
    nofLmod:=0; 
    strno:=FIRSTSTR;
    parlev:=-1; 
    fldlev:=-1;
    IF impName = "SYSTEM" THEN 
      SYSimported:=TRUE;
      Insert(aliasName, obj); 
      obj^.mode:=Mod; 
      obj^.mnolev:=0; 
      obj^.scope:=syslink;
      obj^.adr:=0; 
      obj^.typ:=notyp
    ELSE 
      moduleFromDLL:=DLLImportList.IsFromDLL(impName);
      OPM.OldSym(impName, FALSE, done);
      IF done THEN
        struct[Undef]:=undftyp; struct[Byte]:=bytetyp;
        struct[Bool]:=booltyp;  struct[Char]:=chartyp;
        struct[SInt]:=sinttyp;  struct[Int]:=inttyp;
        struct[LInt]:=linttyp;  struct[Real]:=realtyp;
        struct[LReal]:=lrltyp;  struct[Set]:=settyp;
        struct[String]:=stringtyp; struct[NilTyp]:=niltyp;
        struct[NoTyp]:=notyp;
        struct[Pointer]:=sysptrtyp;
        NEW(head); (*for bound procedures*)
        LOOP (*read next item from symbol file*)
          OPM.SymRTag(class);
          IF OPM.eofSF() THEN EXIT END ;
          IF (class < TAG_PTR) OR (class = TAG_RO_VAR) OR 
             (class = TAG_TB_PROC) OR 
             (class = TAG_WND_PROC (*!*)) OR 
             (class=TAG_CDECL_PROC) THEN (*object*)
            obj:=NewObj(); 
            obj.fromDLL:=moduleFromDLL;
            m:=0;
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            obj^.typ:=struct[s];
            CASE class OF
              TAG_CONSTANT:
                obj^.mode:=MODE_CON; 
                obj^.conval:=NewConst();
                CASE obj^.typ^.form OF
                  Byte, Char:
                    OPM.SymRCh(ch); 
                    obj^.conval^.intval:=ORD(ch)
                | SInt, Bool:
                    OPM.SymRCh(ch); 
                    i:=ORD(ch);
                    IF i > OPM.MaxSInt THEN i:=i + 2*OPM.MinSInt END;
                    obj^.conval^.intval:=i
                | Int:
                    OPM.SymRInt(obj^.conval^.intval)
                | LInt:
                    OPM.SymRLInt(obj^.conval^.intval)
                | Set:
                    OPM.SymRSet(obj^.conval^.setval)
                | Real:
                    OPM.SymRReal(rval); 
                    obj^.conval^.realval:=rval;
                    obj^.conval^.intval:=OPM.ConstNotAlloc
                | LReal:
                    OPM.SymRLReal(obj^.conval^.realval);
                    obj^.conval^.intval:=OPM.ConstNotAlloc
                | String:
                    obj^.conval^.ext:=NewExt();
                    ReadId(obj^.conval^.ext^, obj^.conval^.intval2);
                    obj^.conval^.intval:=OPM.ConstNotAlloc
                | NilTyp:
                    obj^.conval^.intval:=OPM.nilval
                END
            | TAG_TYPE, TAG_HID_TYPE:
                IF moduleFromDLL THEN obj^.mode:=MODE_DLLTYPE ELSE obj^.mode:=MODE_TYPE END;
                OPM.SymRTag(m);  
                IF obj^.typ^.strobj = NIL THEN obj^.typ^.strobj:=obj END ;
                IF class = 2 THEN obj^.vis:=external ELSE obj^.vis:=internal END
            | TAG_VAR, TAG_RO_VAR:
                IF moduleFromDLL THEN obj^.mode:=MODE_DLLVAR ELSE obj^.mode:=MODE_VAR END;
                IF OPM.ExpVarAdr THEN 
                  OPM.SymRLInt(obj^.adr)
                ELSE 
                  OPM.SymRLInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=s
                END ;
                IF class = TAG_RO_VAR THEN obj^.vis:=externalR ELSE obj^.vis:=external END
            | TAG_IPROC, TAG_XPROC, TAG_CPROC, TAG_TB_PROC, TAG_WND_PROC, TAG_CDECL_PROC: (*!*)
                obj^.conval:=NewConst();
                IF class = TAG_IPROC THEN 
                  obj^.mode:=IProc; 
                  OPM.SymRLInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=s
                ELSIF class = TAG_WND_PROC THEN 
                  obj^.mode:=WProc; 
                  OPM.SymRLInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=s (*!*)
                ELSIF class = TAG_CDECL_PROC THEN (* + 26.08.96 *)
                  obj^.mode:=MODE_CDECLPROC; 
                  OPM.SymRLInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=s;
                ELSIF class = TAG_XPROC THEN 
                  obj^.mode:=XProc; 
                  OPM.SymRLInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=s
                ELSIF class = TAG_CPROC THEN  
                  obj^.mode:=CProc; 
                  ext:=NewExt(); 
                  obj^.conval^.ext:=ext;
                  OPM.SymRCh(ch); 
                  s:=ORD(ch); 
                  ext^[0]:=ch; 
                  i:=1; 
                  obj^.adr:=0;
                  WHILE i <= s DO 
                    OPM.SymRCh(ext^[i]); 
                    INC(i);
                  END
                ELSE 
                  obj^.mode:=TProc; 
                  obj^.vis:=external; 
                  OPM.SymRInt(s);  (* changed 28.08.96 *)
                  typ:=struct[s];
                  OPM.SymRInt(i); (* changed 28.08.96 *) 
                  OPM.SymRInt(s);  (* changed 28.08.96 *)
                  obj^.adr:=10000H*i (*! + s *)
                END ;
                IF obj^.mode # TProc THEN obj^.adr:=OPM.LANotAlloc END; (*!*)
                obj^.linkadr:=OPM.LANotAlloc;  (* link adr *)
                obj^.symTableInx:=-1;
                obj^.conval^.intval:=-1;
                reverseList(lastpar[parlev], LocMod[0]^.mnolev);
                obj^.link:=param[parlev]^.right; DEC(parlev)
            END ;
            ReadId(obj^.name, len);
            IF class = TAG_TB_PROC THEN
              head^.right:=typ^.link; 
              head^.mnolev:=-typ^.mno; 
              InsertImport(obj, head, old); 
              typ^.link:=head^.right;
            ELSE 
              InsertImport(obj, LocMod[m], old);
            END ;
            IF (old # NIL) & ((obj^.mode = MODE_TYPE) OR (obj^.mode=MODE_DLLTYPE)) THEN struct[s]:=old^.typ END
          ELSIF class < TAG_PARAM_LIST THEN (*structure*)
            typ:=NewStr(Undef, Basic); 
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            typ^.BaseTyp:=struct[s];
            OPM.SymRTag(si); (* module ? *)
            typ^.mno:=-LocMod[si]^.mnolev;
            CASE class OF
              TAG_PTR:
                typ^.form:=Pointer; 
                typ^.size:=OPM.PointerSize; 
                typ^.n:=0
            | TAG_PROC:
                typ^.form:=ProcTyp; 
                typ^.size:=OPM.ProcSize; 
                reverseList(lastpar[parlev], -typ^.mno);
                typ^.link:=param[parlev]^.right; 
                DEC(parlev)
            | TAG_ARRAY:
                typ^.form:=Comp; 
                typ^.comp:=Array; 
                OPM.SymRLInt(typ^.size);
                typ^.n:=typ^.size DIV typ^.BaseTyp^.size
            | TAG_OPEN_ARRAY:
                typ^.form:=Comp; 
                typ^.comp:=DynArr;
                OPM.SymRLInt(typ^.size); 
                OPM.SymRInt(typ^.offset);
                IF typ^.BaseTyp^.comp = DynArr THEN 
                  typ^.n:=typ^.BaseTyp^.n + 1
                ELSE 
                  typ^.n:=0
                END
            | TAG_RECORD:
                typ^.form:=Comp; 
                typ^.comp:=Record;
                OPM.SymRLInt(typ^.size); 
                typ^.n:=0;
                reverseList(lastfld[fldlev], -typ^.mno); 
                typ^.link:=fldlist[fldlev]^.right; 
                DEC(fldlev); (* inx! *)
                IF typ^.BaseTyp = notyp THEN 
                  typ^.BaseTyp:=NIL; 
                  typ^.extlev:=0
                ELSE 
                  typ^.extlev:=typ^.BaseTyp^.extlev + 1
                END ;
                OPM.SymRLInt(typ^.tdadr)
            END ;
            struct[strno]:=typ; INC(strno)
          ELSIF class = TAG_PARAM_LIST THEN (*parameter list start*)
            obj:=NewObj(); 
            obj^.mode:=Head; 
            obj^.right:=NIL;
            IF parlev < 5 THEN 
              INC(parlev); 
              param[parlev]:=obj; 
              lastpar[parlev]:=NIL
            ELSE 
              Err(E.TOO_MANY_NESTED_REC)
            END
          ELSIF (class < TAG_FIELD_LIST) OR 
                (class = TAG_RO_VAR_PARAM) OR
                (class = TAG_STATICTYPEDVAR_PARAM) THEN (*parameter*)
            obj:=NewObj();
            IF class = TAG_VAL_PARAM THEN  (* !C! *)
              obj^.mode:=MODE_VAR;
              obj^.vis:=internal;
            ELSIF class=TAG_STATICTYPEDVAR_PARAM THEN
              obj^.mode:=MODE_VARSTPAR;
              obj^.vis:=internal;
            ELSIF class=TAG_RO_VAR_PARAM THEN 
              obj^.mode:=VarPar;
              obj^.vis:=internalR;
            ELSE
              obj^.mode:=VarPar;
              obj^.vis:=internal;
            END;
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            obj^.typ:=struct[s];
            IF OPM.ExpParAdr THEN OPM.SymRLInt(obj^.adr) END ;
            ReadId(obj^.name, len);
            obj^.link:=lastpar[parlev]; 
            lastpar[parlev]:=obj;
            IF param[parlev]^.right = NIL THEN param[parlev]^.right:=obj END
          ELSIF class = TAG_FIELD_LIST THEN (*start field list*)
            obj:=NewObj(); 
            obj^.mode:=Head; 
            obj^.right:=NIL;
            IF fldlev < 5 THEN 
              INC(fldlev); 
              fldlist[fldlev]:=obj; 
              lastfld[fldlev]:=NIL
            ELSE 
              Err(E.TOO_MANY_NESTED_REC)
            END
          ELSIF (class = TAG_FIELD) OR (class = TAG_RO_FIELD) THEN (*field*)
            obj:=NewObj(); 
            obj^.mode:=Fld; 
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            obj^.typ:=struct[s]; 
            OPM.SymRLInt(obj^.adr);
            ReadId(obj^.name, len);
            obj^.link:=lastfld[fldlev]; 
            lastfld[fldlev]:=obj;
            InsertImport(obj, fldlist[fldlev], old);
            IF class = TAG_RO_FIELD THEN obj^.vis:=externalR ELSE obj^.vis:=external END
          ELSIF (class = TAG_HID_PTR) OR (class = TAG_HID_PROC) THEN (*hidden pointer or proc*)
            obj:=NewObj(); 
            obj.fromDLL:=moduleFromDLL;
            obj^.mode:=Fld; 
            OPM.SymRLInt(obj^.adr);
            IF class = TAG_HID_PTR THEN 
              obj^.name:=HdPtrName
            ELSE 
              obj^.name:=HdProcName
            END ;
            obj^.typ:=notyp; 
            obj^.vis:=internal;
            obj^.link:=lastfld[fldlev]; 
            lastfld[fldlev]:=obj;
            IF fldlist[fldlev]^.right = NIL THEN
              fldlist[fldlev]^.right:=obj
            END
          ELSIF class = TAG_FIXUP THEN (*fixup pointer typ*)
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            typ:=struct[s]; 
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            IF typ^.BaseTyp = undftyp THEN typ^.BaseTyp:=struct[s] END
          ELSIF class = TAG_SYS THEN (*sysflag*)
            OPM.SymRInt(s);   (* changed 28.08.96 *)
            typ:=struct[s]; 
            OPM.SymRTag(si); 
            typ^.sysflag:=si;
          ELSIF class = TAG_MODULE THEN (*module anchor*)
            OPM.SymRLInt(k); 
            ReadId(mname, len);
            IF mname = selfName THEN Err(E.RECURSIVE_IMPORT) END ;
            i:=0;
            WHILE (i < nofGmod) & (mname # GlbMod[i]^.name) DO
              INC(i)
            END ;
            IF i < nofGmod THEN (*module already present*)
              IF k # GlbMod[i]^.adr THEN Err(E.KEY_INCONSISTENT) END ;
              obj:=GlbMod[i]
            ELSE 
              obj:=NewObj();
              IF nofGmod < MAXIMPS THEN 
                GlbMod[nofGmod]:=obj; 
                INC(nofGmod)
              ELSE 
                Err(E.TOO_MANY_IMPORTED_MOD)
              END ;
              obj^.mode:=NotYetExp; 
              COPY(mname, obj^.name);
              obj^.adr:=k; 
              obj^.mnolev:=-nofGmod; 
              obj^.right:=NIL;
              obj^.fromDLL:=moduleFromDLL;
            END ;
            IF nofLmod < MAXIMPS + 1 THEN 
              LocMod[nofLmod]:=obj; 
              INC(nofLmod);
            ELSE 
              Err(E.TOO_MANY_IMPORTED_MOD)
            END
          ELSIF class = TAG_NOF_METHODS THEN (*nof methods*)
            OPM.SymRInt(s);   (* changed 28.08.96 *)
            typ:=struct[s]; 
            OPM.SymRInt(s);   (* changed 28.08.96 *)
            typ^.n:=s
          ELSIF class = TAG_HID_TB_PROC THEN (*hidden method*)
            obj:=NewObj(); 
            obj^.mode:=TProc; 
            obj^.name:=HdTProcName; 
            obj^.typ:=undftyp;
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            typ:=struct[s]; 
            obj^.mnolev:=-typ^.mno;
            OPM.SymRInt(i);   (* changed 28.08.96 *)
            OPM.SymRInt(s);  (* changed 28.08.96 *)
            obj^.adr:=10000H*i (*! + s *);
            obj^.linkadr:=OPM.LANotAlloc; 
            obj^.symTableInx:=-1;
            obj^.vis:=internal;
            obj^.link:=NewObj(); 
            obj^.link^.typ:=typ; 
            obj^.fromDLL:=moduleFromDLL;
            old:=typ^.link;
            IF old = NIL THEN 
              typ^.link:=obj
            ELSE 
              WHILE old^.left # NIL DO old:=old^.left END ;
              old^.left:=obj
            END
          END
        END (*LOOP*) ;
        Insert(aliasName, obj);
        obj^.mode:=Mod; 
        obj^.scope:=LocMod[0]^.right;
        obj^.mnolev :=LocMod[0]^.mnolev; 
        obj^.typ:=notyp;
        OPM.CloseOldSym
      END
    END
  END Import;


  PROCEDURE^ OutStr(typ: Struct);

  PROCEDURE^ OutObjs(obj: Object);

  PROCEDURE ^OutFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);

  PROCEDURE OutPars(par: Object);
  BEGIN
    OPM.SymWTag(TAG_PARAM_LIST);
    WHILE par # NIL DO
      OutStr(par^.typ);
      IF par^.mode = MODE_VAR THEN 
        OPM.SymWTag(TAG_VAL_PARAM)
      ELSIF par^.mode = MODE_VARSTPAR THEN
        OPM.SymWTag(TAG_STATICTYPEDVAR_PARAM); (* !C! *)
      ELSIF par^.vis = internalR THEN 
        OPM.SymWTag(TAG_RO_VAR_PARAM) (*!*)
      ELSE 
        OPM.SymWTag(TAG_VAR_PARAM)
      END ;
      OPM.SymWInt(par^.typ^.ref);  (* changed 28.08.96 *)
      IF OPM.ExpParAdr THEN OPM.SymWLInt(par^.adr) END;
      WriteId(par^.name); par:=par^.link
    END
  END OutPars;

  PROCEDURE OutHdFld(typ: Struct; fld: Object; adr: LONGINT);
  VAR 
    i, n: LONGINT; 
    btyp: Struct;
  BEGIN
    IF typ^.comp = Record THEN 
      OutFlds(typ^.link, adr, FALSE)
    ELSIF typ^.comp = Array THEN 
      btyp:=typ^.BaseTyp; 
      n:=typ^.n;
      WHILE btyp^.comp = Array DO 
        n:=btyp^.n * n; 
        btyp:=btyp^.BaseTyp 
      END;
      IF (btyp^.form = Pointer) OR (btyp^.comp = Record) THEN 
        i:=0;
        WHILE i < n DO 
          OutHdFld(btyp, fld, adr); 
          INC(adr, btyp^.size); 
          INC(i) 
        END
      END
    ELSIF OPM.ExpHdPtrFld & ((typ^.form = Pointer) & (typ^.sysflag = 0) OR (fld^.name = HdPtrName)) THEN
      OPM.SymWTag(TAG_HID_PTR); 
      OPM.SymWLInt(adr)
    ELSIF OPM.ExpHdProcFld & ((typ^.form = ProcTyp) & (typ^.sysflag = 0) OR (fld^.name = HdProcName)) THEN
      OPM.SymWTag(TAG_HID_PROC); 
      OPM.SymWLInt(adr)
    END
  END OutHdFld;

  PROCEDURE OutFlds(fld: Object; adr: LONGINT; visible: BOOLEAN);
  BEGIN
    IF visible THEN OPM.SymWTag(TAG_FIELD_LIST) END ;
    WHILE (fld # NIL) & (fld^.mode = Fld) DO
      IF (fld^.vis >= external) & visible THEN (*!*)
        OutStr(fld^.typ);
        IF fld^.vis = external THEN OPM.SymWTag(TAG_FIELD) ELSE OPM.SymWTag(TAG_RO_FIELD) END;
        OPM.SymWInt(fld^.typ^.ref);  (* changed 28.08.96 *)
        OPM.SymWLInt(fld^.adr); 
        WriteId(fld^.name)
      ELSE 
        OutHdFld(fld^.typ, fld, fld^.adr + adr)
      END ;
      fld:=fld^.link
    END
  END OutFlds;

  PROCEDURE OutStr(typ: Struct);
  VAR 
    m, em, r: INTEGER; 
    btyp: Struct; 
    mod: Object;
  BEGIN
    IF typ^.ref < 0 THEN 
      OPM.Mark(E.RECURSIVE_EXPORT, typ^.txtpos, "")
    ELSIF typ^.ref = 0 THEN
      typ^.ref:=-1;
      m:=typ^.mno; 
      btyp:=typ^.BaseTyp;
      IF m > 0 THEN 
        mod:=GlbMod[m-1]; 
        em:=mod^.mode;
        IF em = NotYetExp THEN
          mod^.mode:=nofExp; 
          m:=nofExp; 
          INC(nofExp);
          OPM.SymWTag(TAG_MODULE); 
          OPM.SymWLInt(mod^.adr); 
          WriteId(mod^.name)
        ELSE 
          m:=em
        END
      END ;
      CASE typ^.form OF
        Undef .. NoTyp:
      | Pointer:
          OPM.SymWTag(TAG_PTR);
          IF btyp^.ref > 0 THEN 
            OPM.SymWInt(btyp^.ref) (* changed 28.08.96 *)
          ELSE 
            OPM.SymWInt(Undef);  (* changed 28.08.96 *)
            IF udpinx < maxUndPtr THEN 
              undPtr[udpinx]:=typ; 
              INC(udpinx) 
            ELSE 
              Err(E.TOO_MANY_POINTER_TYPES) 
            END
          END ;
          OPM.SymWTag(m)
      | ProcTyp:
          OutStr(btyp); 
          OutPars(typ^.link);    (* parameter list *)
          OPM.SymWTag(TAG_PROC);
          OPM.SymWInt(btyp^.ref);   (* changed 28.08.96 *)
          OPM.SymWTag(m)
      | Comp:
          IF typ^.comp = Array THEN
            OutStr(btyp); 
            OPM.SymWTag(TAG_ARRAY); 
            OPM.SymWInt(btyp^.ref);  (* changed 28.08.96 *)
            OPM.SymWTag(m); 
            OPM.SymWLInt(typ^.size)
          ELSIF typ^.comp = DynArr THEN
            OutStr(btyp); 
            OPM.SymWTag(TAG_OPEN_ARRAY); 
            OPM.SymWInt(btyp^.ref);  (* changed 28.08.96 *)
            OPM.SymWTag(m);
            OPM.SymWLInt(typ^.size); 
            OPM.SymWInt(typ^.offset)
          ELSE (* typ^.comp = Record *)
            IF btyp = NIL THEN 
              r:=NoTyp
            ELSE 
              OutStr(btyp); 
              r:=btyp^.ref
            END ;
            OutFlds(typ^.link, 0, TRUE); 
            OPM.SymWTag(TAG_RECORD); 
            OPM.SymWInt(r);  (* changed 28.08.96 *)
            OPM.SymWTag(m);
            OPM.SymWLInt(typ^.size);
            OPM.SymWLInt(typ^.tdadr)
          END
      END ;
      IF typ^.sysflag # 0 THEN 
        OPM.SymWTag(TAG_SYS); 
        OPM.SymWInt(strno);  (* changed 28.08.96 *)
        OPM.SymWTag(typ^.sysflag) 
      END ;
      IF (typ^.comp = Record) & (typ^.n > 0) THEN
        OPM.SymWTag(TAG_NOF_METHODS); 
        OPM.SymWInt(strno);  (* changed 28.08.96 *)
        OPM.SymWInt(SHORT(typ^.n))  (* changed 28.08.96 *)
      END ;
      IF typ^.strobj # NIL THEN
        IF typ^.strobj^.vis >= external (*!*) THEN 
          OPM.SymWTag(TAG_TYPE);
        ELSE 
          OPM.SymWTag(TAG_HID_TYPE);
        END ;
        OPM.SymWInt(strno);  (* changed 28.08.96 *)
        OPM.SymWTag(m); 
        WriteId(typ^.strobj^.name)
      END ;
      typ^.ref:=strno; INC(strno);
      IF strno > MAXSTRUCT THEN Err(E.TOO_MANY_EXPORTED_REC) END ;
      IF typ^.comp = Record THEN OutObjs(typ^.link) END (*bound procedures*)
    END
  END OutStr;

  PROCEDURE OutTyps(obj: Object);
  VAR 
    strobj: Object;
  BEGIN
    IF obj # NIL THEN
      OutTyps(obj^.left); 
      IF (obj^.vis >= external (*!*)) & ((obj^.mode = MODE_TYPE) OR (obj^.mode=MODE_DLLTYPE)) THEN
        IF obj^.typ^.ref = 0 THEN OutStr(obj^.typ) END;
        strobj:=obj^.typ^.strobj;
        IF (strobj # obj) & (strobj # NIL) THEN
          OPM.SymWTag(TAG_TYPE); 
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          OPM.SymWTag(0); (* module *)
          WriteId(obj^.name)
        END
      END ;
      OutTyps(obj^.right)
    END
  END OutTyps;

  PROCEDURE OutObjs(obj: Object);
  VAR 
    f, m: INTEGER; 
    rval: REAL; 
    ext: ConstExt; 
    typ: Struct; 
    k: LONGINT;
  BEGIN
    IF obj # NIL THEN
      OutObjs(obj^.left);
      IF (obj^.vis >= external (*!*)) OR (obj^.mode = TProc) THEN
        (* for exported items and all type bound procedures: *)
        IF obj^.mode = MODE_VAR THEN
          OutStr(obj^.typ);
          IF obj^.vis = externalR THEN OPM.SymWTag(TAG_RO_VAR) ELSE OPM.SymWTag(TAG_VAR) END ;
          OPM.SymWInt(obj^.typ^.ref); (* changed 28.08.96 *)
          IF OPM.ExpVarAdr THEN 
            OPM.SymWLInt(obj^.adr)
          ELSE 
            OPM.SymWLInt(SHORT(obj^.adr)) (* changed 28.08.96 *)
          END ;
          WriteId(obj^.name)
        ELSIF obj^.mode = MODE_CON THEN
          OPM.SymWTag(TAG_CONSTANT); 
          f:=obj^.typ^.form; 
          OPM.SymWInt(f); (* changed 28.08.96 *)
          CASE f OF
             Byte, Char:
              OPM.SymWCh(CHR(obj^.conval^.intval))
          | Bool, SInt:
              k:=obj^.conval^.intval;
              IF k < 0 THEN k:=k - 2*OPM.MinSInt END ;
              OPM.SymWCh(CHR(k))
          | Int:
              OPM.SymWInt(obj^.conval^.intval)
          | LInt:
              OPM.SymWLInt(obj^.conval^.intval)
          | Set:
              OPM.SymWSet(obj^.conval^.setval)
          | Real:
              rval:=SHORT(obj^.conval^.realval); 
              OPM.SymWReal(rval)
          | LReal:
              OPM.SymWLReal(obj^.conval^.realval)
          | String:
              WriteId(obj^.conval^.ext^)
          | NilTyp:
          ELSE 
            Err(E.ILLEGAL_OBJ_USE);
          END ;
          WriteId(obj^.name)
        ELSIF obj^.mode = XProc THEN
          OutStr(obj^.typ); 
          OutPars(obj^.link); 
          OPM.SymWTag(TAG_XPROC);
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          OPM.SymWLInt(obj^.adr);  (* changed 28.08.96 *)
          WriteId(obj^.name)
        ELSIF obj^.mode = WProc THEN (*!+*)
          OutStr(obj^.typ); 
          OutPars(obj^.link); 
          OPM.SymWTag(TAG_WND_PROC);
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          OPM.SymWLInt(obj^.adr);  (* changed 28.08.96 *)
          WriteId(obj^.name) (*!-*)
        ELSIF obj^.mode = MODE_CDECLPROC THEN (* + 26.08.96 *)
          OutStr(obj^.typ); 
          OutPars(obj^.link); 
          OPM.SymWTag(TAG_CDECL_PROC);
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          OPM.SymWLInt(obj^.adr);  (* changed 28.08.96 *)
          WriteId(obj^.name) 
        ELSIF obj^.mode = IProc THEN
          OutStr(obj^.typ); 
          OutPars(obj^.link); 
          OPM.SymWTag(TAG_IPROC);
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          OPM.SymWLInt(obj^.adr);  (* changed 28.08.96 *)
          WriteId(obj^.name)
        ELSIF obj^.mode = CProc THEN
          OutStr(obj^.typ); 
          OutPars(obj^.link); 
          OPM.SymWTag(TAG_CPROC);
          OPM.SymWInt(obj^.typ^.ref);  (* changed 28.08.96 *)
          ext:=obj^.conval^.ext;
          m:=ORD(ext^[0]); 
          f:=1; 
          OPM.SymWCh(CHR(m));
          WHILE f <= m DO OPM.SymWCh(ext^[f]); INC(f) END ;
          WriteId(obj^.name)
        ELSIF obj^.mode = TProc THEN
          typ:=obj^.link^.typ; 
          IF typ^.form = Pointer THEN typ:=typ^.BaseTyp END ;
          IF (typ^.BaseTyp # NIL) & 
             (obj^.adr DIV 10000H < typ^.BaseTyp^.n) & 
             (obj^.vis < external (*!*)) THEN
            OPM.Mark(E.OVERRIDING_METHOD_NOT_EXPORTED, typ^.txtpos,"")
            (* hidden and overriding, not detected in OPP because 
               record exported indirectly or via aliasing *)
          END ;
          IF OPM.ExpHdTProc OR (obj^.vis >= external (*!*)) THEN
            IF obj^.vis >= external (*!*) THEN 
              OutStr(obj^.typ); 
              OutPars(obj^.link);
              OPM.SymWTag(TAG_TB_PROC); 
              OPM.SymWInt(obj^.typ^.ref) (* changed 28.08.96 *)
            ELSE 
              OPM.SymWTag(TAG_HID_TB_PROC)
            END ;
            OPM.SymWInt(typ^.ref); 
            OPM.SymWInt(SHORT(obj^.adr DIV 10000H));  (* changed 28.08.96 *)
            OPM.SymWInt(SHORT(obj^.adr MOD 10000H));   (* changed 28.08.96 *)
            IF obj^.vis >= external (*!*) THEN WriteId(obj^.name) END
          END
        ELSIF obj^.mode=MODE_DLLVAR THEN
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPT.OutObjs");
        END
      END ;
      OutObjs(obj^.right)
    END
  END OutObjs;

  (* write new symbol file in temporary file; delete old one and rename tmp 
     if they are different *)
  PROCEDURE Export*(VAR modName: OPS.Name; VAR newSF: BOOLEAN; VAR key: LONGINT);
  VAR 
    i: INTEGER; 
    done: BOOLEAN;
    oldkey: LONGINT;
    typ: Struct;
  BEGIN
    OPM.NewSym(modName, done);
    IF done THEN 
      strno:=FIRSTSTR;
      OPM.SymWTag(TAG_MODULE); 
      OPM.SymWLInt(key);
      OPM.OldSym(modName, TRUE, done); (*!*)
      WriteId(modName); 
      nofExp:=1;
      OutTyps(topScope^.right); 
      OutObjs(topScope^.right); i:=0;
      WHILE i < udpinx DO
        typ:=undPtr[i]; 
        undPtr[i]:=NIL;  (*garbage collection*)
        INC(i); 
        OutStr(typ^.BaseTyp);
        OPM.SymWTag(TAG_FIXUP); (*fixup*)
        OPM.SymWInt(typ^.ref);   (* changed 28.08.96 *)
        OPM.SymWInt(typ^.BaseTyp^.ref)  (* changed 28.08.96 *)
      END ;
      IF OPM.noerr THEN
        (*! OPM.OldSym(modName, TRUE, done); *)
        IF done THEN (*compare*)
          IF OPM.EqualSym(oldkey) THEN 
            OPM.DeleteNewSym; 
            newSF:=FALSE; 
            key:=oldkey
          ELSIF newSF THEN 
            OPM.RegisterNewSym(modName)
          ELSE 
            OPM.DeleteNewSym; 
            Err(E.NO_NEW_SYM_FILE);
          END
        ELSE 
          OPM.RegisterNewSym(modName); 
          newSF:=TRUE
        END
      ELSE 
        OPM.DeleteNewSym; newSF:=FALSE
      END
    ELSE newSF:=FALSE
    END
  END Export;

  PROCEDURE InitStruct(VAR typ: Struct; form: SHORTINT);
  BEGIN 
    typ:=NewStr(form, Basic); 
    typ^.ref:=form; 
    typ^.size:=OPM.ByteSize;
    typ^.tdadr:=0; 
    typ^.offset:=0; 
    typ^.strobj:=NewObj()
  END InitStruct;

  PROCEDURE EnterBoolConst(name: OPS.Name; value: LONGINT);
  VAR 
    obj: Object;
  BEGIN 
    Insert(name, obj); 
    obj^.conval:=NewConst();
    obj^.mode:=MODE_CON; 
    obj^.typ:=booltyp; 
    obj^.conval^.intval:=value
  END EnterBoolConst;

  PROCEDURE EnterTyp(name: OPS.Name; form: SHORTINT; size: INTEGER; debugType:INTEGER; VAR res: Struct);
  VAR 
    obj: Object; 
    typ: Struct;
  BEGIN 
    Insert(name, obj);
    typ:=NewStr(form, Basic); 
    obj^.mode:=MODE_TYPE; 
    obj^.typ:=typ; 
    obj^.vis:=external;
    typ^.strobj:=obj; 
    typ^.size:=size; 
    typ^.tdadr:=0; 
    typ^.offset:=0; 
    typ^.ref:=form; 
    typ^.debugType:=debugType;
    res:=typ
  END EnterTyp;

  PROCEDURE EnterProc(name: OPS.Name; num: INTEGER);
  VAR 
    obj: Object;
  BEGIN 
    Insert(name, obj);
    obj^.mode:=SProc; 
    obj^.typ:=notyp; 
    obj^.adr:=num
  END EnterProc;

(*!+*)
(*============================ W R I T E   E X P O R T - F I L E =============*)

  PROCEDURE ^WriteExpStruct(typ: Struct; strobj: Object);

  PROCEDURE ^WriteExpProc(obj: Object; VAR first: BOOLEAN);

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpPars(par: Object);
  VAR 
    sameType: BOOLEAN;
  BEGIN
    sameType:=FALSE;
    WHILE par # NIL DO
      IF ~sameType & (par^.mode = VarPar) THEN OPM.WriteExpString("VAR ") END;
      OPM.WriteExpString(par^.name);
      IF par^.vis = internalR THEN OPM.WriteExpChar("-") END;
      sameType:=(par^.link # NIL) & (par^.link^.typ = par^.typ) &
                  (par^.link^.mode = par^.mode);
      IF sameType THEN
        OPM.WriteExpString(", ")
      ELSE
        OPM.WriteExpString(": ");
        WriteExpStruct(par^.typ, NIL);
        IF par^.link # NIL THEN OPM.WriteExpString("; ") END
      END;
      par:=par^.link;
    END
  END WriteExpPars;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpFlds(fld: Object; VAR first: BOOLEAN);
  BEGIN
    WHILE (fld # NIL) & (fld^.mode = Fld) DO
      IF fld^.vis >= external THEN
        IF first THEN
          OPM.WriteExpLn;
          first:=FALSE
        END;
        OPM.WriteExpString("      ");
        OPM.WriteExpString(fld^.name);
        IF fld^.vis = externalR THEN OPM.WriteExpChar("-") END;
        OPM.WriteExpString(": ");
        WriteExpStruct(fld^.typ, NIL);
        OPM.WriteExpChar(";");
        OPM.WriteExpLn
      END;
      fld:=fld^.link
    END
  END WriteExpFlds;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpStruct(typ: Struct; strobj: Object);
    VAR m, em, r: INTEGER; btyp: Struct; windows, first: BOOLEAN;
  BEGIN
    m:=typ^.mno;
    IF (typ^.strobj # NIL) & (typ^.strobj # strobj) THEN
      IF m > 1  THEN
        OPM.WriteExpString(GlbMod[m - 1]^.name);
        OPM.WriteExpChar(".");
      END;
      OPM.WriteExpString(typ^.strobj^.name);
    ELSE
      windows:=typ^.sysflag # 0;
      btyp:=typ^.BaseTyp;
      CASE typ^.form OF
        Byte:
          OPM.WriteExpString("SYSTEM.BYTE")
      | Bool:
          OPM.WriteExpString("BOOLEAN")
      | Char:
          OPM.WriteExpString("CHAR")
      | SInt:
          OPM.WriteExpString("SHORTINT")
      | Int:
          OPM.WriteExpString("INTEGER")
      | LInt:
          OPM.WriteExpString("LONGINT")
      | Real:
          OPM.WriteExpString("REAL")
      | LReal:
          OPM.WriteExpString("LONGREAL")
      | Set:
          OPM.WriteExpString("SET")
      | Pointer:
          IF windows THEN
            OPM.WriteExpString("POINTER [WINDOWS] TO ")
          ELSE
            OPM.WriteExpString("POINTER TO ")
          END;
          WriteExpStruct(btyp, NIL);
      | ProcTyp:
          OPM.WriteExpString("PROCEDURE ");
          IF windows THEN OPM.WriteExpString("[WINDOWS] ") END;
          IF typ^.link # NIL THEN
            OPM.WriteExpChar("(");
            WriteExpPars(typ^.link);
            OPM.WriteExpChar(")")
          ELSIF btyp # NIL THEN
            OPM.WriteExpString("()")
          END;
          IF btyp^.form # NoTyp THEN
            OPM.WriteExpString(": ");
            WriteExpStruct(btyp, NIL);
          END;
      | Comp:
          IF typ^.comp = Array THEN
            OPM.WriteExpString("ARRAY ");
            IF windows THEN OPM.WriteExpString("[WINDOWS] ") END;
            OPM.WriteExpInt(typ^.n, 10);
            OPM.WriteExpString(" OF ");
            WriteExpStruct(btyp, NIL);
          ELSIF typ^.comp = DynArr THEN
            OPM.WriteExpString("ARRAY OF ");
            WriteExpStruct(btyp, NIL);
          ELSE (* typ^.comp = Record *)
            OPM.WriteExpString("RECORD");
            IF windows THEN OPM.WriteExpString(" [WINDOWS]") END;
            IF btyp # NIL THEN
              OPM.WriteExpString(" (");
              WriteExpStruct(btyp, NIL);
              OPM.WriteExpChar(")");
            END;
            IF typ^.link # NIL THEN
              first:=TRUE;
              WriteExpFlds(typ^.link, first);
              WriteExpProc(typ^.link, first); (*bound procedures*)
              IF ~first THEN OPM.WriteExpString("   ") END
            END;
            OPM.WriteExpString(" END")
          END
      ELSE
        OPM.WriteExpString("<< DATA-TYPE >>");
      END
    END
  END WriteExpStruct;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpConst(obj: Object; VAR first: BOOLEAN);
  VAR 
    i: INTEGER; 
    sval: SET; 
    firstElem: BOOLEAN; 
    rval: REAL;
  BEGIN
    IF obj # NIL THEN
      WriteExpConst(obj^.left, first);
      IF obj^.mode = MODE_CON THEN
        IF first THEN
          OPM.WriteExpLn;
          OPM.WriteExpString("  CONST");
          OPM.WriteExpLn;
          first:=FALSE
        END;
        OPM.WriteExpString("    ");
        OPM.WriteExpString(obj^.name);
        OPM.WriteExpString(" = ");
        CASE obj^.typ^.form OF
          Char:
            OPM.WriteExpInt(obj^.conval^.intval, 16);
            OPM.WriteExpChar("X")
        | Bool:
            IF obj^.conval^.intval = 0 THEN
              OPM.WriteExpString("FALSE")
            ELSE
              OPM.WriteExpString("TRUE")
            END
        | Byte:
            OPM.WriteExpInt(obj^.conval^.intval, 16);
            OPM.WriteExpChar("H")
        | SInt, Int, LInt:
            OPM.WriteExpInt(obj^.conval^.intval, 10)
        | Set:
            sval:=obj^.conval^.setval;
            OPM.WriteExpChar("{");
            firstElem:=TRUE;
            i:=0;
            WHILE i < 8 * OPM.SetSize DO
              IF i IN sval THEN
                IF firstElem THEN
                  firstElem:=FALSE
                ELSE
                  OPM.WriteExpString(", ")
                END;
                OPM.WriteExpInt(i, 10);
              END;
              INC(i)
            END;
            OPM.WriteExpChar("}")
        | Real:
            OPM.WriteExpReal(obj^.conval^.realval, FALSE)
        | LReal:
            OPM.WriteExpReal(obj^.conval^.realval, TRUE)
        | String:
            OPM.WriteExpChar('"');
            OPM.WriteExpString(obj^.conval^.ext^);
            OPM.WriteExpChar('"');
        | NilTyp:
            OPM.WriteExpString("NIL")
        ELSE Err(E.ILLEGAL_OBJ_USE);
        END;
        OPM.WriteExpChar(";");
        OPM.WriteExpLn;
      END;
      WriteExpConst(obj^.right, first)
    END
  END WriteExpConst;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpType(obj: Object; VAR first: BOOLEAN);
  BEGIN
    IF obj # NIL THEN
      WriteExpType(obj^.left, first); 
      IF (obj^.vis >= external) & (obj^.mode = MODE_TYPE) THEN
        IF first THEN
          OPM.WriteExpLn;
          OPM.WriteExpString("  TYPE");
          OPM.WriteExpLn;
          first:=FALSE
        END;
        OPM.WriteExpString("    ");
        OPM.WriteExpString(obj^.name);
        OPM.WriteExpString(" = ");
        WriteExpStruct(obj^.typ, obj);
        OPM.WriteExpChar(";");
        OPM.WriteExpLn;
        IF obj^.typ^.comp = Record THEN
          OPM.WriteExpLn
        END
      END;
      WriteExpType(obj^.right, first)
    END
  END WriteExpType;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpVar(obj: Object; VAR first: BOOLEAN);
  BEGIN
    IF obj # NIL THEN
      WriteExpVar(obj^.left, first);
      IF obj^.mode = MODE_VAR THEN
        IF first THEN
          OPM.WriteExpLn;
          OPM.WriteExpString("  VAR");
          OPM.WriteExpLn;
          first:=FALSE
        END;
        OPM.WriteExpString("    ");
        OPM.WriteExpString(obj^.name);
        IF obj^.vis = externalR THEN OPM.WriteExpChar("-") END;
        OPM.WriteExpString(": ");
        WriteExpStruct(obj^.typ, NIL);
        OPM.WriteExpChar(";");
        OPM.WriteExpLn;
      END;
      WriteExpVar(obj^.right, first)
    END
  END WriteExpVar;


(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpProc(obj: Object; VAR first: BOOLEAN);
  VAR 
    m, f, mode: INTEGER; 
    ext: ConstExt; 
    par: Object;
  BEGIN
    IF obj # NIL THEN
      WriteExpProc(obj^.left, first);
      mode:=obj^.mode;
      IF mode IN {XProc, WProc, MODE_CDECLPROC, IProc, CProc, TProc} THEN
        IF first THEN
          OPM.WriteExpLn;
          first:=FALSE
        END;
        par:=obj^.link;
        IF mode = TProc THEN OPM.WriteExpString("    ") END;
        OPM.WriteExpString("  PROCEDURE ");
        IF mode = WProc THEN
          OPM.WriteExpString("[WINDOWS] ")
        ELSIF mode = MODE_CDECLPROC THEN
          OPM.WriteExpString("[CDECL] ")
        ELSIF mode = CProc THEN
          OPM.WriteExpChar("-")
        ELSIF mode = IProc THEN
          OPM.WriteExpChar("+")
        ELSIF mode = TProc THEN
          OPM.WriteExpChar("(");
          IF par^.mode = VarPar THEN OPM.WriteExpString("VAR ") END;
          OPM.WriteExpString(par^.name);
          IF (par^.mode = VarPar) & (par^.vis = internalR) THEN
            OPM.WriteExpChar("-")
          END;
          OPM.WriteExpString(": ");
          WriteExpStruct(par^.typ, NIL);
          OPM.WriteExpString(") ");
          par:=par^.link
        END;
        OPM.WriteExpString(obj^.name);
        IF par # NIL THEN
          OPM.WriteExpString(" (");
          WriteExpPars(par);
          OPM.WriteExpChar(")")
        ELSIF obj^.typ^.form # NoTyp THEN
          OPM.WriteExpString(" ()")
        END;
        IF obj^.typ^.form # NoTyp THEN
          OPM.WriteExpString(": ");
          WriteExpStruct(obj^.typ, NIL);
        END;
        IF mode = CProc THEN
          ext:=obj^.conval^.ext;
          m:=ORD(ext^[0]); f:=1;
          OPM.WriteExpChar(" ");
          WHILE f <= m DO
            OPM.WriteExpInt(ORD(ext^[f]), 16);
            OPM.WriteExpChar("H");
            IF f # m THEN OPM.WriteExpString(", ") END;
            INC(f)
          END;
        END;
        OPM.WriteExpChar(";");
        OPM.WriteExpLn;
      END;
      WriteExpProc(obj^.right, first)
    END
  END WriteExpProc;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExp*;
  VAR 
    i: INTEGER; 
    done, first: BOOLEAN; 
    modName: OPS.Name;
  BEGIN
    COPY(GlbMod[0]^.name, modName);
    OPM.OpenExpFile(modName, done);
    IF done THEN
      strno:=FIRSTSTR;
      OPM.WriteExpString("DEFINITION ");
      OPM.WriteExpString(modName);
      OPM.WriteExpChar(";");
      OPM.WriteExpLn;
      IF nofGmod > 1 THEN
        OPM.WriteExpLn;
        OPM.WriteExpString("  IMPORT");
        OPM.WriteExpLn;
        OPM.WriteExpString("    ");
        i:=1;
        WHILE i < nofGmod DO
          OPM.WriteExpString(GlbMod[i]^.name);
          IF i < nofGmod - 1 THEN OPM.WriteExpString(", ") END;
          INC(i)
        END;
        OPM.WriteExpChar(";");
        OPM.WriteExpLn;
      END;
      first:=TRUE; WriteExpConst(GlbMod[0]^.right, first);
      first:=TRUE; WriteExpType(GlbMod[0]^.right, first);
      first:=TRUE; WriteExpVar(GlbMod[0]^.right, first);
      first:=TRUE; WriteExpProc(GlbMod[0]^.right, first);
      OPM.WriteExpLn;
      OPM.WriteExpString("END ");
      OPM.WriteExpString(modName);
      OPM.WriteExpChar(".");
      OPM.WriteExpLn;
      OPM.CloseExpFile;
    END
  END WriteExp;

(*----------------------------------------------------------------------------*)
(*!-*)

BEGIN
  topScope:=NIL; 
  OpenScope(0, NIL);  
  OPM.errpos.line:=0;
  OPM.errpos.column:=0;
  
  InitStruct(undftyp, Undef); 
  InitStruct(notyp, NoTyp);
  InitStruct(stringtyp, String); 
  InitStruct(niltyp, NilTyp);
  undftyp^.BaseTyp:=undftyp;
  notyp.debugType:=0; (* also used for the return type of procedures without return value *)

  (*initialization of module SYSTEM*)
  EnterTyp("BYTE", Byte, OPM.ByteSize, 0020H, bytetyp);
  EnterTyp("PTR", Pointer, OPM.PointerSize, 0503H, sysptrtyp);
  EnterProc("ADR", adrfn);
  (*! EnterProc("CC", ccfn); *)
  EnterProc("LSH", lshfn);
  EnterProc("ROT", rotfn);
  EnterProc("GET", SYSTEM_GETFN);
  EnterProc("PUT", SYSTEM_PUTFN);
  EnterProc("GETREG", SYSTEM_GETRFN);
  EnterProc("PUTREG", SYSTEM_PUTRFN);
  EnterProc("BIT", bitfn);
  EnterProc("VAL", valfn);
  EnterProc("NEW", sysnewfn);
  EnterProc("MOVE", movefn);
  EnterProc("BITXOR", SYSTEMFN_XOR);
  EnterProc("BITOR", SYSTEMFN_OR);
  EnterProc("BITAND", SYSTEMFN_AND);
  EnterProc("BITNOT", SYSTEMFN_NOT);
  EnterProc("HIWORD", SYSTEMFN_HIWORD);
  EnterProc("LOWORD", SYSTEMFN_LOWORD);
  EnterProc("MAKELONG", SYSTEMFN_MKLONG);

  syslink:=topScope^.right;
  universe:=topScope; topScope^.right:=NIL;

  EnterTyp("CHAR", Char, OPM.CharSize, 0020H, chartyp);
  EnterTyp("SET", Set, OPM.SetSize, 0022H, settyp);
  EnterTyp("REAL", Real, OPM.RealSize, 0040H, realtyp);
  EnterTyp("INTEGER", Int, OPM.IntSize, 0011H, inttyp);
  EnterTyp("LONGINT",  LInt, OPM.LIntSize, 0012H, linttyp);
  EnterTyp("LONGREAL", LReal, OPM.LRealSize, 0041H, lrltyp);
  EnterTyp("SHORTINT", SInt, OPM.SIntSize, 0010H, sinttyp);
  EnterTyp("BOOLEAN", Bool, OPM.BoolSize, 0010H, booltyp);
  EnterBoolConst("FALSE", 0);  (* 0 and 1 are compiler internal representation only *)
  EnterBoolConst("TRUE",  1);
  EnterProc("HALT", haltfn);
  EnterProc("NEW", newfn);
  EnterProc("DISPOSE", disposefn); (*!*)
  EnterProc("ABS", absfn);
  EnterProc("CAP", capfn);
  EnterProc("ORD", ordfn);
  EnterProc("ENTIER", entierfn);
  EnterProc("ODD", oddfn);
  EnterProc("MIN", minfn);
  EnterProc("MAX", maxfn);
  EnterProc("CHR", chrfn);
  EnterProc("SHORT", shortfn);
  EnterProc("LONG", longfn);
  EnterProc("SIZE", sizefn);
  EnterProc("INC", incfn);
  EnterProc("DEC", decfn);
  EnterProc("INCL", inclfn);
  EnterProc("EXCL", exclfn);
  EnterProc("LEN", lenfn);
  EnterProc("COPY", copyfn);
  EnterProc("ASH", ashfn);
  EnterProc("ASSERT", assertfn);
  first:=TRUE; (*!L*)
END OPT.
