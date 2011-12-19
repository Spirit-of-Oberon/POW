/*****************************************************************************/
/*** Die Datei Linker.h enthält alle für den Linker benötigten Daten-        */
/*** strukturen und Konstanten. 																																													*/
/*****************************************************************************/
												/*****************************************************/
																										/************************/
												/********************* Hinweis !!!! ******************/
																										/************************/
												/*****************************************************/
/*****************************************************************************/
/***** Für das Verstehen der folgenden Definitionen und Datenstrukturen ist  */
/***** die genaue Kenntnis der entsprechenden Dateiformate notwendig !!!     */
/*****	Dies sind vor allem COFF und  PE, aber auch das Win32 Ressource					 	*/
/***** Format und CodeView 4.10 sowie CodeView 5.0																									 	*/
/*****************************************************************************/

#ifndef __LINKER_H__
#define	__LINKER_H__

#ifndef __AFX_H__												
#include <afx.h>
#endif

#ifndef __AFXCOLL_H__
#include <afxcoll.h>
#endif

#ifndef __WINNT_H__
#include <winnt.h>
#endif

/* Umgebaute AFX Klassen */

#ifndef __MYFILE_HPP__
#include "MyCFile.hpp"
#endif

#ifndef __MYCOLL_HPP__
#include "MyColl.hpp"
#endif

/*************************/
/*** Klassendefinition ***/
/*************************/

class CMyMemFile;

class CSection;
 class CObjFileSection;
	class CExeFileDataSection;
		class CExeFileTextSection;
		class CExeFileDebugSection;
 class CExeFileBssSection;
 class CExeFileRelocSection;
	class CExeFileImportSection; 
 class CExeFileExportSection;
	class CExeFileRsrcSection;
	
class CObjFile;

class CLibFile;

class	CExeFile;

class CDllExportEntry;
class CSectionFragmentEntry;
class	CResFileEntry;

class CString;
class CMemFile;

/****************************/                          
/*** Konstantendefinition ***/
/****************************/

#define COF_HDR_SIZ						   20					// Größe des COFF-Headers
#define	SEC_HDR_SIZ         40					//	Größe eines Eintrags in der Sektionstabelle
#define LIB_FIL_HDR_SIZ		   44					// Größe des Headers der Libraries
#define	SYM_TAB_LEN         18					// Größe eines Eintrags der Symboltabelle
#define	REL_ENTRY_SIZ       10					//	Größe eines Eintrags der Relokationen
#define LIN_NUM_ENT_SIZ     06					//	Größe eines Eintrags der Zeilennummern
#define	IMP_DIR_TAB_SIZ     20					// Größe eines Eintrags im Verzeichnis der Importtabelle
#define EXP_DIR_TAB_SIZ     40					//	Größe eines Eintrags im Verzeichnis der Exporttabelle

#define CV_SUB_SEC_DIR_HDR_SIZ 0x10				// Größe des Headers des CV Subsection Directories
#define CV_SUB_SEC_DIR_ENT_SIZ 0x0C				// Größe des Eintrags des CV Subsection Tabelle
#define SST_SEG_MAP_ENT_SIZ    0x14				// Größe des Eintrags der CV SST_SEG_MAP

#define	HIGH_RES_TYP_NUM       0x20				//	Höchste Typnummer eines Ressourcetyps, die verabeitet
																																							//	wird

#define REL_ENT_SIZ      10												//	Größe eines Eintrags der Relokationen
	
#define	EXE_COF_HDR_SIZ            20					// Größe des COFF-Headers im EXE-File 						
#define	EXE_OPT_HDR_STD_FDS_SIZ    28					// Größe der Optional Header Standard Fields im EXE-File 						
#define	EXE_OPT_HDR_NT_SPC_FDS_SIZ 68					// Größe der Optional Header Windows NT Specific Fields
																																										// im EXE-File 						
#define	EXE_OPT_HDR_DATA_DIR_SIZ   128				//	Größe des Optional Headers Datendirectories im EXE-File 						

