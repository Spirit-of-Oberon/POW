MODULE Float;
(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  07-19-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This module contains basic trigonometric, exponential and conversion 
  functions for use with the data types REAL and LONGREAL.

  For all logarithmic functions a result with "infinite" value is returned
  for the value zero. If the argument is less than zero a special code is
  returned, indicating that the result would be an invalid number.

  No runtime errors are caused by numerical values out of the range in any
  of the functions. The result of an invalid operation is a special value
  instead. This can be tested with the function KindOfNumber. If such a
  special value is used for further calculation a runtime error may occur.
  ----------------------------------------------------------------------------*)

IMPORT SYSTEM,Strings;


CONST

  Pi*= 3.14159265359D0;
  e* = 2.71828182846D0;

  (** \NEWGROUP Constants for the result of ValResult *)
  ISREAL*        = 1;
  ISLONGREAL*    = 2;
  ISOUTOFRANGE*  = 4;
  STRINGEMPTY*   = 5;
  STRINGILLEGAL* = 6;

  (** \NEWGROUP Constants for the result of KindOfNumber *)
  UNSUPPORTED* = 0;
  NAN*         = 1; (** invalid real number (NAN = Not A Number) *)
  NORMAL*      = 2; (** a normal number *)
  POSINF*      = 3; (** + infinity *)
  ZERO*        = 4;
  DENORMAL*    = 6; (** a number whose representation is not as precise as the data type used (REAL or LONGREAL) would suggest; this is due to restrictions of the internal representation of floating point numbers. *)
  IMPOSSIBLE*  = 7;
  NEGINF*      = 8; (** - infinity *) 


  ROUND_NEAREST    =0000H; (* round to nearest   *)
  ROUND_DOWN       =0400H; (* round to neg. inf. *)
  ROUND_TRUNC      =0C00H; (* round to zero      *)
  PREC_EXTENDED    =0300H; (* 64 bit precision   *)
  EXCEPTIONS_NORMAL=0070H; (* mask underflow and precision exceptions *)
  EXCEPTIONS_NONE  =007FH; (* mask all exceptions *)
  INF_CONTROL      =1000H;
  CTRL_WORD_DEFAULT=ROUND_DOWN   +PREC_EXTENDED+EXCEPTIONS_NORMAL+INF_CONTROL; (* control word setting expected by compiler *)
  CTRL_WORD_TRUNC  =ROUND_TRUNC  +PREC_EXTENDED+EXCEPTIONS_NONE  +INF_CONTROL;
  CTRL_WORD_ROUND  =ROUND_NEAREST+PREC_EXTENDED+EXCEPTIONS_NONE  +INF_CONTROL;

PROCEDURE- CodeLD_P1Real      0D9H, 045H, 008H; (* FLD  m32realptr [EBP+ 8h] *)
PROCEDURE- CodeLD_P1LongReal  0DDH, 045H, 008H; (* FLD  m64realptr [EBP+ 8h] *)
PROCEDURE- CodeLD_P2Real      0D9H, 045H, 00CH; (* FLD  m32realptr [EBP+ Ch] *)
PROCEDURE- CodeLD_P2LongReal  0DDH, 045H, 010H; (* FLD  m64realptr [EBP+10h] *)
PROCEDURE- CodeLD_X14LongReal 0DDH, 045H, 014H; (* FLD  m64realptr [EBP+14h] *)
PROCEDURE- CodeST_P1Real      0D9H, 055H, 008H; (* FST  m32realptr [EBP+ 8h] *)
PROCEDURE- CodeST_P1LongReal  0DDH, 055H, 008H; (* FST  m64realptr [EBP+ 8h] *)
PROCEDURE- CodeSTP_P1Real     0D9H, 05DH, 008H; (* FSTP m32realptr [EBP+ 8h] *)
PROCEDURE- CodeSTP_P1LongReal 0DDH, 05DH, 008H; (* FSTP m64realptr [EBP+ 8h] *)
PROCEDURE- CodeSTP_P2Real     0D9H, 05DH, 00CH; (* FSTP m32realptr [EBP+ Ch] *)
PROCEDURE- CodeSTP_P2LongReal 0DDH, 05DH, 010H; (* FSTP m64realptr [EBP+10h] *)
PROCEDURE- CodeSTP_V2LongReal 0DDH, 05DH, 0F4H; (* FSTP m64realptr [EBP- Ch] *)
PROCEDURE- CodeSTP_ST1        0DDH, 0D9H;       (* FSTP ST(1)                *)
PROCEDURE- CodeFLD1           0D9H, 0E8H;       (* FLD1                      *)
PROCEDURE- CodeFLDL2T         0D9H, 0E9H;       (* FLDL2T  push ld(10)       *)
PROCEDURE- CodeFLDL2E         0D9H, 0EAH;       (* FLDL2E  push ld(e)        *)
PROCEDURE- CodeFLDPI          0D9H, 0EBH;       (* FLDPI                     *)
PROCEDURE- CodeFYL2X          0D9H, 0F1H;       (* FYL2X  ST(1)->ST(1)*ld(ST(0)), pop ST *)
PROCEDURE- CodeFWAIT          09BH;             (* FWAIT                     *)
PROCEDURE- CodeFBLD           08BH, 075H, 008H, (* MOV ESI, [EBP+8h]         *)
                              0DFH, 026H;       (* FBLD [ESI] - load Binary Coded Decimal *)
