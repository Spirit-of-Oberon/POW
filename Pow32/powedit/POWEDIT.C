/***************************************************************************
 *                                                                         *
 *            ppppppppp      oooooo     www       www     xxxx             *
 *            pppppppppp    oooooooo   www         www   xxxxxx            *
 *            ppp    pppp  ooo    ooo  www         www   xxxxxx            *
 *            ppp    pppp  oo      oo  www   www   www   xxxxxx            *
 *            pppppppppp   oo      oo   www  www  www     xxxx             *
 *            ppppppppp    ooo    ooo   wwww www wwww      xx              *
 *            ppp           oooooooo     wwwwwwwwwww      xxxx             *
 *            ppp            oooooo       wwwwwwwww        xx              *
 *                                                                         *
 *            (Programmers Open Workbench for MS-Windows)                  *
 *                                                                         *
 *            Part of project: Editor                                      *
 *            Version   (19.4.95)   start                                  *
 *            Version   (30.5.95)   first version integrated in Pow! 2.0   *
 *                                                                         *
 ***************************************************************************/


/* used libraries */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <commdlg.h>

#include "powedfnd.h"
#include "powedprn.h"
#include "powedit.h"
         
/* global definitions */
#define EDITCLASS "powedit"                      
#define READONLYCLASS "poweditread"                      
#define HELPFILENAME "powedit.hlp"

#define GWL_ED_CHANGED     (extraOffset+0)
#define GWL_ED_NEXTOFFSET  (extraOffset+4)
#define GWL_ED_FONT        (extraOffset+8)
#define GWL_ED_EXTRA       (extraOffset+12)
                     
#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

/* global variables */
BOOL bypass=FALSE;
BOOL ctrlPend=FALSE;
BOOL marked=FALSE;
BOOL unmark=FALSE;
BOOL insMode=TRUE;
HINSTANCE hInstDLL;
FARPROC editWndProc;
FARPROC readOnlyWndProc;
Options options;
int extraOffset=0;
char languageHelpFile[128];
Options oldOptions;

/* forward declarations */
long FAR PASCAL PowEditWndProc (HWND,UINT,WPARAM,LONG);
long FAR PASCAL PowReadOnlyWndProc (HWND,UINT,WPARAM,LONG);
void FAR PASCAL ShowHelp (HWND);

/***********************
 * ini-file management *
 ***********************/
              
void GetIniFileName (LPSTR name)
{
    char buf[128];
                 
    GetWindowsDirectory(buf,sizeof(buf));
    if (buf[lstrlen(buf)-1]!='\\')
        lstrcat(buf,"\\");
    lstrcpy(name,buf);
    lstrcat(name,"powedit.ini");
}
                               
void ReadIniFile (void)
{
    char ini[128];      
    
    GetIniFileName(ini);
    GetPrivateProfileString("powedit","FontName","Courier",options.fontName,sizeof(options.fontName),ini);
    options.fontSize=GetPrivateProfileInt("powedit","FontSize",13,ini);
    options.tabWidth=GetPrivateProfileInt("powedit","TabWidth",4,ini);
    options.autoIndent=GetPrivateProfileInt("powedit","AutoIndent",1,ini);
    options.useTabs=GetPrivateProfileInt("powedit","UseTabs",1,ini);
    options.mouseTopic=GetPrivateProfileInt("powedit","MouseTopic",1,ini);
}                               

#define WriteValue(entry,value) itoa(value,buf,10); WritePrivateProfileString("powedit",entry,buf,ini);

void WriteIniFile (void)
{
    char ini[128],buf[20];

    GetIniFileName(ini);

    WritePrivateProfileString("powedit","FontName",options.fontName,ini);
    WriteValue("FontSize",options.fontSize);
    WriteValue("TabWidth",options.tabWidth);
    WriteValue("AutoIndent",options.autoIndent);
    WriteValue("UseTabs",options.useTabs);
    WriteValue("MouseTopic",options.mouseTopic);
}                               
                               
/***************************************************************************
 * window function for "poweditfield", a subclass of control class "edit"; *
 * all messages are passed through, only background erasure is kept.       *
 ***************************************************************************/

/* show cursor position of edit-control in status-bar */
void CursorPos (HWND hwnd)
{
    int row,col;
    long sel;

    sel=SendMessage(hwnd,EM_GETSEL,0,0);
    row=(int)SendMessage(hwnd,EM_LINEFROMCHAR,LOWORD(sel),0);
    col=LOWORD(sel)-(int)SendMessage(hwnd,EM_LINEINDEX,row,0);
    SendMessage(GetParent(hwnd),PEM_SHOWLINENR,col+1,(long)(row+1));
}

/* return TRUE, if selection is made */
int Selection (HWND hwnd)
{
    long sel=SendMessage(hwnd,EM_GETSEL,0,0);
    return HIWORD(sel)-LOWORD(sel);
}

