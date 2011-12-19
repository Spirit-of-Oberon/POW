/**************************************************************************************************/
/*** Die Datei ObjFile.cpp beinhaltet die Implementierung folgender Klassen:																			 ***/
/***			CCObjFile      																																																																										***/
/**************************************************************************************************/

#ifndef __STDLIB_H__
#include <stdlib.h>
#endif

#ifndef __STRING_H__
#include <string.h>
#endif

#ifndef	__OBJFILE_HPP__
#include "ObjFile.hpp"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

#ifndef __PUBLIBEN_HPP__
#include "PubLibEn.hpp"
#endif

extern	FILE		*logFil;
extern	char		*logFilNam;     
extern 	int			logOn;   

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

extern void FreeCObjFileSection(CObjFileSection *aCObjFileSection);
extern void FreeCSymbolEntry(CSymbolEntry *aCSymbolEntry);
extern void FreeCDllExportEntry(CDllExportEntry *aCDllExportEntry);
extern void FreeCMapStringToOb(CMapStringToOb *aCMapStringToOb);
extern void FreeCObList(CObList *aCObList);
extern void FreeCObArray(CObArray *aCObArray);
extern void FreeCMemFile(CMemFile *aCMemFile);
extern void FreeCMyMemFile(CMyMemFile *aCMyMemFile);
extern void FreeCMyPtrList(CMyPtrList *aCMyPtrList);


