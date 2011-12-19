(*===========================================================================

  DESCRIPTION:
  This module is the run time system for the 32-bit Oberon-2 compiler.
  
  AUTHORS:     
  Peter René Dietmüller (PDI)
  Bernhard Leisch (LEI)
  
  COPYRIGHT:   
  FIM (Forschungsinstitut für Mikroprozessortechnik),  University of Linz
  
 ============================================================================
  DATE      AUTHOR  CHANGES
  --------  ------  -------------------------------------------------------
  97/04/27  PDI     New, SysNew, Dispose implemented 
  97/07/15  PDI     Halt displays error in a message box instead of the console
  98/08/??  PDI     Garbage Collector
  98/09     PDI     Error in DisposeSubBlock removed.
 ===========================================================================*)

MODULE RTSOberon;


  IMPORT Str := RtsStr, SYSTEM, W := RtsWin;
  
  
  CONST
    
    (* -- start settings -- *)
    LOG_ACTIVE = FALSE;

    (* -- garbage collector -- *)
    GC_ACTIVE  = FALSE;
    GC_MEM     = 64 * 1024;(*65536;*)

    (* -- debug level -- *)
    LOG_STATISTIC   = 1;  (* show RTS information before and after gc *)
    LOG_PROCENTRY   = 2;  (* show entry of all GC functions  *)
    LOG_PROCEXIT    = 3;  (* show exit of all GC functions  *)
    LOG_SYSTEMTABLE = 4;  (* shows heap, module table, .. *)
    LOG_HEAP        = 29; (* checks validity of the heap for each allocate and deallocate *)
    LOG_SPECIAL     = 30;
    LOG_DEBUG       = 31;
    DBGLVL          = {LOG_STATISTIC, LOG_SYSTEMTABLE, LOG_PROCENTRY, LOG_SPECIAL, LOG_DEBUG};

    (* -- restrictions -- *)
    MAXPATH       = 256;
    MAXBASE       = 10;  (* maximum base classes possible; compiler restriction *)
    MAX_ID_LEN*   = 45;  (* length of identifiers; compiler restriction         *)

    (* -- memory management -- *)
    SUBBLOCKSIZE  = 24;  (* overhead for memory allocation *)
    
    (* -- HALT by RTS -- *)
    HALT_RTS_TOO_MANY_MODULES = MAX(INTEGER);
    HALT_RTS_OUT_OF_MEM       = MAX(INTEGER) - 1;
    HALT_RTS_HEAP_CORRUPT     = MAX(INTEGER) - 2;
    HALT_RTS_LAST_ERROR       = HALT_RTS_HEAP_CORRUPT;
    
    (* -- Run-Time-Type Information Codes -- *)
    TYP_UNDEF     = 0;
    TYP_BYTE      = 1;
    TYP_BOOL      = 2;
    TYP_CHAR      = 3;
    TYP_SHORTINT  = 4;
    TYP_INT       = 5;
    TYP_LONGINT   = 6;
    TYP_REAL      = 7;
    TYP_LONGREAL  = 8;
    TYP_SET       = 9;
    TYP_NOTYP     = 0CH;
    TYP_POINTER   = 0DH;
    TYP_PROCTYP   = 0EH;
    TYP_HDPOINTER = 0F0H;  (* hidden pointer *)
    TYP_ARRAY     = 100H;
    TYP_DYNARRAY  = 200H;
    TYP_RECORD    = 400H;
    TYP_ENDRECORD = 800H;

    (* -- log file -- *)
    LOGBUFFERSIZE = 2048;
    LOGFILE       = "C:\RTS32.TXT";
    
    (* -- Maximalwerte -- *)
    MAXCODEMODULE = 100;
    MAXMODULES    = 500;
    MAXMEMBLOCKS  = 1000;
    MEMBLOCKSIZE  = 64 * 1024;

    (* -- Offsets for SubBlock -- *)
    SB_OFS_PREV    = 0;
    SB_OFS_NEXT    = 4;
    SB_OFS_SIZE    = 8;
    SB_OFS_UNUSED  = 12;
    SB_OFS_LOCKED  = 13;
    SB_OFS_USED    = 14;
    SB_OFS_SCANNED = 15;
    SB_OFS_ID      = 16;
    SB_OFS_TYPETAG = 20;
    

  TYPE
    
    Name*  = ARRAY MAX_ID_LEN OF CHAR;
    NameP  = POINTER TO Name;

    TypeNameT = ARRAY 32 OF CHAR;
    TypeNameP = POINTER TO TypeNameT;

    (************************************************************************
     *
     * The following precedes every memory block allocated by NEW. 
     * The compiler expects the type descriptor exactly four bytes before the
     * memory block. So the typedescriptor should always be the last element
     * in this structure!
     *
     ************************************************************************)
    SubBlockHeaderT- = RECORD
      prev:       LONGINT; (* previous sub block         *)
      next:       LONGINT; (* next free sub block        *)
      size:       LONGINT; (* size of sub block          *)
      unused:     CHAR;
      locked*:    BOOLEAN; (* is the block locked for GC *)
      used-:      BOOLEAN; (* is the block used          *)
      scanned-:   BOOLEAN; (* is the block scanned by the gc *)
      uniqueID-:  LONGINT; (* every memory block has a unique id for serialization *)
      typeDesc-:  LONGINT; (* type descriptor *)
    END;
    SubBlockHeaderP- = POINTER TO SubBlockHeaderT;
    

    (************************************************************************
     *
     * Structure for handling memory blocks
     *
     ************************************************************************)
    MemoryBlockT = RECORD
      size:   LONGINT;       (* size of the memory block            *)
      handle: W.HANDLE;      (* handle of the memory block          *)
      adr:    LONGINT;       (* address of the memory block         *)
      last:   LONGINT;       (* address of the last sub block       *)
      first:  LONGINT;       (* address of the first free sub block *)
    END;

    (************************************************************************
     *
     * The module descriptor is a compiler generated structure. It describes
     * a module (name, commands, type descriptors). A module descriptor
     * pointer does not point to the beginning of the structure!! It points
     * to module name pointer as it is shown in the following table.
     *
     * memory layout of a module:
     *
     *        module name (40*8)
     *        
     *        0(32), 0(32),                         -+
     *        nofCommands (32)                       +- open array
     *        list of commands,                     -+
     *        
     *        0(32), 0(32),                         -+
     *        number of type descriptors (32),       +- open array
     *        list of type descriptors,             -+
     *        
     *        RTTI for global variables,
     *        reserved (32) for GC,
     * mdp -> ptr to module name,
     *        size of module global data section
     *        ptr to global module data
     *        ptr to open array of type descriptors
     *        ptr to open array of commands 
     *
     ***********************************************************************)
    ModuleDescriptorT = RECORD
      moduleName-:      NameP;
      globalDataSize-:  LONGINT;
      globalData-:      SYSTEM.PTR; 
      typetagList-:     POINTER TO ARRAY OF SYSTEM.PTR;
      commandList-:     POINTER TO ARRAY OF SYSTEM.PTR;
    END;
    ModuleDescriptorP = POINTER TO ModuleDescriptorT;
    
    ModuleDescriptorPraefixT = RECORD
      nc-:       INTEGER;
      reserved-: LONGINT;
    END;
    ModuleDescriptorPraefixP = POINTER TO ModuleDescriptorPraefixT;

    CommandT- = RECORD
      proc-: PROCEDURE;
      name-: NameP;
    END;
    CommandP- = POINTER TO CommandT;
(*
    CodeModuleT- = RECORD 
      path-:         ARRAY MAXPATH OF CHAR;
      id-:           LONGINT;
      module-:       ARRAY MAXMODULES OF ModuleDescriptorP;
      moduleN-:      LONGINT;
      moduleHandle-: W.HMODULE;
    END;
    CodeModuleP- = POINTER TO CodeModuleT;*)
    
    TypeDescriptorT- = RECORD
      base-: ARRAY MAXBASE OF LONGINT;
    END;
    TypeDescriptorP- = POINTER TO TypeDescriptorT;
    
    TypeDescriptorPraefixT- = RECORD
      nc-:       INTEGER;  (* number of bytes for runtime type information *)
      xxx-:      LONGINT;  (* reserved for garbage collector *)
      typeName-: TypeNameP;
      size-:     LONGINT;  (* size of record *)
    END;
    TypeDescriptorPraefixP- = POINTER TO TypeDescriptorPraefixT;
    
    ObjectT* = RECORD
    END;
    Object* = POINTER TO ObjectT;

    GC_STATISTIC = RECORD
      timerTick:     LONGINT;
      heapElems:     LONGINT;
      heapBlocks:    LONGINT;
      heapAllocated: LONGINT;
    END;

    GC_COUNT = RECORD
      candidates:   LONGINT; (* number of candidates    *)
      markedBlocks: LONGINT; (* number of marked blocks *)
    END;
  

  VAR
    currentID:   LONGINT;                     (* ID counter for unique ID *)
    gcActive:    BOOLEAN;
    gcCount:     GC_COUNT;
    gcMarked:    BOOLEAN;
    gcMem:       LONGINT;                     (* memory allocated since last garbage collecting *)
    logActive:   BOOLEAN;
    logBuffer:   ARRAY LOGBUFFERSIZE OF CHAR; (* buffer for log file      *)
    logCurLen:   INTEGER;                     (* len of log buffer data   *)
    logHandle:   W.HFILE;                     (* handle for log file      *)
    memBlocks:   ARRAY MAXMEMBLOCKS OF MemoryBlockT;
    memBlockN:   LONGINT;
    moduleList-: ARRAY MAXMODULES OF ModuleDescriptorP;                
    moduleN-:    LONGINT;                     (* number of modules loaded *)


(******************************************************************************
 *
 * UTILITY FUNCTIONS FOR Halt
 *
 ******************************************************************************)
PROCEDURE AppendStr(VAR msg: ARRAY OF CHAR; VAR txt-: ARRAY OF CHAR);
BEGIN
  Str.Append(msg, txt);
END AppendStr;

PROCEDURE AppendInt(VAR msg: ARRAY OF CHAR; x: LONGINT);
  VAR txt: ARRAY 20 OF CHAR;
BEGIN
  Str.Str(x,txt);
  Str.Append(msg, txt);
END AppendInt;

PROCEDURE AppendLn(VAR msg: ARRAY OF CHAR);
  VAR txt: ARRAY 3 OF CHAR;
BEGIN
  txt[0]:=0DX;
  txt[1]:=0AX;
  txt[2]:=0X;
  Str.Append(msg, txt);
END AppendLn;


(******************************************************************************
 *
 * Message box functions (mainly for debugging purposes)
 *
 ******************************************************************************)

PROCEDURE ShowMsg(VAR msg-: ARRAY OF CHAR);
  VAR r: LONGINT;
BEGIN
  r := W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR("debug msg"), W.MB_ICONEXCLAMATION + W.MB_APPLMODAL);
END ShowMsg;

PROCEDURE ShowInt(x: LONGINT);
  VAR t: ARRAY 50 OF CHAR;
BEGIN
  t := "";
  AppendInt(t, x);
  ShowMsg(t);
END ShowInt;

PROCEDURE ShowLastError();
  VAR 
    lastError: LONGINT;
    msg:       ARRAY 20 OF CHAR;
BEGIN
  lastError := W.GetLastError();
  msg := "LastError = ";
  AppendInt(msg, lastError);
  ShowMsg(msg);
END ShowLastError;


(******************************************************************************
 *
 * HALT
 *
 ******************************************************************************)
PROCEDURE Halt*(modDescrP:SYSTEM.PTR; lineHaltCode:LONGINT);

  CONST
    title1 = "Oberon-2 Run Time Error";
    title2 = "HALT";
    title3 = "Error in RTS";
  
  VAR
    haltNum:  INTEGER;
    lineNum:  INTEGER; 
    modDescr: ModuleDescriptorP;
    msg:      ARRAY 200 OF CHAR;
    title:    ARRAY 30 OF CHAR;

