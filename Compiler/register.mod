(******************************************************************************)
(*                                                                            *)
(**)                        MODULE Register;                                (**)
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
(* AUTHORS: Richard De Moliner, Bernhard Leisch                               *)
(******************************************************************************)
(* PURPOSE: This module manages both CPU- and virtual registers.              *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*   Virtual registers are maintained on the stack similar to local variables.*)
(******************************************************************************)


IMPORT OPM,E:=Error,Debug;

CONST
    (* 80386 general- and segment register codes             *)
    EAX* = 0;  ECX* = 1;  EDX* = 2;  EBX* = 3; 
    ESP* = 4;  EBP* = 5;  
    ESI* = 6;  EDI* = 7;
    ES*  = 8;  CS*  = 9;  SS*  =10; 
    DS*  =11;  FS*  =12;  GS*  =13; 
    EIP* =14;  EFLAGS* = 15;
    NONE*=16; (* only used for error processing *)
    FREE*=-1;
    
    NOF_FLOAT_REGS* = 8;             (* number of floating point stack registers *)

    NOF_MEM_REGS = 20 + 3*NOF_FLOAT_REGS;
       (* maximum number of registers kept in memory at the same time,
                          must be > 3*NOF_FLOAT_REGS to save float registers *)
    
    NOF_GENERAL_REGS = 6;  
    GENERAL_REGS* = {EAX, ECX, EDX, EBX, ESI, EDI};
    
    NOF_BYTE_REGS = 4;
    BYTE_REGS* = {EAX, ECX, EDX, EBX};
    
    NOF_SEGMENT_REGS = 3;
    SEGMENT_REGS* = {ES, FS, GS};

    ADD_GEN_REGS* = {ESP, EBP};
    ADD_SEG_REGS* = {CS, SS, DS};

    ADD_REGS*=ADD_GEN_REGS + ADD_SEG_REGS;
    GENERAL_REGS_EX* = GENERAL_REGS + ADD_GEN_REGS;
    SEGMENT_REGS_EX* = SEGMENT_REGS + ADD_SEG_REGS;
    REGS* = GENERAL_REGS + SEGMENT_REGS;
    REGS_EX*=GENERAL_REGS_EX + SEGMENT_REGS_EX;
    
    NOF_REGISTERS = NOF_GENERAL_REGS + NOF_SEGMENT_REGS;
    
    NOF_VIRTUAL_REGS = NOF_REGISTERS + NOF_MEM_REGS; (* maximum number of virtual registers *)
    
    FLOATBASE=1000;

TYPE
  (* This type represents a virtual register. It can rESIde either in a 
     specific CPU register or in memory. *)
  RegisterT* = RECORD 
                 reg*:INTEGER; (* code for an actual CPU register (REG_... constants) *) 
                 key*:INTEGER; (* index into the global virtRegTab table, which also
                                  knows whether the register is currently accessible
                                  in the CPU or stored in memory *)
               END;

  RegEntryT* = RECORD
               reg-: INTEGER;   (* actual CPU register currently assigned
                                  if inReg is TRUE and index of memory 
                                  register otherwise *)
               inReg-: BOOLEAN; (* TRUE if virtual register is in CPU *)
               age: LONGINT;   (* the least recently used register has the smallest value *)
               allowed-: SET;   (* set of CPU registers which might be used to store the
                                  virtual register in the CPU *)                                  
             END;
             
  VirtRegTabT = ARRAY NOF_VIRTUAL_REGS OF RegEntryT;
  
  CpuRegTabT = ARRAY 16 OF INTEGER; (* CPU register codes are used as 
               an index to this table. The value stored is either FREE
               or an index into the global virtRegTab. *)

  MemRegTabT = ARRAY NOF_MEM_REGS OF INTEGER; (* The values stored are either 
               FREE for free memory slots or 
               an index into the global virtRegTab or
               >FLOATBASE, where  value MOD FLOATBASE=float reg number. *)
    
  RegSetT* = RECORD
               floatStackUsage-: LONGINT;
               virtRegTab: VirtRegTabT;
               cpuRegTab: CpuRegTabT;
             END; 

  GenCodeRMT=PROCEDURE (reg:INTEGER; virtRegSlot:INTEGER);
  GenCodeRRT=PROCEDURE (fromCReg:INTEGER; toCReg:INTEGER);
  GenCodeRT=PROCEDURE (CPUreg:INTEGER);
  GenCodeFloatT=PROCEDURE (virtRegSlot:INTEGER);
  
