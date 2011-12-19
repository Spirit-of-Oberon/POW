(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPL;                                     (**)
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
(* PURPOSE: Low level code generator of Oberon2 compiler DLL                  *)
(*                                                                            *)
(******************************************************************************)

  IMPORT
    OPT, OPM, OPS, SYSTEM, E:=Error, Coff, Reg:=Register, Debug;

(*
  Items:

  the fields mnolev and typ are set for all modes in OPV

  80386 :
     mode      | adr    disp   seg   bas   inx    reloc  relocInx
  -------------+--------------------------------------------------
   1 Var       | adr
   2 VarPar    | adr
   3 Con       | val    val
               | off                      (real constant)
               | off    len               (len of string)
   6 LProc     | adr   linkadr        
   7 XProc     | adr   linkadr
   9 CProc     |
  10 IProc     | adr   linkadr
  20 DArr      | adr  Var|VarPar      offR
               | size   RegI   segR   offR  basR
  21 Coc       | Tjmp   Fjmp    cc
  22 Stk       |
  23 FStk      |
  24 Reg       |                      R
  25 Abs       | off           segR
  26 RegI      |        disp   segR   R
  27 RegX      | scale  disp   segR   R     RX
  28 Inx       | scale  disp   segR         RX
  29 ABS_RELOC | off           segR               reloc  relocInx
  30 REGX_RELOC| scale  disp   segR   R     RX    reloc  relocInx

  ausgelagert => Item.key # Reg[reg].key

  addressing modes:
     [base register] + [index register] * 2^(scale) + (displacement)
     (scale) = 0 | 1 | 2 | 3
     (displacement) = 8 | 16 | 32 Bit
*)
  CONST

    (* fixup types                                                            *)
    FIXUP_CODE*        = 1007H; (* relative code address (inx is symbol inx) *)
    FIXUP_DATA*        = 1008H; (* reference to the global data area of a module (inx is module inx) *)
    FIXUP_ABSCODE*     = 1009H; (* absolute code address (inx is symbol address) *)
    FIXUP_CONST*       = 1003H; (* reference to the constant area of a module (inx is module index) *)
    FIXUP_MOD_DESC_OFF*= 1000H; (* sets the internal marker modDescOffPos, inx has no meaning      *)
    FIXUP_MODENTRY*    = 1004H; (* code relative reference to a module entry code *)
    FIXUP_DLLMODENTRY* = 100AH; (* code relative reference to a module entry code within a DLL (inx is module index) *)
    FIXUP_CODE_SECTION*= 1006H; (* absolute reference to the beginning of a code section (inx is module index) *)
    CFIXUP_DATA*       = 1005H; (* fixup in constant area to absolute position (inx is symbol index) *)
    DFIXUP_SECREL*     = 100BH; (* fixup in debug area to section relative offset, inx is index to symbol table *)
    DFIXUP_SECTION*    = 100CH; (* fixup in debug area to section nr, inx is index to section symbol in symbol table *)

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
    MODE_VARSTPAR=OPT.MODE_VARSTPAR; (* statically typed VAR parameter; may be declared only in definition modules *)
    MODE_DLLVAR=OPT.MODE_DLLVAR;
    
    (* item modes for 80386 (must not overlap item basemodes,  > 20)          *)
    DArr* = 20;
    Coc* = 21; 
    Stk* = 22; 
    MODE_FSTK* = 23;  (* real on floating-point-stack *)
    MODE_REG* = 24;      (*            bas                                *)
    MODE_ABS* = 25;      (* seg:[adr                                    ] *)
    MODE_REGI* = 26;     (* seg:[      bas +                disp        ] *)
    MODE_REGX* = 27;     (* seg:[      bas + inx * 2 ^adr + disp        ] *)
    MODE_INX* = 28;      (* seg:[            inx * 2 ^adr + disp        ] *)
    MODE_ABS_RELOC* =29; (* seg:[adr +                             reloc] *)
    MODE_REGI_RELOC*=30; (* seg:[      bas +                disp + reloc] *)
    MODE_REGX_RELOC*=31; (* seg:[      bas + inx * 2 ^adr + disp + reloc] *)
    MODE_INX_RELOC* =32; (* seg:[            inx * 2 ^adr + disp + reloc] *)

    (* structure forms                                                        *)
    Undef = 0; Byte = 1; Bool = 2; Char = 3; SInt = 4; Int = 5; LInt = 6;
    Real = 7; LReal = 8; Set = 9; String = 10; NilTyp = 11; NoTyp = 12;
    Pointer = 13; ProcTyp = 14; Comp = 15;
    intSet = {SInt..LInt}; realSet = {Real, LReal};


    (* composite structure forms                                              *)
    Basic = 1; Array = 2; DynArr = 3; Record = 4;

    

 (* condition, 80386                                                       *)
    CST = 2; CCL = 3; EQL = 4; NEQ = 5; LSS = 12; GEQ = 13; LEQ = 14; GTR = 15;
    ALWAYS = 16; NEVER = 17;

    (* RTTI+ *)
    MAXENTRIESNAMES=500; (* max. total length of the names of all record entries *)
    MAXENTRIESCODES=300; (* max. total codes for record entries type description *)
    (* RTTI- *)

    maxCodeLen = 256000;    
    maxConstLen = 128000;   
    
    MAXFIXUPS = 4000; (* maximum number of possible fixups  *)
    maxRecordExt* = 10;     (* maximum depth of record type hierarchy *)


  TYPE
    Item* = RECORD 
      mode*:INTEGER; 
      mnolev*: INTEGER; (* module number level; mnolev<0: module imported and 
                           ABS(mnolev) is index to OPT.GlbMod[] *)
      typ*: OPT.Struct;
      ext*: OPT.ConstExt;
      adr*,             (* often some address *)
      disp*: LONGINT;   (* often some code location *)
      seg*, bas*, inx*: Reg.RegisterT;  (* segment-, base- and index-Register *)
      reloc*:INTEGER;    (* type of relocation *)
      relocInx*:INTEGER; (* index parameter for relocation *)
    END;
    Label* = LONGINT;
    
    CodeBlock = ARRAY maxCodeLen OF CHAR;(* BYTE                       *)
    ConstBlock = ARRAY maxConstLen OF CHAR;(* BYTE                     *)
    ConstBlockPtr = POINTER TO ConstBlock;

    Import = RECORD
               first, last: LONGINT;
               obj: OPT.Object;
             END;
    FixupEntry = RECORD 
                   typ-: INTEGER;
                   inx-: LONGINT; (* symbol table index *)
                   pc-: LONGINT; (* offset *)
                 END;
    FixupTab = ARRAY MAXFIXUPS OF FixupEntry;
    FixupPtr = POINTER TO FixupTab;
    PutDProcT = PROCEDURE(l: LONGINT);
    PutWProcT = PROCEDURE(i: LONGINT);
    PutCProcT = PROCEDURE(ch: CHAR);
    ObjListPtr = POINTER TO ObjListEl;
    ObjListEl = RECORD 
                  obj*: OPT.Object; 
                  next*: ObjListPtr;
                END;
    StrListPtr = POINTER TO StrListEl;
    StrListEl = RECORD 
                  str-: OPT.Struct; 
                  next-: StrListPtr;
                END;

  VAR
    level*: INTEGER;
    pc*,       (* current position in code buffer *)
    dsize*,    (* size of global data *)
    constLen*:LONGINT; (* current position in constant buffer *)
    floatContrWord*: LONGINT; (* offset of control word for floating point unit
               in constants section *)

    modBodyEnd*: LONGINT;
    nofFixup-, 
    nofImport*, (* number of imported procedures *)
    nofComm*, nofTypDesc*: INTEGER;

    importList*,  (* start of linked list of imported procedures *)
    comList*,    (* start of linked list of command procedures *)
    lastImport*,  (* last element of list of imported procedures *)
    lastCom*: ObjListPtr;  (* last element of list of command procedures  *)
    typDescList*:StrListPtr; (* head of type desc. list *)
    lastTypDesc*: StrListPtr; (* during construction pointer to tail of type desc. list; later temp. variable *)
    (* RTTI+ *)
    entryNameTab*:ARRAY MAXENTRIESNAMES OF CHAR;
    nofNameTab*:INTEGER;
    entryTypeTab*:ARRAY MAXENTRIESCODES OF INTEGER;
    nofTypeTab*:INTEGER;
    (* RTTI- *)
    code*: CodeBlock;
    constPtr*: ConstBlockPtr;
    fixupPtr*: FixupPtr; (* list of fixups *)
    modDescLabel-:LONGINT; (* label for module desciptor in const area *)

    modInitAdr*:LONGINT; (* address of own module initialization code *)
    nofStat*: LONGINT; (*!L*)
    
    virtRegStart:LONGINT; (* size needed for local variables in current procedure *)
    virtRegPatch:LONGINT; (* position of stack frame size to patch with length of memory registers *)
    virtRegNesting:INTEGER; (* stack frame nesting level of current procedure *)
    virtRegOffs-:LONGINT; (* offset of memory registers from EBP in current procedure *)
    firstExit:BOOLEAN; (* flag to determine whether EndProc has been called for the first time for a procedure *)

(*----------------------------------------------------------------------------*)
  PROCEDURE ^DefineFixup*(typ:INTEGER; inx:LONGINT; pc: LONGINT);
(*----------------------------------------------------------------------------*)
(*  PROCEDURE ^ MoveThisReg*(VAR reg: Register; this: INTEGER);*)

(*----------------------------------------------------------------------------*)
    (* function:      generate an error message                               *)
    (* precondition:  n is the error number                                   *)
    (* postcondition: error message has been written to file                  *)
  PROCEDURE Err(code:INTEGER);
  BEGIN
    OPM.Err(code)
  END Err;

(*----------------------------------------------------------------------------*)

(*----------------------------------------------------------------------------*)
  PROCEDURE ^ PutB*(byte: LONGINT);

(*----------------------------------------------------------------------------*)
(*  PROCEDURE ^ MoveGenRegIn*(VAR reg: Register);*)

(*----------------------------------------------------------------------------*)
(*  PROCEDURE ^ MoveSegRegIn*(VAR seg: Register);*)

(*----------------------------------------------------------------------------*)
  (* RTTI+ *)
  PROCEDURE BuildRTTI*(typ: OPT.Struct; adr: LONGINT; itemName:ARRAY OF CHAR; first:BOOLEAN;
                       VAR nameTab: ARRAY OF CHAR; VAR nofNameTab: INTEGER;
                       VAR typeTab: ARRAY OF INTEGER; VAR nofTypeTab: INTEGER);
    (* function:      build run time type information in two tables           *)
    (* precondition:  typ = type of variable                                  *)
    (*                adr = address of variable                               *)
    (*                first=TRUE if outmost RECORD - ENDRECORD codes should be omitted *)
    (*                typ^.tdadr already computed                             *)
    (*                adr = address of variable                               *)

  VAR 
    fld: OPT.Object; 
(*    btyp: OPT.Struct;  *)
    i, n: LONGINT;
(*    typeMark:INTEGER;*)
    
    
    PROCEDURE AddName(name:ARRAY OF CHAR);
    (* add name to RTTI name table *)
    VAR
      i:INTEGER;
    BEGIN 
      i:=0;
      WHILE (nofNameTab<LEN(nameTab)) & (name[i]#0X) DO
        nameTab[nofNameTab]:=name[i];
        INC(i);
        INC(nofNameTab);
      END;
      IF nofNameTab<LEN(nameTab) THEN
        nameTab[nofNameTab]:=0X;
        INC(nofNameTab);
      END;
    END AddName;

    PROCEDURE AddTypeRef(typeInx:LONGINT);
    (* add index into RTTI code table to RTTI name table *)
    (* precondition: 0<=typeInx<32767 *)
    BEGIN 
      IF nofNameTab+1<LEN(nameTab) THEN
        nameTab[nofNameTab]:=CHR(typeInx DIV 100H);
        nameTab[nofNameTab+1]:=CHR(typeInx MOD 100H);
        INC(nofNameTab,2);
      ELSE
        nofNameTab:=SHORT(LEN(nameTab));
      END;
    END AddTypeRef;

    PROCEDURE AddType(type:INTEGER);
    (* add type token to RTTI code table *)
    BEGIN 
      IF nofTypeTab<LEN(typeTab) THEN
        typeTab[nofTypeTab]:=type;
        INC(nofTypeTab) 
      END
    END AddType;

    PROCEDURE AddAddr(adr: LONGINT);
    (* add LONGINT to RTTI code table *)
    BEGIN 
      IF nofTypeTab+1<LEN(typeTab) THEN
        SYSTEM.MOVE(SYSTEM.ADR(adr),SYSTEM.ADR(typeTab[nofTypeTab+1]),2); 
        SYSTEM.MOVE(SYSTEM.ADR(adr)+2,SYSTEM.ADR(typeTab[nofTypeTab]),2);  
        INC(nofTypeTab,2) 
      END
    END AddAddr;
    
  BEGIN
    IF typ^.comp = Basic THEN
      AddName(itemName);
      AddTypeRef(nofTypeTab);
      IF (typ^.form=NoTyp) & (itemName=OPT.HdPtrName) THEN (* foreign hidden pointer (not exported) to something *)
        AddType(0F0H);
        AddAddr(adr);
              
      ELSIF typ^.form=Pointer THEN
        AddType(typ^.form);   
        AddAddr(adr);
        IF typ^.BaseTyp^.comp=Record THEN (* pointer to record? *)
          AddType(1024);
        ELSE                              (* pointer to array! *)
          BuildRTTI(typ^.BaseTyp, 0, "^", FALSE,
                    entryNameTab,nofNameTab,
                    entryTypeTab,nofTypeTab);
        END;
      ELSE
        AddType(typ^.form);   
        IF typ^.form#Undef THEN AddAddr(adr) END;
      END;                                                                 
    ELSIF typ^.comp = Record THEN
      IF ~first THEN
        AddName(itemName);
        AddTypeRef(nofTypeTab);
        AddType(1024); (* code for record in RTTI *)
        AddAddr(adr);
      END;
      fld:=typ^.link;    (* look at the rest of the fields  *)
      WHILE (fld # NIL) & (fld^.mode = Fld) DO
          BuildRTTI(fld^.typ, fld^.adr + adr, fld^.name, FALSE,
                    entryNameTab,nofNameTab,
                    entryTypeTab,nofTypeTab);
        fld:=fld^.link;
      END;
      IF ~first THEN
        AddType(2048); (* code for end of record in RTTI *)
        AddName(";");
      END;
    ELSIF typ^.comp = Array THEN
      AddName(itemName);
      AddTypeRef(nofTypeTab);
      AddType(256); (* code for array in RTTI *)
      AddAddr(adr);
      AddAddr(typ^.BaseTyp.size); (* size of array element *)
      AddAddr(typ^.n); (* number of array elements *)
      BuildRTTI(typ^.BaseTyp, 0, "[", FALSE,
                entryNameTab,nofNameTab,
                entryTypeTab,nofTypeTab);
    ELSIF typ^.comp = DynArr THEN
      AddName(itemName);
      AddTypeRef(nofTypeTab);
      AddType(512); (* code for open array in RTTI *)
      AddAddr(adr);
      AddAddr(typ^.BaseTyp.size); (* size of array element *)
      BuildRTTI(typ^.BaseTyp, 0, "[", FALSE,
                entryNameTab,nofNameTab,
                entryTypeTab,nofTypeTab);
    END
  END BuildRTTI;
  (* RTTI- *)


  PROCEDURE FindPtrs*(typ: OPT.Struct; adr: LONGINT; VAR tab: ARRAY OF LONGINT; VAR last: INTEGER);
    (* function:      append all the addresses of pointers in the variable of *)
    (*                type 'typ' at address 'adr' to the array 'tab'          *)
    (* precondition:  typ = type of variable                                  *)
    (*                adr = address of variable                               *)
    (* postcondition: 'tab' contains addresses of pointers                    *)
    (*                'last' has increased by the number of pointers          *)
    (* (used for NIL pointer initialization)                                  *)

    VAR fld: OPT.Object; btyp: OPT.Struct; i, n: LONGINT;
    
    PROCEDURE Add(adr: LONGINT);
    BEGIN IF last < LEN(tab) THEN tab[last]:=adr; INC(last) END
    END Add;

  BEGIN
    IF typ^.form = Pointer THEN
      Add(adr);
    ELSIF typ^.comp = Record THEN
      btyp:=typ^.BaseTyp;
      IF btyp # NIL THEN FindPtrs(btyp, adr, tab, last) END ;
      fld:=typ^.link;
      WHILE (fld # NIL) & (fld^.mode = Fld) DO
        IF fld^.name = OPT.HdPtrName THEN Add(fld^.adr + adr)
        ELSE FindPtrs(fld^.typ, fld^.adr + adr, tab, last)
        END ;
        fld:=fld^.link
      END
    ELSIF typ^.comp = Array THEN
      btyp:=typ^.BaseTyp; n:=typ^.n;
      WHILE btyp^.comp = Array DO n:=btyp^.n * n; btyp:=btyp^.BaseTyp END ;
      IF (btyp^.form = Pointer) OR (btyp^.comp = Record) THEN i:=0;
        WHILE i < n DO FindPtrs(btyp, adr, tab, last); INC(adr, btyp^.size); INC(i) END
      END
    END
  END FindPtrs;
  
(*----------------------------------------------------------------------------*)
  (* RTTI+ *)
  PROCEDURE PutRTTI*(putWProc:PutWProcT; putCProc:PutCProcT;
                     VAR nameTab:ARRAY OF CHAR; nofNameTab:INTEGER;
                     VAR typeTab:ARRAY OF INTEGER; nofTypeTab:INTEGER);
    (* function:      writes a block containing the names and types of a 
                      record or global module var.  *)
    (* precondition:  PutWProc = procedure to write a word of the block      
                      PutCProc = procedure to write a character of the block      *)
  VAR             
    i:INTEGER;
  BEGIN
    FOR i:=1 TO (nofNameTab+2*nofTypeTab) MOD 4 DO putCProc(0X) END; (* alignment *)
    IF nofNameTab=MAXENTRIESNAMES THEN (* table overflow; write 0FFX as indicator *)
      putCProc(0FFX);
    ELSE
      putCProc(0X);
      putCProc(0X);
      putCProc(0FFX);
      putCProc(0X);
      FOR i:=nofNameTab-1 TO 0 BY -1 DO
        putCProc(nameTab[i]);
      END;
    END;
    FOR i:=nofTypeTab-1 TO 0 BY -1 DO
      putWProc(typeTab[i]);
    END;
    IF nofNameTab=MAXENTRIESNAMES THEN (* table overflow; write -entry number as indicator *)
      putWProc(-nofTypeTab);
    ELSE
      putWProc(nofTypeTab);
    END;
  END PutRTTI;
  (* RTTI- *)


(*----------------------------------------------------------------------------*)
PROCEDURE PutSegPrefix*(segReg: INTEGER);
    (* function:     writes a segment prefix byte into code area              *)
    (* precondition: segReg IN {ds, cs, ss, es, fs, gs}                       *)

  BEGIN
    CASE segReg OF
      Reg.ES: PutB(26H) (* ES: *)
    | Reg.CS: PutB(2EH) (* CS: *)
    | Reg.SS: PutB(36H) (* SS: *)
    | Reg.DS: PutB(3EH) (* DS: *)
    | Reg.FS: PutB(64H) (* FS: *)
    | Reg.GS: PutB(65H) (* GS: *)
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutSegPrefix");
    END
  END PutSegPrefix;
      
(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstC*(ch: CHAR);
    (* function:      writes a single character into constant area            *)

  BEGIN 
    IF constLen>=maxConstLen THEN 
      Err(E.CONSTANT_FRAME_TOO_LARGE); 
      constLen:=0;
    END;
    constPtr^[constLen]:=ch; 
    INC(constLen);
  END PutConstC;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstB(byte: LONGINT);
    (* function:      writes a byte or a 8-bit integer into constant area     *)
    (* precondition:  -80H <= byte <= 100H                                    *)

  BEGIN
    IF (byte < -80H) OR (100H <= byte) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutConstB");
    ELSE
      IF byte < 0 THEN INC(byte, 100H) END;
      PutConstC(CHR(byte))
    END
  END PutConstB;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstW*(word: LONGINT);
    (* function:      writes a word or 16-bit integer into constant area      *)
    (* precondition:  -8000H <= word <= 10000H                                *)

  BEGIN
    IF (word < -8000H) OR (10000H <= word) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutConstW");
    ELSE
      IF word < 0 THEN INC(word, 10000H) END;
      PutConstC(CHR(word MOD  100H));
      PutConstC(CHR(word DIV  100H))
    END
  END PutConstW;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstD*(dword: LONGINT);
    (* function:      writes a dword or 32-bit integer into constant area     *)
  BEGIN 
    PutConstC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutConstC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutConstC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutConstC(CHR(dword MOD  100H));
  END PutConstD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstName*(name: ARRAY OF CHAR);
    (* function:      writes a name into constant area                        *)

    VAR i: INTEGER;
  BEGIN
    i:=0;
    WHILE (i < LEN(name)) & (i < OPM.MaxIdLen) & (name[i] # 0X) DO
      PutConstC(name[i]);
      INC(i)
    END;
    WHILE i < OPM.MaxIdLen DO PutConstC(0X); INC(i) END;
  END PutConstName;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutConstString(str: ARRAY OF CHAR);
    (* function:      writes a string into constant area                      *)

    VAR i: INTEGER;
  BEGIN
    i:=0;
    WHILE (i < LEN(str)) & (str[i] # 0X) DO
      PutConstC(str[i]);
      INC(i)
    END;
    PutConstC(0X);
  END PutConstString;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE PutC*(ch: CHAR);
    (* function:      writes a single character into code area                *)

  BEGIN 
    IF pc >= maxCodeLen THEN Err(E.CODE_TOO_LONG); pc:=maxCodeLen DIV 2 END;
    code[pc]:=ch; INC(pc)
  END PutC;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutB*(byte: LONGINT);
    (* function:      writes a byte or a 8-bit integer into code area         *)
    (* precondition:  -80H <= byte < 100H                                     *)

  BEGIN
    IF (byte < -80H) OR (100H <= byte) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutB");
    ELSE
      IF byte < 0 THEN INC(byte, 100H) END;
      PutC(CHR(byte))
    END
  END PutB;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutW*(word: LONGINT);
    (* function:      writes a word or a 16-bit integer into code area        *)
    (* precondition:  -8000H <= word < 10000H                                 *)

  BEGIN
    IF (word < -8000H) OR (10000H <= word) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutW");
    ELSE
      IF word < 0 THEN INC(word, 10000H) END;
      PutC(CHR(word MOD  100H));
      PutC(CHR(word DIV  100H))
    END
  END PutW;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutD*(dword: LONGINT);
    (* function:      writes a dword or a 32-bit integer into code area       *)
 BEGIN 
    PutC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutC(CHR(dword MOD  100H));
    dword:=dword DIV  100H; 
    PutC(CHR(dword MOD  100H));
  END PutD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutName*(VAR name: ARRAY OF CHAR);
    (* function:      writes a name into code area                            *)

  VAR 
    i: INTEGER;
  BEGIN
    i:=0;
    WHILE (i < LEN(name)) & (i < OPM.MaxIdLen) & (name[i] # 0X) DO
      PutC(name[i]);
      INC(i)
    END;
    WHILE i < OPM.MaxIdLen DO PutC(0X); INC(i) END;
  END PutName;

(*----------------------------------------------------------------------------*)
  PROCEDURE GetB(loc: LONGINT): INTEGER;
    (* function:                                                              *)
    (* precondition:                                                          *)
    (* postcondition:                                                         *)

  BEGIN 
    RETURN ORD(code[loc])
  END GetB;

(*----------------------------------------------------------------------------*)
  PROCEDURE GetW(loc: LONGINT): LONGINT;
    (* function:      read one word from code area at address 'loc'           *)

  VAR 
    h: LONGINT;
  BEGIN 
    h:=ORD(code[loc+1]);
    RETURN h * 100H + ORD(code[loc])
  END GetW;

(*----------------------------------------------------------------------------*)
  PROCEDURE GetD(loc: LONGINT): LONGINT;
    (* function:      read 32-bit integer from code area at address 'loc'     *)

  VAR 
    i: INTEGER; 
    h: LONGINT;
  BEGIN 
    i:=4; 
    h:=0;
    WHILE i > 0 DO 
      DEC(i); 
      h:=h * 100H + ORD(code[loc+i]);
    END;
    RETURN h
  END GetD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutLabel*(loc, l: Label);
    (* function:      writes the 32-bit label 'l' at code address 'loc'       *)

  VAR 
    h: Label;
  BEGIN 
    h:=pc; 
    pc:=loc; 
    PutD(l); 
    pc:=h;
  END PutLabel;

(*----------------------------------------------------------------------------*)
  PROCEDURE GetLabel*(loc: Label): Label;
    (* function:      returns the 32-bit label at code address 'loc'          *)

  BEGIN 
    RETURN GetD(loc);
  END GetLabel;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutO*(opsize: INTEGER; opc: LONGINT);
    (* function:      writes opcode 'opc' with 32-bit address size to code area*)
    (* precondition:  opsize = size of operands (0, 2 or 4 byte)              *)
    (*                0 <= opc < 10000H, opcode number                        *)

  BEGIN
    IF (opc < 0) OR (10000H <= opc) THEN 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutO");
    ELSE
      IF opsize = 2 THEN
        PutB(66H) (* OPSIZE: *)
      END;
      IF (0 <= opc) & (opc < 100H) THEN 
        PutB(SHORT(opc))
      ELSE 
        PutB(SHORT(opc DIV  100H)); 
        PutB(SHORT(opc MOD  100H))
      END
    END
  END PutO;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutOM*(opsize, opc, ttt: INTEGER; VAR mem: Item);
    (* function:      writes opcode with memory location 'mem' to code area   *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                0 <= opc < 10000H, opcode number                        *)
    (*                0 <= ttt < 8, ttt-field (/digit) in opcode                       *)
    (*                mem = memory location or register                       *)

  BEGIN
    IF (ttt < 0) OR (8 <= ttt) THEN 
      ttt:=0; 
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM");
    END;
    CASE mem.mode OF
      MODE_REG:        Reg.MoveGenRegIn(mem.bas)
    | MODE_ABS:        Reg.MoveSegRegIn(mem.seg);
    | MODE_ABS_RELOC:  Reg.MoveSegRegIn(mem.seg);
    | MODE_REGI:       Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.bas)
    | MODE_REGI_RELOC: Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.bas)
    | MODE_REGX:       Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.bas); Reg.MoveGenRegIn(mem.inx)
    | MODE_REGX_RELOC: Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.bas); Reg.MoveGenRegIn(mem.inx)
    | MODE_INX:        Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.inx)
    | MODE_INX_RELOC:  Reg.MoveSegRegIn(mem.seg); Reg.MoveGenRegIn(mem.inx)
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 2");
    END;
    CASE mem.mode OF
      MODE_REG:  IF (opsize = 1) & ~(mem.bas.reg IN Reg.BYTE_REGS) THEN 
              OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 3");
            END;
            PutO(opsize, opc); 
            PutB(0C0H + 08H * ttt + mem.bas.reg)
    | MODE_ABS:
            IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
            PutO(opsize, opc); 
            PutB(08H * ttt + 05H); PutD(mem.adr);
    | MODE_ABS_RELOC:
            IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
            PutO(opsize, opc); 
            PutB(08H * ttt + 05H); 
            PutD(mem.adr);
            DefineFixup(mem.reloc,mem.relocInx,pc-4);
    | MODE_REGI: IF mem.disp = 0 THEN
              IF mem.bas.reg = Reg.ESP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(08H * ttt + 04H); PutB(20H + Reg.ESP);
              ELSIF mem.bas.reg = Reg.EBP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(40H + 08H * ttt + Reg.EBP); PutB(0);
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(08H * ttt + mem.bas.reg)
              END
            ELSIF (-80H <= mem.disp) & (mem.disp < 80H) THEN
              IF mem.bas.reg = Reg.ESP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(40H + 08H * ttt + 04H); PutB(20H + Reg.ESP)
              ELSIF mem.bas.reg = Reg.EBP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(40H + 08H * ttt + Reg.EBP)
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(40H + 08H * ttt + mem.bas.reg)
              END;
              PutB(SHORT(mem.disp))
            ELSE
              IF mem.bas.reg = Reg.ESP THEN
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(80H + 08H * ttt + 04H); PutB(20H + Reg.ESP)
              ELSIF mem.bas.reg = Reg.EBP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(80H + 08H * ttt + Reg.EBP)
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(80H + 08H * ttt + mem.bas.reg)
              END;
              PutD(mem.disp)
            END
    | MODE_REGI_RELOC:
            IF mem.bas.reg = Reg.ESP THEN
              IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
              PutO(opsize, opc); PutB(80H + 08H * ttt + 04H); PutB(20H + Reg.ESP)
            ELSIF mem.bas.reg = Reg.EBP THEN
              IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
              PutO(opsize, opc); PutB(80H + 08H * ttt + Reg.EBP)
            ELSE
              IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
              PutO(opsize, opc); PutB(80H + 08H * ttt + mem.bas.reg)
            END;
            PutD(mem.disp);
            DefineFixup(mem.reloc,mem.relocInx,pc-4);
    | MODE_REGX: IF mem.inx.reg = Reg.ESP THEN 
              OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 4");
            ELSIF mem.disp = 0 THEN
              IF mem.bas.reg = Reg.ESP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(08H * ttt + 04H);
                PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
              ELSIF mem.bas.reg = Reg.EBP THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(40H + 08H * ttt + 04H);
                PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
                PutB(0)
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
                PutO(opsize, opc); PutB(08H * ttt + 04H);
                PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
              END
            ELSIF (-80H <= mem.disp) & (mem.disp < 80H) THEN
              IF (mem.bas.reg = Reg.ESP) OR (mem.bas.reg = Reg.EBP) THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END
              END;
              PutO(opsize, opc); PutB(40H + 08H * ttt + 04H);
              PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
              PutB(SHORT(mem.disp))
            ELSE
              IF (mem.bas.reg = Reg.ESP) OR (mem.bas.reg = Reg.EBP) THEN
                IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END
              ELSE
                IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END
              END;
              PutO(opsize, opc); PutB(80H + 08H * ttt + 04H);
              PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
              PutD(mem.disp)
            END
    | MODE_REGX_RELOC:
            IF mem.inx.reg = Reg.ESP THEN 
              OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 7");
            END;
            IF (mem.bas.reg = Reg.ESP) OR (mem.bas.reg = Reg.EBP) THEN
              IF mem.seg.reg # Reg.SS THEN PutSegPrefix(mem.seg.reg) END
            ELSE
              IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END
            END;
            PutO(opsize, opc); PutB(80H + 08H * ttt + 04H);
            PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + mem.bas.reg));
            PutD(mem.disp);
            DefineFixup(mem.reloc,mem.relocInx,pc-4);
    | MODE_INX:  
            IF mem.inx.reg = Reg.ESP THEN 
              OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 5");
            ELSE
              IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
              PutO(opsize, opc); PutB(08H * ttt + 04H);
              PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + 05H));
              PutD(mem.disp)
            END
    | MODE_INX_RELOC:  
            IF mem.inx.reg = Reg.ESP THEN 
              OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 6");
            ELSE
              IF mem.seg.reg # Reg.DS THEN PutSegPrefix(mem.seg.reg) END;
              PutO(opsize, opc); PutB(08H * ttt + 04H);
              PutB(SHORT(mem.adr * 40H + mem.inx.reg * 08H + 05H));
              PutD(mem.disp);
              DefineFixup(mem.reloc,mem.relocInx,pc-4);
            END
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.PutOM 6");
    END 
  END PutOM;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutOD*(opsize, datasize: INTEGER; opc, data: LONGINT);
    (* function:      writes opcode 'opc' with immediate data 'data' to code  *)
    (*                area                                                    *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                datasize = size of immediate data (1, 2 or 4 bytes)     *)
    (*                0 <= opc < 10000H, opcode number                        *)
    (*                0 <= data < 10000H, value of immediate data             *)

  BEGIN
    PutO(opsize, opc);
    IF datasize = 1 THEN PutB(SHORT(data))
    ELSIF datasize = 2 THEN PutW(data)
    ELSE PutD(data)
    END
  END PutOD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutOMD*(opsize, datasize, opc, ttt: INTEGER; VAR mem: Item;
                   data: LONGINT);
    (* function:      writes opcode with memory location 'mem' and immediate  *)
    (*                data 'data' to code area                                *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                datasize = size of immediate data (1, 2 or 4 bytes)     *)
    (*                0 <= opc < 10000H, opcode number                        *)
    (*                0 <= ttt < 8, ttt-field in opcode                       *)
    (*                mem = memory location or register                       *)
    (*                0 <= data < 10000H, value of immediate data             *)

  BEGIN
    PutOM(opsize, opc, ttt, mem);
    IF datasize = 1 THEN PutB(SHORT(data))
    ELSIF datasize = 2 THEN PutW(data)
    ELSE PutD(data)
    END
  END PutOMD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutORM*(opsize, opc: INTEGER; VAR reg: Reg.RegisterT; VAR mem: Item);
    (* function:      writes opcode with register 'reg' as one and memory     *)
    (*                location 'mem' as the other parameter to code area      *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                0 <= opc < 10000H, opcode number                        *)
    (*                reg = register                                          *)
    (*                mem = memory location or register                       *)

  BEGIN
    IF reg.reg IN Reg.GENERAL_REGS_EX THEN
      IF reg.reg IN Reg.GENERAL_REGS THEN Reg.MoveGenRegIn(reg) END;
      IF (opsize = 1) & ~(reg.reg IN Reg.BYTE_REGS) THEN 
        OPM.CommentedErr(E.INTERNAL_MURKS,"PutORM");
      ELSE 
        PutOM(opsize, opc, reg.reg, mem)
      END
    ELSIF reg.reg IN Reg.SEGMENT_REGS_EX THEN
      IF reg.reg IN Reg.SEGMENT_REGS THEN Reg.MoveSegRegIn(reg) END;
      PutOM(opsize, opc, reg.reg - 8, mem)
    ELSE
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutORM2");
    END
  END PutORM;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutORMD*(opsize, datasize, opc: INTEGER; VAR reg: Reg.RegisterT;
                    VAR mem: Item; data: LONGINT);
    (* function:      writes opcode with register 'reg' as one and memory     *)
    (*                location 'mem' as the other parameter, followed by      *)
    (*                immediate data 'data' to code area                      *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                datasize = size of immediate data (1, 2 or 4 bytes)     *)
    (*                0 <= opc < 10000H, opcode number                        *)
    (*                reg = register                                          *)
    (*                mem = memory location or register                       *)
    (*                0 <= data < 10000H, value of immediate data             *)

  BEGIN
    PutORM(opsize, opc, reg, mem);
    IF datasize = 1 THEN PutB(SHORT(data))
    ELSIF datasize = 2 THEN PutW(data)
    ELSE PutD(data)
    END
  END PutORMD;

