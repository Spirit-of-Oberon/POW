(******************************************************************************
 *  Module Print
 *  
 *  This module implements printing. This includes the dialog box
 *  which allows the user to choose which part of the document should
 *  be printed and which printer should be used.
 ******************************************************************************)

MODULE Print;


IMPORT List:=ListSt, WD := WinDef, WU := WinUser, WB := WinBase,
       WG :=WinGdi, SYSTEM, CommDlg, Str := Strings, 
       Utils, TWin:=TextWin, Options, GlobWin;


CONST
  ABORTDIALOG="AbortDialog";
  ID_ABORTBUTTON=211;

  MODE_ALL       = CommDlg.PD_ALLPAGES;
  MODE_PAGES     = CommDlg.PD_PAGENUMS;
  MODE_SELECTION = CommDlg.PD_SELECTION;

  
TYPE
  AbortProcT = PROCEDURE [_APICALL] (hdc : WD.HDC; code : INTEGER) : INTEGER;

VAR
  fAbort           : BOOLEAN;           (* TRUE wenn der Benutzer den Druck abgebrochen hat *)
  hwndPDlg         : WD.HWND;           (* Handle des Abbruchs Druck Dialog                 *)
  szTitle          : ARRAY 256 OF CHAR; (* Globaler Zeiger auf Druckjobtitel                *)
  fileName         : ARRAY 256 OF CHAR; (* Name der zu druckenden Datei                     *)
  tabWidth         : LONGINT;           (* Breite eines Tabulators                          *)
  printMode        : INTEGER;
  fromPage         : INTEGER;
  toPage           : INTEGER;
  copies           : INTEGER;

  xOffs  : LONGINT; (* leftmost co-ordinate of print area in device units *)
  yOffs  : LONGINT; (* topmost co-ordinate of print area in device units *)
  xMax   : LONGINT; (* rightmost co-ordinate of print area in device units *)
  yMax   : LONGINT; (* maximum vertical co-ordinate of print area in device units *)
  dpiX   : LONGINT; (* number of pixels per inch along the screen width *)
  dpiY   : LONGINT; (* number of pixels per inch along the screen height *)
  textOffs:LONGINT; (* x co-ordinate for source code *)
  halfChar:LONGINT;
  lineHeight : LONGINT; (* height of a of text in device units *)

  hDCPrinter : WD.HDC;  (* decive context for printer *)
  hFont,
  hItalicFont: WD.HFONT;

  printedOnCurrentPage:BOOLEAN;

(*********************************************************************************************)

PROCEDURE [_APICALL] PrintAbortProc*(hdc : WD.HDC; code : INTEGER) : INTEGER;
(* wird durch GDI Druck Code aufgerufen um auf Benutzerabbruch hin zu prüfen *)

VAR
  msg   : WU.MSG;
  done  : WD.BOOL;
  ok    : LONGINT;

