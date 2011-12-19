/*************************************************************************
 *                                                                       *
 *  PROGRAM: _Oberon.c                                                   *
 *                                                                       *
 *  PURPOSE: Pow! Compiler-Interface DLL for Oberon/2                    *
 *                                                                       *
 *************************************************************************/

#include <memory.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <direct.h>
#include <errno.h>
#include <ctype.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "../powsup/powsupp.h"
#include "_oberon.h"
#include "dde.h"

/* the about bitmap dimensions */
#define BITMAPY 16
#define BITMAPDX 200
#define BITMAPDY 150
#define MAXPATHLENGTH 256

/*****************************
 * external linker functions *
 *****************************/

#ifdef _WIN32
   extern int FAR PASCAL Link32 (int opt,LPSTR obj,LPSTR lib,LPSTR exe,LPSTR res,LPSTR exp,FARPROC msg,ULONG baseAdr,LPSTR entrySym,ULONG stackSize);
#else
   extern int FAR PASCAL LinkProgram (int opt,LPSTR obj,LPSTR lib,LPSTR exe,LPSTR stub,LPSTR res,LPSTR imp,LPSTR exp,FARPROC msg,WORD hSize,WORD sSize);
#endif

extern void FAR PASCAL GetLinkVersion (LPSTR);

/******************************
 * compiler interface version *
 ******************************/
 
const char compilerVersion[]= "Version x.xx\\(c) 1998";
const char interfaceVersion[]= "32-Bit Interface 1.1";
const char interfaceYear[]= "(c) 1998";

/**********************
 * instance data type *
 **********************/                  

typedef struct {                        
    int cSwitches;                     /* compiler switches */
    int lSwitches;                     /* linker switches */
    long heap;                         /* heap size */
    long stack;                        /* stack size */
    HANDLE exports;                    /* export procedures */
    HANDLE imports;                    /* import procedures (from DLL's) */
    HANDLE dllModules;                 /* modules from dlls */
    char objDir[MAXPATHLENGTH];        /* objectcode directories */
    char prjDir[MAXPATHLENGTH];        /* project directory */
    char prjFil[MAXPATHLENGTH];        /* project file */
	  long baseAdr;                      /* base address */
	  char entrySym[80];                 /* entry symbol name */
    long stackSize;                    /* size of the application's stack */
    BOOL ignoreLink;                   /* TRUE if linkage is suppressed */
} INSTDATA;

typedef INSTDATA far *LPINSTDATA;

/**********************                        
 * global definitions *
 **********************/ 

#define ID(id) MAKEINTRESOURCE(id)
#define MAXID 40                       /* maximum size of identifiers in Oberon-2 */

#ifdef _WIN32
   #define HELPFILE     (LPSTR)"oberon32.hlp"
   #define HELPCOMPILER (LPSTR)"_ob32.hlp"
   #define PRJFILEVERSION301 "Project version 3.01"
   #define PRJFILEVERSION302 "Project version 3.02"
   #define PRJFILEVERSION303 "Project version 3.03"
   #define VERSIONSTRINGLENGTH 80
#else
   #define HELPFILE     (LPSTR)"oberon2.hlp"
   #define HELPCOMPILER (LPSTR)"_oberon.hlp"
#endif

HANDLE hInst;                          /* instance handle of dll */
FARPROC errMsg;                        /* send error message to pow! */
char homeDir[MAXPATHLENGTH];                      /* home directory of pow! */
DWORD ddeInstId;                       /* DDEML instance handle of pow! */

typedef void FAR PASCAL Depends (LPSTR);
typedef void FAR PASCAL EnumKey (LPSTR);
typedef void FAR PASCAL CompMsg (LPSTR);
typedef void FAR PASCAL CompErr (int,int,int,BOOL,LPSTR);
typedef void FAR PASCAL LinkMsg (LPSTR);

typedef struct {
   char fileName[MAXPATHLENGTH];
   char tmpName[MAXPATHLENGTH];
   char objDir[MAXPATHLENGTH];
   char objName[MAXPATHLENGTH];
   char licName[MAXPATHLENGTH];
   char symDirs[MAXPATHLENGTH*4];
   HWND fromWnd;
   FARPROC firstProc;
   FARPROC nextProc;
   FARPROC openProc;
   FARPROC readProc;
   FARPROC closeProc;
   long options;
   FARPROC errProc;
   FARPROC depProc;
} COMP;

typedef struct {
    char ext[MAXPATHLENGTH],doc[256];
} FileExt[],EXT;

typedef EXT far *LPEXT;

typedef int FAR PASCAL ReplaceProc (HWND,LPSTR,LPSTR,int,int,int,int,int);

FileExt
   SrcExt=
      {{"*.mod","Oberon Source (*.mod)"},
{"*.mm2","Mini-Modula-2 (*.mm2)"},
		 {"*.rc","Resource Source (*.rc)"},
		 {"*.*","All Files (*.*)"}},

#ifdef _WIN32
   /* 32-bit oberon compiler has no resource compiler :-( */
   AddExt=
      {{"*.mod","Oberon Source (*.mod)"},
		 {"*.obj","Object File (*.obj)"},
		 {"*.lib","Library (*.lib)"},
		 {"*.res","Resource File (*.res)"},
		 {"*.*","All Files (*.*)"}};
#else
   AddExt=
      {{"*.mod","Oberon Source (*.mod)"},
		 {"*.rc","Resource Source (*.rc)"},
		 {"*.obj","Object File (*.obj)"},
		 {"*.lib","Library (*.lib)"},            
		 {"*.res","Resource File (*.res)"},
		 {"*.*","All Files (*.*)"}};
#endif

void FAR PASCAL NewProject (HANDLE hData);
void CreateDir (LPSTR dir);
int ObjectdirValid (LPINSTDATA lpInst);

extern BOOL FAR PASCAL Oberon2 (LPSTR command);
extern void FAR PASCAL GetCompilerVersion (LPSTR version);
extern void WINAPI AddDLLModule (LPSTR module,long lowbound,long size,LPINT done);
extern void WINAPI ClearDLLModules (void);

#ifndef _WIN32
   extern void WINAPI CompileRes (LPSTR src,LPSTR dst,FARPROC err,FARPROC msg);
#endif

/*************************************************************************
 *                                                                       *
 *            I n t e r f a c e - I n i t i a l i z a t i o n            *
 *                                                                       *
 *************************************************************************/