(*----------------------------------------------------------------------------*)
  PROCEDURE PushReg(opsize, creg: INTEGER);
    (* function:      writes code to push contents of register 'reg' to stack *)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                creg = register to push                                 *)

  BEGIN
    IF (Reg.EAX <= creg) & (creg <= Reg.EDI) THEN PutO(opsize, 050H + creg)
    ELSIF (Reg.ES <= creg) & (creg <= Reg.DS) THEN PutO(2, 06H + 8 * (creg-8))
    ELSIF (creg = Reg.FS) OR (creg = Reg.GS) THEN PutO(2, 0F80H + 8 * (creg-8))
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PushReg");
    END
  END PushReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE PopReg(opsize, creg: INTEGER);
    (* function:      writes code to pop contents of register 'reg' from stack*)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                creg = register to push                                 *)

  BEGIN
    IF (Reg.EAX <= creg) & (creg <= Reg.EDI) THEN PutO(opsize, 058H + creg)
    ELSIF (Reg.ES <= creg) & (creg <= Reg.DS) THEN PutO(2, 07H + 8 * (creg-8))
    ELSIF (creg = Reg.FS) OR (creg = Reg.GS) THEN PutO(2, 0F81H + 8 * (creg-8))
    ELSE 
      OPM.CommentedErr(E.INTERNAL_MURKS,"PopReg");
    END
  END PopReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutPushReg*(opsize: INTEGER; VAR reg: Reg.RegisterT);
    (* function:      writes code to push contents of register 'reg' to stack *)
    (* precondition:  opsize = size of operands (1, 2 or 4 bytes)             *)
    (*                creg = register to push                                 *)

  VAR 
    x: Item;
  BEGIN
    IF reg.reg IN Reg.ADD_REGS THEN
      PushReg(opsize, reg.reg)
    ELSIF reg.reg IN Reg.REGS THEN
      IF (*(reg.key=KEY_INREG) OR*) (Reg.virtRegTab[reg.key].inReg) THEN
        PushReg(opsize, Reg.virtRegTab[reg.key].reg)
      ELSE 
        x.mode:=MODE_REGI; 
        x.seg.reg:=Reg.SS;
        x.bas.reg:=Reg.EBP;
        x.disp:=-virtRegStart-4 * Reg.virtRegTab[reg.key].reg;
        PutOM(opsize, 0FFH, 6H, x); (* PUSH r/m32 *)
      END
    ELSE
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutPushReg");
    END
  END PutPushReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutPopReg*(opsize: INTEGER; VAR reg: Reg.RegisterT);
    (* function:      writes code to pop contents of register 'reg' from stack*)
    (* precondition:  opsize = size of operands (0, 2 or 4 bytes)             *)
    (*                creg = register to push                                 *)

  VAR 
    x: Item;
  BEGIN
    IF opsize#4 THEN
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"stack alignment: pop 16");
    END;
    IF reg.reg IN Reg.ADD_REGS THEN
      PopReg(opsize, reg.reg)
    ELSIF reg.reg IN Reg.REGS THEN
      IF (*(reg.key=KEY_INREG) OR*) (Reg.virtRegTab[reg.key].inReg) THEN
        PopReg(opsize, Reg.virtRegTab[reg.key].reg)
      ELSE 
        x.mode:=MODE_REGI; 
        x.seg.reg:=Reg.SS;
        x.bas.reg:=Reg.EBP;
        x.disp:=-virtRegStart-4 * Reg.virtRegTab[reg.key].reg;
        PutOM(opsize, 08FH, 0H, x); (* POP r/m32 *)
