/***************************************************************************
 *                                                                         *
 *  MODULE    : PowRibb.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for drawing the ribbon bar               *
 *                                                                         *
 *  FUNCTIONS : InitRibbon    - Initializes the ribbon area and buttons    *
 *                                                                         *
 *              DestroyRibbon - Removes the ribbon buttons                 *
 *                                                                         *
 *              ShowRibbon    - Display ribbon with buttons                *
 *                                                                         *
 *              RibbonCommand - Execute a button command                   *
 *                                                                         *
 *              ProjectToRibbon - Copies project filenames to prj-combobox *
 *                                                                         *
 *              CheckFileAct  - Is filename in project-definition?         *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <string.h>
#include <stdlib.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powcomp.h"
#include "powribb.h"
#include "powproj.h"
#include "powtools.h"
#include "powopts.h"

/* exported globals */
BOOL ribbonOn=FALSE;
HWND hProj=0;

/* globals */
static HWND hOpen;
static HWND hSave;
static HWND hComp;
static HWND hMake;
static HWND hRun;
static HWND hPrint;
static HWND hAbout;
static HANDLE hRibbProjects=0;
                                 
/***************************************************************************
 *                                                                         *
 * FUNCTION    : InitRibbon ()                                             *
 *                                                                         *
 * PURPOSE     : Build up ribbon with push buttons                         *
 *                                                                         *
 ***************************************************************************/

void FAR InitRibbon ()
{
    if (!ribbonOn) {
        RECT r;                         
        int ypos;

        /* switch on ribbon */
        ribbonOn=TRUE;

        /* new window dimension (shrink) */
        GetClientRect(hwndFrame,(LPRECT)&r);
        if (actConfig.ribbonOnBottom) 
            ypos=r.bottom-STATHIGH-RIBBHIGH+YPOS+1;    
        else {    
            r.top+=RIBBHIGH;
            ypos=YPOS;
        }
        MoveWindow(hwndMDIClient,r.left,r.top,r.right-r.left+1,r.bottom-RIBBHIGH-STATHIGH,TRUE);

        /* ribbon does not exist */
        hOpen=CreateWindow("PowButton","Open",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                           OPENX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BAROPEN,hInst,NULL);
        hSave=CreateWindow("PowButton","Save",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                           SAVEX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BARSAVE,hInst,NULL);
        hPrint=CreateWindow("PowButton","Print",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                           PRINTX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BARPRINT,hInst,NULL);
        hComp=CreateWindow("PowButton","Compile",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                           COMPX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BARCOMP,hInst,NULL);
        hMake=CreateWindow("PowButton","Make",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                           MAKEX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BARMAKE,hInst,NULL);
        hRun=CreateWindow("PowButton","Run",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                          RUNX,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)IDD_BARRUN,hInst,NULL);
        hProj=CreateWindow("ComboBox","",WS_CHILD|WS_VISIBLE|WS_VSCROLL|CBS_DROPDOWNLIST|CBS_SORT|WS_BORDER,
                           PRJX,ypos+PRJY,PRJDX,PRJDY,hwndFrame,(HMENU)IDD_BARPRJ,hInst,NULL);
        hAbout=CreateWindow("PowButton","About",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                            ABTX,ypos,ABTDX,BUTDY,hwndFrame,(HMENU)IDD_BARABT,hInst,NULL);
#ifdef _WIN32
        SendMessage(hProj,WM_SETFONT,(WPARAM)smallFont,TRUE); 
#else
        SendMessage(hProj,WM_SETFONT,0,0); // dummy call to custom control                   
#endif
        GetClientRect(hwndFrame,(LPRECT)&r);
                         
        /* initialize user buttons */                 
        NewToolButtons();

        /* show ribbon */
        GetClientRect(hwndFrame,(LPRECT)&r);
        if (actConfig.ribbonOnBottom) 
            r.top=r.bottom-STATHIGH-RIBBHIGH+1;
        r.bottom=r.top+RIBBHIGH-1;
        InvalidateRect(hwndFrame,(LPRECT)&r,TRUE);
    }
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : ShowRibbon ()                                             *
 *                                                                         *
 * PURPOSE     : Display ribbon bar with background and buttons            *
 *                                                                         *
 ***************************************************************************/

