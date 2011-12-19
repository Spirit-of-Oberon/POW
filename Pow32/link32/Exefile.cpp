/**************************************************************************************************/
/*** Die Datei ExeFile.cpp beinhaltet die Implementierung folgender Klassen:																			 ***/
/***			CExeFile	      																																																																										***/
/**************************************************************************************************/

#include <stdlib.h>
#include <string.h>

#ifndef __EXEFILE_HPP__
#include "ExeFile.hpp"
#endif

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

#ifndef __DEBUG_HPP__
#include "Debug.hpp"
#endif

#ifndef __PUBLIBEN_HPP__
#include "PubLibEn.hpp"
#endif

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

extern DWORD	CalcTimeDateStamp();    // In Linker.cpp definiert
extern void TestHeap(void);

extern void FreeCExeFileTextSection(CExeFileTextSection *);
extern void FreeCExeFileBssSection(CExeFileBssSection *);
extern void FreeCExeFileDataSection(CExeFileDataSection *);
extern void FreeCExeFileImportSection(CExeFileImportSection *);
extern void FreeCExeFileRsrcSection(CExeFileRsrcSection *);
extern void FreeCExeFileRelocSection(CExeFileRelocSection *);
extern void FreeCExeFileDebugSection(CExeFileDebugSection *);
extern void FreeCSection(CSection *);	
extern void FreeCMyMemFile(CMyMemFile *);

extern BYTE chrBuf00[];

