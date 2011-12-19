#include <stdio.h>
#include <windows.h>

typedef void FAR PASCAL Depends (LPSTR);
typedef void FAR PASCAL EnumKey (LPSTR);
typedef void FAR PASCAL CompMsg (LPSTR);
typedef void FAR PASCAL CompErr (int,int,int,BOOL,LPSTR);
typedef void FAR PASCAL LinkMsg (LPSTR);

typedef struct {
   char fileName[80];
   char tmpName[80];
   char objDir[128];
   char objName[80];
   char licName[80];
   char symDirs[256];
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

BOOL FAR PASCAL Oberon2 (COMP *command)
{
   char buf[200];
   sprintf(buf,"Simulation - Options %lx File %s",command->options,command->fileName);
   ((CompErr*)command->errProc)(-1,-1,-1,FALSE,buf);
   return TRUE;
}

void FAR PASCAL GetCompilerVersion (LPSTR version)
{
   strcpy(version,"NULL");
}

void FAR PASCAL AddDLLModule (long size,long lowbound,LPSTR module,LPINT done)
{
}

void FAR PASCAL ClearDllModules (void)
{
}
