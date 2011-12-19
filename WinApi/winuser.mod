(******************************************************************************)
(*                                                                            *)
(**)                        DEFINITION WinUser;                             (**)
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
(*  06-03-1997 rel. 1.1 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(* winuser.h -- USER procedure declarations; constant definitions and macros  *)
(******************************************************************************)

(*  for already defined structures or constants  *)
(*  Define API decoration for direct importing of DLL references. *)

IMPORT WD := WinDef, WG := Wingdi;

CONST 
  SB_HORZ = 0;
  SB_VERT = 1;
  SB_CTL = 2;
  SB_BOTH = 3;

(*                         *)
(*  * Scroll Bar Commands  *)
(*                         *)
  SB_LINEUP = 0;
  SB_LINELEFT = 0;
  SB_LINEDOWN = 1;
  SB_LINERIGHT = 1;
  SB_PAGEUP = 2;
  SB_PAGELEFT = 2;
  SB_PAGEDOWN = 3;
  SB_PAGERIGHT = 3;
  SB_THUMBPOSITION = 4;
  SB_THUMBTRACK = 5;
  SB_TOP = 6;
  SB_LEFT = 6;
  SB_BOTTOM = 7;
  SB_RIGHT = 7;
  SB_ENDSCROLL = 8;

(*                           *)
(*  * ShowWindow() Commands  *)
(*                           *)
  SW_HIDE = 0;
  SW_SHOWNORMAL = 1;
  SW_NORMAL = 1;
  SW_SHOWMINIMIZED = 2;
  SW_SHOWMAXIMIZED = 3;
  SW_MAXIMIZE = 3;
  SW_SHOWNOACTIVATE = 4;
  SW_SHOW = 5;
  SW_MINIMIZE = 6;
  SW_SHOWMINNOACTIVE = 7;
  SW_SHOWNA = 8;
  SW_RESTORE = 9;
  SW_SHOWDEFAULT = 10;
  SW_MAX = 10;

(*                               *)
(*  * Old ShowWindow() Commands  *)
(*                               *)
  HIDE_WINDOW = 0;
  SHOW_OPENWINDOW = 1;
  SHOW_ICONWINDOW = 2;
  SHOW_FULLSCREEN = 3;
  SHOW_OPENNOACTIVATE = 4;

(*                                               *)
(*  * Identifiers for the WM_SHOWWINDOW message  *)
(*                                               *)
  SW_PARENTCLOSING = 1;
  SW_OTHERZOOM = 2;
  SW_PARENTOPENING = 3;
  SW_OTHERUNZOOM = 4;

(*                                             *)
(*  * WM_KEYUP/DOWN/char HIWORD(lParam) flags  *)
(*                                             *)
  KF_EXTENDED = 100H;
  KF_DLGMODE = 800H;
  KF_MENUMODE = 1000H;
  KF_ALTDOWN = 2000H;
  KF_REPEAT = 4000H;
  KF_UP = 8000H;

(*                                *)
(*  * Virtual Keys; Standard Set  *)
(*                                *)
  VK_LBUTTON = 1H;
  VK_RBUTTON = 2H;
  VK_CANCEL = 3H;
  VK_MBUTTON = 4H;                     (*  NOT contiguous with L & RBUTTON  *)
  VK_BACK = 8H;
  VK_TAB = 9H;
  VK_CLEAR = 0CH;
  VK_RETURN = 0DH;
  VK_SHIFT = 10H;
  VK_CONTROL = 11H;
  VK_MENU = 12H;
  VK_PAUSE = 13H;
  VK_CAPITAL = 14H;
  VK_ESCAPE = 1BH;
  VK_SPACE = 20H;
  VK_PRIOR = 21H;
  VK_NEXT = 22H;
  VK_END = 23H;
  VK_HOME = 24H;
  VK_LEFT = 25H;
  VK_UP = 26H;
  VK_RIGHT = 27H;
  VK_DOWN = 28H;
  VK_SELECT = 29H;
  VK_PRINT = 2AH;
  VK_EXECUTE = 2BH;
  VK_SNAPSHOT = 2CH;
  VK_INSERT = 2DH;
  VK_DELETE = 2EH;
  VK_HELP = 2FH;

(*  VK_0 thru VK_9 are the same as ASCII '0' thru '9' (0x30 - 0x39)  *)
(*  VK_A thru VK_Z are the same as ASCII 'A' thru 'Z' (0x41 - 0x5A)  *)
  VK_LWIN = 5BH;
  VK_RWIN = 5CH;
  VK_APPS = 5DH;
  VK_NUMPAD0 = 60H;
  VK_NUMPAD1 = 61H;
  VK_NUMPAD2 = 62H;
  VK_NUMPAD3 = 63H;
  VK_NUMPAD4 = 64H;
  VK_NUMPAD5 = 65H;
  VK_NUMPAD6 = 66H;
  VK_NUMPAD7 = 67H;
  VK_NUMPAD8 = 68H;
  VK_NUMPAD9 = 69H;
  VK_MULTIPLY = 6AH;
  VK_ADD = 6BH;
  VK_SEPARATOR = 6CH;
  VK_SUBTRACT = 6DH;
  VK_DECIMAL = 6EH;
  VK_DIVIDE = 6FH;
  VK_F1 = 70H;
  VK_F2 = 71H;
  VK_F3 = 72H;
  VK_F4 = 73H;
  VK_F5 = 74H;
  VK_F6 = 75H;
  VK_F7 = 76H;
  VK_F8 = 77H;
  VK_F9 = 78H;
  VK_F10 = 79H;
  VK_F11 = 7AH;
  VK_F12 = 7BH;
  VK_F13 = 7CH;
  VK_F14 = 7DH;
  VK_F15 = 7EH;
  VK_F16 = 7FH;
  VK_F17 = 80H;
  VK_F18 = 81H;
  VK_F19 = 82H;
  VK_F20 = 83H;
  VK_F21 = 84H;
  VK_F22 = 85H;
  VK_F23 = 86H;
  VK_F24 = 87H;
  VK_NUMLOCK = 90H;
  VK_SCROLL = 91H;

(*                                                                               *)
(*  * VK_L* & VK_R* - left and right Alt; Ctrl and Shift virtual keys.           *)
(*  * Used only as parameters to GetAsyncKeyState() and GetKeyState().           *)
(*  * No other API or message will distinguish left and right keys in this way.  *)
(*                                                                               *)
  VK_LSHIFT = 0A0H;
  VK_RSHIFT = 0A1H;
  VK_LCONTROL = 0A2H;
  VK_RCONTROL = 0A3H;
  VK_LMENU = 0A4H;
  VK_RMENU = 0A5H;
  VK_PROCESSKEY = 0E5H;
  VK_ATTN = 0F6H;
  VK_CRSEL = 0F7H;
  VK_EXSEL = 0F8H;
  VK_EREOF = 0F9H;
  VK_PLAY = 0FAH;
  VK_ZOOM = 0FBH;
  VK_NONAME = 0FCH;
  VK_PA1 = 0FDH;
  VK_OEM_CLEAR = 0FEH;

(*                            *)
(*  * SetWindowsHook() codes  *)
(*                            *)
  WH_MIN = -1;
  WH_MINHOOK = WH_MIN;
  WH_MSGFILTER = -1;
  WH_JOURNALRECORD = 0;
  WH_JOURNALPLAYBACK = 1;
  WH_KEYBOARD = 2;
  WH_GETMESSAGE = 3;
  WH_CALLWNDPROC = 4;
  WH_CBT = 5;
  WH_SYSMSGFILTER = 6;
  WH_MOUSE = 7;
  WH_HARDWARE = 8;
  WH_DEBUG = 9;
  WH_SHELL = 10;
  WH_FOREGROUNDIDLE = 11;
  WH_CALLWNDPROCRET = 12;
  WH_MAX = 12;
  WH_MAXHOOK = WH_MAX;

(*                *)
(*  * Hook Codes  *)
(*                *)

  HC_ACTION = 0;
  HC_GETNEXT = 1;
  HC_SKIP = 2;
  HC_NOREMOVE = 3;
  HC_NOREM = HC_NOREMOVE;
  HC_SYSMODALON = 4;
  HC_SYSMODALOFF = 5;

(*                    *)
(*  * CBT Hook Codes  *)
(*                    *)
  HCBT_MOVESIZE = 0;
  HCBT_MINMAX = 1;
  HCBT_QS = 2;
  HCBT_CREATEWND = 3;
  HCBT_DESTROYWND = 4;
  HCBT_ACTIVATE = 5;
  HCBT_CLICKSKIPPED = 6;
  HCBT_KEYSKIPPED = 7;
  HCBT_SYSCOMMAND = 8;
  HCBT_SETFOCUS = 9;

  DIFFERENCE = 11;
 
  MSGF_DIALOGBOX = 0;
  MSGF_MESSAGEBOX = 1;
  MSGF_MENU = 2;
  MSGF_MOVE = 3;
  MSGF_SIZE = 4;
  MSGF_SCROLLBAR = 5;
  MSGF_NEXTWINDOW = 6;
  MSGF_MAINLOOP = 8;
  MSGF_MAX = 8;
  MSGF_USER = 4096;

(*                   *)
(*  * Shell support  *)
(*                   *)
  HSHELL_WINDOWCREATED = 1;
  HSHELL_WINDOWDESTROYED = 2;
  HSHELL_ACTIVATESHELLWINDOW = 3;
  HSHELL_WINDOWACTIVATED = 4;
  HSHELL_GETMINRECT = 5;
  HSHELL_REDRAW = 6;
  HSHELL_TASKMAN = 7;
  HSHELL_LANGUAGE = 8;
 
  DESKTOP_READOBJECTS = 1H;
  DESKTOP_CREATEWINDOW = 2H;
  DESKTOP_CREATEMENU = 4H;
  DESKTOP_HOOKCONTROL = 8H;
  DESKTOP_JOURNALRECORD = 10H;
  DESKTOP_JOURNALPLAYBACK = 20H;
  DESKTOP_ENUMERATE = 40H;
  DESKTOP_WRITEOBJECTS = 80H;
  DESKTOP_SWITCHDESKTOP = 100H;

(*                                    *)
(*  * Desktop-specific control flags  *)
(*                                    *)
  DF_ALLOWOTHERACCOUNTHOOK = 1H;

  HKL_PREV = 0;
  HKL_NEXT = 1;
  KLF_ACTIVATE = 1H;
  KLF_SUBSTITUTE_OK = 2H;
  KLF_UNLOADPREVIOUS = 4H;
  KLF_REORDER = 8H;
  KLF_REPLACELANG = 10H;
  KLF_NOTELLSHELL = 80H;

(*                                                                                 *)
(*  * Size of KeyboardLayoutName (number of characters); including nul terminator  *)
(*                                                                                 *)
  KL_NAMELENGTH = 9;

(*                                         *)
(*  * Windowstation-specific access flags  *)
(*                                         *)


  WINSTA_ENUMDESKTOPS = 1H;
  WINSTA_READATTRIBUTES = 2H;
  WINSTA_ACCESSCLIPBOARD = 4H;
  WINSTA_CREATEDESKTOP = 8H;
  WINSTA_WRITEATTRIBUTES = 10H;
  WINSTA_ACCESSGLOBALATOMS = 20H;
  WINSTA_EXITWINDOWS = 40H;
  WINSTA_ENUMERATE = 100H;
  WINSTA_READSCREEN = 200H;

(*                                            *)
(*  * Windowstation-specific attribute flags  *)
(*                                            *)
  WSF_VISIBLE = 1H;
 
  UOI_FLAGS = 1;
  UOI_NAME = 2;
  UOI_TYPE = 3;
(*                                              *)
(*  * Window field offsets for GetWindowLong()  *)
(*                                              *)

 
  GWL_WNDPROC = -4;
  GWL_HINSTANCE = -6;
  GWL_HWNDPARENT = -8;
  GWL_STYLE = -16;
  GWL_EXSTYLE = -20;
  GWL_USERDATA = -21;
  GWL_ID = -12;

(*                                            *)
(*  * Class field offsets for GetClassLong()  *)
(*                                            *)
  GCL_MENUNAME = -8;
  GCL_HBRBACKGROUND = -10;
  GCL_HCURSOR = -12;
  GCL_HICON = -14;
  GCL_HMODULE = -16;
  GCL_CBWNDEXTRA = -18;
  GCL_CBCLSEXTRA = -20;
  GCL_WNDPROC = -24;
  GCL_STYLE = -26;
  GCW_ATOM = -32;
  GCL_HICONSM = -34;

(*                     *)
(*  * Window Messages  *)
(*                     *)
  WM_NULL = 0H;
  WM_CREATE = 1H;
  WM_DESTROY = 2H;
  WM_MOVE = 3H;
  WM_SIZE = 5H;
  WM_ACTIVATE = 6H;

(*                              *)
(*  * WM_ACTIVATE state values  *)
(*                              *)
  WA_INACTIVE = 0;
  WA_ACTIVE = 1;
  WA_CLICKACTIVE = 2;
  WM_SETFOCUS = 7H;
  WM_KILLFOCUS = 8H;
  WM_ENABLE = 0AH;
  WM_SETREDRAW = 0BH;
  WM_SETTEXT = 0CH;
  WM_GETTEXT = 0DH;
  WM_GETTEXTLENGTH = 0EH;
  WM_PAINT = 0FH;
  WM_CLOSE = 10H;
  WM_QUERYENDSESSION = 11H;
  WM_QUIT = 12H;
  WM_QUERYOPEN = 13H;
  WM_ERASEBKGND = 14H;
  WM_SYSCOLORCHANGE = 15H;
  WM_ENDSESSION = 16H;
  WM_SHOWWINDOW = 18H;
  WM_WININICHANGE = 1AH;
  WM_SETTINGCHANGE = WM_WININICHANGE;
  WM_DEVMODECHANGE = 1BH;
  WM_ACTIVATEAPP = 1CH;
  WM_FONTCHANGE = 1DH;
  WM_TIMECHANGE = 1EH;
  WM_CANCELMODE = 1FH;
  WM_SETCURSOR = 20H;
  WM_MOUSEACTIVATE = 21H;
  WM_CHILDACTIVATE = 22H;
  WM_QUEUESYNC = 23H;
  WM_GETMINMAXINFO = 24H;

  WM_PAINTICON = 26H;
  WM_ICONERASEBKGND = 27H;
  WM_NEXTDLGCTL = 28H;
  WM_SPOOLERSTATUS = 2AH;
  WM_DRAWITEM = 2BH;
  WM_MEASUREITEM = 2CH;
  WM_DELETEITEM = 2DH;
  WM_VKEYTOITEM = 2EH;
  WM_CHARTOITEM = 2FH;
  WM_SETFONT = 30H;
  WM_GETFONT = 31H;
  WM_SETHOTKEY = 32H;
  WM_GETHOTKEY = 33H;
  WM_QUERYDRAGICON = 37H;
  WM_COMPAREITEM = 39H;
  WM_COMPACTING = 41H;
  WM_WINDOWPOSCHANGING = 46H;
  WM_WINDOWPOSCHANGED = 47H;
  WM_POWER = 48H;

(*   wParam for WM_POWER message and DRV_POWER driver notificaton  *)
  PWR_OK = 1H;
  PWR_FAIL = -1;
  PWR_SUSPENDREQUEST = 1H;
  PWR_SUSPENDRESUME = 2H;
  PWR_CRITICALRESUME = 3H;
  
  WM_COPYDATA = 4AH;
  WM_CANCELJOURNAL = 4BH;
  WM_NOTIFY = 4EH;
  WM_INPUTLANGCHANGEREQUEST = 50H;
  WM_INPUTLANGCHANGE = 51H;
  WM_TCARD = 52H;
  WM_HELP = 53H;
  WM_USERCHANGED = 54H;
  WM_NOTIFYFORMAT = 55H;
  NFR_ANSI = 1;
  NFR_UNICODE = 2;
  NF_QUERY = 3;
  NF_REQUERY = 4;
  WM_CONTEXTMENU = 7BH;
  WM_STYLECHANGING = 7CH;
  WM_STYLECHANGED = 7DH;
  WM_DISPLAYCHANGE = 7EH;
  WM_GETICON = 7FH;
  WM_SETICON = 80H;
  WM_NCCREATE = 81H;
  WM_NCDESTROY = 82H;
  WM_NCCALCSIZE = 83H;
  WM_NCHITTEST = 84H;
  WM_NCPAINT = 85H;
  WM_NCACTIVATE = 86H;
  WM_GETDLGCODE = 87H;
  WM_NCMOUSEMOVE = 0A0H;
  WM_NCLBUTTONDOWN = 0A1H;
  WM_NCLBUTTONUP = 0A2H;
  WM_NCLBUTTONDBLCLK = 0A3H;
  WM_NCRBUTTONDOWN = 0A4H;
  WM_NCRBUTTONUP = 0A5H;
  WM_NCRBUTTONDBLCLK = 0A6H;
  WM_NCMBUTTONDOWN = 0A7H;
  WM_NCMBUTTONUP = 0A8H;
  WM_NCMBUTTONDBLCLK = 0A9H;
  WM_KEYFIRST = 100H;
  WM_KEYDOWN = 100H;
  WM_KEYUP = 101H;
  WM_CHAR = 102H;
  WM_DEADCHAR = 103H;
  WM_SYSKEYDOWN = 104H;
  WM_SYSKEYUP = 105H;
  WM_SYSCHAR = 106H;
  WM_SYSDEADCHAR = 107H;
  WM_KEYLAST = 108H;
  WM_IME_STARTCOMPOSITION = 10DH;
  WM_IME_ENDCOMPOSITION = 10EH;
  WM_IME_COMPOSITION = 10FH;
  WM_IME_KEYLAST = 10FH;
  WM_INITDIALOG = 110H;
  WM_COMMAND = 111H;
  WM_SYSCOMMAND = 112H;
  WM_TIMER = 113H;
  WM_HSCROLL = 114H;
  WM_VSCROLL = 115H;
  WM_INITMENU = 116H;
  WM_INITMENUPOPUP = 117H;
  WM_MENUSELECT = 11FH;
  WM_MENUCHAR = 120H;
  WM_ENTERIDLE = 121H;
  WM_CTLCOLORMSGBOX = 132H;
  WM_CTLCOLOREDIT = 133H;
  WM_CTLCOLORLISTBOX = 134H;
  WM_CTLCOLORBTN = 135H;
  WM_CTLCOLORDLG = 136H;
  WM_CTLCOLORSCROLLBAR = 137H;
  WM_CTLCOLORSTATIC = 138H;
  WM_MOUSEFIRST = 200H;
  WM_MOUSEMOVE = 200H;
  WM_LBUTTONDOWN = 201H;
  WM_LBUTTONUP = 202H;
  WM_LBUTTONDBLCLK = 203H;
  WM_RBUTTONDOWN = 204H;
  WM_RBUTTONUP = 205H;
  WM_RBUTTONDBLCLK = 206H;
  WM_MBUTTONDOWN = 207H;
  WM_MBUTTONUP = 208H;
  WM_MBUTTONDBLCLK = 209H;
  WM_MOUSELAST = 209H;
  WM_PARENTNOTIFY = 210H;
  MENULOOP_WINDOW = 0;
  MENULOOP_POPUP = 1;
  WM_ENTERMENULOOP = 211H;
  WM_EXITMENULOOP = 212H;
  WM_NEXTMENU = 213H;


  WM_SIZING = 214H;
  WM_CAPTURECHANGED = 215H;
  WM_MOVING = 216H;
  WM_POWERBROADCAST = 218H;
  WM_DEVICECHANGE = 219H;
  WM_IME_SETCONTEXT = 281H;
  WM_IME_NOTIFY = 282H;
  WM_IME_CONTROL = 283H;
  WM_IME_COMPOSITIONFULL = 284H;
  WM_IME_SELECT = 285H;
  WM_IME_CHAR = 286H;
  WM_IME_KEYDOWN = 290H;
  WM_IME_KEYUP = 291H;
  WM_MDICREATE = 220H;
  WM_MDIDESTROY = 221H;
  WM_MDIACTIVATE = 222H;
  WM_MDIRESTORE = 223H;
  WM_MDINEXT = 224H;
  WM_MDIMAXIMIZE = 225H;
  WM_MDITILE = 226H;
  WM_MDICASCADE = 227H;
  WM_MDIICONARRANGE = 228H;
  WM_MDIGETACTIVE = 229H;
  WM_MDISETMENU = 230H;
  WM_ENTERSIZEMOVE = 231H;
  WM_EXITSIZEMOVE = 232H;
  WM_DROPFILES = 233H;
  WM_MDIREFRESHMENU = 234H;
  WM_CUT = 300H;
  WM_COPY = 301H;
  WM_PASTE = 302H;
  WM_CLEAR = 303H;
  WM_UNDO = 304H;
  WM_RENDERFORMAT = 305H;
  WM_RENDERALLFORMATS = 306H;
  WM_DESTROYCLIPBOARD = 307H;
  WM_DRAWCLIPBOARD = 308H;
  WM_PAINTCLIPBOARD = 309H;
  WM_VSCROLLCLIPBOARD = 30AH;
  WM_SIZECLIPBOARD = 30BH;
  WM_ASKCBFORMATNAME = 30CH;
  WM_CHANGECBCHAIN = 30DH;
  WM_HSCROLLCLIPBOARD = 30EH;
  WM_QUERYNEWPALETTE = 30FH;
  WM_PALETTEISCHANGING = 310H;
  WM_PALETTECHANGED = 311H;
  WM_HOTKEY = 312H;
  WM_PRINT = 317H;
  WM_PRINTCLIENT = 318H;
  WM_HANDHELDFIRST = 358H;
  WM_HANDHELDLAST = 35FH;
  WM_AFXFIRST = 360H;
  WM_AFXLAST = 37FH;
  WM_PENWINFIRST = 380H;
  WM_PENWINLAST = 38FH;
  WM_APP = 8000H;

(*                                                          *)
(*  * NOTE: All Message Numbers below 0x0400 are RESERVED.  *)
(*  *                                                       *)
(*  * Private Window Messages Start Here:                   *)
(*                                                          *)
  WM_USER = 400H;

(*   wParam for WM_SIZING message   *)
  WMSZ_LEFT = 1;
  WMSZ_RIGHT = 2;
  WMSZ_TOP = 3;
  WMSZ_TOPLEFT = 4;
  WMSZ_TOPRIGHT = 5;
  WMSZ_BOTTOM = 6;
  WMSZ_BOTTOMLEFT = 7;
  WMSZ_BOTTOMRIGHT = 8;

(*                          *)
(*  * WM_SYNCTASK Commands  *)
(*                          *)
  ST_BEGINSWP = 0;
  ST_ENDSWP = 1;

(*                                                           *)
(*  * WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes  *)
(*                                                           *)
  HTERROR = -2;
  HTTRANSPARENT = -1;
  HTNOWHERE = 0;
  HTCLIENT = 1;
  HTCAPTION = 2;
  HTSYSMENU = 3;
  HTGROWBOX = 4;
  HTSIZE = HTGROWBOX;
  HTMENU = 5;
  HTHSCROLL = 6;
  HTVSCROLL = 7;
  HTMINBUTTON = 8;
  HTREDUCE = HTMINBUTTON;
  HTMAXBUTTON = 9;
  HTZOOM = HTMAXBUTTON;
  HTLEFT = 10;
  HTSIZEFIRST = HTLEFT;
  HTRIGHT = 11;
  HTTOP = 12;
  HTTOPLEFT = 13;
  HTTOPRIGHT = 14;
  HTBOTTOM = 15;
  HTBOTTOMLEFT = 16;
  HTBOTTOMRIGHT = 17;
  HTSIZELAST = HTBOTTOMRIGHT;
  HTBORDER = 18;
  HTOBJECT = 19;
  HTCLOSE = 20;
  HTHELP = 21;

(*                               *)
(*  * SendMessageTimeout values  *)
(*                               *)
  SMTO_NORMAL = 0H;
  SMTO_BLOCK = 1H;
  SMTO_ABORTIFHUNG = 2H;

(*                                   *)
(*  * WM_MOUSEACTIVATE Return Codes  *)
(*                                   *)
  MA_ACTIVATE = 1;
  MA_ACTIVATEANDEAT = 2;
  MA_NOACTIVATE = 3;
  MA_NOACTIVATEANDEAT = 4;

(*                                   *)
(*  * WM_SIZE message wParam values  *)
(*                                   *)

  SIZE_RESTORED = 0;
  SIZENORMAL = SIZE_RESTORED;
  SIZE_MINIMIZED = 1;
  SIZEICONIC = SIZE_MINIMIZED;
  SIZE_MAXIMIZED = 2;
  SIZEFULLSCREEN = SIZE_MAXIMIZED;
  SIZE_MAXSHOW = 3;
  SIZEZOOMSHOW = SIZE_MAXSHOW;
  SIZE_MAXHIDE = 4;
  SIZEZOOMHIDE = SIZE_MAXHIDE;

(*                                                     *)
(*  * WM_NCCALCSIZE "window valid rect" return values  *)
(*                                                     *)
 
  WVR_ALIGNTOP = 10H;
  WVR_ALIGNLEFT = 20H;
  WVR_ALIGNBOTTOM = 40H;
  WVR_ALIGNRIGHT = 80H;
  WVR_HREDRAW = 100H;
  WVR_VREDRAW = 200H;
  WVR_REDRAW = 300H;    (*  (WVR_HREDRAW | \
                            WVR_VREDRAW) *)
  WVR_VALIDRECTS = 400H;

(*                                        *)
(*  * Key State Masks for Mouse Messages  *)
(*                                        *)
  MK_LBUTTON = 1H;
  MK_RBUTTON = 2H;
  MK_SHIFT = 4H;
  MK_CONTROL = 8H;
  MK_MBUTTON = 10H;

(*                   *)
(*  * Window Styles  *)
(*                   *)
  WS_OVERLAPPED = 0H;
  WS_TILED = WS_OVERLAPPED;
  WS_POPUP = MIN(LONGINT);
  WS_CHILD = 40000000H;
  WS_MINIMIZE = 20000000H;
  WS_ICONIC = WS_MINIMIZE;
  WS_VISIBLE = 10000000H;
  WS_DISABLED = 8000000H;
  WS_CLIPSIBLINGS = 4000000H;
  WS_CLIPCHILDREN = 2000000H;
  WS_MAXIMIZE = 1000000H;
  WS_CAPTION = 0C00000H;               (*  WS_BORDER | WS_DLGFRAME   *)
  WS_BORDER = 800000H;
  WS_DLGFRAME = 400000H;
  WS_VSCROLL = 200000H;
  WS_HSCROLL = 100000H;
  WS_SYSMENU = 80000H;
  WS_THICKFRAME = 40000H;
  WS_SIZEBOX = WS_THICKFRAME;
  WS_GROUP = 20000H;
  WS_TABSTOP = 10000H;
  WS_MINIMIZEBOX = 20000H;
  WS_MAXIMIZEBOX = 10000H;

(*                          *)
(*  * Common Window Styles  *)
(*                          *)
  WS_OVERLAPPEDWINDOW = 0C80000H;  (*(WS_OVERLAPPED     | \
                             WS_CAPTION        | \
                             WS_SYSMENU        | \
                             WS_THICKFRAME     | \
                             WS_MINIMIZEBOX    | \
                             WS_MAXIMIZEBOX)  ???*)
  WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;
(*  WS_POPUPWINDOW = -2138570752;     (WS_POPUP          | \
                             WS_BORDER         | \
                             WS_SYSMENU) ????*)

  WS_CHILDWINDOW = WS_CHILD;

(*                            *)
(*  * Extended Window Styles  *)
(*                            *)
  WS_EX_DLGMODALFRAME = 1H;
  WS_EX_NOPARENTNOTIFY = 4H;
  WS_EX_TOPMOST = 8H;
  WS_EX_ACCEPTFILES = 10H;
  WS_EX_TRANSPARENT = 20H;
  WS_EX_MDICHILD = 40H;
  WS_EX_TOOLWINDOW = 80H;
  WS_EX_WINDOWEDGE = 100H;
  WS_EX_CLIENTEDGE = 200H;
  WS_EX_CONTEXTHELP = 400H;
  WS_EX_RIGHT = 1000H;
  WS_EX_LEFT = 0H;
  WS_EX_RTLREADING = 2000H;
  WS_EX_LTRREADING = 0H;
  WS_EX_LEFTSCROLLBAR = 4000H;
  WS_EX_RIGHTSCROLLBAR = 0H;
  WS_EX_CONTROLPARENT = 10000H;
  WS_EX_STATICEDGE = 20000H;
  WS_EX_APPWINDOW = 40000H;
  WS_EX_OVERLAPPEDWINDOW = 300H;(* (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE) *)
  WS_EX_PALETTEWINDOW = 188H; (*(WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW 
                  | WS_EX_TOPMOST)*)

(*                  *)
(*  * Class styles  *)
(*                  *)
  CS_VREDRAW = 1H;
  CS_HREDRAW = 2H;
  CS_KEYCVTWINDOW = 4H;
  CS_DBLCLKS = 8H;
  CS_OWNDC = 20H;
  CS_CLASSDC = 40H;
  CS_PARENTDC = 80H;
  CS_NOKEYCVT = 100H;
  CS_NOCLOSE = 200H;
  CS_SAVEBITS = 800H;
  CS_BYTEALIGNCLIENT = 1000H;
  CS_BYTEALIGNWINDOW = 2000H;
  CS_GLOBALCLASS = 4000H;
  CS_IME = 10000H;

(*  WM_PRINT flags  *)
  PRF_CHECKVISIBLE = 1H;
  PRF_NONCLIENT = 2H;
  PRF_CLIENT = 4H;
  PRF_ERASEBKGND = 8H;
  PRF_CHILDREN = 10H;
  PRF_OWNED = 20H;

(*  3D border styles  *)
  BDR_RAISEDOUTER = 1H;
  BDR_SUNKENOUTER = 2H;
  BDR_RAISEDINNER = 4H;
  BDR_SUNKENINNER = 8H;
  BDR_OUTER = 3H;
  BDR_INNER = 0CH;
  BDR_RAISED = 5H;
  BDR_SUNKEN = 0AH;
  EDGE_RAISED = 5H;    (*(BDR_RAISEDOUTER | BDR_RAISEDINNER)*)
  EDGE_SUNKEN = 0AH;  (*(BDR_SUNKENOUTER | BDR_SUNKENINNER)*)
  EDGE_ETCHED = 6H;    (*(BDR_SUNKENOUTER | BDR_RAISEDINNER)*)
  EDGE_BUMP = 9H;      (*(BDR_RAISEDOUTER | BDR_SUNKENINNER)*)

(*  Border flags  *)
  BF_LEFT = 1H;
  BF_TOP = 2H;
  BF_RIGHT = 4H;
  BF_BOTTOM = 8H;
  BF_TOPLEFT = 3H;    (*(BF_TOP | BF_LEFT)*)
  BF_TOPRIGHT = 6H;    (*(BF_TOP | BF_RIGHT)*)
  BF_BOTTOMLEFT = 9H;   (*(BF_BOTTOM | BF_LEFT)*)
  BF_BOTTOMRIGHT = 0CH;  (*(BF_BOTTOM | BF_RIGHT)*)
  BF_RECT = 0FH;       (*(BF_LEFT | BF_TOP | BF_RIGHT | BF_BOTTOM)*)
  BF_DIAGONAL = 10H;

(*  For diagonal lines; the BF_RECT flags specify the end point of the *)
(*  vector bounded by the rectangle parameter. *)
  BF_DIAGONAL_ENDTOPRIGHT = 1CH;   (*(BF_DIAGONAL | BF_TOP | BF_RIGHT)*)
  BF_DIAGONAL_ENDTOPLEFT = 13H;     (*(BF_DIAGONAL | BF_TOP | BF_LEFT)*)
  BF_DIAGONAL_ENDBOTTOMLEFT = 15H; (*(BF_DIAGONAL | BF_BOTTOM | BF_LEFT)*)
  BF_DIAGONAL_ENDBOTTOMRIGHT = 1CH;(*(BF_DIAGONAL | BF_BOTTOM | BF_RIGHT)*)
  BF_MIDDLE = 800H;                    (*  Fill in the middle  *)
  BF_SOFT = 1000H;                     (*  For softer buttons  *)
  BF_ADJUST = 2000H;                   (*  Calculate the space left over  *)
  BF_FLAT = 4000H;                     (*  For flat rather than 3D borders  *)
  BF_MONO = 8000H;                     (*  For monochrome borders  *)

(*  flags for DrawFrameControl  *)

  DFC_CAPTION = 1;
  DFC_MENU = 2;
  DFC_SCROLL = 3;
  DFC_BUTTON = 4;
  DFCS_CAPTIONCLOSE = 0H;
  DFCS_CAPTIONMIN = 1H;
  DFCS_CAPTIONMAX = 2H;
  DFCS_CAPTIONRESTORE = 3H;
  DFCS_CAPTIONHELP = 4H;
  DFCS_MENUARROW = 0H;
  DFCS_MENUCHECK = 1H;
  DFCS_MENUBULLET = 2H;
  DFCS_MENUARROWRIGHT = 4H;
  DFCS_SCROLLUP = 0H;
  DFCS_SCROLLDOWN = 1H;
  DFCS_SCROLLLEFT = 2H;
  DFCS_SCROLLRIGHT = 3H;
  DFCS_SCROLLCOMBOBOX = 5H;
  DFCS_SCROLLSIZEGRIP = 8H;
  DFCS_SCROLLSIZEGRIPRIGHT = 10H;
  DFCS_BUTTONCHECK = 0H;
  DFCS_BUTTONRADIOIMAGE = 1H;
  DFCS_BUTTONRADIOMASK = 2H;
  DFCS_BUTTONRADIO = 4H;
  DFCS_BUTTON3STATE = 8H;
  DFCS_BUTTONPUSH = 10H;
  DFCS_INACTIVE = 100H;
  DFCS_PUSHED = 200H;
  DFCS_CHECKED = 400H;
  DFCS_ADJUSTRECT = 2000H;
  DFCS_FLAT = 4000H;
  DFCS_MONO = 8000H;

(*  flags for DrawCaption  *)

  DC_ACTIVE = 1H;
  DC_SMALLCAP = 2H;
  DC_ICON = 4H;
  DC_TEXT = 8H;
  DC_INBUTTON = 10H;
 
  IDANI_OPEN = 1;
  IDANI_CLOSE = 2;
  IDANI_CAPTION = 3;

(*                                  *)
(*  * Predefined Clipboard Formats  *)
(*                                  *)
 
  CF_TEXT = 1;
  CF_BITMAP = 2;
  CF_METAFILEPICT = 3;
  CF_SYLK = 4;
  CF_DIF = 5;
  CF_TIFF = 6;
  CF_OEMTEXT = 7;
  CF_DIB = 8;
  CF_PALETTE = 9;
  CF_PENDATA = 10;
  CF_RIFF = 11;
  CF_WAVE = 12;
  CF_UNICODETEXT = 13;
  CF_ENHMETAFILE = 14;
  CF_HDROP = 15;
  CF_LOCALE = 16;
  CF_MAX = 17;
  CF_OWNERDISPLAY = 80H;
  CF_DSPTEXT = 81H;
  CF_DSPBITMAP = 82H;
  CF_DSPMETAFILEPICT = 83H;
  CF_DSPENHMETAFILE = 8EH;

(*                                                *)
(*  * "Private" formats don't get GlobalFree()'d  *)
(*                                                *)
  CF_PRIVATEFIRST = 200H;
  CF_PRIVATELAST = 2FFH;

(*                                              *)
(*  * "GDIOBJ" formats do get DeleteObject()'d  *)
(*                                              *)
  CF_GDIOBJFIRST = 300H;
  CF_GDIOBJLAST = 3FFH;

(*                                                                     *)
(*  * Defines for the fVirt field of the Accelerator table structure.  *)
(*                                                                     *)
  FNOINVERT = 2H;
  FSHIFT = 4H;
  FCONTROL = 8H;
  FALT = 10H;

  WPF_SETMINPOSITION = 1H;
  WPF_RESTORETOMAXIMIZED = 2H;

(*                              *)
(*  * Owner draw control types  *)
(*                              *)
 
  ODT_MENU = 1;
  ODT_LISTBOX = 2;
  ODT_COMBOBOX = 3;
  ODT_BUTTON = 4;
  ODT_STATIC = 5;

(*                        *)
(*  * Owner draw actions  *)
(*                        *)
  ODA_DRAWENTIRE = 1H;
  ODA_SELECT = 2H;
  ODA_FOCUS = 4H;

(*                      *)
(*  * Owner draw state  *)
(*                      *)
  ODS_SELECTED = 1H;
  ODS_GRAYED = 2H;
  ODS_DISABLED = 4H;
  ODS_CHECKED = 8H;
  ODS_FOCUS = 10H;
  ODS_DEFAULT = 20H;
  ODS_COMBOBOXEDIT = 1000H;

(*                           *)
(*  * PeekMessage() Options  *)
(*                           *)
 
  PM_NOREMOVE = 0H;
  PM_REMOVE = 1H;
  PM_NOYIELD = 2H;

  MOD_ALT = 1H;
  MOD_CONTROL = 2H;
  MOD_SHIFT = 4H;
  MOD_WIN = 8H;
  IDHOT_SNAPWINDOW = -1;               (*  SHIFT-PRINTSCRN   *)
  IDHOT_SNAPDESKTOP = -2;              (*  PRINTSCRN         *)
  EW_RESTARTWINDOWS = 42H;
  EW_REBOOTSYSTEM = 43H;
  EW_EXITANDEXECAPP = 44H;
  EWX_LOGOFF = 0;
  EWX_SHUTDOWN = 1;
  EWX_REBOOT = 2;
  EWX_FORCE = 4;
  EWX_POWEROFF = 8;

(* Broadcast Special Message Recipient list *)

  BSM_ALLCOMPONENTS = 0H;
  BSM_VXDS = 1H;
  BSM_NETDRIVER = 2H;
  BSM_INSTALLABLEDRIVERS = 4H;
  BSM_APPLICATIONS = 8H;

(* Broadcast Special Message Flags *)
  BSF_QUERY = 1H;
  BSF_IGNORECURRENTTASK = 2H;
  BSF_FLUSHDISK = 4H;
  BSF_NOHANG = 8H;
  BSF_POSTMESSAGE = 10H;
  BSF_FORCEIFHUNG = 20H;
  BSF_NOTIMEOUTIFNOTHUNG = 40H;

  DBWF_LPARAMPOINTER = 8000H;
  BROADCAST_QUERY_DENY = 424D5144H;    (*  Return this value to deny a query. *)

  HWND_BROADCAST = 65535;

(*                        *)
(*  * SetWindowPos Flags  *)
(*                        *)


  SWP_NOSIZE = 1H;
  SWP_NOMOVE = 2H;
  SWP_NOZORDER = 4H;
  SWP_NOREDRAW = 8H;
  SWP_NOACTIVATE = 10H;
  SWP_FRAMECHANGED = 20H;              (*  The frame changed: send WM_NCCALCSIZE  *)
  SWP_DRAWFRAME = SWP_FRAMECHANGED;
  SWP_SHOWWINDOW = 40H;
  SWP_HIDEWINDOW = 80H;
  SWP_NOCOPYBITS = 100H;
  SWP_NOOWNERZORDER = 200H;            (*  Don't do owner Z ordering  *)
  SWP_NOREPOSITION = SWP_NOOWNERZORDER;
  SWP_NOSENDCHANGING = 400H;           (*  Don't send WM_WINDOWPOSCHANGING  *)
  SWP_DEFERERASE = 2000H;
  SWP_ASYNCWINDOWPOS = 4000H;
  HWND_TOP = 0;
  HWND_BOTTOM = 1;
  HWND_TOPMOST = -1;
  HWND_NOTOPMOST = -2;


  DLGWINDOWEXTRA = 30;
 
  KEYEVENTF_EXTENDEDKEY = 1H;
  KEYEVENTF_KEYUP = 2H;

  MOUSEEVENTF_MOVE = 1H;               (*  mouse move  *)
  MOUSEEVENTF_LEFTDOWN = 2H;           (*  left button down  *)
  MOUSEEVENTF_LEFTUP = 4H;             (*  left button up  *)
  MOUSEEVENTF_RIGHTDOWN = 8H;          (*  right button down  *)
  MOUSEEVENTF_RIGHTUP = 10H;           (*  right button up  *)
  MOUSEEVENTF_MIDDLEDOWN = 20H;        (*  middle button down  *)
  MOUSEEVENTF_MIDDLEUP = 40H;          (*  middle button up  *)
  MOUSEEVENTF_ABSOLUTE = 8000H;        (*  absolute move  *)   

 
  CW_USEDEFAULT = MIN(LONGINT);   (*#define CW_USEDEFAULT       ((int)0x80000000)*)

(*                                            *)
(*  * Special value for CreateWindow; et al.  *)
(*                                            *)
  HWND_DESKTOP = 0;
  
(*                                                                             *)
(*  * Queue status flags for GetQueueStatus() and MsgWaitForMultipleObjects()  *)
(*                                                                             *)


  QS_KEY = 1H;
  QS_MOUSEMOVE = 2H;
  QS_MOUSEBUTTON = 4H;
  QS_POSTMESSAGE = 8H;
  QS_TIMER = 10H;
  QS_PAINT = 20H;
  QS_SENDMESSAGE = 40H;
  QS_HOTKEY = 80H;
  QS_MOUSE = 6H;      (* (QS_MOUSEMOVE     | \
                            QS_MOUSEBUTTON)   *)
  QS_INPUT = 7H;        (* (QS_MOUSE         | \
                                  QS_KEY)  *)
  QS_ALLEVENTS = 0BFH;    (* (QS_INPUT         | \
                            QS_POSTMESSAGE   | \
                            QS_TIMER         | \
                            QS_PAINT         | \
                            QS_HOTKEY)*)
  QS_ALLINPUT = 0FFH;    (* (QS_INPUT         | \
                            QS_POSTMESSAGE   | \
                            QS_TIMER         | \
                            QS_PAINT         | \
                            QS_HOTKEY        | \
                            QS_SENDMESSAGE)  *)

(*                              *)
(*  * GetSystemMetrics() codes  *)
(*                              *)

  SM_CXSCREEN = 0;
  SM_CYSCREEN = 1;
  SM_CXVSCROLL = 2;
  SM_CYHSCROLL = 3;
  SM_CYCAPTION = 4;
  SM_CXBORDER = 5;
  SM_CYBORDER = 6;
  SM_CXDLGFRAME = 7;
  SM_CXFIXEDFRAME = SM_CXDLGFRAME;     (*  ;win40 name change  *)
  SM_CYDLGFRAME = 8;
  SM_CYFIXEDFRAME = SM_CYDLGFRAME;     (*  ;win40 name change  *)
  SM_CYVTHUMB = 9;
  SM_CXHTHUMB = 10;
  SM_CXICON = 11;
  SM_CYICON = 12;
  SM_CXCURSOR = 13;
  SM_CYCURSOR = 14;
  SM_CYMENU = 15;
  SM_CXFULLSCREEN = 16;
  SM_CYFULLSCREEN = 17;
  SM_CYKANJIWINDOW = 18;
  SM_MOUSEPRESENT = 19;
  SM_CYVSCROLL = 20;
  SM_CXHSCROLL = 21;
  SM_DEBUG = 22;
  SM_SWAPBUTTON = 23;
  SM_RESERVED1 = 24;
  SM_RESERVED2 = 25;
  SM_RESERVED3 = 26;
  SM_RESERVED4 = 27;
  SM_CXMIN = 28;
  SM_CYMIN = 29;
  SM_CXSIZE = 30;
  SM_CYSIZE = 31;
  SM_CXFRAME = 32;
  SM_CXSIZEFRAME = SM_CXFRAME;         (*  ;win40 name change  *)
  SM_CYFRAME = 33;
  SM_CYSIZEFRAME = SM_CYFRAME;         (*  ;win40 name change  *)
  SM_CXMINTRACK = 34;
  SM_CYMINTRACK = 35;
  SM_CXDOUBLECLK = 36;
  SM_CYDOUBLECLK = 37;
  SM_CXICONSPACING = 38;
  SM_CYICONSPACING = 39;
  SM_MENUDROPALIGNMENT = 40;
  SM_PENWINDOWS = 41;
  SM_DBCSENABLED = 42;
  SM_CMOUSEBUTTONS = 43;
  SM_SECURE = 44;
  SM_CXEDGE = 45;
  SM_CYEDGE = 46;
  SM_CXMINSPACING = 47;
  SM_CYMINSPACING = 48;
  SM_CXSMICON = 49;
  SM_CYSMICON = 50;
  SM_CYSMCAPTION = 51;
  SM_CXSMSIZE = 52;
  SM_CYSMSIZE = 53;
  SM_CXMENUSIZE = 54;
  SM_CYMENUSIZE = 55;
  SM_ARRANGE = 56;
  SM_CXMINIMIZED = 57;
  SM_CYMINIMIZED = 58;
  SM_CXMAXTRACK = 59;
  SM_CYMAXTRACK = 60;
  SM_CXMAXIMIZED = 61;
  SM_CYMAXIMIZED = 62;
  SM_NETWORK = 63;
  SM_CLEANBOOT = 67;
  SM_CXDRAG = 68;
  SM_CYDRAG = 69;
  SM_SHOWSOUNDS = 70;
  SM_CXMENUCHECK = 71;                 (*  Use instead of GetMenuCheckMarkDimensions()!  *)
  SM_CYMENUCHECK = 72;
  SM_SLOWMACHINE = 73;
  SM_MIDEASTENABLED = 74;
  SM_CMETRICS = 75;

(*  return codes for WM_MENUCHAR  *)
 
  MNC_IGNORE = 0;
  MNC_CLOSE = 1;
  MNC_EXECUTE = 2;
  MNC_SELECT = 3;

  MIIM_STATE = 1H;
  MIIM_ID = 2H;
  MIIM_SUBMENU = 4H;
  MIIM_CHECKMARKS = 8H;
  MIIM_TYPE = 10H;
  MIIM_DATA = 20H;
 
(*                              *)
(*  * Flags for TrackPopupMenu  *)
(*                              *)

  TPM_LEFTBUTTON = 0H;
  TPM_RIGHTBUTTON = 2H;
  TPM_LEFTALIGN = 0H;
  TPM_CENTERALIGN = 4H;
  TPM_RIGHTALIGN = 8H;
  TPM_TOPALIGN = 0H;
  TPM_VCENTERALIGN = 10H;
  TPM_BOTTOMALIGN = 20H;
  TPM_HORIZONTAL = 0H;                 (*  Horz alignment matters more  *)
  TPM_VERTICAL = 40H;                  (*  Vert alignment matters more  *)
  TPM_NONOTIFY = 80H;                  (*  Don't send any notification msgs  *)
  TPM_RETURNCMD = 100H;

  DOF_EXECUTABLE = 8001H;
  DOF_DOCUMENT = 8002H;
  DOF_DIRECTORY = 8003H;
  DOF_MULTIPLE = 8004H;
  DOF_PROGMAN = 1H;
  DOF_SHELLDATA = 2H;
  DO_DROPFILE = 454C4946H;
  DO_PRINTFILE = 544E5250H;

  GMDI_USEDISABLED = 1H;
  GMDI_GOINTOPOPUPS = 2H;

(*                             *)
(*  * DrawText() Format Flags  *)
(*                             *)

  DT_TOP = 0H;
  DT_LEFT = 0H;
  DT_CENTER = 1H;
  DT_RIGHT = 2H;
  DT_VCENTER = 4H;
  DT_BOTTOM = 8H;
  DT_WORDBREAK = 10H;
  DT_SINGLELINE = 20H;
  DT_EXPANDTABS = 40H;
  DT_TABSTOP = 80H;
  DT_NOCLIP = 100H;
  DT_EXTERNALLEADING = 200H;
  DT_CALCRECT = 400H;
  DT_NOPREFIX = 800H;
  DT_INTERNAL = 1000H;
  DT_EDITCONTROL = 2000H;
  DT_PATH_ELLIPSIS = 4000H;
  DT_END_ELLIPSIS = 8000H;
  DT_MODIFYSTRING = 10000H;
  DT_RTLREADING = 20000H;
  DT_WORD_ELLIPSIS = 40000H;

(*  Monolithic state-drawing routine  *)
(*  Image type  *)
 
  DST_COMPLEX = 0H;
  DST_TEXT = 1H;
  DST_PREFIXTEXT = 2H;
  DST_ICON = 3H;
  DST_BITMAP = 4H;

(*  State type  *)
  DSS_NORMAL = 0H;
  DSS_UNION = 10H;                     (*  Gray string appearance  *)
  DSS_DISABLED = 20H;
  DSS_MONO = 80H;
  DSS_RIGHT = 8000H;

(*                     *)
(*  * GetDCEx() flags  *)
(*                     *)
  DCX_WINDOW = 1H;
  DCX_CACHE = 2H;
  DCX_NORESETATTRS = 4H;
  DCX_CLIPCHILDREN = 8H;
  DCX_CLIPSIBLINGS = 10H;
  DCX_PARENTCLIP = 20H;
  DCX_EXCLUDERGN = 40H;
  DCX_INTERSECTRGN = 80H;
  DCX_EXCLUDEUPDATE = 100H;
  DCX_INTERSECTUPDATE = 200H;
  DCX_LOCKWINDOWUPDATE = 400H;
  DCX_VALIDATE = 200000H;  

(*                          *)
(*  * RedrawWindow() flags  *)
(*                          *)

  RDW_INVALIDATE = 1H;
  RDW_INTERNALPAINT = 2H;
  RDW_ERASE = 4H;
  RDW_VALIDATE = 8H;
  RDW_NOINTERNALPAINT = 10H;
  RDW_NOERASE = 20H;
  RDW_NOCHILDREN = 40H;
  RDW_ALLCHILDREN = 80H;
  RDW_UPDATENOW = 100H;
  RDW_ERASENOW = 200H;
  RDW_FRAME = 400H;
  RDW_NOFRAME = 800H;

(*                             *)
(*  * EnableScrollBar() flags  *)
(*                             *)
 
  ESB_ENABLE_BOTH = 0H;
  ESB_DISABLE_BOTH = 3H;
  ESB_DISABLE_LEFT = 1H;
  ESB_DISABLE_LTUP = ESB_DISABLE_LEFT;
  ESB_DISABLE_RIGHT = 2H;
  ESB_DISABLE_RTDN = ESB_DISABLE_RIGHT;
  ESB_DISABLE_UP = 1H;
  ESB_DISABLE_DOWN = 2H;

(*                        *)
(*  * MessageBox() Flags  *)
(*                        *)
 
  MB_OK = 0H;
  MB_OKCANCEL = 1H;
  MB_ABORTRETRYIGNORE = 2H;
  MB_YESNOCANCEL = 3H;
  MB_YESNO = 4H;
  MB_RETRYCANCEL = 5H;
  MB_ICONHAND = 10H;
  MB_ICONSTOP = MB_ICONHAND;
  MB_ICONERROR = MB_ICONHAND;
  MB_ICONQUESTION = 20H;
  MB_ICONEXCLAMATION = 30H;
  MB_ICONWARNING = MB_ICONEXCLAMATION;
  MB_ICONASTERISK = 40H;
  MB_ICONINFORMATION = MB_ICONASTERISK;
  MB_DEFBUTTON1 = 0H;
  MB_DEFBUTTON2 = 100H;
  MB_DEFBUTTON3 = 200H;
  MB_DEFBUTTON4 = 300H;
  MB_APPLMODAL = 0H;
  MB_SYSTEMMODAL = 1000H;
  MB_TASKMODAL = 2000H;
  MB_HELP = 4000H;                     (*  Help Button *)
  MB_RIGHT = 80000H;
  MB_RTLREADING = 100000H;
  MB_NOFOCUS = 8000H;
  MB_SETFOREGROUND = 10000H;
  MB_DEFAULT_DESKTOP_ONLY = 20000H;
 (* MB_SERVICE_NOTIFICATION = 40000H;*)
  MB_TYPEMASK = 0FH;
  MB_USERICON = 80H;
  MB_ICONMASK = 0F0H;
  MB_DEFMASK = 0F00H;
  MB_MODEMASK = 3000H;
  MB_MISCMASK = 0C000H;
 
  SW_SCROLLCHILDREN = 1H;              (*  Scroll children within *lprcScroll.  *)
  SW_INVALIDATE = 2H;                  (*  Invalidate after scrolling  *)
  SW_ERASE = 4H;                       (*  If SW_INVALIDATE; don't send WM_ERASEBACKGROUND  *)
 
  HELPINFO_WINDOW = 1H;
  HELPINFO_MENUITEM = 2H;
 
  CWP_ALL = 0H;
  CWP_SKIPINVISIBLE = 1H;
  CWP_SKIPDISABLED = 2H;
  CWP_SKIPTRANSPARENT = 4H;

(*                 *)
(*  * Color Types  *)
(*                 *)

  CTLCOLOR_MSGBOX = 0;
  CTLCOLOR_EDIT = 1;
  CTLCOLOR_LISTBOX = 2;
  CTLCOLOR_BTN = 3;
  CTLCOLOR_DLG = 4;
  CTLCOLOR_SCROLLBAR = 5;
  CTLCOLOR_STATIC = 6;
  CTLCOLOR_MAX = 7;
  COLOR_SCROLLBAR = 0;
  COLOR_BACKGROUND = 1;
  COLOR_DESKTOP = COLOR_BACKGROUND;
  COLOR_ACTIVECAPTION = 2;
  COLOR_INACTIVECAPTION = 3;
  COLOR_MENU = 4;
  COLOR_WINDOW = 5;
  COLOR_WINDOWFRAME = 6;
  COLOR_MENUTEXT = 7;
  COLOR_WINDOWTEXT = 8;
  COLOR_CAPTIONTEXT = 9;
  COLOR_ACTIVEBORDER = 10;
  COLOR_INACTIVEBORDER = 11;
  COLOR_APPWORKSPACE = 12;
  COLOR_HIGHLIGHT = 13;
  COLOR_HIGHLIGHTTEXT = 14;
  COLOR_BTNFACE = 15;
  COLOR_3DFACE = COLOR_BTNFACE;
  COLOR_BTNSHADOW = 16;
  COLOR_3DSHADOW = COLOR_BTNSHADOW;
  COLOR_GRAYTEXT = 17;
  COLOR_BTNTEXT = 18;
  COLOR_INACTIVECAPTIONTEXT = 19;
  COLOR_BTNHIGHLIGHT = 20;
  COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DDKSHADOW = 21;
  COLOR_3DLIGHT = 22;
  COLOR_INFOTEXT = 23;
  COLOR_INFOBK = 24;

 MB_TOPMOST = 40000H;

(*                           *)
(*  * GetWindow() Constants  *)
(*                           *)

  GW_HWNDFIRST = 0;
  GW_HWNDLAST = 1;
  GW_HWNDNEXT = 2;
  GW_HWNDPREV = 3;
  GW_OWNER = 4;
  GW_CHILD = 5;
  GW_MAX = 5;

(*  ;win40  -- A lot of MF_* flags have been renamed as MFT_* and MFS_* flags  *)
(*                                               *)
(*  * Menu flags for Add/Check/EnableMenuItem()  *)
(*                                               *)

  MF_INSERT = 0H;
  MF_CHANGE = 80H;
  MF_APPEND = 100H;
  MF_DELETE = 200H;
  MF_REMOVE = 1000H;
  MF_BYCOMMAND = 0H;
  MF_BYPOSITION = 400H;
  MF_SEPARATOR = 800H;
  MFT_SEPARATOR = MF_SEPARATOR;
  MF_ENABLED = 0H;
  MFS_ENABLED = MF_ENABLED;
  MF_GRAYED = 1H;
  MF_DISABLED = 2H;
  MF_UNCHECKED = 0H;
  MFS_UNCHECKED = MF_UNCHECKED;
  MF_CHECKED = 8H;
  MFS_CHECKED = MF_CHECKED;
  MF_USECHECKBITMAPS = 200H;
  MF_STRING = 0H;
  MFT_STRING = MF_STRING;
  MF_BITMAP = 4H;
  MFT_BITMAP = MF_BITMAP;
  MF_OWNERDRAW = 100H;
  MFT_OWNERDRAW = MF_OWNERDRAW;
  MF_POPUP = 10H;
  MF_MENUBARBREAK = 20H;
  MFT_MENUBARBREAK = MF_MENUBARBREAK;
  MF_MENUBREAK = 40H;
  MFT_MENUBREAK = MF_MENUBREAK;
  MF_UNHILITE = 0H;
  MFS_UNHILITE = MF_UNHILITE;
  MF_HILITE = 80H;
  MFS_HILITE = MF_HILITE;
  MF_DEFAULT = 1000H;
  MFS_DEFAULT = MF_DEFAULT;
  MF_SYSMENU = 2000H;
  MF_HELP = 4000H;
  MF_RIGHTJUSTIFY = 4000H;
  MFT_RIGHTJUSTIFY = MF_RIGHTJUSTIFY;
  MF_MOUSESELECT = 8000H;
  MF_END = 80H;                        (*  Obsolete -- only used by old RES files  *)
  MFT_RADIOCHECK = 200H;
  MFT_RIGHTORDER = 2000H;

(*  Menu flags for Add/Check/EnableMenuItem()  *)
  MFS_GRAYED = 3H;
  MFS_DISABLED = MFS_GRAYED;

(*                                *)
(*  * System Menu Command Values  *)
(*                                *)

 
  SC_SIZE = 0F000H;
  SC_MOVE = 0F010H;
  SC_MINIMIZE = 0F020H;
  SC_ICON = SC_MINIMIZE;
  SC_MAXIMIZE = 0F030H;
  SC_ZOOM = SC_MAXIMIZE;
  SC_NEXTWINDOW = 0F040H;
  SC_PREVWINDOW = 0F050H;
  SC_CLOSE = 0F060H;
  SC_VSCROLL = 0F070H;
  SC_HSCROLL = 0F080H;
  SC_MOUSEMENU = 0F090H;
  SC_KEYMENU = 0F100H;
  SC_ARRANGE = 0F110H;
  SC_RESTORE = 0F120H;
  SC_TASKLIST = 0F130H;
  SC_SCREENSAVE = 0F140H;
  SC_HOTKEY = 0F150H;
  SC_DEFAULT = 0F160H;
  SC_MONITORPOWER = 0F170H;
  SC_CONTEXTHELP = 0F180H;
  SC_SEPARATOR = 0F00FH;

  IMAGE_BITMAP = 0;
  IMAGE_ICON = 1;
  IMAGE_CURSOR = 2;
  IMAGE_ENHMETAFILE = 3;
  LR_DEFAULTCOLOR = 0H;
  LR_MONOCHROME = 1H;
  LR_COLOR = 2H;
  LR_COPYRETURNORG = 4H;
  LR_COPYDELETEORG = 8H;
  LR_LOADFROMFILE = 10H;
  LR_LOADTRANSPARENT = 20H;
  LR_DEFAULTSIZE = 40H;
  LR_LOADMAP3DCOLORS = 1000H;
  LR_CREATEDIBSECTION = 2000H;
  LR_COPYFROMRESOURCE = 4000H;
  LR_SHARED = 8000H;

  DI_MASK = 1H;
  DI_IMAGE = 2H;
  DI_NORMAL = 3H;
  DI_COMPAT = 4H;
  DI_DEFAULTSIZE = 8H;


  RES_ICON = 1;
  RES_CURSOR = 2;
  ORD_LANGDRIVER = 1;                  (*     The ordinal number for the entry point of  *)
                                       (*  ** language drivers.                          *)
                                       (*                                                *)

(*                            *)
(*  * Dialog Box Command IDs  *)
(*                            *)
 
  IDOK = 1;
  IDCANCEL = 2;
  IDABORT = 3;
  IDRETRY = 4;
  IDIGNORE = 5;
  IDYES = 6;
  IDNO = 7;
  IDCLOSE = 8;
  IDHELP = 9;

(*                                                *)
(*  * Control Manager Structures and Definitions  *)
(*                                                *)
(*                         *)
(*  * Edit Control Styles  *)
(*                         *)
  ES_LEFT = 0H;
  ES_CENTER = 1H;
  ES_RIGHT = 2H;
  ES_MULTILINE = 4H;
  ES_UPPERCASE = 8H;
  ES_LOWERCASE = 10H;
  ES_PASSWORD = 20H;
  ES_AUTOVSCROLL = 40H;
  ES_AUTOHSCROLL = 80H;
  ES_NOHIDESEL = 100H;
  ES_OEMCONVERT = 400H;
  ES_READONLY = 800H;
  ES_WANTRETURN = 1000H;
  ES_NUMBER = 2000H;

(*                                     *)
(*  * Edit Control Notification Codes  *)
(*                                     *)
  EN_SETFOCUS = 100H;
  EN_KILLFOCUS = 200H;
  EN_CHANGE = 300H;
  EN_UPDATE = 400H;
  EN_ERRSPACE = 500H;
  EN_MAXTEXT = 501H;
  EN_HSCROLL = 601H;
  EN_VSCROLL = 602H;

(*  Edit control EM_SETMARGIN parameters  *)
  EC_LEFTMARGIN = 1H;
  EC_RIGHTMARGIN = 2H;
  EC_USEFONTINFO = 0FFFFH;

(*                           *)
(*  * Edit Control Messages  *)
(*                           *)
  EM_GETSEL = 0B0H;
  EM_SETSEL = 0B1H;
  EM_GETRECT = 0B2H;
  EM_SETRECT = 0B3H;
  EM_SETRECTNP = 0B4H;
  EM_SCROLL = 0B5H;
  EM_LINESCROLL = 0B6H;
  EM_SCROLLCARET = 0B7H;
  EM_GETMODIFY = 0B8H;
  EM_SETMODIFY = 0B9H;
  EM_GETLINECOUNT = 0BAH;
  EM_LINEINDEX = 0BBH;
  EM_SETHANDLE = 0BCH;
  EM_GETHANDLE = 0BDH;
  EM_GETTHUMB = 0BEH;
  EM_LINELENGTH = 0C1H;
  EM_REPLACESEL = 0C2H;
  EM_GETLINE = 0C4H;
  EM_LIMITTEXT = 0C5H;
  EM_SETLIMITTEXT = EM_LIMITTEXT;      (*  ;win40 Name change  *)
  EM_CANUNDO = 0C6H;
  EM_UNDO = 0C7H;
  EM_FMTLINES = 0C8H;
  EM_LINEFROMCHAR = 0C9H;
  EM_SETTABSTOPS = 0CBH;
  EM_SETPASSWORDCHAR = 0CCH;
  EM_EMPTYUNDOBUFFER = 0CDH;
  EM_GETFIRSTVISIBLELINE = 0CEH;
  EM_SETREADONLY = 0CFH;
  EM_SETWORDBREAKPROC = 0D0H;
  EM_GETWORDBREAKPROC = 0D1H;
  EM_GETPASSWORDCHAR = 0D2H;
  EM_SETMARGINS = 0D3H;
  EM_GETMARGINS = 0D4H;
  EM_GETLIMITTEXT = 0D5H;
  EM_POSFROMCHAR = 0D6H;
  EM_CHARFROMPOS = 0D7H;

(*                                   *)
(*  * EDITWORDBREAKPROC code values  *)
(*                                   *)
  WB_LEFT = 0;
  WB_RIGHT = 1;
  WB_ISDELIMITER = 2;

(*                           *)
(*  * Button Control Styles  *)
(*                           *)
  BS_PUSHBUTTON = 0H;
  BS_DEFPUSHBUTTON = 1H;
  BS_CHECKBOX = 2H;
  BS_AUTOCHECKBOX = 3H;
  BS_RADIOBUTTON = 4H;
  BS_3STATE = 5H;
  BS_AUTO3STATE = 6H;
  BS_GROUPBOX = 7H;
  BS_USERBUTTON = 8H;
  BS_AUTORADIOBUTTON = 9H;
  BS_OWNERDRAW = 0BH;
  BS_LEFTTEXT = 20H;
  BS_RIGHTBUTTON = BS_LEFTTEXT;
  BS_TEXT = 0H;
  BS_ICON = 40H;
  BS_BITMAP = 80H;
  BS_LEFT = 100H;
  BS_RIGHT = 200H;
  BS_CENTER = 300H;
  BS_TOP = 400H;
  BS_BOTTOM = 800H;
  BS_VCENTER = 0C00H;
  BS_PUSHLIKE = 1000H;
  BS_MULTILINE = 2000H;
  BS_NOTIFY = 4000H;
  BS_FLAT = 8000H;

(*                                    *)
(*  * User Button Notification Codes  *)
(*                                    *)
  BN_CLICKED = 0;
  BN_PAINT = 1;
  BN_HILITE = 2;
  BN_PUSHED = BN_HILITE;
  BN_UNHILITE = 3;
  BN_UNPUSHED = BN_UNHILITE;
  BN_DISABLE = 4;
  BN_DOUBLECLICKED = 5;
  BN_DBLCLK = BN_DOUBLECLICKED;
  BN_SETFOCUS = 6;
  BN_KILLFOCUS = 7;

(*                             *)
(*  * Button Control Messages  *)
(*                             *)
  BM_GETCHECK = 0F0H;
  BM_SETCHECK = 0F1H;
  BM_GETSTATE = 0F2H;
  BM_SETSTATE = 0F3H;
  BM_SETSTYLE = 0F4H;
  BM_CLICK = 0F5H;
  BM_GETIMAGE = 0F6H;
  BM_SETIMAGE = 0F7H;
  BST_UNCHECKED = 0H;
  BST_CHECKED = 1H;
  BST_INDETERMINATE = 2H;
  BST_PUSHED = 4H;
  BST_FOCUS = 8H;

(*                              *)
(*  * Static Control Constants  *)
(*                              *)
  SS_LEFT = 0H;
  SS_CENTER = 1H;
  SS_RIGHT = 2H;
  SS_ICON = 3H;
  SS_BLACKRECT = 4H;
  SS_GRAYRECT = 5H;
  SS_WHITERECT = 6H;
  SS_BLACKFRAME = 7H;
  SS_GRAYFRAME = 8H;
  SS_WHITEFRAME = 9H;
  SS_USERITEM = 0AH;
  SS_SIMPLE = 0BH;
  SS_LEFTNOWORDWRAP = 0CH;
  SS_BITMAP = 0EH;
  SS_OWNERDRAW = 0DH;
  SS_ENHMETAFILE = 0FH;
  SS_ETCHEDHORZ = 10H;
  SS_ETCHEDVERT = 11H;
  SS_ETCHEDFRAME = 12H;
  SS_TYPEMASK = 1FH;
  SS_NOPREFIX = 80H;                   (*  Don't do "&" character translation  *)
  SS_NOTIFY = 100H;
  SS_CENTERIMAGE = 200H;
  SS_RIGHTJUST = 400H;
  SS_REALSIZEIMAGE = 800H;
  SS_SUNKEN = 1000H;

(*                            *)
(*  * Static Control Mesages  *)
(*                            *)
  STM_SETICON = 170H;
  STM_GETICON = 171H;
  STM_SETIMAGE = 172H;
  STM_GETIMAGE = 173H;
  STN_CLICKED = 0;
  STN_DBLCLK = 1;
  STN_ENABLE = 2;
  STN_DISABLE = 3;
  STM_MSGMAX = 174H;

(*                         *)
(*  * Dialog window class  *)
(*                         *)
(*                                                                   *)
(*  * Get/SetWindowWord/Long offsets for use with WC_DIALOG windows  *)
(*                                                                   *)
  DWL_MSGRESULT = 0;
  DWL_DLGPROC = 4;
  DWL_USER = 8;
  
 (*                                                 *)
(*  * DlgDirList; DlgDirListComboBox flags values  *)
(*                                                 *)

  DDL_READWRITE = 0H;
  DDL_READONLY = 1H;
  DDL_HIDDEN = 2H;
  DDL_SYSTEM = 4H;
  DDL_DIRECTORY = 10H;
  DDL_ARCHIVE = 20H;
  DDL_POSTMSGS = 2000H;
  DDL_DRIVES = 4000H;
  DDL_EXCLUSIVE = 8000H;
(*                   *)
(*  * Dialog Styles  *)
(*                   *)

  DS_ABSALIGN = 1H;
  DS_SYSMODAL = 2H;
  DS_LOCALEDIT = 20H;                  (*  Edit items get Local storage.  *)
  DS_SETFONT = 40H;                    (*  User specified font for Dlg controls  *)
  DS_MODALFRAME = 80H;                 (*  Can be combined with WS_CAPTION   *)
  DS_NOIDLEMSG = 100H;                 (*  WM_ENTERIDLE message will not be sent  *)
  DS_SETFOREGROUND = 200H;             (*  not in win3.1  *)
  DS_3DLOOK = 4H;
  DS_FIXEDSYS = 8H;
  DS_NOFAILCREATE = 10H;
  DS_CONTROL = 400H;
  DS_CENTER = 800H;
  DS_CENTERMOUSE = 1000H;
  DS_CONTEXTHELP = 2000H;
  DM_GETDEFID = WM_USER+0;
  DM_SETDEFID = WM_USER+1;
  DM_REPOSITION = WM_USER+2;
  PSM_PAGEINFO = WM_USER+100;
  PSM_SHEETINFO = WM_USER+101;
  PSI_SETACTIVE = 1H;
  PSI_KILLACTIVE = 2H;
  PSI_APPLY = 3H;
  PSI_RESET = 4H;
  PSI_HASHELP = 5H;
  PSI_HELP = 6H;
  PSI_CHANGED = 1H;
  PSI_GUISTART = 2H;
  PSI_REBOOT = 3H;
  PSI_GETSIBLINGS = 4H;

(*                                                                    *)
(*  * Returned in HIWORD() of DM_GETDEFID result if msg is supported  *)
(*                                                                    *)
  DC_HASDEFID = 534BH;

(*                  *)
(*  * Dialog Codes  *)
(*                  *)
  DLGC_WANTARROWS = 1H;                (*  Control wants arrow keys          *)
  DLGC_WANTTAB = 2H;                   (*  Control wants tab keys            *)
  DLGC_WANTALLKEYS = 4H;               (*  Control wants all keys            *)
  DLGC_WANTMESSAGE = 4H;               (*  Pass message to control           *)
  DLGC_HASSETSEL = 8H;                 (*  Understands EM_SETSEL message     *)
  DLGC_DEFPUSHBUTTON = 10H;            (*  Default pushbutton                *)
  DLGC_UNDEFPUSHBUTTON = 20H;          (*  Non-default pushbutton            *)
  DLGC_RADIOBUTTON = 40H;              (*  Radio button                      *)
  DLGC_WANTCHARS = 80H;                (*  Want WM_CHAR messages             *)
  DLGC_STATIC = 100H;                  (*  Static item: don't include        *)
  DLGC_BUTTON = 2000H;                 (*  Button item: can be checked       *)
  LB_CTLCODE = 0;

(*                           *)
(*  * Listbox Return Values  *)
(*                           *)
  LB_OKAY = 0;
  LB_ERR = -1;
  LB_ERRSPACE = -2;

(*                                                                             *)
(* **  The idStaticPath parameter to DlgDirList can have the following values  *)
(* **  ORed if the list box should show other details of the files along with  *)
(* **  the name of the files;                                                  *)
(*                                                                             *)
(*  all other details also will be returned  *)
(*                                *)
(*  * Listbox Notification Codes  *)
(*                                *)
  LBN_ERRSPACE = -2;
  LBN_SELCHANGE = 1;
  LBN_DBLCLK = 2;
  LBN_SELCANCEL = 3;
  LBN_SETFOCUS = 4;
  LBN_KILLFOCUS = 5;

(*                      *)
(*  * Listbox messages  *)
(*                      *)
  LB_ADDSTRING = 180H;
  LB_INSERTSTRING = 181H;
  LB_DELETESTRING = 182H;
  LB_SELITEMRANGEEX = 183H;
  LB_RESETCONTENT = 184H;
  LB_SETSEL = 185H;
  LB_SETCURSEL = 186H;
  LB_GETSEL = 187H;
  LB_GETCURSEL = 188H;
  LB_GETTEXT = 189H;
  LB_GETTEXTLEN = 18AH;
  LB_GETCOUNT = 18BH;
  LB_SELECTSTRING = 18CH;
  LB_DIR = 18DH;
  LB_GETTOPINDEX = 18EH;
  LB_FINDSTRING = 18FH;
  LB_GETSELCOUNT = 190H;
  LB_GETSELITEMS = 191H;
  LB_SETTABSTOPS = 192H;
  LB_GETHORIZONTALEXTENT = 193H;
  LB_SETHORIZONTALEXTENT = 194H;
  LB_SETCOLUMNWIDTH = 195H;
  LB_ADDFILE = 196H;
  LB_SETTOPINDEX = 197H;
  LB_GETITEMRECT = 198H;
  LB_GETITEMDATA = 199H;
  LB_SETITEMDATA = 19AH;
  LB_SELITEMRANGE = 19BH;
  LB_SETANCHORINDEX = 19CH;
  LB_GETANCHORINDEX = 19DH;
  LB_SETCARETINDEX = 19EH;
  LB_GETCARETINDEX = 19FH;
  LB_SETITEMHEIGHT = 1A0H;
  LB_GETITEMHEIGHT = 1A1H;
  LB_FINDSTRINGEXACT = 1A2H;
  LB_SETLOCALE = 1A5H;
  LB_GETLOCALE = 1A6H;
  LB_SETCOUNT = 1A7H;
  LB_INITSTORAGE = 1A8H;
  LB_ITEMFROMPOINT = 1A9H;
  LB_MSGMAX = 1B0H;

(*                    *)
(*  * Listbox Styles  *)
(*                    *)
  LBS_NOTIFY = 1H;
  LBS_SORT = 2H;
  LBS_NOREDRAW = 4H;
  LBS_MULTIPLESEL = 8H;
  LBS_OWNERDRAWFIXED = 10H;
  LBS_OWNERDRAWVARIABLE = 20H;
  LBS_HASSTRINGS = 40H;
  LBS_USETABSTOPS = 80H;
  LBS_NOINTEGRALHEIGHT = 100H;
  LBS_MULTICOLUMN = 200H;
  LBS_WANTKEYBOARDINPUT = 400H;
  LBS_EXTENDEDSEL = 800H;
  LBS_DISABLENOSCROLL = 1000H;
  LBS_NODATA = 2000H;
  LBS_NOSEL = 4000H;
  LBS_STANDARD = 3H;  (* (LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER)*)

(*                             *)
(*  * Combo Box return Values  *)
(*                             *)
  CB_OKAY = 0;
  CB_ERR = -1;
  CB_ERRSPACE = -2;

(*                                  *)
(*  * Combo Box Notification Codes  *)
(*                                  *)
  CBN_ERRSPACE = -1;
  CBN_SELCHANGE = 1;
  CBN_DBLCLK = 2;
  CBN_SETFOCUS = 3;
  CBN_KILLFOCUS = 4;
  CBN_EDITCHANGE = 5;
  CBN_EDITUPDATE = 6;
  CBN_DROPDOWN = 7;
  CBN_CLOSEUP = 8;
  CBN_SELENDOK = 9;
  CBN_SELENDCANCEL = 10;

(*                      *)
(*  * Combo Box styles  *)
(*                      *)
  CBS_SIMPLE = 1H;
  CBS_DROPDOWN = 2H;
  CBS_DROPDOWNLIST = 3H;
  CBS_OWNERDRAWFIXED = 10H;
  CBS_OWNERDRAWVARIABLE = 20H;
  CBS_AUTOHSCROLL = 40H;
  CBS_OEMCONVERT = 80H;
  CBS_SORT = 100H;
  CBS_HASSTRINGS = 200H;
  CBS_NOINTEGRALHEIGHT = 400H;
  CBS_DISABLENOSCROLL = 800H;
  CBS_UPPERCASE = 2000H;
  CBS_LOWERCASE = 4000H;

(*                        *)
(*  * Combo Box messages  *)
(*                        *)
  CB_GETEDITSEL = 140H;
  CB_LIMITTEXT = 141H;
  CB_SETEDITSEL = 142H;
  CB_ADDSTRING = 143H;
  CB_DELETESTRING = 144H;
  CB_DIR = 145H;
  CB_GETCOUNT = 146H;
  CB_GETCURSEL = 147H;
  CB_GETLBTEXT = 148H;
  CB_GETLBTEXTLEN = 149H;
  CB_INSERTSTRING = 14AH;
  CB_RESETCONTENT = 14BH;
  CB_FINDSTRING = 14CH;
  CB_SELECTSTRING = 14DH;
  CB_SETCURSEL = 14EH;
  CB_SHOWDROPDOWN = 14FH;
  CB_GETITEMDATA = 150H;
  CB_SETITEMDATA = 151H;
  CB_GETDROPPEDCONTROLRECT = 152H;
  CB_SETITEMHEIGHT = 153H;
  CB_GETITEMHEIGHT = 154H;
  CB_SETEXTENDEDUI = 155H;
  CB_GETEXTENDEDUI = 156H;
  CB_GETDROPPEDSTATE = 157H;
  CB_FINDSTRINGEXACT = 158H;
  CB_SETLOCALE = 159H;
  CB_GETLOCALE = 15AH;
  CB_GETTOPINDEX = 15BH;
  CB_SETTOPINDEX = 15CH;
  CB_GETHORIZONTALEXTENT = 15DH;
  CB_SETHORIZONTALEXTENT = 15EH;
  CB_GETDROPPEDWIDTH = 15FH;
  CB_SETDROPPEDWIDTH = 160H;
  CB_INITSTORAGE = 161H;
  CB_MSGMAX = 162H;

(*                       *)
(*  * Scroll Bar Styles  *)
(*                       *)
  SBS_HORZ = 0H;
  SBS_VERT = 1H;
  SBS_TOPALIGN = 2H;
  SBS_LEFTALIGN = 2H;
  SBS_BOTTOMALIGN = 4H;
  SBS_RIGHTALIGN = 4H;
  SBS_SIZEBOXTOPLEFTALIGN = 2H;
  SBS_SIZEBOXBOTTOMRIGHTALIGN = 4H;
  SBS_SIZEBOX = 8H;
  SBS_SIZEGRIP = 10H;

(*                         *)
(*  * Scroll bar messages  *)
(*                         *)
  SBM_SETPOS = 0E0H;                   (* not in win3.1  *)
  SBM_GETPOS = 0E1H;                   (* not in win3.1  *)
  SBM_SETRANGE = 0E2H;                 (* not in win3.1  *)
  SBM_SETRANGEREDRAW = 0E6H;           (* not in win3.1  *)
  SBM_GETRANGE = 0E3H;                 (* not in win3.1  *)
  SBM_ENABLE_ARROWS = 0E4H;            (* not in win3.1  *)
  SBM_SETSCROLLINFO = 0E9H;
  SBM_GETSCROLLINFO = 0EAH;
  SIF_RANGE = 1H;
  SIF_PAGE = 2H;
  SIF_POS = 4H;
  SIF_DISABLENOSCROLL = 8H;
  SIF_TRACKPOS = 10H;
  SIF_ALL = 23;

(*                           *)
(*  * MDI client style bits  *)
(*                           *)

  MDIS_ALLCHILDSTYLES = 1H;

(*                                                             *)
(*  * wParam Flags for WM_MDITILE and WM_MDICASCADE messages.  *)
(*                                                             *)
  MDITILE_VERTICAL = 0H;               (* not in win3.1  *)
  MDITILE_HORIZONTAL = 1H;             (* not in win3.1  *)
  MDITILE_SKIPDISABLED = 2H;           (* not in win3.1  *)

  
(*                        *)
(*  *  IME class support  *)
(*                        *)
(*  wParam for WM_IME_CONTROL *)


  IMC_GETCANDIDATEPOS = 7H;
  IMC_SETCANDIDATEPOS = 8H;
  IMC_GETCOMPOSITIONFONT = 9H;
  IMC_SETCOMPOSITIONFONT = 0AH;
  IMC_GETCOMPOSITIONWINDOW = 0BH;
  IMC_SETCOMPOSITIONWINDOW = 0CH;
  IMC_GETSTATUSWINDOWPOS = 0FH;
  IMC_SETSTATUSWINDOWPOS = 10H;
  IMC_CLOSESTATUSWINDOW = 21H;
  IMC_OPENSTATUSWINDOW = 22H;

(*  wParam of report message WM_IME_NOTIFY *)
  IMN_CLOSESTATUSWINDOW = 1H;
  IMN_OPENSTATUSWINDOW = 2H;
  IMN_CHANGECANDIDATE = 3H;
  IMN_CLOSECANDIDATE = 4H;
  IMN_OPENCANDIDATE = 5H;
  IMN_SETCONVERSIONMODE = 6H;
  IMN_SETSENTENCEMODE = 7H;
  IMN_SETOPENSTATUS = 8H;
  IMN_SETCANDIDATEPOS = 9H;
  IMN_SETCOMPOSITIONFONT = 0AH;
  IMN_SETCOMPOSITIONWINDOW = 0BH;
  IMN_SETSTATUSWINDOWPOS = 0CH;
  IMN_GUIDELINE = 0DH;
  IMN_PRIVATE = 0EH;


(*                                   *)
(*  * Commands to pass to WinHelp()  *)
(*                                   *)


  HELP_CONTEXT = 1H;                   (*  Display topic in ulTopic  *)
  HELP_QUIT = 2H;                      (*  Terminate help  *)
  HELP_INDEX = 3H;                     (*  Display index  *)
  HELP_CONTENTS = 3H;
  HELP_HELPONHELP = 4H;                (*  Display help on using help  *)
  HELP_SETINDEX = 5H;                  (*  Set current Index for multi index help  *)
  HELP_SETCONTENTS = 5H;
  HELP_CONTEXTPOPUP = 8H;
  HELP_FORCEFILE = 9H;
  HELP_KEY = 101H;                     (*  Display topic for keyword in offabData  *)
  HELP_COMMAND = 102H;
  HELP_PARTIALKEY = 105H;
  HELP_MULTIKEY = 201H;
  HELP_SETWINPOS = 203H;
  HELP_CONTEXTMENU = 0AH;
  HELP_FINDER = 0BH;
  HELP_WM_HELP = 0CH;
  HELP_SETPOPUP_POS = 0DH;
  HELP_TCARD = 8000H;
  HELP_TCARD_DATA = 10H;
  HELP_TCARD_OTHER_CALLER = 11H;

(*  These are in winhelp.h in Win95. *)
  IDH_NO_HELP = 28440;
  IDH_MISSING_CONTEXT = 28441;         (*  Control doesn't have matching help context *)
  IDH_GENERIC_HELP_BUTTON = 28442;     (*  Property sheet help button *)
  IDH_OK = 28443;
  IDH_CANCEL = 28444;
  IDH_HELP = 28445;
(*                                          *)
(*  * Parameter for SystemParametersInfo()  *)
(*                                          *)


  SPI_GETBEEP = 1;
  SPI_SETBEEP = 2;
  SPI_GETMOUSE = 3;
  SPI_SETMOUSE = 4;
  SPI_GETBORDER = 5;
  SPI_SETBORDER = 6;
  SPI_GETKEYBOARDSPEED = 10;
  SPI_SETKEYBOARDSPEED = 11;
  SPI_LANGDRIVER = 12;
  SPI_ICONHORIZONTALSPACING = 13;
  SPI_GETSCREENSAVETIMEOUT = 14;
  SPI_SETSCREENSAVETIMEOUT = 15;
  SPI_GETSCREENSAVEACTIVE = 16;
  SPI_SETSCREENSAVEACTIVE = 17;
  SPI_GETGRIDGRANULARITY = 18;
  SPI_SETGRIDGRANULARITY = 19;
  SPI_SETDESKWALLPAPER = 20;
  SPI_SETDESKPATTERN = 21;
  SPI_GETKEYBOARDDELAY = 22;
  SPI_SETKEYBOARDDELAY = 23;
  SPI_ICONVERTICALSPACING = 24;
  SPI_GETICONTITLEWRAP = 25;
  SPI_SETICONTITLEWRAP = 26;
  SPI_GETMENUDROPALIGNMENT = 27;
  SPI_SETMENUDROPALIGNMENT = 28;
  SPI_SETDOUBLECLKWIDTH = 29;
  SPI_SETDOUBLECLKHEIGHT = 30;
  SPI_GETICONTITLELOGFONT = 31;
  SPI_SETDOUBLECLICKTIME = 32;
  SPI_SETMOUSEBUTTONSWAP = 33;
  SPI_SETICONTITLELOGFONT = 34;
  SPI_GETFASTTASKSWITCH = 35;
  SPI_SETFASTTASKSWITCH = 36;
  SPI_SETDRAGFULLWINDOWS = 37;
  SPI_GETDRAGFULLWINDOWS = 38;
  SPI_GETNONCLIENTMETRICS = 41;
  SPI_SETNONCLIENTMETRICS = 42;
  SPI_GETMINIMIZEDMETRICS = 43;
  SPI_SETMINIMIZEDMETRICS = 44;
  SPI_GETICONMETRICS = 45;
  SPI_SETICONMETRICS = 46;
  SPI_SETWORKAREA = 47;
  SPI_GETWORKAREA = 48;
  SPI_SETPENWINDOWS = 49;
  SPI_GETHIGHCONTRAST = 66;
  SPI_SETHIGHCONTRAST = 67;
  SPI_GETKEYBOARDPREF = 68;
  SPI_SETKEYBOARDPREF = 69;
  SPI_GETSCREENREADER = 70;
  SPI_SETSCREENREADER = 71;
  SPI_GETANIMATION = 72;
  SPI_SETANIMATION = 73;
  SPI_GETFONTSMOOTHING = 74;
  SPI_SETFONTSMOOTHING = 75;
  SPI_SETDRAGWIDTH = 76;
  SPI_SETDRAGHEIGHT = 77;
  SPI_SETHANDHELD = 78;
  SPI_GETLOWPOWERTIMEOUT = 79;
  SPI_GETPOWEROFFTIMEOUT = 80;
  SPI_SETLOWPOWERTIMEOUT = 81;
  SPI_SETPOWEROFFTIMEOUT = 82;
  SPI_GETLOWPOWERACTIVE = 83;
  SPI_GETPOWEROFFACTIVE = 84;
  SPI_SETLOWPOWERACTIVE = 85;
  SPI_SETPOWEROFFACTIVE = 86;
  SPI_SETCURSORS = 87;
  SPI_SETICONS = 88;
  SPI_GETDEFAULTINPUTLANG = 89;
  SPI_SETDEFAULTINPUTLANG = 90;
  SPI_SETLANGTOGGLE = 91;
  SPI_GETWINDOWSEXTENSION = 92;
  SPI_SETMOUSETRAILS = 93;
  SPI_GETMOUSETRAILS = 94;
  SPI_SCREENSAVERRUNNING = 97;
  SPI_GETFILTERKEYS = 50;
  SPI_SETFILTERKEYS = 51;
  SPI_GETTOGGLEKEYS = 52;
  SPI_SETTOGGLEKEYS = 53;
  SPI_GETMOUSEKEYS = 54;
  SPI_SETMOUSEKEYS = 55;
  SPI_GETSHOWSOUNDS = 56;
  SPI_SETSHOWSOUNDS = 57;
  SPI_GETSTICKYKEYS = 58;
  SPI_SETSTICKYKEYS = 59;
  SPI_GETACCESSTIMEOUT = 60;
  SPI_SETACCESSTIMEOUT = 61;
  SPI_GETSERIALKEYS = 62;
  SPI_SETSERIALKEYS = 63;
  SPI_GETSOUNDSENTRY = 64;
  SPI_SETSOUNDSENTRY = 65;

(*           *)
(*  * Flags  *)
(*           *)
  SPIF_UPDATEINIFILE = 1H;
  SPIF_SENDWININICHANGE = 2H;
  SPIF_SENDCHANGE = SPIF_SENDWININICHANGE;
  METRICS_USEDEFAULT = -1;  

 
  ARW_BOTTOMLEFT = 0H;
  ARW_BOTTOMRIGHT = 1H;
  ARW_TOPLEFT = 2H;
  ARW_TOPRIGHT = 3H;
  ARW_STARTMASK = 3H;
  ARW_STARTRIGHT = 1H;
  ARW_STARTTOP = 2H;
  ARW_LEFT = 0H;
  ARW_RIGHT = 0H;
  ARW_UP = 4H;
  ARW_DOWN = 4H;
  ARW_HIDE = 8H;
  ARW_VALID = 0FH;

(*  flags for SERIALKEYS dwFlags field  *)

  SERKF_SERIALKEYSON = 1H;
  SERKF_AVAILABLE = 2H;
  SERKF_INDICATOR = 4H;

(*  flags for HIGHCONTRAST dwFlags field  *)
 
  HCF_HIGHCONTRASTON = 1H;
  HCF_AVAILABLE = 2H;
  HCF_HOTKEYACTIVE = 4H;
  HCF_CONFIRMHOTKEY = 8H;
  HCF_HOTKEYSOUND = 10H;
  HCF_INDICATOR = 20H;
  HCF_HOTKEYAVAILABLE = 40H;

(*  Flags for ChangeDisplaySettings  *)
  CDS_UPDATEREGISTRY = 1H;
  CDS_TEST = 2H;
  CDS_FULLSCREEN = 4H;

(*  Return values  *)
  DISP_CHANGE_SUCCESSFUL = 0;
  DISP_CHANGE_RESTART = 1;
  DISP_CHANGE_FAILED = -1;
  DISP_CHANGE_BADMODE = -2;
  DISP_CHANGE_NOTUPDATED = -3;
  DISP_CHANGE_BADFLAGS = -4;

(*                             *)
(*  * MOUSEKEYS dwFlags field  *)
(*                             *)

  MKF_MOUSEKEYSON = 1H;
  MKF_AVAILABLE = 2H;
  MKF_HOTKEYACTIVE = 4H;
  MKF_CONFIRMHOTKEY = 8H;
  MKF_HOTKEYSOUND = 10H;
  MKF_INDICATOR = 20H;
  MKF_MODIFIERS = 40H;
  MKF_REPLACENUMBERS = 80H;


(*                                 *)
(*  * ACCESSTIMEOUT dwFlags field  *)
(*                                 *)


  ATF_TIMEOUTON = 1H;
  ATF_ONOFFFEEDBACK = 2H;

(*  values for SOUNDSENTRY iFSGrafEffect field  *)
  SSGF_NONE = 0;
  SSGF_DISPLAY = 3;

(*  values for SOUNDSENTRY iFSTextEffect field  *)
  SSTF_NONE = 0;
  SSTF_CHARS = 1;
  SSTF_BORDER = 2;
  SSTF_DISPLAY = 3;

(*  values for SOUNDSENTRY iWindowsEffect field  *)
  SSWF_NONE = 0;
  SSWF_TITLE = 1;
  SSWF_WINDOW = 2;
  SSWF_DISPLAY = 3;
  SSWF_CUSTOM = 4;

(*                               *)
(*  * SOUNDSENTRY dwFlags field  *)
(*                               *)

  SSF_SOUNDSENTRYON = 1H;
  SSF_AVAILABLE = 2H;
  SSF_INDICATOR = 4H;

(*                              *)
(*  * TOGGLEKEYS dwFlags field  *)
(*                              *)

  TKF_TOGGLEKEYSON = 1H;
  TKF_AVAILABLE = 2H;
  TKF_HOTKEYACTIVE = 4H;
  TKF_CONFIRMHOTKEY = 8H;
  TKF_HOTKEYSOUND = 10H;
  TKF_INDICATOR = 20H;

  FKF_FILTERKEYSON = 1H;
  FKF_AVAILABLE = 2H;
  FKF_HOTKEYACTIVE = 4H;
  FKF_CONFIRMHOTKEY = 8H;
  FKF_HOTKEYSOUND = 10H;
  FKF_INDICATOR = 20H;
  FKF_CLICKON = 40H;

(*                              *)
(*  * STICKYKEYS dwFlags field  *)
(*                              *)

  SKF_STICKYKEYSON = 1H;
  SKF_AVAILABLE = 2H;
  SKF_HOTKEYACTIVE = 4H;
  SKF_CONFIRMHOTKEY = 8H;
  SKF_HOTKEYSOUND = 10H;
  SKF_INDICATOR = 20H;
  SKF_AUDIBLEFEEDBACK = 40H;
  SKF_TRISTATE = 80H;
  SKF_TWOKEYSOFF = 100H;

(*                             *)
(*  * SetLastErrorEx() types.  *)
(*                             *)

  SLE_ERROR = 1H;
  SLE_MINORERROR = 2H;
  SLE_WARNING = 3H;




 UOI_USER_SID  =  4;

(*
 * WM_SETICON / WM_GETICON Type Codes
 *)
 ICON_SMALL  =        0;
 ICON_BIG    =        1;


 ENDSESSION_LOGOFF    =MIN(LONGINT);


BSM_ALLDESKTOPS         = 00000010H;
 MWMO_WAITALL      = 0001;
 MWMO_ALERTABLE    = 0002;

QS_ALLPOSTMESSAGE   = 0100;



 MB_SERVICE_NOTIFICATION     =00200000H;
(*MB_SERVICE_NOTIFICATION     =00040000H;*)
LR_VGACOLOR          =0080H;
 SS_ENDELLIPSIS      =00004000H; 
 SS_PATHELLIPSIS     =00008000H;
 SS_WORDELLIPSIS     =0000C000H;
 SS_ELLIPSISMASK     =0000C000H;

(* Return values *)


 CDS_GLOBAL          =00000008H;
 CDS_SET_PRIMARY     =00000010H;
 CDS_RESET           =40000000H;
 CDS_SETRECT         =20000000H;
 CDS_NORESET         =10000000H;

 DISP_CHANGE_BADPARAM      =  -5;

 ENUM_CURRENT_SETTINGS      =-1;
 ENUM_REGISTRY_SETTINGS     =-2;
(*
 * Standard Cursor IDs
 *)
 IDC_ARROW           = 32512;
 IDC_IBEAM           = 32513;
 IDC_WAIT            = 32514;
 IDC_CROSS           = 32515;
 IDC_UPARROW         = 32516;
 IDC_SIZE            = 32640;  (* OBSOLETE: use IDC_SIZEALL *)
 IDC_ICON            = 32641;  (* OBSOLETE: use IDC_ARROW *)
 IDC_SIZENWSE        = 32642;
 IDC_SIZENESW        = 32643;
 IDC_SIZEWE          = 32644;
 IDC_SIZENS          = 32645;
 IDC_SIZEALL         = 32646;
 IDC_NO              = 32648; (*not in win3.1 *)
 IDC_APPSTARTING     = 32650; (*not in win3.1 *)
 IDC_HELP            = 32651;
(*
 * Predefined Resource Types
 *)
 RT_CURSOR           = 1;
 RT_BITMAP           = 2;
 RT_ICON             = 3;
 RT_MENU             = 4;
 RT_DIALOG           = 5;
 RT_STRING           = 6;
 RT_FONTDIR          = 7;
 RT_FONT             = 8;
 RT_ACCELERATOR      = 9;
 RT_RCDATA           = 10;
 RT_MESSAGETABLE     = 11;
 RT_GROUP_CURSOR = RT_CURSOR + DIFFERENCE;
 RT_GROUP_ICON   = RT_ICON + DIFFERENCE;
 RT_VERSION      = 16;
 RT_DLGINCLUDE   = 17;
 RT_PLUGPLAY     = 19;
 RT_VXD          = 20;
 RT_ANICURSOR    = 21;
 RT_ANIICON      = 22;
 IDI_APPLICATION   =  32512;
 IDI_HAND          =  32513;
 IDI_QUESTION      =  32514;
 IDI_EXCLAMATION   =  32515;
 IDI_ASTERISK      =  32516;
 IDI_WINLOGO       =  32517;
 IDI_WARNING     = IDI_EXCLAMATION;
 IDI_ERROR       = IDI_HAND;
 IDI_INFORMATION = IDI_ASTERISK;

TYPE 
  USEROBJECTFLAGS = RECORD [_NOTALIGNED]
    fInherit : WD.BOOL;
    fReserved: WD.BOOL;
    dwFlags  : WD.DWORD;
  END;

  PUSEROBJECTFLAGS = POINTER TO USEROBJECTFLAGS;

  va_list = WD.PSZ;            (* char* va_list defined in stdarg.h  *)

 (*  typeinformation from MS Visual C++ 4.0 help  *)
  
  ACL = RECORD
      AclRevision: WD.BYTE;
      Sbz1: WD.BYTE;
      AclSize: WD.WORD;
      AceCount: WD.WORD;
      Sbz2: WD.WORD;
  END;
  PSID = WD.LPVOID;
  PACL = POINTER TO ACL;
  SECURITY_DESCRIPTOR_CONTROL = WD.WORD;
  SECURITY_ATTRIBUTES = RECORD [_NOTALIGNED]
    (*  sa  *)
    nLength             : WD.DWORD;
    lpSecurityDescriptor: WD.LPVOID;
    bInheritHandle      : WD.BOOL;
  END;
  SECURITY_DESCRIPTOR = RECORD
    Revision: WD.BYTE;
    Sbz1: WD.BYTE;
    Control: SECURITY_DESCRIPTOR_CONTROL ;
    Owner: PSID;
    Group: PSID;
    Sacl: PACL ;
    Dacl: PACL;
  END;
  PSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;
  LPSECURITY_ATTRIBUTES = POINTER TO SECURITY_ATTRIBUTES;
  PSECURITY_DESCRIPTOR = POINTER TO SECURITY_DESCRIPTOR;   (*  PVOID originaly used  *)
  SECURITY_INFORMATION = WD.DWORD;
  PSECURITY_INFORMATION = WD.PDWORD;

(*  end added for oberon  *)

  HDWP = LONGINT;
  MENUTEMPLATEA = LONGINT; (*void;*)
  MENUTEMPLATEW = LONGINT; (*void;*)
  MENUTEMPLATE = MENUTEMPLATEA;  (* ! A *)
  LPMENUTEMPLATEA = WD.LPVOID;  
  LPMENUTEMPLATEW = WD.LPVOID;
  LPMENUTEMPLATE = LPMENUTEMPLATEA;  (* ! A *)

  WNDPROC = PROCEDURE [_APICALL] ( hwnd: WD.HWND; i: WD.UINT; wParam: WD.WPARAM; 
                      lParam: WD.LPARAM ): WD.LRESULT;

DLGPROC = PROCEDURE [_APICALL](hwnd: WD.HWND; i: WD.UINT; 
            wParam: WD.WPARAM; lParam: WD.LPARAM): WD.BOOL;
TIMERPROC = PROCEDURE [_APICALL](hwnd: WD.HWND; i: WD.UINT; u: WD.UINT; d: WD.DWORD);
GRAYSTRINGPROC = PROCEDURE [_APICALL](hdc: WD.HDC; lParam: WD.LPARAM; i: LONGINT): WD.BOOL;
WNDENUMPROC = PROCEDURE [_APICALL](hwnd: WD.HWND; lParam: WD.LPARAM): WD.BOOL;
HOOKPROC = PROCEDURE [_APICALL]( code: LONGINT; 
            wParam: WD.WPARAM ; lParam: WD.LPARAM ): WD.LRESULT;
SENDASYNCPROC = PROCEDURE [_APICALL](hwnd: WD.HWND; i: WD.UINT; d: WD.DWORD; lres: WD.LRESULT);
PROPENUMPROCA = PROCEDURE [_APICALL](hwnd: WD.HWND; lpsz: WD.LPCSTR; h: WD.HANDLE): WD.BOOL;
PROPENUMPROCW = PROCEDURE [_APICALL](hwnd: WD.HWND; lpsz: WD.LPCWSTR; h: WD.HANDLE): WD.BOOL;
PROPENUMPROCEXA = PROCEDURE [_APICALL](hwnd: WD.HWND; 
            lpsz: WD.LPSTR; h: WD.HANDLE; d: WD.DWORD): WD.BOOL;
PROPENUMPROCEXW = PROCEDURE [_APICALL](hwnd: WD.HWND; 
            lpsz: WD.LPWSTR; h: WD.HANDLE; d: WD.DWORD): WD.BOOL;
EDITWORDBREAKPROCA = PROCEDURE [_APICALL]( lpch: WD.LPSTR; 
        ichCurrent: LONGINT; cch: LONGINT;code: LONGINT): LONGINT;
EDITWORDBREAKPROCW = PROCEDURE [_APICALL](lpch: WD.LPWSTR ; 
        ichCurrent: LONGINT; cch: LONGINT; code: LONGINT): LONGINT;
DRAWSTATEPROC = PROCEDURE [_APICALL](hdc: WD.HDC; lData: WD.LPARAM ;
        wData: WD.WPARAM ; cx: LONGINT; cy: LONGINT): WD.BOOL;


NAMEENUMPROCA = PROCEDURE [_APICALL](lpsz: WD.LPSTR; lParam: WD.LPARAM): WD.BOOL;
NAMEENUMPROCW = PROCEDURE [_APICALL](lpsz: WD.LPWSTR; lParam: WD.LPARAM): WD.BOOL;
WINSTAENUMPROCA = NAMEENUMPROCA;
DESKTOPENUMPROCA = NAMEENUMPROCA;
WINSTAENUMPROCW = NAMEENUMPROCW;
DESKTOPENUMPROCW = NAMEENUMPROCW;
PROPENUMPROC = PROPENUMPROCA;        (* ! A *)
PROPENUMPROCEX = PROPENUMPROCEXA;      (* ! A *)
EDITWORDBREAKPROC = EDITWORDBREAKPROCA;  (* ! A *)
WINSTAENUMPROC = WINSTAENUMPROCA;      (* ! A *)
DESKTOPENUMPROC = DESKTOPENUMPROCA;    (* ! A *)
  
(* Macros  
  <* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEINTRESOURCEA ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEINTRESOURCEA ( i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>

CONST 
  MAKEINTRESOURCE = MAKEINTRESOURCEA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEINTRESOURCEW ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEINTRESOURCEW ( i: ARRAY OF SYSTEM.BYTE );
<* END *>

end MACROS*)



(*                               *)
(*  * Predefined Resource Types  *)
(*                               *)

(*                                                    *)
(*  * HCBT_CREATEWND parameters pointed to by lParam  *)
(*                                                    *)

 
  CREATESTRUCTA = RECORD [_NOTALIGNED]
    lpCreateParams: WD.LPVOID;
    hInstance     : WD.HINSTANCE;
    hMenu         : WD.HMENU;
    hwndParent    : WD.HWND;
    cy            : LONGINT;
    cx            : LONGINT;
    y             : LONGINT;
    x             : LONGINT;
    style         : LONGINT;
    lpszName      : WD.LPCSTR;
    lpszClass     : WD.LPCSTR;
    dwExStyle     : WD.DWORD;
  END;

  LPCREATESTRUCTA = POINTER TO CREATESTRUCTA;

  CBT_CREATEWNDA = RECORD [_NOTALIGNED]
    lpcs           : LPCREATESTRUCTA;
    hwndInsertAfter: WD.HWND;
  END;

  LPCBT_CREATEWNDA = POINTER TO CBT_CREATEWNDA;

(*                                                    *)
(*  * HCBT_CREATEWND parameters pointed to by lParam  *)
(*                                                    *)

  CREATESTRUCTW = RECORD [_NOTALIGNED]
    lpCreateParams: WD.LPVOID;
    hInstance     : WD.HINSTANCE;
    hMenu         : WD.HMENU;
    hwndParent    : WD.HWND;
    cy            : LONGINT;
    cx            : LONGINT;
    y             : LONGINT;
    x             : LONGINT;
    style         : LONGINT;
    lpszName      : WD.LPCWSTR;
    lpszClass     : WD.LPCWSTR;
    dwExStyle     : WD.DWORD;
  END;

  LPCREATESTRUCTW = POINTER TO CREATESTRUCTW;

  CBT_CREATEWNDW = RECORD [_NOTALIGNED]
    lpcs           : LPCREATESTRUCTW;
    hwndInsertAfter: WD.HWND;
  END;

  LPCBT_CREATEWNDW = POINTER TO CBT_CREATEWNDW;
  CBT_CREATEWND = CBT_CREATEWNDA;  (* ! A *)
  LPCBT_CREATEWND = LPCBT_CREATEWNDA;  (* ! A *)

(*                                                  *)
(*  * HCBT_ACTIVATE structure pointed to by lParam  *)
(*                                                  *)

  CBTACTIVATESTRUCT = RECORD [_NOTALIGNED]
    fMouse    : WD.BOOL;
    hWndActive: WD.HWND;
  END;

  LPCBTACTIVATESTRUCT = POINTER TO CBTACTIVATESTRUCT;

(*                                    *)
(*  * WH_MSGFILTER Filter Proc Codes  *)
(*                                    *)

(*                                          *)
(*  * Message Structure used in Journaling  *)
(*                                          *)

 
  EVENTMSG = RECORD [_NOTALIGNED]
    message: WD.UINT;
    paramL : WD.UINT;
    paramH : WD.UINT;
    time   : WD.DWORD;
    hwnd   : WD.HWND;
  END;
 
 EVENTMSGMSG = RECORD [_NOTALIGNED]
    message: WD.UINT;
    paramL : WD.UINT;
    paramH : WD.UINT;
    time   : WD.DWORD;
    hwnd   : WD.HWND;
  END;

  PEVENTMSGMSG = POINTER TO EVENTMSGMSG;
  NPEVENTMSGMSG = POINTER TO EVENTMSGMSG;
  LPEVENTMSGMSG = POINTER TO EVENTMSGMSG;
  PEVENTMSG = POINTER TO EVENTMSG;
  NPEVENTMSG = POINTER TO EVENTMSG;
  LPEVENTMSG = POINTER TO EVENTMSG;

(*                                              *)
(*  * Message structure used by WH_CALLWNDPROC  *)
(*                                              *)

  CWPSTRUCT = RECORD [_NOTALIGNED]
    lParam : WD.LPARAM;
    wParam : WD.WPARAM;
    message: WD.UINT;
    hwnd   : WD.HWND;
  END;

  PCWPSTRUCT = POINTER TO CWPSTRUCT;
  NPCWPSTRUCT = POINTER TO CWPSTRUCT;
  LPCWPSTRUCT = POINTER TO CWPSTRUCT;

(*                                                 *)
(*  * Message structure used by WH_CALLWNDPROCRET  *)
(*                                                 *)

  CWPRETSTRUCT = RECORD [_NOTALIGNED]
    lResult: WD.LRESULT;
    lParam : WD.LPARAM;
    wParam : WD.WPARAM;
    message: WD.UINT;
    hwnd   : WD.HWND;
  END;

  PCWPRETSTRUCT = POINTER TO CWPRETSTRUCT;
  NPCWPRETSTRUCT = POINTER TO CWPRETSTRUCT;
  LPCWPRETSTRUCT = POINTER TO CWPRETSTRUCT;

(*                                *)
(*  * Structure used by WH_DEBUG  *)
(*                                *)

  DEBUGHOOKINFO = RECORD [_NOTALIGNED]
    idThread         : WD.DWORD;
    idThreadInstaller: WD.DWORD;
    lParam           : WD.LPARAM;
    wParam           : WD.WPARAM;
    code             : LONGINT;
  END;

  PDEBUGHOOKINFO = POINTER TO DEBUGHOOKINFO;
  NPDEBUGHOOKINFO = POINTER TO DEBUGHOOKINFO;
  LPDEBUGHOOKINFO = POINTER TO DEBUGHOOKINFO;

(*                                *)
(*  * Structure used by WH_MOUSE  *)
(*                                *)

  MOUSEHOOKSTRUCT = RECORD [_NOTALIGNED]
    pt          : WD.POINT;
    hwnd        : WD.HWND;
    wHitTestCode: WD.UINT;
    dwExtraInfo : WD.DWORD;
  END;

  LPMOUSEHOOKSTRUCT = POINTER TO MOUSEHOOKSTRUCT;
  PMOUSEHOOKSTRUCT = POINTER TO MOUSEHOOKSTRUCT;

(*                                   *)
(*  * Structure used by WH_HARDWARE  *)
(*                                   *)

  HARDWAREHOOKSTRUCT = RECORD [_NOTALIGNED]
    hwnd   : WD.HWND;
    message: WD.UINT;
    wParam : WD.WPARAM;
    lParam : WD.LPARAM;
  END;

  LPHARDWAREHOOKSTRUCT = POINTER TO HARDWAREHOOKSTRUCT;
  PHARDWAREHOOKSTRUCT = POINTER TO HARDWAREHOOKSTRUCT;

 
  WNDCLASSEXA = RECORD [_NOTALIGNED]
    cbSize       : WD.UINT;
 
(*  Win 3.x  *)
    style        : WD.UINT;
    lpfnWndProc  : WNDPROC;
    cbClsExtra   : LONGINT;
    cbWndExtra   : LONGINT;
    hInstance    : WD.HINSTANCE;
    hIcon        : WD.HICON;
    hCursor      : WD.HCURSOR;
    hbrBackground: WD.HBRUSH;
    lpszMenuName : WD.LPCSTR;
    lpszClassName: WD.LPCSTR;
 
(*  Win 4.0  *)
    hIconSm      : WD.HICON;
  END;

  PWNDCLASSEXA = POINTER TO WNDCLASSEXA;
  NPWNDCLASSEXA = POINTER TO WNDCLASSEXA;
  LPWNDCLASSEXA = POINTER TO WNDCLASSEXA;

  WNDCLASSEXW = RECORD [_NOTALIGNED]
    cbSize       : WD.UINT;
 
(*  Win 3.x  *)
    style        : WD.UINT;
    lpfnWndProc  : WNDPROC;
    cbClsExtra   : LONGINT;
    cbWndExtra   : LONGINT;
    hInstance    : WD.HINSTANCE;
    hIcon        : WD.HICON;
    hCursor      : WD.HCURSOR;
    hbrBackground: WD.HBRUSH;
    lpszMenuName : WD.LPCWSTR;
    lpszClassName: WD.LPCWSTR;
 
(*  Win 4.0  *)
    hIconSm      : WD.HICON;
  END;

  PWNDCLASSEXW = POINTER TO WNDCLASSEXW;
  NPWNDCLASSEXW = POINTER TO WNDCLASSEXW;
  LPWNDCLASSEXW = POINTER TO WNDCLASSEXW;

  WNDCLASSEX = WNDCLASSEXA;      (* ! A *)
  PWNDCLASSEX = PWNDCLASSEXA;    (* ! A *)
  NPWNDCLASSEX = NPWNDCLASSEXA;    (* ! A *)
  LPWNDCLASSEX = LPWNDCLASSEXA;    (* ! A *)

  WNDCLASSA = RECORD [_NOTALIGNED]
    style        : WD.UINT;
    lpfnWndProc  : WNDPROC;
    cbClsExtra   : LONGINT;
    cbWndExtra   : LONGINT;
    hInstance    : WD.HINSTANCE;
    hIcon        : WD.HICON;
    hCursor      : WD.HCURSOR;
    hbrBackground: WD.HBRUSH;
    lpszMenuName : WD.LPCSTR;
    lpszClassName: WD.LPCSTR;
  END;

  PWNDCLASSA = POINTER TO WNDCLASSA;
  NPWNDCLASSA = POINTER TO WNDCLASSA;
  LPWNDCLASSA = POINTER TO WNDCLASSA;

  WNDCLASSW = RECORD [_NOTALIGNED]
    style        : WD.UINT;
    lpfnWndProc  : WNDPROC;
    cbClsExtra   : LONGINT;
    cbWndExtra   : LONGINT;
    hInstance    : WD.HINSTANCE;
    hIcon        : WD.HICON;
    hCursor      : WD.HCURSOR;
    hbrBackground: WD.HBRUSH;
    lpszMenuName : WD.LPCWSTR;
    lpszClassName: WD.LPCWSTR;
  END;

  PWNDCLASSW = POINTER TO WNDCLASSW;
  NPWNDCLASSW = POINTER TO WNDCLASSW;
  LPWNDCLASSW = POINTER TO WNDCLASSW;

  WNDCLASS = WNDCLASSA;      (* ! A *)
  PWNDCLASS = PWNDCLASSA;    (* ! A *)
  NPWNDCLASS = NPWNDCLASSA;    (* ! A *)
  LPWNDCLASS = LPWNDCLASSA;    (* ! A *)

(*                       *)
(*  * Message structure  *)
(*                       *)

  MSG = RECORD [_NOTALIGNED]
    hwnd   : WD.HWND;
    message: WD.UINT;
    wParam : WD.WPARAM;
    lParam : WD.LPARAM;
    time   : WD.DWORD;
    pt     : WD.POINT;
  END;

  PMSG = POINTER TO MSG;
  NPMSG = POINTER TO MSG;
  LPMSG = POINTER TO MSG;

(*                                                  *)
(*  * Struct pointed to by WM_GETMINMAXINFO lParam  *)
(*                                                  *)


  MINMAXINFO = RECORD [_NOTALIGNED]
    ptReserved    : WD.POINT;
    ptMaxSize     : WD.POINT;
    ptMaxPosition : WD.POINT;
    ptMinTrackSize: WD.POINT;
    ptMaxTrackSize: WD.POINT;
  END;

  PMINMAXINFO = POINTER TO MINMAXINFO;
  LPMINMAXINFO = POINTER TO MINMAXINFO;

(*                                                *)
(*  * lParam of WM_COPYDATA message points to...  *)
(*                                                *)

  COPYDATASTRUCT = RECORD [_NOTALIGNED]
    dwData: WD.DWORD;
    cbData: WD.DWORD;
    lpData: WD.LPVOID;
  END;

  PCOPYDATASTRUCT = POINTER TO COPYDATASTRUCT;

  MDINEXTMENU = RECORD [_NOTALIGNED]
    hmenuIn  : WD.HMENU;
    hmenuNext: WD.HMENU;
    hwndNext : WD.HWND;
  END;

  PMDINEXTMENU = POINTER TO MDINEXTMENU;
  LPMDINEXTMENU = POINTER TO MDINEXTMENU;

(*                             *)
(*  * Obsolete constant names  *)
(*                             *)
(*                                                              *)
(*  * WM_WINDOWPOSCHANGING/CHANGED struct pointed to by lParam  *)
(*                                                              *)


  WINDOWPOS = RECORD [_NOTALIGNED]
    hwnd           : WD.HWND;
    hwndInsertAfter: WD.HWND;
    x              : LONGINT;
    y              : LONGINT;
    cx             : LONGINT;
    cy             : LONGINT;
    flags          : WD.UINT;
  END;

  LPWINDOWPOS = POINTER TO WINDOWPOS;
  PWINDOWPOS = POINTER TO WINDOWPOS;

(*                                       *)
(*  * WM_NCCALCSIZE parameter structure  *)
(*                                       *)

  NCCALCSIZE_PARAMS = RECORD [_NOTALIGNED]
    rgrc : ARRAY 3 OF WD.RECT;
    lppos: PWINDOWPOS;
  END;

  LPNCCALCSIZE_PARAMS = POINTER TO NCCALCSIZE_PARAMS;

  ACCEL = RECORD [_NOTALIGNED]
    fVirt: WD.BYTE;   (*  Also called the flags field  *)
    key  : WD.WORD;
    cmd  : WD.WORD;
  END;

  LPACCEL = POINTER TO ACCEL;

  PAINTSTRUCT = RECORD [_NOTALIGNED]
    hdc        : WD.HDC;
    fErase     : WD.BOOL;
    rcPaint    : WD.RECT;
    fRestore   : WD.BOOL;
    fIncUpdate : WD.BOOL;
    rgbReserved: ARRAY 32 OF WD.BYTE;
  END;

  PPAINTSTRUCT = POINTER TO PAINTSTRUCT;
  NPPAINTSTRUCT = POINTER TO PAINTSTRUCT;
  LPPAINTSTRUCT = POINTER TO PAINTSTRUCT;


  WINDOWPLACEMENT = RECORD [_NOTALIGNED]
    length          : WD.UINT;
    flags           : WD.UINT;
    showCmd         : WD.UINT;
    ptMinPosition   : WD.POINT;
    ptMaxPosition   : WD.POINT;
    rcNormalPosition: WD.RECT;
  END;

  PWINDOWPLACEMENT = POINTER TO WINDOWPLACEMENT;

  LPWINDOWPLACEMENT = POINTER TO WINDOWPLACEMENT;

  NMHDR = RECORD [_NOTALIGNED]
    hwndFrom: WD.HWND;
    idFrom  : WD.UINT;
    code    : WD.UINT;   (*  NM_ code *)
  END;

  LPNMHDR = POINTER TO NMHDR;

  STYLESTRUCT = RECORD [_NOTALIGNED]
    styleOld: WD.DWORD;
    styleNew: WD.DWORD;
  END;

  LPSTYLESTRUCT = POINTER TO STYLESTRUCT;


(*                                     *)
(*  * MEASUREITEMSTRUCT for ownerdraw  *)
(*                                     *)
 
  MEASUREITEMSTRUCT = RECORD [_NOTALIGNED]
    CtlType   : WD.UINT;
    CtlID     : WD.UINT;
    itemID    : WD.UINT;
    itemWidth : WD.UINT;
    itemHeight: WD.UINT;
    itemData  : WD.DWORD;
  END;

  PMEASUREITEMSTRUCT = POINTER TO MEASUREITEMSTRUCT;
  LPMEASUREITEMSTRUCT = POINTER TO MEASUREITEMSTRUCT;

(*                                  *)
(*  * DRAWITEMSTRUCT for ownerdraw  *)
(*                                  *)

  DRAWITEMSTRUCT = RECORD [_NOTALIGNED]
    CtlType   : WD.UINT;
    CtlID     : WD.UINT;
    itemID    : WD.UINT;
    itemAction: WD.UINT;
    itemState : WD.UINT;
    hwndItem  : WD.HWND;
    hDC       : WD.HDC;
    rcItem    : WD.RECT;
    itemData  : WD.DWORD;
  END;

  PDRAWITEMSTRUCT = POINTER TO DRAWITEMSTRUCT;
  LPDRAWITEMSTRUCT = POINTER TO DRAWITEMSTRUCT;

(*                                    *)
(*  * DELETEITEMSTRUCT for ownerdraw  *)
(*                                    *)

  DELETEITEMSTRUCT = RECORD [_NOTALIGNED]
    CtlType : WD.UINT;
    CtlID   : WD.UINT;
    itemID  : WD.UINT;
    hwndItem: WD.HWND;
    itemData: WD.UINT;
  END;

  PDELETEITEMSTRUCT = POINTER TO DELETEITEMSTRUCT;
  LPDELETEITEMSTRUCT = POINTER TO DELETEITEMSTRUCT;

(*                                            *)
(*  * COMPAREITEMSTUCT for ownerdraw sorting  *)
(*                                            *)

  COMPAREITEMSTRUCT = RECORD [_NOTALIGNED]
    CtlType   : WD.UINT;
    CtlID     : WD.UINT;
    hwndItem  : WD.HWND;
    itemID1   : WD.UINT;
    itemData1 : WD.DWORD;
    itemID2   : WD.UINT;
    itemData2 : WD.DWORD;
    dwLocaleId: WD.DWORD;
  END;

  PCOMPAREITEMSTRUCT = POINTER TO COMPAREITEMSTRUCT;
  LPCOMPAREITEMSTRUCT = POINTER TO COMPAREITEMSTRUCT;
 
  BROADCASTSYSMSG = RECORD [_NOTALIGNED]
    uiMessage: WD.UINT;
    wParam   : WD.WPARAM;
    lParam   : WD.LPARAM;
  END;

  LPBROADCASTSYSMSG = POINTER TO BROADCASTSYSMSG;

(*                                                                        *)
(*  * WARNING:                                                            *)
(*  * The following structures must NOT be DWORD padded because they are  *)
(*  * followed by strings; etc that do not have to be DWORD aligned.      *)
(*                                                                        *)
(* #include <pshpack2.h> *)
(*                                         *)
(*  * original NT 32 bit dialog template:  *)
(*                                         *)
 
  DLGTEMPLATE = RECORD [_NOTALIGNED]
    style          : WD.DWORD;
    dwExtendedStyle: WD.DWORD;
    cdit           : WD.WORD;
    x              : INTEGER;
    y              : INTEGER;
    cx             : INTEGER;
    cy             : INTEGER;
  END;
  DLGTEMPLATEA = DLGTEMPLATE;
  DLGTEMPLATEW = DLGTEMPLATE;
  LPDLGTEMPLATEA = POINTER TO DLGTEMPLATE;
  LPDLGTEMPLATEW = POINTER TO DLGTEMPLATE;
  LPDLGTEMPLATE =  POINTER TO DLGTEMPLATE;
  LPCDLGTEMPLATEA = POINTER TO DLGTEMPLATE;
  LPCDLGTEMPLATEW = POINTER TO DLGTEMPLATE;
  LPCDLGTEMPLATE = LPDLGTEMPLATEA;  (* ! A *)

(*                                  *)
(*  * 32 bit Dialog item template.  *)
(*                                  *)

  DLGITEMTEMPLATE = RECORD [_NOTALIGNED]
    style          : WD.DWORD;
    dwExtendedStyle: WD.DWORD;
    x              : INTEGER;
    y              : INTEGER;
    cx             : INTEGER;
    cy             : INTEGER;
    id             : WD.WORD;
  END;

  PDLGITEMTEMPLATEA = POINTER TO DLGITEMTEMPLATE;
  PDLGITEMTEMPLATEW = POINTER TO DLGITEMTEMPLATE;
  PDLGITEMTEMPLATE =  POINTER TO DLGITEMTEMPLATE;
  LPDLGITEMTEMPLATEA = POINTER TO DLGITEMTEMPLATE;
  LPDLGITEMTEMPLATEW = POINTER TO DLGITEMTEMPLATE;
  LPDLGITEMTEMPLATE = LPDLGITEMTEMPLATEA;  (* ! A *)

 
  TPMPARAMS = RECORD [_NOTALIGNED]
    cbSize   : WD.UINT;   (*  Size of structure  *)
    rcExclude: WD.RECT;   (*  Screen coordinates of rectangle to exclude when positioning  *)
  END;

  LPTPMPARAMS = POINTER TO TPMPARAMS;


 
  MENUITEMINFOA = RECORD [_NOTALIGNED]
    cbSize       : WD.UINT;
    fMask        : WD.UINT;
    fType        : WD.UINT;      (*  used if MIIM_TYPE *)
    fState       : WD.UINT;      (*  used if MIIM_STATE *)
    wID          : WD.UINT;      (*  used if MIIM_ID *)
    hSubMenu     : WD.HMENU;     (*  used if MIIM_SUBMENU *)
    hbmpChecked  : WD.HBITMAP;   (*  used if MIIM_CHECKMARKS *)
    hbmpUnchecked: WD.HBITMAP;   (*  used if MIIM_CHECKMARKS *)
    dwItemData   : WD.DWORD;     (*  used if MIIM_DATA *)
    dwTypeData   : WD.LPSTR;     (*  used if MIIM_TYPE *)
    cch          : WD.UINT;      (*  used if MIIM_TYPE *)
  END;

  LPMENUITEMINFOA = POINTER TO MENUITEMINFOA;

  MENUITEMINFOW = RECORD [_NOTALIGNED]
    cbSize       : WD.UINT;
    fMask        : WD.UINT;
    fType        : WD.UINT;      (*  used if MIIM_TYPE *)
    fState       : WD.UINT;      (*  used if MIIM_STATE *)
    wID          : WD.UINT;      (*  used if MIIM_ID *)
    hSubMenu     : WD.HMENU;     (*  used if MIIM_SUBMENU *)
    hbmpChecked  : WD.HBITMAP;   (*  used if MIIM_CHECKMARKS *)
    hbmpUnchecked: WD.HBITMAP;   (*  used if MIIM_CHECKMARKS *)
    dwItemData   : WD.DWORD;     (*  used if MIIM_DATA *)
    dwTypeData   : WD.LPWSTR;     (*  used if MIIM_TYPE *)
    cch          : WD.UINT;      (*  used if MIIM_TYPE *)
  END;

  LPMENUITEMINFOW = POINTER TO MENUITEMINFOW;

  MENUITEMINFO = MENUITEMINFOA;    (* ! A *)
  LPMENUITEMINFO = LPMENUITEMINFOA;  (* ! A *)
  LPCMENUITEMINFOA = POINTER TO MENUITEMINFOA;
  LPCMENUITEMINFOW = POINTER TO MENUITEMINFOW;
  LPCMENUITEMINFO = LPMENUITEMINFOA;  (* ! A *)


(*  *)
(*  Drag-and-drop support *)
(*  *)

 
  DROPSTRUCT = RECORD [_NOTALIGNED]
    hwndSource   : WD.HWND;
    hwndSink     : WD.HWND;
    wFmt         : WD.DWORD;
    dwData       : WD.DWORD;
    ptDrop       : WD.POINT;
    dwControlData: WD.DWORD;
  END;

  PDROPSTRUCT = POINTER TO DROPSTRUCT;
  LPDROPSTRUCT = POINTER TO DROPSTRUCT;

  DRAWTEXTPARAMS = RECORD [_NOTALIGNED]
    cbSize       : WD.UINT;
    iTabLength   : LONGINT;
    iLeftMargin  : LONGINT;
    iRightMargin : LONGINT;
    uiLengthDrawn: WD.UINT;
  END;

  LPDRAWTEXTPARAMS = POINTER TO DRAWTEXTPARAMS;

(*  Structure pointed to by lParam of WM_HELP  *)
 
  HELPINFO = RECORD [_NOTALIGNED]
    cbSize      : WD.UINT;     (*  Size in bytes of this struct   *)
    iContextType: LONGINT;             (*  Either HELPINFO_WINDOW or HELPINFO_MENUITEM  *)
    iCtrlId     : LONGINT;             (*  Control Id or a Menu item Id.  *)
    hItemHandle : WD.HANDLE;   (*  hWnd of control or hMenu.      *)
    dwContextId : WD.DWORD;    (*  Context Id associated with this item  *)
    MousePos    : WD.POINT;    (*  Mouse Position in screen co-ordinates  *)
  END;

  LPHELPINFO = POINTER TO HELPINFO;

  MSGBOXCALLBACK = PROCEDURE [_APICALL] ( (* lpHelpInfo *)VAR STATICTYPED hlpi: HELPINFO );

  MSGBOXPARAMSA = RECORD [_NOTALIGNED]
    cbSize            : WD.UINT;
    hwndOwner         : WD.HWND;
    hInstance         : WD.HINSTANCE;
    lpszText          : WD.LPCSTR;
    lpszCaption       : WD.LPCSTR;
    dwStyle           : WD.DWORD;
    lpszIcon          : WD.LPCSTR;
    dwContextHelpId   : WD.DWORD;
    lpfnMsgBoxCallback: MSGBOXCALLBACK;
    dwLanguageId      : WD.DWORD;
  END;

  PMSGBOXPARAMSA = POINTER TO MSGBOXPARAMSA;
  LPMSGBOXPARAMSA = POINTER TO MSGBOXPARAMSA;

  MSGBOXPARAMSW = RECORD [_NOTALIGNED]
    cbSize            : WD.UINT;
    hwndOwner         : WD.HWND;
    hInstance         : WD.HINSTANCE;
    lpszText          : WD.LPCWSTR;
    lpszCaption       : WD.LPCWSTR;
    dwStyle           : WD.DWORD;
    lpszIcon          : WD.LPCWSTR;
    dwContextHelpId   : WD.DWORD;
    lpfnMsgBoxCallback: MSGBOXCALLBACK;
    dwLanguageId      : WD.DWORD;
  END;

  PMSGBOXPARAMSW = POINTER TO MSGBOXPARAMSW;
  LPMSGBOXPARAMSW = POINTER TO MSGBOXPARAMSW;
  MSGBOXPARAMS = MSGBOXPARAMSA;    (* ! A *)
  PMSGBOXPARAMS = PMSGBOXPARAMSA;  (* ! A *)
  LPMSGBOXPARAMS = PMSGBOXPARAMSA;  (* ! A *)


(*                               *)
(*  * Menu item resource format  *)
(*                               *)

  MENUITEMTEMPLATEHEADER = RECORD [_NOTALIGNED]
    versionNumber: WD.WORD;
    offset       : WD.WORD;
  END;

  PMENUITEMTEMPLATEHEADER = POINTER TO MENUITEMTEMPLATEHEADER;

  MENUITEMTEMPLATE = RECORD [_NOTALIGNED]
 
(*  version 0 *)
    mtOption: WD.WORD;
    mtID    : WD.WORD;
    mtString: LONGINT;  (*ARRAY [1] OF WG.WCHAR*)
  END;

  PMENUITEMTEMPLATE = POINTER TO MENUITEMTEMPLATE;

(*  Icon/Cursor header  *)

  CURSORSHAPE = RECORD [_NOTALIGNED]
    xHotSpot : LONGINT;
    yHotSpot : LONGINT;
    cx       : LONGINT;
    cy       : LONGINT;
    cbWidth  : LONGINT;
    Planes   : WD.BYTE;
    BitsPixel: WD.BYTE;
  END;

  LPCURSORSHAPE = POINTER TO CURSORSHAPE;
 
  ICONINFO = RECORD [_NOTALIGNED]
    fIcon   : WD.BOOL;
    xHotspot: WD.DWORD;
    yHotspot: WD.DWORD;
    hbmMask : WD.HBITMAP;
    hbmColor: WD.HBITMAP;
  END;

  PICONINFO = POINTER TO ICONINFO;

  SCROLLINFO = RECORD [_NOTALIGNED]
    cbSize   : WD.UINT;
    fMask    : WD.UINT;
    nMin     : LONGINT;
    nMax     : LONGINT;
    nPage    : WD.UINT;
    nPos     : LONGINT;
    nTrackPos: LONGINT;
  END;

  LPSCROLLINFO = POINTER TO SCROLLINFO;

  LPCSCROLLINFO = POINTER TO SCROLLINFO;

 
  MDICREATESTRUCTA = RECORD [_NOTALIGNED]
    szClass: WD.LPCSTR;
    szTitle: WD.LPCSTR;
    hOwner : WD.HANDLE;
    x      : LONGINT;
    y      : LONGINT;
    cx     : LONGINT;
    cy     : LONGINT;
    style  : WD.DWORD;
    lParam : WD.LPARAM;    (*  app-defined stuff  *)
  END;

  LPMDICREATESTRUCTA = POINTER TO MDICREATESTRUCTA;

  MDICREATESTRUCTW = RECORD [_NOTALIGNED]
    szClass: WD.LPCWSTR;
    szTitle: WD.LPCWSTR;
    hOwner : WD.HANDLE;
    x      : LONGINT;
    y      : LONGINT;
    cx     : LONGINT;
    cy     : LONGINT;
    style  : WD.DWORD;
    lParam : WD.LPARAM;    (*  app-defined stuff  *)
  END;

  LPMDICREATESTRUCTW = POINTER TO MDICREATESTRUCTW;

  MDICREATESTRUCT = MDICREATESTRUCTA;     (* ! A *)
  LPMDICREATESTRUCT = LPMDICREATESTRUCTA;   (* ! A *)

  CLIENTCREATESTRUCT = RECORD [_NOTALIGNED]
    hWindowMenu : WD.HANDLE;
    idFirstChild: WD.UINT;
  END;

  LPCLIENTCREATESTRUCT = POINTER TO CLIENTCREATESTRUCT;


(* ***** Help support ******************************************************* *)

 HELPPOLY = LONGINT;

  MULTIKEYHELPA = RECORD [_NOTALIGNED]
    mkSize     : WD.DWORD;
    mkKeylist  : CHAR;
    szKeyphrase: LONGINT;  (*ARRAY [1] OF CHAR;*)
  END;

  PMULTIKEYHELPA = POINTER TO MULTIKEYHELPA;
  LPMULTIKEYHELPA = POINTER TO MULTIKEYHELPA;

  MULTIKEYHELPW = RECORD [_NOTALIGNED]
    mkSize     : WD.DWORD;
    mkKeylist  : WD.WCHAR;
    szKeyphrase: LONGINT;  (*ARRAY [1] OF WD.WCHAR;*)
  END;

  PMULTIKEYHELPW = POINTER TO MULTIKEYHELPW;
  LPMULTIKEYHELPW = POINTER TO MULTIKEYHELPW;
  MULTIKEYHELP = MULTIKEYHELPA;       (* ! A *)
  PMULTIKEYHELP = PMULTIKEYHELPA;     (* ! A *)
  LPMULTIKEYHELP = PMULTIKEYHELPA;     (* ! A *)

  HELPWININFOA = RECORD [_NOTALIGNED]
    wStructSize: LONGINT;
    x          : LONGINT;
    y          : LONGINT;
    dx         : LONGINT;
    dy         : LONGINT;
    wMax       : LONGINT;
    rgchMember : ARRAY 2 OF CHAR;
  END;

  PHELPWININFOA = POINTER TO HELPWININFOA;
  LPHELPWININFOA = POINTER TO HELPWININFOA;
  
  HELPWININFOW = RECORD [_NOTALIGNED]
    wStructSize: LONGINT;
    x          : LONGINT;
    y          : LONGINT;
    dx         : LONGINT;
    dy         : LONGINT;
    wMax       : LONGINT;
    rgchMember : ARRAY 2 OF WD.WCHAR;
  END;

  PHELPWININFOW = POINTER TO HELPWININFOW;
  LPHELPWININFOW = POINTER TO HELPWININFOW;
  HELPWININFO = HELPWININFOA;     (* ! A *)
  PHELPWININFO = PHELPWININFOA;     (* ! A *)
  LPHELPWININFO = PHELPWININFOA;   (* ! A *)


  NONCLIENTMETRICSA = RECORD [_NOTALIGNED]
    cbSize          : WD.UINT;
    iBorderWidth    : LONGINT;
    iScrollWidth    : LONGINT;
    iScrollHeight   : LONGINT;
    iCaptionWidth   : LONGINT;
    iCaptionHeight  : LONGINT;
    lfCaptionFont   : WG.LOGFONTA;
    iSmCaptionWidth : LONGINT;
    iSmCaptionHeight: LONGINT;
    lfSmCaptionFont : WG.LOGFONTA;
    iMenuWidth      : LONGINT;
    iMenuHeight     : LONGINT;
    lfMenuFont      : WG.LOGFONTA;
    lfStatusFont    : WG.LOGFONTA;
    lfMessageFont   : WG.LOGFONTA;
  END;

  PNONCLIENTMETRICSA = POINTER TO NONCLIENTMETRICSA;
  LPNONCLIENTMETRICSA = POINTER TO NONCLIENTMETRICSA;

  NONCLIENTMETRICSW = RECORD [_NOTALIGNED]
    cbSize          : WD.UINT;
    iBorderWidth    : LONGINT;
    iScrollWidth    : LONGINT;
    iScrollHeight   : LONGINT;
    iCaptionWidth   : LONGINT;
    iCaptionHeight  : LONGINT;
    lfCaptionFont   : WG.LOGFONTW;
    iSmCaptionWidth : LONGINT;
    iSmCaptionHeight: LONGINT;
    lfSmCaptionFont : WG.LOGFONTW;
    iMenuWidth      : LONGINT;
    iMenuHeight     : LONGINT;
    lfMenuFont      : WG.LOGFONTW;
    lfStatusFont    : WG.LOGFONTW;
    lfMessageFont   : WG.LOGFONTW;
  END;

  PNONCLIENTMETRICSW = POINTER TO NONCLIENTMETRICSW;
  LPNONCLIENTMETRICSW = POINTER TO NONCLIENTMETRICSW;
  NONCLIENTMETRICS = NONCLIENTMETRICSA;     (* ! A *)
  PNONCLIENTMETRICS = PNONCLIENTMETRICSA;   (* ! A *)
  LPNONCLIENTMETRICS = LPNONCLIENTMETRICSA;   (* ! A *)

 
  MINIMIZEDMETRICS = RECORD [_NOTALIGNED]
    cbSize  : WD.UINT;
    iWidth  : LONGINT;
    iHorzGap: LONGINT;
    iVertGap: LONGINT;
    iArrange: LONGINT;
  END;

  PMINIMIZEDMETRICS = POINTER TO MINIMIZEDMETRICS;
  LPMINIMIZEDMETRICS = POINTER TO MINIMIZEDMETRICS;

  ICONMETRICSA = RECORD [_NOTALIGNED]
    cbSize      : WD.UINT;
    iHorzSpacing: LONGINT;
    iVertSpacing: LONGINT;
    iTitleWrap  : LONGINT;
    lfFont      : WG.LOGFONTA;
  END;

  PICONMETRICSA = POINTER TO ICONMETRICSA;
  LPICONMETRICSA = POINTER TO ICONMETRICSA;

  ICONMETRICSW = RECORD [_NOTALIGNED]
    cbSize      : WD.UINT;
    iHorzSpacing: LONGINT;
    iVertSpacing: LONGINT;
    iTitleWrap  : LONGINT;
    lfFont      : WG.LOGFONTW;
  END;

  PICONMETRICSW = POINTER TO ICONMETRICSW;
  LPICONMETRICSW = POINTER TO ICONMETRICSW;
  ICONMETRICS = ICONMETRICSA;     (* ! A *)
  PICONMETRICS = PICONMETRICSA;     (* ! A *)
  LPICONMETRICS = PICONMETRICSA;   (* ! A *)

  ANIMATIONINFO = RECORD [_NOTALIGNED]
    cbSize     : WD.UINT;
    iMinAnimate: LONGINT;
  END;

  LPANIMATIONINFO = POINTER TO ANIMATIONINFO;

  SERIALKEYSA = RECORD [_NOTALIGNED]
    cbSize        : WD.UINT;
    dwFlags       : WD.DWORD;
    lpszActivePort: WD.LPSTR;
    lpszPort      : WD.LPSTR;
    iBaudRate     : WD.UINT;
    iPortState    : WD.UINT;
    iActive       : WD.UINT;
  END;

  LPSERIALKEYSA = POINTER TO SERIALKEYSA;

  SERIALKEYSW = RECORD [_NOTALIGNED]
    cbSize        : WD.UINT;
    dwFlags       : WD.DWORD;
    lpszActivePort: WD.LPWSTR;
    lpszPort      : WD.LPWSTR;
    iBaudRate     : WD.UINT;
    iPortState    : WD.UINT;
    iActive       : WD.UINT;
  END;

  LPSERIALKEYSW = POINTER TO SERIALKEYSW;
  SERIALKEYS = SERIALKEYSA;      (* ! A *)
  LPSERIALKEYS = LPSERIALKEYSA;    (* ! A *)


 
  HIGHCONTRASTA = RECORD [_NOTALIGNED]
    cbSize           : WD.UINT;
    dwFlags          : WD.DWORD;
    lpszDefaultScheme: WD.LPSTR;
  END;

  LPHIGHCONTRASTA = POINTER TO HIGHCONTRASTA;

  HIGHCONTRASTW = RECORD [_NOTALIGNED]
    cbSize           : WD.UINT;
    dwFlags          : WD.DWORD;
    lpszDefaultScheme: WD.LPWSTR;
  END;

  LPHIGHCONTRASTW = POINTER TO HIGHCONTRASTW;
  HIGHCONTRAST = HIGHCONTRASTA;      (* ! A *)
  LPHIGHCONTRAST = LPHIGHCONTRASTA;      (* ! A *)

(*                           *)
(*  * Accessibility support  *)
(*                           *)

  FILTERKEYS = RECORD [_NOTALIGNED]
    cbSize     : WD.UINT;
    dwFlags    : WD.DWORD;
    iWaitMSec  : WD.DWORD;   (*  Acceptance Delay *)
    iDelayMSec : WD.DWORD;   (*  Delay Until Repeat *)
    iRepeatMSec: WD.DWORD;   (*  Repeat Rate *)
    iBounceMSec: WD.DWORD;   (*  Debounce Time *)
  END;

  LPFILTERKEYS = POINTER TO FILTERKEYS;

  STICKYKEYS = RECORD [_NOTALIGNED]
    cbSize : WD.UINT;
    dwFlags: WD.DWORD;
  END;

  LPSTICKYKEYS = POINTER TO STICKYKEYS;


  MOUSEKEYS = RECORD [_NOTALIGNED]
    cbSize         : WD.UINT;
    dwFlags        : WD.DWORD;
    iMaxSpeed      : WD.DWORD;
    iTimeToMaxSpeed: WD.DWORD;
    iCtrlSpeed     : WD.DWORD;
    dwReserved1    : WD.DWORD;
    dwReserved2    : WD.DWORD;
  END;

  LPMOUSEKEYS = POINTER TO MOUSEKEYS;

 
  ACCESSTIMEOUT = RECORD [_NOTALIGNED]
    cbSize      : WD.UINT;
    dwFlags     : WD.DWORD;
    iTimeOutMSec: WD.DWORD;
  END;

  LPACCESSTIMEOUT = POINTER TO ACCESSTIMEOUT;

 SOUNDSENTRYA = RECORD [_NOTALIGNED]
    cbSize                : WD.UINT;
    dwFlags               : WD.DWORD;
    iFSTextEffect         : WD.DWORD;
    iFSTextEffectMSec     : WD.DWORD;
    iFSTextEffectColorBits: WD.DWORD;
    iFSGrafEffect         : WD.DWORD;
    iFSGrafEffectMSec     : WD.DWORD;
    iFSGrafEffectColor    : WD.DWORD;
    iWindowsEffect        : WD.DWORD;
    iWindowsEffectMSec    : WD.DWORD;
    lpszWindowsEffectDLL  : WD.LPSTR;
    iWindowsEffectOrdinal : WD.DWORD;
  END;

  LPSOUNDSENTRYA = POINTER TO SOUNDSENTRYA;

  SOUNDSENTRYW = RECORD [_NOTALIGNED]
    cbSize                : WD.UINT;
    dwFlags               : WD.DWORD;
    iFSTextEffect         : WD.DWORD;
    iFSTextEffectMSec     : WD.DWORD;
    iFSTextEffectColorBits: WD.DWORD;
    iFSGrafEffect         : WD.DWORD;
    iFSGrafEffectMSec     : WD.DWORD;
    iFSGrafEffectColor    : WD.DWORD;
    iWindowsEffect        : WD.DWORD;
    iWindowsEffectMSec    : WD.DWORD;
    lpszWindowsEffectDLL  : WD.LPWSTR;
    iWindowsEffectOrdinal : WD.DWORD;
  END;

  LPSOUNDSENTRYW = POINTER TO SOUNDSENTRYW;
  SOUNDSENTRY = SOUNDSENTRYA;      (* ! A *)
  LPSOUNDSENTRY = LPSOUNDSENTRYA;    (* ! A *)


(*                              *)
(*  * FILTERKEYS dwFlags field  *)
(*                              *)

  TOGGLEKEYS = STICKYKEYS;
  LPTOGGLEKEYS = LPSTICKYKEYS;




(*                         *)
(*  * Keyboard Layout API  *)
(*                         *)

PROCEDURE [_APICALL] LoadKeyboardLayoutA ( pwszKLID: WD.LPCSTR;
                                Flags: WD.UINT ): WD.HKL;
PROCEDURE [_APICALL] LoadKeyboardLayoutW ( pwszKLID: WD.LPCWSTR;
                                Flags: WD.UINT ): WD.HKL;
(*  ! LoadKeyboardLayout *)

PROCEDURE [_APICALL] ActivateKeyboardLayout ( hkl: WD.HKL;
                                   Flags: WD.UINT ): WD.HKL;

PROCEDURE [_APICALL] ToUnicodeEx ( wVirtKey: WD.UINT; wScanCode: WD.UINT;
                        lpKeyState: WD.PBYTE; pwszBuff: WD.LPWSTR;
                        cchBuff: LONGINT; wFlags: WD.UINT;
                        dwhkl: WD.HKL ): LONGINT;

PROCEDURE [_APICALL] UnloadKeyboardLayout ( hkl: WD.HKL ): WD.BOOL;

PROCEDURE [_APICALL] GetKeyboardLayoutNameA ( pwszKLID: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] GetKeyboardLayoutNameW ( pwszKLID: WD.LPWSTR ): WD.BOOL;
(*  !  GetKeyboardLayoutName *)

PROCEDURE [_APICALL] GetKeyboardLayoutList ( nBuff: LONGINT;
                                  VAR  list: WG.FXPT16DOT16 ): LONGINT;

PROCEDURE [_APICALL] GetKeyboardLayout ( dwLayout: WD.DWORD ): WD.HKL;

(*                                   *)
(*  * Desktop-specific access flags  *)
(*                                   *)



PROCEDURE [_APICALL] wvsprintfA ( arg0: WD.LPSTR; arg1: WD.LPCSTR;
                       arglist: va_list ): LONGINT;
PROCEDURE [_APICALL] wvsprintfW ( arg0: WD.LPWSTR; arg1: WD.LPCWSTR;
                       arglist: va_list ): LONGINT;
(* !  wvsprintf *)

PROCEDURE [_APICALL] wsprintfA ( arg0: WD.LPSTR; arg1: WD.LPCSTR;
                       arg2: LONGINT (*... *) ): LONGINT;
PROCEDURE [_APICALL] wsprintfW ( arg0: WD.LPWSTR; arg1: WD.LPCWSTR;
                       arg2: LONGINT (*...  *) ): LONGINT;
(*  !  wsprintf *)

PROCEDURE [_APICALL] CreateDesktopA ( lpszDesktop: WD.LPSTR;
                           lpszDevice: WD.LPSTR;
                           VAR STATICTYPED pDevmode: WG.DEVMODEA; dwFlags: WD.DWORD;
                           dwDesiredAccess: WD.DWORD;
                           lpsa: LPSECURITY_ATTRIBUTES ): WD.HDESK;
PROCEDURE [_APICALL] CreateDesktopW ( lpszDesktop: WD.LPWSTR;
                           lpszDevice: WD.LPWSTR;
                           VAR STATICTYPED pDevmode: WG.DEVMODEW; dwFlags: WD.DWORD;
                           dwDesiredAccess: WD.DWORD;
                           lpsa: LPSECURITY_ATTRIBUTES ): WD.HDESK;
(*  !  CreateDesktop *)

PROCEDURE [_APICALL] OpenDesktopA ( lpszDesktop: WD.LPSTR; dwFlags: WD.DWORD;
                         fInherit: WD.BOOL;
                         dwDesiredAccess: WD.DWORD ): WD.HDESK;
PROCEDURE [_APICALL] OpenDesktopW ( lpszDesktop: WD.LPWSTR; dwFlags: WD.DWORD;
                         fInherit: WD.BOOL;
                         dwDesiredAccess: WD.DWORD ): WD.HDESK;
(*  !  OpenDesktop *)

PROCEDURE [_APICALL] OpenInputDesktop ( dwFlags: WD.DWORD; fInherit: WD.BOOL;
                             dwDesiredAccess: WD.DWORD ): WD.HDESK;

PROCEDURE [_APICALL] EnumDesktopsA ( hwinsta: WD.HWINSTA; lpEnumFunc: DESKTOPENUMPROCA;
                          lParam: WD.LPARAM ): WD.BOOL;
PROCEDURE [_APICALL] EnumDesktopsW ( hwinsta: WD.HWINSTA; lpEnumFunc: DESKTOPENUMPROCW;
                          lParam: WD.LPARAM ): WD.BOOL;
(*  !  EnumDesktops *)

PROCEDURE [_APICALL] EnumDesktopWindows ( hDesktop: WD.HDESK; lpfn: WNDENUMPROC;
                               lParam: WD.LPARAM ): WD.BOOL;

PROCEDURE [_APICALL] SwitchDesktop ( hDesktop: WD.HDESK ): WD.BOOL;

PROCEDURE [_APICALL] SetThreadDesktop ( hDesktop: WD.HDESK ): WD.BOOL;

PROCEDURE [_APICALL] CloseDesktop ( hDesktop: WD.HDESK ): WD.BOOL;

PROCEDURE [_APICALL] GetThreadDesktop ( dwThreadId: WD.DWORD ): WD.HDESK;

PROCEDURE [_APICALL] CreateWindowStationA ( lpwinsta: WD.LPSTR;
                                 dwReserved: WD.DWORD;
                                 dwDesiredAccess: WD.DWORD;
                                 VAR STATICTYPED lpsa: SECURITY_ATTRIBUTES ): WD.HWINSTA;
PROCEDURE [_APICALL] CreateWindowStationW ( lpwinsta: WD.LPWSTR;
                                 dwReserved: WD.DWORD;
                                 dwDesiredAccess: WD.DWORD;
                                 VAR STATICTYPED lpsa: SECURITY_ATTRIBUTES ): WD.HWINSTA;
(*  !   CreateWindowStation *)

PROCEDURE [_APICALL] OpenWindowStationA ( lpszWinSta: WD.LPSTR;
                               fInherit: WD.BOOL;
                               dwDesiredAccess: WD.DWORD ): WD.HWINSTA;
PROCEDURE [_APICALL] OpenWindowStationW ( lpszWinSta: WD.LPWSTR;
                               fInherit: WD.BOOL;
                               dwDesiredAccess: WD.DWORD ): WD.HWINSTA;
(*  !  OpenWindowStation *)

PROCEDURE [_APICALL] EnumWindowStationsA ( lpEnumFunc: WINSTAENUMPROCA;
                                lParam: WD.LPARAM ): WD.BOOL;
PROCEDURE [_APICALL] EnumWindowStationsW ( lpEnumFunc: WINSTAENUMPROCW;
                                lParam: WD.LPARAM ): WD.BOOL;
(*  !  EnumWindowStations *)

PROCEDURE [_APICALL] CloseWindowStation ( hWinSta: WD.HWINSTA ): WD.BOOL;

PROCEDURE [_APICALL] SetProcessWindowStation ( hWinSta: WD.HWINSTA ): WD.BOOL;

PROCEDURE [_APICALL] GetProcessWindowStation (  ): WD.HWINSTA;

PROCEDURE [_APICALL] SetUserObjectSecurity ( hObj: WD.HANDLE;
                                  pSIRequested: PSECURITY_INFORMATION;
                                  pSID: PSECURITY_DESCRIPTOR ): WD.BOOL;

PROCEDURE [_APICALL] GetUserObjectSecurity ( hObj: WD.HANDLE;
                                  pSIRequested: PSECURITY_INFORMATION;
                                  pSID: PSECURITY_DESCRIPTOR;
                                  nLength: WD.DWORD;
                                  lpnLengthNeeded: WD.LPDWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetUserObjectInformationA ( hObj: WD.HANDLE; nIndex: LONGINT;
                                      pvInfo: WD.LPVOID;
                                      nLength: WD.DWORD;
                                      VAR lpnLengthNeeded: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] GetUserObjectInformationW ( hObj: WD.HANDLE; nIndex: LONGINT;
                                      pvInfo: WD.LPVOID;
                                      nLength: WD.DWORD;
                                      VAR lpnLengthNeeded: WD.DWORD ): WD.BOOL;
(*  !  GetUserObjectInformation *)

PROCEDURE [_APICALL] SetUserObjectInformationA ( hObj: WD.HANDLE; nIndex: LONGINT;
                                      pvInfo: WD.LPVOID;
                                      nLength: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] SetUserObjectInformationW ( hObj: WD.HANDLE; nIndex: LONGINT;
                                      pvInfo: WD.LPVOID;
                                      nLength: WD.DWORD ): WD.BOOL;
(*  !   SetUserObjectInformation *)

(* Macros 
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] POINTSTOPOINT ( pt; pts: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / POINTSTOPOINT ( pt; pts: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] POINTTOPOINTS ( pt: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / POINTTOPOINTS ( pt: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKEWPARAM ( l; h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKEWPARAM ( l; h: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKELPARAM ( l; h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKELPARAM ( l; h: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] MAKELRESULT ( l; h: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / MAKELRESULT ( l; h: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros*)

PROCEDURE [_APICALL] RegisterWindowMessageA ( lpString: WD.LPCSTR ): WD.UINT;
PROCEDURE [_APICALL] RegisterWindowMessageW ( lpString: WD.LPCWSTR ): WD.UINT;
(*  ! RegisterWindowMessage *)

PROCEDURE [_APICALL] DrawEdge ( hdc: WD.HDC; VAR STATICTYPED qrc: WD.RECT;
                     edge: WD.UINT;
                     grfFlags: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DrawFrameControl ( arg0: WD.HDC; VAR STATICTYPED arg1: WD.RECT;
                             arg2: WD.UINT;
                             arg3: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DrawCaption ( arg0: WD.HWND; arg1: WD.HDC;
                        VAR STATICTYPED arg2: WD.RECT;
                        arg3: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DrawAnimatedRects ( hwnd: WD.HWND; idAni: LONGINT;
                              VAR STATICTYPED lprcFrom: WD.RECT;
                              VAR STATICTYPED lprcTo: WD.RECT ): WD.BOOL;

(*                                *)
(*  * Message Function Templates  *)
(*                                *)

PROCEDURE [_APICALL] GetMessageA ( VAR STATICTYPED lpMsg: MSG; hWnd: WD.HWND;
                        wMsgFilterMin: WD.UINT;
                        wMsgFilterMax: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] GetMessageW ( VAR STATICTYPED lpMsg: MSG; hWnd: WD.HWND;
                        wMsgFilterMin: WD.UINT;
                        wMsgFilterMax: WD.UINT ): WD.BOOL;
(*  !  GetMessage *)
PROCEDURE [_APICALL] TranslateMessage ( VAR STATICTYPED lpMsg: MSG ): WD.BOOL;

PROCEDURE [_APICALL] DispatchMessageA ( VAR STATICTYPED lpMsg: MSG ): LONGINT;
PROCEDURE [_APICALL] DispatchMessageW ( VAR STATICTYPED lpMsg: MSG ): LONGINT;
(* !  DispatchMessage *)

PROCEDURE [_APICALL] SetMessageQueue ( cMessagesMax: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] PeekMessageA ( VAR STATICTYPED lpMsg: MSG; hWnd: WD.HWND;
                         wMsgFilterMin: WD.UINT;
                         wMsgFilterMax: WD.UINT;
                         wRemoveMsg: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] PeekMessageW ( VAR STATICTYPED lpMsg: MSG; hWnd: WD.HWND;
                         wMsgFilterMin: WD.UINT;
                         wMsgFilterMax: WD.UINT;
                         wRemoveMsg: WD.UINT ): WD.BOOL;
(*  !   PeekMessage *)


PROCEDURE [_APICALL] RegisterHotKey ( hWnd: WD.HWND; id: LONGINT;
                           fsModifiers: WD.UINT;
                           vk: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] UnregisterHotKey ( hWnd: WD.HWND; id: LONGINT ): WD.BOOL;



(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ExitWindows ( dwReserved; Code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ExitWindows ( dwReserved; Code: ARRAY OF SYSTEM.BYTE );
<* END *>
*)

PROCEDURE [_APICALL] ExitWindowsEx ( uFlags: WD.UINT;
                          dwReserved: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SwapMouseButton ( fSwap: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetMessagePos (  ): WD.DWORD;

PROCEDURE [_APICALL] GetMessageTime (  ): LONGINT;

PROCEDURE [_APICALL] GetMessageExtraInfo (  ): LONGINT;

PROCEDURE [_APICALL] SetMessageExtraInfo ( lParam: WD.LPARAM ): WD.LPARAM;

PROCEDURE [_APICALL] SendMessageA ( hWnd: WD.HWND; Msg: WD.UINT;
                         wParam: WD.WPARAM;
                         lParam: WD.LPARAM ): WD.LRESULT;
PROCEDURE [_APICALL] SendMessageW ( hWnd: WD.HWND; Msg: WD.UINT;
                         wParam: WD.WPARAM;
                         lParam: WD.LPARAM ): WD.LRESULT;
(*  !  SendMessage *)

PROCEDURE [_APICALL] SendMessageTimeoutA ( hWnd: WD.HWND; Msg: WD.UINT;
                                wParam: WD.WPARAM; lParam: WD.LPARAM;
                                fuFlags: WD.UINT; uTimeout: WD.UINT;
                                VAR lpdwResult: WD.DWORD ): WD.LRESULT;
PROCEDURE [_APICALL] SendMessageTimeoutW ( hWnd: WD.HWND; Msg: WD.UINT;
                                wParam: WD.WPARAM; lParam: WD.LPARAM;
                                fuFlags: WD.UINT; uTimeout: WD.UINT;
                                VAR lpdwResult: WD.DWORD ): WD.LRESULT;
(*  !   SendMessageTimeout *)

PROCEDURE [_APICALL] SendNotifyMessageA ( hWnd: WD.HWND; Msg: WD.UINT;
                               wParam: WD.WPARAM;
                               lParam: WD.LPARAM ): WD.BOOL;
PROCEDURE [_APICALL] SendNotifyMessageW ( hWnd: WD.HWND; Msg: WD.UINT;
                               wParam: WD.WPARAM;
                               lParam: WD.LPARAM ): WD.BOOL;
(*  !   SendNotifyMessage *)

PROCEDURE [_APICALL] SendMessageCallbackA ( hWnd: WD.HWND; Msg: WD.UINT;
                                 wParam: WD.WPARAM; lParam: WD.LPARAM;
                                 lpResultCallBack: SENDASYNCPROC;
                                 dwData: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] SendMessageCallbackW ( hWnd: WD.HWND; Msg: WD.UINT;
                                 wParam: WD.WPARAM; lParam: WD.LPARAM;
                                 lpResultCallBack: SENDASYNCPROC;
                                 dwData: WD.DWORD ): WD.BOOL;
(*  !  SendMessageCallback *)

PROCEDURE [_APICALL] BroadcastSystemMessageA ( arg0: WD.DWORD; arg1: WD.LPDWORD;
                                   arg2: WD.UINT; arg3: WD.WPARAM;
                                   arg4: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] BroadcastSystemMessageW ( arg0: WD.DWORD; arg1: WD.LPDWORD;
                                   arg2: WD.UINT; arg3: WD.WPARAM;
                                   arg4: WD.LPARAM ): LONGINT;
(* ! BroadCastSystemMessage *)

PROCEDURE [_APICALL] PostMessageA ( hWnd: WD.HWND; Msg: WD.UINT;
                         wParam: WD.WPARAM;
                         lParam: WD.LPARAM ): WD.BOOL;
PROCEDURE [_APICALL] PostMessageW ( hWnd: WD.HWND; Msg: WD.UINT;
                         wParam: WD.WPARAM;
                         lParam: WD.LPARAM ): WD.BOOL;
(*  !  PostMessage *)

PROCEDURE [_APICALL] PostThreadMessageA ( idThread: WD.DWORD; Msg: WD.UINT;
                               wParam: WD.WPARAM;
                               lParam: WD.LPARAM ): WD.BOOL;
PROCEDURE [_APICALL] PostThreadMessageW ( idThread: WD.DWORD; Msg: WD.UINT;
                               wParam: WD.WPARAM;
                               lParam: WD.LPARAM ): WD.BOOL;
(*  !    PostThreadMessage *)

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] PostAppMessageA ( idThread; wMsg; wParam; lParam: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / PostAppMessageA ( idThread; wMsg; wParam; lParam: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  PostAppMessage = PostAppMessageA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] PostAppMessageW ( idThread; wMsg; wParam; lParam: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / PostAppMessageW ( idThread; wMsg; wParam; lParam: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)

(*                                                                     *)
(*  * Special HWND value for use with PostMessage() and SendMessage()  *)
(*                                                                     *)


PROCEDURE [_APICALL] AttachThreadInput ( idAttach: WD.DWORD;
                              idAttachTo: WD.DWORD;
                              fAttach: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] ReplyMessage ( lResult: WD.LRESULT ): WD.BOOL;

PROCEDURE [_APICALL] WaitMessage (  ): WD.BOOL;

PROCEDURE [_APICALL] WaitForInputIdle ( hProcess: WD.HANDLE;
                             dwMilliseconds: WD.DWORD ): WD.DWORD;

PROCEDURE [_APICALL] DefWindowProcA ( hWnd: WD.HWND; Msg: WD.UINT;
                           wParam: WD.WPARAM;
                           lParam: WD.LPARAM ): WD.LRESULT;
PROCEDURE [_APICALL] DefWindowProcW ( hWnd: WD.HWND; Msg: WD.UINT;
                           wParam: WD.WPARAM;
                           lParam: WD.LPARAM ): WD.LRESULT;
(*  !  DefWindowProc *)

PROCEDURE [_APICALL] PostQuitMessage ( nExitCode: LONGINT );

PROCEDURE [_APICALL] CallWindowProcA ( prevWndFunc: WNDPROC; hWnd: WD.HWND;
                            Msg: WD.UINT; wParam: WD.WPARAM;
                            lParam: WD.LPARAM ): WD.LRESULT;
PROCEDURE [_APICALL] CallWindowProcW ( prevWndFunc: WNDPROC; hWnd: WD.HWND;
                            Msg: WD.UINT; wParam: WD.WPARAM;
                            lParam: WD.LPARAM ): WD.LRESULT;
(*  !  CallWindowProc *)

PROCEDURE [_APICALL] InSendMessage (  ): WD.BOOL;

PROCEDURE [_APICALL] GetDoubleClickTime (  ): WD.UINT;

PROCEDURE [_APICALL] SetDoubleClickTime ( arg0: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] RegisterClassA ( VAR STATICTYPED lpWndClass: WNDCLASSA ): WD.ATOM;
PROCEDURE [_APICALL] RegisterClassW ( VAR STATICTYPED lpWndClass: WNDCLASSA ): WD.ATOM;
(*  !  RegisterClass *)

PROCEDURE [_APICALL] UnregisterClassA ( lpClassName: WD.LPCSTR;
                             hInstance: WD.HINSTANCE ): WD.BOOL;
PROCEDURE [_APICALL] UnregisterClassW ( lpClassName: WD.LPCWSTR;
                             hInstance: WD.HINSTANCE ): WD.BOOL;
(*  !  UnregisterClass *)

PROCEDURE [_APICALL] GetClassInfoA ( hInstance: WD.HINSTANCE;
                          lpClassName: WD.LPCSTR;
                          VAR STATICTYPED lpWndClass: WNDCLASSA ): WD.BOOL;
PROCEDURE [_APICALL] GetClassInfoW ( hInstance: WD.HINSTANCE;
                          lpClassName: WD.LPCWSTR;
                          VAR STATICTYPED lpWndClass: WNDCLASSW ): WD.BOOL;
(*  !   GetClassInfo *)

PROCEDURE [_APICALL] RegisterClassExA ( VAR STATICTYPED arg0: WNDCLASSEXA ): WD.ATOM;
PROCEDURE [_APICALL] RegisterClassExW ( VAR STATICTYPED arg0: WNDCLASSEXA ): WD.ATOM;
(*  !  RegisterClassEx  *)

PROCEDURE [_APICALL] GetClassInfoExA ( arg0: WD.HINSTANCE; arg1: WD.LPCSTR;
                            VAR STATICTYPED arg2: WNDCLASSEXA ): WD.BOOL;

PROCEDURE [_APICALL] GetClassInfoExW ( arg0: WD.HINSTANCE; arg1: WD.LPCWSTR;
                            arg2: LPWNDCLASSEXW ): WD.BOOL;
(*  !  GetClassInfoEx *)

PROCEDURE [_APICALL] CreateWindowExA ( dwExStyle: WD.DWORD;
                            lpClassName: WD.LPCSTR;
                            lpWindowName: WD.LPCSTR;
                            dwStyle: WD.DWORD; X: LONGINT; Y: LONGINT;
                            nWidth: LONGINT; nHeight: LONGINT;
                            hWndParent: WD.HWND; hMenu: WD.HMENU;
                            hInstance: WD.HINSTANCE;
                            lpParam: WD.LPVOID ): WD.HWND;
PROCEDURE [_APICALL] CreateWindowExW ( dwExStyle: WD.DWORD;
                            lpClassName: WD.LPCWSTR;
                            lpWindowName: WD.LPCWSTR;
                            dwStyle: WD.DWORD; X: LONGINT; Y: LONGINT;
                            nWidth: LONGINT; nHeight: LONGINT;
                            hWndParent: WD.HWND; hMenu: WD.HMENU;
                            hInstance: WD.HINSTANCE;
                            lpParam: WD.LPVOID ): WD.HWND;
(*  !   CreateWindowEx *)

(*   MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateWindowA ( lpClassName; lpWindowName; dwStyle; x; y; nWidth; nHeight;
                           hWndParent; hMenu; hInstance;
                           lpParam: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CreateWindowA ( lpClassName; lpWindowName; dwStyle; x; y; nWidth;
                              nHeight; hWndParent; hMenu; hInstance;
                              lpParam: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CreateWindow = CreateWindowA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateWindowW ( lpClassName; lpWindowName; dwStyle; x; y; nWidth; nHeight;
                           hWndParent; hMenu; hInstance;
                           lpParam: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CreateWindowW ( lpClassName; lpWindowName; dwStyle; x; y; nWidth;
                              nHeight; hWndParent; hMenu; hInstance;
                              lpParam: ARRAY OF SYSTEM.BYTE );
<* END *>
 end MACROS *)



PROCEDURE [_APICALL] IsWindow ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] IsMenu ( hMenu: WD.HMENU ): WD.BOOL;

PROCEDURE [_APICALL] IsChild ( hWndParent: WD.HWND;
                    hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] DestroyWindow ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] ShowWindow ( hWnd: WD.HWND; nCmdShow: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] ShowWindowAsync ( hWnd: WD.HWND;
                            nCmdShow: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] FlashWindow ( hWnd: WD.HWND;
                        bInvert: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] ShowOwnedPopups ( hWnd: WD.HWND;
                            fShow: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] OpenIcon ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] CloseWindow ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] MoveWindow ( hWnd: WD.HWND; X: LONGINT; Y: LONGINT; nWidth: LONGINT;
                       nHeight: LONGINT; bRepaint: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowPos ( hWnd: WD.HWND; hWndInsertAfter: WD.HWND;
                         X: LONGINT; Y: LONGINT; cx: LONGINT; cy: LONGINT;
                         uFlags: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowPlacement ( hWnd: WD.HWND;
                               VAR STATICTYPED lpwndpl: WINDOWPLACEMENT ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowPlacement ( hWnd: WD.HWND;
                               VAR STATICTYPED lpwndpl: WINDOWPLACEMENT ): WD.BOOL;

PROCEDURE [_APICALL] BeginDeferWindowPos ( nNumWindows: LONGINT ): HDWP;

PROCEDURE [_APICALL] DeferWindowPos ( hWinPosInfo: HDWP; hWnd: WD.HWND;
                           hWndInsertAfter: WD.HWND; x: LONGINT; y: LONGINT;
                           cx: LONGINT; cy: LONGINT; uFlags: WD.UINT ): HDWP;

PROCEDURE [_APICALL] EndDeferWindowPos ( hWinPosInfo: HDWP ): WD.BOOL;

PROCEDURE [_APICALL] IsWindowVisible ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] IsIconic ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] AnyPopup (  ): WD.BOOL;

PROCEDURE [_APICALL] BringWindowToTop ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] IsZoomed ( hWnd: WD.HWND ): WD.BOOL;


(* #include <poppack.h> *)
(*  Resume normal packing  *)

PROCEDURE [_APICALL] CreateDialogParamA ( hInstance: WD.HINSTANCE;
                               lpTemplateName: WD.LPCSTR;
                               hWndParent: WD.HWND; lpDialogFunc: DLGPROC;
                               dwInitParam: WD.LPARAM ): WD.HWND;
PROCEDURE [_APICALL] CreateDialogParamW ( hInstance: WD.HINSTANCE;
                               lpTemplateName: WD.LPCWSTR;
                               hWndParent: WD.HWND; lpDialogFunc: DLGPROC;
                               dwInitParam: WD.LPARAM ): WD.HWND;
(* !  CreateDialogParam *)

PROCEDURE [_APICALL] CreateDialogIndirectParamA ( hInstance: WD.HINSTANCE;
                                       VAR STATICTYPED lpTemplate: DLGTEMPLATEA;
                                       hWndParent: WD.HWND;
                                       lpDialogFunc: DLGPROC;
                                       dwInitParam: WD.LPARAM ): WD.HWND;
PROCEDURE [_APICALL] CreateDialogIndirectParamW ( hInstance: WD.HINSTANCE;
                                       VAR STATICTYPED lpTemplate: DLGTEMPLATEW;
                                       hWndParent: WD.HWND;
                                       lpDialogFunc: DLGPROC;
                                       dwInitParam: WD.LPARAM ): WD.HWND;
(*  !   CreateDialogIndirectParam *)

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateDialogA ( hInstance; lpName; hWndParent;
                           lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CreateDialogA ( hInstance; lpName; hWndParent;
                              lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CreateDialog = CreateDialogA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateDialogW ( hInstance; lpName; hWndParent;
                           lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CreateDialogW ( hInstance; lpName; hWndParent;
                              lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateDialogIndirectA ( hInstance; lpTemplate; hWndParent;
                                   lpDialogFunc: ARRAY OF SYSTEM.BYTE );
 <* ELSE *>
PROCEDURE [_APICALL]  / CreateDialogIndirectA ( hInstance; lpTemplate; hWndParent;
                                      lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  CreateDialogIndirect = CreateDialogIndirectA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CreateDialogIndirectW ( hInstance; lpTemplate; hWndParent;
                                   lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CreateDialogIndirectW ( hInstance; lpTemplate; hWndParent;
                                      lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)


PROCEDURE [_APICALL] DialogBoxParamA ( hInstance: WD.HINSTANCE;
                            lpTemplateName: WD.LPCSTR;
                            hWndParent: WD.HWND; lpDialogFunc: DLGPROC;
                            dwInitParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] DialogBoxParamW ( hInstance: WD.HINSTANCE;
                            lpTemplateName: WD.LPCWSTR;
                            hWndParent: WD.HWND; lpDialogFunc: DLGPROC;
                            dwInitParam: WD.LPARAM ): LONGINT;
(*  !   DialogBoxParam *)

PROCEDURE [_APICALL] DialogBoxIndirectParamA ( hInstance: WD.HINSTANCE;
                                    VAR STATICTYPED hDialogTemplate: DLGTEMPLATEA;
                                    hWndParent: WD.HWND;
                                    lpDialogFunc: DLGPROC;
                                    dwInitParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] DialogBoxIndirectParamW ( hInstance: WD.HINSTANCE;
                                    VAR STATICTYPED hDialogTemplate: DLGTEMPLATEW;
                                    hWndParent: WD.HWND;
                                    lpDialogFunc: DLGPROC;
                                    dwInitParam: WD.LPARAM ): LONGINT;
(*  !   DialogBoxIndirectParam *)

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DialogBoxA ( hInstance; lpTemplate; hWndParent;
                        lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DialogBoxA ( hInstance; lpTemplate; hWndParent;
                           lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  DialogBox = DialogBoxA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DialogBoxW ( hInstance; lpTemplate; hWndParent;
                        lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DialogBoxW ( hInstance; lpTemplate; hWndParent;
                           lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DialogBoxIndirectA ( hInstance; lpTemplate; hWndParent;
                                lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DialogBoxIndirectA ( hInstance; lpTemplate; hWndParent;
                                   lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
CONST 
  DialogBoxIndirect = DialogBoxIndirectA;
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DialogBoxIndirectW ( hInstance; lpTemplate; hWndParent;
                                lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DialogBoxIndirectW ( hInstance; lpTemplate; hWndParent;
                                   lpDialogFunc: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)

PROCEDURE [_APICALL] EndDialog ( hDlg: WD.HWND; nResult: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetDlgItem ( hDlg: WD.HWND; nIDDlgItem: LONGINT ): WD.HWND;

PROCEDURE [_APICALL] SetDlgItemInt ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                          uValue: WD.UINT;
                          bSigned: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetDlgItemInt ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                          lpTranslated: WD.PBOOL;
                          bSigned: WD.BOOL ): WD.UINT;

PROCEDURE [_APICALL] SetDlgItemTextA ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                            lpString: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetDlgItemTextW ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                            lpString: WD.LPCWSTR ): WD.BOOL;
(*  !  SetDlgItemText *)

PROCEDURE [_APICALL] GetDlgItemTextA ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                            lpString: WD.LPSTR;
                            nMaxCount: LONGINT ): WD.UINT;

PROCEDURE [_APICALL] GetDlgItemTextW ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                            lpString: WD.LPWSTR;
                            nMaxCount: LONGINT ): WD.UINT;
(*  !  GetDlgItemText *)

PROCEDURE [_APICALL] CheckDlgButton ( hDlg: WD.HWND; nIDButton: LONGINT;
                           uCheck: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] CheckRadioButton ( hDlg: WD.HWND; nIDFirstButton: LONGINT;
                             nIDLastButton: LONGINT;
                             nIDCheckButton: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] IsDlgButtonChecked ( hDlg: WD.HWND;
                               nIDButton: LONGINT ): WD.UINT;

PROCEDURE [_APICALL] SendDlgItemMessageA ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                                Msg: WD.UINT; wParam: WD.WPARAM;
                                lParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] SendDlgItemMessageW ( hDlg: WD.HWND; nIDDlgItem: LONGINT;
                                Msg: WD.UINT; wParam: WD.WPARAM;
                                lParam: WD.LPARAM ): LONGINT;
(*  !  SendDlgItemMessage *)

PROCEDURE [_APICALL] GetNextDlgGroupItem ( hDlg: WD.HWND; hCtl: WD.HWND;
                                bPrevious: WD.BOOL ): WD.HWND;

PROCEDURE [_APICALL] GetNextDlgTabItem ( hDlg: WD.HWND; hCtl: WD.HWND;
                              bPrevious: WD.BOOL ): WD.HWND;

PROCEDURE [_APICALL] GetDlgCtrlID ( hWnd: WD.HWND ): LONGINT;

PROCEDURE [_APICALL] GetDialogBaseUnits (  ): LONGINT;

PROCEDURE [_APICALL] DefDlgProcA ( hDlg: WD.HWND; Msg: WD.UINT;
                        wParam: WD.WPARAM;
                        lParam: WD.LPARAM ): WD.LRESULT;

PROCEDURE [_APICALL] DefDlgProcW ( hDlg: WD.HWND; Msg: WD.UINT;
                        wParam: WD.WPARAM;
                        lParam: WD.LPARAM ): WD.LRESULT;
(*  ! DefDlgProc *)

(*                                                           *)
(*  * Window extra byted needed for private dialog classes.  *)
(*                                                           *)


PROCEDURE [_APICALL] CallMsgFilterA ( VAR STATICTYPED lpMsg: MSG; nCode: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] CallMsgFilterW ( VAR STATICTYPED lpMsg: MSG; nCode: LONGINT ): WD.BOOL;
(*  !  CallMsgFilter *)

(*                                 *)
(*  * Clipboard Manager Functions  *)
(*                                 *)

PROCEDURE [_APICALL] OpenClipboard ( hWndNewOwner: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] CloseClipboard (  ): WD.BOOL;

PROCEDURE [_APICALL] GetClipboardOwner (  ): WD.HWND;

PROCEDURE [_APICALL] SetClipboardViewer ( hWndNewViewer: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] GetClipboardViewer (  ): WD.HWND;

PROCEDURE [_APICALL] ChangeClipboardChain ( hWndRemove: WD.HWND;
                                 hWndNewNext: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] SetClipboardData ( uFormat: WD.UINT;
                             hMem: WD.HANDLE ): WD.HANDLE;

PROCEDURE [_APICALL] GetClipboardData ( uFormat: WD.UINT ): WD.HANDLE;

PROCEDURE [_APICALL] RegisterClipboardFormatA ( lpszFormat: WD.LPCSTR ): WD.UINT;
PROCEDURE [_APICALL] RegisterClipboardFormatW ( lpszFormat: WD.LPCWSTR ): WD.UINT;
(*  !  RegisterClipboardFormat *)

PROCEDURE [_APICALL] CountClipboardFormats (  ): LONGINT;

PROCEDURE [_APICALL] EnumClipboardFormats ( format: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] GetClipboardFormatNameA ( format: WD.UINT;
                                    lpszFormatName: WD.LPSTR;
                                    cchMaxCount: LONGINT ): LONGINT;
PROCEDURE [_APICALL] GetClipboardFormatNameW ( format: WD.UINT;
                                    lpszFormatName: WD.LPWSTR;
                                    cchMaxCount: LONGINT ): LONGINT;
(*  !   GetClipboardFormatName *)

PROCEDURE [_APICALL] EmptyClipboard (  ): WD.BOOL;

PROCEDURE [_APICALL] IsClipboardFormatAvailable ( format: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetPriorityClipboardFormat ( paFormatPriorityList: WD.PUINT;
                                       cFormats: LONGINT ): LONGINT;

PROCEDURE [_APICALL] GetOpenClipboardWindow (  ): WD.HWND;

(*                                    *)
(*  * Character Translation Routines  *)
(*                                    *)

PROCEDURE [_APICALL] CharToOemA ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] CharToOemW ( lpszSrc: WD.LPCWSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
(*  !  CharToOem *)

PROCEDURE [_APICALL] AnsiToOemA ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] AnsiToOemW ( lpszSrc: WD.LPCWSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
(*  !  AnsiToOem *)

PROCEDURE [_APICALL] OemToCharA ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] OemToCharW ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPWSTR ): WD.BOOL;
(*  !  OemToChar *)

PROCEDURE [_APICALL] OemToAnsiA ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPSTR ): WD.BOOL;
PROCEDURE [_APICALL] OemToAnsiW ( lpszSrc: WD.LPCSTR;
                       lpszDst: WD.LPWSTR ): WD.BOOL;
(*  !   OemToAnsi *)

PROCEDURE [_APICALL] CharToOemBuffA ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] CharToOemBuffW ( lpszSrc: WD.LPCWSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
(*  !   CharToOemBuff *)

PROCEDURE [_APICALL] AnsiToOemBuffA ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] AnsiToOemBuffW ( lpszSrc: WD.LPCWSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
(*  !  AnsiToOemBuff *)

PROCEDURE [_APICALL] OemToCharBuffA ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] OemToCharBuffW ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPWSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
(*  !   OemToCharBuff *)

PROCEDURE [_APICALL] OemToAnsiBuffA ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] OemToAnsiBuffW ( lpszSrc: WD.LPCSTR; lpszDst: WD.LPWSTR;
                           cchDstLength: WD.DWORD ): WD.BOOL;
(*  !   OemToAnsiBuff *)

PROCEDURE [_APICALL] CharUpperA ( lpsz: WD.LPSTR ): WD.LPSTR;
PROCEDURE [_APICALL] CharUpperW ( lpsz: WD.LPWSTR ): WD.LPWSTR;
(*  !  CharUpper *)

PROCEDURE [_APICALL] AnsiUpperA ( lpsz: WD.LPSTR ): WD.LPSTR;
PROCEDURE [_APICALL] AnsiUpperW ( lpsz: WD.LPWSTR ): WD.LPWSTR;
(*  !  AnsiUpper *)

PROCEDURE [_APICALL] CharUpperBuffA ( lpsz: WD.LPSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] CharUpperBuffW ( lpsz: WD.LPWSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
(*  ! CharUpperBuff *)
PROCEDURE [_APICALL] AnsiUpperBuffA ( lpsz: WD.LPSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] AnsiUpperBuffW ( lpsz: WD.LPWSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
(*  !   AnsiUpperBuff *)

PROCEDURE [_APICALL] CharLowerA ( lpsz: WD.LPSTR ): WD.LPSTR;
PROCEDURE [_APICALL] CharLowerW ( lpsz: WD.LPWSTR ): WD.LPWSTR;
(*  !  CharLower *)

PROCEDURE [_APICALL] AnsiLowerA ( lpsz: WD.LPSTR ): WD.LPSTR;
PROCEDURE [_APICALL] AnsiLowerW ( lpsz: WD.LPWSTR ): WD.LPWSTR;
(*  !  AnsiLower *)

PROCEDURE [_APICALL] CharLowerBuffA ( lpsz: WD.LPSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] CharLowerBuffW ( lpsz: WD.LPWSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
(*  !  CharLowerBuff *)

PROCEDURE [_APICALL] AnsiLowerBuffA ( lpsz: WD.LPSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
PROCEDURE [_APICALL] AnsiLowerBuffW ( lpsz: WD.LPWSTR;
                           cchLength: WD.DWORD ): WD.DWORD;
(*  !  AnsiLowerBuff *)

PROCEDURE [_APICALL] CharNextA ( lpsz: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] CharNextW ( lpsz: WD.LPCWSTR ): WD.LPWSTR;
(*  !   CharNext *)

PROCEDURE [_APICALL] AnsiNextA ( lpsz: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] AnsiNextW ( lpsz: WD.LPCWSTR ): WD.LPWSTR;
(*  !   AnsiNext *)

PROCEDURE [_APICALL] CharPrevA ( lpszStart: WD.LPCSTR;
                      lpszCurrent: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] CharPrevW ( lpszStart: WD.LPCWSTR;
                      lpszCurrent: WD.LPCWSTR ): WD.LPWSTR;
(*  !   CharPrev *)

PROCEDURE [_APICALL] AnsiPrevA ( lpszStart: WD.LPCSTR;
                      lpszCurrent: WD.LPCSTR ): WD.LPSTR;
PROCEDURE [_APICALL] AnsiPrevW ( lpszStart: WD.LPCWSTR;
                      lpszCurrent: WD.LPCWSTR ): WD.LPWSTR;
(*  !  AnsiPrev *)

PROCEDURE [_APICALL] CharNextExA ( CodePage: WD.WORD; lpCurrentChar: WD.LPCSTR;
                        dwFlags: WD.DWORD ): WD.LPSTR;

PROCEDURE [_APICALL] CharPrevExA ( CodePage: WD.WORD; lpStart: WD.LPCSTR;
                        lpCurrentChar: WD.LPCSTR;
                        dwFlags: WD.DWORD ): WD.LPSTR;

(*                                                              *)
(*  * Compatibility defines for character translation routines  *)
(*                                                              *)
(*                                 *)
(*  * Language dependent Routines  *)
(*                                 *)

PROCEDURE [_APICALL] IsCharAlphaA ( ch: CHAR ): WD.BOOL;
PROCEDURE [_APICALL] IsCharAlphaW ( ch: WD.WCHAR ): WD.BOOL;
(*  !  IsCharAlpha *)

PROCEDURE [_APICALL] IsCharAlphaNumericA ( ch: CHAR ): WD.BOOL;
PROCEDURE [_APICALL] IsCharAlphaNumericW ( ch: WD.WCHAR ): WD.BOOL;
(*  !  IsCharAlphaNumeric *)

PROCEDURE [_APICALL] IsCharUpperA ( ch: CHAR ): WD.BOOL;
PROCEDURE [_APICALL] IsCharUpperW ( ch: WD.WCHAR ): WD.BOOL;
(*  !  IsCharUpper *)

PROCEDURE [_APICALL] IsCharLowerA ( ch: CHAR ): WD.BOOL;
PROCEDURE [_APICALL] IsCharLowerW ( ch: WD.WCHAR ): WD.BOOL;
(*  !   IsCharLower *)

PROCEDURE [_APICALL] SetFocus ( hWnd: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] GetActiveWindow (  ): WD.HWND;

PROCEDURE [_APICALL] GetFocus (  ): WD.HWND;

PROCEDURE [_APICALL] GetKBCodePage (  ): WD.UINT;

PROCEDURE [_APICALL] GetKeyState ( nVirtKey: LONGINT ): INTEGER;

PROCEDURE [_APICALL] GetAsyncKeyState ( vKey: LONGINT ): INTEGER;

PROCEDURE [_APICALL] GetKeyboardState ( lpKeyState: WD.PBYTE ): WD.BOOL;

PROCEDURE [_APICALL] SetKeyboardState ( lpKeyState: WD.LPBYTE ): WD.BOOL;

PROCEDURE [_APICALL] GetKeyNameTextA ( lParam: LONGINT; lpString: WD.LPSTR;
                            nSize: LONGINT ): LONGINT;
PROCEDURE [_APICALL] GetKeyNameTextW ( lParam: LONGINT; lpString: WD.LPWSTR;
                            nSize: LONGINT ): LONGINT;
(*  !   GetKeyNameText *)

PROCEDURE [_APICALL] GetKeyboardType ( nTypeFlag: LONGINT ): LONGINT;

PROCEDURE [_APICALL] ToAscii ( uVirtKey: WD.UINT; uScanCode: WD.UINT;
                    VAR lpKeyState: WD.BYTE; lpChar: WD.LPWORD;
                    uFlags: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] ToAsciiEx ( uVirtKey: WD.UINT; uScanCode: WD.UINT;
                      VAR lpKeyState: WD.BYTE; lpChar: WD.LPWORD;
                      uFlags: WD.UINT; dwhkl: WD.HKL ): LONGINT;

PROCEDURE [_APICALL] ToUnicode ( wVirtKey: WD.UINT; wScanCode: WD.UINT;
                      VAR lpKeyState: WD.BYTE; pwszBuff: WD.LPWSTR;
                      cchBuff: LONGINT; wFlags: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] OemKeyScan ( wOemChar: WD.WORD ): WD.DWORD;

PROCEDURE [_APICALL] VkKeyScanA ( ch: CHAR ): INTEGER;
PROCEDURE [_APICALL] VkKeyScanW ( ch: WD.WCHAR ): INTEGER;
(*  !  VkKeyScan *)

PROCEDURE [_APICALL] VkKeyScanExA ( ch: CHAR; dwhkl: WD.HKL ): INTEGER;
PROCEDURE [_APICALL] VkKeyScanExW ( ch: WD.WCHAR; dwhkl: WD.HKL ): INTEGER;
(*  !  VkKeyScanEx *)

PROCEDURE [_APICALL] keybd_event ( bVk: WD.BYTE; bScan: WD.BYTE;
                        dwFlags: WD.DWORD; dwExtraInfo: WD.DWORD );

PROCEDURE [_APICALL] mouse_event ( dwFlags: WD.DWORD; dx: WD.DWORD;
                        dy: WD.DWORD; cButtons: WD.DWORD;
                        dwExtraInfo: WD.DWORD );

PROCEDURE [_APICALL] MapVirtualKeyA ( uCode: WD.UINT;
                           uMapType: WD.UINT ): WD.UINT;
PROCEDURE [_APICALL] MapVirtualKeyW ( uCode: WD.UINT;
                           uMapType: WD.UINT ): WD.UINT;
(*  !  MapVirtualKey *)

PROCEDURE [_APICALL] MapVirtualKeyExA ( uCode: WD.UINT; uMapType: WD.UINT;
                             dwhkl: WD.HKL ): WD.UINT;
PROCEDURE [_APICALL] MapVirtualKeyExW ( uCode: WD.UINT; uMapType: WD.UINT;
                             dwhkl: WD.HKL ): WD.UINT;
(*  !   MapVirtualKeyEx *)

PROCEDURE [_APICALL] GetInputState (  ): WD.BOOL;

PROCEDURE [_APICALL] GetQueueStatus ( flags: WD.UINT ): WD.DWORD;

PROCEDURE [_APICALL] GetCapture (  ): WD.HWND;

PROCEDURE [_APICALL] SetCapture ( hWnd: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] ReleaseCapture (  ): WD.BOOL;

PROCEDURE [_APICALL] MsgWaitForMultipleObjects ( nCount: WD.DWORD;
                                      VAR pHandles: WD.HANDLE;
                                      fWaitAll: WD.BOOL;
                                      dwMilliseconds: WD.DWORD;
                                      dwWakeMask: WD.DWORD ): WD.DWORD;


(*                       *)
(*  * Windows Functions  *)
(*                       *)

PROCEDURE [_APICALL] SetTimer ( hWnd: WD.HWND; nIDEvent: WD.UINT;
                     uElapse: WD.UINT;
                     lpTimerFunc: TIMERPROC ): WD.UINT;

PROCEDURE [_APICALL] KillTimer ( hWnd: WD.HWND;
                      uIDEvent: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] IsWindowUnicode ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] EnableWindow ( hWnd: WD.HWND;
                         bEnable: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] IsWindowEnabled ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] LoadAcceleratorsA ( hInstance: WD.HINSTANCE;
                              lpTableName: WD.LPCSTR ): WD.HACCEL;
PROCEDURE [_APICALL] LoadAcceleratorsW ( hInstance: WD.HINSTANCE;
                              lpTableName: WD.LPCWSTR ): WD.HACCEL;
(*  !   LoadAccelerators *)

PROCEDURE [_APICALL] CreateAcceleratorTableA ( VAR STATICTYPED arg0: ACCEL; 
                        arg1: LONGINT ): WD.HACCEL;
PROCEDURE [_APICALL] CreateAcceleratorTableW ( VAR STATICTYPED arg0: ACCEL;
                        arg1: LONGINT ): WD.HACCEL;
(*  !    CreateAcceleratorTable *)

PROCEDURE [_APICALL] DestroyAcceleratorTable ( hAccel: WD.HACCEL ): WD.BOOL;

PROCEDURE [_APICALL] CopyAcceleratorTableA ( hAccelSrc: WD.HACCEL; 
                  VAR STATICTYPED lpAccelDst: ACCEL;
                                  cAccelEntries: LONGINT ): LONGINT;
PROCEDURE [_APICALL] CopyAcceleratorTableW ( hAccelSrc: WD.HACCEL; 
                  VAR STATICTYPED lpAccelDst: ACCEL;
                                  cAccelEntries: LONGINT ): LONGINT;
(*  !  CopyAcceleratorTable *)

PROCEDURE [_APICALL] TranslateAcceleratorA ( hWnd: WD.HWND; hAccTable: WD.HACCEL;
                                  VAR STATICTYPED lpMsg: MSG ): LONGINT;
PROCEDURE [_APICALL] TranslateAcceleratorW ( hWnd: WD.HWND; hAccTable: WD.HACCEL;
                                  VAR STATICTYPED lpMsg: MSG ): LONGINT;
(*  !  TranslateAccelerator *)


PROCEDURE [_APICALL] GetSystemMetrics ( nIndex: LONGINT ): LONGINT;

PROCEDURE [_APICALL] LoadMenuA ( hInstance: WD.HINSTANCE;
                      lpMenuName: WD.LPCSTR ): WD.HMENU;
PROCEDURE [_APICALL] LoadMenuW ( hInstance: WD.HINSTANCE;
                      lpMenuName: WD.LPCWSTR ): WD.HMENU;
(*  !   LoadMenu *)

PROCEDURE [_APICALL] LoadMenuIndirectA ( VAR menuTemplate: MENUTEMPLATEA ): WD.HMENU;
PROCEDURE [_APICALL] LoadMenuIndirectW ( VAR menuTemplate: MENUTEMPLATEW ): WD.HMENU;
(*  !    LoadMenuIndirect *)

PROCEDURE [_APICALL] GetMenu ( hWnd: WD.HWND ): WD.HMENU;

PROCEDURE [_APICALL] SetMenu ( hWnd: WD.HWND; hMenu: WD.HMENU ): WD.BOOL;

PROCEDURE [_APICALL] ChangeMenuA ( hMenu: WD.HMENU; cmd: WD.UINT;
                        lpszNewItem: WD.LPCSTR; cmdInsert: WD.UINT;
                        flags: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] ChangeMenuW ( hMenu: WD.HMENU; cmd: WD.UINT;
                        lpszNewItem: WD.LPCWSTR; cmdInsert: WD.UINT;
                        flags: WD.UINT ): WD.BOOL;
(*  !   ChangeMenu *)

PROCEDURE [_APICALL] HiliteMenuItem ( hWnd: WD.HWND; hMenu: WD.HMENU;
                           uIDHiliteItem: WD.UINT;
                           uHilite: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetMenuStringA ( hMenu: WD.HMENU; uIDItem: WD.UINT;
                           lpString: WD.LPSTR; nMaxCount: LONGINT;
                           uFlag: WD.UINT ): LONGINT;
PROCEDURE [_APICALL] GetMenuStringW ( hMenu: WD.HMENU; uIDItem: WD.UINT;
                           lpString: WD.LPWSTR; nMaxCount: LONGINT;
                           uFlag: WD.UINT ): LONGINT;
(*  !  GetMenuString *)

PROCEDURE [_APICALL] GetMenuState ( hMenu: WD.HMENU; uId: WD.UINT;
                         uFlags: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] DrawMenuBar ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] GetSystemMenu ( hWnd: WD.HWND;
                          bRevert: WD.BOOL ): WD.HMENU;

PROCEDURE [_APICALL] CreateMenu (  ): WD.HMENU;

PROCEDURE [_APICALL] CreatePopupMenu (  ): WD.HMENU;

PROCEDURE [_APICALL] DestroyMenu ( hMenu: WD.HMENU ): WD.BOOL;

PROCEDURE [_APICALL] CheckMenuItem ( hMenu: WD.HMENU; uIDCheckItem: WD.UINT;
                          uCheck: WD.UINT ): WD.DWORD;

PROCEDURE [_APICALL] EnableMenuItem ( hMenu: WD.HMENU; uIDEnableItem: WD.UINT;
                           uEnable: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetSubMenu ( hMenu: WD.HMENU; nPos: LONGINT ): WD.HMENU;

PROCEDURE [_APICALL] GetMenuItemID ( hMenu: WD.HMENU; nPos: LONGINT ): WD.UINT;

PROCEDURE [_APICALL] GetMenuItemCount ( hMenu: WD.HMENU ): LONGINT;

PROCEDURE [_APICALL] InsertMenuA ( hMenu: WD.HMENU; uPosition: WD.UINT;
                        uFlags: WD.UINT; uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] InsertMenuW ( hMenu: WD.HMENU; uPosition: WD.UINT;
                        uFlags: WD.UINT; uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCWSTR ): WD.BOOL;
(*  !   InsertMenu *)

PROCEDURE [_APICALL] AppendMenuA ( hMenu: WD.HMENU; uFlags: WD.UINT;
                        uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] AppendMenuW ( hMenu: WD.HMENU; uFlags: WD.UINT;
                        uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCWSTR ): WD.BOOL;
(*  !   AppendMenu *)

PROCEDURE [_APICALL] ModifyMenuA ( hMnu: WD.HMENU; uPosition: WD.UINT;
                        uFlags: WD.UINT; uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] ModifyMenuW ( hMnu: WD.HMENU; uPosition: WD.UINT;
                        uFlags: WD.UINT; uIDNewItem: WD.UINT;
                        lpNewItem: WD.LPCWSTR ): WD.BOOL;
(*  !   ModifyMenu *)

PROCEDURE [_APICALL] RemoveMenu ( hMenu: WD.HMENU; uPosition: WD.UINT;
                       uFlags: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DeleteMenu ( hMenu: WD.HMENU; uPosition: WD.UINT;
                       uFlags: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] SetMenuItemBitmaps ( hMenu: WD.HMENU; uPosition: WD.UINT;
                               uFlags: WD.UINT;
                               hBitmapUnchecked: WD.HBITMAP;
                               hBitmapChecked: WD.HBITMAP ): WD.BOOL;

PROCEDURE [_APICALL] GetMenuCheckMarkDimensions (  ): LONGINT;

PROCEDURE [_APICALL] TrackPopupMenu ( hMenu: WD.HMENU; uFlags: WD.UINT;
                           x: LONGINT; y: LONGINT; nReserved: LONGINT;
                           hWnd: WD.HWND;
                           lpRect: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] TrackPopupMenuEx ( arg0: WD.HMENU; arg1: WD.UINT;
                             arg2: LONGINT; arg3: LONGINT; arg4: WD.HWND;
                             VAR STATICTYPED arg5: TPMPARAMS ): WD.BOOL;
  
PROCEDURE [_APICALL] InsertMenuItemA ( arg0: WD.HMENU; arg1: WD.UINT;
                            arg2: WD.BOOL;
                            VAR STATICTYPED arg3: MENUITEMINFOA ): WD.BOOL;
PROCEDURE [_APICALL] InsertMenuItemW ( arg0: WD.HMENU; arg1: WD.UINT;
                            arg2: WD.BOOL;
                            VAR STATICTYPED arg3: MENUITEMINFOW ): WD.BOOL;
(*  !  InsertMenuItem *)

PROCEDURE [_APICALL] GetMenuItemInfoA ( arg0: WD.HMENU; arg1: WD.UINT;
                             arg2: WD.BOOL;
                             VAR STATICTYPED arg3: MENUITEMINFOA ): WD.BOOL;

PROCEDURE [_APICALL] GetMenuItemInfoW ( arg0: WD.HMENU; arg1: WD.UINT;
                             arg2: WD.BOOL;
                             VAR STATICTYPED arg3: MENUITEMINFOW ): WD.BOOL;
(*  !  GetMenuItemInfo *)

PROCEDURE [_APICALL] SetMenuItemInfoA ( arg0: WD.HMENU; arg1: WD.UINT;
                             arg2: WD.BOOL;
                             VAR STATICTYPED arg3: MENUITEMINFOA ): WD.BOOL;
PROCEDURE [_APICALL] SetMenuItemInfoW ( arg0: WD.HMENU; arg1: WD.UINT;
                             arg2: WD.BOOL;
                             VAR STATICTYPED arg3: MENUITEMINFOW ): WD.BOOL;
(*  !   SetMenuItemInfo *)


PROCEDURE [_APICALL] GetMenuDefaultItem ( hMenu: WD.HMENU; fByPos: WD.UINT;
                               gmdiFlags: WD.UINT ): WD.UINT;

PROCEDURE [_APICALL] SetMenuDefaultItem ( hMenu: WD.HMENU; uItem: WD.UINT;
                               fByPos: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] GetMenuItemRect ( hWnd: WD.HWND; hMenu: WD.HMENU;
                            uItem: WD.UINT;
                            lprcItem: WD.LPRECT ): WD.BOOL;

PROCEDURE [_APICALL] MenuItemFromPoint ( hWnd: WD.HWND; hMenu: WD.HMENU;
                              ptScreen: WD.POINT ): LONGINT;

PROCEDURE [_APICALL] DragObject ( arg0: WD.HWND; arg1: WD.HWND;
                       arg2: WD.UINT; arg3: WD.DWORD;
                       arg4: WD.HCURSOR ): WD.DWORD;

PROCEDURE [_APICALL] DragDetect ( arg0: WD.HWND;
                       arg1: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] DrawIcon ( hDC: WD.HDC; X: LONGINT; Y: LONGINT;
                     hIcon: WD.HICON ): WD.BOOL;

PROCEDURE [_APICALL] DrawTextA ( hDC: WD.HDC; lpString: WD.LPCSTR;
                      nCount: LONGINT; VAR STATICTYPED lpRect: WD.RECT;
                      uFormat: WD.UINT ): LONGINT;
PROCEDURE [_APICALL] DrawTextW ( hDC: WD.HDC; lpString: WD.LPCWSTR;
                      nCount: LONGINT; VAR STATICTYPED lpRect: WD.RECT;
                      uFormat: WD.UINT ): LONGINT;
(*  !  DrawText *)

PROCEDURE [_APICALL] DrawTextExA ( arg0: WD.HDC; arg1: WD.LPSTR; arg2: LONGINT;
                        VAR STATICTYPED arg3: WD.RECT; arg4: WD.UINT;
                        VAR STATICTYPED arg5: DRAWTEXTPARAMS ): LONGINT;
PROCEDURE [_APICALL] DrawTextExW ( arg0: WD.HDC; arg1: WD.LPWSTR; arg2: LONGINT;
                        VAR STATICTYPED arg3: WD.RECT; arg4: WD.UINT;
                        VAR STATICTYPED arg5: DRAWTEXTPARAMS ): LONGINT;
(*  !   DrawTextEx *)

PROCEDURE [_APICALL] GrayStringA ( hDC: WD.HDC; hBrush: WD.HBRUSH;
                        lpOutputFunc: GRAYSTRINGPROC; lpData: WD.LPARAM;
                        nCount: LONGINT; X: LONGINT; Y: LONGINT; nWidth: LONGINT;
                        nHeight: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] GrayStringW ( hDC: WD.HDC; hBrush: WD.HBRUSH;
                        lpOutputFunc: GRAYSTRINGPROC; lpData: WD.LPARAM;
                        nCount: LONGINT; X: LONGINT; Y: LONGINT; nWidth: LONGINT;
                        nHeight: LONGINT ): WD.BOOL;
(*  !   GrayString *)

PROCEDURE [_APICALL] DrawStateA ( arg0: WD.HDC; arg1: WD.HBRUSH;
                       arg2: DRAWSTATEPROC; arg3: WD.LPARAM;
                       arg4: WD.WPARAM; arg5: LONGINT; arg6: LONGINT;
                       arg7: LONGINT; arg8: LONGINT;
                       arg9: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] DrawStateW ( arg0: WD.HDC; arg1: WD.HBRUSH;
                       arg2: DRAWSTATEPROC; arg3: WD.LPARAM;
                       arg4: WD.WPARAM; arg5: LONGINT; arg6: LONGINT;
                       arg7: LONGINT; arg8: LONGINT;
                       arg9: WD.UINT ): WD.BOOL;
(*  !  DrawState *)

PROCEDURE [_APICALL] TabbedTextOutA ( hDC: WD.HDC; X: LONGINT; Y: LONGINT;
                           lpString: WD.LPCSTR; nCount: LONGINT;
                           nTabPositions: LONGINT;
                           VAR lpnTabStopPositions: LONGINT (*WD.LPINT*);
                           nTabOrigin: LONGINT ): LONGINT;
PROCEDURE [_APICALL] TabbedTextOutW ( hDC: WD.HDC; X: LONGINT; Y: LONGINT;
                           lpString: WD.LPCWSTR; nCount: LONGINT;
                           nTabPositions: LONGINT;
                           VAR lpnTabStopPositions: LONGINT  (*WD.LPINT*);
                           nTabOrigin: LONGINT ): LONGINT;
(*  !  TabbedTextOut *)

PROCEDURE [_APICALL] GetTabbedTextExtentA ( hDC: WD.HDC; lpString: WD.LPCSTR;
                                 nCount: LONGINT; nTabPositions: LONGINT;
                                 VAR lpnTabStopPositions: LONGINT (*WD.LPINT*) ): WD.DWORD;
PROCEDURE [_APICALL] GetTabbedTextExtentW ( hDC: WD.HDC; lpString: WD.LPCWSTR;
                                 nCount: LONGINT; nTabPositions: LONGINT;
                                 VAR lpnTabStopPositions: LONGINT (*WD.LPINT*) ): WD.DWORD;
(*  !   GetTabbedTextExtent *)

PROCEDURE [_APICALL] UpdateWindow ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] SetActiveWindow ( hWnd: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] GetForegroundWindow (  ): WD.HWND;

PROCEDURE [_APICALL] PaintDesktop ( hdc: WD.HDC ): WD.BOOL;

PROCEDURE [_APICALL] SetForegroundWindow ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] WindowFromDC ( hDC: WD.HDC ): WD.HWND;

PROCEDURE [_APICALL] GetDC ( hWnd: WD.HWND ): WD.HDC;

PROCEDURE [_APICALL] GetDCEx ( hWnd: WD.HWND; hrgnClip: WD.HRGN;
                    flags: WD.DWORD ): WD.HDC;

PROCEDURE [_APICALL] GetWindowDC ( hWnd: WD.HWND ): WD.HDC;

PROCEDURE [_APICALL] ReleaseDC ( hWnd: WD.HWND; hDC: WD.HDC ): LONGINT;

PROCEDURE [_APICALL] BeginPaint ( hWnd: WD.HWND;
                       VAR STATICTYPED lpPaint: PAINTSTRUCT ): WD.HDC;

PROCEDURE [_APICALL] EndPaint ( hWnd: WD.HWND; VAR STATICTYPED lpPaint: PAINTSTRUCT ): WD.BOOL;

PROCEDURE [_APICALL] GetUpdateRect ( hWnd: WD.HWND; VAR STATICTYPED lpRect: WD.RECT;
                          bErase: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetUpdateRgn ( hWnd: WD.HWND; hRgn: WD.HRGN;
                         bErase: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] SetWindowRgn ( hWnd: WD.HWND; hRgn: WD.HRGN;
                         bRedraw: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] GetWindowRgn ( hWnd: WD.HWND; hRgn: WD.HRGN ): LONGINT;

PROCEDURE [_APICALL] ExcludeUpdateRgn ( hDC: WD.HDC; hWnd: WD.HWND ): LONGINT;

PROCEDURE [_APICALL] InvalidateRect ( hWnd: WD.HWND; VAR STATICTYPED rect:WD.RECT;
                           bErase: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] ValidateRect ( hWnd: WD.HWND;
                          lpRect: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] InvalidateRgn ( hWnd: WD.HWND; hRgn: WD.HRGN;
                          bErase: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] ValidateRgn ( hWnd: WD.HWND;
                        hRgn: WD.HRGN ): WD.BOOL;

PROCEDURE [_APICALL] RedrawWindow ( hWnd: WD.HWND; VAR STATICTYPED lprcUpdate: WD.RECT;
                         hrgnUpdate: WD.HRGN;
                         flags: WD.UINT ): WD.BOOL;

(*                          *)
(*  * LockWindowUpdate API  *)
(*                          *)

PROCEDURE [_APICALL] LockWindowUpdate ( hWndLock: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] ScrollWindow ( hWnd: WD.HWND; XAmount: LONGINT; YAmount: LONGINT;
                         VAR STATICTYPED lpRect: WD.RECT;
                         VAR STATICTYPED lpClipRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] ScrollDC ( hDC: WD.HDC; dx: LONGINT; dy: LONGINT;
                     VAR STATICTYPED lprcScroll: WD.RECT; VAR STATICTYPED lprcClip: WD.RECT;
                     hrgnUpdate: WD.HRGN;
                     lprcUpdate: WD.LPRECT ): WD.BOOL;

PROCEDURE [_APICALL] ScrollWindowEx ( hWnd: WD.HWND; dx: LONGINT; dy: LONGINT;
                           VAR STATICTYPED prcScroll: WD.RECT; VAR STATICTYPED prcClip: WD.RECT;
                           hrgnUpdate: WD.HRGN; VAR STATICTYPED prcUpdate: WD.RECT;
                           flags: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] SetScrollPos ( hWnd: WD.HWND; nBar: LONGINT; nPos: LONGINT;
                         bRedraw: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] GetScrollPos ( hWnd: WD.HWND; nBar: LONGINT ): LONGINT;

PROCEDURE [_APICALL] SetScrollRange ( hWnd: WD.HWND; nBar: LONGINT; nMinPos: LONGINT;
                           nMaxPos: LONGINT;
                           bRedraw: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] GetScrollRange ( hWnd: WD.HWND; nBar: LONGINT;
                           VAR lpMinPos: LONGINT (*WD.LPINT*);
                           VAR lpMaxPos: LONGINT (*WD.LPINT*) ): WD.BOOL;

PROCEDURE [_APICALL] ShowScrollBar ( hWnd: WD.HWND; wBar: LONGINT;
                          bShow: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] EnableScrollBar ( hWnd: WD.HWND; wSBflags: WD.UINT;
                            wArrows: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] SetPropA ( hWnd: WD.HWND; lpString: WD.LPCSTR;
                     hData: WD.HANDLE ): WD.BOOL;
PROCEDURE [_APICALL] SetPropW ( hWnd: WD.HWND; lpString: WD.LPCWSTR;
                     hData: WD.HANDLE ): WD.BOOL;
(*    !  SetProp *)

PROCEDURE [_APICALL] GetPropA ( hWnd: WD.HWND;
                     lpString: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] GetPropW ( hWnd: WD.HWND;
                     lpString: WD.LPCWSTR ): WD.HANDLE;
(*  ! GetProp *)

PROCEDURE [_APICALL] RemovePropA ( hWnd: WD.HWND;
                        lpString: WD.LPCSTR ): WD.HANDLE;
PROCEDURE [_APICALL] RemovePropW ( hWnd: WD.HWND;
                        lpString: WD.LPCWSTR ): WD.HANDLE;
(*  ! RemoveProp *)

PROCEDURE [_APICALL] EnumPropsExA ( hWnd: WD.HWND; lpEnumFunc: PROPENUMPROCEXA;
                         lParam: WD.LPARAM ): LONGINT;
PROCEDURE [_APICALL] EnumPropsExW ( hWnd: WD.HWND; lpEnumFunc: PROPENUMPROCEXW;
                         lParam: WD.LPARAM ): LONGINT;
(*  ! EnumPropsEx *)

PROCEDURE [_APICALL] EnumPropsA ( hWnd: WD.HWND; lpEnumFunc: PROPENUMPROCA ): LONGINT;
PROCEDURE [_APICALL] EnumPropsW ( hWnd: WD.HWND; lpEnumFunc: PROPENUMPROCW ): LONGINT;
(*  !  EnumProps *)

PROCEDURE [_APICALL] SetWindowTextA ( hWnd: WD.HWND; lpString: WD.LPCSTR ): WD.BOOL;
PROCEDURE [_APICALL] SetWindowTextW ( hWnd: WD.HWND; lpString: WD.LPCWSTR ): WD.BOOL;
(*  ! SetWindowText *)

PROCEDURE [_APICALL] GetWindowTextA ( hWnd: WD.HWND; lpString: WD.LPSTR;
                           nMaxCount: LONGINT ): LONGINT;
PROCEDURE [_APICALL] GetWindowTextW ( hWnd: WD.HWND; lpString: WD.LPWSTR;
                           nMaxCount: LONGINT ): LONGINT;
(*  !  GetWindowText *)

PROCEDURE [_APICALL] GetWindowTextLengthA ( hWnd: WD.HWND ): LONGINT;
PROCEDURE [_APICALL] GetWindowTextLengthW ( hWnd: WD.HWND ): LONGINT;
(*  !   GetWindowTextLength *)

PROCEDURE [_APICALL] GetClientRect ( hWnd: WD.HWND;
                          VAR STATICTYPED lpRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowRect ( hWnd: WD.HWND;
                          VAR STATICTYPED lpRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] AdjustWindowRect ( VAR STATICTYPED lpRect: WD.RECT; dwStyle: WD.DWORD;
                             bMenu: WD.BOOL ): WD.BOOL;

PROCEDURE [_APICALL] AdjustWindowRectEx ( VAR STATICTYPED lpRect: WD.RECT; dwStyle: WD.DWORD;
                               bMenu: WD.BOOL;
                               dwExStyle: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowContextHelpId ( arg0: WD.HWND;
                                   arg1: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowContextHelpId ( arg0: WD.HWND ): WD.DWORD;

PROCEDURE [_APICALL] SetMenuContextHelpId ( arg0: WD.HMENU;
                                 arg1: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] GetMenuContextHelpId ( arg0: WD.HMENU ): WD.DWORD;

PROCEDURE [_APICALL] MessageBoxA ( hWnd: WD.HWND; lpText: WD.LPCSTR;
                        lpCaption: WD.LPCSTR;
                        uType: WD.UINT ): LONGINT;
PROCEDURE [_APICALL] MessageBoxW ( hWnd: WD.HWND; lpText: WD.LPCWSTR;
                        lpCaption: WD.LPCWSTR;
                        uType: WD.UINT ): LONGINT;
(*  !   MessageBox *)

PROCEDURE [_APICALL] MessageBoxExA ( hWnd: WD.HWND; lpText: WD.LPCSTR;
                          lpCaption: WD.LPCSTR; uType: WD.UINT;
                          wLanguageId: WD.WORD ): LONGINT;
PROCEDURE [_APICALL] MessageBoxExW ( hWnd: WD.HWND; lpText: WD.LPCWSTR;
                          lpCaption: WD.LPCWSTR; uType: WD.UINT;
                          wLanguageId: WD.WORD ): LONGINT;
(*  !  MessageBoxEx *)

PROCEDURE [_APICALL] MessageBoxIndirectA ( VAR STATICTYPED arg0: MSGBOXPARAMSA ): LONGINT;
PROCEDURE [_APICALL] MessageBoxIndirectW ( VAR STATICTYPED arg0: MSGBOXPARAMSW ): LONGINT;
(*  !   MessageBoxIndirect *)

PROCEDURE [_APICALL] MessageBeep ( uType: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] ShowCursor ( bShow: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] SetCursorPos ( X: LONGINT; Y: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetCursor ( hCursor: WD.HCURSOR ): WD.HCURSOR;

PROCEDURE [_APICALL] GetCursorPos ( VAR STATICTYPED lpPoint: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] ClipCursor ( VAR STATICTYPED lpRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] GetClipCursor ( VAR STATICTYPED lpRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] GetCursor (  ): WD.HCURSOR;

PROCEDURE [_APICALL] CreateCaret ( hWnd: WD.HWND; hBitmap: WD.HBITMAP;
                        nWidth: LONGINT; nHeight: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetCaretBlinkTime (  ): WD.UINT;

PROCEDURE [_APICALL] SetCaretBlinkTime ( uMSeconds: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] DestroyCaret (  ): WD.BOOL;

PROCEDURE [_APICALL] HideCaret ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] ShowCaret ( hWnd: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] SetCaretPos ( X: LONGINT; Y: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] GetCaretPos ( VAR STATICTYPED lpPoint: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] ClientToScreen ( hWnd: WD.HWND;
                           VAR STATICTYPED lpPoint: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] ScreenToClient ( hWnd: WD.HWND;
                           VAR STATICTYPED lpPoint: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] MapWindowPoints ( hWndFrom: WD.HWND; hWndTo: WD.HWND;
                            VAR STATICTYPED lpPoints: WD.POINTS;
                            cPoints: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] WindowFromPoint ( Point: WD.POINT ): WD.HWND;

PROCEDURE [_APICALL] ChildWindowFromPoint ( hWndParent: WD.HWND;
                                 Point: WD.POINT ): WD.HWND;


PROCEDURE [_APICALL] ChildWindowFromPointEx ( arg0: WD.HWND; arg1: WD.POINT;
                                   arg2: WD.UINT ): WD.HWND;

PROCEDURE [_APICALL] GetSysColor ( nIndex: LONGINT ): WD.DWORD;

PROCEDURE [_APICALL] GetSysColorBrush ( nIndex: LONGINT ): WD.HBRUSH;

PROCEDURE [_APICALL] SetSysColors ( cElements: LONGINT; lpaElements: WD.PBOOL;
                         lpaRgbValues: PSECURITY_INFORMATION ): WD.BOOL;

PROCEDURE [_APICALL] DrawFocusRect ( hDC: WD.HDC;
                          VAR STATICTYPED lprc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] FillRect ( hDC: WD.HDC; VAR STATICTYPED lprc: WD.RECT;
                     hbr: WD.HBRUSH ): LONGINT;

PROCEDURE [_APICALL] FrameRect ( hDC: WD.HDC; VAR STATICTYPED lprc: WD.RECT;
                      hbr: WD.HBRUSH ): LONGINT;

PROCEDURE [_APICALL] InvertRect ( hDC: WD.HDC; VAR STATICTYPED lprc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] SetRect ( VAR STATICTYPED lprc: WD.RECT; xLeft: LONGINT; yTop: LONGINT;
                    xRight: LONGINT; yBottom: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] SetRectEmpty ( VAR STATICTYPED lprc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] CopyRect ( VAR STATICTYPED lprcDst: WD.RECT;
                     VAR STATICTYPED lprcSrc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] InflateRect ( VAR STATICTYPED lprc: WD.RECT; dx: LONGINT;
                        dy: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] IntersectRect ( VAR STATICTYPED lprcDst: WD.RECT;
              VAR STATICTYPED lprcSrc1: WD.RECT;
                          VAR STATICTYPED lprcSrc2: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] UnionRect ( VAR STATICTYPED lprcDst: WD.RECT; 
            VAR STATICTYPED lprcSrc1: WD.RECT;
                      VAR STATICTYPED lprcSrc2: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] SubtractRect ( VAR STATICTYPED lprcDst: WD.RECT; 
             VAR STATICTYPED lprcSrc1: WD.RECT;
                         VAR STATICTYPED lprcSrc2: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] OffsetRect ( VAR STATICTYPED lprc: WD.RECT; dx: LONGINT;
                       dy: LONGINT ): WD.BOOL;

PROCEDURE [_APICALL] IsRectEmpty ( VAR STATICTYPED lprc: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] EqualRect ( VAR STATICTYPED lprc1: WD.RECT;
                      VAR STATICTYPED lprc2: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] PtInRect ( VAR STATICTYPED lprc: WD.RECT; pt: WD.POINT ): WD.BOOL;

PROCEDURE [_APICALL] GetWindowWord ( hWnd: WD.HWND; nIndex: LONGINT ): WD.WORD;

PROCEDURE [_APICALL] SetWindowWord ( hWnd: WD.HWND; nIndex: LONGINT;
                          wNewWord: WD.WORD ): WD.WORD;

PROCEDURE [_APICALL] GetWindowLongA ( hWnd: WD.HWND; nIndex: LONGINT ): LONGINT;
PROCEDURE [_APICALL] GetWindowLongW ( hWnd: WD.HWND; nIndex: LONGINT ): LONGINT;
(*  !    GetWindowLong *)

PROCEDURE [_APICALL] SetWindowLongA ( hWnd: WD.HWND; nIndex: LONGINT;
                           dwNewLong: LONGINT ): LONGINT;
PROCEDURE [_APICALL] SetWindowLongW ( hWnd: WD.HWND; nIndex: LONGINT;
                           dwNewLong: LONGINT ): LONGINT;
(*  !  SetWindowLong *)

PROCEDURE [_APICALL] GetClassWord ( hWnd: WD.HWND; nIndex: LONGINT ): WD.WORD;

PROCEDURE [_APICALL] SetClassWord ( hWnd: WD.HWND; nIndex: LONGINT;
                         wNewWord: WD.WORD ): WD.WORD;

PROCEDURE [_APICALL] GetClassLongA ( hWnd: WD.HWND; nIndex: LONGINT ): WD.DWORD;
PROCEDURE [_APICALL] GetClassLongW ( hWnd: WD.HWND; nIndex: LONGINT ): WD.DWORD;
(*  !  GetClassLong *)

PROCEDURE [_APICALL] SetClassLongA ( hWnd: WD.HWND; nIndex: LONGINT;
                          dwNewLong: LONGINT ): WD.DWORD;
PROCEDURE [_APICALL] SetClassLongW ( hWnd: WD.HWND; nIndex: LONGINT;
                          dwNewLong: LONGINT ): WD.DWORD;
(*  !  SetClassLong *)

PROCEDURE [_APICALL] GetDesktopWindow (  ): WD.HWND;

PROCEDURE [_APICALL] GetParent ( hWnd: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] SetParent ( hWndChild: WD.HWND;
                      hWndNewParent: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] EnumChildWindows ( hWndParent: WD.HWND; lpEnumFunc: WNDENUMPROC;
                             lParam: WD.LPARAM ): WD.BOOL;

PROCEDURE [_APICALL] FindWindowA ( lpClassName: WD.LPCSTR;
                        lpWindowName: WD.LPCSTR ): WD.HWND;
PROCEDURE [_APICALL] FindWindowW ( lpClassName: WD.LPCWSTR;
                        lpWindowName: WD.LPCWSTR ): WD.HWND;
(*  !  FindWindow *)

PROCEDURE [_APICALL] FindWindowExA ( arg0: WD.HWND; arg1: WD.HWND;
                          arg2: WD.LPCSTR;
                          arg3: WD.LPCSTR ): WD.HWND;
PROCEDURE [_APICALL] FindWindowExW ( arg0: WD.HWND; arg1: WD.HWND;
                          arg2: WD.LPCWSTR;
                          arg3: WD.LPCWSTR ): WD.HWND;
(*  !   FindWindowEx *)

PROCEDURE [_APICALL] EnumWindows ( lpEnumFunc: WNDENUMPROC;
                        lParam: WD.LPARAM ): WD.BOOL;

PROCEDURE [_APICALL] EnumThreadWindows ( dwThreadId: WD.DWORD; lpfn: WNDENUMPROC;
                              lParam: WD.LPARAM ): WD.BOOL;

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] EnumTaskWindows ( hTask; lpfn; lParam: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / EnumTaskWindows ( hTask; lpfn; lParam: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)

PROCEDURE [_APICALL] GetClassNameA ( hWnd: WD.HWND; lpClassName: WD.LPSTR;
                          nMaxCount: LONGINT ): LONGINT;
PROCEDURE [_APICALL] GetClassNameW ( hWnd: WD.HWND; lpClassName: WD.LPWSTR;
                          nMaxCount: LONGINT ): LONGINT;
(*  !   GetClassName *)

PROCEDURE [_APICALL] GetTopWindow ( hWnd: WD.HWND ): WD.HWND;

(*  MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetNextWindow ( hWnd; wCmd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetNextWindow ( hWnd; wCmd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetSysModalWindow ( );
<* ELSE *>
PROCEDURE [_APICALL]  / GetSysModalWindow ( );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] SetSysModalWindow ( hWnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / SetSysModalWindow ( hWnd: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)

PROCEDURE [_APICALL] GetWindowThreadProcessId ( hWnd: WD.HWND;
                                     VAR lpdwProcessId: WD.DWORD ): WD.DWORD;

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] GetWindowTask ( hWnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / GetWindowTask ( hWnd: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)

PROCEDURE [_APICALL] GetLastActivePopup ( hWnd: WD.HWND ): WD.HWND;

PROCEDURE [_APICALL] GetWindow ( hWnd: WD.HWND; uCmd: WD.UINT ): WD.HWND;

PROCEDURE [_APICALL] SetWindowsHookA ( nFilterType: LONGINT; pfnFilterProc: HOOKPROC ): HOOKPROC;
PROCEDURE [_APICALL] SetWindowsHookW ( nFilterType: LONGINT; pfnFilterProc: HOOKPROC ): HOOKPROC;
(*  !   SetWindowsHook *)

PROCEDURE [_APICALL] UnhookWindowsHook ( nCode: LONGINT;
                              pfnFilterProc: HOOKPROC ): WD.BOOL;

PROCEDURE [_APICALL] SetWindowsHookExA ( idHook: LONGINT; lpfn: HOOKPROC;
                              hmod: WD.HINSTANCE;
                              dwThreadId: WD.DWORD ): WD.HHOOK;
PROCEDURE [_APICALL] SetWindowsHookExW ( idHook: LONGINT; lpfn: HOOKPROC;
                              hmod: WD.HINSTANCE;
                              dwThreadId: WD.DWORD ): WD.HHOOK;
(*  ! SetWindowsHookEx *)

PROCEDURE [_APICALL] UnhookWindowsHookEx ( hhk: WD.HHOOK ): WD.BOOL;

PROCEDURE [_APICALL] CallNextHookEx ( hhk: WD.HHOOK; nCode: LONGINT;
                           wParam: WD.WPARAM;
                           lParam: WD.LPARAM ): WD.LRESULT;

(*                                                               *)
(*  * Macros for source-level compatibility with old functions.  *)
(*                                                               *)

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] DefHookProc ( nCode; wParam; lParam; phhk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / DefHookProc ( nCode; wParam; lParam; phhk: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)



PROCEDURE [_APICALL] CheckMenuRadioItem ( arg0: WD.HMENU; arg1: WD.UINT;
                               arg2: WD.UINT; arg3: WD.UINT;
                               arg4: WD.UINT ): WD.BOOL;

(*                    *)
(*  * Obsolete names  *)
(*                    *)
(*                               *)
(*  * Resource Loading Routines  *)
(*                               *)

PROCEDURE [_APICALL] LoadBitmapA ( hInstance: WD.HINSTANCE;
                        lpBitmapName: WD.LPCSTR ): WD.HBITMAP;
PROCEDURE [_APICALL] LoadBitmapW ( hInstance: WD.HINSTANCE;
                        lpBitmapName: WD.LPCWSTR ): WD.HBITMAP;
(*  !  LoadBitmap *)

PROCEDURE [_APICALL] LoadCursorA ( hInstance: WD.HINSTANCE;
                        lpCursorName: WD.LPCSTR ): WD.HCURSOR;
PROCEDURE [_APICALL] LoadCursorW ( hInstance: WD.HINSTANCE;
                        lpCursorName: WD.LPCWSTR ): WD.HCURSOR;
(*  !  LoadCursor *)

PROCEDURE [_APICALL] LoadCursorFromFileA ( lpFileName: WD.LPCSTR ): WD.HCURSOR;
PROCEDURE [_APICALL] LoadCursorFromFileW ( lpFileName: WD.LPCWSTR ): WD.HCURSOR;
(*     LoadCursorFromFile *)

PROCEDURE [_APICALL] CreateCursor ( hInst: WD.HINSTANCE; xHotSpot: LONGINT;
                         yHotSpot: LONGINT; nWidth: LONGINT; nHeight: LONGINT;
                         pvANDPlane: LONGINT; (* ptr to void *)
                         pvXORPlane: LONGINT (* ptr to void *) ): WD.HCURSOR;

PROCEDURE [_APICALL] DestroyCursor ( hCursor: WD.HCURSOR ): WD.BOOL;

(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] CopyCursor ( pcur: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / CopyCursor ( pcur: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS *)
(*                         *)
(*  * Standard Cursor IDs  *)
(*                         *)

PROCEDURE [_APICALL] SetSystemCursor ( hcur: WD.HCURSOR;
                            id: WD.DWORD ): WD.BOOL;

PROCEDURE [_APICALL] LoadIconA ( hInstance: WD.HINSTANCE;
                      lpIconName: WD.LPCSTR ): WD.HICON;
PROCEDURE [_APICALL] LoadIconW ( hInstance: WD.HINSTANCE;
                      lpIconName: WD.LPCWSTR ): WD.HICON;
(*  !   LoadIcon *)

PROCEDURE [_APICALL] CreateIcon ( hInstance: WD.HINSTANCE; nWidth: LONGINT;
                       nHeight: LONGINT; cPlanes: WD.BYTE;
                       cBitsPixel: WD.BYTE; lpbANDbits: WD.PUCHAR;
                       VAR lpbXORbits: CHAR (*WD.PUCHAR*) ): WD.HICON;

PROCEDURE [_APICALL] DestroyIcon ( hIcon: WD.HICON ): WD.BOOL;

PROCEDURE [_APICALL] LookupIconIdFromDirectory ( presbits: WD.PBYTE;
                                      fIcon: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] LookupIconIdFromDirectoryEx ( presbits: WD.PBYTE;
                                        fIcon: WD.BOOL; cxDesired: LONGINT;
                                        cyDesired: LONGINT;
                                        Flags: WD.UINT ): LONGINT;

PROCEDURE [_APICALL] CreateIconFromResource ( presbits: WD.PBYTE;
                                   dwResSize: WD.DWORD;
                                   fIcon: WD.BOOL;
                                   dwVer: WD.DWORD ): WD.HICON;

PROCEDURE [_APICALL] CreateIconFromResourceEx ( presbits: WD.PBYTE;
                                     dwResSize: WD.DWORD;
                                     fIcon: WD.BOOL; dwVer: WD.DWORD;
                                     cxDesired: LONGINT; cyDesired: LONGINT;
                                     Flags: WD.UINT ): WD.HICON;
 
PROCEDURE [_APICALL] LoadImageA ( arg0: WD.HINSTANCE; arg1: WD.LPCSTR;
                       arg2: WD.UINT; arg3: LONGINT; arg4: LONGINT;
                       arg5: WD.UINT ): WD.HANDLE;
PROCEDURE [_APICALL] LoadImageW ( arg0: WD.HINSTANCE; arg1: WD.LPCWSTR;
                       arg2: WD.UINT; arg3: LONGINT; arg4: LONGINT;
                       arg5: WD.UINT ): WD.HANDLE;
(*  !  LoadImage *)

PROCEDURE [_APICALL] CopyImage ( arg0: WD.HANDLE; arg1: WD.UINT; arg2: LONGINT;
                      arg3: LONGINT; arg4: WD.UINT ): WD.HICON;



PROCEDURE [_APICALL] DrawIconEx ( hdc: WD.HDC; xLeft: LONGINT; yTop: LONGINT;
                       hIcon: WD.HICON; cxWidth: LONGINT; cyWidth: LONGINT;
                       istepIfAniCur: WD.UINT;
                       hbrFlickerFreeDraw: WD.HBRUSH;
                       diFlags: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] CreateIconIndirect ( VAR STATICTYPED piconinfo: ICONINFO ): WD.HICON;

PROCEDURE [_APICALL] CopyIcon ( hIcon: WD.HICON ): WD.HICON;

PROCEDURE [_APICALL] GetIconInfo ( hIcon: WD.HICON;
                        piconinfo: PICONINFO ): WD.BOOL;

(*                       *)
(*  * Standard Icon IDs  *)
(*                       *)

PROCEDURE [_APICALL] LoadStringA ( hInstance: WD.HINSTANCE; uID: WD.UINT;
                        lpBuffer: WD.LPSTR; nBufferMax: LONGINT ): LONGINT;
PROCEDURE [_APICALL] LoadStringW ( hInstance: WD.HINSTANCE; uID: WD.UINT;
                        lpBuffer: WD.LPWSTR; nBufferMax: LONGINT ): LONGINT;
(*  !  LoadString *)

(*                             *)
(*  * Dialog Manager Routines  *)
(*                             *)

PROCEDURE [_APICALL] IsDialogMessageA ( hDlg: WD.HWND; VAR STATICTYPED lpMsg: MSG ): WD.BOOL;
PROCEDURE [_APICALL] IsDialogMessageW ( hDlg: WD.HWND; VAR STATICTYPED lpMsg: MSG ): WD.BOOL;
(*  !  IsDialogMessage *)

PROCEDURE [_APICALL] MapDialogRect ( hDlg: WD.HWND;
                          VAR STATICTYPED lpRect: WD.RECT ): WD.BOOL;

PROCEDURE [_APICALL] DlgDirListA ( hDlg: WD.HWND; lpPathSpec: WD.LPSTR;
                        nIDListBox: LONGINT; nIDStaticPath: LONGINT;
                        uFileType: WD.UINT ): LONGINT;
PROCEDURE [_APICALL] DlgDirListW ( hDlg: WD.HWND; lpPathSpec: WD.LPWSTR;
                        nIDListBox: LONGINT; nIDStaticPath: LONGINT;
                        uFileType: WD.UINT ): LONGINT;
(*  !  DlgDirList *)

PROCEDURE [_APICALL] DlgDirSelectExA ( hDlg: WD.HWND; lpString: WD.LPSTR;
                            nCount: LONGINT; nIDListBox: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] DlgDirSelectExW ( hDlg: WD.HWND; lpString: WD.LPWSTR;
                            nCount: LONGINT; nIDListBox: LONGINT ): WD.BOOL;
(*  !  DlgDirSelectEx *)

PROCEDURE [_APICALL] DlgDirListComboBoxA ( hDlg: WD.HWND; lpPathSpec: WD.LPSTR;
                                nIDComboBox: LONGINT; nIDStaticPath: LONGINT;
                                uFiletype: WD.UINT ): LONGINT;
PROCEDURE [_APICALL] DlgDirListComboBoxW ( hDlg: WD.HWND; lpPathSpec: WD.LPWSTR;
                                nIDComboBox: LONGINT; nIDStaticPath: LONGINT;
                                uFiletype: WD.UINT ): LONGINT;
(*  !    DlgDirListComboBox *)

PROCEDURE [_APICALL] DlgDirSelectComboBoxExA ( hDlg: WD.HWND; lpString: WD.LPSTR;
                                    nCount: LONGINT;
                                    nIDComboBox: LONGINT ): WD.BOOL;
PROCEDURE [_APICALL] DlgDirSelectComboBoxExW ( hDlg: WD.HWND;
                                    lpString: WD.LPWSTR; nCount: LONGINT;
                                    nIDComboBox: LONGINT ): WD.BOOL;
(*  !   DlgDirSelectComboBoxEx *)



PROCEDURE [_APICALL] SetScrollInfo ( arg0: WD.HWND; arg1: LONGINT; 
              VAR STATICTYPED arg2: SCROLLINFO;
                          arg3: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] GetScrollInfo ( arg0: WD.HWND; arg1: LONGINT;
                          VAR STATICTYPED arg2: SCROLLINFO ): WD.BOOL;

PROCEDURE [_APICALL] DefFrameProcA ( hWnd: WD.HWND; hWndMDIClient: WD.HWND;
                          uMsg: WD.UINT; wParam: WD.WPARAM;
                          lParam: WD.LPARAM ): WD.LRESULT;
PROCEDURE [_APICALL] DefFrameProcW ( hWnd: WD.HWND; hWndMDIClient: WD.HWND;
                          uMsg: WD.UINT; wParam: WD.WPARAM;
                          lParam: WD.LPARAM ): WD.LRESULT;
(*  !   DefFrameProc *)

PROCEDURE [_APICALL] DefMDIChildProcA ( hWnd: WD.HWND; uMsg: WD.UINT;
                             wParam: WD.WPARAM;
                             lParam: WD.LPARAM ): WD.LRESULT;
PROCEDURE [_APICALL] DefMDIChildProcW ( hWnd: WD.HWND; uMsg: WD.UINT;
                             wParam: WD.WPARAM;
                             lParam: WD.LPARAM ): WD.LRESULT;
(*  !   DefMDIChildProc *)

PROCEDURE [_APICALL] TranslateMDISysAccel ( hWndClient: WD.HWND;
                                 VAR STATICTYPED lpMsg: MSG ): WD.BOOL;

PROCEDURE [_APICALL] ArrangeIconicWindows ( hWnd: WD.HWND ): WD.UINT;

PROCEDURE [_APICALL] CreateMDIWindowA ( lpClassName: WD.LPSTR;
                             lpWindowName: WD.LPSTR;
                             dwStyle: WD.DWORD; X: LONGINT; Y: LONGINT;
                             nWidth: LONGINT; nHeight: LONGINT;
                             hWndParent: WD.HWND;
                             hInstance: WD.HINSTANCE;
                             lParam: WD.LPARAM ): WD.HWND;
PROCEDURE [_APICALL] CreateMDIWindowW ( lpClassName: WD.LPWSTR;
                             lpWindowName: WD.LPWSTR;
                             dwStyle: WD.DWORD; X: LONGINT; Y: LONGINT;
                             nWidth: LONGINT; nHeight: LONGINT;
                             hWndParent: WD.HWND;
                             hInstance: WD.HINSTANCE;
                             lParam: WD.LPARAM ): WD.HWND;
(*  !    CreateMDIWindow *)

PROCEDURE [_APICALL] TileWindows ( hwndParent: WD.HWND; wHow: WD.UINT;
                        VAR STATICTYPED lpRect: WD.RECT; cKids: WD.UINT;
                        VAR  kids: WG.FXPT16DOT16 ): WD.WORD;

PROCEDURE [_APICALL] CascadeWindows ( hwndParent: WD.HWND; wHow: WD.UINT;
                           VAR STATICTYPED lpRect: WD.RECT; cKids: WD.UINT;
                           VAR  kids: WG.FXPT16DOT16 ): WD.WORD;


PROCEDURE [_APICALL] WinHelpA ( hWndMain: WD.HWND; lpszHelp: WD.LPCSTR;
                     uCommand: WD.UINT;
                     dwData: WD.DWORD ): WD.BOOL;
PROCEDURE [_APICALL] WinHelpW ( hWndMain: WD.HWND; lpszHelp: WD.LPCWSTR;
                     uCommand: WD.UINT;
                     dwData: WD.DWORD ): WD.BOOL;
(*  !  WinHelp *)

PROCEDURE [_APICALL] ChangeDisplaySettingsA ( VAR STATICTYPED lpDevMode: WG.DEVMODEA;
                                   dwFlags: WD.DWORD ): LONGINT;
PROCEDURE [_APICALL] ChangeDisplaySettingsW ( VAR STATICTYPED lpDevMode: WG.DEVMODEW;
                                   dwFlags: WD.DWORD ): LONGINT;
(*  !   ChangeDisplaySettings *)

PROCEDURE [_APICALL] EnumDisplaySettingsA ( lpszDeviceName: WD.LPCSTR;
                                 iModeNum: WD.DWORD;
                                 VAR STATICTYPED lpDevMode: WG.DEVMODEA ): WD.BOOL;
PROCEDURE [_APICALL] EnumDisplaySettingsW ( lpszDeviceName: WD.LPCWSTR;
                                 iModeNum: WD.DWORD;
                                 VAR STATICTYPED lpDevMode: WG.DEVMODEW ): WD.BOOL;
(*  !     EnumDisplaySettings *)

PROCEDURE [_APICALL] SystemParametersInfoA ( uiAction: WD.UINT; uiParam: WD.UINT;
                                  pvParam: WD.LPVOID;
                                  fWinIni: WD.UINT ): WD.BOOL;
PROCEDURE [_APICALL] SystemParametersInfoW ( uiAction: WD.UINT; uiParam: WD.UINT;
                                  pvParam: WD.LPVOID;
                                  fWinIni: WD.UINT ): WD.BOOL;
(*  !  SystemParametersInfo *)

(*                     *)
(*  * Set debug level  *)
(*                     *)

PROCEDURE [_APICALL] SetDebugErrorLevel ( dwLevel: WD.DWORD );

PROCEDURE [_APICALL] SetLastErrorEx ( dwErrCode: WD.DWORD; dwType: WD.DWORD );

PROCEDURE [_APICALL] MsgWaitForMultipleObjectsEx(
     nCount: WD.DWORD;
     VAR Handles: WD.HANDLE;
     dwMilliseconds: WD.DWORD;
     dwWakeMask: WD.DWORD;
     dwFlags: WD.DWORD): WD.DWORD;

END WinUser.
