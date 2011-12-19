/***************************************************************************
 *                                                                         *
 *  MODULE    : PowTools.c                                                 *
 *                                                                         *
 *  PURPOSE   : Contains the code for the Tools-Options of Pow!            *
 *                                                                         *
 *  FUNCTIONS : ToolDialog     - The dialog of adding/deleting tools       *
 *              RunTool        - Execute a predefined tool                 *
 *              AutoStartTools - Execute tools on Pow! startup             *
 *              AutoEndTools   - Stop tools on Pow! exit                   *
 *                                                                         *
 ***************************************************************************/

#include <io.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <direct.h>
#include <windows.h>
#include <ddeml.h>

#ifndef _WIN32
    #include <toolhelp.h>
#endif

#include "..\powsup\powsupp.h"
#include "pow.h"
#include "powcomp.h"
#include "powtools.h"
#include "powopen.h"
#include "powhelp.h"
#include "powribb.h"
#include "powopts.h"
#include "powrun.h"
#include "resource.h"
#include "powed.h"
#include "powCompiler.h"
                        
#define ARGTEXTLEN 128

/* globals */
BOOL buttonsChanged;
int actTool;
int toolButtons;
HANDLE ToolList;
HANDLE OldTools;
HANDLE AutoStartList;
HMENU ToolsMenu=0;
HWND hToolDlg;
WORD toolCnt;
LPSTR ArgText;
BOOL noUpdate;
TOOL tool;
int toolImage[MAXTOOLBUTTONS];
HBITMAP toolBmpBut,toolBmpButSel,toolBmp[MAXTOOLBMPS];
HWND hToolBut[MAXTOOLBUTTONS];

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : AddDllToolDlgProc (hwnd,msg,wParam,lParam)               *
 *                                                                        *
 *  PURPOSE    : Dialog box for dll-tools.                                *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export AddDllToolDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch(msg) {
                
    case WM_INITDIALOG: 

        SetFocus(GetDlgItem(hdlg,IDD_DLLNAMEEDIT));
        return TRUE;
    
    case WM_COMMAND:

        switch (wParam) {

            case IDOK:

                GetWindowText(GetDlgItem(hdlg,IDD_DLLNAMEEDIT),(LPSTR)tool.Text1,sizeof(tool.Text1));
                GetWindowText(GetDlgItem(hdlg,IDD_DLLFUNCTIONEDIT),(LPSTR)tool.Text2,sizeof(tool.Text2));
                GetWindowText(GetDlgItem(hdlg,IDD_DLLARGUMENTSEDIT),(LPSTR)tool.Arg,sizeof(tool.Arg));
                tool.Type='L';
                EndDialog(hdlg,wParam);
                break;

            case IDCANCEL:

                EndDialog(hdlg,wParam);
                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Einbinden_von_Software_Tools);
                break;

            default:

                return FALSE;
        }
        return TRUE;

    default:

        return FALSE;
    }
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : AddDdeToolDlgProc (hwnd,msg,wParam,lParam)               *
 *                                                                        *
 *  PURPOSE    : Dialog box for dde-tools.                                *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export AddDdeToolDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch(msg) {

    case WM_INITDIALOG:
    
        SetFocus(GetDlgItem(hdlg,IDD_DDESERVICEEDIT));
        return TRUE;
                
    case WM_COMMAND:

        switch (wParam) {

            case IDOK: 
            
                GetWindowText(GetDlgItem(hdlg,IDD_DDESERVICEEDIT),(LPSTR)tool.Text1,sizeof(tool.Text1));
                GetWindowText(GetDlgItem(hdlg,IDD_DDETOPICEDIT),(LPSTR)tool.Text2,sizeof(tool.Text2));
                GetWindowText(GetDlgItem(hdlg,IDD_DDEARGUMENTSEDIT),(LPSTR)&(tool.Arg),sizeof(tool.Arg));
                tool.Type='E';
                EndDialog(hdlg,wParam);
                break;

            case IDCANCEL:

                EndDialog(hdlg,wParam);
                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Einbinden_von_Software_Tools);
                break;

            default:

                return FALSE;
        }
        return TRUE;

    default:

        return FALSE;
    }
}

