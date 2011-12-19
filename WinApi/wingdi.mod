(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION WinGDI;                              (**)
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
(*  07-29-1997 rel. 1.2 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(* wingdi.h -- GDI procedure declarations, constant definitions and macros    *)
(******************************************************************************)

IMPORT WD := WinDef, SYSTEM;

CONST 
  R2_BLACK = 1;                        (*   0        *)
  R2_NOTMERGEPEN = 2;                  (*  DPon      *)
  R2_MASKNOTPEN = 3;                   (*  DPna      *)
  R2_NOTCOPYPEN = 4;                   (*  PN        *)
  R2_MASKPENNOT = 5;                   (*  PDna      *)
  R2_NOT = 6;                          (*  Dn        *)
  R2_XORPEN = 7;                       (*  DPx       *)
  R2_NOTMASKPEN = 8;                   (*  DPan      *)
  R2_MASKPEN = 9;                      (*  DPa       *)
  R2_NOTXORPEN = 10;                   (*  DPxn      *)
  R2_NOP = 11;                         (*  D         *)
  R2_MERGENOTPEN = 12;                 (*  DPno      *)
  R2_COPYPEN = 13;                     (*  P         *)
  R2_MERGEPENNOT = 14;                 (*  PDno      *)
  R2_MERGEPEN = 15;                    (*  DPo       *)
  R2_WHITE = 16;                       (*   1        *)
  R2_LAST = 16;

(*  Ternary raster operations  *)
  SRCCOPY = 13369376;                  (*  dest = source                    *)
  SRCPAINT = 15597702;                 (*  dest = source OR dest            *)
  SRCAND = 8913094;                    (*  dest = source AND dest           *)
  SRCINVERT = 6684742;                 (*  dest = source XOR dest           *)
  SRCERASE = 4457256;                  (*  dest = source AND (NOT dest )    *)
  NOTSRCCOPY = 3342344;                (*  dest = (NOT source)              *)
  NOTSRCERASE = 1114278;               (*  dest = (NOT src) AND (NOT dest)  *)
  MERGECOPY = 12583114;                (*  dest = (source AND pattern)      *)
  MERGEPAINT = 12255782;               (*  dest = (NOT source) OR dest      *)
  PATCOPY = 15728673;                  (*  dest = pattern                   *)
  PATPAINT = 16452105;                 (*  dest = DPSnoo                    *)
  PATINVERT = 5898313;                 (*  dest = pattern XOR dest          *)
  DSTINVERT = 5570569;                 (*  dest = (NOT dest)                *)
  BLACKNESS = 66;                      (*  dest = BLACK                     *)
  WHITENESS = 16711778;                (*  dest = WHITE                     *)

(*  Quaternary raster codes  *)


 
  GDI_ERROR = -1H;
  HGDI_ERROR = -1;

(*  Region Flags  *)
  ERROR = 0;
  RGN_ERROR = ERROR;
  NULLREGION = 1;
  SIMPLEREGION = 2;
  COMPLEXREGION = 3;

(*  CombineRgn() Styles  *)
  RGN_AND = 1;
  RGN_MIN = RGN_AND;
  RGN_OR = 2;
  RGN_XOR = 3;
  RGN_DIFF = 4;
  RGN_COPY = 5;
  RGN_MAX = RGN_COPY;

(*  StretchBlt() Modes  *)
  BLACKONWHITE = 1;
  STRETCH_ANDSCANS = BLACKONWHITE;
  WHITEONBLACK = 2;
  STRETCH_ORSCANS = WHITEONBLACK;
  COLORONCOLOR = 3;
  STRETCH_DELETESCANS = COLORONCOLOR;
  HALFTONE = 4;
  STRETCH_HALFTONE = HALFTONE;
  MAXSTRETCHBLTMODE = 4;

(*  New StretchBlt() Modes  *)
(*  PolyFill() Modes  *)
  ALTERNATE = 1;
  WINDING = 2;
  POLYFILL_LAST = 2;

(*  Text Alignment Options  *)
  TA_NOUPDATECP = 0;
  TA_UPDATECP = 1;
  TA_LEFT = 0;
  VTA_TOP = TA_LEFT;
  TA_RIGHT = 2;
  VTA_BOTTOM = TA_RIGHT;
  TA_CENTER = 6;
  VTA_CENTER = TA_CENTER;
  TA_TOP = 0;
  VTA_RIGHT = TA_TOP;
  TA_BOTTOM = 8;
  VTA_LEFT = TA_BOTTOM;
  TA_BASELINE = 24;
  VTA_BASELINE = TA_BASELINE;
  TA_RTLREADING = 256;
  TA_MASK = ((TA_BASELINE+TA_CENTER)+TA_UPDATECP)+TA_RTLREADING;
  ETO_OPAQUE = 2H;
  ETO_CLIPPED = 4H;
  ETO_GLYPH_INDEX = 10H;
  ETO_RTLREADING = 80H;
  ASPECT_FILTERING = 1H;

(*  Bounds Accumulation APIs  *)
  DCB_RESET = 1H;
  DCB_ACCUMULATE = 2H;
  DCB_DIRTY = DCB_ACCUMULATE;
  DCB_SET = 3;
  DCB_ENABLE = 4H;
  DCB_DISABLE = 8H;

(*  Metafile Functions  *)
  META_SETBKCOLOR = 201H;
  META_SETBKMODE = 102H;
  META_SETMAPMODE = 103H;
  META_SETROP2 = 104H;
  META_SETRELABS = 105H;
  META_SETPOLYFILLMODE = 106H;
  META_SETSTRETCHBLTMODE = 107H;
  META_SETTEXTCHAREXTRA = 108H;
  META_SETTEXTCOLOR = 209H;
  META_SETTEXTJUSTIFICATION = 20AH;
  META_SETWINDOWORG = 20BH;
  META_SETWINDOWEXT = 20CH;
  META_SETVIEWPORTORG = 20DH;
  META_SETVIEWPORTEXT = 20EH;
  META_OFFSETWINDOWORG = 20FH;
  META_SCALEWINDOWEXT = 410H;
  META_OFFSETVIEWPORTORG = 211H;
  META_SCALEVIEWPORTEXT = 412H;
  META_LINETO = 213H;
  META_MOVETO = 214H;
  META_EXCLUDECLIPRECT = 415H;
  META_INTERSECTCLIPRECT = 416H;
  META_ARC = 817H;
  META_ELLIPSE = 418H;
  META_FLOODFILL = 419H;
  META_PIE = 81AH;
  META_RECTANGLE = 41BH;
  META_ROUNDRECT = 61CH;
  META_PATBLT = 61DH;
  META_SAVEDC = 1EH;
  META_SETPIXEL = 41FH;
  META_OFFSETCLIPRGN = 220H;
  META_TEXTOUT = 521H;
  META_BITBLT = 922H;
  META_STRETCHBLT = 0B23H;
  META_POLYGON = 324H;
  META_POLYLINE = 325H;
  META_ESCAPE = 626H;
  META_RESTOREDC = 127H;
  META_FILLREGION = 228H;
  META_FRAMEREGION = 429H;
  META_INVERTREGION = 12AH;
  META_PAINTREGION = 12BH;
  META_SELECTCLIPREGION = 12CH;
  META_SELECTOBJECT = 12DH;
  META_SETTEXTALIGN = 12EH;
  META_CHORD = 830H;
  META_SETMAPPERFLAGS = 231H;
  META_EXTTEXTOUT = 0A32H;
  META_SETDIBTODEV = 0D33H;
  META_SELECTPALETTE = 234H;
  META_REALIZEPALETTE = 35H;
  META_ANIMATEPALETTE = 436H;
  META_SETPALENTRIES = 37H;
  META_POLYPOLYGON = 538H;
  META_RESIZEPALETTE = 139H;
  META_DIBBITBLT = 940H;
  META_DIBSTRETCHBLT = 0B41H;
  META_DIBCREATEPATTERNBRUSH = 142H;
  META_STRETCHDIB = 0F43H;
  META_EXTFLOODFILL = 548H;
  META_DELETEOBJECT = 1F0H;
  META_CREATEPALETTE = 0F7H;
  META_CREATEPATTERNBRUSH = 1F9H;
  META_CREATEPENINDIRECT = 2FAH;
  META_CREATEFONTINDIRECT = 2FBH;
  META_CREATEBRUSHINDIRECT = 2FCH;
  META_CREATEREGION = 6FFH;

(*  GDI Escapes  *)
  NEWFRAME = 1;
  ABORTDOC = 2;
  NEXTBAND = 3;
  SETCOLORTABLE = 4;
  GETCOLORTABLE = 5;
  FLUSHOUTPUT = 6;
  DRAFTMODE = 7;
  QUERYESCSUPPORT = 8;
  SETABORTPROC = 9;
  STARTDOC = 10;
  ENDDOC = 11;
  GETPHYSPAGESIZE = 12;
  GETPRINTINGOFFSET = 13;
  GETSCALINGFACTOR = 14;
  MFCOMMENT = 15;
  GETPENWIDTH = 16;
  SETCOPYCOUNT = 17;
  SELECTPAPERSOURCE = 18;
  DEVICEDATA = 19;
  PASSTHROUGH = 19;
  GETTECHNOLGY = 20;
  GETTECHNOLOGY = 20;
  SETLINECAP = 21;
  SETLINEJOIN = 22;
  SETMITERLIMIT = 23;
  BANDINFO = 24;
  DRAWPATTERNRECT = 25;
  GETVECTORPENSIZE = 26;
  GETVECTORBRUSHSIZE = 27;
  ENABLEDUPLEX = 28;
  GETSETPAPERBINS = 29;
  GETSETPRINTORIENT = 30;
  ENUMPAPERBINS = 31;
  SETDIBSCALING = 32;
  EPSPRINTING = 33;
  ENUMPAPERMETRICS = 34;
  GETSETPAPERMETRICS = 35;
  POSTSCRIPT_DATA = 37;
  POSTSCRIPT_IGNORE = 38;
  MOUSETRAILS = 39;
  GETDEVICEUNITS = 42;
  GETEXTENDEDTEXTMETRICS = 256;
  GETEXTENTTABLE = 257;
  GETPAIRKERNTABLE = 258;
  GETTRACKKERNTABLE = 259;
  EXTTEXTOUT = 512;
  GETFACENAME = 513;
  DOWNLOADFACE = 514;
  ENABLERELATIVEWIDTHS = 768;
  ENABLEPAIRKERNING = 769;
  SETKERNTRACK = 770;
  SETALLJUSTVALUES = 771;
  SETCHARSET = 772;
  STRETCHBLT = 2048;
  GETSETSCREENPARAMS = 3072;
  QUERYDIBSUPPORT = 3073;
  BEGIN_PATH = 4096;
  CLIP_TO_PATH = 4097;
  END_PATH = 4098;
  EXT_DEVICE_CAPS = 4099;
  RESTORE_CTM = 4100;
  SAVE_CTM = 4101;
  SET_ARC_DIRECTION = 4102;
  SET_BACKGROUND_COLOR = 4103;
  SET_POLY_MODE = 4104;
  SET_SCREEN_ANGLE = 4105;
  SET_SPREAD = 4106;
  TRANSFORM_CTM = 4107;
  SET_CLIP_BOX = 4108;
  SET_BOUNDS = 4109;
  SET_MIRROR_MODE = 4110;
  OPENCHANNEL = 4110;
  DOWNLOADHEADER = 4111;
  CLOSECHANNEL = 4112;
  POSTSCRIPT_PASSTHROUGH = 4115;
  ENCAPSULATED_POSTSCRIPT = 4116;

(*  Flag returned from QUERYDIBSUPPORT  *)
  QDI_SETDIBITS = 1;
  QDI_GETDIBITS = 2;
  QDI_DIBTOSCREEN = 4;
  QDI_STRETCHDIB = 8;

(*  Spooler Error Codes  *)
  SP_NOTREPORTED = 4000H;
  SP_ERROR = -1;
  SP_APPABORT = -2;
  SP_USERABORT = -3;
  SP_OUTOFDISK = -4;
  SP_OUTOFMEMORY = -5;
  PR_JOBSTATUS = 0H;

(*  Object Definitions for EnumObjects()  *)
  OBJ_PEN = 1;
  OBJ_BRUSH = 2;
  OBJ_DC = 3;
  OBJ_METADC = 4;
  OBJ_PAL = 5;
  OBJ_FONT = 6;
  OBJ_BITMAP = 7;
  OBJ_REGION = 8;
  OBJ_METAFILE = 9;
  OBJ_MEMDC = 10;
  OBJ_EXTPEN = 11;
  OBJ_ENHMETADC = 12;
  OBJ_ENHMETAFILE = 13;

  LCS_CALIBRATED_RGB = 0H;
  LCS_DEVICE_RGB = 1H;
  LCS_DEVICE_CMYK = 2H;

(*  xform stuff  *)
  MWT_IDENTITY = 1;
  MWT_MIN = MWT_IDENTITY;
  MWT_LEFTMULTIPLY = 2;
  MWT_RIGHTMULTIPLY = 3;
  MWT_MAX = MWT_RIGHTMULTIPLY;

  LCS_GM_BUSINESS = 1H;
  LCS_GM_GRAPHICS = 2H;
  LCS_GM_IMAGES = 4H;

(*  ICM Defines for results from CheckColorInGamut()  *)
  CM_OUT_OF_GAMUT = 255;
  CM_IN_GAMUT = 0;
(*  constants for the biCompression field  *)

  BI_RGB = 0;
  BI_RLE8 = 1;
  BI_RLE4 = 2;
  BI_BITFIELDS = 3;

  TCI_SRCCHARSET = 1;
  TCI_SRCCODEPAGE = 2;
  TCI_SRCFONTSIG = 3;
 
  TMPF_FIXED_PITCH = 1H;
  TMPF_VECTOR = 2H;
  TMPF_DEVICE = 8H;
  TMPF_TRUETYPE = 4H;
  
  NTM_REGULAR = 40H;
  NTM_BOLD = 20H;
  NTM_ITALIC = 1H;
   
  LF_FACESIZE = 32;
  LF_FULLFACESIZE = 64;
 
  OUT_DEFAULT_PRECIS = 0;
  OUT_STRING_PRECIS = 1;
  OUT_CHARACTER_PRECIS = 2;
  OUT_STROKE_PRECIS = 3;
  OUT_TT_PRECIS = 4;
  OUT_DEVICE_PRECIS = 5;
  OUT_RASTER_PRECIS = 6;
  OUT_TT_ONLY_PRECIS = 7;
  OUT_OUTLINE_PRECIS = 8;
  CLIP_DEFAULT_PRECIS = 0;
  CLIP_CHARACTER_PRECIS = 1;
  CLIP_STROKE_PRECIS = 2;
  CLIP_MASK = 0FH;
  CLIP_LH_ANGLES = 16;
  CLIP_TT_ALWAYS = 32;
  CLIP_EMBEDDED = 128;
  DEFAULT_QUALITY = 0;
  DRAFT_QUALITY = 1;
  PROOF_QUALITY = 2;
  NONANTIALIASED_QUALITY = 3;
  ANTIALIASED_QUALITY = 4;
  DEFAULT_PITCH = 0;
  FIXED_PITCH = 1;
  VARIABLE_PITCH = 2;
  MONO_FONT = 8;
  ANSI_CHARSET = 0;
  DEFAULT_CHARSET = 1;
  SYMBOL_CHARSET = 2;
  SHIFTJIS_CHARSET = 128;
  HANGEUL_CHARSET = 129;
  GB2312_CHARSET = 134;
  CHINESEBIG5_CHARSET = 136;
  OEM_CHARSET = 255;
  JOHAB_CHARSET = 130;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  THAI_CHARSET = 222;
  EASTEUROPE_CHARSET = 238;
  RUSSIAN_CHARSET = 204;
  MAC_CHARSET = 77;
  BALTIC_CHARSET = 186;
  FS_LATIN1 = 1H;
  FS_LATIN2 = 2H;
  FS_CYRILLIC = 4H;
  FS_GREEK = 8H;
  FS_TURKISH = 10H;
  FS_HEBREW = 20H;
  FS_ARABIC = 40H;
  FS_BALTIC = 80H;
  FS_THAI = 10000H;
  FS_JISJAPAN = 20000H;
  FS_CHINESESIMP = 40000H;
  FS_WANSUNG = 80000H;
  FS_CHINESETRAD = 100000H;
  FS_JOHAB = 200000H;
  FS_SYMBOL = MIN(LONGINT);

(*  Font Families  *)
  FF_DONTCARE = 0;                     (*  Don't care or don't know.  *)
  FF_ROMAN = 16;                       (*  Variable stroke width, serifed.  *)

(*  Times Roman, Century Schoolbook, etc.  *)
  FF_SWISS = 32;                       (*  Variable stroke width, sans-serifed.  *)

(*  Helvetica, Swiss, etc.  *)
  FF_MODERN = 48;                      (*  Constant stroke width, serifed or sans-serifed.  *)

(*  Pica, Elite, Courier, etc.  *)
  FF_SCRIPT = 64;                      (*  Cursive, etc.  *)
  FF_DECORATIVE = 80;                  (*  Old English, etc.  *)

(*  Font Weights  *)
  FW_DONTCARE = 0;
  FW_THIN = 100;
  FW_EXTRALIGHT = 200;
  FW_ULTRALIGHT = FW_EXTRALIGHT;
  FW_LIGHT = 300;
  FW_NORMAL = 400;
  FW_REGULAR = FW_NORMAL;
  FW_MEDIUM = 500;
  FW_SEMIBOLD = 600;
  FW_DEMIBOLD = FW_SEMIBOLD;
  FW_BOLD = 700;
  FW_EXTRABOLD = 800;
  FW_ULTRABOLD = FW_EXTRABOLD;
  FW_HEAVY = 900;
  FW_BLACK = FW_HEAVY;
  PANOSE_COUNT = 10;
  PAN_FAMILYTYPE_INDEX = 0;
  PAN_SERIFSTYLE_INDEX = 1;
  PAN_WEIGHT_INDEX = 2;
  PAN_PROPORTION_INDEX = 3;
  PAN_CONTRAST_INDEX = 4;
  PAN_STROKEVARIATION_INDEX = 5;
  PAN_ARMSTYLE_INDEX = 6;
  PAN_LETTERFORM_INDEX = 7;
  PAN_MIDLINE_INDEX = 8;
  PAN_XHEIGHT_INDEX = 9;
  PAN_CULTURE_LATIN = 0;
 
  PAN_ANY = 0;                         (*  Any                             *)
  PAN_NO_FIT = 1;                      (*  No Fit                          *)
  PAN_FAMILY_TEXT_DISPLAY = 2;         (*  Text and Display                *)
  PAN_FAMILY_SCRIPT = 3;               (*  Script                          *)
  PAN_FAMILY_DECORATIVE = 4;           (*  Decorative                      *)
  PAN_FAMILY_PICTORIAL = 5;            (*  Pictorial                       *)
  PAN_SERIF_COVE = 2;                  (*  Cove                            *)
  PAN_SERIF_OBTUSE_COVE = 3;           (*  Obtuse Cove                     *)
  PAN_SERIF_SQUARE_COVE = 4;           (*  Square Cove                     *)
  PAN_SERIF_OBTUSE_SQUARE_COVE = 5;    (*  Obtuse Square Cove              *)
  PAN_SERIF_SQUARE = 6;                (*  Square                          *)
  PAN_SERIF_THIN = 7;                  (*  Thin                            *)
  PAN_SERIF_BONE = 8;                  (*  Bone                            *)
  PAN_SERIF_EXAGGERATED = 9;           (*  Exaggerated                     *)
  PAN_SERIF_TRIANGLE = 10;             (*  Triangle                        *)
  PAN_SERIF_NORMAL_SANS = 11;          (*  Normal Sans                     *)
  PAN_SERIF_OBTUSE_SANS = 12;          (*  Obtuse Sans                     *)
  PAN_SERIF_PERP_SANS = 13;            (*  Prep Sans                       *)
  PAN_SERIF_FLARED = 14;               (*  Flared                          *)
  PAN_SERIF_ROUNDED = 15;              (*  Rounded                         *)
  PAN_WEIGHT_VERY_LIGHT = 2;           (*  Very Light                      *)
  PAN_WEIGHT_LIGHT = 3;                (*  Light                           *)
  PAN_WEIGHT_THIN = 4;                 (*  Thin                            *)
  PAN_WEIGHT_BOOK = 5;                 (*  Book                            *)
  PAN_WEIGHT_MEDIUM = 6;               (*  Medium                          *)
  PAN_WEIGHT_DEMI = 7;                 (*  Demi                            *)
  PAN_WEIGHT_BOLD = 8;                 (*  Bold                            *)
  PAN_WEIGHT_HEAVY = 9;                (*  Heavy                           *)
  PAN_WEIGHT_BLACK = 10;               (*  Black                           *)
  PAN_WEIGHT_NORD = 11;                (*  Nord                            *)
  PAN_PROP_OLD_STYLE = 2;              (*  Old Style                       *)
  PAN_PROP_MODERN = 3;                 (*  Modern                          *)
  PAN_PROP_EVEN_WIDTH = 4;             (*  Even Width                      *)
  PAN_PROP_EXPANDED = 5;               (*  Expanded                        *)
  PAN_PROP_CONDENSED = 6;              (*  Condensed                       *)
  PAN_PROP_VERY_EXPANDED = 7;          (*  Very Expanded                   *)
  PAN_PROP_VERY_CONDENSED = 8;         (*  Very Condensed                  *)
  PAN_PROP_MONOSPACED = 9;             (*  Monospaced                      *)
  PAN_CONTRAST_NONE = 2;               (*  None                            *)
  PAN_CONTRAST_VERY_LOW = 3;           (*  Very Low                        *)
  PAN_CONTRAST_LOW = 4;                (*  Low                             *)
  PAN_CONTRAST_MEDIUM_LOW = 5;         (*  Medium Low                      *)
  PAN_CONTRAST_MEDIUM = 6;             (*  Medium                          *)
  PAN_CONTRAST_MEDIUM_HIGH = 7;        (*  Mediim High                     *)
  PAN_CONTRAST_HIGH = 8;               (*  High                            *)
  PAN_CONTRAST_VERY_HIGH = 9;          (*  Very High                       *)
  PAN_STROKE_GRADUAL_DIAG = 2;         (*  Gradual/Diagonal                *)
  PAN_STROKE_GRADUAL_TRAN = 3;         (*  Gradual/Transitional            *)
  PAN_STROKE_GRADUAL_VERT = 4;         (*  Gradual/Vertical                *)
  PAN_STROKE_GRADUAL_HORZ = 5;         (*  Gradual/Horizontal              *)
  PAN_STROKE_RAPID_VERT = 6;           (*  Rapid/Vertical                  *)
  PAN_STROKE_RAPID_HORZ = 7;           (*  Rapid/Horizontal                *)
  PAN_STROKE_INSTANT_VERT = 8;         (*  Instant/Vertical                *)
  PAN_STRAIGHT_ARMS_HORZ = 2;          (*  Straight Arms/Horizontal        *)
  PAN_STRAIGHT_ARMS_WEDGE = 3;         (*  Straight Arms/Wedge             *)
  PAN_STRAIGHT_ARMS_VERT = 4;          (*  Straight Arms/Vertical          *)
  PAN_STRAIGHT_ARMS_SINGLE_SERIF = 5;  (*  Straight Arms/Single-Serif      *)
  PAN_STRAIGHT_ARMS_DOUBLE_SERIF = 6;  (*  Straight Arms/Double-Serif      *)
  PAN_BENT_ARMS_HORZ = 7;              (*  Non-Straight Arms/Horizontal    *)
  PAN_BENT_ARMS_WEDGE = 8;             (*  Non-Straight Arms/Wedge         *)
  PAN_BENT_ARMS_VERT = 9;              (*  Non-Straight Arms/Vertical      *)
  PAN_BENT_ARMS_SINGLE_SERIF = 10;     (*  Non-Straight Arms/Single-Serif  *)
  PAN_BENT_ARMS_DOUBLE_SERIF = 11;     (*  Non-Straight Arms/Double-Serif  *)
  PAN_LETT_NORMAL_CONTACT = 2;         (*  Normal/Contact                  *)
  PAN_LETT_NORMAL_WEIGHTED = 3;        (*  Normal/Weighted                 *)
  PAN_LETT_NORMAL_BOXED = 4;           (*  Normal/Boxed                    *)
  PAN_LETT_NORMAL_FLATTENED = 5;       (*  Normal/Flattened                *)
  PAN_LETT_NORMAL_ROUNDED = 6;         (*  Normal/Rounded                  *)
  PAN_LETT_NORMAL_OFF_CENTER = 7;      (*  Normal/Off Center               *)
  PAN_LETT_NORMAL_SQUARE = 8;          (*  Normal/Square                   *)
  PAN_LETT_OBLIQUE_CONTACT = 9;        (*  Oblique/Contact                 *)
  PAN_LETT_OBLIQUE_WEIGHTED = 10;      (*  Oblique/Weighted                *)
  PAN_LETT_OBLIQUE_BOXED = 11;         (*  Oblique/Boxed                   *)
  PAN_LETT_OBLIQUE_FLATTENED = 12;     (*  Oblique/Flattened               *)
  PAN_LETT_OBLIQUE_ROUNDED = 13;       (*  Oblique/Rounded                 *)
  PAN_LETT_OBLIQUE_OFF_CENTER = 14;    (*  Oblique/Off Center              *)
  PAN_LETT_OBLIQUE_SQUARE = 15;        (*  Oblique/Square                  *)
  PAN_MIDLINE_STANDARD_TRIMMED = 2;    (*  Standard/Trimmed                *)
  PAN_MIDLINE_STANDARD_POINTED = 3;    (*  Standard/Pointed                *)
  PAN_MIDLINE_STANDARD_SERIFED = 4;    (*  Standard/Serifed                *)
  PAN_MIDLINE_HIGH_TRIMMED = 5;        (*  High/Trimmed                    *)
  PAN_MIDLINE_HIGH_POINTED = 6;        (*  High/Pointed                    *)
  PAN_MIDLINE_HIGH_SERIFED = 7;        (*  High/Serifed                    *)
  PAN_MIDLINE_CONSTANT_TRIMMED = 8;    (*  Constant/Trimmed                *)
  PAN_MIDLINE_CONSTANT_POINTED = 9;    (*  Constant/Pointed                *)
  PAN_MIDLINE_CONSTANT_SERIFED = 10;   (*  Constant/Serifed                *)
  PAN_MIDLINE_LOW_TRIMMED = 11;        (*  Low/Trimmed                     *)
  PAN_MIDLINE_LOW_POINTED = 12;        (*  Low/Pointed                     *)
  PAN_MIDLINE_LOW_SERIFED = 13;        (*  Low/Serifed                     *)
  PAN_XHEIGHT_CONSTANT_SMALL = 2;      (*  Constant/Small                  *)
  PAN_XHEIGHT_CONSTANT_STD = 3;        (*  Constant/Standard               *)
  PAN_XHEIGHT_CONSTANT_LARGE = 4;      (*  Constant/Large                  *)
  PAN_XHEIGHT_DUCKING_SMALL = 5;       (*  Ducking/Small                   *)
  PAN_XHEIGHT_DUCKING_STD = 6;         (*  Ducking/Standard                *)
  PAN_XHEIGHT_DUCKING_LARGE = 7;       (*  Ducking/Large                   *)
  ELF_VENDOR_SIZE = 4;
 
  ELF_VERSION = 0;
  ELF_CULTURE_LATIN = 0;

(*  EnumFonts Masks  *)
  RASTER_FONTTYPE = 1H;
  DEVICE_FONTTYPE = 2H;
  TRUETYPE_FONTTYPE = 4H;
(*  palette entry flags  *)
  PC_RESERVED = 1H;                    (*  palette index used for animation  *)
  PC_EXPLICIT = 2H;                    (*  palette index is explicit to device  *)
  PC_NOCOLLAPSE = 4H;                  (*  do not match color to system palette  *)

(*  Background Modes  *)
  TRANSPARENT = 1;
  OPAQUE = 2;
  BKMODE_LAST = 2;

(*  Graphics Modes  *)
  GM_COMPATIBLE = 1;
  GM_ADVANCED = 2;
  GM_LAST = 2;

(*  PolyDraw and GetPath point types  *)
  PT_CLOSEFIGURE = 1H;
  PT_LINETO = 2H;
  PT_BEZIERTO = 4H;
  PT_MOVETO = 6H;

(*  Mapping Modes  *)
  MM_TEXT = 1;
  MM_MIN = MM_TEXT;
  MM_LOMETRIC = 2;
  MM_HIMETRIC = 3;
  MM_LOENGLISH = 4;
  MM_HIENGLISH = 5;
  MM_TWIPS = 6;
  MM_MAX_FIXEDSCALE = MM_TWIPS;
  MM_ISOTROPIC = 7;
  MM_ANISOTROPIC = 8;
  MM_MAX = MM_ANISOTROPIC;

(*  Min and Max Mapping Mode values  *)
(*  Coordinate Modes  *)
  ABSOLUTE = 1;
  RELATIVE = 2;

(*  Stock Logical Objects  *)
  WHITE_BRUSH = 0;
  LTGRAY_BRUSH = 1;
  GRAY_BRUSH = 2;
  DKGRAY_BRUSH = 3;
  BLACK_BRUSH = 4;
  NULL_BRUSH = 5;
  HOLLOW_BRUSH = NULL_BRUSH;
  WHITE_PEN = 6;
  BLACK_PEN = 7;
  NULL_PEN = 8;
  OEM_FIXED_FONT = 10;
  ANSI_FIXED_FONT = 11;
  ANSI_VAR_FONT = 12;
  SYSTEM_FONT = 13;
  DEVICE_DEFAULT_FONT = 14;
  DEFAULT_PALETTE = 15;
  SYSTEM_FIXED_FONT = 16;
  DEFAULT_GUI_FONT = 17;
  STOCK_LAST = 17;
  CLR_INVALID = -1H;

(*  Brush Styles  *)
  BS_SOLID = 0;
  BS_NULL = 1;
  BS_HOLLOW = BS_NULL;
  BS_HATCHED = 2;
  BS_PATTERN = 3;
  BS_INDEXED = 4;
  BS_DIBPATTERN = 5;
  BS_DIBPATTERNPT = 6;
  BS_PATTERN8X8 = 7;
  BS_DIBPATTERN8X8 = 8;

(*  Hatch Styles  *)
  HS_HORIZONTAL = 0;                   (*  -----  *)
  HS_VERTICAL = 1;                     (*  |||||  *)
  HS_FDIAGONAL = 2;                    (*  \\\\\  *)
  HS_BDIAGONAL = 3;                    (*  /////  *)
  HS_CROSS = 4;                        (*  +++++  *)
  HS_DIAGCROSS = 5;                    (*  xxxxx  *)

(*  Pen Styles  *)
  PS_SOLID = 0;
  PS_DASH = 1;                         (*  -------   *)
  PS_DOT = 2;                          (*  .......   *)
  PS_DASHDOT = 3;                      (*  _._._._   *)
  PS_DASHDOTDOT = 4;                   (*  _.._.._   *)
  PS_NULL = 5;
  PS_INSIDEFRAME = 6;
  PS_USERSTYLE = 7;
  PS_ALTERNATE = 8;
  PS_STYLE_MASK = 0FH;
  PS_ENDCAP_ROUND = 0H;
  PS_ENDCAP_SQUARE = 100H;
  PS_ENDCAP_FLAT = 200H;
  PS_ENDCAP_MASK = 0F00H;
  PS_JOIN_ROUND = 0H;
  PS_JOIN_BEVEL = 1000H;
  PS_JOIN_MITER = 2000H;
  PS_JOIN_MASK = 0F000H;
  PS_COSMETIC = 0H;
  PS_GEOMETRIC = 10000H;
  PS_TYPE_MASK = 0F0000H;
  AD_COUNTERCLOCKWISE = 1;
  AD_CLOCKWISE = 2;

(*  Device Parameters for GetDeviceCaps()  *)
  DRIVERVERSION = 0;                   (*  Device driver version                     *)
  TECHNOLOGY = 2;                      (*  Device classification                     *)
  HORZSIZE = 4;                        (*  Horizontal size in millimeters            *)
  VERTSIZE = 6;                        (*  Vertical size in millimeters              *)
  HORZRES = 8;                         (*  Horizontal width in pixels                *)
  VERTRES = 10;                        (*  Vertical height in pixels                 *)
  BITSPIXEL = 12;                      (*  Number of bits per pixel                  *)
  PLANES = 14;                         (*  Number of planes                          *)
  NUMBRUSHES = 16;                     (*  Number of brushes the device has          *)
  NUMPENS = 18;                        (*  Number of pens the device has             *)
  NUMMARKERS = 20;                     (*  Number of markers the device has          *)
  NUMFONTS = 22;                       (*  Number of fonts the device has            *)
  NUMCOLORS = 24;                      (*  Number of colors the device supports      *)
  PDEVICESIZE = 26;                    (*  Size required for device descriptor       *)
  CURVECAPS = 28;                      (*  Curve capabilities                        *)
  LINECAPS = 30;                       (*  Line capabilities                         *)
  POLYGONALCAPS = 32;                  (*  Polygonal capabilities                    *)
  TEXTCAPS = 34;                       (*  Text capabilities                         *)
  CLIPCAPS = 36;                       (*  Clipping capabilities                     *)
  RASTERCAPS = 38;                     (*  Bitblt capabilities                       *)
  ASPECTX = 40;                        (*  Length of the X leg                       *)
  ASPECTY = 42;                        (*  Length of the Y leg                       *)
  ASPECTXY = 44;                       (*  Length of the hypotenuse                  *)
  LOGPIXELSX = 88;                     (*  Logical pixels/inch in X                  *)
  LOGPIXELSY = 90;                     (*  Logical pixels/inch in Y                  *)
  SIZEPALETTE = 104;                   (*  Number of entries in physical palette     *)
  NUMRESERVED = 106;                   (*  Number of reserved entries in palette     *)
  COLORRES = 108;                      (*  Actual color resolution                   *)

(*  Printing related DeviceCaps. These replace the appropriate Escapes *)
  PHYSICALWIDTH = 110;                 (*  Physical Width in device units            *)
  PHYSICALHEIGHT = 111;                (*  Physical Height in device units           *)
  PHYSICALOFFSETX = 112;               (*  Physical Printable Area x margin          *)
  PHYSICALOFFSETY = 113;               (*  Physical Printable Area y margin          *)
  SCALINGFACTORX = 114;                (*  Scaling factor x                          *)
  SCALINGFACTORY = 115;                (*  Scaling factor y                          *)

(*  Display driver specific *)
  VREFRESH = 116;                      (*  Current vertical refresh rate of the     *)

(*  display device (for displays only) in Hz *)
  DESKTOPVERTRES = 117;                (*  Horizontal width of entire desktop in    *)

(*  pixels                                   *)
  DESKTOPHORZRES = 118;                (*  Vertical height of entire desktop in     *)

(*  pixels                                   *)
  BLTALIGNMENT = 119;                  (*  Preferred blt alignment                  *)

(*  Device Capability Masks:  *)
(*  Device Technologies  *)
  DT_PLOTTER = 0;                      (*  Vector plotter                    *)
  DT_RASDISPLAY = 1;                   (*  Raster display                    *)
  DT_RASPRINTER = 2;                   (*  Raster printer                    *)
  DT_RASCAMERA = 3;                    (*  Raster camera                     *)
  DT_CHARSTREAM = 4;                   (*  Character-stream, PLP             *)
  DT_METAFILE = 5;                     (*  Metafile, VDM                     *)
  DT_DISPFILE = 6;                     (*  Display-file                      *)

(*  Curve Capabilities  *)
  CC_NONE = 0;                         (*  Curves not supported              *)
  CC_CIRCLES = 1;                      (*  Can do circles                    *)
  CC_PIE = 2;                          (*  Can do pie wedges                 *)
  CC_CHORD = 4;                        (*  Can do chord arcs                 *)
  CC_ELLIPSES = 8;                     (*  Can do ellipese                   *)
  CC_WIDE = 16;                        (*  Can do wide lines                 *)
  CC_STYLED = 32;                      (*  Can do styled lines               *)
  CC_WIDESTYLED = 64;                  (*  Can do wide styled lines          *)
  CC_INTERIORS = 128;                  (*  Can do interiors                  *)
  CC_ROUNDRECT = 256;                  (*                                    *)

(*  Line Capabilities  *)
  LC_NONE = 0;                         (*  Lines not supported               *)
  LC_POLYLINE = 2;                     (*  Can do polylines                  *)
  LC_MARKER = 4;                       (*  Can do markers                    *)
  LC_POLYMARKER = 8;                   (*  Can do polymarkers                *)
  LC_WIDE = 16;                        (*  Can do wide lines                 *)
  LC_STYLED = 32;                      (*  Can do styled lines               *)
  LC_WIDESTYLED = 64;                  (*  Can do wide styled lines          *)
  LC_INTERIORS = 128;                  (*  Can do interiors                  *)

(*  Polygonal Capabilities  *)
  PC_NONE = 0;                         (*  Polygonals not supported          *)
  PC_POLYGON = 1;                      (*  Can do polygons                   *)
  PC_RECTANGLE = 2;                    (*  Can do rectangles                 *)
  PC_WINDPOLYGON = 4;                  (*  Can do winding polygons           *)
  PC_TRAPEZOID = 4;                    (*  Can do trapezoids                 *)
  PC_SCANLINE = 8;                     (*  Can do scanlines                  *)
  PC_WIDE = 16;                        (*  Can do wide borders               *)
  PC_STYLED = 32;                      (*  Can do styled borders             *)
  PC_WIDESTYLED = 64;                  (*  Can do wide styled borders        *)
  PC_INTERIORS = 128;                  (*  Can do interiors                  *)
  PC_POLYPOLYGON = 256;                (*  Can do polypolygons               *)
  PC_PATHS = 512;                      (*  Can do paths                      *)

(*  Clipping Capabilities  *)
  CP_NONE = 0;                         (*  No clipping of output             *)
  CP_RECTANGLE = 1;                    (*  Output clipped to rects           *)
  CP_REGION = 2;                       (*  obsolete                          *)

(*  Text Capabilities  *)
  TC_OP_CHARACTER = 1H;                (*  Can do OutputPrecision   CHARACTER       *)
  TC_OP_STROKE = 2H;                   (*  Can do OutputPrecision   STROKE          *)
  TC_CP_STROKE = 4H;                   (*  Can do ClipPrecision     STROKE          *)
  TC_CR_90 = 8H;                       (*  Can do CharRotAbility    90              *)
  TC_CR_ANY = 10H;                     (*  Can do CharRotAbility    ANY             *)
  TC_SF_X_YINDEP = 20H;                (*  Can do ScaleFreedom      X_YINDEPENDENT  *)
  TC_SA_DOUBLE = 40H;                  (*  Can do ScaleAbility      DOUBLE          *)
  TC_SA_INTEGER = 80H;                 (*  Can do ScaleAbility      INTEGER         *)
  TC_SA_CONTIN = 100H;                 (*  Can do ScaleAbility      CONTINUOUS      *)
  TC_EA_DOUBLE = 200H;                 (*  Can do EmboldenAbility   DOUBLE          *)
  TC_IA_ABLE = 400H;                   (*  Can do ItalisizeAbility  ABLE            *)
  TC_UA_ABLE = 800H;                   (*  Can do UnderlineAbility  ABLE            *)
  TC_SO_ABLE = 1000H;                  (*  Can do StrikeOutAbility  ABLE            *)
  TC_RA_ABLE = 2000H;                  (*  Can do RasterFontAble    ABLE            *)
  TC_VA_ABLE = 4000H;                  (*  Can do VectorFontAble    ABLE            *)
  TC_RESERVED = 8000H;
  TC_SCROLLBLT = 10000H;               (*  Don't do text scroll with blt            *)

(*  Raster Capabilities  *)
  RC_BITBLT = 1;                       (*  Can do standard BLT.              *)
  RC_BANDING = 2;                      (*  Device requires banding support   *)
  RC_SCALING = 4;                      (*  Device requires scaling support   *)
  RC_BITMAP64 = 8;                     (*  Device can support >64K bitmap    *)
  RC_GDI20_OUTPUT = 10H;               (*  has 2.0 output calls          *)
  RC_GDI20_STATE = 20H;
  RC_SAVEBITMAP = 40H;
  RC_DI_BITMAP = 80H;                  (*  supports DIB to memory        *)
  RC_PALETTE = 100H;                   (*  supports a palette            *)
  RC_DIBTODEV = 200H;                  (*  supports DIBitsToDevice       *)
  RC_BIGFONT = 400H;                   (*  supports >64K fonts           *)
  RC_STRETCHBLT = 800H;                (*  supports StretchBlt           *)
  RC_FLOODFILL = 1000H;                (*  supports FloodFill            *)
  RC_STRETCHDIB = 2000H;               (*  supports StretchDIBits        *)
  RC_OP_DX_OUTPUT = 4000H;
  RC_DEVBITS = 8000H;

(*  DIB color table identifiers  *)
  DIB_RGB_COLORS = 0;                  (*  color table in RGBs  *)
  DIB_PAL_COLORS = 1;                  (*  color table in palette indices  *)

(*  constants for Get/SetSystemPaletteUse()  *)
  SYSPAL_ERROR = 0;
  SYSPAL_STATIC = 1;
  SYSPAL_NOSTATIC = 2;

(*  constants for CreateDIBitmap  *)
  CBM_INIT = 4H;                       (*  initialize bitmap  *)

(*  ExtFloodFill style flags  *)
  FLOODFILLBORDER = 0;
  FLOODFILLSURFACE = 1;

(*  size of a device name string  *)
  CCHDEVICENAME = 32;

(*  size of a form name string  *)
  CCHFORMNAME = 32;
(*  current version of specification  *)
 
  DM_SPECVERSION = 400H;

(*  field selection bits  *)
  DM_ORIENTATION = 1H;
  DM_PAPERSIZE = 2H;
  DM_PAPERLENGTH = 4H;
  DM_PAPERWIDTH = 8H;
  DM_SCALE = 10H;
  DM_COPIES = 100H;
  DM_DEFAULTSOURCE = 200H;
  DM_PRINTQUALITY = 400H;
  DM_COLOR = 800H;
  DM_DUPLEX = 1000H;
  DM_YRESOLUTION = 2000H;
  DM_TTOPTION = 4000H;
  DM_COLLATE = 8000H;
  DM_FORMNAME = 10000H;
  DM_LOGPIXELS = 20000H;
  DM_BITSPERPEL = 40000H;
  DM_PELSWIDTH = 80000H;
  DM_PELSHEIGHT = 100000H;
  DM_DISPLAYFLAGS = 200000H;
  DM_DISPLAYFREQUENCY = 400000H;
  DM_ICMMETHOD = 800000H;
  DM_ICMINTENT = 1000000H;
  DM_MEDIATYPE = 2000000H;
  DM_DITHERTYPE = 4000000H;

(*  orientation selections  *)
  DMORIENT_PORTRAIT = 1;
  DMORIENT_LANDSCAPE = 2;

(*  paper selections  *)
  DMPAPER_LETTER = 1;                  (*  Letter 8 1/2 x 11 in                *)
  DMPAPER_FIRST = DMPAPER_LETTER;
  DMPAPER_LETTERSMALL = 2;             (*  Letter Small 8 1/2 x 11 in          *)
  DMPAPER_TABLOID = 3;                 (*  Tabloid 11 x 17 in                  *)
  DMPAPER_LEDGER = 4;                  (*  Ledger 17 x 11 in                   *)
  DMPAPER_LEGAL = 5;                   (*  Legal 8 1/2 x 14 in                 *)
  DMPAPER_STATEMENT = 6;               (*  Statement 5 1/2 x 8 1/2 in          *)
  DMPAPER_EXECUTIVE = 7;               (*  Executive 7 1/4 x 10 1/2 in         *)
  DMPAPER_A3 = 8;                      (*  A3 297 x 420 mm                     *)
  DMPAPER_A4 = 9;                      (*  A4 210 x 297 mm                     *)
  DMPAPER_A4SMALL = 10;                (*  A4 Small 210 x 297 mm               *)
  DMPAPER_A5 = 11;                     (*  A5 148 x 210 mm                     *)
  DMPAPER_B4 = 12;                     (*  B4 (JIS) 250 x 354                  *)
  DMPAPER_B5 = 13;                     (*  B5 (JIS) 182 x 257 mm               *)
  DMPAPER_FOLIO = 14;                  (*  Folio 8 1/2 x 13 in                 *)
  DMPAPER_QUARTO = 15;                 (*  Quarto 215 x 275 mm                 *)
  DMPAPER_10X14 = 16;                  (*  10x14 in                            *)
  DMPAPER_11X17 = 17;                  (*  11x17 in                            *)
  DMPAPER_NOTE = 18;                   (*  Note 8 1/2 x 11 in                  *)
  DMPAPER_ENV_9 = 19;                  (*  Envelope #9 3 7/8 x 8 7/8           *)
  DMPAPER_ENV_10 = 20;                 (*  Envelope #10 4 1/8 x 9 1/2          *)
  DMPAPER_ENV_11 = 21;                 (*  Envelope #11 4 1/2 x 10 3/8         *)
  DMPAPER_ENV_12 = 22;                 (*  Envelope #12 4 \276 x 11            *)
  DMPAPER_ENV_14 = 23;                 (*  Envelope #14 5 x 11 1/2             *)
  DMPAPER_CSHEET = 24;                 (*  C size sheet                        *)
  DMPAPER_DSHEET = 25;                 (*  D size sheet                        *)
  DMPAPER_ESHEET = 26;                 (*  E size sheet                        *)
  DMPAPER_ENV_DL = 27;                 (*  Envelope DL 110 x 220mm             *)
  DMPAPER_ENV_C5 = 28;                 (*  Envelope C5 162 x 229 mm            *)
  DMPAPER_ENV_C3 = 29;                 (*  Envelope C3  324 x 458 mm           *)
  DMPAPER_ENV_C4 = 30;                 (*  Envelope C4  229 x 324 mm           *)
  DMPAPER_ENV_C6 = 31;                 (*  Envelope C6  114 x 162 mm           *)
  DMPAPER_ENV_C65 = 32;                (*  Envelope C65 114 x 229 mm           *)
  DMPAPER_ENV_B4 = 33;                 (*  Envelope B4  250 x 353 mm           *)
  DMPAPER_ENV_B5 = 34;                 (*  Envelope B5  176 x 250 mm           *)
  DMPAPER_ENV_B6 = 35;                 (*  Envelope B6  176 x 125 mm           *)
  DMPAPER_ENV_ITALY = 36;              (*  Envelope 110 x 230 mm               *)
  DMPAPER_ENV_MONARCH = 37;            (*  Envelope Monarch 3.875 x 7.5 in     *)
  DMPAPER_ENV_PERSONAL = 38;           (*  6 3/4 Envelope 3 5/8 x 6 1/2 in     *)
  DMPAPER_FANFOLD_US = 39;             (*  US Std Fanfold 14 7/8 x 11 in       *)
  DMPAPER_FANFOLD_STD_GERMAN = 40;     (*  German Std Fanfold 8 1/2 x 12 in    *)
  DMPAPER_FANFOLD_LGL_GERMAN = 41;     (*  German Legal Fanfold 8 1/2 x 13 in  *)
  DMPAPER_ISO_B4 = 42;                 (*  B4 (ISO) 250 x 353 mm               *)
  DMPAPER_JAPANESE_POSTCARD = 43;      (*  Japanese Postcard 100 x 148 mm      *)
  DMPAPER_9X11 = 44;                   (*  9 x 11 in                           *)
  DMPAPER_10X11 = 45;                  (*  10 x 11 in                          *)
  DMPAPER_15X11 = 46;                  (*  15 x 11 in                          *)
  DMPAPER_ENV_INVITE = 47;             (*  Envelope Invite 220 x 220 mm        *)
  DMPAPER_RESERVED_48 = 48;            (*  RESERVED--DO NOT USE                *)
  DMPAPER_RESERVED_49 = 49;            (*  RESERVED--DO NOT USE                *)
  DMPAPER_LETTER_EXTRA = 50;           (*  Letter Extra 9 \275 x 12 in         *)
  DMPAPER_LEGAL_EXTRA = 51;            (*  Legal Extra 9 \275 x 15 in          *)
  DMPAPER_TABLOID_EXTRA = 52;          (*  Tabloid Extra 11.69 x 18 in         *)
  DMPAPER_A4_EXTRA = 53;               (*  A4 Extra 9.27 x 12.69 in            *)
  DMPAPER_LETTER_TRANSVERSE = 54;      (*  Letter Transverse 8 \275 x 11 in    *)
  DMPAPER_A4_TRANSVERSE = 55;          (*  A4 Transverse 210 x 297 mm          *)
  DMPAPER_LETTER_EXTRA_TRANSVERSE = 56;(*  Letter Extra Transverse 9\275 x 12 in  *)
  DMPAPER_A_PLUS = 57;                 (*  SuperA/SuperA/A4 227 x 356 mm       *)
  DMPAPER_B_PLUS = 58;                 (*  SuperB/SuperB/A3 305 x 487 mm       *)
  DMPAPER_LETTER_PLUS = 59;            (*  Letter Plus 8.5 x 12.69 in          *)
  DMPAPER_A4_PLUS = 60;                (*  A4 Plus 210 x 330 mm                *)
  DMPAPER_A5_TRANSVERSE = 61;          (*  A5 Transverse 148 x 210 mm          *)
  DMPAPER_B5_TRANSVERSE = 62;          (*  B5 (JIS) Transverse 182 x 257 mm    *)
  DMPAPER_A3_EXTRA = 63;               (*  A3 Extra 322 x 445 mm               *)
  DMPAPER_A5_EXTRA = 64;               (*  A5 Extra 174 x 235 mm               *)
  DMPAPER_B5_EXTRA = 65;               (*  B5 (ISO) Extra 201 x 276 mm         *)
  DMPAPER_A2 = 66;                     (*  A2 420 x 594 mm                     *)
  DMPAPER_A3_TRANSVERSE = 67;          (*  A3 Transverse 297 x 420 mm          *)
  DMPAPER_A3_EXTRA_TRANSVERSE = 68;    (*  A3 Extra Transverse 322 x 445 mm    *)
  DMPAPER_LAST = DMPAPER_A3_EXTRA_TRANSVERSE;
  DMPAPER_USER = 256;

(*  bin selections  *)
  DMBIN_UPPER = 1;
  DMBIN_FIRST = DMBIN_UPPER;
  DMBIN_ONLYONE = 1;
  DMBIN_LOWER = 2;
  DMBIN_MIDDLE = 3;
  DMBIN_MANUAL = 4;
  DMBIN_ENVELOPE = 5;
  DMBIN_ENVMANUAL = 6;
  DMBIN_AUTO = 7;
  DMBIN_TRACTOR = 8;
  DMBIN_SMALLFMT = 9;
  DMBIN_LARGEFMT = 10;
  DMBIN_LARGECAPACITY = 11;
  DMBIN_CASSETTE = 14;
  DMBIN_FORMSOURCE = 15;
  DMBIN_LAST = DMBIN_FORMSOURCE;
  DMBIN_USER = 256;                    (*  device specific bins start here  *)

(*  print qualities  *)
  DMRES_DRAFT = -1;
  DMRES_LOW = -2;
  DMRES_MEDIUM = -3;
  DMRES_HIGH = -4;

(*  color enable/disable for color printers  *)
  DMCOLOR_MONOCHROME = 1;
  DMCOLOR_COLOR = 2;

(*  duplex enable  *)
  DMDUP_SIMPLEX = 1;
  DMDUP_VERTICAL = 2;
  DMDUP_HORIZONTAL = 3;

(*  TrueType options  *)
  DMTT_BITMAP = 1;                     (*  print TT fonts as graphics  *)
  DMTT_DOWNLOAD = 2;                   (*  download TT fonts as soft fonts  *)
  DMTT_SUBDEV = 3;                     (*  substitute device fonts for TT fonts  *)
  DMTT_DOWNLOAD_OUTLINE = 4;           (*  download TT fonts as outline soft fonts  *)

(*  Collation selections  *)
  DMCOLLATE_FALSE = 0;
  DMCOLLATE_TRUE = 1;

(*  DEVMODE dmDisplayFlags flags  
  DM_GRAYSCALE = 1H;
  DM_INTERLACED = 2H;
no longer used VC++4.2*)

(*  ICM methods  *)
  DMICMMETHOD_NONE = 1;                (*  ICM disabled  *)
  DMICMMETHOD_SYSTEM = 2;              (*  ICM handled by system  *)
  DMICMMETHOD_DRIVER = 3;              (*  ICM handled by driver  *)
  DMICMMETHOD_DEVICE = 4;              (*  ICM handled by device  *)
  DMICMMETHOD_USER = 256;              (*  Device-specific methods start here  *)

(*  ICM Intents  *)
  DMICM_SATURATE = 1;                  (*  Maximize color saturation  *)
  DMICM_CONTRAST = 2;                  (*  Maximize color contrast  *)
  DMICM_COLORMETRIC = 3;               (*  Use specific color metric  *)
  DMICM_USER = 256;                    (*  Device-specific intents start here  *)

(*  Media types  *)
  DMMEDIA_STANDARD = 1;                (*  Standard paper  *)
  DMMEDIA_TRANSPARENCY = 2;            (*  Transparency  *)
  DMMEDIA_GLOSSY = 3;                  (*  Glossy paper  *)
  DMMEDIA_USER = 256;                  (*  Device-specific media start here  *)

(*  Dither types  *)
  DMDITHER_NONE = 1;                   (*  No dithering  *)
  DMDITHER_COARSE = 2;                 (*  Dither with a coarse brush  *)
  DMDITHER_FINE = 3;                   (*  Dither with a fine brush  *)
  DMDITHER_LINEART = 4;                (*  LineArt dithering  *)
  DMDITHER_ERRORDIFFUSION = 5;         (*  LineArt dithering  *)
  DMDITHER_RESERVED6 = 6;              (*  LineArt dithering  *)
  DMDITHER_RESERVED7 = 7;              (*  LineArt dithering  *)
  DMDITHER_RESERVED8 = 8;              (*  LineArt dithering  *)
  DMDITHER_RESERVED9 = 9;              (*  LineArt dithering  *)
  DMDITHER_GRAYSCALE = 10;             (*  Device does grayscaling  *)
  DMDITHER_USER = 256;                 (*  Device-specific dithers start here  *)

(*  GetRegionData/ExtCreateRegion  *)
  RDH_RECTANGLES = 1;

(*   GetGlyphOutline constants *)

  GGO_METRICS = 0;
  GGO_BITMAP = 1;
  GGO_NATIVE = 2;
  GGO_GRAY2_BITMAP = 4;
  GGO_GRAY4_BITMAP = 5;
  GGO_GRAY8_BITMAP = 6;
  GGO_GLYPH_INDEX = 80H;
  TT_POLYGON_TYPE = 24;
  TT_PRIM_LINE = 1;
  TT_PRIM_QSPLINE = 2;
 
  GCP_DBCS = 1H;
  GCP_REORDER = 2H;
  GCP_USEKERNING = 8H;
  GCP_GLYPHSHAPE = 10H;
  GCP_LIGATE = 20H;

(* //#define GCP_GLYPHINDEXING  0x0080 *)
  GCP_DIACRITIC = 100H;
  GCP_KASHIDA = 400H;
  GCP_ERROR = 8000H;
  FLI_MASK = 103BH;
  GCP_JUSTIFY = 10000H;

(* //#define GCP_NODIACRITICS   0x00020000L *)
  FLI_GLYPHS = 40000H;
  GCP_CLASSIN = 80000H;
  GCP_MAXEXTENT = 100000H;
  GCP_JUSTIFYIN = 200000H;
  GCP_DISPLAYZWG = 400000H;
  GCP_SYMSWAPOFF = 800000H;
  GCP_NUMERICOVERRIDE = 1000000H;
  GCP_NEUTRALOVERRIDE = 2000000H;
  GCP_NUMERICSLATIN = 4000000H;
  GCP_NUMERICSLOCAL = 8000000H;
  GCPCLASS_LATIN = 1;
  GCPCLASS_HEBREW = 2;
  GCPCLASS_ARABIC = 2;
  GCPCLASS_NEUTRAL = 3;
  GCPCLASS_LOCALNUMBER = 4;
  GCPCLASS_LATINNUMBER = 5;
  GCPCLASS_LATINNUMERICTERMINATOR = 6;
  GCPCLASS_LATINNUMERICSEPARATOR = 7;
  GCPCLASS_NUMERICSEPARATOR = 8;
  GCPCLASS_PREBOUNDLTR = 80H;
  GCPCLASS_PREBOUNDRTL = 40H;
  GCPCLASS_POSTBOUNDLTR = 20H;
  GCPCLASS_POSTBOUNDRTL = 10H;
  GCPGLYPH_LINKBEFORE = 8000H;
  GCPGLYPH_LINKAFTER = 4000H;

(*  pixel types  *)
  PFD_TYPE_RGBA = 0;
  PFD_TYPE_COLORINDEX = 1;

(*  layer types  *)
  PFD_MAIN_PLANE = 0;
  PFD_OVERLAY_PLANE = 1;
  PFD_UNDERLAY_PLANE = -1;

(*  PIXELFORMATDESCRIPTOR flags  *)
  PFD_DOUBLEBUFFER = 1H;
  PFD_STEREO = 2H;
  PFD_DRAW_TO_WINDOW = 4H;
  PFD_DRAW_TO_BITMAP = 8H;
  PFD_SUPPORT_GDI = 10H;
  PFD_SUPPORT_OPENGL = 20H;
  PFD_GENERIC_FORMAT = 40H;
  PFD_NEED_PALETTE = 80H;
  PFD_NEED_SYSTEM_PALETTE = 100H;
  PFD_SWAP_EXCHANGE = 200H;
  PFD_SWAP_COPY = 400H;

(*  bits defined in wFlags of RASTERIZER_STATUS  *)
  TT_AVAILABLE = 1H;
  TT_ENABLED = 2H;

(*  PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only  *)
  PFD_DOUBLEBUFFER_DONTCARE = 40000000H;
  PFD_STEREO_DONTCARE = MIN(LONGINT);

(*  mode selections for the device mode function  *)
  DM_UPDATE = 1;
  DM_OUT_DEFAULT = DM_UPDATE;
  DM_COPY = 2;
  DM_OUT_BUFFER = DM_COPY;
  DM_PROMPT = 4;
  DM_IN_PROMPT = DM_PROMPT;
  DM_MODIFY = 8;
  DM_IN_BUFFER = DM_MODIFY;

(*  device capabilities indices  *)
  DC_FIELDS = 1;
  DC_PAPERS = 2;
  DC_PAPERSIZE = 3;
  DC_MINEXTENT = 4;
  DC_MAXEXTENT = 5;
  DC_BINS = 6;
  DC_DUPLEX = 7;
  DC_SIZE = 8;
  DC_EXTRA = 9;
  DC_VERSION = 10;
  DC_DRIVER = 11;
  DC_BINNAMES = 12;
  DC_ENUMRESOLUTIONS = 13;
  DC_FILEDEPENDENCIES = 14;
  DC_TRUETYPE = 15;
  DC_PAPERNAMES = 16;
  DC_ORIENTATION = 17;
  DC_COPIES = 18;
  DC_BINADJUST = 19;
  DC_EMF_COMPLIANT = 20;
  DC_DATATYPE_PRODUCED = 21;
  DC_MANUFACTURER = 23;
  DC_MODEL = 24;

(*  bit fields of the return value (DWORD) for DC_TRUETYPE  *)
  DCTT_BITMAP = 1H;
  DCTT_DOWNLOAD = 2H;
  DCTT_SUBDEV = 4H;
  DCTT_DOWNLOAD_OUTLINE = 8H;

(*  return values for DC_BINADJUST  *)
  DCBA_FACEUPNONE = 0H;
  DCBA_FACEUPCENTER = 1H;
  DCBA_FACEUPLEFT = 2H;
  DCBA_FACEUPRIGHT = 3H;
  DCBA_FACEDOWNNONE = 100H;
  DCBA_FACEDOWNCENTER = 101H;
  DCBA_FACEDOWNLEFT = 102H;
  DCBA_FACEDOWNRIGHT = 103H;
 
  CA_NEGATIVE = 1H;
  CA_LOG_FILTER = 2H;

(*  IlluminantIndex values  *)
  ILLUMINANT_DEVICE_DEFAULT = 0;
  ILLUMINANT_A = 1;
  ILLUMINANT_TUNGSTEN = ILLUMINANT_A;
  ILLUMINANT_B = 2;
  ILLUMINANT_C = 3;
  ILLUMINANT_NTSC = ILLUMINANT_C;
  ILLUMINANT_DAYLIGHT = ILLUMINANT_C;
  ILLUMINANT_D50 = 4;
  ILLUMINANT_D55 = 5;
  ILLUMINANT_D65 = 6;
  ILLUMINANT_D75 = 7;
  ILLUMINANT_F2 = 8;
  ILLUMINANT_MAX_INDEX = ILLUMINANT_F2;
  ILLUMINANT_FLUORESCENT = ILLUMINANT_F2;

(*  Min and max for RedGamma, GreenGamma, BlueGamma  *)
  RGB_GAMMA_MIN = 1344;
  RGB_GAMMA_MAX = 65000;

(*  Min and max for ReferenceBlack and ReferenceWhite  *)
  REFERENCE_WHITE_MIN = 6000;
  REFERENCE_WHITE_MAX = 10000;
  REFERENCE_BLACK_MIN = 0;
  REFERENCE_BLACK_MAX = 4000;

(*  Min and max for Contrast, Brightness, Colorfulness, RedGreenTint  *)
  COLOR_ADJ_MIN = -100;
  COLOR_ADJ_MAX = 100;

  DI_APPBANDING = 1H;
 
  FONTMAPPER_MAX = 10;
 

  ICM_OFF = 1;
  ICM_ON = 2;
  ICM_QUERY = 3;
 
  ENHMETA_SIGNATURE = 464D4520H;

(*  Stock object flag used in the object handle index in the enhanced *)
(*  metafile records. *)
(*  E.g. The object handle index (META_STOCK_OBJECT | BLACK_BRUSH) *)
(*  represents the stock object BLACK_BRUSH. *)
  ENHMETA_STOCK_OBJECT = MIN(LONGINT);

(*  Enhanced metafile record types. *)
  EMR_HEADER = 1;
  EMR_POLYBEZIER = 2;
  EMR_POLYGON = 3;
  EMR_POLYLINE = 4;
  EMR_POLYBEZIERTO = 5;
  EMR_POLYLINETO = 6;
  EMR_POLYPOLYLINE = 7;
  EMR_POLYPOLYGON = 8;
  EMR_SETWINDOWEXTEX = 9;
  EMR_SETWINDOWORGEX = 10;
  EMR_SETVIEWPORTEXTEX = 11;
  EMR_SETVIEWPORTORGEX = 12;
  EMR_SETBRUSHORGEX = 13;
  EMR_EOF = 14;
  EMR_SETPIXELV = 15;
  EMR_SETMAPPERFLAGS = 16;
  EMR_SETMAPMODE = 17;
  EMR_SETBKMODE = 18;
  EMR_SETPOLYFILLMODE = 19;
  EMR_SETROP2 = 20;
  EMR_SETSTRETCHBLTMODE = 21;
  EMR_SETTEXTALIGN = 22;
  EMR_SETCOLORADJUSTMENT = 23;
  EMR_SETTEXTCOLOR = 24;
  EMR_SETBKCOLOR = 25;
  EMR_OFFSETCLIPRGN = 26;
  EMR_MOVETOEX = 27;
  EMR_SETMETARGN = 28;
  EMR_EXCLUDECLIPRECT = 29;
  EMR_INTERSECTCLIPRECT = 30;
  EMR_SCALEVIEWPORTEXTEX = 31;
  EMR_SCALEWINDOWEXTEX = 32;
  EMR_SAVEDC = 33;
  EMR_RESTOREDC = 34;
  EMR_SETWORLDTRANSFORM = 35;
  EMR_MODIFYWORLDTRANSFORM = 36;
  EMR_SELECTOBJECT = 37;
  EMR_CREATEPEN = 38;
  EMR_CREATEBRUSHINDIRECT = 39;
  EMR_DELETEOBJECT = 40;
  EMR_ANGLEARC = 41;
  EMR_ELLIPSE = 42;
  EMR_RECTANGLE = 43;
  EMR_ROUNDRECT = 44;
  EMR_ARC = 45;
  EMR_CHORD = 46;
  EMR_PIE = 47;
  EMR_SELECTPALETTE = 48;
  EMR_CREATEPALETTE = 49;
  EMR_SETPALETTEENTRIES = 50;
  EMR_RESIZEPALETTE = 51;
  EMR_REALIZEPALETTE = 52;
  EMR_EXTFLOODFILL = 53;
  EMR_LINETO = 54;
  EMR_ARCTO = 55;
  EMR_POLYDRAW = 56;
  EMR_SETARCDIRECTION = 57;
  EMR_SETMITERLIMIT = 58;
  EMR_BEGINPATH = 59;
  EMR_ENDPATH = 60;
  EMR_CLOSEFIGURE = 61;
  EMR_FILLPATH = 62;
  EMR_STROKEANDFILLPATH = 63;
  EMR_STROKEPATH = 64;
  EMR_FLATTENPATH = 65;
  EMR_WIDENPATH = 66;
  EMR_SELECTCLIPPATH = 67;
  EMR_ABORTPATH = 68;
  EMR_GDICOMMENT = 70;
  EMR_FILLRGN = 71;
  EMR_FRAMERGN = 72;
  EMR_INVERTRGN = 73;
  EMR_PAINTRGN = 74;
  EMR_EXTSELECTCLIPRGN = 75;
  EMR_BITBLT = 76;
  EMR_STRETCHBLT = 77;
  EMR_MASKBLT = 78;
  EMR_PLGBLT = 79;
  EMR_SETDIBITSTODEVICE = 80;
  EMR_STRETCHDIBITS = 81;
  EMR_EXTCREATEFONTINDIRECTW = 82;
  EMR_EXTTEXTOUTA = 83;
  EMR_EXTTEXTOUTW = 84;
  EMR_POLYBEZIER16 = 85;
  EMR_POLYGON16 = 86;
  EMR_POLYLINE16 = 87;
  EMR_POLYBEZIERTO16 = 88;
  EMR_POLYLINETO16 = 89;
  EMR_POLYPOLYLINE16 = 90;
  EMR_POLYPOLYGON16 = 91;
  EMR_POLYDRAW16 = 92;
  EMR_CREATEMONOBRUSH = 93;
  EMR_CREATEDIBPATTERNBRUSHPT = 94;
  EMR_EXTCREATEPEN = 95;
  EMR_POLYTEXTOUTA = 96;
  EMR_POLYTEXTOUTW = 97;
  EMR_SETICMMODE = 98;
  EMR_CREATECOLORSPACE = 99;
  EMR_SETCOLORSPACE = 100;
  EMR_DELETECOLORSPACE = 101;
  EMR_MIN = 1;
  EMR_MAX = 101;

ETO_IGNORELANGUAGE  = 1000H;
VIETNAMESE_CHARSET  = 163;
FS_VIETNAMESE       = 00000100;
BS_MONOPATTERN      = 9;
(*DM_SPECVERSION = 0401H;*)


DM_PANNINGWIDTH    = 00800000H;
DM_PANNINGHEIGHT   = 01000000H;
(*DM_ICMMETHOD       = 02000000H;*)
(*DM_ICMINTENT       = 04000000H;*)
(*DM_MEDIATYPE       = 08000000H;*)
(*DM_DITHERTYPE      = 10000000H;*)
DM_ICCMANUFACTURER = 20000000H;
DM_ICCMODEL        = 40000000H;

(*DM_GRAYSCALE    = 00000001H;  This flag is no longer valid *)
(*DM_INTERLACED   = 00000002H;  This flag is no longer valid *)
DMDISPLAYFLAGS_TEXTMODE =00000004H;
(* PFD_SWAP_COPY = ???;         *)
 PFD_SWAP_LAYER_BUFFERS   = 00000800H;
 PFD_GENERIC_ACCELERATED  = 00001000H;

 PFD_DEPTH_DONTCARE         = 20000000H;
(* PFD_DOUBLEBUFFER_DONTCARE   = 40000000H;*)
(* EMR_DELETECOLORSPACE         =  101;*)
 EMR_GLSRECORD                =  102;
 EMR_GLSBOUNDEDRECORD         =  103;
 EMR_PIXELFORMAT              =  104;
(* EMR_MAX                      =  104;*)
(* DC_DATATYPE_PRODUCED  =  21;*)
(* DC_MANUFACTURER       =  23;*)
(* DC_MODEL              =  24;*)
(* DC_DATATYPE_PRODUCED   = 21;*)
 DC_COLLATE             = 22;

(* LAYERPLANEDESCRIPTOR flags *)
 LPD_DOUBLEBUFFER        = 00000001H;
 LPD_STEREO              = 00000002H;
 LPD_SUPPORT_GDI         = 00000010H;
 LPD_SUPPORT_OPENGL      = 00000020H;
 LPD_SHARE_DEPTH         = 00000040H;
 LPD_SHARE_STENCIL       = 00000080H;
 LPD_SHARE_ACCUM         = 00000100H;
 LPD_SWAP_EXCHANGE       = 00000200H;
 LPD_SWAP_COPY           = 00000400H;
 LPD_TRANSPARENT         = 00001000H;

 LPD_TYPE_RGBA     =   0;
 LPD_TYPE_COLORINDEX = 1;

(* wglSwapLayerBuffers flags *)
 WGL_SWAP_MAIN_PLANE     = 00000001H;
 WGL_SWAP_OVERLAY1       = 00000002H;
 WGL_SWAP_OVERLAY2       = 00000004H;
 WGL_SWAP_OVERLAY3       = 00000008H;
 WGL_SWAP_OVERLAY4       = 00000010H;
 WGL_SWAP_OVERLAY5       = 00000020H;
 WGL_SWAP_OVERLAY6       = 00000040H;
 WGL_SWAP_OVERLAY7       = 00000080H;
 WGL_SWAP_OVERLAY8       = 00000100H;
 WGL_SWAP_OVERLAY9       = 00000200H;
 WGL_SWAP_OVERLAY10      = 00000400H;
 WGL_SWAP_OVERLAY11      = 00000800H;
 WGL_SWAP_OVERLAY12      = 00001000H;
 WGL_SWAP_OVERLAY13      = 00002000H;
 WGL_SWAP_OVERLAY14      = 00004000H;
 WGL_SWAP_OVERLAY15      = 00008000H;
 WGL_SWAP_UNDERLAY1      = 00010000H;
 WGL_SWAP_UNDERLAY2      = 00020000H;
 WGL_SWAP_UNDERLAY3      = 00040000H;
 WGL_SWAP_UNDERLAY4      = 00080000H;
 WGL_SWAP_UNDERLAY5      = 00100000H;
 WGL_SWAP_UNDERLAY6      = 00200000H;
 WGL_SWAP_UNDERLAY7      = 00400000H;
 WGL_SWAP_UNDERLAY8      = 00800000H;
 WGL_SWAP_UNDERLAY9      = 01000000H;
 WGL_SWAP_UNDERLAY10     = 02000000H;
 WGL_SWAP_UNDERLAY11     = 04000000H;
 WGL_SWAP_UNDERLAY12     = 08000000H;
 WGL_SWAP_UNDERLAY13     = 10000000H;
 WGL_SWAP_UNDERLAY14     = 20000000H;
 WGL_SWAP_UNDERLAY15     = 40000000H;
 
 GDICOMMENT_IDENTIFIER = 43494447H;
 GDICOMMENT_WINDOWS_METAFILE = -7FFFFFFFH;
 GDICOMMENT_BEGINGROUP = 2H;
 GDICOMMENT_ENDGROUP = 3H;
 GDICOMMENT_MULTIFORMATS = 40000004H;
 EPS_SIGNATURE = 46535045H;
 
 WGL_FONT_LINES = 0;
 WGL_FONT_POLYGONS = 1;


(*  Binary raster ops  *)


(* MACROS
<* IF __GEN_C__ THEN *>

(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] / MAKEROP4 ( fore, back: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEROP4 ( fore, back: ARRAY OF SYSTEM.BYTE );
<* END *>
*)

TYPE 

  
  XFORM = RECORD [_NOTALIGNED]
    eM11: REAL;
    eM12: REAL;
    eM21: REAL;
    eM22: REAL;
    eDx : REAL;
    eDy : REAL;
  END;

  PXFORM = POINTER TO XFORM;
  LPXFORM = POINTER TO XFORM;

(*  Bitmap Header Definition  *)

  BITMAP = RECORD [_NOTALIGNED]
    bmType      : LONGINT;
    bmWidth     : LONGINT;
    bmHeight    : LONGINT;
    bmWidthBytes: LONGINT;
    bmPlanes    : WD.WORD;
    bmBitsPixel : WD.WORD;
    bmBits      : WD.LPVOID;
  END;

  PBITMAP = POINTER TO BITMAP;
  NPBITMAP = POINTER TO BITMAP;
  LPBITMAP = POINTER TO BITMAP;

(* #include <pshpack1.h> *)

  RGBTRIPLE = RECORD [_NOTALIGNED]
    rgbtBlue : WD.BYTE;
    rgbtGreen: WD.BYTE;
    rgbtRed  : WD.BYTE;
  END;

(* #include <poppack.h> *)

  RGBQUAD = RECORD [_NOTALIGNED]
    rgbBlue    : WD.BYTE;
    rgbGreen   : WD.BYTE;
    rgbRed     : WD.BYTE;
    rgbReserved: WD.BYTE;
  END;

  LPRGBQUAD = POINTER TO RGBQUAD;

(*  Image Color Matching color definitions  *)

  LCSCSTYPE = LONGINT;
  LCSGAMUTMATCH = LONGINT;


(*  Macros to retrieve CMYK values from a WD.COLORREF  

<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetCValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetCValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetMValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetMValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetYValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetYValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetKValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetKValue ( cmyk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CMYK ( c, m, y, k: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CMYK ( c, m, y, k: ARRAY OF SYSTEM.BYTE );
<* END *>
*)
 
  FXPT16DOT16 = LONGINT;
  LPFXPT16DOT16 = WD.LP;
  FXPT2DOT30 = LONGINT;
  LPFXPT2DOT30 = WD.LP;

(*  ICM Color Definitions  *)
(*  The following two structures are used for defining RGB's in terms of *)
(*  CIEXYZ. The values are fixed point 16.16. *)

  CIEXYZ = RECORD [_NOTALIGNED]
    ciexyzX: FXPT2DOT30;
    ciexyzY: FXPT2DOT30;
    ciexyzZ: FXPT2DOT30;
  END;

  LPCIEXYZ = POINTER TO CIEXYZ;

  CIEXYZTRIPLE = RECORD [_NOTALIGNED]
    ciexyzRed  : CIEXYZ;
    ciexyzGreen: CIEXYZ;
    ciexyzBlue : CIEXYZ;
  END;

  LPCIEXYZTRIPLE = POINTER TO CIEXYZTRIPLE;

(*  The next structures the logical color space. Unlike pens and brushes, *)
(*  but like palettes, there is only one way to create a LogColorSpace. *)
(*  A pointer to it must be passed, its elements can't be pushed as *)
(*  arguments. *)

  LOGCOLORSPACEA = RECORD [_NOTALIGNED]
    lcsSignature : WD.DWORD;
    lcsVersion   : WD.DWORD;
    lcsSize      : WD.DWORD;
    lcsCSType    : LCSCSTYPE;
    lcsIntent    : LCSGAMUTMATCH;
    lcsEndpoints : CIEXYZTRIPLE;
    lcsGammaRed  : WD.DWORD;
    lcsGammaGreen: WD.DWORD;
    lcsGammaBlue : WD.DWORD;
    lcsFilename  : ARRAY WD.MAX_PATH OF CHAR;
  END;

  LPLOGCOLORSPACEA = POINTER TO LOGCOLORSPACEA;

 

  LOGCOLORSPACEW = RECORD [_NOTALIGNED]
    lcsSignature : WD.DWORD;
    lcsVersion   : WD.DWORD;
    lcsSize      : WD.DWORD;
    lcsCSType    : LCSCSTYPE;
    lcsIntent    : LCSGAMUTMATCH;
    lcsEndpoints : CIEXYZTRIPLE;
    lcsGammaRed  : WD.DWORD;
    lcsGammaGreen: WD.DWORD;
    lcsGammaBlue : WD.DWORD;
    lcsFilename  : ARRAY WD.MAX_PATH OF CHAR;
  END;
  
  LPLOGCOLORSPACEW = POINTER TO LOGCOLORSPACEW;

  LOGCOLORSPACE = LOGCOLORSPACEA;   (* ! A *)
  LPLOGCOLORSPACE = LPLOGCOLORSPACEA;  (* ! A *)

(*  structures for defining DIBs  *)
  BITMAPCOREHEADER = RECORD [_NOTALIGNED]
    bcSize    : WD.DWORD;   (*  used to get to color table  *)
    bcWidth   : WD.WORD;
    bcHeight  : WD.WORD;
    bcPlanes  : WD.WORD;
    bcBitCount: WD.WORD;
  END;

  LPBITMAPCOREHEADER = POINTER TO BITMAPCOREHEADER;
  PBITMAPCOREHEADER = POINTER TO BITMAPCOREHEADER;

  BITMAPINFOHEADER = RECORD [_NOTALIGNED]
    biSize         : WD.DWORD;
    biWidth        : LONGINT;
    biHeight       : LONGINT;
    biPlanes       : WD.WORD;
    biBitCount     : WD.WORD;
    biCompression  : WD.DWORD;
    biSizeImage    : WD.DWORD;
    biXPelsPerMeter: LONGINT;
    biYPelsPerMeter: LONGINT;
    biClrUsed      : WD.DWORD;
    biClrImportant : WD.DWORD;
  END;

  LPBITMAPINFOHEADER = POINTER TO BITMAPINFOHEADER;
  PBITMAPINFOHEADER = POINTER TO BITMAPINFOHEADER;

  BITMAPV4HEADER = RECORD [_NOTALIGNED]
    bV4Size         : WD.DWORD;
    bV4Width        : LONGINT;
    bV4Height       : LONGINT;
    bV4Planes       : WD.WORD;
    bV4BitCount     : WD.WORD;
    bV4V4Compression: WD.DWORD;
    bV4SizeImage    : WD.DWORD;
    bV4XPelsPerMeter: LONGINT;
    bV4YPelsPerMeter: LONGINT;
    bV4ClrUsed      : WD.DWORD;
    bV4ClrImportant : WD.DWORD;
    bV4RedMask      : WD.DWORD;
    bV4GreenMask    : WD.DWORD;
    bV4BlueMask     : WD.DWORD;
    bV4AlphaMask    : WD.DWORD;
    bV4CSType       : WD.DWORD;
    bV4Endpoints    : CIEXYZTRIPLE;
    bV4GammaRed     : WD.DWORD;
    bV4GammaGreen   : WD.DWORD;
    bV4GammaBlue    : WD.DWORD;
  END;

  LPBITMAPV4HEADER = POINTER TO BITMAPV4HEADER;
  PBITMAPV4HEADER = POINTER TO BITMAPV4HEADER;


 
  BITMAPINFO = RECORD [_NOTALIGNED]
    bmiHeader: BITMAPINFOHEADER;
  END;

  BITMAPINFO2 = RECORD [_NOTALIGNED] (BITMAPINFO)
    bmiColors: ARRAY 2 OF RGBQUAD;
  END;

  BITMAPINFO16 = RECORD [_NOTALIGNED] (BITMAPINFO)
    bmiColors: ARRAY 16 OF RGBQUAD;
  END;

  BITMAPINFO256 = RECORD [_NOTALIGNED] (BITMAPINFO)
    bmiColors: ARRAY 256 OF RGBQUAD;
  END;


  LPBITMAPINFO = POINTER TO BITMAPINFO;
  PBITMAPINFO = POINTER TO BITMAPINFO;

  BITMAPCOREINFO = RECORD [_NOTALIGNED]
    bmciHeader: BITMAPCOREHEADER;
    bmciColors: LONGINT  (*ARRAY [1] OF RGBTRIPLE;*)
  END;

  LPBITMAPCOREINFO = POINTER TO BITMAPCOREINFO;
  PBITMAPCOREINFO = POINTER TO BITMAPCOREINFO;

(* #include <pshpack2.h>    *)

  BITMAPFILEHEADER = RECORD [_NOTALIGNED]
    bfType     : WD.WORD;
    bfSize     : WD.DWORD;
    bfReserved1: WD.WORD;
    bfReserved2: WD.WORD;
    bfOffBits  : WD.DWORD;
  END;

  LPBITMAPFILEHEADER = POINTER TO BITMAPFILEHEADER;
  PBITMAPFILEHEADER = POINTER TO BITMAPFILEHEADER;

(* #include <poppack.h>   *)

(* Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEPOINTS ( l: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEPOINTS ( l: ARRAY OF SYSTEM.BYTE );
<* END *>
*)
 
  FONTSIGNATURE = RECORD [_NOTALIGNED]
    fsUsb: ARRAY 4 OF WD.DWORD;
    fsCsb: ARRAY 2 OF WD.DWORD;
  END;

  PFONTSIGNATURE = POINTER TO FONTSIGNATURE;
  LPFONTSIGNATURE = POINTER TO FONTSIGNATURE;

  CHARSETINFO = RECORD [_NOTALIGNED]
    ciCharset: WD.UINT;
    ciACP    : WD.UINT;
    fs       : FONTSIGNATURE;
  END;

  PCHARSETINFO = POINTER TO CHARSETINFO;
  NPCHARSETINFO = POINTER TO CHARSETINFO;
  LPCHARSETINFO = POINTER TO CHARSETINFO;

  LOCALESIGNATURE = RECORD [_NOTALIGNED]
    lsUsb         : ARRAY 4 OF WD.DWORD;
    lsCsbDefault  : ARRAY 2 OF WD.DWORD;
    lsCsbSupported: ARRAY 2 OF WD.DWORD;
  END;

  PLOCALESIGNATURE = POINTER TO LOCALESIGNATURE;
  LPLOCALESIGNATURE = POINTER TO LOCALESIGNATURE;

(*  Clipboard Metafile Picture Structure  *)

  HANDLETABLE = RECORD [_NOTALIGNED]
    objectHandle: LONGINT;  (*ARRAY [1] OF WD.HGDIOBJ;*)
  END;

  PHANDLETABLE = POINTER TO HANDLETABLE;
  LPHANDLETABLE = POINTER TO HANDLETABLE;

  METARECORD = RECORD [_NOTALIGNED]
    rdSize    : WD.DWORD;
    rdFunction: WD.WORD;
    rdParm    : LONGINT;  (*ARRAY [1] OF WD.WORD;*)
  END;

  PMETARECORD = POINTER TO METARECORD;
  LPMETARECORD = POINTER TO METARECORD;

 METAFILEPICT = RECORD [_NOTALIGNED]
    mm  : LONGINT;
    xExt: LONGINT;
    yExt: LONGINT;
    hMF : WD.HMETAFILE;
  END;

  LPMETAFILEPICT = POINTER TO METAFILEPICT;

(* #include <pshpack2.h>    *)

  METAHEADER = RECORD [_NOTALIGNED]
    mtType        : WD.WORD;
    mtHeaderSize  : WD.WORD;
    mtVersion     : WD.WORD;
    mtSize        : WD.DWORD;
    mtNoObjects   : WD.WORD;
    mtMaxRecord   : WD.DWORD;
    mtNoParameters: WD.WORD;
  END;

  PMETAHEADER = POINTER TO METAHEADER;
  LPMETAHEADER = POINTER TO METAHEADER;

(* #include <poppack.h>  *)
(*  Enhanced Metafile structures  *)

  ENHMETARECORD = RECORD [_NOTALIGNED]
    iType: WD.DWORD;                     (*  Record type EMR_XXX *)
    nSize: WD.DWORD;                     (*  Record size in bytes *)
    dParm: LONGINT; (*ARRAY [1] OF WD.DWORD;*)   (*  Parameters *)
  END;

  PENHMETARECORD = POINTER TO ENHMETARECORD;

  LPENHMETARECORD = POINTER TO ENHMETARECORD;

  ENHMETAHEADER = RECORD [_NOTALIGNED]
    iType         : WD.DWORD;   (*  Record type EMR_HEADER *)
    nSize         : WD.DWORD;   (*  Record size in bytes.  This may be greater *)
 
(*  than the sizeof(ENHMETAHEADER). *)
    rclBounds     : WD.RECTL;   (*  Inclusive-inclusive bounds in device units *)
    rclFrame      : WD.RECTL;   (*  Inclusive-inclusive Picture Frame of metafile in .01 mm units *)
    dSignature    : WD.DWORD;   (*  Signature.  Must be ENHMETA_SIGNATURE. *)
    nVersion      : WD.DWORD;   (*  Version number *)
    nBytes        : WD.DWORD;   (*  Size of the metafile in bytes *)
    nRecords      : WD.DWORD;   (*  Number of records in the metafile *)
    nHandles      : WD.WORD;    (*  Number of handles in the handle table *)
 
(*  Handle index zero is reserved. *)
    sReserved     : WD.WORD;    (*  Reserved.  Must be zero. *)
    nDescription  : WD.DWORD;   (*  Number of chars in the unicode description string *)
 
(*  This is 0 if there is no description string *)
    offDescription: WD.DWORD;   (*  Offset to the metafile description record. *)
 
(*  This is 0 if there is no description string *)
    nPalEntries   : WD.DWORD;   (*  Number of entries in the metafile palette. *)
    szlDevice     : WD.SIZEL;   (*  Size of the reference device in pels *)
    szlMillimeters: WD.SIZEL;   (*  Size of the reference device in millimeters *)
    cbPixelFormat: WD.DWORD;       (* Size of PIXELFORMATDESCRIPTOR information
                                   This is 0 if no pixel format is set*)
    offPixelFormat: WD.DWORD;      (* Offset to PIXELFORMATDESCRIPTOR
                                 This is 0 if no pixel format is set*)
    bOpenGL: WD.DWORD;             (* TRUE if OpenGL commands are present in
                                 the metafile, otherwise FALSE*)
  END;

  PENHMETAHEADER = POINTER TO ENHMETAHEADER;
  LPENHMETAHEADER = POINTER TO ENHMETAHEADER;

(*  tmPitchAndFamily flags  *)



(*  BCHAR definition for APPs *)
 
  BCHAR = CHAR;

  TEXTMETRICA = RECORD [_NOTALIGNED]
    tmHeight          : LONGINT;
    tmAscent          : LONGINT;
    tmDescent         : LONGINT;
    tmInternalLeading : LONGINT;
    tmExternalLeading : LONGINT;
    tmAveCharWidth    : LONGINT;
    tmMaxCharWidth    : LONGINT;
    tmWeight          : LONGINT;
    tmOverhang        : LONGINT;
    tmDigitizedAspectX: LONGINT;
    tmDigitizedAspectY: LONGINT;
    tmFirstChar       : WD.BYTE;
    tmLastChar        : WD.BYTE;
    tmDefaultChar     : WD.BYTE;
    tmBreakChar       : WD.BYTE;
    tmItalic          : WD.BYTE;
    tmUnderlined      : WD.BYTE;
    tmStruckOut       : WD.BYTE;
    tmPitchAndFamily  : WD.BYTE;
    tmCharSet         : WD.BYTE;
  END;

  PTEXTMETRICA = POINTER TO TEXTMETRICA;
  NPTEXTMETRICA = POINTER TO TEXTMETRICA;
  LPTEXTMETRICA = POINTER TO TEXTMETRICA;

  TEXTMETRICW = RECORD [_NOTALIGNED]
    tmHeight          : LONGINT;
    tmAscent          : LONGINT;
    tmDescent         : LONGINT;
    tmInternalLeading : LONGINT;
    tmExternalLeading : LONGINT;
    tmAveCharWidth    : LONGINT;
    tmMaxCharWidth    : LONGINT;
    tmWeight          : LONGINT;
    tmOverhang        : LONGINT;
    tmDigitizedAspectX: LONGINT;
    tmDigitizedAspectY: LONGINT;
    tmFirstChar       : WD.WCHAR;
    tmLastChar        : WD.WCHAR;
    tmDefaultChar     : WD.WCHAR;
    tmBreakChar       : WD.WCHAR;
    tmItalic          : WD.BYTE;
    tmUnderlined      : WD.BYTE;
    tmStruckOut       : WD.BYTE;
    tmPitchAndFamily  : WD.BYTE;
    tmCharSet         : WD.BYTE;
  END;

  PTEXTMETRICW = POINTER TO TEXTMETRICW;
  NPTEXTMETRICW = POINTER TO TEXTMETRICW;
  LPTEXTMETRICW = POINTER TO TEXTMETRICW;

  TEXTMETRIC = TEXTMETRICA;   (* ! A *)
  PTEXTMETRIC = PTEXTMETRICA;  (* ! A *)
  NPTEXTMETRIC = NPTEXTMETRICA;  (* ! A *)
  LPTEXTMETRIC = LPTEXTMETRICA;  (* ! A *)

(*  ntmFlags field flags  *)


(* #include <pshpack4.h> *)

  NEWTEXTMETRICA = RECORD [_NOTALIGNED]
    tmHeight          : LONGINT;
    tmAscent          : LONGINT;
    tmDescent         : LONGINT;
    tmInternalLeading : LONGINT;
    tmExternalLeading : LONGINT;
    tmAveCharWidth    : LONGINT;
    tmMaxCharWidth    : LONGINT;
    tmWeight          : LONGINT;
    tmOverhang        : LONGINT;
    tmDigitizedAspectX: LONGINT;
    tmDigitizedAspectY: LONGINT;
    tmFirstChar       : WD.BYTE;
    tmLastChar        : WD.BYTE;
    tmDefaultChar     : WD.BYTE;
    tmBreakChar       : WD.BYTE;
    tmItalic          : WD.BYTE;
    tmUnderlined      : WD.BYTE;
    tmStruckOut       : WD.BYTE;
    tmPitchAndFamily  : WD.BYTE;
    tmCharSet         : WD.BYTE;
    ntmFlags          : WD.DWORD;
    ntmSizeEM         : WD.UINT;
    ntmCellHeight     : WD.UINT;
    ntmAvgWidth       : WD.UINT;
  END;

  PNEWTEXTMETRICA = POINTER TO NEWTEXTMETRICA;
  NPNEWTEXTMETRICA = POINTER TO NEWTEXTMETRICA;
  LPNEWTEXTMETRICA = POINTER TO NEWTEXTMETRICA;

  NEWTEXTMETRICW = RECORD [_NOTALIGNED]
    tmHeight          : LONGINT;
    tmAscent          : LONGINT;
    tmDescent         : LONGINT;
    tmInternalLeading : LONGINT;
    tmExternalLeading : LONGINT;
    tmAveCharWidth    : LONGINT;
    tmMaxCharWidth    : LONGINT;
    tmWeight          : LONGINT;
    tmOverhang        : LONGINT;
    tmDigitizedAspectX: LONGINT;
    tmDigitizedAspectY: LONGINT;
    tmFirstChar       : WD.WCHAR;
    tmLastChar        : WD.WCHAR;
    tmDefaultChar     : WD.WCHAR;
    tmBreakChar       : WD.WCHAR;
    tmItalic          : WD.BYTE;
    tmUnderlined      : WD.BYTE;
    tmStruckOut       : WD.BYTE;
    tmPitchAndFamily  : WD.BYTE;
    tmCharSet         : WD.BYTE;
    ntmFlags          : WD.DWORD;
    ntmSizeEM         : WD.UINT;
    ntmCellHeight     : WD.UINT;
    ntmAvgWidth       : WD.UINT;
  END;

  PNEWTEXTMETRICW = POINTER TO NEWTEXTMETRICW;
  NPNEWTEXTMETRICW = POINTER TO NEWTEXTMETRICW;
  LPNEWTEXTMETRICW = POINTER TO NEWTEXTMETRICW;

  NEWTEXTMETRIC = NEWTEXTMETRICA;  (* ! A *)
  PNEWTEXTMETRIC = PNEWTEXTMETRICA;   (* ! A *)
  NPNEWTEXTMETRIC = NPNEWTEXTMETRICA; (* ! A *)
  LPNEWTEXTMETRIC = LPNEWTEXTMETRICA; (* ! A *)

(* #include <poppack.h> *)

  NEWTEXTMETRICEXA = RECORD [_NOTALIGNED]
    ntmTm     : NEWTEXTMETRICA;
    ntmFontSig: FONTSIGNATURE;
  END;

  NEWTEXTMETRICEXW = RECORD [_NOTALIGNED]
    ntmTm     : NEWTEXTMETRICW;
    ntmFontSig: FONTSIGNATURE;
  END;

  NEWTEXTMETRICEX = NEWTEXTMETRICEXA;  (* ! A *)

(*  GDI Logical Objects:  *)
(*  Pel Array  *)

  PELARRAY = RECORD [_NOTALIGNED]
    paXCount: LONGINT;
    paYCount: LONGINT;
    paXExt  : LONGINT;
    paYExt  : LONGINT;
    paRGBs  : WD.BYTE;
  END;

  PPELARRAY = POINTER TO PELARRAY;
  NPPELARRAY = POINTER TO PELARRAY;
  LPPELARRAY = POINTER TO PELARRAY;

(*  Logical Brush (or Pattern)  *)

  LOGBRUSH = RECORD [_NOTALIGNED]
    lbStyle: WD.UINT;
    lbColor: WD.COLORREF;
    lbHatch: LONGINT;
  END;

  PLOGBRUSH = POINTER TO LOGBRUSH;
  NPLOGBRUSH = POINTER TO LOGBRUSH;
  LPLOGBRUSH = POINTER TO LOGBRUSH;
  PATTERN = LOGBRUSH;
  PPATTERN = POINTER TO PATTERN;
  NPPATTERN = POINTER TO PATTERN;
  LPPATTERN = POINTER TO PATTERN;

(*  Logical Pen  *)

  LOGPEN = RECORD [_NOTALIGNED]
    lopnStyle: WD.UINT;
    lopnWidth: WD.POINT;
    lopnColor: WD.COLORREF;
  END;

  PLOGPEN = POINTER TO LOGPEN;
  NPLOGPEN = POINTER TO LOGPEN;
  LPLOGPEN = POINTER TO LOGPEN;

  EXTLOGPEN = RECORD [_NOTALIGNED]
    elpPenStyle  : WD.DWORD;
    elpWidth     : WD.DWORD;
    elpBrushStyle: WD.UINT;
    elpColor     : WD.COLORREF;
    elpHatch     : LONGINT;
    elpNumEntries: WD.DWORD;
    elpStyleEntry: LONGINT; (*ARRAY [1] OF WD.DWORD;*)
  END;

  PEXTLOGPEN = POINTER TO EXTLOGPEN;
  NPEXTLOGPEN = POINTER TO EXTLOGPEN;
  LPEXTLOGPEN = POINTER TO EXTLOGPEN;

  PALETTEENTRY = RECORD [_NOTALIGNED]
    peRed  : WD.BYTE;
    peGreen: WD.BYTE;
    peBlue : WD.BYTE;
    peFlags: WD.BYTE;
  END;

  PPALETTEENTRY = POINTER TO PALETTEENTRY;
  LPPALETTEENTRY = POINTER TO PALETTEENTRY;

(*  Logical Palette  *)

  LOGPALETTE = RECORD [_NOTALIGNED]
    palVersion   : WD.WORD;
    palNumEntries: WD.WORD;
  END;

  LOGPALETTE2 = RECORD [_NOTALIGNED] (LOGPALETTE)
    palPalEntry  : ARRAY 2 OF PALETTEENTRY;
  END;

  LOGPALETTE16 = RECORD [_NOTALIGNED] (LOGPALETTE)
    palPalEntry  : ARRAY 16 OF PALETTEENTRY;
  END;

  LOGPALETTE256 = RECORD [_NOTALIGNED] (LOGPALETTE)
    palPalEntry  : ARRAY 256 OF PALETTEENTRY;
  END;

  PLOGPALETTE = POINTER TO LOGPALETTE;
  NPLOGPALETTE = POINTER TO LOGPALETTE;
  LPLOGPALETTE = POINTER TO LOGPALETTE;

(*  Logical Font  *)


  LOGFONTA = RECORD [_NOTALIGNED]
    lfHeight        : LONGINT;
    lfWidth         : LONGINT;
    lfEscapement    : LONGINT;
    lfOrientation   : LONGINT;
    lfWeight        : LONGINT;
    lfItalic        : WD.BYTE;
    lfUnderline     : WD.BYTE;
    lfStrikeOut     : WD.BYTE;
    lfCharSet       : WD.BYTE;
    lfOutPrecision  : WD.BYTE;
    lfClipPrecision : WD.BYTE;
    lfQuality       : WD.BYTE;
    lfPitchAndFamily: WD.BYTE;
    lfFaceName      : ARRAY LF_FACESIZE OF CHAR;
  END;

  PLOGFONTA = POINTER TO LOGFONTA;
  NPLOGFONTA = POINTER TO LOGFONTA;
  LPLOGFONTA = POINTER TO LOGFONTA;
    
  LOGFONTW = RECORD [_NOTALIGNED]
    lfHeight        : LONGINT;
    lfWidth         : LONGINT;
    lfEscapement    : LONGINT;
    lfOrientation   : LONGINT;
    lfWeight        : LONGINT;
    lfItalic        : WD.BYTE;
    lfUnderline     : WD.BYTE;
    lfStrikeOut     : WD.BYTE;
    lfCharSet       : WD.BYTE;
    lfOutPrecision  : WD.BYTE;
    lfClipPrecision : WD.BYTE;
    lfQuality       : WD.BYTE;
    lfPitchAndFamily: WD.BYTE;
    lfFaceName      : ARRAY LF_FACESIZE OF CHAR;
  END;
  PLOGFONTW = POINTER TO LOGFONTW;
  NPLOGFONTW = POINTER TO LOGFONTW;
  LPLOGFONTW = POINTER TO LOGFONTW;
  LOGFONT = LOGFONTA;    (* ! A *)
  PLOGFONT = PLOGFONTA;    (* ! A *)
  NPLOGFONT = NPLOGFONTA; (* ! A *)
  LPLOGFONT = LPLOGFONTA; (* ! A *)


(*  Structure passed to FONTENUMPROC  *)
 
  ENUMLOGFONTA = RECORD [_NOTALIGNED]
    elfLogFont : LOGFONTA;
    elfFullName: ARRAY LF_FULLFACESIZE OF WD.BYTE;
    elfStyle   : ARRAY LF_FACESIZE OF WD.BYTE;
  END;

  LPENUMLOGFONTA = POINTER TO ENUMLOGFONTA;

(*  Structure passed to FONTENUMPROC  *)

  ENUMLOGFONTW = RECORD [_NOTALIGNED]
    elfLogFont : LOGFONTW;
    elfFullName: ARRAY LF_FULLFACESIZE OF WD.WCHAR;
    elfStyle   :ARRAY LF_FACESIZE OF WD.WCHAR;
  END;

  LPENUMLOGFONTW = POINTER TO ENUMLOGFONTW;

  ENUMLOGFONT = ENUMLOGFONTA;    (* ! A *)
  LPENUMLOGFONT = LPENUMLOGFONTA; (* ! A *)

  ENUMLOGFONTEXA = RECORD [_NOTALIGNED]
    elfLogFont : LOGFONTA;
    elfFullName: ARRAY LF_FULLFACESIZE OF WD.BYTE;
    elfStyle   : ARRAY LF_FACESIZE OF WD.BYTE;
    elfScript  : ARRAY LF_FACESIZE OF WD.BYTE;
  END;

  LPENUMLOGFONTEXA = POINTER TO ENUMLOGFONTEXA;

  ENUMLOGFONTEXW = RECORD [_NOTALIGNED]
    elfLogFont : LOGFONTA;
    elfFullName: ARRAY LF_FULLFACESIZE OF WD.WCHAR;
    elfStyle   : ARRAY LF_FACESIZE OF WD.WCHAR;
    elfScript  : ARRAY LF_FACESIZE OF WD.WCHAR;
  END;

  LPENUMLOGFONTEXW = POINTER TO ENUMLOGFONTEXW;

  ENUMLOGFONTEX = ENUMLOGFONTEXA;     (* ! A *)
  LPENUMLOGFONTEX = LPENUMLOGFONTEXA;  (* ! A *)

  PANOSE = RECORD [_NOTALIGNED]
    bFamilyType     : WD.BYTE;
    bSerifStyle     : WD.BYTE;
    bWeight         : WD.BYTE;
    bProportion     : WD.BYTE;
    bContrast       : WD.BYTE;
    bStrokeVariation: WD.BYTE;
    bArmStyle       : WD.BYTE;
    bLetterform     : WD.BYTE;
    bMidline        : WD.BYTE;
    bXHeight        : WD.BYTE;
  END;

  LPPANOSE = POINTER TO PANOSE;



(*  The extended logical font        *)
(*  An extension of the ENUMLOGFONT  *)

  EXTLOGFONTA = RECORD [_NOTALIGNED]
    elfLogFont  : LOGFONTA;
    elfFullName : ARRAY LF_FULLFACESIZE OF WD.BYTE;
    elfStyle    : ARRAY LF_FACESIZE OF WD.BYTE;
    elfVersion  : WD.DWORD;                              (*  0 for the first release of NT  *)
    elfStyleSize: WD.DWORD;
    elfMatch    : WD.DWORD;
    elfReserved : WD.DWORD;
    elfVendorId : ARRAY ELF_VENDOR_SIZE OF WD.BYTE;
    elfCulture  : WD.DWORD;                              (*  0 for Latin                    *)
    elfPanose   : PANOSE;
  END;

  PEXTLOGFONTA = POINTER TO EXTLOGFONTA;
  NPEXTLOGFONTA = POINTER TO EXTLOGFONTA;
  LPEXTLOGFONTA = POINTER TO EXTLOGFONTA;

  EXTLOGFONTW = RECORD [_NOTALIGNED]
    elfLogFont  : LOGFONTW;
    elfFullName : ARRAY LF_FULLFACESIZE OF WD.WCHAR;
    elfStyle    : ARRAY LF_FACESIZE OF WD.WCHAR;
    elfVersion  : WD.DWORD;                        (*  0 for the first release of NT  *)
    elfStyleSize: WD.DWORD;
    elfMatch    : WD.DWORD;
    elfReserved : WD.DWORD;
    elfVendorId : ARRAY ELF_VENDOR_SIZE OF WD.BYTE;
    elfCulture  : WD.DWORD;                        (*  0 for Latin                    *)
    elfPanose   : PANOSE;
  END;

  PEXTLOGFONTW = POINTER TO EXTLOGFONTW;
  NPEXTLOGFONTW = POINTER TO EXTLOGFONTW;
  LPEXTLOGFONTW = POINTER TO EXTLOGFONTW;

  EXTLOGFONT = EXTLOGFONTA;     (* ! A *)
  PEXTLOGFONT = PEXTLOGFONTA;   (* ! A *)
  NPEXTLOGFONT = NPEXTLOGFONTA;   (* ! A *)
  LPEXTLOGFONT = LPEXTLOGFONTA;   (* ! A *)

(* Marcos
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] RGB ( r, g, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / RGB ( r, g, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] PALETTERGB ( r, g, b: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / PALETTERGB ( r, g, b: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] PALETTEINDEX ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / PALETTEINDEX ( i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetRValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetRValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetGValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetGValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetBValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetBValue ( rgb: ARRAY OF SYSTEM.BYTE );
<* END *>
*)

 
  DEVMODEA = RECORD [_NOTALIGNED]
    dmDeviceName      : ARRAY CCHDEVICENAME OF WD.BYTE;
    dmSpecVersion     : WD.WORD;
    dmDriverVersion   : WD.WORD;
    dmSize            : WD.WORD;
    dmDriverExtra     : WD.WORD;
    dmFields          : WD.DWORD;
    dmOrientation     : INTEGER;
    dmPaperSize       : INTEGER;
    dmPaperLength     : INTEGER;
    dmPaperWidth      : INTEGER;
    dmScale           : INTEGER;
    dmCopies          : INTEGER;
    dmDefaultSource   : INTEGER;
    dmPrintQuality    : INTEGER;
    dmColor           : INTEGER;
    dmDuplex          : INTEGER;
    dmYResolution     : INTEGER;
    dmTTOption        : INTEGER;
    dmCollate         : INTEGER;
    dmFormName        : ARRAY CCHFORMNAME OF WD.BYTE;
    dmLogPixels       : WD.WORD;
    dmBitsPerPel      : WD.DWORD;
    dmPelsWidth       : WD.DWORD;
    dmPelsHeight      : WD.DWORD;
    dmDisplayFlags    : WD.DWORD;
    dmDisplayFrequency: WD.DWORD;
    dmICMMethod       : WD.DWORD;
    dmICMIntent       : WD.DWORD;
    dmMediaType       : WD.DWORD;
    dmDitherType      : WD.DWORD;
    dmReserved1       : WD.DWORD;
    dmReserved2       : WD.DWORD;
   (* dmDitherType: WD.DWORD;*)
    dmICCManufacturer: WD.DWORD;
    dmICCModel: WD.DWORD;
    dmPanningWidth: WD.DWORD;
    dmPanningHeight: WD.DWORD;
  END;
  PDEVMODEA = POINTER TO DEVMODEA;
  NPDEVMODEA = POINTER TO DEVMODEA;
  LPDEVMODEA = POINTER TO DEVMODEA;

  DEVMODEW = RECORD [_NOTALIGNED]
    dmDeviceName      : ARRAY CCHDEVICENAME OF WD.WCHAR;
    dmSpecVersion     : WD.WORD;
    dmDriverVersion   : WD.WORD;
    dmSize            : WD.WORD;
    dmDriverExtra     : WD.WORD;
    dmFields          : WD.DWORD;
    dmOrientation     : INTEGER;
    dmPaperSize       : INTEGER;
    dmPaperLength     : INTEGER;
    dmPaperWidth      : INTEGER;
    dmScale           : INTEGER;
    dmCopies          : INTEGER;
    dmDefaultSource   : INTEGER;
    dmPrintQuality    : INTEGER;
    dmColor           : INTEGER;
    dmDuplex          : INTEGER;
    dmYResolution     : INTEGER;
    dmTTOption        : INTEGER;
    dmCollate         : INTEGER;
    dmFormName        : ARRAY CCHFORMNAME OF WD.WCHAR;
    dmLogPixels       : WD.WORD;
    dmBitsPerPel      : WD.DWORD;
    dmPelsWidth       : WD.DWORD;
    dmPelsHeight      : WD.DWORD;
    dmDisplayFlags    : WD.DWORD;
    dmDisplayFrequency: WD.DWORD;
    dmICMMethod       : WD.DWORD;
    dmICMIntent       : WD.DWORD;
    dmMediaType       : WD.DWORD;
    dmDitherType      : WD.DWORD;
    dmReserved1       : WD.DWORD;
    dmReserved2       : WD.DWORD;
    (*dmDitherType: WD.DWORD;*)
    dmICCManufacturer: WD.DWORD;
    dmICCModel: WD.DWORD;
    dmPanningWidth: WD.DWORD;
    dmPanningHeight: WD.DWORD;
  END;

  PDEVMODEW = POINTER TO DEVMODEW;
  NPDEVMODEW = POINTER TO DEVMODEW;
  LPDEVMODEW = POINTER TO DEVMODEW;
  DEVMODE = DEVMODEA;   (* ! A *)
  PDEVMODE = PDEVMODEA;   (* ! A *) 
  NPDEVMODE = PDEVMODEA; (* ! A *)
  LPDEVMODE = PDEVMODEA; (* ! A *)

  RGNDATAHEADER = RECORD [_NOTALIGNED]
    dwSize  : WD.DWORD;
    iType   : WD.DWORD;
    nCount  : WD.DWORD;
    nRgnSize: WD.DWORD;
    rcBound : WD.RECT;
  END;

  PRGNDATAHEADER = POINTER TO RGNDATAHEADER;

  RGNDATA = RECORD [_NOTALIGNED]
    rdh   : RGNDATAHEADER;
    Buffer: LONGINT;  (*ARRAY [1] OF CHAR;*)
  END;

  PRGNDATA = POINTER TO RGNDATA;
  NPRGNDATA = POINTER TO RGNDATA;
  LPRGNDATA = POINTER TO RGNDATA;

  ABC = RECORD [_NOTALIGNED]
    abcA: LONGINT;
    abcB: WD.UINT;
    abcC: LONGINT;
  END;

  PABC = POINTER TO ABC;
  NPABC = POINTER TO ABC;
  LPABC = POINTER TO ABC;

  ABCFLOAT = RECORD [_NOTALIGNED]
    abcfA: REAL;
    abcfB: REAL;
    abcfC: REAL;
  END;

  PABCFLOAT = POINTER TO ABCFLOAT;
  NPABCFLOAT = POINTER TO ABCFLOAT;
  LPABCFLOAT = POINTER TO ABCFLOAT;

  OUTLINETEXTMETRICA = RECORD [_NOTALIGNED]
    otmSize               : WD.UINT;
    otmTextMetrics        : TEXTMETRICA;
    otmFiller             : WD.BYTE;
    otmPanoseNumber       : PANOSE;
    otmfsSelection        : WD.UINT;
    otmfsType             : WD.UINT;
    otmsCharSlopeRise     : LONGINT;
    otmsCharSlopeRun      : LONGINT;
    otmItalicAngle        : LONGINT;
    otmEMSquare           : WD.UINT;
    otmAscent             : LONGINT;
    otmDescent            : LONGINT;
    otmLineGap            : WD.UINT;
    otmsCapEmHeight       : WD.UINT;
    otmsXHeight           : WD.UINT;
    otmrcFontBox          : WD.RECT;
    otmMacAscent          : LONGINT;
    otmMacDescent         : LONGINT;
    otmMacLineGap         : WD.UINT;
    otmusMinimumPPEM      : WD.UINT;
    otmptSubscriptSize    : WD.POINT;
    otmptSubscriptOffset  : WD.POINT;
    otmptSuperscriptSize  : WD.POINT;
    otmptSuperscriptOffset: WD.POINT;
    otmsStrikeoutSize     : WD.UINT;
    otmsStrikeoutPosition : LONGINT;
    otmsUnderscoreSize    : LONGINT;
    otmsUnderscorePosition: LONGINT;
    otmpFamilyName        : WD.PSTR;
    otmpFaceName          : WD.PSTR;
    otmpStyleName         : WD.PSTR;
    otmpFullName          : WD.PSTR;
  END;

  POUTLINETEXTMETRICA = POINTER TO OUTLINETEXTMETRICA;
  NPOUTLINETEXTMETRICA = POINTER TO OUTLINETEXTMETRICA;
  LPOUTLINETEXTMETRICA = POINTER TO OUTLINETEXTMETRICA;

  OUTLINETEXTMETRICW = RECORD [_NOTALIGNED]
    otmSize               : WD.UINT;
    otmTextMetrics        : TEXTMETRICW;
    otmFiller             : WD.BYTE;
    otmPanoseNumber       : PANOSE;
    otmfsSelection        : WD.UINT;
    otmfsType             : WD.UINT;
    otmsCharSlopeRise     : LONGINT;
    otmsCharSlopeRun      : LONGINT;
    otmItalicAngle        : LONGINT;
    otmEMSquare           : WD.UINT;
    otmAscent             : LONGINT;
    otmDescent            : LONGINT;
    otmLineGap            : WD.UINT;
    otmsCapEmHeight       : WD.UINT;
    otmsXHeight           : WD.UINT;
    otmrcFontBox          : WD.RECT;
    otmMacAscent          : LONGINT;
    otmMacDescent         : LONGINT;
    otmMacLineGap         : WD.UINT;
    otmusMinimumPPEM      : WD.UINT;
    otmptSubscriptSize    : WD.POINT;
    otmptSubscriptOffset  : WD.POINT;
    otmptSuperscriptSize  : WD.POINT;
    otmptSuperscriptOffset: WD.POINT;
    otmsStrikeoutSize     : WD.UINT;
    otmsStrikeoutPosition : LONGINT;
    otmsUnderscoreSize    : LONGINT;
    otmsUnderscorePosition: LONGINT;
    otmpFamilyName        : WD.PSTR;
    otmpFaceName          : WD.PSTR;
    otmpStyleName         : WD.PSTR;
    otmpFullName          : WD.PSTR;
  END;

  POUTLINETEXTMETRICW = POINTER TO OUTLINETEXTMETRICW;
  NPOUTLINETEXTMETRICW = POINTER TO OUTLINETEXTMETRICW;
  LPOUTLINETEXTMETRICW = POINTER TO OUTLINETEXTMETRICW;
  OUTLINETEXTMETRIC = OUTLINETEXTMETRICA;    (* ! A *)
  POUTLINETEXTMETRIC = POUTLINETEXTMETRICA;    (* ! A *)
  NPOUTLINETEXTMETRIC = NPOUTLINETEXTMETRICA; (* ! A *)
  LPOUTLINETEXTMETRIC = LPOUTLINETEXTMETRICA; (* ! A *)

  POLYTEXTA = RECORD [_NOTALIGNED]
    x      : LONGINT;
    y      : LONGINT;
    n      : WD.UINT;
    lpstr  : WD.LPCSTR;
    uiFlags: WD.UINT;
    rcl    : WD.RECT;
    pdx    : WD.PBOOL;
  END;

  PPOLYTEXTA = POINTER TO POLYTEXTA;
  NPPOLYTEXTA = POINTER TO POLYTEXTA;
  LPPOLYTEXTA = POINTER TO POLYTEXTA;

  POLYTEXTW = RECORD [_NOTALIGNED]
    x      : LONGINT;
    y      : LONGINT;
    n      : WD.UINT;
    lpstr  : WD.LPCSTR;
    uiFlags: WD.UINT;
    rcl    : WD.RECT;
    pdx    : WD.PBOOL;
  END;
  
  PPOLYTEXTW = POINTER TO POLYTEXTW;
  NPPOLYTEXTW = POINTER TO POLYTEXTW;
  LPPOLYTEXTW = POINTER TO POLYTEXTW;

  POLYTEXT = POLYTEXTA;     (* ! A *)
  PPOLYTEXT = PPOLYTEXTA;   (* ! A *)
  NPPOLYTEXT = NPPOLYTEXTA;   (* ! A *)
  LPPOLYTEXT = LPPOLYTEXTA;   (* ! A *)

  FIXED = RECORD [_NOTALIGNED]
    fract: WD.WORD;
    value: INTEGER;
  END;

  MAT2 = RECORD [_NOTALIGNED]
    eM11: FIXED;
    eM12: FIXED;
    eM21: FIXED;
    eM22: FIXED;
  END;

  LPMAT2 = POINTER TO MAT2;

  GLYPHMETRICS = RECORD [_NOTALIGNED]
    gmBlackBoxX    : WD.UINT;
    gmBlackBoxY    : WD.UINT;
    gmptGlyphOrigin: WD.POINT;
    gmCellIncX     : INTEGER;
    gmCellIncY     : INTEGER;
  END;

  LPGLYPHMETRICS = POINTER TO GLYPHMETRICS;

  POINTFX = RECORD [_NOTALIGNED]
    x: FIXED;
    y: FIXED;
  END;

  LPPOINTFX = POINTER TO POINTFX;

  TTPOLYCURVE = RECORD [_NOTALIGNED]
    wType: WD.WORD;
    cpfx : WD.WORD;
    apfx : LONGINT;  (*ARRAY [1] OF POINTFX;*)
  END;

  LPTTPOLYCURVE = POINTER TO TTPOLYCURVE;

  TTPOLYGONHEADER = RECORD [_NOTALIGNED]
    cb      : WD.DWORD;
    dwType  : WD.DWORD;
    pfxStart: POINTFX;
  END;

  LPTTPOLYGONHEADER = POINTER TO TTPOLYGONHEADER;



  GCP_RESULTSA = RECORD [_NOTALIGNED]
    lStructSize: WD.DWORD;
    lpOutString: WD.LPSTR;
    lpOrder    : WD.PUINT;  (*H2D_h2d_wingdi_PtrUINT;*)
    lpDx       : WD.PUINT;  (*H2D_h2d_wingdi_PtrSInt;*)
    lpCaretPos : WD.PUINT;  (*H2D_h2d_wingdi_PtrSInt;*)
    lpClass    : WD.LPSTR;
    lpGlyphs   : WD.LPWSTR;
    nGlyphs    : WD.UINT;
    nMaxFit    : LONGINT;
  END;

  LPGCP_RESULTSA = POINTER TO GCP_RESULTSA;

  GCP_RESULTSW = RECORD [_NOTALIGNED]
    lStructSize: WD.DWORD;
    lpOutString: WD.LPWSTR;
    lpOrder    : WD.PUINT;  (*2D_h2d_wingdi_PtrUINT;*)
    lpDx       : WD.PUINT;  (*H2D_h2d_wingdi_PtrSInt;*)
    lpCaretPos : WD.PUINT;  (*H2D_h2d_wingdi_PtrSInt;*)
    lpClass    : WD.LPSTR;
    lpGlyphs   : WD.LPWSTR;
    nGlyphs    : WD.UINT;
    nMaxFit    : LONGINT;
  END;

  LPGCP_RESULTSW = POINTER TO GCP_RESULTSW;

  GCP_RESULTS = GCP_RESULTSA;    (* ! A *)
  LPGCP_RESULTS = LPGCP_RESULTSA;    (* ! A *)

  RASTERIZER_STATUS = RECORD [_NOTALIGNED]
    nSize      : INTEGER;
    wFlags     : INTEGER;
    nLanguageID: INTEGER;
  END;

  LPRASTERIZER_STATUS = POINTER TO RASTERIZER_STATUS;



(*  Pixel format descriptor  *)

  PIXELFORMATDESCRIPTOR = RECORD [_NOTALIGNED]
    nSize          : WD.WORD;
    nVersion       : WD.WORD;
    dwFlags        : WD.DWORD;
    iPixelType     : WD.BYTE;
    cColorBits     : WD.BYTE;
    cRedBits       : WD.BYTE;
    cRedShift      : WD.BYTE;
    cGreenBits     : WD.BYTE;
    cGreenShift    : WD.BYTE;
    cBlueBits      : WD.BYTE;
    cBlueShift     : WD.BYTE;
    cAlphaBits     : WD.BYTE;
    cAlphaShift    : WD.BYTE;
    cAccumBits     : WD.BYTE;
    cAccumRedBits  : WD.BYTE;
    cAccumGreenBits: WD.BYTE;
    cAccumBlueBits : WD.BYTE;
    cAccumAlphaBits: WD.BYTE;
    cDepthBits     : WD.BYTE;
    cStencilBits   : WD.BYTE;
    cAuxBuffers    : WD.BYTE;
    iLayerType     : WD.BYTE;
    bReserved      : WD.BYTE;
    dwLayerMask    : WD.DWORD;
    dwVisibleMask  : WD.DWORD;
    dwDamageMask   : WD.DWORD;
  END;

  PPIXELFORMATDESCRIPTOR = POINTER TO PIXELFORMATDESCRIPTOR;
  LPPIXELFORMATDESCRIPTOR = POINTER TO PIXELFORMATDESCRIPTOR;


  OLDFONTENUMPROC = WD.FARPROC;
  FONTENUMPROCA = OLDFONTENUMPROC;
  FONTENUMPROCW = OLDFONTENUMPROC;
  FONTENUMPROC = OLDFONTENUMPROC;  (* ! A *)
  GOBJENUMPROC = OLDFONTENUMPROC;  (* ! A *)
  LINEDDAPROC = OLDFONTENUMPROC;  (* ! A *)

(*    define types of pointers to ExtDeviceMode() and DeviceCapabilities()  *)
(*  * functions for Win 3.1 compatibility                                   *)
(*                                                                          *) 
  LPFNDEVMODE = PROCEDURE [_APICALL] ( a:WD.HWND; b:WD.HMODULE; c:LPDEVMODE; d:WD.LPSTR;
                          e:WD.LPSTR; f:LPDEVMODE; g:WD.LPSTR; h:WD.UINT ): WD.UINT;

  LPFNDEVCAPS = PROCEDURE [_APICALL] ( a:WD.LPSTR; b:WD.LPSTR; c:WD.UINT; d:WD.LPSTR; e:LPDEVMODE ):WD.DWORD;

(* ! AddFontResource *)

  MFENUMPROC = PROCEDURE [_APICALL] ( a:WD.HDC; b:LPHANDLETABLE; c:LPMETARECORD; d:LONGINT;
                         e:WD.LPARAM ): LONGINT;

  ENHMFENUMPROC = PROCEDURE [_APICALL] ( a:WD.HDC; b:LPHANDLETABLE; c:PENHMETARECORD; d:LONGINT;
                            e:WD.LPARAM ): LONGINT;


  DIBSECTION = RECORD [_NOTALIGNED]
    dsBm       : BITMAP;
    dsBmih     : BITMAPINFOHEADER;
    dsBitfields: ARRAY 3 OF WD.DWORD;
    dshSection : WD.HANDLE;
    dsOffset   : WD.DWORD;
  END;

  LPDIBSECTION = POINTER TO DIBSECTION;

  PDIBSECTION = POINTER TO DIBSECTION;


  COLORADJUSTMENT = RECORD [_NOTALIGNED]
    caSize           : WD.WORD;
    caFlags          : WD.WORD;
    caIlluminantIndex: WD.WORD;
    caRedGamma       : WD.WORD;
    caGreenGamma     : WD.WORD;
    caBlueGamma      : WD.WORD;
    caReferenceBlack : WD.WORD;
    caReferenceWhite : WD.WORD;
    caContrast       : INTEGER;
    caBrightness     : INTEGER;
    caColorfulness   : INTEGER;
    caRedGreenTint   : INTEGER;
  END;

  PCOLORADJUSTMENT = POINTER TO COLORADJUSTMENT;
  LPCOLORADJUSTMENT = POINTER TO COLORADJUSTMENT;
 
  POINTFLOAT = RECORD [_NOTALIGNED]
    x: REAL;
    y: REAL;
  END;

  PPOINTFLOAT = POINTER TO POINTFLOAT;

  GLYPHMETRICSFLOAT = RECORD [_NOTALIGNED]
    gmfBlackBoxX    : REAL;
    gmfBlackBoxY    : REAL;
    gmfptGlyphOrigin: POINTFLOAT;
    gmfCellIncX     : REAL;
    gmfCellIncY     : REAL;
  END;

  PGLYPHMETRICSFLOAT = POINTER TO GLYPHMETRICSFLOAT;
  LPGLYPHMETRICSFLOAT = POINTER TO GLYPHMETRICSFLOAT;

 
  ICMENUMPROCA = PROCEDURE [_APICALL] ( a:WD.LPSTR; b:WD.LPARAM ): LONGINT;

  ICMENUMPROCW = PROCEDURE [_APICALL] ( a:WD.LPWSTR; b:WD.LPARAM ): LONGINT;

  ICMENUMPROC = ICMENUMPROCA;   (* ! A *)

  ABORTPROC = OLDFONTENUMPROC;

  DOCINFOA = RECORD [_NOTALIGNED]
    cbSize      : LONGINT;
    lpszDocName : WD.LPCSTR;
    lpszOutput  : WD.LPCSTR;
    lpszDatatype: WD.LPCSTR;
    fwType      : WD.DWORD;
  END;

  LPDOCINFOA = POINTER TO DOCINFOA;

  DOCINFOW = RECORD [_NOTALIGNED]
    cbSize      : LONGINT;
    lpszDocName : WD.LPCWSTR;
    lpszOutput  : WD.LPCWSTR;
    lpszDatatype: WD.LPCWSTR;
    fwType      : WD.DWORD;
  END;

  LPDOCINFOW = POINTER TO DOCINFOW;
  DOCINFO = DOCINFOA;    (* ! A *)
  LPDOCINFO = LPDOCINFOA; (* ! A *)

  KERNINGPAIR = RECORD [_NOTALIGNED]
    wFirst     : WD.WORD;
    wSecond    : WD.WORD;
    iKernAmount: LONGINT;
  END;

  LPKERNINGPAIR = POINTER TO KERNINGPAIR;

(* Layer plane descriptor *)
LAYERPLANEDESCRIPTOR = RECORD [_NOTALIGNED]
      nSize: WD.WORD;
      nVersion: WD.WORD;
      dwFlags: WD.DWORD;
      iPixelType: WD.BYTE;
      cColorBits: WD.BYTE;
      cRedBits: WD.BYTE;
      cRedShift: WD.BYTE;
      cGreenBits: WD.BYTE;
      cGreenShift: WD.BYTE;
      cBlueBits: WD.BYTE;
      cBlueShift: WD.BYTE;
      cAlphaBits: WD.BYTE;
      cAlphaShift: WD.BYTE;
      cAccumBits: WD.BYTE;
      cAccumRedBits: WD.BYTE;
      cAccumGreenBits: WD.BYTE;
      cAccumBlueBits: WD.BYTE;
      cAccumAlphaBits: WD.BYTE;
      cDepthBits: WD.BYTE;
      cStencilBits: WD.BYTE;
      cAuxBuffers: WD.BYTE;
      iLayerPlane: WD.BYTE;
      bReserved: WD.BYTE;
      crTransparent: WD.COLORREF;
END;
PLAYERPLANEDESCRIPTOR = POINTER TO LAYERPLANEDESCRIPTOR;
LPLAYERPLANEDESCRIPTOR = POINTER TO LAYERPLANEDESCRIPTOR;

(*  OpenGL wgl prototypes *)
PROCEDURE [_APICALL] AddFontResourceA ( lpszFilename: WD.LPCSTR ): LONGINT;
PROCEDURE [_APICALL] AddFontResourceW ( lpszFilenam: WD.LPCWSTR ): LONGINT;

PROCEDURE [_APICALL] AnimatePalette ( hPal: WD.HPALETTE; iStartIndex: WD.UINT;
                           cEntries: WD.UINT;
                           VAR STATICTYPED ppe: PALETTEENTRY ): WD.BOOL;

PROCEDURE [_APICALL] Arc ( hdc: WD.HDC; nLeftRec: LONGINT; nTopRec: LONGINT; nRightRec: LONGINT;
                nBottomRec: LONGINT; nXStartArc: LONGINT; nYStartArc: LONGINT; 
        nXEndArc: LONGINT; nYEndARC: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] BitBlt ( hdcDest: WD.HDC; nXDest: LONGINT; nYDest: LONGINT; nWidth: LONGINT;
                   nHeigth: LONGINT; hdcSrc: WD.HDC; nXSrc: LONGINT; nYSrc: LONGINT;
                   dwPop: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] CancelDC ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] Chord ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT; nRight: LONGINT;
                  nBottomRect: LONGINT; nXRadial1: LONGINT; nYRadial1: LONGINT; 
          nXRadial2: LONGINT; nYRadial2: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ChoosePixelFormat ( hdc: WD.HDC;
                              VAR STATICTYPED ppfd: PIXELFORMATDESCRIPTOR ): LONGINT;

PROCEDURE [_APICALL] CloseMetaFile ( hdc: WD.HDC ): WD.HMETAFILE;

PROCEDURE [_APICALL] CombineRgn ( hrgnDest: WD.HRGN; hrgnScr1: WD.HRGN;
                       hrgnScr2: WD.HRGN; fnCombineMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] CopyMetaFileA ( hmfSrc: WD.HMETAFILE;
                          lpszFile: WD.LPCSTR ): WD.HMETAFILE;
PROCEDURE [_APICALL] CopyMetaFileW ( hmfSrc: WD.HMETAFILE;
                          lpszFile: WD.LPCWSTR ): WD.HMETAFILE;
(* ! CopyMetaFile *)

PROCEDURE [_APICALL] CreateBitmap ( nWidth: LONGINT; nHeight: LONGINT; cPlanes: WD.UINT;
                         cBitsPerPel: WD.UINT;
                         lpvBits: WD.LPVOID ): WD.HBITMAP;  

PROCEDURE [_APICALL] CreateBitmapIndirect ( VAR STATICTYPED lpbm: BITMAP ): WD.HBITMAP;

PROCEDURE [_APICALL] CreateBrushIndirect ( VAR STATICTYPED lplb: LOGBRUSH ): WD.HBRUSH;

PROCEDURE [_APICALL] CreateCompatibleBitmap ( hdc: WD.HDC; nWidth: LONGINT;
                                   nHeight: LONGINT ): WD.HBITMAP;

PROCEDURE [_APICALL] CreateDiscardableBitmap ( hdc: WD.HDC; nWidth: LONGINT;
                                    nHeight: LONGINT ): WD.HBITMAP;

PROCEDURE [_APICALL] CreateCompatibleDC ( hdc: WD.HDC ): WD.HDC;

PROCEDURE [_APICALL] CreateDCA ( lpszDriver: WD.LPCSTR; lpszDevice: WD.LPCSTR; lpszOutPut: WD.LPCSTR;
                      VAR STATICTYPED lpInitData: DEVMODEA ): WD.HDC;
PROCEDURE [_APICALL] CreateDCW ( lpszDriver: WD.LPCWSTR; lpszDevice: WD.LPCWSTR; lpszOutPut: WD.LPCWSTR;
                      VAR STATICTYPED lpInitData: DEVMODEW ): WD.HDC;
(* !  CreateDC *)
PROCEDURE [_APICALL] CreateDIBitmap ( hdc: WD.HDC; VAR STATICTYPED bmih: BITMAPINFOHEADER;
                           fdwInit: WD.DWORD; 
                           lpnInit: WD.LPVOID;
                           VAR STATICTYPED lpbmi: BITMAPINFO;
                           fuUsage: WD.UINT ): WD.HBITMAP;

PROCEDURE [_APICALL] CreateDIBPatternBrush ( hlgbDIBPacked: WD.HGLOBAL;
                                  fuColorSpec: WD.UINT ): WD.HBRUSH;

PROCEDURE [_APICALL] CreateDIBPatternBrushPt (lpPackedDib:WD.LPVOID;
                                    iUsage: WD.UINT ): WD.HBRUSH;

PROCEDURE [_APICALL] CreateEllipticRgn ( nLeftRect: LONGINT; nTopRect: LONGINT; 
                nRightREct: LONGINT; nBottomREct: LONGINT ): WD.HRGN;

PROCEDURE [_APICALL] CreateEllipticRgnIndirect ( VAR STATICTYPED lprc: WD.RECT ): WD.HRGN;

PROCEDURE [_APICALL] CreateFontIndirectA ( VAR STATICTYPED lplf: LOGFONTA ): WD.HFONT;
PROCEDURE [_APICALL] CreateFontIndirectW ( VAR STATICTYPED lplf: LOGFONTW ): WD.HFONT;
(* ! CreateFontIndirect *)

PROCEDURE [_APICALL] CreateFontA ( nHeight: LONGINT; nWidth: LONGINT; 
            nEscapment: LONGINT; nOrientation: LONGINT;
                        fnWidth: LONGINT; fdwItalic: WD.DWORD; fdwUnderLine: WD.DWORD;
                        fdwStrikeOut: WD.DWORD; fdwCharSet: WD.DWORD;
                        fdwOutputPrecision: WD.DWORD; fdwClipPrecision: WD.DWORD;
                        fdwQuality: WD.DWORD; fdwPitchAndFamily: WD.DWORD;
                        lpszFace: WD.LPCSTR ): WD.HFONT;
PROCEDURE [_APICALL] CreateFontW ( nHeight: LONGINT; nWidth: LONGINT; 
            nEscapment: LONGINT; nOrientation: LONGINT;
                        fnWidth: LONGINT; fdwItalic: WD.DWORD; fdwUnderLine: WD.DWORD;
                        fdwStrikeOut: WD.DWORD; fdwCharSet: WD.DWORD;
                        fdwOutputPrecision: WD.DWORD; fdwClipPrecision: WD.DWORD;
                        fdwQuality: WD.DWORD; fdwPitchAndFamily: WD.DWORD;
                        lpszFace: WD.LPCWSTR ): WD.HFONT;
(* ! CreateFont *)

PROCEDURE [_APICALL] CreateHatchBrush ( fnStyle: LONGINT;
                             clref: WD.COLORREF ): WD.HBRUSH;


(* names of param from MS Visual C++ 4.0 helpfile*)


PROCEDURE [_APICALL] CreateICA ( arg0: WD.LPCSTR; arg1: WD.LPCSTR; arg2: WD.LPCSTR;
                      VAR STATICTYPED arg3: DEVMODEA ): WD.HDC;
PROCEDURE [_APICALL] CreateICW ( arg0: WD.LPCWSTR; arg1: WD.LPCWSTR; arg2: WD.LPCWSTR;
                      VAR STATICTYPED arg3: DEVMODEW ): WD.HDC;
(* ! CreateIC *)

PROCEDURE [_APICALL] CreateMetaFileA ( lpszFile: WD.LPCSTR ): WD.HDC;
PROCEDURE [_APICALL] CreateMetaFileW ( lpszFile: WD.LPCWSTR ): WD.HDC;
(* !  CreateMetaFile *)

PROCEDURE [_APICALL] CreatePalette ( VAR STATICTYPED lplgpl: LOGPALETTE ): WD.HPALETTE;

PROCEDURE [_APICALL] CreatePen ( fnPenStyle: LONGINT; nWidth: LONGINT;
                      crColor: WD.COLORREF ): WD.HPEN;

PROCEDURE [_APICALL] CreatePenIndirect ( VAR STATICTYPED lgpn: LOGPEN ): WD.HPEN;

PROCEDURE [_APICALL] CreatePolyPolygonRgn ( VAR STATICTYPED pt: WD.POINT; VAR PolyCounts: LONGINT;
                                 nCount: LONGINT; fnPolyFillMode: LONGINT ): WD.HRGN;

PROCEDURE [_APICALL] CreatePatternBrush ( hbmp: WD.HBITMAP ): WD.HBRUSH;

PROCEDURE [_APICALL] CreateRectRgn ( nLeftRect: LONGINT; nTopRect: LONGINT; nRightRect: LONGINT;
                          nBottomRect: LONGINT ): WD.HRGN;

PROCEDURE [_APICALL] CreateRectRgnIndirect ( VAR STATICTYPED rc: WD.RECT ): WD.HRGN;

PROCEDURE [_APICALL] CreateRoundRectRgn ( nLeftRect: LONGINT; nTopRect: LONGINT; nRightRect: LONGINT;
                               nBottomRect: LONGINT; nWidthEllipse: LONGINT;
                               nHeightEllipse: LONGINT ): WD.HRGN;

PROCEDURE [_APICALL] CreateScalableFontResourceA ( fdwHidden: WD.DWORD; lpszFontRes: WD.LPCSTR;
                                        lpszFontFile: WD.LPCSTR; lpszCurrentPath: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] CreateScalableFontResourceW ( fdwHidden: WD.DWORD; lpszFontRes: WD.LPCWSTR;
                                        lpszFontFile: WD.LPCWSTR; lpszCurrentPath: WD.LPCWSTR ): WD.BOOL;
(* ! CreateScalableFontResource *)

PROCEDURE [_APICALL] CreateSolidBrush ( crColor: WD.COLORREF ): WD.HBRUSH;

PROCEDURE [_APICALL] DeleteDC ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] DeleteMetaFile ( hmf: WD.HMETAFILE ): WD.BOOL;

PROCEDURE [_APICALL] DeleteObject ( hObject: WD.HGDIOBJ ): WD.BOOL;

PROCEDURE [_APICALL] DescribePixelFormat ( hdc: WD.HDC; iPixelFormat: LONGINT;
                                nBytes: WD.UINT;
                                VAR STATICTYPED pfd: PIXELFORMATDESCRIPTOR ): LONGINT;

PROCEDURE [_APICALL] DeviceCapabilitiesA ( pDevice: WD.LPCSTR; pPort: WD.LPCSTR; fwCapability: WD.WORD;
                                pOutput: WD.LPSTR; VAR STATICTYPED DevMode: DEVMODEA ): LONGINT;
PROCEDURE [_APICALL] DeviceCapabilitiesW ( pDevice: WD.LPCWSTR; pPort: WD.LPCWSTR; fwCapability: WD.WORD;
                                pOutput: WD.LPWSTR; VAR STATICTYPED DevMode: DEVMODEW ): LONGINT;
(* ! DeviceCapabilities *)
PROCEDURE [_APICALL] DrawEscape ( hdc: WD.HDC; nEscape: LONGINT; cbInput: LONGINT;
                       lpszInData: WD.LPCSTR ): LONGINT;

PROCEDURE [_APICALL] Ellipse ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT; nRightRect: LONGINT;
                    nBottomRect: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] EnumFontFamiliesExA ( hdc: WD.HDC; VAR STATICTYPED lgf: LOGFONTA;
                                lpEnumFontFamExProc: FONTENUMPROCA; lParam: WD.LPARAM;
                                dwFlags: WD.DWORD ): LONGINT;
PROCEDURE [_APICALL] EnumFontFamiliesExW ( hdc: WD.HDC; VAR STATICTYPED lgf: LOGFONTW;
                                lpEnumFontFamExProc: FONTENUMPROCW; lParam: WD.LPARAM;
                                dwFlags: WD.DWORD ): LONGINT;
(* !  EnumFontFamiliesEx *)

PROCEDURE [_APICALL] EnumFontFamiliesA ( hdc: WD.HDC; lpszFamily: WD.LPCSTR; lpEnumFontFamProc: FONTENUMPROCA;
                              lParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] EnumFontFamiliesW ( hdc: WD.HDC; lpszFamily: WD.LPCWSTR;
                              lpEnumFontFamProc: FONTENUMPROCW; lParam: WD.LPARAM ): LONGINT;
(* ! EnumFontFamilies *)

PROCEDURE [_APICALL] EnumFontsA ( hdc: WD.HDC; lpFaceName: WD.LPCSTR; lpFontFunc: FONTENUMPROCA;
                       lParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] EnumFontsW ( hdc: WD.HDC; lpFaceName: WD.LPCWSTR; lpFontFunc: FONTENUMPROCW;
                       lParam: WD.LPARAM ): LONGINT;
(* !  EnumFonts  *)

PROCEDURE [_APICALL] EnumObjects ( hdc: WD.HDC; nObjectType: LONGINT; lpObjectFunc: GOBJENUMPROC;
                        lParam: WD.LPARAM ): LONGINT;

PROCEDURE [_APICALL] EqualRgn ( hSrcRgn1: WD.HRGN; hSrcRgn2: WD.HRGN ): WD.BOOL;

PROCEDURE [_APICALL] Escape ( hdc: WD.HDC; nEscape: LONGINT; cbInput: LONGINT; lpvInData: WD.LPCSTR;
                   lpvOutData: WD.LPVOID ): LONGINT;

PROCEDURE [_APICALL] ExtEscape ( hdc: WD.HDC; nEscape: LONGINT; cbInput: LONGINT;
                      lpszInData: WD.LPCSTR; cbOutput: LONGINT; lpszOutData: WD.LPSTR ): LONGINT;

PROCEDURE [_APICALL] ExcludeClipRect ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT;
                            nRightRect: LONGINT; nBottomRect: LONGINT ): LONGINT;

PROCEDURE [_APICALL] ExtCreateRegion ( VAR STATICTYPED xf: XFORM; nCount: WD.DWORD;
                            VAR STATICTYPED RgnData: RGNDATA ): WD.HRGN;

PROCEDURE [_APICALL] ExtFloodFill ( hdc: WD.HDC; nXStart: LONGINT; nYStart: LONGINT;
                         crColor: WD.COLORREF;
                         fuFillType: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] FillRgn ( hdc: WD.HDC; hrgn: WD.HRGN;
                    hbr: WD.HBRUSH ): WD.BOOL;

PROCEDURE [_APICALL] FloodFill ( hdc: WD.HDC; nXStart: LONGINT; nYStart: LONGINT;
                      crColor: WD.COLORREF ): WD.BOOL;

PROCEDURE [_APICALL] FrameRgn ( hdc: WD.HDC; hrgn: WD.HRGN;
                     hbr: WD.HBRUSH; nWidth: LONGINT;
                     nHeight: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetROP2 ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetAspectRatioFilterEx ( hdc: WD.HDC;
                                   VAR STATICTYPED lpAspectRatio: WD.SIZE ): WD.BOOL;

PROCEDURE [_APICALL] GetBkColor ( hdc: WD.HDC ): WD.COLORREF;

PROCEDURE [_APICALL] GetBkMode ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetBitmapBits ( hbmp: WD.HBITMAP; cbBuffer: LONGINT;
                          lpvBits: WD.LPVOID ): LONGINT;

PROCEDURE [_APICALL] GetBitmapDimensionEx ( hbmp: WD.HBITMAP;
                                 VAR STATICTYPED lpDimension: WD.SIZE ): WD.BOOL;

PROCEDURE [_APICALL] GetBoundsRect ( hdc: WD.HDC; VAR STATICTYPED rcBounds: WD.RECT;
                          flags: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] GetBrushOrgEx ( hdc: WD.HDC;
                          VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] GetCharWidthA ( hdc: WD.HDC; iFirstChar: WD.UINT;
                          iLastChar: WD.UINT;
                          VAR lpBuffer: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] GetCharWidthW ( hdc: WD.HDC; iFirstChar: WD.UINT;
                          iLastChar: WD.UINT;
                          VAR lpBuffer: LONGINT ): WD.BOOL;
(* !  GetCharWidth *)

PROCEDURE [_APICALL] GetCharWidth32A ( hdc: WD.HDC; iFirstChar: WD.UINT;
                            iLastChar: WD.UINT;
                            VAR lpBuffer: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] GetCharWidth32W ( hdc: WD.HDC; iFirstChar: WD.UINT;
                            iLastChar: WD.UINT;
                            VAR lpBuffer: LONGINT ): WD.BOOL;
(* ! GetCharWidth32 *)

PROCEDURE [_APICALL] GetCharWidthFloatA ( hdc: WD.HDC; iFirstChar: WD.UINT;
                               iLastChar: WD.UINT;
                               VAR pxBuffer: REAL ): WD.BOOL;
PROCEDURE [_APICALL] GetCharWidthFloatW ( hdc: WD.HDC; iFirstChar: WD.UINT;
                               iLastChar: WD.UINT;
                               VAR pxBuffer: REAL ): WD.BOOL;
(* !  GetCharWidthFloat *)

PROCEDURE [_APICALL] GetCharABCWidthsA ( hdc: WD.HDC; iFirstChar: WD.UINT;
                              iLastChar: WD.UINT; VAR STATICTYPED lpabc: ABC ): WD.BOOL;
PROCEDURE [_APICALL] GetCharABCWidthsW ( hdc: WD.HDC; iFirstChar: WD.UINT;
                              iLastChar: WD.UINT; VAR STATICTYPED lpabc: ABC ): WD.BOOL;
(* ! GetCharABCWidths *)

PROCEDURE [_APICALL] GetCharABCWidthsFloatA ( hdc: WD.HDC; iFirstChar: WD.UINT;
                                   iLastChar: WD.UINT;
                                   VAR STATICTYPED lpabcf: ABCFLOAT ): WD.BOOL;
PROCEDURE [_APICALL] GetCharABCWidthsFloatW ( hdc: WD.HDC; iFirstChar: WD.UINT;
                                   iLastChar: WD.UINT;
                                   VAR STATICTYPED lpabcf: ABCFLOAT ): WD.BOOL;
(* ! GetCharABCWidthsFloat *)

PROCEDURE [_APICALL] GetClipBox ( hdc: WD.HDC; VAR STATICTYPED rc: WD.RECT ): LONGINT;

PROCEDURE [_APICALL] GetClipRgn ( hdc: WD.HDC; hrgn: WD.HRGN ): LONGINT;

PROCEDURE [_APICALL] GetMetaRgn ( hdc: WD.HDC; hrgn: WD.HRGN ): LONGINT;

PROCEDURE [_APICALL] GetCurrentObject ( hdc: WD.HDC; uObjectType: WD.UINT ): WD.HGDIOBJ;

PROCEDURE [_APICALL] GetCurrentPositionEx ( hdc: WD.HDC; VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] GetDeviceCaps ( hdc: WD.HDC; nIndex: LONGINT ): LONGINT;

PROCEDURE [_APICALL] GetDIBits ( hdc: WD.HDC; hbmp: WD.HBITMAP;
                      uStartScan: WD.UINT; cScanLines: WD.UINT;
                      lpvBits: WD.LPVOID; VAR STATICTYPED bmi: BITMAPINFO;
                      uUsage: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] GetFontData ( hdc: WD.HDC; dwTable: WD.DWORD;
                        dwOffset: WD.DWORD; lpvBuffer: WD.LPVOID;
                        cbData: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] GetGlyphOutlineA ( hdc: WD.HDC; uChar: WD.UINT;
                             uFormat: WD.UINT; VAR STATICTYPED gm: GLYPHMETRICS;
                             cbBuffer: WD.DWORD; lpvBuffer: WD.LPVOID;
                             VAR STATICTYPED mat2: MAT2 ): WD.DWORD;
PROCEDURE [_APICALL] GetGlyphOutlineW ( hdc: WD.HDC; uChar: WD.UINT;
                             uFormat: WD.UINT; VAR STATICTYPED gm: GLYPHMETRICS;
                             cbBuffer: WD.DWORD; lpvBuffer: WD.LPVOID;
                             VAR STATICTYPED mat2: MAT2 ): WD.DWORD;
(* ! GetGlyphOutline *)

PROCEDURE [_APICALL] GetGraphicsMode ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetMapMode ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetMetaFileBitsEx ( hmf: WD.HMETAFILE; nSize: WD.UINT;
                              lpvData: WD.LPVOID ): WD.UINT;

PROCEDURE [_APICALL] GetMetaFileA ( lpszFile: WD.LPCSTR ): WD.HMETAFILE;
PROCEDURE [_APICALL] GetMetaFileW ( lpszFile: WD.LPCWSTR ): WD.HMETAFILE;
(*  !  GetMetaFile *)

PROCEDURE [_APICALL] GetNearestColor ( hdc: WD.HDC; crColor: WD.COLORREF ): WD.COLORREF;

PROCEDURE [_APICALL] GetNearestPaletteIndex ( hpal: WD.HPALETTE; crColor: WD.COLORREF ): WD.UINT;

PROCEDURE [_APICALL] GetObjectType ( h: WD.HGDIOBJ ): WD.DWORD;

PROCEDURE [_APICALL] GetOutlineTextMetricsA ( hdc: WD.HDC; cbData: WD.UINT;
                                   VAR STATICTYPED otm: OUTLINETEXTMETRICA ): WD.UINT;
PROCEDURE [_APICALL] GetOutlineTextMetricsW ( hdc: WD.HDC; cbData: WD.UINT;
                                   VAR STATICTYPED otm: OUTLINETEXTMETRICW ): WD.UINT;
(*  !  GetOutlineTextMetrics *)

PROCEDURE [_APICALL] GetPaletteEntries ( hpal: WD.HPALETTE; iStartIndex: WD.UINT;
                              nEntries: WD.UINT;
                              VAR STATICTYPED pe: PALETTEENTRY ): WD.UINT;

PROCEDURE [_APICALL] GetPixel ( hdc: WD.HDC; nXPos: LONGINT;
                     nYPos: LONGINT ): WD.COLORREF;

PROCEDURE [_APICALL] GetPixelFormat ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetPolyFillMode ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetRasterizerCaps ( VAR STATICTYPED rrs: RASTERIZER_STATUS;
                              cb: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetRegionData ( hrgn: WD.HRGN; dwCount: WD.DWORD;
                          VAR STATICTYPED rgndata: RGNDATA ): WD.DWORD;

PROCEDURE [_APICALL] GetRgnBox ( hrgn: WD.HRGN; VAR STATICTYPED rc: WD.RECT ): LONGINT;

PROCEDURE [_APICALL] GetStockObject ( fnObject: LONGINT ): WD.HGDIOBJ;

PROCEDURE [_APICALL] GetStretchBltMode ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetSystemPaletteEntries ( hdc: WD.HDC; iStartIndex: WD.UINT;
                                    nEntries: WD.UINT;
                                    VAR STATICTYPED pe: PALETTEENTRY ): WD.UINT;

PROCEDURE [_APICALL] GetSystemPaletteUse ( hdc: WD.HDC ): WD.UINT;

PROCEDURE [_APICALL] GetTextCharacterExtra ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetTextAlign ( hdc: WD.HDC ): WD.UINT;

PROCEDURE [_APICALL] GetTextColor ( hdc: WD.HDC ): WD.COLORREF;

PROCEDURE [_APICALL] GetTextExtentPointA ( hdc: WD.HDC; lpString: WD.LPCSTR; cbString: LONGINT;
                                VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
PROCEDURE [_APICALL] GetTextExtentPointW ( arghdc0: WD.HDC; lpString: WD.LPCWSTR; cbString: LONGINT;
                                VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
(*  !    GetTextExtentPoint *)

PROCEDURE [_APICALL] GetTextExtentPoint32A ( hdc: WD.HDC; lpString: WD.LPCSTR; cbString: LONGINT;
                                  VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
PROCEDURE [_APICALL] GetTextExtentPoint32W ( hdc: WD.HDC; lpString: WD.LPCWSTR; cbString: LONGINT;
                                  VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
(*  !  GetTextExtentPoint32 *)

PROCEDURE [_APICALL] GetTextExtentExPointA ( hdc: WD.HDC; lpszStr: WD.LPCSTR; cchString: LONGINT;
                                  nMaxExtent: LONGINT; VAR lpnFit: LONGINT;
                                  VAR alpDx: LONGINT;
                                  VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
PROCEDURE [_APICALL] GetTextExtentExPointW ( hdc: WD.HDC; lpszStr: WD.LPCWSTR; cchString: LONGINT;
                                  nMaxExtent: LONGINT; VAR lpnFit: LONGINT;
                                  VAR alpDx: LONGINT;
                                  VAR STATICTYPED size: WD.SIZE ): WD.BOOL;
(*  !  GetTextExtentExPoint *)

PROCEDURE [_APICALL] GetTextCharset ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetTextCharsetInfo ( hdc: WD.HDC; VAR STATICTYPED Sig: FONTSIGNATURE;
                               dwFlags: WD.DWORD ): LONGINT;

PROCEDURE [_APICALL] TranslateCharsetInfo ( VAR Src: WD.DWORD; 
                 VAR STATICTYPED Cs: CHARSETINFO;
                                 dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetFontLanguageInfo ( hdc: WD.HDC ): WD.DWORD;

PROCEDURE [_APICALL] GetCharacterPlacementA ( hdc: WD.HDC; lpString: WD.LPCSTR; nCount: LONGINT;
                                   nMaxExtent: LONGINT; VAR STATICTYPED Results: GCP_RESULTSA;
                                   dwFlags: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetCharacterPlacementW ( hdc: WD.HDC; lpString: WD.LPCWSTR; nCount: LONGINT;
                                   nMaxExtent: LONGINT; VAR STATICTYPED Results: GCP_RESULTSW;
                                   dwFlags: WD.DWORD ): WD.DWORD;
(*  !  GetCharacterPlacement *)

PROCEDURE [_APICALL] GetViewportExtEx ( hdc: WD.HDC;
                             VAR STATICTYPED size: WD.SIZE ): WD.BOOL;

PROCEDURE [_APICALL] GetViewportOrgEx ( hdc: WD.HDC;
                             VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowExtEx ( hdc: WD.HDC;
                           VAR STATICTYPED size: WD.SIZE ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowOrgEx ( hdc: WD.HDC;
                           VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] IntersectClipRect ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT;
                              nRightRect: LONGINT; nBottomRect: LONGINT ): LONGINT;

PROCEDURE [_APICALL] InvertRgn ( hdc: WD.HDC; hrgn: WD.HRGN ): WD.BOOL;

PROCEDURE [_APICALL] LineDDA ( nXStart: LONGINT; nYStart: LONGINT; nXEnd: LONGINT; nYEnd: LONGINT;
                    lpLineFunc: LINEDDAPROC; lpData: WD.LPARAM ): WD.BOOL;

PROCEDURE [_APICALL] LineTo ( hdc: WD.HDC; nXEnd: LONGINT;
                   nYEnd: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] MaskBlt ( hdcDest: WD.HDC; nXDest: LONGINT; nYDest: LONGINT; nWidth: LONGINT;
                    nHeight: LONGINT; hdcSrc: WD.HDC; nXSrc: LONGINT; nYSrc: LONGINT;
                    hbmask: WD.HBITMAP; xMask: LONGINT; yMask: LONGINT;
                    dwRop: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PlgBlt ( hdcdest: WD.HDC; VAR STATICTYPED pt: WD.POINT;
                   hdcsrc: WD.HDC; nXSrc: LONGINT; nYSrc: LONGINT; nWidth: LONGINT;
                   nHeight: LONGINT; hbmmask: WD.HBITMAP; xMask: LONGINT;
                   yMask: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] OffsetClipRgn ( hdc: WD.HDC; nXOffset: LONGINT;
                          nYOffset: LONGINT ): LONGINT;

PROCEDURE [_APICALL] OffsetRgn ( hrgn: WD.HRGN; nXOffset: LONGINT; nYOffset: LONGINT ): LONGINT;

PROCEDURE [_APICALL] PatBlt ( hdc: WD.HDC; nXLeft: LONGINT; nYLeft: LONGINT; nWidth: LONGINT;
                   nHeight: LONGINT; dwRop: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] Pie ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT; nRightRect: LONGINT;
                nBottomRect: LONGINT; nXRadial1: LONGINT; nYRadial1: LONGINT; nXRadial2: LONGINT;
                nYRadial2: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] PlayMetaFile ( hdc: WD.HDC;
                         hmf: WD.HMETAFILE ): WD.BOOL;

PROCEDURE [_APICALL] PaintRgn ( hdc: WD.HDC; hrgn: WD.HRGN ): WD.BOOL;

PROCEDURE [_APICALL] PolyPolygon ( hdc: WD.HDC; VAR STATICTYPED pt: WD.POINT;
                        VAR lpPolyCounts: LONGINT; nCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] PtInRegion ( hrgn: WD.HRGN; X: LONGINT;
                       Y: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] PtVisible ( hdc: WD.HDC; X: LONGINT;
                      Y: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] RectInRegion ( hrgn: WD.HRGN;
                         VAR STATICTYPED rc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] RectVisible ( hdc: WD.HDC;
                        VAR STATICTYPED rc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] Rectangle ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT;
                      nRightRect: LONGINT; nBottomRect: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] RestoreDC ( hdc: WD.HDC; nSavedDC: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ResetDCA ( hdc: WD.HDC; VAR STATICTYPED dm: DEVMODEA ): WD.HDC;
PROCEDURE [_APICALL] ResetDCW ( hdc: WD.HDC; VAR STATICTYPED dm: DEVMODEW ): WD.HDC;
(* !  ResetDC *)
PROCEDURE [_APICALL] RealizePalette ( hdc: WD.HDC ): WD.UINT;

PROCEDURE [_APICALL] RemoveFontResourceA ( lpFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] RemoveFontResourceW ( lpFileName: WD.LPCWSTR ): WD.BOOL;
(*  !  RemoveFontResource *)

PROCEDURE [_APICALL] RoundRect ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT;
                      nRightRect: LONGINT; nBottomRect: LONGINT; nWidth: LONGINT;
                      nHeight: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ResizePalette ( hpal: WD.HPALETTE;
                          nEntries: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] SaveDC ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] SelectClipRgn ( hdc: WD.HDC; hrgn: WD.HRGN ): LONGINT;

PROCEDURE [_APICALL] ExtSelectClipRgn ( hdc: WD.HDC; hrgn: WD.HRGN;
                             fnMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetMetaRgn ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] SelectObject ( hdc: WD.HDC;
                         hobject: WD.HGDIOBJ ): WD.HGDIOBJ;

PROCEDURE [_APICALL] SelectPalette ( hdc: WD.HDC; hpal: WD.HPALETTE;
                          bForceBackground: WD.BOOL ): WD.HPALETTE;

PROCEDURE [_APICALL] SetBkColor ( hdc: WD.HDC;
                       crColor: WD.COLORREF ): WD.COLORREF;

PROCEDURE [_APICALL] SetBkMode ( hdc: WD.HDC; iBkMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetBitmapBits ( hbmp: WD.HBITMAP; cBytes: WD.DWORD;
                          lpBits: WD.LPVOID ): LONGINT;

PROCEDURE [_APICALL] SetBoundsRect ( hdc: WD.HDC; VAR STATICTYPED rcBounds: WD.RECT;
                          flags: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] SetDIBits ( hdc: WD.HDC; hbmp: WD.HBITMAP;
                      uStartScan: WD.UINT; cScanLines: WD.UINT;
                      lpvBits: WD.LPVOID; VAR STATICTYPED bmi: BITMAPINFO;
                      fuColorUse: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] SetDIBitsToDevice ( hdc: WD.HDC; XDest: LONGINT; YDest: LONGINT;
                              dwWidth: WD.DWORD; dwHeight: WD.DWORD;
                              XSrc: LONGINT; YSrc: LONGINT; uStartScan: WD.UINT;
                              cScanLines: WD.UINT; lpvBits: WD.LPVOID;
                              VAR STATICTYPED bmi: BITMAPINFO; fuColorUse: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] SetMapperFlags ( hdc: WD.HDC;
                           dwFlag: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetGraphicsMode ( hdc: WD.HDC; iMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetMapMode ( hdc: WD.HDC; fnMapMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetMetaFileBitsEx ( nSize: WD.UINT;
                              VAR Data: WD.BYTE ): WD.HMETAFILE;

PROCEDURE [_APICALL] SetPaletteEntries ( hpal: WD.HPALETTE; iStart: WD.UINT;
                              cEntries: WD.UINT;
                              VAR STATICTYPED pe: PALETTEENTRY ): WD.UINT;

PROCEDURE [_APICALL] SetPixel ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                     crColor: WD.COLORREF ): WD.COLORREF;

PROCEDURE [_APICALL] SetPixelV ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                      crColor: WD.COLORREF ): WD.BOOL;

PROCEDURE [_APICALL] SetPixelFormat ( hdc: WD.HDC; iPixelFormat: LONGINT;
                           VAR STATICTYPED pfdc: PIXELFORMATDESCRIPTOR ): WD.BOOL;

PROCEDURE [_APICALL] SetPolyFillMode ( hdc: WD.HDC; iPolyFillMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] StretchBlt ( hdcDest: WD.HDC; nXOriginDest: LONGINT; nYOriginDest: LONGINT;
                       nWidthDest: LONGINT; nHeightDest: LONGINT; hdcSrc: WD.HDC;
                       nXOriginSrc: LONGINT; nYOriginSrc: LONGINT; nWidthSrc: LONGINT; nHeightSrc: LONGINT;
                       dwRop: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetRectRgn ( hrgn: WD.HRGN; nLeftRect: LONGINT; nTopRect: LONGINT;
                       nRightRect: LONGINT; nBottomRect: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] StretchDIBits ( hdc: WD.HDC; XDest: LONGINT; YDest: LONGINT;
                          nDestWidth: LONGINT; nDestHeight: LONGINT; XSrc: LONGINT; YSrc: LONGINT;
                          nSrcWidth: LONGINT; nSrcHeight: LONGINT; lpBits: WD.LPVOID;
                          VAR STATICTYPED bmi: BITMAPINFO; iUsage: WD.UINT;
                          dwRop: WD.DWORD ): LONGINT;

PROCEDURE [_APICALL] SetROP2 ( hdc: WD.HDC; fnDrawMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetStretchBltMode ( hdc: WD.HDC; iStretchMode: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetSystemPaletteUse ( hdc: WD.HDC; uUsage: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] SetTextCharacterExtra ( hdc: WD.HDC; nCharExtra: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetTextColor ( hdc: WD.HDC; crColor: WD.COLORREF ): WD.COLORREF;

PROCEDURE [_APICALL] SetTextAlign ( hdc: WD.HDC; fMode: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] SetTextJustification ( hdc: WD.HDC; nBreakExtra: LONGINT;
                                 nBreakCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] UpdateColors ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] PlayMetaFileRecord ( hdc: WD.HDC; VAR STATICTYPED ht: HANDLETABLE;
                               VAR STATICTYPED mr: METARECORD;
                               nHandles: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] EnumMetaFile ( hdc: WD.HDC; hmf: WD.HMETAFILE;
                         lpMetaFunc: MFENUMPROC; lParam: WD.LPARAM ): WD.BOOL;


(*  Enhanced Metafile Function Declarations *)

PROCEDURE [_APICALL] CloseEnhMetaFile ( hdc: WD.HDC ): WD.HENHMETAFILE;

PROCEDURE [_APICALL] CopyEnhMetaFileA ( hemfSrc: WD.HENHMETAFILE;
                             lpszFile: WD.LPCSTR ): WD.HENHMETAFILE;
PROCEDURE [_APICALL] CopyEnhMetaFileW ( hemfSrc: WD.HENHMETAFILE;
                             lpszFile: WD.LPCWSTR ): WD.HENHMETAFILE;
(*  ! CopyEnhMetaFile *)

PROCEDURE [_APICALL] CreateEnhMetaFileA ( hdc: WD.HDC; lpFilename: WD.LPCSTR;
                               VAR STATICTYPED rc: WD.RECT; lpDescription: WD.LPCSTR ): WD.HDC;
PROCEDURE [_APICALL] CreateEnhMetaFileW ( hdc: WD.HDC; lpFilename: WD.LPCWSTR;
                               VAR STATICTYPED rc: WD.RECT; lpDescription: WD.LPCWSTR ): WD.HDC;
(*  !  CreateEnhMetaFile *)

PROCEDURE [_APICALL] DeleteEnhMetaFile ( hemf: WD.HENHMETAFILE ): WD.BOOL;

PROCEDURE [_APICALL] EnumEnhMetaFile ( hdc: WD.HDC; hemf: WD.HENHMETAFILE;
                            lpEnhMetaFunc: ENHMFENUMPROC; lpData: WD.LPVOID;
                            VAR STATICTYPED Rect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] GetEnhMetaFileA ( lpszMetaFile: WD.LPCSTR ): WD.HENHMETAFILE;
PROCEDURE [_APICALL] GetEnhMetaFileW ( lpszMetaFile: WD.LPCWSTR ): WD.HENHMETAFILE;
(*  !  GetEnhMetaFile *)

PROCEDURE [_APICALL] GetEnhMetaFileBits ( hemf: WD.HENHMETAFILE; cbBuffer: WD.UINT;
                               VAR bBuffer: WD.BYTE ): WD.UINT;

PROCEDURE [_APICALL] GetEnhMetaFileDescriptionA ( hemf: WD.HENHMETAFILE;
                                       cchBuffer: WD.UINT;
                                       lpszDescription: WD.LPSTR ): WD.UINT;
PROCEDURE [_APICALL] GetEnhMetaFileDescriptionW ( hemf: WD.HENHMETAFILE;
                                       cchBuffer: WD.UINT;
                                       lpszDescription: WD.LPWSTR ): WD.UINT;
(*  ! GetEnhMetaFileDescription *)

PROCEDURE [_APICALL] GetEnhMetaFileHeader ( hemf: WD.HENHMETAFILE; cbBuffer: WD.UINT;
                                 VAR STATICTYPED emh: ENHMETAHEADER ): WD.UINT;

PROCEDURE [_APICALL] GetEnhMetaFilePaletteEntries ( hemf: WD.HENHMETAFILE;
                                         cEntries: WD.UINT;
                                         VAR STATICTYPED pe: PALETTEENTRY ): WD.UINT;

PROCEDURE [_APICALL] GetWinMetaFileBits ( hemf: WD.HENHMETAFILE; cbBuffer: WD.UINT;
                               VAR bBuffer: WD.BYTE; fnMapMode: LONGINT;
                               hdcRef: WD.HDC ): WD.UINT;

PROCEDURE [_APICALL] PlayEnhMetaFile ( hdc: WD.HDC; hemf: WD.HENHMETAFILE;
                            VAR STATICTYPED rc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] PlayEnhMetaFileRecord ( hdc: WD.HDC; VAR STATICTYPED ht: HANDLETABLE;
                                  VAR STATICTYPED ehmr: ENHMETARECORD;
                                  nHandles: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] SetEnhMetaFileBits ( cbBuffer: WD.UINT;
                               VAR data: WD.UCHAR ): WD.HENHMETAFILE;

PROCEDURE [_APICALL] SetWinMetaFileBits ( cbBuffer: WD.UINT; VAR bBuffer: WD.BOOL;
                               hdcRef: WD.HDC;
                               VAR STATICTYPED mfp: METAFILEPICT ): WD.HENHMETAFILE;

PROCEDURE [_APICALL] GdiComment ( hdc: WD.HDC; cbSize: WD.UINT;
                       VAR data: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetTextMetricsA ( hdc: WD.HDC;
                            VAR STATICTYPED tm: TEXTMETRICA ): WD.BOOL;
PROCEDURE [_APICALL] GetTextMetricsW ( hdc: WD.HDC;
                            VAR STATICTYPED tm: TEXTMETRICW ): WD.BOOL;
(*  !  GetTextMetrics *)

(*  new GDI  *)

PROCEDURE [_APICALL] AngleArc ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                     dwRadius: WD.DWORD; eStartAngle: REAL;
                     eSweepAngle: REAL ): WD.BOOL;

PROCEDURE [_APICALL] PolyPolyline ( hdc: WD.HDC; VAR STATICTYPED pt: WD.POINT;
                         VAR dwPolyPoints: WD.DWORD;
                         cCount: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetWorldTransform ( hdc: WD.HDC; VAR STATICTYPED xf: XFORM ): WD.BOOL;

PROCEDURE [_APICALL] SetWorldTransform ( hdc: WD.HDC; VAR STATICTYPED xf: XFORM ): WD.BOOL;

PROCEDURE [_APICALL] ModifyWorldTransform ( hdc: WD.HDC; VAR STATICTYPED xf: XFORM;
                                 iMode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] CombineTransform ( VAR STATICTYPED lpxformResult: XFORM; 
                             VAR STATICTYPED xf1: XFORM;
                             VAR STATICTYPED xf2: XFORM ): WD.BOOL;

PROCEDURE [_APICALL] CreateDIBSection ( hdc: WD.HDC; VAR STATICTYPED bmi: BITMAPINFO;
                             iUsage: WD.UINT; ppvBits: WD.LPVOID;
                             hSection: WD.HANDLE;
                             dwOffset: WD.DWORD ): WD.HBITMAP;

PROCEDURE [_APICALL] GetDIBColorTable ( hdc: WD.HDC; uStartIndex: WD.UINT;
                             cEntries: WD.UINT;
                             VAR STATICTYPED colors: RGBQUAD ): WD.UINT;

PROCEDURE [_APICALL] SetDIBColorTable ( hdc: WD.HDC; uStartIndex: WD.UINT;
                             cEntries: WD.UINT;
                             VAR STATICTYPED colors: RGBQUAD ): WD.UINT;

PROCEDURE [_APICALL] SetColorAdjustment ( hdc: WD.HDC;
                               VAR STATICTYPED ca: COLORADJUSTMENT ): WD.BOOL;

PROCEDURE [_APICALL] GetColorAdjustment ( hdc: WD.HDC;
                               VAR STATICTYPED ca: COLORADJUSTMENT ): WD.BOOL;

PROCEDURE [_APICALL] CreateHalftonePalette ( hdc: WD.HDC ): WD.HPALETTE;

PROCEDURE [_APICALL] StartDocA ( hdc: WD.HDC; VAR STATICTYPED di: DOCINFOA ): LONGINT;
PROCEDURE [_APICALL] StartDocW ( hdc: WD.HDC; VAR STATICTYPED di: DOCINFOA ): LONGINT;
(*  !   StartDoc *)

PROCEDURE [_APICALL] EndDoc ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] StartPage ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] EndPage ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] AbortDoc ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] SetAbortProc ( hdc: WD.HDC; lpAbortProc: ABORTPROC ): LONGINT;

PROCEDURE [_APICALL] AbortPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] ArcTo ( hdc: WD.HDC; nLeftRect: LONGINT; nTopRect: LONGINT; nRightRect: LONGINT;
                  nBottomRect: LONGINT; nXRadial1: LONGINT; nYRadial1: LONGINT; nXRadial2: LONGINT;
                  nYRadial2: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] BeginPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] CloseFigure ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] EndPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] FillPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] FlattenPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] GetPath ( hdc: WD.HDC; VAR STATICTYPED pt: WD.POINT;
                    VAR Types: WD.BYTE; nSize: LONGINT ): LONGINT;

PROCEDURE [_APICALL] PathToRegion ( hdc: WD.HDC ): WD.HRGN;

PROCEDURE [_APICALL] PolyDraw ( hdc: WD.HDC; VAR STATICTYPED pt: WD.POINT;
                     VAR bTypes: WD.BOOL; cCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SelectClipPath ( hdc: WD.HDC; nMode: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetArcDirection ( hdc: WD.HDC; ArcDirection: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetMiterLimit ( hdc: WD.HDC; eNewLimit: REAL;
                          VAR peOldLimit: REAL ): WD.BOOL;

PROCEDURE [_APICALL] StrokeAndFillPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] StrokePath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] WidenPath ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] ExtCreatePen ( dwPenStyle: WD.DWORD; dwWidth: WD.DWORD;
                         VAR STATICTYPED lgbr: LOGBRUSH; dwStyleCount: WD.DWORD;
                         VAR Style: WD.DWORD ): WD.HPEN;

PROCEDURE [_APICALL] GetMiterLimit ( hdc: WD.HDC;
                          VAR eLimit: REAL ): WD.BOOL;

PROCEDURE [_APICALL] GetArcDirection ( hdc: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] GetObjectA ( hobject: WD.HGDIOBJ; cbBuffer: LONGINT;
                       lpvObject: WD.LPVOID ): LONGINT;
PROCEDURE [_APICALL] GetObjectW ( hobject: WD.HGDIOBJ; cbBuffer: LONGINT;
                       lpvObject: WD.LPVOID ): LONGINT;
(*  ! GetObject *)

PROCEDURE [_APICALL] MoveToEx ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                     VAR STATICTYPED point:WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] TextOutA ( hdc: WD.HDC; nXStart: LONGINT; nYStart: LONGINT; lpString: WD.LPCSTR;
                     cbString: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] TextOutW ( hdc: WD.HDC; nXStart: LONGINT; nYStart: LONGINT;
                     lpString: WD.LPCWSTR; cbString: LONGINT ): WD.BOOL;
(* !   TextOut *)

PROCEDURE [_APICALL] ExtTextOutA ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                        fuOptions: WD.UINT; VAR STATICTYPED rc: WD.RECT; lpString: WD.LPCSTR;
                        cbCount: WD.UINT;
                        lpDx: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] ExtTextOutW ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                        fuOptions: WD.UINT; VAR STATICTYPED rc: WD.RECT; lpString: WD.LPCWSTR;
                        cbCount: WD.UINT;
                        lpDx: LONGINT ): WD.BOOL;
(*  !   ExtTextOut *)

PROCEDURE [_APICALL] PolyTextOutA ( hdc: WD.HDC; VAR STATICTYPED pt: POLYTEXTA;
                         cStrings: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] PolyTextOutW ( hdc: WD.HDC; VAR STATICTYPED pt: POLYTEXTW;
                         cStrings: LONGINT ): WD.BOOL;
(*  !   PolyTextOut *)

PROCEDURE [_APICALL] CreatePolygonRgn ( VAR STATICTYPED pt: WD.POINT; cPoints: LONGINT;
                             fnPolyFillMode: LONGINT ): WD.HRGN;

PROCEDURE [_APICALL] DPtoLP ( hdc: WD.HDC; lpp: LONGINT;
                   nCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] LPtoDP ( hdc: WD.HDC; lpp: LONGINT;
                   nCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] Polygon ( hdc: WD.HDC; lpPoints: LONGINT;
                    nCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] Polyline ( hdc: WD.HDC; lpPoints: LONGINT;
                     cPoints: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] PolyBezier ( hdc: WD.HDC; lpPoints: LONGINT;
                       cPoints: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PolyBezierTo ( hdc: WD.HDC; lpPoints: LONGINT;
                         cCount: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PolylineTo ( hdc: WD.HDC; lpPoints: LONGINT;
                       cCount: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetViewportExtEx ( hdc: WD.HDC; nXExtent: LONGINT; nYExtent: LONGINT;
                             lpsize: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetViewportOrgEx ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                             lpp: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowExtEx ( hdc: WD.HDC; nXExtent: LONGINT; nYExtent: LONGINT;
                           lpsize: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowOrgEx ( hdc: WD.HDC; X: LONGINT; Y: LONGINT;
                           lpp: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] OffsetViewportOrgEx ( hdc: WD.HDC; nXOffset: LONGINT; nYOffset: LONGINT;
                                lpp: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] OffsetWindowOrgEx ( hdc: WD.HDC; nXOffset: LONGINT; nYOffset: LONGINT;
                              lpp: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ScaleViewportExtEx ( hdc: WD.HDC; Xnum: LONGINT; Xdenom: LONGINT;
                               Ynum: LONGINT; Ydenom: LONGINT;
                               lpsize: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ScaleWindowExtEx ( hdc: WD.HDC; Xnum: LONGINT; Xdenom: LONGINT;
                             Ynum: LONGINT; Ydenom: LONGINT;
                             lpsize: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetBitmapDimensionEx ( hbmp: WD.HBITMAP; nWidth: LONGINT;
                                 nHeight: LONGINT;
                                 lpsize: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetBrushOrgEx ( hdc: WD.HDC; nXOrg: LONGINT; nYOrg: LONGINT;
                          lpp: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetTextFaceA ( hdc: WD.HDC; nCount: LONGINT; lpFaceName: WD.LPSTR ): LONGINT;
PROCEDURE [_APICALL] GetTextFaceW ( hdc: WD.HDC; nCount: LONGINT; lpFaceName: WD.LPWSTR ): LONGINT;
(* !  GetTextFace *)



PROCEDURE [_APICALL] GetKerningPairsA ( hdc: WD.HDC; nNumPairs: WD.DWORD;
                             VAR STATICTYPED lpkp: KERNINGPAIR ): WD.DWORD;
PROCEDURE [_APICALL] GetKerningPairsW ( hdc: WD.HDC; nNumPairs: WD.DWORD;
                             VAR STATICTYPED lpkp: KERNINGPAIR ): WD.DWORD;
(*  !   GetKerningPairs *)

PROCEDURE [_APICALL] GetDCOrgEx ( hdc: WD.HDC;
                       VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] FixBrushOrgEx ( hdc: WD.HDC; nXOrg: LONGINT; nYOrg: LONGINT;
                          VAR STATICTYPED pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] UnrealizeObject ( hobject: WD.HGDIOBJ ): WD.BOOL;

PROCEDURE [_APICALL] GdiFlush (): WD.BOOL;

PROCEDURE [_APICALL] GdiSetBatchLimit ( dwLimit: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] GdiGetBatchLimit (): WD.DWORD;


PROCEDURE [_APICALL] SetICMMode ( hdc: WD.HDC; fICM: LONGINT ): LONGINT;

PROCEDURE [_APICALL] CheckColorsInGamut ( hdc: WD.HDC; lpaRGBQuad: WD.LPVOID;
                               lpResult: WD.LPVOID;
                               nCount: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetColorSpace ( hdc: WD.HDC ): WD.HANDLE;

PROCEDURE [_APICALL] GetLogColorSpaceA ( hColorSpace: WD.HCOLORSPACE; 
                VAR STATICTYPED buffer: LOGCOLORSPACEA;
                              nSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetLogColorSpaceW ( hColorSpace: WD.HCOLORSPACE;
                VAR STATICTYPED buffer: LOGCOLORSPACEW;
                              nSize: WD.DWORD ): WD.BOOL;
(*  !  GetLogColorSpace *)

PROCEDURE [_APICALL] CreateColorSpaceA ( VAR STATICTYPED lplgcs: LOGCOLORSPACEA ): WD.HCOLORSPACE;
PROCEDURE [_APICALL] CreateColorSpaceW ( VAR STATICTYPED lplgcs: LOGCOLORSPACEW ): WD.HCOLORSPACE;
(*  !  CreateColorSpace *)

PROCEDURE [_APICALL] SetColorSpace ( hdc: WD.HDC;
                          hColorSpace: WD.HCOLORSPACE ): WD.BOOL;

PROCEDURE [_APICALL] DeleteColorSpace ( hColorSpace: WD.HCOLORSPACE ): WD.BOOL;

PROCEDURE [_APICALL] GetICMProfileA ( hdc: WD.HDC; VAR cbName: WD.DWORD;
                           lpszFilename: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] GetICMProfileW ( hdc: WD.HDC; VAR cbName: WD.DWORD;
                           lpszFilename: WD.LPWSTR ): WD.BOOL;
(*  !  GetICMProfile *)

PROCEDURE [_APICALL] SetICMProfileA ( hdc: WD.HDC; lpFileName: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetICMProfileW ( hdc: WD.HDC; lpFileName: WD.LPWSTR ): WD.BOOL;
(*  !   SetICMProfile *)

PROCEDURE [_APICALL] GetDeviceGammaRamp ( hdc: WD.HDC; lpRamp: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] SetDeviceGammaRamp ( hdc: WD.HDC; lpRamp: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] ColorMatchToTarget ( hdc: WD.HDC; hdcTarget: WD.HDC;
                               uiAction: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] UpdateICMRegKeyA ( dwReserved: WD.DWORD; CMID: WD.DWORD;
                             lpszFileName: WD.LPSTR; nCommand: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] UpdateICMRegKeyW ( dwReserved: WD.DWORD; CMID: WD.DWORD;
                             lpszFileName: WD.LPWSTR; nCommand: WD.UINT ): WD.BOOL;
(*  !   UpdateICMRegKey *)
PROCEDURE [_APICALL] EnumICMProfilesA ( hdc: WD.HDC; lpICMEnumFunc: ICMENUMPROCA;
                             lParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] EnumICMProfilesW ( hdc: WD.HDC; lpICMEnumFunc: ICMENUMPROCW;
                             lParam: WD.LPARAM ): LONGINT;
(*  !  EnumICMProfiles *)

PROCEDURE [_APICALL] wglCreateContext ( hdc: WD.HDC ): WD.HGLRC;

PROCEDURE [_APICALL] wglDeleteContext ( hglrc: WD.HGLRC ): WD.BOOL;

PROCEDURE [_APICALL] wglGetCurrentContext (  ): WD.HGLRC;

PROCEDURE [_APICALL] wglGetCurrentDC (  ): WD.HDC;

PROCEDURE [_APICALL] wglGetProcAddress ( lpszProc: WD.LPCSTR ): WD.PROC;

PROCEDURE [_APICALL] wglMakeCurrent ( hdc: WD.HDC;
                           hglrc: WD.HGLRC ): WD.BOOL;

PROCEDURE [_APICALL] wglShareLists ( hglrc1: WD.HGLRC;
                          hglrc2: WD.HGLRC ): WD.BOOL;

PROCEDURE [_APICALL] wglUseFontBitmapsA ( hdc: WD.HDC; first: WD.DWORD;
                               count: WD.DWORD;
                               listBase: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] wglUseFontBitmapsW ( hdc: WD.HDC; first: WD.DWORD;
                               count: WD.DWORD;
                               listBase: WD.DWORD ): WD.BOOL;
(*  ! wglUseFontBitmaps *)

PROCEDURE [_APICALL] SwapBuffers ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] wglUseFontOutlinesA ( hdc: WD.HDC; first: WD.DWORD;
                                count: WD.DWORD; listBase: WD.DWORD;
                                deviation: REAL;
                                extrusion: REAL; format: LONGINT;
                                VAR STATICTYPED gmf: GLYPHMETRICSFLOAT ): WD.BOOL;
PROCEDURE [_APICALL] wglUseFontOutlinesW ( hdc: WD.HDC; first: WD.DWORD;
                                count: WD.DWORD; listBase: WD.DWORD;
                                deviation: REAL;
                                extrusion: REAL; format: LONGINT;
                                VAR STATICTYPED gmf: GLYPHMETRICSFLOAT ): WD.BOOL;
(*  !   wglUseFontOutlines *)

PROCEDURE [_APICALL] wglCopyContext(hglrc1: WD.HGLRC; hglrc2: WD.HGLRC; i:WD.UINT):WD.BOOL;

PROCEDURE [_APICALL] wglCreateLayerContext(hdc:WD.HDC; i:LONGINT): WD.HGLRC;

PROCEDURE [_APICALL] wglDescribeLayerPlane(hdc:WD.HDC;i1: LONGINT;i2: LONGINT;i3: WD.UINT;
                     VAR STATICTYPED DESC: LAYERPLANEDESCRIPTOR):WD.BOOL;

PROCEDURE [_APICALL] wglSetLayerPaletteEntries(hdc:WD.HDC; i1:LONGINT; i2:LONGINT; 
            i3:LONGINT; VAR  colref: WD.COLORREF):LONGINT;

PROCEDURE [_APICALL] wglGetLayerPaletteEntries(hdc:WD.HDC; i1:LONGINT; i2:LONGINT; 
            i3:LONGINT;VAR  colref:WD.COLORREF):LONGINT;

PROCEDURE [_APICALL] wglRealizeLayerPalette(hdc:WD.HDC; i1:LONGINT; b:WD.BOOL):WD.BOOL;

PROCEDURE [_APICALL] wglSwapLayerBuffers(hdc:WD.HDC; i:WD.UINT):WD.BOOL;

END WinGDI.
