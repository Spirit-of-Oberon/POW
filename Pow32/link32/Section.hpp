/**************************************************************************************************/
/*** Die Datei Section.hpp beinhaltet alle Klassendefinitionen von Klassen, die COFF oder PE-   ***/
/*** Datei Sektionen abbilden.																																																																		***/
/**************************************************************************************************/

// 32-Bit Linker 

#ifndef __SECTION_HPP__
#define __SECTION_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

/**************************************************************************************************/
/*** Die Klasse CSection ist die Oberklasse aller Klassen, die COFF oder PE-Sektionen abbilden	 ***/
/*** und vereint die gemeinsamen Instanzveriablen und Methoden der Sektionen beider Formate					***/
/**************************************************************************************************/

class CSection : public CObject
{
	DECLARE_DYNAMIC(CSection)

 friend class CObjFile;
	friend class CExeFile;
	friend class CSectionFragmentEntry;
 friend class CExeFileExportSection;
 friend class CExeFileDebugSection;
	
	public:
		char		*secNam;									 

	protected:
		mySectionTable	*actSecTab;
		CMyMemFile  			*secRawDat;
		
		DWORD secRawDatSiz;
		DWORD	virSecAdr;
  WORD		aln;
		WORD		secNum;
		BOOL		freSecNam;				/* Gibt an ob der Speicherplatz des Sektionsnamens freigegeben werden muß, */
																						/* da er mit malloc(...) allokierte wurde																																		*/
	public:
		CSection();
		CSection(char *aSecNam, WORD sNum= 0);
		
		~CSection();

		virtual void FreeUsedMemory();
		
		void SetSecAlign();
		DWORD BytesTillAlignEnd(DWORD aNum, WORD aAln);
  virtual BOOL GiveSecRawDataBlock(CMyMemFile *exeFilRawDat);
		
		/*** Hilfsmethoden zum Debuggen ***/

		void WriteSecDataToFile();
		void WriteRawDataToFile(CFile *secRawDat);	
};

/**************************************************************************************************/
/*** Die Klasse CObjFileSection ist von CSection abgeleitet und wird für alle Sektionen in						***/
/*** COFF Objektdateien verwendet. Ein Objekt dieser Klasse bildet eine Sektion einer 32-Bit    ***/
/***	Objektdatei ab. Die Unterscheidung der Sektionsarten erfolgt über den Sektionsnamen und    ***/
/*** das Charakteristik-Flag.																																																																			***/	
/**************************************************************************************************/
							
class CObjFileSection : public CSection
{
	DECLARE_DYNAMIC(CObjFileSection)

	friend class CSectionFragmentEntry;
	friend class CExeFileTextSection;
 friend class CExeFileExportSection;
	friend class CExeFileDebugSection;
	
	protected:
		CSectionFragmentEntry *actFrgEnt;

		BYTE *secRelBuf;
  BYTE *secLinNumBuf;     
	
	public:
		CObjFileSection();
		CObjFileSection(char *aSecNam, WORD sNum= 0);
		
		~CObjFileSection();

		virtual void FreeUsedMemory();
		
		void SetFragEntry(CSectionFragmentEntry *frgEnt);	
		BOOL ReadSecData(CMyMemFile *actObjRawDat, DWORD sekPos, CObjFile *secObjFil);
		BOOL WrapFromObj2Exe(CObjFile *secObjFil, CExeFile *aExeFil);
  CMyMapStringToOb *GiveDllFunDir();		
		CDllExportEntry *GiveDllExpEntIdata$2(CObjFile *dObjFil, char *dllNam);
		CDllExportEntry *GiveDllExpEntIdata$4(CObjFile *dObjFil, char *dllNam, CObjFileSection *txtSec);
		CDllExportEntry *GiveDllExpEntIdata$6(CObjFile *dObjFil, char *dllNam, CObjFileSection *txtSec= NULL);
};

/**************************************************************************************************/
/*** Abgeleitet von der Klasse CSection ist die Klasse CExeFileDataSection die Oberklasse der   ***/
/*** der Klassen CExeFileTextSection, CExeFileBssSection und CExeFileDebugSection. Sie bildet   ***/
/*** die .DATA Sektion der PE-Datei ab und stellt die entsprechenden Instanzvariablen und							***/
/*** Methoden zur Verfügung.																																																																				***/	
/**************************************************************************************************/

class CExeFileDataSection : public CSection
{
	DECLARE_DYNAMIC(CExeFileDataSection)

	friend class CSectionFragmentEntry;
	friend class CExeFileDebugSection;

	protected:
		CMyMapStringToOb	*unSorObjSecFrgLst;    // In diese Liste kommen alle Sectionfragmente, welche
																																							  	// den selben Fragmentnamen wie die zukünftige Exefile-
																																								  // section haben
		CMyMapStringToOb	*unSorOthObjSecFrgLst; // In diese Liste kommen alle anderen Fragmente, zum 
																																								  // Beispiel die .CRT0 Sektionen in den LIBS
																																								  // Die Aufspaltung in zwei Listen wurde aufgrund der
																																								  // leichteren Sortierbarkeit vorgenommen
		CMyStringList	*objNamLst;
		CMyStringList	*othObjNamLst;
		CMyObList			*secFrgLst;

