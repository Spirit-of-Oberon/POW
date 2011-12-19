(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION WinBase;                             (**)
(*                                                                            *)
(******************************************************************************)
(* Copyright (c) 1993; Robinson Associates                                    *)
(*                     Red Lion House                                         *)
(*                     St Mary's Street                                       *)
(*                     PAINSWICK                                              *)
(*                     Glos                                                   *)
(*                     GL6  6QR                                               *)
(*                     Tel:    (+44) (0)1452 813 699                          *)
(*                     Fax:    (+44) (0)1452 812 912                          *)
(*                     e-Mail: Oberon@robinsons.co.uk                         *)
(******************************************************************************)
(*  05-30-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(*                                                                            *)
(*    winbase.h -- This module defines the 32-Bit Windows Base APIs           *)
(*                                                                            *)
(******************************************************************************)
IMPORT WN := WinNt, WD := WinDef;

(*  Define API decoration for direct importing of DLL references. *)


CONST 
  INVALID_HANDLE_VALUE = -1;
  INVALID_FILE_SIZE = -1;
  FILE_BEGIN = 0;
  FILE_CURRENT = 1;
  FILE_END = 2;
  TIME_ZONE_ID_INVALID = -1;
  WAIT_FAILED = -1;
  WAIT_OBJECT_0 = (*STATUS_WAIT_0+*)0;
  WAIT_ABANDONED = (*STATUS_ABANDONED_WAIT_0+*)0;
  WAIT_ABANDONED_0 = (*STATUS_ABANDONED_WAIT_0+*)0;

(*  *)
(*  File creation flags must start at the high end since they *)
(*  are combined with the attributes *)
(*  *)
  FILE_FLAG_WRITE_THROUGH = MIN(LONGINT);
  FILE_FLAG_OVERLAPPED = 40000000H;
  FILE_FLAG_NO_BUFFERING = 20000000H;
  FILE_FLAG_RANDOM_ACCESS = 10000000H;
  FILE_FLAG_SEQUENTIAL_SCAN = 8000000H;
  FILE_FLAG_DELETE_ON_CLOSE = 4000000H;
  FILE_FLAG_BACKUP_SEMANTICS = 2000000H;
  FILE_FLAG_POSIX_SEMANTICS = 1000000H;
  CREATE_NEW = 1;
  CREATE_ALWAYS = 2;
  OPEN_EXISTING = 3;
  OPEN_ALWAYS = 4;
  TRUNCATE_EXISTING = 5;

(*  *)
(*  Define possible return codes from the CopyFileEx callback routine *)
(*  *)
  PROGRESS_CONTINUE = 0;
  PROGRESS_CANCEL = 1;
  PROGRESS_STOP = 2;
  PROGRESS_QUIET = 3;

(*  *)
(*  Define CopyFileEx callback routine state change values *)
(*  *)
  CALLBACK_CHUNK_FINISHED = 0H;
  CALLBACK_STREAM_SWITCH = 1H;

(*  *)
(*  Define CopyFileEx option flags *)
(*  *)
  COPY_FILE_FAIL_IF_EXISTS = 1H;
  COPY_FILE_RESTARTABLE = 2H;

(*  *)
(*  Define the NamedPipe definitions *)
(*  *)
(*  *)
(*  Define the dwOpenMode values for CreateNamedPipe *)
(*  *)
  PIPE_ACCESS_INBOUND = 1H;
  PIPE_ACCESS_OUTBOUND = 2H;
  PIPE_ACCESS_DUPLEX = 3H;

(*  *)
(*  Define the Named Pipe End flags for GetNamedPipeInfo *)
(*  *)
  PIPE_CLIENT_END = 0H;
  PIPE_SERVER_END = 1H;

(*  *)
(*  Define the dwPipeMode values for CreateNamedPipe *)
(*  *)
  PIPE_WAIT = 0H;
  PIPE_NOWAIT = 1H;
  PIPE_READMODE_BYTE = 0H;
  PIPE_READMODE_MESSAGE = 2H;
  PIPE_TYPE_BYTE = 0H;
  PIPE_TYPE_MESSAGE = 4H;

(*  *)
(*  Define the well known values for CreateNamedPipe nMaxInstances *)
(*  *)
  PIPE_UNLIMITED_INSTANCES = 255;

(*  *)
(*  Define the Security Quality of Service bits to be passed *)
(*  into CreateFile *)
(*  *)
  SECURITY_ANONYMOUS = 0;
  SECURITY_IDENTIFICATION = 65536;
  SECURITY_IMPERSONATION = 131072;
  SECURITY_DELEGATION = 196608;
  SECURITY_CONTEXT_TRACKING = 40000H;
  SECURITY_EFFECTIVE_ONLY = 80000H;
  SECURITY_SQOS_PRESENT = 100000H;
  SECURITY_VALID_SQOS_FLAGS = 1F0000H;

(*  *)
(*  Serial provider type. *)
(*  *)

  SP_SERIALCOMM = 1;

(*  *)
(*  Provider SubTypes *)
(*  *)
  PST_UNSPECIFIED = 0;
  PST_RS232 = 1;
  PST_PARALLELPORT = 2;
  PST_RS422 = 3;
  PST_RS423 = 4;
  PST_RS449 = 5;
  PST_MODEM = 6;
  PST_FAX = 33;
  PST_SCANNER = 34;
  PST_NETWORK_BRIDGE = 256;
  PST_LAT = 257;
  PST_TCPIP_TELNET = 258;
  PST_X25 = 259;

(*  *)
(*  Provider capabilities flags. *)
(*  *)
  PCF_DTRDSR = 1;
  PCF_RTSCTS = 2;
  PCF_RLSD = 4;
  PCF_PARITY_CHECK = 8;
  PCF_XONXOFF = 16;
  PCF_SETXCHAR = 32;
  PCF_TOTALTIMEOUTS = 64;
  PCF_INTTIMEOUTS = 128;
  PCF_SPECIALCHARS = 256;
  PCF_16BITMODE = 512;

(*  *)
(*  Comm provider settable parameters. *)
(*  *)
  SP_PARITY = 1;
  SP_BAUD = 2;
  SP_DATABITS = 4;
  SP_STOPBITS = 8;
  SP_HANDSHAKING = 16;
  SP_PARITY_CHECK = 32;
  SP_RLSD = 64;

(*  *)
(*  Settable baud rates in the provider. *)
(*  *)
  BAUD_075 = 1;
  BAUD_110 = 2;
  BAUD_134_5 = 4;
  BAUD_150 = 8;
  BAUD_300 = 16;
  BAUD_600 = 32;
  BAUD_1200 = 64;
  BAUD_1800 = 128;
  BAUD_2400 = 256;
  BAUD_4800 = 512;
  BAUD_7200 = 1024;
  BAUD_9600 = 2048;
  BAUD_14400 = 4096;
  BAUD_19200 = 8192;
  BAUD_38400 = 16384;
  BAUD_56K = 32768;
  BAUD_128K = 65536;
  BAUD_115200 = 131072;
  BAUD_57600 = 262144;
  BAUD_USER = 268435456;

(*  *)
(*  Settable Data Bits *)
(*  *)
  DATABITS_5 = 1;
  DATABITS_6 = 2;
  DATABITS_7 = 4;
  DATABITS_8 = 8;
  DATABITS_16 = 16;
  DATABITS_16X = 32;

(*  *)
(*  Settable Stop and Parity bits. *)
(*  *)
  STOPBITS_10 = 1;
  STOPBITS_15 = 2;
  STOPBITS_20 = 4;
  PARITY_NONE = 256;
  PARITY_ODD = 512;
  PARITY_EVEN = 1024;
  PARITY_MARK = 2048;
  PARITY_SPACE = 4096;

  COMMPROP_INITIALIZED = -415435474;

(*  *)
(*  DTR Control Flow Values. *)
(*  *)

  DTR_CONTROL_DISABLE = 0H;
  DTR_CONTROL_ENABLE = 1H;
  DTR_CONTROL_HANDSHAKE = 2H;

(*  *)
(*  RTS Control Flow Values *)
(*  *)
  RTS_CONTROL_DISABLE = 0H;
  RTS_CONTROL_ENABLE = 1H;
  RTS_CONTROL_HANDSHAKE = 2H;
  RTS_CONTROL_TOGGLE = 3H;



(*  Global Memory Flags  *)

  GMEM_FIXED = 0H;
  GMEM_MOVEABLE = 2H;
  GMEM_NOCOMPACT = 10H;
  GMEM_NODISCARD = 20H;
  GMEM_ZEROINIT = 40H;
  GMEM_MODIFY = 80H;
  GMEM_DISCARDABLE = 100H;
  GMEM_NOT_BANKED = 1000H;
  GMEM_LOWER = GMEM_NOT_BANKED;
  GMEM_SHARE = 2000H;
  GMEM_DDESHARE = 2000H;
  GMEM_NOTIFY = 4000H;
  GMEM_VALID_FLAGS = 7F72H;
  GMEM_INVALID_HANDLE = 8000H;
  GHND = 66;
  GPTR = 64;

(*  Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE)  *)

  GMEM_DISCARDED = 4000H;
  GMEM_LOCKCOUNT = 0FFH;
(*  Local Memory Flags  *)

  LMEM_FIXED = 0H;
  LMEM_MOVEABLE = 2H;
  LMEM_NOCOMPACT = 10H;
  LMEM_NODISCARD = 20H;
  LMEM_ZEROINIT = 40H;
  LMEM_MODIFY = 80H;
  LMEM_DISCARDABLE = 0F00H;
  LMEM_VALID_FLAGS = 0F72H;
  LMEM_INVALID_HANDLE = 8000H;
  LHND = 66;
  LPTR = 64;
  NONZEROLHND = LMEM_MOVEABLE;
  NONZEROLPTR = LMEM_FIXED;

(*  Flags returned by LocalFlags (in addition to LMEM_DISCARDABLE)  *)

  LMEM_DISCARDED = 4000H;
  LMEM_LOCKCOUNT = 0FFH;

(*  *)
(*  dwCreationFlag values *)
(*  *)
  DEBUG_PROCESS = 1H;
  DEBUG_ONLY_THIS_PROCESS = 2H;
  CREATE_SUSPENDED = 4H;
  DETACHED_PROCESS = 8H;
  CREATE_NEW_CONSOLE = 10H;
  NORMAL_PRIORITY_CLASS = 20H;
  IDLE_PRIORITY_CLASS = 40H;
  HIGH_PRIORITY_CLASS = 80H;
  REALTIME_PRIORITY_CLASS = 100H;
  CREATE_NEW_PROCESS_GROUP = 200H;
  CREATE_UNICODE_ENVIRONMENT = 400H;
  CREATE_SEPARATE_WOW_VDM = 800H;
  CREATE_SHARED_WOW_VDM = 1000H;
  CREATE_DEFAULT_ERROR_MODE = 4000000H;
  CREATE_NO_WINDOW = 8000000H;
  PROFILE_USER = 10000000H;
  PROFILE_KERNEL = 20000000H;
  PROFILE_SERVER = 40000000H;
  THREAD_PRIORITY_NORMAL = 0;
  THREAD_PRIORITY_ERROR_RETURN = MAX(LONGINT);

(*  *)
(*  Debug APIs *)
(*  *)
  EXCEPTION_DEBUG_EVENT = 1;
  CREATE_THREAD_DEBUG_EVENT = 2;
  CREATE_PROCESS_DEBUG_EVENT = 3;
  EXIT_THREAD_DEBUG_EVENT = 4;
  EXIT_PROCESS_DEBUG_EVENT = 5;
  LOAD_DLL_DEBUG_EVENT = 6;
  UNLOAD_DLL_DEBUG_EVENT = 7;
  OUTPUT_DEBUG_STRING_EVENT = 8;
  RIP_EVENT = 9;

  DRIVE_UNKNOWN = 0;
  DRIVE_NO_ROOT_DIR = 1;
  DRIVE_REMOVABLE = 2;
  DRIVE_FIXED = 3;
  DRIVE_REMOTE = 4;
  DRIVE_CDROM = 5;
  DRIVE_RAMDISK = 6;

  FILE_TYPE_UNKNOWN = 0H;
  FILE_TYPE_DISK = 1H;
  FILE_TYPE_CHAR = 2H;
  FILE_TYPE_PIPE = 3H;
  FILE_TYPE_REMOTE = 8000H;
  STD_INPUT_HANDLE = -10;
  STD_OUTPUT_HANDLE = -11;
  STD_ERROR_HANDLE = -12;
  NOPARITY = 0;
  ODDPARITY = 1;
  EVENPARITY = 2;
  MARKPARITY = 3;
  SPACEPARITY = 4;
  ONESTOPBIT = 0;
  ONE5STOPBITS = 1;
  TWOSTOPBITS = 2;
  IGNORE = 0;                          (*  Ignore signal *)
  INFINITE = -1H;               (*  Infinite timeout *)

(*  *)
(*  Baud rates at which the communication device operates *)
(*  *)
  CBR_110 = 110;
  CBR_300 = 300;
  CBR_600 = 600;
  CBR_1200 = 1200;
  CBR_2400 = 2400;
  CBR_4800 = 4800;
  CBR_9600 = 9600;
  CBR_14400 = 14400;
  CBR_19200 = 19200;
  CBR_38400 = 38400;
  CBR_56000 = 56000;
  CBR_57600 = 57600;
  CBR_115200 = 115200;
  CBR_128000 = 128000;
  CBR_256000 = 256000;

(*  *)
(*  Error Flags *)
(*  *)
  CE_RXOVER = 1H;                      (*  Receive Queue overflow *)
  CE_OVERRUN = 2H;                     (*  Receive Overrun Error *)
  CE_RXPARITY = 4H;                    (*  Receive Parity Error *)
  CE_FRAME = 8H;                       (*  Receive Framing error *)
  CE_BREAK = 10H;                      (*  Break Detected *)
  CE_TXFULL = 100H;                    (*  TX Queue is full *)
  CE_PTO = 200H;                       (*  LPTx Timeout *)
  CE_IOE = 400H;                       (*  LPTx I/O Error *)
  CE_DNS = 800H;                       (*  LPTx Device not selected *)
  CE_OOP = 1000H;                      (*  LPTx Out-Of-Paper *)
  CE_MODE = 8000H;                     (*  Requested mode unsupported *)
  IE_BADID = -1;                       (*  Invalid or unsupported id *)
  IE_OPEN = -2;                        (*  Device Already Open *)
  IE_NOPEN = -3;                       (*  Device Not Open *)
  IE_MEMORY = -4;                      (*  Unable to allocate queues *)
  IE_DEFAULT = -5;                     (*  Error in default parameters *)
  IE_HARDWARE = -10;                   (*  Hardware Not Present *)
  IE_BYTESIZE = -11;                   (*  Illegal Byte Size *)
  IE_BAUDRATE = -12;                   (*  Unsupported BaudRate *)

(*  *)
(*  Events *)
(*  *)
  EV_RXCHAR = 1H;                      (*  Any Character received *)
  EV_RXFLAG = 2H;                      (*  Received certain character *)
  EV_TXEMPTY = 4H;                     (*  Transmitt Queue Empty *)
  EV_CTS = 8H;                         (*  CTS changed state *)
  EV_DSR = 10H;                        (*  DSR changed state *)
  EV_RLSD = 20H;                       (*  RLSD changed state *)
  EV_BREAK = 40H;                      (*  BREAK received *)
  EV_ERR = 80H;                        (*  Line status error occurred *)
  EV_RING = 100H;                      (*  Ring signal detected *)
  EV_PERR = 200H;                      (*  Printer error occured *)
  EV_RX80FULL = 400H;                  (*  Receive buffer is 80 percent full *)
  EV_EVENT1 = 800H;                    (*  Provider specific event 1 *)
  EV_EVENT2 = 1000H;                   (*  Provider specific event 2 *)

(*  *)
(*  Escape Functions *)
(*  *)
  SETXOFF = 1;                         (*  Simulate XOFF received *)
  SETXON = 2;                          (*  Simulate XON received *)
  SETRTS = 3;                          (*  Set RTS high *)
  CLRRTS = 4;                          (*  Set RTS low *)
  SETDTR = 5;                          (*  Set DTR high *)
  CLRDTR = 6;                          (*  Set DTR low *)
  RESETDEV = 7;                        (*  Reset device if possible *)
  SETBREAK = 8;                        (*  Set the device break line. *)
  CLRBREAK = 9;                        (*  Clear the device break line. *)

(*  *)
(*  PURGE function flags. *)
(*  *)
  PURGE_TXABORT = 1H;                  (*  Kill the pending/current writes to the comm port. *)
  PURGE_RXABORT = 2H;                  (*  Kill the pending/current reads to the comm port. *)
  PURGE_TXCLEAR = 4H;                  (*  Kill the transmit queue if there. *)
  PURGE_RXCLEAR = 8H;                  (*  Kill the typeahead buffer if there. *)
  LPTx = 80H;                          (*  Set if ID is for LPT device *)

(*  *)
(*  Modem Status Flags *)
(*  *)
  MS_CTS_ON = 16;
  MS_DSR_ON = 32;
  MS_RING_ON = 64;
  MS_RLSD_ON = 128;

(*  *)
(*  WaitSoundState() Constants *)
(*  *)
  S_QUEUEEMPTY = 0;
  S_THRESHOLD = 1;
  S_ALLTHRESHOLD = 2;

(*  *)
(*  Accent Modes *)
(*  *)
  S_NORMAL = 0;
  S_LEGATO = 1;
  S_STACCATO = 2;

(*  *)
(*  SetSoundNoise() Sources *)
(*  *)
  S_PERIOD512 = 0;                     (*  Freq = N/512 high pitch; less coarse hiss *)
  S_PERIOD1024 = 1;                    (*  Freq = N/1024 *)
  S_PERIOD2048 = 2;                    (*  Freq = N/2048 low pitch; more coarse hiss *)
  S_PERIODVOICE = 3;                   (*  Source is frequency from voice channel (3) *)
  S_WHITE512 = 4;                      (*  Freq = N/512 high pitch; less coarse hiss *)
  S_WHITE1024 = 5;                     (*  Freq = N/1024 *)
  S_WHITE2048 = 6;                     (*  Freq = N/2048 low pitch; more coarse hiss *)
  S_WHITEVOICE = 7;                    (*  Source is frequency from voice channel (3) *)
  S_SERDVNA = -1;                      (*  Device not available *)
  S_SEROFM = -2;                       (*  Out of memory *)
  S_SERMACT = -3;                      (*  Music active *)
  S_SERQFUL = -4;                      (*  Queue full *)
  S_SERBDNT = -5;                      (*  Invalid note *)
  S_SERDLN = -6;                       (*  Invalid note length *)
  S_SERDCC = -7;                       (*  Invalid note count *)
  S_SERDTP = -8;                       (*  Invalid tempo *)
  S_SERDVL = -9;                       (*  Invalid volume *)
  S_SERDMD = -10;                      (*  Invalid mode *)
  S_SERDSH = -11;                      (*  Invalid shape *)
  S_SERDPT = -12;                      (*  Invalid pitch *)
  S_SERDFQ = -13;                      (*  Invalid frequency *)
  S_SERDDR = -14;                      (*  Invalid duration *)
  S_SERDSR = -15;                      (*  Invalid source *)
  S_SERDST = -16;                      (*  Invalid state *)
  NMPWAIT_WAIT_FOREVER = -1H;
  NMPWAIT_NOWAIT = 1H;
  NMPWAIT_USE_DEFAULT_WAIT = 0H;
  OF_READ = 0H;
  OF_WRITE = 1H;
  OF_READWRITE = 2H;
  OF_SHARE_COMPAT = 0H;
  OF_SHARE_EXCLUSIVE = 10H;
  OF_SHARE_DENY_WRITE = 20H;
  OF_SHARE_DENY_READ = 30H;
  OF_SHARE_DENY_NONE = 40H;
  OF_PARSE = 100H;
  OF_DELETE = 200H;
  OF_VERIFY = 400H;
  OF_CANCEL = 800H;
  OF_CREATE = 1000H;
  OF_PROMPT = 2000H;
  OF_EXIST = 4000H;
  OF_REOPEN = 8000H;
  OFS_MAXPATHNAME = 128;

  MAXINTATOM = 0C000H;

  INVALID_ATOM = 0;

  PROCESS_HEAP_REGION = 1H;
  PROCESS_HEAP_UNCOMMITTED_RANGE = 2H;
  PROCESS_HEAP_ENTRY_BUSY = 4H;
  PROCESS_HEAP_ENTRY_MOVEABLE = 10H;
  PROCESS_HEAP_ENTRY_DDESHARE = 20H;

(*  GetBinaryType return values. *)

  SCS_32BIT_BINARY = 0;
  SCS_DOS_BINARY = 1;
  SCS_WOW_BINARY = 2;
  SCS_PIF_BINARY = 3;
  SCS_POSIX_BINARY = 4;
  SCS_OS216_BINARY = 5;
 
  SEM_FAILCRITICALERRORS = 1H;
  SEM_NOGPFAULTERRORBOX = 2H;
  SEM_NOALIGNMENTFAULTEXCEPT = 4H;
  SEM_NOOPENFILEERRORBOX = 8000H;

  LOCKFILE_FAIL_IMMEDIATELY = 1H;
  LOCKFILE_EXCLUSIVE_LOCK = 2H;
 
  HANDLE_FLAG_INHERIT = 1H;
  HANDLE_FLAG_PROTECT_FROM_CLOSE = 2H;
  HINSTANCE_ERROR = 32;
 
  GET_TAPE_MEDIA_INFORMATION = 0;
  GET_TAPE_DRIVE_INFORMATION = 1;
 
  SET_TAPE_MEDIA_INFORMATION = 0;
  SET_TAPE_DRIVE_INFORMATION = 1;
 
  FORMAT_MESSAGE_ALLOCATE_BUFFER = 100H;
  FORMAT_MESSAGE_IGNORE_INSERTS = 200H;
  FORMAT_MESSAGE_FROM_STRING = 400H;
  FORMAT_MESSAGE_FROM_HMODULE = 800H;
  FORMAT_MESSAGE_FROM_SYSTEM = 1000H;
  FORMAT_MESSAGE_ARGUMENT_ARRAY = 2000H;
  FORMAT_MESSAGE_MAX_WIDTH_MASK = 0FFH;

(*  *)
(*   Stream Ids *)
(*  *)

  BACKUP_INVALID = 0H;
  BACKUP_DATA = 1H;
  BACKUP_EA_DATA = 2H;
  BACKUP_SECURITY_DATA = 3H;
  BACKUP_ALTERNATE_DATA = 4H;
  BACKUP_LINK = 5H;
  BACKUP_PROPERTY_DATA = 6H;

(*  *)
(*   Stream Attributes *)
(*  *)
  STREAM_NORMAL_ATTRIBUTE = 0H;
  STREAM_MODIFIED_WHEN_READ = 1H;
  STREAM_CONTAINS_SECURITY = 2H;
  STREAM_CONTAINS_PROPERTIES = 4H;

(*  *)
(*  Dual Mode API below this line. Dual Mode Structures also included. *)
(*  *)
  STARTF_USESHOWWINDOW = 1H;
  STARTF_USESIZE = 2H;
  STARTF_USEPOSITION = 4H;
  STARTF_USECOUNTCHARS = 8H;
  STARTF_USEFILLATTRIBUTE = 10H;
  STARTF_RUNFULLSCREEN = 20H;          (*  ignored for non-x86 platforms *)
  STARTF_FORCEONFEEDBACK = 40H;
  STARTF_FORCEOFFFEEDBACK = 80H;
  STARTF_USESTDHANDLES = 100H;

  STARTF_USEHOTKEY = 200H;
 
  TLS_OUT_OF_INDEXES = -1;
 
  SHUTDOWN_NORETRY = 1H;
 
  DONT_RESOLVE_DLL_REFERENCES = 1H;
  LOAD_LIBRARY_AS_DATAFILE = 2H;
  LOAD_WITH_ALTERED_SEARCH_PATH = 8H;

  GetFileExInfoStandard = 0;
  GetFileExMaxInfoLevel = 1;
 
  FindExInfoStandard = 0;
  FindExInfoMaxInfoLevel = 1;
 
  FIND_FIRST_EX_CASE_SENSITIVE = 1H;
 
  MOVEFILE_REPLACE_EXISTING = 1H;
  MOVEFILE_COPY_ALLOWED = 2H;
  MOVEFILE_DELAY_UNTIL_REBOOT = 4H;
  MOVEFILE_WRITE_THROUGH = 8H;
 
  MAX_COMPUTERNAME_LENGTH = 15;

(*  *)
(*  Logon Support APIs *)
(*  *)

  LOGON32_LOGON_INTERACTIVE = 2;
  LOGON32_LOGON_BATCH = 4;
  LOGON32_LOGON_SERVICE = 5;
  LOGON32_PROVIDER_DEFAULT = 0;
  LOGON32_PROVIDER_WINNT35 = 1;
  LOGON32_PROVIDER_WINNT40 = 2;


(*  *)
(*  Plug-and-Play API's *)
(*  *)

  HW_PROFILE_GUIDLEN = 39;             (*  36-characters plus NULL terminator *)
  MAX_PROFILE_LEN = 80;
  DOCKINFO_UNDOCKED = 1H;
  DOCKINFO_DOCKED = 2H;
  DOCKINFO_USER_SUPPLIED = 4H;
  DOCKINFO_USER_UNDOCKED = 5;
  DOCKINFO_USER_DOCKED = 6;

(*  *)
(*  dwPlatformId defines: *)
(*  *)
 
  VER_PLATFORM_WIN32s = 0;
  VER_PLATFORM_WIN32_WINDOWS = 1;
  VER_PLATFORM_WIN32_NT = 2;

(*  Abnormal termination codes  *)
 
  TC_NORMAL = 0;
  TC_HARDERR = 1;
  TC_GP_TRAP = 2;
  TC_SIGNAL = 3;

(* (WINVER >= 0x0400) *)
(*  *)
(*  Power Management APIs *)
(*  *)
  AC_LINE_OFFLINE = 0H;
  AC_LINE_ONLINE = 1H;
  AC_LINE_BACKUP_POWER = 2H;
  AC_LINE_UNKNOWN = 0FFH;
  BATTERY_FLAG_HIGH = 1H;
  BATTERY_FLAG_LOW = 2H;
  BATTERY_FLAG_CRITICAL = 4H;
  BATTERY_FLAG_CHARGING = 8H;
  BATTERY_FLAG_NO_BATTERY = 80H;
  BATTERY_FLAG_UNKNOWN = 0FFH;
  BATTERY_PERCENTAGE_UNKNOWN = 0FFH;
  BATTERY_LIFE_UNKNOWN = -1H;

(*  *)
(*  Currently; the only defined certificate revision is WIN_CERT_REVISION_1_0 *)
(*  *)
  WIN_CERT_REVISION_1_0 = 100H;

(*  *)
(*  Possible certificate types are specified by the following values *)
(*  *)
  WIN_CERT_TYPE_X509 = 1H;             (*  bCertificate contains an X.509 Certificate *)
  WIN_CERT_TYPE_PKCS_SIGNED_DATA = 2H; (*  bCertificate contains a PKCS SignedData structure *)
  WIN_CERT_TYPE_RESERVED_1 = 3H;       (*  Reserved *)
 
  DDD_RAW_TARGET_PATH = 1H;
  DDD_REMOVE_DEFINITION = 2H;
  DDD_EXACT_MATCH_ON_REMOVE = 4H;
  DDD_NO_BROADCAST_SYSTEM = 8H;
 
  FindExSearchNameMatch = 0;
  FindExSearchLimitToDirectories = 1;
  FindExSearchLimitToDevices = 2;
  FindExSearchMaxSearchOp = 3;
 


(*  *)
(*   File structures *)
(*  *)

TYPE 
  OVERLAPPED = RECORD [_NOTALIGNED]
    Internal    : WD.DWORD;
    InternalHigh: WD.DWORD;
    Offset      : WD.DWORD;
    OffsetHigh  : WD.DWORD;
    hEvent      : WD.HANDLE;
  END;
  LPOVERLAPPED = POINTER TO OVERLAPPED;

  SECURITY_ATTRIBUTES = RECORD [_NOTALIGNED]
    nLength             : WD.DWORD;
    lpSecurityDescriptor: WD.LPVOID;
    bInheritHandle      : WD.BOOL;
  END;
  PSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;
  LPSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;

  PROCESS_INFORMATION = RECORD [_NOTALIGNED]
    hProcess   : WD.HANDLE;
    hThread    : WD.HANDLE;
    dwProcessId: WD.DWORD;
    dwThreadId : WD.DWORD;
  END;
  PPROCESS_INFORMATION = POINTER TO PROCESS_INFORMATION;
  LPPROCESS_INFORMATION = POINTER TO PROCESS_INFORMATION;

(*  *)
(*   File System time stamps are represented with the following structure: *)
(*  *)

  FILETIME = RECORD [_NOTALIGNED]
    dwLowDateTime : WD.DWORD;
    dwHighDateTime: WD.DWORD;
  END;
  PFILETIME = POINTER TO FILETIME;
  LPFILETIME = POINTER TO FILETIME;

(*  *)
(*  System time is represented with the following structure: *)
(*  *)

  SYSTEMTIME = RECORD [_NOTALIGNED]
    wYear        : WD.WORD;
    wMonth       : WD.WORD;
    wDayOfWeek   : WD.WORD;
    wDay         : WD.WORD;
    wHour        : WD.WORD;
    wMinute      : WD.WORD;
    wSecond      : WD.WORD;
    wMilliseconds: WD.WORD;
  END;
  PSYSTEMTIME = POINTER TO SYSTEMTIME;
  LPSYSTEMTIME = POINTER TO SYSTEMTIME;

  PTHREAD_START_ROUTINE = PROCEDURE [_APICALL] ( lpThreadParameter: WD.LPVOID ): WD.DWORD; 
  LPTHREAD_START_ROUTINE = PTHREAD_START_ROUTINE;
  PFIBER_START_ROUTINE = PROCEDURE [_APICALL] ( lpFiberParameter: WD.LPVOID );
  LPFIBER_START_ROUTINE = PFIBER_START_ROUTINE;

  CRITICAL_SECTION = WN.RTL_CRITICAL_SECTION;
  PCRITICAL_SECTION = WN.PRTL_CRITICAL_SECTION;
  LPCRITICAL_SECTION = PCRITICAL_SECTION;
  CRITICAL_SECTION_DEBUG = WN.RTL_CRITICAL_SECTION_DEBUG;
  PCRITICAL_SECTION_DEBUG = WN.PRTL_CRITICAL_SECTION_DEBUG;
  LPCRITICAL_SECTION_DEBUG = PCRITICAL_SECTION_DEBUG;


  LPLDT_ENTRY = WN.PLDT_ENTRY;

  COMMPROP = RECORD [_NOTALIGNED]
    wPacketLength      : WD.WORD;
    wPacketVersion     : WD.WORD;
    dwServiceMask      : WD.DWORD;
    dwReserved1        : WD.DWORD;
    dwMaxTxQueue       : WD.DWORD;
    dwMaxRxQueue       : WD.DWORD;
    dwMaxBaud          : WD.DWORD;
    dwProvSubType      : WD.DWORD;
    dwProvCapabilities : WD.DWORD;
    dwSettableParams   : WD.DWORD;
    dwSettableBaud     : WD.DWORD;
    wSettableData      : WD.WORD;
    wSettableStopParity: WD.WORD;
    dwCurrentTxQueue   : WD.DWORD;
    dwCurrentRxQueue   : WD.DWORD;
    dwProvSpec1        : WD.DWORD;
    dwProvSpec2        : WD.DWORD;
    wcProvChar         : LONGINT;  (*ARRAY [1] OF WD.WCHAR;*)
  END;
  LPCOMMPROP = POINTER TO COMMPROP;

(*  *)
(*  Set dwProvSpec1 to COMMPROP_INITIALIZED to indicate that wPacketLength *)
(*  is valid before a call to GetCommProperties(). *)
(*  *)
(* BITFIELD *)
  COMSTAT = RECORD [_NOTALIGNED]
    data     : LONGINT;
    cbInQue  : WD.DWORD;
    cbOutQue : WD.DWORD;
  END;
(*  COMSTAT = RECORD [_NOTALIGNED]
<* IF __GEN_C__ THEN *>
    fCtsHold : WD.DWORD;       (* H2D: bit field. fCtsHold:1 *)
    fDsrHold : WD.DWORD;       (* H2D: bit field. fDsrHold:1 *)
    fRlsdHold: WD.DWORD;       (* H2D: bit field. fRlsdHold:1 *)
    fXoffHold: WD.DWORD;       (* H2D: bit field. fXoffHold:1 *)
    fXoffSent: WD.DWORD;       (* H2D: bit field. fXoffSent:1 *)
    fEof     : WD.DWORD;       (* H2D: bit field. fEof:1 *)
    fTxim    : WD.DWORD;       (* H2D: bit field. fTxim:1 *)
    fReserved: WD.DWORD;       (* H2D: bit field. fReserved:25 *)
<* ELSE *>
    fCtsHold : PACKEDSET OF [0..31];   (* H2D: bit field. fCtsHold:1; fDsrHold:1; fRlsdHold:1; fXoffHold:1; fXoffSent:1; fEof:1; fTxim:1; fReserved:25. *)
<* END *>
    cbInQue  : WD.DWORD;
    cbOutQue : WD.DWORD;
  END;
*)
  LPCOMSTAT = POINTER TO COMSTAT;
(* BITFIELD*)
  DCB = RECORD [_NOTALIGNED]
    DCBlength        : WD.DWORD;       (*  sizeof(DCB)                      *)
    BaudRate         : WD.DWORD;       (*  Baudrate at which running        *)
  data             : LONGINT;
    wReserved        : WD.WORD;        (*  Not currently used               *)
    XonLim           : WD.WORD;        (*  Transmit X-ON threshold          *)
    XoffLim          : WD.WORD;        (*  Transmit X-OFF threshold         *)
    ByteSize         : WD.BYTE;        (*  Number of bits/byte; 4-8         *)
    Parity           : WD.BYTE;        (*  0-4=None;Odd;Even;Mark;Space     *)
    StopBits         : WD.BYTE;        (*  0;1;2 = 1; 1.5; 2                *)
    XonChar          : CHAR;                   (*  Tx and Rx X-ON character         *)
    XoffChar         : CHAR;                   (*  Tx and Rx X-OFF character        *)
    ErrorChar        : CHAR;                   (*  Error replacement char           *)
    EofChar          : CHAR;                   (*  End of Input character           *)
    EvtChar          : CHAR;                   (*  Received Event character         *)
    wReserved1       : WD.WORD;        (*  Fill for now.                    *)
  END;
(*
  _DCB = RECORD [_NOTALIGNED]
    DCBlength        : WD.DWORD;       (*  sizeof(DCB)                      *)
    BaudRate         : WD.DWORD;       (*  Baudrate at which running        *)
<* IF __GEN_C__ THEN *>
    fBinary          : WD.DWORD;       (* H2D: bit field. fBinary:1 *)
                                               (*  Binary Mode (skip EOF check)     *)
    fParity          : WD.DWORD;       (* H2D: bit field. fParity:1 *)
                                               (*  Enable parity checking           *)
    fOutxCtsFlow     : WD.DWORD;       (* H2D: bit field. fOutxCtsFlow:1 *)
                                               (*  CTS handshaking on output        *)
    fOutxDsrFlow     : WD.DWORD;       (* H2D: bit field. fOutxDsrFlow:1 *)
                                               (*  DSR handshaking on output        *)
    fDtrControl      : WD.DWORD;       (* H2D: bit field. fDtrControl:2 *)
                                               (*  DTR Flow control                 *)
    fDsrSensitivity  : WD.DWORD;       (* H2D: bit field. fDsrSensitivity:1 *)
                                               (*  DSR Sensitivity               *)
    fTXContinueOnXoff: WD.DWORD;       (* H2D: bit field. fTXContinueOnXoff:1 *)
                                               (*  Continue TX when Xoff sent  *)
    fOutX            : WD.DWORD;       (* H2D: bit field. fOutX:1 *)
                                               (*  Enable output X-ON/X-OFF         *)
    fInX             : WD.DWORD;       (* H2D: bit field. fInX:1 *)
                                               (*  Enable input X-ON/X-OFF          *)
    fErrorChar       : WD.DWORD;       (* H2D: bit field. fErrorChar:1 *)
                                               (*  Enable Err Replacement           *)
    fNull            : WD.DWORD;       (* H2D: bit field. fNull:1 *)
                                               (*  Enable Null stripping            *)
    fRtsControl      : WD.DWORD;       (* H2D: bit field. fRtsControl:2 *)
                                               (*  Rts Flow control                 *)
    fAbortOnError    : WD.DWORD;       (* H2D: bit field. fAbortOnError:1 *)
                                               (*  Abort all reads and writes on Error  *)
    fDummy2          : WD.DWORD;       (* H2D: bit field. fDummy2:17 *)
                                               (*  Reserved                         *)
<* ELSE *>
    fBinary          : PACKEDSET OF [0..31];   (* H2D: bit field. fBinary:1; fParity:1; fOutxCtsFlow:1; fOutxDsrFlow:1; fDtrControl:2; fDsrSensitivity:1; fTXContinueOnXoff:1; fOutX:1; fInX:1; fErrorChar:1; fNull:1; fRtsControl:2; fAbortOnError:1; fDummy2:17. *)
                                               (*  Binary Mode (skip EOF check)     *)
                                               (*  Enable parity checking           *)
                                               (*  CTS handshaking on output        *)
                                               (*  DSR handshaking on output        *)
                                               (*  DTR Flow control                 *)
                                               (*  DSR Sensitivity               *)
                                               (*  Continue TX when Xoff sent  *)
                                               (*  Enable output X-ON/X-OFF         *)
                                               (*  Enable input X-ON/X-OFF          *)
                                               (*  Enable Err Replacement           *)
                                               (*  Enable Null stripping            *)
                                               (*  Rts Flow control                 *)
                                               (*  Abort all reads and writes on Error  *)
                                               (*  Reserved                         *)
<* END *>
    wReserved        : WD.WORD;        (*  Not currently used               *)
    XonLim           : WD.WORD;        (*  Transmit X-ON threshold          *)
    XoffLim          : WD.WORD;        (*  Transmit X-OFF threshold         *)
    ByteSize         : WD.BYTE;        (*  Number of bits/byte; 4-8         *)
    Parity           : WD.BYTE;        (*  0-4=None;Odd;Even;Mark;Space     *)
    StopBits         : WD.BYTE;        (*  0;1;2 = 1; 1.5; 2                *)
    XonChar          : CHAR;                   (*  Tx and Rx X-ON character         *)
    XoffChar         : CHAR;                   (*  Tx and Rx X-OFF character        *)
    ErrorChar        : CHAR;                   (*  Error replacement char           *)
    EofChar          : CHAR;                   (*  End of Input character           *)
    EvtChar          : CHAR;                   (*  Received Event character         *)
    wReserved1       : WD.WORD;        (*  Fill for now.                    *)
  END;
*)
  LPDCB = POINTER TO DCB;

  COMMTIMEOUTS = RECORD [_NOTALIGNED]
    ReadIntervalTimeout        : WD.DWORD;   (*  Maximum time between read chars.  *)
    ReadTotalTimeoutMultiplier : WD.DWORD;   (*  Multiplier of characters.         *)
    ReadTotalTimeoutConstant   : WD.DWORD;   (*  Constant in milliseconds.         *)
    WriteTotalTimeoutMultiplier: WD.DWORD;   (*  Multiplier of characters.         *)
    WriteTotalTimeoutConstant  : WD.DWORD;   (*  Constant in milliseconds.         *)
  END;
  LPCOMMTIMEOUTS = POINTER TO COMMTIMEOUTS;

  COMMCONFIG = RECORD [_NOTALIGNED]
    dwSize           : WD.DWORD;                     (*  Size of the entire struct  *)
    wVersion         : WD.WORD;                      (*  version of the structure  *)
    wReserved        : WD.WORD;                      (*  alignment  *)
    dcb              : DCB;                                  (*  device control block  *)
    dwProviderSubType: WD.DWORD;                     (*  ordinal value for identifying           *)
                                                             (*  provider-defined data structure format  *)
    dwProviderOffset : WD.DWORD;                     (*  Specifies the offset of provider specific  *)
                                                             (*  data field in bytes from the start         *)
    dwProviderSize   : WD.DWORD;                     (*  size of the provider-specific data field  *)
    wcProviderData   : LONGINT;  (*ARRAY [1] OF WD.WCHAR;*)   (*  provider-specific data  *)
  END;
  LPCOMMCONFIG = POINTER TO COMMCONFIG;

  winbase_Struct = RECORD [_NOTALIGNED]
    wProcessorArchitecture: WD.WORD;
    wReserved             : WD.WORD;
  END;
 (* UNION
  winbase_Union = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: dwOemId: WD.DWORD;         (*  Obsolete field...do not use *)
      |1: u      : winbase_Struct;
    END;
  END;
 *)
  winbase_Union = RECORD [_NOTALIGNED]
     dwOemId: ARRAY 4 OF WD.BYTE;         (*  Obsolete field...do not use *)
  END;

  SYSTEM_INFO = RECORD [_NOTALIGNED]
    d                          : winbase_Union;
    dwPageSize                 : WD.DWORD;
    lpMinimumApplicationAddress: WD.LPVOID;
    lpMaximumApplicationAddress: WD.LPVOID;
    dwActiveProcessorMask      : WD.DWORD;
    dwNumberOfProcessors       : WD.DWORD;
    dwProcessorType            : WD.DWORD;
    dwAllocationGranularity    : WD.DWORD;
    wProcessorLevel            : WD.WORD;
    wProcessorRevision         : WD.WORD;
  END;
  LPSYSTEM_INFO = POINTER TO SYSTEM_INFO;
 
  MEMORYSTATUS = RECORD [_NOTALIGNED]
    dwLength       : WD.DWORD;
    dwMemoryLoad   : WD.DWORD;
    dwTotalPhys    : WD.DWORD;
    dwAvailPhys    : WD.DWORD;
    dwTotalPageFile: WD.DWORD;
    dwAvailPageFile: WD.DWORD;
    dwTotalVirtual : WD.DWORD;
    dwAvailVirtual : WD.DWORD;
  END;
  LPMEMORYSTATUS = POINTER TO MEMORYSTATUS;

  EXCEPTION_DEBUG_INFO = RECORD [_NOTALIGNED]
    ExceptionRecord: WN.EXCEPTION_RECORD;
    dwFirstChance  : WD.DWORD;
  END;
  LPEXCEPTION_DEBUG_INFO = POINTER TO EXCEPTION_DEBUG_INFO;

  CREATE_THREAD_DEBUG_INFO = RECORD [_NOTALIGNED]
    hThread          : WD.HANDLE;
    lpThreadLocalBase: WD.LPVOID;
    lpStartAddress   : LPTHREAD_START_ROUTINE;
  END;
  LPCREATE_THREAD_DEBUG_INFO = POINTER TO CREATE_THREAD_DEBUG_INFO;

  CREATE_PROCESS_DEBUG_INFO = RECORD [_NOTALIGNED]
    hFile                : WD.HANDLE;
    hProcess             : WD.HANDLE;
    hThread              : WD.HANDLE;
    lpBaseOfImage        : WD.LPVOID;
    dwDebugInfoFileOffset: WD.DWORD;
    nDebugInfoSize       : WD.DWORD;
    lpThreadLocalBase    : WD.LPVOID;
    lpStartAddress       : LPTHREAD_START_ROUTINE;
    lpImageName          : WD.LPVOID;
    fUnicode             : WD.WORD;
  END;
  LPCREATE_PROCESS_DEBUG_INFO = POINTER TO CREATE_PROCESS_DEBUG_INFO;

  EXIT_THREAD_DEBUG_INFO = RECORD [_NOTALIGNED]
    dwExitCode: WD.DWORD;
  END;
  LPEXIT_THREAD_DEBUG_INFO = POINTER TO EXIT_THREAD_DEBUG_INFO;

  EXIT_PROCESS_DEBUG_INFO = RECORD [_NOTALIGNED]
    dwExitCode: WD.DWORD;
  END;
  LPEXIT_PROCESS_DEBUG_INFO = POINTER TO EXIT_PROCESS_DEBUG_INFO;

  LOAD_DLL_DEBUG_INFO = RECORD [_NOTALIGNED]
    hFile                : WD.HANDLE;
    lpBaseOfDll          : WD.LPVOID;
    dwDebugInfoFileOffset: WD.DWORD;
    nDebugInfoSize       : WD.DWORD;
    lpImageName          : WD.LPVOID;
    fUnicode             : WD.WORD;
  END;
  LPLOAD_DLL_DEBUG_INFO = POINTER TO LOAD_DLL_DEBUG_INFO;

  UNLOAD_DLL_DEBUG_INFO = RECORD [_NOTALIGNED]
    lpBaseOfDll: WD.LPVOID;
  END;
  LPUNLOAD_DLL_DEBUG_INFO = POINTER TO UNLOAD_DLL_DEBUG_INFO;

  OUTPUT_DEBUG_STRING_INFO = RECORD [_NOTALIGNED]
    lpDebugStringData : WD.LPSTR;
    fUnicode          : WD.WORD;
    nDebugStringLength: WD.WORD;
  END;
  LPOUTPUT_DEBUG_STRING_INFO = POINTER TO OUTPUT_DEBUG_STRING_INFO;

  RIP_INFO = RECORD [_NOTALIGNED]
    dwError: WD.DWORD;
    dwType : WD.DWORD;
  END;
  LPRIP_INFO = POINTER TO RIP_INFO;
  (* UNION *)
  (*
  winbase_Union0 = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: Exception        : EXCEPTION_DEBUG_INFO;
      |1: CreateThread     : CREATE_THREAD_DEBUG_INFO;
      |2: CreateProcessInfo: CREATE_PROCESS_DEBUG_INFO;
      |3: ExitThread       : EXIT_THREAD_DEBUG_INFO;
      |4: ExitProcess      : EXIT_PROCESS_DEBUG_INFO;
      |5: LoadDll          : LOAD_DLL_DEBUG_INFO;
      |6: UnloadDll        : UNLOAD_DLL_DEBUG_INFO;
      |7: DebugString      : OUTPUT_DEBUG_STRING_INFO;
      |8: RipInfo          : RIP_INFO;
    END;
  END;
  *)
  winbase_Union0 = RECORD [_NOTALIGNED]
    data        : ARRAY 42 OF WD.BYTE;
  END;
  
  DEBUG_EVENT = RECORD [_NOTALIGNED]
    dwDebugEventCode: WD.DWORD;
    dwProcessId     : WD.DWORD;
    dwThreadId      : WD.DWORD;
    u               : winbase_Union0;
  END;
  LPDEBUG_EVENT = POINTER TO DEBUG_EVENT;
(* CONTEXT ?????  *)
  LPCONTEXT = LONGINT;
  LPEXCEPTION_RECORD = WN.PEXCEPTION_RECORD;
  LPEXCEPTION_POINTERS = WN.PEXCEPTION_POINTERS;

  OFSTRUCT = RECORD [_NOTALIGNED]
    cBytes    : WD.BYTE;
    fFixedDisk: WD.BYTE;
    nErrCode  : WD.WORD;
    Reserved1 : WD.WORD;
    Reserved2 : WD.WORD;
    szPathName: ARRAY OFS_MAXPATHNAME OF CHAR;
  END;
  LPOFSTRUCT = POINTER TO OFSTRUCT;
  POFSTRUCT = POINTER TO OFSTRUCT;

  winbase_Struct0 = RECORD [_NOTALIGNED]
    hMem      : WD.HANDLE;
    dwReserved: ARRAY 3 OF WD.DWORD;
  END;

  winbase_Struct1 = RECORD [_NOTALIGNED]
    dwCommittedSize  : WD.DWORD;
    dwUnCommittedSize: WD.DWORD;
    lpFirstBlock     : WD.LPVOID;
    lpLastBlock      : WD.LPVOID;
  END;
  (* UNION*)
(*  winbase_Union1 = RECORD [_NOTALIGNED]
    CASE : INTEGER OF
       0: Block : winbase_Struct0;
      |1: Region: winbase_Struct1;
    END;
  END;
*)
  winbase_Union1 = RECORD [_NOTALIGNED]
    Block : ARRAY 16 OF WD.BYTE;
  END;

  PROCESS_HEAP_ENTRY = RECORD [_NOTALIGNED]
    lpData      : WD.LPVOID;
    cbData      : WD.DWORD;
    cbOverhead  : WD.BYTE;
    iRegionIndex: WD.BYTE;
    wFlags      : WD.WORD;
    u           : winbase_Union1;
  END;
  LPPROCESS_HEAP_ENTRY = POINTER TO PROCESS_HEAP_ENTRY;
  PPROCESS_HEAP_ENTRY = LPPROCESS_HEAP_ENTRY;

  PTOP_LEVEL_EXCEPTION_FILTER = PROCEDURE [_APICALL] ( 
              VAR STATICTYPED ExceptionInfo: WN.EXCEPTION_POINTERS ): LONGINT;
  LPTOP_LEVEL_EXCEPTION_FILTER = PTOP_LEVEL_EXCEPTION_FILTER;

  PtrLPOVERLAPPED = LONGINT;  (*POINTER TO LPOVERLAPPED;*)

(*  added for oberon *)
  CONTEXT = LONGINT;
  va_list = WD.LPSTR;
  LPVA_LIST = WD.LP;
  PAPCFUNC = PROCEDURE [_APICALL] ( dwParam: WD.DWORD );
 
  BY_HANDLE_FILE_INFORMATION = RECORD [_NOTALIGNED]
    dwFileAttributes    : WD.DWORD;
    ftCreationTime      : FILETIME;
    ftLastAccessTime    : FILETIME;
    ftLastWriteTime     : FILETIME;
    dwVolumeSerialNumber: WD.DWORD;
    nFileSizeHigh       : WD.DWORD;
    nFileSizeLow        : WD.DWORD;
    nNumberOfLinks      : WD.DWORD;
    nFileIndexHigh      : WD.DWORD;
    nFileIndexLow       : WD.DWORD;
  END;
  PBY_HANDLE_FILE_INFORMATION = POINTER TO BY_HANDLE_FILE_INFORMATION;
  LPBY_HANDLE_FILE_INFORMATION = POINTER TO BY_HANDLE_FILE_INFORMATION;
 
  TIME_ZONE_INFORMATION = RECORD [_NOTALIGNED]
    Bias        : LONGINT;
    StandardName: ARRAY 32 OF WD.WCHAR;
    StandardDate: SYSTEMTIME;
    StandardBias: LONGINT;
    DaylightName: ARRAY 32 OF WD.WCHAR;
    DaylightDate: SYSTEMTIME;
    DaylightBias: LONGINT;
  END;
  PTIME_ZONE_INFORMATION = POINTER TO TIME_ZONE_INFORMATION;
  LPTIME_ZONE_INFORMATION = POINTER TO TIME_ZONE_INFORMATION;
 
  LPOVERLAPPED_COMPLETION_ROUTINE = PROCEDURE [_APICALL] ( dwErrorCode: WD.DWORD; 
                                              dwNumberOfBytesTransfered: WD.DWORD;
                                              lpOverlapped: LPOVERLAPPED );

(*  *)
(*   Stream id structure *)
(*  *)

 
  WIN32_STREAM_ID = RECORD [_NOTALIGNED]
    dwStreamId        : WD.DWORD;
    dwStreamAttributes: WD.DWORD;
    Size              : WN.LARGE_INTEGER;
    dwStreamNameSize  : WD.DWORD;
    cStreamName       : LONGINT;  (*ARRAY ANYSIZE_ARRAY = 1 OF WD.WCHAR;*)
  END;
  LPWIN32_STREAM_ID = POINTER TO WIN32_STREAM_ID;

  STARTUPINFOA = RECORD [_NOTALIGNED]
    cb             : WD.DWORD;
    lpReserved     : WD.LPSTR;
    lpDesktop      : WD.LPSTR;
    lpTitle        : WD.LPSTR;
    dwX            : WD.DWORD;
    dwY            : WD.DWORD;
    dwXSize        : WD.DWORD;
    dwYSize        : WD.DWORD;
    dwXCountChars  : WD.DWORD;
    dwYCountChars  : WD.DWORD;
    dwFillAttribute: WD.DWORD;
    dwFlags        : LONGINT;
    wShowWindow    : WD.WORD;
    cbReserved2    : WD.WORD;
    lpReserved2    : WD.LPBYTE;
    hStdInput      : WD.HANDLE;
    hStdOutput     : WD.HANDLE;
    hStdError      : WD.HANDLE;
  END;
  LPSTARTUPINFOA = POINTER TO STARTUPINFOA;

  STARTUPINFOW = RECORD [_NOTALIGNED]
    cb             : WD.DWORD;
    lpReserved     : WD.LPWSTR;
    lpDesktop      : WD.LPWSTR;
    lpTitle        : WD.LPWSTR;
    dwX            : WD.DWORD;
    dwY            : WD.DWORD;
    dwXSize        : WD.DWORD;
    dwYSize        : WD.DWORD;
    dwXCountChars  : WD.DWORD;
    dwYCountChars  : WD.DWORD;
    dwFillAttribute: WD.DWORD;
    dwFlags        : LONGINT;
    wShowWindow    : WD.WORD;
    cbReserved2    : WD.WORD;
    lpReserved2    : WD.LPBYTE;
    hStdInput      : WD.HANDLE;
    hStdOutput     : WD.HANDLE;
    hStdError      : WD.HANDLE;
  END;
  LPSTARTUPINFOW = POINTER TO STARTUPINFOW;
  STARTUPINFO = STARTUPINFOA;     (* ! A *)
  LPSTARTUPINFO = LPSTARTUPINFOA;  (* ! A *)
 
  WIN32_FIND_DATAA = RECORD [_NOTALIGNED]
    dwFileAttributes  : WD.DWORD;
    ftCreationTime    : FILETIME;
    ftLastAccessTime  : FILETIME;
    ftLastWriteTime   : FILETIME;
    nFileSizeHigh     : WD.DWORD;
    nFileSizeLow      : WD.DWORD;
    dwReserved0       : WD.DWORD;
    dwReserved1       : WD.DWORD;
    cFileName         : ARRAY WD.MAX_PATH OF CHAR;
    cAlternateFileName: ARRAY 14 OF CHAR;
  END;
  PWIN32_FIND_DATAA = POINTER TO WIN32_FIND_DATAA;
  LPWIN32_FIND_DATAA = POINTER TO WIN32_FIND_DATAA;

  WIN32_FIND_DATAW = RECORD [_NOTALIGNED]
    dwFileAttributes  : WD.DWORD;
    ftCreationTime    : FILETIME;
    ftLastAccessTime  : FILETIME;
    ftLastWriteTime   : FILETIME;
    nFileSizeHigh     : WD.DWORD;
    nFileSizeLow      : WD.DWORD;
    dwReserved0       : WD.DWORD;
    dwReserved1       : WD.DWORD;
    cFileName         : ARRAY WD.MAX_PATH OF WD.WCHAR;
    cAlternateFileName: ARRAY 14 OF WD.WCHAR;
  END;
  PWIN32_FIND_DATAW = POINTER TO WIN32_FIND_DATAW;
  LPWIN32_FIND_DATAW = POINTER TO WIN32_FIND_DATAW;
  WIN32_FIND_DATA = WIN32_FIND_DATAA;    (* ! A *)
  PWIN32_FIND_DATA = PWIN32_FIND_DATAA;    (* ! A *)
  LPWIN32_FIND_DATA = PWIN32_FIND_DATAA;  (* ! A *)

  WIN32_FILE_ATTRIBUTE_DATA = RECORD [_NOTALIGNED]
    dwFileAttributes: WD.DWORD;
    ftCreationTime  : FILETIME;
    ftLastAccessTime: FILETIME;
    ftLastWriteTime : FILETIME;
    nFileSizeHigh   : WD.DWORD;
    nFileSizeLow    : WD.DWORD;
  END;
  LPWIN32_FILE_ATTRIBUTE_DATA = POINTER TO WIN32_FILE_ATTRIBUTE_DATA;
 
  PTIMERAPCROUTINE = PROCEDURE [_APICALL] ( lpArgToCompletionRoutine: WD.LPVOID;  
                               dwTimerLowValue: WD.DWORD;  
                               dwTimerHighValue: WD.DWORD );

  ENUMRESTYPEPROC = PROCEDURE [_APICALL] ( hModule: WD.HMODULE; lpType: WN.LPTSTR;
                              lParam: LONGINT ): WD.BOOL;

  ENUMRESNAMEPROC = PROCEDURE [_APICALL] ( hModule: WD.HMODULE; lpType: WN.LPCTSTR;
                              lpName: WN.LPTSTR; lParam: LONGINT ): WD.BOOL;

  ENUMRESLANGPROC = PROCEDURE [_APICALL] ( hModule: WD.HMODULE; lpType: WN.LPCTSTR; 
                              lpName:  WN.LPCTSTR; wLanguage: WD.WORD;
                              lParam: LONGINT ): WD.BOOL;
 
  GET_FILEEX_INFO_LEVELS = LONGINT;

  FINDEX_INFO_LEVELS = LONGINT;

  FINDEX_SEARCH_OPS = LONGINT;

  LPPROGRESS_ROUTINE = PROCEDURE [_APICALL] ( TotalFileSize: WN.LARGE_INTEGER; 
                                 TotalBytesTransferred: WN.LARGE_INTEGER;  
                                 StreamSize: WN.LARGE_INTEGER;  
                                 StreamBytesTransferred: WN.LARGE_INTEGER; 
                                 dwStreamNumber: WD.DWORD; 
                                 dwCallbackReason: WD.DWORD;  hSourceFile: WD.HANDLE;
                                 hDestinationFile: WD.HANDLE;
                                 lpData: WD.LPVOID ): WD.DWORD;

  PtrPACL = LONGINT;  (*POINTER TO WN.PACL;*)

  HW_PROFILE_INFOA = RECORD [_NOTALIGNED]
    dwDockInfo     : WD.DWORD;
    szHwProfileGuid: ARRAY HW_PROFILE_GUIDLEN OF CHAR;
    szHwProfileName: ARRAY MAX_PROFILE_LEN OF CHAR;
  END;
  LPHW_PROFILE_INFOA = POINTER TO HW_PROFILE_INFOA;

  HW_PROFILE_INFOW = RECORD [_NOTALIGNED]
    dwDockInfo     : WD.DWORD;
    szHwProfileGuid: ARRAY HW_PROFILE_GUIDLEN OF WD.WCHAR;
    szHwProfileName: ARRAY MAX_PROFILE_LEN OF WD.WCHAR;
  END;
  LPHW_PROFILE_INFOW = POINTER TO HW_PROFILE_INFOW;
  HW_PROFILE_INFO = HW_PROFILE_INFOA;      (* ! A *)
  LPHW_PROFILE_INFO = LPHW_PROFILE_INFOA;    (* ! A *)

(* ///////////////////////////////////////////////////////////// *)
(*                                                            // *)
(*       Win Certificate API and Structures                   // *)
(*                                                            // *)
(* ///////////////////////////////////////////////////////////// *)
(*  *)
(*  Structures *)
(*  *)
 
  OSVERSIONINFOA = RECORD [_NOTALIGNED]
    dwOSVersionInfoSize: WD.DWORD;
    dwMajorVersion     : WD.DWORD;
    dwMinorVersion     : WD.DWORD;
    dwBuildNumber      : WD.DWORD;
    dwPlatformId       : WD.DWORD;
    szCSDVersion       : ARRAY 128 OF CHAR; (*Maintenance string for PSS usage *)
  END;
  POSVERSIONINFOA = POINTER TO OSVERSIONINFOA;
  LPOSVERSIONINFOA = POINTER TO OSVERSIONINFOA;

  OSVERSIONINFOW = RECORD [_NOTALIGNED]
    dwOSVersionInfoSize: WD.DWORD;
    dwMajorVersion     : WD.DWORD;
    dwMinorVersion     : WD.DWORD;
    dwBuildNumber      : WD.DWORD;
    dwPlatformId       : WD.DWORD;
    szCSDVersion       : ARRAY 128 OF WD.WCHAR;  (* Maintenance string for PSS usage *)
  END;
  POSVERSIONINFOW = POINTER TO OSVERSIONINFOW;
  LPOSVERSIONINFOW = POINTER TO OSVERSIONINFOW;
  OSVERSIONINFO = OSVERSIONINFOA;     (* ! A *)
  POSVERSIONINFO = POSVERSIONINFOA;     (* ! A *)
  LPOSVERSIONINFO = POSVERSIONINFOA;   (* ! A *)

  SYSTEM_POWER_STATUS = RECORD [_NOTALIGNED]
    ACLineStatus       : WD.BYTE;
    BatteryFlag        : WD.BYTE;
    BatteryLifePercent : WD.BYTE;
    Reserved1          : WD.BYTE;
    BatteryLifeTime    : WD.DWORD;
    BatteryFullLifeTime: WD.DWORD;
  END;
  LPSYSTEM_POWER_STATUS = POINTER TO SYSTEM_POWER_STATUS;
 
  WIN_CERTIFICATE = RECORD [_NOTALIGNED]
    dwLength        : WD.DWORD;
    wRevision       : WD.WORD;
    wCertificateType: WD.WORD;    (*  WIN_CERT_TYPE_xxx *)
    bCertificate    : LONGINT;  (*ARRAY ANYSIZE_ARRAY=1 OF WD.BYTE;*)
  END;
  LPWIN_CERTIFICATE = POINTER TO WIN_CERTIFICATE;
 
  LPGUID = POINTER TO WN.GUID;

(* ///////////////////////////////////////////////////////////// *)
(*                                                            // *)
(*              Common Trust API Data Structures              // *)
(*                                                            // *)
(* ///////////////////////////////////////////////////////////// *)
(*  *)
(*  Data type commonly used in ActionData structures *)
(*  *)
 
  WIN_TRUST_SUBJECT = WD.LPVOID;

(*  *)
(*  Two commonly used ActionData structures *)
(*  *)

  WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT = RECORD [_NOTALIGNED]  
    hClientToken: WD.HANDLE;
    SubjectType : LPGUID;
    Subject     : WIN_TRUST_SUBJECT;
  END;
  LPWIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT = POINTER TO WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT;

  WIN_TRUST_ACTDATA_SUBJECT_ONLY = RECORD [_NOTALIGNED]
    SubjectType: LPGUID;
    Subject    : WIN_TRUST_SUBJECT;
  END;
  LPWIN_TRUST_ACTDATA_SUBJECT_ONLY = POINTER TO WIN_TRUST_ACTDATA_SUBJECT_ONLY;

(* ////////////////////////////////////////////////////////////////// *)
(*                                                                  / *)
(*       SUBJECT FORM DEFINITIONS                                   / *)
(*                                                                  / *)
(* ////////////////////////////////////////////////////////////////// *)
(*  *)
(*  Currently defined Subject Type Identifiers *)
(*  *)
(*  RawFile == 959dc450-8d9e-11cf-8736-00aa00a485eb  *)
(*  PeImage == 43c9a1e0-8da0-11cf-8736-00aa00a485eb  *)
(*  OleStorage == c257e740-8da0-11cf-8736-00aa00a485eb  *)
(*  JavaClass = 08ad3990-8da1-11cf-8736-00aa00a485eb  *)
(*  *)
(*  Subject Data Structures: *)
(*  *)
(*  WIN_TRUST_SUBJTYPE_RAW_FILE: *)
(*  *)
(*       Uses WIN_TRUST_SUBJECT_FILE *)
(*  *)
(*  WIN_TRUST_SUBJTYPE_PE_IMAGE: *)
(*  *)
(*       Uses WIN_TRUST_SUBJECT_FILE *)
(*  *)
(*  WIN_TRUST_SUBJTYPE_JAVA_CLASS: *)
(*  *)
(*       Uses WIN_TRUST_SUBJECT_FILE *)
(*  *)

  WIN_TRUST_SUBJECT_FILE = RECORD [_NOTALIGNED]
    hFile : WD.HANDLE;
    lpPath: WD.LPCWSTR;
  END;
  LPWIN_TRUST_SUBJECT_FILE = POINTER TO WIN_TRUST_SUBJECT_FILE;

(* ////////////////////////////////////////////////////////////////// *)
(*                                                                  / *)
(*       TRUST PROVIDER SPECIFIC DEFINITIONS                        / *)
(*                                                                  / *)
(*                                                                  / *)
(*       Each trust provider will have the following                / *)
(*       sections defined:                                          / *)
(*                                                                  / *)
(*       Actions - What actions are supported by the trust          / *)
(*           provider.                                              / *)
(*                                                                  / *)
(*       SubjectForms - Subjects that may be evaluated by this      / *)
(*           trust provider.                                        / *)
(*                                                                  / *)
(*                      and                                         / *)
(*                                                                  / *)
(*       Data structures to support the subject forms.              / *)
(*                                                                  / *)
(*                                                                  / *)
(* ////////////////////////////////////////////////////////////////// *)
(* ////////////////////////////////////////////////////////////////// *)
(*                                                                  / *)
(*              Software Publisher Trust Provider                   / *)
(*                                                                  / *)
(* ////////////////////////////////////////////////////////////////// *)
(*  *)
(*  Actions: *)
(*  *)
(*  TrustedPublisher == 66426730-8da1-11cf-8736-00aa00a485eb  *)
(*  NtActivateImage == 8bc96b00-8da1-11cf-8736-00aa00a485eb  *)
(*  PublishedSoftware == 64b9d180-8da2-11cf-8736-00aa00a485eb  *)
(*  *)
(*  Data Structures: *)
(*  *)
(*  WIN_SPUB_ACTION_TRUSTED_PUBLISHER: *)
(*  *)
(*       Uses WIN_SPUB_TRUSTED_PUBLISHER_DATA *)
(*  *)
(*  WIN_SPUB_ACTION_NT_ACTIVATE_IMAGE: *)
(*  *)
(*       Uses WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT *)
(*  *)
(*  WIN_SPUB_ACTION_PUBLISHED_SOFTWARE: *)
(*  *)
(*       Uses WIN_TRUST_ACTDATA_CONTEXT_WITH_SUBJECT *)
(*  *)

  WIN_SPUB_TRUSTED_PUBLISHER_DATA = RECORD [_NOTALIGNED]
    hClientToken : WD.HANDLE;
    lpCertificate: LPWIN_CERTIFICATE;
  END;
  LPWIN_SPUB_TRUSTED_PUBLISHER_DATA = POINTER TO WIN_SPUB_TRUSTED_PUBLISHER_DATA;
                                 
                               
(*  The MS-MIPS and Alpha compilers support intrinsic functions for interlocked *)
(*  increment; decrement; and exchange. *)

(*  (defined(_M_MRX000) || defined(_M_ALPHA) || (defined(_M_PPC) && (_MSC_VER >= 1000))) && !defined(RC_INVOKED) *)
(*                                                                 *)
(* #define InterlockedIncrement _InterlockedIncrement              *)
(* #define InterlockedDecrement _InterlockedDecrement              *)
(* #define InterlockedExchange _InterlockedExchange                *)
(* #define InterlockedExchangeAdd _InterlockedExchangeAdd          *)
(* #define InterlockedCompareExchange _InterlockedCompareExchange  *)
(*                                                                 *)
(* LONG                                                            *)
(* WINAPI                                                          *)
(* InterlockedIncrement(                                           *)
(*     LPLONG lpAddend                                             *)
(*     );                                                          *)
(*                                                                 *)
(* LONG                                                            *)
(* WINAPI                                                          *)
(* InterlockedDecrement(                                           *)
(*     LPLONG lpAddend                                             *)
(*     );                                                          *)
(*                                                                 *)
(* LONG                                                            *)
(* WINAPI                                                          *)
(* InterlockedExchange(                                            *)
(*     LPLONG Target;                                              *)
(*     LONG Value                                                  *)
(*     );                                                          *)
(*                                                                 *)
(* PVOID                                                           *)
(* WINAPI                                                          *)
(* InterlockedCompareExchange (                                    *)
(*     PVOID *Destination;                                         *)
(*     PVOID Exchange;                                             *)
(*     PVOID Comperand                                             *)
(*     );                                                          *)
(*                                                                 *)
(* LONG                                                            *)
(* WINAPI                                                          *)
(* InterlockedExchangeAdd(                                         *)
(*     LPLONG Addend;                                              *)
(*     LONG Value                                                  *)
(*     );                                                          *)
(*                                                                 *)
(* #pragma intrinsic(_InterlockedIncrement)                        *)
(* #pragma intrinsic(_InterlockedDecrement)                        *)
(* #pragma intrinsic(_InterlockedExchange)                         *)
(* #pragma intrinsic(_InterlockedCompareExchange)                  *)
(* #pragma intrinsic(_InterlockedExchangeAdd)                      *)
(*                                                                 *)
(*  *)
(* ndef _NTOS_ *)

PROCEDURE [_APICALL] InterlockedIncrement ( VAR Addend: LONGINT ): LONGINT;

PROCEDURE [_APICALL] InterlockedDecrement ( VAR Addend: LONGINT ): LONGINT;

PROCEDURE [_APICALL] InterlockedExchange ( VAR Target: LONGINT;
                                Value: LONGINT ): LONGINT;

PROCEDURE [_APICALL] InterlockedExchangeAdd ( VAR Addend: LONGINT ;
                                   Value: LONGINT ): LONGINT;

PROCEDURE [_APICALL] InterlockedCompareExchange ( Destination: WD.LPVOID;
                                       Exchange: WD.LPVOID;
                                       Comperand: WD.LPVOID ): WD.LPVOID;

PROCEDURE [_APICALL] FreeResource ( hResData: WD.HGLOBAL ): WD.BOOL;

PROCEDURE [_APICALL] LockResource ( hResData: WD.HGLOBAL ): WD.LPVOID;

PROCEDURE [_APICALL] WinMain ( hInstance: WD.HINSTANCE;
                    hPrevInstance: WD.HINSTANCE; lpCmdLine: WD.LPSTR;
                    nShowCmd: LONGINT ): LONGINT;

PROCEDURE [_APICALL] FreeLibrary ( hLibModule: WD.HMODULE ): WD.BOOL;

PROCEDURE [_APICALL] FreeLibraryAndExitThread ( hLibModule: WD.HMODULE;
                                     dwExitCode: WD.DWORD );

PROCEDURE [_APICALL] DisableThreadLibraryCalls ( hLibModule: WD.HMODULE ): WD.BOOL;

PROCEDURE [_APICALL] GetProcAddress ( hModule: WD.HMODULE;
                           lpProcName: WD.LPCSTR ): WD.FARPROC;

PROCEDURE [_APICALL] GetVersion (  ): WD.DWORD;

PROCEDURE [_APICALL] GlobalAlloc ( uFlags: WD.UINT;
                        dwBytes: WD.DWORD ): WD.HGLOBAL;

PROCEDURE [_APICALL] GlobalReAlloc ( hMem: WD.HGLOBAL; dwBytes: WD.DWORD;
                          uFlags: WD.UINT ): WD.HGLOBAL;

PROCEDURE [_APICALL] GlobalSize ( hMem: WD.HGLOBAL ): WD.DWORD;

PROCEDURE [_APICALL] GlobalFlags ( hMem: WD.HGLOBAL ): WD.UINT;

PROCEDURE [_APICALL] GlobalLock ( hMem: WD.HGLOBAL ): WD.LPVOID;

(* !!!MWH My version  win31 = DWORD WINAPI GlobalHandle(UINT) *)

PROCEDURE [_APICALL] GlobalHandle ( pMem: WD.LPCVOID ): WD.HGLOBAL;

PROCEDURE [_APICALL] GlobalUnlock ( hMem: WD.HGLOBAL ): WD.BOOL;

PROCEDURE [_APICALL] GlobalFree ( hMem: WD.HGLOBAL ): WD.HGLOBAL;

PROCEDURE [_APICALL] GlobalCompact ( dwMinFree: WD.DWORD ): WD.UINT;

PROCEDURE [_APICALL] GlobalFix ( hMem: WD.HGLOBAL );

PROCEDURE [_APICALL] GlobalUnfix ( hMem: WD.HGLOBAL );

PROCEDURE [_APICALL] GlobalWire ( hMem: WD.HGLOBAL ): WD.LPVOID;

PROCEDURE [_APICALL] GlobalUnWire ( hMem: WD.HGLOBAL ): WD.BOOL;

PROCEDURE [_APICALL] GlobalMemoryStatus ( VAR STATICTYPED Buffer: MEMORYSTATUS );

PROCEDURE [_APICALL] LocalAlloc ( uFlags: WD.UINT;
                       uBytes: WD.UINT ): WD.HLOCAL;

PROCEDURE [_APICALL] LocalReAlloc ( hMem: WD.HLOCAL; uBytes: WD.UINT;
                         uFlags: WD.UINT ): WD.HLOCAL;

PROCEDURE [_APICALL] LocalLock ( hMem: WD.HLOCAL ): WD.LPVOID;

PROCEDURE [_APICALL] LocalHandle ( pMem: WD.LPCVOID ): WD.HLOCAL;

PROCEDURE [_APICALL] LocalUnlock ( hMem: WD.HLOCAL ): WD.BOOL;

PROCEDURE [_APICALL] LocalSize ( hMem: WD.HLOCAL ): WD.UINT;

PROCEDURE [_APICALL] LocalFlags ( hMem: WD.HLOCAL ): WD.UINT;

PROCEDURE [_APICALL] LocalFree ( hMem: WD.HLOCAL ): WD.HLOCAL;

PROCEDURE [_APICALL] LocalShrink ( hMem: WD.HLOCAL;
                        cbNewSize: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] LocalCompact ( uMinFree: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] FlushInstructionCache ( hProcess: WD.HANDLE;
                                  lpBaseAddress: WD.LPCVOID;
                                  dwSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualAlloc ( lpAddress: WD.LPVOID; dwSize: WD.DWORD;
                         flAllocationType: WD.DWORD;
                         flProtect: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] VirtualFree ( lpAddress: WD.LPVOID; dwSize: WD.DWORD;
                        dwFreeType: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualProtect ( lpAddress: WD.LPVOID; dwSize: WD.DWORD;
                           flNewProtect: WD.DWORD;
                           VAR flOldProtect: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualQuery ( lpAddress: WD.LPCVOID;
                         VAR STATICTYPED Buffer: WN.MEMORY_BASIC_INFORMATION;
                         dwLength: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] VirtualAllocEx ( hProcess: WD.HANDLE; lpAddress: WD.LPVOID;
                           dwSize: WD.DWORD;
                           flAllocationType: WD.DWORD;
                           flProtect: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] VirtualFreeEx ( hProcess: WD.HANDLE; lpAddress: WD.LPVOID;
                          dwSize: WD.DWORD;
                          dwFreeType: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualProtectEx ( hProcess: WD.HANDLE;
                             lpAddress: WD.LPVOID; dwSize: WD.DWORD;
                             flNewProtect: WD.DWORD;
                             VAR flOldProtect: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualQueryEx ( hProcess: WD.HANDLE; lpAddress: WD.LPCVOID;
                           VAR STATICTYPED Buffer: WN.MEMORY_BASIC_INFORMATION;
                           dwLength: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] HeapCreate ( flOptions: WD.DWORD; dwInitialSize: WD.DWORD;
                       dwMaximumSize: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] HeapDestroy ( hHeap: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] HeapAlloc ( hHeap: WD.HANDLE; dwFlags: WD.DWORD;
                      dwBytes: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] HeapReAlloc ( hHeap: WD.HANDLE; dwFlags: WD.DWORD;
                        lpMem: WD.LPVOID;
                        dwBytes: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] HeapFree ( hHeap: WD.HANDLE; dwFlags: WD.DWORD;
                     lpMem: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] HeapSize ( hHeap: WD.HANDLE; dwFlags: WD.DWORD;
                     lpMem: WD.LPCVOID ): WD.DWORD;

PROCEDURE [_APICALL] HeapValidate ( hHeap: WD.HANDLE; dwFlags: WD.DWORD;
                         lpMem: WD.LPCVOID ): WD.BOOL;

PROCEDURE [_APICALL] HeapCompact ( hHeap: WD.HANDLE;
                        dwFlags: WD.DWORD ): WD.UINT;

PROCEDURE [_APICALL] GetProcessHeap (  ): WD.HANDLE;

PROCEDURE [_APICALL] GetProcessHeaps ( NumberOfHeaps: WD.DWORD;
                            VAR ProcessHeaps: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] HeapLock ( hHeap: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] HeapUnlock ( hHeap: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] HeapWalk ( hHeap: WD.HANDLE;
                     VAR STATICTYPED Entry: PROCESS_HEAP_ENTRY ): WD.BOOL;

PROCEDURE [_APICALL] GetBinaryTypeA ( lpApplicationName: WD.LPCSTR;
                           VAR BinaryType: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetBinaryTypeW ( lpApplicationName: WD.LPCWSTR;
                           VAR BinaryType: WD.DWORD ): WD.BOOL;
(*  !  GetBinaryType *)

PROCEDURE [_APICALL] GetShortPathNameA ( lpszLongPath: WD.LPCSTR;
                              lpszShortPath: WD.LPSTR;
                              cchBuffer: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetShortPathNameW ( lpszLongPath: WD.LPCWSTR;
                              lpszShortPath: WD.LPWSTR;
                              cchBuffer: WD.DWORD ): WD.DWORD;
(* !  GetShortPathName *)

PROCEDURE [_APICALL] GetProcessAffinityMask ( hProcess: WD.HANDLE;
                                   VAR ProcessAffinityMask: WD.DWORD;
                                   VAR SystemAffinityMask: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetProcessAffinityMask ( hProcess: WD.HANDLE;
                                   dwProcessAffinityMask: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessTimes ( hProcess: WD.HANDLE; 
              VAR STATICTYPED CreationTime: FILETIME;
                            VAR STATICTYPED ExitTime: FILETIME; VAR STATICTYPED KernelTime: FILETIME;
                            VAR STATICTYPED UserTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessWorkingSetSize ( hProcess: WD.HANDLE;
                                     VAR MinimumWorkingSetSize: WD.DWORD;
                                     VAR MaximumWorkingSetSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetProcessWorkingSetSize ( hProcess: WD.HANDLE;
                                     dwMinimumWorkingSetSize: WD.DWORD;
                                     dwMaximumWorkingSetSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] OpenProcess ( dwDesiredAccess: WD.DWORD;
                        bInheritHandle: WD.BOOL;
                        dwProcessId: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] GetCurrentProcess (): WD.HANDLE;

PROCEDURE [_APICALL] GetCurrentProcessId (): WD.DWORD;

PROCEDURE [_APICALL] ExitProcess ( uExitCode: WD.UINT );

PROCEDURE [_APICALL] TerminateProcess ( hProcess: WD.HANDLE;
                             uExitCode: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetExitCodeProcess ( hProcess: WD.HANDLE;
                               VAR ExitCode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] FatalExit ( ExitCode: LONGINT );

PROCEDURE [_APICALL] GetEnvironmentStringsA (): WD.LPSTR;

PROCEDURE [_APICALL] GetEnvironmentStringsW (): WD.LPWSTR;
(* ! GetEnvironmentStrings *)

PROCEDURE [_APICALL] FreeEnvironmentStringsA ( arg0: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] FreeEnvironmentStringsW ( arg0: WD.LPWSTR ): WD.BOOL;
(* ! FreeEnvironmentStrings *)

PROCEDURE [_APICALL] RaiseException ( dwExceptionCode: WD.DWORD;
                           dwExceptionFlags: WD.DWORD;
                           nNumberOfArguments: WD.DWORD;
                           VAR Arguments: WN.LCID );

PROCEDURE [_APICALL] UnhandledExceptionFilter ( 
          VAR STATICTYPED ExceptionInfo: WN.EXCEPTION_POINTERS ): LONGINT;

PROCEDURE [_APICALL] SetUnhandledExceptionFilter ( 
    lpTopLevelExceptionFilter: LPTOP_LEVEL_EXCEPTION_FILTER ): LPTOP_LEVEL_EXCEPTION_FILTER;

PROCEDURE [_APICALL] CreateFiber ( dwStackSize: WD.DWORD;
                        lpStartAddress: LPFIBER_START_ROUTINE;
                        lpParameter: WD.LPVOID ): WD.LPVOID;

PROCEDURE [_APICALL] DeleteFiber ( lpFiber: WD.LPVOID );

PROCEDURE [_APICALL] ConvertThreadToFiber ( lpParameter: WD.LPVOID ): WD.LPVOID;

PROCEDURE [_APICALL] SwitchToFiber ( lpFiber: WD.LPVOID );

PROCEDURE [_APICALL] SwitchToThread (  ): WD.BOOL;

PROCEDURE [_APICALL] CreateThread ( VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                         dwStackSize: WD.DWORD;
                         lpStartAddress: LPTHREAD_START_ROUTINE;
                         lpParameter: WD.LPVOID;
                         dwCreationFlags: WD.DWORD;
                         VAR ThreadId: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] CreateRemoteThread ( hProcess: WD.HANDLE;
                               VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                               dwStackSize: WD.DWORD;
                               lpStartAddress: LPTHREAD_START_ROUTINE;
                               lpParameter: WD.LPVOID;
                               dwCreationFlags: WD.DWORD;
                               VAR ThreadId: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] GetCurrentThread (): WD.HANDLE;

PROCEDURE [_APICALL] GetCurrentThreadId (): WD.DWORD;

PROCEDURE [_APICALL] SetThreadAffinityMask ( hThread: WD.HANDLE;
                                  dwThreadAffinityMask: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetThreadIdealProcessor ( hThread: WD.HANDLE;
                                    dwIdealProcessor: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetProcessPriorityBoost ( hProcess: WD.HANDLE;
                                    bDisablePriorityBoost: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessPriorityBoost ( hProcess: WD.HANDLE;
                                    VAR DisablePriorityBoost: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] SetThreadPriority ( hThread: WD.HANDLE;
                              nPriority: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetThreadPriorityBoost ( hThread: WD.HANDLE;
                                   bDisablePriorityBoost: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetThreadPriorityBoost ( hThread: WD.HANDLE;
                                   VAR DisablePriorityBoost: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetThreadPriority ( hThread: WD.HANDLE ): LONGINT;

PROCEDURE [_APICALL] GetThreadTimes ( hThread: WD.HANDLE; VAR STATICTYPED CreationTime: FILETIME;
                           VAR STATICTYPED ExitTime: FILETIME; 
               VAR STATICTYPED KernelTime: FILETIME;
                           VAR STATICTYPED UserTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] ExitThread ( dwExitCode: WD.DWORD );

PROCEDURE [_APICALL] TerminateThread ( hThread: WD.HANDLE;
                            dwExitCode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetExitCodeThread ( hThread: WD.HANDLE;
                              VAR ExitCode: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetThreadSelectorEntry ( hThread: WD.HANDLE;
                                   dwSelector: WD.DWORD;
                                   VAR STATICTYPED SelectorEntry: WN.LDT_ENTRY ): WD.BOOL;

PROCEDURE [_APICALL] GetLastError (): WD.DWORD;

PROCEDURE [_APICALL] SetLastError ( dwErrCode: WD.DWORD );

PROCEDURE [_APICALL] GetOverlappedResult ( hFile: WD.HANDLE; VAR STATICTYPED Overlapped: OVERLAPPED;
                                VAR NumberOfBytesTransferred: WD.DWORD;
                                bWait: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] CreateIoCompletionPort ( FileHandle: WD.HANDLE;
                                   ExistingCompletionPort: WD.HANDLE;
                                   CompletionKey: WD.DWORD;
                                   NumberOfConcurrentThreads: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] GetQueuedCompletionStatus ( CompletionPort: WD.HANDLE;
                                      VAR NumberOfBytesTransferred: WD.DWORD;
                                      VAR CompletionKey: WD.DWORD;
                                      lpOverlapped: PtrLPOVERLAPPED;
                                      dwMilliseconds: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PostQueuedCompletionStatus ( CompletionPort: WD.HANDLE;
                                       dwNumberOfBytesTransferred: WD.DWORD;
                                       dwCompletionKey: WD.DWORD;
                                       lpOverlapped: LPOVERLAPPED ): WD.BOOL;

PROCEDURE [_APICALL] SetErrorMode ( uMode: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] ReadProcessMemory ( hProcess: WD.HANDLE;
                              lpBaseAddress: WD.LPCVOID;
                              lpBuffer: WD.LPVOID; nSize: WD.DWORD;
                              VAR NumberOfBytesRead: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] WriteProcessMemory ( hProcess: WD.HANDLE;
                               lpBaseAddress: WD.LPVOID;
                               lpBuffer: WD.LPVOID; nSize: WD.DWORD;
                               VAR NumberOfBytesWritten: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetThreadContext ( hThread: WD.HANDLE;
                             lpContext: LPCONTEXT ): WD.BOOL;

PROCEDURE [_APICALL] SetThreadContext ( hThread: WD.HANDLE;
                             lpContext: WN.PLONG ): WD.BOOL;

PROCEDURE [_APICALL] SuspendThread ( hThread: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] ResumeThread ( hThread: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] QueueUserAPC ( pfnAPC: PAPCFUNC; hThread: WD.HANDLE;
                         dwData: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] DebugBreak ();

PROCEDURE [_APICALL] WaitForDebugEvent ( VAR STATICTYPED DebugEvent: DEBUG_EVENT;
                              dwMilliseconds: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] ContinueDebugEvent ( dwProcessId: WD.DWORD;
                               dwThreadId: WD.DWORD;
                               dwContinueStatus: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] DebugActiveProcess ( dwProcessId: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] InitializeCriticalSection ( VAR STATICTYPED CriticalSection: CRITICAL_SECTION );

PROCEDURE [_APICALL] EnterCriticalSection ( VAR STATICTYPED CriticalSection: CRITICAL_SECTION );

PROCEDURE [_APICALL] LeaveCriticalSection ( VAR STATICTYPED CriticalSection: CRITICAL_SECTION );

PROCEDURE [_APICALL] TryEnterCriticalSection ( VAR STATICTYPED CriticalSection: CRITICAL_SECTION ): WD.BOOL;

PROCEDURE [_APICALL] DeleteCriticalSection ( VAR STATICTYPED CriticalSection: CRITICAL_SECTION );

PROCEDURE [_APICALL] SetEvent ( hEvent: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] ResetEvent ( hEvent: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] PulseEvent ( hEvent: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] ReleaseSemaphore ( hSemaphore: WD.HANDLE;
                             lReleaseCount: LONGINT;
                             VAR PreviousCount: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ReleaseMutex ( hMutex: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] WaitForSingleObject ( hHandle: WD.HANDLE;
                                dwMilliseconds: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] WaitForMultipleObjects ( nCount: WD.DWORD;
                                   VAR Handles: LONGINT;
                                   bWaitAll: WD.BOOL;
                                   dwMilliseconds: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] Sleep ( dwMilliseconds: WD.DWORD );

PROCEDURE [_APICALL] LoadResource ( hModule: WD.HMODULE;
                         hResInfo: WD.HRSRC ): WD.HGLOBAL;

PROCEDURE [_APICALL] SizeofResource ( hModule: WD.HMODULE;
                           hResInfo: WD.HRSRC ): WD.DWORD;

PROCEDURE [_APICALL] GlobalDeleteAtom ( nAtom: WD.ATOM ): WD.ATOM;

PROCEDURE [_APICALL] InitAtomTable ( nSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] DeleteAtom ( nAtom: WD.ATOM ): WD.ATOM;

PROCEDURE [_APICALL] SetHandleCount ( uNumber: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] GetLogicalDrives (): WD.DWORD;

PROCEDURE [_APICALL] LockFile ( hFile: WD.HANDLE; dwFileOffsetLow: WD.DWORD;
                     dwFileOffsetHigh: WD.DWORD;
                     nNumberOfBytesToLockLow: WD.DWORD;
                     nNumberOfBytesToLockHigh: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] UnlockFile ( hFile: WD.HANDLE; dwFileOffsetLow: WD.DWORD;
                       dwFileOffsetHigh: WD.DWORD;
                       nNumberOfBytesToUnlockLow: WD.DWORD;
                       nNumberOfBytesToUnlockHigh: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] LockFileEx ( hFile: WD.HANDLE; dwFlags: WD.DWORD;
                       dwReserved: WD.DWORD;
                       nNumberOfBytesToLockLow: WD.DWORD;
                       nNumberOfBytesToLockHigh: WD.DWORD;
                       Overlapped: LONGINT ): WD.BOOL;


PROCEDURE [_APICALL] UnlockFileEx ( hFile: WD.HANDLE; dwReserved: WD.DWORD;
                         nNumberOfBytesToUnlockLow: WD.DWORD;
                         nNumberOfBytesToUnlockHigh: WD.DWORD;
                         Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetFileInformationByHandle ( hFile: WD.HANDLE;
                           VAR STATICTYPED FileInformation: BY_HANDLE_FILE_INFORMATION ): WD.BOOL;

PROCEDURE [_APICALL] GetFileType ( hFile: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] GetFileSize ( hFile: WD.HANDLE;
                        FileSizeHigh: LONGINT ): WD.DWORD;

PROCEDURE [_APICALL] GetStdHandle ( nStdHandle: WD.DWORD ): WD.HANDLE;

PROCEDURE [_APICALL] SetStdHandle ( nStdHandle: WD.DWORD;
                         hHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] WriteFile ( hFile: WD.HANDLE; lpBuffer: WD.LPCVOID;
                      nNumberOfBytesToWrite: WD.DWORD;
                      VAR NumberOfBytesWritten: WD.DWORD;
                      Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ReadFile ( hFile: WD.HANDLE; lpBuffer: WD.LPVOID;
                     nNumberOfBytesToRead: WD.DWORD;
                     VAR NumberOfBytesRead: WD.DWORD;
                     Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] FlushFileBuffers ( hFile: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] DeviceIoControl ( hDevice: WD.HANDLE;
                            dwIoControlCode: WD.DWORD;
                            lpInBuffer: WD.LPVOID;
                            nInBufferSize: WD.DWORD;
                            lpOutBuffer: WD.LPVOID;
                            nOutBufferSize: WD.DWORD;
                            VAR BytesReturned: WD.DWORD;
                            Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetEndOfFile ( hFile: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] SetFilePointer ( hFile: WD.HANDLE;
                           lDistanceToMove: LONGINT;
                           lpDistanceToMoveHigh: WD.LP;
                           dwMoveMethod: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] FindClose ( hFindFile: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] GetFileTime ( hFile: WD.HANDLE; 
            VAR STATICTYPED CreationTime: FILETIME;
                        VAR STATICTYPED LastAccessTime: FILETIME;
                        VAR STATICTYPED LastWriteTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] SetFileTime ( hFile: WD.HANDLE; 
            VAR STATICTYPED CreationTime: FILETIME;
                        VAR STATICTYPED LastAccessTime: FILETIME;
                        VAR STATICTYPED LastWriteTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] CloseHandle ( hObject: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] DuplicateHandle ( hSourceProcessHandle: WD.HANDLE;
                            hSourceHandle: WD.HANDLE;
                            hTargetProcessHandle: WD.HANDLE;
                            VAR TargetHandle: WD.HANDLE;
                            dwDesiredAccess: WD.DWORD;
                            bInheritHandle: WD.BOOL;
                            dwOptions: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetHandleInformation ( hObject: WD.HANDLE;
                                 VAR dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetHandleInformation ( hObject: WD.HANDLE; dwMask: WD.DWORD;
                                 dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] LoadModule ( lpModuleName: WD.LPCSTR;
                       lpParameterBlock: WD.LPVOID ): WD.DWORD;

PROCEDURE [_APICALL] WinExec ( lpCmdLine: WD.LPCSTR;
                    uCmdShow: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] ClearCommBreak ( hFile: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] ClearCommError ( hFile: WD.HANDLE; VAR Errors: WD.DWORD;
                           VAR STATICTYPED Stat: COMSTAT ): WD.BOOL;

PROCEDURE [_APICALL] SetupComm ( hFile: WD.HANDLE; dwInQueue: WD.DWORD;
                      dwOutQueue: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] EscapeCommFunction ( hFile: WD.HANDLE;
                               dwFunc: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetCommConfig ( hCommDev: WD.HANDLE; VAR STATICTYPED CC: COMMCONFIG;
                          VAR dwSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetCommMask ( hFile: WD.HANDLE;
                        VAR EvtMask: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetCommProperties ( hFile: WD.HANDLE;
                              VAR STATICTYPED CommProp: COMMPROP ): WD.BOOL;

PROCEDURE [_APICALL] GetCommModemStatus ( hFile: WD.HANDLE;
                               VAR ModemStat: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetCommState ( hFile: WD.HANDLE; VAR STATICTYPED dcb: DCB ): WD.BOOL;

PROCEDURE [_APICALL] GetCommTimeouts ( hFile: WD.HANDLE;
                            VAR STATICTYPED CommTimeouts: COMMTIMEOUTS ): WD.BOOL;

PROCEDURE [_APICALL] PurgeComm ( hFile: WD.HANDLE;
                      dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetCommBreak ( hFile: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] SetCommConfig ( hCommDev: WD.HANDLE; VAR STATICTYPED CC: COMMCONFIG;
                          dwSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetCommMask ( hFile: WD.HANDLE;
                        dwEvtMask: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetCommState ( hFile: WD.HANDLE; VAR STATICTYPED dcb: DCB ): WD.BOOL;

PROCEDURE [_APICALL] SetCommTimeouts ( hFile: WD.HANDLE;
                            VAR STATICTYPED CommTimeouts: COMMTIMEOUTS ): WD.BOOL;

PROCEDURE [_APICALL] TransmitCommChar ( hFile: WD.HANDLE; cChar: CHAR ): WD.BOOL;

PROCEDURE [_APICALL] WaitCommEvent ( hFile: WD.HANDLE; VAR EvtMask: WD.DWORD;
                          Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetTapePosition ( hDevice: WD.HANDLE;
                            dwPositionMethod: WD.DWORD;
                            dwPartition: WD.DWORD;
                            dwOffsetLow: WD.DWORD;
                            dwOffsetHigh: WD.DWORD;
                            bImmediate: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] GetTapePosition ( hDevice: WD.HANDLE;
                            dwPositionType: WD.DWORD;
                            VAR dwPartition: WD.DWORD;
                            VAR dwOffsetLow: WD.DWORD;
                            VAR dwOffsetHigh: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] PrepareTape ( hDevice: WD.HANDLE; dwOperation: WD.DWORD;
                        bImmediate: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] EraseTape ( hDevice: WD.HANDLE; dwEraseType: WD.DWORD;
                      bImmediate: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] CreateTapePartition ( hDevice: WD.HANDLE;
                                dwPartitionMethod: WD.DWORD;
                                dwCount: WD.DWORD;
                                dwSize: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] WriteTapemark ( hDevice: WD.HANDLE;
                          dwTapemarkType: WD.DWORD;
                          dwTapemarkCount: WD.DWORD;
                          bImmediate: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] GetTapeStatus ( hDevice: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] GetTapeParameters ( hDevice: WD.HANDLE;
                              dwOperation: WD.DWORD;
                              VAR dwSize: WD.DWORD;
                              lpTapeInformation: WD.LPVOID ): WD.DWORD;

PROCEDURE [_APICALL] SetTapeParameters ( hDevice: WD.HANDLE;
                              dwOperation: WD.DWORD;
                              lpTapeInformation: WD.LPVOID ): WD.DWORD;

PROCEDURE [_APICALL] Beep ( dwFreq: WD.DWORD;
                 dwDuration: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] OpenSound ();

PROCEDURE [_APICALL] CloseSound ();

PROCEDURE [_APICALL] StartSound ();

PROCEDURE [_APICALL] StopSound ();

PROCEDURE [_APICALL] WaitSoundState ( nState: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SyncAllVoices (): WD.DWORD;

PROCEDURE [_APICALL] CountVoiceNotes ( nVoice: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] GetThresholdEvent (): WD.LPDWORD;

PROCEDURE [_APICALL] GetThresholdStatus (): WD.DWORD;

PROCEDURE [_APICALL] SetSoundNoise ( nSource: WD.DWORD;
                          nDuration: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceAccent ( nVoice: WD.DWORD; nTempo: WD.DWORD;
                           nVolume: WD.DWORD; nMode: WD.DWORD;
                           nPitch: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceEnvelope ( nVoice: WD.DWORD; nShape: WD.DWORD;
                             nRepeat: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceNote ( nVoice: WD.DWORD; nValue: WD.DWORD;
                         nLength: WD.DWORD;
                         nCdots: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceQueueSize ( nVoice: WD.DWORD;
                              nBytes: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceSound ( nVoice: WD.DWORD; Frequency: WD.DWORD;
                          nDuration: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] SetVoiceThreshold ( nVoice: WD.DWORD;
                              nNotes: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] MulDiv ( nNumber: LONGINT; nNumerator: LONGINT;
                   nDenominator: LONGINT ): LONGINT;

PROCEDURE [_APICALL] GetSystemTime ( VAR STATICTYPED SystemTime: SYSTEMTIME );

PROCEDURE [_APICALL] GetSystemTimeAsFileTime ( VAR STATICTYPED SystemTimeAsFileTime: FILETIME );

PROCEDURE [_APICALL] SetSystemTime ( VAR STATICTYPED SystemTime: SYSTEMTIME ): WD.BOOL;

PROCEDURE [_APICALL] GetLocalTime ( VAR STATICTYPED SystemTime: SYSTEMTIME );

PROCEDURE [_APICALL] SetLocalTime ( VAR STATICTYPED SystemTime: SYSTEMTIME ): WD.BOOL;

PROCEDURE [_APICALL] GetSystemInfo ( VAR STATICTYPED SystemInfo: SYSTEM_INFO );

PROCEDURE [_APICALL] SystemTimeToTzSpecificLocalTime ( 
                VAR STATICTYPED TimeZoneInformation: TIME_ZONE_INFORMATION;
                                VAR STATICTYPED UniversalTime: SYSTEMTIME;
                                VAR STATICTYPED LocalTime: SYSTEMTIME ): WD.BOOL;

PROCEDURE [_APICALL] GetTimeZoneInformation ( 
            VAR STATICTYPED TimeZoneInformation: TIME_ZONE_INFORMATION ): WD.DWORD;

PROCEDURE [_APICALL] SetTimeZoneInformation ( 
            VAR STATICTYPED TimeZoneInformation: TIME_ZONE_INFORMATION ): WD.BOOL;

(*  *)
(*  Routines to convert back and forth between system time and file time *)
(*  *)

PROCEDURE [_APICALL] SystemTimeToFileTime ( VAR STATICTYPED SystemTime: SYSTEMTIME;
                                 VAR STATICTYPED FileTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] FileTimeToLocalFileTime ( VAR STATICTYPED FileTime: FILETIME;
                                    VAR STATICTYPED LocalFileTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] LocalFileTimeToFileTime ( VAR STATICTYPED LocalFileTime: FILETIME;
                                    VAR STATICTYPED FileTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] FileTimeToSystemTime ( VAR STATICTYPED FileTime: FILETIME;
                                 VAR STATICTYPED SystemTime: SYSTEMTIME ): WD.BOOL;

PROCEDURE [_APICALL] CompareFileTime ( VAR STATICTYPED FileTime1: FILETIME;
                            VAR STATICTYPED FileTime2: FILETIME ): LONGINT;

PROCEDURE [_APICALL] FileTimeToDosDateTime ( VAR STATICTYPED FileTime: FILETIME; 
                  VAR FatDate: WD.WORD;
                                  VAR FatTime: WD.WORD ): WD.BOOL;

PROCEDURE [_APICALL] DosDateTimeToFileTime ( wFatDate: WD.WORD;
                                  wFatTime: WD.WORD;
                                  VAR STATICTYPED FileTime: FILETIME ): WD.BOOL;

PROCEDURE [_APICALL] GetTickCount (): WD.DWORD;

PROCEDURE [_APICALL] SetSystemTimeAdjustment ( dwTimeAdjustment: WD.DWORD;
                                    bTimeAdjustmentDisabled: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetSystemTimeAdjustment ( lpTimeAdjustment: WD.PDWORD;
                                    VAR TimeIncrement: WD.DWORD;
                                    VAR TimeAdjustmentDisabled: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] FormatMessageA ( dwFlags: WD.DWORD; lpSource: WD.LPCVOID;
                           dwMessageId: WD.DWORD;
                           dwLanguageId: WD.DWORD; lpBuffer: WD.LPSTR;
                           nSize: WD.DWORD;
                           Arguments: LPVA_LIST ): WD.DWORD;
PROCEDURE [_APICALL] FormatMessageW ( dwFlags: WD.DWORD; lpSource: WD.LPCVOID;
                           dwMessageId: WD.DWORD;
                           dwLanguageId: WD.DWORD;
                           lpBuffer: WD.LPWSTR; nSize: WD.DWORD;
                           Arguments: LPVA_LIST ): WD.DWORD;
(*  ! FormatMessage *)

PROCEDURE [_APICALL] CreatePipe ( VAR hReadPipe: WD.HANDLE; VAR hWritePipe: WD.HANDLE;
                       VAR STATICTYPED PipeAttributes: SECURITY_ATTRIBUTES;
                       nSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] ConnectNamedPipe ( hNamedPipe: WD.HANDLE;
                             Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] DisconnectNamedPipe ( hNamedPipe: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] SetNamedPipeHandleState ( hNamedPipe: WD.HANDLE;
                                    VAR Mode: WD.DWORD;
                                    VAR MaxCollectionCount: WD.DWORD;
                                    VAR CollectDataTimeout: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetNamedPipeInfo ( hNamedPipe: WD.HANDLE;
                             VAR Flags: WD.DWORD;
                             VAR OutBufferSize: WD.DWORD;
                             VAR InBufferSize: WD.DWORD;
                             VAR MaxInstances: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PeekNamedPipe ( hNamedPipe: WD.HANDLE; lpBuffer: WD.LPVOID;
                          nBufferSize: WD.DWORD;
                          VAR BytesRead: WD.DWORD;
                          VAR TotalBytesAvail: WD.DWORD;
                          VAR BytesLeftThisMessage: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] TransactNamedPipe ( hNamedPipe: WD.HANDLE;
                              lpInBuffer: WD.LPVOID;
                              nInBufferSize: WD.DWORD;
                              lpOutBuffer: WD.LPVOID;
                              nOutBufferSize: WD.DWORD;
                              VAR BytesRead: WD.DWORD;
                              Overlapped: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] CreateMailslotA ( lpName: WD.LPCSTR;
                            nMaxMessageSize: WD.DWORD;
                            lReadTimeout: WD.DWORD;
                            VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.HANDLE;
PROCEDURE [_APICALL] CreateMailslotW ( lpName: WD.LPCWSTR;
                            nMaxMessageSize: WD.DWORD;
                            lReadTimeout: WD.DWORD;
                            VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.HANDLE;
(*  !   CreateMailslot *)

PROCEDURE [_APICALL] GetMailslotInfo ( hMailslot: WD.HANDLE;
                            VAR MaxMessageSize: WD.DWORD;
                            VAR NextSize: WD.DWORD;
                            VAR MessageCount: WD.DWORD;
                            VAR ReadTimeout: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetMailslotInfo ( hMailslot: WD.HANDLE;
                            lReadTimeout: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] MapViewOfFile ( hFileMappingObject: WD.HANDLE;
                          dwDesiredAccess: WD.DWORD;
                          dwFileOffsetHigh: WD.DWORD;
                          dwFileOffsetLow: WD.DWORD;
                          dwNumberOfBytesToMap: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] FlushViewOfFile ( lpBaseAddress: WD.LPCVOID;
                            dwNumberOfBytesToFlush: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] UnmapViewOfFile ( lpBaseAddress: WD.LPCVOID ): WD.BOOL;

(*  _l Compat Functions *)
PROCEDURE [_APICALL] lstrcmpA ( lpString1: WD.LPCSTR;
                     lpString2: WD.LPCSTR ): LONGINT;
PROCEDURE [_APICALL] lstrcmpW ( lpString1: WD.LPCWSTR;
                     lpString2: WD.LPCWSTR ): LONGINT;
(* !  lstrcmp *)

PROCEDURE [_APICALL] lstrcmpiA ( lpString1: WD.LPCSTR;
                      lpString2: WD.LPCSTR ): LONGINT;
PROCEDURE [_APICALL] lstrcmpiW ( lpString1: WD.LPCWSTR;
                      lpString2: WD.LPCWSTR ): LONGINT;
(*  !  lstrcmpi *)

PROCEDURE [_APICALL] lstrcpynA ( lpString1: WD.LPSTR; lpString2: WD.LPCSTR;
                      iMaxLength: LONGINT ): WD.LPSTR;
PROCEDURE [_APICALL] lstrcpynW ( lpString1: WD.LPWSTR; lpString2: WD.LPCWSTR;
                      iMaxLength: LONGINT ): WD.LPWSTR;
(*  ! lstrcpyn *)

PROCEDURE [_APICALL] lstrcpyA ( lpString1: WD.LPSTR;
                     lpString2: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] lstrcpyW ( lpString1: WD.LPWSTR;
                     lpString2: WD.LPCWSTR ): WD.LPWSTR;
(* !  lstrcpy *)

PROCEDURE [_APICALL] lstrcatA ( lpString1: WD.LPSTR;
                     lpString2: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] lstrcatW ( lpString1: WD.LPWSTR;
                     lpString2: WD.LPCWSTR ): WD.LPWSTR;
(*  ! lstrcat *)

PROCEDURE [_APICALL] lstrlenA ( lpString: WD.LPCSTR ): LONGINT;
PROCEDURE [_APICALL] lstrlenW ( lpString: WD.LPCWSTR ): LONGINT;
(*  ! lstrlen *)

PROCEDURE [_APICALL] OpenFile ( lpFileName: WD.LPCSTR; VAR STATICTYPED ReOpenBuff: OFSTRUCT;
                     uStyle: WD.UINT ): WD.HFILE;

PROCEDURE [_APICALL] _lopen ( lpPathName: WD.LPCSTR;
                   iReadWrite: LONGINT ): WD.HFILE;

PROCEDURE [_APICALL] _lcreat ( lpPathName: WD.LPCSTR;
                    iAttribute: LONGINT ): WD.HFILE;

PROCEDURE [_APICALL] _lread ( hFile: WD.HFILE; lpBuffer: WD.LPVOID;
                   uBytes: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] _lwrite ( hFile: WD.HFILE; lpBuffer: WD.LPCSTR;
                    uBytes: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] _hread ( hFile: WD.HFILE; lpBuffer: WD.LPVOID;
                   lBytes: LONGINT ): LONGINT;

PROCEDURE [_APICALL] _hwrite ( hFile: WD.HFILE; lpBuffer: WD.LPCSTR;
                    lBytes: LONGINT ): LONGINT;

PROCEDURE [_APICALL] _lclose ( hFile: WD.HFILE ): WD.HFILE;

PROCEDURE [_APICALL] _llseek ( hFile: WD.HFILE; lOffset: LONGINT;
                    iOrigin: LONGINT ): LONGINT;

PROCEDURE [_APICALL] IsTextUnicode ( lpBuffer: WD.LPVOID; cb: LONGINT;
                          lpi: WD.LPINT ): WD.BOOL;

PROCEDURE [_APICALL] TlsAlloc (): WD.DWORD;

PROCEDURE [_APICALL] TlsGetValue ( dwTlsIndex: WD.DWORD ): WD.LPVOID;

PROCEDURE [_APICALL] TlsSetValue ( dwTlsIndex: WD.DWORD;
                        lpTlsValue: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] TlsFree ( dwTlsIndex: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SleepEx ( dwMilliseconds: WD.DWORD;
                    bAlertable: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] WaitForSingleObjectEx ( hHandle: WD.HANDLE;
                                  dwMilliseconds: WD.DWORD;
                                  bAlertable: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] WaitForMultipleObjectsEx ( nCount: WD.DWORD;
                                     VAR Handles: LONGINT;
                                     bWaitAll: WD.BOOL;
                                     dwMilliseconds: WD.DWORD;
                                     bAlertable: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] SignalObjectAndWait ( hObjectToSignal: WD.HANDLE;
                                hObjectToWaitOn: WD.HANDLE;
                                dwMilliseconds: WD.DWORD;
                                bAlertable: WD.BOOL ): WD.DWORD;

PROCEDURE [_APICALL] ReadFileEx ( hFile: WD.HANDLE; lpBuffer: WD.LPVOID;
                       nNumberOfBytesToRead: WD.DWORD;
                       Overlapped: LONGINT;
                       lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE ): WD.BOOL;

PROCEDURE [_APICALL] WriteFileEx ( hFile: WD.HANDLE; lpBuffer: WD.LPCVOID;
                        nNumberOfBytesToWrite: WD.DWORD;
                        Overlapped: LONGINT;
                        lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE ): WD.BOOL;

PROCEDURE [_APICALL] BackupRead ( hFile: WD.HANDLE; lpBuffer: WD.LPBYTE;
                       nNumberOfBytesToRead: WD.DWORD;
                       VAR NumberOfBytesRead: WD.DWORD;
                       bAbort: WD.BOOL; bProcessSecurity: WD.BOOL;
                       lpContext: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] BackupSeek ( hFile: WD.HANDLE; dwLowBytesToSeek: WD.DWORD;
                       dwHighBytesToSeek: WD.DWORD;
                       VAR dwLowByteSeeked: WD.DWORD;
                       VAR dwHighByteSeeked: WD.DWORD;
                       lpContext: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] BackupWrite ( hFile: WD.HANDLE; lpBuffer: WD.LPBYTE;
                        nNumberOfBytesToWrite: WD.DWORD;
                        VAR NumberOfBytesWritten: WD.DWORD;
                        bAbort: WD.BOOL; bProcessSecurity: WD.BOOL;
                        lpContext: WD.LPVOID ): WD.BOOL;


PROCEDURE [_APICALL] CreateMutexA ( VAR STATICTYPED MutexAttributes: SECURITY_ATTRIBUTES;
                         bInitialOwner: WD.BOOL;
                         lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] CreateMutexW ( VAR STATICTYPED MutexAttributes: SECURITY_ATTRIBUTES;
                         bInitialOwner: WD.BOOL;
                         lpName: WD.LPCWSTR ): WD.HANDLE;
(* ! CreateMutex *)

PROCEDURE [_APICALL] OpenMutexA ( dwDesiredAccess: WD.DWORD;
                       bInheritHandle: WD.BOOL;
                       lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenMutexW ( dwDesiredAccess: WD.DWORD;
                       bInheritHandle: WD.BOOL;
                       lpName: WD.LPCWSTR ): WD.HANDLE;
(*  ! OpenMutex *)

PROCEDURE [_APICALL] CreateEventA ( VAR STATICTYPED EventAttributes: SECURITY_ATTRIBUTES;
                         bManualReset: WD.BOOL;
                         bInitialState: WD.BOOL;
                         lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] CreateEventW ( VAR STATICTYPED EventAttributes: SECURITY_ATTRIBUTES;
                         bManualReset: WD.BOOL;
                         bInitialState: WD.BOOL;
                         lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !  CreateEvent *)

PROCEDURE [_APICALL] OpenEventA ( dwDesiredAccess: WD.DWORD;
                       bInheritHandle: WD.BOOL;
                       lpName: WD.LPCSTR ): WD.HANDLE;

PROCEDURE [_APICALL] OpenEventW ( dwDesiredAccess: WD.DWORD;
                       bInheritHandle: WD.BOOL;
                       lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !   OpenEvent *)

PROCEDURE [_APICALL] CreateSemaphoreA ( VAR STATICTYPED SemaphoreAttributes: SECURITY_ATTRIBUTES;
                             lInitialCount: LONGINT;
                             lMaximumCount: LONGINT;
                             lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] CreateSemaphoreW ( VAR STATICTYPED SemaphoreAttributes: SECURITY_ATTRIBUTES;
                             lInitialCount: LONGINT;
                             lMaximumCount: LONGINT;
                             lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !   CreateSemaphore *)

PROCEDURE [_APICALL] OpenSemaphoreA ( dwDesiredAccess: WD.DWORD;
                           bInheritHandle: WD.BOOL;
                           lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenSemaphoreW ( dwDesiredAccess: WD.DWORD;
                           bInheritHandle: WD.BOOL;
                           lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !   OpenSemaphore *)

PROCEDURE [_APICALL] CreateWaitableTimerA ( VAR STATICTYPED TimerAttributes: SECURITY_ATTRIBUTES;
                                 bManualReset: WD.BOOL;
                                 lpTimerName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] CreateWaitableTimerW ( VAR STATICTYPED TimerAttributes: SECURITY_ATTRIBUTES;
                                 bManualReset: WD.BOOL;
                                 lpTimerName: WD.LPCWSTR ): WD.HANDLE;
(*  ! CreateWaitableTimer *)

PROCEDURE [_APICALL] OpenWaitableTimerA ( dwDesiredAccess: WD.DWORD;
                               bInheritHandle: WD.BOOL;
                               lpTimerName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenWaitableTimerW ( dwDesiredAccess: WD.DWORD;
                               bInheritHandle: WD.BOOL;
                               lpTimerName: WD.LPCWSTR ): WD.HANDLE;
(*  !  OpenWaitableTimer *)

PROCEDURE [_APICALL] SetWaitableTimer ( hTimer: WD.HANDLE;
                             lpDueTime: WN.PLARGE_INTEGER;
                             lPeriod: LONGINT;
                             pfnCompletionRoutine: PTIMERAPCROUTINE;
                             lpArgToCompletionRoutine: WD.LPVOID;
                             fResume: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] CancelWaitableTimer ( hTimer: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] CreateFileMappingA ( hFile: WD.HANDLE;
                               VAR STATICTYPED FileMappingAttributes: SECURITY_ATTRIBUTES;
                               flProtect: WD.DWORD;
                               dwMaximumSizeHigh: WD.DWORD;
                               dwMaximumSizeLow: WD.DWORD;
                               lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] CreateFileMappingW ( hFile: WD.HANDLE;
                               VAR STATICTYPED FileMappingAttributes: SECURITY_ATTRIBUTES;
                               flProtect: WD.DWORD;
                               dwMaximumSizeHigh: WD.DWORD;
                               dwMaximumSizeLow: WD.DWORD;
                               lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !   CreateFileMapping *)

PROCEDURE [_APICALL] OpenFileMappingA ( dwDesiredAccess: WD.DWORD;
                             bInheritHandle: WD.BOOL;
                             lpName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenFileMappingW ( dwDesiredAccess: WD.DWORD;
                             bInheritHandle: WD.BOOL;
                             lpName: WD.LPCWSTR ): WD.HANDLE;
(*  !  OpenFileMapping *)

PROCEDURE [_APICALL] GetLogicalDriveStringsA ( nBufferLength: WD.DWORD;
                                    lpBuffer: WD.LPSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetLogicalDriveStringsW ( nBufferLength: WD.DWORD;
                                    lpBuffer: WD.LPWSTR ): WD.DWORD;
(*  !  GetLogicalDriveStrings *)

PROCEDURE [_APICALL] LoadLibraryA ( lpLibFileName: WD.LPCSTR ): WD.HMODULE;
PROCEDURE [_APICALL] LoadLibraryW ( lpLibFileName: WD.LPCWSTR ): WD.HMODULE;
(*  !   LoadLibrary *)

PROCEDURE [_APICALL] LoadLibraryExA ( lpLibFileName: WD.LPCSTR; hFile: WD.HANDLE;
                           dwFlags: WD.DWORD ): WD.HMODULE;
PROCEDURE [_APICALL] LoadLibraryExW ( lpLibFileName: WD.LPCWSTR;
                           hFile: WD.HANDLE;
                           dwFlags: WD.DWORD ): WD.HMODULE;
(*  ! LoadLibraryEx *)

PROCEDURE [_APICALL] GetModuleFileNameA ( hModule: WD.HMODULE;
                               lpFilename: WD.LPSTR;
                               nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetModuleFileNameW ( hModule: WD.HMODULE;
                               lpFilename: WD.LPWSTR;
                               nSize: WD.DWORD ): WD.DWORD;
(*   !  GetModuleFileName *)

PROCEDURE [_APICALL] GetModuleHandleA ( lpModuleName: WD.LPCSTR ): WD.HMODULE;

PROCEDURE [_APICALL] GetModuleHandleW ( lpModuleName: WD.LPCWSTR ): WD.HMODULE;
(*  ! GetModuleHandle *)

PROCEDURE [_APICALL] CreateProcessA ( lpApplicationName: WD.LPCSTR;
                           lpCommandLine: WD.LPSTR;
                           VAR STATICTYPED ProcessAttributes: SECURITY_ATTRIBUTES;
                           VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                           bInheritHandles: WD.BOOL;
                           dwCreationFlags: WD.DWORD;
                           lpEnvironment: WD.LPVOID;
                           lpCurrentDirectory: WD.LPCSTR;
                           VAR STATICTYPED StartupInfo: STARTUPINFOA;
                           VAR STATICTYPED ProcessInformation: PROCESS_INFORMATION ): WD.BOOL;
PROCEDURE [_APICALL] CreateProcessW ( lpApplicationName: WD.LPCWSTR;
                           lpCommandLine: WD.LPWSTR;
                           VAR STATICTYPED ProcessAttributes: SECURITY_ATTRIBUTES;
                           VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                           bInheritHandles: WD.BOOL;
                           dwCreationFlags: WD.DWORD;
                           lpEnvironment: WD.LPVOID;
                           lpCurrentDirectory: WD.LPCWSTR;
                           VAR STATICTYPED StartupInfo: STARTUPINFOW;
                           VAR STATICTYPED ProcessInformation: PROCESS_INFORMATION ): WD.BOOL;
(*   ! CreateProcess *)

PROCEDURE [_APICALL] SetProcessShutdownParameters ( dwLevel: WD.DWORD;
                                         dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessShutdownParameters ( VAR dwLevel: WD.DWORD;
                                         VAR dwFlags: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessVersion ( ProcessId: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] FatalAppExitA ( uAction: WD.UINT;
                          lpMessageText: WD.LPCSTR );
PROCEDURE [_APICALL] FatalAppExitW ( uAction: WD.UINT;
                          lpMessageText: WD.LPCWSTR );
(*  !  FatalAppExit *)

PROCEDURE [_APICALL] GetStartupInfoA ( VAR STATICTYPED StartupInfo: STARTUPINFOA );
PROCEDURE [_APICALL] GetStartupInfoW ( VAR STATICTYPED StartupInfo: STARTUPINFOW );
(*  !   GetStartupInfo *)

PROCEDURE [_APICALL] GetCommandLineA (): WD.LPSTR;
PROCEDURE [_APICALL] GetCommandLineW (  ): WD.LPWSTR;
(*  ! GetCommandLine *)

PROCEDURE [_APICALL] GetEnvironmentVariableA ( lpName: WD.LPCSTR;
                                    lpBuffer: WD.LPSTR;
                                    nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetEnvironmentVariableW ( lpName: WD.LPCWSTR;
                                    lpBuffer: WD.LPWSTR;
                                    nSize: WD.DWORD ): WD.DWORD;
(*  ! GetEnvironmentVariable *)

PROCEDURE [_APICALL] SetEnvironmentVariableA ( lpName: WD.LPCSTR;
                                    lpValue: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetEnvironmentVariableW ( lpName: WD.LPCWSTR;
                                    lpValue: WD.LPCWSTR ): WD.BOOL;
(*  !   SetEnvironmentVariable *)

PROCEDURE [_APICALL] ExpandEnvironmentStringsA ( lpSrc: WD.LPCSTR;
                                      lpDst: WD.LPSTR;
                                      nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] ExpandEnvironmentStringsW ( lpSrc: WD.LPCWSTR;
                                      lpDst: WD.LPWSTR;
                                      nSize: WD.DWORD ): WD.DWORD;
(*  !  ExpandEnvironmentStrings *)

PROCEDURE [_APICALL] OutputDebugStringA ( lpOutputString: WD.LPCSTR );
PROCEDURE [_APICALL] OutputDebugStringW ( lpOutputString: WD.LPCWSTR );
(*  ! OutputDebugString*)

PROCEDURE [_APICALL] FindResourceA ( hModule: WD.HMODULE; lpName: WD.LPCSTR;
                          lpType: WD.LPCSTR ): WD.HRSRC;
PROCEDURE [_APICALL] FindResourceW ( hModule: WD.HMODULE; lpName: WD.LPCWSTR;
                          lpType: WD.LPCWSTR ): WD.HRSRC;
(*  !   FindResource *)

PROCEDURE [_APICALL] FindResourceExA ( hModule: WD.HMODULE; lpType: WD.LPCSTR;
                            lpName: WD.LPCSTR;
                            wLanguage: WD.WORD ): WD.HRSRC;
PROCEDURE [_APICALL] FindResourceExW ( hModule: WD.HMODULE; lpType: WD.LPCWSTR;
                            lpName: WD.LPCWSTR;
                            wLanguage: WD.WORD ): WD.HRSRC;
(* !  FindResourceEx *)

PROCEDURE [_APICALL] EnumResourceTypesA ( hModule: WD.HMODULE;
                               lpEnumFunc: ENUMRESTYPEPROC;
                               lParam: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] EnumResourceTypesW ( hModule: WD.HMODULE;
                               lpEnumFunc: ENUMRESTYPEPROC;
                               lParam: LONGINT ): WD.BOOL;
(*  !  EnumResourceTypes *)

PROCEDURE [_APICALL] EnumResourceNamesA ( hModule: WD.HMODULE; lpType: WD.LPCSTR;
                               lpEnumFunc: ENUMRESNAMEPROC;
                               lParam: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] EnumResourceNamesW ( hModule: WD.HMODULE;
                               lpType: WD.LPCWSTR;
                               lpEnumFunc: ENUMRESNAMEPROC;
                               lParam: LONGINT ): WD.BOOL;
(*  !   EnumResourceNames *)

PROCEDURE [_APICALL] EnumResourceLanguagesA ( hModule: WD.HMODULE;
                                   lpType: WD.LPCSTR;
                                   lpName: WD.LPCSTR;
                                   lpEnumFunc: ENUMRESLANGPROC;
                                   lParam: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] EnumResourceLanguagesW ( hModule: WD.HMODULE;
                                   lpType: WD.LPCWSTR;
                                   lpName: WD.LPCWSTR;
                                   lpEnumFunc: ENUMRESLANGPROC;
                                   lParam: LONGINT ): WD.BOOL;
(*  ! EnumResourceLanguages *)

PROCEDURE [_APICALL] BeginUpdateResourceA ( pFileName: WD.LPCSTR;
                                 bDeleteExistingResources: WD.BOOL ): WD.HANDLE;
PROCEDURE [_APICALL] BeginUpdateResourceW ( pFileName: WD.LPCWSTR;
                                 bDeleteExistingResources: WD.BOOL ): WD.HANDLE;
(*  !   BeginUpdateResource *)

PROCEDURE [_APICALL] UpdateResourceA ( hUpdate: WD.HANDLE; lpType: WD.LPCSTR;
                            lpName: WD.LPCSTR; wLanguage: WD.WORD;
                            lpData: WD.LPVOID;
                            cbData: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] UpdateResourceW ( hUpdate: WD.HANDLE; lpType: WD.LPCWSTR;
                            lpName: WD.LPCWSTR; wLanguage: WD.WORD;
                            lpData: WD.LPVOID;
                            cbData: WD.DWORD ): WD.BOOL;
(*  ! UpdateResource *)

PROCEDURE [_APICALL] EndUpdateResourceA ( hUpdate: WD.HANDLE;
                               fDiscard: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] EndUpdateResourceW ( hUpdate: WD.HANDLE;
                               fDiscard: WD.BOOL ): WD.BOOL;
(*  ! EndUpdateResource *)

PROCEDURE [_APICALL] GlobalAddAtomA ( lpString: WD.LPCSTR ): WD.ATOM;
PROCEDURE [_APICALL] GlobalAddAtomW ( lpString: WD.LPCWSTR ): WD.ATOM;
(*  !   GlobalAddAtom *)

PROCEDURE [_APICALL] GlobalFindAtomA ( lpString: WD.LPCSTR ): WD.ATOM;
PROCEDURE [_APICALL] GlobalFindAtomW ( lpString: WD.LPCWSTR ): WD.ATOM;
(*  !   GlobalFindAtom *)

PROCEDURE [_APICALL] GlobalGetAtomNameA ( nAtom: WD.ATOM; lpBuffer: WD.LPSTR;
                               nSize: LONGINT ): WD.UINT;
PROCEDURE [_APICALL] GlobalGetAtomNameW ( nAtom: WD.ATOM; lpBuffer: WD.LPWSTR;
                               nSize: LONGINT ): WD.UINT;
(*  !  GlobalGetAtomName *)

PROCEDURE [_APICALL] AddAtomA ( lpString: WD.LPCSTR ): WD.ATOM;
PROCEDURE [_APICALL] AddAtomW ( lpString: WD.LPCWSTR ): WD.ATOM;
(*  ! AddAtom *)

PROCEDURE [_APICALL] FindAtomA ( lpString: WD.LPCSTR ): WD.ATOM;
PROCEDURE [_APICALL] FindAtomW ( lpString: WD.LPCWSTR ): WD.ATOM;
(*  ! FindAtom *)

PROCEDURE [_APICALL] GetAtomNameA ( nAtom: WD.ATOM; lpBuffer: WD.LPSTR;
                         nSize: LONGINT ): WD.UINT;
PROCEDURE [_APICALL] GetAtomNameW ( nAtom: WD.ATOM; lpBuffer: WD.LPWSTR;
                         nSize: LONGINT ): WD.UINT;
(*  !  GetAtomName *)

PROCEDURE [_APICALL] GetProfileIntA ( lpAppName: WD.LPCSTR; lpKeyName: WD.LPCSTR;
                           nDefault: LONGINT ): WD.UINT;
PROCEDURE [_APICALL] GetProfileIntW ( lpAppName: WD.LPCWSTR;
                           lpKeyName: WD.LPCWSTR;
                           nDefault: LONGINT ): WD.UINT;
(*  ! GetProfileInt *)

PROCEDURE [_APICALL] GetProfileStringA ( lpAppName: WD.LPCSTR;
                              lpKeyName: WD.LPCSTR;
                              lpDefault: WD.LPCSTR;
                              lpReturnedString: WD.LPSTR;
                              nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetProfileStringW ( lpAppName: WD.LPCWSTR;
                              lpKeyName: WD.LPCWSTR;
                              lpDefault: WD.LPCWSTR;
                              lpReturnedString: WD.LPWSTR;
                              nSize: WD.DWORD ): WD.DWORD;
(*  ! GetProfileString *)

PROCEDURE [_APICALL] WriteProfileStringA ( lpAppName: WD.LPCSTR;
                                lpKeyName: WD.LPCSTR;
                                lpString: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] WriteProfileStringW ( lpAppName: WD.LPCWSTR;
                                lpKeyName: WD.LPCWSTR;
                                lpString: WD.LPCWSTR ): WD.BOOL;
(*  !   WriteProfileString *)

PROCEDURE [_APICALL] GetProfileSectionA ( lpAppName: WD.LPCSTR;
                               lpReturnedString: WD.LPSTR;
                               nSize: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetProfileSectionW ( lpAppName: WD.LPCWSTR;
                               lpReturnedString: WD.LPWSTR;
                               nSize: WD.DWORD ): WD.DWORD;
(*  !  GetProfileSection *)

PROCEDURE [_APICALL] WriteProfileSectionA ( lpAppName: WD.LPCSTR;
                                 lpString: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] WriteProfileSectionW ( lpAppName: WD.LPCWSTR;
                                 lpString: WD.LPCWSTR ): WD.BOOL;
(*  !   WriteProfileSection *)

PROCEDURE [_APICALL] GetPrivateProfileIntA ( lpAppName: WD.LPCSTR;
                                  lpKeyName: WD.LPCSTR;
                                  nDefault: LONGINT;
                                  lpFileName: WD.LPCSTR ): WD.UINT;
PROCEDURE [_APICALL] GetPrivateProfileIntW ( lpAppName: WD.LPCWSTR;
                                  lpKeyName: WD.LPCWSTR;
                                  nDefault: LONGINT;
                                  lpFileName: WD.LPCWSTR ): WD.UINT;
(*  !   GetPrivateProfileInt *)

PROCEDURE [_APICALL] GetPrivateProfileStringA ( lpAppName: WD.LPCSTR;
                                     lpKeyName: WD.LPCSTR;
                                     lpDefault: WD.LPCSTR;
                                     lpReturnedString: WD.LPSTR;
                                     nSize: WD.DWORD;
                                     lpFileName: WD.LPCSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetPrivateProfileStringW ( lpAppName: WD.LPCWSTR;
                                     lpKeyName: WD.LPCWSTR;
                                     lpDefault: WD.LPCWSTR;
                                     lpReturnedString: WD.LPWSTR;
                                     nSize: WD.DWORD;
                                     lpFileName: WD.LPCWSTR ): WD.DWORD;
(*  !  GetPrivateProfileString *)

PROCEDURE [_APICALL] WritePrivateProfileStringA ( lpAppName: WD.LPCSTR;
                                       lpKeyName: WD.LPCSTR;
                                       lpString: WD.LPCSTR;
                                       lpFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] WritePrivateProfileStringW ( lpAppName: WD.LPCWSTR;
                                       lpKeyName: WD.LPCWSTR;
                                       lpString: WD.LPCWSTR;
                                       lpFileName: WD.LPCWSTR ): WD.BOOL;
(*  !  WritePrivateProfileString *)

PROCEDURE [_APICALL] GetPrivateProfileSectionA ( lpAppName: WD.LPCSTR;
                                      lpReturnedString: WD.LPSTR;
                                      nSize: WD.DWORD;
                                      lpFileName: WD.LPCSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetPrivateProfileSectionW ( lpAppName: WD.LPCWSTR;
                                      lpReturnedString: WD.LPWSTR;
                                      nSize: WD.DWORD;
                                      lpFileName: WD.LPCWSTR ): WD.DWORD;
(*  !   GetPrivateProfileSection *)

PROCEDURE [_APICALL] WritePrivateProfileSectionA ( lpAppName: WD.LPCSTR;
                                        lpString: WD.LPCSTR;
                                        lpFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] WritePrivateProfileSectionW ( lpAppName: WD.LPCWSTR;
                                        lpString: WD.LPCWSTR;
                                        lpFileName: WD.LPCWSTR ): WD.BOOL;
(*  !   WritePrivateProfileSection *)

PROCEDURE [_APICALL] GetPrivateProfileSectionNamesA ( lpszReturnBuffer: WD.LPSTR;
                                           nSize: WD.DWORD;
                                           lpFileName: WD.LPCSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetPrivateProfileSectionNamesW ( lpszReturnBuffer: WD.LPWSTR;
                                           nSize: WD.DWORD;
                                           lpFileName: WD.LPCWSTR ): WD.DWORD;
(*  !  GetPrivateProfileSectionNames *)

PROCEDURE [_APICALL] GetPrivateProfileStructA ( lpszSection: WD.LPCSTR;
                                     lpszKey: WD.LPCSTR;
                                     lpStruct: WD.LPVOID;
                                     uSizeStruct: WD.UINT;
                                     szFile: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] GetPrivateProfileStructW ( lpszSection: WD.LPCWSTR;
                                     lpszKey: WD.LPCWSTR;
                                     lpStruct: WD.LPVOID;
                                     uSizeStruct: WD.UINT;
                                     szFile: WD.LPCWSTR ): WD.BOOL;
(*  !   GetPrivateProfileStruct *)

PROCEDURE [_APICALL] WritePrivateProfileStructA ( lpszSection: WD.LPCSTR;
                                       lpszKey: WD.LPCSTR;
                                       lpStruct: WD.LPVOID;
                                       uSizeStruct: WD.UINT;
                                       szFile: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] WritePrivateProfileStructW ( lpszSection: WD.LPCWSTR;
                                       lpszKey: WD.LPCWSTR;
                                       lpStruct: WD.LPVOID;
                                       uSizeStruct: WD.UINT;
                                       szFile: WD.LPCWSTR ): WD.BOOL;
(*  !   WritePrivateProfileStruct *)

PROCEDURE [_APICALL] GetDriveTypeA ( lpRootPathName: WD.LPCSTR ): WD.UINT;
PROCEDURE [_APICALL] GetDriveTypeW ( lpRootPathName: WD.LPCWSTR ): WD.UINT;
(*  !   GetDriveType *)

PROCEDURE [_APICALL] GetSystemDirectoryA ( lpBuffer: WD.LPSTR;
                                uSize: WD.UINT ): WD.UINT;
PROCEDURE [_APICALL] GetSystemDirectoryW ( lpBuffer: WD.LPWSTR;
                                uSize: WD.UINT ): WD.UINT;
(*  !   GetSystemDirectory *)

PROCEDURE [_APICALL] GetTempPathA ( nBufferLength: WD.DWORD;
                         lpBuffer: WD.LPSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetTempPathW ( nBufferLength: WD.DWORD;
                         lpBuffer: WD.LPWSTR ): WD.DWORD;
(*  !  GetTempPath *)

PROCEDURE [_APICALL] GetTempFileNameA ( lpPathName: WD.LPCSTR;
                             lpPrefixString: WD.LPCSTR;
                             uUnique: WD.UINT;
                             lpTempFileName: WD.LPSTR ): WD.UINT;
PROCEDURE [_APICALL] GetTempFileNameW ( lpPathName: WD.LPCWSTR;
                             lpPrefixString: WD.LPCWSTR;
                             uUnique: WD.UINT;
                             lpTempFileName: WD.LPWSTR ): WD.UINT;
(*  !   GetTempFileName *)

PROCEDURE [_APICALL] GetWindowsDirectoryA ( lpBuffer: WD.LPSTR;
                                 uSize: WD.UINT ): WD.UINT;
PROCEDURE [_APICALL] GetWindowsDirectoryW ( lpBuffer: WD.LPWSTR;
                                 uSize: WD.UINT ): WD.UINT;
(*  !  GetWindowsDirectory *)

PROCEDURE [_APICALL] SetCurrentDirectoryA ( lpPathName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetCurrentDirectoryW ( lpPathName: WD.LPCWSTR ): WD.BOOL;
(*  !  SetCurrentDirectory *)

PROCEDURE [_APICALL] GetCurrentDirectoryA ( nBufferLength: WD.DWORD;
                                 lpBuffer: WD.LPSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetCurrentDirectoryW ( nBufferLength: WD.DWORD;
                                 lpBuffer: WD.LPWSTR ): WD.DWORD;
(*  !  GetCurrentDirectory *)

PROCEDURE [_APICALL] GetDiskFreeSpaceA ( lpRootPathName: WD.LPCSTR;
                              VAR SectorsPerCluster: WD.DWORD;
                              VAR BytesPerSector: WD.DWORD;
                              VAR NumberOfFreeClusters: WD.DWORD;
                              VAR TotalNumberOfClusters: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetDiskFreeSpaceW ( lpRootPathName: WD.LPCWSTR;
                              VAR SectorsPerCluster: WD.DWORD;
                              VAR BytesPerSector: WD.DWORD;
                              VAR NumberOfFreeClusters: WD.DWORD;
                              VAR TotalNumberOfClusters: WD.DWORD ): WD.BOOL;
(*  !   GetDiskFreeSpace *)

PROCEDURE [_APICALL] GetDiskFreeSpaceExA ( lpDirectoryName: WD.LPCSTR;
                                VAR FreeBytesAvailableToCaller: WN.ULARGE_INTEGER;
                                VAR TotalNumberOfBytes: WN.ULARGE_INTEGER;
                                VAR TotalNumberOfFreeBytes: WN.ULARGE_INTEGER ): WD.BOOL;
PROCEDURE [_APICALL] GetDiskFreeSpaceExW ( lpDirectoryName: WD.LPCWSTR;
                                VAR FreeBytesAvailableToCaller: WN.ULARGE_INTEGER;
                                VAR TotalNumberOfBytes: WN.ULARGE_INTEGER;
                                VAR TotalNumberOfFreeBytes: WN.ULARGE_INTEGER ): WD.BOOL;
(*  !   GetDiskFreeSpaceEx *)

PROCEDURE [_APICALL] CreateDirectoryA ( lpPathName: WD.LPCSTR;
                             VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.BOOL;
PROCEDURE [_APICALL] CreateDirectoryW ( lpPathName: WD.LPCWSTR;
                             VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.BOOL;
(*  !  CreateDirectory *)

PROCEDURE [_APICALL] CreateDirectoryExA ( lpTemplateDirectory: WD.LPCSTR;
                               lpNewDirectory: WD.LPCSTR;
                               VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.BOOL;
PROCEDURE [_APICALL] CreateDirectoryExW ( lpTemplateDirectory: WD.LPCWSTR;
                               lpNewDirectory: WD.LPCWSTR;
                               VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.BOOL;
(*  !   CreateDirectoryEx *)

PROCEDURE [_APICALL] RemoveDirectoryA ( lpPathName: WD.LPCSTR ): WD.BOOL;

PROCEDURE [_APICALL] RemoveDirectoryW ( lpPathName: WD.LPCWSTR ): WD.BOOL;
(*  !   RemoveDirectory *)

PROCEDURE [_APICALL] GetFullPathNameA ( lpFileName: WD.LPCSTR;
                             nBufferLength: WD.DWORD;
                             lpBuffer: WD.LPSTR;
                             lpFilePart: WN.PLONG ): WD.DWORD;
PROCEDURE [_APICALL] GetFullPathNameW ( lpFileName: WD.LPCWSTR;
                             nBufferLength: WD.DWORD;
                             lpBuffer: WD.LPWSTR;
                             lpFilePart: WN.PLONG ): WD.DWORD;
(*  !   GetFullPathName *)

PROCEDURE [_APICALL] DefineDosDeviceA ( dwFlags: WD.DWORD;
                             lpDeviceName: WD.LPCSTR;
                             lpTargetPath: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] DefineDosDeviceW ( dwFlags: WD.DWORD;
                             lpDeviceName: WD.LPCWSTR;
                             lpTargetPath: WD.LPCWSTR ): WD.BOOL;
(* !  DefineDosDevice*)

PROCEDURE [_APICALL] QueryDosDeviceA ( lpDeviceName: WD.LPCSTR;
                            lpTargetPath: WD.LPSTR;
                            ucchMax: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] QueryDosDeviceW ( lpDeviceName: WD.LPCWSTR;
                            lpTargetPath: WD.LPWSTR;
                            ucchMax: WD.DWORD ): WD.DWORD;
(*  !   QueryDosDevice *)

PROCEDURE [_APICALL] CreateFileA ( lpFileName: WD.LPCSTR;
                        dwDesiredAccess: WD.DWORD;
                        dwShareMode: WD.DWORD;
                        VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES;
                        dwCreationDisposition: WD.DWORD;
                        dwFlagsAndAttributes: WD.DWORD;
                        hTemplateFile: WD.HANDLE ): WD.HANDLE;
PROCEDURE [_APICALL] CreateFileW ( lpFileName: WD.LPCWSTR;
                        dwDesiredAccess: WD.DWORD;
                        dwShareMode: WD.DWORD;
                        VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES;
                        dwCreationDisposition: WD.DWORD;
                        dwFlagsAndAttributes: WD.DWORD;
                        hTemplateFile: WD.HANDLE ): WD.HANDLE;
(*  !  CreateFile *)

PROCEDURE [_APICALL] SetFileAttributesA ( lpFileName: WD.LPCSTR;
                               dwFileAttributes: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] SetFileAttributesW ( lpFileName: WD.LPCWSTR;
                               dwFileAttributes: WD.DWORD ): WD.BOOL;
(*  !  SetFileAttributes *)

PROCEDURE [_APICALL] GetFileAttributesA ( lpFileName: WD.LPCSTR ): WD.DWORD;
PROCEDURE [_APICALL] GetFileAttributesW ( lpFileName: WD.LPCWSTR ): WD.DWORD;
(*  ! GetFileAttributes *)



PROCEDURE [_APICALL] GetFileAttributesExA ( lpFileName: WD.LPCSTR;
                                 fInfoLevelId: GET_FILEEX_INFO_LEVELS;
                                 lpFileInformation: WD.LPVOID ): WD.BOOL;
PROCEDURE [_APICALL] GetFileAttributesExW ( lpFileName: WD.LPCWSTR;
                                 fInfoLevelId: GET_FILEEX_INFO_LEVELS;
                                 lpFileInformation: WD.LPVOID ): WD.BOOL;
(*  ! GetFileAttributesEx *)

PROCEDURE [_APICALL] GetCompressedFileSizeA ( lpFileName: WD.LPCSTR;
                                   VAR FileSizeHigh: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] GetCompressedFileSizeW ( lpFileName: WD.LPCWSTR;
                                   VAR FileSizeHigh: WD.DWORD ): WD.DWORD;
(*  ! GetCompressedFileSize *)

PROCEDURE [_APICALL] DeleteFileA ( lpFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] DeleteFileW ( lpFileName: WD.LPCWSTR ): WD.BOOL;
(*  !   DeleteFile *)

PROCEDURE [_APICALL] FindFirstFileExA ( lpFileName: WD.LPCSTR;
                             fInfoLevelId: FINDEX_INFO_LEVELS;
                             lpFindFileData: WD.LPVOID;
                             fSearchOp: FINDEX_SEARCH_OPS;
                             lpSearchFilter: WD.LPVOID;
                             dwAdditionalFlags: WD.DWORD ): WD.HANDLE;
PROCEDURE [_APICALL] FindFirstFileExW ( lpFileName: WD.LPCWSTR;
                             fInfoLevelId: FINDEX_INFO_LEVELS;
                             lpFindFileData: WD.LPVOID;
                             fSearchOp: FINDEX_SEARCH_OPS;
                             lpSearchFilter: WD.LPVOID;
                             dwAdditionalFlags: WD.DWORD ): WD.HANDLE;
(*  !   FindFirstFileEx *)

PROCEDURE [_APICALL] FindFirstFileA ( lpFileName: WD.LPCSTR;
                           VAR STATICTYPED FindFileData: WIN32_FIND_DATAA ): WD.HANDLE;
PROCEDURE [_APICALL] FindFirstFileW ( lpFileName: WD.LPCWSTR;
                           VAR STATICTYPED FindFileData: WIN32_FIND_DATAW ): WD.HANDLE;
(*  !   FindFirstFile *)

PROCEDURE [_APICALL] FindNextFileA ( hFindFile: WD.HANDLE;
                          VAR STATICTYPED FindFileData: WIN32_FIND_DATAA ): WD.BOOL;
PROCEDURE [_APICALL] FindNextFileW ( hFindFile: WD.HANDLE;
                          VAR STATICTYPED FindFileData: WIN32_FIND_DATAW ): WD.BOOL;
(*  !  FindNextFile *)

PROCEDURE [_APICALL] SearchPathA ( lpPath: WD.LPCSTR; lpFileName: WD.LPCSTR;
                        lpExtension: WD.LPCSTR;
                        nBufferLength: WD.DWORD; lpBuffer: WD.LPSTR;
                        VAR FilePart: LONGINT ): WD.DWORD;
PROCEDURE [_APICALL] SearchPathW ( lpPath: WD.LPCWSTR; lpFileName: WD.LPCWSTR;
                        lpExtension: WD.LPCWSTR;
                        nBufferLength: WD.DWORD; lpBuffer: WD.LPWSTR;
                        FilePart: LONGINT ): WD.DWORD;
(*  !   SearchPath *)

PROCEDURE [_APICALL] CopyFileA ( lpExistingFileName: WD.LPCSTR;
                      lpNewFileName: WD.LPCSTR;
                      bFailIfExists: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] CopyFileW ( lpExistingFileName: WD.LPCWSTR;
                      lpNewFileName: WD.LPCWSTR;
                      bFailIfExists: WD.BOOL ): WD.BOOL;
(*  ! CopyFile *)

PROCEDURE [_APICALL] CopyFileExA ( lpExistingFileName: WD.LPCSTR;
                        lpNewFileName: WD.LPCSTR;
                        lpProgressRoutine: LPPROGRESS_ROUTINE;
                        lpData: WD.LPVOID; VAR bCancel: WD.BOOL;
                        dwCopyFlags: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] CopyFileExW ( lpExistingFileName: WD.LPCWSTR;
                        lpNewFileName: WD.LPCWSTR;
                        lpProgressRoutine: LPPROGRESS_ROUTINE;
                        lpData: WD.LPVOID; VAR bCancel: WD.BOOL;
                        dwCopyFlags: WD.DWORD ): WD.BOOL;
(*  !   CopyFileEx *)

PROCEDURE [_APICALL] MoveFileA ( lpExistingFileName: WD.LPCSTR;
                      lpNewFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] MoveFileW ( lpExistingFileName: WD.LPCWSTR;
                      lpNewFileName: WD.LPCWSTR ): WD.BOOL;
(*  !  MoveFile *)

PROCEDURE [_APICALL] MoveFileExA ( lpExistingFileName: WD.LPCSTR;
                        lpNewFileName: WD.LPCSTR;
                        dwFlags: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] MoveFileExW ( lpExistingFileName: WD.LPCWSTR;
                        lpNewFileName: WD.LPCWSTR;
                        dwFlags: WD.DWORD ): WD.BOOL;
(*  !   MoveFileEx *)

PROCEDURE [_APICALL] CreateNamedPipeA ( lpName: WD.LPCSTR; dwOpenMode: WD.DWORD;
                             dwPipeMode: WD.DWORD;
                             nMaxInstances: WD.DWORD;
                             nOutBufferSize: WD.DWORD;
                             nInBufferSize: WD.DWORD;
                             nDefaultTimeOut: WD.DWORD;
                             VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.HANDLE;
PROCEDURE [_APICALL] CreateNamedPipeW ( lpName: WD.LPCWSTR; dwOpenMode: WD.DWORD;
                             dwPipeMode: WD.DWORD;
                             nMaxInstances: WD.DWORD;
                             nOutBufferSize: WD.DWORD;
                             nInBufferSize: WD.DWORD;
                             nDefaultTimeOut: WD.DWORD;
                             VAR STATICTYPED SecurityAttributes: SECURITY_ATTRIBUTES ): WD.HANDLE;
(*  !   CreateNamedPipe *)

PROCEDURE [_APICALL] GetNamedPipeHandleStateA ( hNamedPipe: WD.HANDLE;
                                     VAR State: WD.DWORD;
                                     VAR CurInstances: WD.DWORD;
                                     VAR MaxCollectionCount: WD.DWORD;
                                     VAR CollectDataTimeout: WD.DWORD;
                                     lpUserName: WD.LPSTR;
                                     nMaxUserNameSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetNamedPipeHandleStateW ( hNamedPipe: WD.HANDLE;
                                     VAR State: WD.DWORD;
                                     VAR CurInstances: WD.DWORD;
                                     VAR MaxCollectionCount: WD.DWORD;
                                     VAR CollectDataTimeout: WD.DWORD;
                                     lpUserName: WD.LPWSTR;
                                     nMaxUserNameSize: WD.DWORD ): WD.BOOL;
(*  !  GetNamedPipeHandleState*)

PROCEDURE [_APICALL] CallNamedPipeA ( lpNamedPipeName: WD.LPCSTR;
                           lpInBuffer: WD.LPVOID;
                           nInBufferSize: WD.DWORD;
                           lpOutBuffer: WD.LPVOID;
                           nOutBufferSize: WD.DWORD;
                           VAR BytesRead: WD.DWORD;
                           nTimeOut: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] CallNamedPipeW ( lpNamedPipeName: WD.LPCWSTR;
                           lpInBuffer: WD.LPVOID;
                           nInBufferSize: WD.DWORD;
                           lpOutBuffer: WD.LPVOID;
                           nOutBufferSize: WD.DWORD;
                           VAR BytesRead: WD.DWORD;
                           nTimeOut: WD.DWORD ): WD.BOOL;
(*  ! CallNamedPipe *)

PROCEDURE [_APICALL] WaitNamedPipeA ( lpNamedPipeName: WD.LPCSTR;
                           nTimeOut: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] WaitNamedPipeW ( lpNamedPipeName: WD.LPCWSTR;
                           nTimeOut: WD.DWORD ): WD.BOOL;
(*  !  WaitNamedPipe *)

PROCEDURE [_APICALL] SetVolumeLabelA ( lpRootPathName: WD.LPCSTR;
                            lpVolumeName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetVolumeLabelW ( lpRootPathName: WD.LPCWSTR;
                            lpVolumeName: WD.LPCWSTR ): WD.BOOL;
(*  !  SetVolumeLabel *)

PROCEDURE [_APICALL] SetFileApisToOEM ();

PROCEDURE [_APICALL] SetFileApisToANSI ();

PROCEDURE [_APICALL] AreFileApisANSI (): WD.BOOL;

PROCEDURE [_APICALL] GetVolumeInformationA ( lpRootPathName: WD.LPCSTR;
                                  lpVolumeNameBuffer: WD.LPSTR;
                                  nVolumeNameSize: WD.DWORD;
                                  VAR VolumeSerialNumber: WD.DWORD;
                                  VAR MaximumComponentLength: WD.DWORD;
                                  VAR FileSystemFlags: WD.DWORD;
                                  lpFileSystemNameBuffer: WD.LPSTR;
                                  nFileSystemNameSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetVolumeInformationW ( lpRootPathName: WD.LPCWSTR;
                                  lpVolumeNameBuffer: WD.LPWSTR;
                                  nVolumeNameSize: WD.DWORD;
                                  VAR VolumeSerialNumber: WD.DWORD;
                                  VAR MaximumComponentLength: WD.DWORD;
                                  VAR FileSystemFlags: WD.DWORD;
                                  lpFileSystemNameBuffer: WD.LPWSTR;
                                  nFileSystemNameSize: WD.DWORD ): WD.BOOL;
(*  !  GetVolumeInformation *)

(*  Event logging APIs *)

PROCEDURE [_APICALL] ClearEventLogA ( hEventLog: WD.HANDLE;
                           lpBackupFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] ClearEventLogW ( hEventLog: WD.HANDLE;
                           lpBackupFileName: WD.LPCWSTR ): WD.BOOL;
(*  !   ClearEventLog *)

PROCEDURE [_APICALL] BackupEventLogA ( hEventLog: WD.HANDLE;
                            lpBackupFileName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] BackupEventLogW ( hEventLog: WD.HANDLE;
                            lpBackupFileName: WD.LPCWSTR ): WD.BOOL;
(*  !   BackupEventLog *)

PROCEDURE [_APICALL] CloseEventLog ( hEventLog: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] DeregisterEventSource ( hEventLog: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] NotifyChangeEventLog ( hEventLog: WD.HANDLE;
                                 hEvent: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] GetNumberOfEventLogRecords ( hEventLog: WD.HANDLE;
                                       VAR NumberOfRecords: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetOldestEventLogRecord ( hEventLog: WD.HANDLE;
                                    VAR OldestRecord: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] OpenEventLogA ( lpUNCServerName: WD.LPCSTR;
                          lpSourceName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenEventLogW ( lpUNCServerName: WD.LPCWSTR;
                          lpSourceName: WD.LPCWSTR ): WD.HANDLE;
(*  !   OpenEventLog *)

PROCEDURE [_APICALL] RegisterEventSourceA ( lpUNCServerName: WD.LPCSTR;
                                 lpSourceName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] RegisterEventSourceW ( lpUNCServerName: WD.LPCWSTR;
                                 lpSourceName: WD.LPCWSTR ): WD.HANDLE;
(*  !   RegisterEventSource *)

PROCEDURE [_APICALL] OpenBackupEventLogA ( lpUNCServerName: WD.LPCSTR;
                                lpFileName: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] OpenBackupEventLogW ( lpUNCServerName: WD.LPCWSTR;
                                lpFileName: WD.LPCWSTR ): WD.HANDLE;
(*  !  OpenBackupEventLog *)

PROCEDURE [_APICALL] ReadEventLogA ( hEventLog: WD.HANDLE; dwReadFlags: WD.DWORD;
                          dwRecordOffset: WD.DWORD;
                          lpBuffer: WD.LPVOID;
                          nNumberOfBytesToRead: WD.DWORD;
                          VAR nBytesRead: WN.LCID;
                          VAR nMinNumberOfBytesNeeded: WN.LCID ): WD.BOOL;
PROCEDURE [_APICALL] ReadEventLogW ( hEventLog: WD.HANDLE; dwReadFlags: WD.DWORD;
                          dwRecordOffset: WD.DWORD;
                          lpBuffer: WD.LPVOID;
                          nNumberOfBytesToRead: WD.DWORD;
                          VAR nBytesRead: WN.LCID;
                          VAR pnMinNumberOfBytesNeeded: WN.LCID ): WD.BOOL;
(*  !   ReadEventLog *)

PROCEDURE [_APICALL] ReportEventA ( hEventLog: WD.HANDLE; wType: WD.WORD;
                         wCategory: WD.WORD; dwEventID: WD.DWORD;
                         lpUserSid: WN.PSID; wNumStrings: WD.WORD;
                         dwDataSize: WD.DWORD; VAR Strings: LONGINT;
                         lpRawData: WD.LPVOID ): WD.BOOL;
PROCEDURE [_APICALL] ReportEventW ( hEventLog: WD.HANDLE; wType: WD.WORD;
                         wCategory: WD.WORD; dwEventID: WD.DWORD;
                         lpUserSid: WN.PSID; wNumStrings: WD.WORD;
                         dwDataSize: WD.DWORD; VAR Strings: LONGINT;
                         lpRawData: WD.LPVOID ): WD.BOOL;
(*  !   ReportEvent *)

(*  Security APIs *)

PROCEDURE [_APICALL] DuplicateToken ( ExistingTokenHandle: WD.HANDLE;
                           ImpersonationLevel: WN.SECURITY_IMPERSONATION_LEVEL;
                           VAR DuplicateTokenHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] GetKernelObjectSecurity ( Handle: WD.HANDLE;
                                    RequestedInformation: WN.SECURITY_INFORMATION;
                                    VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                    nLength: WD.DWORD;
                                    VAR nLengthNeeded: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] ImpersonateNamedPipeClient ( hNamedPipe: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] ImpersonateSelf ( ImpersonationLevel: WN.SECURITY_IMPERSONATION_LEVEL ): WD.BOOL;

PROCEDURE [_APICALL] RevertToSelf (): WD.BOOL;

PROCEDURE [_APICALL] SetThreadToken ( VAR Thread: WD.HANDLE;
                           Token: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] AccessCheck ( VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                        ClientToken: WD.HANDLE;
                        DesiredAccess: WD.DWORD;
                        VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING;
                        VAR STATICTYPED PrivilegeSet: WN.PRIVILEGE_SET;
                        VAR PrivilegeSetLength: WD.DWORD;
                        VAR GrantedAccess: WD.DWORD;
                        VAR AccessStatus: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] OpenProcessToken ( ProcessHandle: WD.HANDLE;
                             DesiredAccess: WD.DWORD;
                             VAR TokenHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] OpenThreadToken ( ThreadHandle: WD.HANDLE;
                            DesiredAccess: WD.DWORD;
                            OpenAsSelf: WD.BOOL;
                            VAR TokenHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] GetTokenInformation ( TokenHandle: WD.HANDLE;
                                TokenInformationClass: WN.TOKEN_INFORMATION_CLASS;
                                TokenInformation: WD.LPVOID;
                                TokenInformationLength: WD.DWORD;
                                ReturnLength: WD.PDWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetTokenInformation ( TokenHandle: WD.HANDLE;
                                TokenInformationClass: WN.TOKEN_INFORMATION_CLASS;
                                TokenInformation: WD.LPVOID;
                                TokenInformationLength: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] AdjustTokenPrivileges ( TokenHandle: WD.HANDLE;
                                  DisableAllPrivileges: WD.BOOL;
                                  VAR STATICTYPED NewState: WN.TOKEN_PRIVILEGES;
                                  BufferLength: WD.DWORD;
                                  VAR STATICTYPED PreviousState: WN.TOKEN_PRIVILEGES;
                                  ReturnLength: WD.PDWORD ): WD.BOOL;

PROCEDURE [_APICALL] AdjustTokenGroups ( TokenHandle: WD.HANDLE;
                              ResetToDefault: WD.BOOL;
                              VAR STATICTYPED NewState: WN.TOKEN_GROUPS;
                              BufferLength: WD.DWORD;
                              VAR STATICTYPED PreviousState: WN.TOKEN_GROUPS;
                              VAR ReturnLength: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] PrivilegeCheck ( ClientToken: WD.HANDLE;
                           VAR STATICTYPED RequiredPrivileges: WN.PRIVILEGE_SET;
                           VAR fResult: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] AccessCheckAndAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                      HandleId: WD.LPVOID;
                                      ObjectTypeName: WD.LPSTR;
                                      ObjectName: WD.LPSTR;
                                      VAR SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      DesiredAccess: WD.DWORD;
                                      VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING;
                                      ObjectCreation: WD.BOOL;
                                      VAR GrantedAccess: WD.DWORD;
                                      VAR AccessStatus: WD.BOOL;
                                      VAR pfGenerateOnClose: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] AccessCheckAndAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                      HandleId: WD.LPVOID;
                                      ObjectTypeName: WD.LPWSTR;
                                      ObjectName: WD.LPWSTR;
                                      VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      DesiredAccess: WD.DWORD;
                                      VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING;
                                      ObjectCreation: WD.BOOL;
                                      VAR GrantedAccess: WD.DWORD;
                                      VAR AccessStatus: WD.BOOL;
                                      VAR fGenerateOnClose: WD.BOOL ): WD.BOOL;
(*  !   AccessCheckAndAuditAlarm *)

PROCEDURE [_APICALL] ObjectOpenAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                  HandleId: WD.LPVOID;
                                  ObjectTypeName: WD.LPSTR;
                                  ObjectName: WD.LPSTR;
                                  VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                  ClientToken: WD.HANDLE;
                                  DesiredAccess: WD.DWORD;
                                  GrantedAccess: WD.DWORD;
                                  VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                  ObjectCreation: WD.BOOL;
                                  AccessGranted: WD.BOOL;
                                  VAR GenerateOnClose: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] ObjectOpenAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                  HandleId: WD.LPVOID;
                                  ObjectTypeName: WD.LPWSTR;
                                  ObjectName: WD.LPWSTR;
                                  VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                  ClientToken: WD.HANDLE;
                                  DesiredAccess: WD.DWORD;
                                  GrantedAccess: WD.DWORD;
                                  VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                  ObjectCreation: WD.BOOL;
                                  AccessGranted: WD.BOOL;
                                  VAR GenerateOnClose: WD.BOOL ): WD.BOOL;
(*  !    ObjectOpenAuditAlarm *)

PROCEDURE [_APICALL] ObjectPrivilegeAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                       HandleId: WD.LPVOID;
                                       ClientToken: WD.HANDLE;
                                       DesiredAccess: WD.DWORD;
                                       VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                       AccessGranted: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] ObjectPrivilegeAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                       HandleId: WD.LPVOID;
                                       ClientToken: WD.HANDLE;
                                       DesiredAccess: WD.DWORD;
                                       VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                       AccessGranted: WD.BOOL ): WD.BOOL;
(*  !  ObjectPrivilegeAuditAlarm *)

PROCEDURE [_APICALL] ObjectCloseAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                   HandleId: WD.LPVOID;
                                   GenerateOnClose: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] ObjectCloseAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                   HandleId: WD.LPVOID;
                                   GenerateOnClose: WD.BOOL ): WD.BOOL;
(*  !   ObjectCloseAuditAlarm *)

PROCEDURE [_APICALL] ObjectDeleteAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                    HandleId: WD.LPVOID;
                                    GenerateOnClose: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] ObjectDeleteAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                    HandleId: WD.LPVOID;
                                    GenerateOnClose: WD.BOOL ): WD.BOOL;
(*  !  ObjectDeleteAuditAlarm *)

PROCEDURE [_APICALL] PrivilegedServiceAuditAlarmA ( SubsystemName: WD.LPCSTR;
                                         ServiceName: WD.LPCSTR;
                                         ClientToken: WD.HANDLE;
                                         VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                         AccessGranted: WD.BOOL ): WD.BOOL;
PROCEDURE [_APICALL] PrivilegedServiceAuditAlarmW ( SubsystemName: WD.LPCWSTR;
                                         ServiceName: WD.LPCWSTR;
                                         ClientToken: WD.HANDLE;
                                         VAR STATICTYPED Privileges: WN.PRIVILEGE_SET;
                                         AccessGranted: WD.BOOL ): WD.BOOL;
(*    PrivilegedServiceAuditAlarm *)

PROCEDURE [_APICALL] IsValidSid ( pSid: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] EqualSid ( pSid1: WN.PSID; pSid2: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] EqualPrefixSid ( pSid1: WN.PSID;
                           pSid2: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] GetSidLengthRequired ( nSubAuthorityCount: WD.UCHAR ): WD.DWORD;

PROCEDURE [_APICALL] AllocateAndInitializeSid ( 
                VAR STATICTYPED IdentifierAuthority: WN.SID_IDENTIFIER_AUTHORITY;
                                     nSubAuthorityCount: WD.BYTE;
                                     nSubAuthority0: WD.DWORD;
                                     nSubAuthority1: WD.DWORD;
                                     nSubAuthority2: WD.DWORD;
                                     nSubAuthority3: WD.DWORD;
                                     nSubAuthority4: WD.DWORD;
                                     nSubAuthority5: WD.DWORD;
                                     nSubAuthority6: WD.DWORD;
                                     nSubAuthority7: WD.DWORD;
                                     pSid: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] FreeSid ( pSid: WN.PSID ): WD.LPVOID;

PROCEDURE [_APICALL] InitializeSid ( Sid: WN.PSID;
                          VAR STATICTYPED IdentifierAuthority: WN.SID_IDENTIFIER_AUTHORITY;
                          nSubAuthorityCount: WD.BYTE ): WD.BOOL;

PROCEDURE [_APICALL] GetSidIdentifierAuthority ( pSid: WN.PSID ): WN.PSID_IDENTIFIER_AUTHORITY;

PROCEDURE [_APICALL] GetSidSubAuthority ( pSid: WN.PSID;
                               nSubAuthority: WD.DWORD ): WD.PDWORD;

PROCEDURE [_APICALL] GetSidSubAuthorityCount ( pSid: WN.PSID ): WD.PUCHAR;

PROCEDURE [_APICALL] GetLengthSid ( pSid: WN.PSID ): WD.DWORD;

PROCEDURE [_APICALL] CopySid ( nDestinationSidLength: WD.DWORD;
                    pDestinationSid: WN.PSID;
                    pSourceSid: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] AreAllAccessesGranted ( GrantedAccess: WD.DWORD;
                                  DesiredAccess: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] AreAnyAccessesGranted ( GrantedAccess: WD.DWORD;
                                  DesiredAccess: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] MapGenericMask ( AccessMask: WD.PDWORD;
                           VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING );

PROCEDURE [_APICALL] IsValidAcl ( VAR STATICTYPED Acl: WN.ACL ): WD.BOOL;

PROCEDURE [_APICALL] InitializeAcl ( VAR STATICTYPED Acl: WN.ACL; nAclLength: WD.DWORD;
                          dwAclRevision: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetAclInformation ( VAR STATICTYPED Acl: WN.ACL;
                              pAclInformation: WD.LPVOID;
                              nAclInformationLength: WD.DWORD;
                              dwAclInformationClass: WN.ACL_INFORMATION_CLASS ): WD.BOOL;

PROCEDURE [_APICALL] SetAclInformation ( VAR STATICTYPED Acl: WN.ACL;
                              pAclInformation: WD.LPVOID;
                              nAclInformationLength: WD.DWORD;
                              dwAclInformationClass: WN.ACL_INFORMATION_CLASS ): WD.BOOL;

PROCEDURE [_APICALL] AddAce ( VAR STATICTYPED Acl: WN.ACL; dwAceRevision: WD.DWORD;
                   dwStartingAceIndex: WD.DWORD; pAceList: WD.LPVOID;
                   nAceListLength: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] DeleteAce ( VAR STATICTYPED Acl: WN.ACL;
                      dwAceIndex: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetAce ( VAR STATICTYPED Acl: WN.ACL; dwAceIndex: WD.DWORD;
                   pAce: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] AddAccessAllowedAce ( VAR STATICTYPED Acl: WN.ACL; dwAceRevision: WD.DWORD;
                                AccessMask: WD.DWORD;
                                pSid: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] AddAccessDeniedAce ( VAR STATICTYPED Acl: WN.ACL; dwAceRevision: WD.DWORD;
                               AccessMask: WD.DWORD;
                               pSid: WN.PSID ): WD.BOOL;

PROCEDURE [_APICALL] AddAuditAccessAce ( VAR STATICTYPED Acl: WN.ACL; dwAceRevision: WD.DWORD;
                              dwAccessMask: WD.DWORD; pSid: WN.PSID;
                              bAuditSuccess: WD.BOOL;
                              bAuditFailure: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] FindFirstFreeAce ( VAR STATICTYPED Acl: WN.ACL;
                             pAce: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] InitializeSecurityDescriptor (
            VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                         dwRevision: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] IsValidSecurityDescriptor ( 
          VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR ): WD.BOOL;

PROCEDURE [_APICALL] GetSecurityDescriptorLength ( 
          VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR ): WD.DWORD;

PROCEDURE [_APICALL] GetSecurityDescriptorControl ( 
                     VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                         VAR Control: WN.SECURITY_DESCRIPTOR_CONTROL;
                                         VAR dwRevision: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetSecurityDescriptorDacl ( 
                    VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      bDaclPresent: WD.BOOL;
                                      VAR STATICTYPED Dacl: WN.ACL;
                                      bDaclDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetSecurityDescriptorDacl ( 
                    VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      VAR bDaclPresent: WD.BOOL;
                                      pDacl: PtrPACL;
                                      lpbDaclDefaulted: WD.LPBOOL ): WD.BOOL;

PROCEDURE [_APICALL] SetSecurityDescriptorSacl ( 
                    VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      bSaclPresent: WD.BOOL;
                                      VAR STATICTYPED Sacl: WN.ACL;
                                      bSaclDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetSecurityDescriptorSacl ( 
                    VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                      VAR bSaclPresent: WD.BOOL;
                                      pSacl: PtrPACL;
                                      VAR bSaclDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] SetSecurityDescriptorOwner ( 
                     VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                       pOwner: WN.PSID;
                                       bOwnerDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetSecurityDescriptorOwner ( 
                     VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                       pOwner: WD.LPVOID;
                                       VAR bOwnerDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] SetSecurityDescriptorGroup ( 
                     VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                       pGroup: WN.PSID;
                                       bGroupDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetSecurityDescriptorGroup ( 
                     VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                                       pGroup: WD.LPVOID;
                                       VAR bGroupDefaulted: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] CreatePrivateObjectSecurity ( 
                    VAR STATICTYPED ParentDescriptor: WN.SECURITY_DESCRIPTOR;
                                        VAR STATICTYPED CreatorDescriptor: WN.SECURITY_DESCRIPTOR;
                                        NewDescriptor: WD.LPVOID;
                                        IsDirectoryObject: WD.BOOL;
                                        Token: WD.HANDLE;
                                        VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING ): WD.BOOL;

PROCEDURE [_APICALL] SetPrivateObjectSecurity ( SecurityInformation: WN.SECURITY_INFORMATION;
                                     VAR STATICTYPED ModificationDescriptor: WN.SECURITY_DESCRIPTOR;
                                     ObjectsSecurityDescriptor: WD.LPVOID;
                                     VAR STATICTYPED GenericMapping: WN.GENERIC_MAPPING;
                                     Token: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] GetPrivateObjectSecurity ( 
                   VAR STATICTYPED ObjectDescriptor: WN.SECURITY_DESCRIPTOR;
                                     SecurityInformation: WN.SECURITY_INFORMATION;
                                     VAR STATICTYPED ResultantDescriptor: WN.SECURITY_DESCRIPTOR;
                                     DescriptorLength: WD.DWORD;
                                     VAR ReturnLength: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] DestroyPrivateObjectSecurity ( ObjectDescriptor: WD.LPVOID ): WD.BOOL;

PROCEDURE [_APICALL] MakeSelfRelativeSD ( 
              VAR STATICTYPED AbsoluteSecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                            VAR STATICTYPED SelfRelativeSecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                            VAR dwBufferLength: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] MakeAbsoluteSD ( 
               VAR STATICTYPED SelfRelativeSecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                           VAR STATICTYPED AbsoluteSecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                           VAR dwAbsoluteSecurityDescriptorSize: WD.DWORD;
                           VAR STATICTYPED Dacl: WN.ACL; VAR dwDaclSize: WD.DWORD;
                           VAR STATICTYPED Sacl: WN.ACL; VAR dwSaclSize: WD.DWORD;
                           pOwner: WN.PSID; VAR dwOwnerSize: WD.DWORD;
                           pPrimaryGroup: WN.PSID;
                           VAR dwPrimaryGroupSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetFileSecurityA ( lpFileName: WD.LPCSTR;
                             SecurityInformation: WN.SECURITY_INFORMATION;
                             VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR ): WD.BOOL;
PROCEDURE [_APICALL] SetFileSecurityW ( lpFileName: WD.LPCWSTR;
                             SecurityInformation: WN.SECURITY_INFORMATION;
                             VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR ): WD.BOOL;
(*  ! SetFileSecurity *)

PROCEDURE [_APICALL] GetFileSecurityA ( lpFileName: WD.LPCSTR;
                             RequestedInformation: WN.SECURITY_INFORMATION;
                             VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                             nLength: WD.DWORD;
                             VAR nLengthNeeded: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetFileSecurityW ( lpFileName: WD.LPCWSTR;
                             RequestedInformation: WN.SECURITY_INFORMATION;
                             VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR;
                             nLength: WD.DWORD;
                             VAR nLengthNeeded: WD.DWORD ): WD.BOOL;
(*  !   GetFileSecurity *)

PROCEDURE [_APICALL] SetKernelObjectSecurity ( Handle: WD.HANDLE;
                              SecurityInformation: WN.SECURITY_INFORMATION;
                              VAR STATICTYPED SecurityDescriptor: WN.SECURITY_DESCRIPTOR ): WD.BOOL;

PROCEDURE [_APICALL] FindFirstChangeNotificationA ( lpPathName: WD.LPCSTR;
                                         bWatchSubtree: WD.BOOL;
                                         dwNotifyFilter: WD.DWORD ): WD.HANDLE;
PROCEDURE [_APICALL] FindFirstChangeNotificationW ( lpPathName: WD.LPCWSTR;
                                         bWatchSubtree: WD.BOOL;
                                         dwNotifyFilter: WD.DWORD ): WD.HANDLE;
(*  !   FindFirstChangeNotification *)

PROCEDURE [_APICALL] FindNextChangeNotification ( hChangeHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] FindCloseChangeNotification ( hChangeHandle: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] ReadDirectoryChangesW ( hDirectory: WD.HANDLE;
                                  lpBuffer: WD.LPVOID;
                                  nBufferLength: WD.DWORD;
                                  bWatchSubtree: WD.BOOL;
                                  dwNotifyFilter: WD.DWORD;
                                  VAR BytesReturned: WD.DWORD;
                                  Overlapped: LONGINT;
                                  lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE ): WD.BOOL;

PROCEDURE [_APICALL] VirtualLock ( lpAddress: WD.LPVOID;
                        dwSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] VirtualUnlock ( lpAddress: WD.LPVOID;
                          dwSize: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] MapViewOfFileEx ( hFileMappingObject: WD.HANDLE;
                            dwDesiredAccess: WD.DWORD;
                            dwFileOffsetHigh: WD.DWORD;
                            dwFileOffsetLow: WD.DWORD;
                            dwNumberOfBytesToMap: WD.DWORD;
                            lpBaseAddress: WD.LPVOID ): WD.LPVOID;

PROCEDURE [_APICALL] SetPriorityClass ( hProcess: WD.HANDLE;
                             dwPriorityClass: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetPriorityClass ( hProcess: WD.HANDLE ): WD.DWORD;

PROCEDURE [_APICALL] IsBadReadPtr ( lp: WD.LPVOID; ucb: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] IsBadWritePtr ( lp: WD.LPVOID;
                          ucb: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] IsBadHugeReadPtr ( lp: WD.LPVOID;
                             ucb: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] IsBadHugeWritePtr ( lp: WD.LPVOID;
                              ucb: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] IsBadCodePtr ( lpfn: WD.FARPROC ): WD.BOOL;

PROCEDURE [_APICALL] IsBadStringPtrA ( lpsz: WD.LPCSTR;
                            ucchMax: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] IsBadStringPtrW ( lpsz: WD.LPCWSTR;
                            ucchMax: WD.UINT ): WD.BOOL;
(*  ! IsBadStringPtr *)

PROCEDURE [_APICALL] LookupAccountSidA ( lpSystemName: WD.LPCSTR; Sid: WN.PSID;
                              Name: WD.LPSTR; VAR cbName: WD.DWORD;
                              ReferencedDomainName: WD.LPSTR;
                              VAR cbReferencedDomainName: WD.DWORD;
                              peUse: WN.PSID_NAME_USE ): WD.BOOL;
PROCEDURE [_APICALL] LookupAccountSidW ( lpSystemName: WD.LPCWSTR; Sid: WN.PSID;
                              Name: WD.LPWSTR; VAR cbName: WD.DWORD;
                              ReferencedDomainName: WD.LPWSTR;
                              VAR cbReferencedDomainName: WD.DWORD;
                              peUse: WN.PSID_NAME_USE ): WD.BOOL;
(*  !   LookupAccountSid *)

PROCEDURE [_APICALL] LookupAccountNameA ( lpSystemName: WD.LPCSTR;
                               lpAccountName: WD.LPCSTR; Sid: WN.PSID;
                               VAR cbSid: WD.DWORD;
                               ReferencedDomainName: WD.LPSTR;
                               VAR cbReferencedDomainName: WD.DWORD;
                               peUse: WN.PSID_NAME_USE ): WD.BOOL;
PROCEDURE [_APICALL] LookupAccountNameW ( lpSystemName: WD.LPCWSTR;
                               lpAccountName: WD.LPCWSTR; Sid: WN.PSID;
                               VAR cbSid: WD.DWORD;
                               ReferencedDomainName: WD.LPWSTR;
                               VAR cbReferencedDomainName: WD.DWORD;
                               VAR eUse: WN.SID_NAME_USE ): WD.BOOL;
(*  !  LookupAccountName *)

PROCEDURE [_APICALL] LookupPrivilegeValueA ( lpSystemName: WD.LPCSTR;
                                  lpName: WD.LPCSTR;
                                  VAR STATICTYPED Luid: WN.LUID ): WD.BOOL;
PROCEDURE [_APICALL] LookupPrivilegeValueW ( lpSystemName: WD.LPCWSTR;
                                  lpName: WD.LPCWSTR;
                                  VAR STATICTYPED Luid: WN.LUID ): WD.BOOL;
(*  !  LookupPrivilegeValue *)

PROCEDURE [_APICALL] LookupPrivilegeNameA ( lpSystemName: WD.LPCSTR;
                                 VAR STATICTYPED Luid: WN.LUID; lpName: WD.LPSTR;
                                 VAR cbName: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] LookupPrivilegeNameW ( lpSystemName: WD.LPCWSTR;
                                 VAR STATICTYPED Luid: WN.LUID; lpName: WD.LPWSTR;
                                 VAR cbName: WD.DWORD ): WD.BOOL;
(*  !   LookupPrivilegeName *)

PROCEDURE [_APICALL] LookupPrivilegeDisplayNameA ( lpSystemName: WD.LPCSTR;
                                        lpName: WD.LPCSTR;
                                        lpDisplayName: WD.LPSTR;
                                        VAR cbDisplayName: WD.DWORD;
                                        VAR LanguageId: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] LookupPrivilegeDisplayNameW ( lpSystemName: WD.LPCWSTR;
                                        lpName: WD.LPCWSTR;
                                        lpDisplayName: WD.LPWSTR;
                                        VAR cbDisplayName: WD.DWORD;
                                        VAR LanguageId: WD.DWORD ): WD.BOOL;
(*  !  LookupPrivilegeDisplayName *)

PROCEDURE [_APICALL] AllocateLocallyUniqueId ( VAR STATICTYPED Luid: WN.LUID ): WD.BOOL;

PROCEDURE [_APICALL] BuildCommDCBA ( lpDef: WD.LPCSTR; VAR STATICTYPED dcb: DCB ): WD.BOOL;
PROCEDURE [_APICALL] BuildCommDCBW ( lpDef: WD.LPCWSTR; VAR STATICTYPED dcb: DCB ): WD.BOOL;
(*  !  BuildCommDCB *)

PROCEDURE [_APICALL] BuildCommDCBAndTimeoutsA ( lpDef: WD.LPCSTR; VAR STATICTYPED dcb: DCB;
                                     VAR STATICTYPED CommTimeouts: COMMTIMEOUTS ): WD.BOOL;
PROCEDURE [_APICALL] BuildCommDCBAndTimeoutsW ( lpDef: WD.LPCWSTR; lpDCB: LPDCB;
                                     lpCommTimeouts: LPCOMMTIMEOUTS ): WD.BOOL;
(*  !  BuildCommDCBAndTimeouts *)

PROCEDURE [_APICALL] CommConfigDialogA ( lpszName: WD.LPCSTR; hWnd: WD.HWND;
                              VAR STATICTYPED CC: COMMCONFIG ): WD.BOOL;
PROCEDURE [_APICALL] CommConfigDialogW ( lpszName: WD.LPCWSTR; hWnd: WD.HWND;
                              VAR STATICTYPED CC: COMMCONFIG ): WD.BOOL;
(*  !  CommConfigDialog *)

PROCEDURE [_APICALL] GetDefaultCommConfigA ( lpszName: WD.LPCSTR; VAR STATICTYPED CC: COMMCONFIG;
                                  VAR dwSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetDefaultCommConfigW ( lpszName: WD.LPCWSTR; VAR STATICTYPED CC: COMMCONFIG;
                                  VAR dwSize: WD.DWORD ): WD.BOOL;
(*  !   GetDefaultCommConfig *)

PROCEDURE [_APICALL] SetDefaultCommConfigA ( lpszName: WD.LPCSTR; VAR STATICTYPED CC: COMMCONFIG;
                                  dwSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] SetDefaultCommConfigW ( lpszName: WD.LPCWSTR; VAR STATICTYPED CC: COMMCONFIG;
                                  dwSize: WD.DWORD ): WD.BOOL;
(*  !  SetDefaultCommConfig *)

PROCEDURE [_APICALL] GetComputerNameA ( lpBuffer: WD.LPSTR;
                             VAR nSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetComputerNameW ( lpBuffer: WD.LPWSTR;
                             VAR nSize: WD.DWORD ): WD.BOOL;
(*  !   GetComputerName*)

PROCEDURE [_APICALL] SetComputerNameA ( lpComputerName: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetComputerNameW ( lpComputerName: WD.LPCWSTR ): WD.BOOL;
(*  ! SetComputerName *)

PROCEDURE [_APICALL] GetUserNameA ( lpBuffer: WD.LPSTR;
                         VAR nSize: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetUserNameW ( lpBuffer: WD.LPWSTR;
                         VAR nSize: WD.DWORD ): WD.BOOL;
(*  !  GetUserName *)

PROCEDURE [_APICALL] LogonUserA ( lpszUsername: WD.LPSTR; lpszDomain: WD.LPSTR;
                       lpszPassword: WD.LPSTR; dwLogonType: WD.DWORD;
                       dwLogonProvider: WD.DWORD;
                       VAR hToken: WD.HANDLE ): WD.BOOL;
PROCEDURE [_APICALL] LogonUserW ( lpszUsername: WD.LPWSTR; lpszDomain: WD.LPWSTR;
                       lpszPassword: WD.LPWSTR; dwLogonType: WD.DWORD;
                       dwLogonProvider: WD.DWORD;
                       VAR hToken: WD.HANDLE ): WD.BOOL;
(*  ! LogonUser *)

PROCEDURE [_APICALL] ImpersonateLoggedOnUser ( hToken: WD.HANDLE ): WD.BOOL;

PROCEDURE [_APICALL] CreateProcessAsUserA ( hToken: WD.HANDLE;
                                 lpApplicationName: WD.LPCSTR;
                                 lpCommandLine: WD.LPSTR;
                                 VAR STATICTYPED ProcessAttributes: SECURITY_ATTRIBUTES;
                                 VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                                 bInheritHandles: WD.BOOL;
                                 dwCreationFlags: WD.DWORD;
                                 lpEnvironment: WD.LPVOID;
                                 lpCurrentDirectory: WD.LPCSTR;
                                 VAR STATICTYPED StartupInfo: STARTUPINFOA;
                 VAR STATICTYPED ProcessInformation: PROCESS_INFORMATION ): WD.BOOL;
PROCEDURE [_APICALL] CreateProcessAsUserW ( hToken: WD.HANDLE;
                                 lpApplicationName: WD.LPCWSTR;
                                 lpCommandLine: WD.LPWSTR;
                                 VAR STATICTYPED ProcessAttributes: SECURITY_ATTRIBUTES;
                                 VAR STATICTYPED ThreadAttributes: SECURITY_ATTRIBUTES;
                                 bInheritHandles: WD.BOOL;
                                 dwCreationFlags: WD.DWORD;
                                 lpEnvironment: WD.LPVOID;
                                 lpCurrentDirectory: WD.LPCWSTR;
                                 VAR STATICTYPED StartupInfo: STARTUPINFOW;
                                 VAR STATICTYPED ProcessInformation: PROCESS_INFORMATION ): WD.BOOL;
(*  !  CreateProcessAsUser *)

PROCEDURE [_APICALL] DuplicateTokenEx ( hExistingToken: WD.HANDLE;
                             dwDesiredAccess: WD.DWORD;
                             VAR STATICTYPED TokenAttributes: SECURITY_ATTRIBUTES;
                             ImpersonationLevel: WN.SECURITY_IMPERSONATION_LEVEL;
                             TokenType: WN.TOKEN_TYPE;
                             VAR hNewToken: WD.HANDLE ): WD.BOOL;


PROCEDURE [_APICALL] GetCurrentHwProfileA ( VAR STATICTYPED HwProfileInfo: HW_PROFILE_INFOA ): WD.BOOL;
PROCEDURE [_APICALL] GetCurrentHwProfileW ( VAR STATICTYPED HwProfileInfo: HW_PROFILE_INFOW ): WD.BOOL;
(*  !  GetCurrentHwProfile *)

(*  Performance counter API's *)

PROCEDURE [_APICALL] QueryPerformanceCounter ( VAR STATICTYPED PerformanceCount: WN.LARGE_INTEGER ): WD.BOOL;

PROCEDURE [_APICALL] QueryPerformanceFrequency ( VAR STATICTYPED Frequency: WN.LARGE_INTEGER ): WD.BOOL;

PROCEDURE [_APICALL] GetVersionExA ( VAR STATICTYPED VersionInformation: OSVERSIONINFOA ): WD.BOOL;
PROCEDURE [_APICALL] GetVersionExW ( VAR STATICTYPED VersionInformation: OSVERSIONINFOW ): WD.BOOL;
(*  ! GetVersionEx *)

(*  DOS and OS/2 Compatible Error Code definitions returned by the Win32 Base *)
(*  API functions. *)

PROCEDURE [_APICALL] GetSystemPowerStatus ( 
              VAR STATICTYPEDSystemPowerStatus: SYSTEM_POWER_STATUS ): WD.BOOL;

PROCEDURE [_APICALL] SetSystemPowerState ( fSuspend: WD.BOOL;
                                fForce: WD.BOOL ): WD.BOOL;

(*  API *)
PROCEDURE [_APICALL] WinSubmitCertificate (
        VAR STATICTYPED Certificate: WIN_CERTIFICATE ): WD.BOOL;

(* ///////////////////////////////////////////////////////////// *)
(*                                                            // *)
(*              Trust API and Structures                      // *)
(*                                                            // *)
(* ///////////////////////////////////////////////////////////// *)

PROCEDURE [_APICALL] WinVerifyTrust ( hwnd: WD.HWND; VAR STATICTYPED ActionID: WN.GUID;
                           ActionData: WD.LPVOID ): LONGINT;

PROCEDURE [_APICALL] WinLoadTrustProvider ( VAR STATICTYPED ActionID: WN.GUID ): WD.BOOL;

END WinBase.
(*Macros
(*                          *)
(*  * Compatibility macros  *)
(*                          *)
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DefineHandleTable ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DefineHandleTable ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] LimitEmsPages ( dw: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / LimitEmsPages ( dw: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] SetSwapAreaSize ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / SetSwapAreaSize ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] LockSegment ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / LockSegment ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] UnlockSegment ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / UnlockSegment ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetCurrentTime ( );
<* ELSE *>
PROCEDURE [_APICALL]  / GetCurrentTime ( );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Yield ( );
<* ELSE *>
PROCEDURE [_APICALL]  / Yield ( );
<* END *>
end Macros*)
(*Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] FreeModule ( hLibModule: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / FreeModule ( hLibModule: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MakeProcInstance ( lpProc; hInstance: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MakeProcInstance ( lpProc; hInstance: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] FreeProcInstance ( lpProc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / FreeProcInstance ( lpProc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GlobalLRUNewest ( h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GlobalLRUNewest ( h: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GlobalLRUOldest ( h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GlobalLRUOldest ( h: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GlobalDiscard ( h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GlobalDiscard ( h: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] LocalDiscard ( h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / LocalDiscard ( h: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros*)
(*Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetFreeSpace ( w: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetFreeSpace ( w: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] UnlockResource ( hResData: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / UnlockResource ( hResData: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEINTATOM ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEINTATOM ( i: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros*)
(*Marcos
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] HasOverlappedIoCompleted ( lpOverlapped: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / HasOverlappedIoCompleted ( lpOverlapped: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros*)

