(******************************************************************************)
(*                                                                            *)
(**)                      DEFINITION CommDlg;                               (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1993; Robinson Associates                                    *)
(*                     Red Lion House                                         *)
(*                     St Mary's Street                                       *)
(*                     PAINSWICK                                              *)
(*                     Glos                                                   *)
(*                     GL6  6QR                                               *)
(*                     Tel:    (+44) (0)1452 813 699                          *)
(*                     Fax:    (+44) (0)1452 812 912                          *)
(*                     e-Mail: Oberon@robinsons.co.uk                         *)
(******************************************************************************)
(*  06-14-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(*    commdlg.h -- This module defines the 32-Bit Common Dialog APIs          *)
(*                                                                            *)
(******************************************************************************)

IMPORT  WU := WinUser, WD := WinDef, WG := WinGDI;

(*  Assume byte packing throughout  *)
CONST 
  WM_USER = 400H;
  OFN_READONLY = 1H;
  OFN_OVERWRITEPROMPT = 2H;
  OFN_HIDEREADONLY = 4H;
  OFN_NOCHANGEDIR = 8H;
  OFN_SHOWHELP = 10H;
  OFN_ENABLEHOOK = 20H;
  OFN_ENABLETEMPLATE = 40H;
  OFN_ENABLETEMPLATEHANDLE = 80H;
  OFN_NOVALIDATE = 100H;
  OFN_ALLOWMULTISELECT = 200H;
  OFN_EXTENSIONDIFFERENT = 400H;
  OFN_PATHMUSTEXIST = 800H;
  OFN_FILEMUSTEXIST = 1000H;
  OFN_CREATEPROMPT = 2000H;
  OFN_SHAREAWARE = 4000H;
  OFN_NOREADONLYRETURN = 8000H;
  OFN_NOTESTFILECREATE = 10000H;
  OFN_NONETWORKBUTTON = 20000H;
  OFN_NOLONGNAMES = 40000H;            (*  force no long names for 4.x modules *)
  OFN_EXPLORER = 80000H;               (*  new look commdlg *)
  OFN_NODEREFERENCELINKS = 100000H;
  OFN_LONGNAMES = 200000H;             (*  force long names for 3.x modules *)

(*  Return values for the registered message sent to the hook function *)
(*  when a sharing violation occurs.  OFN_SHAREFALLTHROUGH allows the *)
(*  filename to be accepted; OFN_SHARENOWARN rejects the name but puts *)
(*  up no warning (returned when the app has already put up a warning *)
(*  message); and OFN_SHAREWARN puts up the default warning message *)
(*  for sharing violations. *)
(*  *)
(*  Note:  Undefined return values map to OFN_SHAREWARN; but are *)
(*         reserved for future use. *)
  OFN_SHAREFALLTHROUGH = 2;
  OFN_SHARENOWARN = 1;
  OFN_SHAREWARN = 0;
 
  CDN_FIRST = 0-601;
  CDN_LAST = 0-699;

(*  Notifications when Open or Save dialog status changes *)
  CDN_INITDONE = CDN_FIRST-0H;
  CDN_SELCHANGE = CDN_FIRST-1H;
  CDN_FOLDERCHANGE = CDN_FIRST-2H;
  CDN_SHAREVIOLATION = CDN_FIRST-3H;
  CDN_HELP = CDN_FIRST-4H;
  CDN_FILEOK = CDN_FIRST-5H;
  CDN_TYPECHANGE = CDN_FIRST-6H;
  CDM_FIRST = WM_USER+100;
  CDM_LAST = WM_USER+200;
  CDM_GETFILEPATH = CDM_FIRST+1H;
  CDM_GETFOLDERPATH = CDM_FIRST+2H;
  CDM_GETSPEC = CDM_FIRST+0H;
  CDM_GETFOLDERIDLIST = CDM_FIRST+3H;
  CDM_SETCONTROLTEXT = CDM_FIRST+4H;
  CDM_HIDECONTROL = CDM_FIRST+5H;
  CDM_SETDEFEXT = CDM_FIRST+6H;

  CC_RGBINIT = 1H;
  CC_FULLOPEN = 2H;
  CC_PREVENTFULLOPEN = 4H;
  CC_SHOWHELP = 8H;
  CC_ENABLEHOOK = 10H;
  CC_ENABLETEMPLATE = 20H;
  CC_ENABLETEMPLATEHANDLE = 40H;
  CC_SOLIDCOLOR = 80H;
  CC_ANYCOLOR = 100H;
 
  FR_DOWN = 1H;
  FR_WHOLEWORD = 2H;
  FR_MATCHCASE = 4H;
  FR_FINDNEXT = 8H;
  FR_REPLACE = 10H;
  FR_REPLACEALL = 20H;
  FR_DIALOGTERM = 40H;
  FR_SHOWHELP = 80H;
  FR_ENABLEHOOK = 100H;
  FR_ENABLETEMPLATE = 200H;
  FR_NOUPDOWN = 400H;
  FR_NOMATCHCASE = 800H;
  FR_NOWHOLEWORD = 1000H;
  FR_ENABLETEMPLATEHANDLE = 2000H;
  FR_HIDEUPDOWN = 4000H;
  FR_HIDEMATCHCASE = 8000H;
  FR_HIDEWHOLEWORD = 10000H;
 
  CF_SCREENFONTS = 1H;
  CF_PRINTERFONTS = 2H;
  CF_BOTH = 3;
  CF_SHOWHELP = 4H;
  CF_ENABLEHOOK = 8H;
  CF_ENABLETEMPLATE = 10H;
  CF_ENABLETEMPLATEHANDLE = 20H;
  CF_INITTOLOGFONTSTRUCT = 40H;
  CF_USESTYLE = 80H;
  CF_EFFECTS = 100H;
  CF_APPLY = 200H;
  CF_ANSIONLY = 400H;
  CF_SCRIPTSONLY = CF_ANSIONLY;
  CF_NOVECTORFONTS = 800H;
  CF_NOOEMFONTS = CF_NOVECTORFONTS;
  CF_NOSIMULATIONS = 1000H;
  CF_LIMITSIZE = 2000H;
  CF_FIXEDPITCHONLY = 4000H;
  CF_WYSIWYG = 8000H;                  (*  must also have CF_SCREENFONTS & CF_PRINTERFONTS *)
  CF_FORCEFONTEXIST = 10000H;
  CF_SCALABLEONLY = 20000H;
  CF_TTONLY = 40000H;
  CF_NOFACESEL = 80000H;
  CF_NOSTYLESEL = 100000H;
  CF_NOSIZESEL = 200000H;
  CF_SELECTSCRIPT = 400000H;
  CF_NOSCRIPTSEL = 800000H;
  CF_NOVERTFONTS = 1000000H;

(*  these are extra nFontType bits that are added to what is returned to the *)
(*  EnumFonts callback routine *)
  SIMULATED_FONTTYPE = 8000H;
  PRINTER_FONTTYPE = 4000H;
  SCREEN_FONTTYPE = 2000H;
  BOLD_FONTTYPE = 100H;
  ITALIC_FONTTYPE = 200H;
  REGULAR_FONTTYPE = 400H;
  WM_CHOOSEFONT_GETLOGFONT = WM_USER+1;

(*  strings used to obtain unique window message for communication *)
(*  between dialog and caller *)
  LBSELCHSTRINGA = 'commdlg_LBSelChangedNotify';
  LBSELCHSTRING = LBSELCHSTRINGA;      (* ! A *)
  SHAREVISTRINGA = 'commdlg_ShareViolation';
  SHAREVISTRING = SHAREVISTRINGA;      (* ! A *)
  FILEOKSTRINGA = 'commdlg_FileNameOK';
  FILEOKSTRING = FILEOKSTRINGA;        (* ! A *)
  COLOROKSTRINGA = 'commdlg_ColorOK';
  COLOROKSTRING = COLOROKSTRINGA;      (* ! A *)
  SETRGBSTRINGA = 'commdlg_SetRGBColor';
  SETRGBSTRING = SETRGBSTRINGA;        (* ! A *)
  HELPMSGSTRINGA = 'commdlg_help';
  HELPMSGSTRING = HELPMSGSTRINGA;      (* ! A *)
  FINDMSGSTRINGA = 'commdlg_FindReplace';
  FINDMSGSTRING = FINDMSGSTRINGA;      (* ! A *)

(*  HIWORD values for lParam of commdlg_LBSelChangeNotify message *)
  CD_LBSELNOITEMS = -1;
  CD_LBSELCHANGE = 0;
  CD_LBSELSUB = 1;
  CD_LBSELADD = 2;
 
  PD_ALLPAGES = 0H;
  PD_SELECTION = 1H;
  PD_PAGENUMS = 2H;
  PD_NOSELECTION = 4H;
  PD_NOPAGENUMS = 8H;
  PD_COLLATE = 10H;
  PD_PRINTTOFILE = 20H;
  PD_PRINTSETUP = 40H;
  PD_NOWARNING = 80H;
  PD_RETURNDC = 100H;
  PD_RETURNIC = 200H;
  PD_RETURNDEFAULT = 400H;
  PD_SHOWHELP = 800H;
  PD_ENABLEPRINTHOOK = 1000H;
  PD_ENABLESETUPHOOK = 2000H;
  PD_ENABLEPRINTTEMPLATE = 4000H;
  PD_ENABLESETUPTEMPLATE = 8000H;
  PD_ENABLEPRINTTEMPLATEHANDLE = 10000H;
  PD_ENABLESETUPTEMPLATEHANDLE = 20000H;
  PD_USEDEVMODECOPIES = 40000H;
  PD_USEDEVMODECOPIESANDCOLLATE = 40000H;
  PD_DISABLEPRINTTOFILE = 80000H;
  PD_HIDEPRINTTOFILE = 100000H;
  PD_NONETWORKBUTTON = 200000H;

  DN_DEFAULTPRN = 1H;

  WM_PSD_PAGESETUPDLG = WM_USER;
  WM_PSD_FULLPAGERECT = WM_USER+1;
  WM_PSD_MINMARGINRECT = WM_USER+2;
  WM_PSD_MARGINRECT = WM_USER+3;
  WM_PSD_GREEKTEXTRECT = WM_USER+4;
  WM_PSD_ENVSTAMPRECT = WM_USER+5;
  WM_PSD_YAFULLPAGERECT = WM_USER+6;
 
  PSD_DEFAULTMINMARGINS = 0H;          (*  default (printer's) *)
  PSD_INWININIINTLMEASURE = 0H;        (*  1st of 4 possible *)
  PSD_MINMARGINS = 1H;                 (*  use caller's *)
  PSD_MARGINS = 2H;                    (*  use caller's *)
  PSD_INTHOUSANDTHSOFINCHES = 4H;      (*  2nd of 4 possible *)
  PSD_INHUNDREDTHSOFMILLIMETERS = 8H;  (*  3rd of 4 possible *)
  PSD_DISABLEMARGINS = 10H;
  PSD_DISABLEPRINTER = 20H;
  PSD_NOWARNING = 80H;                 (*  must be same as PD_* *)
  PSD_DISABLEORIENTATION = 100H;
  PSD_RETURNDEFAULT = 400H;            (*  must be same as PD_* *)
  PSD_DISABLEPAPER = 200H;
  PSD_SHOWHELP = 800H;                 (*  must be same as PD_* *)
  PSD_ENABLEPAGESETUPHOOK = 2000H;     (*  must be same as PD_* *)
  PSD_ENABLEPAGESETUPTEMPLATE = 8000H; (*  must be same as PD_* *)
  PSD_ENABLEPAGESETUPTEMPLATEHANDLE = 20000H;   (*  must be same as PD_* *)
  PSD_ENABLEPAGEPAINTHOOK = 40000H;
  PSD_DISABLEPAGEPAINTING = 80000H;
  PSD_NONETWORKBUTTON = 200000H;       (*  must be same as PD_* *)

TYPE 
  LPOFNHOOKPROC = PROCEDURE [_APICALL] ( hwnd: WD.HWND; uint: WD.UINT; wParam: WD.WPARAM; 
                            lParam: WD.LPARAM ): WD.UINT;

  OFNA = RECORD [_NOTALIGNED]
    lStructSize      : WD.DWORD;
    hwndOwner        : WD.HWND;
    hInstance        : WD.HINSTANCE;
    lpstrFilter      : WD.LPCSTR;
    lpstrCustomFilter: WD.LPSTR;
    nMaxCustFilter   : WD.DWORD;
    nFilterIndex     : WD.DWORD;
    lpstrFile        : WD.LPSTR;
    nMaxFile         : WD.DWORD;
    lpstrFileTitle   : WD.LPSTR;
    nMaxFileTitle    : WD.DWORD;
    lpstrInitialDir  : WD.LPCSTR;
    lpstrTitle       : WD.LPCSTR;
    Flags            : WD.DWORD;
    nFileOffset      : WD.WORD;
    nFileExtension   : WD.WORD;
    lpstrDefExt      : WD.LPCSTR;
    lCustData        : WD.LPARAM;
    lpfnHook         : LPOFNHOOKPROC;
    lpTemplateName   : WD.LPCSTR;
  END;
  OPENFILENAMEA = OFNA;
  LPOPENFILENAMEA = POINTER TO OFNA;

  OFNW = RECORD [_NOTALIGNED]
    lStructSize      : WD.DWORD;
    hwndOwner        : WD.HWND;
    hInstance        : WD.HINSTANCE;
    lpstrFilter      : WD.LPCWSTR;
    lpstrCustomFilter: WD.LPWSTR;
    nMaxCustFilter   : WD.DWORD;
    nFilterIndex     : WD.DWORD;
    lpstrFile        : WD.LPWSTR;
    nMaxFile         : WD.DWORD;
    lpstrFileTitle   : WD.LPWSTR;
    nMaxFileTitle    : WD.DWORD;
    lpstrInitialDir  : WD.LPCWSTR;
    lpstrTitle       : WD.LPCWSTR;
    Flags            : WD.DWORD;
    nFileOffset      : WD.WORD;
    nFileExtension   : WD.WORD;
    lpstrDefExt      : WD.LPCWSTR;
    lCustData        : WD.LPARAM;
    lpfnHook         : LPOFNHOOKPROC;
    lpTemplateName   : WD.LPCWSTR;
  END;

  OPENFILENAMEW = OFNW;
  LPOPENFILENAMEW = POINTER TO OFNW;
  OPENFILENAME = OFNA;        (* ! A *)
  LPOPENFILENAME = LPOPENFILENAMEA;  (* ! A *)
 
  LPCCHOOKPROC = LPOFNHOOKPROC;

(*  Structure used for all OpenFileName notifications *)

  OFNOTIFYA = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    lpOFN  : LPOPENFILENAMEA;
    pszFile: WD.LPSTR;    (*  May be NULL *)
  END;
  LPOFNOTIFYA = POINTER TO OFNOTIFYA;

(*  Structure used for all OpenFileName notifications *)

  OFNOTIFYW = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    lpOFN  : LPOPENFILENAMEW;
    pszFile: WD.LPWSTR;   (*  May be NULL *)
  END;
  LPOFNOTIFYW = POINTER TO OFNOTIFYW;
  OFNOTIFY = OFNOTIFYA;      (* ! A *)
  LPOFNOTIFY = LPOFNOTIFYA;    (* ! A *)
 
  CHOOSECOLORA = RECORD [_NOTALIGNED]
    lStructSize   : WD.DWORD;
    hwndOwner     : WD.HWND;
    hInstance     : WD.HWND;
    rgbResult     : WD.COLORREF;
    lpCustColors  : WD.PULONG;
    Flags         : WD.DWORD;
    lCustData     : WD.LPARAM;
    lpfnHook      : LPCCHOOKPROC;
    lpTemplateName: WD.LPCSTR;
  END;
  LPCHOOSECOLORA = POINTER TO CHOOSECOLORA;

  CHOOSECOLORW = RECORD [_NOTALIGNED]
    lStructSize   : WD.DWORD;
    hwndOwner     : WD.HWND;
    hInstance     : WD.HWND;
    rgbResult     : WD.COLORREF;
    lpCustColors  : WD.PULONG;
    Flags         : WD.DWORD;
    lCustData     : WD.LPARAM;
    lpfnHook      : LPCCHOOKPROC;
    lpTemplateName: WD.LPCWSTR;
  END;
  LPCHOOSECOLORW = POINTER TO CHOOSECOLORW;
  CHOOSECOLOR = CHOOSECOLORA;    (* ! A *)
  LPCHOOSECOLOR = LPCHOOSECOLORA;  (* ! A *)

  LPFRHOOKPROC = LPOFNHOOKPROC;

  FINDREPLACEA = RECORD [_NOTALIGNED]
    lStructSize     : WD.DWORD;       (*  size of this struct 0x20 *)
    hwndOwner       : WD.HWND;        (*  handle to owner's window *)
    hInstance       : WD.HINSTANCE;   (*  instance handle of.EXE that *)
(*    contains cust. dlg. template *)
    Flags           : WD.DWORD;       (*  one or more of the FR_?? *)
    lpstrFindWhat   : WD.LPSTR;       (*  ptr. to search string *)
    lpstrReplaceWith: WD.LPSTR;       (*  ptr. to replace string *)
    wFindWhatLen    : WD.WORD;        (*  size of find buffer *)
    wReplaceWithLen : WD.WORD;        (*  size of replace buffer *)
    lCustData       : WD.LPARAM;      (*  data passed to hook fn. *)
    lpfnHook        : LPFRHOOKPROC;           (*  ptr. to hook fn. or NULL *)
    lpTemplateName  : WD.LPCSTR;      (*  custom template name *)
  END;
  LPFINDREPLACEA = POINTER TO FINDREPLACEA;

  FINDREPLACEW = RECORD [_NOTALIGNED]
    lStructSize     : WD.DWORD;       (*  size of this struct 0x20 *)
    hwndOwner       : WD.HWND;        (*  handle to owner's window *)
    hInstance       : WD.HINSTANCE;   (*  instance handle of.EXE that *)
 
(*    contains cust. dlg. template *)
    Flags           : WD.DWORD;       (*  one or more of the FR_?? *)
    lpstrFindWhat   : WD.LPWSTR;      (*  ptr. to search string *)
    lpstrReplaceWith: WD.LPWSTR;      (*  ptr. to replace string *)
    wFindWhatLen    : WD.WORD;        (*  size of find buffer *)
    wReplaceWithLen : WD.WORD;        (*  size of replace buffer *)
    lCustData       : WD.LPARAM;      (*  data passed to hook fn. *)
    lpfnHook        : LPFRHOOKPROC;           (*  ptr. to hook fn. or NULL *)
    lpTemplateName  : WD.LPCWSTR;     (*  custom template name *)
  END;
  LPFINDREPLACEW = POINTER TO FINDREPLACEW;
  FINDREPLACE = FINDREPLACEA;     (* ! A *)
  LPFINDREPLACE = LPFINDREPLACEA;   (* ! A *)
 
  LPCFHOOKPROC = LPOFNHOOKPROC;

  CHOOSEFONTA = RECORD [_NOTALIGNED]
    lStructSize           : WD.DWORD;
    hwndOwner             : WD.HWND;           (*  caller's window handle *)
    hDC                   : WD.HDC;            (*  printer DC/IC or NULL *)
    lpLogFont             : LONGINT;           (*  ptr. to a LOGFONT struct *)
    iPointSize            : WD.INT;            (*  10 * size in points of selected font *)
    Flags                 : WD.DWORD;          (*  enum. type flags *)
    rgbColors             : WD.COLORREF;       (*  returned text color *)
    lCustData             : WD.LPARAM;         (*  data passed to hook fn. *)
    lpfnHook              : LPCFHOOKPROC;              (*  ptr. to hook function *)
    lpTemplateName        : WD.LPCSTR;         (*  custom template name *)
    hInstance             : WD.HINSTANCE;      (*  instance handle of.EXE that *)
 
(*    contains cust. dlg. template *)
    lpszStyle             : WD.LPSTR;          (*  return the style field here *)
 
(*  must be LF_FACESIZE or bigger *)
    nFontType             : WD.WORD;           (*  same value reported to the EnumFonts *)
 
(*    call back with the extra FONTTYPE_ *)
 
(*    bits added *)
    ___MISSING_ALIGNMENT__: WD.WORD;
    nSizeMin              : WD.INT;   (*  minimum pt size allowed & *)
    nSizeMax              : WD.INT;   (*  max pt size allowed if *)
 
(*    CF_LIMITSIZE is used *)
  END;
  LPCHOOSEFONTA = POINTER TO CHOOSEFONTA;
  CHOOSEFONTW = RECORD [_NOTALIGNED]
    lStructSize           : WD.DWORD;
    hwndOwner             : WD.HWND;           (*  caller's window handle *)
    hDC                   : WD.HDC;            (*  printer DC/IC or NULL *)
    lpLogFont             : LONGINT;           (*  ptr. to a LOGFONT struct *)
    iPointSize            : INTEGER;   (*  10 * size in points of selected font *)
    Flags                 : WD.DWORD;          (*  enum. type flags *)
    rgbColors             : WD.COLORREF;       (*  returned text color *)
    lCustData             : WD.LPARAM;         (*  data passed to hook fn. *)
    lpfnHook              : LPCFHOOKPROC;              (*  ptr. to hook function *)
    lpTemplateName        : WD.LPCWSTR;        (*  custom template name *)
    hInstance             : WD.HINSTANCE;      (*  instance handle of.EXE that *)
 
(*    contains cust. dlg. template *)
    lpszStyle             : WD.LPWSTR;         (*  return the style field here *)
 
(*  must be LF_FACESIZE or bigger *)
    nFontType             : WD.WORD;           (*  same value reported to the EnumFonts *)
 
(*    call back with the extra FONTTYPE_ *)
 
(*    bits added *)
    ___MISSING_ALIGNMENT__: WD.WORD;
    nSizeMin              : INTEGER;   (*  minimum pt size allowed & *)
    nSizeMax              : INTEGER;   (*  max pt size allowed if *)
 
(*    CF_LIMITSIZE is used *)
  END;
  LPCHOOSEFONTW = POINTER TO CHOOSEFONTW;
  CHOOSEFONT = CHOOSEFONTA;      (* ! A *)
  LPCHOOSEFONT = LPCHOOSEFONTA;    (* ! A *)
 
  LPPRINTHOOKPROC = LPOFNHOOKPROC;
  LPSETUPHOOKPROC = LPOFNHOOKPROC;

  PDA = RECORD [_NOTALIGNED]
    lStructSize        : WD.DWORD;
    hwndOwner          : WD.HWND;
    hDevMode           : WD.HGLOBAL;
    hDevNames          : WD.HGLOBAL;
    hDC                : WD.HDC;
    Flags              : WD.DWORD;
    nFromPage          : WD.WORD;
    nToPage            : WD.WORD;
    nMinPage           : WD.WORD;
    nMaxPage           : WD.WORD;
    nCopies            : WD.WORD;
    hInstance          : WD.HINSTANCE;
    lCustData          : WD.LPARAM;
    lpfnPrintHook      : LPPRINTHOOKPROC;
    lpfnSetupHook      : LPSETUPHOOKPROC;
    lpPrintTemplateName: WD.LPCSTR;
    lpSetupTemplateName: WD.LPCSTR;
    hPrintTemplate     : WD.HGLOBAL;
    hSetupTemplate     : WD.HGLOBAL;
  END;
  PRINTDLGA = PDA;
  LPPRINTDLGA = POINTER TO PDA;

  PDW = RECORD [_NOTALIGNED]
    lStructSize        : WD.DWORD;
    hwndOwner          : WD.HWND;
    hDevMode           : WD.HGLOBAL;
    hDevNames          : WD.HGLOBAL;
    hDC                : WD.HDC;
    Flags              : WD.DWORD;
    nFromPage          : WD.WORD;
    nToPage            : WD.WORD;
    nMinPage           : WD.WORD;
    nMaxPage           : WD.WORD;
    nCopies            : WD.WORD;
    hInstance          : WD.HINSTANCE;
    lCustData          : WD.LPARAM;
    lpfnPrintHook      : LPPRINTHOOKPROC;
    lpfnSetupHook      : LPSETUPHOOKPROC;
    lpPrintTemplateName: WD.LPCWSTR;
    lpSetupTemplateName: WD.LPCWSTR;
    hPrintTemplate     : WD.HGLOBAL;
    hSetupTemplate     : WD.HGLOBAL;
  END;
  PRINTDLGW = PDW;
  LPPRINTDLGW = POINTER TO PDW;
  PRINTDLG = PDA;         (* ! A *)
  LPPRINTDLG = LPPRINTDLGA;     (* ! A *)

  DEVNAMES = RECORD [_NOTALIGNED]
    wDriverOffset: WD.WORD;
    wDeviceOffset: WD.WORD;
    wOutputOffset: WD.WORD;
    wDefault     : WD.WORD;
  END;
  LPDEVNAMES = POINTER TO DEVNAMES;
 
  LPPAGEPAINTHOOK = LPOFNHOOKPROC;
  LPPAGESETUPHOOK = LPOFNHOOKPROC;

  PSDA = RECORD [_NOTALIGNED]
    lStructSize            : WD.DWORD;
    hwndOwner              : WD.HWND;
    hDevMode               : WD.HGLOBAL;
    hDevNames              : WD.HGLOBAL;
    Flags                  : WD.DWORD;
    ptPaperSize            : WD.POINT;
    rtMinMargin            : WD.RECT;
    rtMargin               : WD.RECT;
    hInstance              : WD.HINSTANCE;
    lCustData              : WD.LPARAM;
    lpfnPageSetupHook      : LPPAGESETUPHOOK;
    lpfnPagePaintHook      : LPPAGEPAINTHOOK;
    lpPageSetupTemplateName: WD.LPCSTR;
    hPageSetupTemplate     : WD.HGLOBAL;
  END;
  PAGESETUPDLGA = PSDA;
  LPPAGESETUPDLGA = POINTER TO PSDA;

  PSDW = RECORD [_NOTALIGNED]
    lStructSize            : WD.DWORD;
    hwndOwner              : WD.HWND;
    hDevMode               : WD.HGLOBAL;
    hDevNames              : WD.HGLOBAL;
    Flags                  : WD.DWORD;
    ptPaperSize            : WD.POINT;
    rtMinMargin            : WD.RECT;
    rtMargin               : WD.RECT;
    hInstance              : WD.HINSTANCE;
    lCustData              : WD.LPARAM;
    lpfnPageSetupHook      : LPPAGESETUPHOOK;
    lpfnPagePaintHook      : LPPAGEPAINTHOOK;
    lpPageSetupTemplateName: WD.LPCWSTR;
    hPageSetupTemplate     : WD.HGLOBAL;
  END;
  PAGESETUPDLGW = PSDW;
  LPPAGESETUPDLGW = POINTER TO PSDW;
  PAGESETUPDLG = PSDA;              (* ! A *)
  LPPAGESETUPDLG = LPPAGESETUPDLGA;    (* ! A *)

PROCEDURE [_APICALL] GetOpenFileNameA ( VAR STATICTYPED arg0: OPENFILENAMEA ): WD.BOOL;
PROCEDURE [_APICALL] GetOpenFileNameW ( VAR STATICTYPED arg0: OPENFILENAMEW ): WD.BOOL;
(*  !   GetOpenFileName *)

PROCEDURE [_APICALL] GetSaveFileNameA ( VAR STATICTYPED arg0: OPENFILENAMEA ): WD.BOOL;
PROCEDURE [_APICALL] GetSaveFileNameW ( VAR STATICTYPED arg0: OPENFILENAMEW ): WD.BOOL;
(*  ! GetSaveFileName *)

PROCEDURE [_APICALL] GetFileTitleA ( arg0: WD.LPCSTR; arg1: WD.LPSTR;
                          arg2: WD.WORD ): INTEGER;
PROCEDURE [_APICALL] GetFileTitleW ( arg0: WD.LPCWSTR; arg1: WD.LPWSTR;
                          arg2: WD.WORD ): INTEGER;
(*  ! GetFileTitle *)

PROCEDURE [_APICALL] ChooseColorA ( VAR STATICTYPED arg0: CHOOSECOLORA ): WD.BOOL;
PROCEDURE [_APICALL] ChooseColorW ( VAR STATICTYPED arg0: CHOOSECOLORW ): WD.BOOL;
(*  !  ChooseColor *)

PROCEDURE [_APICALL] FindTextA ( VAR STATICTYPED arg0: FINDREPLACEA ): WD.HWND;
PROCEDURE [_APICALL] FindTextW ( VAR STATICTYPED arg0: FINDREPLACEW ): WD.HWND;
(*  !  FindText *)

PROCEDURE [_APICALL] ReplaceTextA ( VAR STATICTYPED arg0: FINDREPLACEA ): WD.HWND;
PROCEDURE [_APICALL] ReplaceTextW ( VAR STATICTYPED arg0: FINDREPLACEW ): WD.HWND;
(*  !   ReplaceText *)

PROCEDURE [_APICALL] ChooseFontA ( VAR STATICTYPED arg0: CHOOSEFONTA ): WD.BOOL;
PROCEDURE [_APICALL] ChooseFontW ( VAR STATICTYPED arg0: CHOOSEFONTW ): WD.BOOL;
(*  !  ChooseFont *)

PROCEDURE [_APICALL] PrintDlgA ( VAR STATICTYPED arg0: PRINTDLGA ): WD.BOOL;
PROCEDURE [_APICALL] PrintDlgW ( VAR STATICTYPED arg0: PRINTDLGW ): WD.BOOL;
(*  !  PrintDlg *)

PROCEDURE [_APICALL] CommDlgExtendedError (  ): WD.DWORD;

PROCEDURE [_APICALL] PageSetupDlgA ( VAR STATICTYPED arg0: PAGESETUPDLGA ): WD.BOOL;
PROCEDURE [_APICALL] PageSetupDlgW ( VAR STATICTYPED arg0: PAGESETUPDLGW ): WD.BOOL;
(*  !  PageSetupDlg *)

(* Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetSpecA ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetSpecA ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CommDlg_OpenSave_GetSpec = CommDlg_OpenSave_GetSpecA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetSpecW ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetSpecW ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetFilePathA ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetFilePathA ( _hdlg; _psz;
                                              _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CommDlg_OpenSave_GetFilePath = CommDlg_OpenSave_GetFilePathA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetFilePathW ( _hdlg; _psz; _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetFilePathW ( _hdlg; _psz;
                                              _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetFolderPathA ( _hdlg; _psz;
                                             _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetFolderPathA ( _hdlg; _psz;
                                                _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CommDlg_OpenSave_GetFolderPath = CommDlg_OpenSave_GetFolderPathA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetFolderPathW ( _hdlg; _psz;
                                             _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetFolderPathW ( _hdlg; _psz;
                                                _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_GetFolderIDList ( _hdlg; _pidl;
                                              _cbmax: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_GetFolderIDList ( _hdlg; _pidl;
                                                 _cbmax: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_SetControlText ( _hdlg; _id; _text: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_SetControlText ( _hdlg; _id;
                                                _text: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_HideControl ( _hdlg; _id: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_HideControl ( _hdlg; _id: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CommDlg_OpenSave_SetDefExt ( _hdlg; _pszext: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CommDlg_OpenSave_SetDefExt ( _hdlg; _pszext: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros *)

END CommDlg.