/**************************************************************************
 *                                                                        *
 *  Helper Functions for Tools dialog                                     *
 *                                                                        *
 *  FUNCTIONS :  ListTool - add a tools name to list box                  *
 *                                                                        *
 *               ShowTool - Display options of tool                       *
 *                                                                        *
 *               SaveList - Save old contents of tools options            *
 *                                                                        *
 *               ToolMenu - Update menu items                             *
 *                                                                        *
 *               MakeTool - Generate tool from inputs                     *
 *                                                                        *
 *               FindTool - Search for tool by menu text                  *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export ListTool (LPLIST list)
{
    LPTOOL tool=(LPTOOL)GlobalLock(list->elem);
    SendDlgItemMessage(hToolDlg,IDD_TOOLLIST,LB_ADDSTRING,0,(long)tool->MenuText);
    GlobalUnlock(list->elem);
    return TRUE;
}

void ShowTool (HWND hdlg,int n)
{       
    TOOL t;
    char type;
     
    if ((n>0) && (GetElem(ToolList,n,(long)(LPTOOL)&t)!=0)) {                  
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1,WM_SETTEXT,0,(long)(LPSTR)t.Text1);
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2,WM_SETTEXT,0,(long)(LPSTR)t.Text2);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUTEXT,WM_SETTEXT,0,(long)(LPSTR)t.MenuText);
        SendDlgItemMessage(hdlg,IDD_TOOLARG,WM_SETTEXT,0,(long)(LPSTR)t.Arg);
        SendDlgItemMessage(hdlg,IDD_TOOLASK,BM_SETCHECK,t.AskArg,0);
        SendDlgItemMessage(hdlg,IDD_TOOLTOTOP,BM_SETCHECK,t.ToTop,0);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUENTRY,BM_SETCHECK,t.Menu,0);
        SendDlgItemMessage(hdlg,IDD_TOOLSPEEDBUTTON,BM_SETCHECK,t.Button,0);
        SendDlgItemMessage(hdlg,IDD_TOOLAUTOSTART,BM_SETCHECK,t.AutoStart,0);
        SendDlgItemMessage(hdlg,IDD_TOOLICONLIST,LB_SETCURSEL,t.ButtonId,0);
        type=t.Type;
    }
    else if (n==-1) {                                    
        char c='\0';           
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1,WM_SETTEXT,0,(long)(LPSTR)tool.Text1);
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2,WM_SETTEXT,0,(long)(LPSTR)tool.Text2);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUTEXT,WM_SETTEXT,0,(long)(LPSTR)&c);
        SendDlgItemMessage(hdlg,IDD_TOOLARG,WM_SETTEXT,0,(long)(LPSTR)tool.Arg);
        SendDlgItemMessage(hdlg,IDD_TOOLASK,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLTOTOP,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUENTRY,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLSPEEDBUTTON,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLAUTOSTART,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLICONLIST,LB_SETCURSEL,0,0);
        type=tool.Type;
    }
    else {
        char c='\0';           
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1,WM_SETTEXT,0,(long)(LPSTR)&c);
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2,WM_SETTEXT,0,(long)(LPSTR)&c);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUTEXT,WM_SETTEXT,0,(long)(LPSTR)&c);
        SendDlgItemMessage(hdlg,IDD_TOOLARG,WM_SETTEXT,0,(long)(LPSTR)&c);
        SendDlgItemMessage(hdlg,IDD_TOOLASK,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLTOTOP,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLMENUENTRY,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLSPEEDBUTTON,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLAUTOSTART,BM_SETCHECK,0,0);
        SendDlgItemMessage(hdlg,IDD_TOOLICONLIST,LB_SETCURSEL,0,0);
        type='X';
    }

    switch (type) {
    case 'X':
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1NAME,WM_SETTEXT,0,(long)(LPSTR)"&Pathname:");
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2NAME,WM_SETTEXT,0,(long)(LPSTR)"&Initial Directory:");
        break;
    case 'L':
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1NAME,WM_SETTEXT,0,(long)(LPSTR)"&DLL Name:");
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2NAME,WM_SETTEXT,0,(long)(LPSTR)"&Function:");
        break;
    case 'E':
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT1NAME,WM_SETTEXT,0,(long)(LPSTR)"&DDE Service:");
        SendDlgItemMessage(hdlg,IDD_TOOLTEXT2NAME,WM_SETTEXT,0,(long)(LPSTR)"&Topic:");
    }
    actTool=n;
}

static void SaveList ()
{
    int n;
    TOOL tool;

    OldTools=0;
    for (n=1;n<=CountList(ToolList);n++) {
        GetElem(ToolList,n,(long)(LPTOOL)&tool);
        AddElem(&OldTools,(long)(LPTOOL)&tool,sizeof(TOOL));
    }
}

BOOL FAR PASCAL _export AddToolMenu (LPLIST list)
{
    int n;
    LPTOOL tool=(LPTOOL)GlobalLock(list->elem);    
    // is menu entry?
    if (tool->Menu) {
        toolCnt++;
        n=GetMenuItemCount(ToolsMenu);
        InsertMenu(ToolsMenu,n-1,MF_BYPOSITION|MF_STRING,IDM_TOOLS+toolCnt,(LPSTR)(tool->MenuText));
        GlobalUnlock(list->elem);
    }    
    return TRUE;
}

void FAR ToolMenu ()
{                          
    HMENU sub;
    FARPROC add;
    char txt[40];
    WORD item,subitems;

    /* get tools menu handle */               
    /* maybe strange, but necessary (popups change position, */
    /* if mdi-childs switch to and from full-size view) */
    ToolsMenu=0;        
    item=GetMenuItemCount(GetMenu(hwndFrame));
    while (item--) {
        sub=GetSubMenu(GetMenu(hwndFrame),item);
        subitems=GetMenuItemCount(sub);
        if (subitems && GetMenuItemID(sub,subitems-1)==IDM_TOOLSOPT) {
            ToolsMenu=GetSubMenu(GetMenu(hwndFrame),item);
            break;                                              
        }    
    }    
     
    /* only false, if someone plays with pow!-s resources */  
    if (ToolsMenu) {
        /* remove old menus */
        while (GetMenuItemCount(ToolsMenu))
            RemoveMenu(ToolsMenu,0,MF_BYPOSITION);
        toolCnt=0;

        /* add options menu */
        strcpy(txt,"&Options...");
        AppendMenu(ToolsMenu,MF_STRING,IDM_TOOLSOPT,(LPSTR)txt);

        /* add remaining tools */
        add=MakeProcInstance(AddToolMenu,hInst);
        ListForEach(ToolList,add);
        FreeProcInstance(add);
    }    
}