HANDLE FAR PASCAL _export InitInterface (LPSTR compName,LPSTR powDir,DWORD instId)
{          
   HANDLE h;
   LPINSTDATA lp;
   char cmd[1000];

   /* remember DDEML instance handle */
   ddeInstId=instId;

   lstrcpy((LPSTR)homeDir,powDir);
   DownStr((LPSTR)homeDir);
   if ((*homeDir) && (homeDir[lstrlen(homeDir)-1]!='\\'))
       lstrcat(homeDir,"\\");

   /* add default tools */
   DdeSendCommand("pow","pow","addtool Oberon-2 Win32 API,winhlp32.exe, ,%d\\oberon-2\\winapi\\win32.hlp,1,0,0,0");

   sprintf(cmd,"addtool Oberon-2 Symbolfile Browser,%sOberon-2\\Tools\\SymbolFileBrowser.exe, , ,1,0,0,0",homeDir);
   DdeSendCommand("pow","pow",cmd);

   sprintf(cmd,"addtool Oberon-2 Report Generator,%sOberon-2\\Tools\\Report.exe, , ,1,0,0,0",homeDir);
   DdeSendCommand("pow","pow",cmd);
    
   if ((h=GlobalAlloc(GMEM_MOVEABLE,sizeof(INSTDATA)))!=0) {
     	lp=(LPINSTDATA)GlobalLock(h);
       lp->exports=0;
	   lp->imports=0;
	   lp->dllModules=0;
	   lp->lSwitches=0;
	   lp->cSwitches=0;
	   lp->heap=16000;
	   lp->stack=16000;
	   lp->baseAdr=0;
	   *(lp->objDir)=0;
	   *(lp->prjDir)=0;
	   *(lp->prjFil)=0;
	   *(lp->entrySym)=0;
       lp->stackSize=0;
       lp->ignoreLink=FALSE;
	   lstrcpy((LPSTR)lp->prjDir,(LPSTR)homeDir);
	   NewProject(h);       
	   GlobalUnlock(h);
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

BOOL FAR PASCAL _export CompAboutDlgProc (HWND hwnd,WORD msg,WORD wParam,LONG lParam)
{
   switch (msg) {

   case WM_ACTIVATE:

	   return FALSE;

   case WM_PAINT: {

       RECT r;
       HDC dc,memdc;
	   HBITMAP hmap,oldmap;
	   PAINTSTRUCT ps;

	   hmap=LoadBitmap(hInst,MAKEINTRESOURCE(IDB_ABOUT));
	   if (hmap) {
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

   case WM_INITDIALOG: {
			      
	   int fil,i;
	   LPSTR src,dst;
	   char num[256],vers[256],year[256],link[256],buf[256],licence[256];                      
		 
	   /* read licence information */
	   lstrcpy((LPSTR)licence,(LPSTR)homeDir);
	   lstrcat((LPSTR)licence,"oberon2.lic");
	   if ((fil=_lopen((LPSTR)licence,OF_READ))!=-1) {
        _lread(fil,(LPSTR)buf,sizeof(buf));
	      _lclose(fil);         
	      dst=(LPSTR)licence;
	      src=(LPSTR)buf;
	      i=0;
	      while (*src && i<50) {
      		if (*src>=' ') *dst++=*src;
            if (*src=='\n') {
               if (i<35) *dst++=' ';
               else i=50;
		      }                    
   		   src++;
	   	   i++;
	      }       
   	   *dst=0;
      }    
	   else 
	      lstrcpy((LPSTR)licence,"No licence information!");
	
      /*
      	IF NO PROCEDURE GETCOMPILERVERSION AVAILABLE: USE A CONSTANT!
	      (VERSION AND YEAR INFO MUST BE SEPERATED BY "//"!)
   	   src=(LPSTR)compilerVersion;
	      dst=(LPSTR)vers;
	      do  
   	       *dst++=*src++; 
      	while (*src!='\\'); 
	      src++;
      	*dst=0;
	      lstrcpy((LPSTR)year,src);
      */                                    
	   lstrcpy((LPSTR)vers,"Version ");
   	GetCompilerVersion((LPSTR)num); 
	   lstrcat((LPSTR)vers,(LPSTR)num);
   	lstrcpy((LPSTR)year,"Copyright (c) 1998 by");
	   		   
   	GetLinkVersion((LPSTR)&link);                  
	   
   	SetWindowText(GetDlgItem(hwnd,IDD_ABOUTCOMPVERS),(LPSTR)vers);
	   SetWindowText(GetDlgItem(hwnd,IDD_ABOUTCOMPYEAR),(LPSTR)year);
   	SetWindowText(GetDlgItem(hwnd,IDD_ABOUTINTERVERS),(LPSTR)interfaceVersion);
	   SetWindowText(GetDlgItem(hwnd,IDD_ABOUTLINKVERS),(LPSTR)link);
   	SetWindowText(GetDlgItem(hwnd,IDD_ABOUTINTERYEAR),(LPSTR)interfaceYear);
      /*        
   	   SetWindowText(GetDlgItem(hwnd,IDD_ABOUTLICENCE),(LPSTR)licence);
      */
	   }
   	break;

   case WM_COMMAND:

      switch (wParam) {

      	case IDOK:
	      case IDCANCEL:

	         EndDialog(hwnd,0);
            break;

      	default:

            return FALSE;
   	}
	   break;

   case WM_SETFONT:

	   break;

   default:

   	return FALSE;
   }
   return TRUE;
}

/**********************
 * start about dialog *
 **********************/

void FAR PASCAL _export AboutCompiler (HANDLE hData,HWND hwnd)
{
    FARPROC lpMsg;
    int ret;

    lpMsg=MakeProcInstance(CompAboutDlgProc,hInst);
    ret=DialogBox(hInst,IDD_COMPABOUT,hwnd,lpMsg);
    FreeProcInstance(lpMsg);
}

/**********************************************************
 * initialize a compiler switch button with project value *
 **********************************************************/

void InitCOption (HWND hdlg,WORD id,int val,int cSw)
{
   SendDlgItemMessage(hdlg,id,BM_SETCHECK,(cSw & val)!=0,0);
}

/**********************************************
 * set compiler option with value from button *
 **********************************************/

void GetCOption (HWND hdlg,WORD id,int val,LPINT cSw)
{
   *cSw=*cSw&(~val);
   if (SendDlgItemMessage(hdlg,id,BM_GETCHECK,0,0))
	*cSw=*cSw|val;
}

/*****************************************************
 * let the user choose the compiler switches to use; *
 * the setup is local to the project!                *
 *****************************************************/

BOOL FAR PASCAL _export CompOptDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{                
   static LPINSTDATA lpInst; 
    
   switch(msg) {

   case WM_INITDIALOG:
	   
   	lpInst=(LPINSTDATA)lParam;   

   	/* clear sensitive compiler option flags */
	   lpInst->cSwitches&=(~CSW_LISTIMPORT);
   	lpInst->cSwitches&=(~CSW_BROWSESYM);
						      
	   InitCOption(hdlg,IDD_COPTOVER,CSW_OVERFLOW,lpInst->cSwitches);
   	InitCOption(hdlg,IDD_COPTTYPE,CSW_TYPE,lpInst->cSwitches);
	   InitCOption(hdlg,IDD_COPTINDEX,CSW_INDEX,lpInst->cSwitches);
	   InitCOption(hdlg,IDD_COPTRANGE,CSW_RANGE,lpInst->cSwitches);
	   InitCOption(hdlg,IDD_COPTPTRINIT,CSW_PTRINIT,lpInst->cSwitches);
	   InitCOption(hdlg,IDD_COPTASSERTEVAL,CSW_ASSERTEVAL,lpInst->cSwitches);
	   InitCOption(hdlg,IDD_COPTNILCHECK,CSW_NILCHECK,lpInst->cSwitches);

      #ifdef _WIN32
         if ((lpInst->cSwitches)&CSW_DEBUGINFO)
            SendDlgItemMessage(hdlg,IDD_COPTDEBUGCV,BM_SETCHECK,BST_CHECKED,0);
         else if ((lpInst->cSwitches)&CSW_DEBUGCOFF)
            SendDlgItemMessage(hdlg,IDD_COPTDEBUGCOFF,BM_SETCHECK,BST_CHECKED,0);
         else if ((lpInst->cSwitches)&CSW_DEBUGCV5)
            SendDlgItemMessage(hdlg,IDD_COPTDEBUGCV5,BM_SETCHECK,BST_CHECKED,0);
         else
            SendDlgItemMessage(hdlg,IDD_COPTDEBUGNONE,BM_SETCHECK,BST_CHECKED,0);
      #else
      	InitCOption(hdlg,IDD_COPTDEBUG,CSW_DEBUGINFO,lpInst->cSwitches);
	      InitCOption(hdlg,IDD_COPTSMART,CSW_SMART,lpInst->cSwitches);
      #endif
	   break;

   case WM_COMMAND:

#ifdef _WIN32
      switch (LOWORD(wParam)) {
#else
      switch (wParam) {
#endif

	   case IDOK:

		   GetCOption(hdlg,IDD_COPTOVER,CSW_OVERFLOW,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTTYPE,CSW_TYPE,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTINDEX,CSW_INDEX,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTRANGE,CSW_RANGE,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTPTRINIT,CSW_PTRINIT,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTASSERTEVAL,CSW_ASSERTEVAL,(LPINT)&(lpInst->cSwitches));
		   GetCOption(hdlg,IDD_COPTNILCHECK,CSW_NILCHECK,(LPINT)&(lpInst->cSwitches));

         #ifdef _WIN32
            (lpInst->cSwitches)&=~CSW_DEBUGINFO;
            (lpInst->cSwitches)&=~CSW_DEBUGCOFF;
            (lpInst->cSwitches)&=~CSW_DEBUGCV5;

            if (SendDlgItemMessage(hdlg,IDD_COPTDEBUGCV,BM_GETCHECK,0,0)==BST_CHECKED)
               (lpInst->cSwitches)|=CSW_DEBUGINFO;
            else if (SendDlgItemMessage(hdlg,IDD_COPTDEBUGCOFF,BM_GETCHECK,0,0)==BST_CHECKED)
               (lpInst->cSwitches)|=CSW_DEBUGCOFF;
            else if (SendDlgItemMessage(hdlg,IDD_COPTDEBUGCV5,BM_GETCHECK,0,0)==BST_CHECKED)
               (lpInst->cSwitches)|=CSW_DEBUGCV5;
         #else
		      GetCOption(hdlg,IDD_COPTSMART,CSW_SMART,(LPINT)&(lpInst->cSwitches));
            GetCOption(hdlg,IDD_COPTDEBUG,CSW_DEBUGINFO,(LPINT)&(lpInst->cSwitches));
         #endif
   		/* fall through! */

	   case IDCANCEL:

		   EndDialog(hdlg,(wParam==IDOK));
		   break;

      case IDD_HELP: {

		   char buf[256];        

		   /* generate helpfile-id ("Oberon*.hlp" in pow-directory) */
		   lstrcpy(buf,homeDir);
		   if ((*buf) && (buf[lstrlen(buf)-1]!='\\'))
		      lstrcat(buf,"\\");
		   lstrcat(buf,HELPFILE);
		   WinHelp(hdlg,(LPSTR)buf,HELP_PARTIALKEY,(DWORD)(LPSTR)"Compiler");
		   }
		   break;
	     
      case IDD_COPTSMART: {
	    
         #ifdef _WIN32
            if (HIWORD(wParam)==BN_CLICKED) {         
         #else
            if (HIWORD(lParam)==BN_CLICKED) {
         #endif
               HWND hsmart=GetDlgItem(hdlg,IDD_COPTSMART);
		         if ((SendMessage(hsmart,BM_GETCHECK,0,0)==0) &&
                  (MessageBox(hdlg,"Really switch off smart callbacks? (should be enabled)","Message",MB_YESNO|MB_ICONQUESTION)==IDNO)) {
			         SendMessage(hsmart,BM_SETCHECK,1,0);
			         return TRUE;
		         }
		      }
		   }
		   break;

	   }
	   break;

   default:

	   return FALSE;
   }
   return TRUE;
}

/********************************
 * start compile options dialog *
 ********************************/

BOOL FAR PASCAL _export CompileOptions (HANDLE hData,HWND hwnd)
{
   int ret;
   FARPROC lpMsg;                                     
   LPINSTDATA lpInst;
						     
   lpInst=(LPINSTDATA)GlobalLock(hData);                                                 
   lpMsg=MakeProcInstance(CompOptDlgProc,hInst);
   ret=DialogBoxParam(hInst,IDD_COMPILEROPT,hwnd,lpMsg,(long)lpInst);
   FreeProcInstance(lpMsg); 
   GlobalUnlock(hData);
   return ret;
}

/***************************
 * error callback function *
 ***************************/

void FAR PASCAL _export ErrorCallback (int num,int line,int col,BOOL warn,LPSTR txt)
{
   /* pass message to pow! */
   (*(CompErr*)errMsg)(num,line,col,warn,(LPSTR)txt);
}

/************************************
 * resource error callback function *
 ************************************/

void FAR PASCAL _export ResourceError (int num,int col,int line,BOOL warn,LPSTR txt)
{
   (*(CompErr*)errMsg)(num,line,col,warn,txt);
}

/********************************************************************
 * check library for Oberon-2 modules and tell compiler their names *
 ********************************************************************/

void SearchLibraryForModules (LPSTR lib)
{
	BOOL done;
	HFILE fil;
	long len;
	ULONG symbols;
	LPSTR lp;
	char c;
	char buf[50000];

	done=TRUE;
	if ((fil=_lopen((LPSTR)lib,OF_READ))!=HFILE_ERROR) {
      len=(long)_lread(fil,(LPSTR)buf,sizeof(buf));
		// ist this a library? (check signature)
		if (strncmp(buf,"!<arch>\n",strlen("!<arch>\n"))==0) {
			lp=buf+strlen("!<arch>\n");
			// is this the first linker member part of the library?
			if (*lp=='/') {
				// skip archive member header
				lp+=60; 

				// get number of symbols (convert to big-endian)
				c=*lp; *lp=*(lp+3); *(lp+3)=c;
				c=*(lp+1); *(lp+1)=*(lp+2); *(lp+2)=c;
				symbols=*(ULONG *)lp;

				// skip symbol offsets
				lp+=4*(symbols+1);

				// check symbol strings for @@MODNAME entries (made by Pow! linker)
				while (done && symbols && (lp-buf < len)) {
					if (*lp=='@' && *(lp+1)=='@') {
						// found an Oberon-2 module -> notify compiler
						lp+=2;
						AddDLLModule(lp,(long)0,strlen(lp),(LPINT)&done);
						if (!done)
							MessageBox(0,"Compiler did not accept DLL module name!","Warning",MB_OK|MB_ICONEXCLAMATION);
					}
					// go to next symbol
					while (*lp && (lp-buf<len)) lp++;
					if (!*lp) lp++;
					symbols--;
				}
			}
		}
	   _lclose(fil);         
	}
}

/***********************************
 * call the compiler (oberon2.dll) *
 ***********************************/

BOOL CallCompiler (LPINSTDATA lpInst,LPSTR file,FARPROC err,FARPROC msg,FARPROC dep,long opt,HWND fromWnd,FARPROC firstProc,FARPROC nextProc,FARPROC openProc,FARPROC readProc,FARPROC closeProc,HANDLE flist)
{
   int i,n,ret,done;
   COMP comp;          
   BOOL resource;
   LPSTR dst,st,p;
   char txt[512],mod[512],name[512],drv[_MAX_DRIVE],dir[_MAX_DIR],fname[_MAX_FNAME],ext[_MAX_EXT];
				   
   if (!ObjectdirValid(lpInst)) {
	   MessageBox(0,"Object directory is invalid!","Error",MB_OK|MB_ICONEXCLAMATION);
	   return FALSE;
   }                               
				   
   /* file name */
   lstrcpy((LPSTR)&(comp.fileName),file);

   /* source buffer and len */
   comp.fromWnd=fromWnd;
   comp.firstProc=firstProc;
   comp.nextProc=nextProc;
   comp.openProc=openProc;
   comp.readProc=readProc;
   comp.closeProc=closeProc;

   /* get module name from source file id */
   st=(LPSTR)file+lstrlen(file);
   dst=(LPSTR)mod;
   while (*st!='\\') st--;
   st++;
   while (*st!='.') *dst++=*st++;
   *dst=0;
   resource=(stricmp(st,".rc")==0);
   if (resource && opt&CSW_LISTIMPORT)
      return TRUE; /* resource files dont have imported modules */

   /* make object directory name */   
   if ((*lpInst->objDir) && !resource)
      lstrcpy((LPSTR)txt,(LPSTR)lpInst->objDir);
   else
   	lstrcpy((LPSTR)txt,(LPSTR)lpInst->prjDir);
						
   /* make license file name */
   lstrcpy((LPSTR)&(comp.licName),(LPSTR)homeDir);
   lstrcat((LPSTR)&(comp.licName),"oberon2.lic");
						
   /* write temp file name */
   lstrcpy((LPSTR)&(comp.tmpName),(LPSTR)txt);
   lstrcat((LPSTR)&(comp.tmpName),"_oberon.tmp");

   /* write directory for target symbol file (same as obj) */
   lstrcpy((LPSTR)&(comp.objDir),(LPSTR)txt);

   /* make object file name */
   lstrcpy((LPSTR)&(comp.objName),(LPSTR)txt);
   lstrcat((LPSTR)&(comp.objName),(LPSTR)mod);

   if (resource) {
      #ifndef _WIN32
	      lstrcat((LPSTR)&(comp.objName),".res");
	      err=MakeProcInstance((FARPROC)ResourceError,hInst);
	      CompileRes((LPSTR)&(comp.fileName),(LPSTR)&comp.objName,err,msg);
	      FreeProcInstance(err); 
      #endif
	   return TRUE;
   }    

   lstrcat((LPSTR)&(comp.objName),".obj");
					      
   /* collect possible symbol directories for objects and libraries */
   st=(LPSTR)&(comp.symDirs);
   *st=0;
   n=CountList(flist);
   for (i=1;i<=n;i++) {
	   GetElem(flist,i,(long)(LPSTR)name);
	   p=(LPSTR)name+lstrlen(name)-3;
	   if (!stricmp(p,"lib")) {
         while (p>(LPSTR)name && *p!='\\') p--;
	      *(p+1)=0;
	      if (lstrlen((LPSTR)name)+st-(LPSTR)&comp.symDirs<sizeof(comp.symDirs)-3) {
	         lstrcat(st,name);
	         while (*st) st++;
	         st++;
	         *st=0;
	      }  
	   }    
   }

   for (i=1;i<=n;i++) {
	   GetElem(flist,i,(long)(LPSTR)name);
	   p=(LPSTR)name+lstrlen(name)-3;
	   if (!stricmp(p,"obj")) {
	      while (p>(LPSTR)name && *p!='\\') p--;
	      *(p+1)=0;
	      if (lstrlen((LPSTR)name)+st-(LPSTR)&comp.symDirs<sizeof(comp.symDirs)-3) {
	         lstrcat(st,name);
	         while (*st) st++;
	         st++;
	         *st=0;
	      }  
	   }    
   }
   *st++=0;
   *st=1;                                          
					      
   /* compile options */
   comp.options=opt;

   /* callback functions */
   comp.errProc=err;
   comp.depProc=dep;

#ifdef _WIN32
	/* notify compiler of modules from dlls */
	if (!dep) {
		ClearDLLModules();
		done=TRUE;
		n=CountList(flist);
		i=1;       
		while (done && (i<=n)) {
			// check all files in project
			done=GetElem(flist,i,(long)(LPSTR)mod);
      if (done)
      {
			  _splitpath(mod,drv,dir,fname,ext);
			  // file is a library?
			  if (stricmp(ext,".lib")==0) {
				  // yes -> search first linker member entry for module names
				  SearchLibraryForModules(mod);
        }
			  i++;
      }
		}        
	}
#endif

   /* execute compiler */
   ret=Oberon2((LPSTR)&comp);
   return ret;
}

/*******************************************
 * compile a single file                   *
 * (returns true if interface has changed) *
 *******************************************/

BOOL FAR PASCAL _export CompileFile (HANDLE hData,LPSTR file,FARPROC msg,FARPROC err,HWND fromWnd,FARPROC firstProc,FARPROC nextProc,FARPROC openProc,FARPROC readProc,FARPROC closeProc,HANDLE flist)
{
   BOOL ret;
   FARPROC error;
   char txt[256];                                
   LPINSTDATA lpInst;
		      
   lpInst=(LPINSTDATA)GlobalLock(hData);                  
		      
   /* start message */
   lstrcpy((LPSTR)txt,(LPSTR)"Compile ");
   lstrcat((LPSTR)txt,file);
   (*(CompMsg *)msg)((LPSTR)txt);

   errMsg=err;
   error=MakeProcInstance((FARPROC)ErrorCallback,hInst);

   /* clear sensitive compiler option flags */
   lpInst->cSwitches&=(~CSW_LISTIMPORT);
   lpInst->cSwitches&=(~CSW_BROWSESYM);
    
   ret=CallCompiler(lpInst,file,error,msg,NULL,lpInst->cSwitches|CSW_NEWSYMFILE,fromWnd,firstProc,nextProc,openProc,readProc,closeProc,flist);
   FreeProcInstance(error); 
    
   GlobalUnlock(hData);
    
   return ret;
}

/*********************************
 * dummy error callback function *
 *********************************/

void FAR PASCAL _export IgnoreErrors (int num,int line,int col,BOOL warn,LPSTR txt)
{
}

/**********************************
 * find out dependences of module *
 **********************************/

void FAR PASCAL _export CheckDepend (HANDLE hData,LPSTR file,FARPROC depends,HWND fromWnd,FARPROC firstProc,FARPROC nextProc,FARPROC openProc,FARPROC readProc,FARPROC closeProc,HANDLE flist)
{
   FARPROC errors;
   LPINSTDATA lpInst;
		      
   lpInst=(LPINSTDATA)GlobalLock(hData);                  
		      
   /* ignore errors found while looking for dependences */
   errors=MakeProcInstance((FARPROC)IgnoreErrors,hInst);
   CallCompiler(lpInst,file,errors,NULL,depends,(long)CSW_LISTIMPORT,fromWnd,firstProc,nextProc,openProc,readProc,closeProc,flist);
   FreeProcInstance(errors);
    
   GlobalUnlock(hData);
}

/***********************************
 * check if file was compiled ever *
 ***********************************/

BOOL FAR PASCAL _export FileWasCompiled (HANDLE hData,LPSTR file)
{
   LPSTR dst,st;
   char txt[255];                 
   int f;                                            
   LPINSTDATA lpInst;
		      
   lpInst=(LPINSTDATA)GlobalLock(hData);                  
		      
   /* get module name from source file id */
   st=file+lstrlen(file);
   while (*st!='\\') st--;
   st++;

   /* make object directory name */
   if (stricmp((LPSTR)st,".rc")==0 || *lpInst->objDir==0)
	   lstrcpy((LPSTR)txt,(LPSTR)lpInst->prjDir);
   else
   	lstrcpy((LPSTR)txt,(LPSTR)lpInst->objDir);

   /* make object file name */
   dst=(LPSTR)txt+lstrlen(txt);
   while (*st!='.') *dst++=*st++;
   *dst=0;                                            
		 
   /* is this an oberon or an resource source? */             
   if (!stricmp((LPSTR)st,".rc"))     
	   lstrcat((LPSTR)txt,".res");
   else    
	   lstrcat((LPSTR)txt,".obj");

   /* see if object file exists */
   if ((f=_lopen((LPSTR)txt,OF_READ))!=-1) 
	   _lclose(f);                       
	
   GlobalUnlock(hData);
	
   return f!=-1;
}

/*************************************************************************
 *                                                                       *
 *                    L i n k e r - I n t e r f a c e                    *
 *                                                                       *
 *************************************************************************/

/********************************************************
 * initialize a linker switch button with project value *
 ********************************************************/

void InitLOption (HWND hdlg,WORD id,int val,int lSw)
{
   SendDlgItemMessage(hdlg,id,BM_SETCHECK,(lSw & val)!=0,0);
}

/********************************************
 * set linker option with value from button *
 ********************************************/

void GetLOption (HWND hdlg,WORD id,int val,LPINT lSw)
{
   *lSw=*lSw&(~val);
   if (SendDlgItemMessage(hdlg,id,BM_GETCHECK,0,0))
	*lSw=*lSw|val;
}

/***************************
 * link options dialog box *
 ***************************/

BOOL FAR PASCAL _export LinkOptDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{                  
   static LPINSTDATA lpInst;

   switch(msg) {

      case WM_INITDIALOG: {

          BOOL state;
          char buf[50];
			     
	      lpInst=(LPINSTDATA)lParam;
			     
	      /* projects export list */
	      ListToLBox(lpInst->exports,GetDlgItem(hdlg,IDD_LOPTEXPLIST));

	      /* set flags */
	      InitLOption(hdlg,IDD_LOPTDEBUG,LSW_DEBUG,lpInst->lSwitches);
	      InitLOption(hdlg,IDD_LOPTDYNAMICRTS,LSW_DYNAMICRTS,lpInst->lSwitches);
	      InitLOption(hdlg,IDD_LOPTGARBAGE,LSW_GARBAGE,lpInst->lSwitches);

         #ifdef _WIN32
            if (lpInst->ignoreLink)
                SendDlgItemMessage(hdlg,IDD_LOPTNOLINK,BM_SETCHECK,TRUE,0);

            if (lpInst->lSwitches & LSW_DLL)
                SendDlgItemMessage(hdlg,IDD_LOPTDLL,BM_SETCHECK,TRUE,0);
            else if (lpInst->lSwitches & LSW_CONSOLE)
                SendDlgItemMessage(hdlg,IDD_LOPTCONSOLE,BM_SETCHECK,TRUE,0);
            else
                SendDlgItemMessage(hdlg,IDD_LOPTWIN32,BM_SETCHECK,TRUE,0);

            InitLOption(hdlg,IDD_LOPTNORTS,LSW_NORTS,lpInst->lSwitches);
            if (!SendDlgItemMessage(hdlg,IDD_LOPTDYNAMICRTS,BM_GETCHECK,0,0) &&
                !SendDlgItemMessage(hdlg,IDD_LOPTNORTS,BM_GETCHECK,0,0))
                SendDlgItemMessage(hdlg,IDD_LOPTSTATICRTS,BM_SETCHECK,TRUE,0);

			if (lpInst->baseAdr) {
				sprintf(buf,"0x%lx",lpInst->baseAdr);
                SetWindowText(GetDlgItem(hdlg,IDD_LOPTBASE),(LPSTR)buf);
			}

            if (*(lpInst->entrySym))
                SetWindowText(GetDlgItem(hdlg,IDD_LOPTENTRY),lpInst->entrySym);

			if (lpInst->stackSize) {
				sprintf(buf,"0x%lx",lpInst->stackSize);
                SetWindowText(GetDlgItem(hdlg,IDD_LOPTSTACK),(LPSTR)buf);
			}

  	        state=(SendDlgItemMessage(hdlg,IDD_LOPTNORTS,BM_GETCHECK,0,0)==BST_CHECKED);
            EnableWindow(GetDlgItem(hdlg,IDD_LOPTGARBAGE),!state);
         #else
	        InitLOption(hdlg,IDD_LOPTDLL,LSW_DLL,lpInst->lSwitches);
            InitLOption(hdlg,IDD_LOPTCASE,LSW_CASE,lpInst->lSwitches);

	         /* stack and heap size */
	         MakeStr(lpInst->stack,(LPSTR)buf);
	         SetWindowText(GetDlgItem(hdlg,IDD_LOPTSTSIZE),(LPSTR)buf);
	         MakeStr(lpInst->heap,(LPSTR)buf);
	         SetWindowText(GetDlgItem(hdlg,IDD_LOPTHESIZE),(LPSTR)buf);
         #endif
	      break;
	      }

      case WM_COMMAND:

         #ifdef _WIN32
            switch (LOWORD(wParam)) {
         #else
            switch (wParam) {
         #endif

               case IDOK: {

                    char buf[255];
                    char *convStoppedAt;
			  
		            /* get new export list */
		            LBoxToList(GetDlgItem(hdlg,IDD_LOPTEXPLIST),(LPHANDLE)&(lpInst->exports));

		            /* get flags */
                    GetLOption(hdlg,IDD_LOPTDLL,LSW_DLL,(LPINT)&lpInst->lSwitches);
		            GetLOption(hdlg,IDD_LOPTDEBUG,LSW_DEBUG,(LPINT)&lpInst->lSwitches);
		            GetLOption(hdlg,IDD_LOPTDYNAMICRTS,LSW_DYNAMICRTS,(LPINT)&lpInst->lSwitches);
		            GetLOption(hdlg,IDD_LOPTGARBAGE,LSW_GARBAGE,(LPINT)&lpInst->lSwitches);

                  #ifdef _WIN32
		            GetLOption(hdlg,IDD_LOPTCONSOLE,LSW_CONSOLE,(LPINT)&lpInst->lSwitches);
   		            GetLOption(hdlg,IDD_LOPTNORTS,LSW_NORTS,(LPINT)&lpInst->lSwitches);

                    /* base address */
                    GetWindowText(GetDlgItem(hdlg,IDD_LOPTBASE),(LPSTR)buf,sizeof(buf));
                    if (*buf) {
						__try {
                          lpInst->baseAdr=strtoul(buf,&convStoppedAt,16);
						} __except (EXCEPTION_EXECUTE_HANDLER) {
                          lpInst->baseAdr=0;
						}
					} else
                        lpInst->baseAdr=0;

                    /* entry symbol */
                    GetWindowText(GetDlgItem(hdlg,IDD_LOPTENTRY),lpInst->entrySym,sizeof(lpInst->entrySym));

                    /* stack size */
                    GetWindowText(GetDlgItem(hdlg,IDD_LOPTSTACK),(LPSTR)buf,sizeof(buf));
                    if (*buf)
						__try {
                          lpInst->stackSize=strtoul(buf,&convStoppedAt,16);
						} __except (EXCEPTION_EXECUTE_HANDLER) {
                          lpInst->stackSize=0;
						}
                    else
                        lpInst->stackSize=0;

                    /* ignore link flag */
                    lpInst->ignoreLink=(SendDlgItemMessage(hdlg,IDD_LOPTNOLINK,BM_GETCHECK,0,0)==BST_CHECKED);

                  #else
		               GetLOption(hdlg,IDD_LOPTCASE,LSW_CASE,(LPINT)&lpInst->lSwitches);

                     /* stack and heap size */
		               GetWindowText(GetDlgItem(hdlg,IDD_LOPTSTSIZE),(LPSTR)buf,sizeof(buf));
		               lpInst->stack=MakeLon((LPSTR)buf);
		               GetWindowText(GetDlgItem(hdlg,IDD_LOPTHESIZE),(LPSTR)buf,sizeof(buf));
		               lpInst->heap=MakeLon((LPSTR)buf);
                  #endif

		            if ((lpInst->lSwitches&LSW_GARBAGE) && !(lpInst->lSwitches&LSW_DYNAMICRTS) && !(lpInst->lSwitches&LSW_NORTS)) {
		                if (MessageBox(hdlg,"Use DLL runtime-system? (should be enabled for garbage collection)","Message",MB_YESNO|MB_ICONQUESTION)==IDYES) {
		                   lpInst->lSwitches&=~LSW_DYNAMICRTS;
		                   lpInst->lSwitches|=LSW_DYNAMICRTS;
                        }
		            }

                  #ifndef _WIN32
		               if ((lpInst->lSwitches&LSW_GARBAGE) && lpInst->stack<32768) {
		                  lpInst->stack=32768;
		                  MessageBox(hdlg,"Stack size corrected to 32 kByte (for garbage collection)!","Message",MB_OK|MB_ICONINFORMATION);
		                  if (lpInst->stack+lpInst->heap>64000)
		                     lpInst->heap=64000-lpInst->stack;
		               }
                  #endif
		            
		            }
		            /* FALL THROUGH! */

	   case IDCANCEL:

		   EndDialog(hdlg,(wParam==IDOK));
		   break;

      case IDD_LOPTEXPADD: {

		   char buf[255];

		   if ((GetWindowText(GetDlgItem(hdlg,IDD_LOPTFEDIT),(LPSTR)buf,sizeof(buf))!=0) &&
		       (SendDlgItemMessage(hdlg,IDD_LOPTEXPLIST,LB_FINDSTRINGEXACT,(WORD)-1,(long)(LPSTR)buf)==LB_ERR))
		       SendDlgItemMessage(hdlg,IDD_LOPTEXPLIST,LB_ADDSTRING,0,(long)(LPSTR)buf);
		   break;
		   }

      case IDD_LOPTEXPDEL: {

		   int i;

		   if ((i=(int)SendDlgItemMessage(hdlg,IDD_LOPTEXPLIST,LB_GETCURSEL,0,0))!=LB_ERR)
		       SendDlgItemMessage(hdlg,IDD_LOPTEXPLIST,LB_DELETESTRING,i,0);
		   break;
		   }

	   case IDD_LOPTMODULEADD: {

		   char buf[MAXID];

		   if ((GetWindowText(GetDlgItem(hdlg,IDD_LOPTMODULE),(LPSTR)buf,MAXID)!=0) &&
		       (SendDlgItemMessage(hdlg,IDD_LOPTMODULELIST,LB_FINDSTRINGEXACT,(WORD)-1,(long)(LPSTR)buf)==LB_ERR))
		       SendDlgItemMessage(hdlg,IDD_LOPTMODULELIST,LB_ADDSTRING,0,(long)(LPSTR)buf);
		   break;
		   }

	   case IDD_LOPTMODULEDEL: {

		   int i;

		   if ((i=(int)SendDlgItemMessage(hdlg,IDD_LOPTMODULELIST,LB_GETCURSEL,0,0))!=LB_ERR)
		       SendDlgItemMessage(hdlg,IDD_LOPTMODULELIST,LB_DELETESTRING,i,0);
		   break;
		   }

#ifdef _WIN32
       case IDD_LOPTSTATICRTS:
       case IDD_LOPTDYNAMICRTS:
       case IDD_LOPTNORTS: {
           BOOL state;
		   state=(SendDlgItemMessage(hdlg,IDD_LOPTNORTS,BM_GETCHECK,0,0)==BST_CHECKED);
           EnableWindow(GetDlgItem(hdlg,IDD_LOPTGARBAGE),!state);
           break;
           }
#endif
       
	   case IDD_HELP: {

		   char buf[255];        

		   /* generate helpfile-id ("Oberon*.hlp" in pow-directory) */
		   lstrcpy(buf,homeDir);
		   if ((*buf) && (buf[lstrlen(buf)-1]!='\\'))
		      lstrcat(buf,"\\");
		   lstrcat(buf,HELPFILE);
		   WinHelp(hdlg,(LPSTR)buf,HELP_PARTIALKEY,(DWORD)(LPSTR)"Linker");
		   }
		   break;
	   }
	   break;

   default:

   	return FALSE;
   }
   return TRUE;
}

/*******************************
 * start linker options dialog *
 *******************************/

BOOL FAR PASCAL _export LinkerOptions (HANDLE hData,HWND hwnd)
{
   int ret;
   FARPROC lpMsg;  
   LPINSTDATA lpInst;

   lpInst=(LPINSTDATA)GlobalLock(hData);
    
   lpMsg=MakeProcInstance(LinkOptDlgProc,hInst);
   ret=DialogBoxParam(hInst,IDD_LINKEROPT,hwnd,lpMsg,(long)lpInst);
   FreeProcInstance(lpMsg);
    
   GlobalUnlock(hData);
    
   return ret;
}

/**************
 * add string *
 **************/

void AddString (LPHANDLE h,LPSTR far *lp,LPSTR src)
{
   if (!*h) {
	   *h=GlobalAlloc(GMEM_MOVEABLE,lstrlen(src)+1);
	   if (*h) {
         *lp=GlobalLock(*h);
	      lstrcpy(*lp,src);
	   }
   }
   else {
	   GlobalUnlock(*h);
	   *h=GlobalReAlloc(*h,GlobalSize(*h)+lstrlen(src)+2,GMEM_MOVEABLE);
	   if (*h) {
	      *lp=GlobalLock(*h);
          #ifdef _WIN32
    	      lstrcat(*lp,"\001"); /* there might be errors with spaces in file names */
          #else
    	      lstrcat(*lp," ");
          #endif
	      lstrcat(*lp,src);
	   }
   }
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
 
/*************************************
 * read module name from symbol file *
 *************************************/ 
 
void GetModuleName (LPINSTDATA lpInst,LPSTR file,LPSTR modName)
{         
   int n;
   HFILE fh;
   unsigned char buf[255];
    
   if (*lpInst->objDir)
   	lstrcpy((LPSTR)buf,(LPSTR)lpInst->objDir);
   else
	   lstrcpy((LPSTR)buf,(LPSTR)lpInst->prjDir);

   if (buf[lstrlen((LPSTR)buf)-1]!='\\')
	   lstrcat((LPSTR)buf,"\\");

   lstrcat((LPSTR)buf,file);
   lstrcat((LPSTR)buf,".sym");
				 
   *modName=0;
   if (fh=_lopen(buf,OF_READ)) {
   	n=_lread(fh,buf,sizeof(buf));

	   if (n>6) {
	      if (buf[0]==(unsigned char)0xf7) {
   		   /* old symbol file (compiler <= 1.17 -> copy name */
	   	   lstrcpy(modName,buf+6);
	      }
	      else if (buf[0]=='S' && buf[1]=='Y' && buf[2]=='M' && buf[3]==0x1a && n>13) {
		      /* new symbol file (compiler > 1.17 -> copy name */
		      lstrcpy(modName,buf+13);
	      }
      }

	   _lclose(fh);
   }
}

/****************
 * link project *
 ****************/

int FAR PASCAL _export Link (HANDLE hData,LPSTR file,HANDLE flist,FARPROC msg)
{
   LPSTR p,libname;
   HCURSOR oldC;
   int i,n,ret,libMainExported,switches;
   char stub[255],exe[255],name[255],buf[255],buf2[255],buf3[255],buf4[255],modInit[255],modGData[255];
   HANDLE hobj,hlib,hres,hexp,himp;
   LPSTR obj,lib,res,exp,imp;            
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   if (lpInst->ignoreLink) {
       (*(CompMsg *)msg)("Warning: linking suppressed by linker option.");
       ret=TRUE;
   }
   else {
       /* set cursor shape to hourglass */
       oldC=SetCursor(LoadCursor(0,IDC_WAIT));

       /* stub program */
       lstrcpy((LPSTR)stub,(LPSTR)homeDir);
       if ((*stub) && (stub[lstrlen(stub)-1]!='\\')) lstrcat(stub,"\\");
       lstrcat((LPSTR)stub,"winstub.exe");

       /* executable name */
       lstrcpy((LPSTR)exe,(LPSTR)lpInst->prjFil);
       p=(LPSTR)exe+lstrlen((LPSTR)exe)-1;
       while (*p!='.') p--;
       *++p=0;       
       if (lpInst->lSwitches&LSW_DLL)
   	    lstrcat((LPSTR)exe,"dll");
       else
	       lstrcat((LPSTR)exe,"exe");

       /* initialize lists */
       hobj=hlib=hres=hexp=himp=0;
       obj=lib=res=exp=imp=0;

       /* standard library to add (exe or dll) */
       lstrcpy((LPSTR)buf,(LPSTR)homeDir);
       if ((*buf) && (buf[lstrlen(buf)-1]!='\\')) lstrcat(buf,"\\");

       lstrcpy((LPSTR)buf2,(LPSTR)buf);
       lstrcpy((LPSTR)buf3,(LPSTR)buf);
       lstrcpy((LPSTR)buf4,(LPSTR)buf);

       /* automatically add some files */
       #ifdef _WIN32
          /* add static or dynamic runtime library */
          if (lpInst->lSwitches&LSW_DYNAMICRTS) {
	          if (lpInst->lSwitches&LSW_GARBAGE)
	             lstrcat((LPSTR)buf2,"oberon-2\\lib\\rts32dgc.lib");
	          else
	             lstrcat((LPSTR)buf2,"oberon-2\\lib\\rts32d.lib");
              AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf2);     
          }
          else if (!(lpInst->lSwitches&LSW_NORTS)) {
	          if (lpInst->lSwitches&LSW_GARBAGE)
	              lstrcat((LPSTR)buf2,"oberon-2\\lib\\rts32sgc.lib");
	          else
	              lstrcat((LPSTR)buf2,"oberon-2\\lib\\rts32s.lib");                      
              AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf2);     
          }
    
          /* add windows api libraries */
          sprintf(buf4,"%s%s",buf3,"oberon-2\\lib\\kernel32.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf4);     

          sprintf(buf4,"%s%s",buf3,"oberon-2\\lib\\user32.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf4);     
      
          sprintf(buf4,"%s%s",buf3,"oberon-2\\lib\\gdi32.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf4);     

          sprintf(buf4,"%s%s",buf3,"oberon-2\\lib\\comdlg32.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf4);     

          sprintf(buf4,"%s%s",buf3,"oberon-2\\winapi\\win32.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf4);     

          /* add startup files for console or gui applications, NOTHING FOR DLL'S! */
          if (!(lpInst->lSwitches&LSW_DLL)) {
             lstrcpy(buf4,buf);
             if (lpInst->lSwitches&LSW_CONSOLE) {
	             lstrcat((LPSTR)buf,"oberon-2\\lib\\obcon.obj");
	             lstrcat((LPSTR)buf4,"oberon-2\\lib\\obconint.obj");
             }
             else {
	             lstrcat((LPSTR)buf,"oberon-2\\lib\\obgui.obj");                      
	             lstrcat((LPSTR)buf4,"oberon-2\\lib\\obguiint.obj");
             }
             AddString((LPHANDLE)&hobj,(LPSTR far *)&obj,(LPSTR)buf);     
             AddString((LPHANDLE)&hobj,(LPSTR far *)&obj,(LPSTR)buf4);     
          }

       #else
          /* add windows api library */
          lstrcat((LPSTR)buf3,"libw.lib");    
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf3);     
    
          /* add static or dynamic runtime library */
          if (lpInst->lSwitches&LSW_DYNAMICRTS) {
	          if (lpInst->lSwitches&LSW_GARBAGE)
	             lstrcat((LPSTR)buf2,"rtsdllgc.lib");
	          else
	             lstrcat((LPSTR)buf2,"rtsdll.lib");
          }
          else {
	          if (lpInst->lSwitches&LSW_GARBAGE)
	              lstrcat((LPSTR)buf2,"rtslibgc.lib");
	          else
	              lstrcat((LPSTR)buf2,"rtslib.lib");                      
          }
          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf2);     
    
          if (lpInst->lSwitches&LSW_DLL) {
	          lstrcat((LPSTR)buf,"dllobero.lib");
	          lstrcat((LPSTR)buf4,"libentry.obj");
	          AddString((LPHANDLE)&hobj,(LPSTR far *)&obj,(LPSTR)buf4);
          }
          else
	          lstrcat((LPSTR)buf,"exeobero.lib");                      

          AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)buf);     
       #endif
      
       /* get object-, library- and resource file names */
       n=CountList(flist);
       for (i=1;i<=n;i++) {
	       GetElem(flist,i,(long)(LPSTR)name);
	       p=(LPSTR)name+lstrlen(name)-3;
	       if (!stricmp(p,"mod")) {
	          *(p-1)=0;
	          while (p>=(LPSTR)name && *(p-1)!='\\') p--;
	          if (*lpInst->objDir)
		          lstrcpy((LPSTR)buf,(LPSTR)lpInst->objDir);
	          else
		          lstrcpy((LPSTR)buf,(LPSTR)lpInst->prjDir);
	          if (buf[lstrlen((LPSTR)buf)-1]!='\\')
		          lstrcat((LPSTR)buf,"\\");
	          lstrcat((LPSTR)buf,p);
	          lstrcat((LPSTR)buf,".obj");
	          AddString((LPHANDLE)&hobj,(LPSTR far *)&obj,(LPSTR)buf);
	       }  
	       else if (!stricmp(p,".rc")) {
	          p++;
	          *(p-1)=0;
	          while (p>=(LPSTR)name && *(p-1)!='\\') p--;
	          lstrcpy((LPSTR)buf,(LPSTR)lpInst->prjDir);
	          if (buf[lstrlen((LPSTR)buf)-1]!='\\')
		          lstrcat((LPSTR)buf,"\\");
	          lstrcat((LPSTR)buf,p);
	          lstrcat((LPSTR)buf,".res");
	          AddString((LPHANDLE)&hres,(LPSTR far *)&res,(LPSTR)buf);
	       }
	       else if (!stricmp(p,"obj")) AddString((LPHANDLE)&hobj,(LPSTR far *)&obj,(LPSTR)name);
	       else if (!stricmp(p,"lib")) {
               #ifdef _WIN32
                   /* calculate name of library */
                   libname=p;
                   while (libname>name && *(libname-1)!='\\') libname--;

                   /* avoid double entries of automatically added libraries */
                   if (stricmp(libname,"win32.lib")!=0 &&
                       stricmp(libname,"kernel32.lib")!=0 &&
                       stricmp(libname,"user32.lib")!=0 &&
                       stricmp(libname,"gdi32.lib")!=0) 
                       AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)name);
               #else
                   AddString((LPHANDLE)&hlib,(LPSTR far *)&lib,(LPSTR)name);
               #endif
           }
	       else if (!stricmp(p,"res")) AddString((LPHANDLE)&hres,(LPSTR far *)&res,(LPSTR)name);
       }

       /* build import and export lists */
       libMainExported=0;
       n=CountList(lpInst->exports);
       for (i=1;i<=n;i++) {
	       GetElem(lpInst->exports,i,(long)(LPSTR)name);
	       if (lpInst->lSwitches&LSW_CASE) {
	          if (!lstrcmp("LibMain",name)) libMainExported=1;
	       }
	       else
	          if (!lstrcmpi("LibMain",name)) libMainExported=1;
   	    AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)name);
       }
   
       n=CountList(lpInst->imports);
       for (i=1;i<=n;i++) {
	       GetElem(lpInst->imports,i,(long)(LPSTR)name);
	       AddString((LPHANDLE)&himp,(LPSTR far *)&imp,(LPSTR)name);
       }

       /* add <mod>_$INIT and <mod>_$GLOBALDATA to export list for every module in a DLL */
       if (lpInst->lSwitches&LSW_DLL) {
   	    n=CountList(flist);
	       for (i=1;i<=n;i++) {
	          GetElem(flist,i,(long)(LPSTR)name);
	          p=(LPSTR)name+lstrlen(name)-4;
	          if (!stricmp(p,".mod")) {
		          *p=0;
		          while (p>(LPSTR)name && *(p-1)!='\\') p--;
				            
                #ifdef _WIN32
                   /* retrieve module name from symbol file to ensure correct capitalization */
                   GetModuleName(lpInst,p,modInit);
                #else
   		          /* retrieve module name from symbol file, if filename greater 8 chars (16-Bit only) */                  
		             if (lstrlen(p)>=8)
                      GetModuleName(lpInst,p,modInit);
		             else
                      lstrcpy(modInit,p);
		             AnsiUpper(modInit);
                #endif
		          
		          /* generate symbols */
		          if (*modInit) {

                   #ifdef _WIN32
   		             lstrcpy(modGData,modInit);
		                lstrcat(modGData,"_$Data");
		                AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modGData);

   		             lstrcpy(modGData,modInit);
		                lstrcat(modGData,"_$Const");
		                AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modGData);

   		             lstrcpy(modGData,modInit);
		                lstrcat(modGData,"_$Code");
		                AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modGData);

                      lstrcat(modInit,"_$Init");
	                   AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modInit);
                   #else
   		             lstrcpy(modGData,modInit);
		                lstrcat(modGData,"_$GLOBALDATA");
		                AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modGData);

                      lstrcat(modInit,"_$INIT");
	                   AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,(LPSTR)modInit);
                   #endif
		          }
	          }
	       }
       }
    
       /* add LibMain to export list for DLLs, if not already exported */
       #ifndef _WIN32
          if ((lpInst->lSwitches&LSW_DLL) && !libMainExported)
	          AddString((LPHANDLE)&hexp,(LPSTR far *)&exp,"LibMain");
       #endif

       switches=lpInst->lSwitches;

       #ifdef _WIN32
          switches&=~LSW_DEBUGCV5;
          if (lpInst->cSwitches&CSW_DEBUGCV5)
             switches|=LSW_DEBUGCV5;
       #endif

       /* execute linker */
       #ifdef _WIN32
          ret=Link32(switches,obj,lib,exe,res,exp,msg,lpInst->baseAdr,lpInst->entrySym,lpInst->stackSize);
       #else
          ret=LinkProgram(switches,obj,lib,exe,stub,res,imp,exp,msg,(WORD)lpInst->heap,(WORD)lpInst->stack);
       #endif

       /* free allocated memory */
       FreeMem(hobj,obj);
       FreeMem(hlib,lib);
       FreeMem(hres,res);
       FreeMem(himp,imp);
       FreeMem(hexp,exp);

       /* restore old cursor */
       SetCursor(oldC);         
   }    
   GlobalUnlock(hData);
    
   return ret;
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

