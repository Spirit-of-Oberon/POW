/***************************************************************************
 *                                                                         *
 *  MODULE    : PowProj.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for the Project handling of Pow!         *
 *                                                                         *
 *  FUNCTIONS : WriteProject () - save project on disk                     *
 *                                                                         *
 *              ReadProject () - read project from disk                    *
 *                                                                         *
 *              PurgeProject () - purge project from memory                *
 *                                                                         *
 *              InitProject () - initialize a project                      *
 *                                                                         *
 *              WriteTemplate () - write project as template definition    *
 *                                                                         *
 *              OpenTemplate () - Select name of template and of project   *
 *                                                                         *
 ***************************************************************************/

#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include <direct.h>
#include <commdlg.h>
#include <dlgs.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powcomp.h"
#include "powproj.h"
#include "powribb.h"
#include "powopts.h"
#include "powrun.h"
#include "powhelp.h"
#include "powed.h"
#include "powtemp.h"
#include "powCompiler.h"

/* signature of actual project files */
#define PROJECTVERSION20 "Prj20"  // changes every time the file-format changes!
#define PROJECTVERSION21 "Prj21"  // changes every time the file-format changes!
#define PROJECTVERSION10 "Prj10"  // changes every time the file-format changes!

/* global variables */
PrjDecl actProject;

char tplPath[70];
char tplProj[70];
char tplSubdir[20];
BOOL tplSourcedir;

/*
typedef BOOL FAR PASCAL RWProc (HANDLE,LPSTR,HFILE);
typedef void FAR PASCAL NewProjectProc (HANDLE,LPSTR);
typedef void FAR PASCAL NewProjectNameProc (HANDLE,LPSTR);
typedef void FAR PASCAL ChangeModuleNameProc (HANDLE,HWND,FARPROC,LPSTR,LPSTR);
*/
/************************************************************************
 *                                                                      *
 *  FUNCTION: PurgeProject (LPPrjDecl)                                  *
 *                                                                      *
 *  PURPOSE:  Purge project definition from memory                      *
 *                                                                      *
 ************************************************************************/

VOID FAR PurgeProject (LPPrjDecl prj)
{
    PurgeList((LPHANDLE)&(prj->files));
    RemoveDependMatrix();
}

/************************************************************************
 *                                                                      *
 *  FUNCTION: InitProject (LPPrjDecl)                                   *
 *                                                                      *
 *  PURPOSE:  Initialize project definition                             *
 *                                                                      *
 ************************************************************************/

VOID FAR InitProject (LPPrjDecl prj)
{
    prj->files=0;
}
 
/************************************************************************
 *                                                                      *
 *  FUNCTION: WriteProject (LPSTR)                                      *
 *                                                                      *
 *  PURPOSE:  The active Project definitions are stored on disk         *
 *                                                                      *
 ************************************************************************/

BOOL FAR PASCAL _export WriteProjectFile (LPLIST l)
{
    PrjFile fil;

    if (l->elem!=0) {
        fil=*(LPPrjFile)GlobalLock(l->elem);
        ShrinkDir((LPSTR)&(fil.name),(LPSTR)defaultDir,(LPSTR)actPrj);
        FileOut((LPSTR)&(fil.name),sizeof(fil.name));
        FileOut((LPSTR)&(fil.timeStamp),sizeof(fil.timeStamp));
        GlobalUnlock(l->elem);
    }                     
    return TRUE;
}