#define DBG_DIR_ENT_MAX												3						// Derzeit werden MISC, FPO und CV Debugformate untersützt, daher
																																										// höchsten drei Einträge im Debugdirectory


/*** Festlegung verschiedener Symboltypen ***/

enum mySymTyp
{
	noSym,
	gloSym,
	gloPubSym,
	staSym
};


/*** COFF-Header ***/
                                 
struct 	myCoffHeader
{
	WORD  mach;
	WORD  secNum;
	DWORD timDatStp;
	DWORD symTabPtr;
	DWORD symNum;
	WORD  optHdrSiz;
	WORD  chr;
};
	
/*** COFF Symboltabelle ***/

struct	mySymbolTable
{
	DWORD zero;
	DWORD strTabOff;
	DWORD val;
	WORD  secNum;
	WORD  typ;
	BYTE  storClass;
	BYTE  auxSymNum;
};

/*** Hilfssymboleintrag Function Definitions ***/

struct myFunctionDefinition
{
 DWORD tagInd;
 DWORD totSiz;
 DWORD linNumPtr;
 DWORD nxtFncPtr;
 WORD  unUsd;
};

/*** Hilfssymboleintrag Begin und End Function ***/

struct myBfAndEfAuxiliarySymbolFormat
{
 DWORD unUsd1;
 WORD  actLinNum;
 WORD  unUsd2;
 DWORD unUsd3;
 DWORD nxtFncPtr;
 WORD  unUsd4;
};

/*** Hilfssymboleintrag Sektiondefinition ***/

struct mySectionDefinitions
{
 DWORD len;
 WORD  relNmb;
 WORD  linNmb;
 DWORD chkSum;
 WORD  nmb;
 BYTE  sel;
 BYTE  unUsd[3];
};


/*** Speicherung aller notwendigen Symboldaten, nicht identisch mit den COFF ***/
/*** Symboleintrag.																																																										***/

struct mySymbolEntry
{
 char            *symNam;
 mySymbolTable   *actSymTab;
 mySymbolEntry   *resSym;
 CDllExportEntry *dllExpEnt;
 CObjFile        *symObjFil;
 DWORD           bssOff;
 DWORD           val;
 DWORD           symOff;
 DWORD           secOff;
 DWORD           secNum;
 char            *expTabSymNam;
};

/*** Bibliotheksverzeichniseintrag der Symbole in den Libraries ***/

struct myPublicLibEntry
{
 char     *achMemSym;
 DWORD    achMemOff;
 CLibFile *myLibFil;
};

/*** COFF Relokationseintrag ***/

struct	myRelocationEntry
{
	DWORD off;
	DWORD symTabInd;
	WORD  typ;
};

/*** COFF Zeilennummerneintrag ***/

struct myLineNumberEntry
{
	DWORD typ;
	WORD		linNum;
};

/*** COFF Symbolverzeichniseintrag ***/
	
struct mySectionTable
{
	BYTE  secNam[8];
	DWORD virSiz;
	DWORD rVAdrPtr;
	DWORD	rawDatSiz;
	DWORD rawDatPtr;
	DWORD relPtr;
	DWORD linNumPtr;
	WORD  relNum;
	WORD  linNumNum;	
	DWORD chr;
};

/****************************/
/****** .edata Section ******/
/****************************/

/*** Verzeichniseintrag der Exporttabelle ***/

struct myExportDirectoryTable
{
	DWORD expFlags;
	DWORD timDatStp;
	WORD  majVer;
	WORD  minVer;
	DWORD dllNamAdr;
	DWORD ordBas;
	DWORD adrTabEntNum;
	DWORD namPtrNum;
	DWORD expAdrTabPtr;
	DWORD expNamPtrTab;
	DWORD ordTabPtr;
};

/*** Eintrag der Exporttabellen ***/

struct myExportRecord
{
 DWORD expSymOrd;
 LPSTR expSymNam;
};

/****************************/
/****** .idata Section ******/
/****************************/

/*** Verzeichniseintrag der Importtabelle aus DLL's ***/

struct myImportDirectoryTable
{
	DWORD impLookupTab;
	DWORD timDatStp;
	DWORD forChn;
	DWORD dllNamRAdr;
	DWORD impAdrTabRAdr;
};