/* mark next char for overwrite-mode */
void MarkNext (HWND hwnd)
{
    if ((!insMode) && (Selection(hwnd)<=1)) {
        long sel=SendMessage(hwnd,EM_GETSEL,0,0);
        if (LOWORD(sel)-SendMessage(hwnd,EM_LINEINDEX,(WORD)-1,0)==
            SendMessage(hwnd,EM_LINELENGTH,(WORD)-1,0))
            marked=FALSE;
        else {
            HIWORD(sel)=LOWORD(sel)+1;
            SendMessage(hwnd,EM_SETSEL,0,sel);
            SendMessage(hwnd,EM_SCROLLCARET,0,0);
            marked=TRUE;
        }
    }
}

/* if no selection is made, mark next character */
void MarkNotSel (HWND hwnd)
{
    if ((!insMode) && (Selection(hwnd)==0))
        MarkNext(hwnd);
}

/* undo selection */
void UnmarkSel (HWND hwnd)
{
    if (marked && (Selection(hwnd)<=1)) {
        long sel=SendMessage(hwnd,EM_GETSEL,0,0);
        HIWORD(sel)=LOWORD(sel);
        SendMessage(hwnd,EM_SETSEL,0,sel);
        SendMessage(hwnd,EM_SCROLLCARET,0,0);
    }
}

/* check if next character is letter or digit or underscore */
BOOL CharOk (char c)
{
    return ((c>='0' && c<='9') ||
            (c>='a' && c<='z') ||
            (c>='A' && c<='Z') ||
            (c=='_')) ? TRUE : FALSE;
}
 
/* check if edit buffer needs resizing */
void CheckSize (HWND hwnd)
{             
    HANDLE hloc,hglo;
    LPSTR buf,temp;
    unsigned size,len,newsize;
                        
    hloc=(HANDLE)CallWindowProc(editWndProc,hwnd,EM_GETHANDLE,0,0);
    size=LocalSize(hloc);
    buf=(LPSTR)LocalLock(hloc);
    len=lstrlen(buf);
    if (len+500>size) {
        newsize=size+1000;
        if (newsize>60000L)
            newsize=60000L;
        if (newsize>size) {
            if (hglo=GlobalAlloc(GHND,newsize)) {
                temp=GlobalLock(hglo);
                lstrcpy(temp,buf);
                LocalUnlock(hloc);
                LocalFree(hloc);
                if ((hloc=LocalAlloc(LMEM_MOVEABLE,newsize))==0)
                    hloc=LocalAlloc(LMEM_MOVEABLE,size);
                buf=(LPSTR)LocalLock(hloc);
                lstrcpy(buf,temp);
                memset(&buf[len],1,newsize-len);
                buf[newsize-1]=0;
                LocalUnlock(hloc);
                GlobalUnlock(hglo);
                GlobalFree(hglo);
                CallWindowProc(editWndProc,hwnd,EM_SETHANDLE,(WPARAM)hloc,(LPARAM)0);
                buf=(LPSTR)LocalLock(hloc);
                memset(&buf[len],0,newsize-len);
            }
        }
    }
    LocalUnlock(hloc);
}

