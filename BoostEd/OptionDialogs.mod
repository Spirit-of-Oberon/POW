(******************************************************************************
 *  Module OptionDialogs
 *  
 *  
 ******************************************************************************)


MODULE OptionDialogs;

IMPORT SYSTEM,
       WD:=WinDef, WB:=WinBase, WU:=WinUser, WN:=WinNT, WG:=WinGdi,
       Utils, Strings,
       GlobWin, Options, Env:=EnvHnd, ListSt;


CONST
  ID_DISP_COURIER   =122;
  ID_DISP_COURIERNEW=123;
  ID_DISP_FIXEDSYS  =124;
  ID_DISP_FONTSIZE  =125;
  ID_PRNT_COURIER   =132;
  ID_PRNT_COURIERNEW=133;
  ID_PRNT_FIXEDSYS  =134;
  ID_PRNT_FONTSIZE  =135;
  ID_OKFNT          =140;
  ID_CANCELFNT      =141; 

  ID_INDENT         =102;
  ID_USETABS        =103;
  ID_TABSIZE        =104;
  ID_RBNOTHING      =105;
  ID_RBSEARCH       =106;
  ID_FONT           =108;
  ID_OK             =  1;
  ID_CANCEL         =  2;
  ID_HELP           =998;
  ID_SYNTAX         =121;
  ID_SMARTMERGE     =120;
  ID_INDENTWIDTH    =122;
  ID_COLORCOMMENTS  =140;


(****************************************************************)
(*       CallBack-Funktion für Font-Dialog                      *)
(****************************************************************)

PROCEDURE [_APICALL] FontOptionsDlgProc*(hDlg:WD.HWND; 
                                         message: WD.UINT; 
                                         wParam:WD.WPARAM; 
                                         lParam:WD.LPARAM): WD.BOOL;
CONST
  MINFONTSIZE=6;
  MAXFONTSIZE=72;

VAR 
  tmp        : ARRAY 12 OF CHAR;
  res                : WD.LRESULT;
  dmyi,val           : LONGINT;
  done               : WD.BOOL;
  code               : WD.WORD;

