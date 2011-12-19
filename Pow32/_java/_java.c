/*************************************************************************
 *                                                                       *
 *  PROGRAM: _JAVA.C                                                     *
 *                                                                       *
 *  PURPOSE: Pow! Compiler-Interface DLL für Java                        *
 *                                                                       *
 *  written by Bernhard Pfeifer 9155224 / 880                            *
 *************************************************************************/

#include <memory.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <shellapi.h>
#include <direct.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>

#include "errors.h"
#include "dde.h"
#include "_java.h"
#include "resource.h"

/* the about bitmap dimensions */
#define BITMAPY 16
#define BITMAPDX 168
#define BITMAPDY 149

#define MAXPATHLENGTH 256


#define VERSIONSTRINGLENGTH 12
#define PRJFILEVERSION200 "java prj 2.0"

#define EXECJAVADEFAULT "%c /K java.exe %p"

#define JAVAHELP "_java.hlp"

#define MAXCOMPOPTIONLENGTH 256

/**********************
 * instance data type *
 **********************/

typedef struct {
	 int cSwitches;                         /* compiler switches */
	 char classDir[MAXPATHLENGTH*8];        /* class directories */
	 char compilerDir[MAXPATHLENGTH];	      /* Compiler directory */
	 char prjDir[MAXPATHLENGTH];            /* project directory */
	 char prjFil[MAXPATHLENGTH];            /* project file */
   char execJava[MAXPATHLENGTH];          /* java exec string */
   char addOptions[MAXCOMPOPTIONLENGTH];  /* additional compiler options */
   BOOL prjLocalClassDir;                 /* TRUE if class dirs are local to project */
} INSTDATA;

typedef INSTDATA far *LPINSTDATA;

/**********************
 * global definitions *
 **********************/

#define ID(if) MAKEINTRESOURCE(id)
#define HELPFILE (LPSTR)"_java.hlp"


HANDLE hInst;                          /* instance handle of dll */
char homeDir[512];                     /* home directory of pow! */
char tempFile[512];                    /* compilation results temporary file */
char errorMessage[512];
char oldPath[1000];
DWORD ddeInstId;                       /* DDEML instance handle of pow! */

typedef void FAR PASCAL Depends (LPSTR);
typedef void FAR PASCAL EnumKey (LPSTR);
typedef void FAR PASCAL CompMsg (LPSTR);
typedef void FAR PASCAL CompErr (int, int, int, BOOL, LPSTR);
typedef void FAR PASCAL LinkMsg (LPSTR);

// editor functions
typedef int FAR PASCAL ReplaceProc (HWND,LPSTR,LPSTR,int,int,int,int,int);


/* *******************************
** datastructure for LoadModule  *
******************************** */

typedef struct {
	 char ext[MAXPATHLENGTH],doc[256];
} FileExt[], EXT;

typedef EXT far *LPEXT;

FileExt SrcExt={{"*.java", "Java Source (*.java)"},
				    	  {"*.html", "HTML Script (*.html)"},
		    			  {"*.*", "All Files (*.*)"}},
		    AddExt={{"*.java", "Java Source (*.java)"},
				    	  {"*.html", "HTML Script (*.html)"},
					      {"*.*", "All Files (*.*)"}};



char dirName[MAXPATHLENGTH];          // global, because of DS!=SS
char oldDir[MAXPATHLENGTH];



void FAR PASCAL NewProject (HANDLE hData);
int ObjectdirValid (LPINSTDATA lpInst);


/******************
 * initialize dll *
 ******************/
#if !defined (_WIN32)
  int FAR PASCAL LibMain (HANDLE hInstance, WORD wDSeg, WORD wHSize, LPSTR lpCmd)
  {
	 if (wHSize) UnlockData(0);
	 hInst = hInstance;
	 return 1;
  }
#else

  int main (void)
  {
	  return 0;
  }

  BOOL WINAPI DllEntryPoint (HINSTANCE instance, DWORD fdwReason, LPVOID lpvReserved)
  {
	 hInst = instance;

     if (fdwReason==DLL_PROCESS_ATTACH) {
         /* remember search path */
         *oldPath=0;
         GetEnvironmentVariable("PATH",oldPath,sizeof(oldPath));
     }
     else if (fdwReason==DLL_PROCESS_DETACH) {
         /* remove java default tools */
//         DdeSendCommand("pow","pow","deletetool AppletViewer");
//         DdeSendCommand("pow","pow","deletetool Java Runtime");
         DdeSendCommand("pow","pow","deletetool Command Prompt");

         /* reset search path */
         if (*oldPath)
             SetEnvironmentVariable ("PATH", oldPath);
     }

	 return  TRUE;
  }
#endif

/**************************************************
 * add compiler path to path environment variable *
 **************************************************/

void SetCompilerPath (LPSTR path)
{
    char newPath[1000];

    if (path && *path) {
        sprintf(newPath,"%s;%s",path,oldPath);
        SetEnvironmentVariable ("PATH",newPath);
    }
    else
        SetEnvironmentVariable ("PATH",oldPath);
}

/*********************************
 * helper function: remove slash *
 *********************************/

void RemoveTrailingSlash(LPSTR lp)
{
	if (lp && *lp && lp[lstrlen(lp)-1]=='\\')
		lp[lstrlen(lp)-1]=0;
}

/*****************************
 * set environment variables *
 *****************************/