IMPLEMENT_DYNAMIC(CExeFile, CObject)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CExeFile::CExeFile()
{
 textSec= NULL;
	bssSec= NULL;
	rdataSec= NULL;
	idataSec= NULL;
	dataSec= NULL;
	relocSec= NULL;
	edataSec= NULL;
	rsrcSec= NULL;
	debugSec= NULL;
 
	memset(&exeCofHdr, 0, EXE_COF_HDR_SIZ);
 memset(&exeOptHdrStdFds, 0, EXE_OPT_HDR_STD_FDS_SIZ);
 memset(&exeOptHdrNtSpcFds, 0, EXE_OPT_HDR_NT_SPC_FDS_SIZ); 
 memset(&exeOptHdrDatDir, 0, EXE_OPT_HDR_DATA_DIR_SIZ);
	
	exeFilRawDat= NULL;
 exeFilSecLst= NULL;
	objFilLst= NULL;
 srcObjFilLst= NULL;
	pubSymLstForDll= NULL;
	pubSymLst= NULL;

	basAdr= 0x400000; // Windows 95 ausführbares Programm
 lodObjSecNum= 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CExeFile::~CExeFile()
{
	FreeUsedMemory(); 
}


/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CExeFile::FreeUsedMemory()
{
	if (textSec) 
	{
		FreeCExeFileTextSection(textSec);
		delete textSec;
		textSec= NULL;
	}
	if (bssSec)
	{
	 FreeCExeFileBssSection(bssSec);
		delete bssSec;
		bssSec= NULL;
	}
	if (rdataSec) 
	{
		FreeCExeFileDataSection(rdataSec);
		delete rdataSec;
		rdataSec= NULL;
	}
	if (dataSec)
	{
	 FreeCExeFileDataSection(dataSec);
		delete dataSec;
		dataSec= NULL;
	}
	if (idataSec)
	{
		FreeCExeFileImportSection(idataSec);
		delete idataSec;
		idataSec= NULL;
	}
	if (rsrcSec)
	{
		FreeCExeFileRsrcSection(rsrcSec);
		delete rsrcSec;
		rsrcSec= NULL;
	}
	if (relocSec)
	{
	 FreeCExeFileRelocSection(relocSec);
		delete relocSec;
		relocSec= NULL;
	}
	if (edataSec)
	{
	 edataSec-> ~CExeFileExportSection();
		delete edataSec;
		edataSec= NULL;
	}
	if (debugSec)
	{
		FreeCExeFileDebugSection(debugSec);
		delete debugSec;
		debugSec= NULL;
	}
	if (exeFilRawDat)
	{
		exeFilRawDat-> ~CMyMemFile();
		delete exeFilRawDat;
		exeFilRawDat= NULL;
	}
 if (exeFilSecLst)
 {
  exeFilSecLst-> ~CMyObList();
  delete exeFilSecLst;
  exeFilSecLst= NULL;
 }
 objFilLst= NULL;
 srcObjFilLst= NULL;
	pubSymLstForDll= NULL;
	pubSymLst= NULL;
 lodObjSecNum= 0;
	return TRUE;
}

/**************************************************************************************************/
/*** Initialisieren und Anlegen aller benötigter Sektionen der zu erzeugenden PE-Datei									 ***/
/**************************************************************************************************/

BOOL CExeFile::InitExeFileSec(CMyObList *obFilLst, CMyObList *srObjFilLst, CMyMapStringToPtr *pSymLst)
{
	WORD actSecNum= 0;
	char secNamBuf[9];

 exeFilSecLst= new CMyObList();

	textSec= new CExeFileTextSection(strcpy(secNamBuf, ".text"), ++actSecNum);
 exeFilSecLst-> AddTail(textSec);
	bssSec= new CExeFileBssSection(strcpy(secNamBuf, ".bss"), ++actSecNum);
 exeFilSecLst-> AddTail(bssSec);
	rdataSec= new CExeFileDataSection(strcpy(secNamBuf, ".rdata"), ++actSecNum);
 exeFilSecLst-> AddTail(rdataSec);
	dataSec= new CExeFileDataSection(strcpy(secNamBuf, ".data"), ++actSecNum);
 exeFilSecLst-> AddTail(dataSec);
 idataSec= new CExeFileImportSection(strcpy(secNamBuf, ".idata"), ++actSecNum);
 exeFilSecLst-> AddTail(idataSec);

 if (expFncSymLst[0] != NULL)
 {
  edataSec= new CExeFileExportSection(strcpy(secNamBuf, ".edata"), ++actSecNum);
  exeFilSecLst-> AddTail(edataSec);
 }
 else
  edataSec= NULL;

	if (resFilNam != NULL)
 {
		rsrcSec= new CExeFileRsrcSection(strcpy(secNamBuf, ".rsrc"), ++actSecNum);
  exeFilSecLst-> AddTail(rsrcSec);
  rsrcSec-> resFilNam= resFilNam;
 }
 else
  rsrcSec= NULL;

	relocSec= new CExeFileRelocSection(strcpy(secNamBuf, ".reloc"), ++actSecNum);
 exeFilSecLst-> AddTail(relocSec);
	if (includeDebugInfo)
 {
 	debugSec= new CExeFileDebugSection(strcpy(secNamBuf, ".debug"), this, 0);
  exeFilSecLst-> AddTail(debugSec);
  debugSec-> objFilLst= objFilNam;
  debugSec-> libFilLst= libFilNam;
		debugSec-> verSgnCV= includeDebugInfo;
 }
 else
  debugSec= NULL;

	exeFilRawDat= new CMyMemFile();
	objFilLst= obFilLst;
 srcObjFilLst= srObjFilLst;
	pubSymLstForDll= pSymLst;

 if (basAdr)
		exeOptHdrNtSpcFds.imgBas= basAdr;
	else
	{
		if (buildExeFile)
			exeOptHdrNtSpcFds.imgBas= 0x400000;
		else
			exeOptHdrNtSpcFds.imgBas= 0x10000000;
	}
	
 exeCofHdr.secNum= actSecNum;
	exeOptHdrStdFds.codBas= 0x1000;
 exeOptHdrNtSpcFds.secAln= 0x1000;
	exeOptHdrNtSpcFds.filAln= 0x200;
	return TRUE;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFile::WriteSecFragDataToFile()
{
	textSec-> WriteSecFragToFile();
	bssSec-> WriteSecFragToFile();
	rdataSec-> WriteSecFragToFile();
	dataSec-> WriteSecFragToFile();
	if (idataSec)	idataSec-> WriteImpSecToFile();
	if (rsrcSec) rsrcSec-> WriteResSecRawDataToFile();
	if (relocSec)	relocSec-> WriteRelSecToFile();
}
													
/**************************************************************************************************/
/*** Einfügen eines Importeintrags einer DLL in die Liste der Importeinträge (sortiert nach DLL ***/
/*** Dateinamen).	Die Liste selbst befindet sich in der .IDATA Sektion																										***/
/**************************************************************************************************/

BOOL CExeFile::IncludeDllImport(CDllExportEntry *dllExpEnt)
{
	CMyMapStringToOb		*aDllImpLst;
	CMyMapStringToOb		*aDllExpEnt;
	char	*aDllNam;

	aDllNam= dllExpEnt-> dllNam;

	if (!(idataSec-> dllImpLstLst)-> Lookup(aDllNam, (CObject *&)aDllImpLst))
	{
		aDllImpLst= new CMyMapStringToOb(50);
		(idataSec-> dllImpLstLst)-> SetAt(aDllNam, aDllImpLst);
	}
	
	if (!aDllImpLst-> Lookup(dllExpEnt-> expFunNam, (CObject *&)aDllExpEnt))
	{
		aDllImpLst-> SetAt(dllExpEnt-> expFunNam, dllExpEnt);
		textSec-> IncDllImp(dllExpEnt);
	}
	return TRUE;
}

/**************************************************************************************************/
/*** Zusammensetzen der Sektionsfragmente der .TEXT, .BSS, .RDATA und .DATA Sektionen, sowie    ***/
/*** Aufruf der Methoden zum Erzeugen der .IDATA Sektion und der DLL Forwarder Chain der .TEXT  ***/
/*** Sektion und Aufruf der Methoden zum Erzeugen	der .EDATA Sektion und der entsprechenden 				***/
/*** Importdatei, falls die PE-Datei eine DLL ist. 																																													***/
/**************************************************************************************************/

BOOL CExeFile::BuildExeFileRawDataSections()
{
	DWORD		nxtVirSecAdr;
	DWORD		dllForChnStart;
	DWORD  exeSecAln;

	nxtVirSecAdr= exeSecAln= exeOptHdrNtSpcFds.secAln;	
	
	textSec-> SetVirSecAdr(exeOptHdrStdFds.codBas);
 textSec-> BuildSecRawDataBlock();
 nxtVirSecAdr+= textSec-> GiveSecRawDataSize((WORD )exeOptHdrNtSpcFds.filAln);
	dllForChnStart= exeOptHdrStdFds.codBas + textSec-> GiveDllForChainStart();
	nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);

	bssSec-> SetVirSecAdr(nxtVirSecAdr);
 bssSec-> BuildSecRawDataBlock();
	nxtVirSecAdr+= bssSec-> GiveSecRawDataSize((WORD )exeOptHdrNtSpcFds.filAln);
	bssSec-> SetBssVarOff(exeOptHdrNtSpcFds.imgBas, (WORD )exeOptHdrNtSpcFds.filAln);
	nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);	
	
	rdataSec-> SetVirSecAdr(nxtVirSecAdr);
 if (includeDebugInfo)
 {
  rdataSec-> secRawDatSiz= sizeof(myDebugDirectory) * DBG_DIR_ENT_MAX;
  debugSec-> actSecTab-> virSiz= sizeof(myDebugDirectory) * DBG_DIR_ENT_MAX;
 }
 rdataSec-> BuildSecRawDataBlock();
 DWORD rdataSecSiz= rdataSec-> GiveSecRawDataSize((WORD )exeOptHdrNtSpcFds.filAln);

 if (rdataSecSiz)
 {
  nxtVirSecAdr+= rdataSec-> GiveSecRawDataSize((WORD )exeOptHdrNtSpcFds.filAln);
  nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);		
 }
 else // Es gibt keine .rdata Sektionsdaten, daher auch keine Section
	{
		exeCofHdr.secNum--;
		dataSec-> secNum--;
		idataSec-> secNum--;
		if (edataSec) edataSec-> secNum--;
		if (rsrcSec) rsrcSec-> secNum--;
		relocSec-> secNum--;
 }

	dataSec-> SetVirSecAdr(nxtVirSecAdr);
 dataSec-> BuildSecRawDataBlock();
	nxtVirSecAdr+= dataSec-> GiveSecRawDataSize((WORD )exeOptHdrNtSpcFds.filAln);
	nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);																						
	
	idataSec-> SetVirSecAdr(nxtVirSecAdr);
	nxtVirSecAdr+= idataSec-> BuildDllImpSec(pubSymLstForDll, (WORD )exeOptHdrNtSpcFds.filAln,	exeOptHdrNtSpcFds.imgBas,	
                                          dllForChnStart, includeDebugInfo);
	nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);	

	if (edataSec)
 {
  char *dllOrExeFilNam;
  char *expFilNam;
  char *dllLibFilNam;
  WORD fulNamLen;


  fulNamLen= (WORD )strlen(exeFilNam);
  while(exeFilNam[--fulNamLen] != '\\');
  dllOrExeFilNam= (char *) &exeFilNam[fulNamLen + 1];
  expFilNam= (char *) malloc(256); // !!! strlen(exeFilNam) + 2);
  dllLibFilNam= (char *) malloc(256); // !!! strlen(exeFilNam) + 2);
  expFilNam= strncpy(expFilNam, exeFilNam, strlen(exeFilNam) - 3);
  expFilNam[ strlen(exeFilNam) - 3]= '\0';
  dllLibFilNam= strcpy(dllLibFilNam, expFilNam);
  expFilNam= strcat(expFilNam, "EXP");
  dllLibFilNam= strcat(dllLibFilNam, "LIB");

	 edataSec-> SetVirSecAdr(nxtVirSecAdr);
	 nxtVirSecAdr+= edataSec-> BuildExpFncSec(dllOrExeFilNam, (WORD )exeOptHdrNtSpcFds.filAln);
 
		edataSec-> BuildDllLibFile(dllOrExeFilNam, dllLibFilNam, this);
		WriteMessageToPow(BLD_MSGC_BLD_IMP_LIB, dllLibFilNam, NULL);

		edataSec-> BuildDllExportFile(dllOrExeFilNam, expFilNam);
		WriteMessageToPow(BLD_MSGC_BLD_EXP_FIL, expFilNam, NULL);
		
		nxtVirSecAdr= GiveSectionEnd(nxtVirSecAdr);	

		free(expFilNam);
		free(dllLibFilNam);
 }

	if (rsrcSec)
	{
		rsrcSec-> SetVirSecAdr(nxtVirSecAdr);
		if (!rsrcSec-> BuildResSecRawData())
			return FALSE;
		nxtVirSecAdr+= GiveSectionEnd(rsrcSec-> actSecTab-> virSiz);	
	}

	relocSec-> SetVirSecAdr(nxtVirSecAdr);
	return TRUE;
}

