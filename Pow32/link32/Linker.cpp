/**************************************************************************************************/
/*** Die Datei Linker.cpp beinhaltet die Schnittstelle und das Ablaufdiagramm, wie es im 						 ***/
/*** '4.0 Konkretes Vorgehensmodell' beschrieben wird. Desweiteren befinden sich alle FreeC...  ***/
/*** Funktionen hier, welche dieeinzelnen Destruktoren der implentierten Klassen zum Frei-      ***/
/*** geben des benötigten Speichers aufrufen.																																																			***/
/**************************************************************************************************/


#ifndef __LINKER_H__
#include "Linker.h"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#include <iostream.h>
#include <malloc.h>

#ifndef __OBJ2EXE_HPP__
#include "Obj2Exe.hpp"
#endif

#ifndef __OBJFILE_HPP__
#include "ObjFile.hpp"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

#ifndef __DEEBUG_HPP__
#include "Debug.hpp"
#endif

// Prototypen der klassenunabhängigen Funktionen
void FreeCObj2Exe(CObj2Exe *aCObj2Exe);


void MessageOut (FARPROC,char*);
DWORD	CalcTimeDateStamp();
int LinkProgram(LPSTR[], LPSTR[] , LPSTR, LPSTR, LPSTR, LPSTR[], WORD, BOOL, BOOL, BOOL, FARPROC, DWORD, DWORD);
void TestHeap(void);

void WriteMessageToPow(WORD , char*, char*);

typedef void far PASCAL MsgPrc (LPSTR msg);
FARPROC ErrMsgPrc;

BYTE chrBufCC[0x200];
BYTE chrBuf00[0x200];

char *logFilNam= "C:\\LINKER.LOG";
FILE *logFil; 
int		logOn;   

BOOL incDebInf;
BOOL isExeFil;
BOOL	oneLibLst;
BOOL	libFilInMem;
BOOL	heapMsg;
BOOL	shwDRCMsg;


/**************************************************************************************************/
/*** Schnittstelle zu POW! (Implementierung des konkreten Vorgehensmodells für den Linkablauf.  ***/
/**************************************************************************************************/