void ConfigureEnvironment (LPINSTDATA lpInst)
{
    if (*(lpInst->classDir) && !lpInst->prjLocalClassDir)
        SetEnvironmentVariable ("CLASSPATH", lpInst->classDir);
}

/*************************************************************************
 *                                                                       *
 *            I n t e r f a c e - I n i t i a l i z a t i o n            *
 *                                                                       *
 *************************************************************************/

HANDLE CALLBACK InitInterface (LPSTR compName,LPSTR powDir,DWORD instId)
{
  HANDLE        h;
  LPINSTDATA    lp;
  DWORD         size;
  char          temp[500];
  OSVERSIONINFO version;

  lstrcpy((LPSTR)homeDir, powDir);

  /* remember DDEML instance id of pow! */
  ddeInstId=instId;

  /* add default tools for java */
//  DdeSendCommand("pow","pow","addtool AppletViewer,appletviewer.exe,%o,%p.html,1,0,0,0");
//  DdeSendCommand("pow","pow","addtool Java Runtime,cmd.exe,%o,/K java.exe %p,1,0,0,0");

//  DdeSendCommand("pow","pow","addtool Command Prompt,%c, , ,1,0,0,0"); would require translation of tool pathname in addition to tool params
  version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
  GetVersionEx(&version);
  if (version.dwPlatformId==VER_PLATFORM_WIN32_NT)
      DdeSendCommand("pow","pow","addtool Command Prompt,cmd.exe, , ,1,0,0,0");
  else
      DdeSendCommand("pow","pow","addtool Command Prompt,command.com, , ,1,0,0,0");

  #if !defined (_WIN32)
  AnsiLower ((LPSTR)homeDir);
  #endif
  if ((*homeDir) && (homeDir[lstrlen(homeDir) - 1] != '\\'))
	  lstrcat(homeDir, "\\");

  size = GetEnvironmentVariable("temp",temp,sizeof(temp));
  if (!size) size = GetEnvironmentVariable("tmp",temp,sizeof(temp));
  if (size) 
  {
	  lstrcpy(tempFile,temp);
	  if (*tempFile && tempFile[size-1]!='\\')
		  lstrcat(tempFile,"\\");
	  lstrcat(tempFile,"process.err");
  }
  else
	  lstrcat(tempFile,"c:\\process.err");
  #if !defined (_WIN32)
  AnsiLower((LPSTR)tempFile);
  #endif

  if ((h = GlobalAlloc(GMEM_MOVEABLE, sizeof(INSTDATA))) != 0)
  {
	  lp = (LPINSTDATA)GlobalLock (h);
	  lp->cSwitches = 0;
	  *(lp->classDir) = 0;
	  *(lp->compilerDir) = 0;
	  *(lp->prjDir) = 0;
	  *(lp->prjFil) = 0;
    *(lp->addOptions)=0;
	  lstrcpy((LPSTR)lp->prjDir, (LPSTR)homeDir);
    lstrcpy((LPSTR)lp->execJava,EXECJAVADEFAULT);
    lp->prjLocalClassDir=0;

	  GetProfileString("_java","ClassPath","",(LPSTR)lp->classDir, sizeof(lp->classDir));
	  GetProfileString("_java","JavacPath","",(LPSTR)lp->compilerDir, sizeof(lp->compilerDir));

	  RemoveTrailingSlash((LPSTR)lp->classDir);
	  RemoveTrailingSlash((LPSTR)lp->compilerDir);
    SetCompilerPath(lp->compilerDir);
    ConfigureEnvironment(lp);

	  NewProject (h);
	  GlobalUnlock (h);
  }
  return h;
}

/*************************************************************************
 *                                                                       *
 *                  C o m p i l e r - I n t e r f a c e                  *
 *                                                                       *
 *************************************************************************/

/*************************
 * compiler about dialog *
 *************************/

BOOL CALLBACK CompAboutDlgProc (HWND hwnd, WORD msg, WORD wParam, LONG lParam)
{
  RECT r;
  HDC dc,memdc;
  HBITMAP hmap,oldmap;
	PAINTSTRUCT ps;

	switch (msg) {

	  case WM_PAINT: {

		  hmap=LoadBitmap(hInst,MAKEINTRESOURCE(IDB_ABOUT));
		  if (hmap) 
      {
        GetClientRect(hwnd,&r);
		    dc=BeginPaint(hwnd,(LPPAINTSTRUCT)&ps);
			  memdc=CreateCompatibleDC(dc);
			  oldmap=SelectObject(memdc,hmap);
			  BitBlt(dc,(r.right-BITMAPDX)/2,BITMAPY,BITMAPDX,BITMAPDY,memdc,0,0,SRCCOPY);
               SelectObject(memdc,oldmap);
			  DeleteDC(memdc);
			  EndPaint(hwnd,(LPPAINTSTRUCT)&ps);
        DeleteObject(hmap);
      }
		}
		break;

	  case WM_COMMAND:

		  EndDialog(hwnd,0);
		  break;

	  default:

	    return FALSE;
  }
  return TRUE;
}

/**********************                      
 * start about dialog *
 **********************/

void CALLBACK AboutCompiler (HANDLE hData, HWND hwnd)
{
  FARPROC lpMsg;

  lpMsg = MakeProcInstance ((FARPROC) CompAboutDlgProc, hInst);
  DialogBox (hInst, MAKEINTRESOURCE(ABOUTCOMPILER), hwnd, lpMsg);
  FreeProcInstance (lpMsg);
}

