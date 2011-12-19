/**************************************************************************************************/
/*** Die Datei LibFile.cpp beinhaltet die Implementierung folgender Klassen:																			 ***/
/***			CLibFile	      																																																																										***/
/**************************************************************************************************/

#include <StdLib.h>
#include <String.h>
#include <Malloc.h>

#ifndef __LIBFILE_HPP__
#include "LibFile.hpp"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __OBJFILE_HPP__
#include "ObjFile.hpp"
#endif           

DWORD GivNum(BYTE *strNum, WORD start, WORD endSgn);
char *GivFilNam(BYTE *buf);

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

extern void FreeCMemFile(CMemFile *aCMemFile);
extern void FreeCMyMemFile(CMyMemFile *aCMyMemFile);

extern	FILE		*logFil;
extern	char		*logFilNam;     
extern BOOL libFilInMem;


IMPLEMENT_DYNAMIC(CLibFile, CObject)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CLibFile::CLibFile()
{
	actLibFil= NULL;
	filNam= NULL;
	pubLibSymLst= NULL;
	pubLibEntBuf= NULL;
	lstAccObjFil= NULL;		
 strDirBuf= NULL;
 libFilInd= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/


CLibFile::~CLibFile()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CLibFile::FreeUsedMemory()
{
 if (filNam)
	{
		free(filNam); 
		filNam= NULL;
 }
	if (actLibFil)
	{
		actLibFil-> ~CBuffFile();	
		delete actLibFil;
		actLibFil= NULL;
	}
	if (pubLibSymLst) 
	{		
		pubLibSymLst-> ~CMyMapStringToPtr();       
		delete pubLibSymLst;
		pubLibSymLst= NULL;
	}
	if (strDirBuf)
 {
  free(strDirBuf);
  strDirBuf= NULL;
 }
 if (pubLibEntBuf)
 {
  free(pubLibEntBuf);
  pubLibEntBuf= NULL;
 }
	memNum= 0;
 symNum= 0;
	lngNamTabOff= 0;
 staLib= TRUE;
}

/**************************************************************************************************/
/*** Anlegen der Listen und Aufruf der Methode zum Laden des Bibliothekverzeichnisses, wenn					***/
/*** Bibliothek ihr eigenes Verzeichnis besitzt.																																																***/
/**************************************************************************************************/

BOOL CLibFile::LoadLibFileFromDiscOwnPubList(const char *pszFilNam)
{
	pubLibSymLst= new CMyMapStringToPtr();
	pubLibSymLst-> InitHashTable(100, TRUE);
	return LoadLibFileFromDisc(pszFilNam, pubLibSymLst);
}

/**************************************************************************************************/
/*** Aufruf der Methode zum Laden des Bibliothekverzeichnisses bei nur einem Verzeichnis für    ***/
/*** alle vorhandenen Bibliotheken.																																																													***/
/**************************************************************************************************/

BOOL CLibFile::LoadLibFileFromDiscComPubList(const char *pszFilNam, CMyMapStringToPtr *&pLibSymLst)
{
	return LoadLibFileFromDisc(pszFilNam, pLibSymLst);
}

/**************************************************************************************************/
/*** Öffnen und Laden der Datei einer Bibliothek und Verarbeiten des Bibliothekverzeichnisses			***/
/**************************************************************************************************/

BOOL CLibFile::LoadLibFileFromDisc(const char *pszFilNam, CMyMapStringToPtr *&pubLibSymLst)
{
	CFileException		 *pErr= NULL;
	myPublicLibEntry	*nxtPubLibEnt;
	
	myLibFileHeader		lngNamHdr;

	DWORD	*symOffLst;
	DWORD	secLnkMemOff;								
	DWORD	lngNamOff;
	DWORD	secLnkMemStart;
	DWORD strDirSiz;
	DWORD libFilSiz;
	WORD		*symIndLst;
	WORD		posCor;
	WORD		i;
	char  *strDirBufInd;

	CBuffFile *libFil;
	BYTE  *libFilBuf;
	
 filNam= GiveLibNameUp(pszFilNam);
	libFil= new CBuffFile();

	if (!libFil-> Open(pszFilNam, CFile::modeRead | CFile::shareExclusive | CFile::typeBinary, pErr))
	{
		WriteMessageToPow(ERR_MSGI_OPN_LIB, (char *)pszFilNam, NULL);
		((CBuffFile *)libFil)-> ~CBuffFile();       
		delete libFil;
		return FALSE;
	}
	else
		WriteMessageToPow(INF_MSG_FIL_OPE_SUC, (char *)pszFilNam, NULL);
																																																																		
	if (libFilInMem)
	{
		libFilSiz= libFil-> GetLength();
		libFilBuf= (BYTE *) malloc(libFilSiz + 1);
		libFil-> ReadHuge(libFilBuf, libFilSiz);
		((CMyMemFile *)libFil)-> SetBufferDirect(libFilBuf, libFilSiz);
		((CBuffFile *)libFil)-> ~CBuffFile();       
		delete libFil;
	}
	else
		actLibFil= libFil;

	actLibFil-> SeekToBegin();
	actLibFil-> Read(libFilSig, 8);
	actLibFil-> Read(&achMemNam, 16);

	// Untersuchen, ob wirklich 16 Byte für den ArchivMembernamen im Header reserviert sind 
	// Enthält das 16. Byte den Wert '20', so trifft dies zu. Sonst beginnt der nächste Eintrag 
	// schon um x-Byte früher.

	posCor= 0;

	while(achMemNam[15 - posCor] != 32) 
		posCor++;

	actLibFil-> Seek(actLibFil-> GetPosition() - posCor, CFile::begin);
	actLibFil-> Read(&actLibFilHdr, 44);

	secLnkMemOff= GivNum(actLibFilHdr.siz, 0, 0x20);

	strDirSiz= 0;
	strDirSiz-= actLibFil-> GetPosition();
	actLibFil-> Seek(actLibFil-> GetPosition() + secLnkMemOff + 1, CFile::begin);
	actLibFil-> Read(&secLnkMemNam, 16);

	// Untersuchen, ob wirklich 16 Byte für den ArchivMemernamen im Header reserviert sind 
	// Enthält das 16. Byte den Wert '20', so trifft dies zu. Sonst beginnt der nächste Eintrag 
	// schon auf um 8 Byte früher.

	posCor= 0;

	while(secLnkMemNam[15 - posCor] != 32)
		posCor++;

	actLibFil-> Seek(actLibFil-> GetPosition() - posCor, CFile::begin);	
	actLibFil-> Read(&secLnkMemHdr, 44);

	secLnkMemStart= actLibFil-> GetPosition();

	actLibFil-> Read(&memNum, sizeof(DWORD));
	symOffLst= (DWORD *) malloc(memNum * sizeof(DWORD));
	actLibFil-> Read(symOffLst, memNum * sizeof(DWORD));
	
	actLibFil-> Read(&symNum, sizeof(DWORD));
	symIndLst= (WORD *) malloc(symNum * sizeof(WORD));
	actLibFil-> Read(symIndLst, symNum * sizeof(WORD));

 strDirSiz= secLnkMemOff - (symNum + 1) * sizeof(DWORD);
	strDirBuf= (BYTE *) malloc(strDirSiz + 4);
 actLibFil-> Read(strDirBuf, strDirSiz);

 pubLibEntBuf= (BYTE *) malloc (sizeof(myPublicLibEntry) * strDirSiz);
 nxtPubLibEnt= (myPublicLibEntry *) pubLibEntBuf;

	strDirBufInd= (char *)strDirBuf;

 for(i= 0; i < symNum; i++)
	{
  nxtPubLibEnt-> achMemSym= strDirBufInd;
  nxtPubLibEnt-> achMemOff= symOffLst[symIndLst[i] - 1];
  nxtPubLibEnt-> myLibFil= this;
		pubLibSymLst-> SetAt(strDirBufInd, nxtPubLibEnt);
  nxtPubLibEnt++;

		while(*strDirBufInd++ != '\0');
	}			

 // Ist es eine statische oder eine Importlibrary
 // Annahme: NULL_IMPORT_DESCRIPTOR sollte vorkommen, dann 
 // handelt es sich um eine Importlibrary, sonst um eine statische.
 
 if (pubLibSymLst-> Lookup("NULL_IMPORT_DESCRIPTOR", (void *&)nxtPubLibEnt))
  if (nxtPubLibEnt-> myLibFil == this)
   staLib= FALSE;

	/* strDirBuf darf hier nicht gelöscht werden, da CMyMapStringToOb den Speicherbereich */
 /* direkt für die HashStrings benützt, freigeben erst nachdem alle Symbole aufgelöst  */
 /* wurden.                                                                            */    
	  
	free(symIndLst);
	free(symOffLst);

	lngNamOff= GivNum(secLnkMemHdr.siz, 0, 0x20) + secLnkMemStart + 1;
	actLibFil-> Seek(lngNamOff, CFile::begin);
	actLibFil-> Read(&secLnkMemNam, 16);

	// Untersuchen, ob wirklich 16 Byte für den ArchivMemernamen im Header reserviert sind 
	// Enthält das 16. Byte den Wert '20', so trifft dies zu. Sonst beginnt der nächste Eintrag 
	// schon auf um 8 Byte früher.

	posCor= 0;

	while(secLnkMemNam[15 - posCor] != 32)
		posCor++;

	actLibFil-> Seek(actLibFil-> GetPosition() - posCor, CFile::begin);	
	actLibFil-> Read(&lngNamHdr, 44);
	lngNamTabOff= actLibFil-> GetPosition();

	return TRUE;
}

/**************************************************************************************************/
/*** Auslesen der Daten eines Objektmoduls aus einer Bibliothek bei bekanntem Dateioffset							***/
/**************************************************************************************************/

CMyMemFile	*CLibFile::ReadLibObjFile(DWORD achMemOff)
{
	myLibFileHeader 	objFilHdr;
 CMyMemFile					  *objFil;

	DWORD strTabOff;
	DWORD	sekPos;
	DWORD	objFilOff;
	DWORD	objFilSiz;
	BYTE		achMemNam[16];
	
 BYTE		*objFilBuf;
	
	/*  Symbol in Library gefunden - Object Module wird geladen  */

 objFilOff= achMemOff;

	/* Laden des Objectfiles */

	actLibFil-> Seek(objFilOff, CFile::begin);
	actLibFil-> Read(&achMemNam, 16);

	// Untersuchen, ob wirklich 16 Byte für den Archivmembernamen im Header reserviert sind 
	// Enthält das 16. Byte den Wert '20', so trifft dies zu. Sonst beginnt der nächste Eintrag 
	// schon auf um 8 Byte früher.

	if ((achMemNam[15] != 0x20) && (achMemNam[8] > 0x39) && (achMemNam[8] < 0x30))	
		actLibFil-> Seek(actLibFil-> GetPosition() - 8, CFile::begin);

	// Auswerten des Archivnamens


	if ((47 < achMemNam[1]) && (achMemNam[1] < 58))
	{
		sekPos= actLibFil-> GetPosition();
		strTabOff= GivNum(achMemNam, 1, 0x20) + lngNamTabOff;
		actLibFil-> Seek(strTabOff, CFile::begin);
		lstAccObjFil= (char *) malloc(50);
		actLibFil-> Read(lstAccObjFil, 50);
		actLibFil-> Seek(sekPos, CFile::begin);
 }
	else
	{
		lstAccObjFil=  (char *) malloc(strlen(GivFilNam(achMemNam)) + 1);
		strcpy(lstAccObjFil, (char *)achMemNam);		
	}
	
	actLibFil-> Read(&objFilHdr, LIB_FIL_HDR_SIZ);
 
	objFilSiz= GivNum(objFilHdr.siz, 0, 0x20);
	objFil= new CMyMemFile();
	objFilBuf= (BYTE *) malloc(objFilSiz);
	actLibFil-> Read(objFilBuf, objFilSiz);
 ((CMyMemFile *)objFil)-> SetBufferDirect(objFilBuf, objFilSiz);
	
	return objFil;  
}

/**************************************************************************************************/
/*** Umwandeln des Bibliotheknamens in ein später benötigtes Format. Großbuchstaben ohne ".LIB" ***/
/**************************************************************************************************/

char *CLibFile::GiveLibNameUp(const char *pszFilNam)
{             
	char *namStart;
	char *fulNam;
	char *retNam;
     
	fulNam= (char *) malloc(20);
	_strnset(fulNam, '\0', 9);
	namStart= strrchr(pszFilNam, 92);
	namStart= namStart++;
	fulNam= strcpy(fulNam, namStart);
	fulNam= _strupr(fulNam);
	retNam= (char *) malloc(strlen(fulNam) - 3);
	retNam= strncpy(retNam, fulNam, strlen(fulNam) - 4);
	retNam[strlen(fulNam) - 4]= '\0';
	free(fulNam);
	return retNam;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CLibFile::WritePubLibEntToFile()
{							
	myPublicLibEntry *actEnt;
	LPCTSTR									actSym;
	POSITION 							mapPos;	
	
 logFil = fopen(logFilNam,"a");
	
	mapPos= pubLibSymLst-> GetStartPosition();

	while(mapPos)
	{
		pubLibSymLst-> GetNextAssoc(mapPos, actSym, (void *&)actEnt);
		fprintf(logFil, "\n%08x     %50s", actEnt-> achMemOff, actSym);
	}																																
			
	fclose(logFil);
}

/**************************************************************************************************/
/*** Methode zum Schließen der Bibliothek																																																							***/
/**************************************************************************************************/

void CLibFile::Close()
{
	actLibFil-> Close();
}

/**************************************************************************************************/
/*** Umwandeln einer Zahl, die als ASCII-Zeichenkette vorliegt, in ein DWORD		0x49 0x50 => 12			***/
/**************************************************************************************************/

DWORD GivNum(BYTE *strNum, WORD start, WORD endSgn)
{
	DWORD num;
	int  	i= start + 1;

	num= strNum[start] - 48;
	while(strNum[i] != endSgn)
			num= 10 * num + strNum[i++] - 48;
	return num;
}

/**************************************************************************************************/
/*** Ermitteln und Rückgabe des Dateinamens, wie er im Libraryheader gespeichert ist.											***/
/**************************************************************************************************/

char *GivFilNam(BYTE *buf)
{
		char *filNam;
		int		i= 0;

		while((buf[i] != 0x2f) && ( i++ < 16));
		filNam= (char *)buf;
		filNam[i]= 0x0;
		return filNam;
}


		



