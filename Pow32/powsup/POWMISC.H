#ifndef _INC_POWMISC

#include "powsupp.h"

/* exported procedures */
extern void FAR PASCAL ListToCombo (HANDLE,HWND,BOOL);
extern void FAR PASCAL ListToLBox (HANDLE,HWND);
extern void FAR PASCAL LBoxToList (HWND,LPHANDLE);
extern BOOL FAR PASCAL OpenOut (LPSTR);
extern BOOL FAR PASCAL OpenIn (LPSTR);
extern BOOL FAR PASCAL CloseOut (void);
extern BOOL FAR PASCAL CloseIn (void);
extern void FAR PASCAL PutStr (LPSTR);
extern void FAR PASCAL ReadBytes (LPSTR,int);
extern void FAR PASCAL WriteBytes (LPSTR,int);
extern void FAR PASCAL ReadStr (LPSTR);
extern void FAR PASCAL WriteStr (LPSTR);   
extern void FAR PASCAL FileOut (LPSTR,int);
extern void FAR PASCAL FileIn (void far *,int);
extern BOOL FAR PASCAL PutListElem (LPLIST);
extern void FAR PASCAL WriteList (HANDLE);
extern void FAR PASCAL ReadList (LPHANDLE);
extern char FAR PASCAL DownCase (char);
extern LPSTR FAR PASCAL DownStr (LPSTR);
extern BOOL FAR PASCAL Wildcard (LPSTR);
extern BOOL FAR PASCAL DriveReady (int);
extern short FAR CDECL Message (HWND,BOOL,WORD,...);

#define _INC_POWMISC
#endif
