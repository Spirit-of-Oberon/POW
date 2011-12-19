/***************************************************************************
 *                                                                         *
 *  MODULE  :   PowRun.c                                                   *
 *                                                                         *
 *  PURPOSE :   Run menu of Pow!                                           *
 *                                                                         *
 *  FUNCTIONS : RunProject ()    - Try to run the project!                 *
 *                                                                         *
 *              RunArgsDlgProc() - Dialog function for Run Params          *
 *                                                                         *
 *              GetRunArgs()     - Invokes RunArgsDlgProc                  *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifndef _WIN32
  #include <toolhelp.h>
#endif

#include "..\powsup\powsupp.h"
#include "powproj.h"
#include "powopen.h"
#include "powhelp.h"
#include "powopts.h"
#include "powrun.h"
#include "pow.h"
#include "powcomp.h"
#include "powed.h"
#include "powCompiler.h"
#include "powtools.h"

/* globals */
char RunArgs[255]="";      /* initialize argument string for tools */

/************************************************************
 * check if an earlier instance of the program is in memory *
 ************************************************************/

BOOL FAR StillRunning (LPSTR module)
{               
#ifdef _WIN32
    /* until now, I did not find a method for enumerating all processes,
       or how to get a process handle from a process identifier (then
       EnumWindows - GetWindowProcessId would be a way) */
    return FALSE;
#else
    int choice;
    HMODULE hmodule;
    char exename[MAXPATHLENGTH],drive[MAXPATHLENGTH],dir[MAXPATHLENGTH],ext[MAXPATHLENGTH];
    TASKENTRY tentry;
    MODULEENTRY mentry;
    
    _splitpath(module,drive,dir,exename,ext);
    AnsiUpper(exename);
    mentry.dwSize=sizeof(MODULEENTRY);
    
    while (hmodule=ModuleFindName(&mentry,exename)) {
        choice=Message(hwndFrame,MB_YESNOCANCEL|MB_ICONQUESTION,IDS_ALREADYRUNNING,exename);
        if (choice==IDYES) {
            tentry.dwSize=sizeof(TASKENTRY);
            if (TaskFirst(&tentry)) {
                do {
                    if (tentry.hModule==hmodule)
                        TerminateApp(tentry.hTask,NO_UAE_BOX);
                        //PostAppMessage(tentry.hTask,WM_QUIT,0,0);
                } while (TaskNext(&tentry));
            }
        }
        else return (choice==IDCANCEL);
    }
    return FALSE;
#endif
}

/**************************
 * run project executable *
 **************************/

