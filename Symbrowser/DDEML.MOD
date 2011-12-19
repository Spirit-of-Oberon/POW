DEFINITION DDEML;

IMPORT W:=Windows;


CONST
     DMLERR_NO_ERROR               =     0;       (* must be 0 *)

     DMLERR_FIRST                  =     4000H;

     DMLERR_ADVACKTIMEOUT          =     4000H;
     DMLERR_BUSY                   =     4001H;
     DMLERR_DATAACKTIMEOUT         =     4002H;
     DMLERR_DLL_NOT_INITIALIZED    =     4003H;
     DMLERR_DLL_USAGE              =     4004H;
     DMLERR_EXECACKTIMEOUT         =     4005H;
     DMLERR_INVALIDPARAMETER       =     4006H;
     DMLERR_LOW_MEMORY             =     4007H;
     DMLERR_MEMORY_ERROR           =     4008H;
     DMLERR_NOTPROCESSED           =     4009H;
     DMLERR_NO_CONV_ESTABLISHED    =     400AH;
     DMLERR_POKEACKTIMEOUT         =     400BH;
     DMLERR_POSTMSG_FAILED         =     400CH;
     DMLERR_REENTRANCY             =     400DH;
     DMLERR_SERVER_DIED            =     400EH;
     DMLERR_SYS_ERROR              =     400FH;
     DMLERR_UNADVACKTIMEOUT        =     4010H;
     DMLERR_UNFOUND_QUEUE_ID       =     4011H;
                                              
     DMLERR_LAST                   =     4011H;
     
     QID_SYNC = -00000001H;
     TIMEOUT_ASYNC          = -00000001H;

     APPCMD_CLIENTONLY            =00000010H;
     APPCMD_FILTERINITS           =00000020H;
     APPCMD_MASK                  =00000FF0H;

(*
 * Callback filter flags for use with standard apps.
 *)

     CBF_FAIL_SELFCONNECTIONS     = 00001000H;
     CBF_FAIL_CONNECTIONS         = 00002000H;
     CBF_FAIL_ADVISES             = 00004000H;
     CBF_FAIL_EXECUTES            = 00008000H;
     CBF_FAIL_POKES               = 00010000H;
     CBF_FAIL_REQUESTS            = 00020000H;
     CBF_FAIL_ALLSVRXACTIONS      = 0003F000H;
     CBF_SKIP_CONNECT_CONFIRMS    = 00040000H;
     CBF_SKIP_REGISTRATIONS       = 00080000H;
     CBF_SKIP_UNREGISTRATIONS     = 00100000H;
     CBF_SKIP_DISCONNECTS         = 00200000H;
     CBF_SKIP_ALLNOTIFICATIONS    = 003C0000H;

(*
 * Application classification flags
 *)
     APPCLASS_STANDARD            =00000000H;
     APPCLASS_MASK                =0000000FH;

     WM_DDE_FIRST = 03E0H;
     WM_DDE_INITIATE = WM_DDE_FIRST;
     WM_DDE_TERMINATE = WM_DDE_FIRST+1;
     WM_DDE_ACK = WM_DDE_FIRST+4;
     WM_DDE_DATA = WM_DDE_FIRST+5;
     WM_DDE_REQUEST = WM_DDE_FIRST+6;
     WM_DDE_EXECUTE = WM_DDE_FIRST+8;

     XTYPF_NOBLOCK            =0002H;  
     XTYPF_NODATA             =0004H;  
     XTYPF_ACKREQ             =0008H;  

   (*  XCLASS_MASK              0xFC00 =-... *)
     XCLASS_BOOL              =1000H;
     XCLASS_DATA              =2000H;
     XCLASS_FLAGS             =4000H;
     XCLASS_NOTIFICATION      =-7FFFH;

     XTYP_ERROR              =(0000H + XCLASS_NOTIFICATION + XTYPF_NOBLOCK );
     XTYP_ADVDATA            =(0010H + XCLASS_FLAGS         );
     XTYP_ADVREQ             =(0020H + XCLASS_DATA + XTYPF_NOBLOCK );
     XTYP_ADVSTART           =(0030H + XCLASS_BOOL          );
     XTYP_ADVSTOP            =(0040H + XCLASS_NOTIFICATION);
     XTYP_EXECUTE            =(0050H + XCLASS_FLAGS         );
     XTYP_CONNECT            =(0060H + XCLASS_BOOL + XTYPF_NOBLOCK);
     XTYP_CONNECT_CONFIRM    =(0070H + XCLASS_NOTIFICATION + XTYPF_NOBLOCK);
     XTYP_XACT_COMPLETE      =(0080H + XCLASS_NOTIFICATION  );
     XTYP_POKE               =(0090H + XCLASS_FLAGS         );
     XTYP_REGISTER           =(00A0H + XCLASS_NOTIFICATION + XTYPF_NOBLOCK);
     XTYP_REQUEST            =(00B0H + XCLASS_DATA          );
     XTYP_DISCONNECT         =(00C0H + XCLASS_NOTIFICATION + XTYPF_NOBLOCK);
     XTYP_UNREGISTER         =(00D0H + XCLASS_NOTIFICATION + XTYPF_NOBLOCK);
     XTYP_WILDCONNECT        =(00E0H + XCLASS_DATA + XTYPF_NOBLOCK);

     XTYP_MASK               =00F0H;
     XTYP_SHIFT               =4;

