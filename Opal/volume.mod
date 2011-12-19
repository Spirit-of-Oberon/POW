(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  06-22-1997 rel. 32/1.0 LEI                                                *)
(*  02-02-1999 Bug in Scan.Next; FindFirstFileA replaced by FindNextFileA     *)
(**---------------------------------------------------------------------------  
  The Volume module provides facilities for creating, searching, and modifying
  file directories.
  
  The module interface is designed to be applicable to different systems. 
  The following notes refer exclusively to the file system of MS-DOS.
  
   Drives are identified by letters. 
   The letter "A" refers to the first floppy disk, drive, "B" to the second, 
   and "C" to the first hard disk drive. All letters down to "Z" may be used, 
   but the settings vary from system to system. A drive is specified using 
   a single letter or a letter followed by a colon passed as parameter. 
   No distinction between uppercase and lowercase is made. For example, 
   "a", "A:" and "A" have the same meaning.
   
   A colon must be put after the drive identification when a path is defined, 
   a path being a combination of a drive name and a file name. The backslash
   "\" serves as a separating symbol between directory names. For compatibility
   with other systems the forward slash "/" may also be used. For example,
   a path statement "C:\" refers to the root directory of the drive C.
   
   For access to the current drive the drive identification may be omitted in 
   path statements. If the only the drive identification is given as a parameter 
   then a blank is passed as a reference to the current drive.
   
   File names are passed through to the operating system without any 
   modification. Therefore the rules for creating valid directory and 
   filenames under MS-DOS must be adhered to.

   All procedures with a parameter <resCode> return an error code. 
   This code can be used to check if the function was carried out 
   successfully (<resCode> = NOERROR) or indicate more details about the 
   cause of the error.
   
   All errors occurring during file or drive operations are indicated 
   by an appropriate error code there should be no cases where a 
   runtime error is reported or the program is terminated. It is the 
   programmer's responsibility to arrange for an error handling and to 
   avoid further errors. The procedure GetErrorMessage provides an 
   equivalent message for every possible error code and can be used for 
   building error diagnostic dialogs. 
  ----------------------------------------------------------------------------*)

MODULE Volume;

IMPORT SYSTEM,Strings,FileUtil,WB:=WinBase,WD:=WinDef;

CONST

  MAXPATH*=255;
  MAXFILENAME*=128; (** \NEWGROUP Error Codes *)

  NOERROR*        = FileUtil.NOERROR;              (** the operation was successfull              *)
  WRITEPROTECTED* = FileUtil.ERROR_WRITE_PROTECT;  (** attempted write to a write-protected drive *)
  PATHNOTFOUND*   = FileUtil.ERROR_PATH_NOT_FOUND; (** the stated path could not be found         *)
  INVALIDDRIVE*   = FileUtil.ERROR_INVALID_DRIVE;  (** the indicated drive could not be found     *)
  NOMOREFILES*    = FileUtil.ERROR_NO_MORE_FILES;  (** no further suitable files could be found   
                                                       \NEWGROUP File Attributes *)
  
  ATTRREADONLY*  = 0; (** the file is read-only                     *)
  ATTRHIDDEN*    = 1; (** the file is hidden                        *)
  ATTRSYSTEM*    = 2; (** the file is part of the operating system  *)
  ATTRVOLUME*    = 3; (** maintained for compatibility only         *)
  ATTRDIR*       = 4; (** file entry is really a directory          *)
  ATTRARCHIVE*   = 5; (** file marked for backup                    *)
  ATTRNORMAL*    = 7; (** a plain file with no other attributes set *)
  ATTRTEMP*      = 8; (** the file is used for temporary storage    *)
  ATTRCOMPRESSED*=11; (** the file or directory is compressed       *)
  ATTROFFLINE*   =12; (** file currently physically unavailable     *)

  
TYPE
  (* This class serves for searching for directory entries which match some 
     given searching criteria. *)
  Scan*=RECORD
    fData:WB.WIN32_FIND_DATA;
    searchHandle:WD.HANDLE;
  END;
  ScanP*=POINTER TO Scan;
  RetCodeT*=INTEGER;
  
PROCEDURE GetErrorMessage*(error:RetCodeT; VAR message:ARRAY OF CHAR);
(** The text returned in <message> describes the error code error.
    All return values for all functions in this module may be passed 
    as an error code. Under certain circumstances an error code might 
    be reported which is different from all predefined constants. 
    Even in this case GetErrorMessage will provide an appropriate text.
    
    Identical constants for error codes defined in the module Volume 
    have the same numerical value as their counterparts in the module File. *)
BEGIN
  FileUtil.GetErrorMessage(error,message);
END GetErrorMessage;

PROCEDURE CurrentDirectory*(VAR dir:ARRAY OF CHAR;
                            VAR resCode:RetCodeT);