BEGIN
  WHILE ~fAbort & (WU.PeekMessageA(msg,0,0,0,WU.PM_REMOVE)#0) DO
    IF WU.IsDialogMessageA(hwndPDlg,msg)=0 THEN
      done :=WU.TranslateMessage(msg);
      ok   :=WU.DispatchMessageA(msg); (* Nachricht senden *)
    END;
  END;
  IF fAbort THEN RETURN 0 ELSE RETURN 1 END;
END PrintAbortProc;

(*********************************************************************************************)

PROCEDURE [_APICALL] AbortDlg* (hwnd    : WD.HWND;
                                message : WD.UINT;
                                wParam  : WD.WPARAM;
                                lParam  : WD.LPARAM) : WD.BOOL;
(* Dialogfunktion für Druckabbruch Dialogbox *)

VAR done : WD.BOOL;

BEGIN
  CASE message OF
    WU.WM_INITDIALOG : 
        done := WU.ShowWindow(hwnd,WU.SW_NORMAL);
        done := WU.UpdateWindow(hwnd);
        RETURN 1;
    | WU.WM_COMMAND : 
        fAbort:=TRUE;
        done := WU.DestroyWindow(hwnd);
        RETURN 1;
  ELSE
    RETURN 0;
  END;
  RETURN 1;
END AbortDlg;

(*********************************************************************************************)

PROCEDURE PrintHeader(page:INTEGER; VAR currentY:LONGINT);
(* druckt die Kopfzeile einer Seite *)

VAR
  buf  : ARRAY 100 OF CHAR;
  res  : WD.BOOL;
  date : ARRAY 100 OF CHAR;
  size : WD.SIZE;
  prevFont: WD.HFONT;
BEGIN    
  printedOnCurrentPage:=TRUE;
  prevFont:=WG.SelectObject(hDCPrinter,hItalicFont);
  COPY(fileName,buf);
  IF Options.printDate THEN
    Str.Append(buf,"  ");
    Utils.GetDateStr(date);
    Str.Append(buf,date);
  END;
  res:=WG.TextOutA(hDCPrinter,xOffs,currentY,SYSTEM.ADR(buf),Str.Length(buf));    

  Str.Str(page,buf);          
  Str.Insert("page ",buf,1);
  res := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR(buf),Str.Length(buf),size);
  lineHeight := size.cy; (* Höhe einer Zeile zuweisen *)
  res:=WG.TextOutA(hDCPrinter,xMax-size.cx,currentY,SYSTEM.ADR(buf),Str.Length(buf));    
 
  IF Options.printLineNumbers THEN
    res:=WG.MoveToEx(hDCPrinter,textOffs-halfChar,currentY+(lineHeight*3) DIV 2,NIL);
    res:=WG.LineTo(hDCPrinter,xMax,currentY+(lineHeight*3) DIV 2);
    res:=WG.MoveToEx(hDCPrinter,textOffs-halfChar,currentY+(lineHeight*3) DIV 2,NIL);
    res:=WG.LineTo(hDCPrinter,textOffs-halfChar,yMax);
  ELSE
    res:=WG.MoveToEx(hDCPrinter,textOffs,currentY+(lineHeight*3) DIV 2,NIL);
    res:=WG.LineTo(hDCPrinter,xMax,currentY+(lineHeight*3) DIV 2);
  END;
  INC(currentY,lineHeight*2);
  prevFont:=WG.SelectObject(hDCPrinter,prevFont);
END PrintHeader;


PROCEDURE ShouldPrintPage(pageNr : LONGINT) : BOOLEAN;
(* prüft, ob die aktuelle Seite gedruckt werden soll oder nicht *)
(* Rückgabewert : TRUE - Seite wird gedruckt, FALSE - Seite wird nicht gedruckt *)
BEGIN
  IF (printMode=MODE_ALL) OR (printMode=MODE_SELECTION) THEN 
    RETURN TRUE;
  ELSIF printMode=MODE_PAGES THEN 
    RETURN (pageNr >= fromPage) & (pageNr <= toPage); 
  END;
END ShouldPrintPage;


PROCEDURE EndOfPage(actYPos : LONGINT) : BOOLEAN;
(* prüft, ob das Ende einer Seite erreicht wurde oder nicht  *)
(* Rückgabewert : TRUE - Ende der Seite, FALSE - andernfalls *)

BEGIN
  RETURN (actYPos + lineHeight) > yMax;
END EndOfPage;

(*********************************************************************************************)

PROCEDURE StartNewPage (VAR pageNr : INTEGER; 
                        VAR actY : LONGINT; 
                        height : LONGINT) : BOOLEAN;
(* beginnt eine neue Seite für den Druck *)
(* Rückgabewert : TRUE - erfolgreich, FALSE - Fehler aufgetreten *)

VAR
  pError : LONGINT;
  ok     : WD.BOOL;
BEGIN
  INC(pageNr);       (* increment page count *)
  IF ShouldPrintPage(pageNr) THEN (* should we print this page? *)
    IF printedOnCurrentPage THEN
      printedOnCurrentPage:=FALSE;
      IF WG.EndPage(hDCPrinter)<=0 THEN (* close the old page *)
        pError := WG.SP_ERROR;
        GlobWin.DisplayError("Internal Error","Could not finish the current page");
        RETURN FALSE;
      END;
      IF WG.StartPage(hDCPrinter)<=0 THEN (* start a new page *)
        pError := WG.SP_ERROR;
        GlobWin.DisplayError("Internal Error","Could not start a new page");
        RETURN FALSE;
      END;
    END;
    actY:=yOffs;
    PrintHeader(pageNr, actY); (* print the header for the current page *)
  END;
  RETURN TRUE;
