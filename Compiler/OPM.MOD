(******************************************************************************)
(*                                                                            *)
(**)                        MODULE OPM;                                     (**)
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
(* PURPOSE:  Host interface of Oberon2 compiler DLL                           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*   This module contains all machine dependent constants needed before code  *)
(*   generation.                                                              *)
(******************************************************************************)

  IMPORT SYSTEM,E:=Error,W:=Win32,String;

  CONST
    version* = "1.3a 32Bit";     (* compiler version *)
    SF_TAG = 1A4D5953H;          (* symbol file tag *)
    SF_VERSION_TAG = 00320200H;  (* symbol file version tag *)
    SYMBOLSEPARATOR*="_";        (* character used to separate module names, class 
                                    names and procedure names in linker symbols *)

  
    FPU_ROUND_NEAREST    =0000H; (* round to nearest   *)
    FPU_ROUND_DOWN       =0400H; (* round to neg. inf. *)
    FPU_ROUND_TRUNC      =0C00H; (* round to zero      *)
    FPU_PREC_EXTENDED    =0300H; (* 64 bit precision   *)
    FPU_EXCEPTIONS       =0070H; (* mask underflow and precision exceptions *)
    FPU_INF_CONTROL      =1000H;
    FPU_CONTROL_WORD*=FPU_ROUND_DOWN+FPU_PREC_EXTENDED+FPU_EXCEPTIONS+FPU_INF_CONTROL; (* setting for fpu control word *)

    
    (* basic type sizes *)
    ByteSize* = 1;    (* SYSTEM.BYTE *)
    CharSize* = 1;    (* CHAR *)
    BoolSize* = 1;    (* BOOLEAN *)
    SetSize* = 4;     (* SET *)
    SIntSize* = 1;    (* SHORTINT *)
    IntSize* = 2;     (* INTEGER *)
    LIntSize* = 4;    (* LONGINT *)
    RealSize* = 4;    (* REAL *)
    LRealSize* = 8;   (* LONGREAL *)
    ProcSize* = 4;    (* PROCEDURE type *)
    PointerSize* = 4; (* POINTER type *)

    (* value of constant NIL *)
    nilval* = 0;
    
    (* target machine minimum values of basic types expressed in host machine format: *)
    MinSInt* = -80H;
    MinInt* = -8000H;
    MinLInt* =  -7FFFFFFFH-1;(*-2147483648*)
    MinRealPat = -800001H;   (*0FF7FFFFFH*)    (* most  negative, 32-bit pattern *)
    MinLRealPatL = -1;       (*0FFFFFFFFH*)    (* most  negative, lower 32-bit pattern *)
    MinLRealPatH = -100001H; (*0FFEFFFFFH*)    (* most  negative, higher 32-bit pattern *)
    
    (* target machine maximum values of basic types expressed in host machine format: *)
    MaxSInt* = 7FH;
    MaxInt* = 7FFFH;
    MaxLInt* = 7FFFFFFFH; (*2147483647*)
    MaxSet* = 31;                     (* must be >= 15, else the bootstraped compiler cannot run (IN-tests) *)
    MaxRealPat = 7F7FFFFFH;           (* most positive, 32-bit pattern *)
    MaxLRealPatL = -1; (*0FFFFFFFFH*) (* most positive, lower 32-bit pattern *)
    MaxLRealPatH = 7FEFFFFFH;         (* most positive, higher 32-bit pattern *)
    
    (* maximal index value for array declaration: *)
    MaxIndex* = 10000000H; 
     
    (* parametrization of numeric scanner: *)
    MaxHDig* = 8;    (* maximal hexadecimal longint length *)
    MaxRExp* = 38;   (* maximal real exponent *)
    MaxLExp* = 308;  (* maximal longreal exponent *)
    
    (* inclusive range of parameter of standard procedure HALT: *)
    MinHaltNr* = 0;
    MaxHaltNr* = MaxInt;
    
    (* inclusive range of register number of procedures SYSTEM.GETREG and SYSTEM.PUTREG: *)
    MinRegNr* = 0;    (* interpretation is left to the back-end *)
    MaxRegNr* = 13;
    
    (* maximal value of flag used to interface structures: *)
    MaxSysFlag* = 3;    (* 0: default, 1: [_APICALL], 2: [_CDECL], 3:[_NOTALIGNED] *) 
    SYSFLAG_APICALL*=1;
    SYSFLAG_CDECL*=2;
    SYSFLAG_NOTALIGNED*=3;
    
    (* maximal condition value of parameter of SYSTEM.CC: *)
    MaxCC* = 0;    (* interpretation is left to the back-end *)
    
    (* initialization of linkadr field in ObjDesc, must be different from any valid link address: *)
    LANotAlloc* = 0;
    
    (* initialization of constant addys, must be different from any valid constant address: *)
    ConstNotAlloc* = -1;
    
    (* initialization of tdadr field in StrDesc, must be different from any valid address: *)
    TDAdrUndef* = -1;
    
    (* maximal number of cases in a case statement: *)
    MaxCases* = 512;
    
    (* maximal range of a case statement (higher label - lower label ~ jump table size): *)
    MaxCaseRange* = 512;
    
    (* whether hidden pointer fields have to be nevertheless exported: *)
    ExpHdPtrFld* = TRUE;

    (* whether hidden procedure fields have to be nevertheless exported (may be used for System.Free): *)
    ExpHdProcFld* = FALSE;
    
    (* whether hidden bound procedures have to be nevertheless exported: *)
    ExpHdTProc* = FALSE;

    (* whether addresses of formal parameters are exported: *)
    ExpParAdr* = FALSE;

    (* whether addresses or entry numbers are exported for global variables: *)
    ExpVarAdr* = TRUE; (*!*)

    (* whether field leaf of pointer variable p has to be set to FALSE, when NEW(p) or SYSTEM.NEW(p, n) is used: *)
    NEWusingAdr* = TRUE;
    
    (* special character (< " ") returned by procedure Get, if end of text reached *)
    Eot* = 0X;

    (* files *)
    srcFileNum* = 0; symFileNum* = 1; tmpFileNum* = 2; objFileNum* = 3;
    expFileNum* = 4; licFileNum* = 5;

    (* maximum length of identifiers *)
    MaxIdLen* = 45;

    maxSrcLen = 8192;
    maxSymLen = 8192;
    maxTmpLen = 8192;
    maxObjLen = 32767;
    maxExpLen = maxObjLen;
    LINENUMFACT* = 8000H; (* ASSERT, HALT: lineNum = pos DIV lineNumFact, charNum = pos MOD lineNumFact *)
