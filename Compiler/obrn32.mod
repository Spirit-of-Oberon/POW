(******************************************************************************)
(*                                                                            *)
(**)                        MODULE Obrn32;                                  (**)
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
(* PURPOSE:  Main module of the compiler                                      *)
(*                                                                            *)
(******************************************************************************)

         
IMPORT W:=Win32,SYSTEM,Compiler:=Comp32,E:=Error,S:=String,OPM;
                        
CONST srcFileNum=0;
      symFileNum=1;
      tmpFileNum=2;
      objFileNum=3;
      expFileNum=4;
      licFileNum=5;
      nofFile=6;
      MAXPATHLENGTH=256;

TYPE String= ARRAY 256 OF CHAR;
     ErrProc= PROCEDURE [_APICALL] (num,line,col:LONGINT;warn:BOOLEAN;VAR txt:ARRAY OF CHAR);
     CompErrProc= PROCEDURE [_APICALL] (num,line,col:LONGINT;warn:BOOLEAN;txt:W.LPSTR);
     DepProc= PROCEDURE [_APICALL] (mod:W.LPSTR);
     FirstProc= PROCEDURE [_APICALL] (wnd:W.HWND;buf,size:LONGINT): LONGINT;
     NextProc= PROCEDURE [_APICALL] (wnd:W.HWND;buf,size:LONGINT): LONGINT;
     OpenProc= PROCEDURE [_APICALL] (fileName:LONGINT): INTEGER;
     ReadProc= PROCEDURE [_APICALL] (handle:W.HANDLE; buf,size:LONGINT): LONGINT;
     CloseProc= PROCEDURE [_APICALL] (handle:W.HANDLE);
     CompParam= RECORD [_NOTALIGNED]
                  fileName: ARRAY [_NOTALIGNED] MAXPATHLENGTH OF CHAR;
                  tmpName: ARRAY [_NOTALIGNED] MAXPATHLENGTH OF CHAR;
                  objDir: ARRAY [_NOTALIGNED] MAXPATHLENGTH OF CHAR;
                  objName: ARRAY [_NOTALIGNED] MAXPATHLENGTH OF CHAR;
                  licName: ARRAY [_NOTALIGNED] MAXPATHLENGTH OF CHAR;
                  symDirs: ARRAY [_NOTALIGNED] MAXPATHLENGTH*4 OF CHAR;
                  fromWnd: W.HWND;
                  firstProc: FirstProc;
                  nextProc: NextProc;
                  openProc: OpenProc;
                  readProc: ReadProc;
                  closeProc: CloseProc;
                  options: SET;
                  errorProc: CompErrProc;
                  dependProc: DepProc;
                END; 

VAR 
  parameter: Compiler.Parameter; 
  hInst: W.HANDLE;
  fileDesc: ARRAY nofFile OF W.HANDLE;
  fileOpen: ARRAY nofFile OF BOOLEAN;
  srcRead: LONGINT;
  comp: CompParam;
  newSymbols: LONGINT;
  dummy: INTEGER;

PROCEDURE WriteLog* (ch:CHAR);
BEGIN
END WriteLog;

PROCEDURE WriteLogLn*;
BEGIN
END WriteLogLn;

PROCEDURE MakeFileName (fileNum:INTEGER; VAR modName,filName:ARRAY OF CHAR);
VAR 
  module: String;
BEGIN
  COPY(modName,module);
  CASE fileNum OF
    srcFileNum: COPY(comp.fileName,filName);
  | objFileNum: COPY(comp.objName,filName);
  | symFileNum: COPY(comp.objDir,filName);
                S.Append(filName,module);
                S.Append(filName,".sym");
  | tmpFileNum: COPY(comp.tmpName,filName);
  | licFileNum: COPY(comp.licName,filName);
  ELSE
  END;
END MakeFileName;

