/***************************************************************************
 *
 * PROGRAM:   Pow.c
 *
 * FUNCTIONS: 
 * WinMain()         Calls the initialization function and processes 
 *                   message loop
 * FrameWndProc()    Window function for the "frame" window, which 
 *                   controls the menu and contains the MDI document 
 *                   windows as child windows.
 * MDIChildWndProc() Window function for the individual document windows
 * CloseAllChildren  Destroys all MDI child windows.
 * AboutDlgProc()    Dialog function for the About dialog.
 * Error()           Flashes an error messagebox.
 * QueryCloseChild() Prompts for saving current MDI child window.
 * QueryCloseAllChildren() Asks whether it is OK to close down app.
 *
 ***************************************************************************/

#include <stdlib.h>
#include <direct.h>
#include <string.h>
#include <windows.h>
//#include <stdarg.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powcomp.h"
#include "powtools.h"
#include "powribb.h"
#include "powfind.h"
#include "powproj.h"
#include "powopts.h"
#include "powrun.h"
#include "powhelpe.h"
#include "powbug.h"
#include "powdde.h"
#include "powed.h"
#include "powtemp.h"
#include "powintro.h"
#include "ctl3dv2.h"
#include "resource.h"
#include "powCompiler.h"

#ifdef _WIN32
   #include <richedit.h>
#endif

/* global variables used in this module or among more than one module */
HANDLE hInst;                    /* Program instance handle */
HANDLE hPrev;                    /* Handle of previous program instance */
HANDLE hAccel;                   /* Main accelerator resource */
HWND hwndFrame       = 0;        /* Handle to main window */
HWND hwndMDIClient   = 0;        /* Handle to MDI client */
/*HWND hwndActive      = 0;*/        /* Handle to currently activated child */
LONG styleDefault    = 0; //WS_CHILD; /* Default style bits for child windows */
LPSTR lpMenu         = (LPSTR)IDPOW; /* Contains resource id of frame menu */
HFONT editFont;                  /* logical font used for edit-window */
HFONT smallFont;                 /* small font, i.e. used for status-bar */
FARPROC edProc;                  /* edit-control window procedure */
LPSTR arg_1;                     /* first program argument */
LPSTR arg_2;                     /* second program argument */

HBITMAP hShade;                  /* background bitmap shade */
HBITMAP okBut;                   /* ok-button */
HBITMAP okButFoc;                /* ok-button with focus */
HBITMAP okButSel;                /* selected ok-button */
HBITMAP cnBut;                   /* cancel-button */
HBITMAP cnButFoc;                /* cancel-button with focus */
HBITMAP cnButSel;                /* selected cancel-button */
HBITMAP liBut;                   /* linker-setup button */
HBITMAP liButFoc;                /* linker-setup button with focus*/
HBITMAP liButSel;                /* selectedlinker-setup button */
HBITMAP coBut;                   /* linker-setup button */
HBITMAP coButFoc;                /* linker-setup button with focus*/
HBITMAP coButSel;                /* selected linker-setup button */
HBITMAP heBut;                   /* help button */
HBITMAP heButFoc;                /* help button with focus */
HBITMAP heButSel;                /* selected help button */
HBITMAP hNote;                   /* note sign */
HBRUSH  hShadeB;                 /* pattern brush (shade-bitmap) */

HICON drwOp;                     /* open drawer */
HICON drwOpGr;                   /* open drawer, active */
HICON drwCl;                     /* closed drawer */
HICON drvNet;                    /* net drive */
HICON drvDisk;                   /* floppy disk drive */
HICON drvHard;                   /* hard drive */

HPEN grayPen;                    /* medium gray pen */

char defaultDir[MAXPATHLENGTH];             /* startup directory */
char windowsDir[MAXPATHLENGTH];             /* local windows directory */
char helpName[MAXPATHLENGTH];               /* name of help file */
char actPrj[MAXPATHLENGTH];                 /* name of project file */
char defPrj[MAXPATHLENGTH];                 /* name and path of default project file */
char actPath[MAXPATHLENGTH];                /* actual drive:\directory */
char actExt[MAXPATHLENGTH];                  /* actual file extension */
char actCfg[MAXPATHLENGTH];                 /* actual configuration file */
char prjHistory[HISTORY][MAXPATHLENGTH]={0};  /* last <n> open projects */
char filHistory[HISTORY][MAXPATHLENGTH]={0};  /* last <n> open files */
int prjHistoryMenus= 0;             /* number of project history entries in menu */
int filHistoryMenus= 0;             /* number of file history entries in menu */
char defCfg[10]=POWCFG;             /* default configuration file */
char projectDirectory[MAXPATHLENGTH];   /* standard path of projects */

/* forward declarations of helper functions in this module */
// int  NEAR PASCAL QueryCloseChild (HWND);
//void NEAR ShowRibbonAndBar (void);
//void NEAR SaveHistory (void);

/* external variables */
extern int errCnt;
extern int wrnCnt;

/* returns the window handle of the currently active child window */
HWND GetActiveEditWindow(HWND hWndClient) {
  return (HWND) SendMessage(hwndMDIClient, WM_MDIGETACTIVE, 0L, 0L);
}


/**********************************************************************
 *                                                                    *
 *  FUNCTION   : QueryCloseChild (hwnd)                               *
 *                                                                    *
 *  PURPOSE    : If the child MDI is unsaved, allow the user to save, *
 *               not save, or cancel the close operation.             *
 *                                                                    *
 *  RETURNS    : TRUE  - if user chooses save or not save, or if the  *
 *                       file has not changed.                        *
 *       FALSE - otherwise.                                           *
 *                                                                    *
 **********************************************************************/

BOOL NEAR PASCAL QueryCloseChild(hwnd)
register HWND hwnd;
{
    char sz[64];
    register int i;

    /* Return OK if edit control has not changed. */
    if (!IsEditWindow(hwnd) || !EditHasChanged(hwnd))
    return TRUE;

    GetWindowText (hwnd, sz, sizeof(sz));

    /* Ask user whether to save / not save / cancel */
    i=Message(hwnd,MB_YESNOCANCEL|MB_ICONQUESTION,IDS_CLOSESAVE,(LPSTR)sz);

    switch (i) {
    case IDYES:
        /* is file untitled? */
        if ((GetWindowWord(hwnd,GWW_UNTITLED)) && (!ChangeFile(hwnd)))
            return FALSE;

        /* User wants file saved */
        SaveFile(hwnd);
        break;

    case IDNO:
        /* User doesn't want file saved */
        break;

    default:
        /* We couldn't do the messagebox, or not ok to close */
        return FALSE;
    }
    return TRUE;
}


/****************************************************************************
 *                                                                          *
 *  FUNCTION   : ShowRibbonAndBar ()                                        *
 *                                                                          *
 *  PURPOSE    : Display both toolbar and statusbar (only one BeginPaint!)  *
 *                                                                          *
 ****************************************************************************/