BEGIN
  CASE message OF

    (* WM_INITDIALOG *)
  
    WU.WM_INITDIALOG: 
      done := WU.CheckDlgButton(hDlg,ID_DISP_FIXEDSYS,0);
      done := WU.CheckDlgButton(hDlg,ID_DISP_COURIER,0);
      done := WU.CheckDlgButton(hDlg,ID_DISP_COURIERNEW,0);
      done := WU.CheckDlgButton(hDlg,ID_PRNT_FIXEDSYS,0);
      done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIER,0);
      done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIERNEW,0);

      (* eingestellte Schriftart auswählen *)
      IF Options.fontName = Options.FONT_FIXEDSYS THEN   
        done := WU.CheckDlgButton(hDlg,ID_DISP_FIXEDSYS,1);
      ELSIF Options.fontName = Options.FONT_COURIER THEN   
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIER,1);
      ELSIF Options.fontName = Options.FONT_COURIERNEW THEN   
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIERNEW,1);
      END;

      IF Options.printerFontName = Options.FONT_FIXEDSYS THEN   
        done := WU.CheckDlgButton(hDlg,ID_PRNT_FIXEDSYS,1);
      ELSIF Options.printerFontName = Options.FONT_COURIER THEN   
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIER,1);
      ELSIF Options.printerFontName = Options.FONT_COURIERNEW THEN   
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIERNEW,1);
      END;

      (* eingestellte Schriftgröße auswählen *)
      Strings.Str(Options.fontSize,tmp);
      done := WU.SetWindowTextA(WU.GetDlgItem(hDlg,ID_DISP_FONTSIZE),SYSTEM.ADR(tmp[0]));

      Strings.Str(Options.printerFontSize,tmp);
      done := WU.SetWindowTextA(WU.GetDlgItem(hDlg,ID_PRNT_FONTSIZE),SYSTEM.ADR(tmp[0]));

    (* WM_COMMAND *)

  | WU.WM_COMMAND:   
      code := Utils.LoWord(wParam); (* Code auslesen *)
      IF code = ID_OKFNT THEN  
        IF WU.IsDlgButtonChecked(hDlg, ID_DISP_FIXEDSYS) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_FIXEDSYS,Options.fontName);
        ELSIF WU.IsDlgButtonChecked(hDlg, ID_DISP_COURIER) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_COURIER,Options.fontName);
        ELSIF WU.IsDlgButtonChecked(hDlg, ID_DISP_COURIERNEW) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_COURIERNEW,Options.fontName);
        END;
        IF WU.IsDlgButtonChecked(hDlg, ID_PRNT_FIXEDSYS) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_FIXEDSYS,Options.printerFontName);
        ELSIF WU.IsDlgButtonChecked(hDlg, ID_PRNT_COURIER) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_COURIER,Options.printerFontName);
        ELSIF WU.IsDlgButtonChecked(hDlg, ID_PRNT_COURIERNEW) = 1 THEN (* ist markiert *)
          COPY(Options.FONT_COURIERNEW,Options.printerFontName);
        END;
        dmyi:=WU.GetWindowTextA(WU.GetDlgItem(hDlg,ID_DISP_FONTSIZE),SYSTEM.ADR(tmp),10);
        Options.fontSize:=Strings.Val(tmp);
        dmyi:=WU.GetWindowTextA(WU.GetDlgItem(hDlg,ID_PRNT_FONTSIZE),SYSTEM.ADR(tmp),10);
        Options.printerFontSize:=Strings.Val(tmp);
        IF Options.fontSize < MINFONTSIZE THEN Options.fontSize:=MINFONTSIZE END;
        IF Options.fontSize > MAXFONTSIZE THEN Options.fontSize:=MAXFONTSIZE END;
        IF Options.printerFontSize < MINFONTSIZE THEN Options.printerFontSize:=MINFONTSIZE END;
        IF Options.printerFontSize > MAXFONTSIZE THEN Options.printerFontSize:=MAXFONTSIZE END;
        done := WU.EndDialog(hDlg,wParam);
                                
      ELSIF code = ID_CANCELFNT THEN
        done := WU.EndDialog(hDlg,wParam);
                                
      ELSIF code = ID_DISP_FIXEDSYS THEN
        done := WU.CheckDlgButton(hDlg,ID_DISP_FIXEDSYS,1);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIER,0);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIERNEW,0);
                                
      ELSIF code = ID_DISP_COURIER THEN
        done := WU.CheckDlgButton(hDlg,ID_DISP_FIXEDSYS,0);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIER,1);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIERNEW,0);

      ELSIF code = ID_DISP_COURIERNEW THEN
        done := WU.CheckDlgButton(hDlg,ID_DISP_FIXEDSYS,0);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIER,0);
        done := WU.CheckDlgButton(hDlg,ID_DISP_COURIERNEW,1);
                                
      ELSIF code = ID_PRNT_FIXEDSYS THEN
        done := WU.CheckDlgButton(hDlg,ID_PRNT_FIXEDSYS,1);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIER,0);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIERNEW,0);
                                
      ELSIF code = ID_PRNT_COURIER THEN
        done := WU.CheckDlgButton(hDlg,ID_PRNT_FIXEDSYS,0);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIER,1);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIERNEW,0);

      ELSIF code = ID_PRNT_COURIERNEW THEN
        done := WU.CheckDlgButton(hDlg,ID_PRNT_FIXEDSYS,0);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIER,0);
        done := WU.CheckDlgButton(hDlg,ID_PRNT_COURIERNEW,1);
                                
      ELSE 
      END;
                                
  ELSE 
  END;
  RETURN 0;
END FontOptionsDlgProc;

(***********************************************************************************************)   
                                   
PROCEDURE SelectFont();
(* Schriftdialogbox erzeugen *)
VAR 
  proc    : WD.FARPROC;
  nres    : LONGINT;
BEGIN
  nres:=WU.DialogBoxParamA(GlobWin.hInstance, SYSTEM.ADR("DIALOG_2"),WD.NULL, FontOptionsDlgProc, WD.NULL);
  IF nres=-1 THEN GlobWin.DisplayError("error","Could not display dialogbox"); END;
END SelectFont;


(****************************************************************)
(*       CallBack-Funktion für Edit-Dialog                      *)
(****************************************************************)

PROCEDURE [_APICALL] EditOptionsDlgProc*(hDlg:WD.HWND; 
                                         message: WD.UINT; 
                                         wParam:WD.WPARAM; 
                                         lParam:WD.LPARAM): WD.BOOL;

VAR
  tabstr,str         : ARRAY 12 OF CHAR;
  res                : WD.LRESULT;
  dmyi,val           : LONGINT;
  high               : WD.BYTE;
  hObj               : WD.HGDIOBJ;
  fontsel            : ARRAY 32 OF CHAR;
  hChild,hChildfirst : WD.HWND;
  done               : WD.BOOL;
  code               : WD.WORD;

