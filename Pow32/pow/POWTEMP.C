/***************************************************************************
 *                                                                         *
 *  MODULE  : PowTemp.c                                                    *
 *                                                                         *
 *  PURPOSE : Code for template popup menu.                                *
 *                                                                         *
 *  FUNCTIONS :                                                            *
 *                                                                         *
 *        CreateTemplateMenu   - create popup menu with template entries   *
 *        SelectTemplate       - a template menu entry has been selected   *
 *        RemoveTemplateList   - clear list of templates                   *
 *                                                                         *
 ***************************************************************************/

#ifdef _WIN32
   #include <io.h>
#else
   #include <dos.h>
#endif

#include <dos.h>
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <stdio.h>

#include "pow.h"
#include "..\powsup\powsupp.h"
#include "powhelp.h"
#include "powopen.h"
#include "powproj.h"
                   
static HANDLE templateList= 0;
static char newProjectDir[_MAX_PATH];
static char newProjectName[_MAX_PATH];
static int newProjectIsProject;
                   
/**************************************************************
 * create a menu entry and save full name of template in list *
 **************************************************************/                   
void AddReference (HMENU submenu,UINT *menuId,LPSTR name,LPSTR fullname)
{
   char buf[255];
   
   *menuId+=1;
      
   /* hide trainling file extension */   
   if (strlen(name)>4)
      name[strlen(name)-4]=0;
         
   /* hide trainling '_' characters (for Opal) :-( */   
   if (strlen(name) && name[strlen(name)-1]=='_')
      name[strlen(name)-1]=0;
   
   #ifndef _WIN32
      AnsiLower(name);
      AnsiLower(fullname);
      *name=toupper(*name);
   #endif

   strcpy(buf,"Use template ");
   strcat(buf,"\"");
   strcat(buf,name);
   strcat(buf,"\"");
   
   AppendMenu(submenu,MF_ENABLED|MF_STRING,*menuId,buf);
   AddStr((LPHANDLE)&templateList,fullname);
}

/*******************************************************
 * check, if this directory has a single template only *
 *******************************************************/
int HasSingleTemplate (LPSTR dir,LPSTR tplname)
{
   char search[_MAX_PATH];
                    
#ifdef _WIN32
   long hresult;
   struct _finddata_t c_file;
#else
   struct _find_t c_file;
#endif

   strcpy(search,dir);
   strcat(search,"\\*.tpl");

   /* procedure returns 1 if there is exactly one template file */
#ifdef _WIN32
   hresult=_findfirst(search,&c_file);
   if (hresult!=-1) {
      strcpy(tplname,c_file.name);      /* return name of template */
      if (_findnext(hresult,&c_file)==-1)
         return 1;
   }
#else
   if (_dos_findfirst(search,_A_NORMAL,&c_file )==0) {
      strcpy(tplname,c_file.name);      /* return name of template */
      if (_dos_findnext(&c_file)!=0)
         return 1;
   }
#endif

   return 0;
}
      
/*************************************************
 * recursively build the template menu structure *
 *************************************************/      
