/**************************************************************************************************/
/*** Die Datei Publiben.cpp beinhaltet die Implementierung folgender Klassen:																			***/
/***			CDllExportEntry																																																																										***/
/***			CSectionFragmentEntry																																																																				***/
/***			CResFileEntry																																																																												***/
/***			CResUniCodeString																																																																								***/
/**************************************************************************************************/

#include <math.h>

#ifndef __LINKER_HPP__
#include "Linker.hpp"
#endif

#ifndef __PUBLIBEN_HPP__
#include "PubLibEn.hpp"
#endif

#ifndef __OBJFILE_HPP__
#include "ObjFile.hpp"
#endif

#ifndef __SECTION_HPP__
#include "Section.hpp"
#endif

extern void WriteMessageToPow(WORD msgNr, char *str1, char *str2);

extern BYTE chrBuf00[];
 
extern void FreeCResUniCodeString(CResUniCodeString *aCResUniCodeString);
extern void FreeCMyMemFile(CMyMemFile *aCMyMemFile);
extern void FreeCMyObList(CMyObList *aCMyObList);

extern	FILE		*logFil;
extern	char		*logFilNam;        
extern 	int			logOn;   

IMPLEMENT_DYNAMIC(CDllExportEntry, CObject)
IMPLEMENT_DYNAMIC(CSectionFragmentEntry, CObject)
IMPLEMENT_DYNAMIC(CResUniCodeString, CObject)
IMPLEMENT_DYNAMIC(CResFileEntry, CObject)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CDllExportEntry::CDllExportEntry()
{
	expOrd= 0;
	expFunNam= NULL;
	dllObjFil= NULL;
	txtDllSec= NULL;
	dllNam= NULL;
	textSegOff= 0;
	idataLokUpTabOffIdata= 0;
	idataLookupTabOff= 0;
	idataExeSecNum= 0;
	impLokUpTabOff= 0;
	impAdrTabOff= 0;		
	namTabEntOff= 0;
	namTabEntLen= 0;			
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CDllExportEntry::CDllExportEntry(WORD ord, char *eFunNam, char *aDllNam, BOOL eByOrd, DWORD txtSegOff, 
                                 DWORD lUpTabOff)
{
	expOrd= ord;
	expFunNam= eFunNam;
	dllNam= aDllNam;
	textSegOff= txtSegOff;
 expByOrd= eByOrd;
	idataLokUpTabOffIdata= 0;
	idataLookupTabOff=  lUpTabOff;
	idataExeSecNum= 0;
	impLokUpTabOff= 0;
	impAdrTabOff= 0;		
	namTabEntOff= 0;
	namTabEntLen= 0;
}	

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CDllExportEntry::CDllExportEntry(CObjFile *dObjFil, CObjFileSection *tDllSec, WORD ord, char *eFunNam,
																																	char *aDllNam, BOOL eByOrd, DWORD txtSegOff, DWORD lUpTabOff)
{
	dllObjFil= dObjFil;
	txtDllSec= tDllSec;
	expOrd= ord;
	expFunNam= eFunNam;
	dllNam= aDllNam;
	textSegOff= txtSegOff;
 expByOrd= eByOrd;
	idataLokUpTabOffIdata= 0;
	idataLookupTabOff=  lUpTabOff;
	idataExeSecNum= 0;
	impLokUpTabOff= 0;
	impAdrTabOff= 0;		
	namTabEntOff= 0;
	namTabEntLen= 0;
}	

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CDllExportEntry::~CDllExportEntry()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CDllExportEntry::FreeUsedMemory()
{
	dllObjFil= NULL;
	txtDllSec= NULL;
	expFunNam= NULL;
	dllNam= NULL;	
	expOrd= 0;
	textSegOff= 0;
	idataLokUpTabOffIdata= 0;
	idataLookupTabOff= 0;
	idataExeSecNum= 0;
	impLokUpTabOff= 0;
	impAdrTabOff= 0;		
	namTabEntOff= 0;
	namTabEntLen= 0;			
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CDllExportEntry::WriteDataToFile()
{
	logFil = fopen(logFilNam,"a");
	fprintf(logFil, "\n%s: %04X % -35s", dllNam, expOrd, expFunNam);
	if (textSegOff)
		fprintf(logFil, "TextSegmentOffset: %08X", textSegOff);
	if (idataLookupTabOff)
		fprintf(logFil, "IdataOffset: %08X", idataLookupTabOff);
		
	fclose(logFil);
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CSectionFragmentEntry::CSectionFragmentEntry()
{
	actExeSec= NULL;
	secFrgOff= 0;
	myHomSec= NULL;
	secFrgRelBuf= NULL;
	rawDat= NULL;
	rawDatSiz= 0;
	secFrgAln= 16;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CSectionFragmentEntry::CSectionFragmentEntry(CExeFileDataSection *exeSec, DWORD frgOff, CObjFileSection *homSec,
																		 CObjFile *frgObjFil, WORD sFrgAln)
{
	actExeSec= exeSec;
	secFrgOff= frgOff;
	myHomSec= homSec;
	secFrgRelBuf= homSec-> secRelBuf;
	rawDat= homSec-> secRawDat;
	rawDatSiz= homSec-> actSecTab-> rawDatSiz;
	secFrgObjFil= frgObjFil;
	secFrgAln= sFrgAln;
}	

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CSectionFragmentEntry::~CSectionFragmentEntry()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CSectionFragmentEntry::FreeUsedMemory()
{
	actExeSec= NULL;
	myHomSec= NULL;
	secFrgRelBuf= NULL;
	rawDat= NULL;
	secFrgOff= 0;
	rawDatSiz= 0;
	secFrgAln= 0;	
}

/**************************************************************************************************/
/*** Setzen des Offset des Sektionsfragments in der PE-Datei Sektion																												***/
/**************************************************************************************************/

void CSectionFragmentEntry::SetFragOffset(DWORD	secOff)
{
	secFrgOff= secOff;
}
	
/**************************************************************************************************/
/*** Rückgabe der Größe des Sektionsfragments																																																			***/
/**************************************************************************************************/

DWORD CSectionFragmentEntry::GetRawDataSize()
{
 return rawDatSiz;
}

/**************************************************************************************************/
/*** Auflösen aller noch offenen Adressen eines Sektionsfragments, Ermitteln dabei anfallender		***/
/*** Debuginformationen, sowie Schreiben der in die .RELOC Sektion einzufügenden Adressen in    ***/
/*** die entsprechende Liste.																																																																			***/
/**************************************************************************************************/

BOOL CSectionFragmentEntry::ResRel(CDWordArray *relLst, DWORD imgBas, DWORD virSecAdr, WORD secNum)
{
	CObjFileSection	  *resSymSec;
	CDllExportEntry   *resDllEnt;
	myRelocationEntry *relEnt;
	mySymbolEntry		 		*actSym;
	mySymbolEntry			 	*resSym;
	
	DWORD	adrBuf;
	DWORD	resSymSecFrgOff;
	DWORD	imBase;
 DWORD secFrgRelInd= 0; 

 BOOL 	relNed= FALSE;
	BOOL		lnkOK= TRUE;
 

	while(secFrgRelInd < myHomSec-> actSecTab-> relNum)
	{
		// Laden des Symbols auf das die Relocation verweist
		relEnt= (myRelocationEntry *)(secFrgRelBuf + 10 * secFrgRelInd++);
		actSym= (mySymbolEntry *)secFrgObjFil-> newSymLst[relEnt-> symTabInd];
  resSym= actSym-> resSym;

		resDllEnt= actSym-> dllExpEnt;

		if (!resDllEnt)
		{
			if ((short) resSym-> actSymTab-> secNum > 0) // int, weil sonst keine Zahlen zustande kommen
			{
				// Ermitteln der Sectionsnummer zu der das Symbol gehört
				resSymSec= (CObjFileSection *) (resSym-> symObjFil-> secLst-> GetAt(resSym-> actSymTab-> secNum - 1));

				if (resSymSec-> actFrgEnt)
					resSymSecFrgOff= ((resSymSec-> actFrgEnt)-> actExeSec)-> virSecAdr + (resSymSec-> actFrgEnt)-> secFrgOff;
				else
				{
					WriteMessageToPow(ERR_MSGR_NO_SEC_FRG, resSym-> symNam, NULL);
					lnkOK= FALSE;
				}
				imBase= imgBas;
			}
			else
			{
				if ((short) resSym-> actSymTab-> secNum < 0)
				{
					resSymSecFrgOff= 0;
					imBase= 0;
				}
				else	// .bssEintrag
				{
					;
				}
			}
		}

		rawDat-> Seek(relEnt-> off, CFile::begin);
		rawDat-> Read(&adrBuf, sizeof(DWORD));
		switch (relEnt-> typ)
		{
			case 0x0006:		// DIR32 
				relNed= TRUE;
				if (!resDllEnt)
				{
					if (resSym)
					{
						if (resSym-> bssOff)
							adrBuf+= resSym-> bssOff;
						else
						{
							adrBuf+= imBase + resSymSecFrgOff + resSym-> val;
							if (!imBase)
								relNed= FALSE;
						}
					}
					else
					{
						if (actSym-> bssOff)
							adrBuf+= actSym-> bssOff;
						else
						{
							WriteMessageToPow(ERR_MSGR_DIR32, actSym-> symNam, NULL);
							relNed= FALSE;
						}
					}
				}	
				else
    {
					adrBuf= resDllEnt-> idataLookupTabOff;
     relNed= FALSE;
    }
							
				break;

			case 0x0007:	// DIR32NB
				if (!resDllEnt)
				{
					if (resSym)
					{
						if (resSym-> bssOff)
							adrBuf+= resSym-> bssOff;
						else
							adrBuf+= resSymSecFrgOff + resSym-> val;					
					}
					else
							WriteMessageToPow(ERR_MSGR_DIR32NB, actSym-> symNam, NULL);
				}
				
				break;
				
			case 0x000A:	// SECTION
				if (!resDllEnt)
				{
					if (resSym)
						adrBuf+= resSymSecFrgOff + resSym-> val;
					else
						WriteMessageToPow(ERR_MSGR_SECTION, actSym-> symNam, NULL);
				}
				
			case 0x000B:	// SECREL
				if (!resDllEnt)
				{
					if (resSym)
						adrBuf+= resSymSecFrgOff + resSym-> val;
					else
						WriteMessageToPow(ERR_MSGR_SECREL, actSym-> symNam, NULL);
				}
				
				break;
			
			case 0x0014:	//REL32
			
				if (!resDllEnt)
				{
					if (resSym)
						adrBuf+= resSymSecFrgOff + resSym-> val - 
											 (virSecAdr + secFrgOff + adrBuf + relEnt-> off + sizeof(DWORD));
					else
						WriteMessageToPow(ERR_MSGR_REL32, actSym-> symNam, NULL);
				}
				else
					adrBuf= resDllEnt-> textSegOff - (virSecAdr + secFrgOff + adrBuf + 
													relEnt-> off + sizeof(DWORD));
			
				break;

			default:
				char *hexBuf;

				hexBuf= (char *)malloc(sizeof(WORD));
				_itoa(relEnt-> typ, hexBuf,16);
				WriteMessageToPow(ERR_MSGR_NEW_REL, hexBuf, NULL);
				free(hexBuf);
				lnkOK= FALSE;

		}				

		/* Debug Information	- wird auch für nicht benötigte Symbole berechnet */
		
		if (!resDllEnt)
		{
			if (resSym-> actSymTab-> secNum != 0xFFFF)  // secNum == 0xFFFF ==> ABS
			{
				if (!resSym-> bssOff)
				{
          if (resSymSec->actFrgEnt)
          {
  					resSym-> secOff= resSymSec-> actFrgEnt-> secFrgOff + resSym-> val;
	  				resSym-> secNum= resSymSec-> actFrgEnt-> actExeSec-> secNum;
          }
          else
          {
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  					resSym-> secOff= resSym-> val;
	  				resSym-> secNum= 0;
          }
				}
				else
				{
					resSym-> secOff= resSym-> bssOff - imgBas;
					resSym-> secNum= 0x2;	// .text Section, nächste Section immer .bss
     			WriteMessageToPow(WRN_MSGR_SHIT, NULL, NULL);
				}
			}
		}
		else
		{
			if (resSym)
			{
				resSym-> secOff= resDllEnt-> idataLokUpTabOffIdata;
				resSym-> secNum= resDllEnt-> idataExeSecNum;
			}
		}

		rawDat-> Seek(relEnt-> off, CFile::begin);

		DWORD adrSizDif;

		adrSizDif= this-> rawDatSiz - relEnt-> off - sizeof(DWORD);
		if (adrSizDif > 0xFFFFFFFC)
		{
			WriteMessageToPow(WRN_MSGR_SMA_FRG, NULL, NULL);
			rawDat-> Write(&adrBuf, sizeof(WORD));
			if (adrSizDif == 0xFFFF)
				rawDat-> Write(&chrBuf00, sizeof(BYTE));
		}
		else
			rawDat-> Write(&adrBuf, sizeof(DWORD));

		relEnt-> off+= virSecAdr + secFrgOff; // Wird für FPO-Information benötigt			


		if (relNed)
		{
			relLst-> Add(relEnt-> off);
			relNed= FALSE;
		}		
	}

	return lnkOK;
}

/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CSectionFragmentEntry::WriteFragDataToFile()
{
	BYTE		wordBuf;
	DWORD		wriBytes= 0;
	div_t		div_res;
	
	logFil = fopen(logFilNam,"a");
	if (secFrgObjFil-> objFilNam)
		fprintf(logFil, "\nObjFile: % -32s", secFrgObjFil-> objFilNam);
	else
		fprintf(logFil, "\nObjFile: Name nicht bekannt, vermutlich DLL");
 fprintf(logFil, "\nFrag off: %04X", secFrgOff);
	if (rawDat)
  	fprintf(logFil, "\nRaw Datenlänge : %04X", rawDat-> GetLength());
	else
		fprintf(logFil, "\nRaw Datenlänge : 0000");
	
	fprintf(logFil, "\n");

	if (rawDat)
	{
		rawDat-> Seek(0, CFile::begin);

		while (rawDat-> Read(&wordBuf, 1))
		{
			div_res= div(wriBytes, 16);
			if (div_res.rem == 0)
				fprintf(logFil, "\n%04X", wriBytes);
			else
			{
				div_res= div(wriBytes, 8);
				if (div_res.rem == 0)
					fprintf(logFil, " |");
			}
			fprintf(logFil, " %02X", wordBuf);
			wriBytes++;
		}                    
		fprintf(logFil, "\n");  
	}

	fclose(logFil);
}
/**************************************************************************************************/
/*** Hilfsmethode zum Debuggen																																																																		***/
/**************************************************************************************************/

void CSectionFragmentEntry::WriteResolvedSymbols()
{
	myRelocationEntry	*relEnt;
	mySymbolEntry			  *actSym;
	
 DWORD	secFrgRelInd= 0;

	while(secFrgRelInd < myHomSec-> actSecTab-> relNum)
	{
		relEnt= (myRelocationEntry *)secFrgRelBuf + secFrgRelInd++;
		//relEnt-> WriteRelDataToFile();
		actSym= (mySymbolEntry *)(secFrgObjFil-> newSymLst[relEnt-> symTabInd]);
		//actSym-> WriteSymResDataToFile();
	}
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CResFileEntry::CResFileEntry()
{
	resAddHdr1.datSiz= 0x0;
	resAddHdr1.hdrSiz= 0x0;
	typIdtId.chr= 0xFFFF;
	typIdtId.typ= 0x0;
	typIdtUCStr= NULL;
	namIdtId.chr= 0xFFFF;
	namIdtId.nam= 0x0;
	namIdtUCStr= NULL;
	resAddHdr2.datVer= 0x0;
	resAddHdr2.memFlg= 0x0;
	resAddHdr2.lngId= 0x0;
	resAddHdr2.ver= 0x0;
	resAddHdr2.chr= 0x0;
	resRawDat= NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CResFileEntry::~CResFileEntry()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CResFileEntry::FreeUsedMemory()
{
	if (typIdtUCStr)
	{
	 FreeCResUniCodeString(typIdtUCStr);
		delete typIdtUCStr;
		typIdtUCStr= NULL;
	}
	if (namIdtUCStr) 
	{
		FreeCResUniCodeString(namIdtUCStr);
		delete namIdtUCStr;
		namIdtUCStr= NULL;
	}
	if (resRawDat)
	{
	 FreeCMyMemFile(resRawDat);
		delete resRawDat;
		resRawDat= NULL;
	}
}

/**************************************************************************************************/
/*** Lesen und Verarbeiten eines Ressourceneintrags																																													***/
/**************************************************************************************************/

int CResFileEntry::ReadResFileEntry(CFile *actResFil)
{
	DWORD	actFilPos;
	DWORD	hdrEndPos;
 WORD  uniCodChrBuf;
	BYTE		*rawDatBuf;
	WORD  actAln;

	// Untersuchen ob aktuelle FilePos dem Align entspricht
	// angenommenes Align ist DWORD

	actFilPos= actResFil-> GetPosition();
	actAln= sizeof(DWORD);
	if (actFilPos - actAln * (actFilPos / actAln))
		actResFil-> Seek(actFilPos + actAln - (actFilPos - actAln * (actFilPos / actAln)), CFile::begin);
	
	// Lesen der Hdr Informationen	
	
	actResFil-> Read(&resAddHdr1, 8);
	actFilPos= actResFil->  GetPosition();
	hdrEndPos= actFilPos + resAddHdr1.hdrSiz - 8;
	actResFil-> Read(&typIdtId, sizeof(DWORD));

	// Lesen der Typ und String Information

	if (typIdtId.chr != 0xFFFF)
	{	 
		actResFil-> Seek(actFilPos, CFile::begin);
		typIdtUCStr= new CResUniCodeString();
  typIdtUCStr-> idtUCStrLen= 1;
  actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	
  while(uniCodChrBuf)
  {
   actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	   
   typIdtUCStr-> idtUCStrLen++;
  }
  typIdtUCStr-> idtUCStrLen*= 2; 
		typIdtUCStr-> idtUCStr= new WORD[typIdtUCStr-> idtUCStrLen];
		typIdtUCStr-> uCResAdr= 0;
  actResFil-> Seek(actFilPos, CFile::begin);
		actResFil-> Read(typIdtUCStr-> idtUCStr, typIdtUCStr-> idtUCStrLen);
  
  // Ausgleichen eines möglichen Alignments

  if (typIdtUCStr-> idtUCStrLen % sizeof(WORD))
   actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	      
	}

	actFilPos= actResFil->  GetPosition();
 actResFil-> Read(&namIdtId, sizeof(DWORD));

	if (namIdtId.chr != 0xFFFF)
	{
		actResFil-> Seek(actFilPos, CFile::begin);
		namIdtUCStr= new CResUniCodeString();	
  namIdtUCStr-> idtUCStrLen= 1;
  actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	
  while(uniCodChrBuf)
  {
   actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	   
   namIdtUCStr-> idtUCStrLen++;
  }
  namIdtUCStr-> idtUCStrLen*= 2;
  namIdtUCStr-> idtUCStr= new WORD[namIdtUCStr-> idtUCStrLen];
  actResFil-> Seek(actFilPos, CFile::begin);
		actResFil-> Read(namIdtUCStr-> idtUCStr,	namIdtUCStr-> idtUCStrLen);	

  // Ausgleichen eines möglichen Alignments

  if (namIdtUCStr-> idtUCStrLen % sizeof(WORD))
   actResFil-> Read(&uniCodChrBuf,	sizeof(WORD));	      
	}
	
	actResFil-> Seek(hdrEndPos - 0x10, CFile::begin);
	actResFil-> Read(&resAddHdr2, 16);
	
	if (resAddHdr1.datSiz != 0)
	{
		resRawDat= new CMyMemFile();	
		rawDatBuf= new BYTE[resAddHdr1.datSiz];
		actResFil-> Read(rawDatBuf, resAddHdr1.datSiz);
		resRawDat-> Write(rawDatBuf, resAddHdr1.datSiz);
		delete[] rawDatBuf;
	}
	 
	return 1;
}

/*################################################################################################*/
/*################################################################################################*/
/*################################################################################################*/

/*-------------------*/
/*-- Konstruktoren --*/
/*-------------------*/

CResUniCodeString::CResUniCodeString()
{
	idtUCStr= NULL;
	idtUCStrLen= 0x0;
	uCResAdr= 0x0;
}
 
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/*------------------*/
/*-- Destruktoren --*/
/*------------------*/

CResUniCodeString::~CResUniCodeString()
{
	FreeUsedMemory();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CResUniCodeString::FreeUsedMemory()
{
	if (idtUCStr) delete[] idtUCStr;
	idtUCStr= NULL;
}