/* window procedure for custom edit control */
long FAR PASCAL _export PowEditWndProc (HWND hwnd,UINT msg,WPARAM wParam,LONG lParam )
{
    long ret;
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

                if (wParam==VK_RETURN && options.autoIndent) {
                    /* auto indent */
                    int n;
                    char *c,spc[80];
                    HANDLE buf;
                    n=(int)SendMessage(hwnd,EM_LINEINDEX,(WORD)-1,0);
                    CallWindowProc(editWndProc,hwnd,WM_CHAR,wParam,0x00390001);
                    buf=(HANDLE)SendMessage(hwnd,EM_GETHANDLE,0,0);
                    c=(char *)LocalLock(buf)+n;
                    n=0;
                    while ((*c++==' ') && (n<sizeof(spc)-1)) {
                        spc[n]=' ';
                        n++;
                    }
                    spc[n]=0;
                    LocalUnlock(buf);
                    CallWindowProc(editWndProc,hwnd,EM_REPLACESEL,0,(long)(LPSTR)spc);
                    return 0;
                }
                else
                if ((wParam==0x0019) && (HIWORD(lParam)==0x002c)) {
                    /* delete line (^Y) */
                    long l,lin1,lin2;

                    lin1=SendMessage(hwnd,EM_LINEINDEX,(WORD)-1,0);
                    lin2=SendMessage(hwnd,EM_LINEFROMCHAR,LOWORD(lin1),0);
                    lin2=SendMessage(hwnd,EM_LINEINDEX,LOWORD(lin2)+1,0);
                    l=(lin2<<16)+lin1;
                    SendMessage(hwnd,EM_SETSEL,0,l);
                    SendMessage(hwnd,WM_CLEAR,0,0);
                    SendMessage(hwnd,EM_SCROLLCARET,0,0);
                    return 0;
                }
                else
                if ((wParam==VK_TAB) && (!options.useTabs)) {
                    int i;
                    for (i=1;i<=options.tabWidth;i++)
                        CallWindowProc(editWndProc,hwnd,WM_CHAR,VK_SPACE,0);
                    return 0;
                }
                else
                    CheckSize(hwnd);

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

                    if (options.useTabs) {
                        int i;
                        UnmarkSel(hwnd);
                        for (i=1;i<=options.tabWidth;i++)
                            CallWindowProc(editWndProc,hwnd,WM_CHAR,VK_SPACE,0);
                        MarkNext(hwnd);
                        return 0;
                    }
                    /* no break! */

                case VK_BACK:

                    UnmarkSel(hwnd);
                    /* no break! */

                case VK_DELETE:

                    return CallWindowProc(editWndProc,hwnd,msg,wParam,lParam);

                case VK_RETURN:

                    CallWindowProc(editWndProc,hwnd,WM_KEYDOWN,VK_HOME,0);
                    CallWindowProc(editWndProc,hwnd,WM_KEYDOWN,VK_DOWN,0);
                    MarkNext(hwnd);
                    return 0;

                default: {

                    bypass=TRUE;
                    if (marked) {
                        rep[0]=(char)wParam;
                        rep[1]=0;
                        CallWindowProc(editWndProc,hwnd,EM_REPLACESEL,0,(LONG)(LPSTR)rep);
                    }
                    else { 
                        CheckSize(hwnd);
                        CallWindowProc(editWndProc,hwnd,msg,wParam,lParam);
                    }
                    MarkNext(hwnd);
                    bypass=FALSE;
                    return 0;
                    }
                }
            }
        }
    }

    ret=CallWindowProc(editWndProc,hwnd,msg,wParam,lParam);

    if (bypass)
        return ret;

    switch(msg) {

    case WM_SETFOCUS:
    
        CursorPos(hwnd);
        break;      
              
    case WM_COMMAND:

        if (wParam==ID_EDIT && HIWORD(lParam)==EN_CHANGE) {
            SetWindowLong(hwnd,GWL_ED_CHANGED,TRUE);
            SendMessage(GetParent(hwnd),PEM_SHOWCHANGED,TRUE,0);
        }
        break;

    case WM_KEYDOWN:

        if (ctrlPend)
            break;

        if (wParam==VK_INSERT) {
            insMode=!insMode;
            SendMessage(GetParent(hwnd),PEM_SHOWINSERTMODE,insMode,0);
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

        if (*languageHelpFile && options.mouseTopic) {

            /* right mouse button pressed -> call compiler for topic help */
            long l;
            WORD siz;
            HLOCAL h;
            char key[100];
            PSTR buf,beg,end;
            LPSTR k;

            h=(HLOCAL)SendMessage(hwnd,EM_GETHANDLE,0,0);
            siz=LocalSize(h);
            buf=LocalLock(h);
            CallWindowProc(editWndProc,hwnd,WM_LBUTTONDOWN,MK_LBUTTON,lParam);
            CallWindowProc(editWndProc,hwnd,WM_LBUTTONUP,MK_LBUTTON,lParam);
            l=CallWindowProc(editWndProc,hwnd,EM_GETSEL,0,0);
            beg=buf+LOWORD(l);
            end=buf+LOWORD(l);
            while ((beg>buf) && CharOk(*beg)) beg--;
            while ((end<buf+siz-1) && CharOk(*end)) end++;
            if (!CharOk(*beg)) beg++;
            if (!CharOk(*end)) end--;
            if ((end>beg) && (end-beg+1>=sizeof(key)))
                end=beg+sizeof(key)-2;
            k=(LPSTR)key;
            while (beg<=end)
                *k++=*beg++;
            *k=0;
            LocalUnlock(h);
            WinHelp(hwnd,(LPSTR)languageHelpFile,HELP_PARTIALKEY,(DWORD)(LPSTR)key);
        }
        break;
    }
    return ret;
}

/***************************************************************************
 * window function for "poweditfield", a subclass of control class "edit"; *
 * all messages are passed through, only background erasure is kept.       *
 ***************************************************************************/