int LinkProgram(LPSTR oFilLst[], LPSTR lFilLst[], LPSTR rFil, LPSTR eFil, LPSTR stUpSym,
                LPSTR eFncLst[], WORD sSys, BOOL bExeFil, BOOL bWinNtFil, DWORD iDbgInf, FARPROC msg, 
																DWORD basAdr, DWORD stackSize)
{																	
	CObj2Exe	*newExe;
	UINT					startTime, endTime, firstTime;
	BOOL					lnkOK= TRUE;
	
	memset(chrBufCC, 0xCC, 0x200);
	memset(chrBuf00, 0x00, 0x200);

	logOn= FALSE;
	oneLibLst= TRUE;
	libFilInMem= FALSE;
	heapMsg= FALSE;
	shwDRCMsg= FALSE;
	ErrMsgPrc= msg;

	if (logOn)
	{
		logFil = fopen(logFilNam,"w");
		fclose(logFil);
	}

	newExe= new CObj2Exe();
	newExe-> objFilLst= oFilLst;

 newExe-> libFilLst= lFilLst;
 newExe-> resFil= rFil;
 newExe-> exeFil= eFil;
 newExe-> startUpSym= stUpSym;
 newExe-> expFncLst= eFncLst;
 newExe-> bldExeFil= bExeFil;
 newExe-> incDbgInf= iDbgInf;
 newExe-> bldWinNtFil= bWinNtFil;
 newExe-> subSystem= sSys;
	newExe-> basAdr= basAdr;
 newExe-> stackSize= stackSize;

	WriteMessageToPow(INF_MSG_INI, NULL, NULL);
	startTime= GetTickCount();
	lnkOK= newExe-> InitLinker();
	endTime= GetTickCount();
 firstTime= startTime;                          
 printf("\nInitialisieren: % 7.3f\n", (endTime - startTime) * 0.001);
 TestHeap();
                                
	if (lnkOK)
	{
		WriteMessageToPow(INF_MSG_RES_SYM, NULL, NULL);
		startTime= endTime;
		lnkOK= newExe-> ResolveSymbols();
		endTime= GetTickCount();
		printf("\nSymbole auflösen: % 7.3f\n", (endTime - startTime) * 0.001);
		TestHeap();
	}
	
	if (lnkOK)
	{
		WriteMessageToPow(INF_MSG_FRE_LIB, NULL, NULL);
		startTime= endTime;
		lnkOK= newExe-> FreeLibFiles();
	 endTime= GetTickCount();
		printf("\nFreigeben der Libfiles: % 7.3f\n", (endTime - startTime) * 0.001);
		TestHeap();
	}

	if (lnkOK) 
	{
		WriteMessageToPow(INF_MSG_CON_SEC_FRG, NULL, NULL);
		startTime= endTime;
		lnkOK= newExe-> ConnectSectionFragments();
		endTime= GetTickCount();
		printf("\nZusammensetzen der Sectionfragmente: % 7.3f\n", (endTime - startTime) * 0.001);
		TestHeap();
	}
 
	if (lnkOK)
	{
		WriteMessageToPow(INF_MSG_RES_REL, NULL, NULL);
		startTime= endTime;
		lnkOK= newExe-> ResolveRelocations();
		endTime= GetTickCount();
		printf("\nRelocationen auflösen: % 7.3f\n", (endTime - startTime) * 0.001);
		TestHeap();
	}
 
	if (lnkOK)
	{
		if (iDbgInf)
		{	
			WriteMessageToPow(INF_MSG_BLD_DBG, NULL, NULL);
			startTime= endTime;
			lnkOK= newExe-> BuildDebugInformation();
			endTime= GetTickCount();
 		printf("\nDebuginformation erstellen: % 7.3f\n", (endTime - startTime) * 0.001);
		}
		TestHeap();
	}

	if (lnkOK)
	{ 
		WriteMessageToPow(INF_MSG_WRT_PE, NULL, NULL);
		startTime= endTime;
		lnkOK= newExe-> BuildExeFile();
		endTime= GetTickCount();
		if (lnkOK)
			printf("\nExefile erstellen: % 7.3f\n", (endTime - startTime) * 0.001);
		TestHeap();
	}

	WriteMessageToPow(INF_MSG_FRE_MEM, NULL, NULL); 
	startTime= endTime;
	FreeCObj2Exe(newExe);
	delete newExe;
	endTime= GetTickCount();
	printf("\nSpeicher freigeben: % 7.3f\n", (endTime - startTime) * 0.001);
	TestHeap();
	endTime= GetTickCount();
	printf("\nGesamtlinkzeit: % 7.3f\n", (endTime - firstTime) * 0.001);

	return lnkOK;
}						 

/*************************************************/
/*** Rückgabe einer beliebigen Meldung an POW! ***/
/*************************************************/

void MessageOut (FARPROC msg,char *error)
{
  if (msg) (*(MsgPrc *)msg)((LPSTR)error);
}

/************************************************************/
/*** Ausgabe der Fehlermeldungen und Warnings des Linkers ***/
/************************************************************/

