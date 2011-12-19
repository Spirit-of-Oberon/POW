#ifndef _INC_POW

/* for WIN32 generation */
#include "pow32.h"
#include "..\powsup\powsupp.h"

#ifndef _INC_WINDOWS
#include <windows.h>
#define _INC_WINDOWS
#endif

#ifdef CDECL
#undef CDECL
#endif
#define CDECL cdecl

/* dialog ids */

#define IDD_OK       1
#define IDD_CANCEL   2
#define IDD_HELP     3
#define IDD_SETUP    4
#define IDD_YES      5
#define IDD_NO       6

#define IDD_FILEOPEN    ID(200)
#define IDD_OPNPATH     201
#define IDD_OPNDUMMYLB  202
#define IDD_OPNFILESGRP 203
#define IDD_OPNFILES    204
#define IDD_OPNDIRSGRP  205
#define IDD_OPNDIRS     206
#define IDD_OPNTYPGRP   207
#define IDD_OPNTYPES    208
#define IDD_OPNDRVGRP   209
#define IDD_OPNDRIVES   210

#define IDD_ABOUT       ID(300)

#define IDD_FIND        ID(400)
#define IDD_FINDTEXT    401
#define IDD_FINDCASE    402
#define IDD_FINDWORD    403
#define IDD_FINDUP      404
#define IDD_FINDDOWN    405

#define IDD_REPLACE     ID(500)
#define IDD_REPLACESRC  501
#define IDD_REPLACEDST  502
#define IDD_REPLACECASE 503
#define IDD_REPLACEWORD 504
#define IDD_REPLACEALL  505
#define IDD_REPLACEUP   506
#define IDD_REPLACEDOWN 507

#define IDD_PRINT       ID(600)
#define IDD_PRINTDEVICE 601
#define IDD_PRINTPORT   602
#define IDD_PRINTTITLE  603

#define IDD_GOTOLINE    ID(700)
#define IDD_GOTONUMBER  701

#define IDD_RUNARG      ID(800)
#define IDD_RUNARGSGRP  801
#define IDD_RUNARGS     802

#define IDD_PROJECT     ID(1000)
#define IDD_PRJLISTGRP  10001
#define IDD_PRJLIST     10002
#define IDD_PRJADD      10003
#define IDD_PRJDEL      10004

#define IDD_TOOLS         ID(1300)
#define IDD_TOOLGRP       1301
#define IDD_TOOLLIST      1302
#define IDD_TOOLDEL       1303
#define IDD_TOOLUP        1304
#define IDD_TOOLDOWN      1305
#define IDD_TOOLTEXT1     1306
#define IDD_TOOLMENUTEXT  1307
#define IDD_TOOLARG       1308
#define IDD_TOOLTEXT2     1309
#define IDD_TOOLASK       1310
#define IDD_TOOLAUTOSTART 1320

#define IDD_TOOLSARG    ID(1400)
#define IDD_TARGARGSGRP 1401
#define IDD_TARGARGS    1402

#define IDD_GETPREFS     ID(1500)
#define IDD_PREFEDITGRP  1505
#define IDD_PREFEDITOR   1506
#define IDD_PREFMOUNOT   1507
#define IDD_PREFMOUTOPIC 1508
#define IDD_PREFCOMPGRP  1509
#define IDD_PREFCOMPILER 1510
#define IDD_PREFSAVEPRJ  1515
#define IDD_PREFSAVEDESK 1516
#define IDD_PREFSAVECFG  1517
#define IDD_PREFRIBBTOP  1518
#define IDD_PREFRIBBBOT  1519

#define IDD_CHANGEPRINTER ID(1700)
#define IDD_PRINTERLSTGRP 1701
#define IDD_PRINTERLIST   1702

#define IDD_OPENTEMPLATE  ID(2000)
#define IDD_TPLNEWPRJGRP  2001
#define IDD_TPLPROJ       2002
#define IDD_TPLNEWDIRGRP  2003
#define IDD_TPLSUBDIR     2004
#define IDD_TPLSOURCEDIR  2005