(*        x.mode:=MODE_ABS; 
        x.seg.reg:=Reg.DS;
        x.adr:=4 * virtRegTab[reg.key].reg;
        PutOM(opsize, 08FH, 0H, x); (* POP Ev *)
        DefineFixup(FIXUP_VIRTREGISTER, 0, pc - 4);*)
      END
    ELSE
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutPopReg");
    END
  END PutPopReg;

(*----------------------------------------------------------------------------*)
  PROCEDURE MergedLink*(x, y: Label): Label;
    (* function:      merges the two links 'x' and 'y' and retruns the        *)
    (*                starting address of the merged link                     *)
    (* precondition:  x = starting address of first link                      *)
    (*                y = starting address of second link                     *)
    (* postcondition: MergedLink = starting address of merged link            *)

    VAR l, h: Label;
  BEGIN
    IF y = 0 THEN RETURN x END;
    IF x = 0 THEN RETURN y END;
    l:=y;
    REPEAT 
      h:=l; 
      l:=GetLabel(l);
    UNTIL l = 0;
    PutLabel(h, x);
    RETURN y
  END MergedLink;

(*----------------------------------------------------------------------------*)
  PROCEDURE FixLink*(l: Label);
    (* function:      inserts at every address in the link, starting at       *)
    (*                address 'l', a relative address for a jump to the       *)
    (*                current pc location                                             *)
    (* precondition:  l = starting address of link                            *)

  VAR 
    h: Label; 
    d: LONGINT;
  BEGIN
    WHILE l # 0 DO
      h:=l; 
      l:=GetLabel(l); 
      d:=pc - h - 4;
      IF (d < OPM.MinInt) OR (OPM.MaxInt < d) THEN  (* jump distance too long     *)
        Err(E.JUMP_TOO_FAR); 
        d:=0
      END;
      PutLabel(h, d)
    END;
  END FixLink;

