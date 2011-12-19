/**************************************************************************************************/
/*** Die Datei Debug.cpp beinhaltet die Implementierung der Klasse CExeFileDebugSektion, die				***/
/***	für die Erstellung von Debuginformation in der PE-Datei zuständig ist.																					***/
/**************************************************************************************************/

#include <malloc.h> // Zum Heapcheck
#include <stdlib.h>
#include <ctype.h>
#include <math.h>

#ifndef __LINKER_HPP__
#include "Linker.h"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __DEBUG_HPP__
#include "Debug.hpp"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

#ifndef __PUBLIBEN_HPP__
#include "PubLibEn.hpp"
#endif

#ifndef __OBJFILE_HPP__
#include "ObjFile.hpp"
#endif

#define CV_MOD_120		   1
#define CV_MOD_125		   2
#define CV_MOD_127		   4
#define CV_MOD_128		   8
#define CV_MOD_129		  16
#define CV_MOD_12A		  32
#define CV_MOD_12B		  64
#define CV_MOD_12D		 128
#define CV_MOD_133		 256
#define CV_MOD_134		 512

#define VER_SGN_CV4		0x00000001
#define VER_SGN_CV5		0x00000002

#define MAX_SCOPE_LEVEL	10

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

BOOL WritePadBytes(CMyMemFile *rawDat, WORD bytTilAlnEnd);
BOOL SeekNumericLeaf(CMyMemFile *rawDat);
DWORD GiveTableHash(char *lpbName);
BOOL AppandCVModAndDirectoryToCVModule(CMyMemFile *modRawDat, CMyMemFile *srcRawDat, CMyMemFile *subSecDirRawDat,
																																							WORD subDirInd, WORD modInd) ;

extern void MessageOut (FARPROC msg, char *error);
extern void TestHeap(void);
extern DWORD	CalcTimeDateStamp();
extern void FreeCResFileEntry(CResFileEntry *aCResFileEntry);
extern void FreeCMyObList(CMyObList *aCObList);
extern void FreeCMyMapStringToOb(CMyMapStringToOb *aCMyMapStringToOb);
extern void FreeCMyMemFile(CMyMemFile *aCMemFile);
extern void FreeCSectionFragmentEntry(CSectionFragmentEntry *aCSectionFragmentEntry);
extern void FreeCMapWordToOb(CMapWordToOb *aCMapWordToOb);
extern void FreeCDWordArray(CDWordArray *aCDWordArray);
extern void FreeCMyObArray(CMyObArray *aCObArray);
extern void FreeCMyPtrList(CMyPtrList *aCPtrList);

extern	FILE	*logFil;
extern	char	*logFilNam;
extern 	int	logOn;   

extern BYTE chrBufCC[];
extern BYTE chrBuf00[];

IMPLEMENT_DYNAMIC(CExeFileDebugSection, CExeFileDataSection)
																																																													
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileDebugSection::CExeFileDebugSection() : CExeFileDataSection()
{
	debLstF= NULL;
	debLstS= NULL;
	debLstT= NULL;
	usrDefNamLst= NULL;	
	gloDatSymLst= NULL;
	rawDatMisc= NULL;
	rawDatFpo= NULL;
	rawDatCV= NULL;
	rawDatCof= NULL;
 dbgDirRawDat= NULL;
	sstGloSymLst= NULL;
 sstGloSymAdrSrtTabLst= NULL;
 newExeFil= NULL;
	exeFilSecFrgLst= NULL;
	sstGloTypArr= NULL;
	chgDbgTSecLst= NULL;

	bldMisc= TRUE;
	bldFPO= FALSE;
	bldCV= TRUE;
	bldCOFF= FALSE;
 	
	verSgnCV= 0;
	secRawDatSiz= 0;
	sstGloTypInd= 0;	
	secAln= 0;
	virSecAdr= 0;

	wrtCV5ToCV4Msg= TRUE;
	wrtCV4ToCV5Msg= TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileDebugSection::CExeFileDebugSection(char *secName, CExeFile *nExeFil, WORD sNum) : CExeFileDataSection(secName, sNum)
{
 debLstF= new CMyObList(250);
	debLstS= new CMyObList(25);
	debLstT= new CMyObList(25);	
	usrDefNamLst= new CMyStringList(100);
	gloDatSymLst= new CMyMapStringToPtr(100);;
	sstGloTypArr= new CPtrArray();
	sstGloTypArr-> SetSize(0x400, 0x200);
	rawDatMisc= NULL;
	rawDatFpo= NULL;
	rawDatCV= NULL;
	rawDatCof= NULL;
	dbgDirRawDat= new CMyMemFile();
	sstGloSymLst= new CMyObList(100);
 sstGloSymAdrSrtTabLst= new CMyObList(100);
	exeFilSecFrgLst= new CMyMapStringToOb(100);
	exeFilSecFrgLst-> InitHashTable(10);
	newExeFil= nExeFil;
 
 actSecTab-> chr= 0x00000000;
	verSgnCV= 0;
	secRawDatSiz= 0;
	secAln= 8;
	sstGloTypInd= 0;		
	virSecAdr= 0;	

	bldMisc= TRUE;
	bldFPO= FALSE;
	bldCV= TRUE;
	bldCOFF= FALSE;
	
	chgDbgTSecLst= new CMyObList(100);
	wrtCV5ToCV4Msg= TRUE;
	wrtCV4ToCV5Msg= TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileDebugSection::~CExeFileDebugSection()
{
	FreeUsedMemory();	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileDebugSection::FreeUsedMemory()
{
	CMyMapStringToOb *secFrgEntLst;
	CMyObList								*secFrgObjLst;
	CMyMemFile							*delMemFil;
	POSITION	entPos;
	POSITION	frgEntPos;
 char     *strLstNam;
	char					*frgEntNam;
	char					*frgSecNam;

 CExeFileDataSection::FreeUsedMemory();
	if (debLstF)
	{
		FreeCMyObList(debLstF);
		delete debLstF;
		debLstF= NULL;
	}
	if (debLstS)
	{
		FreeCMyObList(debLstS);
		delete debLstS;
		debLstS= NULL;
	}
	if (debLstT)
	{
		FreeCMyObList(debLstT);
		delete debLstT;
		debLstT= NULL;
	}
 if (usrDefNamLst)
 {
  while(usrDefNamLst-> GetCount())
  {
   strLstNam= (char *) usrDefNamLst-> RemoveTail();
   free(strLstNam);
  }
  //FreeCMyStringList(usrDefNamLst);
  usrDefNamLst-> ~CMyStringList();
  delete usrDefNamLst;
  usrDefNamLst= NULL;
 }
	if (gloDatSymLst)
 {
  gloDatSymLst-> ~CMyMapStringToPtr();
  delete gloDatSymLst;
  gloDatSymLst= NULL;
 }
	if (rawDatMisc) 
	{
		FreeCMyMemFile(rawDatMisc);
		delete rawDatMisc;
		rawDatMisc= NULL;
	}
	if (rawDatFpo)
	{
		FreeCMyMemFile(rawDatFpo);
		delete rawDatFpo;
		rawDatFpo= NULL;
	}
	if (rawDatCV)
	{
		FreeCMyMemFile(rawDatCV);
		delete rawDatCV;
		rawDatCV= NULL;
	}
	if (rawDatCof)
	{
		FreeCMyMemFile(rawDatCof);
		delete rawDatCof;
		rawDatCof= NULL;
	}
	if (dbgDirRawDat)
 {
		FreeCMyMemFile(dbgDirRawDat);
		delete dbgDirRawDat;
		dbgDirRawDat= NULL;
	}
	if (sstGloSymLst)
	{
		while(!sstGloSymLst-> IsEmpty())
		{
			delMemFil= (CMyMemFile *)sstGloSymLst-> RemoveHead();
			FreeCMyMemFile(delMemFil);
			delete delMemFil;
		}
		FreeCMyObList(sstGloSymLst);
		delete sstGloSymLst;
		sstGloSymLst= NULL;
	}

 if (sstGloSymAdrSrtTabLst)
	{
		while(!sstGloSymAdrSrtTabLst-> IsEmpty())
		{
			delMemFil= (CMyMemFile *)sstGloSymAdrSrtTabLst-> RemoveHead();
			FreeCMyMemFile(delMemFil);
			delete delMemFil;
		}
		FreeCMyObList(sstGloSymAdrSrtTabLst);
		delete sstGloSymAdrSrtTabLst;
		sstGloSymAdrSrtTabLst= NULL;
	}

	if (chgDbgTSecLst)
	{
		while(!chgDbgTSecLst-> IsEmpty())
		{
			delMemFil= (CMyMemFile *)chgDbgTSecLst-> RemoveHead();
			FreeCMyMemFile(delMemFil);
			delete delMemFil;
		}
		FreeCMyObList(chgDbgTSecLst);
		delete chgDbgTSecLst;
		chgDbgTSecLst= NULL;
	}

	if (sstGloTypArr)
	{
		sstGloTypArr-> RemoveAll();
		sstGloTypArr-> ~CPtrArray();
		delete sstGloTypArr;
		sstGloTypArr= NULL;
	}

	if (exeFilSecFrgLst)
	{
		frgEntPos= exeFilSecFrgLst-> GetStartPosition();
		while(frgEntPos)
	 {
  	exeFilSecFrgLst-> GetNextAssoc(frgEntPos, frgEntNam, (CObject *&) secFrgEntLst);
			entPos= secFrgEntLst-> GetStartPosition();
			while(entPos)
			{
				secFrgEntLst-> GetNextAssoc(entPos, frgSecNam, (CObject *&) secFrgObjLst);
				secFrgObjLst-> RemoveAll();
				FreeCMyObList(secFrgObjLst);
				delete secFrgObjLst;
			}
			secFrgEntLst-> RemoveAll();
   FreeCMyMapStringToOb(secFrgEntLst);
 	 delete secFrgEntLst;
  }
		exeFilSecFrgLst-> RemoveAll();
	 FreeCMyMapStringToOb(exeFilSecFrgLst);
 	delete exeFilSecFrgLst;
		exeFilSecFrgLst= NULL;
	}
	
 newExeFil= NULL;
	
	verSgnCV= 0;
	secRawDatSiz= 0;
	secAln= 0;
	virSecAdr= 0;
}

/**************************************************************************************************/
/*** Hinzufügen der einzelnen Debugsektionen aus den Objektdateien in die dem Debugtyp ent-					***/
/*** sprechenden Listen.																																																																								***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::AddSecFrag(CSectionFragmentEntry *aSecFrg)
{
	if (aSecFrg-> myHomSec-> secNam[7] == 'F')
	 debLstF-> AddTail(aSecFrg);
	else
	{
		if (aSecFrg-> myHomSec-> secNam[7] == 'S')
			debLstS-> AddTail(aSecFrg);					
		else
		{
			if (aSecFrg-> myHomSec-> secNam[7] == 'T')
			 debLstT-> AddTail(aSecFrg);
			else
				WriteMessageToPow(WRN_MSGS_UNK_DEB_SEC, aSecFrg-> myHomSec-> secNam, NULL); 
		}
	}
	return TRUE;
}

/**************************************************************************************************/
/*** Hinzufügen eine Sektionsfragmenteintrags in die Liste der beim CV 4 zu berücksichtigenden  ***/
/*** Einträge.																																																																																		***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::IncSecFrgEntryForCV(CSectionFragmentEntry *aSecFrg)
{
	CMyMapStringToOb	*aSecFrgLst;
	CMyObList								*aObjList;
	
	char *objFilNam;

	objFilNam= aSecFrg-> secFrgObjFil-> objFilNam;
	
	if (!exeFilSecFrgLst-> Lookup(objFilNam, (CObject *&) aSecFrgLst))
	{
		aSecFrgLst= new CMyMapStringToOb(10);
		aSecFrgLst-> InitHashTable(5, TRUE);
		exeFilSecFrgLst-> SetAt(objFilNam, aSecFrgLst);
		aObjList= new CMyObList(10);
		aSecFrgLst-> SetAt(aSecFrg-> myHomSec-> secNam, aObjList);
	}
	else
	{
		if (!aSecFrgLst-> Lookup(aSecFrg-> myHomSec-> secNam, (CObject *&)aObjList))
		{
			aObjList= new CMyObList(10);
			aSecFrgLst-> SetAt(aSecFrg-> myHomSec-> secNam, aObjList);
		}
	}

	aObjList-> AddTail(aSecFrg);	

	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der MISC Debuginformation																																																								***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::BuildMiscRawDataBlock()
{
 DWORD rawDatMiscSiz= 0x110;
 DWORD miscSig= 0x00000001;
 BYTE  *rawDatBuf;
 LPSTR filNamPtr;

	rawDatMisc= new CMyMemFile();

	rawDatBuf= (BYTE *) malloc(rawDatMiscSiz);
 memset(rawDatBuf, 0x00, rawDatMiscSiz);
	rawDatMisc-> Write(rawDatBuf, rawDatMiscSiz);
	free(rawDatBuf);
	rawDatMisc-> SeekToBegin();
	rawDatMisc-> Write(&miscSig, sizeof(DWORD));
	rawDatMisc-> Write(&rawDatMiscSiz, sizeof(DWORD));
	rawDatMisc-> Seek(sizeof(DWORD), CFile::current);
	filNamPtr= newExeFil-> exeFilNam + strlen(newExeFil-> exeFilNam) - 1;
	while((*(filNamPtr) != 0x5c) || (!(strcmp(filNamPtr, newExeFil-> exeFilNam))))
	 filNamPtr--;
	rawDatMisc-> Write(++filNamPtr, strlen(filNamPtr));
		
	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der FPO Debuginformation																																																									***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::BuildFPORawDataBlock(DWORD virTxtSecAdr)
{
	CSectionFragmentEntry *aSecFrgEnt;
	CObjFileSection						 *relObjFilSec;
	myRelocationEntry					*relEnt;
	mySymbolEntry									*actSym;
	POSITION														frgPos;

	DWORD fpoEntTxtOff;
 DWORD relInd;
	DWORD actFilPos;
	DWORD  fpoEntLen;
	BYTE  *fpoEntBuf;

	rawDatFpo= new CMyMemFile();

	frgPos= debLstF-> GetHeadPosition();

	if (!frgPos) return FALSE;

	while (frgPos)
	{
		relInd= 0;
		aSecFrgEnt= (CSectionFragmentEntry *) debLstF-> GetNext(frgPos);
		aSecFrgEnt-> rawDat-> SeekToBegin();
		while(relInd < aSecFrgEnt-> myHomSec-> actSecTab-> relNum)
		{
			actFilPos= aSecFrgEnt-> rawDat-> GetPosition();
			aSecFrgEnt-> rawDat-> Read(&fpoEntTxtOff, sizeof(DWORD));
			aSecFrgEnt-> rawDat-> Seek(actFilPos, CFile::begin);
			relEnt= (myRelocationEntry *)(aSecFrgEnt-> secFrgRelBuf + REL_ENT_SIZ * relInd++);
			actSym= (mySymbolEntry *)aSecFrgEnt-> secFrgObjFil-> newSymLst[relEnt-> symTabInd];
			relObjFilSec= (CObjFileSection *)aSecFrgEnt-> secFrgObjFil-> secLst-> GetAt(actSym-> actSymTab-> secNum - 1);
			fpoEntTxtOff+= virTxtSecAdr + relObjFilSec-> actFrgEnt-> secFrgOff; // + relEnt-> actRelEnt.off;
			aSecFrgEnt-> rawDat-> Write(&fpoEntTxtOff, sizeof(DWORD));
			aSecFrgEnt-> rawDat-> Seek(0xC, CFile::current);
		}
		fpoEntLen= aSecFrgEnt-> rawDat-> GetLength();
		aSecFrgEnt-> rawDat-> SeekToBegin();
		fpoEntBuf= (BYTE *) aSecFrgEnt-> rawDat-> ReadWithoutMemcpy(fpoEntLen);
		rawDatFpo-> Write(fpoEntBuf, fpoEntLen);
	}
	//WriteRawDataToFile(rawDatFpo);
	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der CV 4 Debuginformation. Für jedes zu erstellende CodeView Modul wird die	für		***/
/*** die Erstellung notwendige Methode aufgerufen, die erhaltenen Daten zu den bereits vor-     ***/
/*** handenen hinzugefügt und das CV Subsection Directory entsprechend angepaßt.																***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::BuildCVRawDataBlock(CMyMapStringToOb *dllImpLstLst, CMyObList *obFilLst)
{
	mySubsectionDirectoryHeader subSecDirHdr;
 mySubsectionDirectoryEntry  subSecDirEnt;
	
	CMyMemFile *rawDatCVsstMod;
	CMyMemFile *rawDatCVsstAlnSym;
 CMyMemFile *rawDatCVsstSrcMod;
 CMyMemFile *rawDatCVsstGlbSym;
	CMyMemFile *rawDatCVsstGlbPub;
 CMyMemFile *rawDatCVsstLib;
 CMyMemFile *rawDatCVsstGlbTyp;
 CMyMemFile *rawDatCVsstSegMap;
 CMyMemFile *rawDatCVsstFilInd;
 CMyMemFile *rawDatCVsstStaSym;
 
	CMyMapStringToOb		*actDllImpLst;	
	CDllExportEntry			*actDllExpEnt;
	CObjFile										*actObjFil;
	
 POSITION   objFilLstPos;
	POSITION			dllExpLstPos;
	POSITION			dllLstEntPos;
 
	WORD       sstAlnSymInd= 0x0000;

 DWORD cVDirOff= 0x00;
 DWORD subSecDirEntNum= 0;
	char		*dllNam;
	char		*dllEntNam;
 char 	*cVSig40= "NB09";
	char		*cVSig50=	"NB11";
 BYTE  *datBuf;

	WORD		bldCVMod;


	bldCVMod= CV_MOD_120 +	
											CV_MOD_125	+
											CV_MOD_127	+	
											CV_MOD_128	+	
											CV_MOD_129	+
											CV_MOD_12A	+		
											CV_MOD_12B	+	
											CV_MOD_12D	+	
											CV_MOD_133	+	
											CV_MOD_134;		

 /***** Erstellen und Zusammensetzen der einzelnen CV Debugmodule *****/

 rawDatCV= new CMyMemFile();
 memset(&subSecDirHdr, 0x00, CV_SUB_SEC_DIR_HDR_SIZ);
 memset(&subSecDirEnt, 0x00, CV_SUB_SEC_DIR_ENT_SIZ);

 /*************/
	/*** 0x120 ***/
	/*************/

	if (bldCVMod & CV_MOD_120)
	{
		rawDatCVsstMod= BuildCVsstModule(obFilLst, newExeFil, dllImpLstLst); 
		rawDatCVsstMod-> SeekToBegin(); 
		datBuf= (BYTE *) rawDatCVsstMod-> ReadWithoutMemcpy(rawDatCVsstMod-> GetLength());
		rawDatCV-> Write(datBuf, rawDatCVsstMod-> GetLength());
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
			WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x120", NULL); 
		FreeCMyMemFile(rawDatCVsstMod);
		delete rawDatCVsstMod;

		subSecDirEntNum= (subSecDirCV-> GetLength() - CV_SUB_SEC_DIR_HDR_SIZ) / CV_SUB_SEC_DIR_ENT_SIZ;
	}

	/*******************************************************/
 /*** 0x125 && 0x127 für .obj Files aus Objektdateien ***/
	/*******************************************************/
	
	if ((bldCVMod & CV_MOD_125) || (bldCVMod & CV_MOD_127))
	{
		objFilLstPos= obFilLst-> GetHeadPosition();
		while(objFilLstPos)
		{																																		
		 actObjFil= (CObjFile *)obFilLst-> GetNext(objFilLstPos);

			if (!actObjFil-> libObjFil)
			{
				/*-------*/
				/* 0x125 */
				/*-------*/
	 	
				if (bldCVMod & CV_MOD_125)
				{
					rawDatCVsstAlnSym= BuildCVsstAlignSym(actObjFil); 	
					if (rawDatCVsstAlnSym)
					{
						AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstAlnSym, subSecDirCV, 0x0125, actObjFil-> cvModInd);
						subSecDirEntNum++;
						if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
						 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x125", NULL); 
					}
				}

				/*-------*/
				/* 0x127 */
				/*-------*/

				if (bldCVMod & CV_MOD_127)
				{
					if (!actObjFil-> incDllFun)
					{
						rawDatCVsstSrcMod= BuildCVsstSrcModule(actObjFil);
						if (rawDatCVsstSrcMod)
						{
							AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstSrcMod, subSecDirCV, 0x0127, actObjFil-> cvModInd);
							subSecDirEntNum++;
							if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
							 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x127", NULL); 
						}			
					}
				}
			}
		}
 }

	/***************************************/
	/*** 0x125 für Funktionen aus DLL' s ***/
	/***************************************/

	if (bldCVMod & CV_MOD_125)
	{
		dllExpLstPos= dllImpLstLst-> GetStartPosition();
		while(dllExpLstPos)
		{
		 dllImpLstLst-> GetNextAssoc(dllExpLstPos, dllNam, (CObject *&) actDllImpLst);
		
			dllLstEntPos= actDllImpLst-> GetStartPosition();
  
			while(dllLstEntPos)						 
			{
				actDllImpLst-> GetNextAssoc(dllLstEntPos, dllEntNam, (CObject *&) actDllExpEnt);
			
				rawDatCVsstAlnSym= BuildCVsstAlignSym(actDllExpEnt-> dllObjFil); 	
				if (rawDatCVsstAlnSym)
				{
					AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstAlnSym, subSecDirCV, 0x0125,  actDllExpEnt-> dllObjFil-> cvModInd);
					subSecDirEntNum++;
					if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
					 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x125", NULL); 
					}
			}
		}
	}
	
	/************************************************************/
 /*** 0x125 && 0x127 für .obj Files aus den Librarymodulen ***/
	/************************************************************/
	
	if ((bldCVMod & CV_MOD_125) && (bldCVMod & CV_MOD_127))
	{
		objFilLstPos= obFilLst-> GetHeadPosition();
		while(objFilLstPos)
		{																																		
		 char *filExt;

			actObjFil= (CObjFile *)obFilLst-> GetNext(objFilLstPos);
			
			filExt= _strupr(&actObjFil-> objFilNam[strlen(actObjFil-> objFilNam) - 3]);

			if (bldCVMod & CV_MOD_125)
			{
				if (actObjFil-> libObjFil && !actObjFil-> incDllFun && (strcmp(filExt, "DLL") != 0))
				{
					/*-------*/
					/* 0x125 */
					/*-------*/
									
					rawDatCVsstAlnSym= BuildCVsstAlignSym(actObjFil); 	
					if (rawDatCVsstAlnSym)
					{
						AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstAlnSym, subSecDirCV, 0x0125, actObjFil-> cvModInd);
						subSecDirEntNum++;
						if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
							WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x125", NULL); 
					}					
				}
			}
				
			/*-------*/
			/* 0x127 */
			/*-------*/
			
			if (bldCVMod & CV_MOD_127 && (strcmp(filExt, "DLL") != 0))
			{
				if (actObjFil-> linNmbInc && actObjFil-> libObjFil)
				{
					rawDatCVsstSrcMod= BuildCVsstSrcModule(actObjFil);
					if (rawDatCVsstSrcMod)
					{
						AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstSrcMod, subSecDirCV, 0x0127, actObjFil-> cvModInd);
						subSecDirEntNum++;
						if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
						 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x127", NULL); 
					}			
					else 
						actObjFil-> insSstFilInd= FALSE;		
				}
				else
					actObjFil-> insSstFilInd= FALSE;		
			}
			
		}
 }
	

	/************************************************************************************/

	/*************/
	/*** 0x12A ***/
	/*************/
	if (bldCVMod & CV_MOD_12A)
	{
		rawDatCVsstGlbPub= BuildCVsstGlobalPub(obFilLst);
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstGlbPub, subSecDirCV, 0x012A, 0xFFFF);
		subSecDirEntNum++;
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
		 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x12A", NULL); 
		
	}

	/*-----------*/
 /*-- 0x129 --*/
	/*-----------*/

	if (bldCVMod & CV_MOD_129)
	{
		rawDatCVsstGlbSym= BuildCVsstGlobalSym();
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstGlbSym, subSecDirCV, 0x0129, 0xFFFF);
		subSecDirEntNum++;
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
		 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x129", NULL); 
	}

	/*-----------*/
 /*-- 0x134 --*/
	/*-----------*/

	if (bldCVMod & CV_MOD_134)
	{
		rawDatCVsstStaSym= BuildCVsstStaSym();
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstStaSym, subSecDirCV, 0x0134, 0xFFFF);
		subSecDirEntNum++;
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
		 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x134", NULL); 
	}
 
	/*-----------*/
 /*-- 0x128 --*/
	/*-----------*/

	if (bldCVMod & CV_MOD_128)
	{
		rawDatCVsstLib= BuildCVsstLibraries();
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstLib, subSecDirCV, 0x0128, 0xFFFF);
		subSecDirEntNum++;
	}
		
	/*-----------*/
 /*-- 0x12B --*/
	/*-----------*/
	if (bldCVMod & CV_MOD_12B)
	{
		rawDatCVsstGlbTyp= BuildCVsstGlobalTypes();
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstGlbTyp, subSecDirCV, 0x012B, 0xFFFF);
		subSecDirEntNum++;
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
		 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x12B", NULL); 
	}

	/*-----------*/
 /*-- 0x12D --*/
	/*-----------*/

	if (bldCVMod & CV_MOD_12D)
	{
	 rawDatCVsstSegMap= BuildCVsstSegMap();
	 AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstSegMap, subSecDirCV, 0x012D, 0xFFFF);
	 subSecDirEntNum++;
	 if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
	  WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x12D", NULL); 
	}
		
	/*************/
 /*** 0x133 ***/
	/*************/

	if (bldCVMod & CV_MOD_133)
	{
		rawDatCVsstFilInd= BuildCVsstFileIndex(obFilLst);
		AppandCVModAndDirectoryToCVModule(rawDatCV, rawDatCVsstFilInd, subSecDirCV, 0x0133, 0xFFFF);
		subSecDirEntNum++;
		if (BytesTillAlignEnd(rawDatCV-> GetLength(), sizeof(DWORD)))
		 WriteMessageToPow(WRN_MSGD_WRO_ALN, "0x133", NULL); 
	}

	/*** Initialisieren der Header und Schreiben der Rohdaten ***/
 
 cVDirOff= rawDatCV-> GetPosition();
 rawDatCV-> Seek(0x04, CFile::begin);
 rawDatCV-> Write(&cVDirOff, sizeof(DWORD));
 rawDatCV-> Seek(cVDirOff, CFile::begin);

 subSecDirCV-> Seek(sizeof(DWORD), CFile::begin);
 subSecDirCV-> Write(&subSecDirEntNum, sizeof(DWORD));
 subSecDirCV-> SeekToBegin();                                
 datBuf= (BYTE *) subSecDirCV-> ReadWithoutMemcpy(subSecDirCV-> GetLength());
 rawDatCV-> Write(datBuf, subSecDirCV-> GetLength());

 cVDirOff= rawDatCV-> GetPosition() + 2 * sizeof(DWORD); 
	if (verSgnCV == VER_SGN_CV4)
		rawDatCV-> Write(cVSig40, strlen(cVSig40));
	else
		rawDatCV-> Write(cVSig50, strlen(cVSig50));
 rawDatCV-> Write(&cVDirOff, sizeof(DWORD));
 

 FreeCMyMemFile(subSecDirCV);
 delete subSecDirCV;
 subSecDirCV= NULL;

	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der COFF Debuginformationen																																																						***/