#define IDD_NEWPROJECT    ID(2100)
#define IDD_NEWPRJNAME    2101
#define IDD_NEWPRJDIR     2102
#define IDD_NEWPRJCREATE  2103
#define IDD_NEWPRJNEWDIR  2104
#define IDD_NEWPRJBROWSE  2105

#define IDD_CHOOSEDIR     ID(2200)

#define IDD_HALLOFFAME    ID(2300)
#define IDD_HALLLIST      2301

/* set text message for pow static */
#define PS_SETTEXT WM_USER+1

/* position of window menu */
#define WINDOWMENU 8

/* size of project and file history */
#define HISTORY 6

/* height of status bar */
#define STATHIGH 23

/* position of short version window menu */
#define SHORTMENU 2

/* this is due to an incompatibility to Win/NT:
   instead of scrolling the edit window to the caret automatically,
   there must be sent a message EM_SCROLLCARET, which is imitated here */
#define EMULATED_EM_SCROLLCARET (0xB7)

#define DEFFILESEARCH (LPSTR) "*.mod"
#define ALLFILES (LPSTR) "*.*"
#define MESSAGEWINDOW (LPSTR) "Messages"

#ifdef RC_INVOKED
#define ID(id) id
#else
#define ID(id) MAKEINTRESOURCE(id)
#endif

/* edit control identifier */
#define ID_EDIT 0xCAC

/* resource ID's */
#define IDPOW  ID(1)
#define IDPOW2 ID(3)
#define IDNOTE ID(2)

/* window word values for child windows */
#define GWL_HWNDEDIT     0
#define GWW_CHANGED      4
#define GWW_WORDWRAP     6
#define GWW_UNTITLED     8
#define GWW_EDITROW     10
#define GWW_EDITCOL     12
#define GWW_EDITWIN     14
#define CBWNDEXTRA      16


/* menu ID's */
#define IDM_TEMPLATEEMPTY     198  /* menu ID of entry "empty project..." in template popup */
#define IDM_TEMPLATEOTHER     199  /* menu ID of entry "other..." in template popup */
#define IDM_TEMPLATEPOPUP     200  /* first entry in template popup (File/New/Project...) */
#define IDM_TEMPLATEPOPUPLAST 299  /* last possible entry in template popup */

#define IDM_FILENEW     1001
#define IDM_FILEOPEN    1002
#define IDM_FILESAVE    1003
#define IDM_FILESAVEAS  1004
#define IDM_FILESAVEALL 1005
#define IDM_FILEPRINT   1006
#define IDM_FILESETUP   1007
#define IDM_FILEEXIT    1008
#define IDM_FILEMENU    1009
#define IDM_FILEHISTORY 1010     

#define IDM_FILEPRJOTHER 1500
#define IDM_FILEPRJFIRST 1501

#define IDM_EDITUNDO    2001
#define IDM_EDITREDO    2002
#define IDM_EDITCUT     2003
#define IDM_EDITCOPY    2004
#define IDM_EDITPASTE   2005
#define IDM_EDITCLEAR   2006
#define IDM_EDITTIME    2007
#define IDM_EDITWRAP    2008
#define IDM_EDITFONT    2009
#define IDM_EDITFIRST   IDM_EDITUNDO
#define IDM_EDITLAST    IDM_EDITFONT
                                 
#define IDM_SEARCHFIND           3001
#define IDM_SEARCHREPLACE        3002
#define IDM_SEARCHNEXT           3003
#define IDM_SEARCHGOTOLINE       3004
#define IDM_SEARCHFINDNEXTERR    3005
#define IDM_SEARCHFINDPREVERR    3006
#define IDM_SEARCHIGNOREWARNINGS 3007
#define IDM_SEARCHFIRST IDM_SEARCHFIND
#define IDM_SEARCHLAST  IDM_SEARCHIGNOREWARNINGS

