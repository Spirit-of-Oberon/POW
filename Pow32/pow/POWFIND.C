/***************************************************************************
 *                                                                         *
 *  MODULE  : PowFind.c                                                    *
 *                                                                         *
 *  PURPOSE : Code to do text searches in Pow.                             *
 *                                                                         *
 *  FUNCTIONS :                                                            *
 *                                                                         *
 *        RealSlowCompare () - Compares subject string with target string. *
 *        FindDlgProc ()     - Dialog function for Search/Find.            *
 *        Find ()            - Invokes FindDlgProc ()                      *
 *        Replace ()         - Invokes ReplaceDlgProc ()                   *
 *        FindNext ()        - Repeats last search ()                      *
 *                                                                         *
 ***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <windows.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powfind.h"
#include "powhelp.h"
#include "powed.h"
#include "resource.h"

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

BOOL FindDown=TRUE;            /* Default search dir is down */
BOOL FindCase=FALSE;           /* Turn case sensitivity off */
BOOL FindWord=FALSE;           /* Find whole word */
BOOL FindAsk=FALSE;            /* Ask before replacing */
BOOL ReplaceAll=FALSE;         /* Replace all occurences */
BOOL WasReplace=FALSE;         /* Last command was not replace */
BOOL HasFound=FALSE;           /* The string has been found? */
HANDLE GotoList=0;             /* List of searchstrings till now */
HANDLE FindList=0;             /* List of searchstrings till now */
HANDLE ReplaceList=0;          /* List of replacestrings */
char FindTxt[100]="";          /* Initialize search string  */
char ReplaceTxt[100]="";       /* Initialize replace string  */


/***************************************************************************
 *                                                                         *
 *  FUNCTION   : FindDlgProc (hdlg,message,wParam,lParam)                  *
 *                                                                         *
 *  PURPOSE    : Dialog function for the Search/Find command. Prompts user *
 *               for target string, case/word flags and search direction.  *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export FindDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch (msg) {

    case WM_INITDIALOG: {
        long l;
        int i,n;
        char buf[80];

        HasFound=FALSE;
        
        /* Check/uncheck case and word search button */
        SendDlgItemMessage(hdlg,IDD_FINDCASE,BM_SETCHECK,FindCase,0);
        SendDlgItemMessage(hdlg,IDD_FINDWORD,BM_SETCHECK,FindWord,0);

        /* Set Direction buttons */
        SendDlgItemMessage(hdlg,IDD_FINDUP,BM_SETCHECK,!FindDown,0);
        SendDlgItemMessage(hdlg,IDD_FINDDOWN,BM_SETCHECK,FindDown,0);

        /* Insert last search strings to combobox */
        n=CountList(FindList);
        for (i=1;i<=n;i++) {
            GetStr(FindList,i,(LPSTR)buf);
            SendDlgItemMessage(hdlg,IDD_FINDTEXT,CB_ADDSTRING,0,(long)(LPSTR)buf);
            if (i==n) {
                LOWORD(l)=0;
                HIWORD(l)=strlen(buf);
                SetWindowText(GetDlgItem(hdlg,IDD_FINDTEXT),(LPSTR)buf);
                SendDlgItemMessage(hdlg,IDD_FINDTEXT,CB_SETEDITSEL,0,l);
            }
        }
        break;
    }

    case WM_COMMAND: {

        switch (wParam) {

        case IDD_FINDDOWN:

            SendDlgItemMessage(hdlg,IDD_FINDUP,BM_SETCHECK,FALSE,0);
            break;

        case IDD_FINDUP:

            SendDlgItemMessage(hdlg,IDD_FINDDOWN,BM_SETCHECK,FALSE,0);
            break;

        case IDOK:

            /* get button states */
            FindCase=(int)SendDlgItemMessage(hdlg,IDD_FINDCASE,BM_GETCHECK,0,0);
            FindWord=(int)SendDlgItemMessage(hdlg,IDD_FINDWORD,BM_GETCHECK,0,0);
            FindDown=(int)SendDlgItemMessage(hdlg,IDD_FINDDOWN,BM_GETCHECK,0,0);

            /* Get search string */
            GetDlgItemText(hdlg,IDD_FINDTEXT,FindTxt,sizeof(FindTxt));

            /* Add text to list */
            if (*FindTxt && !FindStr(FindList,FindTxt))
                AddStr((LPHANDLE)&FindList,(LPSTR)FindTxt);

            /* Find the text */
            if (*FindTxt) {
                WasReplace=FALSE;
                HasFound=EditSearch(GetActiveEditWindow(hwndMDIClient),FindTxt,FindCase,FindDown,FindWord);
            }
            EndDialog (hdlg,1);
            break;

        case IDCANCEL:

            EndDialog (hdlg,0);
            break;

        case IDD_HELP:

            WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Suchen_von_Text);
            break;

        default:

            return FALSE;
        }
        break;
    }
    default:

        return FALSE;
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : Find ()                                                   *
 *                                                                         *
 *  PURPOSE    : Invokes the Search/Find dialog.                           *
 *                                                                         *
 ***************************************************************************/

