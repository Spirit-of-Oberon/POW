(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  09-01-1997 rel. 32/1.0 LEI                                                *)
(**---------------------------------------------------------------------------  
  This is an internal module of the Win32 OPAL implementation.
  ----------------------------------------------------------------------------*)

MODULE InOut;

IMPORT SYSTEM,Panes,ListPane,
       WD:=WinDef, WU:=WinUser, WG:=WinGDI, WC:=CommDlg,
       Utils,Strings,Float,
       WinUtils,Process,AppGrp,
       Volume,InBuffer,InEdit;

CONST
  MAXKEYBUF=1000;
  MAXPROMPT=100;

TYPE
  InOutT*=RECORD (Panes.Group)
    lp-:ListPane.ListPaneP;
    edit-:InEdit.Edit;
    menuModified:BOOLEAN;
    changeToFile:BOOLEAN;
    appendFromKeyboard:BOOLEAN;
    buffer:InBuffer.BufferT;
    keybuf:InBuffer.BufferT;
    tmp:POINTER TO ARRAY MAXKEYBUF+1 OF CHAR;
    prompt:ARRAY MAXPROMPT OF CHAR;
    doPrompt:BOOLEAN;
  END;
  InOut*=POINTER TO InOutT;


PROCEDURE (VAR p:InOutT) Init*;
VAR
  res:BOOLEAN;
