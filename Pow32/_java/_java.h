/*************************************************************************
 *                                                                       *
 *  PROGRAM: _Java.h                                                     *
 *                                                                       *
 *  PURPOSE: Header of Pow! Compiler-Interface DLL for Java              *
 *                                                                       *
 *************************************************************************/

#if !defined (__java_h)
#define __java_h

#include "_java.rh"

#define HELPTOPIC_DIRECTORIES 3

#define MAXPATHLENGTH     256
#define CSW_OPTIMIZE    		2
#define CSW_NOWARNING	 		  4
#define CSW_NOBYTECODE     	8
#define CSW_JAVADEBUG      16

/* data types */
typedef struct {
	 int len;
	 HANDLE elem;
	 HANDLE next;
} LIST;

typedef LIST FAR *LPLIST;

extern DWORD ddeInstId;            /* DDEML instance handle of pow! */

#endif