void FAR ShowRibbon (HDC hDC)
{
    if (ribbonOn) {          
        int ry;
        RECT r; 
        HPEN oldP;
        HFONT oldF;
        HBRUSH oldB;
        /* copyright variables */
        int i;
        int len;
        char c;
        char Copy[30];                         
        /* xor 223:    "(c)'97 FIM, Universität Linz." */
        char Code[30]= "ñ¥±¶“ÿ«[«¶¬­º©¶±Šÿó’–™ÿèæøö¼÷";
        /* end of copyright variables */

        GetClientRect(hwndFrame,(LPRECT)&r);

        /* y-position of ribbon */
        if (actConfig.ribbonOnBottom)
            r.top=r.bottom-STATHIGH-RIBBHIGH+1;
        r.bottom=r.top+RIBBHIGH-1;
        ry=r.top;    

        oldB=SelectObject(hDC,GetStockObject(LTGRAY_BRUSH));
        PatBlt(hDC,r.left,r.top,r.right+1,r.bottom+1,PATCOPY);

        oldP=SelectObject(hDC,GetStockObject(WHITE_PEN));
        MoveToEx(hDC,r.left,r.top,NULL); LineTo(hDC,r.left,r.bottom-1);
        MoveToEx(hDC,r.left,r.top,NULL); LineTo(hDC,r.right,r.top);
        MoveToEx(hDC,r.left+2,r.bottom-3,NULL); LineTo(hDC,r.right-2,r.bottom-3);
        MoveToEx(hDC,r.right-2,r.top+2,NULL); LineTo(hDC,r.right-2,r.bottom-3);

        SelectObject(hDC,grayPen);
        MoveToEx(hDC,r.right,r.top,NULL); LineTo(hDC,r.right,r.bottom);
        MoveToEx(hDC,r.left,r.bottom-1,NULL); LineTo(hDC,r.right,r.bottom-1);
        MoveToEx(hDC,r.left+2,r.top+2,NULL); LineTo(hDC,r.left+2,r.bottom-2);
        MoveToEx(hDC,r.left+2,r.top+2,NULL); LineTo(hDC,r.right-2,r.top+2);

        SelectObject(hDC,GetStockObject(BLACK_PEN));
        MoveToEx(hDC,r.left,r.bottom,NULL); LineTo(hDC,r.right,r.bottom);

        /* copyright message */
        i=0;
        len=strlen(Code);
        while (c=Code[i]) {
            if (c=='[') c='ä';
            else c=c^(unsigned char)223;
            Copy[len-i-1]=c;
            i++;
        }
        Copy[len]=0;
        r.left=LOGOX;
        if (toolButtons)
            r.left+=BUTNEXT*toolButtons+5;
        r.right-=5;
        r.top=ry+LOGOY1;
        r.bottom=ry+LOGOY2;
        if (r.right>0) {
            SetBkMode(hDC,TRANSPARENT);
            oldF=SelectObject(hDC,smallFont);
            DrawText(hDC,(LPSTR)Copy,strlen(Copy),(LPRECT)&r,DT_LEFT|DT_VCENTER|DT_SINGLELINE);
            SelectObject(hDC,oldF);
        }
        /* end of copyright message */

        SelectObject(hDC,oldB);
        SelectObject(hDC,oldP);
    }
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : DestroyRibbon ()                                          *
 *                                                                         *
 * PURPOSE     : Remove ribbon and destroy buttons                         *
 *                                                                         *
 ***************************************************************************/

void FAR DestroyRibbon ()
{
    if (ribbonOn) {
        RECT r;            
        int i;

        /* turn off ribbon */
        ribbonOn=FALSE;
        DestroyWindow(hOpen);
        DestroyWindow(hSave);
        DestroyWindow(hPrint);
        DestroyWindow(hComp);
        DestroyWindow(hMake);
        DestroyWindow(hRun);
        DestroyWindow(hProj);
        DestroyWindow(hAbout);
                           
        for (i=0;i<toolButtons;i++)
            DestroyWindow(hToolBut[i]);                   
                           
        /* new window dimension (enlarge) */
        GetWindowRect(hwndMDIClient,(LPRECT)&r);
        r.top-=RIBBHIGH;
        MoveWindow(hwndMDIClient,r.left,r.top,r.right-r.left+1,r.bottom-r.top+1,TRUE);
    
        /* remove elements from list */
        PurgeList((LPHANDLE)&(hRibbProjects));
    }
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : RibbonCommand ()                                          *
 *                                                                         *
 * PURPOSE     : Execute command associated with button                    *
 *                                                                         *
 ***************************************************************************/

void FAR RibbonCommand (HWND hwnd,WPARAM wParam,LONG lParam)
{
#ifdef _WIN32
    switch (LOWORD(wParam)) {
#else
    switch (wParam) {
#endif

    case IDD_BAROPEN:

        SendMessage(hwndFrame,WM_COMMAND,IDM_FILEOPEN,0);
        break;

    case IDD_BARSAVE:

        SendMessage(hwndFrame,WM_COMMAND,IDM_FILESAVE,0);
        break;
                              
    case IDD_BARPRINT:
                                  
        SendMessage(hwndFrame,WM_COMMAND,IDM_FILEPRINT,0);
        break;
                              
    case IDD_BARCOMP:

        SendMessage(hwndFrame,WM_COMMAND,IDM_COMPCOMP,0);
        break;

    case IDD_BARMAKE:

        SendMessage(hwndFrame,WM_COMMAND,IDM_COMPMAKE,0);
        break;

    case IDD_BARRUN:

        SendMessage(hwndFrame,WM_COMMAND,IDM_RUNRUN,0);
        break;
                              
    case IDD_BARABT: 
        {
    
        FARPROC lpfn;
                              
        lpfn=MakeProcInstance(AboutDlgProc,hInst);
        DialogBox(hInst,IDD_ABOUT,hwndFrame,lpfn);
        FreeProcInstance(lpfn);
        }
        break;

    case IDD_BARPRJ:

        #ifdef _WIN32
          if (HIWORD(wParam)==CBN_SELCHANGE) {
        #else
          if (HIWORD(lParam)==CBN_SELCHANGE) {
        #endif
            int sel;
            HWND hwndFile;
            char fil[200];

            if ((sel=(int)SendDlgItemMessage(hwnd,IDD_BARPRJ,CB_GETCURSEL,0,0))>0) {
                SendDlgItemMessage(hwnd,IDD_BARPRJ,CB_GETLBTEXT,(WPARAM)sel,(LPARAM)(LPSTR)fil);

                /* display the selected file */
                if (hRibbProjects) {
                    int i;
                    char sub[200],found[200];
                    
                    strcpy(sub,"\\");
                    strcat(sub,fil);
                    *found=0;
                    
                    for (i=1;i<=CountList(hRibbProjects);i++) {
                        GetStr(hRibbProjects,i,fil);
                        if (strstr(fil,sub)) {
                           strcpy(found,fil);
                           break;
                        }
                    }
                        
                    if (*found) {
                        if (hwndFile=AlreadyOpen(found))
                            BringWindowToTop(hwndFile);
                        else {
                            #ifndef _WIN32
                               AnsiLower(found); 
                            #endif
                            if (AddFile(found)) {
                                SetWindowText(GetActiveEditWindow(hwndMDIClient),found);
                                AppendHistory(filHistory,found);  
                            }
                        }
                    }
                    else CheckFileAct();
                }
            }
            else CheckFileAct();
            SetMDIChildFocus();
        }
    }
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : ProjectToRibbon ()                                        *
 *                                                                         *
 * PURPOSE     : Fills project combo-box with project files.               *
 *                                                                         *
 ***************************************************************************/

void FAR ProjectToRibbon ()
{
    int i,j,src,n,cy,height;
    HDC hdc;
    RECT r;
    POINT p;
    TEXTMETRIC tm;
    PrjFile fil;
    char drv[20],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH],sub[MAXPATHLENGTH];

    if (!hProj)
        return;

    /* remove old content */
    PurgeList((LPHANDLE)&(hRibbProjects));

    SendMessage(hProj,CB_RESETCONTENT,0,0);
    strcpy(fil.name,"(no file)");
    SendMessage(hProj,CB_ADDSTRING,0,(long)(LPSTR)fil.name);
    n=CountList(actProject.files);
    src=0;

    /* fill combobox */
    for (i=1;i<=n;i++) {
        GetElem(actProject.files,i,(long)(LPPrjFile)&fil);
        _splitpath(fil.name,drv,dir,nam,ext);
        strcat(nam,ext);

        if (CheckIfSource((LPSTR)nam)) {
            SendMessage(hProj,CB_ADDSTRING,0,(long)(LPSTR)nam);
            src++;
        }    
    }     
    
    /* combobox is now sorted -> copy elements to list */
    n=CountList(actProject.files);
    for (i=0;i<src;i++) {
        if (SendMessage(hProj,CB_GETLBTEXT,i+1,(long)(LPSTR)nam)!=CB_ERR) {
            strcpy(sub,"\\");
            strcat(sub,nam);
            j=1;
            while (j<=n) {
                GetElem(actProject.files,j,(long)(LPPrjFile)&fil);
                if (strstr(fil.name,sub)) {
                    /* this is the i-th file -> add to list */
                    AddStr((LPHANDLE)(&hRibbProjects),fil.name);
                    break;
                }
                j++;
            }
        }
    }
    
    /* resize combo-box for project files */
    hdc=GetDC(hProj) ;
    GetTextMetrics(hdc,&tm) ;
    cy=tm.tmHeight+tm.tmExternalLeading;
    ReleaseDC(hProj,hdc) ;
    GetWindowRect(hProj,&r);
    p.x=r.left;
    p.y=r.top;
    ScreenToClient(GetParent(hProj),&p);
    height=2*(int)SendMessage(hProj,CB_GETITEMHEIGHT,0xffff,0)+(src+1)*(int)SendMessage(hProj,CB_GETITEMHEIGHT,0,0);
    if (height>250)
        height=250;                                  
    MoveWindow(hProj,p.x,p.y,PRJDX,height,TRUE);
      
    CheckFileAct();
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : CheckFileAct (LPSTR)                                      *
 *                                                                         *
 * PURPOSE     : Checks, if editfile is in project; selects combobox entry *
 *                                                                         *
 ***************************************************************************/

void FAR CheckFileAct ()
{
    int i;
    char buf[MAXPATHLENGTH],nam[MAXPATHLENGTH],add[MAXPATHLENGTH];

    if (hProj && GetActiveEditWindow(hwndMDIClient)) {
        GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)buf,sizeof(buf));

        #ifndef _WIN32
           DownStr((LPSTR)buf);
        #endif

        for (i=1;i<(int)SendMessage(hProj,CB_GETCOUNT,0,0);i++) {
            strcpy(nam,"\\");
            SendMessage(hProj,CB_GETLBTEXT,i,(long)(LPSTR)add);
            strcat(nam,add);
            if (strstr(buf,nam) && FileAlreadyIn(buf)) {
                SendMessage(hProj,CB_SETCURSEL,i,0);
                return;
            }
        }
    }
    if (hProj)
        SendMessage(hProj,CB_SETCURSEL,0,0);
    return;
}
                                         
/***************************************************************************
 *                                                                         *
 * FUNCTION    : MoveRibbon (void)                                         *
 *                                                                         *
 * PURPOSE     : Move ribbon to position according to options (top/bottom) *
 *                                                                         *
 ***************************************************************************/

void FAR MoveRibbon (void)
{
    if (ribbonOn) {
        DestroyWindow(hOpen);
        DestroyWindow(hSave);
        DestroyWindow(hComp);
        DestroyWindow(hMake);
        DestroyWindow(hRun);
        DestroyWindow(hProj);
        DestroyWindow(hPrint);
        DestroyWindow(hAbout);
        ribbonOn=FALSE;
        InitRibbon();                     
        ProjectToRibbon();
        InvalidateRect(hwndFrame,0,TRUE);
    }
}                                         
