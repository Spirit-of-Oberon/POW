/***************************************************************************
 *                                                                         *
 *  MODULE    : PowFile.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for File I/O for Multipad.               *
 *                                                                         *
 *  FUNCTIONS : AlreadyOpen   - Determines if a file is already open.      *
 *                                                                         *
 *              AddFile       - Creates a new MDI window and, if specified,*
 *              loads a file into it.                      *
 *                                                                         *
 *              LoadFile      - Loads a file into a MDI window.            *
 *                                                                         *
 *              ReadFromFile  - Calls File/Open dialog and appropriately   *
 *                              responds to the user's input.              *
 *                                                                         *
 *              SaveFile      - Saves the contents of a MDI window's edit  *
 *                              control to a file.                         *
 *                                                                         *
 *              ChangeFile    - Calls File/SaveAs dialog.                  *
 *                                                                         *
 ***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <windows.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powed.h"
#include "powopen.h"

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : AlreadyOpen(szFile)                                        *
 *                                                                          *
 *  PURPOSE    : Checks to see if the file described by the string pointed  *
 *               to by 'szFile' is already open.                            *
 *                                                                          *
 *  RETURNS    : a handle to the described file's window if that file is    *
 *               already open;  NULL otherwise.                             *
 *                                                                          *
 ****************************************************************************/

HWND FAR AlreadyOpen (LPSTR szFile)
{
    int     iDiff;
    HWND    hwndCheck;
    char    szChild[80];
    char    fil[80];
    LPSTR   lpChild, lpFile;

    lstrcpy((LPSTR)fil,szFile);

    /* Check each MDI child window in Pow */
    for (   hwndCheck = GetWindow(hwndMDIClient, GW_CHILD);
        hwndCheck;
        hwndCheck = GetWindow(hwndCheck, GW_HWNDNEXT)   ) {
    /* Initialization  for comparison */
    lpFile = AnsiLower((LPSTR)fil);
    iDiff = 0;

    /* Skip icon title windows */
    if (GetWindow(hwndCheck, GW_OWNER))
        continue;

    /* Get current child window's name */
    GetWindowText(hwndCheck, (LPSTR)szChild, sizeof(szChild));
    lpChild=AnsiLower((LPSTR)szChild);

    /* Compare window name with given name */
    while ((*lpChild) && (*lpFile) && (!iDiff)){
        if (*lpChild != *lpFile)
            iDiff = 1;                
        lpChild++;
        lpFile++;
    }

    /* If the two names matched, the file is already   */
    /* open -- return handle to matching child window. */
    if (!iDiff)
        return(hwndCheck);
    }
    /* No match found -- file is not open -- return NULL handle */
    return(0);
}

/****************************************************************************
 *                                      *
 *  FUNCTION   : AddFile (lpName)                       *
 *                                      *
 *  PURPOSE    : Creates a new MDI window. If the lpName parameter is not   *
 *       NULL, it loads a file into the window.             *
 *                                      *
 *  RETURNS    : HWND  - A handle to the new window.                *
 *                                      *
 ****************************************************************************/

HWND FAR AddFile (LPSTR pName)
{
    return AddFileAt(pName,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT);
}

HWND FAR AddFileAt (LPSTR pName,int x,int y,int dx,int dy)
{
    HWND hwnd;
    BOOL hasTitle;

    char sz[160];
    MDICREATESTRUCT mcs;
                                 
    if ((!pName) || (!*pName)) {
    /* The pName parameter is NULL -- load the "Untitled" string from */
    /* STRINGTABLE and set the title field of the MDI CreateStruct.    */
        LoadString (hInst, IDS_UNTITLED, sz, sizeof(sz));
        mcs.szTitle = (LPSTR)sz;
        hasTitle=FALSE;
    }
    else {
    /* Title the window with the fully qualified pathname obtained by
     * calling OpenFile() with the OF_PARSE flag (in function
     * AlreadyOpen(), which is called before AddFile().
     */ 
        mcs.szTitle=pName;
        hasTitle=TRUE;
    }

    mcs.szClass = szChild;
    mcs.hOwner  = hInst;

    /* Use the default size for the window */
    mcs.x = x;
    mcs.cx = dx;
    mcs.y = y;
    mcs.cy = dy;
                     
    /* Set the style DWORD of the window to default */
    mcs.style = styleDefault;
    if (GetActiveEditWindow(hwndMDIClient) && (GetWindowLong(GetActiveEditWindow(hwndMDIClient),GWL_STYLE)&WS_MAXIMIZE))
        mcs.style+=WS_MAXIMIZE;
       
    if ((!pName) || TRUE || FileExists(pName) || (Message(hwndFrame,2,IDS_NOFILE,pName)==IDOK)) {
        /* tell the MDI Client to create the child */
        hwnd=(HWND)SendMessage(hwndMDIClient,WM_MDICREATE,0,(LONG)(LPMDICREATESTRUCT)&mcs);
                  
        /* Did we get a file? Read it into the window */
        if ((pName) && (*pName) && FileExists(pName)) {
            if (!LoadFile(hwnd,pName)){
                /* File couldn't be loaded -- close window */
                SendMessage(hwndMDIClient,WM_MDIDESTROY,(WPARAM) hwnd,0);
                hwnd=0;
            }
        }
        if (hasTitle)
            SetWindowWord(hwnd, GWW_UNTITLED, FALSE);
    }
    else
        hwnd=0;

    return hwnd;
}

