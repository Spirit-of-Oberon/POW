/**************************************************************************************************/
/*** Die Datei Section.cpp beinhaltet die Implementierung folgender Klassen:																				***/
/***			CSection																																																																																	***/
/***			CObjFileSection																																																																										***/
/***   CExeFileDataSection																																																																						***/
/***   CExeFileTextSection																																																																						***/
/***   CExeFileBssSection																																																																							***/
/***   CExeFileImportSection																																																																				***/
/***   CExeFileExportSection																																																																				***/
/***			CExeFileRsrcSection																																																																						***/
/***			CExeFileRelocSection																																																																					***/
/**************************************************************************************************/

#include <malloc.h> // Zum Heapcheck
#include <stdlib.h>
#include <ctype.h>
#include <math.h>

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __PUBLIBEN_HPP__
#include "PubLibEn.hpp"
#endif

#ifndef __OBJFILE_HPP__
#include "ObjFile.hpp"
#endif

#ifndef __DEBUG_HPP__
#include "Debug.hpp"
#endif

extern DWORD GivNum(BYTE *strNum, WORD start, WORD endSgn);
extern DWORD CalcTimeDateStamp();
extern void TestHeap(void);

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

extern DWORD	CalcTimeDateStamp();
extern void FreeCResFileEntry(CResFileEntry *aCResFileEntry);
extern void FreeCMyObList(CMyObList *aCObList);
extern void FreeCMyMapStringToOb(CMyMapStringToOb *aCMyMapStringToOb);
extern void FreeCMyMapStringToPtr(CMyMapStringToPtr *aCMyMapStringToPtr);
extern void FreeCMyMemFile(CMyMemFile *aCMemFile);
extern void FreeCSectionFragmentEntry(CSectionFragmentEntry *aCSectionFragmentEntry);
extern void FreeCMapWordToOb(CMapWordToOb *aCMapWordToOb);
extern void FreeCDWordArray(CDWordArray *aCDWordArray);
extern void FreeCMyObArray(CMyObArray *aCObArray);
extern void FreeCDllExportEntry(CDllExportEntry *aCDllExportEntry);
extern void FreeCMyPtrList(CMyPtrList *);

extern	FILE		*logFil;
extern	char		*logFilNam;
extern 	int			logOn;   

extern BYTE chrBufCC[];
extern BYTE chrBuf00[];

IMPLEMENT_DYNAMIC(CSection, CObject)
IMPLEMENT_DYNAMIC(CObjFileSection, CSection)
IMPLEMENT_DYNAMIC(CExeFileDataSection, CSection)
IMPLEMENT_DYNAMIC(CExeFileTextSection, CExeFileDataSection)
IMPLEMENT_DYNAMIC(CExeFileBssSection, CExeFileDataSection)
IMPLEMENT_DYNAMIC(CExeFileImportSection, CSection)
IMPLEMENT_DYNAMIC(CExeFileExportSection, CSection)
IMPLEMENT_DYNAMIC(CExeFileRsrcSection, CSection)
IMPLEMENT_DYNAMIC(CExeFileRelocSection, CSection)
																																																													
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/
																							
