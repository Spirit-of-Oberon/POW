(******************************************************************************)
(*                                                                            *)
(**)                    MODULE OPC_Base;                                    (**)
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
(* PURPOSE: Basic components of high level code generator                     *)
(*                                                                            *)
(******************************************************************************)


  IMPORT
    OPT, OPL, OPM, E:=Error, Coff, Debug, S:=String, Reg:=Register;

  CONST
    (* compiler options *)
    indexCheck* = 0; 
    overflowCheck* = 1; 
    rangeCheck*  = 2; 
    typeCheck* = 3;
    newSymFile*    = 4;  
    pointerInit* = 5;    (* initialize pointers to NIL *)
    assertEval*=6;       (* ASSERT() evaluation *)
    debugInfo*=7;        (* add debug information to .obj file *)
    listImport*=8;       (* report all imported modules *)
    browseSymFile* = 9;  (* reports all exported entities of a module *)
(*    smartCallback* = 10; (* smart call-back prolog code *) *)
    nilCheck*   = 11;    (* check for a nil pointer before dereferencing *)
    OPTN_CODEVIEW4*=12;   (* generate CodeView 4.0 compatible debug symbols *)
    OPTN_CODEVIEW5*=13;   (* generate CodeView 5.0 compatible debug symbols *)

(*    (* index in symbol table of runtime system routines                            *)
    rtsHaltInx*           = 6; *)
  
    (* fixup types                                                            *)
    FIXUP_CODE=OPL.FIXUP_CODE;
    FIXUP_DATA=OPL.FIXUP_DATA;
(*    FIXUP_VIRTREGISTER=OPL.FIXUP_VIRTREGISTER;*)
    FIXUP_MODENTRY=OPL.FIXUP_MODENTRY;
    FIXUP_CONST=OPL.FIXUP_CONST;
    FIXUP_MOD_DESC_OFF=OPL.FIXUP_MOD_DESC_OFF;
(*    FIXUP_DATA_SECTION=OPL.FIXUP_DATA_SECTION;*)
    
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
(*    noReg  = OPL.noReg;
    freeReg= OPL.freeReg; *)

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

    (* item modes for 80386 (must not overlap item basemodes,  > 15)          *)
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
    MODE_REGX_RELOC=OPL.MODE_REGX_RELOC;
    MODE_REGI_RELOC=OPL.MODE_REGI_RELOC;
    MODE_INX_RELOC=OPL.MODE_INX_RELOC;

    (* structure forms                                                        *)
    Undef* = 0; Byte* = 1; Bool* = 2; Char* = 3; SInt* = 4; Int* = 5; LInt* = 6;
    Real* = 7; LReal* = 8; Set* = 9; String* = 10; NilTyp* = 11; NoTyp* = 12;
    Pointer* = 13; ProcTyp* = 14; Comp* = 15;
    intSet* = {SInt..LInt}; realSet* = {Real, LReal};
  
    (* composite structure forms                                              *)
    Basic* = 1; Array* = 2; DynArr* = 3; Record* = 4;

    (* condition, 80386                                                       *)
    CST* = 2; CCL* = 3; EQL* = 4; NEQ* = 5; LSS* = 12; GEQ* = 13; LEQ* = 14; GTR* = 15;
    ULSS* = 2; UGEQ* = 3; ULEQ* = 6; UGTR* = 7; ALWAYS* = 16; NEVER* = 17;

    progMainProcName = "ProgMain";
    winMainProcName = "WinMain";
    libMainProcName = "LibMain";

    (* software interrupts, 80386                                             *)
    rangeTrap*        = -1;
    indexTrap*        = -2;
    ovflTrap*         = -3;
    guardTrap*        = -4;
    wrongModKeyTrap*  = -5;
    wrongDefFileTrap* = -6;
    nilTrap*          = -11;

    
    maxFloatStackUsage = 8;

    false = 0; true = 1; nil = 0;
    
(*    floatBegin = OPL.floatBegin;*)
    
  VAR
    rtsModule-, inxchk-, ovfchk-, ranchk-, typchk-, nilchk-, ptrinit-(*, smartcallback-*): BOOLEAN;
    
    (* index in symbol table of runtime system routines                            *)
    rtsHaltInx-:LONGINT;

      
(*----------------------------------------------------------------------------*)
  PROCEDURE ^ DeRef*(VAR x: OPL.Item);
  PROCEDURE ^ DeRefToThisReg*(VAR x: OPL.Item; targetReg:INTEGER);

(*----------------------------------------------------------------------------*)
  PROCEDURE ^ Index*(VAR x, y: OPL.Item); 

(*----------------------------------------------------------------------------*)
  PROCEDURE ^ Trap*(n: LONGINT); 
    
(*=================== E X P O R T E D : G E N E R A L - P R O C E D U R E S ==*)

  PROCEDURE Init*(isRtsModule:BOOLEAN; options: SET);
    (* function:      initialization of module                                *)
    (* precondition:  inx = index check for arrays                            *)
    (*                ovf = overflow check for arithmetic                     *)
    (*                ran = range check of data-types                         *)
    (*                typ = type check for record and pointer types           *)
    (* postcondition: module is initialized                                   *)

  BEGIN
    rtsModule := isRtsModule;
    inxchk := indexCheck IN options; 
    ovfchk := overflowCheck IN options; 
    ranchk := rangeCheck IN options; 
    typchk := typeCheck IN options;
    nilchk := nilCheck IN options;
    ptrinit := pointerInit IN options;
(*    smartcallback:= smartCallback IN options;*)
(*    IF ~rtsModule THEN*)
      Coff.AddRtsProc("Halt",rtsHaltInx);
(*    ELSE
      rtsHaltInx:=-1;
    END;*)
  END Init;

(*=================== I N T E R N A L : G E N E R A L - P R O C E D U R E S ==*)

    (* function:      generate an error message                               *)
    (* precondition:  n is the error number                                   *)
    (* postcondition: error message has been written to file                  *)
  PROCEDURE Err(code:INTEGER);
  BEGIN
    OPM.Err(code)
  END Err;

(*
(*----------------------------------------------------------------------------*)
  PROCEDURE IncFSP*;
    (* function:      floating point stack pointer is incremented             *)

  BEGIN
    OPL.IncFSP;
  END IncFSP;

(*----------------------------------------------------------------------------*)
  PROCEDURE DecFSP*;
    (* function:      floating point stack pointer is decremented             *)

  BEGIN
    OPL.DecFSP;
  END DecFSP;
  *)
(*=================== I N T E R N A L : I T E M   T R A N S F E R S ==========*)

  PROCEDURE ClearReg*(reg: Reg.RegisterT);
    (* function:      erase CPU-register                                      *)
    (* precondition:  reg: a correct register                                 *)
    (* postcondition: VALUE(reg) = 0                                          *)

    VAR h: OPL.Item;
  BEGIN
    h.mode := MODE_REG; h.bas := reg;
    OPL.PutORM(4, 031H, h.bas, h) (* XOR Ed,Gd *)
  END ClearReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE CocToReg*(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = Coc                                            *)
    (* postcondition: x.mode = Reg                                            *)

    VAR L1: OPL.Label;
  BEGIN
    L1 := 0;
    Reg.GetByteReg(x.bas); x.mode := MODE_REG;
    OPL.PutJmpCF(x.seg.reg, x.adr);     (* Tjmp                               *)
    OPL.FixLink(x.disp);                (* Fjmp here                          *)
    OPL.PutOMD(4, 4, 0C7H, 0H, x, false); (* MOV Ed,Id *)
    OPL.PutJmpF(L1);
    OPL.FixLink(x.adr);                 (* Tjmp here                          *)
    OPL.PutOMD(4, 4, 0C7H, 0H, x, true); (* MOV Ed,Id *)
    OPL.FixLink(L1)
  END CocToReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE IncAdr*(VAR x: OPL.Item; offset: LONGINT);
    (* function:      increment address of item                               *)
    (* precondition:  x.mode IN {Abs, RegI, RegX, Inx}                        *)
    (*                offset: number of bytes to increment                    *)
    (* postcondition: x.mode IN {Abs, RegI, RegX, Inx}                        *)

  BEGIN
    IF (x.mode = MODE_ABS) OR (x.mode=MODE_ABS_RELOC) THEN 
      INC(x.adr, offset)
    ELSE 
      INC(x.disp, offset)
    END
  END IncAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadBaseAdr*(VAR x: OPL.Item);
    (* function:      load base-address on stack                              *)
    (* precondition:  x.mode IN {Var, VarPar, DArr}, 0 < x.mnolev <= OPL.level      *)
    (* postcondition: x.mode = RegI, x is base-address on stack               *)
  VAR 
    y: OPL.Item;
  BEGIN
    IF x.mnolev = OPL.level THEN        (* local variable is in own SS        *)
      x.bas.reg := EBP;
    ELSE                                (* access over static link            *)
      y.mode := MODE_REGI; 
      y.seg.reg := SS; 
      y.bas.reg := EBP;
      y.disp := - 4 * x.mnolev; (* !C! was -2* *)
      Reg.GetGenReg(x.bas);
