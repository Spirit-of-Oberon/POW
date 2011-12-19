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
 *            Part of project: 32-Bit editor based on rich edit controls   *
 *            Version   (23.11.95)   start                                 *
 *                                                                         *
 ***************************************************************************/


/* used libraries */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <commdlg.h>
#include <commctrl.h>
#include <richedit.h>

#include "powedprn.h"
#include "powedit.h"
         
/* global definitions */
#define EDITCLASS "powed32"                      
#define HELPFILENAME "powedit.hlp"

#define GWL_ED_CHANGED     (extraOffset+0)
#define GWL_ED_NEXTOFFSET  (extraOffset+4)
#define GWL_ED_INSERTMODE  (extraOffset+8)
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
HINSTANCE hInstDLL;
HANDLE hRTFLib;
FARPROC editWndProc;
Options options;
int extraOffset=0;
char languageHelpFile[128];
Options oldOptions;

/* forward declarations */
long FAR PASCAL PowEditWndProc (HWND,UINT,WPARAM,LPARAM);
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
    lstrcat(name,"powed32.ini");
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
    long selbeg,selend;

    SendMessage(hwnd,EM_GETSEL,(WPARAM)&selbeg,(LPARAM)&selend);
    row=(int)SendMessage(hwnd,EM_LINEFROMCHAR,(WPARAM)selbeg,0);
    col=selbeg-(int)SendMessage(hwnd,EM_LINEINDEX,row,0);
    SendMessage(GetParent(hwnd),PEM_SHOWLINENR,(WPARAM)(col+1),(LPARAM)(row+1));
}

/* return TRUE, if selection is made */
int Selection (HWND hwnd)
{
    long selbeg,selend;
    
    SendMessage(hwnd,EM_GETSEL,(WPARAM)&selbeg,(LPARAM)&selend);
    return selend-selbeg;
}

/* window procedure for custom edit control */
long FAR PASCAL _export PowEditWndProc (HWND hwnd,UINT msg,WPARAM wParam,LPARAM lParam )
{
    long ret;
 
    if (msg==WM_COMMAND && wParam==EN_CHANGE) {
        if (!GetWindowLong(hwnd,GWL_ED_CHANGED)) {
            SetWindowLong(hwnd,GWL_ED_CHANGED,TRUE);
            SendMessage(GetParent(hwnd),PEM_SHOWCHANGED,TRUE,0);
        }
    }

    if (msg==WM_KEYDOWN && wParam==VK_INSERT) {
        SetWindowLong(hwnd,GWL_ED_INSERTMODE,!GetWindowLong(hwnd,GWL_ED_INSERTMODE));
        SendMessage(GetParent(hwnd),PEM_SHOWINSERTMODE,GetWindowLong(hwnd,GWL_ED_INSERTMODE),0);
    }

    ret=CallWindowProc(editWndProc,hwnd,msg,wParam,lParam);

    if (msg==WM_LBUTTONDBLCLK && (GetWindowLong(hwnd,GWL_STYLE)&ES_READONLY))
        SendMessage(GetParent(hwnd),PEM_DOUBLECLICK,0,0);
    
    if (msg==WM_KEYDOWN || msg==WM_LBUTTONDOWN || msg==WM_SETFOCUS || msg==WM_ACTIVATE) {
        CursorPos(hwnd);
        if (msg==WM_SETFOCUS || msg==WM_ACTIVATE) {
            SendMessage(GetParent(hwnd),PEM_SHOWINSERTMODE,GetWindowLong(hwnd,GWL_ED_INSERTMODE),0);
        }
    }


    return ret;
}


/**********************************
 * exported procedures for editor *
 **********************************/              
              
//return supported Pow! editor interface specification number (i.e. 1.23=123)
int FAR PASCAL _export InterfaceVersion (void)
{            
    /* this is for 1.5 */
    return 150;
}

//create a new edit-control (empty)
void FAR PASCAL _export NewEditWindow (HWND parent,BOOL readOnly)
{
    RECT r;
    HWND hEd;
    LOGFONT lf;
    HFONT hFont;
    
    GetClientRect(parent,&r);
    hEd=CreateWindow(EDITCLASS,NULL,
          WS_CHILD|WS_MAXIMIZE|WS_VISIBLE|WS_VSCROLL|WS_HSCROLL|ES_SAVESEL|
          ES_AUTOHSCROLL|ES_AUTOVSCROLL|ES_MULTILINE|(readOnly?ES_READONLY:0),
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
            
        SendMessage(hEd,EM_LIMITTEXT,(WPARAM)1000000L,0);
        SendMessage(hEd,EM_SETEVENTMASK,0,ENM_CHANGE|ENM_KEYEVENTS|ENM_MOUSEEVENTS);

        SetWindowLong(hEd,GWL_ED_INSERTMODE,TRUE);
        SetWindowLong(hEd,GWL_ED_CHANGED,0);

        CursorPos(hEd);
        SendMessage(hEd,PEM_SHOWINSERTMODE,TRUE,0);
    }
}