PROCEDURE- CodeFBSTP          08BH, 075H, 008H, (* MOV ESI, [EBP+8h]         *)
                              0DFH, 036H;       (* FBSTP [ESI] - store Binary Coded Decimal and pop *)
PROCEDURE- CodeFLD_ST0        0D9H, 0C0H;       (* FLD ST(0)                 *)
PROCEDURE- CodeFRNDINT        0D9H, 0FCH;       (* FRNDINT                   *)
PROCEDURE- CodeFSUB_ST1ST0    0DCH, 0E9H;       (* FSUB ST(1),ST             *)
PROCEDURE- CodeFSCALE         0D9H, 0FDH;       (* FSCALE                    *)
PROCEDURE- CodeFXCH_ST2       0D9H, 0CAH;       (* FXCH ST(2)                *)
PROCEDURE- CodeFADD           0DEH, 0C1H;       (* FADD                      *)
PROCEDURE- CodeFMUL_ST0ST2    0D8H, 0CAH;       (* FMUL ST,ST(2) *)
PROCEDURE- CodeFLDCW_V1       0D9H, 06DH, 0F8H; (* FLDCW [EXP-8h] *)
PROCEDURE- CodeF2XM1          0D9H, 0F0H;       (* F2XM1 - ST->2^ST-1 *)
PROCEDURE- CodeASCII2BCD      066H, 01EH,       (* PUSH ds *) 
                              066H, 007H,       (* POP es *)
                              08BH, 075H, 014H, (* MOV ESI, [EBP+14h] *)
                              08BH, 07DH, 008H, (* MOV EDI, [EBP+08h] *)
                              0FCH,             (* CLD *)
                              083H, 0C7H, 009H, (* ADD EDI, 9 *)
                              0ACH,             (* LODSB *)
                              03CH, 02DH,       (* CMP AL, "-" *)
                              075H, 004H,       (* JNE +4 *)
                              0B0H, 080H,       (* MOV AL,80h  *)
                              0EBH, 002H,       (* JMP +2 *)
                              032H, 0C0H,       (* XOR AL,AL *)
                              026H, 088H, 007H, (* MOV [ES:EDI],AL *)
                              0B9H, 009H, 0,0,0,(* MOV ECX, 9 *)
                              066H, 0ADH,       (* LODSW *)
                              066H, 02DH, 030H, 030H, (* SUB AX,3030h *)
                              0C0H, 0E0H, 004H, (* SHL AL,4 *)
                              00AH, 0C4H,       (* OR AL,AH *)
                              04FH,             (* DEC EDI *)
                              026H, 088H, 007H, (* MOV [ES:EDI],AL *)
                              0E2H, 0EFH;       (* LOOP -11h *)

PROCEDURE -CodeBCD2ASCII      066H, 01EH,       (* PUSH ds *) 
                              066H, 007H,       (* POP es *)
                              08BH, 075H, 014H, (* MOV ESI, [EBP+14h] *)
                              083H, 0C6H, 009H, (* ADD ESI, 9 *)
                              08BH, 07DH, 008H, (* MOV EDI, [EBP+08h] *)
                              0FCH,             (* CLD *)
                              08AH, 006H,       (* MOV AL,[ESI] *)
                              024H, 080H,       (* AND AL, 80h *)
                              074H, 004H,       (* JZ l1: *)
                              0B0H, 02DH,       (* MOV AL, "-" *)
                              0EBH, 002H,       (* JMP l2: *)
                              0B0H, 02BH,       (* l1: MOV AL, "+" *)
                              0AAH,             (* l2: STOSB *)
                              0B9H, 009H,0,0,0, (* MOV ECX, 9 *)
                              04EH,             (* l3: DEC ESI *)
                              08AH, 006H,       (* MOV AL,[ESI] *)
                              08AH, 0E0H,       (* MOV AH,AL *)
                              0C0H, 0E8H, 004H, (* SHR AL,4 *)
                              080H, 0E4H, 00FH, (* AND AH,0Fh *)
                              066H, 005H, 030H, 030H, (* ADD AX,3030h *)
                              066H, 0ABH,       (* STOSW *)
                              0E2H, 0EDH;       (* LOOP l3 (-15h) *)

