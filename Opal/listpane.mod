(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE ListPane;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser, WG:=WinGDI, WC:=CommDlg, WB:=WinBase,
       Utils, Process, Strings, Panes, TextPane, 
       Float, WinUtils, P:=Print, AppGrp, 
       Volume;

CONST 
  maxLineChars*=200; 
  maxColum*=80;
  maxLines*=25;

TYPE
  LineEleP*=POINTER TO RECORD
    txt*:POINTER TO ARRAY maxLineChars+1 OF CHAR;
    next*:LineEleP;
    prev*:LineEleP;
  END;

  ListPane*=RECORD (TextPane.TextPane)
    firstLine:LineEleP;
    lastLine:LineEleP;
    posLine:LineEleP;
    totalLines:INTEGER;
    update:BOOLEAN;
  END;
  ListPaneP*=POINTER TO ListPane;

(************************************)
PROCEDURE (VAR p:ListPane) Init*;
BEGIN
  p.Init^;
  p.caption:=TRUE;
END Init;

PROCEDURE (p:ListPaneP) TotalViewedLines():LONGINT;
VAR
  wRect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  RETURN (wRect.bottom+1) DIV p.charHeight;
END TotalViewedLines;

PROCEDURE (p:ListPaneP) CopyAllToClipboard*();
VAR
  dummy:WD.BOOL;
  ele:LineEleP;
  mem:WD.HANDLE;
  memA:LONGINT;
BEGIN
  IF WU.OpenClipboard(p.hwnd)#0 THEN 
    dummy:=WU.EmptyClipboard();
    mem:=WB.GlobalAlloc(WB.GMEM_FIXED,(maxLineChars+1)*p.totalLines);
    IF mem#WD.NULL THEN
      memA:=WB.GlobalLock(mem);  
      IF memA#0 THEN
        ele:=p.firstLine;
        WHILE ele#NIL DO
          SYSTEM.MOVE(SYSTEM.ADR(ele.txt[0]),memA,Strings.Length(ele.txt^));
          memA:=memA+Strings.Length(ele.txt^);
          SYSTEM.PUT(memA,0DX);
          SYSTEM.PUT(memA+1,0AX);
          memA:=memA+2;
          ele:=ele.next;
        END;
        SYSTEM.PUT(memA,0X);
        dummy:=WB.GlobalUnlock(mem);
        mem:=WU.SetClipboardData(WU.CF_TEXT,mem);
      END;
    END;
    dummy:=WU.CloseClipboard();
  ELSE
    dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
  END;
END CopyAllToClipboard;

PROCEDURE (p:ListPaneP) GetAbsLinePos(line:LineEleP):INTEGER;
VAR
  pos:INTEGER;
  found:BOOLEAN;
  ele:LineEleP;
BEGIN
  IF line=NIL THEN RETURN 0 END;
  pos:=0;
  found:=FALSE;
  ele:=p.firstLine;
  WHILE ele#p.lastLine DO
    IF ~found THEN
      IF ele=line THEN found:=TRUE ELSE INC(pos) END;
    END;
    ele:=ele.next;
  END;
  RETURN pos;
END GetAbsLinePos;

PROCEDURE (p:ListPaneP) GetRelLinePos(line:LineEleP):INTEGER;
BEGIN
  RETURN p.GetAbsLinePos(line)-p.GetAbsLinePos(p.posLine);
END GetRelLinePos;

PROCEDURE (p:ListPaneP) GetNthLine(lineNr:LONGINT; VAR line:LineEleP);
BEGIN
  line:=p.firstLine;
  WHILE (line#NIL) & (lineNr>0) DO
    line:=line.next;
    DEC(lineNr);
  END;
  IF line=NIL THEN line:=p.lastLine; END;
END GetNthLine;

PROCEDURE (p:ListPaneP) PositionCursor*();
VAR
  pos:INTEGER;
  size:WD.SIZE;
  dummy:WD.BOOL;
  dummyl:LONGINT;
  hdc:WD.HDC;
  oldFont:WD.HFONT;
BEGIN
  IF p.cursOn THEN 
    IF p.lastLine#NIL THEN
      pos:=p.GetRelLinePos(p.lastLine)+1;
      hdc:=WU.GetDC(p.hwnd);
      oldFont:=WG.SelectObject(hdc,p.font);
      ASSERT(oldFont#WD.NULL);
      dummy:=WG.GetTextExtentPointA(hdc,
                                    SYSTEM.ADR(p.lastLine.txt^),
                                    Strings.Length(p.lastLine.txt^),
                                    size);
      oldFont:=WG.SelectObject(hdc,oldFont);
      ASSERT(oldFont#WD.NULL);
      dummyl:=WU.ReleaseDC(p.hwnd,hdc);   
      dummy:=WU.SetCaretPos(size.cx,pos*p.charHeight-2);
    ELSE
      dummy:=WU.SetCaretPos(0,p.charHeight-2);
    END;
  END;
END PositionCursor;

PROCEDURE (p:ListPaneP) Paint*(hdc:WD.HDC; VAR paint:WU.PAINTSTRUCT);
VAR
  maxLines:LONGINT;
  i,posy,txtLen:LONGINT;
  dummy:WD.BOOL;
  dummyl:LONGINT;
  ele:LineEleP;
  rect,rect2:WD.RECT;
  size:WD.SIZE;
  oldFont:WD.HFONT;
BEGIN
  oldFont:=WG.SelectObject(hdc,p.font);
  ASSERT(oldFont#WD.NULL);
  dummy:=WU.GetClientRect(p.hwnd,rect);
  maxLines:=p.TotalViewedLines();
  ele:=p.posLine;
  i:=0;
  posy:=0;
  WHILE (ele#NIL) & (i<maxLines) DO
    txtLen:=SHORT(Strings.Length(ele.txt^));
    dummy:=WG.GetTextExtentPointA(hdc,SYSTEM.ADR(ele.txt^),txtLen,size);
    dummyl:=WG.TextOutA(hdc,0,posy,SYSTEM.ADR(ele.txt^),txtLen);
    rect2.left:=size.cx;
    rect2.top:=posy;
    rect2.right:=rect.right;
    rect2.bottom:=posy+p.charHeight;
    dummyl:=WU.FillRect(hdc,rect2,p.backBrush);
    posy:=posy+p.charHeight;
    INC(i);
    ele:=ele.next;
  END;
  rect2.left:=rect.left;
  rect2.top:=posy;
  rect2.right:=rect.right;
  rect2.bottom:=rect.bottom;
  dummyl:=WU.FillRect(hdc,rect2,p.backBrush);
  oldFont:=WG.SelectObject(hdc,oldFont);
  ASSERT(oldFont#WD.NULL);
END Paint;

PROCEDURE (p:ListPaneP) ManageVerticalScroll*(code:LONGINT; value:LONGINT):LONGINT;
VAR
  oldPos:LONGINT;
  oldTop:LONGINT;
  topPos:LONGINT;
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  CASE code OF
    WU.SB_THUMBTRACK:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,value,1);
  | WU.SB_LINEDOWN:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos+1,1);
  | WU.SB_PAGEDOWN:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos+p.TotalViewedLines(),1);
  | WU.SB_LINEUP:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos-1,1);
  | WU.SB_PAGEUP:
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,0,0);
      oldPos:=WU.SetScrollPos(p.hwnd,WU.SB_VERT,oldPos-p.TotalViewedLines(),1);
  ELSE
  END;
  oldTop:=p.GetAbsLinePos(p.posLine);
  topPos:=WU.GetScrollPos(p.hwnd,WU.SB_VERT);
  IF oldTop#topPos THEN
    p.GetNthLine(topPos,p.posLine);
    dummy:=WU.GetClientRect(p.hwnd,rect);
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
    dummy:=WU.UpdateWindow(p.hwnd);
    p.PositionCursor();
  END;
  RETURN 0;
END ManageVerticalScroll;

PROCEDURE (p:ListPaneP) ManageScrollBars*;
VAR
  rect:WD.RECT;
  max:LONGINT;
  dummyl:LONGINT;
  dummy:WD.BOOL;
BEGIN
  max:=p.TotalViewedLines();
  IF p.totalLines-max>0 THEN max:=p.totalLines-max ELSE max:=0 END;
  ASSERT(p.hwnd#WD.NULL);
  dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,0,max,0);
  dummyl:=p.ManageVerticalScroll(1000,0);
  dummyl:=WU.SetScrollPos(p.hwnd,
                         WU.SB_VERT,
                         WU.GetScrollPos(p.hwnd,WU.SB_VERT), 
                         1);
END ManageScrollBars;

PROCEDURE (p:ListPaneP) ScrollLastPosition*;
VAR
  rect:WD.RECT;
  max:LONGINT;
  range:LONGINT;
  dummyl:LONGINT;
  dummy:WD.BOOL;
BEGIN
  max:=p.TotalViewedLines();
  IF p.totalLines-max>0 THEN range:=p.totalLines-max ELSE range:=0 END;
  dummy:=WU.SetScrollRange(p.hwnd,WU.SB_VERT,0,range,0);
  dummyl:=WU.SetScrollPos(p.hwnd,
                          WU.SB_VERT,
                          range,
                          1);
  dummyl:=p.ManageVerticalScroll(1000,0);
END ScrollLastPosition;

PROCEDURE (p:ListPaneP) Open*():BOOLEAN;
VAR
  ele:LineEleP;
  t:ARRAY 30 OF CHAR;
  flags:LONGINT;
BEGIN
  IF ~p.RegisterClass() OR (p.owner=NIL) THEN RETURN FALSE END;  
  NEW(ele);
  ASSERT(ele#NIL);
  NEW(ele.txt);
  ASSERT(ele.txt#NIL);
  ele.txt^[0]:=0X;
  ele.prev:=NIL;
  ele.next:=NIL;
  p.lastLine:=ele;
  p.firstLine:=ele;
  p.posLine:=ele;
  p.totalLines:=1;
  p.update:=TRUE;
  t:="a Listpane";
  flags:=SYSTEM.BITOR(WU.WS_CHILD,WU.WS_CLIPSIBLINGS);
  flags:=SYSTEM.BITOR(flags,WU.WS_VISIBLE);
  flags:=SYSTEM.BITOR(flags,WU.WS_VSCROLL);
  IF p.caption THEN flags:=SYSTEM.BITOR(flags,WU.WS_CAPTION) END;
  IF p.framed THEN flags:=SYSTEM.BITOR(flags,WU.WS_BORDER) END;
  RETURN p.OpenTextPane(t,0,flags,TextPane.TextPaneClassTxt);
END Open;

PROCEDURE (p:ListPaneP) UpdateLastLine();
VAR
  maxLines:LONGINT;
  wRect:WD.RECT;
  pos:LONGINT;
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.GetClientRect(p.hwnd,wRect);
  maxLines:=p.TotalViewedLines();
  pos:=p.GetRelLinePos(p.lastLine);
  IF (pos>=0) & (pos<maxLines) THEN
    wRect.top:=pos*p.charHeight;
    wRect.bottom:=wRect.top+p.charHeight;
    dummy:=WU.InvalidateRect(p.hwnd,wRect,1);
    dummy:=WU.UpdateWindow(p.hwnd);
  END;
  p.PositionCursor();
END UpdateLastLine;

PROCEDURE (p:ListPaneP) AddLine*(VAR t:ARRAY OF CHAR);
VAR
  ele:LineEleP;
BEGIN
  NEW(ele);
  ASSERT(ele#NIL);
  NEW(ele.txt);
  ASSERT(ele.txt#NIL);
  COPY(t,ele.txt^);
  IF p.lastLine#NIL THEN p.lastLine.next:=ele; END;
  ele.prev:=p.lastLine;
  ele.next:=NIL;
  p.lastLine:=ele;
  INC(p.totalLines);
  IF p.firstLine=NIL THEN p.firstLine:=p.lastLine END;
  IF p.posLine=NIL THEN p.posLine:=p.lastLine END;
  IF p.update THEN
    p.UpdateLastLine;
    p.ScrollLastPosition;
  END;
END AddLine;

PROCEDURE (p:ListPaneP) AddEmptyLine*();
VAR
  ele:LineEleP;
BEGIN
  NEW(ele);
  ASSERT(ele#NIL);
  NEW(ele.txt);
  ASSERT(ele.txt#NIL);
  ele.txt^[0]:=0X;
  IF p.lastLine#NIL THEN p.lastLine.next:=ele; END;
  ele.prev:=p.lastLine;
  ele.next:=NIL;
  p.lastLine:=ele;
  INC(p.totalLines);
  IF p.firstLine=NIL THEN p.firstLine:=p.lastLine END;
  IF p.posLine=NIL THEN p.posLine:=p.lastLine END;
  IF p.update THEN
    p.UpdateLastLine;
    p.ScrollLastPosition;
  END;
END AddEmptyLine;

PROCEDURE (p:ListPaneP) ChangeLastLine*(VAR t:ARRAY OF CHAR);
BEGIN
  IF p.lastLine=NIL THEN 
    p.AddLine(t)
  ELSE
    COPY(t,p.lastLine.txt^);
    IF p.update THEN
      p.UpdateLastLine;
      p.ScrollLastPosition;
    END;
  END;
  IF p.cursOn THEN p.PositionCursor() END;
END ChangeLastLine; 

PROCEDURE (p:ListPaneP) AddCharToLine*(ch:CHAR);
VAR
  t:ARRAY 5 OF CHAR;
BEGIN
  Process.Yield();
  IF (p.lastLine=NIL) OR (Strings.Length(p.lastLine.txt^)>=maxLineChars) THEN
    t[0]:=ch; t[1]:=0X;
    p.AddLine(t);
  ELSE
    Strings.AppendChar(p.lastLine.txt^,ch);
    IF p.update THEN
      p.UpdateLastLine;
      p.ScrollLastPosition;
    END;
  END;
  IF p.cursOn THEN p.PositionCursor() END;
END AddCharToLine;

PROCEDURE (p:ListPaneP) ReadChar*():CHAR;
VAR
  ch,ex:CHAR;
BEGIN
  p.CursorOn();
  p.PositionCursor();
  REPEAT
    ch:=p.ReadKey();
    IF ch=0X THEN ex:=p.ReadKey()
    ELSE p.AddCharToLine(ch) END;
  UNTIL ch#0X;
  p.CursorOff();
  RETURN ch;
END ReadChar;

PROCEDURE (p:ListPaneP) WriteStr*(t:ARRAY OF CHAR);
VAR
  buf:ARRAY 200 OF CHAR;
  i,l,inx:LONGINT;
BEGIN
  Process.Yield();
  inx:=0;
  l:=Strings.Length(p.lastLine.txt^);
  WHILE t[inx]#0X DO 
    buf:="";
    i:=0;
    WHILE (t[inx]#0X) & (t[inx]#0DX) & (t[inx]#0AX) & (i+l<=maxLineChars) DO
      buf[i]:=t[inx];
      INC(i);
      INC(inx);
    END;
    buf[i]:=0X;
    Strings.Append(p.lastLine.txt^,buf);
    IF p.update THEN p.UpdateLastLine() END;
    IF (t[inx]=0DX) OR (t[inx]=0AX) THEN
      IF ((t[inx]=0DX) & (t[inx+1]=0AX)) OR ((t[inx]=0AX) & (t[inx+1]=0DX)) THEN INC(inx) END;
      INC(inx);
      p.AddEmptyLine;
    ELSE
      IF t[inx]#0X THEN p.AddEmptyLine END;
    END;
    l:=0;
  END;
END WriteStr;

PROCEDURE (p:ListPaneP) WriteLn*();
BEGIN
  p.AddEmptyLine();
END WriteLn;

PROCEDURE (p:ListPaneP) MaxLineLength*():INTEGER;
BEGIN
  RETURN maxLineChars;
END MaxLineLength;

PROCEDURE (p:ListPaneP) CurrentLineLength*():INTEGER;
BEGIN
  RETURN SHORT(Strings.Length(p.lastLine.txt^));
END CurrentLineLength;

PROCEDURE (p:ListPaneP) SetScreenUpdate*(x:BOOLEAN);
VAR
  rect:WD.RECT;
  dummy:WD.BOOL;
BEGIN
  IF x & ~p.update THEN
    p.ManageScrollBars;
    p.ScrollLastPosition;
    dummy:=WU.GetClientRect(p.hwnd,rect);
    dummy:=WU.InvalidateRect(p.hwnd,rect,1);
  END;
  p.update:=x;
END SetScreenUpdate;

PROCEDURE (p:ListPaneP) ReadLongInt*(maxLng:INTEGER):LONGINT;
VAR
  t:ARRAY 30 OF CHAR;
  lng,currentLng:INTEGER;
  ch:CHAR;
  res:BOOLEAN;
  dummy:WD.BOOL;
BEGIN
  t:="";
  lng:=0;
  currentLng:=SHORT(Strings.Length(p.lastLine.txt^));
  IF currentLng+maxLng>=maxLineChars THEN 
    p.AddEmptyLine();
    currentLng:=0;
  END;
  p.CursorOn();
  p.PositionCursor();
  REPEAT
    ch:=p.ReadKey();
    IF (((ch>="0") & (ch<="9")) OR (ch="-")) & (lng<maxLng) THEN
      t[lng]:=ch;
      p.lastLine.txt^[currentLng+lng]:=ch;
      INC(lng);
      t[lng]:=0X;      
      p.lastLine.txt^[currentLng+lng]:=0X;
      p.UpdateLastLine();
    ELSIF (ch=08X) & (lng>0) THEN  
      DEC(lng);
      t[lng]:=0X;
      p.lastLine.txt^[currentLng+lng]:=0X;
      p.UpdateLastLine();
    ELSIF ch=0X THEN
      ch:=p.ReadKey();
      ch:=0X;
    ELSIF ch#0DX THEN
      dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
    END;
  UNTIL ch=0DX;
  p.CursorOff();
  Strings.RemoveLeadingSpaces(t);
  IF t="" THEN RETURN 0 ELSE RETURN Strings.Val(t) END;
END ReadLongInt;

PROCEDURE (p:ListPaneP) ReadStr*(VAR t:ARRAY OF CHAR);
VAR
  maxLng:INTEGER;
  lng,currentLng:INTEGER;
  ch:CHAR;
  dummy:WD.BOOL;
BEGIN
  maxLng:=SHORT(LEN(t));
  t[0]:=0X;
  lng:=0;
  currentLng:=SHORT(Strings.Length(p.lastLine.txt^));
  IF currentLng+maxLng>=maxLineChars THEN 
    p.AddEmptyLine();
    currentLng:=0;
  END;
  p.CursorOn();
  p.PositionCursor();
  REPEAT
    ch:=p.ReadKey(); 
    IF ch=08X THEN  
      IF lng>0 THEN
        DEC(lng);
        t[lng]:=0X;
        p.lastLine.txt^[currentLng+lng]:=0X;
        p.UpdateLastLine();
      END;
    ELSIF ch=0X THEN
      ch:=p.ReadKey(); ch:=0X;
    ELSIF (ch=0DX) OR (ch=1BX) THEN
    ELSIF (lng<maxLng-1) & (ch#0DX) & (ch#08X) THEN
      t[lng]:=ch;
      p.lastLine.txt^[currentLng+lng]:=ch;
      INC(lng);
      t[lng]:=0X;      
      p.lastLine.txt^[currentLng+lng]:=0X;
      p.UpdateLastLine();
    ELSE
      dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
    END;
  UNTIL ch=0DX;
  p.CursorOff();
END ReadStr;

PROCEDURE (p:ListPaneP) ReadReal*(VAR a:LONGREAL);
CONST
  maxLng=25;
VAR
  t:ARRAY 50 OF CHAR;
  lng,currentLng:INTEGER;
  ch:CHAR;
  res:BOOLEAN;
  h:LONGREAL;
  dummy:WD.BOOL;
BEGIN
  t:="";
  lng:=0;
  currentLng:=SHORT(Strings.Length(p.lastLine.txt^));
  IF currentLng+maxLng>=maxLineChars THEN 
    p.AddEmptyLine();
    currentLng:=0;
  END;
  p.CursorOn();
  p.PositionCursor();
  REPEAT
    ch:=p.ReadKey();
    IF (((ch>="0") & (ch<="9")) OR (ch="e") OR (ch="E") OR (ch="-") OR (ch=".")) & (lng<maxLng) THEN
      t[lng]:=ch;
      p.lastLine.txt^[currentLng+lng]:=ch;
      INC(lng);
      t[lng]:=0X;      
      p.lastLine.txt^[currentLng+lng]:=0X;
      p.UpdateLastLine();
    ELSIF (ch=08X) & (lng>0) THEN  
      DEC(lng);
      t[lng]:=0X;
      p.lastLine.txt^[currentLng+lng]:=0X;
      p.UpdateLastLine();
    ELSIF ch=0X THEN
      ch:=p.ReadKey();
      ch:=0X;
    ELSIF ch#0DX THEN
      dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
    END;
  UNTIL ch=0DX;
  p.CursorOff();
  IF Float.ValResult(t)>Float.ISLONGREAL THEN a:=MIN(LONGREAL) ELSE a:=Float.Val(t) END;
END ReadReal;

PROCEDURE (p:ListPaneP) Shutdown*():LONGINT;
VAR
  old,ele:LineEleP;
BEGIN
  ele:=p.firstLine;
  WHILE ele#NIL DO
    old:=ele;
    ele:=ele.next;
    DISPOSE(old);
  END;
  RETURN p.Shutdown^();
END Shutdown;

PROCEDURE (p:ListPaneP) Print*();
VAR
  ele:LineEleP;
BEGIN
  IF P.StartWithDialog() THEN
    P.SetLeftMargin(WinUtils.LeftPrintMargin());
    P.SetTopMargin(WinUtils.TopPrintMargin());
    ele:=p.firstLine;
    WHILE ele#NIL DO
      P.Str(ele.txt^);
      P.Ln;
      ele:=ele.next;
    END;
    P.Finished;
  END;
END Print;

END ListPane.