(*!L+*)
    nofRound = 10;
    userKeyLen = 8;
    dataLen = 4;
    keyLen = nofRound * 6 + 4;
    dataSize = 2 * dataLen;
    mulMod = 10001H;
    addMod = 10000H;
    licUserNameBlkLen = 16;
    licUserNameStrLen = licUserNameBlkLen * dataSize;
(*!L-*)

  TYPE
    Name* = ARRAY MaxIdLen OF CHAR;
    CreateFileProc* = PROCEDURE (fileNum: INTEGER; VAR modName: Name; VAR res: INTEGER);
    OpenFileProc* = PROCEDURE (fileNum: INTEGER; VAR modName: Name; VAR res:INTEGER);
    ReadBytesProc* = PROCEDURE (fileNum: INTEGER; VAR x: ARRAY OF SYSTEM.BYTE; VAR n: LONGINT);
    WriteBytesProc* = PROCEDURE (fileNum: INTEGER; VAR x: ARRAY OF SYSTEM.BYTE; n: LONGINT);
    SeekFileProc*=PROCEDURE (fileNum:INTEGER; pos:LONGINT);
    FilePosProc*=PROCEDURE (fileNum:INTEGER):LONGINT;
    CloseFileProc* = PROCEDURE (fileNum: INTEGER);
    StoreNewSymFileProc* = PROCEDURE (VAR modName: Name; VAR res:INTEGER);
    ImportedModuleProc* = PROCEDURE (VAR modName: Name);
    NewKeyProc* = PROCEDURE (): INTEGER;
    LogWriteProc* = PROCEDURE (ch: CHAR);
    LogWriteLnProc* = PROCEDURE;
    ErrorProc* = PROCEDURE (errorNum, lineNum, charNum: INTEGER;
                            warning:BOOLEAN;
                            VAR txt:ARRAY OF CHAR);
(*!L+*)
    Data* = ARRAY dataLen OF INTEGER;
    UserKey = ARRAY userKeyLen OF INTEGER;
    Key = ARRAY keyLen OF INTEGER;
    LicUserNameBlk = ARRAY licUserNameBlkLen OF Data;
    LicUserNameStr = ARRAY licUserNameStrLen OF CHAR;
    License = RECORD
      licUserNameBlk: LicUserNameBlk;
      licCodeBlk: Data;
    END;
(*!L-*)
    SourcePosT*=RECORD
      line*,column*:LONGINT;
    END;

  VAR
    MinReal*, MaxReal*: REAL;
    MinLReal*, MaxLReal*: LONGREAL;
    noerr*: BOOLEAN;  (* no error found until now *)
    curpos*, errpos*: SourcePosT;  (* character and error position in source file *)
    breakpc*: LONGINT;  (* set by OPV.Init *)
    curObjRec*: INTEGER; (* current object record type *)
    data2*: Data; (*!L*)

    CreateFile*: CreateFileProc;  (* create a new file *)
    OpenFile*: OpenFileProc;  (* open an existing file *)
    ReadBytes*: ReadBytesProc;  (* postconditition: n = number of bytes read *)
    WriteBytes*: WriteBytesProc;
    CloseFile*: CloseFileProc;
    SeekFile*:SeekFileProc;
    FilePos*:FilePosProc;
    StoreNewSymFile*: StoreNewSymFileProc;
    LogWrite*: LogWriteProc;
    LogWriteLn*: LogWriteLnProc;
    Error*: ErrorProc;

    data1*: Data; (*!L*)

    LRealPat: RECORD L, H: LONGINT END;
    pat: LONGINT;
    lastErrPos: SourcePosT;    (* last error position in source file *)

    symFilesEqual: BOOLEAN;
    symFileKey: LONGINT;

    srcBuf: ARRAY maxSrcLen OF CHAR;
    symBuf: ARRAY maxSymLen OF CHAR;
    objBuf: ARRAY maxObjLen OF CHAR; (* is used for expBuf *)
    tmpBuf: ARRAY maxTmpLen OF CHAR;
    srcLen, srcPos, symLen, symPos, tmpLen, tmpPos, expLen, objLen: LONGINT;

    actRecCheckSum: INTEGER;
    license: License; (*!L*)
    
    moduleName-:ARRAY MaxIdLen OF CHAR; (* name of currently compiler module *)
    sourceFile-:ARRAY 256 OF CHAR; (* name of source file *)

    addDebugInfo-: BOOLEAN;   (* add COFF line number info ? *)
    addSymDebugInfo-:BOOLEAN; (* add symbolic debug info (CodeView compatible), 
                                 requires addDebugInfo to be set *)
    codeWritable-:BOOLEAN;    (* should it be possible to modify code at run-time? *)
    