VAR
  genCodeRegToMem:GenCodeRMT;
  genCodeMemToReg:GenCodeRMT;
  genCodeRegToReg:GenCodeRRT;
  genCodePushReg:GenCodeRT;
  genCodePopReg:GenCodeRT;
  genCodeXchgRegReg:GenCodeRRT;
  genCodeStoreFloat:GenCodeFloatT; (* store m80real to virtRegSlot and pop *)
  genCodeGetFloat:GenCodeFloatT;   (* push m80real from virtRegSlot *)
  
  virtRegTab-: VirtRegTabT;
  cpuRegTab: CpuRegTabT;
  memRegTab: MemRegTabT;
  genRegPos, bytRegPos, segRegPos: INTEGER;
  curAge: LONGINT;
  maxMemReg:INTEGER; (* highest slot number for memory register location used
                        since the last call to ResetVirtRegisters *)

  floatStackUsage*:INTEGER; 


PROCEDURE InitRegTabs;
  (* function:      initializes the tables for the register management   *)
VAR 
  i: INTEGER;
BEGIN
  i:=0;
  WHILE i < NOF_VIRTUAL_REGS DO 
    virtRegTab[i].reg:=FREE; 
    virtRegTab[i].inReg:=FALSE;
    INC(i);
  END;
  i:=EAX;
  WHILE i <= EFLAGS DO cpuRegTab[i]:=FREE; INC(i) END;
  i:=0;
  WHILE i < NOF_MEM_REGS DO memRegTab[i]:=FREE; INC(i) END;
END InitRegTabs;

PROCEDURE DebugShowState*();
(* function: create a pop-up window with a view stats about register allocation *)
VAR 
  i,c: INTEGER;
BEGIN
  i:=0;
  c:=0;
  WHILE i < NOF_VIRTUAL_REGS DO
    IF virtRegTab[i].reg # FREE THEN 
      INC(c);
    END;
    INC(i)
  END;
  Debug.WriteStr("allocations in virtRegTab: "); Debug.WriteInt(c); Debug.WriteLn;
  i:=EAX;
  c:=0;
  WHILE i <= EFLAGS DO
    IF cpuRegTab[i] # FREE THEN 
      INC(c);
    END;
    INC(i)
  END;
  Debug.WriteStr("allocations in cpuRegTab: "); Debug.WriteInt(c); Debug.WriteLn;
  i:=0;
  c:=0;
  WHILE i < NOF_MEM_REGS DO
    IF memRegTab[i] # FREE THEN 
      INC(c);
    END;
    INC(i)
  END; 
  Debug.WriteStr("allocations in memRegTab: "); Debug.WriteInt(c); Debug.WriteLn;
  Debug.ShowOutput;
END DebugShowState;

PROCEDURE CheckRegTabsEmpty*();
(* function: checks whether all registers are currently unused *)
VAR 
  i: INTEGER;
  error:BOOLEAN;
BEGIN
  error:=FALSE;
  i:=0;
  WHILE i < NOF_VIRTUAL_REGS DO
    IF virtRegTab[i].inReg THEN 
      error:=TRUE;
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"register (not empty 1)") 
    END;
    IF virtRegTab[i].reg # FREE THEN 
      error:=TRUE;
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"register (not empty 2)") 
    END;
    INC(i)
  END;
  i:=EAX;
  WHILE i <= EFLAGS DO
    IF cpuRegTab[i] # FREE THEN 
      error:=TRUE;
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"register (not empty 3)") 
    END;
    INC(i)
  END;
  i:=0;
  WHILE i < NOF_MEM_REGS DO
    IF memRegTab[i] # FREE THEN 
      error:=TRUE;
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"register (not empty 4)") 
    END;
    INC(i)
  END; 
  IF error THEN InitRegTabs END;
END CheckRegTabsEmpty;

PROCEDURE ResetVirtRegisters*();
(* called at the entry of procedures; resets statistics of memory register
 usage. *)
BEGIN
  maxMemReg:=-1; (* no slot used yet *)
END ResetVirtRegisters;

PROCEDURE VirtRegisterStackSize*():LONGINT;
(* Returns the amount of stack needed for memory register usage since the
   last call to ResetVirtRegisters. *)
BEGIN
  RETURN (maxMemReg+1)*4;
END VirtRegisterStackSize;

(*----------------------------------------------------------------------------*)

PROCEDURE ResetFSP*;
BEGIN
  floatStackUsage:=0;
END ResetFSP;

PROCEDURE IncFSP*;
  (* function:      floating point stack pointer is incremented             *)

BEGIN
  INC(floatStackUsage);
  IF floatStackUsage >= NOF_FLOAT_REGS THEN OPM.Err(E.OUT_OF_FLOAT_REGISTERS) END
END IncFSP;

(*----------------------------------------------------------------------------*)
PROCEDURE DecFSP*;
  (* function:      floating point stack pointer is decremented             *)

