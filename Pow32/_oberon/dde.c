/***************************************************************************
 *                                                                         *
 *  MODULE    : DDE.c                                                      *
 *                                                                         *
 *  FUNCTIONS : DdeSendCommand: send a command string to a DDE server.     *
 *              DdeInit:        must be called before any DdeSendCommand.  *
 *              DdeExit:        must be called before program exit.        *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <ddeml.h>

#include "_oberon.h"

BOOL DdeSendCommand (LPSTR service,LPSTR topic,LPSTR command)
{
    DWORD result;
    HCONV hconv;                
    HSZ hservice,htopic;
    BOOL done;

    done=FALSE;
    hservice=DdeCreateStringHandle(ddeInstId,(LPSTR)service,CP_WINANSI);
    htopic=DdeCreateStringHandle(ddeInstId,(LPSTR)topic,CP_WINANSI);

    if (hconv=DdeConnect(ddeInstId,hservice,htopic,0)) {
        if (DdeClientTransaction(command,lstrlen(command)+1,hconv,0,CF_TEXT,XTYP_EXECUTE,10000l,(DWORD FAR *)&result))
            done=TRUE;
        DdeDisconnect(hconv); 
    }
    
    DdeFreeStringHandle(ddeInstId,hservice);
    DdeFreeStringHandle(ddeInstId,htopic);

    return done;
}
