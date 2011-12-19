MODULE SymElem;

(********************************************************************************
 * Autor   : Gerhard Kurka                                                      *
 * Project : Symbol file browser ( viewer ) for POW-Oberon-2 symbol-files       *
 ********************************************************************************
 * PURPOSE: Implementation of an abstract basic class for a sym-type.           *
 ********************************************************************************)

TYPE PSymElement*=POINTER TO SymElement;
     SymElement*=RECORD
                   next* : PSymElement;
                   nextH : PSymElement;
                   symID*: INTEGER;
                 END;

VAR
  symChain: PSymElement;
  help    : PSymElement;

(**************************************************************************
 * Read a complete sym-type from file and inserts the type into a linked  *
 * list, which is neccessary for fixup                                    *
 **************************************************************************)
PROCEDURE (self:PSymElement) ReadSymInformation*();
BEGIN
  self.nextH := NIL;
  IF help # NIL THEN
    help.nextH:= self;
    help := help.nextH;
  ELSE
    symChain := self;
    help     := self;
  END;  
END ReadSymInformation;

(***************************************************************
 * Displays local symbol specific information.                 *
 ***************************************************************)
PROCEDURE (self:PSymElement) DisplaySymInformation*();
BEGIN
END DisplaySymInformation;

(*****************************************************************************************)
(* This procedure will be called by "IterateOverAllSyms" after the symfile has been read *)
(* completely                                                                            *)
(*****************************************************************************************)
PROCEDURE (self:PSymElement) FixTypeInfo*();
BEGIN
END FixTypeInfo;

(*************************************************************************************)
(* This method is similarly to FixTypeInfo, but it will be called after FixTypeInfo  *)
(* in a third pass                                                                   *)
(*************************************************************************************)
PROCEDURE (self:PSymElement) PrepareSymElement*();
BEGIN
END PrepareSymElement;

PROCEDURE IterateOverAllSyms*();
BEGIN
  help := symChain;
  WHILE help # NIL DO
    help.FixTypeInfo();
    help :=help.nextH;
  END;
  help := symChain;
  WHILE help # NIL DO
    help.PrepareSymElement();
    help :=help.nextH;
  END; 
END IterateOverAllSyms;  

BEGIN
  symChain := NIL;
  help     := NIL;
END SymElem.