BEGIN
  IF floatStackUsage = 0 THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"DecFSP");
  ELSE
    DEC(floatStackUsage)
  END
END DecFSP;

(*----------------------------------------------------------------------------*)
PROCEDURE ZeroFSP*(): BOOLEAN;
  (* function:      checks whether floating point stack pointer is zero                           *)

BEGIN
  RETURN floatStackUsage = 0
END ZeroFSP;

(*----------------------------------------------------------------------------*)
PROCEDURE SetAllowedRegs*(VAR x:RegisterT; regs:SET);
BEGIN
  virtRegTab[x.key].allowed:=regs;
END SetAllowedRegs;

(*----------------------------------------------------------------------------*)
PROCEDURE NextAge(): LONGINT;
  (* function:      returns the next age (for register deallocation)        *)
BEGIN 
  INC(curAge); 
  RETURN curAge-1;
END NextAge;

PROCEDURE IncGenRegPos;
  (* function:      sets 'genRegPos' to the next general register           *)
BEGIN 
  CASE genRegPos OF
    EAX:genRegPos:=ECX;
  | ECX:genRegPos:=EDX;
  | EDX:genRegPos:=EBX;
  | EBX:genRegPos:=ESI;
  | ESI:genRegPos:=EDI;
  | EDI:genRegPos:=EAX;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.IncGenRegPos");
  END;
END IncGenRegPos;

(*----------------------------------------------------------------------------*)
PROCEDURE IncBytRegPos;
  (* function:      sets 'bytRegPos' to the next byte register              *)
BEGIN 
  IF bytRegPos = EBX THEN bytRegPos:=EAX ELSE INC(bytRegPos) END
END IncBytRegPos;

(*----------------------------------------------------------------------------*)
PROCEDURE IncSegRegPos;
  (* function:      sets 'segRegPos' to the next segment register           *)
BEGIN 
  CASE segRegPos OF
    ES:segRegPos:=FS;
  | FS:segRegPos:=GS;
  | GS:segRegPos:=ES;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.IncSegRegPos");
  END;
END IncSegRegPos;

(*----------------------------------------------------------------------------*)

