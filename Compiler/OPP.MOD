(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPP;                                     (**)
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
(* PURPOSE: Parser of Oberon2 compiler DLL                                    *)
(*                                                                            *)
(******************************************************************************)

  IMPORT
    OPT, OPS, OPM, OPB, E:=Error;
    
  CONST
    (* numtyp values *)
    char = 1; integer = 2; real = 3; longreal = 4;

    (* symbol values *)
    null = 0; times = 1; slash = 2; div = 3; mod = 4;
    and = 5; plus = 6; minus = 7; or = 8; eql = 9;
    neq = 10; lss = 11; leq = 12; gtr = 13; geq = 14;
    in = 15; is = 16; arrow = 17; period = 18; comma = 19;
    colon = 20; upto = 21; rparen = 22; rbrak = 23; rbrace = 24;
    of = 25; then = 26; do = 27; to = 28; by = 29;
    lparen = 30; lbrak = 31; lbrace = 32; not = 33; becomes = 34;
    number = 35; nil = 36; string = 37; ident = 38; semicolon = 39;
    bar = 40; end = 41; else = 42; elsif = 43; until = 44;
    if = 45; case = 46; while = 47; repeat = 48; for = 49;
    loop = 50; with = 51; exit = 52; return = 53; array = 54;
    record = 55; pointer = 56; begin = 57; const = 58; type = 59;
    var = 60; procedure = 61; import = 62; module = 63; eof = 64;
    definition = 65; 
    SYM_APICALL=OPS.SYM_APICALL;
    SYM_CDECL  =OPS.SYM_CDECL;
    SYM_STATICTYPED=OPS.SYM_STATICTYPED;
    SYM_NOTALIGEND=OPS.SYM_NOTALIGNED;

    (* object modes *)
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

    (* Structure forms *)
    Undef = 0; Byte = 1; Bool = 2; Char = 3; SInt = 4; Int = 5; LInt = 6;
    Real = 7; LReal = 8; Set = 9; String = 10; NilTyp = 11; NoTyp = 12;
    Pointer = 13; ProcTyp = 14; Comp = 15;
    intSet = {SInt..LInt};
    
    (* composite structure forms *)
    Basic = 1; Array = 2; DynArr = 3; Record = 4;

    (*function number*)
    haltfn = 0; newfn = 1; incfn = 13; sysnewfn = 30;
    disposefn = 33; (*!*)

    (* nodes classes *)
    Nvar = 0; Nvarpar = 1; Nfield = 2; Nderef = 3; Nindex = 4; Nguard = 5; Neguard = 6;
    Nconst = 7; Ntype = 8; Nproc = 9; Nupto = 10; Nmop = 11; Ndop = 12; Ncall = 13;
    Ninittd = 14; Nif = 15; Ncaselse = 16; Ncasedo = 17; Nenter = 18; Nassign = 19;
    Nifelse = 20; Ncase = 21; Nwhile = 22; Nrepeat = 23; Nloop = 24; Nexit = 25;
    Nreturn = 26; Nwith = 27; Ntrap = 28;
    Ndispose = 30; (*!*)

    (* node subclasses *)
    super = 1;
    
    (* module visibility of objects *)
    internal = 0; internalR = 1; external = 2; externalR = 3; (*!*)

    (* procedure flags (conval^.setval) *)
    hasBody = 1; isRedef = 2; slNeeded = 3;

    progMainProcName = "ProgMain";
    
  TYPE
    CaseTable = ARRAY OPM.MaxCases OF
      RECORD
        low, high: LONGINT
      END ;
    
  VAR
    sym, level: SHORTINT;
    LoopLevel: INTEGER;
    TDinit, lastTDinit: OPT.Node;
    nofFwdPtr: INTEGER;
    FwdPtr: ARRAY 64 OF OPT.Struct;
    nofStat: LONGINT; (*!L*)

  PROCEDURE^ Type(VAR typ, banned: OPT.Struct);
  PROCEDURE^ Expression(VAR x: OPT.Node);
  PROCEDURE^ Block(VAR procdec, statseq: OPT.Node);

  PROCEDURE Err(code:INTEGER);
  BEGIN 
    OPM.Err(code);
  END Err;

  PROCEDURE CheckSym(s: INTEGER);
  BEGIN
    IF sym = s THEN OPS.Get(sym) ELSE OPM.Err(s) END
  END CheckSym;

  PROCEDURE qualident(VAR id: OPT.Object);
  VAR 
    obj: OPT.Object; 
    lev: SHORTINT;
    nameBuf:OPM.Name;
  BEGIN (*sym = ident*)
    OPT.Find(obj); 
    IF obj=NIL THEN nameBuf:=OPS.name END; (* BugFix 8.3.96 *)
    OPS.Get(sym);
    IF (sym = period) & (obj # NIL) & (obj^.mode = Mod) THEN
      OPS.Get(sym);
      IF sym = ident THEN
        OPT.FindImport(obj, obj); 
        IF obj=NIL THEN nameBuf:=OPS.name END; (* BugFix 8.3.96 *)
        OPS.Get(sym)
      ELSE 
        Err(ident); 
        obj:=NIL
      END
    END;
    IF obj = NIL THEN 
      OPM.CommentedErr(E.UNDECLARED,nameBuf); (* BugFix 8.3.96 *)
      obj:=OPT.NewObj(); 
      obj^.mode:=MODE_VAR; 
      obj^.typ:=OPT.undftyp; 
      obj^.adr:=0
    ELSE 
      lev:=obj^.mnolev;
      IF (obj^.mode IN {MODE_VAR, VarPar, MODE_DLLVAR}) & (lev # level) THEN
        obj^.leaf:=FALSE;
        IF lev > 0 THEN OPB.StaticLink(level-lev) END
      END
    END ;
    id:=obj
  END qualident;

  PROCEDURE ConstExpression(VAR x: OPT.Node);
  BEGIN 
    Expression(x);
    IF x^.class # Nconst THEN
      Err(E.EXPR_SHOULD_BE_CONSTANT); 
      x:=OPB.NewIntConst(1) 
    END
  END ConstExpression;

  PROCEDURE CheckMark(VAR vis: SHORTINT);
  BEGIN 
    OPS.Get(sym);
    IF OPT.defModule THEN (*!+*)
      IF (sym = times) OR (sym = minus) THEN
        IF sym = times THEN Err(E.IDENT_UNMARKED); vis:=external ELSE vis:=externalR END ;
        OPS.Get(sym)
      ELSE vis:=external
      END (*!-*)
    ELSIF (sym = times) OR (sym = minus) THEN
      IF level > 0 THEN Err(E.IDENT_MARKED_WRONG) END ;
      IF sym = times THEN vis:=external ELSE vis:=externalR END ;
      OPS.Get(sym)
    ELSE vis:=internal
    END
  END CheckMark;
  
  PROCEDURE CheckSysFlag(VAR sysflag: INTEGER; default: INTEGER; legalValues:SET);
  (* redesigned 27.08.96 *)
  VAR 
    x: OPT.Node; 
    sf: LONGINT;
  BEGIN
    IF sym = lbrak THEN OPS.Get(sym);
      IF sym = SYM_APICALL THEN  
        IF OPM.SYSFLAG_APICALL IN legalValues THEN
          sysflag:=OPM.SYSFLAG_APICALL;
        ELSE
          sysflag:=0;
          Err(E.ILLEGAL_SYS_FLAG); 
        END;
        OPS.Get(sym); 
      ELSIF sym=SYM_CDECL THEN
        IF OPM.SYSFLAG_CDECL IN legalValues THEN
          sysflag:=OPM.SYSFLAG_CDECL;
        ELSE
          sysflag:=0;
          Err(E.ILLEGAL_SYS_FLAG); 
        END;
        OPS.Get(sym); 
      ELSIF sym=SYM_NOTALIGEND THEN
        IF OPM.SYSFLAG_NOTALIGNED IN legalValues THEN
          sysflag:=OPM.SYSFLAG_NOTALIGNED;
        ELSE
          sysflag:=0;
          Err(E.ILLEGAL_SYS_FLAG); 
        END;
        OPS.Get(sym); 
      ELSE 
        ConstExpression(x);
        IF x^.typ^.form IN intSet THEN 
          sf:=x^.conval^.intval;
          IF (sf#0) & 
             (*!+*) ((sf > MAX(SET)) OR (*!-*) ~(sf IN legalValues)) THEN Err(E.ILLEGAL_SYS_FLAG); sf:=0 END (* bugfix LEI 30.11.98 *)
        ELSE 
          Err(E.CONSTANT_NOT_INT); 
          sf:=0;
        END ;
        sysflag:=SHORT(sf)
      END;
      CheckSym(rbrak)
    ELSE 
      sysflag:=default
    END
  END CheckSysFlag;

  PROCEDURE RecordType(VAR typ, banned: OPT.Struct);
  VAR 
    fld, first, last, base: OPT.Object;
    ftyp: OPT.Struct; 
    sysflag: INTEGER;
  BEGIN 
    typ:=OPT.NewStr(Comp, Record); 
    typ^.BaseTyp:=NIL;
    CheckSysFlag(sysflag, -1,{OPM.SYSFLAG_NOTALIGNED}); (* !!! *)
    IF sym = lparen THEN
      OPS.Get(sym); (*record extension*)
      IF sym = ident THEN
        qualident(base);
        IF ((base^.mode = MODE_TYPE) OR (base^.mode=MODE_DLLTYPE)) & (base^.typ^.comp = Record) THEN
          IF base^.typ = banned THEN 
            Err(E.RECURSIVE_TYPE_DEFINITION)
          ELSE 
            typ^.BaseTyp:=base^.typ; 
            typ^.extlev:=base^.typ^.extlev + 1; 
            typ^.sysflag:=base^.typ^.sysflag
          END
        ELSE
          Err(E.IDENT_NO_TYPE)
        END
      ELSE
        Err(ident)
      END ;
      CheckSym(rparen)
    END ;
    IF sysflag >= 0 THEN typ^.sysflag:=sysflag END ;
    OPT.OpenScope(0, NIL); 
    first:=NIL; 
    last:=NIL;
    LOOP
      IF sym = ident THEN
        LOOP
          IF sym = ident THEN
            IF typ^.BaseTyp # NIL THEN
              OPT.FindField(OPS.name, typ^.BaseTyp, fld);
              IF fld # NIL THEN OPM.CommentedErr(E.MULTIPLY_DEFINED,OPS.name) END
            END ;
            OPT.Insert(OPS.name, fld); 
            CheckMark(fld^.vis);
            fld^.mode:=Fld; 
            fld^.link:=NIL; 
            fld^.typ:=OPT.undftyp;
            IF first = NIL THEN first:=fld END ;
            IF last = NIL THEN typ^.link:=fld ELSE last^.link:=fld END ;
            last:=fld
          ELSE 
            Err(ident)
          END ;
          IF sym = comma THEN 
            OPS.Get(sym)
          ELSIF sym = ident THEN 
            Err(comma)
          ELSE EXIT
          END
        END ;
        CheckSym(colon); 
        Type(ftyp, banned);
        IF ftyp^.comp = DynArr THEN 
          ftyp:=OPT.undftyp; 
          Err(E.OPEN_ARRAY_NOT_ALLOWED);
        END;
        WHILE first # NIL DO
          first^.typ:=ftyp; 
          first:=first^.link
        END
      END ;
      IF sym = semicolon THEN 
        OPS.Get(sym)
      ELSIF sym = ident THEN 
        Err(semicolon)
      ELSE 
        EXIT
      END
    END ;
    OPT.CloseScope
  END RecordType;

  PROCEDURE ArrayType(VAR typ, banned: OPT.Struct);
  VAR 
    x: OPT.Node; 
    n: LONGINT; 
    sysflag: INTEGER;
  BEGIN 
    CheckSysFlag(sysflag, 0,{OPM.SYSFLAG_NOTALIGNED}); (* !!! *)
    IF sym = of THEN  (*dynamic array*)
      typ:=OPT.NewStr(Comp, DynArr); 
      typ^.mno:=0; 
      typ^.sysflag:=sysflag;
      OPS.Get(sym); 
      Type(typ^.BaseTyp, banned);
      IF typ^.BaseTyp^.comp = DynArr THEN 
        typ^.n:=typ^.BaseTyp^.n + 1;
      ELSE 
        typ^.n:=0;
      END
    ELSE
      typ:=OPT.NewStr(Comp, Array); 
      typ^.sysflag:=sysflag; 
      ConstExpression(x);
      IF x^.typ^.form IN intSet THEN 
        n:=x^.conval^.intval;
        IF (n <= 0) OR (n > OPM.MaxIndex) THEN Err(E.ILLEGAL_CONST_VALUE); n:=1 END
      ELSE 
        Err(E.CONSTANT_NOT_INT); 
        n:=1
      END ;
      typ^.n:=n;
      IF sym = of THEN
        OPS.Get(sym); 
        Type(typ^.BaseTyp, banned)
      ELSIF sym = comma THEN
        OPS.Get(sym); 
        IF sym # of THEN ArrayType(typ^.BaseTyp, banned) END
      ELSE 
        Err(E.EXPECTED1)
      END ;
      IF typ^.BaseTyp^.comp = DynArr THEN typ^.BaseTyp:=OPT.undftyp; Err(E.OPEN_ARRAY_NOT_ALLOWED) END
    END
  END ArrayType;

  PROCEDURE PointerType(VAR typ: OPT.Struct);
  VAR 
    id: OPT.Object;
  BEGIN 
    typ:=OPT.NewStr(Pointer, Basic); 
(*    CheckSysFlag(typ^.sysflag, 0,{OPM.SYSFLAG_APICALL}); (* !!! *)*)
    typ^.sysflag:=0;
    CheckSym(to);
    IF sym = ident THEN 
      OPT.Find(id);
      IF id = NIL THEN
        IF nofFwdPtr < LEN(FwdPtr) THEN 
          FwdPtr[nofFwdPtr]:=typ; 
          INC(nofFwdPtr)
        ELSE 
          Err(E.TOO_MANY_POINTER_TYPES)
        END ;
        typ^.link:=OPT.NewObj(); COPY(OPS.name, typ^.link^.name);
        typ^.BaseTyp:=OPT.undftyp; OPS.Get(sym) (*forward ref*)
      ELSE qualident(id);
        IF (id^.mode = MODE_TYPE) OR (id^.mode=MODE_DLLTYPE) THEN
          IF id^.typ^.comp IN {Array, DynArr, Record} THEN
            typ^.BaseTyp:=id^.typ
          ELSE typ^.BaseTyp:=OPT.undftyp; Err(E.POINTER_BOUND_TO_BASIC)
          END
        ELSE typ^.BaseTyp:=OPT.undftyp; Err(E.IDENT_NO_TYPE)
        END
      END
    ELSE Type(typ^.BaseTyp, OPT.notyp);
      IF ~(typ^.BaseTyp^.comp IN {Array, DynArr, Record}) THEN
        typ^.BaseTyp:=OPT.undftyp; Err(E.POINTER_BOUND_TO_BASIC)
      END
    END
  END PointerType;
  
  PROCEDURE FormalParameters(VAR firstPar: OPT.Object; VAR resTyp: OPT.Struct);
  VAR 
    mode: SHORTINT;
    par, first, last, res: OPT.Object; 
    typ: OPT.Struct;
  BEGIN 
    first:=NIL; 
    last:=firstPar;
    IF (sym = ident) OR (sym = var) THEN
      LOOP
        IF sym = var THEN 
          OPS.Get(sym);
          IF sym=SYM_STATICTYPED THEN (* !C! *)
            IF ~OPT.defModule THEN OPM.Err(E.STATICTYPED_IN_MODULE) END;
            mode:=MODE_VARSTPAR;
            OPS.Get(sym);
          ELSE
            mode:=VarPar;
          END;
        ELSE 
          mode:=MODE_VAR;
        END ;
        LOOP
          IF sym = ident THEN
            OPT.Insert(OPS.name, par); 
            OPS.Get(sym);
            IF (mode = VarPar) & (sym = minus) THEN (*!+*)
              OPS.Get(sym); 
              par^.vis:=internalR
            ELSE
              par^.vis:=internal
            END; (*!-*) 
            par^.mode:=mode; 
            par^.link:=NIL;
            IF first = NIL THEN first:=par END ;
            IF firstPar = NIL THEN firstPar:=par ELSE last^.link:=par END ;
            last:=par
          ELSE 
            Err(ident)
          END ;
          IF sym = comma THEN 
            OPS.Get(sym)
          ELSIF sym = ident THEN 
            Err(comma)
          ELSIF sym = var THEN 
            Err(comma); 
            OPS.Get(sym)
          ELSE 
            EXIT
          END
        END ;
        CheckSym(colon); 
        Type(typ, OPT.notyp); (* assign types to param list previously read *)
        WHILE first # NIL DO 
          first^.typ:=typ; 
          (* BugFix+ 10.3.1996 *)
          IF (typ^.comp=Basic) & (first^.mode=VarPar) & (first^.vis=internalR) THEN
            OPM.CommentedErr(E.BASIC_RO_VAR_PARAM,first^.name);
          END;
          (* BugFix- 10.3.1996 *)
          IF (first^.mode=MODE_VARSTPAR) & (typ^.comp#Record) THEN (* !C! *)
            OPM.Err(E.STATICTYPED_NO_RECORD);
          END;
          first:=first^.link;
        END ;
        IF sym = semicolon THEN 
          OPS.Get(sym)
        ELSIF sym = ident THEN 
          Err(semicolon)
        ELSE 
          EXIT
        END
      END
    END ;
    CheckSym(rparen);
    IF sym = colon THEN
      OPS.Get(sym); 
      resTyp:=OPT.undftyp;
      IF sym = ident THEN 
        qualident(res);
        IF (res^.mode = MODE_TYPE) OR (res^.mode=MODE_DLLTYPE) THEN
          IF res^.typ^.form < Comp THEN 
            resTyp:=res^.typ
          ELSE 
            Err(E.RESULT_TYPE_NOT_BASIC)
          END
        ELSE
          Err(E.IDENT_NO_TYPE)
        END
      ELSE
        Err(ident)
      END
    ELSE
      resTyp:=OPT.notyp
    END
  END FormalParameters;

  PROCEDURE TypeDecl(VAR typ, banned: OPT.Struct);
  VAR 
    id: OPT.Object;
  BEGIN 
    typ:=OPT.undftyp;
    IF sym < lparen THEN 
      Err(E.TYPEDEF_STARTS_WRONG);
      REPEAT 
        OPS.Get(sym);
      UNTIL sym >= lparen;
    END;
    IF sym = ident THEN 
      qualident(id);
      IF (id^.mode = MODE_TYPE) OR (id^.mode=MODE_DLLTYPE) THEN
        IF id^.typ # banned THEN typ:=id^.typ ELSE Err(E.RECURSIVE_TYPE_DEFINITION) END
      ELSE 
        Err(E.IDENT_NO_TYPE)
      END
    ELSIF sym = array THEN
      OPS.Get(sym); 
      ArrayType(typ, banned)
    ELSIF sym = record THEN
      OPS.Get(sym); 
      RecordType(typ, banned);
      OPB.Inittd(TDinit, lastTDinit, typ); 
      CheckSym(end)
    ELSIF sym = pointer THEN
      OPS.Get(sym); 
      PointerType(typ)
    ELSIF sym = procedure THEN
      OPS.Get(sym); 
      typ:=OPT.NewStr(ProcTyp, Basic); 
      CheckSysFlag(typ^.sysflag, 0,{OPM.SYSFLAG_APICALL,OPM.SYSFLAG_CDECL});
      IF sym = lparen THEN
        OPS.Get(sym); 
        OPT.OpenScope(level, NIL);
        FormalParameters(typ^.link, typ^.BaseTyp); 
        OPT.CloseScope
      ELSE 
        typ^.BaseTyp:=OPT.notyp; 
        typ^.link:=NIL
      END
    ELSE
      Err(E.TYPEDEF_STARTS_WRONG);
    END ;
    LOOP
      IF (sym >= semicolon) & (sym <= else) OR (sym = rparen) OR (sym = eof) THEN EXIT END;
      Err(E.DECL_ENDS_WRONG); IF sym = ident THEN EXIT END;
      OPS.Get(sym)
    END
  END TypeDecl;
  
  PROCEDURE Type(VAR typ, banned: OPT.Struct);
  BEGIN 
    TypeDecl(typ, banned);
    IF (typ^.form = Pointer) & (typ^.BaseTyp = OPT.undftyp) & (typ^.strobj = NIL) THEN 
      Err(E.UNDECLARED);
    END
  END Type;

  PROCEDURE selector(VAR x: OPT.Node);
    VAR obj, proc: OPT.Object; y: OPT.Node; typ: OPT.Struct; name: OPS.Name;
  BEGIN
    LOOP
      IF sym = lbrak THEN OPS.Get(sym);
        LOOP
          IF (x^.typ # NIL) & (x^.typ^.form = Pointer) THEN OPB.DeRef(x) END ;
          Expression(y); OPB.Index(x, y);
          IF sym = comma THEN OPS.Get(sym) ELSE EXIT END
        END ;
        CheckSym(rbrak)
      ELSIF sym = period THEN OPS.Get(sym);
        IF sym = ident THEN name:=OPS.name; OPS.Get(sym);
          IF x^.typ # NIL THEN
            IF x^.typ^.form = Pointer THEN OPB.DeRef(x) END ;
            IF x^.typ^.comp = Record THEN
              OPT.FindField(name, x^.typ, obj); OPB.Field(x, obj);
              IF (obj # NIL) & (obj^.mode = TProc) THEN
                IF sym = arrow THEN  (* super call *) OPS.Get(sym);
                  y:=x^.left;
                  IF y^.class = Nderef THEN y:=y^.left END ;  (* y = record variable *)
                  IF y^.obj # NIL THEN
                    proc:=OPT.topScope;  (* find innermost scope which owner is a TProc *)
                    WHILE (proc^.link # NIL) & (proc^.link^.mode # TProc) DO proc:=proc^.left END ;
                    IF (proc^.link = NIL) OR (proc^.link^.link # y^.obj) THEN Err(E.INVALID_BASE_PROC_CALL) END ;
                    typ:=y^.obj^.typ;
                    IF typ^.form = Pointer THEN typ:=typ^.BaseTyp END ;
                    OPT.FindField(x^.obj^.name, typ^.BaseTyp, proc);
                    IF proc # NIL THEN x^.subcl:=super ELSE Err(E.PROC_UNKNOWN_IN_BASE_TYPE) END
                  ELSE 
                    Err(E.INVALID_BASE_PROC_CALL)
                  END
                END ;
                IF (obj^.typ # OPT.notyp) & (sym # lparen) THEN Err(lparen) END
              END
            ELSE Err(E.IDENT_NO_RECORD)
            END
          ELSE Err(E.IDENT_NO_TYPE)
          END
        ELSE Err(ident)
        END
      ELSIF sym = arrow THEN OPS.Get(sym); OPB.DeRef(x)
      ELSIF (sym = lparen) & (x^.class < Nconst) & (x^.typ^.form # ProcTyp) &
          ((x^.obj = NIL) OR (x^.obj^.mode # TProc)) THEN
        OPS.Get(sym);
        IF sym = ident THEN
          qualident(obj);
          IF (obj^.mode = MODE_TYPE) OR (obj^.mode=MODE_DLLTYPE) THEN 
            OPB.TypTest(x, obj, TRUE)
          ELSE 
            Err(E.IDENT_NO_TYPE)
          END
        ELSE Err(ident)
        END ;
        CheckSym(rparen)
      ELSE EXIT
      END
    END
  END selector;

  PROCEDURE ActualParameters(VAR aparlist: OPT.Node; fpar: OPT.Object);
  VAR 
    apar, last: OPT.Node;
  BEGIN 
    aparlist:=NIL; 
    last:=NIL;
    IF sym # rparen THEN
      LOOP Expression(apar);
        IF fpar # NIL THEN
          OPB.Param(apar, fpar); 
          OPB.Link(aparlist, last, apar);
          fpar:=fpar^.link;
        ELSE 
          Err(E.MORE_PARAMS)
        END ;
        IF sym = comma THEN 
          OPS.Get(sym)
        ELSIF (lparen <= sym) & (sym <= ident) THEN 
          Err(comma)
        ELSE 
          EXIT
        END
      END
    END ;
    IF fpar # NIL THEN Err(E.FEWER_PARAMS) END
  END ActualParameters;

  PROCEDURE StandProcCall(VAR x: OPT.Node);
  VAR 
    y: OPT.Node; 
    m: SHORTINT; 
    n: INTEGER;
  BEGIN 
    m:=SHORT(SHORT(x^.obj^.adr)); 
    n:=0;
    IF sym = lparen THEN 
      OPS.Get(sym);
      IF sym # rparen THEN
        LOOP
          IF n = 0 THEN 
            Expression(x); 
            OPB.StPar0(x, m); 
            n:=1
          ELSIF n = 1 THEN 
            Expression(y); 
            OPB.StPar1(x, y, m); 
            n:=2
          ELSE 
            Expression(y); 
            OPB.StParN(x, y, m, n); 
            INC(n)
          END ;
          IF sym = comma THEN 
            OPS.Get(sym)
          ELSIF (lparen <= sym) & (sym <= ident) THEN 
            Err(comma)
          ELSE 
            EXIT
          END
        END ;
        CheckSym(rparen)
      ELSE 
        OPS.Get(sym)
      END ;
      OPB.StFct(x, m, n)
    ELSE 
      Err(lparen)
    END ;
    IF (level > 0) & ((m = newfn) OR (m = sysnewfn)) THEN OPT.topScope^.link^.leaf:=FALSE END
  END StandProcCall;
  
  PROCEDURE Element(VAR x: OPT.Node);
  VAR 
    y: OPT.Node;
  BEGIN Expression(x);
    IF sym = upto THEN
      OPS.Get(sym); Expression(y); OPB.SetRange(x, y)
    ELSE OPB.SetElem(x)
    END
  END Element;

  PROCEDURE Sets(VAR x: OPT.Node);
    VAR y: OPT.Node;
  BEGIN
    IF sym # rbrace THEN
      Element(x);
      LOOP
        IF sym = comma THEN OPS.Get(sym)
        ELSIF (lparen <= sym) & (sym <= ident) THEN Err(comma)
        ELSE EXIT
        END ;
        Element(y); OPB.Op(plus, x, y)
      END
    ELSE x:=OPB.EmptySet()
    END ;
    CheckSym(rbrace)
  END Sets;
  
  PROCEDURE Factor(VAR x: OPT.Node);
  VAR 
    fpar, id: OPT.Object; 
    apar: OPT.Node;
  BEGIN
    IF sym < lparen THEN 
      Err(E.FACTOR_STARTS_WRONG);
      REPEAT OPS.Get(sym) UNTIL sym >= lparen;
    END ;
    IF sym = ident THEN
      qualident(id); x:=OPB.NewLeaf(id); selector(x);
      IF (x^.class = Nproc) & (x^.obj^.mode = SProc) THEN StandProcCall(x)  (* x may be NIL *)
      ELSIF sym = lparen THEN
        OPS.Get(sym); 
        OPB.PrepCall(x, fpar);
        ActualParameters(apar, fpar);
        OPB.Call(x, apar, fpar);
        CheckSym(rparen);
        IF level > 0 THEN OPT.topScope^.link^.leaf:=FALSE END
      END
    ELSIF sym = number THEN
      CASE OPS.numtyp OF
         char: x:=OPB.NewIntConst(OPS.intval); x^.typ:=OPT.chartyp
      | integer: x:=OPB.NewIntConst(OPS.intval)
      | real: x:=OPB.NewRealConst(OPS.realval, OPT.realtyp)
      | longreal: x:=OPB.NewRealConst(OPS.lrlval, OPT.lrltyp)
      END ;
      OPS.Get(sym)
    ELSIF sym = string THEN
      x:=OPB.NewString(OPS.str, OPS.intval); 
      OPS.Get(sym)
    ELSIF sym = nil THEN
      x:=OPB.Nil(); OPS.Get(sym)
    ELSIF sym = lparen THEN
      OPS.Get(sym); 
      Expression(x); 
      CheckSym(rparen)
    ELSIF sym = lbrak THEN
      OPS.Get(sym); 
      Err(lparen); 
      Expression(x); 
      CheckSym(rparen)
    ELSIF sym = lbrace THEN 
      OPS.Get(sym); 
      Sets(x)
    ELSIF sym = not THEN
      OPS.Get(sym); 
      Factor(x); 
      OPB.MOp(not, x)
    ELSE 
      Err(E.FACTOR_STARTS_WRONG); 
      OPS.Get(sym); x:=NIL
    END ;
    IF x = NIL THEN x:=OPB.NewIntConst(1); x^.typ:=OPT.undftyp END
  END Factor;

  PROCEDURE Term(VAR x: OPT.Node);
  VAR 
    y: OPT.Node; 
    mulop: SHORTINT;
  BEGIN Factor(x);
    WHILE (times <= sym) & (sym <= and) DO
      mulop:=sym; OPS.Get(sym);
      Factor(y); OPB.Op(mulop, x, y)
    END
  END Term;

  PROCEDURE SimpleExpression(VAR x: OPT.Node);
  VAR 
    y: OPT.Node; 
    addop: SHORTINT;
  BEGIN
    IF sym = minus THEN OPS.Get(sym); Term(x); OPB.MOp(minus, x)
    ELSIF sym = plus THEN OPS.Get(sym); Term(x); OPB.MOp(plus, x)
    ELSE Term(x)
    END ;
    WHILE (plus <= sym) & (sym <= or) DO
      addop:=sym; OPS.Get(sym);
      Term(y); OPB.Op(addop, x, y)
    END
  END SimpleExpression;

  PROCEDURE Expression(VAR x: OPT.Node);
  VAR 
    y: OPT.Node; 
    obj: OPT.Object; 
    relation: SHORTINT;
  BEGIN 
    SimpleExpression(x);
    IF (eql <= sym) & (sym <= geq) THEN
      relation:=sym; 
      OPS.Get(sym);
      SimpleExpression(y); 
      OPB.Op(relation, x, y)
    ELSIF sym = in THEN
      OPS.Get(sym); 
      SimpleExpression(y); 
      OPB.In(x, y)
    ELSIF sym = is THEN
      OPS.Get(sym);
      IF sym = ident THEN
        qualident(obj);
        IF (obj^.mode = MODE_TYPE) OR (obj^.mode=MODE_DLLTYPE) THEN 
          OPB.TypTest(x, obj, FALSE)
        ELSE 
          Err(E.IDENT_NO_TYPE)
        END
      ELSE 
        Err(ident)
      END
    END
  END Expression;

  PROCEDURE Receiver(VAR mode, vis: SHORTINT; VAR name: OPS.Name; VAR typ, rec: OPT.Struct);
  VAR 
    obj: OPT.Object;
  BEGIN 
    typ:=OPT.undftyp; 
    rec:=NIL;
    IF sym = var THEN 
      OPS.Get(sym); 
      mode:=VarPar 
    ELSE 
      mode:=MODE_VAR; 
    END ;
    name:=OPS.name; 
    CheckSym(ident);
    IF (mode = VarPar) & (sym = minus) THEN 
      OPS.Get(sym); 
      vis:=internalR (*!+*)
    ELSE 
      vis:=internal
    END; (*!-*)
    CheckSym(colon);
    IF sym = ident THEN 
      OPT.Find(obj); 
      OPS.Get(sym);
      IF obj = NIL THEN 
        Err(E.UNDECLARED)
      ELSIF (obj^.mode # MODE_TYPE) & (obj^.mode#MODE_DLLTYPE) THEN 
        Err(E.RECORD_NOT_SAME_SCOPE)
      ELSE 
        typ:=obj^.typ; 
        rec:=typ;
        IF rec^.form = Pointer THEN rec:=rec^.BaseTyp END ;
        IF ~((mode = MODE_VAR) & (typ^.form = Pointer) & (rec^.comp = Record) OR
          (mode = VarPar) & (typ^.comp = Record)) THEN Err(E.WRONG_RECEIVER); rec:=NIL END ;
        IF (rec # NIL) & (rec^.mno # level) THEN Err(E.RECORD_NOT_SAME_SCOPE); rec:=NIL END
      END
    ELSE Err(ident)
    END ;
    CheckSym(rparen);
    IF rec = NIL THEN rec:=OPT.NewStr(Comp, Record); rec^.BaseTyp:=NIL END
  END Receiver;
  
  PROCEDURE Extends(x, b: OPT.Struct): BOOLEAN;
  BEGIN
    IF (b^.form = Pointer) & (x^.form = Pointer) THEN b:=b^.BaseTyp; x:=x^.BaseTyp END ;
    IF (b^.comp = Record) & (x^.comp = Record) THEN
      REPEAT x:=x^.BaseTyp UNTIL (x = NIL) OR (x = b)
    END ;
    RETURN x = b
  END Extends;

  PROCEDURE ProcedureDeclaration(VAR x: OPT.Node);
  VAR 
    proc, fwd: OPT.Object;
    name: OPS.Name;
    mode, vis: SHORTINT;
    forward: BOOLEAN;
    sysFlag:INTEGER;

    PROCEDURE GetCode;
    VAR 
      ext: OPT.ConstExt; 
      n: INTEGER; 
      c: LONGINT;
    BEGIN
      ext:=OPT.NewExt(); 
      proc^.conval^.ext:=ext;
      n:=0;
      LOOP
        IF sym = number THEN 
          c:=OPS.intval; 
          INC(n);
          IF n>=OPS.MaxStrLen THEN
            Err(E.CODE_PROC_TOO_LONG);
            c:=1; n:=1;
          ELSIF (c < 0) OR (c > 255) OR (n = OPT.MaxConstLen) THEN
            Err(E.ILLEGAL_CONST_VALUE); 
            c:=1; n:=1;
          END ;
          OPS.Get(sym); ext^[n]:=CHR(c)
        END ;
        IF sym = comma THEN OPS.Get(sym)
        ELSIF sym = number THEN Err(comma)
        ELSE ext^[0]:=CHR(n); EXIT
        END
      END ;
      INCL(proc^.conval^.setval, hasBody)
    END GetCode;

    PROCEDURE GetParams;
    BEGIN
      proc^.vis:=vis; 
      proc^.mode:=mode; 
      proc^.typ:=OPT.notyp;
      proc^.conval:=OPT.NewConst(); 
      proc^.conval^.setval:={};
      IF sym = lparen THEN
        OPS.Get(sym); 
        FormalParameters(proc^.link, proc^.typ)
      END ;
      IF fwd # NIL THEN
        OPB.CheckParameters(proc^.link, fwd^.link, TRUE);
        IF proc^.typ # fwd^.typ THEN Err(E.RESULT_TYPE_MISMATCH) END ;
        IF (proc^.mode = WProc) # (fwd^.mode = WProc) THEN Err(E.SYSFLAG_MISMATCH) END ; (*!*)
        IF (proc^.mode = MODE_CDECLPROC) # (fwd^.mode = MODE_CDECLPROC) THEN Err(E.SYSFLAG_MISMATCH) END ; (* + 26.08.96 *)
        proc:=fwd; OPT.topScope:=fwd^.scope
      END
    END GetParams;

    PROCEDURE Body;
    VAR 
      procdec, statseq: OPT.Node; 
      c: OPM.SourcePosT;
    BEGIN
      c:=OPM.errpos;
      INCL(proc^.conval^.setval, hasBody);
      CheckSym(semicolon); 
      Block(procdec, statseq);
      OPB.Enter(procdec, statseq, proc); 
      x:=procdec;
      (* !!!
      x^.conval:=OPT.NewConst(); 
      x^.conval^.intval:=OPM.LINENUMFACT*c.line+c.column; *)
      x^.txtpos:=c;
      IF sym = ident THEN
        x^.endLine:=OPM.errpos.line;
        IF OPS.name # proc^.name THEN Err(E.IDENT_NO_MATCH) END;
        OPS.Get(sym);
      ELSE 
        Err(ident)
      END
    END Body;

    (* type bound procedure *)
    PROCEDURE TProcDecl;
    VAR 
      baseProc: OPT.Object;
      objTyp, recTyp: OPT.Struct;
      objMode: SHORTINT;
      objVis: SHORTINT; (*!*)
      objName: OPS.Name;
    BEGIN
      OPS.Get(sym); mode:=TProc;
      IF level > 0 THEN Err(E.PROC_LEVEL_0_REQU) END ;
      Receiver(objMode, objVis, objName, objTyp, recTyp);
      IF sym = ident THEN
        name:=OPS.name; CheckMark(vis);
        OPT.FindField(name, recTyp, fwd);
        OPT.FindField(name, recTyp^.BaseTyp, baseProc);
        IF (baseProc # NIL) & (baseProc^.mode # TProc) THEN baseProc:=NIL END ;
        IF fwd = baseProc THEN fwd:=NIL END ;
        IF (fwd # NIL) & (fwd^.mnolev # level) THEN fwd:=NIL END ;
        IF (fwd # NIL) & (fwd^.mode = TProc) & ~(hasBody IN fwd^.conval^.setval) THEN
          (* there exists a corresponding forward declaration *)
          proc:=OPT.NewObj(); proc^.leaf:=TRUE;
          IF fwd^.vis # vis THEN Err(E.FORWARD_DECL_EXPORT_MISMATCH) END
        ELSE
          IF fwd # NIL THEN OPM.CommentedErr(E.MULTIPLY_DEFINED,fwd.name); fwd:=NIL END ;
          OPT.OpenScope(0, NIL); 
          OPT.topScope^.right:=recTyp^.link; 
          OPT.Insert(name, proc);
          recTyp^.link:=OPT.topScope^.right; 
          OPT.CloseScope; 
        END ;
        INC(level); 
        OPT.OpenScope(level, proc);
        OPT.Insert(objName, proc^.link); 
        proc^.link^.mode:=objMode; 
        proc^.link^.typ:=objTyp;
        proc^.link^.vis:=objVis; (*!*)
        GetParams;
        IF baseProc # NIL THEN
          IF (objMode # baseProc^.link^.mode) OR ~Extends(objTyp, baseProc^.link^.typ) THEN Err(E.PARAMETER_MISMATCH) END ;
          OPB.CheckParameters(proc^.link^.link, baseProc^.link^.link, FALSE);
          IF proc^.typ # baseProc^.typ THEN Err(E.RESULT_TYPE_MISMATCH) END ;
          IF (baseProc^.vis = external) & (proc^.vis < external (*!*)) &
            (recTyp^.strobj # NIL) & (recTyp^.strobj^.vis = external) THEN Err(E.OVERRIDING_METHOD_NOT_EXPORTED)
          END ;
          INCL(proc^.conval^.setval, isRedef)
        END ;
        IF ~forward THEN Body END ;
        DEC(level); OPT.CloseScope
      ELSE 
        Err(ident)
      END
    END TProcDecl;
  
  BEGIN 
    proc:=NIL; 
    forward:=FALSE; 
    x:=NIL; 
    mode:=LProc;
    IF (sym # ident) & (sym # lparen) THEN
      IF sym = times THEN  (* mode set later in OPB.CheckAssign *)
        OPS.Get(sym);
      ELSIF sym = arrow THEN 
        forward:=TRUE;
        OPS.Get(sym);
      ELSIF sym = plus THEN 
        mode:=IProc;
        OPS.Get(sym);
      ELSIF sym = minus THEN 
        mode:=CProc;
        OPS.Get(sym);
      ELSIF sym = lbrak THEN 
        CheckSysFlag(sysFlag,0,{OPM.SYSFLAG_APICALL,OPM.SYSFLAG_CDECL});
        IF sysFlag=OPM.SYSFLAG_APICALL THEN
          mode:=WProc;
        ELSIF sysFlag=OPM.SYSFLAG_CDECL THEN
          mode:=MODE_CDECLPROC;
        END;
      ELSE 
        Err(ident);
        OPS.Get(sym);
      END ;
      IF (mode IN {IProc, CProc}) & ~OPT.SYSimported THEN Err(E.SYSTEM_NOT_IMPORTED) END;
    END ;
    IF OPT.defModule & (mode # WProc) THEN Err(E.NOT_WINDOWS) END; (*!*)
    IF sym = lparen THEN 
      TProcDecl;
    ELSIF sym = ident THEN 
      OPT.Find(fwd);
      name:=OPS.name; 
      CheckMark(vis);
      IF (vis >= external (*!*)) & (mode = LProc) THEN 
        (* change+ 20.11.95 Rel. 1.18 no need to declare [WINDOWS] with progmain *)
        (* orig. code: mode:=XProc *)
        IF name=progMainProcName THEN mode:=WProc ELSE mode:=XProc END;
        (* change- *)
      END;
      IF (fwd # NIL) & ((fwd^.mnolev # level) OR (fwd^.mode = SProc)) THEN fwd:=NIL END ;
      IF (fwd # NIL) & (fwd^.mode IN {LProc, XProc, WProc, MODE_CDECLPROC (*!*)}) & ~(hasBody IN fwd^.conval^.setval) THEN
        (* there exists a corresponding forward declaration *)
        proc:=OPT.NewObj(); 
        proc^.leaf:=TRUE;
        IF fwd^.vis # vis THEN Err(E.FORWARD_DECL_EXPORT_MISMATCH) END
      ELSE
        IF fwd # NIL THEN 
          OPM.CommentedErr(E.MULTIPLY_DEFINED,fwd.name); 
          fwd:=NIL;
        END ;
        OPT.Insert(name, proc)
      END ;
      IF (mode # LProc) & (level > 0) THEN Err(E.PROC_LEVEL_0_REQU) END ;
      INC(level); 
      OPT.OpenScope(level, proc);
      proc^.link:=NIL; 
      GetParams;
      IF mode = CProc THEN 
        GetCode
      ELSIF ~forward & ~OPT.defModule (*!*) THEN 
        Body
      END ;
      DEC(level); 
      OPT.CloseScope
    ELSE 
      Err(ident)
    END
  END ProcedureDeclaration;

  PROCEDURE CaseLabelList(VAR lab: OPT.Node; LabelForm: INTEGER; VAR n: INTEGER; VAR tab: CaseTable);
  VAR 
    x, y, lastlab: OPT.Node; 
    i, f: INTEGER; 
    xval, yval: LONGINT;
  BEGIN 
    lab:=NIL; 
    lastlab:=NIL;
    LOOP 
      ConstExpression(x); 
      f:=x^.typ^.form;
      IF f IN intSet + {Char} THEN  
        xval:=x^.conval^.intval
      ELSE 
        Err(E.CASE_LABEL_INADMISSIBLE_TYPE); 
        xval:=1
      END ;
      IF f IN intSet THEN
        IF LabelForm < f THEN Err(E.CASE_LABEL_WRONG_TYPE) END
      ELSIF LabelForm # f THEN Err(E.CASE_LABEL_WRONG_TYPE)
      END ;
      IF sym = upto THEN
        OPS.Get(sym); ConstExpression(y); yval:=y^.conval^.intval;
        IF (y^.typ^.form # f) & ~((f IN intSet) & (y^.typ^.form IN intSet)) THEN Err(E.CASE_LABEL_WRONG_TYPE) END ;
        IF yval < xval THEN Err(E.ILLEGAL_CONST_VALUE); yval:=xval END
      ELSE yval:=xval
      END ;
      x^.conval^.intval2:=yval;
      (*enter label range into ordered table*)  i:=n;
      IF i < OPM.MaxCases THEN
        LOOP
          IF i = 0 THEN EXIT END ;
          IF tab[i-1].low <= yval THEN
            IF tab[i-1].high >= xval THEN Err(E.CASE_LABEL_MULTIPLY_DEFINED) END ;
            EXIT
          END ;
          tab[i]:=tab[i-1]; DEC(i)
        END ;
        tab[i].low:=xval; tab[i].high:=yval; INC(n)
      ELSE Err(E.TOO_MANY_CASES)
      END ;
      OPB.Link(lab, lastlab, x);
      IF sym = comma THEN OPS.Get(sym)
      ELSIF (sym = number) OR (sym = ident) THEN Err(comma)
      ELSE EXIT
      END
    END
  END CaseLabelList;

  PROCEDURE StatSeq(VAR stat: OPT.Node);
  VAR 
    fpar, id, t, obj: OPT.Object; 
    idtyp: OPT.Struct; 
    e: BOOLEAN;
    s, x, y, z, apar, last, lastif: OPT.Node; 
    pos: OPM.SourcePosT;

    PROCEDURE CasePart(VAR x: OPT.Node);
    VAR 
      n: INTEGER; 
      low, high: LONGINT; 
      e: BOOLEAN;
      tab: CaseTable; 
      cases, lab, y, lastcase: OPT.Node; 
    BEGIN
      Expression(x); 
      pos:=OPM.errpos;
      IF (x^.class = Ntype) OR (x^.class = Nproc) THEN 
        Err(E.NO_PROC_ALLOWED)
      ELSIF ~(x^.typ^.form IN {Char..LInt}) THEN 
        Err(E.CASE_TYPE)
      END ;
      CheckSym(of); 
      cases:=NIL; 
      lastcase:=NIL; 
      n:=0;
      LOOP
        IF sym < bar THEN
          CaseLabelList(lab, x^.typ^.form, n, tab);
          CheckSym(colon); 
          StatSeq(y);
          OPB.Construct(Ncasedo, lab, y); 
          OPB.Link(cases, lastcase, lab)
        END ;
        IF sym = bar THEN OPS.Get(sym) ELSE EXIT END
      END ;
      IF n > 0 THEN 
        low:=tab[0].low; 
        high:=tab[n-1].high;
        IF high - low > OPM.MaxCaseRange THEN Err(E.CASE_RANGE_TOO_LARGE) END
      ELSE 
        low:=1; 
        high:=0
      END ;
      e:=sym=else;
      IF e THEN 
        OPS.Get(sym); 
        StatSeq(y);
      ELSE 
        y:=NIL;
      END ;
      OPB.Construct(Ncaselse, cases, y); 
      OPB.Construct(Ncase, x, cases);
      cases^.conval:=OPT.NewConst();
      cases^.conval^.intval:=low; 
      cases^.conval^.intval2:=high;
      IF e THEN cases^.conval^.setval:={1} ELSE cases^.conval^.setval:={} END
    END CasePart;

    PROCEDURE CheckBool(VAR x: OPT.Node);
    BEGIN
      IF (x^.class = Ntype) OR (x^.class = Nproc) THEN 
        Err(E.NO_PROC_ALLOWED); 
        x:=OPB.NewBoolConst(FALSE);
      ELSIF x^.typ^.form # Bool THEN 
        Err(E.BOOLEAN_EXPECTED); 
        x:=OPB.NewBoolConst(FALSE);
      END ;
      pos:=OPM.errpos
    END CheckBool;

  BEGIN 
    stat:=NIL; 
    last:=NIL;
    LOOP 
      x:=NIL;
      INC(nofStat); (*!L*)
      IF sym < ident THEN Err(E.STATEMENT_STARTS_WRONG);
        REPEAT OPS.Get(sym) UNTIL sym>=ident;
      END ;
      IF sym = ident THEN
        qualident(id); 
        x:=OPB.NewLeaf(id); 
        selector(x);
        IF sym = becomes THEN
          OPS.Get(sym); 
          Expression(y); 
          OPB.Assign(x, y)
        ELSIF sym = eql THEN
          Err(becomes); 
          OPS.Get(sym); 
          Expression(y); 
          OPB.Assign(x, y)
        ELSIF (x^.class = Nproc) & (x^.obj^.mode = SProc) THEN
          StandProcCall(x);
          IF (x # NIL) & (x^.typ # OPT.notyp) THEN Err(E.RESULT_IGNORED) END
        ELSE 
          OPB.PrepCall(x, fpar);
          IF sym = lparen THEN
            OPS.Get(sym); 
            ActualParameters(apar, fpar); 
            CheckSym(rparen)
          ELSE 
            apar:=NIL;
            IF fpar # NIL THEN Err(E.FEWER_PARAMS) END
          END ;
          OPB.Call(x, apar, fpar);
          IF x^.typ # OPT.notyp THEN Err(E.RESULT_IGNORED) END ;
          IF level > 0 THEN OPT.topScope^.link^.leaf:=FALSE END
        END ;
        pos:=OPM.errpos
      ELSIF sym = if THEN
        OPS.Get(sym); 
        Expression(x); 
        CheckBool(x); 
        CheckSym(then); 
        StatSeq(y);
        OPB.Construct(Nif, x, y);
        x.txtpos:=pos;
   (*     SetPos(x);  *)
        lastif:=x;
        WHILE sym = elsif DO
          OPS.Get(sym); 
          Expression(y); 
          CheckBool(y); 
          CheckSym(then); 
          StatSeq(z);
          OPB.Construct(Nif, y, z); 
          y.txtpos:=pos;
  (*        SetPos(y);  *)
          OPB.Link(x, lastif, y);
        END ;
        IF sym = else THEN 
          OPS.Get(sym); 
          StatSeq(y)
        ELSE 
          y:=NIL
        END ;
        OPB.Construct(Nifelse, x, y); 
        CheckSym(end); 
        x^.endLine:=OPM.errpos.line;
        OPB.OptIf(x); 
        pos:=OPM.errpos
      ELSIF sym = case THEN
        OPS.Get(sym); 
        CasePart(x); 
        CheckSym(end);
        x.endLine:=OPM.errpos.line;
      ELSIF sym = while THEN
        OPS.Get(sym); 
        Expression(x); 
        CheckBool(x); 
        CheckSym(do); 
        StatSeq(y);
        OPB.Construct(Nwhile, x, y); 
        CheckSym(end);
        x.endLine:=OPM.errpos.line;
      ELSIF sym = repeat THEN
        OPS.Get(sym); 
        StatSeq(x);
        IF sym = until THEN 
          OPS.Get(sym); 
          Expression(y); 
          CheckBool(y)
        ELSE 
          Err(until)
        END ;
        OPB.Construct(Nrepeat, x, y);
        x.endLine:=OPM.errpos.line;
      ELSIF sym = for THEN
        OPS.Get(sym);
        IF sym = ident THEN qualident(id);
          IF ~(id^.typ^.form IN intSet) THEN Err(E.CTRL_VAR_NOT_INT) END ;
          CheckSym(becomes); 
          Expression(y); 
          pos:=OPM.errpos;
          x:=OPB.NewLeaf(id); 
          OPB.Assign(x, y); 
          x.txtpos:=pos;
          OPB.Link(stat, last, x);
          CheckSym(to); 
          Expression(y); 
          pos:=OPM.errpos;
          IF y^.class # Nconst THEN
            OPT.Insert("@@", t); 
            t^.name:="@for"; 
            t^.mode:=MODE_VAR; 
            t^.typ:=y.typ;
            obj:=OPT.topScope^.scope;
            IF obj = NIL THEN 
              OPT.topScope^.scope:=t
            ELSE
              WHILE obj^.link # NIL DO obj:=obj^.link END ;
              obj^.link:=t
            END ;
            x:=OPB.NewLeaf(t); 
            OPB.Assign(x, y); 
            x.txtpos:=pos;
            OPB.Link(stat, last, x);
            y:=OPB.NewLeaf(t);
          END ;
          IF sym = by THEN OPS.Get(sym); ConstExpression(z) ELSE z:=OPB.NewIntConst(1) END ;
          pos:=OPM.errpos; 
          x:=OPB.NewLeaf(id);
          IF z^.conval^.intval > 0 THEN 
            OPB.Op(leq, x, y)
          ELSIF z^.conval^.intval < 0 THEN 
            OPB.Op(geq, x, y)
          ELSE 
            Err(E.ILLEGAL_CONST_VALUE);
            OPB.Op(geq, x, y)
          END ;
          CheckSym(do); 
          StatSeq(s);
          y:=OPB.NewLeaf(id); 
          OPB.StPar1(y, z, incfn); 
          y.txtpos:=pos;
          IF s = NIL THEN 
            s:=y
          ELSE z:=s;
            WHILE z^.link # NIL DO z:=z^.link END ;
            z^.link:=y
          END ;
          CheckSym(end); 
          OPB.Construct(Nwhile, x, s);
          x.endLine:=OPM.errpos.line;
        ELSE 
          Err(ident)
        END
      ELSIF sym = loop THEN
        OPS.Get(sym); 
        INC(LoopLevel); 
        StatSeq(x); 
        DEC(LoopLevel);
        OPB.Construct(Nloop, x, NIL); 
        CheckSym(end); 
        x.endLine:=OPM.errpos.line;
        pos:=OPM.errpos
      ELSIF sym = with THEN
        OPS.Get(sym); 
        idtyp:=NIL; 
        x:=NIL;
        LOOP
          IF sym = ident THEN
            qualident(id); y:=OPB.NewLeaf(id);
            IF (id # NIL) & (id^.typ^.form = Pointer) & ((id^.mode = VarPar) OR ~id^.leaf) THEN
              Err(E.POSSIBLE_SIDE_EFFECT)  (* warning *)
            END ;
            CheckSym(colon);
            IF sym = ident THEN qualident(t);
              IF (t^.mode = MODE_TYPE) OR (t^.mode=MODE_DLLTYPE) THEN
                IF id # NIL THEN
                  idtyp:=id^.typ; 
                  OPB.TypTest(y, t, FALSE); 
                  id^.typ:=t^.typ
                ELSE 
                  Err(E.WITH_CLAUSE_NO_VAR)
                END
              ELSE 
                Err(E.IDENT_NO_TYPE)
              END
            ELSE 
              Err(ident)
            END
          ELSE 
            Err(ident)
          END ;
          pos:=OPM.errpos; 
          CheckSym(do); 
          StatSeq(s); 
          OPB.Construct(Nif, y, s); 
          y.txtpos:=pos;
          IF idtyp # NIL THEN 
            id^.typ:=idtyp; 
            idtyp:=NIL;
          END;
          IF x = NIL THEN 
            x:=y; 
            lastif:=x;
          ELSE 
            OPB.Link(x, lastif, y);
          END ;
          IF sym = bar THEN OPS.Get(sym) ELSE EXIT END
        END;
        e:=sym = else;
        IF e THEN OPS.Get(sym); StatSeq(s) ELSE s:=NIL END ;
        OPB.Construct(Nwith, x, s); 
        CheckSym(end); 
        x.endLine:=OPM.errpos.line;
        IF e THEN x^.subcl:=1 END
      ELSIF sym = exit THEN
        OPS.Get(sym);
        IF LoopLevel = 0 THEN Err(E.EXIT_OUT_OF_LOOP) END ;
        OPB.Construct(Nexit, x, NIL);
        pos:=OPM.errpos
      ELSIF sym = return THEN 
        OPS.Get(sym);
        IF sym < semicolon THEN Expression(x) END ;
        IF level > 0 THEN 
          OPB.Return(x, OPT.topScope^.link)
        ELSE
          OPB.Return(x, NIL) (* not standard Oberon *) 
        END ;
        pos:=OPM.errpos
      END ;
      IF x # NIL THEN 
        x.txtpos:=pos;
        OPB.Link(stat, last, x);
      END ;
      IF sym = semicolon THEN 
        OPS.Get(sym);
      ELSIF (sym <= ident) OR (if <= sym) & (sym <= return) THEN 
        Err(semicolon);
      ELSE EXIT
      END
    END
  END StatSeq;

  PROCEDURE Block(VAR procdec, statseq: OPT.Node);
  VAR 
    typ: OPT.Struct;
    obj, first, last: OPT.Object;
    x, lastdec: OPT.Node;
    i: INTEGER;
  BEGIN 
    first:=NIL; 
    last:=NIL; 
    nofFwdPtr:=0;
    LOOP
      IF sym = const THEN
        OPS.Get(sym);
        WHILE sym = ident DO
          OPT.Insert(OPS.name, obj); 
          CheckMark(obj^.vis);
          obj^.typ:=OPT.sinttyp; 
          obj^.mode:=MODE_VAR;  (* Var to avoid recursive definition *)
          IF sym = eql THEN
            OPS.Get(sym); 
            ConstExpression(x)
          ELSIF sym = becomes THEN
            OPM.CommentedErr(E.EQU_EXPECTED,":="); 
            OPS.Get(sym); 
            ConstExpression(x)
          ELSE 
            Err(E.EQU_EXPECTED2); 
            x:=OPB.NewIntConst(1)
          END ;
          obj^.mode:=MODE_CON; 
          obj^.typ:=x^.typ; 
          obj^.conval:=x^.conval; (* ConstDesc ist not copied *)
          CheckSym(semicolon)
        END
      END ;
      IF sym = type THEN
        OPS.Get(sym);
        WHILE sym = ident DO
          OPT.Insert(OPS.name, obj); 
          obj^.mode:=MODE_TYPE; 
          obj^.typ:=OPT.undftyp;
          CheckMark(obj^.vis);
          IF sym = eql THEN
            OPS.Get(sym); 
            TypeDecl(obj^.typ, obj^.typ)
          ELSIF (sym = becomes) OR (sym = colon) THEN
            IF sym=becomes THEN
              OPM.CommentedErr(E.EQU_EXPECTED,":=");
            ELSE
              OPM.CommentedErr(E.EQU_EXPECTED,",");
            END;
            OPS.Get(sym); 
            TypeDecl(obj^.typ, obj^.typ)
          ELSE 
            Err(E.EQU_EXPECTED2);
          END ;
          IF obj^.typ^.strobj = NIL THEN obj^.typ^.strobj:=obj END ;
          IF obj^.typ^.comp IN {Record, Array, DynArr} THEN
            i:=0;
            WHILE i < nofFwdPtr DO 
              typ:=FwdPtr[i]; 
              INC(i);
              IF typ^.link^.name = obj^.name THEN 
                typ^.BaseTyp:=obj^.typ; 
                typ^.link^.name:="";
              END
            END
          END;
          CheckSym(semicolon);
        END
      END ;
      IF sym = var THEN
        IF OPT.defModule THEN Err(E.NO_VARS_ALLOWED) END; (*!*)
        OPS.Get(sym);
        WHILE sym = ident DO
          LOOP
            IF sym = ident THEN
              OPT.Insert(OPS.name, obj); CheckMark(obj^.vis);
              obj^.mode:=MODE_VAR; 
              obj^.link:=NIL; 
              obj^.leaf:=obj^.vis < external (*!*); 
              obj^.typ:=OPT.undftyp;
              IF first = NIL THEN first:=obj END ;
              IF last = NIL THEN OPT.topScope^.scope:=obj ELSE last^.link:=obj END ;
              last:=obj
            ELSE Err(ident)
            END ;
            IF sym = comma THEN OPS.Get(sym)
            ELSIF sym = ident THEN Err(comma)
            ELSE EXIT
            END
          END ;
          CheckSym(colon); 
          Type(typ, OPT.notyp);
          IF typ^.comp = DynArr THEN 
            typ:=OPT.undftyp; 
            Err(E.OPEN_ARRAY_NOT_ALLOWED);
          END ;
          WHILE first # NIL DO first^.typ:=typ; first:=first^.link END ;
          CheckSym(semicolon)
        END
      END ;
      IF (sym < const) OR (sym > var) THEN EXIT END ;
    END ;
    i:=0;
    WHILE i < nofFwdPtr DO
      IF FwdPtr[i]^.link^.name # "" THEN 
        OPM.Mark(E.FORWARD_REF, 
                 FwdPtr[i]^.txtpos, 
                 FwdPtr[i]^.link^.name); (*!*) 
      END;
      FwdPtr[i]:=NIL;  (* garbage collection *)
      INC(i)
    END ;
    OPT.topScope^.adr:=OPM.LINENUMFACT*OPM.errpos.line+OPM.errpos.column;
    procdec:=NIL; lastdec:=NIL;
    WHILE sym = procedure DO
      OPS.Get(sym); ProcedureDeclaration(x);
      IF x # NIL THEN
        IF lastdec = NIL THEN procdec:=x ELSE lastdec^.link:=x END ;
        lastdec:=x
      END ;
      CheckSym(semicolon)
    END;
    (* change+ 14.11.95 Rel. 1.18 *)
    IF (sym # begin) & (sym # end) THEN Err(E.PROC_BEGIN_OR_END_EXPECTED) END;
    (* change- *)
    IF sym = begin THEN
      IF OPT.defModule THEN Err(E.NO_STATS_ALLOWED) END; (*!*)
      OPS.Get(sym); StatSeq(statseq)
    ELSE statseq:=NIL
    END ;
    IF (level = 0) & (TDinit # NIL) THEN
      lastTDinit^.link:=statseq; statseq:=TDinit
    END ;
    CheckSym(end)
  END Block;

  PROCEDURE Module*(VAR prog: OPT.Node; VAR modName: OPS.Name);
  VAR 
    impName, aliasName: OPS.Name;
    procdec, statseq: OPT.Node;
    srcPos:OPM.SourcePosT;
    (*!L+*)
    maxNofStat: LONGINT;

    PROCEDURE MaxNofStat():LONGINT;
    VAR
      i, d, h: LONGINT;
    BEGIN
      h:=0;
      FOR i:=0 TO 3 DO 
        d:=OPM.data1[i];
        IF (d < 0) OR (32 <= d) THEN 
          d:=0; 
          RETURN -1;
        ELSE 
          h:=h*32+d;
        END;
      END; 
      d:=0;
      IF h < 50 THEN RETURN (h DIV 9) * 100 ELSE RETURN MAX(LONGINT) END;
    END MaxNofStat;
    (*!L-*)
    
  BEGIN
    nofStat:=0; (*!L*)
    maxNofStat:=MaxNofStat(); (*!L*)
    LoopLevel:=0; 
    level:=0;
    OPS.Get(sym);
    IF sym = module THEN 
      OPS.Get(sym); (*!+*)
      OPT.defModule:=FALSE
    ELSIF sym = definition THEN 
      OPS.Get(sym); 
      OPT.defModule:=TRUE
    ELSE 
      Err(E.MODULE_EXPECTED) 
    END ; (*!-*)
    IF sym = ident THEN
      OPM.LogWStr(OPS.name); 
      OPM.LogWLn; (*!*)
      COPY(OPS.name, modName); 
      OPS.Get(sym); 
      CheckSym(semicolon);
      IF sym=import THEN 
        OPS.Get(sym);
        LOOP
          IF sym = ident THEN
            COPY(OPS.name, aliasName); 
            COPY(aliasName, impName); 
            OPS.Get(sym);
            IF sym = becomes THEN 
              OPS.Get(sym);
              IF sym = ident THEN 
                COPY(OPS.name, impName); 
                OPS.Get(sym) 
              ELSE 
                Err(ident)
              END
            END ;
            OPT.Import(aliasName, impName, modName)
          ELSE 
            Err(ident)
          END ;
          IF sym = comma THEN 
            OPS.Get(sym)
          ELSIF sym = ident THEN 
            Err(comma)
          ELSE
            EXIT
          END
        END ;
        CheckSym(semicolon)
      END ;
      IF OPM.noerr THEN 
        TDinit:=NIL; 
        lastTDinit:=NIL; 
        srcPos:=OPM.errpos;
        Block(procdec, statseq); 
        OPB.Enter(procdec, statseq, NIL); 
        prog:=procdec;
        (* !!!
        prog^.conval:=OPT.NewConst(); 
        prog^.conval^.intval:=OPM.LINENUMFACT*srcPos.line+srcPos.column; *)
        prog^.txtpos:=srcPos;
        IF nofStat > maxNofStat THEN prog:=NIL END; (*!L*)
        IF sym = ident THEN
          IF OPS.name # modName THEN Err(E.IDENT_NO_MATCH) END ;
          OPS.Get(sym)
        ELSE 
          Err(ident)
        END ;
        IF sym # period THEN Err(period) END
      END
    ELSE 
      OPM.LogWLn; (*!*) 
      Err(ident)
    END ;
    TDinit:=NIL; 
    lastTDinit:=NIL;
    IF maxNofStat<0 THEN Err(E.INCORRECT_LICENSE) ELSIF nofStat>maxNofStat THEN Err(E.LICENSE_LIMIT) END(*!L*)
  END Module;

END OPP.
