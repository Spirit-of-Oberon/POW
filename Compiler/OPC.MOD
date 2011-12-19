(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPC;                                     (**)
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
(* PURPOSE: Code generator of Oberon2 compiler DLL                            *)
(*                                                                            *)
(******************************************************************************)

  IMPORT
    OPT, OPL, OPM, CB:=OPC_Base, E:=Error, WriteObj, 
    Coff, Debug, OPB, SYSTEM, Reg:=Register;

  CONST
    rtsModName = "RTSOberon";

    (* OPL constants                                                          *)
    constBegin = 10;                    (* [CS:000A] = start of const field   *)

    (* nodes classes                                                          *)
    Nvar = 0; Nvarpar = 1; Nconst = 7; Nproc = 9;

    (*SYSTEM*)
    adr = OPB.adr;
    cc = 25; bit = 26; lsh = 27; rot = 28; val = 29;

    (*SYSTEM function number*)
    SYSTEM_GETFN=OPT.SYSTEM_GETFN;
    SYSTEM_PUTFN=OPT.SYSTEM_PUTFN;
    SYSTEM_GETRFN=OPT.SYSTEM_GETRFN;
    SYSTEM_PUTRFN=OPT.SYSTEM_PUTRFN;
    
    (* symbol values or ops                                                   *)
    eql = 9; neq = 10; lss = 11; leq = 12; gtr = 13; geq = 14;

    false = 0; true = 1; nil = 0;

    indexCheck = CB.indexCheck; overflowCheck = CB.overflowCheck; 
    rangeCheck = CB.rangeCheck; typeCheck     = CB.typeCheck;
    nilCheck   = CB.nilCheck;   newSymFile    = CB.newSymFile;
    pointerInit= CB.pointerInit;

    (* fixup types                                                            *)
    FIXUP_CODE=OPL.FIXUP_CODE;
    FIXUP_ABSCODE=OPL.FIXUP_ABSCODE;
    FIXUP_DATA=OPL.FIXUP_DATA;
    FIXUP_CONST=OPL.FIXUP_CONST;
    FIXUP_MODENTRY=OPL.FIXUP_MODENTRY;
    FIXUP_DLLMODENTRY=OPL.FIXUP_DLLMODENTRY;
    FIXUP_MOD_DESC_OFF=OPL.FIXUP_MOD_DESC_OFF;
    FIXUP_CODE_SECTION=OPL.FIXUP_CODE_SECTION;


    (* 80386 general- and segment registers                                   *)
    EAX    = Reg.EAX; 
    ECX    = Reg.ECX; 
    EDX    = Reg.EDX; 
    EBX    = Reg.EBX; 
    ESP    = Reg.ESP; 
    EBP    = Reg.EBP; 
    ESI    = Reg.ESI; 
    EDI    = Reg.EDI;
    ES     = Reg.ES; 
    CS     = Reg.CS; 
    SS     = Reg.SS; 
    DS     = Reg.DS; 
    FS     = Reg.FS; 
    GS     = Reg.GS; 
    EIP    = Reg.EIP; 
    EFLAGS = Reg.EFLAGS;

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

    (* item modes for 80386 (must not overlap item basemodes,  > 20)          *)
    DArr = OPL.DArr; 
    Coc = OPL.Coc; 
    Stk = OPL.Stk; 
    MODE_FSTK = OPL.MODE_FSTK; 
    MODE_REG = OPL.MODE_REG; 
    MODE_ABS = OPL.MODE_ABS; 
    MODE_REGI = OPL.MODE_REGI;
    MODE_REGX = OPL.MODE_REGX; 
    MODE_INX = OPL.MODE_INX;
    MODE_ABS_RELOC=OPL.MODE_ABS_RELOC; 
    MODE_REGI_RELOC=OPL.MODE_REGI_RELOC; 
    MODE_REGX_RELOC=OPL.MODE_REGX_RELOC; 
    MODE_INX_RELOC=OPL.MODE_INX_RELOC; 

    (* structure forms                                                        *)
    Undef = CB.Undef; 
    Byte = CB.Byte; 
    Bool = CB.Bool; 
    Char = CB.Char; 
    SInt = CB.SInt; 
    Int = CB.Int; 
    LInt = CB.LInt;
    Real = CB.Real; 
    LReal = CB.LReal; 
    Set = CB.Set; 
    String = CB.String; 
    NilTyp = CB.NilTyp; 
    NoTyp = CB.NoTyp;
    Pointer = CB.Pointer; 
    ProcTyp = CB.ProcTyp; 
    Comp = CB.Comp;
    intSet = CB.intSet; 
    realSet = CB.realSet;

    (* composite structure forms                                              *)
    Basic = CB.Basic; 
    Array = CB.Array; 
    DynArr = CB.DynArr; 
    Record = CB.Record;

    (* condition, 80386                                                       *)
    CST = CB.CST; 
    CCL = CB.CCL; 
    EQL = CB.EQL; 
    NEQ = CB.NEQ; 
    LSS = CB.LSS; 
    GEQ = CB.GEQ; 
    LEQ = CB.LEQ; 
    GTR = CB.GTR;
    ULSS = CB.ULSS; 
    UGEQ = CB.UGEQ; 
    ULEQ = CB.ULEQ; 
    UGTR = CB.UGTR; 
    ALWAYS = CB.ALWAYS; 
    NEVER = CB.NEVER;

    progMainProcName = "ProgMain";
    winMainProcName = "WinMain";
    libMainProcName = "DllEntryPoint";
    UpProgMainProcName = "PROGMAIN";
    UpWinMainProcName = "WINMAIN";
    UpLibMainProcName = "DLLENTRYPOINT";

    (* software interrupts, 80386             *)
    rangeTrap        = CB.rangeTrap;
    indexTrap        = CB.indexTrap;
    ovflTrap         = CB.ovflTrap;
    guardTrap        = CB.guardTrap;
    wrongModKeyTrap  = CB.wrongModKeyTrap;
    wrongDefFileTrap = CB.wrongDefFileTrap;
    nilTrap          = CB.nilTrap;



  VAR
    
    boundAdr*: ARRAY 16 OF LONGINT; (*address bounds for conversion checks*)
    relToCoc: ARRAY 15 OF INTEGER;
    moduleKey:LONGINT;
    modInitFlagAdr:LONGINT; (* address of module initialization flag in constant area *)

    (* index in symbol table of runtime system routines                            *)
    rtsBodyInx:LONGINT;
    rtsNewInx:LONGINT;
    rtsSysNewInx:LONGINT;
    rtsInitModuleInx:LONGINT;
    rtsInitDllModuleInx:LONGINT;
    rtsHaltInx:LONGINT;
    rtsDisposeInx:LONGINT;
    rtsLeavingWinMainInx:LONGINT;

    (* function:      generate an error message                               *)
    (* precondition:  n is the error number                                   *)
    (* postcondition: error message has been written to file                  *)
  PROCEDURE Err(code:INTEGER);
  BEGIN
    OPM.Err(code)
  END Err;

(*----------------------------------------------------------------------------*)
  PROCEDURE LeftOperand*(VAR x: OPL.Item; real, common: BOOLEAN);
    (* needed when OPV.DoCommonDESIgn = TRUE, for optimization of:            *)
    (*   des:=des + v; des:=des / v; des:=des DIV v; des:=des MOD v;  *)
    (*   des:=des - v; des:=ASH(des, v); des:=MSK(des, v);              *)
    (*   des:=LSH(des, v); des:=ROT(des, v)                               *)
  END LeftOperand;

(*----------------------------------------------------------------------------*)
  PROCEDURE DescToData*(VAR x: OPL.Item);
    (* not needed in my back-end*)
  END DescToData;


(*=================== E X P O R T E D : G E N E R A L - P R O C E D U R E S ==*)

  PROCEDURE Init*(VAR modName: ARRAY OF CHAR; options: SET; key: LONGINT);
    (* function:      initialization of module                                *)
    (* precondition:  inx = index check for arrays                            *)
    (*                ovf = overflow check for arithmetic                     *)
    (*                ran = range check of data-types                         *)
    (*                typ = type check for record and pointer types           *)
    (* postcondition: module is initialized                                   *)

  BEGIN
    CB.Init(modName = rtsModName,options);
    moduleKey:=key;
    IF CB.ranchk THEN
      OPL.AllocBounds(0, OPM.MaxSet, boundAdr[Set]);
      OPL.AllocBounds(0, 0FFH, boundAdr[Char]);
      OPL.AllocBounds(OPM.MinSInt, OPM.MaxSInt, boundAdr[SInt]);
      OPL.AllocBounds(OPM.MinInt, OPM.MaxInt, boundAdr[Int])
    END;
    OPL.AllocInitFlag(modInitFlagAdr);
    rtsHaltInx:=CB.rtsHaltInx;
    Coff.AddRtsProc(Coff.MODULE_BODY_NAME,rtsBodyInx);
    Coff.AddRtsProc("New",rtsNewInx);
    Coff.AddRtsProc("SysNew",rtsSysNewInx);
    Coff.AddRtsProc("InitModule",rtsInitModuleInx);
    Coff.AddRtsProc("InitDLL",rtsInitDllModuleInx);
    Coff.AddRtsProc("Dispose",rtsDisposeInx);
    Coff.AddRtsProc("LeavingWinMain",rtsLeavingWinMainInx);
  END Init;


  PROCEDURE Field*(VAR x: OPL.Item; offset: LONGINT);
    (* function:      field of a record                                       *)
    (* precondition:  x.mode IN {VarPar, Var, Abs, RegI, RegX, Inx}           *)
    (* postcondition: x.mode IN {Abs, RegI, RegX, Inx}                        *)

  BEGIN
    CB.LoadAdr(x);
    CB.IncAdr(x, offset)
  END Field;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadTypDescAdr(typ: OPT.Struct; VAR y: OPL.Item);
    (* function:      load address of type-descriptor                         *)
    (* precondition:  typ = data type                                         *)
    (* postcondition: y = address of type descriptor                          *)
  VAR
    x:OPL.Item;
  BEGIN
    IF (typ.strobj#NIL) & (typ.strobj.mode=MODE_DLLTYPE) THEN (* type from across DLL boundary ? *)
      x.mode := MODE_ABS_RELOC; 
      x.adr:=2; (* skip first two bytes of entry, which contain opcodes for CALLs *)
      x.reloc:=FIXUP_CONST;
      x.relocInx:=typ^.mno;
      x.seg.reg:=DS;
      Reg.GetGenReg(y.bas);
      OPL.PutORM(4, 08BH, y.bas, x); (* MOV r32, r/m32 *) (* get const section table entry address *)
      y.mode := MODE_REGI; 
      y.seg.reg:=DS; 
      y.disp:=typ^.tdadr;
      OPL.PutORM(4, 08BH, y.bas, y); (* MOV r32, r/m32 *) (* get const section address *)
      y.disp:=0;
(*      y.disp:=0;
      OPL.PutORM(4, 08BH, y.bas, y); (* MOV r32, r/m32 *) (* get const section address *)
      y.disp:=typ^.tdadr; before 12.3.1999 *)
    ELSE
      y.mode:=MODE_ABS_RELOC; 
      y.adr:=typ^.tdadr;
      y.reloc:=FIXUP_CONST;
      y.relocInx:=typ^.mno;
      y.seg.reg:=DS;
      IF (y.relocInx<0) OR (y.relocInx>=OPT.MAXIMPS) THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.LoadTypDescAdr");
      END;
    END;
  END LoadTypDescAdr;

(*----------------------------------------------------------------------------*)
(*  PROCEDURE LoadChangedCStoES(VAR seg: OPL.Register);
    VAR x: OPL.Item;
  BEGIN
    seg.reg:=cs; OPL.PutPushReg(2, seg);
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsChangedCSInx, OPL.pc - 4);
    OPL.GetThisReg(seg, es);
    x.mode:=Reg; OPL.GetThisReg(x.bas, EAX);
    OPL.PutORM(2, 08EH, seg, x); (* MOV Sw,Ew *)
    OPL.ReleaseReg(x.bas);
  END LoadChangedCStoES;
  *)
(*----------------------------------------------------------------------------*)
  PROCEDURE InitTypDesc*(typ: OPT.Struct);
    (* function:      initializes own type descriptor in CS                   *)
    (* precondition:  typ^.comp IN {Record, Array}                            *)
    (*                typ^.mno = 0                                            *)

  VAR 
    x, y(* , h*): OPL.Item; 
(*    hadr: LONGINT;*)

    PROCEDURE InitMTA(obj: OPT.Object);
    BEGIN
      IF obj # NIL THEN
        InitMTA(obj^.left);
        IF obj^.mode = TProc THEN (* !!!! *)
          x.disp:=4*(obj^.adr DIV 10000H);
          OPL.PutOMD(4, 4, 0C7H, 0H, x, obj^.adr MOD 10000H); (* MOV r/m32, imm32 *)
           (* value put into imm32 needs to form a linked list of all references 
              from different method tables to a particular method;
              will be fixed with OPL.FixLinkAbs when the method code is emitted *)
          OPL.DefineFixup(FIXUP_CODE_SECTION, 0, OPL.pc - 4);
          obj^.adr:=(obj^.adr DIV 10000H) * 10000H + OPL.pc - 4;
(*          h.adr:=hadr + 4 * (obj^.adr DIV 10000H);
          OPL.PutOMD(4, 4, 0C7H, 0H, h, 0); (* MOV Ed,Id *)
          OPL.DefineFixup(fixupCodeSeg, 0, OPL.pc - 2);
          OPL.DefineFixup(fixupConstLen, 0, OPL.pc - 4); 
          obj^.adr:=(obj^.adr DIV 10000H) * 10000H + OPL.pc - 4; !C! *)
        END;
        InitMTA(obj^.right);
      END
    END InitMTA;

  BEGIN
    IF typ^.comp = Record THEN
(*      IF changedCSpc = OPL.pc THEN
        OPL.GetThisReg(h.seg, es);
      ELSE
        LoadChangedCStoES(h.seg);
      END; !C! *)
      (* pointers to base-types and methode addresses  from base-types        *)
(*      IF typ^.BaseTyp # NIL THEN
        LoadTypDescAdr(typ, x); x.seg:=h.seg;
        LoadTypDescAdr(typ^.BaseTyp, y);
        CB.MoveBlockS(x, y, 4 * (typ^.BaseTyp^.n + OPL.maxRecordExt));
        OPL.Release(y)
      END;
      
      (* fixup cs for pointer to name *)
      h.mode:=MODE_ABS; h.adr:=typ^.tdadr - 6; y.seg.reg:=cs;
      OPL.PutORM(2, 08CH, y.seg, h); (* MOV Ew,Sw *) (* segment *)

      (* pointer to itselfe                                                   *)
      h.mode:=MODE_ABS; h.adr:=typ^.tdadr + 4 * typ^.extlev;
      OPL.PutOMD(4, 4, 0C7H, 0H, h, typ^.tdadr); (* MOV Ed,Id *)
      OPL.DefineFixup(fixupCodeSeg, typ^.mno, OPL.pc - 2);

      (* fixup cs for method addresses *)
      hadr:=typ^.tdadr + 4 * OPL.maxRecordExt;
      InitMTA(typ^.link);

      IF typ^.BaseTyp # NIL THEN OPL.Release(x)
      ELSE OPL.ReleaseReg(h.seg)
      END; !C! *)

      IF typ^.BaseTyp # NIL THEN
        (* code to copy pointers to base-types into type descriptor    *)
        LoadTypDescAdr(typ, x); 
        LoadTypDescAdr(typ^.BaseTyp, y);
        CB.MoveBlockS(x, y, 4 * typ^.extlev);
        OPL.Release(x);
        OPL.Release(y);
        (* code to copy pointers to method addresses from base-types into type descriptor *)
        LoadTypDescAdr(typ, x);
        INC(x.adr,4*OPL.maxRecordExt);
        LoadTypDescAdr(typ^.BaseTyp, y);
        INC(y.adr,4*OPL.maxRecordExt);
        CB.MoveBlockS(x, y, 4 * typ^.BaseTyp^.n);
        OPL.Release(x);
        OPL.Release(y) 
      END;
      
      (* code to initialize method addresses in type descriptor *)
      LoadTypDescAdr(typ, x);
      INC(x.adr,4*OPL.maxRecordExt);
      CB.LoadAdr(x);
      CB.AdrToRegI(x);
(*      x.mode:=RegX;
      x.adr:=2; (* scale factor *)
      OPL.GetGenReg(x.inx);*)
      InitMTA(typ^.link);

      OPL.Release(x);
    ELSE                                (* no typdescriptors for array        *)
    END;
  END InitTypDesc;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadMTA*(VAR rec: OPL.Item; superType:OPT.Struct; VAR proc: OPL.Item);    
    (* function:      load methode address                                      *)
    (* precondition:  rec = type-tag of actual parameter = receiver             *)
    (*                superType = NIL or type of super class which is to be called  *)
    (*                proc.mode = TProc                                         *)
    (* postcondition: proc = location of procedure address to be called         *)
 VAR 
    typ: OPT.Struct;
(*    h:OPL.Item;*)
  BEGIN
    IF superType#NIL THEN
(*      IF rec.typ^.form = Pointer THEN 
        typ:=rec.typ^.BaseTyp^.BaseTyp;
      ELSE 
        typ:=rec.typ^.BaseTyp;
      END; *)
      OPL.Release(rec);
      LoadTypDescAdr(superType, rec) (* pointer to type-descriptor *)
(*    ELSIF rec.typ^.form = Pointer THEN
      CB.DeRef(rec);           (* pointer to object on heap *)
      CB.IncAdr(rec, -4);      (* pointer to type-tag *) 
      CB.DeRef(rec)            (* pointer to type-descriptor *)
    ELSIF deref THEN
      CB.IncAdr(rec, -4);      (* pointer to type-tag *)
      CB.DeRef(rec)            (* pointer to type-descriptor *)
    ELSIF rec.mode = VarPar THEN
      CB.LoadBaseAdr(rec);     (* pointer to type-tag *)
      CB.DeRef(rec)            (* pointer to type-descriptor *)
    ELSE
      LoadTypDescAdr(rec.typ, h);    (* pointer to type-descriptor *)
      OPL.Release(rec);
      rec:=h; *)
    END;
    rec.typ:=OPT.linttyp;
    IF proc.adr DIV 10000H = -1 THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.LoadMTA");
    ELSE
      CB.IncAdr(rec, 4 * ((proc.adr DIV 10000H) + OPL.maxRecordExt));
    END;
    OPL.Release(proc);
    proc:=rec;
  END LoadMTA;

(*===================================== mono operations ======================*)

  PROCEDURE SetElem*(VAR x: OPL.Item);
    (* function:      returns a set in which the element 'x' is set           *)
    (* precondition:  x = element to be set                                   *)
    (* postcondition: x = set, with element 'x' set                           *)

  VAR 
    y: OPL.Item;
  BEGIN
    IF x.mode = MODE_CON THEN
      Reg.GetGenReg(x.bas); x.mode:=MODE_REG;
      CB.ClearReg(x.bas);
      OPL.PutOMD(OPM.SetSize, 1, 0FBAH, 5H, x, x.adr) (* BTS Ev,Ib *)
    ELSE
      CB.ValToReg(x);
      CB.CheckRange(x.bas, boundAdr[Set]);
      Reg.GetGenReg(y.bas); y.mode:=MODE_REG;
      CB.ClearReg(y.bas);
      OPL.PutORM(OPM.SetSize, 0FABH, x.bas, y); (* BTS Ev,Gv *)
      Reg.ReleaseReg(x.bas);
      x.bas:=y.bas
    END
  END SetElem;

(*----------------------------------------------------------------------------*)
  PROCEDURE SetRange*(VAR x, y, z: OPL.Item);
    (* function:      returns set 'x' in which elements 'y'..'z' are set      *)
    (* precondition:  y..z = range of elements to be set                      *)
    (* postcondition: x:={y..z}                                             *)

    VAR L1, L2: OPL.Label;
  BEGIN
    x.mode:=MODE_REG; Reg.GetGenReg(x.bas);
    CB.ClearReg(x.bas);
    CB.ValToReg(y); CB.CheckRange(y.bas, boundAdr[Set]);
    CB.ValToReg(z); CB.CheckRange(z.bas, boundAdr[Set]);
    L1:=0; L2:=OPL.pc;
    OPL.PutORM(4, 039H, y.bas, z); (* CMP Ed,Gd *)
    OPL.PutJmpCF(LSS, L1);
    OPL.PutORM(OPM.SetSize, 0FABH, y.bas, x); (* BTS Ev,Gv *)
    OPL.PutOM(4, 0FFH, 0H, y); (* INC Ed *)
    OPL.PutJmpB(L2);
    OPL.FixLink(L1)
  END SetRange;

(*----------------------------------------------------------------------------*)
  PROCEDURE Include*(VAR x, y: OPL.Item; exclude: BOOLEAN);
    (* function:      include or exclude element 'x' in set 'y'               *)
    (* precondition:  x = set                                                 *)
    (*                y = element to be included/excluded                     *)
    (*                IF exclude THEN exclude ELSE include END element        *)
    (* postcondition: IF exclude THEN x:=x - {y} ELSE x:=x + {y} END      *)

  BEGIN
    CB.LoadAdr(x);
    IF y.mode = MODE_CON THEN
      IF exclude THEN 
        OPL.PutOMD(OPM.SetSize, 1, 0FBAH, 6H, x, y.adr) (* BTR Ev,Ib *)
      ELSE 
        OPL.PutOMD(OPM.SetSize, 1, 0FBAH, 5H, x, y.adr) (* BTS Ev,Ib *)
      END
    ELSE
      CB.ValToReg(y);
      CB.CheckRange(y.bas, boundAdr[Set]);
      IF exclude THEN OPL.PutORM(OPM.SetSize, 0FB3H, y.bas, x) (* BTR Ev,Gv *)
      ELSE OPL.PutORM(OPM.SetSize, 0FABH, y.bas, x) (* BTS Ev,Gv *)
      END
    END
  END Include;

(*----------------------------------------------------------------------------*)
  PROCEDURE Neg*(VAR x: OPL.Item);
    (* function:      returns negated value of x                              *)
    (* precondition:  x.typ^.form IN {Set, intSet, realSet}                   *)
    (* postcondition: x:=-x                                                 *)

    VAR f: INTEGER;
  BEGIN
    f:=x.typ^.form;
    IF f = Set THEN
      CB.ValToReg(x);
      OPL.PutOM(OPM.SetSize, 0F7H, 2H, x) (* NOT Ev *)
    ELSIF f IN intSet THEN
      CB.ValToReg(x);
      OPL.PutOM(4, 0F7H, 3H, x); (* NEG Ed *)
      CB.CheckOvfl;
    ELSE                                (* f IN realSet                       *)
      CB.ValToFStk(x);
      OPL.PutO(0, 0D9E0H) (* FCHS *)
    END
  END Neg;

(*----------------------------------------------------------------------------*)
  PROCEDURE Not*(VAR x: OPL.Item);
    (* function:      returns inverted value of x                             *)
    (* precondition:  x = condition code or boolean value                     *)
    (* postcondition: x:=~x                                                 *)

  VAR 
    h: LONGINT;
  BEGIN
    IF x.mode = Coc THEN
      x.seg.reg:=CB.InvertedCoc(x.seg.reg);
      h:=x.adr; x.adr:=x.disp; x.disp:=h (* exchange Tjmp and Fjmp *)
    ELSE 
      CB.ValToReg(x);
      OPL.PutOMD(4, 4, 081H, 6H, x, true) (* XOR Ed,Id *)
    END
  END Not;

(*----------------------------------------------------------------------------*)
  PROCEDURE AbsVal*(VAR x: OPL.Item);
    (* function:      returns the absolute value of x                         *)
    (* precondition:  x.typ^.form IN {intSet, realSet}                        *)
    (* postcondition: x:=|x|                                                *)

  VAR 
    L1: OPL.Label; 
    f: INTEGER;
  BEGIN
    f:=x.typ^.form;
    IF f IN intSet THEN
      CB.ValToReg(x);
      OPL.PutORM(4, 85H, x.bas, x); (* TEST Ed,Gd *)
      L1:=0;
      OPL.PutJmpCF(GEQ, L1);
      OPL.PutOM(4, 0F7H, 3H, x); (* NEG Ed *)
      CB.CheckOvfl;
      OPL.FixLink(L1)
    ELSE                                (* f IN realSet                       *)
      CB.ValToFStk(x);
      OPL.PutO(0, 0D9E1H) (* FABS *)
    END
  END AbsVal;

(*----------------------------------------------------------------------------*)
  PROCEDURE Cap*(VAR x: OPL.Item);
    (* function:      returns the capital value of lowercase characters       *)
    (* precondition:                                                          *)
    (* postcondition: x:=CAP(x)                                             *)

  VAR 
    L1: OPL.Label;
  BEGIN
    L1:=0;
    CB.ValToByteReg(x);
    OPL.PutOMD(1, 1, 080H, 7H, x, ORD("a")); (* CMP Eb,Ib *)
    OPL.PutJmpCF(LSS, L1);
    OPL.PutOMD(1, 1, 080H, 7H, x, ORD("z")); (* CMP Eb,Ib *)
    OPL.PutJmpCF(GTR, L1);
    OPL.PutOMD(1, 1, 080H, 5H, x, ORD("a")-ORD("A")); (* SUB Eb,Ib *)
    OPL.FixLink(L1)
  END Cap;

(*----------------------------------------------------------------------------*)
  PROCEDURE Odd*(VAR x: OPL.Item);
    (* function:      test if value of x is odd or even                       *)
    (* precondition:  x = value to be tested                                  *)
    (* postcondition: x:=ODD(x)                                             *)

  BEGIN
    CB.LoadAdr(x);
    IF x.mode = MODE_REG THEN OPL.PutOMD(4, 4, 0F7H, 0H, x, 1) (* TEST Ib/Id Ed *)
    ELSE OPL.PutOMD(1, 1, 0F6H, 0H, x, 1) (* TEST Ib/I? Eb *)
    END;
    OPL.Release(x);
    CB.SetCoc(x, NEQ)
  END Odd;

(*----------------------------------------------------------------------------*)
  PROCEDURE Convert*(VAR x: OPL.Item; from, to: INTEGER);
    (* function:      convertes the value of 'x' from type 'from' to type 'to'*)
    (* precondition:  x = value to be converted                               *)
    (*                from, to = datatypes                                    *)
    (* postcondition: x.mode IN {FStk, Reg}                                   *)

  BEGIN
    IF to IN realSet THEN CB.ValToFStk(x) ELSE CB.ValToReg(x) END
  END Convert;

(*----------------------------------------------------------------------------*)
  PROCEDURE TypTest*(VAR x0: OPL.Item; testtyp: OPT.Struct; guard,equal: BOOLEAN);
    (* function:      cenerate code for type test (is 'x' of type 'testtyp')  *)
    (* precondition:  x0.mode IN {Var, VarPar, RegI, RegX, Abs, ... }          *)
    (*                x0.typ IN {Pointer to Record, Record}                    *)
    (*                testtyp: test type                                      *)
    (*                guard = type guard                                      *)
    (*                equal = 'x0' must have exactly type 'testtyp' (not extension)*)
    (*                (guard,equal) IN { (T,T), (T,F), (F,F) }                *)
    (* postcondition: 'x0' is unchanged if 'guard' = TRUE                                      *)

  VAR 
    h, x, tagItem: OPL.Item; 
    L1: OPL.Label;
  BEGIN
    IF CB.typchk OR ~guard THEN
      OPL.CopyItem(x0, x);
      IF guard & equal THEN
        IF x.mode = VarPar THEN  (* VarPar                             *)
          CB.LoadBaseAdr(x)                (* pointer to type-tag                *)
        ELSE                            (* Pointer to Record                  *)
          CB.IncAdr(x, -4)                 (* pointer to type-tag                *)
        END;
        LoadTypDescAdr(testtyp,tagItem);
        CB.CmpAdr(x,tagItem);
        OPL.Release(tagItem);
(* !C!        OPL.PutOMD(4, 4, 081H, 7H,  x, testtyp^.tdadr); (* CMP Ed,Id *)
(*        OPL.DefineFixup(fixupCodeSeg, testtyp^.mno, OPL.pc - 2); !C! *) 
        OPL.DefineFixup(FIXUP_CONST, (* ??? -*)testtyp^.mno, OPL.pc - 4); *)
        L1:=0;
        OPL.PutJmpCF(EQL, L1);
        CB.Trap(guardTrap);
        OPL.FixLink(L1)
      ELSE                              (* equal = FALSE                      *)
        IF testtyp^.comp = Record THEN  (* VarPar                             *)
          CB.LoadBaseAdr(x);               (* pointer to type-tag                *)
          CB.DeRef(x);                     (* pointer to type-descriptor         *)
        ELSE                            (* Pointer to Record                  *)
          testtyp:=testtyp^.BaseTyp;
          CB.DeRef(x);                     (* pointer to object                  *)
          CB.IncAdr(x, -4);                (* pointer to type-tag of object      *)
          CB.DeRef(x)                      (* pointer to type-descriptor of object*)
        END;
        CB.IncAdr(x, 4 * testtyp^.extlev);
        LoadTypDescAdr(testtyp,tagItem);
        CB.CmpAdr(x,tagItem);
        OPL.Release(tagItem);
(* !C!        OPL.PutOMD(4, 4, 081H, 7H,  x, testtyp^.tdadr); (* CMP Ed,Id *)
(*        OPL.DefineFixup(fixupCodeSeg, testtyp^.mno, OPL.pc - 2); !C! *)
        OPL.DefineFixup(FIXUP_CONST, (* ??? -*)testtyp^.mno, OPL.pc - 4); *)
        IF guard THEN
          L1:=0;
          OPL.PutJmpCF(EQL, L1);
          CB.Trap(guardTrap);
          OPL.FixLink(L1)
        ELSE
          OPL.Release(x0);
          CB.SetCoc(x0, EQL);
        END
      END;
      OPL.Release(x);
    END
  END TypTest;

(*===================================== double operations ====================*)

  PROCEDURE Add*(VAR x, y: OPL.Item; floating: BOOLEAN);
    (* function:      computes the addition of 'x' and 'y'                    *)
    (* precondition:  x, y = values to be added                               *)
    (*                IF floating THEN floating point ELSE integer END addition*)
    (* postcondition: x:=x + y                                              *)

  VAR 
    h: OPL.Item;
  BEGIN
    IF floating THEN
      CB.ValToFStk(x); 
      CB.ValToFStk(y); 
      Reg.DecFSP; 
      OPL.PutO(0, 0DEC1H) (* FADDP ST(1),ST *)
    ELSE
      IF x.mode = MODE_CON THEN h:=x; x:=y; y:=h END;
      CB.ValToReg(x);
      IF y.mode = MODE_CON THEN
        IF y.adr = 1 THEN OPL.PutOM(4, 0FFH, 0H, x) (* INC Ed *)
        ELSE OPL.PutOMD(4, 4, 081H, 0H, x, y.adr) (* ADD Ed,Id *)
        END
      ELSE
        IF y.typ^.form = LInt THEN CB.LoadAdr(y) ELSE CB.ValToReg(y) END;
        OPL.PutORM(4, 03H, x.bas, y) (* ADD Gd,Ed *)
      END;
      CB.CheckOvfl;
    END;
  END Add;

(*----------------------------------------------------------------------------*)
  PROCEDURE Sub*(VAR x, y: OPL.Item; floating: BOOLEAN);
    (* function:      computes the subtraction of 'y' from 'x'                *)
    (* precondition:  x, y = values                                           *)
    (*                IF floating THEN floating point ELSE integer END        *)
    (*                subtraction                                             *)
    (* postcondition: x:=x - y                                              *)

  VAR 
    reverse: BOOLEAN;
  BEGIN
    IF floating THEN
      reverse:=(y.mode = MODE_FSTK) & (x.mode # MODE_FSTK);
      CB.ValToFStk(x); CB.ValToFStk(y);
      IF reverse THEN Reg.DecFSP; OPL.PutO(0, 0DEE1H) (* FSUBRP ST(1),ST *)
      ELSE Reg.DecFSP; OPL.PutO(0, 0DEE9H) (* FSUBP ST(1),ST *)
      END
    ELSE
      CB.ValToReg(x);
      IF y.mode = MODE_CON THEN
        IF y.adr = 1 THEN OPL.PutOM(4, 0FFH, 1H, x) (* DEC Ed *)
        ELSE OPL.PutOMD(4, 4, 081H, 5H, x, y.adr) (* SUB Ed,Id *)
        END
      ELSE
        IF y.typ^.form = LInt THEN CB.LoadAdr(y) ELSE CB.ValToReg(y) END;
        OPL.PutORM(4, 02BH, x.bas, y) (* SUB Gd,Ed *)
      END;
      CB.CheckOvfl;
    END;
  END Sub;

(*----------------------------------------------------------------------------*)
  PROCEDURE Increment*(VAR x, y: OPL.Item; decrement: BOOLEAN);
    (* function:      increments or decrements 'x' by value of 'y'            *)
    (* precondition:  x = variable to be changed                              *)
    (*                y = value to be added or subtracted                     *)
    (* postcondition: IF decrement THEN x:=x - y ELSE x:=x + y END        *)

  VAR 
    s: LONGINT;
  BEGIN
    CB.LoadAdr(x);
    s:=x.typ^.size;
    IF (s = 1) & (x.mode = MODE_REG) THEN Reg.MoveToByteReg(x.bas) END;
    IF decrement THEN
      IF y.mode = MODE_CON THEN
        IF y.adr = 1 THEN
          IF s = 1 THEN OPL.PutOM(1, 0FEH, 1H, x) (* DEC Eb *)
          ELSIF s = 2 THEN OPL.PutOM(2, 0FFH, 1H, x) (* DEC Ew *)
          ELSE OPL.PutOM(4, 0FFH, 1H, x) (* DEC Ed *)
          END
        ELSE
          IF s = 1 THEN OPL.PutOMD(1, 1, 080H, 5H, x, y.adr) (* SUB Eb,Ib *)
          ELSIF s = 2 THEN OPL.PutOMD(2, 2, 081H, 5H, x, y.adr) (* SUB Ew,Iw *)
          ELSE OPL.PutOMD(4, 4, 081H, 5H, x, y.adr) (* SUB Ed,Id *)
          END
        END
      ELSE
        CB.ValToByteReg(y);
        IF s = 1 THEN OPL.PutORM(1, 028H, y.bas, x) (* SUB Eb,Gb *)
        ELSIF s = 2 THEN OPL.PutORM(2, 029H, y.bas, x) (* SUB Ew,Gw *)
        ELSE OPL.PutORM(4, 029H, y.bas, x) (* SUB Ed,Gd *)
        END
      END
    ELSE
      IF y.mode = MODE_CON THEN
        IF y.adr = 1 THEN
          IF s = 1 THEN OPL.PutOM(1, 0FEH, 0H, x) (* INC Eb *)
          ELSIF s = 2 THEN OPL.PutOM(2, 0FFH, 0H, x) (* INC Ew *)
          ELSE OPL.PutOM(4, 0FFH, 0H, x) (* INC Ed *)
          END
        ELSE
          IF s = 1 THEN OPL.PutOMD(1, 1, 080H, 0H, x, y.adr) (* ADD Eb,Ib *)
          ELSIF s = 2 THEN OPL.PutOMD(2, 2, 081H, 0H, x, y.adr) (* ADD Ew,Iw *)
          ELSE OPL.PutOMD(4, 4, 081H, 0H, x, y.adr) (* ADD Ed,Id *)
          END
        END
      ELSE
        CB.ValToByteReg(y);
        IF s = 1 THEN OPL.PutORM(1, 00H, y.bas, x) (* ADD Eb,Gb *)
        ELSIF s = 2 THEN OPL.PutORM(2, 01H, y.bas, x) (* ADD Ew,Gw *)
        ELSE OPL.PutORM(4, 01H, y.bas, x) (* ADD Ed,Gd *)
        END
      END
    END;
    CB.CheckOvfl;
  END Increment;

(*----------------------------------------------------------------------------*)
  PROCEDURE Mul*(VAR x, y: OPL.Item; floating: BOOLEAN);
    (* function:      computes the multiplication of 'y' with 'x'             *)
    (* precondition:  x, y = values                                           *)
    (*                IF floating THEN floating point ELSE integer END        *)
    (*                multiplication                                          *)
    (* postcondition: x:=x * y                                              *)

  VAR 
    h: OPL.Item;
  BEGIN
    IF floating THEN
      CB.ValToFStk(x); CB.ValToFStk(y);
      Reg.DecFSP; OPL.PutO(0, 0DEC9H) (* FMULP ST(1),ST *)
    ELSE
      IF x.mode = MODE_CON THEN h:=x; x:=y; y:=h END;
      CB.ValToReg(x);
      IF y.mode # MODE_CON THEN
        IF y.typ^.form = LInt THEN CB.LoadAdr(y) ELSE CB.ValToReg(y) END;
        OPL.PutORM(4, 0FAFH, x.bas, y) (* IMUL Gd,Ed *)
      ELSIF y.adr # 1 THEN (* y.mode = Con *)
        OPL.PutORMD(4, 4, 069H, x.bas, x, y.adr) (* IMUL Gd,Ed,Id *)
      END;
      CB.CheckOvfl;
    END;
  END Mul;

(*----------------------------------------------------------------------------*)
  PROCEDURE FloatDiv*(VAR x, y: OPL.Item);
    (* function:      computes the division of 'x' by 'y'                     *)
    (* precondition:  x, y = values                                           *)
    (*                IF floating THEN floating point ELSE integer END        *)
    (*                division                                                *)
    (* postcondition: x:=x / y                                              *)

  VAR 
    reverse: BOOLEAN;
  BEGIN
    reverse:=(y.mode = MODE_FSTK) & (x.mode # MODE_FSTK);
    CB.ValToFStk(x); CB.ValToFStk(y);
    IF reverse THEN Reg.DecFSP; OPL.PutO(0, 0DEF1H) (* FDIVRP ST(1),ST *)
    ELSE Reg.DecFSP; OPL.PutO(0, 0DEF9H) (* FDIVP ST(1),ST *)
    END
  END FloatDiv;

(*----------------------------------------------------------------------------*)
  PROCEDURE DivMod*(VAR x, y: OPL.Item; div: BOOLEAN);
    (* function:      computes the division of 'x' by 'y' or the modulus of 'x' in 'y'   *)
    (* precondition:  x, y = values                                           *)
    (*                        div = division = not modulus *)
    (* postcondition: IF div THEN x:=x DIV y ELSE x:=x MOD y END *)

  VAR 
    regD: OPL.Item; 
    L1, L2: OPL.Label;
  BEGIN
    L1:=0;
    L2:=0;
    CB.ValToThisReg(x, EAX);
    regD.mode:=MODE_REG; Reg.GetThisReg(regD.bas, EDX);
    IF (y.mode = MODE_CON) OR (y.typ^.form # LInt) THEN 
      CB.ValToReg(y);
    ELSE 
      CB.LoadAdr(y);
    END;
    OPL.PutORM(4, 08BH, regD.bas, x); (* MOV Gd,Ed *)
    OPL.PutORM(4, 033H, regD.bas, y); (* XOR Gd,Ed *)
    OPL.PutJmpCF(GEQ, L1);
    OPL.PutO(4, 099H); (* CWD/CDQ *)
    OPL.PutOM(4, 0F7H, 7H, y); (* IDIV AL/eAX Ed *)
    OPL.PutORM(4, 85H, regD.bas, regD); (* TEST Ed,Gd *)
    OPL.PutJmpCF(EQL, L2);
    IF div THEN OPL.PutOM(4, 0FFH, 1H, x) (* DEC Ed *)
    ELSE OPL.PutORM(4, 03H, regD.bas, y) (* ADD Gd,Ed *)
    END;
    OPL.PutJmpF(L2);
    OPL.FixLink(L1);
    OPL.PutO(4, 099H); (* CWD/CDQ *)
    OPL.PutOM(4, 0F7H, 7H, y); (* IDIV AL/eAX Ed *)
    OPL.FixLink(L2);
    IF div THEN (* result is in EAX register (x DIV y) *)
      Reg.ReleaseReg(regD.bas)
    ELSE (* result is in EDX register (x MOD y) *)
      Reg.ReleaseReg(x.bas);
      x.bas:=regD.bas;
    END;
    Reg.MoveToByteReg(x.bas)
  END DivMod;

(*----------------------------------------------------------------------------*)
  PROCEDURE In*(VAR x, y: OPL.Item);
    (* function:      returns the contition if element 'x' is in set 'y'      *)
    (* precondition:  x = element number, y = set                             *)
    (* postcondition: x:=x IN y                                             *)

  BEGIN
    IF y.mode = MODE_CON THEN CB.ValToReg(y) ELSE CB.LoadAdr(y) END;
    IF x.mode = MODE_CON THEN
      OPL.PutOMD(OPM.SetSize, 1, 0FBAH, 4H, y, x.adr) (* BT Ev,Ib *)
    ELSE
      CB.ValToReg(x);
      CB.CheckRange(x.bas, boundAdr[Set]);
      OPL.PutORM(OPM.SetSize, 0FA3H, x.bas, y); (* BT Ev,Gv *)
      OPL.Release(x)
    END;
    CB.SetCoc(x, CST)
  END In;

(*----------------------------------------------------------------------------*)
  PROCEDURE SetUnion*(VAR x, y: OPL.Item);
    (* function:      computes the union of the sets 'x' and 'y'              *)
    (* precondition:  x, y = sets                                             *)
    (* postcondition: x:=x OR y                                             *)

  BEGIN
    CB.ValToReg(x);
    IF y.mode = MODE_CON THEN
      OPL.PutOMD(OPM.SetSize, OPM.SetSize, 081H, 1H, x, y.adr) (* OR Ev,Iv *)
    ELSE
      CB.LoadAdr(y);
      OPL.PutORM(OPM.SetSize, 0BH, x.bas, y) (* OR Gv,Ev *)
    END
  END SetUnion;

(*----------------------------------------------------------------------------*)
  PROCEDURE SetDiff*(VAR x, y: OPL.Item);
    (* function:      computes the difference of the sets 'x' and 'y'         *)
    (* precondition:  x, y = sets                                             *)
    (* postcondition: x:=x & ~y                                             *)

  VAR 
    i: LONGINT;
  BEGIN
    CB.ValToReg(x);
    IF y.mode = MODE_CON THEN
      IF y.adr < 0 THEN i:=-(y.adr + 1) ELSE i:=(-y.adr) - 1 END;
      OPL.PutOMD(OPM.SetSize, OPM.SetSize, 081H, 4H, x, i) (* AND Ev,Iv *)
    ELSE
      CB.ValToReg(y);
      OPL.PutOM(OPM.SetSize, 0F7H, 2H, y); (* NOT Ev *)
      OPL.PutORM(OPM.SetSize, 023H, x.bas, y); (* AND Gv,Ev *)
    END
  END SetDiff;

(*----------------------------------------------------------------------------*)
  PROCEDURE SetInter*(VAR x, y: OPL.Item);
    (* function:      computes the intersection of the sets 'x' and 'y'       *)
    (* precondition:  x, y = sets                                             *)
    (* postcondition: x:=x & y                                              *)

  BEGIN
    CB.ValToReg(x);
    IF y.mode = MODE_CON THEN
      OPL.PutOMD(OPM.SetSize, OPM.SetSize, 081H, 4H, x, y.adr) (* AND Ev,Iv *)
    ELSE
      CB.LoadAdr(y);
      OPL.PutORM(OPM.SetSize, 023H, x.bas, y) (* AND Gv,Ev *)
    END
  END SetInter;

(*----------------------------------------------------------------------------*)
  PROCEDURE SetSymmDiff*(VAR x, y: OPL.Item);
    (* function:      computes the symmetric difference of the sets 'x' and 'y'*)
    (* precondition:  x, y = sets                                             *)
    (* postcondition: x:=x XOR y                                            *)

  BEGIN
    CB.ValToReg(x);
    IF y.mode = MODE_CON THEN
      OPL.PutOMD(OPM.SetSize, OPM.SetSize, 081H, 6H, x, y.adr) (* XOR Ev,Iv *)
    ELSE
      CB.LoadAdr(y);
      OPL.PutORM(OPM.SetSize, 033H, x.bas, y) (* XOR Gv,Ev *)
    END
  END SetSymmDiff;

(*----------------------------------------------------------------------------*)
  PROCEDURE Msk*(VAR x, y: OPL.Item);
    (* function:      resets in 'x' all the bits which are set in 'y'         *)
    (* precondition:  y.mode = Con, x = value                                 *)
    (* postcondition: x:=x & ~y                                             *)

  VAR 
    i: LONGINT;
  BEGIN
    CB.ValToReg(x);
    IF y.adr < 0 THEN i:=-(y.adr + 1) ELSE i:=(-y.adr) - 1 END;
    OPL.PutOMD(4, 4, 081H, 4H, x, i) (* AND Ed,Id *)
  END Msk;

(*----------------------------------------------------------------------------*)
  PROCEDURE Ash*(VAR x, y: OPL.Item);
    (* function:      computes the arithemetic shift of 'x' by 'y' positions  *)
    (* precondition:  x, y = values                                           *)
    (* postcondition: x:=x * 2^y                                            *)

  VAR 
    L1, L2: OPL.Label;
  BEGIN
    CB.ValToReg(x);
    IF y.mode = MODE_CON THEN
      IF y.adr < 0 THEN
        OPL.PutOMD(4, 1, 0C1H, 7H, x, -y.adr) (* SAR Ed,Ib *)
      ELSIF y.adr > 0 THEN
        OPL.PutOMD(4, 1, 0C1H, 4H, x, y.adr); (* SHL Ed,Ib *)
        CB.CheckOvfl;
      END
    ELSE
      CB.ValToThisReg(y, ECX);
      OPL.PutORM(4, 085H, y.bas, y); (* TEST Ed,Gd *)
      L1:=0; L2:=0;
      OPL.PutJmpCF(EQL, L2);
      OPL.PutJmpCF(GTR, L1);
      OPL.PutOM(4, 0F7H, 3H, y); (* NEG Ed *)
      OPL.PutOM(4, 0D3H, 7H, x); (* SAR Ed,CL *)
      OPL.PutJmpF(L2);
      OPL.FixLink(L1);
      OPL.PutOM(4, 0D3H, 4H, x); (* SHL Ed,CL *)
      CB.CheckOvfl;
      OPL.FixLink(L2);
      x.typ:=OPT.linttyp
    END
  END Ash;

(*----------------------------------------------------------------------------*)
  PROCEDURE And*(VAR x, y: OPL.Item);
    (* function:      computes & on boolean values                            *)
    (* precondition:  x = condition code                                      *)
    (*                y = condition codes or boolean values                   *)
    (* postcondition: x:=x & y, x.mode = Coc                                *)

  BEGIN
    IF y.mode # Coc THEN CB.BoolToCoc(y) END;
    IF y.disp # 0 THEN x.disp:=OPL.MergedLink(x.disp, y.disp) END;(* Fjmp   *)
    x.seg.reg:=y.seg.reg;             (* cc                                 *)
    x.adr:=y.adr                      (* Tjmp                               *)
  END And;

(*----------------------------------------------------------------------------*)
  PROCEDURE Or*(VAR x, y: OPL.Item);
    (* function:      computes OR on boolean values                           *)
    (* precondition:  x = condition code                                      *)
    (*                y = condition codes or boolean values                   *)
    (* postcondition: x:=x OR y, x.mode = Coc                               *)

  BEGIN
    IF y.mode # Coc THEN CB.BoolToCoc(y) END;
    IF y.adr # 0 THEN x.adr:=OPL.MergedLink(x.adr, y.adr) END;(* Tjmp       *)
    x.seg.reg:=y.seg.reg;             (* cc                                 *)
    x.disp:=y.disp                    (* Fjmp                               *)
  END Or;

(*----------------------------------------------------------------------------*)
  PROCEDURE CondAnd*(VAR x: OPL.Item);
    (* function:      sets true and false jumps for AND                       *)
    (* precondition:  x = condition code or boolean value                     *)
    (* postcondition: x = condition code                                      *)

  BEGIN
    IF x.mode # Coc THEN CB.BoolToCoc(x) END;
    OPL.PutJmpCF(CB.InvertedCoc(x.seg.reg), x.disp);(* Fjmp                      *)
    OPL.FixLink(x.adr)                  (* Tjmp here                          *)
  END CondAnd;

(*----------------------------------------------------------------------------*)
  PROCEDURE CondOr*(VAR x: OPL.Item);
    (* function:      sets true and false jumps for OR                        *)
    (* precondition:  x = condition code or boolean value                     *)
    (* postcondition: x = condition code                                      *)

  BEGIN
    IF x.mode # Coc THEN CB.BoolToCoc(x) END;
    OPL.PutJmpCF(x.seg.reg, x.adr);     (* Tjmp                               *)
    OPL.FixLink(x.disp)                 (* Fjmp here                          *)
  END CondOr;

(*----------------------------------------------------------------------------*)
  PROCEDURE Relation*(VAR x: OPL.Item);
  BEGIN
    IF x.mode = Coc THEN
      CB.CocToReg(x)
    ELSIF x.typ^.form IN realSet THEN
      CB.ValToFStk(x)
    END
  END Relation;

(*----------------------------------------------------------------------------*)
  PROCEDURE Len*(VAR x, y: OPL.Item);
    (* function:      returns the length of an array                          *)
    (* precondition:  x = array, y.mode = Con = dimension                     *)
    (* postcondition: x:=LEN(x, y)                                          *)

  VAR 
    n: LONGINT; 
    typ: OPT.Struct; 
    h: OPL.Item;
  BEGIN
    n:=y.adr; typ:=x.typ;
    WHILE n > 0 DO typ:=typ^.BaseTyp; DEC(n) END;
    IF typ^.comp = DynArr THEN          (* x.mode IN {Var, VarPar, RegI, DArr}      *)
      IF x.mode = MODE_REGI THEN
        x.disp:=typ^.offset + 4
      ELSIF x.mode = DArr THEN
        IF x.disp = MODE_REGI THEN
          Reg.ReleaseReg(x.bas);
          x.bas:=x.inx;
          x.disp:=typ^.offset + 4;
          x.mode:=MODE_REGI;
        ELSE
          CB.LoadBaseAdr(x);
          x.disp:=x.disp + typ^.offset + 4;
        END;
      ELSE
        CB.LoadBaseAdr(x);
        x.disp:=x.disp + typ^.offset + 4;
      END;
      h.mode:=MODE_REG; Reg.GetGenReg(h.bas);
      OPL.PutORM(4, 08BH, h.bas, x); (* MOV Gd,Ed *)
      OPL.PutOM(4, 0FFH, 0H, h); (* INC Ed *)
      OPL.Release(x);
      x.mode:=MODE_REG; x.bas:=h.bas
    ELSE                                (* typ^.comp = Array *)
      x.mode:=MODE_CON; 
      x.adr:=typ^.n
    END;
    x.typ:=OPT.linttyp;
  END Len;

(*----------------------------------------------------------------------------*)
  PROCEDURE Cmp*(VAR x, y: OPL.Item; rel: INTEGER);
    (* function:      returns the result of the comparison of 'x' with 'y'    *)
    (* precondition:  x, y: values to be compared (not both are constant)     *)
    (*                rel = relation used for comparison                      *)
    (* postcondition: x:=x 'rel' y. x.mode = Coc                            *)

  VAR 
    fx, fy, coc, size: INTEGER; 
    h: OPL.Item;
    L1, L2, L3: OPL.Label; 
    len: LONGINT;
  BEGIN
    IF x.mode # MODE_CON THEN 
      coc:=relToCoc[rel]
    ELSE 
      h:=x; x:=y; y:=h; 
      coc:=CB.ExchangedCoc(relToCoc[rel])
    END;
    fx:=x.typ^.form; size:=SHORT(x.typ^.size);
    fy:=y.typ^.form;
    CB.IgnoreDynArrDesc(x);
    CB.IgnoreDynArrDesc(y);
    IF fx # String THEN CB.LoadAdr(x) END;
    IF (fx IN realSet) OR (fy IN realSet) THEN
      IF (y.mode = MODE_FSTK) & (x.mode # MODE_FSTK) THEN
        coc:=CB.UnsignedCoc(coc)
      ELSE
        coc:=CB.UnsignedCoc(CB.ExchangedCoc(coc))
      END;
      CB.ValToFStk(x);
      CB.ValToFStk(y);
      Reg.GetThisReg(h.bas, EAX);
      Reg.DecFSP; Reg.DecFSP; OPL.PutO(0, 0DED9H); (* FCOMPP *)
      OPL.PutO(0, 0DFE0H); (* FSTSW AX *)
      OPL.PutO(1, 09EH); (* SAHF *)
      Reg.ReleaseReg(h.bas)
    ELSIF fx IN {Byte, Char} THEN
      CB.ValToReg(x);
      IF y.mode = MODE_CON THEN
        OPL.PutOMD(2, 2, 081H, 7H, x, y.adr) (* CMP Ew,Iw *)
      ELSE
        CB.ValToReg(y); OPL.PutORM(2, 039H, y.bas, x) (* CMP Ew,Gw *)
      END
    ELSIF fx IN {SInt..LInt, Set, NilTyp, Pointer, ProcTyp} THEN
      IF (size = 1) & (x.mode = MODE_REG) THEN Reg.MoveToByteReg(x.bas) END;
      IF y.mode = MODE_CON THEN
        IF size = 1 THEN OPL.PutOMD(1, 1, 080H, 7H, x, y.adr) (* CMP Eb,Ib *)
        ELSE OPL.PutOMD(size, size, 081H, 7H, x, y.adr) (* CMP Ev,Iv *)
        END
      ELSE
        IF size = 1 THEN CB.ValToByteReg(y); OPL.PutORM(size, 038H, y.bas, x) (* CMP Eb,Gb *)
        ELSE CB.ValToReg(y); OPL.PutORM(size, 039H, y.bas, x) (* CMP Ev,Gv *)
        END
      END
    ELSIF fx = Bool THEN                (* only eq or neq                     *)
      IF x.mode = MODE_REG THEN Reg.MoveToByteReg(x.bas) END;
      IF y.mode = MODE_CON THEN
        OPL.PutOMD(1, 1, 080H, 7H, x, y.adr) (* CMP Eb,Ib *)
      ELSE
        IF y.mode = Coc THEN CB.CocToReg(y) ELSE CB.ValToByteReg(y) END;
        OPL.PutORM(1, 038H, y.bas, x) (* CMP Eb,Gb *)
      END
    ELSIF y.mode = MODE_CON THEN        (* character-array 'rel' constant-string         *)
      len:=y.disp;
      CB.AdrToRegID0(x, ESI);
      CB.AdrToRegID0(y, EDI);
      Reg.MoveToThisReg(y.seg, ES);
      Reg.MoveSegRegIn(x.seg);
      h.mode:=MODE_REG; Reg.GetThisReg(h.bas, ECX);
      OPL.PutOMD(4, 4, 0C7H, 0H, h, len); (* MOV Ed,Id *)
      OPL.PutO(0, 0FCH); (* CLD *)
      IF x.seg.reg # DS THEN OPL.PutSegPrefix(x.seg.reg) END;
      OPL.PutO(1, 0F3A6H); (* REP REPE CMPSB *)
      OPL.Release(h);
    ELSE                                        (* character-array 'rel' character-array *)
      L2:=0; L3:=0;
      CB.AdrToRegID0(x, ESI);
      CB.AdrToRegID0(y, EDI);
      Reg.MoveToThisReg(y.seg, ES);
      Reg.MoveSegRegIn(x.seg);
      OPL.PutO(0, 0FCH); (* CLD *)
      L1:=OPL.pc;
      OPL.PutOMD(1, 1, 080H, 7H, y, 0); (* CMP Eb,Ib *)
      OPL.PutJmpCF(EQL, L2);
      IF x.seg.reg # DS THEN OPL.PutSegPrefix(x.seg.reg) END;
      OPL.PutO(1, 0A6H); (* CMPSB *)
      OPL.PutJmpCB(EQL, L1);
      OPL.PutJmpF(L3);
      OPL.FixLink(L2);
      IF x.seg.reg # DS THEN OPL.PutSegPrefix(x.seg.reg) END;
      OPL.PutO(1, 0A6H); (* CMPSB *)
      OPL.FixLink(L3)
    END;
    OPL.Release(x);
    CB.SetCoc(x, coc);
  END Cmp;

(*===================================== statements ===========================*)

  PROCEDURE Copy*(VAR x, y: OPL.Item);   (* x:=y                             *)
    (* function:      code for a copy                                         *)
    (* precondition:                                                          *)
    (* postcondition: x:=y                                                  *)

    VAR L1, L2: OPL.Label; size, base: OPL.Item;
  BEGIN
    CB.LoadSize(x, size);
    CB.ValToReg(size);
    CB.IgnoreDynArrDesc(x);
    CB.IgnoreDynArrDesc(y);
    CB.AdrToRegID0(y, ESI);
    CB.AdrToRegID0(x, EDI);
    Reg.MoveToThisReg(x.seg, ES);
    Reg.MoveSegRegIn(y.seg);
    Reg.MoveToThisReg(size.bas, EAX);
    OPL.PutO(0, 0FCH); (* CLD *)
      
    L1:=OPL.pc; L2:=0;
    OPL.PutOM(4, 0FFH, 1H, size); (* DEC Ed *)
    OPL.PutJmpCF(LEQ, L2);
    OPL.PutOMD(1, 1, 080H, 7H, y, 0); (* CMP Eb,Ib *)
    OPL.PutJmpCF(EQL, L2);      
    IF y.seg.reg # DS THEN OPL.PutSegPrefix(y.seg.reg) END;
    OPL.PutO(1, 0A4H); (* MOVSB *)
    OPL.PutJmpB(L1);
      
    OPL.FixLink(L2);
    OPL.PutORM(4, 031H, size.bas, size); (* XOR Ed,Gd *)
    OPL.PutO(1, 0AAH); (* STOSB *)
    OPL.Release(size);
  END Copy;

(*----------------------------------------------------------------------------*)
  PROCEDURE Assign*(VAR x, y: OPL.Item);
    (* function:      code for an assignement                                 *)
    (* postcondition: x:=y                                                  *)

  VAR 
    f, g: INTEGER;
  BEGIN
    f:=x.typ^.form; g:=y.typ^.form;
    CASE f OF
      Byte, Bool, Char:
        IF y.mode = MODE_CON THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 1, 06AH, y.adr) (* PUSH imm8  *)
(* !C!            OPL.PutOD(2, 2, 068H, y.adr) (* PUSH Iw *) *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(1, 1, 0C6H, 0H, x, y.adr) (* MOV Eb,Ib *)
          END
        ELSE
          CB.ValToByteReg(y);
          CB.CheckRange(y.bas, boundAdr[Char]);
          IF x.mode = Stk THEN
(*            OPL.PutPushReg(4, y.bas);  ??? !!! *)
            OPL.PutOD(2, 2, 068H, 0); (* PUSH imm16  *)
            OPL.PutPushReg(2, y.bas) 
          ELSE
            CB.LoadAdr(x);
            OPL.PutORM(1, 088H, y.bas, x) (* MOV Eb,Gb *)
          END
        END
    | SInt:
        IF y.mode = MODE_CON THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 1, 06AH, y.adr) (* PUSH imm8 *)
(* !C!            OPL.PutOD(2, 2, 068H, y.adr) (* PUSH Iw *) *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(1, 1, 0C6H, 0H, x, y.adr) (* MOV Eb,Ib *)
          END
        ELSE
          CB.ValToByteReg(y);
          CB.CheckRange(y.bas, boundAdr[SInt]);
          IF x.mode = Stk THEN
(*            OPL.PutPushReg(4, y.bas);  ??? !!! *)
            OPL.PutOD(2, 2, 068H, 0); (* PUSH imm16  *)
            OPL.PutPushReg(2, y.bas) 
          ELSE
            CB.LoadAdr(x);
            OPL.PutORM(1, 088H, y.bas, x) (* MOV Eb,Gb *)
          END
        END
    | Int:
        IF y.mode = MODE_CON THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 4, 068H, y.adr) (* PUSH imm32 *)
(* !C!            OPL.PutOD(2, 2, 068H, y.adr) (* PUSH Iw *) *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(2, 2, 0C7H, 0H, x, y.adr) (* MOV Ew,Iw *)
          END
        ELSE
          CB.ValToReg(y);
          CB.CheckRange(y.bas, boundAdr[Int]);
          IF x.mode = Stk THEN
(*            OPL.PutPushReg(4, y.bas);  ??? !!! *)
            OPL.PutOD(2, 2, 068H, 0); (* PUSH imm16  *)
            OPL.PutPushReg(2, y.bas) 
          ELSE
            CB.LoadAdr(x);
            OPL.PutORM(2, 089H, y.bas, x) (* MOV Ew,Gw *)
          END
        END
    | LInt:
        IF y.mode = MODE_CON THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 4, 068H, y.adr) (* PUSH Id *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, y.adr) (* MOV Ed,Id *)
          END
        ELSE
          CB.ValToReg(y);
          IF x.mode = Stk THEN
            OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutORM(4, 089H, y.bas, x) (* MOV Ed,Gd *)
          END
        END
    | Real:
        IF (y.mode = MODE_CON) & (g = Real) THEN
          IF x.mode = Stk THEN
            CB.LoadAdr(y);
            OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
          ELSE
            CB.LoadAdr(x);
            CB.MoveBlockS(x, y, 4);
          END
        ELSE
          IF x.mode = Stk THEN
            IF g # Real THEN CB.ValToFStk(y) END;
            IF y.mode = MODE_FSTK THEN
              CB.AllocStkBlockS(4, x);
              Reg.DecFSP; OPL.PutOM(4, 0D9H, 3H, x); (* FSTP Es *)
              OPL.PutB(09BH); (* WAIT *)
              OPL.Release(x);
              x.mode:=Stk
            ELSE
              CB.LoadAdr(y);
              OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
            END
          ELSE
            CB.ValToFStk(y);
            CB.LoadAdr(x);
            Reg.DecFSP; OPL.PutOM(4, 0D9H, 3H, x); (* FSTP Es *)
            OPL.PutB(09BH) (* WAIT *)
          END
        END
    | LReal:
        IF (y.mode = MODE_CON) & (g = LReal) THEN
          IF x.mode = Stk THEN 
            CB.LoadAdr(y);
            CB.IncAdr(y, 4);
            OPL.PutOM(4, 0FFH, 6H, y); (* PUSH Ed *)
            CB.IncAdr(y, -4);
            OPL.PutOM(4, 0FFH, 6H, y); (* PUSH Ed *)
          ELSE
            CB.LoadAdr(x);
            CB.MoveBlockS(x, y, 8);
          END
        ELSE
          IF x.mode = Stk THEN
            IF g # LReal THEN CB.ValToFStk(y) END;
            IF y.mode = MODE_FSTK THEN
              CB.AllocStkBlockS(8, x);
              Reg.DecFSP; OPL.PutOM(4, 0DDH, 3H, x); (* FSTP El *)
              OPL.PutB(09BH); (* WAIT *)
              OPL.Release(x);
              x.mode:=Stk
            ELSE
              CB.LoadAdr(y);
              CB.IncAdr(y, 4);
              OPL.PutOM(4, 0FFH, 6H, y); (* PUSH Ed *)
              CB.IncAdr(y, -4);
              OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
            END;
          ELSE
            CB.ValToFStk(y);
            CB.LoadAdr(x);
            Reg.DecFSP; OPL.PutOM(4, 0DDH, 3H, x); (* FSTP El *)
            OPL.PutB(09BH) (* WAIT *)
          END
        END
    | Set:
        IF y.mode = MODE_CON THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 4, 068H, y.adr) (* PUSH Id *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(OPM.SetSize, OPM.SetSize, 0C7H, 0H, x, y.adr) (* MOV Ev,Iv *)
          END
        ELSE
          CB.ValToReg(y);
          IF x.mode = Stk THEN
            OPL.PutPushReg(4, y.bas)
          ELSE
            CB.LoadAdr(x);
            OPL.PutORM(OPM.SetSize, 089H, y.bas, x) (* MOV Ev,Gv *)
          END
        END
    | Pointer:
        IF g = NilTyp THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 4, 068H, nil) (* PUSH Id *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, nil) (* MOV Ed,Id *)
          END
        ELSE
          IF x.mode = Stk THEN CB.LoadAdr(y);
            OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
          ELSE
            CB.ValToReg(y);
            CB.LoadAdr(x);
            OPL.PutORM(4, 089H, y.bas, x) (* MOV Ed,Gd *)
          END
        END
    | ProcTyp:
        IF g = NilTyp THEN
          IF x.mode = Stk THEN
            OPL.PutOD(4, 4, 068H, nil) (* PUSH Id *)
          ELSE
            CB.LoadAdr(x);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, nil) (* MOV Ed,Id *)
          END
        ELSIF x.typ = y.typ THEN
          IF x.mode = Stk THEN CB.LoadAdr(y);
            OPL.PutOM(4, 0FFH, 6H, y) (* PUSH Ed *)
          ELSE
            CB.ValToReg(y);
            CB.LoadAdr(x);
            OPL.PutORM(4, 089H, y.bas, x) (* MOV Ed,Gd *)
          END
        ELSE                            (* y.mode IN {XProc, IProc, WProc, CDeclProc ? }    *)
          IF y.mnolev < 0 THEN          (* procedure imported from other module*)
(*!C!            IF x.mode = Stk THEN
              OPL.PutOD(4, 4, 068H, y.adr) (* !C! 0 -> y.adr *) (* PUSH Id *)
            ELSE
              CB.LoadAdr(x);
              OPL.PutOMD(4, 4, 0C7H, 0H, x, y.adr) (* !C! 0 -> y.adr *) (* MOV Ed,Id *)
            END;
(*            OPL.DefineFixup(fixupCodePtr, SHORT(y.adr), OPL.pc - 4) !C! *)
            OPL.DefineFixup(FIXUP_CODE_SECTION, -y.mnolev, OPL.pc - 4) (* !!! ??? *)*)
            IF x.mode = Stk THEN
              OPL.PutOD(4, 4, 068H, 0) (* PUSH Id *)
            ELSE
              CB.LoadAdr(x);
              OPL.PutOMD(4, 4, 0C7H, 0H, x, 0) (* MOV Ed,Id *)
            END;
            OPL.DefineFixup(FIXUP_ABSCODE, y.adr, OPL.pc - 4)
          ELSE                          (* own procedure                     *)
            IF y.adr > 0 THEN
              IF x.mode = Stk THEN
                OPL.PutOD(4, 4, 068H, y.adr) (* PUSH Id *)
              ELSE
                CB.LoadAdr(x);
                OPL.PutOMD(4, 4, 0C7H, 0H, x, y.adr) (* MOV Ed,Id *)
              END;
            ELSE                        (* forward definition                 *)
              IF x.mode = Stk THEN
                OPL.PutOD(4, 4, 068H, y.disp) (* PUSH Id *)
              ELSE
                CB.LoadAdr(x);
                OPL.PutOMD(4, 4, 0C7H, 0H, x, y.disp) (* MOV Ed,Id *)
              END;
              y.disp:=OPL.pc - 4;
            END;
(*            OPL.DefineFixup(fixupConstLen, 0, OPL.pc - 4); !C! 
            OPL.DefineFixup(fixupCodeSeg, 0, OPL.pc - 2); *)
            OPL.DefineFixup(FIXUP_CODE_SECTION, 0, OPL.pc - 4) (* !!! ??? *)
          END
        END
    | Comp:
        IF x.mode = Stk THEN
          IF x.typ^.comp # DynArr THEN
            CB.AllocStkBlockS(x.typ^.size + (-x.typ^.size) MOD  4, x)
(* !C!           CB.AllocStkBlockS(x.typ^.size + (-x.typ^.size) MOD  2, x) *)
          END
        ELSE
          CB.LoadAdr(x);
        END;
        IF x.typ^.comp = Array THEN
          IF x.typ = y.typ THEN
            CB.MoveBlockS(x, y, x.typ^.size)
          ELSE
            CB.MoveBlockS(x, y, y.disp) (* String                             *)
          END
        ELSIF x.typ^.comp = DynArr THEN
          CB.PushDynArrDesc(x, y)
        ELSE                                          (* x.typ^.comp = Record               *)
          CB.MoveBlockS(x, y, x.typ^.size)
        END
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"assign");
    END
  END Assign;

(*----------------------------------------------------------------------------*)
  PROCEDURE MulDim*(VAR y, z: OPL.Item; dimtyp, dim0typ: OPT.Struct);    (* z:=z * y *)

    VAR s: OPL.Item;
  BEGIN
    IF y.mode # MODE_CON THEN
      CB.ValToReg(y)
    END;
    IF dimtyp = dim0typ THEN (* outer dimension *)
      z.mode:=MODE_REG;
      Reg.GetGenReg(z.bas);
      IF y.mode = MODE_CON THEN
        OPL.PutOMD(4, 4, 0C7H, 0H, z, y.adr) (* MOV Ed,Id *)
      ELSE
        OPL.PutORM(4, 089H, y.bas, z) (* MOV Ed,Gd *)
      END;
    ELSE
      Mul(z, y, FALSE);
    END;
    IF dimtyp^.offset = 4 THEN (* inner dimension *)
      s.mode:=MODE_CON; s.typ:=OPT.linttyp; s.adr:=dimtyp^.BaseTyp^.size;
      Mul(z, s, FALSE);
      s.mode:=MODE_CON; s.typ:=OPT.linttyp; s.adr:=dim0typ^.size;
      Add(z, s, FALSE);
    END;
  END MulDim;

 (*----------------------------------------------------------------------------*)
  PROCEDURE SetDim*(VAR x, y: OPL.Item; dimtyp: OPT.Struct);
    (* function:      set LEN(x, dimtyp^.n)-1 to y-1                   *)
    (* precondition:  x.mode = RegI, pointer to array bounds         *)
    (*                y = LEN(x, dimtyp^.n)                           *)
    (* postcondition: array bounds for dimension 'dimtyp^.n' are set   *)
    
    VAR h: OPL.Item;
  BEGIN
    x.disp:=dimtyp^.offset;
    OPL.PutOMD(4, 4, 0C7H, 0H, x, 0); (* MOV Ed,Id *) (* 0 *)
    INC(x.disp, 4);
    IF y.mode = MODE_CON THEN
      OPL.PutOMD(4, 4, 0C7H, 0H, x, y.adr - 1) (* MOV Ed,Id *) (* LEN - 1 *)
    ELSE
      h.mode:=MODE_CON; h.adr:=1;
      Sub(y, h, FALSE);
      OPL.PutORM(4, 089H, y.bas, x); (* MOV Ed,Gd *) (* LEN - 1 *)
    END;
  END SetDim;

(*----------------------------------------------------------------------------*)
  PROCEDURE New*(VAR x, y: OPL.Item);
    (* function:      allocates a new block of memory from heap               *)
    (* precondition:  x = address, where address of new block is stored       *)
    (*                x.typ^.BaseTyp^.comp IN {Record, Array, DynArr} *)
    (*                for DynArr 'y' is set to size of heap-block  *)
    
  VAR 
    h, x2, y2, xtag: OPL.Item; 
    typ: OPT.Struct; 
    regs: Reg.RegSetT;
  BEGIN
    typ:=x.typ^.BaseTyp;

    IF typ^.comp = DynArr THEN
      Reg.SaveCPURegisters(regs);
      OPL.TransferItem(x, regs, x2);
      OPL.TransferItem(y, regs, y2);
    ELSE
      x2:=x; y2:=y
    END; 
    IF typ^.comp = DynArr THEN
      OPL.PutOD(4, 4, 068H, 0); (* PUSH Id *)  (* no type-tag for DynArr *)
      IF y2.mode = MODE_CON THEN
        IF CB.ptrinit THEN
          OPL.PutOD(4, 4, 068H, -y2.adr) (* PUSH Id *)
        ELSE
          OPL.PutOD(4, 4, 068H, y2.adr) (* PUSH Id *)
        END
      ELSE
        CB.ValToReg(y2);
        IF CB.ptrinit THEN
          OPL.PutOM(4, 0F7H, 3H, y2); (* NEG Ed *)
        END;
        OPL.PutOM(4, 0FFH, 6H, y2) (* PUSH Ed *)
      END
    ELSE
      IF typ^.comp = Array THEN
        OPL.PutOD(4, 4, 068H, 0); (* PUSH Id *) (* no type-tag for Array *)
      ELSE
        LoadTypDescAdr(typ,xtag);
        CB.PushAdr(xtag);
        OPL.Release(xtag);
(* !C!        OPL.PutOD(4, 4, 068H, typ^.tdadr); (* PUSH Id *)
(*        OPL.DefineFixup(fixupCodeSeg, typ^.mno, OPL.pc - 2); !C! *)
        OPL.DefineFixup(FIXUP_CONST, (* ??? -*)typ^.mno, OPL.pc - 4); *)
      END;
      IF CB.ptrinit THEN
        OPL.PutOD(4, 4, 068H, -typ^.size) (* PUSH Id *)
      ELSE
        OPL.PutOD(4, 4, 068H, typ^.size) (* PUSH Id *)
      END
    END;
    CB.PushAdr(x2);
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsNewInx, OPL.pc - 4);

    IF typ^.comp = DynArr THEN
      h.mode:=0;
      h.typ:=OPT.notyp;
      Reg.RestoreCPURegisters(regs);
    ELSE
      x:=x2; y:=y2;
    END;
  END New;

