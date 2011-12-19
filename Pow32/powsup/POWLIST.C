/***************************************************************************
 *                                                                         *
 *  MODULE    : PowList.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for a generic (unsorted) list            *
 *              and an extension for string-lists                          *
 *                                                                         *
 *  FUNCTIONS : AddElem - add element (address=<long>,size=int) to list    *
 *                                                                         *
 *              DelElem - purge element                                    *
 *                                                                         *
 *              GetElem - read an element                                  *
 *                                                                         *
 *              GetElemP - get address of an element                       *
 *                                                                         *
 *              ChgElem - change content of node                           *
 *                                                                         *
 *              LenElem - return length of element                         *
 *                                                                         *
 *              FindElem - search for a specific element                   *
 *                                                                         *
 *              MoveElem - moves internal position of list element         *
 *                                                                         *
 *              PurgeList - purge entire list                              *
 *                                                                         *
 *              CountList - return number of elements                      *
 *                                                                         *
 *              AddStr - add a string element                              *
 *                                                                         *
 *              DelStr - delete a string                                   *
 *                                                                         *
 *              GetStr - read a string                                     *
 *                                                                        *
 *              FindStr - search a string                                  *
 *                                                                         *
 *              AddStrSort - add string in sorted order                    *
 *                                                                         *
 ***************************************************************************/

#include <string.h>
#include <windows.h>

#include "powsupp.h"


/* create new list node */
HANDLE NewNode ()
{
    return GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,sizeof(LIST));
}

/* purge entire list */
VOID FAR PASCAL _export PurgeList (LPHANDLE list)
{
    HANDLE next;
    LPLIST l;
    while (*list!=0) {
        l=(LPLIST)GlobalLock(*list);
        next=l->next;
        if (l->elem!=0)
            GlobalFree(l->elem);
        GlobalUnlock(*list);
        GlobalFree(*list);
        *list=next;
    }
}

/* add a single element */
BOOL FAR PASCAL _export AddElem (LPHANDLE list,long adr,int len)
{
    HANDLE new,nxt,old,ele;
    LPLIST l;

    /* allocate memory for element */
    if ((new=NewNode())!=0) {
        if ((ele=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,len))!=0) {
            if (*list==0)
                *list=new;
            else {
                nxt=*list;
                while ((l=(LPLIST)GlobalLock(nxt))->next!=0) {
                    old=nxt;
                    nxt=l->next;
                    GlobalUnlock(old);
                }
                l->next=new;
                GlobalUnlock(nxt);
            }
            l=(LPLIST)GlobalLock(new);
            l->next=0;
            l->elem=ele;
            l->len=len;

            #ifdef _WIN32
                memmove(GlobalLock(ele),(LPVOID)adr,len);
            #else
                _fmemmove(GlobalLock(ele),(void _far *)adr,len);
            #endif

            GlobalUnlock(ele);
            //DEBUG GlobalUnlock(l->elem);
            GlobalUnlock(new);
            return TRUE;
        }
        else
            GlobalFree(new);
    }
    return FALSE;
}

/* delete the i-th element */
BOOL FAR PASCAL _export DelElem (LPHANDLE list,int i)
{
    HANDLE elem,last;
    LPLIST l;

    elem=last=*list;
    while ((elem!=0) && (i>0)) {
        i--;
        if (i==0) {
            l=(LPLIST)GlobalLock(elem);
            if (l->elem!=0)
                GlobalFree(l->elem);
            if (elem==*list)
                *list=l->next;
            else {
                ((LPLIST)GlobalLock(last))->next=l->next;
                GlobalUnlock(last);
            }
            GlobalUnlock(elem);
            GlobalFree(elem);
            return TRUE;
        }
        else {
            last=elem;
            elem=((LPLIST)GlobalLock(elem))->next;
            GlobalUnlock(last);
        }
    }
    /* index is zero or too high */
    return FALSE;
}