/**************************************************************************************************/
/*** Aufruf der Methoden zum Auflösen der noch offenen Symbole und Erzeugen der Relokationsein-	***/
/*** träge der DLL Forwarder Chain in der DLL.																																																		***/
/**************************************************************************************************/

BOOL CExeFile::ResolveRelocations()
{
	BOOL lnkOK= TRUE;

 if (textSec) 
 {
  if (!textSec-> ResRel(relocSec-> relLst, exeOptHdrNtSpcFds.imgBas))
			lnkOK= FALSE;
	 if (!textSec-> IncDllForChainRel(idataSec-> dllImpLstLst, relocSec-> relLst, includeDebugInfo))
			lnkOK= FALSE;
 }
	
	if (rdataSec)
	 if (!rdataSec-> ResRel(relocSec-> relLst, exeOptHdrNtSpcFds.imgBas))
			lnkOK= FALSE;
	
	if (dataSec)
	 if (!dataSec-> ResRel(relocSec-> relLst,exeOptHdrNtSpcFds.imgBas))
			lnkOK= FALSE;

	if (lnkOK)
		relocSec-> BuildRelSec((WORD )exeOptHdrNtSpcFds.secAln, (WORD )exeOptHdrNtSpcFds.filAln);
	
	return lnkOK;
}

