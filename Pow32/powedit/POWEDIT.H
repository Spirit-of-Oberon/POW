#ifndef INC_POWEDIT
#define INC_POWEDIT

#include <windows.h>
#include "..\pow\pow32.h"

/* data types */
typedef struct {
    char fontName[100];
    int fontSize;
    int tabWidth;
    BOOL autoIndent;
    BOOL useTabs;
    BOOL mouseTopic;
} Options;         
                      
extern Options options;
extern HINSTANCE hInstDLL;

#define IDD_OK     1
#define IDD_CANCEL 2
#define IDD_HELP   3
                                        
#define ID_EDIT    0xCAC                                        
                                        
#define PEM_SHOWLINENR      WM_USER+1000
#define PEM_SHOWINSERTMODE  WM_USER+1001
#define PEM_SHOWCHANGED     WM_USER+1002
#define PEM_DOUBLECLICK     WM_USER+1003

#define ID_ED_OPTIONS      100
#define IDD_ED_INDENT      101
#define IDD_ED_TABS        102
#define IDD_ED_TSIZE       103
#define IDD_ED_TEDIT       104
#define IDD_ED_FONT        105
#define IDD_ED_MOUNOT      106
#define IDD_ED_MOUTOPIC    107

#define ID_ED_PRINT        200
#define IDD_ED_PRINTDEVICE 201
#define IDD_ED_PRINTPORT   202
#define IDD_ED_PRINTTITLE  203

#define ID_ED_FONT         300
#define ID_ED_FONTTYPE     1136
#define ID_ED_FONTSIZE     1138

#endif