/**********************************************************
 * initialize a compiler switch button with project value *
 **********************************************************/

void InitCOption (HWND hdlg, WORD id, int val, int cSw)
{
	 SendDlgItemMessage(hdlg, id, BM_SETCHECK, (cSw & val) !=0 ,0);
}

/**********************************************
 * set compiler option with value from button *
 **********************************************/

void GetCOption (HWND hdlg, WORD id, int val, LPINT cSw)
{
	 *cSw = *cSw& (~val);
	 if (SendDlgItemMessage(hdlg, id, BM_GETCHECK, 0, 0))
		  *cSw = *cSw | val;
}

/*****************************************************
 * let the user choose the compiler switches to use; *
 * the setup is local to the project!                *
 *****************************************************/

BOOL CALLBACK CompOptDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
	 static LPINSTDATA lpInst;

	 switch(msg)
	 {
		case WM_INITDIALOG:
			 lpInst=(LPINSTDATA)lParam;

			 InitCOption(hdlg, IDC_OPTIMIZE, CSW_OPTIMIZE, lpInst->cSwitches);
			 InitCOption(hdlg, IDC_NOWARNING, CSW_NOWARNING, lpInst->cSwitches);
			 InitCOption(hdlg, IDC_NOBYTECODE, CSW_NOBYTECODE, lpInst->cSwitches);
			 InitCOption(hdlg, IDC_JAVADEBUG, CSW_JAVADEBUG, lpInst->cSwitches);

       SetWindowText (GetDlgItem (hdlg, IDC_JAVAMORE), (LPSTR)lpInst->addOptions);
       SetWindowText (GetDlgItem (hdlg, IDC_COMMANDSTRING), (LPSTR)lpInst->execJava);
       
       break;

		case WM_COMMAND:
			 switch (LOWORD(wParam))
			 {
				case IDOK :
				{
					 GetCOption (hdlg, IDC_OPTIMIZE, CSW_OPTIMIZE, (LPINT)&(lpInst->cSwitches));
					 GetCOption (hdlg, IDC_NOWARNING, CSW_NOWARNING, (LPINT)&(lpInst->cSwitches));
					 GetCOption (hdlg, IDC_NOBYTECODE, CSW_NOBYTECODE, (LPINT)&(lpInst->cSwitches));
					 GetCOption (hdlg, IDC_JAVADEBUG, CSW_JAVADEBUG, (LPINT)&(lpInst->cSwitches));

           GetWindowText (GetDlgItem (hdlg, IDC_JAVAMORE), (LPSTR)lpInst->addOptions, sizeof(lpInst->addOptions));
           GetWindowText (GetDlgItem (hdlg, IDC_COMMANDSTRING), (LPSTR)lpInst->execJava, sizeof(lpInst->execJava));
        }

				case IDCANCEL :
				{
					 EndDialog(hdlg, LOWORD(wParam));
					 break;
				}
			 }
			 break;

		default:  return FALSE;
	 }
  return TRUE;
}

/********************************
 * start compile options dialog *
 ********************************/

BOOL CALLBACK CompileOptions (HANDLE hData, HWND hwnd)
{
	 int ret;
	 FARPROC lpMsg;
	 LPINSTDATA lpInst;

	 lpInst=(LPINSTDATA)GlobalLock(hData);
	 lpMsg=MakeProcInstance((FARPROC)CompOptDlgProc, hInst);
	 ret=DialogBoxParam(hInst, MAKEINTRESOURCE(COMPILEROPTIONS), hwnd, lpMsg, (long)lpInst);
	 FreeProcInstance(lpMsg);
	 GlobalUnlock(hData);
	 return ret;
}

/***************************
 * error callback function *
 ***************************/

BOOL FAR PASCAL AnalyzeLogFile (FARPROC err,FARPROC msg)
{
  int   lineNo, columnNo;
  char  Msg[1000];

  if (StartAnalyze (tempFile) == TRUE) {
     while (NextError() != FALSE) {

        /* try to find a line number ":???:" in current line */
        lineNo = GetLineNo (Msg);
        if (lineNo != -1) {
           /* we found a line number -> this is an error message */
		   columnNo = GetColumnNo ();
        }
        else {
           /* no line number -> compiler notification */
           columnNo = -1;
           GetLine(Msg);
        }

        if (lineNo == -1) {
           /* display notifications and other compiler messages */
           (*(CompMsg*)msg)(Msg);
        }
        else {
           /* send error messages */
           (*(CompErr*)err)(-1, lineNo, columnNo, FALSE, Msg);
        }
	 }
	 EndAnalyze ();
	 return TRUE;
  }
  else
	 return FALSE;
}

