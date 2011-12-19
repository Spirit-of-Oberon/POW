(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE WinUtils;

IMPORT GDI:=WinGDI,WD:=WinDef,WU:=WinUser,SYSTEM,Utils,Strings,OOBase;

CONST
  COLOR_RED* = 000000FFH;
  COLOR_BLUE*= 00FF0000H;
  COLOR_GREEN*=0000FF00H;
  COLOR_WHITE*=00FFFFFFH;
  COLOR_BLACK*=00000000H;
  
  TOPPRINTMARGIN=20;
  LEFTPRINTMARGIN=20;
  

VAR
  RED_PEN-:WD.HPEN;
  BLUE_PEN-:WD.HPEN;
  GREEN_PEN-:WD.HPEN;
  WHITE_PEN-:WD.HPEN;
  BLACK_PEN-:WD.HPEN;
  WHITE_BRUSH-:WD.HBRUSH;
  GRAY_BRUSH-:WD.HBRUSH;
  inPaintIcon:BOOLEAN;
  references:INTEGER;

PROCEDURE TopPrintMargin*():LONGINT;
BEGIN
  RETURN TOPPRINTMARGIN;
END TopPrintMargin;

PROCEDURE LeftPrintMargin*():LONGINT;
BEGIN
  RETURN LEFTPRINTMARGIN;
END LeftPrintMargin;

PROCEDURE GetRGB*(x:WD.COLORREF; VAR r,g,b:INTEGER);
BEGIN
  r:=SHORT(Utils.BitAndL(x,00000FFH));
  g:=SHORT(Utils.BitAndL(x,000FF00H) DIV 100H);
  b:=SHORT(Utils.BitAndL(x,0FF0000H) DIV 10000H);
END GetRGB;

PROCEDURE RGB*(r,g,b:INTEGER):WD.COLORREF;
VAR
  l:LONGINT;
BEGIN
  l:=b;
  l:=SYSTEM.LSH(l,8);
  l:=Utils.BitOrL(l,g);
  l:=SYSTEM.LSH(l,8);
  l:=Utils.BitOrL(l,r);
  RETURN SYSTEM.VAL(WD.COLORREF,l);
END RGB;

PROCEDURE IsClassRegistered*(instance:WD.HINSTANCE; class:ARRAY OF CHAR):BOOLEAN;
VAR
  res:WD.BOOL;
  info:WU.WNDCLASS;
BEGIN
  res:=WU.GetClassInfoA(instance,SYSTEM.ADR(class),info);
  RETURN res#0;
END IsClassRegistered;

PROCEDURE GetReasonableFixedFont*():WD.HFONT;
VAR
  x:INTEGER;
  width:LONGINT;
  font:WD.HFONT;
BEGIN
  width:=WU.GetSystemMetrics(WU.SM_CXSCREEN);
  IF width<=640 THEN x:=14
  ELSIF width<=800 THEN x:=15
  ELSIF width<=1024 THEN x:=22
  ELSE x:=22 END;
  font:=GDI.CreateFontA(x,0,0,0,
                     GDI.FW_NORMAL,
                     0,0,0,
                     GDI.ANSI_CHARSET,
                     GDI.OUT_STROKE_PRECIS,
                     GDI.CLIP_DEFAULT_PRECIS,
                     GDI.PROOF_QUALITY,
                     GDI.FF_DONTCARE+GDI.FIXED_PITCH,
                     SYSTEM.ADR("Fixedsys"));
  IF font#WD.NULL THEN RETURN font END;
  RETURN GDI.CreateFontA(x,0,0,0,
                      GDI.FW_NORMAL,
                      0,0,0,
                      GDI.ANSI_CHARSET,
                      GDI.OUT_STROKE_PRECIS,
                      GDI.CLIP_DEFAULT_PRECIS,
                      GDI.DEFAULT_QUALITY,
                      GDI.FF_DONTCARE+GDI.FIXED_PITCH,
                      SYSTEM.ADR("Courier New")); 
END GetReasonableFixedFont;

PROCEDURE Prepare*;
BEGIN
  IF references=0 THEN
    RED_PEN:=GDI.CreatePen(GDI.PS_SOLID,1,COLOR_RED);
    BLUE_PEN:=GDI.CreatePen(GDI.PS_SOLID,1,COLOR_BLUE);
    GREEN_PEN:=GDI.CreatePen(GDI.PS_SOLID,1,COLOR_GREEN);
    WHITE_PEN:=GDI.CreatePen(GDI.PS_SOLID,1,COLOR_WHITE);
    BLACK_PEN:=GDI.CreatePen(GDI.PS_SOLID,1,COLOR_BLACK);
    WHITE_BRUSH:=GDI.GetStockObject(GDI.WHITE_BRUSH);
    GRAY_BRUSH:=GDI.GetStockObject(GDI.LTGRAY_BRUSH);
  END;
  INC(references);
END Prepare;

PROCEDURE Down*;
VAR
  dummy:WD.BOOL;
BEGIN
  DEC(references);
  IF references=0 THEN
    dummy:=GDI.DeleteObject(RED_PEN);
    dummy:=GDI.DeleteObject(BLUE_PEN);
    dummy:=GDI.DeleteObject(GREEN_PEN);
    dummy:=GDI.DeleteObject(WHITE_PEN);
    dummy:=GDI.DeleteObject(BLACK_PEN);
  END;
END Down;

PROCEDURE WriteStr*(t:ARRAY OF CHAR);
BEGIN
  IF WU.MessageBoxA(0,SYSTEM.ADR(t[0]),SYSTEM.ADR("Show String"),
                  WU.MB_RETRYCANCEL+WU.MB_ICONEXCLAMATION+
                  WU.MB_APPLMODAL)#WU.IDRETRY THEN END;
END WriteStr;

PROCEDURE WriteChar*(ch:CHAR);
VAR
  t:ARRAY 2 OF CHAR;
BEGIN
  t[0]:=ch;
  t[1]:=0X;
  IF WU.MessageBoxA(0,SYSTEM.ADR(t[0]),SYSTEM.ADR("Show Char"),
                  WU.MB_RETRYCANCEL+WU.MB_ICONEXCLAMATION+
                  WU.MB_APPLMODAL)#WU.IDRETRY THEN END;
END WriteChar;

PROCEDURE WriteInt*(i:LONGINT);
VAR
  t:ARRAY 30 OF CHAR;
BEGIN
  Strings.Str(i,t);
  WriteStr(t);
END WriteInt;

PROCEDURE WriteHexInt*(i:LONGINT);
VAR
  t:ARRAY 30 OF CHAR;
BEGIN
  Strings.HexStr(i,t);
  WriteStr(t);
END WriteHexInt;

PROCEDURE WriteObj*(txt:ARRAY OF CHAR; p:OOBase.Object);
VAR
  t1,t2:ARRAY 200 OF CHAR;
BEGIN
  OOBase.ObjToName(p,t1,t2);
  Strings.AppendChar(t1,"\");
  Strings.Append(t1,t2);
  Strings.InsertChar(0AX,t1,1);
  Strings.Insert(txt,t1,1);
  IF WU.MessageBoxA(0,SYSTEM.ADR(t1),SYSTEM.ADR("Show Object"),
                  WU.MB_RETRYCANCEL+WU.MB_ICONEXCLAMATION+
                  WU.MB_APPLMODAL)#WU.IDRETRY THEN END;
END WriteObj;

PROCEDURE WriteError*(txt:ARRAY OF CHAR);
VAR
  i,flags:INTEGER;
BEGIN
  i:=0;
  WHILE txt[i]#0X DO
    IF txt[i]="$" THEN txt[i]:=0AX END;
    INC(i);
  END;
  flags:=SYSTEM.BITOR(WU.MB_OK,WU.MB_ICONEXCLAMATION);
  flags:=SYSTEM.BITOR(flags,WU.MB_TASKMODAL);
  IF WU.MessageBoxA(0,SYSTEM.ADR(txt),SYSTEM.ADR("Error"),flags)#0 THEN END;
END WriteError;
      
BEGIN
  inPaintIcon:=FALSE;
  references:=0;
END WinUtils.
