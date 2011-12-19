/**************************************************************************************************/
/*** In der Datei Publiben.hpp befinden sich die Definitionen der Klassen CDllExportEntry, für  ***/
/*** die Abbildung der aus DLL's importierten Symbolen, CSectionFragmentEntry, für die Ab-						***/
/*** bildung der Sektionsfragmente der .TEXT, .BSS, .RDATA und .DATA Sektionen der PE-Datei,		  ***/
/*** sowie die Klassen CResFileEntry und CUniCodeString, die Daten einen Ressourceeintrags und  ***/
/*** eines Ressource Unicode String kapseln.																																																				***/
/**************************************************************************************************/

// 32-Bit Linker 

#ifndef __PUBLIBEN_HPP__
#define __PUBLIBEN_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

/**************************************************************************************************/
/*** Die Klasse CDllExportEntry speichert alle Daten eines aus einer DLL importierten Symobls,  ***/
/*** die für das Erstellen der .IDATA Sektion von Bedeutung sind.	Außer den üblichen Konstrukt-	***/
/*** und Destruktuoren besitzt sie keine Methoden.																																														***/ 
/**************************************************************************************************/

class CDllExportEntry : public CObject
{
	DECLARE_DYNAMIC(CDllExportEntry);

	friend class CObj2Exe;
	friend class CExeFile;
	friend class CExeFileImportSection;	
	friend class CExeFileTextSection;
	friend class CExeFileDebugSection;
	friend class CSectionFragmentEntry;

	public:
		WORD	expOrd;

	protected:
		CObjFile								*dllObjFil;
		CObjFileSection *txtDllSec;

		DWORD	textSegOff;
		DWORD idataLokUpTabOffIdata;
		DWORD	idataLookupTabOff;
		DWORD idataExeSecNum;
		DWORD	impLokUpTabOff;
		DWORD	impAdrTabOff;
		DWORD namTabEntOff;
		DWORD	namTabEntLen;
		char	 *expFunNam;
		char	 *dllNam;
  BOOL  expByOrd;

	public:
		CDllExportEntry();
		
		// Wird nicht benötigt für neue Versioin der C-Laufzeitbibliotheken
		CDllExportEntry(WORD ord, char *eFunNam, char *aDllNam, BOOL eByOrd= FALSE, DWORD txtSegOff= 0, DWORD lUpTabOff= 0);

		CDllExportEntry(CObjFile *dObjFil, CObjFileSection *tDllSec, WORD ord, char *eFunNam, char *aDllNam, BOOL eByOrd= FALSE,
																		DWORD txtSegOff= 0, DWORD lUpTabOff= 0);

		~CDllExportEntry();

		void FreeUsedMemory();

		// Hilfsmethode zum Debuggen

		void WriteDataToFile();
};

/**************************************************************************************************/
/*** Die Klasse CSectionFragmentEntry kapselt alle notwendigen Daten eines Sektionsfragments    ***/
/*** .TEXT, .BSS, .RDATA und .DATA Sektion. Weiters erfolgt mittels der Methode ResRel(...)     ***/
/*** das Auflösen der noch nicht berechneten Adressen.                                          ***/
/**************************************************************************************************/

class CSectionFragmentEntry : public CObject
{
	DECLARE_DYNAMIC(CSectionFragmentEntry);

	friend class CExeFileDataSection;
	friend class CExeFileTextSection;
	friend class CExeFileBssSection;
 friend class CExeFileExportSection;
	friend class CExeFileDebugSection;

	public:
		DWORD			secFrgOff;

	private:
		CExeFileDataSection	*actExeSec;
		CObjFileSection					*myHomSec;
		BYTE											     *secFrgRelBuf;
		CMyMemFile										*rawDat;
		CObjFile												*secFrgObjFil;

		DWORD	rawDatSiz;	
		DWORD	secSiz;
		
		WORD		secFrgAln;

	public:
		CSectionFragmentEntry();
		CSectionFragmentEntry(CExeFileDataSection *exeSec, DWORD frgOff, CObjFileSection *homSec,
																								CObjFile *frgObjFil, WORD sFrgAln);

		~CSectionFragmentEntry();

		void FreeUsedMemory();
	
		void SetFragOffset(DWORD secOff);
		DWORD GetRawDataSize();
		BOOL ResRel(CDWordArray *relLst, DWORD	imBas, DWORD virSecAdr, WORD secNum);
		void WriteFragDataToFile();															
		
		// Hilfsfunktion zum Debuggen
		
		void WriteResolvedSymbols();
};

/**************************************************************************************************/
/*** Die Klasse CResUniCodeString dient als Datenkapsel eines Unicode Strings, wie er in den    ***/
/*** Microsoft Win32 Ressourcedateien verwendet wird.																																											***/
/**************************************************************************************************/

class CResUniCodeString : public CObject
{
	DECLARE_DYNAMIC(CResUniCodeString);

	friend class CExeFileRsrcSection;
	friend class	CResFileEntry;
	
	protected:
		DWORD	idtUCStrLen;
		DWORD	uCResAdr;
		WORD	 *idtUCStr;

	public:	
		CResUniCodeString();
		~CResUniCodeString();

		void FreeUsedMemory();
};

/**************************************************************************************************/
/*** Die Klasse CResFileEntry kapselt die Daten eines Ressourceeintrags und liest sie durch die ***/
/*** Methode ReadResFileEntry in die entsprechenden Instanzvariablen ein.																							***/
/**************************************************************************************************/

class CResFileEntry : public CObject
{
	DECLARE_DYNAMIC(CResFileEntry);

	friend class CExeFileRsrcSection;

	protected:
		myResourceAddHeader1	resAddHdr1;
		myTypeIdentifier					typIdtId;
		CResUniCodeString				*typIdtUCStr;
		myNameIdentifier					namIdtId;
		CResUniCodeString				*namIdtUCStr;
		myResourceAddHeader2	resAddHdr2;

		CMyMemFile	*resRawDat;
	public:
		CResFileEntry();
		~CResFileEntry();

		void FreeUsedMemory();

		int ReadResFileEntry(CFile *actResFil);
};

#endif
		 