void WriteMessageToPow(WORD msgNr, char *str1, char *str2)
{
	char msgBuf[256];
	BOOL	shwMsg= TRUE;

	memset(msgBuf, 0x00, 256);

	switch(msgNr)		// Ausschalten von Linkermeldungen
	{
		/*********************************************/
		/*** Meldungen während des Programmablaufs ***/
		/*********************************************/

		//case INF_MSG_INI:											// Intilisierungsmeldung
		//case INF_MSG_RES_SYM:							// Symbole auflösen
		//case INF_MSG_FRE_LIB:							// Freigeben der Libraries
		//case INF_MSG_CON_SEC_FRG:			// Zusammensetzen der Sektionsfragmente
		//case INF_MSG_RES_REL:							// Auflösen der Relokationen
		//case INF_MSG_BLD_DBG:							// Erstellen der Debugsektion
		//case INF_MSG_WRT_PE:								// Schreiben der PE-Datei
		//case INF_MSG_FRE_MEM:							// Freigeben des Speichers

		/********************************************************************/
		/*** Meldungen, die keiner bestimmten Linkphase zugeordnet werden ***/
		/********************************************************************/

		case INF_MSG_FIL_OPE_SUC:			// Erfolgreiches Öffnen einer Datei

		/*************************************************/
		/*** Meldungen beim Initialisieren des Linkers ***/
		/*************************************************/

		/*******************************************/
		/*** Meldungen beim Auflösen der Symbole ***/	
		/*******************************************/
		
		//	case	WRN_MSGS_NO_SYM:						// Symbol wurde durch andere Anzahl von _ aufgelöst
		//	case	WRN_MSGS_UNK_DEB_SEC:	// Unbekannte Debugsektion (nicht $S, $T oder $F)
		//	case	INF_MSGS_UNI_VAR:					// Uninitialisierte Variable vorhanden, mögliche Fehlerquelle

		/********************************************************/
		/*** Meldungen beim Analysieren der Objektdateien				 ***/
		/********************************************************/

		//case WRN_MSGIS_DRC:									shwMsg= shwDRCMsg;

		/***********************************************************/
		/*** Meldungen beim Zusammensetzen der Sektionsfragmente ***/
		/***********************************************************/

		/************************************************/
		/*** Meldungen beim Auflösen der Relokationen ***/
		/************************************************/

		//case WRN_MSGR_NO_DLL_DBG_INF:			// Bei einem DLL-Entry konnte die Debuginformation nicht gefunden werden
		//case WRN_MSGR_SMA_FRG:										// Falsches Alignment in einem Sektionsfragment

		/************************************************************/
		/*** Meldungen beim beim Erstellen der Debuginformationen ***/
		/************************************************************/

		//case WRN_MSGD_CHG_VC5_TO_CV4:	// Änderung CV5 zu CV4
		//case WRN_MSGD_CHG_VC4_TO_CV5:	// Änderung CV4 zu CV5

		//case WRN_MSGD_WRO_ALN:									// Fehler im Alignment eines CV-Moduls-> fehlerhafte Debuginformation
		case WRN_MSGD_NO_SYM_IND:						// Ein Symbolindex konnte nicht zugeordnet werden	
		case WRN_MSGD_NO_TYP_IND:						// Ein Symobltyp konnte nicht zugeordnet werden
		//case WRN_MSGD_WRO_CVS_FOR:					// Unbekannte CV-Format (nicht CV4 oder CV5)
		case WRN_MSGD_CV129_NO_SYM:				// Die Debuginformationen eines Symobls in 0x129 konnten nicht gefunden werden
		
		/*********************************************/
		/*** Meldungen beim Schreiben der PE-Datei ***/
		/*********************************************/

		/**************************/
		/*** Sonstige Meldungen ***/
		/**************************/

		//case MSG_NUL:	      // Ausgabe einer beliebigen Meldung


		/******************************/
		/*** Heap Kontrollmeldungen ***/
		/******************************/
		
		case MSG_HEAP_BADBEGIN:		// Ungültiger Heapanfang
		case MSG_HEAP_BADNODE:			// Ungültiger Knoten
		case	MSG_HEAP_BADPTR:				//	Ungültiger Heappointer
		case	MSG_HEAP_EMPTY:					// Leerer Heap
		case	MSG_HEAP_OK:								// Korrekter Heap
		case	MSG_HEAP_END:							// Ungültiges Heapende
		case	MSG_HEAP_UNKNOWN:			// Unbekannte Heapmeldung

				shwMsg= FALSE;
			break;

		default: ;
	}



	switch(msgNr)
	{
		/****************************************/
		/*** Es wird keine Meldung ausgegeben ***/
		/****************************************/

		case NO_MSG: break;
		
		/*********************************************/
		/*** Meldungen während des Programmablaufs ***/
		/*********************************************/

		case INF_MSG_INI:									strcpy(msgBuf, "Linker Message: Init Linker!"); break;
		case INF_MSG_RES_SYM:					strcpy(msgBuf, "Linker Message: Resolve Symbols!"); break;
		case INF_MSG_FRE_LIB:					strcpy(msgBuf, "Linker Message: Free Libraries!"); break;
		case INF_MSG_CON_SEC_FRG:	strcpy(msgBuf, "Linker Message: Connect Section Fragments!"); break;
		case INF_MSG_RES_REL:					strcpy(msgBuf, "Linker Message: Resolve Relocations!"); break;
		case INF_MSG_BLD_DBG:					strcpy(msgBuf, "Linker Message: Build Debuginformation!"); break;
		case INF_MSG_WRT_PE:						strcpy(msgBuf, "Linker Message: Write PE-File!"); break;
		case INF_MSG_FRE_MEM:					strcpy(msgBuf, "Linker Message: Free Memory!"); break;

		/********************************************************************/
		/*** Meldungen, die keiner bestimmten Linkphase zugeordnet werden ***/
		/********************************************************************/

		case INF_MSG_FIL_OPE_SUC:	wsprintf(msgBuf, "Linker Message: File %s was opened successfully!", str1);	break;

		/*************************************************/
		/*** Meldungen beim Initialisieren des Linkers ***/
		/*************************************************/

		case ERR_MSGI_NO_LIB:					strcpy(msgBuf,   "*** Linker Error ***: No Library in Project!"); break;
		case	ERR_MSGI_NO_OBJ:					strcpy(msgBuf,   "*** Linker Error ***: No Object File in Project!"); break;
		case ERR_MSGI_NO_STA_SYM:	wsprintf(msgBuf, "*** Linker Error ***: Startup Symbol %s not Found!", str1);	break;
		case	ERR_MSGI_NO_EXP_SYM:	wsprintf(msgBuf, "*** Linker Error ***: Exported Symbol %s not Found!", str1);	break;
		
		case ERR_MSGI_OPN_LIB:				wsprintf(msgBuf, "*** Linker Error ***: Library %s not found!", str1);	break;
		case ERR_MSGI_OPN_OBJ:				wsprintf(msgBuf, "*** Linker Error ***: Object File %s not found!", str1);	break;


		/*******************************************/
		/*** Meldungen beim Auflösen der Symbole ***/	
		/*******************************************/
		
		case	ERR_MSGS_NO_SYM:						wsprintf(msgBuf, "*** Linker Error ***: Symbol %s in %s not resolved!", str1, str2);	break;
		case	ERR_MSGS_NO_DLL_SYM:		wsprintf(msgBuf, "*** Linker Error ***: DLL Symbol %s not resolved!", str1);	break;

		case	WRN_MSGS_NO_SYM:						wsprintf(msgBuf, "*** Linker Warning ***: Symbol %s  was resolved by %s!", str1, str2);	break;
		case	WRN_MSGS_UNK_DEB_SEC:	wsprintf(msgBuf, "*** Linker Warning ***: Unknown Debugsection %s occured!", str1);	break;
						
		case	INF_MSGS_UNI_VAR:					wsprintf(msgBuf, "Linker Message: Unitialized Variable %s found!", str1);	break;

		/********************************************************/
		/*** Meldungen beim Analysieren der Objektdateien				 ***/
		/********************************************************/

		case ERR_MSGIS_NEW_SEC_TYP: wsprintf(msgBuf, "*** Linker Error: New section type [%s] found in %s!", str1, str2); break;
		case ERR_MSGIS_WRG_MAC:					wsprintf(msgBuf, "*** Linker Error: Wrong machine type in COFF-file %s!", str1); break;
		case ERR_MSGIS_NO_IMP_SYM:		wsprintf(msgBuf, "*** Linker Error: DLL Importsymbol in %s not found!", str1); break;
		
		
		case WRN_MSGIS_DRC:									shwMsg= shwDRCMsg;
																														wsprintf(msgBuf, "Linker Message: .DRECTVE Sektion in %s ignored!", str1); break;


		/***********************************************************/
		/*** Meldungen beim Zusammensetzen der Sektionsfragmente ***/
		/***********************************************************/

		case ERR_MSGC_OPN_RES:						wsprintf(msgBuf, "*** Linker Error ***: Resource File %s not found!", str1);	break;
		case ERR_MSGC_NO_WIN32_RES:	wsprintf(msgBuf, "*** Linker Error ***: %s isn't a Win32 Resource File!", str1);	break;
		
		case BLD_MSGC_BLD_IMP_LIB	:	wsprintf(msgBuf, "--- Build Message --: DLL Import Library %s was created!", str1);	break;		
		case BLD_MSGC_BLD_EXP_FIL	:	wsprintf(msgBuf, "--- Build Message --: DLL Export File %s was created!", str1);	break;		
				 
		case WRN_MSGC_BLD_IMP_LIB:		wsprintf(msgBuf, "*** Linker Warning ***: Unable to create DLL Import Library %s!", str1);	break;		
		case WRN_MSGC_BLD_EXP_FIL:		wsprintf(msgBuf, "*** Linker Warning ***: Unable to create DLL Export File %s!", str1);	break;		

		case	WRN_MSGC_NO_IMP_DES:			wsprintf(msgBuf, "Unable to write Import Descriptor %s in .edata Section!", str1);	break;	


		/************************************************/
		/*** Meldungen beim Auflösen der Relokationen ***/
		/************************************************/

		case ERR_MSGR_NO_SEC_FRG:					wsprintf(msgBuf, "Beim Symbol %s fehlt der Zeiger auf actFrgEnt", str1);	break;
		case ERR_MSGR_DIR32:										wsprintf(msgBuf, "DIR32 address - %s - couldn't be resolved", str1);	break;
		case ERR_MSGR_DIR32NB:								wsprintf(msgBuf, "DIR32NB address - %s - couldn't be resolved", str1);	break;
		case ERR_MSGR_SECTION:								wsprintf(msgBuf, "SECTION address - %s - konnte nicht aufgelöst werden", str1);	break;
		case ERR_MSGR_SECREL:									wsprintf(msgBuf, "SECREL address - %s - couldn't be resolved", str1);	break;
		case ERR_MSGR_REL32:										wsprintf(msgBuf, "REL32 address - %s - couldn't be resolved", str1);	break;
		case ERR_MSGR_NEW_REL:								wsprintf(msgBuf, "*** Linker Error: Unknown relocation type (0x%s) was found!", str1);	break;
		
		case WRN_MSGR_NO_DLL_DBG_INF:	wsprintf(msgBuf, "*** Linker Warning: No Debuginformation for Dll-Entry %s from DLL %s", str1, str2);	break;
		
		case WRN_MSGR_SMA_FRG:				strcpy(msgBuf, "*** Linker Warning ***: Section Fragment to small!"); break;
		case WRN_MSGR_SHIT:		    		strcpy(msgBuf, "*** Linker Warning ***: could not calc offset of symbol"); break;

		/************************************************************/
		/*** Meldungen beim beim Erstellen der Debuginformationen ***/
		/************************************************************/

		case WRN_MSGD_CHG_VC5_TO_CV4:	strcpy(msgBuf, "*** Linker Warning ***: CV5 Debuginformation ignored, target is CV4!"); break;
		case WRN_MSGD_CHG_VC4_TO_CV5:	strcpy(msgBuf, "*** Linker Warning ***: CV4 Debuginformation changed to target CV5!"); break;

		case WRN_MSGD_WRO_ALN							:	wsprintf(msgBuf, "*** Linker Warning ***: Wrong Alignment in CV-Module %s, incorrect Debuginformtion possible", str1); break;
		case WRN_MSGD_NO_SYM_IND				:	wsprintf(msgBuf, "Symbol Index %s in Objectfile %s couldn't be resolved", str1, str2);	break;
		case WRN_MSGD_NO_TYP_IND				:	wsprintf(msgBuf, "Type Index %s in Objectfile %s couldn't be resolved", str1, str2);	break;
		case WRN_MSGD_WRO_CVS_FOR			:	wsprintf(msgBuf, "Objectfile Section .debug$S in %s includes unknown Debugformat", str1);	break;	
		case WRN_MSGD_CV129_NO_SYM		:	wsprintf(msgBuf, "Debugsymbol %s in CV-Modul 0x129 couldn't be resolved", str1);	break;	
		
		/*********************************************/
		/*** Meldungen beim Schreiben der PE-Datei ***/
		/*********************************************/

		case ERR_MSGB_OPN_EXE:		wsprintf(msgBuf, "The file %s couldn't be written", str1);	break;
			
		/**************************/
		/*** Sonstige Meldungen ***/
		/**************************/

		case MSG_NUL:	strcpy(msgBuf, str1); break;


		/******************************/
		/*** Heap Kontrollmeldungen ***/
		/******************************/
		
		case MSG_HEAP_BADBEGIN:	strcpy(msgBuf, "Heap Message: Bad Begin!"); break;
		case MSG_HEAP_BADNODE:		strcpy(msgBuf, "Heap Message: Bad Node!"); break;
		case	MSG_HEAP_BADPTR:			strcpy(msgBuf, "Heap Message: Bad Pointer!"); break;
		case	MSG_HEAP_EMPTY:				strcpy(msgBuf, "Heap Message: Heap Emtpy!"); break;
		case	MSG_HEAP_OK:							strcpy(msgBuf, "Heap Message: Heap Ok!"); break;
		case	MSG_HEAP_END:						strcpy(msgBuf, "Heap Message: Heap End!"); break;
		case	MSG_HEAP_UNKNOWN:		strcpy(msgBuf, "Heap Message: Unknown Message!"); break;

		
		/*********************************/
		/*** Unbekannte Meldungsnummer ***/
		/*********************************/

		default:	strcpy(msgBuf, "Linker Message: Unknown Message Id!");
	}

	if (shwMsg)
	{
		if (ErrMsgPrc)
			MessageOut(ErrMsgPrc, msgBuf);
		else
			printf("\n%s", msgBuf);
	}
}


