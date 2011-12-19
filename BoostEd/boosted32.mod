(******************************************************************************
 *  BoostEd 32  Rel. 1.1  21/10/1998
 *-----------------------------------------------------------------------------
 *  Vi4Win    1.0 1995       Michael Bogner, Max Mayrb‰url                          
 *  BoostEd   1.0 1996       Bernhard Leisch
 *  BoostEd32 0.9 1998       Alexander Bergsmann
 *  BoostEd32 1.0 1998       Bernhard Leisch
 *  BoostEd32 1.1 1998 21/10 BL +more explicit error messages for printing
 *-----------------------------------------------------------------------------
 *  Module Boosted32
 *  
 *  This module contains the procedures which form the interface that is used
 *  by Pow! to integrate the editor into the environment.
 ******************************************************************************)

(*
    If you want to create a new version of the editor yourself,
    you have to
    
    1. Recompile this project
    2. Copy the Boosted32.DLL file into the Pow! program directory
       (the Pow.EXE file is in this directory)
    3. Rename the Boosted32.DLL into something like "NewBoosted.ELL".
       It is important to change the extension from ".DLL" to ".ELL".
       Of course it is also possible to replace the original 
       Boosted32.ELL that came with this distribution, but it is 
       advisable to keep a copy of a working editor just in case.
    4. Start Pow!, select "Preferences" in the menu "Options".
       Select the editor in the editor combo box.
       
    To get rid of a faulty editor which can not even be loaded,
    you can delete the corresponding ".ELL" file in the Pow! program
    directory. Although Pow! will complain it will start up and allow
    you to select another editor.

*)

MODULE Boosted32;

IMPORT SYSTEM,
       WD:=WinDef, WB:=WinBase, WU:=WinUser, WN:=WinNT, WG:=WinGDI,
       GlobWin, WinHnd, TextWin, FileHnd, ListSt, EditWin, EnvHnd, Print,
       Options, OptionDialogs;


CONST
  EDITORINTERFACEVERSION = 170;  (* Pow! editor interface version supported 
                                    by this implementation *)
  TRACE_CALLS = FALSE;  (* if set to TRUE, each call of an interface procedure
     also generates a pop-up window showing which procedure has been called. *)




PROCEDURE [_APICALL] InterfaceVersion* (): INTEGER;
(* returns the code for the Pow! editor interface version supported by the editor *)
BEGIN
  RETURN EDITORINTERFACEVERSION;
END InterfaceVersion;


