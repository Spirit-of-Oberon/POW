(******************************************************************************)
(*                                                                            *)
(**)                        MODULE WriteObj;                                (**)
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
(* PURPOSE: write code to object file                                         *)
(*                                                                            *)
(******************************************************************************)

IMPORT OPM,OPT,OPL,E:=Error,Coff,Debug,DebugInfo;

CONST
  ALIGNMENT=4;
    CONSTBEGIN = 2 * OPM.MaxIdLen;(* module name, compiler version and module *)
                                  (*   key at beginning of const field        *)
                                  
    translatorName = "Oberon-2 for Windows, Robinson Associates";

    (* item modes for 80386 (must not overlap item basemodes,  > 15)          *)
    DArr = OPL.DArr; 
    Coc = OPL.Coc; 
    Stk = OPL.Stk; 

    (* item base modes (=object modes)                                        *)
    Var* = 1; VarPar* = 2; Con* = 3; LProc* = 6; XProc* = 7; CProc* = 9; IProc* = 10;
    TProc* = 13; WProc* = 14; 
    MODE_CDECLPROC*=OPT.MODE_CDECLPROC;

    (* structure forms                                                        *)
    Undef* = 0; Byte* = 1; Bool* = 2; Char* = 3; SInt* = 4; Int* = 5; LInt* = 6;
    Real* = 7; LReal* = 8; Set* = 9; String* = 10; NilTyp* = 11; NoTyp* = 12;
    Pointer* = 13; ProcTyp* = 14; Comp* = 15;
    intSet* = {SInt..LInt}; realSet* = {Real, LReal};
  
    (* composite structure forms                                              *)
    Basic* = 1; Array* = 2; DynArr* = 3; Record* = 4;
    
    (* fixup types                                                            *)
    FIXUP_CODE=OPL.FIXUP_CODE;
    FIXUP_MOD_DESC_OFF=OPL.FIXUP_MOD_DESC_OFF;
    CFIXUP_DATA=OPL.CFIXUP_DATA;

    (* module visibility of objects *)
    internal* = 0; internalR* = 1; external* = 2; externalR* = 3; (*!*)

VAR
    typCount, nameCount, extCount, segCount, grpCount: INTEGER;

(*----------------------------------------------------------------------------*)

  PROCEDURE Err(code:INTEGER);
  (* function:      generate an error message                               *)
  (* precondition:  n is the error number                                   *)
  (* postcondition: error message has been written to file                  *)
  BEGIN
    OPM.Err(code)
  END Err;
  

(*----------------------------------------------------------------------------*)
  PROCEDURE DefineImport*(obj: OPT.Object);
    (* function:      marks an imported procedure. This is used to write      *)
    (*                fixup commands into the object file                     *)
    (* precondition:  obj^.marked = TRUE, obj^.mnolev <= 0                    *)
    (*                obj^.mode IN {XProc, IProc, WProc, CDeclProc }          *)
    (* postcondition: obj^.symTableInx = index in symbol table of object file *)
  VAR
    symTableInx:LONGINT;
  BEGIN
    IF obj^.symTableInx=-1 THEN
      Coff.AddImportedProc(obj,symTableInx);
      obj^.symTableInx:=symTableInx;
    END;
  END DefineImport;

(*----------------------------------------------------------------------------*)
  PROCEDURE DefineExport*(obj: OPT.Object;
                          offset:LONGINT; (* start of procedure code *)
                          codeSize:LONGINT; 
                          firstLine:INTEGER;
                          lastLine:INTEGER;
                          lineNumInx:INTEGER;       (* index of first line number record for the procedure *)
                          nofLineRecs:INTEGER
                          );
    (* function:      marks an exported procedure. This is used to write      *)
    (*                the entry points of this procedures into the object file*)
    (* precondition:  obj^.marked = TRUE, obj^.mnolev =0                      *)
    (*                obj^.mode IN {XProc, IProc, WProc, CDeclProc }          *)
  VAR
    symTableInx:LONGINT;
  BEGIN
    IF ~OPM.addDebugInfo THEN lineNumInx:=0 END;
    IF obj=NIL THEN (* module body *)
      Coff.AddExportedProc(NIL,offset,codeSize,firstLine,lastLine,lineNumInx,symTableInx,nofLineRecs);
    ELSIF obj^.symTableInx=-1 THEN
      Coff.AddExportedProc(obj,offset,codeSize,firstLine,lastLine,lineNumInx,symTableInx,nofLineRecs);
      obj^.symTableInx:=symTableInx;
      (* a call to AddExportedProc is not necessary because it
         is called for all defined procedures anyway *)
      IF (obj^.vis >= external) & (obj^.mnolev = 0) & 
         (obj^.mode = XProc) & (obj^.link = NIL) & (obj^.typ = OPT.notyp) THEN
        (* command = parameterless exported procedure                           *)
        NEW(OPL.lastCom^.next);
        OPL.lastCom:=OPL.lastCom^.next;
        OPL.lastCom^.next:=NIL;
        OPL.lastCom^.obj:=obj;
        INC(OPL.nofComm)
      END
    END;
  END DefineExport;