/**************************************************************************************************/

BOOL  CExeFileDebugSection::BuildCofRawDataBlock(DWORD virTxtSecAdr)
{
		// Nicht implementiert

	virTxtSecAdr= virTxtSecAdr;	// Verhindert Compiler Warning

	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::BuildSecRawDataBlockParts(CMyMapStringToOb *actUnSorLst, CMyStringList *namLst)
{
	// Wird hier nicht benötigt, deshalb überschrieben

	actUnSorLst= actUnSorLst;	// Verhindert Compiler Warning
	namLst= namLst;											// Verhindert Compilerwarning

	return TRUE;
}	

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::BuildSecRawDataBlock()
{
	// Wird hier nicht benötigt, deshalb überschrieben	
	return TRUE;
}

/**************************************************************************************************/
/*** Hinzufügen der Debuginformationen an die PE-Datei und Schreiben des Debugdirectories in    ***/
/*** die .RDATA Sektion der PE-Datei.																																																											***/
/**************************************************************************************************/

BOOL CExeFileDebugSection::GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAln)
{
 myDebugDirectory aDbgDir;
	WORD													dbgDirEnt;

 BYTE *datBuf;
 
	fAln= fAln;
	dbgDirEnt= 0;

 /***** Misc Debug Information *****/

	if (bldMisc)
	{
		memset(&aDbgDir, 0x00, sizeof(myDebugDirectory));
		aDbgDir.timDatStp= CalcTimeDateStamp();
		aDbgDir.dbgTyp= 0x04; 
		aDbgDir.datSiz= rawDatMisc-> GetLength();
		aDbgDir.rawDatPtr= exeFilRawDat-> GetPosition();
		dbgDirRawDat-> Write(&aDbgDir, sizeof(myDebugDirectory));

		rawDatMisc-> SeekToBegin();                                                                 
		datBuf= (BYTE *) rawDatMisc-> ReadWithoutMemcpy(aDbgDir.datSiz);
		exeFilRawDat-> Write(datBuf, aDbgDir.datSiz);
		FreeCMyMemFile(rawDatMisc);
		delete rawDatMisc;
		rawDatMisc= NULL;
		dbgDirEnt++;
 }

 /***** FPO Debug Information *****/
	
	if (bldFPO)
	{
		aDbgDir.dbgTyp= 0x03; 
		aDbgDir.datSiz= rawDatFpo-> GetLength();
		aDbgDir.rawDatPtr= exeFilRawDat-> GetPosition();
		dbgDirRawDat-> Write(&aDbgDir, sizeof(myDebugDirectory));
		
		rawDatFpo-> SeekToBegin();                                                                 
		datBuf= (BYTE *) rawDatFpo-> ReadWithoutMemcpy(aDbgDir.datSiz);
		exeFilRawDat-> Write(datBuf, aDbgDir.datSiz);
		FreeCMyMemFile(rawDatFpo);
		delete rawDatFpo;
		rawDatFpo= NULL;
		dbgDirEnt++;
 }	
		
 /***** CV Debug Information *****/
	
	if (bldCV)
	{
		aDbgDir.dbgTyp= 0x02; 
		aDbgDir.datSiz= rawDatCV-> GetLength();
		aDbgDir.rawDatPtr= exeFilRawDat-> GetPosition();
		dbgDirRawDat-> Write(&aDbgDir, sizeof(myDebugDirectory));
		
		rawDatCV-> SeekToBegin();                                                                 
		datBuf= (BYTE *) rawDatCV-> ReadWithoutMemcpy(aDbgDir.datSiz);
		exeFilRawDat-> Write(datBuf, aDbgDir.datSiz);
		FreeCMyMemFile(rawDatCV);
		delete rawDatCV;
		rawDatCV= NULL;
		dbgDirEnt++;
	}

 /***** Schreiben des Debugdirectories in der .rdata Sektion *****/

 dbgDirRawDat-> SeekToBegin();
 datBuf= (BYTE *) dbgDirRawDat-> ReadWithoutMemcpy(sizeof(myDebugDirectory) * dbgDirEnt);  
 exeFilRawDat-> Seek(newExeFil-> rdataSec-> actSecTab-> rawDatPtr, CFile::begin);
 exeFilRawDat-> Write(datBuf, sizeof(myDebugDirectory) * dbgDirEnt);

	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::ResRel(CDWordArray *relLst, DWORD	imBas)
{
	// Wird hier nicht benötigt, deshalb überschrieben	#
	relLst= relLst; // Verhindert Compilerwarning
	imBas= imBas;			// Verhindert Compilerwarning

	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen des CV sstModules (0x120) **********************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstModule(CMyObList *obFilLst, CExeFile *actExeFil, CMyMapStringToOb *dllImpLstLst)
{
	CExeFileTextSection			*actTxtSec;
 CExeFileDataSection			*actDatSec;
	CExeFileImportSection *actImpSec;

	mySubsectionDirectoryEntry 	subDirEnt;
	mySstModule																	sstModEnt;
	mySstModuleSegInfo										sstModEntSegInf;
			
	CSectionFragmentEntry *actSecFrgEnt;
	CDllExportEntry							*actDllExpEnt;
	CDllExportEntry							*actSpeDllExpEnt;
	
	CObjFile														*actObjFil;
	CObjFile														*hndObjFil;
		
	CMyMapStringToOb						*actDllExpLst;
	CMyMapStringToOb						*secFrgEntLst;
	CMyObList													*secFrgObjLst;
 
	CMyMemFile												*rawDatCVsstMod;
	LPCTSTR															dllEntNam;
	LPCTSTR															dllNam;

	POSITION secEntPos;
	POSITION secFrgObjPos;
	
	POSITION objFilLstPos;
	POSITION dllLstPos;
	POSITION dllLstEntPos;

	BOOL		sstModEntWritten;
	BOOL		speDllEntWritten;
	BOOL		nulTnkDatWritten;

	DWORD	dirOff= 0x0000;
	WORD  modInd= 0x0000;
	BYTE		filNamLen;
	WORD		hndLibObjFilInd;
	char 	*cVSig40= "NB09";
	char  *cVSig50= "NB11";
	char  *oldFilNam= "";

	char 		*impDes= "__IMPORT_DESCRIPTOR_";									// Spezielle .idata Einträge
	char 		*nulImpDes= "__NULL_IMPORT_DESCRIPTOR";
	char 		*nulTnkDat= "_NULL_THUNK_DATA";

	char		*secEntNam;


	actTxtSec= actExeFil-> textSec;
	actDatSec= actExeFil-> dataSec;
	actImpSec= actExeFil-> idataSec;
	
	rawDatCVsstMod= new CMyMemFile();
	subSecDirCV= new CMyMemFile();
	
	/*************************************************************************************/
	/*                    Erstellen der sstModule Information                            */
	/*************************************************************************************/
	
	subDirHdr.dirHdrLen= 0x0010;
	subDirHdr.dirEntLen= 0x000C;
	subDirHdr.nxtDirOff= 0x0000;
	subDirHdr.flg= 0x0000;

	subDirEnt.subDirInd= 0x0120; // (0x120 == sstModule)
	subDirEnt.modInd= 0x0000;
	
	sstModEnt.ovlNum= 0x0000;
	sstModEnt.sty= 0x5643; // => "CV"

	sstModEntSegInf.pad= 0;

	if (verSgnCV == VER_SGN_CV4)
		rawDatCVsstMod-> Write(cVSig40, sizeof(DWORD));
	else
		rawDatCVsstMod-> Write(cVSig50, sizeof(DWORD));

	rawDatCVsstMod-> Write(&dirOff, sizeof(DWORD));

	subSecDirCV-> Write(&subDirHdr, 0x10);

	for(hndLibObjFilInd= 0; hndLibObjFilInd < 2; hndLibObjFilInd++)
	{
		objFilLstPos= obFilLst-> GetHeadPosition();
	
		while(objFilLstPos)
		{
			actObjFil= (CObjFile *)obFilLst-> GetNext(objFilLstPos);
			hndObjFil= NULL;

			if (!actObjFil-> libObjFil && !hndLibObjFilInd)
				hndObjFil= actObjFil;
			else
			{
				if(actObjFil-> libObjFil && hndLibObjFilInd)
					hndObjFil= actObjFil;
			}
			
			if (hndObjFil)
			{
				if (exeFilSecFrgLst-> Lookup(hndObjFil-> objFilNam, (CObject *&) secFrgEntLst))
				{
					sstModEnt.conCodSegNum= 0;
					
					// Bestimmen der Anzahl der sstModule SegInfo Einträge
			
					sstModEnt.conCodSegNum= 0;
					secEntPos= secFrgEntLst-> GetStartPosition();
			
					while(secEntPos)
					{
						secFrgEntLst-> GetNextAssoc(secEntPos, secEntNam, (CObject *&) secFrgObjLst);			
				
						// Die Einträge der .text Sektion werden zu einem Block zusammengefaßt, während bei 
						// Einträgen der Datensektionen für jeden Objektmodulblock ein Eintrag erstellt wird.
								
						if (!strcmp(secEntNam, ".text"))
							sstModEnt.conCodSegNum++;
						else
							sstModEnt.conCodSegNum+= secFrgObjLst-> GetCount();
					}
			
					// Bestimmen der sstModul SegInfo Eintragsdaten

					secEntPos= secFrgEntLst-> GetStartPosition();
					sstModEntWritten= FALSE;
		
					while(secEntPos)
					{
						secFrgEntLst-> GetNextAssoc(secEntPos, secEntNam, (CObject *&) secFrgObjLst);						
		
						// Annahme: Es muß immer zumindest ein Element in der Liste sein.
				
						secFrgObjPos= secFrgObjLst-> GetHeadPosition();
						actSecFrgEnt= (CSectionFragmentEntry *) secFrgObjLst-> GetAt(secFrgObjPos);

						// Die Einträge der .text Sektion werden zu einem Block zusammengefaßt, während bei 
						// Einträgen der Datensektionen für jeden Objektmodulblock ein Eintrag erstellt wird.
								
						if (!sstModEntWritten)
						{
							subDirEnt.entOff= rawDatCVsstMod-> GetPosition();				
							sstModEnt.sstLibSubSecInd= actSecFrgEnt-> secFrgObjFil-> libFilInd;
							rawDatCVsstMod-> Write(&sstModEnt, sizeof(mySstModule));
							sstModEntWritten= TRUE;
						}

						while(secFrgObjPos)
						{
							actSecFrgEnt= (CSectionFragmentEntry *) secFrgObjLst-> GetNext(secFrgObjPos);
							sstModEntSegInf.seg= actSecFrgEnt-> actExeSec-> secNum;
							sstModEntSegInf.codOff= actSecFrgEnt-> secFrgOff;
							sstModEntSegInf.codLen= actSecFrgEnt-> rawDatSiz + BytesTillAlignEnd(actSecFrgEnt-> rawDatSiz, actSecFrgEnt-> secFrgAln);
					
							if (!strcmp(secEntNam, ".text"))
							{
								while(secFrgObjPos)
								{
									actSecFrgEnt= (CSectionFragmentEntry *) secFrgObjLst-> GetNext(secFrgObjPos);
									sstModEntSegInf.codLen+= actSecFrgEnt-> rawDatSiz + BytesTillAlignEnd(actSecFrgEnt-> rawDatSiz, actSecFrgEnt-> secFrgAln);
								}
							}
					
							rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));
						}
					}

					filNamLen= (BYTE )strlen(hndObjFil-> objFilNam);
					rawDatCVsstMod-> Write(&filNamLen, sizeof(BYTE));
					rawDatCVsstMod-> Write(hndObjFil-> objFilNam, filNamLen);
			
					subDirEnt.bytNum= rawDatCVsstMod-> GetLength() - subDirEnt.entOff;
			
					if (BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)))
						rawDatCVsstMod-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)));

					actSecFrgEnt-> secFrgObjFil-> cvModInd= ++subDirEnt.modInd;
					subSecDirCV-> Write(&subDirEnt, 0x0C);
					subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
				}
			}
		}		
	
		if (!objFilLstPos && !hndLibObjFilInd)
		{
 
		/***************************************************/
		/**************** D L L - Einträge *****************/
		/***************************************************/

			// Einfügen der IMPORT_DESCRIPTOREN und NULL_THUNK_DATA
	
			nulTnkDatWritten= FALSE;
	
			dllLstPos= dllImpLstLst-> GetStartPosition();
			while(dllLstPos)
			{
				speDllEntWritten= FALSE;
				dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
				filNamLen= (BYTE )strlen(dllNam);
				dllLstEntPos= actDllExpLst-> GetStartPosition();
				while(dllLstEntPos)
				{
					subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
			
					actDllExpLst-> GetNextAssoc(dllLstEntPos, dllEntNam, (CObject *&)actDllExpEnt);

					if (!speDllEntWritten)
					{
						sstModEnt.sstLibSubSecInd= actDllExpEnt-> dllObjFil-> libFilInd;
						sstModEnt.conCodSegNum= 0x0002;
						rawDatCVsstMod-> Write(&sstModEnt, sizeof(mySstModule));
								
						// Null Thunk Data Einträge der DLL
				
						char *symSrhNam= (char *) malloc (strlen(dllNam) + strlen(nulTnkDat));
						memset(symSrhNam, '\0', strlen(dllNam) + strlen(nulTnkDat));
						symSrhNam[0]= '';
						symSrhNam= strncat(symSrhNam, dllNam, strlen(dllNam) - 4);
						symSrhNam= strcat(symSrhNam, nulTnkDat);

						if (actImpSec-> speDllEntLst-> Lookup(symSrhNam, (CObject *&)actSpeDllExpEnt))
						{
							// Null Thunk Data Eintrag im Import Lookup Table
							sstModEntSegInf.seg= actImpSec-> secNum;
							sstModEntSegInf.codOff= actSpeDllExpEnt-> impLokUpTabOff;
							sstModEntSegInf.codLen= actSpeDllExpEnt-> namTabEntLen;
							rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

							// Null Thunk Data Eintrag im Import Address Table
							sstModEntSegInf.codOff= actSpeDllExpEnt-> impAdrTabOff;
							sstModEntSegInf.codLen= actSpeDllExpEnt-> namTabEntLen;
							rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));
			
							rawDatCVsstMod-> Write(&filNamLen, sizeof(BYTE));
							rawDatCVsstMod-> Write(dllNam, filNamLen);
			
							subDirEnt.bytNum= rawDatCVsstMod-> GetLength() - subDirEnt.entOff;
			
							if (BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)))
								rawDatCVsstMod-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)));

							actDllExpEnt-> dllObjFil-> cvModInd= ++subDirEnt.modInd;
							subSecDirCV-> Write(&subDirEnt, 0x0C);
							subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
						}
		
						free(symSrhNam);
				
						// Allgemeinen Null Thunk Data Eintrag hinzufügen

						if (!nulTnkDatWritten)
						{
							sstModEnt.sstLibSubSecInd= actDllExpEnt-> dllObjFil-> libFilInd;
							sstModEnt.conCodSegNum= 0x0001;
							rawDatCVsstMod-> Write(&sstModEnt, sizeof(mySstModule));
						
							if (actImpSec-> speDllEntLst-> Lookup(nulImpDes, (CObject *&)actSpeDllExpEnt))
							{
								sstModEntSegInf.seg= actImpSec-> secNum;
								sstModEntSegInf.codOff= actSpeDllExpEnt-> impLokUpTabOff;
								sstModEntSegInf.codLen= actSpeDllExpEnt-> impAdrTabOff;
								rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

								rawDatCVsstMod-> Write(&filNamLen, sizeof(BYTE));
								rawDatCVsstMod-> Write(dllNam, filNamLen);
											
								subDirEnt.bytNum= rawDatCVsstMod-> GetLength() - subDirEnt.entOff;
			
								if (BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)))
										rawDatCVsstMod-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)));
										
								actDllExpEnt-> dllObjFil-> cvModInd= ++subDirEnt.modInd;
								subSecDirCV-> Write(&subDirEnt, 0x0C);
								subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
								nulTnkDatWritten= TRUE;
							}
						}
		
						// DLL Null Import Descriptor + DLL Name

						sstModEnt.sstLibSubSecInd= actDllExpEnt-> dllObjFil-> libFilInd;
						sstModEnt.conCodSegNum= 0x0002;
						rawDatCVsstMod-> Write(&sstModEnt, sizeof(mySstModule));
				
						symSrhNam= (char *) malloc (strlen(dllNam) + strlen(impDes));
						memset(symSrhNam, '\0', strlen(dllNam) + strlen(impDes));
						symSrhNam= strcat(symSrhNam, impDes);
						symSrhNam= strncat(symSrhNam, dllNam, strlen(dllNam) - 4);

						if (actImpSec-> speDllEntLst-> Lookup(symSrhNam, (CObject *&)actSpeDllExpEnt))
						{
							// Null Import Descriptor Eintrag
							sstModEntSegInf.seg= actImpSec-> secNum;
							sstModEntSegInf.codOff= actSpeDllExpEnt-> impLokUpTabOff;
							sstModEntSegInf.codLen= actSpeDllExpEnt-> impAdrTabOff;
							rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

							// DLL Name
							sstModEntSegInf.codOff= actSpeDllExpEnt-> namTabEntOff;
							sstModEntSegInf.codLen= actSpeDllExpEnt-> namTabEntLen;
							rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));
			
							rawDatCVsstMod-> Write(&filNamLen, sizeof(BYTE));
							rawDatCVsstMod-> Write(dllNam, filNamLen);
			
							subDirEnt.bytNum= rawDatCVsstMod-> GetLength() - subDirEnt.entOff;
			
							if (BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)))
								rawDatCVsstMod-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)));

							actDllExpEnt-> dllObjFil-> cvModInd= ++subDirEnt.modInd;
							subSecDirCV-> Write(&subDirEnt, 0x0C);
							subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
						}

						free(symSrhNam);
				
						speDllEntWritten= TRUE;
						
					}
			
					// Alle ab jetzt behandelten Einträge besitzen SegInfo Records für die DLL Forwarder-Chain
					// in der	.TEXT-Sektion, dem Import Lookup Table dem Import Adress Table und dem Hint/
					// Name Table.

					sstModEnt.conCodSegNum= 0x0004;
					rawDatCVsstMod-> Write(&sstModEnt, sizeof(mySstModule));

					//	DLL Forwarder-Chain Eintrag der .TEXT-Sektion

					sstModEntSegInf.seg= actTxtSec-> secNum;
					sstModEntSegInf.codOff= actDllExpEnt-> textSegOff - actTxtSec-> virSecAdr;
					sstModEntSegInf.codLen= 0x0006;
					rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

					//	DLL Import Lookup Table

					sstModEntSegInf.seg= (WORD )actDllExpEnt-> idataExeSecNum;
					sstModEntSegInf.codOff= actDllExpEnt-> impLokUpTabOff;
					sstModEntSegInf.codLen= 0x0004;
					rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

					// DLL Import Address Table

					sstModEntSegInf.codOff= actDllExpEnt-> impAdrTabOff;
					rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

					// DLL Hint/Name Table

					sstModEntSegInf.codOff= actDllExpEnt-> namTabEntOff;
					sstModEntSegInf.codLen= actDllExpEnt-> namTabEntLen;
					rawDatCVsstMod-> Write(&sstModEntSegInf, sizeof(mySstModuleSegInfo));

			
					rawDatCVsstMod-> Write(&filNamLen, sizeof(BYTE));
					rawDatCVsstMod-> Write(dllNam, filNamLen);
			
					subDirEnt.bytNum= rawDatCVsstMod-> GetLength() - subDirEnt.entOff;
			
					if (BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)))
						rawDatCVsstMod-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstMod-> GetPosition(), sizeof(DWORD)));

					actDllExpEnt-> dllObjFil-> cvModInd= ++subDirEnt.modInd;
					subSecDirCV-> Write(&subDirEnt, 0x0C);
					subDirEnt.entOff= rawDatCVsstMod-> GetPosition();
				}
			}
		}
	}
 
	return rawDatCVsstMod;
	
}

