#include <string.h>
#include <windows.h>
#include <drivinit.h>
#include <commdlg.h>
#include <memory.h>

#include "powedit.h"

typedef struct {
    unsigned wDriver;
    unsigned wDevice;
    unsigned wOutput;
    unsigned wDefault;
    char buf[100];
} DevInfo;    

static BOOL fAbort;           /* TRUE if the user has aborted the print job */
static HWND hwndPDlg;         /* Handle to the cancel print dialog */
static char szName[128];      /* Contains the name of the file to be printed */
static LPSTR szDriver;        /* Pointer to the driver name */
static LPSTR szPort;          /* Port, ie, LPT1 */
static LPSTR szTitle;         /* Global pointer to job title */
static LPSTR filename;        /* name of the file to print */
static PRINTDLG printerData;  /* information on current printer */
static int tabWidth;          /* width of a single tabulator */

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : PrintAbortProc()                                          *
 *                                                                         *
 *  PURPOSE    : To be called by GDI print code to check for user abort.   *
 *                                                                         *
 ***************************************************************************/

int FAR PASCAL _export PrintAbortProc (HDC hdc,WORD reserved)
{
    MSG msg;      
    
    if (!hwndPDlg)
        return TRUE;

    /* Allow other apps to run, or get abort messages */
    while (!fAbort && PeekMessage (&msg, 0, 0, 0, TRUE))
    if (!IsDialogMessage (hwndPDlg, &msg)){
        TranslateMessage (&msg);
        DispatchMessage  (&msg);
    }
    return !fAbort;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : PrintDlgProc ()                                            *
 *                                                                          *
 *  PURPOSE    : Dialog function for the print cancel dialog box.           *
 *                                                                          *
 *  RETURNS    : TRUE  - OK to abort/ not OK to abort                       *
 *               FALSE - otherwise.                                         *
 *                                                                          *  
 ****************************************************************************/

BOOL FAR PASCAL _export PrintDlgProc(HWND hwnd, WORD msg, WORD wParam, LONG lParam)
{
    switch (msg){

    case WM_INITDIALOG:
        // Set up information in dialog box 
        if (szDriver) SetDlgItemText (hwnd, IDD_ED_PRINTDEVICE, szDriver);
        if (szPort) SetDlgItemText (hwnd, IDD_ED_PRINTPORT, szPort);
        if (szTitle) SetDlgItemText (hwnd, IDD_ED_PRINTTITLE, szTitle);
        break;

    case WM_COMMAND:
        // abort printing if the only button gets hit 
        fAbort = TRUE;
        break;

    default:
        return FALSE;
    }
    return TRUE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : PrintFile ()                                               *
 *                                                                          *
 *  PURPOSE    : Prints the contents of the edit control.                   *
 *                                                                          *
 ****************************************************************************/

void FAR PrintHeader (HDC dc,int page)
{
    char buf[100];
    char pagenr[5];
    
    /* Print name of file and page number */          
    lstrcpy((LPSTR)buf,"Listing of file: ");
    lstrcat((LPSTR)buf,(LPSTR)filename);
    lstrcat((LPSTR)buf,"   page ");
    wsprintf((LPSTR)pagenr,"%d",page);
    lstrcat((LPSTR)buf,pagenr);
    AnsiUpper((LPSTR)buf);
    TextOut(dc,0,0,(LPSTR)buf,lstrlen((LPSTR)buf));    
}

void FAR CheckPage (HWND hwnd,HDC dc,LPINT page,LPINT y,int dy,int ymax)
{
    if (*y+dy>ymax) {
        // Reached the end of a page. Tell the device driver to eject a page 
        Escape(dc,NEWFRAME,0,0,0);   
        (*page)++;
        PrintHeader(dc,*page);
        *y=2*dy;
    }
}

void FAR PrintLine (LPSTR text,HWND hwnd,HDC dc,int x,LPINT y,int dy,int xmax,int ymax,LPINT page)
{            
    LPSTR lp;       
    int dx,xorg=x;    

#ifdef _WIN32
    SIZE size;

    GetTextExtentPoint32(dc,text,lstrlen(text),&size);
    if (size.cx>xmax) {
#else                         
    if ((int)LOWORD(GetTextExtent(dc,text,lstrlen(text)))>xmax) {
#endif

        lp=text;
        while (*text) {
            while (*lp && *lp!=' ') lp++;
            if (*lp==' ') lp++;

            #ifdef _WIN32
                GetTextExtentPoint32(dc,text,lp-text,&size);
                dx=size.cx;
            #else
                dx=LOWORD(GetTextExtent(dc,text,lp-text));
            #endif

            if (x+dx>xmax) {  
                if (x!=xorg) {
                    x=xorg;
                    *y+=dy;    
                }    
                CheckPage(hwnd,dc,page,y,dy,ymax);
                while (x+dx>xmax) {
                    lp--;
                    #ifdef _WIN32
                        GetTextExtentPoint32(dc,text,lp-text,&size);
                        dx=size.cx;
                    #else
                        dx=LOWORD(GetTextExtent(dc,text,lp-text));
                    #endif
                }          
            }         
            if (lp-text>0)
                TabbedTextOut(dc,x,*y,text,lp-text,1,(LPINT)&tabWidth,xorg);
            x+=dx;
            text=lp;
        }                  
        if (x!=xorg) {
            *y+=dy;    
            CheckPage(hwnd,dc,page,y,dy,ymax);
        }
    }
    else {              
        if (*text)
            TabbedTextOut(dc,x,*y,text,lstrlen(text),1,(LPINT)&tabWidth,xorg);
        *y+=dy;
    }                       
}

int PrintFile (HWND hwnd,LPSTR title)
{           
    int iPage;
    int yExtPage;                       
    int xExtPage;
    WORD ich;
    WORD iLine;
    WORD nLinesEc;
    HANDLE hT;
    FARPROC lpfnAbort;
    FARPROC lpfnPDlg;
    HWND hwndPDlg;
    int dy;
    int yExtSoFar;
    WORD fError = TRUE;
    int xTextStart;
    char linenr[10];
    char line[200];
    DOCINFO di;
    HDC hDC;          
    DevInfo far *dev;

    #ifdef _WIN32
        SIZE size;
    #else
        WORD cch;
        PSTR pch;
    #endif
                    
    printerData.lStructSize=sizeof(PRINTDLG);
    printerData.hwndOwner=hwnd;
    printerData.Flags=PD_RETURNDC|PD_HIDEPRINTTOFILE|PD_NOPAGENUMS|PD_NOSELECTION; 
    printerData.nCopies=1;

    if (!PrintDlg((LPPRINTDLG)&printerData)) 
        return 0;
    if (printerData.hDC) 
        hDC=printerData.hDC;
    else 
        return 0;
           
    if (printerData.hDevNames) {
        dev=(DevInfo far *)GlobalLock(printerData.hDevNames);         
        szDriver=(LPSTR)dev+dev->wDevice;
        szPort=(LPSTR)dev+dev->wOutput;
    }
    else 
        szDriver=szPort=0;

    // Create the job title by loading the title string from STRINGTABLE 
    filename=title;
    lstrcpy(szName,"Pow! - ");
    szTitle=szName+lstrlen(szName);
    lstrcpy(szTitle,title);

    // Make instances of the Abort proc. and the Print dialog function 
    lpfnAbort=MakeProcInstance(PrintAbortProc,hInstDLL);
    lpfnPDlg=MakeProcInstance(PrintDlgProc,hInstDLL);

    // Allow the application to inform GDI of the escape function to call 
    Escape(hDC,SETABORTPROC,0,(LPSTR)lpfnAbort,0);

    // Initialize the document 
    di.cbSize=lstrlen((LPSTR)szName);
    di.lpszDocName=(LPSTR)szName;
    di.lpszOutput=0;

    Escape(hDC,STARTDOC,lstrlen(szName),(LPSTR)szName,(LPSTR)NULL);
    fAbort=FALSE;
    hwndPDlg=CreateDialog(hInstDLL,MAKEINTRESOURCE(ID_ED_PRINT),hwnd,lpfnPDlg);
    ShowWindow(hwndPDlg,SW_NORMAL);
    UpdateWindow(hwndPDlg);

    // Get the height of one line and the height of a page 
    GetTextExtentPoint32(hDC,"CC",2,&size);
    dy=size.cy;
    yExtPage=GetDeviceCaps(hDC,VERTRES);
    xExtPage=GetDeviceCaps(hDC,HORZRES);

    // Get the lines in document and and a handle to the text buffer 
    iLine=0;
    iPage=0;
    nLinesEc=(WORD)SendMessage(hwnd,EM_GETLINECOUNT,0,0L);
    hT=(HANDLE)SendMessage(hwnd,EM_GETHANDLE,0,0L);
                                                        
    tabWidth=8;

    #ifdef _WIN32
         GetTextExtentPoint32(hDC," ",1,&size);
         tabWidth*=size.cx;
    #else
         tabWidth*=LOWORD(GetTextExtent(hDC," ",1));
    #endif
                                                        
    // Print file name
    PrintHeader(hDC,++iPage);    
    yExtSoFar=2*dy;                                    
        
    // Calculate width of line numbering information 
    #ifdef _WIN32
        if (nLinesEc>=1000)
            GetTextExtentPoint32(hDC,"XXXX: ",6,&size);
        else                
            GetTextExtentPoint32(hDC,"XXX: ",5,&size);
        xTextStart=size.cx;
    #else
        if (nLinesEc>=1000)
            xTextStart=LOWORD(GetTextExtent(hDC,"XXXX: ",6));
        else                
            xTextStart=LOWORD(GetTextExtent(hDC,"XXX: ",5));
    #endif
                                                
    // While more lines print out the text 
    while (iLine<nLinesEc && !fAbort) {
        CheckPage(hwnd,hDC,&iPage,&yExtSoFar,dy,yExtPage);

        // Get the length and position of the line in the buffer
        // and lock from that offset into the buffer 
        ich=(WORD)SendMessage(hwnd,EM_LINEINDEX,iLine,0L);
        // Print the line number 
        if (nLinesEc>=1000)
            wsprintf((LPSTR)linenr,"%4d: ",iLine+1);
        else
            wsprintf((LPSTR)linenr,"%3d: ",iLine+1);
        TextOut(hDC,0,yExtSoFar,(LPSTR)linenr,lstrlen((LPSTR)linenr));    
                                                   
        #ifdef _WIN32
            SendMessage(hwnd,EM_GETLINE,(WPARAM)ich,(LPARAM)line);
            PrintLine((LPSTR)line,hwnd,hDC,xTextStart,&yExtSoFar,dy,xExtPage-xTextStart,yExtPage,&iPage);
        #else
            // Print the line and unlock the text handle 
            cch=(WORD)SendMessage(hwnd,EM_LINELENGTH,ich,0L);
            pch=LocalLock(hT)+ich;
            if (cch>=sizeof(line)) cch=sizeof(line)-1;
            memcpy((LPSTR)line,(LPSTR)pch,cch);
            line[cch]=0;
            PrintLine((LPSTR)line,hwnd,hDC,xTextStart,&yExtSoFar,dy,xExtPage-xTextStart,yExtPage,&iPage);
            LocalUnlock(hT);
        #endif

        // Move down the page 
        iLine++;
    }

    if (!fAbort) {
        // Eject the last page and complete the document 
        Escape(hDC,NEWFRAME,0,0,0);
        Escape(hDC,ENDDOC,0,0,0);
    }    
    else 
        Escape(hDC,ABORTDOC,0,0,0);
            
    // Close the cancel dialog and re-enable main window 
    DestroyWindow(hwndPDlg);

    // Get rid of dialog procedure instances 
    FreeProcInstance (lpfnPDlg);
    FreeProcInstance (lpfnAbort);

    // get rid of print data
    DeleteDC(hDC);
    return 1;
}