(*============================ G E N E R A L   P R O C E D U R E =============*)

  PROCEDURE Init*(addDebug,addSymDebug,cWriteable:BOOLEAN);
  BEGIN
    curpos.line:=1;
    curpos.column:=0;
    errpos.line:=0;
    errpos.column:=0;
    noerr:=TRUE;
    lastErrPos.line:=-1;
    lastErrPos.column:=0;
    srcLen:=0; srcPos:=0; symLen:=0; symPos:=0; objLen:=0;
    tmpLen:=0; expLen:=0;
    symFilesEqual:=FALSE;
    addDebugInfo:=addDebug;
    addSymDebugInfo:=addSymDebug;
    codeWritable:=cWriteable;
    IF addSymDebugInfo THEN addDebugInfo:=TRUE END;
  END Init;

(*----------------------------------------------------------------------------*)
  PROCEDURE Get*(VAR ch: CHAR);    (* read next character from source text, Eot if no more *)
  BEGIN 
    IF srcPos < srcLen THEN
      ch:=srcBuf[srcPos]; INC(srcPos)
    ELSE
      srcLen:=maxSrcLen;
      ReadBytes(srcFileNum, srcBuf, srcLen);
      IF srcLen > 0 THEN 
        ch:=srcBuf[0]; 
        srcPos:=1
      ELSE 
        ch:=Eot; 
        srcPos:=srcLen;
      END
    END;
    IF ch = 0AX (* LF *) THEN
      INC(curpos.line);
      curpos.column:=1;
    ELSE (* 0DX CR and other *)
      INC(curpos.column);
    END
  END Get;
    
(*----------------------------------------------------------------------------*)
  PROCEDURE LongIntToString*(l: LONGINT; VAR str: ARRAY OF CHAR);
  VAR 
    i, j: INTEGER; 
    num: ARRAY 20 OF CHAR;
  BEGIN
    IF l < 0 THEN l:=-l; str[0]:="-"; j:=1 ELSE j:=0 END;
    i:=0;
    REPEAT
      num[i]:=CHR(ORD("0") + (l MOD  10));
      l:=l DIV  10;
      INC(i)
    UNTIL l = 0;
    WHILE i > 0 DO DEC(i); str[j]:=num[i]; INC(j) END;
    str[j]:=0X;
  END LongIntToString;

(*----------------------------------------------------------------------------*)
  PROCEDURE Length(VAR s: ARRAY OF CHAR): INTEGER;
    VAR i: INTEGER;
  BEGIN
    i:=0;
    WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END;
    RETURN i
  END Length;

(*----------------------------------------------------------------------------*)
  PROCEDURE Append*(VAR s, t: ARRAY OF CHAR);
    VAR i, j: INTEGER;
  BEGIN
    j:=Length(t);
    i:=Length(s);
    t[i + j]:=0X;
    WHILE i > 0 DO DEC(i); t[i + j]:=s[i] END;
  END Append;

(*----------------------------------------------------------------------------*)
  PROCEDURE MakeGlobalName*(VAR modName-:ARRAY OF CHAR;
                            localName: ARRAY OF CHAR; 
                            VAR globalName: ARRAY OF CHAR);
  VAR 
    h: ARRAY 2 OF CHAR;
  BEGIN
    COPY(modName,globalName);
    h:=SYMBOLSEPARATOR;
    Append(h ,globalName);
    Append(localName,globalName);
  END MakeGlobalName;

  PROCEDURE MakeCName*(VAR name-,linkSymbol:ARRAY OF CHAR);
  VAR
    i:INTEGER;
  BEGIN
    linkSymbol[0]:="_";
    i:=0;
    WHILE name[i]#0X DO
      linkSymbol[i+1]:=name[i];
      INC(i);
    END;
    linkSymbol[i+1]:=0X;
  END MakeCName;

  PROCEDURE SetModuleName*(VAR module-:ARRAY OF CHAR);
  BEGIN
    COPY(module,moduleName);
  END SetModuleName;
  
  PROCEDURE SetSourceFile*(VAR fileName-:ARRAY OF CHAR);
  BEGIN
    COPY(fileName,sourceFile);
  END SetSourceFile;
  
