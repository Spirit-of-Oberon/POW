/***************************************************************************
 *                                                                         *
 *  MODULE    : PowDDE.c                                                   *
 *                                                                         *
 *  PURPOSE   : Contains the DDE Server functions for Pow!                 *
 *                                                                         *
 *  FUNCTIONS : InitDDE - Start the Pow! DDE Server                        *
 *                                                                         *
 *              ExitDDE - Free all DDE Server memory                       *
 *                                                                         *
 ***************************************************************************/

#include <string.h>
#include <windows.h>
#include <ddeml.h>
#include <stdlib.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powcomp.h"
#include "powed.h"
#include "powrun.h"
#include "powopts.h"
#include "powproj.h"
#include "powtools.h"
#include "powCompiler.h"
                        
/* globals */
DWORD ddeInstId;                   // ddeml instance identifier

static FARPROC ddeProc;            // dde server callback function 
static BOOL ddeInstalled= FALSE;   // TRUE after service initializiaton (initdde)
static HSZ hService;               // dde string handle of service
static HSZ hTopic;                 // dde string handle of topic (pow window handle)
static char topic[10];             // topic string for this instance of pow!

                
/*************************************************
 * helper function:                              *
 * compare given topic with pow instance topic   *
 * return true, if equal or given topic is "pow" *
 *************************************************/
 
BOOL IsTopic (HSZ sz)
{              
    BOOL ret;
    ret=(DdeCmpStringHandles(sz,hService)==0) || (DdeCmpStringHandles(sz,hTopic)==0);
    return ret;
}    
                                                                         
                                                                         
/***************************************************
 * helper function:                                *
 * release data which was allocated by copyddedata *
 ***************************************************/

void FreeDDEData (HGLOBAL hMem)
{
    GlobalUnlock(hMem);
    GlobalFree(hMem);
}
   
   
/*******************************************************************
 * helper function:                                                *
 * case-insensitive string compare (until space or null character) *
 *******************************************************************/

BOOL IsCommand (LPSTR s,LPSTR t)
{           
    if (!s || !t) return 0;
    while (*s && *t && *s!=' ' && *t!=' ' && (*s&0xdf)==(*t&0xdf)) {
        s++;
        t++;
    }       
    return (*s==*t || (*s==' ' && *t==0));
}
 
                                                                         
/*********************************************************
 * helper function:                                      *
 * get second string in execute command (return pointer) *
 *********************************************************/
 
LPSTR GetExecData (LPSTR lp)
{
    if (lp) {
        while (*lp && *lp!=' ') lp++;        
        if (*lp==' ') lp++;
    }
    return lp;
} 


/*****************************************
 * helper function:                      *
 * compare a string handle with a string *
 *****************************************/
 
int IsEqualString (HSZ hsz,LPSTR lp)
{
    HSZ h;
    int ret;
    
    h=DdeCreateStringHandle(ddeInstId,lp,CP_WINANSI);
    ret=(DdeCmpStringHandles(hsz,h)==0);
    DdeFreeStringHandle(ddeInstId,h);
    return ret;
}
                                  
                                  
/**************************************************
 * helper function:                               *
 * insert file from disk in current edit position *
 **************************************************/
 
void InsertFile (LPSTR name)
{
    long len;
    LPSTR lp;
    HGLOBAL hMem;
    HFILE hFil;                        

    if (hFil=_lopen(name,OF_READ)) {
        len=_llseek(hFil,0,SEEK_END);
        _llseek(hFil,0,SEEK_SET);
        if ((len+1)<32000l) {
            if (hMem=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,len+1)) {                                 
                lp=GlobalLock(hMem);
                _lread(hFil,lp,(int)len);
                *(lp+len)=0;
                GlobalUnlock(hMem);                 
                if (OpenClipboard(hwndFrame)) {
                    SetClipboardData(CF_TEXT,hMem);
                    CloseClipboard();
                    EditPaste(GetActiveEditWindow(hwndMDIClient));
                }
            }
        }
        _lclose(hFil);
    }    
}