LONG FAR PASCAL _export PowReadOnlyWndProc (HWND hwnd,UINT msg,WPARAM wParam,LONG lParam )
{                                                   
    switch (msg) {

    case WM_CHAR:

        if ((wParam==VK_RETURN) || (wParam==VK_EXECUTE)) {
            /* send doubleclick to mdi window */
            SendMessage(GetParent(hwnd),PEM_DOUBLECLICK,0,0);
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
        SendMessage(GetParent(hwnd),PEM_DOUBLECLICK,0,0);
        return 0;
    }
    return CallWindowProc(readOnlyWndProc,hwnd,msg,wParam,lParam);
}

/**********************************
 * exported procedures for editor *
 **********************************/              
              
//return supported Pow! editor interface specification number (i.e. 1.23=123)
int FAR PASCAL _export InterfaceVersion (void)
{            
    /* this is for 1.4 */
    return 140;
}

//create a new edit-control (empty)
void FAR PASCAL _export NewEditWindow (HWND parent,BOOL readOnly)
{
    RECT r;
    HWND hEd;
    LOGFONT lf;
    HFONT hFont;
    
    GetClientRect(parent,&r);
    hEd=CreateWindow(readOnly ? (LPSTR)READONLYCLASS : (LPSTR)EDITCLASS,
          NULL,WS_CHILD|WS_MAXIMIZE|WS_VISIBLE|WS_VSCROLL|WS_HSCROLL|
          ES_AUTOHSCROLL|ES_AUTOVSCROLL|ES_MULTILINE,
          0,0,r.right,r.bottom,parent,(HMENU)ID_EDIT,hInstDLL,NULL);
    if (hEd) {
        lf.lfEscapement=MM_TEXT;
        lf.lfOrientation=0;
        lf.lfWeight=FW_DONTCARE;
        lf.lfItalic=FALSE;
        lf.lfUnderline=FALSE;
        lf.lfStrikeOut=FALSE;
        lf.lfCharSet=DEFAULT_CHARSET;
        lf.lfOutPrecision=OUT_DEFAULT_PRECIS;
        lf.lfClipPrecision=OUT_DEFAULT_PRECIS;
        lf.lfQuality=PROOF_QUALITY;
        lf.lfPitchAndFamily=DEFAULT_PITCH|FF_DONTCARE;
        lf.lfWidth=0;
        lf.lfHeight=options.fontSize;
        strcpy(lf.lfFaceName,options.fontName);

        if (hFont=CreateFontIndirect(&lf))
            SendMessage(hEd,WM_SETFONT,(WPARAM)hFont,0);
            
        SendMessage(hEd,EM_LIMITTEXT,(unsigned)60000,0);

        SetWindowLong(hEd,GWL_ED_FONT,(long)hFont);
        SetWindowLong(hEd,GWL_ED_CHANGED,0);
    }
}

//close a edit-window (don't care for ssaving!)
void FAR PASCAL _export CloseEditWindow (HWND edit)
{     
    HFONT hFont;
    HWND hEd=GetWindow(edit,GW_CHILD);
    
    hFont=(HFONT)GetWindowLong(hEd,GWL_ED_FONT);
    DestroyWindow(hEd);
    if (hFont)
        DeleteObject(hFont);
}

//text has been changed (return 1) or not (return 0)
int FAR PASCAL _export HasChanged (HWND edit)
{                        
    HWND hEd=GetWindow(edit,GW_CHILD);
    return (int)GetWindowLong(hEd,GWL_ED_CHANGED);
}

//load the edit-control with the given file
int FAR PASCAL _export LoadFile (HWND edit,LPSTR name)
{       
    HFILE f;
    HLOCAL h;
    HWND hEd;
    long len;
    LPSTR lp;
    char err[100];
    
    f=_lopen(name,OF_READ);
    if (f!=HFILE_ERROR) {
        /* calculate length */
        len=_llseek(f,0L,2);
        _llseek(f,0L,0);

        hEd=GetWindow(edit,GW_CHILD);
        h=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0L);
        if (len>62000L || 
            (LocalReAlloc(h,LOWORD(len)+1000,LHND)==0 &&
             LocalReAlloc(h,LOWORD(len)+100,LHND)==0 &&
             LocalReAlloc(h,LOWORD(len)+1,LHND)==0)) {
            strcpy(err,"Not enough memory for file '");
            strcat(err,name);
            strcat(err,"'!");
            MessageBox(0,err,"Error",MB_OK|MB_ICONINFORMATION);
        }
        else {
            lp=(LPSTR)LocalLock(h);                                                 
            len=(long)_lread(f,lp,LOWORD(len));
            lp[len]=0;
            _lclose(f);
            LocalUnlock(h);
            SendMessage(hEd,EM_SETHANDLE,(WPARAM)h,0L);
            CheckSize(hEd);
            SendMessage(edit,PEM_SHOWLINENR,1,1);
            return 1;
        }
        _lclose(f);
    }
    else {
        strcpy(err,"Cannot open file '");
        strcat(err,name);
        strcat(err,"'!");
        MessageBox(0,err,"Error",MB_OK|MB_ICONINFORMATION);
    }
    return 0;
}

//save the current text in the given file
int FAR PASCAL _export SaveFile (HWND edit,LPSTR name)
{
    HFILE f;
    HLOCAL h;
    HWND hEd;
    long len;
    LPSTR lp;
    int ret;
    char err[100];
    OFSTRUCT of;
              
    ret=0;
    OpenFile(name,(LPOFSTRUCT)&of,OF_DELETE);
    f=_lcreat(name,0);
    if (f!=HFILE_ERROR) {
        /* calculate length */
        len=_llseek(f,0L,2);
        _llseek(f,0L,0);

        hEd=GetWindow(edit,GW_CHILD);
        h=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0L);
        lp=(LPSTR)LocalLock(h);
        len=(long)_lwrite(f,lp,strlen(lp));
        if (len!=(long)strlen(lp)) {
            strcpy(err,"Cannot save file '");
            strcat(err,name);
            strcat(err,"'!");
            MessageBox(0,err,"Error",MB_OK|MB_ICONINFORMATION);
        }    
        ret=(len==(long)strlen(lp));
        LocalUnlock(h);
        _lclose(f);
        SetWindowLong(hEd,GWL_ED_CHANGED,FALSE);
        SendMessage(edit,PEM_SHOWCHANGED,FALSE,0);
    }
    else {
        strcpy(err,"Cannot write to file '");
        strcat(err,name);
        strcat(err,"'!");
        MessageBox(0,err,"Error",MB_OK|MB_ICONINFORMATION);
    }    
    return ret;
}

