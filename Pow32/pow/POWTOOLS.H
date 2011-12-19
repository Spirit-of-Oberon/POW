#ifndef _INC_POWTOOLS

#define MAXTOOLBMPS 50
#define MAXTOOLBUTTONS 15
#define ICONHEIGHT 22
#define VIADDESIGNATURE 0x12345678

#define NEW_TOOLS_VERSION 9999  // must be greater than max. possible tools

typedef struct {
    BOOL Menu;
    BOOL Button;
    BOOL AskArg;
    BOOL ToTop;
    int ButtonId;
    char Text1[80]; 
    char Text2[80];
    char MenuText[80];
    char Arg[100];
    char Type;  // 'X'=EXE,'L'=DLL,'E'=DDE
} OLDTOOLFORMAT;

typedef struct {
    BOOL Menu;
    BOOL Button;
    BOOL AskArg;
    BOOL ToTop;
    int ButtonId;
    char Text1[80]; 
    char Text2[80];
    char MenuText[80];
    char Arg[100];
    char Type;  // 'X'=EXE,'L'=DLL,'E'=DDE
    BOOL AutoStart;
    long ViaDDE;   // TRUE if tool was appended by DDE call (must not be destroyed when reading configuration)
    char Reserved[100-sizeof(long)];    // reserved for future extensions
} TOOL;

typedef TOOL FAR *LPTOOL;

extern HANDLE ToolList;
extern int toolButtons;
extern int toolImage[MAXTOOLBUTTONS];
extern HWND hToolBut[MAXTOOLBUTTONS];

extern void FAR ToolDialog (HWND hwnd);
extern HANDLE FAR RunTool (WORD nr,BOOL fromMenu,BOOL absolute);
extern void FAR ToolMenu (void);
extern void FAR NewToolButtons (void);
extern BOOL FAR PASCAL ArgDlgProc (HWND,WORD,WORD,LONG);
extern void FAR AutoStartTools (void);
extern void FAR AutoStopTools (void);
extern BOOL FAR ToolAdd (LPSTR name,LPSTR command,LPSTR dir,LPSTR options,BOOL menu,int buttonId,BOOL toTop,BOOL askArg);
extern BOOL FAR ToolDelete (LPSTR name);

extern void DecodeArg (LPSTR src,LPSTR dst);

#define _INC_POWTOOLS
#endif