int WorkDirectory (HMENU popup,LPSTR path,UINT *menuId)
{
   int entries;
   char search[_MAX_PATH],nextdir[_MAX_PATH],drv[_MAX_DRIVE],dir[_MAX_DIR],
        full[_MAX_PATH],nam[_MAX_FNAME],ext[_MAX_EXT],tplname[_MAX_PATH];
               
#ifdef _WIN32
   long hresult;
   struct _finddata_t c_file;
#else
   struct _find_t c_file;
#endif

   entries=0;            
                    
   strcpy(search,path);
   strcat(search,"\\*.*");

   /* first search for any templates in this directory or subdirectories with a single template */
#ifdef _WIN32
   hresult=_findfirst(search,&c_file );
   if (hresult!=-1) {
#else
   if (_dos_findfirst(search,_A_SUBDIR,&c_file )==0) {
#endif
      do {
         c_file.attrib&=(~_A_ARCH);
         if (c_file.attrib==_A_NORMAL) {
            strcpy(full,path);
            strcat(full,"\\");
            strcat(full,c_file.name);

            #ifndef _WIN32
               AnsiLower(full);
            #endif
      
            _splitpath(full,drv,dir,nam,ext);
      
            /* add templates to popup menu */
            if (strcmp(ext,".tpl")==0) {
               AddReference(popup,menuId,c_file.name,full);
               entries++;
            }
         }
         else if ((c_file.attrib==_A_SUBDIR) && (c_file.name[0]!='.')) {
            strcpy(nextdir,path);
            strcat(nextdir,"\\");
            strcat(nextdir,c_file.name);
            if (HasSingleTemplate(nextdir,tplname)) {
               /* directory has a single template -> add to popup menu */
               strcpy(full,nextdir);
               strcat(full,"\\");
               strcat(full,tplname);
               AddReference(popup,menuId,tplname,full);
               entries++;
            }
         }
#ifdef _WIN32
      } while (_findnext(hresult,&c_file)!=-1);
#else
      } while (_dos_findnext(&c_file)==0);
#endif
   }
                                                         
   /* at last search for templates in subdirectories */                                                      
#ifdef _WIN32
   hresult=_findfirst(search,&c_file );
   if (hresult!=-1) {
#else
   if (_dos_findfirst(search,_A_SUBDIR,&c_file )==0) {
#endif
      do {
         c_file.attrib&=(~_A_ARCH);
         if ((c_file.attrib==_A_SUBDIR) && (c_file.name[0]!='.')) {
            strcpy(nextdir,path);
            strcat(nextdir,"\\");
            strcat(nextdir,c_file.name);
            if (!HasSingleTemplate(nextdir,tplname)) {
               HMENU nextpopup;
               /* create new popup for a directory with more than one templates */    
               #ifndef _WIN32
                  AnsiLower(c_file.name);
                  c_file.name[0]=toupper(c_file.name[0]);
               #endif
               
               nextpopup=CreatePopupMenu();
               if (WorkDirectory(nextpopup,nextdir,menuId)) {
                  AppendMenu(popup,MF_POPUP,(UINT)nextpopup,c_file.name);
                  entries++;
               }
               else
                  DestroyMenu(nextpopup); /* don't create empty menus! */
            }
         }
#ifdef _WIN32
      } while (_findnext(hresult,&c_file)!=-1);
#else
      } while (_dos_findnext(&c_file)==0);
#endif
   }
   return entries;
}

/***************************
 * clear list of templates *
 ***************************/
void RemoveTemplateList (void)
{
   PurgeList((LPHANDLE)&templateList);
}

/*******************************************************
 * create the menu entries for the template popup menu *
 *******************************************************/
void CreateTemplateMenu (HMENU mainmenu)
{
   UINT menuId;
   char dir[_MAX_PATH];
   HMENU popup,filenew,project,oldpopup;
                      
   /* get old template menu */                   
   filenew=GetSubMenu(GetSubMenu(mainmenu,0),0);
   project=GetSubMenu(mainmenu,4);
   oldpopup=GetSubMenu(filenew,1);
                              
   /* set new popup menu in file/new/project */                           
   popup=CreatePopupMenu();
   ModifyMenu(filenew,1,MF_BYPOSITION|MF_ENABLED|MF_POPUP,(UINT)popup,"&Project");
 
   /* set new popup menu in project/new */                           
   ModifyMenu(project,0,MF_BYPOSITION|MF_ENABLED|MF_POPUP,(UINT)popup,"&New");
           
   /* remove the old menu and allocated memory */        
   DestroyMenu(oldpopup);
   RemoveTemplateList();
                           
   /* append entries to popup menu */                        
   strcpy(dir,defaultDir);
   strcat(dir,"\\template");
   menuId=IDM_TEMPLATEPOPUP;
   WorkDirectory(popup,dir,&menuId);
   
   AppendMenu(popup,MF_ENABLED|MF_STRING,IDM_TEMPLATEEMPTY,"&Empty Project...");
   AppendMenu(popup,MF_ENABLED|MF_STRING,IDM_TEMPLATEOTHER,"&Find Template...");
}
 