BOOL FAR PASCAL _export GetDirsDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{   

   switch(msg) {

      case WM_INITDIALOG:
	   
	      lpInst=(LPINSTDATA)lParam;   
	      SetWindowText(GetDlgItem(hdlg,IDD_DIRSOBJEDIT),(LPSTR)lpInst->objDir);
	      break;

      case WM_COMMAND:

         #ifdef _WIN32
            switch (LOWORD(wParam)) {
         #else
            switch (wParam) {
         #endif

	            case IDOK:

		            GetWindowText(GetDlgItem(hdlg,IDD_DIRSOBJEDIT),(LPSTR)lpInst->objDir,MAXPATHLENGTH);
		            if (*lpInst->objDir) {
		               if (lpInst->objDir[lstrlen(lpInst->objDir)-1]=='\\')
			               lpInst->objDir[lstrlen(lpInst->objDir)-1]=0;
		               CreateDir(lpInst->objDir);
		               lstrcat(lpInst->objDir,"\\");
		            }    
		            /* fall through! */

        	      case IDCANCEL:

		            EndDialog(hdlg,wParam);
         		   break;

	            case IDD_HELP: {

		            char buf[255];        

		            /* generate helpfile-id ("Oberon2.hlp" in pow-directory) */
		            lstrcpy(buf,homeDir);
		            if ((*buf) && (buf[lstrlen(buf)-1]!='\\'))
		               lstrcat(buf,"\\");
		            lstrcat(buf,HELPFILE);
		            WinHelp(hdlg,(LPSTR)buf,HELP_PARTIALKEY,(DWORD)(LPSTR)"Directories");
		            }
		            break;
	         }
	         break;

      default:

	      return FALSE;
   }
   return TRUE;
}

/*************************
 * make directory dialog *
 *************************/

BOOL FAR PASCAL _export DirectoryOptions (HANDLE hData,HWND hwnd)
{
   int ret;
   FARPROC lpMsg;
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   lpMsg=MakeProcInstance(GetDirsDlgProc,hInst);
   ret=DialogBoxParam(hInst,IDD_GETDIRS,hwnd,lpMsg,(long)lpInst);
   FreeProcInstance(lpMsg); 
    
   GlobalUnlock(hData);
    
   return (ret==IDOK);
}

/*************************************************************************
 *                                                                       *
 *                   P r o j e k t - I n t e r f a c e                   *
 *                                                                       *
 *************************************************************************/

void FAR PASCAL _export NewProject (HANDLE hData)
{                             
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);
  
   /* purge old project */
   PurgeList((LPHANDLE)&lpInst->exports);
   PurgeList((LPHANDLE)&lpInst->imports);
   PurgeList((LPHANDLE)&lpInst->dllModules);

   /* set default values */
   #ifdef _WIN32
      lpInst->cSwitches=CSW_DEBUGCOFF|CSW_OVERFLOW|CSW_TYPE|CSW_INDEX|CSW_RANGE|CSW_PTRINIT|CSW_ASSERTEVAL;
      lpInst->baseAdr=0;
      *(lpInst->entrySym)=0;
   #else
      lpInst->cSwitches=CSW_DEBUGINFO|CSW_OVERFLOW|CSW_TYPE|CSW_INDEX|CSW_RANGE|CSW_PTRINIT|CSW_ASSERTEVAL|CSW_SMART;
   #endif
   
   lpInst->lSwitches=LSW_DEBUG|LSW_CASE|LSW_GARBAGE|LSW_DYNAMICRTS;
   lpInst->heap=16000;
   lpInst->stack=16000;
    
   GlobalUnlock(hData);
}