PROCEDURE -CodeExamine        0D9H, 0E5H;       (* FXAM *)
PROCEDURE -CodeStoreSW_V1     0DDH, 07DH, 0F8H; (* FNSTSW [EBP-8h] *) 
PROCEDURE -CodeFDIVP_ST1ST0   0DEH, 0F9H;       (* FDIVP ST(1), ST *)
PROCEDURE -CodeCos            0D9H, 0FFH;       (* FCOS *)
PROCEDURE -CodeSin            0D9H, 0FEH;       (* FSIN *)
PROCEDURE -CodeTan            0D9H, 0F2H;       (* FPTAN *)
PROCEDURE -CodeATan           0D9H, 0F3H;       (* FPATAN *)
PROCEDURE -CodeSqrt           0D9H, 0FAH;       (* FSQRT *)
PROCEDURE -CodeFNClEx         0DBH, 0E2H;       (* FNCLEX  clear exceptions without check *)



PROCEDURE BCD2Float(VAR bcd:ARRAY OF CHAR (* [EBP+8] *)):LONGREAL;
VAR
  x:LONGREAL; (* [EBP-Ch] *)
BEGIN
  CodeFBLD;
  CodeSTP_V2LongReal;
  RETURN x;
END BCD2Float;

PROCEDURE Float2BCD(x:LONGREAL; VAR bcd:ARRAY OF CHAR (* [EBP+8] *));
BEGIN
  CodeLD_X14LongReal;
  CodeFBSTP;
END Float2BCD;

PROCEDURE ASCII2BCD(VAR ascii:ARRAY OF CHAR;(* [EBP+14h]*) VAR bcd:ARRAY OF CHAR (* [EBP+8] *));
BEGIN
  CodeASCII2BCD;
END ASCII2BCD;

PROCEDURE BCD2ASCII(VAR bcd:ARRAY OF CHAR;(* [EBP+14h]*) VAR ascii:ARRAY OF CHAR (* [EBP+8] *));
BEGIN
  CodeBCD2ASCII;
END BCD2ASCII;