//return the cursor position (row/col)
void FAR PASCAL _export GetCursorpos (HWND edit,LPLONG row,LPLONG col)
{
    long sel;
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);
    sel=SendMessage(hEd,EM_GETSEL,0,0);
    *row=SendMessage(hEd,EM_LINEFROMCHAR,LOWORD(sel),0);
    *col=(long)((LOWORD(sel))-(int)SendMessage(hEd,EM_LINEINDEX,(int)*row,0)+1);
    *row=*row+1;
}

//copy selected text to the clipboard
//return: 1 (successful), 0 (no selection or not successful)
int FAR PASCAL _export Copy (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,WM_COPY,0,0L);
    return 1;
}    

//paste the clipboard content at the current cursor position
//return: 1 (successful), 0 (no clipboard info or not successful)
int FAR PASCAL _export Paste (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,WM_PASTE,0,0L);
    return 1;
}    

//cut selected text to the clipboard
//return: 1 (successful), 0 (no selection or not successful)
int FAR PASCAL _export Cut (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,WM_CUT,0,0L);
    return 1;
}    

//clear selected text
//return: 1 (successful), 0 (no selection or not successful)
int FAR PASCAL _export Clear (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_REPLACESEL,0,(long)(LPSTR)"");
    return 1;
}    

//undo the last command
void FAR PASCAL _export Undo (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_UNDO,0,0L);
}    

//redo the last undone command
void FAR PASCAL _export Redo (HWND edit)
{
    HWND hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_UNDO,0,0L);
}    

//set cursor to given position (row/col)
void FAR PASCAL _export GotoPos (HWND edit,long row,long col)
{
    long sel;
    HLOCAL hmem;
    HWND hEd=GetWindow(edit,GW_CHILD);

    if (row==-1 && col==-1) { 
        /* position caret after last character */
        hmem=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0);
        HIWORD(sel)=LOWORD(sel)=LocalSize(hmem);
    }
    else {
        sel=SendMessage(hEd,EM_LINEINDEX,(int)(row-1),0)+col-1;
        HIWORD(sel)=LOWORD(sel);
    }
    SendMessage(hEd,EM_SETSEL,0,sel);
    SendMessage(hEd,EM_SCROLLCARET,0,0);
}

//search text in an edit-control
//case sensitive search if matchcase==1
//search from cursor to end of file if down=1
//search for whole words only if words=1
//return: 1 (found), 0 (not found)
int FAR PASCAL _export Search (HWND edit,LPSTR text,int matchcase,int down,int words)
{             
    HWND hEd=GetWindow(edit,GW_CHILD);
    
    DoReplace=FALSE;
    FindTxt=text;
    FindCase=matchcase;
    FindDown=down;
    FindWord=words;
    FindWnd=hEd;
    
    return SearchText();
}

//replace text in an edit-control by new text
//case sensitive search if matchcase==1
//search from cursor to end of file if down==1
//change all occurences if all==1
//search for whole words only if words=1
//ask before change if ask==1
//return: number of changed occurences
int FAR PASCAL _export Replace (HWND edit,LPSTR text,LPSTR newtext,int matchcase,int down,int words,int all,int ask)
{
    int i;
    HWND hEd=GetWindow(edit,GW_CHILD);
    
    DoReplace=TRUE;
    FindTxt=text;
    ReplaceTxt=newtext;
    FindCase=matchcase;
    FindDown=down;
    FindWord=words;
    FindAsk=ask;
    FindWnd=hEd;
    
    i=0;                                                
    do {
        if (SearchText()) i++;
        else return i;
    } while (all);
    
    return i;
}           
                
//retrieve character height of logical font
int GetFontSize (HWND hwnd,int height,LPSTR font)
{                          
    HDC dc;
    long size;
    LOGFONT lf;
    TEXTMETRIC tm;
    long logPixelsY;
    HFONT oldFont,hFont;

    lf.lfEscapement=MM_TEXT;
    lf.lfOrientation=0;
    lf.lfWeight=FW_DONTCARE;
    lf.lfItalic=FALSE;
    lf.lfUnderline=FALSE;
    lf.lfStrikeOut=FALSE;
    lf.lfCharSet=DEFAULT_CHARSET;
    lf.lfOutPrecision=OUT_DEFAULT_PRECIS;
    lf.lfClipPrecision=OUT_DEFAULT_PRECIS;
    lf.lfQuality=PROOF_QUALITY;
    lf.lfPitchAndFamily=DEFAULT_PITCH|FF_DONTCARE;
    lf.lfWidth=0;
    lf.lfHeight=height;
    strcpy(lf.lfFaceName,font);
    
    if (hFont=CreateFontIndirect(&lf)) {
        dc=GetDC(hwnd);
        oldFont=SelectObject(dc,hFont);
        logPixelsY=(long)GetDeviceCaps(dc,LOGPIXELSY);
        GetTextMetrics(dc,&tm);
        size=5+(((long)tm.tmHeight-(long)tm.tmInternalLeading)*720/logPixelsY);
        if (size<0) size=-1*size;
        size/=10;
        SelectObject(dc,oldFont);
        ReleaseDC(hwnd,dc);
        DeleteObject(hFont);
    }
    else
        size=0;    
    return (int)size;
}