BOOL FAR WriteProject (LPSTR name)
{
  FARPROC write;
  char dummy[12];
  short elems;
  BOOL dllSaved;

  if (!*name)
     return TRUE;
                           
  if (OpenOut(name)) 
  {
    /* write project file signature */
    lstrcpy(dummy,PROJECTVERSION21);
    WriteBytes((LPSTR)dummy,6);

    /* write changed flag */
    WriteBytes((LPSTR)&actProject.changed,2);
                               
    /* write 12 bytes (reserved for future use) */                  
    memset(dummy,0,sizeof(dummy));
    WriteBytes((LPSTR)dummy,12);
                          
   /* write name of compiler-dll */
    WriteStr((LPSTR)actConfig.compiler);
        
    /* save run-argument string */
    WriteStr((LPSTR)RunArgs);

    /* save size/state of open windows */
    WriteSizeOpenWindows();
                               
    /* write project files */
    elems=CountList(actProject.files);
    FileOut((LPSTR)&elems,2);
    write=MakeProcInstance(WriteProjectFile,hInst);
    ListForEach(actProject.files,write);
    FreeProcInstance(write);

    /* force compiler-dll to save data */
//    FileOut((LPSTR)&actDLL,sizeof(actDLL));  !!!!!!
    dllSaved=IsCompilerInterfaceLoaded();
    FileOut((LPSTR)&dllSaved,sizeof(dllSaved));
    if (dllSaved) 
    {
//       write=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_WRITEOPTIONS));
      if (*actPrj)
        (*compWriteOpt)(hCompData,(LPSTR)actPrj,GetOutFile());
      else
        (*compWriteOpt)(hCompData,(LPSTR)defPrj,GetOutFile()); /*2.0*/
    }  

    /* set up new dependency matrix */
    if (*actPrj) /*2.0*/
      MakeDependMatrix();
    return CloseOut();
  }
  return FALSE;
}


/************************************************************************
 *                                                                      *
 *  FUNCTION: ReadProject (LPSTR)                                       *
 *                                                                      *
 *  PURPOSE:  Read project definitions from disk                        *
 *                                                                      *
 ************************************************************************/

BOOL ReadPrj (LPSTR name)
{           
    PrjFile fil;
//    FARPROC read;
    BOOL dllSaved;
    BOOL version10;
    BOOL version20;
    BOOL version21;
    int i;                                                   
    short elems;
    char dummy[12];
    char buf[MAXPATHLENGTH],
         prj[MAXPATHLENGTH],
         drv[4],
         dir[MAXPATHLENGTH],
         nam[MAXPATHLENGTH],
         ext[MAXPATHLENGTH],
         oldcomp[MAXPATHLENGTH];
        
    if (!*name)
        return TRUE;    
        
    if (OpenIn(name)) {
                         
        /* try to close all child windows */                 
        CloseAllChildren();
        ShowWindow(hwndMDIClient,SW_SHOW);
                         
        strcpy((LPSTR)buf,name);
        _splitpath(buf,drv,dir,nam,ext);
        strcpy(prj,drv);
        strcat(prj,dir);
        
       #ifndef _WIN32
    	  AnsiLower((LPSTR)prj);
       #else
		    CharLower((LPSTR)prj);
       #endif
		
               
        /* check if this is a valid project file */
        ReadBytes((LPSTR)dummy,6);
        version10=!lstrcmp((LPSTR)dummy,PROJECTVERSION10);
        version20=!lstrcmp((LPSTR)dummy,PROJECTVERSION20);
        version21=!lstrcmp((LPSTR)dummy,PROJECTVERSION21);
        if (version10 || version20 || version21) 
        {
         
            /* read changed flag */
            ReadBytes((LPSTR)&actProject.changed,2);             
                         
            /* read 12 bytes (reserved for future use) */                  
            ReadBytes((LPSTR)dummy,12);
                          
            /* load name of compiler-dll */                                          
            strcpy(oldcomp,actConfig.compiler);
            ReadStr((LPSTR)actConfig.compiler);
            if (stricmp(oldcomp,actConfig.compiler))
                UseNewCompiler();
        
            /* remember project file */
            lstrcpy((LPSTR)actPrj,name);

            /* load run-argument string */
            ReadStr((LPSTR)RunArgs);

            /* load size/state of open windows */
            ReadSizeOpenWindows();
       
            /* set new work directory */
            if (prj[strlen(prj)-1]=='\\')
                prj[strlen(prj)-1]=0;
            strcpy(actPath,prj);                
            
            /* read project files */
            FileIn((LPSTR)&elems,2);
            for (i=0; i<elems; i++) 
            {
                if (version21)
                  FileIn(&(fil.name),sizeof(fil.name));
                else
                  FileIn(&(fil.name),80);
                FileIn((LPSTR)&(fil.timeStamp),sizeof(fil.timeStamp));

                StretchDir((LPSTR)&(fil.name),(LPSTR)defaultDir,(LPSTR)actPrj);
                AddElem((LPHANDLE)&(actProject.files),(long)(LPSTR)&fil,sizeof(PrjFile));
            }

            /* let the compiler-dll read data */
            FileIn((LPSTR)&dllSaved,sizeof(dllSaved));
            if (dllSaved && IsCompilerInterfaceLoaded()) {
 //               read=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_READOPTIONS));
                (*compReadOpt)(hCompData,(LPSTR)actPrj,GetInFile());
            }                                             
            return CloseIn();
        }
        else {
            Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOVALIDPROJECT,name);    
            *actPrj=0;
            CloseIn();
            return FALSE;
        }    
    }
    return FALSE;
}

