(******************************************************************************)
(*                                                                            *)
(**)                      DEFINITION DDEML;                                 (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1993, Robinson Associates                                    *)
(*                     Red Lion House                                         *)
(*                     St Mary's Street                                       *)
(*                     PAINSWICK                                              *)
(*                     Glos                                                   *)
(*                     GL6  6QR                                               *)
(*                     Tel:    (+44) (0)1452 813 699                          *)
(*                     Fax:    (+44) (0)1452 812 912                          *)
(*                     e-Mail: Oberon@robinsons.co.uk                         *)
(******************************************************************************)
(*  05-21-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(*   ddeml.h -    DDEML API header file                                       *)
(*                                                                            *)
(*                Version 3.10                                                *)
(*                                                                            *)
(*                                                                            *) 
(******************************************************************************)
(* ******* public types ******* *)
(* **** conversation states (usState) **** *)
IMPORT WD := WinDef, DDE;

CONST 
  XST_NULL = 0;                        (*  quiescent states  *)
  XST_INCOMPLETE = 1;
  XST_CONNECTED = 2;
  XST_INIT1 = 3;                       (*  mid-initiation states  *)
  XST_INIT2 = 4;
  XST_REQSENT = 5;                     (*  active conversation states  *)
  XST_DATARCVD = 6;
  XST_POKESENT = 7;
  XST_POKEACKRCVD = 8;
  XST_EXECSENT = 9;
  XST_EXECACKRCVD = 10;
  XST_ADVSENT = 11;
  XST_UNADVSENT = 12;
  XST_ADVACKRCVD = 13;
  XST_UNADVACKRCVD = 14;
  XST_ADVDATASENT = 15;
  XST_ADVDATAACKRCVD = 16;

(*  used in LOWORD(dwData1) of XTYP_ADVREQ callbacks...  *)
  CADV_LATEACK = 0FFFFH;

(* **** conversation status bits (fsStatus) **** *)
  ST_CONNECTED = 1H;
  ST_ADVISE = 2H;
  ST_ISLOCAL = 4H;
  ST_BLOCKED = 8H;
  EC_DISABLE = ST_BLOCKED;
  ST_CLIENT = 10H;
  ST_TERMINATED = 20H;
  ST_INLIST = 40H;
  ST_BLOCKNEXT = 80H;
  EC_ENABLEONE = ST_BLOCKNEXT;
  ST_ISSELF = 100H;

(*  DDE constants for wStatus field  *)
  DDE_FACK = 8000H;
  DDE_FBUSY = 4000H;
  DDE_FDEFERUPD = 4000H;
  DDE_FACKREQ = 8000H;
  DDE_FRELEASE = 2000H;
  DDE_FREQUESTED = 1000H;
  DDE_FAPPSTATUS = 0FFH;
  DDE_FNOTPROCESSED = 0H;
  DDE_FACKRESERVED = 0C0FFH;    (* -49408 (~(DDE_FACK | DDE_FBUSY | DDE_FAPPSTATUS))*)
  DDE_FADVRESERVED = 0C000H;    (* -49153 (~(DDE_FACKREQ | DDE_FDEFERUPD))*)
  DDE_FDATRESERVED = 0B000H;    (* -45057 (~(DDE_FACKREQ | DDE_FRELEASE | DDE_FREQUESTED))*)
  DDE_FPOKRESERVED = 2000H;     (* -8193 (~(DDE_FRELEASE))*)

(* **** message filter hook types **** *)
  MSGF_DDEMGR = 8001H;

(* **** codepage constants *** *)
  CP_WINANSI = 1004;                   (*  default codepage for windows & old DDE convs.  *)
  CP_WINNEUTRAL = CP_WINANSI;
  CP_WINUNICODE = 1200;

(* **** transaction types **** *)
  XTYPF_NOBLOCK =           2H;                  (*  CBR_BLOCK will not work  *)
  XTYPF_NODATA =            4H;                   (*  DDE_FDEFERUPD  *)
  XTYPF_ACKREQ =            8H;                   (*  DDE_FACKREQ  *)
  XCLASS_MASK =         0FC00H;
  XCLASS_BOOL =          1000H;
  XCLASS_DATA =          2000H;
  XCLASS_FLAGS =         4000H;
  XCLASS_NOTIFICATION =  8000H;
  XTYP_ERROR = 32770;     (*8002H (0x0000 | XCLASS_NOTIFICATION | XTYPF_NOBLOCK )*)
  XTYP_ADVDATA = 16400;   (*4010H(0x0010 | XCLASS_FLAGS         )*)
  XTYP_ADVREQ = 8226;     (*2022H(0x0020 | XCLASS_DATA | XTYPF_NOBLOCK )*)
  XTYP_ADVSTART = 4144;   (*1030H(0x0030 | XCLASS_BOOL          )*)
  XTYP_ADVSTOP = 32832;   (*8040H(0x0040 | XCLASS_NOTIFICATION)*)
  XTYP_EXECUTE = 16464;   (*4050H(0x0050 | XCLASS_FLAGS         )*)
  XTYP_CONNECT = 4194;    (*1062H(0x0060 | XCLASS_BOOL | XTYPF_NOBLOCK)*)
  XTYP_CONNECT_CONFIRM = 32882;  (*8072H(0x0070 | XCLASS_NOTIFICATION | XTYPF_NOBLOCK)*)
  XTYP_XACT_COMPLETE = 32896;     (*8080H(0x0080 | XCLASS_NOTIFICATION  )*)
  XTYP_POKE = 16528;      (*4090H(0x0090 | XCLASS_FLAGS         )               *)
  XTYP_REGISTER = 32930;  (*80A2H(0x00A0 | XCLASS_NOTIFICATION | XTYPF_NOBLOCK) *)
  XTYP_REQUEST = 8368;    (*20B0H(0x00B0 | XCLASS_DATA          )*)
  XTYP_DISCONNECT = 32962;(*80C2H(0x00C0 | XCLASS_NOTIFICATION | XTYPF_NOBLOCK)              *)
  XTYP_UNREGISTER = 32978;(*80D2H(0x00D0 | XCLASS_NOTIFICATION | XTYPF_NOBLOCK) *)
  XTYP_WILDCONNECT = 8418;(*20E2H(0x00E0 | XCLASS_DATA | XTYPF_NOBLOCK)*)
  XTYP_MASK = 0F0H;       
  XTYP_SHIFT = 4;         (*  shift to turn XTYP_ into an index  *)


(* **** Timeout constants **** *)
  TIMEOUT_ASYNC = -1H;

(* **** Transaction ID constants **** *)
  QID_SYNC = -1H;

(* ***** public strings used in DDE ***** *)
  SZDDESYS_TOPIC = 'System';
  SZDDESYS_ITEM_TOPICS = 'Topics';
  SZDDESYS_ITEM_SYSITEMS = 'SysItems';
  SZDDESYS_ITEM_RTNMSG = 'ReturnMessage';
  SZDDESYS_ITEM_STATUS = 'Status';
  SZDDESYS_ITEM_FORMATS = 'Formats';
  SZDDESYS_ITEM_HELP = 'Help';
  SZDDE_ITEM_ITEMLIST = 'TopicItemList';

  CBR_BLOCK = -1;   (* FFFFFFFFH*)
(*                                                       *)
(*  * Callback filter flags for use with standard apps.  *)
(*                                                       *)


  CBF_FAIL_SELFCONNECTIONS = 1000H;
  CBF_FAIL_CONNECTIONS = 2000H;
  CBF_FAIL_ADVISES = 4000H;
  CBF_FAIL_EXECUTES = 8000H;
  CBF_FAIL_POKES = 10000H;
  CBF_FAIL_REQUESTS = 20000H;
  CBF_FAIL_ALLSVRXACTIONS = 3F000H;
  CBF_SKIP_CONNECT_CONFIRMS = 40000H;
  CBF_SKIP_REGISTRATIONS = 80000H;
  CBF_SKIP_UNREGISTRATIONS = 100000H;
  CBF_SKIP_DISCONNECTS = 200000H;
  CBF_SKIP_ALLNOTIFICATIONS = 3C0000H;

(*                               *)
(*  * Application command flags  *)
(*                               *)
  APPCMD_CLIENTONLY = 10H;
  APPCMD_FILTERINITS = 20H;
  APPCMD_MASK = 0FF0H;

(*                                      *)
(*  * Application classification flags  *)
(*                                      *)
  APPCLASS_STANDARD = 0H;
  APPCLASS_MASK = 0FH;

  EC_ENABLEALL = 0;
  EC_QUERYWAITING = 2;
 
  DNS_REGISTER = 1H;
  DNS_UNREGISTER = 2H;
  DNS_FILTERON = 4H;
  DNS_FILTEROFF = 8H;

  HDATA_APPOWNED = 1H;
 
  DMLERR_NO_ERROR = 0;                 (*  must be 0  *)
  DMLERR_FIRST = 4000H;
  DMLERR_ADVACKTIMEOUT = 4000H;
  DMLERR_BUSY = 4001H;
  DMLERR_DATAACKTIMEOUT = 4002H;
  DMLERR_DLL_NOT_INITIALIZED = 4003H;
  DMLERR_DLL_USAGE = 4004H;
  DMLERR_EXECACKTIMEOUT = 4005H;
  DMLERR_INVALIDPARAMETER = 4006H;
  DMLERR_LOW_MEMORY = 4007H;
  DMLERR_MEMORY_ERROR = 4008H;
  DMLERR_NOTPROCESSED = 4009H;
  DMLERR_NO_CONV_ESTABLISHED = 400AH;
  DMLERR_POKEACKTIMEOUT = 400BH;
  DMLERR_POSTMSG_FAILED = 400CH;
  DMLERR_REENTRANCY = 400DH;
  DMLERR_SERVER_DIED = 400EH;
  DMLERR_SYS_ERROR = 400FH;
  DMLERR_UNADVACKTIMEOUT = 4010H;
  DMLERR_UNFOUND_QUEUE_ID = 4011H;
  DMLERR_LAST = 4011H;
 
  MH_CREATE = 1;
  MH_KEEP = 2;
  MH_DELETE = 3;
  MH_CLEANUP = 4;
 
  MAX_MONITORS = 4;
  APPCLASS_MONITOR = 1H;
  XTYP_MONITOR = 33010;

(*                                                                            *)
(*  * Callback filter flags for use with MONITOR apps - 0 implies no monitor  *)
(*  * callbacks.                                                              *)
(*                                                                            *)
  MF_HSZ_INFO = 1000000H;
  MF_SENDMSGS = 2000000H;
  MF_POSTMSGS = 4000000H;
  MF_CALLBACKS = 8000000H;
  MF_ERRORS = 10000000H;
  MF_LINKS = 20000000H;
  MF_CONV = 40000000H;
  MF_MASK = -1000000H;

TYPE 
  HCONVLIST = LONGINT;
  HCONV = LONGINT;
  HSZ = LONGINT;
  HDDEDATA = LONGINT;

(*  the following structure is for use with XTYP_WILDCONNECT processing.  *)

  HSZPAIR = RECORD [_NOTALIGNED]
    hszSvc  : HSZ;
    hszTopic: HSZ;
  END;
  PHSZPAIR = POINTER TO HSZPAIR;

(*  The following structure is used by DdeConnect() and DdeConnectList() and  *)
(*  by XTYP_CONNECT and XTYP_WILDCONNECT callbacks.                           *)

  CONVCONTEXT = RECORD [_NOTALIGNED]
    cb        : WD.UINT;                       (*  set to sizeof(CONVCONTEXT)  *)
    wFlags    : WD.UINT;                       (*  none currently defined.  *)
    wCountryID: WD.UINT;                       (*  country code for topic/item strings used.  *)
    iCodePage : LONGINT;                               (*  codepage used for topic/item strings.  *)
    dwLangID  : WD.DWORD;                      (*  language ID for topic/item strings.  *)
    dwSecurity: WD.DWORD;                      (*  Private security code.  *)
    qos       : DDE.SECURITY_QUALITY_OF_SERVICE;   (*  client side's quality of service  *)
  END;
  PCONVCONTEXT = POINTER TO CONVCONTEXT;

(*  The following structure is used by DdeQueryConvInfo():  *)

  CONVINFO = RECORD [_NOTALIGNED]
    cb           : WD.DWORD;   (*  sizeof(CONVINFO)   *)
    hUser        : WD.DWORD;   (*  user specified field   *)
    hConvPartner : HCONV;              (*  hConv on other end or 0 if non-ddemgr partner   *)
    hszSvcPartner: HSZ;                (*  app name of partner if obtainable   *)
    hszServiceReq: HSZ;                (*  AppName requested for connection   *)
    hszTopic     : HSZ;                (*  Topic name for conversation   *)
    hszItem      : HSZ;                (*  transaction item name or NULL if quiescent   *)
    wFmt         : WD.UINT;    (*  transaction format or NULL if quiescent   *)
    wType        : WD.UINT;    (*  XTYP_ for current transaction   *)
    wStatus      : WD.UINT;    (*  ST_ constant for current conversation   *)
    wConvst      : WD.UINT;    (*  XST_ constant for current transaction   *)
    wLastError   : WD.UINT;    (*  last transaction error.   *)
    hConvList    : HCONVLIST;          (*  parent hConvList if this conversation is in a list  *)
    ConvCtxt     : CONVCONTEXT;        (*  conversation context  *)
    hwnd         : WD.HWND;    (*  window handle for this conversation  *)
    hwndPartner  : WD.HWND;    (*  partner window handle for this conversation  *)
  END;
  PCONVINFO = POINTER TO CONVINFO;



(* ***** API entry points ***** *)
 
  PFNCALLBACK = PROCEDURE [_APICALL] ( wType: WD.UINT; wFmt: WD.UINT; 
			  hConv: HCONV; hsz1: HSZ; hsz2: HSZ; 
	      hData: HDDEDATA; dwData1: WD.DWORD; 
	      dwData2: WD.DWORD ): HDDEDATA;

(*                                             *)
(*  * DDEML public debugging header file info  *)
(*                                             *)

  DDEML_MSG_HOOK_DATA = RECORD [_NOTALIGNED]
    (*  new for NT *)
    uiLo  : WD.UINT;                      (*  unpacked lo and hi parts of lParam *)
    uiHi  : WD.UINT;
    cbData: WD.DWORD;                     (*  amount of data in message; if any. May be > than 32 bytes. *)
    Data  : ARRAY 8 OF WD.DWORD;   (*  data peeking by DDESPY is limited to 32 bytes. *)
  END;
  PDDEML_MSG_HOOK_DATA = POINTER TO DDEML_MSG_HOOK_DATA;

  MONMSGSTRUCT = RECORD [_NOTALIGNED]
    cb    : WD.UINT;
    hwndTo: WD.HWND;
    dwTime: WD.DWORD;
    hTask : WD.HANDLE;
    wMsg  : WD.UINT;
    wParam: WD.WPARAM;
    lParam: WD.LPARAM;
    dmhd  : DDEML_MSG_HOOK_DATA;   (*  new for NT *)
  END;
  PMONMSGSTRUCT = POINTER TO MONMSGSTRUCT;

  MONCBSTRUCT = RECORD [_NOTALIGNED]
    cb     : WD.UINT;
    dwTime : WD.DWORD;
    hTask  : WD.HANDLE;
    dwRet  : WD.DWORD;
    wType  : WD.UINT;
    wFmt   : WD.UINT;
    hConv  : HCONV;
    hsz1   : HSZ;
    hsz2   : HSZ;
    hData  : HDDEDATA;
    dwData1: WD.DWORD;
    dwData2: WD.DWORD;
    cc     : CONVCONTEXT;                          (*  new for NT for XTYP_CONNECT callbacks *)
    cbData : WD.DWORD;                     (*  new for NT for data peeking *)
    Data   : ARRAY 8 OF WD.DWORD;   (*  new for NT for data peeking *)
  END;
  PMONCBSTRUCT = POINTER TO MONCBSTRUCT;

  MONHSZSTRUCTA = RECORD [_NOTALIGNED]
    cb      : WD.UINT;
    fsAction: WD.BOOL;          (*  MH_ value  *)
    dwTime  : WD.DWORD;
    hsz     : HSZ;
    hTask   : WD.HANDLE;
    str     : LONGINT;  (*ARRAY 1 OF CHAR;*)
  END;

  PMONHSZSTRUCTA = POINTER TO MONHSZSTRUCTA;
  MONHSZSTRUCTW = RECORD [_NOTALIGNED]
    cb      : WD.UINT;
    fsAction: WD.BOOL;          (*  MH_ value  *)
    dwTime  : WD.DWORD;
    hsz     : HSZ;
    hTask   : WD.HANDLE;
    str     : LONGINT;  (*ARRAY [1] OF WCHAR;*)
  END;
  PMONHSZSTRUCTW = POINTER TO MONHSZSTRUCTW;
  MONHSZSTRUCT = MONHSZSTRUCTA;    (* ! A *)
  PMONHSZSTRUCT = PMONHSZSTRUCTA;  (* ! A *)

  MONERRSTRUCT = RECORD [_NOTALIGNED]
    cb        : WD.UINT;
    wLastError: WD.UINT;
    dwTime    : WD.DWORD;
    hTask     : WD.HANDLE;
  END;
  PMONERRSTRUCT = POINTER TO MONERRSTRUCT;

  MONLINKSTRUCT = RECORD [_NOTALIGNED]
    cb          : WD.UINT;
    dwTime      : WD.DWORD;
    hTask       : WD.HANDLE;
    fEstablished: WD.BOOL;
    fNoData     : WD.BOOL;
    hszSvc      : HSZ;
    hszTopic    : HSZ;
    hszItem     : HSZ;
    wFmt        : WD.UINT;
    fServer     : WD.BOOL;
    hConvServer : HCONV;
    hConvClient : HCONV;
  END;
  PMONLINKSTRUCT = POINTER TO MONLINKSTRUCT;

  MONCONVSTRUCT = RECORD [_NOTALIGNED]
    cb         : WD.UINT;
    fConnect   : WD.BOOL;
    dwTime     : WD.DWORD;
    hTask      : WD.HANDLE;
    hszSvc     : HSZ;
    hszTopic   : HSZ;
    hConvClient: HCONV;               (*  Globally unique value != apps local hConv *)
    hConvServer: HCONV;               (*  Globally unique value != apps local hConv *)
  END;
  PMONCONVSTRUCT = POINTER TO MONCONVSTRUCT;

(*  DLL registration functions  *)

PROCEDURE [_APICALL] DdeInitializeA ( VAR idInst: WD.DWORD; pfnCallback: PFNCALLBACK;
			   afCmd: WD.DWORD;
			   ulRes: WD.DWORD ): WD.UINT;
PROCEDURE [_APICALL] DdeInitializeW ( VAR idInst: WD.DWORD; pfnCallback: PFNCALLBACK;
			   afCmd: WD.DWORD;
			   ulRes: WD.DWORD ): WD.UINT;
(*  !   DdeInitialize *)


PROCEDURE [_APICALL] DdeUninitialize ( idInst: WD.DWORD ): WD.BOOL;

(*                                        *)
(*  * conversation enumeration functions  *)
(*                                        *)

PROCEDURE [_APICALL] DdeConnectList ( idInst: WD.DWORD; hszService: HSZ; hszTopic: HSZ;
			   hConvList: HCONVLIST; VAR STATICTYPED CC: CONVCONTEXT ): HCONVLIST;

PROCEDURE [_APICALL] DdeQueryNextServer ( hConvList: HCONVLIST; hConvPrev: HCONV ): HCONV;

PROCEDURE [_APICALL] DdeDisconnectList ( hConvList: HCONVLIST ): WD.BOOL;

(*                                    *)
(*  * conversation control functions  *)
(*                                    *)

PROCEDURE [_APICALL] DdeConnect ( idInst: WD.DWORD; hszService: HSZ; hszTopic: HSZ;
		       VAR STATICTYPED CC: CONVCONTEXT ): HCONV;

PROCEDURE [_APICALL] DdeDisconnect ( hConv: HCONV ): WD.BOOL;

PROCEDURE [_APICALL] DdeReconnect ( hConv: HCONV ): HCONV;

PROCEDURE [_APICALL] DdeQueryConvInfo ( hConv: HCONV; idTransaction: WD.DWORD;
			     VAR STATICTYPED ConvInfo: CONVINFO ): WD.UINT;

PROCEDURE [_APICALL] DdeSetUserHandle ( hConv: HCONV; id: WD.DWORD;
			     hUser: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] DdeAbandonTransaction ( idInst: WD.DWORD; hConv: HCONV;
				  idTransaction: WD.DWORD ): WD.BOOL;

(*                                    *)
(*  * app server interface functions  *)
(*                                    *)

PROCEDURE [_APICALL] DdePostAdvise ( idInst: WD.DWORD; hszTopic: HSZ;
			  hszItem: HSZ ): WD.BOOL;

PROCEDURE [_APICALL] DdeEnableCallback ( idInst: WD.DWORD; hConv: HCONV;
			      wCmd: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DdeImpersonateClient ( hConv: HCONV ): WD.BOOL;

PROCEDURE [_APICALL] DdeNameService ( idInst: WD.DWORD; hsz1: HSZ; hsz2: HSZ;
			   afCmd: WD.UINT ): HDDEDATA;

(*                                    *)
(*  * app client interface functions  *)
(*                                    *)

PROCEDURE [_APICALL] DdeClientTransaction (data: WD.LPBYTE; cbData: WD.DWORD;
				 hConv: HCONV; hszItem: HSZ; wFmt: WD.UINT;
				 wType: WD.UINT; dwTimeout: WD.DWORD;
				 VAR pdwResult: WD.DWORD ): HDDEDATA;

(*                            *)
(*  *data transfer functions  *)
(*                            *)

PROCEDURE [_APICALL] DdeCreateDataHandle ( idInst: WD.DWORD; VAR Src: WD.BYTE;
				cb: WD.DWORD; cbOff: WD.DWORD;
				hszItem: HSZ; wFmt: WD.UINT;
				afCmd: WD.UINT ): HDDEDATA;

PROCEDURE [_APICALL] DdeAddData ( hData: HDDEDATA; VAR Src: WD.BYTE; cb: WD.DWORD;
		       cbOff: WD.DWORD ): HDDEDATA;

PROCEDURE [_APICALL] DdeGetData ( hData: HDDEDATA; VAR Dst: WD.BYTE;
		       cbMax: WD.DWORD;
		       cbOff: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] DdeAccessData ( hData: HDDEDATA;
			  VAR cbDataSize: WD.DWORD ): WD.LPBYTE;

PROCEDURE [_APICALL] DdeUnaccessData ( hData: HDDEDATA ): WD.BOOL;

PROCEDURE [_APICALL] DdeFreeDataHandle ( hData: HDDEDATA ): WD.BOOL;

PROCEDURE [_APICALL] DdeGetLastError ( idInst: WD.DWORD ): WD.UINT;

PROCEDURE [_APICALL] DdeCreateStringHandleA ( idInst: WD.DWORD; psz: WD.LPCSTR;
				   iCodePage: LONGINT ): HSZ;
PROCEDURE [_APICALL] DdeCreateStringHandleW ( idInst: WD.DWORD; psz: WD.LPCWSTR;
				   iCodePage: LONGINT ): HSZ;
(*  !   DdeCreateStringHandle *)

PROCEDURE [_APICALL] DdeQueryStringA ( idInst: WD.DWORD; hsz: HSZ; psz: WD.LPSTR;
			    cchMax: WD.DWORD;
			    iCodePage: LONGINT ): WD.DWORD;
PROCEDURE [_APICALL] DdeQueryStringW ( idInst: WD.DWORD; hsz: HSZ;
			    psz: WD.LPWSTR; cchMax: WD.DWORD;
			    iCodePage: LONGINT ): WD.DWORD;
(*  !  DdeQueryString *)

PROCEDURE [_APICALL] DdeFreeStringHandle ( idInst: WD.DWORD; hsz: HSZ ): WD.BOOL;

PROCEDURE [_APICALL] DdeKeepStringHandle ( idInst: WD.DWORD; hsz: HSZ ): WD.BOOL;

PROCEDURE [_APICALL] DdeCmpStringHandles ( hsz1: HSZ; hsz2: HSZ ): LONGINT;


END DDEML.