(*----------------------------------------------------------------------------*)
  PROCEDURE Dispose*(VAR x: OPL.Item);
    (* function:      deallocates a block of memory from heap                 *)
    (* precondition:  x = address, where address of block is stored           *)
    
    VAR h: OPL.Item;
  BEGIN 
    CB.LoadAdr(x);
    OPL.PutOM(4, 0FFH, 6H, x); (* PUSH Ed *)
    IF CB.ptrinit THEN (* change+ 3.10.95, 1.18 : if option pointer initialization is set, set pointer to zero after DISPOSE *)
      OPL.PutOMD(4,4,0C7H,0,x,0);
    END;               (* change- *)
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsDisposeInx, OPL.pc - 4);
  END Dispose;

(*----------------------------------------------------------------------------*)
  PROCEDURE Code*(n: LONGINT);
    (* function:      writes a single byte into code area                     *)
    (* precondition:  n = value of byte to be written                         *)

  BEGIN
    OPL.PutB(SHORT(n))
  END Code;

(*----------------------------------------------------------------------------*)
  PROCEDURE With*(VAR x: OPL.Item);
    (* function:      code for the with statement                             *)

  BEGIN
  END With;

(*----------------------------------------------------------------------------*)
  PROCEDURE FJ*(VAR loc: OPL.Label);
    (* function:      unconditional forward jump                              *)

  BEGIN
    OPL.PutJmpF(loc);
  END FJ;