/**************************************************************************************************/
/*** Berechnen des TimeDataStamps; wird in den verschiedenen Dateiheadern benötigt.													***/
/**************************************************************************************************/

DWORD	CalcTimeDateStamp()
{
	WORD	monDays[12]=	{31,28,31,30,31,30,31,31,30,31,30,31};
	CTime	actTim= CTime::GetCurrentTime();
	DWORD	days= 0x0;
	DWORD	secs= 0x0;

	WORD	mon;
	WORD year;
	WORD	startYear= 1970;

	year= (WORD )(actTim.GetYear() - 1);

	while (startYear <= year)
	{
		days+= 365;
		if (year - 100 * (year/100))
			if (!(year - 4 * (year/4)))	
				days++;		
		year--;
	}
		
	mon= (WORD )(actTim.GetMonth() - 1);
		
	while (mon)
		days+= monDays[--mon];
	
	if (actTim.GetMonth() > 2)
	{
		year= (WORD )actTim.GetYear();	
		if (year - 100 * (year/100))
			if (!(year - 4 * (year/4)))	
				days++;		
	}			

	days+= actTim.GetDay() - 1;
	secs= days * 24 * 60 * 60;
	secs+= actTim.GetHour() * 60 * 60 + actTim.GetMinute() * 60 + actTim.GetSecond() - 60 * 60;

	return secs;	
}

