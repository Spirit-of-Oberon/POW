/**************************************************************************************************/
/*** In der Datei Linker.msg werden Nummern für Fehlermeldungen, Warnings und sontige Meldungen ***/
/*** an POW! definiert.																																																																									***/
/**************************************************************************************************/

#ifndef __LINKER_HPP__
#define __LINKER_HPP__

// Sondermeldungen

#define MSG_NUL														0x0000		// Beliebige Meldung mit einer Zeichenkette
#define NO_MSG															0xFFFF		// Es wird keine Meldung ausgegeben;

// Heapkontrollmeldungen

#define MSG_HEAP_BADBEGIN					0x9001
#define	MSG_HEAP_BADNODE						0x9002						
#define	MSG_HEAP_BADPTR							0x9003
#define	MSG_HEAP_EMPTY								0x9004
#define	MSG_HEAP_OK											0x9005
#define	MSG_HEAP_END										0x9006
#define	MSG_HEAP_UNKNOWN						0x9007


// Ablaufmeldungen des Linkers

#define INF_MSG_INI												0x0001
#define	INF_MSG_RES_SYM								0x0002
#define INF_MSG_FRE_LIB								0x0003
#define INF_MSG_CON_SEC_FRG				0x0004
#define INF_MSG_RES_REL								0x0005
#define INF_MSG_BLD_DBG								0x0006
#define INF_MSG_WRT_PE									0x0007
#define INF_MSG_FRE_MEM								0x0008


// Erfolgreiches Öffnen einer Datei

#define INF_MSG_FIL_OPE_SUC				0x0011

// Fehlermeldungen beim Initialisieren

#define ERR_MSGI_NO_LIB								0x1101
#define ERR_MSGI_NO_OBJ								0x1102
#define ERR_MSGI_NO_STA_SYM				0x1103
#define ERR_MSGI_NO_EXP_SYM				0x1104	

#define ERR_MSGI_OPN_LIB							0x1111
#define ERR_MSGI_OPN_OBJ							0x1112
#define ERR_MSGIS_NO_IMP_SYM			0x1113


// Fehlermeldungen beim Auflösen der Symbole

#define ERR_MSGS_NO_SYM								0x1201
#define ERR_MSGS_NO_DLL_SYM				0x1202

#define WRN_MSGS_NO_SYM								0x1251
#define WRN_MSGS_UNK_DEB_SEC			0x1252

#define INF_MSGS_UNI_VAR							0x1291


// Fehlermeldungen beim Zuteilen der Objektdateisektionen

#define ERR_MSGIS_NEW_SEC_TYP		0x1211
#define ERR_MSGIS_WRG_MAC						0x1212

#define WRN_MSGIS_DRC										0x1261


// Fehlermeldungen beim Zusammensetzen der Sektionsfragmente

#define ERR_MSGC_NO_WIN32_RES		0x1301

#define ERR_MSGC_OPN_RES							0x1311

#define BLD_MSGC_BLD_IMP_LIB   0x1321
#define BLD_MSGC_BLD_EXP_FIL			0x1322

#define WRN_MSGC_BLD_IMP_LIB   0x1331
#define WRN_MSGC_BLD_EXP_FIL			0x1332

#define WRN_MSGC_NO_IMP_DES				0x1341


// Fehlermeldungen beim Auflösen der Adressen

#define ERR_MSGR_NO_SEC_FRG						0x1501
#define ERR_MSGR_DIR32											0x1511			// 0x0006
#define ERR_MSGR_DIR32NB									0x1512			// 0x0007
#define ERR_MSGR_SECTION									0x1513			//	0x000A	
#define ERR_MSGR_SECREL										0x1514			// 0x000B
#define ERR_MSGR_REL32											0x1515			//	0x0014
#define ERR_MSGR_NEW_REL									0x1519			// nicht behandelter Relokationstyp

#define WRN_MSGR_NO_DLL_DBG_INF		0x1521			// Keine Debuginformation für einen DLL-Eintrag	

#define WRN_MSGR_SMA_FRG							0x1551
#define WRN_MSGR_SHIT  0x1552

// Fehlermeldungen beim Erstellen der Debuginformationen

#define WRN_MSGD_CHG_VC5_TO_CV4		0x1601
#define WRN_MSGD_CHG_VC4_TO_CV5		0x1602

#define WRN_MSGD_WRO_ALN									0x1651
#define WRN_MSGD_NO_SYM_IND						0x1652
#define WRN_MSGD_NO_TYP_IND						0x1653
#define WRN_MSGD_WRO_CVS_FOR					0x1654
#define WRN_MSGD_CV129_NO_SYM				0x1655


// Fehlermeldungen beim Erstellen der PE-Datei

#define ERR_MSGB_OPN_EXE							0x1701

#endif // __LINKER_HPP__