BEGIN
  
  SYSTEM.GET(SYSTEM.ADR(lineHaltCode)+2,lineNum);
  SYSTEM.GET(SYSTEM.ADR(lineHaltCode),haltNum);
  modDescr:=SYSTEM.VAL(ModuleDescriptorP, modDescrP);
  
  (* -- build error message -- *)
  msg := "";
  IF haltNum >= HALT_RTS_LAST_ERROR THEN        (* Error in Run-Time-System *)
    title := title3;
    AppendStr(msg, title3); 
    AppendStr(msg, " detected: at line "); 
    AppendInt(msg, lineNum); 
    AppendStr(msg, " of module ");
  ELSE
    IF haltNum < 0 THEN                       (* Oberon-2 Run-Time-Error  *)
      title := title1;
      AppendStr(msg, title1);
    ELSE                                      (* HALT                     *)
      title := title2;
      AppendStr(msg, title2);
    END;
    AppendStr(msg, " at line ");
    AppendInt(msg, lineNum);
    AppendStr(msg, " of module ");
  END;
  AppendStr(msg, modDescr.moduleName^); AppendLn(msg);
  IF    haltNum =  -1 THEN AppendStr(msg, "value out of range")
  ELSIF haltNum =  -2 THEN AppendStr(msg, "index out of range")
  ELSIF haltNum =  -3 THEN AppendStr(msg, "arithmetic overflow")
  ELSIF haltNum =  -4 THEN AppendStr(msg, "wrong dynamic type")
  ELSIF haltNum =  -5 THEN AppendStr(msg, "wrong module version")
  ELSIF haltNum =  -6 THEN AppendStr(msg, "wrong definition file (INIT in EXPORTS)")
  ELSIF haltNum =  -7 THEN AppendStr(msg, "WITH trap (no ELSE included)")
  ELSIF haltNum =  -8 THEN AppendStr(msg, "CASE trap (no ELSE included)")
  ELSIF haltNum =  -9 THEN AppendStr(msg, "no result returned")
  ELSIF haltNum = -10 THEN AppendStr(msg, "ASSERT fault")
  ELSIF haltNum = -11 THEN AppendStr(msg, "referenced pointer is nil (assignments can also cause pointer dereferencing because of type checks)");
  ELSIF haltNum = HALT_RTS_TOO_MANY_MODULES THEN AppendStr(msg, "too many modules");
  ELSIF haltNum = HALT_RTS_OUT_OF_MEM       THEN AppendStr(msg, "out of memory");
  ELSIF haltNum = HALT_RTS_HEAP_CORRUPT     THEN AppendStr(msg, "heap corrupt");
  ELSE
    AppendStr(msg, "HALT("); AppendInt(msg, haltNum); AppendStr(msg, ")")
  END;
  AppendLn(msg);

  (* -- display halt message box -- *)
  IF haltNum = 0 THEN
    IF W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR(title), W.MB_RETRYCANCEL + W.MB_ICONEXCLAMATION + W.MB_APPLMODAL) # W.IDRETRY THEN 
      W.ExitProcess(0);
    END
  ELSE
    IF W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR(title), W.MB_OK + W.MB_ICONEXCLAMATION + W.MB_APPLMODAL) # 0 THEN END;
    W.ExitProcess(0);
  END
  
END Halt;


(******************************************************************************
 *
 * LOG FUNCTIONS
 *
 ******************************************************************************)
PROCEDURE ^LogWriteLn;
PROCEDURE ^LogClose();

PROCEDURE LogClearBuffer();
BEGIN
  logCurLen := 0;
  logBuffer := "";  
END LogClearBuffer;

PROCEDURE LogWriteBuffer();
  VAR written: W.UINT;
BEGIN
  written := W._lwrite(logHandle, SYSTEM.ADR(logBuffer), logCurLen);
  LogClearBuffer();
END LogWriteBuffer;

PROCEDURE LogOpen();
BEGIN
  LogClearBuffer();
  logHandle := W._lopen(SYSTEM.ADR(LOGFILE), W.OF_WRITE);
  IF logHandle > 0 THEN
    IF W._llseek(logHandle, 0, 2) < 0 THEN (* go to the end *)
      LogClose();
      RETURN
    END;
  ELSE
    logHandle := W._lcreat(SYSTEM.ADR(LOGFILE), 0);
  END;
END LogOpen;

PROCEDURE LogWrite(ch: CHAR);
BEGIN
  IF ch="$" THEN
    LogWriteLn;
  ELSE
    IF logCurLen >= LEN(logBuffer) THEN
      LogWriteBuffer();
    END;
    logBuffer[logCurLen] := ch;
    INC(logCurLen)
  END;
END LogWrite;

PROCEDURE LogWriteLn;
BEGIN
  LogWrite(0DX); LogWrite(0AX);
END LogWriteLn;
  