(*----------------------------------------------------------------------------*)
  PROCEDURE FixLinkValue*(l: Label; value:LONGINT);
    (* function:      inserts at every address in the link, starting at       *)
    (*                address 'l', a given value                              *)
    (* precondition:  l = starting address of link                            *)

  VAR 
    h: Label;
  BEGIN
    WHILE l # 0 DO 
      h:=l; 
      l:=GetLabel(l); 
      PutLabel(h, value);
    END;
  END FixLinkValue;

(*----------------------------------------------------------------------------*)
  PROCEDURE FixLinkAbs*(l: Label);
    (* function:      inserts at every address in the link, starting at       *)
    (*                address 'l', an absolute address for a jump to the      *)
    (*                pc location                                             *)
    (* precondition:  l = starting address of link                            *)

  BEGIN
    FixLinkValue(l,pc);
  END FixLinkAbs;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutJmpF*(VAR loc: Label);
    (* function:      writes code for an unconditional forward jump           *)
    (* precondition:  loc = starting address of link to same jump address     *)
    (* postcondition: loc = new starting address of link                      *)

  BEGIN 
    PutB(0E9H); (* JMP rel32 *)
    PutD(loc); 
    loc:=pc - 4;
  END PutJmpF;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutJmpB*(loc: Label);
    (* function:      writes code for an unconditional backward jump          *)
    (* precondition:  loc = destination address for the jump                  *)

  VAR 
    d: LONGINT;
  BEGIN 
    d:=loc - pc - 2;
    IF d>0 THEN Err(E.JUMP_TOO_FAR)       (* jump distance is too large         *)
    ELSIF d <= OPM.MinSInt THEN
      PutB(0E9H); (* JMP rel32 *) 
      PutD(d-3);
    ELSE
      PutB(0EBH); (* JMP rel8 *) 
      PutB(SHORT(d));
    END
  END PutJmpB;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutJmpCF*(cc: INTEGER; VAR loc: Label);
    (* function:      writes code for a conditional forward jump              *)
    (* precondition:  cc = condition code                                     *)
    (*                loc = starting address of link to same jump address     *)
    (* postcondition: loc = new staring address of link                       *)

  BEGIN
    IF cc = ALWAYS THEN 
      PutJmpF(loc)
    ELSIF cc # NEVER THEN 
      PutW(0800FH + cc * 100H); 
      PutD(loc); 
      loc:=pc - 4;
    END
  END PutJmpCF;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutJmpCB*(cc: INTEGER; loc: Label);
    (* function:      writes code for a conditional backward jump             *)
    (* precondition:  cc = condition code                                     *)
    (*                loc = destination address for the jump                  *)

  VAR 
    d: LONGINT;
  BEGIN
    IF cc = ALWAYS THEN 
      PutJmpB(loc)
    ELSIF cc # NEVER THEN
      d:=loc - pc - 2;
      IF d>0 THEN Err(E.JUMP_TOO_FAR)     (* jump distance too large             *)
      ELSIF d < OPM.MinSInt THEN
        PutW(0800FH + cc * 100H);  (* JMPcc *) 
        PutD(d-4);
      ELSE
        PutB(070H+cc); (* JMPcc *) 
        PutB(SHORT(d));
      END
    END
  END PutJmpCB;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutCaseJmp*(VAR x: Item);
    (* function:      writes code for an indirect within segment call         *)
    (* precondition:  x = index value in a register, x.mode = Reg             *)

  BEGIN
    x.mode:=MODE_INX;
    x.adr:=2;                         (* scale = 2^2 = 4                    *)
    x.disp:=0;                        (* OPL.pc + caseTabDisp               *)
    x.seg.reg:=Reg.CS;
    x.inx:=x.bas;
    PutOM(4, 0FFH, 4H, x);            (* JMP r/m32 *)
    pc:=pc - 4;
    PutD(pc + 4);
    DefineFixup(FIXUP_CODE_SECTION,0,pc-4);
  END PutCaseJmp;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutDirCall*(adr: LONGINT);
    (* function:      writes code for a direct intersegment call              *)
    (* precondition:  adr = address in [off32] format                         *)

  BEGIN 
    PutB(0E8H); (* CALL rel32 *) 
    PutD(adr); 
  END PutDirCall;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutIndCall*(VAR x: Item);
    (* function:      writes code for an indirect intersegment call           *)
    (* precondition:  x = address where call address [off32] is stored      *)
    (*                x.mode IN {Abs, RegI}                                   *)

  BEGIN
    IF x.mode = MODE_ABS THEN
      Reg.MoveSegRegIn(x.seg);
      IF x.seg.reg # Reg.DS THEN PutSegPrefix(x.seg.reg) END;
      PutB(0FFH); PutB(2*8H+5); PutD(x.adr); (* CALL [disp32] *)
    ELSIF x.mode=MODE_ABS_RELOC THEN
      Reg.MoveSegRegIn(x.seg);
      IF x.seg.reg # Reg.DS THEN PutSegPrefix(x.seg.reg) END;
      PutB(0FFH); 
      PutB(2*8H+5); 
      PutD(x.adr); (* CALL [disp32] *)
      DefineFixup(x.reloc,x.relocInx,pc-4);
    ELSIF x.mode = MODE_REGI THEN
      Reg.MoveSegRegIn(x.seg);
      IF x.disp = 0 THEN
        IF ~(x.bas.reg IN {Reg.EAX, Reg.EBX, Reg.ECX, Reg.EDX, Reg.ESI, Reg.EDI}) THEN
          Reg.MoveToThisReg(x.bas, Reg.EBX);
        ELSE
          Reg.MoveGenRegIn(x.bas)
        END;
        IF x.seg.reg # Reg.SS THEN PutSegPrefix(x.seg.reg) END;
        PutB(0FFH); PutB(2*8H + x.bas.reg)           (* CALL [reg] *);
      ELSE
        IF x.bas.reg # Reg.EBP THEN
          IF ~(x.bas.reg IN {Reg.EAX, Reg.EBX, Reg.ECX, Reg.EDX, Reg.ESI, Reg.EDI}) THEN
            Reg.MoveToThisReg(x.bas, Reg.EBX);
          ELSE
            Reg.MoveGenRegIn(x.bas)
          END;
          IF x.seg.reg # Reg.SS THEN PutSegPrefix(x.seg.reg) END;
          PutB(0FFH); PutB(2*40H + 2*8H + x.bas.reg); PutD(x.disp); (* CALL [reg+disp32] *)
        ELSE
          IF x.seg.reg # Reg.DS THEN PutSegPrefix(x.seg.reg) END;
          PutB(0FFH); PutB(2*40H + 2*8H + 5); PutD(x.disp); (* CALL [EBP+disp32] *)
        END;
      END;
    ELSIF x.mode = MODE_REGI_RELOC THEN
      Reg.MoveSegRegIn(x.seg);
      IF x.bas.reg # Reg.EBP THEN
        IF ~(x.bas.reg IN {Reg.EAX, Reg.EBX, Reg.ECX, Reg.EDX, Reg.ESI, Reg.EDI}) THEN
          Reg.MoveToThisReg(x.bas, Reg.EBX);
        ELSE
          Reg.MoveGenRegIn(x.bas)
        END;
        IF x.seg.reg # Reg.SS THEN PutSegPrefix(x.seg.reg) END;
        PutB(0FFH); PutB(2*40H + 2*8H + x.bas.reg);  (* CALL [reg+disp32] *)
      ELSE
        IF x.seg.reg # Reg.DS THEN PutSegPrefix(x.seg.reg) END;
        PutB(0FFH); PutB(2*40H + 2*8H + 5);  (* CALL [EBP+disp32] *)
      END;
      PutD(x.disp);
      DefineFixup(x.reloc,x.relocInx,pc-4);
    ELSE
      OPM.CommentedErr(E.INTERNAL_MURKS,"PutIndCall");
    END;
  END PutIndCall;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutCallF*(VAR loc: Label);
    (* function:      writes code for a near forward call to own procedure    *)
    (* precondition:  loc = - starting address of link to same call address   *)
    (* postcondition: loc = - new starting address of link                    *)

  BEGIN
    PutB(0E8H); (* CALL Av *) 
    PutD(-loc); loc:=- (pc - 4);
  END PutCallF;