/**************************************************************************************************/
/*** Erstellen des CV sstAlign Sym Moduls (0x125) *************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstAlignSym(CObjFile *aObjFil)
{
 CObjFileSection       *actDebObjFilSecS;
	CObjFileSection							*actRelDbgSec;
	CSectionFragmentEntry *actDebSecS;
	mySymbolEntry									*relSymEnt;
	myRelocationEntry					*actOffRel;
	myRelocationEntry					*actSecRel;
	
	CMyMemFile *rawDatSstAlnSym;
	CMyMemFile *retRawDatSstAlnSym;
	CMyMemFile	*rawDatSecS;
	CMyMemFile	*rawDatSecT;
	CMyMemFile *usrDefTypBuf;
 CMyMemFile *usrDefAdrSrtTabBuf;

	mySstGloTypInfRec	*aSstGloTypInf;
	CPtrArray									*objFilTypArr;
	DWORD													objFilTypInd;	
	WORD														sstGloTypSymLen;
	
 myProcedureReference prcRef;
	myProcedureStartCV4  gloPrcSrtCV4;
	myProcedureStartCV5		gloPrcSrtCV5;
	mySymbolRecord  	    symRecHdr;
	
	DWORD relEntInd;
	DWORD verSgn;
 DWORD staScpFilPos[MAX_SCOPE_LEVEL];
	DWORD staScpFilOff[MAX_SCOPE_LEVEL];
	DWORD nxtScpFilPos[MAX_SCOPE_LEVEL];
 DWORD endScpFilPos[MAX_SCOPE_LEVEL];
	DWORD actScpOff;
	DWORD fstStaSrhSymOff= 0;
	DWORD lstNxtScpFilPos;
	DWORD symTypDW;

	DWORD actFilPos= 0;
	DWORD actRawDatPos;
 DWORD adrSrtTabActOff= 0;
 DWORD adrSrtTabActFilPos= 0;
	DWORD bytBufLen;
	WORD		staSrhSec;
	WORD  bytTilAln;
 WORD  refLen;
	WORD		scpLev;
	WORD		symTypW;

	BYTE  *bytBuf;
	BYTE  *namBuf;

 POSITION      usrDefNamPos;
	BOOL										chkVerSgn;
	BOOL										retMemFil;
	BOOL										insStrSrc;
	BOOL										chgDbgFor;
	char          *usrDefNam;
 BYTE          usrDefNamLen;
	BYTE										msgBuf[256];

	int i;

	chkVerSgn= TRUE;
	insStrSrc= FALSE;
	retMemFil= FALSE;
	actRawDatPos= 0;
	rawDatSstAlnSym= new CMyMemFile();

	/*** Überprüfen welches Debugformat (CV40/CV50) vorhanden ist ***/

	chgDbgFor= FALSE;
	rawDatSecT= NULL;

	if (aObjFil-> dbgTSec)  // Wenn .debug$T Sektion vorhanden -> Versionsflag überprüfen
	{
		if (aObjFil-> dbgTSec-> actSecTab-> rawDatSiz > 0x0004)
		{
			rawDatSecT= aObjFil-> dbgTSec-> actFrgEnt-> rawDat;
			rawDatSecT-> SeekToBegin();
			rawDatSecT-> Read(&verSgn, sizeof(DWORD));

			if (verSgn != verSgnCV)
				chgDbgFor= TRUE;
		}
	}
	else		// Wenn .debug$S Sektion vorhanden -> Versionsflag überprüfen
	{
		i= 0;
		while(i < aObjFil-> objCofHdr.secNum)
		{
			actDebObjFilSecS= (CObjFileSection *) aObjFil-> secLst-> GetAt(i);
			if (!strcmp(actDebObjFilSecS-> secNam, ".debug$S"))
			{
				rawDatSecS= actDebObjFilSecS-> actFrgEnt-> rawDat;
				rawDatSecS-> Read(&verSgn, sizeof(DWORD));
				if (verSgn != verSgnCV)
					chgDbgFor= TRUE;

				i= aObjFil-> objCofHdr.secNum;
			}
			i++;
		}
	}

	if (chgDbgFor)		// Ändern des vorhandenen Debugformats
	{
		if (aObjFil-> dbgTSec)  // Wenn .debug$T Sektion vorhanden -> Format ändern
		{
			if (aObjFil-> dbgTSec-> actSecTab-> rawDatSiz > 0x0004)
			{
				if (verSgnCV ==	VER_SGN_CV4)
				{
					if (wrtCV5ToCV4Msg)
					{
						WriteMessageToPow(WRN_MSGD_CHG_VC5_TO_CV4, NULL, NULL);
						wrtCV5ToCV4Msg= FALSE;
					}
					rawDatSecT= ChgDbgForSecTToCV4(aObjFil-> dbgTSec-> actFrgEnt-> rawDat);
				}
				else
				{
					if (wrtCV4ToCV5Msg)
					{
						WriteMessageToPow(WRN_MSGD_CHG_VC4_TO_CV5, NULL, NULL);
						wrtCV4ToCV5Msg= FALSE;
					}
					rawDatSecT= ChgDbgForSecTToCV5(aObjFil-> dbgTSec-> actFrgEnt-> rawDat);
					chgDbgTSecLst-> AddTail(rawDatSecT);
				}
			}
		}
	}

	/*** Einlesen der Typinformationen der Objektdatei ***/

	objFilTypArr= new CPtrArray();
	objFilTypArr-> SetSize(0x40, 0x20);
	objFilTypInd= 0;	
	
	
	if (rawDatSecT)
	{
		rawDatSecT-> SeekToBegin();
		rawDatSecT-> Read(&verSgn, sizeof(DWORD));

		if (verSgn == VER_SGN_CV4 || verSgn == VER_SGN_CV5)
		{    
			while(rawDatSecT-> Read(&sstGloTypSymLen, sizeof(WORD)))
			{
				aSstGloTypInf= (mySstGloTypInfRec *) malloc(sizeof(mySstGloTypInfRec));
				aSstGloTypInf-> symLen= sstGloTypSymLen;
				aSstGloTypInf-> typRefNmb= 0x0;
				aSstGloTypInf-> typRawDat= (BYTE *) rawDatSecT-> ReadWithoutMemcpy(sstGloTypSymLen);
				aSstGloTypInf-> sstGloTypInd= 0xFFFFFFFF;

				objFilTypArr-> SetAtGrow(objFilTypInd, aSstGloTypInf);
				objFilTypInd++;
			}

			/*** Neuzuordnung der Typindizes der selbstdefinierten Typen ***/

			rawDatSecT-> SeekToBegin();
			rawDatSecT-> Read(&verSgn, sizeof(DWORD));

			while(rawDatSecT-> Read(&symRecHdr, sizeof(mySymbolRecord)))
			{
				actRawDatPos= rawDatSecT-> GetPosition();
				
				if (verSgn == VER_SGN_CV4)
					CalculateTypeIndizes40(symRecHdr.symTyp, symRecHdr.recLen, rawDatSecT, (WORD )objFilTypInd, objFilTypArr, aObjFil);
				else
					CalculateTypeIndizes50(symRecHdr.symTyp, symRecHdr.recLen, rawDatSecT, objFilTypInd, objFilTypArr, aObjFil);

				rawDatSecT-> Seek(actRawDatPos + symRecHdr.recLen - sizeof(WORD), CFile::begin);
			}
		}
	}

	if (!aObjFil-> sstGloTypRawDat)
		aObjFil-> sstGloTypRawDat= new CMyMemFile();

	/* Initialisieren des Start Search Records - Nicht bei Funktionen aus DLL' s */
	
	rawDatSstAlnSym-> Write(&verSgn, sizeof(DWORD));
	
	scpLev= 0;

	memset(&staScpFilPos, 0x00, sizeof(DWORD) * MAX_SCOPE_LEVEL);
	memset(&staScpFilOff, 0x00, sizeof(DWORD) * MAX_SCOPE_LEVEL);
	memset(&nxtScpFilPos[scpLev], 0x00, sizeof(DWORD) * MAX_SCOPE_LEVEL);
 memset(&endScpFilPos[scpLev], 0x00, sizeof(DWORD) * MAX_SCOPE_LEVEL);

	lstNxtScpFilPos= 0;
	
	for(i= 0; i < aObjFil-> objCofHdr.secNum; i++)
	{
		actDebObjFilSecS= (CObjFileSection *) aObjFil-> secLst-> GetAt(i);
		
		if (!strcmp(actDebObjFilSecS-> secNam, ".debug$S"))
		{
			actDebSecS= actDebObjFilSecS-> actFrgEnt;
			rawDatSecS= actDebSecS-> rawDat;

			/* Auflösen der Relocationen in der .debug$S Section */
			/* Relocationen treten in 0x205 immer Paarweise auf */

			relEntInd= 0;
				
			while(relEntInd < actDebSecS-> myHomSec-> actSecTab-> relNum)
			{
				actOffRel=  (myRelocationEntry *)(actDebSecS-> secFrgRelBuf + REL_ENT_SIZ * relEntInd++);
				actSecRel=  (myRelocationEntry *)(actDebSecS-> secFrgRelBuf + REL_ENT_SIZ * relEntInd++);
				relSymEnt= (mySymbolEntry *)actDebSecS-> secFrgObjFil-> newSymLst[actOffRel-> symTabInd];
			
				if (relSymEnt-> actSymTab-> secNum)
					actRelDbgSec= (CObjFileSection *) aObjFil-> secLst-> GetAt(relSymEnt-> actSymTab-> secNum - 1);

				if (!(relSymEnt-> actSymTab-> secNum && !actRelDbgSec-> actFrgEnt))
				{
					rawDatSecS-> Seek(actOffRel-> off, CFile::begin);
					rawDatSecS-> Read(&relSymEnt-> secOff, sizeof(DWORD));
					rawDatSecS-> Seek(actOffRel-> off, CFile::begin);
			
					if (aObjFil-> incExpEnt)
						rawDatSecS-> Write(&aObjFil-> incExpEnt-> textSegOff, sizeof(DWORD));
					else
					{
						if (relSymEnt-> actSymTab-> secNum)
							relSymEnt-> secOff+= actRelDbgSec-> actFrgEnt-> secFrgOff +	relSymEnt-> val;

						rawDatSecS-> Write(&relSymEnt-> secOff, sizeof(DWORD));
					}
									
					rawDatSecS-> Seek(actSecRel-> off, CFile::begin);
				
					if (aObjFil-> incExpEnt)	   
						rawDatSecS-> Write(&aObjFil-> ftrExeFil-> textSec-> secNum, sizeof(WORD));
					else
					{
						if (relSymEnt-> actSymTab-> secNum)
							relSymEnt-> secNum= actRelDbgSec-> actFrgEnt-> actExeSec-> secNum;
					
						rawDatSecS-> Write(&relSymEnt-> secNum, sizeof(WORD));
					}
				}
			}

			/*** Ändere Debugformat wenn notwendig ***/

			if (chgDbgFor)		
			{
				rawDatSecS-> SeekToBegin();
				if (verSgnCV ==	VER_SGN_CV4)
				{
					if (wrtCV5ToCV4Msg)
					{
						WriteMessageToPow(WRN_MSGD_CHG_VC5_TO_CV4, NULL, NULL);
						wrtCV5ToCV4Msg= FALSE;
					}
					rawDatSecS= ChgDbgForSecSToCV4(rawDatSecS);
				}
				else
				{
					if (wrtCV4ToCV5Msg)
					{
						WriteMessageToPow(WRN_MSGD_CHG_VC4_TO_CV5, NULL, NULL);
						wrtCV4ToCV5Msg= FALSE;
					}
					rawDatSecS= ChgDbgForSecSToCV5(rawDatSecS);
				}
			}

			if (rawDatSecS)
			{
				rawDatSecS-> SeekToBegin();
			
				if (chkVerSgn)
				{
					rawDatSecS-> Read(&verSgn, sizeof(DWORD));
					chkVerSgn= FALSE;
				}
				else
					verSgn= verSgnCV;

				if (verSgn == verSgnCV)
				{    
					while(rawDatSecS-> Read(&symRecHdr, sizeof(mySymbolRecord)))
					{
						/*** Überprüfe ob selbstdefinierter Typ vorhanden -> Neuzuordnung desselben ***/
					
						actRawDatPos= rawDatSecS-> GetPosition();

						if (verSgn == VER_SGN_CV4)
						{
							switch (symRecHdr.symTyp)
							{
								case 0x0001:		/* Besitzen keinen Typindex, sollen aber auch keine */
								case 0x0006:		/* Fehlermeldung (default: ) auslösen															*/
								case 0x0009:
								case 0x0206:
								
								break;

								case 0x201:	/* Local Data Symbol 16:32 */
								case 0x202:	/* Global Data Symbol 16:32 */
								case 0x203: /* Public Symobl	16:32 */
										rawDatSecS-> Seek(sizeof(WORD), CFile::current);

								case 0x200:	/* BP Relative Symbol 16:32 */

										rawDatSecS-> Seek(sizeof(DWORD), CFile::current);

								case 0x004:	/* User-defined Type */
							
										actFilPos= rawDatSecS-> GetPosition();
										rawDatSecS-> Read(&symTypW, sizeof(WORD));
										symTypW= SetPESymbolType40(symTypW, (WORD )objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
										if (symTypW)
										{
											rawDatSecS-> Seek(actFilPos, CFile::begin);
											rawDatSecS-> Write(&symTypW, sizeof(WORD));							
										}
															
									break;

								case 0x0204:	/* Local Procedure Start 16:32 */
								case 0x0205:	/* Global Procedure Start 16:32 */
									
										rawDatSecS-> Seek(7 * sizeof(DWORD) + sizeof(WORD), CFile::current);
										actFilPos= rawDatSecS-> GetPosition();
										rawDatSecS-> Read(&symTypW, sizeof(WORD));
										symTypW= SetPESymbolType40(symTypW, (WORD )objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
										if (symTypW)
										{
											rawDatSecS-> Seek(actFilPos, CFile::begin);
											rawDatSecS-> Write(&symTypW, sizeof(WORD));							
										}

									break;
						
								default: memset(msgBuf, 0x00, 256);
										wsprintf((char *)msgBuf, "\n0X%04x", symRecHdr.symTyp);
										WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
							}
						}
						else			// verSgn == VER_SGN_CV5
						{
							switch (symRecHdr.symTyp)
							{
								case 0x0001:		/* Besitzen keinen Typindex, sollen aber auch keine */
								case 0x0006:		/* Fehlermeldung (default: ) auslösen															*/			
								case 0x0009:
								case 0x0206: 

									break;

								case 0x1006:	/* BP Relative Symbol 16:32 */

										rawDatSecS-> Seek(sizeof(DWORD), CFile::current);
				
								case 0x1003:	/* User-defined Type */
								case 0x1007:	/* Local Data Symbol 16:32 */
								case 0x1008:	/* Global Data Symbol 16:32 */
								case 0x1009: /* Public Symobl	16:32 */
							
										actFilPos= rawDatSecS-> GetPosition();
										rawDatSecS-> Read(&symTypDW, sizeof(DWORD));
										symTypDW= SetPESymbolType50(symTypDW, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
										if (symTypDW)
										{
											rawDatSecS-> Seek(actFilPos, CFile::begin);
											rawDatSecS-> Write(&symTypDW, sizeof(DWORD));							
										}
															
									break;

								case 0x100A:	/* Local Procedure Start 16:32 */
								case 0x100B:	/* Global Procedure Start 16:32 */

										rawDatSecS-> Seek(6 * sizeof(DWORD), CFile::current);
										actFilPos= rawDatSecS-> GetPosition();
										rawDatSecS-> Read(&symTypDW, sizeof(DWORD));
										symTypDW= SetPESymbolType50(symTypDW, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
										if (symTypDW)
										{
											rawDatSecS-> Seek(actFilPos, CFile::begin);
											rawDatSecS-> Write(&symTypDW, sizeof(DWORD));							
										}

									break;

								default: 	memset(msgBuf, 0x00, 256);
										wsprintf((char *)msgBuf, "\n0X%04x", symRecHdr.symTyp);
										WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
							}
						}
					
						rawDatSecS-> Seek(actRawDatPos, CFile::begin);

						/*** Verarbeiten der Symbolinformation ***/

						switch (symRecHdr.symTyp)
						{
							case 0x0001:	/* Compile Flag */
						
							case 0x0009: /* Object File Name */
									bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));
									symRecHdr.recLen+= bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
									rawDatSstAlnSym-> Write(bytBuf, symRecHdr.recLen - sizeof(WORD) - bytTilAln);
									free(bytBuf);
									if (bytTilAln)
										rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);														
									actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
									retMemFil= TRUE;
								break;
						
							case 0x0004:	/* User-defined Type (CV4.0) wird nicht in die sstAlignSym aufgenommen */
							case 0x1003:	/* User-defined Type (CV5.0) */
									actRawDatPos= rawDatSecS-> GetPosition();
									aObjFil-> sstGloTypRawDat-> Write(&symRecHdr, sizeof(mySymbolRecord));
									bytBuf= (BYTE *) rawDatSecS-> ReadWithoutMemcpy(symRecHdr.recLen - sizeof(WORD));       
									aObjFil-> sstGloTypRawDat-> Write(bytBuf, symRecHdr.recLen - sizeof(WORD));  
									rawDatSecS-> Seek(actRawDatPos, CFile::begin);							
								
									bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
			      actFilPos= rawDatSecS-> GetPosition();
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));
			      rawDatSecS-> Seek(actFilPos + sizeof(WORD), CFile::begin);
									if (symRecHdr.symTyp == 0x1003)
										rawDatSecS-> Seek(sizeof(WORD), CFile::current);

			      rawDatSecS-> Read(&usrDefNamLen, sizeof(BYTE));
	       
									usrDefNam= (char *) malloc(usrDefNamLen + 1);
						   memset(usrDefNam, 0x00, usrDefNamLen + 1);       
					    rawDatSecS-> Read(usrDefNam, usrDefNamLen);
       
				     usrDefNamPos= usrDefNamLst-> FindString(usrDefNam);
			      if (!usrDefNamPos) // Keine doppelten Einträge zulassen
			      {      
						    usrDefNamLst-> AddTail(usrDefNam);
					     usrDefNamPos= usrDefNamLst-> FindString(usrDefNam);
									
										/* Erstellen des Eintrags in die Liste der Selbst definierten Typen */
									
										usrDefTypBuf= new CMyMemFile();
				      bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
				      refLen= (WORD )(symRecHdr.recLen + bytTilAln);
					 				usrDefTypBuf-> Write(&refLen, sizeof(WORD));
									 usrDefTypBuf-> Write(&symRecHdr.symTyp, sizeof(WORD));
								  usrDefTypBuf-> Write(bytBuf, symRecHdr.recLen - sizeof(WORD));
							   usrDefTypBuf-> Write(chrBuf00, bytTilAln);
									 sstGloSymLst-> AddTail(usrDefTypBuf);
						    adrSrtTabActFilPos+= usrDefTypBuf-> GetLength();
							  }
									else
										free(usrDefNam);

									free(bytBuf);									
								
									actRawDatPos-= sizeof(DWORD); // Platz des Symbol Records wird wieder abgezogen
								break;
						
							case 0x0006:	/* End of block */
									actScpOff= rawDatSstAlnSym-> GetLength() + 0xC;
									if (scpLev)
									{
										actRawDatPos= rawDatSstAlnSym-> GetPosition();
										rawDatSstAlnSym-> Seek(staScpFilPos[scpLev-1], CFile::begin);
										rawDatSstAlnSym-> Write(&staScpFilOff[scpLev-1], sizeof(DWORD));									
										rawDatSstAlnSym-> Write(&actScpOff, sizeof(DWORD));
										endScpFilPos[scpLev-1]= 0;
										if (nxtScpFilPos[scpLev-1])
										{
											lstNxtScpFilPos= nxtScpFilPos[scpLev-1];
											rawDatSstAlnSym-> Seek(nxtScpFilPos[scpLev-1], CFile::begin);
											actScpOff+= sizeof(DWORD);
											rawDatSstAlnSym-> Write(&actScpOff, sizeof(DWORD));
											nxtScpFilPos[scpLev-1]= 0;
										}
										rawDatSstAlnSym-> Seek(actRawDatPos, CFile::begin);
										scpLev--;
									}
									rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
									actRawDatPos+= sizeof(mySymbolRecord);
							 break;
						
							case 0x0200: /* BP Relative 16:32 (CV4.0) */
							case 0x1006: /* BP Relative 16:32 (CV5.0) */
							case 0x0201:	/* Local Data 16:32 (CV4.0) */
							case 0x1007:	/* Local Data 16:32 (CV5.0) */
							case 0x0206:	/* Thunk Start 16:32 */
							case 0x0209:	/* Code Label 16:32 */
								
									bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
									bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));       
							  symRecHdr.recLen+= bytTilAln;
							  rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
								 rawDatSstAlnSym-> Write(bytBuf, symRecHdr.recLen - bytTilAln - sizeof(WORD));
							  rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);
							  actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
							  free(bytBuf);
									insStrSrc= TRUE;
									retMemFil= TRUE;

							 break;

						
							case 0x0202:	/* Global Data Symbol 16:32 (CV4.0) */
							case 0x1008:	/* Global Data Symbol 16:32 (CV5.0) */
								
									DWORD *sTypAsPtr;	
									DWORD sTypBuf;
									DWORD sTypDW;
									WORD		sTypW;
									BOOL		ignTyp;
									BYTE		nBuf[256];
									BYTE		namLen;

									ignTyp= FALSE;
																
									actFilPos= rawDatSecS-> GetPosition();
								
									if (symRecHdr.symTyp == 0x1008)
									{
										rawDatSecS-> Read(&sTypDW, sizeof(DWORD));
										rawDatSecS-> Seek(sizeof(DWORD) + sizeof(WORD), CFile::current);		
									}
									else
									{
										rawDatSecS-> Seek(sizeof(DWORD), CFile::current);
										rawDatSecS-> Read(&sTypW, sizeof(WORD));
										rawDatSecS-> Seek(sizeof(WORD), CFile::current);
									}
								
									memset(&nBuf, 0x00, 256);
									rawDatSecS-> Read(&namLen, sizeof(BYTE));
									rawDatSecS-> Read(&nBuf, namLen);

									namBuf= (BYTE *) malloc(namLen + 2);
									strcpy((char *)namBuf, "_");										// Symbole haben ein zusätzliches "_" in der Symboltabelle
									strcat((char *)namBuf, (char *)nBuf);


									if (symRecHdr.symTyp == 0x1008)
										sTypAsPtr= (DWORD *)sTypDW;
									else
									{
										sTypBuf= 0;
										sTypBuf+= sTypW;
										sTypAsPtr= (DWORD *)sTypBuf;
									}

									if (gloDatSymLst-> Lookup((char *)namBuf, (void *&)sTypAsPtr))
										free(namBuf);
									else
										gloDatSymLst-> SetAt((char *)namBuf, sTypAsPtr);
									
									rawDatSecS-> Seek(actFilPos, CFile::begin);
								
								 bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
									bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));       
									if (!ignTyp)
									{
										symRecHdr.recLen+= (WORD )bytTilAln;
										rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
										rawDatSstAlnSym-> Write(bytBuf, symRecHdr.recLen - bytTilAln - sizeof(WORD));
										rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);
										actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
										retMemFil= TRUE;
										insStrSrc= TRUE;
									}
									free(bytBuf);
							
							 break;
						
							case 0x0204:	/* Local Procedure Start 16:32 (CV4.0) */
							case 0x100A:	/* Local Procedure Start 16:32 (CV5.0) */
								
									actRawDatPos= rawDatSstAlnSym-> GetPosition();
						
									if (!fstStaSrhSymOff)
										fstStaSrhSymOff= actRawDatPos + 0xC;
								
									staScpFilPos[scpLev]= actRawDatPos + 2 * sizeof(WORD);
									staScpFilOff[scpLev + 1]= actRawDatPos + 0xC;
									endScpFilPos[scpLev]= staScpFilPos[scpLev] + sizeof(DWORD);
							  nxtScpFilPos[scpLev]= endScpFilPos[scpLev] + sizeof(DWORD);									    

									scpLev++;

									bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
									bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));       
							  symRecHdr.recLen+= (WORD )bytTilAln;
						  
									rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
							  rawDatSstAlnSym-> Write(bytBuf, symRecHdr.recLen - bytTilAln - sizeof(WORD));
							  rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);
							  actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
							  free(bytBuf);
									insStrSrc= TRUE;
									retMemFil= TRUE;								
								break;

							case 0x0205:	/* Global Procedure Start 16:32	(CV4.0) */
							case 0x100B:	/* Global Procedure Start 16:32 (CV5.0) */
						
									actRawDatPos= rawDatSecS-> GetPosition();
									aObjFil-> sstGloTypRawDat-> Write(&symRecHdr, sizeof(mySymbolRecord));
									bytBuf= (BYTE *) rawDatSecS-> ReadWithoutMemcpy(symRecHdr.recLen - sizeof(WORD));       
									aObjFil-> sstGloTypRawDat-> Write(bytBuf, symRecHdr.recLen - sizeof(WORD));  
									rawDatSecS-> Seek(actRawDatPos, CFile::begin);							

									if (symRecHdr.symTyp == 0x0205)
									{
										rawDatSecS-> Read(&gloPrcSrtCV4, PRO_STA_CV4_LEN);
										staSrhSec= gloPrcSrtCV4.seg;
										namBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV4_LEN);
										rawDatSecS-> Read(namBuf, symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV4_LEN);																	
									}
									else
									{
										rawDatSecS-> Read(&gloPrcSrtCV5, PRO_STA_CV5_LEN);
										staSrhSec= gloPrcSrtCV5.seg;
										namBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV5_LEN);
										rawDatSecS-> Read(namBuf, symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV5_LEN);																	
									}
								
									/* Erstellen des Eintrags in die Liste der Selbst definierten Typen */
       	
									usrDefTypBuf= new CMyMemFile();
									prcRef.refLen= 0x0E;
					    prcRef.ind= 0x0400;
									namLen= (BYTE ) namBuf[0];
					    usrDefNam= (char *) malloc(namLen + 1);
					    memset(usrDefNam, 0x00, namLen + 1);
						   usrDefNam= (char *) strncpy(usrDefNam,(char *)(namBuf + 1), namLen);
							  prcRef.chkSum= GiveTableHash(usrDefNam);
								 free(usrDefNam);
					    prcRef.off= actRawDatPos;
									if (symRecHdr.symTyp == 0x0205)
										prcRef.mod= gloPrcSrtCV4.seg;
									else
										prcRef.mod= gloPrcSrtCV5.seg;
							  prcRef.alnSgn= 0x00;       
							  usrDefTypBuf-> Write(&prcRef, sizeof(myProcedureReference));
							  sstGloSymLst-> AddTail(usrDefTypBuf);
							  usrDefAdrSrtTabBuf= new CMyMemFile();
							  usrDefAdrSrtTabBuf-> Write(&adrSrtTabActFilPos, sizeof(DWORD));
							  usrDefAdrSrtTabBuf-> Write(&adrSrtTabActOff, sizeof(DWORD));
									if (symRecHdr.symTyp == 0x0205)
										adrSrtTabActOff+= gloPrcSrtCV4.prcLen;
									else
										adrSrtTabActOff+= gloPrcSrtCV5.prcLen;
						   sstGloSymAdrSrtTabLst-> AddTail(usrDefAdrSrtTabBuf);
						   adrSrtTabActFilPos+= usrDefTypBuf-> GetLength();
								
									actRawDatPos= rawDatSstAlnSym-> GetPosition();
								
									if (!fstStaSrhSymOff)
										fstStaSrhSymOff= actRawDatPos + 0xC;
								
									staScpFilPos[scpLev]= actRawDatPos + 2 * sizeof(WORD);
									staScpFilOff[scpLev + 1]= actRawDatPos + 0xC;
									endScpFilPos[scpLev]= staScpFilPos[scpLev] + sizeof(DWORD);
									nxtScpFilPos[scpLev]= endScpFilPos[scpLev] + sizeof(DWORD);									    
								
									scpLev++;

									symRecHdr.recLen+= bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
									rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
									
									if (symRecHdr.symTyp == 0x0205)
									{
										gloPrcSrtCV4.end= actRawDatPos;
										rawDatSstAlnSym-> Write(&gloPrcSrtCV4, PRO_STA_CV4_LEN );
										rawDatSstAlnSym-> Write(namBuf, symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV4_LEN - bytTilAln);
									}
									else
									{
										gloPrcSrtCV5.end= actRawDatPos;
										rawDatSstAlnSym-> Write(&gloPrcSrtCV5, PRO_STA_CV5_LEN);
										rawDatSstAlnSym-> Write(namBuf, symRecHdr.recLen - sizeof(WORD) - PRO_STA_CV5_LEN - bytTilAln);
									}

									free(namBuf);
									if (bytTilAln)
										rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);														
									retMemFil= TRUE;
									insStrSrc= TRUE;
								break;
						
							case 0x207:	/* Block Start 16:32 */

									actRawDatPos= rawDatSecS-> GetPosition();
								
									if (!fstStaSrhSymOff)
										fstStaSrhSymOff= actRawDatPos + 0xC;
								
									staScpFilPos[scpLev]= actRawDatPos + 2 * sizeof(WORD);
									staScpFilOff[scpLev + 1]= actRawDatPos + 0xC;
									endScpFilPos[scpLev]= staScpFilPos[scpLev] + sizeof(DWORD);
									nxtScpFilPos[scpLev]= endScpFilPos[scpLev] + sizeof(DWORD);									    
							
									scpLev++;

									bytBuf= (BYTE *) malloc(symRecHdr.recLen - sizeof(WORD));
									bytTilAln= (WORD )BytesTillAlignEnd(symRecHdr.recLen + sizeof(WORD), sizeof(DWORD));
									rawDatSecS-> Read(bytBuf, symRecHdr.recLen - sizeof(WORD));       
							  symRecHdr.recLen+= bytTilAln;
						  
									rawDatSstAlnSym-> Write(&symRecHdr, sizeof(mySymbolRecord));
							  rawDatSstAlnSym-> Write(bytBuf, symRecHdr.recLen - bytTilAln - sizeof(WORD));
							  rawDatSstAlnSym-> Write(chrBuf00, bytTilAln);
							  actRawDatPos+= symRecHdr.recLen + sizeof(WORD);
									free(bytBuf);
									insStrSrc= TRUE;
									retMemFil= TRUE;
						
							break;
										
							default: memset(msgBuf, 0x00, 256);
																wsprintf((char *)msgBuf, "\n0X%04x", symRecHdr.symTyp);
																WriteMessageToPow(WRN_MSGD_NO_SYM_IND, (char *)msgBuf, aObjFil-> objFilNam);
																rawDatSecS-> Seek(symRecHdr.recLen - sizeof(WORD), CFile::current);
						}
					}

					if (chgDbgFor)	// Freigeben der neu erzeugten Debugsektion
					{
						FreeCMyMemFile(rawDatSecS);	
						delete(rawDatSecS);
					}
				}
				else
				{
					if ((verSgn != VER_SGN_CV4) != (verSgn == VER_SGN_CV5))
						WriteMessageToPow(WRN_MSGD_WRO_CVS_FOR, actDebSecS-> secFrgObjFil-> objFilNam, NULL);
				}
			}
		}

		/*** Löschen des letzten NxtScp Eintrags ***/

		if (lstNxtScpFilPos)
		{
			actFilPos= rawDatSstAlnSym-> GetPosition();
			rawDatSstAlnSym-> Seek(lstNxtScpFilPos, CFile::begin);
			rawDatSstAlnSym-> Write(chrBuf00, sizeof(DWORD));
			rawDatSstAlnSym-> Seek(actFilPos, CFile::begin);
		}
	}

		/*** Freigeben des Speichers der nicht benötigten Typinformation ***/

	for(i= 0; i < (WORD )objFilTypInd; i++)
	{
		aSstGloTypInf= (mySstGloTypInfRec *) objFilTypArr-> GetAt(i); 
		if (!aSstGloTypInf-> typRefNmb)
			free(aSstGloTypInf);
	}

	objFilTypArr-> RemoveAll();
	objFilTypArr-> ~CPtrArray();
	delete objFilTypArr;

	/* Einfügen des Start Search Records - Nicht bei Funktionen aus DLL' s */
		
	if (insStrSrc && !aObjFil-> incExpEnt)
	{
		retRawDatSstAlnSym= new CMyMemFile();

		symRecHdr.recLen= 0xA;
		symRecHdr.symTyp= 0x005;
		retRawDatSstAlnSym-> Write(&verSgn, sizeof(DWORD));
		retRawDatSstAlnSym-> Write(&symRecHdr, sizeof(DWORD));
		retRawDatSstAlnSym-> Write(&fstStaSrhSymOff, sizeof(DWORD));
		retRawDatSstAlnSym-> Write(&staSrhSec, sizeof(WORD));
		retRawDatSstAlnSym-> Write(chrBuf00, sizeof(WORD));
		
		bytBufLen= rawDatSstAlnSym-> GetLength() - sizeof(DWORD);
		//bytBuf= (BYTE *) malloc(bytBufLen);
		rawDatSstAlnSym-> Seek(sizeof(DWORD), CFile::begin);
		bytBuf= (BYTE *) rawDatSstAlnSym-> ReadWithoutMemcpy(bytBufLen);
		retRawDatSstAlnSym-> Write(bytBuf, bytBufLen);
	
		rawDatSstAlnSym-> ~CMyMemFile();
		delete (rawDatSstAlnSym);
		return retRawDatSstAlnSym;
	}

	if (!retMemFil)
	{
		rawDatSstAlnSym-> ~CMyMemFile();
		delete (rawDatSstAlnSym);
		return NULL;
	}
	
	return rawDatSstAlnSym;
}