/**************************************************************************
 *                                                                        *
 *  FUNCTION   : PowDDEServerProc (hwnd,msg,wParam,lParam)                *
 *                                                                        *
 *  PURPOSE    : Callback function for Pow! DDE Service                   *
 *                                                                        *
 **************************************************************************/

HDDEDATA FAR PASCAL _export PowDdeServerProc (UINT type,UINT fmt,HCONV hconv,HSZ hsz1,HSZ hsz2,HDDEDATA hdata,DWORD dwData1,DWORD dwData2)
{                          
    LPSTR exec;
    HWND hWnd;                 
    DWORD size;
    HDDEDATA hDat;
    
    switch (type) {                  
    
        case XTYP_CONNECT:
            return (HDDEDATA)IsTopic(hsz1);
        
        case XTYP_EXECUTE:
        { 
            char buf[1000];
            
            if (IsTopic(hsz1)) {
                DdeGetData(hdata,buf,sizeof(buf),0);
                exec=GetExecData(buf);
                
                if (IsCommand(buf,"openfile")) {        
                    if (*exec && (hWnd=AlreadyOpen(exec)))
                        BringWindowToTop(hWnd);
                    else {
                        #ifndef _WIN32
                           DownStr(exec);
                        #endif
                        AddFile(exec);
                    }
                    return (HDDEDATA)DDE_FACK;    
                }

                else if (IsCommand(buf,"newfile")) {
                    hWnd=AddFile(0);
                    if (hWnd && *exec) {
                        HWND old;
                        if (old=AlreadyOpen(exec))
                            SendMessage (hwndMDIClient,WM_MDIDESTROY,(WPARAM)old,0L);
                        #ifndef _WIN32
                           DownStr(exec);
                        #endif
                        SetWindowText(hWnd,exec);
                        SetWindowWord(hWnd,GWW_UNTITLED,0);
                    }
                    return (HDDEDATA)DDE_FACK;    
                }

                else if (IsCommand(buf,"savefile")) {
                    if (GetActiveEditWindow(hwndMDIClient)) {
                        if (*exec) {
                            #ifndef _WIN32
                              AnsiLower(exec);
                            #endif
                            SetWindowText(GetActiveEditWindow(hwndMDIClient),exec);
                            SetWindowWord(GetActiveEditWindow(hwndMDIClient),GWW_UNTITLED,0);
                        }             
                        SendMessage(hwndFrame,WM_COMMAND,IDM_FILESAVE,0);
                    }    
                    return (HDDEDATA)DDE_FACK;    
                }

                else if (IsCommand(buf,"activate")) {
                    if (*exec && (hWnd=AlreadyOpen(exec)))
                        BringWindowToTop(hWnd);         
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"appendtext") || IsCommand(buf,"addtext")) {
                    if (*exec && GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))
                        EditAddText(GetActiveEditWindow(hwndMDIClient),exec);
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"inserttext")) {
                    if (*exec && GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))
                        EditInsertText(GetActiveEditWindow(hwndMDIClient),exec);
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"appendfile") || IsCommand(buf,"addtext")) {
                    if (*exec && GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) {
                        EditGotoPos(GetActiveEditWindow(hwndMDIClient),-1,-1);
                        InsertFile(exec);
                    }
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"insertfile")) {
                    if (*exec && GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))
                        InsertFile(exec);
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"showposition")) {
                    /* go to line/col of a given file (open if necessary) */
                    if (*exec) {
                        char *file,*sline,*scol;
                        int line=-1,col=-1;
                            
                        file=strtok(exec," ");
                        if (file) {
                            /* read position */
                            sline=strtok(NULL," ");
                            if (sline) {
                                line=atoi(sline);
                                scol=strtok(NULL," ");
                                if (scol)
                                    col=atoi(scol);
                            }
                                               
                            /* display the file */
                        if (hWnd=AlreadyOpen(file))
                            BringWindowToTop(hWnd);
                        else {
                            #ifndef _WIN32
                               DownStr(file);
                            #endif
                            AddFile(file);
                        }
                                              
                        /* set caret to given position */
                            EditGotoPos(GetActiveEditWindow(hwndMDIClient),line,col);
                        }
                    }
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"addtool")) {
                    /* create a new tool */
                    if (*exec) {
                        LPSTR lp;
                        char *name,*cmd,*dir,*options;
                        BOOL menu,askArg,toTop;
                        int buttonId;

                        name=cmd=dir=options=NULL;
                        menu=askArg=toTop=FALSE;
                        buttonId=0;

                        /* read tool name */
                        name=strtok(exec,",");
                        if (name) {
                            cmd=strtok(NULL,",");
                            if (cmd) {
                                dir=strtok(NULL,",");
                                if (dir) {
                                    options=strtok(NULL,",");
                                    if (options) {
                                       lp=strtok(NULL,",");
                                       if (lp) {
                                           menu=(BOOL)atoi(lp);
                                           lp=strtok(NULL,",");
                                           if (lp) {
                                               buttonId=atoi(lp);
                                               lp=strtok(NULL,",");
                                               if (lp) {
                                                   toTop=(BOOL)atoi(lp);
                                                   lp=strtok(NULL,",");
                                                   if (lp) {
                                                       askArg=(BOOL)atoi(lp);
                                                   }
                                               }
                                           }
                                       }
                                    }
                                }
                            }
                        }
                        if (strcmp(dir," ")==0) dir="";
                        if (strcmp(options," ")==0) options="";
                        if (name && cmd && *name && *cmd && (menu || buttonId))
                            ToolAdd(name,cmd,dir,options,menu,buttonId,toTop,askArg);
                    }
                    return (HDDEDATA)DDE_FACK;
                }

                else if (IsCommand(buf,"deletetool")) {
                    /* remove an external tool */
                    if (*exec)
                        ToolDelete(exec);
                    return (HDDEDATA)DDE_FACK;
                }
            }
            return (HDDEDATA)DDE_FNOTPROCESSED;
        }
    
        case XTYP_POKE:
        {
          if (IsTopic(hsz1)) 
          {
            if (IsEqualString(hsz2,"editbuffer")) 
            {        
              if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))  
              {
                LPSTR lBuf;                                              
                if (lBuf=DdeAccessData(hdata,(LPDWORD)&size)) 
                {
                  EditResetContent(GetActiveEditWindow(hwndMDIClient));
                  EditAddText(GetActiveEditWindow(hwndMDIClient),lBuf);
                  DdeUnaccessData(hdata);
                }    
              }
              return (HDDEDATA)DDE_FACK;
            }
          }    
          return (HDDEDATA)DDE_FNOTPROCESSED;
        }
     
        case XTYP_REQUEST:     
        {                      
          if (IsTopic(hsz1)) 
          {
            if (IsEqualString(hsz2,"activefile")) 
            {        
              if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))  
              {
                long len;
                char name[100];
                HSZ hitem;
                        
                hitem=DdeCreateStringHandle(ddeInstId,(LPSTR)"activefile",CP_WINANSI);
                len=GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)name,sizeof(name));
                return DdeCreateDataHandle(ddeInstId,(LPSTR)name,len+1,0,hitem,CF_TEXT,0);
              }
            }
            else if (IsEqualString(hsz2,"editbuffer")) 
            {        
              if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)))  
              {
                LPSTR lp;
                HGLOBAL h;
                if (h=EditGetText(GetActiveEditWindow(hwndMDIClient))) 
                {
                  HSZ hitem;
                          
                  hitem=DdeCreateStringHandle(ddeInstId,(LPSTR)"editbuffer",CP_WINANSI);
                  lp=GlobalLock(h);
                  hDat=DdeCreateDataHandle(ddeInstId,lp,GlobalSize(h),0,hitem,CF_TEXT,0);
                  GlobalUnlock(h);
                  GlobalFree(h);
                }
                else 
                  hDat=0;
                return hDat;
              }
            }
            else if (IsEqualString(hsz2,"compiler")) 
            {        
              /* return name of active compiler interface dll */
              char name[100];
              HSZ hitem;
                        
              hitem=DdeCreateStringHandle(ddeInstId,(LPSTR)"compiler",CP_WINANSI);
              strcpy(name,actConfig.compiler);
              return DdeCreateDataHandle(ddeInstId,(LPSTR)name,strlen(name)+1,0,hitem,CF_TEXT,0);
            }
            else if (IsEqualString(hsz2,"executable")) 
            {        
              /* return name of target executale */
              BOOL isExecutable;
              //FARPROC lpfn;                  
              char name[500];
              HSZ hitem;
                    
              if (IsCompilerInterfaceLoaded()) 
              {
                if (!*actPrj) 
                {
                  RemoveMessageWindow();
                  if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient)) && !GetWindowWord(GetActiveEditWindow(hwndMDIClient),GWW_UNTITLED)) 
                  {
                    SetDefaultProjectName();
                    isExecutable=(*compGetTarget)(hCompData,(LPSTR)name);
                    if (*name && *RunArgs) 
                    { 
                      /* append run arguments (as string included in "") */
                      strcat(name," \"");
                      strcat(name,RunArgs);
                      strcat(name,"\"");
                    }
                  }
                  else *name=0;
                }
                else 
                  isExecutable=(*compGetTarget)(hCompData,(LPSTR)name);
              }
              else *name=0;
                    
              hitem=DdeCreateStringHandle(ddeInstId,(LPSTR)"executable",CP_WINANSI);
              return DdeCreateDataHandle(ddeInstId,(LPSTR)name,strlen(name)+1,0,hitem,CF_TEXT,0);
            }
          }
          return (HDDEDATA) NULL;
        }    
    }                                        
    if (type&XCLASS_FLAGS)
        return (HDDEDATA)DDE_FNOTPROCESSED;
    else
        return (HDDEDATA)NULL;              
}

                                                                                    
/**************************************************************************
 *                                                                        *
 *  FUNCTION   : InitDDE (powinstance)                                    *
 *                                                                        *
 *  PURPOSE    : Start the Pow! DDE Service, topic is instance win-handle *
 *                                                                        *
 **************************************************************************/