CSection::CSection()
{
	secNam= NULL;									 
	secNum= 0;
 secRawDat= NULL;
	actSecTab= NULL;	
	freSecNam= FALSE;
 secRawDatSiz= 0;
 virSecAdr= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CSection::CSection(char *aSecNam, WORD sNum)
{
	secNam= aSecNam;
	secNum= sNum;
	secRawDat= NULL;
	actSecTab= NULL;	
	freSecNam= FALSE;
 secRawDatSiz= 0;
 virSecAdr= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Desstrukoren --*/
/*------------------*/

CSection::~CSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CSection::FreeUsedMemory()
{
 if (actSecTab)
	{
		free(actSecTab);
		actSecTab= NULL;
	}
	if (freSecNam)
	{
		free(secNam);
		freSecNam= FALSE;
	}
	secNam= NULL;
 if (secRawDat)
 {
  FreeCMyMemFile((CMyMemFile *)secRawDat);
		delete secRawDat;
		secRawDat= NULL;	
	}
	secNum= 0;
 secRawDatSiz= 0;
 virSecAdr= 0;
}

/**************************************************************************************************/
/*** Berechnung der restlichen Bytes bis zur nächsten Alignmentgrenze																											***/
/**************************************************************************************************/

DWORD CSection::BytesTillAlignEnd(DWORD aNum, WORD aAln)
{
   if (aAln && (aNum % aAln))
      return aAln - (aNum % aAln);
	
   return 0; 
}

/**************************************************************************************************/
/*** Ermittlen des Sektionsalignments aufgrund des entsprechenden Flags im Header der Sektion   ***/
/**************************************************************************************************/

void CSection::SetSecAlign()
{
    try {
//        aln= (WORD) pow(2,((actSecTab-> chr / 0x100000) | 0xFF0) - 0xFF1); !!!! changed 5.10.98 LEI
        aln= (WORD) pow(2,((actSecTab-> chr / 0x100000) | 0xFF0) - 0xFF0);
    } catch (...)
	{
		aln = 1;
	}
    if (!aln)
       aln = sizeof(DWORD);
}

/**************************************************************************************************/
/*** Schreiben der Rohdaten der Sektion an die akutelle Position der PE-Datei und initialisieren **/
/*** der dabei gewonnen Headerinformation.																																																							**/
/**************************************************************************************************/

BOOL CSection::GiveSecRawDataBlock(CMyMemFile *exeFilRawDat)
{
	BYTE *impSecRawDatBuf;

	actSecTab-> rawDatPtr= exeFilRawDat-> GetPosition();
	secRawDat-> SeekToBegin();
	impSecRawDatBuf= (BYTE *) secRawDat-> ReadWithoutMemcpy(secRawDatSiz);
	exeFilRawDat-> Write(impSecRawDatBuf, secRawDatSiz);
	actSecTab-> rawDatSiz= exeFilRawDat-> GetPosition() - actSecTab-> rawDatPtr;
	return TRUE;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CSection::WriteSecDataToFile()
{
 logFil= fopen(logFilNam, "a");
	fprintf(logFil, "\nSektionname  : % -12s", secNam);
	fprintf(logFil, "\nSektiongröße : %08X", actSecTab-> rawDatSiz);
	fprintf(logFil, "\nRelocationen : % 8d", actSecTab-> relNum);
	fprintf(logFil, "\nSectionFlags : %08X  aln: % 2d\n", actSecTab-> chr, aln);

	fclose(logFil);
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen: Schreibt die Rohdaten der Sektion georndet in eine Datei								***/
/**************************************************************************************************/

void CSection::WriteRawDataToFile(CFile * secRawData)
{	
	DWORD	writtenBytes= 0;
	DWORD	sekPos;
	DWORD i;
	BYTE		wordBuffer;
	int		 secWordBuffer;
	
	logFil = fopen(logFilNam,"a");
 if (secRawData && secRawData-> GetLength())
	{
		secRawData-> SeekToBegin();
		while (secRawData-> Read(&wordBuffer, 0x01))
		{
			if (!BytesTillAlignEnd(writtenBytes, 0x10))
			{
				fprintf(logFil, "     ");
				sekPos= secRawData-> GetPosition();
				if (sekPos > 16)
				{
					secRawData-> Seek(sekPos - 0x11, CFile::begin);			
					for(i= 0; i < 16; i++)
					{	
						secWordBuffer= 0;
						secRawData-> Read(&secWordBuffer, 1);
						if ((32 < secWordBuffer) && (secWordBuffer < 127))
       fprintf(logFil, "%c", secWordBuffer);
						else
							fprintf(logFil, ".", secWordBuffer);							
					}
					secRawData-> Seek(0x1, CFile::current);
  	 }
  	 fprintf(logFil, "\n%04X", writtenBytes);
			}
			else
			{
				if (!BytesTillAlignEnd(writtenBytes, 0x08))
					fprintf(logFil, " |");
			}
			fprintf(logFil, " %02X", wordBuffer);
			writtenBytes++;
		}      
		secRawData-> Seek(sekPos - 0x01, CFile::begin);			
		fprintf(logFil, "     ");
		for(i= 0; i < 16; i++)
		{	
			secWordBuffer= 0x00;
			secRawData-> Read(&secWordBuffer, 1);
			if ((32 < secWordBuffer) && (secWordBuffer < 127))
      	fprintf(logFil, "%c", secWordBuffer);
			else
				fprintf(logFil, ".", secWordBuffer);							
		}              
		fprintf(logFil, "\n");  
	}
	fclose(logFil);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CObjFileSection::CObjFileSection() : CSection()
{
	actFrgEnt= NULL;
 secRelBuf= NULL;
 secLinNumBuf= NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObjFileSection::CObjFileSection(char *aSecNam, WORD sNum) : CSection(aSecNam, sNum)
{
	actFrgEnt= NULL;	
 secRelBuf= NULL;
 secLinNumBuf= NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CObjFileSection::~CObjFileSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CObjFileSection::FreeUsedMemory()
{
	actSecTab= NULL;
	CSection::FreeUsedMemory();		
	if (actFrgEnt)
	{
	 FreeCSectionFragmentEntry(actFrgEnt);
		delete actFrgEnt;
		actFrgEnt= NULL;
	}
 secRelBuf= NULL;
 secLinNumBuf= NULL;
}

/**************************************************************************************************/
/*** Einlesen der Daten einer Sektion (Headerinformation, Rohdaten, Relokationen und Zeilennum- ***/
/*** mern), sowie aufarbeiten der erhaltenen Daten.																																													***/
/**************************************************************************************************/

BOOL CObjFileSection::ReadSecData(CMyMemFile *actObjRawDat, DWORD sekPos, CObjFile *secObjFil)
{
	DWORD oldRelOff= 0;
 DWORD strTabOff;
	WORD		actInd;
	
	// Vorsicht, wenn der secNam genau 8 Bytes groß ist, dann muß dafür gesorgt werden, 
	// daß der String auch abgeschlossen wird. Es könnte sonst ein Fehler auftreten.

	actObjRawDat-> Seek(sekPos, CFile::begin);
 actSecTab= (mySectionTable *)actObjRawDat-> ReadWithoutMemcpy(sizeof(mySectionTable));
 
	// Auswerten des Sectionnames, der länger als 8 Zeichen sein kann

	if ((47 < actSecTab-> secNam[1]) && (actSecTab-> secNam[1] < 58))
	{
	 sekPos= actObjRawDat-> GetPosition();
		strTabOff= GivNum(actSecTab-> secNam, 1, 0x00) + secObjFil-> objCofHdr.symTabPtr + secObjFil-> objCofHdr.symNum * 18;
		actObjRawDat-> Seek(strTabOff, CFile::begin);
  secNam= (char *)((CMyMemFile *)actObjRawDat)-> ReadWithoutMemcpy(30);
		actObjRawDat-> Seek(sekPos, CFile::begin);
 }
	else
 {
  secNam= (char *)actSecTab-> secNam;	// Funktioniert nur, da das nächste Feld in der Sektionstabelle
																																						// für Objektdateien definitionsgemäß auf Null gesetzt wird. Dadurch wird
																																						// secNam auch mit \0 abgeschlossen, wenn der Name 8 Zeichen lang ist.
		if (actSecTab-> virSiz && actSecTab-> secNam[7] != 0x00)
		{
			secNam= (char *)malloc(2 * sizeof(DWORD) + 1);
			memset(secNam, 0x00, 2 * sizeof(DWORD) + 1);
			memcpy(secNam, (char *)actSecTab-> secNam, 2 * sizeof(DWORD));
			freSecNam= TRUE;
		}
 }
	
	if (actSecTab-> rawDatSiz)
	{
		actObjRawDat-> Seek(actSecTab-> rawDatPtr, CFile::begin);
		secRawDat= new CMyMemFile();
		((CMyMemFile *)secRawDat)-> SetBufferDirect(((CMyMemFile *)actObjRawDat)-> ReadWithoutMemcpy(actSecTab-> rawDatSiz), actSecTab-> rawDatSiz);
		if (actSecTab-> relNum)
		{
			actObjRawDat-> Seek(actSecTab-> relPtr, CFile::begin);
   secRelBuf= (BYTE *)((CMyMemFile *)actObjRawDat)-> ReadWithoutMemcpy(actSecTab-> relNum * 10);
		}

		if (actSecTab-> linNumNum)
		{
			secObjFil-> linNmbInc= TRUE;
			actObjRawDat-> Seek(actSecTab-> linNumPtr, CFile::begin);
			secLinNumBuf= (BYTE *)((CMyMemFile *)actObjRawDat)-> ReadWithoutMemcpy(actSecTab-> linNumNum * 6);
		}
	}

	SetSecAlign();

 // Überprüfen, ob Objektmodul auch wirklich einen Exporteintrag einer DLL enthält !
 // Bei gemischten Libraries wird dies so initialisiert und muß gegebenfalls korrigiert werden !

 if (secObjFil-> incDllFun)
 {
  if ((actSecTab-> chr | 0xFFFFFF00) == 0xFFFFFF20)  // Code Sektion
  {
   if (actSecTab-> rawDatSiz && (actSecTab-> rawDatSiz != 0x06))
   {
    DWORD hlpWrd;
    secRawDat-> SeekToBegin();
    secRawDat-> Read(&hlpWrd, sizeof(DWORD));
    if (hlpWrd != 0x000025FF)
     secObjFil-> incDllFun= FALSE; 
   }
   else
    secObjFil-> incDllFun= FALSE; 
  } 
 }

	if (!strcmp(secNam, ".bss")) actInd++;

	return TRUE;
}

/**************************************************************************************************/
/*** Aufgrund der Charakteristikflag der Sektion und dem Sektionsnamen (wenn nötig) wird die    ***/
/*** Sektion der COFF-Datei der entsprechenden Sektion in der PE-Datei zugeordnet und dort als  ***/
/*** Sektionsfragment gespeichert.																																																														***/
/**************************************************************************************************/

BOOL CObjFileSection::WrapFromObj2Exe(CObjFile *secObjFil, CExeFile *aExeFil)
{
	CSectionFragmentEntry		*newSecFrg;
	CExeFileDataSection				*actSec= NULL;
	BOOL		dbgIncNeeded= TRUE;												

 switch (actSecTab-> chr | 0xFFFFFF00)
 {
  case 0xFFFFFF20: actSec= aExeFil-> textSec;                   
   break;
  case 0xFFFFFF40:	// genauso wie 0xFFFFFF48

		case 0xFFFFFF48: if (!strncmp(secNam, ".debug$", strlen(".debug$")))
																		{
																			if (!strcmp(secNam, ".debug$T"))
																				secObjFil-> dbgTSec= this;
																			actSec= aExeFil-> debugSec; // debug $F, $S, $T
																			dbgIncNeeded= FALSE;
																		}
																		else
																		{	
																			if (!strcmp(secNam, ".rdata")) 
																				actSec= aExeFil-> rdataSec;
																			else 
																				actSec=	aExeFil-> dataSec;				
																		}
   break;
  case 0xFFFFFF80: actSec= aExeFil-> bssSec;
																			dbgIncNeeded= FALSE;
   break;
  default: if (strcmp(secNam, ".drectve"))
											{
												WriteMessageToPow(ERR_MSGIS_NEW_SEC_TYP, secNam,	secObjFil-> objFilNam);
												return FALSE;
											}
											else
												WriteMessageToPow(WRN_MSGIS_DRC	, secObjFil-> objFilNam,	NULL);

											dbgIncNeeded= FALSE;											
 }
 
 if (actSec)
	{
		newSecFrg= new CSectionFragmentEntry(actSec, 0, this, secObjFil, aln);
		actSec-> AddSecFrag(newSecFrg);	
  SetFragEntry(newSecFrg);	
		if (aExeFil-> includeDebugInfo && dbgIncNeeded)
			aExeFil-> debugSec-> IncSecFrgEntryForCV(newSecFrg);	// Für CV 0x120 (sstModule) Debugmodulinformation
	}
	return TRUE;
}
	
/**************************************************************************************************/
/*** Setzen der Instanzvariable actFrgEnt der Klasse CObjFileSection																												***/
/**************************************************************************************************/

void CObjFileSection::SetFragEntry(CSectionFragmentEntry *frgEnt)
{
	actFrgEnt= frgEnt;		
}

/**************************************************************************************************/
/*** Anlegen eines Objekts der Klasse CDllExportEntry aus den Daten der Objektdateisektion						***/
/*** .IDATA$2. Kommt in Importlibraries vor.																																																						***/
/**************************************************************************************************/

CDllExportEntry* CObjFileSection::GiveDllExpEntIdata$2(CObjFile *dObjFil, char *dllNam)
{
	CDllExportEntry *actDllExpEnt;
	
	if (secRawDat)
	{
		actDllExpEnt= new CDllExportEntry(dObjFil, NULL, 0, NULL, dllNam, FALSE);
		return actDllExpEnt;
	}
	else
		return NULL;
}

/**************************************************************************************************/
/*** Anlegen eines Objekts der Klasse CDllExportEntry aus den Daten der Objektdateisektion      ***/
/*** .IDATA$4. Kommt ebenfalls in Importlibraries vor.																																										***/
/**************************************************************************************************/

CDllExportEntry* CObjFileSection::GiveDllExpEntIdata$4(CObjFile *dObjFil, char *dllNam, CObjFileSection *txtSec)
{
	CDllExportEntry *actDllExpEnt;

 myRelocationEntry *txtSecRelEnt;
 mySymbolEntry     *expFncSymEnt;
	
 WORD	ord;	
	char *dllExpFunNam;
	BOOL eByOrd= TRUE;

 if (secRawDat)
 { 
  secRawDat-> SeekToBegin();
	 secRawDat-> Read(&ord, sizeof(WORD));

  txtSecRelEnt= (myRelocationEntry *) txtSec-> secRelBuf;
  expFncSymEnt= (mySymbolEntry *) dObjFil-> newSymLst[txtSecRelEnt-> symTabInd];
  dllExpFunNam= expFncSymEnt-> symNam;
  
  actDllExpEnt= new CDllExportEntry(dObjFil, txtSec, ord, dllExpFunNam, dllNam, eByOrd);
		return actDllExpEnt;
	}
	else
		return NULL;
}
	
/**************************************************************************************************/
/*** Anlegen eines Objekts der Klasse CDllExportEntry aus den Daten der Objektdateisektion      ***/
/*** .IDATA$6. Kommt ebenfalls in Importlibraries vor.																																										***/
/**************************************************************************************************/

CDllExportEntry* CObjFileSection::GiveDllExpEntIdata$6(CObjFile *dObjFil, char *dllNam, CObjFileSection *txtSec)
{
	CDllExportEntry *actDllExpEnt;
	
	WORD	ord;	
	WORD fncNamLen;
	char *dllExpFunNam;
 BOOL eByOrd= FALSE;
						
	if (secRawDat)
	{
		fncNamLen= (WORD) (secRawDat-> GetLength() - sizeof(WORD));
		secRawDat-> SeekToBegin();
		secRawDat-> Read(&ord, sizeof(WORD));
		dllExpFunNam= (char *) ((CMyMemFile *)secRawDat)-> ReadWithoutMemcpy(fncNamLen);
		actDllExpEnt= new CDllExportEntry(dObjFil, txtSec, ord, dllExpFunNam, dllNam, eByOrd);
		return actDllExpEnt;
	}
	else
		return NULL;
}
	
/**************************************************************************************************/
/*** Auslesen der Exporttabelle einer Importlibrary. Seit VC++ 2.5 wird diese Methode nicht     ***/
/*** mehr verwendet, da sich das Format der Importlibrary geändert hat.																									***/
/**************************************************************************************************/

CMyMapStringToOb *CObjFileSection::GiveDllFunDir()
{
	myExportDirectoryTable	expDirTab;

	CDllExportEntry		*newDllExpEnt;
	CMyMapStringToOb	*dllFunDir;
	CDWordArray						*expNamPtrLst;
	CWordArray							*expOrdLst;
	char										*dllNam;
	char										*newStr;
	
	DWORD	expNamPtrBuf;
	DWORD	sekPos;  
	WORD		expOrdBuf;
	char		*namBuf;
	int			i;

	dllFunDir= new CMyMapStringToOb();       	

	secRawDat-> SeekToBegin();
	secRawDat-> Read(&expDirTab, 40); 
	secRawDat-> Seek(expDirTab.expNamPtrTab, CFile::begin);

	expNamPtrLst= new CDWordArray();
	expNamPtrLst-> SetSize(expDirTab.adrTabEntNum, 100);

	for(i= 0; i < (int)expDirTab.adrTabEntNum; i++)
	{
		secRawDat-> Read(&expNamPtrBuf, sizeof(DWORD));
		expNamPtrLst-> SetAt(i, expNamPtrBuf);
	}			

	expOrdLst= new CWordArray();											
	expOrdLst-> SetSize(expDirTab.namPtrNum, 100);

	for(i= 0; i < (int)expDirTab.namPtrNum; i++)
	{
		secRawDat-> Read(&expOrdBuf, sizeof(WORD));
		expOrdLst-> SetAt(i, expOrdBuf);
	}			

	namBuf= new char[50];

	sekPos= secRawDat-> GetPosition();
	secRawDat-> Read(namBuf, 50);
	dllNam= new char[strlen(namBuf)];
	dllNam= strcpy(dllNam, namBuf);
	delete[] namBuf;

	sekPos+= strlen(dllNam) + 1;
	secRawDat-> Seek(sekPos, CFile::begin);
  	
	for(i= 0; i < (int)expDirTab.namPtrNum; i++)
	{
		sekPos= secRawDat-> GetPosition();
		secRawDat-> Read(namBuf, 50);
		newStr= namBuf;
		newDllExpEnt= new CDllExportEntry(expOrdLst-> GetAt(i), newStr, dllNam);
		dllFunDir-> SetAt(namBuf, newDllExpEnt);
		secRawDat-> Seek(sekPos + strlen(newStr) + 1, CFile::begin);
	}			

	return dllFunDir;
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileDataSection::CExeFileDataSection() : CSection()
{
	unSorObjSecFrgLst= NULL;
 unSorOthObjSecFrgLst= NULL;
 objNamLst= NULL;
	othObjNamLst= NULL;
	secFrgLst= NULL;
	
	secAln= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileDataSection::CExeFileDataSection(char *secName, WORD sNum) : CSection(secName, sNum)
{
 unSorObjSecFrgLst= new CMyMapStringToOb(100);
	unSorObjSecFrgLst-> InitHashTable(50, TRUE);
	unSorOthObjSecFrgLst= new CMyMapStringToOb(50);
	unSorOthObjSecFrgLst-> InitHashTable(50, TRUE);
	objNamLst= new CMyStringList();
	othObjNamLst= new CMyStringList();
	secFrgLst= new CMyObList(50);
	
	secAln= 0x8;

 actSecTab= (mySectionTable *) malloc(sizeof(mySectionTable));
 memset(actSecTab, 0, sizeof(mySectionTable));
 memcpy(actSecTab-> secNam, secNam, strlen(secNam));

	if (strcmp(secNam, ".data"))
		actSecTab-> chr= 0x40000040;
	else
		actSecTab-> chr= 0xC0000040;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileDataSection::~CExeFileDataSection()
{
	FreeUsedMemory();	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileDataSection::FreeUsedMemory()
{
	CMyMapStringToOb *secFrgEntLst;
	CMyObList								*secFrgObjLst;
	char      							*keyNam;
	POSITION							entPos;
	POSITION							frgEntPos;


	CSection::FreeUsedMemory();
	if (unSorObjSecFrgLst)
	{
		entPos= unSorObjSecFrgLst-> GetStartPosition();
		while(entPos)
		{
		 unSorObjSecFrgLst-> GetNextAssoc(entPos, keyNam, (CObject *&)secFrgEntLst);
			frgEntPos= secFrgEntLst-> GetStartPosition();
			while(frgEntPos)
			{
				secFrgEntLst-> GetNextAssoc(frgEntPos, keyNam, (CObject *&)secFrgObjLst);
				FreeCMyObList(secFrgObjLst);
				delete secFrgObjLst;
			}
			FreeCMyMapStringToOb(secFrgEntLst);
			delete secFrgEntLst;
		}
		FreeCMyMapStringToOb(unSorObjSecFrgLst);
		delete unSorObjSecFrgLst;
		unSorObjSecFrgLst= NULL;
	}
	if (unSorOthObjSecFrgLst)
	{
		entPos= unSorOthObjSecFrgLst-> GetStartPosition();
		while(entPos)
		{
		 unSorOthObjSecFrgLst-> GetNextAssoc(entPos, keyNam, (CObject *&)secFrgEntLst);
			frgEntPos= secFrgEntLst-> GetStartPosition();
			while(frgEntPos)
			{
				secFrgEntLst-> GetNextAssoc(frgEntPos, keyNam, (CObject *&)secFrgObjLst);
				FreeCMyObList(secFrgObjLst);
				delete secFrgObjLst;
			}
			FreeCMyMapStringToOb(secFrgEntLst);
			delete secFrgEntLst;
		}
		FreeCMyMapStringToOb(unSorOthObjSecFrgLst);
		delete unSorOthObjSecFrgLst;
		unSorOthObjSecFrgLst= NULL;
	}
	if (objNamLst)
	{
	 objNamLst-> ~CMyStringList();
		delete objNamLst;
		objNamLst= NULL;
	}
	if (othObjNamLst)
	{
		othObjNamLst-> ~CMyStringList();
		delete othObjNamLst;
		othObjNamLst= NULL;
	}
	if (secFrgLst)
	{
	 FreeCMyObList(secFrgLst);
		delete secFrgLst;
		secFrgLst= NULL;
	}
	secAln= 0;
}

/**************************************************************************************************/
/*** Hinzufügen eines Sektionsfragments einer Objektdatei (.DATA) in die Fragmentliste der      ***/
/*** .DATA Sektion der zu erstellenden PE-Datei.																																																***/
/**************************************************************************************************/

BOOL CExeFileDataSection::AddSecFrag(CSectionFragmentEntry *aSecFrg)
{
	CMyMapStringToOb	*aSecFrgNamLst;
	CMyMapStringToOb *aSecFrgLst;
	CMyStringList		   	*namLst;
	CMyObList								*aFrgLst;
	char								*objFilNam;
				
	// Wenn der Name des Sectionfragments gleich ist mit dem Sectionnamen im Exefile, dann
	// kommt er in die erste Liste, sonst in die zweite. Dies dient der Vereinfachung beim 
	// Auflösen der Reihenfolge der Fragmente.

	if (!strcmp(aSecFrg-> myHomSec-> secNam, secNam))
	{
		aSecFrgLst= unSorObjSecFrgLst;
		namLst= objNamLst;
	}
	else
	{
		aSecFrgLst= unSorOthObjSecFrgLst;
		namLst= othObjNamLst;
	}

	objFilNam= aSecFrg-> secFrgObjFil-> objFilNam;
	
	if (!aSecFrgLst-> Lookup(objFilNam, (CObject *&) aSecFrgNamLst))
	{
		aSecFrgNamLst= new CMyMapStringToOb(20);
  aSecFrgNamLst-> InitHashTable(10, TRUE);
		aFrgLst= new CMyObList(15);
		namLst-> AddTail(objFilNam);
		aSecFrgLst-> SetAt(objFilNam, aSecFrgNamLst);																					
		aSecFrgNamLst-> SetAt(aSecFrg-> myHomSec-> secNam, aFrgLst);				
	}
	else
	{
		if (!aSecFrgNamLst-> Lookup(aSecFrg-> myHomSec-> secNam, (CObject *&)aFrgLst))
			aFrgLst= new CMyObList(15);
		
		aSecFrgNamLst-> SetAt(aSecFrg-> myHomSec-> secNam, aFrgLst);
	}
	aFrgLst-> AddTail(aSecFrg);
	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der Rohdaten der .DATA Sektion aus den Sektionsfragmentslisten. Dabei wird die   ***/
/*** Beginnadresse des Sektionsfragments in der PE-Datei .DATA Sektion, und die Länge zuzüglich ***/
/*** etwaiger Alignmentanforderungen berechnet.																																																	***/
/**************************************************************************************************/

BOOL CExeFileDataSection::BuildSecRawDataBlockParts(CMyMapStringToOb *actUnSorLst, CMyStringList *namLst)
{
	CSectionFragmentEntry *aSecFrgEnt;
	CMyMapStringToOb 					*aSecFrgLst;
	CMyObList							 					*aFrgLst;
	CMyStringList 								*sorKeyLst;

	LPCTSTR objFilNam;
	LPCTSTR keyFrgNam;
	LPCTSTR sorFrgNam;
																							
	POSITION	objStrLst;
	POSITION	secFrgLstPos;
	POSITION	sorKeyPos;
	POSITION oldSorKeyPos;

	DWORD	frgEntNum;
	DWORD	i;
	DWORD objFilNamInd= 0;
	BOOL		ins;
		
	sorKeyLst= new CMyStringList();
	objStrLst= namLst-> GetHeadPosition();
	
	while(objStrLst)
	{
		objFilNam= namLst-> GetNext(objStrLst);
		actUnSorLst-> Lookup(objFilNam, (CObject *&) aSecFrgLst);
		secFrgLstPos= aSecFrgLst-> GetStartPosition();
		while(secFrgLstPos)
		{
			aSecFrgLst-> GetNextAssoc(secFrgLstPos, keyFrgNam, (CObject *&) aFrgLst);
			sorKeyPos= sorKeyLst-> GetHeadPosition();
			ins= FALSE;
			while(sorKeyPos)
			{
				oldSorKeyPos= sorKeyPos;
				sorFrgNam= sorKeyLst-> GetNext(sorKeyPos);
				if (strcmp(sorFrgNam, keyFrgNam) == 1)
				{
					sorKeyLst-> InsertBefore(oldSorKeyPos, keyFrgNam);
					ins= TRUE;
					sorKeyPos= NULL;
				}
			}
			if (!ins) sorKeyLst-> AddTail(keyFrgNam);
		}
		frgEntNum= sorKeyLst-> GetCount();

		for(i= 0; i < frgEntNum; i++)
		{
			sorFrgNam= sorKeyLst-> RemoveHead();
			aSecFrgLst-> Lookup(sorFrgNam, (CObject *&)aFrgLst);
			
			secFrgLstPos= aFrgLst-> GetHeadPosition();

			while(secFrgLstPos)
			{
				aSecFrgEnt= (CSectionFragmentEntry *)aFrgLst-> GetNext(secFrgLstPos);
				// Es wird hier nicht das Alignment der einzelnen Fragmente sondern der ganzen Sektion verwendet
				if (BytesTillAlignEnd(secRawDatSiz, secAln))
					secRawDatSiz+= BytesTillAlignEnd(secRawDatSiz, secAln);
				aSecFrgEnt-> SetFragOffset(secRawDatSiz);
				secFrgLst-> AddTail(aSecFrgEnt);
				secRawDatSiz+= aSecFrgEnt-> GetRawDataSize();
			}
		}
	}
	actSecTab-> virSiz= secRawDatSiz;
	sorKeyLst-> ~CMyStringList();
	delete sorKeyLst;

	return TRUE;
}	

/***************************************************************************************************/
/*** Aufruf der Methode zum virtellen Berechnen der .DATA Sektion für die Fragmente mit normalen ***/
/*** Sektionsnamen (.DATA) und für die Fragmente mit besonderen Sektionsnamen (.CRT, ...)								***/
/***************************************************************************************************/

BOOL CExeFileDataSection::BuildSecRawDataBlock()
{
	BuildSecRawDataBlockParts(unSorObjSecFrgLst, objNamLst);
	BuildSecRawDataBlockParts(unSorOthObjSecFrgLst, othObjNamLst);
	return TRUE;
}

/**************************************************************************************************/
/*** Setzen der virtuellen Sektionsadresse in der PE-Datei																																						***/
/**************************************************************************************************/

void CExeFileDataSection::SetVirSecAdr(DWORD vSecAdr)
{
	actSecTab-> rVAdrPtr= virSecAdr= vSecAdr;
}

/**************************************************************************************************/
/*** Physischen Schreiben der .DATA Sektionsdaten in die entsprechende .DATA Sektion der PE-    ***/
/*** Datei unter Berücksichtigung des Sektionsaligments.																																								***/
/**************************************************************************************************/

BOOL CExeFileDataSection::GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAln)
{
	CSectionFragmentEntry	*curFrgEnt;
	
	POSITION	frgPos;
	
	DWORD lstFrgEnd= 0;
	DWORD	bytTilSecEnd;
	BYTE	 filSecBuf= 0x0;
	BYTE  *rawDatBuf;
	
	actSecTab-> rawDatPtr= exeFilRawDat-> GetPosition();
	frgPos= secFrgLst-> GetHeadPosition();

	if (frgPos)
	{
		while (frgPos)
		{
			curFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(frgPos);
			// Ausfüllen der Alignment Leerstellen und reservieren des Platzes des Debugdirectories
			exeFilRawDat-> Write(chrBuf00, curFrgEnt-> secFrgOff - lstFrgEnd);
		
			curFrgEnt-> rawDat-> SeekToBegin();
			rawDatBuf= (BYTE *) curFrgEnt-> rawDat-> ReadWithoutMemcpy(curFrgEnt-> rawDatSiz);
			exeFilRawDat-> Write((char *)rawDatBuf, curFrgEnt-> rawDatSiz);
			lstFrgEnd+= curFrgEnt-> secFrgOff - lstFrgEnd + curFrgEnt-> rawDatSiz;
		}
	}
	else
		exeFilRawDat-> Write(chrBuf00, sizeof(myDebugDirectory) * DBG_DIR_ENT_MAX); // Debugdirectory, wenn keine sonstigen Daten

	bytTilSecEnd= BytesTillAlignEnd(exeFilRawDat-> GetPosition(), fAln);

	if (bytTilSecEnd)
		exeFilRawDat-> Write(chrBuf00, bytTilSecEnd);
	
	actSecTab-> rawDatSiz= exeFilRawDat-> GetPosition() - actSecTab-> rawDatPtr;

	return TRUE;
}

/**************************************************************************************************/
/*** Berechnen der Größe aktuellen .DATA Sektion der PE-Datei																																			***/
/**************************************************************************************************/

DWORD CExeFileDataSection::GiveSecRawDataSize(WORD fAln)
{
	if (BytesTillAlignEnd(secRawDatSiz, fAln))
		return secRawDatSiz + BytesTillAlignEnd(secRawDatSiz, fAln);
	
	return secRawDatSiz;	
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileDataSection::WriteSecFragToFile()
{
	CSectionFragmentEntry *curFrgEnt;
	POSITION	objPos;

	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\nListe Fragmente der %s Section:\n", secNam);
	fclose(logFil);

	objPos= secFrgLst-> GetHeadPosition();

	while(objPos)
	{
	 curFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(objPos);
		curFrgEnt-> WriteFragDataToFile();
	}	
}

/**************************************************************************************************/
/*** Durchlaufen aller Sektionsfragmente der .DATA Sektion und Aufrufen der Methode zur									***/
/*** Berechnung der noch offenen Adressen der einzelnen Sektionsfragmente																							***/
/**************************************************************************************************/

BOOL CExeFileDataSection::ResRel(CDWordArray *relLst, DWORD	imBas)
{
	CSectionFragmentEntry		*actSecFrgEnt;	
	POSITION		secFragPos;

	BOOL	lnkOK= TRUE;

	secFragPos= secFrgLst-> GetHeadPosition();
	
	while(secFragPos)
	{
		actSecFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(secFragPos);
		if (actSecFrgEnt-> secFrgRelBuf)
			if (!actSecFrgEnt-> ResRel(relLst, imBas, virSecAdr, secNum))
				lnkOK= FALSE;
	}

	return lnkOK;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileDataSection::WriteResolvedSectionSymbols()
{
	CSectionFragmentEntry		*actSecFrgEnt;	
	POSITION		secFragPos;

	secFragPos= secFrgLst-> GetHeadPosition();
	
	while(secFragPos)
	{
		actSecFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(secFragPos);
		if (actSecFrgEnt-> secFrgRelBuf)
		{
			logFil= fopen(logFilNam, "a");     
			fprintf(logFil, "\n\n%s", actSecFrgEnt-> secFrgObjFil-> objFilNam);
			fclose(logFil);
			actSecFrgEnt-> WriteResolvedSymbols();
		}
	}
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileTextSection::CExeFileTextSection() : CExeFileDataSection()
{
	secAln= 0;
	dllImpEntLst= NULL;
	nxtDllAdrEntAdr= 0;
	entPntAdr= 0;
	actSecTab-> chr= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileTextSection::CExeFileTextSection(char *aSecNam, WORD sNum) : CExeFileDataSection(aSecNam, sNum)
{
	secAln= 16;
	dllImpEntLst= new CMyObList(100);
	nxtDllAdrEntAdr= 0;
	entPntAdr= 0;
	actSecTab-> chr= 0x60000020;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*----------------*/
/*-- Destruktoren */
/*----------------*/

CExeFileTextSection::~CExeFileTextSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileTextSection::FreeUsedMemory()
{
	CExeFileDataSection::FreeUsedMemory();
	if (dllImpEntLst)
	{
	 FreeCMyObList(dllImpEntLst);
		delete dllImpEntLst;
		dllImpEntLst= NULL;
	}
	secAln= 0;
	nxtDllAdrEntAdr= 0;
	entPntAdr= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFileTextSection::IncDllImp(CDllExportEntry *dllExpEnt)
{
 	dllImpEntLst-> AddTail(dllExpEnt);
		return TRUE;
}

/**************************************************************************************************/
/*** Berechnung und Rückgabe der Größe der .TEXT Sektion einschließlich der DLL Forwarder Chain ***/
/**************************************************************************************************/

DWORD CExeFileTextSection::GiveSecRawDataSize(WORD fAln)
{
	nxtDllAdrEntAdr= CExeFileDataSection::GiveSecRawDataSize(secAln);
	secRawDatSiz= nxtDllAdrEntAdr + 6 * dllImpEntLst-> GetCount();
	actSecTab-> virSiz= secRawDatSiz;
	return CExeFileDataSection::GiveSecRawDataSize(fAln); 
}

/**************************************************************************************************/
/*** Gibt den Offset zum Einfügen des nächsten Dll Forwarder Chain Eintrags an. Relativ zum					***/
/*** Sektionsbegin.																																																																													***/					
/**************************************************************************************************/

DWORD CExeFileTextSection::GiveDllForChainStart()
{
	return nxtDllAdrEntAdr;
}

/**************************************************************************************************/
/*** Alle Einträge der DLL Forwarder Chain müssen in die .RELOC Sektion der PE-Datei aufgenommen **/
/*** werden. Des weiteren werden auch Debuginformatinen für die Einträge erstellt.															**/
/**************************************************************************************************/

BOOL CExeFileTextSection::IncDllForChainRel(CMyMapStringToOb *dllImpLstLst, CDWordArray *relLst, DWORD incDbgInf)
{
	CDllExportEntry   *actDllExpEnt;
	mySymbolEntry	    *actDllEntSym;
	mySymbolEntry     *impDllEntSym;
	mySymbolEntry					**symEntLst;
	myRelocationEntry	*actDllSymRel;
	CMyMapStringToOb	 *actDllExpLst;
	LPCTSTR									  dllNam;
	LPCTSTR									  dllSymNam;
	POSITION								  dllLstPos;
	POSITION								  dllLstEntPos;
	DWORD											  symNum;
	WORD														symInd;
	char														*hlpSymNamStr;
	BOOL														symFnd;
	
	dllLstPos= dllImpLstLst-> GetStartPosition();

	while(dllLstPos)
	{
		dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
		dllLstEntPos= actDllExpLst-> GetStartPosition();
		while(dllLstEntPos)
		{
			actDllExpLst-> GetNextAssoc(dllLstEntPos, dllSymNam, (CObject *&)actDllExpEnt);
			
			/* Einfügen der Debuginformation für das mit dem Dll Eintrag verbundene Symbol */

			if (incDbgInf)
			{
    if (actDllExpEnt-> txtDllSec)
			 {
					actDllSymRel= (myRelocationEntry *)actDllExpEnt-> txtDllSec-> secRelBuf;
			
				 symNum= actDllSymRel-> symTabInd;
				 impDllEntSym= (mySymbolEntry *)actDllExpEnt-> dllObjFil-> newSymLst[symNum];
				 if (!impDllEntSym-> secNum)
				 {
				 	impDllEntSym-> secOff= actDllExpEnt-> idataLokUpTabOffIdata;
				 	impDllEntSym-> secNum= actDllExpEnt-> idataExeSecNum;
					}
				}
			
				hlpSymNamStr= impDllEntSym-> symNam + strlen("__imp_");
				symFnd= FALSE;
				symEntLst= actDllExpEnt-> dllObjFil-> newSymLst;
				symNum= actDllExpEnt-> dllObjFil-> objCofHdr.symNum;
				symInd= 0;
						
				while((symInd < symNum) && !symFnd)
				{
					actDllEntSym= (mySymbolEntry *)symEntLst[symInd];
					if (actDllEntSym)
						if (!strcmp(hlpSymNamStr, actDllEntSym-> symNam))
							symFnd= TRUE;
					symInd++;
				}

				if (symFnd)
				{
					actDllEntSym-> secOff= nxtDllAdrEntAdr;
					actDllEntSym-> secNum=	secNum;
				}
				else 
				 WriteMessageToPow(WRN_MSGR_NO_DLL_DBG_INF, (char *)dllSymNam, (char *)dllNam);
			}
			
			relLst-> Add(nxtDllAdrEntAdr + actSecTab-> rVAdrPtr + sizeof(WORD));
			nxtDllAdrEntAdr+= 6;																											
		}
	}
	return TRUE;
}

/**************************************************************************************************/
/*** Pyhsisches Zusammensetzen der .TEXT Sektionsfragmente zu einem Speicherblock. Gleich-						***/
/*** zeitig wird auch die Adresse des Codeeinsprungspunktes berechnet.																										***/
/**************************************************************************************************/

BOOL CExeFileTextSection::GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, CMyMapStringToOb *dllImpLstLst, 
																																														WORD fAln)
{
	CSectionFragmentEntry *curFrgEnt;
	CDllExportEntry 						*actDllExpEnt;
	CMyMapStringToOb						*actDllExpLst;
	CObjFileSection							*entPntObjFilSection;

	LPCTSTR		dllNam;
	LPCTSTR		dllSymNam;
	POSITION	dllLstPos;
	POSITION	dllLstEntPos;
	POSITION	frgPos;

	DWORD lstFrgEnd= 0;
	DWORD	bytTilSecEnd;
	WORD  dllFunBuf= 0x25FF;
	BYTE		filSecBuf= 0x90;
	BYTE		*rawDatBuf;
	
	actSecTab-> rawDatPtr= exeFilRawDat-> GetPosition();
	frgPos= secFrgLst-> GetHeadPosition();

 while(frgPos)
	{
		curFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(frgPos);
		exeFilRawDat-> Write(chrBufCC, curFrgEnt-> secFrgOff - lstFrgEnd);
	
		curFrgEnt-> rawDat-> SeekToBegin();
		rawDatBuf= (BYTE *) curFrgEnt-> rawDat-> ReadWithoutMemcpy(curFrgEnt-> rawDatSiz);
		exeFilRawDat-> Write((char *)rawDatBuf, curFrgEnt-> rawDatSiz);
		lstFrgEnd= exeFilRawDat-> GetPosition() - actSecTab-> rawDatPtr;
	}

 // Initialisieren des Codeeinsprungpunktes		

	entPntObjFilSection= (CObjFileSection *) (startUpSym-> symObjFil-> secLst-> GetAt(startUpSym-> actSymTab-> secNum - 1));

	entPntAdr= entPntObjFilSection-> actFrgEnt-> secFrgOff + actSecTab-> rVAdrPtr + startUpSym->	actSymTab-> val;

	if (BytesTillAlignEnd(lstFrgEnd, secAln))
		exeFilRawDat-> Write(chrBufCC, BytesTillAlignEnd(lstFrgEnd, secAln));
	
	dllLstPos= dllImpLstLst-> GetStartPosition();
	while(dllLstPos)
	{
		dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
		dllLstEntPos= actDllExpLst-> GetStartPosition();

		while(dllLstEntPos)
		{
			actDllExpLst-> GetNextAssoc(dllLstEntPos, dllSymNam, (CObject *&)actDllExpEnt);
			exeFilRawDat-> Write(&dllFunBuf, sizeof(WORD));
			exeFilRawDat-> Write(&(actDllExpEnt-> idataLookupTabOff), sizeof(DWORD));
		}
		//FreeCMyMapStringToOb(actDllExpLst);
		//delete actDllExpLst;
	}
	
	bytTilSecEnd= exeFilRawDat-> GetPosition() - fAln * (exeFilRawDat-> GetPosition() / fAln);
	
	if (bytTilSecEnd)
		exeFilRawDat-> Write(chrBuf00, fAln - bytTilSecEnd);
	
	actSecTab-> rawDatSiz= exeFilRawDat-> GetPosition() - actSecTab-> rawDatPtr;

	return TRUE;
}
	
/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/
										
void CExeFileTextSection::WriteSecFragToFile()
{
	CSectionFragmentEntry	*curFrgEnt;
	CDllExportEntry							*curDllExpEnt;
	POSITION														objPos;

	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "Liste Fragmente der .text Section:\n");
	fclose(logFil);

	objPos= secFrgLst-> GetHeadPosition();

	while(objPos)
	{
 	curFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(objPos);
		curFrgEnt-> WriteFragDataToFile();
	}

	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\n\nListe Dll Importe der .text Section:\n");
	fclose(logFil);
                                                              
	objPos= dllImpEntLst-> GetHeadPosition();

	while(objPos)
	{
	 curDllExpEnt= (CDllExportEntry *)dllImpEntLst-> GetNext(objPos);
		curDllExpEnt-> WriteDataToFile();
	}
	
	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\n");
	fclose(logFil);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileBssSection::CExeFileBssSection() : CExeFileDataSection()
{
	secAln= 0;
	bssVarLst= NULL;
	varStartOff= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileBssSection::CExeFileBssSection(char *aSecNam, WORD sNum) : CExeFileDataSection(aSecNam, sNum)
{
	secAln= 8;
	bssVarLst= new CMyPtrList(50);
	varStartOff= 0;
	actSecTab-> chr= 0xC0000080;
}																										

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileBssSection::~CExeFileBssSection()
{
	FreeUsedMemory();	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileBssSection::FreeUsedMemory()
{
	CExeFileDataSection::FreeUsedMemory();
	if (bssVarLst)
	{
	 bssVarLst-> ~CMyPtrList();
		delete bssVarLst;
		bssVarLst= NULL;
	}
	secAln= 0;
	varStartOff= 0;
}

/**************************************************************************************************/
/*** Hinzufügen eines Sektionsfragmentes der .BSS Sektion																																							***/
/**************************************************************************************************/

BOOL CExeFileBssSection::AddSecFrag(CSectionFragmentEntry *aSecFrg)
{
	if (aSecFrg-> secFrgAln == 0)
			aSecFrg-> secFrgAln= 0x08;

	secRawDatSiz+= BytesTillAlignEnd(secRawDatSiz, aSecFrg-> secFrgAln);		

	//if (secRawDatSiz - (secRawDatSiz / aSecFrg-> secFrgAln) * aSecFrg-> secFrgAln)
	//	secRawDatSiz+= aSecFrg-> secFrgAln - (secRawDatSiz / aSecFrg-> secFrgAln) * aSecFrg-> secFrgAln;

	secFrgLst-> AddTail(aSecFrg);
	secRawDatSiz+= aSecFrg-> GetRawDataSize();

	return TRUE;
}

/**************************************************************************************************/
/*** In der .BSS Sektion gibt es keine Adressen die aufzulösen wären			 																								***/
/**************************************************************************************************/

BOOL CExeFileBssSection::ResRel(DWORD imBas)
{
	// Methode nicht in CExeFileBssSection verfügbar, wird daher überschrieben
	if (imBas)						// Sinnloser Code verhinder Linker Warning
		return imBas;

	return TRUE;
}

/**************************************************************************************************/
/*** Berechnung des Speicherbedarfs der uninitialisierten statischen und globalen Variablen und ***/
/*** Stringkonstanten.																																																																										***/
/**************************************************************************************************/

DWORD CExeFileBssSection::GiveSecRawDataSize(WORD fAln)
{
	mySymbolEntry *curSymEnt;
	POSITION			 		objPos;
	
	DWORD	symCnt= 0;
	DWORD	hlpRawDatSiz= 0;
	
	objPos= bssVarLst-> GetHeadPosition();
		
	while(objPos)
	{
		curSymEnt= (mySymbolEntry *)bssVarLst-> GetNext(objPos);
		hlpRawDatSiz+= curSymEnt-> val;
	}

	secRawDatSiz+= hlpRawDatSiz;
	secRawDatSiz= CExeFileDataSection::GiveSecRawDataSize(fAln);
	//actSecTab-> rawDatSiz= secRawDatSiz;

	return secRawDatSiz;
}					

/**************************************************************************************************/
/*** Setzen der Adressen der unitialisierten statischen und globalen Variablen und String-						***/
/*** konstanten der .BSS Sektionsfragmente.																																																					***/
/**************************************************************************************************/

BOOL CExeFileBssSection::SetBssVarOff(DWORD imBas, WORD fAln)
{
	mySymbolEntry *curSymEnt;
	POSITION	 				objPos;

	// Variables for Section Entries
	CSectionFragmentEntry *aSecFrgEnt;

	objPos= bssVarLst-> GetHeadPosition();

	while(objPos)
	{
		curSymEnt= (mySymbolEntry *)bssVarLst-> GetNext(objPos);
		curSymEnt-> bssOff= imBas + virSecAdr + varStartOff;
		varStartOff+= curSymEnt-> val;
	}

	secRawDatSiz= varStartOff;
	
	objPos= secFrgLst-> GetHeadPosition();

	while(objPos)
	{
		aSecFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(objPos);
		if (varStartOff - (varStartOff / aSecFrgEnt-> secFrgAln) * aSecFrgEnt-> secFrgAln)
			varStartOff+= aSecFrgEnt-> secFrgAln -	(varStartOff - (varStartOff / aSecFrgEnt-> secFrgAln) * aSecFrgEnt-> secFrgAln);
		aSecFrgEnt-> SetFragOffset(varStartOff);
		varStartOff+= aSecFrgEnt-> GetRawDataSize();
	}
	actSecTab-> virSiz= varStartOff;
 secRawDatSiz= varStartOff + BytesTillAlignEnd(varStartOff, fAln);

	return TRUE;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileBssSection::WriteSecFragToFile()
{
	CSectionFragmentEntry *curFrgEnt;
	mySymbolEntry									*curSymEnt;
	POSITION														objPos;

	logFil= fopen(logFilNam, "a");
	fprintf(logFil, "Liste Fragmente der .bss Section:\n");
	fclose(logFil);

	objPos= secFrgLst-> GetHeadPosition();

	while(objPos)
	{
		curFrgEnt= (CSectionFragmentEntry *)secFrgLst-> GetNext(objPos);
		curFrgEnt-> WriteFragDataToFile();
	}

	logFil= fopen(logFilNam, "a");
	fprintf(logFil, "\n\nListe Variablen der .bss Section:\n");
	fclose(logFil);

	objPos= bssVarLst-> GetHeadPosition();

	while(objPos)
	{
		curSymEnt= (mySymbolEntry *)bssVarLst-> GetNext(objPos);
		//curSymEnt-> WriteDataToFile();
	}

	logFil= fopen(logFilNam, "a");
	fprintf(logFil, "\n");
	fclose(logFil);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileImportSection::	CExeFileImportSection() : CSection()
{
	dllImpLstLst= NULL;
	virSecAdr= 0;
	speDllEntLst= NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileImportSection::CExeFileImportSection(char *secName, WORD sNum) : CSection(secName, sNum)
{
	dllImpLstLst= new CMyMapStringToOb(500);
 dllImpLstLst-> InitHashTable(50);
	virSecAdr= 0;
 actSecTab= (mySectionTable *) malloc(sizeof(mySectionTable));
 memset(actSecTab, 0, sizeof(mySectionTable));
 memcpy(actSecTab-> secNam, secNam, strlen(secNam));
	actSecTab-> chr= 0xC0000040;
	speDllEntLst= new CMyMapStringToOb(20);
	speDllEntLst-> InitHashTable(5);
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileImportSection::	~CExeFileImportSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileImportSection::	FreeUsedMemory()
{
 CMyMapStringToOb		*actDllExpLst;
 CDllExportEntry   *actDllExpEnt;
 POSITION          dllLstPos;
 POSITION          dllLstEntPos;
 char														*dllNam;
 char														*dllSymNam;

	CSection::FreeUsedMemory();
	
	if (dllImpLstLst)
	{
	 dllLstPos= dllImpLstLst-> GetStartPosition();
 	while(dllLstPos)
	 {
   dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
		 dllLstEntPos= actDllExpLst-> GetStartPosition();
		 while(dllLstEntPos)
		 {
			 actDllExpLst-> GetNextAssoc(dllLstEntPos, dllSymNam, (CObject *&)actDllExpEnt);
    FreeCDllExportEntry(actDllExpEnt);
    delete actDllExpEnt;
   }
   FreeCMyMapStringToOb(actDllExpLst);
 	 delete actDllExpLst;
  }
	 FreeCMyMapStringToOb(dllImpLstLst);
 	delete dllImpLstLst;
		dllImpLstLst= NULL;
	}
	
	if (speDllEntLst)
 {
	 dllLstEntPos= speDllEntLst-> GetStartPosition();
 	while(dllLstEntPos)
	 {
		 speDllEntLst-> GetNextAssoc(dllLstEntPos, dllSymNam, (CObject *&)actDllExpEnt);
			free(dllSymNam);
   FreeCDllExportEntry(actDllExpEnt);
   delete actDllExpEnt;
  }
	 FreeCMyMapStringToOb(speDllEntLst);
 	delete speDllEntLst;
		speDllEntLst= NULL;
	}

	virSecAdr= 0;	
}

/**************************************************************************************************/
/*** Setzen der virtuellen Adresse der .IDATA Sektion	in der PE-Datei																											***/
/**************************************************************************************************/

void CExeFileImportSection::SetVirSecAdr(DWORD vSecAdr)
{
	actSecTab-> rVAdrPtr= virSecAdr= vSecAdr;
}

/**************************************************************************************************/
/*** Erstellen der .IDATA Sektion und der DLL Forwarder Chain der .TEXT Sektion	und Erstellen   ***/
/*** dabei anfallender Debuginformationen																																																							***/
/**************************************************************************************************/

DWORD CExeFileImportSection::BuildDllImpSec(CMyMapStringToPtr *pubSymLst, WORD fAln, DWORD imBas, 
																																												DWORD actEntSecTxtOff, BOOL incDbgInf)
{
	myImportDirectoryTable	impDirTabEnt;

	CDllExportEntry	  *actDllExpEnt;
	CDllExportEntry			*newDllExpEnt;
	CMyMapStringToOb		*actDllExpLst;
	mySymbolEntry				 *dllImpTnkSym;
	mySymbolEntry					*speDllImpTnkSym;
	
	CMyMemFile	*impHdr;
	CMyMemFile	*lookupTab;
	CMyMemFile	*namTab;
	LPCTSTR		dllSymNam;
	LPCTSTR	 dllNam;
	POSITION	dllLstPos;
	POSITION	dllLstEntPos;

	DWORD	impLookupTabStart;
	DWORD impLookupTabStartFix;
	DWORD	namTabStartAdr;
	DWORD	nxtNamEntAdr;
	DWORD	dllNum;
	DWORD	dllLstEntNum= 0;
	DWORD	impLookupTabSiz;
	DWORD impLookupGesSiz;
	DWORD	bytToRead;
	DWORD namTabEntOff;
	DWORD namTabEntLen;
	WORD		namOrd;
	BYTE		*impHdrBuf;
 BYTE		*lookupTabBuf;
	BYTE		*namTabBuf;
	char 	*symNam;

	char 		*impDes= "__IMPORT_DESCRIPTOR_";									// Spezielle .idata Einträge
	char 		*nulImpDes= "__NULL_IMPORT_DESCRIPTOR";
	char 		*nulTnkDat= "_NULL_THUNK_DATA";
	
	dllLstPos= dllImpLstLst-> GetStartPosition();
	dllNum= 1; // Wird mit 1 initialisert, weil ein leerer Eintrag hinzukommt
	
	while(dllLstPos)
	{
		dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
		dllLstEntNum+= actDllExpLst-> GetCount() + 1;
		dllNum++;
	}
                              
	impLookupTabStart= impLookupTabStartFix= IMP_DIR_TAB_SIZ * dllNum;
	impLookupGesSiz= dllLstEntNum * sizeof(DWORD);
	namTabStartAdr= impLookupTabStart + 2 * impLookupGesSiz;

	/* Initialisieren der die Importsektion betreffenden Directory Einträge des */
	/* Exe-Headers.																																																													*/

	impDirAdr= impAdrTabAdr= actSecTab-> rVAdrPtr;
 impDirSiz= impLookupTabStart;
	impAdrTabAdr+= impLookupGesSiz + impLookupTabStart;
 impAdrTabSiz= impLookupGesSiz;
		
	impHdrBuf= (BYTE *) malloc(IMP_DIR_TAB_SIZ * dllNum);
			
	namTab= new CMyMemFile();
	impHdr= new CMyMemFile();
	lookupTab= new CMyMemFile();	
	
	impHdr-> SeekToBegin();
	lookupTab-> SeekToBegin();
	namTab-> SeekToBegin();
	
	nxtNamEntAdr= IMP_DIR_TAB_SIZ * dllNum + 2 * dllLstEntNum * sizeof(DWORD) + virSecAdr;

	dllLstPos= dllImpLstLst-> GetStartPosition();

	while(dllLstPos)
	{
		dllImpLstLst-> GetNextAssoc(dllLstPos, dllNam, (CObject *&)actDllExpLst);
		dllLstEntPos= actDllExpLst-> GetStartPosition();
		impLookupTabSiz= sizeof(DWORD);
		while(dllLstEntPos)
		{
			actDllExpLst-> GetNextAssoc(dllLstEntPos, dllSymNam, (CObject *&)actDllExpEnt);
			actDllExpEnt-> idataLokUpTabOffIdata= impLookupTabStartFix + impLookupGesSiz + 	lookupTab-> GetPosition();
			actDllExpEnt-> idataLookupTabOff= imBas + virSecAdr + actDllExpEnt-> idataLokUpTabOffIdata;
			actDllExpEnt-> textSegOff= actEntSecTxtOff;
			actDllExpEnt-> impLokUpTabOff= impLookupTabStartFix + lookupTab-> GetPosition();
			actDllExpEnt-> impAdrTabOff= actDllExpEnt-> impLokUpTabOff + impLookupGesSiz;
			actDllExpEnt-> namTabEntLen= actDllExpEnt-> namTabEntOff= nxtNamEntAdr - actSecTab-> rVAdrPtr;
			actDllExpEnt-> idataExeSecNum= secNum;
			actEntSecTxtOff+= 0x6;

			/* Import by Name or Ordinal */

			if (!actDllExpEnt-> expByOrd)
   {			
			 lookupTab-> Write(&nxtNamEntAdr, sizeof(DWORD));  // Import by Name
			 impLookupTabSiz+= sizeof(DWORD);
			 namOrd= actDllExpEnt-> expOrd;
			 namTab-> Write(&namOrd, sizeof(WORD));
			 symNam= actDllExpEnt-> expFunNam;
			 namTab-> Write(symNam, strlen(symNam));
			 nxtNamEntAdr+= sizeof(WORD) + strlen(symNam) + 1;
			 if (BytesTillAlignEnd(nxtNamEntAdr, 2))
			 {
		  	namTab-> Write(chrBuf00, 2);
			 	nxtNamEntAdr++;
			 }
			 else
			 	namTab-> Write(chrBuf00, 1);					
   }
   else
   {
    namOrd= actDllExpEnt-> expOrd;                    // Import by Ordinal
    lookupTab-> Write(&namOrd, sizeof(WORD));
    namOrd= 0x8000;
    lookupTab-> Write(&namOrd, sizeof(WORD));
			 impLookupTabSiz+= sizeof(DWORD);			 
   }
			
			actDllExpEnt-> namTabEntLen= nxtNamEntAdr - actSecTab-> rVAdrPtr - actDllExpEnt-> namTabEntLen;
			
		}																																																																																							

		// Erstellen der Debuginformation der _NULL_THUNK_DATA Einträge

		if (incDbgInf)
		{
			char *symSrhNamImpDes= (char *) malloc (strlen(dllNam) + strlen(nulTnkDat));
			memset(symSrhNamImpDes, '\0', strlen(dllNam) + strlen(nulTnkDat));
			symSrhNamImpDes[0]= '';
			symSrhNamImpDes= strncat(symSrhNamImpDes, dllNam, strlen(dllNam) - 4);
			symSrhNamImpDes= strcat(symSrhNamImpDes, nulTnkDat);
  
			if (pubSymLst-> Lookup(symSrhNamImpDes, (void *&)dllImpTnkSym))
			{
				newDllExpEnt= new CDllExportEntry();
				newDllExpEnt-> impAdrTabOff= newDllExpEnt-> impLokUpTabOff=	impLookupTabStartFix + lookupTab-> GetPosition(); 
				newDllExpEnt-> impAdrTabOff+= impLookupGesSiz;
				newDllExpEnt-> namTabEntLen= sizeof(DWORD);
				speDllEntLst-> SetAt(symSrhNamImpDes, newDllExpEnt);
			}
			else
				WriteMessageToPow(WRN_MSGC_NO_IMP_DES, symSrhNamImpDes, NULL);
		}
	
		lookupTab-> Write(chrBuf00, sizeof(DWORD));	
		impDirTabEnt.impLookupTab= virSecAdr + impLookupTabStart;
		impDirTabEnt.timDatStp= 0; // Set to zero until bound
		impDirTabEnt.forChn= 0;		
		impDirTabEnt.impAdrTabRAdr= impDirTabEnt.impLookupTab + impLookupGesSiz;
  impDirTabEnt.dllNamRAdr= nxtNamEntAdr;
  symNam= actDllExpEnt-> dllNam;

		namTabEntOff= nxtNamEntAdr;
		namTab-> Write(symNam, strlen(symNam));
		nxtNamEntAdr+= strlen(symNam) + 1;		
		
		if (BytesTillAlignEnd(nxtNamEntAdr, 2))
  {
   nxtNamEntAdr++;
		 namTab-> Write(chrBuf00, 2);
  }
		else
			namTab-> Write(chrBuf00, 1);			

		namTabEntLen= nxtNamEntAdr - namTabEntOff;
		namTabEntOff-= actSecTab-> rVAdrPtr;

		// Erstellen der Debuginformation der IMPORT_DESCRIPTOR Einträge

		if (incDbgInf)
		{
			char *symSrhNam= (char *) malloc (strlen(dllNam) + strlen(impDes));
			memset(symSrhNam, '\0', strlen(dllNam) + strlen(impDes));
			symSrhNam= strcat(symSrhNam, impDes);
			symSrhNam= strncat(symSrhNam, dllNam, strlen(dllNam) - 4);

			if (pubSymLst-> Lookup(symSrhNam, (void *&)dllImpTnkSym))
			{
				if (!speDllEntLst-> Lookup(symSrhNam, (CObject *&)speDllImpTnkSym))
				{
					newDllExpEnt= new CDllExportEntry();
					// impLokUpTabOff gibt hier den Offset des Importeintrags an
					// namTabEntLen die Länge des Importeintrags
					newDllExpEnt-> impLokUpTabOff= impHdr-> GetPosition(); 
					newDllExpEnt-> impAdrTabOff= IMP_DIR_TAB_SIZ;
					// namTabEntOff gibt den Offset zum DLL Importnamen an
					// namTabEntLen die Länge des DLL Importnameneintrags
					newDllExpEnt-> namTabEntOff= namTabEntOff;
					newDllExpEnt-> namTabEntLen= namTabEntLen;
					speDllEntLst-> SetAt(symSrhNam, newDllExpEnt);			
				}
			}
			else
				WriteMessageToPow(WRN_MSGC_NO_IMP_DES, symSrhNam, NULL);
		}
		
		impHdr-> Write(&impDirTabEnt, IMP_DIR_TAB_SIZ);
	
		impLookupTabStart= impDirTabEnt.impLookupTab + impLookupTabSiz - virSecAdr;
 }
	
	// Schreiben des leeren Directory Eintrags (NULL_THUNK)

	impDirTabEnt.impLookupTab= 0;
	impDirTabEnt.timDatStp= 0;
	impDirTabEnt.forChn= 0;
	impDirTabEnt.dllNamRAdr= 0;
	impDirTabEnt.impAdrTabRAdr= 0;
	
	impHdr-> Write(&impDirTabEnt, IMP_DIR_TAB_SIZ);

	if (incDbgInf)
	{
	 if (pubSymLst-> Lookup(nulImpDes, (void *&)dllImpTnkSym)) // NULL THUNK DATA darf nur einmal geschrieben werden
		{
			if (!speDllEntLst-> Lookup(nulImpDes, (CObject *&)speDllImpTnkSym))
			{
				char *symSrhNam= (char *) malloc (strlen(nulImpDes) + 1);
				memset(symSrhNam, '\0', strlen(nulImpDes) + 1);
				symSrhNam= strcpy(symSrhNam, nulImpDes);
			
				newDllExpEnt= new CDllExportEntry();
				// impLokUpTabOff gibt hier den Offset des leeren Importeintrags an
				// impAdrTabOff die Länge des leeren Importeintrags
				newDllExpEnt-> impLokUpTabOff= impLookupTabStartFix - IMP_DIR_TAB_SIZ; 
				newDllExpEnt-> impAdrTabOff= IMP_DIR_TAB_SIZ;
				speDllEntLst-> SetAt(symSrhNam, newDllExpEnt);			
			}
		}
		else
			WriteMessageToPow(WRN_MSGC_NO_IMP_DES, nulImpDes, NULL);
	}	

	// Erstellen der Import Section als eine Einheit

 secRawDatSiz= impHdr-> GetPosition() + 2 * lookupTab-> GetPosition() +	namTab-> GetPosition() - 3;

	if (secRawDatSiz - fAln * (secRawDatSiz / fAln))
		secRawDatSiz+= fAln - (secRawDatSiz - fAln * (secRawDatSiz / fAln));
	
	secRawDat= new CMyMemFile();

	bytToRead= impHdr-> GetPosition();
	impHdr-> SeekToBegin();
	impHdr-> Read(impHdrBuf, bytToRead);
	secRawDat-> Write(impHdrBuf, bytToRead);
 free(impHdrBuf);
	FreeCMyMemFile(impHdr);
 delete impHdr;

	bytToRead= lookupTab-> GetPosition();
	lookupTabBuf= (BYTE *) malloc(bytToRead);
	lookupTab-> SeekToBegin();
	lookupTab-> Read(lookupTabBuf, bytToRead);
	secRawDat-> Write(lookupTabBuf, bytToRead);
	secRawDat-> Write(lookupTabBuf, bytToRead);
 free(lookupTabBuf);
	FreeCMyMemFile(lookupTab);
 delete lookupTab;

 TestHeap();
 	
	bytToRead= namTab-> GetPosition();
 namTab-> SeekToBegin();
 namTabBuf= (BYTE *) malloc(bytToRead);
 namTab-> Read(namTabBuf, bytToRead);											
 secRawDat-> Write(namTabBuf, bytToRead);	
 free(namTabBuf);
	FreeCMyMemFile(namTab);
 delete namTab;    

 actSecTab-> virSiz= secRawDat-> GetPosition();
	secRawDat-> Write(chrBuf00, secRawDatSiz - actSecTab-> virSiz);	
 
 return secRawDatSiz;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileImportSection::WriteImpSecToFile()
{	
	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\nAusgabe der Daten der %s Section in Hex Darstellung:\n", ".idata");
	fclose(logFil);

	WriteRawDataToFile(secRawDat);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*--------------------*/
/*--- Konstruktoren --*/
/*--------------------*/

CExeFileExportSection::	CExeFileExportSection() : CSection()
{
	expFncLst= NULL;
 expFilEdataRawDat= NULL;
	virSecAdr= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileExportSection::CExeFileExportSection(char *secName, WORD sNum) : CSection(secName, sNum)
{
	expFncLst= new CMyPtrList();
 expFilEdataRawDat= NULL;
	expSymLst= NULL;
 virSecAdr= 0;
 actSecTab= (mySectionTable *) malloc(sizeof(mySectionTable));
 memset(actSecTab, 0, sizeof(mySectionTable));
 memcpy(actSecTab-> secNam, secNam, strlen(secNam));
	actSecTab-> chr= 0x40000040;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileExportSection::	~CExeFileExportSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileExportSection::	FreeUsedMemory()
{
	CSection::FreeUsedMemory();
	if (expFncLst)
	{
	 expFncLst-> ~CMyPtrList();
		delete expFncLst;
		expFncLst= NULL;
	}
 if (expFilEdataRawDat)
 {
  expFilEdataRawDat-> ~CMyMemFile();
  delete expFilEdataRawDat;
  expFilEdataRawDat= NULL;
 }
	if (secRawDat)
	{
		FreeCMyMemFile(secRawDat);
		delete secRawDat;
		secRawDat= NULL;
	}
	if (expSymLst)
	{
		free(expSymLst);
		expSymLst= NULL;
	}
	virSecAdr= 0;	
}

/**************************************************************************************************/
/*** Setzen der virtuellen .EDATA Sektionsadresse der PE-Datei																																		***/
/**************************************************************************************************/

void CExeFileExportSection::SetVirSecAdr(DWORD vSecAdr)
{
	actSecTab-> rVAdrPtr= virSecAdr= vSecAdr;
}

/**************************************************************************************************/
/*** Hinzufügen eines zu exportierenden Symbols in die entsprechende Liste																						***/
/**************************************************************************************************/

BOOL CExeFileExportSection::AddExpFncEntry(mySymbolEntry *addSymEnt)
{
 mySymbolEntry *actSymEnt;
 POSITION      symEntPos;
 POSITION      oldSymEntPos;
 
 BOOL symInc= FALSE;

 symEntPos= expFncLst-> GetHeadPosition();
 while(symEntPos && !symInc)
 {
  oldSymEntPos= symEntPos;
  actSymEnt= (mySymbolEntry *)expFncLst-> GetNext(symEntPos);
  if (strcmp(addSymEnt-> symNam, actSymEnt-> symNam) < 0)
  {
   expFncLst-> InsertBefore(oldSymEntPos, addSymEnt);
   symInc= TRUE;
  }
 }

 if (!symInc)
  expFncLst-> AddTail(addSymEnt);

	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der .EDATA Sektion der PE-Datei																																																		***/
/**************************************************************************************************/

DWORD CExeFileExportSection::BuildExpFncSec(char *dllOrExeFilNam, WORD fAln)
{
 CObjFileSection *actObjFilSec;
 
 mySymbolEntry  *actSymEnt;
 myExportRecord *actExpRec;
 CMyMemFile     *expNamTab;
 POSITION       symEntPos;

 DWORD *expAdrTab;
 DWORD *expNamPtrTab;
	DWORD expNamPtrTabEnt;
 WORD  *expOrdTab;
 WORD  expOrdTabEnt;
	char  **expSrtNamTab;
	char  *expSrtNamTabEnt;

 DWORD actExpNamTabOff;
 DWORD expNum;
 DWORD	actExpOrd;
 WORD  expSymLstInd;
 char  *symNam;

	DWORD i, l;

 memset(&actExpDirTab, 0, EXP_DIR_TAB_SIZ);
 actExpDirTab.ordBas= 1;

 secRawDat= new CMyMemFile();
 expFilEdataRawDat= new CMyMemFile();
 
 expNum= expFncLst-> GetCount();
 actExpNamTabOff= actSecTab-> rVAdrPtr + EXP_DIR_TAB_SIZ + 2 * expNum * sizeof(DWORD) + expNum * sizeof(WORD);

 expNamTab= new CMyMemFile();
 expAdrTab= (DWORD *) malloc (expNum * sizeof(DWORD));
 expNamPtrTab= (DWORD *) malloc (expNum * sizeof(DWORD));
 expOrdTab= (WORD *) malloc (expNum * sizeof(WORD));
	expSrtNamTab= (char **) malloc (expNum * sizeof(char *));

 expNamTab-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) + 1);
 actExpDirTab.dllNamAdr= actExpNamTabOff;
 actExpNamTabOff+= strlen(dllOrExeFilNam) + 1;
    
 expSymLst= (myExportRecord **) malloc (expNum * sizeof(myExportRecord));
 actExpRec= (myExportRecord *)expSymLst;

 symEntPos= expFncLst-> GetHeadPosition();
 actExpOrd= 0;
 expSymLstInd= 0;

 while(symEntPos)
 {
  actSymEnt= (mySymbolEntry *)expFncLst-> GetNext(symEntPos);
  actObjFilSec= (CObjFileSection *)actSymEnt-> symObjFil-> secLst-> GetAt(actSymEnt-> actSymTab-> secNum - 1);
  expAdrTab[actExpOrd]= actObjFilSec-> actFrgEnt-> actExeSec-> virSecAdr +
                        actObjFilSec-> actFrgEnt-> secFrgOff + actSymEnt-> actSymTab-> val;
  expOrdTab[actExpOrd]= actExpOrd;
  expNamPtrTab[actExpOrd]= actExpNamTabOff;
  symNam= actSymEnt-> expTabSymNam;
  expNamTab-> Write(symNam, strlen(symNam) + 1);
  actExpNamTabOff+= strlen(symNam) + 1;
  
		expSrtNamTab[actExpOrd]= symNam;

  actExpRec-> expSymOrd= actExpOrd + actExpDirTab.ordBas;
  actExpRec-> expSymNam= actSymEnt-> symNam;

  actExpRec++;  
  actExpOrd++;  
 }

	/* Alphabetisches sortieren des Exportverzeichnisses */
	
	for(i= 0; i < expNum - 1; i++)
	{
		for(l= i + 1; l < expNum; l++)
		{
			if (strcmp(expSrtNamTab[i], expSrtNamTab[l]) > 0)
			{
				expNamPtrTabEnt= expNamPtrTab[i];
				expOrdTabEnt= expOrdTab[i];
				expSrtNamTabEnt= expSrtNamTab[i];
				expNamPtrTab[i]= expNamPtrTab[l];
				expOrdTab[i]= expOrdTab[l];
				expSrtNamTab[i]= expSrtNamTab[l];
				expNamPtrTab[l]= expNamPtrTabEnt;
				expOrdTab[l]= expOrdTabEnt;
				expSrtNamTab[l]= expSrtNamTabEnt;
			}
		}
	}
	
 actExpDirTab.timDatStp= CalcTimeDateStamp();
 actExpDirTab.adrTabEntNum= actExpDirTab.namPtrNum= expNum;
 actExpDirTab.expAdrTabPtr= actSecTab-> rVAdrPtr + EXP_DIR_TAB_SIZ;
 actExpDirTab.expNamPtrTab= actExpDirTab.expAdrTabPtr + expNum * sizeof(DWORD);
 actExpDirTab.ordTabPtr= actExpDirTab.dllNamAdr - expNum * sizeof(WORD);

 secRawDat-> Write(&actExpDirTab, EXP_DIR_TAB_SIZ); 
 actExpDirTab.dllNamAdr-= actSecTab-> rVAdrPtr;
 actExpDirTab.expAdrTabPtr-= actSecTab-> rVAdrPtr;
 actExpDirTab.expNamPtrTab-= actSecTab-> rVAdrPtr;
 actExpDirTab.ordTabPtr-= actSecTab-> rVAdrPtr;
 expFilEdataRawDat-> Write(&actExpDirTab, EXP_DIR_TAB_SIZ); 
 
 secRawDat-> Write(expAdrTab, expNum * sizeof(DWORD));
 memset(expAdrTab, 0, expNum * sizeof(DWORD));
 expFilEdataRawDat-> Write(expAdrTab, expNum * sizeof(DWORD));

 secRawDat-> Write(expNamPtrTab, expNum * sizeof(DWORD));
 for(i= 0; i < expNum; i++)
  expNamPtrTab[i]-= actSecTab-> rVAdrPtr;
 expFilEdataRawDat-> Write(expNamPtrTab, expNum * sizeof(DWORD));                                       

 secRawDat-> Write(expOrdTab, expNum * sizeof(WORD));
 expFilEdataRawDat-> Write(expOrdTab, expNum * sizeof(WORD));
 
 expNamTab-> SeekToBegin();
 BYTE *expNamTabBuf= (BYTE *)expNamTab-> ReadWithoutMemcpy(expNamTab-> GetLength());
 secRawDat-> Write(expNamTabBuf, expNamTab-> GetLength());
 expFilEdataRawDat-> Write(expNamTabBuf, expNamTab-> GetLength());
 
	actSecTab-> virSiz= secRawDat-> GetPosition();
 secRawDat-> Write(chrBuf00, BytesTillAlignEnd(actSecTab-> virSiz, fAln));
 WriteExpSecToFile();

	if (expNamTab)
	{
		FreeCMyMemFile(expNamTab);
		delete expNamTab;
	}

 free(expAdrTab);
 free(expNamPtrTab);
 free(expOrdTab);
	free(expSrtNamTab);
	//free(expSymLst);

 return secRawDatSiz= actSecTab-> virSiz + BytesTillAlignEnd(actSecTab-> virSiz, fAln); 
}


/**************************************************************************************************/
/*** Erstellen der Exportdatei der Dynamic Link Libray																																										***/
/**************************************************************************************************/

BOOL CExeFileExportSection::BuildDllExportFile(char *dllOrExeFilNam, char *expFilNam)
{
 myCoffHeader      dllExpFilHdr;
 mySectionTable    edataSecTab;
 mySectionTable    drctveSecTab;
 myRelocationEntry edataRelEnt;
 mySymbolTable     edataSymEnt;
 mySymbolEntry     *actSymEnt;

 CMyMemFile *dllExpFilRawDat;
 CMyMemFile *expFilSymTab;
 CMyMemFile *expFilStrTab;
 POSITION   symEntPos;

 CFile          actDllExpFil;
 CFileException *pErr= NULL;

 
 DWORD strTabLen= 0x04;
 DWORD actExpOrd;
	WORD expNum;
	WORD relNum;

 char  *expFilDrctveStr;
 char  *symNam;
 char  *expSymNam;
 BYTE  drctveHlpStr[12]= {0x20, 0x2D, 0x44, 0x4C, 0x4C, 0x20, 0x2D, 0x4F, 0x55, 0x54, 0x3A, 0x00};
 BYTE  *expFilEdataRawDatBuf;
 BYTE  *datBuf;
 

 dllExpFilRawDat= new CMyMemFile();

 expNum= (WORD )expFncLst-> GetCount();
 relNum= (WORD )(4 + 2 * expNum);
 expFilDrctveStr= (char *) malloc(sizeof(drctveHlpStr) + strlen(dllOrExeFilNam) + 2);
 memcpy(expFilDrctveStr, drctveHlpStr, sizeof(drctveHlpStr));
 expFilDrctveStr= strncat(expFilDrctveStr, dllOrExeFilNam, strlen(dllOrExeFilNam) + 1);

 /*** Initialisieren Export File COFF Header ***/
 
 dllExpFilHdr.mach= 0x14C;
 dllExpFilHdr.secNum= 2;
 dllExpFilHdr.timDatStp= actExpDirTab.timDatStp;
 dllExpFilHdr.symTabPtr= COF_HDR_SIZ + 2 * SEC_HDR_SIZ + expFilEdataRawDat-> GetLength() +
                         relNum * REL_ENT_SIZ + strlen(expFilDrctveStr) + 1;
 dllExpFilHdr.symNum= 2 + expNum;
 dllExpFilHdr.optHdrSiz= 0;
 dllExpFilHdr.chr= 0x100;
 
 dllExpFilRawDat-> Write(&dllExpFilHdr, COF_HDR_SIZ);
 
 /*** Initialisieren der Sectiontables ***/

 memset(&edataSecTab, 0, SEC_HDR_SIZ);
 memcpy(&edataSecTab.secNam, ".edata", strlen(".edata"));
 edataSecTab.rawDatSiz= expFilEdataRawDat-> GetLength();
 edataSecTab.rawDatPtr= COF_HDR_SIZ + 2 * SEC_HDR_SIZ;
 edataSecTab.relPtr= edataSecTab.rawDatPtr + expFilEdataRawDat-> GetLength();
 edataSecTab.relNum= relNum;
 edataSecTab.chr= 0x40000040;

 memset(&drctveSecTab, 0, SEC_HDR_SIZ);
 memcpy(&drctveSecTab.secNam, ".drectve", strlen(".drectve"));
 drctveSecTab.rawDatSiz= strlen(expFilDrctveStr) + 1;
 drctveSecTab.rawDatPtr= edataSecTab.rawDatPtr + edataSecTab.rawDatSiz + relNum * REL_ENT_SIZ;
 drctveSecTab.chr= 0x00000A00;

 dllExpFilRawDat-> Write(&edataSecTab, SEC_HDR_SIZ);
 dllExpFilRawDat-> Write(&drctveSecTab, SEC_HDR_SIZ);
 
 expFilEdataRawDat-> SeekToBegin(); 
 expFilEdataRawDatBuf= (BYTE *)expFilEdataRawDat-> ReadWithoutMemcpy(expFilEdataRawDat-> GetLength());
 dllExpFilRawDat-> Write(expFilEdataRawDatBuf, expFilEdataRawDat-> GetLength()); 

 /*** Erstellen der Relocationen für die .edata Section ***/

 expFilSymTab= new CMyMemFile();
 expFilStrTab= new CMyMemFile();
 
 edataRelEnt.typ= 0x0007;

 /* .edata Symbol */
 memset(&edataSymEnt, 0, SYM_TAB_LEN);
 memcpy(&edataSymEnt, ".edata", sizeof(".edata"));
 edataSymEnt.secNum= 0x1;
 edataSymEnt.storClass= 0x3;

 expFilSymTab-> Write(&edataSymEnt, SYM_TAB_LEN);

 /* Relocationen des .edata Headers */

 edataRelEnt.off= 0x0C;
 edataRelEnt.symTabInd= 0;
 dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);
 edataRelEnt.off= 0x1C;
 dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);
 edataRelEnt.off= 0x20;
 dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);
 edataRelEnt.off= 0x24;
 dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);

 symEntPos= expFncLst-> GetHeadPosition();
 while(symEntPos)
 {
  actSymEnt= (mySymbolEntry *)expFncLst-> GetNext(symEntPos);
  symNam= actSymEnt-> symNam;
  while(*(symNam) == '_')
			symNam++;

  expFilStrTab-> Write(symNam, strlen(symNam) + 1);
  strTabLen+= strlen(symNam) + 1;  
 }

 /* Relocationen der exportierten Funktionen */
 
 symEntPos= expFncLst-> GetHeadPosition();
 actExpOrd= 0;
 while(symEntPos)
 {
  edataRelEnt.off= EXP_DIR_TAB_SIZ + actExpOrd * sizeof(DWORD);
  edataRelEnt.symTabInd= ++actExpOrd;
  dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);
  edataRelEnt.off+= relNum * sizeof(DWORD);
  edataRelEnt.symTabInd= 0x0;
  dllExpFilRawDat-> Write(&edataRelEnt, REL_ENT_SIZ);

  actSymEnt= (mySymbolEntry *)expFncLst-> GetNext(symEntPos);
  symNam= actSymEnt-> symNam;
  memset(&edataSymEnt, 0, SYM_TAB_LEN);
  if (strlen(symNam) < 9)
   memcpy(&edataSymEnt, symNam, strlen(symNam));
  else
  {
   edataSymEnt.zero= 0x00;
   edataSymEnt.strTabOff= strTabLen;
   expFilStrTab-> Write(symNam, strlen(symNam) + 1);
   strTabLen+= strlen(symNam) + 1;  
  }
  edataSymEnt.storClass= 0x2;
  expFilSymTab-> Write(&edataSymEnt, SYM_TAB_LEN);
 }

 dllExpFilRawDat-> Write(expFilDrctveStr, strlen(expFilDrctveStr) + 1);

 expSymNam= (char *) malloc(strlen(dllOrExeFilNam) + strlen("_EXPORTS"));
 expSymNam= strncpy(expSymNam, dllOrExeFilNam, strlen(dllOrExeFilNam) - 4);
 expSymNam[strlen(dllOrExeFilNam) - 4]= '\0';
 expSymNam= strcat(expSymNam, "_EXPORTS");
 edataSymEnt.zero= 0x0;
 edataSymEnt.strTabOff= strTabLen;
 edataSymEnt.secNum= 0x1;
 edataSymEnt.storClass= 0x2;
 expFilSymTab-> Write(&edataSymEnt, SYM_TAB_LEN);
 strTabLen+= strlen(expSymNam) + 1;  
 expFilStrTab-> Write(expSymNam, strlen(expSymNam) + 1);
 free(expSymNam);

 expFilSymTab-> SeekToBegin();
 datBuf= (BYTE *)expFilSymTab-> ReadWithoutMemcpy(expFilSymTab-> GetLength());
 dllExpFilRawDat-> Write(datBuf, expFilSymTab-> GetLength());
 dllExpFilRawDat-> Write(&strTabLen, sizeof(DWORD));
 expFilStrTab-> SeekToBegin();
 datBuf= (BYTE *)expFilStrTab-> ReadWithoutMemcpy(expFilStrTab-> GetLength());
 dllExpFilRawDat-> Write(datBuf, expFilStrTab-> GetLength());

 FreeCMyMemFile(expFilSymTab);
	delete expFilSymTab;
 FreeCMyMemFile(expFilStrTab);
	delete expFilStrTab;
	
 dllExpFilRawDat-> SeekToBegin();
 datBuf= (BYTE *)dllExpFilRawDat-> ReadWithoutMemcpy(dllExpFilRawDat-> GetLength());
 if (!actDllExpFil.Open(expFilNam, CFile::modeCreate | CFile::modeWrite | CFile::typeBinary, pErr))
		WriteMessageToPow(WRN_MSGC_BLD_EXP_FIL, (char *)expFilNam, NULL);
	else
	{
		actDllExpFil.Write(datBuf, dllExpFilRawDat-> GetLength());
		actDllExpFil.Close();
		actDllExpFil.~CFile();
	}

 FreeCMyMemFile(dllExpFilRawDat);
	delete dllExpFilRawDat;

	free(expFilDrctveStr);

	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der Importbibliothek der Dynamic Link Library																																				***/
/**************************************************************************************************/

BOOL CExeFileExportSection::BuildDllLibFile(char *dllOrExeFilNam, char *dllLibFilNam, CExeFile *exeFil)
{
 CFile          dllLibFil;
 CFileException *pErr= NULL;

 CMyMemFile     *dllLibFilRawDat;
 CMyMemFile     *modsRawDat;
 CMyMemFile     *actModRawDat;
 CMyMemFile     *actModStrTabBuf;

 DWORD modsRawDatPtr;
 DWORD actModRawDatSiz;

 myLibFileHeader libFilHdr;
 
 BYTE archFilSgn[8]= {0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A};
 BYTE archFilNam[16]= {0x2F, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
                       0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20};

 CMyMemFile *fstLnkMmbStrTab;
 CMyMemFile *secLnkMmbStrTab;

	// BEGIN: Changed 22.11.1998 CS
	CMyMemFile	*thdLnkMmbStrTab;
	// END: Changed 22.11.1998 CS
 
 DWORD firstMemberOffset;
 DWORD **fstLnkMmb;
 DWORD *fstLnkMmbPtr;
 DWORD fstLnkMmbNum;
 BYTE  fstLnkMmbLitEnd[4];

 myExportRecord **secLnkExpLst;
 myExportRecord *secLnkExpLstPtr;
 
 myExportRecord *hlpSrtExpRec;
 CMyPtrList     *secLnkSrtHlpLst;    
 POSITION       expEntPos;
 POSITION       oldExpEntPos;
 BOOL           insDon;
 
 DWORD **secLnkMmb;
 DWORD *secLnkMmbOff;
 DWORD secLnkMmbIndNmb;
	DWORD	secLnkMmbOffNmb;

 DWORD libFilHdrSiz;
 
 DWORD timDatStp;
 DWORD libModSiz;
 BYTE  *datBuf;
 BYTE  tDatStp[16];
 BYTE  lModSiz[10];

 WORD  timDatInd;
 WORD  secTimDatInd;
 WORD  libModSizInd;
 WORD  secLibModSizInd;

 BYTE  libAlnBuf= 0x0A;


 /*** Lib Module Definitions **/

 myLibFileHeader                  actModHdr;
 myCoffHeader                     actModCofHdr;
 myOptionalHeaderStandardFields   actModOptStdHdr;
 myOptionalHeaderNtSpecificFields actModOptNtHdr;
 myOptionalHeaderDataDirectory    actModOptDatDir;

	char actModNam[16];
	
 LPSTR impDes="__IMPORT_DESCRIPTOR_";
 LPSTR nulImpDes= "__NULL_IMPORT_DESCRIPTOR";
 BYTE  nulThkBgnSgn= 0x7F;
 LPSTR nulThkDat= "_NULL_THUNK_DATA";

 LPSTR txtNam= ".text";
 LPSTR dbgNam= ".";
 LPSTR iDat2Nam= ".idata$2";
 LPSTR iDat3Nam= ".idata$3";
 LPSTR iDat4Nam= ".idata$4";
 LPSTR iDat5Nam= ".idata$5";
 LPSTR iDat6Nam= ".idata$6";
 DWORD iDat4RawDat;
 DWORD iDat5RawDat;

 BYTE  txtRawDat[6]= {0xFF, 0x25, 0x00, 0x00, 0x00, 0x00};
 BYTE  iDat2RawDat[20];
 BYTE  iDat3RawDat[20];
 
 mySectionTable txtSecTab;
	mySectionTable dbgSecTab;
 mySectionTable iDat2SecTab;
 mySectionTable iDat3SecTab;
 mySectionTable iDat4SecTab;
 mySectionTable iDat5SecTab;
 mySectionTable iDat6SecTab;
 
 myRelocationEntry txtRelEnt;
 myRelocationEntry iDat2RelEnt[3];
 myRelocationEntry dbgRelEnt[2];

 mySymbolTable impDesSymTab;
	mySymbolTable nulImpDesSymTab;
 mySymbolTable nulThkDatSymTab;
 mySymbolTable txtSymTab;
 mySymbolTable iDat2SymTab;
 mySymbolTable iDat4SymTab;
 mySymbolTable iDat5SymTab;
 mySymbolTable iDat6SymTab;
 mySymbolTable expFncSymTab;
 mySymbolTable impExpFncSymTab;

 mySectionDefinitions hlpTxtSymTab;
 mySectionDefinitions hlpIDat4SymTab;
 mySectionDefinitions hlpIDat5SymTab;

 myThunkStart  thkStart;
 DWORD         thkSrtBgnRec= 0x00000001;
 DWORD         thkSrtEndRec= 0x00060002;

 myExportRecord *actExpRec;
 LPSTR          hlpSymNam;
 LPSTR          dbgSecSymNam;
 LPSTR          hlpDbgSecSymNam;
 
 WORD expSymNum;
 WORD expSymInd;

	char *strOff;
 
 /*** Init Global ***/

 dllLibFilRawDat= new CMyMemFile(); 
 modsRawDat= new CMyMemFile();
 modsRawDatPtr= 0;


 memset(&libFilHdr, 0x20, 44);
 
 timDatStp= CalcTimeDateStamp();
 
 memset(&actModCofHdr, 0x00, COF_HDR_SIZ);
 actModCofHdr.timDatStp= timDatStp;

 timDatInd= 0;
 
 while (timDatStp)
 {
  tDatStp[timDatInd++]= (BYTE )(timDatStp - 10 * (timDatStp / 10));
  timDatStp= timDatStp/10;
 }

 secTimDatInd= 0;

 while (timDatInd)
  libFilHdr.dat[secTimDatInd++]= (BYTE )(0x30 + tDatStp[--timDatInd]);

 libFilHdr.mod[0]= 0x30;
 libFilHdr.hdrEnd= 0x0A60;
 memcpy(&actModHdr, &libFilHdr, 0x44);

 /*** Linker Member Initialisations ***/

 fstLnkMmbStrTab= new CMyMemFile(0x2000);
	secLnkMmbIndNmb= 0x03 + 2 * expFncLst-> GetCount();
 fstLnkMmbNum= secLnkMmbIndNmb + exeFil-> objFilNum; // object modules added for Pow!
	secLnkMmbOffNmb= 0x03 + expFncLst-> GetCount();
 fstLnkMmb= (DWORD **) malloc((fstLnkMmbNum + 1) * sizeof(DWORD));
 fstLnkMmbPtr= (DWORD *)fstLnkMmb;
 secLnkMmb= (DWORD **) malloc((secLnkMmbOffNmb + 1) * sizeof(DWORD));
 secLnkMmbOff= (DWORD *)secLnkMmb;

	// BEGIN: Changed 22.11.1998 CS
 //secLnkExpLst= (myExportRecord **) malloc((secLnkMmbIndNmb + 1) * sizeof(myExportRecord));
	// CHANGED TO
	secLnkExpLst= (myExportRecord **) malloc((secLnkMmbIndNmb + exeFil-> objFilNum + 1) * sizeof(myExportRecord));
	secLnkMmbIndNmb+= exeFil-> objFilNum;
	// END: Changed 22.11.1998 CS

 secLnkExpLstPtr= (myExportRecord *)secLnkExpLst;

	// BEGIN: Changed 22.11.1998 CS
	thdLnkMmbStrTab= new CMyMemFile(0x50);
	
	/* Überprüfen, ob der Name der DLL in den Third Linker Member geschrieben werden muß */

	/*** Module Name ***/

	memset(actModNam, 0x20, 16);
	
	if (strlen(dllOrExeFilNam) < 16)
	{
		strcpy(actModNam, dllOrExeFilNam);
		actModNam[strlen(actModNam)]= '/';
	}
	else
	{
		actModNam[0]= '/';
		libModSiz= thdLnkMmbStrTab-> GetLength();

		
		if (libModSiz == 0)
			actModNam[1]= (BYTE )(0x30);
		else
		{
			libModSizInd= 0;

			while (libModSiz)
			{
				lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
			 libModSiz= libModSiz/10;
			}

			secLibModSizInd= 1;
		
			while (libModSizInd)
			 actModNam[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);
		}		

		thdLnkMmbStrTab-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) + 1);
	}

	// END: Changed 22.11.1998 CS


 /********************************************************************/
 /************************ IMPORT_DESCRIPTOR *************************/
 /********************************************************************/

 /*** Init ***/

 actModRawDat= new CMyMemFile();
 actModStrTabBuf= new CMyMemFile();
 actModStrTabBuf-> Seek(sizeof(DWORD), CFile::begin);
 actModRawDatSiz= 0;
 
 // BEGIN: Changed 22.11.1998 CS 
	
	/*** Module Name ***/
 
 //memset(actModNam, 0x20, 16);
	
	//if (strlen(dllOrExeFilNam) >= 16)
	//	memcpy(actModNam, dllOrExeFilNam, 16);
	//else
	//{
	//	strcpy(actModNam, dllOrExeFilNam);
	//	actModNam[strlen(actModNam)]= 0x2F;
	//}

	// END: Changed 22.11.1998 CS
		
 /*** Coff Header ***/
  
 actModCofHdr.mach= 0x014C;
 actModCofHdr.secNum= 0x0002;
 actModCofHdr.optHdrSiz= EXE_OPT_HDR_STD_FDS_SIZ + EXE_OPT_HDR_NT_SPC_FDS_SIZ + 
                         EXE_OPT_HDR_DATA_DIR_SIZ;
 actModCofHdr.chr= 0x0100;

 /*** Optional Header Standard Fields ***/

 memset(&actModOptStdHdr, 0x00, EXE_OPT_HDR_STD_FDS_SIZ);
 actModOptStdHdr.mag= 0x010B;
 actModOptStdHdr.lnkMaj= 0x02;
 actModOptStdHdr.lnkMin= 0x32;
 
 /*** Optional Header WinNt Specific Fields ***/
 
 memset(&actModOptNtHdr, 0x00, EXE_OPT_HDR_NT_SPC_FDS_SIZ);
 actModOptNtHdr.secAln= 0x00001000;
 actModOptNtHdr.filAln= 0x00000200;
 actModOptNtHdr.osMaj= 0x0001;
 actModOptNtHdr.stkResSiz= 0x00100000;
 actModOptNtHdr.stkComSiz= 0x00010000;		// changed from 0x1000 to 0x10000 by PDI due to problem with enter instruction at the beginning of ProgMain
 actModOptNtHdr.heaResSiz= 0x00100000;
 actModOptNtHdr.heaComSiz= 0x00001000;
 actModOptNtHdr.datDirNum= 0x00000010;
 
 /*** Data Directory ***/

 memset(&actModOptDatDir, 0x00, EXE_OPT_HDR_DATA_DIR_SIZ);
 

 /*** Sektionstabelle ***/

 memset(&iDat2SecTab, 0x00, SEC_HDR_SIZ);
 memset(&iDat6SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat2SecTab.secNam, iDat2Nam, strlen(iDat2Nam));
 memcpy(&iDat6SecTab.secNam, iDat6Nam, strlen(iDat6Nam));

 iDat2SecTab.rawDatSiz= sizeof(iDat2RawDat);
 iDat2SecTab.rawDatPtr= COF_HDR_SIZ + EXE_OPT_HDR_STD_FDS_SIZ + EXE_OPT_HDR_NT_SPC_FDS_SIZ +
                        EXE_OPT_HDR_DATA_DIR_SIZ + actModCofHdr.secNum * SEC_HDR_SIZ;
 iDat2SecTab.relPtr= iDat2SecTab.rawDatPtr + iDat2SecTab.rawDatSiz;
 iDat2SecTab.relNum= 0x03;
 iDat2SecTab.chr= 0xC0000048;

 memset(&iDat2RawDat, 0x00, sizeof(iDat2RawDat));
 
 iDat6SecTab.rawDatSiz= strlen(dllOrExeFilNam) + 1;
 if (BytesTillAlignEnd(iDat6SecTab.rawDatSiz, sizeof(WORD)))
  iDat6SecTab.rawDatSiz++;
 iDat6SecTab.rawDatPtr= iDat2SecTab.relPtr + iDat2SecTab.relNum * REL_ENTRY_SIZ;
 iDat6SecTab.relPtr= iDat2SecTab.relPtr;
 iDat6SecTab.chr= 0xC0200040;

 iDat2RelEnt[0].off= 0x0000000C;
 iDat2RelEnt[0].symTabInd= 0x00000002;
 iDat2RelEnt[0].typ= 0x0007;
 iDat2RelEnt[1].off= 0x00000000;
 iDat2RelEnt[1].symTabInd= 0x00000003;
 iDat2RelEnt[1].typ= 0x0007;
 iDat2RelEnt[2].off= 0x00000010;
 iDat2RelEnt[2].symTabInd= 0x00000004;
 iDat2RelEnt[2].typ= 0x0007;

 actModRawDat-> Seek(COF_HDR_SIZ, CFile::begin);
 actModRawDat-> Write(&actModOptStdHdr, EXE_OPT_HDR_STD_FDS_SIZ);
 actModRawDat-> Write(&actModOptNtHdr, EXE_OPT_HDR_NT_SPC_FDS_SIZ);
 actModRawDat-> Write(&actModOptDatDir, EXE_OPT_HDR_DATA_DIR_SIZ);
 actModRawDat-> Write(&iDat2SecTab, SEC_HDR_SIZ);
 actModRawDat-> Write(&iDat6SecTab, SEC_HDR_SIZ);
 actModRawDat-> Write(&iDat2RawDat, sizeof(iDat2RawDat));
 actModRawDat-> Write(&iDat2RelEnt[0], REL_ENTRY_SIZ);
 actModRawDat-> Write(&iDat2RelEnt[1], REL_ENTRY_SIZ);
 actModRawDat-> Write(&iDat2RelEnt[2], REL_ENTRY_SIZ);

 actModRawDat-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) + 1);
 if (BytesTillAlignEnd(actModRawDat-> GetPosition(), sizeof(WORD)))
  actModRawDat-> Write(chrBuf00, sizeof(BYTE));

 actModCofHdr.symTabPtr= actModRawDat-> GetPosition();

 /*** Symboltabelle ***/

 /* import_descriptor */

 memset(&impDesSymTab, 0x00, SYM_TAB_LEN);
 impDesSymTab.strTabOff= actModStrTabBuf-> GetPosition();
 impDesSymTab.secNum= 0x0001;
 impDesSymTab.storClass= 0x02;

 actModRawDat-> Write(&impDesSymTab, SYM_TAB_LEN);
	actModStrTabBuf-> Write(impDes, strlen(impDes));
 actModStrTabBuf-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) - strlen(".dll"));
 actModStrTabBuf-> Write(chrBuf00, sizeof(BYTE));
	
	secLnkExpLstPtr-> expSymNam= (char *) malloc(strlen(impDes) + strlen(dllOrExeFilNam));
	memset(secLnkExpLstPtr-> expSymNam, 0x00, strlen(impDes) + strlen(dllOrExeFilNam));
	strcpy(secLnkExpLstPtr-> expSymNam, impDes);
	strncat(secLnkExpLstPtr-> expSymNam, dllOrExeFilNam, strlen(dllOrExeFilNam) - strlen(".dll"));
 fstLnkMmbStrTab-> SeekToBegin();
	fstLnkMmbStrTab-> Write(secLnkExpLstPtr-> expSymNam, strlen(secLnkExpLstPtr-> expSymNam) + 1);
	
	secLnkExpLstPtr-> expSymOrd= 0x0001;
 secLnkExpLstPtr++;

 /* .idata$2 */

 memset(&iDat2SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat2SymTab.zero, iDat2Nam, sizeof(DWORD));
 memcpy(&iDat2SymTab.strTabOff, (iDat2Nam + sizeof(DWORD)) , sizeof(DWORD));
 iDat2SymTab.val= 0xC0000040;
 iDat2SymTab.secNum= 0x0001;
 iDat2SymTab.storClass= 0x68;
 actModRawDat-> Write(&iDat2SymTab, SYM_TAB_LEN);

 /* .idata$6 */

 memset(&iDat6SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat6SymTab.zero, iDat6Nam, sizeof(DWORD));
 memcpy(&iDat6SymTab.strTabOff, (iDat6Nam + sizeof(DWORD)), sizeof(DWORD));
 iDat6SymTab.secNum= 0x0002;
 iDat6SymTab.storClass= 0x03;
 actModRawDat-> Write(&iDat6SymTab, SYM_TAB_LEN);

 /* .idata$4 */

 memset(&iDat4SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat4SymTab.zero, iDat4Nam, sizeof(DWORD));
 memcpy(&iDat4SymTab.strTabOff, (iDat4Nam + sizeof(DWORD)), sizeof(DWORD));
 iDat4SymTab.val= 0xC0000040;
 iDat4SymTab.storClass= 0x68;
 actModRawDat-> Write(&iDat4SymTab, SYM_TAB_LEN);

 /* .idata$5 */

 memset(&iDat5SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat5SymTab.zero, iDat5Nam, sizeof(DWORD));
 memcpy(&iDat5SymTab.strTabOff, (iDat5Nam + sizeof(DWORD)), sizeof(DWORD));
 iDat5SymTab.val= 0xC0000040;
 iDat5SymTab.storClass= 0x68;
 actModRawDat-> Write(&iDat5SymTab, SYM_TAB_LEN);

 /* null_import_descriptor */

 memset(&nulImpDesSymTab, 0x00, SYM_TAB_LEN);
 nulImpDesSymTab.strTabOff= actModStrTabBuf-> GetPosition();
 nulImpDesSymTab.storClass= 0x02;

 actModRawDat-> Write(&nulImpDesSymTab, SYM_TAB_LEN);
 actModStrTabBuf-> Write(nulImpDes, strlen(nulImpDes) + 1);

 /* null_thunk_data */

 memset(&nulThkDatSymTab, 0x00, SYM_TAB_LEN);
 nulThkDatSymTab.strTabOff= actModStrTabBuf-> GetPosition();
 nulThkDatSymTab.storClass= 0x02;

 actModRawDat-> Write(&nulThkDatSymTab, SYM_TAB_LEN);
 actModStrTabBuf-> Write(&nulThkBgnSgn, sizeof(BYTE));
 actModStrTabBuf-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) - strlen(".dll"));
 actModStrTabBuf-> Write(nulThkDat, strlen(nulThkDat) + 1);

 /*** --------------- ***/
 
 actModCofHdr.symNum= (actModRawDat-> GetPosition() - actModCofHdr.symTabPtr) / SYM_TAB_LEN;
  
 actModRawDatSiz= actModStrTabBuf-> GetPosition();

 if (BytesTillAlignEnd(actModStrTabBuf-> GetPosition(), sizeof(WORD)))
  actModStrTabBuf-> Write(&libAlnBuf, sizeof(BYTE));

 actModStrTabBuf-> SeekToBegin();
 actModStrTabBuf-> Write(&actModRawDatSiz, sizeof(DWORD));
 actModStrTabBuf-> SeekToBegin();
 datBuf= (BYTE *)actModStrTabBuf-> ReadWithoutMemcpy(actModStrTabBuf-> GetLength());
 actModRawDat-> Write(datBuf, actModStrTabBuf-> GetLength());

 actModRawDat-> SeekToBegin();
 actModRawDat-> Write(&actModCofHdr, COF_HDR_SIZ);
 actModRawDat-> SeekToBegin();

 /* Library Module Header Size */
 
 memset(&actModHdr.siz, 0x20, 10);
 libModSiz= actModRawDat-> GetLength();
 libModSizInd= 0;
 
 while (libModSiz)
 {
  lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
  libModSiz= libModSiz/10;
 }

 secLibModSizInd= 0;

 while (libModSizInd)
  actModHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 /* Include Library Module */

 *fstLnkMmbPtr= modsRawDat-> GetPosition();
 fstLnkMmbPtr++;
 *secLnkMmbOff= modsRawDat-> GetPosition();
 secLnkMmbOff++;
 
 modsRawDat-> Write(actModNam, sizeof(actModNam));

 modsRawDat-> Write(&actModHdr, LIB_FIL_HDR_SIZ);
 actModRawDat-> SeekToBegin();
 datBuf= (BYTE *)actModRawDat-> ReadWithoutMemcpy(actModRawDat-> GetLength());
 modsRawDat-> Write(datBuf, actModRawDat-> GetLength());

 if (BytesTillAlignEnd(modsRawDat-> GetLength(), sizeof(WORD)))
   modsRawDat-> Write(&libAlnBuf, sizeof(BYTE));


 /*** Destruct ***/

 TestHeap();
 
 FreeCMyMemFile(actModStrTabBuf);
 delete actModStrTabBuf;
 FreeCMyMemFile(actModRawDat);
 delete actModRawDat;
                  
                   
 /********************************************************************/
 /********************* NULL_IMPORT_DESCRIPTOR ***********************/
 /********************************************************************/

 /*** Init ***/

 actModRawDat= new CMyMemFile();
 actModStrTabBuf= new CMyMemFile();
 actModStrTabBuf-> Seek(sizeof(DWORD), CFile::begin);
 actModRawDatSiz= 0;
 libModSiz= 0;
 
 /*** Module Name ***/
  
 /*** Coff Header ***/
  
 actModCofHdr.mach= 0x014C;
 actModCofHdr.secNum= 0x0001;
 actModCofHdr.optHdrSiz= 0x0000;
 actModCofHdr.chr= 0x0100;

 /*** Sektionstabelle ***/

 memset(&iDat3SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat3SecTab.secNam, iDat3Nam, strlen(iDat3Nam));

 iDat3SecTab.rawDatSiz= sizeof(iDat3RawDat);
 iDat3SecTab.rawDatPtr= COF_HDR_SIZ + actModCofHdr.secNum * SEC_HDR_SIZ;
 iDat3SecTab.chr= 0xC0000048;

 memset(&iDat3RawDat, 0x00, sizeof(iDat3RawDat));
 
 actModRawDat-> Seek(COF_HDR_SIZ, CFile::begin);
 actModRawDat-> Write(&iDat3SecTab, SEC_HDR_SIZ);
 actModRawDat-> Write(&iDat3RawDat, sizeof(iDat3RawDat));

 actModCofHdr.symTabPtr= actModRawDat-> GetPosition();

 /*** Symboltabelle ***/

 /* null_import_descriptor */

 memset(&nulImpDesSymTab, 0x00, SYM_TAB_LEN);
 nulImpDesSymTab.strTabOff= actModStrTabBuf-> GetPosition();
 nulImpDesSymTab.secNum= 0x0001;
 nulImpDesSymTab.storClass= 0x02;

 actModRawDat-> Write(&nulImpDesSymTab, SYM_TAB_LEN);
 actModStrTabBuf-> Write(nulImpDes, strlen(nulImpDes) + 1);

	strOff= (char *) fstLnkMmbStrTab-> ReadWithoutMemcpy();
 fstLnkMmbStrTab-> Write(nulImpDes, strlen(nulImpDes) + 1);
	secLnkExpLstPtr-> expSymNam= (char *) malloc(strlen(strOff) + 1);
	strcpy(secLnkExpLstPtr-> expSymNam, strOff);

	secLnkExpLstPtr-> expSymOrd= 0x0002;
 secLnkExpLstPtr++;


 /*** --------------- ***/
 
 actModCofHdr.symNum= (actModRawDat-> GetPosition() - actModCofHdr.symTabPtr) / SYM_TAB_LEN;
  
 actModRawDatSiz= actModStrTabBuf-> GetPosition();

 if (BytesTillAlignEnd(actModStrTabBuf-> GetPosition(), sizeof(WORD)))
 {
  actModStrTabBuf-> Write(&libAlnBuf, sizeof(BYTE));
  libModSiz= 0xFFFFFFFF;	// -1
 }

 actModStrTabBuf-> SeekToBegin();
 actModStrTabBuf-> Write(&actModRawDatSiz, sizeof(DWORD));
 actModStrTabBuf-> SeekToBegin();
 datBuf= (BYTE *)actModStrTabBuf-> ReadWithoutMemcpy(actModStrTabBuf-> GetLength());
 actModRawDat-> Write(datBuf, actModStrTabBuf-> GetLength());

 actModRawDat-> SeekToBegin();
 actModRawDat-> Write(&actModCofHdr, COF_HDR_SIZ);
 actModRawDat-> SeekToBegin();

 /* Library Module Header Size */
 
 memset(&actModHdr.siz, 0x20, 10);
 libModSiz+= actModRawDat-> GetLength();
 libModSizInd= 0;
 
 while (libModSiz)
 {
  lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
  libModSiz= libModSiz/10;
 }

 secLibModSizInd= 0;

 while (libModSizInd)
  actModHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 /* Include Library Module */
 
 *fstLnkMmbPtr= modsRawDat-> GetPosition();
 fstLnkMmbPtr++;
 *secLnkMmbOff= modsRawDat-> GetPosition();
 secLnkMmbOff++;
 
 modsRawDat-> Write(actModNam, sizeof(actModNam));
 modsRawDat-> Write(&actModHdr, LIB_FIL_HDR_SIZ);
 actModRawDat-> SeekToBegin();
 datBuf= (BYTE *)actModRawDat-> ReadWithoutMemcpy(actModRawDat-> GetLength());
 modsRawDat-> Write(datBuf, actModRawDat-> GetLength());

 if (BytesTillAlignEnd(modsRawDat-> GetLength(), sizeof(WORD)))
   modsRawDat-> Write(&libAlnBuf, sizeof(BYTE));

 /*** Destruct ***/
 
 FreeCMyMemFile(actModRawDat);
 delete actModRawDat;
 FreeCMyMemFile(actModStrTabBuf);
 delete actModStrTabBuf;
 
 /********************************************************************/
 /************************ NULL_THUNK_DATA ***************************/
 /********************************************************************/

 /*** Init ***/

 actModRawDat= new CMyMemFile();
 actModStrTabBuf= new CMyMemFile();
 actModStrTabBuf-> Seek(sizeof(DWORD), CFile::begin);
 actModRawDatSiz= 0;
 libModSiz= 0;
 
 /*** Module Name ***/
  
 /*** Coff Header ***/
  
 actModCofHdr.mach= 0x014C;
 actModCofHdr.secNum= 0x0002;
 actModCofHdr.chr= 0x0100;

 /*** Sektionstabelle ***/

 /* .idata$5 */

 memset(&iDat5SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat5SecTab.secNam, iDat5Nam, strlen(iDat5Nam));

 iDat5SecTab.rawDatSiz= sizeof(iDat5RawDat);
 iDat5SecTab.rawDatPtr= COF_HDR_SIZ + actModCofHdr.secNum * SEC_HDR_SIZ;
 iDat5SecTab.chr= 0xC0300040;

 memset(&iDat5RawDat, 0x00, sizeof(iDat5RawDat));

 /* .idata$4 */
 
 memset(&iDat4SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat4SecTab.secNam, iDat4Nam, strlen(iDat4Nam));

 iDat4SecTab.rawDatSiz= sizeof(iDat4RawDat);
 iDat4SecTab.rawDatPtr= COF_HDR_SIZ + actModCofHdr.secNum * SEC_HDR_SIZ + iDat5SecTab.rawDatSiz;
 iDat4SecTab.chr= 0xC0300040;

 memset(&iDat4RawDat, 0x00, sizeof(iDat4RawDat));

 /* Write Coff Header and Section Table */

 actModRawDat-> Seek(COF_HDR_SIZ, CFile::begin);
 actModRawDat-> Write(&iDat4SecTab, SEC_HDR_SIZ);
 actModRawDat-> Write(&iDat5SecTab, SEC_HDR_SIZ);
 actModRawDat-> Write(&iDat4RawDat, sizeof(iDat4RawDat));
 actModRawDat-> Write(&iDat5RawDat, sizeof(iDat5RawDat));

 actModCofHdr.symTabPtr= actModRawDat-> GetPosition();

 /*** Symboltabelle ***/

 /* null_thunk_data */

 memset(&nulThkDatSymTab, 0x00, SYM_TAB_LEN);
 nulThkDatSymTab.strTabOff= actModStrTabBuf-> GetPosition();
 nulThkDatSymTab.secNum= 0x0001;
 nulThkDatSymTab.storClass= 0x02;

 actModRawDat-> Write(&nulThkDatSymTab, SYM_TAB_LEN);
 actModStrTabBuf-> Write(&nulThkBgnSgn, sizeof(BYTE));
 actModStrTabBuf-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) - 0x04);
 actModStrTabBuf-> Write(nulThkDat, strlen(nulThkDat) + 1);

	strOff= (char *) fstLnkMmbStrTab-> ReadWithoutMemcpy();
	fstLnkMmbStrTab-> Write(&nulThkBgnSgn, sizeof(BYTE));
 fstLnkMmbStrTab-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) - 0x4);
 fstLnkMmbStrTab-> Write(nulThkDat, strlen(nulThkDat) + 1);
	secLnkExpLstPtr-> expSymNam= (char *) malloc(strlen(strOff) + 1);
	strcpy(secLnkExpLstPtr-> expSymNam, strOff);

	secLnkExpLstPtr-> expSymOrd= 0x0003;
 secLnkExpLstPtr++;

 /*** --------------- ***/
 
 actModCofHdr.symNum= (actModRawDat-> GetPosition() - actModCofHdr.symTabPtr) / SYM_TAB_LEN;
  
 actModRawDatSiz= actModStrTabBuf-> GetPosition();

 if (BytesTillAlignEnd(actModStrTabBuf-> GetPosition(), sizeof(WORD)))
 {
  actModStrTabBuf-> Write(&libAlnBuf, sizeof(BYTE));
  libModSiz= 0xFFFFFFFF;	// -1
 }

 actModStrTabBuf-> SeekToBegin();
 actModStrTabBuf-> Write(&actModRawDatSiz, sizeof(DWORD));
 actModStrTabBuf-> SeekToBegin();
 datBuf= (BYTE *)actModStrTabBuf-> ReadWithoutMemcpy(actModStrTabBuf-> GetLength());
 actModRawDat-> Write(datBuf, actModStrTabBuf-> GetLength());

 actModRawDat-> SeekToBegin();
 actModRawDat-> Write(&actModCofHdr, COF_HDR_SIZ);
 actModRawDat-> SeekToBegin();

 /* Library Module Header Size */
 
 memset(&actModHdr.siz, 0x20, 10);
 libModSiz+= actModRawDat-> GetLength();
 libModSizInd= 0;
 
 while (libModSiz)
 {
  lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
  libModSiz= libModSiz/10;
 }

 secLibModSizInd= 0;

 while (libModSizInd)
  actModHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 /* Include Library Module */
 
 *fstLnkMmbPtr= modsRawDat-> GetPosition();
 fstLnkMmbPtr++;
 *secLnkMmbOff= modsRawDat-> GetPosition();
 secLnkMmbOff++;
 
 modsRawDat-> Write(actModNam, sizeof(actModNam));
 modsRawDat-> Write(&actModHdr, LIB_FIL_HDR_SIZ);
 actModRawDat-> SeekToBegin();
 datBuf= (BYTE *)actModRawDat-> ReadWithoutMemcpy(actModRawDat-> GetLength());
 modsRawDat-> Write(datBuf, actModRawDat-> GetLength());

 if (BytesTillAlignEnd(modsRawDat-> GetLength(), sizeof(WORD)))
   modsRawDat-> Write(&libAlnBuf, sizeof(BYTE));

 /*** Destruct ***/
 
 FreeCMyMemFile(actModRawDat);
 delete actModRawDat;
 FreeCMyMemFile(actModStrTabBuf);
 delete actModStrTabBuf;
                  

 /********************************************************************/
 /********************** EXPORTIERTE SYMBOLE *************************/
 /********************************************************************/

 /*** Global init -  equal to all exportet Library Modules ***/

 /*** Coff Header ***/

 actModCofHdr.mach= 0x014C;
 actModCofHdr.secNum= 0x0004;
 actModCofHdr.chr= 0x0100;
 
 /*** Sektionstabelle ***/

 /* .text */

 memset(&txtSecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&txtSecTab.secNam, txtNam, strlen(txtNam));
 txtSecTab.rawDatSiz= sizeof(txtRawDat);
 txtSecTab.rawDatPtr= COF_HDR_SIZ + actModCofHdr.secNum * SEC_HDR_SIZ;
 txtSecTab.relPtr= txtSecTab.rawDatPtr + txtSecTab.rawDatSiz;
 txtSecTab.relNum= 0x0001;
 txtSecTab.chr= 0x60201020;

 txtRelEnt.off= 0x00000002;
 txtRelEnt.symTabInd= 0x00000008;
 txtRelEnt.typ= 0x0006;

 /* .idata$5 */

 memset(&iDat5SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat5SecTab.secNam, iDat5Nam, strlen(iDat5Nam));

 iDat5SecTab.rawDatSiz= sizeof(iDat5RawDat);
 iDat5SecTab.rawDatPtr= txtSecTab.relPtr + txtSecTab.relNum * REL_ENTRY_SIZ;
 iDat5SecTab.chr= 0xC0301040;
  
 /* .idata$4 */
 
 memset(&iDat4SecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&iDat4SecTab.secNam, iDat4Nam, strlen(iDat4Nam));

 iDat4SecTab.rawDatSiz= sizeof(iDat4RawDat);
 iDat4SecTab.rawDatPtr= iDat5SecTab.rawDatPtr + iDat5SecTab.rawDatSiz;
 iDat4SecTab.chr= 0xC0301040;

 /* .debug$S */


 memset(&thkStart, 0x00, 0x1A);
 thkStart.symTyp= 0x0206;
 memset(&dbgSecTab, 0x00, SEC_HDR_SIZ);
 memcpy(&dbgSecTab.secNam, dbgNam, strlen(dbgNam));
 dbgSecTab.rawDatPtr= iDat4SecTab.rawDatPtr + iDat4SecTab.rawDatSiz;
 dbgSecTab.relNum= 0x0002;
 dbgSecTab.chr= 0x42000048;

 dbgRelEnt[0].off= 0x00000014;
 dbgRelEnt[0].symTabInd= 0x00000006;
 dbgRelEnt[0].typ= 0x000B; 
 dbgRelEnt[1].off= 0x00000018;
 dbgRelEnt[1].symTabInd= 0x00000006;
 dbgRelEnt[1].typ= 0x000A;

 /*** Symboltabelle ***/


 /* .text */

 memset(&txtSymTab, 0x00, SYM_TAB_LEN);
 memcpy(&txtSymTab.zero, txtNam, sizeof(DWORD));
 memcpy(&txtSymTab.strTabOff, (txtNam + sizeof(DWORD)), sizeof(DWORD));
 txtSymTab.secNum= 0x0001;
 txtSymTab.storClass= 0x03;
 txtSymTab.auxSymNum= 0x01;

 memset(&hlpTxtSymTab, 0x00, SYM_TAB_LEN);
 hlpTxtSymTab.len= 0x00000006;
 hlpTxtSymTab.relNmb= 0x0001;
 hlpTxtSymTab.sel= 0x01;
 hlpTxtSymTab.unUsd[1]= 0xC0;
 hlpTxtSymTab.unUsd[2]= 0x01;
  
 /* .idata$5 */

 memset(&iDat5SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat5SymTab.zero, iDat5Nam, sizeof(DWORD));
 memcpy(&iDat5SymTab.strTabOff, (iDat5Nam + sizeof(DWORD)), sizeof(DWORD));
 iDat5SymTab.secNum= 0x0002;
 iDat5SymTab.storClass= 0x03;
 iDat5SymTab.auxSymNum= 0x01;

 memset(&hlpIDat5SymTab, 0x00, SYM_TAB_LEN);
 hlpIDat5SymTab.len= 0x00000004;
 hlpIDat5SymTab.sel= 0x01;
 hlpIDat5SymTab.unUsd[1]= 0xC0;
 hlpIDat5SymTab.unUsd[2]= 0x01;

 /* .idata$4 */

 memset(&iDat4SymTab, 0x00, SYM_TAB_LEN);
 memcpy(&iDat4SymTab.zero, iDat4Nam, sizeof(DWORD));
 memcpy(&iDat4SymTab.strTabOff, (iDat4Nam + sizeof(DWORD)), sizeof(DWORD));
 iDat4SymTab.secNum= 0x0003;
 iDat4SymTab.storClass= 0x03;
 iDat4SymTab.auxSymNum= 0x01;

 memset(&hlpIDat4SymTab, 0x00, SYM_TAB_LEN);
 hlpIDat4SymTab.len= 0x00000004;
 hlpIDat4SymTab.nmb= 0x0002;
 hlpIDat4SymTab.sel= 0x05;
 hlpIDat4SymTab.unUsd[1]= 0xC0;
 hlpIDat4SymTab.unUsd[2]= 0x01;

 /* Function Name */
 
 memset(&expFncSymTab, 0x00, SYM_TAB_LEN);
 expFncSymTab.secNum= 0x0001;
 expFncSymTab.storClass= 0x02;

 /* Import Descriptor */
 
 memset(&impDesSymTab, 0x00, SYM_TAB_LEN);
 impDesSymTab.storClass= 0x02;

 /* Import Function Name */

 memset(&impExpFncSymTab, 0x00, SYM_TAB_LEN);
 impExpFncSymTab.secNum= 0x0002;
 impExpFncSymTab.storClass= 0x02;

 actExpRec= (myExportRecord *)expSymLst;
 expSymNum= (WORD )expFncLst-> GetCount();

 for(expSymInd= 0; expSymInd < expSymNum; expSymInd++)
 {

  /*** Init ***/

  actModRawDat= new CMyMemFile();
  actModStrTabBuf= new CMyMemFile();
  actModStrTabBuf-> Seek(sizeof(DWORD), CFile::begin);
  actModRawDatSiz= 0;
  libModSiz= 0;
 
  /*** Sektionstabelle ***/

  /* .text */
  
  /* .idata$4 */ + /* .idata$5 */

  iDat4RawDat= iDat5RawDat= actExpRec-> expSymOrd + 0x80000000;

  /* .debug$S */

  hlpSymNam= actExpRec-> expSymNam;
  while(*(hlpSymNam) == '_')
			hlpSymNam++;
  dbgSecSymNam= (char *)malloc(strlen(hlpSymNam) + 1);
  strcpy(dbgSecSymNam, hlpSymNam);
  hlpDbgSecSymNam= strchr(dbgSecSymNam, 0x40);
  if (hlpDbgSecSymNam) memset(hlpDbgSecSymNam, 0x00, 1);
		  

  thkStart.symLen= (BYTE )strlen(dbgSecSymNam);
  thkStart.recLen= ((WORD )(sizeof(myThunkStart) + thkStart.symLen - sizeof(DWORD)));
  dbgSecTab.rawDatSiz= 5 * sizeof(WORD) + thkStart.recLen;
                       
  dbgSecTab.relPtr= dbgSecTab.rawDatPtr + dbgSecTab.rawDatSiz;


  /* Write Coff Header and Section Table */

  actModRawDat-> Seek(COF_HDR_SIZ, CFile::begin);
  actModRawDat-> Write(&txtSecTab, SEC_HDR_SIZ);
  actModRawDat-> Write(&iDat5SecTab, SEC_HDR_SIZ);
  actModRawDat-> Write(&iDat4SecTab, SEC_HDR_SIZ);
  actModRawDat-> Write(&dbgSecTab, SEC_HDR_SIZ);

  actModRawDat-> Write(&txtRawDat, 0x06);
  actModRawDat-> Write(&txtRelEnt, REL_ENTRY_SIZ);
  actModRawDat-> Write(&iDat5RawDat, sizeof(iDat5RawDat));
  actModRawDat-> Write(&iDat4RawDat, sizeof(iDat4RawDat));
  actModRawDat-> Write(&thkSrtBgnRec, sizeof(DWORD));
  actModRawDat-> Write(&thkStart, sizeof(myThunkStart) - sizeof(WORD));
  
  actModRawDat-> Write(dbgSecSymNam, strlen(dbgSecSymNam));
  actModRawDat-> Write(&thkSrtEndRec, sizeof(DWORD));

  actModRawDat-> Write(&dbgRelEnt[0], REL_ENTRY_SIZ);
  actModRawDat-> Write(&dbgRelEnt[1], REL_ENTRY_SIZ);

  actModCofHdr.symTabPtr= actModRawDat-> GetPosition();

  free(dbgSecSymNam);

  /*** Symboltabelle ***/


  /* .text */

  /* .idata$5 */

  /* .idata$4 */

  /* Function Name */
 
  expFncSymTab.strTabOff= actModStrTabBuf-> GetPosition();
  actModStrTabBuf-> Write(actExpRec-> expSymNam, strlen(actExpRec-> expSymNam) + 1);  

		secLnkExpLstPtr-> expSymNam= (char *) malloc(strlen(actExpRec-> expSymNam) + 1);
		strcpy(secLnkExpLstPtr-> expSymNam, actExpRec-> expSymNam);
		fstLnkMmbStrTab-> Write(secLnkExpLstPtr-> expSymNam, strlen(actExpRec-> expSymNam) + 1);
		secLnkExpLstPtr-> expSymOrd= 0x0003 + expSymInd + 1;
  secLnkExpLstPtr++;

		secLnkExpLstPtr-> expSymNam= (char *) malloc(strlen(actExpRec-> expSymNam) + strlen("__imp_") + 1);
		strcpy(secLnkExpLstPtr-> expSymNam, "__imp_");
		strcat(secLnkExpLstPtr-> expSymNam, actExpRec-> expSymNam);
		fstLnkMmbStrTab-> Write(secLnkExpLstPtr-> expSymNam, strlen(secLnkExpLstPtr-> expSymNam) + 1);
		secLnkExpLstPtr-> expSymOrd= 0x0003 + expSymInd + 1;
  secLnkExpLstPtr++;

  /* Import Descriptor */
 
  impDesSymTab.strTabOff= actModStrTabBuf-> GetPosition();

  actModStrTabBuf-> Write(impDes, strlen(impDes));
		actModStrTabBuf-> Write(dllOrExeFilNam, strlen(dllOrExeFilNam) - strlen(".Dll"));
  actModStrTabBuf-> Write(chrBuf00, sizeof(BYTE));

  /* Import Function Name */

  impExpFncSymTab.strTabOff= actModStrTabBuf-> GetPosition();

  actModStrTabBuf-> Write("__imp_", strlen("__imp_"));
  actModStrTabBuf-> Write(actExpRec-> expSymNam, strlen(actExpRec-> expSymNam) + 1);  

  actModRawDat-> Write(&txtSymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&hlpTxtSymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&iDat5SymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&hlpIDat5SymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&iDat4SymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&hlpIDat4SymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&expFncSymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&impDesSymTab, SYM_TAB_LEN);
  actModRawDat-> Write(&impExpFncSymTab, SYM_TAB_LEN);

  actModCofHdr.symNum= (actModRawDat-> GetPosition() - actModCofHdr.symTabPtr) / SYM_TAB_LEN;
  actModRawDatSiz= actModStrTabBuf-> GetPosition();
  
  actModStrTabBuf-> SeekToBegin();
  actModStrTabBuf-> Write(&actModRawDatSiz, sizeof(DWORD));
  actModStrTabBuf-> SeekToBegin();
  datBuf= (BYTE *)actModStrTabBuf-> ReadWithoutMemcpy(actModStrTabBuf-> GetLength());
  actModRawDat-> Write(datBuf, actModStrTabBuf-> GetLength());

  actModRawDat-> SeekToBegin();
  actModRawDat-> Write(&actModCofHdr, COF_HDR_SIZ);
  actModRawDat-> SeekToBegin();

  /* Library Module Header Size */
 
  memset(&actModHdr.siz, 0x20, 10);
  libModSiz+= actModRawDat-> GetLength();
  libModSizInd= 0;
 
  while (libModSiz)
  {
   lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
   libModSiz= libModSiz/10;
  }

  secLibModSizInd= 0;

  while (libModSizInd)
   actModHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 /* Include Library Module */

  *fstLnkMmbPtr= modsRawDat-> GetPosition();
  firstMemberOffset=*fstLnkMmbPtr;
  fstLnkMmbPtr++;
  *fstLnkMmbPtr= modsRawDat-> GetPosition();
  fstLnkMmbPtr++;
  *secLnkMmbOff= modsRawDat-> GetPosition();
  secLnkMmbOff++;
 
  modsRawDat-> Write(actModNam, sizeof(actModNam));
  modsRawDat-> Write(&actModHdr, LIB_FIL_HDR_SIZ);
  actModRawDat-> SeekToBegin();
  datBuf= (BYTE *)actModRawDat-> ReadWithoutMemcpy(actModRawDat-> GetLength());
  modsRawDat-> Write(datBuf, actModRawDat-> GetLength());

  if (BytesTillAlignEnd(modsRawDat-> GetLength(), sizeof(WORD)))
   modsRawDat-> Write(&libAlnBuf, sizeof(BYTE));

  /*** Destruct ***/
 
  FreeCMyMemFile(actModRawDat);
  delete actModRawDat;
  FreeCMyMemFile(actModStrTabBuf);
  delete actModStrTabBuf;

  actExpRec++;

 }

 /*** Write Module List ***/
		
	int n;
	char drv[_MAX_DRIVE],dir[_MAX_DIR],fname[_MAX_FNAME],ext[_MAX_EXT];
 DWORD secLnkMmbStrTabLen;

	n=0;
	while (exeFil-> objFilNam[n]) {
  *fstLnkMmbPtr= firstMemberOffset;
  fstLnkMmbPtr++;
		_splitpath(exeFil-> objFilNam[n],drv,dir,fname,ext);
		fstLnkMmbStrTab-> Write(("@@"), strlen("@@"));
		fstLnkMmbStrTab-> Write(fname, strlen(fname) + 1);
		
		// BEGIN: Changed 22.11.1998 CS
		hlpSymNam= (char *) malloc (strlen(fname) + strlen("@@") + 1);
		memset(hlpSymNam, 0x00, strlen(fname) + strlen("@@") + 1);
		strcpy(hlpSymNam, "@@");
		strcat(hlpSymNam, fname);
		secLnkExpLstPtr-> expSymNam= hlpSymNam;
		secLnkExpLstPtr-> expSymOrd= 0x0001;
		secLnkExpLstPtr++;
		// END: Changed 22.11.1998 CS
		n++;		
 }

	// BEGIN: Changed 22.11.1998 CS
	secLnkMmbStrTabLen= fstLnkMmbStrTab-> GetLength();
	// END: Changed 22.11.1998 CS

	
 /*** Build All Library Headers ***/

 // BEGIN: Changed 22.11.1998 CS - Hinzufügen des Third Linker Members
	//libFilHdrSiz= 0x08 + 2 * 0x10 + 2 * LIB_FIL_HDR_SIZ + fstLnkMmbStrTab-> GetLength() + secLnkMmbStrTabLen + 
 //              3 * sizeof(DWORD) + fstLnkMmbNum * sizeof(DWORD) + secLnkMmbOffNmb * sizeof(DWORD) +
 //              secLnkMmbIndNmb * sizeof(WORD); 
	// CHANGED TO.		
	libFilHdrSiz= 0x08 + 3 * 0x10 + 3 * LIB_FIL_HDR_SIZ + fstLnkMmbStrTab-> GetLength() + secLnkMmbStrTabLen + 
               3 * sizeof(DWORD) + fstLnkMmbNum * sizeof(DWORD) + secLnkMmbOffNmb * sizeof(DWORD) +
	              secLnkMmbIndNmb * sizeof(WORD) + thdLnkMmbStrTab-> GetLength(); 
	// END: Changed 22.11.1998 CS
	

	/* Berücksitige DWORD Alignment */

	if (BytesTillAlignEnd(fstLnkMmbStrTab-> GetLength(), sizeof(WORD)))
		libFilHdrSiz++;

	if (BytesTillAlignEnd(secLnkMmbStrTabLen, sizeof(WORD)))
		libFilHdrSiz++;

 *fstLnkMmbPtr= 0x00000000;
 *secLnkMmbOff= 0x00000000;
 
 fstLnkMmbPtr= (DWORD *)fstLnkMmb;
 *fstLnkMmbPtr+= libFilHdrSiz;
 fstLnkMmbPtr++;

 while (*fstLnkMmbPtr)
 {
  *fstLnkMmbPtr+= libFilHdrSiz;
  fstLnkMmbPtr++;
 }
 
 secLnkMmbOff= (DWORD *)secLnkMmb;
 *secLnkMmbOff+= libFilHdrSiz;
 secLnkMmbOff++;
 
 while (*secLnkMmbOff)
 {
  *secLnkMmbOff+= libFilHdrSiz;
  secLnkMmbOff++;
 }
 
	libModSiz= fstLnkMmbStrTab-> GetLength() + sizeof(DWORD) + fstLnkMmbNum * sizeof(DWORD);

	if (BytesTillAlignEnd(fstLnkMmbStrTab-> GetLength(), sizeof(WORD)))
		libModSiz++;
 
 libModSizInd= 0;

 while (libModSiz)
 {
  lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
  libModSiz= libModSiz/10;
 }

 secLibModSizInd= 0;

 while (libModSizInd)
  libFilHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 dllLibFilRawDat-> Write(archFilSgn, 8);

 dllLibFilRawDat-> Write(archFilNam, 16);
 dllLibFilRawDat-> Write(&libFilHdr, LIB_FIL_HDR_SIZ);
 
 memcpy(&fstLnkMmbLitEnd, &fstLnkMmbNum, sizeof(DWORD));
 dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[3], sizeof(BYTE)); 
 dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[2], sizeof(BYTE)); 
 dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[1], sizeof(BYTE)); 
 dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[0], sizeof(BYTE)); 
 
 fstLnkMmbPtr= (DWORD *)fstLnkMmb;
 while (*fstLnkMmbPtr)
 {
  memcpy(&fstLnkMmbLitEnd, fstLnkMmbPtr, sizeof(DWORD));
  dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[3], sizeof(BYTE)); 
  dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[2], sizeof(BYTE)); 
  dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[1], sizeof(BYTE)); 
  dllLibFilRawDat-> Write(&fstLnkMmbLitEnd[0], sizeof(BYTE)); 
  fstLnkMmbPtr++;
 }

 fstLnkMmbStrTab-> SeekToBegin();
 datBuf= (BYTE *)fstLnkMmbStrTab-> ReadWithoutMemcpy(fstLnkMmbStrTab-> GetLength());
 dllLibFilRawDat-> Write(datBuf, fstLnkMmbStrTab-> GetLength());

	if (BytesTillAlignEnd(dllLibFilRawDat-> GetLength(), sizeof(WORD)))
		dllLibFilRawDat-> Write(&chrBuf00, sizeof(BYTE));

 libModSiz= secLnkMmbStrTabLen + 2 * sizeof(DWORD) + secLnkMmbOffNmb * sizeof(DWORD) + 
            secLnkMmbIndNmb * sizeof(WORD);

	if (BytesTillAlignEnd(secLnkMmbStrTabLen, sizeof(WORD)))
		libModSiz++;

 memset(&actModHdr.siz, 0x20, 0x0A);
 libModSizInd= 0;
 
 while (libModSiz)
 {
  lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
  libModSiz= libModSiz/10;
 }

 secLibModSizInd= 0;

 while (libModSizInd)
  libFilHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);

 dllLibFilRawDat-> Write(archFilNam, 16);
 dllLibFilRawDat-> Write(&libFilHdr, LIB_FIL_HDR_SIZ);
 dllLibFilRawDat-> Write(&secLnkMmbOffNmb, sizeof(DWORD));
 dllLibFilRawDat-> Write(secLnkMmb, secLnkMmbOffNmb * sizeof(DWORD));
 dllLibFilRawDat-> Write(&secLnkMmbIndNmb, sizeof(DWORD));

 /* Sort Second Linker Member Ordinal and String List */

 secLnkSrtHlpLst= new CMyPtrList();
 secLnkMmbStrTab= new CMyMemFile();

 secLnkExpLstPtr-> expSymNam= NULL;	// Setzen des letzen Eintrags in der Liste auf NULL, sonst
																																				// wird die folgende Schleife nicht abgebrochen

 secLnkExpLstPtr= (myExportRecord *)secLnkExpLst;

 secLnkSrtHlpLst-> AddTail(secLnkExpLstPtr);
 secLnkExpLstPtr++;

	while(secLnkExpLstPtr-> expSymNam)
 {
  insDon= FALSE;
  expEntPos= secLnkSrtHlpLst-> GetHeadPosition();
  while(expEntPos)
  {
   oldExpEntPos= expEntPos;
   hlpSrtExpRec= (myExportRecord *)secLnkSrtHlpLst-> GetNext(expEntPos);
   if (memcmp(secLnkExpLstPtr-> expSymNam, hlpSrtExpRec-> expSymNam, 
              strlen(hlpSrtExpRec-> expSymNam)) < 0)
   {
    secLnkSrtHlpLst-> InsertBefore(oldExpEntPos, secLnkExpLstPtr);
    expEntPos= 0x0000;
    insDon= TRUE;
   }
  }
  if (!insDon) 
   secLnkSrtHlpLst-> AddTail(secLnkExpLstPtr);

  secLnkExpLstPtr++;
 }

 /* Write Second Linker Member Ordinal and String List */
 
 expEntPos= secLnkSrtHlpLst-> GetHeadPosition();
 while(expEntPos)
 {
  hlpSrtExpRec= (myExportRecord *)secLnkSrtHlpLst-> GetNext(expEntPos);
  dllLibFilRawDat-> Write(&hlpSrtExpRec-> expSymOrd, sizeof(WORD));
  secLnkMmbStrTab-> Write(hlpSrtExpRec-> expSymNam, strlen(hlpSrtExpRec-> expSymNam) + 1);
 }

 secLnkMmbStrTab-> SeekToBegin();
 datBuf= (BYTE *)secLnkMmbStrTab-> ReadWithoutMemcpy(secLnkMmbStrTab-> GetLength());
 dllLibFilRawDat-> Write(datBuf, secLnkMmbStrTab-> GetLength());

	if (BytesTillAlignEnd(dllLibFilRawDat-> GetLength(), sizeof(WORD)))
		dllLibFilRawDat-> Write(&chrBuf00, sizeof(BYTE));
 
	
	// BEGIN: Changed 22.11.1998 CS - Hinzufügen des Third Linker Members

	/* Build and Write Third Linker Member */

	libModSiz= thdLnkMmbStrTab-> GetLength();

	if (BytesTillAlignEnd(libModSiz, sizeof(WORD)))
		libModSiz++;

 memset(&libFilHdr.siz, 0x20, 0x0A);
	
 if (libModSiz == 0)
		libFilHdr.siz[0]= (BYTE )(0x30);
	else
	{

		libModSizInd= 0;
	
		while (libModSiz)
		{
		 lModSiz[libModSizInd++]= (BYTE )(libModSiz - 10 * (libModSiz / 10));
		 libModSiz= libModSiz/10;
		}

		secLibModSizInd= 0;

		while (libModSizInd)
			libFilHdr.siz[secLibModSizInd++]= (BYTE )(0x30 + lModSiz[--libModSizInd]);
	}
	
	memset(archFilNam, 0x20, 0x20);
	memset(archFilNam, 0x2F, 0x02);
	
	dllLibFilRawDat-> Write(archFilNam, 16);
 dllLibFilRawDat-> Write(&libFilHdr, LIB_FIL_HDR_SIZ);

	if (thdLnkMmbStrTab-> GetLength())
	{
		thdLnkMmbStrTab-> SeekToBegin();
		datBuf= (BYTE *)thdLnkMmbStrTab-> ReadWithoutMemcpy(thdLnkMmbStrTab-> GetLength());
		dllLibFilRawDat-> Write(datBuf, thdLnkMmbStrTab-> GetLength());

		if (BytesTillAlignEnd(dllLibFilRawDat-> GetLength(), sizeof(WORD)))
			dllLibFilRawDat-> Write(&chrBuf00, sizeof(BYTE)); 
	}
 
	// END: Changed 22.11.1998 CS

	
 /* Write Library Modules */

 modsRawDat-> SeekToBegin();
 datBuf= (BYTE *)modsRawDat-> ReadWithoutMemcpy(modsRawDat-> GetLength());
 dllLibFilRawDat-> Write(datBuf, modsRawDat-> GetLength());
 
 dllLibFilRawDat-> SeekToBegin();
 datBuf= (BYTE *)dllLibFilRawDat-> ReadWithoutMemcpy(dllLibFilRawDat-> GetLength());

	if(!dllLibFil.Open(dllLibFilNam, CFile::modeCreate | CFile::modeWrite | CFile::typeBinary, pErr))
		WriteMessageToPow(WRN_MSGC_BLD_IMP_LIB, (char *)dllLibFilNam, NULL);
	else
	{
	 dllLibFil.Write(datBuf,dllLibFilRawDat-> GetLength());
	 dllLibFil.Close();
		dllLibFil.~CFile();
	}

	secLnkExpLstPtr= (myExportRecord *)secLnkExpLst;

	while(secLnkExpLstPtr-> expSymNam)
	{
		free(secLnkExpLstPtr-> expSymNam);
		secLnkExpLstPtr++;
	} 

	FreeCMyPtrList(secLnkSrtHlpLst);
	delete secLnkSrtHlpLst;
	FreeCMyMemFile(fstLnkMmbStrTab);
	delete fstLnkMmbStrTab;
	FreeCMyMemFile(secLnkMmbStrTab);
	delete secLnkMmbStrTab;
	FreeCMyMemFile(modsRawDat);
	delete modsRawDat;
	FreeCMyMemFile(dllLibFilRawDat);
	delete dllLibFilRawDat;
	
	free(fstLnkMmb);
	free(secLnkMmb);
	free(secLnkExpLst);

	return TRUE; 
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileExportSection::WriteExpSecToFile()
{	
	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\nAusgabe der Daten der %s Section in Hex Darstellung:\n", ".edata");
	fclose(logFil);

	WriteRawDataToFile(secRawDat);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileRsrcSection::CExeFileRsrcSection() : CSection()
{
	hdrResFilEnt= NULL;
	resTypMap= NULL;
 resTypStrMap= NULL;
	resEntNum= 0;
	aln= 1;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileRsrcSection::CExeFileRsrcSection(char *aSecNam, WORD sNum) : CSection(aSecNam, sNum)
{
	hdrResFilEnt= NULL;
	resTypMap= NULL;
 resTypStrMap= NULL;
	resEntNum= 0;
	aln= sizeof(DWORD);
 actSecTab= (mySectionTable *) malloc(sizeof(mySectionTable));
 memset(actSecTab, 0, sizeof(mySectionTable));
 memcpy(actSecTab-> secNam, secNam, strlen(secNam));
	actSecTab-> chr= 0x40000040;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileRsrcSection::~CExeFileRsrcSection()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileRsrcSection::FreeUsedMemory()
{
	CSection::FreeUsedMemory();
	if (hdrResFilEnt)
	{
	 FreeCResFileEntry(hdrResFilEnt);
		delete hdrResFilEnt;
		hdrResFilEnt=NULL;
	}
	if (resTypMap)
	{
	 FreeCMapWordToOb(resTypMap);
		delete resTypMap;
		resTypMap= NULL;
	}
	if (resTypStrMap)
	{
	 FreeCMyMapStringToOb(resTypStrMap);
		delete resTypStrMap;
		resTypStrMap= NULL;
	}
	resEntNum= 0;
	aln= 0;
}

/**************************************************************************************************/
/*** Einlesen und Aufarbeiten der Daten der .RES Datei in der die Ressourcendaten stehen								***/
/**************************************************************************************************/

BOOL CExeFileRsrcSection::ReadResFile(const char *pszResFilNam)
{	
	CFileException	*pErr= NULL;
	CResFileEntry		*aResFilEnt;
	CMyObList								*resTypEntLst;
	CBuffFile						  *actResFil;
	CMyMemFile							*actResMemFil;

	DWORD	filLen;
	DWORD actResFilSiz;
	BYTE		*actResFilBuf;
 char		*uCStrBuf= NULL;
	
	actResFil= new CBuffFile();

	if (!actResFil-> Open(pszResFilNam, CFile::modeRead | CFile::typeBinary, pErr))
	{
		WriteMessageToPow(ERR_MSGC_OPN_RES, (char *)pszResFilNam, NULL);
		return FALSE;
	}
	else
		WriteMessageToPow(INF_MSG_FIL_OPE_SUC, (char *)pszResFilNam, NULL);

	actResFilSiz= actResFil-> GetLength();
	actResFilBuf= new BYTE[actResFilSiz + 1];
	actResFil-> ReadHuge(actResFilBuf, actResFilSiz);
	actResFil-> Close();
	actResFil-> ~CBuffFile();
	delete actResFil;

	actResMemFil= new CMyMemFile();
	actResMemFil-> WriteHuge(actResFilBuf, actResFilSiz);
	actResMemFil-> SeekToBegin();
	delete[] actResFilBuf;
	
	hdrResFilEnt= new CResFileEntry();
	hdrResFilEnt-> ReadResFileEntry(actResMemFil);

	if (hdrResFilEnt-> resAddHdr1.hdrSiz == 0x20)
	{
		filLen= actResMemFil-> GetLength();
		resTypMap= new CMapWordToOb();
		resTypStrMap= new CMyMapStringToOb();
		
		while(actResMemFil-> GetPosition() < filLen - 0x20)
		{
			aResFilEnt= new CResFileEntry();
			aResFilEnt-> ReadResFileEntry(actResMemFil);

			if (aResFilEnt-> typIdtId.typ != 0x11)
			{

				// Typ Eintrag durch einen String oder durch einen Id ?
   
				if (!aResFilEnt-> typIdtUCStr)
				{
					if (!resTypMap-> Lookup(aResFilEnt-> typIdtId.typ, (CObject *&)resTypEntLst))
					{
			 			resTypEntLst= new CMyObList(10);
			 			resTypMap-> SetAt(aResFilEnt-> typIdtId.typ, resTypEntLst);
					}
				}
				else
				{
					// Umwandeln des Unicode String in einen normalen
   
					uCStrBuf= (char *) malloc(aResFilEnt-> typIdtUCStr-> idtUCStrLen/0x2);					
	  			wcstombs(uCStrBuf, aResFilEnt-> typIdtUCStr-> idtUCStr, aResFilEnt-> typIdtUCStr-> idtUCStrLen/0x2); 
					uCStrBuf[aResFilEnt-> typIdtUCStr-> idtUCStrLen/0x2]= '\0';

					if (!resTypStrMap-> Lookup(uCStrBuf, (CObject *&)resTypEntLst))    
					{
						resTypEntLst= new CMyObList(10);
						resTypStrMap-> SetAt(uCStrBuf, resTypEntLst);
					}
				}

				resTypEntLst-> AddTail(aResFilEnt);
				resEntNum++;
			}				
		}
	}
	else
	{
		WriteMessageToPow(ERR_MSGC_OPN_RES, (char *)pszResFilNam, NULL);
	
		FreeCMyMemFile(actResMemFil);
		delete actResMemFil;
	
		return FALSE;
	}

	FreeCMyMemFile(actResMemFil);
	delete actResMemFil;
	
	return TRUE;
}

/**************************************************************************************************/
/*** Erstellen der .RSRC Sektion der PE-Datei																																																			***/
/**************************************************************************************************/

int CExeFileRsrcSection::BuildResSecRawData()
{
	CResUniCodeString	*aUCString;
	CResFileEntry					*actResFilEnt;
	CMyMapStringToOb		*uCStrMap;
	CMyPtrList        *resTypPtrLst;
	CMyObList									*resTypEntLst;
 
	POSITION	entPosPtrLst;
 POSITION	entPos;
				
	DWORD	nxtDirAdr;
	DWORD	nxtResDirStrAdr;
	DWORD	fstResRawDatEntAdr;
	DWORD	nxtResRawDatEntAdr;
	DWORD	dWrdBuf;
	DWORD	actFilPos;
	DWORD	resDirTabPos;
	DWORD	resRawDatBufLen;
	DWORD	uniCodStrLen;
	WORD  actResTyp;
	WORD		resDirEntNum;
	WORD		namEntNum;
	WORD		idEntNum;
	BYTE		*resRawDatBuf;
	char		*uCStrBuf= NULL;

	myResourceDirectoryTable	actDirTab;

	if (!ReadResFile(resFilNam))
		return FALSE;

	actDirTab.chr= 0x0;
	actDirTab.timDatStp= CalcTimeDateStamp();
	actDirTab.majVer= 0x0;
	actDirTab.minVer= 0x0;

	secRawDat= new CMyMemFile();
		
	actDirTab.namEntNum= (WORD )resTypStrMap-> GetCount();
	actDirTab.idEntNum= (WORD )resTypMap-> GetCount();
 resDirEntNum= (WORD )(actDirTab.namEntNum + actDirTab.idEntNum);
 secRawDat-> Write(&actDirTab, sizeof(myResourceDirectoryTable));

	nxtDirAdr= 0x10 + resDirEntNum * 0x8;
	nxtResDirStrAdr= 0x10 + resDirEntNum * (0x8 + 0x10) +	resEntNum * (0x10 + 0x10 + 0x10);
	
	// Erstellen der Typ Information

 resTypPtrLst= new CMyPtrList();
	uCStrMap= new CMyMapStringToOb();

 entPos= resTypStrMap-> GetStartPosition();

 while (entPos)
	{
 	resTypStrMap-> GetNextAssoc(entPos, uCStrBuf, (CObject *&)resTypEntLst);
  resTypPtrLst-> AddTail(resTypEntLst);
		
  dWrdBuf= 0x80000000 + nxtResDirStrAdr;
		secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
		dWrdBuf= 0x80000000 + nxtDirAdr;
		secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
		nxtDirAdr+= 0x10 + resTypEntLst-> GetCount() * 0x8;
		
  actResFilEnt= (CResFileEntry *)resTypEntLst-> GetHead();
  
  actResFilEnt-> typIdtUCStr-> uCResAdr= nxtResDirStrAdr;
		uCStrMap-> SetAt(uCStrBuf, actResFilEnt-> typIdtUCStr);
		uniCodStrLen= actResFilEnt-> typIdtUCStr-> idtUCStrLen / 0x02 - 0x01;
  actFilPos= secRawDat-> GetPosition();
		secRawDat-> Seek(nxtResDirStrAdr, CFile::begin);
		secRawDat-> Write(&uniCodStrLen, 0x02);
		secRawDat-> Write(actResFilEnt-> typIdtUCStr-> idtUCStr, actResFilEnt-> typIdtUCStr-> idtUCStrLen);
		secRawDat-> Seek(actFilPos, CFile::begin);
		nxtResDirStrAdr+= actResFilEnt-> typIdtUCStr-> idtUCStrLen;			 						
 }
		
	
 // Erstellen der typ Information	
 // Durchgehen aller möglicher Restypen, ermitteln der Anzahl

 actResTyp= 0x0001;

	while (actResTyp <= HIGH_RES_TYP_NUM)
	{
		if (resTypMap-> Lookup(actResTyp, (CObject *&)resTypEntLst))
		{
			resTypPtrLst-> AddTail(resTypEntLst);
			secRawDat-> Write(&actResTyp, sizeof(WORD));
			secRawDat-> Write(chrBuf00, sizeof(WORD));
			dWrdBuf= 0x80000000 + nxtDirAdr;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			nxtDirAdr+= 0x10 + resTypEntLst-> GetCount() * 0x8;
		}
		actResTyp++;
	}

	// Erstellen der Nam Information

	entPosPtrLst= resTypPtrLst-> GetHeadPosition();

 while (entPosPtrLst)
	{
		resTypEntLst= (CMyObList *)resTypPtrLst-> GetNext(entPosPtrLst);
		namEntNum= 0;
		idEntNum= 0;
		resDirTabPos= secRawDat-> GetPosition();
		secRawDat-> Seek(resDirTabPos + 0x10, CFile::begin);
		entPos= resTypEntLst-> GetHeadPosition();
	
		while(entPos)
		{
			actResFilEnt= (CResFileEntry *)resTypEntLst-> GetNext(entPos);
			if (actResFilEnt-> namIdtId.chr == 0xFFFF)
   {
					dWrdBuf= (DWORD)actResFilEnt-> namIdtId.nam;
     idEntNum++;
   }
			else
			{
				// Umwandeln des UniCodeStrings in einen normalen String

				uCStrBuf= (char *) malloc(actResFilEnt-> namIdtUCStr-> idtUCStrLen/0x2 * 2);
				
				wcstombs(uCStrBuf, actResFilEnt-> namIdtUCStr-> idtUCStr, actResFilEnt-> namIdtUCStr-> idtUCStrLen/0x2); 
				uCStrBuf[actResFilEnt-> namIdtUCStr-> idtUCStrLen/0x2]= '\0';
				if (uCStrMap-> Lookup(uCStrBuf, (CObject *&)aUCString))
					dWrdBuf= 0x80000000 + aUCString-> uCResAdr;
				else
				{
					dWrdBuf= 0x80000000 + nxtResDirStrAdr;
					actResFilEnt-> namIdtUCStr-> uCResAdr= nxtResDirStrAdr;
					uCStrMap-> SetAt(uCStrBuf, actResFilEnt-> namIdtUCStr);
					actFilPos= secRawDat-> GetPosition();
					secRawDat-> Seek(nxtResDirStrAdr, CFile::begin);
					uniCodStrLen= actResFilEnt-> namIdtUCStr-> idtUCStrLen / 0x02 - 0x01;
					secRawDat-> Write(&uniCodStrLen, 0x02);
					secRawDat-> Write(actResFilEnt-> namIdtUCStr-> idtUCStr, actResFilEnt-> namIdtUCStr-> idtUCStrLen);
					secRawDat-> Seek(actFilPos, CFile::begin);
					nxtResDirStrAdr+= actResFilEnt-> namIdtUCStr-> idtUCStrLen;			 						
				}
								
				free(uCStrBuf);
    namEntNum++;
			}
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			dWrdBuf= 0x80000000 + nxtDirAdr;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			nxtDirAdr+= 0x18;
		}
		actDirTab.namEntNum= namEntNum;
		actDirTab.idEntNum= idEntNum;
		actFilPos= secRawDat-> GetPosition();
		secRawDat-> Seek(resDirTabPos, CFile::begin);
		secRawDat-> Write(&actDirTab, sizeof(myResourceDirectoryTable));		
		secRawDat-> Seek(actFilPos, CFile::begin);
	}		

	uCStrMap-> ~CMyMapStringToOb();
	delete uCStrMap;
	
	// Erstellen der Language Information

	entPosPtrLst= resTypPtrLst-> GetHeadPosition();

 while (entPosPtrLst)
	{
		resTypEntLst= (CMyObList *)resTypPtrLst-> GetNext(entPosPtrLst);
		entPos= resTypEntLst-> GetHeadPosition();	
		while(entPos)
		{
			actResFilEnt= (CResFileEntry *)resTypEntLst-> GetNext(entPos);
			actDirTab.namEntNum= 0x0;
			actDirTab.idEntNum= 0x1;
			secRawDat-> Write(&actDirTab, sizeof(myResourceDirectoryTable));		
			dWrdBuf= (DWORD)actResFilEnt-> resAddHdr2.lngId;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			dWrdBuf= nxtDirAdr;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			nxtDirAdr+= 0x10;	
		}	
	}
						

	// Einfügen der Resource Directory Tables
	
	nxtResRawDatEntAdr= fstResRawDatEntAdr= 0x08 * (nxtResDirStrAdr / 0x08) + 0x08;
	
	entPosPtrLst= resTypPtrLst-> GetHeadPosition();

 while (entPosPtrLst)
	{
  resTypEntLst= (CMyObList *)resTypPtrLst-> GetNext(entPosPtrLst);
		entPos= resTypEntLst-> GetHeadPosition();	
		while(entPos)
		{
			actResFilEnt= (CResFileEntry *)resTypEntLst-> GetNext(entPos);
			dWrdBuf= nxtResRawDatEntAdr + actSecTab-> rVAdrPtr;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			dWrdBuf= (DWORD)actResFilEnt-> resAddHdr1.datSiz;
			secRawDat-> Write(&dWrdBuf, sizeof(DWORD));
			nxtResRawDatEntAdr+= dWrdBuf;
			secRawDat-> Write(chrBuf00, 2 * sizeof(DWORD));
			if (BytesTillAlignEnd(nxtResRawDatEntAdr, aln))
				nxtResRawDatEntAdr+= BytesTillAlignEnd(nxtResRawDatEntAdr, aln);					
		}	
	}		

	// Einfügen von Nullen bis zum Beginn der Resourcen Raw Daten
	
	secRawDat-> Seek(nxtResDirStrAdr, CFile::begin);
	actFilPos= nxtResDirStrAdr;
	secRawDat-> Write(chrBuf00, fstResRawDatEntAdr - actFilPos);
	
	// Einfügen der Raw Daten der Resourcen

	entPosPtrLst= resTypPtrLst-> GetHeadPosition();

 while (entPosPtrLst)
	{
  resTypEntLst= (CMyObList *)resTypPtrLst-> GetNext(entPosPtrLst);
		entPos= resTypEntLst-> GetHeadPosition();
		while(entPos)
		{
			actResFilEnt= (CResFileEntry *)resTypEntLst-> GetNext(entPos);
			resRawDatBufLen= (actResFilEnt-> resRawDat)-> GetLength();
			resRawDatBuf= (BYTE *)malloc(resRawDatBufLen);
			actResFilEnt-> resRawDat-> SeekToBegin();
			actResFilEnt-> resRawDat-> Read(resRawDatBuf, resRawDatBufLen);
			secRawDat-> Write(resRawDatBuf, resRawDatBufLen);
			free(resRawDatBuf);
			if (BytesTillAlignEnd(secRawDat-> GetPosition(), aln))
				secRawDat-> Write(chrBuf00, BytesTillAlignEnd(secRawDat-> GetPosition(), aln));
		  FreeCResFileEntry(actResFilEnt);
			delete actResFilEnt;
		}
		FreeCMyObList(resTypEntLst);
		delete resTypEntLst;
		resTypEntLst= NULL;
	}


 FreeCMyPtrList(resTypPtrLst);
 delete resTypPtrLst;

	actSecTab-> virSiz= secRawDat-> GetLength();	
	return actSecTab-> virSiz;
}

/**************************************************************************************************/
/*** Schreiben der .RSRC Sektion in die zu erstellende PE-Datei																																	***/
/**************************************************************************************************/

BOOL CExeFileRsrcSection::GiveSecRawDataBlock(CMyMemFile *exeFilRawDat, WORD fAln)
{
	BYTE *relSecRawDatBuf;

	actSecTab-> rawDatPtr= exeFilRawDat-> GetPosition();
	actSecTab-> rawDatSiz=	fAln * (actSecTab-> virSiz / fAln);

	if (actSecTab-> virSiz != actSecTab-> rawDatSiz)
		actSecTab-> rawDatSiz+=	fAln;		

	secRawDat-> Write(chrBuf00, actSecTab-> rawDatSiz - actSecTab-> virSiz);


	secRawDat-> SeekToBegin();
	relSecRawDatBuf= (BYTE *) secRawDat-> ReadWithoutMemcpy(actSecTab-> rawDatSiz);
	exeFilRawDat-> Write(relSecRawDatBuf, actSecTab-> rawDatSiz);	

	return TRUE;
}

/**************************************************************************************************/
/*** Setzen der virtuellen Sektionsadresse der .RSRC Sektion																																				***/
/**************************************************************************************************/

void CExeFileRsrcSection::SetVirSecAdr(DWORD vSecAdr)
{
	actSecTab-> rVAdrPtr= vSecAdr;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int	CExeFileRsrcSection::WriteResSecRawDataToFile()
{
	WriteRawDataToFile(secRawDat);		
	return 1;
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFileRelocSection::CExeFileRelocSection() : CSection()
{
	relLst= NULL;
	virSecAdr= 0;
	aln= 0;	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CExeFileRelocSection::CExeFileRelocSection(char *aSecNam, WORD sNum) : CSection(aSecNam, sNum)
{
	relLst= new CDWordArray();
	virSecAdr= 0;
	aln= 4;
 actSecTab= (mySectionTable *) malloc(sizeof(mySectionTable));
 memset(actSecTab, 0, sizeof(mySectionTable));
 memcpy(actSecTab-> secNam, secNam, strlen(secNam));
	actSecTab-> chr= 0x42000040;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFileRelocSection::~CExeFileRelocSection()
{
	FreeUsedMemory();	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CExeFileRelocSection::FreeUsedMemory()
{
	CSection::FreeUsedMemory();
	if (relLst)
	{
	 FreeCDWordArray(relLst);
		delete relLst;
		relLst= NULL;
	}
	virSecAdr= 0;
	aln= 0;	
}

/**************************************************************************************************/
/*** Setzen der virtuellen Adresse der .RELOC Sektion																																											***/
/**************************************************************************************************/

void CExeFileRelocSection::SetVirSecAdr(DWORD vSecAdr)
{
	actSecTab-> rVAdrPtr= virSecAdr= vSecAdr;
}

/**************************************************************************************************/
/*** Erstellen der .RELOC Sektion der PE-Datei																																																		***/
/**************************************************************************************************/

BOOL CExeFileRelocSection::BuildRelSec(WORD secAln, WORD filAln)
{
	CMyMemFile *relSec;

	DWORD virBlkAdr;
	DWORD relAdr;
	DWORD	bytInBlk;
	DWORD	virBlkPos;
	DWORD relEntNum;
	DWORD relPosNum;
	DWORD i;
	WORD		relWrtAdr;
	
	relEntNum= relLst-> GetSize();
	relSec= new CMyMemFile();
	relAdr= relLst-> GetAt(0);
	virBlkAdr= secAln * (relAdr / secAln);
	relSec-> Write(&virBlkAdr, sizeof(DWORD));
	relPosNum= relSec-> GetPosition();
	relSec-> Write(&bytInBlk, sizeof(DWORD));

	for(i= 1; i < relEntNum; i++)
	{
		relAdr-= virBlkAdr;
		relWrtAdr= (WORD )(((WORD) relAdr) | 0x3000);
		relSec-> Write(&relWrtAdr, sizeof(WORD));
		relAdr= relLst-> GetAt(i);
		if (relAdr >= virBlkAdr + secAln)
		{
			virBlkPos= relSec-> GetPosition();
			if (BytesTillAlignEnd(virBlkPos, aln))
				relSec-> Write(chrBuf00, sizeof(WORD));
			virBlkPos= relSec-> GetPosition();
			relSec-> Seek(relPosNum, CFile::begin);
			bytInBlk= virBlkPos - relPosNum + sizeof(DWORD);
			relSec-> Write(&bytInBlk, sizeof(DWORD));
			relSec-> Seek(virBlkPos, CFile::begin);
			virBlkAdr= secAln * (relAdr / secAln);
			relSec-> Write(&virBlkAdr, sizeof(DWORD));
			relPosNum= relSec-> GetPosition();
			relSec-> Write(&bytInBlk, sizeof(DWORD));
		}
	}
	relAdr-= virBlkAdr;
	relWrtAdr= (WORD)(relAdr | 0x3000);
	relSec-> Write(&relWrtAdr, sizeof(WORD));

	virBlkPos= relSec-> GetPosition();
	relSec-> Seek(relPosNum, CFile::begin);
	bytInBlk= virBlkPos - relPosNum + sizeof(DWORD);
 if (BytesTillAlignEnd(bytInBlk, aln))
  bytInBlk+= sizeof(WORD);
	relSec-> Write(&bytInBlk, sizeof(DWORD));
	relSec-> Seek(virBlkPos, CFile::begin);

	actSecTab-> virSiz= relSec-> GetPosition();
	// BEGIN: Changed 23.11.1998 CS
	//if (BytesTillAlignEnd(actSecTab-> virSiz, secAln))
	// CHANGED TO
	if (BytesTillAlignEnd(actSecTab-> virSiz, aln))
	// END: Changed 22.11.1998 CS
	 actSecTab-> virSiz+= 2;

	relSec-> Write(chrBuf00, BytesTillAlignEnd(relSec-> GetPosition(), filAln));
	
	secRawDatSiz= relSec-> GetLength();
	secRawDat= relSec;

	return TRUE;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFileRelocSection::WriteRelSecToFile()
{
	logFil= fopen(logFilNam, "a");
	fprintf(logFil, "\nAusgabe der Daten der %s Section in Hex Darstellung:\n", ".reloc");
	fclose(logFil);
	
	WriteRawDataToFile(secRawDat);
}