BOOL FAR PASCAL _export WriteOptions (HANDLE hData,LPSTR prjName,HFILE file)
{
   LPSTR p;                                       
   LPINSTDATA lpInst;
   char buf[VERSIONSTRINGLENGTH];
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   /* remember project name and directory */
   lstrcpy((LPSTR)lpInst->prjFil,prjName);
   lstrcpy((LPSTR)lpInst->prjDir,prjName);
   p=(LPSTR)lpInst->prjDir+lstrlen(lpInst->prjDir)-1;
   while (*p!='\\') p--;
   *++p=0;

#ifdef _WIN32
   /* save file version information */
   strcpy(buf,PRJFILEVERSION303);
   FileOut(buf,VERSIONSTRINGLENGTH);
#endif

   /* save directory information */
   ShrinkDir((LPSTR)lpInst->objDir,(LPSTR)homeDir,(LPSTR)lpInst->prjFil);
   FileOut((LPSTR)lpInst->objDir,sizeof(lpInst->objDir));
   FileOut((LPSTR)&lpInst->cSwitches,sizeof(lpInst->cSwitches));
   FileOut((LPSTR)&lpInst->lSwitches,sizeof(lpInst->lSwitches));
   FileOut((LPSTR)&lpInst->heap,sizeof(lpInst->heap));
   FileOut((LPSTR)&lpInst->stack,sizeof(lpInst->stack));
   WriteList(lpInst->exports);
   WriteList(lpInst->imports);
   WriteList(lpInst->dllModules);

#ifdef _WIN32
   FileOut((LPSTR)&lpInst->baseAdr,sizeof(lpInst->baseAdr));
   FileOut((LPSTR)lpInst->entrySym,sizeof(lpInst->entrySym));
   FileOut((LPSTR)&lpInst->stackSize,sizeof(lpInst->stackSize));
   FileOut((LPSTR)&lpInst->ignoreLink,sizeof(lpInst->ignoreLink));
#endif

   StretchDir((LPSTR)lpInst->objDir,(LPSTR)homeDir,(LPSTR)lpInst->prjFil);
   GlobalUnlock(hData);                  
		      
   return TRUE;
}