PROCEDURE LogWriteStr(s: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO 
    LogWrite(s[i]); 
    INC(i);
  END;
END LogWriteStr;

PROCEDURE LogWriteStrX(s: ARRAY OF CHAR; width: INTEGER);
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO 
    LogWrite(s[i]); 
    INC(i);
  END;
  WHILE i < width DO
    LogWrite(" ");
    INC(i);
  END;
END LogWriteStrX;

PROCEDURE LogWriteInt(x, n: LONGINT);
  VAR i: INTEGER; neg: BOOLEAN; a: ARRAY 11 OF CHAR;
BEGIN
  neg := (x < 0);
  IF neg THEN x := -x END;
  i := 0;
  REPEAT
    a[i] := CHR(ORD("0") + (x MOD 10));
    x := x DIV 10;
    INC(i);
  UNTIL x = 0;
  IF neg THEN
    a[i] := "-";
    INC(i);
  END;
  WHILE (i < n) DO
    a[i] := " ";
    INC(i);
  END; 
  REPEAT
    DEC(i);
    LogWrite(a[i]);
  UNTIL i = 0;
END LogWriteInt;

PROCEDURE LogWriteHex(x: LONGINT);
  VAR i: INTEGER; y: LONGINT; a: ARRAY 12 OF CHAR;
BEGIN
  LogWrite(" ");
  i := 0;
  REPEAT
    y := x MOD 16;
    IF y < 10 THEN 
      a[i] := CHR(y + ORD("0"))
    ELSE 
      a[i] := CHR((y - 10) + ORD("A"))
    END;
    x := x DIV 16;
    INC(i);
  UNTIL i = 8;
  REPEAT
    DEC(i);
    LogWrite(a[i]);
  UNTIL i = 0;
END LogWriteHex;

PROCEDURE LogClose();
 VAR r: W.UINT;
BEGIN
  IF logHandle > 0 THEN
    IF logCurLen > 0 THEN
      LogWriteBuffer();
    END;
    r := W._lclose(logHandle);
  END;
END LogClose;


(***************************************************************************
 * 
 * Type Functions
 * 
 ***************************************************************************)

PROCEDURE GetTypeSize*(typetag: LONGINT; VAR size: LONGINT);
BEGIN
  SYSTEM.GET(typetag - 4, size);
END GetTypeSize;

PROCEDURE GetTypeName*(typetag: LONGINT; VAR name: ARRAY OF CHAR);
  VAR np: TypeNameP;
BEGIN
  SYSTEM.GET(typetag - 8, np);
  COPY(np^, name);
END GetTypeName;


(***************************************************************************
 * 
 * Object Functions 
 * 
 ***************************************************************************)

PROCEDURE SetObjUID(object: LONGINT; uid: LONGINT);
BEGIN
  SYSTEM.PUT(object - 8, uid);
END SetObjUID;

PROCEDURE GetObjUID*(object: LONGINT; VAR uid: LONGINT);
BEGIN
  SYSTEM.GET(object - 8, uid);
END GetObjUID;

PROCEDURE SetObjType(object: LONGINT; typetag: LONGINT);
BEGIN
  SYSTEM.PUT(object - 4, typetag);
END SetObjType;

PROCEDURE GetObjType*(object: LONGINT; VAR typetag: LONGINT);
BEGIN
  SYSTEM.GET(object - 4, typetag);
END GetObjType;

PROCEDURE GetObjSize*(object: LONGINT; VAR size: LONGINT);
  VAR typetag: LONGINT;
BEGIN
  GetObjType(object, typetag);
  GetTypeSize(typetag, size);
END GetObjSize;

PROCEDURE GetObjName*(object: LONGINT; VAR name: ARRAY OF CHAR);
  VAR typetag: LONGINT;
BEGIN
  GetObjType(object, typetag);
  GetTypeName(typetag, name);
END GetObjName;


(***************************************************************************
 * 
 * Module Functions
 * 
 ***************************************************************************)

PROCEDURE GetModuleName*(mdp: ModuleDescriptorP; VAR name: ARRAY OF CHAR);
VAR
BEGIN
  COPY(mdp^.moduleName^, name);
END GetModuleName;


(***************************************************************************
 * 
 * Helper Functions for Memory Management and Garbage Collector
 * 
 ***************************************************************************)

PROCEDURE GetSubBlockSize(adr: LONGINT; VAR value: LONGINT);
BEGIN
  SYSTEM.GET(adr + SB_OFS_SIZE, value);
END GetSubBlockSize;

PROCEDURE SetSubBlockSize(adr: LONGINT; value: LONGINT);
BEGIN
  SYSTEM.PUT(adr + SB_OFS_SIZE, value);
END SetSubBlockSize;

PROCEDURE IsSubBlockFree(adr: LONGINT): BOOLEAN;
VAR sbSize: LONGINT;
BEGIN
  GetSubBlockSize(adr, sbSize);
  RETURN sbSize < 0;
END IsSubBlockFree;

PROCEDURE GetSubBlockNext(adr: LONGINT; VAR value: LONGINT);
BEGIN
  SYSTEM.GET(adr + SB_OFS_NEXT, value);
END GetSubBlockNext;

PROCEDURE SetSubBlockNext(adr: LONGINT; value: LONGINT);
BEGIN
  SYSTEM.PUT(adr + SB_OFS_NEXT, value);
END SetSubBlockNext;

PROCEDURE GetSubBlockPrev(adr: LONGINT; VAR value: LONGINT);
BEGIN
  SYSTEM.GET(adr + SB_OFS_PREV, value);
END GetSubBlockPrev;

PROCEDURE SetSubBlockPrev(adr: LONGINT; value: LONGINT);
BEGIN
  SYSTEM.PUT(adr + SB_OFS_PREV, value);
END SetSubBlockPrev;

PROCEDURE SetSubBlockLocked(adr: LONGINT; locked: BOOLEAN);
BEGIN
  IF locked THEN
    SYSTEM.PUT(adr + SB_OFS_LOCKED, 1);
  ELSE
    SYSTEM.PUT(adr + SB_OFS_LOCKED, 0);
  END;    
END SetSubBlockLocked;

PROCEDURE IsSubBlockLocked(adr: LONGINT): BOOLEAN;
VAR locked: SHORTINT;
BEGIN
  SYSTEM.GET(adr + SB_OFS_LOCKED, locked);
  RETURN locked = 1;
END IsSubBlockLocked;

PROCEDURE SetSubBlockUsed(adr: LONGINT; used: BOOLEAN);
BEGIN
  IF used THEN
    SYSTEM.PUT(adr + SB_OFS_USED, 1);
  ELSE
    SYSTEM.PUT(adr + SB_OFS_USED, 0);
  END;    
END SetSubBlockUsed;

PROCEDURE IsSubBlockUsed(adr: LONGINT): BOOLEAN;
VAR used: SHORTINT;
BEGIN
  SYSTEM.GET(adr + SB_OFS_USED, used);
  RETURN used = 1;
END IsSubBlockUsed;

PROCEDURE SetSubBlockScanned(adr: LONGINT; scanned: BOOLEAN);
BEGIN
  IF scanned THEN
    SYSTEM.PUT(adr + SB_OFS_SCANNED, 1);
  ELSE
    SYSTEM.PUT(adr + SB_OFS_SCANNED, 0);
  END;    
END SetSubBlockScanned;

PROCEDURE IsSubBlockScanned(adr: LONGINT): BOOLEAN;
VAR scanned: SHORTINT;
BEGIN
  SYSTEM.GET(adr + SB_OFS_SCANNED, scanned);
  RETURN scanned = 1;
END IsSubBlockScanned;


(***************************************************************************
 * 
 * Functions for decoding Run-Time-Type Information to the log file
 * 
 ***************************************************************************)

PROCEDURE ^ShowType(ra: LONGINT; ta: LONGINT; VAR count: INTEGER);

PROCEDURE ShowInternalRecord(ra: LONGINT; ta: LONGINT; VAR count: INTEGER);
  VAR code: INTEGER; nc: INTEGER;
BEGIN
  count := 0;
  SYSTEM.GET(ta - 2, code);
  WHILE (code # TYP_ENDRECORD) DO
    ShowType(ra, ta, nc);
    ta := ta - 2 * nc;
    INC(count, nc);
    LogWriteLn;
    SYSTEM.GET(ta - 2, code);
  END;
  INC(count);
END ShowInternalRecord;


PROCEDURE ShowArray(aa: LONGINT; ta: LONGINT; elems: LONGINT; size: LONGINT; VAR count: INTEGER);
  VAR i: LONGINT;
BEGIN
  count := 0;
  FOR i := 0 TO elems - 1 DO
    LogWriteLn;
    ShowType(aa, ta, count);
    INC(aa, size);
  END;
END ShowArray;


PROCEDURE ShowType(ra: LONGINT; ta: LONGINT; VAR count: INTEGER);

  VAR 
    code:  INTEGER;
    elems: LONGINT;
    ofs:   LONGINT;
    p:     LONGINT;  (* pointer         *)
    size:  LONGINT;
    tta:   LONGINT;  (* typetag address *)
    xl:    LONGINT;
    vc:    CHAR;
    vi:    INTEGER;
    vl:    LONGINT;
    vs:    SHORTINT;

BEGIN

  LogWriteHex(ra);
  LogWriteHex(ta);
  SYSTEM.GET(ta - 2, code); 
  
  IF code = TYP_UNDEF THEN
    LogWriteStr("UNDEF    "); 
    count := 1;

  ELSIF (code >= TYP_BYTE) & (code <= TYP_SET) THEN
    SYSTEM.GET(ta - 6, ofs);  LogWriteHex(ofs); LogWriteStr("  ");
    CASE code OF
      TYP_BYTE:     LogWriteStr("BYTE      "); SYSTEM.GET(ra + ofs, vs); LogWriteInt(vs, 1);
     |TYP_BOOL:     LogWriteStr("BOOLEAN   "); SYSTEM.GET(ra + ofs, vs); IF vs = 0 THEN LogWriteStr("FALSE") ELSE LogWriteStr("TRUE") END;
     |TYP_CHAR:     LogWriteStr("CHAR      "); SYSTEM.GET(ra + ofs, vc); LogWrite(vc);
     |TYP_SHORTINT: LogWriteStr("SHORTINT  "); SYSTEM.GET(ra + ofs, vs); LogWriteInt(vs, 1);
     |TYP_INT:      LogWriteStr("INTEGER   "); SYSTEM.GET(ra + ofs, vi); LogWriteInt(vi, 1);
     |TYP_LONGINT:  LogWriteStr("LONGINT   "); SYSTEM.GET(ra + ofs, vl); LogWriteInt(vl, 1);
     |TYP_REAL:     LogWriteStr("REAL      ");
     |TYP_LONGREAL: LogWriteStr("LONGREAL  ");
     |TYP_SET:      LogWriteStr("SET       ");
    END;
    count := 3;
  
  ELSIF code = TYP_NOTYP THEN
    LogWriteStr("NOTYP ");
    count := 3;
    
  ELSIF code = TYP_POINTER THEN
    SYSTEM.GET(ta - 6, ofs);  (* get offset of pointer *)
    LogWriteHex(ofs); 
    LogWriteStr("  ");
    LogWriteStr("POINTER TO ");
    SYSTEM.GET(ra + ofs, p);  (* get pointer itself    *)
    SYSTEM.GET(ta - 8, code); (* get type of pointer   *)
    IF code = TYP_RECORD THEN (* record has its own type descriptor *)
      LogWriteStr("RECORD");
      LogWriteHex(p);
      count := 4;
      (* -- analyze block referenced by pointer -- *)
      IF p # 0 THEN
        SYSTEM.GET(p - 4, tta); LogWriteHex(tta);
      END;
    ELSIF code = TYP_ARRAY THEN
      (* the type tag of the block referenced by p is 0!*)
      LogWriteStr("ARRAY OF");
      ShowType(p, ta - 6, count);
      INC(count, 3);
    ELSIF code = TYP_DYNARRAY THEN
      (* the type tag of the block referenced by p is 0!
         first 12 bytes of the array are not used by the array.
         first eight bytes are unknown
         next 4 bytes holds the highest possible index for the dynamic array (0..index)!*)
      SYSTEM.GET(ta - 12, ofs);  (* get offset of dynamic array *)
      SYSTEM.GET(ta - 16, size); (* get size of an element *)
      IF p # 0 THEN
        SYSTEM.GET(p + 8, elems);  (* number of elems *)
      ELSE
        elems := 0; (* dynamic array not allocated *)
      END;
      LogWriteStr("DYNARRAY("); 
      LogWriteInt(elems + 1, 1); 
      LogWriteStr(") OF "); 
      ShowArray(p + 12, ta - 16, elems, size, count);
      INC(count, 8);
    END;
    
  ELSIF code = TYP_PROCTYP THEN  
    SYSTEM.GET(ta - 6, ofs);  
    LogWriteHex(ofs); 
    LogWriteStr("  ");
    LogWriteStr("PROCEDURE ");
    count := 3;
    
  ELSIF code = TYP_ARRAY THEN
    SYSTEM.GET(ta - 6, ofs);  LogWriteHex(ofs); LogWriteStr("  ");
    SYSTEM.GET(ta - 10, size);  (* size of element    *)
    SYSTEM.GET(ta - 14, elems); (* number of elements *)
    LogWriteStr("ARRAY("); LogWriteInt(elems, 1); LogWriteStr(") OF "); LogWriteLn;
    ShowArray(ra + ofs, ta - 14, elems, size, count);
    INC(count, 7); 

  ELSIF code = TYP_RECORD THEN
    SYSTEM.GET(ta - 6, ofs);  LogWriteHex(ofs); LogWriteStr("  ");
    LogWriteStr("RECORD "); LogWriteLn;
    ShowInternalRecord(ra, ta - 6, count);
    INC(count, 3);

  ELSIF code = TYP_ENDRECORD THEN
    LogWriteStr("END ");
    count := 1;
    
  ELSE (* error !! *)
    HALT(0);
    
  END;
  
END ShowType;


PROCEDURE ShowRecord(ra: LONGINT; tdp: TypeDescriptorP);

VAR
  count: INTEGER;
  nc:    INTEGER;
  ta:    LONGINT;   (* type address = adress of RTTI *)
  tn:    TypeNameP; (* type name                     *)
    
BEGIN
  ta := SYSTEM.VAL(LONGINT, tdp) - 14;
  SYSTEM.GET(ta, nc);
  SYSTEM.GET(ta + 6, tn);
  LogWriteStr(tn^); LogWriteInt(nc, 10); LogWriteLn;
  WHILE (nc > 0) DO
    ShowType(ra, ta, count);
    LogWriteLn;
    ta := ta - 2 * count;
    DEC(nc, count);
  END;
END ShowRecord;


PROCEDURE ShowGlobalData(ra: LONGINT; mdp: ModuleDescriptorP);

  VAR
    ch:    CHAR;
    count: INTEGER;
    i:     INTEGER;
    nc:    INTEGER;
    ta:    LONGINT;
    dword: LONGINT;
    
BEGIN
  
  LogWriteLn;
  LogWriteStr("Global data of ");
  LogWriteStr(mdp^.moduleName^);
  LogWriteStr(" (");
  LogWriteInt(mdp^.globalDataSize, 1);
  LogWriteStr(" bytes)");
  LogWriteLn;
  i := 0;
  WHILE (i < mdp^.globalDataSize) DO
    SYSTEM.GET(ra (*SYSTEM.VAL(LONGINT, mdp^.globalData)*) + i, dword);
    LogWriteHex(dword);
    INC(i);
    IF (i MOD 8) = 0 THEN LogWriteLn END;
  END;
  LogWriteLn;

  (* -- hex dump of rtti -- *)
  ta := SYSTEM.VAL(LONGINT, mdp) - 6;
  SYSTEM.GET(ta, nc);
  LogWriteLn;
  LogWriteStr("RTTI of module ");
  LogWriteStr(mdp^.moduleName^);
  LogWriteStr(" (");
  LogWriteInt(nc, 1);
  LogWriteStr(" words)");
  LogWriteLn;
  i := 0;
  WHILE (nc > 0) DO
    DEC(ta, 4);
    SYSTEM.GET(ta, dword);
    LogWriteHex(dword);
    DEC(nc, 2);
    INC(i);
    IF i = 8 THEN
      i := 0;
      LogWriteLn;
    END;
  END;
  LogWriteLn;

  (* -- show rtti -- *)
  ta := SYSTEM.VAL(LONGINT, mdp) - 6;
  SYSTEM.GET(ta, nc);
  WHILE (nc > 0) DO
    ShowType(ra, ta, count);
    LogWriteLn;
    ta := ta - 2 * count;
    DEC(nc, count);
  END;

END ShowGlobalData;



(***************************************************************************
 * 
 * ShowModules
 *
 ***************************************************************************
 *
 * This function shows the content of the module table moduleList. 
 * 
 ***************************************************************************)

PROCEDURE ShowModules*();

  VAR
    cmd:   CommandP;
    i:     INTEGER;
    j:     LONGINT;
    k:     LONGINT;
    mdp:   ModuleDescriptorP;
    name:  POINTER TO ARRAY MAX_ID_LEN OF CHAR;
    tt:    LONGINT;
    vi:    INTEGER;
    vl:    LONGINT;

BEGIN

  LogOpen();

  LogWriteStr("aktive Module:"); LogWriteLn;
  LogWriteStr("--------------"); LogWriteLn; 
  LogWriteLn;
  LogWriteStr("   # @M.-Desc Modulname     Data     Size  "); LogWriteLn;
  LogWriteStr("---- -------- ------------- -------- ----- "); LogWriteLn;

  FOR i := 0 TO moduleN - 1 DO
    mdp := moduleList[i];
    LogWriteInt(i + 1, 3);
    LogWriteStr(".");
    LogWriteHex(SYSTEM.VAL(LONGINT, mdp));
    LogWriteStr(" ");
    LogWriteStrX(mdp.moduleName^, 12);
    LogWriteStr(" ");
    LogWriteHex(SYSTEM.VAL(LONGINT, mdp^.globalData));
    LogWriteInt(mdp^.globalDataSize, 6);
    SYSTEM.GET(SYSTEM.VAL(LONGINT, mdp) - 8, vi);
    LogWriteInt(vi, 5);
    LogWriteLn;
  END;
  
  FOR i := 0 TO moduleN - 1 DO
    (* -- show typetag list -- *)
    LogWriteLn;
    LogWriteStr("Types of module "); 
    LogWriteStr(moduleList[i]^.moduleName^); LogWriteLn;
    LogWriteLn;
    LogWriteStr("@Typetag  Name                               size       superclasses        "); LogWriteLn;
    LogWriteStr("--------- ---------------------------------- ---------- --------------------"); LogWriteLn;
    FOR j := 0 TO LEN(moduleList[i]^.typetagList^) - 1 DO
      tt := SYSTEM.VAL(LONGINT, moduleList[i]^.typetagList^[j]);
      LogWriteHex(tt);
      LogWrite(" ");
      SYSTEM.GET(tt - 8, name); (* get pointer to type name *)
      LogWriteStrX(name^, 35);
      SYSTEM.GET(tt - 4, vl);   (* get size *)
      LogWriteInt(vl, 10);
      k := 1; (* entry at 0 is pointer to itself *)
      LOOP
        IF (k >= MAXBASE) THEN EXIT END;
        SYSTEM.GET(tt + (k * 4), vl);  (* get base class *)
        IF vl = 0 THEN EXIT END;
        LogWriteHex(vl); 
        INC(k) 
      END;
      LogWriteLn;
    END;
    (* -- show command list -- *)
    IF (moduleList[i].commandList # NIL) & (LEN(moduleList[i].commandList^) > 0) THEN
      LogWriteLn;
      LogWriteStr("Commands of module "); 
      LogWriteStr(moduleList[i]^.moduleName^); LogWriteLn;
      LogWriteLn;
      LogWriteStr("Name                                adr       "); LogWriteLn;
      LogWriteStr("----------------------------------- ----------"); LogWriteLn;
      FOR j := 0 TO LEN(moduleList[i].commandList^) - 1 DO
        cmd := SYSTEM.VAL(CommandP, moduleList[i].commandList[j]);
        LogWriteHex(SYSTEM.VAL(LONGINT, cmd));
(*      LogWriteStrX(cmd^.name, 35);
        LogWriteHex(SYSTEM.VAL(LONGINT, cmd^.proc));*)
        LogWriteLn;
      END;
    END;

    ShowGlobalData(SYSTEM.VAL(LONGINT, moduleList[i].globalData), moduleList[i]);

  END;

  LogClose();

END ShowModules;


(******************************************************************************
 *
 * ShowStack
 *
 ******************************************************************************)
PROCEDURE ShowStack*();
BEGIN
END ShowStack;


(******************************************************************************
 *
 * ShowHeap
 *
 ******************************************************************************)

PROCEDURE ShowHeap*();

  VAR
    block:    LONGINT;
    name:     ARRAY 32 OF CHAR;
    obj:      LONGINT;
    size:     LONGINT;
    subBlock: LONGINT;
    typetag:  LONGINT;
    value:    LONGINT;

BEGIN

  LogOpen();

  LogWriteLn;
  LogWriteLn;
  LogWriteStr("current heap:"); LogWriteLn;
  LogWriteStr("-------------"); LogWriteLn;
  LogWriteLn;

  (* -- scan all heap blocks -- *)
  LogWriteStr("   #  adr      size     first/nxt last/prev UID       Flags LUS "); LogWriteLn;
  LogWriteStr("----  -------- -------- --------- --------- --------- ----------"); LogWriteLn;
  block := 0;
  WHILE (block <= memBlockN) DO
    LogWriteInt(block, 3);
    LogWriteStr(". ");
    LogWriteHex(memBlocks[block].adr); 
    LogWriteStr(" ");
    LogWriteInt(memBlocks[block].size, 8);
    LogWriteHex(memBlocks[block].first);
    LogWriteStr(" ");
    LogWriteHex(memBlocks[block].last);
    LogWriteStr(" ");
    LogWriteLn;
    subBlock := memBlocks[block].adr;
    WHILE (subBlock < memBlocks[block].adr + memBlocks[block].size) DO
      LogWriteStr("     ");
      LogWriteHex(subBlock); 
      LogWriteStr(" ");
      GetSubBlockSize(subBlock, size);
      LogWriteInt(size, 8);
      GetSubBlockNext(subBlock, value);
      LogWriteHex(value);
      LogWriteStr(" ");
      GetSubBlockPrev(subBlock, value);
      LogWriteHex(value);
      LogWriteStr(" ");
      IF size > 0 THEN
        obj := subBlock + SUBBLOCKSIZE;
        (* -- show type info -- *)
        GetObjUID(obj, value);
        LogWriteHex(value);
        LogWriteStr("  ");
        IF IsSubBlockLocked(subBlock)  THEN LogWriteStr("J ") ELSE LogWriteStr("N ") END;
        IF IsSubBlockUsed(subBlock)    THEN LogWriteStr("J ") ELSE LogWriteStr("N ") END;
        IF IsSubBlockScanned(subBlock) THEN LogWriteStr("J ") ELSE LogWriteStr("N ") END;
        GetObjType(obj, typetag);
        IF typetag # 0 THEN
          GetObjName(obj, name);
          LogWriteStr(name);
        ELSE
          LogWriteStr("Open Array");
        END
      ELSE
        LogWriteStr(" FREE");
      END;
      IF size = 0 THEN
        LogClose();
        HALT(HALT_RTS_HEAP_CORRUPT);
      END;
      INC(subBlock, ABS(size));
      LogWriteLn;
    END;
    LogWriteLn;
    INC(block);
  END;
  
  LogClose();

END ShowHeap;


(******************************************************************************
 *
 * Garbage Collector
 *
 ******************************************************************************)

(* returns true if the type descriptor pointer is valid *)
PROCEDURE IsValidTypeDescriptorP(tt: LONGINT): BOOLEAN;
BEGIN
  (* for ARRAY OF ..... typedescriptor is 0 and                    *)
  (* for ARRAY N OF ... the loword of the typedescriptor is 0FFFEH *)
  RETURN (tt # 0) & (W.IsBadReadPtr(tt, 4) = 0) & (W.IsBadWritePtr(tt, 4) # 0);
END IsValidTypeDescriptorP;


PROCEDURE ^GetBlock(adr: LONGINT; VAR block: LONGINT);

(* return true if the address is a valid memory block in the heap *)
PROCEDURE IsValidHeapObject(adr: LONGINT): BOOLEAN;

VAR
  block: LONGINT;
  sb:    LONGINT;
  size:  LONGINT;

BEGIN
  IF adr # 0 THEN  (* nil check *)
    GetBlock(adr, block);
    IF (block >= 0) & (block <= memBlockN) THEN
      (* -- search heap subblock -- *)
      sb := memBlocks[block].last;
      WHILE (sb # 0) & (sb + SUBBLOCKSIZE # adr) DO 
        SYSTEM.GET(sb + SB_OFS_PREV, sb) (* sb := sb^.prev *)
      END;
      IF (sb # 0) THEN 
        SYSTEM.GET(sb + SB_OFS_SIZE, size); (* size := sb^.size *)
        RETURN (size > 0)         (* is not free ?    *)
      END;
    END;
  END;
  RETURN FALSE
END IsValidHeapObject;


(******************************************************************************
 *
 * marks a subblock as used
 *
 ******************************************************************************)
PROCEDURE MarkBlock(adr: LONGINT): BOOLEAN;

VAR
  used: BOOLEAN;

BEGIN

  IF logActive & (LOG_PROCENTRY IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("Marking block "); 
    LogWriteHex(adr); 
    LogWriteLn;
    LogClose;
  END;

  INC(gcCount.candidates);
  
  (* -- mark block -- *)
  IF IsValidHeapObject(adr) THEN
    SYSTEM.GET(adr - 10, used);   (* used := adr^.used *)
    IF ~used THEN
      SYSTEM.PUT(adr - 10, TRUE); (* adr^.used := TRUE *)
      gcMarked := TRUE;
      INC(gcCount.markedBlocks);
      IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
        LogOpen();
        LogWriteStr("Block at");
        LogWriteHex(adr);
        LogWriteStr(" has been marked as used block!");
        LogWriteLn;
        LogClose;
      END;
      RETURN TRUE
    END;
  END;
  RETURN FALSE

END MarkBlock;


(******************************************************************************
 *
 * ScanMemory scans a memory area seeking pointers to records created by 
 * an Oberon-2 program. If it finds some pointers the records pointed to
 * by these pointers are marked as used records.
 *
 ******************************************************************************)
PROCEDURE ScanMemory(start, end: LONGINT);

VAR
  i:   LONGINT;
  ptr: LONGINT;

BEGIN

  IF logActive & ((LOG_PROCENTRY IN DBGLVL) OR (LOG_DEBUG IN DBGLVL)) THEN
    LogOpen();
    LogWriteStr("Scanning memory from ");
    LogWriteHex(start); 
    LogWriteStr(" to "); 
    LogWriteHex(end); 
    LogWriteLn;
    LogClose();
  END;

  FOR i := start TO end - SIZE(LONGINT) + 1 DO
    SYSTEM.GET(i, ptr);
    IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
      LogOpen();
      LogWriteHex(i);
      LogWriteHex(ptr);
      LogWriteLn;
      LogClose;
    END;
    IF MarkBlock(ptr) THEN
      IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
        LogOpen();
        LogWriteStr("pointer to heap block found at ");
        LogWriteHex(i);
        LogWriteHex(ptr);
        LogWriteLn;
        LogClose;
      END;
    END;
  END;

  IF logActive & (LOG_PROCEXIT IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("Scanning memory from ");
    LogWriteHex(start); 
    LogWriteStr(" to "); 
    LogWriteHex(end); 
    LogWriteStr(" finished.");
    LogWriteLn;
    LogClose();
  END;

END ScanMemory;


PROCEDURE IsNoType(ta: LONGINT; VAR count: INTEGER; VAR result: BOOLEAN);

VAR 
  code:  INTEGER;
  nc:    INTEGER;

BEGIN
  result := FALSE;
  SYSTEM.GET(ta - 2, code); 

  IF logActive & ((LOG_PROCENTRY IN DBGLVL)) THEN
    LogOpen();
    LogWriteStr("IsNoType with RTTI at ");
    LogWriteHex(ta);
    LogWriteStr(" code = ");
    LogWriteHex(code);
    LogWriteLn;
    LogClose;
  END;

  IF code = TYP_NOTYP THEN
    count := 3;
    result := TRUE;
  ELSIF code = TYP_UNDEF THEN
    count := 1;
  ELSIF (code >= TYP_BYTE) & (code <= TYP_SET) THEN
    count := 3;
  ELSIF code = TYP_PROCTYP THEN  
    count := 3;
  ELSIF code = TYP_HDPOINTER THEN  
    count := 3;
  ELSIF code = TYP_POINTER THEN
    SYSTEM.GET(ta - 8, code); (* get type of pointer   *)
    IF code = TYP_RECORD THEN (* record has its own type descriptor *)
      count := 4;
    ELSIF code = TYP_ARRAY THEN
      IsNoType(ta - 20, count, result);
      INC(count, 10);
    ELSIF code = TYP_DYNARRAY THEN
      IsNoType(ta - 16, count, result);
      INC(count, 8);
    ELSIF code = TYP_UNDEF THEN (* SYSTEM.PTR *)
      count := 4;
    ELSE
      count := 1;
      HALT(0);
    END;
  ELSIF code = TYP_ARRAY THEN
    IsNoType(ta - 14, count, result);
    INC(count, 7); 
  ELSIF code = TYP_RECORD THEN
    count := 3; 
    DEC(ta, 6);
    SYSTEM.GET(ta - 2, code);
    WHILE (code # TYP_ENDRECORD) & ~result DO
      IsNoType(ta, nc, result);
      INC(count, nc);
      ta := ta - 2 * nc;
      SYSTEM.GET(ta - 2, code);
    END;
    INC(count); (* for ENDRECORD *)
  ELSE (* error !! *)
    ShowInt(code);
    HALT(0);
  END;
END IsNoType;


PROCEDURE TypeHasNoType(ta: LONGINT; nc: INTEGER): BOOLEAN;

VAR
  count: INTEGER;  (* number of bytes used by the rtti of the actual processed type *)
  noType:BOOLEAN;
    
BEGIN
  noType := FALSE;
  IF nc > 0 THEN  (* rtti code table ok *)
    (* -- scan run time type information -- *)
    WHILE (nc > 0) & ~noType DO
      IsNoType(ta, count, noType);
      ta := ta - 2 * count;
      DEC(nc, count);
    END;
  END;
  IF noType & logActive & (LOG_PROCEXIT IN DBGLVL) THEN
    LogOpen(); LogWriteStr("NoType occured!"); LogWriteLn; LogClose();
  END;
  RETURN noType;
END TypeHasNoType;


PROCEDURE SkipType(ta: LONGINT; VAR count: INTEGER);

VAR 
  code:  INTEGER;
  nc:    INTEGER;

BEGIN
  SYSTEM.GET(ta - 2, code); 
  IF code = TYP_UNDEF THEN
    count := 1;
  ELSIF (code >= TYP_BYTE) & (code <= TYP_SET) THEN
    count := 3;
  ELSIF code = TYP_NOTYP THEN
    HALT(0);
  ELSIF code = TYP_PROCTYP THEN  
    count := 3;
  ELSIF code = TYP_HDPOINTER THEN
    count := 3;
  ELSIF code = TYP_POINTER THEN
    SYSTEM.GET(ta - 8, code); (* get type of pointer   *)
    IF code = TYP_RECORD THEN (* record has its own type descriptor *)
      count := 4;
    ELSIF code = TYP_ARRAY THEN
      SkipType(ta - 20, count);
      INC(count, 10);
    ELSIF code = TYP_DYNARRAY THEN
      SkipType(ta - 16, count);
      INC(count, 8);
    ELSIF code = TYP_UNDEF THEN (* SYSTEM.PTR *)
      count := 4;
    ELSE
      count := 1;
      HALT(0);
    END;
  ELSIF code = TYP_ARRAY THEN
    SkipType(ta - 14, count);
    INC(count, 7); 
  ELSIF code = TYP_RECORD THEN
    count := 3; 
    DEC(ta, 6);
    SYSTEM.GET(ta - 2, code);
    WHILE (code # TYP_ENDRECORD) DO
      SkipType(ta, nc);
      INC(count, nc);
      ta := ta - 2 * nc;
      SYSTEM.GET(ta - 2, code);
    END;
    INC(count); (* for ENDRECORD *)
  ELSE (* error !! *)
    ShowInt(code);
    HALT(0);
  END;
END SkipType;

(* count is valid only if result is false! *)
PROCEDURE HasPointer(ta: LONGINT; VAR count: INTEGER; VAR result: BOOLEAN);
VAR 
  code:  INTEGER;
  nc:    INTEGER;
BEGIN

  IF logActive & (LOG_PROCENTRY IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("HasPointer ta = "); LogWriteHex(ta); LogWriteLn;
    LogClose();
  END;

  result := FALSE;
  SYSTEM.GET(ta - 2, code); 
  IF code = TYP_NOTYP THEN
    count := 3;
  ELSIF code = TYP_UNDEF THEN
    count := 1;
  ELSIF (code >= TYP_BYTE) & (code <= TYP_SET) THEN
    count := 3;
  ELSIF code = TYP_PROCTYP THEN  
    count := 3;
  ELSIF code = TYP_HDPOINTER THEN
    count := 0;
    result := TRUE;
  ELSIF code = TYP_POINTER THEN
    count := 0;
    result := TRUE;
  ELSIF code = TYP_ARRAY THEN
    HasPointer(ta - 14, count, result);
    INC(count, 7); 
  ELSIF code = TYP_RECORD THEN
    count := 3; 
    DEC(ta, 6);
    SYSTEM.GET(ta - 2, code);
    WHILE (code # TYP_ENDRECORD) & ~result DO
      HasPointer(ta, nc, result);
      IF ~result THEN  (* pfui! *)
        INC(count, nc);
        ta := ta - 2 * nc;
        SYSTEM.GET(ta - 2, code);
      END;
    END;
    INC(count); (* for ENDRECORD *)
  ELSE (* error !! *)
    ShowInt(code);
    HALT(0);
  END;
END HasPointer;


PROCEDURE ^ScanType(ra: LONGINT; ta: LONGINT; VAR count: INTEGER);

PROCEDURE ScanArray(aa: LONGINT; ta: LONGINT; elems: LONGINT; size: LONGINT; VAR count: INTEGER);

VAR 
  hasPointer: BOOLEAN;
  i:          LONGINT; 

BEGIN

  IF logActive & (LOG_PROCENTRY IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("ScanArray entry: ta = "); LogWriteHex(ta); LogWriteLn;
    LogClose();
  END;

  HasPointer(ta, count, hasPointer);
  IF hasPointer THEN 
    (* -- search all pointers in the array and mark all referenced blocks -- *)
    count := 0;
    FOR i := 0 TO elems - 1 DO
      ScanType(aa, ta, count);
      INC(aa, size);
    END;
  ELSE
    IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
      LogOpen();
      LogWriteStr("No pointers in array"); LogWriteLn;
      LogClose();
    END;
  END;

END ScanArray;


(******************************************************************************
 *
 * ScanType scans the next type of the RTTI at the address ta and marks the
 * subblock as used if the type is a pointer.
 *
 *    ra ... record address
 *    ta ... type address; address of the run-time-type information
 *    count . number of words used by the actual run-time type
 *
 ******************************************************************************)
PROCEDURE ScanType(ra: LONGINT; ta: LONGINT; VAR count: INTEGER);

VAR 
  code:    INTEGER;  (* the actual rtti code               *)
  elems:   LONGINT;  (* number of array elements           *)
  ofs:     LONGINT;  (* offset of a pointer, ...           *)
  nc:      INTEGER;  (* number of rtti codes from ScanType *)
  p:       LONGINT;  (* pointer                            *)
  size:    LONGINT;

BEGIN

  SYSTEM.GET(ta - 2, code); 
  
  IF logActive & ((LOG_PROCENTRY IN DBGLVL)) THEN
    LogOpen();
    LogWriteStr("ScanType at");
    LogWriteHex(ra);
    LogWriteStr(" with RTTI at");
    LogWriteHex(ta);
    LogWriteStr(" code = ");
    LogWriteHex(code);
    LogWriteLn;
    LogClose;
  END;

  IF code = TYP_UNDEF THEN
    count := 1;

  ELSIF (code >= TYP_BYTE) & (code <= TYP_SET) THEN
    count := 3;
    
  ELSIF code = TYP_NOTYP THEN
    HALT(0);

  ELSIF code = TYP_PROCTYP THEN  
    count := 3;
    
  ELSIF code = TYP_POINTER THEN
    SYSTEM.GET(ta - 6, ofs);  (* get offset of pointer *)
    SYSTEM.GET(ra + ofs, p);  (* get pointer itself    *)
    (* -- mark block -- *)
    SYSTEM.GET(ta - 8, code); (* get type of pointer   *)
    IF (code = TYP_RECORD) OR (code = TYP_UNDEF) THEN (* record has its own type descriptor *)
      count := 4;
      (* -- mark block referenced by pointer -- *)
      IF MarkBlock(p) THEN END;
    ELSIF code = TYP_ARRAY THEN
      (* the type tag of the block referenced by p is 0!*)
      SYSTEM.GET(ta - 12, ofs); 
      SYSTEM.GET(ta - 16, size);  (* size of element    *)
      SYSTEM.GET(ta - 20, elems); (* number of elements *)
      IF MarkBlock(p) THEN
        ScanArray(p, ta - 20, elems, size, count);
      ELSE
        SkipType(ta - 20, count);
      END;
      INC(count, 10);
    ELSIF code = TYP_DYNARRAY THEN
      (* the type tag of the block referenced by p is 0!
         first 12 bytes of the array are not used by the array.
         first eight bytes are unknown
         next 4 bytes holds the highest possible index for the dynamic array (0..index)!*)
      SYSTEM.GET(ta - 12, ofs);  (* get offset of dynamic array *)
      SYSTEM.GET(ta - 16, size); (* get size of an element *)
      IF MarkBlock(p) THEN
        SYSTEM.GET(p + 8, elems);  (* number of elems *)
        ScanArray(p + 12, ta - 16, elems, size, count);
      ELSE
        SkipType(ta - 16, count);
      END;
      INC(count, 8);
    ELSE
      count := 1;
      HALT(0); (* should not be possible *)
    END;

  ELSIF code = TYP_HDPOINTER THEN
    SYSTEM.GET(ta - 6, ofs);  (* get offset of pointer *)
    SYSTEM.GET(ra + ofs, p);  (* get pointer itself    *)
    (* -- mark block -- *)
    IF MarkBlock(p) THEN END;
    count := 3;
    
  ELSIF code = TYP_ARRAY THEN
    SYSTEM.GET(ta - 6, ofs); 
    SYSTEM.GET(ta - 10, size);  (* size of element    *)
    SYSTEM.GET(ta - 14, elems); (* number of elements *)
    ScanArray(ra + ofs, ta - 14, elems, size, count);
    INC(count, 7); 

  ELSIF code = TYP_RECORD THEN
    SYSTEM.GET(ta - 6, ofs);
    count := 3;
    DEC(ta, 6);
    SYSTEM.GET(ta - 2, code);
    WHILE (code # TYP_ENDRECORD) DO
      ScanType(ra, ta, nc);
      ta := ta - 2 * nc;
      INC(count, nc);
      SYSTEM.GET(ta - 2, code);
    END;
    INC(count); (* for TYP_ENDRECORD *)

  ELSE (* error !! *)
    ShowInt(code);
    count := 1;
    HALT(0);
    
  END;
  
  IF logActive & (LOG_PROCEXIT IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("ScanType at");
    LogWriteHex(ra);
    LogWriteStr(" with RTTI at");
    LogWriteHex(ta);
    LogWriteStr(" code = ");
    LogWriteHex(code);
    LogWriteStr(" finished.");
    LogWriteLn;
    LogClose;
  END;

END ScanType;


(******************************************************************************
 *
 * marks all subblocks referenced by pointers within the record starting 
 * at the address ra.
 *
 ******************************************************************************)
PROCEDURE ScanRecord(ra: LONGINT; tdp: TypeDescriptorP);

VAR
  count: INTEGER;   (* number of bytes used by the rtti of the actual processed type *)
  i:     INTEGER;
  nc:    INTEGER;   (* number of bytes used by the run time type information *)
  ta:    LONGINT;   (* address of run time type information *)
  tn:    TypeNameP; (* pointer to type name *)
  size:  LONGINT;   (* size of record *)
    
BEGIN
  
  ta := SYSTEM.VAL(LONGINT, tdp) - 14;
  SYSTEM.GET(ta, nc);
  SYSTEM.GET(ta + 6, tn);
  SYSTEM.GET(ta + 10, size);
  
  IF logActive & ((LOG_PROCENTRY IN DBGLVL) OR (LOG_DEBUG IN DBGLVL)) THEN
    LogOpen();
    LogWriteStr("Scanning record ");
    LogWriteStr(tn^);
    LogWriteStr(" at address");
    LogWriteHex(ra);
    LogWriteStr(" with ");
    LogWriteInt(nc, 1);
    LogWriteStr(" words of RTTI.");
    LogWriteLn;
    LogClose;
  END;
  
  (* -- nc = 0: can have base classes with pointers!!! -- *)
  IF (nc >= 0) & ~TypeHasNoType(ta, nc) THEN  (* rtti code table ok *)

    (* -- scan run time type information -- *)
    WHILE (nc > 0) DO
      ScanType(ra, ta, count);
      ta := ta - 2 * count;
      DEC(nc, count);
    END;
  
    (* -- scan run time type informations in parent class -- *)
    i := MAXBASE - 1; (* at last index base holds pointer to itself *)
    WHILE (i >= 0) & (tdp^.base[i] = 0) DO DEC(i) END;
    IF (i > 0) THEN
      IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
        LogOpen();
        LogWriteStr("Scan parent class of "); 
        LogWriteStr(tn^);
        LogWriteLn;
        (* ShowDescriptor(tdp); *)
        LogClose();
      END;
      ScanRecord(ra, SYSTEM.VAL(TypeDescriptorP, tdp^.base[i - 1]));
    END;
  
  ELSE (* rtti table overrun *)
  
    ScanMemory(ra, ra + size - 1);
    
  END;

  IF logActive & (LOG_PROCEXIT IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("Scanning record ");
    LogWriteStr(tn^);
    LogWriteStr(" at address");
    LogWriteHex(ra);
    LogWriteStr(" finished.");
    LogWriteLn;
    LogClose;
  END;
  
END ScanRecord;


(******************************************************************************
 *
 * scans the global data of a module and marks all records which are pointed
 * to by global variables of this module.
 *
 ******************************************************************************)
PROCEDURE ScanGlobalData(ds: LONGINT; mdp: ModuleDescriptorP);

VAR
  count: INTEGER;  (* number of bytes used by the rtti of the actual processed type *)
  nc:    INTEGER;  (* number of bytes used by the run time type information *)
  ta:    LONGINT;  (* address of run time type information *)
    
BEGIN
  
  ta := SYSTEM.VAL(LONGINT, mdp) - 6;
  SYSTEM.GET(ta, nc);
  
  IF logActive & ((LOG_PROCENTRY IN DBGLVL)) THEN
    LogOpen();
    LogWriteStr("Processing module "); 
    LogWriteStr(mdp^.moduleName^); 
    LogWriteStr(" with ");
    LogWriteInt(nc, 1);
    LogWriteStr(" words of RTTI.");
    LogWriteHex(ds);
    LogWriteLn;
    ShowGlobalData(ds, mdp);
    LogClose;
  END;

  IF (nc = 0) THEN
    (* no rtti code available *)
  ELSIF (nc > 0) & ~TypeHasNoType(ta, nc) THEN  (* rtti code table ok *)
    WHILE (nc > 0) DO
      ScanType(ds, ta, count);
      ta := ta - 2 * count;
      DEC(nc, count);
    END;
  ELSE (* rtti table overrun *)
    ScanMemory(ds, ds + mdp^.globalDataSize - 1); (* scan whole global data segment *)
  END;

  IF logActive & (LOG_PROCEXIT IN DBGLVL) THEN
    LogOpen();
    LogWriteStr("Processing module "); 
    LogWriteStr(mdp^.moduleName^); 
    LogWriteStr(" finished.");
    LogWriteLn;
    LogClose;
  END;

END ScanGlobalData;


PROCEDURE ^Dispose*(adr: LONGINT);

(* Stack Pointer soll außerhalb dieser Prozedur ermittelt werden, damit
   die lokalen Variablen dieser Prozdedur nicht in die Stack-
   Suche eingebunden werden.*)
PROCEDURE GC(); (* Garbage Collector *)

VAR
  adr:  LONGINT; (* address of a subblock or global data *)
  ebp:  LONGINT; (* register ebp = base pointer          *)
  esp:  LONGINT; (* register esp = stack pointer         *)
  i:    INTEGER;
  obj:  LONGINT; (* address of a memory object           *)
  size: LONGINT; (* size of a subblock                   *)
  tt:   LONGINT; (* type tag                             *)

BEGIN

  IF logActive & (LOG_SYSTEMTABLE IN DBGLVL) THEN
    ShowModules();
    ShowStack();
    ShowHeap();
  END;

  (* -- initialize statistical data -- *)
  gcCount.candidates := 0;
  gcCount.markedBlocks := 0;
  
  gcMem := 0;

  (* -- unmark all blocks -- *)
  FOR i := 0 TO memBlockN DO
    adr := memBlocks[i].last;
    WHILE (adr # 0) DO
      SYSTEM.PUT(adr + SB_OFS_USED, FALSE);     (* adr.used := FALSE    *)
      SYSTEM.PUT(adr + SB_OFS_SCANNED, FALSE);  (* adr.scanned := FALSE *)
      SYSTEM.GET(adr + SB_OFS_PREV, adr);       (* adr := adr^.prev     *)
    END;
  END;

  (* -- mark all blocks referenced by a global pointer -- *)
  IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
    LogOpen();
    LogWriteLn;
    LogWriteStr("Marking blocks referenced by global pointers"); LogWriteLn;
    LogClose();
  END;
  FOR i := 0 TO moduleN - 1 DO
    adr := SYSTEM.VAL(LONGINT, moduleList[i]^.globalData);
    ScanGlobalData(adr, moduleList[i]);
  END;

  (* -- mark all blocks referenced by a local pointer (stack) -- *)
  IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
    ShowHeap();
    LogOpen();
    LogWriteLn;
    LogWriteStr("Marking blocks referenced by local pointers"); LogWriteLn;
    LogClose();
  END;

  SYSTEM.GETREG(5, ebp);
  SYSTEM.GETREG(4, esp);
  WHILE (ebp # 0) DO      (* could be optimized: the stack of the procedure GC need not be scanned *)
    ScanMemory(esp, ebp); (* maybe esp + 4 *)
    esp := ebp;
    SYSTEM.GET(ebp, ebp);
  END;

  (* -- go through heap and mark all descendant blocks -- *)
  IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
    ShowHeap();
    LogOpen();
    LogWriteLn;
    LogWriteStr("Marking descendant blocks"); LogWriteLn;
    LogClose;
  END;
  
  REPEAT
    
    IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
      LogOpen();
      LogWriteStr("Starting a new heap scan ... ");
      LogWriteLn;
      LogClose();
    END;
      
    gcMarked := FALSE; (* gcMarked will be set to TRUE by MarkBlock *)
      
    FOR i := 0 TO memBlockN DO
      adr := memBlocks[i].last;
      WHILE (adr # 0) DO
        (* -- if block is used and not scanned, scan block -- *)
        GetSubBlockSize(adr, size);
        IF ~IsSubBlockScanned(adr) & (size > 0) & (IsSubBlockUsed(adr) OR IsSubBlockLocked(adr)) THEN
          (* -- check if type descriptor is valid; module could have been unloaded -- *)
          obj := adr + SUBBLOCKSIZE;
          GetObjType(obj, tt);
          IF IsValidTypeDescriptorP(tt) THEN
            ScanRecord(obj, SYSTEM.VAL(TypeDescriptorP, tt));
          ELSE
            ScanMemory(obj, obj + size - 1 - SUBBLOCKSIZE);
          END;
          SetSubBlockScanned(adr, TRUE);
        END;
        SYSTEM.GET(adr + SB_OFS_PREV, adr);         (* adr := adr^.prev     *)
      END;
    END;

  UNTIL ~gcMarked;

  (* -- dispose all blocks not used by the actual application -- *)
  IF logActive & (LOG_SPECIAL IN DBGLVL) THEN
    ShowHeap();
    LogOpen();
    LogWriteLn;
    LogWriteStr("Disposing unused blocks"); LogWriteLn;
    LogClose;
  END;
  FOR i := 0 TO memBlockN DO
    adr := memBlocks[i].last;
    WHILE (adr # 0) DO
      GetSubBlockSize(adr, size);
      IF (size > 0) & (~IsSubBlockUsed(adr)) & (~IsSubBlockLocked(adr)) THEN (* not free and used by the current program *)
        obj := adr + SUBBLOCKSIZE;
        (* -- search used subblock (all free subblocks will be merged) -- *)
        GetSubBlockPrev(adr, adr);  (* adr := adr^.prev *)
        WHILE (adr # 0) & IsSubBlockFree(adr) DO GetSubBlockPrev(adr, adr); END;
        Dispose(obj);
      ELSE
        GetSubBlockPrev(adr, adr);  (* adr := adr^.prev     *)
      END;
    END;
  END;

  IF logActive & (LOG_SYSTEMTABLE IN DBGLVL) THEN
    ShowHeap();
  END;
  
END GC;


PROCEDURE RunGC(): BOOLEAN;
BEGIN
  RETURN gcActive & (gcMem >= GC_MEM);
END RunGC;



(***************************************************************************
 * 
 * MEMORY MANAGMENT 
 * 
 ***************************************************************************
 * 
 * New, SysNew and Dispose are called by compiler generated code.
 * The other functions are called by New, SysNew and Dispose.
 * 
 ***************************************************************************)

(* checks, if the whole heap is consistent *)
PROCEDURE IsHeapValid(): BOOLEAN;
VAR
  i:        INTEGER;
  next:     LONGINT;
  prev:     LONGINT;
  prevSize: LONGINT;
  sb:       LONGINT;
  size:     LONGINT;
BEGIN

  FOR i := 0 TO memBlockN DO

    (* -- check memory block entries -- *)
    IF (memBlocks[i].size <= 0) OR 
       (memBlocks[i].handle = 0) OR 
       (memBlocks[i].adr = 0) OR 
       ((memBlocks[i].first # 0) & ((memBlocks[i].first > memBlocks[i].last) OR (memBlocks[i].first < memBlocks[i].adr))) OR
       (memBlocks[i].last = 0) OR 
       (memBlocks[i].last < memBlocks[i].adr) THEN
      LogOpen(); LogWriteStr("Entry "); LogWriteInt(i, 0); LogWriteStr(" of memBlocks wrong."); LogWriteLn(); LogClose();
      RETURN FALSE;
    END;

    (* -- check first subblock -- *)
    SYSTEM.GET(memBlocks[i].adr + SB_OFS_PREV, prev);
    IF (prev # 0) THEN 
      LogOpen(); LogWriteStr("first subblock of memory block "); LogWriteInt(i, 0); LogWriteLn(); LogClose();
      RETURN FALSE 
    END;

    (* -- check last subblock -- *)
    SYSTEM.GET(memBlocks[i].last + SB_OFS_NEXT, next);
    IF (next # 0) THEN 
      LogOpen(); LogWriteStr("last subblock of memory block "); LogWriteInt(i, 0); LogWriteLn(); LogClose();
      RETURN FALSE 
    END;

    (* -- check if first subblock is free -- *)
    IF (memBlocks[i].first # 0) THEN
      SYSTEM.GET(memBlocks[i].first + SB_OFS_SIZE, size);
      IF (size >= 0) THEN 
        LogOpen(); LogWriteStr("size of memory block "); LogWriteInt(i, 0); LogWriteLn(); LogClose();
        RETURN FALSE 
      END;
    END;

    (* -- check all subblocks -- *)
    sb := memBlocks[i].adr;
    WHILE (sb <= memBlocks[i].last) DO

      SYSTEM.GET(sb + SB_OFS_PREV, prev);
      SYSTEM.GET(sb + SB_OFS_NEXT, next);
      SYSTEM.GET(sb + SB_OFS_SIZE, size);
      
      (* -- check for correct linking of prev -- *)
      IF ((prev = 0) & (sb # memBlocks[i].adr)) OR 
         ((prev # 0) & ((prev >= sb) OR (prev < memBlocks[i].adr))) THEN 
        LogOpen(); LogWriteStr("prev pointer of subblock "); LogWriteHex(sb); LogWriteLn(); LogClose();
        RETURN FALSE;
      END;
      IF (prev # 0) THEN
        SYSTEM.GET(prev + SB_OFS_SIZE, prevSize);
        IF (prev + ABS(prevSize) # sb) THEN
          LogOpen(); LogWriteStr("size of previous subblock "); LogWriteHex(sb); LogWriteLn(); LogClose();
          RETURN FALSE 
        END;
      END;

      (* -- check size -- *)
      IF (size >= 0) & (size <= SUBBLOCKSIZE) THEN 
        LogOpen(); LogWriteStr("size of subblock "); LogWriteHex(sb); LogWriteLn(); LogClose();
        RETURN FALSE 
      END;

      IF (size < 0) THEN
        (* -- check free subblock -- *)
        IF ((next # 0) & ((next <= sb) OR (next > memBlocks[i].last))) THEN 
          LogOpen(); LogWriteStr("next pointer in free subblock "); LogWriteHex(sb); LogWriteLn(); LogClose();
          RETURN FALSE 
        END;
        sb := sb - size;
        (* -- check if next subblock is free -- *)
        IF (next # 0) THEN
          SYSTEM.GET(next + SB_OFS_SIZE, size);
          IF (size >= 0) THEN 
            LogOpen(); LogWriteStr("size in next free subblock "); LogWriteHex(next); LogWriteLn(); LogClose();
            RETURN FALSE 
          END;
        END;
      ELSE
        (* -- check not free subblock -- *)
        IF (next # 0) THEN 
          LogOpen(); LogWriteStr("next pointer in nonfree subblock "); LogWriteHex(sb); LogWriteLn(); LogClose();
          RETURN FALSE 
        END;
        sb := sb + size;
      END;

    END;
  END;
  RETURN TRUE;

END IsHeapValid;

(***************************************************************************
 * allocates a new block for memory management. block contains the index
 * of the new block and subBlock the adress of the new block
 ***************************************************************************)
PROCEDURE AllocateNewBlock(size: LONGINT; VAR block: LONGINT; VAR subBlock: LONGINT);

  VAR 
    adr:  LONGINT;
    hMem: W.HANDLE;
    
BEGIN
  block := -1;
  IF memBlockN < LEN(memBlocks) - 1 THEN
    (* -- allocate a new block -- *)
    hMem := W.GlobalAlloc(W.GMEM_FIXED + W.GMEM_ZEROINIT, size);
    IF hMem # 0 THEN
      (* -- store information about block -- *)
      INC(memBlockN);
      adr := W.GlobalLock(hMem);
      memBlocks[memBlockN].handle := hMem;
      memBlocks[memBlockN].size   := size;
      memBlocks[memBlockN].adr    := adr;
      memBlocks[memBlockN].first  := adr;
      memBlocks[memBlockN].last   := adr;
      (* -- create an empty subblock -- *)
      SetSubBlockNext(adr, 0);
      SetSubBlockPrev(adr, 0);
      SetSubBlockSize(adr, -size);
      (* -- set return values -- *)
      block := memBlockN;
      subBlock := adr;
    ELSE
      HALT(HALT_RTS_OUT_OF_MEM);
    END;
  ELSE
    HALT(HALT_RTS_OUT_OF_MEM);
  END;
END AllocateNewBlock;


(***************************************************************************
 * looks for a subblock of the specified size. If such a subblock can be
 * found the block number and the address of the subblock is returned.
 * Otherwise -1 is returned in block.
 ***************************************************************************)
PROCEDURE GetFreeSubBlock(size: LONGINT; VAR block: LONGINT; VAR subBlock: LONGINT);

  VAR
    found:  BOOLEAN;
    sbSize: LONGINT;
    
BEGIN
  (* -- look for a block which contains a free sub block of the specified size -- *)
  block := memBlockN;
  subBlock := 0;
  WHILE (block >= 0) & (subBlock = 0) DO
    (* -- look for a sub block of the specified size -- *)
    found := FALSE;
    subBlock := memBlocks[block].first; (* first free sub block *)
    WHILE (subBlock # 0) & ~found DO
      SYSTEM.GET(subBlock + SB_OFS_SIZE, sbSize);           (* GetSubBlockSize(subBlock, sbSize);   *)
      found := (- sbSize >= size);
      IF ~found THEN 
        SYSTEM.GET(subBlock + SB_OFS_NEXT, subBlock);       (* GetSubBlockNext(subBlock, subBlock); *)
      END;
    END;
    IF subBlock = 0 THEN DEC(block); END;
  END;
END GetFreeSubBlock;


(***************************************************************************
 * alllcates a subblock in the specified memory block and address.
 * If the free subblock is larger than the needed size the subblock is
 * divided into two subblocks.
 ***************************************************************************)
PROCEDURE AllocateSubBlock(block: LONGINT; subBlock: LONGINT; size: LONGINT; VAR adr: LONGINT);

  VAR
    h:      LONGINT;
    next:   LONGINT;
    sbSize: LONGINT;
    sbNew:  LONGINT;
    
BEGIN
  adr := 0;
  GetSubBlockSize(subBlock, sbSize);
  ASSERT(sbSize < 0);
  sbSize := - sbSize;
  IF (sbSize <= size + SUBBLOCKSIZE + 4) THEN
    (* -- allocate whole sub block to avoid fragmentation -- *)
    SetSubBlockSize(subBlock, sbSize);
    (* -- remove sub block from list of free blocks -- *)
    IF memBlocks[block].first = subBlock THEN
      GetSubBlockNext(subBlock, memBlocks[block].first);
    ELSE (*memBlocks[block].first < subBlock THEN*)
      (* -- look for prev free sub block -- *)
      GetSubBlockPrev(subBlock, h);
      WHILE (h # 0) & (~IsSubBlockFree(h)) DO GetSubBlockPrev(h, h) END;
      IF (h # 0) THEN
        GetSubBlockNext(subBlock, next);
        SetSubBlockNext(h, next);
      END;
    END;
    SetSubBlockNext(subBlock, 0);
    adr := subBlock;
  ELSE
    (* -- split sub block -- *)
    sbNew := subBlock + sbSize - size;           (* get new sub block        *)
    IF memBlocks[block].last = subBlock THEN
      memBlocks[block].last := sbNew;
    ELSE
      SetSubBlockPrev(subBlock + sbSize, sbNew); (* set prev of next sub block *)
    END;
    SetSubBlockSize(subBlock, -(sbSize - size)); (* reduce size of splitted sub block *)
    SetSubBlockSize(sbNew, size);
    SetSubBlockPrev(sbNew, subBlock);
    SetSubBlockNext(sbNew, 0);
    adr := sbNew;
  END;
END AllocateSubBlock;


(***************************************************************************
 * fills a memory block with zero.
 ***************************************************************************)
PROCEDURE ClearMemory(adr: LONGINT; count: LONGINT);
  VAR i: LONGINT; end: LONGINT;
BEGIN
  end := adr + count - 1;
  end := end - (end MOD 4);
  FOR i := adr TO end DO
    SYSTEM.PUT(i, LONG(LONG(0)));
  END;
END ClearMemory;


(***************************************************************************
 * AllocateMemory allocates a block of memory. It allocates eight extra bytes
 * for the unique ID and the typetag at the beginning.
 ***************************************************************************)
PROCEDURE AllocateMemory(typetag, size: LONGINT; init: BOOLEAN; VAR adr: LONGINT);

  VAR 
    block:    LONGINT;
    subBlock: LONGINT;
      
BEGIN

  (* -- check validity of the heap -- *)
  IF LOG_HEAP IN DBGLVL THEN
    LogOpen();
    LogWriteStr("Typetag: "); LogWriteHex(typetag); LogWriteLn;
    LogWriteStr("Size:    "); LogWriteHex(size); LogWriteLn;
    LogWriteStr("Init:    "); IF init THEN LogWrite('J') ELSE LogWrite('N') END; LogWriteLn;
    LogClose();
    IF ~IsHeapValid() THEN
      LogOpen(); LogWriteStr("Start of AllocateMemory"); LogWriteLn(); LogClose();
      ShowHeap();
      HALT(HALT_RTS_HEAP_CORRUPT);
    END;
  END;

  (* -- activate Garbage collector -- *)
  IF RunGC() THEN
    GC();
  END;

  INC(size, SUBBLOCKSIZE);
  INC(size, (-size) MOD 4); (* dword alignment *)
  IF size > MEMBLOCKSIZE THEN
    AllocateNewBlock(size, block, subBlock);
    IF block = -1 THEN HALT(HALT_RTS_OUT_OF_MEM) END;
    AllocateSubBlock(block, subBlock, size, adr);
  ELSE
    GetFreeSubBlock(size, block, subBlock);
    IF block = -1 THEN
      AllocateNewBlock(MEMBLOCKSIZE, block, subBlock);
      IF block = -1 THEN HALT(HALT_RTS_OUT_OF_MEM) END;
    END;
    AllocateSubBlock(block, subBlock, size, adr);
  END;
  IF adr # 0 THEN
    INC(adr, SUBBLOCKSIZE);
    SetObjType(adr, typetag);
    INC(currentID);
    SetObjUID(adr, currentID);
    IF init THEN
      ClearMemory(adr, size - SUBBLOCKSIZE);
    END;
    INC(gcMem, size);
  END;

  (* -- check validity of the heap -- *)
  IF LOG_HEAP IN DBGLVL THEN
    LogOpen();
    LogWriteStr("Adr:     "); LogWriteHex(adr); LogWriteLn;
    LogWriteStr("UID:     "); LogWriteHex(currentID); LogWriteLn;
    LogClose();
    IF ~IsHeapValid() THEN
      LogOpen(); LogWriteStr("End of AllocateMemory"); LogWriteLn(); LogClose();
      ShowHeap();
      HALT(HALT_RTS_HEAP_CORRUPT);
    END;
  END;

END AllocateMemory;


(***************************************************************************
 * gets the block number for a specified address.
 ***************************************************************************)
PROCEDURE GetBlock(adr: LONGINT; VAR block: LONGINT);
BEGIN
  block := memBlockN;
  WHILE (block >= 0) & ~((adr >= memBlocks[block].adr) & (adr <= memBlocks[block].adr + memBlocks[block].size - 1)) DO
    DEC(block);
  END;
END GetBlock;


(***************************************************************************
 * merges contigous free subblocks to one free subblock.
 ***************************************************************************)
PROCEDURE MergeFreeSubBlocks(block: LONGINT; subBlock: LONGINT);

  VAR
    first: LONGINT;
    last:  LONGINT;
    size:  LONGINT;
    t:     LONGINT;
    
BEGIN

  (* -- check if the next sub block is free -- *)
  GetSubBlockSize(subBlock, size);
  ASSERT(size < 0);
  IF (memBlocks[block].last # subBlock) & IsSubBlockFree(subBlock - size) THEN
    last := subBlock - size;
  ELSE
    last := subBlock;
  END;

  (* -- find free contigous sub blocks -- *)
  first := subBlock;
  SYSTEM.GET(first + SB_OFS_PREV, t);    (* t := first^.prev  *)
  LOOP
    IF t = 0 THEN EXIT END;
    SYSTEM.GET(t + SB_OFS_SIZE, size);    (* size := t^.size  *)
    IF size >= 0 THEN EXIT END;
    first := t;
    SYSTEM.GET(t + SB_OFS_PREV, t);      (* t := t^.prev    *)
  END;

  (* all subblock from first to last are contigous and free *)

  (* -- are there more than one free sub block -- *)
  IF first # last THEN

    (* -- merge all block from first to last -- *)
    GetSubBlockNext(last, t);
    SetSubBlockNext(first, t);
    (* SetSubBlockPrev(first) ist gesetzt ! *)
    GetSubBlockSize(last, size);
    SetSubBlockSize(first, -(last - first - size));

    IF memBlocks[block].last # last THEN
      t := last - size; (* next not free sub block *)
      SetSubBlockPrev(t, first);
    ELSE
      memBlocks[block].last := first;
    END;

  END;

END MergeFreeSubBlocks;


(***************************************************************************
 * disposes a subblock.
 ***************************************************************************)
PROCEDURE DisposeSubBlock(block: LONGINT; subBlock: LONGINT);

  VAR 
    h:      LONGINT;
    sbSize: LONGINT;
    t:      LONGINT; (* temporary *)
    
BEGIN
  GetSubBlockSize(subBlock, sbSize); 
(*  DEC(gcMem, sbSize);*)
  ASSERT(sbSize > 0, HALT_RTS_HEAP_CORRUPT);
  SetSubBlockSize(subBlock, -sbSize);
  (* -- find previous free sub block -- *)
  IF (memBlocks[block].first = 0) OR (memBlocks[block].first > subBlock) THEN
    SetSubBlockNext(subBlock, memBlocks[block].first);
    memBlocks[block].first := subBlock;
  ELSE
    SYSTEM.GET(subBlock + SB_OFS_PREV, h);
    LOOP
      IF h = 0 THEN EXIT END;
      SYSTEM.GET(h + SB_OFS_SIZE, sbSize);  (* sbSize := h^.size *)
      IF sbSize < 0 THEN EXIT END;
      SYSTEM.GET(h + SB_OFS_PREV, h);    (* h := h^.prev      *)
    END;
    IF (h # 0) THEN
      GetSubBlockNext(h, t);
      SetSubBlockNext(subBlock, t);
      SetSubBlockNext(h, subBlock);
    ELSE
      SetSubBlockNext(subBlock, memBlocks[block].first);
      memBlocks[block].first := subBlock;
    END;
  END;
END DisposeSubBlock;


(***************************************************************************
 * disposes a whole memory block.
 ***************************************************************************)
PROCEDURE DisposeBlock(block: LONGINT);
BEGIN
  IF (block >= 0) & (block <= memBlockN) THEN
    (* -- free allocated block -- *)
    IF W.GlobalUnlock(memBlocks[block].handle) = 0 THEN 
      (* ShowLastError(); HALT(0); *) (* special case for OED *)
    END;
    IF W.GlobalFree(memBlocks[block].handle) # 0 THEN 
      (* ShowLastError(); HALT(0); *) (* special case for OED *)
    END;
    (* -- remove entry from block table -- *)
    WHILE (block < memBlockN) DO
      memBlocks[block] := memBlocks[block+1];
      INC(block);
    END;
    DEC(memBlockN);
  END;
END DisposeBlock;


(***************************************************************************
 * FreeMemory deallocates a block of memory. 
 ***************************************************************************)
PROCEDURE FreeMemory(adr: LONGINT);
  VAR 
    block:  LONGINT;
    sbSize: LONGINT;
BEGIN

  (* -- check validity of the heap -- *)
  IF LOG_HEAP IN DBGLVL THEN
    IF ~IsHeapValid() THEN
      LogOpen(); LogWriteStr("Start of FreeMemory"); LogWriteLn(); LogClose();
      ShowHeap();
      HALT(HALT_RTS_HEAP_CORRUPT);
    END;
  END;

  DEC(adr, SUBBLOCKSIZE);
  GetBlock(adr, block);
  IF block >= 0 THEN
    DisposeSubBlock(block, adr);
    MergeFreeSubBlocks(block, adr);
    (* -- if whole memory block is free, dispose it -- *)
    IF memBlocks[block].first # 0 THEN
      GetSubBlockSize(memBlocks[block].first, sbSize);
      IF memBlocks[block].size = -sbSize THEN
        DisposeBlock(block);
      END;
    END;
  END;

  (* -- check validity of the heap -- *)
  IF LOG_HEAP IN DBGLVL THEN
    IF ~IsHeapValid() THEN
      LogOpen(); LogWriteStr("End of FreeMemory"); LogWriteLn(); LogClose();
      ShowHeap();
      HALT(HALT_RTS_HEAP_CORRUPT);
    END;
  END;

END FreeMemory;


(***************************************************************************
 * The following function is called for every NEW Statement in the source 
 * code except for open arrays. 
 * The compiler generates code which passes the typetag and the size
 * of the block to the function and expects the address of the allocated
 * block. If the size is negativ the allocated memory should be initialized
 * with null.
 ***************************************************************************)
PROCEDURE New*(typetag, size: LONGINT; VAR adr: LONGINT);
BEGIN
  AllocateMemory(typetag, ABS(size), size < 0, adr);
END New;

(***************************************************************************
 * The following function is called for every NEW Statement in the source 
 * code which allocates an open array. 
 * The compiler generates code which passes the size of the array to the 
 * function and expects the address of the allocated block. If the size 
 * is negativ the allocated memory should be initialized with null.
 ***************************************************************************)
PROCEDURE SysNew*(size: LONGINT; VAR adr: LONGINT);
BEGIN
  AllocateMemory(0, ABS(size), size < 0, adr);
END SysNew;


(***************************************************************************
 * The function Dispose is called every time the Statement DISPOSE is used
 * in the source code.
 * The compiler generates code, which passes the address of the block which
 * should be deallocated to the function.
 ***************************************************************************)
PROCEDURE Dispose*(adr: LONGINT);
BEGIN
  FreeMemory(adr);
END Dispose;


(******************************************************************************
 *
 * ObjToName(obj, codeName, name)
 *
 ******************************************************************************
 * 
 * The symbolic name of an objects qualified class name and the name of its 
 * code module are returned.
 * 
 ******************************************************************************
 * Parameter  Description
 * ---------  -----------------------------------------------------------------
 * obj        IN  pointer to the object whose symbolic name should be determined
 * codeName   OUT returns the full pathname of the .EXE or .DLL file containing 
 *                the code of the class implementation
 * name       OUT returns the qualified class name of the object in the form 
 *                moduleName.typeName
 ******************************************************************************)
PROCEDURE ObjToName*(p: Object; VAR codeName, name: ARRAY OF CHAR);

  VAR
    x:       LONGINT;
    typetag: LONGINT;
    nameP:   NameP;

BEGIN
  IF p = NIL THEN
    codeName[0] := 0X;
    COPY("NIL", name);
  ELSE
    x := SYSTEM.VAL(LONGINT, p);
    SYSTEM.MOVE(x-4,SYSTEM.ADR(typetag),4);
    SYSTEM.MOVE(typetag - 8, SYSTEM.ADR(nameP), 4);
(*    SYSTEM.GET(x-4,typetag);
    SYSTEM.GET(typetag-8,nameP);*)
    COPY(nameP^, name);
    codeName[0]:=0X;
  END;
END ObjToName;


(******************************************************************************
 *
 * TypetagToModRecName(typetag, modName, recName, codeName)
 *
 ******************************************************************************
 * 
 * The symbolic name of a typetag qualified class name and the name of its 
 * code module are returned.
 * 
 ******************************************************************************
 * Parameter  Description
 * ---------  -----------------------------------------------------------------
 * typetag    IN  pointer to the typetag whose symbolic name should be 
 *                determined
 * modName    OUT returns the name of the module which the typetag belongs to
 * recName    OUT returns the class name of the typetag
 * codeName   OUT returns the full pathname of the .EXE or .DLL file containing 
 *                the code of the class implementation
 ******************************************************************************)

PROCEDURE TypetagToModRecName*(typetag: LONGINT;
                               VAR modName, recName, codeName: ARRAY OF CHAR);
BEGIN
  COPY("", modName);
  COPY("", recName);
  COPY("", codeName);
END TypetagToModRecName;


(******************************************************************************
 *
 * ModRecNameToTypetag(modName, recName, codeName, typetag, res)
 *
 ******************************************************************************
 * 
 * The typetag of a class (specified by module, type and code name) and a 
 * result code are returned.
 * 
 ******************************************************************************
 * Parameter  Description
 * ---------  -----------------------------------------------------------------
 * modName    IN  the name of the module which the typetag belongs to
 * recName    IN  the class name of the typetag
 * codeName   IN  the full pathname of the .EXE or .DLL file containing 
 *                the code of the class implementation
 * typetag    OUT pointer to the typetag 
 * res        OUT result code: 1 = success, 0 = no luck, -1 codeName not found
 ******************************************************************************)

PROCEDURE ModRecNameToTypetag*(VAR modName-, recName-, codeName-: ARRAY OF CHAR;
                               VAR typetag: LONGINT; VAR res:INTEGER);
  VAR
    i:    LONGINT;
    j:    LONGINT;
    name: ARRAY MAX_ID_LEN OF CHAR;

BEGIN

  (* -- initialization -- *)
  typetag := 0;
  res     := -1;

  (* -- look for module in module table *)
  i := moduleN - 1;
  WHILE (i >= 0) & (moduleList[i].moduleName^ # modName) DO DEC(i) END;

  (* -- if module found look for type name *)
  IF (i >= 0) THEN
    j := LEN(moduleList[i].typetagList^);
    REPEAT
      DEC(j);
      GetTypeName(SYSTEM.VAL(LONGINT, moduleList[i].typetagList[j]), name);
    UNTIL (j = 0) OR (name = recName);
    IF (j >= 0) & (name = recName) THEN
      (* -- type name found -- *)
      typetag := SYSTEM.VAL(LONGINT, moduleList[i].typetagList[j]);
      res := 1;
    ELSE
      res := 0;
    END;
  ELSE
    res := 0;
  END;

END ModRecNameToTypetag;



(***************************************************************************
 * 
 * STARTUP AND TERMINATION
 * 
 ***************************************************************************
 * 
 * 
 ***************************************************************************)


PROCEDURE InitModule*(mda: LONGINT);
VAR mdp: ModuleDescriptorP;
BEGIN
  IF moduleN < MAXMODULES THEN
    mdp := SYSTEM.VAL(ModuleDescriptorP, mda);
    moduleList[moduleN] := mdp; 
    INC(moduleN); 
  ELSE
    HALT(HALT_RTS_TOO_MANY_MODULES);
  END;
END InitModule;


PROCEDURE InitDLL*(mdp: ModuleDescriptorP; hDLL: W.HANDLE; dwReason: W.DWORD; lpReserved: W.LPVOID);
BEGIN
END InitDLL;


PROCEDURE LeavingWinMain*;
BEGIN
END LeavingWinMain;


(*****************************************************************************

 The function Lock locks a memory blocks. This can be used to tell the 
 garbage collector not to free the memory block even if it isn't used any
 more.
 The function Unlock does the opposite. It tells the garbage collector
 that the memory block can be freed if it isn't used any more.

 *****************************************************************************)

PROCEDURE Lock*(adr: SYSTEM.PTR);
BEGIN
  IF IsValidHeapObject(SYSTEM.VAL(LONGINT, adr)) THEN
    SetSubBlockLocked(SYSTEM.VAL(LONGINT, adr) - SUBBLOCKSIZE, TRUE);
  END;
END Lock;

PROCEDURE Unlock*(adr: SYSTEM.PTR);
BEGIN
  IF IsValidHeapObject(SYSTEM.VAL(LONGINT, adr)) THEN
    SetSubBlockLocked(SYSTEM.VAL(LONGINT, adr) - SUBBLOCKSIZE, FALSE);
  END;
END Unlock;


(*****************************************************************************

 This function starts the garbage collector immediately.

 *****************************************************************************)

PROCEDURE GCCollect*();
BEGIN
  GC();
END GCCollect;


(*****************************************************************************

 Normally the garbage collector starts automatically at regular intervals.
 This can be switched off using the function GCDisable and can be switched
 on with the function GCEnable. The function GCIsActive returns the 
 information whether this switch is on or off.

 *****************************************************************************)

PROCEDURE GCEnable*();
BEGIN
  gcActive := TRUE;
END GCEnable;

PROCEDURE GCDisable*();
BEGIN
  gcActive := FALSE;
END GCDisable;

PROCEDURE GCIsActive*(): BOOLEAN;
BEGIN
  RETURN gcActive;
END GCIsActive;


(*****************************************************************************

 Zu Testzwecken kann für Operationen des Garbage Collector ein Log mitge-
 schrieben werden. Die Daten werden in die Datei "c:\rtsobero.txt" geschrieben.
 Mit EnableLog wird der Log eingeschaltet und mit DisableLog ausgeschaltet.

 *****************************************************************************)

PROCEDURE LogEnable*();
BEGIN
  logActive := TRUE;
END LogEnable;

PROCEDURE LogDisable*();
BEGIN
  logActive := FALSE;
END LogDisable;


BEGIN
  moduleN   := 0;
  currentID := 0;
  gcActive  := GC_ACTIVE;
  gcMem     := 0;
  logActive := LOG_ACTIVE;
  memBlockN := -1;
END RTSOberon.