PROCEDURE Log2*(x:REAL):REAL;
(** The return value is the logarithm base 2 of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeLD_P1Real;
  CodeFYL2X;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Log2;

PROCEDURE Log2L*(x:LONGREAL):LONGREAL;
(** The return value is the logarithm base 2 of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeLD_P1LongReal;
  CodeFYL2X;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Log2L;

PROCEDURE Ln*(x:REAL):REAL;
(** The return value is the natural logarithm (base e) of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeFLDL2E;
  CodeFDIVP_ST1ST0;
  CodeLD_P1Real;
  CodeFYL2X;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Ln;

PROCEDURE LnL*(x:LONGREAL):LONGREAL;
(** The return value is the natural logarithm (base e) of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeFLDL2E;
  CodeFDIVP_ST1ST0;
  CodeLD_P1LongReal;
  CodeFYL2X;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END LnL;

PROCEDURE Log10*(x:REAL):REAL;
(** The return value is the logarithm base 10 of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeFLDL2T;
  CodeFDIVP_ST1ST0;
  CodeLD_P1Real;
  CodeFYL2X;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Log10;

PROCEDURE Log10L*(x:LONGREAL):LONGREAL;
(** The return value is the logarithm base 10 of <x>. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeFLD1;
  CodeFLDL2T;
  CodeFDIVP_ST1ST0;
  CodeLD_P1LongReal;
  CodeFYL2X;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Log10L;

PROCEDURE Exp*(x,y:REAL):REAL;
(** The return value is <x> to the power of <y>. 

    If the value is too big for the exact representation in the floating point 
    format a special code for the result infinity is returned.
    
    The valid range for <x> comprises only positive numbers. If <x> is negative 
    a special code is returned indicating that the result is an invalid number. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  CodeLD_P1Real;
  CodeLD_P2Real;
  CodeFYL2X;
  CodeFLD_ST0;
  CodeFRNDINT;
  CodeFSUB_ST1ST0;
  CodeFLD1;
  CodeFSCALE;
  CodeFXCH_ST2;
  CodeF2XM1;
  CodeFLD1;
  CodeFADD;
  CodeFMUL_ST0ST2;
  ctrlWord:=CTRL_WORD_ROUND;
  CodeFLDCW_V1;
  CodeSTP_P1Real;
  CodeSTP_ST1;
  CodeSTP_P2Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN y;
END Exp;

PROCEDURE ExpL*(x,y:LONGREAL):LONGREAL;
(** The return value is <x> to the power of <y>. 

    If the value is too big for the exact representation in the floating point 
    format a special code for the result infinity is returned.
    
    The valid range for <x> comprises only positive numbers. If <x> is negative 
    a special code is returned indicating that the result is an invalid number. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  CodeLD_P1LongReal;
  CodeLD_P2LongReal;
  CodeFYL2X;
  CodeFLD_ST0;
  CodeFRNDINT;
  CodeFSUB_ST1ST0;
  CodeFLD1;
  CodeFSCALE;
  CodeFXCH_ST2;
  CodeF2XM1;
  CodeFLD1;
  CodeFADD;
  CodeFMUL_ST0ST2;
  ctrlWord:=CTRL_WORD_ROUND;
  CodeFLDCW_V1;
  CodeSTP_P1LongReal;
  CodeSTP_ST1;
  CodeSTP_P2LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN y;
END ExpL;

PROCEDURE Sqrt*(x:REAL):REAL;
(** The return value is the square root of <x>. 
    
    If <x> is smaller than zero a special code is returned indicating that 
    the result is an invalid number.*)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1Real;
  CodeSqrt;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Sqrt;

PROCEDURE SqrtL*(x:LONGREAL):LONGREAL;
(** The return value is the square root of <x>. 
    
    If <x> is smaller than zero a special code is returned indicating that 
    the result is an invalid number.*)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1LongReal;
  CodeSqrt;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END SqrtL;

PROCEDURE Cos*(x:REAL):REAL;
(** The return value is the cosine of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1Real;
  CodeCos;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Cos;

PROCEDURE CosL*(x:LONGREAL):LONGREAL;
(** The return value is the cosine of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1LongReal;
  CodeCos;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END CosL;

PROCEDURE Sin*(x:REAL):REAL;
(** The return value is the sine of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1Real;
  CodeSin;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Sin;

PROCEDURE SinL*(x:LONGREAL):LONGREAL;
(** The return value is the sine of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1LongReal;
  CodeSin;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END SinL;

PROCEDURE Tan*(x:REAL):REAL;
(** The return value is the tangent of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1Real;
  CodeTan;
  CodeSTP_P1Real;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END Tan;

PROCEDURE TanL*(x:LONGREAL):LONGREAL;
(** The return value is the tangent of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1LongReal;
  CodeTan;
  CodeSTP_P1Real;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END TanL;

PROCEDURE ArcTan*(x:REAL):REAL;
(** The return value is the arc tangent of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1Real;
  CodeFLD1;
  CodeATan;
  CodeSTP_P1Real;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END ArcTan;

PROCEDURE ArcTanL*(x:LONGREAL):LONGREAL;
(** The return value is the arc tangent of <x> in radians. *)
VAR
  ctrlWord:INTEGER;
BEGIN
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN ctrlWord:=CTRL_WORD_ROUND; CodeFLDCW_V1 END;
  CodeLD_P1LongReal;
  CodeFLD1;
  CodeATan;
  CodeSTP_P1LongReal;
  IF CTRL_WORD_ROUND#CTRL_WORD_DEFAULT THEN CodeFNClEx; ctrlWord:=CTRL_WORD_DEFAULT; CodeFLDCW_V1 ELSE CodeFWAIT END;
  RETURN x;
END ArcTanL;

PROCEDURE ArcSin*(x:REAL):REAL;
(** The return value is the arc sine of <x> in radians. 

    The arc cosine is not implemented as a separate function as it can be 
    easily calculated using Pi/2 - ArcSin(x). *)
BEGIN
  IF x#1 THEN RETURN ArcTan(x/Sqrt(1-x*x)) ELSE RETURN SHORT(Pi/2) END;
END ArcSin;

PROCEDURE ArcSinL*(x:LONGREAL):LONGREAL;
(** The return value is the arc sine of <x> in radians. 

    The arc cosine is not implemented as a separate function as it can be 
    easily calculated using Pi/2 - ArcSin(x). *)
BEGIN
  IF x#1 THEN RETURN ArcTanL(x/SqrtL(1-x*x)) ELSE RETURN Pi/2 END;
END ArcSinL;                                            

PROCEDURE KindOfNumber*(x:REAL):INTEGER;
(** This function checks if <x> is a normal number or if it contains a 
    special value.
    The following constants are intended to be compared with the return 
    values of the function:

    NAN          not a number
    
    NORMAL       ordinary number
    
    POSINF       positive infinity
    
    ZERO         zero
    
    DENORMAL     number stored with reduced precision
    
    NEGINF       negative infinity 
    
    Note that the return value of the function may also be a value different 
    from the defined constants. In this case a numerical error has occurred 
    which was not expected in that form. The parameter <x> does not contain a 
    valid numerical value in this case. *)
VAR
  ss:LONGINT;
  k:INTEGER;
BEGIN
  ss:=0;
  CodeLD_P1Real;
  CodeExamine;
  CodeStoreSW_V1;
  CodeSTP_P1Real;
  k:=0;
  IF SYSTEM.BIT(ss,8) THEN k:=1; END;
  IF SYSTEM.BIT(ss,10) THEN k:=k+2; END;
  IF SYSTEM.BIT(ss,14) THEN k:=k+4; END;
  IF (k=3) & SYSTEM.BIT(ss,9) THEN k:=8; END;
  RETURN k;
END KindOfNumber;

PROCEDURE KindOfNumberL*(x:LONGREAL):INTEGER;
(** Returns one of the following values which characterizes the contents of <x>:

    UNSUPPORTED
    NAN          not a number
    NORMAL       ordinary number
    POSINF       positive infinity
    ZERO         zero
    DENORMAL     number stored with reduced precision
    NEGINF       negative infinity 
*)
VAR
  ss:LONGINT;
  k:INTEGER;
BEGIN
  ss:=0;
  CodeLD_P1LongReal;
  CodeExamine;
  CodeStoreSW_V1;
  CodeSTP_P1Real;
  k:=0;
  IF SYSTEM.BIT(ss,8) THEN k:=1; END;
  IF SYSTEM.BIT(ss,10) THEN k:=k+2; END;
  IF SYSTEM.BIT(ss,14) THEN k:=k+4; END;
  IF (k=3) & SYSTEM.BIT(ss,9) THEN k:=8; END;
  RETURN k;
END KindOfNumberL;

PROCEDURE ValResult*(t:ARRAY OF CHAR):INTEGER;
(** This function checks if the string <t> can be converted to a number and 
    what kind of floating point type is at least required for storing it.
    
    The following constants are possible return values of the function:
    
    ISREAL: <t> contains a number which can be stored in a REAL variable.
    
    ISLONGREAL: <t> contains a number which can be stored in a LONGREAL variable.
    
    ISOUTOFRANGE: <t> contains a number which is too small or too big to be stored in a LONGREAL variable.
    
    STRINGEMPTY: <t> is empty or contains nothing but blanks.
 
    STRINGILLEGAL: <t> contains characters that must not occur in a number.
    
    The constants have a numerical order defined relatively to each other:
    ISREAL < ISLONGREAL < ISOUTOFRANGE < (STRINGEMPTY, STRINGILLEGAL)
    
    This definition makes it easier to find out if, for example, a number can 
    be stored in a LONGREAL variable. *)
VAR
  tasc:ARRAY 20 OF CHAR;
  tbcd:ARRAY 11 OF CHAR;
  tBuf:ARRAY 8 OF CHAR;
  x,xa:LONGREAL;
  h,inx,tInx,l,decPos:LONGINT;
  res:INTEGER;
  exponent:LONGINT;
  exit,decimal:BOOLEAN;
BEGIN
  Strings.RemoveLeadingSpaces(t);
  Strings.RemoveTrailingSpaces(t);
  l:=Strings.Length(t);
  IF l<1 THEN RETURN STRINGEMPTY END;
  tInx:=0;
  inx:=1;
  decimal:=FALSE;
  exponent:=0;
  tasc:="+";
  IF (t[0]="+") OR (t[0]="-") THEN tasc[0]:=t[0]; INC(tInx); END;
  exit:=FALSE;
  WHILE (tInx<l) & ((t[tInx]="0") OR (t[tInx]=".")) DO
    IF t[tInx]="." THEN 
      IF decimal THEN RETURN STRINGILLEGAL ELSE decimal:=TRUE END;
    END;  
    IF (t[tInx]="0") & decimal THEN DEC(exponent) END;
    INC(tInx);
  END;
  IF tInx=l THEN RETURN ISREAL; END;
  h:=tInx;
  exit:=FALSE;
  decPos:=-1;
  WHILE (tInx<l) & ~exit DO
    IF (t[tInx]>="0") & (t[tInx]<="9") THEN
      IF inx<=18 THEN
        tasc[inx]:=t[tInx];
        INC(inx);
        IF decimal THEN DEC(exponent) END;  
      ELSE
        IF ~decimal THEN INC(exponent) END;
      END;    
    ELSIF t[tInx]="." THEN
      IF decimal THEN RETURN STRINGILLEGAL ELSE decPos:=tInx-h; decimal:=TRUE END;
    ELSE exit:=TRUE END;
    INC(tInx);
  END;
  tasc[inx]:=0X;
  WHILE inx<19 DO
    Strings.InsertChar("0",tasc,2);
    INC(inx);
  END;
  ASCII2BCD(tasc,tbcd);
  x:=BCD2Float(tbcd);
  IF exit THEN
    t[tInx-1]:=Strings.UpCaseChar(t[tInx-1]);
    IF (t[tInx-1]#"D") & (t[tInx-1]#"E") THEN RETURN STRINGILLEGAL END;
    Strings.Copy(t,tBuf,tInx+1,l-tInx);
    res:=Strings.ValResult(tBuf);
    IF res>Strings.ISLONGINT THEN RETURN res END;
    exponent:=exponent+Strings.Val(tBuf);
  END;  
  IF exponent#0 THEN x:=x*ExpL(10,exponent) END;
  xa:=ABS(x);
  IF (xa>=1.4D-45) & (xa<=MAX(REAL)) THEN RETURN ISREAL END;
  IF (xa>=4.19D-307) & (xa<=MAX(LONGREAL)) THEN RETURN ISLONGREAL END;
  RETURN ISOUTOFRANGE;
END ValResult;

PROCEDURE Val*(t:ARRAY OF CHAR):LONGREAL;
(** The string <t> is converted to a number and returned as the result.

    If the character sequence in <t> does not represent a real number and 
    the conversion fails the smallest negative number (MIN(LONGREAL)) is 
    returned.
    
    Blanks at the beginning and the end of <t> are ignored. The number must 
    not contain blanks within itself. *)
VAR
  tasc:ARRAY 20 OF CHAR;
  tbcd:ARRAY 11 OF CHAR;
  tBuf:ARRAY 8 OF CHAR;
  x,xa:LONGREAL;
  h,inx,tInx,l,decPos:LONGINT;
  res:INTEGER;
  exponent:LONGINT;
  exit,decimal:BOOLEAN;
BEGIN
  Strings.RemoveLeadingSpaces(t);
  Strings.RemoveTrailingSpaces(t);
  l:=Strings.Length(t);
  IF l<1 THEN RETURN MIN(LONGREAL) END;
  tInx:=0;
  inx:=1;
  decimal:=FALSE;
  exponent:=0;
  tasc:="+";
  IF (t[0]="+") OR (t[0]="-") THEN tasc[0]:=t[0]; INC(tInx); END;
  exit:=FALSE;
  WHILE (tInx<l) & ((t[tInx]="0") OR (t[tInx]=".")) DO
    IF t[tInx]="." THEN 
      IF decimal THEN RETURN MIN(LONGREAL) ELSE decimal:=TRUE END;
    END;  
    IF (t[tInx]="0") & decimal THEN DEC(exponent) END;
    INC(tInx);
  END;
  IF tInx=l THEN RETURN 0 END;
  h:=tInx;
  exit:=FALSE;
  decPos:=-1;
  WHILE (tInx<l) & ~exit DO
    IF (t[tInx]>="0") & (t[tInx]<="9") THEN
      IF inx<=18 THEN
        tasc[inx]:=t[tInx];
        INC(inx);
        IF decimal THEN DEC(exponent) END;  
      ELSE
        IF ~decimal THEN INC(exponent) END;
      END;    
    ELSIF t[tInx]="." THEN
      IF decimal THEN RETURN MIN(LONGREAL) ELSE decPos:=tInx-h; decimal:=TRUE END;
    ELSE exit:=TRUE END;
    INC(tInx);
  END;
  tasc[inx]:=0X;
  WHILE inx<19 DO
    Strings.InsertChar("0",tasc,2);
    INC(inx);
  END;
  ASCII2BCD(tasc,tbcd);
  x:=BCD2Float(tbcd);
  IF exit THEN
    t[tInx-1]:=Strings.UpCaseChar(t[tInx-1]);
    IF (t[tInx-1]#"D") & (t[tInx-1]#"E") THEN RETURN MIN(LONGREAL) END;
    Strings.Copy(t,tBuf,tInx+1,l-tInx);
    res:=Strings.ValResult(tBuf);
    IF res>Strings.ISLONGINT THEN RETURN MIN(LONGREAL) END;
    exponent:=exponent+Strings.Val(tBuf);
  END;  
  IF exponent#0 THEN x:=x*ExpL(10,exponent) END;
  xa:=ABS(x);
  IF (xa>=4.19D-307) & (xa<=MAX(LONGREAL)) THEN RETURN x END;
  RETURN MIN(LONGREAL);
END Val;

PROCEDURE StrF*(x:LONGREAL; n1,n2:INTEGER; VAR t:ARRAY OF CHAR);
(** The number <x> is converted to a string and the result is returned in <t>.
    The representation is effected with a fixed number of digits before (<n1>)
    and after (<n2>) the decimal point. 
    
    If <t> is not large enough to hold the selected output format or if the 
    number cannot be represented with <n1> digits before the comma, <t> is 
    filled with "$" characters.
    
    The length of the result totals <n1> + <n2> + 2 characters: digits for 
    the integral part + digits for the fractional part + decimal point + sign.
    
    Examples for StrF(x,4,2,t):
    
    x=1 -> t="    1.00"
    
    x=-125 -> t=" -125.00"
    
    x=3300790 -> t="$$$$$$$$"
    
    x=0.1 -> t="    0.10"
    
    x=33007 -> t="$$$$$$$$"
    
    x=5887.009 -> t=" 5887.01" *)
CONST
  PRECIS=16;
VAR
  ex,shift,k,i,h:INTEGER;
  tasc:ARRAY 20 OF CHAR;
  tbcd:ARRAY 11 OF CHAR;
  xcor:LONGREAL;
  th:ARRAY 100 OF CHAR;
BEGIN
  IF LEN(t)<n1+n2+3 THEN
    FOR i:=0 TO LEN(t)-2 DO t[i]:="$" END;
    t[LEN(t)-1]:=0X;
    RETURN;
  END;
  FOR i:=0 TO n1-1 DO t[i]:=" " END;
  FOR i:=n1 TO n1+n2 DO t[i]:="0" END;
  t[n1+n2+1]:=0X;
  k:=KindOfNumberL(x);
  CASE k OF
    ZERO:
      Strings.InsertChar(".",t,n1+2);
  | NORMAL,DENORMAL:
      ex:=SHORT(ENTIER(Log10L(ABS(x))));
      shift:=PRECIS-ex;
      xcor:=x*ExpL(10,shift);
      Float2BCD(xcor,tbcd);
      BCD2ASCII(tbcd,tasc);
      FOR i:=0 TO PRECIS-1 DO th[1+i]:=tasc[18-PRECIS+i]; END;
      th[0]:=tasc[0];
      th[PRECIS+1]:=0X;
      IF (ex+n2+2<=PRECIS) & (ex+n2+1>=0) THEN
        i:=ex+n2+1;
        h:=ORD(th[i+1])-ORD("0");
        IF h>4 THEN h:=1 ELSE h:=0 END;
        WHILE (i>0) & (h>0) DO
          h:=ORD(th[i])-ORD("0")+h;
          th[i]:=CHR(ORD("0")+h MOD 10);
          h:=h DIV 10;
          DEC(i);
        END;
        IF h>0 THEN
          Strings.InsertChar(CHR(ORD("0")+h),th,2);
          INC(ex);
        END;  
      END;
      IF ex>=n1 THEN
        FOR i:=0 TO n1+n2+1 DO t[i]:="$" END;
        t[n1+n2+2]:=0X;
        RETURN;
      END;
      h:=ex+n2+1;
      IF h>PRECIS THEN h:=PRECIS END;
      FOR i:=1 TO h DO t[i+n1-ex-1]:=th[i] END;
      FOR i:=h+1-ex TO n2+1 DO t[i+n1-1]:="0" END;
      Strings.InsertChar(".",t,n1+2);
      h:=n1-ex-1;
      IF h>n1-1 THEN h:=n1-1 END;
      IF th[0]="-" THEN t[h]:="-" ELSE t[h]:=" " END;
  | NAN:
      COPY("error",t);
  | NEGINF:
      COPY("-infinity",t);
  | POSINF:
      COPY("+infinity",t);
  ELSE
    Strings.Str(k,tasc);
    COPY("error in Float.StrF (",t);
    Strings.Append(t,tasc);
    Strings.AppendChar(t,")");
  END;
END StrF;

PROCEDURE Str*(x:LONGREAL; VAR t:ARRAY OF CHAR);
(** The number <x> is converted to a string and the result is returned in <t>.

    If <t> is not large enough to hold all characters of the number, <t> is 
    filled with "$" characters.
    
    Examples for Str(x,t):
    
    x=4 -> t="1e0"
    
    x=-125 -> t="-1.25e2"
    
    x=3300790 -> t="3.30079e6"
    
    x=0.1 -> t="1e-1"
    
    x=33007000 -> t="3.3007e7"
    
    x=Log2(0) -> t="-infinity"
    
    KindOfNumber(x)=NAN -> t="error" *)
CONST
  PRECIS=12;
VAR
  k,decpos:INTEGER;
  i:INTEGER;
  ex:INTEGER;
  hl:LONGINT;  
  shift:INTEGER;
  tasc:ARRAY 20 OF CHAR;
  tbcd:ARRAY 11 OF CHAR;
  xcor:LONGREAL;
  xh:LONGREAL;
  th:ARRAY 10 OF CHAR;
BEGIN
  k:=KindOfNumberL(x);
  CASE k OF
    ZERO:
      COPY("0",t);
  | NORMAL,DENORMAL:
      xh:=Log10L(ABS(x));
      hl:=ENTIER(xh);
      ex:=SHORT(hl);
      shift:=PRECIS-ex;
      xcor:=x*ExpL(10,shift);
      Float2BCD(xcor,tbcd);
      BCD2ASCII(tbcd,tasc);
      FOR i:=0 TO PRECIS-1 DO tasc[1+i]:=tasc[18-PRECIS+i]; END;
      tasc[PRECIS+1]:=0X;
      decpos:=3;
      Strings.InsertChar(".",tasc,decpos);
      i:=SHORT(Strings.Length(tasc))-1;
      WHILE (i>=decpos) & (tasc[i]="0") DO 
        tasc[i]:=0X;
        DEC(i);
      END;
      IF tasc[i]="." THEN tasc[i]:=0X; END;
      Strings.Str(ex,th);
      Strings.AppendChar(tasc,"e");
      Strings.Append(tasc,th);
      IF tasc[0]="+" THEN Strings.Delete(tasc,1,1) END;
      IF Strings.Length(tasc)<LEN(t) THEN 
        COPY(tasc,t);
      ELSE 
        FOR i:=0 TO LEN(t)-2 DO t[i]:="$" END;
        t[LEN(t)-1]:=0X;
      END; 
  | NAN:
      COPY("error",t);
  | NEGINF:
      COPY("-infinity",t);
  | POSINF:
      COPY("+infinity",t);
  ELSE
    Strings.Str(k,tasc);
    COPY("error in Float.Str (",t);
    Strings.Append(t,tasc);
    Strings.AppendChar(t,")");
  END;
END Str;

PROCEDURE StrL*(x:LONGREAL; n:INTEGER; VAR t:ARRAY OF CHAR);
(** The number <x> is converted to a string of length <n> and the result is 
    stored right aligned in <t>. If necessary the number of digits is reduced 
    and the number is rounded.
    
    The minimum value for <n> is five characters. Smaller values are ignored.
    
    If <t> is not large enough to hold all characters of the number, it is 
    filled with "$" characters. Even though the result is reduced to <n> characters 
    <t> must be of a sufficient size to contain the full number.
    
    Examples for StrL(x,8,t):
    
    x=1 -> t="     1e0"
    
    x=-125 -> t=" -1.25e2"
    
    x=3300790 -> t="3.3008e6"
    
    x=0.1 -> t="    1e-1"
    
    x=33007000 -> t="3.3007e7" *)
VAR
  th:ARRAY 255 OF CHAR;
  endPos:LONGINT;
  roundPos,kommaPos,exp:LONGINT;
  i,v,l:LONGINT;
BEGIN
  Str(x,t);
  IF n<5 THEN n:=5 END;
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
          IF (i>=0) & ((t[i]<"0") OR (t[i]>"9")) THEN DEC(i) END;
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
END StrL;
  
END Float.
