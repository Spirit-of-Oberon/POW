(******************************************************************************
 *  Module Syntax
 *  
 *  This module provides hard coded Oberon-2 specific syntax support
 *  to automatically complete frequently used constructs as they are typed.
 ******************************************************************************)

MODULE Syntax;


IMPORT List := ListSt, Strings, Options, GlobWin;


CONST
  MAXIDENT=40;
  FLNOTHING=0;
  FLEND=1;
  FLBEGIN=2;
  FLWHILE=3;
  FLREPEAT=4;
  FLUNTIL=5;
  FLFOR=6;
  FLIF=7;
  FLELSIF=8;
  FLELSE=9;
  FLPROCEDURE=10;
  FLCONST=11;
  FLVAR=12;
  FLTYPE=13;
  FLLOOP=14;
  FLWITH=15;
  FLCASE=16;
  FLALTERNATIVE*=17;
  

TYPE
  LineAnalyzerT=RECORD
    txt                                 : ARRAY List.MAXLENGTH+1 OF CHAR;
    procName                            : ARRAY MAXIDENT+1 OF CHAR;
    indent,len,paramIndent,indentChange : LONGINT;
    startFlag,endFlag                   : INTEGER;
  END;


PROCEDURE IsIdentChar*(ch:CHAR):BOOLEAN;
(* prüft, ob das übergebene Zeichen ein Buchstabe, eine Zahl oder ein Underscore ist *)
BEGIN
  RETURN (ch="_") OR 
         ((ch>="a") & (ch<="z")) OR 
         ((ch>="A") & (ch<="Z")) OR 
         ((ch>="0") & (ch<="9"));
END IsIdentChar;

(*********************************************************************************************)

PROCEDURE GetIdent(VAR txt:ARRAY OF CHAR; 
                   VAR ident:ARRAY OF CHAR;
                   VAR inx:LONGINT);
(* liefert einen Textbereich zurück *)
VAR
  i : LONGINT;
BEGIN
  i:=0;
  WHILE IsIdentChar(txt[inx]) & (i<LEN(ident)-1) DO
    ident[i]:=txt[inx];
    INC(i);
    INC(inx);
  END;
  ident[i]:=0X;
END GetIdent;

(*********************************************************************************************)

PROCEDURE SkipBlanks(VAR txt:ARRAY OF CHAR; VAR inx:LONGINT);
(* überspringt Leerzeichen *)
BEGIN
  WHILE txt[inx]=" " DO INC(inx) END;
END SkipBlanks;

(*********************************************************************************************)

PROCEDURE InitIndent(indent:LONGINT; VAR txt:ARRAY OF CHAR);
(* Initialisierung eines Ident *)
BEGIN
  IF indent>LEN(txt)-1 THEN indent:=LEN(txt)-1 END;
  IF indent<0 THEN indent:=0 END;
  txt[indent]:=0X;
  WHILE indent>0 DO
    DEC(indent);
    txt[indent]:=" ";
  END;
END InitIndent;

(*********************************************************************************************)

PROCEDURE (VAR line:LineAnalyzerT) Init(text:List.Text; row:LONGINT);
(* Initialisierung *)
VAR
  inx,i,h : LONGINT;
  ident   : ARRAY MAXIDENT+1 OF CHAR;
