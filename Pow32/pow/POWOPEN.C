/**************************************************************************
 *                                                                        *
 *  MODULE  : PowOpen.c                                                   *
 *                                                                        *
 *  PURPOSE : Contains the file open dialog function and it's helper      *
 *            functions.                                                  *
 *                                                                        *
 *  FUNCTIONS:                                                            *
 *                                                                        *
 *        GetFileName       - Gets a file name from the user.             *
 *        ChooseDirectory   - Select a directory                          *
 *                                                                        *
 **************************************************************************/


#include <dos.h>
#include <direct.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include <commdlg.h>
#include <dlgs.h>

#include "pow.h"
#include "powopen.h"
#include "powhelp.h"

#undef HIWORD
#undef LOWORD

#define HIWORD(l) (((WORD*)&(l))[1])
#define LOWORD(l) (((WORD*)&(l))[0])

BOOL SaveAs;
int srcN=1;           /* number of source extensions */
int addN=1;           /* number of add-to-project extensions */
int lastSel;
int Extensions;
LPSTR FileSel;
EXT PrjExt[]= {{"*.prj","Project File (*.prj)"}},  
    TplExt[]= {{"*.tpl","Project Template (*.tpl)"}},
    CfgExt[]= {{"*.cfg","Config. File (*.cfg)"}},
    AllExt[]= {{"*.*","All Files (*.*)"}},
    ExeExt[]= {{"*.exe","Exe-Files (*.exe)"},
               {"*.com","Com-Files (*.com)"},
               {"*.bat","Batch-Files (*.bat)"},
               {"*.pif","Pif-Files (*.pif)"},
               {"*.*","All Files (*.*)"}};
LPEXT //FileTypes,
      SrcExt=(LPEXT)&AllExt,
      AddExt=(LPEXT)&AllExt;


/**************************************************************************
 *                                                                        *
 *  FUNCTION   : FileExists(pch)                                          *
 *                                                                        *
 *  PURPOSE    : Checks to see if a file exists with the path/filename    *
 *               described by the string pointed to by 'pch'.             *
 *                                                                        *
 *  RETURNS    : TRUE  - if the described file does exist.                *
 *               FALSE - otherwise.                                       *
 *                                                                        *
 **************************************************************************/

BOOL FAR FileExists (LPSTR pch)
{
    int fh;

    if ((fh = _lopen(pch, 0)) < 0)
         return(FALSE);

    _lclose(fh);
    return(TRUE);
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : GetFilename (lpstr)                                      *
 *                                                                        *
 *  PURPOSE    : Gets a filename from the user by calling the File/Open   *
 *               dialog.                                                  *
 *                                                                        *
 **************************************************************************/

void FAR GetFileName (LPSTR lpstr,LPSTR capt,BOOL as,LPEXT ext,int exts,HWND parent)
{
    int i;
    OPENFILENAME ofn;
    char filter[1000],title[100],*s;
          
    *filter=0;
    for (i=0;i<exts;i++) {
       strcat(filter,ext[i].doc);
       strcat(filter,"|");
       strcat(filter,ext[i].ext);
       strcat(filter,"|");
    }
    strcat(filter,"|");
     
    s=filter;
    while (*s!=0) {
       if (*s=='|') *s=0;
       s++;
    }                
    
    memset(&ofn,0,sizeof(OPENFILENAME));

    ofn.lStructSize=sizeof(OPENFILENAME);
    ofn.hwndOwner=hwndFrame;
    ofn.lpstrFilter=filter;
    ofn.nFilterIndex=1;
    ofn.lpstrFile=lpstr;
    ofn.nMaxFile=100;
    ofn.lpstrFileTitle=title;
    ofn.nMaxFileTitle=sizeof(title);
    ofn.lpstrInitialDir=0;
    ofn.Flags=OFN_PATHMUSTEXIST|OFN_HIDEREADONLY;

    if (exts>0)
        ofn.lpstrDefExt=&(ext[0].ext[2]);
        
    if (as) {
       ofn.Flags|=OFN_OVERWRITEPROMPT;
       if (!GetSaveFileName(&ofn))
          *lpstr=0;
    }
    else
       if (!GetOpenFileName(&ofn))
          *lpstr=0;
           
    #ifndef _WIN32
       if (*lpstr)       
          AnsiLower(lpstr);
    #endif
}


/**************************************************************************
 *                                                                        *
 *  FUNCTION   : ChooseDirectoryHookProc (hwnd,msg,wParam,lParam)         *
 *                                                                        *
 *  PURPOSE    : Choose directory dialog box.                             *
 *               Select a directory (hooked common open dialog)           *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export ChooseDirectoryHookProc (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
{
    switch (msg) {

    case WM_COMMAND:
        
        switch (wParam) {

            case IDOK:
            
                SetWindowText(GetDlgItem(hdlg,edt1),"x");
                return 0; /* let commdlg.dll end the dialog */

            case IDCANCEL:

                EndDialog(hdlg,wParam);
                return 1;

            default:  
            
                break;
        }
        break;
        
    default:
    
        break;
    }
    return 0;
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : ChooseDirectory                                          *
 *                                                                        *
 *  PURPOSE    : Select an existing directory by calling the File/Open    *
 *               dialog.                                                  *
 *                                                                        *
 **************************************************************************/

int FAR ChooseDirectory (LPSTR startdir,LPSTR title,HWND parent)
{              
    int ret;
    FARPROC lpfn;
    OPENFILENAME ofn;
    char filename[_MAX_PATH];
          
    *filename=0;
    
    lpfn=MakeProcInstance(ChooseDirectoryHookProc,hInst);
    
    memset(&ofn,0,sizeof(OPENFILENAME));
    ofn.lStructSize=sizeof(OPENFILENAME);
    ofn.hwndOwner=parent;
    ofn.lpstrFile=filename;
    ofn.nMaxFile=sizeof(filename);
    ofn.lpstrInitialDir=startdir;
    ofn.lpstrTitle=title;
    ofn.lpfnHook=(UINT (CALLBACK *)(HWND,UINT,WPARAM,LPARAM))lpfn;
    ofn.lpTemplateName=MAKEINTRESOURCE(IDD_CHOOSEDIR);
    ofn.hInstance=hInst;
    ofn.Flags=OFN_PATHMUSTEXIST|OFN_HIDEREADONLY|OFN_ENABLEHOOK|OFN_ENABLETEMPLATE;

    ret=0;                        
    if (GetOpenFileName(&ofn)) {
       #ifndef _WIN32
          AnsiLower(filename);
       #endif   
       
       /* cut off the dummy filename */
       if (strlen(filename)>=1)
          filename[strlen(filename)-1]=0;
          
       strcpy(startdir,filename);
       ret=1;
    }
    
    FreeProcInstance(lpfn);
    return ret;
}