PROCEDURE [_APICALL] NewEditWindow* (parent:WD.HWND;readOnly:INTEGER);
(* Creates an empty new editor window. If readOnly is true, keyboard 
   input to the window is disabled. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in NewEditWindow "); END;
  WinHnd.NewEditWindow(parent,readOnly#0);
END NewEditWindow;


PROCEDURE [_APICALL] CloseEditWindow* (edit:WD.HWND);
(* Closes an edit window. Any changes to the contents are lost. *)
VAR
  hEdit : WD.HWND;
  res   : WD.BOOL;

BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in CloseEditWindow "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);
  res:=WU.DestroyWindow(hEdit);
END CloseEditWindow;


PROCEDURE [_APICALL] HasChanged* (edit:WD.HWND): INTEGER;
(* This function returns TRUE if the text in the edit window has been changed
   since it was loaded from file *)
VAR
  hEdit : WD.HWND;
  win   : EditWin.EditWin;

BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in HasChanged "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);
  win:=EditWin.AssocWinObj(hEdit);
  IF win.changed THEN RETURN 1 ELSE RETURN 0 END;
END HasChanged;


PROCEDURE [_APICALL] LoadFile* (edit:WD.HWND; name:WD.LPSTR): INTEGER;
(* The edit window is loaded with the file specified in <name> *)
VAR 
  hEdit      : WD.HWND;
  res        : INTEGER;
  hcurSave,
  tmpcur     : WD.HCURSOR;
  win        : EditWin.EditWin; 
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in LoadFile "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  hcurSave:=WU.SetCursor(WU.LoadCursorA(WD.NULL,WU.IDC_WAIT)); (* Cursorumriﬂ ‰ndern *)
  win.text.ResetContents;
  res:=FileHnd.LoadFile(hEdit, name);
  tmpcur:=WU.SetCursor(hcurSave);
  IF TRACE_CALLS THEN GlobWin.DisplayError("","end of LoadFile") END;
  RETURN res;
END LoadFile;


PROCEDURE [_APICALL] SaveFile* (edit:WD.HWND; name:WD.LPSTR): INTEGER;
(* The current contents of the edit window are stored in the file specified by
   <name>. The previous contents of the file are overwritten. *)
VAR 
  hEdit        : WD.HWND;
  res          : INTEGER;
  hcurSave,
  tmpcur       : WD.HCURSOR;
  reslt        : WD.LRESULT;
  win          : EditWin.EditWin; 
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in SaveFile ") END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  hcurSave:=WU.SetCursor(WU.LoadCursorA(WD.NULL,WU.IDC_WAIT));
  res:=FileHnd.SaveFile(hEdit, name);
  IF res=1 THEN  
    win.changed:=FALSE;
    reslt:=WU.SendMessageA(WU.GetParent(hEdit),ListSt.PEM_SHOWCHANGED,0,0);
  ELSE
    GlobWin.Beep;
  END; 
  tmpcur:=WU.SetCursor(hcurSave);
  RETURN res;
END SaveFile;


PROCEDURE [_APICALL] GetCursorpos* (edit:WD.HWND; VAR row,col:LONGINT): INTEGER;
(* This function returns the current position of the cursor in the edit window
   in <row> and <col>. 
   The return value of the function is 1 for success and 0 for failure. *)
VAR 
  hEdit     : WD.HWND;
  win       : EditWin.EditWin; 
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GetCursorPos "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  IF win#NIL THEN
    row:=win.row;
    col:=win.col;
    RETURN 1;
  ELSE
    RETURN 0;
  END;  
END GetCursorpos;


PROCEDURE [_APICALL] Copy* (edit:WD.HWND): INTEGER;
(* The currently selected text is copied to the clipboard 
   The return value of the function is 1 for success and 0 if there was
   a fault or no text was selected. *)
VAR
  hEdit : WD.HWND;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Copy "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  RETURN WinHnd.Copy(hEdit);
END Copy;


PROCEDURE [_APICALL] Paste* (edit:WD.HWND): INTEGER;
(* The current contents of the clipboard is inserted at the current 
   cursor location 
   The return value of the function is 1 for success and 0 if there was
   a fault or the clipboard was empty. *)
VAR 
  hEdit : WD.HWND;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Paste"); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  RETURN WinHnd.Paste(hEdit);
END Paste;


PROCEDURE [_APICALL] Cut* (edit:WD.HWND): INTEGER;
(* The currently selected text is copied into the clipboard and removed 
   from the edit window. 
   The return value of the function is 1 for success and 0 if there was
   a fault or no text was selected. *)
VAR 
  hEdit : WD.HWND;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Cut "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  RETURN WinHnd.Cut(hEdit);
END Cut;


PROCEDURE [_APICALL] Clear* (edit:WD.HWND): INTEGER;
(* The currently selected text is deleted
   The return value of the function is 1 for success and 0 if there was
   a fault or no text was selected. *)
VAR 
  hEdit : WD.HWND;
  win   : EditWin.EditWin; 
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Clear"); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  IF win.CutSelectionFromScreen() THEN RETURN 1 ELSE RETURN 0 END;
END Clear;


PROCEDURE [_APICALL] CanUndo* (): INTEGER;
(* The return value of the function is
   0: if the editor does not support Undo
   1: if the editor supports Undo but does not support Redo
   2: if the editor supports Undo and Redo
   This editor implementation supports a single Undo/Redo (no undo buffer) *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in CanUndo "); END;
  RETURN 2;  
END CanUndo;


PROCEDURE [_APICALL] Undo* (edit:WD.HWND);
(* The last change to the text is undone *)
VAR 
  hEdit : WD.HWND;
  win   : EditWin.EditWin;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Undo "); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  win.Undo;
END Undo;


PROCEDURE [_APICALL] Redo* (edit:WD.HWND);
(* The last undone change to the text is done again *)
VAR 
  hEdit : WD.HWND;
  win   : EditWin.EditWin;

BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Redo"); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  win:=EditWin.AssocWinObj(hEdit);
  win.Redo;
END Redo;


PROCEDURE [_APICALL] GotoPos* (edit:WD.HWND; row,col:LONGINT): INTEGER;
(* The cursor position is set to the position defined by <row> and <col>.
   Column and row count starts with 1.
   The cursor can be set after the end of the text by setting <row> or 
   <col> to -1. *)
VAR 
  win : EditWin.EditWin;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GotoPos ") END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win#NIL THEN 
    win.CursGoto(row, col);
    RETURN 1;
  ELSE 
    RETURN 0;
  END;
END GotoPos;


PROCEDURE [_APICALL] Search* (edit:WD.HWND;
                              text:WD.LPSTR;
                              matchcase,down,words:BOOLEAN): BOOLEAN;
(* The string defined in <text> is searched for in the designated edit
   window. The search is 
   case sensitive if <matchcase> is TRUE, 
   downwards from the current cursor location if <down> is TRUE,
   searches for whole words only if <words> is TRUE. 
   The return value is TRUE if the text has been found and FALSE if
   it could not be found. *)
VAR 
  win   : EditWin.EditWin;
BEGIN      
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Search"); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win=NIL THEN RETURN FALSE END;
  RETURN win.SearchText(text, matchcase, down, words);
END Search;


PROCEDURE [_APICALL] Replace* (edit:WD.HWND;
                               text,new:WD.LPSTR;
                               matchcase,down,words,all,ask:BOOLEAN): INTEGER;
(* The string defined in <text> is replcaded with the string defined in
   <new> in the designated edit window. The search for the text which should
   be replaced is 
   case sensitive if <matchcase> is TRUE, 
   downwards from the current cursor location if <down> is TRUE,
   searches for whole words only if <words> is TRUE. 
   All occurrences of the text are replaced if <all> is true.
   If <ask> is TRUE a pop-up window is displayed to individually confirm the 
   replacement of each occurrence of <text>.
   The return value of the function is the number of text replacements which
   took place. *)
VAR
  res     : BOOLEAN;
  win     : EditWin.EditWin;
  once    : BOOLEAN;
  
  PROCEDURE ReplaceOk():BOOLEAN;
  VAR
    res : LONGINT;
  BEGIN
    res:=WU.MessageBoxA(win.hwnd,
                      SYSTEM.ADR("Replace ?"),
                      SYSTEM.ADR("Search and Replace"),
                      WU.MB_YESNOCANCEL);
    IF res=WU.IDCANCEL THEN all:=FALSE END;
    RETURN res=WU.IDYES;
  END ReplaceOk;

BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Replace"); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win=NIL THEN RETURN 0 END;
  win.SetUndoAction(TextWin.ACT_NONE);
  once:=FALSE;
  REPEAT
    res:=win.SearchText(text, matchcase, down, words);
    IF (res=TRUE) & ((ask=FALSE) OR ReplaceOk()) THEN
      IF win.CutSelectionFromScreen() THEN
        IF ~win.InsertText(new) THEN
          GlobWin.Beep;
          res:=FALSE;
        END;
      END;
    END;
    IF res=TRUE THEN once:=TRUE END;
  UNTIL (res=FALSE) OR (all=FALSE);
  IF once THEN RETURN 1 ELSE RETURN 0 END;
END Replace;


PROCEDURE [_APICALL] Keywords* (caseSensitive:BOOLEAN; words:WD.LPSTR);
(* This function supplies the editor with a list of key words to allow
   syntax highlighting. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in KeyWords"); END;
END Keywords;


PROCEDURE [_APICALL] SetCommandProcedure* (command:WD.FARPROC);
(* This function is not supported. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in SetCommandProcedure "); END;
END SetCommandProcedure;


PROCEDURE [_APICALL] Comments* (nested:WD.WORD;
                                on,off,stringstart:WD.LPSTR);
(* This function defines the strings which are used to open and close a comment
   in the source file depending on the compiler which is currently selected. *)
VAR 
  dmy: WD.LPSTR;
  buf: ARRAY 1024 OF CHAR;
  
  PROCEDURE CutBufAtBlank;
  VAR
    i:INTEGER;
  BEGIN
    i:=0;
    WHILE (buf[i]#0X) & (buf[i]#' ') DO INC(i) END;
    buf[i]:=0X; 
  END CutBufAtBlank;
  
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in Comments"); END;
  dmy:=WB.lstrcpyA(SYSTEM.ADR(buf),on);  
  CutBufAtBlank;  (* Boosted can only handle one alternative *)
  COPY(buf,Options.commentStart);
  dmy:=WB.lstrcpyA(SYSTEM.ADR(buf),off);  
  CutBufAtBlank;  (* Boosted can only handle one alternative *)
  COPY(buf,Options.commentEnd);
  dmy:=WB.lstrcpyA(SYSTEM.ADR(buf),stringstart);  
  COPY(buf,Options.stringDelims);
  Options.commentsNested:=nested#0;
END Comments;


PROCEDURE [_APICALL] SetHelpFile* (name:WD.LPSTR);
(* This function defines the help file which should be used for context
   sensitive help. This is usually a help file for a programming language. *)
VAR 
  dmy: WD.LPSTR;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in SetHelpFile "); END;
  dmy:=WB.lstrcpyA(SYSTEM.ADR(WinHnd.langHelpFile),name);  
END SetHelpFile;


PROCEDURE [_APICALL] GetFirstBuffer* (edit:WD.HWND; buf:WD.LPSTR; size:LONGINT): LONGINT;
(* This function is used in combination with GetNextBuffer to retrieve the contents of the 
   designated edit window via a small transfer buffer. This function has to be called once
   to start the transfer before GetNextBuffer can be used to retrieve the remainder of the
   text. 
   This function fills the transfer buffer with the first piece of text. The size of the 
   transfer buffer is defined in <size>.
   The return value of the function is the number of bytes which have been copied
   to the buffer. The end of the text has been reached when the return value is
   smaller than <size>. *)
VAR 
  hEdit : WD.HWND;
  ptr   : POINTER TO ARRAY OF CHAR; 
  r     : LONGINT;  
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GetFirstBuffer"); END;
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);
  NEW(ptr,size);
  ASSERT(ptr#NIL);
  r := FileHnd.GetFirstBuffer(hEdit, ptr^, size);
  SYSTEM.MOVE(SYSTEM.ADR(ptr^),buf,r);
  DISPOSE(ptr);
  RETURN r;
END GetFirstBuffer;


PROCEDURE [_APICALL] GetNextBuffer* (edit:WD.HWND; buf:WD.LPSTR; size:LONGINT): LONGINT;
(* This function is used to retrieve the contents of the designated edit window
   via a small transfer buffer. Each call to this function fills the transfer
   buffer with the next piece of text. The size of the transfer buffer is defined
   in <size>.
   The return value of the function is the number of bytes which have been copied
   to the buffer. The end of the text has been reached when the return value is
   smaller than <size>. *)
VAR 
  hEdit : WD.HWND;
  ptr   : POINTER TO ARRAY OF CHAR;
  r     : LONGINT;  
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GetNextBuffer"); END; 
  hEdit:=WU.GetWindow(edit, WU.GW_CHILD);  
  NEW(ptr,size);
  ASSERT(ptr#NIL);
  r := FileHnd.GetNextBuffer(hEdit, ptr^, size);
  SYSTEM.MOVE(SYSTEM.ADR(ptr^),buf,r);
  DISPOSE(ptr);
  RETURN r;  
END GetNextBuffer;


PROCEDURE [_APICALL] GeneratesAscii* (): INTEGER;
(* The return value of this function is 1 if the editor generates
   files in plain text ASCII format and 0 if the editor uses a 
   proprietary format.
   This implementation uses plain text ASCII format. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GeneratesAscii"); END;
  RETURN 1;
END GeneratesAscii;


PROCEDURE [_APICALL] LoadOpen* (file:WD.LPSTR): INTEGER;
(* This function is not supported. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in LoadOpen"); END;
  RETURN 0;
END LoadOpen;


PROCEDURE [_APICALL] LoadRead* (handle:INTEGER; 
                                buf:WD.LPSTR; 
                                size:LONGINT): LONGINT;
(* This function is not supported. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in LoadRead"); END;
  RETURN 0;
END LoadRead;


PROCEDURE [_APICALL] LoadClose* (handle:INTEGER);
(* This function is not supported. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in LoadClose"); END;
END LoadClose;


PROCEDURE [_APICALL] PrintWindow* (edit:WD.HWND): INTEGER;
(* The contents of the designated edit window is printed.
   This function displays a dialog box to determine print 
   parameters before the text is printed. *)
VAR 
  win    : EditWin.EditWin;
  title  : ARRAY 100 OF CHAR;
  len    : LONGINT;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in PrintWindow "); END;
  len:=WU.GetWindowTextA(edit,SYSTEM.ADR(title),LEN(title)-1);
  title[len]:=0X;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  RETURN Print.PrintFile(edit,win,title);
END PrintWindow;


PROCEDURE [_APICALL] InsertText* (edit:WD.HWND; text:WD.LPSTR): INTEGER;
(* The zero terminated string given in <text> is inserted at the
   current cursor position. *)
VAR 
  win  : EditWin.EditWin;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in InsertText "); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  win.SetUndoAction(TextWin.ACT_NONE);
  IF win.InsertText(text) THEN RETURN 1 ELSE RETURN 0 END;
END InsertText;


PROCEDURE [_APICALL] AddText* (edit:WD.HWND; text:WD.LPSTR): INTEGER;
(* The zero terminated string given in <text> is appended to the current
   contents of the edit window. *)
VAR 
  win  : TextWin.WinDesc;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in AddText"); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win#NIL THEN
    win.SetUndoAction(TextWin.ACT_NONE);
    RETURN WinHnd.AddText(win, text);
  ELSE
    RETURN 0;
  END;
END AddText;


PROCEDURE [_APICALL] ResizeWindow* (edit:WD.HWND; width,height:INTEGER);
(* The size of the designated edit window is changed to a width of <width> pixels 
   and a height of <height> pixels. The size defines the total size of the edit 
   window and not the size of the client area. *)
VAR 
  hEdit : WD.HWND;
  win   : TextWin.WinDesc;
  res   : WD.BOOL;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in ResizeWindow "); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  res:=WU.MoveWindow(win.hwnd,0,0,width,height,WD.True);
  win.ScreenConfig;
END ResizeWindow;


PROCEDURE [_APICALL] HasSelection* (edit:WD.HWND): INTEGER;
(* The return value of the function is 1 if text is selected in 
   the edit window and 0 if no text is selected. *)
VAR 
  win : TextWin.WinDesc; 
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in HasSelection "); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win.text.isSelected THEN RETURN 1 ELSE RETURN 0 END;
END HasSelection;


PROCEDURE [_APICALL] ResetContent*(edit:WD.HWND);
(* The designated edit window is cleared. *)
VAR 
  win   : TextWin.WinDesc; 
  dummy : LONGINT;
  done  : WD.BOOL;
  rect  : WD.RECT;
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in ResetContent "); END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win#NIL THEN
    win.text.ResetContents;
    win.ScreenConfig;
    win.row:=1;
    win.col:=1;
    win.textPos:=1;
    win.SetCaret;
    win.SetUndoAction(TextWin.ACT_NONE);
    done := WU.InvalidateRect(win.hwnd,rect,0);
    done := WU.UpdateWindow(win.hwnd);
  ELSE
    GlobWin.Beep;
  END;
END ResetContent;


PROCEDURE [_APICALL] GetText* (edit:WD.HWND): WD.HGLOBAL;
(* A global memory object handle to the text in the current editor window
   is returned.
   This function is not supported in this editor version and therefore
   always fails. *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GetText "); END;
  RETURN 0;
END GetText;


PROCEDURE [_APICALL] GetLine* (edit:WD.HWND;
                               row,max:INTEGER;
                               buf:WD.LPSTR): INTEGER;
(* The contents of the line number <row> is copied into the buffer <buf>.
   If the line contains more than <max> characters the line is truncated to
   avoid a buffer overflow. *)
VAR
  dmy     : WD.LPSTR;
  line    : ARRAY ListSt.MAXLENGTH OF CHAR; 
  len     : LONGINT;
  win     : TextWin.WinDesc;
  copied  : INTEGER;

BEGIN
  INC(row);
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in GetLine ") END;
  win:=EditWin.AssocWinObj(WU.GetWindow(edit, WU.GW_CHILD));
  IF win.text.GetLine( row, line, len) THEN
    IF len > max THEN
      SYSTEM.MOVE(SYSTEM.ADR(line),buf,max);
      copied:=max;
    ELSE 
      SYSTEM.MOVE(SYSTEM.ADR(line),buf,len);
      copied:=SHORT(len);
    END;
  ELSE
    copied:=0;
  END;
  RETURN copied;
END GetLine;


PROCEDURE [_APICALL] ShowHelp* (hEdit:WD.HWND);
(* The editor help file is shown *)
BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in ShowHelp"); END;
  GlobWin.ShowHelp(hEdit);
END ShowHelp;


PROCEDURE [_APICALL] EditOptions*();
(* A dialog window is opened which allows the user to change editor option
   settings.
   This editor implementation stores the options selected by the user in the
   file "boosted.ini". *)
VAR 
  hdc                : WD.HDC;
  hObj               : WD.HGDIOBJ;
  res                : LONGINT;
  i                  : INTEGER;
  oldFocus,dhwnd     : WD.HWND;
  done               : WD.BOOL;
  lfHeight           : LONGINT;

BEGIN
  IF TRACE_CALLS THEN GlobWin.DisplayError("","in EditOptions"); END;
  OptionDialogs.EditOptions;
  
  FOR i:=0 TO WinHnd.wCounter-1 DO
    hObj:=WG.SelectObject(WinHnd.wList[i].hdc,WinHnd.wList[i].oldFont);
  END;
  IF WinHnd.wCounter>0 THEN
    IF WG.DeleteObject(WinHnd.hFont)=0 THEN GlobWin.DisplayError("ERROR","Can not delete current font"); END; 
    hdc:=WU.GetDC(WD.NULL);
    lfHeight:=-WB.MulDiv(Options.fontSize,
                         WG.GetDeviceCaps(hdc,WG.LOGPIXELSY),
                         72);
    res:=WU.ReleaseDC(WD.NULL,hdc);
    WinHnd.hFont := WG.CreateFontA(lfHeight,
                                   0,0,0,0,0,0,0,0,0,0,
                                   WG.DEFAULT_QUALITY,
                                   WG.FIXED_PITCH,
                                   SYSTEM.ADR(Options.fontName));
    oldFocus:=WD.NULL;
    FOR i:=0 TO WinHnd.wCounter-1 DO
      IF oldFocus=WD.NULL THEN
        oldFocus:=WU.SetFocus(WinHnd.wList[i].hwnd);
      ELSE
        dhwnd:=WU.SetFocus(WinHnd.wList[i].hwnd);
      END;
      WinHnd.SetWindowOldFont(i,WG.SelectObject(WinHnd.wList[i].hdc,WinHnd.hFont));
      WinHnd.wList[i].ScreenConfig;          
      done := WU.InvalidateRect(WinHnd.wList[i].hwnd,NIL,0);
      WinHnd.wList[i].CursGoto(WinHnd.wList[i].row,WinHnd.wList[i].col);
    END;
    dhwnd:=WU.SetFocus(oldFocus);
  END;
END EditOptions;


PROCEDURE [_APICALL] UnloadEditor*;
(* This function is obsolete in the Win32 API based version of BoostEd.
   Cleaning up can be done in the DllEntryPoint procedure. *)
BEGIN
END UnloadEditor;


PROCEDURE [_APICALL] DllEntryPoint* (hInst:WD.HINSTANCE;
                                     reason:WD.DWORD;
                                     reserved:WD.LPVOID): WD.BOOL;
(* This function is called by the NT program loader when the editor DLL is 
   loaded or unloaded *)
BEGIN
  IF reason=WN.DLL_PROCESS_ATTACH THEN
    GlobWin.hInstance:=hInst;     (* remember DLL instance handle for later use *)
    IF ~WinHnd.RegisterClass() THEN (* register window class for editor windows *)
      GlobWin.Beep;
      RETURN WD.False;
    END;
    EnvHnd.ReadIniFile();
  ELSIF reason=WN.DLL_PROCESS_DETACH THEN
    WinHnd.CloseAllWindows;       
    WinHnd.UnregisterClass;       (* unregister window class for editor windows *)
  END;
  RETURN WD.True;
END DllEntryPoint;

END Boosted32.
  