BEGIN
  line.txt:="";
  line.indent:=0;
  line.paramIndent:=0;
  line.indentChange:=0;
  line.len:=0;
  line.startFlag:=FLNOTHING;
  line.endFlag:=FLNOTHING;
  IF ~text.GetLine(row,line.txt,line.len) THEN RETURN END;
  WHILE line.txt[line.indent]=" " DO INC(line.indent) END;
  Strings.RemoveLeadingSpaces(line.txt);
  Strings.RemoveTrailingSpaces(line.txt);
  line.len:=Strings.Length(line.txt);
  inx:=0;
  GetIdent(line.txt,ident,inx);
  line.startFlag:=FLNOTHING;
  IF ident="PROCEDURE" THEN
    line.startFlag:=FLPROCEDURE;
    line.indentChange:=0;
    SkipBlanks(line.txt,inx);
    IF line.txt[inx]="^" THEN 
      line.startFlag:=FLNOTHING;
      RETURN;
    END;
    IF line.txt[inx]="[" THEN
      WHILE (line.txt[inx]#"]") & (line.txt[inx]#0X) DO INC(inx) END;
      IF line.txt[inx]="]" THEN INC(inx) END;
    END;
    IF line.txt[inx]="(" THEN
      WHILE (line.txt[inx]#")") & (line.txt[inx]#0X) DO INC(inx) END;
      IF line.txt[inx]=")" THEN INC(inx) END;
    END;
    SkipBlanks(line.txt,inx);
    GetIdent(line.txt,line.procName,inx);
    WHILE (line.txt[inx]=" ") OR (line.txt[inx]="*") DO INC(inx) END;
    IF (line.len>inx+2) & (line.txt[inx]="(") THEN
      i:=0;
      h:=inx+1;
      WHILE line.txt[inx]#0X DO
        IF line.txt[inx]="(" THEN INC(i)
        ELSIF line.txt[inx]=")" THEN DEC(i)
        END;
        INC(inx);
      END;
      IF i>0 THEN line.paramIndent:=h ELSE line.paramIndent:=0 END;
    END;
  ELSIF ident="WHILE" THEN
    line.indentChange:=1;
    line.startFlag:=FLWHILE;
  ELSIF ident="REPEAT" THEN
    line.indentChange:=1;
    line.startFlag:=FLREPEAT;
  ELSIF ident="FOR" THEN
    line.indentChange:=1;
    line.startFlag:=FLFOR;
  ELSIF ident="LOOP" THEN
    line.indentChange:=1;
    line.startFlag:=FLLOOP;
  ELSIF ident="IF" THEN
    line.indentChange:=1;
    line.startFlag:=FLIF;
  ELSIF ident="VAR" THEN
    line.indentChange:=1;
    line.startFlag:=FLVAR;
  ELSIF ident="CONST" THEN
    line.indentChange:=1;
    line.startFlag:=FLCONST;
  ELSIF ident="TYPE" THEN
    line.indentChange:=1;
    line.startFlag:=FLTYPE;
  ELSIF ident="BEGIN" THEN
    line.indentChange:=1;
    line.startFlag:=FLBEGIN;
  ELSIF ident="END" THEN
    line.indentChange:=-1;
    line.startFlag:=FLEND;
  ELSIF ident="UNTIL" THEN
    line.indentChange:=-1;
    line.startFlag:=FLUNTIL;
  ELSIF ident="ELSIF" THEN
    line.indentChange:=1;
    line.startFlag:=FLELSIF;
  ELSIF ident="ELSE" THEN
    line.indentChange:=1;
    line.startFlag:=FLELSE;
  ELSIF ident="WITH" THEN
    line.indentChange:=1;
    line.startFlag:=FLWITH;
  ELSIF ident="CASE" THEN
    line.indentChange:=1;
    line.startFlag:=FLCASE;
  ELSIF (ident="") & (line.txt[inx]="|") THEN
    line.indentChange:=1;
    line.startFlag:=FLALTERNATIVE;
    INC(inx);
  END;
  line.endFlag:=FLNOTHING;
  IF line.startFlag#FLNOTHING THEN
    inx:=line.len-1;
    WHILE (inx>=0) & ((line.txt[inx]=" ") OR (line.txt[inx]=";") OR 
          ((inx>0) & (line.txt[inx]=")") & (line.txt[inx-1]="*"))) DO
      IF (inx>0) & (line.txt[inx]=")") & (line.txt[inx-1]="*") THEN
        DEC(inx,2);
        WHILE (inx>0) & ((line.txt[inx]#"(") OR (line.txt[inx+1]#"*")) DO DEC(inx) END;
      END;
      DEC(inx);
    END;
    IF (inx>2) & (line.txt[inx-2]="E") & (line.txt[inx-1]="N") & (line.txt[inx]="D") THEN
      line.endFlag:=FLEND;
      DEC(line.indentChange);
    END;
  END;
END Init;

(*********************************************************************************************)

PROCEDURE Analyze*(row:LONGINT; text:List.Text; VAR noNewLine:BOOLEAN);
(* Analysieren eines Textes *)
VAR
  line,nextLine,prevLine : LineAnalyzerT;
  txt                    : ARRAY List.MAXLENGTH+1 OF CHAR;
  done                   : BOOLEAN;
BEGIN
  noNewLine:=FALSE;
  line.Init(text,row);
  nextLine.Init(text,row+1);
  prevLine.Init(text,row-1);
  IF (line.startFlag=FLPROCEDURE) & (nextLine.startFlag#FLBEGIN) &
     (nextLine.startFlag#FLVAR) & (nextLine.startFlag#FLTYPE) &
     (nextLine.startFlag#FLCONST) THEN
    InitIndent(line.indent,txt);
    Strings.Append(txt,"END ");
    Strings.Append(txt,line.procName);
    Strings.Append(txt,";");
    done:=text.InsertLine(txt,row+1);
    InitIndent(line.indent,txt);
    Strings.Append(txt,"BEGIN");
    done:=text.InsertLine(txt,row+1);
    InitIndent(line.indent,txt);
    Strings.Append(txt,"VAR");
    done:=text.InsertLine(txt,row+1);
    IF line.paramIndent>0 THEN
      InitIndent(line.indent+line.paramIndent,txt);
      done:=text.InsertLine(txt,row+1);
    END;
    noNewLine:=TRUE;
    
  ELSIF (line.startFlag=FLVAR) OR
        (line.startFlag=FLCONST) OR
        (line.startFlag=FLTYPE) THEN
    InitIndent(line.indent+Options.indentWidth,txt);
    done:=text.InsertLine(txt,row+1);
    noNewLine:=TRUE;
    
  ELSIF (line.startFlag=FLELSIF) OR (line.startFlag=FLELSE) THEN
    IF ((prevLine.indentChange-1=0) & (prevLine.indent<line.indent)) OR
       ((prevLine.indentChange-1<0) & (prevLine.indent=line.indent)) OR
       ((prevLine.startFlag=FLELSIF) & (prevLine.indent<line.indent)) THEN
      line.indent:=line.indent-Options.indentWidth;
      InitIndent(line.indent,txt);
      Strings.Append(txt,line.txt);
      done:=text.SetLine(row,txt);

      IF ~done THEN GlobWin.Beep END;

    END;
    IF line.endFlag#FLEND THEN line.indent:=line.indent+Options.indentWidth END;
    InitIndent(line.indent,txt);
    done:=text.InsertLine(txt,row+1);

    IF ~done THEN GlobWin.Beep END;

    noNewLine:=TRUE;
  
  ELSIF (line.indentChange<0) &
        (((prevLine.indentChange+line.indentChange=0) & (prevLine.indent<line.indent)) OR
        ((prevLine.indentChange+line.indentChange<0) & (prevLine.indent=line.indent))) THEN
    InitIndent(line.indent-Options.indentWidth,txt);
    Strings.Append(txt,line.txt);
    done:=text.SetLine(row,txt);

    IF ~done THEN GlobWin.Beep END;

    InitIndent(line.indent-Options.indentWidth,txt);
    done:=text.InsertLine(txt,row+1);

    IF ~done THEN GlobWin.Beep END;

    noNewLine:=TRUE;
    
  ELSIF line.indentChange>0 THEN
    IF ((line.startFlag=FLWHILE) OR (line.startFlag=FLFOR) OR 
       (line.startFlag=FLIF) OR (line.startFlag=FLLOOP) OR 
       (line.startFlag=FLWITH) OR (line.startFlag=FLCASE)) & 
       (nextLine.indent#line.indent+Options.indentWidth) &
       ~((nextLine.startFlag=FLEND) & (nextLine.indent=line.indent)) THEN
      InitIndent(line.indent,txt);
      Strings.Append(txt,"END;");
      done:=text.InsertLine(txt,row+1);
    ELSIF (line.startFlag=FLREPEAT) & (nextLine.indent#line.indent+Options.indentWidth) THEN
      InitIndent(line.indent,txt);
      Strings.Append(txt,"UNTIL ;");
      done:=text.InsertLine(txt,row+1);
    END;
    InitIndent(line.indent+Options.indentWidth,txt);
    done:=text.InsertLine(txt,row+1);
    noNewLine:=TRUE;
    
  END;
END Analyze;

END Syntax.
