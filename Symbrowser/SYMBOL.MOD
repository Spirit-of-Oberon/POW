MODULE Symbol;
(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * PURPOSE: Contains common type-specific definitions to map raw-symFile data   *
 *          into a readable format                                              *
 *          Consider to the description of the symfile-format for more details  *
 *          about.                                                              *
 ********************************************************************************)

(* Symboldefs *)

CONST
  conSy*    = 1;
  typeSy*   = 2;
  hdTypeSy* = 3;
  varSy*    = 4;
  xproSy*   = 5;
  iproSy*   = 6;
  cproSy*   = 7;
  ptrSy*    = 8;
  procSy*   = 9;
  arrSy*    =10;
  darrSy*   =11;
  recSy*    =12;
  plistSy*  =13;
  valParSy* =14;
  varParSy* =15;
  flistSy*  =16;
  fldSy*    =17;
  hdptrSy*  =18;
  hdprocSy* =19;
  fixSy*    =20;
  sysSy*    =21;
  modSy*    =22;
  rvarSy*   =23;
  rfldSy*   =24;
  tproSy*   =25;
  nmethSy*  =26;
  hdtprocSy*=27;
  wproSy*   =30;
  rovarParSy*=31;
  cdeclproSy*=32; 
  stvarParSy*=33;

 (* BOOLEAN    constants *)   
  falseSy*  = 0;
  trueSy*   = 1;
 
 (* PREDEFINED types *) 
  undefSy*  = 0;
  byteSy*   = 1;
  boolSy*   = 2;
  charSy*   = 3;
  sintSy*   = 4;
  intSy*    = 5;
  lintSy*   = 6;
  realSy*   = 7;
  lrealSy*  = 8;
  setSy*    = 9;
  stringSy* =10;
  nilSy*    =11;
  noTypSy*  =12;
  
 (* special Symbols (no symfile-symbol) *)
   eofSy*   = 255;
  
BEGIN
END Symbol.
