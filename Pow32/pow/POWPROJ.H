#ifndef _INC_POWPROJ

#include <time.h>

typedef struct {
    char name[MAXPATHLENGTH];
    time_t timeStamp;
} PrjFile;

typedef struct {
    short changed;    /* comp/link options have changed? */
    HANDLE files;     /* project files */
} PrjDecl;

typedef PrjFile FAR *LPPrjFile;
typedef PrjDecl FAR *LPPrjDecl;

/* global declarations */
extern PrjDecl actProject;    /* current project */
extern HANDLE hDep;           /* module dependency matrix */

/* exported procedures */
extern BOOL FAR WriteProject (LPSTR name);
extern BOOL FAR ReadProject (LPSTR name,BOOL isDefault);
extern VOID FAR PurgeProject (LPPrjDecl prj);
extern VOID FAR InitProject (LPPrjDecl prj);
extern VOID FAR ProjectCaption (void);
extern VOID FAR WriteTemplate (void);
extern VOID FAR ReadTemplate (LPSTR tpl,LPSTR prj);
extern VOID FAR OpenTemplate (void);
extern VOID FAR SetDefaultProjectName (void);
extern VOID FAR CreateProjectFromTemplate (LPSTR tpl,LPSTR prj,LPSTR dir,int targetIsProject);
extern BOOL FAR ReadPrj (LPSTR name);

#define _INC_POWPROJ
#endif