(*----------------------------------------------------------------------------*)
  PROCEDURE CFJ*(VAR x: OPL.Item; VAR loc: OPL.Label);
    (* function:      conditional forward jump on false                       *)

  BEGIN
    IF x.mode # Coc THEN CB.BoolToCoc(x) END;
    OPL.PutJmpCF(CB.InvertedCoc(x.seg.reg), x.disp); loc:=x.disp;(* Fjmp       *)
    OPL.FixLink(x.adr)                  (* Tjmp here                          *)
  END CFJ;

(*----------------------------------------------------------------------------*)
  PROCEDURE BJ*(loc: OPL.Label);
    (* function:      unconditional backward jump                             *)

  BEGIN
    OPL.PutJmpB(loc)
  END BJ;

(*----------------------------------------------------------------------------*)
  PROCEDURE CBJ*(VAR x: OPL.Item; loc: OPL.Label);
    (* function:      conditional backward jump on false                      *)

    VAR L1: OPL.Label;
  BEGIN
    IF x.mode # Coc THEN CB.BoolToCoc(x) END;
    IF x.disp = 0 THEN
      OPL.PutJmpCB(CB.InvertedCoc(x.seg.reg), loc);(* Fjmp                       *)
    ELSE
      L1:=0;
      OPL.PutJmpCF(x.seg.reg, L1);
      OPL.FixLink(x.disp);              (* Fjmp here                          *)
      OPL.PutJmpB(loc);
      OPL.FixLink(L1);
    END;
    OPL.FixLink(x.adr)                  (* Tjmp here                          *)
  END CBJ;

