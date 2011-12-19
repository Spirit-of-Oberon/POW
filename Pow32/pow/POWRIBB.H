#ifndef _INC_POWRIBB

/* button dimensions */
#define BUTDX     26
#define BUTDY     24
#define BUTNEXT   30
#define BUTGROUP  45

/* project combo-box position and size */
#define PRJY      0
#define PRJDX     130
#define PRJDY     250

/* fim-logo size */
#define ABTDX     39

/* window position parameters */
#define YPOS      4
#define RIBBHIGH  33
#define OPENX     20
#define SAVEX     OPENX+BUTNEXT
#define PRINTX    SAVEX+BUTNEXT
#define COMPX     PRINTX+BUTGROUP
#define MAKEX     COMPX+BUTNEXT
#define RUNX      MAKEX+BUTGROUP
#define PRJX      RUNX+BUTGROUP
#define ABTX      PRJX+PRJDX+BUTGROUP-BUTDX

/* positions of fim-logo */
#define LOGOX     ABTX+BUTGROUP+ABTDX-BUTDX
#define LOGOY1    1
#define LOGOY2    29

extern BOOL ribbonOn;
extern HWND hProj;    // window handle of project combo-box

extern void FAR InitRibbon (void);
extern void FAR DestroyRibbon (void);
extern void FAR ShowRibbon (HDC);
extern void FAR RibbonCommand (HWND,WPARAM,LPARAM);
extern LONG FAR PASCAL ProjectButtonProc (HWND,WORD,WORD,LONG);
extern void FAR ProjectToRibbon (void);
extern void FAR CheckFileAct (void);
extern void FAR MoveRibbon (void);

#define _INC_POWRIBB
#endif
