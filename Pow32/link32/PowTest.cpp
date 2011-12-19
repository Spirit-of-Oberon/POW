#include <afx.h>


/**************************************************************************************************/
/***                           W  I   N   3   2       T   e   s   t                             ***/
/**************************************************************************************************/

int LinkProgram(LPSTR[], LPSTR[], LPSTR, LPSTR, LPSTR, LPSTR[], WORD, BOOL, BOOL, BOOL, FARPROC);

void MessageOut (FARPROC,char *);
extern FARPROC MsgProc;				  

BOOL LinkPowLinkerTestPrograms(int tstNmb, FARPROC msg)
{

 int sel= 0;
 char *pObjFilNam[50];
 char *pLibFilNam[50];
 char *pResFilNam;
 char *pszExeFilNam;
 
 char *expFncNam[50];

 char	*startUpCRTSym;
 WORD subSystem= 0x00;

 BOOL buildExeFile;
 BOOL buildWinNtFile;
 BOOL incDebugInf;

 BOOL lnkPrg= TRUE;
                
 if (tstNmb > 1)
	{   
   //sel= 0x1001;       
			sel= tstNmb;

   switch (sel)
   {

		/***************************************************************************/
  /***************************************************************************/
		/*****************   O W N    T E S T    P R O G R A M S   *****************/
		/***************************************************************************/
		/***************************************************************************/

																															    
    case 1:

			/****************************************************************/
			/*******************  H A L L O 3 2 . E X E  ********************/
			/****************************************************************/
   
	    pObjFilNam[0]= "f:\\linker32\\input\\hallo32\\hallo32.obj";
		  pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "d:\\msvc20\\lib\\libc.lib";
			pLibFilNam[1]= "d:\\msvc20\\lib\\kernel32.lib";
			pLibFilNam[2]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam=  "f:\\linker32\\output\\win32\\Hallo32.exe";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= TRUE;

		break;

		case 2:

			/****************************************************************/
			/******************  H A L L O 3 2 2 . E X E  *******************/
			/****************************************************************/
   
			pObjFilNam[0]= "f:\\linker32\\input\\hallo322\\foofile.obj";
			pObjFilNam[1]= "f:\\linker32\\input\\hallo322\\mainfile.obj";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "d:\\msvc20\\lib\\libc.lib";
			pLibFilNam[1]= "d:\\msvc20\\lib\\kernel32.lib";
			pLibFilNam[2]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam=  "f:\\linker32\\output\\win32\\Hallo322.exe";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= TRUE;

		break;


   /***************************************************************************/
   /***************************************************************************/
   /***************** W I N 3 2    T E S T    P R O G R A M S *****************/
   /***************************************************************************/
   /***************************************************************************/

		case 101:

			/**************************************************************/
			/*******************  C D T E S T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\CDTEST.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\COLORS.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\FIND.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\FONT.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\OPEN.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\PRINT.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\REPLACE.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\SAVE.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\TITLE.OBJ";
			pObjFilNam[9]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\CDTEST\\CDTEST.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CDTEST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		case 102:

			/**************************************************************/
			/*********************  C O M M . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\COMM\\TTY.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\COMM\\TTY.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\TTY.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		case 103:

			/**************************************************************/
			/*******************	C O N G U I . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CONGUI\\CONSOLE.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\CONGUI\\GUI.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\CONGUI\\CONGUI.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CONGUI.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		case 104:

			/**************************************************************/
			/******************  C O N S O L E . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\ALOCFREE.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CODEPAGE.OBJ";         
      pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CONINFO.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CONMODE.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CONSOLE.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CONTITLE.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CREATE.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CURSOR.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\FILLATT.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\FILLCHAR.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\FLUSH.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\GETLRGST.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\GETNUMEV.OBJ";
			pObjFilNam[13]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\HANDLER.OBJ";
			pObjFilNam[14]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\NUMBUT.OBJ";
			pObjFilNam[15]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\READCHAR.OBJ";
			pObjFilNam[16]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\READOUT.OBJ";
			pObjFilNam[17]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\SCROLL.OBJ";
			pObjFilNam[18]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\SIZE.OBJ";
			pObjFilNam[19]= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\WRITEIN.OBJ";
			pObjFilNam[20]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\CONSOLE\\CONSOLE.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CONSOLE.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		case 105:

			/**************************************************************/
			/*******************  C L I E N T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\CLINIT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\DDE.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\DDEMLCL.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\DIALOG.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\HUGE.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\INFOCTRL.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\MEM.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\CLIENT\\TRACK.OBJ";
			pObjFilNam[8]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CLIENT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		case 106:

			/**************************************************************/
			/********************  C L O C K . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CLOCK\\CLOCK.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\CLOCK\\CLOCKRES.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CLOCK.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 107:

			/**************************************************************/
			/******************  D D E I N S T . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\DDEADD.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\DDEDLG.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\DDEINST.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\DDEMAIN.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\DDEPROCS.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\DDEINST\\INSTALL.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DDEINST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 108:

			/**************************************************************/
			/********************  D D E M O . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DDEMO\\DDEMO.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 109:

			/**************************************************************/
			/******************  D D E P R O G . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DDEPROG\\PHTEST.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\DDEPROG\\PROGHELP.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\DDEPROG\\PHTEST.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\PHTEST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 110:

			/**************************************************************/
			/*******************  S E R V E R . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\SERVER\\DDE.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\SERVER\\DDEMLSV.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\SERVER\\DIALOG.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\SERVER\\HUGE.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\SERVER.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		
		case 111:

			/**************************************************************/
			/*************************  D E B   ***************************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DEB\\DEBDEBUG.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\DEB\\DEBMAIN.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\DEB\\DEBMISC.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\DEB\\LINKLIST.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\DEB\\TOOLBAR.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\DEB\\DEB.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DEB.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 112:

			/**************************************************************/
			/*******************  D Y N D L G . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DYNDLG\\DYNDLG.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\DYNDLG\\DYNDLG.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DYNDLG.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 113:

			/**************************************************************/
			/*****************  F O N T V I E W . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\FONTVIEW.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\DIALOGS.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\DISPLAY.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\STATUS.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\TOOLS.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\FONTVIEW\\FONTVIEW.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\FONTVIEW.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 114:

			/**************************************************************/
			/******************  G E N E R I C . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\GENERIC\\GENERIC.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\GENERIC\\GENERIC.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\GENERIC.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 115:

			/**************************************************************/
			/*******************  G L O B C L . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\ABOUT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\CONNECT.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\DISPATCH.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\GLOBCL.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\INIT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\MISC.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\SELECT.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\WINMAIN.OBJ";
			pObjFilNam[8]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[13]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\GLOBCL\\GLOBCL.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\GLOBCL.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 116:

			/**************************************************************/
			/*****************  G L O B C H A T . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\ABOUT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\DISPATCH.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\GLOBCHAT.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\INIT.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\MISC.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\WINMAIN.OBJ";
			pObjFilNam[6]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[13]= NULL;
    
   
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\GLOBSR\\GLOBCHAT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\GLOBCHAT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 117:

			/**************************************************************/
			/********************  H O O K S . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\HOOKS\\HOOKTEST.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\HOOKS\\HOOKTEST.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\HOOKTEST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 118:

			/**************************************************************/
			/******************  I P X C H A T . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\DISPATCH.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\CONNECT.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\ABOUT.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\IPXCHAT.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\INIT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\LISTEN.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\MISC.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\WINMAIN.OBJ";
			pObjFilNam[8]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[13]= NULL;
    
   
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\IPXCHAT\\IPXCHAT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\IPXCHAT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 119:

			/**************************************************************/
			/*******************  M A N D E L . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\JULIA.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\LOADBMP.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\SAVEBMP.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\DIBMP.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\BNDSCAN.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\PRINTER.OBJ";
			pObjFilNam[6]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\lib\\libc.lib";
			pLibFilNam[1]= "D:\\MSDEV\\lib\\kernel32.lib";
			pLibFilNam[2]= "D:\\MSDEV\\lib\\user32.lib";
			pLibFilNam[3]= "D:\\MSDEV\\lib\\gdi32.lib";
			pLibFilNam[4]= "D:\\MSDEV\\lib\\winspool.lib";
			pLibFilNam[5]= "D:\\MSDEV\\lib\\comdlg32.lib";
			pLibFilNam[6]= "D:\\MSDEV\\lib\\advapi32.lib";
			pLibFilNam[7]= "D:\\MSDEV\\lib\\shell32.lib";
			pLibFilNam[8]= "D:\\MSDEV\\lib\\ole32.lib";
			pLibFilNam[9]= "D:\\MSDEV\\lib\\oleaut32.lib";
			pLibFilNam[10]= "D:\\MSDEV\\lib\\uuid.lib";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MANDEL\\JULIA.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\JULIA.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 120:

			/**************************************************************/
			/*********************  M A P I . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MAPI\\MAPIAPP.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\MAPI\\MAPINIT.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MAPI\\MAPIAPP.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MAPIAPP.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 121:

			/**************************************************************/
			/*****************  M A Z E L O R D . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\BITMAP.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\DRAW.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\DRONES.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\INITMAZE.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\MAZE.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\MAZEDLG.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\MAZEWND.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\NETWORK.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\READSGRD.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\SCOREWND.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\TEXTWND.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\TOPWND.OBJ";
			pObjFilNam[12]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WINMM.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MAZELORD\\MAZE.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MAZE.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 122:

			/**************************************************************/
			/*******************  M E M O R Y . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MEMORY\\MEMORY.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\MEMORY\\NMMEMCLI.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\MEMORY\\NMMEMSRV.OBJ";
			pObjFilNam[3]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MEMORY\\MEMORY.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MEMORY.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 123:

			/**************************************************************/
			/*******************  M F E D I T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MFEDIT\\MFEDIT.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MFEDIT\\MFEDIT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MFEDIT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 124:

			/**************************************************************/
			/*****************  M L T I T H R D . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MLTITHRD\\MLTITHRD.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MLTITHRD\\MLTITHRD.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MLTITHRD.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 125:

			/**************************************************************/
			/********************  M Y P A L . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\MYPAL\\MYPAL.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\MYPAL\\MYPAL.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MYPAL.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 126:

			/**************************************************************/
			/******************  N M P I P E  . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\NMPIPE\\NMPIPE.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\MSVCRTD.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\NMPIPE.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 127:

			/**************************************************************/
			/****************		N P C L I E N T . E X E  *****************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\NPCLIENT\\CLIENT32.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\NPCLIENT\\CLIENT32.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CLIENT32.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 128:

			/**************************************************************/
			/*****************  N P S E R V E R . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\NPSERVER\\SERVER32.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\NPSERVER\\SERVER32.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\SERVER32.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 129:

			/**************************************************************/
			/******************  C O N N E C T . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\CONNECT.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\TESTLIB.LIB";
			pLibFilNam[13]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\CONNECT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;



		case 130:

			/**************************************************************/
			/*******************  D G R E C V . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\DGRECV\\DGRECV.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\TESTLIB.LIB";
			pLibFilNam[13]= NULL;
    
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DGRECV.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 131:

			/**************************************************************/
			/********************  B L O C K . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\BLOCK\\LISTEN.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\TESTLIB.LIB";
			pLibFilNam[13]= NULL;
    	    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\LISTEN.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 132:

			/**************************************************************/
			/*****************  N O N B L O C K . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\NONBLOCK\\LISTEN.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\TESTLIB.LIB";
			pLibFilNam[13]= NULL;
   
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\LISTEN2.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
			 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 133:

			/**************************************************************/
			/*********************  P I N G . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\PING\\PING.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\CONNECT\\TESTLIB.LIB";
			pLibFilNam[13]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\PING.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
			
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 134:

			/**************************************************************/
			/******************  T E S T L I B . L I B  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\TESTLIB\\.OBJ";
			pObjFilNam[8]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\TESTLIB.LIB";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
			
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 135:

			/**************************************************************/
			/**********************  P D C . E X E  ***********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\PDC\\PDC.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\PDC.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
			
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 136:

			/**************************************************************/
			/******************  P R I N T E R . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\ENUMPRT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\GETCAPS.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\GETPDRIV.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\PAINT.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\PRINTER.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\PRINTER\\PRINTER.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\PRINTER.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 137:

			/**************************************************************/
			/*****************	 R A S B E R R Y . E X E  *****************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\ABOUT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\AUTHDLG.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\DIALDLG.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\DISPATCH.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\INIT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\MISC.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\PHBKDLG.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\RASBERRY.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\RASUTIL.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\STATDLG.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\WINMAIN.OBJ";
			pObjFilNam[11]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\RASAPI32.LIB";
			pLibFilNam[13]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\RASBERRY\\RASBERRY.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\RASBERRY.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 138:

			/**************************************************************/
			/*******************  M O N K E Y . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\REGISTRY\\MONKEY.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\REGISTRY\\MONKEY.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\MONKEY.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 139:

			/**************************************************************/
			/*******************  S E L E C T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\SELECT\\DEMO.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\SELECT\\SELECT.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\SELECT\\DEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\DEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

		
		case 140:

			/**************************************************************/
			/*******************  S I M P L E . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\SIMPLE\\SIMPLE.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\SIMPLE.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
			
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		
		case 141:

			/**************************************************************/
			/*****************  S P I N C U B E . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 142:

			/**************************************************************/
			/*******************  T E X T F X . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\TEXTFX\\FX.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\TEXTFX\\GUIDE.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\TEXTFX\\TEXTFX.OBJ";
			pObjFilNam[3]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\TEXTFX\\TEXTFX.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\TEXTFX.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 143:

			/**************************************************************/
			/******************  T T F O N T S . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\ALLFONT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\DIALOGS.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\DISPLAY.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\TOOLBAR.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\TTFONTS.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\TTFONTS\\TTFONTS.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\TTFONTS.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 144:

			/**************************************************************/
			/*****************  W D B G E X T S . D L L  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 145:

			/**************************************************************/
			/*****************  W I N C A P 3 2 . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WIN32\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		case 146:

			/**************************************************************/
			/********************  W S O C K . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN32\\WSOCK\\DIALOGS.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN32\\WSOCK\\WSOCK.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBCMT.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN32\\WSOCK\\WSOCK.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN32\\MY_EXE\\WSOCK.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

   /***************************************************************************/
   /***************************************************************************/
   /***************** W I N 9 5    T E S T    P R O G R A M S *****************/
   /***************************************************************************/
   /***************************************************************************/


		case 201:

			/**************************************************************/
			/*****************  C O M D L G 3 2 . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\COMDLG32\\COMDLG32.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\COMDLG32\\COMDLG32.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\COMDLG32.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 		case 202:

			/**************************************************************/
			/*****************	F I L E V I E W . D L L  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\CSTATHLP.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\CSTRTABL.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\FILEVIEW.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\FVINIT.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\FVPROC.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\FVTEXT.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\IFILEVW.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\IPERFILE.OBJ";
			pObjFilNam[8]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\FILEVIEW\\FILEVIEW.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\FILEVIEW.DLL";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
	case 203:

			/**************************************************************/
			/******************  F P A R S E R . D L L  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\FPARSER\\VS_ASC.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\FPARSER\\VSD_ASC.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\VS_ASC.DLL";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
	case 204:

			/**************************************************************/
			/********************  H F O R M . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\HFORM\\HFORM.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\PENWIN32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\HFORM\\HFORM.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\HFORM.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
		case 205:

			/**************************************************************/
			/******************  I C M T E S T . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\ICMTEST\\ICMTEST.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\ICMTEST\\PRINT.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN95\\ICMTEST\\DIB.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN95\\ICMTEST\\DIALOGS.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\ICMTEST\\ICMTEST.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\ICMTEST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
		case 206:

			/**************************************************************/
			/******************  F U L L I M E . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\FULLIME\\CANDUI.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\FULLIME\\GLOBAL.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN95\\FULLIME\\IMEUI.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN95\\FULLIME\\MAIN.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\IMM32.LIB";
			pLibFilNam[12]= NULL;
    
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\FULLIME\\FULLIME.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\FULLIME.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
		case 207:

			/**************************************************************/
			/******************  H A L F I M E . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\HALFIME\\MAIN.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\IMM32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\HALFIME\\HALFIME.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\HALFIME.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
		case 208:

			/**************************************************************/
			/******************  I M E A P P S . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\COMP.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\DATA.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\IMEAPPS.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\MODE.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\PAINT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\SETCOMP.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\STATUS.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\SUBS.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\TOOLBAR.OBJ";
			pObjFilNam[9]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\IMM32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\COMCTL32.LIB";
			pLibFilNam[13]= NULL;
    
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\IMEAPPS\\IMEAPPS.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\IMEAPPS.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
	case 209:

			/**************************************************************/
			/*******************  I N K P U T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\INKPUT\\IP.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\PENWIN32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\INKPUT\\IP.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\IP.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
	case 210:

			/**************************************************************/
			/*****************  S H E L L E X T . D L L   ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\COPYHOOK.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\CTXMENU.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\ICONHDLR.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\PROPSHET.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\SHELLEXT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\SHEXINTI.OBJ";
			pObjFilNam[6]=  NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\SHELLEXT\\SHELLEXT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\SHELLEXT.DLL";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 
	case 211:

			/**************************************************************/
			/******************  T R A Y N O T . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\TRAYNOT\\APP32.OBJ";
			pObjFilNam[1]=  NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\TRAYNOT\\APP32.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\APP32.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

	break;

		 
	case 212:

			/**************************************************************/
			/*******************  W I Z A R D . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WIN95\\WIZARD\\WIZARD.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\COMCTL32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WIN95\\WIZARD\\WIZARD.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WIN95\\MY_EXE\\WIZARD.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

	break;



	/***************************************************************************/
 /***************************************************************************/
 /***************** W I N N T    T E S T    P R O G R A M S *****************/
 /***************************************************************************/
 /***************************************************************************/

	case 301:

			/**************************************************************/
			/*******************  C L I E N T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\CLIENT\\SOCKCLI.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\CLIENT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 302:

			/**************************************************************/
			/********************  F I L E R . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\FILER\\FILER.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\FILER\\ENUMDRV.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\FILER\\DRVPROC.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\FILER\\EXPDIR.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\FILER\\FILER.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\FILER.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 303:

			/**************************************************************/
			/*******************  F L O P P Y . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\FLOPPY\\MFMT.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\MFMT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 304:

			/**************************************************************/
			/*******************  N E T A P I . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\NETAPI\\NETSMPLE.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\NETAPI32.LIB";
			pLibFilNam[12]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\NETSMPLE.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 305:

			/**************************************************************/
			/*******************  P L G B L T . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\PLGBLT\\PLGBLT.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\PLGBLT\\TRACK.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\PLGBLT\\BITMAP.OBJ";
			pObjFilNam[3]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\PLGBLT\\PLGBLT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\PLGBLT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 306:

			/**************************************************************/
			/*********************  P O P 3 . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\POP3SRV.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\POP3.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\POPFILE.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\SERVICE.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\EVENTS.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\DEBUG.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\PARAM.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\THREADS.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\POP3\\SOCKET.OBJ";
			pObjFilNam[9]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\RPCRT4.LIB";
			pLibFilNam[13]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\POP3\\POP3EVNT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\POP3SRV.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 307:

			/**************************************************************/
			/*******************  P R P E R F . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\PRPERF\\PRPERF.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\WSOCK32.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\PRPERF.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 308:

			/**************************************************************/
			/******************  R E G M P A D	. E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MULTIPAD.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MPINIT.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MPFILE.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MPFIND.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MPPRINT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MPOPEN.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\REGDB.OBJ";
			pObjFilNam[7]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\REGMPAD\\MULTIPAD.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\REGMPAD.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

		break;


	case 309:

			/**************************************************************/
			/**********************  R N R . E X E  ***********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 310:

			/**************************************************************/
			/******************  S E R V I C E . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 311:

			/**************************************************************/
			/*******************  S I D C L N . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 312:

			/**************************************************************/
			/******************  S I M P L E X . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 313:

			/**************************************************************/
			/******************  S O C K E T S . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 314:

			/**************************************************************/
			/******************  T A L E O W N . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 315:

			/**************************************************************/
			/******************  U N B U F C P Y . E X E  *****************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;


	case 316:

			/**************************************************************/
			/*******************  W X F O R M . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[10]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[11]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[12]= "F:\\LINKER32\\TEST\\WINNT\\\\.OBJ";
			pObjFilNam[13]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\WINNT\\\\.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\WINNT\\MY_EXE\\.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= TRUE;
			incDebugInf= FALSE;

	break;



 
	/***************************************************************************/
	/***************************************************************************/
	/*************** C R O S S D E V   T E S T    P R O G R A M S **************/
	/***************************************************************************/
	/***************************************************************************/

	case 401:

			/**************************************************************/
			/*****************  A D M N D E M O . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\HEADERS.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\MENU.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\ERRCHECK.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\ADMNDEMO.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\INI.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\STANDARD.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\INFO.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\EXECUTE.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\DIALOGS.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\RESULTS.OBJ";
			pObjFilNam[10]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\ADMNDEMO\\ADMNDEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\ADMNDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 		case 402:

			/**************************************************************/
			/******************  C P P D E M O . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\CPPDEMO\\CPPDEMO.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\CPPDEMO\\CODBC.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\CPPDEMO\\HEADERS.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\CPPDEMO\\DIALOGS.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\CPPDEMO\\CPPDEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\CPPDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
		
		case 403:

			/**************************************************************/
			/*****************  C R S R D E M O . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\HEADERS.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\DIALOGS.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\CHILD.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\FRAME.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\CRSRDEMO.OBJ";
			pObjFilNam[5]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;    	
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\CRSRDEMO\\CRSRDEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\CRSRDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
	 

		case 404:

			/**************************************************************/
			/******************  G D I D E M O . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\BOUNCE.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\DIALOG.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\DRAW.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\GDIDEMO.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\INIT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\MAZE.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\POLY.OBJ";
			pObjFilNam[7]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\STDWIN.OBJ";
			pObjFilNam[8]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\WININFO.OBJ";
			pObjFilNam[9]= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\XFORM.OBJ";
			pObjFilNam[10]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\GDIDEMO\\GDIDEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\GDIDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break; 

		case 405:

			/**************************************************************/
			/******************  G E N E R I C . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\GENERIC\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\GENERIC\\GENERIC.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= "D:\\MSDEV\\LIB\\VERSION.LIB";
			pLibFilNam[15]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\GENERIC\\GENERIC.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\GENERIC.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
					 

		case 406:

			/**************************************************************/
			/*******************  G E T D E V . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\GETDEV\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\GETDEV\\GETDEV.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\GETDEV\\GETDEV.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\GETDEV.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
	 

		case 407:

			/**************************************************************/
			/*******************  G E T S Y S . E X E  ********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\GETSYS\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\GETSYS\\GETSYS.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\GETSYS\\GETSYS.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\GETSYS.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 

		case 408:

			/**************************************************************/
			/*****************  G R I D F O N T . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\VIEW.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\BOX.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\CSET.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\FONT.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\GRID.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\APP.OBJ";
			pObjFilNam[7]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\GRIDFONT\\GRIDFONT.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\GRIDFONT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
				  

		case 409:

			/**************************************************************/
			/*****************  H O O K T E S T . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\HOOKTEST\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\HOOKTEST\\HOOKTEST.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\HOOKTEST\\HOOKTEST.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\HOOKTEST.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
				  

		case 410:

			/**************************************************************/
			/*********************  M D I _ . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\MDI_\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\MDI_\\MDI.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
      
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MDI_\\MDI.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\MDI.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
					  

		case 411:

			/**************************************************************/
			/*********************  M E N U . E X E  **********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\MENU\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\MENU\\MENU.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
    
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MENU\\MENU.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\MENU.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
					  

		case 412:

			/**************************************************************/
			/*****************  M U L T I P A D . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MPINIT.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MULTIPAD.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MPOPEN.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MPFIND.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MPFILE.OBJ";
			pObjFilNam[6]= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MPPRINT.OBJ";
			pObjFilNam[7]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[13]= NULL;
      
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MULTIPAD\\MULTIPAD.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\MULTIPAD.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 					
		case 413:

			/**************************************************************/
			/*****************  O W N C O M B O . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\OWNCOMBO\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\OWNCOMBO\\OWNCOMBO.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
        
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\OWNCOMBO\\OWNCOMBO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\OWNCOMBO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 						 
		case 414:

			/**************************************************************/
			/*****************  Q U R Y D E M O . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\QURYDEMO\\HEADERS.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\QURYDEMO\\MAIN.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\QURYDEMO\\QUERY.OBJ";
			pObjFilNam[3]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
     
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\QURYDEMO\\QURYDEMO.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\QURYDEMO.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;
			 

		case 415:

			/**************************************************************/
			/******************  S H O W D I B . E X E  *******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\DRAWDIB.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\SHOWDIB.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\DLGOPEN.OBJ";
			pObjFilNam[4]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\DIB.OBJ";
			pObjFilNam[5]= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\PRINT.OBJ";
			pObjFilNam[6]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
        
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\SHOWDIB\\SHOWDIB.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\SHOWDIB.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

 		
		case 416:

			/**************************************************************/
			/*****************  S U B C L A S S . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\CROSSDEV\\SUBCLASS\\STDWIN.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\CROSSDEV\\SUBCLASS\\SUBCLASS.OBJ";
			pObjFilNam[2]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBC.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= "D:\\MSDEV\\LIB\\USER32.LIB";
			pLibFilNam[3]= "D:\\MSDEV\\LIB\\GDI32.LIB";
			pLibFilNam[4]= "D:\\MSDEV\\LIB\\WINSPOOL.LIB";
			pLibFilNam[5]= "D:\\MSDEV\\LIB\\COMDLG32.LIB";
			pLibFilNam[6]= "D:\\MSDEV\\LIB\\ADVAPI32.LIB";
			pLibFilNam[7]= "D:\\MSDEV\\LIB\\SHELL32.LIB";
			pLibFilNam[8]= "D:\\MSDEV\\LIB\\OLE32.LIB";
			pLibFilNam[9]= "D:\\MSDEV\\LIB\\OLEAUT32.LIB";
			pLibFilNam[10]= "D:\\MSDEV\\LIB\\UUID.LIB";
			pLibFilNam[11]= "D:\\MSDEV\\LIB\\CTL3D32.LIB";
			pLibFilNam[12]= "D:\\MSDEV\\LIB\\ODBC32.LIB";
			pLibFilNam[13]= "D:\\MSDEV\\LIB\\ODBCCP32.LIB";
			pLibFilNam[14]= NULL;
       
			pResFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\SUBCLASS\\SUBCLASS.RES";
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\CROSSDEV\\MY_EXE\\SUBCLASS.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_WinMainCRTStartup";
			subSystem= 0x02;
 
			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;


		/***************************************************************************/
  /***************************************************************************/
		/*****************   O W N    T E S T    P R O G R A M S   *****************/
		/***************************************************************************/
		/***************************************************************************/
		

case 501:

			/**************************************************************/
			/********************  T E S T 1 . E X E  *********************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\OBERON\\TEST1\\TEST1.OBJ";
			pObjFilNam[1]= "F:\\LINKER32\\TEST\\OBERON\\TEST1\\RTSOBERO.OBJ";
			pObjFilNam[2]= "F:\\LINKER32\\TEST\\OBERON\\TEST1\\WIN32.OBJ";
			pObjFilNam[3]= "F:\\LINKER32\\TEST\\OBERON\\TEST1\\STRING.OBJ";
			pObjFilNam[4]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[1]= NULL;

			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\OBERON\\MY_EXE\\TEST1.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_MainCRTStartup@0";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= FALSE;

		break;

case 502:

			/**************************************************************/
			/*****************  F L O A T I N G . E X E  ******************/
			/**************************************************************/
         
			pObjFilNam[0]= "F:\\LINKER32\\TEST\\OWNPROG\\FLOAT\\DEBUG\\FLOAT.OBJ";
			pObjFilNam[1]= NULL;
 
			pLibFilNam[0]= "D:\\MSDEV\\LIB\\LIBCD.LIB";
			pLibFilNam[1]= "D:\\MSDEV\\LIB\\KERNEL32.LIB";
			pLibFilNam[2]= NULL;

			pResFilNam= NULL;
    
			pszExeFilNam= "F:\\LINKER32\\TEST\\OWNPROG\\MY_EXE\\FLOAT.EXE";
 
			expFncNam[0]= NULL;

			startUpCRTSym= "_mainCRTStartup";
			subSystem= 0x03;

			buildExeFile= TRUE;
			buildWinNtFile= FALSE;
			incDebugInf= TRUE;

		break;

  /****************************************************************/
  /*******************  OBERON  DLL            ********************/
  /****************************************************************/

		case 0x1001:
				MessageOut(msg, "------ Test der Dateifehlermeldungen ------");
				pObjFilNam[0]= "F:\\LINKER32\\TEST\\OBERON\\TESTDLL\\dlltest.obj";
    pObjFilNam[1]= "F:\\LINKER32\\TEST\\OBERON\\TESTDLL\\rtsobero.obj";
    pObjFilNam[2]= "F:\\LINKER32\\TEST\\OBERON\\TESTDLL\\winconso.obj";
    pObjFilNam[3]= "F:\\LINKER32\\TEST\\OBERON\\TESTDLL\\winbase.obj";
    pObjFilNam[4]= "F:\\LINKER32\\TEST\\OBERON\\TESTDLL\\string.obj";
    pObjFilNam[5]= NULL;
				//pObjFilNam[0]= NULL;
 
    pLibFilNam[0]= "d:\\msdev\\lib\\kernel32.lib";
    pLibFilNam[1]= NULL;
				//pLibFilNam[0]= NULL;
    
    pResFilNam= NULL;
    
    pszExeFilNam=  "F:\\LINKER32\\TEST\\OBERON\\MY_EXE\\dlltest.dll";
 
    expFncNam[0]= "_Test@4";
    expFncNam[1]= "DLLTest_$Init";
    expFncNam[2]= "DLLTest_$Data";
    expFncNam[3]= "DLLTest_$Const";
    expFncNam[4]= "DLLTest_$Code";
				expFncNam[5]= NULL;

    startUpCRTSym= "_DllEntryPoint@12";
    subSystem= 0x03;
 
    buildExeFile= FALSE;
    buildWinNtFile= FALSE;
    incDebugInf= FALSE;
	break;



   default:
    printf("\nAngegebenes Testprojekt steht nicht zur Verfügung!"); 
    lnkPrg= FALSE;
  }

  if (lnkPrg)
    LinkProgram(pObjFilNam, pLibFilNam, pResFilNam, pszExeFilNam, startUpCRTSym, 
                expFncNam, subSystem, buildExeFile, buildWinNtFile, incDebugInf, msg);  

 }    

 return 1;
}