(*----------------------------------------------------------------------------*)
  PROCEDURE Case*(VAR x: OPL.Item; low, high: LONGINT; VAR tab: LONGINT);
    (* function:      code for the case statement                             *)
    (* precondition:  x = value of case selector                              *)
    (*                low, high = minimal an maximal value of 'x'             *)
    (* postcondition: tab = address of case table                             *)
    (*                code for trap or ELSE clause must follow immEDIately    *)
    (*                after the code emitted by this function                 *)
  VAR 
    LElse: OPL.Label;
  BEGIN
    CB.ValToReg(x);
    IF low # 0 THEN 
      OPL.PutOMD(4, 4, 081H, 5H, x, low); (* SUB Ed,Id *)
    ELSE
      OPL.PutORM(4, 85H, x.bas, x); (* TEST Ed,Gd *)
    END;
    LElse:=0;
    OPL.PutJmpCF(LSS, LElse);
    OPL.PutOMD(4, 4, 081H, 7H, x, high-low); (* CMP Ed,Id *)
    OPL.PutJmpCF(GTR, LElse);
    OPL.PutCaseJmp(x);
    OPL.AllocCaseTab(low, high, tab);
(*     OPL.CaseJump(tab, 0, high - low);!C! *)
    OPL.FixLink(LElse)
  END Case;