BOOL FAR PASCAL _export ReadOptions (HANDLE hData,LPSTR prjName,HFILE file)
{
   LPSTR p;                                      
   LPINSTDATA lpInst;
   char version[VERSIONSTRINGLENGTH];

#ifdef _WIN32
   BOOL version301;
   BOOL version302;
   BOOL version303;
#endif
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   /* remember project name */
   lstrcpy((LPSTR)lpInst->prjFil,prjName);
   lstrcpy((LPSTR)lpInst->prjDir,prjName);
   p=(LPSTR)lpInst->prjDir+lstrlen(lpInst->prjDir)-1;
   while (*p!='\\') p--;
   *++p=0;

   /* retrieve directory information */
   FileIn(version,VERSIONSTRINGLENGTH);

#ifdef _WIN32
   version301 = (strcmp(version,PRJFILEVERSION301)==0);
   version302 = (strcmp(version,PRJFILEVERSION302)==0);
   version303 = (strcmp(version,PRJFILEVERSION303)==0);

   *lpInst->objDir=0;
   if (version303)
   {
      memset(lpInst->objDir,sizeof(lpInst->objDir),0);
      FileIn((LPSTR)lpInst->objDir,sizeof(lpInst->objDir));
   }

   if (version301 || version302) {
      memset(lpInst->objDir,sizeof(lpInst->objDir),0);
      FileIn((LPSTR)lpInst->objDir,80);
      /* avoid an earlier bug, that wrote the project version info as object directory */
      if (strstr(lpInst->objDir,PRJFILEVERSION301) || strstr(lpInst->objDir,PRJFILEVERSION302))
          *(lpInst->objDir)=0;
   }

#endif

   FileIn((LPSTR)&lpInst->cSwitches,sizeof(lpInst->cSwitches));
   FileIn((LPSTR)&lpInst->lSwitches,sizeof(lpInst->lSwitches));
   FileIn((LPSTR)&lpInst->heap,sizeof(lpInst->heap));
   FileIn((LPSTR)&lpInst->stack,sizeof(lpInst->stack));
   ReadList((LPHANDLE)&lpInst->exports);
   ReadList((LPHANDLE)&lpInst->imports);
   ReadList((LPHANDLE)&lpInst->dllModules);
   StretchDir((LPSTR)lpInst->objDir,(LPSTR)homeDir,(LPSTR)lpInst->prjFil);
   CreateDir(lpInst->objDir);

#ifdef _WIN32
   if (version301 || version302 || version303) {
      FileIn((LPSTR)&lpInst->baseAdr,sizeof(lpInst->baseAdr));
      FileIn((LPSTR)lpInst->entrySym,sizeof(lpInst->entrySym));

      if (version302 || version303) {
          FileIn((LPSTR)&lpInst->stackSize,sizeof(lpInst->stackSize));
          FileIn((LPSTR)&lpInst->ignoreLink,sizeof(lpInst->ignoreLink));
      }
      else {
          lpInst->ignoreLink=FALSE;
          lpInst->stackSize=0;
      }
   }
   else {
      lpInst->baseAdr=0;
      *(lpInst->entrySym)=0;
   }
#endif
     
   GlobalUnlock(hData);
    
   return TRUE;
}

