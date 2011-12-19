DEFINITION WPrint;

IMPORT WinB:=WinBase;

CONST

  PQERROR=-1;
  USA_COUNTRYCODE=1;

(* size of a device name string *)
  CCHDEVICENAME =32;
  CCHPAPERNAME  =64;

(* current version of specification *)
  DM_SPECVERSION =030AH;

(* field selection bits *)
  DM_ORIENTATION      =00000001H;
  DM_PAPERSIZE        =00000002H;
  DM_PAPERLENGTH      =00000004H;
  DM_PAPERWIDTH       =00000008H;
  DM_SCALE            =00000010H;
  DM_COPIES           =00000100H;
  DM_DEFAULTSOURCE    =00000200H;
  DM_PRINTQUALITY     =00000400H;
  DM_COLOR            =00000800H;
  DM_DUPLEX           =00001000H;
  DM_YRESOLUTION      =00002000H;
  DM_TTOPTION         =00004000H;

(* orientation selections *)
  DMORIENT_PORTRAIT   =1;
  DMORIENT_LANDSCAPE  =2;

(* paper selections *)
(*  Warning: The PostScript driver mistakingly uses DMPAPER_ values between
 *  50 and 56.  Don't use this range when defining new paper sizes.
 *)
  DMPAPER_LETTER      =1;           (* Letter 8 1/2 x 11 in               *)
  DMPAPER_FIRST       =DMPAPER_LETTER;
  DMPAPER_LETTERSMALL =2;           (* Letter Small 8 1/2 x 11 in         *)
  DMPAPER_TABLOID     =3;           (* Tabloid 11 x 17 in                 *)
  DMPAPER_LEDGER      =4;           (* Ledger 17 x 11 in                  *)
  DMPAPER_LEGAL       =5;           (* Legal 8 1/2 x 14 in                *)
  DMPAPER_STATEMENT   =6;           (* Statement 5 1/2 x 8 1/2 in         *)
  DMPAPER_EXECUTIVE   =7;           (* Executive 7 1/4 x 10 1/2 in        *)
  DMPAPER_A3          =8;           (* A3 297 x 420 mm                    *)
  DMPAPER_A4          =9;           (* A4 210 x 297 mm                    *)
  DMPAPER_A4SMALL     =10;          (* A4 Small 210 x 297 mm              *)
  DMPAPER_A5          =11;          (* A5 148 x 210 mm                    *)
  DMPAPER_B4          =12;          (* B4 250 x 354                       *)
  DMPAPER_B5          =13;          (* B5 182 x 257 mm                    *)
  DMPAPER_FOLIO       =14;          (* Folio 8 1/2 x 13 in                *)
  DMPAPER_QUARTO      =15;          (* Quarto 215 x 275 mm                *)
  DMPAPER_10X14       =16;          (* 10x14 in                           *)
  DMPAPER_11X17       =17;          (* 11x17 in                           *)
  DMPAPER_NOTE        =18;          (* Note 8 1/2 x 11 in                 *)
  DMPAPER_ENV_9       =19;          (* Envelope #9 3 7/8 x 8 7/8          *)
  DMPAPER_ENV_10      =20;          (* Envelope #10 4 1/8 x 9 1/2         *)
  DMPAPER_ENV_11      =21;          (* Envelope #11 4 1/2 x 10 3/8        *)
  DMPAPER_ENV_12      =22;          (* Envelope #12 4 \276 x 11           *)
  DMPAPER_ENV_14      =23;          (* Envelope #14 5 x 11 1/2            *)
  DMPAPER_CSHEET      =24;          (* C size sheet                       *)
  DMPAPER_DSHEET      =25;          (* D size sheet                       *)
  DMPAPER_ESHEET      =26;          (* E size sheet                       *)
  DMPAPER_ENV_DL      =27;          (* Envelope DL 110 x 220mm            *)
  DMPAPER_ENV_C5      =28;          (* Envelope C5 162 x 229 mm           *)
  DMPAPER_ENV_C3      =29;          (* Envelope C3  324 x 458 mm          *)
  DMPAPER_ENV_C4      =30;          (* Envelope C4  229 x 324 mm          *)
  DMPAPER_ENV_C6      =31;          (* Envelope C6  114 x 162 mm          *)
  DMPAPER_ENV_C65     =32;          (* Envelope C65 114 x 229 mm          *)
  DMPAPER_ENV_B4      =33;          (* Envelope B4  250 x 353 mm          *)
  DMPAPER_ENV_B5      =34;          (* Envelope B5  176 x 250 mm          *)
  DMPAPER_ENV_B6      =35;          (* Envelope B6  176 x 125 mm          *)
  DMPAPER_ENV_ITALY   =36;          (* Envelope 110 x 230 mm              *)
  DMPAPER_ENV_MONARCH =37;          (* Envelope Monarch 3.875 x 7.5 in    *)
  DMPAPER_ENV_PERSONAL=38;          (* 6 3/4 Envelope 3 5/8 x 6 1/2 in    *)
  DMPAPER_FANFOLD_US  =39;          (* US Std Fanfold 14 7/8 x 11 in      *)
  DMPAPER_FANFOLD_STD_GERMAN = 40;  (* German Std Fanfold 8 1/2 x 12 in   *)
  DMPAPER_FANFOLD_LGL_GERMAN = 41;  (* German Legal Fanfold 8 1/2 x 13 in *)

  DMPAPER_LAST        =DMPAPER_FANFOLD_LGL_GERMAN;

  DMPAPER_USER        =256;

(* bin selections *)
  DMBIN_UPPER         =1;
  DMBIN_FIRST         =DMBIN_UPPER;
  DMBIN_ONLYONE       =1;
  DMBIN_LOWER         =2;
  DMBIN_MIDDLE        =3;
  DMBIN_MANUAL        =4;
  DMBIN_ENVELOPE      =5;
  DMBIN_ENVMANUAL     =6;
  DMBIN_AUTO          =7;
  DMBIN_TRACTOR       =8;
  DMBIN_SMALLFMT      =9;
  DMBIN_LARGEFMT      =10;
  DMBIN_LARGECAPACITY =11;
  DMBIN_CASSETTE      =14;
  DMBIN_LAST          =DMBIN_CASSETTE;

  DMBIN_USER          =256;     (* device specific bins start here *)

(* print qualities *)
  DMRES_DRAFT         =-1;
  DMRES_LOW           =-2;
  DMRES_MEDIUM        =-3;
  DMRES_HIGH          =-4;

(* color enable/disable for color printers *)
  DMCOLOR_MONOCHROME  =1;
  DMCOLOR_COLOR       =2;

(* duplex enable *)
  DMDUP_SIMPLEX    =1;
  DMDUP_VERTICAL   =2;
  DMDUP_HORIZONTAL =3;

(* TrueType options *)
  DMTT_BITMAP     =1;       (* print TT fonts as graphics *)
  DMTT_DOWNLOAD   =2;       (* download TT fonts as soft fonts *)
  DMTT_SUBDEV     =3;       (* substitute device fonts for TT fonts *)

(* mode selections for the device mode function *)
  DM_UPDATE           =1;
  DM_COPY             =2;
  DM_PROMPT           =4;
  DM_MODIFY           =8;

  DM_IN_BUFFER        =DM_MODIFY;
  DM_IN_PROMPT        =DM_PROMPT;
  DM_OUT_BUFFER       =DM_COPY;
  DM_OUT_DEFAULT      =DM_UPDATE;

(* device capabilities indices *)
  DC_FIELDS           =1;
  DC_PAPERS           =2;
  DC_PAPERSIZE        =3;
  DC_MINEXTENT        =4;
  DC_MAXEXTENT        =5;
  DC_BINS             =6;
  DC_DUPLEX           =7;
  DC_SIZE             =8;
  DC_EXTRA            =9;
  DC_VERSION          =10;
  DC_DRIVER           =11;
  DC_BINNAMES         =12;
  DC_ENUMRESOLUTIONS  =13;
  DC_FILEDEPENDENCIES =14;
  DC_TRUETYPE         =15;
  DC_PAPERNAMES       =16;
  DC_ORIENTATION      =17;
  DC_COPIES           =18;

(* bit fields of the return value (DWORD) for DC_TRUETYPE *)
  DCTT_BITMAP         =00000001H;
  DCTT_DOWNLOAD       =00000002H;
  DCTT_SUBDEV         =00000004H;

(*(* export ordinal definitions *)
  PROC_EXTDEVICEMODE      MAKEINTRESOURCE(90)
  PROC_DEVICECAPABILITIES MAKEINTRESOURCE(91)
  PROC_OLDDEVICEMODE      MAKEINTRESOURCE(13)*)


TYPE

  HPQ=INTEGER;
  HPJOB=INTEGER;
  LPSTR=LONGINT;
  BOOL=INTEGER;
  UINT=INTEGER;
  DWORD=LONGINT;

  BANDINFOSTRUCT=RECORD [_NOTALIGNED]
    fGraphics:BOOL;
    fText:BOOL;
    rcGraphics:WinB.RECT;
  END;

  DEVMODE=RECORD [_NOTALIGNED]
    dmDeviceName:ARRAY CCHDEVICENAME OF CHAR;
    dmSpecVersion:UINT;
    dmDriverVersion:UINT;
    dmSize:UINT;
    dmDriverExtra:UINT;
    dmFields:DWORD;
    dmOrientation:INTEGER;
    dmPaperSize:INTEGER;
    dmPaperLength:INTEGER;
    dmPaperWidth:INTEGER;
    dmScale:INTEGER;
    dmCopies:INTEGER;
    dmDefaultSource:INTEGER;
    dmPrintQuality:INTEGER;
    dmColor:INTEGER;
    dmDuplex:INTEGER;
    dmYResolution:INTEGER;
    dmTTOption:INTEGER;
  END;
  LPDEVMODE=POINTER TO DEVMODE;

(* 
  define types of pointers to ExtDeviceMode() and DeviceCapabilities()
  functions
*)
  LPFNDEVMODE=PROCEDURE [_APICALL] (a:WinB.HWND; b:WinB.HMODULE; c:LPDEVMODE;
                                   d,e:LPSTR; f:LPDEVMODE; g:LPSTR; h:UINT):UINT;
  LPFNDEVCAPS=PROCEDURE [_APICALL] (a,b:LPSTR; c:UINT; d:LPSTR; e:LPDEVMODE):DWORD;

(* this structure is used by the GETSETSCREENPARAMS escape *)
  SCREENPARAMS=RECORD [_NOTALIGNED]
    angle:INTEGER;
    frequency:INTEGER;
  END;


PROCEDURE [_APICALL] CreatePQ(x:INTEGER):HPQ;
PROCEDURE [_APICALL] MinPQ(x:HPQ):INTEGER;
PROCEDURE [_APICALL] ExtractPQ(x:HPQ):INTEGER;
PROCEDURE [_APICALL] InsertPQ(a:HPQ; b,c:INTEGER):INTEGER;
PROCEDURE [_APICALL] SizePQ(a:HPQ; b:INTEGER):INTEGER;
PROCEDURE [_APICALL] DeletePQ(x:HPQ);
PROCEDURE [_APICALL] OpenJob(a,b:LPSTR; c:HPJOB);
PROCEDURE [_APICALL] StartSpoolPage(x:HPJOB):INTEGER;
PROCEDURE [_APICALL] EndSpoolPage(x:HPJOB):INTEGER;
PROCEDURE [_APICALL] WriteSpool(x:HPJOB; a:LPSTR; c:INTEGER):INTEGER;
PROCEDURE [_APICALL] CloseJob(x:HPJOB):INTEGER;
PROCEDURE [_APICALL] DeleteJob(x:HPJOB; a:INTEGER):INTEGER;
PROCEDURE [_APICALL] WriteDialog(x:HPJOB; b:LPSTR; c:INTEGER):INTEGER;
PROCEDURE [_APICALL] DeleteSpoolPage(x:HPJOB):INTEGER;
PROCEDURE [_APICALL] ResetDC(a:WinB.HDC; b:LPDEVMODE):WinB.HDC;

END WPrint.