/**************************************************************************************************/
/* 																							R E S S O U R C E - D E F I N I T I O N S 																														*/
/**************************************************************************************************/

/*** Additional Header1 Information der RES-Files ***/

struct myResourceAddHeader1
{
	DWORD datSiz;	
	DWORD hdrSiz;
};    

/*** Additional Header2 Information der RES-Files ***/

struct myResourceAddHeader2
{
	DWORD datVer;
	WORD  memFlg;
	WORD  lngId;
	DWORD ver;
	DWORD chr;
};    

/*** Type der Ressource ***/

struct myTypeIdentifier
{
	WORD chr;
	WORD typ;
};    

/*** Name der Ressource ***/

struct myNameIdentifier
{
	WORD chr;
	WORD nam;
};
      
/* Eintrag im Ressourcenverzeichnis */

struct myResourceDirectoryTable
{
	DWORD chr;
	DWORD timDatStp;
	WORD  majVer;
	WORD  minVer;
	WORD  namEntNum;
	WORD  idEntNum;
};     

/**************************************************************************************************/
/* 																														L I B R A R Y - D E F I N I T I O N S 																											*/
/**************************************************************************************************/

/*** Header der COFF Libraries, jedoch ohne "Archivemembername", da dieser Eintrag keine konstante ***/
/*** Länge (normalerwiese 16 Bytes) aufweisen muß																																																		***/		

struct myLibFileHeader					
{
	BYTE dat[12];
	BYTE usrId[6];
	BYTE grpId[6];
	BYTE mod[8];
	BYTE siz[10];
	WORD hdrEnd;
};


/**************************************************************************************************/
/* 																										E X E F I L E   H E A D E R - D E F I N I T I O N S 																	*/
/**************************************************************************************************/

struct	myOptionalHeaderStandardFields
{
	WORD  mag;
	BYTE  lnkMaj;
	BYTE		lnkMin;
	DWORD codSiz;
	DWORD initDat;
	DWORD unInitDat;
	DWORD entPntAdr;
	DWORD codBas;
	DWORD datBas;
};
										
struct	myOptionalHeaderNtSpecificFields
{
	DWORD imgBas;
	DWORD secAln;
	DWORD	filAln;
	WORD  osMaj;
	WORD  osMin;
	WORD  usrMaj;
	WORD  usrMin;
	WORD  subSysMaj;
	WORD  subSysMin;
	DWORD res;
	DWORD imgSiz;
	DWORD hdrSiz;
	DWORD filChkSum;
	WORD  subSys;
	WORD  dllFlg;
	DWORD stkResSiz;
	DWORD stkComSiz;
	DWORD heaResSiz;
	DWORD heaComSiz;
	DWORD loaFlg;
	DWORD datDirNum;
};

struct	myOptionalHeaderDataDirectory
{
	DWORD expAdr;
	DWORD expSiz;
	DWORD impAdr;
	DWORD impSiz;
	DWORD resAdr;
	DWORD resSiz;
	DWORD excAdr;
	DWORD excSiz;
	DWORD secAdr;
	DWORD secSiz;
	DWORD relAdr;
	DWORD relSiz;
	DWORD debAdr;
	DWORD debSiz;
	DWORD cpyAdr;
	DWORD cpySiz;
	DWORD gloPtrAdr;
	DWORD gloPtrSiz;
	DWORD tlsPtrAdr;
	DWORD tlsPtrSiz;
	DWORD loaConAdr;
	DWORD loaConSiz;
	DWORD bouImpAdr;
	DWORD bouImpSiz;
	DWORD impAdrTabAdr;
	DWORD impAdrTabSiz;
	DWORD resAdr1;
	DWORD resSiz1;
	DWORD resAdr2;
	DWORD resSiz2;
	DWORD resAdr3;
	DWORD resSiz3;
};

/**************************************************************************************************/
/*																											D E B U G F O R M A T - D E F I N I T I O N S																								*/
/**************************************************************************************************/

/*********************************/
/* D E B U G   D I R E C T O R Y */
/*********************************/