//hook function for the choosefont common dialog function
int FAR PASCAL _export ChooseFontHook (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    if (msg==WM_INITDIALOG) {
        char size[20];
        itoa(GetFontSize(hdlg,options.fontSize,options.fontName),size,10);
        SendDlgItemMessage(hdlg,ID_ED_FONTTYPE,CB_SELECTSTRING,(WORD)-1,(long)(LPSTR)(options.fontName));
        SendDlgItemMessage(hdlg,ID_ED_FONTSIZE,CB_SELECTSTRING,(WORD)-1,(long)(LPSTR)size);
        return 1;
    }
    return 0;
}

//options-dialog for all edit-windows, save this information in an INI-File
//information to change: font, tabs, right mouse button, ...
BOOL FAR PASCAL _export PowEditOptionsDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch(msg) {

    case WM_INITDIALOG: {
                                  
        int size;
        char buf[128];

        oldOptions=options;
        SendDlgItemMessage(hdlg,IDD_ED_INDENT,BM_SETCHECK,options.autoIndent,0);
        SendDlgItemMessage(hdlg,IDD_ED_TABS,BM_SETCHECK,options.useTabs,0);
        SendDlgItemMessage(hdlg,IDD_ED_MOUNOT,BM_SETCHECK,!options.mouseTopic,0);
        SendDlgItemMessage(hdlg,IDD_ED_MOUTOPIC,BM_SETCHECK,options.mouseTopic,0);
        
        size=GetFontSize(hdlg,options.fontSize,options.fontName);
        itoa(size,buf,10);
        strcat(buf,",");
        strcat(buf,options.fontName);
        SetWindowText(GetDlgItem(hdlg,IDD_ED_FONT),buf);

        itoa(options.tabWidth,buf,10);
        SetWindowText(GetDlgItem(hdlg,IDD_ED_TEDIT),(LPSTR)buf);
        break;
        }

    case WM_COMMAND:

        switch (wParam) {

            case IDOK: {
                char buf[128];

                options.autoIndent=(BOOL)SendDlgItemMessage(hdlg,IDD_ED_INDENT,BM_GETCHECK,0,0);
                options.useTabs=(BOOL)SendDlgItemMessage(hdlg,IDD_ED_TABS,BM_GETCHECK,0,0);
                options.mouseTopic=(BOOL)SendDlgItemMessage(hdlg,IDD_ED_MOUTOPIC,BM_GETCHECK,0,0);
                GetWindowText(GetDlgItem(hdlg,IDD_ED_TEDIT),(LPSTR)buf,80);
                options.tabWidth=atoi(buf);
                if (options.tabWidth<0 || options.tabWidth>10)
                    options.tabWidth=4;
                WriteIniFile();
                EndDialog(hdlg,wParam);
                break;
                }

            case IDCANCEL:
                                   
                /* restore old values */
                options=oldOptions;
                EndDialog(hdlg,wParam);
                break;

            case IDD_ED_MOUNOT:

                SendDlgItemMessage(hdlg,IDD_ED_MOUTOPIC,BM_SETCHECK,FALSE,0);
                break;

            case IDD_ED_MOUTOPIC:

                SendDlgItemMessage(hdlg,IDD_ED_MOUNOT,BM_SETCHECK,FALSE,0);
                break;

            case IDD_HELP:

                ShowHelp(hdlg);
                break;
                
            case IDD_ED_FONT: {
                int size;
                LOGFONT lf;
                FARPROC hook;
                CHOOSEFONT cf;
                char buf[100];

                memset(&cf,0,sizeof(CHOOSEFONT));
                cf.lStructSize=sizeof(CHOOSEFONT);
                cf.hwndOwner=hdlg;
                lf.lfHeight=options.fontSize;
                strcpy(lf.lfFaceName,options.fontName);
                cf.lpLogFont=&lf;
                cf.Flags=CF_SCREENFONTS|CF_ENABLETEMPLATE|CF_NOSTYLESEL|CF_ENABLEHOOK;
                cf.nFontType=SCREEN_FONTTYPE;
                cf.lpTemplateName=MAKEINTRESOURCE(ID_ED_FONT);
                cf.hInstance=hInstDLL;
                hook=MakeProcInstance((FARPROC)ChooseFontHook,hInstDLL);
                cf.lpfnHook=(UINT (CALLBACK *)(HWND,UINT,WPARAM,LPARAM))hook;
                ChooseFont(&cf);
                FreeProcInstance(hook);
                   
                if (*lf.lfFaceName) {
                    strcpy(options.fontName,lf.lfFaceName);
                    options.fontSize=lf.lfHeight;
                    size=GetFontSize(hdlg,options.fontSize,options.fontName);
                    itoa(size,buf,10);
                    strcat(buf,",");
                    strcat(buf,options.fontName);
                    SetWindowText(GetDlgItem(hdlg,IDD_ED_FONT),buf);
                }
                break;
                }
        }
        break;
    default:
        return FALSE;
    }
    return TRUE;
}

void FAR PASCAL _export EditOptions (void)
{    
    FARPROC proc;
    Options oldOptions;
    
    MessageBeep(0);
    proc=MakeProcInstance(PowEditOptionsDlgProc,hInstDLL);
    memcpy(&oldOptions,&options,sizeof(Options));
    if (DialogBox(hInstDLL,MAKEINTRESOURCE(ID_ED_OPTIONS),0,proc)==IDCANCEL)
        memcpy(&options,&oldOptions,sizeof(Options));
    FreeProcInstance(proc);
}

