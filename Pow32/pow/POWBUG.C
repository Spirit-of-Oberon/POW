/***************************************************************************
 *                                                                         *
 *  MODULE  :   PowBug.c                                                   *
 *                                                                         *
 *  PURPOSE :   Bug Report option of Pow!                                  *
 *                                                                         *
 *  FUNCTIONS : BugReportDlgProg () - Dialog function for Help/Bug Report  *
 *                                                                         *
 *              BugReport () - Invokes BugReportDlgProc                    *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <string.h>
#include <time.h>

#include "pow.h"
#include "..\powsup\powsupp.h"

#define IDD_BUGREPORT      ID(1100)
#define IDD_BUGTOPIC       1122
#define IDD_BUGTEXT        1102
#define IDD_BUGENVIRONMENT 1125
#define IDD_BUGFINDER      1123
#define IDD_BUGBUG         1104
#define IDD_BUGIMPROVEMENT 1105
#define IDD_BUGQUESTION    1126
#define IDD_BUGIMMEDIATE   1107
#define IDD_BUGNEXTVERSION 1108
#define IDD_BUGNOTURGENT   1109
#define IDD_BUG1           1111
#define IDD_BUG2           1112
#define IDD_BUG3           1113
#define IDD_BUG4           1114
#define IDD_BUG5           1115
#define IDD_BUGADD         1118
#define IDD_BUGCLEAR       1120
#define IDD_BUGCANCEL      1119

/* globals */
HFILE f;
BOOL ok;
int len;

void Out (LPSTR p)
{
    LPSTR out;

    if (ok) {
        AnsiToOem((LPSTR)p,(LPSTR)p);
        out=p;
        while (*p) {
            while (*p && *p!=' ' && *p!='\n' && *p!='-') p++;
            if (*p && len<p-out) {
                if (_lwrite(f,"\r\n",2)!=2)
                    ok=FALSE;
                len=79;
            }
            if (ok && (int)_lwrite(f,(LPSTR)out,p-out+1)!=p-out+1)
                ok=FALSE;
            else
                len-=p-out+1;
            if (*p=='\n')
                len=79;
            if (*p) p++;
            out=p;
        }
    }
}

BOOL FAR PASCAL _export BugReportDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch (msg) {

    case WM_COMMAND: {

        char bugFile[80];

        /* bug file is "pow.bug" in local windows-directory */
        strcpy(bugFile,windowsDir);
        if (bugFile[strlen(bugFile)-1]!='\\')
            strcat(bugFile,"\\");
        strcat(bugFile,"pow.bug");

        switch (wParam) {

        case IDD_BUGADD: {

            OFSTRUCT of;

            len=79;
            ok=TRUE;

            if (OpenFile((LPSTR)bugFile,(LPOFSTRUCT)&of,OF_EXIST)!=-1) {
                f=OpenFile((LPSTR)bugFile,(LPOFSTRUCT)&of,OF_WRITE);
                _llseek(f,0,2);
            }
            else
                f=OpenFile((LPSTR)bugFile,(LPOFSTRUCT)&of,OF_CREATE|OF_WRITE);
            if (f!=-1) {
                char buf[1000];

                /* finder */
                GetDlgItemText(hdlg,IDD_BUGFINDER,(LPSTR)buf,sizeof(buf));
                if (*buf) {
                    Out("\r\nFROM:        ");
                    Out(buf);
                    Out("\r\n");
                }

                /* date and time */
                if (!*buf)
                    Out("\r\n");
                Out("DATE:        ");
                Out(_strdate(buf));
                Out("\r\n");

                /* topic */
                GetDlgItemText(hdlg,IDD_BUGTOPIC,(LPSTR)buf,sizeof(buf));
                if (*buf) {
                    Out("TOPIC:       ");
                    Out(buf);
                    Out("\r\n");
                }

                /* bug type */
                if (SendDlgItemMessage(hdlg,IDD_BUGBUG,BM_GETCHECK,0,0))
                    Out("BUG TYPE:    Bug\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUGIMPROVEMENT,BM_GETCHECK,0,0))
                    Out("BUG TYPE:    Improvement\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUGQUESTION,BM_GETCHECK,0,0))
                    Out("BUG TYPE:    Question\r\n");

                /* fix time */
                if (SendDlgItemMessage(hdlg,IDD_BUGIMMEDIATE,BM_GETCHECK,0,0))
                    Out("FIX IT:      Immediate\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUGNEXTVERSION,BM_GETCHECK,0,0))
                    Out("FIX IT:      next Version\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUGNOTURGENT,BM_GETCHECK,0,0))
                    Out("FIX IT:      not urgent\r\n");

                /* priority */
                if (SendDlgItemMessage(hdlg,IDD_BUG1,BM_GETCHECK,0,0))
                    Out("PRIORITY:    1 (highest)\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUG2,BM_GETCHECK,0,0))
                    Out("PRIORITY:    2\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUG3,BM_GETCHECK,0,0))
                    Out("PRIORITY:    3\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUG4,BM_GETCHECK,0,0))
                    Out("PRIORITY:    4\r\n");
                else if (SendDlgItemMessage(hdlg,IDD_BUG5,BM_GETCHECK,0,0))
                    Out("PRIORITY:    5 (lowest)\r\n");

                /* environment */
                GetDlgItemText(hdlg,IDD_BUGENVIRONMENT,(LPSTR)buf,sizeof(buf));
                if (*buf) {
                    Out("ENVIRONMENT: ");
                    Out(buf);
                    Out("\r\n");
                }

                /* bug text */
                GetDlgItemText(hdlg,IDD_BUGTEXT,(LPSTR)buf,sizeof(buf));
                if (*buf) {
                    Out("\r\n");
                    Out("DESCRIPTION: ");
                    Out(buf);
                    Out("\r\n");
                }

                Out("\r\n##############################################################################\r\n");
                _lclose(f);

                if ((f==-1) || !ok)
                    Message(hdlg,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,(LPSTR)bugFile);
            }
            EndDialog(hdlg,0);
            break;
            }

        case IDD_BUGCLEAR: {

            OFSTRUCT of;
            if (Message(hdlg,MB_YESNO|MB_ICONQUESTION,IDS_REALLYDELETE,(LPSTR)bugFile)==IDYES)
                OpenFile((LPSTR)bugFile,(LPOFSTRUCT)&of,OF_DELETE);
            BringWindowToTop(hdlg);
            break;
            }

        case IDD_CANCEL:

            EndDialog(hdlg,0);
            break;
        }
        break;
    }
    default:

        return FALSE;
    }
    return TRUE;
}

void FAR BugReport ()
{
    FARPROC lpfn;

    lpfn=MakeProcInstance(BugReportDlgProc,hInst);
    DialogBox(hInst,IDD_BUGREPORT,hwndFrame,lpfn);
    FreeProcInstance(lpfn);
}