VOID FAR Find()
{
    int ret;
    FARPROC lpfn;

    if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) {
        lpfn=MakeProcInstance(FindDlgProc,hInst);
        ret=DialogBox(hInst,IDD_FIND,hwndFrame,lpfn);
        FreeProcInstance(lpfn);
        if (ret && !HasFound)
           Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTFIND,FindTxt);
        SetFocus(GetActiveEditWindow(hwndMDIClient));
        //SetFocus((HWND)GetWindowLong(GetActiveEditWindow(hwndMDIClient),GWL_HWNDEDIT));
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ReplaceDlgProc (hdlg,message,wParam,lParam)               *
 *                                                                         *
 *  PURPOSE    : Dialog function for the Search/Replace command. Prompts   *
 *               for target/replace string, case/word flags and direction. *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export ReplaceDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch (msg) {

    case WM_INITDIALOG: {
        long l;
        int i,n;
        char buf[80]; 
        
        HasFound=FALSE;

        /* Check/uncheck case, word and all search button */
        SendDlgItemMessage(hdlg,IDD_REPLACECASE,BM_SETCHECK,FindCase,0);
        SendDlgItemMessage(hdlg,IDD_REPLACEWORD,BM_SETCHECK,FindWord,0);
        SendDlgItemMessage(hdlg,IDD_REPLACEALL,BM_SETCHECK,ReplaceAll,0);
        SendDlgItemMessage(hdlg,IDD_REPLACEASK,BM_SETCHECK,FindAsk,0);

        /* Set Direction buttons */
        SendDlgItemMessage(hdlg,IDD_REPLACEUP,BM_SETCHECK,!FindDown,0);
        SendDlgItemMessage(hdlg,IDD_REPLACEDOWN,BM_SETCHECK,FindDown,0);

        /* Insert last search strings to combobox */
        n=CountList(FindList);
        for (i=1;i<=n;i++) {
            GetStr(FindList,i,(LPSTR)buf);
            SendDlgItemMessage(hdlg,IDD_REPLACESRC,CB_ADDSTRING,0,(long)(LPSTR)buf);
            if (i==n) {
                LOWORD(l)=0;
                HIWORD(l)=strlen(buf);
                SetWindowText(GetDlgItem(hdlg,IDD_REPLACESRC),(LPSTR)buf);
                SendDlgItemMessage(hdlg,IDD_REPLACESRC,CB_SETEDITSEL,0,l);
            }
        }

        /* Insert last replace strings to combobox */
        n=CountList(ReplaceList);
        for (i=1;i<=n;i++) {
            GetStr(ReplaceList,i,(LPSTR)buf);
            SendDlgItemMessage(hdlg,IDD_REPLACEDST,CB_ADDSTRING,0,(long)(LPSTR)buf);
            if (i==n) {
                LOWORD(l)=0;
                HIWORD(l)=strlen(buf);
                SetWindowText(GetDlgItem(hdlg,IDD_REPLACEDST),(LPSTR)buf);
                SendDlgItemMessage(hdlg,IDD_REPLACEDST,CB_SETEDITSEL,0,l);
            }
        }
        break;
    }

    case WM_COMMAND: {

        switch (wParam) {

        case IDD_REPLACEDOWN:

            SendDlgItemMessage(hdlg,IDD_REPLACEUP,BM_SETCHECK,FALSE,0);
            break;

        case IDD_REPLACEUP:

            SendDlgItemMessage(hdlg,IDD_REPLACEDOWN,BM_SETCHECK,FALSE,0);
            break;

        case IDOK:

            /* get button states */
            FindCase=(int)SendDlgItemMessage(hdlg,IDD_REPLACECASE,BM_GETCHECK,0,0);
            FindWord=(int)SendDlgItemMessage(hdlg,IDD_REPLACEWORD,BM_GETCHECK,0,0);
            ReplaceAll=(int)SendDlgItemMessage(hdlg,IDD_REPLACEALL,BM_GETCHECK,0,0);
            FindDown=(int)SendDlgItemMessage(hdlg,IDD_REPLACEDOWN,BM_GETCHECK,0,0);
            FindAsk=(int)SendDlgItemMessage(hdlg,IDD_REPLACEASK,BM_GETCHECK,0,0);

            /* Get search and replace string */
            GetDlgItemText(hdlg,IDD_REPLACESRC,FindTxt,sizeof(FindTxt));
            GetDlgItemText(hdlg,IDD_REPLACEDST,ReplaceTxt,sizeof(ReplaceTxt));

            /* Add texts to list */
            if (*FindTxt!=0) {
                if (!FindStr(FindList,FindTxt))
                    AddStr((LPHANDLE)&FindList,(LPSTR)FindTxt);
                if (!FindStr(ReplaceList,ReplaceTxt))
                    AddStr((LPHANDLE)&ReplaceList,(LPSTR)ReplaceTxt);
            }

            /* Replace Selections */
            if (*FindTxt) {
                HWND active;
                
                WasReplace=TRUE;
                active=GetFocus();
                HasFound=EditReplace(GetActiveEditWindow(hwndMDIClient),FindTxt,ReplaceTxt,FindCase,FindDown,FindWord,ReplaceAll,FindAsk);
                SetFocus(active);
            }
            EndDialog (hdlg,1);
            break;

        case IDCANCEL:

            EndDialog (hdlg,0);
            break;

        case IDD_HELP:

            WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Ersetzen_von_Text);
            break;

        default:

            return FALSE;
        }
        break;
    }
    default:

        return FALSE;
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : Replace ()                                                *
 *                                                                         *
 *  PURPOSE    : Invokes the Search/Replace dialog.                        *
 *                                                                         *
 ***************************************************************************/

