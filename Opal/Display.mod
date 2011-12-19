(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module provides a simple, text-oriented user interface. It is an easy
  to understand basis especially for programmers just starting to use Oberon-2.
  Its main purpose is to make it easy to display text from a Windows program.
  As far as its features are concerned it is adapted to the possibilities of
  usual devices operating in the text mode.

  In this implementation a window is used for displaying up to 80 characters
  and 25 lines with a non-proportional font. If the size of the window is 
  reduced any desired section of the whole window can be viewed using scroll
  bars.
  
  All procedures for input and output access a virtual text screen with 80 
  characters and 25 lines. This text screen is called virtual because all 
  functions are described in a way as if they controlled the complete screen 
  operated in text mode. The actual implementation details are hidden from 
  the programmer.
  
  The character positions of the usable area can be directly referenced by 
  their line and column position. The character in the left top corner has 
  the position column one, line one by convention.
  
  For positioning the input and output, a special mark called the cursor may 
  be positioned anywhere by calling the appropriate procedures, and appears 
  as a flashing mark on the screen. It may also be hidden; when invisible 
  its position is still maintained on the virtual screen.
  
  There are two groups of output procedures. One group is characterized by 
  procedure names ending with "XY" and can be used for output at any position. 
  The second group of procedures serves for output at the current cursor 
  position; after the output has taken place the cursor is moved on. When
  the program is started the cursor is always initialized at the left top corner.
  
  Output that would go over the end of the line is continued on the next line.
  If this happens in the last line or if a line feed with WriteLn is executed 
  in the last line, the whole screen contents is moved up one line. The new 
  "last" line is now empty and may be used for further output, while the old
  "first" line is lost.
  
  All input procedures expect input typed at the current cursor position. 
  Input functions with a parameter resCode return a code which represents 
  the character used to terminate the input (e.g., enter or escape key).
 ----------------------------------------------------------------------------*)

MODULE Display;

IMPORT SYSTEM, WD:=WinDef, WU:=WinUser,
       I:=IOManage,AppGrp,Float,Strings,ScreenPane;

CONST
  CURSUP*=26X;
  CURSDOWN*=28X;
  CURSLEFT*=25X;
  CURSRIGHT*=27X;
  INSERT*=2DX;
  DELETE*=2EX;
  HOME*=24X;
  ENDKEY*=23X;
  PAGEUP*=21X;
  PAGEDOWN*=22X;
  F1*=70X;
  F2*=71X;
  F3*=72X;
  F4*=73X;
  F5*=74X;
  F6*=75X;
  F7*=76X;
  F8*=77X;
  F9*=78X;
  F10*=79X;
  F11*=7AX;
  F12*=7BX;
  F13*=0D4X;
  F14*=0D5X;
  F15*=0D6X;
  F16*=0D7X;
  F17*=0D8X;
  F18*=0D9X;
  F19*=0DAX;
  F20*=0DBX;
  F21*=0DCX;
  F22*=0DDX;
  F23*=0DEX;
  F24*=0DFX;
  ENTER*=0DX;
  ESC*=1BX;
  TAB*=9X;
  BACKSPACE*=8X;
  INPUTINVALID*=0X;

VAR
  screenPane:ScreenPane.ScreenPaneP;

PROCEDURE SetWindowTitle*(t:ARRAY OF CHAR);
(** The title of the program window is set to the string passed in <t>.
    In implementations of OPAL on other systems, e.g., on text-oriented 
    systems without any space for displaying a program title, this procedure 
    may have no effect. *)
VAR
  app:AppGrp.AppP;
  dummy:WD.BOOL;
BEGIN
  app:=AppGrp.GetApp();
  dummy:=WU.SetWindowTextA(app(I.InOutAppP).hwnd,SYSTEM.ADR(t));
END SetWindowTitle;

PROCEDURE GotoXY*(s,z:INTEGER);
(** The cursor is moved to column s and line z. If the stated position is 
    invalid the cursor is positioned at column one, line one. *)
BEGIN
  screenPane.GotoXY(s,z);
END GotoXY;

PROCEDURE WhereX*():INTEGER;
(** The return value of this function is the column of the current cursor position. *)
BEGIN
  RETURN SHORT(screenPane.WhereX());
END WhereX;

PROCEDURE WhereY*():INTEGER;
(** The return value of this function is the line of the current cursor position. *)
BEGIN
  RETURN SHORT(screenPane.WhereY());
END WhereY;

PROCEDURE WriteCharXY*(s,z:INTEGER; x:CHAR);
(** The character contained in <x> is printed at the position column <s>, line <z>. *)
BEGIN
  screenPane.WriteCharXY(s,z,x);