void MakeTool (HWND hdlg,LPTOOL tool,char type)
{
    GetWindowText(GetDlgItem(hdlg,IDD_TOOLTEXT1),(LPSTR)(tool->Text1),sizeof(tool->Text1));
    GetWindowText(GetDlgItem(hdlg,IDD_TOOLTEXT2),(LPSTR)(tool->Text2),sizeof(tool->Text2));
    GetWindowText(GetDlgItem(hdlg,IDD_TOOLMENUTEXT),(LPSTR)(tool->MenuText),sizeof(tool->MenuText));
    GetWindowText(GetDlgItem(hdlg,IDD_TOOLARG),(LPSTR)(tool->Arg),sizeof(tool->Arg));
    tool->AskArg=(BOOL)SendDlgItemMessage(hdlg,IDD_TOOLASK,BM_GETCHECK,0,0);
    tool->Button=(BOOL)SendDlgItemMessage(hdlg,IDD_TOOLSPEEDBUTTON,BM_GETCHECK,0,0);
    tool->Menu=(BOOL)SendDlgItemMessage(hdlg,IDD_TOOLMENUENTRY,BM_GETCHECK,0,0);
    tool->ToTop=(BOOL)SendDlgItemMessage(hdlg,IDD_TOOLTOTOP,BM_GETCHECK,0,0);
    tool->AutoStart=(BOOL)SendDlgItemMessage(hdlg,IDD_TOOLAUTOSTART,BM_GETCHECK,0,0);
    tool->Type=type;                                                         
    tool->ButtonId=(int)SendDlgItemMessage(hdlg,IDD_TOOLICONLIST,LB_GETCURSEL,0,0);
}

int FindTool (LPSTR id)
{
    int i;
    TOOL tool;

    for (i=1;i<=CountList(ToolList);i++) {
         GetElem(ToolList,i,(long)(LPTOOL)&tool);
         if (strcmp(id,tool.MenuText)==0)
             return i;
    }
    return 0;
}

void MemorizeTool (HWND hdlg,BOOL makeNew,char type)
{
    char txt[80];
    TOOL tool;

    MakeTool(hdlg,(LPTOOL)&tool,type);

    if (!*tool.MenuText) {
        lstrcpy((LPSTR)tool.MenuText,(LPSTR)tool.Text1);
        if (type!='X') {
            lstrcat((LPSTR)tool.MenuText,".");
            lstrcat((LPSTR)tool.MenuText,(LPSTR)tool.Text2);
        }         
        SetWindowText(GetDlgItem(hdlg,IDD_TOOLMENUTEXT),(LPSTR)tool.MenuText);
    }              

    if (makeNew) {
        int n;
        /* make new menu entry */             
        n=(int)SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_ADDSTRING,0,(long)(LPSTR)tool.MenuText);
        AddElem((LPHANDLE)&ToolList,(long)(LPTOOL)&tool,sizeof(TOOL));
        actTool=CountList(ToolList);
        SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,n,0);
    }              
    else {                  
        TOOL t;
        char buf[40];
        FARPROC list;
        /* update old entry */
        if (actTool>0) {
            SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETTEXT,actTool-1,(long)(LPSTR)buf);
                
            // buttons have changed?    
            GetElem(ToolList,actTool,(long)(LPSTR)&t);
            if ((t.Button && !tool.Button) ||
                (tool.Button && !t.Button) ||
                (tool.ButtonId!=t.ButtonId))
                buttonsChanged=TRUE;          
                
            ChgElem(ToolList,actTool,(long)(LPTOOL)&tool,sizeof(TOOL));
            if (strcmp(txt,buf)) {
                /* show new text in listbox */
                int sel=(int)SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETCURSEL,0,0);
                SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_RESETCONTENT,0,0);
                list=MakeProcInstance(ListTool,hInst);
                ListForEach(ToolList,list);
                FreeProcInstance(list);
                SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,sel,0);
            }
        }
    }
}

void UpdateTool (HWND hdlg)
{
    char type;                                                     
    TOOL t;
    
    if (!noUpdate) {
        if (actTool && GetElem(ToolList,actTool,(long)(LPSTR)&t))
            type=t.Type;
        else
            type=tool.Type;
        SendDlgItemMessage(hdlg,IDD_TOOLMENUTEXT,WM_GETTEXT,sizeof(tool.MenuText),(long)(LPSTR)tool.MenuText);                 
        MemorizeTool(hdlg,FALSE,type);
    }    
    else
        noUpdate=FALSE;
}

void NewTool (HWND hdlg,char type)
{
    tool.ToTop=FALSE;
    tool.Menu=TRUE;
    tool.Button=FALSE;
    tool.AskArg=FALSE;
    tool.AutoStart=FALSE;
    tool.ButtonId=0;
    tool.ViaDDE=0;
    
    MemorizeTool(hdlg,TRUE,type);
}

void AddTool (HWND hdlg,char type)
{       
    BOOL add;
    FARPROC lpProc;
    char fNam[MAXPATHLENGTH],buf[MAXPATHLENGTH],drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];

    UpdateTool(hdlg);
    add=FALSE;

    switch (type) {
    
    case 'X':        
        strcpy(fNam,"*.exe");
        GetFileName((LPSTR)fNam,"Select Tool",FALSE,(LPEXT)&ExeExt,5,hdlg);
            
        if (*fNam) {
            ShowTool(hdlg,0);
            _fullpath(buf,fNam,sizeof(buf));
            #ifndef _WIN32
               DownStr(buf);
            #endif

            SendDlgItemMessage(hdlg,IDD_TOOLTEXT1,WM_SETTEXT,0,(long)(LPSTR)buf);
            _splitpath(buf,drv,dir,nam,ext);
            if ((nam[0]>='a') && (nam[0]<='z'))
                nam[0]-=(char)((int)'a'-(int)'A');
            SendDlgItemMessage(hdlg,IDD_TOOLMENUTEXT,WM_SETTEXT,0,(long)(LPSTR)nam);
            tool.Type=type;                                                      
            add=TRUE;
        }    
        break;
        
    case 'L':
            
        lpProc=MakeProcInstance(AddDllToolDlgProc,hInst);
        add=(DialogBox(hInst,MAKEINTRESOURCE(IDD_ADDDLLTOOL),hdlg,lpProc)==IDOK);
        FreeProcInstance(lpProc); 
        ShowTool(hdlg,-1);
        break;
        
    case 'E':
            
        lpProc=MakeProcInstance(AddDdeToolDlgProc,hInst);
        add=(DialogBox(hInst,MAKEINTRESOURCE(IDD_ADDDDETOOL),hdlg,lpProc)==IDOK);
        FreeProcInstance(lpProc);
        ShowTool(hdlg,-1);
        break;
    }
    
    if (add) {
        SendDlgItemMessage(hdlg,IDD_TOOLMENUENTRY,BM_SETCHECK,1,0);
        NewTool(hdlg,type);
    }
}

