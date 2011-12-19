#ifndef INC_DDE
#define INC_DDE

extern BOOL DdeInit (void);
extern void DdeExit (void);
extern BOOL DdeSendCommand (LPSTR service,LPSTR topic,LPSTR command);

#endif