		WORD	secAln;		
		
	public:
	 CExeFileDataSection();
		CExeFileDataSection(char *aSecNam, WORD sNum= 0);

		~CExeFileDataSection();

		virtual void FreeUsedMemory();
		
		BOOL ResRel(CDWordArray *relLst, DWORD	imBas);
		BOOL BuildSecRawDataBlock();
		virtual BOOL AddSecFrag(CSectionFragmentEntry *aSecFrg);
		virtual BOOL BuildSecRawDataBlockParts(CMyMapStringToOb *actUnSortLst, CMyStringList *namLst);
		virtual void SetVirSecAdr(DWORD vSecAdr);
		virtual DWORD GiveSecRawDataSize(WORD fAlign);
		virtual BOOL GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAlign);
		
		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteSecFragToFile();	
		void WriteResolvedSectionSymbols();
};

/******************************************************************************************************/
/*** Die Klasse CExeFileTextSection repräsentiert die .TEXT Sektion der PE-Datei. Sie ist von der  ***/
/*** Klasse CEXEFileDataSection abgeleitet und hat zusätzliche Instanzvariablen und Methoden für   ***/
/*** für die Forwarder Chain der Dynamic Link Library Importeinträge.																														***/
/******************************************************************************************************/

class CExeFileTextSection : public CExeFileDataSection
{
	DECLARE_DYNAMIC(CExeFileTextSection)

	friend class CExeFile;
	
 public:
  mySymbolEntry *startUpSym;

 protected:
		CMyObList	*dllImpEntLst;
		DWORD			nxtDllAdrEntAdr;
		DWORD			entPntAdr;
	
	public:
		CExeFileTextSection();
		CExeFileTextSection(char *aSecNam, WORD sNum= 0);

		~CExeFileTextSection();
 
 	virtual void FreeUsedMemory();
		
		BOOL IncDllImp(CDllExportEntry *dllExpEnt);
		BOOL IncDllForChainRel(CMyMapStringToOb *dllImpLstLst, CDWordArray *relLst, DWORD incDbgInf);
		DWORD	GiveDllForChainStart();
		DWORD GiveSecRawDataSize(WORD fAln);
		virtual BOOL GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, CMyMapStringToOb *dllImpLstLst, WORD fAln);
		
		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteSecFragToFile();	
};

/*******************************************************************************************************/
/*** Die .BSS Sektion der PE-Datei wird durch ein Objekt der Klasse CExeFileBssSection abgebildet.   ***/
/*** Obwohl eine .BSS Sektion keine Rohdaten enthält, werden beim Linken trotzdem Instanzvariabelen  ***/
/*** und Methoden zum Bestimmen des zu reservierenden Speichers für die uninitialisierten statischen ***/
/*** und globalen Variablen. Der Microsoft Linker erstllt ab Version 4.0 keine eigene .BSS Sektion   ***/
/*** mehr, sondern addiert den reservierten Speicherbedarf, den der .DATA Sektion hinzu.													***/
/*******************************************************************************************************/

class CExeFileBssSection : public CExeFileDataSection
{
	DECLARE_DYNAMIC(CExeFileBssSection)

	friend class CObj2Exe;
 friend class CObjFile;
	friend class CSymbolEntry;
	friend class CExeFile;

	protected:
		CMyPtrList	*bssVarLst;
		DWORD		    varStartOff;

	public:
		CExeFileBssSection();
		CExeFileBssSection(char *aSecNam, WORD sNum= 0);

		~CExeFileBssSection();
	
		virtual void FreeUsedMemory();
		
		BOOL ResRel(DWORD imBas);
		BOOL SetBssVarOff(DWORD imBas, WORD fAln);
		virtual BOOL AddSecFrag(CSectionFragmentEntry *aSecFrg);
		virtual DWORD GiveSecRawDataSize(WORD fAlign);

		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteSecFragToFile();
};
	
/******************************************************************************************************/
/*** Die Klasse CExeFileImportSection bildet die .IDATA Sektion der PE-Datei ab. Sie besitzt 							***/
/*** Instanzvariablen und Methoden zum Speichern der Importeinträge aus den DLL's und zum Erstellen ***/
/*** der Importsektion der PE-Datei.																																																																***/          
/******************************************************************************************************/

class CExeFileImportSection : public CSection
{
	DECLARE_DYNAMIC(CExeFileImportSection)

	friend class CSection;
	friend class CExeFile;
	friend class CExeFileDebugSection;

	protected:
		CMyMapStringToOb	*dllImpLstLst;