/**************************************************************************************************/
/*** Erstellen des CV sstSrcModule (0x127) ********************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstSrcModule(CObjFile *aObjFil)
{
 DWORD					*basSrcLinOffArr;
	DWORD					*basSrcFilOffArr;
 staEndRec *staEndOffArr; 
 
 BYTE  srcFilNamLen;

 CObjFileSection                *actTxtSec;
 myLineNumberEntry              *actLinNumEnt;
 mySymbolEntry                  *actSymEnt;
 myFunctionDefinition           *actBgnFncDef;
	myFunctionDefinition											*actEndFncDef;
 myBfAndEfAuxiliarySymbolFormat *actAuxSymFor;
	

	linNmbAdrMapInfRec	*aLinNmbAdrMapInfRec;
	modHdrStrRec							*aModHdrStrRec;
	filTabRec										*aFilTabRec;

	CMyPtrList	*linNmbAdrMapInfLst;

 CMyMemFile *sstSrcModRawDat;
	CMyMemFile *linNmbToAdrMapInfRawDat;

	POSITION codSegInd;
		
 DWORD modHdrStrLen;
	DWORD	filTabLen;
 DWORD basSrcLinOff;
	DWORD nxtLinNmbToAdrMapOff;
 DWORD *symTabOff;
 WORD  linNmbSum= 0x0000; 
 WORD  linNmbBlkSta;
	WORD		segIndNmb;
	WORD		secNmbInd;
	WORD  linNmbInd;
	BYTE		*bytBuf;

	sstSrcModRawDat= NULL;
	linNmbAdrMapInfLst= new CMyPtrList();

	for(secNmbInd= 0; secNmbInd < aObjFil-> objCofHdr.secNum; secNmbInd++)
	{
		actTxtSec= (CObjFileSection *) aObjFil-> secLst-> GetAt(secNmbInd);

		if (!strcmp(actTxtSec-> secNam, ".text"))
		{
			if (actTxtSec-> actSecTab-> linNumNum)
			{
				aLinNmbAdrMapInfRec= (linNmbAdrMapInfRec *) malloc(LIN_NMB_ADR_MAP_INF_SIZ);
				aLinNmbAdrMapInfRec-> segInd= newExeFil-> textSec-> secNum;
				aLinNmbAdrMapInfRec-> linNmbCnt= actTxtSec-> actSecTab-> linNumNum;  
				aLinNmbAdrMapInfRec-> codSegOffArr= (DWORD *) malloc((aLinNmbAdrMapInfRec-> linNmbCnt + 1) * sizeof(DWORD));
			 aLinNmbAdrMapInfRec-> linNmbArr= (WORD *) malloc(aLinNmbAdrMapInfRec-> linNmbCnt * sizeof(WORD));

				symTabOff= (DWORD *)(aObjFil-> symEntBuf + sizeof(DWORD));

				for(linNmbInd= 0; linNmbInd < aLinNmbAdrMapInfRec-> linNmbCnt; linNmbInd++)
				{
				 actLinNumEnt= (myLineNumberEntry *) (actTxtSec-> secLinNumBuf + linNmbInd * LIN_NUM_ENT_SIZ);
				 if (actLinNumEnt-> linNum)
				 {
				  aLinNmbAdrMapInfRec-> codSegOffArr[linNmbInd]= actTxtSec-> actFrgEnt-> secFrgOff + actLinNumEnt-> typ;
				  aLinNmbAdrMapInfRec-> linNmbArr[linNmbInd]= linNmbBlkSta + actLinNumEnt-> linNum;
				 }
				 else
				 {
					 actSymEnt= (mySymbolEntry *)(aObjFil-> symEntBuf + actLinNumEnt-> typ * sizeof(mySymbolEntry));
					 aLinNmbAdrMapInfRec-> codSegOffArr[linNmbInd]= actTxtSec-> actFrgEnt-> secFrgOff + actSymEnt-> val;
						
						
						
					 actBgnFncDef= (myFunctionDefinition *)(*symTabOff + (actLinNumEnt-> typ + 1) * SYM_TAB_LEN);
					 actAuxSymFor= (myBfAndEfAuxiliarySymbolFormat *)(*symTabOff + (actBgnFncDef-> tagInd + 1) * SYM_TAB_LEN);
						actEndFncDef= (myFunctionDefinition *)(*symTabOff + (actBgnFncDef-> tagInd + 3) * SYM_TAB_LEN);
						aLinNmbAdrMapInfRec-> linNmbArr[linNmbInd]= linNmbBlkSta= actAuxSymFor-> actLinNum;
						aLinNmbAdrMapInfRec-> codSegOffArr[aLinNmbAdrMapInfRec-> linNmbCnt]= aLinNmbAdrMapInfRec-> codSegOffArr[linNmbInd] + 
																																																																											actEndFncDef-> linNumPtr - 1; 	
					}
				}
				linNmbAdrMapInfLst-> AddTail(aLinNmbAdrMapInfRec);
			}
		}	
	} 

	if (linNmbAdrMapInfLst-> GetCount())
	{

		aModHdrStrRec= (modHdrStrRec *) malloc(MOD_HDR_SIZ);
		aFilTabRec= (filTabRec *) malloc(FIL_TAB_SIZ);

		aModHdrStrRec-> srcFilNmb= 1;
		codSegInd= linNmbAdrMapInfLst-> GetHeadPosition();
		aFilTabRec-> codSegNmb= aModHdrStrRec-> codSegNmb= linNmbAdrMapInfLst-> GetCount();
		
		basSrcFilOffArr= (DWORD *) malloc(aModHdrStrRec-> srcFilNmb * sizeof(DWORD));
		basSrcLinOffArr= (DWORD *) malloc(aModHdrStrRec-> codSegNmb * sizeof(DWORD)); 
		staEndOffArr= (staEndRec *) malloc(aModHdrStrRec-> codSegNmb * STA_END_REC_SIZ); 

		aModHdrStrRec-> basSrcFilOffArr= (DWORD *) malloc(aModHdrStrRec-> srcFilNmb * sizeof(DWORD));
		aModHdrStrRec-> staEndOffArr= staEndOffArr;

		aFilTabRec-> basSrcLinOffArr= (DWORD *) malloc(aModHdrStrRec-> codSegNmb * sizeof(DWORD)); 
		aFilTabRec-> staEndOffArr= staEndOffArr;
		aFilTabRec-> pad= 0x00;
		
		aModHdrStrRec-> segIndArr= (WORD *) malloc(aModHdrStrRec-> codSegNmb * sizeof(WORD));
				
		modHdrStrLen= sizeof(DWORD) + sizeof(DWORD) * aModHdrStrRec-> srcFilNmb + (0x8 + 0x2) * aModHdrStrRec-> codSegNmb;
		modHdrStrLen+= BytesTillAlignEnd(modHdrStrLen, sizeof(DWORD));	
		filTabLen= sizeof(DWORD) + (sizeof(DWORD) + 2 * sizeof(DWORD)) * aModHdrStrRec-> codSegNmb +
													sizeof(BYTE) + strlen(aObjFil-> srcFilNam);			 

		filTabLen+= BytesTillAlignEnd(filTabLen, sizeof(DWORD));	

		aModHdrStrRec-> basSrcFilOffArr[0]= modHdrStrLen;

		nxtLinNmbToAdrMapOff= basSrcLinOff= modHdrStrLen + filTabLen;

		linNmbToAdrMapInfRawDat= new CMyMemFile();
		segIndNmb= 0;
				
		while (codSegInd)
		{
			aLinNmbAdrMapInfRec= (linNmbAdrMapInfRec	*) linNmbAdrMapInfLst-> GetNext(codSegInd);
					
			aModHdrStrRec-> segIndArr[segIndNmb]= aLinNmbAdrMapInfRec-> segInd;

			staEndOffArr[segIndNmb].staOff= aLinNmbAdrMapInfRec-> codSegOffArr[0];
			staEndOffArr[segIndNmb].endOff= aLinNmbAdrMapInfRec-> codSegOffArr[aLinNmbAdrMapInfRec-> linNmbCnt];
			
			aFilTabRec-> basSrcLinOffArr[segIndNmb]= nxtLinNmbToAdrMapOff;

			linNmbToAdrMapInfRawDat->	Write(&aLinNmbAdrMapInfRec-> segInd, sizeof(WORD));
			linNmbToAdrMapInfRawDat->	Write(&aLinNmbAdrMapInfRec-> linNmbCnt, sizeof(WORD));
			linNmbToAdrMapInfRawDat-> Write(aLinNmbAdrMapInfRec-> codSegOffArr, aLinNmbAdrMapInfRec-> linNmbCnt * sizeof(DWORD));
			linNmbToAdrMapInfRawDat-> Write(aLinNmbAdrMapInfRec-> linNmbArr, aLinNmbAdrMapInfRec-> linNmbCnt * sizeof(WORD));

			linNmbToAdrMapInfRawDat-> Write(chrBuf00, BytesTillAlignEnd(linNmbToAdrMapInfRawDat-> GetPosition(), sizeof(DWORD)));
			nxtLinNmbToAdrMapOff= basSrcLinOff + linNmbToAdrMapInfRawDat-> GetPosition();

			free(aLinNmbAdrMapInfRec-> codSegOffArr);
			free(aLinNmbAdrMapInfRec-> linNmbArr);
			free(aLinNmbAdrMapInfRec);
			
			segIndNmb++;
		}
					
		sstSrcModRawDat= new CMyMemFile();
		
		/* Schreiben der Module Header Structure Daten */

		sstSrcModRawDat-> Write(&aModHdrStrRec-> srcFilNmb, sizeof(WORD));
		sstSrcModRawDat-> Write(&aModHdrStrRec-> codSegNmb, sizeof(WORD));
		sstSrcModRawDat-> Write(aModHdrStrRec-> basSrcFilOffArr, aModHdrStrRec-> srcFilNmb * sizeof(DWORD));
		sstSrcModRawDat-> Write(aModHdrStrRec-> staEndOffArr, aModHdrStrRec-> codSegNmb * STA_END_REC_SIZ);
		sstSrcModRawDat-> Write(aModHdrStrRec-> segIndArr, aModHdrStrRec-> codSegNmb * sizeof(WORD));
		if (BytesTillAlignEnd(sstSrcModRawDat-> GetLength(), sizeof(DWORD)))
			sstSrcModRawDat-> Write(chrBuf00, BytesTillAlignEnd(sstSrcModRawDat-> GetLength(), sizeof(DWORD)));

		/* Zusammensetzen des File Tables */

		srcFilNamLen= strlen(aObjFil-> srcFilNam);

		sstSrcModRawDat-> Write(&aFilTabRec-> codSegNmb, sizeof(WORD));
		sstSrcModRawDat-> Write(&aFilTabRec-> pad, sizeof(WORD));
		sstSrcModRawDat-> Write(aFilTabRec-> basSrcLinOffArr, aFilTabRec-> codSegNmb * sizeof(DWORD));
		sstSrcModRawDat-> Write(aFilTabRec-> staEndOffArr, aFilTabRec-> codSegNmb * STA_END_REC_SIZ);
		sstSrcModRawDat-> Write(&srcFilNamLen, sizeof(BYTE));
		sstSrcModRawDat-> Write(aObjFil-> srcFilNam, srcFilNamLen);
		sstSrcModRawDat-> Write(chrBuf00, BytesTillAlignEnd(sstSrcModRawDat-> GetLength(), sizeof(DWORD)));

		/* Zusammensetzen der Line Number To Address Mapping Information */

		linNmbToAdrMapInfRawDat->	SeekToBegin();
		bytBuf= (BYTE *) linNmbToAdrMapInfRawDat->	ReadWithoutMemcpy();
		sstSrcModRawDat-> Write(bytBuf, linNmbToAdrMapInfRawDat->	GetLength());
		sstSrcModRawDat-> Write(chrBuf00, BytesTillAlignEnd(sstSrcModRawDat-> GetLength(), sizeof(DWORD)));

		/* Freigeben des benötigten Speichers der Hilfsstrukturen */

		linNmbAdrMapInfLst-> RemoveAll();

		FreeCMyPtrList(linNmbAdrMapInfLst);
		delete(linNmbAdrMapInfLst);

		FreeCMyMemFile(linNmbToAdrMapInfRawDat);
		delete(linNmbToAdrMapInfRawDat);
		
		free(aModHdrStrRec-> basSrcFilOffArr);
		free(aModHdrStrRec-> segIndArr);
		free(aModHdrStrRec);
		free(basSrcFilOffArr);
		free(basSrcLinOffArr);
		free(staEndOffArr);
		free(aFilTabRec-> basSrcLinOffArr);
		free(aFilTabRec);
	}
	else 
			aObjFil-> insSstFilInd= FALSE;
	
	return sstSrcModRawDat;
}