#define IDM_RUNRUN      4001
#define IDM_RUNDEBUG    4002
#define IDM_RUNPARAM    4003

#define IDM_COMPCOMP      5001
#define IDM_COMPMAKE      5002
#define IDM_COMPBUILD     5003
#define IDM_COMPOPENPRJ   5004
#define IDM_COMPEDITPRJ   5005
#define IDM_COMPSAVEASPRJ 5006
#define IDM_COMPCLOSPRJ   5007
#define IDM_COMPINFO      5008
#define IDM_COMPFROMTEMP  5009
#define IDM_COMPSAVETEMP  5010
#define IDM_COMPLINK      5011
#define IDM_PRJHISTORY    5012

//#define IM_TOOLS        5
#define IDM_TOOLS       6000
#define IDM_TOOLSFIRST  6001
#define IDM_TOOLSLAST   6098
#define IDM_TOOLSOPT    6099

#define IDM_OPTEDIT     7000
#define IDM_OPTCOMP     7001
#define IDM_OPTLINK     7002
#define IDM_OPTPREF     7003
#define IDM_OPTDIR      7004
#define IDM_OPTOPEN     7005
#define IDM_OPTSAVE     7006
#define IDM_OPTSAVEAS   7007

#define IDM_WINDOWTILEHOR    8001
#define IDM_WINDOWTILEVER    8002
#define IDM_WINDOWCASCADE    8003
#define IDM_WINDOWICONS      8004
#define IDM_WINDOWCLOSEALL   8005
#define IDM_WINDOWCHILD      8100

#define IDM_HELPINDEX   9001
#define IDM_HELPTOPIC   9002
#define IDM_HELPCOMP    9003
#define IDM_HELPUSING   9004
#define IDM_HELPABOUT   9005
#define IDM_BUGREPORT   9006
#define IDM_HELPEDIT    9007

#define IDM_MINIMIZE    10900

/* strings */
#define IDS_CANTOPEN         1
#define IDS_CANTCREATE       2
#define IDS_ILLFNM           3
#define IDS_ADDEXT           4
#define IDS_CLOSESAVE        5
#define IDS_CANTFIND         6
#define IDS_HELPNOTAVAIL     7
#define IDS_ALREADYLOADED    8
#define IDS_NOTIMPLEMENTED   9
#define IDS_WRONGEXTENSION   10
#define IDS_CONTAINSWILD     11
#define IDS_WRONGPATH        12
#define IDS_CLIENTTITLE      13
#define IDS_UNTITLED         14
#define IDS_PRINTJOB         15
#define IDS_PRINTERROR       16
#define IDS_OVERWRITEFILE    17
#define IDS_OKTOREPLACE      18
#define IDS_PRINTABORTED     19
#define IDS_NOFILE           20
#define IDS_NOCOMPILER       21
#define IDS_CANTOPENDLL      22
#define IDS_CANTCOMPILE      23
#define IDS_NOPROJECT        24
#define IDS_CIRCULARDEPEND   25
#define IDS_STARTTEST        26
#define IDS_OPENTESTFILE     27
#define IDS_CANTREAD         28
#define IDS_NOCOMPHELP       29
#define IDS_OVERWRITEEXIST   30
#define IDS_FILETOOLARGE     31
#define IDS_NOPROG           32
#define IDS_CREATEPROJECT    33
#define IDS_CANTALLOCDEP     34
#define IDS_PROJECTCHANGED   35
#define IDS_REALLYDELETE     36
#define IDS_NOPROJECTFILE    37
#define IDS_STATERROR        38
#define IDS_UPTODATE         39
#define IDS_NOEXECUTABLE     40
#define IDS_NODLLFUNCTION    41
#define IDS_OVERWRITETPL     42

