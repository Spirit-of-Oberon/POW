/***************************************************************************
 *                                                                         *
 *  MODULE  : PowOpts.c                                                    *
 *                                                                         *
 *  PURPOSE : Code to get program options in Pow.                          *
 *                                                                         *
 *  FUNCTIONS :                                                            *
 *                                                                         *
 *        SaveMemorize()         - Auto save files/desktop/config          *
 *                                                                         *
 *        LoadMemorize()         - Load memorized configuration            *
 *                                                                         *
 *        WriteSizeOpenWindows() - Save size of open edit-windows          *
 *                                                                         *
 *        ReadSizeOpenWindows()  - Reload size of saved edit-windows       *
 *                                                                         *
 *        ReadConfig()           - Load configuration file                 *
 *                                                                         *
 *        WriteConfig()          - Save configuration file                 *
 *                                                                         *
 ***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <windows.h>

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powopen.h"
#include "powproj.h"
#include "powopts.h"
#include "powtools.h"
#include "powhelp.h"
#include "powribb.h"
#include "powed.h"
#include "powintro.h"
#include "powdde.h"
#include "powCompiler.h"

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

/* globals */
/*
HANDLE actDLL=0;              // actual compiler dll 
char actDLLname[80]="";       // name of compiler dll
char compilerHelpfile[80]=""; // name of compiler help (includes path) 
*/
char oldCompiler[255]="";      /* name of previously used compiler */
CONFIG actConfig;             /* current configuration */
int oldComp;                  /* previous compiler */
int oldEdit;                  /* previous editor */
int showResized=1;            /* flag: reposition windows or don´t */
int openChilds;               /* enumeration of open child windows */


/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetDirectories ()                                         *
 *                                                                         *
 *  PURPOSE    : invokes directories-dialog of options-menu.               *
 *                                                                         *
 ***************************************************************************/

void FAR GetDirectories()
{
    if (IsCompilerInterfaceLoaded()) {
//        FARPROC lpDir=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_DIRECTORYOPTIONS));
        (*compDirOpt)(hCompData,hwndFrame);
    }
    else
        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NOCOMPILER);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : UseNewCompiler ()                                         *
 *                                                                         *
 *  PURPOSE    : initialize workbench for selected compiler.               *
 *                                                                         *
 ***************************************************************************/