void FAR PASCAL _export GetExtensions (HANDLE hData,LPEXT far *srcExt,LPINT srcN,LPEXT far *addExt,LPINT addN)
{
   *srcExt=(LPEXT)&SrcExt;
   *addExt=(LPEXT)&AddExt;
   *srcN=4;
   #ifdef _WIN32
      *addN=5;  /* no resource compiler available for 32-bit :-( */
   #else
      *addN=6;
   #endif
}

BOOL FAR PASCAL _export GetExecutable (HANDLE hData,LPSTR exe)
{
   LPSTR p;
   BOOL ret;                                        
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);
    
   /* executable name */
   lstrcpy(exe,"\"");
   lstrcat(exe,(LPSTR)lpInst->prjFil);
   p=exe+lstrlen(exe)-1;
   while (*p!='.') p--;
   *++p=0;       
   if (lpInst->lSwitches&LSW_DLL) 
   {
     lstrcat(exe,"dll");
     ret=FALSE;  // target is not executable!
   }    
   else 
   {
     lstrcat(exe,"exe");
	   ret=TRUE;   // target is executable
   }        
   lstrcat(exe,"\"");
   GlobalUnlock(hData);
   return ret;
}

BOOL FAR PASCAL _export GetTarget (HANDLE hData,LPSTR exe)
// returns TRUE if target is executable and false otherwise
{
   LPSTR p;
   BOOL ret;                                        
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);
    
   /* executable name */
   lstrcpy(exe,(LPSTR)lpInst->prjFil);
   p=exe+lstrlen(exe)-1;
   while (*p!='.') p--;
   *++p=0;       
   if (lpInst->lSwitches&LSW_DLL) 
   {
     lstrcat(exe,"dll");
     ret=FALSE;  // target is not executable!
   }    
   else 
   {
     lstrcat(exe,"exe");
	   ret=TRUE;   // target is executable
   }        
   GlobalUnlock(hData);
   return ret;
}

