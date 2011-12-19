
#include "powCompiler.h"
#include "powEd.h"

HANDLE hCompData;                /* handle to compiler-dll data */
HANDLE compilerDLL=0;              /* actual compiler dll */
char compilerDLLname[MAXPATHLENGTH]="";       /* name of compiler dll */
char compilerHelpfile[MAXPATHLENGTH]=""; /* name of compiler help (includes path) */

/* compiler interface access functions */
CompAboutProc*             compAbout;
CompChangeModuleNameProc*  compChangeModuleName;
CompCheckDepProc*          compCheckDep; 
CompCheckIfYoungerProc*    compCheckIfYounger;
CompCompileProc*           compCompile;
CompCompOptProc*           compCompOpt;
CompDirOptProc*            compDirOpt;
CompExitProc*              compExit;
CompGetExecProc*           compGetExec;
CompGetExtProc*            compGetExt;
CompGetHelpProc*           compGetHelp;
CompHelpProc*              compHelp;
CompInitProc*              compInit;
CompLinkProc*              compLink;
CompLinkOptProc*           compLinkOpt;
CompMustBeBuiltProc*       compMustBeBuilt;
CompNewProjectProc*        compNewProject;
CompNewProjectNameProc*    compNewProjectName;
CompReadOptProc*           compReadOpt;
CompSourceAvailableProc*   compSourceAvailable;
CompWriteOptProc*          compWriteOpt;
CompGetTargetProc*         compGetTarget;
CompFileWasCompiledProc*   compFileWasCompiled;
CompCommentProc*           compComment;
CompKeywordProc*           compKeyword;


BOOL LoadCompilerInterface(LPSTR dllName, 
                           BOOL  showIntroPopup,
                           LPSTR compiler,
                           LPSTR defaultDir,
                           DWORD ddeInstId)
{
  HWND focus;
  char buf[MAXPATHLENGTH];

  if (IsCompilerInterfaceLoaded()) UnloadCompilerInterface();
  strcpy(compilerDLLname,dllName);




  compilerDLL=LoadLibrary(compilerDLLname);
#ifdef _WIN32
  if (compilerDLL==NULL) 
  {
#else
  if (compilerDLL<32)
  {
#endif
    /* can't open dll */
    Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTOPENDLL,compilerDLLname,compilerDLL);

    /* source extensions */
    srcN=1;
    SrcExt=(LPEXT)&AllExt;
    addN=1;
    AddExt=(LPEXT)&AllExt;

    compilerDLL=0;
    return 0;
  }  
  else
  {
    /* initialize dll */
    compAbout=(CompAboutProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_ABOUTCOMPILER));
    compChangeModuleName=(CompChangeModuleNameProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_CHANGEMODULENAME));
    compCheckDep=(CompCheckDepProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_CHECKDEPEND));
    compCheckIfYounger=(CompCheckIfYoungerProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_CHECKIFYOUNGER));
    compCompile=(CompCompileProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_COMPILE));
    compCompOpt=(CompCompOptProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_COMPILEOPTIONS));
    compDirOpt=(CompDirOptProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_DIRECTORYOPTIONS));
    compExit=(CompExitProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_EXITINTERFACE));
    compGetExec=(CompGetExecProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_GETEXECUTABLE));
    compGetExt=(CompGetExtProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_GETEXTENSIONS));
    compGetHelp=(CompGetHelpProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_GETHELPFILE));
    compHelp=(CompHelpProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_HELPCOMPILER));
    compInit=(CompInitProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_INITINTERFACE));
    compLink=(CompLinkProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_LINK));
    compLinkOpt=(CompLinkOptProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_LINKEROPTIONS));
    compMustBeBuilt=(CompMustBeBuiltProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_MUSTBEBUILT));
    compNewProject=(CompNewProjectProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_NEWPROJECT));
    compNewProjectName=(CompNewProjectNameProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_NEWPROJECTNAME));
    compReadOpt=(CompReadOptProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_READOPTIONS));
    compSourceAvailable=(CompSourceAvailableProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_SOURCEAVAILABLE));
    compWriteOpt=(CompWriteOptProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_WRITEOPTIONS));
    compGetTarget=(CompGetTargetProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_GETTARGET));
    compFileWasCompiled=(CompFileWasCompiledProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_FILEWASCOMPILED));
    compComment=(CompCommentProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_EDITORCOMMENT));
    compKeyword=(CompKeywordProc*)GetProcAddress(compilerDLL,MAKEINTRESOURCE(DLL_EDITORSYNTAX));
    
    if (!(compAbout &&
          compChangeModuleName &&
          compCheckDep &&
          compCheckIfYounger &&
          compCompile &&
          compCompOpt &&
          compDirOpt &&
          compExit &&
          compGetExec &&
          compGetExt &&
          compGetHelp &&
          compHelp &&
          compInit &&
          compLink &&
          compLinkOpt &&
          compMustBeBuilt &&
          compNewProject &&
          compNewProjectName &&
          compReadOpt &&
          compSourceAvailable &&
          compWriteOpt &&
          compGetTarget &&
          compFileWasCompiled &&
          compComment &&
          compKeyword))
    {  
      Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_CANTOPENDLL,"The compiler interface DLL does not provide all of the required functions.");
      FreeLibrary(compilerDLL);
      compilerDLL=0;
      return 0;
    }
    else
    {
      hCompData=(*compInit)(compiler,defaultDir,ddeInstId);

        /* ignore compiler about box on startup of Pow!, only show when switching interfaces */
      if (showIntroPopup) 
      {
            /* compiler about box */
        focus=GetFocus();
        (*compAbout)(hCompData,hwndFrame);
        SetFocus(focus);
      }

      /* source extensions */
      (*compGetExt)(hCompData,(LPEXT far *)&SrcExt,(LPINT)&srcN,(LPEXT far *)&AddExt,(LPINT)&addN);
        
            
      (*compGetHelp)(hCompData,(LPSTR)buf);
      if (*buf)
      {
        lstrcpy(compilerHelpfile,defaultDir);
        if (*compilerHelpfile && compilerHelpfile[lstrlen(compilerHelpfile)-1]!='\\')
        {
          lstrcat(compilerHelpfile,"\\");
        }
        lstrcat(compilerHelpfile,buf);
        EditSetHelpFile(compilerHelpfile);
      }
      else
      {
        compilerHelpfile[0]=0;
      }
      /* report syntax to editor */
      EditSetSyntax();
      return 1;
    }
  }
}

BOOL UnloadCompilerInterface(void)
{
  if (IsCompilerInterfaceLoaded())
  {

    (*compExit)(hCompData);
    FreeLibrary(compilerDLL);
    compilerDLL=0;
    return 1;
  }
  else
  {
    return 0;
  }
}

BOOL IsCompilerInterfaceLoaded(void)
{
  return (compilerDLL!=0);
}