void NEAR ShowRibbonAndBar ()
{
    HDC hDC;
    PAINTSTRUCT ps;

    hDC=BeginPaint(hwndFrame,(LPPAINTSTRUCT)&ps);
    ShowRibbon(hDC);
    ShowBar(hDC);
    EndPaint(hwndFrame,(LPPAINTSTRUCT)&ps);
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : HallOfFameDlgProc ( hwnd, msg, wParam, lParam )            *
 *                                                                          *
 *  PURPOSE    : Dialog function for the Hall of Fame dialog.               *
 *                                                                          *
 ****************************************************************************/

BOOL FAR PASCAL _export HallOfFameDlgProc (HWND hwnd,WORD msg,WPARAM wParam,LPARAM lParam )
{
    switch (msg){

    case WM_INITDIALOG: {

        int n;
        LPSTR p;
        HFILE f;
        DWORD read;
        OFSTRUCT of;
        char fil[_MAX_PATH];
        char student[200];

        /* fill listbox with content of <pow-dir>\credits.txt */
        SendDlgItemMessage(hwnd,IDD_HALLLIST,LB_RESETCONTENT,0,0);
        of.cBytes=sizeof(OFSTRUCT);
        strcpy(fil,defaultDir);
        strcat(fil,"\\credits.txt");
        f=OpenFile(fil,&of,OF_READ);
        if (f!=HFILE_ERROR) {
            p=student;
            n=0;
            do {
                read=_lread(f,p,1);
                if (read) {
                    if (((unsigned char)*p)<32) {
                        *p=0;
                        if (strlen(student)>0)
                            SendDlgItemMessage(hwnd,IDD_HALLLIST,LB_ADDSTRING,0,(LPARAM)(LPSTR)student);
                        p=student;
                        n=0;
                    }
                    else if (n<sizeof(student)) {
                        p++;
                        n++;
                    }
                }
            } while (read);
            *p=0;
            if (strlen(student)>0)
                SendDlgItemMessage(hwnd,IDD_HALLLIST,LB_ADDSTRING,0,(LPARAM)(LPSTR)student);
            _lclose(f);
        }
        else
            SendDlgItemMessage(hwnd,IDD_HALLLIST,LB_ADDSTRING,0,(LPARAM)(LPSTR)"credits.txt not found");
        }
        break;
         
    case WM_COMMAND:
        #ifdef _WIN32
            if (LOWORD(wParam)==IDOK || LOWORD(wParam)==IDCANCEL) {
        #else
            if (wParam==IDOK || wParam==IDCANCEL) {
        #endif
                EndDialog(hwnd, 0);
                break;
            }
        return FALSE;
        break;

    default:

        return FALSE;
    }
    return TRUE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : AboutDlgProc ( hwnd, msg, wParam, lParam )                 *
 *                                                                          *
 *  PURPOSE    : Dialog function for the About Pow dialog.                  *
 *                                                                          *
 ****************************************************************************/

BOOL FAR PASCAL _export AboutDlgProc (HWND hwnd,WORD msg,WPARAM wParam,LPARAM lParam )
{
    switch (msg){

    case WM_ERASEBKGND: {

        RECT r;
        GetClientRect(hwnd,(LPRECT)&r);
        FillRect((HDC)wParam,(LPRECT)&r,hShadeB);
        }
        break;

    case WM_PAINT: {
/*
        HWND habout;
        HDC dc,memdc;
        RECT pr,cr;
        HBITMAP hmap;
        PAINTSTRUCT ps;
                     
        hmap=LoadBitmap(hInst,MAKEINTRESOURCE(IDB_FIMABOUT));
        if (hmap) {
           habout=GetDlgItem(hwnd,IDD_ABOUTPOW);
           GetWindowRect(hwnd,(LPRECT)&pr);
           GetWindowRect(habout,(LPRECT)&cr);

           dc=BeginPaint(hwnd,(LPPAINTSTRUCT)&ps);
           memdc=CreateCompatibleDC(dc);
           SelectObject(memdc,hmap);
           BitBlt(dc,cr.left-pr.left+(cr.right-cr.left+5),cr.top-pr.top,55,40,memdc,0,0,SRCCOPY);
           DeleteDC(memdc);
           EndPaint(hwnd,(LPPAINTSTRUCT)&ps);
        }
*/
        RECT r;
        HDC dc,memdc;
      HBITMAP hIntro,oldmap;
      PAINTSTRUCT ps;

        hIntro=LoadBitmap(hInst,MAKEINTRESOURCE(IDB_INTRO));
      if (hIntro) {
            GetClientRect(hwnd,&r);
          dc=BeginPaint(hwnd,(LPPAINTSTRUCT)&ps);
          memdc=CreateCompatibleDC(dc);
        oldmap=SelectObject(memdc,hIntro);
        BitBlt(dc,(r.right-INTRODX)/2,(r.bottom-INTRODY)/2,INTRODX,INTRODY,memdc,0,0,SRCCOPY);
            SelectObject(memdc,oldmap);
        DeleteDC(memdc);
            DeleteObject(hIntro);
        EndPaint(hwnd,(LPPAINTSTRUCT)&ps);
    }
        }
        break;
/*
    case WM_CREATE: {

        LPCREATESTRUCT cs;

        cs=(LPCREATESTRUCT)lParam;
        cs->cx=INTRODX;
        cs->cy=INTRODY;
            
        return FALSE;
        }

*/  case WM_INITDIALOG: {

        RECT r,wr;
        BOOL ret;
        int x,y,dx,dy,wx,wy;
        HWND okBut,pluginBut,hallBut;
        
        okBut=GetDlgItem(hwnd,IDOK);
        pluginBut=GetDlgItem(hwnd,IDD_ABOUTPLUGIN);
        hallBut=GetDlgItem(hwnd,IDD_ABOUTHALL);

        /* move about window */
        GetWindowRect(hwnd,&r);
        wx=INTRODX+2*GetSystemMetrics(SM_CXBORDER);
        wy=INTRODY+2*GetSystemMetrics(SM_CYBORDER)+GetSystemMetrics(SM_CYCAPTION);
        ret=MoveWindow(hwnd,(GetSystemMetrics(SM_CXSCREEN)-wx)/2,(GetSystemMetrics(SM_CYSCREEN)-wy)/2,wx,wy,TRUE);

        /* position ok, about plugin and hall of fame buttons */
        GetWindowRect(okBut,&r);
        GetClientRect(hwnd,&wr);
        dx=r.right-r.left+1;
        dy=r.bottom-r.top+1;
        x=(wr.right-3*dx-2*10)/2;
        y=wr.bottom-dy-5;
        ret=MoveWindow(okBut,x,y,dx,dy,FALSE);
        ret=MoveWindow(pluginBut,x+dx+10,y,dx,dy,FALSE);
        ret=MoveWindow(hallBut,x+2*dx+2*10,y,dx,dy,FALSE);

        /* disable about plugin button, if no compiler present */
        if (!IsCompilerInterfaceLoaded())
            EnableWindow(pluginBut,FALSE);
        }
        break;

    case WM_COMMAND:
#ifdef _WIN32
        switch (LOWORD(wParam)){
#else
        switch (wParam){
#endif
        case IDOK:
        case IDCANCEL:
            EndDialog(hwnd, 0);
            break;

        case IDD_ABOUTPLUGIN:

            /* show compiler about box, if one is present */
            if (IsCompilerInterfaceLoaded()) (*compAbout)(hCompData,hwnd);
            
            break;

        case IDD_ABOUTHALL: {

            /* show hall of fame */
            FARPROC lpfn;

            lpfn=MakeProcInstance(HallOfFameDlgProc,hInst);
            DialogBox(hInst,IDD_HALLOFFAME,hwnd,lpfn);
            FreeProcInstance(lpfn);
            }
            break;

        default:
            return FALSE;
        }
        break;

    default:

        return FALSE;
    }

    return TRUE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : PrepareFilename (src, dst)                                 *
 *                                                                          *
 *  PURPOSE    : Shortens a given filename, so that it occupies less space  *
 *               in the history menu entries.                               *
 *                                                                          *
 ****************************************************************************/

void PrepareFilename (LPSTR dst,LPSTR src)
{           
    LPSTR lp;
    
    /* display only last directory entry */
    lp=src+strlen(src);
    while (lp!=src && *lp!='\\') lp--;

    if (lp!=src) {
       lp--;
       while (lp!=src && *lp!='\\') lp--;
    }   

    if (lp!=src && *lp=='\\') {
       lp--;
       while (lp!=src && *lp!='\\') lp--;
    }
    
    if (lp!=src) {
       if (*lp=='\\') lp++;
       strcpy(dst,"...\\");
    }
    else
       *dst=0;
       
    strcat(dst,lp);
}                          


/****************************************************************************
 *                                                                          *
 *  FUNCTION   : CloseAllChildren ()                                        *
 *                                                                          *
 *  PURPOSE    : Destroys all MDI child windows.                            *
 *                                                                          *
 ****************************************************************************/

VOID FAR CloseAllChildren ()
{
    HWND hwndT;

    /* hide the MDI client window to avoid multiple repaints */
    ShowWindow(hwndMDIClient,SW_HIDE);

    /* As long as the MDI client has a child, destroy it */
    while ( hwndT = GetWindow (hwndMDIClient, GW_CHILD)){

    /* Skip the icon title windows */
    while (hwndT && GetWindow (hwndT, GW_OWNER))
        hwndT = GetWindow (hwndT, GW_HWNDNEXT);

    if (!hwndT)
        break;
                                                                
    if (hwndT==msgWnd)
        msgWnd=0;

    SendMessage (hwndMDIClient, WM_MDIDESTROY, (WPARAM)hwndT, 0L);
    }
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SetMDIChildFocus ()                                        *
 *                                                                          *
 *  PURPOSE    : Set Focus to active MDI window.                            *
 *                                                                          *
 ****************************************************************************/

void FAR SetMDIChildFocus (void)
{
    HWND mdiActive,mdiChild;
    
    mdiActive=GetActiveEditWindow(hwndMDIClient);
    if (mdiActive) {
        mdiChild=GetWindow(mdiActive,GW_CHILD);
        if (mdiChild) SetFocus(mdiChild);
        else SetFocus(mdiActive);
    }
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : ShowAboutBox ()                                            *
 *                                                                          *
 *  PURPOSE    : Display the about dialog box.                              *
 *                                                                          *
 ****************************************************************************/

void ShowAboutBox (void)
{
   FARPROC lpfn;

   lpfn=MakeProcInstance(AboutDlgProc, hInst);
   DialogBox(hInst,IDD_ABOUT,hwndFrame,lpfn);
   FreeProcInstance(lpfn);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : Message ( hwnd, buttons, id, ...)                        *
 *                                                                        *
 *  PURPOSE    : Flashes a Message Box to the user. The format string is  *
 *               taken from the Stringtable. If twobuttons is TRUE, an    *
 *               additional Cancel-button appears.                        *
 *                                                                        *
 *  RETURNS    : Returns value returned by DialogBox() to the caller.     *
 *                                                                        *
 **************************************************************************/

short FAR CDECL Message (HWND hwnd,UINT style,WORD id,...)
{
    va_list l;
    char szFmt[256],msg[256];

    va_start(l,id);
    LoadString(hInst,id,szFmt,sizeof (szFmt));
    wvsprintf(msg,szFmt,l);
    va_end(l);

    return MessageBox (hwnd,(LPSTR)msg,"Message",style);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : Error ( hwnd, flags, id, ...)                            *
 *                                                                        *
 *  PURPOSE    : Flashes a Message Box to the user. The format string is  *
 *               taken from the Stringtable.                              *
 *                                                                        *
 *  RETURNS    : Returns value returned by MessageBox() to the caller.    *
 *                                                                        *
 **************************************************************************/

short FAR CDECL Error (HWND hwnd,WORD bFlags,WORD id,...)
{
    va_list l;
    char sz[160];
    char szFmt[256];

    va_start(l,id);
    LoadString (hInst,id,(LPSTR)szFmt,sizeof (szFmt));
    wvsprintf (sz,(LPSTR)szFmt,l);
    LoadString (hInst,IDS_APPNAME,(LPSTR)szFmt,sizeof(szFmt));
    va_end(l);

    return MessageBox(hwndFrame,sz,(LPSTR)szFmt,bFlags);
}

/****************************************************************************
 *                                      *
 *  FUNCTION   : QueryCloseAllChildren()                    *
 *                                      *
 *  PURPOSE    : Asks the child windows if it is ok to close up app. Nothing*
 *       is destroyed at this point. The z-order is not changed.    *
 *                                      *
 *  RETURNS    : TRUE - If all children agree to the query.         *
 *       FALSE- If any one of them disagrees.               *
 *                                      *
 ****************************************************************************/

BOOL FAR QueryCloseAllChildren (void)
{
    register HWND hwndT;

    for ( hwndT = GetWindow (hwndMDIClient, GW_CHILD);
      hwndT;
      hwndT = GetWindow (hwndT, GW_HWNDNEXT)       ){

    /* Skip if an icon title window */
    if (GetWindow (hwndT, GW_OWNER))
        continue;

    if (SendMessage (hwndT, WM_QUERYENDSESSION, 0, 0L))
        return FALSE;
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : InitResources ()                                          *
 *                                                                         *
 * PURPOSE     : Initialize global used pens, brushes and bitmaps          *
 *                                                                         *
 ***************************************************************************/
VOID FAR InitResources ()
{
    /* load bitmaps */
    drwOp=LoadIcon(hInst,"drwOp");
    drwOpGr=LoadIcon(hInst,"drwOpGr");
    drwCl=LoadIcon(hInst,"drwCl");
    drvNet=LoadIcon(hInst,"drvNet");
    drvDisk=LoadIcon(hInst,"drvDisk");
    drvHard=LoadIcon(hInst,"drvHard");

    /* init pen */
    grayPen=CreatePen(PS_SOLID,1,0x00808080);

    return;
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : DestroyResources ()                                       *
 *                                                                         *
 * PURPOSE     : Free global used pens, brushes, bitmaps and classes       *
 *                                                                         *
 ***************************************************************************/

VOID FAR DestroyResources ()
{
    /* purge lists */
    PurgeProject((LPPrjDecl)&actProject);
    PurgeList((LPHANDLE)&ToolList);
    PurgeList((LPHANDLE)&FindList);
    PurgeList((LPHANDLE)&ReplaceList);
    PurgeList((LPHANDLE)&GotoList);
    RemoveTemplateList();

    /* destroy bitmaps */
    DeleteObject(hShade);

    /* destroy icons */
    DestroyIcon(drwOp);
    DestroyIcon(drwOpGr);
    DestroyIcon(drwCl);
    DestroyIcon(drvNet);
    DestroyIcon(drvDisk);
    DestroyIcon(drvHard);

    /* destroy pattern brushes */
    DeleteObject(hShadeB);

    /* destroy pen */
    DeleteObject(grayPen);

    /* destroy custom classes */
    if (!hPrev) {
        UnregisterClass("powtext",hInst);
        UnregisterClass("powread",hInst);
        UnregisterClass("powchild",hInst);
    }
    return;
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : DriveReady (int)                                          *
 *                                                                         *
 * PURPOSE     : Returns TRUE, if drive is ready.                          *
 *                                                                         *
 ***************************************************************************/

BOOL FAR DriveReady (int i)
{
    char buf[MAXPATHLENGTH];
    return (getcwd(buf,sizeof(buf))!=NULL);
}


/**************************************************
 * handle owner-draw button event (focus,select), *
 * draw custom button in actual style and state   *
 * (possible states are: normal,focus,select)     *
 **************************************************/

void FAR OwnerDrawButt (LPDRAWITEMSTRUCT di)
{
    HDC memDC;
    LPRECT r;
    BOOL border;
    HBITMAP map;
    HBITMAP oldM;

    border=((di->itemState)&ODS_FOCUS)!=0;
    memDC=CreateCompatibleDC(di->hDC);
    r=(LPRECT)&(di->rcItem);

    switch(di->CtlID) {

    case IDD_BARSAVE:

        if (di->itemState&ODS_GRAYED)
            map=LoadBitmap(hInst,"savegry");
        else if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"savesel");
        else
            map=LoadBitmap(hInst,"save");
        border=FALSE;
        break;

    case IDD_BAROPEN:

        if (di->itemState&ODS_GRAYED)
            map=LoadBitmap(hInst,"opengry");
        else if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"opensel");
        else
            map=LoadBitmap(hInst,"open");
        border=FALSE;
        break;

    case IDD_BARPRINT:

        if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"printsel");
        else
            map=LoadBitmap(hInst,"print");
        border=FALSE;
        break;

    case IDD_BARCOMP:

        if (di->itemState&ODS_GRAYED)
            map=LoadBitmap(hInst,"compgry");
        else if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"compsel");
        else
            map=LoadBitmap(hInst,"comp");
        border=FALSE;
        break;

    case IDD_BARMAKE:

        if (di->itemState&ODS_GRAYED)
            map=LoadBitmap(hInst,"makegry");
        else if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"makesel");
        else
            map=LoadBitmap(hInst,"make");
        border=FALSE;
        break;

    case IDD_BARRUN:

        if (di->itemState&ODS_GRAYED)
            map=LoadBitmap(hInst,"rungry");
        else if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"runsel");
        else
            map=LoadBitmap(hInst,"run");
        border=FALSE;
        break;

    case IDD_BARABT:

        if (di->itemState&ODS_SELECTED)
            map=LoadBitmap(hInst,"logosel");
        else
            map=LoadBitmap(hInst,"logo");
        border=FALSE;
        break;

    default: {
                      
        int i;
        LPSTR lp;
        char buf[20],nr[5];
            
        if (di->CtlID>=IDD_TOOL_FIRST && di->CtlID<=IDD_TOOL_LAST) {    
            i=toolImage[di->CtlID-IDD_TOOL_FIRST];  
            lp=(LPSTR)nr;
            if (i>=10) *lp++=(i/10)+'0';
            *lp++=(i%10)+'0';
            *lp=0;                         
            lstrcpy((LPSTR)buf,"TOOL");
            lstrcat((LPSTR)buf,(LPSTR)nr);
            if (di->itemState&ODS_SELECTED)       
                map=LoadBitmap(hInst,"TOOLSEL");
            else
                map=LoadBitmap(hInst,"TOOL");

            oldM=SelectObject(memDC,map);
            FrameRect(di->hDC,r,GetStockObject(LTGRAY_BRUSH));
            BitBlt(di->hDC,r->left+1,r->top+1,r->right-1,r->bottom-1,memDC,0,0,SRCCOPY);
            
            map=LoadBitmap(hInst,(LPSTR)buf);
            DeleteObject(SelectObject(memDC,map));

            if (di->itemState&ODS_SELECTED)       
                BitBlt(di->hDC,r->left+4,r->top+4,r->right-7,r->bottom-7,memDC,2,2,SRCCOPY);
            else
                BitBlt(di->hDC,r->left+3,r->top+3,r->right-5,r->bottom-5,memDC,2,2,SRCCOPY);
            
            DeleteDC(memDC);
            DeleteObject(map);
            return;
        }    
        }            
    }

    /* draw black border, if necessary */
    if (border)
        FrameRect(di->hDC,r,GetStockObject(BLACK_BRUSH));
    else
        FrameRect(di->hDC,r,GetStockObject(LTGRAY_BRUSH));

    /* draw bitmap */
    oldM=SelectObject(memDC,map);
    BitBlt(di->hDC,r->left+1,r->top+1,r->right-1,r->bottom-1,memDC,0,0,SRCCOPY);
    DeleteDC(memDC);
    DeleteObject(map);
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : SaveHistory (void)                                        *
 *                                                                         *
 * PURPOSE     : Save information about last <n> open files and projects   *
 *                                                                         *
 ***************************************************************************/

void NEAR SaveHistory (void)
{                                    
    int n;
    char buf[256];
         
    /* save project history */
    n=0;
    while (n<HISTORY && *prjHistory[n]) {
        wsprintf(buf,"project_%d",n);
        WriteProfileString(INIFILESECTION,buf,prjHistory[n]);
        n++;
    }
    wsprintf(buf,"%d",n);
    WriteProfileString(INIFILESECTION,"projects",buf);
   
    /* save file history */
    n=0;
    while (n<HISTORY && *filHistory[n]) {
        wsprintf(buf,"file_%d",n);
        WriteProfileString(INIFILESECTION,buf,filHistory[n]);
        n++;
    }
    wsprintf(buf,"%d",n);
    WriteProfileString(INIFILESECTION,"files",buf);
    
    WriteProfileString(INIFILESECTION,"projectdir",projectDirectory);
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : LoadHistory (void)                                        *
 *                                                                         *
 * PURPOSE     : Load information about last <n> open files and projects   *
 *                                                                         *
 ***************************************************************************/

void FAR LoadHistory (void)
{                                    
    int i,n;
    char buf[256];
          
    for (n=0;n<HISTORY;n++) {
       *prjHistory[n]=0;      
       *filHistory[n]=0;      
    }
       
    /* load project history */
    i=0;
    n=GetProfileInt(INIFILESECTION,"projects",0);
    if (n>HISTORY) n=HISTORY;
    while (i<n) {
        wsprintf(buf,"project_%d",i);
        GetProfileString(INIFILESECTION,buf,"",prjHistory[i],80);
        i++;
    }                        
    
    /* load file history */
    i=0;
    n=GetProfileInt(INIFILESECTION,"files",0);
    if (n>HISTORY) n=HISTORY;
    while (i<n) {
        wsprintf(buf,"file_%d",i);
        GetProfileString(INIFILESECTION,buf,"",filHistory[i],80);
        i++;
    }

    GetProfileString(INIFILESECTION,"projectdir",defaultDir,projectDirectory,sizeof(projectDirectory));
    if (*projectDirectory && (projectDirectory[strlen(projectDirectory)-1]!='\\'))
        strcat(projectDirectory,"\\");
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : AppendHistory (char **,LPSTR)                             *
 *                                                                         *
 * PURPOSE     : Append a name to a history array                          *
 *                                                                         *
 ***************************************************************************/

void FAR AppendHistory(char far history[HISTORY][256],LPSTR buf)
{                                                            
    int i,pos;

    /* is entry already in list? */                                             
    pos=0;
    while (pos<HISTORY) {
        if (!stricmp((LPSTR)(history[pos]),buf))
            break;
        pos++;
    }          
    
    /* put entry <pos> in first position */
    if (pos<HISTORY) {
        for (i=pos;i>0;i--)
            lstrcpy((LPSTR)(history[i]),(LPSTR)(history[i-1]));
    }
    else 
        for (i=HISTORY-1;i>0;i--)
            lstrcpy((LPSTR)(history[i]),(LPSTR)(history[i-1]));
    
    lstrcpy((LPSTR)(history[0]),buf);
}


/****************************************************************************
 *
 * MDI CHILD WINDOW Functions
 *
 ****************************************************************************/

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : MDIWndProc ( hwnd, msg, wParam, lParam )                   *
 *                                                                          *
 *  PURPOSE    : The window function for the individual document windows,   *
 *       each of which has a "note". Each of these windows contain          *
 *       one multi-line edit control filling their client area.             * 
 *       In response to the following:                                      *
 *                                                                          *
 *           WM_CREATE      : Creates & diplays an edit control             *
 *                    and does some initialization.                         *
 *                                                                          *
 *           WM_MDIACTIVATE : Activates/deactivates the child.              *
 *                                                                          *
 *           WM_SETFOCUS    : Sets focus on the edit control.               *
 *                                                                          *
 *           WM_SIZE        : Resizes the edit control.                     *
 *                                                                          *
 *           WM_COMMAND     : Processes some of the edit commands,          *
 *                            saves files, compiles ...                     *
 *                                                                          *
 *           WM_CLOSE       : Closes child if it is ok to do so.            *
 *                                                                          *
 *           WM_QUERYENDSESSION : Same as above.                            *
 *                                                                          *
 ****************************************************************************/

LONG FAR PASCAL _export MDIChildWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {

    switch(msg) {
                 
    case PEM_SHOWINSERTMODE:
        NewInsertMode(wParam);
        return 0;                 
                 
    case PEM_SHOWLINENR:
        NewLineNr((int)lParam,wParam);
        return 0;
    
    case PEM_SHOWCHANGED:   
        NewModified(wParam);
        return 0;
        
    case PEM_DOUBLECLICK:
        if (hwnd == msgWnd) GotoError(hwnd);
        return 0;
        
    case WM_CREATE: 

        EditNewEditWindow(hwnd, readOnlyWindow);
                     
        /* Remember the window handle and initialize some window attributes */
        SetWindowLong (hwnd, GWL_HWNDEDIT, (LONG)GetWindow(hwnd,GW_CHILD));
        SetWindowWord (hwnd, GWW_WORDWRAP, FALSE);
        SetWindowWord (hwnd, GWW_UNTITLED, TRUE);
        SetWindowWord (hwnd, GWW_EDITCOL, 1);
        SetWindowWord (hwnd, GWW_EDITROW, 1);
        SetWindowWord (hwnd, GWW_EDITWIN, (WORD)!readOnlyWindow);

        break;

    // changed by PDI: 6.4.99
    //case WM_NCACTIVATE:
    //    if (wParam) SendMessage(hwnd,WM_MDIACTIVATE,(WPARAM)hwnd,0);
    //    return DefMDIChildProc(hwnd,msg,wParam,lParam);

    case WM_MDIACTIVATE: {

        HWND hwndToActivate;

        hwndToActivate = (HWND)lParam;

        /* If we're activating this child, remember it */
        if (hwndToActivate && IsEditWindow(hwndToActivate)) {

            HWND child;
            char buf[256];

            /* -- set focus to first child window -- */
            child = GetWindow(hwndToActivate,GW_CHILD);
            if (child) SetFocus(child);

            NewModified(EditHasChanged(hwndToActivate));
            ShowInsert();
            GetWindowText(hwndToActivate, (LPSTR)buf,sizeof(buf));
            DownStr((LPSTR)buf);
            SetWindowText(hwndToActivate, (LPSTR)buf);
            CheckFileAct();

        } else {

            NewLineNr(-1,-1);
            NewModified(FALSE);
            NewInsertMode(GetInsertMode());
            CheckFileAct();
        }
        return DefMDIChildProc(hwnd, msg, wParam, lParam); /* added by PDI */
    }

    case WM_QUERYENDSESSION:
        /* Prompt to save the child */
        return !QueryCloseChild(hwnd);
        
    //case WM_MOUSEACTIVATE:
    //
    //    SendMessage(hwndMDIClient,WM_MDIACTIVATE,(WPARAM)hwnd,0);
    //    return MA_ACTIVATE;

    case WM_CLOSE:
        /* If its OK to close the child, do so, else ignore */
        if ((!IsEditWindow(hwnd)) || QueryCloseChild(hwnd)) {
            char txt[20];
            GetWindowText(hwnd,(LPSTR)txt,sizeof(txt));
            if (!stricmp((LPSTR)txt,MESSAGEWINDOW)) msgWnd = 0;
        }
        return DefMDIChildProc (hwnd, msg, wParam, lParam);
        break;

    case WM_SIZE:
        /* On creation or resize, size the edit control. */
        if (IsEditWindow(hwnd) || hwnd == msgWnd)
            EditResizeWindow(hwnd,LOWORD(lParam),HIWORD(lParam));
        return DefMDIChildProc (hwnd, msg, wParam, lParam);

    case WM_SETFOCUS:
    
        if (IsEditWindow(hwnd) || hwnd == msgWnd) {
            HWND child;

            ShowInsert();
            NewModified(EditHasChanged(hwnd));
            CheckFileAct();
            
            /* if editor makes subwindow -> set focus to this */
            child = GetWindow(hwnd,GW_CHILD);
            if (child) SetFocus(child);
        }
        /*SetFocus(GetWindow(hwnd,GW_CHILD));*/
        /*WIEDER EINBAUEN!!!CursorPos(GetWindow(hwnd,GW_CHILD));*/
        return DefMDIChildProc (hwnd, msg, wParam, lParam);  /* added by PDI */


    case WM_COMMAND:
    
        switch (LOWORD(wParam)){

        case ID_EDIT:

            #ifdef _WIN32
                if (HIWORD(wParam)==EN_CHANGE)
                    SendMessage((HWND)lParam,LOWORD(msg),EN_CHANGE,lParam);
            #else
                if (HIWORD(lParam)==EN_CHANGE)
                    SendMessage(LOWORD(lParam),msg,wParam,lParam);
                else if (HIWORD(lParam)==EN_ERRSPACE)
                    /* if the control is out of space, honk */
                    MessageBeep(0);          
            #endif

            break;

        case IDM_FILESAVE: {
					int ok;
          /* -- Do not save message windows -- */
					if (IsEditWindow(hwnd)) {
						if (GetWindowWord(hwnd, GWW_UNTITLED)) {
							ok = ChangeFile(hwnd);									/* save as */
						} else {
							ok = SaveFile(hwnd);										/* save file */
						}
						if (ok) NewModified(FALSE);
						SetFocus(hwnd);
					}
          break;
				}

        case IDM_COMPCOMP:
          /* rename untitled ? */
          if ((!IsEditWindow(hwnd)) ||
              (GetWindowWord(hwnd, GWW_UNTITLED) && !ChangeFile(hwnd)))
            break;
          CompileFile(hwnd);
          break;

        default:
          return DefMDIChildProc (hwnd, msg, wParam, lParam);
        }
        break;

    default:
        return DefMDIChildProc (hwnd, msg, wParam, lParam);
    }
    return FALSE;
}



/****************************************************************************
 *
 * FRAME WINDOW Functions
 *
 ****************************************************************************/

LONG OnFrameCreate(HWND hwnd, WPARAM wParam, LPARAM lParam) {

  RECT r;
  CLIENTCREATESTRUCT ccs;          /* structure for child windows */

  /* Find window menu where children will be listed */
  ccs.hWindowMenu = GetSubMenu (GetMenu(hwnd), WINDOWMENU);
  ccs.idFirstChild = IDM_WINDOWCHILD;

  /* get size of parents client area */
  GetClientRect(hwnd, (LPRECT)&r);

  /* Create the MDI client filling the client area */
  hwndMDIClient = CreateWindow ("mdiclient",
                NULL,
                WS_CHILD | WS_CLIPCHILDREN,
                0,                 /* always begin in left */
                0,                 /*   upper edge of parent */
                r.right,           /* size of parent */
                r.bottom-STATHIGH, /* size of parent-statusbar-copyright */
                hwnd,
                (HMENU)0xCAC,
                hInst,
                (LPVOID)&ccs);

  ShowWindow(hwndMDIClient,SW_SHOW);
  return 0;
}


LONG OnFrameActivate(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  if (!(GetWindowLong(hwnd, GWL_STYLE) & WS_ICONIC)) ShowRibbonAndBar();
  return DefFrameProc(hwnd, hwndMDIClient, WM_ACTIVATE, wParam, lParam);
}


/*****************************************************************************
 *
 * PURPOSE:
 * --------
 * Sets up greying, enabling and checking of main menu items based on the 
 * app's state.
 *
 *****************************************************************************/

LONG OnFrameInitMenu(HANDLE hmenu) {

	char buf[256];
	int  canundo;
	char dir[MAXPATHLENGTH];
	char drv[4];
	char ext[MAXPATHLENGTH];
	HWND hWndActive;
	int  i;
  char menuTxt[256];
	int  n;
	char nam[MAXPATHLENGTH];
  int  status;

  /* Is there any active child to talk to? */
  hWndActive = GetActiveEditWindow(hwndMDIClient);  /* added by PDI */
  if (hWndActive) if (IsEditWindow(hWndActive)) strcpy(buf,"huhu");

  if (hWndActive && IsEditWindow(hWndActive)) {

    /* If edit control can respond to an undo request, enable the
     * undo selection.
     */
    canundo = EditCanUndo();

    status = canundo ? MF_ENABLED : MF_GRAYED;
    EnableMenuItem (hmenu, IDM_EDITUNDO, status);
        
    status = canundo>1 ? MF_ENABLED : MF_GRAYED;
    EnableMenuItem (hmenu, IDM_EDITREDO, status);

    /* if there is some text selected in the edit control, allow cut/copy/clear */
    status = EditHasSelection(hWndActive) ? MF_ENABLED : MF_GRAYED;
    EnableMenuItem (hmenu, IDM_EDITCUT, status);
    EnableMenuItem (hmenu, IDM_EDITCOPY, status);
    EnableMenuItem (hmenu, IDM_EDITCLEAR, status);

    status = MF_GRAYED;
    /* if the clipboard contains some CF_TEXT data, allow paste */
    if (OpenClipboard (hwndFrame)) {
      int wFmt = 0;
      while ((wFmt = EnumClipboardFormats(wFmt)) && (wFmt != CF_TEXT));
      if (wFmt == CF_TEXT) status = MF_ENABLED;
      CloseClipboard();
    }
    EnableMenuItem (hmenu, IDM_EDITPASTE, status);

    /* Enable search menu items only if there is a search string */
    if (*FindTxt)
      status = MF_ENABLED;
    else
      status = MF_GRAYED;
    EnableMenuItem(hmenu, IDM_SEARCHNEXT, status);

    /* select all search functions always enabled */
    status = MF_ENABLED;
    EnableMenuItem(hmenu,IDM_SEARCHFIND, status);
    EnableMenuItem(hmenu,IDM_SEARCHREPLACE, status);
    EnableMenuItem(hmenu,IDM_SEARCHGOTOLINE, status);

  } else {

    /* There are no active child windows */
    status = MF_GRAYED;

    /* No active window, so disable everything */
    for (i = IDM_EDITFIRST; i <= IDM_EDITLAST; i++)
      EnableMenuItem (hmenu, i, status);

    for (i = IDM_SEARCHFIRST; i <= IDM_SEARCHLAST; i++)
      EnableMenuItem (hmenu, i, status);
  }
             
  /* shall next/prev error ignore warnings? */
  CheckMenuItem(hmenu,IDM_SEARCHIGNOREWARNINGS,actConfig.searchIgnoreWarnings ? MF_CHECKED : MF_UNCHECKED);
  EnableMenuItem(hmenu,IDM_SEARCHIGNOREWARNINGS,MF_ENABLED);
      
  /* The following menu items are enabled if there is an active window */
  EnableMenuItem (hmenu, IDM_FILESAVE, status);
  EnableMenuItem (hmenu, IDM_FILESAVEAS, status);

  /* if there are error messages, enable search */
  status=(msgWnd && (errCnt+wrnCnt>0)) ? MF_ENABLED : MF_GRAYED;
  EnableMenuItem(hmenu,IDM_SEARCHFINDNEXTERR,status);
  EnableMenuItem(hmenu,IDM_SEARCHFINDPREVERR,status);

  /* if there is an open editor interface, enable editor options */
  EnableMenuItem(hmenu,IDM_OPTEDIT,EditorIsOpen() ? MF_ENABLED : MF_GRAYED);

  /* window functions are enabled if there is an edit or error window */
  status=(hWndActive && (IsEditWindow(hWndActive) || hWndActive==msgWnd)) ? MF_ENABLED : MF_GRAYED;
  EnableMenuItem (hmenu, IDM_WINDOWTILEHOR, status);
  EnableMenuItem (hmenu, IDM_WINDOWTILEVER, status);
  EnableMenuItem (hmenu, IDM_WINDOWCASCADE, status);
  EnableMenuItem (hmenu, IDM_WINDOWICONS, status);
  EnableMenuItem (hmenu, IDM_WINDOWCLOSEALL, status);

  /* is there a project to close or to edit */
  status = strlen(actPrj) ? MF_ENABLED : MF_GRAYED;
  strcpy(menuTxt,"&Edit...\t");
  if (*actPrj) {
    _splitpath(actPrj,drv,dir,nam,ext);
    strcat(menuTxt,nam);
    strcat(menuTxt,ext);
  }
  ModifyMenu(hmenu,IDM_COMPEDITPRJ,MF_BYCOMMAND,IDM_COMPEDITPRJ,(LPSTR)menuTxt);
  EnableMenuItem(hmenu,IDM_COMPCLOSPRJ,status);
  EnableMenuItem(hmenu,IDM_COMPSAVETEMP,status);
                                            
  /*2.0*/
  EnableMenuItem(hmenu,IDM_COMPEDITPRJ,MF_ENABLED);  // always enabled (for default-projects)
  EnableMenuItem(hmenu,IDM_COMPSAVEASPRJ,MF_ENABLED);

  /* enable/disable printing */
  status = (hWndActive && (IsEditWindow(hWndActive) || hWndActive == msgWnd)) ? MF_ENABLED : MF_GRAYED;
  EnableMenuItem(hmenu,IDM_FILEPRINT,status);
                               
  /* add file and project history to menu */
  for (n=1;n<=HISTORY;n++) {
    if (*prjHistory[n-1]) {                        
      if (prjHistoryMenus==0)
        AppendMenu(GetSubMenu(hmenu,4),MF_SEPARATOR,0,0);
                          
      PrepareFilename(menuTxt,prjHistory[n-1]);
      wsprintf(buf,"&%d %s",n,menuTxt);

      if (n>prjHistoryMenus) {
        AppendMenu(GetSubMenu(hmenu,4),MF_ENABLED|MF_STRING,IDM_PRJHISTORY+n,buf);
        prjHistoryMenus=n;
      } else
        ModifyMenu(GetSubMenu(hmenu,4),IDM_PRJHISTORY+n,MF_BYCOMMAND|MF_ENABLED|MF_STRING,IDM_PRJHISTORY+n,buf);
    }
    if (*filHistory[n-1]) {
      if (filHistoryMenus==0)
        AppendMenu(GetSubMenu(hmenu,0),MF_SEPARATOR,0,0);
                          
      PrepareFilename(menuTxt,filHistory[n-1]);
      wsprintf(buf,"&%d %s",n,menuTxt);

      if (n>filHistoryMenus) {
        AppendMenu(GetSubMenu(hmenu,0),MF_ENABLED|MF_STRING,IDM_FILEHISTORY+n,buf);
        filHistoryMenus=n;
      } else
        ModifyMenu(GetSubMenu(hmenu,0),IDM_FILEHISTORY+n,MF_BYCOMMAND|MF_ENABLED|MF_STRING,IDM_FILEHISTORY+n,buf);
    }
  }
  return 0;
}


LONG OnFrameMenuSelect(HMENU hMenu, UINT menuItem, UINT menuFlags) {

  int ids;               
  char buf[MAXPATHLENGTH];

	/* -- initialise -- */
	ids = 0;
	strcpy(buf, "");

	/* -- if hMenu is NULL, Windows has closed the menu -- */
	if (hMenu) {

    /* -- set resource identifier -- */
    switch (menuItem) {
      case IDM_FILENEW:              ids = IDS_MENUFILENEW; break;
      case IDM_FILEOPEN:             ids = IDS_MENUFILEOPEN; break;
      case IDM_FILESAVE:             ids = IDS_MENUFILESAVE; break;
      case IDM_FILESAVEAS:           ids = IDS_MENUFILESAVEAS; break;
      case IDM_FILESAVEALL:          ids = IDS_MENUFILESAVEALL; break;
      case IDM_FILEPRINT:            ids = IDS_MENUFILEPRINT; break;
      case IDM_FILESETUP:            ids = IDS_MENUFILESETUP; break;
      case IDM_FILEEXIT:             ids = IDS_MENUFILEEXIT; break;
      case IDM_EDITUNDO:             ids = IDS_MENUEDITUNDO; break;
      case IDM_EDITREDO:             ids = IDS_MENUEDITREDO; break;
      case IDM_EDITCUT:              ids = IDS_MENUEDITCUT; break;
      case IDM_EDITCOPY:             ids = IDS_MENUEDITCOPY; break;
      case IDM_EDITPASTE:            ids = IDS_MENUEDITPASTE; break;
      case IDM_EDITCLEAR:            ids = IDS_MENUEDITCLEAR; break;
      case IDM_SEARCHFIND:           ids = IDS_MENUSEARCHFIND; break;
      case IDM_SEARCHREPLACE:        ids = IDS_MENUSEARCHREPLACE; break;
      case IDM_SEARCHNEXT:           ids = IDS_MENUSEARCHNEXT; break;
      case IDM_SEARCHGOTOLINE:       ids = IDS_MENUSEARCHGOTOLINE; break;
      case IDM_SEARCHFINDNEXTERR:    ids = IDS_MENUSEARCHFINDNEXTERR; break;
      case IDM_SEARCHFINDPREVERR:    ids = IDS_MENUSEARCHFINDPREVERR; break;
      case IDM_SEARCHIGNOREWARNINGS: ids = IDS_MENUSEARCHIGNORE; break;
      case IDM_RUNRUN:               ids = IDS_MENURUNRUN; break;
      case IDM_RUNDEBUG:             ids = IDS_MENURUNDEBUG; break;
      case IDM_RUNPARAM:             ids = IDS_MENURUNPARAM; break;                                                
      case IDM_COMPCOMP:             ids = IDS_MENUCOMPCOMP; break;
      case IDM_COMPMAKE:             ids = IDS_MENUCOMPMAKE; break;
      case IDM_COMPBUILD:            ids = IDS_MENUCOMPBUILD; break;
      case IDM_COMPLINK:             ids = IDS_MENUCOMPLINK; break;
      case IDM_COMPOPENPRJ:          ids = IDS_MENUCOMPOPENPRJ; break;
      case IDM_COMPEDITPRJ:          ids = IDS_MENUCOMPEDITPRJ; break;
      case IDM_COMPSAVEASPRJ:        ids = IDS_MENUCOMPSAVEASPRJ; break;
      case IDM_COMPCLOSPRJ:          ids = IDS_MENUCOMPCLOSPRJ; break;
      case IDM_COMPFROMTEMP:         ids = IDS_MENUCOMPFROMTEMP; break;
      case IDM_COMPSAVETEMP:         ids = IDS_MENUCOMPSAVETEMP; break;
      case IDM_TOOLSOPT:             ids = IDS_MENUTOOLSOPT; break;
      case IDM_OPTEDIT:              ids = IDS_MENUOPTEDIT; break;
      case IDM_OPTCOMP:              ids = IDS_MENUOPTCOMP; break;
      case IDM_OPTLINK:              ids = IDS_MENUOPTLINK; break;
      case IDM_OPTPREF:              ids = IDS_MENUOPTPREF; break;
      case IDM_OPTDIR:               ids = IDS_MENUOPTDIR; break;
      case IDM_OPTOPEN:              ids = IDS_MENUOPTOPEN; break;
      case IDM_OPTSAVE:              ids = IDS_MENUOPTSAVE; break;
      case IDM_OPTSAVEAS:            ids = IDS_MENUOPTSAVEAS; break;
      case IDM_WINDOWTILEHOR:        ids = IDS_MENUWINDOWTILEHOR; break;
      case IDM_WINDOWTILEVER:        ids = IDS_MENUWINDOWTILEVER; break;
      case IDM_WINDOWCASCADE:        ids = IDS_MENUWINDOWCASCADE; break;
      case IDM_WINDOWICONS:          ids = IDS_MENUWINDOWICONS; break;
      case IDM_WINDOWCLOSEALL:       ids = IDS_MENUWINDOWCLOSEALL; break;
      case IDM_HELPINDEX:            ids = IDS_MENUHELPINDEX; break;
      case IDM_HELPTOPIC:            ids = IDS_MENUHELPTOPIC; break;
      case IDM_HELPCOMP:             ids = IDS_MENUHELPCOMP; break;
      case IDM_HELPEDIT:             ids = IDS_MENUHELPEDIT; break;
      case IDM_HELPUSING:            ids = IDS_MENUHELPUSING; break;
      case IDM_HELPABOUT:            ids = IDS_MENUHELPABOUT; break;
      case IDM_BUGREPORT:            ids = IDS_MENUBUGREPORT; break;
    }
                       
    /* -- load text from resource table -- */
    if (ids) LoadString(hInst, ids, (LPSTR)buf, sizeof(buf));
	}        

  /* -- show text -- */
  NewMessage((LPSTR)buf, FALSE);

  return 0;
}


/****************************************************************************
 *                                                                          *
 *  FUNCTION   : SaveAllChildren ()                                         *
 *                                                                          *
 *  PURPOSE    : Saves all MDI child windows.                               *
 *                                                                          *
 ****************************************************************************/

VOID NEAR PASCAL SaveAllChildren () {

  HWND hwnd;
	HWND hedit;
  char name[20];
 
  // Is there a child window?
  hwnd=GetWindow(hwndMDIClient,GW_CHILD);
  while (hwnd) {
 
    // Save edit controls only
    if (hedit=(HWND)GetWindowLong(hwnd,GWL_HWNDEDIT)) {
      GetClassName(hwnd,(LPSTR)name,sizeof(name));
      if (!stricmp(name,"powchild")) {
        SendMessage(hwnd,WM_COMMAND,IDM_FILESAVE,0L);
      }
    }

    // Get next window
    hwnd=GetWindow(hwnd,GW_HWNDNEXT);
  }

}


/****************************************************************************
 *
 * PURPOSE:
 * --------
 * Processes all "frame" WM_COMMAND messages.
 *
 ****************************************************************************/

LONG OnFrameCommand(HWND hwnd, WPARAM wParam, LPARAM lParam) {

	HWND hWndActive;				/* active MDI child window */

  switch (LOWORD(wParam)) {

		/* -- Compile -- */
	  case IDM_COMPCOMP:
      SendMessage(GetActiveEditWindow(hwndMDIClient), WM_COMMAND, IDM_COMPCOMP, 0L);
      break;

		/* -- Build Project -- */
    case IDM_COMPBUILD:
      BuildProject(GetActiveEditWindow(hwndMDIClient));
      break;

		/* -- Make Project -- */
    case IDM_COMPMAKE: {
      int uptodate;
      if (MakeProject(GetActiveEditWindow(hwndMDIClient), &uptodate, FALSE) && uptodate)
        Message(hwndFrame, MB_OK|MB_ICONINFORMATION, IDS_UPTODATE); 
      }
      break;

		/* -- Link Project -- */
    case IDM_COMPLINK:
      LinkOnlyProject(GetActiveEditWindow(hwndMDIClient));    
      break;

		/* -- Open Project -- */
    case IDM_COMPOPENPRJ:
      if (*actPrj)
        WriteProject((LPSTR)actPrj);
      else                            
        WriteProject((LPSTR)defPrj);         /*2.0: write default project */
      OpenProject();
      break;

		/* -- Edit Project -- */
    case IDM_COMPEDITPRJ:
      EditProject();
      break;

		/* -- Save as Project -- */
    case IDM_COMPSAVEASPRJ:
      SaveAsProject();
      break;

		/* -- Close Project -- */
    case IDM_COMPCLOSPRJ:
      CloseProject(TRUE);
      break;

		/* -- Save Project as Template -- */
    case IDM_COMPSAVETEMP:
      WriteTemplate();
      break;

		/* -- Run -- */
    case IDM_RUNRUN:
      /* Run project executable */
      RunProject(hwnd);
      break;

    case IDM_RUNPARAM:
      /* Enter program arguments for run */
      GetRunArgs();
      break;

		/* -- Editor Options -- */
    case IDM_OPTEDIT:
      EditEditOptions();
      break;

		/* -- Compiler Options -- */
    case IDM_OPTCOMP:
      CompilerOptions(hwnd);
      break;

		/* -- Linker Options -- */
    case IDM_OPTLINK:
      LinkerOptions(hwnd);
      break;

    case IDM_TOOLSOPT:
      ToolDialog(hwnd);
      break;

    case IDM_HELPINDEX:
      WinHelp(hwndFrame,(LPSTR)helpName,HELP_INDEX,Pow_Hilfe_Index);
      break;

    case IDM_HELPUSING:
      WinHelp(hwndFrame,NULL,HELP_HELPONHELP,0);
      break;

    case IDM_HELPTOPIC:
      CompilerHelp(HELP_PARTIALKEY,(long)(LPSTR)"");
      //WinHelp(hwndFrame,(LPSTR)helpName,HELP_PARTIALKEY,(long)(LPSTR)"");
      break;

    case IDM_HELPCOMP:
      CompilerHelp(HELP_INDEX,0);
      break;

    case IDM_HELPEDIT:
      EditShowHelp(hwndFrame);
      break;

    case IDM_FILENEW:
      /* Add a new, empty MDI child */
      AddFile(NULL);
      break;

    case IDM_FILEOPEN:
      ReadFromFile(hwnd);
      break;

    case IDM_FILESAVE:
      /* Save the active child MDI */
      SendMessage(GetActiveEditWindow(hwndMDIClient), WM_COMMAND, IDM_FILESAVE, 0L);
      SetMDIChildFocus();
      break;

    case IDM_FILESAVEAS:
      /* Save active child MDI under another name */
      hWndActive = GetActiveEditWindow(hwndMDIClient);
      if (ChangeFile(hWndActive)) {
        SendMessage(hWndActive, WM_COMMAND, IDM_FILESAVE, 0L);
        SetMDIChildFocus();
      }
      break;

    case IDM_FILESAVEALL:
      /* Save all MDI child windows */
      SaveAllChildren();
      break;

    case IDM_FILEPRINT:
      /* Print the active child MDI */
      EditPrint(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_FILESETUP:
      /* Set up the printer environment for this app */
      SetupPrinter(hwnd);
      break;

    case IDM_FILEMENU: {
      /* lengthen / shorten the size of the MDI menu */
      HMENU hMenu;
      HMENU hWindowMenu;
      int i;

      if (lpMenu==IDPOW) {
        lpMenu=(LPSTR)IDPOW2;
        i=SHORTMENU;
      } else {
        lpMenu=(LPSTR)IDPOW;
        i=WINDOWMENU;
      }

      hMenu=LoadMenu (hInst,lpMenu);
      hWindowMenu=GetSubMenu(hMenu,i);

      /* Set the new menu */
      hMenu=(HMENU)SendMessage(hwndMDIClient, WM_MDISETMENU,0,MAKELONG(hMenu,hWindowMenu));

      DestroyMenu(hMenu);
      DrawMenuBar(hwndFrame);
      break;
    }

    case IDM_FILEEXIT:
      /* Close Pow */
      SendMessage(hwnd, WM_CLOSE, 0, 0L);
      break;

    case IDM_BUGREPORT:
      BugReport();
      break;

    case IDM_HELPABOUT: {
      ShowAboutBox();
      break;
    }

    /* The following are edit commands. Pass these off to the active
     * child's edit control window.
     */
    case IDM_EDITCOPY:
      EditCopy(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_EDITPASTE:
      EditPaste(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_EDITCUT:
      EditCut(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_EDITCLEAR:
      EditClear(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_EDITREDO:
      EditRedo(GetActiveEditWindow(hwndMDIClient));
      break;
        
    case IDM_EDITUNDO:
      EditUndo(GetActiveEditWindow(hwndMDIClient));
      break;

    case IDM_SEARCHFIND:
      /* Put up the find dialog box */
      Find();
      break;

    case IDM_SEARCHREPLACE:
      /* Replace occurence */
      Replace();
      break;

    case IDM_SEARCHNEXT:
      /* Find next occurence */
      FindNext();
      break;

    case IDM_SEARCHGOTOLINE:
      /* Goto line number */
      GotoLine();
      break;

    case IDM_SEARCHFINDNEXTERR:
      /* Find next compile error */
      NextError();
      break;

    case IDM_SEARCHFINDPREVERR:
      /* Find last compile error */
      PrevError();
      break;

    case IDM_SEARCHIGNOREWARNINGS:
      /* Toggle ignore flag */
      actConfig.searchIgnoreWarnings=!actConfig.searchIgnoreWarnings;
      break;
                               
    case IDM_OPTDIR:
      /* Get directories for compiler */
      GetDirectories();
      break;

    case IDM_OPTPREF:
      /* Get global workbench options */
      GetPreferences();
      break;

    case IDM_OPTOPEN:
      /* open a new configuration file */
      OpenConfig();
      break;

    case IDM_OPTSAVE:
      /* save current configuration file */
      SaveConfig();
      break;

    case IDM_OPTSAVEAS:
      /* Save configuration in new file */
      SaveAsConfig();
      break;

    /* The following are window commands - these are handled by the
     * MDI Client. */
    case IDM_WINDOWTILEHOR:
      /* Tile MDI windows horizontally */
      SendMessage (hwndMDIClient, WM_MDITILE, MDITILE_HORIZONTAL, 0L);
      break;

    case IDM_WINDOWTILEVER:
      /* Tile MDI windows vertically */
      SendMessage (hwndMDIClient, WM_MDITILE, MDITILE_VERTICAL, 0L);
      break;

    case IDM_WINDOWCASCADE:
      /* Cascade MDI windows */
      SendMessage (hwndMDIClient, WM_MDICASCADE, 0, 0L);
      break;

    case IDM_WINDOWICONS:
      /* Auto - arrange MDI icons */
      SendMessage (hwndMDIClient, WM_MDIICONARRANGE, 0, 0L);
      break;

    case IDM_WINDOWCLOSEALL:
      /* Abort operation if something is not saved */
      if (!QueryCloseAllChildren()) break;
      CloseAllChildren();

      /* Show the window since CloseAllChilren() hides the window
       * for fewer repaints.
       */
      ShowWindow(hwndMDIClient, SW_SHOW);

      break;
      
    case IDM_TEMPLATEOTHER:
      OpenTemplate();
      break;


    case IDM_TEMPLATEEMPTY:
      MakeEmptyProject();
      break;

    default:            
               
      /* open file from history list? */
      if (wParam>IDM_FILEHISTORY && wParam<=IDM_FILEHISTORY+HISTORY) {
        HWND hwndFile;                        
        char buf[256];
        int n;
        
        n=wParam-IDM_FILEHISTORY-1;
        lstrcpy((LPSTR)buf,(LPSTR)(filHistory[(unsigned)n]));
        /* file already open? */
        if (hwndFile=AlreadyOpen(buf))
          /* yes, bring window to the top */
          BringWindowToTop(hwndFile);
        else 
          /* no, make a new window and load file */
          AddFile(buf);           
        /* rearrange history list */
        AppendHistory(filHistory,(LPSTR)buf);  
      }
      
      /* open project from history list? */
      if (wParam>IDM_PRJHISTORY && wParam<=IDM_PRJHISTORY+HISTORY) {
        int n=wParam-IDM_PRJHISTORY-1;
        if (FileExists(prjHistory[n])) {
          if (*actPrj)
            WriteProject((LPSTR)actPrj);
          else
            WriteProject((LPSTR)defPrj);   /*2.0*/
          CloseProject(FALSE);
          strcpy(actPrj,prjHistory[n]);
          if (ReadProject(actPrj,FALSE)) {
            /* rearrange history list */
            AppendHistory(prjHistory,actPrj);  
          } else
            *actPrj=0;
        } else 
          Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOPROJECTFILE,(LPSTR)prjHistory[n]);
      }
      
      /* menu tool selected? */
      if (wParam>=IDM_TOOLSFIRST && wParam<=IDM_TOOLSLAST) {
        RunTool((WORD)(wParam-IDM_TOOLS),TRUE,FALSE);
        break;
      }

      /* button tool selected? */
      if (LOWORD(wParam)>=IDD_TOOL_FIRST && LOWORD(wParam)<=IDD_TOOL_LAST) {
        RunTool((WORD)(LOWORD(wParam)-IDD_TOOL_FIRST+1),FALSE,FALSE);
        break;
      }

      /* ribbon button pressed? */
      if (LOWORD(wParam)>=RIBBON_FIRST && LOWORD(wParam)<=RIBBON_LAST) {
        RibbonCommand(hwnd,wParam,lParam);
        break;
      }

      /* select a template? */
      if (wParam>IDM_TEMPLATEPOPUP && wParam<IDM_TEMPLATEPOPUPLAST) {
        SelectTemplate(wParam);
        break;
      }
                               
      /*
       * This is essential, since there are frame WM_COMMANDS generated
       * by the MDI system for activating child windows via the
       * window menu.
       */
      return DefFrameProc(hwnd, hwndMDIClient, WM_COMMAND, wParam, 0L);
  }
  return 0;
}


LONG OnFrameClose(HWND hwnd, WPARAM wParam, LPARAM lParam) {
    
  RECT r;
  LONG ws;
  char buf[20];

  /* -- Don't close if any children cancel the operation -- */
  if (QueryCloseAllChildren()) {

    /* close help */
    BOOL ret = WinHelp(hwndFrame,(LPSTR)helpName,HELP_QUIT,0);
    
    /* save position and size of frame window in ini-file */
    ws=GetWindowLong(hwndFrame,GWL_STYLE);
    if (ws&WS_ICONIC)
      WriteProfileString(INIFILESECTION,"window_minimize","1");
    else
      WriteProfileString(INIFILESECTION,"window_minimize","0");
    
    if (ws&WS_MAXIMIZE)
      WriteProfileString(INIFILESECTION,"window_maximize","1");
    else
      WriteProfileString(INIFILESECTION,"window_maximize","0");
    
    if (ws&WS_ICONIC || ws&WS_MAXIMIZE)
      WriteProfileString(INIFILESECTION,"window_saved","0");
    else
      WriteProfileString(INIFILESECTION,"window_saved","1");
    
    GetWindowRect(hwndFrame,(LPRECT)&r);
    wsprintf((LPSTR)buf,"%u",r.left);
    WriteProfileString(INIFILESECTION,"window_x",(LPSTR)buf);
    wsprintf((LPSTR)buf,"%u",r.top);
    WriteProfileString(INIFILESECTION,"window_y",(LPSTR)buf);
    wsprintf((LPSTR)buf,"%u",r.right-r.left);
    WriteProfileString(INIFILESECTION,"window_dx",(LPSTR)buf);
    wsprintf((LPSTR)buf,"%u",r.bottom-r.top);
    WriteProfileString(INIFILESECTION,"window_dy",(LPSTR)buf);
    SaveHistory();
    
    /* save desktop */
    SaveMemorize();
    DestroyWindow(hwnd);

  }

  return 0;

}


LONG OnFrameDestroy(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  DestroyRibbon();
  PostQuitMessage (0);
  return 0;
}

LONG OnFrameSize(HWND hwnd, WPARAM wParam, LPARAM lParam) {

  RECT r;

  /* spare status bar */
  DefFrameProc(hwnd,hwndMDIClient, WM_SIZE, wParam, lParam);

  if ((wParam==SIZEFULLSCREEN) || (wParam==SIZENORMAL)) {
    GetClientRect(hwndFrame,(LPRECT)&r);
    if (ribbonOn) {
      if (!actConfig.ribbonOnBottom) r.top+=RIBBHIGH;
      r.bottom-=RIBBHIGH;    
    }
    MoveWindow(hwndMDIClient,r.left,r.top,r.right,r.bottom-STATHIGH,TRUE);
    if (actConfig.ribbonOnBottom) MoveRibbon();
    //ShowRibbonAndBar();
  }
  return 0;
}


LONG OnFramePaint(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  if (!(GetWindowLong(hwndFrame, GWL_STYLE) & WS_ICONIC)) ShowRibbonAndBar();
  return DefFrameProc(hwnd, hwndMDIClient, WM_PAINT, wParam, lParam);
}                         


LONG OnFrameMove(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  if (hProj) SendMessage(hProj, CB_SHOWDROPDOWN, 0, 0);
  return 0;
}

        
LONG OnFrameDrawItem(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  OwnerDrawButt((LPDRAWITEMSTRUCT)lParam);
  return 0;
}


LONG OnFrameGetMinMaxInfo(HWND hwnd, WPARAM wParam, LPARAM lParam) {
  MINMAXINFO FAR* lpmmi;
  lpmmi=(MINMAXINFO FAR*)lParam;
  lpmmi->ptMinTrackSize.x = 300;
  lpmmi->ptMinTrackSize.y = 200;
  return 0;
}


/**************************************************************************
 *
 * FUNCTION: 
 *
 * FrameWndProc(hwnd, msg, wParam, lParam)
 *
 *
 * PURPOSE: 
 *
 * The window function for the "frame" window, which controls the menu 
 * and encompasses all the MDI child windows. Does the major part of the 
 * message processing. Specifically, in response to:
 *
 * WM_CREATE:          Creates and displays the "frame".
 * WM_INITMENU:        Sets up the state of the menu.
 * WM_COMMAND:         Passes control to a command handling function.
 * WM_CLOSE:           Quits the app. if all the child windows agree.
 * WM_QUERYENDSESSION: Checks that all child windows agree to quit.
 * WM_DESTROY:         Destroys frame window and quits app.
 *
 **************************************************************************/

LONG FAR PASCAL _export FrameWndProc (HWND hwnd, WORD msg, WPARAM wParam, LPARAM lParam) {
  switch (msg) {
    case WM_CREATE:          return OnFrameCreate(hwnd, wParam, lParam);
    case WM_ACTIVATE:        return OnFrameActivate(hwnd, wParam, lParam);
    case WM_INITMENU:        return OnFrameInitMenu((HANDLE)wParam);
    case WM_MENUSELECT:      return OnFrameMenuSelect((HMENU)lParam, LOWORD(wParam), HIWORD(wParam));
    case WM_COMMAND:         return OnFrameCommand(hwnd, wParam, lParam);
    case WM_CLOSE:           return OnFrameClose(hwnd, wParam, lParam);
    case WM_QUERYENDSESSION: return QueryCloseAllChildren();
    case WM_DESTROY:         return OnFrameDestroy(hwnd, wParam, lParam);
    case WM_SIZE:            return OnFrameSize(hwnd, wParam, lParam);
    case WM_PAINT:           return OnFramePaint(hwnd, wParam, lParam);
    case WM_MOVE:            return OnFrameMove(hwnd, wParam, lParam);
    case WM_DRAWITEM:        return OnFrameDrawItem(hwnd, wParam, lParam);
    case WM_GETMINMAXINFO:   return OnFrameGetMinMaxInfo(hwnd, wParam, lParam);
    default:                 return DefFrameProc(hwnd, hwndMDIClient, msg, wParam, lParam);
  }
}



/****************************************************************************
 *
 * FUNCTION: 
 * WinMain(HANDLE, HANDLE, LPSTR, int)
 *
 * PURPOSE: 
 * Creates the "frame" window, does some initialization and enters the 
 * message loop.
 * 
 ****************************************************************************/

int FAR PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance, LPSTR lpszCmdLine, int nCmdShow) {

  MSG  msg;
  char drv[4];
  char dir[MAXPATHLENGTH];
  char nam[MAXPATHLENGTH];
  char ext[MAXPATHLENGTH];

  hInst=hInstance;                                           
  hPrev=hPrevInstance;

  /* If init does not work -> exit */
  if (!hPrevInstance && !InitializeApplication()) return 0;                            
                      
  /* get windows directory */
  GetWindowsDirectory(windowsDir,sizeof(windowsDir));    
                                           
  /* get pow! directory */
  GetModuleFileName(hInst,(LPSTR)defaultDir,sizeof(defaultDir));
  AnsiLower((LPSTR)defaultDir);
  _splitpath(defaultDir,drv,dir,nam,ext);
  strcpy(defaultDir,drv);
  strcat(defaultDir,dir);
  if (defaultDir[strlen(defaultDir)-1]=='\\')
      defaultDir[strlen(defaultDir)-1]=0;
  strcpy(actPath,defaultDir);
  lstrcpy((LPSTR)actExt,DEFFILESEARCH);

  /* build helpfile name */
  strcpy(helpName,defaultDir);
  if (helpName[strlen(helpName)-1]!='\\')
      strcat(helpName,"\\");
  strcat(helpName,"pow.hlp");

  /* initialize project string */
  actPrj[0]=0;

  /* remember first two arguments */
  arg_1=arg_2=lpszCmdLine;  
  while (*arg_2 && *arg_2!=' ') arg_2++;
  if (*arg_2==' ') *arg_2++=0;

  /* Create the frame and do other initialization */
  if (!InitializeInstance (lpszCmdLine, nCmdShow))
  return 0;

  /* Enter main message loop */
  while(GetMessage(&msg, 0, 0, 0)) {
    /* If a keyboard message is for the MDI , let the MDI client
     * take care of it.  Otherwise, check to see if it's a normal
     * accelerator key (like F3 = find next).  Otherwise, just handle
     * the message as usual.
     */
    if (!TranslateMDISysAccel (hwndMDIClient, &msg) && !TranslateAccelerator(hwndFrame, hAccel, &msg)){
      TranslateMessage (&msg);
      DispatchMessage (&msg);
    }
  }
  
  /* write project, if there is one */
//!!!    if (*actPrj)
//!!!        WriteProject((LPSTR)actPrj);

  /* purge status bar resources */
  DestroyStatus();

  /* free global resources */
  DestroyResources();

  /* delete fonts */
  DeleteObject(editFont);
  DeleteObject(smallFont);
               
  /* stop autostart tools */
  AutoStopTools();
                   
  /* free initialization data */
  ExitConfig();
      
  /* close dde server functionality */
  ExitDDE();        
      
  /* prepare supporter dll to exit */
  ExitSupporterDLL();

  return 0;
}