/**************************************************************************************************/
/*** Hilfsprogramm zum Überprüfen von Heapfehlern während des Linkens.																										***/
/**************************************************************************************************/

void TestHeap(void)
{
	WORD msgId;
	char *outStr;
	
	switch (_heapchk())
	{
		case _HEAPBADBEGIN: outStr= "HEAPBADBEGIN";	msgId= MSG_HEAP_BADBEGIN;	break;										
		case _HEAPBADNODE	: outStr= "HEAPBADNODE"; msgId= MSG_HEAP_BADNODE;	break;										
		case _HEAPBADPTR		: outStr= "HEAPBADPTR";	msgId= MSG_HEAP_BADPTR; break;										
		case _HEAPEMPTY			: outStr= "HEAPEMPTY";	msgId= MSG_HEAP_EMPTY;	break;										
		case _HEAPOK						: outStr= "HEAPOK"; msgId= MSG_HEAP_OK;	break;										
		case _HEAPEND					: outStr= "HEAPEND";	msgId= MSG_HEAP_END;	break;										
		default											:	outStr= "UNKNOWNMESSAGE";	msgId= MSG_HEAP_UNKNOWN;
	}
	if (heapMsg)
		WriteMessageToPow(msgId, NULL, NULL);
}	

/**************************************************************************************************/
/*** Aufruf der verschiedenen Destruktoren der einzelnen Klassen. Dies wurde wegen Problemen mit***/
/*** der Speicherverwaltung beim direkten Aufruf der Destruktoren in VC++ V2.0 so implementiert ***/
/*** und für spätere VC++ Versionen beibehalten.																																																***/
/**************************************************************************************************/