/**************************************************************************************************/
/*** Aufruf der Methoden zum Erzeugen der Debuginformationen																																				***/
/**************************************************************************************************/

BOOL CExeFile::BuildDebugInformation()
{
	BOOL lnkOKMisc;
	BOOL lnkOKFPO;
	BOOL lnkOKCV;

	debugSec-> objFilNum= objFilNum;
	debugSec-> libFilNum= libFilNum;
	
	if (debugSec-> bldMisc)
	{
		lnkOKMisc= debugSec-> BuildMiscRawDataBlock();
		if (!lnkOKMisc)
		{
			debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);
			debugSec-> bldMisc= FALSE;
		}
	}
	else
		debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);

	if (debugSec-> bldFPO)
	{
		lnkOKFPO= debugSec-> BuildFPORawDataBlock(textSec-> virSecAdr);
		if (!lnkOKFPO)
		{
			debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);
			debugSec-> bldFPO= FALSE;
		}
	}
	else
		debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);

	if (debugSec-> bldCV)
	{
		lnkOKCV= debugSec-> BuildCVRawDataBlock(idataSec-> dllImpLstLst, objFilLst);
		if (!lnkOKCV)
		{
			debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);
			debugSec-> bldCV= FALSE;
		}
	}
	else
		debugSec-> actSecTab-> virSiz-= sizeof(myDebugDirectory);

	return lnkOKMisc || lnkOKFPO || lnkOKCV;
}

