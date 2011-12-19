/***************************************************************************
 *                                                                         *
 *  MODULE    : PowMisc.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains miscellaneous procedures for Pow!                 *
 *                                                                         *
 ***************************************************************************/

#include <io.h>
#include <direct.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>

#include "powsupp.h"

#undef HIWORD
#undef LOWORD
#undef ID

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])
#define ID(id) MAKEINTRESOURCE(id)


/* global variables */
int instances=0;            /* number of dll-invocations */
int inF;                    /* handle input file */
int outF;                   /* handle output file */
char inName[MAXPATHLENGTH]; /* name of input file */
char outName[MAXPATHLENGTH];/* name of output file */
char msgTxt[160];           /* text of message box */
BOOL readErr;               /* read error flag */
BOOL writeErr;              /* write error flag */
HFONT dialogFont;           /* font for custom controls */
HANDLE hInstDLL;            /* instance handle of this DLL */
FARPROC pushProc;           /* push button-control window procedure */

long FAR PASCAL PowButtonWndProc (HWND,UINT,WPARAM,LPARAM);

/********************
 * helper functions *
 ********************/

/* case insensitive string compare */
int StrEqual (LPSTR s1,LPSTR s2)
{
   while (*s1 && *s2 && (tolower(*s1)==tolower(*s2))) {
      s1++;
      s2++;
   }
   return *s1==0 && *s2==0;
}

/* string partitioning in tokens without destroying source string */
LPSTR NextToken (LPSTR token,LPSTR source,char delimiter)
{
   while (*source && *source!=delimiter) 
      *token++=*source++;
   *token=0;
   if (*source)
      source++;   /* skip delimiter */
   return source;
}

/****************************
 * initialize supporter dll *
 ****************************/

void FAR PASCAL _export InitSupporterDLL (void)                                                     
{
    WNDCLASS wc;                             
               
    /* count number of invocations */
    instances++;           
    if (instances>1)
        return;

    /* subclass for standard push-buttons */
    GetClassInfo(0,"button",(LPWNDCLASS)&wc);
    pushProc=MakeProcInstance((FARPROC)wc.lpfnWndProc,0);
    wc.style|=CS_GLOBALCLASS;
    wc.hInstance=hInstDLL;
    wc.lpfnWndProc=PowButtonWndProc;
    wc.lpszClassName="powbutton";
    RegisterClass((LPWNDCLASS)&wc);
}

/*************************************************
 * main program is about to unload supporter dll *
 *************************************************/

void FAR PASCAL _export ExitSupporterDLL ()
{                                                             
    /* is this the last invocation? */
    if (--instances) 
        return;
               
    /* unregister custom controls */
    UnregisterClass("powbutton",hInstDLL);
}

/**************************************
 * copy contents of list to combo box *
 * (and select last entry)            *
 **************************************/

void FAR PASCAL _export ListToCombo (HANDLE list,HWND hwnd,BOOL select)
{
    long l;
    int i,n;
    char buf[80];

    n=CountList(list);
    for (i=1;i<=n;i++) {
        GetStr(list,i,(LPSTR)buf);
        SendMessage(hwnd,CB_ADDSTRING,0,(long)(LPSTR)buf);
        if ((i==n) && select) {
            LOWORD(l)=0;
            HIWORD(l)=lstrlen((LPSTR)buf);
            SetWindowText(hwnd,(LPSTR)buf);
            SendMessage(hwnd,CB_SETEDITSEL,0,l);
        }
    }
}

/*************************************
 * copy contents of list to list box *
 *************************************/

void FAR PASCAL _export ListToLBox (HANDLE list,HWND hwnd)
{
    int i;
    char buf[80];

    for (i=1;i<=CountList(list);i++) {
        GetStr(list,i,(LPSTR)buf);
        SendMessage(hwnd,LB_ADDSTRING,0,(long)(LPSTR)buf);
    }
}

/*************************************
 * copy contents of list box to list *
 *************************************/

void FAR PASCAL _export LBoxToList (HWND hwnd,LPHANDLE list)
{
    int i;
    char buf[80];

    PurgeList(list);
    for (i=0;i<(int)SendMessage(hwnd,LB_GETCOUNT,0,0);i++) {
        SendMessage(hwnd,LB_GETTEXT,i,(long)(LPSTR)buf);
        AddStr(list,(LPSTR)buf);
    }
}

/********************
 * open output file *
 ********************/

BOOL FAR PASCAL _export OpenOut (LPSTR st)
{
    if ((outF=_lcreat(st,0))!=-1) {
        writeErr=FALSE;
        lstrcpy((LPSTR)outName,st);
        return TRUE;
    }
    return FALSE;
}