(*============================ S T A N D A R D   O U T P U T =================*)

  PROCEDURE LogW*(ch: CHAR);
  BEGIN
    LogWrite(ch);
  END LogW;

(*----------------------------------------------------------------------------*)
  PROCEDURE LogWLn*;
  BEGIN
    LogWriteLn();
  END LogWLn;

(*----------------------------------------------------------------------------*)
  PROCEDURE LogWStr*(s: ARRAY OF CHAR);
  VAR i: INTEGER;
  BEGIN i:=0;
    WHILE s[i] # 0X DO LogW(s[i]); INC(i) END
  END LogWStr;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE LogWNum*(i, len: LONGINT);
    VAR neg: BOOLEAN;
    PROCEDURE WriteDigit(i, len: LONGINT);
    BEGIN
      IF i # 0 THEN WriteDigit(i DIV 10, len - 1);
        LogW(CHR(ORD('0') + i MOD 10));
      ELSE
        WHILE len > 0 DO LogW(" "); DEC(len) END;
        IF neg THEN LogW("-") END;
      END
    END WriteDigit;
  BEGIN
    neg:=i < 0;
    IF i = 0 THEN WriteDigit(0, len - 1); LogW("0")
    ELSIF neg THEN WriteDigit(-i, len - 1)
    ELSE WriteDigit(i, len)
    END
  END LogWNum;

(*============================ E R R O R   O U T P U T =======================*)

  PROCEDURE Mark*(err:INTEGER; pos:SourcePosT; optTxt:ARRAY OF CHAR);
  VAR
    msg:ARRAY 200 OF CHAR;
    x:INTEGER;
  BEGIN
    E.Message(err,optTxt,msg);