/**************************************************************************************************/
/*** Erstellen des CV sstLibrary Moduls (0x128) ***************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstLibraries()
{
	CMyMemFile *sstLibRawDat= NULL;
 
 WORD   libFilInd;
 __int8 libFilNamLen;

 sstLibRawDat= new CMyMemFile();

 sstLibRawDat-> Write(chrBuf00, 1); // First entry should be a zero-length string

 libFilInd= 0;

 while(libFilLst[libFilInd] != NULL)
 {
  libFilNamLen= strlen(libFilLst[libFilInd]);
  sstLibRawDat-> Write(&libFilNamLen, sizeof(__int8));
		sstLibRawDat-> Write(libFilLst[libFilInd], libFilNamLen);
  libFilInd++;
 }	
 sstLibRawDat-> Write(chrBuf00, BytesTillAlignEnd(sstLibRawDat-> GetLength(), sizeof(DWORD)));
	return sstLibRawDat;
}

/**************************************************************************************************/
/*** Erstellen des CV sstGlobalSym Moduls	(0x129) *************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstGlobalSym()
{
	mySstGSymGPubSSymHeader sstGloSymPubHdr;
	myDatSym32CV4 										gloDat32RecEntCV4;
	myDatSym32CV5											gloDat32RecEntCV5;
 mySymbolRecord          glbSymRec;
	mySymbolRecord          alnStaRec;
	mySymbolEntry											*actSymEnt;
	
	CMyMemFile *rawDatGlbSymEnt;
	CMyMemFile	*rawDatCVsstGlbSym;
	CMyMemFile	*rawDatBukCnt;
	CMyMemFile	*rawDatChnTab;
	CMyMemFile	*rawDatHshChnEnt;
	CMyMemFile	*rawDatAdrEnt;
	CMyMemFile	*rawDatSecCnt;
	CMyMemFile	*rawDatAdrTab;
	CMyObArray	*symHshFunChnArr;
	CMyObArray	*symAdrFunChnArr;
	
	POSITION	symLstPos;

	__int8 pubSymNamLen;
 char   *pubSymNam;
	char			*hlpPubSymNam;

	DWORD chkSum;
	DWORD nxtSymInfEnt= 0;
	DWORD oldNxtSymInfEnt= 0;
	DWORD nxtChnTabEnt= 0;
	DWORD nxtAdrTabEnt= 0;
	DWORD chnTabEntLen;
	DWORD adrTabEntLen;
	DWORD bukNumCnt;
	DWORD alnEndSgn;
	DWORD *sSymTypPtr;
	DWORD sSymTypDW;
	WORD		sSymTypW;
	WORD  bytTilAlnEnd;
	WORD  hshFunChnInd;
	WORD  adrFunChnInd;
	WORD  bukNum= 0;
	WORD  secNum= 1;
	BYTE  *bytBuf;
 BYTE  symPagAlnBuf[8]= {0x06, 0x00, 0x02, 0x04, 0xFF, 0xFF, 0xFF, 0xFF};
 

	sstGloSymPubHdr.symHshInd= 0xA;
	sstGloSymPubHdr.adrHshInd= 0xC;
	gloDat32RecEntCV4.symTyp=  0x0202;
	gloDat32RecEntCV5.symTyp=  0x1008;

	// Ermitteln der Eintragsanzahl

	rawDatCVsstGlbSym= new CMyMemFile();
	rawDatCVsstGlbSym-> Write(&sstGloSymPubHdr, sizeof(mySstGSymGPubSSymHeader));

	bukNum= gloDatSymLst-> GetCount();
	bukNum+= sstGloSymLst-> GetCount();
	bukNum= bukNum / sstGloSymPubHdr.symHshInd;
 if (bukNum < 6) bukNum= 6;
	
	symHshFunChnArr= new CMyObArray();
	symHshFunChnArr-> SetSize(bukNum);
	symAdrFunChnArr= new CMyObArray();
	symAdrFunChnArr-> SetSize(secNum);
	
	for(hshFunChnInd= 0; hshFunChnInd < bukNum; hshFunChnInd++)
	{
		rawDatHshChnEnt= new CMyMemFile();
		symHshFunChnArr-> SetAt(hshFunChnInd, rawDatHshChnEnt);
	}

	for(adrFunChnInd= 0; adrFunChnInd < secNum; adrFunChnInd++)
	{
		rawDatAdrEnt= new CMyMemFile();
		symAdrFunChnArr-> SetAt(adrFunChnInd, rawDatAdrEnt);
	}
	
	symLstPos= gloDatSymLst-> GetStartPosition();
	while(symLstPos)
	{
		gloDatSymLst-> GetNextAssoc(symLstPos, pubSymNam, (void *&)sSymTypPtr);
		sSymTypW= (WORD )sSymTypPtr;
		sSymTypDW= (DWORD )sSymTypPtr;
		hlpPubSymNam= pubSymNam;

		if (newExeFil-> pubSymLst-> Lookup(hlpPubSymNam, (void *&)actSymEnt))
		{
			pubSymNam++;
			if (verSgnCV == VER_SGN_CV4)
			{
				gloDat32RecEntCV4.symLen= strlen(pubSymNam);
				gloDat32RecEntCV4.recLen= DAT_SYM_CV4_LEN + gloDat32RecEntCV4.symLen - sizeof(WORD);
   
				// Natural Alignment
				bytTilAlnEnd= (WORD )BytesTillAlignEnd(sizeof(WORD) + gloDat32RecEntCV4.recLen, sizeof(DWORD));
				gloDat32RecEntCV4.recLen+= bytTilAlnEnd;

				gloDat32RecEntCV4.codSecOff= actSymEnt-> secOff;
				gloDat32RecEntCV4.secNum= (WORD )actSymEnt-> secNum;
				gloDat32RecEntCV4.typInd= sSymTypW;
				
				oldNxtSymInfEnt= nxtSymInfEnt;
				nxtSymInfEnt+= gloDat32RecEntCV4.recLen + sizeof(WORD);
			}
			else
			{
				gloDat32RecEntCV5.symLen= strlen(pubSymNam);
				gloDat32RecEntCV5.recLen= DAT_SYM_CV5_LEN + gloDat32RecEntCV5.symLen - sizeof(WORD);

				// Natural Alignment
				bytTilAlnEnd= (WORD )BytesTillAlignEnd(sizeof(WORD) + gloDat32RecEntCV5.recLen, sizeof(DWORD));
				gloDat32RecEntCV5.recLen+= bytTilAlnEnd;

				gloDat32RecEntCV5.codSecOff= actSymEnt-> secOff;
				gloDat32RecEntCV5.secNum= (WORD )actSymEnt-> secNum;
				gloDat32RecEntCV5.typInd= sSymTypDW;
				
				oldNxtSymInfEnt= nxtSymInfEnt;
				nxtSymInfEnt+= gloDat32RecEntCV5.recLen + sizeof(WORD);
			}
				
			if (!((oldNxtSymInfEnt / 0x1000) == (nxtSymInfEnt / 0x1000))) // Füge S_Align Symbol ein
			{
			 alnStaRec.recLen= (WORD )((nxtSymInfEnt / 0x1000) * 0x1000 - oldNxtSymInfEnt - sizeof(WORD));
				alnStaRec.symTyp= 0x0402;
				rawDatCVsstGlbSym-> Write(&alnStaRec, sizeof(mySymbolRecord));
				rawDatCVsstGlbSym-> Write(chrBuf00, alnStaRec.recLen - sizeof(WORD));
				oldNxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
				nxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
			}
				
			chkSum= GiveTableHash(actSymEnt-> symNam);
			rawDatHshChnEnt= (CMyMemFile *)symHshFunChnArr-> GetAt(chkSum % bukNum);
			rawDatHshChnEnt-> Write(&oldNxtSymInfEnt, sizeof(DWORD));
			rawDatHshChnEnt-> Write(&chkSum, sizeof(DWORD));

			rawDatAdrEnt= (CMyMemFile *)symAdrFunChnArr-> GetAt((actSymEnt-> secNum - 1) % secNum);
			rawDatAdrEnt-> Write(&oldNxtSymInfEnt, sizeof(DWORD));
			rawDatAdrEnt-> Write(&actSymEnt-> secOff, sizeof(DWORD));

			if (verSgnCV == VER_SGN_CV4)
			{
				rawDatCVsstGlbSym-> Write(&gloDat32RecEntCV4, DAT_SYM_CV4_LEN);
				rawDatCVsstGlbSym-> Write(pubSymNam, gloDat32RecEntCV4.symLen);
				if (bytTilAlnEnd)
					rawDatCVsstGlbSym-> Write(chrBuf00, bytTilAlnEnd);			 
			}
			else
			{
				rawDatCVsstGlbSym-> Write(&gloDat32RecEntCV5, DAT_SYM_CV5_LEN);
				rawDatCVsstGlbSym-> Write(pubSymNam, gloDat32RecEntCV5.symLen);
				if (bytTilAlnEnd)
					rawDatCVsstGlbSym-> Write(chrBuf00, bytTilAlnEnd);			 
			}
		}
		else
			WriteMessageToPow(WRN_MSGD_CV129_NO_SYM, hlpPubSymNam, NULL);

		free(hlpPubSymNam);
	}


	symLstPos= sstGloSymLst-> GetHeadPosition();
	while(symLstPos)
	{
		rawDatGlbSymEnt= (CMyMemFile *)sstGloSymLst-> GetNext(symLstPos);
  rawDatGlbSymEnt-> SeekToBegin();

		rawDatGlbSymEnt-> Read(&glbSymRec, sizeof(DWORD));

  if (glbSymRec.symTyp == 0x0400)
  {
   rawDatGlbSymEnt-> Read(&chkSum, sizeof(DWORD));
   //rawDatSymHshFncChnArr-> Write(&nxtSymInfEnt, sizeof(DWORD));
  }
  else
  {
   rawDatGlbSymEnt-> Seek(sizeof(WORD), CFile::current);
   rawDatGlbSymEnt-> Read(&pubSymNamLen, sizeof(__int8));
   pubSymNam= (char *) malloc(pubSymNamLen + 1);
   rawDatGlbSymEnt-> Read(pubSymNam, pubSymNamLen);
   pubSymNam[pubSymNamLen]= '\0';
   chkSum= GiveTableHash(pubSymNam);
			free(pubSymNam);
  }
		
		oldNxtSymInfEnt= nxtSymInfEnt;
		nxtSymInfEnt+= rawDatGlbSymEnt-> GetLength();

		if (!((oldNxtSymInfEnt / 0x1000) == (nxtSymInfEnt / 0x1000))) // Füge S_Align Symbol ein
		{
		 alnStaRec.recLen= (WORD )((nxtSymInfEnt / 0x1000) * 0x1000 - oldNxtSymInfEnt - sizeof(WORD));
			alnStaRec.symTyp= 0x0402;
			rawDatCVsstGlbSym-> Write(&alnStaRec, sizeof(mySymbolRecord));
			rawDatCVsstGlbSym-> Write(chrBuf00, alnStaRec.recLen - sizeof(WORD));
			oldNxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
			nxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
		}

		rawDatHshChnEnt= (CMyMemFile *)symHshFunChnArr-> GetAt(chkSum % bukNum);
		rawDatHshChnEnt-> Write(&nxtSymInfEnt, sizeof(DWORD));
		rawDatHshChnEnt-> Write(&chkSum, sizeof(DWORD));

  rawDatGlbSymEnt-> SeekToBegin();
  bytBuf= (BYTE *) rawDatGlbSymEnt-> ReadWithoutMemcpy(rawDatGlbSymEnt-> GetLength());
  rawDatCVsstGlbSym-> Write(bytBuf, rawDatGlbSymEnt-> GetLength());
	}
	
	// Abschließendes P_ALIGN Symbol

	alnStaRec.recLen= 0x0006;
 alnStaRec.symTyp= 0x0402;
 alnEndSgn= 0xFFFFFFFF;
 rawDatCVsstGlbSym-> Write(&alnStaRec, sizeof(mySymbolRecord));
 rawDatCVsstGlbSym-> Write(&alnEndSgn, sizeof(DWORD));
	nxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
		
	/* Zusammenhängen der einzelnen CMemFiles des CV sstGlobalPublic Moduls */
	
	sstGloSymPubHdr.symTabLen= rawDatCVsstGlbSym-> GetLength() - sizeof(mySstGSymGPubSSymHeader);
	sstGloSymPubHdr.symHshTabLen= 2 * sizeof(WORD) + 2 * bukNum * sizeof(DWORD);
	sstGloSymPubHdr.adrHshTabLen= 2 * sizeof(WORD) + 2 * secNum * sizeof(DWORD);

	rawDatCVsstGlbSym-> Write(&bukNum, sizeof(WORD));
	rawDatCVsstGlbSym-> Write(chrBuf00, sizeof(WORD));

	rawDatBukCnt= new CMyMemFile();
	rawDatChnTab= new CMyMemFile();
	
	for(hshFunChnInd= 0; hshFunChnInd < bukNum; hshFunChnInd++)
	{
		rawDatCVsstGlbSym-> Write(&nxtChnTabEnt, sizeof(DWORD));
		rawDatHshChnEnt= (CMyMemFile *)symHshFunChnArr-> GetAt(hshFunChnInd);
		nxtChnTabEnt+= chnTabEntLen= rawDatHshChnEnt-> GetLength();
		bukNumCnt= chnTabEntLen / (2 * sizeof (DWORD));
		rawDatBukCnt-> Write(&bukNumCnt, sizeof(DWORD));
		if (chnTabEntLen)
		{
			rawDatHshChnEnt-> SeekToBegin();
			bytBuf= (BYTE *)rawDatHshChnEnt-> ReadWithoutMemcpy(chnTabEntLen);
			rawDatChnTab-> Write(bytBuf, chnTabEntLen);
		}
		FreeCMyMemFile(rawDatHshChnEnt);
		delete rawDatHshChnEnt;
	}

	sstGloSymPubHdr.symHshTabLen+= nxtChnTabEnt;

	rawDatBukCnt-> SeekToBegin();
 bytBuf= (BYTE *) rawDatBukCnt-> ReadWithoutMemcpy(bukNum * sizeof(DWORD));
	rawDatCVsstGlbSym-> Write(bytBuf, bukNum * sizeof(DWORD));
	
	rawDatChnTab-> SeekToBegin();
	bytBuf= (BYTE *) rawDatChnTab-> ReadWithoutMemcpy(rawDatChnTab-> GetLength());
	rawDatCVsstGlbSym-> Write(bytBuf, rawDatChnTab-> GetLength());
 
	sstGloSymPubHdr.symHshTabLen+= nxtAdrTabEnt;

	rawDatSecCnt= new CMyMemFile();
	rawDatAdrTab= new CMyMemFile();
 sstGloSymPubHdr.adrHshTabLen= rawDatCVsstGlbSym-> GetLength() * -1;
	rawDatCVsstGlbSym-> Write(&secNum, sizeof(WORD));
	rawDatCVsstGlbSym-> Write(chrBuf00, sizeof(WORD));

 rawDatCVsstGlbSym-> Write(&nxtAdrTabEnt, sizeof(DWORD));

 adrTabEntLen= sstGloSymAdrSrtTabLst-> GetCount();
 rawDatCVsstGlbSym-> Write(&adrTabEntLen, sizeof(DWORD));

 symLstPos= sstGloSymAdrSrtTabLst-> GetHeadPosition();
	while(symLstPos)
	{
		rawDatGlbSymEnt= (CMyMemFile *)sstGloSymAdrSrtTabLst-> GetNext(symLstPos);
  rawDatGlbSymEnt-> SeekToBegin();
  bytBuf= (BYTE *) rawDatGlbSymEnt-> ReadWithoutMemcpy(2 * sizeof(DWORD));
  rawDatCVsstGlbSym-> Write(bytBuf, 2 * sizeof(DWORD));
 }
	
 for(adrFunChnInd= 0; adrFunChnInd < secNum; adrFunChnInd++)
	{                             
		rawDatCVsstGlbSym-> Write(&nxtAdrTabEnt, sizeof(DWORD));
		rawDatAdrEnt= (CMyMemFile *)symAdrFunChnArr-> GetAt(adrFunChnInd);
		nxtAdrTabEnt+= adrTabEntLen= rawDatAdrEnt-> GetLength();
		bukNumCnt= adrTabEntLen / (2 * sizeof (DWORD));
		rawDatSecCnt-> Write(&bukNumCnt, sizeof(DWORD));
		if (adrTabEntLen)
		{
			rawDatAdrEnt-> SeekToBegin();
			bytBuf= (BYTE *) rawDatAdrEnt-> ReadWithoutMemcpy(adrTabEntLen);
			rawDatAdrTab-> Write(bytBuf, adrTabEntLen);
		}
		FreeCMyMemFile(rawDatAdrEnt);
		delete rawDatAdrEnt;
	}
 
	sstGloSymPubHdr.symHshTabLen+= nxtAdrTabEnt;

	rawDatSecCnt-> SeekToBegin();
	bytBuf= (BYTE *) rawDatSecCnt-> ReadWithoutMemcpy(secNum * sizeof(DWORD));
	rawDatCVsstGlbSym-> Write(bytBuf, secNum * sizeof(DWORD));
	FreeCMyMemFile(rawDatSecCnt);
	delete rawDatSecCnt;
	
	rawDatAdrTab-> SeekToBegin();
	bytBuf= (BYTE *) rawDatAdrTab-> ReadWithoutMemcpy(nxtAdrTabEnt);
	rawDatCVsstGlbSym-> Write(bytBuf, nxtAdrTabEnt);
	FreeCMyMemFile(rawDatAdrTab);
	delete rawDatAdrTab;

	rawDatCVsstGlbSym-> SeekToBegin();
	sstGloSymPubHdr.adrHshTabLen+= rawDatCVsstGlbSym-> GetLength();
	rawDatCVsstGlbSym-> Write(&sstGloSymPubHdr, sizeof(mySstGSymGPubSSymHeader));
 
	/* Freigeben des allokierten Speichers */

	FreeCMyMemFile(rawDatBukCnt);
	delete rawDatBukCnt;
	FreeCMyMemFile(rawDatChnTab);
	delete rawDatChnTab;
	FreeCMyObArray(symHshFunChnArr);
	delete symHshFunChnArr;
	FreeCMyObArray(symAdrFunChnArr);
	delete symAdrFunChnArr;
		
	return rawDatCVsstGlbSym;

}

