/***************************************************************************
 *                                                                         *
 *  MODULE  : PowPrint()                                                   *
 *                                                                         *
 *  PURPOSE : Printing code for Pow.                                       *
 *                                                                         *
 *  FUNCTIONS   :                                                          *
 *                                                                         *
 *        PrintFile ()     -  Prints the contents of the edit dialog.      *
 *        SetupPrinter ()  -  Call printer setup dialog                    *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <commdlg.h>
#include "powed.h"

PRINTDLG printerData;  /* information on current printer */
                                                         
                                                         
/***************************************************************************
 *                                                                         *
 *  FUNCTION   : PrintFile (HWND)                                          *
 *                                                                         *
 *  PURPOSE    : print the file in the active edit window.                 *
 *                                                                         *
 ***************************************************************************/

VOID FAR PrintFile (HWND hwnd)
{
    EditPrint(hwnd);
}


/***************************************************************************
 *                                                                         *
 *  FUNCTION   : SetupPrinter (HWND)                                       *
 *                                                                         *
 *  PURPOSE    : calls the setup-procedure of the printer.                 *
 *                                                                         *
 ***************************************************************************/

void FAR SetupPrinter (HWND hwnd)
{  
    DWORD flags;

    flags=printerData.Flags;
    printerData.Flags|=PD_PRINTSETUP;
    PrintDlg((LPPRINTDLG)&printerData);
    printerData.Flags=flags;
}

