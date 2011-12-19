(*===========================================================================

  DESCRIPTION:
  This module is an optimized version of the Run-Time-System for the 
  Oberon-2 compiler.
  
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
 ===========================================================================*)

MODULE RTSOberon;


  IMPORT Str := String, SYSTEM, W := Win32;
  
  
  CONST
  
    MAX_ID_LEN* = 45;

    MAXBASE       = 10;  (* maximum base classes possible; compiler restriction *)
    MAXCODEMODULE = 100;
    MAXMODULE     = 500;
    MAXPATH       = 256;
  
    BLOCKINFOSIZE = 8;
    
    MEMFIRSTBLOCKSIZE = 2 * 1024 * 1024;
    MEMNEXTBLOCKSIZE  = 1024 * 256;
    
    OUT_OF_MEM_HALT=10000;

  TYPE
    
    (************************************************************************
     *
     * The following precedes every memory block allocated by NEW. 
     * The compiler expects the type descriptor exactly four bytes before the
     * memory block. So the typedescriptor should always be the last element
     * in this structure!
     *
     ************************************************************************)
    BlockInfoT- = RECORD
      uniqueID-: LONGINT; (* every memory block has a unique id for serialization *)
      typeDesc-: LONGINT; (* type descriptor *)
    END;
    BlockInfoP- = POINTER TO BlockInfoT;
    
    (************************************************************************
     *
     * The module descriptor is a compiler generated structure. It describes
     * a module (name, commands, type descriptors). A module descriptor
     * pointer does not point to the beginning of the structure!! It points
     * to module name pointer as it is shown in the following table.
     *
     * memory layout of module descriptor:
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
     *        res(32) for GC,
     * mdp -> ptr to module name,
     *        size of module global data section
     *        ptr to global module data
     *        ptr to open array of type descriptors
     *        ptr to open array of commands 
     *
     ***********************************************************************)
    ModuleDescriptorT = RECORD
      moduleName-:      POINTER TO ARRAY MAX_ID_LEN OF CHAR;
      globalDataSize-:  LONGINT;
      globalData-:      SYSTEM.PTR; 
      typeDescList-:    POINTER TO ARRAY OF SYSTEM.PTR;
      commandList-:     POINTER TO ARRAY OF SYSTEM.PTR;
    END;
    ModuleDescriptorP = POINTER TO ModuleDescriptorT;
  
    CodeModuleT- = RECORD 
      path-:         ARRAY MAXPATH OF CHAR;
      id-:           LONGINT;
      module-:       ARRAY MAXMODULE OF ModuleDescriptorP;
      moduleN-:      LONGINT;
      moduleHandle-: W.HMODULE;
    END;
    CodeModuleP- = POINTER TO CodeModuleT;
    
    TypeDescriptorT- = RECORD
      base-: ARRAY MAXBASE OF LONGINT;
    END;
    TypeDescriptorP- = POINTER TO TypeDescriptorT;
    
    TypeDescriptorPraefixT- = RECORD
      nc-:       INTEGER;  (* number of bytes for runtime type information *)
      xxx-:      LONGINT;  (* reserved for garbage collector *)
      typeName-: POINTER TO ARRAY 32 OF CHAR; 
      size-:     LONGINT;  (* size of record *)
    END;
    TypeDescriptorPraefixP- = POINTER TO TypeDescriptorPraefixT;
    
    ModuleDescriptorPraefixT- = TypeDescriptorPraefixT;
    ModuleDescriptorPraefixP- = POINTER TO ModuleDescriptorPraefixT;
  
    ObjectT* = RECORD
    END;
    Object* = POINTER TO ObjectT;
  
    Name*  = ARRAY MAX_ID_LEN OF CHAR;
    NameP  = POINTER TO Name;
  
  
  VAR
    currentID:   LONGINT;
    memAllocated:BOOLEAN;
    memBlock:    LONGINT;
    memMark:     LONGINT;
    memSize:     LONGINT;
    memUsed:     LONGINT;
    moduleList-: ARRAY 100 OF ModuleDescriptorP;
    moduleN-:    LONGINT;


(** Utility functions for convenient string concatenation *)
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

PROCEDURE ShowMsg(VAR msg-: ARRAY OF CHAR);
BEGIN
  IF W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR("debug msg"),
                   W.MB_ICONEXCLAMATION + W.MB_APPLMODAL) = 0 THEN END;