PROCEDURE Error* (errorNum,lineNum,charNum:INTEGER;warn:BOOLEAN;VAR txt:ARRAY OF CHAR);
BEGIN
  comp.errorProc(errorNum,lineNum,charNum,warn,SYSTEM.ADR(txt));
END Error;

PROCEDURE SeekFile*(fileNum:INTEGER; pos:LONGINT);
VAR
  dummy:LONGINT;
BEGIN
  ASSERT(fileNum#srcFileNum);
  IF fileOpen[fileNum] THEN
    dummy:=W.SetFilePointer(fileDesc[fileNum],pos,0,W.FILE_BEGIN);
  END;
END SeekFile;

PROCEDURE FilePos*(fileNum:INTEGER):LONGINT;
BEGIN
  ASSERT(fileNum#srcFileNum);
  IF fileOpen[fileNum] THEN
    RETURN W.SetFilePointer(fileDesc[fileNum],0,0,W.FILE_CURRENT);
  ELSE
    RETURN -1;
  END;
END FilePos;

PROCEDURE CloseFile* (fileNum:INTEGER);
VAR 
  h: W.BOOL;
BEGIN
  IF fileOpen[fileNum] THEN
    IF fileNum=srcFileNum THEN
      IF comp.fromWnd=0 THEN
        comp.closeProc(fileDesc[srcFileNum]);
      END;
    ELSE
      h:=W.CloseHandle(fileDesc[fileNum]);
    END;
    fileOpen[fileNum]:=FALSE;
  END;
END CloseFile;

PROCEDURE HelpOpenFile(name:ARRAY OF CHAR; access: LONGINT; creation: LONGINT; VAR handle:W.HANDLE; VAR res:INTEGER);
(*VAR
  ofstr:W.OFSTRUCT;*)
VAR error: LONGINT;
BEGIN
(*  ofstr.cBytes:=CHR(SIZE(W.OFSTRUCT));
  handle:=W.OpenFile(SYSTEM.ADR(name),ofstr,flags);*)
  handle := W.CreateFileA(
            SYSTEM.ADR(name),
            access, 
            SYSTEM.BITOR(W.FILE_SHARE_READ, W.FILE_SHARE_WRITE),
            NIL,
            creation,
            W.FILE_ATTRIBUTE_NORMAL,
            W.NULL);

  IF handle=W.INVALID_HANDLE_VALUE THEN
    error := W.GetLastError();
    CASE error OF
        2: res := E.FILE_NOT_FOUND;
    |   3: res := E.PATH_NOT_FOUND;
    |   4: res := E.TOO_MANY_OPEN_FILES;
    |   5: res := E.ACCESS_DENIED;
    | 13H: res := E.WRITE_PROTECTED;
    | 20H: res := E.SHARING_VIOLATION;
    | 41H: res := E.NETWORK_ACCESS_DENIED;
    ELSE
      res := E.UNEXPECTED_FILE_ERROR;
    END;
  ELSE 
    res:=0;
  END; 
END HelpOpenFile;


PROCEDURE CreateFile*(fileNum: INTEGER; VAR modName: Compiler.ModName; VAR res: INTEGER);
VAR 
  fileName: String;
BEGIN
  IF fileOpen[fileNum] THEN CloseFile(fileNum) END;
  MakeFileName(fileNum,modName,fileName);
  (* Do not use GENERIC_WRITE with GENERIC_READ: It seems Windows NT sets a wrong last write time for files created with these flags on a file server. *)
  HelpOpenFile(fileName, W.GENERIC_WRITE, W.CREATE_ALWAYS, (*SYSTEM.BITOR(W.OF_CREATE,W.OF_READWRITE),*)fileDesc[fileNum], res);
  fileOpen[fileNum]:=res=0;
END CreateFile;


PROCEDURE OpenFile* (fileNum:INTEGER; VAR modName:Compiler.ModName; VAR res:INTEGER);
VAR 
  fileName,dir,module: String;
  i,s: INTEGER;
BEGIN                  
  COPY(modName,module);
  MakeFileName(fileNum,modName,fileName);
  IF (fileNum#srcFileNum) OR (comp.fromWnd=0) THEN
    IF fileOpen[fileNum] THEN CloseFile(fileNum) END;
    IF fileNum=srcFileNum THEN
      fileDesc[fileNum]:=comp.openProc(SYSTEM.ADR(fileName));
      IF fileDesc[fileNum]=0 THEN res:=E.UNEXPECTED_FILE_ERROR ELSE res:=0 END; (* !!! *)
    ELSE
      HelpOpenFile(fileName, W.GENERIC_READ, W.OPEN_EXISTING, (*W.OF_READ,*) fileDesc[fileNum], res);
    END;
    IF (res#0) & (fileNum=symFileNum) THEN 
      i:=0;
      WHILE (res#0) & (comp.symDirs[i]#1X) DO
        s:=0;
        WHILE comp.symDirs[i]#0X DO 
          dir[s]:=comp.symDirs[i];
          s:=s+1;
          i:=i+1; 
        END;     
        IF s>0 THEN
          dir[s]:=0X;
          S.Append(dir,module);
          S.Append(dir,".sym");
          HelpOpenFile(dir, W.GENERIC_READ, W.OPEN_EXISTING, (*W.OF_READ,*) fileDesc[fileNum], res);
        END;
        i:=i+1;
      END;
    END;
    fileOpen[fileNum]:=res=0;
  ELSE
    fileOpen[fileNum]:=FALSE;
    res:=0;
  END;
END OpenFile;

PROCEDURE ReadBytes* (fileNum:INTEGER; VAR x:ARRAY OF SYSTEM.BYTE; VAR n:LONGINT);
VAR 
  f: W.HANDLE;
  ret: W.UINT;
  i: INTEGER;
  len,oldn,newn: LONGINT;
  hwnd: W.HWND;
  dummy:W.BOOL;
BEGIN
  IF fileNum=srcFileNum THEN
    IF comp.fromWnd=0 THEN
      (*read source from file*)
      n:=comp.readProc(fileDesc[fileNum],SYSTEM.ADR(x),SHORT(n))
    ELSE
      (*read source from edit-window*)
      IF srcRead=0 THEN
        oldn:=n;
        hwnd:=W.GetWindow(comp.fromWnd,W.GW_CHILD);
        ASSERT(n<32000);
        newn:=n;
        newn:=comp.firstProc(comp.fromWnd,SYSTEM.ADR(x),n);
        ASSERT(n=oldn);
        n:=newn;
        ASSERT(n<32000);
      ELSE
        n:=comp.nextProc(comp.fromWnd,SYSTEM.ADR(x),SHORT(n));
      END;
    END;
    INC(srcRead,n);
  ELSE
    dummy:=W.ReadFile(fileDesc[fileNum],SYSTEM.ADR(x),n,n,NIL);
  END;
END ReadBytes;

PROCEDURE WriteBytes* (fileNum:INTEGER; VAR x:ARRAY OF SYSTEM.BYTE; n:LONGINT);
VAR
  dummy:W.BOOL;
BEGIN
  ASSERT(fileNum>=0);
  ASSERT(fileNum<=5);
  dummy:=W.WriteFile(fileDesc[fileNum],SYSTEM.ADR(x),n,n,NIL);
END WriteBytes;


PROCEDURE StoreNewSymFile* (VAR modName: Compiler.ModName; VAR res:INTEGER);
CONST 
  bufLen= 1024;
VAR 
  h: INTEGER;
  l,len: LONGINT;
  done: BOOLEAN;
  buffer: ARRAY bufLen OF CHAR;
BEGIN
  newSymbols:=1;
  CloseFile(tmpFileNum);
  OpenFile(tmpFileNum, modName, res);
  CreateFile(symFileNum, modName, res);
  IF res=0 THEN
    l:=W.SetFilePointer(fileDesc[tmpFileNum],0,0,W.FILE_BEGIN);
    REPEAT
      len:=bufLen;
      ReadBytes(tmpFileNum,buffer,len);
      IF len>0 THEN WriteBytes(symFileNum,buffer,len) END;
    UNTIL len#bufLen;
  END;
  CloseFile(symFileNum);
  CloseFile(tmpFileNum);
END StoreNewSymFile;


PROCEDURE ImportedModule* (VAR modName:Compiler.ModName);
BEGIN
  comp.dependProc(SYSTEM.ADR(modName));
END ImportedModule;

PROCEDURE NewKey* (): INTEGER;
BEGIN
  RETURN SHORT(W.GetTickCount() MOD MAX(INTEGER));
END NewKey;

PROCEDURE [_APICALL] Oberon2* (p:LONGINT): INTEGER;
TYPE 
  CP= POINTER TO CompParam;
VAR 
  h,modName: Compiler.ModName;
  filName,srcFileName,objFileName: String;
  done: BOOLEAN;
  res:INTEGER;
  i,j: INTEGER;
  c: CP;
  dmyB: W.BOOL;
BEGIN
  newSymbols:=0;
  srcRead:=0;
  c:=SYSTEM.VAL(CP,p);
  FOR i:=srcFileNum TO objFileNum DO fileOpen[i]:=FALSE; END;
  comp:=c^;
  parameter.options:=comp.options;
  COPY(comp.fileName,filName);
  OPM.SetSourceFile(comp.fileName);
  i:=0;
  j:=0;
  WHILE comp.fileName[i]#0X DO 
    IF comp.fileName[i]="\" THEN
      j:=i+1;
    END;
    i:=i+1;
  END;
  i:=0;
  WHILE comp.fileName[j]#0X DO
    modName[i]:=comp.fileName[j];
    i:=i+1;
    j:=j+1;
  END;
  modName[i]:=0X;

  COPY(modName,h);
  MakeFileName(srcFileNum,h,srcFileName);
  MakeFileName(objFileNum,h,objFileName);
  OpenFile(srcFileNum,modName,res);
  IF res=0 THEN
    Compiler.Compile(srcFileName,objFileName,parameter,modName,done);
  END;
  FOR i:=srcFileNum TO objFileNum DO CloseFile(i); END;
  RETURN SHORT(newSymbols);
END Oberon2;

PROCEDURE [_APICALL] GetCompilerVersion* (p:W.LPSTR);
VAR 
  vers: ARRAY 20 OF CHAR;
BEGIN
  vers:=Compiler.version;
  SYSTEM.MOVE(SYSTEM.ADR(vers),SYSTEM.VAL(LONGINT,p),LEN(vers));
END GetCompilerVersion;

PROCEDURE [_APICALL] DllEntryPoint*(hDLL:W.HANDLE; 
                                    dwReason:W.DWORD; 
                                    lpReserved:W.LPVOID):W.BOOL;
VAR
  res:LONGINT;
BEGIN
  
  IF dwReason=W.DLL_PROCESS_ATTACH THEN
    parameter.CreateFile:=CreateFile;
    parameter.OpenFile:=OpenFile;
    parameter.ReadBytes:=ReadBytes;
    parameter.WriteBytes:=WriteBytes;
    parameter.CloseFile:=CloseFile;
    parameter.StoreNewSymFile:=StoreNewSymFile;
    parameter.ImportedModule:=ImportedModule;
    parameter.NewKey:=NewKey;
    parameter.LogWrite:=WriteLog;
    parameter.LogWriteLn:=WriteLogLn;
    parameter.Error:=Error;
    parameter.SeekFile:=SeekFile;
    parameter.FilePos:=FilePos;
  ELSIF dwReason=W.DLL_PROCESS_DETACH THEN
  END;
  RETURN 1;
END DllEntryPoint;                                            

END Obrn32.