(*----------------------------------------------------------------------------*)
  PROCEDURE DefineLocalProc*(obj: OPT.Object;
                          offset:LONGINT; (* start of procedure code *)
                          codeSize:LONGINT; 
                          firstLine:INTEGER;
                          lastLine:INTEGER;
                          lineNumInx:INTEGER;       (* index of first line number record for the procedure *)
                          nofLineRecs:INTEGER
                          );
    (* function:      marks a local procedure. This is used to write      *)
    (*                the line number information of this procedure into the object file*)
    (* precondition:  obj^.marked = TRUE, obj^.mnolev =0                      *)
    (*                obj^.mode IN {XProc, IProc, WProc, CDeclProc }          *)
  VAR
    symTableInx:LONGINT;
  BEGIN
    IF obj^.symTableInx=-1 THEN
      Coff.AddLocalProc(obj,offset,codeSize,firstLine,lastLine,lineNumInx,symTableInx,nofLineRecs);
      obj^.symTableInx:=symTableInx;
    END;
  END DefineLocalProc;

(*----------------------------------------------------------------------------*)
(*                G E N E R A T I O N   O F   O B J - F I L E                 *)
(*----------------------------------------------------------------------------*)

PROCEDURE WriteFixups;
  (* function:      write fixup information for the constant and code       *)
  (*                sections to the object file                             *)
  (* postcondition: fixup informations are in object file                   *)
VAR 
  type:INTEGER;
  i:LONGINT;
BEGIN
  Coff.StartCodeRelocs; (* write relocations for code area *)
  FOR i:=0 TO OPL.nofFixup-1 DO
    type:=OPL.fixupPtr^[i].typ;
    IF type#CFIXUP_DATA THEN
      Coff.WriteReloc(OPL.fixupPtr^[i].pc,OPL.fixupPtr^[i].inx,type);
    END;
  END;
  Coff.EndCodeRelocs;
  Coff.StartConstRelocs; (* write relocations for initialized data *)
  FOR i:=0 TO OPL.nofFixup-1 DO
    type:=OPL.fixupPtr^[i].typ;
    IF type=CFIXUP_DATA THEN
      Coff.WriteReloc(OPL.fixupPtr^[i].pc,OPL.fixupPtr^[i].inx,Coff.IMAGE_REL_I386_DIR32);
    END;
  END;
  Coff.EndConstRelocs;
  OPL.ResetFixups;
END WriteFixups;

PROCEDURE WriteDebugFixups;
  (* function:      write fixup information for the debug                   *)
  (*                sections to the object file                             *)
  (* precondition: code and constants fixups have been written before debug *)
  (*               fixups were generated                                    *)
  (* postcondition: fixup informations are in object file                   *)
VAR
  i:LONGINT;
BEGIN
  Coff.StartDebugRelocs;
  FOR i:=0 TO OPL.nofFixup-1 DO
    Coff.WriteReloc(OPL.fixupPtr^[i].pc,OPL.fixupPtr^[i].inx,OPL.fixupPtr^[i].typ);
  END;
  Coff.EndDebugRelocs;
END WriteDebugFixups;

(*----------------------------------------------------------------------------*)

PROCEDURE OutCode*(VAR modName: OPM.Name; key: LONGINT);
  (* function:      write generated code to object file                     *)
  (* precondition:  modName = module name                                   *)
  (*                key = key-value of symbol file                          *)