void FAR PASCAL CallCompiler (LPINSTDATA lpInst, LPSTR file, FARPROC msg, FARPROC err, LPSTR options)
{
  char 	             name[512], toScreen[255], msgtxt[1000];
  PROCESS_INFORMATION ProcessInformation;
  SECURITY_ATTRIBUTES security;
  STARTUPINFO         si;
  DWORD  				 exitCode;
  BOOL                success;
  HANDLE   				 out;
  char *      pos;        /* position of last backslash in file */

  lstrcpy (name, "\"");
  lstrcat (name, lpInst->compilerDir);
  lstrcat (name, "\\javac\" ");
  lstrcpy (toScreen, "javac ");

  /* -- add class path -- */
  lstrcat(name, "-classpath .");

  /* -- add directory of source file -- */
  pos = strrchr(file, '\\');  
  if (pos) {
    lstrcat(name, ";\"");
    strncat(name, file, pos - file);
	lstrcat(name, "\"");
  }

  /* -- add class path -- */
  if (*lpInst->classDir) {
    lstrcat(name, ";");
    lstrcat(name, lpInst->classDir);

    lstrcat(toScreen, "-classpath ");
    lstrcat(toScreen, lpInst->classDir);
    lstrcat(toScreen, " ");
  }

  /* -- add classes.zip of java compiler -- */
  pos = strrchr(lpInst->compilerDir, '\\');
  if (pos) {
    lstrcat(name, ";");
    strncat(name, lpInst->compilerDir, pos - lpInst->compilerDir);
    lstrcat(name, "\\lib\\classes.zip");
  }

  lstrcat(name, " ");

  lstrcat (name, options);
  lstrcat (name, "\"");
  lstrcat (name, file);
  lstrcat (name, "\"");

  lstrcat (toScreen, options);
  lstrcat (toScreen, "\"");
  lstrcat (toScreen, file);
  lstrcat (toScreen, "\"");
  (*(CompMsg *)msg)((LPSTR)toScreen);

  security.nLength = sizeof(security);
  security.lpSecurityDescriptor = NULL;
  security.bInheritHandle = TRUE;

  out = CreateFile (tempFile, GENERIC_WRITE, FILE_SHARE_WRITE, &security, CREATE_ALWAYS, FILE_ATTRIBUTE_TEMPORARY, NULL);

  if (out!=INVALID_HANDLE_VALUE) {
      memset (&si, 0, sizeof (si));
      si.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
      si.hStdError = out;
      si.wShowWindow = SW_SHOWMINIMIZED;
      si.cb = sizeof (si);

      success = CreateProcess (NULL, name, NULL, NULL, TRUE, 0, NULL, NULL, &si, &ProcessInformation);
      if (success) {
	     /* compiler has been started successfully */
	     HANDLE hProcess = ProcessInformation.hProcess;
	     CloseHandle (ProcessInformation.hThread);
	     if (WaitForSingleObject (hProcess, INFINITE) != WAIT_FAILED)
		    GetExitCodeProcess (hProcess, &exitCode);
	     CloseHandle (hProcess);
	     CloseHandle (out);
	     AnalyzeLogFile (err,msg);
      }
      else {
	     /* could not start compiler! */
	     sprintf(msgtxt,"Could not start compiler: %s%s",lpInst->compilerDir,"\\javac");
	     (*(CompErr*)err)(-1, -1, -1, FALSE, msgtxt);

	     CloseHandle (out);
      }
  }
  else {
	     /* could not capture stdout! */
	     sprintf(msgtxt,"Could not open temporary file %s",tempFile);
	     (*(CompErr*)err)(-1, -1, -1, FALSE, msgtxt);

	     CloseHandle (out);
  }
}



/*******************************************
 * compile a single file                   *
 * (returns true if interface has changed) *
 *******************************************/

BOOL CALLBACK CompileFile (HANDLE hData, LPSTR file, FARPROC msg, FARPROC err, HWND fromWnd, FARPROC first, FARPROC next, FARPROC fileOpen, FARPROC fileRead, FARPROC fileClose, HANDLE flist)
{
  char        options[256], opt[256];
  LPINSTDATA  lpInst;
  char drv[_MAX_DRIVE],dir[_MAX_DIR],fil[_MAX_FNAME],ext[_MAX_EXT];


  _splitpath(file,drv,dir,fil,ext);
  if ((stricmp(ext,".html")==0) || (stricmp(ext,".htm")==0)) // no java source file
  {
    return TRUE;
  }
  else
  {
  
  
    lpInst = (LPINSTDATA)GlobalLock (hData);
 
    *options = 0;

    LoadString (hInst, IDS_DEBUG, opt, sizeof(opt));
    if ((lpInst->cSwitches) & CSW_JAVADEBUG) { lstrcat (options, opt); lstrcat (options, " "); }
    LoadString (hInst, IDS_OPTIMIZE, opt, sizeof(opt));
    if (lpInst->cSwitches & CSW_OPTIMIZE) { lstrcat (options, opt); lstrcat (options, " "); }
    LoadString (hInst, IDS_NOWARNING, opt, sizeof(opt));
    if (lpInst->cSwitches & CSW_NOWARNING) { lstrcat (options, opt); lstrcat (options, " "); }
    LoadString (hInst, IDS_NOBYTECODE, opt, sizeof(opt));
    if (lpInst->cSwitches & CSW_NOBYTECODE) { lstrcat (options, opt); lstrcat (options, " "); }
    lstrcat (options, lpInst->addOptions); 
    lstrcat (options, " ");

    CallCompiler (lpInst, file, msg, err, (LPSTR)options);

    GlobalUnlock (hData);
    return TRUE;
  }
}

/*********************************
 * dummy error callback function *
 *********************************/

void CALLBACK IgnoreErrors (int num, int line, int col)
{
}

/* return the number of elements in the list */
int FAR PASCAL CountList (HANDLE list)
{
	 int i;
	 HANDLE old;

	 i = 0;
	 while (list != 0) {
		  old=list;
		  list=((LPLIST)GlobalLock(list))->next;
		  GlobalUnlock(old);
		  i++;
	 }
	 return i;
}