PROCEDURE AllocMemReg*(VAR inx:INTEGER);
BEGIN
  inx:=0;
  WHILE (inx<NOF_MEM_REGS) & (memRegTab[inx] # FREE) DO INC(inx) END;
  IF inx=NOF_MEM_REGS THEN
    OPM.Err(E.OUT_OF_MEM_REGS);
  ELSE
    memRegTab[inx]:=FLOATBASE-1;
    IF inx>maxMemReg THEN maxMemReg:=inx END;
  END;
END AllocMemReg;

(*----------------------------------------------------------------------------*)
PROCEDURE NextGenReg():INTEGER;
  (* function:      returns the next free general register                  *)
VAR 
  i, creg, vreg: INTEGER; 
  age: LONGINT;
BEGIN 
  i:=0; 
  age:=curAge;
  vreg:=cpuRegTab[genRegPos];
  WHILE (vreg#FREE) & (i < NOF_GENERAL_REGS) DO
    IF virtRegTab[vreg].age < age THEN 
      age:=virtRegTab[vreg].age;
      creg:=genRegPos;
    END;
    IncGenRegPos; 
    vreg:=cpuRegTab[genRegPos];
    INC(i);
  END;
  IF vreg = FREE THEN 
    RETURN genRegPos;
  ELSE
    RETURN creg
  END;
END NextGenReg;

(*----------------------------------------------------------------------------*)
PROCEDURE NextBytReg():INTEGER;
  (* function:      returns the next free byte register                     *)
VAR 
  i, creg, vreg: INTEGER; 
  age: LONGINT;
BEGIN 
  i:=0; 
  age:=curAge;
  vreg:=cpuRegTab[bytRegPos];
  WHILE (vreg#FREE) & (i < NOF_BYTE_REGS) DO
    IF virtRegTab[vreg].age < age THEN 
      age:=virtRegTab[vreg].age;
      creg:=bytRegPos;
    END;
    IncBytRegPos; 
    vreg:=cpuRegTab[bytRegPos];
    INC(i);
  END;
  IF vreg = FREE THEN 
    RETURN bytRegPos;
  ELSE
    RETURN creg;
  END;
END NextBytReg;

(*----------------------------------------------------------------------------*)
PROCEDURE NextSegReg():INTEGER;
  (* function:      retruns the next free segment register                  *)
BEGIN
  IF cpuRegTab[segRegPos] = FREE THEN RETURN segRegPos END;
  IncSegRegPos;
  IF cpuRegTab[segRegPos] = FREE THEN RETURN segRegPos END;
  IncSegRegPos;
  IF cpuRegTab[segRegPos] = FREE THEN RETURN segRegPos END;
  IF virtRegTab[cpuRegTab[ES]].age < virtRegTab[cpuRegTab[FS]].age THEN
    RETURN ES
  ELSE
    RETURN FS
  END
END NextSegReg;

(*----------------------------------------------------------------------------*)
PROCEDURE MoveVirtRegOut(vreg: INTEGER);
  (* function:      move contents of virtual register from cpu to memory    *)
VAR 
  to: INTEGER;
  from:INTEGER;
BEGIN
  IF virtRegTab[vreg].inReg THEN 
    AllocMemReg(to);
    from:=virtRegTab[vreg].reg;
    genCodeRegToMem(from,to);
    cpuRegTab[from]:=FREE;
    memRegTab[to]:=vreg;
    virtRegTab[vreg].reg:=to;
    virtRegTab[vreg].inReg:=FALSE;
  END;
END MoveVirtRegOut;

(*----------------------------------------------------------------------------*)

PROCEDURE AllocFloatMemReg*(floatReg:INTEGER; VAR inx:INTEGER);
(* allocate a continuous space of 10 (actually 12) bytes in the memory registers *)
VAR
  free: INTEGER;
BEGIN
  free:=0;
  inx:=0;
  WHILE (free<3) & (inx<NOF_MEM_REGS) DO
    IF memRegTab[inx]=FREE THEN
      INC(free);
    ELSE
      free:=0;
    END;
    INC(inx);
  END;
  IF free=3 THEN
    INC(floatReg,FLOATBASE);
    inx:=inx-3;
    memRegTab[inx  ]:=floatReg;
    memRegTab[inx+1]:=floatReg;
    memRegTab[inx+2]:=floatReg;
    IF inx+2>maxMemReg THEN maxMemReg:=inx+2 END;
  ELSE
    inx:=0;
    OPM.Err(E.OUT_OF_MEM_REGS);
  END;
END AllocFloatMemReg;

(*----------------------------------------------------------------------------*)

PROCEDURE ReleaseMemReg*(inx:INTEGER);
BEGIN
  memRegTab[inx]:=FREE;
END ReleaseMemReg;

(*----------------------------------------------------------------------------*)

PROCEDURE MoveFloatRegOut*(floatReg:INTEGER);
  (* function:      move contents of top of float stack register from cpu to memory and pop   *)
VAR 
  inx: INTEGER;
BEGIN
  AllocFloatMemReg(floatReg,inx);
  DecFSP;
  genCodeStoreFloat(inx);
END MoveFloatRegOut;

(*----------------------------------------------------------------------------*)

PROCEDURE MoveFloatRegIn*(floatReg:INTEGER);
(* function:      move the desired float reg from the memory registers onto
   the top of the float register stack *)
VAR 
  inx: INTEGER;
BEGIN
  INC(floatReg,FLOATBASE);
  inx:=0;
  WHILE (inx<NOF_MEM_REGS) & (memRegTab[inx]#floatReg) DO INC(inx) END;
  IF inx<NOF_MEM_REGS THEN
    IncFSP;
    genCodeGetFloat(inx);
    memRegTab[inx  ]:=FREE;
    memRegTab[inx+1]:=FREE;
    memRegTab[inx+2]:=FREE;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveFloatRegIn");
  END;
END MoveFloatRegIn;

(*----------------------------------------------------------------------------*)
PROCEDURE FreeCpuReg(creg: INTEGER);
  (* function:      frees the register 'creg'                               *)
BEGIN 
  IF cpuRegTab[creg] # FREE THEN MoveVirtRegOut(cpuRegTab[creg]) END;
END FreeCpuReg;  

(*----------------------------------------------------------------------------*)
PROCEDURE MoveVirtRegIn(vreg: INTEGER);
  (* function:     moves a probably saved virtual register value back from  *)
  (*               the extended register field to a cpu register            *)
  (* precondition: 'vreg' = virtual register number                         *)
VAR 
  from: INTEGER; 
  regSet: SET;
  to:INTEGER;
BEGIN
  IF  ~virtRegTab[vreg].inReg THEN
    regSet:=virtRegTab[vreg].allowed;
    IF regSet = GENERAL_REGS THEN to:=NextGenReg()
    ELSIF regSet = BYTE_REGS THEN to:=NextBytReg()
    ELSIF regSet = SEGMENT_REGS THEN to:=NextSegReg()
    ELSIF regSet = {} THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveVirtRegIn");
      to:=0;
    ELSE 
      to:=0; 
      WHILE ~(to IN regSet) DO INC(to) END;
    END;
    IF cpuRegTab[to] # FREE THEN MoveVirtRegOut(cpuRegTab[to]) END;
    from:=virtRegTab[vreg].reg;
    memRegTab[from]:=FREE;
    cpuRegTab[to]:=vreg;
    virtRegTab[vreg].reg:=to;
    virtRegTab[vreg].inReg:=TRUE;
    virtRegTab[vreg].age:=NextAge();
    genCodeMemToReg(to,from);
  END
END MoveVirtRegIn;

(*----------------------------------------------------------------------------*)
PROCEDURE MoveGenRegIn*(VAR reg: RegisterT);
  (* function:      moves a possibly saved register value back from the      *)
  (*                extended register field to a genereal cpu register      *)
  (* precondition:  'reg' is registered in the virtual register table       *)
  (* postcondition: 'reg' is a general cpu register                         *)

BEGIN
  IF reg.reg IN GENERAL_REGS THEN
    IF (reg.key<0) OR (reg.key>=NOF_VIRTUAL_REGS) THEN
      Debug.WriteStr("MoveGenRegIn"); Debug.WriteLn;
      Debug.WriteStr("reg.reg "); Debug.WriteInt(reg.reg); Debug.WriteLn;
      Debug.WriteStr("reg.key "); Debug.WriteInt(reg.key); Debug.WriteLn;
      Debug.ShowOutput;
      OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"Register.MoveGenRegIn 1");
      RETURN;
    ELSE
      IF virtRegTab[reg.key].inReg THEN 
        virtRegTab[reg.key].age:=NextAge()
      ELSE 
        MoveVirtRegIn(reg.key)
      END;
      reg.reg:=virtRegTab[reg.key].reg;
    END;
  ELSIF ~(reg.reg IN ADD_GEN_REGS) THEN (* ESP, EBP need not be moved because they are never used for different purposes *)
    OPM.CommentedErr(E.INTERNAL_MURKS,"MoveGenRegIn 2");
  END;
END MoveGenRegIn;

(*----------------------------------------------------------------------------*)
PROCEDURE MoveSegRegIn*(VAR seg: RegisterT);
  (* function:      moves a probably saved segment register value back from *)
  (*                the extended register field to a cpu segment register   *)
  (* precondition:  'seg' is registered in the virtual register table       *)
  (* postcondition: 'seg' is a cpu segment register                         *)

BEGIN
  IF (seg.reg<0) OR (seg.reg>MAX(SET)) THEN 
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveSegRegIn 3");
    RETURN;
  END;
  IF seg.reg IN SEGMENT_REGS THEN
    IF (seg.key<0) OR (seg.key>=NOF_VIRTUAL_REGS) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveSegRegIn 1");
      RETURN;
    END;
    IF virtRegTab[seg.key].inReg THEN 
      virtRegTab[seg.key].age:=NextAge();
    ELSE 
      MoveVirtRegIn(seg.key);
    END;
    seg.reg:=virtRegTab[seg.key].reg;
  ELSIF ~(seg.reg IN ADD_SEG_REGS) THEN (* {CS, SS, DS} need not be moved because they are never used for different purposes *)
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveSegRegIn 2");
  END;
END MoveSegRegIn;

(*----------------------------------------------------------------------------*)
PROCEDURE GetGenReg*(VAR r: RegisterT);
  (* function:      returns a free general register                         *)
  (* postcondition: r = free general register                               *)
VAR 
  vreg, creg: INTEGER;
BEGIN 
  vreg:=0;
  WHILE (vreg < NOF_VIRTUAL_REGS) & (virtRegTab[vreg].reg # FREE) DO INC(vreg) END;
  IF vreg < NOF_VIRTUAL_REGS THEN
    creg:=NextGenReg();
    FreeCpuReg(creg);
    cpuRegTab[creg]:=vreg;
    virtRegTab[vreg].reg:=creg;
    virtRegTab[vreg].inReg:=TRUE;
    virtRegTab[vreg].age:=NextAge();
    virtRegTab[vreg].allowed:=GENERAL_REGS;
    r.reg:=creg;
    r.key:=vreg;
  ELSE
    r.reg:=NONE;
    OPM.Err(E.OUT_OF_REGISTERS)                       (* expression to complex              *)
  END;
END GetGenReg;

(*----------------------------------------------------------------------------*)
PROCEDURE GetByteReg*(VAR r: RegisterT);
  (* function:      returns a free byte register                            *)
  (* postcondition: r = free byte register                                  *)

VAR 
  vreg, creg: INTEGER;
BEGIN 
  vreg:=0;
  WHILE (vreg < NOF_VIRTUAL_REGS) & (virtRegTab[vreg].reg # FREE) DO INC(vreg) END;
  IF vreg < NOF_VIRTUAL_REGS THEN
    creg:=NextBytReg();
    FreeCpuReg(creg);
    cpuRegTab[creg]:=vreg;
    virtRegTab[vreg].reg:=creg;
    virtRegTab[vreg].inReg:=TRUE;
    virtRegTab[vreg].age:=NextAge();
    virtRegTab[vreg].allowed:=BYTE_REGS;
    r.reg:=creg;
    r.key:=vreg;
  ELSE
    r.reg:=NONE;
    OPM.Err(E.OUT_OF_REGISTERS)                       (* expression to complex              *)
  END;
END GetByteReg;

(*----------------------------------------------------------------------------*)
PROCEDURE GetSegReg*(VAR r: RegisterT);
  (* function:      returns a free segment register                         *)
  (* postcondition: r = free segment register                               *)

VAR 
  vreg, creg: INTEGER;
BEGIN 
  vreg:=0;
  WHILE (vreg < NOF_VIRTUAL_REGS) & (virtRegTab[vreg].reg # FREE) DO INC(vreg) END;
  IF vreg < NOF_VIRTUAL_REGS THEN
    creg:=NextSegReg();
    FreeCpuReg(creg);
    cpuRegTab[creg]:=vreg;
    virtRegTab[vreg].reg:=creg;
    virtRegTab[vreg].inReg:=TRUE;
    virtRegTab[vreg].age:=NextAge();
    virtRegTab[vreg].allowed:=SEGMENT_REGS;
    r.reg:=creg;
    r.key:=vreg;
  ELSE
    r.reg:=NONE;
    OPM.Err(E.OUT_OF_REGISTERS)                       (* expression to complex              *)
  END;
END GetSegReg;

(*----------------------------------------------------------------------------*)
PROCEDURE GetThisReg*(VAR r: RegisterT; creg: INTEGER);
  (* function:      returns the CPU register creg in 'r' and frees it if necessary *)
  (* precondition:  creg = CPU register to be allocated                             *)
  (* postcondition: r = free CPU register 'creg'                            *)
VAR 
  vreg: INTEGER;
BEGIN 
  vreg:=0;
  WHILE (vreg < NOF_VIRTUAL_REGS) & (virtRegTab[vreg].reg # FREE) DO INC(vreg) END;
  IF vreg < NOF_VIRTUAL_REGS THEN
    FreeCpuReg(creg);
    cpuRegTab[creg]:=vreg;
    virtRegTab[vreg].reg:=creg;
    virtRegTab[vreg].inReg:=TRUE;
    virtRegTab[vreg].age:=NextAge();
    virtRegTab[vreg].allowed:={creg};
    r.reg:=creg;
    r.key:=vreg;
  ELSE
    r.reg:=NONE;
    OPM.Err(E.OUT_OF_REGISTERS)                       (* expression to complex              *)
  END;
END GetThisReg;

(*----------------------------------------------------------------------------*)
PROCEDURE MoveToThisReg*(VAR reg: RegisterT; this: INTEGER);
  (* function:      move the value of register 'reg' to 'this' CPU register     *)
  (* precondition:  this = CPU register                                         *)
  (* postcondition: reg = used register 'this'                              *)

VAR 
  creg, vreg, h: INTEGER; 
  from:INTEGER;
BEGIN
  IF (this<0) OR (this>MAX(SET)) OR ~(this IN REGS) THEN 
    OPM.CommentedErr(E.INTERNAL_MURKS,"MoveThisReg");
  ELSIF (reg.reg IN ADD_SEG_REGS) & (this IN SEGMENT_REGS) THEN
    MoveSegRegIn(reg);
    genCodePushReg(reg.reg);
    GetThisReg(reg, this);
    genCodePopReg(this);
  ELSIF (reg.reg IN ADD_GEN_REGS) & (this IN GENERAL_REGS) THEN
    MoveGenRegIn(reg);
    from:=reg.reg;
    GetThisReg(reg, this);
    genCodeRegToReg(from,reg.reg);
  ELSIF reg.reg IN REGS THEN
    vreg:=reg.key;
    IF ~virtRegTab[vreg].inReg THEN MoveVirtRegIn(vreg) END;
    creg:=virtRegTab[vreg].reg;
    IF creg # this THEN
      h:=cpuRegTab[this];
      IF (h = FREE) OR 
         ~(creg IN virtRegTab[h].allowed) OR
         ~(this IN GENERAL_REGS) THEN
        IF h # FREE THEN MoveVirtRegOut(h) END;
        genCodeRegToReg(creg,this);
        cpuRegTab[creg]:=FREE;
      ELSE
        genCodeXchgRegReg(creg,this);
        virtRegTab[h].reg:=creg;
        cpuRegTab[creg]:=h;
      END;
      cpuRegTab[this]:=vreg;
      virtRegTab[vreg].reg:=this
    END;
    virtRegTab[vreg].allowed:={this};
    virtRegTab[vreg].age:=NextAge();
    reg.reg:=this
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"MoveThisReg3");
  END; 
END MoveToThisReg;
  
(*----------------------------------------------------------------------------*)
PROCEDURE MoveToSegReg*(VAR r: RegisterT);
  (* function:      move the value of register 'r' into a segment register  *)
  (* precondition:  r = any initialized register                            *)
  (* postcondition: r = segment register                                    *)

VAR 
  vreg, creg, to: INTEGER;
BEGIN
  IF r.reg IN ADD_REGS THEN
    to:=NextSegReg();
    MoveToThisReg(r, to);
    virtRegTab[r.key].allowed:=SEGMENT_REGS;
  ELSIF r.reg IN REGS THEN
    vreg:=r.key;
    IF virtRegTab[vreg].inReg THEN
      creg:=virtRegTab[vreg].reg;
      IF ~(creg IN SEGMENT_REGS) THEN 
        MoveToThisReg(r, NextSegReg());
      ELSE 
        virtRegTab[vreg].age:=NextAge();
      END;
      virtRegTab[vreg].allowed:=SEGMENT_REGS;
    ELSE
      virtRegTab[vreg].allowed:=SEGMENT_REGS;
      MoveVirtRegIn(vreg);
    END;
    r.reg:=virtRegTab[vreg].reg;
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"MoveSegReg");
  END
END MoveToSegReg;

(*----------------------------------------------------------------------------*)
PROCEDURE MoveToGenReg*(VAR r: RegisterT);
  (* function:      move the value of register 'r' into a general register  *)
  (* precondition:  r = any initialized register                            *)
  (* postcondition: r = general register                                    *)

VAR 
  vreg, creg, to: INTEGER;
BEGIN
  IF r.reg IN ADD_REGS THEN
    to:=NextGenReg();
    MoveToThisReg(r, to);
    virtRegTab[r.key].allowed:=GENERAL_REGS;
  ELSIF r.reg IN REGS THEN
    vreg:=r.key;
    IF virtRegTab[vreg].inReg THEN
      creg:=virtRegTab[vreg].reg;
      IF ~(creg IN GENERAL_REGS) THEN 
        MoveToThisReg(r, NextGenReg());
      ELSE 
        virtRegTab[vreg].age:=NextAge();
      END;
      virtRegTab[vreg].allowed:=GENERAL_REGS;
    ELSE
      virtRegTab[vreg].allowed:=GENERAL_REGS;
      MoveVirtRegIn(vreg);
    END;
    r.reg:=virtRegTab[vreg].reg
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"MoveGenReg");
  END
END MoveToGenReg;


(*----------------------------------------------------------------------------*)
PROCEDURE MoveToByteReg*(VAR r: RegisterT);
  (* function:      move the value of register 'r' into a byte register     *)
  (* precondition:  r = any initialized register                            *)
  (* postcondition: r = byte register                                       *)

VAR 
  vreg, creg, to, h: INTEGER;
BEGIN
  IF r.reg IN ADD_REGS THEN
    to:=NextBytReg();
    MoveToThisReg(r, to);
    virtRegTab[r.key].allowed:=BYTE_REGS;
  ELSIF r.reg IN REGS THEN
    vreg:=r.key;
    IF virtRegTab[vreg].inReg THEN
      creg:=virtRegTab[vreg].reg;
      IF ~(creg IN BYTE_REGS) THEN 
        to:=EAX; 
        h:=FREE;
        WHILE (to <= EBX) & (cpuRegTab[to] # FREE) DO
          IF creg IN virtRegTab[cpuRegTab[to]].allowed THEN h:=to END;
          INC(to)
        END;
        IF to > EBX THEN
          IF h = FREE THEN to:=NextBytReg() ELSE to:=h END
        END;
        MoveToThisReg(r, to);
      ELSE 
        virtRegTab[vreg].age:=NextAge();
      END;
      virtRegTab[vreg].allowed:=BYTE_REGS;
    ELSE
      virtRegTab[vreg].allowed:=BYTE_REGS;
      MoveVirtRegIn(vreg);
    END;
    r.reg:=virtRegTab[vreg].reg
  ELSE
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.MoveToByteReg");
  END
END MoveToByteReg;

(*----------------------------------------------------------------------------*)
PROCEDURE ReleaseReg*(VAR r: RegisterT);
  (* function:      gives the previous defined register 'r' free            *)
  (* postcondition: r = released register                                   *)

BEGIN
  IF (r.reg<0) OR (r.reg>MAX(SET)) THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Register.ReleaseReg 1");
    RETURN;
  END;
  IF (r.reg IN REGS) & (r.key # FREE) THEN
    IF (r.key<0) OR (r.key>=NOF_VIRTUAL_REGS) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Register.ReleaseReg 2");
      RETURN;
    END;
    IF virtRegTab[r.key].inReg THEN
      cpuRegTab[virtRegTab[r.key].reg]:=FREE
    ELSE
      memRegTab[virtRegTab[r.key].reg]:=FREE
    END;
    virtRegTab[r.key].reg:=FREE;
    virtRegTab[r.key].inReg:=FALSE;
  END;
  r.key:=FREE;
END ReleaseReg;

(*----------------------------------------------------------------------------*)
PROCEDURE SaveCPURegisters*(VAR regs: RegSetT);
(* function:      pushes the values of all currently active CPU registers to the stack  *)
VAR 
  vreg: INTEGER; 
BEGIN
  FreeCpuReg(EAX);
  regs.virtRegTab:=virtRegTab;
  regs.cpuRegTab:=cpuRegTab;
(*  regs.memRegTab:=memRegTab;*)
  vreg:=0;
  WHILE vreg < NOF_VIRTUAL_REGS DO
    IF virtRegTab[vreg].inReg THEN
      IF virtRegTab[vreg].reg = FREE THEN (* !!!! remove *)
        OPM.CommentedErr(E.INTERNAL_MURKS_WARN,"Register.SaveCPURegisters");
        RETURN;
      END;
      genCodePushReg(virtRegTab[vreg].reg);
      cpuRegTab[virtRegTab[vreg].reg]:=FREE;
      virtRegTab[vreg].inReg:=FALSE;
      virtRegTab[vreg].reg:=FREE;
    END;
    INC(vreg)
  END;
  regs.floatStackUsage:=floatStackUsage;
  WHILE floatStackUsage > 0 DO
    MoveFloatRegOut(floatStackUsage);
  END;
END SaveCPURegisters;

(*----------------------------------------------------------------------------*)
PROCEDURE RestoreCPURegisters*(VAR regs: RegSetT);
  (* function:      pops the values of all saved registers from stack       *)
  (* precondition:  x = previously called procedure                           *)
  (* postcondition: x = function result                                     *)
  (* The floating point register stack is restored in OPL.GetFunctionReturnValue.
     Although this somewhat violates the modularisation this makes it possible
     to avoid the generation of unnecessary code in some cases. *)
     
VAR 
  vreg: INTEGER; 
BEGIN
  virtRegTab:=regs.virtRegTab;
  cpuRegTab:=regs.cpuRegTab;
(*  memRegTab:=regs.memRegTab;*)
  vreg:=NOF_VIRTUAL_REGS;
  WHILE vreg > 0 DO 
    DEC(vreg);
    IF virtRegTab[vreg].inReg THEN 
      genCodePopReg(virtRegTab[vreg].reg);
    END;
  END;
END RestoreCPURegisters;

(*----------------------------------------------------------------------------*)

PROCEDURE TransferReg*(VAR x: RegisterT; VAR regs: RegSetT; VAR y: RegisterT);
  (* function:      Is called after 'SaveCPURegisters'. Makes the register 'x' *)
  (*                also usable after 'SaveCPURegisters' .                      *)
  (* precondition:  x = correct register for use before 'SaveRegisters'     *)
  (* postcondition: y = substitute for x to be used after 'SaveRegisters'   *)
VAR 
  vreg: INTEGER;
BEGIN
  y:=x;
  IF y.reg IN REGS THEN
    vreg:=y.key;
    virtRegTab[vreg]:=regs.virtRegTab[vreg];
    IF virtRegTab[vreg].inReg THEN
      cpuRegTab[virtRegTab[vreg].reg]:=vreg
    END
  END
END TransferReg;

(*----------------------------------------------------------------------------*)


PROCEDURE Init*(regToMem,memToReg:GenCodeRMT; 
                xchgRegReg:GenCodeRRT;
                regToReg:GenCodeRRT;
                pushReg,popReg:GenCodeRT;
                storeFloat,getFloat:GenCodeFloatT);
BEGIN
  genCodeRegToMem:=regToMem;
  genCodeMemToReg:=memToReg;
  genCodeXchgRegReg:=xchgRegReg;
  genCodeRegToReg:=regToReg;
  genCodePushReg:=pushReg;
  genCodePopReg:=popReg;
  genCodeStoreFloat:=storeFloat;
  genCodeGetFloat:=getFloat;
  InitRegTabs;
  genRegPos:=EAX; 
  bytRegPos:=EAX; 
  segRegPos:=ES; 
  curAge:=0;
END Init;

END Register.