void FreeBitmaps (void)
{
    int i;
        
    for (i=0;i<MAXTOOLBMPS;i++) 
        if (toolBmp[i]) DeleteObject(toolBmp[i]);
        
    if (toolBmpBut) DeleteObject(toolBmpBut);
    if (toolBmpButSel) DeleteObject(toolBmpButSel);    
}    

/**************************************************************************
 *                                                                        *
 *  FUNCTION   : ToolDlgProc (hwnd,msg,wParam,lParam)                     *
 *                                                                        *
 *  PURPOSE    : Tools options dialog box.                                *
 *               The user can change the list of tools and their options  *
 *                                                                        *
 **************************************************************************/

BOOL FAR PASCAL _export ToolDlgProc (HWND hdlg,WORD msg,WPARAM wParam,LONG lParam)
{
    switch(msg) {

    case WM_INITDIALOG: {

        int i;
        RECT r;
        FARPROC list;
        char bmp[20]; 
                 
        /* size of button listbox */
        GetWindowRect(GetDlgItem(hdlg,IDD_TOOLICONLIST),(LPRECT)&r);
        SetWindowPos(GetDlgItem(hdlg,IDD_TOOLICONLIST),0,0,0,r.right-r.left+1,
                     ICONHEIGHT+GetSystemMetrics(SM_CYVSCROLL),SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE);
        
                   
        /* save old list for cancel-option */
        SaveList();

        // load bitmap images 
        toolBmpBut=LoadBitmap(hInst,"TOOL");
        toolBmpButSel=LoadBitmap(hInst,"TOOLSEL");
        
        for (i=0;i<MAXTOOLBMPS;i++) {
            sprintf(bmp,"TOOL%d",i);
            
            // load image
            toolBmp[i]=LoadBitmap(hInst,(LPSTR)bmp);
                                                      
            // add to listbox
            if (toolBmp[i])
                SendDlgItemMessage(hdlg,IDD_TOOLICONLIST,LB_ADDSTRING,0,(long)(LPSTR)bmp);
        }    

        /* list existing tools */
        hToolDlg=hdlg;
        list=MakeProcInstance(ListTool,hInst);
        ListForEach(ToolList,list);
        FreeProcInstance(list);

        /* show parameters of first tool */
        ShowTool(hdlg,1);

        /* set default push button */
        SendMessage(hdlg,DM_SETDEFID,IDOK,0);
        SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,0,0);

        noUpdate=FALSE;

        return TRUE;     
        }
        
    case WM_MEASUREITEM: {     
    
        LPMEASUREITEMSTRUCT mi=(LPMEASUREITEMSTRUCT)lParam;
        mi->itemWidth=24;
        mi->itemHeight=22;

        return TRUE;
        }
                          
    case WM_DRAWITEM: {
         
        LPDRAWITEMSTRUCT di=(LPDRAWITEMSTRUCT)lParam; 
                    
        if (wParam==IDD_TOOLICONLIST) {
                    
            HDC memDC;                                             
            RECT r;
            HBITMAP oldBmp;                            
                                        
            switch (di->itemAction) {
            
            case ODA_DRAWENTIRE:
            case ODA_SELECT:
                      
                r=di->rcItem;
                memDC=CreateCompatibleDC(di->hDC);      
                
                if (di->itemState==ODS_SELECTED)
                    oldBmp=SelectObject(memDC,toolBmpButSel);
                else 
                    oldBmp=SelectObject(memDC,toolBmpBut);
                    
                BitBlt(di->hDC,r.left,r.top,r.right-r.left+1,r.bottom-r.top+1,memDC,0,0,SRCCOPY);

                SelectObject(memDC,toolBmp[di->itemID]);

                if (di->itemState==ODS_SELECTED)
                    BitBlt(di->hDC,r.left+3,r.top+3,r.right-r.left-2,r.bottom-r.top-2,memDC,2,2,SRCCOPY);
                else 
                    BitBlt(di->hDC,r.left+2,r.top+2,r.right-r.left-3,r.bottom-r.top-3,memDC,2,2,SRCCOPY);
                      
                SelectObject(memDC,oldBmp);      
                DeleteDC(memDC);
                
                return TRUE;
            }    
        }            
        break;
        }           
                          
    case WM_COMMAND:

        #ifdef _WIN32
          switch (LOWORD(wParam)) {
        #else
          switch (wParam) {
        #endif

            case IDOK:

                UpdateTool(hdlg);
                PurgeList((LPHANDLE)&OldTools);
                ToolMenu();
                FreeBitmaps();
                EndDialog(hdlg,wParam);
                break;

            case IDCANCEL:

                /* restore old options */
                PurgeList((LPHANDLE)&ToolList);
                ToolList=OldTools;
                ToolMenu();
                FreeBitmaps();
                EndDialog(hdlg,wParam);
                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Einbinden_von_Software_Tools);
                break;

            case IDD_TOOLADDEXE:

                AddTool(hdlg,'X');
                break;

            case IDD_TOOLADDDLL:

                AddTool(hdlg,'L');
                break;

            case IDD_TOOLADDDDE:

                AddTool(hdlg,'E');
                break;

            case IDD_TOOLDEL: {

                long n;
                char txt[80];                                
                TOOL tool;

                if ((n=SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETCURSEL,0,0))!=LB_ERR) {
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETTEXT,LOWORD(n),(long)(LPSTR)txt);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_DELETESTRING,LOWORD(n),0);
                    if ((n=FindTool(txt))!=0) {
                        GetElem(ToolList,LOWORD(n),(long)(LPSTR)&tool);
                        DelElem((LPHANDLE)&ToolList,LOWORD(n));
                        SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,0,0);
                        ShowTool(hdlg,1);
                        if (tool.Button)
                            buttonsChanged=TRUE;
                    }
                }
                break;
                }

            case IDD_TOOLUP: {

                int n;
                char txt[80];

                UpdateTool(hdlg);
                noUpdate=TRUE;
                if ((n=(int)SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETCURSEL,0,0))!=LB_ERR &&
                     n>0) {
                    MoveElem((LPHANDLE)&ToolList,n+1,n);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETTEXT,n,(long)(LPSTR)txt);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_DELETESTRING,n,0);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_INSERTSTRING,n-1,(long)(LPSTR)txt);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,n-1,0);
                }
                break;
                }

            case IDD_TOOLDOWN: {

                int n;
                char txt[80];

                UpdateTool(hdlg);
                noUpdate=TRUE;
                if ((n=(int)SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETCURSEL,0,0))!=LB_ERR &&
                     n<CountList(ToolList)-1) {
                    MoveElem((LPHANDLE)&ToolList,n+1,n+2);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETTEXT,n,(long)(LPSTR)txt);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_DELETESTRING,n,0);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_INSERTSTRING,n+1,(long)(LPSTR)txt);
                    SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_SETCURSEL,n+1,0);
                }
                break;
                }

            case IDD_TOOLLIST:

                #ifdef _WIN32
                  if (HIWORD(wParam)==LBN_SELCHANGE) {
                #else
                  if (HIWORD(lParam)==LBN_SELCHANGE) {
                #endif
                    int n;

                    UpdateTool(hdlg);
                    n=(int)SendDlgItemMessage(hdlg,IDD_TOOLLIST,LB_GETCURSEL,0,0);
                    ShowTool(hdlg,n+1);
                }
                /* no break, false has to be returned */

            default:

                return FALSE;
        }
        return TRUE;

    default:

        return FALSE;
    }
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION :   ToolDialog (hwnd)                                        *
 *                                                                        *
 *  PURPOSE  :   Run the Tools Options dialog to add/delete Tools         *
 *                                                                        *
 **************************************************************************/