// check, if file exists in a  directory
BOOL SearchFile (LPSTR dir,LPSTR name,LPSTR file)
{
   int f;    
   char full[255];

   // generate full file name    
   strcpy(full,dir);
   if (full[strlen(full)-1]!='\\')
	   strcat(full,"\\");
   strcat(full,name);
		     
   // check, if file exists
   #ifdef _WIN32
      f=_lopen(full,OF_READ);
   #else
      f=_lopen(full,READ);
   #endif

   if (f!=HFILE_ERROR) {
      _lclose(f);
      strcpy(file,full);
   }

   return f!=HFILE_ERROR;
}

void FAR PASCAL _export NewProjectName (HANDLE hData,LPSTR prjName)
{
   LPSTR p;                                      
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   ShrinkDir((LPSTR)lpInst->objDir,(LPSTR)homeDir,(LPSTR)lpInst->prjFil);

   /* remember project name */
   lstrcpy((LPSTR)lpInst->prjFil,prjName);
   lstrcpy((LPSTR)lpInst->prjDir,prjName);
   p=(LPSTR)lpInst->prjDir+lstrlen(lpInst->prjDir)-1;
   while (*p!='\\') p--;
   *++p=0;                           

   StretchDir((LPSTR)lpInst->objDir,(LPSTR)homeDir,(LPSTR)lpInst->prjFil);
   CreateDir(lpInst->objDir);
    
   GlobalUnlock(hData);
}

void FAR PASCAL _export ChangeModuleName (HANDLE hData,HWND hwnd,FARPROC replace,LPSTR modname,LPSTR dstname)
{            
   char buf[1000],newbuf[1000],newname[1000];            
				 
   // convert first letter of new module name to upper case
   lstrcpy(newname,dstname);
   *newname=toupper(*newname);
    
   // replace head module name
   lstrcpy((LPSTR)buf,"MODULE ");
   lstrcat((LPSTR)buf,(LPSTR)modname);
   lstrcat((LPSTR)buf,";"); 
    
   lstrcpy((LPSTR)newbuf,"MODULE ");
   lstrcat((LPSTR)newbuf,(LPSTR)newname);
   lstrcat((LPSTR)newbuf,";"); 

   if (replace)
	   (*(ReplaceProc*)replace)(hwnd,buf,newbuf,FALSE,TRUE,FALSE,FALSE,FALSE);

   // replace tail module name
   lstrcpy((LPSTR)buf,"END ");
   lstrcat((LPSTR)buf,(LPSTR)modname);
   lstrcat((LPSTR)buf,".");            

   lstrcpy((LPSTR)newbuf,"END ");
   lstrcat((LPSTR)newbuf,(LPSTR)newname);
   lstrcat((LPSTR)newbuf,".");            
    
   if (replace)
	   (*(ReplaceProc*)replace)(hwnd,buf,newbuf,FALSE,TRUE,FALSE,FALSE,FALSE);
}
				
char dirName[MAXPATHLENGTH];          // global, because of DS!=SS
char oldDir[MAXPATHLENGTH];                                          
					  
void CreateDir (LPSTR dir)
{               
   int n,ret;         

   if (n=lstrlen(dir)) 
   {
	   lstrcpy((LPSTR)dirName,dir);
	   if (dirName[n-1]=='\\') dirName[n-1]=0;
	   ret=_mkdir(dirName);
   }        
}
		 
int ObjectdirValid (LPINSTDATA lpInst)
{
   if (lpInst && *(lpInst->objDir)) {
	   getcwd(oldDir,sizeof(oldDir));
	   lstrcpy((LPSTR)dirName,lpInst->objDir);
	   if (dirName[lstrlen((LPSTR)dirName)-1]=='\\')
	       dirName[lstrlen((LPSTR)dirName)-1]=0;  
	   if (chdir(dirName))
	       return FALSE;  // object directory is invalid!!!
	   chdir(oldDir);    
   }                         
   return TRUE;
}
		 