/* read project - main */
/* read default project if "isDefault" is TRUE */
BOOL FAR ReadProject (LPSTR name,BOOL isDefault)
{
    BOOL ret;

    PurgeProject(&actProject);
    InitProject(&actProject);
    ret=ReadPrj(name);

    /*2.0*/
    if (isDefault)
        *actPrj=0;
    else
        MakeDependMatrix();
        
    ProjectCaption();
    ProjectToRibbon();
    
    return ret;
}


/************************************************************************
 *                                                                      *
 *  FUNCTION: ProjectCaption ()                                         *
 *                                                                      *
 *  PURPOSE:  Make a new caption for main window (project name)         *
 *                                                                      *
 ************************************************************************/

void FAR ProjectCaption ()
{
    char buf[MAXPATHLENGTH],
		 drv[4],
		 dir[MAXPATHLENGTH],
		 nam[MAXPATHLENGTH],
		 ext[MAXPATHLENGTH];

    strcpy(buf,"Pow!");
    if (*actPrj) {
        strcat(buf," - ");
        _splitpath(actPrj,drv,dir,nam,ext);
        strcat(buf,nam);
        strcat(buf,ext);
    }
    SetWindowText(hwndFrame,(LPSTR)buf);
}

void FAR CopyMyFile (LPSTR dst,LPSTR src)
{
    long len;
    BOOL err;
    HANDLE hbuf;
    LPSTR lpbuf;
    int fdst,fsrc,siz;
                                              
    err=FALSE;                                          
    
    // open source file                  
    if ((fsrc=_lopen(src,OF_READ))==HFILE_ERROR) {
        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTREAD,src);
        err=TRUE;
    }         
      
    // create or rewrite destination file                            
    if ((fdst=_lcreat(dst,0))==HFILE_ERROR &&
        (fdst=_lopen(dst,OF_WRITE))==HFILE_ERROR) {
        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTWRITE,dst);
        err=TRUE;
    }          
                                         
    // copy file (buffered)                                     
    if (!err) {
        hbuf=GlobalAlloc(GMEM_MOVEABLE,10000);
        if (hbuf) {                        
            lpbuf=GlobalLock(hbuf);
            len=_llseek(fsrc,0,2);  
            _llseek(fsrc,0,0);
            while (len) {
                siz=_lread(fsrc,lpbuf,10000);
                if (siz) {
                    _lwrite(fdst,lpbuf,siz);
                    len-=siz;    
                }
                else break;    
            }
            GlobalUnlock(hbuf);    
            GlobalFree(hbuf);
            _lclose(fsrc);
            _lclose(fdst);
        }                 
    }    
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : NewProjectHookProc (hwnd,msg,wParam,lParam)              *
 *                                                                        *
 *  PURPOSE    : Project open dialog box.                                 *
 *               Select a directory and specify the name of a new project *
 *               (hooked common open dialog)                              *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export NewProjectHookProc (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
{
    switch (msg) {

    case WM_COMMAND:
        
#ifdef _WIN32
        switch (LOWORD(wParam)) {
#else
        switch (wParam) {
#endif

            case IDOK:

                GetDlgItemText(hdlg,edt1,tplProj,sizeof(tplProj));
                GetDlgItemText(hdlg,IDD_OPNPATH,tplPath,sizeof(tplPath));
                GetDlgItemText(hdlg,IDD_TPLSUBDIR,tplSubdir,sizeof(tplSubdir));

                /* cut project name and subdirectory name to max. 8 chars */
                #ifndef _WIN32
                   tplProj[8]=0;
                   tplSubdir[8]=0;
                #endif
                                    
                tplSourcedir=(BOOL)SendDlgItemMessage(hdlg,IDD_TPLSOURCEDIR,BM_GETCHECK,0,0);
                if (*tplPath && tplPath[strlen(tplPath)]=='\\') 
                    tplPath[strlen(tplPath)-1]=0;
                
                if (*tplProj) {
                    strcat(tplProj,".prj");
                }    
                return 0; /* let commdlg.dll end the dialog */

            case IDCANCEL:

                *tplProj=0;
                *tplSubdir=0;
                tplSourcedir=0;
                EndDialog(hdlg,wParam);
                return 1;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Arbeiten_mit_Templates);
                return 1;

            default:  
            
                break;
        }
        break;
        
    default:
    
        break;
    }
    return 0;
}

/************************************************************************
 *                                                                      *
 *  FUNCTION: CreateProjectFromTemplate (tpl,prj,dir,targetIsProject    *
 *                                                                      *
 *  PURPOSE:  Create a new project from template in given directory.    *
 *            The reverse is done, if targetIsProject is TRUE: then     *
 *            a template is created from a project.                     *
 *                                                                      *
 ************************************************************************/
             
void FAR CreateProjectFromTemplate (LPSTR tpl,LPSTR prj,LPSTR dstdir,int targetIsProject)
{        
    HWND hwnd;
    BOOL main;
    LPSTR lp;
    int i,n,err;
    PrjFile fil;                
  //  FARPROC lpfn;
    char project[_MAX_PATH],drv[_MAX_DRIVE],dir[_MAX_DIR],nam[_MAX_FNAME],
         ext[_MAX_EXT],oldnam[_MAX_FNAME],buf[_MAX_PATH],mainname[_MAX_FNAME],prjdir[_MAX_PATH];
                              
    if (!*tpl || !*prj || !*dstdir) return;                          
                              
    if (!FileExists((LPSTR)tpl))
       Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTOPEN,(LPSTR)tpl);
    else {                        
       #ifndef _WIN32
          AnsiLower(tpl);
          AnsiLower(prj);
          AnsiLower(dstdir);
       #endif
        
       /* create project directory */
       strcpy(buf,dstdir);
       if (*buf && buf[strlen(buf)-1]=='\\')
          buf[strlen(buf)-1]=0;
       err=_mkdir(buf);
       
       /* source template/project directory */
       strcpy(prjdir,tpl);
       lp=prjdir+strlen(prjdir);
       while (lp!=prjdir && *lp!='\\') lp--;
       *++lp=0;
       
       /* full name of new project */
       strcpy(project,dstdir);
       strcat(project,prj);
       
       if (targetIsProject) 
          strcat(project,".prj");
       else
          strcat(project,".tpl");
                
       /* module name of potential main module */
       _splitpath(tpl,drv,dir,mainname,ext);
       #ifndef _WIN32
          AnsiLower(mainname);
       #endif

       CloseProject(FALSE);
       showResized=FALSE;
       
       /* load project file */
       if (ReadProject(tpl,FALSE)) {
                              
          /* compare all module names with template name (look for main module) */
          n=CountList(actProject.files);
          for (i=1;i<=n;i++) {
             GetElem(actProject.files,i,(long)(LPSTR)&fil);
             if (CheckIfSource((LPSTR)fil.name)) {
                _splitpath(fil.name,drv,dir,nam,ext);

                /* rename main module */
                #ifndef _WIN32
                  AnsiLower(nam);
                #endif
                main=!stricmp(nam,mainname);
                 
                if (main) {
                   strcpy(oldnam,nam);
                   strcpy(nam,prj);  
                     
                   /* open window with main module! */
                   if (!AlreadyOpen(fil.name))
                       AddFile(fil.name);
                }    

                /* build new program name */
                strcpy(buf,dstdir);
                strcat(buf,nam);
                strcat(buf,ext);         
                                
                /* copy to new file */
                if ((!FileExists((LPSTR)buf)) || 
                    (Message(hwndFrame,MB_YESNO|MB_ICONQUESTION,IDS_OVERWRITEFILE,(LPSTR)buf)==IDYES))
                   CopyMyFile((LPSTR)buf,(LPSTR)fil.name);
                                
                /* new title for open window */
                if (hwnd=AlreadyOpen((LPSTR)fil.name)) {
                   char name[_MAX_PATH];
                    
                   strcpy(name,buf);

                   #ifndef _WIN32
                      AnsiLower(name);
                   #endif    
                                    
                   SetWindowText(hwnd,(LPSTR)name);     
                   if (main)
                      LoadFile(hwnd,(LPSTR)name);
                }             
                                                                     
                /* manipulate main program (module name is new project name) */
                if (main && IsCompilerInterfaceLoaded()) {
//                   lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_CHANGEMODULENAME));
                   //(*(ChangeModuleNameProc*)lpfn)(hCompData,(LPSTR)buf,(LPSTR)oldnam,(LPSTR)prjnam);
                   (*compChangeModuleName)(hCompData,hwnd,editReplaceProc,(LPSTR)oldnam,(LPSTR)prj);
                }    
                                
                /* change project information */
                strcpy(fil.name,buf);
                ChgElem(actProject.files,i,(long)(LPSTR)&fil,sizeof(PrjFile));
             }                      
             else if (!targetIsProject) {
                /* copy binary files, too, if target is a template */
                _splitpath(fil.name,drv,dir,nam,ext);

                strcpy(buf,drv);
                strcat(buf,dir);
                
                if (stricmp(buf,prjdir)==0) {
                   /* copy only files, that reside in the project directory */
                   strcpy(buf,dstdir);
                   strcat(buf,nam);
                   strcat(buf,ext);         
                                
                   /* copy to new file */
                   if ((!FileExists((LPSTR)buf)) || 
                       (Message(hwndFrame,MB_YESNO|MB_ICONQUESTION,IDS_OVERWRITEFILE,(LPSTR)buf)==IDYES))
                      CopyMyFile((LPSTR)buf,(LPSTR)fil.name);
                }       
             }
          }              
          
          showResized=TRUE;
          WriteProject((LPSTR)project);    
          
          if (targetIsProject) {
             lstrcpy((LPSTR)actPrj,(LPSTR)project);
             ProjectCaption();
             ProjectToRibbon();
             if (IsCompilerInterfaceLoaded()) {
//                lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_NEWPROJECTNAME));
                (*compNewProjectName)(hCompData,(LPSTR)actPrj);
             }

             AppendHistory(prjHistory,actPrj);  
          }
          else
             CloseProject(TRUE);
       }                
       showResized=TRUE;
    }        
}                                                            

