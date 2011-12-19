/***************************************************************************
 *                                                                         *
 *  MODULE  : PowInit.c                                                    *
 *                                                                         *
 *  PURPOSE : Contains initialization code for Pow.                        *
 *                                                                         *
 *  FUNCTIONS   : InitializeApplication() - Sets up Class data structures  *
 *                      and registers window classes.                      *
 *                                                                         *
 *                InitializeInstance ()   - Does a per-instance initial-   *
 *                      ization of Pow. Creates the "frame"s               *
 *                      and MDI client.                                    *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <commdlg.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powribb.h"
#include "powopts.h"
#include "powdde.h"
#include "powtools.h"
#include "powtemp.h"
#include "powintro.h"

char szFrame[]     = "powframe";  /* Class name for "frame" window */
char szChild[]     = "powchild";  /* Class name for MDI window */

extern PRINTDLG printerData;

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : InitializeApplication ()                                  *
 *                                                                         *
 *  PURPOSE    : Sets up the class data structures and does a one-time     *
 *       initialization of the app by registering the window classes       *
 *                                                                         *
 *  RETURNS    : TRUE  - If RegisterClass() was successful for all classes *
 *               FALSE - otherwise.                                        *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL InitializeApplication()
{
    WNDCLASS    wc;

    /* Register the frame class */
    wc.style         = 0;
    wc.lpfnWndProc   = (WNDPROC) FrameWndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInst;
    wc.hIcon         = LoadIcon(hInst,IDPOW);
    wc.hCursor       = LoadCursor(NULL,IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_APPWORKSPACE+1);
    wc.lpszMenuName  = IDPOW;
    wc.lpszClassName = szFrame;

    if (!RegisterClass (&wc) )
        return FALSE;

    /* Register the child window class */
    wc.lpfnWndProc   = (WNDPROC)MDIChildWndProc;
    wc.hIcon         = LoadIcon(hInst,IDNOTE);
    wc.lpszMenuName  = NULL;
    wc.cbWndExtra    = CBWNDEXTRA;
    wc.lpszClassName = szChild;

    if (!RegisterClass(&wc))
        return FALSE;

    /* Create pattern brushes */
    hShade=LoadBitmap(hInst,"shade");
    hShadeB=CreatePatternBrush(hShade);

    return TRUE;
}

/***************************************************************************
 *  FUNCTION   : InitializeInstance ()                                     *
 *                                                                         *
 *  PURPOSE    : Performs a per-instance initialization of Pow. It         *
 *               also creates the frame, the client and an MDI window.     *
 *                                                                         *
 *  RETURNS    : TRUE  - If initialization was successful.                 *
 *               FALSE - otherwise.                                        *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL InitializeInstance(LPSTR lpCmdLine, int nCmdShow)
{           
    int x,y,dx,dy,saved,maximize,minimize;
    WNDCLASS wc;
    char sz[80];
    LOGFONT log;

    /* display the intro screen */
    ShowIntroScreen();

    /* Register a subclass for standard edit-controls */
    GetClassInfo(NULL,"edit",(LPWNDCLASS)&wc);
    edProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,NULL);
    wc.lpfnWndProc=(WNDPROC)PowTextWndProc;
    wc.lpszClassName="powtext";
    wc.hInstance=hInst;
    RegisterClass(&wc);

    /* Register a subclass for read only edit-controls */
    GetClassInfo(NULL,"edit",(LPWNDCLASS)&wc);
    wc.lpfnWndProc=(WNDPROC)PowReadWndProc;
    wc.lpszClassName="powread";
    wc.hInstance=hInst;
    RegisterClass(&wc);

    /* Get the base window title */
    LoadString (hInst, IDS_APPNAME, sz, sizeof(sz));

    /* Create small font (i.e. for status-bar) */
    GetObject(GetStockObject(ANSI_VAR_FONT),sizeof(LOGFONT),(LPSTR)&log);
#ifndef _WIN32
    log.lfWeight=FW_BOLD;
#endif
    smallFont=CreateFontIndirect((LPLOGFONT)&log);

    /* Create logical font for edit-windows */
    editFont=CreateFont(
          10,
          8,
          0,
          0,
          FW_NORMAL,
          FALSE,
          FALSE,
          FALSE,
          ANSI_CHARSET,
          OUT_DEFAULT_PRECIS,
          CLIP_DEFAULT_PRECIS,
          DEFAULT_QUALITY,
          FIXED_PITCH | FF_MODERN,
          "Courier");

    /* Initialize global resources */
    InitResources();

    /* Initialize status bar resources */
    InitStatus();
                                
    /* Remember position and size of last time pow was open */
    saved=GetProfileInt(INIFILESECTION,"window_saved",0);
    maximize=GetProfileInt(INIFILESECTION,"window_maximize",0);
    minimize=GetProfileInt(INIFILESECTION,"window_minimize",0);
    if (saved) {
        x=GetProfileInt(INIFILESECTION,"window_x",CW_USEDEFAULT);
        y=GetProfileInt(INIFILESECTION,"window_y",CW_USEDEFAULT);
        dx=GetProfileInt(INIFILESECTION,"window_dx",CW_USEDEFAULT);
        dy=GetProfileInt(INIFILESECTION,"window_dy",CW_USEDEFAULT);
    }
    else
        x=y=dx=dy=CW_USEDEFAULT;
                               
    /* Restory names of last open files and projects */
    LoadHistory();
                                       
    /* Create the frame */
    hwndFrame = CreateWindow (szFrame,
                  sz,
                  WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN |
                  (maximize ? WS_MAXIMIZE : 0) |
                  (minimize ? WS_ICONIC : 0),
                  x,
                  y,
                  dx,
                  dy,
                  NULL,
                  NULL,
                  hInst,
                  NULL);

    if ((!hwndFrame) || (!hwndMDIClient))
        return FALSE;

    /* Load main menu accelerators */
    if (!(hAccel = LoadAccelerators (hInst, IDPOW)))
        return FALSE;

    // Display the frame window
    // UpdateWindow (hwndFrame);

    /* initialize dll */
    InitSupporterDLL();

    /* initialize dde server functions */
    InitDDE(hwndFrame);                   
                   
    /* Initialize pow configuration */
    InitConfig();
                   
    /* Default to minimized windows after the first. */
    //!!!styleDefault = 0L;

    /* load saved desktop */
    LoadMemorize();
    
    /* run autostart tools */
    AutoStartTools();

    /* make ribbon */
    InitRibbon();
    ProjectToRibbon();
    CheckFileAct();

    /* enumerate templates and create menu */
    CreateTemplateMenu(GetMenu(hwndFrame));

    /* load hourglass cursor for lengthy operations */
    hHourGlass=LoadCursor(NULL,IDC_WAIT);
    
    /* information on printer */
    printerData.lStructSize=sizeof(PRINTDLG);
    printerData.hwndOwner=hwndFrame;
    printerData.hDevMode=NULL;
    printerData.hDevNames=NULL;
    printerData.Flags=PD_RETURNDC|PD_HIDEPRINTTOFILE|PD_NOPAGENUMS|PD_NOSELECTION; 
    printerData.nCopies=1;

    /* remove intro screen and show pow window */
    HideIntroScreen();
    if (minimize)
        ShowWindow (hwndFrame, SW_SHOWMINIMIZED);
    else if (maximize)
        ShowWindow (hwndFrame, SW_SHOWMAXIMIZED);
    else
        ShowWindow (hwndFrame, nCmdShow);
    UpdateWindow(hwndFrame);

    return TRUE;
}