/***********************************************************
 * get the name of the template associated with menu event *
 ***********************************************************/ 
int GetTemplate (int menuId,LPSTR name)
{
   if (menuId>IDM_TEMPLATEPOPUP) {
      GetStr(templateList,menuId-IDM_TEMPLATEPOPUP,name);
      return 1;
   }
   return 0;
}     
                
/********************************************************************
 * dialog procedure for definition of a new project                 *
 * if "newProjectIsProject" is set, then the new file is a project, *
 * else a template file will be created                             *
 ********************************************************************/
BOOL FAR PASCAL _export SelectTemplateDlgProc (HWND hdlg,WORD msg,WPARAM wParam,LPARAM lParam)
{
    switch(msg) {

    case WM_INITDIALOG: {
        char dir[_MAX_PATH];
 
        #ifndef _WIN32
           SendDlgItemMessage(hdlg,IDD_NEWPRJNAME,EM_LIMITTEXT,8,0);
        #endif

        if (newProjectIsProject) {
           char buf[1000];
           LPSTR p;
         
           p=(LPSTR)lParam+strlen((LPSTR)lParam)-1;
           while (p!=(LPSTR)lParam && *p!='\\') p--;
           if (*p=='\\')
              p++;
           else
              p=(LPSTR)lParam;
           
           sprintf(buf,"New Project from Template \"%s\"",p);
           SetWindowText(hdlg,buf);
           strcpy(dir,projectDirectory);
        }
        else {
           strcpy(dir,defaultDir);
           strcat(dir,"\\template\\");
           SetWindowText(hdlg,"Save Project as Template");
           SetWindowText(GetDlgItem(hdlg,IDD_NEWPRJCREATE),"Create new &directory for template:");
        }
        
        SendDlgItemMessage(hdlg,IDD_NEWPRJCREATE,BM_SETCHECK,1,0);
        SetWindowText(GetDlgItem(hdlg,IDD_NEWPRJDIR),dir);
        SetWindowText(GetDlgItem(hdlg,IDD_NEWPRJNEWDIR),dir);
        EnableWindow(GetDlgItem(hdlg,IDD_NEWPRJDIR),FALSE);
        }
        return TRUE;
                
    case WM_COMMAND:

        #ifdef _WIN32
          switch (LOWORD(wParam)) {
        #else
          switch (wParam) {
        #endif

            case IDOK: 
                                                 
                GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJNAME),newProjectName,sizeof(newProjectName));

                if (SendDlgItemMessage(hdlg,IDD_NEWPRJCREATE,BM_GETCHECK,0,0))
                   GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJNEWDIR),newProjectDir,sizeof(newProjectDir));
                else
                   GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJDIR),newProjectDir,sizeof(newProjectDir));
                   
                #ifdef _WIN32
                   EndDialog(hdlg,LOWORD(wParam));
                #else
                   EndDialog(hdlg,wParam);
                #endif

                break;

            case IDCANCEL:

                #ifdef _WIN32
                   EndDialog(hdlg,LOWORD(wParam));
                #else
                   EndDialog(hdlg,wParam);
                #endif

                break;

            case IDD_HELP:

                WinHelp(hwndFrame,(LPSTR)helpName,HELP_CONTEXT,Arbeiten_mit_Templates);
                break;
                                                           
            case IDD_NEWPRJCREATE: {
                int subdir;
            
                subdir=(SendDlgItemMessage(hdlg,IDD_NEWPRJCREATE,BM_GETCHECK,0,0)!=0);
                EnableWindow(GetDlgItem(hdlg,IDD_NEWPRJDIR),!subdir);
                EnableWindow(GetDlgItem(hdlg,IDD_NEWPRJNEWDIR),subdir);
                }
                break;
                                                           
            case IDD_NEWPRJBROWSE: {
                char dir[_MAX_PATH];
                BOOL ret;
                
                GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJDIR),dir,sizeof(dir));
                
                if (newProjectIsProject) ret=ChooseDirectory(dir,"Select Project Direcory",hdlg);
                else ret=ChooseDirectory(dir,"Select Template Direcory",hdlg);
                
                if (ret) {
                   if (*dir && (dir[strlen(dir)-1]!='\\'))
                      strcat(dir,"\\");        
                                              
                   SetWindowText(GetDlgItem(hdlg,IDD_NEWPRJDIR),dir);

                   if (newProjectIsProject) {
                      /* remember directory as new project directory */   
                      strcpy(projectDirectory,dir);
                   }
                   
                   /* notify static control containing new directory name */
                   #ifdef _WIN32
                      SendMessage(hdlg,WM_COMMAND,MAKEWPARAM(IDD_NEWPRJNAME,EN_CHANGE),(LPARAM)GetDlgItem(hdlg,IDD_NEWPRJNAME));
                   #else
                      SendMessage(hdlg,WM_COMMAND,IDD_NEWPRJNAME,MAKELPARAM(IDD_NEWPRJNAME,EN_CHANGE));
                   #endif
                }
                break;
                }
                
            case IDD_NEWPRJNAME:
            
