////////////////////////////////////////////////////////////////////////
//	PROJECT: POW! - Compiler Interface DLL for GNU-C++								//
////////////////////////////////////////////////////////////////////////
//																																		//
//	NAME: GNU_CPP.C																										//
//																																		//
//	HISTORY:																													//
//																																		//	
//	Version 1.0 written by Helml Thomas, 9455856 / 881								//
//																																		//
//	Parts used from Version 1.0 by Pfeiffer Bernhard, 9155224 / 880		//
//																																		//
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

#include <direct.h> 
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "resource.h"
#include "_gcc.h"

HINSTANCE hInst;		// Instanz der DLL Gnu_CPP (wird übergeben in DllMain)
HINSTANCE	hPowSup;	// Instanz der DLL POWSUP32.DLL
FARPROC GetElem;		// Prozedur aus POWSUP32.DLL
FARPROC CountList;	// Prozedur aus POWSUP32.DLL

// Erweiterungen für File-Open Dialog
FileExt SrcExt ={{"*.c",	"GNU-C Files (*.c)"},
								{"*.cpp", "GNU-C++ Files (*.cpp)"},
								{"*.h",		"GNU-Header Files (*.h)"},
								{"*.rc",	"GNU-Resource Files (*.rc)"},
								{"*.def", "GNU-Definition Files (*.def)"},
								{"*.*",		"All Files (*.*)"}}; 
// Erweiterungen für Projekt-Dialog
FileExt AddExt={{"*.c",		"GNU-C Files (*.c)"},
								{"*.cpp", "GNU-C++ Files (*.cpp)"},
								{"*.h",		"GNU-Header Files (*.h)"},
								{"*.rc",	"GNU-Resource Files (*.rc)"},
								{"*.def", "GNU-Definition Files (*.def)"},
								{"*.a",		"GNU-Library Files (*.a)"},
								{"*.*",		"All Files (*.*)"}};

// Vorausdeklarationen
EXPORT BOOL CALLBACK CheckIfYounger (HANDLE hDat, LPSTR module, LPSTR client);
EXPORT BOOL CALLBACK FileWasCompiled (HANDLE hDat, LPSTR file);
EXPORT BOOL CALLBACK SourceAvailable (HANDLE hDat, LPSTR module, LPSTR file);


void DBOutString (LPSTR string)
{
	MessageBox (0, string, "DEBUG", MB_OK);
}


void DBOutInt (int Int)
{
	char* string="";

	itoa(Int, string, 10);
	DBOutString (string);
}



//////////////////////////////////////////////////////////////////////////////
// BOOL GetRegistryEntry (LPSTR strKey, char *value)
//////////////////////////////////////////////////////////////////////////////
// Funktion: liefert den Inhalt des Keys strKey (String) in value zurück der 
//					 unter key gespeichert ist.
//
// Rückgabe: FALSE, wenn etwas schiefgelaufen ist, TRUE wenn alles OK
//////////////////////////////////////////////////////////////////////////////

BOOL GetRegistryEntry (LPSTR key, LPSTR strKey, LPSTR lpstrValue)
{
	DWORD len;							
	char str[_MAX_PATH]="";	
	DWORD dwType;
	HKEY hKey;	
	BOOL ok=TRUE;

	// existiert Schlüssel?
	if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, key, REG_SZ, 
									 KEY_READ, &hKey)==ERROR_SUCCESS)
	{	
		len=sizeof(str);
		if (RegQueryValueEx(hKey, strKey, NULL, &dwType, str, &len) != ERROR_SUCCESS)
			ok=FALSE;	// Fehler!!
		else strcpy (lpstrValue, str);	// auslesen des keys
		if (RegCloseKey(hKey) != ERROR_SUCCESS) ok=FALSE;
	}
	else ok=FALSE;	// Key existiert noch nicht
	return ok;
}


//////////////////////////////////////////////////////////////////////////////
// BOOL SetRegistryEntry (LPSTR lpstrDir, LPSTR lpstrValue, int iLen)
//////////////////////////////////////////////////////////////////////////////
// Funktion: setzt den Inhalt des Keys lpstrDir mit dem Wert lpstrValue und 
//					 der Länge iLen unter:
//					 "HKEY_LOCAL_MACHINE\SOFTWARE\Gnu C++\Paths\strKey"
//
// Rückgabe: liefert FALSE wenn etwas schiefgelaufen ist
//////////////////////////////////////////////////////////////////////////////

BOOL SetRegistryEntry (LPSTR lpstrDir, LPSTR lpstrValue, int iLen)
{
	HKEY hKey;	
	DWORD dwDisposition;
	BOOL ok=TRUE;
	SECURITY_ATTRIBUTES sa;
	
	sa.nLength=sizeof(SECURITY_ATTRIBUTES); 
  sa.lpSecurityDescriptor = NULL; 
  sa.bInheritHandle = TRUE; 
	// Schlüssel setzen
	if (RegCreateKeyEx (HKEY_LOCAL_MACHINE,	"SOFTWARE\\Gnu C++\\Paths",
						0, "String", REG_OPTION_NON_VOLATILE, KEY_WRITE, 
						&sa, &hKey, &dwDisposition)==ERROR_SUCCESS)
	{			
		// Werte setzen
		if (RegSetValueEx (hKey, lpstrDir, 0, REG_SZ, 
										 	 lpstrValue, iLen+1)!= ERROR_SUCCESS)
			ok=FALSE;
		if (RegCloseKey (hKey)!= ERROR_SUCCESS)
			ok=FALSE;
	}
	else ok=FALSE;
	return ok;
}


//////////////////////////////////////////////////////////////////////////////
// BOOL CreateRegistryEntry (LPSTR lpKeyName)
//////////////////////////////////////////////////////////////////////////////
// Funktion: beim erstmaligen Aufruf von dieser Compiler-DLL muß ein Key in 
//					 der Registry erstellt werden um die Pfade des Compilers bzw.
//					 den Include und Library Pfad zu speichern. Dieser geschieht hier
//					 unter: "HKEY_LOCAL_MACHINE\SOFTWARE\Gnu C++\Paths"
//
// Rückgabe: liefert FALSE wenn etwas schiefgelaufen ist
//////////////////////////////////////////////////////////////////////////////

