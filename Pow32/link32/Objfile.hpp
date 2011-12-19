/**************************************************************************************************/
/*** Die Datei ObjFile.hpp beinhaltet die Definition der Klasse CObjFile, welche eine COFF-     ***/
/*** Datei abbildet. Die Instanzvariblen enthalten die Daten der COFF-Datei, ihre Methoden      ***/
/*** lesen und analysieren den Inhalt der PE-Datei und bereiten in für den weiteren Linkvor-    ***/
/*** gang entsprechend auf.                                                                     ***/
/**************************************************************************************************/

// 32-Bit Linker 

#ifndef __OBJFILE_HPP__
#define __OBJFILE_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

#ifndef __EXEFILE_HPP__
#include "ExeFile.hpp"
#endif
  
#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

#ifndef __MYFILE_HPP__
#include "MyCFile.hpp"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CObjFile : public CObject
{
	DECLARE_DYNAMIC(CObjFile);

	friend class CObjFileSection;	
	friend class CExeFileTextSection;
 friend class CExeFileExportSection;
	friend class CExeFileDebugSection;
	friend class CObj2Exe;
	friend class CSectionFragmentEntry;

	public:
		CDllExportEntry *incExpEnt;
		
		char *srcFilNam;
		char *objFilNam;
	 char	*libFilNam;
  BYTE *symEntBuf;
		BYTE *objFilBuf;
		
  WORD libFilInd;
		WORD	cvModInd;
		BOOL	incDllFun;
		BOOL libObjFil;
		BOOL linNmbInc;
		BOOL	insSstFilInd;

	private:
 	CMyMapStringToOb	*secLstLst;
		CMyObArray							*secLst;
		mySymbolEntry    **newSymLst;
	 CExeFile					    *ftrExeFil;
  myCoffHeader 		  objCofHdr; 

  CMyMemFile       *objMemFil;
		CMyPtrList							*freSymNamLst;		/* Liste aller freizugebender Symbolnamen die 8 Zeichen */
																																			/* lang sind, und bei denen das nächste Byte im Record  */
																																			/* nicht (val) nicht Null ist																											*/	
		
		/* For easier Debug Information build */

		CObjFileSection		*dbgTSec;
		CMyPtrList							*gloPubSymLst;				// Speichert die globalen public Symbole für CV-Debuginforamtion
		CMyMemFile							*sstGloTypRawDat;	// Enthält die sstGlobalTypes CV Debuginformation, die nicht
																																					// aus den .debug$S Sektionen stammt.
 public:
	 CObjFile();
		~CObjFile();

		void FreeUsedMemory();

	 BOOL LoadObjFileFromDisc(const char *pszFilNam, CMyPtrList *unResSymLst, CMyMapStringToPtr *pubSymLst);
	 BOOL AnalObjFileData(CMyMemFile *aMemFil, CMyPtrList *unResSymst, CMyMapStringToPtr *pubSymLst);
	 BOOL SplitObjSec(CExeFile *aExeFil);
	 void SetExeFile(CExeFile *ftrExeFil);
	 void WriteSymToFile();
  void WriteObjDataToFile();	
  CMapStringToOb *GiveDllFunDir();

 private:
  DWORD CObjFile::ReadSymEntData(mySymbolEntry *actSymEnt, CMyMemFile *actObjRawDat, DWORD ptrToStrTab, 
                                 CObjFile *actObjFil, CMyPtrList *unResSymLst, CMyMapStringToPtr *pubSymLst);
};

#endif
