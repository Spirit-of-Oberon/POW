(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(*  20-10-1998 rel. 32/1.1 LEI obsolete printer escapes replaced by new       *)
(*                             WinAPI 32 calls                                *)
(**---------------------------------------------------------------------------  
  This module provides character based access to printers.
  
  The printer is regarded as a sequential line-oriented output medium. 
  At the beginning of a printout a virtual output cursor is set to the top 
  left corner of the first page. After data has been output this position is 
  moved right by the width of the output; if necessary a CR LF is included. 
  It is also possible to force an immediate change of line or page.
  
  Before starting a printout the module must be initialized by calling Start. 
  After the last output on the printout the procedure Finished must be called. 
  In a multi-user environment the procedures Start and Finished ensure that all 
  output in between is managed as a single print job.
  ----------------------------------------------------------------------------*)

MODULE Print;


IMPORT SYSTEM,WD:=WinDef,WB:=WinBase,WC:=CommDlg,WG:=WinGDI,WU:=WinUser,
       Utils, Strings, Float, WinUtils, GH:=GlobHandles;

CONST
  MAXDOCNAME=300;

TYPE
  Coordinate=LONGINT;

VAR
  printerData:WC.PRINTDLG;
  charHeight:Coordinate;
  xResolution:Coordinate;
  yResolution:Coordinate;
  leftMargin,topMargin:Coordinate;
  posX,posY:Coordinate;
  started:BOOLEAN;

PROCEDURE [_APICALL] AbortProc(hdc:WD.HDC; res:INTEGER);
BEGIN
END AbortProc;

PROCEDURE GetDocumentName(VAR docName:ARRAY OF CHAR);
(* returns the name of the document which shows up in the list of print jobs *)
VAR
  len:LONGINT;
BEGIN
  len:=WB.GetModuleFileNameA(GH.GetAppInstanceHandle(),
                             SYSTEM.ADR(docName),
                             LEN(docName));
  IF len=0 THEN docName[0]:=0X END;
END GetDocumentName;
  
PROCEDURE StartWithDialog*():BOOLEAN;
(** The module is initialized for the start of a new printout. This procedure 
    or Start must be called before any of the other modules procedures 
    are called. 
    
    This call displays a dialog box which offers an opportunity to select a specific 
    printer for the new print job. The function returns TRUE if a printer was selected
    and FALSE if the dialog was aborted by the user.
    
    In a network environment the system is indicated the start of a new printer job. *)
VAR
  res:WD.BOOL;
  textSize:WD.SIZE;
  docInfo:WG.DOCINFO;
  printJobId:LONGINT;
  docName:ARRAY MAXDOCNAME OF CHAR;
BEGIN
  printerData.lStructSize:=SIZE(WC.PRINTDLG);
  printerData.hwndOwner:=0;
  printerData.hDevNames:=WD.NULL;
  printerData.hDevMode:=WD.NULL;
  printerData.Flags:=SYSTEM.BITOR(SYSTEM.BITOR(WC.PD_NOPAGENUMS,WC.PD_RETURNDC),WC.PD_NOSELECTION);
  printerData.nCopies:=1;
  res:=WC.PrintDlgA(printerData);
  IF res#0 THEN 
    ASSERT(printerData.hDC#0);
    res:=WG.GetTextExtentPointA(printerData.hDC,SYSTEM.ADR("Cf"),2,textSize);
    charHeight:=textSize.cy;
    xResolution:=WG.GetDeviceCaps(printerData.hDC,WG.HORZRES);
    yResolution:=WG.GetDeviceCaps(printerData.hDC,WG.VERTRES);
    leftMargin:=0; 
    topMargin:=0;
    posX:=leftMargin;
    posY:=topMargin;
    docInfo.cbSize:=SIZE(WG.DOCINFO);
    GetDocumentName(docName);
    docInfo.lpszDocName:=SYSTEM.ADR(docName);
    docInfo.lpszOutput:=WD.NULL;
    docInfo.lpszDatatype:=WD.NULL;
    docInfo.fwType:=0;
    printJobId:=WG.StartDocA(printerData.hDC, docInfo);
    IF printJobId>0 THEN
      started:=TRUE;
      RETURN TRUE;
    ELSE
      WinUtils.WriteError("the print job could not be started (StartDoc failed)");
      started:=FALSE;
      RETURN FALSE;
    END;
  ELSE
    started:=FALSE;
    RETURN FALSE;
  END;
END StartWithDialog;

PROCEDURE Start*();
(** The module is initialized for the start of a new printout. This procedure 
    or StartWithDialog must be called before any of the other modules procedures 
    are called. 
    
    In a network environment the system is indicated the start of a new printer job. *)
VAR
  res:WD.BOOL;
  textSize:WD.SIZE;
  docInfo:WG.DOCINFO;
  printJobId:LONGINT;
  docName:ARRAY MAXDOCNAME OF CHAR;
BEGIN
  printerData.lStructSize:=SIZE(WC.PRINTDLG);
  printerData.hwndOwner:=0;
  printerData.Flags:=Utils.BitOr(WC.PD_RETURNDEFAULT,WC.PD_RETURNDC);
  printerData.nCopies:=1;
  printerData.hDevNames:=WD.NULL;
  printerData.hDevMode:=WD.NULL;
  res:=WC.PrintDlgA(printerData);
  IF (res#0) &
     (printerData.hDC#0) THEN
    res:=WG.GetTextExtentPointA(printerData.hDC,SYSTEM.ADR("Cf"),2,textSize);
    charHeight:=textSize.cy;
    xResolution:=WG.GetDeviceCaps(printerData.hDC,WG.HORZRES);
    yResolution:=WG.GetDeviceCaps(printerData.hDC,WG.VERTRES);
    leftMargin:=0; 
    topMargin:=0;
    posX:=leftMargin; 
    posY:=topMargin;
    docInfo.cbSize:=SIZE(WG.DOCINFO);
    GetDocumentName(docName);
    docInfo.lpszDocName:=SYSTEM.ADR(docName);
    docInfo.lpszOutput:=WD.NULL;
    docInfo.lpszDatatype:=WD.NULL;
    docInfo.fwType:=0;
    printJobId:=WG.StartDocA(printerData.hDC, docInfo);
    IF printJobId>0 THEN
      started:=TRUE;
    ELSE
      WinUtils.WriteError("the print job could not be started (StartDoc failed)");
      started:=FALSE;
    END;
  ELSE
    WinUtils.WriteError("the print job could not be started, no default printer");
    started:=FALSE;
  END;
END Start;

PROCEDURE Page*();
(** The output cursor is set to the beginning of the next page. *)
VAR
  res:LONGINT;
BEGIN
  IF ~started THEN RETURN END;
  res:=WG.EndPage(printerData.hDC);
  posX:=leftMargin; 
  posY:=topMargin;
END Page;

PROCEDURE Ln*();
(** The output cursor is set to the beginning of the next line. *)
BEGIN
  IF ~started THEN RETURN END;
  posX:=leftMargin; 
  INC(posY,charHeight);
  IF posY>yResolution-charHeight THEN Page END;
END Ln;

PROCEDURE CharNoCheck(x:CHAR);
VAR
  res:WD.BOOL;
  t:ARRAY 2 OF CHAR;
  width:Coordinate;
  textSize:WD.SIZE;
BEGIN
  t[0]:=x;
  t[1]:=0X;
  res:=WG.GetTextExtentPointA(printerData.hDC,SYSTEM.ADR(t),1,textSize);
  width:=textSize.cx;
  IF posX+width>=xResolution THEN Ln END;
  res:=WG.TextOutA(printerData.hDC,
                 posX,
                 posY,
                 SYSTEM.ADR(t[0]),1);
  INC(posX,width);
END CharNoCheck;

PROCEDURE GetInfo*(VAR x,y:LONGINT; VAR hdc:WD.HDC);
(** This function is very Windows specific. It should be avoided if possible.
    This function returns the current output location in device co-ordinates and
    a handle to the Windows printer device context which is used for printing for
    the current print job. *)
BEGIN
  x:=posX;
  y:=posY;
  hdc:=printerData.hDC;
END GetInfo;

PROCEDURE Char*(x:CHAR);
(** The character <x> is printed. *)
VAR
  res:WD.BOOL;
  t:ARRAY 2 OF CHAR;
  width:Coordinate;
BEGIN
  IF ~started THEN RETURN END;
  CharNoCheck(x);
END Char;

PROCEDURE Str*(t:ARRAY OF CHAR);
(** The string contained in <t> is printed. *)
VAR
  i,l:LONGINT;
BEGIN
  IF ~started THEN RETURN END;
  l:=Strings.Length(t);
  FOR i:=0 TO l-1 DO CharNoCheck(t[i]) END;
END Str;

PROCEDURE Real*(x:LONGREAL; n:INTEGER);
(** The number passed in <x> is printed right aligned <n> characters wide. If 
    the number cannot be represented in the desired width the stated width is 
    extended. *)
VAR
  t,th:ARRAY 255 OF CHAR;
  endPos:LONGINT;
  roundPos,kommaPos,exp:LONGINT;
  i,v,l:LONGINT;
BEGIN
  Float.Str(x,t);
  l:=Strings.Length(t);
  IF ~((t[0]>"9") OR ((t[1]#0X) & (t[1]>"9"))) & (l>n) THEN
    endPos:=Strings.Pos("e",t,1)-1;
    kommaPos:=Strings.Pos(".",t,1);
    IF kommaPos#0 THEN 
      IF endPos=-1 THEN endPos:=l END;
      roundPos:=endPos-l+n+1;
      IF roundPos>kommaPos THEN
        i:=roundPos-1;
        v:=5;
        WHILE i>=0 DO
          v:=ORD(t[i])-48+v;
          t[i]:=CHR((v MOD 10)+48);
          v:=v DIV 10;
          DEC(i);
          IF (t[i]<"0") OR (t[i]>"9") THEN DEC(i) END;
        END;
        IF v>0 THEN
          IF Strings.Pos("e",t,1)#0 THEN
            Strings.Copy(t,th,endPos+2,l-endPos-1);
            Strings.Str(Strings.Val(th)+1,th);
            Strings.Delete(t,endPos+2,l-endPos-1);
            Strings.Append(t,th);
            i:=1;
            IF (t[0]="-") OR (t[0]="+") THEN INC(i) END;
            Strings.Delete(t,i+1,1);
            Strings.InsertChar(".",t,i);
            Strings.InsertChar(CHR(v+48),t,i);
            l:=Strings.Length(t);
            endPos:=Strings.Pos("e",t,1)-1;
            roundPos:=endPos-l+n+1;
          ELSE
            i:=1;
            IF (t[0]="-") OR (t[0]="+") THEN INC(i) END;
            Strings.InsertChar(CHR(v+48),t,i);
            l:=Strings.Length(t);
            endPos:=Strings.Pos("e",t,1)-1;
            roundPos:=endPos-l+n+1;
          END;  
        END;
        Strings.Delete(t,roundPos,l-n);
        IF Strings.PosChar(".",t,1)#0 THEN
          i:=Strings.PosChar("e",t,1)-1;
          IF i=-1 THEN i:=Strings.Length(t) END;
          WHILE (i>1) & (t[i-1]="0") DO
            Strings.Delete(t,i,1);
            DEC(i);
          END;
        END;  
      END;
    END;  
  END;
  Strings.RightAlign(t,n);
  Str(t);
END Real;

PROCEDURE Int*(i,n:LONGINT);
(** The number passed in <i> is printed right aligned <n> characters wide. If 
    the number cannot be represented in the desired width the stated width 
    is extended. *)
VAR
  t:ARRAY 255 OF CHAR;
BEGIN
  Strings.Str(i,t);
  Strings.RightAlign(t,SHORT(n));
  Str(t);
END Int;
  
PROCEDURE Finished*();
(** This procedure is called at the end of the current printout. In a network 
    environment the document is released for printing in the printer queue.  *)
VAR
  res:WD.BOOL;
  dummy:WD.HGLOBAL;
BEGIN
  IF ~started THEN RETURN END;
  IF (posX#leftMargin) OR (posY#topMargin) THEN Page END;
  res:=WG.EndDoc(printerData.hDC);
  res:=WG.DeleteDC(printerData.hDC);
  IF printerData.hDevMode#WD.NULL THEN dummy:=WB.GlobalFree(printerData.hDevMode) END;
  IF printerData.hDevNames#WD.NULL THEN dummy:=WB.GlobalFree(printerData.hDevNames) END;
  started:=FALSE;
END Finished;

PROCEDURE SetLeftMargin*(marg:LONGINT);
(** The left page margin is set to <marg> millimeters. If the current output cursor 
    is situated to the left of the new margin it is automatically adjusted to the 
    new margin.
    
    Bear in mind that paper feeder tolerances and printer driver inaccuracies may 
    give rise to irregularities. *)
VAR
  x:LONGINT;
  res:WD.BOOL;
  point:WD.POINT;
BEGIN
  IF ~started THEN RETURN END;
  res:=WG.Escape(printerData.hDC,WG.GETPRINTINGOFFSET,WD.NULL,WD.NULL,SYSTEM.ADR(point));
  x:=WG.GetDeviceCaps(printerData.hDC,WG.LOGPIXELSX);
  x:=(x*1000) DIV 2571;
  leftMargin:=(marg*x) DIV 10-point.x;
  IF leftMargin<0 THEN leftMargin:=0 END;
  IF leftMargin>posX THEN posX:=leftMargin END;
END SetLeftMargin;

PROCEDURE SetTopMargin*(marg:LONGINT);
(** The top page margin is set to <marg> millimeters. If the current output position 
    is situated above the new margin it is automatically adjusted to the new margin.
    
    Bear in mind that paper feeder tolerances and printer driver inaccuracies may 
    give rise to irregularities. *)
VAR
  x:LONGINT;
  res:LONGINT;
  point:WD.POINT;
BEGIN
  IF ~started THEN RETURN END;
  res:=WG.Escape(printerData.hDC,WG.GETPRINTINGOFFSET,WD.NULL,WD.NULL,SYSTEM.ADR(point));
  x:=WG.GetDeviceCaps(printerData.hDC,WG.LOGPIXELSY);
  x:=(x*1000) DIV 2571;
  topMargin:=SHORT((marg*x) DIV 10)-point.y;
  IF topMargin<0 THEN topMargin:=0 END;
  IF topMargin>posY THEN posY:=topMargin END;
END SetTopMargin;

PROCEDURE RemainingLines*():INTEGER;
(** The return value of the function is the number of lines that may still be 
    printed on the current page using the current font. *)
VAR
  x:LONGINT;
BEGIN
  IF started THEN
    x:=(yResolution-posY) DIV charHeight;
    IF x<0 THEN x:=0 END;
    RETURN SHORT(x);
  ELSE 
    RETURN 0;
  END;
END RemainingLines;
          
BEGIN
  started:=FALSE;
END Print.
