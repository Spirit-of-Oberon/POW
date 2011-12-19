/**************************************************************************************************/
/*** Die Klasse CExeFile bildet eine PE-Datei ab. Instanzvariablen enthalten die zum Linken be-	***/
/*** nötigten Daten, sowie Objekte der zu erzeugenden Sektionen. Ihre Methoden zur Ablauf-						***/
/*** steuerung werden durch die entsprechenden Methoden eines Objekts der Klasse CLinker								***/
/*** aufgerufen und steuern ihrerseits den weiteren Ablauf durch Aufruf der Methoden ihrer      ***/
/*** Instanzvariablen die PE-Sektionen abbilden.																																																***/
/**************************************************************************************************/


// 32-Bit Linker 

#ifndef __EXEFILE_HPP__
#define __EXEFILE_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CExeFile : public CObject
{	
	DECLARE_DYNAMIC(CExeFile);

 friend class CObjFile;
	friend class CObjFileSection;
 friend class CExeFileDebugSection;
	friend class CObj2Exe;
	friend class CSymbolEntry;

 public:
  CMyMapStringToPtr		*pubSymLst;
		
		LPSTR *objFilNam;
  LPSTR *libFilNam;
  DWORD objFilNum;
  DWORD libFilNum;
  LPSTR exeFilNam;
  LPSTR resFilNam;
  LPSTR *expFncSymLst;
		DWORD basAdr;
  WORD  subSystem;
  BOOL  buildExeFile;
  BOOL  buildWinNtFile;
  DWORD includeDebugInfo;
  DWORD stackSize;

	protected:
		myCoffHeader																					exeCofHdr;
		myOptionalHeaderStandardFields			exeOptHdrStdFds;
		myOptionalHeaderNtSpecificFields	exeOptHdrNtSpcFds;
		myOptionalHeaderDataDirectory				exeOptHdrDatDir;

  CExeFileTextSection		 *textSec;
		CExeFileBssSection			 *bssSec;
		CExeFileDataSection		 *rdataSec;
		CExeFileDataSection		 *dataSec;
		CExeFileImportSection	*idataSec;
		CExeFileExportSection	*edataSec;
		CExeFileRelocSection	 *relocSec;
		CExeFileRsrcSection		 *rsrcSec;
		CExeFileDebugSection	 *debugSec;

		CMyMapStringToPtr *pubSymLstForDll;
		CMyMemFile						 	*exeFilRawDat;
		CMyObList  					 	*objFilLst;
  CMyObList         *srcObjFilLst;
  CMyObList         *exeFilSecLst;
		
  WORD lodObjSecNum;

public:
	CExeFile();
	~CExeFile();

	BOOL FreeUsedMemory();

	BOOL InitExeFileSec(CMyObList *obFilLst, CMyObList *srObjFilLst, CMyMapStringToPtr *pSymLst);
	BOOL BuildExeFileRawDataSections();
	BOOL ResolveRelocations();
	BOOL InitExeFileHeaders();
	BOOL BuildDebugInformation();
	BOOL BuildExeFileHeaders();
	BOOL BuildExeFileRawData();
	BOOL WriteExeFileRawDataToFile();
	
	BOOL IncludeDllImport(CDllExportEntry *dllExpEnt);
 DWORD GiveSectionEnd(DWORD actVirSecAdr);
	
	void WriteSecFragDataToFile();
	void WriteExeRawDataFileToLogFile();
	void WriteResolvedSymbolsList();
};

#endif	