/**************************************************************************************************/
/*** Initialisieren der PE-Datei Header																																																									***/
/**************************************************************************************************/

BOOL CExeFile::InitExeFileHeaders()
{
	exeCofHdr.mach= 0x14C;	

 /* Anzahl der Sektionen bereits bei Initialisierung berechnet */
 
 // exeCofHdr.secNum= ?!
  
	exeCofHdr.timDatStp= CalcTimeDateStamp();
	exeCofHdr.symTabPtr = 0;
	exeCofHdr.symNum = 0;
	exeCofHdr.optHdrSiz = 0xE0;

 exeCofHdr.chr= 0x0002 + 0x0008 + 0x0100;
 
 if (!buildExeFile)
 	exeCofHdr.chr+= 0x2000;

 if (!includeDebugInfo)
  exeCofHdr.chr+= 0x0004; 

	exeOptHdrStdFds.mag= 0x10B;
	exeOptHdrStdFds.lnkMaj= 0x3;
	exeOptHdrStdFds.lnkMin= 0x0;
 
 if (rdataSec-> actSecTab-> rawDatSiz)
	 exeOptHdrStdFds.codSiz= rdataSec-> actSecTab-> rawDatPtr - textSec-> actSecTab-> rawDatPtr;
 else
  exeOptHdrStdFds.codSiz= dataSec-> actSecTab-> rawDatPtr - textSec-> actSecTab-> rawDatPtr;  
	
	exeOptHdrStdFds.initDat= rdataSec-> actSecTab-> rawDatSiz + dataSec-> actSecTab-> rawDatSiz +
															 										idataSec-> actSecTab-> rawDatSiz + relocSec-> actSecTab-> rawDatSiz;

 if (rsrcSec)
 	exeOptHdrStdFds.initDat+= rsrcSec-> actSecTab-> rawDatSiz;

 if (edataSec)
  exeOptHdrStdFds.initDat+= edataSec-> actSecTab-> rawDatSiz;
	
	exeOptHdrStdFds.unInitDat= bssSec-> secRawDatSiz;
	exeOptHdrStdFds.entPntAdr= textSec-> entPntAdr;
	//exeOptHdrStdFds.codBas= 0;
	exeOptHdrStdFds.datBas= bssSec-> actSecTab-> rVAdrPtr;
 
 //exeOptHdrNtSpcFds.secAln= 0;
	//exeOptHdrNtSpcFds.filAln= 0;
	exeOptHdrNtSpcFds.osMaj= 4;
	exeOptHdrNtSpcFds.osMin= 0;
	exeOptHdrNtSpcFds.usrMaj= 0;
	exeOptHdrNtSpcFds.usrMin= 0;
	exeOptHdrNtSpcFds.subSysMaj= 0x4;
	exeOptHdrNtSpcFds.subSysMin= 0x0;
	exeOptHdrNtSpcFds.res= 0;

 exeOptHdrNtSpcFds.imgSiz= relocSec-> actSecTab-> rVAdrPtr + relocSec-> actSecTab-> rawDatSiz;
 if (exeOptHdrNtSpcFds.imgSiz % exeOptHdrNtSpcFds.secAln)
  exeOptHdrNtSpcFds.imgSiz+= exeOptHdrNtSpcFds.secAln - (exeOptHdrNtSpcFds.imgSiz % exeOptHdrNtSpcFds.secAln);
 
	exeOptHdrNtSpcFds.hdrSiz= 0x400;
	exeOptHdrNtSpcFds.filChkSum= 0;

	exeOptHdrNtSpcFds.subSys= subSystem; 

	if (buildExeFile)
 	exeOptHdrNtSpcFds.dllFlg= 0;
 else
  exeOptHdrNtSpcFds.dllFlg= 1;  
	exeOptHdrNtSpcFds.stkResSiz= stackSize;
	exeOptHdrNtSpcFds.stkComSiz= 0x10000;		// changed from 0x1000 to 0x10000 by PDI due to problem with enter instruction at the beginning of ProgMain
	exeOptHdrNtSpcFds.heaResSiz= 0x100000;
	exeOptHdrNtSpcFds.heaComSiz= 0x1000;
	exeOptHdrNtSpcFds.loaFlg= 0;
	exeOptHdrNtSpcFds.datDirNum= 0x10;
	
 if (edataSec)
 {
 	exeOptHdrDatDir.expAdr= edataSec-> actSecTab-> rVAdrPtr;;
	 exeOptHdrDatDir.expSiz= edataSec-> actSecTab-> virSiz;
 }
	
	exeOptHdrDatDir.impAdr= idataSec-> impDirAdr;
 exeOptHdrDatDir.impSiz= idataSec-> impDirSiz;

	if (rsrcSec)
	{
		exeOptHdrDatDir.resAdr= rsrcSec-> actSecTab-> rVAdrPtr;
		exeOptHdrDatDir.resSiz= rsrcSec-> actSecTab-> virSiz;
	}
	exeOptHdrDatDir.excAdr= 0;
	exeOptHdrDatDir.excSiz= 0;
	exeOptHdrDatDir.secAdr= 0;
	exeOptHdrDatDir.secSiz= 0;
	exeOptHdrDatDir.relAdr= relocSec-> actSecTab-> rVAdrPtr;
	exeOptHdrDatDir.relSiz= relocSec-> actSecTab-> virSiz;
 if (debugSec)
 {
 	exeOptHdrDatDir.debAdr= rdataSec-> actSecTab-> rVAdrPtr;
	 exeOptHdrDatDir.debSiz= debugSec-> actSecTab-> virSiz;
 }
	exeOptHdrDatDir.cpyAdr= 0;
	exeOptHdrDatDir.cpySiz= 0;
	exeOptHdrDatDir.gloPtrAdr= 0;
	exeOptHdrDatDir.gloPtrSiz= 0;
	exeOptHdrDatDir.tlsPtrAdr= 0;
	exeOptHdrDatDir.tlsPtrSiz= 0;
	exeOptHdrDatDir.loaConAdr= 0;
	exeOptHdrDatDir.loaConSiz= 0;
	exeOptHdrDatDir.bouImpAdr= 0;
	exeOptHdrDatDir.bouImpSiz= 0;
	exeOptHdrDatDir.impAdrTabAdr= idataSec-> impAdrTabAdr;
	exeOptHdrDatDir.impAdrTabSiz= idataSec-> impAdrTabSiz;
	exeOptHdrDatDir.resAdr1= 0;
	exeOptHdrDatDir.resSiz1= 0;
	exeOptHdrDatDir.resAdr2= 0;
	exeOptHdrDatDir.resSiz2= 0;
	exeOptHdrDatDir.resAdr3= 0;
	exeOptHdrDatDir.resSiz3= 0;

	return TRUE;
}