void FAR RunProject (HWND hwnd)
{       
  BOOL isExecutable;
  int uptodate;
//    FARPROC lpfn;                  
  char prog[MAXPATHLENGTH+256];
  char buf[MAXPATHLENGTH+256];
  char params[256];
  int ret;  
  int i;
  char drv[MAXPATHLENGTH],dir[MAXPATHLENGTH],name[MAXPATHLENGTH],ext[MAXPATHLENGTH];
  char *runDir;
            
  /*2.0*/
  SaveProjectEdits(GetActiveEditWindow(hwndMDIClient), FALSE);

  if (!*actPrj) 
  {
    RemoveMessageWindow();
    if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) 
    {
      /* rename untitled source */
      if (GetWindowWord(GetActiveEditWindow(hwndMDIClient),GWW_UNTITLED)) 
      {
        if (ChangeFile(GetActiveEditWindow(hwndMDIClient)))
          SendMessage(GetActiveEditWindow(hwndMDIClient),WM_COMMAND,IDM_FILESAVE,0L);
        else
          return;
      }
      SetDefaultProjectName();
    }   
    else
    {
      Message(hwnd,MB_OK|MB_ICONEXCLAMATION,IDS_NOPROGRAM);
      return;
    }
  }
        
  isExecutable=(*compGetExec)(hCompData,(LPSTR)prog);

  if (!isExecutable)
    Message(hwnd,MB_OK|MB_ICONEXCLAMATION,IDS_NOEXECUTABLE);        
  else 
  {  
    /* check if an earlier instance is already active */
    if (StillRunning(prog))
      return;
            
    if (!*actPrj) CollectFiles(GetActiveEditWindow(hwndMDIClient));
    if (!AllFilesThere()) 
    {
      if (!*actPrj) FreeCollectedFiles();
      return;
    }
    if (!*actPrj) FreeCollectedFiles();
        
    if (*prog) 
    {
      if (!MakeProject(GetActiveEditWindow(hwndMDIClient), &uptodate, FALSE)) return;               // always make program before running!
        /* append program parameters */
      #ifdef _WIN32
      strcat(prog," ");
      strcat(prog,RunArgs);
      DecodeArg(prog,buf);
      if (buf[0]=='"')
      {
        i=1;
        while ((buf[i]!=0) && (buf[i]!='"')) i++;
        if (buf[i]!=0) i++;
        strcpy(params,buf+i);
        if ((i>0) && (buf[i-1]=='"')) buf[i-1]=0; else buf[i]=0;
        i=1;
        while (buf[i-1]=buf[i]) i++;
      }
      else
      {
        i=0;
        while ((buf[i]!=0) && (buf[i]!=' ')) i++;
        strcpy(params,buf+i);
        buf[i]=0;
      }
      if (*actPrj)
      {
        _splitpath(actPrj,drv,dir,name,ext);
        runDir=drv;
        strcat(runDir,dir);
      }
      else
      {
        runDir=NULL;
      }


      if ((ret=(int)ShellExecute(GetDesktopWindow(),"open",buf,params,runDir,SW_SHOWNORMAL))<=32) 
      {
        switch (ret) 
        {
          case 0:  LoadString(hInst,IDS_RUNERROR0,prog,sizeof(prog)); break;
          case 2:  LoadString(hInst,IDS_RUNERROR2,prog,sizeof(prog)); break;
          case 3:  LoadString(hInst,IDS_RUNERROR3,prog,sizeof(prog)); break;
          case 8:  LoadString(hInst,IDS_RUNERROR8,prog,sizeof(prog)); break;
          default: {
                     char code[10];
                     strcpy(prog,"Program returned with code ");
                     itoa(ret,code,10);
                     strcat(prog,code);
                     strcat(prog,".");
                   }
        }         
      }
      else 
        strcpy(prog,"Program started successfully.");    

      NewMessage((LPSTR)prog,TRUE);

      #else
      DownStr((LPSTR)prog);

      if (FileExists((LPSTR)prog)) 
      {
        strcat(prog," ");
        strcat(prog,RunArgs);
        if ((ret=WinExec((LPSTR)prog,SW_SHOW))<=32) 
        {
           /* error encountered */
           switch (ret) {
             case 0:  LoadString(hInst,IDS_RUNERROR0,prog,sizeof(prog)); break;
             case 2:  LoadString(hInst,IDS_RUNERROR2,prog,sizeof(prog)); break;
             case 3:  LoadString(hInst,IDS_RUNERROR3,prog,sizeof(prog)); break;
             case 8:  LoadString(hInst,IDS_RUNERROR8,prog,sizeof(prog)); break;
             default: {
                        char code[10];
                        strcpy(prog,"Program returned with code ");
                        itoa(ret,code,10);
                        strcat(prog,code);
                        strcat(prog,".");
                      }
           }         
        }
      }
      else 
        strcpy(prog,"Program started successfully.");    

      NewMessage((LPSTR)prog,TRUE);
      #endif                    
    }
    else
      Message(hwnd,MB_OK|MB_ICONEXCLAMATION,IDS_NOPROG,(LPSTR)prog);
  }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : RunArgsDlgProc (hdlg,message,wParam,lParam)               *
 *                                                                         *
 *  PURPOSE    : Dialog function for the Run/Params command.               *
 *               Prompts for Run Argument string.                          *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export RunArgsDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch (msg) {

    case WM_INITDIALOG:
        /* Insert last argument string */
        SetWindowText(GetDlgItem(hdlg,IDD_RUNARGS),(LPSTR)RunArgs);
        SendDlgItemMessage(hdlg,IDD_RUNARGS,EM_SETSEL,0,0);
        break;

    case WM_COMMAND: {

        switch (wParam) {

        case IDOK:

            /* Get line number */
            GetDlgItemText(hdlg,IDD_RUNARGS,(LPSTR)RunArgs,sizeof(RunArgs));
            /*** FALL THRU ***/

        case IDCANCEL:

            EndDialog (hdlg,0);
            break;

        case IDD_HELP:

            WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Programm_Parameter);
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
 *  FUNCTION   : GetRunArgs ()                                             *
 *                                                                         *
 *  PURPOSE    : Invokes the Run Arguments dialog.                         *
 *                                                                         *
 ***************************************************************************/

void FAR GetRunArgs ()
{
    FARPROC lpfn;

    lpfn=MakeProcInstance(RunArgsDlgProc,hInst);
    DialogBox(hInst,IDD_RUNARG,hwndFrame,lpfn);
    FreeProcInstance(lpfn);
}

