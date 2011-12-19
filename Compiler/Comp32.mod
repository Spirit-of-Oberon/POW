(******************************************************************************)
(*                                                                            *)
(**)                        MODULE Comp32;                                  (**)
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
(* PURPOSE: Main program of Oberon2 compiler DLL                              *)
(*                                                                            *)
(******************************************************************************)

(*
  changes marked with
  
  RTTI : run time type information extension 23.2.1996
*)
  IMPORT
    OPP, OPB, OPV, OPT, OPS, OPC, OPL, OPM, RTSOberon,
    E:=Error, CB:=OPC_Base, WriteObj, Coff, Debug, DebugInfo;

  TYPE
    ModName* = OPM.Name;
    Parameter* = RECORD
      options*: SET;
      CreateFile*: OPM.CreateFileProc;
      OpenFile*: OPM.OpenFileProc;
      ReadBytes*: OPM.ReadBytesProc;
      WriteBytes*: OPM.WriteBytesProc;
      SeekFile*: OPM.SeekFileProc;
      FilePos*:OPM.FilePosProc;
      CloseFile*: OPM.CloseFileProc;
      StoreNewSymFile*: OPM.StoreNewSymFileProc;
      ImportedModule*: OPM.ImportedModuleProc;
      NewKey*: OPM.NewKeyProc;
      LogWrite*: OPM.LogWriteProc;
      LogWriteLn*: OPM.LogWriteLnProc;
      Error*: OPM.ErrorProc;
    END;

  CONST
    version* = OPM.version;

    SignOnMessage0 = "Oberon-2 for Windows V";
    SignOnMessage1 = "Copyright (c) 1998 by";
    SignOnMessage2 = "  Robinson Associates";
    SignOnMessage3 = "Licensed for";

    (* compiler options: *)
    indexCheck* = CB.indexCheck;       (* index check on *)
    overflowCheck* = CB.overflowCheck; (* overflow check on *)
    rangeCheck* = CB.rangeCheck;       (* range check on *)
    typeCheck* = CB.typeCheck;         (* type check on *)
    nilCheck* = CB.nilCheck;           (* NIL check on *)
    newSymFile* = CB.newSymFile;       (* generation of new symbol file allowed *)
    pointerInit* = CB.pointerInit;     (* pointer initialization *)
    assertEval* = CB.assertEval;       (* assert evaluation on *)
    debugInfo* = CB.debugInfo;         (* add debug informations to object file *)
    listImport* = CB.listImport;       (* reports all imported modules *)
    browseSymFile* = CB.browseSymFile; (* reports all exported entities of a module *)
    OPTN_CODEVIEW4*=CB.OPTN_CODEVIEW4;   (* generate CodeView 4.0 debug symbols *)
    OPTN_CODEVIEW5*=CB.OPTN_CODEVIEW5;   (* generate CodeView 5.0 debug symbols *)
    
    (* files *)
    srcFileNum* = 0; symFileNum* = 1; tmpFileNum* = 2; objFileNum* = 3;
    expFileNum* = 4; licFileNum* = 5;

    (*symbol values*)
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
    definition = 65; windows = 66; (*!*)

  VAR
    first: BOOLEAN;