/* get the i-th element and return its length in bytes */
int FAR PASCAL GetElem (HANDLE list, int i, long adr)
{
	 int len;
	 LPLIST l;
	 HANDLE old;

	 while ((list!=0) && (i>0)) {
		  i--;
		  l=(LPLIST)GlobalLock(list);
		  if (i==0) {
				len=l->len;
				if (len>0) {
					 memmove((void far *)adr,GlobalLock(l->elem),len);
					 GlobalUnlock(l->elem);
				}
				GlobalUnlock(list);
				return len;
		  }
		  else {
				old=list;
				list=l->next;
				GlobalUnlock(old);
		  }
	 }
	 return 0;
}

/**********************************
 * find out dependences of module *
 **********************************/

void CALLBACK CheckDepend (HANDLE hData, LPSTR file, FARPROC depends, LPSTR buf, long len, HANDLE flist)
{
  /* no dependency check until now!!! */
}

/***********************************
 * check if file was compiled ever *
 ***********************************/

BOOL CALLBACK FileWasCompiled (HANDLE hData, LPSTR file)
{
  LPSTR      dst, st;
  char		 txt[255];
  LPINSTDATA lpInst;
  OFSTRUCT   of;

  lpInst = (LPINSTDATA)GlobalLock (hData);

  st = file + lstrlen(file);
  while (*st != '\\') st--;
  st++;

  lstrcpy ((LPSTR)txt, (LPSTR)lpInst->prjDir);

  dst = (LPSTR)txt + lstrlen (txt);
  while (*st != '.') *dst++ = *st++;
  *dst = 0;

  lstrcat ((LPSTR)txt, ".class");

  GlobalUnlock (hData);

  of.cBytes=sizeof(of);
  return (OpenFile(txt,&of,OF_EXIST)!=HFILE_ERROR);
}

/*************************************************************************
 *                                                                       *
 *                    L i n k e r - I n t e r f a c e                    *
 *                                                                       *
 *************************************************************************/

/********************************************************
 * initialize a linker switch button with project value *
 ********************************************************/

void InitLOption (HWND hdlg, WORD id, int val, int lSw)
{
}

/********************************************
 * set linker option with value from button *
 ********************************************/

void GetLOption (HWND hdlg, WORD id, int val, LPINT lSw)
{
}

/***************************
 * link options dialog box *
 ***************************/

BOOL CALLBACK LinkOptDlgProc (HWND hdlg, WORD msg, WORD wParam, LONG lParam)
{
  return TRUE;
}



/*******************************
 * start linker options dialog *
 *******************************/

BOOL CALLBACK LinkerOptions (HANDLE hData,HWND hwnd)
{
  MessageBox (hwnd, "No linker options!", "Information", MB_OK | MB_ICONEXCLAMATION);
  return FALSE;
}


/****************
 * free strings *
 ****************/

void FreeMem (HANDLE h,LPSTR p)
{
	 if (h) {
		  GlobalUnlock(h);
		  GlobalFree(h);
	 }
}

/****************
 * link project *
 ****************/

int CALLBACK Link (HANDLE hData, LPSTR file, HANDLE flist, FARPROC msg)
{
  return 1;
}

/*************************************************************************
 *                                                                       *
 *                 D i r e c t o r y - I n t e r f a c e                 *
 *                                                                       *
 *************************************************************************/

/******************************                                                                         *
 * directory dialog procedure *
 ******************************/

LPINSTDATA lpInst;

BOOL CALLBACK GetDirsDlgProc (HWND hdlg, WORD msg, WORD wParam, LONG lParam)
{
  static LPINSTDATA lpInst = NULL;

  switch (msg)
  {
	 case WM_INITDIALOG :
	 {
		lpInst = (LPINSTDATA) lParam;

//		GetProfileString("_java","ClassPath","",(LPSTR)lpInst->classDir, sizeof(lpInst->classDir));
		GetProfileString("_java","JavacPath","",(LPSTR)lpInst->compilerDir, sizeof(lpInst->compilerDir));

		RemoveTrailingSlash((LPSTR)lpInst->classDir);
		RemoveTrailingSlash((LPSTR)lpInst->compilerDir);

    SendMessage(GetDlgItem (hdlg, IDC_PRJLOCALCLASSPATH), BM_SETCHECK, lpInst->prjLocalClassDir, 0);

		SetWindowText (GetDlgItem (hdlg, IDC_CLASSPATH), (LPSTR)lpInst->classDir);
		SetWindowText (GetDlgItem (hdlg, IDC_COMPILERPATH), (LPSTR)lpInst->compilerDir);

		break;
	 }

	 case WM_COMMAND :
	 {
		switch (LOWORD(wParam))
		{
		  case IDOK :
		  {
			 GetWindowText (GetDlgItem (hdlg, IDC_CLASSPATH), (LPSTR)lpInst->classDir, sizeof(lpInst->classDir));
			 GetWindowText (GetDlgItem (hdlg, IDC_COMPILERPATH), (LPSTR)lpInst->compilerDir, sizeof(lpInst->compilerDir));

       lpInst->prjLocalClassDir=SendMessage(GetDlgItem (hdlg, IDC_PRJLOCALCLASSPATH), BM_GETCHECK, 0, 0);

			 RemoveTrailingSlash((LPSTR)lpInst->classDir);
			 RemoveTrailingSlash((LPSTR)lpInst->compilerDir);

       if (!lpInst->prjLocalClassDir)
         WriteProfileString("_java","ClassPath",(LPSTR)lpInst->classDir);

			 WriteProfileString("_java","JavacPath",(LPSTR)lpInst->compilerDir);

       /* activate new path to compiler (and cygwin.dll) */
       SetCompilerPath(lpInst->compilerDir);

       /* set environment variables */
       ConfigureEnvironment(lpInst);
		  }

		  case IDCANCEL :
		  {
			 EndDialog (hdlg, LOWORD(wParam));
			 break;
		  }

      case ID_HELP:
        WinHelp(hdlg,JAVAHELP,HELP_CONTEXT,HELPTOPIC_DIRECTORIES);
        break;
		}
	 }
	 default : return FALSE;
  }
  return TRUE;
}