/*******************
 * open input file *
 *******************/

BOOL FAR PASCAL _export OpenIn (LPSTR st)
{
    if ((inF=_lopen(st,OF_READ))!=-1) {
        readErr=FALSE;
        lstrcpy((LPSTR)inName,st);
        return TRUE;
    }
    return FALSE;
}

/*********************
 * close output file *
 *********************/

BOOL FAR PASCAL _export CloseOut ()
{
    _lclose(outF);
    if (writeErr) {
        writeErr=FALSE;
        return FALSE;
    }
    return TRUE;
}

/********************
 * close input file *
 ********************/

BOOL FAR PASCAL _export CloseIn ()
{
    _lclose(inF);
    if (readErr) {
        readErr=FALSE;
        return FALSE;
    }
    return TRUE;
}

/***************
 * write error *
 ***************/

void WriteError ()
{
    char st[100];

    lstrcpy((LPSTR)st,"Can´t write file ");
    lstrcat((LPSTR)st,outName);
    lstrcat((LPSTR)st,"!");

    writeErr=TRUE;
    MessageBox(GetDesktopWindow(),(LPSTR)st,"Message",MB_OK|MB_ICONEXCLAMATION);
}

/**************
 * read error *
 **************/

void ReadError ()
{
    char st[100];

    lstrcpy((LPSTR)st,"Can´t read file ");
    lstrcat((LPSTR)st,inName);
    lstrcat((LPSTR)st,"!");

    readErr=TRUE;
    MessageBox(GetDesktopWindow(),(LPSTR)st,"Message",MB_OK|MB_ICONEXCLAMATION);
}

/**********************
 * put string to file *
 **********************/

void FAR PASCAL _export PutStr (LPSTR st)
{
    if (!writeErr) {
        int len=lstrlen(st);
        if (_lwrite(outF,st,len)!=(WORD)len)
            WriteError();
    }
}

/*********************************
 * write number of bytes to file *
 *********************************/

void FAR PASCAL _export WriteBytes (LPSTR st,int len)
{
    if (!writeErr) 
        if (_lwrite(outF,st,len)!=(WORD)len)
            WriteError();
}

/**********************************
 * read number of bytes from file *
 **********************************/

void FAR PASCAL _export ReadBytes (LPSTR st,int len)
{
    if (!readErr) 
        if (_lread(inF,st,len)!=(WORD)len)
            ReadError();
}

/********************************************
 * write string to file with leading length *
 ********************************************/

void FAR PASCAL _export WriteStr (LPSTR st)
{
    if (!writeErr) {
        short len=(short)(lstrlen(st)+1);
        if ((_lwrite(outF,(LPSTR)&len,sizeof(len))!=sizeof(len)) ||
            (_lwrite(outF,st,len)!=(WORD)len))
            WriteError();
    }
}

/*************************
 * read string from file *
 *************************/

void FAR PASCAL _export ReadStr (LPSTR st)
{
    if (!readErr) {
        int don;
        short len;
        don=_lread(inF,(LPSTR)&len,sizeof(len));
        if ((don!=sizeof(len)) ||
            (_lread(inF,st,len)!=(WORD)len))
            ReadError();
    }
}

/**********************************************
 * write some date to file (and act on error) *
 **********************************************/

void FAR PASCAL _export FileOut (LPSTR st,int len)
{
    if (!writeErr) {
        if (_lwrite(outF,st,len)!=(WORD)len)
            WriteError();
    }
}

/***********************************************
 * read some date from file (and act on error) *
 ***********************************************/

int FAR PASCAL _export FileIn (void far *st,int len)
{
    if (!readErr) {
        if (_lread(inF,st,len)!=(WORD)len) {
            ReadError();
            return FALSE;
        }
    }
    return TRUE;
}

/****************************
 * write whole list to file *
 ****************************/

BOOL FAR PASCAL _export PutListElem (LPLIST l)
{
    LPSTR lp;
    short len;

    if (l->elem!=0) {
        lp=(LPSTR)GlobalLock(l->elem);
        len=l->len;
        FileOut((LPSTR)&len,sizeof(len));
        FileOut(lp,l->len);
        GlobalUnlock(l->elem);
    }
    return TRUE;
}

void FAR PASCAL _export WriteList (HANDLE h)
{
    FARPROC put;
    short i=(short)CountList(h);

    FileOut((LPSTR)&i,sizeof(i));
    put=MakeProcInstance(PutListElem,hInstDLL);
    ListForEach(h,put);
    FreeProcInstance(put);
}