END WriteCharXY;

PROCEDURE GetCharXY*(s,z:INTEGER):CHAR;
(** This function returns the value of the character which is currently 
    displayed at column <s>, line <z>. *)
BEGIN
  RETURN screenPane.GetCharXY(s,z);
END GetCharXY;

PROCEDURE GetStrXY*(s,z,n:INTEGER; VAR t:ARRAY OF CHAR);
(** Starting at column <s>, line <z>, the following <n> characters displayed 
    on the screen are copied to the array <t>. After the last copied character 
    a character with the code zero is written so that <t> can be used as a string.
    
    If <n> is sufficiently large several lines can be copied with a single call. 
    If <t> is not big enough fewer characters are copied (max. LEN(<t>)-1 characters). *)
BEGIN
  screenPane.GetStrXY(s,z,n,t);
END GetStrXY;

PROCEDURE WriteLn*();
(** The cursor is moved to the beginning of the next line. If the cursor was 
    already situated in the last available line, then the whole contents of 
    the screen is moved one line up. So the last line is empty and may be 
    used for further output. The former first line is lost. *)
BEGIN
  screenPane.WriteLn();
END WriteLn;

PROCEDURE WriteChar*(x:CHAR);
(** The character contained in <x> is displayed at the current cursor position. 
    Afterwards the cursor is moved on one character. *)
BEGIN
  screenPane.WriteChar(x);
END WriteChar;

PROCEDURE WriteStrXY*(s,z:INTEGER; t:ARRAY OF CHAR);
(** The string passed in <t> is displayed in column <s>, line <z>. *)
BEGIN
  screenPane.WriteStrXY(s,z,t);
END WriteStrXY;

PROCEDURE WriteStr*(t:ARRAY OF CHAR);
(** The string contained in <t> is displayed at the current cursor position. 
    Afterwards the cursor is moved to the end of the output.
    Each occurrence of the control characters CR, LF, or CR LF is not 
    written out but interpreted as a new line command. *)
BEGIN
  screenPane.WriteStr(t);
END WriteStr;

PROCEDURE WriteSpacesXY*(s,z:INTEGER; n:INTEGER);
(** This procedure displays <n> blanks starting at column <s>, line <z>. *)
BEGIN
  screenPane.WriteSpacesXY(s,z,n);
END WriteSpacesXY;

PROCEDURE WriteSpaces*(n:INTEGER);
(** <n> blanks are printed at the current cursor position. Then the cursor 
    is moved to the end of the output. *)
BEGIN
  screenPane.WriteSpaces(n);
END WriteSpaces;

PROCEDURE WriteIntXY*(s,z:INTEGER; x:LONGINT; len:INTEGER);
(** The value of <x> is displayed in column <s>, line <z>.
    The width of the output is <len> characters. The number is displayed 
    right aligned. If the number is too big to be represented with <len>
    characters, the output is widened appropriately. *)
BEGIN
  screenPane.WriteIntXY(s,z,x,len);
END WriteIntXY;

PROCEDURE WriteInt*(x:LONGINT; len:INTEGER);
(** The value contained in <x> is displayed at the current cursor position. 
    The width of the output is <len> characters or more if this is necessary 
    for the representation of the number. If a representation with <len> 
    characters is possible the number is written right aligned. Then the
    cursor is moved to the end of the output. *)
BEGIN
  screenPane.WriteInt(x,len);
END WriteInt;

PROCEDURE WriteRealXY*(s,z:INTEGER; x:LONGREAL; len:INTEGER);
(** The value of <x> is displayed in column <s>, line <z>. The width of the 
    output is <len> characters or more in case this is necessary for the 
    representation of the number. If a representation is possible with 
    <len> characters, the number is written right aligned. *)
VAR
  t:ARRAY 255 OF CHAR;
BEGIN
  IF len<5 THEN len:=5 END;
  IF (ABS(x)>10000) OR
     ((ABS(x)>0.001) & (ABS(x*100-ENTIER(x*100+0.5))<0.00001)) THEN
    Float.StrF(x,len-4,2,t);
  ELSE
    t[0]:="$";
  END;
  IF t[0]="$" THEN Float.StrL(x,len,t) END;
  screenPane.WriteStrXY(s,z,t);
END WriteRealXY;

PROCEDURE WriteReal*(x:LONGREAL; len:INTEGER);
(** The value contained in <x> is written at the current cursor position. 
    The width of the output is <len> characters or more if this necessary 
    for the representation of the number. If a representation with <len>
    characters is possible then the number is written right aligned. 
    Afterwards the cursor is moved to the end of the output. *)