BOOL CALLBACK DirectoryOptions (HANDLE hData, HWND hwnd)
{
  int        ret;
  FARPROC    lpMsg;
  LPINSTDATA lpInst;

  lpInst = (LPINSTDATA) GlobalLock (hData);

  lpMsg = MakeProcInstance ((FARPROC)GetDirsDlgProc, hInst);
  ret = DialogBoxParam (hInst, (char *)DIRPATHES, hwnd, lpMsg, (long)lpInst);
  FreeProcInstance (lpMsg);

  GlobalUnlock (hData);

  return (ret == IDOK);
}

/*************************************************************************
 *                                                                       *
 *                   P r o j e k t - I n t e r f a c e                   *
 *                                                                       *
 *************************************************************************/

void CALLBACK NewProject (HANDLE hDat)
{
  LPINSTDATA  lpInst;

  lpInst = (LPINSTDATA)GlobalLock (hDat);

  lpInst->cSwitches = CSW_OPTIMIZE;
  lstrcpy((LPSTR)lpInst->execJava,EXECJAVADEFAULT);
  lpInst->prjLocalClassDir=0;
  *(lpInst->addOptions)=0;

  GlobalUnlock (hDat);
}

BOOL CALLBACK WriteOptions (HANDLE hDat, LPSTR prjName, HFILE hf/*uk*/)
{
  LPSTR      p;
  LPINSTDATA lpInst;
  char versionStr[VERSIONSTRINGLENGTH+1];

  lpInst = (LPINSTDATA) GlobalLock (hDat);

  lstrcpy ((LPSTR)lpInst->prjFil, prjName);
  lstrcpy ((LPSTR)lpInst->prjDir, prjName);
  p = (LPSTR)lpInst->prjDir + lstrlen(lpInst->prjDir) - 1;
  while (*p != '\\') p--;
  *++p = 0;

  strcpy(versionStr,PRJFILEVERSION200);

  _lwrite (hf, (LPSTR)versionStr, VERSIONSTRINGLENGTH);

  _lwrite (hf, (LPSTR)&lpInst->prjLocalClassDir, sizeof(lpInst->prjLocalClassDir));
  if (lpInst->prjLocalClassDir)
    _lwrite (hf, (LPSTR)lpInst->classDir, sizeof(lpInst->classDir));
  _lwrite (hf, (LPSTR)lpInst->execJava, sizeof(lpInst->execJava));
  _lwrite (hf, (LPSTR)lpInst->addOptions, sizeof(lpInst->addOptions));
  _lwrite (hf, (LPSTR)&lpInst->cSwitches, sizeof(lpInst->cSwitches));

  GlobalUnlock (hDat);

  return TRUE;
}

BOOL CALLBACK ReadOptions (HANDLE hData, LPSTR prjName, HANDLE hf/*uk*/)
{
  typedef enum _prjVersions {Version10, Version20} PrjVersionT;

  LPSTR      p;
  LPINSTDATA lpInst;
  char versionStr[VERSIONSTRINGLENGTH+1];

  PrjVersionT version;
  LONG bytesRead;


  lpInst = (LPINSTDATA)GlobalLock (hData);

  lstrcpy ((LPSTR)lpInst->prjFil, prjName);
  lstrcpy ((LPSTR)lpInst->prjDir, prjName);
  p = (LPSTR)lpInst->prjDir + lstrlen(lpInst->prjDir) - 1;
  while (*p != '\\') p--;
  *++p = 0;

  ReadFile(hf, versionStr, VERSIONSTRINGLENGTH, &bytesRead, NULL);

  versionStr[VERSIONSTRINGLENGTH]=0;

  if (bytesRead!=VERSIONSTRINGLENGTH)
  {
    version=Version10;
    SetFilePointer(hf,-bytesRead,NULL,FILE_CURRENT);
  }
  else if (strcmp(versionStr,PRJFILEVERSION200)==0) version=Version20;

  if (version==Version20) 
  {
    ReadFile(hf, &lpInst->prjLocalClassDir, sizeof(lpInst->prjLocalClassDir), &bytesRead, NULL);
    if (lpInst->prjLocalClassDir)
      ReadFile(hf, lpInst->classDir, sizeof(lpInst->classDir), &bytesRead, NULL);
    else
      GetProfileString("_java","ClassPath","",(LPSTR)lpInst->classDir, sizeof(lpInst->classDir));
    ReadFile(hf, lpInst->execJava, sizeof(lpInst->execJava), &bytesRead, NULL);
    ReadFile(hf, lpInst->addOptions, sizeof(lpInst->addOptions), &bytesRead, NULL);
  }
  else
  {
    GetProfileString("_java","ClassPath","",(LPSTR)lpInst->classDir, sizeof(lpInst->classDir));
    lpInst->prjLocalClassDir=0;
    strcpy(lpInst->execJava,EXECJAVADEFAULT);
    *(lpInst->addOptions)=0;
  }
  ReadFile(hf, (LPSTR)&lpInst->cSwitches, sizeof(lpInst->cSwitches), &bytesRead, NULL);

  GlobalUnlock (hData);

  return TRUE;
}