//close a edit-window (don't care for ssaving!)
void FAR PASCAL _export CloseEditWindow (HWND edit)
{     
    HFONT hFont;
    HWND hEd=GetWindow(edit,GW_CHILD);
    
    hFont=(HFONT)SendMessage(hEd,WM_GETFONT,0,0);
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

// callback function for loading a file
DWORD FAR PASCAL _export StreamInProc (DWORD cookie,LPBYTE buf,LONG cb,LONG FAR *pcb)
{
    ReadFile((HANDLE)cookie,buf,cb,pcb,NULL);
    return 0;//(*pcb<cb) ? 0 : *pcb;
}

// callback function for saving a file
DWORD FAR PASCAL _export StreamOutProc (DWORD cookie,LPBYTE buf,LONG cb,LONG FAR *pcb)
{
    WriteFile((HANDLE)cookie,buf,cb,pcb,NULL);
    return *pcb!=cb;
}

//load the edit-control with the given file
int FAR PASCAL _export LoadFile (HWND edit,LPSTR name)
{       
    HANDLE f;
    HWND hEd;
    int num;
    char err[200];
    EDITSTREAM stream;
    
    f=CreateFile(name,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL|FILE_FLAG_SEQUENTIAL_SCAN,0);

    if (f!=INVALID_HANDLE_VALUE) {
        hEd=GetWindow(edit,GW_CHILD);
        
        stream.dwCookie=(DWORD)f;
        stream.dwError=0;
        stream.pfnCallback=StreamInProc;
        num=SendMessage(hEd,EM_STREAMIN,(WPARAM)SF_TEXT,(LPARAM)&stream);

        CloseHandle(f);

        SetWindowLong(hEd,GWL_ED_CHANGED,FALSE);
        SendMessage(edit,PEM_SHOWCHANGED,FALSE,0);
        
        return 1;
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
    HANDLE f;
    HWND hEd;
    int ret;
    char err[200];
    EDITSTREAM stream;
    
    ret=0;
    DeleteFile(name);
    f=CreateFile(name,GENERIC_WRITE,0,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL|FILE_FLAG_SEQUENTIAL_SCAN,0);

    if (f!=INVALID_HANDLE_VALUE) {
        hEd=GetWindow(edit,GW_CHILD);
        
        stream.dwCookie=(DWORD)f;
        stream.dwError=0;
        stream.pfnCallback=StreamOutProc;
        SendMessage(hEd,EM_STREAMOUT,(WPARAM)SF_TEXT,(LPARAM)&stream);

        if (stream.dwError) {
            strcpy(err,"Cannot save file '");
            strcat(err,name);
            strcat(err,"'!");
            MessageBox(0,err,"Error",MB_OK|MB_ICONINFORMATION);
        }    
        else ret=1;

        CloseHandle(f);

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
    HWND hEd;
    long selbeg,selend;
    
    hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_GETSEL,(WPARAM)&selbeg,(LPARAM)&selend);
    *row=SendMessage(hEd,EM_LINEFROMCHAR,(WPARAM)selbeg,0);
    *col=(long)((LOWORD(selbeg))-(int)SendMessage(hEd,EM_LINEINDEX,(WPARAM)*row,0)+1);
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
    SendMessage(hEd,WM_SETTEXT,0,(long)(LPSTR)"");
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
    long pos,len;
    CHARRANGE range;
    HWND hEd=GetWindow(edit,GW_CHILD);

    if (row==-1) {
        range.cpMin=-1;
        range.cpMax=-1;
        SendMessage(hEd,EM_EXSETSEL,0,(LPARAM)(CHARRANGE FAR *)&range);
        SendMessage(hEd,EM_SCROLLCARET,0,0);
    }
    else {
        pos=SendMessage(hEd,EM_LINEINDEX,(WPARAM)(row-1),0);
        if (pos!=-1) {
            len=SendMessage(hEd,EM_LINELENGTH,(WPARAM)pos,0);
            if (col>len) col=len;
            pos+=(col-1);
            SendMessage(hEd,EM_SETSEL,(WPARAM)pos,(LPARAM)pos);
            SendMessage(hEd,EM_SCROLLCARET,0,0);
        }
    }
}

//search text in an edit-control
//case sensitive search if matchcase==1
//search from cursor to end of file if down=1
//search for whole words only if words=1
//return: 1 (found), 0 (not found)
int FAR PASCAL _export Search (HWND edit,LPSTR text,int matchcase,int down,int words)
{   
    int pos;          
    long selbeg,selend;
    unsigned flags;
    FINDTEXT ftext;
    HWND hEd=GetWindow(edit,GW_CHILD);

    flags=0;
    if (matchcase) flags+=FR_MATCHCASE;
    if (words) flags+=FR_WHOLEWORD;

    SendMessage(hEd,EM_GETSEL,(WPARAM)&selbeg,(LPARAM)&selend);
    ftext.chrg.cpMin=selbeg+1;
    ftext.chrg.cpMax=-1;
    ftext.lpstrText=text;

    if ((pos=SendMessage(hEd,EM_FINDTEXT,(WPARAM)flags,(LPARAM)&ftext))==-1)
        return 0;
    else {
        SendMessage(hEd,EM_SETSEL,(WPARAM)pos,(LPARAM)(pos+strlen(text)));
        SendMessage(hEd,EM_SCROLLCARET,(WPARAM)0,(LPARAM)0);
        return 1;
    }
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
    
    i=0;                                                
    do {
        if (Search(edit,text,matchcase,down,words)) {
            i++;
            if (!ask || MessageBox(0,"Replace Occurrence","Question",MB_OK|MB_ICONQUESTION)==IDOK)
                SendMessage(hEd,EM_REPLACESEL,(WPARAM)TRUE,(LPARAM)newtext);
        }
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
int FAR PASCAL _export ChooseFontHook (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
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
BOOL FAR PASCAL _export PowEditOptionsDlgProc (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
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

        switch (LOWORD(wParam)) {

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
    HWND hEd;
    TEXTRANGE range;
 
    hEd=GetWindow(edit,GW_CHILD);
    range.chrg.cpMin=0;
    range.chrg.cpMax=size;
    range.lpstrText=buf;
    size=SendMessage(hEd,EM_GETTEXTRANGE,0,(LPARAM)&range);
    
    SetWindowLong(hEd,GWL_ED_NEXTOFFSET,size);
    return size;    
}

long FAR PASCAL _export GetNextBuffer (HWND edit,LPSTR buf,long size)
{
    HWND hEd;
    long offset;
    TEXTRANGE range;
 
    hEd=GetWindow(edit,GW_CHILD);
    offset=GetWindowLong(hEd,GWL_ED_NEXTOFFSET);
    range.chrg.cpMin=offset;
    range.chrg.cpMax=offset+size;
    range.lpstrText=buf;
    size=SendMessage(hEd,EM_GETTEXTRANGE,0,(LPARAM)&range);
    
    SetWindowLong(hEd,GWL_ED_NEXTOFFSET,offset+size);
    return size;    
}

HGLOBAL FAR PASCAL _export GetText (HWND edit)
{
    /* not supported here! */
    return 0;
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
    HWND hEd;
    long selbeg,selend;
    
    hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_GETSEL,(WPARAM)&selbeg,(LPARAM)&selend);
    return (selbeg!=selend);
}

int FAR PASCAL _export PrintWindow (HWND edit)
{
    // !!! source from MSDN Library !!!
    HWND hEd;
    FORMATRANGE fr;
    DOCINFO docInfo;
    LONG lTextOut, lTextAmt;
    PRINTDLG pd;
    char title[100];

    hEd=GetWindow(edit,GW_CHILD);
    GetWindowText(edit,title,sizeof(title));

    // Initialize the PRINTDLG structure.
    pd.lStructSize = sizeof(PRINTDLG);
    pd.hwndOwner = hEd;
    pd.hDevMode = (HANDLE)NULL;
    pd.hDevNames = (HANDLE)NULL;
    pd.nFromPage = 0;
    pd.nToPage = 0;
    pd.nMinPage = 0;
    pd.nMaxPage = 0;
    pd.nCopies = 0;
    pd.hInstance = (HANDLE)hInstDLL;
    pd.Flags = PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP;
    pd.lpfnSetupHook = (LPSETUPHOOKPROC)(FARPROC)NULL;
    pd.lpSetupTemplateName = (LPTSTR)NULL;
    pd.lpfnPrintHook = (LPPRINTHOOKPROC)(FARPROC)NULL;
    pd.lpPrintTemplateName = (LPTSTR)NULL;

    // Get the printer DC.
    if (PrintDlg(&pd) == TRUE)
    {
        // Fill in the FORMATRANGE structure for the RTF output.
        fr.hdc = fr.hdcTarget = pd.hDC; // HDC
        fr.chrg.cpMin = 0;              // print the
        fr.chrg.cpMax = -1;             //  entire contents
        fr.rc.top = fr.rcPage.top = fr.rc.left = fr.rcPage.left = 0;
        fr.rc.right = fr.rcPage.right = GetDeviceCaps(pd.hDC, HORZRES);
        fr.rc.bottom = fr.rcPage.bottom = GetDeviceCaps(pd.hDC, VERTRES );

        // Fill in the DOCINFO structure.
        docInfo.cbSize = sizeof(DOCINFO);
        docInfo.lpszDocName = title;
        docInfo.lpszOutput = NULL;

        // Make sure that printer DC is in text mode.
        SetMapMode(pd.hDC, MM_TEXT);

        StartDoc( pd.hDC, &docInfo);
        StartPage( pd.hDC );

        lTextOut = 0;
        lTextAmt = SendMessage( hEd, WM_GETTEXTLENGTH, 0, 0);

        while (lTextOut < lTextAmt)
        {
            lTextOut = SendMessage(hEd, EM_FORMATRANGE, TRUE, (LPARAM) &fr);
        
            if (lTextOut < lTextAmt)
            {
                EndPage( pd.hDC );
                StartPage( pd.hDC );    
                fr.chrg.cpMin = lTextOut;
                fr.chrg.cpMax = -1;
            }
        }
        // Reset the formatting of the RTF control.
        SendMessage(hEd, EM_FORMATRANGE, TRUE, (LPARAM)NULL);

        // Finish off the document
        EndPage( pd.hDC );
        EndDoc( pd.hDC );

        // Delete the printer DC.
        DeleteDC( pd.hDC );
    }
    return 1;
}            

int FAR PASCAL _export InsertText (HWND edit,LPSTR text)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);
    SendMessage(hEd,EM_REPLACESEL,0,(long)text);
    return 0;
}                            

int FAR PASCAL _export AddText (HWND edit,LPSTR text)
{
    GotoPos(edit,-1,-1);
    InsertText(edit,text);
    return 0;
}

void FAR PASCAL _export ResizeWindow (HWND edit,short dx,short dy)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);
    MoveWindow(hEd,0,0,dx,dy,TRUE);
}

void FAR PASCAL _export ResetContent (HWND edit)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);               
    SendMessage(hEd,WM_SETTEXT,0,(LPARAM)(LPSTR)"");
}