BEGIN
  CASE message OF                       

    (* WM_INITDIALOG *)

    WU.WM_INITDIALOG: 
      Options.TmpSave;
      IF Options.autoIndent THEN val:=1 ELSE val:=0; END;
      res:=WU.SendDlgItemMessageA(hDlg,ID_INDENT,WU.BM_SETCHECK,val,0);
      IF Options.useTabs THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_USETABS,WU.BM_SETCHECK,val,0);
      IF ~Options.mouse THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_RBNOTHING,WU.BM_SETCHECK,val,0);
      IF Options.mouse THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_RBSEARCH,WU.BM_SETCHECK,val,0);
      IF Options.syntax THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_SYNTAX,WU.BM_SETCHECK,val,0);
      IF Options.smartDel THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_SMARTMERGE,WU.BM_SETCHECK,val,0);
      Strings.Str(Options.indentWidth,str);
      done := WU.SetWindowTextA(WU.GetDlgItem(hDlg,ID_INDENTWIDTH),SYSTEM.ADR(str));
      Strings.Str(Options.tabsize,tabstr);
      done := WU.SetWindowTextA(WU.GetDlgItem(hDlg,ID_TABSIZE),SYSTEM.ADR(tabstr));
      IF Options.colorComments THEN val:=1 ELSE val:=0; END;  
      res:=WU.SendDlgItemMessageA(hDlg,ID_COLORCOMMENTS,WU.BM_SETCHECK,val,0);

   (* WM_COMMAND *)

  | WU.WM_COMMAND:
      code := Utils.LoWord(wParam); (* Code auslesen *)   
      IF code=ID_OK THEN  
        Options.autoIndent:=SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_INDENT,WU.BM_GETCHECK,0,0));
        Options.useTabs   :=SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_USETABS,WU.BM_GETCHECK,0,0));
        Options.mouse     :=~SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_RBNOTHING,WU.BM_GETCHECK,0,0));
        Options.colorComments:=SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_COLORCOMMENTS,WU.BM_GETCHECK,0,0));
        IF Options.useTabs THEN
          dmyi:=WU.GetWindowTextA(WU.GetDlgItem(hDlg,ID_TABSIZE),SYSTEM.ADR(tabstr),10);
          Options.tabsize:=Strings.Val(tabstr);
          IF (Options.tabsize<0) OR (Options.tabsize>40) THEN 
            Options.tabsize:=0;
          END;
        ELSE 
          Options.tabsize:=0;
        END;
        Options.syntax:=SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_SYNTAX,WU.BM_GETCHECK,0,0));
        Options.smartDel:=SYSTEM.VAL(BOOLEAN,WU.SendDlgItemMessageA(hDlg,ID_SMARTMERGE,WU.BM_GETCHECK,0,0));
        IF Options.syntax THEN
          dmyi:=WU.GetWindowTextA(WU.GetDlgItem(hDlg,ID_INDENTWIDTH),SYSTEM.ADR(str),10);
          Options.indentWidth:=Strings.Val(str);
          IF (Options.indentWidth<0) OR (Options.indentWidth>10) THEN 
            Options.indentWidth:=0;
          END;
        ELSE
          Options.indentWidth:=0;
        END;
        Env.WriteIniFile(); 
        done := WU.EndDialog(hDlg,wParam);
                              
      ELSIF code = ID_CANCEL THEN
        Options.Restore;
        done := WU.EndDialog(hDlg,wParam);
                              
      ELSIF code = ID_RBNOTHING THEN
        IF Options.mouse THEN
          res:=WU.SendDlgItemMessageA(hDlg,ID_RBNOTHING,WU.BM_SETCHECK,WD.True,0);
          res:=WU.SendDlgItemMessageA(hDlg,ID_RBSEARCH,WU.BM_SETCHECK,WD.False,0);
        END;
                         
      ELSIF code = ID_RBSEARCH THEN
        IF ~Options.mouse THEN
          res:=WU.SendDlgItemMessageA(hDlg,ID_RBSEARCH,WU.BM_SETCHECK,WD.True,0);
          res:=WU.SendDlgItemMessageA(hDlg,ID_RBNOTHING,WU.BM_SETCHECK,WD.False,0);
        END;
                              
      ELSIF code = ID_HELP THEN
        GlobWin.ShowHelp(hDlg); 
                   
      ELSIF code = ID_FONT THEN       
        SelectFont();
      ELSE 
      END;
                                
  ELSE 
  END;
  RETURN 0;
END EditOptionsDlgProc;
  

(***********************************************************************************************)   

PROCEDURE EditOptions*;
VAR
  res:LONGINT;
BEGIN
  Options.TmpSave;  
  res:=WU.DialogBoxParamA(GlobWin.hInstance, SYSTEM.ADR("DIALOG_1"),WD.NULL, EditOptionsDlgProc,WD.NULL);
  IF res=ID_CANCEL THEN 
    Options.Restore;
  ELSIF res=-1 THEN GlobWin.DisplayError("error","Could not display dialogbox");
  END;
END EditOptions;

END OptionDialogs.