/*** Eintrag im Verzeichnis der Debuginformationen in der PE-Datei (üblicherweise ***/
/*** in der .RDATA Sektion)																																																							***/ 

struct myDebugDirectory
{
	DWORD chr;
	DWORD timDatStp;
	WORD		majVer;
	WORD  minVer;
	DWORD dbgTyp;
	DWORD datSiz;
	DWORD rVAdr;
	DWORD rawDatPtr;
};

/**********************************/
/* F P O - Frame Pointer Omission */
/**********************************/

struct myFPOData
{
	DWORD fncOff;
	DWORD prcSiz;
	DWORD cdwLoc;
	WORD 	cdwPar;

	WORD 	plg 			: 8;
	WORD  reg 			: 3;
	WORD  hasSeh : 1;
	WORD  usePp  : 1;
	WORD  res    : 1;
	WORD  frm				: 2;
};

/*******************/
/*	C O D E V I E W */
/*******************/

/*-------------------*/
/* Symbol Definition */
/*-------------------*/

struct mySymbolRecord
{
	WORD recLen;
	WORD symTyp;
};

/*---------------------*/
/* Codeview Exe-Format */
/*---------------------*/

struct mySubsectionDirectoryHeader
{
	WORD  dirHdrLen;
	WORD		dirEntLen;
	DWORD dirEntNum;
	DWORD nxtDirOff;
	DWORD flg;
};

struct mySubsectionDirectoryEntry
{
	WORD  subDirInd;
	WORD  modInd;
	DWORD entOff;
	DWORD bytNum;
};

/*-------------------*/
/* (0x120) sstModule */
/*-------------------*/

struct mySstModule
{
	WORD  ovlNum;
	WORD  sstLibSubSecInd;
	WORD  conCodSegNum;
	WORD  sty;
};

struct mySstModuleSegInfo
{
	WORD		seg;
	WORD	 pad;
	DWORD codOff;
	DWORD codLen;
};

/***********************/
/* Type Records Format */
/***********************/

/*-----------------------------------*/
/* 0x0002 Pointer : attribute record */
/*-----------------------------------*/

struct pointerAttributesCV4
{
 WORD ptrtype   : 5;
 WORD ptrmode   : 3;
 WORD isflat32  : 1;
 WORD volatil			: 1;
 WORD cons						: 1;
 WORD unaligned : 1;
 WORD unused			 : 4;
};

struct pointerAttributesCV5
{
 DWORD ptrtype   :  5;
 DWORD ptrmode   :  3;
 DWORD isflat32  :  1;
 DWORD volatil			:  1;
 DWORD cons						:  1;
 DWORD unaligned :  1;
 DWORD restrict		:  1;
	DWORD unused				:	19;
};

/*************************/
/* Symbol Records Format */
/*************************/

/*------------------------------------------*/
/* (0x201) Local Data 16:32	(CV4.0)								 */
/* (0x202) Global Data Symbol 16:32 (CV4.0)	*/
/* (0x203) Public 16:32	(CV4.0)					    			 */
/*------------------------------------------*/

#define		DAT_SYM_CV4_LEN		0xD

struct myDatSym32CV4
{
	WORD  recLen;
	WORD  symTyp;
	DWORD codSecOff;
	WORD  secNum;
	WORD  typInd;
	BYTE  symLen;
};

/*-------------------------------------------*/
/* (0x1007) Local Data 16:32	(CV5.0)								 */
/* (0x1008) Global Data Symbol 16:32 (CV5.0) */
/* (0x1009) Public 16:32	(CV5.0) 												*/
/*-------------------------------------------*/

#define		DAT_SYM_CV5_LEN		0xF

struct myDatSym32CV5
{
	WORD  recLen;
	WORD  symTyp;
	DWORD typInd;
	DWORD codSecOff;
	WORD  secNum;
	BYTE  symLen;
};

/*----------------------------------------------*/
/* (0x0205) Local Procedure Start 16:32 (CV4.0) */
/*----------------------------------------------*/

#define		PRO_STA_CV4_LEN		0x21

