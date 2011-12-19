#ifndef _INC_POWRUN

/*
typedef BOOL FAR PASCAL GetExecProc (HANDLE,LPSTR);   // command line to exec project target
typedef BOOL FAR PASCAL GetTargetProc (HANDLE,LPSTR); // target file created by project
*/

extern char RunArgs[255];

extern void FAR RunProject (HWND);
extern void FAR GetRunArgs (void);

#define _INC_POWRUN
#endif