#ifdef _WIN32
                if (HIWORD(wParam)==EN_CHANGE) {
#else
                if (HIWORD(lParam)==EN_CHANGE) {
#endif
                   char dir[_MAX_PATH],name[100];
                                                                        
                   /* set name of new directory */
                   GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJNAME),name,sizeof(name));
                   GetWindowText(GetDlgItem(hdlg,IDD_NEWPRJDIR),dir,sizeof(dir));
                   strcat(dir,name);
                   if (*name)
                      strcat(dir,"\\");
                   SetWindowText(GetDlgItem(hdlg,IDD_NEWPRJNEWDIR),dir);
                }
                break;
                
            default:

                return FALSE;
        }
        return TRUE;

    default:

        return FALSE;
    }
}

/*************************************************************************************
 * is a project name valid (check against names in "prjnames.err" in Pow!-directory) *
 *************************************************************************************/

int ProjectNameValid (LPSTR name)
{
   int ok;
   char fname[MAXPATHLENGTH],exception[256];
   FILE *f;
   
   ok=TRUE;
   
   strcpy(fname,defaultDir);
   strcat(fname,"\\prjnames.err");
   
   f=fopen(fname,"rt");
   if (f) {
      while (ok && !feof(f)) {
         fgets(exception,sizeof(exception)-1,f);
         if (*exception && exception[strlen(exception)-1]<32)
            exception[strlen(exception)-1]=0;
         ok=stricmp(name,exception);
      }
      fclose(f);
   }
   
   return ok;
}

/************************************************************
 * dialog for entering data for new project out of template *
 ************************************************************/
                                          
void NewProjectFromTemplate (LPSTR tpl,int targetIsProject)
{
   FARPROC proc;
      
   newProjectIsProject=targetIsProject;
   proc=MakeProcInstance(SelectTemplateDlgProc,hInst);
      
   if (DialogBoxParam(hInst,IDD_NEWPROJECT,hwndFrame,proc,(LPARAM)tpl)==IDOK) {
      if (ProjectNameValid(newProjectName))
         CreateProjectFromTemplate(tpl,newProjectName,newProjectDir,targetIsProject);
      else
         Message(hwndFrame,MB_OK|MB_ICONEXCLAMATION,IDS_PRJNAMEINVALID,(LPSTR)newProjectName);
   }
      
   FreeProcInstance(proc);
}
                                          
/*******************************************
 * a template menu entry has been selected *
 *******************************************/                      
                      
void SelectTemplate (int menuId)
{                         
   char name[_MAX_PATH];
   
   if (GetTemplate(menuId,name))
      NewProjectFromTemplate(name,TRUE);
}