/**************************************************************************************************/
/*** Pyhsisches Erzeugen der PE-Datei Header																																																				***/
/**************************************************************************************************/

BOOL CExeFile::BuildExeFileHeaders()
{
	WORD	actInd= 0;
	DWORD	sig= 0x0004550;
	DWORD	dosStb[]=		{	0x00905A4D, 0x00000003, 0x00000004, 0x0000FFFF,
																				0x000000B8, 0x00000000, 0x00000040, 0x00000000,
																				0x00000000, 0x00000000, 0x00000000, 0x00000000,
																				0x00000000, 0x00000000, 0x00000000, 0x00000080,
																				0x0EBA1F0E,	0xCD09B400,	0x4C01B821, 0x685421CD,
																				0x70207369,	0x72676F72, 0x63206D61,	0x6F6E6E61,
																				0x65622074, 0x6E757220, 0x206E8920,	0x20534F44,
																				0x65646F6D, 0x0A0D0D2E,	0x00000024,	0x00000000};

	exeFilRawDat-> Write(dosStb, 32 * sizeof(DWORD));
	exeFilRawDat-> Write(&sig, sizeof(DWORD));
	exeFilRawDat-> Write(&exeCofHdr, EXE_COF_HDR_SIZ);
	exeFilRawDat-> Write(&exeOptHdrStdFds, EXE_OPT_HDR_STD_FDS_SIZ);
	exeFilRawDat-> Write(&exeOptHdrNtSpcFds, EXE_OPT_HDR_NT_SPC_FDS_SIZ);
	exeFilRawDat-> Write(&exeOptHdrDatDir, EXE_OPT_HDR_DATA_DIR_SIZ);
	
	if (textSec)	exeFilRawDat-> Write(textSec-> actSecTab, SEC_HDR_SIZ);
	if (bssSec)	exeFilRawDat-> Write(bssSec-> actSecTab, SEC_HDR_SIZ);
	if (rdataSec-> actSecTab-> virSiz) exeFilRawDat-> Write(rdataSec-> actSecTab, SEC_HDR_SIZ);
	if (dataSec)	exeFilRawDat-> Write(dataSec-> actSecTab, SEC_HDR_SIZ);
	if (idataSec) exeFilRawDat-> Write(idataSec-> actSecTab, SEC_HDR_SIZ);
	if (edataSec)	exeFilRawDat-> Write(edataSec-> actSecTab, SEC_HDR_SIZ);
	if (rsrcSec)	exeFilRawDat-> Write(rsrcSec-> actSecTab, SEC_HDR_SIZ);
	if (relocSec)	exeFilRawDat-> Write(relocSec-> actSecTab, SEC_HDR_SIZ);
	//if (debugSec) exeFilRawDat-> Write(debugSec-> actSecTab, SEC_HDR_SIZ);


	exeFilRawDat-> Write(chrBuf00, exeOptHdrNtSpcFds.filAln - (exeFilRawDat-> GetPosition() - 
			exeOptHdrNtSpcFds.filAln * (exeFilRawDat-> GetPosition() / exeOptHdrNtSpcFds.filAln)));	

	return TRUE;
}
	 