(*    x:=W.MessageBox(0,SYSTEM.ADR(msg),SYSTEM.ADR("Shit"),W.MB_TASKMODAL);*)
    IF err>=0 THEN
      IF noerr OR (err=E.INTERNAL_MURKS) OR (pos.line#lastErrPos.line) THEN
        noerr:=FALSE;
        lastErrPos:=pos;
        Error(err,SHORT(pos.line),SHORT(pos.column),FALSE,msg)
      END
    ELSE
      Error(err,SHORT(pos.line),SHORT(pos.column),TRUE,msg)
    END
  END Mark;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE Err*(n:INTEGER);
  BEGIN 
    Mark(n,errpos,"")
  END Err;

  PROCEDURE Warn*(code:INTEGER);
  BEGIN 
    code:=-ABS(code);
    Mark(code,errpos,"")
  END Warn;

  PROCEDURE CommentedErr*(n:INTEGER; txt:ARRAY OF CHAR);
  BEGIN 
    Mark(n,errpos,txt)
  END CommentedErr;

(*!L+*)
(*============================ L I C E N S E =================================*)

  PROCEDURE ReadLicense*;
  VAR 
    n, i, j: LONGINT; 
    done: BOOLEAN; 
    modName: Name;
    str: LicUserNameStr;
    res:INTEGER;
  BEGIN
    FOR i:=0 TO MaxIdLen - 1 DO modName[i]:=0X END;
    OpenFile(licFileNum, modName, res);
    IF res#0 THEN 
      CommentedErr(res,"license file");
    ELSE
      n:=SIZE(License);
      ReadBytes(licFileNum, license, n);
      IF n # SIZE(License) THEN Err(E.INCORRECT_LICENSE);
      ELSE
        str:=SYSTEM.VAL(LicUserNameStr, license.licUserNameBlk);
        i:=0; LogW(" "); LogW(" ");
        WHILE str[i] # 0X DO
          IF str[i] >= " " THEN
            LogW(str[i])
          ELSIF str[i] = 0DX THEN
            LogWLn; LogW(" "); LogW(" ");
          END;
          INC(i)
        END;
        LogWLn;
      END;
      CloseFile(licFileNum);
    END
  END ReadLicense;
  
(*!L-*)
(*============================ R E A D   S Y M B O L   F I L E ===============*)

  PROCEDURE SymRCh*(VAR ch: CHAR);
  BEGIN
    IF symPos # symLen THEN
      ch:=symBuf[symPos]; 
      INC(symPos)
    ELSE
      IF symLen = maxSymLen THEN
        ReadBytes(symFileNum, symBuf, symLen);
        IF symLen > 0 THEN 
          ch:=symBuf[0]; 
          symPos:=1
        ELSE 
          ch:=Eot; 
          symPos:=symLen
        END
      ELSE 
        ch:=Eot
      END
    END
  END SymRCh;
  
(*----------------------------------------------------------------------------*)
    PROCEDURE SymRTag*(VAR k: INTEGER);
    VAR ch: CHAR;
    BEGIN 
      SymRCh(ch); 
      k:=ORD(ch);
    END SymRTag;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymRBytes(VAR x: ARRAY OF SYSTEM.BYTE; len: INTEGER);
  VAR 
    i: INTEGER; 
    ch: CHAR;
  BEGIN i:=0;
    WHILE i < len DO 
      SymRCh(ch); 
      x[i]:=ch; 
      INC(i) 
    END;
  END SymRBytes;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymRInt*(VAR k: LONGINT);
  VAR 
    i: INTEGER;
  BEGIN 
    SymRBytes(i, IntSize); 
    k:=i
  END SymRInt;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymRLInt*(VAR k: LONGINT);
  BEGIN 
    SymRBytes(k, LIntSize)
  END SymRLInt;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE SymRSet*(VAR s: SET);
  BEGIN 
    SymRBytes(s, SetSize)
  END SymRSet;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymRReal*(VAR r: REAL);
  BEGIN 
    SymRBytes(r, RealSize)
  END SymRReal;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE SymRLReal*(VAR lr: LONGREAL);
  BEGIN 
    SymRBytes(lr, LRealSize)
  END SymRLReal;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE CloseOldSym*;
  (* called only if OldSym previously returned done = TRUE *)
  BEGIN
    CloseFile(symFileNum);
  END CloseOldSym;

(*----------------------------------------------------------------------------*)
  PROCEDURE OldSym*(VAR modName: Name; self: BOOLEAN; VAR done:BOOLEAN);
  (* open file in read mode *)
  VAR 
    tag:LONGINT;
    txt:ARRAY 100 OF CHAR;
    res:INTEGER;
    ch:CHAR;
  BEGIN 
    OpenFile(symFileNum, modName, res);
    symPos:=maxSymLen; 
    symLen:=maxSymLen;
    IF res=0 THEN
      SymRLInt(tag);
      IF tag # SF_TAG THEN 
        IF ~self THEN Err(E.INCORRECT_SYM_FILE) END; (* overwrite old incorrect symbol file of self *)
        CloseOldSym; 
        res:=E.INCORRECT_SYM_FILE;
      ELSE
        SymRLInt(tag);
        IF tag # SF_VERSION_TAG THEN 
          IF ~self THEN Err(E.WRONG_SYM_FILE_FORMAT) END; (* overwrite old incorrect symbol file of self *)
          CloseOldSym; 
          res:=E.WRONG_SYM_FILE_FORMAT;
        END
      END
    ELSIF ~self THEN  (* for self the sym file can not be found *)
      txt:="symbol file for module ";
      String.Append(txt,modName);
      CommentedErr(res,txt); 
    END;
    symFilesEqual:=self & (res=0);
    IF symFilesEqual THEN 
      SymRCh(ch);
      SymRLInt(symFileKey);
    END;
    done:=(res=0) OR self;
  END OldSym;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE eofSF*(): BOOLEAN;
  (* = TRUE if end of old file reached *)
  BEGIN 
    RETURN (symPos = symLen) & (symLen < maxSymLen);
  END eofSF;
  
(*============================ W R I T E   S Y M B O L   F I L E =============*)

  PROCEDURE SymWCh*(ch: CHAR);
    VAR ch1: CHAR;
  BEGIN
    IF symFilesEqual THEN SymRCh(ch1);
      IF ch1 # ch THEN symFilesEqual:=FALSE END
    END;
    tmpBuf[tmpLen]:=ch;
    INC(tmpLen);
    IF tmpLen >= maxTmpLen THEN
      WriteBytes(tmpFileNum, tmpBuf, tmpLen);
      tmpLen:=0
    END;
  END SymWCh;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWTag*(k: INTEGER);
  BEGIN 
    SymWCh(CHR(k))
  END SymWTag;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWBytes(VAR x: ARRAY OF SYSTEM.BYTE; len: INTEGER);
    VAR i: INTEGER;
  BEGIN i:=0;
    WHILE i < len DO SymWCh(SYSTEM.VAL(CHAR, x[i])); INC(i) END
  END SymWBytes;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWInt*(k: LONGINT);
    VAR j: INTEGER;
  BEGIN j:=SHORT(k);    
    SymWBytes(j, IntSize);
  END SymWInt;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWLInt*(k: LONGINT);
  BEGIN 
    SymWBytes(k, LIntSize);
  END SymWLInt;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWSet*(s: SET);
  BEGIN 
    SymWBytes(s, SetSize)
  END SymWSet;

(*----------------------------------------------------------------------------*)
  PROCEDURE SymWReal*(r: REAL);
  BEGIN 
    SymWBytes(r, RealSize)
  END SymWReal;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE SymWLReal*(lr: LONGREAL);
  BEGIN 
    SymWBytes(lr, LRealSize)
  END SymWLReal;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE RegisterNewSym*(VAR modName: Name);
  (* delete possibly already existing file with same name, register new created file *)
  VAR
    res:INTEGER;
    txt:ARRAY 100 OF CHAR;
  BEGIN 
    IF tmpLen > 0 THEN
      WriteBytes(tmpFileNum, tmpBuf, tmpLen);
      tmpLen:=0
    END;
    StoreNewSymFile(modName,res);
    IF res#0 THEN
      txt:="new symbol file for module ";
      String.Append(txt,modName);
      CommentedErr(res,txt);
    END;
  END RegisterNewSym;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE DeleteNewSym*;
  (* delete new created file, don't touch possibly already existing file with same name *)
  END DeleteNewSym;

(*----------------------------------------------------------------------------*)
  PROCEDURE NewSym*(VAR modName: Name; VAR done: BOOLEAN);
  (* open new file in write mode, don't touch possibly already existing file with same name *)
  VAR
    res:INTEGER;
    txt:ARRAY 100 OF CHAR;
  BEGIN
    CreateFile(tmpFileNum, modName, res); 
    tmpLen:=0;
    IF res=0 THEN 
      SymWLInt(SF_TAG);
      SymWLInt(SF_VERSION_TAG);
    ELSE
      txt:="symbol file for module ";
      String.Append(txt,modName);
      CommentedErr(res,txt);
    END;
    done:=res=0;
  END NewSym;

(*----------------------------------------------------------------------------*)
  PROCEDURE EqualSym*(VAR oldkey: LONGINT): BOOLEAN;
  (* compare old and new Symbol File, close old file, return TRUE if equal *)
  BEGIN
    oldkey:=symFileKey;
    symFilesEqual:=symFilesEqual & eofSF();
    CloseOldSym;
    RETURN symFilesEqual
  END EqualSym;

(*============================ W R I T E   E X P O R T - F I L E =============*)

  PROCEDURE WriteExpChar*(ch: CHAR);
  BEGIN
    objBuf[expLen]:=ch;
    INC(expLen);
    IF expLen >= maxExpLen THEN
      WriteBytes(expFileNum, objBuf, expLen);
      expLen:=0;
    END
  END WriteExpChar;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpLn*;
  BEGIN
    WriteExpChar(0DX); WriteExpChar(0AX)
  END WriteExpLn;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpString*(s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN
    i:=0;
    WHILE s[i] # 0X DO WriteExpChar(s[i]); INC(i) END
  END WriteExpString;
  
(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpInt*(i, base: LONGINT);
    VAR first: BOOLEAN;
    PROCEDURE WriteDigit(i: LONGINT);
      VAR h: LONGINT;
    BEGIN
      IF i # 0 THEN
        WriteDigit(i DIV base);
        h:=i MOD base;
        IF h >= 10 THEN
          IF first THEN WriteExpChar("0") END;
          WriteExpChar(CHR(ORD('A') + h - 10))
        ELSE
          WriteExpChar(CHR(ORD('0') + h))
        END;
        first:=FALSE;
      END
    END WriteDigit;
  BEGIN
    first:=FALSE;
    IF i > 0 THEN WriteDigit(i)
    ELSIF i = 0 THEN WriteExpChar("0")
    ELSIF i = MinLInt THEN
      IF base = 16 THEN
        WriteExpString("80000000")
      ELSE
        WriteExpString("-2147483648");
      END
    ELSE WriteExpChar("-"); WriteDigit(-i)
    END
  END WriteExpInt;

(*----------------------------------------------------------------------------*)
  PROCEDURE WriteExpReal*(x: LONGREAL; long: BOOLEAN);
    VAR e, n: INTEGER; x0: LONGREAL; d: ARRAY 16 OF CHAR;

    PROCEDURE Expo(x: LONGREAL): INTEGER;
      TYPE R = RECORD l, h: LONGINT END;
      VAR r: R;
    BEGIN r:=SYSTEM.VAL(R, x);
      RETURN SHORT((r.h DIV (1024 * 1024)) MOD 2048)
    END Expo;
    
    PROCEDURE Ten(e: INTEGER): LONGREAL;
      VAR r, f: LONGREAL;
    BEGIN r:=1.0D0; f:=10.0D0;
      LOOP
        IF ODD(e) THEN r:=r * f END;
        e:=e DIV 2;
        IF e = 0 THEN EXIT END;
        f:=f * f
      END;
      RETURN r
    END Ten;
    
    PROCEDURE Convert(x: LONGREAL; n: INTEGER; VAR d: ARRAY OF CHAR);
      VAR i: INTEGER; l: LONGINT;
    BEGIN l:=ENTIER(x);
      FOR i:=0 TO n - 1 DO d[i]:=CHR(l MOD 10 + 30H); l:=l DIV 10 END; 
    END Convert;
    
  BEGIN
    e:=Expo(x);
    IF e = 0 THEN
      WriteExpChar("0")
    ELSIF e = 2047 THEN
      WriteExpString("NaN")
    ELSE
      IF x < 0 THEN WriteExpChar("-"); x:=-x END;
      e:=SHORT(LONG(e - 1023) * 77 DIV 256);
      IF e >= 0 THEN x:=x / Ten(e) ELSE x:=Ten(-e) * x END;
      IF x >= 10.0D0 THEN x:=x * 0.1D0; INC(e) END;
      n:=8; x0:=Ten(n - 1); x:=x * x0 + 0.5D0;
      IF x >= 10.0D0 * x0 THEN x:=x * 0.1D0; INC(e) END;
      Convert(x, n, d);
      DEC(n); WriteExpChar(d[n]); WriteExpChar(".");
      REPEAT DEC(n); WriteExpChar(d[n]) UNTIL n = 0;
      IF long THEN WriteExpChar("D") ELSE WriteExpChar("E") END;
      IF e < 0 THEN WriteExpChar("-"); e:=-e ELSE WriteExpChar("+") END;
      IF long THEN WriteExpChar(CHR(e DIV 100 + 30H)); e:=e MOD 100 END;
      WriteExpChar(CHR(e DIV 10 + 30H));
      WriteExpChar(CHR(e MOD 10 + 30H))
    END
  END WriteExpReal;

(*----------------------------------------------------------------------------*)
  PROCEDURE OpenExpFile*(VAR modName: Name; VAR done: BOOLEAN);
  VAR
    res:INTEGER;
    txt:ARRAY 100 OF CHAR;
  BEGIN
    CreateFile(expFileNum, modName, res); 
    expLen:=0;
    IF res#0 THEN 
      txt:="export file for module ";
      String.Append(txt,modName);
      CommentedErr(res,txt); 
    END;
    done:=res=0;
  END OpenExpFile;

(*----------------------------------------------------------------------------*)
  PROCEDURE CloseExpFile*;
  BEGIN
    IF expLen > 0 THEN
      WriteBytes(expFileNum, objBuf, expLen);
      expLen:=0
    END;
    CloseFile(expFileNum);
  END CloseExpFile;
  
(*!L+*)
(*============================ L I C E N S E =================================*)

  PROCEDURE XOR(a, b: LONGINT): LONGINT;
  BEGIN
    RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, a) / SYSTEM.VAL(SET, b))
  END XOR;

(*----------------------------------------------------------------------------*)
  PROCEDURE Long(a: INTEGER): LONGINT;
  BEGIN
    IF a < 0 THEN RETURN addMod + a
    ELSE RETURN a
    END
  END Long;

(*----------------------------------------------------------------------------*)
  PROCEDURE Short(a: LONGINT): INTEGER;
  BEGIN
    a:=a MOD addMod;
    IF a > MAX(INTEGER) THEN RETURN SHORT(a - addMod)
    ELSE RETURN SHORT(a)
    END
  END Short;

(*----------------------------------------------------------------------------*)
  PROCEDURE CryptData(VAR dataIn: Data; VAR key: Key; VAR dataOut: Data);
    VAR x0, x1, x2, x3, t0, t1, round, pos: LONGINT;

    PROCEDURE Mul(a, b: LONGINT): LONGINT;
      CONST max = 8000H;
      PROCEDURE Mod(x: LONGINT): LONGINT;
        VAR t: LONGINT;
      BEGIN
        t:=x DIV addMod; x:=x MOD addMod;
        IF x < t THEN INC(x, mulMod) END;
        RETURN x - t
      END Mod;
    BEGIN
      a:=a MOD addMod;
      IF a = 0 THEN RETURN mulMod - b END;
      IF b = 0 THEN RETURN mulMod - a END;
      IF (a > max) & (b > max) THEN
        DEC(a, max); DEC(b, max);
        RETURN Mod(Mod((a + b) * max) + a * b + 49153)
      ELSE
        RETURN Mod(a * b)
      END
    END Mul;

  BEGIN
    x0:=Long(dataIn[0]); x1:=Long(dataIn[1]);
    x2:=Long(dataIn[2]); x3:=Long(dataIn[3]);
    round:=nofRound; pos:=0;
    WHILE round > 0 DO DEC(round);
      x0:=Mul(x0, Long(key[pos])); INC(pos);
      INC(x1, Long(key[pos])); INC(pos);
      INC(x2, Long(key[pos])); INC(pos);
      x3:=Mul(x3, Long(key[pos])); INC(pos);
      t0:=Mul(XOR(x0, x2), Long(key[pos])); INC(pos);
      t1:=Mul(XOR(x1, x3) + t0, Long(key[pos])); INC(pos);
      INC(t0, t1); x0:=XOR(x0, t1); x3:=XOR(x3, t0);
      t0:=XOR(t0, x1); x1:=XOR(x2, t1); x2:=t0;
    END;
    dataOut[0]:=Short(Mul(x0, Long(key[pos]))); INC(pos);
    dataOut[1]:=Short(x2 + Long(key[pos])); INC(pos);
    dataOut[2]:=Short(x1 + Long(key[pos])); INC(pos);
    dataOut[3]:=Short(Mul(x3, Long(key[pos])));
    x0:=0; x1:=0; x2:=0; x3:=0; t0:=0; t1:=0;
  END CryptData;

(*----------------------------------------------------------------------------*)
  PROCEDURE ExpandUserKey(VAR userKey: UserKey; VAR key: Key);
  VAR i: LONGINT;
  BEGIN
    FOR i:=0 TO userKeyLen - 1 DO key[i]:=userKey[i] END;
    FOR i:=userKeyLen TO keyLen - 1 DO
      IF i MOD 8 < 6 THEN
        key[i]:=Short((Long(key[i - 7]) MOD 128) * 512 + Long(key[i - 6]) DIV 128)
      ELSIF i MOD 8 = 6 THEN
        key[i]:=Short((Long(key[i - 7]) MOD 128) * 512 + Long(key[i - 14]) DIV 128)
      ELSE
        key[i]:=Short((Long(key[i - 15]) MOD 128) * 512 + Long(key[i - 14]) DIV 128)
      END
    END
  END ExpandUserKey;
  
(*-----------------------------------------------------------------------------*)
  PROCEDURE XorData(VAR data1, data2: Data);
    VAR i: LONGINT;
  BEGIN
    FOR i:=0 TO dataLen - 1 DO
      data1[i]:=Short(XOR(Long(data1[i]), Long(data2[i])))
    END
  END XorData;

(*-----------------------------------------------------------------------------*)
  PROCEDURE Init2*;
    VAR uk: UserKey; key: Key; i: LONGINT;
  BEGIN
    uk[0]:=0FC7H; uk[1]:=1143H; uk[2]:=147AH; uk[3]:=2649H;
    uk[4]:=7310H; uk[5]:=71A4H; uk[6]:=5B2DH; uk[7]:=77E7H;
    ExpandUserKey(uk, key);
    FOR i:=0 TO dataLen - 1 DO data2[i]:=SHORT(i) + 7 END;
    FOR i:=0 TO licUserNameBlkLen - 1 DO
      XorData(data2, license.licUserNameBlk[i]);
      CryptData(data2, key, data2);
    END;
    XorData(data2, license.licCodeBlk);
    CryptData(data2, key, data2);
    FOR i:=0 TO userKeyLen - 1 DO uk[i]:=0 END;
    FOR i:=0 TO keyLen - 1 DO key[i]:=0 END;
  END Init2;

(*-----------------------------------------------------------------------------*)
  PROCEDURE Init1*;
    VAR uk: UserKey; key: Key; i: LONGINT;
  BEGIN
    uk[0]:=0A83H; uk[1]:=51D6H; uk[2]:=0432H; uk[3]:=0806H;
    uk[4]:=0698H; uk[5]:=27EFH; uk[6]:=7B08H; uk[7]:=64A6H;
    ExpandUserKey(uk, key);
    CryptData(data2, key, data1);
    FOR i:=0 TO userKeyLen - 1 DO uk[i]:=0 END;
    FOR i:=0 TO keyLen - 1 DO key[i]:=0 END;
  END Init1;

(*!L+*) 
(*============================ L I C E N S E =================================*)

  PROCEDURE Check1*():BOOLEAN;
    VAR uk: UserKey; key: Key; data: Data; i: LONGINT; ok: BOOLEAN;
  BEGIN
    uk[0]:=0A83H; uk[1]:=51D6H; uk[2]:=0432H; uk[3]:=0806H;
    uk[4]:=0698H; uk[5]:=27EFH; uk[6]:=7B08H; uk[7]:=64A6H;
    ExpandUserKey(uk, key);
    CryptData(data2, key, data);
    ok:=TRUE;
    FOR i:=0 TO dataLen - 1 DO ok:=ok & (data[i] = data1[i]) END;
    IF ok THEN
      uk[0]:=0FC7H; uk[1]:=1143H; uk[2]:=147AH; uk[3]:=2649H;
      uk[4]:=7310H; uk[5]:=71A4H; uk[6]:=5B2DH; uk[7]:=77E7H;
      ExpandUserKey(uk, key);
      FOR i:=0 TO dataLen - 1 DO data[i]:=SHORT(i) + 7 END;
      FOR i:=0 TO licUserNameBlkLen - 1 DO
        XorData(data, license.licUserNameBlk[i]);
        CryptData(data, key, data);
      END;
      XorData(data, license.licCodeBlk);
      CryptData(data, key, data);
      FOR i:=0 TO dataLen - 1 DO ok:=ok & (data[i] = data2[i]) END;
    END;
    FOR i:=0 TO userKeyLen - 1 DO uk[i]:=0 END;
    FOR i:=0 TO keyLen - 1 DO key[i]:=0 END;
    FOR i:=0 TO dataLen - 1 DO data[i]:=0 END;
    RETURN ~ok
  END Check1;

(*!L-*)
(*============================================================================*)
BEGIN
  pat:=MinRealPat;
  SYSTEM.MOVE(SYSTEM.ADR(pat), SYSTEM.ADR(MinReal), 4);
  

  pat:=MaxRealPat;
  SYSTEM.MOVE(SYSTEM.ADR(pat), SYSTEM.ADR(MaxReal), 4);

  LRealPat.L:=MinLRealPatL;
  LRealPat.H:=MinLRealPatH;
  SYSTEM.MOVE(SYSTEM.ADR(LRealPat), SYSTEM.ADR(MinLReal), 8);

  LRealPat.L:=MaxLRealPatL;
  LRealPat.H:=MaxLRealPatH;
  SYSTEM.MOVE(SYSTEM.ADR(LRealPat), SYSTEM.ADR(MaxLReal), 8);

END OPM.
