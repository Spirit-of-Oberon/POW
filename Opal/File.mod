(*----------------------------------------------------------------------------*)
(* Copyright (c) 1997 by the POW! team                                        *)
(*                    e-Mail: pow@fim.uni-linz.ac.at                          *)
(*----------------------------------------------------------------------------*)
(*  08-30-1997 rel. 32/1.0 LEI                                                *)
(*  09-21-1998 rel. 32/1.1 LEI fixes to support SHORTBUFFER correctly         *)
(**---------------------------------------------------------------------------  
  This module provides the functionality needed for working with files and
  doing file management.

  All functions for file processing need a so-called <Handle> which is a unique
  reference which identifies a particular file. To obtain a valid handle a file
  must be opened with the function <Open>. When all work on a file has been
  completed the file must be closed with the function <Close>.

  Functions that refer to a file as a whole rather than its contents require
  its file name as an argument instead of a handle.

  Files are regarded as streams of characters without predefined type. Single
  characters or whole data blocks can be read one after another. In order to
  control the current reading position within a file the system provides an
  internal variable for every open file, the so-called "fle pointer", which
  is also used to define the writing position. Initially the value of the file
  pointer start with zero.

  After data has been read or written at the current position, the file pointer
  is moved on for each read or written character. Additionally, there are
  functions <Seek> and <SeekRel> which make it possible to set the file pointer
  to a particular position.
  ----------------------------------------------------------------------------*)

MODULE File;

IMPORT SYSTEM,WD:=WinDef,WB:=WinBase,WN:=WinNT,
       Utils,Strings,FileUtil;