(* !C!       OPL.PutORM(4,  0FB7H, x.bas, y); (* MOVZX Gd,Ew *) *)
      OPL.PutORM(4, 08BH, x.bas, y); (* MOV r32, r/m32 *)
    END;
    x.mode := MODE_REGI; 
    x.seg.reg := SS; 
    x.disp := x.adr;
  END LoadBaseAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE VarParToRegI(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = VarPar                                         *)
    (* postcondition: x.mode = RegI                                           *)

  BEGIN
    LoadBaseAdr(x);
    IF x.typ^.comp = Record THEN IncAdr(x, 4) END;(* jump over typtag         *)
    DeRef(x)
  END VarParToRegI;

(*----------------------------------------------------------------------------*)

  PROCEDURE VarParToThisRegI(VAR x: OPL.Item; targetReg:INTEGER);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = VarPar                                         *)
    (* postcondition: x.mode = RegI                                           *)

  BEGIN
    LoadBaseAdr(x);
    IF x.typ^.comp = Record THEN IncAdr(x, 4) END;(* jump over typtag         *)
    DeRefToThisReg(x,targetReg)
  END VarParToThisRegI;

(*----------------------------------------------------------------------------*)
  PROCEDURE VarToAdr(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = Var, DLLVAR                                    *)
    (* postcondition: x.mode IN {RegI, Abs, MODE_ABS_RELOC}                   *)

  VAR 
    y: OPL.Item; 
    L1, L2: OPL.Label;
  BEGIN
    IF x.mnolev < 0 THEN                (* imported variable from another module *)
 (*!C!*)
      IF (x.mode=MODE_DLLVAR) THEN        (* global variable imported from another DLL *)
        y.mode := MODE_ABS_RELOC; 
        y.seg.reg:=DS;
        y.reloc:=FIXUP_DATA;
        y.relocInx:=-x.mnolev;
        y.adr:=2;
        x.mode := MODE_REGI; 
        x.seg.reg := DS; 
(*        x.disp:=x.adr;*)
        Reg.GetGenReg(x.bas);
        OPL.PutORM(4, 08BH, x.bas, y); (* MOV r32, r/m32 *)
(*        x.disp:=0;
        OPL.PutORM(4, 08BH, x.bas, x); (* MOV r32, r/m32 *) *)
        x.disp:=x.adr;
      ELSE                      (* global variable from module within the same executable image *)
        x.mode := MODE_ABS_RELOC; 
        x.disp := 0; 
        x.seg.reg:=DS;
        x.reloc:=FIXUP_DATA;
        x.relocInx:=-x.mnolev;
      END;
(*      
      L1 := 0; L2 := 0;
      y.mode := Reg;
      OPL.GetSegReg(y.seg);
      OPL.GetGenReg(y.bas);
      OPL.PutOMD(4, 4, 0C7H, 0H, y, 0); (* MOV Ed,Id *)
      OPL.DefineFixup(FIXUP_MODENTRY, -x.mnolev, OPL.pc - 4);
(* !C!       OPL.DefineFixup(fixupModEntryPtr, -x.mnolev, OPL.pc - 4);*)
      OPL.PutOMD(4, 1, 0C1H, 0H, y, 16); (* ROL Ed,Ib *)
      OPL.PutORM(2, 08EH, y.seg, y); (* MOV Sw,Ew *)
      OPL.PutOMD(4, 1, 0C1H, 0H, y, 16); (* ROL Ed,Ib *)
      OPL.PutORM(4, 0FB7H, y.bas, y); (* MOVZX Gd,Ew *)
      y.mode := RegI; y.disp := 0;
      OPL.PutOMD(1, 1, 080H, 7H, y, 0B8H); (* CMP Eb,Ib *)
      OPL.PutJmpCF(EQL, L1);
      y.mode := Reg; x.seg.reg := ds;
      OPL.PutORM(2, 08CH, x.seg, y); (* MOV Ew,Sw *) (* segment *)
      OPL.PutORM(2, 08EH, y.seg, y); (* MOV Sw,Ew *) (* Segment *)
      OPL.PutJmpF(L2);

      OPL.FixLink(L1);
      y.mode := Reg;
      OPL.PutOM(4, 0FFH, 0H, y); (* INC Ed *)
      y.mode := RegI;
      OPL.PutORM(2, 08EH, y.seg, y); (* MOV Sw,Ew *) (* Segment *)
      
      OPL.FixLink(L2);
      OPL.ReleaseReg(y.bas);
      y.mode := Abs; y.adr := 0;
      OPL.PutORM(2, 08EH, y.seg, y); (* MOV Sw,Ew *) (* Segment *)
(*      OPL.DefineFixup(fixupGSOff, -x.mnolev, OPL.pc - 4);*)
      x.mode := Abs; x.disp := 0; x.seg := y.seg;  *)
    ELSIF x.mnolev = 0 THEN             (* global variable in own data section*)
      x.mode := MODE_ABS_RELOC; 
      x.disp := 0; 
      x.seg.reg:=DS;
      x.reloc:=FIXUP_DATA;
      x.relocInx:=0; 

(*      x.mode := Abs; x.disp := 0; x.seg.reg := gs; *)
    ELSE                                (* local variable on stack            *)
      LoadBaseAdr(x);
      IF x.typ^.comp = DynArr THEN DeRef(x) END
    END
  END VarToAdr;

(*----------------------------------------------------------------------------*)
(*  PROCEDURE AbsToRegI(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = Abs                                            *)
    (* postcondition: x.mode = RegI                                           *)

  BEGIN
    OPL.GetGenReg(x.bas); x.mode := Reg;
    OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Id *)
    x.mode := RegI; x.disp := 0
  END AbsToRegI; *)

(*----------------------------------------------------------------------------*)
  PROCEDURE VarToRegI(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = Var, DLLVAR                                    *)
    (* postcondition: x.mode = RegI                                           *)

  BEGIN
    VarToAdr(x);
    IF x.mode = MODE_ABS THEN
      Reg.GetGenReg(x.bas); x.mode := MODE_REG;
      OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Id *)
      x.mode := MODE_REGI; 
      x.disp := 0;
    ELSIF x.mode=MODE_ABS_RELOC THEN 
      Reg.GetGenReg(x.bas); x.mode := MODE_REG;
      OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Id *)
      OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4);
      x.mode := MODE_REGI; 
      x.disp := 0;
    END;
    IF x.mode#MODE_REGI THEN
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"postcondition violated in OPC_Base.VarToRegI");
    END;
  END VarToRegI;