//support language-aware editors with list of keywords
//keywords separated by 0-chars, end of list are two 0-chars
void FAR PASCAL _export Keywords (int caseSensitive,LPSTR words)
{
    /* not supported here! */
}

//install a command procedure, which is called automatically with the
//actual selection,  whenever a special key is pressed (ALT-F1)
//callback-procedure is: void Command (LPSTR selection)
void FAR PASCAL _export SetCommandProcedure (FARPROC command)
{
    /* not supported here! */
}

//support language-aware editors with comment syntax
//on gives start of comments (i.e. "/*"), off its end (i.e. "*/")
//more than one syntax can given by seperating them with spaces,
//two spaces must be placed after the last entry
//single-line comments are supported by leaving the appropriate off-string empty
void FAR PASCAL _export Comments (LPSTR on,LPSTR off)
{
    /* not supported here! */
}

//support editor with the name of the compiler-help file
//(for searching a selected keyword after pressing the right mouse button)
void FAR PASCAL _export SetHelpFile (LPSTR name)
{
    strcpy(languageHelpFile,name);
}
    
//retrieve edit buffer in parts
//first call GetFirstBuffer, then GetNextBuffer
//maximal size bytes are copied to buf
//returns actual size
//EOF is reached, if returned value < size
long FAR PASCAL _export GetFirstBuffer (HWND edit,LPSTR buf,long size)
{                       
    HLOCAL h;
    HWND hEd;
    LPSTR text;
    long len;
 
    hEd=GetWindow(edit,GW_CHILD);

    h=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0);
    text=(LPSTR)LocalLock(h);
    len=strlen(text);
    
    if (len<size)
        size=len;
                        
    memcpy(buf,text,(unsigned)size);
    
    SetWindowLong(hEd,GWL_ED_NEXTOFFSET,size);
    LocalUnlock(h);

    return size;    
}

long FAR PASCAL _export GetNextBuffer (HWND edit,LPSTR buf,long size)
{
    HWND hEd;
    HLOCAL h;
    LPSTR text;
    char txt[100];
    long offset,len;
             
//    MessageBox(0,"get next","buffer",MB_OK);

    hEd=GetWindow(edit,GW_CHILD);
    offset=GetWindowLong(hEd,GWL_ED_NEXTOFFSET);
    h=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0);
    
    text=(LPSTR)LocalLock(h);
    len=strlen(text);
    
    if (len-offset<size)
        size=len-offset;

    ltoa(size,txt,10);
//    MessageBox(0,txt,"next",MB_OK);
    
    if (size)                    
        memcpy(buf,text+(unsigned)offset,(unsigned)size);
    
    SetWindowLong(hEd,GWL_ED_NEXTOFFSET,offset+size);
    LocalUnlock(h);

    return size;    
}

HGLOBAL FAR PASCAL _export GetText (HWND edit)
{
    HWND hEd;
    LPSTR lp;
    PSTR pbuf;
    long size;
    HLOCAL hmem;
    HGLOBAL h;
    
    hEd=GetWindow(edit,GW_CHILD);
    hmem=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0);
    size=LocalSize(hmem);
    h=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,size);
    if (h) {
        lp=GlobalLock(h);
        pbuf=LocalLock(hmem);
        lstrcpy(lp,(LPSTR)pbuf);
        LocalUnlock(hmem);
        GlobalUnlock(h);
    }
    return h;
}

//return 1, if editor generates pure ascii-files
//return 0, if editor has own file format
int FAR PASCAL _export GeneratesAscii (void)
{   
    return 1;
}

int FAR PASCAL _export LoadOpen (LPSTR file)
{
    /* not necessary here! */
    return 0;
}

long FAR PASCAL _export LoadRead (int handle,LPSTR buf,long size)
{
    /* not necessary here! */
    return 0;
}

void FAR PASCAL _export LoadClose (int handle)
{
    /* not necessary here! */
}

int FAR PASCAL _export CanUndo (void)
{
    return 1;
}

int FAR PASCAL _export HasSelection (HWND edit)
{
    long sel;
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);
    sel=SendMessage(hEd,EM_GETSEL,0,0);
    return (LOWORD(sel)!=HIWORD(sel));
}

int FAR PASCAL _export PrintWindow (HWND edit)
{
    HWND hEd;
    char title[128];
    
    hEd=GetWindow(edit,GW_CHILD);
    GetWindowText(edit,title,sizeof(title));
    PrintFile(hEd,title);
    return 1;
}            

int FAR PASCAL _export InsertText (HWND edit,LPSTR text)
{
    HWND hEd;
    long sel;
    unsigned pos;
    
    hEd=GetWindow(edit,GW_CHILD);
    sel=SendMessage(hEd,EM_GETSEL,0,0);
    pos=(LOWORD(sel)>HIWORD(sel)) ? LOWORD(sel) : HIWORD(sel);
    SendMessage(hEd,EM_SETSEL,0,MAKELPARAM(pos,pos));
    SendMessage(hEd,EM_REPLACESEL,0,(long)text);
    return 0;
}                            