BOOL CreateRegistryEntry (LPSTR lpKeyName)
{
	HKEY hKey;	
	DWORD dwDisposition;
	BOOL ok=TRUE;
	SECURITY_ATTRIBUTES sa;
	
	sa.nLength=sizeof(SECURITY_ATTRIBUTES); 
  sa.lpSecurityDescriptor = NULL; 
  sa.bInheritHandle = TRUE;
	// Schlüssel anlegen
	if (RegCreateKeyEx (HKEY_LOCAL_MACHINE,	"SOFTWARE\\Gnu C++\\Paths",
						0, "String", REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, 
						&sa, &hKey, &dwDisposition)==ERROR_SUCCESS) 
	{	
		// Initialiesieren mit ""
		if (RegSetValueEx (hKey, lpKeyName, 0, REG_SZ, "", 0)!= ERROR_SUCCESS)
			ok=FALSE;	// FEHLER
		if (RegCloseKey (hKey)!= ERROR_SUCCESS)
			ok=FALSE;	//FEHLER
	}
	else ok=FALSE;
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// void SetEnvironmentVariables(LPGLOBALDATA lpGlobDat)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Setzt die Umgebungsvariablen entsprechend den Einträgen die der
//					 Benutzer im Directory Fenster eingestellt hat. Gesetzt werden:
//					 PATH, GCC_EXEC_PREFIX, C_INCLUDE_PATH, CPLUS_INCLUDE_PATH und 
//					 LIBRARY_PATH
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

void SetEnvironmentVariables(LPGLOBALDATA lpGlobDat)
{
	char strPath[_MAX_PATH*3];	
	
	// PATH setzen 
	strcpy (strPath, lpGlobDat->strHomeDir);
	if (strPath[strlen (strPath)-1] != '\\') 
		strcat(strPath, "\\BIN");
	else 
		strcat (strPath, "BIN");
	// muß aus Kompatiblitätsgründen zu Windows 95/98 im 8.3 Format sein
	GetShortPathName(strPath, strPath, (_MAX_PATH*3));
	SetEnvironmentVariable("PATH", strPath);
	
	// GCC_EXEC_PREFIX setzen
	strcpy (strPath, lpGlobDat->strHomeDir);
	if (strPath[strlen (strPath)-1] != '\\') 
		sprintf (strPath, "%s\\lib\\gcc-lib\\", lpGlobDat->strHomeDir);
  else 
		sprintf (strPath, "%slib\\gcc-lib\\", lpGlobDat->strHomeDir);
	SetEnvironmentVariable("GCC_EXEC_PREFIX", strPath);

	// C_INCLUDE_PATH setzen
	strcpy (strPath, lpGlobDat->strCIncludeDir);
	if (strPath[strlen (strPath)-1] == '\\') 
		strPath[strlen (strPath)-1] = '\0';
	SetEnvironmentVariable("C_INCLUDE_PATH", lpGlobDat->strCIncludeDir);

	// CPLUS_INCLUDE_PATH setzen
	strcpy (strPath, lpGlobDat->strCPPIncludeDir);
	if (strPath[strlen (strPath)-1] == '\\') 
		strPath[strlen (strPath)-1] = '\0';
	SetEnvironmentVariable("CPLUS_INCLUDE_PATH", lpGlobDat->strCPPIncludeDir);

	// LIBRARY_PATH setzen
	strcpy (strPath, lpGlobDat->strLibDir);
	if (strPath[strlen (strPath)-1] == '\\') 
		strPath[strlen (strPath)-1] = '\0';
	SetEnvironmentVariable("LIBRARY_PATH", lpGlobDat->strLibDir);
}



//////////////////////////////////////////////////////////////////////////////
//
//  3.1 Initialisierung und Terminierung
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// EXPORT HANDLE CALLBACK InitInterface (LPSTR compilerName, LPSTR powDir, 
//																			 DWORD ddeInstId)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Diese Funktion wird erstmaligen Öffnen der CompilerDLL 
//				   aufgerufen. Hier wird ein globaler Speicherblock angelegt und
//					 initialisiert. Beim allerersten Aufruf dieser DLL wird 
//
// Rückgabe: HANDLE auf globalen Speicherblock
//////////////////////////////////////////////////////////////////////////////

EXPORT HANDLE CALLBACK InitInterface (LPSTR compilerName, 
		 																	LPSTR powDir, 
																			DWORD ddeInstId)
{
	HANDLE h;
	LPGLOBALDATA lpGlobDat;
	char dllPath[_MAX_PATH];	// Pfad zur POWSUP32.DLL 

	if ((h=GlobalAlloc (GMEM_MOVEABLE, sizeof (GLOBALDATA)))!=0)
	{
		lpGlobDat = (LPGLOBALDATA)GlobalLock (h);
		strcpy (lpGlobDat->compilerName, compilerName);		// Compilername speichern
		strcpy (lpGlobDat->powDir, powDir);								// Pow! Verzeichnis sichern
		lpGlobDat->ddeInstId=ddeInstId;										// DDE Handle speichern
		
		// POWSUP32.DLL muß geladen werden, damit später darauf zugegriffen werden kann
		sprintf(dllPath,"%s\\powsup32.dll", lpGlobDat->powDir);
		hPowSup=LoadLibrary(dllPath);
		if (hPowSup==NULL) MessageBox (0, "Error: POWSUP32.DLL not found!", "Error", MB_OK);
		else
		{	// die Funktionen "GetElem" und "CountList" werden benötigt beim Linken
			GetElem=GetProcAddress(hPowSup, "GetElem");
			CountList=GetProcAddress(hPowSup, "CountList");
		}
		// Initialisieren der Compiler Optionen mit den Vorgabewerten
		lpGlobDat->iCompilerSwitches = (0 | C_SW_DEBUG | C_SW_NOOPT | C_SW_I386);
		strcpy (lpGlobDat->strStdCompilerSwitches, "");
   	strcpy (lpGlobDat->strCompilerSwitches, "-g -O0 -mcpu=i386 -march=i386 -m386");
		strcpy (lpGlobDat->strExtraCompilerSwitches, "\0");
		// Initialisieren der Linker Optionen mit den Vorgabewerten
		lpGlobDat->iLinkerSwitches = (0 | L_SW_CONSOLE);
		strcpy (lpGlobDat->strStdLinkerSwitches, "\0");
		strcpy (lpGlobDat->strLinkerSwitches, "\0");
		strcpy (lpGlobDat->strExtraLinkerSwitches, "\0");
		
		// Initialisierung der Directory Options 
	
		///////////// HOME DIRECTORY ////////////////
		// Prüfen, ob erster Aufruf überhaupt
		if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","Home Directory", lpGlobDat->strHomeDir))
		{
			strcpy(lpGlobDat->strHomeDir,"");
			// Wenn Eintrag noch nicht vorhanden, dann anlegen
			if (!CreateRegistryEntry("Home Directory"))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
			// Schlüssel initialisieren
			if (!SetRegistryEntry ("Home Directory", "", 0))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);		
		}
		
		///////////// C - INCLUDE DIRECTORY ////////////////
		// Prüfen, ob erster Aufruf überhaupt
		if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","C Include Directory", lpGlobDat->strCIncludeDir))
		{
			strcpy(lpGlobDat->strCIncludeDir,"");
			// Wenn Eintrag noch nicht vorhanden, dann anlegen
			if (!CreateRegistryEntry("C Include Directory"))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
			// Schlüssel initialisieren
			if (!SetRegistryEntry ("C Include Directory", "", 0))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
		}
		
		///////////// C++ - INCLUDE DIRECTORY ////////////////
		// Prüfen, ob erster Aufruf überhaupt
		if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","CPP Include Directory", lpGlobDat->strCPPIncludeDir))
		{
			strcpy(lpGlobDat->strCPPIncludeDir,"");
			// Wenn Eintrag noch nicht vorhanden, dann anlegen
			if (!CreateRegistryEntry("CPP Include Directory"))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
			// Schlüssel initialisieren
			if (!SetRegistryEntry ("CPP Include Directory", "", 0))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
		}
		
		///////////// LIB DIRECTORY ////////////////
		// Prüfen, ob erster Aufruf überhaupt
		if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","Lib Directory", lpGlobDat->strLibDir))
		{
			strcpy(lpGlobDat->strLibDir,"");
			// Wenn Eintrag noch nicht vorhanden, dann anlegen
			if (!CreateRegistryEntry("Lib Directory"))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
			// Schlüssel initialisieren
			if (!SetRegistryEntry ("Lib Directory", "", 0))
				MessageBox (0, "Error in Registry!", "Error", MB_OK);
		}

		// Umgebungsvariable setzen !!!
		SetEnvironmentVariables(lpGlobDat);
		GlobalUnlock (h);
	}
	return h;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK ExitInterface (HANDLE hDat)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Hier wird der in InitInterface allokierte Speicher und die
//				   "Powsupp-Dll" aus dem Speicher freigegeben.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK ExitInterface (HANDLE hDat)
{
	// Powsup32.dll wieder freigeben
	if (!FreeLibrary(hPowSup)) 
		MessageBox (0, "Error: Unloading POWSUP32.DLL failed!", "Error", MB_OK);
	GlobalFree(hDat);	// Globalen Speicherblock freigeben
}



//////////////////////////////////////////////////////////////////////////////
//
// 3.2 Übersetzen
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK AboutDlgProc (HWND hDlg, UINT iMsg, 
//																		WPARAM wParam, LPARAM lParam)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Fensterprozedur, wird aufgerufen in AboutCompiler.
//
// Rückgabe: TRUE, wenn auf OK-Button gedrückt wird.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK AboutDlgProc (HWND hDlg, 
																	 UINT iMsg, 
																	 WPARAM wParam, 
																	 LPARAM lParam)
{
	// OK gedrückt-> Ende des Dialogs
	if ((iMsg==WM_COMMAND) && (LOWORD (wParam)==IDOK))
	{
		EndDialog (hDlg, 0);
		return TRUE;
	}
	else return FALSE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK AboutCompiler (HANDLE hDat, HWND hwnd)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Zeigt den About-Dialog an.
//
// Rückgabe: TRUE, wenn auf OK-Button gedrückt wird.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK AboutCompiler (HANDLE hDat, 
																		HWND hwnd)
{
	return (DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUT), 
					hwnd, AboutDlgProc) != -1);
}



//////////////////////////////////////////////////////////////////////////////
// BOOL CheckCompilerOption (LPGLOBALDATA lpGlobDat, int iCompilerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft, ob die Compileroption iCompilerSwitch im globalen
//					 Speicherblock gesetzt ist.
//
// Rückgabe: TRUE, falls CompilerOption aktiviert, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

BOOL CheckCompilerOption (LPGLOBALDATA lpGlobDat, 
													int iCompilerSwitch)
{
	return ((lpGlobDat->iCompilerSwitches & iCompilerSwitch) == iCompilerSwitch);
}



//////////////////////////////////////////////////////////////////////////////
// void SetCompilerOption (HWND hDlg,	int iDlgElement, 
//												 LPGLOBALDATA lpGlobDat, int iCompilerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Schickt anhand der bereits gespeicherten Compileroptionen an das
//					 Dialogfeld iDlgElement eine entsprechende Meldung.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

void SetCompilerOption (HWND hDlg,
												int iDlgElement,
												LPGLOBALDATA lpGlobDat, 
												int iCompilerSwitch)
{
	if (CheckCompilerOption (lpGlobDat, iCompilerSwitch))
		SendDlgItemMessage (hDlg, iDlgElement, BM_SETCHECK, BST_CHECKED, 0);
	else 
		SendDlgItemMessage (hDlg, iDlgElement, BM_SETCHECK, BST_UNCHECKED, 0);
}



//////////////////////////////////////////////////////////////////////////////
// BOOL GetCompilerOption (HWND hDlg,	int iDlgElement,
//												 LPGLOBALDATA lpGlobDat, int iCompilerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft, ob iDlgElement gesetzt ist, falls dies der Fall ist, so 
//					 wird der "iCompilerSwitch" entsprechend in der globalen Speicher-
//					 struktur gespeichert.
//
// Rückgabe: TRUE, falls das Dialogelement "iDlgElement" gesetzt war, 
//					 FALSE sonst
//////////////////////////////////////////////////////////////////////////////

