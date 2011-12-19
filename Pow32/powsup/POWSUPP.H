#ifndef _INC_POWSUPP

/* for WIN32 generation */
#include "..\pow\pow32.h"

/* dialog elements */
#define IDD_HELP        3
#define IDD_SETUP       4

/* shortcuts for independent directories */
#define PROJECT_DIR  1
#define POW_DIR      2
#define OTHER_DIR    3
#define RELATIVE_DIR 4

/* strings */
#define IDS_CANTWRITE   200
#define IDS_APPNAME     201

/* button ids of tool bar */
#define RIBBON_FIRST    IDD_BARSAVE
#define IDD_BARSAVE     10
#define IDD_BARPRINT    11
#define IDD_BAROPEN     12
#define IDD_BARCOMP     13
#define IDD_BARMAKE     14
#define IDD_BARRUN      15
#define IDD_BARABT      16
#define IDD_BARPRJ      17
#define RIBBON_LAST     IDD_BARPRJ

#define IDD_TOOL_FIRST  20
#define IDD_TOOL_LAST   50

/* data types */
typedef struct {
    int len;
    HANDLE elem;
    HANDLE next;
} LIST;

typedef LIST FAR *LPLIST;
typedef BOOL FAR PASCAL LISTELEMPROC(LPLIST);
typedef int FAR PASCAL COMPAREPROC(long,long);

/* exported procedures powlist.c*/
extern VOID FAR PASCAL _export PurgeList(LPHANDLE);
extern BOOL FAR PASCAL _export AddElem(LPHANDLE,long,int);
extern BOOL FAR PASCAL _export DelElem(LPHANDLE,int);
extern BOOL FAR PASCAL _export ChgElem(HANDLE,int,long,int);
extern BOOL FAR PASCAL _export MoveElem(LPHANDLE,int,int);
extern int FAR PASCAL _export GetElem(HANDLE,int,long);
extern HANDLE FAR PASCAL _export GetElemH(HANDLE,int);
extern int FAR PASCAL _export FindElem(HANDLE,long,int);
extern int FAR PASCAL _export CountList(HANDLE);
extern int FAR PASCAL _export LenElem(HANDLE,int);
extern VOID FAR PASCAL _export ListForEach (HANDLE,FARPROC);
extern BOOL FAR PASCAL _export AddSort(LPHANDLE,long,int,FARPROC);
extern BOOL FAR PASCAL _export AddStr(LPHANDLE,LPSTR);
extern BOOL FAR PASCAL _export DelStr(LPHANDLE,int);
extern int FAR PASCAL _export GetStr(HANDLE,int,LPSTR);
extern int FAR PASCAL _export FindStr(HANDLE,LPSTR);

/* exported procedures powmisc.c*/
extern void FAR PASCAL _export InitSupporterDLL (void);
extern void FAR PASCAL _export ExitSupporterDLL (void);
extern void FAR PASCAL _export ListToCombo (HANDLE,HWND,BOOL);
extern void FAR PASCAL _export ListToLBox (HANDLE,HWND);
extern void FAR PASCAL _export LBoxToList (HWND,LPHANDLE);
extern BOOL FAR PASCAL _export OpenOut (LPSTR);
extern BOOL FAR PASCAL _export OpenIn (LPSTR);
extern BOOL FAR PASCAL _export CloseOut (void);
extern BOOL FAR PASCAL _export CloseIn (void);
extern void FAR PASCAL _export PutStr (LPSTR);
extern void FAR PASCAL _export ReadBytes (LPSTR,int);
extern void FAR PASCAL _export WriteBytes (LPSTR,int);
extern void FAR PASCAL _export ReadStr (LPSTR);
extern void FAR PASCAL _export WriteStr (LPSTR);
extern void FAR PASCAL _export FileOut (LPSTR,int);
extern int FAR PASCAL _export FileIn (void far *,int);
extern void FAR PASCAL _export WriteList (HANDLE);
extern void FAR PASCAL _export ReadList (LPHANDLE);
extern char FAR PASCAL _export DownCase (char);
extern LPSTR FAR PASCAL _export DownStr (LPSTR);
extern BOOL FAR PASCAL _export Wildcard (LPSTR);
extern void FAR PASCAL _export MakeStr (long,LPSTR);
extern long FAR PASCAL _export MakeLon (LPSTR);
extern void FAR PASCAL _export ShrinkDir (LPSTR,LPSTR,LPSTR);
extern void FAR PASCAL _export StretchDir (LPSTR,LPSTR,LPSTR);
extern HFILE FAR PASCAL _export GetInFile (void);
extern HFILE FAR PASCAL _export GetOutFile (void);

#define MAXPATHLENGTH  256

#define _INC_POWSUPP
#endif
