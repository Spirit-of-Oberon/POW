#include <afx.h>

/**************************************************************************************************/
/***                           W  I   N   3   2       T   e   s   t                             ***/
/**************************************************************************************************/

/*** Funktionsprototypen ***/

int ChooseTestProgram(int, FARPROC);
																									

/*** Hauptprogramm für den Testaufruf ***/

int main(int argc, char *argv[])
{

 int sel= 0;
                
 //if (argc == 2)
 if (argc == 1)
	{   
  //sel= atoi(argv[1]);

  //sel= 3; 							// Simple32
		//sel = 119;			// Mandel
		//sel= 404;				// GDIDemo
		//sel= 502;				// Float 
		sel= 0x512;							// LinkExeR
		//		sel= 0x513;					// LinkExeD	

		//sel= 0x1002;	// Oberon DLL II
		//sel = 0x1010;  // Oberon Console Debug
		//sel = 0x1011;  //	Oberon MakeDll
		//sel = 0x1012;  //	Oberon	TestDll
		//sel = 0x1013;  // Oberon Oed32
		//sel= 0x1014;			// Puzzle	
		return ChooseTestProgram(sel, NULL);
 }    
	else 
		return FALSE;
}