CONST
  gsSegName = "$GlobalData";
  rtsBodyName = Coff.MODULE_BODY_NAME;

VAR
  emptyLNInx, dgroupLNInx, modCodeLNInx, codeLNInx, modDataLNInx, dataLNInx,
  modBssLNInx, bssLNInx, codeSegInx, dataSegInx, bssSegInx, dgroupGrpInx,
  inx, i, fixupBegin, fixupEnd: INTEGER;
  begin, end, loc, 
  commTab:LONGINT; (* offset of command list in module descriptor *)
  typDescTab: LONGINT; (* offset of type desc. list *)
  defModule: BOOLEAN;
  str: ARRAY 2 * OPM.MaxIdLen + 2 OF CHAR;
  obj: OPT.Object;
  gsInx: ARRAY OPT.MAXIMPS + 1 OF INTEGER;


(*!L+*)
  PROCEDURE MaxNofStat():LONGINT;
    VAR i, d, h: LONGINT;
  BEGIN h:=0;
    FOR i:=0 TO 3 DO d:=OPM.data1[i];
      IF (d < 0) OR (32 <= d) THEN d:=0; RETURN -1 ELSE h:=h * 32 + d END;
    END; d:=0;
    IF h < 50 THEN RETURN (h DIV 9) * 100 + 10 ELSE RETURN MAX(LONGINT) END;
  END MaxNofStat;

(*!L-*)
  (* RTTI+ *)
  PROCEDURE Traverse(obj: OPT.Object);
  BEGIN
    IF obj # NIL THEN
      Traverse(obj^.left);
      IF obj^.mode = Var THEN 
        OPL.BuildRTTI(obj^.typ, obj^.adr, obj^.name, FALSE,
                      OPL.entryNameTab,OPL.nofNameTab,
                      OPL.entryTypeTab,OPL.nofTypeTab);
      END;
      Traverse(obj^.right)
    END
  END Traverse;
  (* RTTI- *)

 PROCEDURE WriteModuleDescriptor;
  VAR
    h:LONGINT;
    modNameOff:LONGINT;
    hh:PROCEDURE (x:LONGINT);
  BEGIN
    modNameOff:=OPL.constLen;
    OPL.PutConstName(OPM.moduleName);
       (* begin of module descriptor         *)
    WHILE (OPL.constLen MOD  4) # 0 DO OPL.PutConstC(0X) END;
    commTab:=OPL.constLen;           (* list of commands                   *)
    OPL.PutConstD(0);
    OPL.PutConstD(0);
    OPL.PutConstD(OPL.nofComm - 1);
    OPL.lastCom:=OPL.comList^.next;
    WHILE OPL.lastCom # NIL DO
      OPL.PutConstD(0);
      OPL.DefineFixup(CFIXUP_DATA, OPL.lastCom^.obj^.symTableInx, OPL.constLen - 4); 
      OPL.PutConstName(OPL.lastCom^.obj^.name);
      OPL.lastCom:=OPL.lastCom^.next;
    END;
    
    typDescTab:=OPL.constLen;        (* list of type descriptors           *)
    OPL.PutConstD(0);
    OPL.PutConstD(0);
    OPL.PutConstD(OPL.nofTypDesc - 1);
    OPL.lastTypDesc:=OPL.typDescList^.next;
    WHILE OPL.lastTypDesc # NIL DO
      OPL.PutConstD(OPL.lastTypDesc^.str^.tdadr);
      OPL.DefineFixup(CFIXUP_DATA, Coff.symInxConst, OPL.constLen - 4); (* type descriptor now in constant area *)
      OPL.lastTypDesc:=OPL.lastTypDesc^.next;
    END;
    (* RTTI+ *)
    OPL.nofNameTab:=0;
    OPL.nofTypeTab:=0;
    Traverse(OPT.topScope^.right);    (* build global variable type info table  *)
    hh:=OPL.PutConstW;
    OPL.PutRTTI(OPL.PutConstW,OPL.PutConstC,OPL.entryNameTab,OPL.nofNameTab,OPL.entryTypeTab,OPL.nofTypeTab);
    OPL.PutConstD(0);                            (* 4 bytes in const area reserved for GC *)
    (* RTTI- *)

    OPL.FixLinkValue(-OPL.modDescLabel,OPL.constLen); (* internal fixup for pointer to module descriptor *)
    
      (* module descriptor table as seen in memory at run time           *)
    OPL.PutConstD(modNameOff);                            (* pointer to module name    *)
    OPL.DefineFixup(CFIXUP_DATA, Coff.symInxConst, OPL.constLen - 4);
    OPL.PutConstD(OPL.dsize);                        (* size of global data section *)
    OPL.PutConstD(0);                                (* pointer to global data section *)
    OPL.DefineFixup(CFIXUP_DATA, Coff.symInxData, OPL.constLen - 4);
    OPL.PutConstD(typDescTab);                   (* pointer to list of type descriptors*)    
    OPL.DefineFixup(CFIXUP_DATA, Coff.symInxConst, OPL.constLen - 4);
    OPL.PutConstD(commTab);                      (* pointer to list of commands        *)
    OPL.DefineFixup(CFIXUP_DATA, Coff.symInxConst, OPL.constLen - 4);
                                        (* end of module descriptor           *)
    (* alignement to paragraph boundaries                                     *)
    WHILE (OPL.constLen MOD  16) # 0 DO OPL.PutConstC(0X) END;
  END WriteModuleDescriptor;

  PROCEDURE Align;
  BEGIN
    WHILE Coff.globObjLen MOD ALIGNMENT#0 DO Coff.WriteObjByte(0) END;
  END Align;

