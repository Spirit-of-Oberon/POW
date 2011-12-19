/******************************************************************************************************/
/*** Die Datei Debug.hpp enthält die Definitionen der Klasse CExefileDebugSection. Ihre Instanz-				***/
/*** variablen und Methoden ermöglichen die Erstellung von MISC, FPO und CV Debuginformationen.					***/
/******************************************************************************************************/

// 32-Bit Linker 

#ifndef __DEBUG_HPP__
#define __DEBUG_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

class CExeFileDebugSection : public CExeFileDataSection
{
	DECLARE_DYNAMIC(CExeFileDebugSection)

	friend class CExeFile;
	friend class CObjFileSection;

 public:
  LPSTR *objFilLst;
  LPSTR *libFilLst;
  DWORD objFilNum;
  DWORD libFilNum;

		BOOL		bldMisc;
		BOOL		bldFPO;
		BOOL		bldCV;
		BOOL		bldCOFF;

	protected:
		CMyMemFile *rawDatMisc;
		CMyMemFile *rawDatFpo;
		CMyMemFile *rawDatCV;
		CMyMemFile *rawDatCof;
  CMyMemFile *dbgDirRawDat;
		CMyObList 	*debLstF;
		CMyObList 	*debLstS;
		CMyObList 	*debLstT;
		CMyObList  *sstGloSymLst;
  CMyObList  *sstGloSymAdrSrtTabLst;  

		CPtrArray		*sstGloTypArr;
		DWORD						sstGloTypInd;	

		DWORD						verSgnCV;																	// CodeView Versionsnummer; gibt an, welches Debugformat
																																							// erstellt werden soll.

  CMyMapStringToPtr *gloDatSymLst;
		CMyStringList					*usrDefNamLst;							
		
		CMyMapStringToOb *exeFilSecFrgLst;			// Zur leichteren Erstellung des CV 0x120 (sstModule)
																																							// Debugmodules. Die Fragmente werden beim Analysieren
																																							// der Objektdatei oder des Objektmodules in die Liste
																																							// geschrieben.

		myDebugDirectory dirMisc;				// Directory Eintrag der MISC Debuginformationen		
		myDebugDirectory	dirFpo;					// Directory Eintrag der FPO Debugfinformationen
		myDebugDirectory	dirCV;						// Directory Eintrag der CV Debuginformationen
		myDebugDirectory dirCof;					// Directory Eintrag der COFF Debuginformationen (nicht implementiert!)

		CExeFile *newExeFil;				// Zeiger auf das Objekt der zu erstellenden PE-Datei
		
private:
	mySubsectionDirectoryHeader subDirHdr;
	
	CMyMemFile *subSecDirCV;

	CMyObList	*chgDbgTSecLst;	// Speichert die neu erstellten .debugs$T Sektionen (CV4 -> CV5)

	BOOL	wrtCV5ToCV4Msg;						// Soll die Nachricht das CV5 auf CV4 geändert wurde geschrieben werden
	BOOL	wrtCV4ToCV5Msg;						// Soll die Nachricht das CV4 auf CV5 geändert wurde geschrieben werden
		
	public:
		CExeFileDebugSection();
		CExeFileDebugSection(char *aSecNam, CExeFile *nExeFil, WORD sNum= 0);

		~CExeFileDebugSection();

		virtual void FreeUsedMemory();
		
		BOOL ResRel(CDWordArray *relLst, DWORD	imBas);
		BOOL BuildMiscRawDataBlock();
		BOOL BuildFPORawDataBlock(DWORD virTxtSecAdr);
		BOOL BuildCVRawDataBlock(CMyMapStringToOb *dllImpLstLst, CMyObList *obFilLst);
		BOOL BuildCofRawDataBlock(DWORD virTxtSecAdr);
		BOOL BuildSecRawDataBlock();
		virtual BOOL AddSecFrag(CSectionFragmentEntry *aSecFrg);
		virtual BOOL BuildSecRawDataBlockParts(CMyMapStringToOb *actUnSortLst, CMyStringList *namLst);
		virtual BOOL GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAlign);

	private:
		CMyMemFile *BuildCVsstModule(CMyObList *obFilLst, CExeFile *actExeFil, CMyMapStringToOb *dllImpLstLst); // 0x120
		CMyMemFile *BuildCVsstAlignSym(CObjFile *aObjFil); // 0x125
		CMyMemFile *BuildCVsstSrcModule(CObjFile *aObjFil); // 0x127
		CMyMemFile *BuildCVsstLibraries(); // 0x128
		CMyMemFile *BuildCVsstGlobalSym(); // 0x129
		CMyMemFile *BuildCVsstGlobalPub(CMyObList *obFilLst); // 0x12A
		CMyMemFile *BuildCVsstGlobalTypes(); // 0x12B
		CMyMemFile *BuildCVsstSegMap(); // 0x12D
		CMyMemFile *BuildCVsstFileIndex(CMyObList *obFilLst); // 0x133
  CMyMemFile *BuildCVsstStaSym(); // 0x134

		BOOL IncSecFrgEntryForCV(CSectionFragmentEntry *aSecFrg);	// Daten sammeln für 0x120
		BOOL CalculateTypeIndizes40(WORD symTyp, WORD symLen, CMyMemFile *rawDatSecT, WORD objFilTypInd, CPtrArray *objFilTypArr, CObjFile *aObjFil);	
		BOOL CalculateTypeIndizes50(WORD symTyp, WORD symLen, CMyMemFile *rawDatSecT, DWORD objFilTypInd, CPtrArray *objFilTypArr, CObjFile *aObjFil);	
		WORD SetPESymbolType40(WORD sTyp, WORD oFilTypInd, CPtrArray	*objFilTypArr, char *objFilNam);	// Ermittlen des Symboltypindexes in der PE-Datei
		DWORD SetPESymbolType50(DWORD sTyp, DWORD oFilTypInd, CPtrArray	*objFilTypArr, char *objFilNam);	

		CMyMemFile *ChgDbgForSecTToCV4(CMyMemFile *oldRawDatSecT);
		CMyMemFile *ChgDbgForSecTToCV5(CMyMemFile *oldRawDatSecT);
		CMyMemFile *ChgDbgForSecSToCV4(CMyMemFile *oldRawDatSecS);
		CMyMemFile *ChgDbgForSecSToCV5(CMyMemFile *oldRawDatSecS);

		BOOL WriteNumericLeaf(CMyMemFile *oldRawDat, CMyMemFile *newRawDat);
};

#endif