#define IDS_MENUFILENEW        43
#define IDS_MENUFILEOPEN       44 
#define IDS_MENUFILESAVE       45 
#define IDS_MENUFILESAVEAS     46 
#define IDS_MENUFILESAVEALL    47 
#define IDS_MENUFILEPRINT      48 
#define IDS_MENUFILESETUP      49 
#define IDS_MENUFILEEXIT       50 
#define IDS_MENUEDITUNDO       51 
#define IDS_MENUEDITREDO       52 
#define IDS_MENUEDITCUT        53 
#define IDS_MENUEDITCOPY       54 
#define IDS_MENUEDITPASTE      55 
#define IDS_MENUEDITCLEAR      56 
#define IDS_MENUSEARCHFIND     57 
#define IDS_MENUSEARCHREPLACE  58  
#define IDS_MENUSEARCHNEXT     59  
#define IDS_MENUSEARCHGOTOLINE 60 
#define IDS_MENUSEARCHFINDNEXTERR 61 
#define IDS_MENUSEARCHFINDPREVERR 62 
#define IDS_MENURUNRUN         63   
#define IDS_MENURUNDEBUG       64   
#define IDS_MENURUNPARAM       65   
#define IDS_MENUCOMPCOMP       66 
#define IDS_MENUCOMPMAKE       67 
#define IDS_MENUCOMPBUILD      68 
#define IDS_MENUCOMPOPENPRJ    69 
#define IDS_MENUCOMPEDITPRJ    70 
#define IDS_MENUCOMPSAVEASPRJ  71 
#define IDS_MENUCOMPFROMTEMP   72 
#define IDS_MENUCOMPSAVETEMP   73  
#define IDS_MENUTOOLSOPT       74 
#define IDS_MENUOPTCOMP        75     
#define IDS_MENUOPTLINK        76     
#define IDS_MENUOPTPREF        77     
#define IDS_MENUOPTDIR         78     
#define IDS_MENUOPTOPEN        79     
#define IDS_MENUOPTSAVE        80     
#define IDS_MENUOPTSAVEAS      81     
#define IDS_MENUWINDOWTILEHOR  82 
#define IDS_MENUWINDOWCASCADE  83  
#define IDS_MENUWINDOWICONS    84 
#define IDS_MENUWINDOWCLOSEALL 85 
#define IDS_MENUHELPINDEX      86 
#define IDS_MENUHELPTOPIC      87 
#define IDS_MENUHELPCOMP       88 
#define IDS_MENUHELPUSING      89 
#define IDS_MENUHELPABOUT      90 
#define IDS_MENUBUGREPORT      91 
#define IDS_MENUCOMPCLOSPRJ    92
#define IDS_CANTMKDIR          93
#define IDS_NOVALIDPROJECT     94
#define IDS_MENUWINDOWTILEVER  95
#define IDS_MENUSEARCHIGNORE   96
#define IDS_RUNERROR0          97
#define IDS_RUNERROR2          98
#define IDS_RUNERROR3          99
#define IDS_RUNERROR8          100
#define IDS_CANTOPENDEFPRJ     101
#define IDS_NOPROGRAM          102
#define IDS_NOTHINGTOMAKE      103
#define IDS_TOOLNOTFOUND       104
#define IDS_TOOLNOTSTARTED     105
#define IDS_CANNOTLOADEDITOR   106
#define IDS_NOEDITORPROCEDURE  107
#define IDS_NOEDITOR           108
#define IDS_MENUOPTEDIT        109
#define IDS_MENUHELPEDIT       110
#define IDS_DDEFAILED          111
#define IDS_FILENOTEXISTS      112
#define IDS_USEOLDEDITOR       113
#define IDS_LINKANYWAY         114
#define IDS_ALREADYRUNNING     115
#define IDS_MENUCOMPLINK       116
#define IDS_PRJNAMEINVALID     117
                                
#define IDC_STATUSBAR 10000

/* attribute flags for DlgDirList */
#define ATTR_DIRS   0xC010              /* find drives and directories */
#define ATTR_FILES  0x0000              /* find ordinary files         */
#define PROP_FILENAME   szPropertyName  /* name of property for dialog */