BEGIN                                 

  (* Step 1: add some tables to constant area                   *)
  
  defModule:=OPT.defModule;

  begin:=OPL.constLen;                  (* module name and version number     *)
  OPL.constLen:=0;
  OPL.PutConstName(modName);
  OPL.PutConstName(OPM.version);
  DEC(OPL.constLen, 4);
(*!L+*)
  IF OPM.Check1() OR (OPL.nofStat > MaxNofStat()) THEN 
    defModule:=TRUE
  ELSE 
    DEC(OPL.constLen, 8); 
    FOR i:=0 TO 3 DO OPL.PutConstW(OPM.data2[i]) END
  END;
(*!L-*)
  OPL.PutConstD(key);   (* module key ? *)
  IF CONSTBEGIN # OPL.constLen THEN OPM.CommentedErr(E.INTERNAL_MURKS,"OutCode") END;
  OPL.constLen:=begin;

  IF defModule THEN
    OPL.pc:=OPL.modBodyEnd;
    OPL.importList^.next:=NIL; 
    OPL.lastImport:=OPL.importList; 
    OPL.nofImport:=0;
    OPL.comList^.next:=NIL; 
    OPL.lastCom:=OPL.comList; 
    OPL.nofComm:=0;
  END;

  WriteModuleDescriptor;

  (* Step 2: generate object file                      *)

  Coff.OpenObjFile(modName);
  Coff.WriteCoffHeader(modName,                      (* name of module *)
                       OPL.pc,                       (* total code size *)
                       OPL.constLen,                 (* total constant area size *)
                       OPL.dsize,                    (* global data size *)
                       0);                           (* size of common data area *)
  
  Align;
  Coff.WriteConst(OPL.constPtr^,OPL.constLen);
  Align;
  Coff.WriteCode(OPL.code,OPL.pc);

  WriteFixups;
  IF OPM.addSymDebugInfo THEN 
    Align;
    DebugInfo.Write;
    Align;
    WriteDebugFixups;
  END;
  Align;
  Coff.WriteLineNumberTable; (* needs to be called even if there should not be debug info in the object file *)
  Align;
  Coff.WriteSymbolTable;
  Coff.WriteStringTable; (* the string table must follow right after the symbol table *)
  Coff.CloseObjFile;
END OutCode;

(*============================================================================*)

PROCEDURE Init*(debugInfo: BOOLEAN);
    (* function:      initializes the global variables of this module         *)
BEGIN
  OPL.Init(debugInfo);
  WHILE OPL.constLen < CONSTBEGIN DO OPL.PutConstC(0X) END;
  OPL.floatContrWord:=OPL.constLen;
  OPL.PutConstW(OPM.FPU_CONTROL_WORD); (* control word for 80387   *)
  typCount:=0;
  nameCount:=0; 
  extCount:=0; 
  segCount:=0; 
  grpCount:=0;
END Init;

END WriteObj.
