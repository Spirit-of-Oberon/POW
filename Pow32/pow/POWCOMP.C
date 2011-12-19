/***************************************************************************
 *                                                                         *
 *  MODULE    : PowComp.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for the Compile Menu of Pow!             *
 *                                                                         *
 *  FUNCTIONS : CompileFile   - Compiles a single File and updates         *
 *                              the Error List                             *
 *                                                                         *
 *              NextError     - Find next error                            *
 *                                                                         *
 *              PrevError     - Find previous error                        *
 *                                                                         *
 *              OpenProject   - Open an existing/Create a new project file *
 *                                                                         *
 *              EditProject   - Edit the current project file              *
 *                                                                         *
 *              MakeProject   - Compile all necessary files and link       *
 *                                                                         *
 *              BuildProject  - Compile all files of a project and link    *
 *                                                                         *
 *              LinkOnlyProject - Generate executable without compilation  *
 *                                                                         *
 *              CompilerHelp  - Asks for compiler specific help            *
 *                                                                         *
 ***************************************************************************
 * Date      Author  Changes, Remarks
 * --------  ------  -----------------------------------------------------
 * ??-??-??  KRE     Ported from 16-Bit Version
 * 98-09-01  PDI     Bugs removed which caused a crash if the error 
 *                   message was too long
 ***************************************************************************/

#include <io.h>
#include <dos.h>
#include <fcntl.h>
#include <errno.h>
#include <direct.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <commdlg.h>
#include <dlgs.h>

#include "POWCOMP.H"
#include "..\powsup\powsupp.h"
//#include "pow.h"
#include "powopts.h"
#include "powproj.h"
#include "powopen.h"
#include "powribb.h"
#include "powhelp.h"
#include "powrun.h"
#include "powed.h"
#include "resource.h"
#include "powCompiler.h"

#undef HIWORD
#undef LOWORD
#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

#define MAXMOD 100    /* maximum number of modules in project */
#define MAXERR 100
#define FILEMUSTBECOMPILED (time_t)-1 /* timestamp in project to force compilation of a module */

#define WARNINGTEXT "Warning"
#define ERRORTEXT   "Error"

typedef struct {
    int line;
    int col;
    BOOL warn;
    char fil[MAXPATHLENGTH];          /* changed by PDI */
    char msg[MAXPATHLENGTH];          /* changed by PDI */
} ERRMSG;

typedef char MODNAM[MAXPATHLENGTH];
typedef char MODEXT[MAXPATHLENGTH];

typedef struct {
    MODNAM name;
    MODEXT ext;
    int depends[];
} DepMatLine;

typedef ERRMSG far *LPERRMSG;
typedef DepMatLine far *LPDepMatLine;

int errCnt;                  /* # of errors */
int wrnCnt;                  /* # of warnings */
int actErr;                  /* index of actual error */
char actComp[MAXPATHLENGTH];           /* name of file currently compiled */
char errMod[MAXPATHLENGTH];             /* compiled (erroneous) module */
HWND actDlg;                 /* window handle */
HWND msgWnd=0;               /* window handle of message window */
LPSTR toCheck;               /* pointer to module to check dependency */
BOOL readOnlyWindow=FALSE;   /* flag, if edit to be created shall be read-only */
int modNr;                   /* nr of module to check */
int messages,errMsg[MAXERR]; /* actual error message */
HCURSOR hHourGlass;          /* hourglass cursor */
HANDLE oldFiles;             /* save-list for edit project dialog */
int collected;               /* number of collected files for default project */

/* dependency matrix */
int depNr;                   /* number of modules */
int depLen;                  /* length in bytes of a single line in matrix */
int depOfs;                  /* Offset from filename to dependencies */
HANDLE hDep=0;               /* handle to dependency matrix */
LPSTR depend;                /* pointer to dependency matrix */

/*
typedef BOOL FAR PASCAL CompProc (HANDLE,LPSTR,FARPROC,FARPROC,HWND,FARPROC,FARPROC,FARPROC,FARPROC,FARPROC,HANDLE);
typedef BOOL FAR PASCAL LinkProc (HANDLE,LPSTR,HANDLE,FARPROC);
typedef BOOL FAR PASCAL CompOptProc (HANDLE,HWND);
typedef BOOL FAR PASCAL LinkOptProc (HANDLE,HWND);
typedef void FAR PASCAL CheckDepProc (HANDLE,LPSTR,FARPROC,HWND,FARPROC,FARPROC,FARPROC,FARPROC,FARPROC,HANDLE);
typedef BOOL FAR PASCAL HelpProc (HANDLE,HWND,LPSTR,WORD,DWORD);
typedef void FAR PASCAL NewProjectProc (HANDLE);
typedef BOOL FAR PASCAL FileWasCompiledProc (HANDLE,LPSTR);
typedef BOOL FAR PASCAL SourceAvailableProc (HANDLE,LPSTR,LPSTR);
typedef BOOL FAR PASCAL MustBeBuiltProc (HANDLE,LPSTR);
typedef BOOL FAR PASCAL CheckIfYoungerProc (HANDLE,LPSTR,LPSTR);
typedef void FAR PASCAL NewProjectNameProc (HANDLE,LPSTR);
*/
typedef void FAR PASCAL MsgOutProc (LPSTR);

int fileIn,count,projectListChanged;
char fileComp[MAXPATHLENGTH];

HANDLE moduleList;
FARPROC dependProc;
/*
FARPROC mustBuildProc;
FARPROC srcAvailProc;
FARPROC getDependProc;
FARPROC checkIfYoungerProc;
*/

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : DefLoadNextBuffer (LPHANDLE file,LPSTR buf,long n)        *
 *                                                                         *
 *  PURPOSE    : Load the next n bytes from ascii file <file>              *
 *                                                                         *
 ***************************************************************************/
          
#define MAXOPEN 100                      
static HFILE fHandles[MAXOPEN]={0};
 
int FAR PASCAL _export DefOpenFile (LPSTR file)
{                      
    int n;
    
    for (n=1;n<MAXOPEN;n++)
  if (fHandles[n]==0) {
      fHandles[n]=_lopen(file,OF_READ);
      return n;
  }
    return 0;
}

long FAR PASCAL _export DefReadFile (int handle,LPSTR buf,long n)
{
    if (handle)
  return (long)_lread(fHandles[handle],buf,(unsigned)n);
    else
  return 0;
}