IMPLEMENT_DYNAMIC(CObjFile, CObject)

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CObjFile::CObjFile()
{
	objFilBuf= NULL;
	srcFilNam= NULL;
	objFilNam= NULL;																								
	libFilNam= NULL;
	incDllFun= FALSE;
	libObjFil= TRUE;
	insSstFilInd= TRUE;
	linNmbInc= FALSE;
	incExpEnt= NULL;
	secLstLst= NULL;
	secLst= NULL;
	newSymLst= NULL;
	ftrExeFil= NULL;
 objMemFil= NULL;
	dbgTSec= NULL;
	freSymNamLst= NULL;
	gloPubSymLst= NULL;
 symEntBuf= NULL;
	sstGloTypRawDat= NULL;
 libFilInd= 0;
	cvModInd= 0xFFFF;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CObjFile::~CObjFile()
{
	FreeUsedMemory();	
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CObjFile::FreeUsedMemory()
{
	CObjFileSection *delSecEnt;

	char	*symNam;
	int		entInLst;
	int		i;

	if (objFilBuf)
	{
		free(objFilBuf);
		objFilBuf= NULL;
	}
	if (srcFilNam)
	{
		free(srcFilNam);
		srcFilNam= NULL;
	}
	if (objFilNam)
	{
		free(objFilNam);
		objFilNam= NULL;
	}
	if (secLstLst)
	{
		FreeCMapStringToOb(secLstLst);
		delete secLstLst;
		secLstLst= NULL;
	}
	if (secLst)
	{
		entInLst= secLst-> GetUpperBound();
		for(i= 0; i <= entInLst; i++)
		{
			delSecEnt= (CObjFileSection *)secLst-> GetAt(i);
			if (delSecEnt)
			{
				FreeCObjFileSection(delSecEnt);
				delete delSecEnt;
			}
		}
		secLst-> ~CMyObArray();
		delete secLst;
		secLst= NULL;
	}
 if (newSymLst)
 { 
  free(newSymLst);
  newSymLst= NULL;
 }
 if (symEntBuf)
 {
  free(symEntBuf);
  symEntBuf= NULL;
 }
 if (objMemFil)
 {
  FreeCMyMemFile(objMemFil);
  delete objMemFil;
  objMemFil= NULL;
 }
	if (libFilNam)
	{
		free(libFilNam);
		libFilNam= NULL;
	}
	if	(freSymNamLst)
	{
		while(!freSymNamLst-> IsEmpty())
		{
			symNam= (char *)freSymNamLst-> RemoveHead();
			free(symNam);
		}
		FreeCMyPtrList(freSymNamLst);
		delete freSymNamLst;
		freSymNamLst= NULL;
	}
	if (gloPubSymLst)
	{
		FreeCMyPtrList(gloPubSymLst);
		delete gloPubSymLst;
		gloPubSymLst= NULL;
	}
 if (symEntBuf)
 {
  free(symEntBuf);  
  symEntBuf= NULL;
 }
	if (sstGloTypRawDat)
	{
		sstGloTypRawDat-> ~CMyMemFile();
		delete sstGloTypRawDat;
		sstGloTypRawDat= NULL;
	}
	dbgTSec= NULL;
 incExpEnt= NULL;
}

/******************************************************************************************************/
/*** Einlesen einer Objektdatei und Aufruf der Methode zum Analysieren derselben																				***/
/******************************************************************************************************/

BOOL CObjFile::LoadObjFileFromDisc(const char *pszFilNam, CMyPtrList *unResSymLst, CMyMapStringToPtr *pubSymLst)
{
	CFileException *pErr= NULL;
	CBuffFile 		  		objFil;
	CMyMemFile						*objMemFil;
		
	DWORD	objFilSiz;
	BOOL		lnkOK= TRUE;
				
	objFilNam= (char *) malloc(strlen(pszFilNam) + 1);
	objFilNam= strcpy(objFilNam, (char *)pszFilNam);
	                                                                             
	if (!objFil.Open(pszFilNam, CStdioFile::modeRead | CStdioFile::typeBinary, pErr))
	{
		WriteMessageToPow(ERR_MSGI_OPN_OBJ, (char *)pszFilNam, NULL);
		return FALSE;
	}
	else
		WriteMessageToPow(INF_MSG_FIL_OPE_SUC, (char *)pszFilNam, NULL);
		
	objFilSiz= objFil.GetLength();
	objFilBuf= (BYTE *) malloc(objFilSiz + 1);
	objFil.ReadHuge(objFilBuf, objFilSiz);
	objFil.Close();
	objMemFil= new CMyMemFile();
 objMemFil-> SetBufferDirect(objFilBuf, objFilSiz);
	lnkOK= AnalObjFileData(objMemFil, unResSymLst, pubSymLst);
 objMemFil-> ~CMyMemFile(); 
 delete objMemFil;
 objMemFil= NULL;

	return lnkOK;
}                                                                              

/******************************************************************************************************/
/*** Analysieren einer Objektdatei. Verarbeiten des Headers, der Sektionstabelle, der Sektions-			  ***/
/***	(Rohdaten, Relokationen und Zeilennummern), sowie Aufarbeiten der Symboltabelle.															***/
/******************************************************************************************************/

BOOL CObjFile::AnalObjFileData(CMyMemFile *aMemFil, CMyPtrList *unResSymLst, CMyMapStringToPtr *pubSymLst)
{
	CSectionFragmentEntry		*newSecFrg;
	CObjFileSection								*newSec;
	CObjFileSection								*txtSec;
	mySymbolEntry										*nxtSymEnt;
		
	DWORD	actFilSekPos;
	DWORD	actSymInd;
	DWORD	strTabPtr;
	WORD		i;													
	BOOL		lnkOK= TRUE;
	
	// Initialising Coff Hdr

	aMemFil-> SeekToBegin();
 aMemFil-> Read(&objCofHdr, COF_HDR_SIZ);

	if (objCofHdr.mach != IMAGE_FILE_MACHINE_I386)
	{
		WriteMessageToPow(ERR_MSGIS_WRG_MAC, objFilNam, NULL);
		return FALSE;
	}
 
	// Liste der Sektionen wird erstellt

	secLstLst= new CMyMapStringToOb(objCofHdr.secNum);
 secLstLst-> InitHashTable(objCofHdr.secNum, TRUE); 
 secLst= new CMyObArray();
	secLst-> SetSize(objCofHdr.secNum, 1);

 if (objCofHdr.optHdrSiz)
  aMemFil-> Seek(objCofHdr.optHdrSiz, CFile::current);

 actFilSekPos= (WORD ) aMemFil-> GetPosition();

	for(i= 0; i < objCofHdr.secNum; i++)
	{
		newSec= new CObjFileSection();
		lnkOK= newSec-> ReadSecData(aMemFil, actFilSekPos, this);
		secLstLst-> SetAt(newSec-> secNam, newSec);
		secLst-> SetAt(i, newSec);
		actFilSekPos+= SEC_HDR_SIZ;
 }

	if (!lnkOK) 
		return lnkOK;

 if ((secLstLst-> Lookup(".idata$2", (CObject *&)newSec)) || 
					(secLstLst-> Lookup(".idata$3", (CObject *&)newSec)) ||    
					(secLstLst-> Lookup(".idata$5", (CObject *&)newSec)))
  incDllFun= TRUE;
 else
  incDllFun= FALSE;

 if (!incDllFun)										  
 {
  for(i= 0; i < objCofHdr.secNum; i++)
	 {
	 	newSec= (CObjFileSection *)secLst-> GetAt(i);
   if (newSec-> actSecTab-> rawDatSiz) 
    lnkOK= newSec-> WrapFromObj2Exe(this, ftrExeFil);  
	 }
		if (!lnkOK)
			return lnkOK;
	}

	// Einlesen der Symboltabelle
 
 strTabPtr= objCofHdr.symTabPtr + objCofHdr.symNum * SYM_TAB_LEN;

	if (ftrExeFil-> includeDebugInfo)
		gloPubSymLst= new CMyPtrList(objCofHdr.symNum);

	actSymInd= 0;
	aMemFil-> Seek(objCofHdr.symTabPtr, CFile::begin);

 DWORD symEntSiz= sizeof(mySymbolEntry);
 symEntBuf= (BYTE *) malloc (symEntSiz * objCofHdr.symNum);
 memset(symEntBuf, 0, symEntSiz * objCofHdr.symNum);
 newSymLst= (mySymbolEntry **) malloc (sizeof(mySymbolEntry*) * objCofHdr.symNum);
 memset(newSymLst, 0, sizeof(mySymbolEntry*) * objCofHdr.symNum);
 nxtSymEnt= (mySymbolEntry *)symEntBuf;
	
	while(actSymInd < objCofHdr.symNum)
	{
  newSymLst[actSymInd]= (mySymbolEntry *)nxtSymEnt;
  actSymInd+= ReadSymEntData(nxtSymEnt, aMemFil, strTabPtr, this, unResSymLst, pubSymLst);		
		nxtSymEnt= (mySymbolEntry *)symEntBuf + actSymInd;
	}	

 // Überpüfen ob Dll Import und ermitteln der Funktionsdaten

	if (incDllFun)
	{
		if (ftrExeFil-> includeDebugInfo)
		{
			for(i= 0; i < objCofHdr.secNum; i++)
			{
				newSec= (CObjFileSection *)secLst-> GetAt(i);
				if (!strcmp(newSec-> secNam, ".debug$S"))
				{
					newSecFrg= new CSectionFragmentEntry(NULL, 0x00, newSec, this, newSec-> aln);
					newSec-> SetFragEntry(newSecFrg);	
				}
			}
		}
		
		incExpEnt= NULL;
		if (secLstLst-> Lookup(".idata$6", (CObject *&)newSec))
  {
   if (secLstLst-> Lookup(".text", (CObject *&)txtSec))
    incExpEnt= newSec-> GiveDllExpEntIdata$6(this, objFilNam, txtSec);	
   else
   {
    if (secLstLst-> Lookup(".idata$2", (CObject *&)txtSec))
     incExpEnt= newSec-> GiveDllExpEntIdata$2(this, objFilNam);	  
    else
     incExpEnt= newSec-> GiveDllExpEntIdata$6(this, objFilNam);	  
   }
  }
  else
  {
   if (secLstLst-> Lookup(".idata$4", (CObject *&)newSec))
   {
    if (secLstLst-> Lookup(".text", (CObject *&)txtSec))
     incExpEnt= newSec-> GiveDllExpEntIdata$4(this, objFilNam, txtSec);	
   }
   else
			{
				if (!secLstLst-> Lookup(".idata$3", (CObject *&)newSec))
				{
					WriteMessageToPow(ERR_MSGIS_NO_IMP_SYM, objFilNam, NULL);
					lnkOK= FALSE;
				}
			}
  }

		if (!incExpEnt)
  	incDllFun= FALSE;
 }
	return lnkOK;
}

/******************************************************************************************************/
/*** Einlesen des Eportverzeichnisses einer DLL. Wird ab MS VC++ 2.0 nicht mehr verwendet, da es    ***/
/*** die .EDATA Sektion in den Bibliotheken nicht mehr gibt.																																								***/
/******************************************************************************************************/

CMapStringToOb *CObjFile::GiveDllFunDir()
{
	CObjFileSection	*expSec;			
	char	*expSecNam= ".edata";
		
	if (secLstLst-> Lookup(expSecNam, (CObject *&)expSec))
		return expSec-> GiveDllFunDir();
	
	return NULL;
}

/******************************************************************************************************/
/*** Setzen des Zeigers auf das Objekt der zu erzeugenden PE-Datei																																		***/
/******************************************************************************************************/

void CObjFile::SetExeFile(CExeFile *ftrExeFile)
{
	ftrExeFil= ftrExeFile;
}

/******************************************************************************************************/
/*** Zuordnen der Objektdateisektionen in die entsprechenden Sektionen der PE-Datei														   ***/
/******************************************************************************************************/

BOOL CObjFile::SplitObjSec(CExeFile *aExeFil)
{
	CObjFileSection		*actSec;
	LPCTSTR										secNam;
	POSITION									secPos;
	
	secPos= secLstLst-> GetStartPosition();

	while(secPos != NULL)
	{
		secLstLst-> GetNextAssoc(secPos, secNam, (CObject *&)actSec);
		actSec-> WrapFromObj2Exe(this, aExeFil);
	}
	return TRUE;
}

/******************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																						***/
/******************************************************************************************************/

void CObjFile::WriteObjDataToFile()
{
	POSITION	symPos;
	LPCTSTR		nam;
	CSection *curSec;

	logFil = fopen(logFilNam,"a");

	if (objFilNam)
  	fprintf(logFil, "\n\nObjectfile: %s", objFilNam);
	else
		fprintf(logFil, "\n\nThere' s no Objectfilename:");

	if (libFilNam)
		fprintf(logFil, "(%s)", libFilNam);
 	fprintf(logFil, "\nSektionen      : %04d", objCofHdr.secNum);
	fprintf(logFil, "\nSymbole        : %04d", objCofHdr.symNum);		
	fprintf(logFil, "\nCharakteristik : %08X\n", objCofHdr.chr);
	fclose(logFil);

	symPos= secLstLst-> GetStartPosition();

	while(symPos)
	{
	 secLstLst-> GetNextAssoc(symPos, nam, (CObject *&)curSec);
		curSec-> WriteSecDataToFile();
	}              
}

/******************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																						***/
/******************************************************************************************************/

void CObjFile::WriteSymToFile()
{
 mySymbolEntry	*aSymEnt;
 DWORD	i;
  
	for(i= 0; i < objCofHdr.symNum; i++)
	{
	 	aSymEnt= (mySymbolEntry *)newSymLst + i;
	 	if (aSymEnt-> symNam)
				printf("\n%s", aSymEnt-> symNam);
	}
}

/******************************************************************************************************/
/*** Lesen und Aufarbeiten eines Symboleintrags und seiner dazugehöriger Hilfssymboleinträge einer		***/
/*** Objektdatei																																																																																				***/
/******************************************************************************************************/

DWORD CObjFile::ReadSymEntData(mySymbolEntry *actSymEnt, CMyMemFile *actObjRawDat, DWORD ptrToStrTab, 
                               CObjFile *actObjFil, CMyPtrList *unResSymLst, CMyMapStringToPtr *pubSymLst)
{
 mySymbolTable *actSymTab;
 mySymbolEntry *resSymEnt;
 
 DWORD sekPos;		

	actSymEnt-> symObjFil= actObjFil;
 actSymEnt-> actSymTab= actSymTab= (mySymbolTable *)actObjRawDat-> ReadWithoutMemcpy(SYM_TAB_LEN);
 actSymEnt-> val= actSymTab-> val;	// Speichern von val in einer neuen Variablen, siehe unten !!!!!

 if (actSymTab-> zero)
 {
		/* Symbolname steht	im Symbol Table */

		if (actSymTab-> val && (actSymTab-> strTabOff / 0x1000000 > 0)) // Überprüfen ob 8.Byte nicht sowieso Null enthält.
		{
			actSymEnt-> symNam= (char *)malloc(2 * sizeof(DWORD) + 1);
			memset(actSymEnt-> symNam, 0x00, 2 * sizeof(DWORD) + 1);
			strncpy(actSymEnt-> symNam, (char *)actSymTab, 2 * sizeof(DWORD));
			if (!freSymNamLst)
				freSymNamLst= new CMyPtrList(50);

			freSymNamLst-> AddTail(actSymEnt-> symNam);
		}
		else
			actSymEnt-> symNam= (char *)actSymTab;
	}
	else
	{
		/*** Symbolname steht im String Table, im Symbol Table steht der Offset ***/

		sekPos= actObjRawDat-> GetPosition();
		actObjRawDat-> Seek(ptrToStrTab + actSymTab-> strTabOff, CFile::begin);
  actSymEnt-> symNam= (char *)((CMyMemFile *)actObjRawDat)-> ReadWithoutMemcpy(0);
  actObjRawDat-> Seek(sekPos, CFile::begin);
	}

	if (actSymTab-> storClass == IMAGE_SYM_CLASS_FILE)			
	{
		if (!srcFilNam)
		{
			srcFilNam= (char *) malloc(actSymTab-> auxSymNum * SYM_TAB_LEN + 1);
			memset(srcFilNam, 0x00, actSymTab-> auxSymNum * SYM_TAB_LEN + 1);
			sekPos= actObjRawDat-> GetPosition();
			actObjRawDat-> Read(srcFilNam, actSymTab-> auxSymNum * SYM_TAB_LEN);
			actObjRawDat-> Seek(sekPos, CFile::begin);
		}
	}
	
 if (actSymTab-> secNum) // Zeiger in Sektion desselben Objectfiles --> mgl. Debug Information
	{
		// Symbol wird im selben Objektfile aufgelöst
		
		actSymEnt-> resSym= actSymEnt;
		
				// Es werden nicht alle Symbole im Modul in die Symbolliste aufgenommen
		
		if (actSymEnt-> symNam[0] != '$' && actSymEnt-> symNam[0] != '.')
		 if (pubSymLst)
		 	pubSymLst-> SetAt(actSymEnt-> symNam, actSymEnt);

		if (ftrExeFil-> includeDebugInfo)
			if ((actSymTab-> storClass == IMAGE_SYM_CLASS_EXTERNAL) && (actSymTab-> secNum != 0xFFFF/*IMAGE_SYM_ABSOLUTE*/)) // External Public Symbol --> geht in Debugliste,
				actObjFil-> gloPubSymLst-> AddTail(actSymEnt);	// CV - sstGlobalPub														// außer ABS Symbole
	}		
	else
	{
		if (actSymEnt-> symNam[0] != '.')			// Es gibt .idata$# Einträge die UNDEF sind, jedoch
		{																																			// einen .val Wert haben! Haben hier nichts verloren
			if (actSymEnt-> val && (strncmp(actSymEnt-> symNam, "__F", strlen("__F"))))
			{
				// Wenn actSymTab->  val != Null ist, dann handelt es sich um eine Variable
				actSymEnt-> resSym= actSymEnt;
				WriteMessageToPow(INF_MSGS_UNI_VAR, actSymEnt-> symNam, NULL);
				
				pubSymLst-> SetAt(actSymEnt-> symNam, actSymEnt);
				actObjFil-> ftrExeFil-> bssSec-> bssVarLst-> AddTail(actSymEnt);	
																								
																																										// External Public Symbol --> geht in Debugliste außer ABS Symbole
				if ((ftrExeFil-> includeDebugInfo) && (actSymTab->  storClass == IMAGE_SYM_CLASS_EXTERNAL)) 
					actObjFil-> gloPubSymLst-> AddTail(actSymEnt);	// CV - sstGlobalPub											
			}
			else
			{
    if (actSymTab-> storClass == IMAGE_SYM_CLASS_WEAK_EXTERNAL) // Weak External
    {
     mySymbolTable *weakExt;
     sekPos= actObjRawDat-> GetPosition();
     weakExt= (mySymbolTable *)actObjRawDat-> ReadWithoutMemcpy(SYM_TAB_LEN);
     actSymEnt-> resSym= (mySymbolEntry *)symEntBuf + weakExt-> zero;
     unResSymLst-> AddTail(actSymEnt);		
     actObjRawDat-> Seek(sekPos, CFile::begin);
    }
    else
    {
			  if (unResSymLst)
				 {
				 	if (pubSymLst-> Lookup(actSymEnt-> symNam, (void *&)resSymEnt))	
				 	{
      	if (resSymEnt-> dllExpEnt)
				 			actSymEnt-> dllExpEnt= resSymEnt-> dllExpEnt;
				 		
				 		actSymEnt-> resSym= resSymEnt;		
				 	}
				 	else
      {
       if (!actObjFil-> incDllFun)
       	unResSymLst-> AddTail(actSymEnt);		
       else
        unResSymLst-> AddHead(actSymEnt);  // Soll doppelte Einträge der allgemeinen Import Descriptoren verhindern
      }
				 }
    }
			}
		}
	}

	// Überlesen der Hilfssymboleinträge

	actObjRawDat-> Seek(actSymTab->  auxSymNum * SYM_TAB_LEN, CFile::current);
 
	return actSymTab->  auxSymNum + 1;
}