int FAR PASCAL _export AddText (HWND edit,LPSTR text)
{
    GotoPos(edit,-1,-1);
    InsertText(edit,text);
    return 0;
}

void FAR PASCAL _export ResizeWindow (HWND edit,int dx,int dy)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);
    MoveWindow(hEd,0,0,dx,dy,TRUE);
}

void FAR PASCAL _export ResetContent (HWND edit)
{
    HWND hEd;
    LPSTR buf;
    HLOCAL hmem;
    
    hEd=GetWindow(edit,GW_CHILD);               

    SendMessage(hEd,EM_SETSEL,0,0);
    hmem=(HLOCAL)SendMessage(hEd,EM_GETHANDLE,0,0);
    hmem=LocalReAlloc(hmem,1,LHND);
    buf=(LPSTR)LocalLock(hmem);
    *buf=0;
    LocalUnlock(hmem);
    SendMessage(hEd,EM_SETHANDLE,(WPARAM)hmem,0);
}

int FAR PASCAL _export GetLine (HWND edit,int line,int max,LPSTR buf)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);               

    *((LPINT)buf)=max;
    return (int)SendMessage(hEd,EM_GETLINE,line,(long)buf);
}

void FAR PASCAL _export ShowHelp (HWND hwnd)
{
    int ret;
    LPSTR lp;
    char helpFile[128];
    
    GetModuleFileName(hInstDLL,helpFile,sizeof(helpFile));
    if (*helpFile) {
        lp=(LPSTR)helpFile+lstrlen(helpFile);
        while (*lp!='\\') lp--;
        lstrcpy(lp+1,HELPFILENAME);
        ret=WinHelp(hwnd,(LPSTR)helpFile,HELP_CONTENTS,0);
    }
}

/***********************************************************************
 *                                                                     *
 *              DLL Initialization and Finalization                    *
 *                                                                     *
 ***********************************************************************/

#ifdef _WIN32

int main (void)
{
    return 0;
}

BOOL WINAPI MyDllEntryPoint (HINSTANCE hI,DWORD reason,LPVOID reserved)
{
    if (reason==DLL_PROCESS_ATTACH) {
        WNDCLASS wc;
    
        hInstDLL=hI;

        /* user defined edit field */
        GetClassInfo(0,"richedit",(LPWNDCLASS)&wc);
        editWndProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,hInstDLL);
        extraOffset=wc.cbWndExtra;
        wc.cbWndExtra+=GWL_ED_EXTRA;
        wc.style|=CS_GLOBALCLASS;
        wc.hInstance=hInstDLL;
        wc.lpfnWndProc=PowEditWndProc;
        wc.lpszClassName=EDITCLASS;
        RegisterClass((LPWNDCLASS)&wc);

        /* user defined read-only edit field */
        GetClassInfo(0,"richedit",(LPWNDCLASS)&wc);
        readOnlyWndProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,hInstDLL);
        wc.cbWndExtra+=GWL_ED_EXTRA;
        wc.style|=CS_GLOBALCLASS;
        wc.hInstance=hInstDLL;
        wc.lpfnWndProc=PowReadOnlyWndProc;
        wc.lpszClassName=READONLYCLASS;
        RegisterClass((LPWNDCLASS)&wc);

        ReadIniFile();
    }

    if (reason==DLL_PROCESS_DETACH) {
        UnregisterClass(EDITCLASS,hInstDLL);
        UnregisterClass(READONLYCLASS,hInstDLL);
    }

    return TRUE;
}

#else

/* initialize dll */
int FAR PASCAL LibMain (HANDLE hI,WORD wDSeg,WORD wHSize,LPSTR lpCmd)
{
    WNDCLASS wc;
    
    hInstDLL=hI;
    if (wHSize)
        UnlockData(0);

    /* user defined edit field */
    GetClassInfo(0,"edit",(LPWNDCLASS)&wc);
    editWndProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,hInstDLL);
    extraOffset=wc.cbWndExtra;
    wc.cbWndExtra+=GWL_ED_EXTRA;
    wc.style|=CS_GLOBALCLASS;
    wc.hInstance=hInstDLL;
    wc.lpfnWndProc=PowEditWndProc;
    wc.lpszClassName=EDITCLASS;
    RegisterClass((LPWNDCLASS)&wc);

    /* user defined read-only edit field */
    GetClassInfo(0,"edit",(LPWNDCLASS)&wc);
    readOnlyWndProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,hInstDLL);
    wc.cbWndExtra+=GWL_ED_EXTRA;
    wc.style|=CS_GLOBALCLASS;
    wc.hInstance=hInstDLL;
    wc.lpfnWndProc=PowReadOnlyWndProc;
    wc.lpszClassName=READONLYCLASS;
    RegisterClass((LPWNDCLASS)&wc);

    ReadIniFile();
    return 1;
}

/* dll exit function */
int CALLBACK WEP (int exitType)
{
    UnregisterClass(EDITCLASS,hInstDLL);
    UnregisterClass(READONLYCLASS,hInstDLL);
    return 1;
}

#endif
