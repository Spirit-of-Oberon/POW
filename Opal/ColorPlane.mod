(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module provides easy to use simple color graphics.
  
  All output operations represent their output in a drawing region with fixed
  resolution. This implementation provides an area of 800 x 650 pixel (horizontal
  by vertical).

  The left bottom corner of the output area has the co-ordinate (0,0), the same
  as for the Cartesian system of co-ordinates.

  The definition of colors is based upon a true-color model which defines the
  colors by their relative concentrations of red, green and blue. As not 
  every system supports a true-color display the desired colors are mapped
  to the nearest available colors.

  A cursor is used to indicate the position for input and output of text. It
  can be positioned by calling the relevant procedures and appears as a 
  flashing mark on the screen.
  ----------------------------------------------------------------------------*)

MODULE ColorPlane;

IMPORT I:=IOManage, AppGrp, CBitPane;

CONST
  draw*=1;          (** \HIDE *)
  erase*=0;         (** \HIDE *)
  DRAW*=1;          (** required with the parameter <mode> to draw with the foreground color *)
  ERASE*=0;         (** required with the parameter <mode> to draw with the background color *)
  RESOLUTIONX*=800; (** horizontal resolution of the drawing area *)
  RESOLUTIONY*=650; (** vertical resolution of the drawing area *)

  BACKSPACE*=8X;
  CURSDOWN*=28X;
  CURSLEFT*=25X;
  CURSRIGHT*=27X;
  CURSUP*=26X;
  DELETE*=2EX;
  ENDKEY*=23X;
  ENTER*=0DX;
  ESC*=1BX;
  F1* = 70X; F2* = 71X; F3* = 72X; F4* = 73X;
  F5* = 74X; F6* = 75X; F7* = 76X; F8* = 77X;
  F9* = 78X; F10*= 79X; F11*= 7AX; F12*= 7BX;
  F13*=0D4X; F14*=0D5X; F15*=0D6X; F16*=0D7X;
  F17*=0D8X; F18*=0D9X; F19*=0DAX; F20*=0DBX;
  F21*=0DCX; F22*=0DDX; F23*=0DEX; F24*=0DFX;
  HOME*=24X;
  INSERT*=2DX;
  PAGEDOWN*=22X;
  PAGEUP*=21X;
  TAB*=9X;

  INPUTINVALID*=0X;

VAR
  app:I.InOutAppP;
  colorPane:CBitPane.CBitmapPaneP;

PROCEDURE Bar*(x1,y1,x2,y2:INTEGER;
               mode:INTEGER);
(** Draws a filled rectangle where the left top corner is defined by the 
    co-ordinate (<x1>,<y1>) and the right bottom corner by (<x2>,<y2>).
    <mode> determines whether the rectangle is drawn in the current 
    foreground or background color. The value <DRAW> represents the foreground 
    color, <ERASE> the background color. *)
BEGIN
  colorPane.Bar(x1,y1,x2,y2,mode);
END Bar;

PROCEDURE Box*(x1,y1,x2,y2:INTEGER; 
               mode:INTEGER);
(** Draws a rectangle where the left top corner is defined by the 
    co-ordinates (<x1>,<y1>) and the right bottom corner by (<x2>,<y2>).
    <mode> determines whether the rectangle is drawn in the current 
    foreground or background color. The value <DRAW> represents the 
    foreground color, <ERASE> the background color. *)
BEGIN
  colorPane.Box(x1,y1,x2,y2,mode);
END Box;

PROCEDURE Clear*();
(** The whole drawing area is cleared, or in other words, set to the 
    current background color. *)
BEGIN
  colorPane.Clear();
END Clear;

PROCEDURE Close*();
(** The display area for the graphics is closed. The free space in the
    program window is divided for the remaining output areas (e.g.,
    for the modules <Display> or <Out>). *)
BEGIN
  app.CloseColorPlane();
END Close;

PROCEDURE CursorOff*();
(** The cursor becomes invisible. Its position and function remain unchanged. *)
BEGIN
  colorPane.CursorOff();
END CursorOff;

PROCEDURE CursorOn*();
(** The cursor is displayed. *)
BEGIN
  colorPane.CursorOn();