BEGIN
  WriteRealXY(SHORT(screenPane.cursX),SHORT(screenPane.cursY),x,len);
END WriteReal;

PROCEDURE KeyPressed*():BOOLEAN;
(** The return value of this function is TRUE if a key was pressed and 
    the corresponding code in the keyboard buffer is waiting to be read
    by a call of ReadKey. *)
BEGIN
  RETURN screenPane.KeyPressed();
END KeyPressed;

PROCEDURE ReadKey*():CHAR;
(** The next key is awaited. The return value of the function is the 
    character entered next; no output on the screen is effected.
    
    If the pressed key does not have an ASCII code the result of the 
    function is initially returned as zero. The next call of this 
    function returns a key code which serves to identify the special 
    key (e.g., the function keys or the cursor keys). *)
BEGIN
  RETURN screenPane.ReadKey();
END ReadKey;

PROCEDURE CursorOn*();
(** The cursor is displayed. *)
BEGIN
  screenPane.CursorOn();
END CursorOn;

PROCEDURE CursorOff*();
(** The cursor becomes invisible. Its position and function remain unchanged. *)
BEGIN
  screenPane.CursorOff();
END CursorOff;

PROCEDURE IsCursorOn*():BOOLEAN;
(** The return value of this function is TRUE if the cursor is visible. *)
BEGIN
  RETURN screenPane.IsCursorOn();
END IsCursorOn;

PROCEDURE TerminalBell*();
(** A short sound is emitted. *)
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WU.MessageBeep(WU.MB_ICONEXCLAMATION);
END TerminalBell;

PROCEDURE ReadChar*(VAR x:CHAR); 
(** The next key is awaited. The character entered next is returned in <x>
    and is displayed on the screen at the current cursor position. Keys that 
    do not return an ASCII code are ignored, e.g., all cursor keys and the 
    function keys. *)
BEGIN
  screenPane.ReadChar(x);
END ReadChar;

PROCEDURE ReadLongInt*(VAR x:LONGINT; maxLen:INTEGER; VAR resCode:CHAR);
(** The cursor is displayed and an input from the keyboard is awaited. 
    The only valid characters are "0" to "9" and the minus symbol.
    
    The length of the input can be limited with <maxLen>.
    
    The input may be terminated using either the enter or the escape key.
    If the enter key was used then the input is converted to a value of 
    the type LONGINT and returned in <x>. In <resCode> the value ENTER is 
    returned. In case the correct conversion of the input to a number is 
    impossible resCode is set to INPUTINVALID.
    
    If the input is interrupted by the escape key <x> is set to 
    zero and <resCode> returns the value ESC. *)
BEGIN
  screenPane.ReadLongInt(x,maxLen,resCode);
END ReadLongInt;

PROCEDURE ReadReal*(VAR x:REAL; maxLen:INTEGER; VAR resCode:CHAR);
(** The cursor is displayed and an input from the keyboard is awaited. 
    The only characters accepted are "0" to "9", "." and "-".
    
    The length of the input can be limited by maxLen.
    The input can be terminated with either the enter or escape key.
    
    If the enter key is used then the input is converted to a value of 
    the type REAL and returned in <x>. In <resCode> the value ENTER is 
    returned. In case the correct conversion of the input to a number 
    is impossible <resCode> is set to INPUTINVALID.
    
    If the input is interrupted by the escape key <x> is set to zero 
    and <resCode> returns the value ESC. *)
BEGIN
  screenPane.ReadReal(x,maxLen,resCode);
END ReadReal;

PROCEDURE ReadLongReal*(VAR x:LONGREAL; maxLen:INTEGER; VAR resCode:CHAR);
(** The cursor is displayed and an input from the keyboard is awaited. 
    The only characters accepted are "0" to "9", "." and "-".
    
    The length of the input can be limited by maxLen.
    The input can be terminated with either the enter or escape key.
    
    If the enter key is used then the input is converted to a value of 
    the type LONGREAL and returned in <x>. In <resCode> the value ENTER is 
    returned. In case the correct conversion of the input to a number 
    is impossible <resCode> is set to INPUTINVALID.
    
    If the input is interrupted by the escape key <x> is set to zero 
    and <resCode> returns the value ESC. *)
BEGIN
  screenPane.ReadLongReal(x,maxLen,resCode);
END ReadLongReal;

