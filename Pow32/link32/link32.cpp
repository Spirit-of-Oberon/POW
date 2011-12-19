/***************************************************************************
 *                                                                         *
 *            ppppppppp      oooooo     www       www     xxxx             *
 *            pppppppppp    oooooooo   www         www   xxxxxx            *
 *            ppp    pppp  ooo    ooo  www         www   xxxxxx            *
 *            ppp    pppp  oo      oo  www   www   www   xxxxxx            *
 *            pppppppppp   oo      oo   www  www  www     xxxx             *
 *            ppppppppp    ooo    ooo   wwww www wwww      xx              *
 *            ppp           oooooooo     wwwwwwwwwww      xxxx             *
 *            ppp            oooooo       wwwwwwwww        xx              *
 *                                                                         *
 *            (Programmers Oberon/2 Workbench for MS-Windows)              *
 *                                                                         *
 *            Part of project: 32-Bit Linker, Hauptprogramm                *
 *                                                                         *
 ***************************************************************************/

#include <afx.h>


/*************************
 * constant declarations *
 *************************/

#define OPT_DEBUGINFO   0x0100
#define OPT_GENERATEDLL 0x0400
#define OPT_CONSOLE     0x2000
#define OPT_DEBUGCV5    0x8000

#define MAX_EXPORTS 1000
#define MAX_OBJS 1000
#define MAX_LIBS 1000


/******************                   
 * linker version *
 ******************/     
     
static char linkerVersion[]= "Pow!-Link32 1.1";


/*************
 * externals *
 *************/

int LinkProgram (LPSTR[], LPSTR[], LPSTR, LPSTR, LPSTR, LPSTR[], WORD, BOOL, BOOL, DWORD, FARPROC, ULONG, ULONG);
int ChooseTestProgram (int sel, FARPROC msg);

extern "C" int WINAPI Link32 (int opt,LPSTR obj,LPSTR lib,LPSTR exe,LPSTR res,LPSTR exp,FARPROC msg,ULONG baseAdr,LPSTR entrySym,ULONG stackSize);
extern "C" void WINAPI GetLinkVersion (LPSTR lp);


/*************************************************************
 * copy sequential strings to pointer array with MAX entries *
 * (\001 seperates strings, "\001\000" signals the end)      *
 *************************************************************/

void CopyToPointerArray (LPSTR strings,LPSTR array[],int max)
{
   int i;

   i=0;
   while (i<max-1 && strings && *strings) {
      array[i] = strings;
      while (*strings && *strings!=0x1) strings++;
      if (*strings) {
         *strings = 0;
         strings++;
      }
      i++;
   }
   array[i] = NULL;
}

/****************
 * link project *
 ****************/

int WINAPI Link32 (int opt,LPSTR obj,LPSTR lib,LPSTR exe,LPSTR res,LPSTR exp,FARPROC msg,ULONG baseAdr,LPSTR entrySym,ULONG stackSize)
{
   BOOL ret;
   WORD subSystem;
   char startupSymbol[200];
   BOOL buildExe,buildWinNtFile;
   DWORD includeDebugInfo;
   LPSTR objects[MAX_OBJS],libraries[MAX_LIBS],exports[MAX_EXPORTS];

   CopyToPointerArray(obj,objects,MAX_OBJS);
   CopyToPointerArray(lib,libraries,MAX_LIBS);
   CopyToPointerArray(exp,exports,MAX_EXPORTS);

   if (opt & OPT_CONSOLE)
      subSystem= 0x03;
   else
      subSystem= 0x02;

   if (entrySym && *entrySym)
      strcpy(startupSymbol,entrySym);
   else if (opt & OPT_GENERATEDLL)
      strcpy(startupSymbol,"_DllEntryPoint@12"); /* @12 */
   else
      strcpy(startupSymbol,"_ExeEntryPoint@0"); /* @0 */
 
   buildExe= !(opt & OPT_GENERATEDLL);

   if (opt & OPT_DEBUGINFO) {
      if (opt & OPT_DEBUGCV5)
         includeDebugInfo= 2;
      else
         includeDebugInfo= 1;
   }
   else
      includeDebugInfo= 0;

   if (stackSize<0x1000) 
       stackSize=0x100000;

   buildWinNtFile= FALSE;

   /* call Christians ultimative linker! */
   //ChooseTestProgram(106,msg); ret = TRUE;
   ret = LinkProgram(objects,libraries,res,exe,startupSymbol,exports,subSystem,buildExe,buildWinNtFile,includeDebugInfo,msg,baseAdr,stackSize);
   return ret;
}
    
    
/********************************
 * get version number of linker *
 ********************************/
 
void WINAPI GetLinkVersion (LPSTR lp)
{                   
    lstrcpy(lp,(LPSTR)linkerVersion);                         
}
    
  
/***************************************
 * DLL initialization and finalization *
 ***************************************/

/*
int main (void)
{
    return 0;
}
*/

BOOL WINAPI MyDllEntryPoint (HINSTANCE hI,DWORD reason,LPVOID reserved)
{
    if (reason==DLL_PROCESS_ATTACH) {
    }

    if (reason==DLL_PROCESS_DETACH) {
    }

    return TRUE;
}