(*----------------------------------------------------------------------------*)
  PROCEDURE Param*(VAR ap: OPL.Item; fpO: OPT.Object; deref: BOOLEAN; isReceiver:BOOLEAN);
    (* function:      pushes the parameter to the stack                       *)
    (* precondition:  ap = actual parameter;                                  *)
    (*                fpO = formal parameter;                                 *)
    (*                IF deref THEN ap is a pointer END                       *)
    (*                isReceiver is TRUE if the parameter is the receiver of  *) 
    (*                  a method call                                         *)
    (* postcondtion:  if parameter is receiver: ap = type-tag                 *)

  VAR 
    f: INTEGER; 
    fp, h, xtag: OPL.Item;
  BEGIN
    fp.mode:=fpO^.mode; 
    fp.typ:=fpO^.typ;
    f:=fp.typ^.comp;
    IF f = DynArr THEN
      CB.PushDynArrDesc(fp, ap)
    ELSIF fp.mode = VarPar THEN
      IF f = Record THEN
        IF ap.typ^.form = Pointer THEN
          CB.DeRef(ap);           (* pointer to object on heap *)
          CB.PushAdr(ap);
          CB.IncAdr(ap, -4);      (* pointer to type-tag *)
          OPL.PutOM(4, 0FFH, 6H, ap); (* PUSH Ed *) (* push type-tag *)
          IF isReceiver THEN CB.DeRef(ap) END;
        ELSIF deref THEN
          CB.LoadAdr(ap);
          CB.PushAdr(ap);
          CB.IncAdr(ap, -4);      (* pointer to type-tag *)
          OPL.PutOM(4, 0FFH, 6H, ap); (* PUSH Ed *) (* push type-tag *)
          IF isReceiver THEN CB.DeRef(ap) END;
        ELSIF ap.mode = VarPar THEN
          CB.LoadBaseAdr(ap);     (* pointer to type-tag *)
          CB.IncAdr(ap, 4);       (* pointer to address *)
          OPL.PutOM(4, 0FFH, 6H, ap); (* PUSH Ed *) (* push adr *)
          CB.IncAdr(ap, -4);      (* pointer to type-tag *)
          OPL.PutOM(4, 0FFH, 6H, ap); (* PUSH Ed *) (* push type-tag *)
          IF isReceiver THEN CB.DeRef(ap) END;
        ELSE
          CB.PushAdr(ap);
          LoadTypDescAdr(ap.typ,xtag);
          CB.PushAdr(xtag);
          OPL.Release(ap);
          ap:=xtag;