/**************************************************************************************************/
/*** Erstellen des CV sstGlobalPub Moduls (0x12A) *************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstGlobalPub(CMyObList *obFilLst)
{
	mySstGSymGPubSSymHeader sstGloSymPubHdr;
	myDatSym32CV4											pub32RecEntCV4;
	myDatSym32CV5											pub32RecEntCV5;
 mySymbolRecord          alnStaRec;

	CMyMapStringToPtr							*sstGloSymNamLst;
	CObjFileSection									*resSymSec;
	mySymbolEntry											*actSymEnt;

	CObjFile	  *actObjFil;
	CMyMemFile	*rawDatCVsstGlbPub;
	CMyMemFile	*rawDatBukCnt;
	CMyMemFile	*rawDatChnTab;
	CMyMemFile	*rawDatHshChnEnt;
	CMyMemFile	*rawDatAdrEnt;
	CMyMemFile	*rawDatSecCnt;
	CMyMemFile	*rawDatAdrTab;
	CMyObArray	*symHshFunChnArr;
	CMyObArray	*symAdrFunChnArr;

	POSITION	objLstPos;
	POSITION	symLstPos;

	DWORD chkSum;
	DWORD nxtSymInfEnt= 0;
 DWORD oldNxtSymInfEnt= 0;
	DWORD nxtChnTabEnt= 0;
	DWORD nxtAdrTabEnt= 0;
	DWORD chnTabEntLen;
	DWORD adrTabEntLen;
	DWORD bukNumCnt;
 DWORD alnEndSgn;
	DWORD *aPtr= 0x0000;
	WORD  hshFunChnInd;
	WORD  adrFunChnInd;
	WORD  bytTilAlnEnd;
	WORD  bukNum= 0;
	WORD  secNum= 5;
	BYTE  *bytBuf;

	sstGloSymPubHdr.symHshInd= 0xA;
	sstGloSymPubHdr.adrHshInd= 0xC;
	pub32RecEntCV4.symTyp=  0x0203;
	pub32RecEntCV5.symTyp=  0x1009;

	// Ermitteln der Eintragsanzahl

	rawDatCVsstGlbPub= new CMyMemFile();
	rawDatCVsstGlbPub-> Write(&sstGloSymPubHdr, sizeof(mySstGSymGPubSSymHeader));

	objLstPos= obFilLst-> GetHeadPosition();
	while(objLstPos)
	{
		actObjFil= (CObjFile *)obFilLst-> GetNext(objLstPos);
		bukNum+= actObjFil-> gloPubSymLst-> GetCount();
	}
	
	bukNum= bukNum / sstGloSymPubHdr.symHshInd;
	
	symHshFunChnArr= new CMyObArray();
	symHshFunChnArr-> SetSize(bukNum);
	symAdrFunChnArr= new CMyObArray();
	symAdrFunChnArr-> SetSize(secNum);
	
	for(hshFunChnInd= 0; hshFunChnInd < bukNum; hshFunChnInd++)
	{
		rawDatHshChnEnt= new CMyMemFile();
		symHshFunChnArr-> SetAt(hshFunChnInd, rawDatHshChnEnt);
	}

	for(adrFunChnInd= 0; adrFunChnInd < secNum; adrFunChnInd++)
	{
		rawDatAdrEnt= new CMyMemFile();
		symAdrFunChnArr-> SetAt(adrFunChnInd, rawDatAdrEnt);
	}
	
	sstGloSymNamLst= new CMyMapStringToPtr();
	
	objLstPos= obFilLst-> GetHeadPosition();

	while(objLstPos)
	{
		actObjFil= (CObjFile *)obFilLst-> GetNext(objLstPos);
		symLstPos= actObjFil-> gloPubSymLst-> GetHeadPosition();
		while(symLstPos)
		{
			actSymEnt= (mySymbolEntry *)actObjFil-> gloPubSymLst-> GetNext(symLstPos);
			
			if (!actSymEnt-> secNum)
			{
				// Diese Symbole werden bei Programmdurchführung nicht benötigt, sind aber mit der
				// Laufzeitlibrary beim Auflösen anderer Symbole mitgeladen worden. In die Debuginformation
				// werden sie trotzdem aufgenommen. 
				resSymSec= (CObjFileSection *)actSymEnt-> symObjFil-> secLst-> GetAt(actSymEnt-> actSymTab-> secNum - 1);

				if (resSymSec-> actFrgEnt)
    {
 				actSymEnt-> secOff= resSymSec-> actFrgEnt-> secFrgOff + actSymEnt-> val;
	 			actSymEnt-> secNum= resSymSec-> actFrgEnt-> actExeSec-> secNum;
    }
    else // Es handelt sich um einen IMPORT_DESCRIPTOR oder NULL_THUNK_DATA
    {
     actSymEnt-> secOff= 0x0000;
     actSymEnt-> secNum= newExeFil-> idataSec-> secNum;
    }
			}
   
			if (!sstGloSymNamLst-> Lookup(actSymEnt-> symNam, (void *&) aPtr))
			{
				sstGloSymNamLst-> SetAt(actSymEnt-> symNam, aPtr);

				if (verSgnCV == VER_SGN_CV4)
				{
					pub32RecEntCV4.symLen= strlen(actSymEnt-> symNam);
					pub32RecEntCV4.recLen= DAT_SYM_CV4_LEN + pub32RecEntCV4.symLen - sizeof(WORD);
   
					// Natural Alignment
					bytTilAlnEnd= (WORD )BytesTillAlignEnd(sizeof(WORD) + pub32RecEntCV4.recLen, sizeof(DWORD));
					pub32RecEntCV4.recLen+= bytTilAlnEnd;

					pub32RecEntCV4.codSecOff= actSymEnt-> secOff;
					pub32RecEntCV4.secNum= (WORD )actSymEnt-> secNum;
					pub32RecEntCV4.typInd= 0x0000; // Public Symbols => T_NOTYPE
					oldNxtSymInfEnt= nxtSymInfEnt;
					nxtSymInfEnt+= pub32RecEntCV4.recLen + sizeof(WORD);
				}
				else
				{
					pub32RecEntCV5.symLen= strlen(actSymEnt-> symNam);
					pub32RecEntCV5.recLen= DAT_SYM_CV5_LEN + pub32RecEntCV5.symLen - sizeof(WORD);
   
					// Natural Alignment
					bytTilAlnEnd= (WORD )BytesTillAlignEnd(sizeof(WORD) + pub32RecEntCV5.recLen, sizeof(DWORD));
					pub32RecEntCV5.recLen+= bytTilAlnEnd;

					pub32RecEntCV5.codSecOff= actSymEnt-> secOff;
					pub32RecEntCV5.secNum= (WORD )actSymEnt-> secNum;
					pub32RecEntCV5.typInd= 0x00000000; // Public Symbols => T_NOTYPE
					oldNxtSymInfEnt= nxtSymInfEnt;
					nxtSymInfEnt+= pub32RecEntCV5.recLen + sizeof(WORD);
				}


				if (!((oldNxtSymInfEnt / 0x1000) == (nxtSymInfEnt / 0x1000))) // Füge S_Align Symbol ein
				{
				 alnStaRec.recLen= (WORD )((nxtSymInfEnt / 0x1000) * 0x1000 - oldNxtSymInfEnt - sizeof(WORD));
					alnStaRec.symTyp= 0x0402;
					rawDatCVsstGlbPub-> Write(&alnStaRec, sizeof(mySymbolRecord));
					rawDatCVsstGlbPub-> Write(chrBuf00, alnStaRec.recLen - sizeof(WORD));
					oldNxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
					nxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
				}
				
				chkSum= GiveTableHash(actSymEnt-> symNam);
				rawDatHshChnEnt= (CMyMemFile *)symHshFunChnArr-> GetAt(chkSum % bukNum);
				rawDatHshChnEnt-> Write(&oldNxtSymInfEnt, sizeof(DWORD));
				rawDatHshChnEnt-> Write(&chkSum, sizeof(DWORD));

				rawDatAdrEnt= (CMyMemFile *)symAdrFunChnArr-> GetAt((actSymEnt-> secNum - 1) % secNum);
				rawDatAdrEnt-> Write(&oldNxtSymInfEnt, sizeof(DWORD));
				rawDatAdrEnt-> Write(&actSymEnt-> secOff, sizeof(DWORD));

				if (verSgnCV == VER_SGN_CV4)
				{
					rawDatCVsstGlbPub-> Write(&pub32RecEntCV4, DAT_SYM_CV4_LEN);
					rawDatCVsstGlbPub-> Write(actSymEnt-> symNam, pub32RecEntCV4.symLen);
					if (bytTilAlnEnd)
						rawDatCVsstGlbPub-> Write(chrBuf00, bytTilAlnEnd);			 
				}
				else
				{
					rawDatCVsstGlbPub-> Write(&pub32RecEntCV5, DAT_SYM_CV5_LEN);
					rawDatCVsstGlbPub-> Write(actSymEnt-> symNam, pub32RecEntCV5.symLen);
					if (bytTilAlnEnd)
						rawDatCVsstGlbPub-> Write(chrBuf00, bytTilAlnEnd);			 
				}
			}
		}
	}

	sstGloSymNamLst-> RemoveAll();
	delete(sstGloSymNamLst);
	
 // Abschließendes P_ALIGN Symbol

	alnStaRec.recLen= 0x0006;
 alnStaRec.symTyp= 0x0402;
 alnEndSgn= 0xFFFFFFFF;
 rawDatCVsstGlbPub-> Write(&alnStaRec, sizeof(mySymbolRecord));
 rawDatCVsstGlbPub-> Write(&alnEndSgn, sizeof(DWORD));
	nxtSymInfEnt+= alnStaRec.recLen + sizeof(WORD);
	
	/* Zusammenhängen der einzelnen CMemFiles des CV sstGlobalPublic Moduls */
		
	sstGloSymPubHdr.symTabLen= nxtSymInfEnt + BytesTillAlignEnd(nxtSymInfEnt, sizeof(DWORD));
	sstGloSymPubHdr.symHshTabLen= 2 * sizeof(WORD) + 2 * bukNum * sizeof(DWORD);
	sstGloSymPubHdr.adrHshTabLen= 2 * sizeof(WORD) + 2 * secNum * sizeof(DWORD);

	rawDatCVsstGlbPub-> Write(&bukNum, sizeof(WORD));
	rawDatCVsstGlbPub-> Write(chrBuf00, sizeof(WORD));

	rawDatBukCnt= new CMyMemFile();
	rawDatChnTab= new CMyMemFile();
	
	for(hshFunChnInd= 0; hshFunChnInd < bukNum; hshFunChnInd++)
	{
		rawDatCVsstGlbPub-> Write(&nxtChnTabEnt, sizeof(DWORD));
		rawDatHshChnEnt= (CMyMemFile *)symHshFunChnArr-> GetAt(hshFunChnInd);
		nxtChnTabEnt+= chnTabEntLen= rawDatHshChnEnt-> GetLength();
		bukNumCnt= chnTabEntLen / (2 * sizeof (DWORD));
		rawDatBukCnt-> Write(&bukNumCnt, sizeof(DWORD));
		if (chnTabEntLen)
		{
			rawDatHshChnEnt-> SeekToBegin();
			bytBuf= (BYTE *)rawDatHshChnEnt-> ReadWithoutMemcpy(chnTabEntLen);
			rawDatChnTab-> Write(bytBuf, chnTabEntLen);
		}
		FreeCMyMemFile(rawDatHshChnEnt);
		delete rawDatHshChnEnt;
	}

	sstGloSymPubHdr.symHshTabLen+= nxtChnTabEnt;

	rawDatBukCnt-> SeekToBegin();
	bytBuf= (BYTE *)rawDatBukCnt-> ReadWithoutMemcpy(bukNum * sizeof(DWORD));
	rawDatCVsstGlbPub-> Write(bytBuf, bukNum * sizeof(DWORD));
	
	rawDatChnTab-> SeekToBegin();
	bytBuf= (BYTE *)rawDatChnTab-> ReadWithoutMemcpy(nxtChnTabEnt);
	rawDatCVsstGlbPub-> Write(bytBuf, nxtChnTabEnt);

 // Build Address Sort Table
	
	rawDatSecCnt= new CMyMemFile();
	rawDatAdrTab= new CMyMemFile();
	rawDatCVsstGlbPub-> Write(&secNum, sizeof(WORD));  // Number of logical Segments/Sections
	rawDatCVsstGlbPub-> Write(chrBuf00, sizeof(WORD)); // Alignment Filer

	for(adrFunChnInd= 0; adrFunChnInd < secNum; adrFunChnInd++)
	{
		rawDatCVsstGlbPub-> Write(&nxtAdrTabEnt, sizeof(DWORD));
		rawDatAdrEnt= (CMyMemFile *)symAdrFunChnArr-> GetAt(adrFunChnInd);
		nxtAdrTabEnt+= adrTabEntLen= rawDatAdrEnt-> GetLength();
		bukNumCnt= adrTabEntLen / (2 * sizeof (DWORD));
		rawDatSecCnt-> Write(&bukNumCnt, sizeof(DWORD));
		if (adrTabEntLen)
		{
			rawDatAdrEnt-> SeekToBegin();
			bytBuf= (BYTE *)rawDatAdrEnt-> ReadWithoutMemcpy(adrTabEntLen);
			rawDatAdrTab-> Write(bytBuf, adrTabEntLen);
		}
		FreeCMyMemFile(rawDatAdrEnt);
		delete rawDatAdrEnt;
	}

	rawDatSecCnt-> SeekToBegin();
	bytBuf= (BYTE *)rawDatSecCnt-> ReadWithoutMemcpy(secNum * sizeof(DWORD));
	rawDatCVsstGlbPub-> Write(bytBuf, secNum * sizeof(DWORD));
	FreeCMyMemFile(rawDatSecCnt);
	delete rawDatSecCnt;
	
	rawDatAdrTab-> SeekToBegin();
	bytBuf= (BYTE *) rawDatAdrTab-> ReadWithoutMemcpy(nxtAdrTabEnt);
	rawDatCVsstGlbPub-> Write(bytBuf, nxtAdrTabEnt);
	FreeCMyMemFile(rawDatAdrTab);
	delete rawDatAdrTab;

	rawDatCVsstGlbPub-> SeekToBegin();
	sstGloSymPubHdr.adrHshTabLen+= nxtAdrTabEnt;
	rawDatCVsstGlbPub-> Write(&sstGloSymPubHdr, sizeof(mySstGSymGPubSSymHeader));

	/* Freigeben des allokierten Speichers */

	FreeCMyMemFile(rawDatBukCnt);
	delete rawDatBukCnt;
	FreeCMyMemFile(rawDatChnTab);
	delete rawDatChnTab;
	FreeCMyObArray(symHshFunChnArr);
	delete symHshFunChnArr;
	FreeCMyObArray(symAdrFunChnArr);
	delete symAdrFunChnArr;
		
	return rawDatCVsstGlbPub;
}

/**************************************************************************************************/
/*** Erstellen des CV sstGlobalTypes (0x12B) ******************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstGlobalTypes()
{
	mySstGloTypInfRec *aSstGlbTypInfRec;
	CMyMemFile								*rawDatCVsstGlbTyp= NULL;

 DWORD gloTypNum= 0x01;
 DWORD typOff= 0x00;
 DWORD typOffEntNum= 0x00;
	DWORD	typInd;
	DWORD	bytTilAlnEnd;
	DWORD *typOffArr;

	rawDatCVsstGlbTyp= new CMyMemFile();
	rawDatCVsstGlbTyp-> Write(&verSgnCV, sizeof(DWORD));
	rawDatCVsstGlbTyp-> Write(&sstGloTypInd, sizeof(DWORD));
	typOffArr= (DWORD *) malloc(sstGloTypInd * sizeof(DWORD));
	rawDatCVsstGlbTyp-> Write(typOffArr, sstGloTypInd * sizeof(DWORD));
	
	typOff= 0x00000000;
	
	for(typInd= 0; typInd < sstGloTypInd; typInd++)
	{
		typOffArr[typInd]= typOff;
		aSstGlbTypInfRec= (mySstGloTypInfRec *) sstGloTypArr-> GetAt(typInd);
		bytTilAlnEnd= BytesTillAlignEnd(aSstGlbTypInfRec-> symLen + sizeof(WORD), sizeof(DWORD));
		rawDatCVsstGlbTyp-> Write(&aSstGlbTypInfRec-> symLen, sizeof(WORD));
		rawDatCVsstGlbTyp-> Write(aSstGlbTypInfRec-> typRawDat, aSstGlbTypInfRec-> symLen);
		if (bytTilAlnEnd)
			rawDatCVsstGlbTyp-> Write(&chrBuf00, bytTilAlnEnd);
		typOff+= bytTilAlnEnd + aSstGlbTypInfRec-> symLen + sizeof(WORD);
		free(aSstGlbTypInfRec);
	}

	rawDatCVsstGlbTyp-> Seek(2 * sizeof(DWORD), CFile::begin);
	rawDatCVsstGlbTyp-> Write(typOffArr, sstGloTypInd * sizeof(DWORD));

	free(typOffArr);
	
	return rawDatCVsstGlbTyp;
}

/**************************************************************************************************/
/*** Erstellen des CV sstSegMap Moduls (0x12D) ****************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstSegMap() 
{
	mySstSegDisArr segMapEnt;
	CMyMemFile     *rawDatCVsstSegMap= NULL;
 CSection       *actExeFilSec;
 mySectionTable *actExeFilSecTab;

 POSITION  secLstPos;
 
 DWORD chkNum;
 WORD  sNum;

 rawDatCVsstSegMap= new CMyMemFile();
 
 sNum= newExeFil-> exeCofHdr.secNum + 1;
 rawDatCVsstSegMap-> Write(&sNum, sizeof(WORD));
 rawDatCVsstSegMap-> Write(&sNum, sizeof(WORD));

 secLstPos= newExeFil-> exeFilSecLst-> GetHeadPosition();

 for(int i= 0; i < newExeFil-> exeCofHdr.secNum; i++)
 {
  memset(&segMapEnt, 0x00, SST_SEG_MAP_ENT_SIZ);
  actExeFilSec= (CSection *)newExeFil-> exeFilSecLst-> GetNext(secLstPos);
  actExeFilSecTab= actExeFilSec-> actSecTab;
  
  chkNum= actExeFilSecTab-> chr & 0xF0000000;
  if (chkNum / 0x80000000) 
  {
   segMapEnt.frmWrt= 0x1;  
   chkNum%= 0x80000000;
  }
  if (chkNum / 0x40000000) 
  {
   segMapEnt.frmRed= 0x1;
   chkNum%= 0x40000000;
  }
  if (chkNum / 0x20000000) 
  {
   segMapEnt.frmExe= 0x1;  
   chkNum%= 0x20000000;
  }

  if (strcmp(actExeFilSec-> secNam, ".debug"))
  {
   segMapEnt.frmSel= 0x1;
   segMapEnt.segLen= actExeFilSec-> actSecTab-> virSiz;
   // Die neueste Linkerversion macht keine Alignment mehr.
			// segMapEnt.segLen+= BytesTillAlignEnd(actExeFilSec-> actSecTab-> virSiz, 0x200);
  }
  else
  {
   segMapEnt.frmAbs= 0x1;
   segMapEnt.segLen= 0xFFFFFFFF;
  }

  segMapEnt.frm32Bit= 0x1;
  segMapEnt.frm= actExeFilSec-> secNum;
  segMapEnt.segNamInd= segMapEnt.clsNamInd= 0xFFFF;
  segMapEnt.off= 0x0000;
  
  rawDatCVsstSegMap-> Write(&segMapEnt, SST_SEG_MAP_ENT_SIZ);
 }

 /* Letzter Eintrag ist folgender, weiss aber nicht warum */

 memset(&segMapEnt, 0x00, SST_SEG_MAP_ENT_SIZ);
 segMapEnt.frm32Bit= 0x1;
 segMapEnt.frmAbs= 0x1;
 segMapEnt.segNamInd= 0xFFFF;
 segMapEnt.clsNamInd= 0xFFFF;
 segMapEnt.segLen= 0xFFFFFFFF;

 rawDatCVsstSegMap-> Write(&segMapEnt, SST_SEG_MAP_ENT_SIZ);

 return rawDatCVsstSegMap;
}

/**************************************************************************************************/
/*** Erstellen des CV sstFileIndex Moduls (0x133) *************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstFileIndex(CMyObList *obFilLst) 
{
 CMyMemFile *rawDatCVsstFilInd;
	CMyMemFile *rawDatModSta;
	CMyMemFile *rawDatRefCnt;
	CMyMemFile *rawDatNamRef;
	CMyMemFile *rawDatNamTab;
	
	CObjFile			*actObjFil;

	POSITION objFilPos;

	DWORD	namTabOff;
	WORD		objModCnt;
	WORD		filNamRefCnt;
	WORD		refCntNmb= 0x0001;
	BYTE		srcFilNamLen;
	BYTE		*bytBuf;

 rawDatCVsstFilInd= new CMyMemFile();
	rawDatModSta= new CMyMemFile();
	rawDatRefCnt= new CMyMemFile();
	rawDatNamRef= new CMyMemFile();
	rawDatNamTab= new CMyMemFile();

	objFilPos= obFilLst-> GetHeadPosition();
	objModCnt= filNamRefCnt= 0;
	namTabOff= 0;
 
	while(objFilPos)
	{
		actObjFil= (CObjFile *) obFilLst-> GetNext(objFilPos);
		objModCnt++;
		if (actObjFil-> srcFilNam)
		{
			rawDatModSta-> Write(&filNamRefCnt, sizeof(WORD));
			rawDatRefCnt-> Write(&refCntNmb, sizeof(WORD));
			rawDatNamRef-> Write(&namTabOff, sizeof(DWORD));
			srcFilNamLen= strlen(actObjFil-> srcFilNam);
			rawDatNamTab-> Write(&srcFilNamLen, sizeof(BYTE));
			rawDatNamTab-> Write(actObjFil-> srcFilNam, srcFilNamLen);
			namTabOff+= srcFilNamLen + sizeof(BYTE);
			filNamRefCnt++;
		}
		else
		{
			rawDatModSta-> Write(chrBuf00, sizeof(WORD));
			rawDatRefCnt-> Write(chrBuf00, sizeof(WORD));
		}
	}

	rawDatCVsstFilInd-> Write(&objModCnt, sizeof(WORD));
	rawDatCVsstFilInd-> Write(&filNamRefCnt, sizeof(WORD));

	rawDatModSta-> SeekToBegin();
	bytBuf= (BYTE *) rawDatModSta-> ReadWithoutMemcpy();
	rawDatCVsstFilInd-> Write(bytBuf, rawDatModSta-> GetLength());

	rawDatRefCnt-> SeekToBegin();
	bytBuf= (BYTE *) rawDatRefCnt-> ReadWithoutMemcpy();
	rawDatCVsstFilInd-> Write(bytBuf, rawDatRefCnt-> GetLength());

	rawDatNamRef-> SeekToBegin();
	bytBuf= (BYTE *) rawDatNamRef-> ReadWithoutMemcpy();
	rawDatCVsstFilInd-> Write(bytBuf, rawDatNamRef-> GetLength());

	rawDatNamTab-> SeekToBegin();
	bytBuf= (BYTE *) rawDatNamTab-> ReadWithoutMemcpy();
	rawDatCVsstFilInd-> Write(bytBuf, rawDatNamTab-> GetLength());
 
	rawDatCVsstFilInd-> Write(chrBuf00, BytesTillAlignEnd(rawDatCVsstFilInd-> GetLength(), sizeof(DWORD)));           
 
	FreeCMyMemFile(rawDatModSta);
	FreeCMyMemFile(rawDatRefCnt);
	FreeCMyMemFile(rawDatNamRef);
	FreeCMyMemFile(rawDatNamTab);
	delete rawDatModSta;
	delete rawDatRefCnt;
	delete rawDatNamRef;
	delete rawDatNamTab;

	return rawDatCVsstFilInd;
}


/**************************************************************************************************/
/*** Erstellen des CV sstStaticSym Moduls (0x134) *************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::BuildCVsstStaSym()
{
 CMyMemFile *rawDatCVsstStaSym= NULL;
 rawDatCVsstStaSym= new CMyMemFile();
 
 rawDatCVsstStaSym-> Write(chrBuf00, 0x10);
 
 return rawDatCVsstStaSym;
}

/**************************************************************************************************/
/*** Hinzufügen der Daten eines CV Moduls und des dazugehörigen Verzeichniseintrag zu den						 ***/
/*** vorhandenen Modulen und Verzeichniseinträgen.																																														***/
/**************************************************************************************************/

