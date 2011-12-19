(******************************************************************************)
(*                                                                            *)
(**)                        MODULE Coff;                                    (**)
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
(* AUTHORS: Bernhard Leisch                                                   *)
(******************************************************************************)
(* PURPOSE:  COFF Support                                                     *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*   This module provides functions to support the creation of files          *)
(*   in COFF format.                                                          *)
(******************************************************************************)


(*
  file layout:

    COFF Header
    
    Section Table
      code section
      constants section=initialized data
      data section
      virtual register section
      
    Code
      code image
      relocations
      line number information
    
    Constants
    
    Symbol Table
    
    String Table
*)

IMPORT SYSTEM,OPM,String,E:=Error,Debug,OPT;

CONST
  MAX_NOFSECTIONS=6;
  SCTNNAME_CODE        = "_$Code";
  SHORT_SCTNNAME_CODE  = ".text";
  SCTNNAME_DATA        = "_$Data";
  SHORT_SCTNNAME_DATA  = ".bss";
  SCTNNAME_CONST       = "_$Const";
  SHORT_SCTNNAME_CONST = ".data";
  MODULE_BODY_NAME*    = "$Init";
  SCTNNAME_DEBUGTYPES  = ".debug$T";
  SCTNNAME_DEBUGSYMBOLS= ".debug$S";
  RTS_MODULE_NAME      = "RTSOberon";
  
  MAXFILEFIXUPS=100; (* maximum number of places in the object file which need to be patched with
                        a file location later *)
  maxObjLen = 32767;
  MAXSTRINGTABLE=32000;
  MAXLINENUMS=5000; (* maximum number of line number records per module *)
  
  IMAGE_FILE_MACHINE_I386 = 14CH;
  IMAGE_FILE_BYTES_REVERSED_HI=MIN(INTEGER);

  IMAGE_SCN_TYPE_NO_PAD*=            8H;  (*  Reserved. *)
  IMAGE_SCN_CNT_CODE*=              20H;  (*  Section contains code. *)
  IMAGE_SCN_CNT_INITIALIZED_DATA*=  40H;  (*  Section contains initialized data. *)
  IMAGE_SCN_CNT_UNINITIALIZED_DATA*=80H;  (*  Section contains uninitialized data. *)
  IMAGE_SCN_LNK_OTHER*=            100H;  (*  Reserved. *)
  IMAGE_SCN_LNK_INFO*=             200H;  (*  Section contains comments or some other type of information. *)
  IMAGE_SCN_LNK_REMOVE*=           800H;  (*  Section contents will not become part of image. *)
  IMAGE_SCN_LNK_COMDAT*=          1000H;  (*  Section contents comdat. *)
  IMAGE_SCN_ALIGN_1BYTES*=      100000H;  (*  *)
  IMAGE_SCN_ALIGN_2BYTES*=      200000H;  (*  *)
  IMAGE_SCN_ALIGN_4BYTES*=      300000H;  (*  *)
  IMAGE_SCN_ALIGN_8BYTES*=      400000H;  (*  *)
  IMAGE_SCN_ALIGN_16BYTES*=     500000H;  (*  Default alignment if no others are specified. *)
  IMAGE_SCN_ALIGN_32BYTES*=     600000H;  (*  *)
  IMAGE_SCN_ALIGN_64BYTES*=     700000H;  (*  *)
  IMAGE_SCN_LNK_NRELOC_OVFL*=  1000000H;  (*  Section contains extended relocations. *)
  IMAGE_SCN_MEM_FARDATA*=         8000H;
  IMAGE_SCN_MEM_PURGEABLE*=      20000H;
  IMAGE_SCN_MEM_16BIT*=          20000H;
  IMAGE_SCN_MEM_LOCKED*=         40000H;
  IMAGE_SCN_MEM_PRELOAD*=        80000H;
  IMAGE_SCN_MEM_DISCARDABLE*=  2000000H;  (*  Section can be discarded. *)
  IMAGE_SCN_MEM_NOT_CACHED*=   4000000H;  (*  Section is not cachable. *)
  IMAGE_SCN_MEM_NOT_PAGED*=    8000000H;  (*  Section is not pageable. *)
  IMAGE_SCN_MEM_SHARED*=      10000000H;  (*  Section is shareable. *)
  IMAGE_SCN_MEM_EXECUTE*=     20000000H;  (*  Section is executable. *)
  IMAGE_SCN_MEM_READ*=        40000000H;  (*  Section is readable. *)
  IMAGE_SCN_MEM_WRITE*=    MIN(LONGINT);  (*  Section is writeable. *)

  SECTION_HEADER_SIZE=40; (* size of an entry in the section table in bytes *)
  HEADER_SIZE=20; (* size of the coff header in bytes *)

  IMAGE_SYM_CLASS_END_OF_FUNCTION*=255;
  IMAGE_SYM_CLASS_NULL*=0;
  IMAGE_SYM_CLASS_AUTOMATIC*=1;
  IMAGE_SYM_CLASS_EXTERNAL*=2;
  IMAGE_SYM_CLASS_STATIC*=3;
  IMAGE_SYM_CLASS_REGISTER*=4;
  IMAGE_SYM_CLASS_EXTERNAL_DEF*=5;
  IMAGE_SYM_CLASS_LABEL*=6;
  IMAGE_SYM_CLASS_UNDEFINED_LABEL*=7;
  IMAGE_SYM_CLASS_MEMBER_OF_STRUCT*=8;
  IMAGE_SYM_CLASS_ARGUMENT*=9;
  IMAGE_SYM_CLASS_STRUCT_TAG*=10;
  IMAGE_SYM_CLASS_MEMBER_OF_UNION*=11;
  IMAGE_SYM_CLASS_UNION_TAG*=12;
  IMAGE_SYM_CLASS_TYPE_DEFINITION*=13;
  IMAGE_SYM_CLASS_UNDEFINED_STATIC*=14;
  IMAGE_SYM_CLASS_ENUM_TAG*=15;
  IMAGE_SYM_CLASS_MEMBER_OF_ENUM*=16;
  IMAGE_SYM_CLASS_REGISTER_PARAM*=17;
  IMAGE_SYM_CLASS_BIT_FIELD*=18;
  IMAGE_SYM_CLASS_BLOCK*=100;
  IMAGE_SYM_CLASS_FUNCTION*=101;
  IMAGE_SYM_CLASS_END_OF_STRUCT*=102;
  IMAGE_SYM_CLASS_FILE*=103;
  IMAGE_SYM_CLASS_SECTION*=104;
  IMAGE_SYM_CLASS_WEAK_EXTERNAL*=105;

  IMAGE_SYM_DEBUG*=-2;    (* special values for section references in the symbol table *)
  IMAGE_SYM_ABSOLUTE*=-1;
  IMAGE_SYM_UNDEFINED*=0;

  IMAGE_REL_I386_ABSOLUTE*=0;
  IMAGE_REL_I386_DIR*=1;
  IMAGE_REL_I386_REL16*=2;
  IMAGE_REL_I386_DIR32*=6;
  IMAGE_REL_I386_DIR32NB*=7;
  IMAGE_REL_I386_SEG12*=9;
  IMAGE_REL_I386_SECTION*=0AH;
  IMAGE_REL_I386_SECREL*=0BH;
  IMAGE_REL_I386_REL32*=014H;

  IMAGE_COMDAT_SELECT_NODUPLICATES=1;
  IMAGE_COMDAT_SELECT_ANY=2;
  IMAGE_COMDAT_SELECT_SAME_SIZE=3;
  
  LProc = OPT.LProc;
  XProc = OPT.XProc;
  SProc = OPT.SProc;
  CProc = OPT.CProc;
  IProc = OPT.IProc;
  TProc = OPT.TProc;
  WProc = OPT.WProc;
  MODE_CDECLPROC=OPT.MODE_CDECLPROC;

  IMPORTED_SYM_CLASS=IMAGE_SYM_CLASS_EXTERNAL; (* symbol class used for all symbol implemented by other modules *)