void CALLBACK GetExtensions (HANDLE hData, LPEXT far *srcExt,LPINT srcN,LPEXT far *addExt,LPINT addN)
{
  *srcExt = (LPEXT)&SrcExt;
  *addExt = (LPEXT)&AddExt;
  *srcN = 3;
  *addN = 3;
}

BOOL CALLBACK GetExecutable (HANDLE hData, LPSTR exe)
{
  LPINSTDATA lpInst;
    
  lpInst=(LPINSTDATA)GlobalLock(hData);
  lstrcpy(exe,(LPSTR)lpInst->execJava);
  GlobalUnlock(hData);
  return TRUE;
}

BOOL CALLBACK GetTarget (HANDLE hData,LPSTR exe)
{
  *exe=0;
  return FALSE;
}

// check, if file exists in a  directory
BOOL SearchFile (LPSTR dir,LPSTR name,LPSTR file)
{
  int f;
  char full[MAXPATHLENGTH];

  strcpy (full, dir);
  if (full[strlen(full) - 1] != '\\')
	 strcat (full, "\\");
  strcat (full, name);

  f = _lopen (full, OF_READ);
  if (f != HFILE_ERROR)
  {
	 _lclose (f);
	 strcpy (file, full);
  }
  return (f != HFILE_ERROR);
}

void CALLBACK NewProjectName (HANDLE hData,LPSTR prjName)
{
  LPINSTDATA   lpInst;

  lpInst = (LPINSTDATA)GlobalLock (hData);

  lstrcpy ((LPSTR)lpInst->prjFil, prjName);
  lstrcpy ((LPSTR)lpInst->prjDir, prjName);
  RemoveTrailingSlash(lpInst->prjDir);

  GlobalUnlock (hData);
}


// added by PDI, 98/10/07
void CALLBACK ChangeModuleName (HANDLE hData,HWND hwnd,FARPROC replace,LPSTR modname,LPSTR dstname) {

  char szSearch[MAXPATHLENGTH];    // search string
  char szReplace[MAXPATHLENGTH];   // replace string
				 
  if (replace) {

    // -- replace class name: "class <template name>" -> "class <project name>" --
    lstrcpy(szSearch, "class ");
    lstrcat(szSearch, modname);
    lstrcpy(szReplace, "class ");
    lstrcat(szReplace, dstname);
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);

    // -- replace constructor name: "<template name>(" -> "<project name>(" --
    lstrcpy(szSearch, modname);
    lstrcat(szSearch, "(");
    lstrcpy(szReplace, dstname);
    lstrcat(szReplace, "(");
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);

	// -- replace applet tag: various situations
	// 1) "<applet code="template name">"   --> "<applet code="project name">"
	// 2) "<applet code=template name>"     --> "<applet code="project name">"
	// 3) "<applet code = "template name">" --> "<applet code="project name">"
	// 4) "<applet code = template name>"   --> "<applet code="project name">"
	lstrcpy(szSearch, "code=\"");
	lstrcat(szSearch, modname);
	lstrcpy(szReplace, "code=\"");
	lstrcat(szReplace, dstname);
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);
	lstrcpy(szSearch, "code=");
	lstrcat(szSearch, modname);
	lstrcpy(szReplace, "code=");
	lstrcat(szReplace, dstname);
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);
	lstrcpy(szSearch, "code = \"");
	lstrcat(szSearch, modname);
	lstrcpy(szReplace, "code = \"");
	lstrcat(szReplace, dstname);
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);
	lstrcpy(szSearch, "code = ");
	lstrcat(szSearch, modname);
	lstrcpy(szReplace, "code = ");
	lstrcat(szReplace, dstname);
    (*(ReplaceProc*)replace)(hwnd, szSearch, szReplace, FALSE, TRUE, FALSE, FALSE, FALSE);

  }

}


int ObjectdirValid (LPINSTDATA lpInst)
{
  if (lpInst && *(lpInst->classDir))
  {
	 getcwd (oldDir, sizeof (oldDir));
	 lstrcpy ((LPSTR)dirName, lpInst->classDir);
	 if (dirName[lstrlen((LPSTR)dirName) - 1] == '\\')
		dirName[lstrlen((LPSTR)dirName - 1)] = 0;
	 if (chdir (dirName)) return FALSE;
	 chdir (oldDir);
  }
  return TRUE;
}

// check, if we have the source for a requested module
BOOL CALLBACK SourceAvailable (HANDLE hData, LPSTR module, LPSTR file)
{
  return TRUE;
}

// calculate time of creation of given file, return TRUE if file exists
BOOL GetFileCreation (char *file,FILETIME *time)
{
   HANDLE h;
   WIN32_FIND_DATA fdata;

   h=FindFirstFile(file,&fdata);
   if (h!=INVALID_HANDLE_VALUE) {
      *time = fdata.ftLastWriteTime;
      FindClose(h);
      return TRUE;
   }
   return FALSE;
}

