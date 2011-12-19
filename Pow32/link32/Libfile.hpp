/**************************************************************************************************/
/*** Jede Datei im COFF für Libraries wird durch ein Objekt der Klasse CLibFile abgebildet. 				***/
/*** Die Instanzvariablen enthalten das Exportverzeichnis der Bibliotheken. Die Methoden er-				***/
/*** möglichen das Laden der Datei, das Verarbeiten des Exportverzeichnisses und das Laden von  ***/
/*** Objektmodulen.																																																																													***/
/**************************************************************************************************/


// 32-Bit Linker 

#ifndef __LIBFILE_HPP__
#define __LIBFILE_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

#ifndef __PULIBEN_HPP__
#include "PubLibEn.hpp"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CLibFile : public CObject
{
	DECLARE_DYNAMIC(CLibFile)
	
	friend class CObj2Exe;

	public:
		char	*filNam;

	private:
		myLibFileHeader 	actLibFilHdr; 
		myLibFileHeader		secLnkMemHdr;
	
		CMyMapStringToPtr	*pubLibSymLst;
		//CMapPtrToWord		   *givObjFilLst;
		CBuffFile							  *actLibFil;

		char	*lstAccObjFil;
		char	achMemNam[16];
		char	secLnkMemNam[16];
		
  BYTE  *pubLibEntBuf; 
  BYTE  *strDirBuf; // Speicher für die Stringtabelle der Library; Wird auch von pubLibSymLst verwendet  

		BYTE		libFilSig[8];
		DWORD	memNum;
		DWORD	symNum;
		DWORD	lngNamTabOff;
  WORD  libFilInd;         // Wird von CV-Debuginformation für sstModules und sstLibraries benötigt

  BOOL  staLib;
											  
 public:
		CLibFile();
		~CLibFile();

		void FreeUsedMemory();
		
		BOOL LoadLibFileFromDiscOwnPubList(const char *pszFilNam);
		BOOL LoadLibFileFromDiscComPubList(const char *pszFilNam, CMyMapStringToPtr *&pLibSymLst);
		
	private:
		BOOL LoadLibFileFromDisc(const char *pszFilNam, CMyMapStringToPtr *&pubLibSymLst);
		char *GiveLibNameUp(const char *pszFilNam);

	public:
		CMyMemFile	*ReadLibObjFile(DWORD achMemOff);
		void Close();  

		void WritePubLibEntToFile();
		
};

#endif	