(*----------------------------------------------------------------------------*)
  PROCEDURE Compile*(VAR srcFileName:ARRAY OF CHAR;
                     VAR objFileName:ARRAY OF CHAR;
                     VAR parameter: Parameter; 
                     VAR ownModName: ModName;
                     VAR done: BOOLEAN);
  VAR
    p: OPT.Node;
    key: LONGINT;
    impName, modName, noName: OPS.Name;
    newSF: BOOLEAN;
    sym: SHORTINT;
    
    PROCEDURE IsFileNameOK():BOOLEAN;
    VAR
      i,j:INTEGER;
    BEGIN
      i:=0;
      WHILE srcFileName[i]#0X DO INC(i) END;
      WHILE (i>=0) & (srcFileName[i]#"\") DO DEC(i) END;
      INC(i);
      j:=0;
      WHILE (CAP(ownModName[j])=CAP(srcFileName[i])) & (ownModName[j]#0X) DO
        INC(i);
        INC(j);
      END;
      RETURN (ownModName[j]=0X) & (srcFileName[i]=".");
    END IsFileNameOK;
    
  BEGIN
    RTSOberon.Mark;
    OPM.CreateFile := parameter.CreateFile;
    OPM.OpenFile := parameter.OpenFile;
    OPM.ReadBytes := parameter.ReadBytes;
    OPM.WriteBytes := parameter.WriteBytes;
    OPM.SeekFile:=parameter.SeekFile;
    OPM.FilePos:=parameter.FilePos;
    OPM.CloseFile := parameter.CloseFile;
    OPM.StoreNewSymFile := parameter.StoreNewSymFile;
    OPM.LogWrite := parameter.LogWrite;
    OPM.LogWriteLn := parameter.LogWriteLn;
    OPM.Error := parameter.Error;

    IF first THEN
      OPM.LogWStr(SignOnMessage0); OPM.LogWStr(version); OPM.LogWLn;
      OPM.LogWStr(SignOnMessage1); OPM.LogWLn;
      OPM.LogWStr(SignOnMessage2); OPM.LogWLn;
      OPM.LogWStr(SignOnMessage3); OPM.LogWLn;
      OPM.ReadLicense; (*!L*)
      OPM.LogWLn;
      first := FALSE
    END;
    OPM.Init(debugInfo IN parameter.options,
             (OPTN_CODEVIEW4 IN parameter.options) OR
             (OPTN_CODEVIEW5 IN parameter.options),
             FALSE); 
    OPS.Init; 
    OPT.Init; 
    OPB.typSize := OPV.TypSize;
    IF listImport IN parameter.options THEN
      OPS.Get(sym);
      IF (sym = module) OR (sym = definition) THEN OPS.Get(sym);
        IF sym = ident THEN COPY(OPS.name, ownModName); OPS.Get(sym);
          IF sym = semicolon THEN OPS.Get(sym);
            IF sym = import THEN OPS.Get(sym);
              LOOP
                IF sym = ident THEN 
                  COPY(OPS.name, impName); 
                  OPS.Get(sym);
                  IF sym = becomes THEN 
                    OPS.Get(sym);
                    IF sym = ident THEN 
                      COPY(OPS.name, impName); 
                      OPS.Get(sym) 
                    ELSE 
                      OPM.Err(ident); 
                      EXIT
                    END
                  END ;
                  IF impName#"" THEN parameter.ImportedModule(impName) END;
                ELSE 
                  OPM.Err(ident); 
                  EXIT
                END ;
                IF sym = comma THEN 
                  OPS.Get(sym)
                ELSIF sym = ident THEN 
                  OPM.Err(comma); 
                  EXIT
                ELSE 
                  EXIT
                END
              END ;
              IF sym # semicolon THEN OPM.Err(semicolon) END
            END ;
          ELSE 
            OPM.Err(semicolon)
          END
        ELSE 
          OPM.Err(ident)
        END
      ELSE 
        OPM.Err(E.MODULE_EXPECTED);
      END
    ELSIF browseSymFile IN parameter.options THEN
      OPM.LogWStr("browsing ");
      OPM.LogWStr(ownModName);
      OPM.LogWLn;
      OPT.OpenScope(0, NIL);
      COPY("@#$", noName);
      OPT.Import(ownModName, ownModName, noName);
      IF OPM.noerr THEN
        OPM.LogWStr("  -> ");
        OPM.LogWStr(OPT.GlbMod[0]^.name);
        OPM.LogWLn;
        OPT.WriteExp
      END;
    ELSE
      OPM.LogWStr("compiling ");
      IF OPTN_CODEVIEW4 IN parameter.options THEN
        DebugInfo.Init(DebugInfo.VERSION_CV4,objFileName);
      ELSIF OPTN_CODEVIEW5 IN parameter.options THEN
        DebugInfo.Init(DebugInfo.VERSION_CV5,objFileName);
      END;
      Coff.Init;
      newSF := newSymFile IN parameter.options;
      OPT.OpenScope(0, NIL);
      OPP.Module(p, modName);
      COPY(modName, ownModName);
      OPM.SetModuleName(modName);
      IF ~IsFileNameOK() THEN 
        OPM.Err(E.WRONG_SRC_FILENAME) 
      ELSE
        IF OPM.noerr THEN
          WriteObj.Init(debugInfo IN parameter.options);
          OPV.AdrAndSize(OPT.topScope);
          OPM.errpos.line:=0;
          OPM.errpos.column:=0;
          key := parameter.NewKey() MOD 1000000H;
          OPT.Export(modName, newSF, key);
          IF newSF THEN OPM.LogWStr("  new symbol file"); OPM.LogWLn END ;
          IF OPM.noerr THEN
            OPC.Init(modName, parameter.options, key);
            OPV.Init(assertEval IN parameter.options, 
                      debugInfo IN parameter.options);
            OPV.Module(p);
            IF OPM.noerr THEN
              WriteObj.OutCode(modName, key);
              IF OPM.noerr THEN 
                OPM.LogWStr("  size = ");
                OPM.LogWNum(OPL.pc, 0); OPM.LogWStr(", ");
                OPM.LogWNum(OPL.constLen, 0); OPM.LogWStr(", ");
                OPM.LogWNum(OPL.dsize, 0); OPM.LogWLn
              END
            END
          END ;
        END ;
      END;
      OPT.CloseScope; OPT.Close;
    END;
    done := OPM.noerr;
    RTSOberon.Release;
  END Compile;

BEGIN
  first := TRUE;
END Comp32.