void FreeCObj2Exe(CObj2Exe *aCObj2Exe)
{
	aCObj2Exe-> ~CObj2Exe();
}

/**************************************************************************************************/
void FreeCSection(CSection *aCSection)
{
	aCSection-> ~CSection();
}

/**************************************************************************************************/

void FreeCObjFileSection(CObjFileSection *aCObjFileSection)
{
	aCObjFileSection-> ~CObjFileSection();
}

/**************************************************************************************************/

void FreeCExeFileTextSection(CExeFileTextSection *aCExeFileTextSection)
{
	aCExeFileTextSection-> ~CExeFileTextSection();
}

/**************************************************************************************************/

void FreeCExeFileBssSection(CExeFileBssSection *aCExeFileBssSection)
{
	aCExeFileBssSection-> ~CExeFileBssSection();
}

/**************************************************************************************************/

void FreeCExeFileDataSection(CExeFileDataSection *aCExeFileDataSection)
{
	aCExeFileDataSection-> ~CExeFileDataSection();
}


/**************************************************************************************************/

void FreeCExeFileImportSection(CExeFileImportSection *aCExeFileImportSection)
{
	aCExeFileImportSection-> ~CExeFileImportSection();
}

/**************************************************************************************************/

void FreeCExeFileRsrcSection(CExeFileRsrcSection *aCExeFileRsrcSection)
{
	aCExeFileRsrcSection-> ~CExeFileRsrcSection();
}

