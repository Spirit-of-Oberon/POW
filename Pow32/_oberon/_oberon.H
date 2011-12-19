#ifndef _INC_OBERON

/* default buttons */
#define IDD_OK      1
#define IDD_CANCEL  2
#define IDD_HELP    3

/* compiler and linker switches */
#define CSW_INDEX       0x0001
#define CSW_OVERFLOW    0x0002
#define CSW_RANGE       0x0004
#define CSW_TYPE        0x0008
#define CSW_NEWSYMFILE  0x0010
#define CSW_PTRINIT     0x0020
#define CSW_ASSERTEVAL  0x0040
#define CSW_LISTIMPORT  0x0100
#define CSW_BROWSESYM   0x0200
#define CSW_SMART       0x0400
#define CSW_NILCHECK    0x0800

#ifdef _WIN32
   #define CSW_DEBUGCOFF   0x0080
   #define CSW_DEBUGINFO   0x1000
   #define CSW_DEBUGCV5    0x2000
#else
   #define CSW_DEBUGINFO   0x0080
#endif

#define LSW_DEBUG       0x0100
#define LSW_CASE        0x0200
#define LSW_DLL         0x0400
#define LSW_DYNAMICRTS  0x0800
#define LSW_GARBAGE     0x1000
#define LSW_DYNAMICRTS  0x0800
#define LSW_CONSOLE     0x2000
#define LSW_NORTS       0x4000
#define LSW_DEBUGCV5    0x8000

/* compiler about box */
#define IDD_COMPABOUT      ID(100)
#define IDD_ABOUTCOMPVERS  101
#define IDD_ABOUTCOMPYEAR  102
#define IDD_ABOUTINTERVERS 103
#define IDD_ABOUTLINKVERS  104
#define IDD_ABOUTINTERYEAR 105
#define IDD_ABOUTLICENCE   106

/* compiler options dialog */
#define IDD_COMPILEROPT    ID(200)
#define IDD_COPTDEBUG      201
#define IDD_COPTOVER       202
#define IDD_COPTTYPE       203
#define IDD_COPTINDEX      204
#define IDD_COPTRANGE      205
#define IDD_COPTPTRINIT    206  
#define IDD_COPTASSERTEVAL 207
#define IDD_COPTNILCHECK   208
#define IDD_COPTSMART      209
#define IDD_COPTDEBUGCV    210
#define IDD_COPTDEBUGCOFF  211
#define IDD_COPTDEBUGNONE  212
#define IDD_COPTDEBUGCV5   213

/* linker options dialog */
#define IDD_LINKEROPT      ID(300)
#define IDD_LOPTFUNC       301
#define IDD_LOPTFEDIT      302
#define IDD_LOPTEXPORTS    303
#define IDD_LOPTEXPLIST    304
#define IDD_LOPTEXPADD     305
#define IDD_LOPTEXPDEL     306
#define IDD_LOPTDEBUG      311
#define IDD_LOPTCASE       312
#define IDD_LOPTSTACK      313
#define IDD_LOPTSTSIZE     314
#define IDD_LOPTHEAP       315
#define IDD_LOPTHESIZE     316
#define IDD_LOPTDLL        317
#define IDD_LOPTDYNAMICRTS 318
#define IDD_LOPTGARBAGE    319
#define IDD_LOPTMODULE     320
#define IDD_LOPTMODULELIST 321
#define IDD_LOPTMODULEADD  322
#define IDD_LOPTMODULEDEL  323
#define IDD_LOPTCONSOLE    324
#define IDD_LOPTWIN32      325
#define IDD_LOPTNORTS      326
#define IDD_LOPTSTATICRTS  327
#define IDD_LOPTBASE       328
#define IDD_LOPTENTRY      329
#define IDD_LOPTNOLINK     330

/* search directory dialog */
#define IDD_GETDIRS     ID(400)
#define IDD_DIRSEXE     401
#define IDD_DIRSEXEEDIT 402
#define IDD_DIRSOBJ     403
#define IDD_DIRSOBJEDIT 404

/* window messages for compiler call */
#define WM_COMPILE      (WM_USER+1)
#define WM_TERMINATE    (WM_USER+2)

/* about bitmap */
#define IDB_ABOUT       102

extern DWORD ddeInstId;  // DDEML instance handle of Pow!

#define _INC_OBERON
#endif
