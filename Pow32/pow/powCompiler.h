/*

   declaration of compiler DLL interface

*/
#ifndef _INC_PowCompiler

#include <windows.h>
#include "powopen.h"
#include "..\powsup\powsupp.h"
#include "pow.h"

/* compiler interface dll functions */
#define DLL_INITINTERFACE     1
#define DLL_ABOUTCOMPILER     2
#define DLL_COMPILEOPTIONS    3
#define DLL_COMPILE           4
#define DLL_CHECKDEPEND       5
#define DLL_FILEWASCOMPILED   6
#define DLL_LINKEROPTIONS     7
#define DLL_LINK              8
#define DLL_DIRECTORYOPTIONS  9
#define DLL_NEWPROJECT       10
#define DLL_WRITEOPTIONS     11
#define DLL_READOPTIONS      12
#define DLL_GETEXTENSIONS    13
#define DLL_HELPCOMPILER     14
#define DLL_EDITORSYNTAX     15
#define DLL_EDITORCOMMENT    16
#define DLL_EXITINTERFACE    17
#define DLL_GETEXECUTABLE    18
#define DLL_NEWPROJECTNAME   19
#define DLL_CHANGEMODULENAME 20
#define DLL_SOURCEAVAILABLE  28
#define DLL_MUSTBEBUILT      29
#define DLL_CHECKIFYOUNGER   30
#define DLL_GETHELPFILE      31
#define DLL_GETTARGET        32

/* compiler interface dll procedure types */
typedef BOOL   FAR PASCAL CompAboutProc     (HANDLE,HWND);
typedef void   FAR PASCAL CompChangeModuleNameProc (HANDLE,HWND,FARPROC,LPSTR,LPSTR);
typedef void   FAR PASCAL CompCheckDepProc (HANDLE,LPSTR,FARPROC,HWND,FARPROC,FARPROC,FARPROC,FARPROC,FARPROC,HANDLE);
typedef BOOL   FAR PASCAL CompCheckIfYoungerProc (HANDLE,LPSTR,LPSTR);
typedef BOOL   FAR PASCAL CompCompileProc (HANDLE,LPSTR,FARPROC,FARPROC,HWND,FARPROC,FARPROC,FARPROC,FARPROC,FARPROC,HANDLE);
typedef BOOL   FAR PASCAL CompCompOptProc (HANDLE,HWND);
typedef BOOL   FAR PASCAL CompDirOptProc    (HANDLE,HWND);
typedef void   FAR PASCAL CompExitProc      (HANDLE);
typedef BOOL   FAR PASCAL CompGetExecProc   (HANDLE,LPSTR);   // command line to exec project target
typedef int    FAR PASCAL CompGetExtProc    (HANDLE,LPEXT far *,LPINT,LPEXT far *,LPINT);
typedef void   FAR PASCAL CompGetHelpProc   (HANDLE,LPSTR);
typedef BOOL   FAR PASCAL CompHelpProc (HANDLE,HWND,LPSTR,WORD,DWORD);
typedef HANDLE FAR PASCAL CompInitProc      (LPSTR,LPSTR,DWORD);
typedef BOOL   FAR PASCAL CompLinkProc (HANDLE,LPSTR,HANDLE,FARPROC);
typedef BOOL   FAR PASCAL CompLinkOptProc (HANDLE,HWND);
typedef BOOL   FAR PASCAL CompMustBeBuiltProc (HANDLE,LPSTR);
typedef void   FAR PASCAL CompNewProjectProc (HANDLE, LPSTR);
typedef void   FAR PASCAL CompNewProjectNameProc (HANDLE,LPSTR);
typedef BOOL   FAR PASCAL CompReadOptProc (HANDLE,LPSTR,HFILE); 
typedef BOOL   FAR PASCAL CompWriteOptProc (HANDLE,LPSTR,HFILE); 
typedef BOOL   FAR PASCAL CompSourceAvailableProc (HANDLE,LPSTR,LPSTR);
typedef BOOL   FAR PASCAL CompGetTargetProc (HANDLE,LPSTR); // target file created by project
typedef BOOL   FAR PASCAL CompFileWasCompiledProc (HANDLE,LPSTR);
typedef void   FAR PASCAL CompCommentProc (HANDLE,LPLONG,LPSTR,LPSTR,LPSTR);
typedef void   FAR PASCAL CompKeywordProc (HANDLE,LPLONG,FARPROC);


extern CompAboutProc*             compAbout;
extern CompChangeModuleNameProc*  compChangeModuleName;
extern CompCheckDepProc*          compCheckDep; 
extern CompCheckIfYoungerProc*    compCheckIfYounger;
extern CompCompileProc*           compCompile;
extern CompCompOptProc*           compCompOpt;
extern CompDirOptProc*            compDirOpt;
extern CompExitProc*              compExit;
extern CompGetExecProc*           compGetExec;
extern CompGetExtProc*            compGetExt;
extern CompGetHelpProc*           compGetHelp;
extern CompHelpProc*              compHelp;
extern CompInitProc*              compInit;
extern CompLinkProc*              compLink;
extern CompLinkOptProc*           compLinkOpt;
extern CompMustBeBuiltProc*       compMustBeBuilt;
extern CompNewProjectProc*        compNewProject;
extern CompNewProjectNameProc*    compNewProjectName;
extern CompReadOptProc*           compReadOpt;
extern CompSourceAvailableProc*   compSourceAvailable;
extern CompWriteOptProc*          compWriteOpt;
extern CompGetTargetProc*         compGetTarget;
extern CompFileWasCompiledProc*   compFileWasCompiled;
extern CompCommentProc*           compComment;
extern CompKeywordProc*           compKeyword;

extern char compilerDLLname[MAXPATHLENGTH];
extern char far compilerHelpfile[MAXPATHLENGTH];
extern HANDLE hCompData;      /* handle to compiler-dll data */

BOOL LoadCompilerInterface(LPSTR dllName, 
						   BOOL  showIntroPopup,
						   LPSTR compiler,
						   LPSTR defaultDir,
						   DWORD ddeInstId);
BOOL UnloadCompilerInterface(void);
BOOL IsCompilerInterfaceLoaded(void);


#define _INC_PowCompiler
#endif
