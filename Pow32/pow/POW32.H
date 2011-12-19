/*
conditional defines for compiling Pow! with VC++ 2.2
*/

#ifndef INC_POW32
#define INC_POW32
         
#ifdef _WIN32

    #define _export 
    #define EZERO 0

    #define POWDSK "pow32.dsk"
    #define POWCFG "pow32.cfg"
    #define POWPRJ "pow32.prj"

    #define _fstrcpy(a,b) strcpy(a,b)
    #define _fstrcat(a,b) strcat(a,b)
    #define _fstrlen(a) strlen(a)
    #define _fstrstr(a,b) strstr(a,b)
    #define _fmemmove(a,b,c) memmove(a,b,c)

    #define INIFILESECTION "pow32"

#else

    #define INIFILESECTION "pow"

    #define POWDSK "pow.dsk"
    #define POWCFG "pow.cfg"
    #define POWPRJ "pow.prj"
#endif

#endif