TYPE
  SymbolTableRecordT=RECORD
    name:ARRAY OPM.MaxIdLen+1 OF CHAR;
    value:LONGINT;
    section:INTEGER;
    type:INTEGER;
    storageClass:CHAR;
    nrOfAuxSymbols:SHORTINT;
  END;
  SymbolListEle=POINTER TO SymbolListEleT;
  SymbolListEleT=RECORD
    obj:OPT.Object;
    next:SymbolListEle;
  END;
  
  (* because COFF line number information also relies on procedure symbols all Oberon procedures
  generate symbol table entries whether they are exported or not
  If obj is NIL, obj designates the current module *)
  SymbolExportedProcT=RECORD (SymbolListEleT)
    offset:LONGINT; (* start of procedure code *)
    codeSize:LONGINT;
    firstLine,                       
    lastLine,
    nofLineRecs:INTEGER;
    lineNumInx:LONGINT; (* before line number info is written index into table in memory; after that file pointer *)
    symTableInx:LONGINT;
  END;
  SymbolExportedProc=POINTER TO SymbolExportedProcT;

  SymbolLocalProcT=RECORD (SymbolExportedProcT)
  END;
  SymbolLocalProc=POINTER TO SymbolLocalProcT;

  SymbolImportedProcT=RECORD (SymbolListEleT)
  END;
  SymbolImportedProc=POINTER TO SymbolImportedProcT;

  SymbolImportedDataT=RECORD (SymbolListEleT)
  END;
  SymbolImportedData=POINTER TO SymbolImportedDataT;

  SymbolRtsProcT=RECORD (SymbolListEleT)
    name:ARRAY OPM.MaxIdLen OF CHAR;
  END;
  SymbolRtsProc=POINTER TO SymbolRtsProcT;

  LineNumEntryT=RECORD
    offset:LONGINT; (* if line=0 index into symbol table; else relative virtual code address *)
    line:INTEGER;
    symbol:SymbolExportedProc; (* NIL or pointer to symbol if procedure start *)
  END;
  

VAR
  nofSections:INTEGER; (* number of sections *)                           
  minResEntries:INTEGER; (* minimum number of entries in symbol table before procedure definitions, has to be >0 *)
  objBuf: ARRAY maxObjLen OF CHAR; 
  objLen:LONGINT; (* current position in objBuf *)
  globObjLen-:LONGINT; (* current position in object file from beginning of file *)
  stringTable:ARRAY MAXSTRINGTABLE+1 OF CHAR;
  stringLen:LONGINT;
  symTableFixup:LONGINT; (* position of pointer to symbol table in object file *)
  symbolList:SymbolListEle; (* head of linked list of symbols for the symbol table *)
  lastSymbol:SymbolListEle; (* last element of symbolList *)
  symTableInx:LONGINT; (* later index into the symbol table of the next element put into the symbol list *)
  lineNums:POINTER TO ARRAY MAXLINENUMS OF LineNumEntryT;
  nLineNums:INTEGER;
  nSymbols:LONGINT; (* the number of records and auxiliary records in the symbol table *)
  resEntries:INTEGER; (* number of entries in symbol table before procedure definitions, has to be >0 *)
  codeFixup:LONGINT;
  constFixup:LONGINT;
  debugTypesFixup-:LONGINT;
  debugSymbolsFixup-:LONGINT;
  relocsStart:LONGINT;
  relocsN:INTEGER;
  testNofSections:INTEGER; (* check counter for number of sections *)
  sctnInxCode:INTEGER; (* one based section table index of code section, valid after call to Init *)
  sctnInxData:INTEGER; (* one based section table index of data section, valid after call to Init  *)
  sctnInxConst:INTEGER; (* one based section table index of initialized data section, valid after call to Init  *)
  sctnInxDebugT:INTEGER; (* one based section table index of debug types section, valid after call to Init  *)
  sctnInxDebugS:INTEGER; (* one based section table index of debug symbols data section, valid after call to Init  *)
  symInxCode-:INTEGER; (* zero based symbol table index of code section, valid after call to Init *)
  symInxData-:INTEGER; (* zero based symbol table index of data section, valid after call to Init  *)
  symInxConst-:INTEGER; (* zero based symbol table index of initialized data section, valid after call to Init  *)
  symInxDebugT-:INTEGER;
  symInxDebugS-:INTEGER;
  sctnList:ARRAY MAX_NOFSECTIONS OF RECORD
                                length:LONGINT;
                                nofRelocs:INTEGER;
                                nofLines:INTEGER;
                              END;
  sctnNameData:ARRAY OPM.MaxIdLen+10 OF CHAR;
  sctnNameConst:ARRAY OPM.MaxIdLen+10 OF CHAR;
  sctnNameCode:ARRAY OPM.MaxIdLen+10 OF CHAR;
  lastTrueLineNr:LONGINT; (* used to check for would-be identical entries in AddLineNum (during code generation) *)
  procLineNrs:INTEGER; (* total number of line number records for the current procedure (during code generation) *)
      
PROCEDURE Err(code:INTEGER);
VAR
BEGIN
  OPM.Err(code);
END Err;

PROCEDURE MakeSectionName(VAR modName-,extName-,result:ARRAY OF CHAR);
VAR
  i,j:LONGINT;