BOOL GetCompilerOption (HWND hDlg,
												int iDlgElement,
												LPGLOBALDATA lpGlobDat, 
												int iCompilerSwitch)
{
	if (SendDlgItemMessage (hDlg, iDlgElement, BM_GETCHECK, 0, 0) == BST_CHECKED)
	{
		lpGlobDat->iCompilerSwitches = (lpGlobDat->iCompilerSwitches | iCompilerSwitch);
		return TRUE;
	}
	return FALSE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK CompileDlgProc (HWND hDlg, UINT iMsg, 
//																		  WPARAM wParam, LPARAM lParam)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Fensterprozedur für CompileOptions
//
// Rückgabe: TRUE, falls Änderungen vorgenommen wurden, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK CompileDlgProc (HWND hDlg, 
																		 UINT iMsg, 
																		 WPARAM wParam, 
																		 LPARAM lParam)
{
	static LPGLOBALDATA lpGlobDat;
	char strHelpFile[_MAX_PATH];	// Pfad zu "GNU C++.hlp" Hilfe zum Interface
	char strKeyword[17]="Compiler Options";	// Schlüsselwort innerhalb Hilfe
	
	switch (iMsg)
	{
		// Setze auf gespeicherte Werte beim Initialisieren des Dialogs
		case WM_INITDIALOG:
			lpGlobDat=(LPGLOBALDATA)lParam;
			SetCompilerOption (hDlg, IDC_SUPPORTANSI, lpGlobDat, C_SW_SUPPORTANSI);
			SetCompilerOption (hDlg, IDC_PROFILE, lpGlobDat, C_SW_PROFILE);
			SetCompilerOption (hDlg, IDC_DEBUG, lpGlobDat, C_SW_DEBUG);
			SetCompilerOption (hDlg, IDC_SYNTAX, lpGlobDat, C_SW_SYNTAX);
			SetCompilerOption (hDlg, IDC_WARNANSI, lpGlobDat, C_SW_WARNANSI);
			SetCompilerOption (hDlg, IDC_ERRORANSI, lpGlobDat, C_SW_ERRORANSI);
			SetCompilerOption (hDlg, IDC_ALLERRORS, lpGlobDat, C_SW_ALLERRORS);
			SetCompilerOption (hDlg, IDC_INHIBITWARN, lpGlobDat, C_SW_INHIBITWARN);
			SetCompilerOption (hDlg, IDC_NOOPT, lpGlobDat, C_SW_NOOPT);
			SetCompilerOption (hDlg, IDC_OPT1, lpGlobDat, C_SW_OPT1);
			SetCompilerOption (hDlg, IDC_OPT2, lpGlobDat, C_SW_OPT2);
			SetCompilerOption (hDlg, IDC_OPT3, lpGlobDat, C_SW_OPT3);
			SetCompilerOption (hDlg, IDC_OPTSIZE, lpGlobDat, C_SW_OPTSIZE);
			SetCompilerOption (hDlg, IDC_I386, lpGlobDat, C_SW_I386);
			SetCompilerOption (hDlg, IDC_I486, lpGlobDat, C_SW_I486);
			SetCompilerOption (hDlg, IDC_PENTIUM, lpGlobDat, C_SW_PENTIUM);
			SetCompilerOption (hDlg, IDC_PENTIUMPRO, lpGlobDat, C_SW_PENTIUMPRO);
			SetDlgItemText(hDlg, IDC_EXTRA_COMPILER_OPTIONS, 
										 lpGlobDat->strExtraCompilerSwitches); 
			break;			
		case WM_COMMAND:
			switch (LOWORD (wParam))
			{
				// wenn OK Button gedrückt, dann auslesen der Veränderungen
				case IDOK: 
					lpGlobDat->iCompilerSwitches=0;
					strcpy (lpGlobDat->strCompilerSwitches, lpGlobDat->strStdCompilerSwitches);
					if (GetCompilerOption (hDlg, IDC_SUPPORTANSI, lpGlobDat, C_SW_SUPPORTANSI))
						strcat (lpGlobDat->strCompilerSwitches, " -ansi");
					if (GetCompilerOption (hDlg, IDC_PROFILE, lpGlobDat, C_SW_PROFILE))
						strcat (lpGlobDat->strCompilerSwitches, " -pg");
					if (GetCompilerOption (hDlg, IDC_DEBUG, lpGlobDat, C_SW_DEBUG))
						strcat (lpGlobDat->strCompilerSwitches, " -g");
					if (GetCompilerOption (hDlg, IDC_SYNTAX, lpGlobDat, C_SW_SYNTAX))
						strcat (lpGlobDat->strCompilerSwitches, " -fsyntax-only");
					if (GetCompilerOption (hDlg, IDC_WARNANSI, lpGlobDat, C_SW_WARNANSI))
						strcat (lpGlobDat->strCompilerSwitches, " -pedantic");
					if (GetCompilerOption (hDlg, IDC_ERRORANSI, lpGlobDat, C_SW_ERRORANSI))
						strcat (lpGlobDat->strCompilerSwitches, " -pedantic-errors");
					if (GetCompilerOption (hDlg, IDC_ALLERRORS, lpGlobDat, C_SW_ALLERRORS))
						strcat (lpGlobDat->strCompilerSwitches, " -Werror");
					if (GetCompilerOption (hDlg, IDC_INHIBITWARN, lpGlobDat, C_SW_INHIBITWARN))
						strcat (lpGlobDat->strCompilerSwitches, " -w");
					if (GetCompilerOption (hDlg, IDC_NOOPT, lpGlobDat, C_SW_NOOPT))
						strcat (lpGlobDat->strCompilerSwitches, " -O0");
					if (GetCompilerOption (hDlg, IDC_OPT1, lpGlobDat, C_SW_OPT1))
						strcat (lpGlobDat->strCompilerSwitches, " -O1");
					if (GetCompilerOption (hDlg, IDC_OPT2, lpGlobDat, C_SW_OPT2))
						strcat (lpGlobDat->strCompilerSwitches, " -O2");
					if (GetCompilerOption (hDlg, IDC_OPT3, lpGlobDat, C_SW_OPT3))
						strcat (lpGlobDat->strCompilerSwitches, " -O3");
					if (GetCompilerOption (hDlg, IDC_OPTSIZE, lpGlobDat, C_SW_OPTSIZE))
						strcat (lpGlobDat->strCompilerSwitches, " -Os");
					if (GetCompilerOption (hDlg, IDC_I386, lpGlobDat, C_SW_I386))
						strcat (lpGlobDat->strCompilerSwitches, " -mcpu=i386 -march=i386 -m386");
					if (GetCompilerOption (hDlg, IDC_I486, lpGlobDat, C_SW_I486))
						strcat (lpGlobDat->strCompilerSwitches, " -mcpu=i486 -march=i486 -m486");
					if (GetCompilerOption (hDlg, IDC_PENTIUM, lpGlobDat, C_SW_PENTIUM))
						strcat (lpGlobDat->strCompilerSwitches, " -mcpu=i586 -march=pentium -mpentium");
					if (GetCompilerOption (hDlg, IDC_PENTIUMPRO, lpGlobDat, C_SW_PENTIUMPRO))
						strcat (lpGlobDat->strCompilerSwitches, " -mcpu=i686 -march=pentiumpro -mpentiumpro");
			    GetDlgItemText(hDlg, IDC_EXTRA_COMPILER_OPTIONS,
						lpGlobDat->strExtraCompilerSwitches, MAX_SW_LENGTH);
					EndDialog (hDlg, 0);
					break;

				case IDCANCEL:	// CANCEL gedrückt-> nichts übernehmen
					EndDialog (hDlg, 0);
					break;
				
				case IDHELP_COMPILE:	// HILFE anzeigen
					strcpy (strHelpFile, lpGlobDat->powDir);
					strcat (strHelpFile, "\\GNU C++.hlp");
					WinHelp(hDlg, strHelpFile, HELP_KEY, (DWORD) &strKeyword);
					break;
			}
		default: return FALSE;
	}
	return TRUE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK CompileOptions (HANDLE hDat, 
//																			HWND hwnd)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Öffnet einen Dialog, in welchem die Compiler Optionen eingestellt
//					 werden müssen.
//
// Rückgabe: TRUE, wenn Änderungen, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK CompileOptions (HANDLE hDat, 
																		 HWND hwnd)
{
	BOOL ok;
	LPGLOBALDATA lpGlobDat;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// schicke Daten an Dialogbox zur Initialisierung ...
	ok=DialogBoxParam(hInst, MAKEINTRESOURCE(IDD_COMPILE), hwnd,
										(DLGPROC)CompileDlgProc, (LPARAM)lpGlobDat); 
	GlobalUnlock (hDat);
	return ok;
}


   
//////////////////////////////////////////////////////////////////////////////
// void DelChars(int i, char strErrOut[])
//////////////////////////////////////////////////////////////////////////////
// Funktion: Löscht im String "strErrOut" alle Zeichen bis zum i-ten.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

void DelChars(int i, char strErrOut[])
{
	int j=0, len;

	len=strlen(strErrOut);	// Länge des Strings strErrOut
	while (i<len)						// String ab Position i bis zum Ende durchlaufen
	{
		strErrOut[j]=strErrOut[i];	// an den Anfang kopieren
		j++; i++;
	}
	strErrOut[j]='\0';		// Ende des Strings
}



//////////////////////////////////////////////////////////////////////////////
// BOOL GetErrors(char tempPath[], FARPROC msg, FARPROC err)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Die Datei "tempPath" wird nach Fehler gescannt, welche mittels 
//					 der Funktion "err" an POW! zur Ausgabe übergeben wird. Weiters
//					 steht noch die Funktion "msg" zur Ausgabe von Text zur Verfügung.
//					
//					 Folgendes Fehlerverhalten wurde für den Gnu-Compiler erkannt:
//
//				   Compilerfehler haben die Form: "gcc.exe: blablabla..."
//					 Erklärungen haben die Form: "C:\path\file.c: In function 'main':"
//					 Errors haben die Form: "C:\path\file.c:1: blablabla..."
//					 Warnings haben die Form: "C:\path\file.c:1: warning: blablabla..."
//
// Rückgabe: FALSE, wenn Temporäre Datei "tempPath" nicht geöffnet werden 
//					 kann, TRUE sonst.
//////////////////////////////////////////////////////////////////////////////

BOOL GetErrors(char tempPath[], FARPROC msg, FARPROC err)
{
	BOOL ok, bFound, bWarn, bLinkerCall;
	DWORD dwFileSize, dwBytesRead;
	HANDLE hFile, hError;
	LPSTR lpStr;
	SECURITY_ATTRIBUTES sa;
	char strErrOut[256], strErrNo[256];
	DWORD i, j, dwWarns=0, dwErrors=0;

	bLinkerCall=(err==NULL);		// kommt der Aufruf vom Linker??
	// Security Attribute setzen
	ZeroMemory (&sa, sizeof (sa)); 
	sa.nLength=sizeof(sa);  sa.lpSecurityDescriptor = NULL;  sa.bInheritHandle = TRUE; 
	// Temporäre Datei mit Fehlermeldungen öffnen
	hFile = CreateFile (tempPath, GENERIC_READ, FILE_SHARE_READ, 
										  (LPSECURITY_ATTRIBUTES) &sa, OPEN_EXISTING, 
											FILE_ATTRIBUTE_TEMPORARY, NULL);
	// Fehler beim Öffnen?
	if (hFile==INVALID_HANDLE_VALUE) 
	{
		CloseHandle (hFile);
		return FALSE;
	}	
	dwFileSize=GetFileSize(hFile, NULL);	// Länge des Tempfiles bestimmen
	if (dwFileSize==0)	// Datei leer -> keine Fehler 
		msg("No Errors.");
	else
	{	// TEMP-File nicht leer-> FEHLER !!
		hError=LocalAlloc(LMEM_MOVEABLE, dwFileSize);
		lpStr = (LPSTR)LocalLock (hError);
		// die ganze Datei in einen Puffer in den Heap laden
		ok=ReadFile(hFile, lpStr,	dwFileSize,
								&dwBytesRead,	NULL);
		i=0;
		// den ganzen Speicherblock scannen
		while (i<dwFileSize)
		{
			bWarn=FALSE;
			// Zeilenweise scannen, Zeilen werden von einem '\r' und '\n' abgeschlossen
			j=0;
			while ((i<dwFileSize) && (lpStr[i]!='\n'))
			{
				if (lpStr[i]!='\r') strErrOut[j]=lpStr[i];
				i++; j++;
			}
			strErrOut[j-1]='\0'; 
			i++; j=0; bFound=FALSE;
			// Zuerst einmal die ganze Zeile nach einem Eintrag der Form ":XX"
			// wobei XX für eine Zahl steht.
			while ((strErrOut[j]!='\0') && (!bFound))
			{
				if ((j>1) && (strErrOut[j-1]==':') && 
						(strErrOut[j]>='0') && (strErrOut[j]<='9'))
					bFound=TRUE;
				else j++;
			}
			// Wurde keine Zahl gefunden, so handelt es sich um einen Compiler/Linker
			// Fehler bzw. um eine Erklärung, d.h. auf jeden Fall ausgeben
			if (!bFound) 
			{
				msg (strErrOut);
				// Wenn Compiler-/Linker-Fehler dann Fehler erhöhen
				if (strncmp(strErrOut, "gcc:", 4)==0) 
					dwErrors++;
				// "fake:" wird normalerweise beim linken einer DLL geliefert, wenn dort etwas
				// schiefgelaufen ist. 
				if (strstr(strErrOut, "fake:")!=NULL) 
					dwErrors++;
			}
			else
			{
				if (bLinkerCall)	// stammt Aufruf vom Linker??
				{
					if (strncmp (strErrOut, "warning: ",9)==0) // WARNING ??
						dwWarns++;
					else 
						dwErrors++;
					// Linkerfehler müssen über "msg" ausgegeben werden, da von POW! beim
					// Linkeraufruf die Adresse für die Funktion "err" mitgegeben wird.
					msg (strErrOut);
				}
				else
				{
					DelChars(j, strErrOut); // Anfang der Zeile bis Beginn der Zahl löschen
					j=0; 
					// Zeilennummer auslesen
					while ((strErrOut[j]!='\0') && (strErrOut[j]!=':')) 
						{j++; }
					strcpy (strErrNo, strErrOut);
					strErrNo[j]='\0';
					DelChars (j+2, strErrOut); // ": " löschen
					if (strncmp (strErrOut, "warning: ",9)==0) // WARNING ??
					{
						bWarn=TRUE;
						dwWarns++;			// Anzahl Warnings erhöhen
						DelChars(9, strErrOut);	// "warning: " löschen
					}
					else 
						dwErrors++;	// Anzahl Errors erhöhen
					err (-1, atoi(strErrNo), 0, bWarn, strErrOut);	// verwendet werden
				}
			}
		}
		// Ausgabe zur Information, Anzahl Error/Warning insgesamt
		sprintf(strErrOut, "%d Error(s), %d Warning(s)", dwErrors, dwWarns);
		msg (strErrOut);
		LocalUnlock(hError); LocalFree(hError); 	CloseHandle(hError);
	}
	CloseHandle (hFile);
	return TRUE;
}



//////////////////////////////////////////////////////////////////////////////
// BOOL RunCommand (char strCommandLine[], HANDLE hOutput)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Erzeugt einen Prozess (Aufruf von "strCommandLine") und über-
//					 gibt die Ausgabe des Compilers an die Datei strTempFile.
//
// Rückgabe: TRUE, wenn Prozess erzeugt wurde, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

BOOL RunCommand (char strCommandLine[], char strTempFile[])
{
	BOOL ok=FALSE;
	STARTUPINFO si;
	SECURITY_ATTRIBUTES sa;
	PROCESS_INFORMATION pi; 
	HANDLE hFile;
	
	ZeroMemory (&sa, sizeof (sa)); 
 	sa.nLength=sizeof(sa); 
  sa.lpSecurityDescriptor = NULL; 
  sa.bInheritHandle = TRUE;
	// Temporäre Datei erzeugen
	hFile = CreateFile (strTempFile, GENERIC_WRITE, 
											FILE_SHARE_WRITE, &sa, CREATE_ALWAYS, 
											FILE_ATTRIBUTE_TEMPORARY, NULL);
	// Startupinfo: Die Standarausgabe und der StandardError werden nun in das
	// Tempfile umgeleitet (es müssen für diesen Compiler beide sein!!)
	ZeroMemory( &si, sizeof(si));
  si.cb = sizeof(si);
	si.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
	si.hStdError = hFile;
	si.hStdOutput = hFile;
  si.wShowWindow = SW_MINIMIZE;

  // Child Prozess starten
  if (CreateProcess( NULL,	// Kein module name 
      strCommandLine,				// Aufruf in der Form: "gcc ...."
      NULL,									// Process handle nicht vererbbar 
      NULL,									// Thread handle nicht vererbbar 
      TRUE,									// Handles werden vererbt
      0,										// Keine "creation flags" 
      NULL,									// Umgebungsvariablen des aufrufenden Prozesses übernehmen
      NULL,									// Startverzeichnis des aufrufenden Prozesses übernehmen
      &si,									// Zeiger auf STARTUPINFO Struktur
      &pi))									// Zeiger auf PROCESS_INFORMATION Struktur
  {
		ok=TRUE;
		WaitForSingleObject( pi.hProcess, INFINITE);
		// Prozess und Thread-Handle schließen
		CloseHandle( pi.hProcess );
		CloseHandle( pi.hThread );
	}
	CloseHandle(hFile);	// Handle der Temporären Datei schließen
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK CompileFile (HANDLE hDat, LPSTR file, FARPROC msg, 
// 																	 FARPROC err, HWND fromWnd, FARPROC first, 
// 																	 FARPROC next, FARPROC fileOpen, 
//																	 FARPROC fileRead, FARPROC fileClose)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Ruft den Compiler "gcc" auf und compiliert die Datei "file".
//					 Fehler werden mittels der Prozedur "err" übergeben.
//
// Rückgabe: TRUE, wenn sich Interface des Moduls geändert hat
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK CompileFile (HANDLE hDat, 
																	LPSTR file, 
																	FARPROC msg, 
																	FARPROC err,
																	HWND fromWnd, 
																	FARPROC first, 
																	FARPROC next,
																	FARPROC fileOpen, 
																	FARPROC fileRead, 
																	FARPROC fileClose)
{
	LPGLOBALDATA lpGlobDat;
	char strCommandLine[_MAX_PATH],						// Befehlszeile: Aufruf des Compilers
			 strPrjDir[_MAX_PATH],								// Projektverzeichnis
			 strSourceFile[_MAX_FNAME+_MAX_EXT],	// zu kompilierende Datei
			 strTargetFile[_MAX_PATH],						// kompilierte Datei
			 strTempFile[_MAX_PATH],							// temporäre Datei (Fehlerausgabe speichern)
			 drive[_MAX_DRIVE], dir[_MAX_DIR],		// werden zum zerlegen eines Pfades "drive:\dir\fname.ext"
			 fname[_MAX_FNAME], ext[_MAX_EXT],		// in seine Bestandteile benötigt
			 strSwitches[MAX_SW_LENGTH],					// Compileroptionen für Aufruf
			 strInfo[81];													// Ausgabestring für Pow!
		
	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);

	// Projektverzeichnis auslesen und zerlegen
	strcpy (strPrjDir, lpGlobDat->prjName);		
	_splitpath (strPrjDir, drive, dir, fname, ext);
	sprintf (strPrjDir, "%s%s", drive, dir);
	// "wechseln" des Arbeitsverzeichnis in das Projektverzeichnis
	GetShortPathName (strPrjDir, strPrjDir, _MAX_PATH);
	SetCurrentDirectory(strPrjDir);
	// Optionen für Aufruf zusammenstellen
	sprintf (strSwitches, "%s %s", lpGlobDat->strCompilerSwitches, 
																 lpGlobDat->strExtraCompilerSwitches);
	// Sourcefile wird zerlegt
	_splitpath (file, drive, dir, fname, ext);
	// Prüfung, ob es sich um ein Headerfile (.h) oder Definitionfile (.def) handelt
	if ((strcmp (_strlwr(ext), ".h")) && (strcmp (_strlwr(ext), ".def")))
	{
		_strlwr(fname);	// Umwandlung in Kleinschreibung
		// Sourcefile und Tempfile bestimmen
		sprintf (strSourceFile, "%s%s", fname, ext);
		sprintf (strTempFile, "%s%s%s.tmp", drive, dir, fname);
		if (!strcmp(_strlwr(ext), ".rc"))
		{		// Wenn Quelldatei eine Resource (.rc), dann windres aufrufen 
			sprintf (strTargetFile, "%s.coff", fname);
			sprintf (strCommandLine, "windres %s -o %s", strSourceFile, strTargetFile);
		//	DeleteFile(strTargetFile);
		}
		else		// normale .c bzw. .cpp Datei
		{
			sprintf (strTargetFile, "%s.o", fname);
			sprintf (strCommandLine, "gcc %s -o %s -c %s",
							 strSourceFile, strTargetFile, strSwitches);
		}
		msg(strCommandLine);	// Ausgeben der Befehlszeile
		sprintf (strInfo, "Compiling '%s' ...", file);	// Info ausgeben
		msg(strInfo);
		GlobalUnlock (hDat);
		// Aufruf der erstellten Befehlszeile, Fehler werden in strTempFile umgeleitet
		if (RunCommand (strCommandLine, strTempFile))
		{
			if (!strcmp(_strlwr(ext), ".rc"))
			{
				// beim Aufruf des Resourcencompilers "windres" ist es nicht möglich die Ausgabe
				// umzuleiten, deshalb wird nur geprüft, ob eine (.coff) Datei erzeugt wurde, 
				// dann wurde der Compiler-Vorgang korrekt abgschlossen, sonst ist ein Fehler 
				// aufgetreten. Es kann jedoch nicht bestimmt werden wo im Source.
				if (!FileWasCompiled(hDat, file))
					err(-1, 0, 0, FALSE, "Error in resource file.");	// trotzdem Fehler melden!
				else msg("0 Error(s), 0 Warning(s)");
			}
			else
			{
				if (!GetErrors(strTempFile, msg, err))		// Fehler beim kompilieren prüfen
					msg("Error: Could not open Logfile!");	// Fehler beim erstellen der Logdatei 
			}
		}
		else 
			msg ("Error: Could not start process.");		// Fehler im Prozess !!
	}
	return TRUE;
}



//////////////////////////////////////////////////////////////////////////////
// BOOL CheckHeaderFile (HANDLE hDat, char strFile[])
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft ob es zu strFile (Format: "name") ein entsprechendes .C 
//					 bzw. .CPP-Source File im Projektverzeichnis gibt.
//					 Wird von CheckDepend benötigt.
//
// Rückgabe: TRUE, wenn ein Sourcefile gefunden wird, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

BOOL CheckHeaderFile (HANDLE hDat, char strFile[])
{
	char strCheckC[_MAX_PATH],		// Pfad der .C Datei
			 strCheckCPP[_MAX_PATH],	// Pfad der .C Datei
			 drive[_MAX_DRIVE], dir[_MAX_DIR], 
			 fname[_MAX_FNAME], ext[_MAX_EXT];
	LPGLOBALDATA lpGlobDat;
	BOOL bExist=FALSE;	// Rückgabewert der Funktion

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	_splitpath (lpGlobDat->prjName, drive, dir, fname, ext);
	// Pfade zu der .C bzw. .CPP Datei bestimmen
	sprintf (strCheckC, "%s%s%s.c", drive, dir, strFile);
	sprintf (strCheckCPP, "%s%s%s.cpp", drive, dir, strFile);
	GlobalUnlock (hDat);
	if (SourceAvailable (hDat, strCheckC, strCheckC))	
		bExist=TRUE;	// es gibt eine C Datei
	else 
		if (SourceAvailable (hDat, strCheckCPP, strCheckCPP)) 
			bExist=TRUE;	// es existiert ein C++ File
	return bExist;
}



//////////////////////////////////////////////////////////////////////////////
// BOOL CheckForInclude (char strLine[], char strHeaderFile[])
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft ob in der Zeile strLine ein Eintrag der Art 
//					 "#include "name.h"" enthalten ist, falls dies der Fall ist, 
//					 so wird der Dateiname des HeaderFiles in "strHeaderFile" zurück-
//					 gegeben.
//
// Rückgabe: TRUE, wenn ein #include gefunden wurde + Dateiname in 
//					 "strHeaderFile", FALSE sonst
//////////////////////////////////////////////////////////////////////////////

BOOL CheckForInclude (char strLine[], char strHeaderFile[])
{
	int i=0;
	BOOL bFound=FALSE;	// '#' gefunden ?

	// Suchen nach einem '#' -> Beginn einer jeden "include"-Anweisung
	while ((i<MAX_EDITOR_LINE) && (!bFound) && (strLine[i]!='\n') && (strLine[i]!='\r')) 
	{
		if (strLine[i]=='#') bFound=TRUE;
		else i++;
	}
	if (bFound)	// wenn '#' gefunden
	{
		DelChars(i, strLine);		// Zeichen die voher sind (eventuelle Leerzeichen) löschen
		if (!strncmp (strLine, "#include", 8))
		{
			DelChars(9, strLine);	// "#include " löschen
			// folgen noch mehrere Leerzeichen, dann diese löschen?
			while ((strLine[i]!='\n') && (strLine[i]!='\r') && (strLine[i]==' ')) i++;
			DelChars (i, strLine);
			i=0;
			if (strLine[0]=='"')	// Zeichen nachher ein Hochkomma???
			{
				DelChars(1, strLine);	// Hochkomma löschen
				while ((i<MAX_EDITOR_LINE) && (strLine[i]!='\n') && (strLine[i]!='\r') && (strLine[i]!='"'))
				{
					i++;		// vorwärts bis Ende (d.h. bis wieder Hochkomma, sonst Fehler)
				}
				if (strLine[i]=='"') // aktuelles Zeichen Hochkomma?
				{
					strncpy(strHeaderFile, strLine, i);	// dann HeaderFile gefunden.
					strHeaderFile[i-2]='\0';						// ".h" weglassen
					return TRUE;												
				}
			}
		}
	}
	return FALSE;		// keine #include Anweisung in dieser Zeile
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK CheckDepend (HANDLE hDat, LPSTR file, FARPROC depends, 
//																	 HWND fromWnd, FARPROC first, FARPROC next,
//																	 FARPROC fileOpen, FARPROC fileRead, 
//																	 FARPROC fileClose)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Diese Funktion liefert alle Dateien an POW! zurück (mittels 
// "depends") welche von file abhängig sind, d.h. welche unbedingt vorher 
// kompiliert werden müssen.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK CheckDepend (HANDLE hDat, 
																	LPSTR file, 
																	FARPROC depends, 
																	HWND fromWnd, 
																	FARPROC first, 
																	FARPROC next,
																	FARPROC fileOpen, 
																	FARPROC fileRead, 
																	FARPROC fileClose)
{
	char strLine[MAX_EDITOR_LINE], // eine Zeile im Source
			 strHeaderFile[_MAX_FNAME+_MAX_EXT];	// Name+Erweiterung der Headerdatei
	FILE *f;
	int i;
	BOOL bComment=FALSE; // Offenes Kommentar??
	
	if ((f=fopen(file,"r")) !=NULL)	// Datei öffnen
	{
		// bis zum Dateiende Datei zeilenweise einlesen
		while (!feof(f) && (fgets(strLine, sizeof(strLine), f) >0)) 
		{ 
			i=0;
			// Als erstes Kommentare der Art: "/* */" überlesn
			while ((i<MAX_EDITOR_LINE-1) && (strLine[i]!='\n') && (strLine[i]!='\r'))
			{
				if (bComment) // Kommentar offen?
				{
					if ((strLine[i]=='*') && (strLine[i+1]=='/')) // Kommentarende? 
					{
						strLine[i]=' '; strLine[i+1]=' ';		// "*/" durch Leerzeichen ersetzen
						bComment=FALSE;
					}
					else		// wenn Kommentar offen, Zeichen durch Leerzeichen ersetzten
						strLine[i]=' ';
				}
				else	// Kommentar geschlossen
				{
					if ((strLine[i]=='/') && (strLine[i+1]=='*'))	// Prüfen, ob Kommentar
					{
						strLine[i]=' ';	strLine[i+1]=' ';		// "/*" durch Leerzeichen ersetzen
						bComment=TRUE;
					}
				}
				i++;
			}
			i=0;
			// Zweiter Schritt: Kommentare der Form ; "//" überlesen
			while ((i<2047) && (strLine[i]!='\n') && (strLine[i]!='\r'))
			{
				if ((strLine[i]=='/') && (strLine[i+1]=='/'))	// Kommentar gefunden
					strLine[i]='\n';		// Rest der Zeile ist sinnlos
				else 
					i++;
			}
			// Dritter Schritt: Prüfen, ob die Anweisung '#include' in der Zeile steht.
			if (CheckForInclude (strLine, strHeaderFile))
			{
				// Falls nun ein gültiges .C bzw. .CPP File existiert, dann => Abhängigkeit
				if (CheckHeaderFile(hDat, strHeaderFile))	
					depends (strHeaderFile);
			}
		}
		fclose(f);
	}
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK CheckIfYounger (HANDLE hDat, LPSTR module, 
//																			LPSTR client)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft ob die Datei "client" existiert oder älter als "module" ist.
//
// Rückgabe: TRUE, wenn "client" nicht existiert oder älter als "module" ist
//					 FALSE sonst
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK CheckIfYounger (HANDLE hDat,
																		 LPSTR  module,
																		 LPSTR  client)
{
  FILETIME ftClient;    // last write access to client
  HANDLE   hClient;     // file handle for client
  HANDLE   hModule;     // file handle for module
	FILETIME ftModule;    // last write access to module

  /* -- get time of last write access to client -- */
  hClient = CreateFile(client, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, 0, NULL);
  if (hClient != NULL) {
    GetFileTime(hClient, NULL, NULL, &ftClient);
    CloseHandle(hClient);
  }
  /* -- get time of last write access to module -- */
  hModule = CreateFile(module, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, 0, NULL);
  if (hModule != NULL) {
    GetFileTime(hModule, NULL, NULL, &ftModule);
    CloseHandle(hModule);
  }
	return (hClient == NULL) || (CompareFileTime(&ftModule, &ftClient) > 0);
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK FileWasCompiled (HANDLE hDat, LPSTR file)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft prüft, ob die Datei "file" schon einmal compiliert wurde
//
// Rückgabe: TRUE, wenn "file" schon einmal compiliert wurde, FALSE sonst
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK FileWasCompiled (HANDLE hDat, 
																			LPSTR file)
{
	BOOL ok=TRUE;	// Rückgabewert
	char strObjFile[_MAX_PATH],	 // Pfad der Object-Datei
			 drive[_MAX_DRIVE], dir[_MAX_DIR],
			 fname[_MAX_FNAME], ext[_MAX_EXT];

	_splitpath (file, drive, dir, fname, ext);
	// handelt es sich um ein Header-File oder eine Definitions-Datei?
	if ((!strcmp (ext, ".h"))  || (!strcmp (ext, ".def"))) 
		ok=TRUE;
	else 
	{
		if(!strcmp(ext, ".rc"))		// Resourcefile => dann prüfen, ob .COFF Datei existiert
			sprintf (strObjFile, "%s%s%s.coff", drive, dir, fname);	
		else
			sprintf (strObjFile, "%s%s%s.o", drive, dir, fname);	// Prüfen, ob Objektdatei
		ok=!CheckIfYounger(hDat, file, strObjFile);	// Prüfen ob schon mal Kompiliert.
	}
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK SourceAvailable (HANDLE hDat, LPSTR module, 
//																			 LPSTR file)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft, ob die Datei "module" existiert, wenn ja wird der Datei-
//					 name in "file" zurückgegeben
//
// Rückgabe: TRUE, wenn "module" existiert, FALSE sonst
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK SourceAvailable (HANDLE hDat, 
																			LPSTR module, 
																			LPSTR file)
{
	HANDLE h;			// Handle auf Datei
	BOOL ok=TRUE;	// Rückgabewert

	// Wenn sich Datei öffnen läßt, so existiert sie
	h=CreateFile (module, 0, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (h==INVALID_HANDLE_VALUE)	// ungültiges Handle => Source exisitiert nicht
		ok=FALSE;
	else 
		strcpy (file, module);	// Source existiert
	CloseHandle(h);
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK MustBeBuilt (HANDLE hDat, LPSTR file)
//////////////////////////////////////////////////////////////////////////////
// Funktion: "file" muß übersetzt werden, wenn kein dazugehöriges Objekt-File
//					 existiert, bzw. wenn "file" jünger als das Objekt-File ist.
//
// Rückgabe: TRUE, wenn "file" übersetzt werden muß, FALSE sonst
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK MustBeBuilt (HANDLE hDat, 
																	LPSTR file)
{
	BOOL ok=TRUE;		// Rückgabewert
	char strObjFile[_MAX_PATH],		// Pfad der Object-Datei 
		   drive[_MAX_DRIVE], dir[_MAX_DIR],
			 fname[_MAX_FNAME], ext[_MAX_EXT];
	
	_splitpath (file, drive, dir, fname, ext);
	if ((!strcmp (ext, ".h"))  || (!strcmp (ext, ".def"))) 
		ok=FALSE;
	else 
	{
		if (!strcmp (ext, ".rc"))		// Resourcefile -> Objects haben Endung .COFF 
			sprintf (strObjFile, "%s%s%s.coff", drive, dir, fname);
		else	
			sprintf (strObjFile, "%s%s%s.o", drive, dir, fname);	// Objektfile
		ok=CheckIfYounger(hDat, file, strObjFile);	// prüfen, ob ObjFile existiert, bzw. ob jünger
	}
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
//
// 3.3 Linker
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BOOL CheckLinkerOption (LPGLOBALDATA lpGlobDat, int iLinkerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft, ob die Linkeroption iLinkerSwitch im globalen
//					 Speicherblock gesetzt ist.
//
// Rückgabe: TRUE, falls LinkerOption aktiviert, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

BOOL CheckLinkerOption (LPGLOBALDATA lpGlobDat, 
												int iLinkerSwitch)
{
	return ((lpGlobDat->iLinkerSwitches & iLinkerSwitch) == iLinkerSwitch);
}



//////////////////////////////////////////////////////////////////////////////
// void SetLinkerOption (HWND hDlg,	int iDlgElement, 
//											 LPGLOBALDATA lpGlobDat, int iLinkerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Schickt anhand der bereits gespeicherten Linkeroptionen an das
//					 Dialogfeld iDlgElement eine entsprechende Meldung.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

void SetLinkerOption (HWND hDlg,
											int iDlgElement,
											LPGLOBALDATA lpGlobDat, 
											int iLinkerSwitch)
{
	if (CheckLinkerOption (lpGlobDat, iLinkerSwitch))
		SendDlgItemMessage (hDlg, iDlgElement, BM_SETCHECK, BST_CHECKED, 0);
	else 
		SendDlgItemMessage (hDlg, iDlgElement, BM_SETCHECK, BST_UNCHECKED, 0);
}



//////////////////////////////////////////////////////////////////////////////
// BOOL GetLinkerOption (HWND hDlg,	int iDlgElement,
//											 LPGLOBALDATA lpGlobDat, int iLinkerSwitch)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Prüft, ob iDlgElement gesetzt ist, falls dies der Fall ist, so 
//					 wird der "iLinkerSwitch" entsprechend in der globalen Speicher-
//					 struktur gespeichert.
//
// Rückgabe: TRUE, falls das Dialogelement "iDlgElement" gesetzt war, 
//					 FALSE sonst
//////////////////////////////////////////////////////////////////////////////

BOOL GetLinkerOption (HWND hDlg,
											int iDlgElement,  
											LPGLOBALDATA lpGlobDat, 
											int iLinkerSwitch)
{
	if (SendDlgItemMessage (hDlg, iDlgElement, BM_GETCHECK, 0, 0) == BST_CHECKED)
	{
		lpGlobDat->iLinkerSwitches =  (lpGlobDat->iLinkerSwitches | iLinkerSwitch);
		return TRUE;
	}
	return FALSE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK LinkDlgProc (HWND hDlg, UINT iMsg, 
//																	 WPARAM wParam, LPARAM lParam)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Fensterprozedur für LinkerOptions
//
// Rückgabe: TRUE, falls Änderungen vorgenommen wurden, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK LinkDlgProc (HWND hDlg, 
																	UINT iMsg, 
																	WPARAM wParam, 
																	LPARAM lParam)
{
	static LPGLOBALDATA lpGlobDat;
  char strHelpFile[_MAX_PATH]="";				// Pfad incl. Dateiname der Hilfedatei
	char strKeyword[15]="Linker Options";	// Keywort zum Suchen innerhalb Hilfedatei

	switch (iMsg)
	{
		case WM_INITDIALOG:
			lpGlobDat=(LPGLOBALDATA)lParam;
			// Dialogelemente initialisieren
			SetLinkerOption (hDlg, IDC_CONSOLE, lpGlobDat, L_SW_CONSOLE);
			SetLinkerOption (hDlg, IDC_WINDOWS, lpGlobDat, L_SW_WINDOWS);
			SetLinkerOption (hDlg, IDC_DLL, lpGlobDat, L_SW_DLL);
			SetDlgItemText(hDlg, IDC_EXTRA_LINKER_OPTIONS, 
										 lpGlobDat->strExtraLinkerSwitches); 
			break;
		case WM_COMMAND:
			switch (LOWORD (wParam))
			{
				// Wenn OK gedrückt wurde, müssen alle Änderungen gespeichert werden
				case IDOK: 
					strcpy (lpGlobDat->strLinkerSwitches, lpGlobDat->strStdLinkerSwitches);
					lpGlobDat->iLinkerSwitches=0;
					GetLinkerOption (hDlg, IDC_CONSOLE, lpGlobDat, L_SW_CONSOLE);
					if (GetLinkerOption (hDlg, IDC_WINDOWS, lpGlobDat, L_SW_WINDOWS))
						strcat (lpGlobDat->strLinkerSwitches, " -mwindows");
					if (GetLinkerOption (hDlg, IDC_DLL, lpGlobDat, L_SW_DLL))
						strcat (lpGlobDat->strLinkerSwitches, " -mdll");
					GetDlgItemText(hDlg, IDC_EXTRA_LINKER_OPTIONS,
												 lpGlobDat->strExtraLinkerSwitches, MAX_SW_LENGTH);
					EndDialog (hDlg, 0);	// Dialog-Ende
					break;
				// wird CANCEL angeklickt passiert nichts.
				case IDCANCEL:	
					EndDialog (hDlg, 0);	// Dialog beenden
					break;
				// HELP => Hilfe wird mit dem richtigen Fenster angezeigt
				case IDHELP_LINK:
					strcpy (strHelpFile, lpGlobDat->powDir);
					strcat (strHelpFile, "\\GNU C++.hlp");
					WinHelp(hDlg, strHelpFile, HELP_KEY, (DWORD) &strKeyword);
					break;
			}
		default: return FALSE;
	}
	return TRUE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK LinkerOptions (HANDLE hDat, HWND hwnd)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Öffnet einen Dialog, in welchem die Linker Optionen eingestellt
//					 werden müssen.
//
// Rückgabe: TRUE, wenn Änderungen, FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK LinkerOptions (HANDLE hDat, 
	 																  HWND hwnd)
{
	BOOL ok;
	LPGLOBALDATA lpGlobDat;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	ok = DialogBoxParam(hInst, MAKEINTRESOURCE(IDD_LINK), hwnd, 
					    (DLGPROC)LinkDlgProc, (LPARAM)lpGlobDat)!=-1;
	GlobalUnlock (hDat);
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK Link (HANDLE hDat, LPSTR file, 
//														LPHANDLE flist, FARPROC msg)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Ruft den Linker "gcc" auf und linkt die Object Dateien, welche
//					 zu den Source Files aus der Liste "flist" gehören in eine Datei
//					 "file" zusammen.
//					 Fehler sowie sonstige Mitteilungen an den Benutzer müssen mittels
//					 der Prozedur "msg" übergeben werden.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK Link (HANDLE hDat, 
													 LPSTR file, 
													 LPHANDLE flist, 
													 FARPROC msg)
{
	LPGLOBALDATA lpGlobDat;
	HANDLE hLocalMem;			// lokaler Speicherblock für Objectfile-Liste
	int i, 
			iCountList;				// Anzahl der Dateien im Projekt
	char strCommandLine[(_MAX_FNAME+_MAX_EXT)*4+MAX_SW_LENGTH],		// Aufruf des Linkers
			 strDLLToolLine[(_MAX_FNAME+_MAX_EXT)*5+MAX_SW_LENGTH],		// Aufruf des "dlltool"
			 strPrjDir[_MAX_PATH],				// Projektverzeichnis
			 strTargetFile[_MAX_FNAME+_MAX_EXT],		// Datei, die erzeugt wird
			 strExpFile[_MAX_FNAME+_MAX_EXT],				// .EXP Datei, für DLL benötigt
			 strObjectFile[_MAX_FNAME+_MAX_EXT],		// Objekt Datei
			 strLibFile[_MAX_FNAME+_MAX_EXT]="",		// .LIB Datei, bei DLL Linkvorgang erzeugt
			 strTempFile[_MAX_PATH],								// temporäre Datei für Fehlerausgabe
			 strPrjFile[_MAX_PATH],									// eine Datei aus dem Projekt
 			 drive[_MAX_DRIVE], dir[_MAX_DIR],	// werden zum zerlegen eines Pfades "drive:\dir\fname.ext"
			 fname[_MAX_FNAME], ext[_MAX_EXT],	// in seine Bestandteile benötigt
			 strSwitches[MAX_SW_LENGTH]="";			// Linkeroptionen bei Aufruf
	LPSTR lpObjectFiles;		// Pointer auf String, in dem alle Objekt Dateien stehen
	BOOL bCPP=FALSE,		// sind C++ Files im Projekt?
			 bDEF=FALSE,		// soll DLL erzeugt werden und keine .DEF Datei im Projekt?
			 bDLL=FALSE,		// soll eine DLL erzeugt werden?
			 bError=FALSE;	// irgendwo Fehler aufgetreten ?
	
	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);

	strcpy (strPrjDir, lpGlobDat->prjName);
	_splitpath (strPrjDir, drive, dir, fname, ext);
	sprintf (strPrjDir, "%s%s", drive, dir);
	GetShortPathName (strPrjDir, strPrjDir, _MAX_PATH);
	// aktives Arbeitsverzeichnis ins Projektverzeichnis setzen
	SetCurrentDirectory(strPrjDir);
	_splitpath (file, drive, dir, fname, ext);
	// Prüfung, ob DLL erzeugt werden soll
	if ((lpGlobDat->iLinkerSwitches) == L_SW_DLL) 
	{
		bDLL=TRUE;
		// Target und .EXP-Dateien bestimmen
		sprintf (strTargetFile, "%s.dll", fname);
		sprintf (strExpFile, "%s.exp", fname);
	}
	else	// sonst wird .EXE generiert
	  sprintf (strTargetFile, "%s.exe", fname);
	// Temp-File Pfad setzen
	sprintf (strTempFile, "%s%s%s.tmp", drive, dir, fname);
	iCountList=CountList(flist); // aus wievielen Dateien besteht das Projekt
	// Speicher für Projektdateien - Liste allokieren
	hLocalMem=LocalAlloc(LMEM_MOVEABLE, iCountList*_MAX_PATH);
	lpObjectFiles = (LPSTR)LocalLock (hLocalMem);
	strcpy(lpObjectFiles, "\0");
	// aus allen Dateien im Projekt muß nun eine "Object"-Liste erzeugt werden, d.h. die
	// Namen aller Objekt Dateien aneinandergereiht durch Leerzeichen getrennt um
	// den Linker aufrufen zu können
	for (i=1;i<=iCountList;i++)	// alle Dateien aus dem Projekt durchgehen
	{
		GetElem(flist, i, strPrjFile);	// Datei aus Element holen
		_splitpath (strPrjFile, drive, dir, fname, ext);
		if (strcmp(_strlwr(ext), ".h"))	// Header-Files werden nicht mitgelinkt
		{
			if (strcmp(_strlwr(ext), ".rc"))
			{	// kein Resource File-> prüfen, ob Library
				if (!strcmp(_strlwr(ext), ".a")) 
					sprintf (strLibFile, "%s.a ",  fname);	// Libraries werden mitgelinkt
				else 
				{	// prüfen, ob Definition File? -> werden nicht mitgelinkt
					if (!strcmp(_strlwr(ext), ".def")) 
						bDEF=TRUE;	// wichtig, bei DLL Generierung daß .DEF Datei vorhanden !!
					else
					{	// sonst ist es eine einfache Objektdatei
						sprintf (strObjectFile, "%s.o ",  fname);
						strcat(lpObjectFiles, strObjectFile);
					}
				}
			}
			else
			{	// kompilierte Resource-Files haben Endung ".COFF"
				sprintf (strObjectFile, "%s.coff ", fname);
				strcat(lpObjectFiles, strObjectFile);
			}
		}
		if (!strcmp(_strlwr(ext), ".cpp")) 
			bCPP=TRUE;	// C++ Source File
	}
	// Optionen für Linkeraufruf vorbereiten
	if (strlen(lpGlobDat->strLinkerSwitches)>0) 
		strcat (strSwitches, lpGlobDat->strLinkerSwitches);
	if (strlen(lpGlobDat->strExtraLinkerSwitches)>0) 
		strcat (strSwitches, lpGlobDat->strExtraLinkerSwitches);
	if (bCPP) // bei C++ Dateien muß die Bibliothek "libstdc++.a" mitgelinkt werden!
		strcat (strSwitches, " -lstdc++");
	if (bDLL)
	{ // Linkeraufruf, bei DLL Erzeugung
		sprintf (strCommandLine, "gcc -o %s %s %s %s", strTargetFile, 
						 strExpFile, lpObjectFiles, strSwitches);
	}
  else
	{
		if (strlen(strLibFile)>0) // Wird ein Lib-File mitgelinkt, dann Linkeraufruf so:
			sprintf (strCommandLine, "gcc %s %s -o %s %s", lpObjectFiles, 
							 strLibFile, strTargetFile, strSwitches);
		else	// sonst normaler Linkeraufruf 
			sprintf (strCommandLine, "gcc %s -o %s %s", lpObjectFiles, 
			 	  	   strTargetFile, strSwitches);
	}
	LocalUnlock(hLocalMem);	LocalFree(hLocalMem);	CloseHandle(hLocalMem);
	GlobalUnlock (hDat);	
	if (bDLL)
	{
		if (!bDEF)	// soll Projekt zu einer DLL gelinkt werden
		{						// und kein .DEF-File vorhanden, dann Fehler
			msg ("Error: .DEF-File missing in project!");
			msg ("1 Error(s), 0 Warning(s)");
			bError=TRUE;	// Fehler !!
		}
		else
		{	// bei DLL, zuerst Aufruf des "dlltool"
			_splitpath (file, drive, dir, fname, ext);
			sprintf (strDLLToolLine, "dlltool --def %s.def --output-exp %s.exp --output-lib %s.a --dllname %s.dll", 
							 fname, fname, fname, fname);
			msg (strDLLToolLine);
			if (RunCommand(strDLLToolLine, strTempFile)) 
			{
				// prüfen, ob Fehler
				if (!GetErrors(strTempFile, msg, NULL)) 
					msg("Error: Could not open Logfile!"); 
			}
			else 
				msg ("Error: Could not start process.");		// Fehler im Prozess !!
		}
	}
	if (!bError)	// wenn es keinen Fehler gegeben hat, dann
	{							// Linker aufrufen
		msg(strCommandLine);
		if (RunCommand (strCommandLine, strTempFile))
		{
			if (!GetErrors(strTempFile, msg, NULL))		// auf Fehler prüfen
				msg("Error: Could not open Logfile!"); 
		}
		else 
			msg ("Error: Could not start process.");		// Fehler im Prozess !!
	}
//	if (!DeleteFile(strTempFile))
//		msg ("Error: Could not delete Temp File");
}



//////////////////////////////////////////////////////////////////////////////
//
//  3.4 Verzeichnissse
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK DirectoryDlgProc (HWND hDlg, UINT iMsg, 
// 																			  WPARAM wParam, LPARAM lParam)
//////////////////////////////////////////////////////////////////////////////
// Funktion: FensterProzedur für DirectoryOptions. Bei Änderung eines Eintrags
//					 wird hier eine Aktualisierung der Registry-Einträge gemacht.
//
// Rückgabe: TRUE bei Änderung eines Eintrags
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK DirectoryDlgProc (HWND hDlg, 
																			 UINT iMsg, 
																			 WPARAM wParam, 
																			 LPARAM lParam)
{
	static LPGLOBALDATA lpGlobDat;
	char strDir[_MAX_PATH];
	UINT iLen;
	char strHelpFile[_MAX_PATH];
	char strKeyword[18]="Directory Options";


	switch (iMsg)
	{
		case WM_INITDIALOG:
			// initialisieren des Dialogs -> Directories anzeigen
			lpGlobDat=(LPGLOBALDATA)lParam;
			SetDlgItemText(hDlg, IDC_HOMEDIR, lpGlobDat->strHomeDir); 
			SetDlgItemText(hDlg, IDC_C_INCLUDE_PATH, lpGlobDat->strCIncludeDir); 
			SetDlgItemText(hDlg, IDC_CPLUS_INCLUDE_PATH, lpGlobDat->strCPPIncludeDir); 
			SetDlgItemText(hDlg, IDC_LIBDIR, lpGlobDat->strLibDir); 
			break;

		case WM_COMMAND:
			switch (LOWORD (wParam))
			{
				// OK gedrückt-> Änderungen speichern in Registrierung !!!
				case IDOK: 
					iLen=GetDlgItemText(hDlg, IDC_HOMEDIR, strDir, _MAX_PATH);
					if (!SetRegistryEntry ("Home Directory", strDir, iLen))
						MessageBox (0, "Error in Registry!", "Error", MB_OK);
					else strcpy(lpGlobDat->strHomeDir, strDir);	

					iLen=GetDlgItemText(hDlg, IDC_C_INCLUDE_PATH, strDir, _MAX_PATH);
					if (!SetRegistryEntry ("C Include Directory", strDir, iLen))
						MessageBox (0, "Error in Registry!", "Error", MB_OK);
					else strcpy(lpGlobDat->strCIncludeDir, strDir);
					
					iLen=GetDlgItemText(hDlg, IDC_CPLUS_INCLUDE_PATH, strDir, _MAX_PATH);
					if (!SetRegistryEntry ("CPP Include Directory", strDir, iLen))
						MessageBox (0, "Error in Registry!", "Error", MB_OK);
					else strcpy(lpGlobDat->strCPPIncludeDir, strDir);
					
					iLen=GetDlgItemText(hDlg, IDC_LIBDIR, strDir, _MAX_PATH);
					if (!SetRegistryEntry ("Lib Directory", strDir, iLen))
						MessageBox (0, "Error in Registry!", "Error", MB_OK);
					else strcpy(lpGlobDat->strLibDir, strDir);
					
					// Umgebungsvariablen müssen angepasst werden !!
					SetEnvironmentVariables(lpGlobDat);
					EndDialog (hDlg, 0);
					break;
				// CANCEL gedrückt => keine Änderungen
				case IDCANCEL: 
					EndDialog (hDlg, FALSE);
					break;
				// HELP => Hilfe wird mit der richtigen Seite angezeigt
				case IDHELP_DIR:
					strcpy (strHelpFile, lpGlobDat->powDir);
					strcat (strHelpFile, "\\GNU C++.hlp");
					WinHelp(hDlg, strHelpFile, HELP_KEY, (DWORD) &strKeyword);
					break;
			}
		default: return FALSE;
	}
	return TRUE;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK DirectoryOptions (HANDLE hDat, HWND hwnd)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Gibt ein Fenster aus, in dem die Pfade für den Compiler(HomeDir),
//					 Include Verzeichnis und das Library Verzeichnis eingegeben werden
//					 können.
//
// Rückgabe: TRUE bei Änderung
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK DirectoryOptions (HANDLE hDat, 
																		   HWND hwnd)
{
	LPGLOBALDATA lpGlobDat;
	BOOL ok;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// schicke Daten an Dialogbox zur Initialisierung ...
	ok=(DialogBoxParam (hInst,MAKEINTRESOURCE(IDD_DIR), 
					hwnd, (DLGPROC)DirectoryDlgProc, (LPARAM) lpGlobDat)); 
  GlobalUnlock (hDat);
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
//
//  3.5 Projekte
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK NewProject (HANDLE hDat)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Wird dann aufgerufen, wenn ein neues Projekt erzeugt wird.
//					 Hier werden sämtliche Einstellungen wieder zurückgestellt und 
//					 entsprechend initialisiert.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK NewProject (HANDLE hDat)
{
	LPGLOBALDATA lpGlobDat;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	
	// Compileroptionen initialisieren
	lpGlobDat->iCompilerSwitches = (0 | C_SW_DEBUG | C_SW_NOOPT | C_SW_I386);
	strcpy (lpGlobDat->strStdCompilerSwitches, "");
 	strcpy (lpGlobDat->strCompilerSwitches, "-g -O0 -mcpu=i386 -march=i386 -m386");
	strcpy (lpGlobDat->strExtraCompilerSwitches, "\0");
	
	// Linkeroptionen initialisieren
	lpGlobDat->iLinkerSwitches = (0 | L_SW_CONSOLE);
	strcpy (lpGlobDat->strStdLinkerSwitches, "\0");
	strcpy (lpGlobDat->strLinkerSwitches, "\0");
	strcpy (lpGlobDat->strExtraLinkerSwitches, "\0");
	
	// Directory Optionen aus Registrierung auslesen, falls dies schiefgehen sollte,
	// so werden sie einfach mit "" initialisiert
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths", "Home Directory", lpGlobDat->strHomeDir))
		strcpy(lpGlobDat->strHomeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths", "C Include Directory", lpGlobDat->strCIncludeDir))
		strcpy(lpGlobDat->strCIncludeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths", "CPP Include Directory", lpGlobDat->strCPPIncludeDir))
		strcpy(lpGlobDat->strCPPIncludeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths", "Lib Directory", lpGlobDat->strLibDir))
		strcpy(lpGlobDat->strLibDir,"");
	GlobalUnlock (hDat);
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK WriteOptions (HANDLE hDat, LPSTR prjName, HFILE file)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Speichert den gesamten Globalen Speicherbereich (hDat) in die 
//					 Datei "file" mit (Projektdatei). 
//
// Rückgabe: FALSE bei Schreibfehler, sonst TRUE
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK WriteOptions (HANDLE hDat, 
																	 LPSTR prjName, 
																	 HFILE file)
{
	LPGLOBALDATA lpGlobDat;
	DWORD dwHaveWritten;
	BOOL ok;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	strcpy (lpGlobDat->prjName, prjName);		// aktualisieren des Projektnamens 
	// abspeichern der gesamten globalen Datenstruktur !!
	ok=WriteFile ((HANDLE) file, lpGlobDat, sizeof(GLOBALDATA),
								&dwHaveWritten, NULL);
	GlobalUnlock (hDat);		
	return ok;
}
 


//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK ReadOptions (HANDLE hDat, LPSTR prjName, HFILE file)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Liest aus der Datei "file" sämtliche Daten in die globale 
//					 Datenstruktur hDat ein.
//					 Weiters werden noch aus der Registry die Directories (siehe 
//					 DirectoryOptions) in diesen Speicherblock geladen.
//
// Rückgabe: FALSE bei Lesefehler, sonst TRUE
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK ReadOptions (HANDLE hDat, 
																	LPSTR prjName, 
																	HFILE file)
{
	LPGLOBALDATA lpGlobDat;
	DWORD dwHaveRead;							// Anzahl der gelesenen Bytes
	BOOL ok;											// Rückgabewert
	char strOldPowDir[_MAX_PATH];	// POW Verzeichnis muß gesichert werden, 
	
	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// File ist bereits geöffnet !!
	// altes POW! Verzeichnis sichern
	strcpy (strOldPowDir, lpGlobDat->powDir);
	// Daten einlesen ...
	ok=ReadFile ((HANDLE) file, lpGlobDat, sizeof(GLOBALDATA),
								&dwHaveRead, NULL);
	// altes POW! Verzeichnis rücksichern -> muß gemacht werden, sonst Fehler
	strcpy (lpGlobDat->powDir, strOldPowDir);
  // neues Projekt Verzeichnis ist aktueller könnte eventuell verschoben worden sein !!
	strcpy (lpGlobDat->prjName, prjName);
	// aus Registry Directories nochmals auslesen, da event. Änderung
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","Home Directory", lpGlobDat->strHomeDir))
		strcpy(lpGlobDat->strHomeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","C Include Directory", lpGlobDat->strCIncludeDir))
		strcpy(lpGlobDat->strCIncludeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","CPP Include Directory", lpGlobDat->strCPPIncludeDir))
		strcpy(lpGlobDat->strCPPIncludeDir,"");
	if (!GetRegistryEntry ("SOFTWARE\\Gnu C++\\Paths","Lib Directory", lpGlobDat->strLibDir))
		strcpy(lpGlobDat->strLibDir,"");
	// nach Einlesen Umgebungsvariablen neu setzen
	SetEnvironmentVariables(lpGlobDat);
	GlobalUnlock (hDat);		
	return ok;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK NewProjectName (HANDLE hDat, LPSTR prjName)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Diese Funktion wird aufgerufen, wenn sich der Projektname
//					 ändert. Änderung in hDat (Handle auf globale Speicherstruktur)
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK NewProjectName (HANDLE hDat,
																		 LPSTR prjName)
{
	LPGLOBALDATA lpGlobDat;

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// hier wird lediglich der Projektname im globalen Datenblock aktualisiert
	strcpy (lpGlobDat->prjName, prjName);
	GlobalUnlock (hDat);		
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK ChangeModuleName (HANDLE hData, HWND hwnd, 
//																				FARPROC replace, LPSTR modname,
//																				LPSTR dstname) 
//////////////////////////////////////////////////////////////////////////////
// Funktion: Diese Funktion wird aufgerufen, wenn sich ein Modulname 
//					 ändert. Keine Auswirkung.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK ChangeModuleName (HANDLE hData,
																			 HWND hwnd,
																			 FARPROC replace,
																			 LPSTR modname,
																			 LPSTR dstname) 
{
		// in C bzw. C++ gibt es keine "MODULE" Definitionen wie z.B. unter Oberon,
		// daher ist diese Funktion unnötig
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK GetExecuteable (HANDLE hDat, LPSTR exe)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Liefert in 'exe' den Pfad+Dateinamen jener Datei, welche beim
//					 Linken erzeugt wird.
//
// Rückgabe: TRUE, wenn es sich dabei um eine ausführbare Datei handelt,
//					 FALSE sonst.
//////////////////////////////////////////////////////////////////////////////


EXPORT BOOL CALLBACK GetExecuteable (HANDLE hDat, 
 																		 LPSTR exe)
{
	BOOL bExe = TRUE;	// ausführbare Datei ?
	LPGLOBALDATA lpGlobDat;
  char drive[_MAX_DRIVE], dir[_MAX_DIR],
			 fname[_MAX_FNAME], ext[_MAX_EXT],
			 strExeFile[_MAX_PATH];		// Pfad der ausführbaren Datei

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// Datei befindent sich im Projektverzeichnis
	_splitpath (lpGlobDat->prjName, drive, dir, fname, ext);
	// Wenn Option DLL im Linker Optionen Dialog aktiviert, dann DLL
	if ((lpGlobDat->iLinkerSwitches) == L_SW_DLL) 
	{
		sprintf (strExeFile, "%s%s%s.dll", drive, dir, fname);
		bExe = FALSE;		// keine ausführbare Datei
	}
	else	// sonst EXE-File
		sprintf (strExeFile, "%s%s%s.exe", drive, dir, fname);
	GetShortPathName (strExeFile, strExeFile, _MAX_PATH);
	strcpy (exe, strExeFile);	// muß in "exe" zurückgegeben werden
	GlobalUnlock (hDat);	
	return bExe;
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK GetTarget (HANDLE hDat, LPSTR exe)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Liefert in 'exe' den Pfad+Dateinamen jener Datei, welche beim
//					 Linken erzeugt wird.
//
// Rückgabe: TRUE, wenn es sich dabei um eine ausführbare Datei handelt,
//					 FALSE sonst.
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK GetTarget (HANDLE hDat,
																LPSTR exe)
{
	BOOL bExe = TRUE;	// ausführbare Datei ?
	LPGLOBALDATA lpGlobDat;
  char drive[_MAX_DRIVE], dir[_MAX_DIR],
			 fname[_MAX_FNAME], ext[_MAX_EXT],
			 strExeFile[_MAX_PATH];		// Pfad der ausführbaren Datei

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	// Datei befindent sich im Projektverzeichnis
	_splitpath (lpGlobDat->prjName, drive, dir, fname, ext);
	// Wenn Option DLL im Linker Optionen Dialog aktiviert, dann DLL
	if ((lpGlobDat->iLinkerSwitches) == L_SW_DLL) 
	{
		sprintf (strExeFile, "%s%s%s.dll", drive, dir, fname);
		bExe = FALSE;		// keine ausführbare Datei
	}
	else	// sonst EXE-File
		sprintf (strExeFile, "%s%s%s.exe", drive, dir, fname);
	GetShortPathName (strExeFile, strExeFile, _MAX_PATH);
	strcpy (exe, strExeFile);		// muß in "exe" zurückgegeben werden
	GlobalUnlock (hDat);		
	return bExe;
}



//////////////////////////////////////////////////////////////////////////////
//
//  3.6 Hilfe
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// EXPORT BOOL CALLBACK HelpCompiler (HANDLE hDat, HWND hwnd, LPSTR powDir, 
//																	  WORD wCmd, DWORD dwData)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Ruft das Compiler-Helpfile auf (Hier: GNU C++.hlp)
//
// Rückgabe: TRUE bei Erfolg, FALSE bei Fehler
//////////////////////////////////////////////////////////////////////////////

EXPORT BOOL CALLBACK HelpCompiler (HANDLE hDat, 
																	 HWND hwnd, 
																	 LPSTR powDir, 
																	 WORD wCmd,
																	 DWORD dwData)
{
	LPGLOBALDATA lpGlobDat;
	char strHelpFile[_MAX_PATH];		// Pfad zur Hilfedatei

	lpGlobDat = (LPGLOBALDATA)GlobalLock (hDat);
	strcpy(strHelpFile, powDir);	// Hilfedatei muß im POW! Verzeichnis stehen
  if (strHelpFile[strlen(strHelpFile)-1] == '\\')	// "\" hinten oder nicht?
		strcat (strHelpFile, "GNU C++.hlp");					// anhängen des Dateinamens
	else
		strcat (strHelpFile, "\\GNU C++.hlp");				// anhängen des Dateinamens
	GlobalUnlock (hDat);		
	return WinHelp (hwnd, strHelpFile, wCmd, dwData);	// WinHelp aufrufen
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK GetHelpFile (HANDLE hData, LPSTR name)
///////////////////////////////////////////////////////////////////////////
// Funktion: soweit bekannt keine
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK GetHelpFile (HANDLE hData,
																	LPSTR name)
{
	// diese Funktion wird nicht mehr benötigt
}



//////////////////////////////////////////////////////////////////////////////
//
//  3.7 Editor
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK EditorSyntax (HANDLE hDat, LPLONG caseSensitive, 
//																		FARPROC enumKeys)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Übergibt an Pow! sämtliche Schlüsselwörter zur Einfärbung des 
//					 Sources für den Editor. C/C++ ist Case-sensitiv.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK EditorSyntax (HANDLE hDat, 
																	 LPLONG caseSensitive, 
																	 FARPROC enumKeys)
{
	*caseSensitive=1;		// C und C++ sind Case-Sensitive Sprachen
	(*(enumKey*)enumKeys)("break");			(*(enumKey*)enumKeys)("case");
	(*(enumKey*)enumKeys)("char");			(*(enumKey*)enumKeys)("class");
	(*(enumKey*)enumKeys)("const");			(*(enumKey*)enumKeys)("continue");	
	(*(enumKey*)enumKeys)("default");		(*(enumKey*)enumKeys)("delete");
	(*(enumKey*)enumKeys)("do");				(*(enumKey*)enumKeys)("double");
	(*(enumKey*)enumKeys)("else");			(*(enumKey*)enumKeys)("enum");
	(*(enumKey*)enumKeys)("far");				(*(enumKey*)enumKeys)("float");
	(*(enumKey*)enumKeys)("for");				(*(enumKey*)enumKeys)("friend");
	(*(enumKey*)enumKeys)("goto");			(*(enumKey*)enumKeys)("huge");
	(*(enumKey*)enumKeys)("if");				(*(enumKey*)enumKeys)("int");
	(*(enumKey*)enumKeys)("interrupt");	(*(enumKey*)enumKeys)("long");
	(*(enumKey*)enumKeys)("near");			(*(enumKey*)enumKeys)("new");
	(*(enumKey*)enumKeys)("operator");	(*(enumKey*)enumKeys)("pascal");
	(*(enumKey*)enumKeys)("private");		(*(enumKey*)enumKeys)("protected");
	(*(enumKey*)enumKeys)("public");		(*(enumKey*)enumKeys)("register");
	(*(enumKey*)enumKeys)("return");		(*(enumKey*)enumKeys)("short");
	(*(enumKey*)enumKeys)("signed");		(*(enumKey*)enumKeys)("static");
	(*(enumKey*)enumKeys)("struct");		(*(enumKey*)enumKeys)("switch");
	(*(enumKey*)enumKeys)("template");	(*(enumKey*)enumKeys)("this");
	(*(enumKey*)enumKeys)("typedef");		(*(enumKey*)enumKeys)("union");
	(*(enumKey*)enumKeys)("unsigned");	(*(enumKey*)enumKeys)("virtual");
	(*(enumKey*)enumKeys)("void");			(*(enumKey*)enumKeys)("while");
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK EditorComment (HANDLE hDat, LPLONG nested, 
//																		 LPSTR commentOn, LPSTR commentoff)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Die Funktion EditorComment liefert für den Pow! Editor die 
//					 Zeichen "/* */" und "//" welche als Kommentare unter C bzw. C++
//					 verwendet werden. Es werden keine geschachtelten Kommentare 
//					 (nested=0) erlaubt.
//
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK EditorComment (HANDLE hDat, 
																		LPLONG nested, 
																		LPSTR commentOn, 
																		LPSTR commentoff)
{
	strcpy (commentOn, "/* //");
	strcpy (commentoff, "*/");
	*nested = 0;		// Geschachtelte Kommentare sind nicht erlaubt!
}



//////////////////////////////////////////////////////////////////////////////
// EXPORT void CALLBACK GetExtensions (HANDLE hDat, LPEXT far *srcExt, LPINT 
//																		 srcN, LPEXT far *addExt, LPINT addN)
//////////////////////////////////////////////////////////////////////////////
// Funktion: Diese Funktion ist zuständig für die Erweiterungen, die im File-
//					 Open und im Project Dialog angezeigt werden - diese werden hier
//					 initialisiert und an Pow! zurück übergeben.
//					 
// Rückgabe: -
//////////////////////////////////////////////////////////////////////////////

EXPORT void CALLBACK GetExtensions (HANDLE hDat, 
			  														LPEXT far *srcExt, 
																	  LPINT srcN,
																		LPEXT far *addExt, 
																		LPINT addN)
{
	*srcExt= (LPEXT) &SrcExt;
	*addExt= (LPEXT) &AddExt;
	*srcN= 5; 
	*addN= 6;
}



//////////////////////////////////////////////////////////////////////////////
// int WINAPI DllMain (HINSTANCE hDllInst, DWORD fdwReason, LPVOID lpReserved)
//////////////////////////////////////////////////////////////////////////////
// Funktion: DLL-Einstiegspunkt, hier wird das Instanz-Handle gespeichert
//					 
// Rückgabe: TRUE
//////////////////////////////////////////////////////////////////////////////

BOOL WINAPI DllEntryPoint(HINSTANCE hDllInst,
                          DWORD     fdwReason,
 				                  LPVOID    lpReserved)
{
  hInst=hDllInst;		// Instanz Handle sichern
  if (fdwReason == DLL_PROCESS_ATTACH) { 
  } else 
	if (fdwReason == DLL_PROCESS_DETACH) { 
  }
  return TRUE;
}