END CursorOn;

PROCEDURE Dot*(x,y: INTEGER;
               mode:INTEGER);
(** Draws a dot at the co-ordinate (x,y). The value DRAW for mode draws the 
    dot in the current foreground color and ERASE selects the background color. *)
BEGIN
  colorPane.SetDot(x,y,mode);
END Dot;

PROCEDURE EditStr*(VAR aString:ARRAY OF CHAR; maxLen:INTEGER; VAR resCode:CHAR);
(** The text passed in <aString> is displayed, then the cursor is displayed and 
    an input from the keyboard is awaited. The input line may be edited using the 
    delete, cursor left, and cursor right keys. The entered string is shown on 
    the screen.
    
    The maximum length of the input is limited by the length of the array passed 
    in <aString>. In addition, it may be limited by <maxLen>.
    The input may be finished by using the enter or the escape key. 
    
    The code of the terminating key used is returned in <resCode>.  *)
BEGIN
  colorPane.EditStr(aString,maxLen,resCode);
END EditStr;

PROCEDURE GetBackColor*(VAR red,green,blue:INTEGER);
(** The current background color values are returned in <red>, <green>,
    and <blue>. *)
BEGIN
  colorPane.GetBackColor(red,green,blue);
END GetBackColor;

PROCEDURE GetDot*(x,y:INTEGER; VAR r,g,b:INTEGER);
(** The actual color of the point with the co-ordinate (<x>,<y>) is returned, 
    separated into red, green, and blue components. If the system does not 
    support true-color display the color reported by GetDot may deviate from 
    the color values previously passed to SetDot. *)
BEGIN
  colorPane.GetDotColor(x,y,r,g,b);
END GetDot;

PROCEDURE GetForeColor*(VAR red,green,blue:INTEGER);
(** The current foreground color values are returned in <red>, <green>, 
    and <blue>. *)
BEGIN
  colorPane.GetForeColor(red,green,blue);
END GetForeColor;

PROCEDURE GetMouse*(VAR buttons:SET; VAR x,y:INTEGER);
(** The co-ordinates of the current mouse position are returned in <x> and <y>. 
    The mouse buttons currently pressed are returned in <buttons>. 
    The following coding is used:
    
    0 = left button
    
    1 = central button
    
    2 = right button 
    
    The mouse pointer may also be located outside the possible drawing area. 
    In this situation at least one mouse co-ordinate is either less than zero
    or more than or equal to the corresponding <RESOLUTION> constant. *)
VAR
  xh,yh:LONGINT;
BEGIN
  colorPane.GetMouse(buttons,xh,yh);
  x:=SHORT(xh);
  y:=SHORT(yh);
END GetMouse;

PROCEDURE GotoXY*(x,y:INTEGER);
(** The cursor is set to the co-ordinate (<x>,<y>) position. *)
BEGIN
  colorPane.GotoXY(x,y);
END GotoXY;

PROCEDURE IsCursorOn*():BOOLEAN;
(** The return value of this function is TRUE if the cursor is visible. *)
BEGIN
  RETURN colorPane.IsCursorOn();
END IsCursorOn;

PROCEDURE KeyPressed*():BOOLEAN;
(** The return value of the function is TRUE if a key was pressed; 
    the corresponding code is stored in the keyboard buffer and may 
    be read by calling ReadKey. *)
BEGIN
  RETURN colorPane.KeyPressed();
END KeyPressed;

PROCEDURE Line*(x1,y1,x2,y2,mode:INTEGER);
(** Draws a line starting from the co-ordinate (<x1>,<y1>) to the co-ordinate 
    (<x2>,<y2>). <mode> determines whether the line is drawn in the current 
    foreground or background color. The value <DRAW> represents the foreground 
    color, <ERASE> the background color. *)
BEGIN
  colorPane.Line(x1,y1,x2,y2,mode);
END Line;

PROCEDURE Open*();
(** The display area for the graphics is created in the program window.
    This function must be called before any other function in the module
    as it provides the initialization. *)
