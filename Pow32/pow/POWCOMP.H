// Exported functions of module POWCOMP.C

#ifndef _INCLUDE_POWCOMP_
#define _INCLUDE_POWCOMP_

void FAR NextError();
void FAR PrevError();
void FAR GotoError (HWND hwnd);

void FAR GetTargetName(LPSTR exe, BOOL* isExecutable);

BOOL FAR OpenProject();
BOOL FAR MakeEmptyProject();
void FAR EditProject();
void FAR SaveAsProject();
void FAR CloseProject(BOOL readDef);

void FAR SaveProjectEdits(HWND hWndActive, BOOL ask);

VOID FAR CompilerOptions(HWND parent);
VOID FAR LinkerOptions(HWND parent);

int FAR FileAlreadyIn (LPSTR id);
BOOL FAR CheckIfSource (LPSTR file);
int FAR AllFilesThere (void);

void FAR CompileFile (HWND hwnd);
BOOL FAR MakeProject(HWND hWndActive, LPINT uptodate, BOOL checkIfMakeNecessary);
void FAR BuildProject (HWND hWndActive);
void FAR LinkOnlyProject (HWND hWndActive);

void FAR RemoveDependMatrix ();
void FAR MakeDependMatrix ();

void FAR CollectFiles (HWND hWndActive);
void FAR FreeCollectedFiles (void);

void FAR CompilerHelp (WORD wCmd,DWORD dwData);

void InitMessageWindow (HWND hWndClient);
void FAR RemoveMessageWindow (void);


#endif