/********************************
 * get list from disk to memory *
 ********************************/

void FAR PASCAL _export ReadList (LPHANDLE h)
{
    int i;
    short len;
    short elems;
    char buf[500];

    /* get number of elements */
    FileIn((LPSTR)&elems,sizeof(elems));
    for (i=0; i<elems && (!readErr); i++) {
        FileIn(&len,sizeof(len));
        FileIn(buf,len);
        buf[len]=0;
        AddElem(h,(long)(LPSTR)&buf,len);
    }
}

/****************************
 * get lower case of letter *
 ****************************/

char FAR PASCAL _export DownCase (char c)
{
    if (c>='A' && c<='Z')
        return c-(char)'A'+(char)'a';
    else
        return c;
}

/****************************
 * get lower case of string *
 ****************************/

LPSTR FAR PASCAL _export DownStr (LPSTR lp)
{
    LPSTR i=lp;
    while (*i)
        *i++=DownCase(*i);
    return lp;
}

/*******************************************
 * check string for wildcards ('*' or '?') *
 *******************************************/

BOOL FAR PASCAL _export Wildcard (LPSTR id)
{
    register char c;

    while (c=*id)
        if (*id++=='*' || c=='?')
            return TRUE;
    return FALSE;
}

/********************************************
 * convert integer to string (far!, SS!=DS) *
 ********************************************/

void FAR PASCAL _export MakeStr (long n,LPSTR st)
{
    int i=0,pos=0;
    long old;

    if (n==0)
        *st='0';
    else {
        old=n;
        while (old>=10) {
            pos++;
            old/=10;
        }
        i=pos;
        while (n>0) {
            *(st+pos)=(char)(48+(n%10));
            n/=10;
            pos--;
        }
    }
    *(st+i+1)=0;
}

/********************************************
 * convert string to integer (far!, SS!=DS) *
 ********************************************/

long FAR PASCAL _export MakeLon (LPSTR st)
{
    long l=0;
    while (*st)
        l=10*l+((int)(*st++))-48;
    return l;
}

/**************************************************************************
 * window function for "powbutton", a subclass of control class "button"; *
 * all messages are passed through, only background erasure is kept.      *
 **************************************************************************/

LONG FAR PASCAL _export PowButtonWndProc (HWND hwnd,UINT msg,WPARAM wParam,LPARAM lParam)
{
    if (msg==WM_ERASEBKGND) {
        RECT r;
        GetClientRect(hwnd,(LPRECT)&r);
        FillRect((HDC)wParam,(LPRECT)&r,GetStockObject(LTGRAY_BRUSH));
        return 0;
    }
    else              
        return CallWindowProc(pushProc,hwnd,msg,wParam,lParam);
}

/*********************************************
 * Functions for independent directory names * 
 *********************************************/

/* This function returns true, if the str starts with the string start. 
   The compare is case-insensitive */
