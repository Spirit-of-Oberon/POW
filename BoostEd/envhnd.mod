(******************************************************************************
 *  Module EnvHnd
 *  
 *  This module contains the access procedures to the .INI file
 *  to load and store the settings of the editor options.
 ******************************************************************************)

MODULE EnvHnd;


IMPORT SYSTEM,
       WD:=WinDef, WU:=WinUser, WB:=WinBase, WG:=WinGdi,
       List:=ListSt, Strings, Com:=CommDlg, 
       TWin:=TextWin, Options, Syntax, EWin:=EditWin, GlobWin;


CONST
  SECTION="BoostEd";
  INIFILENAME="BoostEd.INI";


TYPE ARCHAR=ARRAY OF CHAR;
 

PROCEDURE GetIniFileName*(VAR name:ARRAY OF CHAR):BOOLEAN;
(* INI Dateiname liefern *)
VAR 
  buf   : ARRAY 128 OF CHAR;
  len,i : LONGINT;
BEGIN
  len := WB.GetWindowsDirectoryA(SYSTEM.ADR(buf),128); (* Verzeichnis von Windows ermitteln *)
  IF len=0 THEN GlobWin.DisplayError("ERROR","Error in accessing INI-file"); RETURN FALSE END;
  IF buf[len-1]#"\" THEN buf[len]:="\"; buf[len+1]:=0X;END;
  COPY(buf,name);
  Strings.Append(name,INIFILENAME);
  RETURN TRUE;
END GetIniFileName;   


PROCEDURE ReadIniFile*();
(* INI Datei lesen *)
CONST
  BUFLEN=100;
VAR 
  ini  : ARRAY 128 OF CHAR;
  dmyi : LONGINT;
  default,
  buf  : ARRAY 100 OF CHAR;
BEGIN
  IF ~GetIniFileName(ini) THEN RETURN END;
  dmyi:=WB.GetPrivateProfileStringA(SYSTEM.ADR(SECTION),
                                  SYSTEM.ADR("FontName"),
                                  SYSTEM.ADR(Options.FONT_FIXEDSYS),
                                  SYSTEM.ADR(Options.fontName),
                                  Options.FONTNAMELEN,
                                  SYSTEM.ADR(ini));
  dmyi:=WB.GetPrivateProfileStringA(SYSTEM.ADR(SECTION),
                                  SYSTEM.ADR("PrinterFontName"),
                                  SYSTEM.ADR(Options.FONT_COURIERNEW),
                                  SYSTEM.ADR(Options.printerFontName),
                                  Options.FONTNAMELEN,
                                  SYSTEM.ADR(ini));
  Options.autoIndent:=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("AutoIndent"),1,SYSTEM.ADR(ini)));
  Options.tabsize   :=WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("Tabsize"),4,SYSTEM.ADR(ini));
  Options.useTabs   :=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("UseTabs"),1,SYSTEM.ADR(ini)));
  Options.mouse     :=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("Mouse"),0,SYSTEM.ADR(ini)));
  Options.fontSize  :=WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("FontSize"),12,SYSTEM.ADR(ini));
  Options.printerFontSize:=WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrinterFontSize"),10,SYSTEM.ADR(ini));
  Options.syntax    :=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("Oberon2Syntax"),1,SYSTEM.ADR(ini)));
  Options.smartDel  :=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("SmartLineMerge"),1,SYSTEM.ADR(ini)));
  Options.indentWidth:=WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("IndentWidth"),2,SYSTEM.ADR(ini));
  Options.colorComments:=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("ColorComments"),1,SYSTEM.ADR(ini)));
  Options.printMarginLeft   := WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintMarginLeft"),40,SYSTEM.ADR(ini));
  Options.printMarginRight  := WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintMarginRight"),40,SYSTEM.ADR(ini));
  Options.printMarginTop    := WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintMarginTop"),60,SYSTEM.ADR(ini));
  Options.printMarginBottom := WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintMarginBottom"),100,SYSTEM.ADR(ini));
  Options.printDate:=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintDate"),1,SYSTEM.ADR(ini)));
  Options.printLineNumbers:=SYSTEM.VAL(BOOLEAN,WB.GetPrivateProfileIntA(SYSTEM.ADR(SECTION),SYSTEM.ADR("PrintLineNumbers"),1,SYSTEM.ADR(ini)));
  Strings.HexStr(GlobWin.RGB(Options.COMMENT_RED,
                             Options.COMMENT_GREEN,
                             Options.COMMENT_BLUE),default);
  dmyi:=WB.GetPrivateProfileStringA(SYSTEM.ADR(SECTION),
                                  SYSTEM.ADR("CommentColor"),
                                  SYSTEM.ADR(default),
                                  SYSTEM.ADR(buf),
                                  BUFLEN,
                                  SYSTEM.ADR(ini));
  Options.commentColor:=Strings.Val(buf);