void FAR ToolDialog (HWND hwnd)
{
    FARPROC lpProc;

    buttonsChanged=FALSE;
  
    lpProc=MakeProcInstance(ToolDlgProc,hInst);
    DialogBox(hInst,IDD_TOOLS,hwndFrame,lpProc);
    FreeProcInstance(lpProc);
  
    if (buttonsChanged)
        NewToolButtons();
    
    return;
}

/**************************************************************************
 *                                                                        *
 *  Helper Functions for RunTool                                          *
 *                                                                        *
 *  FUNCTIONS :  WorkArg - Replace %-commands in argument list            *
 *                                                                        *
 *               ArgDlgProc - Dialog: get argument list                   *
 *                                                                        *
 **************************************************************************/

void DecodeArg (LPSTR src,LPSTR dst)
{
    char ch;
    char capt[_MAX_PATH];    
    char buf[_MAX_PATH];
    LPSTR l;
    LPSTR dstorigin;
    BOOL changeSlashes;
    OSVERSIONINFO version;
    BOOL isExecutable;

    dstorigin=dst;
    changeSlashes=FALSE;
    
    while (ch=*src++)
        if (ch=='%') {
            ch=*src++;
            switch (ch) {
            case 'a': sprintf(buf,"%04X",GetActiveEditWindow(hwndMDIClient));
                      l=(LPSTR)buf;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 'c': version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
                      GetVersionEx(&version);
                      if (version.dwPlatformId==VER_PLATFORM_WIN32_NT)
                        strcpy(buf,"cmd.exe");
                      else
                        strcpy(buf,"command.com");
                      l=(LPSTR)buf;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 'd': l=(LPSTR)defaultDir;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 'f': if (GetActiveEditWindow(hwndMDIClient)!=0) {
                          GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)capt,80);
                          l=(LPSTR)capt;
                          while (*dst++=*l++);
                          dst--;
                      }
                      break;
            case 'i': GetWindowsDirectory((LPSTR)buf,sizeof(buf));
                      #ifndef _WIN32
                         DownStr((LPSTR)buf);
                      #endif
                      l=(LPSTR)buf;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 'n': if (GetActiveEditWindow(hwndMDIClient)) {
                          char drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];
                          GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)capt,80);
                          _splitpath(capt,drv,dir,nam,ext);
                          if ((nam[0]>='a') && (nam[0]<='z'))
                              nam[0]-=(char)((int)'a'-(int)'A');
                          l=(LPSTR)nam;
                          while (*dst++=*l++);
                          dst--;
                      }
                      break;
            case 'o': if (*actPrj) {
                          int n;
                          char drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];
                          _splitpath(actPrj,drv,dir,nam,ext);
                          l=(LPSTR)drv;
                          while (*dst++=*l++);
                          dst--;
                          n=0;
                          l=(LPSTR)dir;     
                          while (*dst++=*l++) n++;
                          dst--;
                          if (n>1 && *(dst-1)=='\\') 
                            dst--;
                      }
                      break;
            case 'p': if (*actPrj) {
                          char drv[4],dir[MAXPATHLENGTH],nam[MAXPATHLENGTH],ext[MAXPATHLENGTH];
                          _splitpath(actPrj,drv,dir,nam,ext);
                          /*if ((nam[0]>='a') && (nam[0]<='z'))
                              nam[0]-=(char)((int)'a'-(int)'A');*/
                          l=(LPSTR)nam;
                          while (*dst++=*l++);
                          dst--;
                      }
                      break;
            case 'r': l=actPrj;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 's': /* directory of active edit window */
                      RemoveMessageWindow();
	                  if (GetActiveEditWindow(hwndMDIClient) && IsEditWindow(GetActiveEditWindow(hwndMDIClient))) {
                          char drv[_MAX_DRIVE],dir[_MAX_DIR],nam[_MAX_FNAME],ext[_MAX_EXT];
                          GetWindowText(GetActiveEditWindow(hwndMDIClient),(LPSTR)capt,sizeof(capt));
                          _splitpath(capt,drv,dir,nam,ext);
                          strcpy(dst,drv);
                          dst+=strlen(drv);
                          strcat(dst,dir);
                          dst+=strlen(dir);
                          if (strlen(dir)>0 || strlen(drv)>0)
                              dst--; /* remove trailing "\" */
                      }
                      break;
            case 'w': sprintf(buf,"%04X",hwndFrame);
                      l=(LPSTR)buf;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case 'x': if (IsCompilerInterfaceLoaded()) {
                          GetTargetName(buf,&isExecutable);
                          l=(LPSTR)buf;
                          while (*dst++=*l++);
                          dst--;
                      }    
                      break;
            case '1': l=arg_1;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case '2': l=arg_2;
                      while (*dst++=*l++);
                      dst--;
                      break;
            case '/': changeSlashes=TRUE;
                      break;
            case '%': *dst++='%'; // replace %% by %
                      break;
            default:  *dst++='%';
                      *dst++=ch;
            }
        }
        else *dst++=ch;
    *dst=0;

    /* change backward slashes to forward slashes if %/ command was given */
    if (changeSlashes) {
        dst=dstorigin;
        while (*dst) {
            if (*dst=='\\') *dst='/';
            dst++;
        }
    }
}