		CMyMapStringToOb *speDllEntLst;				 	// Um die NULL_THUNK_DATA und IMPORT_DESCRIPTOREN der 
																																							// einzelnen DLL' s leichter Erstellen zu können, werden 
																																							// sie in dieser Liste geschrieben.
		DWORD		impDirAdr;
		DWORD		impDirSiz;
		DWORD		impAdrTabAdr;
		DWORD		impAdrTabSiz;
		
	public:
		CExeFileImportSection();
		CExeFileImportSection(char *aSecNam, WORD sNum= 0);

		~CExeFileImportSection();
	
		virtual void FreeUsedMemory();
		
		DWORD BuildDllImpSec(CMyMapStringToPtr *pubSymLst, WORD fAln, DWORD imBas, DWORD actEntSecTxtOff,
																							BOOL incDbgInf);
		virtual void SetVirSecAdr(DWORD vSecAdr);

		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteImpSecToFile();
};			

/******************************************************************************************************/
/*** Die Exportsektion ist Bestandteil der Dynamic Link Libraries und der Importdateien und wird    ***/
/*** durch die Klasse CExeFileExportSection abgebildet. Sie besitzt Instanzvariablen und Methoden   ***/
/*** zum Speichern der zu exportierenden Funktionen und zum Erstellen der .EDATA Sektion der 							***/
/*** PE-Datei und der Importdatei.	Der Microsoft Linker erstellt ab Version 4.0 keine eigene     			***/
/*** Exportsektion mehr, sondern schreibt die Exportinformationen in die .RDATA Sektion.            ***/
/******************************************************************************************************/

class CExeFileExportSection : public CSection
{
	DECLARE_DYNAMIC(CExeFileExportSection)

	friend class CSection;
	friend class CExeFile;

	protected:
		myExportDirectoryTable actExpDirTab;
  myExportRecord         **expSymLst;

		CMyPtrList	*expFncLst;
  CMyMemFile *expFilEdataRawDat;

	public:
		CExeFileExportSection();
		CExeFileExportSection(char *aSecNam, WORD sNum= 0);

		~CExeFileExportSection();
	
		virtual void FreeUsedMemory();
		
		DWORD BuildExpFncSec(char *dllOrExeFilNam, WORD fAln);
  BOOL AddExpFncEntry(mySymbolEntry *addSymEnt);
  BOOL BuildDllExportFile(char *dllOrExeFilNam, char *expFilNam);
  BOOL BuildDllLibFile(char *dllOrExeFilNam, char *dllLibFilNam, CExeFile *exeFil);
		virtual void SetVirSecAdr(DWORD vSecAdr);
		
		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteExpSecToFile();
};			

/******************************************************************************************************/
/*** Die Klasse CExeFileRsrcSection bildet die .RSRC Sektion der PE-Datei ab. Als Eingabedatei wird ***/
/*** die nur .RES Datei des Projekts benötigt. Die vorhandenen Instanzvariablen und Methoden	       ***/
/*** bilden den Inhalt der .RES-Datei ab und erstellen die benötigte .RSRC Datei.																			***/
/******************************************************************************************************/

class CExeFileRsrcSection : public CSection
{
	DECLARE_DYNAMIC(CExeFileRsrcSection)

 public:
  LPSTR resFilNam;

	protected:
		CResFileEntry	   *hdrResFilEnt;
		CMapWordToOb	    *resTypMap;
  CMyMapStringToOb *resTypStrMap;

		DWORD	resEntNum;

	public:
		CExeFileRsrcSection();							 
		CExeFileRsrcSection(char *aSecNam, WORD sNum= 0);

		~CExeFileRsrcSection();							 

		virtual void FreeUsedMemory();
		
		BOOL ReadResFile(const char *pszResFilNam);
		void SetVirSecAdr(DWORD vSecAdr);
		virtual BOOL GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAln);
		BOOL BuildResSecRawData();

		/*** Hilfsmethoden zum Debuggen ***/

		int	WriteResSecRawDataToFile();
};

/******************************************************************************************************/
/*** Die Klasse CExeFileRelocSection ist ebenfalls von CSection abgeleitet und bildet die .RELOC-   ***/
/*** Sektion der PE-Datei ab. Die Instanzvariablen speichern die dafür notwendigen Daten und die    ***/
/*** Methoden erstellen die Sektion.																																																																***/
/******************************************************************************************************/

class CExeFileRelocSection : public CSection
{
	DECLARE_DYNAMIC(CExeFileRelocSection)

	friend class CExeFile;

	protected:
		CDWordArray	*relLst;
		
	public:
		CExeFileRelocSection();
		CExeFileRelocSection(char *aSecNam, WORD sNum= 0);

		~CExeFileRelocSection();

		virtual void FreeUsedMemory();
		
		BOOL BuildRelSec(WORD secAlign, WORD fileAlign);
		virtual void SetVirSecAdr(DWORD vSecAdr);

		/*** Hilfsmethoden zum Debuggen ***/

		virtual void WriteRelSecToFile();
};

#endif