void FAR UseNewCompiler ()
{
//    FARPROC lpProc;
    char buffer[MAXPATHLENGTH];

    strcpy(buffer,defaultDir);
    if ((*defaultDir) && (defaultDir[strlen(defaultDir)-1]!='\\'))
        strcat(buffer,"\\");
    strcat(buffer,actConfig.compiler);
    strcpy(oldCompiler,actConfig.compiler);


    LoadCompilerInterface(buffer, !introScreen, (LPSTR)actConfig.compiler,(LPSTR)defaultDir,ddeInstId);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetPrefsDlgProc ()                                        *
 *                                                                         *
 *  PURPOSE    : dialog procedure of Options/Preferences                   *
 *                                                                         *
 ***************************************************************************/

void AddFiles (LPSTR files,HWND dlg,int item)
{
    #ifdef _WIN32
        HANDLE h;
        WIN32_FIND_DATA find;
        h = FindFirstFile(files,&find);
        if (h!=INVALID_HANDLE_VALUE) {
            do {
                char drv[_MAX_DRIVE],dir[_MAX_DIR],fname[_MAX_FNAME],ext[_MAX_EXT];
                _splitpath(find.cFileName,drv,dir,fname,ext);
                SendDlgItemMessage(dlg,item,CB_ADDSTRING,0,(LPARAM)(LPSTR)fname);
            } while (FindNextFile(h,&find));
            FindClose(h);
        }
    #else
        SendDlgItemMessage(dlg,item,CB_DIR,0,(long)(LPSTR)buf);
    #endif
}

int FindFile (LPSTR file,HWND dlg,int item)
{
    #ifdef _WIN32
        char drv[_MAX_DRIVE],dir[_MAX_DIR],fname[_MAX_FNAME],ext[_MAX_EXT];
        _splitpath(file,drv,dir,fname,ext);
        return (int)SendDlgItemMessage(dlg,item,CB_FINDSTRING,(WPARAM)-1,(LPARAM)(LPSTR)fname);
    #else
        return (int)SendDlgItemMessage(dlg,item,CB_FINDSTRING,(WPARAM)-1,(LPARAM)(LPSTR)file);
    #endif
}

BOOL FAR PASCAL _export GetPrefsDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch(msg) {

    case WM_INITDIALOG: {

        char buf[256];

        /* editor */
        strcpy(buf,defaultDir);
        if (*buf && buf[strlen(buf)-1]!='\\')
            strcat(buf,"\\");
        strcat(buf,"*.ell");
        DownStr((LPSTR)buf);
		AddFiles(buf,hdlg,IDD_PREFEDITOR);
        if ((oldEdit=FindFile(actConfig.editor,hdlg,IDD_PREFEDITOR))!=CB_ERR)
            SendDlgItemMessage(hdlg,IDD_PREFEDITOR,CB_SETCURSEL,oldEdit,0);

        /* ribbon position */
        SendDlgItemMessage(hdlg,IDD_PREFRIBBTOP,BM_SETCHECK,!actConfig.ribbonOnBottom,0);
        SendDlgItemMessage(hdlg,IDD_PREFRIBBBOT,BM_SETCHECK,actConfig.ribbonOnBottom,0);

        /* compiler */
        strcpy(buf,defaultDir);
        if (*buf && buf[strlen(buf)-1]!='\\')
            strcat(buf,"\\");
        strcat(buf,"*.cll");
        DownStr((LPSTR)buf);
		AddFiles(buf,hdlg,IDD_PREFCOMPILER);
        
        /* select currently used compiler */
        if ((oldComp=FindFile(actConfig.compiler,hdlg,IDD_PREFCOMPILER))!=CB_ERR)
            SendDlgItemMessage(hdlg,IDD_PREFCOMPILER,CB_SETCURSEL,oldComp,0);

        /* exit-options */
        SendDlgItemMessage(hdlg,IDD_PREFSAVEPRJ,BM_SETCHECK,actConfig.saveProject,0);
        SendDlgItemMessage(hdlg,IDD_PREFSAVEDESK,BM_SETCHECK,actConfig.saveDesk,0);
        SendDlgItemMessage(hdlg,IDD_PREFSAVECFG,BM_SETCHECK,actConfig.saveConfig,0);
        
        break;
        }

    case WM_COMMAND:

        switch (wParam) {

            case IDOK: {

                int i;

                /* editor */
                i=(int)SendDlgItemMessage(hdlg,IDD_PREFEDITOR,CB_GETCURSEL,0,0);
                if (i!=oldEdit) {
                    char oldedit[256];
                    lstrcpy(oldedit,(LPSTR)actConfig.editor);
                    SendDlgItemMessage(hdlg,IDD_PREFEDITOR,CB_GETLBTEXT,i,(long)(LPSTR)actConfig.editor);
                    lstrcat(actConfig.editor,".ell");
                    if (!UseNewEditor())
                        lstrcpy((LPSTR)actConfig.editor,(LPSTR)oldedit);
                }

                /* ribbon position */
                actConfig.ribbonOnBottom=(BOOL)SendDlgItemMessage(hdlg,IDD_PREFRIBBBOT,BM_GETCHECK,0,0);

                /* compiler */
                i=(int)SendDlgItemMessage(hdlg,IDD_PREFCOMPILER,CB_GETCURSEL,0,0);
                if (i!=oldComp) {
                    SendDlgItemMessage(hdlg,IDD_PREFCOMPILER,CB_GETLBTEXT,i,(long)(LPSTR)actConfig.compiler);
                    lstrcat(actConfig.compiler,".cll");
                    UseNewCompiler();
                }

                /* exit-options */
                actConfig.saveProject=(BOOL)SendDlgItemMessage(hdlg,IDD_PREFSAVEPRJ,BM_GETCHECK,0,0);
                actConfig.saveDesk=(BOOL)SendDlgItemMessage(hdlg,IDD_PREFSAVEDESK,BM_GETCHECK,0,0);
                actConfig.saveConfig=(BOOL)SendDlgItemMessage(hdlg,IDD_PREFSAVECFG,BM_GETCHECK,0,0);

                /* fall through! */
                }

            case IDCANCEL:

                EndDialog(hdlg,wParam);
                break;

            case IDD_PREFMOUNOT:

                SendDlgItemMessage(hdlg,IDD_PREFMOUTOPIC,BM_SETCHECK,FALSE,0);
                break;

            case IDD_PREFMOUTOPIC:

                SendDlgItemMessage(hdlg,IDD_PREFMOUNOT,BM_SETCHECK,FALSE,0);
                break;

            case IDD_PREFRIBBBOT:

                SendDlgItemMessage(hdlg,IDD_PREFRIBBTOP,BM_SETCHECK,FALSE,0);
                break;

            case IDD_PREFRIBBTOP:

                SendDlgItemMessage(hdlg,IDD_PREFRIBBBOT,BM_SETCHECK,FALSE,0);
                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Konfigurieren_der_Oberflaeche);
                break;
        }
        break;

    default:

        return FALSE;
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetPreferences ()                                         *
 *                                                                         *
 *  PURPOSE    : invokes preferences-dialog of options-menu.               *
 *                                                                         *
 ***************************************************************************/

void FAR GetPreferences()
{
    FARPROC lpMsg;
    BOOL oldRibbPos;

    oldRibbPos=actConfig.ribbonOnBottom;
    
    lpMsg=MakeProcInstance(GetPrefsDlgProc,hInst);
    DialogBox(hInst,IDD_GETPREFS,hwndFrame,lpMsg);
    FreeProcInstance(lpMsg);
    
    if (oldRibbPos!=actConfig.ribbonOnBottom)
        MoveRibbon();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : InitConfig ()                                             *
 *                                                                         *
 *  PURPOSE    : initialize configuration of workbench.                    *
 *                                                                         *
 ***************************************************************************/

void FAR InitConfig ()
{
    strcpy(actCfg,windowsDir);
    if ((!*actCfg) || (actCfg[strlen(actCfg)-1]!='\\'))
        strcat(actCfg,"\\");     
    /*2.0*/
    strcpy(defPrj,actCfg);
    strcat(defPrj,POWPRJ);
    DownStr(defPrj);

    strcat(actCfg,defCfg);
    *actPrj=0;
    
    *actConfig.editor=0;

    ReadConfig((LPSTR)actCfg);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ExitConfig ()                                             *
 *                                                                         *
 *  PURPOSE    : free initialization data.                                 *
 *                                                                         *
 ***************************************************************************/

void FAR ExitConfig ()
{
    /* free editor dll */
    CloseEditor();
    
    /* free compiler dll */
    if (IsCompilerInterfaceLoaded()) UnloadCompilerInterface();
/*        FARPROC lpFree;
        lpFree=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_EXITINTERFACE));
        (*(ExitProc*)lpFree)(hCompData);
        FreeLibrary(actDLL);
    }
  */                     
    /* free dependency matrix */
    if (hDep)
        GlobalFree(hDep);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NewSaveCfgMenu ()                                         *
 *                                                                         *
 *  PURPOSE    : update the entry in the save config-menu.                 *
 *                                                                         *
 ***************************************************************************/

void NewSaveCfgMenu ()
{
    char buf[MAXPATHLENGTH],drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];

    _splitpath(actCfg,drv,dir,nam,ext);
    strcpy(buf,"&Save\t");
    strcat(buf,nam);
    strcat(buf,ext);
    ModifyMenu(GetSubMenu(GetMenu(hwndFrame),6),8,MF_BYPOSITION,IDM_OPTSAVE,(LPSTR)buf);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : WriteConfig (LPSTR)                                       *
 *                                                                         *
 *  PURPOSE    : write workbench configuration to file.                    *
 *                                                                         *
 ***************************************************************************/

BOOL FAR WriteConfig (LPSTR lp)
{
    int i,n,tools;
    TOOL tool;
    
    if (OpenOut(lp)) {
        /* preferences */
        actConfig.version=100;
        FileOut((LPSTR)&actConfig,sizeof(CONFIG));

        /* write tools */
        i=NEW_TOOLS_VERSION;
        FileOut((LPSTR)&i,sizeof(int));

        /* count tools that were not generated by DDE calls */
        n=CountList(ToolList);
        tools=0;
        for (i=1;i<=n;i++)
            if (GetElem(ToolList,i,(long)(LPSTR)&tool))
                if (tool.ViaDDE!=VIADDESIGNATURE)
                    tools++;

        /* write all tools that were not generated by DDE calls */
        FileOut((LPSTR)&tools,sizeof(int));
        for (i=1;i<=n;i++)
            if (GetElem(ToolList,i,(long)(LPSTR)&tool)) {
                if (tool.ViaDDE!=VIADDESIGNATURE) {
                    if (tool.Type=='X')
                        ShrinkDir((LPSTR)tool.Text1,(LPSTR)defaultDir,0);
                    FileOut((LPSTR)&tool,sizeof(tool));
                }
            }    

        /* save as default name */
        lstrcpy((LPSTR)actCfg,lp);
        NewSaveCfgMenu();

        return CloseOut();
    }
    return FALSE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ReadConfig ()                                             *
 *                                                                         *
 *  PURPOSE    : read workbench configuration from file.                   *
 *                                                                         *
 ***************************************************************************/

BOOL FAR ReadConfig (LPSTR lp)
{
    TOOL tool;
    BOOL done;
    HANDLE ddeTools;
    int i,n,oldFormat;
    char oldEditor[40]="";
              
    done=FALSE;
    if (OpenIn(lp)) {
        strcpy(oldEditor,actConfig.editor);
    
        /* preferences */
        FileIn((LPSTR)&actConfig,sizeof(CONFIG));
        if (actConfig.version<100)
            *actConfig.editor=0;

        /* reset tool list, but don't purge tools generated by DDE calls */
        ddeTools = 0;
        n=CountList(ToolList);
        for (i=1;i<=n;i++) {
            if (GetElem(ToolList,i,(long)(LPSTR)&tool)) {
                /* save DDE tools to new list */
                if (tool.ViaDDE == VIADDESIGNATURE)
                    AddElem((LPHANDLE)&ddeTools,(long)(LPSTR)&tool,sizeof(tool));
            }
        }

        /* replace tool list by dde tool list */
        PurgeList((LPHANDLE)&ToolList);
        ToolList = ddeTools;

        /* read tools */
        FileIn((LPSTR)&n,sizeof(int));
        if (n==NEW_TOOLS_VERSION) { 
            FileIn((LPSTR)&n,sizeof(int));
            oldFormat=FALSE;
        }
        else
            oldFormat=TRUE;
            
        for (i=1;i<=n;i++) {
            if (oldFormat) {
                memset((LPSTR)&tool,0,sizeof(TOOL));
                FileIn((LPSTR)&tool,sizeof(OLDTOOLFORMAT));
            }
            else
                FileIn((LPSTR)&tool,sizeof(tool));
            if (tool.Type=='X')
                StretchDir((LPSTR)tool.Text1,(LPSTR)defaultDir,0);
            AddElem((LPHANDLE)&ToolList,(long)(LPSTR)&tool,sizeof(tool));
        }    
        ToolMenu(); 

        /* mark this file as current config file  */
        lstrcpy((LPSTR)actCfg,lp);

        /* put name in menu Options/Save */
        NewSaveCfgMenu();

        /* use new editor dll? */
        if (strcmp(oldEditor,actConfig.editor) && *actConfig.editor)
            if (!UseNewEditor())
                if (oldEditor)
                    strcpy(actConfig.editor,oldEditor);
                else
                    *(actConfig.editor)=0;

        /* use new compiler dll? */
        if (strcmp(oldCompiler,actConfig.compiler))
            UseNewCompiler();

        return CloseIn();
    }         
    
    if (!done) {
        //set defaults
        actConfig.compiler[0]=0;
        actConfig.editor[0]=0;
        actConfig.saveProject=TRUE;
        actConfig.saveDesk=TRUE;
        actConfig.saveConfig=TRUE;
        actConfig.ribbonOnBottom=FALSE;
        actConfig.searchIgnoreWarnings=TRUE;
    }
    return FALSE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : OpenConfig ()                                             *
 *                                                                         *
 *  PURPOSE    : open configuration file.                                  *
 *                                                                         *
 ***************************************************************************/

void FAR OpenConfig ()
{
    char buf[64]="";
    strcpy(buf,"*.cfg");
    GetFileName((LPSTR)buf,"Open Configuration",FALSE,(LPEXT)&CfgExt,1,hwndFrame);
    if (*buf) {
        ReadConfig((LPSTR)buf);
        NewToolButtons();
    }
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveConfig ()                                             *
 *                                                                         *
 *  PURPOSE    : save configuration of workbench.                          *
 *                                                                         *
 ***************************************************************************/

void FAR SaveConfig ()
{
    WriteConfig((LPSTR)actCfg);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveAsConfig ()                                           *
 *                                                                         *
 *  PURPOSE    : save configuration of workbench in new file.              *
 *                                                                         *
 ***************************************************************************/

void FAR SaveAsConfig ()
{
    char buf[MAXPATHLENGTH];

    strcpy(buf,"*.cfg");
    GetFileName((LPSTR)buf,"Save Configuration as",FALSE,(LPEXT)&CfgExt,1,hwndFrame);
    if (*buf &&
        ((!FileExists((LPSTR)buf)) || (Message(hwndFrame,MB_YESNO|MB_ICONQUESTION,IDS_OVERWRITEFILE,(LPSTR)buf)==IDYES)))
        WriteConfig((LPSTR)buf);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveOrgExt (HWND)                                         *
 *                                                                         *
 *  PURPOSE    : save origin and extent of a window.                       *
 *                                                                         *
 ***************************************************************************/

void SaveOrgExt (HWND hwnd)
{
    BOOL ok;
    long ws;
    HWND par;
    RECT r,pr;

    /* get window style and mark iconized/maximized windows */
    ws=GetWindowLong(hwnd,GWL_STYLE);
    ok=!((ws & WS_ICONIC) || (ws & WS_MAXIMIZE));
    FileOut((LPSTR)&ok,sizeof(ok));

    /* get window coordinates */
    GetWindowRect(hwnd,(LPRECT)&r);

    /* relativate coordinates for child windows */
    if ((par=GetParent(hwnd))!=0) {
        GetWindowRect(par,(LPRECT)&pr);
        r.left-=pr.left;
        r.right-=pr.left;
        r.top-=pr.top;
        r.bottom-=pr.top;
    }

    FileOut((LPSTR)&r,sizeof(r));
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : EnumOpenWindows ()                                        *
 *                                                                         *
 *  PURPOSE    : save information on open windows in desktop file.         *
 *                                                                         *
 ***************************************************************************/

BOOL FAR PASCAL _export EnumOpenWindows (HWND hwnd,DWORD lParam)
{                                               
    char name[20];
 
    /* exit, if no file-window */
    GetClassName(hwnd,(LPSTR)name,sizeof(name));
    if (lstrcmp((LPSTR)name,(LPSTR)szChild) ||
        GetWindowWord(hwnd,GWW_UNTITLED) || 
        hwnd==msgWnd)
        return TRUE;

    if (!lParam) {
        openChilds++;
    }
    else {
        char buf[MAXPATHLENGTH];
        long row,col;

        if (IsEditWindow(hwnd))
            GetWindowText(hwnd,(LPSTR)buf,sizeof(buf));
        else
            *buf=0;
        ShrinkDir((LPSTR)buf,(LPSTR)defaultDir,(LPSTR)actPrj);
        WriteStr((LPSTR)buf);

        /* origin, extent */
        SaveOrgExt(hwnd);

        /* and cursor position */
        EditGetCursorpos(hwnd,&row,&col);
        FileOut((LPSTR)&row,sizeof(int));  /* save only 16 bit! */
        FileOut((LPSTR)&col,sizeof(int));  /* (for compatibility with older Pow! config files */
    }
    return TRUE;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : WriteSizeOpenWindows ()                                   *
 *                                                                         *
 *  PURPOSE    : saves size of desktop and of child windows.               *
 *                                                                         *
 ***************************************************************************/

void FAR WriteSizeOpenWindows (void)
{
    FARPROC count;
            
    openChilds=0;
    count=MakeProcInstance(EnumOpenWindows,hInst);

    /* save number of open edit windows first */
    EnumChildWindows(hwndMDIClient,count,(long)0);
    FileOut((LPSTR)&openChilds,sizeof(openChilds));

    /* then save information about each window */
    EnumChildWindows(hwndMDIClient,count,(long)1);

    FreeProcInstance(count);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SaveMemorize ()                                           *
 *                                                                         *
 *  PURPOSE    : save desktop/project and configuration info.              *
 *                                                                         *
 ***************************************************************************/

void FAR SaveMemorize ()
{
    char fil[MAXPATHLENGTH],buf[MAXPATHLENGTH];

    strcpy(fil,windowsDir);
    if ((*fil) && (fil[strlen(fil)-1]!='\\'))
        strcat(fil,"\\");
    strcat(fil,POWDSK);

    if (OpenOut((LPSTR)fil)) {

        /* configuration file */
        if (actConfig.saveConfig) strcpy((LPSTR)buf,(LPSTR)actCfg);
        else *buf=0;            
        ShrinkDir((LPSTR)buf,(LPSTR)windowsDir,0);
        WriteStr((LPSTR)buf);

        /* project definition */
        if (actConfig.saveProject) strcpy((LPSTR)buf,(LPSTR)actPrj);
        else *buf=0;
        ShrinkDir((LPSTR)buf,(LPSTR)defaultDir,0);
        WriteStr((LPSTR)buf);

        /* desktop */
        FileOut((LPSTR)&(actConfig.saveDesk),sizeof(actConfig.saveDesk));


        if (actConfig.saveDesk) {
            /* position and size of main window */
            SaveOrgExt(hwndFrame);
            
            /* position and size of child windows */
            WriteSizeOpenWindows();
        }    

        CloseOut();
    }
 
    /* save project, if recommended */
    if (actConfig.saveProject)
        if (*actPrj)
            WriteProject((LPSTR)actPrj);
        else
            WriteProject((LPSTR)defPrj);    /*2.0*/

    /* save configuration, if recommended */
    if (actConfig.saveConfig)
        WriteConfig((LPSTR)actCfg);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : LoadOrgExt (HWND,LPSTR)                                   *
 *                                                                         *
 *  PURPOSE    : load origin and extent of a window.                       *
 *                                                                         *
 ***************************************************************************/

HWND LoadOrgExt (HWND hwnd,LPSTR buf)
{
    RECT r;
    BOOL ok;

    /* get iconized/maximized flag */
    FileIn((LPSTR)&ok,sizeof(ok));

    /* get window position and size */
    FileIn((LPSTR)&r,sizeof(r));

    if (ok && EditorIsOpen()) {
        /* read file to edit */
        if (buf && *buf)
           if (showResized)
               hwnd=AddFileAt(buf,r.left,r.top,r.right-r.left+1,r.bottom-r.top+1);
           else
               hwnd=AddFile(buf);
    }

    return (ok) ? hwnd : 0;
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ReadSizeOpenWindows ()                                    *
 *                                                                         *
 *  PURPOSE    : loads size of desktop and of child windows.               *
 *                                                                         *
 ***************************************************************************/
                      
void FAR ReadSizeOpenWindows ()
{   
    HWND winHnd;
    int row,col;
    char buf[MAXPATHLENGTH];
                         
    /* read number of open files */
    FileIn((LPSTR)&openChilds,sizeof(openChilds));

    /* for all files: */
    while (openChilds>0) {

        /* get filename, origin, extent and cursor position */
        ReadStr((LPSTR)buf);  
        StretchDir((LPSTR)buf,(LPSTR)defaultDir,(LPSTR)actPrj);
        winHnd=LoadOrgExt(0,(LPSTR)buf);
        FileIn((LPSTR)&row,sizeof(row));
        FileIn((LPSTR)&col,sizeof(col));
        if (EditorIsOpen() && winHnd && showResized) {
            EditGotoPos(winHnd,row,col);
            SetWindowText(winHnd,(LPSTR)buf);
        }                                    
        openChilds--;
    }   
}                      
                      
/***************************************************************************
 *                                                                         *
 *  FUNCTION   : LoadMemorize ()                                           *
 *                                                                         *
 *  PURPOSE    : load desktop/project and configuration info.              *
 *                                                                         *
 ***************************************************************************/

void FAR LoadMemorize ()
{
    BOOL winDesk;
    char buf[MAXPATHLENGTH],cfg[MAXPATHLENGTH],prj[MAXPATHLENGTH];
                             
    strcpy(buf,windowsDir);
    if ((*buf) && (buf[strlen(buf)-1]!='\\'))
        strcat(buf,"\\");
    strcat(buf,POWDSK);

    if (OpenIn((LPSTR)buf)) {

        /* read file names */
        ReadStr((LPSTR)cfg);
        ReadStr((LPSTR)prj);   
        StretchDir((LPSTR)cfg,(LPSTR)windowsDir,0);
        StretchDir((LPSTR)prj,(LPSTR)defaultDir,0);

        /* desktop saved ? */
        FileIn((LPSTR)&winDesk,sizeof(winDesk));
                                
        /* restore frame window position and size */
        if (winDesk)
            LoadOrgExt(hwndFrame,NULL);

        /* read desktop only if no project file will be read afterwards */                               
        /*
        if (winDesk && !*prj && !*arg_1) 
            ReadSizeOpenWindows();
        */
        CloseIn();

        /* read configuration */
        if (*cfg)
            ReadConfig((LPSTR)cfg);

        /* read project definition */
        if (*prj && !*arg_1)
            ReadProject((LPSTR)prj,FALSE);
    }              
    if (*arg_1)
        ReadProject(arg_1,FALSE);
        
    /*2.0*/
    if (!*actPrj)
        ReadProject(defPrj,TRUE);  // read default project
}
