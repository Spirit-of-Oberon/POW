#ifndef _INC_POWTEMP
#define _INC_POWTEMP
                                                   
/* enumerate templates in template directory and create popup menu */
void CreateTemplateMenu (HMENU mainmenu);             

/* a template menu entry has been selected */
int SelectTemplate (int menuId);

/* remove allocated memory for template popup menu */
void RemoveTemplateList (void);

/* create a new project from template */
void NewProjectFromTemplate (LPSTR tpl,int targetIsProject);

#endif