BEGIN
  p.Init^;
  NEW(p.lp);
  ASSERT(p.lp#NIL);
  p.lp.Init;
  NEW(p.edit);
  ASSERT(p.edit#NIL);
  NEW(p.tmp);
  ASSERT(p.tmp#NIL);
  p.edit.Init;
  p.edit.corner1.Init(0,0);
  p.edit.growRelativex1:=FALSE;
  p.edit.growRelativey1:=FALSE;
  p.edit.corner2.Init(1000,50);
  p.edit.growRelativex2:=TRUE;
  p.edit.growRelativey2:=FALSE;
  p.lp.corner1.Init(0,51);
  p.lp.growRelativex1:=FALSE;
  p.lp.growRelativey1:=FALSE;
  p.lp.corner2.Init(1000,1000);
  p.lp.growRelativex2:=TRUE;
  p.lp.growRelativey2:=TRUE;
  p.lp.SetCaptionVisible(FALSE);
  p.lp.focusRedirection:=p.edit;
  p.focusRedirection:=p.edit;
  p.menuModified:=FALSE;
  p.appendFromKeyboard:=TRUE;
  p.changeToFile:=FALSE;
  res:=p.buffer.InitEx(65000);
  ASSERT(res);
  res:=p.keybuf.InitEx(1000);
  ASSERT(res);
  p.framed:=TRUE;
  p.doPrompt:=FALSE;
END Init;

PROCEDURE (p:InOut) InsertionInit*(top:BOOLEAN):BOOLEAN;
VAR
  res:BOOLEAN;
BEGIN
  res:=p.Insert(p.edit);
  ASSERT(res);
  res:=p.Insert(p.lp);
  ASSERT(res);
  RETURN p.InsertionInit^(top);
END InsertionInit;

PROCEDURE (p:InOut) AdaptSize*;
BEGIN
  p.lp.corner1.y:=p.edit.corner2.y+1;
  p.AdaptSize^;
END AdaptSize;

PROCEDURE (p:InOut) ShowExitButton*;
BEGIN
  p.edit.ShowExitButton;
END ShowExitButton;

PROCEDURE (p:InOut) WaitForExitButton*;
BEGIN
  WHILE ~p.edit.exitClicked DO Process.Yield END;
END WaitForExitButton;

PROCEDURE (p:InOut) ShowFocusMark*(x:BOOLEAN);
VAR
  dummy:WD.BOOL;
  app:AppGrp.AppP;
BEGIN
  app:=AppGrp.GetApp();
  IF x & ~p.menuModified THEN
    dummy:=WU.AppendMenuA(app.popup,WU.MF_STRING,Panes.AM_INPUTFROM,SYSTEM.ADR("&read input from file..."));
    dummy:=WU.AppendMenuA(app.popup,WU.MF_STRING,Panes.AM_SAVEINPUT,SYSTEM.ADR("&save input to file..."));
    p.menuModified:=dummy#0;
    IF (p.edit#NIL) & ~p.edit.acceptInput THEN
      dummy:=WU.EnableMenuItem(app.popup,
                            Panes.AM_INPUTFROM,
                            SYSTEM.BITOR(WU.MF_BYCOMMAND,WU.MF_GRAYED));
    END;
  ELSIF ~x & p.menuModified THEN
    dummy:=WU.RemoveMenu(app.popup,Panes.AM_INPUTFROM,WU.MF_BYCOMMAND);
    dummy:=WU.RemoveMenu(app.popup,Panes.AM_SAVEINPUT,WU.MF_BYCOMMAND);
    p.menuModified:=~(dummy#0);
  END;
  p.ShowFocusMark^(x);
END ShowFocusMark;

PROCEDURE TranslateLF(VAR t:ARRAY OF CHAR);
VAR
  i:LONGINT;
BEGIN
  FOR i:=0 TO Strings.Length(t)-1 DO
    IF t[i]="$" THEN t[i]:=0AX 
    ELSIF t[i]="°" THEN t[i]:='"'
    END;
  END;
END TranslateLF;

PROCEDURE (p:InOut) Reset*();
BEGIN
  p.buffer.SeekStart;
  p.edit.ChangeText("");
END Reset;

PROCEDURE (p:InOut) PrepKeyInput(VAR done:BOOLEAN; txt:ARRAY OF CHAR):BOOLEAN;
BEGIN
  IF ~p.appendFromKeyboard THEN
    done:=FALSE;
    RETURN FALSE;
  END;
  done:=TRUE;
  p.edit.AcceptInput(TRUE);
  IF p.doPrompt THEN
    p.edit.ChangeText(p.prompt);
    p.doPrompt:=FALSE;
  ELSE
    p.edit.ChangeText(txt);
  END;
  RETURN TRUE;
END PrepKeyInput;

PROCEDURE (p:InOut) DoKeyInput(waitEdit:BOOLEAN);
BEGIN
  p.edit.newInput:=FALSE;
  IF p.edit.buffer="" THEN waitEdit:=TRUE END;
  REPEAT Process.Yield UNTIL p.edit.newInput OR 
                             p.edit.endClicked OR 
                             p.changeToFile OR
                             (~waitEdit & (p.edit.buffer#""));
  IF p.changeToFile THEN
    p.appendFromKeyboard:=FALSE;
    p.edit.AcceptInput(FALSE);
  END;
END DoKeyInput;

PROCEDURE (p:InOut) KeyErrMsg(code:LONGINT; txt:ARRAY OF CHAR; VAR msg:LONGINT);
BEGIN
  IF code=InBuffer.ERRSYNTAX THEN
    TranslateLF(txt);
    msg:=WU.MessageBoxA(WD.NULL,
                      SYSTEM.ADR(txt),
                      SYSTEM.ADR("Error"),
                      Utils.BitOr(Utils.BitOr(
                        WU.MB_RETRYCANCEL,
                        WU.MB_ICONEXCLAMATION),
                        WU.MB_TASKMODAL));
  ELSIF code=InBuffer.ERRBOUNDS THEN
    msg:=WU.MessageBoxA(WD.NULL,
                      SYSTEM.ADR("parameter out of range"),
                      SYSTEM.ADR("Error"),
                      Utils.BitOr(Utils.BitOr(
                        WU.MB_RETRYCANCEL,
                        WU.MB_ICONEXCLAMATION),
                        WU.MB_TASKMODAL));
  ELSE msg:=0 END;
  IF msg=WU.IDCANCEL THEN p.appendFromKeyboard:=FALSE END;
END KeyErrMsg;

PROCEDURE (p:InOut) CheckKeyEnd(VAR done:BOOLEAN);
BEGIN
  p.edit.ChangeText("");
  Process.Yield;
  IF p.edit.endClicked THEN 
    done:=FALSE;
    p.appendFromKeyboard:=FALSE;
  END;
END CheckKeyEnd;

PROCEDURE (p:InOut) MoveKeyBuffer;
BEGIN
  p.keybuf.GetLeftover(p.tmp^);
  p.edit.SetInput(p.tmp^);
END MoveKeyBuffer;

PROCEDURE (p:InOut) ReadChar*(VAR ch:CHAR; VAR done:BOOLEAN);
VAR
  code,msg:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    ch:=0X;
    IF ~p.PrepKeyInput(done,"In.Char") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadChar(ch,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetChar(ch,done,code);
        p.KeyErrMsg(code,"could not read char from input stream",msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN
      p.MoveKeyBuffer;
      p.buffer.AppendChar(ch);
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetChar(ch,done,code);
  END;
END ReadChar;

PROCEDURE (p:InOut) ReadInt*(VAR x:INTEGER; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  t:ARRAY 50 OF CHAR;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    x:=0;
    IF ~p.PrepKeyInput(done,"In.Int") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadInt(x,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetInt(x,done,code);
        p.KeyErrMsg(code,'could not read integer from input stream$IntConst = ["-"] (digit {digit} | digit {hexDigit} "H")',msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      Strings.Str(x,t);
      p.buffer.Append(t);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetInt(x,done,code);
  END;
END ReadInt;

PROCEDURE (p:InOut) ReadLongInt*(VAR x:LONGINT; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  t:ARRAY 50 OF CHAR;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    x:=0;
    IF ~p.PrepKeyInput(done,"In.LongInt") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadLongInt(x,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetLongInt(x,done,code);
        p.KeyErrMsg(code,'could not read long integer from input stream$IntConst = [-] (digit {digit} | digit {hexDigit} "H")',msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      Strings.Str(x,t);
      p.buffer.Append(t);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetLongInt(x,done,code);
  END;
END ReadLongInt;

PROCEDURE (p:InOut) ReadReal*(VAR x:REAL; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  t:ARRAY 50 OF CHAR;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    x:=0;
    IF ~p.PrepKeyInput(done,"In.Real") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadReal(x,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetReal(x,done,code);
        p.KeyErrMsg(code,'could not read real from input stream$RealConst = ["-"] digit {digit} [ "." {digit} ] ["E" [("+" | "-")] digit {digit} ]',msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      Float.Str(x,t);
      p.buffer.Append(t);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetReal(x,done,code);
  END;
END ReadReal;

PROCEDURE (p:InOut) ReadLongReal*(VAR x:LONGREAL; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  t:ARRAY 50 OF CHAR;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    x:=0;
    IF ~p.PrepKeyInput(done,"In.LongReal") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadLongReal(x,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetLongReal(x,done,code);
        p.KeyErrMsg(code,'could not read long real from input stream$RealConst = ["-"] digit {digit} [ "." {digit} ] ["E" [("+" | "-")] digit {digit} ]',msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      Float.Str(x,t);
      p.buffer.Append(t);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetLongReal(x,done,code);
  END;
END ReadLongReal;

PROCEDURE (p:InOut) ReadName*(VAR t:ARRAY OF CHAR; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    t[0]:=0X;
    IF ~p.PrepKeyInput(done,"In.Name") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadName(t,done); RETURN END;
      IF ~p.edit.endClicked THEN
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetName(t,done,code);
        p.KeyErrMsg(code,"could not read name from input stream$NameConst = nameChar {nameChar}",msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      p.buffer.Append(t);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetName(t,done,code);
  END;
END ReadName;

PROCEDURE (p:InOut) ReadStr*(VAR t:ARRAY OF CHAR; VAR done:BOOLEAN);
VAR
  msg:LONGINT;
  i:LONGINT;
  ch:CHAR;
  code:LONGINT;
BEGIN
  IF p.buffer.AtEnd() THEN
    t[0]:=0X;
    IF ~p.PrepKeyInput(done,"In.String") THEN RETURN END;
    REPEAT
      p.DoKeyInput(~done);
      IF p.changeToFile THEN p.ReadStr(t,done); RETURN END;
      IF ~p.edit.endClicked THEN
        IF (p.edit.buffer[0]#"'") & (p.edit.buffer[0]#'"') THEN
          Strings.InsertChar('"',p.edit.buffer,1);
          Strings.AppendChar(p.edit.buffer,'"');
        END;
        p.keybuf.Clear;
        p.keybuf.Append(p.edit.buffer);
        p.keybuf.GetStr(t,done,code);
        p.KeyErrMsg(code,"could not read string from input stream$StringConst = ' ° ' {char} ' ° '",msg);
      END;
    UNTIL done OR (msg=WU.IDCANCEL) OR p.edit.endClicked;
    p.CheckKeyEnd(done);
    IF done THEN 
      p.MoveKeyBuffer;
      i:=0;
      WHILE (t[i]#0X) & (t[i]#'"') DO INC(i) END;
      IF t[i]='"' THEN ch:="'" ELSE ch:='"' END;
      p.buffer.AppendChar(ch);
      p.buffer.Append(t);
      p.buffer.AppendChar(ch);
      p.buffer.AppendChar(" ");
      p.buffer.SeekEnd();
    END;
    p.edit.AcceptInput(FALSE);
  ELSE
    p.buffer.GetStr(t,done,code);
  END;
END ReadStr;

PROCEDURE (p:InOut) ChangeInputToFile*();
VAR
  ofn:WC.OPENFILENAME;
  currentDir,filename,file:ARRAY 200 OF CHAR;
  res:WD.BOOL;
  res2:Volume.RetCodeT;
  filters,customFilter:ARRAY 100 OF CHAR;
  i:LONGINT;
BEGIN
  Volume.CurrentDirectory(currentDir,res2);
  filters:="text files$*.txt$all files$*.*$$";
  file:="";
  customFilter:="";
  FOR i:=0 TO LEN(filters)-1 DO IF filters[i]="$" THEN filters[i]:=0X END END;
  ofn.lStructSize:=SIZE(WC.OPENFILENAME);
  ofn.hwndOwner:=p.hwnd;
  ofn.lpstrFilter:=SYSTEM.ADR(filters);
  ofn.lpstrCustomFilter:=SYSTEM.ADR(customFilter);
  ofn.nMaxCustFilter:=LEN(customFilter);
  ofn.nFilterIndex:=1;
  ofn.lpstrFile:=SYSTEM.ADR(file);
  ofn.nMaxFile:=LEN(file);
  ofn.lpstrFileTitle:=SYSTEM.ADR(filename);
  ofn.nMaxFileTitle:=LEN(filename);
  ofn.lpstrInitialDir:=SYSTEM.ADR(currentDir);
  ofn.lpstrTitle:=SYSTEM.ADR("input from file");
  ofn.Flags:=Utils.BitOrL(WC.OFN_PATHMUSTEXIST,
             Utils.BitOrL(WC.OFN_FILEMUSTEXIST,
             WC.OFN_HIDEREADONLY));
  ofn.nFileOffset:=0;
  ofn.nFileExtension:=0;
  ofn.lpstrDefExt:=SYSTEM.ADR("");
  ofn.lpfnHook:=NIL;
  ofn.lpTemplateName:=WD.NULL;
  IF WC.GetOpenFileNameA(ofn)#0 THEN
    p.edit.ChangeText("");
    p.buffer.AppendFile(file);
    p.appendFromKeyboard:=FALSE;
    p.changeToFile:=TRUE;
  END;
END ChangeInputToFile;

PROCEDURE (p:InOut) SaveInputToFile*();
VAR
  ofn:WC.OPENFILENAME;
  currentDir,filename,file:ARRAY 200 OF CHAR;
  res:WD.BOOL;
  res2:Volume.RetCodeT;
  filters,customFilter:ARRAY 100 OF CHAR;
  i:LONGINT;
BEGIN
  Volume.CurrentDirectory(currentDir,res2);
  filters:="text files$*.txt$all files$*.*$$";
  file:="";
  customFilter:="";
  FOR i:=0 TO LEN(filters)-1 DO IF filters[i]="$" THEN filters[i]:=0X END END;
  ofn.lStructSize:=SIZE(WC.OPENFILENAME);
  ofn.hwndOwner:=p.hwnd;
  ofn.lpstrFilter:=SYSTEM.ADR(filters);
  ofn.lpstrCustomFilter:=SYSTEM.ADR(customFilter);
  ofn.nMaxCustFilter:=LEN(customFilter);
  ofn.nFilterIndex:=1;
  ofn.lpstrFile:=SYSTEM.ADR(file);
  ofn.nMaxFile:=LEN(file);
  ofn.lpstrFileTitle:=SYSTEM.ADR(filename);
  ofn.nMaxFileTitle:=LEN(filename);
  ofn.lpstrInitialDir:=SYSTEM.ADR(currentDir);
  ofn.lpstrTitle:=SYSTEM.ADR("save input to file");
  ofn.Flags:=Utils.BitOrL(WC.OFN_PATHMUSTEXIST,
             Utils.BitOrL(WC.OFN_OVERWRITEPROMPT,
             WC.OFN_HIDEREADONLY));
  ofn.nFileOffset:=0;
  ofn.nFileExtension:=0;
  ofn.lpstrDefExt:=SYSTEM.ADR("");
  ofn.lpfnHook:=NIL;
  ofn.lpTemplateName:=WD.NULL;
  IF WC.GetSaveFileNameA(ofn)#0 THEN p.buffer.SaveFile(file) END;
END SaveInputToFile;

PROCEDURE (p:InOut) Prompt*(VAR txt:ARRAY OF CHAR);
BEGIN
  COPY(txt,p.prompt);
  p.doPrompt:=TRUE;
END Prompt;

PROCEDURE (p:InOut) Print*;
BEGIN
  IF p.lp#NIL THEN p.lp.Print END;
END Print;

PROCEDURE (p:InOut) CopyAllToClipboard*;
BEGIN
  IF p.lp#NIL THEN p.lp.CopyAllToClipboard END;
END CopyAllToClipboard;

END InOut.