BOOL FAR PASCAL _export ArgDlgProc (HWND hdlg,WORD msg,WORD wParam,LONG lParam)
{
    switch(msg) {

    case WM_INITDIALOG: {
                                                                  
        SendDlgItemMessage(hdlg,IDD_TARGARGS,WM_SETTEXT,0,(long)ArgText);
        return TRUE;
        }

    case WM_COMMAND:

        switch (wParam) {

            case IDOK:
            case IDCANCEL:

                /* read out argument list */
                SendDlgItemMessage(hdlg,IDD_TARGARGS,WM_GETTEXT,ARGTEXTLEN,(long)ArgText);
                EndDialog(hdlg,wParam);
                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Parameter_fuer_Werkzeuge);
                break;

            default:

                return FALSE;
        }
        return TRUE;

    default:

        return FALSE;
    }
}                               

/**************************************************************************
 *                                                                        *
 *  FUNCTION :   NewToolButtons (void)                                    *
 *                                                                        *
 *  PURPOSE  :   Generate tool buttons appropriate to tools-list          * 
 *                                                                        *
 **************************************************************************/

void FAR NewToolButtons (void)
{        
    int i,n,x,ypos;                   
    RECT r;
    TOOL tool;
    
    // remove old buttons
    toolButtons=0;
    for (i=0;i<MAXTOOLBUTTONS;i++)
        if (hToolBut[i])
            DestroyWindow(hToolBut[i]);
    
    // positions of buttons
    GetClientRect(hwndFrame,(LPRECT)&r);
    ypos=YPOS;
    if (actConfig.ribbonOnBottom)
        ypos+=r.bottom-STATHIGH-RIBBHIGH+1;
            
    // create new buttons
    x=0;
    n=CountList(ToolList);
    for (i=1;i<=n;i++) {
        GetElem(ToolList,i,(long)(LPTOOL)&tool);
        if (toolButtons<MAXTOOLBUTTONS && tool.Button) {
            hToolBut[toolButtons]=CreateWindow("PowButton","",BS_OWNERDRAW|BS_PUSHBUTTON|WS_CHILD|WS_VISIBLE,
                                    LOGOX+x,ypos,BUTDX,BUTDY,hwndFrame,(HMENU)(IDD_TOOL_FIRST+toolButtons),hInst,NULL);
            toolImage[toolButtons]=tool.ButtonId;              
            toolButtons++;              
            x+=BUTNEXT;
        }
    }                       
    
    // show buttons                             
    if (actConfig.ribbonOnBottom)
        r.top=r.bottom-STATHIGH-RIBBHIGH+1;
    r.bottom=r.top+RIBBHIGH;
    InvalidateRect(hwndFrame,(LPRECT)&r,FALSE);
    UpdateWindow(hwndFrame);
}
  
/**************************************************************************
 *                                                                        *
 *  FUNCTION :   RunTool (tool)                                           *
 *                                                                        *
 *  PURPOSE  :   Execute a predefined tool (ask for arguments, if needed) *
 *               absolute ... nr is absolute index to tool list?          *
 *               fromMenu ... nr is relative index via menu               *
 *                                                                        *
 **************************************************************************/

HDDEDATA FAR PASCAL _export DdeCallbackProc (UINT type,UINT fmt,HCONV hconv,HSZ hsz1,HSZ hsz2,HDDEDATA hdata,DWORD dwData1,DWORD dwData2)
{
    if (type==XTYP_ADVDATA)
        return (HDDEDATA)DDE_FACK;
                                                                      
    return (HDDEDATA) NULL;
}