/************************************************************************
 *                                                                      *
 *  FUNCTION: OpenTemplate ()                                           *
 *                                                                      *
 *  PURPOSE:  Select name of template and of project file               *
 *                                                                      *
 ************************************************************************/
             
void FAR OpenTemplate ()                                   
{
    char fNam[_MAX_FNAME]="*.tpl";
    
    GetFileName((LPSTR)fNam,"Select Template",FALSE,(LPEXT)&TplExt,1,hwndFrame);
    if (*fNam)
        NewProjectFromTemplate(fNam,TRUE);
}        

/************************************************************************
 *                                                                      *
 *  FUNCTION: SetDefaultProjectName ()                                  *
 *                                                                      *
 *  PURPOSE:  Inform compiler of the project name for default project   *
 *                                                                      *
 ************************************************************************/
             
void FAR SetDefaultProjectName (void)
{
//    FARPROC lpfn;
    char prog[MAXPATHLENGTH];

//    lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_NEWPROJECTNAME));
    GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)prog,sizeof(prog));
    (*compNewProjectName)(hCompData,(LPSTR)prog);            
}

/************************************************************************
 *                                                                      *
 *  FUNCTION: WriteTemplate ()                                          *
 *                                                                      *
 *  PURPOSE:  Write current project options as a template               *
 *                                                                      *
 ************************************************************************/

void FAR WriteTemplate ()                                   
{                                              
    if (*actPrj) {
       char buf[_MAX_PATH];
       
       strcpy(buf,actPrj);     /* does not work else because of side effect */
       NewProjectFromTemplate(buf,FALSE);
       CreateTemplateMenu(GetMenu(hwndFrame));
    }
    /*    
    FARPROC lpfn;
    char fNam[128]="*.tpl";
    
    // save old project
    if (*actPrj) 
        WriteProject((LPSTR)actPrj);
    else
        WriteProject((LPSTR)defPrj);

    // save as template definition            
    GetFileName((LPSTR)fNam,"Save as Template",TRUE,(LPEXT)&TplExt,1,hwndFrame);

    if (*fNam) {
        if (actDLL) {
            lpfn=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_NEWPROJECTNAME));
            (*(NewProjectNameProc*)lpfn)(hCompData,(LPSTR)fNam);
            lstrcpy((LPSTR)actPrj,(LPSTR)fNam);
        }
        CloseProject(TRUE);
        CreateTemplateMenu(GetMenu(hwndFrame));
    }    
    */
}                                                             