BOOL AppandCVModAndDirectoryToCVModule(CMyMemFile *modRawDat, CMyMemFile *srcRawDat, CMyMemFile *subSecDirRawDat,
                                       WORD subDirInd, WORD modInd) 
{
 mySubsectionDirectoryEntry  subSecDirEnt;
 BYTE *datBuf;

 subSecDirEnt.subDirInd= subDirInd;
 subSecDirEnt.modInd= modInd;
 subSecDirEnt.entOff= modRawDat-> GetPosition();
 subSecDirEnt.bytNum= srcRawDat-> GetLength();
 srcRawDat-> SeekToBegin(); 
 datBuf= (BYTE *) srcRawDat-> ReadWithoutMemcpy(subSecDirEnt.bytNum);
 modRawDat-> Write(datBuf, subSecDirEnt.bytNum);
 subSecDirRawDat-> Write(&subSecDirEnt,	CV_SUB_SEC_DIR_ENT_SIZ);
	FreeCMyMemFile(srcRawDat);
	delete srcRawDat;
		
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::CalculateTypeIndizes40(WORD symTyp, WORD symLen, CMyMemFile *rawDatSecT, 
																																																WORD objFilTypInd, CPtrArray *objFilTypArr, CObjFile *aObjFil)
{
	DWORD actTypFilPos;
	DWORD	typStaFilPos;
	WORD  symInd;
	WORD		numLefOff;
	WORD		sTyp;
	WORD		argCntW;
	BYTE		namLen;

	switch (symTyp)
	{
		case 0x0001: /* Type Modifier */
		case 0x0002:	/* Pointer */
		case 0x0006: /* Unions */
		case 0x0007: /* Enumerations */
		case 0x0206: /* Bit Fields */
		case 0x0207:	/* Method List */
		case 0x0208: /* Dimensioned Array wiht Constant Upper Bound */
		case 0x0209: /* Dimensioned Array with Constant Lower and Upper Bounds */
		case 0x020A:	/* Dimensioned Array with Variable Upper Bound */
		case 0x020B:	/* Dimensioned Array with Variable Lower and Upper Bounds */
		case 0x0408:	/* Method */
		case 0x040C:	/* One Method */
							
				rawDatSecT-> Seek(sizeof(WORD), CFile::current);
						
		case 0x0008: /* Procedure */
		case 0x000D: /* Basic Array */
		case 0x0202: /* Default Argument */
		case 0x0400: /* Real Base Class */
		case 0x0404:	/* Friend Function */
		case 0x0405:	/* Index To Another Type Record */
		case 0x0406:	/* Data Member */
		case 0x0407:	/* Static Data Member */
		case 0x0409:	/* Nested Type Definition */
		case 0x040A:	/* Virtual Function Table Pointer */
		case 0x040B:	/* Friend Class */
		case 0x040D:	/* Virtual Function Offset */

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
							
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

				if (symTyp == 0x0008)
				{
					rawDatSecT-> Seek(2 * sizeof(BYTE) + sizeof(WORD), CFile::current);
					actTypFilPos= rawDatSecT-> GetPosition();
					rawDatSecT-> Read(&symInd, sizeof(WORD));
							
					symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

					if (symInd)
					{
						rawDatSecT-> Seek(actTypFilPos, CFile::begin);
						rawDatSecT-> Write(&symInd, sizeof(WORD));							
					}
				}


			break;
				
		case 0x0009: /* Member Functions */
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symTyp, sizeof(WORD));
							
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

		case 0x0003: /* Simple Array */
		case 0x0011: /* Multiply Dimensioned Array */
		case 0x0401:	/* Direct Virtual Base Class */
		case 0x0402: /* Indirect Virtual Base Class */
						
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
						
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
						
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

		 break;

		case 0x0004: /* Classes */
		case 0x0005: /* Structures */
							
				rawDatSecT-> Seek(sizeof(WORD), CFile::current);
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

				rawDatSecT-> Seek(sizeof(WORD), CFile::current);
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(WORD));
				symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(WORD));							
				}

			break;

		case 0x0012: /* Path to Virtual Function Table */
		case 0x0201:	/* Argument List */
		case 0x0205: /* Derived Classes */

				rawDatSecT-> Read(&argCntW, sizeof(WORD));
								
				while(argCntW)
				{
					actTypFilPos= rawDatSecT-> GetPosition();
					rawDatSecT-> Read(&symInd, sizeof(WORD));
							
					symInd= SetPESymbolType40(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

					if (symInd)
					{
						rawDatSecT-> Seek(actTypFilPos, CFile::begin);
						rawDatSecT-> Write(&symInd, sizeof(WORD));							
					}

					argCntW--;
				}

			break;

		case 0x0204:	/* Field List */

				typStaFilPos= actTypFilPos= rawDatSecT-> GetPosition();
				typStaFilPos-= sizeof(DWORD);
				
				while(actTypFilPos < typStaFilPos + symLen) 
				{
					char sBuf[10];
					
					memset(sBuf, 0x00, 10);

					rawDatSecT-> Read(&sTyp, sizeof(WORD));

					if (sTyp != 0x406)
					{
						wsprintf(sBuf, "Debugtyp in 0x204: 0x%04X", sTyp);
						WriteMessageToPow(MSG_NUL, (char *)sBuf, NULL);
					}
					CalculateTypeIndizes40(sTyp, symLen, rawDatSecT, objFilTypInd, objFilTypArr, aObjFil);
																																		 
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
				
					switch (sTyp)
					{
						case 0x406:
							numLefOff= 3 * sizeof(WORD);
							rawDatSecT-> Seek(numLefOff, CFile::current);
					
							
							/*** Numeric Leaf ***/
							
							SeekNumericLeaf(rawDatSecT);
							rawDatSecT-> Read(&namLen, sizeof(BYTE));
							rawDatSecT-> Seek(namLen, CFile::current);
							if (BytesTillAlignEnd(rawDatSecT-> GetPosition(), sizeof(DWORD)))
								rawDatSecT-> Seek(BytesTillAlignEnd(rawDatSecT-> GetPosition(), sizeof(DWORD)), CFile::current);

							break;

						default: rawDatSecT-> Seek(symLen - sizeof(DWORD), CFile::current);
					
					}
					actTypFilPos= rawDatSecT-> GetPosition();
				}

			break;

		default: ;
					
	}		
	
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::CalculateTypeIndizes50(WORD symTyp, WORD symLen, CMyMemFile *rawDatSecT, 
																																																		DWORD objFilTypInd, CPtrArray *objFilTypArr, CObjFile *aObjFil)
{
	DWORD actTypFilPos;
	DWORD	typStaFilPos;
	DWORD argCntDW;
	DWORD symInd;
	WORD		sTyp;
	WORD		numLefOff;
	BYTE		namLen;

	switch (symTyp)
	{
		case 0x1006: /* Unions */
		case 0x1007: /* Enumerations */
		case 0x1206:	/* Method List */
		
				rawDatSecT-> Seek(sizeof(WORD), CFile::current);
		
		case 0x1400: /* Real Base Class */
		case 0x1403:	/* Friend Function */
		case 0x1404:	/* Index To Another Type Record */
		case 0x1405:	/* Data Member */
		case 0x1406:	/* Static Data Member */
		case 0x1407:	/* Method */
		case 0x1408:	/* Nested Type Definition */
		case 0x1409:	/* Virtual Function Table Pointer */
		case 0x140A:	/* Friend Class */
		case 0x140B:	/* One Method */
		case 0x140C:	/* Virtual Function Offset */
		case 0x140D:	/* Nested Type Extended Definition */
		case 0x040F:	/* Member Modification */
																									 
				rawDatSecT-> Seek(sizeof(WORD), CFile::current);

		case 0x1001: /* Type Modifier */
		case 0x1002:	/* Pointer */
		case 0x1008: /* Procedure */
		case 0x100B: /* Basic Array */
		case 0x1202: /* Default Argument */
		case 0x1205: /* Bit Fields */
		case 0x1207: /* Dimensioned Array with Constant Upper Bound */
		case 0x0209: /* Dimensioned Array with Constant Lower and Upper Bounds */
		case 0x020A:	/* Dimensioned Array with Variable Upper Bound */
		case 0x020B:	/* Dimensioned Array with Variable Lower and Upper Bounds */
		
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
							
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

				if (symTyp == 0x1008)
				{
					rawDatSecT-> Seek(2 * sizeof(BYTE) + sizeof(WORD), CFile::current);
					actTypFilPos= rawDatSecT-> GetPosition();
					rawDatSecT-> Read(&symInd, sizeof(DWORD));
							
					symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

					if (symInd)
					{
						rawDatSecT-> Seek(actTypFilPos, CFile::begin);
						rawDatSecT-> Write(&symInd, sizeof(DWORD));							
					}
				}


			break;
				
		case 0x1009: /* Member Functions */
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symTyp, sizeof(DWORD));
							
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

		case 0x1003: /* Simple Array */
		case 0x100C: /* Multiply Dimensioned Array */
		case 0x1401:	/* Direct Virtual Base Class */
		case 0x1402: /* Indirect Virtual Base Class */
						
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
						
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
						
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

		 break;

		case 0x1004: /* Classes */
		case 0x1005: /* Structures */
							
				rawDatSecT-> Seek(sizeof(DWORD), CFile::current);
				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
				symInd= SetPESymbolType50(symInd, (WORD )objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

				actTypFilPos= rawDatSecT-> GetPosition();
				rawDatSecT-> Read(&symInd, sizeof(DWORD));
				symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);
				if (symInd)
				{
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
					rawDatSecT-> Write(&symInd, sizeof(DWORD));							
				}

			break;

		case 0x100D: /* Path to Virtual Function Table */
		case 0x1201:	/* Argument List */
		case 0x1204: /* Derived Classes */

				rawDatSecT-> Read(&argCntDW, sizeof(DWORD));
								
				while(argCntDW)
				{
					actTypFilPos= rawDatSecT-> GetPosition();
					rawDatSecT-> Read(&symInd, sizeof(DWORD));
							
					symInd= SetPESymbolType50(symInd, objFilTypInd, objFilTypArr, aObjFil-> objFilNam);

					if (symInd)
					{
						rawDatSecT-> Seek(actTypFilPos, CFile::begin);
						rawDatSecT-> Write(&symInd, sizeof(DWORD));							
					}

					argCntDW--;
				}

			break;

		case 0x1203:	/* Field List */

				typStaFilPos= actTypFilPos= rawDatSecT-> GetPosition();
				typStaFilPos-= sizeof(DWORD);
				
				while(actTypFilPos < typStaFilPos + symLen) 
				{
					char sBuf[10];
					
					memset(sBuf, 0x00, 10);

					rawDatSecT-> Read(&sTyp, sizeof(WORD));

					if (sTyp != 0x1405)
					{
						wsprintf(sBuf, "Debugtyp in 0x1203: 0x%04X", sTyp);
						WriteMessageToPow(MSG_NUL, (char *)sBuf, NULL);
					}
					CalculateTypeIndizes50(sTyp, symLen, rawDatSecT, objFilTypInd, objFilTypArr, aObjFil);
																																		 
					rawDatSecT-> Seek(actTypFilPos, CFile::begin);
				
					switch (sTyp)
					{
						case 0x1405:
							numLefOff= 2 * sizeof(WORD) + sizeof(DWORD);
							rawDatSecT-> Seek(numLefOff, CFile::current);
					
							
							/*** Numeric Leaf ***/
							SeekNumericLeaf(rawDatSecT);
							rawDatSecT-> Read(&namLen, sizeof(BYTE));
							rawDatSecT-> Seek(namLen, CFile::current);
							if (BytesTillAlignEnd(rawDatSecT-> GetPosition(), sizeof(DWORD)))
								rawDatSecT-> Seek(BytesTillAlignEnd(rawDatSecT-> GetPosition(), sizeof(DWORD)), CFile::current);

							break;

						default: rawDatSecT-> Seek(symLen - sizeof(DWORD), CFile::current);
					
					}
					actTypFilPos= rawDatSecT-> GetPosition();
				}

			break;

		default: ;
					
	}		
	
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/******************************************************/
/*** Ermitteln des Symboltypindexes in der PE-Datei ***/
/******************************************************/