BEGIN
  app.OpenColorPlane();
  colorPane:=app.colorPane;
  ASSERT(colorPane#NIL);
END Open;

PROCEDURE ReadKey*():CHAR;
(** This function waits for the next key and returns its character value. 
    This character is not displayed on the screen. If the key cannot be 
    represented by an ASCII code, the result of the function is initially 
    zero. The next call of the function returns a code which identifies a 
    special key (e.g., the function keys or the cursor keys). *)
BEGIN
  RETURN colorPane.ReadKey();
END ReadKey;

PROCEDURE ReadStr*(VAR aString:ARRAY OF CHAR; (** returns the result *)
                   maxLen:INTEGER;            (** limits the length of the input *)
                   VAR resCode:CHAR           (** set to either <ENTER> or <ESC>,
                                                  see the text below *)
                  );
(** The cursor is displayed and the procedure waits for key input. The string 
    that is entered is displayed on the screen.
    The maximum length of the input string is limited by the length of the 
    array passed in <aString>. In addition to this, it may be limited by <maxLen>.
    The input action can be terminated with either the enter and the escape key. 
    In the first case the value <ENTER> is returned in <resCode>, in the second 
    the value <ESC>. *)
BEGIN
  colorPane.ReadStr(aString,maxLen,resCode);
END ReadStr;

PROCEDURE SetBackColor*(red,green,blue:INTEGER);
(** The new background color is set. The color is defined by the red, 
    green, and blue values contained in <red>, <green>, and <blue>.
    The color values range from 0 to 255.
    
    If the system cannot provide the desired color then the nearest available 
    color is selected. *)
BEGIN
  colorPane.SetBackColor(red,green,blue);
END SetBackColor;

PROCEDURE SetForeColor*(red,green,blue:INTEGER);
(** Sets the new foreground color for all subsequent drawing operations. 
    The color is defined by the red, green, and blue values contained in 
    <red>, <green>, and <blue>. The color values range from 0 to 255.
    
    If the system cannot provide the desired color then the nearest available 
    color is selected. *)
BEGIN
  colorPane.SetForeColor(red,green,blue);
END SetForeColor;

PROCEDURE SetScreenUpdate*(x:BOOLEAN);
(** This function inhibits drawing visibly on the screen if <x> is FALSE;
    if TRUE then drawing is as normal.
    When the update is re-enabled again all changes that have taken place
    in the meantime are displayed automatically. *)
BEGIN
  colorPane.SetScreenUpdate(x);
END SetScreenUpdate;

PROCEDURE TextHeight*():INTEGER;
(** The return value of this function is the height of the character set (font) 
    currently in use. *)
BEGIN
  RETURN SHORT(colorPane.TextHeight());
END TextHeight;

PROCEDURE TextWidth*(VAR txt:ARRAY OF CHAR):INTEGER;
(** The return value of this function is the width of the string <txt> if it 
    were written with the character set currently in use. *)
BEGIN
  RETURN SHORT(colorPane.TextWidth(txt));
END TextWidth;

PROCEDURE WhereX*():INTEGER;
(** The return value of this function is the X-co-ordinate of the cursor 
    position. *)
BEGIN
  RETURN SHORT(colorPane.WhereX());
END WhereX;

PROCEDURE WhereY*():INTEGER;
(** The return value of this function is the Y-co-ordinate of the cursor 
    position. *)
BEGIN
  RETURN SHORT(colorPane.WhereY());
END WhereY;

PROCEDURE WriteLn*();
(** The cursor is moved to the left edge of the drawing region and then 
    one text line down (i.e., the height of the character set in use). *)
BEGIN
  colorPane.WriteLn();
END WriteLn;

PROCEDURE WriteStr*(txt:ARRAY OF CHAR);
(** The string <txt> is written to the screen starting at the cursor position, 
    and results in the cursor being moved to the end of the output. If the 
    left edge of the drawing area is reached then the output is truncated. 
    A carriage return/line feed is not provided automatically. *)
BEGIN
  colorPane.WriteStr(txt);
END WriteStr;

PROCEDURE Init;
VAR
  h:AppGrp.AppP;
BEGIN
  h:=AppGrp.GetApp();
  app:=h(I.InOutAppP);
  colorPane:=NIL;
END Init;

BEGIN
  Init;
END ColorPlane.