END StartNewPage;

(*********************************************************************************************)

PROCEDURE PrintLine(lineNr    : LONGINT;
                    VAR pageNr: INTEGER;
                    VAR text- : ARRAY OF CHAR; (* Text             *)
                    VAR yPos  : LONGINT);
(* Zeile drucken *)

VAR
  lineWidth  : LONGINT; (* Breite der Zeile *)
  len        : LONGINT; (* Länge des Textes einer Zeile *)  
  textInx    : LONGINT; (* Position im Text *)  
  lenSubStr  : LONGINT; (* Länge des Teilstrings *)
  res        : LONGINT;
  size       : WD.SIZE;
  ok         : WD.BOOL;
  prevFont   : WD.HFONT;
  buf        : ARRAY 10 OF CHAR;
BEGIN
  IF Options.printLineNumbers & ShouldPrintPage(pageNr) THEN
    prevFont:=WG.SelectObject(hDCPrinter,hItalicFont);
    Str.Str(lineNr,buf);
    Str.RightAlign(buf,4);
    res:=WG.TextOutA(hDCPrinter,xOffs,yPos,SYSTEM.ADR(buf),Str.Length(buf));
    printedOnCurrentPage:=TRUE;
    prevFont:=WG.SelectObject(hDCPrinter,prevFont);
  END;
  
  len:=Str.Length(text); (* Länge des Textes ermitteln *)
  
  ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR(text),len,size);
  lineWidth := size.cx; (* Breite der Zeile ermitteln *)

  IF textOffs+lineWidth-1 > xMax THEN (* Text länger als maximale Breite *)
    textInx:=0; 
    WHILE (textInx < len) & ShouldPrintPage(pageNr) DO
      lenSubStr := len - textInx;
      ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR(text)+textInx,lenSubStr,size);
      lineWidth := size.cx;
      WHILE textOffs+lineWidth-1 > xMax DO
        DEC(lenSubStr);
        ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR(text)+textInx,lenSubStr,size);
        lineWidth := size.cx;
      END;
      IF ShouldPrintPage(pageNr) THEN
        res:=WU.TabbedTextOutA(hDCPrinter,textOffs,yPos,SYSTEM.ADR(text)+textInx,lenSubStr,1,tabWidth,textOffs);
        printedOnCurrentPage:=TRUE;
      END;
      INC(textInx,lenSubStr);
      INC(yPos,lineHeight);
      IF EndOfPage(yPos) THEN
        IF ~StartNewPage(pageNr, yPos, lineHeight) THEN
          GlobWin.Beep;
        END;
      END; 
    END;

  ELSE (* Text passt in Zeile *)

    IF text[0]#0X THEN
      IF ShouldPrintPage(pageNr) THEN
        res:=WU.TabbedTextOutA(hDCPrinter,textOffs,yPos,SYSTEM.ADR(text),len,1,tabWidth,textOffs);
        printedOnCurrentPage:=TRUE;
      END;
    END;
    INC(yPos,lineHeight); 

  END;    
(*  Process.Yield;*)
END PrintLine;

(*********************************************************************************************)

PROCEDURE PrintFile*(hwnd : WD.HWND;
                     win:TWin.WinDesc; 
                     title:ARRAY OF CHAR):INTEGER;