BEGIN
  i:=0;
  WHILE modName[i]#0X DO
    result[i]:=modName[i];
    INC(i);
  END;
  j:=0;
  WHILE extName[j]#0X DO
    result[i+j]:=extName[j];
    INC(j);
  END;
  result[i+j]:=0X;
END MakeSectionName;

(*============================ W R I T E   O B J E C T - F I L E =============*)

PROCEDURE WriteObjByte*(i: LONGINT);
(* this procedure must be the only one to write bytes in objBuf *)
BEGIN
  IF i < 0 THEN INC(i, 100H) END;
  objBuf[objLen] := CHR(i);
  INC(objLen);
  INC(globObjLen);
  IF objLen>=maxObjLen THEN
    OPM.WriteBytes(OPM.objFileNum, objBuf, objLen);
    objLen:=0;
  END;
END WriteObjByte;

(*----------------------------------------------------------------------------*)
PROCEDURE WriteObjBlock*(begin, end: LONGINT; VAR block: ARRAY OF CHAR);
  VAR i: LONGINT;
BEGIN
  i := begin;
  WHILE i <= end DO WriteObjByte(ORD(block[i])); INC(i) END;
END WriteObjBlock;

(*----------------------------------------------------------------------------*)
PROCEDURE WriteObjWord*(i: LONGINT);
BEGIN
  WriteObjByte(SHORT(i MOD  100H));
  WriteObjByte(SHORT(i DIV  100H));
END WriteObjWord;

(*----------------------------------------------------------------------------*)

PROCEDURE WriteObjLongint*(i: LONGINT);
BEGIN
  WriteObjByte(SHORT(i MOD  100H));
  i := i DIV  100H;
  WriteObjByte(SHORT(i MOD  100H));
  i := i DIV  100H;
  WriteObjByte(SHORT(i MOD  100H));
  WriteObjByte(SHORT(i DIV  100H)); 
END WriteObjLongint;
  
PROCEDURE WriteObjAlignment*;
(* This procedure zero pads the object file, so that after the call
  the file position is aligned on a 4 byte boundary *)
BEGIN
  WHILE (globObjLen MOD 4)#0 DO WriteObjByte(0) END;
END WriteObjAlignment;

PROCEDURE WriteDataBlock*(VAR data-:ARRAY OF CHAR; length:LONGINT);
(* write a block of data to the object file at the current position *)
VAR
  i:LONGINT;
BEGIN
  FOR i:=0 TO length-1 DO WriteObjByte(ORD(data[i])) END;
END WriteDataBlock;

PROCEDURE OpenObjFile*(VAR modName: OPM.Name);
VAR 
  res:INTEGER;
  txt:ARRAY 100 OF CHAR;
BEGIN
  OPM.CreateFile(OPM.objFileNum, modName, res); 
  objLen:=0;
  stringLen:=0;
  globObjLen:=0;
  testNofSections:=0;
  IF res#0 THEN 
    txt:="object file for module ";
    String.Append(txt,modName);
    OPM.CommentedErr(res,txt); 
  END;
  MakeSectionName(modName,SCTNNAME_CODE,sctnNameCode);
  MakeSectionName(modName,SCTNNAME_DATA,sctnNameData);
  MakeSectionName(modName,SCTNNAME_CONST,sctnNameConst);
END OpenObjFile;

PROCEDURE FlushWriteBuffer;
BEGIN
  IF objLen>0 THEN      
    OPM.WriteBytes(OPM.objFileNum, objBuf, objLen);
    objLen:=0;
  END;
END FlushWriteBuffer;

PROCEDURE WriteFixup*(atOffset:LONGINT; value:LONGINT);
BEGIN
  FlushWriteBuffer;
  OPM.SeekFile(OPM.objFileNum,atOffset);
  OPM.WriteBytes(OPM.objFileNum,value,4);
  OPM.SeekFile(OPM.objFileNum,globObjLen);
END WriteFixup;

PROCEDURE WriteFixupWord*(atOffset:LONGINT; value:LONGINT);
BEGIN
  FlushWriteBuffer;
  OPM.SeekFile(OPM.objFileNum,atOffset);
  OPM.WriteBytes(OPM.objFileNum,value,2);
  OPM.SeekFile(OPM.objFileNum,globObjLen);
END WriteFixupWord;

PROCEDURE CloseObjFile*;
BEGIN
  FlushWriteBuffer;
  OPM.CloseFile(OPM.objFileNum)
END CloseObjFile;

(* -----  string table management  -------------------------------- *)

PROCEDURE WriteStringTable*;
(* Write the entire string table to the object file *)
BEGIN
  WriteObjLongint(stringLen+4);
  WriteDataBlock(stringTable,stringLen);
END WriteStringTable;

PROCEDURE NewString*(VAR txt-:ARRAY OF CHAR; VAR offs:LONGINT);
(* Add a string to the string table *)
VAR
  i:LONGINT;
