MODULE SymLists;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * PURPOSE: Provides a set of lists to handle the different symElements to get  *
 *          an ordered output.                                                  *
 ********************************************************************************)


IMPORT SymElem, Display:=PowDDE;

TYPE
PWrapper = POINTER TO Wrapper;
Wrapper  = RECORD
             item : SymElem.PSymElement;
             next : PWrapper;
           END;

PSymList* = POINTER TO SymList;
SymList*  = RECORD
              itemChain : PWrapper;
              rider     : PWrapper;
            END;

PFieldList* = POINTER TO FieldList; (* Own Type for Field-Lists (RECORDS) *)
FieldList*  = RECORD (SymList)
              END;
                               
VAR
  help : PWrapper;

  typeList-      : PSymList;
  variableList-  : PSymList;
  parameterList- : PSymList;
  procedureList- : PSymList;
  tprocedureList-: PSymList;
  cdeclprocedureList-: PSymList;
  wprocedureList-: PSymList;
  cprocedureList-: PSymList;
  procTypeList-  : PSymList;
  paramListList- : PSymList;
  arrayList-     : PSymList;
  dynArrayList-  : PSymList;
  pointerList-   : PSymList;
  recordList-    : PFieldList;
  fieldListList- : PSymList;
  hdPtrOffsList- : PSymList;
  hdtProcList-   : PSymList;
  nmethList-     : PSymList;
  fixList-       : PSymList;
  sysList-       : PSymList;
  constList-     : PSymList;
  moduleList-    : PSymList;


PROCEDURE (self:PSymList) IsEmpty*():BOOLEAN;
BEGIN
  RETURN self.itemChain = self.itemChain.next;
END IsEmpty;
           
PROCEDURE (self:PSymList) Add*(sym: SymElem.PSymElement);
BEGIN
  help := self.itemChain;
  WHILE help.next # self.itemChain DO
    help:=help.next;
  END;
  NEW(help.next);
  help.next.item := sym;
  help.next.next := self.itemChain;
END Add;

PROCEDURE (self:PSymList) Describe*(headLine: ARRAY OF CHAR);
BEGIN
  IF self.itemChain.next # self.itemChain THEN
    IF headLine # 'invisible' THEN
      Display.WriteStr(headLine);
      Display.WriteLn();
    END;
    help := self.itemChain;
    WHILE help.next # self.itemChain DO
      help := help.next;
      help.item.DisplaySymInformation(); 
    END;
    IF headLine # 'invisible' THEN      
      Display.WriteLn();
    END;
  END;
END Describe;

PROCEDURE (self:PSymList) Init();
BEGIN
  NEW(self.itemChain);
  self.itemChain.next := self.itemChain;
  self.itemChain.item := NIL;
  self.rider          := NIL;
END Init;

PROCEDURE (self:PSymList) ResetRider*();
BEGIN
  self.rider := NIL;
END ResetRider;

PROCEDURE (self:PSymList) Next*(): SymElem.PSymElement;
BEGIN
  IF self.rider = NIL THEN
    self.rider := self.itemChain.next;
  ELSE 
    IF self.rider # self.itemChain THEN
      self.rider := self.rider.next;
    END
  END;
  IF self.rider # self.itemChain THEN
    RETURN self.rider.item;
  ELSE
    RETURN NIL;
  END;
END Next;

PROCEDURE (self:PSymList) RemoveCurrent*();
VAR
  h: PWrapper;
  l: PWrapper;
BEGIN
  IF (self.rider # NIL) & (self.rider # self.itemChain) THEN
    h := self.rider.next;
    IF h = self.itemChain THEN
      self.itemChain := self.rider;
    END;
    self.rider.item := h.item;
    self.rider.next := h.next;
    DISPOSE(h);
  END;
END RemoveCurrent;
        
PROCEDURE (self:PFieldList) Describe*(headLine: ARRAY OF CHAR);
BEGIN
  IF self.itemChain.next # self.itemChain THEN
    IF headLine # 'invisible' THEN
      Display.WriteStr(headLine);
      Display.WriteLn();
    END;
    help := self.itemChain;
    WHILE help.next # self.itemChain DO
      help := help.next;
      help.item.DisplaySymInformation();
      IF help.next # self.itemChain THEN
        Display.WriteLn();
      END;
    END;
    IF headLine # 'invisible' THEN      
      Display.WriteLn();
    END;
  END;
END Describe;

BEGIN 
  NEW(typeList);        typeList.Init();
  NEW(variableList);    variableList.Init();
  NEW(parameterList);   parameterList.Init();
  NEW(procedureList);   procedureList.Init();
  NEW(tprocedureList);  tprocedureList.Init();
  NEW(cdeclprocedureList);  cdeclprocedureList.Init();
  NEW(wprocedureList);  wprocedureList.Init();
  NEW(cprocedureList);  cprocedureList.Init();
  NEW(procTypeList);    procTypeList.Init();
  NEW(paramListList);   paramListList.Init();
  NEW(arrayList);       arrayList.Init();
  NEW(dynArrayList);    dynArrayList.Init();
  NEW(pointerList);     pointerList.Init();
  NEW(recordList);      recordList.Init();
  NEW(fieldListList);   fieldListList.Init();
  NEW(hdPtrOffsList);   hdPtrOffsList.Init();
  NEW(hdtProcList);     hdtProcList.Init();
  NEW(nmethList);       nmethList.Init();
  NEW(fixList);         fixList.Init();
  NEW(sysList);         sysList.Init();
  NEW(constList);       constList.Init();
  NEW(moduleList);      moduleList.Init();
END SymLists.