PROCEDURE ReadInt*(VAR x:INTEGER; maxLen:INTEGER; VAR resCode:CHAR);
(** The cursor is displayed and an input from the keyboard is awaited. 
    The only valid characters are "0" to "9" and the minus symbol.
    
    The length of the input can be limited with <maxLen>.
    
    The input may be terminated using either the enter or the escape key.
    If the enter key was used then the input is converted to a value of 
    the type INTEGER and returned in <x>. In <resCode> the value ENTER is 
    returned. In case the correct conversion of the input to a number is 
    impossible resCode is set to INPUTINVALID.
    
    If the input is interrupted by the escape key <x> is set to 
    zero and <resCode> returns the value ESC. *)
BEGIN
  screenPane.ReadInt(x,maxLen,resCode);
END ReadInt;

PROCEDURE ReadStr*(VAR aString:ARRAY OF CHAR; maxLen:INTEGER; VAR resCode:CHAR);
(** The cursor is displayed and an input from the keyboard is awaited. The input 
    string is shown on the screen. The maximum length of the input is limited 
    by the length of the array passed in <aString>. In addition, it may be 
    further limited by <maxLen>.
    
    The input can be terminated using either the enter or escape key. In 
    the first case the value ENTER is returned in <resCode<, in the second case ESC. *)
BEGIN
  screenPane.ReadStr(aString,maxLen,resCode);
END ReadStr;

PROCEDURE EditStr*(VAR aString:ARRAY OF CHAR; maxLen:INTEGER; VAR resCode:CHAR);
(** The text passed in <aString> is displayed. Then the cursor is displayed 
    and an input from the keyboard is awaited. The input line may be edited 
    using the delete, cursor left, and cursor right keys. The entered string 
    is shown on the screen. The maximum length of the input is limited by the
    length of the array passed in aString. In addition, it may be limited by <maxLen>.
    The input may be finished with one of the following keys: enter, escape, cursor up,
    cursor down, page up, page down, tabulator and the function keys. The code 
    of the terminating key used is returned in <resCode>. *)
BEGIN
  screenPane.EditStr(aString,maxLen,resCode);
END EditStr;

PROCEDURE FlushKeyBuffer*();
(** The keyboard buffer is cleared.
    This ensures that the next call of ReadKey does not return keys that were 
    pressed earlier but not processed. *)
BEGIN
  screenPane.FlushKeyBuffer();
END FlushKeyBuffer;

PROCEDURE ClrScr*();
(** The screen is cleared and set to the current background color 
    (see SetBackColor). When the program is started the background color is white. *)
BEGIN
  screenPane.ClrScr();
END ClrScr;

PROCEDURE SetForeColor*(red,green,blue:INTEGER);
(** All following output to the screen is drawn in the color defined by the 
    color values given in <red>, <green>, and <blue>. If the system cannot 
    provide the required color exactly, the nearest available color is selected.
    The values of the parameters red, green, and blue must be in the range 0 to 255. *)
BEGIN
  screenPane.SetForeColor(red,green,blue);
END SetForeColor;

PROCEDURE SetBackColor*(red,green,blue:INTEGER);
(** The background for all following output is set to the color defined 
    by <red>, <green>, and <blue>. This defined color is also used for clearing 
    the output region. If the system cannot provide the desired color exactly, 
    the nearest available color is used.
    The values for the parameters <red>, <<green>, and <blue> must be in the 
    range 0 to 255. *)
BEGIN
  screenPane.SetBackColor(red,green,blue);
END SetBackColor;

PROCEDURE GetForeColor*(VAR red,green,blue:INTEGER);
(** The text color currently used is returned in <red>, <green>, and <blue>
    according to their proportions. *)
BEGIN
  screenPane.GetForeColor(red,green,blue);
END GetForeColor;

PROCEDURE GetBackColor*(VAR red,green,blue:INTEGER);
(** The background color currently used is returned in <red>, <green>, and <blue> 
    according to their proportions. *)
BEGIN
  screenPane.GetBackColor(red,green,blue);
END GetBackColor;

PROCEDURE IsColorSupported*():BOOLEAN;
(** The return value of this function is TRUE if the system provides colors. 
    In the implementation based on Windows the result of this function is always TRUE.
    If the system does not support colors then the procedures described in this 
    section have no effect and the return values of GetForeColor and GetBackColor 
    are always zero. *)
BEGIN
  RETURN TRUE;
END IsColorSupported;

PROCEDURE Init;
VAR
  app:AppGrp.AppP;
BEGIN
  app:=AppGrp.GetApp();
  WITH app:I.InOutAppP DO
    app.OpenDisplay();
    screenPane:=app.screenPane;
    ASSERT(screenPane#NIL);
    screenPane.FlushKeyBuffer();
  END;
END Init;

BEGIN
  Init;
END Display.