// check, if we have the source for a requested module
BOOL FAR PASCAL _export SourceAvailable (HANDLE hData,LPSTR module,LPSTR file)
{
   BOOL ret;
   char source[255];
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);

   #ifdef _WIN32
      strcpy(source,module);
   #else
      strncpy(source,module,8);
    
      /* cut module name to eight characters */
      source[8]=0;
   #endif

   strcat(source,".mod");

   ret=SearchFile(lpInst->prjDir,source,file) || (*(lpInst->objDir) && SearchFile(lpInst->objDir,source,file));
    
   GlobalUnlock(hData);
   return ret;
}

#ifndef _WIN32
/* this structure consists of 2 DWORDS in WIN32 */
#define FILETIME long
#endif

/* compare two file times, return TRUE if time1 was earlier than time2 */
BOOL WasEarlier (FILETIME *time1,FILETIME *time2)
{
#ifdef _WIN32
   return (time1->dwHighDateTime < time2->dwHighDateTime) ||
          ((time1->dwHighDateTime == time2->dwHighDateTime) &&
           (time1->dwLowDateTime < time2->dwLowDateTime));
#else
   return *time1 < *time2;
#endif
}

/* calculate time of creation of given file, return TRUE if file exists */
BOOL GetFileCreation (char *file,FILETIME *time)
{
#ifdef _WIN32
   HANDLE h;
   WIN32_FIND_DATA fdata;

   h=FindFirstFile(file,&fdata);
   if (h!=INVALID_HANDLE_VALUE) {
      *time = fdata.ftLastWriteTime;
      FindClose(h);
      return TRUE;
   }

#else
   struct _stat fstat;
   if (_stat(file,&fstat)==0) {
      *time = fstat.ctime;
      return TRUE;
   }

#endif

   return FALSE;
}

// check, if a project file must be compiled
BOOL FAR PASCAL _export MustBeBuilt (HANDLE hData,LPSTR file)
{                                                         
   BOOL ret;
   LPINSTDATA lpInst;
   FILETIME srctime,symtime,objtime;
   char drv[_MAX_DRIVE],dir[_MAX_DIR],fil[_MAX_FNAME],ext[_MAX_EXT],obj[_MAX_PATH],sym[_MAX_PATH];

   lpInst=(LPINSTDATA)GlobalLock(hData);
   _splitpath(file,drv,dir,fil,ext);
   DownStr((LPSTR)ext);
    
   if (*(lpInst->objDir) && stricmp((LPSTR)ext,".rc"))  
   	strcpy(obj,lpInst->objDir);
   else
	   //res-files always reside in the project-directory
	   strcpy(obj,lpInst->prjDir);
	
   if (*obj && obj[strlen(obj)-1]!='\\')
   	strcat(obj,"\\");
   strcat(obj,fil);
    
   if (stricmp(ext,".rc")==0) {
   	strcat(obj,".res");
	   *sym=0;
   }
   else {
	   strcpy(sym,obj);
	   strcat(obj,".obj");
	   strcat(sym,".sym");
   }

   GlobalUnlock(hData);

   if (!GetFileCreation(file,&srctime))
   	return FALSE;  // source does not exist -> no build necessary
    
   if (*sym && !GetFileCreation(sym,&symtime))
   	return TRUE;   // no symbol file -> build necessary

   if (!GetFileCreation(obj,&objtime))
   	return TRUE;   // no object file -> build necessary
	
   ret=WasEarlier(&objtime,&srctime);
                     // compilation necessary if object older than source
	 
   return ret;
}

// check, if a project file must be compiled
BOOL FAR PASCAL _export CheckIfYounger (HANDLE hData,LPSTR module,LPSTR client)
{
   BOOL ret;
   LPINSTDATA lpInst;
   FILETIME modtime,clitime;
   char drv[_MAX_DRIVE],dir[_MAX_DIR],fil[_MAX_FNAME],ext[_MAX_EXT],cliobj[_MAX_PATH],modsym[_MAX_PATH];

   lpInst=(LPINSTDATA)GlobalLock(hData);
    
   if (*(lpInst->objDir))
	   strcpy(modsym,lpInst->objDir);
   else
	   strcpy(modsym,lpInst->prjDir);
   if (*modsym && modsym[strlen(modsym)-1]!='\\')
   	strcat(modsym,"\\");   
	
   strcpy(cliobj,modsym);

   _splitpath(module,drv,dir,fil,ext);
   strcat(modsym,fil);
   strcat(modsym,".sym");
    
   _splitpath(client,drv,dir,fil,ext);
   strcat(cliobj,fil);
   strcat(cliobj,".obj");

   GlobalUnlock(hData);

   if (!GetFileCreation(modsym,&modtime))
	   return FALSE;      // no module symbol file -> no compilation of client necessary
		
   ret=(!GetFileCreation(cliobj,&clitime) ||
        WasEarlier(&clitime,&modtime));
                         // no client object or client object older than module symbols -> compilation necessary
	 
   return ret;
}

/*************************************************************************
 *                                                                       *
 *                      H e l p - I n t e r f a c e                      *
 *                                                                       *
 *************************************************************************/

BOOL FAR PASCAL _export HelpCompiler (HANDLE hData,HWND hwnd,LPSTR powDir,WORD wCmd,DWORD dwData)
{
   char buf[256];        

   /* generate helpfile-id ("_Oberon.hlp" in pow-directory) */
   lstrcpy(buf,powDir);
   if ((*buf) && (buf[lstrlen(buf)-1]!='\\'))
   	lstrcat(buf,"\\");
   lstrcat(buf,HELPCOMPILER);

   /* call for help */
   return WinHelp(hwnd,(LPSTR)buf,wCmd,dwData);
}

/* return name of help file (without directory information) */
void FAR PASCAL _export GetHelpFile (HANDLE hData,LPSTR name)
{
   lstrcpy(name,HELPCOMPILER);
}

/*************************************************************************
 *                                                                       *
 *                    E d i t o r - I n t e r f a c e                    *
 *                                                                       *
 *************************************************************************/

/*****************
 * tell keywords *
 *****************/

void FAR PASCAL _export EditorSyntax (HANDLE hData,LPLONG caseSensitive,FARPROC enumK)
{
   *caseSensitive=1;
   (*(EnumKey*)enumK)("ARRAY");      (*(EnumKey*)enumK)("MODULE");
   (*(EnumKey*)enumK)("BEGIN");      (*(EnumKey*)enumK)("NIL");
   (*(EnumKey*)enumK)("CASE");       (*(EnumKey*)enumK)("OF");
   (*(EnumKey*)enumK)("CONST");      (*(EnumKey*)enumK)("OR");
   (*(EnumKey*)enumK)("DIV");        (*(EnumKey*)enumK)("POINTER");
   (*(EnumKey*)enumK)("DO");         (*(EnumKey*)enumK)("PROCEDURE");
   (*(EnumKey*)enumK)("ELSE");       (*(EnumKey*)enumK)("RECORD");
   (*(EnumKey*)enumK)("ELSIF");      (*(EnumKey*)enumK)("REPEAT");
   (*(EnumKey*)enumK)("END");        (*(EnumKey*)enumK)("RETURN");
   (*(EnumKey*)enumK)("EXIT");       (*(EnumKey*)enumK)("THEN");
   (*(EnumKey*)enumK)("IF");         (*(EnumKey*)enumK)("TO");
   (*(EnumKey*)enumK)("IMPORT");     (*(EnumKey*)enumK)("TYPE");
   (*(EnumKey*)enumK)("IN");         (*(EnumKey*)enumK)("UNTIL");
   (*(EnumKey*)enumK)("IS");         (*(EnumKey*)enumK)("VAR");
   (*(EnumKey*)enumK)("LOOP");       (*(EnumKey*)enumK)("WHILE");
   (*(EnumKey*)enumK)("MOD");        (*(EnumKey*)enumK)("WITH");
   (*(EnumKey*)enumK)("FOR");
}

/*********************************
 * tell construction of comments *
 *********************************/

void FAR PASCAL _export EditorComment (HANDLE hData,LPLONG inComments,LPSTR commentOn,LPSTR commentOff,LPSTR strings)
{
   *inComments=1;             /* comments in comments are possible */
   _fstrcpy(commentOn,"(*");  /* first characters of comments */
   _fstrcpy(commentOff,"*)"); /* last characters of comments */
   _fstrcpy(strings,"\"\'");  /* delimiters of strings */
}

/*************************************************************************
 *                                                                       *
 *                      I n t e r f a c e - E x i t                      *
 *                                                                       *
 *************************************************************************/

void FAR PASCAL _export ExitInterface (HANDLE hData)
{                        
   LPINSTDATA lpInst;
    
   lpInst=(LPINSTDATA)GlobalLock(hData);
    
   PurgeList((LPHANDLE)&lpInst->exports);
   PurgeList((LPHANDLE)&lpInst->imports);
   PurgeList((LPHANDLE)&lpInst->dllModules);
    
   GlobalUnlock(hData);
   GlobalFree(hData);  
}

/*************************************************************************
 *                                                                       *
 *            D L L - I n i t i a l i z a t i o n / E x i t              *
 *                                                                       *
 *************************************************************************/

#ifdef _WIN32

   int main (void)
   {
       return 0;
   }

   BOOL WINAPI MyDllEntryPoint (HINSTANCE hI,DWORD reason,LPVOID reserved)
   {
       if (reason==DLL_PROCESS_ATTACH) {
          hInst=hI;
       }

       if (reason==DLL_PROCESS_DETACH) {
          /* remove default tools */
          DdeSendCommand("pow","pow","deletetool Oberon-2 Win32 API");
          DdeSendCommand("pow","pow","deletetool Oberon-2 Symbolfile Browser");
          DdeSendCommand("pow","pow","deletetool Oberon-2 Report Generator");
       }

       return TRUE;
   }

#else

   /******************
    * initialize dll *
    ******************/

   int FAR PASCAL LibMain (HANDLE hInstance,WORD wDSeg,WORD wHSize,LPSTR lpCmd)
   {
      if (wHSize)
	      UnlockData(0);
      hInst=hInstance;
      return 1;
   }

   /*********************
    * dll exit function *
    *********************/

   int FAR PASCAL _export WEP (int exitType)
   {                  
      return 1;
   }

#endif