END ShowMsg;


(** The symbolic name of an objects qualified class name and the name of its 
    code module are returned. *)
PROCEDURE ObjToName*(
  p: Object;          (** pointer to the object whose symbolic name should be determined *)
  VAR codeName,       (** returns the full pathname of the .EXE or .DLL file containing the code of the class implementation *)
  name: ARRAY OF CHAR (** returns the qualified class name of the object in the form moduleName.typeName *)
);

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


PROCEDURE Halt*(modDescrP:SYSTEM.PTR; lineHaltCode:LONGINT);

  CONST
    title1 = "Oberon-2 Run Time Error";
    title2 = "HALT";
    title3 = "Error in RTS";
    title4 = "Error";
  
  VAR
    haltNum:  INTEGER;
    lineNum:  INTEGER; 
    modDescr: ModuleDescriptorP;
    msg:      ARRAY 200 OF CHAR;
    title:    ARRAY 30 OF CHAR;

BEGIN
  
  SYSTEM.GET(SYSTEM.ADR(lineHaltCode)+2,lineNum);
  SYSTEM.GET(SYSTEM.ADR(lineHaltCode),haltNum);
  modDescr:=SYSTEM.VAL(ModuleDescriptorP,modDescrP);
  
  (* -- build error message -- *)
  msg := "";
  IF haltNum >= MAX(INTEGER) - 10 THEN        (* Error in Run-Time-System *)
    title := title3;
    AppendStr(msg, title3); 
    AppendStr(msg, "detected: at line "); 
    AppendInt(msg, lineNum); 
    AppendStr(msg, " of module ");
  ELSE
    IF haltNum < 0 THEN                       (* Oberon-2 Run-Time-Error  *)
      title := title1;
      AppendStr(msg, title1);
    ELSIF haltNum=OUT_OF_MEM_HALT THEN
      title := title4;
      AppendStr(msg, title4);
    ELSE                                      (* HALT                     *)
      title := title2;
      AppendStr(msg, title2);
    END;
    AppendStr(msg, " at line ");
    AppendInt(msg, lineNum);
    AppendStr(msg, " of module ");
  END;
  AppendStr(msg, modDescr.moduleName^); AppendLn(msg);
  IF    haltNum= -1 THEN AppendStr(msg, "value out of range")
  ELSIF haltNum= -2 THEN AppendStr(msg, "index out of range")
  ELSIF haltNum= -3 THEN AppendStr(msg, "arithmetic overflow")
  ELSIF haltNum= -4 THEN AppendStr(msg, "wrong dynamic type")
  ELSIF haltNum= -5 THEN AppendStr(msg, "wrong module version")
  ELSIF haltNum= -6 THEN AppendStr(msg, "wrong definition file (INIT in EXPORTS)")
  ELSIF haltNum= -7 THEN AppendStr(msg, "WITH trap (no ELSE included)")
  ELSIF haltNum= -8 THEN AppendStr(msg, "CASE trap (no ELSE included)")
  ELSIF haltNum= -9 THEN AppendStr(msg, "no result returned")
  ELSIF haltNum=-10 THEN AppendStr(msg, "ASSERT fault")
  ELSIF haltNum=-11 THEN AppendStr(msg, "referenced pointer is nil (assignments can also cause pointer dereferencing because of type checks)");
  ELSIF haltNum=OUT_OF_MEM_HALT THEN AppendStr(msg, "memory allocation failed");
  ELSE
    AppendStr(msg, "HALT("); AppendInt(msg, haltNum); AppendStr(msg, ")")
  END;
  AppendLn(msg);

  (* -- display halt message box -- *)
  IF haltNum = 0 THEN
    IF W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR(title), W.MB_RETRYCANCEL + W.MB_ICONEXCLAMATION + W.MB_TASKMODAL) # W.IDRETRY THEN 
      W.ExitProcess(0);
    END
  ELSE
    IF W.MessageBoxA(0, SYSTEM.ADR(msg), SYSTEM.ADR(title), W.MB_OK + W.MB_ICONEXCLAMATION + W.MB_TASKMODAL) # 0 THEN END;
    W.ExitProcess(0);
  END
  
END Halt;


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

PROCEDURE GetTypeSize*(typetag: LONGINT; VAR size: LONGINT);
BEGIN
  SYSTEM.GET(typetag - 4, size);
