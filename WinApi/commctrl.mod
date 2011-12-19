(******************************************************************************)
(*                                                                            *)
(**)                      DEFINITION CommCTRL;                              (**)
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
(*  06-14-1997 rel. 1.0 by Christian Wohlfahrtstaetter                        *)
(******************************************************************************)
(*                                                                            *)
(* commctrl.h - - Interface for the Windows Common Controls                   *)
(*                                                                            *)
(* Version 1.2                                                                *)
(* Version 1.3  Minor changes and additions (notify messages)                 *)
(******************************************************************************)

IMPORT  WU := WinUser, WD := WinDef, WN := WinNT;

(*  *)
(*  Define API decoration for direct importing of DLL references. *)
(*  *)
(*  *)
(*  For compilers that don't support nameless unions *)
(*  *)
(*  *)
(*  Users of this header may define any number of these constants to avoid *)
(*  the definitions of each functional group. *)
(*  *)
(*     NOTOOLBAR    Customizable bitmap-button toolbar control. *)
(*     NOUPDOWN     Up and Down arrow increment/decrement control. *)
(*     NOSTATUSBAR  Status bar control. *)
(*     NOMENUHELP   APIs to help manage menus; especially with a status bar. *)
(*     NOTRACKBAR   Customizable column-width tracking control. *)
(*     NODRAGLIST   APIs to make a listbox source and sink drag&drop actions. *)
(*     NOPROGRESS   Progress gas gauge. *)
(*     NOHOTKEY     HotKey control *)
(*     NOHEADER     Header bar control. *)
(*     NOIMAGEAPIS  ImageList apis. *)
(*     NOLISTVIEW   ListView control. *)
(*     NOTREEVIEW   TreeView control. *)
(*     NOTABCONTROL Tab control. *)
(*     NOANIMATE    Animate control. *)
(*  *)
(* ============================================================================= *)

CONST 
  WM_USER = 400H;
  
  ICC_LISTVIEW_CLASSES = 1H;           (*  listview; header *)
  ICC_TREEVIEW_CLASSES = 2H;           (*  treeview; tooltips *)
  ICC_BAR_CLASSES = 4H;                (*  toolbar; statusbar; trackbar; tooltips *)
  ICC_TAB_CLASSES = 8H;                (*  tab; tooltips *)
  ICC_UPDOWN_CLASS = 10H;              (*  updown *)
  ICC_PROGRESS_CLASS = 20H;            (*  progress *)
  ICC_HOTKEY_CLASS = 40H;              (*  hotkey *)
  ICC_ANIMATE_CLASS = 80H;             (*  animate *)
  ICC_WIN95_CLASSES = 0FFH;
  ICC_DATE_CLASSES = 100H;             (*  month picker; date picker; time picker; updown *)
  ICC_USEREX_CLASSES = 200H;           (*  comboex *)
  ICC_COOL_CLASSES = 400H;             (*  rebar (coolbar) control *)

  ODT_HEADER = 100;
  ODT_TAB = 101;
  ODT_LISTVIEW = 102;

(* ====== Ranges for control message IDs ======================================= *)
  LVM_FIRST = 1000H;                   (*  ListView messages *)
  TV_FIRST  = 1100H;                   (*  TreeView messages *)
  HDM_FIRST = 1200H;                   (*  Header messages *)

(* ====== Generic WM_NOTIFY notification codes ================================= *)
(* ====== WM_NOTIFY codes (NMHDR.code values) ================================== *)
 
  NM_FIRST       =   0;                (*  generic to all controls *)
  NM_LAST        = -99;
  NM_OUTOFMEMORY = (NM_FIRST-1);
  NM_CLICK       = (NM_FIRST-2);
  NM_DBLCLK      = (NM_FIRST-3);
  NM_RETURN      = (NM_FIRST-4);
  NM_RCLICK      = (NM_FIRST-5);
  NM_RDBLCLK     = (NM_FIRST-6);
  NM_SETFOCUS    = (NM_FIRST-7);
  NM_KILLFOCUS   = (NM_FIRST-8);
  NM_CUSTOMDRAW  = (NM_FIRST-12);
  NM_HOVER       = (NM_FIRST-13);

  LVN_FIRST      = 0-100;              (*  listview *)
  LVN_LAST       = 0-199;
  HDN_FIRST      = 0-300;              (*  header *)
  HDN_LAST       = 0-399;
  TVN_FIRST      = 0-400;              (*  treeview *)
  TVN_LAST       = 0-499;
  TTN_FIRST      = 0-520;              (*  tooltips *)
  TTN_LAST       = 0-549;
  TCN_FIRST      = 0-550;              (*  tab control *)
  TCN_LAST       = 0-580;
  (* Reserverd:    (0U-580U) -  (0U-589U) *)
  CDN_FIRST      = 0-601;              (*  common dialog (new) *)
  CDN_LAST       = 0-699;
  TBN_FIRST      = 0-700;              (*  toolbar *)
  TBN_LAST       = 0-720;
  UDN_FIRST      = 0-721;              (*  updown *)
  UDN_LAST       = 0-740;
  MCN_FIRST      = 0-750;              (*  monthcal *)
  MCN_LAST       = 0-759;
  DTN_FIRST      = 0-760;              (*  datetimepick *)
  DTN_LAST       = 0-769;
  CBEN_FIRST     = 0-800;              (*  combo box ex *)
  CBEN_LAST      = 0-830;
  RBN_FIRST      = 0-831;              (*  rebar *)
  RBN_LAST       = 0-859;

  MSGF_COMMCTRL_BEGINDRAG   = 4200H;
  MSGF_COMMCTRL_SIZEHEADER  = 4201H;
  MSGF_COMMCTRL_DRAGSELECT  = 4202H;
  MSGF_COMMCTRL_TOOLBARCUST = 4203H;

(* ==================== CUSTOM DRAW ========================================== *)
(*  custom draw return flags *)
(*  values under 0x00010000 are reserved for global custom draw values. *)
(*  above that are for specific controls *)
  CDRF_DODEFAULT = 0H;
  CDRF_NEWFONT = 2H;
  CDRF_SKIPDEFAULT = 4H;
  CDRF_NOTIFYPOSTPAINT = 10H;
  CDRF_NOTIFYITEMDRAW = 20H;

(*  drawstage flags *)
(*  values under 0x00010000 are reserved for global custom draw values. *)
(*  above that are for specific controls *)
  CDDS_PREPAINT = 1H;
  CDDS_POSTPAINT = 2H;

(*  the 0x000010000 bit means it's individual item specific *)
  CDDS_ITEM = 10000H;
  CDDS_ITEMPREPAINT = 65537;
  CDDS_ITEMPOSTPAINT = 65538;

(*  itemState flags *)
  CDIS_SELECTED = 1H;
  CDIS_GRAYED = 2H;
  CDIS_DISABLED = 4H;
  CDIS_CHECKED = 8H;
  CDIS_FOCUS = 10H;
  CDIS_DEFAULT = 20H;

(* ====== IMAGE APIS =========================================================== *)
  CLR_NONE = -1H;
  CLR_DEFAULT = -1000000H;
  CLR_HILIGHT = CLR_DEFAULT;

  ILC_MASK = 1H;
  ILC_COLOR = 0H;
  ILC_COLORDDB = 0FEH;
  ILC_COLOR4 = 4H;
  ILC_COLOR8 = 8H;
  ILC_COLOR16 = 10H;
  ILC_COLOR24 = 18H;
  ILC_COLOR32 = 20H;
  ILC_PALETTE = 800H;                  (*  (no longer supported...never worked anyway) *)

  ILD_NORMAL = 0H;
  ILD_TRANSPARENT = 1H;
  ILD_MASK = 10H;
  ILD_IMAGE = 20H;
  ILD_ROP = 40H;
  ILD_BLEND25 = 2H;
  ILD_FOCUS = ILD_BLEND25;
  ILD_BLEND50 = 4H;
  ILD_SELECTED = ILD_BLEND50;
  ILD_BLEND = ILD_BLEND50;
  ILD_OVERLAYMASK = 0F00H;


(* ====== HEADER CONTROL ======================================================= *)

  WC_HEADER = 'SysHeader';
  HDS_HORZ = 0H;
  HDS_BUTTONS = 2H;
  HDS_HOTTRACK = 4H;
  HDS_HIDDEN = 8H;
  HDS_DRAGDROP = 40H;
 
  HDI_WIDTH = 1H;
  HDI_HEIGHT = HDI_WIDTH;
  HDI_TEXT = 2H;
  HDI_FORMAT = 4H;
  HDI_LPARAM = 8H;
  HDI_BITMAP = 10H;
  HDI_IMAGE = 20H;
  HDI_DI_SETITEM = 40H;
  HDI_ORDER = 80H;
  HDF_LEFT = 0;
  HDF_RIGHT = 1;
  HDF_CENTER = 2;
  HDF_JUSTIFYMASK = 3H;
  HDF_RTLREADING = 4;
  HDF_OWNERDRAW = 8000H;
  HDF_STRING = 4000H;
  HDF_BITMAP = 2000H;
  HDF_BITMAP_ON_RIGHT = 1000H;
  HDF_IMAGE = 800H;
  HDM_GETITEMCOUNT = HDM_FIRST+0;
  HDM_INSERTITEMA = HDM_FIRST+1;
  HDM_INSERTITEM = HDM_INSERTITEMA;    (* ! A *)
  HDM_INSERTITEMW = HDM_FIRST+10;
  HDM_DELETEITEM = HDM_FIRST+2;
  HDM_GETITEMA = HDM_FIRST+3;
  HDM_GETITEM = HDM_GETITEMA;      (* ! A *)
  HDM_GETITEMW = HDM_FIRST+11;
  HDM_SETITEMA = HDM_FIRST+4;
  HDM_SETITEM = HDM_SETITEMA;      (* ! A *)
  HDM_SETITEMW = HDM_FIRST+12;
  HDM_LAYOUT = HDM_FIRST+5;
 
  HHT_NOWHERE = 1H;
  HHT_ONHEADER = 2H;
  HHT_ONDIVIDER = 4H;
  HHT_ONDIVOPEN = 8H;
  HHT_ABOVE = 100H;
  HHT_BELOW = 200H;
  HHT_TORIGHT = 400H;
  HHT_TOLEFT = 800H;
 
  HDM_HITTEST = HDM_FIRST+6;
  HDM_GETITEMRECT = HDM_FIRST+7;
(*  lparam = int array of size HDM_GETITEMCOUNT *)
(*  the array specifies the order that all items should be displayed. *)
(*  e.g.  { 2; 0; 1} *)
(*  says the index 2 item should be shown in the 0ths position *)
(*       index 0 should be shown in the 1st position *)
(*       index 1 should be shown in the 2nd position *)
 
  HDM_SETIMAGELIST = HDM_FIRST+8;
  HDM_GETIMAGELIST = HDM_FIRST+9;
  HDM_ORDERTOINDEX = HDM_FIRST+15;
  HDM_CREATEDRAGIMAGE = HDM_FIRST+16;  (*  wparam = which item (by index) *)
  HDM_GETORDERARRAY = HDM_FIRST+17;
  HDM_SETORDERARRAY = HDM_FIRST+18;
  HDM_SETHOTDIVIDER = HDM_FIRST+19;

(*  convenience message for external dragdrop *)
(*  wParam = BOOL  specifying whether the lParam is a dwPos of the cursor *)
(*               position or the index of which divider to hotlight *)
(*  lParam = depends on wParam  (-1 and wParm = FALSE turns off hotlight) *)
 
  HDN_ITEMCHANGINGA = HDN_FIRST-0;
  HDN_ITEMCHANGING = HDN_ITEMCHANGINGA;    (* ! A *)
  HDN_ITEMCHANGINGW = HDN_FIRST-20;
  HDN_ITEMCHANGEDA = HDN_FIRST-1;
  HDN_ITEMCHANGED = HDN_ITEMCHANGEDA;    (* ! A *)
  HDN_ITEMCHANGEDW = HDN_FIRST-21;
  HDN_ITEMCLICKA = HDN_FIRST-2;
  HDN_ITEMCLICK = HDN_ITEMCLICKA;      (* ! A *)
  HDN_ITEMCLICKW = HDN_FIRST-22;
  HDN_ITEMDBLCLICKA = HDN_FIRST-3;
  HDN_ITEMDBLCLICK = HDN_ITEMDBLCLICKA;     (* ! A *)
  HDN_ITEMDBLCLICKW = HDN_FIRST-23;
  HDN_DIVIDERDBLCLICKA = HDN_FIRST-5;
  HDN_DIVIDERDBLCLICK = HDN_DIVIDERDBLCLICKA;  (* ! A *)
  HDN_DIVIDERDBLCLICKW = HDN_FIRST-25;
  HDN_BEGINTRACKA = HDN_FIRST-6;
  HDN_BEGINTRACK = HDN_BEGINTRACKA;       (* ! A *)
  HDN_BEGINTRACKW = HDN_FIRST-26;
  HDN_ENDTRACKA = HDN_FIRST-7;
  HDN_ENDTRACK = HDN_ENDTRACKA;         (* ! A *)
  HDN_ENDTRACKW = HDN_FIRST-27;
  HDN_TRACKA = HDN_FIRST-8;
  HDN_TRACK = HDN_TRACKA;
  HDN_TRACKW = HDN_FIRST-28;
  HDN_GETDISPINFOA = HDN_FIRST-9;
  HDN_GETDISPINFO = HDN_GETDISPINFOA;     (* ! A *)
  HDN_GETDISPINFOW = HDN_FIRST-29;
  HDN_BEGINDRAG = HDN_FIRST-10;
  HDN_ENDDRAG = HDN_FIRST-11;

(* ====== TOOLBAR CONTROL ====================================================== *)
  TOOLBARCLASSNAME = 'ToolbarWindow';

  CMB_MASKED = 2H;
  TBSTATE_CHECKED = 1H;
  TBSTATE_PRESSED = 2H;
  TBSTATE_ENABLED = 4H;
  TBSTATE_HIDDEN = 8H;
  TBSTATE_INDETERMINATE = 10H;
  TBSTATE_WRAP = 20H;
  TBSTYLE_BUTTON = 0H;
  TBSTYLE_SEP = 1H;
  TBSTYLE_CHECK = 2H;
  TBSTYLE_GROUP = 4H;
  TBSTYLE_CHECKGROUP = 6;
  TBSTYLE_DROPDOWN = 8H;
  TBSTYLE_TOOLTIPS = 100H;
  TBSTYLE_WRAPABLE = 200H;
  TBSTYLE_ALTDRAG = 400H;
  TBSTYLE_TRANSPARENT = 800H;
  TBSTYLE_FLAT = 1000H;
  TBSTYLE_HOTTRACK = 2000H;
  TBSTYLE_NOTEXT = 4000H;
  TB_ENABLEBUTTON = WM_USER+1;
  TB_CHECKBUTTON = WM_USER+2;
  TB_PRESSBUTTON = WM_USER+3;
  TB_HIDEBUTTON = WM_USER+4;
  TB_INDETERMINATE = WM_USER+5;
  TB_ISBUTTONENABLED = WM_USER+9;
  TB_ISBUTTONCHECKED = WM_USER+10;
  TB_ISBUTTONPRESSED = WM_USER+11;
  TB_ISBUTTONHIDDEN = WM_USER+12;
  TB_ISBUTTONINDETERMINATE = WM_USER+13;
  TB_SETSTATE = WM_USER+17;
  TB_GETSTATE = WM_USER+18;
  TB_ADDBITMAP = WM_USER+19;
  TB_ADDBUTTONS = WM_USER+20;
  TB_INSERTBUTTON = WM_USER+21;
  TB_DELETEBUTTON = WM_USER+22;
  TB_GETBUTTON = WM_USER+23;
  TB_BUTTONCOUNT = WM_USER+24;
  TB_COMMANDTOINDEX = WM_USER+25;
  TB_SAVERESTOREA = WM_USER+26;
  TB_SAVERESTORE = TB_SAVERESTOREA;      (* ! A *)
  TB_SAVERESTOREW = WM_USER+76;
  TB_CUSTOMIZE = WM_USER+27;
  TB_ADDSTRINGA = WM_USER+28;
  TB_ADDSTRING = TB_ADDSTRINGA;        (* ! A *)
  TB_ADDSTRINGW = WM_USER+77;
  TB_GETITEMRECT = WM_USER+29;
  TB_BUTTONSTRUCTSIZE = WM_USER+30;
  TB_SETBUTTONSIZE = WM_USER+31;
  TB_SETBITMAPSIZE = WM_USER+32;
  TB_AUTOSIZE = WM_USER+33;
  TB_GETTOOLTIPS = WM_USER+35;
  TB_SETTOOLTIPS = WM_USER+36;
  TB_SETPARENT = WM_USER+37;
  TB_SETROWS = WM_USER+39;
  TB_GETROWS = WM_USER+40;
  TB_SETCMDID = WM_USER+42;
  TB_CHANGEBITMAP = WM_USER+43;
  TB_GETBITMAP = WM_USER+44;
  TB_GETBUTTONTEXTA = WM_USER+45;
  TB_GETBUTTONTEXT = TB_GETBUTTONTEXTA;    (* ! A *)
  TB_GETBUTTONTEXTW = WM_USER+75;
  TB_REPLACEBITMAP = WM_USER+46;
  TB_SETINDENT = WM_USER+47;
  TB_SETIMAGELIST = WM_USER+48;
  TB_GETIMAGELIST = WM_USER+49;
  TB_LOADIMAGES = WM_USER+50;
  TB_GETRECT = WM_USER+51;             (*  wParam is the Cmd instead of index *)
  TB_SETHOTIMAGELIST = WM_USER+52;
  TB_GETHOTIMAGELIST = WM_USER+53;
  TB_SETDISABLEDIMAGELIST = WM_USER+54;
  TB_GETDISABLEDIMAGELIST = WM_USER+55;
  TB_SETSTYLE = WM_USER+56;
  TB_GETSTYLE = WM_USER+57;
  TB_GETBUTTONSIZE = WM_USER+58;

(* ====== REBAR CONTROL ======================================================== *)

  REBARCLASSNAME = 'ReBarWindow';
  RBIM_STYLE = 1H;
  RBIM_IMAGELIST = 2H;
  RBIM_BACKGROUND = 4H;
  RBS_TOOLTIPS = 1H;
  RBS_VARHEIGHT = 2H;
  RBS_VALID = 3;

  RBBS_BREAK = 1H;                     (*  break to new line *)
  RBBS_FIXEDSIZE = 2H;                 (*  band can't be sized *)
  RBBS_KEEPHEIGHT = 4H;                (*  don't change height *)
  RBBS_HIDDEN = 8H;                    (*  don't show *)
  RBBS_NOVERT = 10H;                   (*  don't show when vertical *)
  RBBIM_STYLE = 1H;
  RBBIM_COLORS = 2H;
  RBBIM_TEXT = 4H;
  RBBIM_IMAGE = 8H;
  RBBIM_CHILD = 10H;
  RBBIM_CHILDSIZE = 20H;
  RBBIM_SIZE = 40H;
 
  RB_INSERTBANDA = WM_USER+1;
  RB_INSERTBAND = RB_INSERTBANDA;     (* ! A *)
  RB_DELETEBAND = WM_USER+2;
  RB_GETBARINFO = WM_USER+3;
  RB_SETBARINFO = WM_USER+4;
  RB_GETBANDINFO = WM_USER+5;
  RB_SETBANDINFOA = WM_USER+6;
  RB_SETBANDINFO = RB_SETBANDINFOA;      (* ! A *)
  RB_SETPARENT = WM_USER+7;
  RB_ERASEDARK = WM_USER+8;
  RB_ANIMATE = WM_USER+9;
  RB_INSERTBANDW = WM_USER+10;
  RB_SETBANDINFOW = WM_USER+11;
  RB_GETBANDCOUNT = WM_USER+12;
  RB_GETROWCOUNT = WM_USER+13;
  RB_GETROWHEIGHT = WM_USER+14;
  RBN_HEIGHTCHANGE = RBN_FIRST-0;

(* ====== TOOLTIPS CONTROL ===================================================== *)
  TOOLTIPS_CLASS = 'tooltips_class';
 
  TTS_ALWAYSTIP = 1H;
  TTS_NOPREFIX = 2H;
  TTF_IDISHWND = 1H;

(*  Use this to center around trackpoint in trackmode *)
(*  -OR- to center around tool in normal mode. *)
(*  Use TTF_ABSOLUTE to place the tip exactly at the track coords when *)
(*  in tracking mode.  TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP *)
(*  to center the tip absolutely about the track point. *)
  TTF_CENTERTIP = 2H;
  TTF_RTLREADING = 4H;
  TTF_SUBCLASS = 10H;
  TTF_TRACK = 20H;
  TTF_ABSOLUTE = 80H;
  TTF_TRANSPARENT = 100H;
  TTF_DI_SETITEM = 8000H;              (*  valid only on the TTN_NEEDTEXT callback *)
  TTDT_AUTOMATIC = 0;
  TTDT_RESHOW = 1;
  TTDT_AUTOPOP = 2;
  TTDT_INITIAL = 3;
  TTM_ACTIVATE = WM_USER+1;
  TTM_SETDELAYTIME = WM_USER+3;
  TTM_ADDTOOLA = WM_USER+4;
  TTM_ADDTOOL = TTM_ADDTOOLA;     (* ! A *)
  TTM_ADDTOOLW = WM_USER+50;
  TTM_DELTOOLA = WM_USER+5;
  TTM_DELTOOL = TTM_DELTOOLA;      (* ! A *)
  TTM_DELTOOLW = WM_USER+51;
  TTM_NEWTOOLRECTA = WM_USER+6;
  TTM_NEWTOOLRECT = TTM_NEWTOOLRECTA; (* ! A *)
  TTM_NEWTOOLRECTW = WM_USER+52;
  TTM_RELAYEVENT = WM_USER+7;
  TTM_GETTOOLINFOA = WM_USER+8;
  TTM_GETTOOLINFO = TTM_GETTOOLINFOA;  (* ! A *)
  TTM_GETTOOLINFOW = WM_USER+53;
  TTM_SETTOOLINFOA = WM_USER+9;
  TTM_SETTOOLINFO = TTM_SETTOOLINFOA;  (* ! A *)
  TTM_SETTOOLINFOW = WM_USER+54;
  TTM_HITTESTA = WM_USER+10;
  TTM_HITTEST = TTM_HITTESTA;  (* ! A *)
  TTM_HITTESTW = WM_USER+55;
  TTM_GETTEXTA = WM_USER+11;
  TTM_GETTEXT = TTM_GETTEXTA;  (* ! A *)
  TTM_GETTEXTW = WM_USER+56;
  TTM_UPDATETIPTEXTA = WM_USER+12;
  TTM_UPDATETIPTEXT = TTM_UPDATETIPTEXTA;  (* ! A *)
  TTM_UPDATETIPTEXTW = WM_USER+57;
  TTM_GETTOOLCOUNT = WM_USER+13;
  TTM_ENUMTOOLSA = WM_USER+14;
  TTM_ENUMTOOLS = TTM_ENUMTOOLSA;  (* ! A *)
  TTM_ENUMTOOLSW = WM_USER+58;
  TTM_GETCURRENTTOOLA = WM_USER+15;
  TTM_GETCURRENTTOOL = TTM_GETCURRENTTOOLA;    (* ! A *)
  TTM_GETCURRENTTOOLW = WM_USER+59;
  TTM_WINDOWFROMPOINT = WM_USER+16;
  TTM_TRACKACTIVATE = WM_USER+17;      (*  wParam = TRUE/FALSE start end  lparam = LPTOOLINFO *)
  TTM_TRACKPOSITION = WM_USER+18;      (*  lParam = dwPos *)
  TTM_SETTIPBKCOLOR = WM_USER+19;
  TTM_SETTIPTEXTCOLOR = WM_USER+20;
  TTM_GETDELAYTIME = WM_USER+21;
  TTM_GETTIPBKCOLOR = WM_USER+22;
  TTM_GETTIPTEXTCOLOR = WM_USER+23;
  TTM_SETMAXTIPWIDTH = WM_USER+24;
  TTM_GETMAXTIPWIDTH = WM_USER+25;
  TTM_SETMARGIN = WM_USER+26;          (*  lParam = lprc *)
  TTM_GETMARGIN = WM_USER+27;          (*  lParam = lprc *)

  TTN_GETDISPINFOA = TTN_FIRST-0;
  TTN_NEEDTEXTA = TTN_GETDISPINFOA;    
  TTN_GETDISPINFO = TTN_GETDISPINFOA;  (* ! A *)
  TTN_GETDISPINFOW = TTN_FIRST-10;
  TTN_NEEDTEXTW = TTN_GETDISPINFOW;
  TTN_SHOW = TTN_FIRST-1;
  TTN_POP = TTN_FIRST-2;

(* ====== STATUS BAR CONTROL =================================================== *)
  SBARS_SIZEGRIP = 100H;
  STATUSCLASSNAME = 'msctls_statusbar';
  SB_SETTEXTA = WM_USER+1;
  SB_SETTEXT = SB_SETTEXTA;     (* ! A *)
  SB_SETTEXTW = WM_USER+11;
  SB_GETTEXTA = WM_USER+2;
  SB_GETTEXT = SB_GETTEXTA;    (* ! A *)
  SB_GETTEXTW = WM_USER+13;
  SB_GETTEXTLENGTHA = WM_USER+3;
  SB_GETTEXTLENGTH = SB_GETTEXTLENGTHA;   (* ! A *)
  SB_GETTEXTLENGTHW = WM_USER+12;
  SB_SETPARTS = WM_USER+4;
  SB_GETPARTS = WM_USER+6;
  SB_GETBORDERS = WM_USER+7;
  SB_SETMINHEIGHT = WM_USER+8;
  SB_SIMPLE = WM_USER+9;
  SB_GETRECT = WM_USER+10;
  SB_ISSIMPLE = WM_USER+14;
  SBT_OWNERDRAW = 1000H;
  SBT_NOBORDERS = 100H;
  SBT_POPOUT = 200H;
  SBT_RTLREADING = 400H;

(* ====== TRACKBAR CONTROL ===================================================== *)
 
  TRACKBAR_CLASS = 'msctls_trackbar';
  TBS_AUTOTICKS = 1H;
  TBS_VERT = 2H;
  TBS_HORZ = 0H;
  TBS_TOP = 4H;
  TBS_BOTTOM = 0H;
  TBS_LEFT = 4H;
  TBS_RIGHT = 0H;
  TBS_BOTH = 8H;
  TBS_NOTICKS = 10H;
  TBS_ENABLESELRANGE = 20H;
  TBS_FIXEDLENGTH = 40H;
  TBS_NOTHUMB = 80H;
  TBS_TOOLTIPS = 100H;
  TBM_GETPOS = WM_USER;
  TBM_GETRANGEMIN = WM_USER+1;
  TBM_GETRANGEMAX = WM_USER+2;
  TBM_GETTIC = WM_USER+3;
  TBM_SETTIC = WM_USER+4;
  TBM_SETPOS = WM_USER+5;
  TBM_SETRANGE = WM_USER+6;
  TBM_SETRANGEMIN = WM_USER+7;
  TBM_SETRANGEMAX = WM_USER+8;
  TBM_CLEARTICS = WM_USER+9;
  TBM_SETSEL = WM_USER+10;
  TBM_SETSELSTART = WM_USER+11;
  TBM_SETSELEND = WM_USER+12;
  TBM_GETPTICS = WM_USER+14;
  TBM_GETTICPOS = WM_USER+15;
  TBM_GETNUMTICS = WM_USER+16;
  TBM_GETSELSTART = WM_USER+17;
  TBM_GETSELEND = WM_USER+18;
  TBM_CLEARSEL = WM_USER+19;
  TBM_SETTICFREQ = WM_USER+20;
  TBM_SETPAGESIZE = WM_USER+21;
  TBM_GETPAGESIZE = WM_USER+22;
  TBM_SETLINESIZE = WM_USER+23;
  TBM_GETLINESIZE = WM_USER+24;
  TBM_GETTHUMBRECT = WM_USER+25;
  TBM_GETCHANNELRECT = WM_USER+26;
  TBM_SETTHUMBLENGTH = WM_USER+27;
  TBM_GETTHUMBLENGTH = WM_USER+28;
  TBM_SETTOOLTIPS = WM_USER+29;
  TBM_GETTOOLTIPS = WM_USER+30;
  TBM_SETTIPSIDE = WM_USER+31;

(*  TrackBar Tip Side flags *)
  TBTS_TOP = 0;
  TBTS_LEFT = 1;
  TBTS_BOTTOM = 2;
  TBTS_RIGHT = 3;
  TBM_SETBUDDY = WM_USER+32;           (*  wparam = BOOL fLeft; (or right) *)
  TBM_GETBUDDY = WM_USER+33;           (*  wparam = BOOL fLeft; (or right) *)
  TB_LINEUP = 0;
  TB_LINEDOWN = 1;
  TB_PAGEUP = 2;
  TB_PAGEDOWN = 3;
  TB_THUMBPOSITION = 4;
  TB_THUMBTRACK = 5;
  TB_TOP = 6;
  TB_BOTTOM = 7;
  TB_ENDTRACK = 8;

(*  custom draw item specs *)
  TBCD_TICS = 1H;
  TBCD_THUMB = 2H;
  TBCD_CHANNEL = 3H;
 
  DL_BEGINDRAG = WM_USER+133;
  DL_DRAGGING = WM_USER+134;
  DL_DROPPED = WM_USER+135;
  DL_CANCELDRAG = WM_USER+136;
  DL_CURSORSET = 0;
  DL_STOPCURSOR = 1;
  DL_COPYCURSOR = 2;
  DL_MOVECURSOR = 3;

(* ====== UPDOWN CONTROL ======================================================= *)
  UPDOWN_CLASS = 'msctls_updown';

  UD_MAXVAL = 7FFFH;
  UD_MINVAL = -UD_MAXVAL;
  UDS_WRAP = 1H;
  UDS_SETBUDDYINT = 2H;
  UDS_ALIGNRIGHT = 4H;
  UDS_ALIGNLEFT = 8H;
  UDS_AUTOBUDDY = 10H;
  UDS_ARROWKEYS = 20H;
  UDS_HORZ = 40H;
  UDS_NOTHOUSANDS = 80H;
  UDS_HOTTRACK = 100H;
  UDM_SETRANGE = WM_USER+101;
  UDM_GETRANGE = WM_USER+102;
  UDM_SETPOS = WM_USER+103;
  UDM_GETPOS = WM_USER+104;
  UDM_SETBUDDY = WM_USER+105;
  UDM_GETBUDDY = WM_USER+106;
  UDM_SETACCEL = WM_USER+107;
  UDM_GETACCEL = WM_USER+108;
  UDM_SETBASE = WM_USER+109;
  UDM_GETBASE = WM_USER+110;
 
  UDN_DELTAPOS = UDN_FIRST-1;

(* ====== PROGRESS CONTROL ===================================================== *)
  PROGRESS_CLASS = 'msctls_progress';
  PBS_SMOOTH = 1H;
  PBS_VERTICAL = 4H;
  PBM_SETRANGE = WM_USER+1;
  PBM_SETPOS = WM_USER+2;
  PBM_DELTAPOS = WM_USER+3;
  PBM_SETSTEP = WM_USER+4;
  PBM_STEPIT = WM_USER+5;
  PBM_SETRANGE32 = WM_USER+6;          (*  lParam = high; wParam = low *)
  PBM_GETRANGE = WM_USER+7;            (*  wParam = return (TRUE ? low : high). lParam = PPBRANGE or NULL *)
  PBM_GETPOS = WM_USER+8;

(* ====== HOTKEY CONTROL ======================================================= *)
  HOTKEYF_SHIFT = 1H;
  HOTKEYF_CONTROL = 2H;
  HOTKEYF_ALT = 4H;
  HOTKEYF_EXT = 8H;
  HKCOMB_NONE = 1H;
  HKCOMB_S = 2H;
  HKCOMB_C = 4H;
  HKCOMB_A = 8H;
  HKCOMB_SC = 10H;
  HKCOMB_SA = 20H;
  HKCOMB_CA = 40H;
  HKCOMB_SCA = 80H;
  HKM_SETHOTKEY = WM_USER+1;
  HKM_GETHOTKEY = WM_USER+2;
  HKM_SETRULES = WM_USER+3;
  HOTKEY_CLASS = 'msctls_hotkey';

(* ====== COMMON CONTROL STYLES ================================================ *)
  CCS_TOP = 1H;
  CCS_NOMOVEY = 2H;
  CCS_BOTTOM = 3H;
  CCS_NORESIZE = 4H;
  CCS_NOPARENTALIGN = 8H;
  CCS_ADJUSTABLE = 20H;
  CCS_NODIVIDER = 40H;
  CCS_VERT = 80H;
  CCS_LEFT = 129;
  CCS_RIGHT = 131;
  CCS_NOMOVEX = 130;

(* ====== LISTVIEW CONTROL ===================================================== *)
  WC_LISTVIEW = 'SysListView';
  LVS_ICON = 0H;
  LVS_REPORT = 1H;
  LVS_SMALLICON = 2H;
  LVS_LIST = 3H;
  LVS_TYPEMASK = 3H;
  LVS_SINGLESEL = 4H;
  LVS_SHOWSELALWAYS = 8H;
  LVS_SORTASCENDING = 10H;
  LVS_SORTDESCENDING = 20H;
  LVS_SHAREIMAGELISTS = 40H;
  LVS_NOLABELWRAP = 80H;
  LVS_AUTOARRANGE = 100H;
  LVS_EDITLABELS = 200H;
  LVS_OWNERDATA = 1000H;
  LVS_NOSCROLL = 2000H;
  LVS_TYPESTYLEMASK = 0FC00H;
  LVS_ALIGNTOP = 0H;
  LVS_ALIGNLEFT = 800H;
  LVS_ALIGNMASK = 0C00H;
  LVS_OWNERDRAWFIXED = 400H;
  LVS_NOCOLUMNHEADER = 4000H;
  LVS_NOSORTHEADER = 8000H;
  LVM_GETBKCOLOR = LVM_FIRST+0;
 
  LVM_SETBKCOLOR = LVM_FIRST+1;
 
  LVM_GETIMAGELIST = LVM_FIRST+2;
 
  LVSIL_NORMAL = 0;
  LVSIL_SMALL = 1;
  LVSIL_STATE = 2;
  LVM_SETIMAGELIST = LVM_FIRST+3;

  LVM_GETITEMCOUNT = LVM_FIRST+4;
 
  LVIF_TEXT = 1H;
  LVIF_IMAGE = 2H;
  LVIF_PARAM = 4H;
  LVIF_STATE = 8H;
  LVIF_INDENT = 10H;
  LVIF_NORECOMPUTE = 800H;
  LVIS_FOCUSED = 1H;
  LVIS_SELECTED = 2H;
  LVIS_CUT = 4H;
  LVIS_DROPHILITED = 8H;
  LVIS_OVERLAYMASK = 0F00H;
  LVIS_STATEIMAGEMASK = 0F000H;

  I_INDENTCALLBACK = -1;
 
  LPSTR_TEXTCALLBACKW = -1;
  LPSTR_TEXTCALLBACKA = -1;
  LPSTR_TEXTCALLBACK = LPSTR_TEXTCALLBACKA;   (* ! A *)
  I_IMAGECALLBACK = -1;
  LVM_GETITEMA = LVM_FIRST+5;
  LVM_GETITEM = LVM_GETITEMA;     (* ! A *)
  LVM_GETITEMW = LVM_FIRST+75;
  LVM_SETITEMA = LVM_FIRST+6;
  LVM_SETITEM = LVM_SETITEMA;     (* ! A *)
  LVM_SETITEMW = LVM_FIRST+76;
  LVM_INSERTITEMA = LVM_FIRST+7;
  LVM_INSERTITEM = LVM_INSERTITEMA;   (* ! A *)
  LVM_INSERTITEMW = LVM_FIRST+77;
  LVM_DELETEITEM = LVM_FIRST+8;
  LVM_DELETEALLITEMS = LVM_FIRST+9;
  LVM_GETCALLBACKMASK = LVM_FIRST+10;
  LVM_SETCALLBACKMASK = LVM_FIRST+11;
 
  LVNI_ALL = 0H;
  LVNI_FOCUSED = 1H;
  LVNI_SELECTED = 2H;
  LVNI_CUT = 4H;
  LVNI_DROPHILITED = 8H;
  LVNI_ABOVE = 100H;
  LVNI_BELOW = 200H;
  LVNI_TOLEFT = 400H;
  LVNI_TORIGHT = 800H;
  LVM_GETNEXTITEM = LVM_FIRST+12;
 
  LVFI_PARAM = 1H;
  LVFI_STRING = 2H;
  LVFI_PARTIAL = 8H;
  LVFI_WRAP = 20H;
  LVFI_NEARESTXY = 40H;

  LVM_FINDITEMA = LVM_FIRST+13;
  LVM_FINDITEM = LVM_FINDITEMA;   (* ! A *)
  LVM_FINDITEMW = LVM_FIRST+83;
 
  LVIR_BOUNDS = 0;
  LVIR_ICON = 1;
  LVIR_LABEL = 2;
  LVIR_SELECTBOUNDS = 3;
  LVM_GETITEMRECT = LVM_FIRST+14;
 
  LVM_SETITEMPOSITION = LVM_FIRST+15;
 
  LVM_GETITEMPOSITION = LVM_FIRST+16;
 
  LVM_GETSTRINGWIDTHA = LVM_FIRST+17;
  LVM_GETSTRINGWIDTH = LVM_GETSTRINGWIDTHA;   (* ! A *)
  LVM_GETSTRINGWIDTHW = LVM_FIRST+87;
 
  LVHT_NOWHERE = 1H;
  LVHT_ONITEMICON = 2H;
  LVHT_ONITEMLABEL = 4H;
  LVHT_ONITEMSTATEICON = 8H;
  LVHT_ONITEM = 14;
  LVHT_ABOVE = 8H;
  LVHT_BELOW = 10H;
  LVHT_TORIGHT = 20H;
  LVHT_TOLEFT = 40H;
 
  LVM_HITTEST = LVM_FIRST+18;
  LVM_ENSUREVISIBLE = LVM_FIRST+19;
  LVM_SCROLL = LVM_FIRST+20;
  LVM_REDRAWITEMS = LVM_FIRST+21;
  LVA_DEFAULT = 0H;
  LVA_ALIGNLEFT = 1H;
  LVA_ALIGNTOP = 2H;
  LVA_SNAPTOGRID = 5H;
  LVM_ARRANGE = LVM_FIRST+22;
  LVM_EDITLABELA = LVM_FIRST+23;
  LVM_EDITLABEL = LVM_EDITLABELA;  (* ! A *)
  LVM_EDITLABELW = LVM_FIRST+118;
  LVM_GETEDITCONTROL = LVM_FIRST+24;
 
  LVCF_FMT = 1H;
  LVCF_WIDTH = 2H;
  LVCF_TEXT = 4H;
  LVCF_SUBITEM = 8H;
  LVCF_IMAGE = 10H;
  LVCF_ORDER = 20H;
  LVCFMT_LEFT = 0H;
  LVCFMT_RIGHT = 1H;
  LVCFMT_CENTER = 2H;
  LVCFMT_JUSTIFYMASK = 3H;
  LVCFMT_IMAGE = 800H;
  LVCFMT_BITMAP_ON_RIGHT = 1000H;
  LVCFMT_COL_HAS_IMAGES = 8000H;
  LVM_GETCOLUMNA = LVM_FIRST+25;
  LVM_GETCOLUMN = LVM_GETCOLUMNA;  (* ! A *)
  LVM_GETCOLUMNW = LVM_FIRST+95;
  LVM_SETCOLUMNA = LVM_FIRST+26;
  LVM_SETCOLUMN = LVM_SETCOLUMNA;  (* ! A *)
  LVM_SETCOLUMNW = LVM_FIRST+96;
  LVM_INSERTCOLUMNA = LVM_FIRST+27;
  LVM_INSERTCOLUMN = LVM_INSERTCOLUMNA;  (* ! A *)
  LVM_INSERTCOLUMNW = LVM_FIRST+97;
  LVM_DELETECOLUMN = LVM_FIRST+28;
  LVM_GETCOLUMNWIDTH = LVM_FIRST+29;
  LVSCW_AUTOSIZE = -1;
  LVSCW_AUTOSIZE_USEHEADER = -2;
  LVM_SETCOLUMNWIDTH = LVM_FIRST+30;
  LVM_CREATEDRAGIMAGE = LVM_FIRST+33;
  LVM_GETVIEWRECT = LVM_FIRST+34;
  LVM_GETTEXTCOLOR = LVM_FIRST+35;
  LVM_SETTEXTCOLOR = LVM_FIRST+36;
  LVM_GETTEXTBKCOLOR = LVM_FIRST+37;
  LVM_SETTEXTBKCOLOR = LVM_FIRST+38;
  LVM_GETTOPINDEX = LVM_FIRST+39;
  LVM_GETCOUNTPERPAGE = LVM_FIRST+40;
  LVM_GETORIGIN = LVM_FIRST+41;
  LVM_UPDATE = LVM_FIRST+42;
  LVM_SETITEMSTATE = LVM_FIRST+43;
  LVM_GETITEMSTATE = LVM_FIRST+44;
  LVM_GETITEMTEXTA = LVM_FIRST+45;
  LVM_GETITEMTEXT = LVM_GETITEMTEXTA;  (* ! A *)
  LVM_GETITEMTEXTW = LVM_FIRST+115;
  LVM_SETITEMTEXTA = LVM_FIRST+46;
  LVM_SETITEMTEXT = LVM_SETITEMTEXTA;  (* ! A *)
  LVM_SETITEMTEXTW = LVM_FIRST+116;
(*  these flags only apply to LVS_OWNERDATA listviews in report or list mode *)
  LVSICF_NOINVALIDATEALL = 1H;
  LVSICF_NOSCROLL = 2H;
  LVM_SETITEMCOUNT = LVM_FIRST+47;
  LVM_SORTITEMS = LVM_FIRST+48;
  LVM_SETITEMPOSITION32 = LVM_FIRST+49;
  LVM_GETSELECTEDCOUNT = LVM_FIRST+50;
  LVM_GETITEMSPACING = LVM_FIRST+51;
  LVM_GETISEARCHSTRINGA = LVM_FIRST+52;
  LVM_GETISEARCHSTRING = LVM_GETISEARCHSTRINGA;   (* ! A *)
  LVM_GETISEARCHSTRINGW = LVM_FIRST+117;
  LVM_SETICONSPACING = LVM_FIRST+53;
  LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST+54;
  LVM_GETEXTENDEDLISTVIEWSTYLE = LVM_FIRST+55;
  LVS_EX_GRIDLINES = 99H;
  LVS_EX_SUBITEMIMAGES = 99H;
  LVS_EX_CHECKBOXES = 99H;
  LVS_EX_TRACKSELECT = 99H;
  LVS_EX_HEADERDRAGDROP = 99H;
  LVS_EX_FULLROWSELECT = 99H;          (*  applies to report mode only *)
  LVS_EX_ONECLICKACTIVATE = 99H;
  LVS_EX_TWOCLICKACTIVATE = 99H;
  LVM_GETSUBITEMRECT = LVM_FIRST+56;
  LVM_SUBITEMHITTEST = LVM_FIRST+57;
  LVM_SETCOLUMNORDERARRAY = LVM_FIRST+58;
  LVM_GETCOLUMNORDERARRAY = LVM_FIRST+59;
  LVM_SETHOTITEM = LVM_FIRST+60;
  LVM_GETHOTITEM = LVM_FIRST+61;
  LVM_SETHOTCURSOR = LVM_FIRST+62;
  LVM_GETHOTCURSOR = LVM_FIRST+63;
  LVM_APPROXIMATEVIEWRECT = LVM_FIRST+64;
 
  LVN_ITEMCHANGING = LVN_FIRST-0;
  LVN_ITEMCHANGED = LVN_FIRST-1;
  LVN_INSERTITEM = LVN_FIRST-2;
  LVN_DELETEITEM = LVN_FIRST-3;
  LVN_DELETEALLITEMS = LVN_FIRST-4;
  LVN_BEGINLABELEDITA = LVN_FIRST-5;
  LVN_BEGINLABELEDIT = LVN_BEGINLABELEDITA;   (* ! A *)
  LVN_BEGINLABELEDITW = LVN_FIRST-75;
  LVN_ENDLABELEDITA = LVN_FIRST-6;
  LVN_ENDLABELEDIT = LVN_ENDLABELEDITA;     (* ! A *)
  LVN_ENDLABELEDITW = LVN_FIRST-76;
  LVN_COLUMNCLICK = LVN_FIRST-8;
  LVN_BEGINDRAG = LVN_FIRST-9;
  LVN_BEGINRDRAG = LVN_FIRST-11;
  LVN_ODCACHEHINT = LVN_FIRST-13;
  LVN_ODFINDITEMA = LVN_FIRST-52;
  LVN_ODFINDITEM = LVN_ODFINDITEMA;    (* ! A *)
  LVN_ODFINDITEMW = LVN_FIRST-79;
  LVN_ITEMACTIVATE = LVN_FIRST-14;
  LVN_GETDISPINFOA = LVN_FIRST-50;
  LVN_GETDISPINFO = LVN_GETDISPINFOA;  (* ! A *)
  LVN_GETDISPINFOW = LVN_FIRST-77;
  LVN_SETDISPINFOA = LVN_FIRST-51;
  LVN_SETDISPINFO = LVN_SETDISPINFOA;  (* ! A *)
  LVN_SETDISPINFOW = LVN_FIRST-78;
  LVIF_DI_SETITEM = 1000H;
 
  LVN_KEYDOWN = LVN_FIRST-55;
  LVN_MARQUEEBEGIN = LVN_FIRST-56;

(* ====== TREEVIEW CONTROL ===================================================== *)
  WC_TREEVIEW = 'SysTreeView';
  TVS_HASBUTTONS = 1H;
  TVS_HASLINES = 2H;
  TVS_LINESATROOT = 4H;
  TVS_EDITLABELS = 8H;
  TVS_DISABLEDRAGDROP = 10H;
  TVS_SHOWSELALWAYS = 20H;
  TVS_SHAREDIMAGELISTS = 0H;
  TVS_PRIVATEIMAGELISTS = 40H;
  TVS_NOTOOLTIPS = 80H;
  TVS_CHECKBOXES = 100H;
  TVS_TRACKSELECT = 200H;
 
  TVIF_TEXT = 1H;
  TVIF_IMAGE = 2H;
  TVIF_PARAM = 4H;
  TVIF_STATE = 8H;
  TVIF_HANDLE = 10H;
  TVIF_SELECTEDIMAGE = 20H;
  TVIF_CHILDREN = 40H;
  TVIS_SELECTED = 2H;
  TVIS_CUT = 4H;
  TVIS_DROPHILITED = 8H;
  TVIS_BOLD = 10H;
  TVIS_EXPANDED = 20H;
  TVIS_EXPANDEDONCE = 40H;
  TVIS_EXPANDPARTIAL = 80H;
  TVIS_OVERLAYMASK = 0F00H;
  TVIS_STATEIMAGEMASK = 0F000H;
  TVIS_USERMASK = 0F000H;
  I_CHILDRENCALLBACK = -1;

  TVI_ROOT  = -65535; (* 0FFFF0000H *)
  TVI_FIRST = -65534; (* 0FFFF0001H *)
  TVI_LAST  = -65533; (* 0FFFF0002H *)
  TVI_SORT  = -65532; (* 0FFFF0003H *)
 
  TVM_INSERTITEMA = TV_FIRST+0;
  TVM_INSERTITEM = TVM_INSERTITEMA;   (* ! A *)
  TVM_INSERTITEMW = TV_FIRST+50;
  TVM_DELETEITEM = TV_FIRST+1;
  TVM_EXPAND = TV_FIRST+2;
  TVE_COLLAPSE = 1H;
  TVE_EXPAND = 2H;
  TVE_TOGGLE = 3H;
  TVE_EXPANDPARTIAL = 4000H;
  TVE_COLLAPSERESET = 8000H;
  TVM_GETITEMRECT = TV_FIRST+4;
  TVM_GETCOUNT = TV_FIRST+5;
  TVM_GETINDENT = TV_FIRST+6;
  TVM_SETINDENT = TV_FIRST+7;
  TVM_GETIMAGELIST = TV_FIRST+8;
  TVSIL_NORMAL = 0;
  TVSIL_STATE = 2;
  TVM_SETIMAGELIST = TV_FIRST+9;
  TVM_GETNEXTITEM = TV_FIRST+10;
  TVGN_ROOT = 0H;
  TVGN_NEXT = 1H;
  TVGN_PREVIOUS = 2H;
  TVGN_PARENT = 3H;
  TVGN_CHILD = 4H;
  TVGN_FIRSTVISIBLE = 5H;
  TVGN_NEXTVISIBLE = 6H;
  TVGN_PREVIOUSVISIBLE = 7H;
  TVGN_DROPHILITE = 8H;
  TVGN_CARET = 9H;
  TVM_SELECTITEM = TV_FIRST+11;
  TVM_GETITEMA = TV_FIRST+12;
  TVM_GETITEM = TVM_GETITEMA;   (* ! A *)
  TVM_GETITEMW = TV_FIRST+62;
  TVM_SETITEMA = TV_FIRST+13;
  TVM_SETITEM = TVM_SETITEMA;    (* ! A *)
  TVM_SETITEMW = TV_FIRST+63;
  TVM_EDITLABELA = TV_FIRST+14;
  TVM_EDITLABEL = TVM_EDITLABELA;  (* ! A *)
  TVM_EDITLABELW = TV_FIRST+65;
  TVM_GETEDITCONTROL = TV_FIRST+15;
  TVM_GETVISIBLECOUNT = TV_FIRST+16;
  TVM_HITTEST = TV_FIRST+17;
  TVHT_NOWHERE = 1H;
  TVHT_ONITEMICON = 2H;
  TVHT_ONITEMLABEL = 4H;
  TVHT_ONITEMINDENT = 8H;
  TVHT_ONITEMBUTTON = 10H;
  TVHT_ONITEMRIGHT = 20H;
  TVHT_ONITEMSTATEICON = 40H;
  TVHT_ABOVE = 100H;
  TVHT_BELOW = 200H;
  TVHT_TORIGHT = 400H;
  TVHT_TOLEFT = 800H;
  TVM_CREATEDRAGIMAGE = TV_FIRST+18;
  TVM_SORTCHILDREN = TV_FIRST+19;
  TVM_ENSUREVISIBLE = TV_FIRST+20;
  TVM_SORTCHILDRENCB = TV_FIRST+21;
  TVM_ENDEDITLABELNOW = TV_FIRST+22;
  TVM_GETISEARCHSTRINGA = TV_FIRST+23;
  TVM_GETISEARCHSTRING = TVM_GETISEARCHSTRINGA;  (* ! A *)
  TVM_GETISEARCHSTRINGW = TV_FIRST+64;
  TVM_SETTOOLTIPS = TV_FIRST+24;
  TVM_GETTOOLTIPS = TV_FIRST+25;
  TVN_SELCHANGINGA = TVN_FIRST-1;
  TVN_SELCHANGING = TVN_SELCHANGINGA;  (* ! A *)
  TVN_SELCHANGINGW = TVN_FIRST-50;
  TVN_SELCHANGEDA = TVN_FIRST-2;
  TVN_SELCHANGED = TVN_SELCHANGEDA;     (* ! A *)
  TVN_SELCHANGEDW = TVN_FIRST-51;
  TVC_UNKNOWN = 0H;
  TVC_BYMOUSE = 1H;
  TVC_BYKEYBOARD = 2H;
  TVN_GETDISPINFOA = TVN_FIRST-3;
  TVN_GETDISPINFO = TVN_GETDISPINFOA;   (* ! A *)
  TVN_GETDISPINFOW = TVN_FIRST-52;
  TVN_SETDISPINFOA = TVN_FIRST-4;
  TVN_SETDISPINFO = TVN_SETDISPINFOA;    (* ! A *)
  TVN_SETDISPINFOW = TVN_FIRST-53;
  TVIF_DI_SETITEM = 1000H;
 
  TVN_ITEMEXPANDINGA = TVN_FIRST-5;
  TVN_ITEMEXPANDING = TVN_ITEMEXPANDINGA;  (* ! A *)
  TVN_ITEMEXPANDINGW = TVN_FIRST-54;
  TVN_ITEMEXPANDEDA = TVN_FIRST-6;
  TVN_ITEMEXPANDED = TVN_ITEMEXPANDEDA;     (* ! A *)
  TVN_ITEMEXPANDEDW = TVN_FIRST-55;
  TVN_BEGINDRAGA = TVN_FIRST-7;
  TVN_BEGINDRAG = TVN_BEGINDRAGA;     (* ! A *)
  TVN_BEGINDRAGW = TVN_FIRST-56;
  TVN_BEGINRDRAGA = TVN_FIRST-8;
  TVN_BEGINRDRAG = TVN_BEGINRDRAGA;     (* ! A *)
  TVN_BEGINRDRAGW = TVN_FIRST-57;
  TVN_DELETEITEMA = TVN_FIRST-9;
  TVN_DELETEITEM = TVN_DELETEITEMA;     (* ! A *)
  TVN_DELETEITEMW = TVN_FIRST-58;
  TVN_BEGINLABELEDITA = TVN_FIRST-10;
  TVN_BEGINLABELEDIT = TVN_BEGINLABELEDITA;   (* ! A *)
  TVN_BEGINLABELEDITW = TVN_FIRST-59;
  TVN_ENDLABELEDITA = TVN_FIRST-11;
  TVN_ENDLABELEDIT = TVN_ENDLABELEDITA;  (* ! A *)
  TVN_ENDLABELEDITW = TVN_FIRST-60;
  TVN_KEYDOWN = TVN_FIRST-12;

(* //////////////////  ComboBoxEx //////////////////////////////// *)

  WC_COMBOBOXEXA = 'ComboBoxEx32';
  WC_COMBOBOXEX = WC_COMBOBOXEXA;    (* ! A *)
  CBEIF_TEXT = 1H;
  CBEIF_IMAGE = 2H;
  CBEIF_SELECTEDIMAGE = 4H;
  CBEIF_OVERLAY = 8H;
  CBEIF_INDENT = 10H;
  CBEIF_LPARAM = 20H;
  CBEIF_DI_SETITEM = 10000000H;
  CBEM_INSERTITEMA = WM_USER+1;
  CBEM_INSERTITEM = CBEM_INSERTITEMA;   (* ! A *)
  CBEM_SETIMAGELIST = WM_USER+2;
  CBEM_GETIMAGELIST = WM_USER+3;
  CBEM_GETITEMA = WM_USER+4;
  CBEM_GETITEM = CBEM_GETITEMA;       (* ! A *)
  CBEM_SETITEMA = WM_USER+5;
  CBEM_SETITEM = CBEM_SETITEMA;       (* ! A *)
  CBEM_GETCOMBOCONTROL = WM_USER+6;
  CBEM_GETEDITCONTROL = WM_USER+7;
  CBEM_SETEXSTYLE = WM_USER+8;
  CBEM_GETEXSTYLE = WM_USER+9;
  CBEM_HASEDITCHANGED = WM_USER+10;
  CBEM_INSERTITEMW = WM_USER+11;
  CBEM_SETITEMW = WM_USER+12;
  CBEM_GETITEMW = WM_USER+13;
  CBES_EX_NOEDITIMAGE = 1H;
  CBES_EX_NOEDITIMAGEINDENT = 2H;
  CBES_EX_PATHWORDBREAKPROC = 4H;
  CBEN_GETDISPINFO = CBEN_FIRST-0;
  CBEN_INSERTITEM = CBEN_FIRST-1;
  CBEN_DELETEITEM = CBEN_FIRST-2;
  CBEN_BEGINEDIT = CBEN_FIRST-4;
  CBEN_ENDEDITA = CBEN_FIRST-5;
  CBEN_ENDEDIT = CBEN_ENDEDITA;      (* ! A *)
  CBEN_ENDEDITW = CBEN_FIRST-6;

(*  lParam specifies why the endedit is happening *)
  CBENF_KILLFOCUS = 1;
  CBENF_RETURN = 2;
  CBENF_ESCAPE = 3;
  CBENF_DROPDOWN = 4;
  CBEMAXSTRLEN = 260;
(* ====== TAB CONTROL ========================================================== *)

  WC_TABCONTROL = 'SysTabControl';
  TCS_SCROLLOPPOSITE = 1H;             (*  assumes multiline tab *)
  TCS_BOTTOM = 2H;
  TCS_RIGHT = 2H;
  TCS_FORCEICONLEFT = 10H;
  TCS_FORCELABELLEFT = 20H;
  TCS_HOTTRACK = 40H;
  TCS_VERTICAL = 80H;                  (*  only valid with multiline mode *)
  TCS_TABS = 0H;
  TCS_BUTTONS = 100H;
  TCS_SINGLELINE = 0H;
  TCS_MULTILINE = 200H;
  TCS_RIGHTJUSTIFY = 0H;
  TCS_FIXEDWIDTH = 400H;
  TCS_RAGGEDRIGHT = 800H;
  TCS_FOCUSONBUTTONDOWN = 1000H;
  TCS_OWNERDRAWFIXED = 2000H;
  TCS_TOOLTIPS = 4000H;
  TCS_FOCUSNEVER = 8000H;
  TCM_FIRST = 1300H;
  TCM_GETIMAGELIST = TCM_FIRST+2;
  TCM_SETIMAGELIST = TCM_FIRST+3;
  TCM_GETITEMCOUNT = TCM_FIRST+4;
  TCIF_TEXT = 1H;
  TCIF_IMAGE = 2H;
  TCIF_RTLREADING = 4H;
  TCIF_PARAM = 8H;
  TCIF_STATE = 10H;
  TCIS_BUTTONPRESSED = 1H;
  TCM_GETITEMA = TCM_FIRST+5;
  TCM_GETITEM = TCM_GETITEMA;     (* ! A *)
  TCM_GETITEMW = TCM_FIRST+60;
  TCM_SETITEMA = TCM_FIRST+6;
  TCM_SETITEM = TCM_SETITEMA;     (* ! A *)
  TCM_SETITEMW = TCM_FIRST+61;
  TCM_INSERTITEMA = TCM_FIRST+7;
  TCM_INSERTITEM = TCM_INSERTITEMA;    (* ! A *)
  TCM_INSERTITEMW = TCM_FIRST+62;
  TCM_DELETEITEM = TCM_FIRST+8;
  TCM_DELETEALLITEMS = TCM_FIRST+9;
  TCM_GETITEMRECT = TCM_FIRST+10;
  TCM_GETCURSEL = TCM_FIRST+11;
  TCM_SETCURSEL = TCM_FIRST+12;
  TCHT_NOWHERE = 1H;
  TCHT_ONITEMICON = 2H;
  TCHT_ONITEMLABEL = 4H;
  TCHT_ONITEM = 6;
  TCM_HITTEST = TCM_FIRST+13;
  TCM_SETITEMEXTRA = TCM_FIRST+14;
  TCM_ADJUSTRECT = TCM_FIRST+40;
  TCM_SETITEMSIZE = TCM_FIRST+41;
  TCM_REMOVEIMAGE = TCM_FIRST+42;
  TCM_SETPADDING = TCM_FIRST+43;
  TCM_GETROWCOUNT = TCM_FIRST+44;
  TCM_GETTOOLTIPS = TCM_FIRST+45;
  TCM_SETTOOLTIPS = TCM_FIRST+46;
  TCM_GETCURFOCUS = TCM_FIRST+47;
  TCM_SETCURFOCUS = TCM_FIRST+48;
  TCM_SETMINTABWIDTH = TCM_FIRST+49;
  TCM_DESELECTALL = TCM_FIRST+50;
  TCN_KEYDOWN = TCN_FIRST-0;
  TCN_SELCHANGE = TCN_FIRST-1;
  TCN_SELCHANGING = TCN_FIRST-2;


TYPE 
  INITCOMMONCONTROLSEX = RECORD [_NOTALIGNED]
    dwSize: WD.DWORD;          (*  size of this structure *)
    dwICC : WD.DWORD;          (*  flags indicating which classes to be initialized *)
  END;
  LPINITCOMMONCONTROLSEX = POINTER TO INITCOMMONCONTROLSEX;

  NMCUSTOMDRAWINFO = RECORD [_NOTALIGNED]
    hdr        : WU.NMHDR;
    dwDrawStage: WD.DWORD;
    hdc        : WD.HDC;
    rc         : WD.RECT;
    dwItemSpec : WD.DWORD;    (*  this is control specific; but it's how to specify an item.  valid only with CDDS_ITEM bit set *)
    uItemState : WD.UINT;
    lItemlParam: WD.LPARAM;
  END;
  NMCUSTOMDRAW = NMCUSTOMDRAWINFO;
  LPNMCUSTOMDRAW = POINTER TO NMCUSTOMDRAWINFO;

(*  for tooltips *)

  NMTTCUSTOMDRAW = RECORD [_NOTALIGNED]
    nmcd      : NMCUSTOMDRAW;
    uDrawFlags: WD.UINT;
  END;
  LPNMTTCUSTOMDRAW = POINTER TO NMTTCUSTOMDRAW;

  IMAGELIST = RECORD [_NOTALIGNED]
    (* Declaration without definition *)
  END;
  HIMAGELIST = POINTER TO IMAGELIST;

  IMAGELISTDRAWPARAMS = RECORD [_NOTALIGNED]
    cbSize : WD.DWORD;
    himl   : HIMAGELIST;
    i      : LONGINT;
    hdcDst : WD.HDC;
    x      : LONGINT;
    y      : LONGINT;
    cx     : LONGINT;
    cy     : LONGINT;
    xBitmap: LONGINT;               (*  x offest from the upperleft of bitmap *)
    yBitmap: LONGINT;               (*  y offset from the upperleft of bitmap *)
    rgbBk  : WD.COLORREF;
    rgbFg  : WD.COLORREF;
    fStyle : WD.UINT;
    dwRop  : WD.DWORD;
  END;
  LPIMAGELISTDRAWPARAMS = POINTER TO IMAGELISTDRAWPARAMS;

  HD_ITEMA = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    cxy       : LONGINT;
    pszText   : WD.LPSTR;
    hbm       : WD.HBITMAP;
    cchTextMax: LONGINT;
    fmt       : LONGINT;
    lParam    : WD.LPARAM;
    iImage    : LONGINT;              (*  index of bitmap in ImageList *)
    iOrder    : LONGINT;              (*  where to draw this item *)
  END;
  HDITEMA = HD_ITEMA;
  HDITEM = HD_ITEMA;   (* ! A *)
  HD_ITEM = HD_ITEMA;   (* ! A *)
  LPHDITEMA = POINTER TO HD_ITEMA;

  HD_ITEMW = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    cxy       : LONGINT;
    pszText   : WD.LPWSTR;
    hbm       : WD.HBITMAP;
    cchTextMax: LONGINT;
    fmt       : LONGINT;
    lParam    : WD.LPARAM;
    iImage    : LONGINT;              (*  index of bitmap in ImageList *)
    iOrder    : LONGINT;
  END;
  HDITEMW = HD_ITEMW;
  LPHDITEMW = POINTER TO HD_ITEMW;
  LPHDITEM = LPHDITEMW;

  PtrWINDOWPOS = LONGINT;  (*POINTER TO WU.WINDOWPOS;*)
  HD_LAYOUT = RECORD [_NOTALIGNED]
    prc  : WD.LPRECT;
    pwpos: PtrWINDOWPOS;
  END;
  HDLAYOUT = HD_LAYOUT;
  LPHDLAYOUT = POINTER TO HD_LAYOUT;

  HD_HITTESTINFO = RECORD [_NOTALIGNED]
    pt   : WD.POINT;
    flags: WD.UINT;
    iItem: LONGINT;
  END;
  HDHITTESTINFO = HD_HITTESTINFO;
  LPHDHITTESTINFO = POINTER TO HD_HITTESTINFO;
 
  NMHEADERA = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    iItem  : LONGINT;
    iButton: LONGINT;
    pitem  : LPHDITEMA;
  END;
  NMHEADER = NMHEADERA;     (* ! A *)
  HD_NOTIFYA = NMHEADERA;
  LPNMHEADERA = POINTER TO NMHEADERA;
  LPNMHEADER = LPNMHEADERA;   (* ! A *)

  NMHEADERW = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    iItem  : LONGINT;
    iButton: LONGINT;
    pitem  : LPHDITEMW;
  END;
  HD_NOTIFYW = NMHEADERW;
  LPNMHEADERW = POINTER TO NMHEADERW;

  NMHDDISPINFOW = RECORD [_NOTALIGNED]
    hdr       : WU.NMHDR;
    iItem     : LONGINT;
    mask      : WD.UINT;
    pszText   : WD.LPWSTR;
    cchTextMax: LONGINT;
    iImage    : LONGINT;
    lParam    : WD.LPARAM;
  END;
  LPNMHDDISPINFOW = POINTER TO NMHDDISPINFOW;

  NMHDDISPINFOA = RECORD [_NOTALIGNED]
    hdr       : WU.NMHDR;
    iItem     : LONGINT;
    mask      : WD.UINT;
    pszText   : WD.LPSTR;
    cchTextMax: LONGINT;
    iImage    : LONGINT;
    lParam    : WD.LPARAM;
  END;
  NMHDDISPINFO = NMHDDISPINFOA;   (* ! A *)
  LPNMHDDISPINFOA = POINTER TO NMHDDISPINFOA;
  LPNMHDDISPINFO = LPNMHDDISPINFOA;    (* ! A *)
 
  TBBUTTON = RECORD [_NOTALIGNED]
    iBitmap  : LONGINT;
    idCommand: LONGINT;
    fsState  : WD.BYTE;
    fsStyle  : WD.BYTE;
    dwData   : WD.DWORD;
    iString  : LONGINT;
  END;
  PTBBUTTON = POINTER TO TBBUTTON;
  LPTBBUTTON = POINTER TO TBBUTTON;
  LPCTBBUTTON = LPTBBUTTON;

  COLORMAP = RECORD [_NOTALIGNED]
    from: WD.COLORREF;
    to  : WD.COLORREF;
  END;
  LPCOLORMAP = POINTER TO COLORMAP;

  TBREPLACEBITMAP = RECORD [_NOTALIGNED]
    hInstOld: WD.HINSTANCE;
    nIDOld  : WD.UINT;
    hInstNew: WD.HINSTANCE;
    nIDNew  : WD.UINT;
    nButtons: LONGINT;
  END;

  LPTBREPLACEBITMAP = POINTER TO TBREPLACEBITMAP;

  REBARINFO = RECORD [_NOTALIGNED]
    cbSize : WD.UINT;
    fMask  : WD.UINT;
    fStyle : WD.UINT;
    himl   : HIMAGELIST;
    hbmBack: WD.HBITMAP;
  END;
  LPREBARINFO = POINTER TO REBARINFO;
 
  REBARBANDINFOA = RECORD [_NOTALIGNED]
    cbSize    : WD.UINT;
    fMask     : WD.UINT;
    fStyle    : WD.UINT;
    clrFore   : WD.COLORREF;
    clrBack   : WD.COLORREF;
    lpText    : WD.LPSTR;
    cch       : WD.UINT;
    iImage    : LONGINT;
    hwndChild : WD.HWND;
    cxMinChild: WD.UINT;
    cyMinChild: WD.UINT;
    cx        : WD.UINT;
  END;
  REBARBANDINFO = REBARBANDINFOA;     (* ! A *)
  LPREBARBANDINFOA = POINTER TO REBARBANDINFOA;
  LPREBARBANDINFO = LPREBARBANDINFOA;  (* ! A *)
  LPCREBARBANDINFOA = LPREBARBANDINFOA;
  LPCREBARBANDINFO = LPREBARBANDINFOA;   (* ! A *)

  REBARBANDINFOW = RECORD [_NOTALIGNED]
    cbSize    : WD.UINT;
    fMask     : WD.UINT;
    fStyle    : WD.UINT;
    clrFore   : WD.COLORREF;
    clrBack   : WD.COLORREF;
    lpText    : WD.LPWSTR;
    cch       : WD.UINT;
    iImage    : LONGINT;
    hwndChild : WD.HWND;
    cxMinChild: WD.UINT;
    cyMinChild: WD.UINT;
    cx        : WD.UINT;
  END;
  LPREBARBANDINFOW = POINTER TO REBARBANDINFOW;
  LPCREBARBANDINFOW = LPREBARBANDINFOW;
 
  TOOLINFOA = RECORD [_NOTALIGNED]
    cbSize  : WD.UINT;
    uFlags  : WD.UINT;
    hwnd    : WD.HWND;
    uId     : WD.UINT;
    rect    : WD.RECT;
    hinst   : WD.HINSTANCE;
    lpszText: WD.LPSTR;
  END;
  TTTOOLINFOA = TOOLINFOA;
  TTTOOLINFO = TOOLINFOA;   (* ! A *)
  PTOOLINFOA = POINTER TO TOOLINFOA;
  PTOOLINFO = PTOOLINFOA;   (* ! A *)
  LPTTTOOLINFOA = POINTER TO TOOLINFOA;
  LPTTTOOLINFO = LPTTTOOLINFOA;   (* ! A *)
  LPTOOLINFOA = LPTTTOOLINFOA;

  TOOLINFOW = RECORD [_NOTALIGNED]
    cbSize  : WD.UINT;
    uFlags  : WD.UINT;
    hwnd    : WD.HWND;
    uId     : WD.UINT;
    rect    : WD.RECT;
    hinst   : WD.HINSTANCE;
    lpszText: WD.LPWSTR;
  END;
  TTTOOLINFOW = TOOLINFOW;
  PTOOLINFOW = POINTER TO TOOLINFOW;
  LPTTTOOLINFOW = POINTER TO TOOLINFOW;
  LPTOOLINFOW = LPTTTOOLINFOW;

  TT_HITTESTINFOA = RECORD [_NOTALIGNED]
    hwnd: WD.HWND;
    pt  : WD.POINT;
    ti  : TTTOOLINFOA;
  END;
  TTHITTESTINFOA = TT_HITTESTINFOA;
  TTHITTESTINFO = TT_HITTESTINFOA;  (* ! A *)
  LPTTHITTESTINFOA = POINTER TO TT_HITTESTINFOA;
  LPTTHITTESTINFO = LPTTHITTESTINFOA;   (* ! A *)
  LPHITTESTINFOA = LPTTHITTESTINFOA;

  TT_HITTESTINFOW = RECORD [_NOTALIGNED]
    hwnd: WD.HWND;
    pt  : WD.POINT;
    ti  : TTTOOLINFOW;
  END;
  TTHITTESTINFOW = TT_HITTESTINFOW;
  LPTTHITTESTINFOW = POINTER TO TT_HITTESTINFOW;
  LPHITTESTINFOW = LPTTHITTESTINFOW;
 
  NMTTDISPIFNOA = RECORD [_NOTALIGNED]
    hdr     : WU.NMHDR;
    lpszText: WD.LPSTR;
    szText  : ARRAY 80 OF CHAR;
    hinst   : WD.HINSTANCE;
    uFlags  : WD.UINT;
    lParam  : WD.LPARAM;
  END;
  TOOLTIPTEXTA = NMTTDISPIFNOA;
  NMTTDISPINFO = NMTTDISPIFNOA;   (* ! A *)
  TOOLTIPTEXT = NMTTDISPIFNOA;
  LPNMTTDISPINFOA = POINTER TO NMTTDISPIFNOA;
  LPTOOLTIPTEXTA = LPNMTTDISPINFOA;
  LPNMTTDISPINFO = LPNMTTDISPINFOA;   (* ! A *)
  LPTOOLTIPTEXT = LPNMTTDISPINFOA;   (* ! A *)

  NMTTDISPINFOW = RECORD [_NOTALIGNED]
    hdr     : WU.NMHDR;
    lpszText: WD.LPWSTR;
    szText  : ARRAY 80 OF WD.WCHAR;
    hinst   : WD.HINSTANCE;
    uFlags  : WD.UINT;
    lParam  : WD.LPARAM;
  END;
  TOOLTIPTEXTW = NMTTDISPINFOW;
  LPNMTTDISPINFOW = POINTER TO NMTTDISPINFOW;
  LPTOOLTIPTEXTW = LPNMTTDISPINFOW;

  DRAGLISTINFO = RECORD [_NOTALIGNED]
    uNotification: WD.UINT;
    hWnd         : WD.HWND;
    ptCursor     : WD.POINT;
  END;
  LPDRAGLISTINFO = POINTER TO DRAGLISTINFO;

  UDACCEL = RECORD [_NOTALIGNED]
    nSec: WD.UINT;
    nInc: WD.UINT;
  END;
  LPUDACCEL = POINTER TO UDACCEL;

  NM_UPDOWN = RECORD [_NOTALIGNED]
    hdr   : WU.NMHDR;
    iPos  : LONGINT;
    iDelta: LONGINT;
  END;
  NMUPDOWN = NM_UPDOWN;
  LPNMUPDOWN = POINTER TO NM_UPDOWN;
  LPNM_UPDOWN = LPNMUPDOWN;

  PBRANGE = RECORD [_NOTALIGNED]
    iLow : LONGINT;
    iHigh: LONGINT;
  END;
  PPBRANGE = POINTER TO PBRANGE;
 
  LVITEMA = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    iItem     : LONGINT;
    iSubItem  : LONGINT;
    state     : WD.UINT;
    stateMask : WD.UINT;
    pszText   : WD.LPSTR;
    cchTextMax: LONGINT;
    iImage    : LONGINT;
    lParam    : WD.LPARAM;
    iIndent   : LONGINT;
  END;
  LV_ITEMA = LVITEMA;
  LVITEM = LVITEMA;   (* ! A *)
  LV_ITEM = LVITEMA;   (* ! A *)
  LPLVITEMA = POINTER TO LVITEMA;
  LPLVITEM = LPLVITEMA;    (* ! A *)

  LVITEMW = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    iItem     : LONGINT;
    iSubItem  : LONGINT;
    state     : WD.UINT;
    stateMask : WD.UINT;
    pszText   : WD.LPWSTR;
    cchTextMax: LONGINT;
    iImage    : LONGINT;
    lParam    : WD.LPARAM;
    iIndent   : LONGINT;
  END;
  LV_ITEMW = LVITEMW;
  LPLVITEMW = POINTER TO LVITEMW;
 
  LVFINDINFOA = RECORD [_NOTALIGNED]
    flags      : WD.UINT;
    psz        : WD.LPCSTR;
    lParam     : WD.LPARAM;
    pt         : WD.POINT;
    vkDirection: WD.UINT;
  END;
  LV_FINDINFOA = LVFINDINFOA;
  LVFINDINFO = LVFINDINFOA;      (* ! A *)
  LV_FINDINFO = LVFINDINFOA;    (* ! A *)
  LPFINDINFOA = POINTER TO LVFINDINFOA;

  LVFINDINFOW = RECORD [_NOTALIGNED]
    flags      : WD.UINT;
    psz        : WD.LPCWSTR;
    lParam     : WD.LPARAM;
    pt         : WD.POINT;
    vkDirection: WD.UINT;
  END;
  LV_FINDINFOW = LVFINDINFOW;
  LPFINDINFOW = POINTER TO LVFINDINFOW;

  LVHITTESTINFO = RECORD [_NOTALIGNED]
    pt      : WD.POINT;
    flags   : WD.UINT;
    iItem   : LONGINT;
    iSubItem: LONGINT;            (*  this is was NOT in win95.  valid only for LVM_SUBITEMHITTEST *)
  END;
  LV_HITTESTINFO = LVHITTESTINFO;
  LPLVHITTESTINFO = POINTER TO LVHITTESTINFO;

  LVCOLUMNA = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    fmt       : LONGINT;
    cx        : LONGINT;
    pszText   : WD.LPSTR;
    cchTextMax: LONGINT;
    iSubItem  : LONGINT;
    iImage    : LONGINT;
    iOrder    : LONGINT;
  END;
  LV_COLUMNA = LVCOLUMNA;
  LVCOLUMN = LVCOLUMNA;      (* ! A *)
  LV_COLUMN = LVCOLUMNA;    (* ! A *)
  LPLVCOLUMNA = POINTER TO LVCOLUMNA;
  LPLVCOLUMN = LPLVCOLUMNA;    (* ! A *)

  LVCOLUMNW = RECORD [_NOTALIGNED]
    mask      : WD.UINT;
    fmt       : LONGINT;
    cx        : LONGINT;
    pszText   : WD.LPWSTR;
    cchTextMax: LONGINT;
    iSubItem  : LONGINT;
    iImage    : LONGINT;
    iOrder    : LONGINT;
  END;
  LV_COLUMNW = LVCOLUMNW;
  LPLVCOLUMNW = POINTER TO LVCOLUMNW;
 
  PFNLVCOMPARE = PROCEDURE [_APICALL] ( l1:WD.LPARAM; l2:WD.LPARAM; l3:WD.LPARAM ): LONGINT;

  NMLISTVIEW = RECORD [_NOTALIGNED]
    hdr      : WU.NMHDR;
    iItem    : LONGINT;
    iSubItem : LONGINT;
    uNewState: WD.UINT;
    uOldState: WD.UINT;
    uChanged : WD.UINT;
    ptAction : WD.POINT;
    lParam   : WD.LPARAM;
  END;
  NM_LISTVIEW = NMLISTVIEW;
  LPNMLISTVIEW = POINTER TO NMLISTVIEW;
  LPNM_LISTVIEW = LPNMLISTVIEW;

  NMLVCUSTOMDRAW = RECORD [_NOTALIGNED]
    nmcd     : NMCUSTOMDRAW;
    clrText  : WD.COLORREF;
    clrTextBk: WD.COLORREF;
  END;
  LPNMLVCUSTOMDRAW = POINTER TO NMLVCUSTOMDRAW;


  NMLVCACHEHINT = NM_UPDOWN;
  NM_CACHEHINT = NM_UPDOWN;
  LPNMLVCACHEHINT = LPNMUPDOWN;
  PNM_CACHEHINT = LPNMUPDOWN;
  LPNM_CACHEHINT = LPNMUPDOWN;

  NMLVFINDITEM = RECORD [_NOTALIGNED]
    hdr   : WU.NMHDR;
    iStart: LONGINT;
    lvfi  : LVFINDINFOA;
  END;
  NM_FINDITEM = NMLVFINDITEM;
  LPNMLVFINDITEM = POINTER TO NMLVFINDITEM;
  PNM_FINDITEM = LPNMLVFINDITEM;
  LPNM_FINDITEM = LPNMLVFINDITEM;
 
  LVDISPINFO = RECORD [_NOTALIGNED]   (* ! A *)
    hdr : WU.NMHDR;
    item: LVITEMA;
  END;
  NMLVDISPINFOA = LVDISPINFO;
  NMLVDISPINFO = LVDISPINFO;  (* ! A *)
  LV_DISPINFOA = LVDISPINFO;
  LPNMLVDISPINFOA = POINTER TO LVDISPINFO;

  LVDISPINFOW = RECORD [_NOTALIGNED]
    hdr : WU.NMHDR;
    item: LVITEMW;
  END;
  NMLVDISPINFOW = LVDISPINFOW;
  LV_DISPINFOW = LVDISPINFOW;
  LPNMLVDISPINFOW = POINTER TO LVDISPINFOW;
 
  LVKEYDOWN = RECORD [_NOTALIGNED]
    hdr  : WU.NMHDR;
    wVKey: WD.WORD;
    flags: WD.UINT;
  END;
  NMLVKEYDOWN = LVKEYDOWN;
  LV_KEYDOWN = LVKEYDOWN;
  LPNMLVKEYDOWN = POINTER TO LVKEYDOWN;
 
  TREEITEM = IMAGELIST;
  HTREEITEM = POINTER TO TREEITEM;

  TVITEMA = RECORD [_NOTALIGNED]
    mask          : WD.UINT;
    hItem         : HTREEITEM;
    state         : WD.UINT;
    stateMask     : WD.UINT;
    pszText       : WD.LPSTR;
    cchTextMax    : LONGINT;
    iImage        : LONGINT;
    iSelectedImage: LONGINT;
    cChildren     : LONGINT;
    lParam        : WD.LPARAM;
  END;
  TV_ITEMA = TVITEMA;
  TVITEM = TVITEMA;    (* ! A *)
  TV_ITEM = TVITEMA;  (* ! A *)
  LPTVITEMA = POINTER TO TVITEMA;
  LPTV_ITEMA = LPTVITEMA;
  LPTVITEM = LPTVITEMA;     (* ! A *)
  LPTV_ITEM = LPTVITEMA;   (* ! A *)

  TVITEMW = RECORD [_NOTALIGNED]
    mask          : WD.UINT;
    hItem         : HTREEITEM;
    state         : WD.UINT;
    stateMask     : WD.UINT;
    pszText       : WD.LPWSTR;
    cchTextMax    : LONGINT;
    iImage        : LONGINT;
    iSelectedImage: LONGINT;
    cChildren     : LONGINT;
    lParam        : WD.LPARAM;
  END;
  TV_ITEMW = TVITEMW;
  LPTVITEMW = POINTER TO TVITEMW;
  LPTV_ITEMW = LPTVITEMW;

  TVINSERTSTRUCTA = RECORD [_NOTALIGNED]
    hParent     : HTREEITEM;
    hInsertAfter: HTREEITEM;
    item        : TVITEMA;
  END;
  TV_INSERTSTRUCTA = TVINSERTSTRUCTA;
  TVINSERTSTRUCT = TVINSERTSTRUCTA;    (* ! A *)
  TV_INSERTSTRUCT = TVINSERTSTRUCTA;  (* ! A *)
  LPTVINSERTSTRUCTA = POINTER TO TVINSERTSTRUCTA;
  LPTV_INSERTSTRUCTA = LPTVINSERTSTRUCTA;
  LPTVINSERTSTRUCT = LPTVINSERTSTRUCTA;     (* ! A *)
  LPTV_INSERTSTRUCT = LPTVINSERTSTRUCTA;   (* ! A *)

  TVINSERTSTRUCTW = RECORD [_NOTALIGNED]
    hParent     : HTREEITEM;
    hInsertAfter: HTREEITEM;
    item        : TVITEMW;
  END;
  TV_INSERTSTRUCTW = TVINSERTSTRUCTW;
  LPTVINSERTSTRUCTW = POINTER TO TVINSERTSTRUCTW;
  LPTV_INSERTSTRUCTW = LPTVINSERTSTRUCTW;
 
  TVHITTESTINFO = RECORD [_NOTALIGNED]
    pt   : WD.POINT;
    flags: WD.UINT;
    hItem: HTREEITEM;
  END;
  TV_HITTESTINFO = TVHITTESTINFO;
  LPTVHITTESTINFO = POINTER TO TVHITTESTINFO;
  LPTV_HITTESTINFO = LPTVHITTESTINFO;

  PFNTVCOMPARE = PFNLVCOMPARE;

  TVSORTCB = RECORD [_NOTALIGNED]
    hParent    : HTREEITEM;
    lpfnCompare: PFNTVCOMPARE;
    lParam     : WD.LPARAM;
  END;
  TV_SORTCB = TVSORTCB;
  LPTVSORTCB = POINTER TO TVSORTCB;
  LPTV_SORTCB = LPTVSORTCB;

  NMTREEVIEWA = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    action : WD.UINT;
    itemOld: TVITEMA;
    itemNew: TVITEMA;
    ptDrag : WD.POINT;
  END;
  NM_TREEVIEWA = NMTREEVIEWA;
  NMTREEVIEW = NMTREEVIEWA;    (* ! A *)
  NM_TREEVIEW = NMTREEVIEWA;  (* ! A *)
  LPNMTREEVIEWA = POINTER TO NMTREEVIEWA;
  LPNM_TREEVIEWA = LPNMTREEVIEWA;
  LPNMTREEVIEW = LPNMTREEVIEWA;     (* ! A *)
  LPNM_TREEVIEW = LPNMTREEVIEWA;   (* ! A *)

  NMTREEVIEWW = RECORD [_NOTALIGNED]
    hdr    : WU.NMHDR;
    action : WD.UINT;
    itemOld: TVITEMW;
    itemNew: TVITEMW;
    ptDrag : WD.POINT;
  END;
  NM_TREEVIEWW = NMTREEVIEWW;
  LPNMTREEVIEWW = POINTER TO NMTREEVIEWW;
  LPNM_TREEVIEWW = LPNMTREEVIEWW;

  TVDISPINFOA = RECORD [_NOTALIGNED]
    hdr : WU.NMHDR;
    item: TVITEMA;
  END;
  TV_DISPINFOA = TVDISPINFOA;
  NMTVDISPINFO = TVDISPINFOA;    (* ! A *)
  TV_DISPINFO = TVDISPINFOA;    (* ! A *)
  LPNMTVDISPINFOA = POINTER TO TVDISPINFOA;
  LPNMTVDISPINFO = LPNMTVDISPINFOA;    (* ! A *)

  TVDISPINFOW = RECORD [_NOTALIGNED]
    hdr : WU.NMHDR;
    item: TVITEMW;
  END;
  TV_DISPINFOW = TVDISPINFOW;
  LPNMTVDISPINFOW = POINTER TO TVDISPINFOW;
 
  TVKEYDOWN = LVKEYDOWN;
  NMTVKEYDOWN = LVKEYDOWN;
  TV_KEYDOWN = LVKEYDOWN;
  LPNMTVKEYDOWN = LPNMLVKEYDOWN;

  NMTVCUSTOMDRAW = NMLVCUSTOMDRAW;
  LPNMTVCUSTOMDRAW = LPNMLVCUSTOMDRAW;

  COMBOBOXEXITEMA = RECORD [_NOTALIGNED]
    mask          : WD.UINT;
    iItem         : LONGINT;
    pszText       : WD.LPSTR;
    cchTextMax    : LONGINT;
    iImage        : LONGINT;
    iSelectedImage: LONGINT;
    iOverlay      : LONGINT;
    iIndent       : LONGINT;
    lParam        : WD.LPARAM;
  END;
  COMBOBOXEXITEM = COMBOBOXEXITEMA;     (* ! A *)
  PCOMBOBOXEXITEMA = POINTER TO COMBOBOXEXITEMA;
  PCOMBOBOXEXITEM = PCOMBOBOXEXITEMA;  (* ! A *)
  PCCOMBOEXITEMA = PCOMBOBOXEXITEMA;

  COMBOBOXEXITEMW = RECORD [_NOTALIGNED]
    mask          : WD.UINT;
    iItem         : LONGINT;
    pszText       : WD.LPWSTR;
    cchTextMax    : LONGINT;
    iImage        : LONGINT;
    iSelectedImage: LONGINT;
    iOverlay      : LONGINT;
    iIndent       : LONGINT;
    lParam        : WD.LPARAM;
  END;
  PCOMBOBOXEXITEMW = POINTER TO COMBOBOXEXITEMW;
  PCCOMBOEXITEMW = PCOMBOBOXEXITEMW;
 
(*  CBEN_ENDEDIT sends this information... *)
(*  fChanged if the user actually did anything *)
(*  iNewSelection gives what would be the new selection unless the notify is failed *)
(*                       iNewSelection may be CB_ERR if there's no match *)
  NMCOMBOBOXEX = RECORD [_NOTALIGNED]  (* ! A *)
    hdr   : WU.NMHDR;
    ceItem: COMBOBOXEXITEMA;
  END;
  PNMCOMBOBOXEX = POINTER TO NMCOMBOBOXEX;  (* ! A *)

  NMCBEENDEDITW = RECORD [_NOTALIGNED]
    hdr          : WU.NMHDR;
    fChanged     : WD.BOOL;
    iNewSelection: LONGINT;
    szText       : ARRAY CBEMAXSTRLEN OF WD.WCHAR;
    iWhy         : LONGINT;
  END;
  PNMCBEENDEDITW = POINTER TO NMCBEENDEDITW;

  NMCBEENDEDITA = RECORD [_NOTALIGNED]
    hdr          : WU.NMHDR;
    fChanged     : WD.BOOL;
    iNewSelection: LONGINT;
    szText       : ARRAY CBEMAXSTRLEN OF CHAR;
    iWhy         : LONGINT;
  END;
  NMCBEENDEDIT = NMCBEENDEDITA;    (* ! A *)
  PNMCBEENDEDITA = POINTER TO NMCBEENDEDITA;
  PNMCBEENDEDIT = PNMCBEENDEDITA;    (* ! A *)

  TCITEMA = RECORD [_NOTALIGNED]
    mask       : WD.UINT;
    dwState    : WD.DWORD;
    dwStateMask: WD.DWORD;
    pszText    : WD.LPSTR;
    cchTextMax : LONGINT;
    iImage     : LONGINT;
    lParam     : WD.LPARAM;
  END;
  TC_ITEMA = TCITEMA;
  TCITEM = TCITEMA;    (* ! A *)
  TC_ITEM = TCITEMA;  (* ! A *)
  LPTCITEMA = POINTER TO TCITEMA;
  LPTCITEM = LPTCITEMA;  (* ! A *)

  TCITEMW = RECORD [_NOTALIGNED]
    mask       : WD.UINT;
    dwState    : WD.DWORD;
    dwStateMask: WD.DWORD;
    pszText    : WD.LPWSTR;
    cchTextMax : LONGINT;
    iImage     : LONGINT;
    lParam     : WD.LPARAM;
  END;
  TC_ITEMW = TCITEMW;
  LPTCITEMW = POINTER TO TCITEMW;

  TCHITTESTINFO = RECORD [_NOTALIGNED]
    pt   : WD.POINT;
    flags: WD.UINT;
  END;
  TC_HITTESTINFO = TCHITTESTINFO;
  LPTCHITTESTINFO = POINTER TO TCHITTESTINFO;
  LPTC_HITTESTINFO = LPTCHITTESTINFO;
  
  TCKEYDOWN = LVKEYDOWN;
  NMTCKEYDOWN = LVKEYDOWN;
  TC_KEYDOWN = LVKEYDOWN;

PROCEDURE [_APICALL] InitCommonControls (  );

PROCEDURE [_APICALL] InitCommonControlsEx ( arg0: LPINITCOMMONCONTROLSEX ): WD.BOOL;

PROCEDURE [_APICALL] ImageList_Create ( cx: LONGINT; cy: LONGINT; flags: WD.UINT;
                             cInitial: LONGINT; cGrow: LONGINT ): HIMAGELIST;

PROCEDURE [_APICALL] ImageList_Destroy ( himl: HIMAGELIST ): WD.BOOL;

PROCEDURE [_APICALL] ImageList_GetImageCount ( himl: HIMAGELIST ): LONGINT;

PROCEDURE [_APICALL] ImageList_SetImageCount ( himl: HIMAGELIST;
                                    uNewCount: WD.UINT ): WD.BOOL;

PROCEDURE [_APICALL] ImageList_Add ( himl: HIMAGELIST; hbmImage: WD.HBITMAP;
                          hbmMask: WD.HBITMAP ): LONGINT;

PROCEDURE [_APICALL] ImageList_ReplaceIcon ( himl: HIMAGELIST; i: LONGINT;
                                  hicon: WD.HICON ): LONGINT;

PROCEDURE [_APICALL] ImageList_SetBkColor ( himl: HIMAGELIST;
                                 clrBk: WD.COLORREF ): WD.COLORREF;

PROCEDURE [_APICALL] ImageList_GetBkColor ( himl: HIMAGELIST ): WD.COLORREF;

PROCEDURE [_APICALL] ImageList_SetOverlayImage ( himl: HIMAGELIST; iImage: LONGINT;
                                      iOverlay: LONGINT ): WD.BOOL;


PROCEDURE [_APICALL] ImageList_Draw ( himl: HIMAGELIST; i: LONGINT; hdcDst: WD.HDC;
                           x: LONGINT; y: LONGINT;
                           fStyle: WD.UINT ): WD.BOOL;
 
PROCEDURE [_APICALL] CreateToolbarEx ( hwnd: WD.HWND; ws: WD.DWORD;
                            wID: WD.UINT; nBitmaps: LONGINT;
                            hBMInst: WD.HINSTANCE; wBMID: WD.UINT;
                            VAR STATICTYPED Buttons: TBBUTTON; iNumButtons: LONGINT;
                            dxButton: LONGINT; dyButton: LONGINT; dxBitmap: LONGINT;
                            dyBitmap: LONGINT;
                            uStructSize: WD.UINT ): WD.HWND;

PROCEDURE [_APICALL] CreateMappedBitmap ( hInstance: WD.HINSTANCE; idBitmap: LONGINT;
                               wFlags: WD.UINT; VAR STATICTYPED ColorMap: COLORMAP;
                               iNumMaps: LONGINT ): WD.HBITMAP;

PROCEDURE [_APICALL] DrawStatusTextA ( hDC: WD.HDC; VAR STATICTYPED rc: WD.RECT;
                            pszText: WD.LPCSTR; uFlags: WD.UINT );
PROCEDURE [_APICALL] DrawStatusTextW ( hDC: WD.HDC; VAR STATICTYPED rc: WD.RECT;
                            pszText: WD.LPCWSTR; uFlags: WD.UINT );
(*  !  DrawStatusText *)

PROCEDURE [_APICALL] CreateStatusWindowA ( style: LONGINT;
                                lpszText: WD.LPCSTR;
                                hwndParent: WD.HWND;
                                wID: WD.UINT ): WD.HWND;
PROCEDURE [_APICALL] CreateStatusWindowW ( style: LONGINT;
                                lpszText: WD.LPCWSTR;
                                hwndParent: WD.HWND;
                                wID: WD.UINT ): WD.HWND;
(*  !   CreateStatusWindow *)

PROCEDURE [_APICALL] MenuHelp ( uMsg: WD.UINT; wParam: WD.WPARAM;
                     lParam: WD.LPARAM; hMainMenu: WD.HMENU;
                     hInst: WD.HINSTANCE; hwndStatus: WD.HWND;
                     VAR wIDs: WD.UINT );

PROCEDURE [_APICALL] ShowHideMenuCtl ( hWnd: WD.HWND; uFlags: WD.UINT;
                            VAR Info: INTEGER ): WD.BOOL;

PROCEDURE [_APICALL] GetEffectiveClientRect ( hWnd: WD.HWND; VAR STATICTYPED rc: WD.RECT;
                                   VAR Info: INTEGER );

PROCEDURE [_APICALL] MakeDragList ( hLB: WD.HWND ): WD.BOOL;

PROCEDURE [_APICALL] DrawInsert ( handParent: WD.HWND; hLB: WD.HWND;
                       nItem: LONGINT );

PROCEDURE [_APICALL] LBItemFromPt ( hLB: WD.HWND; pt: WD.POINT;
                         bAutoScroll: WD.BOOL ): LONGINT;

PROCEDURE [_APICALL] CreateUpDownControl ( dwStyle: WD.DWORD; x: LONGINT; y: LONGINT;
                                cx: LONGINT; cy: LONGINT; hParent: WD.HWND;
                                nID: LONGINT; hInst: WD.HINSTANCE;
                                hBuddy: WD.HWND; nUpper: LONGINT;
                                nLower: LONGINT; nPos: LONGINT ): WD.HWND;

 

(* ====== ANIMATE CONTROL ====================================================== *)
(* ====== MONTHCAL CONTROL ====================================================== *)
(* ====== DATETIMEPICK CONTROL ================================================== *)

(*Macros
(* ====== WM_NOTIFY Macros ===================================================== *)
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] HANDLE_WM_NOTIFY ( hwnd; wParam; lParam; fn: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / HANDLE_WM_NOTIFY ( hwnd; wParam; lParam; fn: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] FORWARD_WM_NOTIFY ( hwnd; idFrom; pnmhdr; fn: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / FORWARD_WM_NOTIFY ( hwnd; idFrom; pnmhdr; fn: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ImageList_AddIcon ( himl; hicon: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ImageList_AddIcon ( himl; hicon: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] INDEXTOOVERLAYMASK ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / INDEXTOOVERLAYMASK ( i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_GetItemCount ( hwndHD: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_GetItemCount ( hwndHD: ARRAY OF SYSTEM.BYTE );
<* END *>
end Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_InsertItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_InsertItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_DeleteItem ( hwndHD; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_DeleteItem ( hwndHD; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_GetItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_GetItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_SetItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_SetItem ( hwndHD; i; phdi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_Layout ( hwndHD; playout: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_Layout ( hwndHD; playout: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_GetItemRect ( hwnd; iItem; lprc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_GetItemRect ( hwnd; iItem; lprc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_SetImageList ( hwnd; himl: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_SetImageList ( hwnd; himl: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_GetImageList ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_GetImageList ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_OrderToIndex ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_OrderToIndex ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_CreateDragImage ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_CreateDragImage ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_GetOrderArray ( hwnd; iCount; lpi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_GetOrderArray ( hwnd; iCount; lpi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_SetOrderArray ( hwnd; iCount; lpi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_SetOrderArray ( hwnd; iCount; lpi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] Header_SetHotDivider ( hwnd; fPos; dw: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / Header_SetHotDivider ( hwnd; fPos; dw: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetBkColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetBkColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetBkColor ( hwnd; clrBk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetBkColor ( hwnd; clrBk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetImageList ( hwnd; iImageList: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetImageList ( hwnd; iImageList: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetImageList ( hwnd; himl; iImageList: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetImageList ( hwnd; himl; iImageList: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] INDEXTOSTATEIMAGEMASK ( i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / INDEXTOSTATEIMAGEMASK ( i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_InsertItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_InsertItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_DeleteItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_DeleteItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetCallbackMask ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetCallbackMask ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetCallbackMask ( hwnd; mask: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetCallbackMask ( hwnd; mask: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetNextItem ( hwnd; i; flags: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetNextItem ( hwnd; i; flags: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_FindItem ( hwnd; iStart; plvfi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_FindItem ( hwnd; iStart; plvfi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemRect ( hwnd; i; prc; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemRect ( hwnd; i; prc; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemPosition ( hwndLV; i; x; y: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemPosition ( hwndLV; i; x; y: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemPosition ( hwndLV; i; ppt: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemPosition ( hwndLV; i; ppt: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetStringWidth ( hwndLV; psz: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetStringWidth ( hwndLV; psz: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_HitTest ( hwndLV; pinfo: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_HitTest ( hwndLV; pinfo: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_EnsureVisible ( hwndLV; i; fPartialOK: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_EnsureVisible ( hwndLV; i; fPartialOK: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_Scroll ( hwndLV; dx; dy: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_Scroll ( hwndLV; dx; dy: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_RedrawItems ( hwndLV; iFirst; iLast: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_RedrawItems ( hwndLV; iFirst; iLast: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_Arrange ( hwndLV; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_Arrange ( hwndLV; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_EditLabel ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_EditLabel ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetEditControl ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetEditControl ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_InsertColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_InsertColumn ( hwnd; iCol; pcol: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_DeleteColumn ( hwnd; iCol: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_DeleteColumn ( hwnd; iCol: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetColumnWidth ( hwnd; iCol: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetColumnWidth ( hwnd; iCol: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetColumnWidth ( hwnd; iCol; cx: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetColumnWidth ( hwnd; iCol; cx: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_CreateDragImage ( hwnd; i; lpptUpLeft: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_CreateDragImage ( hwnd; i; lpptUpLeft: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetViewRect ( hwnd; prc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetViewRect ( hwnd; prc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetTextColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetTextColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetTextColor ( hwnd; clrText: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetTextColor ( hwnd; clrText: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetTextBkColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetTextBkColor ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetTextBkColor ( hwnd; clrTextBk: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetTextBkColor ( hwnd; clrTextBk: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetTopIndex ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetTopIndex ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetCountPerPage ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetCountPerPage ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetOrigin ( hwndLV; ppt: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetOrigin ( hwndLV; ppt: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_Update ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_Update ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemState ( hwndLV; i; data; mask: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemState ( hwndLV; i; data; mask: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemState ( hwndLV; i; mask: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemState ( hwndLV; i; mask: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetCheckState ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetCheckState ( hwndLV; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemText ( hwndLV; i; iSubItem_; pszText_;
                                  cchTextMax_: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemText ( hwndLV; i; iSubItem_; pszText_;
                                     cchTextMax_: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemText ( hwndLV; i; iSubItem_;
                                  pszText_: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemText ( hwndLV; i; iSubItem_;
                                     pszText_: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemCount ( hwndLV; cItems: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemCount ( hwndLV; cItems: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemCountEx ( hwndLV; cItems; dwFlags: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemCountEx ( hwndLV; cItems;
                                        dwFlags: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SortItems ( hwndLV; _pfnCompare; _lPrm: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SortItems ( hwndLV; _pfnCompare; _lPrm: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetItemPosition32 ( hwndLV; i; x; y: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetItemPosition32 ( hwndLV; i; x; y: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetSelectedCount ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetSelectedCount ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetItemSpacing ( hwndLV; fSmall: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetItemSpacing ( hwndLV; fSmall: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetISearchString ( hwndLV; lpsz: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetISearchString ( hwndLV; lpsz: ARRAY OF SYSTEM.BYTE );
<* END *>
(*  -1 for cx and cy means we'll use the default (system settings) *)
(*  0 for cx or cy means use the current setting (allows you to change just one param) *)
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetIconSpacing ( hwndLV; cx; cy: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetIconSpacing ( hwndLV; cx; cy: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetExtendedListViewStyle ( hwndLV; dw: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetExtendedListViewStyle ( hwndLV; dw: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetExtendedListViewStyle ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetExtendedListViewStyle ( hwndLV: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetSubItemRect ( hwnd; iItem; iSubItem; code;
                                     prc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetSubItemRect ( hwnd; iItem; iSubItem; code;
                                        prc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SubItemHitTest ( hwnd; plvhti: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SubItemHitTest ( hwnd; plvhti: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetColumnOrderArray ( hwnd; iCount; pi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetColumnOrderArray ( hwnd; iCount; pi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetColumnOrderArray ( hwnd; iCount; pi: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetColumnOrderArray ( hwnd; iCount; pi: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetHotItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetHotItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetHotItem ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetHotItem ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_SetHotFont ( hwnd; hcur: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_SetHotFont ( hwnd; hcur: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_GetHotFont ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_GetHotFont ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] ListView_ApproximateViewRect ( hwnd; iWidth; iHeight;
                                          iCount: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / ListView_ApproximateViewRect ( hwnd; iWidth; iHeight;
                                             iCount: ARRAY OF SYSTEM.BYTE );
<* END *>
END MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_InsertItem ( hwnd; lpis: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_InsertItem ( hwnd; lpis: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_DeleteItem ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_DeleteItem ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_Expand ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_Expand ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetItemRect ( hwnd; hitem; prc; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetItemRect ( hwnd; hitem; prc; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetIndent ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetIndent ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SetIndent ( hwnd; indent: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SetIndent ( hwnd; indent: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetImageList ( hwnd; iImage: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetImageList ( hwnd; iImage: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SetImageList ( hwnd; himl; iImage: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SetImageList ( hwnd; himl; iImage: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetNextItem ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetNextItem ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetChild ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetChild ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetNextSibling ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetNextSibling ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetPrevSibling ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetPrevSibling ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetParent ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetParent ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetFirstVisible ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetFirstVisible ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetNextVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetNextVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetPrevVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetPrevVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetSelection ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetSelection ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetDropHilight ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetDropHilight ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetRoot ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetRoot ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_Select ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_Select ( hwnd; hitem; code: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SelectItem ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SelectItem ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SelectDropTarget ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SelectDropTarget ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SelectSetFirstVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SelectSetFirstVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SetItem ( hwnd; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_EditLabel ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_EditLabel ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetEditControl ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetEditControl ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetVisibleCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetVisibleCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_HitTest ( hwnd; lpht: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_HitTest ( hwnd; lpht: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_CreateDragImage ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_CreateDragImage ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SortChildren ( hwnd; hitem; recurse: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SortChildren ( hwnd; hitem; recurse: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_EnsureVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_EnsureVisible ( hwnd; hitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_SortChildrenCB ( hwnd; psort; recurse: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_SortChildrenCB ( hwnd; psort; recurse: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_EndEditLabelNow ( hwnd; fCancel: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_EndEditLabelNow ( hwnd; fCancel: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TreeView_GetISearchString ( hwndTV; lpsz: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TreeView_GetISearchString ( hwndTV; lpsz: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetImageList ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetImageList ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetImageList ( hwnd; himl: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetImageList ( hwnd; himl: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetItemCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetItemCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
END MACROS*)
(*Macros
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_InsertItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_InsertItem ( hwnd; iItem; pitem: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_DeleteItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_DeleteItem ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_DeleteAllItems ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetItemRect ( hwnd; i; prc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetItemRect ( hwnd; i; prc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetCurSel ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetCurSel ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetCurSel ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetCurSel ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
end MACROS*)
(* MACROS
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_HitTest ( hwndTC; pinfo: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_HitTest ( hwndTC; pinfo: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetItemExtra ( hwndTC; cb: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetItemExtra ( hwndTC; cb: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_AdjustRect ( hwnd; bLarger; prc: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_AdjustRect ( hwnd; bLarger; prc: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetItemSize ( hwnd; x; y: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetItemSize ( hwnd; x; y: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_RemoveImage ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_RemoveImage ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetPadding ( hwnd; cx; cy: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetPadding ( hwnd; cx; cy: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetRowCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetRowCount ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetToolTips ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetToolTips ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetToolTips ( hwnd; hwndTT: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetToolTips ( hwnd; hwndTT: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_GetCurFocus ( hwnd: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_GetCurFocus ( hwnd: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetCurFocus ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetCurFocus ( hwnd; i: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_SetMinTabWidth ( hwnd; x: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_SetMinTabWidth ( hwnd; x: ARRAY OF SYSTEM.BYTE );
<* END *>
<* IF __GEN_C__ THEN *>
(* H2D: this procedure corresponds to a macro. *)
PROCEDURE [_APICALL] TabCtrl_DeselectAll ( hwnd; fExcludeFocus: ARRAY OF SYSTEM.BYTE );
<* ELSE *>
PROCEDURE [_APICALL]  / TabCtrl_DeselectAll ( hwnd; fExcludeFocus: ARRAY OF SYSTEM.BYTE );
<* END *>
END MACROS *)

END CommCTRL.