int FAR PASCAL _export GetLine (HWND edit,short line,short max,LPSTR buf)
{
    HWND hEd;
    
    hEd=GetWindow(edit,GW_CHILD);               

    *((LPINT)buf)=(int)max;
    return (int)SendMessage(hEd,EM_GETLINE,(WPARAM)line,(long)buf);
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

int main (void)
{
    return 0;
}

BOOL WINAPI MyDllEntryPoint (HINSTANCE hI,DWORD reason,LPVOID reserved)
{
    if (reason==DLL_PROCESS_ATTACH) {
        WNDCLASS wc;
        BOOL ret;
        DWORD err;

        hInstDLL=hI;

        InitCommonControls();
        hRTFLib=LoadLibrary("RICHED32.DLL");
        
        /* user defined edit field */
        ret=GetClassInfo(0,"RICHEDIT",(LPWNDCLASS)&wc);
        err=GetLastError();

        editWndProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,hInstDLL);
        //editWndProc=wc.lpfnWndProc;
        extraOffset=wc.cbWndExtra;
        wc.cbWndExtra+=GWL_ED_EXTRA;
        wc.style|=CS_GLOBALCLASS;
        wc.hInstance=hInstDLL;
        wc.lpfnWndProc=PowEditWndProc;
        wc.lpszClassName=EDITCLASS;
        RegisterClass((LPWNDCLASS)&wc);

        ReadIniFile();
    }

    if (reason==DLL_PROCESS_DETACH) {
        if (hRTFLib)
            FreeLibrary(hRTFLib);
        UnregisterClass(EDITCLASS,hInstDLL);
    }

    return TRUE;
}