/**************************************************************************************************/
/*** Zusammensetzen der einzelnen Sektionen der PE-Datei und Initialisieren und Schreiben der   ***/
/*** PE-Datei Header.																																																																											***/
/**************************************************************************************************/

BOOL CExeFile::BuildExeFileRawData()
{
	exeFilRawDat-> Seek(0x400, CFile::begin);
	textSec-> GiveSecRawDataBlock(exeFilRawDat, idataSec-> dllImpLstLst, (WORD )exeOptHdrNtSpcFds.filAln);
 if (rdataSec-> actSecTab-> virSiz)
  rdataSec-> GiveSecRawDataBlock(exeFilRawDat, (WORD )exeOptHdrNtSpcFds.filAln);
	dataSec-> GiveSecRawDataBlock(exeFilRawDat, (WORD )exeOptHdrNtSpcFds.filAln);
	idataSec-> GiveSecRawDataBlock(exeFilRawDat);
 if (edataSec)
  edataSec-> GiveSecRawDataBlock(exeFilRawDat);  
	if (rsrcSec)
		rsrcSec-> GiveSecRawDataBlock(exeFilRawDat, (WORD )exeOptHdrNtSpcFds.filAln);
	relocSec-> GiveSecRawDataBlock(exeFilRawDat);
 if (debugSec)
  debugSec-> GiveSecRawDataBlock(exeFilRawDat, (WORD )exeOptHdrNtSpcFds.filAln); 
	exeFilRawDat-> SeekToBegin();
	InitExeFileHeaders();
	BuildExeFileHeaders();
	return TRUE;
}