int strStartsWith(LPSTR str, LPSTR start) {

  if (str && start) {

    while (*str && *start && (tolower(*str) == tolower(*start))) {
      str++;
      start++;
    }

    return (*start == 0);

  }

  return 0;

}

                 
void FAR PASCAL _export ShrinkDir (LPSTR dir,LPSTR powDir,LPSTR prjNam)
{
    LPSTR lp,occ;
    char code,prj[MAXPATHLENGTH],buf[MAXPATHLENGTH],shrinked[MAXPATHLENGTH];
                       
    if (!(dir && *dir)) return;
        
    if (prjNam && *prjNam) {                   
        _fstrcpy((LPSTR)prj,prjNam);
        lp=(LPSTR)prj+_fstrlen(prj)-1;
        while (*lp && *lp!='\\') lp--;
        if (*lp) *(lp+1)=0;
    }
    else *prj=0;    

    //if (*prj && _fstrstr(dir,(LPSTR)prj)) {   // changed by PDI
    if (*prj && strStartsWith(dir,(LPSTR)prj)) {
        code=PROJECT_DIR;
        occ=dir+_fstrlen((LPSTR)prj);
    }
//    else if (_fstrstr(dir,powDir)) {          // changed by PDI
    else if (strStartsWith(dir,powDir)) {
        code=POW_DIR;
        occ=dir+_fstrlen(powDir);
    }
    else if (prjNam && *prjNam && dir && *dir) {
        LPSTR nextsrc,nextdst;
        char srcdrv[MAXPATHLENGTH],srcpath[MAXPATHLENGTH],srcfil[MAXPATHLENGTH],srcext[MAXPATHLENGTH],srctoken[MAXPATHLENGTH],
             dstdrv[MAXPATHLENGTH],dstpath[MAXPATHLENGTH],dstfil[MAXPATHLENGTH],dstext[MAXPATHLENGTH],dsttoken[MAXPATHLENGTH];

        _splitpath(prjNam,srcdrv,srcpath,srcfil,srcext);
        _splitpath(dir,dstdrv,dstpath,dstfil,dstext);
        if (StrEqual(srcdrv,dstdrv)) {
           code=RELATIVE_DIR;
           *shrinked=0;

           /* skip equal parts of path */
           /* +1 = skip leading backslashes */
           nextsrc=NextToken(srctoken,srcpath+1,'\\');
           nextdst=NextToken(dsttoken,dstpath+1,'\\');
           while (*srctoken && *dsttoken && StrEqual(srctoken,dsttoken)) {
              nextsrc=NextToken(srctoken,nextsrc,'\\');
              nextdst=NextToken(dsttoken,nextdst,'\\');
           }
           
           /* go back from project directory */
           while (*srctoken) {
              strcat(shrinked,"@");
              nextsrc=NextToken(srctoken,nextsrc,'\\');
           }

           /* step into the destination directory */
           while (*dsttoken) {
              strcat(shrinked,dsttoken);
              strcat(shrinked,"\\");
              nextdst=NextToken(dsttoken,nextdst,'\\');
           }

           /* add file name and extension */
           strcat(shrinked,dstfil);
           strcat(shrinked,dstext);

           occ=shrinked;
        }
        else {
           code=OTHER_DIR;
           occ=dir;
        }
    }
    else {
        code=OTHER_DIR;
        occ=dir;
    }

    *(LPSTR)buf=code;
    _fstrcpy((LPSTR)(buf+1),occ);
    _fstrcpy(dir,(LPSTR)buf);
}                                             

void FAR PASCAL _export StretchDir (LPSTR dir,LPSTR powDir,LPSTR prjNam)
{
    LPSTR lp;
    char buf[MAXPATHLENGTH],prj[MAXPATHLENGTH];
               
    if (!*dir)
        return;           
                            
    if (prjNam && *prjNam) {                        
        _fstrcpy((LPSTR)prj,prjNam);
        lp=(LPSTR)prj+_fstrlen(prj)-1;
        while (*lp && *lp!='\\') lp--;
        if (*lp) *(lp+1)=0;
    }
    else
        *prj=0;    

    if (*dir==PROJECT_DIR)
        _fstrcpy((LPSTR)buf,(LPSTR)prj);

    else if (*dir==POW_DIR)
        _fstrcpy((LPSTR)buf,powDir);

    else if (*dir==RELATIVE_DIR) {
        LPSTR prev,lpdir;
        char drv[MAXPATHLENGTH],path[MAXPATHLENGTH],fil[MAXPATHLENGTH],ext[MAXPATHLENGTH];

        _splitpath(prjNam,drv,path,fil,ext);
        strcpy(buf,drv);
                        
        lpdir=dir+1;                
        prev=path+strlen(path)-1;
        while (*lpdir=='@' && prev!=path) {
           do
              prev--;
           while (prev!=path && *prev!='\\');
           lpdir++;
        }
        *prev=0;

        strcat(buf,path);
        strcat(buf,"\\");
        strcat(buf,lpdir);
        *(dir+1)=0;
    }
    else if (*dir==OTHER_DIR)
        *buf=0;

    else {
        // non-converted string must be copied as is!
        *buf=*dir;
        *(buf+1)=0;
    }    
    _fstrcat((LPSTR)buf,(LPSTR)(dir+1));
    _fstrcpy(dir,buf);
}

HFILE FAR PASCAL _export GetInFile (void)
{
    return inF;
}

HFILE FAR PASCAL _export GetOutFile (void)
{
    return outF;
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
        hInstDLL=hI;
    }

    if (reason==DLL_PROCESS_DETACH) {
        if (instances)
            ExitSupporterDLL();
    }

    return TRUE;
}

#else

/* initialize dll */
int FAR PASCAL LibMain (HANDLE hI,WORD wDSeg,WORD wHSize,LPSTR lpCmd)
{
    hInstDLL=hI;
    if (wHSize)
        UnlockData(0);
    return 1;
}

/* dll exit function */
int CALLBACK WEP (int exitType)
{
    // remove memory, if childs dont call exit-procedure
    if (instances)
        ExitSupporterDLL();
    return 1;
}

#endif