VOID FAR Replace()
{
    int ret;
    FARPROC lpfn;

    if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) {
        lpfn=MakeProcInstance(ReplaceDlgProc,hInst);
        ret=DialogBox(hInst,IDD_REPLACE,hwndFrame,lpfn);
        FreeProcInstance(lpfn);
        if (ret && !HasFound)
           Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTFIND,FindTxt);
        SetFocus(GetActiveEditWindow(hwndMDIClient));
        //SetFocus((HWND)GetWindowLong(GetActiveEditWindow(hwndMDIClient),GWL_HWNDEDIT));
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GotoLineDlgProc (hdlg,message,wParam,lParam)              *
 *                                                                         *
 *  PURPOSE    : Dialog function for the Search/Goto Linenr command.       *
 *               Prompts for target line number.                           *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export GotoLineDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch (msg) {

    case WM_INITDIALOG: {
        int n;
        char buf[80];

        n=CountList(GotoList);
        if (n) {
            GetStr(GotoList,n,(LPSTR)buf);
            SetWindowText(GetDlgItem(hdlg,IDD_GOTONUMBER),(LPSTR)buf);
        }
        SendDlgItemMessage(hdlg,IDD_GOTONUMBER,EM_SETSEL,0,0);
        break;
    }

    case WM_COMMAND: {

        switch (wParam) {

        case IDOK: {

            int i;
            char buf[80];

            /* Get line number */
            GetDlgItemText(hdlg,IDD_GOTONUMBER,(LPSTR)buf,sizeof(buf));

            /* Is string a valid number? */
            if ((i=atoi(buf)) && (i>0)) {
                /* Position cursor */
                EditGotoPos(GetActiveEditWindow(hwndMDIClient),i,1);
                
                /* Append number to list */
                if (!FindStr(GotoList,(LPSTR)buf))
                    AddStr((LPHANDLE)&GotoList,(LPSTR)buf);
            }
            /*** FALL THRU ***/
            }

        case IDCANCEL:

            EndDialog (hdlg,0);
            break;

        case IDD_HELP:

            WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Zu_Zeilennummer_verzweigen);
            break;

        default:

            return FALSE;
        }
        break;
    }
    default:

        return FALSE;
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GotoLine ()                                               *
 *                                                                         *
 *  PURPOSE    : Invokes the Goto Line dialog.                             *
 *                                                                         *
 ***************************************************************************/

VOID FAR GotoLine ()
{
    FARPROC lpfn;

    if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) {
        lpfn=MakeProcInstance(GotoLineDlgProc,hInst);
        DialogBox(hInst,IDD_GOTOLINE,hwndFrame,lpfn);
        FreeProcInstance(lpfn);
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : FindNext ()                                               *
 *                                                                         *
 *  PURPOSE    : Repeats the last search command.                          *
 *                                                                         *
 ***************************************************************************/

VOID FAR FindNext ()
{
    if (WasReplace) {
        if (!EditReplace(GetActiveEditWindow(hwndMDIClient),FindTxt,ReplaceTxt,FindCase,FindDown,FindWord,ReplaceAll,FindAsk))
            Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTFIND,FindTxt);
    }
    else {
        if (!EditSearch(GetActiveEditWindow(hwndMDIClient),FindTxt,FindCase,FindDown,FindWord))
            Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTFIND,FindTxt);
    }
}

