#ifndef _INC_POWFIND
#define _INC_POWFIND

extern BOOL FindDown;
extern BOOL FindCase;
extern BOOL FindWord;
extern HANDLE GotoList;
extern HANDLE FindList;
extern HANDLE ReplaceList;
extern char FindTxt[100];

VOID FAR Find (void);
VOID FAR Replace (void);
VOID FAR FindNext (void);
VOID FAR GotoLine (void);
BOOL FAR PASCAL FindDlgProc (HWND,WORD,WORD,LONG);
BOOL FAR PASCAL ReplaceDlgProc (HWND,WORD,WORD,LONG);
BOOL FAR PASCAL GotoLineDlgProc (HWND,WORD,WORD,LONG);

#endif