/*
 *  External variable declarations
 */
extern HANDLE hInst;          /* application instance handle */
extern HANDLE hAccel;         /* resource handle of accelerators    */
extern HWND hwndFrame;        /* main window handle             */
extern HWND hwndMDIClient;    /* handle of MDI Edit window        */
/*extern HWND hwndActive;*/       /* handle of current active MDI child     */
extern LONG styleDefault;     /* default child creation state       */
extern char szChild[80];      /* class of child             */
extern char szPropertyName[]; /* filename property for dialog box   */
extern WORD cFonts;           /* number of fonts enumerated         */
extern HFONT editFont;        /* font for edit-windows */
extern HFONT smallFont;       /* small system font */
extern HPEN grayPen;          /* medium gray pen */
extern FARPROC edProc;        /* edit-control window procedure */
extern LPSTR arg_1;           /* first program argument */
extern LPSTR arg_2;           /* second program argument */

extern HBITMAP hShade;        /* background bitmap shade */
extern HBITMAP okBut;         /* ok-button */
extern HBITMAP okButFoc;      /* ok-button with focus */
extern HBITMAP okButSel;      /* selected ok-button */
extern HBITMAP cnBut;         /* cancel-button */
extern HBITMAP cnButFoc;      /* cancel-button with focus */
extern HBITMAP cnButSel;      /* selected cancel-button */
extern HBITMAP liBut;         /* linker-setup button */
extern HBITMAP liButFoc;      /* linker-setup button with focus*/
extern HBITMAP liButSel;      /* selectedlinker-setup button */
extern HBITMAP coBut;         /* linker-setup button */
extern HBITMAP coButFoc;      /* linker-setup button with focus*/
extern HBITMAP coButSel;      /* selected linker-setup button */
extern HBITMAP heBut;         /* help button */
extern HBITMAP heButFoc;      /* help button with focus */
extern HBITMAP heButSel;      /* selected help button */
extern HBITMAP hNote;         /* note-sign */
extern HBRUSH  hShadeB;       /* shade as brush */

extern HBITMAP drwOp;         /* open drawer */
extern HBITMAP drwOpGr;       /* open drawer, active */
extern HBITMAP drwCl;         /* closed drawer */
extern HBITMAP drvNet;        /* net drive */
extern HBITMAP drvDisk;       /* floppy disk drive */
extern HBITMAP drvHard;       /* hard drive */

extern BOOL readOnlyWindow;   /* flag, if edit to be created shall be read-only */
extern HWND msgWnd;           /* window handle of message window */
extern HWND msgWndEdit;       /* edit-control of message window */
extern HCURSOR hHourGlass;    /* hourglass cursor */

extern char defaultDir[MAXPATHLENGTH];   /* startup directory with pow! and compiler */
extern char windowsDir[MAXPATHLENGTH];   /* local windows directory */
extern char helpName[MAXPATHLENGTH];     /* name of help file */
extern char actPrj[MAXPATHLENGTH];       /* actual project file */
extern char actCfg[MAXPATHLENGTH];      /* actual configuration file */
extern char actPath[MAXPATHLENGTH];      /* actual path */
extern char actExt[MAXPATHLENGTH];       /* actual file extension */
extern char defPrj[MAXPATHLENGTH];       /* default project file */
extern char defCfg[10];       /* default configuration file */
extern char prjHistory[HISTORY][MAXPATHLENGTH]; /* last <n> open projects */
extern char filHistory[HISTORY][MAXPATHLENGTH]; /* last <n> open files */
extern char projectDirectory[MAXPATHLENGTH];  /* standard path of projects */

/*  externally declared functions
 */