/**************************************************************************************************/
/*** Schreiben der PE-Datei auf eine Datei mit dem entsprechenden Dateinamen																				***/
/**************************************************************************************************/

BOOL CExeFile::WriteExeFileRawDataToFile()
{
	CFile										actExeFil;
	CFileException *pErr= NULL;

	BYTE *filDatBuf;
	
	exeFilRawDat-> SeekToBegin();
	filDatBuf= (BYTE *) exeFilRawDat-> ReadWithoutMemcpy(exeFilRawDat-> GetLength());
	if (!actExeFil.Open(exeFilNam, CFile::modeCreate | CFile::modeWrite | CFile::typeBinary, pErr))
	{
	 WriteMessageToPow(ERR_MSGB_OPN_EXE, exeFilNam, NULL);
		return FALSE;
	}
	
	actExeFil.Write(filDatBuf, exeFilRawDat-> GetLength());
	actExeFil.Close();
	actExeFil.~CFile();	

	return TRUE;
}
	
/**************************************************************************************************/
/*** Berechnen des Sektionsendes einer Sektion unter Berücksichtigung des Alignments											 ***/
/**************************************************************************************************/

DWORD CExeFile::GiveSectionEnd(DWORD actVirSecAdr)
{
 if (actVirSecAdr % exeOptHdrNtSpcFds.secAln)
  return actVirSecAdr + (exeOptHdrNtSpcFds.secAln - (actVirSecAdr % exeOptHdrNtSpcFds.secAln));
  
 return actVirSecAdr;  
}
                     
/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/


void CExeFile::WriteExeRawDataFileToLogFile()
{
	CFile						*actExeFil;
	CFileException	*pErr= NULL;

	BYTE	*filDatBuf;
	char	*pszFilNam= "E:\\linker32\\output\\n_hallo.exe";

	filDatBuf= new BYTE[exeFilRawDat-> GetLength() + 1];
	actExeFil= new CFile();
	actExeFil-> Open(pszFilNam, CFile::modeCreate | CFile::modeWrite | CFile::typeBinary, pErr);
	exeFilRawDat-> Seek(0, CFile::begin);
	exeFilRawDat-> Read(filDatBuf, exeFilRawDat-> GetLength());
	actExeFil-> Write(filDatBuf, exeFilRawDat-> GetLength());
	delete[] filDatBuf;
	actExeFil-> Close();
	actExeFil-> ~CFile();
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CExeFile::WriteResolvedSymbolsList()
{
 textSec-> WriteResolvedSectionSymbols();
	rdataSec-> WriteResolvedSectionSymbols();
	dataSec-> WriteResolvedSectionSymbols();	
}