/****************************************************************************
 *                                      *
 *  FUNCTION   : LoadFile (lpName)                      *
 *                                      *
 *  PURPOSE    : Given the handle to a MDI window and a filename, reads the *
 *       file into the window's edit control child.                 *
 *                                      *
 *  RETURNS    : TRUE  - If file is sucessfully loaded.             *
 *       FALSE - Otherwise.                     *
 *                                      *
 ****************************************************************************/

int FAR LoadFile (HWND hwnd,LPSTR pName)
{                            
    if (EditLoadFile(hwnd,pName)) {
        SetWindowWord(hwnd,GWW_UNTITLED,FALSE);
        return TRUE;
    }
    return FALSE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : ReadFromFile(hwnd)                                         *
 *                                                                          *
 *  PURPOSE    : Called in response to a File/Open menu selection. It asks  *
 *               the user for a file name and responds appropriately.       *
 *                                                                          *
 ****************************************************************************/

VOID FAR ReadFromFile (HWND hwnd)
{
    char szFile[MAXPATHLENGTH];
    HWND hwndFile;

    strcpy(szFile,SrcExt[0].ext);
    GetFileName((LPSTR)szFile,"Open File",FALSE,SrcExt,srcN,hwnd);

    /* If the result is not the empty string -- take appropriate action */
    if (*szFile) {
    /* Is file already open?? */
    if (hwndFile = AlreadyOpen((LPSTR)szFile)) {
        /* Yes -- bring the file's window to the top */
        BringWindowToTop(hwndFile);
    }
    else {
        /* No -- make a new window and load file into it */
        AppendHistory(filHistory,szFile);
        AddFile(szFile);
    }
    }
}

/****************************************************************************
 *                                      *
 *  FUNCTION   : SaveFile (hwnd)                        *
 *                                      *
 *  PURPOSE    : Saves contents of current edit control to disk.        *
 *                                      *
 ****************************************************************************/

int FAR SaveFile(HWND hwnd)
{
    char file[MAXPATHLENGTH],
		 drive[5],
		 dir[MAXPATHLENGTH],
		 fil[MAXPATHLENGTH],
		 ext[MAXPATHLENGTH];

    GetWindowText(hwnd,file,sizeof(file));
    _splitpath(file,drive,dir,fil,ext);
    if (strlen(ext)<=1)
        LoadString(hInst,IDS_ADDEXT,(LPSTR)file+lstrlen(file)-1,4);
    return EditSaveFile(hwnd,(LPSTR)file);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ChangeFile (hwnd)                                         *
 *                                                                         *
 *  PURPOSE    : Invokes the File/SaveAs dialog.                           *
 *                                                                         *
 *  RETURNS    : TRUE  - if user selected OK or NO.                        *
 *               FALSE - otherwise.                                        *
 *                                                                         *
 ***************************************************************************/

BOOL FAR ChangeFile (hwnd)
HWND hwnd;
{
    char new[80],drv[10],path[80],fil[40],ext[80],old[80];
    
    strcpy(old,SrcExt[0].ext);
    GetFileName((LPSTR)old,"Save As",TRUE,SrcExt,srcN,hwnd);
    if (strlen(old)>0) {
        if (_fullpath(new,old,sizeof(new))!=NULL) {
                                             
            _splitpath(new,drv,path,fil,ext);
            #ifndef _WIN32
               /* change filename to 8.3 layout */
               fil[8]=0;
            #endif

            strcpy(new,drv);
            strcat(new,path);
            strcat(new,fil);
            strcat(new,ext);
            
            #ifndef _WIN32
               AnsiLower((LPSTR)new);
            #endif
            AppendHistory(filHistory,new);
            SetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)new);
            SetWindowWord(GetActiveEditWindow(hwndMDIClient),GWW_UNTITLED,0);
            SaveFile(hwnd);
            return TRUE;
        }
        else Message(hwnd,1,IDS_ILLFNM,(LPSTR)old);
    }
    return FALSE;
}