extern BOOL FAR PASCAL InitializeApplication(VOID);
extern BOOL FAR PASCAL InitializeInstance(LPSTR,int);
extern BOOL FAR PASCAL AboutDlgProc(HWND,WORD,WPARAM,LONG);
extern LONG FAR PASCAL MDIChildWndProc (HWND,UINT,WPARAM,LONG);
extern long FAR PASCAL PowTextWndProc (HWND,WORD,WPARAM,LONG);
extern long FAR PASCAL PowReadWndProc (HWND,WORD,WPARAM,LONG);
extern HWND FAR AddFile (LPSTR);
extern HWND FAR AddFileAt (LPSTR,int,int,int,int);
extern VOID FAR ReadFromFile(HWND);
extern int FAR SaveFile(HWND);
extern BOOL FAR ChangeFile(HWND);
extern HWND FAR AlreadyOpen (LPSTR);
extern int FAR LoadFile(HWND,LPSTR);
extern VOID FAR PrintFile(HWND);
extern VOID FAR SetupPrinter(HWND);
extern short FAR CDECL Error(HWND,WORD,WORD,...);
extern short FAR CDECL Message(HWND,UINT,WORD,...);
extern VOID FAR PASCAL SpotHelp(HWND,POINT);
extern LONG FAR PASCAL FrameWndProc(HWND,WORD,WPARAM,LONG);
extern VOID FAR SetSaveFrom (HWND, PSTR);
extern VOID FAR DottedHLine (HDC hDC,WORD x,WORD y,WORD len);
extern VOID FAR DottedVLine (HDC hDC,WORD x,WORD y,WORD len);

//extern VOID FAR CompileFile (HWND);
//extern VOID FAR NextError (void);
//extern VOID FAR PrevError (void);
//extern BOOL FAR OpenProject (void);
//extern BOOL FAR MakeEmptyProject (void);
//extern VOID FAR EditProject (void);
//extern VOID FAR SaveAsProject (void);
//extern VOID FAR CloseProject (BOOL);
//extern VOID FAR LinkerOptions (HWND);
//extern VOID FAR CompilerOptions (HWND);
//extern VOID FAR MakeDependMatrix (void);
//extern VOID FAR RemoveDependMatrix (void);
//extern BOOL FAR CheckIfSource (LPSTR);
//extern int FAR FileAlreadyIn (LPSTR);
//extern int FAR AllFilesThere (VOID);
//extern VOID FAR CollectFiles (VOID);
//extern VOID FAR FreeCollectedFiles (VOID);
//extern VOID FAR RemoveMessageWindow (VOID);

extern VOID FAR InitStatus (void);
extern VOID FAR DestroyStatus (void);
extern VOID FAR NewMessage (LPSTR,BOOL);
extern VOID FAR NewLineNr (int,int);
extern VOID FAR NewInsertMode (int);
extern VOID FAR NewModified (BOOL);
extern VOID FAR ToggleInsert (void);
extern VOID FAR EraseStatus (BOOL,BOOL,BOOL,BOOL);
extern VOID FAR ShowBar (HDC);
extern VOID FAR ShowInsert (void);
extern BOOL FAR GetInsertMode (void);
extern VOID FAR CursorPos (HWND);

extern VOID FAR InitResources(void);
extern VOID FAR DestroyResources(void);
extern BOOL FAR DriveReady(int);
//extern void FAR GotoError(HWND);
//extern void FAR BuildProject(void);
//extern void FAR LinkOnlyProject(void);
//extern BOOL FAR MakeProject(LPINT,BOOL);
//extern void FAR CompilerHelp(WORD,DWORD);
extern VOID FAR CloseAllChildren(void);
extern VOID FAR LoadHistory(void);
extern VOID FAR AppendHistory(char far history[HISTORY][MAXPATHLENGTH],LPSTR buf);
extern BOOL FAR QueryCloseAllChildren (void);
void FAR SetMDIChildFocus (void);
void ShowAboutBox (void);

extern void FAR OwnerDrawButt (LPDRAWITEMSTRUCT di);

/* returns the active window */
HWND GetActiveEditWindow(HWND hWndClient);

#define _INC_POW
#endif