/* return length of element */
int FAR PASCAL _export LenElem (HANDLE list,int i)
{
    int len;
    LPLIST l;
    HANDLE old;

    while ((list!=0) && (i>0)) {
        i--;
        l=(LPLIST)GlobalLock(list);
        if (i==0) {
            len=l->len;
            GlobalUnlock(list);
            return len;
        }
        else {
            old=list;
            list=l->next;
            GlobalUnlock(old);
        }
    }
    return 0;
}

/* change content of i-th element */
BOOL FAR PASCAL _export ChgElem (HANDLE list,int i,long adr,int len)
{
    LPLIST l;
    HANDLE old,ele;

    while ((list!=0) && (i>0)) {
        i--;
        l=(LPLIST)GlobalLock(list);
        if (i==0) {
            if ((ele=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,len))!=0) {
                GlobalFree(l->elem);
                #ifdef _WIN32
                    memmove(GlobalLock(ele),(LPVOID)adr,len);
                #else
                    _fmemmove(GlobalLock(ele),(void _far *)adr,len);
                #endif
                GlobalUnlock(ele);
                l->elem=ele;
            }
            GlobalUnlock(list);
            return (ele!=0);
        }
        else {
            old=list;
            list=l->next;
            GlobalUnlock(old);
        }
    }
    return FALSE;
}

/* move internal position of a single list element */
BOOL FAR PASCAL _export MoveElem (LPHANDLE list,int old,int new)
{
    int len;
    int n;
    HANDLE ele;
    HANDLE bak;
    HANDLE node;
    LPLIST l,nod;

    /* get old element */
    n=CountList(*list);
    len=LenElem(*list,old);
    if ((old>0) && (new>0) && (old<=n) && (new<=n) && (len>0) &&
        ((ele=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,len))!=0)) {
        GetElem(*list,old,(long)GlobalLock(ele));
        GlobalUnlock(ele);
        DelElem(list,old);

        if ((node=NewNode())!=0) {
            l=(LPLIST)GlobalLock(node);
            l->len=len;
            l->elem=ele;
            /* new head position */
            if (new==1) {
                l->next=*list;
                *list=node;
            }
            /* mid position */
            else {
                ele=*list;
                nod=(LPLIST)GlobalLock(ele);
                while (--new>1) {
                    bak=ele;
                    ele=nod->next;
                    GlobalUnlock(bak);
                    nod=(LPLIST)GlobalLock(ele);
                }
                l->next=nod->next;
                nod->next=node;
                GlobalUnlock(ele);
            }
            GlobalUnlock(node);
            return TRUE;
        }
    }
    return FALSE;
}

/* get the i-th element and return its length in bytes */
int FAR PASCAL _export GetElem (HANDLE list,int i,long adr)
{
    int len;
    LPLIST l;
    HANDLE old;

    while ((list!=0) && (i>0)) {
        i--;
        l=(LPLIST)GlobalLock(list);
        if (i==0) {
            len=l->len;
            if (len>0) {
                _fmemmove((void far *)adr,GlobalLock(l->elem),len);
                GlobalUnlock(l->elem);
            }
            GlobalUnlock(list);
            return len;
        }
        else {
            old=list;
            list=l->next;
            GlobalUnlock(old);
        }
    }
    return 0;
}

/* get a pointer to the i-th element */
HANDLE FAR PASCAL _export GetElemH (HANDLE list,int i)
{
    LPLIST l;
    HANDLE old,h;

    while ((list!=0) && (i>0)) {
        i--;
        l=(LPLIST)GlobalLock(list);
        if (i==0) {
            h=l->elem;
            GlobalUnlock(list);
            return h;
        }
        else {
            old=list;
            list=l->next;
            GlobalUnlock(old);
        }
    }
    return 0;
}