END GetTypeSize;

PROCEDURE GetTypeName*(typetag: LONGINT; VAR name: ARRAY OF CHAR);
  VAR np: POINTER TO ARRAY 32 OF CHAR;
BEGIN
  SYSTEM.GET(typetag - 8, np);
  COPY(np^, name);
END GetTypeName;

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
 * AllocateMemory allocates a block of memory. It allocates eight extra bytes
 * for the unique ID and the typetag at the beginning.
 ***************************************************************************)
PROCEDURE AllocateMemory(typetag, size: LONGINT; init: BOOLEAN; VAR adr: LONGINT);

  VAR 
    hMem: W.HGLOBAL;
      
BEGIN

  (* -- init -- *)
  adr := 0;

  (* -- allocate block -- *)
  IF ~memAllocated THEN
    hMem := W.GlobalAlloc(W.GMEM_FIXED + W.GMEM_ZEROINIT, MEMFIRSTBLOCKSIZE);
    IF hMem # 0 THEN
      memBlock := W.GlobalLock(hMem);
      memSize := MEMFIRSTBLOCKSIZE;
      memUsed := 0;
      memAllocated := TRUE;
    END;
  END;
  
  (* -- allocate memory -- *)
  IF memAllocated THEN
    INC(size, BLOCKINFOSIZE);      (* extra memory for typetag and unique id *)
    INC(size, (-size) MOD 4);      (* alignment *)

    IF memUsed + size > memSize THEN    (* try to reallocate *)
      hMem := W.GlobalHandle(memBlock); (* get handle of the block *)
      IF hMem # 0 THEN
        hMem := W.GlobalReAlloc(hMem, memSize + MEMNEXTBLOCKSIZE, W.GMEM_NOCOMPACT + W.GMEM_ZEROINIT);
        IF hMem # 0 THEN
          INC(memSize, MEMNEXTBLOCKSIZE);
        ELSE
          IF W.MessageBeep(-1) = 0 THEN END;
        END;
      END;
    END;

    IF memUsed + size <= memSize THEN  (* memory available ? *)
      adr := memBlock + memUsed;
      INC(memUsed, size);
      (* -- set typetag and UID -- *)
      INC(adr, BLOCKINFOSIZE);
      SetObjType(adr, typetag);
      INC(currentID);
      SetObjUID(adr, currentID);
    ELSE
      adr := 0; (* Error: Not enough memory available *)
      HALT(OUT_OF_MEM_HALT);
    END;
  ELSE
    adr := 0; (* Error: Could not allocate block *)
    HALT(OUT_OF_MEM_HALT);
  END;

END AllocateMemory;


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
END Dispose;


PROCEDURE Mark*();
BEGIN
  memMark := memUsed;
END Mark;


PROCEDURE Release*();
  VAR i: LONGINT; 
BEGIN
  IF memMark >= 0 THEN
    (* -- Speicher initialisieren -- *)
    FOR i := memMark + memBlock TO memUsed + memBlock DO SYSTEM.PUT(i, 0); END;
    memUsed := memMark;
  END;
END Release;


PROCEDURE InitModule*(mda: LONGINT);
VAR mdp: ModuleDescriptorP;
BEGIN
  mdp := SYSTEM.VAL(ModuleDescriptorP, mda);
  moduleList[moduleN] := mdp; 
  INC(moduleN); 
END InitModule;


PROCEDURE LeavingWinMain*;
VAR
BEGIN
END LeavingWinMain;


PROCEDURE GetSize*(object: LONGINT; VAR size: LONGINT);
VAR hMem: W.HGLOBAL;
BEGIN
  size := 0; (* Initialisierung *)
  hMem := W.GlobalHandle(object - BLOCKINFOSIZE);
  IF hMem # 0 THEN
    size := W.GlobalSize(hMem);
    DEC(size, BLOCKINFOSIZE);
  END;
END GetSize;


PROCEDURE GetModuleName*(mdp: ModuleDescriptorP; VAR name: ARRAY OF CHAR);
VAR
BEGIN
  COPY(mdp^.moduleName^, name);
END GetModuleName;


BEGIN
  moduleN      := 0;
  currentID    := 0;
  memAllocated := FALSE;
  memMark      := -1;
END RTSOberon.

