#include <windows.h>
#include <stdlib.h>

#define IDERR_SUCCESS 0
#define IDERR_READFAIL 1
#define IDERR_FILETYPEBAD 2
#define IDERR_EXETYPEBAD 3
#define IDERR_WINVERSIONBAD 4
#define IDERR_RESTABLEBAD 5

#define OS2EXE 1
#define WINDOWSEXE 2

typedef unsigned short USHORT;
typedef unsigned long DWORD;
typedef unsigned char BYTE;
typedef unsigned int WORD;

typedef struct {
    USHORT ehSignature;
    USHORT ehcbLP;
    USHORT ehcp;
    USHORT ehcRelocation;
    USHORT ehcParagraphHdr;
    USHORT ehMinAlloc;
    USHORT ehMaxAlloc;
    USHORT ehSS;
    USHORT ehSP;
    USHORT ehCheckSum;
    USHORT ehIP;
    USHORT ehCS;
    USHORT ehlpRelocation;
    USHORT ehOberlayNo;
    USHORT ehReservedd[16];
    long ehPosNewHdr;
} EXEHDR;

typedef struct {
    WORD nhSignature;
    char nhVer;
    char nhRev;
    WORD nhoffEntryTable;
    WORD nhcbEntryTable;
    long nhCRC;
    WORD nhFlags;
    WORD nhAutoData;
    WORD nhHeap;
    WORD nhStack;
    long nhCSIP;
    long nhSSSP;
    WORD nhcSeg;
    WORD nhcMod;
    WORD nhcbNonResNameTable;
    WORD nhoffSegTable;
    WORD nhoffResourceTable;
    WORD nhoffResNameTable;
    WORD nhoffModRefTable;
    WORD nhoffImpNameTable;
    long nhoffNonResNameTable;
    WORD nhcbMovableEntries;
    WORD nhcAlign;
    WORD ncCRes;
    BYTE nhExeType;
    BYTE nhFlagsOther;
    WORD nhGangStart;
    WORD nhGangLength;
    WORD nhSwapArea;
    WORD nhExpVer;
} NEWHDR;

typedef struct {
    WORD rtType;
    WORD rtCount;
    long rtProc;
} RESTYPEINFO;

typedef struct {
    USHORT rnOffset;
    USHORT rnLength;
    USHORT rnFlags;
    USHORT rnID;
    USHORT rnHandle;
    USHORT rnUsage;
} RESNAMEINFO;

typedef struct {
    RESTYPEINFO rt;
    RESNAMEINFO rn[1];
} RESTABLE;

typedef struct {
    BYTE bWidth;
    BYTE bHeight;
    BYTE bColorCount;
    BYTE bReserved;
    WORD wPlanes;
    WORD wBitCount;
    DWORD dwBytesInRes;
    WORD wNameOrdinal;
} RESDIRECTORY;

typedef struct {
    BYTE fTypeFlag;
    WORD wTypeOrdinal;
    BYTE fNameFlag;
    WORD wNameOrdinal;
    WORD wMemoryFlags;
    DWORD lSize;
} RESOURCEHEADER;

typedef RESNAMEINFO far *LPRESNAMEINFO;
typedef RESTABLE far *LPRESTABLE;


int ReadOldExeHeader (int fil,long flen,long *posHdr)
{
    int len;
    EXEHDR oldHeader;

    if (_llseek(fil,0,0)==-1)
        return IDERR_READFAIL;

    len=_lread(fil,&oldHeader,sizeof(oldHeader));

    if (len!=sizeof(oldHeader))
        return IDERR_READFAIL;
    else if (oldHeader.ehSignature!=0x5a4d)
        return IDERR_FILETYPEBAD;
    else if (oldHeader.ehPosNewHdr<sizeof(EXEHDR))
        return IDERR_EXETYPEBAD;
    else if (oldHeader.ehPosNewHdr>flen-sizeof(NEWHDR))
        return IDERR_EXETYPEBAD;
    else
        *posHdr=oldHeader.ehPosNewHdr;

    return IDERR_SUCCESS;
}

int ReadNewExeHeader (int fil,long flen,long posHdr,long *posRes)
{
    int len;
    WORD wVersion;
    NEWHDR newHeader;

    if (_llseek(fil,posHdr,0)==-1)
        return IDERR_READFAIL;

    wVersion=(WORD)((GetVersion()>>8) | (GetVersion()<<8));

    len=_lread(fil,&newHeader,sizeof(newHeader));

    if (len!=sizeof(newHeader))
        return IDERR_READFAIL;
    else if (newHeader.nhSignature!=0x454e)
        return IDERR_FILETYPEBAD;
    else if (newHeader.nhExeType!=WINDOWSEXE)
        return IDERR_EXETYPEBAD;
    else if (newHeader.nhExpVer>wVersion)
        return IDERR_WINVERSIONBAD;
    else if (newHeader.nhoffResourceTable==0)
        return IDERR_RESTABLEBAD;
    else {
        *posRes=posHdr+newHeader.nhoffResourceTable;
        if (newHeader.nhExpVer<0x300) {
            newHeader.nhExpVer=0x300;
            _llseek(fil,posHdr,0);
            _lwrite(fil,&newHeader,sizeof(newHeader));
        }
    }
    return IDERR_SUCCESS;
}

int ReadExeFile (int fil)
{
    int err;
    long flen;
    long lPosNewHdr,lPosResTable;

    err=ReadOldExeHeader(fil,flen,&lPosNewHdr);

    if (err==IDERR_SUCCESS)
        err=ReadNewExeHeader(fil,flen,lPosNewHdr,&lPosResTable);

    return err;
}

int PASCAL WinMain (HANDLE hInst,HANDLE hPrev,LPSTR lpCmd,int nCmd)
{
    int exe;

    if (*lpCmd && (exe=_lopen(lpCmd,OF_READWRITE))!=-1)
        return ReadExeFile(exe);
    else
        return 0;
}