HANDLE FAR RunTool (WORD nr,int fromMenu,int absolute)
{          
    int i;  
    int err;
    WORD ret;
    TOOL tool;
    FARPROC lpArg;
    HANDLE handle=0;             // instance handle for autostart tools
    char buf[ARGTEXTLEN];
    char arg[MAXPATHLENGTH];
    char cmd[MAXPATHLENGTH];
    char path[MAXPATHLENGTH];

#ifdef _WIN32
    DWORD errCode;
    STARTUPINFO startup;
    PROCESS_INFORMATION process;
    SECURITY_ATTRIBUTES security;
#else
    int cdr;
    char cwd[80];
    char drv[_MAX_DRIVE];
    char dir[_MAX_DIR];
    char fil[_MAX_FNAME];
    char ext[_MAX_EXT];
#endif
                  
    if (absolute)
        err=!GetElem(ToolList,nr,(long)(LPTOOL)&tool);
    else {
        i=1;    
        err=FALSE;                          
        while (nr && !err) {
            err=!GetElem(ToolList,i,(long)(LPTOOL)&tool);
            if ((fromMenu && tool.Menu) ||
                (!fromMenu && tool.Button))
                nr--;
            i++;    
        }
    } 

    if (!err) {
    
        /* get arguments */
        ArgText=(LPSTR)buf;
        DecodeArg((LPSTR)(tool.Arg),ArgText);
        if (tool.AskArg) {
            lpArg=MakeProcInstance(ArgDlgProc,hInst);
            ret=DialogBox(hInst,IDD_TOOLSARG,hwndFrame,lpArg);
            FreeProcInstance(lpArg);
        }
        else 
            ret=IDOK;

        if (ret==IDOK) {
                                                                  
            DecodeArg((LPSTR)buf,(LPSTR)arg);

            switch (tool.Type) {
            
            case 'X': {
                 
                /* execute program */
                strcpy(cmd,tool.Text1);
                strcat(cmd," ");
                strcat(cmd,arg);

                strcpy(buf,tool.Text2);
                DecodeArg((LPSTR)buf,path);
                
#ifdef _WIN32
                memset(&startup,0,sizeof(startup));
                startup.dwFlags=STARTF_USESHOWWINDOW;
                startup.wShowWindow=SW_SHOWNORMAL;
                startup.cb=sizeof(startup);

                security.lpSecurityDescriptor=NULL;
                security.bInheritHandle=FALSE;
                security.nLength=sizeof(security);

                if (CreateProcess(
                              NULL,              /* name of executable */
                              cmd,               /* arguments */
                              &security,         /* no security attributes */
                              NULL,              /* no thread attributes */
                              FALSE,             /* do not inherit handle */
                              CREATE_NEW_CONSOLE,
                              NULL,              /* use environment of parent */
                              *path ? path : 0,  /* start directory */
                              &startup,          /* startup parameters */
                              &process))         /* receives process information */
                    handle=process.hProcess;
                else
                    errCode=GetLastError();
#else
                /* save old drive/path */
                getcwd(cwd,sizeof(cwd));
                cdr=_getdrive();

                /* change drive/path */
                if (strlen(path)>0) {
                    _splitpath(path,drv,dir,fil,ext);
                    if (drv[0]>='a' && drv[0]<='z') drv[0]=(char)(drv[0]-'a'+'A');
                    if (drv[0]>='A' && drv[0]<='Z' && (!_chdrive(drv[0]-'A'+1))) {
                        if (strlen(dir)>1 && dir[strlen(dir)-1]=='\\')
                            dir[strlen(dir)-1]=0;
                        chdir(dir);
                    }
                }

                handle=WinExec((LPSTR)cmd,SW_SHOWNORMAL);
                if (handle<32) {
                    // could not start tool
                    if (handle==2 || handle==3)
                        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_TOOLNOTFOUND,tool.Text1);
                    else
                        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_TOOLNOTSTARTED,tool.Text1);
                    handle=0;
                }

                /* restore old drive/path */
                _chdrive(cdr);
                chdir(cwd);
#endif
                }
                break;
                
            case 'L': {
                
                HINSTANCE h;   
                FARPROC f;

#ifdef _WIN32                
                if (*tool.Text1 && (h=LoadLibrary((LPSTR)tool.Text1))) {
#else
                if (*tool.Text1 && (h=LoadLibrary((LPSTR)tool.Text1))>=HINSTANCE_ERROR) {
#endif

                    if (f=GetProcAddress(h,(LPSTR)tool.Text2)) {
                        if (*arg)
                            (*f)((LPSTR)arg);
                        else
                            (*f)();    
                    }        
                    else
                        Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_NODLLFUNCTION,(LPSTR)tool.Text1,(LPSTR)tool.Text2);
                    FreeLibrary(h);
                }
                break;
                }
            
            case 'E': {
                                            
                UINT ret;
                FARPROC fp;
                DWORD instId; 
                DWORD result;
                HCONV hconv;                
                HDDEDATA done;
                char service[40],topic[40];
                HSZ hservice,htopic;

                lstrcpy((LPSTR)service,(LPSTR)tool.Text1);
                lstrcpy((LPSTR)topic,(LPSTR)tool.Text2);
                    
                fp=MakeProcInstance((FARPROC)DdeCallbackProc,hInst);
                instId=0;                    
                                    
                if ((ret=DdeInitialize((LPDWORD)&instId,(PFNCALLBACK)fp,APPCMD_CLIENTONLY,0))==DMLERR_NO_ERROR) {
                    hservice=DdeCreateStringHandle(instId,(LPSTR)service,CP_WINANSI);
                    htopic=DdeCreateStringHandle(instId,(LPSTR)topic,CP_WINANSI);
    
                    if (hconv=DdeConnect(instId,hservice,htopic,0)) {
                        done=DdeClientTransaction((LPSTR)arg,lstrlen((LPSTR)arg)+1,hconv,0,CF_TEXT,XTYP_EXECUTE,10000l,(DWORD FAR *)&result);
                        if (!done)
                            Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_DDEFAILED,service);    
                        DdeDisconnect(hconv); 
                    }
                    
                    DdeFreeStringHandle(instId,hservice);
                    DdeFreeStringHandle(instId,htopic);

                    /* !!!BUG??? */
                    /* ddeuninitialize sollte eigentlich drinnen sein, kommt aber unter WIN32 nicht zurueck!!! */
                    /* kann es sein, dass man das nur einmal pro applikation machen muss, nicht pro ddeinitialize? */
                    /* (pow! hat gleichzeitig ja einen aktiven dde server mit eigener uninitialize, die funktioniert) */
                    #ifndef _WIN32
                        DdeUninitialize(instId);
                    #endif
                }
                
                FreeProcInstance(fp);
                break; 
                }
            }    
            
            if (tool.ToTop)
                BringWindowToTop(hwndFrame);
        }
    }
    return handle;          // return instance handle of started module
}
    
    
/**************************************************************************
 *                                                                        *
 *  FUNCTION :   AutoStartTools                                           *
 *                                                                        *
 *  PURPOSE  :   Execute tools, which are defined as "autostart"          *
 *               and save program-handles in "AutoStart"-List             *
 *                                                                        *
 **************************************************************************/