struct myProcedureStartCV4
{
	DWORD par;
	DWORD end;
	DWORD nxt;
	DWORD prcLen;
	DWORD dbgSrt;
	DWORD dbgEnd;
	DWORD prcAdrOff;
	WORD  seg;
	WORD  prcTyp;
	BYTE  flg;
};

/*----------------------------------------------*/
/* (0x100B) Local Procedure Start 16:32 (CV5.0) */
/*----------------------------------------------*/

#define		PRO_STA_CV5_LEN		0x23

struct myProcedureStartCV5
{
	DWORD par;
	DWORD end;
	DWORD nxt;
	DWORD prcLen;
	DWORD dbgSrt;
	DWORD dbgEnd;
	DWORD prcTyp;
	DWORD prcAdrOff;
	WORD  seg;
	BYTE  flg;
};

/*---------------------------*/
/* (0x206) Thunk Start 16:32 */
/*---------------------------*/

struct myThunkStart
{
 WORD  recLen;
 WORD  symTyp;
 DWORD pPar;
 DWORD pEnd;
 DWORD pNxt;
 DWORD off;
 WORD  seg;
 WORD  thkLen;
 BYTE  ord;
 BYTE  symLen;
};

/*-----------------------------*/
/* (0x400) Procedure Reference */
/*-----------------------------*/

struct myProcedureReference
{
 WORD  refLen;
 WORD  ind;
 DWORD chkSum;
 DWORD off;
 WORD  mod;
 WORD  alnSgn;
};


/********************/
/* Subsection Types */
/********************/

/*-----------------------*/
/* (0x127) sstSrcModule  */
/*-----------------------*/

/* Hilfs Start/End Record */

#define STA_END_REC_SIZ		0x08

struct staEndRec
{
	DWORD	staOff;
	DWORD	endOff;
};

/*** Module Header ***/

#define MOD_HDR_SIZ		0x10

struct modHdrStrRec
{
	WORD						srcFilNmb;
	WORD						codSegNmb;
	DWORD					*basSrcFilOffArr;
	staEndRec	*staEndOffArr;
	WORD						*segIndArr;
};

/*** File Table ***/

#define FIL_TAB_SIZ		0x11

struct filTabRec
{
	WORD						codSegNmb;
	WORD						pad;
	DWORD					*basSrcLinOffArr;
	staEndRec	*staEndOffArr;
	BYTE						srcFilNamLen;
	char						*srcFilNam;
};

/*** Line number address mapping information ***/

#define LIN_NMB_ADR_MAP_INF_SIZ	0xC

struct linNmbAdrMapInfRec									
{
	WORD		segInd;
	WORD		linNmbCnt;
	DWORD	*codSegOffArr;
	WORD		*linNmbArr;
};																


/*--------------------------------------------------------------------*/
/* (0x129) sstGlobalSym, (0x12A) sstGlobalPub, (0x0x134) sstStaticSym */
/*--------------------------------------------------------------------*/

struct mySstGSymGPubSSymHeader
{
	WORD 	symHshInd;
	WORD 	adrHshInd;
	DWORD symTabLen;
	DWORD symHshTabLen;
	DWORD adrHshTabLen;
};

/*-------------------*/
/* (0x12B) sstSegMap */
/*-------------------*/

struct mySstSegDisArr
{
 WORD frmRed   : 1;
 WORD frmWrt   : 1;
 WORD frmExe   : 1;
 WORD frm32Bit : 1;
 WORD res3     : 4;
 WORD frmSel   : 1;
 WORD frmAbs   : 1;
 WORD res2     : 2;
 WORD frmGrp   : 1;
 WORD res1     : 3;

 WORD  ovlNum;
 WORD  grp;
 WORD  frm;
 WORD  segNamInd;
 WORD  clsNamInd;
 DWORD off;
 DWORD segLen;
};

struct mySstGloTypInfRec
{
	WORD		symLen;
	DWORD	typRefNmb;
	BYTE		*typRawDat;
	DWORD	sstGloTypInd;
	WORD		pad;
};

#endif  // __LINKER_H__