(*----------------------------------------------------------------------------*)
  PROCEDURE DArrToAdr(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode = DArr                                           *)
    (* postcondition: x.mode IN {RegI, RegX}                                  *)

  VAR 
    h: OPL.Item;
  BEGIN
    h.mode := MODE_CON; 
    h.adr := 0;
    h.mnolev:=0; (* !C! *)
    WHILE x.mode = DArr DO Index(x, h) END
  END DArrToAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE IgnoreDynArrDesc*(VAR x: OPL.Item);
    (* function:      gets the start address for data of a dynamic array      *)

  BEGIN
    IF ((x.mode = MODE_REGI) OR (x.mode=MODE_REGI_RELOC)) & 
       (x.disp = 0) & 
       (x.typ^.comp = DynArr) THEN
      x.disp := x.typ^.size
    END
  END IgnoreDynArrDesc;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadAdr*(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode IN {Var, VarPar, StrCon, Abs, Reg, RegI, RegX, Inx, DArr, FSTK}*)
    (* postcondition: x.mode IN {Abs, Reg, RegI, RegX, Inx, MODE_CON (but no strings), FSTK }   *)
  VAR
    txt:ARRAY 50 OF CHAR;
  BEGIN
    (* !!! remove pre- and postconditions checks for speed *)
    IF (x.mode#MODE_REG) &
       (x.mode#MODE_REGI) &
       (x.mode#MODE_INX) &
       (x.mode#MODE_REGX) &
       (x.mode#MODE_ABS) &
       (x.mode#MODE_REGI_RELOC) &
       (x.mode#MODE_INX_RELOC) &
       (x.mode#MODE_REGX_RELOC) &
       (x.mode#MODE_ABS_RELOC) &
       (x.mode#MODE_DLLVAR) &
       (x.mode#MODE_VAR) &
       (x.mode#VarPar) &
       (x.mode#MODE_FSTK) &
       (x.mode#MODE_CON) &
       (x.mode#DArr) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"OPC_Base.LoadAdr precond");
    END;
    IF x.mode = VarPar THEN VarParToRegI(x)
    ELSIF (x.mode = MODE_VAR) OR (x.mode=MODE_DLLVAR) THEN VarToAdr(x)
    ELSIF x.mode = DArr THEN DArrToAdr(x)
    ELSIF (x.mode = MODE_CON) & (x.typ^.form IN ({String} + realSet)) THEN
(*      x.mode := MODE_ABS; x.seg.reg := cs*)
      x.disp := 0;           (* !C! *)
      x.seg.reg:=DS;
      x.reloc:=FIXUP_CONST;
      x.relocInx:=-x.mnolev;
      IF (x.relocInx<0) OR (x.relocInx>=OPT.MAXIMPS) THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.LoadAdr");
      END;
      x.mode:=MODE_ABS_RELOC; 
    END;
    IF (x.mode#MODE_REG) &
       (x.mode#MODE_REGI) &
       (x.mode#MODE_INX) &
       (x.mode#MODE_REGX) &
       (x.mode#MODE_ABS) &
       (x.mode#MODE_FSTK) &
       (x.mode#MODE_REGI_RELOC) &
       (x.mode#MODE_INX_RELOC) &
       (x.mode#MODE_REGX_RELOC) &
       (x.mode#MODE_CON) &
       (x.mode#MODE_ABS_RELOC) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"OPC_Base.LoadAdr postcond");
      S.Str(x.mode,txt);
      S.Insert("item mode ",txt,1);
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,txt);
    END;
  END LoadAdr;

(*----------------------------------------------------------------------------*)
  PROCEDURE AdrToRegI*(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode IN {Var, VarPar, StrCon, Abs, RegI, RegX, Inx, DArr}*)
    (* postcondition: x.mode = RegI,MODE_REGI_RELOC                              *)

  VAR 
    y: OPL.Item;
  BEGIN
    IF (x.mode # MODE_REGI) & (x.mode # MODE_REGI_RELOC) THEN
      IF x.mode = VarPar THEN VarParToRegI(x)
      ELSIF (x.mode = MODE_VAR) OR (x.mode=MODE_DLLVAR) THEN VarToRegI(x)
      ELSE
        IF x.mode = DArr THEN DArrToAdr(x)
        ELSIF (x.mode = MODE_CON) & (x.typ^.form IN ({String} + realSet)) THEN
(*          x.mode := MODE_ABS; x.seg.reg := cs !C! *)
          x.mode := MODE_ABS_RELOC;   (* ??? *)
          x.seg.reg := DS;
          x.reloc:=FIXUP_CONST;
          x.relocInx:=-x.mnolev; 
          IF (x.relocInx<0) OR (x.relocInx>=OPT.MAXIMPS) THEN
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToRegI 1");
          END;
        END;
        CASE x.mode OF
          MODE_ABS:
            x.mode := MODE_REG; 
            Reg.GetGenReg(x.bas);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Imm32 *)
            x.disp := 0;
            x.mode := MODE_REGI;
        | MODE_ABS_RELOC:
            x.mode := MODE_REG; 
            Reg.GetGenReg(x.bas);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Imm32 *)
            OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4);
            x.disp := 0;
            x.mode := MODE_REGI;
        | MODE_REGI_RELOC,
          MODE_REGI:
        | MODE_REGX_RELOC,
          MODE_REGX:
            IF x.bas.reg IN {ESP, EBP} THEN 
              Reg.GetGenReg(y.bas);
            ELSE
              y.bas := x.bas
            END;
            OPL.PutORM(4, 08DH, y.bas, x); (* LEA Gd,M *)
            Reg.ReleaseReg(x.inx);
            x.bas := y.bas; 
            x.disp := 0;
            x.mode := MODE_REGI;
        | MODE_INX_RELOC,
          MODE_INX:
            OPL.PutORM(4, 08DH, x.inx, x); (* LEA Gd,M *)
            x.bas := x.inx; 
            x.disp := 0;
            x.mode := MODE_REGI;
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToRegI 2");
        END;
      END
    END
  END AdrToRegI;

(*----------------------------------------------------------------------------*)
  PROCEDURE AdrToThisRegI*(VAR x: OPL.Item; targetReg:INTEGER);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode IN {Var, VarPar, StrCon, Abs, RegI, RegX, Inx, DArr},*)
    (*                targetReg is a valid register                             *)
    (* postcondition: x.mode = RegI, x.bas=targetReg                            *)

  VAR 
    y: OPL.Item;
  BEGIN
    IF (x.mode # MODE_REGI) & (x.mode # MODE_REGI_RELOC) THEN
      IF x.mode = VarPar THEN 
        VarParToThisRegI(x,targetReg);
      ELSIF (x.mode = MODE_VAR) OR (x.mode=MODE_DLLVAR) THEN 
        VarToRegI(x);
        Reg.MoveToThisReg(x.bas, targetReg);
      ELSE
        IF x.mode = DArr THEN 
          DArrToAdr(x);
        ELSIF (x.mode = MODE_CON) & (x.typ^.form IN ({String} + realSet)) THEN
          x.mode := MODE_ABS_RELOC; 
          x.seg.reg := DS;
          x.reloc:=FIXUP_CONST;
          x.relocInx:=-x.mnolev; 
          IF (x.relocInx<0) OR (x.relocInx>=OPT.MAXIMPS) THEN
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToThisRegI");
          END;
        END;
        CASE x.mode OF
          MODE_ABS:
            x.mode := MODE_REG; 
            Reg.GetThisReg(x.bas,targetReg);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Imm32 *)
            x.disp := 0;
        | MODE_ABS_RELOC:
            x.mode := MODE_REG; 
            Reg.GetThisReg(x.bas,targetReg);
            OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr); (* MOV Ed,Imm32 *)
            OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4);
            x.disp := 0;
        | MODE_REGX_RELOC,
          MODE_REGX:
            IF x.bas.reg IN {ESP, EBP} THEN 
              Reg.GetThisReg(y.bas,targetReg); (* ??? *)
            ELSE
              IF x.bas.reg#targetReg THEN
                OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToThisRegI 1");
              END;
            END;
            OPL.PutORM(4, 08DH, y.bas, x); (* LEA Gd,M *)
            Reg.ReleaseReg(x.inx);
            x.bas:=y.bas;
            x.disp := 0;
        | MODE_INX_RELOC,
          MODE_INX:
            OPL.PutORM(4, 08DH, x.inx, x); (* LEA Gd,M *)
            x.bas := x.inx; x.disp := 0;
            Reg.MoveToThisReg(x.bas, targetReg);
        ELSE 
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToThisRegI 2");
        END;
        x.mode := MODE_REGI;
      END
    ELSE
      IF x.bas.reg#targetReg THEN 
        IF x.disp#0 THEN
          IF x.bas.reg IN {ESP, EBP} THEN 
            Reg.GetThisReg(y.bas, targetReg);
            OPL.PutORM(4, 08DH, y.bas, x); (* LEA r32,m *)
          ELSE
            y.bas := x.bas;
            OPL.PutOMD(4, 4, 081H, 0H, y, x.disp); (* ADD Ed,Id *)
            Reg.MoveToThisReg(x.bas, targetReg);
          END;
          x.disp:=0;
        ELSE
          Reg.MoveToThisReg(x.bas, targetReg);
        END;
      END;
    END
  END AdrToThisRegI;

(*----------------------------------------------------------------------------*)
  PROCEDURE AdrToRegID0*(VAR x: OPL.Item; baseReg: INTEGER);
    (* precondition:  x.mode IN {Var, VarPar, StrCon, Abs, RegI, RegX, Inx, DArr}*)
    (* postcondition: x.mode = RegI, x.disp = 0                               *)
    (*                        IF baseReg >= 0 THEN x.bas.reg = 'baseReg'  *)
    (*                        ELSE x.bas.reg = a general register *)

  VAR 
    y: OPL.Item;
  BEGIN
    AdrToRegI(x); 
(* !!! enhance !!!    IF baseReg>=0 THEN AdrToThisRegI(x,baseReg) ELSE AdrToRegI(x) END; *)
    IF x.disp # 0 THEN
      y.mode := MODE_REG;
      IF x.bas.reg IN {ESP, EBP} THEN 
        IF baseReg < 0 THEN 
          Reg.GetGenReg(y.bas)
        ELSE 
          Reg.GetThisReg(y.bas, baseReg)
        END;
(* !C!       OPL.PutORM(4, 089H, x.bas, y) (* MOV Ed,Gd *)*) 
        OPL.PutORM(4, 08DH, y.bas, x); (* LEA r32,m *)
      ELSE
        y.bas := x.bas;
        OPL.PutOMD(4, 4, 081H, 0H, y, x.disp); (* ADD r/m32, imm32 *)
        IF x.mode=MODE_REGI_RELOC THEN OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4) END;
      END;
      x.bas := y.bas
    ELSIF x.mode=MODE_REGI_RELOC THEN
      y.mode:=MODE_REG;
      y.bas:=x.bas;
      OPL.PutOMD(4, 4, 081H, 0H, y, 0); (* ADD r/m32, imm32 *)
      OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4);
    END;
    IF baseReg>=0 THEN Reg.MoveToThisReg(x.bas, baseReg) END; (* !!! remove later *)
    x.mode := MODE_REGI; 
    x.disp := 0;
    IF (baseReg>=0) & (x.bas.reg#baseReg) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.AdrToRegId0");
    END;
  END AdrToRegID0;

(*----------------------------------------------------------------------------*)
  PROCEDURE ^ ValToReg*(VAR x: OPL.Item);

(*----------------------------------------------------------------------------*)
  PROCEDURE ValToFStk*(VAR x: OPL.Item);
    (* function:      load value of 'x' to floating-point-stack               *)
    (* precondition:  x.mode IN {Var, VarPar, Con, Reg, Abs, RegI, RegX, Inx, FStk}*)
    (*                x.typ^.form IN {Byte, Bool, Char, SInt, Int, LInt, Set, Real, LReal}*)
    (* postcondition: x.mode = FStk                                           *)
  VAR 
    form: INTEGER; 
    dsAbs: BOOLEAN;
    inx:INTEGER;
    y:OPL.Item;
  BEGIN
    IF x.mode # MODE_FSTK THEN
      form := x.typ^.form;
      IF x.mode = MODE_CON THEN
        IF form IN realSet THEN 
          x.mode := MODE_ABS_RELOC; 
          x.seg.reg := DS;
          x.reloc:=FIXUP_CONST;
          x.relocInx:=0;
        ELSE 
          ValToReg(x);
        END
      ELSIF ~(form IN realSet) THEN 
        ValToReg(x);
      ELSE 
        LoadAdr(x);
      END;                              (* x.mode IN {Abs, Reg, RegI, RegX, Inx}*)
      dsAbs := x.mode = MODE_REG;
      IF dsAbs THEN
        Reg.AllocFloatMemReg(100,inx);
        form := LInt;
        y.mode:=MODE_REGI;
        y.disp := -OPL.virtRegOffs-4*inx-8;
        y.seg.reg := SS;
        y.bas.reg := EBP;
        OPL.PutORM(4, 089H, x.bas, y); (* MOV r/m32, r32 *)
        Reg.ReleaseReg(x.bas);
        x:=y;
      END;                              (* x.mode IN {Abs, RegI, RegX, Inx}*)
      Reg.IncFSP; 
      IF form = LInt THEN 
        OPL.PutOM(4, 0DBH, 0H, x); (* FILD Ed *)
      ELSIF form = Real THEN 
        OPL.PutOM(4, 0D9H, 0H, x); (* FLD Es *)
      ELSE 
        OPL.PutOM(4, 0DDH, 0H, x); (* FLD El *)
      END;
      IF dsAbs THEN 
        Reg.ReleaseMemReg(inx);
        Reg.ReleaseMemReg(inx+1);
        Reg.ReleaseMemReg(inx+2);
      END;
      OPL.PutB(09BH); (* WAIT *)
      OPL.Release(x);
      x.mode := MODE_FSTK;
    END
  END ValToFStk;

(*----------------------------------------------------------------------------*)
  PROCEDURE ValToReg*(VAR x: OPL.Item);
    (* function:      load value of 'x' in cpu-register                       *)
    (* precondition:  x.mode IN {Var, VarPar, Con, FStk, Reg, Abs, RegI, RegX, Inx, Coc}*)
    (*                x.typ^.form IN {Byte, Bool, Char, SInt, Int, LInt, Set, Real, LReal}*)
    (* postcondition: x.mode = Reg                                            *)

  VAR 
    form: INTEGER; 
    size: LONGINT; 
    y, h: OPL.Item;
    memReg:INTEGER;
  BEGIN
    IF x.mode # MODE_REG THEN
      IF x.typ^.form IN realSet THEN ValToFStk(x) END;
      IF x.mode = MODE_CON THEN
        Reg.GetGenReg(x.bas); 
        x.mode := MODE_REG;
        OPL.PutOMD(4, 4, 0C7H, 0H, x, x.adr) (* MOV r/m32,imm32 !!!! reloc missing ??? *)
      ELSIF x.mode = Coc THEN
        CocToReg(x)
      ELSIF x.mode = MODE_FSTK THEN
(* !!!! not yet ported to new virtual registers !!!        h.mode := MODE_ABS_RELOC; 
        h.seg.reg := DS; 
        h.adr := OPL.floatContrWord;
        h.reloc:=FIXUP_VIRTREGISTER;
        h.relocInx:=0;
        OPL.PutOM(2, 0D9H, 5H, h); (* FLDCW Ew *)  *)
        Reg.AllocMemReg(memReg);
        h.mode := MODE_REGI; 
        h.disp := -OPL.virtRegOffs-4*memReg; 
        h.seg.reg := SS;
        h.bas.reg := EBP;
        Reg.DecFSP; 
        OPL.PutOM(4, 0DBH, 3H, h); (* FISTP Ed *)
        OPL.PutB(09BH); (* WAIT *)
        Reg.GetGenReg(x.bas);
        OPL.PutORM(4, 08BH, x.bas, h); (* MOV r32, r/m32 *)
        Reg.ReleaseMemReg(memReg);
        x.mode := MODE_REG;
        x.typ := OPT.linttyp
      ELSE
        LoadAdr(x);
        y.mode := MODE_REG; 
        form := x.typ^.form; 
        size := x.typ^.size;
(*        IF (x.mode#MODE_INX) & (x.mode#MODE_ABS) & (x.mode#MODE_ABS_RELOC) &
           ((x.bas.reg<0) OR (x.bas.reg>MAX(SET))) THEN
          Debug.WriteStr("mode: ");
          Debug.WriteInt(x.mode);
          Debug.ShowOutput;
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.ValToReg");
          x.bas.reg:=esi;
          x.bas.key:=freeReg;
        END; *)
        IF (x.mode = MODE_INX) OR (x.mode=MODE_INX_RELOC) THEN
          y.bas := x.inx;
        ELSIF (x.mode = MODE_ABS) OR
              (x.mode = MODE_ABS_RELOC) OR
              (x.bas.reg IN {ESP, EBP}) THEN
          Reg.GetGenReg(y.bas)
        ELSE
          y.bas := x.bas;
        END;
        IF size = 1 THEN
          IF form = SInt THEN OPL.PutORM(4, 0FBEH, y.bas, x) (* MOVSX Gd,Eb *)
          ELSE OPL.PutORM(4, 0FB6H, y.bas, x) (* MOVZX Gd,Eb *)
          END
        ELSIF size = 2 THEN
          IF form = Int THEN OPL.PutORM(4, 0FBFH, y.bas, x) (* MOVSX Gd,Ew *)
          ELSE OPL.PutORM(4, 0FB7H, y.bas, x) (* MOVZX Gd,Ew *)
          END
        ELSE
          OPL.PutORM(4, 08BH, y.bas, x) (* MOV Gd,Ed *)
        END;
        Reg.ReleaseReg(x.seg);
        IF (x.mode = MODE_REGX) OR (x.mode = MODE_REGX_RELOC) THEN Reg.ReleaseReg(x.inx) END;
        x.mode := MODE_REG; 
        x.bas := y.bas;
      END
    END
  END ValToReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE ValToThisReg*(VAR x: OPL.Item; this: INTEGER);
    (* function:      load value of 'x' in 'this' cpu-register                *)
    (* precondition:  x.mode IN {Var, VarPar, Con, FStk, Reg, Abs, RegI, RegX, Inx, Coc}*)
    (*                x.typ^.form IN {Byte, Bool, Char, SInt, Int, LInt, Set} *)
    (* postcondition: x.mode = Reg                                            *)

  BEGIN
    ValToReg(x);
    Reg.MoveToThisReg(x.bas, this)
  END ValToThisReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE ValToByteReg*(VAR x: OPL.Item);
    (* function:      load value of 'x' in a cpu-byte-register                *)
    (* precondition:  x.mode IN {Var, VarPar, Con, FStk, Reg, Abs, RegI, RegX, Inx, Coc}*)
    (*                x.typ^.form IN {Byte, Bool, Char, SInt, Int, LInt, Set} *)
    (* postcondition: x.mode = Reg                                            *)

  BEGIN
    ValToReg(x);
    Reg.MoveToByteReg(x.bas)
  END ValToByteReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadSize*(VAR x, size: OPL.Item);
    (* function:      load size of 'x' in 'size'                              *)
    (* precondition:  x.mode IN {Var, VarPar, StrCon, DArr, RegI}                   *)
    (* postcondition: size.mode IN {Con, Reg}, x is unchanged                 *)

  VAR 
    base, h: OPL.Item; 
    basedisp: LONGINT;

    PROCEDURE DynArrSize(typ: OPT.Struct);
    VAR 
      btyp: OPT.Struct;
    BEGIN
      IF typ^.comp = DynArr THEN
        btyp := typ^.BaseTyp;
        DynArrSize(btyp);
        base.disp := basedisp + typ^.offset + 4;
        IF (btyp^.comp = DynArr) OR (btyp^.size # 1) THEN
          OPL.PutORM(4, 08BH, h.bas, base); (* MOV Gd,Ed *)
          OPL.PutOM(4, 0FFH, 0H, h); (* INC r/m32 *)
(* !C!          OPL.PutOM(4, 0FFH, 0H, h); (* INC Ed *)*)
          OPL.PutORM(4, 0FAFH, size.bas, h) (* IMUL Gd,Ed *)
        ELSE
          OPL.PutORM(4, 08BH, size.bas, base); (* MOV Gd,Ed *)
          OPL.PutOM(4, 0FFH, 0H, size); (* INC r/m32 *)
(* !C!          OPL.PutOM(4, 0FFH, 0H, size); (* INC Ed *)*)
        END
      ELSIF typ^.size # 1 THEN
        OPL.PutOMD(4, 4, 0C7H, 0H, size, typ^.size) (* MOV Ed,Id *)
      END
    END DynArrSize;

  BEGIN
    size.typ := OPT.linttyp;
    IF x.typ^.form = String THEN
      size.mode := MODE_CON; 
      size.adr := x.disp;
      size.mnolev:=0; (* !C! *)
    ELSIF x.typ^.comp = DynArr THEN (* see also PushDynArrDesc *)
      IF (x.mode = DArr) & (x.disp=MODE_REGI_RELOC) THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.LoadSize");
      ELSIF (x.mode = MODE_REGI) OR (x.mode = DArr) & (x.disp = MODE_REGI) THEN
        base.mode := MODE_REGI;
        base.seg := x.seg;
        IF x.mode = MODE_REGI THEN base.bas := x.bas ELSE base.bas := x.inx END;
        basedisp := 0;
        size.mode := MODE_REG; 
        Reg.GetGenReg(size.bas);
        h.mode := MODE_REG; 
        Reg.GetGenReg(h.bas);
        DynArrSize(x.typ);
      ELSIF x.mode = MODE_REGI_RELOC THEN
        base.mode := MODE_REGI_RELOC;
        base.reloc:=x.reloc;
        base.relocInx:=x.relocInx;
        base.seg := x.seg;
        base.bas := x.bas;
        basedisp := 0;
        size.mode := MODE_REG; 
        Reg.GetGenReg(size.bas);
        h.mode := MODE_REG; 
        Reg.GetGenReg(h.bas);
        DynArrSize(x.typ);
      ELSE
        base.mnolev := x.mnolev;
        LoadBaseAdr(base);
        basedisp := x.adr;
        size.mode := MODE_REG; 
        Reg.GetGenReg(size.bas);
        h.mode := MODE_REG; 
        Reg.GetGenReg(h.bas);
        DynArrSize(x.typ);
        OPL.Release(base)
      END;
      Reg.ReleaseReg(h.bas)
    ELSE
      size.mode := MODE_CON; 
      size.adr := x.typ^.size;
      size.mnolev:=0; (* !C! *)
    END
  END LoadSize;

(*----------------------------------------------------------------------------*)
  PROCEDURE LoadVal(VAR x: OPL.Item);
    (* function:      load the value of 'x' in either cpu- of fpu-register    *)
    (* precondition:  x.mode IN {Var, VarPar, Con, FStk, Reg, Abs, RegI, RegX, Inx, Coc}*)
    (* postcondition: x.mode IN {Reg, FStk}                                   *)

  BEGIN
    IF (x.mode # MODE_FSTK) & (x.mode # MODE_REG) THEN
      IF x.typ^.form IN realSet THEN ValToFStk(x)
      ELSE ValToReg(x)
      END
    END
  END LoadVal;

(*----------------------------------------------------------------------------*)
  PROCEDURE Bound(VAR reg: Reg.RegisterT; VAR adr: OPL.Item; trapNum: INTEGER);
    (* function:      code for bound check                                    *)
    (* precondition:  reg = value of this register will be checked            *)
    (*                adr = address of bounds                                 *)

  VAR 
    L1, L2: OPL.Label;
  BEGIN
(* replaced by a call to RTS
    OPL.PutORM(4, 062H, reg, adr) (* BOUND Gd,Ma *)
*)
    L1 := 0; L2 := 0;
    OPL.PutORM(4, 039H, reg, adr); (* CMP r/m32,r32 *)
    OPL.PutJmpCF(GTR, L1);
    IncAdr(adr, 4);
    OPL.PutORM(4, 039H, reg, adr); (* CMP r/m32,r32 *)
    IncAdr(adr, -4);
    OPL.PutJmpCF(GEQ, L2);
    OPL.FixLink(L1);
    Trap(trapNum);
    OPL.FixLink(L2)
  END Bound;  

(*----------------------------------------------------------------------------*)
  PROCEDURE CheckRange*(VAR reg: Reg.RegisterT; bound: LONGINT);
    (* function:      code for range-check                                    *)
    (* precondition:  reg = value of this register will be checked              *)
    (*                bound = address, where the bounds are stored            *)

  VAR 
    adr: OPL.Item;
    L1, L2: OPL.Label;
  BEGIN
    IF ranchk THEN
      adr.mode := MODE_ABS; 
      adr.seg.reg := DS; 
      adr.adr := bound;
      L1 := 0; L2 := 0;
      OPL.PutORM(4, 039H, reg, adr); (* CMP r/m32,r32 *)
      OPL.DefineFixup(FIXUP_CONST,0,OPL.pc-4);
      OPL.PutJmpCF(GTR, L1);
      IncAdr(adr, 4);
      OPL.PutORM(4, 039H, reg, adr); (* CMP r/m32,r32 *)
      OPL.DefineFixup(FIXUP_CONST,0,OPL.pc-4);
      IncAdr(adr, -4);
      OPL.PutJmpCF(GEQ, L2);
      OPL.FixLink(L1);
      Trap(rangeTrap);
      OPL.FixLink(L2)
    END
  END CheckRange;

(*----------------------------------------------------------------------------*)
  PROCEDURE CheckIndex(VAR r: Reg.RegisterT; typ: OPT.Struct);
    (* function:      code for index-check                                    *)
    (* precondition:  r = value of this register will be checked              *)
    (*                bound = address, where the bounds are stored            *)

  VAR 
    y: OPL.Item;
  BEGIN
    IF inxchk THEN
      IF typ^.tdadr < 0 THEN OPL.AllocBounds(0, typ^.n-1, typ^.tdadr) END;
(*      y.mode := MODE_ABS; 
      y.seg.reg := cs; 
      y.adr := typ^.tdadr;*)
      y.mode:=MODE_ABS_RELOC;
      y.seg.reg:=DS;
      y.adr:=typ^.tdadr;
      y.reloc:=FIXUP_CONST;
      y.relocInx:=0;
      Bound(r, y, indexTrap)
    END
  END CheckIndex;

(*----------------------------------------------------------------------------*)
  PROCEDURE CheckOvfl*;
    (* function:      code for overflow-check                                 *)
  VAR 
    L1: OPL.Label;
  BEGIN
    IF ovfchk THEN
      L1 := 0;
      OPL.PutJmpCF(1, L1); (* jump if no ovfl *)
      Trap(ovflTrap);
      OPL.FixLink(L1)
    END
  END CheckOvfl;


(*=================== I N T E R N A L : C O N D I T I O N - C O D E ==========*)

  PROCEDURE SetCoc*(VAR x: OPL.Item; cc: INTEGER);
    (* function:      initialize item with condition                          *)
    (* precondition:  cc = condition                                          *)
    (* postcondition: x = initialized item                                    *)

  BEGIN
    x.typ := OPT.booltyp; x.mode := Coc; x.seg.reg := cc;
    x.adr := 0; x.disp := 0
  END SetCoc;

(*----------------------------------------------------------------------------*)
  PROCEDURE InvertedCoc*(cc: INTEGER): INTEGER;
    (* function:      invert the meaning of condition                         *)
    (* precondition:  cc: condition                                           *)
    (* postcondition: RETURN: inverted condition. (x cc y) = ~ (x RETURN y) *)

  BEGIN
    IF ODD(cc) THEN RETURN cc-1 ELSE RETURN cc+1 END
  END InvertedCoc;

(*----------------------------------------------------------------------------*)
  PROCEDURE ExchangedCoc*(cc: INTEGER): INTEGER;
    (* function:      return condition after change of left and right hand side*)
    (* precondition:  cc: condition                                           *)
    (* postcondition: RETURN: condition after exchange. (x cc y) = (y RETURN x)*)

  BEGIN
    CASE cc OF
      LSS: RETURN GTR
    | GEQ: RETURN LEQ
    | LEQ: RETURN GEQ
    | GTR: RETURN LSS
    ELSE RETURN cc
    END
  END ExchangedCoc;

(*----------------------------------------------------------------------------*)
  PROCEDURE UnsignedCoc*(cc: INTEGER): INTEGER;
    (* function:      return condition for unsigned (or float) compare *)
    (* precondition:  cc: condition                                           *)
    (* postcondition: RETURN condition for unsigned compare *)

  BEGIN
    CASE cc OF
      LSS: RETURN ULSS
    | GEQ: RETURN UGEQ
    | LEQ: RETURN ULEQ
    | GTR: RETURN UGTR
    ELSE RETURN cc
    END
  END UnsignedCoc;

(*----------------------------------------------------------------------------*)
  PROCEDURE BoolToCoc*(VAR x: OPL.Item);
    (* function:      item-transfer                                           *)
    (* precondition:  x.mode IN {Var, VarPar, Con, Reg, Abs, RegI, RegX, Inx} *)
    (* postcondition: x.mode = Coc                                            *)

  BEGIN
    IF x.mode = MODE_CON THEN
      IF x.adr = true THEN SetCoc(x, ALWAYS) ELSE SetCoc(x, NEVER) END
    ELSE 
      LoadAdr(x);
      IF x.mode = MODE_REG THEN 
        OPL.PutOMD(4, 1, 083H, 7H, x, true) (* CMP Ed,Ib *)
      ELSE 
        OPL.PutOMD(1, 1, 080H, 7H, x, true) (* CMP Eb,Ib *)
      END;
      OPL.Release(x);
      SetCoc(x, EQL)
    END
  END BoolToCoc;

(*=================== I N T E R N A L : D Y N A M I C - A R R A Y S ==========*)

  PROCEDURE MoveBlockS*(VAR x, y: OPL.Item; size: LONGINT);
    (* function:      move 'size' bytes from 'y' to 'x'                       *)
    (* precondition:  x, y: addresses                                         *)
    (*                size: number of bytes to move                           *)
    (* postcondition: x[i] := y[i] for i = 0 .. size - 1                      *)

  VAR 
    z: OPL.Item; 
    n: LONGINT;
  BEGIN
    LoadAdr(x); 
    LoadAdr(y); 
    z.mode := MODE_REG;
    IF size = 1 THEN
      Reg.GetByteReg(z.bas);
      OPL.PutORM(1, 08AH, z.bas, y); (* MOV Gb,Eb *)
      OPL.PutORM(1, 088H, z.bas, x) (* MOV Eb,Gb *)
    ELSIF size = 2 THEN
      Reg.GetGenReg(z.bas);
      OPL.PutORM(2, 08BH, z.bas, y); (* MOV Gw,Ew *)
      OPL.PutORM(2, 089H, z.bas, x) (* MOV Ew,Gw *)
    ELSIF size = 4 THEN
      Reg.GetGenReg(z.bas);
      OPL.PutORM(4, 08BH, z.bas, y); (* MOV Gd,Ed *)
      OPL.PutORM(4, 089H, z.bas, x) (* MOV Ed,Gd *)
    ELSE
      AdrToRegID0(y, ESI);
      AdrToRegID0(x, EDI);
      Reg.MoveToThisReg(x.seg, ES);
      Reg.MoveSegRegIn(y.seg);
      Reg.GetThisReg(z.bas, ECX);
      IF (size MOD  4) = 0 THEN
        n := size DIV  4;
        OPL.PutOMD(4, 4, 0C7H, 0H, z, n); (* MOV Ed,Id *)
        OPL.PutO(0, 0FCH); (* CLD *)
        IF y.seg.reg # DS THEN OPL.PutSegPrefix(y.seg.reg) END;
        OPL.PutO(4, 0F3A5H) (* REP REPE MOVSW/D *)
      ELSIF (size MOD  2) = 0 THEN
        n := size DIV  2;
        OPL.PutOMD(4, 4, 0C7H, 0H, z, n); (* MOV Ed,Id *)
        OPL.PutO(0, 0FCH); (* CLD *)
        IF y.seg.reg # DS THEN OPL.PutSegPrefix(y.seg.reg) END;
        OPL.PutO(2, 0F3A5H) (* REP REPE MOVSW/D *)
      ELSE                                (* (size MOD  2) = 1               *)
        OPL.PutOMD(4, 4, 0C7H, 0H, z, size); (* MOV Ed,Id *)
        OPL.PutO(0, 0FCH); (* CLD *)
        IF y.seg.reg # DS THEN OPL.PutSegPrefix(y.seg.reg) END;
        OPL.PutO(1, 0F3A4H) (* REP REPE MOVSB *)
      END
    END;
    Reg.ReleaseReg(z.bas)
  END MoveBlockS;

(*----------------------------------------------------------------------------*)
  PROCEDURE MoveBlock*(VAR x, y, z: OPL.Item);
    (* function:      move 'z' bytes from 'y' to 'x'                          *)
    (* precondition:  x, y: addresses                                         *)
    (*                z: number of bytes to move                              *)
    (* postcondition: x[i] := y[i] for i = 0 .. z - 1                         *)

  BEGIN
    IF z.mode = MODE_CON THEN
      MoveBlockS(x, y, z.adr);
    ELSE
      ValToThisReg(z, ECX);
      AdrToRegID0(y, ESI);
      AdrToRegID0(x, EDI);
      Reg.MoveToThisReg(x.seg, ES);
      Reg.MoveSegRegIn(y.seg);
      Reg.MoveGenRegIn(x.bas);
      Reg.MoveGenRegIn(y.bas);
      Reg.MoveGenRegIn(z.bas);
      OPL.PutO(0, 0FCH); (* CLD *)
      IF y.seg.reg # DS THEN OPL.PutSegPrefix(y.seg.reg) END;
      OPL.PutO(1, 0F3A4H) (* REP REPE MOVSB *)
    END
  END MoveBlock;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocStkBlockS*(size: LONGINT; VAR adr: OPL.Item);
    (* function:      allocates a block of 'size' bytes on stack and returns  *)
    (*                in 'adr' the starting address of this block.            *)
    (* precondition:  size: size in bytes                                     *)
    (* postcondition: adr: points to start address                            *)
    (*                ESP is decremented by 'size'                            *)

    VAR h: OPL.Item;
  BEGIN
    h.mode := MODE_REG; h.bas.reg := ESP;
(* !C!     OPL.PutOMD(2, 2, 081H, 05H, h, size + size MOD 2); (* SUB Ew,Iw *)
    OPL.GetGenReg(adr.bas);        (* an even value is subtracted from ESP *)
    OPL.PutORM(4, 0FB7H, adr.bas, h); (* MOVZX Gd,Ew *) *)
    OPL.PutOMD(4, 4, 081H, 05H, h, size + (-size) MOD 4); (* SUB r/m32, imm32 *)
    Reg.GetGenReg(adr.bas);        (* stack alignment to 4 bytes *)
    OPL.PutORM(4, 08BH, adr.bas, h); (* MOV r32, r/m32 *)
    adr.mode := MODE_REGI; adr.disp := 0; adr.seg.reg := SS;
  END AllocStkBlockS;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocStkBlock*(VAR size, adr: OPL.Item);
    (* function:      allocates a block of 'size' bytes on stack and returns  *)
    (*                in 'adr' the starting address of this block.            *)
    (* precondition:  size: size in bytes                                     *)
    (* postcondition: adr: points to start address                            *)
    (*                ESP is decremented by 'size'                            *)

  VAR 
    h: OPL.Item;
  BEGIN
    IF size.mode = MODE_CON THEN
      AllocStkBlockS(size.adr, adr);
    ELSE
      h.mode := MODE_REG; h.bas.reg := ESP;
(*      OPL.PutORM(2, 02BH, h.bas, size); (* SUB Gw,Ew *)
      OPL.PutOMD(2, 2, 081H, 4H, h, 0FFFEH); (* AND Ew,Iw *) (* ESP is even *)
      OPL.GetGenReg(adr.bas);
      OPL.PutORM(4, 0FB7H, adr.bas, h); (* MOVZX Gd,Ew *) *)
      OPL.PutORM(4, 02BH, h.bas, size); (* SUB r32, r/m32 *)
      OPL.PutOMD(4, 4, 081H, 4H, h, -4); (* AND r/m32, imm32 *) (* ESP is aligned to 4 bytes *)
      Reg.GetGenReg(adr.bas);
      OPL.PutORM(4, 08BH, adr.bas, h); (* MOV r32, r/m32 *)
      adr.mode := MODE_REGI; adr.disp := 0; adr.seg.reg := SS;
    END;
  END AllocStkBlock;

(*=================== I N T E R N A L : P A R A M E T E R - T R A N S F E R ==*)

  PROCEDURE PushAdr*(VAR ap: OPL.Item);
    (* function:      push address of an actual parameter                     *)
    (* precondition:  ap: actual parameter                                    *)
    (* postcondition:                                                         *)

  BEGIN
    LoadAdr(ap);
    IF ap.mode = MODE_ABS THEN
(*      OPL.PutPushReg(2, ap.seg);
      OPL.PutOD(2, 2, 068H, ap.adr); (* PUSH Iw *) *)
      OPL.PutOD(4, 4, 068H, ap.adr); (* PUSH imm32 *)
    ELSIF ap.mode = MODE_ABS_RELOC THEN
      OPL.PutOD(4, 4, 068H, ap.adr); (* PUSH imm32 *)
      OPL.DefineFixup(ap.reloc,ap.relocInx,OPL.pc-4);
    ELSE 
      AdrToRegID0(ap, -1);
(*      OPL.PutPushReg(2, ap.seg);
      OPL.PutPushReg(2, ap.bas) *)
      OPL.PutPushReg(4,ap.bas); (* !C! *)
    END
  END PushAdr;

  PROCEDURE CmpAdr*(VAR memLoc,typeTag: OPL.Item);
    (* function:      compare memLoc, adr(typeTag)              *)
    (* precondition:  typeTag.mode in {MODE_ABSRELOC, MODE_REGI}  *)
    (* postcondition: last instruction emitted was CMP,
                      if typeTag.mode was MODE_REGI: 
                        typeTag.bas:=typeTag.bas+typeTag.disp;
                        typeTag.disp:=0; *)
  BEGIN
    CASE typeTag.mode OF
      MODE_REGI:
        IF typeTag.disp#0 THEN
          typeTag.mode:=MODE_REG;
          OPL.PutOMD(4, 4, 081H, 0H, typeTag, typeTag.disp); (* ADD r/m32,imm32 *)
          typeTag.disp:=0;
          typeTag.mode:=MODE_REGI;
        END;
        OPL.PutORM(4, 039H, typeTag.bas, memLoc); (* CMP r/m32,r32 *)
    | MODE_ABS_RELOC:
        OPL.PutOMD(4, 4, 081H, 7H,  memLoc, typeTag.adr); (* CMP r/m32,imm32 *)
        OPL.DefineFixup(typeTag.reloc,typeTag.relocInx,OPL.pc-4);
    ELSE
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.CmpAdr");
    END;
  END CmpAdr;
(*----------------------------------------------------------------------------*)
  PROCEDURE PushDynArrDesc*(VAR fp, ap: OPL.Item);
    (* function:      push bounds of dynamic array on stack                   *)
    (* precondition:  fp.typ^.comp = DynArr                                   *)
    (*                ap.mode IN {Var, VarPar, StrCon, Abs, RegI, RegX, Inx, DArr, }*)
    (*                fp: formal parameter                                    *)
    (*                ap: actual parameter                                    *)
    (* postcondition:                                                         *)

    VAR 
      size, base: OPL.Item; 
      seg: Reg.RegisterT; 
      basedisp: LONGINT;

    PROCEDURE PushBnd(ftyp, atyp: OPT.Struct);
    BEGIN
      IF atyp^.comp = Array THEN
        OPL.PutOD(4, 4, 068H, atyp^.n-1); (* PUSH Id *) (* LEN-1 *)
        OPL.PutOD(4, 4, 068H, 0) (* PUSH Id *) (* 0 *)
      ELSE                              (* atyp^.comp = DynArr                *)
        base.disp := basedisp + atyp^.offset + 4;
        OPL.PutOM(4, 0FFH, 6H, base); (* PUSH Ed *) (* LEN-1 *)
        OPL.PutOD(4, 4, 068H, 0) (* PUSH Id *) (* 0 *)
      END;
      IF ftyp^.BaseTyp^.comp = DynArr THEN (*! order has been changed *)
        PushBnd(ftyp^.BaseTyp, atyp^.BaseTyp)
      END
    END PushBnd;

  BEGIN
    IF ap.typ^.form = String THEN
(* !C!      seg.reg := cs; *)
      OPL.PutOD(4, 4, 068H, ap.disp - 1); (* PUSH Id *) (* LEN-1 *)
      OPL.PutOD(4, 4, 068H, 0); (* PUSH Id *) (* 0 *)
(* !C!     OPL.PutPushReg(2, seg);           (* segment                            *)
      OPL.PutOD(2, 2, 068H, ap.adr) (* PUSH Iw *) (* offset *) *)
      OPL.PutOD(4, 4, 068H, ap.adr); (* PUSH Iw *) (* offset *)
      OPL.DefineFixup(FIXUP_CONST,0,OPL.pc-4); (* ???!!! is it really guaranteed that the constant is always from the local module? *)
    ELSE
      IF fp.typ^.BaseTyp = OPT.bytetyp THEN
        IF ap.typ^.comp = Array THEN
          OPL.PutOD(4, 4, 068H, ap.typ^.size-1); (* PUSH Id *) (* LEN-1 *)
          OPL.PutOD(4, 4, 068H, 0) (* PUSH Id *) (* 0 *)
        ELSE                            (* ap.typ^.comp = DynArr, ap.mode IN {Var, VarPar, DArr}*)
          LoadSize(ap, size);
          IF size.mode = MODE_CON THEN
            OPL.PutOD(4, 4, 068H, size.adr - 1); (* PUSH Id *) (* 0 *)
          ELSE
            OPL.PutOM(4, 0FFH, 1H, size); (* DEC Ed *)
            OPL.PutOM(4, 0FFH, 6H, size); (* PUSH Ed *) (* LEN-1 *)
          END;
          OPL.PutOD(4, 4, 068H, 0); (* PUSH Id *) (* 0 *)
          OPL.Release(size)
        END
      ELSE                              (* ap.typ^.comp IN {DynArr, Array} ap.mode IN {Var, VarPar, DArr}*)
        IF ap.typ^.comp = DynArr THEN   (* see also LoadSize *)
          IF (ap.mode = MODE_REGI) OR (ap.mode=MODE_REGI_RELOC) OR (ap.mode = DArr) & ((ap.disp = MODE_REGI) OR (ap.disp=MODE_REGI_RELOC)) THEN
            base.mode := MODE_REGI;
            base.seg := ap.seg;
            IF (ap.mode = MODE_REGI) OR (ap.mode=MODE_REGI_RELOC) THEN base.bas := ap.bas ELSE base.bas := ap.inx END;
            basedisp := 0;
            PushBnd(fp.typ, ap.typ)
          ELSE
            base.mnolev := ap.mnolev;
            LoadBaseAdr(base);
            basedisp := ap.adr;
            PushBnd(fp.typ, ap.typ);
            OPL.Release(base)
          END
        ELSE
          PushBnd(fp.typ, ap.typ)
        END;
      END;
      IgnoreDynArrDesc(ap);
      PushAdr(ap)
    END
  END PushDynArrDesc;

(*=================== E X P O R T E D : G E N E R A L - P R O C E D U R E S ==*)

  PROCEDURE DeRef*(VAR x: OPL.Item);
    (* function:      dereference a pointer                                   *)
    (* precondition:  x.mode IN {VarPar, Var, Abs, RegI, RegX, Inx}           *)
    (* postcondition: x.mode = RegI                                           *)
  VAR 
    y: OPL.Item; 
    L1: OPL.Label;
  BEGIN
    LoadAdr(x);
    Reg.GetGenReg(y.bas);
    OPL.PutORM(4, 08BH, y.bas, x); (* MOV r32,r/m32 *)
    OPL.Release(x);
    x.mode := MODE_REGI; 
    x.disp := 0; 
    x.seg.reg:=DS;
    x.bas := y.bas;
    IF nilchk THEN
      x.mode := MODE_REG; 
      OPL.PutOM(4, 09H, x.bas.reg, x); (* OR r/m32,r32 *)
      x.mode := MODE_REGI; 
      L1 := 0;
      OPL.PutJmpCF(NEQ, L1); (* check if pointer is NIL *)
      Trap(nilTrap);
      OPL.FixLink(L1);
    END;
(* !C!    LoadAdr(x);
    OPL.GetSegReg(y.seg); OPL.GetGenReg(y.bas);
    OPL.PutORM(4, 0FB7H, y.bas, x); (* MOVZX Gd,Ew *)
    IncAdr(x, 2);
    IF nilchk THEN
      OPL.PutOM(2, 0F00H, 4H, x); (* VERR Ew *)
      L1 := 0;
      OPL.PutJmpCF(EQL, L1); (* check if pointer is NIL *)
      Trap(nilTrap);
      OPL.FixLink(L1);
    END;
    OPL.PutORM(2, 08EH, y.seg, x); (* MOV Sw,Ew *)
    OPL.Release(x);
    x.mode := RegI; 
    x.disp := 0; 
    x.seg := y.seg; 
    x.bas := y.bas *)
  END DeRef;

(*----------------------------------------------------------------------------*)

  PROCEDURE DeRefToThisReg*(VAR x: OPL.Item; targetReg:INTEGER);
    (* function:      dereference a pointer                                   *)
    (* precondition:  x.mode IN {VarPar, Var, Abs, RegI, RegX, Inx}           *)
    (* postcondition: x.mode = RegI                                           *)
  VAR 
    y: OPL.Item; 
    L1: OPL.Label;
  BEGIN
    LoadAdr(x);
    Reg.GetThisReg(y.bas,targetReg);
    OPL.PutORM(4, 08BH, y.bas, x); (* MOV r32,r/m32 *)
    OPL.Release(x);
    x.mode := MODE_REGI; 
    x.disp := 0; 
    x.seg.reg:=DS;
(*    x.seg.key:=freeReg;*)
    x.bas := y.bas;
    IF nilchk THEN
      x.mode := MODE_REG; 
      OPL.PutOM(4, 09H, x.bas.reg, x); (* OR r/m32,r32 *)
      x.mode := MODE_REGI; 
      L1 := 0;
      OPL.PutJmpCF(NEQ, L1); (* check if pointer is NIL *)
      Trap(nilTrap);
      OPL.FixLink(L1);
    END;
  END DeRefToThisReg;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE Index*(VAR x, y: OPL.Item);
    (* function:      index in an array                                       *)
    (* precondition:  x.typ^.comp IN {Array, DynArr}                          *)
    (*                x.mode IN {Var, VarPar, DArr, RegI (disp = 0)}          *)
    (* postcondition: x.mode IN {DArr, RegI, REGI_RELOC, RegX}                *)

  VAR 
    r, h: OPL.Item; 
    s: LONGINT;
    releaseH:BOOLEAN;
  BEGIN
    releaseH:=FALSE;
    (* Adr := ((.. ((i1 * n2) + i2) * n3 + .. ) * nk + ik) * basSiz + basAdr  *)
    IF x.typ^.comp = Array THEN         (* x.mode IN {Var, VarPar, RegI, RegX, Inx}*)
      s := x.typ^.BaseTyp^.size;
      IF y.mode = MODE_CON THEN
        LoadAdr(x);
        IncAdr(x, y.adr * s)
      ELSIF (x.typ^.BaseTyp^.comp = Array) OR (s#1)&(s#2)&(s#4)&(s#8) THEN
        ValToReg(y);
        CheckIndex(y.bas, x.typ);
        IF s # 1 THEN
          OPL.PutORMD(4, 4, 069H, y.bas, y, s); (* IMUL Gd,Ed,Id *)
        END;
        LoadAdr(x);
        IF x.mode = MODE_ABS THEN
          x.mode := MODE_REGI; 
          x.disp := x.adr; 
          x.bas := y.bas; 
          y.mode := 0
        ELSIF x.mode = MODE_ABS_RELOC THEN 
          x.mode := MODE_REGI_RELOC; 
          x.disp := x.adr; 
          x.bas := y.bas; 
          y.mode := 0;
(*          x.reloc:=x.reloc;  !!!! x.reloc oder y.reloc ???
          x.relocInx:=x.relocInx;                 *)
        ELSE
          AdrToRegI(x);
          Reg.MoveToGenReg(x.bas);
          OPL.PutORM(4, 03H, x.bas, y); (* ADD r32, r/m32 *)
        END
      ELSE
        ValToReg(y);
        CheckIndex(y.bas, x.typ);
        LoadAdr(x);
        IF x.mode = MODE_ABS THEN 
          x.mode := MODE_INX; 
          x.disp := x.adr;
        ELSIF x.mode=MODE_ABS_RELOC THEN
          x.mode:=MODE_INX_RELOC;
          x.disp:=x.adr;
        ELSE 
          AdrToRegI(x); 
          IF x.mode=MODE_REGI THEN x.mode := MODE_REGX 
          ELSIF x.mode=MODE_REGI_RELOC THEN x.mode:=MODE_REGX_RELOC 
          ELSE
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.Index (mode)");
          END;
        END;
        x.inx := y.bas;
        y.mode := 0;
        IF s = 1 THEN x.adr := 0
        ELSIF s = 2 THEN x.adr := 1
        ELSIF s = 4 THEN x.adr := 2
        ELSE             x.adr := 3     (* s = 8                              *)
          
        END
      END;
    ELSE                                (* x.typ^.comp = DynArr;              *)
                                        (* x.mode IN {Var, VarPar, DArr} OR     *)
                                        (* x.mode = RegI, x.disp = 0   *)
      IF (x.mode = MODE_REGI) OR 
         (x.mode = MODE_REGI_RELOC) OR 
         (x.mode = DArr) & ((x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC)) THEN
        h.seg := x.seg;
        IF (x.mode = DArr) & (x.disp=MODE_REGI_RELOC) THEN
          OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"OPC_Base.Index (dyn reloc)");
        END;
        IF (x.mode = MODE_REGI_RELOC) OR 
           (x.mode = DArr) & (x.disp=MODE_REGI_RELOC) THEN
          h.mode:=MODE_REGI_RELOC;
        ELSE
          h.mode:=MODE_REGI;
        END;
        IF (x.mode = DArr) & ((x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC)) THEN
(*        IF (x.mode = MODE_REGI) OR (x.mode=MODE_REGI_RELOC) THEN *)
          h.bas := x.inx;
        ELSE 
          h.bas := x.bas;
        END;
        h.disp := x.typ^.offset
      ELSE
        h.mnolev := x.mnolev;
        LoadBaseAdr(h);
        releaseH:=TRUE;
        h.disp := x.adr + x.typ^.offset;
      END;
      IF x.mode = DArr THEN
        IF (y.mode = MODE_CON) & (~inxchk OR (y.adr = 0)) THEN
          IF y.adr # 0 THEN
            x.mode := MODE_REG;
            OPL.PutOMD(4, 4, 081H, 0H, x, y.adr); (* ADD Ed,Id *)
            x.mode := DArr;
          END
        ELSE
          ValToReg(y);
          IF inxchk THEN Bound(y.bas, h, indexTrap) END;
          OPL.PutORM(4, 03H, x.bas, y); (* ADD Gd,Ed *)
          OPL.Release(y)
        END
      ELSE
        IF (x.mode = MODE_REGI) OR (x.mode=MODE_REGI_RELOC) THEN 
          x.inx := x.bas; 
          x.adr := x.typ^.size;
        END;
        x.disp := x.mode;
        IF (y.mode = MODE_CON) & (~inxchk OR (y.adr = 0)) THEN
          x.mode := MODE_REG;
          Reg.GetGenReg(x.bas);
          OPL.PutOMD(4, 4, 0C7H, 0H, x, y.adr) (* MOV Ed,Id *)
        ELSE
          ValToReg(y);
          IF inxchk THEN Bound(y.bas, h, indexTrap) END;
          x.bas := y.bas;
          y.mode := 0;
        END;
        x.mode := DArr
      END;                              (* x.mode = DArr                      *)
      IF x.typ^.BaseTyp^.comp = DynArr THEN
        IF (x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC) THEN
          h.disp := x.typ^.BaseTyp^.offset + 4
        ELSE
          h.disp := x.adr + x.typ^.BaseTyp^.offset + 4
        END;
        Reg.GetGenReg(r.bas); 
        r.mode := MODE_REG;
        OPL.PutORM(4, 08BH, r.bas, h); (* MOV r32, r/m32 *)  (* LEN - 1 *)
        OPL.PutOM(4, 0FFH, 0H, r); (* INC Ed *)
        OPL.PutORM(4, 0FAFH, x.bas, r); (* IMUL Gd,Ed *)  (* x := x * LEN *)
        Reg.ReleaseReg(r.bas)
      ELSE
        s := x.typ^.BaseTyp^.size;
        IF (s # 1) & (s # 2) & (s # 4) & (s # 8) THEN
          x.mode := MODE_REG;
          OPL.PutORMD(4, 4, 069H, x.bas, x, s); (* IMUL Gd,Ed,Id *)
          IF x.disp = MODE_VAR THEN
            h.disp := x.adr;
            OPL.PutORM(4, 03H, x.bas, h); (* ADD Gw,Ew *)
(* !C!             OPL.PutORM(2, 03H, x.bas, h); (* ADD Gw,Ew *) *)
            x.seg.reg := SS;
          ELSIF x.disp=MODE_DLLVAR THEN
           (* !!!! *)
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.Index from DLL");
          ELSIF x.disp = VarPar THEN
            h.disp := x.adr;
            OPL.PutORM(4, 03H, x.bas, h); (* ADD Gw,Ew *)
(* !C!            OPL.PutORM(2, 03H, x.bas, h); (* ADD Gw,Ew *)
            h.disp := x.adr + 2;
            OPL.GetSegReg(x.seg); (* !!!! *)
            OPL.PutORM(2, 08EH, x.seg, h) (* MOV Sw,Ew *) *)
            x.seg.reg:=DS;
          ELSE (* x.disp = RegI *)
            x.mode := MODE_REG;
            OPL.PutORM(4, 01H, x.inx, x); (* ADD Ed,Gd *)
            Reg.ReleaseReg(x.inx);
            x.seg.reg:=DS;
          END;
          IF x.disp=MODE_REGI_RELOC THEN
            OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"OPC_Base.Index (reloc2)");
          END;
          IF (x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC) THEN x.disp := x.adr ELSE x.disp := 0 END;
          x.mode := MODE_REGI; (* !!!! or MODE_REGI_RELOC? *)
        ELSE
          r.bas := x.inx; 
          x.inx := x.bas; 
          x.bas := r.bas;
          IF x.disp = MODE_VAR THEN
            Reg.GetGenReg(x.bas);
            x.seg.reg := SS;
            h.disp := x.adr;
            OPL.PutORM(4, 08BH, x.bas, h) (* MOV r32,r/m32 *)
(*            IF (x.mode=MODE_REGI_RELOC) OR (x.mode=MODE_REGX_RELOC) THEN (* !!!!! ??? *)
              OPL.PutOMD(4, 4, 081H, 0H, , 0); (* ADD r/m32, imm32 *)
              OPL.DefineFixup(x.reloc,x.relocInx,OPL.pc-4);
              
              
            END; *)
            
(* !C!             OPL.PutORM(4, 0FB7H, x.bas, h) (* MOVZX Gd,Ew *) *)
          ELSIF x.disp=MODE_DLLVAR THEN
           (* !!!! *)
            OPM.CommentedErr(E.INTERNAL_MURKS,"OPC_Base.Index from DLL2");
          ELSIF x.disp = VarPar THEN
            Reg.GetGenReg(x.bas);
            h.disp := x.adr;
            x.seg.reg:=DS;
            OPL.PutORM(4, 08BH, x.bas, h); (* MOV r32,r/m32 *)
(*            OPL.GetGenReg(x.bas);
            h.disp := x.adr;
            OPL.GetSegReg(x.seg); (* !!!! *)
            OPL.PutORM(4, 0FB7H, x.bas, h); (* MOVZX Gd,Ew *)
            h.disp := x.adr + 2;
            OPL.PutORM(2, 08EH, x.seg, h) (* MOV Sw,Ew *) *)
          (* ELSE x.disp = RegI *)
          END;
          IF (x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC) THEN x.disp := x.adr ELSE x.disp := 0 END;
          IF s = 1 THEN x.adr := 0
          ELSIF s = 2 THEN x.adr := 1
          ELSIF s = 4 THEN x.adr := 2
          ELSE x.adr := 3
          END;
          x.mode := MODE_REGX; (* !!!! OR MODE_REGX_RELOC ?? *)
        END
      END;
    END;
    x.typ := x.typ^.BaseTyp;
    IF releaseH THEN Reg.ReleaseReg(h.bas) END;
  END Index;

(*----------------------------------------------------------------------------*)

  PROCEDURE Trap*(n: LONGINT);
    (* function:      code to terminate programm with return code n           *)
    (* precondition:  n = return code (n = -8000H..7FFFH)                          *)
    VAR h: OPL.Item;
  BEGIN
    IF (n < -8000H) OR (7FFFH < n) THEN Err(E.INTERNAL_MURKS); RETURN END;
    IF n < 0 THEN INC(n, 10000H) END;
    INC(n, OPM.errpos.line * 10000H);
(*    h.seg.reg := cs;
    OPL.PutPushReg(2, h.seg); *)
    OPL.PutOD(4, 4, 068H, 0); (* PUSH imm32 *)
    OPL.DefineFixup(FIXUP_MOD_DESC_OFF, 0, OPL.pc - 4);
    OPL.PutOD(4, 4, 068H, n); (* PUSH imm32 *)
    OPL.PutDirCall(0);
    OPL.DefineFixup(FIXUP_CODE, rtsHaltInx, OPL.pc - 4);
  END Trap;

(*----------------------------------------------------------------------------*)

END OPC_Base.
