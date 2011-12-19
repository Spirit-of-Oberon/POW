/***************************************************************************
 *                                                                         *
 *  MODULE    : PowText.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for customize edit-controls              *
 *                                                                         *
 *  FUNCTIONS : PowTextWndProc   - Window function for edit-controls       *
 *                                                                         *
 *              CursorPos     - Calculate and show new cursor position     *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>

#include "pow.h"
#include "powcomp.h"
#include "..\powsup\powsupp.h"
#include "powopts.h"
#include "powCompiler.h"

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

/* externals */
extern int insMode;

/* globals */
BOOL bypass=FALSE;
BOOL ctrlPend=FALSE;
BOOL marked=FALSE;
BOOL unmark=FALSE;

/* compiler interface functions */
typedef FAR PASCAL HelpCompProc (HANDLE,HWND,LPSTR,WORD,DWORD);


/**************************************************************************
 *                                                                        *
 *  FUNCTION   : CursorPos (hwnd)                                         *
 *                                                                        *
 *  PURPOSE    : Calculate cursor position of edit-control and display    *
 *               in status-bar.                                           *
 *                                                                        *
 **************************************************************************/

void FAR CursorPos (HWND hwnd)
{
    int row,col;
    long sel;

    sel=SendMessage(hwnd,EM_GETSEL,0,0);

    /* no position, when a selection is done 
    if (LOWORD(sel)!=HIWORD(sel))
        return;                              
    OVERRULED: IN THIS CASE TAKE THE START POSITION
    */

    row=(int)SendMessage(hwnd,EM_LINEFROMCHAR,LOWORD(sel),0);
    col=LOWORD(sel)-(int)SendMessage(hwnd,EM_LINEINDEX,row,0);
    NewLineNr(row+1,col+1);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : NoSelect (hwnd)                                          *
 *                                                                        *
 *  PURPOSE    : Returns TRUE, if selection is made                       *
 *                                                                        *
 **************************************************************************/

int Selection (HWND hwnd)
{
    long sel=SendMessage(hwnd,EM_GETSEL,0,0);
    return HIWORD(sel)-LOWORD(sel);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : MarkNext (hwnd)                                          *
 *                                                                        *
 *  PURPOSE    : If system is in overwrite-mode, mark next character      *
 *                                                                        *
 **************************************************************************/

void MarkNext (HWND hwnd)
{
    if ((!insMode) && (Selection(hwnd)<=1)) {
        long sel=SendMessage(hwnd,EM_GETSEL,0,0);
        if (LOWORD(sel)-SendMessage(hwnd,EM_LINEINDEX,(WPARAM)-1,0)==
            SendMessage(hwnd,EM_LINELENGTH,(WPARAM)-1,0))
            marked=FALSE;
        else {
            HIWORD(sel)=LOWORD(sel)+1;
            SendMessage(hwnd,EM_SETSEL,0,sel);
            SendMessage(hwnd,EMULATED_EM_SCROLLCARET,0,0);
            marked=TRUE;
        }
    }
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : MarkNotSel (hwnd)                                        *
 *                                                                        *
 *  PURPOSE    : If no selection is made, mark next character             *
 *                                                                        *
 **************************************************************************/

void MarkNotSel (HWND hwnd)
{
    if ((!insMode) && (Selection(hwnd)==0))
        MarkNext(hwnd);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : UnmarkSel (hwnd)                                         *
 *                                                                        *
 *  PURPOSE    : Undo selection                                           *
 *                                                                        *
 **************************************************************************/

void UnmarkSel (HWND hwnd)
{
    if (marked && (Selection(hwnd)<=1)) {
        long sel=SendMessage(hwnd,EM_GETSEL,0,0);
        HIWORD(sel)=LOWORD(sel);
        SendMessage(hwnd,EM_SETSEL,0,sel);
        SendMessage(hwnd,EMULATED_EM_SCROLLCARET,0,0);
    }
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : CharOk (char)                                            *
 *                                                                        *
 *  PURPOSE    : Check, if character is valid for search string.          *
 *                                                                        *
 **************************************************************************/

BOOL CharOk (char c)
{
    c=DownCase(c);
    return ((c>='0' && c<='9') ||
            (c>='a' && c<='z') ||
            (c=='_')) ? TRUE : FALSE;
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : PowTextWndProc (hwnd,msg,wParam,lParam )                 *
 *                                                                        *
 *  PURPOSE    : Window function for "powtext", a subclass of pre-defined *
 *               class "edit". All messages are passed through, only some *
 *               keys get evaluated.                                      *
 **************************************************************************/

LONG FAR PASCAL _export PowTextWndProc (HWND hwnd,WORD msg,WPARAM wParam,LONG lParam )
{
    LONG ret;
    char rep[2];

    if (bypass) {
        if (msg==WM_PAINT || msg==WM_ERASEBKGND)
            return 0;
    }
    else {
        if (insMode) {
            /* insert mode */
            switch (msg) {

            case WM_CHAR:

                if (wParam==VK_RETURN /* && actConfig.autoIndent*/) {
                    /* auto indent */
                    int n;
                    char *c,spc[80];
                    HANDLE buf;
                    n=(int)SendMessage(hwnd,EM_LINEINDEX,(WPARAM)-1,0);
                    CallWindowProc(edProc,hwnd,WM_CHAR,wParam,0x00390001);
                    buf=(HANDLE)SendMessage(hwnd,EM_GETHANDLE,0,0);
                    c=(char *)LocalLock(buf)+n;
                    n=0;
                    while ((*c++==' ') && (n<sizeof(spc)-1)) {
                        spc[n]=' ';
                        n++;
                    }
                    spc[n]=0;
                    LocalUnlock(buf);
                    CallWindowProc(edProc,hwnd,EM_REPLACESEL,0,(long)(LPSTR)spc);
                    return 0;
                }
                else
                if ((wParam==0x0019) && (HIWORD(lParam)==0x002c)) {
                    /* delete line (^Y) */
                    long l,lin1,lin2;

                    lin1=SendMessage(hwnd,EM_LINEINDEX,(WPARAM)-1,0);
                    lin2=SendMessage(hwnd,EM_LINEFROMCHAR,LOWORD(lin1),0);
                    lin2=SendMessage(hwnd,EM_LINEINDEX,LOWORD(lin2)+1,0);
                    l=(lin2<<16)+lin1;
                    SendMessage(hwnd,EM_SETSEL,0,l);
                    SendMessage(hwnd,WM_CLEAR,0,0);
                    SendMessage(hwnd,EMULATED_EM_SCROLLCARET,0,0);
                    return 0;
                }
                else
                if ((wParam==VK_TAB)/* && (!actConfig.useTabs)*/) {
                    int i;
                    for (i=1;i<=4/*actConfig.tabSize*/;i++)
                        CallWindowProc(edProc,hwnd,WM_CHAR,VK_SPACE,0);
                    return 0;
                }

            default:
                ;
            }
        }
        else {
            /* overwrite mode */
            switch (msg) {

            case WM_KEYDOWN:

                if (wParam==VK_CONTROL)
                    ctrlPend=TRUE;
                else
                    switch(wParam) {

                    case VK_LEFT:
                    case VK_RIGHT:
                    case VK_UP:
                    case VK_DOWN:
                    case VK_HOME:
                    case VK_END:
                    case VK_PRIOR:
                    case VK_NEXT:
                    case VK_DELETE:
                        UnmarkSel(hwnd);
                    }
                break;

            case WM_KEYUP:

                if (wParam==VK_CONTROL)
                    ctrlPend=FALSE;
                break;

            case WM_CHAR:

                if (ctrlPend || (Selection(hwnd)>1))
                    break;

                switch(wParam) {

                case VK_TAB:

                    if (1/*!actConfig.useTabs*/) {
                        int i;
                        UnmarkSel(hwnd);
                        for (i=1;i<=4/*actConfig.tabSize*/;i++)
                            CallWindowProc(edProc,hwnd,WM_CHAR,VK_SPACE,0);
                        MarkNext(hwnd);
                        return 0;
                    }
                    /* no break! */

                case VK_BACK:

                    UnmarkSel(hwnd);
                    /* no break! */

                case VK_DELETE:

                    return CallWindowProc(edProc,hwnd,msg,wParam,lParam);

                case VK_RETURN:

                    CallWindowProc(edProc,hwnd,WM_KEYDOWN,VK_HOME,0);
                    CallWindowProc(edProc,hwnd,WM_KEYDOWN,VK_DOWN,0);
                    MarkNext(hwnd);
                    return 0;

                default: {

                    bypass=TRUE;
                    if (marked) {
                        rep[0]=(char)wParam;
                        rep[1]=0;
                        CallWindowProc(edProc,hwnd,EM_REPLACESEL,0,(LONG)(LPSTR)rep);
                    }
                    else
                        CallWindowProc(edProc,hwnd,msg,wParam,lParam);
                    MarkNext(hwnd);
                    bypass=FALSE;
                    return 0;
                    }
                }
            }
        }
    }

    ret=CallWindowProc(edProc,hwnd,msg,wParam,lParam);

    if (bypass)
        return ret;

    switch(msg) {

    case WM_KEYDOWN:

        if (ctrlPend)
            break;

        if (wParam==VK_INSERT) {
            ToggleInsert();
            if (insMode)
                UnmarkSel(hwnd);
        } /*ERROR?*/
        MarkNext(hwnd);
        break;            

    case WM_KEYUP:
                           
        if (ctrlPend)
            break;
        CursorPos(hwnd);
        MarkNotSel(hwnd);
        break;

    case WM_LBUTTONUP:

        MarkNotSel(hwnd);
        /* no break! */
    case WM_LBUTTONDOWN:

        CursorPos(hwnd);
        break;

    case WM_RBUTTONDOWN:

        if (IsCompilerInterfaceLoaded()/* && actConfig.mouseTopic*/) {

            /* right mouse button pressed -> call compiler for topic help */
            long l;
            WORD siz;
            HLOCAL h;
            char key[100];
//            FARPROC lpHelp;
            PSTR buf,beg,end,k;

            h=(HLOCAL)SendMessage(hwnd,EM_GETHANDLE,0,0);
            siz=LocalSize(h);
            buf=LocalLock(h);
            CallWindowProc(edProc,hwnd,WM_LBUTTONDOWN,MK_LBUTTON,lParam);
            CallWindowProc(edProc,hwnd,WM_LBUTTONUP,MK_LBUTTON,lParam);
            l=CallWindowProc(edProc,hwnd,EM_GETSEL,0,0);
            beg=buf+LOWORD(l);
            end=buf+LOWORD(l);
            while ((beg>buf) && CharOk(*beg)) beg--;
            while ((end<buf+siz-1) && CharOk(*end)) end++;
            if (!CharOk(*beg)) beg++;
            if (!CharOk(*end)) end--;
            if ((end>beg) && (end-beg+1>=sizeof(key)))
                end=beg+sizeof(key)-2;
            k=key;
            while (beg<=end)
                *k++=*beg++;
            *k=0;
            LocalUnlock(h);
//            lpHelp=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_HELPCOMPILER));
            (*compHelp)(hCompData,hwnd,(LPSTR)defaultDir,HELP_PARTIALKEY,(DWORD)(LPSTR)key);
        }
        break;
    }
    return ret;
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : PowReadWndProc (hwnd,msg,wParam,lParam )                 *
 *                                                                        *
 *  PURPOSE    : Window function for "powread", a subclass of pre-defined *
 *               class "edit". All messages are passed through, only the  *
 *               edit-key messages are stripped.                          *
 **************************************************************************/

LONG FAR PASCAL _export PowReadWndProc (HWND hwnd,WORD msg,WPARAM wParam,LONG lParam )
{
    switch (msg) {

    case WM_CHAR:

        if ((wParam==VK_RETURN) || (wParam==VK_EXECUTE)) {
            /* goto erroneous line */
            GotoError(hwnd);
            return 0;
        }
        else
        if ((wParam!=VK_LEFT) && (wParam!=VK_RIGHT) &&
            (wParam!=VK_UP) && (wParam!=VK_DOWN) &&
            (wParam!=VK_PRIOR) && (wParam!=VK_NEXT) &&
            (wParam!=VK_END) && (wParam!=VK_HOME))
            return 0;
        break;

    case WM_LBUTTONDBLCLK:

        /* goto erroneous line */
        GotoError(hwnd);
        return 0;
    }
    return CallWindowProc(edProc,hwnd,msg,wParam,lParam);
}