TYPE

  HCONV=LONGINT;
  UINT=INTEGER;
  HDDEDATA=INTEGER;
  DDECALLBACK=PROCEDURE [WINDOWS] (type,fmt:INTEGER; hconv:HCONV; hsz1,hsz2:LONGINT; hData:HDDEDATA; dwData1,dwData2:LONGINT):HDDEDATA;
  CONVCONTEXT=RECORD [WINDOWS]
    cb:UINT;              (* set to sizeof(CONVCONTEXT) *)
    wFlags:UINT;          (* none currently defined. *)
    wCountryID:UINT;      (* country code for topic/item strings used. *)
    iCodePage:INTEGER;    (* codepage used for topic/item strings. *)
    dwLandID:LONGINT;     (* language ID for topic/item strings. *)
    dwSecurity:LONGINT;   (* Private security code. *)
  END;
  PCONVCONTEXT=LONGINT;
  HSZ=LONGINT;
  CONVINFO=RECORD [WINDOWS]
    cb:LONGINT;
    hUser:LONGINT;
    hConvPartner:HCONV;
    hszSvcPartner:HSZ;
    hszServiceReq:HSZ;
    hszTopic:HSZ;
    hszItem:HSZ;
    wFmt:UINT;
    wType:UINT;
    wStatus:UINT;
    wConvst:UINT;
    wLastError:UINT;
    hConvList:LONGINT;
    ConvCtxt:CONVCONTEXT;
  END;  

  PROCEDURE [WINDOWS] DdeInitialize (lpidInst:LONGINT; pfnCallback:LONGINT; atCmd:LONGINT; uRes:LONGINT):LONGINT;
  PROCEDURE [WINDOWS] DdeConnect (idInst:LONGINT; hszService,hszTopic:HSZ;pcc:PCONVCONTEXT):HCONV;
  PROCEDURE [WINDOWS] DdeDisconnect (hConv:HCONV):W.BOOL;
  PROCEDURE [WINDOWS] DdeCreateStringHandle (idInst:LONGINT;lpsz:LONGINT;codepage:INTEGER):HSZ;
  PROCEDURE [WINDOWS] DdeFreeStringHandle (idInst:LONGINT; hsz:HSZ):W.BOOL;
  PROCEDURE [WINDOWS] DdeUninitialize (idInst:LONGINT):W.BOOL;
  PROCEDURE [WINDOWS] DdeQueryConvInfo (hConv:HCONV; idTransaction:LONGINT; lpConvInfo:LONGINT):UINT;
  PROCEDURE [WINDOWS] DdeClientTransaction (lpvData:LONGINT; cbData:W.DWORD; hConv:HCONV; hszItem:HSZ; uFmt:W.UINT; uType:W.UINT; uTimeout:W.DWORD; lpuResult:LONGINT):HDDEDATA;

END DDEML.