// check, if a project file must be compiled
BOOL CALLBACK MustBeBuilt (HANDLE hData, LPSTR file)
{
   BOOL ret;
   FILETIME javatime,classtime;
   char drv[_MAX_DRIVE],dir[_MAX_DIR],fil[_MAX_FNAME],ext[_MAX_EXT],fclass[_MAX_PATH];

   _splitpath(file,drv,dir,fil,ext);
   sprintf(fclass,"%s%s%s%s",drv,dir,fil,".class");

   if (!GetFileCreation(file,&javatime))
   	return FALSE;  // source does not exist -> no build necessary
    
   if (!GetFileCreation(fclass,&classtime))
   	return TRUE;   // no class file -> build necessary
	
   ret=(CompareFileTime(&classtime,&javatime)<0);
                     // compilation necessary if object older than source
	 
   return ret;
}

// check, if a project file must be compiled
BOOL CALLBACK CheckIfYounger (HANDLE hData,LPSTR module,LPSTR client)
{
  return FALSE;
}

/*************************************************************************
 *                                                                       *
 *                      H e l p - I n t e r f a c e                      *
 *                                                                       *
 *************************************************************************/

BOOL CALLBACK HelpCompiler (HANDLE hData, HWND hwnd, LPSTR powDir, WORD wCmd, DWORD dwData)
{
	 char buf[MAXPATHLENGTH];

	 lstrcpy(buf, powDir);
	 if ((*buf) && (buf[lstrlen(buf)-1]!='\\'))
		  lstrcat(buf, "\\");
	 lstrcat(buf, "_java.hlp");

	 /* call for help */
	 return WinHelp(hwnd, (LPSTR)buf, wCmd, dwData);
}

/* return name of help file (without directory information) */
void CALLBACK GetHelpFile (HANDLE hData,LPSTR name)
{
	 lstrcpy(name,JAVAHELP);
}

/*************************************************************************
 *                                                                       *
 *                    E d i t o r - I n t e r f a c e                    *
 *                                                                       *
 *************************************************************************/

/*****************
 * tell keywords *
 *****************/

void CALLBACK EditorSyntax (HANDLE hData,LPLONG caseSensitive,FARPROC enumK)
{
	 *caseSensitive = TRUE;
	 (*(EnumKey*)enumK)("abstract");
	 (*(EnumKey*)enumK)("boolean");
	 (*(EnumKey*)enumK)("break");
	 (*(EnumKey*)enumK)("byte");
	 (*(EnumKey*)enumK)("case");
	 (*(EnumKey*)enumK)("catch");
	 (*(EnumKey*)enumK)("char");
	 (*(EnumKey*)enumK)("class");
	 (*(EnumKey*)enumK)("const");
	 (*(EnumKey*)enumK)("continue");
	 (*(EnumKey*)enumK)("default");
	 (*(EnumKey*)enumK)("do");
	 (*(EnumKey*)enumK)("double");
	 (*(EnumKey*)enumK)("else");
	 (*(EnumKey*)enumK)("extends");
	 (*(EnumKey*)enumK)("final");
	 (*(EnumKey*)enumK)("finally");
	 (*(EnumKey*)enumK)("float");
	 (*(EnumKey*)enumK)("for");
	 (*(EnumKey*)enumK)("goto");
	 (*(EnumKey*)enumK)("if");
	 (*(EnumKey*)enumK)("implements");
	 (*(EnumKey*)enumK)("import");
	 (*(EnumKey*)enumK)("instanceof");
	 (*(EnumKey*)enumK)("int");
	 (*(EnumKey*)enumK)("interface");
	 (*(EnumKey*)enumK)("long");
	 (*(EnumKey*)enumK)("native");
	 (*(EnumKey*)enumK)("new");
	 (*(EnumKey*)enumK)("package");
	 (*(EnumKey*)enumK)("private");
	 (*(EnumKey*)enumK)("protected");
	 (*(EnumKey*)enumK)("public");
	 (*(EnumKey*)enumK)("return");
	 (*(EnumKey*)enumK)("short");
	 (*(EnumKey*)enumK)("static");
	 (*(EnumKey*)enumK)("super");
	 (*(EnumKey*)enumK)("switch");
	 (*(EnumKey*)enumK)("synchronized");
	 (*(EnumKey*)enumK)("this");
	 (*(EnumKey*)enumK)("throw");
	 (*(EnumKey*)enumK)("throws");
	 (*(EnumKey*)enumK)("transient");
	 (*(EnumKey*)enumK)("try");
	 (*(EnumKey*)enumK)("void");
	 (*(EnumKey*)enumK)("volatile");
	 (*(EnumKey*)enumK)("while");
}

/*********************************
 * tell construction of comments *
 *********************************/

void CALLBACK EditorComment (HANDLE hData,LPLONG inComments,LPSTR commentOn,LPSTR commentOff,LPSTR strings)
{
	*inComments = 0;             /* nested comments are not allowed */
	strcpy(strings,"\"");        /* delimiters of strings */
	strcpy(commentOn,"/*");
	strcpy(commentOff,"*/");
}

/*************************************************************************
 *                                                                       *
 *                      I n t e r f a c e - E x i t                      *
 *                                                                       *
 *************************************************************************/

void CALLBACK ExitInterface (HANDLE hData)
{
	 GlobalFree(hData);
}