(** The current directory of the current drive is returned in <dir>. The 
    path stated in <dir> always contains a drive identification.

    The interface has changed from OPAL 16 bit: the drive is no longer a parameter
    of this function. *)
VAR 
  bufLen,res:LONGINT;
  tmp:LONGINT;
BEGIN
  bufLen:=LEN(dir);
  res:=WB.GetCurrentDirectoryA(bufLen,SYSTEM.ADR(dir));
  IF (res=0) OR (res>bufLen) THEN
    dir[0]:=0X;
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END CurrentDirectory;

PROCEDURE ChangeDirectory*(dir:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The current directory is changed to the one stated in <dir>. If the path 
    in <dir> contains a drive identification, the current directory of this 
    drive is selected, otherwise the directory of the current drive if it exists. 
    The current drive remains unchanged.
    
    The parameter <resCode> returns an error code. *)
VAR
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(dir);
  IF WB.SetCurrentDirectoryA(SYSTEM.ADR(dir))=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END ChangeDirectory;

PROCEDURE CreateDirectory*(dir:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The directory specified by <dir> is created. Only one directory and not 
    a whole path can be created per call.
    
    The parameter <resCode> returns an error code. *)
VAR
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(dir);
  IF WB.CreateDirectoryA(SYSTEM.ADR(dir),NIL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END CreateDirectory;

PROCEDURE RemoveDirectory*(dir:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The directory stated in <dir> is removed. 
    
    The parameter <resCode> returns an error code. *)
VAR
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(dir);
  IF WB.RemoveDirectoryA(SYSTEM.ADR(dir))=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END RemoveDirectory;

PROCEDURE GetDiskSpace(drive:ARRAY OF CHAR; 
                       VAR sectorsPerCluster,
                           totalClusters,
                           bytesPerSector,
                           freeClusters:LONGINT;
                       VAR resCode:RetCodeT);
VAR
  tmp:LONGINT;
BEGIN
  IF WB.GetDiskFreeSpaceA(SYSTEM.ADR(drive),
                            sectorsPerCluster,
                            bytesPerSector,
                            freeClusters,
                            totalClusters)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END GetDiskSpace;

PROCEDURE GetUnitSize(s1,s2,s3:LONGINT; VAR size,unit:LONGINT);
(* assumption: at least 1 of the three factors can be
   divided through at least 512 without remainder and
   another factor can be divided by 2. *)
VAR
  h:LONGINT;
  n1,n2,n3:LONGINT;

  PROCEDURE Normalize(x:LONGINT; VAR xNorm,power:LONGINT);
  BEGIN
    xNorm:=x;
    power:=1;
    IF x#0 THEN
      WHILE (xNorm MOD 2=0) & (power<1024) DO
        xNorm:=xNorm DIV 2;
        power:=power * 2;
      END;
    END;
  END Normalize;
 
BEGIN
  Normalize(s1,n1,unit);
  Normalize(s2,n2,h); unit:=unit*h;
  Normalize(s3,n3,h); unit:=unit*h;
  IF n1*n2*n3<MAX(LONGINT) DIV unit THEN
    unit:=1;
    size:=s1*s2*s3;
  ELSE
    IF unit>1024 THEN
      size:=n1*n2*n3;
      WHILE unit>1024 DO
        unit:=unit DIV 2;
        size:=size * 2;
      END;
    ELSE
      IF (n1<n2) & (n2>n3) THEN
        h:=n1; n1:=n2; n2:=h;
      ELSIF n1<n3 THEN
        h:=n1; n1:=n3; n3:=h;
      END;
      WHILE unit<1024 DO
        unit:=unit * 2;
        n1:=n1 DIV 2;
      END;
      size:=n1*n2*n3;
    END;
  END;
END GetUnitSize;

PROCEDURE FreeSpace*(drive:ARRAY OF CHAR; 
                     VAR space:LONGINT; 
                     VAR unit:LONGINT; (** <unit> determins the unit used for the number returned in <space>.
                                           The returned value is either 1 for 1 byte or 1024 for kBytes. 
                                           The smallest possible unit is used which still allows
                                           <space> to be expressed as a LONGINT. *)
                     VAR resCode:RetCodeT);
(** The available space on the drive specified by <drive> is returned in <space>. The
    free space in bytes is <space> * <unit>. 
    
    The parameter <resCode> returns an error code. *)
VAR
  sect,totalClust,bytes,freeClust:LONGINT;
BEGIN
  GetDiskSpace(drive,sect,totalClust,bytes,freeClust,resCode);
  IF resCode=NOERROR THEN 
    GetUnitSize(sect,bytes,freeClust,space,unit);
  ELSE
    space:=0;
    unit:=1;
  END;
END FreeSpace;

PROCEDURE TotalSpace*(drive:ARRAY OF CHAR; 
                      VAR space:LONGINT; 
                      VAR unit:LONGINT; (** <unit> determins the unit used for the number returned in <space>.
                                            The returned value is either 1 for 1 byte or 1024 for kBytes. 
                                            The smallest possible unit is used which still allows
                                            <space> to be expressed as a LONGINT. *)
                      VAR resCode:RetCodeT);
(** The full drive capacity of <drive> in bytes is returned in <space>. The full space
    in bytes is <space> * <unit>.
    
    The parameter resCode returns an error code. *)
                        
VAR
  sect,totalClust,bytes,freeClust:LONGINT;
BEGIN
  GetDiskSpace(drive,sect,totalClust,bytes,freeClust,resCode);
  IF resCode=NOERROR THEN 
    GetUnitSize(sect,bytes,totalClust,space,unit);
  ELSE
    space:=0;
    unit:=1;
  END;
END TotalSpace;

PROCEDURE (VAR self:Scan) First*(searchName:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The first directory entry that matches the stated searching pattern given in 
    <searchName> is searched. This method must be called before any other method.
    In <searchName> any path may be stated; wildcards like "*" and "?" are permitted 
    in the file name.
    
    "*" stands for any number and combination of characters and "?" for 
    precisely one character.
    
    Example for <searchName>:
    "C:\WIN98\*.DLL" starts a search for all files with the extension "DLL" 
    in the directory "C:\WIN98".
    
    If the value NOERROR was returned in <resCode> the search was successful 
    and the name and other characteristics of the matching directory entry may 
    then be obtained using the other methods of the scan object. *)
VAR
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(searchName);
  self.searchHandle:=WB.FindFirstFileA(SYSTEM.ADR(searchName),self.fData);
  IF self.searchHandle=WB.INVALID_HANDLE_VALUE THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END First;

PROCEDURE (VAR self:Scan) Next*(VAR resCode:RetCodeT);
(** On each call of this method the next matching directory entry is searched 
    for until no more entries are available. If the value NOERROR is returned 
    in <resCode> the search was successful and the name and other characteristics 
    of the found entry may be obtained using the corresponding methods. If an 
    error occurs then the methods GetName, GetSize, GetAttr, GetCreationDate, 
    and GetModifyDate must not be called. *)
VAR
  tmp:LONGINT;
BEGIN
  IF WB.FindNextFileA(self.searchHandle,self.fData)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Next;

PROCEDURE (VAR self:Scan) GetName*(VAR fileName:ARRAY OF CHAR);
(** The name of the last matching entry is returned in <fileName>. If the 
    size of <fileName> is not sufficient to hold the result an empty string 
    is returned. The array for the parameter <fileName> should be sized using 
    the constant MAXFILENAME. *)
BEGIN
  COPY(self.fData.cFileName,fileName);
END GetName;

PROCEDURE (VAR self:Scan) GetCreationDate*(VAR dateStr:ARRAY OF CHAR);
(** The creation date of the found file is returned in <dateStr>. If the underlying
    file system does not supply this information an empty string is returned. *)
BEGIN
  FileUtil.Date2String(self.fData.ftCreationTime,dateStr);
END GetCreationDate;

PROCEDURE (VAR self:Scan) GetModifyDate*(VAR dateStr:ARRAY OF CHAR);
(** The date of the last modification of the found file is returned in <dateStr>.
    The format of the date is "DD.MM.YYYY  HH:MM:SS" with two separating blanks. 
    The total length of the string is 20 characters. If <dateStr> cannot hold a string 
    of length 20 the result is truncated. *)
BEGIN
  FileUtil.Date2String(self.fData.ftLastWriteTime,dateStr);
END GetModifyDate;

PROCEDURE (VAR self:Scan) GetAccessDate*(VAR dateStr:ARRAY OF CHAR);
(** The date at which the found file has been accessed the last time is 
    returned in <dateStr>. If the underlying file system does not supply 
    this information an empty string is returned. *)
BEGIN
  FileUtil.Date2String(self.fData.ftLastAccessTime,dateStr);
END GetAccessDate;

PROCEDURE (VAR self:Scan) GetAttr*():SET;
(** The return value of the function is a set containing the attributes of the 
    last detected directory entry.
    The ATTR* constants should be used to evaluate the contents of the returned set. *)
BEGIN
  RETURN SYSTEM.VAL(SET,self.fData.dwFileAttributes);
END GetAttr;

PROCEDURE (VAR self:Scan) GetSize*():LONGINT;
(** The return value of the function is the size of the last detected file. *)
BEGIN
  RETURN self.fData.nFileSizeLow;
END GetSize;

END Volume.