void FAR AutoStartTools (void)
{
    int i,n;
    TOOL tool;
    HANDLE handle;
                          
    AutoStartList=0;                          
    n=CountList(ToolList);
 
    for (i=1;i<=n;i++) {
        GetElem(ToolList,i,(long)(LPTOOL)&tool);
        if (tool.AutoStart) {
            handle=RunTool((WORD)i,FALSE,TRUE);
            if (handle)
                AddElem((LPHANDLE)&AutoStartList,(long)(LPSTR)&handle,sizeof(HANDLE));
        }
    }     
}


/**************************************************************************
 *                                                                        *
 *  FUNCTION :   AutoStopTools                                            *
 *                                                                        *
 *  PURPOSE  :   End tools, which were started at Pow! startup            *
 *                                                                        *
 **************************************************************************/

void FAR AutoStopTools (void)
{
    int i,n;
    HANDLE handle;
#ifdef _WIN32
    DWORD exitCode;
#else
    TASKENTRY task;
#endif

    n=CountList(AutoStartList);
    for (i=1;i<=n;i++) {
        GetElem(AutoStartList,i,(long)(LPTOOL)&handle);

#ifdef _WIN32
        GetExitCodeProcess(handle,&exitCode);
        TerminateProcess(handle,exitCode);
#else
        task.dwSize=sizeof(TASKENTRY);
        if (TaskFirst((TASKENTRY FAR *)&task)) {
            do {
                if (task.hInst==handle) {
                    TerminateApp(task.hTask,NO_UAE_BOX);
                    break;
                }
            } while (TaskNext((TASKENTRY FAR *)&task));
        }
#endif
    }     
    PurgeList((LPHANDLE)&AutoStartList);
}

/***********************************************
 * check if tool with same name already exists *
 ***********************************************/

BOOL ToolAlreadyExists (TOOL t)
{
    int i,n;
    TOOL tool;

    n=CountList(ToolList);
    for (i=1;i<=n;i++) {
        GetElem(ToolList,i,(long)(LPTOOL)&tool);
        /* check if either menu text or button id's are equal */
        if (stricmp(tool.MenuText,t.MenuText)==0 ||
            (tool.Button==TRUE && tool.ButtonId==t.ButtonId))
            return TRUE;
    }
    return FALSE;
}

/**************************************************************************
 *                                                                        *
 *  FUNCTION :   ToolAdd                                                  *
 *                                                                        *
 *  PURPOSE  :   Append a tool to the list (and menu and buttons)         *
 *                                                                        *
 **************************************************************************/

BOOL FAR ToolAdd (LPSTR name,LPSTR command,LPSTR dir,LPSTR options,BOOL menu,int buttonId,BOOL toTop,BOOL askArg)
{
    TOOL t;

    /* fill tool structure */
    memset(&t,0,sizeof(TOOL));
    strcpy(t.MenuText,name);
    strcpy(t.Text1,command);
    strcpy(t.Text2,dir);
    strcpy(t.Arg,options);
    t.ToTop=toTop;
    t.AskArg=askArg;
    t.Button=(buttonId!=0);
    t.ButtonId=buttonId;
    t.Menu=menu;
    t.AutoStart=FALSE;
    t.Type='X';
    t.ViaDDE=VIADDESIGNATURE;

    /* append tool to list */
    if (!ToolAlreadyExists(t))
        AddElem((LPHANDLE)&ToolList,(long)(LPTOOL)&t,sizeof(TOOL));

    /* update speed button list */
    if (buttonId!=0)
       NewToolButtons();

    /* update tool menu entries */
    if (menu)
       ToolMenu();

    return TRUE;
}


/**************************************************************************
 *                                                                        *
 *  FUNCTION :   ToolDelete                                               *
 *                                                                        *
 *  PURPOSE  :   Remove a tool from the list (and menu and buttons)       *
 *                                                                        *
 **************************************************************************/

BOOL FAR ToolDelete (LPSTR name)
{
    int n;
    TOOL t;
    BOOL found;
    BOOL buttonsChanged;
    BOOL menuChanged;

    n=1;
    found=FALSE;
    buttonsChanged=FALSE;
    menuChanged=FALSE;

    /* browse tools */
    while (n<=CountList(ToolList)) {
        GetElem(ToolList,n,(long)(LPTOOL)&t);

        /* tool found? */
        if (stricmp(name,t.MenuText)==0) {
            found=TRUE;

            /* buttons and/or menu changed? */
            if (t.Button)
                buttonsChanged=TRUE;
            if (t.Menu)
                menuChanged=TRUE;

            /* remove from list */
            DelElem((LPHANDLE)&ToolList,n);
        }
        else
            n++;
    }
    
    /* update speed button list */
    if (buttonsChanged)
       NewToolButtons();

    /* update tool menu entries */
    if (menuChanged)
       ToolMenu();

    return found;
}