void FAR PASCAL _export DefCloseFile (int handle)
{                      
    _lclose(fHandles[handle]);
    fHandles[handle]=0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetError (int,LPERRMSG)                                   *
 *                                                                         *
 *  PURPOSE    : Get the n-th error message (read it from error window)    *
 *                                                                         *
 ***************************************************************************/

BOOL GetError (int n, LPERRMSG eMsg)
{

  char  buf[20];
  int   charCnt;    /* added by PDI */
  LPSTR dst;
  int   i;
  int   len;        /* added by PDI */
  BOOL  ok;
  LPSTR src;
  char  txt[MAXPATHLENGTH];

  /* -- look for error message number n -- */
  i = 0;
  while ((errMsg[i] != n) && (i < messages)) i++;

  if (msgWnd && (i < messages)) {

    charCnt = EditGetLine(msgWnd, i, sizeof(txt), (LPSTR)txt);
    if (!charCnt) return FALSE;
      
    ok = TRUE;
    eMsg->line = 0;
    eMsg->col  = 0;
    eMsg->warn = FALSE;                 /* added by PDI     */
    strcpy(eMsg->fil, "");              /* added by PDI     */
    strcpy(eMsg->msg, "");              /* added by PDI     */
      
    /* extract file name */
    src = (LPSTR)txt;
    dst = (LPSTR)&(eMsg->fil);
    len = sizeof(eMsg->fil) - 1;        /* added by PDI     */
    while (*src && len && *src!='(') {  /* changed by PDI   */
      *dst++ = *src++;
      charCnt--;
      len--;                            /* added by PDI     */
    }
    *dst=0;

    /* extract line number */
    if (*src) {
      src++;
      strcpy(buf, "");
      dst = (LPSTR)buf;
      len = sizeof(buf) - 1;            /* added by PDI     */
      while (*src && len && *src!=':' && *src!=')') {   /* pdi */
        *dst++=*src++;
        charCnt--;
        len--;
      }
      *dst=0;
      if (*buf==0) 
        eMsg->line=-1;         /* no error line number */
      else 
        eMsg->line=(int)MakeLon((LPSTR)buf);
   
/*      if (*src==')') eMsg->col=-1; */       /* no error column number */
    }
    else 
      ok = FALSE;

    /* extract column */
    if (*src) {
      src++;
      strcpy(buf, "");
      dst = (LPSTR)buf;
      len = sizeof(buf) - 1;            /* added by PDI     */
      while (*src && len && *src!=')') {   /* pdi */
        *dst++ = *src++;
        charCnt--;
        len--;
      }
      *dst=0;
      if (*buf==0) 
        eMsg->col = -1;         /* no column */
      else 
        eMsg->col = (int)MakeLon((LPSTR)buf);
   
    }
    else 
      ok = FALSE;
/*    if (*src) {
      if (eMsg->col!=-1) {
        src++;
        dst=(LPSTR)buf;
        while (*src && *src!=')') {
          *dst++=*src++;
          charCnt--;
        }
        *dst=0;
        eMsg->col=(int)MakeLon((LPSTR)buf);
      }
    }
    else ok=FALSE;*/
       
    /* extract warning flag */  
    if (*src)
      eMsg->warn=(strstr(src,(LPSTR)WARNINGTEXT)!=0);
    else
      ok=FALSE;
       
    /* extract error message */
    if (*src) {
      src+=3;                        
      charCnt-=5;
      dst = (LPSTR)&(eMsg->msg);
      len = sizeof(eMsg->msg) - 1;
      while (charCnt && len) {
        *dst++=*src++;
        charCnt--;
        len--;
      }
      *dst=0;
    }
    else 
      ok = FALSE;
  
    return ok;
  }

  return FALSE;

}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowError (int)                                           *
 *                                                                         *
 *  PURPOSE    : Sets the cursor to error position actErr+displacement     *
 *                                                                         *
 ***************************************************************************/

void ShowError (int displace)
{
    HWND hwnd;
    ERRMSG eMsg;

    /* compile caused errors? */
    if ((!errCnt) && (!wrnCnt))
       return;            
        
    /* only warnings and these shall be ignored */          
    if ((!errCnt) && actConfig.searchIgnoreWarnings)
       return;
      
    /* find next error (if warnings are disabled) */                                              
    do {                                              
       actErr+=displace;
       if (actErr<1) actErr=errCnt+wrnCnt;
       if (actErr>errCnt+wrnCnt) actErr=1;
       if (!GetError(actErr,(LPERRMSG)&eMsg)) return;
    } while (eMsg.warn && actConfig.searchIgnoreWarnings && displace); 
    
    /* show file with error */
    if (hwnd=AlreadyOpen((LPSTR)&(eMsg.fil)))
       BringWindowToTop(hwnd);
    else
       hwnd=AddFile((LPSTR)&(eMsg.fil));

    /* set cursor to error position */
    if (eMsg.line!=-1) {
      if (eMsg.col==-1)
        EditGotoPos(hwnd,eMsg.line,1);
      else
        EditGotoPos(hwnd,eMsg.line,eMsg.col);
    }

    /* display error message in status line */
    NewMessage((LPSTR)&(eMsg.msg),TRUE);
    NewLineNr(eMsg.line,eMsg.col);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NextError ()                                              *
 *                                                                         *
 *  PURPOSE    : Sets the cursor to the next error position                *
 *                                                                         *
 ***************************************************************************/

void FAR NextError ()
{
    ShowError(1);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : PrevError ()                                              *
 *                                                                         *
 *  PURPOSE    : Sets the cursor to the previous error position            *
 *                                                                         *
 ***************************************************************************/
void FAR PrevError ()
{
    ShowError(-1);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetTargetName (exe)                                       *
 *                                                                         *
 *  PURPOSE    : Returns the name of the target file to build in exe       *
 *               and TRUE if it is executable.                             *
 *                                                                         *
 ***************************************************************************/
void FAR GetTargetName (LPSTR exe, BOOL* isExecutable)
{       
  char projectName[MAXPATHLENGTH];
	HWND hWndActive;

  hWndActive = GetActiveEditWindow(hwndMDIClient);  /* added by PDI */

  if (!*actPrj) 
  {
    if (!hWndActive || !IsEditWindow(hWndActive)) 
    {
      *exe=0;
      *isExecutable=FALSE;
      return;
    }
    GetWindowText(hWndActive,projectName,sizeof(projectName));
    (*compNewProjectName)(hCompData,(LPSTR)projectName);
  }
  *isExecutable=(*compGetTarget)(hCompData,(LPSTR)exe);
  if (!*actPrj) (*compNewProjectName)(hCompData,(LPSTR)defPrj);
}



/***************************************************************************
 *                                                                         *
 *  FUNCTION   : OpenProject ()                                            *
 *                                                                         *
 *  PURPOSE    : Opens an existing or creates a new project file.          *
 *               Return value is TRUE if a project could be opened,        *
 *               else it is FALSE.                                         *
 *                                                                         *
 ***************************************************************************/

BOOL FAR OpenProject ()
{
    char fNam[MAXPATHLENGTH]="*.prj";
    BOOL existed;
    
    GetFileName((LPSTR)fNam,"Open Project",FALSE,(LPEXT)&PrjExt,1,hwndFrame);
    existed=FileExists((LPSTR)fNam);
    
    if (*fNam && (existed || (Message(hwndFrame,MB_YESNO|MB_ICONQUESTION,IDS_CREATEPROJECT,(LPSTR)fNam)==IDYES))) {
  if (!stricmp((LPSTR)defPrj,(LPSTR)fNam))
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTOPENDEFPRJ); /*2.0*/
  else {
      CloseProject(FALSE);
      strcpy(actPrj,fNam);

        /* try to load the project */
        if (ReadProject(actPrj,FALSE) || !existed) 
            AppendHistory(prjHistory,fNam);
      else
            *actPrj = 0;

        if (!existed) {
          CloseAllChildren();
          ShowWindow(hwndMDIClient,SW_SHOW);
          EditProject();
      }
  }    
  return TRUE;
    }
    else
  return FALSE;
}

/****************************************************************************
 *                                                                          *
 *  FUNCTION   : MakeEmptyProject ()                                        *
 *                                                                          *
 *  PURPOSE    : Generate a new project derivated from the default project. *
 *                                                                          *
 ****************************************************************************/

BOOL FAR MakeEmptyProject ()
{
    char fNam[MAXPATHLENGTH]="*.prj";
    BOOL existed;
    
    if (*actPrj)
        WriteProject((LPSTR)actPrj);
    else                            
        WriteProject((LPSTR)defPrj);         /*2.0*/

    GetFileName((LPSTR)fNam,"Make New Project",FALSE,(LPEXT)&PrjExt,1,hwndFrame);
    existed=FileExists((LPSTR)fNam);
    
    if (*fNam && (!existed || (Message(hwndFrame,MB_YESNO|MB_ICONQUESTION,IDS_OVERWRITEFILE,(LPSTR)fNam)==IDYES))) {
      if (!stricmp((LPSTR)defPrj,(LPSTR)fNam))
          Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTOPENDEFPRJ); /*2.0*/
      else {
          CloseProject(FALSE);

            if (existed)
                DeleteFile(fNam);

          strcpy(actPrj,fNam);

            /* try to load the project */
            ReadProject(actPrj,FALSE);
            AppendHistory(prjHistory,fNam);
            CloseAllChildren();
            ShowWindow(hwndMDIClient,SW_SHOW);
            EditProject();
      }    
      return TRUE;
    }
    else
      return FALSE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveAsProject ()                                          *
 *                                                                         *
 *  PURPOSE    : Saves open project under a new name.                      *
 *               Return value is TRUE if a project could be saved,         *
 *               else it is FALSE.                                         *
 *                                                                         *
 ***************************************************************************/

void FAR SaveAsProject ()
{
    char fNam[MAXPATHLENGTH]="*.prj",new[MAXPATHLENGTH];

    GetFileName((LPSTR)fNam,"Save Project as",TRUE,(LPEXT)&PrjExt,1,hwndFrame);
    if (*fNam) {
  if (_fullpath(new,fNam,sizeof(new))!=NULL) {
      AnsiLower((LPSTR)new);
      AppendHistory(prjHistory,new);
      strcpy(actPrj,new);
      WriteProject(actPrj);
      ProjectCaption();
  }
  else Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_ILLFNM,(LPSTR)fNam);
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CompilerOptions (HWND)                                    *
 *                                                                         *
 *  PURPOSE    : Starts the compile options dialog.                        *
 *                                                                         *
 ***************************************************************************/

VOID FAR CompilerOptions(HWND parent)
{
  char prj[MAXPATHLENGTH];
  int i,n;
  HANDLE h;                 
  LPPrjFile fil;

  if (IsCompilerInterfaceLoaded()) {
  
    if ((*compCompOpt)(hCompData,parent)) 
    {
       
      /*2.0*/
      if (*actPrj)
        lstrcpy((LPSTR)prj,(LPSTR)actPrj);
      else
        lstrcpy((LPSTR)prj,(LPSTR)defPrj);

      n=CountList(actProject.files);
      // change timestamps for all source modules
      for (i=1;i<=n;i++) 
      {
        if (h=GetElemH(actProject.files,i)) 
        {
          fil=(LPPrjFile)GlobalLock(h);
          if (CheckIfSource((LPSTR)&(fil->name)))
            fil->timeStamp=FILEMUSTBECOMPILED;
          GlobalUnlock(h);                       
        }    
      }   
      // write the new project file to disk
      if (!WriteProject((LPSTR)prj))
      Message(parent,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,(LPSTR)prj);
    }        
  }
  else
    Message(parent,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : LinkerOptions (HWND)                                      *
 *                                                                         *
 *  PURPOSE    : Starts the linker options dialog.                         *
 *                                                                         *
 ***************************************************************************/

VOID FAR LinkerOptions(HWND parent)
{
  if (IsCompilerInterfaceLoaded()) 
  {
    char prj[MAXPATHLENGTH];
  
    if ((*compLinkOpt)(hCompData,parent)) 
    {
      /*2.0*/
      if (*actPrj)
        lstrcpy((LPSTR)prj,(LPSTR)actPrj);
      else
        lstrcpy((LPSTR)prj,(LPSTR)defPrj);

      if (!WriteProject((LPSTR)prj))
        Message(parent,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,(LPSTR)prj);
      else 
        actProject.changed=TRUE;    
    }
  }
  else
    Message(parent,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
}

/**************************************************************************
 *  Supporter-Functions for Project-Dialog procedure                      *
 **************************************************************************/


BOOL FAR PASCAL _export FileInProject (LPLIST l)
{
    LPPrjFile file;
    char buf[MAXPATHLENGTH];

    count++;
    file=(LPPrjFile)GlobalLock(l->elem);
    lstrcpy(buf,(LPSTR)&(file->name));
    AnsiLower(buf);
    if ((strlen(buf)==strlen(fileComp)) && (stricmp(buf,fileComp)==0)) {
  GlobalUnlock(l->elem);
  fileIn=count;
  return FALSE;
    }
    GlobalUnlock(l->elem);
    return TRUE;
}

int FAR FileAlreadyIn (LPSTR id)
{
    FARPROC in;
         
    /*2.0*/
    //if (!*actPrj)
    //    return 0;
    
    count=0;
    fileIn=0;
    in=MakeProcInstance(FileInProject,hInst);
    lstrcpy((LPSTR)fileComp,id);
    DownStr((LPSTR)fileComp);
    ListForEach(actProject.files,in);
    FreeProcInstance(in);
    return fileIn;
}

void AddToProject (HWND hdlg,LPSTR id)
{
    PrjFile fil;

    lstrcpy((LPSTR)&(fil.name),id);
    #ifndef _WIN32
      DownStr((LPSTR)&(fil.name));
    #endif
    fil.timeStamp=0;

    if ((!Wildcard(id)) && (!FileAlreadyIn(id))) {
  int n;
  n=(int)SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_ADDSTRING,0,(long)(LPSTR)&(fil.name));
  SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_SETCURSEL,n,0);
  /* add to actual project */
  AddElem(&actProject.files,(long)(LPSTR)&fil,sizeof(PrjFile));
  actProject.changed=TRUE;
  projectListChanged=TRUE;
    }
}

void DelFromProject (HWND hdlg,LPSTR id)
{
    int n;
    long idx;

    idx=SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_FINDSTRING,(WPARAM)-1,(long)id);
    if (idx!=LB_ERR) {
  SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_DELETESTRING,LOWORD(idx),0);
  /* purge from actual project file */
  if (n=FileAlreadyIn(id)) {
      DelElem(&actProject.files,n);
      actProject.changed=TRUE;
      projectListChanged=TRUE;
  }    
    }
}

BOOL FAR PASCAL _export InsProjectFile (LPLIST l)
{
    LPPrjFile file;

    file=(LPPrjFile)GlobalLock(l->elem);
    SendDlgItemMessage(actDlg,IDD_PRJLIST,LB_ADDSTRING,0,(long)(LPSTR)&(file->name));
    GlobalUnlock(l->elem);
    return TRUE;
}

void SaveList ()
{
    int n;
    PrjFile file;

    oldFiles=0;
    for (n=1;n<=CountList(actProject.files);n++) {
  GetElem(actProject.files,n,(long)(LPPrjFile)&file);
  AddElem(&oldFiles,(long)(LPPrjFile)&file,sizeof(PrjFile));
    }
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : EditProjectHookProc (hwnd,msg,wParam,lParam)             *
 *                                                                        *
 *  PURPOSE    : Hook function for the customized Open File dialog        *
 *               for editing the project file list.                       *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export EditProjectHookProc (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
{
  FARPROC ins;

  switch (msg) 
  {

    case WM_INITDIALOG: {

      /* caption */
      if (*actPrj)
        SendMessage(hdlg,WM_SETTEXT,0,(long)(LPSTR)actPrj);
      else
        SendMessage(hdlg,WM_SETTEXT,0,(long)(LPSTR)defPrj);
  
      /* save file list */
      SaveList();

      actDlg=hdlg;
      projectListChanged=0;
  
      SendMessage(GetDlgItem(hdlg,IDD_PRJLIST),LB_RESETCONTENT,0,0);
      ins=MakeProcInstance(InsProjectFile,hInst);
      ListForEach(actProject.files,ins);
      FreeProcInstance(ins);

      /* disable delete button */
      EnableWindow(GetDlgItem(hdlg,IDD_PRJDEL),FALSE);
      return 1;
                        
    }

    case WM_COMMAND:
  
      #ifdef _WIN32
        switch (LOWORD(wParam)) {
      #else
        switch (wParam) {
      #endif

      case IDOK:

        /* project list has changed? */
        if (projectListChanged) 
        {
          int i,n;
          HANDLE h;
          LPPrjFile fil;
        
          n=CountList(actProject.files);
          /* change timestamps for all source modules */
          for (i=1;i<=n;i++) 
          {
            if (h=GetElemH(actProject.files,i)) 
            {
              fil=(LPPrjFile)GlobalLock(h);
              if (CheckIfSource((LPSTR)&(fil->name)))
                fil->timeStamp=FILEMUSTBECOMPILED;
              GlobalUnlock(h);                       
            }    
          }
        }
    
        /* save project definitions */
        if (*actPrj) 
        {
          if (!WriteProject((LPSTR)actPrj))
          Message(hdlg,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,(LPSTR)actPrj);
        }
        else
        /*2.0*/
          if (!WriteProject((LPSTR)defPrj))
            Message(hdlg,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,(LPSTR)defPrj);
        ProjectToRibbon();
        EndDialog(hdlg,wParam);
        return 1;

      case IDCANCEL:

        /* restore file list */
        PurgeList((LPHANDLE)&actProject.files);
        actProject.files=oldFiles;
    
        EndDialog(hdlg,wParam);
        return 1;

      case IDD_HELP:

        WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Editieren_der_Projektdefinition);
        return 1;

      case IDD_PRJADD:

        #ifdef _WIN32
        if (HIWORD(wParam)==BN_CLICKED) {
        #else
        if (HIWORD(lParam)==BN_CLICKED) {
        #endif

          char file[MAXPATHLENGTH],buf[MAXPATHLENGTH];
             
          GetDlgItemText(hdlg,edt1,(LPSTR)buf,sizeof(buf));
          _fullpath(file,buf,sizeof(buf));

          #ifndef _WIN32
            AnsiLower(file);
          #endif

          if (FileExists(file))
            AddToProject(hdlg,(LPSTR)file);
          else
            Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_FILENOTEXISTS,file);
          return 1;
        }
        break;

      case IDD_PRJDEL:

        #ifdef _WIN32
        if (HIWORD(wParam)==BN_CLICKED) {
        #else
        if (HIWORD(lParam)==BN_CLICKED) {
        #endif

          char name[MAXPATHLENGTH];
          long idx,count;

          idx=SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_GETCURSEL,0,0);
          if (idx!=LB_ERR) 
          {
            SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_GETTEXT,LOWORD(idx),(long)(LPSTR)name);
            DelFromProject(hdlg,(LPSTR)name);
            SetFocus(GetDlgItem(hdlg,IDD_PRJADD));
            if (count=SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_GETCOUNT,0,0)) 
            {
              count--;  /* index is zero-based */
              if (idx>count) idx=count;
              SendDlgItemMessage(hdlg,IDD_PRJLIST,LB_SETCURSEL,(WPARAM)idx,0);
            }
            else
              EnableWindow(GetDlgItem(hdlg,IDD_PRJDEL),FALSE);
          }
          return 1;
        }
        break;

      case IDD_PRJLIST:

        #ifdef _WIN32
        if (HIWORD(wParam)==LBN_SETFOCUS) {
        #else
        if (HIWORD(lParam)==LBN_SETFOCUS) {
        #endif

          EnableWindow(GetDlgItem(hdlg,IDD_PRJDEL),TRUE);
          return 1;
        }
        break;
    
      case lst1:
      
        #ifdef _WIN32
        if (HIWORD(wParam)==LBN_DBLCLK) {
        #else
        if (HIWORD(lParam)==LBN_DBLCLK) {
        #endif

          SendMessage(hdlg,WM_COMMAND,IDD_PRJADD,MAKELONG(0,BN_CLICKED));
          return 1;
        }
        break;
    
      default:  
      
        break;
      }
      break;
  
    default:
    
      break;

  }
  return 0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : EditProject ()                                            *
 *                                                                         *
 *  PURPOSE    : Edits the actual project definitions                      *
 *               (memory sizes and project files)                          *
 *                                                                         *
 ***************************************************************************/

void FAR EditProject () {

    int i;
    LPSTR s;
    OPENFILENAME ofn;
    FARPROC hookProc;
    char filter[1000],title[MAXPATHLENGTH],file[MAXPATHLENGTH];
    
    *filter=0;
    for (i=0;i<addN;i++) {
       strcat(filter,AddExt[i].doc);
       strcat(filter,"|");
       strcat(filter,AddExt[i].ext);
       strcat(filter,"|");
    }
    strcat(filter,"|");
     
    s=filter;
    while (*s!=0) {
       if (*s=='|') *s=0;
       s++;
    }                
          
    *file=0;                                    
    hookProc=MakeProcInstance(EditProjectHookProc,hInst);
    memset(&ofn,0,sizeof(OPENFILENAME));

    ofn.lStructSize=sizeof(OPENFILENAME);
    ofn.hwndOwner=hwndFrame;
    ofn.lpstrFilter=filter;
    ofn.nFilterIndex=1;
    ofn.lpstrFile=file;
    ofn.nMaxFile=sizeof(file);
    ofn.lpstrFileTitle=title;
    ofn.nMaxFileTitle=sizeof(title);
    ofn.lpstrInitialDir=0;
    ofn.lpfnHook=(UINT (CALLBACK *)(HWND,UINT,WPARAM,LPARAM))hookProc;
    ofn.lpTemplateName=MAKEINTRESOURCE(1000);
    ofn.hInstance=hInst;
    ofn.Flags=OFN_SHOWHELP|OFN_PATHMUSTEXIST|OFN_HIDEREADONLY|OFN_ENABLEHOOK|OFN_ENABLETEMPLATE;
  
    GetOpenFileName(&ofn);
    
    FreeProcInstance(hookProc);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CloseProject (BOOL readDef)                               *
 *                                                                         *
 *  PURPOSE    : Closes the actual project file and reads the default      *
 *               project, if <readDef>=TRUE.                               *
 *                                                                         *
 ***************************************************************************/

void FAR CloseProject (BOOL readDef) {

//    FARPROC lpNew;
  char buffer[MAXPATHLENGTH];
	HWND hWndActive;
    
    // close list of project files                     
    SendMessage(hProj,CB_SHOWDROPDOWN,FALSE,0);

    // save all open files        
    hWndActive = (HWND) SendMessage(hwndMDIClient, WM_MDIGETACTIVE, 0L, 0L);  /* added by PDI */
    SaveProjectEdits(hWndActive, TRUE);

    /*2.0*/    
    if (*actPrj)
      WriteProject((LPSTR)actPrj);                      
    else
      SendMessage(hProj,CB_RESETCONTENT,0,0);
    
    *actPrj=0;
    RemoveDependMatrix();
    
    buffer[0]=0;
    if (IsCompilerInterfaceLoaded()) (*compNewProject)(hCompData,buffer);
        
    actProject.changed=FALSE;
    PurgeList((LPHANDLE)&(actProject.files));
    //ProjectCaption();
    //ProjectToRibbon();
    if (readDef) ReadProject(defPrj,TRUE);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : InitMessageWindow ()                                      *
 *                                                                         *
 *  PURPOSE    : Prepares the compiler message window for output.          *
 *                                                                         *
 ***************************************************************************/

void InitMessageWindow (HWND hWndClient) {

  if (msgWnd) {                       

    /* -- set to original size, if minimized -- */
    if (GetWindowLong(msgWnd,GWL_STYLE) & WS_ICONIC) ShowWindow(msgWnd, SW_RESTORE);

    /* -- clear window -- */
    EditResetContent(msgWnd);
    BringWindowToTop(msgWnd);

  } else {

    /* -- create new message window -- */
    RECT            r;
    MDICREATESTRUCT mcs;
		HWND            hWndActive;		/* active child window */
  
    mcs.szTitle  = MESSAGEWINDOW;
    mcs.szClass  = szChild;
    mcs.hOwner   = hInst;
    mcs.x=mcs.cx = CW_USEDEFAULT;
    mcs.y=mcs.cy = CW_USEDEFAULT;
    mcs.style    = styleDefault;

    hWndActive = (HWND) SendMessage(hWndClient, WM_MDIGETACTIVE, 0L, 0L);  /* added by PDI */
    if (hWndActive && (GetWindowLong(hWndActive, GWL_STYLE) & WS_MAXIMIZE))
      mcs.style += WS_MAXIMIZE;

    /* tell the MDI Client to make an read-only control */
    readOnlyWindow=TRUE;

    /* tell the MDI Client to create the child */
    msgWnd = (HWND)SendMessage(hWndClient, WM_MDICREATE, 0, (LONG)(LPMDICREATESTRUCT)&mcs);
    
    GetClientRect(msgWnd,(LPRECT)&r);
    EditResizeWindow(msgWnd, r.right - r.left + 1, r.bottom - r.top + 1);

    readOnlyWindow=FALSE;
  }

  if (msgWnd) {
    InvalidateRect(msgWnd,NULL,TRUE);
    UpdateWindow(msgWnd);
  }                       

  errCnt=0;
  wrnCnt=0;
  actErr=0;
  messages=0;
  memchr((LPSTR)errMsg,0,sizeof(errMsg));

}


/***************************************************************************
 *                                                                         *
 *  FUNCTION   : RemoveMessageWindow ()                                    *
 *                                                                         *
 *  PURPOSE    : Removes the message window, if existing.                  *
 *                                                                         *
 ***************************************************************************/

void FAR RemoveMessageWindow (void)
{
    if (msgWnd) {
  SendMessage(hwndMDIClient,WM_MDIDESTROY,(WPARAM)msgWnd,0);
  msgWnd=0;
    }
}


/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CheckIfSource (LPSTR)                                     *
 *                                                                         *
 *  PURPOSE    : Checks, if given filename designates a source file.       *
 *                                                                         *
 ***************************************************************************/

BOOL FAR CheckIfSource (LPSTR file)
{
    int i=0;
    char name[MAXPATHLENGTH],drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];

    strcpy((LPSTR)name,file);
    _splitpath(name,drv,dir,nam,ext);
    strcpy(nam,"*");
    strcat(nam,ext);
    DownStr((LPSTR)nam);

    while (i<srcN) {
  /* is extension in list? */
  if (!stricmp((LPSTR)nam,(LPSTR)&((*(SrcExt+i)).ext)))
      return TRUE;
  i++;
    }
    /* extension not found */
    return FALSE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : MessageOut (LPSTR)                                        *
 *                                                                         *
 *  PURPOSE    : Pass a string to the message-window.                      *
 *                                                                         *
 ***************************************************************************/

void FAR PASCAL _export MessageOut (LPSTR txt)
{
    char buf[256];
    lstrcpy((LPSTR)buf,txt);
    lstrcat((LPSTR)buf,"\r\n");
    if (msgWnd) {
  EditAddText(msgWnd,buf);
  if (messages<MAXERR)
     errMsg[messages++]=actErr;
    }    
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ErrorOut (LPSTR)                                          *
 *                                                                         *
 *  PURPOSE    : Append an error to the list and pass to message window.   *
 *                                                                         *
 ***************************************************************************/

void FAR PASCAL _export ErrorOut (int num,int line,int col,BOOL warn,LPSTR txt)
{
    FARPROC msg;
    char st[256],val[10];
        
    if (messages>=MAXERR)
       return;

    if (messages==MAXERR-1) {
       num=-1;
       line=-1;
       col=-1;
       warn=FALSE;
       strcpy(txt,"Too many errors/warnings.");
    }
       
    lstrcpy((LPSTR)st,(LPSTR)actComp);
    lstrcat((LPSTR)st,"(");
    
    /* append line number */
    if (line!=-1) {
       MakeStr(line,(LPSTR)val);
       lstrcat((LPSTR)st,(LPSTR)val);
    }
          
    /* append column number */
    if (col!=-1) {   
       MakeStr(col,(LPSTR)val);
       lstrcat((LPSTR)st,":");
       lstrcat((LPSTR)st,(LPSTR)val);
    }
    
    lstrcat((LPSTR)st,"): ");
    if (warn) {
  wrnCnt++;
  lstrcat((LPSTR)st,WARNINGTEXT);
    }
    else {
  errCnt++;
  lstrcat((LPSTR)st,ERRORTEXT);
    }                         
    
    /* append error number */
    if (num!=-1) {
  lstrcat((LPSTR)st," ");
  MakeStr(num,(LPSTR)val);
  lstrcat((LPSTR)st,(LPSTR)val);
    }
    
    /* append error text */
    if (*txt) {
  lstrcat((LPSTR)st,": ");
  lstrcat((LPSTR)st,txt);
    }

    /* write error message to error window */
    actErr=errCnt+wrnCnt;
    msg=MakeProcInstance((FARPROC)MessageOut,hInst);
    (*(MsgOutProc*)msg)((LPSTR)st);
    FreeProcInstance(msg);
    actErr=0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : AllFilesThere ()                                          *
 *                                                                         *
 *  PURPOSE    : Look if all project files are alive.                      *
 *                                                                         *
 ***************************************************************************/
                   
int FAR AllFilesThere (void)
{         
    int i;
    PrjFile file;
    struct stat stamp;

    for (i=0;i<depNr;i++) {
  GetElem(actProject.files,i+1,(long)(LPPrjFile)&file);
  if (stat(file.name,&stamp)!=EZERO && errno==ENOENT) {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOPROJECTFILE,(LPSTR)&(file.name));
      return 0;
  }                                    
    }    
    return 1;    
}                                                                   

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ModuleNr (LPSTR)                                          *
 *                                                                         *
 *  PURPOSE    : Get the number of the requested module.                   *
 *                                                                         *
 ***************************************************************************/

int ModuleNr (LPSTR module)
{
    int i;
    LPSTR s=depend;
    for (i=1;i<=depNr;i++) {
  if ((strlen(module)==strlen(s)) && (stricmp(module,s)==0))
      return i;
  s+=depLen;
    }
    return 0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : Dependency ()                                             *
 *                                                                         *
 *  PURPOSE    : Callback for CheckDepend(). Signals dependant modules.    *
 *                                                                         *
 ***************************************************************************/

void FAR PASCAL _export Dependency (LPSTR module)
{
    int m;
    char buf[MAXPATHLENGTH];

    lstrcpy((LPSTR)buf,module);
    #ifndef _WIN32
       DownStr(buf);
       buf[8]=0; // ignore names longer than 8 characters!!!
    #endif
    if (m=ModuleNr(buf))
  *(toCheck+m-1)=1;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetDependencies ()                                        *
 *                                                                         *
 *  PURPOSE    : If list element is of source type, get its dependencies.  *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export GetDependencies (LPLIST l)
{
    HWND hwnd;
    LPPrjFile file;
    FARPROC dep;
    FARPROC defOpen,defRead,defClose;

    file=(LPPrjFile)GlobalLock(l->elem);

    if (CheckIfSource((LPSTR)&(file->name))) 
    {
      dep=MakeProcInstance((FARPROC)Dependency,hInst);
      toCheck=depend+depOfs+depLen*modNr;
      memset(toCheck,0,depNr);
      if (hwnd=AlreadyOpen((LPSTR)&(file->name)))
        (*compCheckDep)(hCompData,(LPSTR)(file->name),dep,hwnd,getFirstBufferProc,getNextBufferProc,0,0,0,actProject.files);
      else 
      {
        if (EditGeneratesAscii()) 
        {
          defOpen=MakeProcInstance((FARPROC)DefOpenFile,hInst);
          defRead=MakeProcInstance((FARPROC)DefReadFile,hInst);
          defClose=MakeProcInstance((FARPROC)DefCloseFile,hInst);
          (*compCheckDep)(hCompData,(LPSTR)(file->name),dep,0,0,0,defOpen,defRead,defClose,actProject.files);
          FreeProcInstance(defOpen);
          FreeProcInstance(defRead);
          FreeProcInstance(defClose);
        }
        else
          (*compCheckDep)(hCompData,(LPSTR)(file->name),dep,0,0,0,editLoadOpenProc,editLoadReadProc,editLoadCloseProc,actProject.files);
      }
      FreeProcInstance(dep);
    }
    modNr++;
    GlobalUnlock(l->elem);
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : AddDepending (int)                                        *
 *                                                                         *
 *  PURPOSE    : Touches all modules depending from given module           *
 *                                                                         *
 ***************************************************************************/

BOOL FAR Depending (LPSTR dep,int module,int client)
{                                              
    return *((dep+depOfs+module)+client*depLen); 
}

void FAR AddDepending (int i)
{
    int j;
    PrjFile fil;
    FARPROC getDep;

    if (!AllFilesThere()) return;

    /* lock dependency matrix */
    depend=GlobalLock(hDep);

    /* get direct dependencies */
    modNr=0;
    getDep=MakeProcInstance(GetDependencies,hInst);
    ListForEach(actProject.files,getDep);
    FreeProcInstance(getDep);

    /* add modules, which are to change, too */
    for (j=0;j<depNr;j++)
  if (i!=j && Depending(depend,i,j)) {
      GetElem(actProject.files,j+1,(long)(LPPrjFile)&fil);
      fil.timeStamp=0;
      ChgElem(actProject.files,j+1,(long)(LPPrjFile)&fil,sizeof(fil));
  }    

    /* write new project information */
    if (*actPrj)
  WriteProject(actPrj);
    else
  WriteProject(defPrj);

    /* unlock matrix */
    GlobalUnlock(hDep);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CompileSingle (LPSTR)                                     *
 *                                                                         *
 *  PURPOSE    : Compiles a single file.                                   *
 *               Returns TRUE if interface has changed (dependent modules  *
 *               should be compiled, too), else FALSE.                     *
 *                                                                         *
 ***************************************************************************/

BOOL CompileSingle (LPSTR name)
{
    BOOL ret;
    HWND hwnd;
    HCURSOR oldC;
    FARPROC lpMsg;
    FARPROC lpErr;
//    FARPROC lpComp;
    FARPROC defOpen,defRead,defClose;

    oldC=SetCursor(hHourGlass);
    lstrcpy((LPSTR)actComp,name);
    lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
    lpErr=MakeProcInstance((FARPROC)ErrorOut,hInst);
//    lpComp=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_COMPILE));
    if (hwnd=AlreadyOpen(name))
      ret=(*compCompile)(hCompData,name,lpMsg,lpErr,hwnd,getFirstBufferProc,getNextBufferProc,0,0,0,actProject.files);
    else 
    {
      if (EditGeneratesAscii()) 
      {
        defOpen=MakeProcInstance((FARPROC)DefOpenFile,hInst);
        defRead=MakeProcInstance((FARPROC)DefReadFile,hInst);
        defClose=MakeProcInstance((FARPROC)DefCloseFile,hInst);
        ret=(*compCompile)(hCompData,name,lpMsg,lpErr,0,0,0,defOpen,defRead,defClose,actProject.files);
        FreeProcInstance(defOpen);
        FreeProcInstance(defRead);
        FreeProcInstance(defClose);
      }
      else
        ret=(*compCompile)(hCompData,name,lpMsg,lpErr,0,0,0,editLoadOpenProc,editLoadReadProc,editLoadCloseProc,actProject.files);
    }

    FreeProcInstance(lpMsg);
    FreeProcInstance(lpErr);
    SetCursor(oldC);
    return ret;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CompileFile (HWND)                                        *
 *                                                                         *
 *  PURPOSE    : Compiles a file and shows errors in a window.             *
 *                                                                         *
 ***************************************************************************/

void FAR CompileFile (HWND hwnd)
{

  if (!EditorIsOpen()) {
    Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
    return;
  }

  if (IsCompilerInterfaceLoaded()) {

    FARPROC lpMsg;
    char name[MAXPATHLENGTH];

    GetWindowText(hwnd,(LPSTR)name,sizeof(name));

    if (CheckIfSource(name)) {

      if (!*actPrj)                /* inform compiler of default */
        SetDefaultProjectName();   /* project name, if necessary */

      InitMessageWindow(hwndMDIClient);

      if (EditHasChanged(hwnd)) 
        if (SaveFile(hwnd))
          NewModified(FALSE);

      NewMessage("Compiling...",FALSE);

      #ifndef _WIN32
        DownStr(name);
      #endif          
      
      CompileSingle((LPSTR)name);
//2.0!!!    if (CompileSingle((LPSTR)name)) {
//                int n;
    /* interface has changed, dependent modules have to be compiled, too! */
//                if (*actPrj && errCnt==0 && (n=FileAlreadyIn((LPSTR)name)))
//                    AddDepending(n-1);
//            }    

      lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
      (*(MsgOutProc *)lpMsg)((LPSTR)"Done.");
      FreeProcInstance(lpMsg);

      /* show first error (if there is one) */
      if (errCnt+wrnCnt>0)
        ShowError(1);      
    
      if (errCnt==0) {  
        int i;
        // update the information in project, if file is declared in project
        if (i=FileAlreadyIn((LPSTR)name)) {
          PrjFile file;
          struct stat fdate;
          GetElem(actProject.files,i,(long)(LPPrjFile)&file);
          if (stat(file.name,&fdate)!=ENOENT)
            file.timeStamp=fdate.st_mtime;
          ChgElem(actProject.files,i,(long)(LPPrjFile)&file,sizeof(file));
          actProject.changed=TRUE;
          //2.0
          if (*actPrj)
            WriteProject(actPrj);
          else
            WriteProject(defPrj);
        }    
        NewMessage("Compilation successful.",FALSE);
      }
    }
    else
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTCOMPILE,(LPSTR)name);
  }
  else
    Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : LinkProject ()                                            *
 *                                                                         *
 *  PURPOSE    : Links the whole project.                                  *
 *                                                                         *
 ***************************************************************************/

int FAR LinkProject (BOOL init)
{  
  int ret;
  FARPROC lpMsg;
//  FARPROC lpLink;
                
  if (!EditorIsOpen()) 
  {
    Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
    return FALSE;
  }

    /*2.0*/
  if (IsCompilerInterfaceLoaded()) 
  {

    if (init)
      InitMessageWindow(hwndMDIClient);

    lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
//    lpLink=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_LINK));
    ret=(*compLink)(hCompData,(LPSTR)actPrj,actProject.files,lpMsg);
    FreeProcInstance(lpMsg);
    return ret;
  }       
  return 0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : RemoveDependMatrix ()                                     *
 *                                                                         *
 *  PURPOSE    : Removes dependency matrix from memory.                    *
 *                                                                         *
 ***************************************************************************/

void FAR RemoveDependMatrix ()
{
    if (hDep) {
  GlobalFree(hDep);
  hDep=0;
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : MakeDependMatrix ()                                       *
 *                                                                         *
 *  PURPOSE    : Build matrix for module-dependencies from project data.   *
 *                                                                         *
 ***************************************************************************/

void FAR MakeDependMatrix ()
{
    LPSTR p;

    /* free old matrix */
    RemoveDependMatrix();

    /* number of files in project */
    depNr=CountList(actProject.files);

    /* offset from filename to dependencies */
    depOfs=sizeof(MODNAM)+sizeof(MODEXT);

    /* length of matrix line */
    depLen=depOfs+depNr;

    /* set up new matrix */
    if (hDep=GlobalAlloc(GMEM_MOVEABLE,depNr*depLen)) {
  int i;
  MODNAM nam;
  MODEXT ext;
  PrjFile module;
  LPDepMatLine depMat;
  char drv[MAXPATHLENGTH],dir[MAXPATHLENGTH];

  p=GlobalLock(hDep);
  memset(p,0,depNr*depLen);

  for (i=1;i<=depNr;i++) {
      GetElem(actProject.files,i,(long)(LPPrjFile)&module);
      _splitpath(module.name,drv,dir,nam,ext);
      depMat=(LPDepMatLine)p;

      if (CheckIfSource((LPSTR)&(module.name)))
         lstrcpy((LPSTR)&(depMat->name),(LPSTR)nam);
      else
         *(depMat->name)=0;

      lstrcpy((LPSTR)&(depMat->ext),"*");
      lstrcat((LPSTR)&(depMat->ext),(LPSTR)ext);

      #ifndef _WIN32
         DownStr((LPSTR)&(depMat->name));
         DownStr((LPSTR)&(depMat->ext));
      #endif

      p+=depLen;
  }
  GlobalUnlock(hDep);
    }
    else
  Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTALLOCDEP);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveProjectEdits (ask)                                    *
 *                                                                         *
 *  PURPOSE    : Save modified edit files that correspond to the project.  *
 *               (if ask is true, ALL edit files are asked if to close)    *
 *                                                                         *
 ***************************************************************************/

void FAR SaveProjectEdits(HWND hWndActive, BOOL ask) {

  HWND hwnd;
  char title[MAXPATHLENGTH];

  for (hwnd = GetWindow(hwndMDIClient,GW_CHILD); hwnd; hwnd = GetWindow(hwnd,GW_HWNDNEXT)) {

    GetWindowText(hwnd, (LPSTR)title, sizeof(title));
#ifndef _WIN32
    DownStr((LPSTR)title);
#endif
    if ((ask || FileAlreadyIn((LPSTR)title)) && IsEditWindow(hwnd) && EditHasChanged(hwnd)) {
      if (!ask || Message(hwndFrame,MB_YESNO | MB_ICONQUESTION, IDS_CLOSESAVE, (LPSTR)title) == IDYES) {
        if (GetWindowWord(hwnd, GWW_UNTITLED))
          ChangeFile(hwnd);
        else
          SaveFile(hwnd);
        if (hwnd == hWndActive) NewModified(FALSE);
      }
		}
  }
}                    


/***************************************************************************
 *                                                                         *
 *  Functions for collecting project files for default project.            *
 *                                                                         *
 ***************************************************************************/


typedef struct {
   char modName[10];
   char filName[100];
} Module;
typedef Module far *LPModule;

void FAR AddModule (LPSTR);

BOOL FAR InList (LPSTR module)
{
   int i,n;
   Module mod;
   PrjFile fil;
   char buf[_MAX_PATH],drv[_MAX_DRIVE],path[_MAX_PATH],fname[_MAX_FNAME],ext[_MAX_EXT];
    
   _splitpath(module,drv,path,buf,ext);
   #ifndef _WIN32
       buf[8]=0;
   #endif

   /* file has already been collected? */
   n=CountList(moduleList);
   for (i=1;i<=n;i++) {
      if (GetElem(moduleList,i,(long)(LPSTR)&mod)) {
         if ((lstrlen((LPSTR)(mod.modName))==lstrlen(buf)) && (stricmp((LPSTR)(mod.modName),buf)==0))
            return TRUE;
      }
   }

   /* file is part of the project's file list? */
   n=CountList(actProject.files);
   for (i=1;i<=n;i++) {
      if (GetElem(actProject.files,i,(long)(LPPrjFile)&fil)) {
         if (CheckIfSource(fil.name)) {
            _splitpath(fil.name,drv,path,fname,ext);
            if (strlen(fname)==strlen(buf) && stricmp((LPSTR)(fname),buf)==0)
               return TRUE;
         }
      }
   }

   return FALSE;
}

void FAR PASCAL _export ModuleDependency (LPSTR module)
{
   char file[MAXPATHLENGTH]; 
   if (!InList(module) && (*compSourceAvailable)(hCompData,module,(LPSTR)file))
       AddModule(file);
}

void FAR AddModule (LPSTR file)
{
    Module mod;
    PrjFile fil;
    char drv[_MAX_DRIVE],path[_MAX_PATH],module[_MAX_FNAME],ext[_MAX_EXT];
    
    _splitpath(file,drv,path,module,ext);
    strcpy(mod.modName,module);
    strcpy(mod.filName,file);
    #ifndef _WIN32
       DownStr(file);
    #endif
    AddElem((LPHANDLE)&(moduleList),(long)(LPModule)&mod,sizeof(Module));

    lstrcpy(fil.name,file);
    fil.timeStamp=0;
    AddElem((LPHANDLE)&(actProject.files),(long)(LPPrjFile)&fil,sizeof(PrjFile));
    collected++;
}

void FAR CollectModule (int i)
{
    /*2.0*/
    HWND hwnd;
    Module mod;

    if (!GetElem(moduleList,i,(long)(LPSTR)&mod)) return;
    
    if (hwnd=AlreadyOpen(mod.filName))
      (*compCheckDep)(hCompData,mod.filName,dependProc,hwnd,getFirstBufferProc,getNextBufferProc,0,0,0,0);
    else 
    {
      if (EditGeneratesAscii()) 
      {
        FARPROC defOpen=MakeProcInstance((FARPROC)DefOpenFile,hInst);
        FARPROC defRead=MakeProcInstance((FARPROC)DefReadFile,hInst);
        FARPROC defClose=MakeProcInstance((FARPROC)DefCloseFile,hInst);
        (*compCheckDep)(hCompData,mod.filName,dependProc,0,0,0,defOpen,defRead,defClose,0);
        FreeProcInstance(defOpen);
        FreeProcInstance(defRead);
        FreeProcInstance(defClose);
      }
      else
        (*compCheckDep)(hCompData,mod.filName,dependProc,0,0,0,editLoadOpenProc,editLoadReadProc,editLoadCloseProc,0);
    }
}

void FAR CollectFiles (HWND hWndActive)
{
    /*2.0*/
    FARPROC msg;
    int collectedModules;
    char mainFile[MAXPATHLENGTH],buf[MAXPATHLENGTH];
    
    oldFiles=0;
    if (!IsEditWindow(hWndActive)) return;                   
    
    SaveList();
    moduleList=0;

    SetDefaultProjectName();
    dependProc=MakeProcInstance((FARPROC)ModuleDependency,hInst);
//    mustBuildProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_MUSTBEBUILT));
//    srcAvailProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_SOURCEAVAILABLE));
//    getDependProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_CHECKDEPEND));
//    checkIfYoungerProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_CHECKIFYOUNGER));
    
    GetWindowText(hWndActive,(LPSTR)mainFile,sizeof(mainFile));

    msg=MakeProcInstance((FARPROC)MessageOut,hInst);
    strcpy(buf,"Main module: '");
    strcat(buf,mainFile);
    strcat(buf,"'.");
    (*(MsgOutProc *)msg)((LPSTR)buf);
    FreeProcInstance(msg);
        
    collectedModules=0;
    if (!InList(mainFile))
        AddModule((LPSTR)mainFile);
    while (collectedModules<CountList(moduleList)) {
        collectedModules++;
        CollectModule(collectedModules);
    }       
    
    MakeDependMatrix();
    PurgeList((LPHANDLE)&moduleList);
          
    /* memorize modules in combobox */                  
    ProjectToRibbon();
    
    FreeProcInstance(dependProc);
}
        
void FAR FreeCollectedFiles (void)
{
    /*2.0*/
    if (collected>0) {
  int i,oldi,oldn,found;
  PrjFile file,oldfile;
       
  if (!oldFiles) {
      // original default project was empty
      PurgeList((LPHANDLE)&actProject.files);
  }
  else {
    i=1;
    while (i<=CountList(actProject.files)) {
        GetElem(actProject.files,i,(long)(LPPrjFile)&file);
        found=FALSE;
        oldn=CountList(oldFiles);
        for (oldi=1;oldi<=oldn;oldi++) {
      GetElem(oldFiles,oldi,(long)(LPPrjFile)&oldfile);
      if ((lstrlen((LPSTR)(file.name))==lstrlen((LPSTR)(oldfile.name))) &&
          (stricmp((LPSTR)(file.name),(LPSTR)(oldfile.name))==0)) {
          found=TRUE;
          break;
      }
        }
        if (!found) {
      // this is a collected file -> remove from project file list
      DelElem((LPHANDLE)&(actProject.files),i);
        }
        else
      i++;
    }
    PurgeList((LPHANDLE)&oldFiles);   // remove backup list
    oldFiles=0;
      }
      collected=0;
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : MarkIfYoungerModuleChanged (LPINT)                        *
 *                                                                         *
 *  PURPOSE    : Mark modules to change, which depend on younger modules.  *
 *                                                                         *
 ***************************************************************************/

void MarkIfYoungerModuleChanged (LPINT todo)
{     
    int i,j;
    PrjFile module,client;
    
    for (i=0;i<depNr;i++)
      for (j=0;j<depNr;j++)
        if (i!=j && Depending(depend,i,j)) 
        {
          GetElem(actProject.files,i+1,(long)(LPPrjFile)&module);
          GetElem(actProject.files,j+1,(long)(LPPrjFile)&client);
          if ((*compCheckIfYounger)(hCompData,(LPSTR)(module.name),(LPSTR)(client.name)))
            todo[j]=1;
        }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : MayBeCompiled ()                                          *
 *                                                                         *
 *  PURPOSE    : Check, if a module may be compiled now                    *
 *               (return TRUE if the module may be compiled)               *
 *               (return FALSE if another module must be compiled before)  *
 *                                                                         *
 ***************************************************************************/

BOOL FAR MayBeCompiled (LPINT todo,LPSTR done,LPSTR dep,int client)
{             
    BOOL ret;
    int module;
    char localDone[MAXMOD];    
       
    ret=TRUE;
    if (done[client]) return FALSE;
    
    memcpy(localDone,done,sizeof(localDone));
    localDone[client]=TRUE;
    
    for (module=0;module<depNr;module++)
  if (client!=module && Depending(dep,module,client)) {
      if (todo[module] || !MayBeCompiled(todo,localDone,dep,module)) {
    ret=FALSE;
    break;
      }
  }
  
    return ret;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : MakeProject ()                                            *
 *                                                                         *
 *  PURPOSE    : Update project by compiling only affected files.          *
 *                                                                         *
 *  If checkIfMakeNecessary is true, dependencies are only checked and     *
 *  no files are compiled                                                  *
 ***************************************************************************/

BOOL FAR MakeProject(HWND hWndActive, LPINT uptodate,BOOL checkIfMakeNecessary)
{
    PrjFile fil;
    char targetName[MAXPATHLENGTH],done[MAXMOD];
    int i,client,status,exestat;
    FARPROC getDep;//lpMust,lpfn;
    int todo[MAXMOD];
    struct stat stamp,exestamp;
    BOOL new,changed;

    if (!IsCompilerInterfaceLoaded()) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
      return FALSE;
    }                  

    if (!EditorIsOpen()) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
      return FALSE;
    }

    oldFiles=0;     /*2.0*/    // save-list for old project file list (for default project)
    collected=0;               // number of collected file for default project
//    checkIfYoungerProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_CHECKIFYOUNGER));
    
    if (!*actPrj) 
    {
      /*2.0*/
      RemoveMessageWindow();
      if (!IsEditWindow(hWndActive)) 
      {
        Message(hwndFrame,MB_OK|MB_ICONINFORMATION,IDS_NOTHINGTOMAKE);
        return FALSE;
      }
      if (GetWindowWord(hWndActive,GWW_UNTITLED)) 
      {
        if (ChangeFile(hWndActive))
          SendMessage(hWndActive, WM_COMMAND, IDM_FILESAVE, 0L);
        else
          return FALSE;
      }
      CollectFiles(hWndActive);
    }
    else
      MakeDependMatrix();
    
    if (!AllFilesThere()) 
    {
      FreeCollectedFiles();
      return FALSE;
    }

    /* save open project files */
    SaveProjectEdits(hWndActive, FALSE);

    /* check if make necessary */
    (*compGetTarget)(hCompData,(LPSTR)targetName);
    exestat=stat(targetName,&exestamp);
          
    /* lock dependency matrix */
    depend=GlobalLock(hDep);

    /* get direct dependencies */
    modNr=0;
    getDep=MakeProcInstance(GetDependencies,hInst);
    ListForEach(actProject.files,getDep);
    FreeProcInstance(getDep);

    /* reset make flags */
    memset((LPSTR)todo,0,sizeof(todo));

    /* add changed modules */
    for (i=0;i<depNr;i++) 
    {
      GetElem(actProject.files,i+1,(long)(LPPrjFile)&fil);
      status=stat(fil.name,&stamp);
      
    /* make is also necessary, if a file is younger than an existing target file */    
      #ifdef _WIN32
          /* win32 -> check modification times */
          if (status==EZERO && exestat==EZERO && exestamp.st_mtime<stamp.st_mtime)
            actProject.changed=1;
      #else
          if (status==EZERO && exestat==EZERO && exestamp.st_ctime<stamp.st_ctime)
            actProject.changed=1;
      #endif
      
    /* check, which files must be compiled */                
      if (CheckIfSource(fil.name)) 
      {
        if (fil.timeStamp==FILEMUSTBECOMPILED)
          todo[i]++;
        else
          if ((*compMustBeBuilt)(hCompData,(LPSTR)&(fil.name)))
            todo[i]++;
      }
      else 
      {
        if (status==EZERO && stamp.st_mtime!=fil.timeStamp)
        todo[i]++;
      }
    }    
    
    /* search for younger imported modules */
    MarkIfYoungerModuleChanged(todo);

    /* is there anything to compile or link? */
    changed=0;
    for (i=0;i<depNr;i++)
    {
      if (todo[i])
        changed=1;
    }

    if (checkIfMakeNecessary) 
    {
      GlobalUnlock(hDep);      
      FreeCollectedFiles();   
      *uptodate=!changed;
      return TRUE;
    }
   
    /* nothing -> don't start make */   
    if (!changed && !actProject.changed && exestat==EZERO) 
    {
      GlobalUnlock(hDep);      
      FreeCollectedFiles();   
      *uptodate=TRUE;
      return TRUE;
    }

    /* create window for message output */
    *uptodate=FALSE;
    InitMessageWindow(hwndMDIClient);
    NewMessage("Making project...",FALSE);

    /* make project */
    do 
    {
      changed=FALSE;
      for (i=0;i<depNr;i++) 
      {
        memset((LPSTR)done,0,sizeof(done));
        if (todo[i] && MayBeCompiled(todo,done,depend,i)) 
        {
          PrjFile file;
          GetElem(actProject.files,i+1,(long)(LPPrjFile)&file);
          if (CheckIfSource(file.name)) 
          {
            new=CompileSingle((LPSTR)file.name);
            if (errCnt) 
            {
              FreeCollectedFiles();
              if (*actPrj)
                WriteProject(actPrj);
              else 
                WriteProject(defPrj);
              GlobalUnlock(hDep);
              ShowError(1);
              FreeCollectedFiles();
              return FALSE;
            }
          }
          else
            new=FALSE;
          if (stat(file.name,&stamp)==EZERO)
            file.timeStamp=stamp.st_mtime;
          ChgElem(actProject.files,i+1,(long)(LPPrjFile)&file,sizeof(file));
          if (new) 
          {
            // new symbol files -> compile dependent modules
            for (client=0;client<depNr;client++)
            if (i!=client && Depending(depend,i,client))
              todo[client]=1;
          }
          todo[i]=0;
          changed=TRUE;
        }
      }
      if (!changed)
      {
        for (i=0;i<depNr;i++)
        {
          if (todo[i]) 
          {
            FARPROC lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
            (*(MsgOutProc *)lpMsg)((LPSTR)"Circular dependency detected. Make aborted!");
            FreeProcInstance(lpMsg);
            NewMessage("Make aborted.",TRUE);
            FreeCollectedFiles();
            if (*actPrj)
              WriteProject(actPrj);
            else
              WriteProject(defPrj);
            GlobalUnlock(hDep);
            FreeCollectedFiles();
            return FALSE;
          }
        }
      }
    } while (changed);

    /* link, keep messages */
    if (!changed) 
    {
      int ok;   
      OFSTRUCT of;
      FARPROC lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
  
      (*(MsgOutProc *)lpMsg)((LPSTR)"Link in progress.");
      ok=LinkProject(FALSE);
      if (!ok)
        OpenFile((LPSTR)targetName,(OFSTRUCT far *)&of,OF_DELETE);
      (*(MsgOutProc *)lpMsg)((LPSTR)"Done.");
      FreeProcInstance(lpMsg);
      NewMessage("",FALSE);
      /* unlock matrix */
      GlobalUnlock(hDep);
      /* reset changed flag, if link was successful */
      actProject.changed=!ok;
      FreeCollectedFiles();
      return ok;
    }
      
    FreeCollectedFiles();

    if (*actPrj)
      WriteProject(actPrj);
    else
      WriteProject(defPrj);  /*2.0*/

    /* unlock matrix */
    GlobalUnlock(hDep);      
    return FALSE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : BuildProject ()                                           *
 *                                                                         *
 *  PURPOSE    : Update project by compiling all files.                    *
 *                                                                         *
 ***************************************************************************/

void FAR BuildProject (HWND hWndActive)
{
    int i,j;
    LPSTR dep;
    char targetName[MAXPATHLENGTH];
    struct stat fdate;
    FARPROC getDep;
    BOOL changed,finished,done[MAXMOD];

    if (!IsCompilerInterfaceLoaded()) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
      return;
    }

    if (!EditorIsOpen()) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
      return;
    }

    oldFiles=0;     /*2.0*/    // save-list for old project file list (for default project)
    collected=0;               // number of collected file for default project
//    checkIfYoungerProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_CHECKIFYOUNGER));
    
    if (!*actPrj) 
    {
      /*2.0*/
      RemoveMessageWindow();
      if (!IsEditWindow(hWndActive)) 
      {
        Message(hwndFrame,MB_OK|MB_ICONINFORMATION,IDS_NOTHINGTOMAKE);
        return;
      }
      CollectFiles(hWndActive);
    }                       
    
    if (!AllFilesThere()) 
    {
      FreeCollectedFiles();
      return;
    }

    /* get exe file name */
//    lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_GETEXECUTABLE));
    (*compGetTarget)(hCompData,(LPSTR)targetName);

    /* save open project files */
    SaveProjectEdits(hWndActive, FALSE);

    /* create window for message output */
    InitMessageWindow(hwndMDIClient);

    NewMessage("Building project...",FALSE);

    /* lock dependency matrix */
    depend=GlobalLock(hDep);

    /* get direct dependencies */
    modNr=0;
    getDep=MakeProcInstance(GetDependencies,hInst);
    ListForEach(actProject.files,getDep);
    FreeProcInstance(getDep);

    /* calculate indirect dependencies and build project */
    for (i=0;i<depNr;i++)
      done[i]=FALSE;

    do 
    {
      changed=FALSE;
      finished=TRUE;
      for (i=0;i<depNr;i++)
        if (!done[i]) 
        {
          finished=FALSE;
          done[i]=TRUE;
          dep=depend+i*depLen;
          dep+=depOfs;
          for (j=0;j<depNr;j++)
            if ((*dep++) && (i!=j) && !done[j])
              done[i]=FALSE;
           /* can project file be compiled now? */
          if (done[i]) 
          {
            PrjFile file;
            GetElem(actProject.files,i+1,(long)(LPPrjFile)&file);
            /* compile file */
            if (CheckIfSource(file.name))
              CompileSingle((LPSTR)&(file.name));
            /*NEU!!!*/
            if (!errCnt) 
            {
              /* remember timestamp */
              if (stat(file.name,&fdate)!=ENOENT)
                file.timeStamp=fdate.st_mtime;
              ChgElem(actProject.files,i+1,(long)(LPPrjFile)&file,sizeof(file));
              changed=TRUE;
            }
          }
          /* errors occured? -> show first error and exit build */
          if (errCnt) 
          {
            ShowError(1);
            FreeCollectedFiles();
            goto error;
          }
        }
        /* circular dependencies? */
        if ((!changed) && (!finished)) 
        {
          FARPROC lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);
          (*(MsgOutProc *)lpMsg)((LPSTR)"Circular dependency detected. Build aborted!");
          FreeProcInstance(lpMsg);
          NewMessage("Build aborted.",TRUE);
          finished=TRUE;
          changed=TRUE;
        } 
    } while (!finished);

    /* link, keep messages */
    if (!changed) 
    {
      int ok;           
      OFSTRUCT of;
      FARPROC lpMsg=MakeProcInstance((FARPROC)MessageOut,hInst);

      (*(MsgOutProc *)lpMsg)((LPSTR)"Link in progress.");
      ok=LinkProject(FALSE);
      if (!ok)
        OpenFile((LPSTR)targetName,(OFSTRUCT far *)&of,OF_DELETE);
      (*(MsgOutProc *)lpMsg)((LPSTR)"Done.");
      FreeProcInstance(lpMsg);
      NewMessage("",FALSE);
      /* reset changed flag */
      actProject.changed=FALSE;
    }

    FreeCollectedFiles();

    if (*actPrj)
      WriteProject(actPrj);
    else
      WriteProject(defPrj);  /*2.0*/

error:
    /* unlock matrix */
    GlobalUnlock(hDep);
    return;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : LinkOnlyProject ()                                        *
 *                                                                         *
 *  PURPOSE    : Link project without prior compilation                    *
 *                                                                         *
 ***************************************************************************/

void FAR LinkOnlyProject (HWND hWndActive)
{
    OFSTRUCT of;
    FARPROC lpfn;
    int ok,uptodate;
    char targetName[MAXPATHLENGTH];

    if (!IsCompilerInterfaceLoaded()) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
      return;
    }

    if (!*actPrj) 
    {
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOPROJECT);
      return;
    }                       
    
    if (!AllFilesThere())
      return;

    /* check if make would be necessary */                        
    if (MakeProject(hWndActive, &uptodate,TRUE))
  if (!uptodate && Message(hwndFrame,MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2,IDS_LINKANYWAY)!=IDYES)
      return;
      
    /* get exe file name */
//    lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_GETEXECUTABLE));
    (*compGetTarget)(hCompData,(LPSTR)targetName);

    /* create window for message output */
    InitMessageWindow(hwndMDIClient);

    /* link, keep messages */
    NewMessage("Linking project...",FALSE);
    ok=LinkProject(FALSE);
    if (!ok)
      OpenFile((LPSTR)targetName,(OFSTRUCT far *)&of,OF_DELETE);
    lpfn=MakeProcInstance((FARPROC)MessageOut,hInst);
    (*(MsgOutProc *)lpfn)((LPSTR)"Done.");
    NewMessage("",FALSE);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GotoError (HWND)                                          *
 *                                                                         *
 *  PURPOSE    : User has double-clicked left mouse button in error window *
 *               (the cursor is put to the according file and position)    *
 *                                                                         *
 ***************************************************************************/

void FAR GotoError (HWND hwnd)
{
    long row,col;
    
    EditGetCursorpos(hwnd,(LPLONG)&row,(LPLONG)&col);
    if (row>0 && row<MAXERR) 
    {
      actErr=errMsg[row-1];
      ShowError(0);
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : CompilerHelp (WORD,DWORD)                                 *
 *                                                                         *
 *  PURPOSE    : Asks the compiler-interface dll for help on given topic.  *
 *                                                                         *
 ***************************************************************************/

void FAR CompilerHelp (WORD wCmd,DWORD dwData)
{
//  FARPROC help=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_HELPCOMPILER));
  if (!(*compHelp)(hCompData,hwndFrame,(LPSTR)defaultDir,wCmd,dwData))
    Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPHELP);
} 