(*          OPL.Release(xtag);*)
        END;
      ELSE
        IF isReceiver THEN OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.Param") END; (* typetag would not be set in this case *)
        CB.PushAdr(ap)
      END;
    ELSIF fp.mode = MODE_VARSTPAR THEN (* this type of parameter can not be a receiver *)
      IF f#Record THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.Param");
        RETURN;
      END;
      IF ap.typ=OPT.niltyp THEN
        OPL.PutOD(4, 4, 068H, 0); (* PUSH imm32 *)
      ELSIF ap.typ^.form = Pointer THEN
        CB.DeRef(ap);           (* pointer to object on heap *)
        CB.PushAdr(ap);
      ELSIF deref THEN
        CB.LoadAdr(ap);
        CB.PushAdr(ap);
      ELSIF ap.mode = VarPar THEN
        CB.LoadBaseAdr(ap);     (* pointer to type-tag *)
        CB.IncAdr(ap, 4);       (* pointer to address *)
        OPL.PutOM(4, 0FFH, 6H, ap); (* PUSH Ed *) (* push adr *)
      ELSE
        CB.PushAdr(ap);
      END;
    ELSE
      h.mode:=Stk; 
      h.typ:=fp.typ;
      Assign(h, ap);
      OPL.Release(h); 
      IF isReceiver THEN
        IF ap.typ^.form = Pointer THEN
          CB.DeRef(ap);            (* pointer to object on heap *)
          CB.IncAdr(ap, -4);       (* pointer to type-tag *) 
          CB.DeRef(ap);            (* pointer to type-descriptor *)
        ELSIF deref THEN
          CB.IncAdr(ap, -4);       (* pointer to type-tag *)
          CB.DeRef(ap);            (* pointer to type-descriptor *)
        ELSIF ap.mode = VarPar THEN
          CB.LoadBaseAdr(ap);      (* pointer to type-tag *)
          CB.DeRef(ap);            (* pointer to type-descriptor *)
        ELSE
          LoadTypDescAdr(ap.typ, h);    (* pointer to type-descriptor *)
          OPL.Release(ap);
          ap:=h; 
        END;
      END;  
    END;
  END Param;

(*----------------------------------------------------------------------------*)
(*  PROCEDURE AdjustSP;
  VAR 
    x: OPL.Item;
  BEGIN
    x.mode:=Reg;
    x.bas.reg:=ebp;
    OPL.PutORM(4, 0FB7H, x.bas, x); (* MOVZX EBP,BP *)
  END AdjustSP; *)

(*----------------------------------------------------------------------------*)
(*  PROCEDURE ClearSegRegs;
    VAR x, h: OPL.Item;
  BEGIN
    OPL.GetThisReg(x.bas, ebx);
    CB.ClearReg(x.bas);
    x.mode:=Reg;
    OPL.GetThisReg(h.seg, es);
    OPL.PutORM(2, 08EH, h.seg, x); (* MOV Sw,Ew *)
    OPL.ReleaseReg(h.seg);
    OPL.GetThisReg(h.seg, fs);
    OPL.PutORM(2, 08EH, h.seg, x); (* MOV Sw,Ew *)
    OPL.ReleaseReg(h.seg);
    h.seg.reg:=gs;
    OPL.PutORM(2, 08EH, h.seg, x); (* MOV Sw,Ew *)
    OPL.ReleaseReg(x.bas);
  END ClearSegRegs;*)

