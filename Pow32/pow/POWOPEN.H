#ifndef _INC_POWOPEN

#include "..\powsup\powsupp.h"

typedef void FAR OWNERDRAWPROC (LPDRAWITEMSTRUCT,LPRECT,BOOL);

typedef struct {  /* list of file extensions */
    char ext[MAXPATHLENGTH];
    char doc[256];
} EXT;
typedef EXT far *LPEXT;

extern BOOL SaveAs;
extern int lastSel;
extern int Extensions;
extern int srcN,addN;
extern EXT PrjExt[1],TplExt[1],AllExt[1],CfgExt[1],ExeExt[5];
//extern LPEXT FileTypes;
extern LPEXT SrcExt;
extern LPEXT AddExt;

/* exported procedures */
extern BOOL FAR FileExists (LPSTR pch);
extern void FAR GetFileName (LPSTR lpstr,LPSTR capt,BOOL as,LPEXT ext,int exts,HWND parent);
extern int FAR ChooseDirectory (LPSTR startdir,LPSTR title,HWND parent);

#define _INC_POWOPEN
#endif