BEGIN
  offs:=stringLen+4;
  i:=0;
  WHILE (txt[i]#0X) & (stringLen<MAXSTRINGTABLE) DO
    stringTable[stringLen]:=txt[i];
    INC(i);
    INC(stringLen);
  END;
  IF txt[i]#0X THEN OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.NewString") END;
  stringTable[stringLen]:=0X;
  INC(stringLen);
END NewString;

PROCEDURE AlignedSize(x:LONGINT):LONGINT;
(* returns the smallest multiple of 4 bigger than x *)
BEGIN
  RETURN x+(-x) MOD 4;
END AlignedSize;

(*----------------------------------------------------------------------------*)
(* in .obj file: exp. Prozeduren
   in .sym file: exp. Konstanten und glob. Variablen und
                 typetag und Methoden *)

PROCEDURE WriteSectionHeader(name:ARRAY OF CHAR; (* section name *)
                             flags:LONGINT;      (* section contents flags (code,data,...) *)
                             lineN:LONGINT;  (* number of line number informations *)
                             dataSize:LONGINT; (* size of section data *)
                             VAR fixupHandle:LONGINT; (* handle for later fixing file ptrs *)
                             VAR sectionIndex:INTEGER (* one based index into section table *)
                             ); 
VAR
  sName:ARRAY 8 OF CHAR;
  offs,i:LONGINT;
BEGIN
  INC(testNofSections);
  sectionIndex:=testNofSections;
  i:=0; 
  WHILE (name[i]#0X) & (i<8) DO
    sName[i]:=name[i];
    INC(i);
  END;
  IF name[i]#0X THEN
    NewString(name,offs);
    FOR i:=0 TO 7 DO sName[i]:=0X END;
    String.Str(offs,sName);
    String.InsertChar("/",sName,1);
  ELSE
    WHILE i<8 DO sName[i]:=0X; INC(i) END;
  END;
  WriteDataBlock(sName,8);
  WriteObjLongint(0); (* 0 in obj files *)
  WriteObjLongint(0); (* 0 in obj files *)
  WriteObjLongint(dataSize); (* size of section data *)
  fixupHandle:=globObjLen;
  WriteObjLongint(0); (* offset of raw data in file *)
  WriteObjLongint(0); (* offset of relocations in file *)
  WriteObjLongint(0); (* offset of line number info in file *)
  WriteObjWord(0); (* number of relocations *)
  WriteObjWord(lineN); (* number of line numbers *)
  WriteObjLongint(flags); (* section flags *)
END WriteSectionHeader;

PROCEDURE WriteSectionAux(length:LONGINT; 
                          nofRelocs:INTEGER; 
                          nofLines:INTEGER; 
                          checkSum:LONGINT;
                          assocSectionTableInx:INTEGER;
                          comdatSlct:SHORTINT);
(* write the auxiliary record for a section definition in the symbol table *)
BEGIN
  INC(nSymbols);
  WriteObjLongint(length);
  WriteObjWord(nofRelocs);
  WriteObjWord(nofLines);
  WriteObjLongint(checkSum);
  WriteObjWord(assocSectionTableInx);
  WriteObjByte(comdatSlct); 
  WriteObjByte(0); (* reserved *)
  WriteObjWord(0); (* reserved *)
END WriteSectionAux;

PROCEDURE WriteCoffHeader*(VAR modName:ARRAY OF CHAR; (* name of module *)
                           codeSize,                  (* total code size *)
                           constSize,                 (* total constant area size *)
                           dataSize,                  (* size of global data *)
                           vRegSize:LONGINT);         (* size of common data area for virtual registers *)
(* Write COFF and section headers *)
VAR
  date:LONGINT;
  t:ARRAY 100 OF CHAR;
  start:LONGINT; (* address of first byte after header and section table *)
  fixupHandle:LONGINT;
  sinx:INTEGER;
  flags:LONGINT;
BEGIN
  WriteObjWord(IMAGE_FILE_MACHINE_I386);
  WriteObjWord(nofSections); (* number of sections *)
  start:=HEADER_SIZE+nofSections*SECTION_HEADER_SIZE;
  date:=0;
  WriteObjLongint(date); (* time / date stamp *)
  symTableFixup:=globObjLen;
  WriteObjLongint(-1); (* pointer to symbol table, needs to be fixed later *)
  WriteObjLongint(-1); (* number of symbol table entries plus definition for the ComDat section *)
  WriteObjWord(0); (* 0 in obj files *)
  WriteObjWord(IMAGE_FILE_BYTES_REVERSED_HI);

  flags:=IMAGE_SCN_CNT_CODE+IMAGE_SCN_MEM_EXECUTE+IMAGE_SCN_MEM_READ+IMAGE_SCN_ALIGN_16BYTES;
  IF OPM.codeWritable THEN flags:=flags+IMAGE_SCN_MEM_WRITE END;
  WriteSectionHeader(SHORT_SCTNNAME_CODE,flags,
                     nLineNums,
                     codeSize,
                     codeFixup,
                     sinx);
  IF sinx#sctnInxCode THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 1");
  END;
  sctnList[sinx-1].length:=codeSize;
                     
  WriteSectionHeader(SHORT_SCTNNAME_DATA,
                     IMAGE_SCN_CNT_UNINITIALIZED_DATA+
                     IMAGE_SCN_MEM_READ+
                     IMAGE_SCN_MEM_WRITE+
                     IMAGE_SCN_ALIGN_16BYTES,
                     0,
                     dataSize,
                     fixupHandle,
                     sinx);
  IF sinx#sctnInxData THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 2");
  END;
  sctnList[sinx-1].length:=dataSize;

  WriteSectionHeader(SHORT_SCTNNAME_CONST,
                     IMAGE_SCN_CNT_INITIALIZED_DATA+
                     IMAGE_SCN_MEM_READ+
                     IMAGE_SCN_MEM_WRITE+
                     IMAGE_SCN_ALIGN_16BYTES,
                     0,
                     constSize,
                     constFixup,
                     sinx);
  IF sinx#sctnInxConst THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 3");
  END;
  sctnList[sinx-1].length:=constSize;

  IF OPM.addSymDebugInfo THEN 
    WriteSectionHeader(SCTNNAME_DEBUGTYPES,
                       IMAGE_SCN_CNT_INITIALIZED_DATA+
                       IMAGE_SCN_MEM_READ+
                       IMAGE_SCN_MEM_DISCARDABLE+
                       IMAGE_SCN_TYPE_NO_PAD+
                       IMAGE_SCN_ALIGN_1BYTES,
                       0,
                       0,
                       debugTypesFixup,
                       sinx);
    IF sinx#sctnInxDebugT THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 5");
    END;
    sctnList[sinx-1].length:=constSize;
  
    WriteSectionHeader(SCTNNAME_DEBUGSYMBOLS,
                       IMAGE_SCN_CNT_INITIALIZED_DATA+
                       IMAGE_SCN_MEM_READ+
                       IMAGE_SCN_MEM_DISCARDABLE+
                       IMAGE_SCN_TYPE_NO_PAD+
                       IMAGE_SCN_ALIGN_1BYTES,
                       0,
                       0,
                       debugSymbolsFixup,
                       sinx);
    IF sinx#sctnInxDebugS THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 6");
    END;
    sctnList[sinx-1].length:=constSize;
  END;
  
  IF testNofSections#nofSections THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteCoffHeader 7");
  END;
END WriteCoffHeader;

PROCEDURE WriteSymbol*(VAR name-:ARRAY OF CHAR;
                       value:LONGINT;
                       sectionNr:INTEGER; (* one-based index into section table *)
                       type:INTEGER; (* use at least 20H (function) and 0H (not a function) *)
                       storageClass:INTEGER;
                       auxRecords:INTEGER);
(* write an entry into the symbol table *)
VAR
  i,nameLen:LONGINT;
BEGIN
  INC(nSymbols);
  nameLen:=String.Length(name);
  IF nameLen<=8 THEN
    FOR i:=0 TO nameLen-1 DO WriteObjByte(ORD(name[i])) END;
    FOR i:=nameLen TO 7 DO WriteObjByte(0) END;
  ELSE
    NewString(name,i);
    WriteObjLongint(0);
    WriteObjLongint(i);
  END;
  WriteObjLongint(value);
  WriteObjWord(sectionNr);
  WriteObjWord(type);
  WriteObjByte(storageClass);
  WriteObjByte(auxRecords);
END WriteSymbol;

PROCEDURE WriteSymbolAuxProc*(tagInx:LONGINT;
                              size:LONGINT;
                              lineNums:LONGINT;
                              nextFunction:LONGINT);
(* write auxiliary entry for a function definition into the symbol table *)
BEGIN
  INC(nSymbols);
  WriteObjLongint(tagInx);
  WriteObjLongint(size);
  WriteObjLongint(lineNums);
  WriteObjLongint(nextFunction);
  WriteObjWord(0);
END WriteSymbolAuxProc;

PROCEDURE WriteSymbolAuxFileName*(VAR fileName-:ARRAY OF CHAR);
(* write auxiliary entries into the symbol table defining the source file name;
   the number of entries written is (Length(fileName)+17) DIV 18 *)
VAR
  i,j:INTEGER;
BEGIN
  i:=0;
  WHILE fileName[i]#0X DO
    INC(nSymbols);
    j:=0;
    WHILE j<18 DO
      WriteObjByte(ORD(fileName[i]));
      IF fileName[i]#0X THEN INC(i) END;
      INC(j);
    END;
  END;
END WriteSymbolAuxFileName;

PROCEDURE WriteSymbolAuxBfEf*(line:INTEGER; next:LONGINT);
BEGIN
  INC(nSymbols);
  WriteObjLongint(0);
  WriteObjWord(line);
  WriteObjLongint(0);
  WriteObjWord(0);
  WriteObjLongint(next);
  WriteObjWord(0);
END WriteSymbolAuxBfEf;

(*----------------------------------------------------------------------------*)

PROCEDURE Init*;
(* Initialize all tables prior to each compilation run 
   precondition: variable OPM.sourceFile initialized 
   *)
VAR
  i:INTEGER;
BEGIN
  lastTrueLineNr:=-1;
  procLineNrs:=0;
  nofSections:=3;
  IF OPM.addSymDebugInfo THEN 
    INC(nofSections,2); 
    minResEntries:=1+3*nofSections-2; (* minimum number of entries in symbol table before procedure definitions, has to be >0 *)
  ELSE
    minResEntries:=1+3*nofSections; (* minimum number of entries in symbol table before procedure definitions, has to be >0 *)
  END;
  resEntries:=minResEntries+SHORT((String.Length(OPM.sourceFile)+17) DIV 18);
  NEW(symbolList);
  IF symbolList#NIL THEN
    symbolList.next:=NIL;
  END;
  lastSymbol:=symbolList;
  NEW(lineNums);
  IF (lineNums=NIL) OR (symbolList=NIL) THEN
    OPM.Err(E.COMPILER_OUT_OF_MEM); 
  END;
  symTableInx:=resEntries;
  nLineNums:=0;
  IF OPM.addSymDebugInfo THEN 
    symInxDebugT:=resEntries-13;
    symInxDebugS:=resEntries-10;
    sctnInxDebugT:=4;
    sctnInxDebugS:=5;
  ELSE
    symInxDebugT:=-1;
    symInxDebugS:=-1;
    sctnInxDebugT:=-1;
    sctnInxDebugS:=-1;
  END;  
  symInxCode:=resEntries-7;
  symInxData:=resEntries-4;
  symInxConst:=resEntries-1;
  sctnInxCode:=1;
  sctnInxData:=2;
  sctnInxConst:=3;
  FOR i:=0 TO nofSections-1 DO
    sctnList[i].length:=0;
    sctnList[i].nofRelocs:=0;
    sctnList[i].nofLines:=0;
  END;
END Init;

PROCEDURE AddLineNum*(offset:LONGINT; sourceLine:INTEGER; procHead:BOOLEAN);
(* add a line number record; at the beginning of each procedure,
   an entry with procHead=TRUE and the offset of the prolog code
   of the procedure has to be added. 
   Consecutive calls for an identical line number are ignored except
   for the first call.
   Consecutive calls for an identical offset always update the line number
   to the last value.
   Must not be called any more when WriteCoffHeader has been called.
    *)
BEGIN
  IF sourceLine=-1 THEN RETURN END;
  IF OPM.addDebugInfo THEN 
    IF procHead OR (sourceLine#lastTrueLineNr) THEN
      IF (nLineNums>0) & (lineNums[nLineNums-1].offset=offset) & (lineNums[nLineNums-1].line#0) THEN
        lineNums[nLineNums-1].line:=sourceLine;
      ELSE
        IF nLineNums<MAXLINENUMS THEN
          IF procHead THEN
            lineNums[nLineNums].line:=0;
            procLineNrs:=1;
          ELSE
            lineNums[nLineNums].line:=sourceLine;
            INC(procLineNrs);
          END;
          lineNums[nLineNums].offset:=offset;
          lineNums[nLineNums].symbol:=NIL;
          INC(nLineNums);
        ELSE
          OPM.Err(E.TOO_MANY_LINES);
        END;
      END;
    END;
  ELSE
    lineNums[0].line:=sourceLine;
  END;
  lastTrueLineNr:=sourceLine;
END AddLineNum;

PROCEDURE GetLineInx*():INTEGER;
(* return current index of line number records *)
BEGIN
  RETURN nLineNums-1;
END GetLineInx;

PROCEDURE NofProcLines*():INTEGER;
BEGIN
  RETURN procLineNrs;
END NofProcLines;

PROCEDURE GetLastLine*():INTEGER;
(* return the line number of the most recent entry *)
BEGIN
  IF lastTrueLineNr<1 THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.GetLastLine");
    RETURN 0;
  ELSE
    RETURN SHORT(lastTrueLineNr);
  END;
END GetLastLine;

PROCEDURE AddGlobalData*(obj:OPT.Object; VAR symbolTableInx:LONGINT);
(*Add an imported data section and the module body from another module (containing global module data) 
  to the list for symbol table generation. 
  The zero based index the item will have in the symbol table is returned in symbolTableInx.
  Must not be called any more when WriteCoffHeader has been called.
  The index returned + 1 is the index of the symbol for the module body.
*)
VAR
  sym:SymbolImportedData;
BEGIN
  symbolTableInx:=symTableInx;
  NEW(sym);
  IF sym#NIL THEN
    lastSymbol.next:=sym;
    lastSymbol:=sym;
    sym.next:=NIL;
    sym.obj:=obj;
    INC(symTableInx,4);
  ELSE
    OPM.Err(E.COMPILER_OUT_OF_MEM);
  END;           
END AddGlobalData;

PROCEDURE AddImportedProc*(obj:OPT.Object; VAR symbolTableInx:LONGINT);
(*Add an imported procedure to the list for symbol table generation.
  The zero based index the item will have in the symbol table is returned in symbolTableInx.
  Must not be called any more when WriteCoffHeader has been called.
*)
VAR
  sym:SymbolImportedProc;
BEGIN
  symbolTableInx:=symTableInx;
  NEW(sym);
  IF sym#NIL THEN
    lastSymbol.next:=sym;
    lastSymbol:=sym;
    sym.next:=NIL;
    sym.obj:=obj;
    INC(symTableInx);
  ELSE
    OPM.Err(E.COMPILER_OUT_OF_MEM);
  END;
END AddImportedProc;

PROCEDURE AddRtsProc*(VAR name-:ARRAY OF CHAR; VAR symbolTableInx:LONGINT);
(*Add an imported procedure to the list for symbol table generation.
  The zero based index the item will have in the symbol table is returned in symbolTableInx.
  Must not be called any more when WriteCoffHeader has been called.
*)
VAR
  sym:SymbolRtsProc;
BEGIN
  symbolTableInx:=symTableInx;
  NEW(sym);
  IF sym#NIL THEN
    lastSymbol.next:=sym;
    lastSymbol:=sym;
    sym.next:=NIL;
    COPY(name,sym.name);
    INC(symTableInx);
  ELSE
    OPM.Err(E.COMPILER_OUT_OF_MEM);
  END;
END AddRtsProc;

PROCEDURE AddExportedProc*(obj:OPT.Object;                            
                           offset:LONGINT; (* start of procedure code *)
                           codeSize:LONGINT; 
                           firstLine:INTEGER;
                           lastLine:INTEGER;
                           lineNumInx:INTEGER;       (* index of first line number record for the procedure *)
                           VAR symbolTableInx:LONGINT;
                           nofLineRecs:INTEGER);
VAR
  sym:SymbolExportedProc;
BEGIN
  symbolTableInx:=symTableInx;
  NEW(sym);
  IF sym#NIL THEN
    lastSymbol.next:=sym;
    lastSymbol:=sym;
    sym.next:=NIL;
    sym.obj:=obj;
    sym.offset:=offset;
    sym.codeSize:=codeSize;
    sym.firstLine:=firstLine;
    sym.lastLine:=lastLine;
    sym.lineNumInx:=lineNumInx;
    sym.symTableInx:=symTableInx;
    sym.nofLineRecs:=nofLineRecs;
    INC(symTableInx,7); (* an exported procedure creates 7 symbol table entries *)
  ELSE
    OPM.Err(E.COMPILER_OUT_OF_MEM);
  END;
END AddExportedProc;                           


PROCEDURE AddLocalProc*(obj:OPT.Object;                            
                        offset:LONGINT; (* start of procedure code *)
                        codeSize:LONGINT; 
                        firstLine:INTEGER;
                        lastLine:INTEGER;
                        lineNumInx:INTEGER;       (* index of first line number record for the procedure *)
                        VAR symbolTableInx:LONGINT;
                        nofLineRecs:INTEGER);
VAR
  sym:SymbolLocalProc;
BEGIN
  symbolTableInx:=symTableInx;
  NEW(sym);
  IF sym#NIL THEN
    lastSymbol.next:=sym;
    lastSymbol:=sym;
    sym.next:=NIL;
    sym.obj:=obj;
    sym.offset:=offset;
    sym.codeSize:=codeSize;
    sym.firstLine:=firstLine;
    sym.lastLine:=lastLine;
    sym.lineNumInx:=lineNumInx;
    sym.symTableInx:=symTableInx;
    sym.nofLineRecs:=nofLineRecs;
    INC(symTableInx,7); (* an exported procedure creates 7 symbol table entries *)
  ELSE
    OPM.Err(E.COMPILER_OUT_OF_MEM);
  END;
END AddLocalProc;                           
  
PROCEDURE CreateLineNumTableReferences;
(* Create the references from the line number records to the symbol table *)
VAR
  sym:SymbolListEle;
BEGIN
  IF OPM.addDebugInfo THEN 
    sym:=symbolList.next;
    WHILE sym#NIL DO
      IF sym IS SymbolExportedProc THEN
        IF lineNums[sym(SymbolExportedProc).lineNumInx].line#0 THEN
          OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.CreateLineNumTableReferences");
        ELSE
          lineNums[sym(SymbolExportedProc).lineNumInx].offset:=sym(SymbolExportedProc).symTableInx;
          lineNums[sym(SymbolExportedProc).lineNumInx].symbol:=sym(SymbolExportedProc);
        END;
      END;
      sym:=sym.next;
    END;
  END;
END CreateLineNumTableReferences;

PROCEDURE WriteLineNumberTable*;
(* write the line number info to the object file 
   Line number references to the symbol table are set here and file pointer info
   is prepared here, therefore the line number records need to be written before
   the symbol table. 
   After this procedure has been called no more line numbers may be added with AddLineNum. *)
VAR
  i:INTEGER;
  procStart:INTEGER;
  sym:SymbolListEle;
BEGIN
  IF OPM.addDebugInfo THEN 
    WriteFixup(codeFixup+8,globObjLen);
    CreateLineNumTableReferences;
    procStart:=0;
    FOR i:=0 TO nLineNums-1 DO
      IF lineNums[i].line=0 THEN (* procedure heading *)
        IF lineNums[i].symbol=NIL THEN
          OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.WriteLineNumberTable");
          WriteObjLongint(lineNums[i].offset);
          WriteObjWord(0);
        ELSE
          lineNums[i].symbol.lineNumInx:=globObjLen;
          procStart:=lineNums[i].symbol.firstLine;
          WriteObjLongint(lineNums[i].offset);
          WriteObjWord(0);
        END;
      ELSE                     (* normal line number within procedure *)
        WriteObjLongint(lineNums[i].offset);
        WriteObjWord(lineNums[i].line-procStart);
      END;
    END;
  ELSE
    sym:=symbolList.next; (* set all indices to line number table to zero to indicate that there is none *)
    WHILE sym#NIL DO
      IF sym IS SymbolExportedProc THEN
        sym(SymbolExportedProc).lineNumInx:=0;
      END;
      sym:=sym.next;
    END;
  END;
END WriteLineNumberTable;

PROCEDURE (sym:SymbolListEle) WriteTableEntry(x:LONGINT);
(* write the symbol table entry for the receiver *)
BEGIN
  OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.SymbolListEle.WriteTableEntry");
END WriteTableEntry;

PROCEDURE (sym:SymbolImportedData) WriteTableEntry(nextI:LONGINT);
VAR
  str:ARRAY 2*OPM.MaxIdLen+9 OF CHAR;
BEGIN
  MakeSectionName(sym.obj^.name, SCTNNAME_DATA, str);
  WriteSymbol(str,
              0, (* should be size !!!!! *)
              0, (* one based section index *)
              0H, (* not a function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
  OPM.MakeGlobalName(sym.obj^.name, MODULE_BODY_NAME, str);
  IF sym.obj^.fromDLL THEN String.Insert("__imp_",str,1) END;
  WriteSymbol(str,
              0, (* should be size !!!!! *)
              0, (* one based section index *)
              20H, (* a function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
  MakeSectionName(sym.obj^.name, SCTNNAME_CONST, str);
  WriteSymbol(str,
              0, (* should be size !!!!! *)
              0, (* one based section index *)
              0H, (* not a function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
  MakeSectionName(sym.obj^.name, SCTNNAME_CODE, str);
  WriteSymbol(str,
              0, (* should be size !!!!! *)
              0, (* one based section index *)
              0H, (* not a function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
END WriteTableEntry;

PROCEDURE (sym:SymbolImportedProc) WriteTableEntry(nextI:LONGINT);
VAR
  str:ARRAY 2*OPM.MaxIdLen+9 OF CHAR;
  h:ARRAY 10 OF CHAR;
BEGIN
  IF sym.obj^.mode = WProc THEN
    String.Str(sym.obj^.conval.intval,h);
    COPY(sym.obj^.name, str);
    String.Append(str,"@");
    String.Append(str,h);
    String.Insert("_",str,1);
  ELSIF sym.obj^.mode = MODE_CDECLPROC THEN
    OPM.MakeCName(sym.obj^.name,str);
  ELSE
    OPM.MakeGlobalName(OPT.GlbMod[-sym.obj^.mnolev - 1]^.name, sym.obj^.name, str)
  END;
  IF sym.obj^.fromDLL THEN
    String.Insert("__imp_",str,1);
  END;
  WriteSymbol(str,
              0, (* should be size *)
              0, (* one based section index *)
              20H, (* function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
END WriteTableEntry;

PROCEDURE (sym:SymbolRtsProc) WriteTableEntry(nextI:LONGINT);
VAR
  str:ARRAY 2*OPM.MaxIdLen+2 OF CHAR;
BEGIN
  OPM.MakeGlobalName(RTS_MODULE_NAME, sym.name, str);
  WriteSymbol(str,
              0, (* should be size !!!!! *)
              0, (* one based section index *)
              20H, (* function *)
              IMPORTED_SYM_CLASS,
              0); (* aux records *) 
END WriteTableEntry;

PROCEDURE (sym:SymbolExportedProc) WriteTableEntry(nextI:LONGINT);
(* write the symbol table entry for the receiver *)
VAR
  nextBf:LONGINT;
  str:ARRAY 3*OPM.MaxIdLen+3 OF CHAR;
  h:ARRAY 10 OF CHAR;
BEGIN
  IF sym.obj=NIL THEN
    OPM.MakeGlobalName(OPM.moduleName, MODULE_BODY_NAME, str);
  ELSIF sym.obj^.mode = TProc THEN
    IF (sym.obj^.link=NIL) OR 
       (sym.obj^.link^.typ=NIL) OR 
       (sym.obj^.link^.typ^.strobj=NIL) THEN
      OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.SymbolExportedProc.WriteTableEntry");
    ELSE
      COPY(OPM.moduleName,str);
      String.AppendChar(str,OPM.SYMBOLSEPARATOR);
      String.Append(str,sym.obj^.link^.typ^.strobj^.name);
      String.AppendChar(str,OPM.SYMBOLSEPARATOR);
      String.Append(str,sym.obj^.name);
    END;
  ELSIF sym.obj^.mode = WProc THEN
    String.Str(sym.obj^.conval.intval,h);
    COPY(sym.obj^.name, str);
    String.Append(str,"@");
    String.Append(str,h);
    String.Insert("_",str,1);
  ELSIF sym.obj^.mode = MODE_CDECLPROC THEN
    OPM.MakeCName(sym.obj^.name,str);
  ELSE
    OPM.MakeGlobalName(OPM.moduleName, sym.obj^.name, str);
  END;
  
  WriteSymbol(str,
              sym.offset,
              1, (* one based section index *)
              20H, (* function *)
              IMAGE_SYM_CLASS_EXTERNAL,
              1); (* aux records *) 
  WriteSymbolAuxProc(sym.symTableInx+2, (* symbol table index of corresponding .bf entry *)
                     sym.codeSize,
                     sym.lineNumInx, (* file offset of line number records or zero if none *)
                     nextI); (* index of next function definition *)
  WriteSymbol(".bf",0,1,0,IMAGE_SYM_CLASS_FUNCTION,1);
  IF nextI>0 THEN nextBf:=nextI+2 ELSE nextBf:=0 END;
  WriteSymbolAuxBfEf(sym.firstLine,nextBf);
  WriteSymbol(".lf",sym.nofLineRecs,1,0,IMAGE_SYM_CLASS_FUNCTION,0);
  WriteSymbol(".ef",sym.codeSize,1,0,IMAGE_SYM_CLASS_FUNCTION,1);
  WriteSymbolAuxBfEf(sym.lastLine,0);
END WriteTableEntry;

PROCEDURE (sym:SymbolLocalProc) WriteTableEntry(nextI:LONGINT);
(* write the symbol table entry for the receiver *)
VAR
  nextBf:LONGINT;
  str:ARRAY 3*OPM.MaxIdLen+3 OF CHAR;
  h:ARRAY 10 OF CHAR;
BEGIN
  IF (sym.obj=NIL) OR (sym.obj^.mode = TProc) THEN
    OPM.CommentedErr(E.INTERNAL_MURKS,"Coff.SymbolLocalProc.WriteTableEntry");
    RETURN;
  ELSE
    String.Str(sym.offset,h);
    String.Insert("$",h,1);
    OPM.MakeGlobalName(OPM.moduleName, h, str);
  END;
  
  WriteSymbol(str,
              sym.offset,
              1, (* one based section index *)
              20H, (* function *)
              IMAGE_SYM_CLASS_EXTERNAL,
              1); (* aux records *) 
  WriteSymbolAuxProc(sym.symTableInx+2, (* symbol table index of corresponding .bf entry *)
                     sym.codeSize,
                     sym.lineNumInx, (* file offset of line number records or zero if none *)
                     nextI); (* index of next function definition *)
  WriteSymbol(".bf",0,1,20H,IMAGE_SYM_CLASS_FUNCTION,1);
  IF nextI>0 THEN nextBf:=nextI+2 ELSE nextBf:=0 END;
  WriteSymbolAuxBfEf(sym.firstLine,nextBf);
  WriteSymbol(".lf",sym.nofLineRecs,1,20H,IMAGE_SYM_CLASS_FUNCTION,0);
  WriteSymbol(".ef",sym.codeSize,1,20H,IMAGE_SYM_CLASS_FUNCTION,1);
  WriteSymbolAuxBfEf(sym.lastLine,0);
END WriteTableEntry;

PROCEDURE WriteSymbolTable*;
(* All procedure symbols previously defined with AddProcSym are automatically
   written to the symbol table. *)
VAR
  nextI:LONGINT;
  sym,h:SymbolListEle;
BEGIN
  (* fix the pointer to the symbol table in the header *)
  WriteFixup(symTableFixup,globObjLen);
  nSymbols:=0;
  
  (* write source filename *)
  WriteSymbol(".file", 0, IMAGE_SYM_DEBUG, 0H, IMAGE_SYM_CLASS_FILE,
              SHORT((String.Length(OPM.sourceFile)+17) DIV 18)); (* aux records *)
  WriteSymbolAuxFileName(OPM.sourceFile);

  IF OPM.addSymDebugInfo THEN
    (* write debug types section symbol *)
    WriteSymbol(SCTNNAME_DEBUGTYPES, 0, sctnInxDebugT, 0H, IMAGE_SYM_CLASS_STATIC, 1); 
    WriteSectionAux(sctnList[sctnInxDebugT-1].length,
                    sctnList[sctnInxDebugT-1].nofRelocs,
                    sctnList[sctnInxDebugT-1].nofLines,
                    0,0,0);

    (* write debug symbols section symbol *)
    WriteSymbol(SCTNNAME_DEBUGSYMBOLS, 0, sctnInxDebugS, 0H, IMAGE_SYM_CLASS_STATIC, 1); 
    WriteSectionAux(sctnList[sctnInxDebugS-1].length,
                    sctnList[sctnInxDebugS-1].nofRelocs,
                    sctnList[sctnInxDebugS-1].nofLines,
                    0,0,0);
  END;

  (* write code section symbol *)
  WriteSymbol(SHORT_SCTNNAME_CODE, 0, sctnInxCode, 0H, IMAGE_SYM_CLASS_STATIC, 1); 
  WriteSectionAux(sctnList[sctnInxCode-1].length,
                  sctnList[sctnInxCode-1].nofRelocs,
                  sctnList[sctnInxCode-1].nofLines,
                  0,0,0);
  WriteSymbol(sctnNameCode, 0, sctnInxCode, 0H, IMAGE_SYM_CLASS_EXTERNAL,0); 

  (* write data section symbol *)
  WriteSymbol(SHORT_SCTNNAME_DATA, 0, sctnInxData, 0H, IMAGE_SYM_CLASS_STATIC, 1); 
  WriteSectionAux(sctnList[sctnInxData-1].length,
                  sctnList[sctnInxData-1].nofRelocs,
                  sctnList[sctnInxData-1].nofLines,
                  0,0,0);
  WriteSymbol(sctnNameData, 0, sctnInxData, 0H, IMAGE_SYM_CLASS_EXTERNAL,0); 

  (* write const section symbol *)
  WriteSymbol(SHORT_SCTNNAME_CONST, 0, sctnInxConst, 0H, IMAGE_SYM_CLASS_STATIC, 1); 
  WriteSectionAux(sctnList[sctnInxConst-1].length,
                  sctnList[sctnInxConst-1].nofRelocs,
                  sctnList[sctnInxConst-1].nofLines,
                  0,0,0);
  WriteSymbol(sctnNameConst, 0, sctnInxConst, 0H, IMAGE_SYM_CLASS_EXTERNAL,0); 

  (* write the symbol list *)
  sym:=symbolList.next;
  WHILE sym#NIL DO
    IF sym IS SymbolExportedProc THEN
      h:=sym.next;
      WHILE (h#NIL) & ~(h IS SymbolExportedProc) DO h:=h.next END;
      IF h=NIL THEN nextI:=0 ELSE nextI:=h(SymbolExportedProc).symTableInx END;
    ELSE
      nextI:=0;
    END;
    sym.WriteTableEntry(nextI);
    sym:=sym.next;
  END;
  
  WriteFixup(symTableFixup+4,nSymbols);
END WriteSymbolTable;

PROCEDURE WriteCode*(VAR code-:ARRAY OF CHAR; size:LONGINT);
(* write the code block and fix file pointer references *)
BEGIN
  WriteFixup(codeFixup,globObjLen);
  WriteDataBlock(code,size);
END WriteCode;

PROCEDURE WriteConst*(VAR data-:ARRAY OF CHAR; size:LONGINT);
(* write the initialized data block and fix file pointer references *)
BEGIN
  WriteFixup(constFixup,globObjLen);
  WriteDataBlock(data,size);
END WriteConst;

PROCEDURE StartCodeRelocs*;
(* call directly before the first call to WriteReloc *)
BEGIN
  relocsStart:=globObjLen;
  relocsN:=0;
END StartCodeRelocs;

PROCEDURE WriteReloc*(offset,symInx:LONGINT; type:INTEGER);
(* write one relocation record *)
BEGIN
  WriteObjLongint(offset);
  WriteObjLongint(symInx);
  WriteObjWord(type);
  INC(relocsN);
END WriteReloc;

PROCEDURE EndCodeRelocs*;
(* call directly after the last call to WriteReloc *)
BEGIN
  WriteFixup(codeFixup+4,relocsStart);
  WriteFixupWord(codeFixup+12,relocsN);
  sctnList[sctnInxCode-1].nofRelocs:=relocsN;
END EndCodeRelocs;


PROCEDURE StartConstRelocs*;
(* call directly before the first call to WriteReloc *)
BEGIN
  relocsStart:=globObjLen;
  relocsN:=0;
END StartConstRelocs;

PROCEDURE EndConstRelocs*;
(* call directly after the last call to WriteReloc *)
BEGIN
  WriteFixup(constFixup+4,relocsStart);
  WriteFixupWord(constFixup+12,relocsN);
  sctnList[sctnInxConst-1].nofRelocs:=relocsN;
END EndConstRelocs;

PROCEDURE StartDebugRelocs*;
(* call directly before the first call to WriteReloc *)
BEGIN
  relocsStart:=globObjLen;
  relocsN:=0;
END StartDebugRelocs;

PROCEDURE EndDebugRelocs*;
(* call directly after the last call to WriteReloc *)
BEGIN
  WriteFixup(debugSymbolsFixup+4,relocsStart);
  WriteFixupWord(debugSymbolsFixup+12,relocsN);
  sctnList[sctnInxDebugS-1].nofRelocs:=relocsN;
END EndDebugRelocs;

BEGIN
  objLen:=0;
  stringLen:=0;
  globObjLen:=0;
END Coff.