(*----------------------------------------------------------------------------*)
(*  proc^.obj^.mode = WProc | CDeclProc -> parameters isWProc,... not necessary ? !!! *)
  PROCEDURE Call*(VAR x: OPL.Item; isWProc,isCDeclProc: BOOLEAN; proc: OPT.Object; paramSize:LONGINT);
    (* function:      generate code for procedure calls                       *)
    (* precondition:  x.mode IN {LProc, XProc, WProc, CProc, Var, VarPar      *)
    (*                proc = NIL: call a procedure variable                   *)
    (*                proc # NIL: call this procedure                         *)
    (*                if x.mode is CDeclProc then paramSize contains the total*)
    (*                                    size of parameters on the stackproc *)

  VAR 
    i, n: INTEGER; 
    h: OPL.Item;
    
    PROCEDURE PutAddStack(x:LONGINT);
    BEGIN
      IF x>0 THEN
        IF x>=10000H THEN
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.Call2");
        ELSIF x>=100H THEN
          OPL.PutB(081H); (* ADD SP , imm16 *)
          OPL.PutB(0C4H);
          OPL.PutW(SHORT(x));
        ELSE
          OPL.PutB(083H); (* ADD SP , imm8 *)
          OPL.PutB(0C4H);
          OPL.PutB(SHORT(x));
        END;
      ELSIF x=0 THEN
      ELSE
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.Call");
      END;
    END PutAddStack;
    
  BEGIN
    CASE x.mode OF
      LProc:
        IF proc^.adr <= 0 THEN 
          OPL.PutCallF(proc^.adr)
        ELSE 
          OPL.PutCallB(x.mode, proc^.adr)
        END
    | XProc, WProc, MODE_CDECLPROC:
        IF x.mnolev < 0 THEN  (* call to other module ? *)
          IF proc^.symTableInx = -1 THEN WriteObj.DefineImport(proc) END;
          IF proc^.fromDLL THEN (* call to DLL? *)
            h.seg.reg:=DS;
            h.adr:=0;
            h.mode:=MODE_ABS;
            OPL.PutIndCall(h);
            OPL.DefineFixup(FIXUP_ABSCODE, SHORT(proc^.symTableInx), OPL.pc - 4)
          ELSE
            OPL.PutDirCall(0);
            OPL.DefineFixup(FIXUP_CODE, SHORT(proc^.symTableInx), OPL.pc - 4)
          END;
        ELSE                            (* x.mnolev = 0                       *)
          IF proc^.adr <= 0 THEN
            OPL.PutCallF(proc^.adr)
          ELSE
            OPL.PutCallB(x.mode, proc^.adr)
          END
        END;
        IF x.mode=MODE_CDECLPROC THEN (* + 26.08.96 *)
          PutAddStack(paramSize);
        END;
    | CProc:
        i:=1; 
        n:=ORD(proc^.conval^.ext^[0]);
        WHILE i <= n DO OPL.PutB(ORD(proc^.conval^.ext^[i])); INC(i) END
    | IProc:
        Err(E.NOT_IMPLEMENTED)          (* not yet implemented                *)
    ELSE                                (* proc variables, TProc                    *)
      IF (x.mode#MODE_ABS) & (x.mode#MODE_ABS_RELOC) THEN
        CB.LoadAdr(x);
        CB.AdrToRegI(x);
      END;
      OPL.PutIndCall(x);
      IF isCDeclProc THEN PutAddStack(paramSize) END;
(* !C!      IF isWProc THEN        (* call API-Proc via procedure variable *)
        CB.LoadAdr(x);
        CB.AdrToRegI(x);
        OPL.PutIndCall(x)
      ELSIF isCDeclProc THEN 
        CB.LoadAdr(x);
        CB.AdrToRegI(x);
        OPL.PutIndCall(x);
        PutAddStack(paramSize);
(*        CB.ValToReg(x);
        h.mode:=MODE_ABS; h.seg.reg:=DS; h.adr:=floatBegin;
        OPL.PutORM(4, 089H, x.bas, h); (* MOV Ed,Gd *)
        OPL.DefineFixup(FIXUP_VIRTREGISTER, 0, OPL.pc - 4);
(*        OPL.DefineFixup(fixupComDataOff, 0, OPL.pc - 4); !C! *)
        OPL.Release(x);
(*        ClearSegRegs;*)
        OPL.PutIndCall(h);              (* makes sure that GS is not used *)
        OPL.DefineFixup(FIXUP_VIRTREGISTER, 0, OPL.pc - 2);
(*        OPL.DefineFixup(fixupComDataOff, 0, OPL.pc - 2); !C! *)
        IF isCDeclProc THEN (* + 26.08.96 *)
          PutAddStack(paramSize);
        END;
(*        AdjustSP;*)*)
      ELSE
        CB.LoadAdr(x);
        CB.AdrToRegI(x);
        OPL.PutIndCall(x)
      END *)
    END
    (*function result is marked when restoring registers                      *)
  END Call;

(*----------------------------------------------------------------------------*)
  PROCEDURE CopyDynArray*(adr: LONGINT; typ: OPT.Struct);
    (* function:      copy a dynamic array to stack                           *)
    (* precondition:  SS[EBP + adr] = address of dynamic array (VarPar)       *)
    (*                typ = data-type of dynamic array                        *)

  VAR 
    x, y, h, size: OPL.Item;
  BEGIN
    x.mode:=VarPar; 
    x.adr:=adr; 
    x.typ:=typ; 
    x.mnolev:=OPL.level;
    CB.LoadSize(x, size);  
    CB.AllocStkBlock(size, h);
    CB.MoveBlock(h, x, size);
    OPL.Release(h);
    OPL.Release(size);
    OPL.Release(x);
    x.mode:=MODE_REGI; 
    x.disp:=adr; 
    x.seg.reg:=SS; 
    x.bas.reg:=EBP;
    y.mode:=MODE_REG; 
    y.bas.reg:=ESP;
    OPL.PutORM(4, 089H, y.bas, x); (* MOV Ew,Gw *) (* offset *) 
(* !C!    OPL.PutORM(2, 089H, y.bas, x); (* MOV Ew,Gw *) (* offset *)
    CB.IncAdr(x, 2); y.seg.reg:=ss;
    OPL.PutORM(2, 08CH, y.seg, x) (* MOV Ew,Sw *) (* segment *) *)
  END CopyDynArray;

(*----------------------------------------------------------------------------*)
  PROCEDURE InitPtrs*(proc: OPT.Object);
    (* function:      initializes all local pointers of 'proc' to NIL         *)
    (* precondition:  proc = entered procedure                                *)

  CONST 
    MaxPtrs = 10;
  VAR 
    i, nofptrs: INTEGER; 
    n: LONGINT; 
    x, y, z, h: OPL.Item; 
    obj: OPT.Object;
    PtrTab: ARRAY MaxPtrs + 1 OF LONGINT;
  BEGIN
    IF CB.ptrinit THEN
      nofptrs:=0; obj:=proc^.scope^.scope;    (* local variables *)
      WHILE (obj # NIL) & (nofptrs <= MaxPtrs) DO
        OPL.FindPtrs(obj^.typ, obj^.adr, PtrTab, nofptrs);
        obj:=obj^.link
      END ; 
      
      IF nofptrs>0 THEN
        (* EAX:=0 *)
        Reg.GetThisReg(h.bas, EAX);
        CB.ClearReg(h.bas);
        IF nofptrs > MaxPtrs THEN 
          (* initialize whole frame to NIL *)
          (* proc^.conval^.intval2 is framesize *)
  
          y.mode:=MODE_REG;                    (* ECX:=size DIV 4 *)
          Reg.GetThisReg(y.bas, ECX);
          OPL.PutOMD(4, 4, 0C7H, 0H, y, proc^.conval^.intval2 DIV  4); (* MOV Ed,Id *)
  
          z.seg.reg:=SS;                  (* ES:=SS *)
          Reg.MoveToThisReg(z.seg, ES);
  
          z.mode:=MODE_REG;                    (* EDI:=ESP *)
          z.bas.reg:=ESP;
          Reg.GetThisReg(z.inx, EDI);
          OPL.PutORM(4,  08BH, z.inx, z); (* MOV r32, r/m32 *)
  
          OPL.PutO(0, 0FCH); (* CLD *)
          OPL.PutO(4, 0F3ABH); (* REP REPE STOSW/D *)
          
          Reg.ReleaseReg(y.bas);
          Reg.ReleaseReg(z.seg);
          Reg.ReleaseReg(z.inx);
        ELSE
          (* x.typ:=OPT.niltyp; x.mnolev:=OPL.level; *)
          x.mode:=MODE_REGI; x.seg.reg:=SS; x.bas.reg:=EBP;
          i:=0; 
          WHILE i < nofptrs DO
            x.disp:=PtrTab[i];
            IF x.disp < 0 THEN
              OPL.PutORM(4, 089H, h.bas, x) (* MOV Ed,Gd *)
            END;
            INC(i)
          END
        END; 
        Reg.ReleaseReg(h.bas);
      END;
    END
  END InitPtrs;

(*----------------------------------------------------------------------------*)
  PROCEDURE InitImportedModules;
    (* function:      code to call the module bodies of the imported modules  *)

  VAR 
    i: INTEGER;
    h:OPL.Item;
  BEGIN
    i:=0;
    WHILE i < OPT.nofGmod DO
      OPL.PutOD(4, 4, 068H, OPT.GlbMod[i]^.adr); (* PUSH Id *) (* module key *)
      IF OPT.GlbMod[i]^.fromDLL THEN
        h.seg.reg:=DS;
        h.adr:=0;
        h.mode:=MODE_ABS;
        OPL.PutIndCall(h);
        OPL.DefineFixup(FIXUP_DLLMODENTRY, i + 1, OPL.pc - 4)
      ELSE
        OPL.PutDirCall(0);
        OPL.DefineFixup(FIXUP_MODENTRY, i + 1, OPL.pc - 4);
      END;
      INC(i)
    END
  END InitImportedModules;

(*----------------------------------------------------------------------------*)
  PROCEDURE InitOwnModule;
  (* function:      code to register own module with RTS                      *)
  BEGIN
    OPL.PutOD(4, 4, 068H, 0); (* PUSH imm32 *) 
    OPL.DefineFixup(FIXUP_MOD_DESC_OFF, 0, OPL.pc - 4); 
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsInitModuleInx, OPL.pc - 4);
  END InitOwnModule;

(*----------------------------------------------------------------------------*)
  PROCEDURE EnterProc(mode: INTEGER; locSize: LONGINT; nesting: INTEGER);
  VAR 
    x: OPL.Item;
  BEGIN
    IF ~(mode IN {LProc, XProc, TProc, IProc, WProc, MODE_CDECLPROC}) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"EnterProc");
    END;
    OPL.PutB(0C8H); (* ENTER Iw,Ib *)
    OPL.PutW(locSize);
    OPL.PutB(nesting);
    IF (mode = WProc) OR (mode=MODE_CDECLPROC) THEN
      OPL.PutB(053H); (* PUSH EBX *)
      OPL.PutB(056H); (* PUSH ESI *)
      OPL.PutB(057H); (* PUSH EDI *)
    END;
  END EnterProc;

(*----------------------------------------------------------------------------*)
  PROCEDURE LeaveProc(mode: INTEGER; parSize: LONGINT);
  BEGIN
    IF ~(mode IN {LProc, XProc, TProc, IProc, WProc,MODE_CDECLPROC}) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"LeaveProc");
    END;
    IF (mode = WProc) OR (mode=MODE_CDECLPROC) THEN
      OPL.PutB(05FH); (* POP EDI *)
      OPL.PutB(05EH); (* POP ESI *)
      OPL.PutB(05BH); (* POP EBX *)
    END;
    OPL.PutB(0C9H);              (* LEAVE *)
    IF mode = IProc THEN
      OPL.PutB(0CFH)              (* IRET *)
    ELSIF mode=MODE_CDECLPROC THEN
      OPL.PutB(0C3H);         (* RET near *)
    ELSE
      OPL.PutB(0C2H);   (* RET near imm16 *)
      OPL.PutW(parSize)
    END;
    WHILE OPL.pc MOD 4#0 DO
      OPL.PutB(0CCH);   (* INT 3 *)
    END;
  END LeaveProc;

(*----------------------------------------------------------------------------*)
  PROCEDURE CallRtsInitDllModule;
  VAR
    h:OPL.Item;
  BEGIN
    OPL.PutOD(4, 4, 068H, 0); (* PUSH imm32 *) 
    OPL.DefineFixup(FIXUP_MOD_DESC_OFF, 0, OPL.pc - 4); 
    h.mode:=MODE_REGI;
    h.seg.reg:=SS;
    h.bas.reg:=EBP;
    h.disp:=08H; OPL.PutOM(4,0FFH,6,h); (* PUSH [EBP+ 8] *)
    h.disp:=0CH; OPL.PutOM(4,0FFH,6,h); (* PUSH [EBP+12] *)
    h.disp:=10H; OPL.PutOM(4,0FFH,6,h); (* PUSH [EBP+16] *)
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsInitDllModuleInx, OPL.pc - 4);
  END CallRtsInitDllModule;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE Enter*(proc: OPT.Object; locSize: LONGINT);
    (* function:      code at entry-point of procedures and modules           *)
    (* precondition:  proc = NIL: enter module body                           *)
    (*                proc # NIL: enter procedure 'proc'                      *)
    (*                locSize = size of local variables in bytes              *)

  VAR 
    x, h: OPL.Item; 
    L1, L2, L3: OPL.Label; 
    mode, num, i: INTEGER;
    txt:OPM.Name;
    nestingLevel:INTEGER;
  BEGIN
    IF proc # NIL THEN
      IF locSize > OPM.MaxInt THEN Err(E.LOCAL_VAR_TOO_LARGE); locSize:=0 END;
      mode:=proc^.mode;
      IF ~(mode IN {LProc, XProc, TProc, IProc, WProc, MODE_CDECLPROC}) THEN 
        OPM.CommentedErr(E.INTERNAL_MURKS,"Enter");
      END;
      IF mode = TProc THEN
        OPL.FixLinkAbs(proc^.adr MOD 10000H) (* fix all tables refering to the method to point to the current PC *)
      ELSE
        IF proc^.adr < 0 THEN OPL.FixLink(-proc^.adr) END; (* resolve forward calls *)
        IF proc^.linkadr > 0 THEN OPL.FixLinkAbs(proc^.linkadr) END;
        proc^.adr:=OPL.pc
      END;
      IF mode = LProc THEN
        IF (proc^.mnolev = 0) & proc^.leaf THEN nestingLevel:=0 ELSE nestingLevel:=proc^.mnolev + 1 END
      ELSE
        IF mode = IProc THEN nestingLevel:=0 ELSE nestingLevel:=1 END;
      END;
      OPL.BegProc(OPL.pc+1, locSize,nestingLevel);
      IF mode = LProc THEN
        IF (proc^.mnolev = 0) & proc^.leaf THEN
          EnterProc(mode, locSize, 0)      
        ELSE
          EnterProc(mode, locSize, proc^.mnolev + 1)
        END
      ELSE
        IF mode = IProc THEN
          EnterProc(mode, locSize, 0)      
        ELSE
          EnterProc(mode, locSize, 1);
          (* change+ 14.11.95 Rel. 1.18 for spelling warning for progmain,... *)
          IF mode = WProc THEN
            i:=0;
            WHILE proc^.name[i]#0X DO
              txt[i]:=CAP(proc^.name[i]);
              INC(i);
            END;
            txt[i]:=0X;
            IF (proc^.name = progMainProcName) OR
               (proc^.name = winMainProcName) OR
               (proc^.name = libMainProcName) THEN
              OPL.PutOD(4, 4, 068H, moduleKey); (* PUSH Id *)
              IF OPL.modInitAdr<0 THEN
                OPM.CommentedErr(E.INTERNAL_MURKS,"OPC.Enter");
              END;
              OPL.PutCallB(XProc,OPL.modInitAdr); (* call own module initialization *)
              IF proc^.name = libMainProcName THEN
                CallRtsInitDllModule;
              END;
            ELSIF txt=UpProgMainProcName THEN OPM.CommentedErr(E.PROGMAIN_SPELLING,proc^.name)
            ELSIF txt=UpWinMainProcName  THEN OPM.CommentedErr(E.WINMAIN_SPELLING,proc^.name)
            ELSIF txt=UpLibMainProcName  THEN OPM.CommentedErr(E.DLLENTRY_SPELLING,proc^.name)
            END;
          END
          (* change- *)
        END;                            
      END;
    ELSE                                (* enter module                       *)
      OPL.modInitAdr:=OPL.pc;
      OPL.BegProc(OPL.pc+1, 0, 0);
      EnterProc(WProc, 0, 0);
      OPL.PutW(0E3DBH); (* FINIT *)

      h.mode := MODE_ABS_RELOC; 
      h.seg.reg := DS; 
      h.adr := OPL.floatContrWord;
      h.reloc:=FIXUP_CONST;
      h.relocInx:=0;
      OPL.PutOM(2, 0D9H, 5H, h); (* FLDCW m2byte *)
      
      IF ~CB.rtsModule THEN (* no key for RTSOberon *)
        x.mode:=MODE_REGI;
        x.seg.reg:=SS; 
        x.bas.reg:=EBP; 
        x.disp:=8;
        L1:=0;
        OPL.PutOMD(4, 4, 081H, 7H, x, 0); (* CMP Ed,Id *)
        OPL.PutJmpCF(EQL, L1); (* check module key 0 = force no check *)
        OPL.PutOMD(4, 4, 081H, 7H, x, moduleKey); (* CMP Ed,Id *)
        OPL.PutJmpCF(EQL, L1); (* check module key *)
        CB.Trap(wrongModKeyTrap);
        OPL.FixLink(L1);
      END;
      x.mode:=MODE_ABS; 
      x.seg.reg:=DS; 
      x.adr:=modInitFlagAdr;
      OPL.PutOMD(1, 1, 080H, 7H, x, 0); (* CMP r/m8, imm8 -> CMP [moduleInitFlag],0 *)
      OPL.DefineFixup(FIXUP_CONST, 0, OPL.pc - 5);
      L1:=0;
      OPL.PutJmpCF(EQL, L1);
      LeaveProc(WProc, 4); (* module is already initialized *)
      OPL.FixLink(L1);
      OPL.PutOMD(1, 1, 0C6H, 0H, x, 1); (* MOV [moduleInitFlag],1(8) *)
      OPL.DefineFixup(FIXUP_CONST, 0, OPL.pc - 5);
      IF ~CB.rtsModule THEN (* no call to RTSOberon_$Init for module RTSOberon *)
        OPL.PutOD(4, 4, 068H, 0); (* PUSH Id *)
        OPL.PutDirCall(0);
        OPL.DefineFixup(FIXUP_CODE, rtsBodyInx, OPL.pc - 4);
        InitImportedModules;
      END;
      IF OPL.dsize >= OPM.MaxIndex THEN 
        Err(E.GLOBAL_VAR_TOO_LARGE)
      ELSIF OPL.dsize < 0 THEN 
        OPM.CommentedErr(E.INTERNAL_MURKS,"Enter2");
      END;
      IF ~CB.rtsModule THEN InitOwnModule END;
    END
  END Enter;

(*----------------------------------------------------------------------------*)
  PROCEDURE Result*(proc: OPT.Object; VAR res: OPL.Item);
    (* function:      code to return 'res' from a function *)
    (* precondition:  proc: procedure which finishes                          *)
    (*                res: value to be returned                         *)

  VAR 
    x: OPL.Item;
  BEGIN
    IF proc^.typ^.form IN realSet THEN
      CB.ValToFStk(res)
    ELSE
      CB.ValToThisReg(res, EAX);
(* split of 32 bit function return values not necessary any more      IF ((proc^.mode=WProc) OR (proc^.mode=CDeclProc)) & (res.typ^.size = 4) THEN
        x.mode:=Reg; OPL.GetThisReg(x.bas, edx);
        OPL.PutORM(4, 08BH, x.bas, res); (* MOV Gd,Ed *)
        OPL.PutOMD(4, 1, 0C1H, 5H, x, 16); (* SHR Ed,Ib *)
        OPL.ReleaseReg(x.bas)
      END *)
    END
  END Result;

(*----------------------------------------------------------------------------*)
  PROCEDURE Exit*(proc: OPT.Object);
    (* function:      code at exit-point of procedures and modules          *)
    (* precondition:  proc: procedure which finishes                          *)
  VAR 
    mode: INTEGER; 
    parSize: LONGINT; 
    seg, regA, regD: Reg.RegisterT;
  BEGIN
    IF proc = NIL THEN                  (* module                             *)
      IF CB.rtsModule THEN (* For the RTS module the registration of the module 
       has to be called AFTER the initialization block of the module executed so
       the RTS has a chance to initialize its global variables as needed BEFORE
       the first module (the RTS module itself) tries to become registered. *)
        InitOwnModule;
        InitImportedModules;
      END; 
      LeaveProc(WProc, 4);
      OPL.modBodyEnd:=OPL.pc;
      OPL.EndProc;
    ELSE
      mode:=proc^.mode;
      parSize:=proc^.conval^.intval;
      IF ODD(parSize) THEN 
        OPM.CommentedErr(E.INTERNAL_MURKS,"Exit");
      ELSIF parSize > OPM.MaxInt THEN 
        Err(E.PARAM_TOO_LARGE); 
        parSize:=0
      END;
      IF (mode = WProc) & (proc^.name = winMainProcName) THEN
        OPL.PutOD(4, 4, 068H, 0); (* PUSH imm32 *) (* !!! instead of 0 push offset of module descriptor in const area *)
        OPL.DefineFixup(FIXUP_CONST, 0, OPL.pc - 4); 
        OPL.PutDirCall(0);
        OPL.DefineFixup(FIXUP_CODE, rtsLeavingWinMainInx, OPL.pc - 4);
(*        seg.reg:=cs;
        OPL.GetThisReg(regA, EAX);
        OPL.GetThisReg(regD, edx);
        OPL.PutPushReg(4, regA);
        OPL.PutPushReg(4, regD);
        OPL.PutPushReg(2, seg);
        OPL.PutDirCall(0);
        OPL.DefineFixup(FIXUP_CODE, rtsLeavingWinMainInx, OPL.pc - 4);
        OPL.PutPopReg(4, regD);
        OPL.PutPopReg(4, regA);
        OPL.ReleaseReg(regD);
        OPL.ReleaseReg(regA); *)
      END;
      LeaveProc(mode, parSize);
      OPL.EndProc;
    END
  END Exit;

(*=================== implementation of module SYSTEM ========================*)

  PROCEDURE SYSmop*(VAR x: OPL.Item; subcl, f, g: SHORTINT);    (* implementation of SYSTEM.ADR, CC, VAL *)
  VAR 
    h:OPL.Item;
  BEGIN
    CASE subcl OF
      adr:
        CB.IgnoreDynArrDesc(x);  
        CB.LoadAdr(x);
        Reg.GetGenReg(h.bas);
        OPL.PutORM(4, 08DH, h.bas, x); (* LEA r32,m *)
        OPL.Release(x); 
        x.bas:=h.bas;
        x.seg.reg:=DS;
(*        x.seg.key:=freeReg;*)
        x.mode:=MODE_REG;
(* !C!      
        CB.IgnoreDynArrDesc(x);  
        CB.AdrToRegID0(x, -1);
        h.mode:=Reg;
        OPL.GetGenReg(h.bas);
        OPL.PutORM(2, 08CH, x.seg, h); (* MOV Ew,Sw *)
        OPL.PutOMD(4, 1, 0C1H, 4H, h, 16); (* SHL Ed,Ib *)
        OPL.PutORM(2, 089H, x.bas, h); (* MOV Ew,Gw *)
        OPL.Release(x); 
        x.bas:=h.bas;   
        x.mode:=MODE_REG; *)
        x.typ:=OPT.linttyp;
    | val:
    | cc: Err(E.SYSTEM_CC_UNSUPPORTED);
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"SYSmop");
    END
  END SYSmop;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE SysXOR*(VAR x,y: OPL.Item);
  BEGIN
    CB.ValToReg(x); x.typ:=OPT.linttyp;
    CB.ValToReg(y); y.typ:=OPT.linttyp;
    OPL.PutORM(4, 031H, y.bas, x);       (* XOR r/m32, r32 *)
    OPL.Release(y);
  END SysXOR;
  
  PROCEDURE SysAND*(VAR x,y: OPL.Item);
  BEGIN
    CB.ValToReg(x); x.typ:=OPT.linttyp;
    CB.ValToReg(y); y.typ:=OPT.linttyp;
    OPL.PutORM(4, 021H, y.bas, x);       (* AND r/m32, r32 *)
    OPL.Release(y);
  END SysAND;
  
  PROCEDURE SysOR*(VAR x,y: OPL.Item);
  BEGIN
    CB.ValToReg(x); x.typ:=OPT.linttyp;
    CB.ValToReg(y); y.typ:=OPT.linttyp;
    OPL.PutORM(4, 009H, y.bas, x);       (* OR  r/m32, r32 *)
    OPL.Release(y);
  END SysOR;
  
  PROCEDURE SysNOT*(VAR x: OPL.Item);
  BEGIN
    CB.ValToReg(x);  x.typ:=OPT.linttyp;
    OPL.PutOM(4, 0F7H, 002H, x);       (* NOT r/m32 *)
  END SysNOT;

  PROCEDURE SysHiWord*(VAR x: OPL.Item);
  VAR
    reg:Reg.RegisterT;
    h:INTEGER;
  BEGIN
    IF x.mode=MODE_CON THEN
      SYSTEM.GET(SYSTEM.ADR(x.adr)+2,h);
      x.adr:=h;
      x.typ:=OPT.inttyp;
    ELSE
      CB.LoadAdr(x);
      IF x.mode=MODE_REG THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"adr mode not implemented");
      ELSE
        INC(x.adr,2);
        INC(x.disp,2);
        Reg.GetGenReg(reg);
        OPL.PutORM(4, 00FB7H, reg, x); (* MOVZX r32, r/m16 *)
        OPL.Release(x);
        x.bas:=reg;
        x.mode:=MODE_REG;
        x.typ:=OPT.inttyp;
      END;
    END;
  END SysHiWord;
  
  PROCEDURE SysLoWord*(VAR x: OPL.Item);
  VAR
    reg:Reg.RegisterT;
    h:INTEGER;
  BEGIN
    IF x.mode=MODE_CON THEN
      SYSTEM.GET(SYSTEM.ADR(x.adr),h);
      x.adr:=h;
      x.typ:=OPT.inttyp;
    ELSE
      CB.LoadAdr(x);
      IF x.mode=MODE_REG THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"adr mode not implemented");
      ELSE
        Reg.GetGenReg(reg);
        OPL.PutORM(4, 00FB7H, reg, x); (* MOVZX r32, r/m16 *)
        OPL.Release(x);
        x.bas:=reg;
        x.mode:=MODE_REG;
        x.typ:=OPT.inttyp;
      END;
    END;
  END SysLoWord;
  
  PROCEDURE SysMkLong*(VAR x,y: OPL.Item);
  VAR
    reg:Reg.RegisterT;
    h:INTEGER;
  BEGIN
    IF (x.mode=MODE_CON) & (y.mode=MODE_CON) THEN (* both operands are constants *)
      SYSTEM.GET(SYSTEM.ADR(x.adr),h);
      x.adr:=y.adr;
      SYSTEM.PUT(SYSTEM.ADR(x.adr)+2,h);
      x.typ:=OPT.linttyp;
    ELSIF x.mode=MODE_CON THEN  (* hiword is a constant *)
      CB.LoadAdr(y);
      Reg.GetGenReg(reg);
      OPL.PutOD(2,2,0B8H+reg.reg, x.adr); (* MOV r16, imm16 *)
      x.bas:=reg;
      x.mode:=MODE_REG;
      x.typ:=OPT.linttyp;
      OPL.PutOMD(4,1,0C1H,004H, x, 010H); (* SHL r/m32, imm8 *)
      OPL.PutORM(2, 08BH, reg, y); (* MOV r16, r/m16 *)
      OPL.Release(y);
    ELSIF y.mode=MODE_CON THEN  (* loword is a constant *)
      CB.LoadAdr(x);
      Reg.GetGenReg(reg);
      OPL.PutORM(2, 08BH, reg, x); (* MOV r16, r/m16 *)
      OPL.Release(x);
      x.bas:=reg;
      x.mode:=MODE_REG;
      x.typ:=OPT.linttyp;
      OPL.PutOMD(4,1,0C1H,004H, x, 010H); (* SHL r/m32, imm8 *)
      OPL.PutOD(2,2,0B8H+x.bas.reg, y.adr); (* MOV r16, imm16 *)
    ELSE
      CB.LoadAdr(x);
      CB.LoadAdr(y);
      Reg.GetGenReg(reg);
      OPL.PutORM(2, 08BH, reg, x); (* MOV r16, r/m16 *)
      OPL.Release(x);
      x.bas:=reg;
      x.mode:=MODE_REG;
      x.typ:=OPT.linttyp;
      OPL.PutOMD(4,1,0C1H,004H, x, 010H); (* SHL r/m32, imm8 *)
      OPL.PutORM(2, 08BH, reg, y); (* MOV r16, r/m16 *)
      OPL.Release(y);
    END;
  END SysMkLong;
  
  PROCEDURE SYSdop*(VAR x, y: OPL.Item; subcl: SHORTINT);
      (* implementation of SYSTEM.BIT, LSH, ROT *)
  VAR 
    L1, L2: OPL.Label;
  BEGIN
    CASE subcl OF
      bit:
        (* function: x:=SYSTEM.BIT(x, y)    *)
        CB.LoadAdr(x);
        IF y.mode = MODE_CON THEN
          OPL.PutOMD(4, 1, 0FBAH, 4H, x, y.adr); (* BT Ed,Ib *)
        ELSE
          CB.ValToReg(y);
          OPL.PutORM(4, 0FA3H, y.bas, x); (* BT Ed,Gd *)
        END;
        OPL.Release(x);
        CB.SetCoc(x, CST)
    | lsh:
        (* function: x:=SYSTEM.LSH(x, y)   *)
        CB.ValToReg(x); x.typ:=OPT.linttyp;
        IF y.mode = MODE_CON THEN
          IF y.adr < 0 THEN OPL.PutOMD(4, 1, 0C1H, 5H, x, -y.adr) (* SHR Ed,Ib *)
          ELSIF y.adr > 0 THEN OPL.PutOMD(4, 1, 0C1H, 4H, x, y.adr) (* SHL Ed,Ib *)
          END
        ELSE
          CB.ValToThisReg(y, ECX);
          OPL.PutORM(4, 085H, y.bas, y); (* TEST Ed,Gd *)
          L1:=0; L2:=0;
          OPL.PutJmpCF(EQL, L2);
          OPL.PutJmpCF(GTR, L1);
          OPL.PutOM(4, 0F7H, 3H, y); (* NEG Ed *)
          OPL.PutOM(4, 0D3H, 5H, x); (* SHR Ed,CL *)
          OPL.PutJmpF(L2);
          OPL.FixLink(L1);
          OPL.PutOM(4, 0D3H, 4H, x); (* SHL Ed,CL *)
          OPL.FixLink(L2);
        END
    | rot:
        (* function: x:=SYSTEM.ROT(x, y)   *)
        CB.ValToByteReg(x);
        IF y.mode = MODE_CON THEN
          IF y.adr < 0 THEN
            IF x.typ^.size = 1 THEN OPL.PutOMD(1, 1, 0C0H, 1H, x, -y.adr) (* ROR Eb,Ib *)
            ELSE OPL.PutOMD(SHORT(x.typ^.size), 1, 0C1H, 1H, x, -y.adr) (* ROR Ev,Ib *)
            END
          ELSE
            IF x.typ^.size = 1 THEN OPL.PutOMD(1, 1, 0C0H, 0H, x, y.adr) (* ROL Eb,Ib *)
            ELSE OPL.PutOMD(SHORT(x.typ^.size), 1, 0C1H, 0H, x, y.adr) (* ROL Ev,Ib *)
            END
          END
        ELSE
          CB.ValToThisReg(y, ECX);
          OPL.PutORM(4, 085H, y.bas, y); (* TEST Ed,Gd *)
          L1:=0; L2:=0;
          OPL.PutJmpCF(EQL, L2);
          OPL.PutJmpCF(GTR, L1);
          OPL.PutOM(4, 0F7H, 3H, y); (* NEG Ed *)
          IF x.typ^.size = 1 THEN OPL.PutOM(1, 0D2H, 1H, x) (* ROR Eb,CL *)
          ELSE OPL.PutOM(SHORT(x.typ^.size), 0D3H, 1H, x) (* ROR Ev,CL *)
          END;
          OPL.PutJmpF(L2);
          OPL.FixLink(L1);
          IF x.typ^.size = 1 THEN OPL.PutOM(1, 0D2H, 0H, x) (* ROL Eb,CL *)
          ELSE OPL.PutOM(SHORT(x.typ^.size), 0D3H, 0H, x) (* ROL Ev,CL *)
          END;
          OPL.FixLink(L2);
        END
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"SYSdop");
    END
  END SYSdop;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE ValToAdr(VAR x: OPL.Item);
  (* convert the value in 'x' into a register indirect memory reference *)
  (* precondition:  x.mode IN {Var, VarPar, Con, FStk, Reg, Abs, RegI, RegX, Inx, Coc}*)
  (*                x.typ^.form IN {Byte, Bool, Char, SInt, Int, LInt, Set, Real, LReal}*)
  (* postcondition: x.mode=RegI *)
  VAR 
    h: OPL.Item;
  BEGIN
    CB.ValToReg(x);
    x.disp:=0;
    x.seg.reg:=DS;
