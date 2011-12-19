MODULE ExternM;

TYPE
  r0  = RECORD
          a  : SET;
          b* : POINTER TO r0;
        END;
        
  a1  = ARRAY 7 OF r0;
  
  r1* = RECORD 
          x  : INTEGER;
          y- : r0;
          u- : a1;
        END;
        
END ExternM.