CONST
  MAXPATH*=256;     (** maximum length of a full pathname including the filename *)
  MAXFILENAME*=256; (** maximum length of a filename 

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
  ATTROFFLINE*   =12; (** file currently physically unavailable     

  \NEWGROUP Constants for <mode> parameter of open command          *)

  READONLY*=0;        (** The file will be read only.               *)
  WRITEONLY*=1;       (** The file will be written to only.         *)
  READWRITE*=2;       (** The file will be read from and written to. 

  \NEWGROUP Constants for <deny> parameter of open command          *)

  DENYALL*=10H;      (** No simultaneous access is allowed.         *)
  DENYNONE*=40H;     (** The file may be read and written by others at the same time. *)
  DENYREAD*=30H;     (** The file may be written by others at the same time. *)
  DENYWRITE*=20H;    (** The file may be read by others at the same time. 

  \NEWGROUP Error Codes                                             *)

  ACCESSDENIED*     = FileUtil.ERROR_ACCESS_DENIED;     (** The access to the file was denied by the operating system. *)
  EOFREACHED*       = FileUtil.ERROR_HANDLE_EOF;        (** The end of the file was reached. *)
  FILENOTFOUND*     = FileUtil.ERROR_FILE_NOT_FOUND;    (** The file could not be found. *)
  INVALIDHANDLE*    = FileUtil.ERROR_INVALID_HANDLE;    (** The supplied file handle does not refer to a properly opened file *)
  NOERROR*          = FileUtil.NOERROR;                 (** The operation was carried out successfully. *)
  SHARINGVIOLATION* = FileUtil.ERROR_SHARING_VIOLATION; (** The file has already been opened and must not be opened a second time with the requested rights. *)
  SHORTBUFFER*      = FileUtil.SHORTBUFFER;             (** The data buffer supplied is not big enough for the result. *)
  WRITEPROTECTED*   = FileUtil.ERROR_WRITE_PROTECT;     (** An attempt was made to write to a write-protected drive. *)
  

TYPE
  (** The type handle serves for storing file handles. *)
  Handle*=WD.HANDLE; 
  RetCodeT*=INTEGER;

PROCEDURE Open*(name:ARRAY OF CHAR;  (** name of the file which should be opened or created *)
                create:BOOLEAN;      (** If set to TRUE then the file is created if it does not exist already. *)
                deny:INTEGER;        (** defines whether the file may be used by other programs at the same time and how. See DENY* constants. *)
                mode:INTEGER;        (** defines the required kind of access to the file. See READONLY, WRITEONLY, READWRITE *)
                VAR fHandle:Handle;  (** returns the file handle if successful *)
                VAR resCode:RetCodeT (** returns an error code *)
               );
(** Opens a file.

    The file name is passed in <name> along with an optional path. The name 
    must not contain any wildcards like "?" or "*".
    Otherwise the code FILENOTFOUND is returned and the operation is abandoned.
    
    If the file was opened successfully a handle for the open file is returned 
    in <fHandle> and the file pointer is set to the beginning of the file.

    The parameter <resCode> returns an error code. *)
VAR
  accessFlag:LONGINT;
  shareFlag:LONGINT;
  createFlag:LONGINT;
  tmp:LONGINT;
BEGIN
  CASE mode OF
    READONLY:  accessFlag:=WN.GENERIC_READ;
  | WRITEONLY: accessFlag:=WN.GENERIC_WRITE;
  | READWRITE: accessFlag:=SYSTEM.BITOR(WN.GENERIC_READ,WN.GENERIC_WRITE);
  ELSE
    resCode:=FileUtil.ERROR_OPEN_FAILED;
    fHandle:=WD.NULL;
    RETURN;
  END;
  CASE deny OF
    DENYALL:   shareFlag:=0;
  | DENYWRITE: shareFlag:=WN.FILE_SHARE_READ;
  | DENYREAD:  shareFlag:=WN.FILE_SHARE_WRITE;
  | DENYNONE:  shareFlag:=SYSTEM.BITOR(WN.FILE_SHARE_READ,WN.FILE_SHARE_WRITE);
  ELSE
    resCode:=FileUtil.ERROR_OPEN_FAILED;
    fHandle:=WD.NULL;
    RETURN;
  END;
  IF create THEN createFlag:=WB.OPEN_ALWAYS ELSE createFlag:=WB.OPEN_EXISTING END;
  fHandle:=WB.CreateFileA(SYSTEM.ADR(name),        (* file name *)
                          accessFlag,              (* access mode *)
                          shareFlag,               (* share mode *)
                          NIL,
                          createFlag,              (* reaction to file exists / does not exists *)
                          WN.FILE_ATTRIBUTE_NORMAL,(* file flags and attributes *)
                          WD.NULL);
  IF fHandle=WB.INVALID_HANDLE_VALUE THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Open;

PROCEDURE Close*(handle:Handle);
(** The file specified by <handle> is closed. *)
VAR
  dummy:WD.BOOL;
BEGIN
  dummy:=WB.CloseHandle(handle);
END Close;

PROCEDURE GetErrorMessage*(error:RetCodeT; VAR message:ARRAY OF CHAR);
(** The text returned in message explains the error code error.
    If an invalid error code is passed as a parameter a suitable error message 
    is also returned.
    Identical constants for error codes defined in the module Volume have the 
    same numerical value as their counterparts of the module File. *)
BEGIN
  FileUtil.GetErrorMessage(error,message);
END GetErrorMessage;

PROCEDURE Pos*(handle:Handle; VAR pos:LONGINT; VAR resCode:RetCodeT);
(** The position of the file pointer of the file specified by <handle> is 
    returned in <pos>.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  pos:=WB.SetFilePointer(handle,0,0,WB.FILE_CURRENT);
  IF pos=-1 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Pos;

PROCEDURE Seek*(handle:Handle; pos:LONGINT; VAR resCode:RetCodeT);
(** The file pointer of the file specified by <handle> is set to <pos>.
    If this is not possible the file pointer is set to the end of the file.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  IF WB.SetFilePointer(handle,pos,0,WB.FILE_BEGIN)=-1 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Seek;

PROCEDURE SeekRel*(handle:Handle; pos:LONGINT; VAR resCode:RetCodeT);
(** The file pointer of the file specified by <handle> is transposed by <pos>
    characters. For example, a value -1 in <pos> would move the file pointer one 
    character back. If the operation is unsuccessful, the file pointer is set to 
    the end of the file.
    
    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  IF WB.SetFilePointer(handle,pos,0,WB.FILE_CURRENT)=-1 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END SeekRel;

PROCEDURE Size*(handle:Handle; VAR len:LONGINT; VAR resCode:RetCodeT);
(** The length of the file specified by <handle> is returned in <len>. 

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  len:=WB.GetFileSize(handle,0);
  IF len=-1 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Size;

PROCEDURE ReadChar*(handle:Handle; VAR x:CHAR; VAR resCode:RetCodeT);
(** A character is read from the file specified by <handle> and returned in <x>.

    The parameter <resCode> returns an error code. *)
VAR
  bytesRead:LONGINT;
  tmp:LONGINT;
BEGIN
  IF WB.ReadFile(handle,SYSTEM.ADR(x),1,bytesRead,WD.NULL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    IF bytesRead=0 THEN x:=0X; resCode:=EOFREACHED ELSE resCode:=NOERROR END;
  END;
END ReadChar;

PROCEDURE WriteChar*(handle:Handle; x:CHAR; VAR resCode:RetCodeT);
(** The character <x> is written to the file specified by <handle>.

    The parameter <resCode> returns an error code. *)
VAR
  bytesWritten:LONGINT;
  tmp:LONGINT;
BEGIN
  IF WB.WriteFile(handle,SYSTEM.ADR(x),1,bytesWritten,WD.NULL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END WriteChar;

PROCEDURE Truncate*(handle:Handle; VAR resCode:RetCodeT);
(** The file specified by <handle> is truncated at the current position of 
    the file pointer. With this function the size of a file can be reduced.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  IF WB.SetEndOfFile(handle)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Truncate;

PROCEDURE ReadLn*(handle:Handle; VAR t:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The file specified by <handle> is regarded as a text file. Starting from 
    the current position of the file pointer a line is read and returned in 
    <t>. A line is terminated either by CR, LF, CR LF, or the end of the file.

    The parameter <resCode> returns an error code. If t is too short to hold
    the whole read line the error code SHORTBUFFER is returned.*)
VAR 
  x:CHAR;
  i:LONGINT;
  l:LONGINT;          (* allow the line to end with CR, LF or CR LF *)
BEGIN
  i:=0;
  l:=LEN(t)-1;
  LOOP
    ReadChar(handle,x,resCode);
    IF ~((resCode=NOERROR) & (x#0DX) & (x#0AX) & (i<l)) THEN EXIT END;
    t[i]:=x;
    INC(i);
  END;
  t[i]:=0X;
  IF resCode=NOERROR THEN 
    IF x=0DX THEN
      ReadChar(handle,x,resCode);
      IF (resCode=NOERROR) & (x#0AX) THEN
        SeekRel(handle,-1,resCode);
      END;
      IF resCode=EOFREACHED THEN resCode:=0; END;
    ELSIF i>=l THEN
      SeekRel(handle,-1,resCode);
      resCode:=SHORTBUFFER;
    END;
  END;
END ReadLn;

PROCEDURE WriteLn*(handle:Handle; VAR txt-:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The file specified by <handle> is regarded as a text file. The string passed 
    in <txt> is written to the file and terminated according to the operating 
    system conventions. OPAL for Windows uses the characters CR LF as the mark 
    for the end of a line. The string terminator (0) is not written to the file.
    A file written with WriteLn can be edited directly with any ASCII editor. 
    Every string written with WriteLn appears as a line in the editor.

    The parameter <resCode> returns an error code. *)
VAR
  bytesWritten:LONGINT;
  tmp:LONGINT;
BEGIN
  IF WB.WriteFile(handle,SYSTEM.ADR(txt),Strings.Length(txt),bytesWritten,WD.NULL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    WriteChar(handle,0DX,resCode);
    IF resCode=NOERROR THEN WriteChar(handle,0AX,resCode) END;
  END;
END WriteLn;

PROCEDURE ReadBlock*(handle:Handle; 
                     VAR data:ARRAY OF SYSTEM.BYTE; 
                     n:LONGINT; 
                     VAR bytesRead:LONGINT; 
                     VAR resCode:RetCodeT);
(** An attempt is made to read a block of the length <n> from the file specified 
    by <handle>. The number of bytes actually read is returned in <bytesRead>.
    The file data are written into the region determined by <data>. As <data>
    is of the type SYSTEM.BYTE any types can be passed. Thus data can be 
    directly written into a structure or an array. If <data> is not large enough 
    to hold <n> bytes the maximum number of bytes possible is read and the return 
    value of the function is set to SHORTBUFFER.
    If an error prevents the reading of data, <bytesRead> is set to zero and the 
    error code is returned in the parameter <resCode>. *)
VAR 
  tmp:LONGINT;
  shortBuffer:BOOLEAN;
BEGIN
  shortBuffer:=n > LEN(data);
  IF shortBuffer THEN n:=LEN(data) END;
  IF WB.ReadFile(handle,SYSTEM.ADR(data),n,bytesRead,WD.NULL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    IF bytesRead<n THEN 
      resCode:=EOFREACHED;
    ELSE 
      IF shortBuffer THEN resCode:=SHORTBUFFER ELSE resCode:=NOERROR END;
    END;
  END;
END ReadBlock;

PROCEDURE WriteBlock*(handle:Handle; 
                      VAR data-:ARRAY OF SYSTEM.BYTE; 
                      n:LONGINT; 
                      VAR resCode:RetCodeT);
(** A block <n> bytes long is written to the file specified by <handle>. 
    The data to be written are specified by <data>. The amount of data is 
    limited by the actual size of <data>, even if <n> is larger.

    The parameter <resCode> returns an error code *)                        
VAR
  bytesWritten:LONGINT;
  tmp:LONGINT;
BEGIN
  IF n > LEN(data) THEN n:=LEN(data) END;
  IF WB.WriteFile(handle,SYSTEM.ADR(data),n,bytesWritten,WD.NULL)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END WriteBlock;

PROCEDURE AtEnd*(handle:Handle):BOOLEAN;
(** The return value of this function is TRUE if the file pointer points 
    to the end of the file specified by <handle>.
    If it is impossible to determine a correct result (e.g., <handle> does 
    not contain a valid reference to an open file), the return value of the 
    function is TRUE. *)
VAR
  res1,res2:RetCodeT;
  l1,l2:LONGINT;
BEGIN
  Size(handle,l1,res1);
  Pos(handle,l2,res2);
  RETURN (res1#NOERROR) OR (res2#NOERROR) OR (l1=l2);
END AtEnd;

PROCEDURE GetModifyDate*(handle:Handle; VAR date:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The date of the last modification of the file specified by <handle> is 
    returned in <date>.
    
    The format for the date is "DD.MM.YYYY  HH:MM:SS" and the total length of 
    the string is 20 characters (two separating blanks between date and time).
    
    Example: "15. 4.1998  18:06:27"
    
    The parameter <resCode> returns an error code. *)
VAR
  fileData:WB.BY_HANDLE_FILE_INFORMATION;
  tmp:LONGINT;
BEGIN
  IF WB.GetFileInformationByHandle(handle,fileData)=0 THEN
    date[0]:=0X;
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    FileUtil.Date2String(fileData.ftLastWriteTime,date);
    resCode:=NOERROR;
  END;
END GetModifyDate;

PROCEDURE GetCreationDate*(handle:Handle; VAR date:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The creation date of the file specified by <handle> is returned in <date>. 
    If the underlying file system does not support this feature, an empty
    string is returned in <date>.

    The format for the date is "DD.MM.YYYY  HH:MM:SS" and the total length of 
    the string is 20 characters (two separating blanks between date and time).
    
    Example: "15. 4.1998  18:06:27"

    The parameter <resCode> returns an error code. *)
VAR
  fileData:WB.BY_HANDLE_FILE_INFORMATION;
  tmp:LONGINT;
BEGIN
  IF WB.GetFileInformationByHandle(handle,fileData)=0 THEN
    date[0]:=0X;
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    FileUtil.Date2String(fileData.ftCreationTime,date);
    resCode:=NOERROR;
  END;
END GetCreationDate;

PROCEDURE GetAccessDate*(handle:Handle; VAR date:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The time at which the file specified by <handle> was accessed for the last time
    is returned in <date>. 
    If the underlying file system does not support this feature, an empty
    string is returned in <date>.

    The format for the date is "DD.MM.YYYY  HH:MM:SS" and the total length of 
    the string is 20 characters (two separating blanks between date and time).
    
    Example: "15. 4.1998  18:06:27"

    The parameter <resCode> returns an error code. *)
VAR
  fileData:WB.BY_HANDLE_FILE_INFORMATION;
  tmp:LONGINT;
BEGIN
  IF WB.GetFileInformationByHandle(handle,fileData)=0 THEN
    date[0]:=0X;
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    FileUtil.Date2String(fileData.ftLastAccessTime,date);
    resCode:=NOERROR;
  END;
END GetAccessDate;

PROCEDURE SetModifyDate*(handle:Handle; VAR date-:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The date of the last modification of the file specified by <handle> is set 
    to <date>. The format for the date is "DD.MM.YYYY  HH:MM:SS" (two blanks are required 
    between date and time) and the total length of the string is 20 characters.

    The parameter <resCode> returns an error code. *)
VAR
  fileTime:WB.FILETIME;
  tmp:LONGINT;
BEGIN
  FileUtil.String2Date(date,fileTime);
  IF WB.SetFileTime(handle,NIL,NIL,fileTime)=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END SetModifyDate;

PROCEDURE Exist*(name:ARRAY OF CHAR):BOOLEAN;
(** This function checks whether a certain file exists. The name of the 
    file together with an optional path must be passed in <name>. The return 
    value of the function is TRUE if the file exists.
    <name> may also contain wildchards. *)
VAR
  fData:WB.WIN32_FIND_DATA;
  handle:WD.HANDLE;
BEGIN
  handle:=WB.FindFirstFileA(SYSTEM.ADR(name),fData);
  RETURN handle#WB.INVALID_HANDLE_VALUE;
END Exist;  
  
PROCEDURE GetAttributes*(name:ARRAY OF CHAR; VAR attr:SET; VAR resCode:RetCodeT);
(** The attributes of the directory entry with the name specified by <name> are 
    accessed and returned in <attr>. It is therefore possible to find out if 
    a directory entry is a file or a further directory.
    For a list of the constants which can be used in connection with <attr> 
    see the description of the ATTR* constants.

    The parameter <resCode> returns an error code. *)
VAR
  h:LONGINT;
  tmp:LONGINT;
BEGIN
  h:=WB.GetFileAttributesA(SYSTEM.ADR(name));
  IF h=-1 THEN
    attr:={};
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    attr:=SYSTEM.VAL(SET,h);
    resCode:=NOERROR;
  END;
END GetAttributes;

PROCEDURE SetAttributes*(name:ARRAY OF CHAR; attr:SET; VAR resCode:RetCodeT);
(** The attributes of the file with the name specified by <name> are set to <attr>.
    For a list of the constants which can be used in connection with <attr> 
    see the description of the ATTR* constants.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  IF WB.SetFileAttributesA(SYSTEM.ADR(name),SYSTEM.VAL(LONGINT,attr))=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END SetAttributes;

PROCEDURE Rename*(oldName,newName:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The file with the name specified in <oldName> is renamed to <newName>.
    The name may also contain a path. Wildcards such as "*" or "?" are not allowed.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(oldName);
  FileUtil.CorrectDelimiters(newName);
  IF WB.MoveFileA(SYSTEM.ADR(oldName),SYSTEM.ADR(newName))=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Rename;

PROCEDURE Delete*(name:ARRAY OF CHAR; VAR resCode:RetCodeT);
(** The file with the name specified in <name> is deleted. The name may also 
    contain a path. Wildcards such as "*" or "?" are not permitted.

    The parameter <resCode> returns an error code. *)
VAR 
  tmp:LONGINT;
BEGIN
  FileUtil.CorrectDelimiters(name);
  IF WB.DeleteFileA(SYSTEM.ADR(name))=0 THEN
    tmp:=WB.GetLastError();
    IF tmp>MAX(LONGINT) THEN resCode:=-1 ELSE resCode:=SHORT(tmp) END;
  ELSE
    resCode:=NOERROR;
  END;
END Delete;

END File.
