(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module supports very simple monochrome graphics.
  
  The interface of this module is call-compatible to the standard for the 
  simple graphics module defined in the Oakwood Guidelines.
  
  The drawing area uses a Cartesian system of co-ordinates with the (0,0) 
  origin in the bottom left hand corner. Dots can be drawn in either a 
  foreground or background color.
  ----------------------------------------------------------------------------*)

MODULE XYplane;

IMPORT I:=IOManage, BitPane, AppGrp;

CONST
  draw*=1;  (** Used for the parameter mode when the foreground color should be used *)
  erase*=0; (** Used for the parameter mode when the background color should be used *)
  
VAR
  W-:INTEGER; (** This write-protected variable contains the width (W) of the drawing area. *)
  H-:INTEGER; (** This write-protected variable contains the height (H) of the drawing area. *)
  X-:INTEGER; (** This write-protected variables contains the horizontal component of the
                  the position of the 
                  bottom left corner of the drawing area. In some implementations 
                  of this module the drawing area does not create its own local 
                  system of co-ordinates. If this is the case then all drawing 
                  operations must compensate (x,y) values with the required offsets.
                  
                  In the Windows implementation the drawing area creates its own 
                  system of co-ordinates with an origin at (0,0). *)
  Y-:INTEGER; (** This write-protected variables contains the vertical component of the
                  the position of the 
                  bottom left corner of the drawing area. In some implementations 
                  of this module the drawing area does not create its own local 
                  system of co-ordinates. If this is the case then all drawing 
                  operations must compensate (x,y) values with the required offsets.
                  
                  In the Windows implementation the drawing area creates its own 
                  system of co-ordinates with an origin at (0,0). *)

  xyPane:BitPane.BitmapPaneP;
  app:I.InOutAppP;

PROCEDURE Open*();
(** The module is initialized and the drawing area is created on the screen. 
    Open must be called before any other procedure of the module is called. *)
BEGIN
  app.OpenXYplane();
  xyPane:=app.xyPane;
  ASSERT(xyPane#NIL);
END Open;

PROCEDURE Close*();
(** The drawing area is closed and the space released on the screen is used 
    for the output of other modules (Display, Out, ColorPlane).
    
    This procedure is not defined in the Oakwood Guidelines. *)
BEGIN
  app.CloseXYplane();
END Close;

PROCEDURE Dot*(x,y,mode:INTEGER);
(** A dot is drawn at the co-ordinates (<x>,<y>) if <mode> has the value 
    <draw> or erased if mode has the value <erase>. *)
BEGIN
  IF mode=0 THEN xyPane.SetDot(x,y,0) ELSE xyPane.SetDot(x,y,1); END;
END Dot;

PROCEDURE IsDot*(x,y:INTEGER):BOOLEAN;
(** The return value of the function is TRUE if the dot with the co-ordinate 
    (<x>,<y>) is set. *)
BEGIN
  RETURN xyPane.GetDot(x,y)#0;
END IsDot;

PROCEDURE Key*():CHAR;
(** The return value of the function is 0X, if no key was pressed, otherwise 
    it is the key code. Keys that are not assigned an ASCII code are ignored. *)
VAR
  ch:CHAR;
BEGIN
  IF xyPane.KeyPressed() THEN 
    ch:=xyPane.ReadKey();
    IF ch=0X THEN 
      ch:=xyPane.ReadKey();
      RETURN 0X;
    END;
    RETURN ch;
  ELSE
    RETURN 0X;
  END;
END Key;

PROCEDURE Clear*();
(** The drawing area is cleared to the background color. *)
BEGIN
  xyPane.Clear();
END Clear;

PROCEDURE Init;
VAR
  h:AppGrp.AppP;
BEGIN
  h:=AppGrp.GetApp();
  app:=h(I.InOutAppP);
  xyPane:=NIL;
  X:=0; Y:=0;
  W:=BitPane.WIDTH;
  H:=BitPane.HEIGHT;
END Init;

BEGIN
  Init;
END XYplane.
