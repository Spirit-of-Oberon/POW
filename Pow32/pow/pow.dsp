# Microsoft Developer Studio Project File - Name="pow" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=pow - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "pow.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "pow.mak" CFG="pow - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "pow - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "pow - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "pow - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /Od /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o NUL /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o NUL /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /stack:0x10000000 /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "pow - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o NUL /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o NUL /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /stack:0x10000000 /subsystem:windows /pdb:none /debug /machine:I386

!ENDIF 

# Begin Target

# Name "pow - Win32 Release"
# Name "pow - Win32 Debug"
# Begin Source File

SOURCE=.\CHILDREN.ICO
# End Source File
# Begin Source File

SOURCE=.\COMP.BMP
# End Source File
# Begin Source File

SOURCE=.\GREY.BMP
# End Source File
# Begin Source File

SOURCE=.\POW.C
# End Source File
# Begin Source File

SOURCE=.\POW.ICO
# End Source File
# Begin Source File

SOURCE=.\POW.RC

!IF  "$(CFG)" == "pow - Win32 Release"

!ELSEIF  "$(CFG)" == "pow - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\pow32.def
# End Source File
# Begin Source File

SOURCE=.\POWBUG.C
# End Source File
# Begin Source File

SOURCE=.\POWCOMP.C
# End Source File
# Begin Source File

SOURCE=.\powCompiler.c
# End Source File
# Begin Source File

SOURCE=.\POWDDE.C
# End Source File
# Begin Source File

SOURCE=.\POWED.C
# End Source File
# Begin Source File

SOURCE=.\POWFILE.C
# End Source File
# Begin Source File

SOURCE=.\POWFIND.C
# End Source File
# Begin Source File

SOURCE=.\POWINIT.C
# End Source File
# Begin Source File

SOURCE=.\powintro.c
# End Source File
# Begin Source File

SOURCE=.\POWOPEN.C
# End Source File
# Begin Source File

SOURCE=.\POWOPTS.C
# End Source File
# Begin Source File

SOURCE=.\POWPRINT.C
# End Source File
# Begin Source File

SOURCE=.\POWPROJ.C
# End Source File
# Begin Source File

SOURCE=.\POWRIBB.C
# End Source File
# Begin Source File

SOURCE=.\POWRUN.C
# End Source File
# Begin Source File

SOURCE=.\POWSTAT.C
# End Source File
# Begin Source File

SOURCE=.\POWTEMP.C
# End Source File
# Begin Source File

SOURCE=.\POWTEXT.C
# End Source File
# Begin Source File

SOURCE=.\POWTOOLS.C
# End Source File
# Begin Source File

SOURCE=.\SAVEGRY.BMP
# End Source File
# Begin Source File

SOURCE=.\SBAR.BMP
# End Source File
# Begin Source File

SOURCE=.\SHADE.BMP
# End Source File
# Begin Source File

SOURCE=.\STAT.BMP
# End Source File
# Begin Source File

SOURCE=.\TOOL13.BMP
# End Source File
# Begin Source File

SOURCE=.\TOOL17.BMP
# End Source File
# End Target
# End Project