(*----------------------------------------------------------------------------*)
  PROCEDURE PutCallB*(procType: INTEGER; loc: Label);
    (* function:      writes code for a near backward call to own procedure   *)
    (* precondition:  loc = entry point of the procedure                      *)
    (*                procType IN {LProc, XProc, WProc, CDeclProc ? }                       *)

  BEGIN 
    PutDirCall(loc-pc-5);
  END PutCallB;

(*----------------------------------------------------------------------------*)
  PROCEDURE DefineFixup*(typ:INTEGER; inx:LONGINT; pc: LONGINT);
    (* function:      define location and type of fixup                       *)
    (* precondition:  typ = type of fixup (CodePtr,CodeSeg,GSOff,ModDescOff)  *)
    (*                inx=index of associated symbol in symbol table          *)
    (*                         for typ in {FIXUP_CODE}                             *)
    (*                    index of module in OPT.GlbMod[] for typ in {FIXUP_DATA, FIXUP_MODENTRY  *)
                      (*                modNumInx = module number for 'typ' IN                  *)
                      (*                              {CodeSeg, ModEntry, GSOff}                *)
                      (*                          = index in EXTDEF for 'typ' IN {CodePtr}      *)
    (*                pc = location in code area to be fixed up               *)
  VAR
    h:LONGINT;
  BEGIN
    IF ((typ = FIXUP_CONST) OR 
        (typ = FIXUP_DATA) OR 
        (typ=FIXUP_MODENTRY) OR
        (typ=FIXUP_DLLMODENTRY)) & (inx > 0) THEN
      IF OPT.GlbMod[inx - 1]=NIL THEN
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.DefineFixup 1");
        RETURN;
      END;
      IF OPT.GlbMod[inx - 1]^.linkadr = OPM.LANotAlloc THEN
        Coff.AddGlobalData(OPT.GlbMod[inx-1],OPT.GlbMod[inx - 1]^.linkadr);
      END;  
    END;
    IF nofFixup < MAXFIXUPS THEN
      IF typ = FIXUP_MOD_DESC_OFF THEN
        h:=pc;
        PutLabel(pc,-modDescLabel);
        modDescLabel:=-h;
        typ:=Coff.IMAGE_REL_I386_DIR32; (* module descriptor is in constant area *)
        inx:=Coff.symInxConst;
      ELSIF typ=FIXUP_DATA THEN
        IF inx>0 THEN
          inx:=OPT.GlbMod[inx - 1]^.linkadr;
        ELSE
          inx:=Coff.symInxData;
        END;
        typ:=Coff.IMAGE_REL_I386_DIR32;
      ELSIF typ=FIXUP_MODENTRY THEN
        IF inx>0 THEN
         inx:=OPT.GlbMod[inx - 1]^.linkadr+1;
        ELSE
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.DefineFixup 2");
          (* no fixups needed for own module entry code *)
        END;
        typ:=Coff.IMAGE_REL_I386_REL32;
      ELSIF typ=FIXUP_DLLMODENTRY THEN
        IF inx>0 THEN
         inx:=OPT.GlbMod[inx - 1]^.linkadr+1;
        ELSE
          OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.DefineFixup 2");
          (* no fixups needed for own module entry code *)
        END;
        typ:=Coff.IMAGE_REL_I386_DIR32;
      ELSIF typ=FIXUP_CONST THEN
        IF inx>0 THEN
          inx:=OPT.GlbMod[inx - 1]^.linkadr+2;
        ELSE
          inx:=Coff.symInxConst;
        END;
        typ:=Coff.IMAGE_REL_I386_DIR32;
      ELSIF typ=FIXUP_CODE_SECTION THEN
        IF inx>0 THEN
          inx:=OPT.GlbMod[inx - 1]^.linkadr+3;
        ELSE
          inx:=Coff.symInxCode;
        END;
        typ:=Coff.IMAGE_REL_I386_DIR32;
      ELSIF typ=FIXUP_CODE THEN
        typ:=Coff.IMAGE_REL_I386_REL32;
      ELSIF typ=FIXUP_ABSCODE THEN
        typ:=Coff.IMAGE_REL_I386_DIR32;
      ELSIF typ=CFIXUP_DATA THEN
      ELSIF typ=DFIXUP_SECREL THEN
        typ:=Coff.IMAGE_REL_I386_SECREL;
      ELSIF typ=DFIXUP_SECTION THEN
        typ:=Coff.IMAGE_REL_I386_SECTION;
      ELSE
        OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.DefineFixup (type)");
        RETURN;
      END;
      fixupPtr^[nofFixup].typ:=typ;
      fixupPtr^[nofFixup].inx:=inx;
      fixupPtr^[nofFixup].pc:=pc;
      INC(nofFixup);
    ELSE
      Err(E.TOO_MANY_FIXUPS);
      nofFixup:=0;
    END;
  END DefineFixup;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocString*(VAR s: ARRAY OF CHAR; len: LONGINT; VAR adr: LONGINT);
    (* function:      stores string 's' in const area and returns its address *)
    (* precondition:  s = string, len = length of string                      *)
    (* postcondition: adr = address, where string constant is stored          *)

  VAR 
    i: LONGINT;
  BEGIN
    i:=0; adr:=constLen;
    WHILE i < len DO PutConstC(s[i]); INC(i) END;
  END AllocString;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocReal*(lr: LONGREAL; VAR adr: LONGINT; longReal: BOOLEAN);
    (* function:      stores a real constant in const area      *)
    (* precondition:  r = real number                                         *)
    (* postcondition: adr = address, where real constant is stored            *)

  TYPE 
    Rec= RECORD li1, li2: LONGINT END;
  VAR 
    rec: Rec; r: REAL;
  BEGIN
    WHILE (constLen MOD  4) # 0 DO PutConstB(0) END;
    adr:=constLen;
    IF longReal THEN
      rec:=SYSTEM.VAL(Rec, lr);
      PutConstD(rec.li1); PutConstD(rec.li2)
    ELSE
      r:=SHORT(lr);
      PutConstD(SYSTEM.VAL(LONGINT, r))
    END;
  END AllocReal;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocBounds*(low, hig: LONGINT; VAR adr: LONGINT);
    (* function:      stores the bound values in const area                   *)
    (* precondition:  low, hig = low and high value of bound                  *)
    (* postcondition: adr = address, where the bounds are stored              *)

  BEGIN
    WHILE (constLen MOD  4) # 0 DO PutConstB(0) END;
    adr:=constLen; 
    PutConstD(low); 
    PutConstD(hig);
  END AllocBounds;

  PROCEDURE AllocInitFlag*(VAR adr: LONGINT);
    (* function:      allocate module initialization flag (one byte) in constant area, preset to 0    *)
    (* precondition:  low, hig = low and high value of bound                  *)
    (* postcondition: adr = address where flag is stored              *)

  BEGIN
    WHILE (constLen MOD  4) # 0 DO PutConstB(0) END;
    adr:=constLen; 
    PutConstD(0); (* stick to DWORD alignment *)
  END AllocInitFlag;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocTypDesc*(typ: OPT.Struct);
    (* function:      stores a type-descriptor in const area                  *)
    (* precondition:  typ = data-type, typ^.comp IN {Record, Array}           *)
    (* postcondition: typ.adr = address, where type-descriptor is stored      *)

  VAR 
    i: INTEGER; 
    namePos: LONGINT;
  BEGIN
    IF typ^.comp = Record THEN
      IF typ^.extlev > maxRecordExt THEN 
        Err(E.TOO_MANY_INHERITANCE_LEVELS)
      ELSIF typ^.mno = 0 THEN
        namePos:=constLen;            (* name of record type                *)
        IF typ^.strobj # NIL THEN       (* named record types only            *)
          NEW(lastTypDesc^.next);
          lastTypDesc:=lastTypDesc^.next;
          lastTypDesc^.next:=NIL;
          lastTypDesc^.str:=typ;      (* used to produce list of type descr *)
          INC(nofTypDesc);
          PutConstString(typ^.strobj^.name)
        ELSE
          PutConstC(0X)
        END;
        WHILE (constLen MOD  4) # 0 DO PutConstB(0) END;
        (* RTTI+ *)
        nofNameTab:=0;
        nofTypeTab:=0;
        BuildRTTI(typ, 0, ".", TRUE,
                  entryNameTab,nofNameTab,
                  entryTypeTab,nofTypeTab);
        PutRTTI(PutConstW,PutConstC,entryNameTab,nofNameTab,entryTypeTab,nofTypeTab);
        
        (* RTTI- *)
        PutConstD(0);                   (* 4 reserved bytes for GC            *)
        PutConstD(namePos);             (* pointer to name of record type     *)
                                        (* no need any more for -> CS fixup done in OPC.InitTypDesc   *)
        DefineFixup(CFIXUP_DATA,Coff.symInxConst,constLen-4);                                
        PutConstD(typ^.size);           (* size of record type                *)
        typ^.tdadr:=constLen;
        i:=typ^.extlev;
        WHILE i > 0 DO PutConstD(0); DEC(i) END;
        PutConstD(typ^.tdadr);
        DefineFixup(CFIXUP_DATA,Coff.symInxConst,constLen-4);
        i:=maxRecordExt - typ^.extlev - 1 + SHORT(typ^.n);
        WHILE i > 0 DO PutConstD(0); DEC(i) END;
      ELSE                              (* imported typtag                    *)
      END;
    ELSIF typ^.comp = DynArr THEN       (* no type-descriptor for dyn. array  *)
    ELSE                                (* Array                              *)
      AllocBounds(0, typ^.n-1, typ^.tdadr)
    END;
  END AllocTypDesc;

(*----------------------------------------------------------------------------*)
  PROCEDURE AllocCaseTab*(low, high: LONGINT; VAR tab: LONGINT);
    (* function:      allocate room for a case table in code area             *)
    (* precondition:  low, high = low and high index for case jump            *)
    (* postcondition: tab = address, where the case table starts              *)
  VAR
    pcAfterTable:LONGINT;
  BEGIN 
    tab:=pc;
    pcAfterTable:=pc+(high-low+1)*4;
    WHILE low <= high DO
      DefineFixup(FIXUP_CODE_SECTION,0,pc);
      PutD(pcAfterTable);
      INC(low)
    END;
  END AllocCaseTab;

(*----------------------------------------------------------------------------*)
  PROCEDURE CaseJump*(tab, from, to: LONGINT);
    (* function:      writes jump-offsets into case table 'tab' to jump for the*)
    (*                values 'from'..'to' to the current pc location          *)
    (* precondition:  from = starting index                                   *)
    (*                to = end index                                          *)

  VAR 
    h: LONGINT;
  BEGIN
    h:=pc;
    pc:=tab + 4 * from;
    WHILE from <= to DO 
      PutD(h); 
      INC(from);
    END;
    pc:=h
  END CaseJump;

(*----------------------------------------------------------------------------*)

  PROCEDURE BegStat*;
    (* function:      general-purpose procedure which is called before each   *)
    (*                statement                                               *)
  BEGIN
    Reg.ResetFSP;
    INC(nofStat); (*!L*)
  END BegStat;

(*----------------------------------------------------------------------------*)
  PROCEDURE EndStat*;
    (* function:      general-purpose procedure which is called after each    *)
    (*                statement                                               *)

  BEGIN 
    Reg.CheckRegTabsEmpty;
  END EndStat;

(*----------------------------------------------------------------------------*)

PROCEDURE BegProc*(stackFramePatch,stackFrameSize:LONGINT; nesting:INTEGER);
(* Called at the beginning of procedures. Nested calls of BegProc and EndProc are
   not allowed. *)
BEGIN
  Reg.ResetVirtRegisters;
  virtRegPatch:=stackFramePatch;
  virtRegStart:=stackFrameSize;
  virtRegNesting:=nesting;
  virtRegOffs:=stackFrameSize+nesting*4+4;
  IF stackFrameSize MOD 4#0 THEN OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"stackframe not aligned") END;
  firstExit:=TRUE;
END BegProc;

(*----------------------------------------------------------------------------*)

PROCEDURE EndProc*;
(* Called at the exit points of procedures *)
VAR
  h:LONGINT;
  nesting:INTEGER;
BEGIN
  IF firstExit & (GetW(virtRegPatch)#virtRegStart) THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.EndProc");
(*    Debug.WriteInt(GetB(virtRegPatch-1)); Debug.WriteStr("  ");
    Debug.WriteInt(GetW(virtRegPatch)); Debug.WriteStr("  ");
    Debug.WriteInt(GetB(virtRegPatch+2)); Debug.WriteStr("  ");
    Debug.WriteInt(GetB(virtRegPatch+3)); Debug.WriteStr("  ");
    Debug.WriteInt(GetB(virtRegPatch+4)); Debug.WriteLn;
    Debug.WriteStr("patch addr  "); Debug.WriteInt(virtRegPatch); Debug.WriteLn;
    Debug.WriteStr("local size  "); Debug.WriteInt(virtRegStart); Debug.WriteLn;
    Debug.ShowOutput;*)
  END;
  nesting:=GetB(virtRegPatch+2);
  IF nesting#virtRegNesting THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.EndProc nesting");
  END;
  h:=pc;
  pc:=virtRegPatch;
  PutW(Reg.VirtRegisterStackSize()+virtRegStart);
  pc:=h;
  firstExit:=FALSE;
END EndProc;

(*----------------------------------------------------------------------------*)
PROCEDURE CopyItem*(VAR x, y: Item);
  (* function:      copies the contents of item x to item y    *)
  (* precondition:  'x' is initialized                                 *)
  (* postcondition:  y:=x                                          *)

  PROCEDURE CopyGenReg(VAR a, b: Reg.RegisterT);
  VAR 
    x: Item;
  BEGIN
    IF a.reg IN Reg.GENERAL_REGS THEN
      x.mode:=MODE_REG;
      x.bas:=a;
      Reg.GetGenReg(b);
      PutOM(4, 08BH, b.reg, x); (* MOV Gd,Ed *)
    END
  END CopyGenReg;

  PROCEDURE CopySegReg(VAR a, b: Reg.RegisterT);
  BEGIN
    IF a.reg IN Reg.SEGMENT_REGS THEN
      Reg.MoveSegRegIn(a);
      PushReg(2, a.reg);
      Reg.GetSegReg(b);
      PopReg(2, b.reg);
    END
  END CopySegReg;

BEGIN
  y:=x;
  CASE x.mode OF
    MODE_REG:        CopyGenReg(x.bas, y.bas);
  | MODE_ABS,
    MODE_ABS_RELOC:  CopySegReg(x.seg, y.seg);
  | MODE_REGI,
    MODE_REGI_RELOC: CopySegReg(x.seg, y.seg); CopyGenReg(x.bas, y.bas);
  | MODE_REGX,
    MODE_REGX_RELOC: CopySegReg(x.seg, y.seg); CopyGenReg(x.bas, y.bas); CopyGenReg(x.inx, y.inx);
  | MODE_INX,
    MODE_INX_RELOC:  CopySegReg(x.seg, y.seg); CopyGenReg(x.inx, y.inx);
  ELSE
  END
END CopyItem;

(*----------------------------------------------------------------------------*)

PROCEDURE TransferItem*(VAR x: Item; VAR regs: Reg.RegSetT; VAR y: Item);
  (* function:      Is called after 'SaveRegisters'. Makes the item 'x'     *)
  (*                also usable after 'SaveRegisters' .                     *)
  (* precondition:  x = correct item for use before 'SaveRegisters'         *)
  (* postcondition: y = substitute for x to be used after 'SaveRegisters'   *)

BEGIN
  y:=x;
  CASE y.mode OF
    MODE_REG:        Reg.TransferReg(x.bas, regs, y.bas);
  | MODE_ABS,
    MODE_ABS_RELOC:  Reg.TransferReg(x.seg, regs, y.seg);
  | MODE_REGI,
    MODE_REGI_RELOC: Reg.TransferReg(x.seg, regs, y.seg); 
                     Reg.TransferReg(x.bas, regs, y.bas)
  | MODE_REGX,
    MODE_REGX_RELOC: Reg.TransferReg(x.seg, regs, y.seg); 
                     Reg.TransferReg(x.bas, regs, y.bas);
                     Reg.TransferReg(x.inx, regs, y.inx)
  | MODE_INX,
    MODE_INX_RELOC:  Reg.TransferReg(x.seg, regs, y.seg); 
                     Reg.TransferReg(x.inx, regs, y.inx)
  ELSE
  END;
END TransferItem;

(*----------------------------------------------------------------------------*)

PROCEDURE Release*(VAR x: Item);
  (* function:      gives all the associated registers of item 'x' free     *)
  (* postcondition: all registers used in 'x' are released                  *)

BEGIN
  CASE x.mode OF
    MODE_CON:
  | MODE_REG:        Reg.ReleaseReg(x.bas)
  | MODE_ABS,
    MODE_ABS_RELOC:  Reg.ReleaseReg(x.seg)
  | MODE_REGI,
    MODE_REGI_RELOC: Reg.ReleaseReg(x.seg); Reg.ReleaseReg(x.bas)
  | MODE_REGX,
    MODE_REGX_RELOC: Reg.ReleaseReg(x.seg); Reg.ReleaseReg(x.bas); Reg.ReleaseReg(x.inx)
  | MODE_INX,
    MODE_INX_RELOC:  Reg.ReleaseReg(x.seg); Reg.ReleaseReg(x.inx)
  | DArr:            Reg.ReleaseReg(x.bas);
                     IF (x.disp = MODE_REGI) OR (x.disp=MODE_REGI_RELOC) THEN Reg.ReleaseReg(x.inx) END
  ELSE
  END;
  x.mode:=0
END Release;

PROCEDURE GetFunctionReturnValue*(VAR regs: Reg.RegSetT; VAR x: Item);
  (* function:      retrieve the return value of a function and restore
                    the previously saved register set      *)
  (* precondition:  x = previously called procedure                           *)
  (* postcondition: x = function result                                     *)
VAR 
  vreg, rreg: INTEGER; 
  h, adr, ra, rd: Item; 
  realResult: BOOLEAN;
BEGIN
  realResult:=(x.typ # OPT.notyp) & (x.typ^.form IN realSet);
  Reg.ResetFSP;
  IF realResult THEN Reg.IncFSP END;
  IF regs.floatStackUsage > 0 THEN
    IF realResult THEN Reg.MoveFloatRegOut(0) END;    (* save float result *)
    WHILE Reg.floatStackUsage<regs.floatStackUsage DO (* restore float stack *)
      Reg.MoveFloatRegIn(Reg.floatStackUsage+1);
    END;
    IF realResult THEN                            (* put float result in top of stack *)
      Reg.MoveFloatRegIn(0);
    END;
  END;
  
(*    PutB(09BH); (* WAIT *)!!! ??? *)
  Reg.RestoreCPURegisters(regs);

  IF x.typ # OPT.notyp THEN
    IF realResult THEN
      x.mode:=MODE_FSTK;
    ELSE
      x.mode:=MODE_REG;
      Reg.GetThisReg(x.bas, Reg.EAX);
      Reg.SetAllowedRegs(x.bas,Reg.BYTE_REGS);
    END
  END
END GetFunctionReturnValue;

(*============================================================================*)
  
PROCEDURE GenCodeRegToMem(creg:INTEGER; virtRegSlot:INTEGER);
(* copy CPU register to virtual register slot *)
BEGIN
  IF creg>=Reg.ES THEN
    PutC(08CX);  (* MOV r/m16, Sreg *)
    PutC(CHR(5+(creg-8)*8+80H));
    PutD(-virtRegOffs-4*virtRegSlot);
  ELSE
    PutC(089X);  (* MOV r/m32, r32 *)
    PutC(CHR(5+creg*8+80H));
    PutD(-virtRegOffs-4*virtRegSlot);
  END;
END GenCodeRegToMem;

PROCEDURE GenCodeMemToReg(creg:INTEGER; virtRegSlot:INTEGER);
(* copy virtual register slot to CPU register  *)
BEGIN
  IF creg>=Reg.ES THEN
    PutC(08EX);  (* MOV Sreg, r/m16 *)
    PutC(CHR(5+(creg-8)*8+80H));
    PutD(-virtRegOffs-4*virtRegSlot);
  ELSE
    PutC(08BX);  (* MOV r32, r/m32 *)
    PutC(CHR(5+creg*8+80H));
    PutD(-virtRegOffs-4*virtRegSlot);
  END;
END GenCodeMemToReg;

PROCEDURE GenCodePushReg(CPURegCode:INTEGER);
(* push a CPU register *)
BEGIN
  IF CPURegCode<=Reg.EDI THEN
    PushReg(4,CPURegCode);
  ELSE
    PushReg(2,CPURegCode);
  END;
END GenCodePushReg;

PROCEDURE GenCodePopReg(CPURegCode:INTEGER);
(* pop a CPU register *)
BEGIN
  IF CPURegCode<=Reg.EDI THEN
    PopReg(4,CPURegCode);
  ELSE
    PopReg(2,CPURegCode);
  END;
END GenCodePopReg;

PROCEDURE GenCodeRegToReg(fromCReg:INTEGER; toCReg:INTEGER);
(* copy CPU register to CPU register  *)
VAR
  x:Item;
BEGIN
  IF (fromCReg>=Reg.ES) OR (toCReg>=Reg.ES) THEN
    GenCodePushReg(fromCReg);
    GenCodePopReg(toCReg);
  ELSE
    PutC(08BX);  (* MOV r32, r/m32 *)
    PutC(CHR(fromCReg+toCReg*8+0C0H));
  END;
END GenCodeRegToReg;

PROCEDURE GenCodeXchgRegReg(cReg1:INTEGER; cReg2:INTEGER);
(* exchange CPU register contents  *)
BEGIN
  IF (cReg1>=Reg.ES) OR (cReg2>=Reg.ES) THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"OPL.GenCodeXchgRegReg");
    RETURN;
  END;
  PutC(087X);  (* XCHG r32, r/m32 *)
  PutC(CHR(cReg1+cReg2*8+0C0H));
END GenCodeXchgRegReg;

PROCEDURE GenCodeStoreFloat(virtRegSlot:INTEGER); 
(* store m80real to virtRegSlot and pop *)
VAR
  x:Item;
BEGIN
  x.mode:=MODE_REGI;
  x.disp:=-virtRegOffs-4*virtRegSlot-8;
  x.bas.reg:=Reg.EBP;
  x.seg.reg:=Reg.SS;
  PutOM(4,0DBH,7,x); (* FSTP m80real *)
END GenCodeStoreFloat;

PROCEDURE GenCodeGetFloat(virtRegSlot:INTEGER);
(* push m80real from virtRegSlot *)
VAR
  x:Item;
BEGIN
  x.mode:=MODE_REGI;
  x.disp:=-virtRegOffs-4*virtRegSlot-8;
  x.bas.reg:=Reg.EBP;
  x.seg.reg:=Reg.SS;
  PutOM(4,0DBH,5,x); (* FLD m80real *)
END GenCodeGetFloat;
 
(*============================================================================*)

  PROCEDURE ResetFixups*;
  (* function: reset list of fixups *)
  BEGIN
    nofFixup:=0; 
  END ResetFixups;

  PROCEDURE SetVirtRegStart*(offset:LONGINT);
  BEGIN
    virtRegStart:=offset;
  END SetVirtRegStart;

  PROCEDURE Init*(debugInfo: BOOLEAN);
    (* function:      initializes the global variables of this module         *)
  VAR 
    i: INTEGER;
  BEGIN
    NEW(importList); 
    lastImport:=importList; importList^.next:=NIL; importList^.obj:=NIL;
    NEW(constPtr);
    NEW(fixupPtr);
    NEW(comList); 
    lastCom:=comList; comList^.next:=NIL; comList^.obj:=NIL;
    NEW(typDescList); 
    lastTypDesc:=typDescList; typDescList^.next:=NIL; typDescList^.str:=NIL;
    ResetFixups;
    constLen:=0; level:=0; pc:=0; 
    modBodyEnd:=0; 
    nofImport:=0; 
    nofComm:=0; 
    nofNameTab:=0;
    nofTypeTab:=0;
    nofTypDesc:=0; 
    dsize:=32;  (* the first 16 Bytes in each global heapblock are used by Windows ??? TRUE ??? !!!         *)
    nofStat:=0; (*!L*)
    modInitAdr:=-1;
    modDescLabel:=0;
    Reg.Init(GenCodeRegToMem, GenCodeMemToReg,
             GenCodeXchgRegReg, GenCodeRegToReg,
             GenCodePushReg, GenCodePopReg,
             GenCodeStoreFloat, GenCodeGetFloat);
    virtRegStart:=0;
    virtRegPatch:=-1;
    virtRegNesting:=0;
    virtRegOffs:=0;
    firstExit:=TRUE;
  END Init;

(*============================================================================*)

END OPL.