void FAR InitDDE (HWND powinstance)
{
    ddeProc=MakeProcInstance((FARPROC)PowDdeServerProc,hInst);
    ddeInstId=0;             
    
    // use window handle as topic to make it possible
    // to call specific instances of pow!
    wsprintf((LPSTR)topic,"%04X",powinstance);
                                    
    if (DdeInitialize((LPDWORD)&ddeInstId,(PFNCALLBACK)ddeProc,APPCLASS_STANDARD,0)==DMLERR_NO_ERROR) {
        ddeInstalled=TRUE;
        hService=DdeCreateStringHandle(ddeInstId,"pow",CP_WINANSI);
        hTopic=DdeCreateStringHandle(ddeInstId,(LPSTR)topic,CP_WINANSI);
        DdeNameService(ddeInstId,hService,0,DNS_REGISTER);
    }    
}


/**************************************************************************
 *                                                                        *
 *  FUNCTION   : ExitDDE ()                                               *
 *                                                                        *
 *  PURPOSE    : Stop the Pow! DDE Service                                *
 *                                                                        *
 **************************************************************************/

void FAR ExitDDE (void)
{
    if (ddeInstalled) {
        if (DdeNameService(ddeInstId,hService,0,DNS_UNREGISTER)) {
            DdeFreeStringHandle(ddeInstId,hService);
            DdeFreeStringHandle(ddeInstId,hTopic);
            DdeUninitialize(ddeInstId);
        }
        ddeInstalled=FALSE;
    }    
    FreeProcInstance(ddeProc);                
}                