/* search for an element and return its */
/* index (if found), else return 0 */
int FAR PASCAL _export FindElem (HANDLE list,long adr,int len)
{
    int i;
    HANDLE old;
    LPLIST l;
    LPSTR p;

    i=0;
    while (list!=0) {
        i++;
        l=(LPLIST)GlobalLock(list);
        if (l->elem!=0) {
            p=(LPSTR)GlobalLock(l->elem);
            p=(LPSTR)adr;
            GlobalUnlock(l->elem);
        }
        if ((l->elem!=0) &&
            #ifdef _WIN32
                (memcmp(GlobalLock(l->elem),(LPVOID)adr,len)==0)) {
            #else
                (_fmemcmp(GlobalLock(l->elem),(void _far *)adr,len)==0)) {
            #endif
            GlobalUnlock(l->elem);
            GlobalUnlock(list);
            return i;
        }
        else {
            old=list;
            list=l->next;
            GlobalUnlock(l->elem);
            GlobalUnlock(old);
        }
    }
    /* element not found */
    return 0;
}

/* return the number of elements in the list */
int FAR PASCAL _export CountList (HANDLE list)
{
    int i;
    HANDLE old;

    i=0;
    while (list!=0) {
        old=list;
        list=((LPLIST)GlobalLock(list))->next;
        GlobalUnlock(old);
        i++;
    }
    return i;
}

/* for each element: call a procedure */
VOID FAR PASCAL _export ListForEach (HANDLE list,FARPROC proc)
{
    HANDLE old;
    LPLIST l;

    while (list!=0) {
        l=(LPLIST)GlobalLock(list);
        if (((LISTELEMPROC *)proc)(l)) {
            old=list;
            list=l->next;
            GlobalUnlock(old);
        }
        else {
            //DEBUG GlobalUnlock(old); old durch list ersetzt
            GlobalUnlock(list);
            return;
        }
    }
}

/* add a string to the list */
BOOL FAR PASCAL _export AddStr (LPHANDLE list,LPSTR str)
{
    /* dont forget trailing 0 */
    return AddElem(list,(long)str,(int)(lstrlen(str)+1));
}

/* delete i-th string */
BOOL FAR PASCAL _export DelStr (LPHANDLE list,int i)
{
    return DelElem(list,i);
}

/* get i-th string */
int FAR PASCAL _export GetStr (HANDLE list,int i,LPSTR str)
{
    return GetElem(list,i,(long)str);
}

/* return index of given string (or 0, if not found) */
int FAR PASCAL _export FindStr (HANDLE list,LPSTR str)
{
    return FindElem(list,(long)str,(int)lstrlen(str)+1);
}

/* add in sorted order */
BOOL FAR PASCAL _export AddSort (LPHANDLE list,long adr,int len,FARPROC comp)
{
    LPLIST l,k;
    HANDLE new,ele,nxt,old;

    nxt=*list;
    old=0;

    while (nxt) {

        l=(LPLIST)GlobalLock(nxt);
        if (((COMPAREPROC *)comp)((long)GlobalLock(l->elem),adr)>0) {

            if ((new=NewNode())) {
                if ((ele=GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE,len))) {

                    /* fill list element with data */
                    k=(LPLIST)GlobalLock(new);
                    k->next=nxt;
                    k->elem=ele;
                    k->len=len;
                    #ifdef _WIN32
                        memmove(GlobalLock(ele),(LPVOID)adr,len);
                    #else
                        _fmemmove(GlobalLock(ele),(void _far *)adr,len);
                    #endif
                    GlobalUnlock(ele);

                    /* put in list */
                    if (!old)
                        *list=new;
                    else {
                        ((LPLIST)GlobalLock(old))->next=new;
                        GlobalUnlock(old);
                    }

                    GlobalUnlock(l->elem);
                    GlobalUnlock(new);    
                    GlobalUnlock(nxt); //DEBUG neue Zeile
                    return TRUE;
                }
                else
                    GlobalFree(new);
            }
            GlobalUnlock(l->elem);  //DEBUG neue Zeile
            GlobalUnlock(nxt);      //DEBUG neue Zeile
            return FALSE;
        }
        GlobalUnlock(l->elem);
        old=nxt;
        nxt=l->next;
        GlobalUnlock(old);
    }
    return AddElem(list,adr,len);
}