(*    x.seg.key:=freeReg;*)
    x.mode:=MODE_REGI;
(* !C!    CB.ValToReg(x);
    OPL.GetGenReg(h.bas);
    OPL.PutORM(4,  0FB7H, h.bas, x); (* MOVZX Gd,Ew *)
    OPL.PutOMD(4, 1, 0C1H, 5H, x, 16); (* SHR Ed,Ib *)
    OPL.GetSegReg(x.seg);
    OPL.PutORM(2, 08EH, x.seg, x); (* MOV Sw,Ew *)
    OPL.ReleaseReg(x.bas);
    x.disp:=0;
    x.bas:=h.bas;
    x.mode:=RegI; *)
  END ValToAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE SYSgetput*(VAR x, y: OPL.Item; subcl: SHORTINT);
  (* x:=y *)
  (* implementation of SYSTEM.GET, PUT, GETREG, PUTREG *)
    VAR h: OPL.Item;
  BEGIN
    CASE subcl OF
      SYSTEM_GETFN:
        (* function: SYSTEM.GET(y, x) => x:=MEM[y] *)
        ValToAdr(y);
        CB.LoadAdr(x);
        y.typ:=x.typ;
        Assign(x, y);
    | SYSTEM_PUTFN:
        (* function: SYSTEM.PUT(x, y) => MEM[x]:=y *)
        ValToAdr(x);
        CB.LoadAdr(y);
        x.typ:=y.typ;
        Assign(x, y)
    | SYSTEM_GETRFN:
        (* function: SYSTEM.GETREG(x, y) => x:=REG[y] *)
        (* precondition:  y.mode = Con                                        *)
        h.mode:=MODE_REG;
        IF y.mode # MODE_CON THEN 
          OPM.CommentedErr(E.INTERNAL_MURKS,"SYSgetput");
        ELSE
          IF (EAX <= y.adr) & (y.adr <= EDI) THEN
            Reg.GetThisReg(h.bas, SHORT(y.adr));
          ELSIF (ES <= y.adr) & (y.adr <= GS) THEN
            Reg.GetGenReg(h.bas);
            CB.ClearReg(h.bas);
            OPL.PutOM(2, 08CH, SHORT(y.adr-8), h) (* MOV Ew,Sw *)
          ELSE
            Err(E.REGISTER_UNREADABLE)
          END;
          h.typ:=OPT.linttyp;
          Assign(x, h);
          OPL.Release(h)
        END
    | SYSTEM_PUTRFN:
        (* function: SYSTEM.PUTREG(x, y) => REG[x]:=y *)
        (* precondition:  x.mode = Con                                        *)
        IF x.mode # MODE_CON THEN 
          OPM.CommentedErr(E.INTERNAL_MURKS,"SYSgetput2");
        ELSIF x.adr IN Reg.REGS THEN
          IF (EAX <= x.adr) & (x.adr <= EDI) THEN
            CB.ValToThisReg(y, SHORT(x.adr))
          ELSE
            CB.ValToReg(y);
            OPL.PutOM(2, 08EH, SHORT(x.adr-8), y) (* MOV Sw,Ew *)
          END
        ELSE
          Err(E.READ_ONLY_REGISTER)
        END
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"SYSgetput3");
    END
  END SYSgetput;

(*----------------------------------------------------------------------------*)
  PROCEDURE SYSmove*(VAR x, y, z: OPL.Item);
    (* x^:=z bytes at y *)
    (* implementation of SYSTEM.MOVE *)
    (* function:      x:=z bytes of y                                       *)
    (* precondition:                                                          *)
    (* postcondition:                                                         *)

  BEGIN
    ValToAdr(x);
    ValToAdr(y);
    CB.MoveBlock(x, y, z)
  END SYSmove;

(*----------------------------------------------------------------------------*)
  PROCEDURE SYSnew*(VAR x, y: OPL.Item);
    (* assign addr of an y byte block to x *)
    (* implementation of SYSTEM.NEW *)
    (* function:      allocate a new block of memory from heap                *)
    (* precondition:  x = address, where address of new block is stored       *)
    (*                y = size of new block in bytes                          *)

    VAR h: OPL.Item;
  BEGIN
    IF y.mode = MODE_CON THEN
      IF CB.ptrinit THEN
        OPL.PutOD(4, 4, 068H, -y.adr) (* PUSH Id *)
      ELSE
        OPL.PutOD(4, 4, 068H, y.adr) (* PUSH Id *)
      END
    ELSE
      CB.ValToReg(y);
      IF CB.ptrinit THEN
        OPL.PutOM(4, 0F7H, 3H, y); (* NEG Ed *)
      END;
      OPL.PutOM(4, 0FFH, 6H, y); (* PUSH Ed *)
      OPL.Release(y)
    END;
    CB.PushAdr(x);
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsSysNewInx, OPL.pc - 4);
  END SYSnew;

(*============================================================================*)

BEGIN
  relToCoc[eql]:=EQL;
  relToCoc[neq]:=NEQ;
  relToCoc[lss]:=LSS;
  relToCoc[leq]:=LEQ;
  relToCoc[gtr]:=GTR;
  relToCoc[geq]:=GEQ;
END OPC.
