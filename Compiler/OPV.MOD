(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPV;                                     (**)
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
(* PURPOSE: Parse tree traverser of Oberon2 compiler DLL                      *)
(*                                                                            *)
(******************************************************************************)

  IMPORT
    OPT, OPL, OPC, OPM, OPB, SYSTEM, CB:=OPC_Base, E:=Error, Coff, 
    Debug, S:=String, WriteObj, DebugInfo, Reg:=Register;
  
  CONST
    (* object modes *)
    MODE_VAR = OPT.MODE_VAR; 
    VarPar = OPT.VarPar; 
    MODE_CON = OPT.MODE_CON; 
    Fld = OPT.Fld; 
    MODE_TYPE = OPT.MODE_TYPE; 
    MODE_DLLTYPE = OPT.MODE_DLLTYPE;
    LProc = OPT.LProc; (* "ordinary", local procedures *)
    XProc = OPT.XProc; (* exported procedures "*" *)
    SProc = OPT.SProc; (* built in function or function from module SYSTEM *)
    CProc = OPT.CProc; (* code procedures "-" *)
    IProc = OPT.IProc; (* interrupt procedures "+" *)
    Mod = OPT.Mod; 
    Head = OPT.Head; 
    TProc = OPT.TProc; (* type bound procedures *)
    WProc = OPT.WProc; (* [_APICALL] procedures *)
    MODE_CDECLPROC=OPT.MODE_CDECLPROC;(* [_CDECL] procedures *)
    MODE_VARSTPAR=OPT.MODE_VARSTPAR; (* statically typed VAR parameter; may be declared 
                                        only in definition modules *)
    MODE_DLLVAR=OPT.MODE_DLLVAR;

    (* symbol values and ops *)
    times = OPB.times; slash = OPB.slash; div = OPB.div; 
    mod = OPB.mod;     and = OPB.and;     plus = OPB.plus; 
    minus = OPB.minus; or = OPB.or;       eql = OPB.eql;
    neq = OPB.neq;     lss = OPB.lss;     leq = OPB.leq; 
    gtr = OPB.gtr;     geq = OPB.geq;     in = OPB.in; 
    is = OPB.is;       ash = OPB.ash;     msk = OPB.msk; 
    len = OPB.len;     conv = OPB.conv;   abs = OPB.abs; 
    cap = OPB.cap;     odd = OPB.odd;     not = OPB.not;
    (*SYSTEM*)
    OP_SYSADR = OPB.adr; 
    cc = OPB.cc;   bit = OPB.bit; 
    lsh = OPB.lsh; rot = OPB.rot; val = OPB.val;
    OP_SYSXOR=OPB.OP_SYSXOR;
    OP_SYSOR=OPB.OP_SYSOR;
    OP_SYSAND=OPB.OP_SYSAND;
    OP_SYSNOT=OPB.OP_SYSNOT;
    OP_SYSLOWORD=OPB.OP_SYSLOWORD;
    OP_SYSHIWORD=OPB.OP_SYSHIWORD;
    OP_SYSMKLONG=OPB.OP_SYSMKLONG;

    (*function number*)
    assign = 0; newfn = 1; incfn = 13; decfn = 14;
    inclfn = 15; exclfn = 16; copyfn = 18; assertfn = 32;

    (*SYSTEM function number*)
    getfn = 24; putfn = 25; getrfn = 26; putrfn = 27; sysnewfn = 30; movefn = 31;

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

    (* node subclasses *)
    super = 1;
    
    (* nodes classes *)
    Nvar = 0; Nvarpar = 1; Nfield = 2; Nderef = 3; Nindex = 4; Nguard = 5; Neguard = 6;
    Nconst = 7; Ntype = 8; Nproc = 9; Nupto = 10; Nmop = 11; Ndop = 12; Ncall = 13;
    Ninittd = 14; Nif = 15; Ncaselse = 16; Ncasedo = 17; Nenter = 18; Nassign = 19;
    Nifelse =20; Ncase = 21; Nwhile = 22; Nrepeat = 23; Nloop = 24; Nexit = 25;
    Nreturn = 26; Nwith = 27; Ntrap = 28; Ncommon = 29;
    Ndispose = 30; (*!*)
    NODE_SYSDOP=OPB.NODE_SYSDOP;
    NODE_SYSMOP=OPB.NODE_SYSMOP;

    (* module visibility of objects *)
    internal=WriteObj.internal;
    internalR =WriteObj.internalR;
    external = WriteObj.external;
    externalR =WriteObj.externalR;

    (* procedure flags (conval^.setval) *)
    hasBody = 1; isRedef = 2; slNeeded = 3;

    DoCommonDesign = FALSE;    (* true to generate better code *)
                      (* identify same designators not containing expressions: design:=design op expr *)

    (* item modes for 80386 (must not overlap item basemodes,  > 20)          *)
    DArr = OPL.DArr; 
    Coc = OPL.Coc; 
    Stk = OPL.Stk; 
(*    FStk = OPL.FStk; *)
    (* 80386 general- and segment registers                                   *)
    eax = 0; ecx = 1; edx = 2; ebx = 3; esp = 4; ebp = 5; esi = 6; edi = 7;
    es = 8; cs = 9; ss = 10; ds = 11; fs = 12; gs = 13; eip = 14; eflags = 15;

    MaxAdr = 07FFFFFFH;
    MinAdr = -MaxAdr;
    
    PARSIZE_VAR = 4; (* size of a VAR parameter on stack *)
    PARSIZE_RECVAR = 8; (* size of a record VAR parameter on stack *)
    PARSIZE_VARST=4; (* size of a VAR STATICTYPED parameter on stack *)
    
    (* offset of all parameters from base pointer *)
    LProcParOff =  8; (* !C! was 4 *)
    XProcParOff =  8; (* !C! was 10 *)    
    IProcParOff =  8; (* !C! was 12 *)
    CProcParOff =  4; (* !C! was 2 *)    
    WProcParOff =  8; (* !C! was 12 *)   
    CDeclProcParOff = 8; (* !C! was 12 *)
    
    (* offset of all local variables from base pointer *)
    XProcLocOff = -4; (* !C! was -2 *)
    IProcLocOff =  0;
    CProcLocOff =  0;
    WProcLocOff = -4; (* !C! was -2 *)
    CDeclProcLocOff = -4; (* !C! was -2 *)

    WithTrap = -7;
    CaseTrap = -8;
    FuncTrap = -9;

  VAR
    ExitChain: OPL.Label;
    CommonDesign: OPL.Item;
    CommonDesignClass: SHORTINT;
    debug,
    assert: BOOLEAN;
    

(*----------------------------------------------------------------------------*)
  PROCEDURE Init*(ass, deb: BOOLEAN);
  BEGIN
    assert:=ass;
    debug:=deb;
  END Init;

(*----------------------------------------------------------------------------*)
  PROCEDURE IncAdr(VAR adr: LONGINT; s: LONGINT);
    (* function:      increments 'adr' by 's' bytes                           *)

  BEGIN
    IF (s >= 0) & (adr <= MaxAdr - s) OR
       (s < 0)  & (adr >= MinAdr - s) THEN 
      INC(adr, s);
    ELSE 
      OPM.Err(E.ADDR_OVERFLOW);
    END
  END IncAdr;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE AlignFld(VAR offset: LONGINT; elemsize: LONGINT);
    (* function:      alignment for a record field                            *)
    (* precondition:  offset = base type size, 0 if none                      *)

  BEGIN
    IF elemsize >= 4 THEN 
      IncAdr(offset, (-offset) MOD 4)
    ELSIF elemsize = 2 THEN 
      IncAdr(offset, offset MOD 2)
    END
  END AlignFld;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE AllocFld(VAR offset, this: LONGINT; elemsize: LONGINT);
    (* function:      allocation of a record field                            *)
  BEGIN 
    this:=offset; 
    IncAdr(offset, elemsize);
  END AllocFld;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE AlignRec(VAR size: LONGINT);
    (* function:      alignment for a record                                  *)
  BEGIN 
    IncAdr(size, (-size) MOD 4)
  END AlignRec;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE AlignPar(VAR elemsize: LONGINT);
    (* function:      alignment for a procedure parameter                     *)
  BEGIN 
(* !C!    IncAdr(elemsize, (-elemsize) MOD 2) stack alignment now 4 *)
    IncAdr(elemsize, (-elemsize) MOD 4)
  END AlignPar;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE AllocPar(VAR adr, this: LONGINT; elemsize: LONGINT);
    (* function:      allocation of a procedure parameter                     *)
  BEGIN
    IncAdr(adr, elemsize); this:=adr
  END AllocPar;

(*----------------------------------------------------------------------------*)
  PROCEDURE AlignLVar(VAR adr: LONGINT; elemsize: LONGINT);
    (* function:      alignment for a local variable in a procedure           *)

  BEGIN
(*    IF elemsize >= 4 THEN IncAdr(adr, - (adr MOD  4))
    ELSIF elemsize = 2 THEN IncAdr(adr, - (adr MOD  2))
    END !C! *)
    IncAdr(adr, - (adr MOD  4));
  END AlignLVar;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocLVar(VAR adr, this: LONGINT; elemsize: LONGINT);
    (* function:      allocation of a local variable in a procedure           *)

  BEGIN 
    IncAdr(adr, -elemsize-((4-elemsize) MOD 4)); this:=adr
  END AllocLVar;

(*----------------------------------------------------------------------------*)
  PROCEDURE AlignLBlock(adr: LONGINT; VAR dsize: LONGINT);
    (* function:      alignment for a local variable block in a procedure     *)

  BEGIN 
    IncAdr(adr, - (adr MOD  4)); dsize:=-adr
  END AlignLBlock;

(*----------------------------------------------------------------------------*)
  PROCEDURE AlignGVar(VAR adr: LONGINT; elemsize: LONGINT);
    (* function:      alignment for a global variable                         *)

  BEGIN
    IF elemsize >= 4 THEN IncAdr(adr, (-adr) MOD  4)
    ELSIF elemsize = 2 THEN IncAdr(adr, adr MOD  2)
    END;
(*    IncAdr(adr, (-adr) MOD  4); *)
  END AlignGVar;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocGVar(VAR adr, this: LONGINT; elemsize: LONGINT);
    (* function:      allocation of a global variable                         *)
  BEGIN 
    this:=adr; 
    IncAdr(adr, elemsize)
  END AllocGVar;

(*----------------------------------------------------------------------------*)
  PROCEDURE AlignGBlock(adr: LONGINT; VAR dsize: LONGINT);
    (* function:      alignment for a global variable block                   *)

  BEGIN 
    IncAdr(adr, (-adr) MOD  4); 
    dsize:=adr
  END AlignGBlock;

(*----------------------------------------------------------------------------*)
  PROCEDURE ^ ParamAdr(mode: INTEGER; firstPar: OPT.Object; parOff: LONGINT;  VAR psize:LONGINT);

  PROCEDURE ^Traverse(obj: OPT.Object; exported: BOOLEAN);

  PROCEDURE ^VisitTProcs(obj: OPT.Object);

(*----------------------------------------------------------------------------*)
  PROCEDURE TypSize*(typ: OPT.Struct; allocDesc: BOOLEAN);
    (* function:      computes size of data type 'typ'                        *)
    (* precondition:  allocDesc = TRUE: allocate typedescriptors in constant filed*)
    (* postcondition: typ^.size has correct size value                        *)

  VAR 
    f, c: INTEGER; 
    offset, size: LONGINT;
    fld: OPT.Object; 
    btyp: OPT.Struct; 
    sizeUndef, doAlloc: BOOLEAN;
  BEGIN
    IF typ = OPT.undftyp THEN 
      OPM.Err(E.RECURSIVE_TYPE_DEFINITION);
    ELSE
      sizeUndef:=typ^.size = -1; 
      doAlloc:=allocDesc & (typ^.tdadr = OPM.TDAdrUndef) & (typ^.offset = OPM.TDAdrUndef);
      IF sizeUndef OR doAlloc THEN
        IF doAlloc THEN typ^.tdadr:=-2 END ;(* avoid cycles *)
        f:=typ^.form; 
        c:=typ^.comp; 
        btyp:=typ^.BaseTyp;
        
        IF c = Record THEN
          IF btyp = NIL THEN 
            offset:=0
          ELSE 
            TypSize(btyp, allocDesc); 
            offset:=btyp^.size
          END ;
          IF doAlloc THEN (* +BugFix 15.4.96 *)
            IF (btyp # NIL) & ((btyp^.tdadr = -2) OR 
                               (btyp^.tdadr = OPM.TDAdrUndef)) THEN
              doAlloc := FALSE; (* not jet ready for allocation *)
              typ^.tdadr := OPM.TDAdrUndef;
            ELSE
              IF btyp = NIL THEN typ^.n := 0 ELSE typ^.n := btyp^.n END ;
              VisitTProcs(typ^.link);
            END
          END ; (* -BugFix *)
(*          IF doAlloc THEN
            IF btyp = NIL THEN typ^.n:=0 ELSE typ^.n:=btyp^.n END ;
            VisitTProcs(typ^.link)
          END ; *)
          fld:=typ^.link; (* pointer to fields (only valid for records) *)
          WHILE (fld # NIL) & (fld^.mode = Fld) DO
            btyp:=fld^.typ; 
            TypSize(btyp, allocDesc);
            IF sizeUndef THEN 
              size:=btyp^.size;
              WHILE btyp^.comp = Array DO btyp:=btyp^.BaseTyp END ;
              IF typ^.sysflag # OPM.SYSFLAG_NOTALIGNED THEN AlignFld(offset, btyp^.size) END; (*!!!*)
              AllocFld(offset, fld^.adr, size)
            END ;
            fld:=fld^.link
          END ;
          IF sizeUndef THEN (*!+*)
            IF typ^.sysflag # OPM.SYSFLAG_NOTALIGNED THEN AlignRec(offset) END;  (* !!! *)
            typ^.size:=offset 
          END ; (*!-*)
          IF doAlloc THEN OPL.AllocTypDesc(typ); Traverse(typ^.link, TRUE) END
          
        ELSIF c = Array THEN
          TypSize(btyp, allocDesc);
          IF sizeUndef THEN typ^.size:=typ^.n * btyp^.size END ;
          IF doAlloc THEN OPL.AllocBounds(0, typ^.n-1, typ^.offset) END
          
        ELSIF f = Pointer THEN
          typ^.size:=OPM.PointerSize;
          IF doAlloc THEN
            TypSize(btyp, allocDesc);
            IF btyp^.comp = DynArr THEN OPL.AllocTypDesc(btyp) END
          END
          
        ELSIF f = ProcTyp THEN
          typ^.size:=OPM.ProcSize;
          IF doAlloc THEN 
            TypSize(btyp, TRUE); 
            ParamAdr(XProc, typ^.link, XProcParOff, size);
          END
          
        ELSE (* (c = DynArr) & doAlloc *)
          TypSize(btyp, allocDesc);
          IF btyp^.comp = DynArr THEN 
            typ^.size:=btyp^.size + 8; 
            typ^.offset:=btyp^.offset + 8
          ELSE 
            typ^.size:=12; 
            typ^.offset:=4;
          END
        END
      END
    END
  END TypSize;

(*----------------------------------------------------------------------------*)
  PROCEDURE ParamAdr(mode: INTEGER; firstPar: OPT.Object; parOff: LONGINT;  VAR psize:LONGINT);
    (* function:      initializes addresses of procedure parameters on stack  *)
    (* precondition:  mode = defines what kind of procedure it is             *)
    (*                parOff = offset, relativ to EBP, where parameters begin *)
    (* postcondition: psize = size of parameter field                         *)

  VAR 
    adr: LONGINT;
    
    PROCEDURE Process(par:OPT.Object);
    VAR
      typ: OPT.Struct; 
      s:LONGINT;
    BEGIN
      typ:=par^.typ; 
      TypSize(typ, TRUE);
      IF par^.mode = VarPar THEN
        IF typ^.comp = Record THEN 
          s:=PARSIZE_RECVAR;
        ELSIF typ^.comp = DynArr THEN 
          s:=typ^.size
        ELSE 
          s:=PARSIZE_VAR;
        END
      ELSIF par^.mode=MODE_VARSTPAR THEN (* !C! *)
        s:=PARSIZE_VARST;
      ELSE 
        s:=typ^.size
      END ;
      AlignPar(s);  (* even for WProc it is dword aligned *)
      AllocPar(adr, par^.adr, s); 
    END Process;
    
    PROCEDURE RevTraversal(par:OPT.Object);
    BEGIN
      IF par#NIL THEN
        RevTraversal(par^.link);
        Process(par);
      END;
    END RevTraversal;
    
    PROCEDURE Traversal(par:OPT.Object);
    BEGIN
      WHILE par # NIL DO
        Process(par);
        par:=par^.link
      END;
    END Traversal;
    
  BEGIN 
    adr:=0; 
    IF (mode=MODE_CDECLPROC) OR (mode=WProc) THEN (* + 28.08.96 *)
      RevTraversal(firstPar);
    ELSE
      Traversal(firstPar);
    END;
    psize:=adr; 
    INC(adr, parOff);
    WHILE firstPar # NIL DO
      firstPar^.adr:=adr - firstPar^.adr; firstPar:=firstPar^.link
    END ;
  END ParamAdr;
  
(*----------------------------------------------------------------------------*)
(* + 26.08.96 *)
  PROCEDURE ParamSize(firstPar: OPT.Object; VAR psize:LONGINT);
    (* function:      get total size of procedure parameters on stack  *)
    (* assumption:    total size of parameters is identical for C- and Pascal calling convention *)
    (* postcondition: psize = size of parameter field                         *)

  VAR 
    par: OPT.Object; 
    typ: OPT.Struct; 
    adr, s: LONGINT;
  BEGIN 
    adr:=0; 
    par:=firstPar;
    WHILE par # NIL DO
      typ:=par^.typ; 
      TypSize(typ, FALSE);
      IF par^.mode = VarPar THEN
        IF typ^.comp = Record THEN 
          s:=PARSIZE_RECVAR;
        ELSIF typ^.comp = DynArr THEN 
          s:=typ^.size
        ELSE 
          s:=PARSIZE_VAR;
        END
      ELSIF par^.mode=MODE_VARSTPAR THEN (* !C! *)
        s:=PARSIZE_VARST;
      ELSE 
        s:=typ^.size
      END ;
      AlignPar(s);  (* even for WProc it is word aligned *)
      AllocPar(adr, par^.adr, s); 
      par:=par^.link
    END ;
    psize:=adr; 
  END ParamSize;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE LVarAdr(var: OPT.Object; locOff: LONGINT; VAR lsize: LONGINT);
    (* function:      initializes addresses of local procedure variables      *)
    (* precondition:  locOff = offset, relativ to EBP, where parameters begin *)
    (* postcondition: lsize = size of local variable field                    *)

  VAR 
    adr, s: LONGINT;
  BEGIN 
    adr:=locOff;                  (* adr <= 0                           *)
    WHILE var # NIL DO
      TypSize(var^.typ, TRUE); 
      s:=var^.typ^.size;
      AlignLVar(adr, s);
      AllocLVar(adr, var^.adr, s); 
      var:=var^.link
    END;
    adr:=adr - locOff;
    AlignLBlock(adr, lsize)
  END LVarAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE GVarAdr(var: OPT.Object; firstpass: BOOLEAN);
    (* function:      initializes addresses of global variables               *)
    (* precondition:  var = first global variable                             *)

  VAR 
    adr, s: LONGINT;
  BEGIN 
    adr:=OPL.dsize;
    WHILE var # NIL DO
      IF (var^.vis >= external) = firstpass THEN
        TypSize(var^.typ, TRUE); 
        s:=var^.typ^.size;
        AlignGVar(adr, s);
        AllocGVar(adr, var^.adr, s)
      END;
      var:=var^.link
    END;
    AlignGBlock(adr, OPL.dsize)
  END GVarAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE ProcSize(obj: OPT.Object; firstpass: BOOLEAN);
    (* function:      initializes addresses related to procedure 'proc'       *)
    (* precondition:  firstpass = TRUE: handles exported procedures           *)
    (*                firstpass = FALSE: handles local procedures             *)

  VAR 
    parOff, locOff, psize:LONGINT;
    oldPos:OPM.SourcePosT;
  BEGIN
    oldPos:=OPM.errpos; 
    OPM.errpos.line:=obj^.scope^.adr DIV OPM.LINENUMFACT;
    OPM.errpos.column:=0;
(*    IF firstpass & (obj^.vis >= external) & (obj^.mnolev = 0)
       & (obj^.mode # TProc) THEN
      WriteObj.DefineExport(obj);
    END; *)
    IF ((obj^.vis >= external) = firstpass) OR (obj^.mode = TProc) THEN
      CASE obj^.mode OF
        LProc: parOff:=LProcParOff;
      | XProc, TProc: parOff:=XProcParOff;
      | IProc: parOff:=IProcParOff;
      | CProc: parOff:=CProcParOff;
      | WProc: parOff:=WProcParOff;
      | MODE_CDECLPROC: parOff:=CDeclProcParOff;
      ELSE 
        OPM.CommentedErr(E.INTERNAL_MURKS,"ProcSize");
      END;
      TypSize(obj^.typ, TRUE);
      ParamAdr(obj^.mode, obj^.link, parOff, psize); 
      obj^.conval^.intval:=psize;
      IF obj^.mode # TProc THEN
        obj^.linkadr:=OPM.LANotAlloc;
        obj^.adr:=OPM.LANotAlloc;
        obj^.symTableInx:=-1;
      END
    END ;
    IF ~firstpass OR (obj^.mode = TProc) THEN
      IF ~(hasBody IN obj^.conval^.setval) & ~OPT.defModule THEN 
        OPM.CommentedErr(E.FORWARD_PROC,obj.name);
      END ;
      CASE obj^.mode OF
        LProc: IF (obj^.mnolev = 0) & obj^.leaf THEN locOff:=0
               ELSE locOff:=- 4 * (obj^.mnolev + 1) (* !C! was -2 * *)
               END;
      | XProc, TProc: locOff:=XProcLocOff;
      | IProc: locOff:=IProcLocOff;
      | CProc: locOff:=CProcLocOff;
      | WProc: locOff:=WProcLocOff;
      | MODE_CDECLPROC: locOff:=CDeclProcLocOff;
      ELSE 
        OPM.CommentedErr(E.INTERNAL_MURKS,"ProcSize2");
      END;
      LVarAdr(obj^.scope^.scope, locOff, obj^.conval^.intval2);    (* local variables *)
      Traverse(obj^.scope^.right, FALSE)
    END ;
    OPM.errpos:=oldPos
  END ProcSize;

(*----------------------------------------------------------------------------*)
  PROCEDURE VisitTProcs(obj: OPT.Object);    
    (* function:      recursively traverses the tree of fields and type-     *)
    (*                bound procedures of a record.                          *)
    (* precondition:  TProcs of base type are already visited                *)
    (* postcondition: the addresses of TProcs are initialized                *)

  CONST 
    isRedef = 2;    
  VAR 
    typ: OPT.Struct; 
    redef: OPT.Object;
  BEGIN
    IF obj # NIL THEN
      VisitTProcs(obj^.left);
      IF obj^.mode = TProc THEN
        typ:=obj^.link^.typ;
        IF typ^.form = Pointer THEN typ:=typ^.BaseTyp END ;
        OPT.FindField(obj^.name, typ^.BaseTyp, redef);
        IF redef # NIL THEN 
          obj^.adr:=(redef^.adr DIV 10000H) * 10000H (*mthno*);
          IF ~(isRedef IN obj^.conval^.setval) THEN 
            OPM.Err(E.REDEFINITION_BEFORE_BASEDEF);
          END
        ELSE 
          obj^.adr:=typ^.n * 10000H; 
(*          Debug.WriteStr("method nr. ");
          Debug.WriteInt(typ^.n);
          Debug.ShowOutput;*)
          INC(typ^.n);
        END;
      END ;
      VisitTProcs(obj^.right)
    END
  END VisitTProcs;

(*----------------------------------------------------------------------------*)
  PROCEDURE Traverse(obj: OPT.Object; exported: BOOLEAN);
    (* function:      recursively traverses the tree of objects               *)
    (* precondition:  exported = TRUE: deals with exported objects            *)
    (*                exported = FALSE: deals with local objects              *)

  BEGIN
    IF obj # NIL THEN
      Traverse(obj^.left, exported);
      IF ((obj^.mode = MODE_TYPE) OR (obj^.mode = MODE_DLLTYPE)) & ((obj^.vis >= external) = exported) THEN
        TypSize(obj^.typ, TRUE)
      ELSIF obj^.mode IN {LProc, XProc, WProc, TProc, CProc, IProc, MODE_CDECLPROC} THEN
(* !C!        (* orig. code: IF exported & (obj^.mode IN {XProc, TProc, IProc}) & ~OPT.defModule THEN  *) 
        (* change+ 9.10.95 Rel. 1.18 *)
        IF exported & (obj^.mode IN {WProc, CDeclProc, XProc, TProc, IProc}) & ~OPT.defModule THEN
        (* change- *)
          INC(OPC.nofXTIProc)
        END; *)
        ProcSize(obj, exported)
      END ;
      Traverse(obj^.right, exported);
    END
  END Traverse;

(*----------------------------------------------------------------------------*)
  PROCEDURE AdrAndSize*(topScope: OPT.Object);
    (* function:      initializes addresses of variables and parameters and   *)
    (*                sizes of data types                                     *)
    (* precondition:  topScope = pointer to anchore of object tree            *)

  BEGIN
(* !C!    OPC.nofXTIProc:=0; *)
    OPM.errpos.line:=topScope^.adr MOD OPM.LINENUMFACT;      (* text position of scope used if error *)
    OPM.errpos.column:=0;
    Traverse(topScope^.right, TRUE);    (* first pass only on exported types and procedures  *)
    GVarAdr(topScope^.scope, TRUE);   (* global variables *)
    GVarAdr(topScope^.scope, FALSE);  (* second pass *)
    Traverse(topScope^.right, FALSE)
  END AdrAndSize;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE SameDesign(n1, n2: OPT.Node): BOOLEAN;
    (* function:      checks whether the two designators 'n1' and 'n2 are     *)
    (*                identical or not                                        *)
    (* postcondition: RETURN designator(n1) = designator(n2)                  *)

  BEGIN
    LOOP
      IF (n1^.class # n2^.class) OR (n1^.typ # n2^.typ) THEN RETURN FALSE END ;
      CASE n1^.class OF
        Nvar, Nvarpar, Nproc: RETURN n1^.obj = n2^.obj
      | Nfield:
          IF n1^.obj # n2^.obj THEN RETURN FALSE END
      | Nderef, Nguard:
      | Nindex:
          IF ~SameDesign(n1^.right, n2^.right) THEN RETURN FALSE END
      ELSE RETURN FALSE
      END ;
      n1:=n1^.left; n2:=n2^.left
    END
  END SameDesign;

(*----------------------------------------------------------------------------*)
  PROCEDURE^ expr(n: OPT.Node; VAR x: OPL.Item);

(*----------------------------------------------------------------------------*)
  PROCEDURE Design(n: OPT.Node; VAR x: OPL.Item);
    (* function:      evaluates the designator of node 'n' and returns the    *)
    (*                result in item 'x'                                      *)
    (* precondition:  n = node                                                *)
    (* postcondition: x = address of object                                   *)

  VAR 
    obj: OPT.Object; 
    y: OPL.Item; 
    left: OPT.Node;
  BEGIN 
    left:=n^.left;
    CASE n^.class OF
      Nvar, Nvarpar:
        obj:=n^.obj; 
        x.mode:=obj^.mode; 
        x.mnolev:=obj^.mnolev;
        (* OPC.CompleteItem(n, x); *)
        x.adr:=n^.obj^.adr;
        IF n^.typ^.comp = DynArr THEN OPC.DescToData(x) END
    | Nfield:
        Design(left, x); 
        OPC.Field(x, n^.obj^.adr);
    | Nderef:
        Design(left, x); 
        CB.DeRef(x);
        IF n^.typ^.comp = DynArr THEN x.typ:=n^.typ; OPC.DescToData(x) END
    | Nindex:
        Design(left, x); expr(n^.right, y); CB.Index(x, y);
        OPL.Release(y);
    | Nguard:
        Design(left, x); OPC.TypTest(x, n^.typ, TRUE, FALSE)
    | Neguard:
        Design(left, x); OPC.TypTest(x, n^.typ, TRUE, TRUE)
    | Nproc:
        obj:=n^.obj; 
        IF obj^.conval.intval=-1 THEN
          ParamSize(obj^.link,obj^.conval.intval); 
        END;
        x.mode:=obj^.mode; 
        x.mnolev:=obj^.mnolev;
        IF x.mode = TProc THEN
          x.inx.key:=n^.subcl; (* normal OR super *)
          x.adr:=obj^.adr;
(*        ELSIF (x.mnolev < 0) & (obj^.adr <= 0) THEN(* uninitialized ext. proc    *)*)
        ELSIF x.mnolev < 0 THEN (* uninitialized ext. proc    *)
(*          IF x.mode=WProc THEN
            WriteObj.DefineDLLImport(obj);
          ELSE
            WriteObj.DefineImport(obj);
          END;*)
          WriteObj.DefineImport(obj);
          x.adr:=obj^.symTableInx;
        ELSE
          x.adr:=obj^.adr;
        END;
(* !!! was: ???  x.adr:=obj^.adr;  *)
        x.disp:=obj^.linkadr;
        (* OPC.CompleteItem(n, x) *)
    | Ncommon:
        x:=CommonDesign
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"designator");
    END ;
    x.typ:=n^.typ
  END Design;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE ActualPar(n: OPT.Node; fp: OPT.Object; VAR proc: OPL.Item; rightToLeft:BOOLEAN);
    (* function:      computes all parameters of a procedure                  *)
    (* precondition:  procMode = mode of called procedure                     *)
    (*                n = node of first actual parameter                      *)
    (*                fp = first formal parameter                             *)
    (* postcondition  if proc is a type bound procedure the address of the    *)
    (*                method is calculated and loaded into proc               *)

  VAR 
(*    ap, rec: OPL.Item; *)
    receiver: OPT.Node;
    
    PROCEDURE Process(n:OPT.Node; fp:OPT.Object);
    VAR
      ap:OPL.Item;
      superType:OPT.Struct;
    BEGIN
      expr(n, ap);
      IF n = receiver THEN
        IF proc.inx.key = super THEN
          IF ap.typ^.form = Pointer THEN 
            superType:=ap.typ^.BaseTyp^.BaseTyp;
          ELSE 
            superType:=ap.typ^.BaseTyp;
          END;
        ELSE
          superType:=NIL;
        END;
        OPC.Param(ap, fp, n^.class = Nderef, superType=NIL); (* if ap is receiver address is fixed to point to typetag here *)
        IF (ap.adr <= 0) & (n^.class = Nproc) THEN    (* for forward procedures     *)
          n^.obj^.linkadr:=ap.disp;
        END;
        (* ap has to point directly to typetag here *)
        OPC.LoadMTA(ap, superType, proc);
        (* OPL.Release(ap) is done in LoadMTA *)
      ELSE
        OPC.Param(ap, fp, n^.class = Nderef, FALSE); (* if ap is receiver address is fixed to point to typetag here *)
        IF (ap.adr <= 0) & (n^.class = Nproc) THEN    (* for forward procedures     *)
          n^.obj^.linkadr:=ap.disp;
        END;
        OPL.Release(ap);
      END;
(*      expr(n, ap);
      IF n = receiver THEN
        OPC.LoadMTA(rec, proc.inx.key = super, n^.class = Nderef, proc);
        (* OPL.Release(rec) is done in LoadMTA *)
      END;
      OPC.Param(ap, fp, n^.class = Nderef);
      IF (ap.adr <= 0) & (n^.class = Nproc) THEN    (* for forward procedures     *)
        n^.obj^.linkadr:=ap.disp;
      END;
      OPL.Release(ap); *)
    END Process;
    
    PROCEDURE RevTraversal(n:OPT.Node; fp:OPT.Object); (* process list of parameters in reverse order *)
    BEGIN          (* recursion used to overcome problem of list linked in wrong direction *)
      IF n#NIL THEN 
        RevTraversal(n^.link,fp^.link);
        Process(n,fp);
      END;
    END RevTraversal;
    
  BEGIN
    IF proc.mode = TProc THEN 
      receiver:=n;
(*      expr(n, rec) *)
    ELSE receiver:=NIL END ;
    IF rightToLeft THEN (* + 28.08.96 *)
      RevTraversal(n,fp);
    ELSE
      WHILE n # NIL DO
        Process(n,fp);
        n:=n^.link; fp:=fp^.link
      END
    END;
  END ActualPar;

(*----------------------------------------------------------------------------*)
  PROCEDURE expr(n: OPT.Node; VAR x: OPL.Item);
    (* function:      evaluates the expression of node 'n' and returns the    *)
    (*                result in item 'x'                                      *)
    (* precondition:  n = anchore node of expression                          *)
    (* postcondition: x = value of expression                                 *)

  VAR 
    y, z: OPL.Item; 
    f, g: INTEGER; 
    regs: Reg.RegSetT;
    common: BOOLEAN;
    proc: OPT.Object; 
    isWProc: BOOLEAN;
    isCDeclProc: BOOLEAN;
    pSize:LONGINT;
  BEGIN
    CASE n^.class OF
       Nconst:
        x.mode:=MODE_CON; 
        x.typ:=n^.typ;
        x.mnolev:=0;
        (* OPC.CompleteItem(n, x) *)
        CASE n^.typ^.form OF
          Bool, Byte, Char..LInt, NilTyp, Pointer:
            x.adr:=n^.conval^.intval;
        | Real, LReal:
            IF n^.obj = NIL THEN
              OPL.AllocReal(n^.conval^.realval, n^.conval^.intval, n^.typ^.form = LReal);
              x.adr:=n^.conval^.intval;
            ELSE
              IF n^.obj^.conval^.intval = OPM.ConstNotAlloc THEN
                OPL.AllocReal(n^.obj^.conval^.realval, n^.obj^.conval^.intval, n^.typ^.form = LReal)
              END;
              x.adr:=n^.obj^.conval^.intval;
            END;
            x.disp:=0;
        | Set:
            x.adr:=SYSTEM.VAL(LONGINT, n^.conval^.setval);
        | String:
            IF n^.obj = NIL THEN
              OPL.AllocString(n^.conval^.ext^, n^.conval^.intval2, n^.conval^.intval)
            ELSE
              IF n^.obj^.conval^.intval = OPM.ConstNotAlloc THEN
                OPL.AllocString(n^.conval^.ext^, n^.conval^.intval2,
                                n^.obj^.conval^.intval)
              END;
              n^.conval^.intval:=n^.obj^.conval^.intval
            END;
            x.adr:=n^.conval^.intval; x.disp:=n^.conval^.intval2
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"expr");
        END
    | Nupto:    (* n^.typ = OPT.settyp *)
        expr(n^.left, y); expr(n^.right, z); OPC.SetRange(x, y, z);
        OPL.Release(y); OPL.Release(z);
    | Nmop:
        expr(n^.left, x);
        CASE n^.subcl OF
           not:
            OPC.Not(x)
        | minus:
            OPC.Neg(x)
        | is:
            OPC.TypTest(x, n^.obj^.typ, FALSE, FALSE)
        | conv:
            f:=x.typ^.form; 
            g:=n^.typ^.form;
            IF g = Set THEN 
              OPC.SetElem(x)
            ELSE 
              OPC.Convert(x, f, g)
            END
        | abs:
            OPC.AbsVal(x)
        | cap:
            OPC.Cap(x)
        | odd:
            OPC.Odd(x)
        | (*SYSTEM*)OP_SYSADR, cc, val:
            OPC.SYSmop(x, n^.subcl, x.typ^.form, n^.typ^.form)
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPV.expr Nmop");
        END;
    | Ndop:
        expr(n^.left, x); f:=x.typ^.form;
        IF n^.subcl = and THEN OPC.CondAnd(x)
        ELSIF n^.subcl = or THEN OPC.CondOr(x)
        ELSIF (n^.subcl >= eql) & (n^.subcl <= geq) THEN OPC.Relation(x)
        END ;
        expr(n^.right, y);
        IF n^.subcl IN {times, slash, div, mod, plus, minus, ash, msk, lsh, rot} THEN
          common:=n^.left^.class = Ncommon;
          IF common THEN n^.left^.class:=CommonDesignClass END ;
          OPC.LeftOperand(x, f IN realSet, common)
        END ;
        CASE n^.subcl OF
           times:
            IF f = Set THEN OPC.SetInter(x, y)
            ELSE OPC.Mul(x, y, f IN realSet)
            END
        | slash:
            IF f = Set THEN OPC.SetSymmDiff(x, y)
            ELSE OPC.FloatDiv(x, y)
            END
        | div:
            OPC.DivMod(x, y, TRUE)
        | mod:
            OPC.DivMod(x, y, FALSE)
        | and:
            OPC.And(x, y)
        | plus:
            IF f = Set THEN OPC.SetUnion(x, y)
            ELSE OPC.Add(x, y, f IN realSet)
            END
        | minus:
            IF f = Set THEN OPC.SetDiff(x, y)
            ELSE OPC.Sub(x, y, f IN realSet)
            END
        | or:
            OPC.Or(x, y)
        | eql..geq:
            OPC.Cmp(x, y, n^.subcl)
        | in:
            OPC.In(x, y)
        | ash:
            OPC.Ash(x, y)
        | msk:
            OPC.Msk(x, y)
        | len:
            OPC.Len(x, y)
        | (*SYSTEM*)bit, lsh, rot:
            OPC.SYSdop(x, y, n^.subcl)
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPV.expr 1");
        END;
        OPL.Release(y);
    | NODE_SYSMOP:
        expr(n^.left, x); 
        CASE n^.subcl OF
          OP_SYSNOT:OPC.SysNOT(x);
        | OP_SYSHIWORD:OPC.SysHiWord(x);
        | OP_SYSLOWORD:OPC.SysLoWord(x);
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPV.expr Nmop");
        END;
    | NODE_SYSDOP:
        expr(n^.left, x); (* f:=x.typ^.form; !C! *)
        expr(n^.right, y);
(* !C!       IF n^.subcl IN {times, slash, div, mod, plus, minus, ash, msk, lsh, rot} THEN
          common:=n^.left^.class = Ncommon;
          IF common THEN n^.left^.class:=CommonDesignClass END ;
          OPC.LeftOperand(x, f IN realSet, common)
        END ; *)
        CASE n^.subcl OF
          OP_SYSXOR: OPC.SysXOR(x,y);
        | OP_SYSOR:  OPC.SysOR(x,y);
        | OP_SYSAND: OPC.SysAND(x,y);
        | OP_SYSMKLONG: OPC.SysMkLong(x,y);
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPV.expr 2");
        END;
        OPL.Release(y);
    | Ncall:
        IF n^.left^.class = Nproc THEN (* procedure ? *)
          proc:=n^.left^.obj;
          isWProc:=proc^.mode = WProc;
          isCDeclProc:=proc^.mode = MODE_CDECLPROC;
          IF proc^.conval.intval=-1 THEN
            ParamSize(proc^.link,proc^.conval.intval); 
          END;
          pSize:=proc^.conval.intval;
        ELSE                           (* procedure variable ? *)
          proc:= NIL;
          isWProc:=n^.left^.typ^.sysflag = OPM.SYSFLAG_APICALL;
          isCDeclProc:=n^.left^.typ^.sysflag = OPM.SYSFLAG_CDECL;
          IF n^.left^.typ^.form#ProcTyp THEN
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPV.expr(ProcTyp)");
          END;
          IF n^.left^.conval=NIL THEN
            n^.left^.conval:=OPT.NewConst();  
            n^.left^.conval.intval:=-1;
          END;
          IF n^.left^.conval.intval=-1 THEN
            ParamSize(n^.left^.typ^.link,n^.left^.conval.intval); 
          END;
          pSize:=n^.left^.conval.intval;
        END;
        Reg.SaveCPURegisters(regs);
        Design(n^.left, x);
        ActualPar(n^.right, n^.obj, x,isCDeclProc OR isWProc);
        OPC.Call(x, isWProc, isCDeclProc, proc, pSize);
        x.typ:=n^.typ; (* get result type *)
        OPL.GetFunctionReturnValue(regs, x); (* this includes a call to Reg.RestoreCPURegisters *)
    ELSE 
      Design(n, x)
    END ;
    x.typ:=n^.typ
  END expr;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE stat(n: OPT.Node);
    (* function:      evaluates the statement of node 'n'                     *)
    (* precondition:  n = ancore node of statement                            *)

  VAR 
    x, y, z: OPL.Item; 
    proc, par: OPT.Object; 
    i, j: INTEGER; 
    ch: CHAR;
    L, Lcfj, prevExitChain: OPL.Label; 
(*    regs: OPL.RegSetT;*)
    btyp: OPT.Struct; 
    isCDeclProc,isWProc: BOOLEAN;
    pSize:LONGINT;

    PROCEDURE IfStat(n: OPT.Node; withtrap: BOOLEAN);
    VAR 
      x: OPL.Item; 
      Lcfj, Lfix: OPL.Label; 
      if: OPT.Node;
    BEGIN
      Lfix:=0; 
      if:=n^.left;
      LOOP
        (* !!!
        OPM.errpos:=if^.conval^.intval; (*!*) AddDebugInfo; *)
        OPM.errpos:=if^.txtpos;
        Coff.AddLineNum(OPL.pc,SHORT(if^.txtpos.line),FALSE);
        expr(if^.left, x); 
        OPC.CFJ(x, Lcfj);
        OPL.Release(x); (*!Checkpc;*) 
        stat(if^.right); 
        if:=if^.link;
        IF if = NIL THEN EXIT END ;
        OPC.FJ(Lfix); 
        OPL.FixLink(Lcfj)
      END ;
      IF (n^.right # NIL) OR withtrap THEN 
        OPC.FJ(Lfix); 
        OPL.FixLink(Lcfj);
        IF withtrap THEN 
          (* !!! OPM.errpos:=n^.conval^.intval; *)
          OPM.errpos:=n^.txtpos;
          CB.Trap(WithTrap); 
          (*!Checkpc*)
        ELSE 
          stat(n^.right)
        END
      ELSE 
        OPL.FixLink(Lcfj)
      END ;
      OPL.FixLink(Lfix);
      Coff.AddLineNum(OPL.pc,SHORT(n^.left^.endLine),FALSE);
    END IfStat;
    
    PROCEDURE CaseStat(n: OPT.Node);
    VAR 
      x: OPL.Item; 
      Lfix: OPL.Label;
      case, lab: OPT.Node; 
      tab, low, high: LONGINT;
    BEGIN
      expr(n^.left, x); 
      low:=n^.right^.conval^.intval; 
      high:=n^.right^.conval^.intval2;
      OPC.Case(x, low, high, tab); (*!Checkpc;*) 
      Lfix:=0; 
      OPL.Release(x);
      IF n^.right^.conval^.setval # {} THEN (* ELSE clause *)
        stat(n^.right^.right); 
        OPC.FJ(Lfix);
      ELSE 
        CB.Trap(CaseTrap)
      END ;
      case:=n^.right^.left;
      WHILE case # NIL DO    (* case^.class = Ncasedo *)
        lab:=case^.left;
        WHILE lab # NIL DO
          OPL.CaseJump(tab, lab^.conval^.intval - low, lab^.conval^.intval2 - low);
          lab:=lab^.link
        END ;
        stat(case^.right); 
        OPC.FJ(Lfix);
        case:=case^.link
      END ;
      OPL.FixLink(Lfix)
    END CaseStat;
    
    PROCEDURE Dim(VAR x, z: OPL.Item; n: OPT.Node; dimtyp, dim0typ: OPT.Struct);
    VAR 
      y: OPL.Item;
    BEGIN
      expr(n, y);
      OPC.MulDim(y, z, dimtyp, dim0typ);
      IF n^.link # NIL THEN
        Dim(x, z, n^.link, dimtyp^.BaseTyp, dim0typ);
      ELSE
        OPC.New(x, z);
        OPL.Release(z);
        CB.DeRef(x);
        x.typ:=x.typ^.BaseTyp;
      END;
      OPC.SetDim(x, y, dimtyp);
      OPL.Release(y);
    END Dim;

    PROCEDURE ProcEnter;
    VAR
      lineNumInx,startLine:INTEGER;
      startOffs:LONGINT;
      txt:ARRAY OPM.MaxIdLen*3+3 OF CHAR;
      dummy:LONGINT;
    BEGIN
      DEC(OPL.nofStat); (*!L*)
      startLine:=SHORT(n^.txtpos.line);
      IF n^.obj = NIL THEN (* enter module *)
        startOffs:=OPL.pc;
        Coff.AddLineNum(startOffs,startLine,TRUE); lineNumInx:=Coff.GetLineInx();
        OPC.Enter(NIL, 0); 
        IF OPM.addSymDebugInfo THEN 
          DebugInfo.SetModuleBodyCodeStart(OPL.pc-startOffs);
        END;
        stat(n^.right); 
        IF OPM.addSymDebugInfo THEN 
          DebugInfo.SetModuleBodyCodeEnd(OPL.pc-startOffs);
        END;
        OPC.Exit(NIL);
        IF OPM.addSymDebugInfo THEN 
          DebugInfo.SetModuleBodyProcLen(OPL.pc-startOffs-1);
        END;
        WriteObj.DefineExport(NIL,startOffs,OPL.pc-startOffs,startLine,Coff.GetLastLine(),lineNumInx,Coff.NofProcLines());
        INC(OPL.level); 
        stat(n^.left); 
        DEC(OPL.level);
      ELSE (* enter proc *)
        proc:=n^.obj; 
        IF OPM.addDebugInfo & (proc^.debugInfo=NIL) THEN
          proc^.debugInfo:=OPT.NewDebugInfo();
        END;
        par:=proc^.link;
        INC(OPL.level); 
        stat(n^.left);                  (* local procedures *)
        DEC(OPL.level);
        startOffs:=OPL.pc;
        Coff.AddLineNum(startOffs,startLine,TRUE); lineNumInx:=Coff.GetLineInx();
        OPC.Enter(proc, proc^.conval^.intval2);
        OPC.InitPtrs(proc);
        WHILE par # NIL DO    (* code for dynamic array value parameters *)
          IF (par^.typ^.comp = DynArr) & (par^.mode = MODE_VAR) THEN
            OPC.CopyDynArray(par^.adr, par^.typ)
          END ;
          par:=par^.link
        END ;
        IF proc^.debugInfo#NIL THEN
          proc^.debugInfo.codeDebugStart:=OPL.pc-startOffs;
        END;
        stat(n^.right);
        IF proc^.debugInfo#NIL THEN
          proc^.debugInfo.codeDebugEnd:=OPL.pc-startOffs;
        END;
        IF proc^.typ # OPT.notyp THEN CB.Trap(FuncTrap) END ;
        Coff.AddLineNum(OPL.pc,SHORT(n^.endLine),FALSE);
        OPC.Exit(proc);
        IF proc^.debugInfo#NIL THEN
          proc^.debugInfo.procLen:=OPL.pc-startOffs-1;
        END;
        IF OPL.level>1 THEN
          WriteObj.DefineLocalProc(proc,startOffs,OPL.pc-startOffs,startLine,Coff.GetLastLine(),lineNumInx,Coff.NofProcLines());
        ELSE
          WriteObj.DefineExport(proc,startOffs,OPL.pc-startOffs,startLine,Coff.GetLastLine(),lineNumInx,Coff.NofProcLines());
        END;
      END
    END ProcEnter;

  BEGIN
    WHILE (n # NIL) & OPM.noerr DO
      (* !!! *)
      OPM.errpos:=n^.txtpos; (*!*) 
      OPL.BegStat;
      CASE n^.class OF
        Nenter:
          ProcEnter;
      | Ninittd:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          DEC(OPL.nofStat); (*!L*)
          OPC.InitTypDesc(n^.typ)
      | Nassign:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          IF n^.subcl = (*SYSTEM*)movefn THEN    (* x^:=first z bytes at y *)
            expr(n^.right^.link, z); expr(n^.right, y); expr(n^.left, x);
            OPC.SYSmove(x, y, z);
            OPL.Release(x); OPL.Release(y); OPL.Release(z);
          ELSE
            (*!expr(n^.left, x);*)
            IF n^.subcl = assign THEN
              IF DoCommonDesign & (n^.right^.class = Ndop) &
                (n^.right^.subcl IN {times, slash, div, mod, plus, minus, ash, msk, lsh, rot}) &
                SameDesign(n^.left, n^.right^.left) THEN
                  expr(n^.left, x);(*!*)
                  CommonDesign:=x;
                  CommonDesignClass:=n^.right^.left^.class;
                  n^.right^.left^.class:=Ncommon;
                  expr(n^.right, y); OPL.Release(y)  (* assignment done in expr *) 
              ELSE
                expr(n^.right, y);
                IF y.mode = Coc THEN CB.CocToReg(y) END;(*!*)
                expr(n^.left, x);(*!*)
                OPC.Assign(x, y);
                IF (y.adr <= 0) & (n^.right^.class = Nproc) THEN(* for forward procedures*) (*!+*)
                  n^.right^.obj^.linkadr:=y.disp;
                END; (*!-*)
              END
            ELSE
              expr(n^.left, x);(*!*)
              IF ~(n^.subcl IN {newfn, sysnewfn}) THEN expr(n^.right, y) ELSE y.mode:=0 END ;
              CASE n^.subcl OF
                 newfn:
                  btyp:=x.typ^.BaseTyp;
                  IF n^.right # NIL THEN (*open array*)
                    Dim(x, z, n^.right, btyp, btyp);
                  ELSE
                    OPC.New(x, z);    (* z not used for record or array *)
                  END
              | incfn:
                  OPC.Increment(x, y, FALSE);
              | decfn:
                  OPC.Increment(x, y, TRUE);
              | inclfn, exclfn:
                  OPC.Include(x, y, n^.subcl = exclfn)
              | copyfn:
                  OPC.Copy(x, y)
              | (*SYSTEM*)getfn, putfn, getrfn, putrfn:
                  OPC.SYSgetput(x, y, n^.subcl)
              | (*SYSTEM*)sysnewfn:
                  expr(n^.right, y); OPC.SYSnew(x, y);
              ELSE 
                OPM.CommentedErr(E.INTERNAL_MURKS,"stat/Nassign");
              END
            END;
            OPL.Release(x); OPL.Release(y);
          END
      | Ncall:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          IF n^.left^.class = Nproc THEN (* procedure ? *)
            proc:=n^.left^.obj;
            isWProc:=proc^.mode = WProc;
            isCDeclProc:=proc^.mode = MODE_CDECLPROC;
            IF proc^.conval^.intval=-1 THEN
              ParamSize(proc^.link,proc^.conval^.intval) 
            END;
            pSize:=proc^.conval^.intval;
          ELSE                           (* procedure variable ? *)
            proc:= NIL;
            isWProc:=n^.left^.typ^.sysflag = OPM.SYSFLAG_APICALL;
            isCDeclProc:=n^.left^.typ^.sysflag = OPM.SYSFLAG_CDECL;
            ParamSize(n^.left^.typ^.link,pSize) 
          END;
          Design(n^.left, x);
          ActualPar(n^.right, n^.obj, x,isCDeclProc OR isWProc);
          OPC.Call(x, isWProc, isCDeclProc, proc, pSize);
          x.typ:=n^.typ; (* get result type *)
          OPL.Release(x);
      | Nifelse:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          IF (n^.subcl # assertfn) OR assert THEN IfStat(n, FALSE) END
      | Ncase:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          CaseStat(n)
      | Nwhile:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          L:=OPL.pc; 
          expr(n^.left, x); 
          OPC.CFJ(x, Lcfj); (*!Checkpc;*)
          OPL.Release(x); 
          stat(n^.right);
          Coff.AddLineNum(OPL.pc,SHORT(n^.endLine),FALSE);
          OPC.BJ(L); 
          OPL.FixLink(Lcfj)
      | Nrepeat:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          L:=OPL.pc; 
          stat(n^.left); 
          Coff.AddLineNum(OPL.pc,SHORT(n^.endLine),FALSE);
          expr(n^.right, x); 
          OPC.CBJ(x, L);
          OPL.Release(x);
      | Nloop:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          prevExitChain:=ExitChain; 
          ExitChain:=0;
          L:=OPL.pc; 
          stat(n^.left); 
          Coff.AddLineNum(OPL.pc,SHORT(n^.endLine),FALSE);
          OPC.BJ(L);
          OPL.FixLink(ExitChain); 
          ExitChain:=prevExitChain
      | Nexit:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          OPC.FJ(ExitChain)
      | Nreturn:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          IF n^.left # NIL THEN
            expr(n^.left, x); OPC.Result(n^.obj, x); OPL.Release(x) (*!*)
          END ;
          OPC.Exit(n^.obj);    (* from module if n^.obj = NIL *) (*!*)
      | Nwith:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          IfStat(n, n^.subcl = 0) 
      | Ntrap:
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          CB.Trap(n^.right^.conval^.intval)
      | Ndispose: (*!+*)
          Coff.AddLineNum(OPL.pc,SHORT(n^.txtpos.line),FALSE);
          expr(n^.left, x);
          OPC.Dispose(x);
          OPL.Release(x);
      ELSE 
        OPM.CommentedErr(E.INTERNAL_MURKS,"stat");
      END ;
      (*!Checkpc;*) 
      OPL.EndStat; 
      n:=n^.link;
    END
  END stat;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE Module*(prog: OPT.Node);
    (* function:      generates code for a hole program                       *)
    (* precondition:  prog = anchore node of program (= first statement)      *)

  BEGIN
    stat(prog);
(* !C!    IF OPC.nofXTIProc # 0 THEN OPM.CommentedErr(E.INTERNAL_MURKS,"nofXTIProc"); END;*)
  END Module;

END OPV.
