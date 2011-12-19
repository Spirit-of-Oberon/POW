/**************************************************************************************************/
/*** Die Klasse CObj2Exe relisiert das konkrekte Vorgehensmodell, wie es in der Diplomschrift   ***/
/*** beschrieben wurde. Ihre Instanzvariablen sind hauptsächlich Listen, in denen die für das   ***/
/*** notwendigen Daten in entsprechender Form gespeichert sind. Die Methoden stoßen die									***/
/*** Schritte des Vorgehensmodells an.																																																										***/
/**************************************************************************************************/

// 32-Bit Linker 

#ifndef __OBJ2EXE_HPP__
#define __OBJ2EXE_HPP__

#ifndef	__LINKER_H__
#include "Linker.h"
#endif
                  
#ifndef __EXEFILE_HPP__
#include "ExeFile.hpp"
#endif

#ifndef __LIBFILE_HPP__
#include "LibFile.hpp"
#endif

#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CObj2Exe : public CObject
{
	DECLARE_DYNAMIC(CObj2Exe);

	public:
  LPSTR			*objFilLst;
  LPSTR			*libFilLst;
  LPSTR			resFil;
  LPSTR			exeFil;
  LPSTR			startUpSym;
  LPSTR			*expFncLst;
		DWORD			basAdr;
  WORD				subSystem;
  BOOL				bldExeFil;
  BOOL				bldWinNtFil;
  DWORD			incDbgInf;
		FARPROC ErrMsgFnc;
  DWORD   stackSize;

	
	protected:
		CMyMapStringToPtr	*pubSymLst;
		CMyMapStringToPtr *pubLibSymLst;
		CExeFile	         *newExeFil;
		CMyObList		       *libLst;
		CMyObList		       *objLst;
  CMyObList         *srcObjFilLst;
		CMyPtrList		      *unResSymLst;		
				 
public:
		CObj2Exe();
		~CObj2Exe();

		BOOL FreeUsedMemory();
	
		BOOL InitLinker();
		BOOL ResolveSymbols();
  BOOL ConnectSectionFragments();
		BOOL ResolveRelocations();
		BOOL BuildDebugInformation();
		BOOL BuildExeFile();	
		BOOL SearchForSym(char *aSym);
  BOOL FreeLibFiles();

		// Hilfsmethoden zum Debuggen

		void WriteSymInSymList();
		void WriteUnResSymInSymList();
		void WriteObjSym();

private:

		// Suche nach einem Symobl in den Bibliotheken

		CMyMemFile *FndSymInLibs(char *sNam, CLibFile *&curLibFil);
		CMyMemFile *FndSymInLibsOneList(char *sNam, CLibFile *&curLibFil);
};

#endif	
	
