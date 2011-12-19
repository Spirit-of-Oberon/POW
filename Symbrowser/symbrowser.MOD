MODULE SymBrowser;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * This is the main module, it implements the user                              *
 * interface to open symfiles.                                                  *
 ********************************************************************************)

IMPORT WD:=WinDef, WU:=WinUser, WB:=WinBase, WC:=CommDlg, SYSTEM, 
       Parse, SymFile, PowDDE, Strings;


(* Replaces the file-extension by .EXP *) 
PROCEDURE ChangeName(VAR PathName, NameOut: ARRAY OF CHAR; lenOfPathName:LONGINT);
VAR
  c,l,i,j:LONGINT;
BEGIN
  l := lenOfPathName-1;
  c := 0;
  IF l > 0 THEN
    i:=l;
    WHILE (i # -1) & (PathName[i] # '\') DO
      IF PathName[i] = '.' THEN
        c := c + 1;
      END;
      i := i - 1;
    END;
    FOR j := i + 1 TO l DO
      NameOut[j-(i+1)] := PathName[j];
    END;
    l := l - i;
    NameOut[l] := CHR(0);
    IF c > 0 THEN
      NameOut[l-1] := 'P';
      NameOut[l-2] := 'X';
      NameOut[l-3] := 'E';
    ELSE
      Strings.Append(NameOut, '.EXP');
    END;
  END;      
END ChangeName;

(* Parses the option strings an extracts the full filename              *)
(* IF an error occurs, the value returned by the function will be FALSE *)
PROCEDURE ParseParams(VAR fileName: ARRAY OF CHAR; param:ARRAY OF CHAR):BOOLEAN;
VAR
  i,n :INTEGER;
BEGIN
  n := 0;
  SymFile.debug := FALSE;
  SymFile.allMod:= FALSE;
  IF param[0]='"' THEN
    i:=1;
    WHILE (param[i] # 0X) & (param[i] # '"') DO INC(i) END; (* skip program name *)
  ELSE
    i:=0;
    WHILE (param[i] # 0X) & (param[i] # " ") DO INC(i) END; (* skip program name *)
  END;
  IF param[i]#0X THEN INC(i) END;
  WHILE (param[i] # CHR(0)) DO
    WHILE (param[i] = CHR(32)) DO
      i := i + 1;
    END;
    IF param[i] = '-' THEN (* optionstring found *)
      i := i + 1;
      WHILE (param[i] # CHR(0)) & ((param[i]= 'a') OR (param[i]='g')) DO
        IF param[i] = 'g' THEN
          SymFile.debug := TRUE;
        END;
        IF param[i] = 'a' THEN
          SymFile.allMod := TRUE;
        END;
        i := i + 1;
      END;
      IF (param[i] # CHR(32)) & (param[i] # CHR(0)) THEN
        RETURN FALSE;
      END;
    END;
    IF (n # 0) & (param[i] # CHR(0)) & (param[i] # CHR(32)) THEN
      RETURN FALSE;
    END;
    WHILE (param[i] # CHR(0)) & (param[i] # CHR(32)) DO
      fileName[n] := param[i];
      i := i + 1;
      n := n + 1;
    END;
  END;
  fileName[n] := CHR(0);          
  RETURN TRUE;
END ParseParams;

PROCEDURE CopyString(VAR d:ARRAY OF CHAR; s:ARRAY OF CHAR);
VAR i:INTEGER;
BEGIN
  i:= 0;
  d[i]:= s[i];
  WHILE d[i] # CHR(0) DO
    i := i + 1;
    d[i] := s[i];
  END;
END CopyString;

PROCEDURE UseFileDialog(VAR name: ARRAY OF CHAR):LONGINT;
VAR
  rec: WC.OPENFILENAME;
  ret: INTEGER;
  filter: ARRAY 40 OF CHAR;
BEGIN
  CopyString(filter, 'Oberon symbolfile_*.SYM');
  filter[17] := CHR(0);
  filter[24] := CHR(0);
  rec.lStructSize       := SIZE(WC.OPENFILENAME);
  rec.hwndOwner         := 0;
  rec.hInstance         := 0;
  rec.lpstrFilter       := SYSTEM.ADR(filter);
  rec.lpstrCustomFilter := 0;
  rec.nFilterIndex      := 0;
  rec.nMaxCustFilter    := 0;
  rec.lpstrFile         := SYSTEM.ADR(name);
  rec.nMaxFile          := 80;
  rec.lpstrFileTitle    := 0;
  rec.nMaxFileTitle     := 0;
  rec.lpstrInitialDir   := 0;
  rec.lpstrTitle        := SYSTEM.ADR('Browser');
  rec.Flags             := WC.OFN_FILEMUSTEXIST;
  rec.nFileOffset       := 0;
  rec.lCustData         := 0;
  rec.lpfnHook          := NIL;
  rec.lpstrDefExt       := SYSTEM.ADR('SYM');
  RETURN WC.GetOpenFileNameA(rec);  
END UseFileDialog;

PROCEDURE [_APICALL] WinMain*(hInstance:WD.HINSTANCE;
                             lpCmdLine:WD.LPSTR; nCmdShow:LONGINT):LONGINT;
VAR
  cmd        : ARRAY 100 OF CHAR;
  adr        : LONGINT;
  paramText  : ARRAY 80 OF CHAR;
  str        : ARRAY 80 OF CHAR;
  ret        : LONGINT;
BEGIN
  ret := 1;
  adr := WB.lstrcpyA(SYSTEM.ADR(cmd), lpCmdLine);
  IF ParseParams(paramText, cmd) THEN
    IF paramText[0] = CHR(0) THEN
      CopyString(paramText, "*.SYM");
      ret := UseFileDialog(paramText);
    END; 
    IF (ret # 0) & PowDDE.CreatePowConnection() THEN
      ChangeName(paramText, str, Strings.Length(paramText));
      Strings.Insert("NewFile ",str,0);
      IF Parse.InitParser(paramText) THEN 
        PowDDE.SendStringToPow(str);
        Parse.PSymFile();
      END;
      PowDDE.DestroyPowConnection();
    ELSE
      IF ret # 0 THEN
        ret := WU.MessageBoxA(0, SYSTEM.ADR('POW-DDE Connection Failed'),
                               SYSTEM.ADR('Browser DDE Error'), WU.MB_OK);
      END;
    END;
  ELSE
    ret := WU.MessageBoxA(0, SYSTEM.ADR('Wrong Parameters'),
                           SYSTEM.ADR('Browser Error'), WU.MB_OK);
  END;  
  RETURN 1;
END WinMain;

END SymBrowser.
