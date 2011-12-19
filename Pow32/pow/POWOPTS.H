#ifndef _INC_POWOPTS

#include "powopen.h"

#define MINFONTSIZE 10
#define MAXFONTSIZE 40
#define MAXFONTNAMESIZE 40

typedef struct {
    int version;                    // was: BOOL createBack;
    BOOL dummy2;                    // was: BOOL autoIndent;
    BOOL dummy3;                    // was: BOOL bSpaceUnindent;
    BOOL dummy4;                    // was: BOOL useTabs;
    BOOL dummy5;                    // was: BOOL blockOverwrite;
    BOOL dummy6;                    // was: BOOL colourKeys;
    BOOL dummy7;                    // was: BOOL mouseTopic;
    char compiler[40];
    char editor[40];
    char dummy8[MAXFONTNAMESIZE];   // was: char font[MAXFONTNAMESIZE];
    int dummy9;                     // was: int tabSize;
    BOOL saveProject;
    BOOL saveDesk;
    BOOL saveConfig;
    BOOL ribbonOnBottom;
    BOOL searchIgnoreWarnings;
    BOOL dummy[20]; // for later usage without invalidating old files
} CONFIG;

/*
typedef BOOL FAR PASCAL DirOptProc (HANDLE,HWND);
typedef HANDLE FAR PASCAL InitProc (LPSTR,LPSTR,DWORD);
typedef BOOL FAR PASCAL AboutProc (HANDLE,HWND);
typedef int FAR PASCAL GetExtProc (HANDLE,LPEXT far *,LPINT,LPEXT far *,LPINT);
typedef void FAR PASCAL ExitProc (HANDLE);
typedef void FAR PASCAL GetHelpProc (HANDLE,LPSTR);



extern HANDLE actDLL;
extern char actDLLname[];
extern char far compilerHelpfile[80];
*/
extern CONFIG actConfig;
extern int showResized;

extern void FAR InitConfig (void);
extern void FAR ExitConfig (void);
extern void FAR OpenConfig (void);
extern void FAR SaveConfig (void);
extern BOOL FAR ReadConfig (LPSTR);
extern BOOL FAR WriteConfig (LPSTR);
extern void FAR SaveAsConfig (void);
extern void FAR GetDirectories(void);
extern void FAR GetPreferences(void);
extern BOOL FAR PASCAL GetPrefsDlgProc (HWND,WORD,WORD,LONG);
extern int FAR PASCAL EnumFontsProc (LPLOGFONT,LPTEXTMETRIC,int,LPSTR);
extern BOOL FAR PASCAL EnumChgChildFonts (HWND,DWORD);
extern BOOL FAR PASCAL EnumOpenWindows (HWND,DWORD);
extern void FAR SaveMemorize(void);
extern void FAR LoadMemorize(void);
extern void FAR WriteSizeOpenWindows(void);
extern void FAR ReadSizeOpenWindows(void);
extern void FAR UseNewCompiler(void);

#define _INC_POWOPTS
#endif
