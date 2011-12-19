/****************************************************************************
 *                                                                          *
 *  MODULE:    PowFind.c                                                    *
 *                                                                          *
 *  PURPOSE:   Code to do text searches in Pow.                             *
 *                                                                          *
 *  FUNCTIONS: FindText(wnd)  - Looks for the search string in window <wnd> *
 *                                                                          *
 ****************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <windows.h>
#include "powedit.h"

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])
                                                    
HWND FindWnd;                  /* edit window to examine */                                                    
BOOL DoReplace;                /* Replace/Find-Flag */
BOOL FindAsk=TRUE;             /* Ask before replacing */
BOOL FindDown=TRUE;            /* Default search dir is down */
BOOL FindCase=FALSE;           /* Turn case sensitivity off */
BOOL FindWord=FALSE;           /* Find whole word */
LPSTR FindTxt;                 /* Initialize search string  */
LPSTR ReplaceTxt;              /* Initialize replace string  */


BOOL NoEndWord (char c)
{
    return (c>='0' && c<='9') || (c>='A' && c<='Z') || (c>='a' && c<='z');
}

BOOL Compare (LPSTR wndTxt,LPSTR find)
{
    if (FindCase) {
        while (*find)
            if (*wndTxt++ != *find++)
                return FALSE;
        if (FindWord && NoEndWord(*wndTxt))
            return FALSE;
    }
    else {
        while (*find) {
            if (tolower(*wndTxt)!=tolower(*find))
                return FALSE;
            wndTxt++;
            find++;
        }
        if (FindWord && NoEndWord(*wndTxt))
            return FALSE;
    }
    return TRUE;
}

BOOL SearchText (void)
{
    LONG sel;
    HANDLE h;
    LPSTR pos,start;
    unsigned nrcompares,increment,txtlen;

    increment=(FindDown)?1:-1;

    if (!*FindTxt)
        return FALSE;

    /* get the handle to the text buffer and lock it */
    h=(HANDLE)SendMessage(FindWnd,EM_GETHANDLE,0,0L);

    /* find the current selection range */
    sel=SendMessage(FindWnd,EM_GETSEL,0,0L);
    start=(LPSTR)LocalLock(h);

    /* get the length of the text */
    txtlen=(WORD)SendMessage(FindWnd,WM_GETTEXTLENGTH,0,0L);

    /* if selection, start with next character in selected range */
    pos=start+LOWORD(sel);
    if (LOWORD(sel)!=HIWORD(sel))
        pos+=increment;

    /* compute how many characters are before/after the current selection */
    if (increment<0)
        nrcompares=(pos-start)+1;
    else
        nrcompares=txtlen-(pos-start)-strlen(FindTxt)+2;

    /* while there are uncompared substrings... */
    while (nrcompares) {

        /* word start? */
        if ((!FindWord) || (pos==start) || (!NoEndWord(*(pos-1)))) {
        
            /* does this substring match? */
            if (Compare(pos,FindTxt)) {
            
                /* yes, unlock the buffer.*/
                LocalUnlock(h);

                /* select the located string */
                LOWORD(sel)=pos-start;
                HIWORD(sel)=LOWORD(sel)+strlen(FindTxt);
                SendMessage (FindWnd,EM_SETSEL,0,sel);
                SendMessage (FindWnd,EM_SCROLLCARET,0,0);
                                         
                /* find or replace? */
                if (DoReplace && (!FindAsk || MessageBox(FindWnd,"Replace Selection?","",MB_OKCANCEL|MB_ICONQUESTION)==IDOK))
                    SendMessage(FindWnd,EM_REPLACESEL,0,(long)(LPSTR)ReplaceTxt);

                return TRUE;
            }
        }
        nrcompares--;
        pos+=increment;
    }

    /* not found... unlock buffer. */
    LocalUnlock(h);
    return FALSE;
}
