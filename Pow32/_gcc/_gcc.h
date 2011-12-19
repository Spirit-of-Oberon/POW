#ifndef _GNU_CPP
#define _GNU_CPP

#define EXPORT extern __declspec (dllexport)

// Compiler Switches 
#define C_SW_SUPPORTANSI 		1	// Support all ANSI C programs
#define C_SW_PROFILE				2	// Generate profile information
#define C_SW_DEBUG					4	// Create Debug information
#define C_SW_SYNTAX					8	// Check only syntac errors
#define C_SW_WARNANSI		   16	// Warn, if not standard ANSI-C
#define C_SW_ERRORANSI		 32	// Error, if not standard ANSI-C
#define C_SW_ALLERRORS		 64	// Make all Warnings into Errors
#define C_SW_INHIBITWARN	128	// Inhibit all warning message
#define C_SW_NOOPT			  256	// No Optimization
#define C_SW_OPT1					512	// Optimize Level 1
#define C_SW_OPT2				 1024	// Optimize Level 2
#define C_SW_OPT3				 2048	// Optimize Level 3
#define C_SW_OPTSIZE		 4096	// Optimize for Size
#define C_SW_I386				 8192	// Generate Code for i386
#define C_SW_I486				16384	// Generate Code for i486
#define C_SW_PENTIUM		32768	// Generate Code for Pentium
#define C_SW_PENTIUMPRO	65536	// Generate Code for Pentium Pro

// Linker Switches
#define L_SW_CONSOLE				1	// Console Application
#define L_SW_WINDOWS				2	// Windows Application
#define L_SW_DLL						4	// Dynamic Link Library

#define MAX_SW_LENGTH		  512	// maximale Länge der Benutzer-Switches (Compiler/Linker)
#define MAXPATHLENGTH			256 // Vorgabe von POW! für Pfadlänge 
#define	MAX_EDITOR_LINE	 2048 // maximale Länge einer Zeile in POW!

// wird benötigt für angepaßte Erweiterungen in POW!
typedef struct	
{
	char ext[MAXPATHLENGTH], doc[256];
} FileExt[], EXT;
typedef EXT far *LPEXT;


// GLOBALE DATENSTRUKTUR
// Diese Struktur wird mit den Projektdaten mitgespeichert.
typedef struct{
	char compilerName[_MAX_FNAME+_MAX_EXT];				// Compiler-Interface DLL Name
	DWORD ddeInstId;															// DDE Instance Handle für POW
	char powDir[_MAX_PATH];												// Pfad zur Pow! - Applikation
	char prjName[_MAX_PATH];											// Projekt Name incl. Pfad
	int iCompilerSwitches;												// Compilerswitches ausgewählt im Options-Dialog
	char strCompilerSwitches[MAX_SW_LENGTH];			// Compilerswitches als String, für GCC
	char strStdCompilerSwitches[MAX_SW_LENGTH];		// Compilerswitches als String,
	char strExtraCompilerSwitches[MAX_SW_LENGTH];	// Benutzerdefierte Compiler-Switches
	int iLinkerSwitches;													// Linkerswitches ausgewählt im Options-Dialog
	char strLinkerSwitches[MAX_SW_LENGTH];				// Linkerswitches als String, für GCC
	char strStdLinkerSwitches[MAX_SW_LENGTH];			// Linkerswitches als String, für GCC
	char strExtraLinkerSwitches[MAX_SW_LENGTH];		// Benutzerdefierte Switches
	char strHomeDir[_MAX_PATH];										// Home Verzeichnis Gnu-C++
	char strCIncludeDir[_MAX_PATH];								// C-Include Verzeichnis Gnu-C++
	char strCPPIncludeDir[_MAX_PATH];							// CPP-Include Verzeichnis Gnu-C++
	char strLibDir[_MAX_PATH];										// Lib Verzeichnis Gnu-C++
} GLOBALDATA;
typedef GLOBALDATA far *LPGLOBALDATA;

// Funktionen, die aufgerufen werden müssen (aus POW!)
typedef void FAR PASCAL msg (LPSTR);
typedef void FAR PASCAL err (int, int, int, BOOL, LPSTR);
typedef long FAR PASCAL first (HWND, LPSTR, long);
typedef long FAR PASCAL next (HWND, LPSTR, long);
typedef int  FAR PASCAL fileOpen (LPSTR);
typedef long FAR PASCAL fileRead (int, LPSTR, long);
typedef void FAR PASCAL fileClose (int);
typedef void FAR PASCAL depends (LPSTR);
typedef void FAR PASCAL enumKey (LPSTR);

#endif