END ReadIniFile;


PROCEDURE InsertIniInt*(entry:ARRAY OF CHAR; val:LONGINT;ini:ARRAY OF CHAR); 
(* Integer Wert in INI Datei schreiben *)
VAR 
  chars : ARRAY 80 OF CHAR;
  dmyb  : WD.BOOL;
BEGIN
  Strings.Str(val,chars);
  dmyb:=WB.WritePrivateProfileStringA(SYSTEM.ADR(SECTION),SYSTEM.ADR(entry),SYSTEM.ADR(chars),
                       SYSTEM.ADR(ini));
END InsertIniInt;


PROCEDURE InsertIniHexInt*(entry:ARRAY OF CHAR; val:LONGINT;ini:ARRAY OF CHAR); 
(* Integer Wert in INI Datei schreiben *)
VAR 
  chars : ARRAY 80 OF CHAR;
  dmyb  : WD.BOOL;
BEGIN
  Strings.HexStr(val,chars);
  dmyb:=WB.WritePrivateProfileStringA(SYSTEM.ADR(SECTION),SYSTEM.ADR(entry),SYSTEM.ADR(chars),
                       SYSTEM.ADR(ini));
END InsertIniHexInt;


PROCEDURE InsertIniBool*(entry:ARRAY OF CHAR; val:BOOLEAN;ini:ARRAY OF CHAR); 
(* BOOL Wert in INI Datei schreiben *)
VAR 
  chars   : ARRAY 80 OF CHAR;
  dmyb    : WD.BOOL;
  zeroone : ARRAY 2 OF CHAR;
BEGIN
  IF val THEN zeroone:="1" ELSE zeroone:="0" END;
  dmyb:=WB.WritePrivateProfileStringA(SYSTEM.ADR(SECTION),SYSTEM.ADR(entry),SYSTEM.ADR(zeroone),
                             SYSTEM.ADR(ini));
END InsertIniBool;

(**********************************************************************************************)
 
PROCEDURE WriteIniFile*();
(* INI Datei schreiben *)
VAR 
  ini  : ARRAY 128 OF CHAR;
  dmyb : WD.BOOL;

BEGIN
  IF ~GetIniFileName(ini) THEN RETURN END; 
  dmyb:=WB.WritePrivateProfileStringA(SYSTEM.ADR(SECTION),
                                    SYSTEM.ADR("FontName"),
                                    SYSTEM.ADR(Options.fontName),
                                    SYSTEM.ADR(ini));
  IF dmyb=0 THEN GlobWin.DisplayError("ERROR","No access to Editor-INI-file"); RETURN END;                  
  dmyb:=WB.WritePrivateProfileStringA(SYSTEM.ADR(SECTION),
                                    SYSTEM.ADR("PrinterFontName"),
                                    SYSTEM.ADR(Options.printerFontName),
                                    SYSTEM.ADR(ini));
  InsertIniBool("AutoIndent",Options.autoIndent,ini);
  InsertIniInt("Tabsize",Options.tabsize,ini);
  InsertIniBool("UseTabs",Options.useTabs,ini);
  InsertIniBool("Mouse",Options.mouse,ini);
  InsertIniInt("FontSize",Options.fontSize,ini);
  InsertIniInt("PrinterFontSize",Options.printerFontSize,ini);
  InsertIniBool("Oberon2Syntax",Options.syntax,ini);
  InsertIniBool("SmartLineMerge",Options.smartDel,ini);
  InsertIniInt("IndentWidth",Options.indentWidth,ini);
  InsertIniBool("ColorComments",Options.colorComments,ini);
  InsertIniInt("PrintMarginLeft",Options.printMarginLeft,ini);
  InsertIniInt("PrintMarginRight",Options.printMarginRight,ini);
  InsertIniInt("PrintMarginTop",Options.printMarginTop,ini);
  InsertIniInt("PrintMarginBottom",Options.printMarginBottom,ini);
  InsertIniBool("PrintDate",Options.printDate,ini);
  InsertIniBool("PrintLineNumbers",Options.printLineNumbers,ini);
  InsertIniHexInt("CommentColor",Options.commentColor,ini);
END WriteIniFile;  
 
END EnvHnd.    