/**************************************************************************************************/

void FreeCExeFileRelocSection(CExeFileRelocSection *aCExeFileRelocSection)
{
	aCExeFileRelocSection-> ~CExeFileRelocSection();
}

/**************************************************************************************************/

void FreeCExeFileDebugSection(CExeFileDebugSection *aCExeFileDebugSection)
{
	aCExeFileDebugSection-> ~CExeFileDebugSection();
}

/**************************************************************************************************/

void FreeCDllExportEntry(CDllExportEntry *aCDllExportEntry)
{
	aCDllExportEntry-> ~CDllExportEntry();
}

/**************************************************************************************************/

void FreeCLibFile(CLibFile *aCLibFile)
{
	aCLibFile-> ~CLibFile();
}

/**************************************************************************************************/

void FreeCObjFile(CObjFile *aCObjFile)
{
	aCObjFile-> ~CObjFile();
}

/**************************************************************************************************/

void FreeCResFileEntry(CResFileEntry *aCResFileEntry)
{
	aCResFileEntry-> ~CResFileEntry();
}

/**************************************************************************************************/

void FreeCResUniCodeString(CResUniCodeString *aCResUniCodeString)
{
	aCResUniCodeString-> ~CResUniCodeString();
}

/**************************************************************************************************/

void FreeCObArray(CObArray *aCObArray)
{
	aCObArray-> ~CObArray();
}

/**************************************************************************************************/

void FreeCMyObArray(CMyObArray *aCMyObArray)
{
	aCMyObArray-> ~CMyObArray();
}

/**************************************************************************************************/

void FreeCObList(CObList *aCObList)
{
	aCObList-> ~CObList();
}

/**************************************************************************************************/

void FreeCMyObList(CMyObList *aCMyObList)
{
	aCMyObList-> ~CMyObList();
}

/**************************************************************************************************/

void FreeCMapStringToOb(CMapStringToOb *aCMapStringToOb)
{
	aCMapStringToOb-> ~CMapStringToOb();
}

/**************************************************************************************************/

void FreeCMyMapStringToOb(CMyMapStringToOb *aCMyMapStringToOb)
{
	aCMyMapStringToOb-> ~CMyMapStringToOb();
}

/**************************************************************************************************/

void FreeCMyMapStringToPtr(CMyMapStringToPtr *aCMyMapStringToPtr)
{
	aCMyMapStringToPtr-> ~CMyMapStringToPtr();
}

/**************************************************************************************************/

void FreeCFile(CFile *aCFile)
{
	aCFile-> ~CFile();
}

/**************************************************************************************************/

void FreeCMemFile(CMemFile *aCMemFile)
{
	aCMemFile-> ~CMemFile();
}

/**************************************************************************************************/

void FreeCMyMemFile(CMyMemFile *aCMyMemFile)
{
	aCMyMemFile-> ~CMyMemFile();
}

/**************************************************************************************************/

void FreeCMyPtrList(CMyPtrList *aCMyPtrList)
{
	aCMyPtrList-> ~CMyPtrList();
}

/**************************************************************************************************/

void FreeCSectionFragmentEntry(CSectionFragmentEntry *aCSectionFragmentEntry)
{
	aCSectionFragmentEntry-> ~CSectionFragmentEntry();
}

/**************************************************************************************************/

void FreeCMapWordToOb(CMapWordToOb *aCMapWordToOb)
{
	aCMapWordToOb-> ~CMapWordToOb();
}
	
/**************************************************************************************************/

void FreeCDWordArray(CDWordArray *aCDWordArray)
{
	aCDWordArray-> ~CDWordArray();
}

