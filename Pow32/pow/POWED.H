#ifndef INC_POWED
#define INC_POWED

#include <windows.h>

#define PEM_SHOWLINENR      WM_USER+1000
#define PEM_SHOWINSERTMODE  WM_USER+1001
#define PEM_SHOWCHANGED     WM_USER+1002
#define PEM_DOUBLECLICK     WM_USER+1003

extern FARPROC getFirstBufferProc;
extern FARPROC getNextBufferProc;
extern FARPROC editLoadOpenProc;
extern FARPROC editLoadReadProc;
extern FARPROC editLoadCloseProc;
extern FARPROC editReplaceProc;

BOOL far UseNewEditor (void);
BOOL far CloseEditor (void);
BOOL far EditorIsOpen (void);
BOOL far IsEditWindow (HWND);

int far EditInterfaceVersion (void);
void far EditNewEditWindow (HWND parent,BOOL readOnly);
void far EditCloseEditWindow (HWND edit);
int far EditHasChanged (HWND edit);
int far EditLoadFile (HWND edit,LPSTR name);
int far EditSaveFile (HWND edit,LPSTR name);
void far EditGetCursorpos (HWND edit,LPLONG row,LPLONG col);
int far EditCopy (HWND edit);
int far EditPaste (HWND edit);
int far EditCut (HWND edit);
int far EditClear (HWND edit);
void far EditUndo (HWND edit);
void far EditRedo (HWND edit);
int far EditHasSelection (HWND edit);
void far EditGotoPos (HWND edit,long row,long col);
int far EditSearch (HWND edit,LPSTR text,int matchcase,int down,int words);
int far EditReplace (HWND edit,LPSTR text,LPSTR newtext,int matchcase,int down,int words,int all,int ask);
void far EditEditOptions (void);
void far EditKeywords (int caseSensitive,LPSTR words);
void far EditSetCommandProcedure (FARPROC command);
void far EditComments (int nested,LPSTR on,LPSTR off,LPSTR strings);
void far EditSetHelpFile (LPSTR name);
long far EditGetFirstBuffer (HWND edit,LPSTR buf,long size);
long far EditGetNextBuffer (HWND edit,LPSTR buf,long size);
HGLOBAL far EditGetText (HWND edit);
int far EditGeneratesAscii (void);
long far EditLoadNextBuffer (LPHANDLE file,LPSTR buf,long size);
int far EditCanUndo (void);
int far EditPrint (HWND edit);
int far EditAddText (HWND edit,LPSTR text);
int far EditInsertText (HWND edit,LPSTR text);
void far EditResizeWindow (HWND edit,int dx,int dy);
void far EditResetContent (HWND edit);
int far EditGetLine (HWND edit,int line,int max,LPSTR buf);
void far EditShowHelp (HWND powwnd);
void far EditSetSyntax (void);
void far EditUnloadEditor (void);

#endif