(* Datei drucken *)
VAR
  hwndPDlg   : WD.HWND;    (* Handle für Abbruch - Dialog *)
  dInfo      : WG.DOCINFO; (* Informationen für Druck *)
  abortProc  : AbortProcT; (* Abbruchprozedur *)

  ySizePage   : LONGINT; (* height in raster lines *)
  xSizePage   : LONGINT; (* width in pixels *)
  
  actPage    : INTEGER; (* aktuelle Seite *)
  actLine    : LONGINT; (* current line *)
  firstLine  : LONGINT; (* first line which is to be printed *)
  lastLine   : LONGINT; (* last line which is to be printed *)
  yExtSoFar  : LONGINT; (* Druckfortschritt - aktuelle Position *)

  ok         : WD.BOOL;
  size       : WD.SIZE;
  pError     : LONGINT; (* Druckerfehler *)
  penWidth   : LONGINT;
  printJobId : LONGINT;

  lineTxt    : ARRAY List.MAXLENGTH+1 OF CHAR;
  res        : LONGINT;
  lineLen    : LONGINT;
  done       : BOOLEAN;
  txt        : ARRAY 10 OF CHAR;
  copyNr     : INTEGER; (* Schleifenvariable *)
  oldFont    : WD.HFONT; (* logische Schrift *)
  hPen,
  oldPen     : WD.HPEN;
  printDlg   : CommDlg.PDA;
  lfHeight   : LONGINT;
  devNames   : CommDlg.DEVNAMES;
  devNamesAdr: LONGINT;
  deviceName : ARRAY 300 OF CHAR;
  driverName : ARRAY 300 OF CHAR;

  PROCEDURE GetStringFromAdr(adr:LONGINT; VAR str:ARRAY OF CHAR);
  VAR
    i:INTEGER;
  BEGIN
    i:=0;
    SYSTEM.GET(adr+i,str[i]);
    WHILE (i+1<LEN(str)) & (str[i]#0X) DO
      INC(i);
      SYSTEM.GET(adr+i,str[i]);
    END;
    IF str[i]#0X THEN str[i]:=0X END; 
  END GetStringFromAdr;
  
BEGIN
  IF win=NIL THEN 
    GlobWin.DisplayError("Error","no edit window selected");
    RETURN 0;
  END;

  COPY(title,fileName);


  printDlg.lStructSize:=SIZE(CommDlg.PDA);
  printDlg.hwndOwner:=win.hwnd;
  printDlg.hDevMode:=0;
  printDlg.hDevNames:=0;
  printDlg.hDC:=0;
  printDlg.Flags:=printMode;
  printDlg.nFromPage:=fromPage;
  printDlg.nToPage:=toPage;
  printDlg.nMinPage:=1;
  printDlg.nMaxPage:=9999;
  printDlg.nCopies:=copies;
  printDlg.hInstance:=0;
  printDlg.lCustData:=0;
  printDlg.lpfnPrintHook:=NIL;
  printDlg.lpfnSetupHook:=NIL;
  printDlg.lpPrintTemplateName:=0;
  printDlg.lpSetupTemplateName:=0;
  printDlg.hPrintTemplate:=0;
  printDlg.hSetupTemplate:=0;
 
  res:=CommDlg.PrintDlgA(printDlg);
  IF res=0 THEN 
    RETURN 0;
  END;

  IF SYSTEM.BITAND(printDlg.Flags,CommDlg.PD_ALLPAGES)#0 THEN
    printMode:=MODE_ALL;
  ELSIF SYSTEM.BITAND(printDlg.Flags,CommDlg.PD_PAGENUMS)#0 THEN
    printMode:=MODE_PAGES;
  ELSIF SYSTEM.BITAND(printDlg.Flags,CommDlg.PD_SELECTION)#0 THEN
    printMode:=MODE_SELECTION;
  ELSE
    printMode:=MODE_ALL;
  END;
  fromPage:=printDlg.nFromPage;
  toPage:=printDlg.nToPage;
  copies:=printDlg.nCopies;

  devNamesAdr:=WB.GlobalLock(printDlg.hDevNames);
  SYSTEM.MOVE(devNamesAdr,SYSTEM.ADR(devNames),SIZE(CommDlg.DEVNAMES));
  GetStringFromAdr(devNamesAdr+devNames.wDriverOffset,driverName);
  GetStringFromAdr(devNamesAdr+devNames.wDeviceOffset,deviceName);
  res:=WB.GlobalUnlock(printDlg.hDevNames);
  printDlg.hDevNames:=WB.GlobalFree(printDlg.hDevNames);

 (* Gerätekontext für Drucker erzeugen *)
  hDCPrinter := WG.CreateDCA(SYSTEM.ADR(driverName),
                             SYSTEM.ADR(deviceName),
                             WD.NULL,
                             NIL);
  IF hDCPrinter = 0 THEN 
    GlobWin.DisplayError("Printer Error","It was not possible to create a device context for the specified printer");
    RETURN 0; 
  END;
  
  dpiX:=WG.GetDeviceCaps(hDCPrinter,WG.LOGPIXELSX);
  dpiY:=WG.GetDeviceCaps(hDCPrinter,WG.LOGPIXELSY);
  
  xOffs:=WB.MulDiv(Options.printMarginLeft,dpiX,100);
  yOffs:=WB.MulDiv(Options.printMarginTop,dpiY,100);
  
  IF xOffs<WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALOFFSETX) THEN
    xOffs:=WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALOFFSETX);
  END;
  IF yOffs<WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALOFFSETY) THEN
    yOffs:=WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALOFFSETY);
  END; 
  
  xMax:=WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALWIDTH)-WB.MulDiv(Options.printMarginRight,dpiX,100);
  yMax:=WG.GetDeviceCaps(hDCPrinter,WG.PHYSICALHEIGHT)-WB.MulDiv(Options.printMarginBottom,dpiY,100);
  
  ySizePage:=WG.GetDeviceCaps(hDCPrinter,WG.VERTRES); 
  xSizePage:=WG.GetDeviceCaps(hDCPrinter,WG.HORZRES);
  
  IF xMax>xSizePage THEN xMax:=xSizePage END;
  IF yMax>ySizePage THEN yMax:=ySizePage END;

  lfHeight:=-WB.MulDiv(Options.printerFontSize, dpiY, 72);
  hFont := WG.CreateFontA(lfHeight,
                          0, (* width or 0 for closest match *)
                          0, (* escapement *)
                          0, (* orientation *)
                          WG.FW_DONTCARE, (* weight *)
                          0, (* italics *)
                          0, (* underline *)
                          0, (* strikeout *)
                          WG.DEFAULT_CHARSET, (* character set *)
                          WG.OUT_DEFAULT_PRECIS, (* output precision *)
                          WG.CLIP_DEFAULT_PRECIS,   (* clipping precision *)
                          WG.DEFAULT_QUALITY,
                          WG.FIXED_PITCH,
                          SYSTEM.ADR(Options.printerFontName));
  hItalicFont := WG.CreateFontA(lfHeight,
                          0, (* width or 0 for closest match *)
                          0, (* escapement *)
                          0, (* orientation *)
                          WG.FW_DONTCARE, (* weight *)
                          1, (* italics *)
                          0, (* underline *)
                          0, (* strikeout *)
                          WG.DEFAULT_CHARSET, (* character set *)
                          WG.OUT_DEFAULT_PRECIS, (* output precision *)
                          WG.CLIP_DEFAULT_PRECIS,   (* clipping precision *)
                          WG.DEFAULT_QUALITY,
                          WG.FIXED_PITCH,
                          SYSTEM.ADR(Options.printerFontName));
  IF (hFont=0) OR (hItalicFont=0) THEN
    GlobWin.DisplayError("Internal Error","Create font failed");
  END;
  oldFont := WG.SelectObject(hDCPrinter,hFont);

  penWidth:= 2 (* 2 points *) * dpiX DIV 72;
  hPen := WG.CreatePen(WG.PS_SOLID,0,0);
  oldPen := WG.SelectObject(hDCPrinter,hPen);

  (* Abbruchdialog wird erzeugt *)
  hwndPDlg:=WU.CreateDialogParamA(GlobWin.hInstance,SYSTEM.ADR(ABORTDIALOG),win.hwnd,AbortDlg,WD.NULL);
  IF hwndPDlg=0 THEN
    GlobWin.DisplayError("Internal Error","Create abort dialog failed");
    GlobWin.Beep;
    ok :=WG.DeleteDC(hDCPrinter);
    RETURN 0;
  END;
 

  abortProc := PrintAbortProc;

  (* Abbruchprozedur einrichten, die die Nachrichten für den Abbruchdialog verarbeitet *)
  res := WG.SetAbortProc(hDCPrinter, SYSTEM.VAL(WD.FARPROC,abortProc)); 

  fAbort:=FALSE;

  (* Initialisierung des Dokuments *)
  dInfo.cbSize:=SIZE(WG.DOCINFO);
  dInfo.lpszDocName:=SYSTEM.ADR(fileName);
  dInfo.lpszOutput:=WD.NULL;
  dInfo.lpszDatatype:=WD.NULL;
  dInfo.fwType:=0;

  (* height of a line *)
  ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR("Cg"),2,size);
  lineHeight := size.cy; (* Höhe einer Zeile zuweisen *)

  (* width of a tab *)
  ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR("  "),1,size);
  tabWidth  := Options.tabsize * size.cx;
  halfChar:= size.cx DIV 2;

  IF Options.printLineNumbers THEN
    ok := WG.GetTextExtentPoint32A(hDCPrinter,SYSTEM.ADR("9999:"),5,size);
    textOffs:=xOffs+size.cx;
  ELSE
    textOffs:=xOffs;
  END;

  IF printMode=MODE_SELECTION THEN 
    firstLine:=win.text.markStart.row;
    lastLine:=win.text.markEnd.row;
    IF win.text.markEnd.col<=1 THEN DEC(lastLine) END;
  ELSE
    firstLine:=1;
    lastLine:=win.text.lines;
  END;

  pError:=WG.SP_ERROR+1;
  copyNr := 1; (* Initialisierung *)
  printedOnCurrentPage:=FALSE;
  WHILE (copyNr <= copies) & (~fAbort) & (pError#WG.SP_ERROR) DO
  
    (* Initialisierung des zu druckenden Dokumentes *)
    actPage   := 1;
    actLine   := firstLine;
  
    (* Beginn des Drucks *)
    printJobId := WG.StartDocA(hDCPrinter, dInfo);
    IF printJobId <= 0 THEN
      GlobWin.DisplayError("Internal Error","Could not create a print job");
      pError:=WG.SP_ERROR;
      GlobWin.Beep;
    ELSE
      (* Erste Seite beginnen *)
      IF WG.StartPage(hDCPrinter)<=0 THEN 
        pError := WG.SP_ERROR;
        GlobWin.DisplayError("Internal Error","Could not start a new page");
        GlobWin.Beep;
      ELSE
        yExtSoFar:=yOffs;
        IF ShouldPrintPage(actPage) THEN PrintHeader(actPage, yExtSoFar) END;
      END;
    END;


    (* Solange noch Zeilen vorhanden sind, Text ausdrucken *)
    WHILE (actLine <= lastLine) & (~fAbort) & (pError#WG.SP_ERROR) DO

      IF EndOfPage(yExtSoFar) THEN
         (* Ende einer Seite wurde erreicht *)
         IF ~StartNewPage(actPage, yExtSoFar, lineHeight) THEN
           GlobWin.Beep;
         END;
      END; 
      IF win.text.GetLine(actLine,lineTxt,lineLen) THEN
        PrintLine(actLine, actPage, lineTxt, yExtSoFar);
      END;
      INC(actLine);
    END; (* while *)

    IF (~fAbort) THEN
      (* Letzte Seite auswerfen und Dokument fertigstellen *)
      IF printedOnCurrentPage & (WG.EndPage(hDCPrinter)<=0) THEN 
        pError := WG.SP_ERROR;
        GlobWin.Beep;
        GlobWin.DisplayError("Internal Error","Could not finish the current page");
      ELSE
        IF WG.EndDoc(hDCPrinter)<=0 THEN 
          pError := WG.SP_ERROR;
          GlobWin.Beep;
          GlobWin.DisplayError("Internal Error","Could not close the current print job");
        END;
      END;
    ELSE 
      (* Druck abbrechen *)
      pError := WG.AbortDoc(hDCPrinter);
      IF pError = WG.SP_ERROR THEN 
        GlobWin.Beep;
        GlobWin.DisplayError("Internal Error","Could not abort the document");
      END;
    END;
            
    INC(copyNr);
  END; (* Kopien - Schleife *)

  (* Abbruchfenster schließen und Hauptfenster wiederherstellen *)
  ok := WU.DestroyWindow(hwndPDlg);

  oldFont := WG.SelectObject(hDCPrinter,oldFont);
  oldPen := WG.SelectObject(hDCPrinter,oldPen);
  ok := WG.DeleteObject(hFont);
  ok := WG.DeleteObject(hItalicFont);
  ok := WG.DeleteObject(hPen);
  ok := WG.DeleteDC(hDCPrinter); (* Gerätekontext freigeben *)
  RETURN 1;
END PrintFile;

BEGIN
  printMode:=MODE_ALL;
  fromPage:=1;
  toPage:=999;
  copies:=1;
END Print.