WORD CExeFileDebugSection::SetPESymbolType40(WORD sTyp, WORD objFilTypInd, CPtrArray	*objFilTypArr, char *objFilNam)
{
	mySstGloTypInfRec	*aSstGloTypInf;
	char														msgBuf[10];	
	
	if (sTyp >= 0x1000)
	{
		if (sTyp < objFilTypInd + 0x1000)
		{
			aSstGloTypInf= (mySstGloTypInfRec *) objFilTypArr-> GetAt(sTyp - 0x1000); 
			if (aSstGloTypInf-> sstGloTypInd == 0xFFFFFFFF)
			{
				aSstGloTypInf-> sstGloTypInd= sstGloTypInd + 0x1000;
				sstGloTypArr-> SetAtGrow(sstGloTypInd, aSstGloTypInf);
				sstGloTypInd++;
			}
		aSstGloTypInf-> typRefNmb++;
		}
		else
		{
			memset(msgBuf, 0x00, 256);
			wsprintf((char *)msgBuf, "\n0X%04x", sTyp);
			WriteMessageToPow(WRN_MSGD_NO_SYM_IND, (char *)msgBuf, objFilNam);
			return 0x0000;
		}
		return (WORD )aSstGloTypInf-> sstGloTypInd;
	}
	return 0x0000;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

DWORD CExeFileDebugSection::SetPESymbolType50(DWORD sTyp, DWORD objFilTypInd, CPtrArray	*objFilTypArr, char *objFilNam)
{
	mySstGloTypInfRec	*aSstGloTypInf;
	char														msgBuf[10];	
	
	if ((sTyp >= 0x1000) && (sTyp < 0x8000))
	{
		if (sTyp < objFilTypInd + 0x1000)
		{
			aSstGloTypInf= (mySstGloTypInfRec *) objFilTypArr-> GetAt(sTyp - 0x1000); 
			if (aSstGloTypInf-> sstGloTypInd == 0xFFFFFFFF)
			{
				aSstGloTypInf-> sstGloTypInd= sstGloTypInd + 0x1000;
				sstGloTypArr-> SetAtGrow(sstGloTypInd, aSstGloTypInf);
				sstGloTypInd++;
			}
		aSstGloTypInf-> typRefNmb++;
		}
		else
		{
			memset(msgBuf, 0x00, 256);
			wsprintf((char *)msgBuf, "\n0X%04x", sTyp);
			WriteMessageToPow(WRN_MSGD_NO_SYM_IND, (char *)msgBuf, objFilNam);
			return 0x0000;
		}
		return aSstGloTypInf-> sstGloTypInd;
	}
	return 0x0000;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::ChgDbgForSecTToCV4(CMyMemFile *oldRawDatSecT)
{
	return NULL;  // Not implemented yet !
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::ChgDbgForSecTToCV5(CMyMemFile *oldRawDatSecT)
{
	pointerAttributesCV4 ptrAttCV4;
	pointerAttributesCV5 ptrAttCV5;
	mySymbolRecord							oldSymRecHdr;
	mySymbolRecord							newSymRecHdr;
	CMyMemFile											*newRawDatSecT;
	
	DWORD		actFilPosOld;
	DWORD		filPosSymHdrNew;
	DWORD		actFilPosNew;
	DWORD		bufDW1, bufDW2, bufDW3, bufDW4, bufDW5;
	WORD			subFldSymNew;
	WORD			subFldSymOld;
	WORD			bufW1, bufW2, bufW3, bufW4, bufW5;
	WORD			bytTilAlnEnd;
	BYTE			msgBuf[256];
	BYTE			bytBuf[256];
	BYTE			namLen;
	WORD			i;

	newRawDatSecT= new CMyMemFile();

	newRawDatSecT-> Write(&verSgnCV, sizeof(DWORD));
	oldRawDatSecT-> Seek(sizeof(DWORD), CFile::begin);

	while(oldRawDatSecT-> Read(&oldSymRecHdr, sizeof(oldSymRecHdr)))
	{
		/*** Ermitteln des neuen Symboltyps und der neuen Symbollänge ***/
		
		filPosSymHdrNew= newRawDatSecT-> GetPosition();
		newRawDatSecT-> Seek(sizeof(mySymbolRecord), CFile::current);		
		actFilPosOld= oldRawDatSecT-> GetPosition() - sizeof(DWORD);

		switch(oldSymRecHdr.symTyp)
		{
			case 0x0001: /* Type Modifier */
			case 0x0206: /* Bit Fieds */
					if (oldSymRecHdr.symTyp == 0x0001)
						newSymRecHdr.symTyp= 0x1001;
					else
						newSymRecHdr.symTyp= 0x1205;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD)); // attribute/length, position
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));	// index/@type
					bufDW1= 0;
					bufDW1+= bufW2;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD)); // index/@type
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));			// attribute/length, position
				break;

				
			case 0x0002: /* Pointer */
					newSymRecHdr.symTyp= 0x1002;
					oldRawDatSecT-> Read(&ptrAttCV4, sizeof(pointerAttributesCV4));			// attribute
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// index
					bufDW2= 0;
					bufDW2+= bufW2;
					memset(&ptrAttCV5, 0x00, sizeof(pointerAttributesCV5));
					ptrAttCV5.ptrtype= ptrAttCV4.ptrtype;
					ptrAttCV5.ptrmode= ptrAttCV4.ptrmode;
					ptrAttCV5.isflat32= ptrAttCV4.isflat32;
					ptrAttCV5.volatil= ptrAttCV4.volatil;
					ptrAttCV5.cons= ptrAttCV4.cons;
					ptrAttCV5.unaligned= ptrAttCV4.unaligned;
										
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));			// index
					newRawDatSecT-> Write(&ptrAttCV5, sizeof(pointerAttributesCV5));			// attribute
			
					if (ptrAttCV5.ptrmode == 2)  // Pointer To Data Member
					{
						oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @class
						bufDW1= 0;
						bufDW1+= bufW1;
						newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));			// @class
						oldRawDatSecT-> Read(&bytBuf, oldSymRecHdr.recLen - 4 * sizeof(WORD));  
						newRawDatSecT-> Write(&bytBuf, oldSymRecHdr.recLen - 4 * sizeof(WORD));  				
					}
					else
					{
						oldRawDatSecT-> Read(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD));  
						newRawDatSecT-> Write(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD));  				
					}

				break;

			case 0x0003: /* Simple Array */
					newSymRecHdr.symTyp= 0x1003;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @elemtype
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @idxtype
					bufDW1= 0;
					bufDW1+= bufW1;
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));			// @elemtype
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));			// @idxtype

					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break; 

			case 0x0004: /* Classes */
			case 0x0005: /* Structures */
					if (oldSymRecHdr.symTyp == 0x0004)
						newSymRecHdr.symTyp= 0x1004;
					else
						newSymRecHdr.symTyp= 0x1005;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// count
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @field
					oldRawDatSecT-> Read(&bufW3, sizeof(WORD));			// property
					oldRawDatSecT-> Read(&bufW4, sizeof(WORD));			// @dList
					oldRawDatSecT-> Read(&bufW5, sizeof(WORD));			// @vshape
					bufDW2= bufDW4= bufDW5= 0;
					bufDW2+= bufW2;
					bufDW4+= bufW4;
					bufDW5+= bufW5;
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));					// count
					newRawDatSecT-> Write(&bufW3, sizeof(WORD));					// property
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));			// @field
					newRawDatSecT-> Write(&bufDW4, sizeof(DWORD));			// @dList
					newRawDatSecT-> Write(&bufDW5, sizeof(DWORD));			// @vshape
					
					WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // length
					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break;

			case 0x0006: /* Unions */
					newSymRecHdr.symTyp= 0x1006;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// count
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @field
					oldRawDatSecT-> Read(&bufW3, sizeof(WORD));			// property
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));					// count
					newRawDatSecT-> Write(&bufW3, sizeof(WORD));					// property
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));			// @field

					WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // length
					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break;
				
			case 0x0007: /* Enumeration */
					newSymRecHdr.symTyp= 0x1007;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// count
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @type
					oldRawDatSecT-> Read(&bufW3, sizeof(WORD));			// @fList
					oldRawDatSecT-> Read(&bufW4, sizeof(WORD));			// property
					bufDW2= bufDW3= 0;
					bufDW2+= bufW2;
					bufDW3+= bufW3;
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));					// count
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));			// @field
					newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));			// @dList
					newRawDatSecT-> Write(&bufW4, sizeof(WORD));					// property
				
					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break;

			case 0x0008: /* Procedure */
					newSymRecHdr.symTyp= 0x1008;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// @rvtype
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));		// call, reserved
					oldRawDatSecT-> Read(&bufW3, sizeof(WORD));		// #parms
					oldRawDatSecT-> Read(&bufW4, sizeof(WORD));		// @arglist
					bufDW1= bufDW4= 0;
					bufDW1+= bufW1;
					bufDW4+= bufW4;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @rvtype
					newRawDatSecT-> Write(&bufW2, sizeof(WORD));				// call, reserved
					newRawDatSecT-> Write(&bufW3, sizeof(WORD));				// #parms
					newRawDatSecT-> Write(&bufDW4, sizeof(DWORD));		// @arglist					
				break;

			case 0x0009: /* Member Function */
					newSymRecHdr.symTyp= 0x1009;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// @rvtype
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));		// @class
					oldRawDatSecT-> Read(&bufW3, sizeof(WORD));		// @this
					oldRawDatSecT-> Read(&bufW4, sizeof(WORD));		// call
					oldRawDatSecT-> Read(&bufW5, sizeof(WORD));		// res
					bufDW1= bufDW2= bufDW3= 0;
					bufDW1+= bufW1;
					bufDW2+= bufW2;
					bufDW3+= bufW3;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @rvtype
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @class
					newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));		// @this
					newRawDatSecT-> Write(&bufW4, sizeof(WORD));				// call
					newRawDatSecT-> Write(&bufW5, sizeof(WORD));				// res
					
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// #parms
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));		// @arglist
					oldRawDatSecT-> Read(&bufDW3, sizeof(DWORD));		// thisadjust
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));				// #parms
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @arglist
					newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));		// thisadjust
				break;

			case 0x000A: /* Virtual Function Table Shape */
			case 0x0014:	/* End Of Precompiled Types */
				 newSymRecHdr= oldSymRecHdr;
					oldRawDatSecT-> Read(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));  
					newRawDatSecT-> Write(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));  
				break;

			case 0x0011: /* Multiply Dimensioned Array */
					newSymRecHdr.symTyp= 0x100C;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// @utype
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));		// @diminfo
					bufDW1= bufDW2= 0;
					bufDW1+= bufW1;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @utype
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @diminfo

					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break;

			case 0x0012: /* Path To Virtual Funciton Table */
			case 0x0201: /* Argument List */
			case 0x0205:	/* Derived Classes */
					if (oldSymRecHdr.symTyp == 0x0012)
						newSymRecHdr.symTyp= 0x100D;
					else
					{
						if (oldSymRecHdr.symTyp == 0x0201)
							newSymRecHdr.symTyp= 0x1201;
						else
							newSymRecHdr.symTyp= 0x1204;
					}
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// count
					bufDW1= 0;
					bufDW1+= bufW1;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// count
					for(i= 0; i < bufW1; i++)
					{
						oldRawDatSecT-> Read(&bufW2, sizeof(WORD));	// bases
						bufDW2= 0;
						bufDW2+= bufW2;
						newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// count					
					}
					bytTilAlnEnd= (WORD )BytesTillAlignEnd(oldRawDatSecT-> GetPosition(), sizeof(DWORD));
					if (bytTilAlnEnd)
						oldRawDatSecT-> Seek(bytTilAlnEnd, CFile::current);
				break;

			case 0x0013: /* Reference Precompiled Types */
					newSymRecHdr.symTyp= 0x0013;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// start
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// count
					oldRawDatSecT-> Read(&bufDW3, sizeof(DWORD));	// signature
					bufDW1= bufDW2= 0;
					bufDW1+= bufW1;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// start
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// count
					newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));		// signature
					
					oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
					newRawDatSecT-> Write(&namLen, sizeof(BYTE));
					oldRawDatSecT-> Read(&bytBuf, namLen);  
					newRawDatSecT-> Write(&bytBuf, namLen);  
				break;

			case 0x0200: /* Skip */
			case 0x0202: /* Default Argument */
					if (oldSymRecHdr.symTyp == 0x0200)
						newSymRecHdr.symTyp= 0x1200;
					else
						newSymRecHdr.symTyp= 0x1202;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// index
					bufDW1= 0;
					bufDW1+= bufW1;
					newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// index					
				break;

			case 0x0204: /* Field List */
					newSymRecHdr.symTyp= 0x1203;
					
					while(oldRawDatSecT-> GetPosition() - actFilPosOld < oldSymRecHdr.recLen)
					{
						oldRawDatSecT-> Read(&subFldSymOld, sizeof(WORD));
						switch (subFldSymOld)
						{
							case 0x0400: /* Real Base Class */
									subFldSymNew= 0x1400;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @type
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// attribute
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&bufW2, sizeof(WORD));				// attribute
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @type
				
									/*** Numeric Leaf ***/
									WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // offset
								break;

							case 0x0401: /* Direct Virtual Base Class */
							case 0x0402: /* Indirect Virtual Base Class */

									subFldSymNew= subFldSymOld + 0x1000;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @btype
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @vbtype
									oldRawDatSecT-> Read(&bufW3, sizeof(WORD));			// attribute
									bufDW1= bufDW2= 0;
									bufDW1+= bufW1;
									bufDW2+= bufW2;
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @btype
									newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @vbtype
									newRawDatSecT-> Write(&bufW2, sizeof(WORD));				// attribute
												
									/*** Numeric Leaf ***/
								
									WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // vbpoff
									WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // vboff
								break;

							case 0x0403: /* Enumeration Name and Value */
									subFldSymNew= subFldSymOld;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// attribute
									newRawDatSecT-> Write(&bufW1, sizeof(WORD));				// attribute
				
									/*** Numeric Leaf ***/
								
									WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // value
								
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
								break;

							case 0x0404: /* Friend Function */
							case 0x0409: /* Nested Type Definition */
									subFldSymNew= subFldSymOld + 0x1000 - 1;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// @type/@index
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&chrBuf00, sizeof(WORD));		// pad
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));			// @type/@index
							
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
								break;

							case 0x0405: /* Index To Another Type Record */
							case 0x040A: /* Virtual Function Table Pointer */
							case 0x040B:	/* Friend Class */
									subFldSymNew= subFldSymOld;
									if (subFldSymOld != 0x040B)
										subFldSymNew+= 0x1000 - 1;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));		// @index/@type
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&chrBuf00, sizeof(WORD)); // pad
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @index/@type
								break;

							case 0x0406: /* Data Member */
									subFldSymNew= 0x1405;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @type
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// attribute
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&bufW2, sizeof(WORD));				// attribute
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @type
				
									/*** Numeric Leaf ***/
									
									WriteNumericLeaf(oldRawDatSecT, newRawDatSecT); // value
								
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
							break;

							case 0x0407: /* Static Data Member */
									subFldSymNew= 0x1406;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @type
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// attribute
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&bufW2, sizeof(WORD));				// attribute
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @type
				
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
								break;

							case 0x0408:	/* Method */
									subFldSymNew= 0x1407;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// count
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @mList
									bufDW2= 0;
									bufDW2+= bufW2;
									newRawDatSecT-> Write(&bufW1, sizeof(WORD));				// count
									newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @mList
				
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
								break;

							case 0x040C:	/* One Method */
									subFldSymNew= 0x140B;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// attribute
									oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @type
									oldRawDatSecT-> Read(&bufDW3, sizeof(DWORD));	// vbaseoff
									bufDW2= 0;
									bufDW2+= bufW2;
									newRawDatSecT-> Write(&bufW1, sizeof(WORD));				// attribute
									newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @type
									newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));		// vbaseoff
				
									oldRawDatSecT-> Read(&namLen, sizeof(BYTE));
									oldRawDatSecT-> Read(&bytBuf, namLen);
									newRawDatSecT-> Write(&namLen, sizeof(BYTE));
									newRawDatSecT-> Write(&bytBuf, namLen);
								break;

							case 0x040D:	/* Virtual Function Offset */
									subFldSymNew= 0x140C;
									newRawDatSecT-> Write(&subFldSymNew, sizeof(WORD));
									oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// @type
									oldRawDatSecT-> Read(&bufDW2, sizeof(DWORD));	// offset
									bufDW1= 0;
									bufDW1+= bufW1;
									newRawDatSecT-> Write(&chrBuf00, sizeof(WORD));	// pad
									newRawDatSecT-> Write(&bufDW1, sizeof(DWORD));		// @type
									newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// offset
								break;

							default: ;
						}
						bytTilAlnEnd= (WORD )BytesTillAlignEnd(newRawDatSecT-> GetPosition(), sizeof(DWORD));
						if (bytTilAlnEnd)
							WritePadBytes(newRawDatSecT, bytTilAlnEnd);

						bytTilAlnEnd= (WORD )BytesTillAlignEnd(oldRawDatSecT-> GetPosition(), sizeof(DWORD));
						if (bytTilAlnEnd)
							oldRawDatSecT-> Seek(bytTilAlnEnd, CFile::current);
					}
				break;

			case 0x0207: /* Method List */
					newSymRecHdr.symTyp= 0x1206;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// attribute
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @type
					oldRawDatSecT-> Read(&bufDW3, sizeof(DWORD));		// vtab offset
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufDW1, sizeof(WORD));			// attribute
					newRawDatSecT-> Write(&chrBuf00, sizeof(WORD)); // pad
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @type
					newRawDatSecT-> Write(&bufDW3, sizeof(DWORD));		// vtab offset
				break;

			case 0x0208: /* Dimensioned Array with Constant Upper Bound */
			case 0x0209:	/* Dimensioned Array with Constant Lower and Upper Bounds */
			case 0x020A: /* Dimensioned Array with Variable Upper Bound */
			case 0x020B: /* Dimensioned Array with Varialbe Lower and Upper Bounds */
					if (oldSymRecHdr.symTyp == 0x0208)
						newSymRecHdr.symTyp= 0x1207;
					else
						newSymRecHdr.symTyp= oldSymRecHdr.symTyp;
					oldRawDatSecT-> Read(&bufW1, sizeof(WORD));			// rank
					oldRawDatSecT-> Read(&bufW2, sizeof(WORD));			// @index
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecT-> Write(&bufDW2, sizeof(DWORD));		// @index
					newRawDatSecT-> Write(&bufW1, sizeof(WORD));			// rank
					oldRawDatSecT-> Read(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD));  
					newRawDatSecT-> Write(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD));  
				break;

			case 0x020C: /* Referenced Symbol */
					newSymRecHdr= oldSymRecHdr;
					oldRawDatSecT-> Read(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));  
					newRawDatSecT-> Write(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));  
				break;


			default:
					memset(msgBuf, 0x00, 256);
					wsprintf((char *)msgBuf, "Der Typ (0x%04X) wurde nicht verarbeitet", oldSymRecHdr.symTyp);
					WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
					oldRawDatSecT-> Seek(oldSymRecHdr.recLen - sizeof(WORD), CFile::begin);
		}
		bytTilAlnEnd= (WORD )BytesTillAlignEnd(oldRawDatSecT-> GetPosition(), sizeof(DWORD));
		if (bytTilAlnEnd)
			oldRawDatSecT-> Seek(bytTilAlnEnd, CFile::current);

		bytTilAlnEnd= (WORD )BytesTillAlignEnd(newRawDatSecT-> GetPosition(), sizeof(DWORD));
		if (bytTilAlnEnd)
			WritePadBytes(newRawDatSecT, bytTilAlnEnd);

		actFilPosNew= newRawDatSecT-> GetPosition();
		newSymRecHdr.recLen= (WORD )(actFilPosNew - filPosSymHdrNew - sizeof(WORD));
		newRawDatSecT-> Seek(filPosSymHdrNew, CFile::begin);
		newRawDatSecT-> Write(&newSymRecHdr, sizeof(oldSymRecHdr));
		newRawDatSecT-> Seek(actFilPosNew, CFile::begin);
	}
	
	newRawDatSecT-> SeekToBegin();

	return newRawDatSecT;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileDebugSection::WriteNumericLeaf(CMyMemFile *oldRawDat, CMyMemFile *newRawDat)
{
	WORD			numLef;
	WORD			numLefLen;
	BYTE			msgBuf[256];
	BYTE			bytBuf[256];
	
	oldRawDat-> Read(&numLef, sizeof(WORD));
	newRawDat-> Write(&numLef, sizeof(WORD));
	if (numLef >= 0x8000)
	{
		switch (numLef)
		{
			case 0x8000: /* Signed Char */
					numLefLen= 0x01; 
				break;
			case 0x8001: /* Signed Short */
			case 0x8002:	/* Unsigned Short */
					numLefLen= 0x02;
				break;
			case 0x8003: /* Signed Long */
			case 0x8004:	/* Unsigned Long */
			case 0x8005: /* 32 Bit Float */
					numLefLen= 0x04;
				break;
			default: 
					memset(msgBuf, 0x00, 256);
					wsprintf((char *)msgBuf, "Numeric Leaf (0x%04X) wurde nicht verarbeitet", numLef);
					WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
		}

		oldRawDat-> Read(&bytBuf, numLefLen);
		newRawDat-> Write(&bytBuf, numLefLen);
	}
	
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL SeekNumericLeaf(CMyMemFile *rawDat)
{
	WORD			numLef;
	WORD			numLefLen;
	BYTE			msgBuf[256];
	
	rawDat-> Read(&numLef, sizeof(WORD));
	if (numLef >= 0x8000)
	{
		switch (numLef)
		{
			case 0x8000: /* Signed Char */
					numLefLen= 0x01; 
				break;
			case 0x8001: /* Signed Short */
			case 0x8002:	/* Unsigned Short */
					numLefLen= 0x02;
				break;
			case 0x8003: /* Signed Long */
			case 0x8004:	/* Unsigned Long */
			case 0x8005: /* 32 Bit Float */
					numLefLen= 0x04;
				break;
			default: 
					memset(msgBuf, 0x00, 256);
					wsprintf((char *)msgBuf, "Numeric Leaf (0x%04X) wurde nicht verarbeitet", numLef);
					WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
		}
		rawDat-> Seek(numLefLen, CFile::current);
	}
	
	return TRUE;
}


/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::ChgDbgForSecSToCV4(CMyMemFile *oldRawDatSecS)
{
	return NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMemFile *CExeFileDebugSection::ChgDbgForSecSToCV5(CMyMemFile *oldRawDatSecS)
{
	mySymbolRecord							oldSymRecHdr;
	mySymbolRecord							newSymRecHdr;
	CMyMemFile											*newRawDatSecS;
	
	DWORD		filPosSymHdrNew;
	DWORD		actFilPosNew;
	DWORD		bufDW1, bufDW2, bufDW3, bufDW4;
	DWORD		verSgn;
	WORD			bufW1, bufW2, bufW3, bufW4;
	BYTE			msgBuf[256];
	BYTE			bytBuf[256];

	newRawDatSecS= new CMyMemFile();

	/* Überprüfen, ob die Debugsektion mit der Versionssignature beginnt (Erste .debug$S-Sektion */
	/* in der Objektdatei). */
	
	oldRawDatSecS-> SeekToBegin();
	oldRawDatSecS-> Read(&verSgn, sizeof(DWORD));
	if (verSgn != VER_SGN_CV4)
		oldRawDatSecS-> SeekToBegin();		// Keine Versionssignature -> gehe zum Sektionsanfang
	else
		newRawDatSecS-> Write(&verSgnCV, sizeof(DWORD)); 

	while(oldRawDatSecS-> Read(&oldSymRecHdr, sizeof(oldSymRecHdr)))
	{
		/*** Ermitteln des neuen Symboltyps und der neuen Symbollänge ***/
		
		filPosSymHdrNew= newRawDatSecS-> GetPosition();
		newRawDatSecS-> Seek(sizeof(mySymbolRecord), CFile::current);		

		switch(oldSymRecHdr.symTyp)
		{
			case 0x0001:	/* Compile Flag */
			case 0x0005: /* Start Search */
			case 0x0006:	/* End of Block */
			case 0x0007: /* Skip Record */
			case 0x0009: /* Object File Name */
			case 0x000A: /* End of Arguments */
			case 0x000D:	/* Function Return */
			case 0x000E:	/* this at Method Entry */
			case 0x0206:	/* Thunk Start 16:32 */
			case 0x0207:	/* Block Start 16:32 */
			case 0x0208: /* With Start 16:32 */
			case 0x0209: /* Code Label */
			case 0x020A:	/* Change Execution Model 16:32 */
			case 0x0400: /* Procedure Reference */
			case 0x0401:	/* Data Reference */
			case 0x0402: /* Symbol Page Alignment */
					newSymRecHdr.symTyp= oldSymRecHdr.symTyp;
					oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));
					newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - sizeof(WORD));
				break;

			case 0x0002: /* Register */
			case 0x0003:	/* Constant */
			case 0x0004: /* User-defined type */
			case 0x000C: /* Many Registers */
					if (oldSymRecHdr.symTyp == 0x000C)
						newSymRecHdr.symTyp= 0x1005;
					else
						newSymRecHdr.symTyp= oldSymRecHdr.symTyp + 0x1000 - 1;

					oldRawDatSecS-> Read(&bufW1, sizeof(WORD));			// @type
					bufDW1= 0;
					bufDW1+= bufW1;
					newRawDatSecS-> Write(&bufDW1, sizeof(DWORD));		// @type
					
					oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - 2 * sizeof(WORD));
					newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - 2 * sizeof(WORD));
				break;

			case 0x0200: /* BP Relative 16:32 */
					newSymRecHdr.symTyp= 0x1006;

					oldRawDatSecS-> Read(&bufDW1, sizeof(DWORD));	// offset
					oldRawDatSecS-> Read(&bufW2, sizeof(WORD));			// @type
					bufDW2= 0;
					bufDW2+= bufW2;
					newRawDatSecS-> Write(&bufDW1, sizeof(DWORD));		// offset
					newRawDatSecS-> Write(&bufDW2, sizeof(DWORD));		// @type
					
					oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - 2 * sizeof(WORD) - sizeof(DWORD));
					newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - 2 * sizeof(WORD) - sizeof(DWORD));
				break;

				case 0x0204: /* Local Procedure Start 16:32 */
				case 0x0205:	/* Global Procedure Start 16:32 */
						oldRawDatSecS-> Read(&bytBuf, 6 * sizeof(DWORD));
						newRawDatSecS-> Write(&bytBuf, 6 * sizeof(DWORD));
				case 0x0201: /* Local Data 16:32 */		
				case 0x0202: /* Global Data Symbol 16:32 */
				case 0x0203:	/* Public 16:32 */
				case 0x020D: /* Local Thread Storage 16:32 */
						if (oldSymRecHdr.symTyp < 0x020D)
							newSymRecHdr.symTyp= oldSymRecHdr.symTyp + 0xE06;
						else
							newSymRecHdr.symTyp= oldSymRecHdr.symTyp + 0x1000 + 1;

						oldRawDatSecS-> Read(&bufDW1, sizeof(DWORD));	// offset
						oldRawDatSecS-> Read(&bufW2, sizeof(WORD));			// segment
						oldRawDatSecS-> Read(&bufW3, sizeof(WORD));			// @type
						bufDW3= 0;
						bufDW3+= bufW3;
						newRawDatSecS-> Write(&bufDW3, sizeof(DWORD));	// @type
						newRawDatSecS-> Write(&bufDW1, sizeof(DWORD));	// offset
						newRawDatSecS-> Write(&bufW2, sizeof(WORD));			// segment
					
						if ((oldSymRecHdr.symTyp == 0x0204) || (oldSymRecHdr.symTyp == 0x0205))
						{
							oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - 7 * sizeof(DWORD));
							newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - 7 * sizeof(DWORD));
						}
						else
						{
							oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - sizeof(DWORD));
							newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - sizeof(DWORD));
						}
				break;

				case 0x020B: /* Change Execution Model 16:32 */
						newSymRecHdr.symTyp= oldSymRecHdr.symTyp + 0x1000 + 1;

						oldRawDatSecS-> Read(&bufDW1, sizeof(DWORD));	// offset
						oldRawDatSecS-> Read(&bufW2, sizeof(WORD));			// segment
						oldRawDatSecS-> Read(&bufW3, sizeof(WORD));			// @root
						oldRawDatSecS-> Read(&bufW4, sizeof(WORD));			// @path
						bufDW3= bufDW4= 0;
						bufDW3+= bufW3;
						bufDW4+= bufW4;
						newRawDatSecS-> Write(&bufDW3, sizeof(DWORD));	// @root
						newRawDatSecS-> Write(&bufDW4, sizeof(DWORD));	// @path
						newRawDatSecS-> Write(&bufDW1, sizeof(DWORD));	// offset
						newRawDatSecS-> Write(&bufW2, sizeof(WORD));			// segment
				break;

			case 0x020C:	/* Register Relative 16:32 */
						newSymRecHdr.symTyp= oldSymRecHdr.symTyp + 0x1000 + 1;

						oldRawDatSecS-> Read(&bufDW1, sizeof(DWORD));	// offset
						oldRawDatSecS-> Read(&bufW2, sizeof(WORD));			// register
						oldRawDatSecS-> Read(&bufW3, sizeof(WORD));			// @type
						bufDW3= 0;
						bufDW3+= bufW3;
						newRawDatSecS-> Write(&bufDW1, sizeof(DWORD));	// offset
						newRawDatSecS-> Write(&bufDW3, sizeof(DWORD));	// @type
						newRawDatSecS-> Write(&bufW2, sizeof(WORD));			// register
					
						oldRawDatSecS-> Read(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - sizeof(DWORD));
						newRawDatSecS-> Write(&bytBuf, oldSymRecHdr.recLen - 3 * sizeof(WORD) - sizeof(DWORD));
				break;
					
			default:
					memset(msgBuf, 0x00, 256);
					wsprintf((char *)msgBuf, "Der Typ (0x%04X) wurde nicht verarbeitet", oldSymRecHdr.symTyp);
					WriteMessageToPow(MSG_NUL, (char *)msgBuf, NULL);
					oldRawDatSecS-> Seek(oldSymRecHdr.recLen - sizeof(WORD), CFile::begin);
		}
		actFilPosNew= newRawDatSecS-> GetPosition();
		newSymRecHdr.recLen= (WORD )(actFilPosNew - filPosSymHdrNew - sizeof(WORD));
		newRawDatSecS-> Seek(filPosSymHdrNew, CFile::begin);
		newRawDatSecS-> Write(&newSymRecHdr, sizeof(oldSymRecHdr));
		newRawDatSecS-> Seek(actFilPosNew, CFile::begin);
	}
	
	newRawDatSecS-> SeekToBegin();

	return newRawDatSecS;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL WritePadBytes(CMyMemFile *rawDat, WORD bytTilAlnEnd)
{
	WORD padInd;
	BYTE	padVal;

	padVal= 0xF0 + bytTilAlnEnd;

	for(padInd= 0; padInd < bytTilAlnEnd; padInd++)
	{
		rawDat-> Write(&padVal, sizeof(BYTE));
		padVal--;
	}
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BYTE byt_toupper(BYTE byt)
{
	return byt & 0xDF;
}



/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

DWORD dwrd_toupper(DWORD dwrd)
{
	return dwrd & 0xDFDFDFDF;
}

/**************************************************************************************************/
/*** Hashalgorithmus zum Erstellen der Hashtabelleneinträge der sstGlobalSym, sstGlobalPub und		***/
/*** sstStaticSym CV Module. Siehe CV 4 und CV 5.0 Symoblic Debug Information Specification					***/
/**************************************************************************************************/

DWORD GiveTableHash(char *lpbName)
{
	DWORD ulEnd= 0;
	DWORD ulSum= 0;
	DWORD *lpulName;
	WORD  cb= strlen(lpbName);
	WORD  iul;
	WORD  cul;

	while(cb & 3)
	{
		ulEnd|= byt_toupper(lpbName[cb -1]);
		ulEnd<<= 8;
		cb-= 1;
	}
	cul= cb / 4;
	lpulName= (DWORD *)lpbName;
	for(iul= 0; iul < cul; iul++)
	{
		ulSum^= dwrd_toupper(lpulName[iul]);
		ulSum= _lrotl(ulSum, 4);
	}
	return ulSum ^= ulEnd;
}

